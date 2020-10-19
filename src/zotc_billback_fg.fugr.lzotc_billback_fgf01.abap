************************************************************************
* PROGRAM    :  LZOTC_BILLBACK_FGF01 (Include)                         *
* TITLE      :  Billback Enhancement for Billing User Exit             *
* DEVELOPER  :  ANANYA DAS                                             *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0043                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Update Custom table with Billing informations when
* Invoice is created and Accounting documement is genarated
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 25-APR-2012  RNATHAK  E1DK901257 INITIAL DEVELOPMENT                 *
* 18-DEC-2012  ADAS1    E1DK906242 D#2213: Settled Quantity not updated
*                                          if original inv not exists
*                                  Sorting seq changed for VBFA and
*                                  Staging internal table.
*                                  settled qnty updated for credit/debit.
*                                  Instead of flag, check if the original
*                                  Invoice exists to update the original
*                                  Invoice.
* 26-DEC-2012 ADAS1     E1DK908679 D#2213: For Legacy Billing doc,
*                       get billing qty from ZOTC_BILLBACK table instead
*                       of VBRP table
* 29-MAR-2013 ADAS1     E1DK909552 D#3129: Structure mismatch of
*                                  fp_i_billback and lwa_billback for
*                                  setting Old/New indicator
* 19-APR-2013  ADAS1    E1DK910010 D#3611: Change logic for sold-to,
*                                  ship-to and PO Date to incorporate
*                                  mass update
* 09-MAY-2013  BMAJI    E1DK910352 D#3745: Change logic for call of FM
*                                  ZOTC_0043_BILLBACK_MOD_TAB in
*                                  UPDATE TASK in Subroutine
*                                  F_UPDATE_DB
* 07-DEC-2013  SBASU    E1DK912403 D#1069: VBFA not intial check missing
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_STACK_VAL
*&---------------------------------------------------------------------*
*       Get all Stack values
*----------------------------------------------------------------------*
*      -->FP_IM_VBRK   Billing Header
*      <--FP_LV_INDEX  Index for items
*      <--FP_LI_CVBRP  Billing Item table
*      <--FP_WA_KUAGV  Sold-to-party
*      <--FP_WA_KUWEV  Ship-to-party
*      <--FP_WA_VBKD   Sales Document: Business Data
*      <--FP_WA_VBPA   Sales Document: Partner
*----------------------------------------------------------------------*
FORM f_get_stack_val  USING    fp_im_vbrk   TYPE vbrk
                               fp_lv_index  TYPE char10
                               fp_li_cvbrp  TYPE vbrpvb_t
                      CHANGING fp_wa_kuagv  TYPE kuagv
                               fp_wa_kuwev  TYPE kuwev
                               fp_wa_vbkd   TYPE vbkd
                               fp_i_vbpa    TYPE vbpavb_tab.

* Declare Local constants
  CONSTANTS: lc_ship_to_stk TYPE char20 VALUE '(SAPLV60A)KUWEV',
             " Sold-to-party
             lc_sold_to_stk TYPE char20 VALUE '(SAPLV60A)KUAGV',
             " Ship-to-party
             lc_vbkd_stk    TYPE char20 VALUE '(SAPLV60A)VBKD',
             " SD: Business Data
             lc_vbpa_stk    TYPE char20 VALUE '(SAPLV60A)XVBPA[]'.
  " SD: Partner

  DATA:  li_callstack  TYPE abap_callstack,
         lwa_callstack TYPE abap_callstack_line,
         lwa_vbpa      TYPE vbpavb,
         lwa_cvbrp     TYPE vbrpvb.

* Declare Local Field symbol
  FIELD-SYMBOLS: <lfs_kuwev> TYPE kuwev,     " Ship-to-party
                 <lfs_kuagv> TYPE kuagv,     " Sold-to-party
                 <lfs_vbkd>  TYPE vbkd,      " SD: Business Data
                 <lfs_vbpa>  TYPE vbpavb_tab." SD: Partner

* Check system callstack to avoid GETWA_NOT_ASSIGNED dump when run from
* KE4S tcode for reverse the billing doc
  CALL FUNCTION 'SYSTEM_CALLSTACK'
    IMPORTING
      callstack = li_callstack.

  READ TABLE li_callstack INTO lwa_callstack
     WITH KEY mainprogram = 'SAPLV60A'.
  IF sy-subrc = 0.

* BOC DEL ADAS1 D#3611
** Assign stack values to the Ship-to-party Global variable
*    ASSIGN (lc_ship_to_stk) TO <lfs_kuwev>.
*    IF sy-subrc = 0 AND <lfs_kuwev> IS ASSIGNED.
*      fp_wa_kuwev = <lfs_kuwev>.
*    ENDIF.
*
*
** Assign stack values to the Sold-to-party Global variable
*    ASSIGN (lc_sold_to_stk) TO <lfs_kuagv>.
*    IF sy-subrc = 0 AND <lfs_kuagv> IS ASSIGNED.
*      fp_wa_kuagv = <lfs_kuagv>.
*    ENDIF.
*
** Assign stack values to the SD:Business Data Global variable
*    ASSIGN (lc_vbkd_stk)    TO <lfs_vbkd>.
*    IF sy-subrc = 0 AND <lfs_vbkd> IS ASSIGNED.
*      fp_wa_vbkd  = <lfs_vbkd>.
*    ENDIF.
* EOC DEL ADAS1 D#3611

* Assign stack values to the SD: Partner Global variable
    ASSIGN (lc_vbpa_stk)    TO <lfs_vbpa>.
    IF sy-subrc = 0 AND <lfs_vbpa> IS ASSIGNED.
      fp_i_vbpa   = <lfs_vbpa>.
    ENDIF.

* BOC ADD ADAS1 D#3611
** Assign stack values to the Ship-to-party Global variable
    DELETE fp_i_vbpa WHERE vbeln NE fp_lv_index.

    CLEAR lwa_vbpa.
    READ TABLE fp_i_vbpa INTO lwa_vbpa
               WITH KEY parvw = 'WE'.
    IF sy-subrc = 0.
      fp_wa_kuwev-kunnr = lwa_vbpa-kunnr.
    ENDIF.

** Assign stack values to the Sold-to-party Global variable
    fp_wa_kuagv-kunnr = fp_im_vbrk-kunag.

* Select values from the SD:Business Data Global variable
    READ TABLE fp_li_cvbrp INTO lwa_cvbrp INDEX 1.
    IF sy-subrc = 0.
      SELECT bstdk
             INTO fp_wa_vbkd-bstdk
             UP TO 1 ROWS
             FROM vbkd
             WHERE vbeln = lwa_cvbrp-aubel.
      ENDSELECT.
    ENDIF.
* EOC ADD ADAS1 D#3611
  ENDIF.

ENDFORM.                    " F_GET_STACK_VAL
*&---------------------------------------------------------------------*
*&      Form  F_GET_CUSTOMER
*&---------------------------------------------------------------------*
*       Get Custmer Details
*----------------------------------------------------------------------*
*      <--FP_I_VBPA   SD: Partner
*      <--FP_I_EDPAR  Convert External <  > Internal Partner Number
*      <--FP_I_KNA1   Customer Master
*----------------------------------------------------------------------*
FORM f_get_customer  CHANGING fp_i_vbpa   TYPE vbpavb_tab
                              fp_i_edpar  TYPE ty_t_edpar
                              fp_i_kna1   TYPE ty_t_kna1.

* Declare Local internal table
  DATA: li_vbpa TYPE vbpavb_tab. " SD: Partners

* Keep Header and Item ship-to-party only
  DELETE fp_i_vbpa WHERE parvw <> c_ship_to.

  IF NOT fp_i_vbpa[] IS INITIAL.
    li_vbpa = fp_i_vbpa.
    SORT li_vbpa BY kunnr.
    DELETE ADJACENT DUPLICATES FROM li_vbpa COMPARING kunnr.

*   Get External partner number
    SELECT kunnr   " Customer Number
           parvw   " Partner Function
           expnr   " External partner number (in customer system)
      FROM edpar
      INTO TABLE fp_i_edpar
      FOR ALL ENTRIES IN li_vbpa
      WHERE kunnr = li_vbpa-kunnr
        AND parvw = c_ship_to.

    IF sy-subrc = 0.
      SORT fp_i_edpar BY kunnr.
    ENDIF.

*   Get international Location no
    SELECT kunnr  " Customer no
           bbbnr  " International location number  (part 1)
           bbsnr  " International location number  (part 2)
           bubkz  " Check digit for international location no
      FROM kna1
      INTO TABLE fp_i_kna1
      FOR ALL ENTRIES IN li_vbpa
      WHERE kunnr = li_vbpa-kunnr.

    IF sy-subrc = 0.
      SORT fp_i_kna1 BY kunnr.
    ENDIF.
  ENDIF. " IF NOT fp_i_vbpa[] IS INITIAL.

ENDFORM.                    " F_GET_CUSTOMER
*&---------------------------------------------------------------------*
*&      Form  F_GET_MAT_PRODFAMILY
*&---------------------------------------------------------------------*
*       Get Materials lie in the same Product family
*----------------------------------------------------------------------*
*      -->FP_CVBRP     SD: Items
*      <--FP_I_MARA[]  Material master
*----------------------------------------------------------------------*
FORM f_get_mat_prodfamily  USING    fp_wa_vbrk TYPE vbrk
                                    fp_cvbrp   TYPE vbrpvb_t
                           CHANGING fp_i_mvke  TYPE ty_t_mvke.

* Local constant declaration
  CONSTANTS: lc_star       TYPE char1  VALUE '*', " Star
             lc_str_option TYPE option VALUE 'CP'." Contains Pattern

* Local Internal table and workarea declaration
  DATA: li_vbrp         TYPE vbrpvb_t,              " SD: Items
        li_prod_family  TYPE RANGE OF char19,        " Prod family
        lwa_prod_family LIKE LINE OF li_prod_family." Prod family

* Local field symbol declaration
  FIELD-SYMBOLS: <lfs_vbrp> TYPE vbrpvb,  " SD: Item
                 <lfs_mvke> TYPE ty_mvke. " SD: Material master

* Keep unique entries of Product Family.
  li_vbrp[] = fp_cvbrp[].
  DELETE li_vbrp WHERE prodh = space.
  IF NOT li_vbrp IS INITIAL.
    SORT li_vbrp BY prodh.
    DELETE ADJACENT DUPLICATES FROM li_vbrp COMPARING prodh.

*   Get Product Family value with star (e.g. *AAAA*)
    LOOP AT li_vbrp ASSIGNING <lfs_vbrp>.
      lwa_prod_family-sign   = c_sign.
      lwa_prod_family-option = lc_str_option.
      CONCATENATE <lfs_vbrp>-prodh(11)
                  lc_star
                  INTO lwa_prod_family-low.
      APPEND lwa_prod_family TO li_prod_family.
      CLEAR: lwa_prod_family.
    ENDLOOP. " LOOP AT li_vbrp ASSIGNING <lfs_vbrp>.

*   Fetch Material Master table using product family
    SELECT matnr   " Material no
           vkorg   " Sales Organization
           vtweg   " Distribution Channel
           prodh   " Product hierarchy
           FROM mvke
           INTO TABLE fp_i_mvke
           WHERE vkorg = fp_wa_vbrk-vkorg
             AND vtweg = fp_wa_vbrk-vtweg
             AND prodh IN li_prod_family.

    IF sy-subrc = 0.
      SORT fp_i_mvke BY prdha.

      LOOP AT fp_i_mvke ASSIGNING <lfs_mvke>.

*       Populate Product Family field
        <lfs_mvke>-prodh = <lfs_mvke>-prdha(11).

*       Asumption: unique product family will not have many entres
*       Binary search cannot be used as for read using offset
        READ TABLE li_vbrp TRANSPORTING NO FIELDS
             WITH KEY prodh(11) = <lfs_mvke>-prodh.
        IF sy-subrc <> 0.
          CLEAR <lfs_mvke>-matnr.
        ENDIF.

      ENDLOOP. " LOOP AT fp_i_mara ASSIGNING <lfs_mara>.

*     Delete material master which has different product family
*     than Sales Item
      DELETE fp_i_mvke WHERE matnr IS INITIAL.
      SORT fp_i_mvke BY prodh.

    ENDIF. " IF sy-subrc = 0. Select from MVKE
  ENDIF. " IF NOT li_vbrp IS INITIAL.

ENDFORM.                    " F_GET_MAT_PRODFAMILY
*&---------------------------------------------------------------------*
*&      Form  F_GET_BILLBACK
*&---------------------------------------------------------------------*
*       Get Billback table info of last 1 year
*----------------------------------------------------------------------*
*      -->FP_CVBRP       Billing Item table
*      -->FP_I_MARA      Material Master table
*      <--FP_I_BILLBACK  Billback Custom table
*----------------------------------------------------------------------*
FORM f_get_billback  USING    fp_cvbrp     TYPE vbrpvb_t
                              fp_i_mvke    TYPE ty_t_mvke
                     CHANGING fp_i_billback TYPE ty_t_billback.

* Local Constant declaration
  CONSTANTS: lc_option TYPE option VALUE 'BT', " Between
             lc_1year  TYPE char3  VALUE '-12'." month

* Local interval table,workarea and variable declaration
  DATA:  li_vbrp     TYPE vbrpvb_t,         " Billing doc Item tab
         lr_matnr    TYPE RANGE OF matnr,   " Material master range tab
         lr_date     TYPE RANGE OF sydatum, " Date Range tab
         lwa_r_matnr LIKE LINE OF lr_matnr, " Mat master range workarea
         lwa_r_date  LIKE LINE OF lr_date,  " Date range workarea
         lv_date     TYPE sydatum.          " Date

* Local field symbol declaration
  FIELD-SYMBOLS: <lfs_mvke> TYPE ty_mvke,   " Material master:sales
                 <lfs_vbrp> TYPE vbrpvb.    " Billing doc Item workarea

* Calculate 1 year previous date
  CALL FUNCTION 'CALCULATE_DATE'
    EXPORTING
      months      = lc_1year
      start_date  = sy-datum
    IMPORTING
      result_date = lv_date.

* Populate Date Range
  lwa_r_date-sign   = c_sign.
  lwa_r_date-option = lc_option.
  lwa_r_date-low    = lv_date.
  lwa_r_date-high   = sy-datum.
  APPEND lwa_r_date TO lr_date.

* Keep unique entries of material in Billing item table
  li_vbrp[] = fp_cvbrp[].
  DELETE li_vbrp WHERE matnr = space.
  SORT li_vbrp BY matnr.
  DELETE ADJACENT DUPLICATES FROM li_vbrp COMPARING matnr.

* Material range is populated using Billing doc item materials
  LOOP AT li_vbrp ASSIGNING <lfs_vbrp>.
    lwa_r_matnr-sign = c_sign.
    lwa_r_matnr-option = c_option.
    lwa_r_matnr-low = <lfs_vbrp>-matnr.
    APPEND lwa_r_matnr TO lr_matnr.
  ENDLOOP.

* Material range is populated using all the materials lie in the
* same product family
  LOOP AT fp_i_mvke ASSIGNING <lfs_mvke>.

*  Range table for Material should be unique.
    READ TABLE li_vbrp TRANSPORTING NO FIELDS
         WITH KEY matnr = <lfs_mvke>-matnr
         BINARY SEARCH.
    IF sy-subrc <> 0.
      lwa_r_matnr-sign = c_sign.
      lwa_r_matnr-option = c_option.
      lwa_r_matnr-low = <lfs_mvke>-matnr.
      APPEND lwa_r_matnr TO lr_matnr.
    ENDIF. " IF sy-subrc <> 0. READ TABLE li_vbrp
  ENDLOOP. " LOOP AT fp_i_mara INTO lwa_mara.

* Get Billback table for all the materials and 1 year period
* Note: This is a huge table(7-8 lacs of date per year as per
* Functional person) and as per requirement,we cannot select with
* primary keys. As per Onsite coordinator(Rini Basu), we will create
* secondary index in the custom table if any issues occur during
* integration testing
  IF NOT lr_matnr[] IS INITIAL.
    SELECT  vbeln   " Billing Document
            posnr   " Billing item
            matnr   " Material Number
            vkorg   " Sales Organization
            vtweg   " Distribution Channel
            kunag   " Sold-to party
            kunnr   " Customer Number
            bstkd   " Customer purchase order number
            prodh   " Product hierarchy
            zzold_new_ind " Old/New Sale Indicator
       FROM zotc_billback
             INTO TABLE fp_i_billback
             WHERE matnr IN lr_matnr[]
               AND fkdat IN lr_date[].

    IF sy-subrc = 0.
      SORT fp_i_billback BY kunnr matnr.
    ENDIF. " IF sy-subrc = 0. SELECT * FROM zotc_billback
  ENDIF. " IF NOT lr_matnr[] IS INITIAL.

ENDFORM.                    " F_GET_BILLBACK
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_FINAL
*&---------------------------------------------------------------------*
*       Populate ZOTC_BILLBACK table
*----------------------------------------------------------------------*
*       --> fp_vbrk      Billing Header
*       --> fp_cvbrp     Billing Item
*       --> fp_i_komv    Condition table
*       --> fp_i_vbpa    SD: Partners
*       --> fp_i_edpar   External partner number
*       --> fp_i_kna1    Customer master
*       --> fp_i_billback Billback
*       --> fp_i_vbrk_vbrp_bill  Original billing doc from staging tab
*       --> fp_i_vbrk_vbrp_so    Original billing doc from SO reference
*       --> fp_i_billback_org    Original billback details
*       --> fp_wa_kuagv  Sold-to-party
*       --> fp_wa_kuwev  Ship-to-party
*       --> fp_wa_vbkd   SD: Business Data
*       <-- fp_i_zotc_billback Billback Internal table
*----------------------------------------------------------------------*
FORM f_populate_final  USING    fp_vbrk      TYPE vbrk
                                fp_cvbrp     TYPE vbrpvb_t
                                fp_i_komv    TYPE komv_tab
                                fp_i_vbpa    TYPE ty_t_vbpa
                                fp_i_edpar   TYPE ty_t_edpar
                                fp_i_kna1    TYPE ty_t_kna1
                                fp_i_billback TYPE ty_t_billback
                                fp_i_vbrk_vbrp_so TYPE ty_t_vbrk_vbrp
                                fp_i_vbrk_vbrp_bill TYPE ty_t_vbrk_vbrp
                                fp_i_billback_org TYPE ty_t_billback_org
                                fp_wa_kuwev  TYPE kuwev
                                fp_wa_vbkd   TYPE vbkd
                       CHANGING fp_i_zotc_billback TYPE
                       ty_t_zotc_billback.

* Local constant declaration
  CONSTANTS: lc_zr00   TYPE kschl         VALUE 'ZR00', " Final Price
             lc_zc00   TYPE kschl         VALUE 'ZC00', " Surcharge/Qty
             lc_new    TYPE z_old_new_ind VALUE 'N',    " New
             lc_settled TYPE flag         VALUE 'S',    " Settled
             lc_open    TYPE flag         VALUE 'O'.    " Open

  TYPES: BEGIN OF ty_zotc_billbk,
           vbeln TYPE vbeln_vf,
           posnr TYPE posnr_vf,
           fkimg TYPE fkimg,
         END OF   ty_zotc_billbk,

         ty_t_zotc_billbk TYPE STANDARD TABLE OF ty_zotc_billbk.

* Local internal table, workarea declaration
  DATA: li_komv           TYPE komv_tab,           " Condition tab
        li_billback       TYPE ty_t_zotc_billback, " Billback tab
        li_zotc_billbk    TYPE ty_t_zotc_billbk,
        li_vbrp_so        TYPE ty_t_vbrk_vbrp,
        lv_flag_org       TYPE flag,
        lv_auart          TYPE auart,
        lwa_zotc_billback TYPE zotc_billback,      " Billback workarea
        lwa_billback      TYPE zotc_billback,      " Billback workarea
        lwa_billback1     TYPE ty_billback,        " Billback workarea
        lwa_vbrk_vbrp     TYPE ty_vbrk_vbrp,       " org billing doc
        lwa_vbpa          TYPE vbpavb,             " SD: Partners
        lwa_edpar         TYPE ty_edpar,           " Ext partner no
        lwa_komv          TYPE komv,               " Condition workarea
        lwa_kna1          TYPE ty_kna1,            " Customer master
        lwa_zotc_billback_org TYPE ty_billback_org,
        lwa_cvbrp         TYPE vbrpvb,
        lwa_zotc_billbk   TYPE ty_zotc_billbk.

* Local field symbol declaration
  FIELD-SYMBOLS: <lfs_vbrp> TYPE vbrpvb.  " Billing item

* BOC ADAS1 08/07/2012

* Get the sales document Order type
  CLEAR: lwa_cvbrp.
  READ TABLE fp_cvbrp INTO lwa_cvbrp INDEX 1.
  IF sy-subrc = 0.
    CLEAR: lv_auart.
    SELECT SINGLE auart
           FROM vbak
           INTO lv_auart
           WHERE vbeln = lwa_cvbrp-aubel.
  ENDIF. " IF sy-subrc = 0. READ TABLE fp_cvbrp
* BOC ADAS1 08/07/2012


* BOC ADAS1 D#2213 12/26/2012
  IF NOT fp_i_vbrk_vbrp_so[] IS INITIAL.
    li_vbrp_so[] = fp_i_vbrk_vbrp_so[].
    SORT li_vbrp_so BY vbeln_b posnr_b.
    DELETE ADJACENT DUPLICATES FROM li_vbrp_so COMPARING vbeln_b posnr_b.

    SELECT vbeln
           posnr
           fkimg
           FROM zotc_billback
           INTO TABLE li_zotc_billbk
           FOR ALL ENTRIES IN li_vbrp_so
           WHERE vbeln = li_vbrp_so-vbeln_b
             AND posnr = li_vbrp_so-posnr_b.
    IF sy-subrc = 0.
      SORT li_zotc_billbk BY vbeln posnr.
    ENDIF.
  ENDIF.
* EOC ADAS1 D#2213 12/26/2012


* Keep unique entries for Consiotion record
  li_komv[] = fp_i_komv[].
  SORT li_komv BY kposn kschl.

* Keep unique entries of product family in billback table
  li_billback = fp_i_billback.
  SORT li_billback BY prodh ASCENDING fkdat DESCENDING.

* Populate Billback table entries which will be updated in
* Billback table
  LOOP AT fp_cvbrp ASSIGNING <lfs_vbrp>.

*   BOC ADAS1 08/07/2012

*   For Credit/Debit note, check whether Original invoice is
*   there or not
    IF fp_vbrk-vbtyp = c_credit OR
       fp_vbrk-vbtyp = c_debit.

*     Check from the document flow, if any original invoice exists for
*     this credit/debit note, If found, check the flag
      CLEAR: lwa_vbrk_vbrp,
             lv_flag_org.
      READ TABLE fp_i_vbrk_vbrp_bill INTO lwa_vbrk_vbrp
           WITH KEY vbeln_b = <lfs_vbrp>-aubel
                    posnr_b = <lfs_vbrp>-aupos
                    BINARY SEARCH.
      IF sy-subrc = 0.
        lv_flag_org = c_true.
        lwa_zotc_billback-vbeln = lwa_vbrk_vbrp-vbeln_s. " Invoice no
        lwa_zotc_billback-posnr = lwa_vbrk_vbrp-posnr_s. " Invoice no item
      ELSE.

*     Check from the billback table, if any original invoice exists for
*     this credit/debit note, If found, check the flag
        CLEAR: lwa_vbrk_vbrp.
        READ TABLE fp_i_vbrk_vbrp_so INTO lwa_vbrk_vbrp
             WITH KEY vbeln_s = <lfs_vbrp>-aubel
                      posnr_s = <lfs_vbrp>-aupos
                      BINARY SEARCH.
        IF sy-subrc = 0.
          lv_flag_org = c_true.
          lwa_zotc_billback-vbeln = lwa_vbrk_vbrp-vbeln_b. " Invoice no
          lwa_zotc_billback-posnr = lwa_vbrk_vbrp-posnr_b. " Invoice no item
        ENDIF.
      ENDIF.

*     BOC ADD ADAS1 D#2213
*     For Credit note, Settled Qnty should be the current Invoice qnty
      lwa_zotc_billback-zzset_qty = <lfs_vbrp>-fkimg.
*     EOC ADD ADAS1 D#2213
    ENDIF. " IF fp_vbrk-vbtyp = c_credit OR
    "    fp_vbrk-vbtyp = c_debit.

*   If original Invoice exists, update the billback table
*   with balanced qty, settled qty, and settlement flag

*   Instead of checking the flag, check whether original invoice
*   exists to update the original invoice as
*   an entry can exist in the staging table but without original inv
*   In that case, flag will be populated but original inv will remain blank
*
*    BOC DEL ADAS1 D#2213
*    IF lv_flag_org = c_true.
*    EOC DEL ADAS1 D#2213

*    BOC ADD ADAS1 D#2213
    IF NOT lwa_zotc_billback-vbeln IS INITIAL.
*    EOC ADD ADAS1 D#2213

      lwa_zotc_billback-matnr = <lfs_vbrp>-matnr. " Material Number
      lwa_zotc_billback-vkorg = fp_vbrk-vkorg.    " Sales Organization
      lwa_zotc_billback-vtweg = fp_vbrk-vtweg.    " Distribution Channel
      lwa_zotc_billback-kunag = fp_vbrk-kunag.    " Sold-to-Party
      lwa_zotc_billback-bstkd = fp_vbrk-bstnk_vf. " PO Number

*     BOC DEL ADAS1 D#2213
*     For Credit note, Settled Qnty should be the current Invoice qnty
*      lwa_zotc_billback-zzset_qty = <lfs_vbrp>-fkimg.
*     EOC DEL ADAS1 D#2213

*     Get the original invoice qnty
      CLEAR: lwa_zotc_billback_org.
      READ TABLE fp_i_billback_org INTO lwa_zotc_billback_org
     WITH KEY vbeln = lwa_vbrk_vbrp-vbeln_b
              posnr = lwa_vbrk_vbrp-posnr_b
              BINARY SEARCH.
      IF sy-subrc <> 0.
        CLEAR: lwa_zotc_billback_org.
        READ TABLE fp_i_billback_org INTO lwa_zotc_billback_org
       WITH KEY vbeln = lwa_vbrk_vbrp-vbeln_s
                posnr = lwa_vbrk_vbrp-posnr_s
                BINARY SEARCH.
        IF sy-subrc <> 0.
          READ TABLE li_zotc_billbk INTO lwa_zotc_billbk
               WITH KEY vbeln = lwa_vbrk_vbrp-vbeln_b
                        posnr = lwa_vbrk_vbrp-posnr_b
                        BINARY SEARCH.
          IF sy-subrc = 0.
            lwa_zotc_billback_org-fkimg = lwa_zotc_billbk-fkimg.
          ENDIF.
        ENDIF.
      ENDIF.
*       Balance qnty = original invoice qnty - settled qnty
      lwa_zotc_billback-zzbal_qty =
      lwa_zotc_billback_org-fkimg -  lwa_zotc_billback-zzset_qty.


    ELSE. " IF lv_flag_org <> c_true.
*   EOC ADAS1 08/07/2012

      lwa_zotc_billback-vbeln = fp_vbrk-vbeln.    " Invoice no
      lwa_zotc_billback-vkorg = fp_vbrk-vkorg.    " Sales Organization
      lwa_zotc_billback-vtweg = fp_vbrk-vtweg.    " Distribution Channel
      lwa_zotc_billback-fkart = fp_vbrk-fkart.    " Invoice Type
      lwa_zotc_billback-fkdat = fp_vbrk-fkdat.    " Invoice Date
      lwa_zotc_billback-kunag = fp_vbrk-kunag.    " Sold-to-Party
      lwa_zotc_billback-bstkd = fp_vbrk-bstnk_vf. " PO Number

      lwa_zotc_billback-auart = lv_auart.         " Order Type

      lwa_zotc_billback-posnr = <lfs_vbrp>-posnr. " Position Number
      lwa_zotc_billback-matnr = <lfs_vbrp>-matnr. " Material Number
      lwa_zotc_billback-prodh = <lfs_vbrp>-prodh. " Product Family
      lwa_zotc_billback-fkimg = <lfs_vbrp>-fkimg. " Invoiced Quantity

*   Populate Ship-to-party

*   If item ship-to-party is available, populate item ship-to-party
*   otherwise populate header ship-to-party
      CLEAR: lwa_vbpa.
      READ TABLE fp_i_vbpa INTO lwa_vbpa
           WITH KEY vbeln = <lfs_vbrp>-vbeln
                    posnr = <lfs_vbrp>-posnr
                    BINARY SEARCH.

      IF sy-subrc = 0.
        lwa_zotc_billback-kunnr = lwa_vbpa-kunnr.
      ELSE.
        lwa_zotc_billback-kunnr = fp_wa_kuwev-kunnr.
      ENDIF.

*  Populate Distributor Customer Code
      CLEAR: lwa_edpar.
      READ TABLE fp_i_edpar INTO lwa_edpar
           WITH KEY kunnr = lwa_zotc_billback-kunnr
           BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_zotc_billback-expnr = lwa_edpar-expnr.
      ENDIF.

*   Populate PO Date
      lwa_zotc_billback-bstdk = fp_wa_vbkd-bstdk.

*   Populate GLN Code
      CLEAR: lwa_kna1.
      READ TABLE fp_i_kna1 INTO lwa_kna1
           WITH KEY kunnr = fp_vbrk-kunag
           BINARY SEARCH.
      IF sy-subrc = 0.
        CONCATENATE lwa_kna1-bbbnr
                    lwa_kna1-bbsnr
                    lwa_kna1-bubkz
                    INTO lwa_zotc_billback-zzgln_code.
      ENDIF.

*   Populate GPO Code
      lwa_zotc_billback-kdgrp = <lfs_vbrp>-kdgrp_auft.

*   Populate Buying Group
      lwa_zotc_billback-kvgr1 =  <lfs_vbrp>-kvgr1.

*   Populate IDN Number
      lwa_zotc_billback-kvgr2 =  <lfs_vbrp>-kvgr2.

*   Populate Sales Price
      CLEAR: lwa_komv.
      READ TABLE li_komv INTO lwa_komv
           WITH KEY kposn = <lfs_vbrp>-posnr
                    kschl = lc_zr00
                    BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_zotc_billback-netwr = lwa_komv-kwert.
      ENDIF.

*   Populate Contract Price
      CLEAR: lwa_komv.
      READ TABLE li_komv INTO lwa_komv
           WITH KEY kposn = <lfs_vbrp>-posnr
                    kschl = lc_zc00
                    BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_zotc_billback-zzcont_price = lwa_komv-kwert.
      ENDIF.

*   Populate OLD/NEW Indicator

*   Check ZOTC_BILBACK table first with Ship-to-party and material no
*   If found set, Old/New indicator as per table value
*     D#3129: Coding Bug as structure missmatch of fp_i_billback and lwa_billback
      CLEAR: "lwa_billback,  " ADAS1 DEL D#3129
              lwa_billback1. " ADAS1 ADD D#3129
      READ TABLE fp_i_billback INTO lwa_billback1
     " ADAS1 Change lwa_billback1 to lwa_billback1 D#3129
           WITH KEY kunnr = lwa_zotc_billback-kunnr
                    matnr = lwa_zotc_billback-matnr
                    BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_zotc_billback-zzold_new_ind = lwa_billback1-zzold_new_ind.
        " ADAS1 Change lwa_billback1 to lwa_billback1 D#3129

*   If ZOTC_BILLBACK table does not have the entry,
*   Check the latest entry of the Product family and set the indicator
*   as per table value
      ELSE.
        CLEAR: lwa_billback.
        READ TABLE li_billback INTO lwa_billback
             WITH KEY prodh(11) = lwa_zotc_billback-prodh(11)
             BINARY SEARCH.
        IF sy-subrc = 0.
          lwa_zotc_billback-zzold_new_ind = lwa_billback-zzold_new_ind.
        ELSE.
          lwa_zotc_billback-zzold_new_ind = lc_new.
        ENDIF.

      ENDIF.

*     BOC ADAS1 08/07/2012
      lwa_zotc_billback-zzbal_qty =
      <lfs_vbrp>-fkimg -  lwa_zotc_billback-zzset_qty.
*     EOC ADAS1 08/07/2012
    ENDIF. " IF lv_flag_org = c_true.

*   If balance qn ty is 0, invoice is settled, else invoice is open
*   BOC ADAS1 08/07/2012
    IF lwa_zotc_billback-zzbal_qty = 0.
      lwa_zotc_billback-zzset_flag = lc_settled.
    ELSE.
      lwa_zotc_billback-zzset_flag = lc_open.
    ENDIF.
*   EOC ADAS1 08/07/2012

*   Populate Billback table
    APPEND lwa_zotc_billback TO fp_i_zotc_billback.
    CLEAR: lwa_zotc_billback.

  ENDLOOP.
ENDFORM.                    " F_POPULATE_FINAL
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_DB
*&---------------------------------------------------------------------*
*       Update Database Table
*----------------------------------------------------------------------*
*      -->FP_I_ZOTC_BILLBACK  Billback Table
*----------------------------------------------------------------------*
FORM f_update_db  USING    fp_i_zotc_billback TYPE ty_t_zotc_billback.

* Local Constant declaration
  CONSTANTS: lc_exclusive  TYPE enqmode VALUE 'E'.  " Error

* Local workarea declaration
  DATA: lwa_zotc_billback TYPE zotc_billback.

*&&-- Comment BOC of Defect#3745 Incident#INC0092648 on 09/05/2013
*  LOOP AT fp_i_zotc_billback INTO lwa_zotc_billback.
*&&-- SUB EOC of Defect#3745 Incident#INC0092648 on 09/05/2013

*&&-- Comment EOC of Defect#3745 Incident#INC0092648 on 09/05/2013
*&&-- For every Billing document number this is executed,
*     so the VBELN will be same with multiple items at one time
  READ TABLE fp_i_zotc_billback INTO lwa_zotc_billback INDEX 1.
  IF sy-subrc IS INITIAL.
*&&-- ADD EOC of Defect#3745 Incident#INC0092648 on 09/05/2013

*&&-- Lock the custom table at Billing Doc level
    CALL FUNCTION 'ENQUEUE_EZOTC_BILLBACK'
      EXPORTING
        mode_zotc_billback = lc_exclusive
        mandt              = sy-mandt
        vbeln              = lwa_zotc_billback-vbeln
*       posnr              = lwa_zotc_billback-posnr
                                           "Comment BMAJI Defect#3745
      EXCEPTIONS
        foreign_lock       = 1
        system_failure     = 2
        OTHERS             = 3.

    IF sy-subrc = 0.
*     Update Billback custom table
      CALL FUNCTION 'ZOTC_0043_BILLBACK_MOD_TAB' IN UPDATE TASK
        EXPORTING
*&&-- BOC of Defect#3745 Incident#INC0092648 on 09/05/2013
*        im_zotc_billback = lwa_zotc_billback.

*&&-- Pass the internal table for the Billing doc with all items
          im_zotc_billback = fp_i_zotc_billback.
*&&-- EOC of Defect#3745 Incident#INC0092648 on 09/05/2013

*     Unlock the particular billing document
      CALL FUNCTION 'DEQUEUE_EZOTC_BILLBACK'
        EXPORTING
          mode_zotc_billback = lc_exclusive
          mandt              = sy-mandt
          vbeln              = lwa_zotc_billback-vbeln.
*          posnr              = lwa_zotc_billback-posnr.
      "Comment BMAJI Defect#3745

    ENDIF.
  ENDIF."READ TABLE fp_i_zotc_billback INTO lwa_zotc_billback INDEX 1.
*  ENDLOOP. " LOOP AT fp_i_zotc_billback INTO lwa_zotc_billback.
  "Comment BMAJI Defect#3745

ENDFORM.                    " F_UPDATE_DB
*&---------------------------------------------------------------------*
*&      Form  F_GET_ORIGINAL_DOC
*&---------------------------------------------------------------------*
*       Gettin goriginal Invoice Document Number
*----------------------------------------------------------------------*
*      <--FP_IM_VBRK   Invoice Header
*      <--FP_IM_CVBRP  Invoice Items
*      -->fp_i_vbrk_vbrp_so    Invoice Items for sales ref
*      -->fp_i_vbrk_vbrp_bill  Invoice Items for billing ref
*----------------------------------------------------------------------*
FORM f_get_original_doc  USING    fp_im_vbrk     TYPE vbrk
                                  fp_im_cvbrp    TYPE vbrpvb_t
                         CHANGING fp_i_vbrk_vbrp_so TYPE ty_t_vbrk_vbrp
                                  fp_i_vbrk_vbrp_bill
                                                    TYPE ty_t_vbrk_vbrp.

if fp_im_cvbrp is not initial."Added by SBASU Def#1069
* Get original Invoice number for Credit/Debit Memo
  SELECT vbelv  " SO number
         posnv  " SO Item number
         vbeln  " Billing doc
         posnn  " Billing doc item number
         FROM vbfa
         INTO TABLE fp_i_vbrk_vbrp_bill
         FOR ALL ENTRIES IN fp_im_cvbrp
         WHERE vbeln = fp_im_cvbrp-aubel
           AND posnn = fp_im_cvbrp-aupos
           AND ( vbtyp_n = c_credit OR
                 vbtyp_n = c_debit OR
                 vbtyp_n = c_return )
           AND vbtyp_v = c_invoice.

* If Original Invoice not available from Document flow, check the
* Billback staging table based on the corresponding Sales order
* and sales order item no
  IF sy-subrc <> 0.
    SELECT vbeln_s  " SO number
           posnr_s  " SO Item number
           vbeln_b  " Billing doc
           posnr_b  " Billing doc item number
           FROM zotc_billbk_stg
           INTO TABLE fp_i_vbrk_vbrp_so
           FOR ALL ENTRIES IN fp_im_cvbrp
           WHERE vbeln_s = fp_im_cvbrp-aubel
             AND posnr_s = fp_im_cvbrp-aupos.

    IF sy-subrc = 0.
*     BOC DEL ADAS1 D#2213
*     SORT fp_i_vbrk_vbrp_so BY vbeln_b posnr_b.
*     EOC DEL ADAS1 D#2213
*     BOC ADD ADAS1 D#2213
      SORT fp_i_vbrk_vbrp_so BY vbeln_s posnr_s.
*     EOC ADD ADAS1 D#2213

    ENDIF.
  ELSE.
*     BOC DEL ADAS1 D#2213
*     SORT fp_i_vbrk_vbrp_bill BY vbeln_s posnr_s.
*     BOC DEL ADAS1 D#2213
*     BOC ADD ADAS1 D#2213
    SORT fp_i_vbrk_vbrp_bill BY vbeln_b posnr_b.
*     BOC ADD ADAS1 D#2213
  ENDIF. "  IF sy-subrc <> 0.
endif. "IF fp_im_cvbrp is not initial. "Added by SBASU Def#1069
ENDFORM.                    " F_GET_ORIGINAL_DOC
*&---------------------------------------------------------------------*
*&      Form  F_GET_BILLBACK_CRDR
*&---------------------------------------------------------------------*
*       Get Orriginal Invoice Qnty for Credit/Debit memeo
*----------------------------------------------------------------------*
*      -->FP_I_VBRK_VBRP_SO   Original Inv SO reference
*      -->P_I_VBRK_VBRP_BILL  Original Inv Billing reference
*      <--P_I_BILLBACK_ORG    Original Billback details
*----------------------------------------------------------------------*
FORM f_get_billback_crdr  USING    fp_i_vbrk_vbrp_so
                                         TYPE ty_t_vbrk_vbrp
                                   fp_i_vbrk_vbrp_bill
                                         TYPE ty_t_vbrk_vbrp
                          CHANGING fp_i_billback_org
                                        TYPE ty_t_billback_org.

* Get Original Invoice Qunatity
  IF NOT fp_i_vbrk_vbrp_bill IS INITIAL.
    SELECT vbeln " Billing no
           posnr " Billing item no
           fkimg " Invoiced Qnty
           FROM vbrp
           INTO TABLE fp_i_billback_org
           FOR ALL ENTRIES IN fp_i_vbrk_vbrp_bill
           WHERE vbeln = fp_i_vbrk_vbrp_bill-vbeln_s
             AND posnr = fp_i_vbrk_vbrp_bill-posnr_s.
    IF sy-subrc = 0.
      SORT fp_i_billback_org BY vbeln posnr.
    ENDIF.
  ENDIF. " IF NOT fp_i_vbrk_vbrp_bill IS INITIAL.

* Get Original Invoice Qunatity
  IF NOT fp_i_vbrk_vbrp_so IS INITIAL.
    SELECT vbeln " Billing no
           posnr " Billing item no
           fkimg " Invoiced Qnty
           FROM vbrp
           INTO TABLE fp_i_billback_org
           FOR ALL ENTRIES IN fp_i_vbrk_vbrp_so
           WHERE vbeln = fp_i_vbrk_vbrp_so-vbeln_b
             AND posnr = fp_i_vbrk_vbrp_so-posnr_b.

    IF sy-subrc = 0.
      SORT fp_i_billback_org BY vbeln posnr.
    ENDIF.
  ENDIF. " IF NOT fp_i_vbrk_vbrp_so IS INITIAL.

ENDFORM.                    " F_GET_BILLBACK_CRDR
