FUNCTION ZOTC_0043_BILLBACK_PRICE_ITEM .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_XVBAP) TYPE  VBAPVB
*"     REFERENCE(IM_MAAPV) TYPE  MAAPV
*"     REFERENCE(IM_VBKD) TYPE  VBKD OPTIONAL
*"     REFERENCE(IM_T_XVBAP) TYPE  VA_VBAPVB_T
*"     REFERENCE(IM_MAEPV) TYPE  MAEPV OPTIONAL
*"     REFERENCE(IM_VBAP) TYPE  VBAP OPTIONAL
*"     REFERENCE(IM_VBAK) TYPE  VBAK OPTIONAL
*"  CHANGING
*"     REFERENCE(CHNG_TKOMP) TYPE  KOMP
*"----------------------------------------------------------------------
*FUNCTION zotc_0043_billback_price_item.
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
*======================================================================*
* 20-June-2014 PMISHRA E2DK901708 D2_OTC_EDD_0134 - Populate the values*
*                                 for customer fields in pricing       *
*                                 structure TKOMP.                     *
*&---------------------------------------------------------------------*
* 22-Apr-2015 DMOIRAN E2DK901708  D2_OTC_EDD_0134 CR D2_627. Pass the last
*                                 BOM component indicator to KOMP.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* 20-Aug-2015 DDWIVED E2DK914825  D2_OTC_EDD_0134 Defect 8917. – Modify
*                              condition type ZMPL for Material Group 5.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* 15-Sep-2015 ASK  E2DK915355   Defect 1019.Unit Price and Extended    *
*                              Price are not matching for BoM.         *
*&---------------------------------------------------------------------*
* 05-Sep-2016 SAGARWA1 E2DK918878 D2_OTC_EDD_0011_Defect#2001 -Discount*
*                                 split is not getting copied over from*
*                                 Invoice to Debit and Credit Mamo     *
*                                 Request.                             *
*&---------------------------------------------------------------------*
* 24-Oct-2017  SMUKHER4 E1DK931954 D3_OTC_EDD_0134 Defect# 3696:       *
*                                  Issue with the invoice for debit/   *
*                                  credit notes.                       *
*&---------------------------------------------------------------------*

*--Start of CR D2_163
  CONSTANTS :
     lc_criteria         TYPE z_criteria           VALUE 'NULL',                    " Enh. Criteria
     lc_cri_pomap        TYPE z_criteria           VALUE 'D2_OTC_EDD_0134_PO_TYPE', " Enh. Criteria
     lc_edd_0134         TYPE z_enhancement        VALUE 'D2_OTC_EDD_0134',         " Enhancement No.
     lc_underscr         TYPE char1                VALUE '_',                       " Underscr of type CHAR1
     lc_credit           TYPE vbtyp                VALUE 'K',                       " Defect 2001
     lc_debit            TYPE vbtyp                VALUE 'L',                       " Defect 2001
     lc_zztragr          TYPE char7                VALUE 'ZZTRAGR',                 " Zztragr of type CHAR7
*&--Begin of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017
     lc_criteria_vbtyp  TYPE z_criteria            VALUE 'VBTYP_ITEM'.
*&<--End of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017


  DATA:li_status         TYPE STANDARD TABLE OF zdev_enh_status, "Enhancement Status table
       lv_zztragr        TYPE char12,                            " Zztragr of type CHAR12
       lv_upmat          TYPE upmat,                             " Pricing reference material of main item
       lv_val_low        TYPE fpb_low,                           " From Value
*--End of CR D2_163
*&--Begin of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017
*&--Local Internal & Work Area.
       li_vbtyp         TYPE STANDARD TABLE OF fkk_ranges, " Structure: Select Options
       lwa_status       TYPE zdev_enh_status,              " Enhancement Status
       lwa_vbtyp       TYPE fkk_ranges.                    " Structure: Select Options
*&<--End of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017

* ---> Begin of Change for D2_OTC_EDD_0134 by PMISHRA
  FIELD-SYMBOLS: <lfs_xvbap>   TYPE vbapvb,          " Document Structure for XVBAP/YVBAP
                 <lfs_status>  TYPE zdev_enh_status. " Enhancement Status* "CR D2_163

*  chng_tkomp-zzprodh4 = im_xvbap-prodh(11). " Product Family

  chng_tkomp-zzstlnr  = im_vbap-stlnr. " Bill of material
*  chng_tkomp-zzstlnr  = im_xvbap-stlnr. " Bill of material

* ---> Begin of Change for D2_OTC_EDD_0134_CR_D2_163 by PMISHRA
*--Start of CR D2_163
*--Call to EMI Function Module To Get List Of EMI Statuses for Transportation Group Mapping
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_edd_0134
    TABLES
      tt_enh_status     = li_status.

  DELETE li_status WHERE active NE abap_true.
  SORT li_status BY criteria sel_low.

*  chng_tkomp-zzbsark  = im_vbkd-bsark. " Bill of material
*&-- Get the value of PO type mapped in EMI tool. If there is no value found
*&-- then assign the importing value to TKOMP
  lv_val_low = im_vbkd-bsark.
  READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_cri_pomap
                                                       sel_low  = lv_val_low
                                                       BINARY SEARCH.
  IF sy-subrc EQ 0.
    chng_tkomp-zzbsark  = <lfs_status>-sel_high.
  ELSE. " ELSE -> IF sy-subrc EQ 0
    chng_tkomp-zzbsark  = im_vbkd-bsark. " Bill of material
  ENDIF. " IF sy-subrc EQ 0
* ---> End of Change for D2_OTC_EDD_0134_CR_D2_163 by PMISHRA

**  IF NOT im_maapv-tragr IS INITIAL.
*  IF NOT im_maepv-tragr IS INITIAL.
*    chng_tkomp-tragr    = im_maepv-tragr. " Transportation Group
*  ENDIF. " IF NOT im_maapv-tragr IS INITIAL
*change to maapv

*  IF NOT im_maapv-tragr IS INITIAL.
  IF NOT im_xvbap-zztragr IS INITIAL.

    READ TABLE li_status  ASSIGNING <lfs_status>  WITH KEY criteria = lc_zztragr
                                                           sel_low  = im_xvbap-zztragr
                                                           active   = abap_true.
    IF sy-subrc EQ 0.
      chng_tkomp-tragr    = <lfs_status>-sel_high. " Transportation Group
    ENDIF. " IF sy-subrc EQ 0
*    chng_tkomp-tragr    = im_xvbap-zztragr. " Transportation Group
*--End of CR D2_163

  ENDIF. " IF NOT im_xvbap-zztragr IS INITIAL

*&--Begin of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017
  LOOP AT li_status INTO lwa_status.
    IF lwa_status-criteria = lc_criteria_vbtyp.
**** Populating EMI entries in range table.
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

  IF NOT im_xvbap-vgbel IS INITIAL.
    SELECT SINGLE auart " Sales Document Type
    INTO chng_tkomp-zzrauart
    FROM vbak           " Sales Document: Header Data
    WHERE vbeln = im_xvbap-vgbel.
  ENDIF. " IF NOT im_xvbap-vgbel IS INITIAL
  IF NOT im_xvbap-uepos IS INITIAL.

*&-->Begin of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017
*&--When VBTYP NE (K,L), then the read will happen
    IF im_vbak-vbtyp NOT IN li_vbtyp.
*&<--End of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017

* get bom material number
      READ TABLE im_t_xvbap ASSIGNING <lfs_xvbap> WITH KEY uepos = space  grkor = im_vbap-grkor.
*&-->Begin of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017
*&--When VBTYP EQ (K,L), then the read will happen
    ELSE. " ELSE -> IF im_vbak-vbtyp NOT IN li_vbtyp
      READ TABLE im_t_xvbap ASSIGNING <lfs_xvbap> WITH KEY posnr = im_xvbap-uepos
                                                           grkor = im_vbap-grkor.
    ENDIF. " IF im_vbak-vbtyp NOT IN li_vbtyp
*&<--End of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017

    IF sy-subrc = 0.
      lv_upmat = <lfs_xvbap>-matnr.
    ENDIF. " IF sy-subrc = 0

    READ TABLE im_t_xvbap ASSIGNING <lfs_xvbap> WITH KEY posnr = im_xvbap-uepos.
    IF sy-subrc EQ 0 AND  <lfs_xvbap>-upmat IS NOT INITIAL.
      READ TABLE im_t_xvbap ASSIGNING <lfs_xvbap> WITH KEY matnr = <lfs_xvbap>-upmat.
    ENDIF. " IF sy-subrc EQ 0 AND <lfs_xvbap>-upmat IS NOT INITIAL
    IF sy-subrc EQ 0.
      chng_tkomp-zzuprodh4 = <lfs_xvbap>-prodh+7(4). " Product Family
      chng_tkomp-zzuprodh5 = <lfs_xvbap>-prodh+11(4). " Product Line
      chng_tkomp-upmat = lv_upmat.
      chng_tkomp-zzumvgr5 = <lfs_xvbap>-mvgr5 . " Defect #8917 added by ddwivedi on 19-Aug-2015
*& --> Begin of Insert for D2_OTC_EDD_0011_Defect#2001 by SAGARWA1 on 05-Sep-2016
      IF im_vbak-vbtyp = lc_credit OR
        im_vbak-vbtyp = lc_debit.
        chng_tkomp-zzmgame  = <lfs_xvbap>-zmeng.
      ELSE. " ELSE -> IF im_vbak-vbtyp = lc_credit OR
*& <-- End of Insert for D2_OTC_EDD_0011_Defect#2001 by SAGARWA1 on 05-Sep-2016
        chng_tkomp-zzmgame  = <lfs_xvbap>-kwmeng. " Defect 1019
      ENDIF. " IF im_vbak-vbtyp = lc_credit OR
    ENDIF. " IF sy-subrc EQ 0
*--Start of CR D2_163
*  ELSE. " ELSE -> IF sy-subrc EQ 0
*& --> Begin of Delete for D2_OTC_EDD_0011_Defect#2001 by SAGARWA1 on 05-Sep-2016
**    IF NOT im_xvbap-stlnr IS INITIAL.
*& <-- End of Delete for D2_OTC_EDD_0011_Defect#2001 by SAGARWA1 on 05-Sep-2016
*& --> Begin of Insert for D2_OTC_EDD_0011_Defect#2001 by SAGARWA1 on 05-Sep-2016
    IF NOT im_vbap-stlnr IS INITIAL.
*& <-- End of Insert for D2_OTC_EDD_0011_Defect#2001 by SAGARWA1 on 05-Sep-2016
      READ TABLE im_t_xvbap ASSIGNING <lfs_xvbap> WITH KEY posnr = im_xvbap-uepos.
      IF sy-subrc EQ 0 AND  <lfs_xvbap>-upmat IS NOT INITIAL.
        READ TABLE im_t_xvbap ASSIGNING <lfs_xvbap> WITH KEY matnr = <lfs_xvbap>-upmat.
      ENDIF. " IF sy-subrc EQ 0 AND <lfs_xvbap>-upmat IS NOT INITIAL
      IF sy-subrc EQ 0.
        chng_tkomp-zzuposnr = <lfs_xvbap>-posnr. " Product Family
*      chng_tkomp-zzuposnr = im_xvbap-posnr. " Product Family
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF NOT im_vbap-stlnr IS INITIAL

* ---> Begin of Insert for D2_OTC_EDD_0134 CR D2_627 by DMOIRAN
* If the last item of the BOM component is marked then it is passed
* to corresponding field of KOMP

    IF NOT im_xvbap-zzbom_last_comp IS INITIAL.
      chng_tkomp-zzbom_last_comp = im_xvbap-zzbom_last_comp.
    ENDIF. " IF NOT im_xvbap-zzbom_last_comp IS INITIAL

* <--- End    of Insert for D2_OTC_EDD_0134 CR D2_627 by DMOIRAN

  ENDIF. " IF NOT im_xvbap-uepos IS INITIAL
*--End of CR D2_163
* ---> End of Change for D2_OTC_EDD_0134 by PMISHRA

  chng_tkomp-zzprofl  = im_xvbap-profl. " Dangerous Goods Indicator Prof
  chng_tkomp-zzmvgr4  = im_xvbap-mvgr4. " Material Group 4
  chng_tkomp-zzmvgr5 = im_xvbap-mvgr5. " materail group 5 (+) Defect no # 8917 by ddwivedi on 19-Aug-2015

ENDFUNCTION.
