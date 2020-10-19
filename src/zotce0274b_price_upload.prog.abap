*&---------------------------------------------------------------------*
*& Report  ZOTC_EDD0274_PRICE_UPLOAD
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
* DESCRIPTION: Pricing Upload program for pricing condition            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER     TRANSPORT  DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 18-Aug-2015  MGARG    E2DK913959 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
*01-Dec-2015   VCHOUDH  E2DK916237  Defect 1264.
*Check if the pricing condition type is of discount type
* T685A-KNEGA = 'X'. If so, then if there is no negative sign in the
* value it will be converted to negative value
*&---------------------------------------------------------------------*

REPORT zotce0274b_price_upload NO STANDARD PAGE HEADING
                               LINE-SIZE 132
                               MESSAGE-ID zotc_msg.
* Common Include
INCLUDE zdevnoxxx_common_include. " Include ZDEVNOXXX_COMMON_INCLUDE
* Top Include
INCLUDE zotcn0274b_price_upload_top. " Include ZOTCN0274B_PRICE_UPLOAD_TOP
* Selection Screen Include
INCLUDE zotcn0274b_price_upload_ss. " Include ZOTCN0274B_PRICE_UPLOAD_SS
*Subroutine Include
INCLUDE zotcn0274b_price_upload_sub. " Include ZOTCN0274B_PRICE_UPLOAD_SUB

************************************************************************
*---- AT-SELECTION-SCREEN OUTPUT        -------------------------------*
************************************************************************
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
* If Create Idoc radio button is choosen then disable file parameter
    IF rb_cidoc = c_rbselect.
      CLEAR p_pfile.
      IF screen-group1 = c_mod.
        screen-input = '0'.
        MODIFY SCREEN.
        CLEAR p_pfile.
      ENDIF. " IF screen-group1 = c_mod
    ELSE. " ELSE -> IF screen-group1 = c_mod
      IF screen-group1 = c_mod.
        screen-input = '1'.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_mod
    ENDIF. " IF rb_cidoc = c_rbselect
  ENDLOOP. " LOOP AT SCREEN

************************************************************************
*---------------AT-SELECTION-SCREEN     -------------------------------*
************************************************************************
AT SELECTION-SCREEN.
  IF sy-ucomm = c_ucomm.
*    IF rb_post = c_rbselect OR rb_vrfy = c_rbselect.  "Commented by SNIGAM on 9/25
    IF rb_post = c_rbselect . "Added by SNIGAM on 9/25
      IF p_pfile IS INITIAL.
        MESSAGE i947(zotc_msg) DISPLAY LIKE c_s. " Please enter the File.
        LEAVE LIST-PROCESSING.
      ENDIF. " IF p_pfile IS INITIAL
    ELSE. " ELSE -> IF p_pfile IS INITIAL
      CLEAR p_pfile.
    ENDIF. " IF sy-ucomm = c_ucomm
  ENDIF. " IF sy-ucomm = c_ucomm
************************************************************************
*---- AT-SELECTION-SCREEN VALUE REQUEST -------------------------------*
************************************************************************

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_pfile.
* Provide F4 help for presentation server path
  PERFORM f_help_l_path CHANGING p_pfile.

************************************************************************
*---- AT-SELECTION-SCREEN VALIDATION ----------------------------------*
************************************************************************

AT SELECTION-SCREEN ON p_pfile.
* Validating Input-file- presentation server
  IF p_pfile IS NOT INITIAL.
* Perform File Path and Extension validation
    PERFORM f_check_file USING p_pfile.
  ENDIF. " IF p_pfile IS NOT INITIAL

*----------------------------------------------------------------------*
*     START OF SELECTION
*----------------------------------------------------------------------*

START-OF-SELECTION.

* Fetch EMI value
  PERFORM f_fetch_emi_val.

* If Create idoc radio button is not checked then only Read the file from Presentation server
* and proceed further for validation else pick the files from application server and
* create IDOC
  IF rb_cidoc IS INITIAL.

* Read File From presentation server and File Validation
    PERFORM f_upload_and_validation USING p_pfile.

* Upload File to application server, if radio button post is checked*
    IF rb_post = c_rbselect.
      IF i_ereport IS INITIAL.
        PERFORM f_writeto_app_server.
        MESSAGE i952(zotc_msg) DISPLAY LIKE c_s. " Records are successfully posted to application server
        LEAVE LIST-PROCESSING.
      ELSE. " ELSE -> IF i_ereport IS INITIAL
* Display file summary
        PERFORM f_display_summ_report.
      ENDIF. " IF i_ereport IS INITIAL
* Begin of Comment by SNIGAM on 09/25
*    ELSEIF rb_vrfy = c_rbselect. " ELSE -> IF rb_post = c_rbselect
*      IF i_ereport IS NOT INITIAL.
** Display file summary
*        PERFORM f_display_summ_report.
*      ELSE. " ELSE -> IF i_ereport IS NOT INITIAL
*        MESSAGE i955(zotc_msg) DISPLAY LIKE c_s. " All records are verified and correct
*        LEAVE LIST-PROCESSING.
*      ENDIF. " IF i_ereport IS NOT INITIAL
* End of Comment by SNIGAM on 09/25
    ENDIF. " IF rb_post = c_rbselect

  ELSE. " ELSE -> IF rb_post = c_rbselect

* call program with selection parameter as Logical path  which is coming
* from EMI tool

    SUBMIT zotce0274b_price_upload_gidoc
         WITH p_lfpath = gv_lpath.

  ENDIF. " IF rb_cidoc IS INITIAL
