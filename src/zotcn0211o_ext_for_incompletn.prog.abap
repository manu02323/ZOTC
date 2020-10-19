************************************************************************
* PROGRAM    :  ZOTCN0211O_EXT_FOR_INCOMPLETN(Include)                 *
* TITLE      :  User Exit for Incompletion                             *
* DEVELOPER  :  Kriti Srivastava                                       *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D2_OTC_EDD_0211                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: User Exit for Incompletion
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER     TRANSPORT  DESCRIPTION                         *
* ===========  ======== ========== ====================================*
* 08-AUG-2014  KSRIVAS E2DK903204  INITIAL DEVELOPMENT                 *
* If Product Attribute 5 for the material(MVKE-PRAT5) is ticked,       *
* then check whether Quote Number (VBAP-ZZQUOTEREF) for the material   *
* is populated, if not then generate incompletion log with item detail *
*&---------------------------------------------------------------------*
* 08-DEC-2014  SSAURAV E2DK903204  CR D2_289                           *
* If Product Attribute 1 for the material(MVKE-PRAT1) is ticked,       *
* then check whether Quote Number (VBAP-ZZQUOTEREF) for the material   *
* is populated, if not then generate incompletion log with item detail *
*&---------------------------------------------------------------------*

************************************************************************
*============================Data Declaration==========================*
************************************************************************

* Data Declaration
DATA: li_enh_status  TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Internal table
      lwa_vbuv       TYPE vbuvvb.                                           " Structure for Internal Table XVBUV

*Field symbol declaration
FIELD-SYMBOLS: <lfs_vbap_item>     TYPE vbapvb,          " Document Structure for XVBAP/YVBAP
               <lfs_enh_status>    TYPE zdev_enh_status, " Enhancement Status
               <lfs_vbuv>          TYPE vbuvvb.          " Structure for Internal Table XVBUV

* Constants Declaration
CONSTANTS: lc_tabnam       TYPE tbnam_vb VALUE 'VBAP',                 " Table for documents in sales and distribution
           lc_fldnam       TYPE fdnam_vb VALUE 'ZZQUOTEREF' ,          " Document field name
           lc_statg_val    TYPE statg    VALUE '04',                   " Status group
* ---> Begin of Change/Insert/Delete for CR D2_289  by SSAURAV
*          lc_prat5_val    TYPE prat5    VALUE 'X',                    " ID for product attribute 5
           lc_prat1_val    TYPE prat1    VALUE 'X',                    " ID for product attribute 1
* <--- End    of Change/Insert/Delete for CR D2_289  by SSAURAV
           lc_upd_ind      TYPE updkz_d  VALUE 'I',                    " Update indicator
           lc_enhancem_no  TYPE z_enhancement VALUE 'D2_OTC_EDD_0211', " Enhancement NUMBER
           lc_fcode_pzku   TYPE fcode_fe      VALUE 'PZKU',            " Focde_pzku of type Byte fields
           lc_active_stat  TYPE z_criteria    VALUE 'NULL'.            " Enh. Criteria

************************************************************************
*============================Processing Logic==========================*
************************************************************************

*Check Enh is active in EMI tool
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_enhancem_no
  TABLES
    tt_enh_status     = li_enh_status.

*We select only the active entries.
DELETE li_enh_status WHERE active = space.

*If enh is active in EMI Tool
IF li_enh_status IS NOT INITIAL.

*Get the active status from EMI tool
  READ TABLE li_enh_status ASSIGNING <lfs_enh_status>
                         WITH KEY criteria = lc_active_stat.
  IF sy-subrc = 0.

* If the line item material PRAT5 is having value 'X'
* ---> Begin of Change/Insert/Delete for CR D2_289  by SSAURAV
*   IF maapv-prat5 = lc_prat5_val.
    IF maapv-prat1 = lc_prat1_val.
* <--- End    of Change/Insert/Delete for CR D2_289  by SSAURAV

*Check if item ref. field for the line item is not entered
      IF vbap-zzquoteref IS INITIAL.
*Read table xvbuv to check if there is an incomplete log entry alredy exist
        READ TABLE xvbuv ASSIGNING <lfs_vbuv> WITH KEY vbeln = vbak-vbeln
                                                       posnr = vbap-posnr
                                                       tbnam = lc_tabnam
                                                       fdnam = lc_fldnam.
*If entry not found, prepare the incompletion log
        IF sy-subrc <> 0.
          lwa_vbuv-vbeln = vbak-vbeln.
          lwa_vbuv-posnr = vbap-posnr.
          lwa_vbuv-tbnam = lc_tabnam.
          lwa_vbuv-fdnam = lc_fldnam.
          lwa_vbuv-fehgr = tvap-fehgr.
          lwa_vbuv-statg = lc_statg_val.
          lwa_vbuv-updkz = lc_upd_ind .
*Passing the Fcode for newly added line for Screen Additional data B
          lwa_vbuv-fcode = lc_fcode_pzku.
*Append the incomplete record to the table XVBUV
          APPEND lwa_vbuv TO xvbuv.
          CLEAR: lwa_vbuv.
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF vbap-zzquoteref IS INITIAL
    ENDIF. " IF maapv-prat1 = lc_prat5_val
*    ENDIF. " IF xvbap[] IS NOT INITIAL
  ENDIF. " IF sy-subrc = 0
ENDIF. " IF li_enh_status IS NOT INITIAL
