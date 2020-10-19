*&---------------------------------------------------------------------*
*& Report  ZOTCC0110B_CON_LIST_EXCLUSION
*&
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCC0110B_CON_LIST_EXCLUSION                          *
* TITLE      :  Order to Cash D2_OTC_CDD_0110_Convert Listing          *
*               exclusion records                                      *
* DEVELOPER  :  Abhishek Gupta                                         *
* OBJECT TYPE:  Conversion Program                                     *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_CDD_0110                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Convert Listing exclusion records                      *
*                                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 12-Sep-2014 AGUPTA3  E2DK904581 INITIAL DEVELOPMENT                  *
* =========== ======== ========== =====================================*
* 12-May-2016 U033808  E1DK917461 D3: Add tables 915 and 922. File deli*
*                                 miter changed to pipe. Add codepage  *
*----------------------------------------------------------------------*
* 19-Jul-2016 U033808  E1DK917461 D3 Defect #2570: Short dump for field*
*                                 g_scount                             *
*&---------------------------------------------------------------------*
*                                      ITC1 Defect Issue fixed         *
* 30-AUG-2016 U033870  E1DK917461      Defect#3488: Picking file       *
*                                      from application server require *
*                                             S_DATASET authorization  *
*&---------------------------------------------------------------------*
* 28-SEP-2016 MGARG   E1DK917461  D3_CR_0062:Added logic for call trans*
*                                 action based on EMI Value. Added more*
*                                 access sequences on selection Screen *
*                                 Added option for downloading error   *
*                                 file to presentation server          *
*&---------------------------------------------------------------------*
* 19-OCT-2016 U029639 E1DK917461  D3_CR_0062_2nd_Change:Make changes in*
*                                 logic to address issues mentioned in *
*                                 defect#3121.                         *
*&---------------------------------------------------------------------*

REPORT zotcc0110b_con_list_exclusion NO STANDARD PAGE HEADING
                                         LINE-SIZE 132
                                         LINE-COUNT 72
                                         MESSAGE-ID zotc_msg.
**top Include
INCLUDE zotcn0110b_con_list_exclu_top. " Include ZOTCC0110B_CON_LIST_EXCLU_TOP

** Common Include for Conversion Programs
INCLUDE zdevnoxxx_common_include. " Include ZDEVNOXXX_COMMON_INCLUDE

** Selection Screen include
INCLUDE zotcn0110b_con_list_exclu_ss. " " Include ZOTCC0110B_CON_LIST_EXCLU_SS

** Subroutine include.
INCLUDE zotcn0110b_con_list_exclu_sub. " Include ZOTCN0110B_CON_LIST_EXCLU_SUB

************************************************************************
*---- AT-SELECTION-SCREEN OUTPUT --------------------------------------*
************************************************************************
AT SELECTION-SCREEN OUTPUT.
*   Modify the screen based on User action.
  PERFORM f_modify_screen.

************************************************************************
*---- AT-SELECTION-SCREEN VALUE REQUEST -------------------------------*
************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_pfile.
  PERFORM f_help_l_path CHANGING p_pfile.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_afile.
  PERFORM f_help_as_path CHANGING p_afile.

* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_dfile.
  PERFORM f_help_l_path CHANGING p_dfile.
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG

************************************************************************
*---- AT-SELECTION-SCREEN VALIDATION ----------------------------------*
************************************************************************
* Validating Input File - Presentation Server
AT SELECTION-SCREEN ON p_pfile.
  IF rb_pres = c_true AND
     p_pfile IS NOT INITIAL.
*     Validating the Input File Name
    PERFORM f_validate_p_file USING p_pfile.

*     Checking for ".TXT" extension.
    PERFORM f_check_extension USING p_pfile.
  ENDIF. " IF rb_pres = c_true AND

* Validating Input File - Application Server
AT SELECTION-SCREEN ON p_afile.
  IF p_afile IS NOT INITIAL.
*     Checking for ".TXT" extension.
    PERFORM f_check_extension USING p_afile.
  ENDIF. " IF p_afile IS NOT INITIAL
*

* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062_2nd_Change by u029639
* Make error file mandatory If file is uploaded from presentation server.
AT SELECTION-SCREEN ON p_dfile.
  IF p_pfile IS NOT INITIAL.
    IF p_dfile IS INITIAL.
      MESSAGE e275. " Error file path is mandatory for presentation server file upload.
    ENDIF. " IF p_dfile IS INITIAL
  ENDIF. " IF p_pfile IS NOT INITIAL
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062_2nd_Change by u029639

*************************************************************************
**---- START-OF-SELECTION ----------------------------------------------*
*************************************************************************
START-OF-SELECTION.

*&--Fetch Constant Values
  PERFORM f_get_constants. "Added for E1DK917461 D3 U033808

*   Checking on File Input
  PERFORM f_check_input.

** Get key combination from selection screen
  PERFORM f_get_key_comb_sub.

* Setting the mode of processing
  PERFORM f_set_mode CHANGING gv_save
                              gv_mode.

* Uploading the file from Presentation Server
  IF rb_pres IS NOT INITIAL.
    gv_file = p_pfile.
    PERFORM f_upload_pres USING gv_file.
  ENDIF. " IF rb_pres IS NOT INITIAL

* Uploading the files from Application Server
  IF rb_app IS NOT INITIAL.
*     If Logical File option is selected.
    IF rb_alog IS NOT INITIAL.
* Retriving physical file paths from logical file name
      PERFORM f_logical_to_physical USING p_alog
                                 CHANGING gv_file.
    ELSE. " ELSE -> IF rb_alog IS NOT INITIAL
      gv_file = p_afile.
    ENDIF. " IF rb_alog IS NOT INITIAL
*-->  Begin of change for Defect#3488 by U033870 on 08/30/2016
**//Check file for authorization
    IF gv_file IS NOT INITIAL.
      PERFORM f_check_file USING gv_file
                           CHANGING gv_file_flag.
      IF gv_file_flag IS NOT INITIAL.
*<-- End of change for Defect#3488 by U033870 on 08/30/2016
*     Uploading the files from Application Server
        PERFORM f_upload_apps USING gv_file.
*-->  Begin of change for Defect#3488 by U033870 on 08/30/2016
      ELSE. " ELSE -> IF gv_file_flag IS NOT INITIAL
*&-- File not accessable
        MESSAGE i950 WITH gv_file. " No authorization for access to file &
        LEAVE LIST-PROCESSING.
      ENDIF. " IF gv_file_flag IS NOT INITIAL
    ENDIF. " IF gv_file IS NOT INITIAL
*<-- End of change for Defect#3488 by U033870 on 08/30/2016
  ENDIF. " IF rb_app IS NOT INITIAL

**   Checking whether the uploaded file is empty or not. If empty, then
**   Stopping program
  IF i_final IS INITIAL.
*   Input file contains no record. Please check your entry.
    MESSAGE i000 WITH 'Input file contains no record.'(037) 'Please check the entry'(038). " & & & &
    LEAVE LIST-PROCESSING.
  ELSE. " ELSE -> IF i_final IS INITIAL
***Input file validation.
    PERFORM f_validation.
  ENDIF. " IF i_final IS INITIAL

**BDC Call for VB01 Transaction
*  IF i_valid IS NOT INITIAL                 "U033808
  IF i_final IS NOT INITIAL "U033808
    AND rb_post IS NOT INITIAL.
*    PERFORM f_vb01_bdc USING    i_valid[]   "U033808
    PERFORM f_vb01_bdc USING    i_final[] "U033808
                       CHANGING i_error[].
  ENDIF. " IF i_final IS NOT INITIAL
*
********************************************************************************
**End of selection event
END-OF-SELECTION.

* Now put the file in error or done folder.
  IF rb_post IS NOT INITIAL AND
    rb_app IS NOT INITIAL.
    PERFORM f_move USING gv_file.
  ENDIF. " IF rb_post IS NOT INITIAL AND

  IF gv_ecount IS NOT INITIAL AND
      rb_pres IS INITIAL AND rb_post IS NOT INITIAL.
* Write the error records in error file
    PERFORM f_write_error_file USING gv_file
                                     i_error[] .
  ENDIF. " IF gv_ecount IS NOT INITIAL AND
*

* ---> Begin of Delete for D3_OTC_CDD_0110_D3_CR_0062_2nd_Change by u029639
* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
* IF gv_ecount IS NOT INITIAL AND p_dfile IS NOT INITIAL .
* ---> End of Delete for D3_OTC_CDD_0110_D3_CR_0062_2nd_Change by u029639

* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062_2nd_Change by u029639
* Downloading Error file to Presentation server
  IF gv_ecount IS NOT INITIAL AND p_dfile IS NOT INITIAL AND rb_post IS NOT INITIAL.
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062_2nd_Change by u029639
    PERFORM f_save_presentation USING i_error[]. "   Save the File on presentation server
  ENDIF. " IF gv_ecount IS NOT INITIAL AND p_dfile IS NOT INITIAL AND rb_post IS NOT INITIAL
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG

  IF i_report IS INITIAL.
    CLEAR wa_report.
    wa_report-msgtyp = c_smsg.
    IF rb_post = c_rbselected.
      wa_report-msgtxt = 'All records are successfully uploaded'(031).
      APPEND wa_report TO i_report.
      CLEAR wa_report.
    ELSE. " ELSE -> IF rb_post = c_rbselected
      wa_report-msgtxt = 'All records are verified and correct'(032).
      APPEND wa_report TO i_report.
      CLEAR wa_report.
    ENDIF. " IF rb_post = c_rbselected
  ENDIF. " IF i_report IS INITIAL

* Now show the summary report
*  PERFORM f_display_summary_report USING i_report  "Commented for D3 defect 2570 by U033808
  PERFORM f_display_summary_report2 USING i_report "Added for D3 defect 2570 by U033808
                                        gv_file
                                        gv_mode
                                        gv_scount
                                        gv_ecount.
