***********************************************************************
*Program    : ZOTCN0134O_BOM_PRICING                                  *
*Title      : Append Pricing Structure                                *
*Developer  : Pradipta K Mishra                                       *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_EDD_0134                                           *
*---------------------------------------------------------------------*
*Description: Update the logic to populate STLNR in VBAP based on SAP *
*             incident Number( 1195649)                               *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date          User         Transport       Description
*=========== ============== ============== ===========================*
*08-Jan-2015  PMISHRA      E2DK900492      D2_OTC_EDD_0134_Defect_1853
*---------------------------------------------------------------------*
*28-APR-2015  PMISHRA      E2DK900492      CR D2_627 Population of    *
*                                          STLNR for BoM Items when SO*
*                                          created with Ref to Invouce*
*10-SEP-2015  DARUMUG      E2DK905281      D# 536, 1162 and 1019      *
*                                          Performance tuning changes *
*11-Aug-2016  PDEBARU      E2DK918686      Defect # 1952 : Populate   *
*                                          proper pricing for multiple*
*                                          BOM material               *
*---------------------------------------------------------------------*

DATA:
  li_enh_stat   TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Internal table
  li_stko       TYPE STANDARD TABLE OF stko_api02 INITIAL SIZE 0,      " API structure for BOM header: all fields
  lwa_xvbap     TYPE vbapvb,                                           " CR D2_625
  lv_val_low    TYPE fpb_low,                                          " From Value
  lv_bom_usage  TYPE stlan.                                            " BOM Usage


FIELD-SYMBOLS:
        <lfs_s_enh_data> TYPE zdev_enh_status, " Enhancement Status
        <lfs_s_stko>     TYPE stko_api02.      " API structure for BOM header: all fields

CONSTANTS:
   lc_enh_no      TYPE z_enhancement VALUE 'D2_OTC_EDD_0134',          " Enhancement NUMBER
   lc_enh_stat    TYPE z_criteria    VALUE 'NULL',                     " Enh. Criteria
   lc_mat_type    TYPE z_criteria    VALUE 'D2_OTC_EDD_0134_MAT_TYPE', " Enh. Criteria
   lc_bom_usage   TYPE z_criteria    VALUE 'D2_OTC_EDD_0134_BOM_USG'.  " Enh. Criteria

*---> Begin of delete for D2_OTC_EDD_0134 Defect# 1952 by PDEBARU

*IF gv_bom NE 'X'.   "D# 1019
*<--- End of delete for D2_OTC_EDD_0134 Defect# 1952 by PDEBARU
*---> Begin of change for D2_OTC_EDD_0134 Defect# 1952 by PDEBARU
** Binary sort not used due to very low data
READ TABLE i_enh_stat WITH KEY enhanc_no = lc_enh_no
                          TRANSPORTING NO FIELDS.
IF sy-subrc NE 0.

*<--- End of change for D2_OTC_EDD_0134 Defect# 1952 by PDEBARU

* Check Enh is active in EMI tool
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_no
    TABLES
      tt_enh_status     = i_enh_stat.

  DELETE i_enh_stat WHERE active = space.
ENDIF. " IF sy-subrc NE 0
IF i_enh_stat IS NOT INITIAL.
*&-- Check if the enhancment is active
  READ TABLE i_enh_stat TRANSPORTING NO FIELDS WITH KEY criteria = lc_enh_stat.
  IF sy-subrc EQ 0.
    gv_bom = 'X'. "D# 1019
    SORT i_enh_stat BY criteria sel_low.
    CLEAR lv_val_low.
*&-- Check if the material type is maintained in EMI and allowed for further processing

    lv_val_low = maapv-mtart.
    READ TABLE i_enh_stat TRANSPORTING NO FIELDS WITH KEY criteria = lc_mat_type
                                                           sel_low  = lv_val_low
                                                           BINARY SEARCH.
    IF sy-subrc EQ 0.
      READ TABLE i_enh_stat ASSIGNING <lfs_s_enh_data> WITH KEY criteria = lc_bom_usage.
      IF sy-subrc EQ 0.
        lv_bom_usage = <lfs_s_enh_data>-sel_low.
        CALL FUNCTION 'CSEP_MAT_BOM_READ'
          EXPORTING
            material  = xvbap-matnr
            plant     = xvbap-werks
            bom_usage = lv_bom_usage
          TABLES
            t_stko    = li_stko
          EXCEPTIONS
            error     = 1
            OTHERS    = 2.
        IF sy-subrc EQ 0.
          READ TABLE li_stko ASSIGNING <lfs_s_stko> INDEX 1.
          IF sy-subrc EQ 0.
            vbap-stlnr = <lfs_s_stko>-bom_no.
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0

* Begin of Change for CR D2_627
    IF vbap-vgbel IS NOT INITIAL AND
       vbap-uepos IS NOT INITIAL AND
       vbap-stlnr IS INITIAL.
* Read the Higher Level Item ( BoM Header) STLNR first
      READ TABLE xvbap[] INTO lwa_xvbap WITH KEY
                                     posnr = vbap-uepos.
      IF sy-subrc = 0.
        vbap-stlnr = lwa_xvbap-stlnr.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF vbap-vgbel IS NOT INITIAL AND
* End   of Change for CR D2_627

  ENDIF. " IF sy-subrc EQ 0
ENDIF. " IF i_enh_stat IS NOT INITIAL
