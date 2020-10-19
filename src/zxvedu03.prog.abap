*&---------------------------------------------------------------------*
*&  Include           ZXVEDU03
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  OTC_IDD_0009_SAP_Inbound sales order EDI 850           *
* TITLE      :  SAP_Inbound sales order EDI 850                        *
* DEVELOPER  :  Sneha Ghosh                                            *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_0009                                             *
*----------------------------------------------------------------------*
* DESCRIPTION:                                                         *
* This include will search & populate contract details for inbound IDOC*
* of Basic type ORDERS05 if E1EDP02 segment is not populated.          *
* Retrofit done for CR#2865 from D1 to D2.                             *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER      TRANSPORT      DESCRIPTION                   *
* ===========  ========   =========  ==================================*
* 22/01/2014   SGHOSH     E1DK912631  CR#1110 - Initial Development    *
*                                     Contract details search &        *
*                                     populate contract details for    *
*                                     Inbound ORDERS05 IDOC if E1EDP02 *
*                                     segment is not populated.        *
* 16/05/2014  SGHOSH     E1DK912631   CR#1110 - Identify the Sold-to   *
*                                     and the Ship-to from segment     *
*                                     E1EDKA1(no need to populate) of  *
*                                     Idoc data and search for contract*
*                                     details. If multiple contract    *
*                                     reference found display error    *
*                                     message.                         *
* 21/09/2015  PDEBARU   E2DK915266    Defect # 856 : System should be  *
*                                     able to ignore rejected lines    *
*                                    from identified reference contracts*
* 05-SEP-2017 U033959   E1DK930350   Def#3398 - Delete all the records *
*                                    li_data table where segnum is less*
*                                    than segment-segnum so that corre-*
*                                    ct contract is fetched.           *
* 16-NOV-2018 U103061  E1DK939492    Defect# 7589(INC0412417): Item   *
*                                    does not exist error message for  *
*                                    French orders                     *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

*$-----TYPE DECLARATION--------------------------------
TYPES: BEGIN OF lty_vbeln,
         vbeln TYPE vbak-vbeln, "Sales Document
       END OF lty_vbeln,

*-->> Begin of change for Defect # 856 by PDEBARU
        BEGIN OF lty_item,
           vbeln TYPE vbeln,                        "Contract no
           posnr TYPE posnr,                        "Contract Item
           datab TYPE datab_vi,                     "Contract valid from
           datbi TYPE datbi_vi,                     "Contract valid to
         END OF lty_item,

         BEGIN OF lty_vbap,
           vbeln TYPE vbeln_va,                     "Contract no
           posnr TYPE posnr_va,                     "Contract Item
           abgru TYPE abgru_va,                     "Reason for Rejection
          END OF lty_vbap,

         lty_t_item TYPE STANDARD TABLE OF lty_item " local internal table
         .
*<<-- End of change for Defect # 856 by PDEBARU
*&---DATA DECLARATIONS-----------------------
DATA:
  li_data         TYPE edidd_tt,
* ---> Begin of Insert for D3_OTC_IDD_0009 Def#3398 by U033959 on 05-SEP-2017
  li_data_temp    TYPE edidd_tt, " temporary table
* <--- End of Insert for D3_OTC_IDD_0009 Def#3398 by U033959 on 05-SEP-2017
  lwa_data        TYPE edidd, " Data record (IDoc)
  li_vbeln        TYPE STANDARD TABLE OF lty_vbeln,
  lwa_vbeln       TYPE lty_vbeln,
*-->> Begin of change for Defect # 856 by PDEBARU
  li_item         TYPE lty_t_item,
  li_item1        TYPE lty_t_item,
  lwa_item        TYPE listvbap,                           " Referenced headers/items
  lwa_item1       TYPE lty_item,
  li_vbap  TYPE STANDARD TABLE OF lty_vbap INITIAL SIZE 0, " Local work area
*<<-- End of change for defect # 856 by PDEBARU

*&---LOCAL VARIABLE DECLARATIONS-------------
  lv_matnr        TYPE vbap-matnr, " Material Number
  lv_vbeln        TYPE vbeln,      " Sales and Distribution Document Number
  lv_vkorg        TYPE vkorg,      " Sales Organization
  lv_vtweg        TYPE vtweg,      " Distribution Channel
  lv_ag           TYPE edi_inpnr,  " Internal partner number (in SAP System)
  lv_we           TYPE edi_inpnr,  " Internal partner number (in SAP System)
*  lv_parvw        TYPE parvw,
*  lv_expnr        TYPE edi_expnr,        "CR1110:SGHOSH:16/05/2014--
*  lv_inpnr        TYPE edi_inpnr,
*  lv_kunnr        TYPE kunnr,            "CR1110:SGHOSH:16/05/2014--
  lv_trg_typ      TYPE edi_bsart,          " Document type
  lv_active       TYPE ain_epc_active_ind, " Active or Inactive Indicator
  lv_src_typ      TYPE edi_bsart,          " Document type
  lv_flag         TYPE c,                  " Flag of type Character
  lv_lines        TYPE i.                  "CR1110:SGHOSH:16/05/2014++

*&---FIELD SYMBOL DECLARATIONS----------------
FIELD-SYMBOLS: <lfs_data1>    TYPE edidd_tt,
               <lfs_data>     TYPE edidd, " Data record (IDoc)
               <lfs_data_we>  TYPE edidd, " Data record (IDoc)
               <lfs_data_mat> TYPE edidd, " Data record (IDoc)
               <lfs_vkorg>    TYPE vkorg, " Sales Organization
               <lfs_vtweg>    TYPE vtweg, " Distribution Channel
               <lfs_contk>    TYPE vbeln, " Sales and Distribution Document Number
*-->> Begin of change for Defect # 856 by PDEBARU
               <lfs_posnr>    TYPE posnr_d, " Sequence Number for Distribution to Account Assign. Objects
*<<-- End of change for Defect # 856 by PDEBARU
               <lfs_rkon>     TYPE c, " Rkon> of type Character
*-->> Begin of change for Defect # 856 by PDEBARU
               <lfs_vbap> TYPE lty_vbap. " Field symbols
*<<-- End of change for Defect # 856 by PDEBARU

*&----LOCAL CONSTANT DECLARATIONS---------------------------------
CONSTANTS:lc_e1edp01      TYPE edilsegtyp      VALUE 'E1EDP01', " SEGMENT NAME
          lc_e1edp02      TYPE edilsegtyp      VALUE 'E1EDP02', " SEGMENT NAME
          lc_e1edp19      TYPE edilsegtyp      VALUE 'E1EDP19', " SEGMENT NAME
          lc_43           TYPE edi_qualfr      VALUE '043',     "043
          lc_x(1)         TYPE c               VALUE 'X',       "X
          lc_e1edka1      TYPE edilsegtyp      VALUE 'E1EDKA1', " SEGMENT NAME
          lc_e1edk01      TYPE edilsegtyp      VALUE 'E1EDK01', " SEGMENT NAME
          lc_ag           TYPE parvw           VALUE 'AG',      "AG
          lc_we           TYPE parvw           VALUE 'WE',      "WE
*-->> Begin of change for Defect #  856 by PDEBARU
          lc_sh           TYPE parvw           VALUE 'SH', " SH
*<<-- End of change for Defect # 856 by PDEBARU
          lc_program      TYPE programm        VALUE 'IDOC_DATA_INSERT',      "MPROGRAM
          lc_eq           TYPE rmsae_option    VALUE 'EQ',                    "SOPTION
          lc_param        TYPE enhee_parameter VALUE 'E1EDK01-BSART',         "MPARAMETER
          lc_g            TYPE vbtyp           VALUE 'G',                     "VBTYP
          lc_bd87         TYPE tcode           VALUE 'BD87',                  "TCODE
          lc_idoc_data(30)   TYPE c            VALUE '(SAPLVEDA)IDOC_DATA[]', "IDOC_DATA
          lc_xvbak_vkorg(30) TYPE c            VALUE '(SAPLVEDA)XVBAK-VKORG', "XVBAK_VKORG
          lc_xvbak_vtweg(30) TYPE c            VALUE '(SAPLVEDA)XVBAK-VTWEG', "XVBAK_VTWEG
          lc_xvbap_contk(30) TYPE c            VALUE '(SAPLVEDA)XVBAP-CONTK', "XVBAP_CONTK
*-->> Begin of change for Defect # 856 by PDEBARU
          lc_xvbap_contk_p(30) TYPE c            VALUE '(SAPLVEDA)XVBAP-CONTK_POSNR', "XVBAP_CONTK
*<<-- End of change for Defect # 856 by PDEBARU
          lc_flag_rkon(30)   TYPE c            VALUE '(SAPLVEDA)D_FLAG_P-RKON', "D_FLAG_P-RKON
          lc_mem             TYPE char20       VALUE 'CR1110_IDD_0009'.         " Mem of type CHAR20


IMPORT lv_chk TO lv_flag FROM MEMORY ID lc_mem.

IF lv_flag <> lc_x.

  IF segment-segnam = lc_e1edp01. "E1EDP01

*&--Fetching IDOC_DATA
    ASSIGN (lc_idoc_data) TO <lfs_data1>.

    IF sy-subrc = 0.

      li_data = <lfs_data1>.
* ---> Begin of Insert for D3_OTC_IDD_0009 Def#3398 by U033959 on 05-SEP-2017
*     takke IDOC_DATA in temp table and delete all records less than
*     the current segment number
      li_data_temp = li_data.
      DELETE li_data_temp WHERE segnum LT segment-segnum.
* <--- End of Insert for D3_OTC_IDD_0009 Def#3398 by U033959 on 05-SEP-2017

* ---> Begin of Insert for D3_OTC_IDD_0009 Def#7589/INC0412417 by U103061 on 16-NOV-2018
      DELETE li_data_temp WHERE psgnum NE segment-segnum.
* <--- End of Insert for D3_OTC_IDD_0009 Def#7589/INC0412417 by U103061 on 16-NOV-2018

    ENDIF. " IF sy-subrc = 0

    READ TABLE li_data ASSIGNING <lfs_data> WITH KEY segnam = lc_e1edka1  sdata+0(2) = lc_ag.
    IF sy-subrc = 0.
*BOC:CR1110:SGHOSH:16/05/2014
** Code commented which are not relevant to the current requirement as per CR#1110
*      CLEAR : lv_parvw.
*              lv_expnr.
*      lv_parvw              = <lfs_data>-sdata+0(3).
*      lv_expnr              = <lfs_data>-sdata+20(17).
*
      lv_ag              = <lfs_data>-sdata+3(20).
*
**Get internal number
*      CLEAR : lv_kunnr,
*              lv_inpnr.
*
*      SELECT  kunnr     "Customer Number
*              inpnr     "Internal partner number
*        UP TO 1 ROWS
*       FROM  edpar
*       INTO (lv_kunnr,
*             lv_inpnr)
*       WHERE parvw = lv_parvw AND
*             expnr = lv_expnr.
*      ENDSELECT.
*
*      IF sy-subrc = 0.
*      lv_ag  = lv_inpnr.
*EOC:CR1110:SGHOSH:16/05/2014
      READ TABLE li_data ASSIGNING <lfs_data_we> WITH KEY segnam = lc_e1edka1  sdata+0(2) = lc_we.
      IF sy-subrc = 0.
        lv_we  = <lfs_data_we>-sdata+3(20).
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0
*BOC:CR1110:SGHOSH:16/05/2014
** Code commented which are not relevant to the current requirement as per CR#1110
*      ENDIF.
*    ELSE.
*      READ TABLE li_data ASSIGNING <lfs_data> WITH KEY segnam = lc_e1edka1 sdata+0(2) = lc_we.
*      IF sy-subrc = 0.
*        CLEAR : lv_parvw,
**                lv_expnr,
*                lv_inpnr.
*
*        lv_parvw              = <lfs_data>-sdata+0(3).
**        lv_expnr              = <lfs_data>-sdata+20(17).
*        lv_inpnr              = <lfs_data>-sdata+3(20).
*
*        lv_we = lv_inpnr.
*
*        READ TABLE li_data ASSIGNING <lfs_data> WITH KEY segnam = lc_e1edka1  sdata+0(2) = lc_ag.
*        IF sy-subrc = 0.
*          lv_ag = <lfs_data>-sdata+3(20).
*        ENDIF.
*        CLEAR : lv_kunnr ,
*                lv_inpnr.
**Get Internal number
*        SELECT kunnr     "Customer Number
*               inpnr     "Internal partner number
*          UP TO 1 ROWS
*         FROM  edpar
*         INTO (lv_kunnr,
*               lv_inpnr)
*         WHERE parvw = lv_parvw AND
*               expnr = lv_expnr.
*        ENDSELECT.
*
*        IF sy-subrc = 0.
*          lv_we  = lv_inpnr.
*          lv_ag = lv_kunnr.
*        ENDIF.
*  ENDIF.
*ENDIF.
*EOC:CR1110:SGHOSH:16/05/2014
*&--Fetching VKORG
    ASSIGN (lc_xvbak_vkorg) TO <lfs_vkorg>.

    IF sy-subrc = 0.
      lv_vkorg = <lfs_vkorg>.
    ENDIF. " IF sy-subrc = 0
*&--Fetching VTWEG
    ASSIGN (lc_xvbak_vtweg) TO <lfs_vtweg>.

    IF sy-subrc = 0.
      lv_vtweg = <lfs_vtweg>.
    ENDIF. " IF sy-subrc = 0

    READ TABLE li_data ASSIGNING <lfs_data> WITH KEY segnam = lc_e1edk01.
    IF sy-subrc = 0.
      lv_src_typ = <lfs_data>-sdata+79(4).
    ENDIF. " IF sy-subrc = 0
*Check Active flag
    CLEAR lv_active.
    SELECT mactive                 "Active or Inactive Indicator
           mvalue2                 "Select Options: Value High
      UP TO 1 ROWS
           FROM   zotc_prc_control " OTC Process Team Control Table
           INTO   (lv_active ,
                   lv_trg_typ)
           WHERE  vkorg      = lv_vkorg           AND
                  vtweg      = lv_vtweg           AND
                  mprogram   = lc_program         AND
                  mparameter = lc_param           AND
                  soption    = lc_eq              AND
                  mvalue1    =  lv_src_typ.
    ENDSELECT.
    IF lv_active = lc_x.

      CLEAR: lwa_data.
      LOOP AT li_data INTO lwa_data WHERE segnam =  lc_e1edp01.

        READ TABLE li_data WITH KEY   psgnum     = lwa_data-segnum
                                      segnam     = lc_e1edp02
                                      sdata+0(3) = lc_43
                                      TRANSPORTING NO FIELDS.

        IF sy-subrc <> 0.
* ---> Begin of Delete for D3_OTC_IDD_0009 Def#3398 by U033959 on 05-SEP-2017
*          READ TABLE li_data ASSIGNING <lfs_data_mat> WITH KEY psgnum = lwa_data-segnum segnam = lc_e1edp19.
* <--- End of Delete for D3_OTC_IDD_0009 Def#3398 by U033959 on 05-SEP-2017
* ---> Begin of Insert for D3_OTC_IDD_0009 Def#3398 by U033959 on 05-SEP-2017
*         Read temp table to read the correct record.
          READ TABLE li_data_temp ASSIGNING <lfs_data_mat> WITH KEY psgnum = lwa_data-segnum segnam = lc_e1edp19.
* <--- End of Insert for D3_OTC_IDD_0009 Def#3398 by U033959 on 05-SEP-2017
          IF sy-subrc = 0.
            CLEAR lv_matnr.
            lv_matnr = <lfs_data_mat>-sdata+3(35).
*Join VBAK & VBPA & VBAP
            REFRESH li_vbeln[].
*-->> Begin of comment for Defect # 856 by PDEBARU
* The below code is commented to introduce a new select block

*            SELECT vbak~vbeln INTO TABLE li_vbeln FROM vbak
*             INNER JOIN vbap ON
*             vbak~vbeln = vbap~vbeln
*             INNER JOIN vbpa ON
*             vbak~vbeln = vbpa~vbeln
*             INNER JOIN veda ON
*             vbak~vbeln = veda~vbeln
*             WHERE vbak~vbtyp = lc_g     AND
*               vbak~auart = lv_trg_typ   AND
*               vbak~vkorg = lv_vkorg     AND
*               vbak~vtweg = lv_vtweg     AND
*               vbak~kunnr = lv_ag        AND   " Sold To (AG)
*               vbpa~parvw = lc_we        AND
*               vbpa~kunnr = lv_we        AND   " Ship To (WE)
*               vbap~matnr = lv_matnr     AND
*               veda~vbegdat <= sy-datum  AND
*               veda~venddat >= sy-datum.

*<<-- End of comment for defect # 856 by PDEBARU
*-->> Begin of change for Defect # 856 by PDEBARU
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lv_we
              IMPORTING
                output = lv_we.

            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lv_ag
              IMPORTING
                output = lv_ag.
* select respective contract document from database
            SELECT vapma~vbeln " Sales and Distribution Document Number
                   vapma~posnr " Item number of the SD document
                   vapma~datab " Quotation or contract valid from
                   vapma~datbi " Quotation or contract valid to
                   INTO TABLE li_item
                   FROM vapma  " Sales Index: Order Items by Material
                   INNER JOIN vbpa ON
                   vapma~vbeln = vbpa~vbeln
                                WHERE vapma~matnr =  lv_matnr   AND
                                      vapma~vkorg =  lv_vkorg   AND
                                      vapma~vtweg =  lv_vtweg   AND
                                      vapma~auart =  lv_trg_typ AND
                                      vapma~kunnr =  lv_ag      AND
                                      vbpa~kunnr   =  lv_we     AND
                                      vbpa~parvw  = lc_we .
            IF sy-subrc = 0.
*       Don't consider those contract for which 'Contract start date'
*       is in future. Means delete those contracts for which DATAB (Contract
*       start date) is greater than current date
*       Similarly, Don't consider those contract for which 'Contract End date'
*       is in Past. Means delete those contracts for which DATBI (Contract
*       end date) is less than current date
              DELETE li_item WHERE ( datab GT sy-datum )
                                OR ( datbi LT sy-datum ).
            ENDIF. " IF sy-subrc = 0
            IF li_item IS NOT INITIAL.
* The sort statement has to be introduced as we will consider
* only the first item based on creation of contracts
              SORT li_item BY vbeln ASCENDING.
            ENDIF. " IF sy-subrc = 0

*&&-- After filtering out multiple contracts, it will retain ONLY 1 contract#
*     with multiple items (we need these for Valid From & Valid To Dates)
            CLEAR lwa_item1.
            READ TABLE li_item INTO lwa_item1 INDEX 1.
            IF sy-subrc IS INITIAL.
*&&-- Contract #
              lv_vbeln = lwa_item1-vbeln.

* We will now check if the Material which the user has entered on
* the new Sales Order is already marked for Rejection or not.
              SELECT vbeln " Contract Number (in this case)
                     posnr " Item Number
                     abgru " Reason for Rejection
                INTO TABLE li_vbap
                FROM vbap  " Sales Document: Item Data
                WHERE vbeln = lv_vbeln
                  AND matnr = lv_matnr.
              IF sy-subrc IS INITIAL.
* It may happen that a Material has one line item
* marked for Rejection, and another line item not.
* In such cases, the Material will not be referenced
* from Contract.
                REFRESH: li_item1.
                li_item1[] = li_item[].
* Sort is done as we will consider the line items
                SORT li_item1 BY posnr.
                REFRESH li_item[].
              ENDIF. " IF sy-subrc IS INITIAL

              LOOP AT li_vbap ASSIGNING <lfs_vbap>.
                IF <lfs_vbap>-abgru IS INITIAL.
                  READ TABLE li_item1 INTO lwa_item1
                                      WITH KEY posnr = <lfs_vbap>-posnr
                                      BINARY SEARCH.
                  IF sy-subrc IS INITIAL.
                    ASSIGN (lc_xvbap_contk) TO <lfs_contk>.
                    IF sy-subrc = 0.
                      <lfs_contk> = <lfs_vbap>-vbeln.
                    ENDIF. " IF sy-subrc = 0

                    ASSIGN (lc_xvbap_contk_p) TO <lfs_posnr>.
                    IF sy-subrc = 0.
                      <lfs_posnr> = <lfs_vbap>-posnr.
                    ENDIF. " IF sy-subrc = 0

                    ASSIGN (lc_flag_rkon) TO <lfs_rkon>.
                    IF sy-subrc = 0.
                      <lfs_rkon> = lc_x.
                    ENDIF. " IF sy-subrc = 0

                  ENDIF. " IF sy-subrc IS INITIAL
                ELSE. " ELSE -> IF sy-subrc = 0
* If the item is marked for Rejection, a information message
* will be displayed.
                  MESSAGE i948(zotc_msg) WITH <lfs_vbap>-posnr. "'Marked for Rejection.
                ENDIF. " IF <lfs_vbap>-abgru IS INITIAL
              ENDLOOP. " LOOP AT li_vbap ASSIGNING <lfs_vbap>
*<<-- End of change for Defect # 856 by PDEBARU

*-->> Begin of comment for Defect # 856 by PDEBARU
*            IF sy-subrc = 0.
*
*              SORT li_vbeln BY vbeln.
*              DELETE ADJACENT DUPLICATES FROM li_vbeln COMPARING vbeln.
**BOC:CR1110:SGHOSH:16/05/2014
*              DESCRIBE TABLE li_vbeln LINES lv_lines.
*              IF lv_lines GT 1.
**           Multiple Contract Exist for the given parameters
*                MESSAGE e900(zotc_msg). " Multiple Contract Exist for the given parameters
*              ELSE. " ELSE -> IF lv_lines GT 1
*                READ TABLE li_vbeln INTO lwa_vbeln INDEX 1.
*                IF sy-subrc = 0.
**EOC:CR1110:SGHOSH:16/05/2014
*                  ASSIGN (lc_xvbap_contk) TO <lfs_contk>.
*                  IF sy-subrc = 0.
*                    <lfs_contk> = lwa_vbeln-vbeln.
*                  ENDIF. " IF sy-subrc = 0
*
*                  ASSIGN (lc_flag_rkon) TO <lfs_rkon>.
*                  IF sy-subrc = 0.
*                    <lfs_rkon> = lc_x.
*                  ENDIF. " IF sy-subrc = 0
*                ENDIF. " IF sy-subrc = 0
*              ENDIF. " IF lv_lines GT 1
*<<-- End of comment for Defect # 856 by PDEBARU
            ENDIF. " IF sy-subrc IS INITIAL
          ENDIF. " IF sy-subrc <> 0
        ENDIF. " LOOP AT li_data INTO lwa_data WHERE segnam = lc_e1edp01
      ENDLOOP. " IF lv_active = lc_x
    ENDIF. " IF lv_flag EQ lc_x
  ENDIF. " IF lv_flag EQ lc_x
ENDIF.
