*&---------------------------------------------------------------------*
*& Report  ZOTCE0274B_PRICE_UPLOAD_GIDOC
*&
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCE0274B_PRICE_UPLOAD                                *
* TITLE      :  D2_OTC_EDD_0274_Pricing upload program for pricing cond*
* DEVELOPER  :  Monika Garg                                            *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_EDD_0274                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: Pricing Upload program for pricing condition  (Part 2)  *
* Program will read all the files from specified folder of application *
* server and create the IDOC which will Insert/update/Delete the       *
* condition records.
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER     TRANSPORT  DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 18-Aug-2015  MGARG    E2DK913959 INITIAL DEVELOPMENT                 *
* 16-Sep-2015  MGARG    E2DK913959 Defect D2_959 PGL, Issues during the*
*                                  pricing upload.                     *
*&---------------------------------------------------------------------*

REPORT zotce0274b_price_upload_gidoc NO STANDARD PAGE HEADING
                                     LINE-SIZE 132
                                     MESSAGE-ID zotc_msg.
*Selection Screen Include
INCLUDE zotcn0274b_price_gidoc_ss. " Include ZOTCN0274B_PRICE_GIDOC_SS
* Top Include
INCLUDE zotcn0274b_price_gidoc_top. " Include ZOTCN0274B_PRICE_UPLOAD_TOP
*Subroutine include
INCLUDE zotcn0274b_price_gidoc_sub. " Include ZOTCN0274B_PRICE_UPLOAD_SUB

************************************************************************
*---- AT SELECTION-SCREEN OUTPUT --------------------------------------*
************************************************************************
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'MI'.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDIF. " IF screen-group1 = 'MI'
  ENDLOOP. " LOOP AT SCREEN
* get Physical path
  PERFORM f_get_phy_path  USING    p_lfpath
                          CHANGING p_pfapth.

************************************************************************
*---- START-OF-SELECTION ----------------------------------------------*
************************************************************************
START-OF-SELECTION.

* Fetch data from EMI table
  PERFORM f_fetch_emi.

* Get Logical System
  PERFORM f_get_log_sys.

* Get all the Files from directory
  PERFORM f_get_files_frm_dir.
