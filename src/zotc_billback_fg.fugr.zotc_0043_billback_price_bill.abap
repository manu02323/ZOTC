FUNCTION zotc_0043_billback_price_bill.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_XVBRP) TYPE  VBRPVB
*"     REFERENCE(IM_MAAPV) TYPE  MAAPV
*"     REFERENCE(IM_T_XVBRP) TYPE  VBRPVB_T
*"     REFERENCE(IM_T_VBAP) TYPE  VA_VBAPVB_T OPTIONAL
*"     REFERENCE(IM_T_LIPS) TYPE  VA_LIPSVB_T OPTIONAL
*"     REFERENCE(IM_VBRK) TYPE  VBRK OPTIONAL
*"  CHANGING
*"     REFERENCE(CHNG_TKOMP) TYPE  KOMP
*"----------------------------------------------------------------------
************************************************************************
* PROGRAM    :  ZOTC_0043_BILLBACK_PRICE_FM (FM)                       *
* TITLE      :  Billback Enhancement for Billing User Exit             *
* DEVELOPER  :  ANANYA DAS                                             *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0043                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Population of custom fields in Pricing structure
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 11-FEB-2013  ADAS1   E1DK909221 D#2743:Populate pricing at Item level*
*&---------------------------------------------------------------------*
*======================================================================*
* 20-June-2014 PMISHRA E2DK901708 D2_OTC_EDD_0134 - Populate the values*
*                                 for customer fields in pricing       *
*                                 structure TKOMP.                     *
*&---------------------------------------------------------------------*
* 22-Apr-2015 DMOIRAN E2DK901708  D2_OTC_EDD_0134 CR D2_627. Pass the last
*                                 BOM component indicator to KOMP.
*&---------------------------------------------------------------------*
* 20-Aug-2015 DDWIVED E2DK914825  D2_OTC_EDD_0134 Defect 8917. – Modify
*                              condition type ZMPL for Material Group 5.
*&---------------------------------------------------------------------*
* 15-Sep-2015 ASK  E2DK915355   Defect 1019.Unit Price and Extended    *
*                              Price are not matching for BoM.         *
*&---------------------------------------------------------------------*
* 11-Mar-2016 ASK  E2DK915355   Defect 1424.For Pric book rounding issue*
*&---------------------------------------------------------------------*
* 24-Oct-2017  SMUKHER4 E1DK931954 D3_OTC_EDD_0134 Defect# 3696:       *
*                                  Issue with the invoice for debit/   *
*                                  credit notes.                       *
*&---------------------------------------------------------------------*

* ---> Begin of Change for D2_OTC_EDD_0134 by PMISHRA

  CONSTANTS:
     lc_posnr            TYPE posnr VALUE '000000',                                 " Item number of the SD document
     lc_criteria         TYPE z_criteria           VALUE 'NULL',                    " Enh. Criteria
     lc_cri_pomap        TYPE z_criteria           VALUE 'D2_OTC_EDD_0134_PO_TYPE', " Enh. Criteria
     lc_edd_0134         TYPE z_enhancement        VALUE 'D2_OTC_EDD_0134',         " Enhancement No.
     lc_zztragr          TYPE char7                VALUE 'ZZTRAGR',                 " Zztragr of type CHAR7
*&--Begin of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017
    lc_criteria_vbtyp    TYPE z_criteria           VALUE 'VBTYP_BILL'.
*&<--End of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017

  FIELD-SYMBOLS: <lfs_xvbrp> TYPE vbrpvb,            " Reference Structure for XVBRP/YVBRP
                 <lfs_status>  TYPE zdev_enh_status, " Enhancement Status
                 <lfs_vbap>  TYPE vbapvb,            " Document Structure for XVBAP/YVBAP
                 <lfs_lips>  TYPE lipsvb,            " Reference structure for XLIPS/YLIPS
                 <lfs_lips1>  TYPE lipsvb,           " Reference structure for XLIPS/YLIPS
                 <lfs_vbapvb_1>  TYPE vbapvb,        " Document Structure for XVBAP/YVBAP
                 <lfs_vbapvb_2>  TYPE vbapvb.        " Document Structure for XVBAP/YVBAP

  DATA:li_status         TYPE STANDARD TABLE OF zdev_enh_status. "Enhancement Status table

  DATA: lv_uepos  TYPE uepos,           " Higher-level item in bill of material structures
        lv_bsark  TYPE bsark,           " PO type
        lwa_vbrp  TYPE vbrpvb,          " Defect 1019
        li_lips_tmp  TYPE va_lipsvb_t,  " Defect 1424
        lwa_lips   TYPE lipsvb,         " Defect 1424
        lv_val_low        TYPE fpb_low, " From Value
        lv_upmat  TYPE matnr,           " Material Number
*&--Begin of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017
*&--Local Internal table & Work Area
       li_vbtyp        TYPE STANDARD TABLE OF fkk_ranges, " Structure: Select Options
       lwa_status      TYPE zdev_enh_status,              " Enhancement Status
       lwa_vbtyp       TYPE fkk_ranges.                   " Structure: Select Options
*&<--End of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017

*--Call to EMI Function Module To Get List Of EMI Statuses for Transportation Group Mapping
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_edd_0134
    TABLES
      tt_enh_status     = li_status.

  DELETE li_status WHERE active NE abap_true.

  IF NOT im_xvbrp-zztragr IS INITIAL.
    READ TABLE li_status  ASSIGNING <lfs_status>  WITH KEY criteria = lc_zztragr
                                                           sel_low  = im_xvbrp-zztragr
                                                           active   = abap_true.
    IF sy-subrc EQ 0.
      chng_tkomp-tragr    = <lfs_status>-sel_high. " Transportation Group
    ENDIF. " IF sy-subrc EQ 0
*    chng_tkomp-tragr    = im_xvbrp-zztragr. " Transportation Group ""jrich change maapv to xvbrp
*    chng_tkomp-tragr    = im_maapv-tragr. " Transportation Group
  ENDIF. " IF NOT im_xvbrp-zztragr IS INITIAL

*  IF NOT im_xvbrp-uepos IS INITIAL.
*    READ TABLE im_t_xvbrp ASSIGNING <lfs_xvbrp> WITH KEY posnr = im_xvbrp-uepos.
*    IF sy-subrc EQ 0.
*      chng_tkomp-zzuprodh4 = <lfs_xvbrp>-prodh+7(4). " Product Family
*      chng_tkomp-zzuprodh5 = <lfs_xvbrp>-prodh+11(4). " Product Line
*    ENDIF. " IF sy-subrc EQ 0
*  ENDIF. " IF NOT im_xvbrp-uepos IS INITIAL

  CLEAR lv_bsark.
  IF NOT im_xvbrp-aubel IS INITIAL.
    SELECT bsark " Customer purchase order type
      UP TO 1 ROWS
      FROM vbkd  " Sales Document: Business Data
      INTO lv_bsark
*    INTO chng_tkomp-zzbsark
      WHERE vbeln = im_xvbrp-aubel
        AND  posnr = lc_posnr.
    ENDSELECT.
    IF sy-subrc = 0.
      lv_val_low = lv_bsark.
      SORT li_status BY criteria sel_low.

*&-- Get the value of PO type mapped in EMI tool. If there is no value found
*&-- then assign the importing value to TKOMP
      READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_cri_pomap
                                                       sel_low  = lv_val_low
                                                       BINARY SEARCH.
      IF sy-subrc EQ 0.
        chng_tkomp-zzbsark  = <lfs_status>-sel_high.
      ELSE. " ELSE -> IF sy-subrc EQ 0
        chng_tkomp-zzbsark  = lv_bsark. " Bill of material
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc = 0

*&--Begin of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017
    LOOP AT li_status INTO lwa_status.
      IF lwa_status-criteria = lc_criteria_vbtyp.
**** Populating EMI entries in a range table
      lwa_vbtyp-sign   = lwa_status-sel_sign.
      lwa_vbtyp-option = lwa_status-sel_option.
      lwa_vbtyp-low    = lwa_status-sel_low.
      lwa_vbtyp-high   = lwa_status-sel_high.
      APPEND lwa_vbtyp TO li_vbtyp.
      CLEAR lwa_vbtyp.
      ENDIF.
      CLEAR lwa_status.
    ENDLOOP. " LOOP AT li_status INTO lwa_status
*&<--End of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017

* Begin of Defect 1424
    READ TABLE im_t_lips ASSIGNING <lfs_lips> WITH KEY vbeln = im_xvbrp-vgbel
                                                        posnr = im_xvbrp-vgpos.

    IF sy-subrc = 0.
*   Get higher level item data
      READ TABLE im_t_lips ASSIGNING <lfs_lips1> WITH KEY vbeln = <lfs_lips>-vbeln
                                                   posnr = <lfs_lips>-uecha.
      IF sy-subrc  = 0.
        chng_tkomp-zzkcmeng = <lfs_lips1>-kcmeng.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0
* End of Defect 1424
*  Pricing reference material for main item - from sales data
    READ TABLE im_t_vbap ASSIGNING <lfs_vbap> WITH KEY vbeln = im_xvbrp-aubel
                                                       posnr = im_xvbrp-aupos.
    IF sy-subrc = 0.
      chng_tkomp-zzstlnr = <lfs_vbap>-stlnr.
      IF <lfs_vbap>-uepos IS NOT INITIAL. " Component item
*&--Begin of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017
*&--When VBTYP NE (O , P), then the read will happen
        IF im_vbrk-vbtyp NOT IN li_vbtyp.
*&<--End of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017
* get bom material number
          READ TABLE im_t_vbap ASSIGNING <lfs_vbapvb_1> WITH KEY vbeln = <lfs_vbap>-vbeln
                                                                 uepos = space
*                                                               stlnr = <lfs_vbap>-stlnr.
                                                                 grkor = <lfs_vbap>-grkor.
*&-->Begin of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017
        ELSE. " ELSE -> IF im_vbrk-vbtyp NOT IN li_vbtyp
*&--When VBTYP EQ (O , P), then the read will happen
          READ TABLE im_t_vbap ASSIGNING <lfs_vbapvb_1> WITH KEY vbeln = <lfs_vbap>-vbeln
                                                                 posnr = <lfs_vbap>-uepos
                                                                 grkor = <lfs_vbap>-grkor.
        ENDIF. " IF im_vbrk-vbtyp NOT IN li_vbtyp
*&<--End of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017
        IF sy-subrc = 0.
          lv_upmat = <lfs_vbapvb_1>-matnr.
*        Begin of Defect 1019
*           No Need for Binary search as it will have less no of entries
          READ TABLE im_t_xvbrp INTO lwa_vbrp WITH KEY
                                     matnr = lv_upmat
                                     aubel = <lfs_vbapvb_1>-vbeln
                                     aupos = <lfs_vbapvb_1>-posnr.
          IF sy-subrc = 0.
            chng_tkomp-zzmgame = lwa_vbrp-fkimg.
          ENDIF. " IF sy-subrc = 0
*        End   of Defect 1019

        ENDIF. " IF sy-subrc = 0
*single level bom
        READ TABLE im_t_vbap ASSIGNING <lfs_vbapvb_2> WITH KEY vbeln = <lfs_vbap>-vbeln
                                                               posnr = <lfs_vbap>-uepos
                                                               matnr = lv_upmat.
        IF sy-subrc NE 0.
* this will be done for multi level bom.
*          IF <lfs_vbapvb_1> IS ASSIGNED.
          READ TABLE im_t_vbap ASSIGNING <lfs_vbapvb_2> WITH KEY vbeln = <lfs_vbapvb_1>-vbeln
                                                              posnr = <lfs_vbapvb_1>-posnr
                                                              matnr = lv_upmat.
*          ENDIF. " IF <lfs_vbapvb_1> IS assigned
        ENDIF. " IF sy-subrc NE 0
        IF sy-subrc EQ 0. " AND  <lfs_vbapvb_2>-upmat IS NOT INITIAL.
*          READ TABLE im_t_vbap ASSIGNING <lfs_vbapvb_3> WITH KEY matnr = <lfs_vbapvb_2>-upmat.
*          IF sy-subrc = 0.
          chng_tkomp-upmat = lv_upmat.
          chng_tkomp-zzuposnr = <lfs_vbapvb_2>-posnr.
          chng_tkomp-zzuprodh4 = <lfs_vbapvb_2>-prodh+7(4). " Product Family
          chng_tkomp-zzuprodh5 = <lfs_vbapvb_2>-prodh+11(4). " Product Line
          chng_tkomp-zzumvgr5 = <lfs_vbapvb_2>-mvgr5 . " added by ddwivedi on 19-Aug-2015 Defect # 8917
*          ENDIF.


        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF <lfs_vbap>-uepos IS NOT INITIAL
    ENDIF. " IF sy-subrc = 0

  ENDIF. " IF NOT im_xvbrp-aubel IS INITIAL

* ---> Begin of Insert for D2_OTC_EDD_0134 CR D2_627 by DMOIRAN
* If the last item of the BOM component is marked then it is passed
* to corresponding field of KOMP
* pass BOM last component indicator to KOMP structure
  IF NOT im_xvbrp-zzbom_last_comp IS INITIAL.

    chng_tkomp-zzbom_last_comp = im_xvbrp-zzbom_last_comp.

* Begin of Defect 1424
*  For batch split case in the last item ( of Order ) do not update
* KOMP structure for all the batch componenets except the last one

    READ TABLE im_t_lips INTO lwa_lips WITH KEY vbeln = im_xvbrp-vgbel
                                                posnr = im_xvbrp-vgpos.

    IF sy-subrc = 0.
      IF lwa_lips-uecha IS NOT INITIAL.

        li_lips_tmp = im_t_lips.
        DELETE li_lips_tmp WHERE uecha NE lwa_lips-uecha OR
                                 vbeln NE im_xvbrp-vgbel.
        SORT li_lips_tmp BY posnr DESCENDING.
        CLEAR lwa_lips.
        READ TABLE li_lips_tmp INDEX 1 INTO lwa_lips.
        IF lwa_lips-posnr NE im_xvbrp-vgpos.
          CLEAR chng_tkomp-zzbom_last_comp.
        ENDIF. " IF lwa_lips-posnr NE im_xvbrp-vgpos
      ENDIF. " IF lwa_lips-uecha IS NOT INITIAL
    ENDIF. " IF sy-subrc = 0

* End of Defect 1424

  ENDIF. " IF NOT im_xvbrp-zzbom_last_comp IS INITIAL

* <--- End    of Insert for D2_OTC_EDD_0134 CR D2_627 by DMOIRAN


* ---> End of Change for D2_OTC_EDD_0134 by PMISHRA

  chng_tkomp-zzmvgr4  = im_xvbrp-mvgr4. " Material Group 4
  chng_tkomp-zzmvgr5 = im_xvbrp-mvgr5. " Material Group 5 Defect # 8917 added by DDWIVEDI on 19-Aug-2015

* Dangerous Goods profile Indicator is not passed in Billing Exit
* as this value will be available from Sales document
* (as per conversation with Functional owner Rajiv Basu).
*  chng_tkomp-zzprofl  = im_xvbrp-profl. " Dangerous Goods Indicator Prof





ENDFUNCTION.
