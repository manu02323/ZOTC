*&---------------------------------------------------------------------*
*& Report  ZOTCC0091B_SALESBOM_CONV
*&
*&---------------------------------------------------------------------*
*&**********************************************************************
* PROGRAM    :  ZOTCC0091B_SALESBOM_CONV                               *
* TITLE      :  Sales BOM Conversion                                   *
* DEVELOPER  :  Shoban Mekala                                          *
* OBJECT TYPE:  Conversion Program                                     *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_CDD_0091                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Convert Sales BOM                                      *
*                                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 26-Sep-2014 SMEKALA  E2DK905288 INITIAL DEVELOPMENT                  *
*&
*&---------------------------------------------------------------------*

REPORT zotcc0091b_salesbom_conv NO STANDARD PAGE HEADING
                                  LINE-SIZE 132
                                  LINE-COUNT 72
                                  MESSAGE-ID zotc_msg.

*-- Top Include
INCLUDE zotcc0091b_salesbom_conv_top. " Top Include for Sales BOM Conversion Program

*-- Common Include for Conversion Programs
*INCLUDE zdevotcbom_common_include. " Include ZDEVNOXXX_COMMON_INCLUDE
INCLUDE zdevnoxxx_common_include. " Include ZDEVNOXXX_COMMON_INCLUDE
*-- Selection Screen Include
INCLUDE zotcc0091b_salesbom_conv_sel. " Selection Screen for Sales BOM Conversion Program

*-- Include for sub routines
INCLUDE zotcc0091b_salesbom_conv_sub. " Include for Sub routines

************************************************************************
*     AT-SELECTION-SCREEN OUTPUT                                       *
************************************************************************
AT SELECTION-SCREEN OUTPUT.
*   Modify the screen based on User action.
  PERFORM f_modify_screen.

************************************************************************
*     AT-SELECTION-SCREEN VALIDATION                                   *
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

************************************************************************
*     AT-SELECTION-SCREEN VALUE REQUEST                                *
************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_pfile.
  PERFORM f_help_l_path CHANGING p_pfile.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_afile.
  PERFORM f_help_as_path CHANGING p_afile.
*
*************************************************************************
*      START-OF-SELECTION                                               *
*************************************************************************
START-OF-SELECTION.
*-- Checking on File Input
  PERFORM f_check_input.

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
*     Uploading the files from Application Server
    PERFORM f_upload_apps USING gv_file.
  ENDIF. " IF rb_app IS NOT INITIAL

**   Checking whether the uploaded file is empty or not. If empty, then
**   Stopping program
  IF i_final IS INITIAL.
*   Input file contains no record. Please check your entry.
    MESSAGE i000 WITH 'Input file contains no record.'(007) 'Please check the entry'(008). " & & & &
    LEAVE LIST-PROCESSING.
  ELSE. " ELSE -> IF i_final IS INITIAL
*-- get plants
    PERFORM f_get_plants.
***Input file validation.
    PERFORM f_validation.
  ENDIF. " IF i_final IS INITIAL

**BDC Call for CS01 Transaction(BoM Creation)
  IF i_valid IS NOT INITIAL
     AND rb_post IS NOT INITIAL.
    PERFORM f_execute_bdc USING    i_valid[]
                       CHANGING i_error[].
  ENDIF. " IF i_valid IS NOT INITIAL

*************************************************************************
*        END-OF-SELECTION                                               *
*************************************************************************
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
  IF i_report IS INITIAL.
    CLEAR wa_report.
    wa_report-msgtyp = c_smsg.
    IF rb_post = c_rbselected.
      wa_report-msgtxt = 'All records are successfully uploaded'(019).
      APPEND wa_report TO i_report.
      CLEAR wa_report.
    ELSE. " ELSE -> IF rb_post = c_rbselected
      wa_report-msgtxt = 'All records are verified and correct'(020).
      APPEND wa_report TO i_report.
      CLEAR wa_report.
    ENDIF. " IF rb_post = c_rbselected
  ENDIF. " IF i_report IS INITIAL

* Now show the summary report
  PERFORM f_display_summary_report2 USING i_report
                                         gv_file
                                         gv_mode
                                         gv_scount
                                         gv_ecount.
