*&---------------------------------------------------------------------*
*&  Include           ZOTCB_EDD_0214_PAYMENT_F01
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCB_EDD_0214_PAYMENT                                 *
* TITLE      :  Mexico Payment Supplement for Trailix                  *
* DEVELOPER  :  Srinivasa Gurijala                                     *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D3_OTC_IDD_0214 SCTASK0515243                            *
*----------------------------------------------------------------------*
* DESCRIPTION: This Program is to Create a Payment Supplement File for *
*              Mexico Trailix.                                         *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 31-Aug-2017 U033814  E1DK930729 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*
* 09-Nov-2017 U033814  E1DK930729 Defect 3997 Logic change for RT20    *
*                                 Price for DZ Documents               *
*&---------------------------------------------------------------------*
* 15-Nov-2017 U033814  E1DK932538 Defect 4206 Logic change for RT20    *
*                                 Price for AB Documents and clear the *
*                                 RT20 Document after its postedas its *
*                                 getting repeated for next document   *
*&---------------------------------------------------------------------*
* 7-Dec-2017 U033814  E1DK932538 Defect 4206 7th Dec 2017 Amount Paid
*                                 Logic Change for Reversal Dcouments
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* 19-Dec-2017 U033814  E1DK932538 Defect 4206 12/19 Changes to Record
*                                 Type 20 Price and Reversal Document
*                                 Flag check
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* 29/08/2019  U106341                 HANAtization changes
*----------------------------------------------------------------------*

*&      Form  FETCH_PAYMENT_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_payment_details  CHANGING et_bkpf TYPE ty_t_bkpf
                                     et_bseg TYPE ty_t_bseg
                                     et_bsad TYPE ty_t_bsad
                                     et_bsid TYPE ty_t_bsid
                                     ev_msg  TYPE bapi_msg     " Message Text
                                     ev_subrc TYPE bapi_mtype. " Message type: S Success, E Error, W Warning, I Info, A Abort

  SELECT * FROM bkpf INTO TABLE et_bkpf
             WHERE bukrs EQ p_bukrs
               AND belnr IN s_belnr
               AND cpudt EQ p_cpudt
               AND bstat EQ space.
  IF sy-subrc EQ 0.
    IF s_blart IS NOT INITIAL.
      DELETE et_bkpf WHERE blart NOT IN s_blart.
    ENDIF. " IF s_blart IS NOT INITIAL
  ENDIF. " IF sy-subrc EQ 0
  READ TABLE et_bkpf INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
    SELECT * FROM bseg INTO TABLE et_bseg
            FOR ALL ENTRIES IN et_bkpf
              WHERE bukrs EQ et_bkpf-bukrs
                AND belnr EQ et_bkpf-belnr
                AND gjahr EQ et_bkpf-gjahr.
    READ TABLE et_bseg INDEX 1 TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      gt_bsegt[] = et_bseg[].
      IF s_kunnr IS NOT INITIAL.
        DELETE et_bseg WHERE kunnr NOT IN s_kunnr.
      ENDIF. " IF s_kunnr IS NOT INITIAL
    ENDIF. " IF sy-subrc EQ 0
    IF  et_bseg IS NOT INITIAL.
      SELECT * FROM bsad INTO TABLE et_bsad
              FOR ALL ENTRIES IN et_bseg
                WHERE bukrs EQ et_bseg-bukrs
                  AND kunnr EQ et_bseg-kunnr
                  AND augbl EQ et_bseg-belnr
*                  AND gjahr EQ et_bseg-gjahr.
*&-- Begin of Changes for HANAtization on OTC_IDD_0214 by U106341 on 29-Aug-2019 in E1SK901463
                  ORDER BY PRIMARY KEY.
*&-- End of Changes for HANAtization on OTC_IDD_0214 by U106341 on 29-Aug-2019 in E1SK901463
      READ TABLE et_bsad INDEX 1 TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
        SELECT * FROM bsid INTO TABLE et_bsid
                FOR ALL ENTRIES IN et_bsad
                   WHERE bukrs EQ et_bsad-bukrs
                     AND kunnr EQ et_bsad-kunnr
                     AND umsks EQ et_bsad-umsks
                     AND umskz EQ et_bsad-umskz
                      AND gjahr EQ et_bsad-gjahr.

      ELSE. " ELSE -> IF sy-subrc EQ 0
        ev_subrc = 4.
      ENDIF. " IF sy-subrc EQ 0
    ELSE. " ELSE -> IF et_bseg IS NOT INITIAL
      ev_subrc = 4.
    ENDIF. " IF et_bseg IS NOT INITIAL
  ELSE. " ELSE -> IF sy-subrc EQ 0
    ev_subrc = 4.
    ev_msg = text-052.
  ENDIF. " IF sy-subrc EQ 0

ENDFORM. " FETCH_PAYMENT_DETAILS

*&---------------------------------------------------------------------*
*&      Form  f_populate_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_populate_fieldcat .
* Populating Field-Catalog for ALV Display
  PERFORM f_populate USING:
    'BELNR'       'Document Number'(c01),
    'XMLID'      'XML Message ID'(c02),
    'STATUS'      'Status'(c03),
    'MESSAGE'     'Message'(c04).

ENDFORM. " F_POPULATE_FIELDCAT



*&---------------------------------------------------------------------*
*&      Form  F_POPULATE
*&---------------------------------------------------------------------*
*      Declaration for Field catalog and appending to the work area
*----------------------------------------------------------------------*
*      --> fp_fname using Field name of the field catalog
*      --> fp_text  using the Text Field of the field catalog
*----------------------------------------------------------------------*
FORM f_populate  USING     fp_fname  TYPE lvc_fname  " ALV control: Field name of internal table field
                           fp_text   TYPE scrtext_l. " Long Field Label

* Declaration for Field catalog and appending the work area
*                        to internal table of field catalog
  DATA: lv_fcat TYPE slis_fieldcat_alv.

  CLEAR lv_fcat.
  lv_fcat-fieldname = fp_fname.
  lv_fcat-seltext_l = fp_text.
  APPEND lv_fcat TO gt_fcat.

ENDFORM. " F_POPULATE

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_display_alv .
* local data declaration.
  DATA : lwa_layo TYPE slis_layout_alv.

* Constants declaration
  CONSTANTS:lc_callback_subroutine TYPE slis_formname
                                   VALUE 'F_USER_COMMAND' ##needed.

  lwa_layo-colwidth_optimize = abap_true.
*  SORT gt_final BY mbatch mtart matnr.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = sy-repid
      i_callback_top_of_page = c_top_page
      is_layout              = lwa_layo
      i_save                 = c_save_a
      it_fieldcat            = gt_fcat
    TABLES
      t_outtab               = gt_final
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 1.
  IF sy-subrc <> 0.
    MESSAGE i219.
*   Error ocurred during display
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc <> 0

ENDFORM. " F_DISPLAY_ALV

*&---------------------------------------------------------------------*
*&      Form  f_top_of_page
*&---------------------------------------------------------------------*
*      Subroutine is used to call TOP OF PAGE event dynamically
*----------------------------------------------------------------------*
FORM f_top_of_page ##called.

  CONSTANTS:  lc_typ_h  TYPE char1 VALUE 'H'. " Typ_h of type CHAR1

* Local data declaration
  DATA: li_listheader TYPE slis_t_listheader, "List header internal tab
        lwa_listheader TYPE slis_listheader.  "list header

  lwa_listheader-typ  = lc_typ_h.
  lwa_listheader-info = 'Payment Supplement for Mexico'(002).
  APPEND lwa_listheader TO li_listheader.
  CLEAR lwa_listheader.

* Subroutine for top of page
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = li_listheader.

ENDFORM. "f_top_of_page
*&---------------------------------------------------------------------*
*&      Form  PREPARE_POST_PI_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_BKPF  text
*      -->P_GT_BSEG  text
*      -->P_GT_BSAD  text
*      -->P_GT_BSID  text
*      <--P_GV_MSG  text
*      <--P_GV_SUBRC  text
*----------------------------------------------------------------------*
FORM prepare_post_pi_file  USING fp_gt_bkpf TYPE ty_t_bkpf
                                 fp_gt_bseg TYPE ty_t_bseg
                                 fp_gt_bsad TYPE ty_t_bsad
                                 fp_gt_bsid TYPE ty_t_bsid
                        CHANGING ev_msg     TYPE bapi_msg    " Message Text
                                 ev_subrc   TYPE bapi_mtype. " Message type: S Success, E Error, W Warning, I Info, A Abort
* Begin of Defect 3997
  TYPES : BEGIN OF lty_bseg,
          bukrs TYPE bukrs,   " Company Code
          belnr	TYPE belnr_d,
          gjahr	TYPE gjahr,
          buzei	TYPE buzei,
          koart   TYPE koart, " Account Type
          shkzg   TYPE shkzg, " Debit/Credit Indicator
          xauto   TYPE xauto, " Indicator: Line Item Automatically Created
  END OF lty_bseg.
  FIELD-SYMBOLS : <lfs_bseg>    TYPE bseg, " Accounting Document Segment
                  <lfs_bsaddz>  TYPE bsad. " Accounting: Secondary Index for Customers (Cleared Items)
* End of Defect 3997
  DATA : lv_kukey TYPE kukey_eb, " Short key (surrogate)
         lv_esnum TYPE esnum_eb. " Memo record number (line item number in bank statement)

  TYPES : BEGIN OF lty_bsad,
          bukrs TYPE bukrs,   " Company Code
          augdt TYPE augdt,   " Clearing Date
          augbl TYPE augbl,   " Document Number of the Clearing Document
          kunnr TYPE kunnr,   " Customer Number
          zuonr TYPE dzuonr,  " Assignment Number
          gjahr TYPE gjahr,   " Fiscal Year
          belnr TYPE belnr_d, " Assignment of Item Numbers: Material Doc. - Purchasing Doc.
          buzei TYPE buzei,   " Number of Line Item Within Accounting Document
          END OF lty_bsad.

  DATA : ls_bsad  TYPE bsad,                                            " Accounting: Secondary Index for Customers (Cleared Items)
         ls_bsadt1 TYPE bsad,                                           " Accounting: Secondary Index for Customers (Cleared Items)
         ls_bsaddz TYPE bsad,                                           " Accounting: Secondary Index for Customers (Cleared Items)
         ls_bseg  TYPE bseg,                                            " Accounting Document Segment
         ls_febep TYPE febep,                                           " Electronic Bank Statement Line Items
         ls_kna1  TYPE kna1,                                            " General Data in Customer Master
         ls_adrck TYPE adrc,                                            " Addresses (Business Address Services)
         ls_bsadt TYPE bsad,                                            " Accounting: Secondary Index for Customers (Cleared Items)
         ls_bsid TYPE bsid,                                             " Accounting: Secondary Index for Customers
         ls_vbrk TYPE vbrk,                                             " Billing Document: Header Data
         ls_bsads TYPE lty_bsad,
         lv_date TYPE char15,                                           " Date of type CHAR15
         lv_netwr TYPE netwr,                                           " Net Value in Document Currency
         ls_zrtr_mx_einvoice_u TYPE zrtr_mx_einvoice,                   " Documents for Mexico E-Invoice Interface
         ls_zrtr_mx_einvoice_i TYPE zrtr_mx_einvoice,                   " Documents for Mexico E-Invoice Interface
         lt_zrtr_mx_einvoice_u TYPE STANDARD TABLE OF zrtr_mx_einvoice, " Documents for Mexico E-Invoice Interface
         lt_bsad TYPE STANDARD TABLE OF lty_bsad INITIAL SIZE 0,
         lt_bsadt TYPE STANDARD TABLE OF bsad INITIAL SIZE 0,           " Accounting: Secondary Index for Customers (Cleared Items)
         lt_zrtr_mx_einvoice_i TYPE STANDARD TABLE OF zrtr_mx_einvoice, " Documents for Mexico E-Invoice Interface
         lt_rt02a TYPE z01otcdt_payment_complemen_tab,
         ls_rt02a TYPE z01otcdt_payment_complement_31,                  " Proxy Structure (generated)
         lt_rt05  TYPE z01otcdt_payment_compleme_tab3,
         lt_rt20  TYPE z01otcdt_payment_compleme_tab1,
         ls_rt20  TYPE z01otcdt_payment_complement_34,                  " Proxy Structure (generated)
         lt_bseg  TYPE STANDARD TABLE OF bseg INITIAL SIZE 0,           " Accounting Document Segment
         lt_rt21  TYPE z01otcdt_payment_compleme_tab2,
         ls_rt21  TYPE z01otcdt_payment_complement_37,                  " Proxy Structure (generated)
         ls_final TYPE ty_final,
         ls_rt05  TYPE z01otcdt_payment_complement_38,                  " Proxy Structure (generated)
         lv_mwsbk TYPE mwsbp,                                           " Tax amount in document currency
         lv_kunnr TYPE kunnr,                                           " Customer Number
         lv_rebzt TYPE char1 ##needed,                                  " Rebzt of type CHAR1
         lv_rev   TYPE char1,                                           " Rebzt of type CHAR1
         ls_adrc  TYPE adrc,                                            " Addresses (Business Address Services)
         ls_bkpf  TYPE bkpf,                                            " Accounting Document Number
         ls_t001  TYPE t001,                                            " Company Codes
         ls_out  TYPE z01otcmt_payment_complement_3,                    " Proxy Structure (generated)
         ls_knbk TYPE knbk,                                             " Customer Master (Bank Details)
         ls_bnka TYPE bnka,                                             " Bank master record
         lt_knbk TYPE STANDARD TABLE OF knbk INITIAL SIZE 0,            " Customer Master (Bank Details)
         lt_bsid TYPE STANDARD TABLE OF bsid INITIAL SIZE 0,            " Customer Master (Bank Details)
         lt_bnka TYPE STANDARD TABLE OF bnka INITIAL SIZE 0.            " Bank master record

  DATA : lt_bse_clr TYPE STANDARD TABLE OF bse_clr INITIAL SIZE 0, " Additional Data for Document Segment: Clearing Information
         ls_bse_clr TYPE bse_clr.                                  " Additional Data for Document Segment: Clearing Information


  SELECT SINGLE * FROM t001 INTO ls_t001 WHERE bukrs EQ p_bukrs.

  IF sy-subrc EQ 0.
    SELECT SINGLE * FROM adrc INTO ls_adrc WHERE addrnumber EQ ls_t001-adrnr. "#EC WARNOK
  ENDIF. " IF sy-subrc EQ 0


  READ  TABLE fp_gt_bsad INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
    SELECT * FROM knbk INTO TABLE lt_knbk FOR ALL ENTRIES IN fp_gt_bsad
                   WHERE kunnr EQ fp_gt_bsad-kunnr.
    IF sy-subrc EQ 0.
      SELECT * FROM bnka INTO TABLE lt_bnka FOR ALL ENTRIES IN lt_knbk
                             WHERE banks EQ lt_knbk-banks
                               AND bankl EQ lt_knbk-bankl.
    ENDIF. " IF sy-subrc EQ 0
    LOOP AT fp_gt_bsad INTO ls_bsadt.
      MOVE-CORRESPONDING ls_bsadt TO ls_bsads.
      APPEND ls_bsads TO lt_bsad.
    ENDLOOP. " LOOP AT fp_gt_bsad INTO ls_bsadt
*    LOOP AT fp_gt_bsad INTO ls_bsadt.
    LOOP AT lt_bsad INTO ls_bsads.
      MOVE-CORRESPONDING ls_bsads TO ls_bsadt.
      AT NEW augbl.
        CLEAR lv_kunnr.
        lv_kunnr = ls_bsadt-kunnr.
      ENDAT.
      READ TABLE fp_gt_bsad INTO ls_bsad WITH KEY bukrs = ls_bsads-bukrs
                                                  kunnr = ls_bsads-kunnr
                                                  augdt = ls_bsads-augdt
                                                  augbl = ls_bsads-augbl
                                                  zuonr = ls_bsads-zuonr
                                                  gjahr = ls_bsads-gjahr
                                                  belnr = ls_bsads-belnr
                                                  buzei = ls_bsads-buzei.
      IF sy-subrc EQ 0.
        IF ls_bsad-rebzt EQ 'V'.
          lv_rebzt = abap_true.
        ENDIF. " IF ls_bsad-rebzt EQ 'V'
* RT21
        ls_rt21-registry_type = '21'.
        ls_rt21-payment_unique_identifier = ls_bsad-augbl.
        ls_rt21-id_document               = ls_bsad-vbeln.
        ls_rt21-invoice_number            = ls_bsad-vbeln.

* Populate this from Installment number of Ztable
*        ls_rt21-num_parciality = ls_zrtr_mx_einvoice_u-installment_no.
        READ TABLE fp_gt_bsad INTO ls_bsadt1 WITH KEY kunnr = ls_bsad-kunnr
                                                      augbl = ls_bsad-augbl
                                                      belnr = ls_bsad-augbl. " BINARY SEARCH.
        IF sy-subrc EQ 0.
          ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-series =  ls_bsadt1-blart.
          READ TABLE fp_gt_bseg INTO ls_bseg WITH KEY belnr = ls_bsadt1-augbl
                                                      bukrs = ls_bsadt1-bukrs
                                                      gjahr = ls_bsadt1-gjahr
                                                      xauto = abap_false. " BINARY SEARCH.
          IF sy-subrc EQ 0 AND ls_bsadt1-blart NE 'DZ' AND ls_bsadt1-blart NE 'AB'.
            ls_rt20-price = ls_bseg-wrbtr.
          ENDIF. " IF sy-subrc EQ 0 AND ls_bsadt1-blart NE 'DZ' AND ls_bsadt1-blart NE 'AB'
        ENDIF. " IF sy-subrc EQ 0
* Begin of Defect 3997
        IF ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-series EQ 'DZ'.
          IF ls_rt20-price IS INITIAL.
            LOOP AT fp_gt_bsad ASSIGNING  <lfs_bsaddz> WHERE kunnr = ls_bsad-kunnr
                                                      AND    augbl = ls_bsad-augbl
                                                       AND    xzahl = abap_true.
*              CLEAR : lt_bseg.
*              SELECT *  FROM bseg INTO TABLE lt_bseg
*                                                         WHERE bukrs EQ <lfs_bsaddz>-bukrs
*                                                           AND belnr EQ <lfs_bsaddz>-belnr
*                                                           AND gjahr EQ <lfs_bsaddz>-gjahr.
              IF ls_rt20-price IS INITIAL.
                LOOP AT  gt_bsegt ASSIGNING <lfs_bseg> WHERE belnr = <lfs_bsaddz>-belnr
                                                       AND bukrs = <lfs_bsaddz>-bukrs
                                                       AND gjahr = <lfs_bsaddz>-gjahr
                                                       AND koart = 'S'
                                                       AND shkzg = 'S'
                                                       AND xauto = abap_false. " BINARY SEARCH.
                  ls_rt20-price = <lfs_bseg>-wrbtr +  ls_rt20-price.
                ENDLOOP. " LOOP AT lt_bseg ASSIGNING <lfs_bseg> WHERE belnr = <lfs_bsaddz>-belnr
              ENDIF. " IF ls_rt20-price IS INITIAL
              IF ls_rt20-price IS INITIAL.
                LOOP AT  gt_bsegt ASSIGNING <lfs_bseg> WHERE belnr = <lfs_bsaddz>-belnr
                                                       AND bukrs = <lfs_bsaddz>-bukrs
                                                       AND gjahr = <lfs_bsaddz>-gjahr
                                                       AND koart = 'D'
                                                       AND shkzg = 'H'.

                  ls_rt20-price = <lfs_bseg>-wrbtr +  ls_rt20-price.
                ENDLOOP. " LOOP AT lt_bseg ASSIGNING <lfs_bseg> WHERE belnr = <lfs_bsaddz>-belnr
              ENDIF. " IF ls_rt20-price IS INITIAL
            ENDLOOP. " LOOP AT fp_gt_bsad ASSIGNING <lfs_bsaddz> WHERE kunnr = ls_bsad-kunnr
          ENDIF. " IF ls_rt20-price IS INITIAL
* Begin of Defect 4206 - 12/19
          IF ls_rt20-price IS INITIAL.

                LOOP AT  gt_bsegt  ASSIGNING <lfs_bseg> WHERE belnr = ls_bsad-augbl
                                                       AND bukrs = ls_bsad-bukrs
                                                       AND gjahr = ls_bsad-gjahr
                                                       AND koart = 'S'
                                                       AND shkzg = 'S'
                                                       AND xauto = abap_false
                                                       AND buzid = abap_false.
                  ls_rt20-price = <lfs_bseg>-wrbtr +  ls_rt20-price.
                ENDLOOP. " LOOP AT lt_bseg ASSIGNING <lfs_bseg> WHERE belnr = ls_bsad-augbl

          ENDIF. " IF ls_rt20-price IS INITIAL
* End of Defect 4260 - 12/19
        ENDIF. " IF ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-series EQ 'DZ'
* End of Defect 3997

        IF ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-series EQ 'AB'.
          CLEAR ls_bsadt1.
* Begin of Defect 4206
*          READ TABLE fp_gt_bsad INTO ls_bsadt1 WITH KEY kunnr = ls_bsad-kunnr
*                                                        augbl = ls_bsad-augbl
*                                                        blart = 'DZ'
*                                                        bschl = '15'
*                                                        shkzg = 'H'.
*          IF sy-subrc EQ 0.
*            ls_rt20-price = ls_bsadt1-wrbtr.
*          ELSE. " ELSE -> IF sy-subrc EQ 0
*            READ TABLE fp_gt_bsad INTO ls_bsadt1 WITH KEY kunnr = ls_bsad-kunnr
*                                                          augbl = ls_bsad-augbl
*                                                          blart = 'AB'
*                                                          bschl = '17'
*                                                          shkzg = 'H'.
*            IF sy-subrc EQ 0.
*              ls_rt20-price = ls_bsadt1-wrbtr.
*            ENDIF. " IF sy-subrc EQ 0
*          ENDIF. " IF sy-subrc EQ 0
          APPEND ls_bsad TO lt_bsadt.
* End of Defect 4206
        ENDIF. " IF ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-series EQ 'AB'

        CLEAR ls_bseg.
        SORT fp_gt_bsid BY bukrs kunnr vbeln.
        READ TABLE fp_gt_bsid INTO ls_bsid WITH KEY bukrs = ls_bsad-bukrs
                                                   kunnr = ls_bsad-kunnr
* Begin of Defect 4206 - 12/19
*                                                   vbeln = ls_bsad-vbeln.
                                                    vbeln = ls_bsad-vbeln
                                                    shkzg = 'S'.
* End of Defect 4206 - 12/19
        IF sy-subrc EQ 0.
          ls_rt21-amount_outstanding_balance = ls_bsid-wrbtr.
*        ls_rt21-payment_method_dr = 'PPE'.
        ELSE. " ELSE -> IF sy-subrc EQ 0
          ls_rt21-amount_outstanding_balance = '0.00'.
*        ls_rt21-payment_method_dr = 'PUE'.
        ENDIF. " IF sy-subrc EQ 0
        ls_rt21-payment_method_dr = 'PUE'.

        IF ls_bsad-xragl EQ abap_true.
* Begin of Defect 4206 - 12/19
          READ TABLE fp_gt_bkpf INTO ls_bkpf WITH KEY belnr = ls_bsad-augbl
                                                      bukrs = ls_bsad-bukrs.
          IF ls_bkpf-blart EQ 'DA'.
* End of Defect 4206 - 12/19
            lv_rev = abap_true.
          ELSE. " ELSE -> IF ls_bkpf-blart EQ 'DA'
            ls_bsad-xragl = abap_false.
* Begin of Defect 4206 - 12/19
          ENDIF. " IF ls_bkpf-blart EQ 'DA'
* End of Defect 4206 - 12/19
        ENDIF. " IF ls_bsad-xragl EQ abap_true


        IF ls_bsad-xragl EQ abap_false.
          IF  ls_bsad-augbl NE ls_bsad-belnr AND ls_bsad-buzid NE 'R'.
            CLEAR ls_vbrk.
            IF ls_bsad-vbeln IS NOT INITIAL.
              SELECT SINGLE * FROM vbrk INTO ls_vbrk WHERE vbeln EQ ls_bsad-vbeln.
              IF sy-subrc EQ 0.
                ls_rt21-currency_dr               = ls_vbrk-waerk.
                IF ls_rt21-currency_dr NE 'MXN'.
                  ls_rt21-type_ofchange_dr          = ls_vbrk-kurrf.
                ENDIF. " IF ls_rt21-currency_dr NE 'MXN'

                lv_netwr = lv_netwr + ls_vbrk-netwr.
                lv_mwsbk = lv_mwsbk + ls_vbrk-mwsbk.
* Populate EInvoice table for Update
                SELECT SINGLE * FROM zrtr_mx_einvoice INTO ls_zrtr_mx_einvoice_u "#EC WARNOK
                                         WHERE bukrs EQ ls_bsad-bukrs
*                                     AND gjahr EQ ls_bsad-gjahr
                                           AND belnr EQ ls_bsad-vbeln
*                                     AND blart EQ ls_bsad-blart
                                           AND inv_type EQ 'SD'.
                IF sy-subrc EQ 0.
                  IF p_reg IS INITIAL.
                    ls_zrtr_mx_einvoice_u-installment_no = ls_zrtr_mx_einvoice_u-installment_no + 1.
                  ENDIF. " IF p_reg IS INITIAL
                  ls_zrtr_mx_einvoice_i-zz_changed_by = sy-uname.
                  ls_zrtr_mx_einvoice_i-zz_changed_on = sy-datum.
                  ls_zrtr_mx_einvoice_i-zz_changed_at = sy-uzeit.
                  ls_rt21-num_parciality =  ls_zrtr_mx_einvoice_u-installment_no.
                ELSE. " ELSE -> IF sy-subrc EQ 0
                  ls_rt21-num_parciality =  ls_zrtr_mx_einvoice_u-installment_no.
                ENDIF. " IF sy-subrc EQ 0
                APPEND ls_zrtr_mx_einvoice_u TO lt_zrtr_mx_einvoice_u.
                CLEAR ls_zrtr_mx_einvoice_u.
              ENDIF. " IF sy-subrc EQ 0
            ENDIF. " IF ls_bsad-vbeln IS NOT INITIAL
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                input  = ls_rt21-num_parciality
              IMPORTING
                output = ls_rt21-num_parciality.
            CONDENSE ls_rt21-num_parciality NO-GAPS.
*        ls_rt21-price_prev_balance = ls_vbrk-netwr + ls_vbrk-mwsbk.
            IF ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-series NE 'AB'.
              ls_rt21-price_prev_balance = ls_bsad-wrbtr.
              ls_rt21-amount_paid = ls_rt21-price_prev_balance - ls_rt21-amount_outstanding_balance.
            ELSE. " ELSE -> IF ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-series NE 'AB'
              IF  ls_bsad-bschl NE '15' AND ls_bsad-shkzg EQ 'S'.
                ls_rt21-price_prev_balance = ls_bsad-wrbtr + ls_rt21-price_prev_balance.
                ls_rt21-amount_paid = ls_rt21-price_prev_balance - ls_rt21-amount_outstanding_balance.
                IF ls_bsad-vbeln IS NOT INITIAL.
                  APPEND ls_rt21 TO lt_rt21.
                ENDIF. " IF ls_bsad-vbeln IS NOT INITIAL
                CLEAR ls_rt21.
              ENDIF. " IF ls_bsad-bschl NE '15' AND ls_bsad-shkzg EQ 'S'
            ENDIF. " IF ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-series NE 'AB'
            IF ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-series NE 'AB'.
              IF ls_bsad-vbeln IS NOT INITIAL.
                APPEND ls_rt21 TO lt_rt21.
              ENDIF. " IF ls_bsad-vbeln IS NOT INITIAL
              CLEAR ls_rt21.
            ENDIF. " IF ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-series NE 'AB'
          ENDIF. " IF ls_bsad-augbl NE ls_bsad-belnr AND ls_bsad-buzid NE 'R'
        ENDIF. " IF ls_bsad-xragl EQ abap_false


*      IF ls_bsad-augbl NE ls_bsad-belnr.
*      ENDIF. " IF ls_bsad-augbl NE ls_bsad-belnr

* Begin of Change 3997
*        IF ls_bsad-shkzg EQ 'H' AND ls_bsad-bschl EQ '15'.
**      ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-series =  ls_bsad-blart.
*          SELECT SINGLE bankn FROM t012k INTO ls_rt20-account_beneficiary
*                                     WHERE bukrs EQ ls_bsad-bukrs
*                                       AND hbkid EQ ls_bsad-xblnr+0(5)
*                                       AND hktid EQ ls_bsad-xblnr+5(5).
*          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*            EXPORTING
*              input  = ls_rt20-account_beneficiary
*            IMPORTING
*              output = ls_rt20-account_beneficiary.
*
*        ENDIF. " IF ls_bsad-shkzg EQ 'H' AND ls_bsad-bschl EQ '15'

        ls_rt20-account_beneficiary = '2057757909'.
* End of Change 3997
* Prepare IDOC ITEM
        AT END OF augbl.
          IF ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-series EQ 'AB'.
* Begin of Defect 4206
            IF ls_rt20-price IS INITIAL.
              LOOP AT lt_bsadt INTO ls_bsadt1 WHERE  kunnr = ls_bsad-kunnr
                                                  AND  augbl NE ls_bsad-belnr
                                                  AND  blart EQ 'DZ'
                                                  AND  shkzg EQ 'H'
                                                  AND  buzid NE 'R'.
                ls_rt20-price = ls_bsadt1-wrbtr + ls_rt20-price.
              ENDLOOP. " LOOP AT lt_bsadt INTO ls_bsadt1 WHERE kunnr = ls_bsad-kunnr
            ENDIF. " IF ls_rt20-price IS INITIAL
            IF ls_rt20-price IS  INITIAL.
* Begin of Defect 4206
*              LOOP AT lt_bsadt INTO ls_bsadt1 WHERE  kunnr = ls_bsad-kunnr
*                                                AND  blart EQ 'AB'
*                                                AND  bschl EQ '17'
*                                                AND  shkzg EQ 'H'.
*                ls_rt20-price = ls_bsadt1-wrbtr + ls_rt20-price.

*              ENDLOOP. " LOOP AT lt_bsadt INTO ls_bsadt1 WHERE kunnr = ls_bsad-kunnr
                  LOOP AT  gt_bsegt ASSIGNING <lfs_bseg> WHERE belnr = ls_bsad-augbl
                                                         AND bukrs = ls_bsad-bukrs
                                                         AND gjahr = ls_bsad-gjahr
                                                         AND koart = 'D'
                                                         AND shkzg = 'S'
                                                         AND buzid = abap_false.
                    ls_rt20-price = <lfs_bseg>-wrbtr +  ls_rt20-price.
                  ENDLOOP. " LOOP AT lt_bseg ASSIGNING <lfs_bseg> WHERE belnr = ls_bsad-augbl
* End of Defect 4206
            ENDIF. " IF ls_rt20-price IS INITIAL
            CLEAR lt_bsadt.
          ENDIF. " IF ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-series EQ 'AB'
* End of Defect 4206
* RT00 Record
          ls_out-mt_payment_complement_3_3-start_of_cfdi_rt00-registry_type    =  '00'.
          ls_out-mt_payment_complement_3_3-start_of_cfdi_rt00-id    =  'cfdiPagos'.
          ls_out-mt_payment_complement_3_3-start_of_cfdi_rt00-template_label   =  'CPI'.
          ls_out-mt_payment_complement_3_3-start_of_cfdi_rt00-version_attached =  '3.3'.
* RT01 Record
          ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-registry_type =  '01'.
          CONCATENATE 'CPI' ls_bsad-augbl INTO ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-unique_identifier.
          ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-invoice_number =  ls_bsad-augbl.
          ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-currency = 'XXX'.
          ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-subtotal = 0.
          ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-total = 0.
*        condense ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-subtotal n
*      ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-total_tax_transferred = 0.
* Total in Text to be written
          ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-total_in_text = ''.
          CALL FUNCTION 'ZDEV_DATE_FORMAT'
            EXPORTING
              i_date       = ls_bsad-augdt
              i_format     = 'YYYY-MM-DD'
              i_langu      = 'D'
            IMPORTING
              e_date_final = lv_date.

          CONCATENATE
          lv_date
          'T12:00:00'
          INTO
          ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-date.
          ls_zrtr_mx_einvoice_i-bukrs = ls_bsad-bukrs.
          ls_zrtr_mx_einvoice_i-gjahr = ls_bsad-gjahr.
          ls_zrtr_mx_einvoice_i-belnr = ls_bsad-augbl.
* Begin of 4206
*          ls_zrtr_mx_einvoice_i-blart = ls_bsad-blart.
          ls_zrtr_mx_einvoice_i-blart = ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-series.
* End of Defect 4206
          ls_zrtr_mx_einvoice_i-inv_type = 'PY'.
          ls_zrtr_mx_einvoice_i-shkzg = ls_bsad-shkzg.
          ls_zrtr_mx_einvoice_i-zz_created_by = sy-uname.
          ls_zrtr_mx_einvoice_i-zz_created_on = sy-datum.
          ls_zrtr_mx_einvoice_i-zz_created_at = sy-uzeit.
          APPEND ls_zrtr_mx_einvoice_i TO lt_zrtr_mx_einvoice_i.
          CLEAR ls_zrtr_mx_einvoice_i.

          ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-expedition_place = ls_adrc-post_code1.
          ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-type_ofvoucher = 'P'.
          CLEAR : lv_rebzt,lv_netwr,lv_mwsbk.
          IF lv_rev EQ abap_true.
            CLEAR ls_bkpf.
            READ TABLE fp_gt_bkpf INTO ls_bkpf WITH KEY belnr = ls_bsad-augbl
                                                        bukrs = ls_bsad-bukrs.

            IF sy-subrc EQ 0.
              ls_out-mt_payment_complement_3_3-voucher_relationed_rt02-relationed_identifier = ls_bkpf-stblg.
* Populate RT02 Record
              ls_out-mt_payment_complement_3_3-voucher_relationed_rt02-regsitrytype = '02'.
              ls_out-mt_payment_complement_3_3-voucher_relationed_rt02-relation_type = '04'.

              ls_rt02a-relationed_identifier = ls_bkpf-stblg.
              IF lv_rev IS NOT INITIAL.
                ls_rt02a-uuid = ls_bkpf-stblg.
              ENDIF. " IF lv_rev IS NOT INITIAL
              ls_rt02a-registry_type = '02A'.
              APPEND ls_rt02a TO lt_rt02a.
              ls_out-mt_payment_complement_3_3-voucher_related_rt02a[] = lt_rt02a[].
              CLEAR lt_rt02a.
            ENDIF. " IF sy-subrc EQ 0
            CLEAR ls_bkpf.

          ENDIF. " IF lv_rev EQ abap_true

          READ TABLE fp_gt_bkpf INTO ls_bkpf WITH KEY belnr = ls_bsad-augbl
                                                      bukrs = ls_bsad-bukrs
                                                      gjahr = ls_bsad-gjahr. " BINARY SEARCH.
          IF sy-subrc EQ 0.

            CLEAR : lv_kukey,lv_esnum.
            lv_kukey = ls_bkpf-bktxt+0(8).
            lv_esnum = ls_bkpf-bktxt+8(5).
            SELECT SINGLE * FROM febep INTO ls_febep WHERE kukey EQ lv_kukey
                                                       AND esnum  EQ lv_esnum.
            IF sy-subrc EQ 0.
              ls_rt20-num_operation = ls_febep-chect.
            ENDIF. " IF sy-subrc EQ 0
** RT20
            ls_rt20-registry_type = '20'.
* Begin
            IF ls_bkpf-waers NE 'MXN'.
* End
              IF ls_bkpf-kursf IS NOT INITIAL.
                ls_rt20-type_of_change = ls_bkpf-kursf.
              ELSE. " ELSE -> IF ls_bkpf-kursf IS NOT INITIAL
                ls_rt20-type_of_change = '1.0000'.
              ENDIF. " IF ls_bkpf-kursf IS NOT INITIAL
            ENDIF. " IF ls_bkpf-waers NE 'MXN'
            ls_rt20-payment_unique_identifier = ls_bsad-augbl.
            ls_rt20-payment_date = ls_out-mt_payment_complement_3_3-gnrl_inf_voucher_rt01-date.
            ls_rt20-way_to_pay = '03'.
            ls_rt20-currency = ls_bkpf-waers.
            IF ls_rt20-currency NE 'MXN'.
              ls_rt20-rfc_emitter_ord_account = text-005.
            ENDIF. " IF ls_rt20-currency NE 'MXN'
            READ TABLE lt_knbk INTO ls_knbk WITH KEY kunnr = ls_bsad-kunnr. " BINARY SEARCH.
            IF sy-subrc EQ 0.
              IF ls_rt20-rfc_emitter_ord_account IS INITIAL.
                ls_rt20-payer_account = ls_knbk-bankn.
              ENDIF. " IF ls_rt20-rfc_emitter_ord_account IS INITIAL
              READ TABLE lt_bnka INTO ls_bnka WITH KEY banks = ls_knbk-banks
                                                       bankl = ls_knbk-bankl. " BINARY SEARCH.
              IF sy-subrc EQ 0.
                ls_rt20-name_bank_ord_ext = ls_bnka-banka.
              ENDIF. " IF sy-subrc EQ 0
            ENDIF. " IF sy-subrc EQ 0
            APPEND ls_rt20 TO lt_rt20.
            ls_out-mt_payment_complement_3_3-payment_rt20[] = lt_rt20[].
          ENDIF. " IF sy-subrc EQ 0

* RT03
          ls_out-mt_payment_complement_3_3-receiver_rt03-registry_type = '03'.

          ls_out-mt_payment_complement_3_3-receiver_rt03-unique_receiver_identifier = lv_kunnr.
          CLEAR : ls_kna1,ls_adrck.
          SELECT SINGLE * FROM kna1 INTO ls_kna1 WHERE kunnr EQ lv_kunnr.
          IF sy-subrc EQ 0.
            ls_out-mt_payment_complement_3_3-receiver_rt03-rfcreceiver = ls_kna1-stcd1.
            SELECT SINGLE * FROM adrc INTO ls_adrck WHERE addrnumber EQ ls_kna1-adrnr. "#EC WARNOK
            IF sy-subrc EQ 0.
              ls_out-mt_payment_complement_3_3-receiver_rt03-name = ls_adrck-name1.
              ls_out-mt_payment_complement_3_3-receiver_rt03-country = ls_adrck-country.
              ls_out-mt_payment_complement_3_3-receiver_rt03-street = ls_adrck-street.
              ls_out-mt_payment_complement_3_3-receiver_rt03-outdoor_number = ls_adrck-house_num1.
              ls_out-mt_payment_complement_3_3-receiver_rt03-indoor_number = ls_adrck-house_num2.
              ls_out-mt_payment_complement_3_3-receiver_rt03-colony = ls_adrck-str_suppl1.
              ls_out-mt_payment_complement_3_3-receiver_rt03-municipality = ls_adrck-city1.
              ls_out-mt_payment_complement_3_3-receiver_rt03-state = ls_adrck-region.
              ls_out-mt_payment_complement_3_3-receiver_rt03-postal_code = ls_adrck-post_code1.
              ls_out-mt_payment_complement_3_3-receiver_rt03-use_cfdi = 'P01'.
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF sy-subrc EQ 0
* RT05
          ls_rt05-registry_type = '05'.
          ls_rt05-prod_key_serv = '84111506'.
          ls_rt05-description = 'Pago'(003).
          ls_rt05-unitary_value = '0'.
          ls_rt05-price = '0'.
          ls_rt05-quantity = '1'.
          ls_rt05-unit = 'ACT'.
          ls_rt05-identifier_concept = 'CON1'.
          APPEND ls_rt05 TO lt_rt05.
          ls_out-mt_payment_complement_3_3-concepts_rt05[] = lt_rt05[].
          CLEAR lt_rt05.


          IF lv_rev IS NOT INITIAL.
            READ TABLE fp_gt_bkpf INTO ls_bkpf WITH KEY belnr = ls_bsad-augbl
                                                        bukrs = ls_bsad-bukrs. " BINARY SEARCH.
            IF sy-subrc EQ 0.

              CLEAR : ls_bse_clr , lt_bse_clr.
              SELECT  * FROM bse_clr INTO TABLE lt_bse_clr WHERE bukrs_clr = ls_bsad-bukrs
                                                             AND  belnr_clr = ls_bkpf-stblg
                                                             AND    gjahr_clr = ls_bsad-gjahr.
              IF sy-subrc EQ 0.
                CLEAR lt_bsid.
                SELECT * FROM bsid INTO TABLE lt_bsid FOR ALL ENTRIES IN lt_bse_clr WHERE kunnr EQ ls_bsad-kunnr
                                                            AND bukrs EQ lt_bse_clr-bukrs_clr
                                                            AND belnr EQ lt_bse_clr-belnr.
                IF sy-subrc EQ 0.
                  LOOP AT lt_bse_clr INTO ls_bse_clr.
                    ls_rt21-currency_dr = ls_bse_clr-waers.
                    ls_rt21-price_prev_balance = ls_bse_clr-wrbtr.
* Begin of Defect 4206 - Dec 7th 2017
*                    ls_rt21-amount_paid = ls_bse_clr-wrbtr.
                    ls_rt21-amount_paid = ls_bse_clr-wrbtr - ls_bse_clr-difhw.
* End of Defect 4206 - Dec7th 2017
                    ls_rt21-amount_outstanding_balance = ls_rt21-price_prev_balance - ls_rt21-amount_paid.
                    IF ls_rt21-currency_dr NE 'MXN'.
                      IF  ls_bkpf-kursf IS NOT INITIAL.
                        ls_rt21-type_ofchange_dr = ls_bkpf-kursf.
                      ELSE. " ELSE -> IF ls_bkpf-kursf IS NOT INITIAL
                        ls_rt21-type_ofchange_dr = '1.0000'.
                      ENDIF. " IF ls_bkpf-kursf IS NOT INITIAL
                    ENDIF. " IF ls_rt21-currency_dr NE 'MXN'

                    READ TABLE lt_bsid INTO ls_bsid WITH KEY bukrs = ls_bsad-bukrs
                                                                belnr = ls_bse_clr-belnr
                                                                kunnr = ls_bsad-kunnr.
                    IF sy-subrc EQ 0.
                      ls_rt21-registry_type = '21'.
                      ls_rt21-payment_unique_identifier = ls_bsad-augbl.
                      ls_rt21-num_parciality = 1.

                      ls_rt21-invoice_number = ls_bsid-vbeln.
                      ls_rt21-id_document    = ls_bsid-vbeln.
                      CLEAR ls_bsid.
                      APPEND ls_rt21 TO lt_rt21.
                    ENDIF. " IF sy-subrc EQ 0
                  ENDLOOP. " LOOP AT lt_bse_clr INTO ls_bse_clr
                  CLEAR ls_rt21.
                ENDIF. " IF sy-subrc EQ 0
              ENDIF. " IF sy-subrc EQ 0
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF lv_rev IS NOT INITIAL
          ls_out-mt_payment_complement_3_3-document_related_rt21[] = lt_rt21[].

* Send the Message to PI and Update EInvoice Custom table with Instalment number
          IF lt_rt21 IS NOT INITIAL.
            PERFORM f_send_data USING ls_out
                                      lt_zrtr_mx_einvoice_i
                                      lt_zrtr_mx_einvoice_u.
          ELSE. " ELSE -> IF lt_rt21 IS NOT INITIAL
            READ TABLE lt_zrtr_mx_einvoice_i INTO ls_zrtr_mx_einvoice_i INDEX 1.
            IF sy-subrc EQ 0.
              MOVE ls_zrtr_mx_einvoice_i-belnr TO ls_final-belnr.
              MOVE text-053 TO ls_final-message.
              MOVE 'W'      TO ls_final-status.
              APPEND ls_final TO gt_final.
              CLEAR ls_final.
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF lt_rt21 IS NOT INITIAL
          CLEAR : lt_zrtr_mx_einvoice_i,lt_zrtr_mx_einvoice_u ,ls_out , lt_rt21,lv_rev, ls_rt20.
* Begin of Defect 4206
          CLEAR : lt_rt20 ,lt_rt02a,ls_rt02a,ls_out-mt_payment_complement_3_3-voucher_relationed_rt02.
* End of Defect 4206
        ENDAT.
      ENDIF. " IF sy-subrc EQ 0
    ENDLOOP. " LOOP AT lt_bsad INTO ls_bsads
  ENDIF. " IF sy-subrc EQ 0
  ev_msg   = text-050.
  ev_subrc = 'S'.
ENDFORM. " PREPARE_POST_IDOC


*&---------------------------------------------------------------------*
*&      Form  F_SEND_DATA
*&---------------------------------------------------------------------*
*      Send Data To PI
*----------------------------------------------------------------------*
*      -->FP_X_PAYLOAD  Proxy Structure
*----------------------------------------------------------------------*
FORM f_send_data USING fp_x_payload TYPE z01otcmt_payment_complement_3 " Proxy Structure (generated)
                       fp_zrtr_mx_einvoice_i TYPE  ty_t_zrtr_mx_einvoice_i
                       fp_zrtr_mx_einvoice_u TYPE  ty_t_zrtr_mx_einvoice_i.
  DATA : lv_proxycl  TYPE REF TO z01otcco_si_payment_complement, "Proxy Class
         ls_final    TYPE ty_final.
*&--Local Variable
  DATA:
    lv_error TYPE REF TO cx_ai_system_fault. "Error Variable
  DATA :
  lref_wsprotocol         TYPE REF TO if_wsprotocol,            " ABAP Proxies: Available Protocols
  lref_wsprotocol_msg_id  TYPE REF TO if_wsprotocol_message_id, " XI and WS: Read Message ID
  ls_zrtr_mx_einvoice_i  TYPE zrtr_mx_einvoice,                 " Documents for Mexico E-Invoice Interface
  lv_xml_message_id       TYPE sxmsmguid,                       " XI: Message ID
   lx_cx_root              TYPE REF TO cx_root.                 " Abstract Superclass for All Global Exceptions
  CONSTANTS:
    lc_error TYPE char1 VALUE 'E'. "Error Code

*&--Calling the Proxy Calss Method to communicate the data to XI
  TRY.
      CREATE OBJECT lv_proxycl.
      TRY.
          CALL METHOD lv_proxycl->si_payment_complement_3_3_in
            EXPORTING
              output = fp_x_payload.
*&--Catching the Exception and displaying error message if method
*&--call fails
        CATCH cx_ai_system_fault INTO lv_error.
          MESSAGE lv_error TYPE lc_error.
      ENDTRY.

*&--Doing a Comit Work Or Rolback depending upon method call return
*&--code
      IF sy-subrc IS INITIAL.

        CALL METHOD lv_proxycl->get_protocol
          EXPORTING
            protocol_name = 'IF_WSPROTOCOL_MESSAGE_ID' " todo use constant
          RECEIVING
            protocol      = lref_wsprotocol.           "Protocol
*Try a narrowing cast - try and catch
        TRY.
            lref_wsprotocol_msg_id ?= lref_wsprotocol.
          CATCH cx_root INTO lx_cx_root. "#EC *
        ENDTRY.
        IF lx_cx_root IS NOT BOUND.
*       XML-message ID determination
          lv_xml_message_id = lref_wsprotocol_msg_id->get_message_id( ).
          ls_final-xmlid = lv_xml_message_id.
        ENDIF. " IF lx_cx_root IS NOT BOUND
        MODIFY  zrtr_mx_einvoice FROM TABLE fp_zrtr_mx_einvoice_i.
        UPDATE  zrtr_mx_einvoice FROM TABLE fp_zrtr_mx_einvoice_u.
        COMMIT WORK AND WAIT.
        IF sy-subrc EQ 0.
          MESSAGE s000 WITH 'E-mail triggered successfully.'(050).
        ELSE. " ELSE -> IF sy-subrc EQ 0
          MESSAGE s000 WITH 'E-mail triggering failed.'(051).
        ENDIF. " IF sy-subrc EQ 0
        READ TABLE fp_zrtr_mx_einvoice_i INTO ls_zrtr_mx_einvoice_i INDEX 1.
        MOVE ls_zrtr_mx_einvoice_i-belnr TO ls_final-belnr.
        MOVE text-050 TO ls_final-message.
        MOVE 'S'      TO ls_final-status.
      ELSE. " ELSE -> IF sy-subrc IS INITIAL
*&--Rolling Back if exception occurs.
        ROLLBACK WORK.
        MESSAGE s000 WITH 'E-mail triggering failed.'(051).
        MOVE text-051 TO ls_final-message.
        MOVE 'E'      TO ls_final-status.
      ENDIF. " IF sy-subrc IS INITIAL
*&--Catching the Exception and displaying error message if method
*&--call fails
    CATCH cx_ai_system_fault INTO lv_error.
      MESSAGE lv_error TYPE lc_error.
  ENDTRY.
  APPEND ls_final TO gt_final.
  CLEAR ls_final.
ENDFORM. " F_SEND_DATA
