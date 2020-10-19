*&---------------------------------------------------------------------*
*& Program      ZOTCE0285B_SORD_ATP_CHECK
*&
************************************************************************
* PROGRAM    :  ZOTCE0285B_SORD_ATP_CHECK                              *
* TITLE      :  ATP Check for Sales orders                             *
* DEVELOPER  :  Dhanasekar Arumugam                                    *
* OBJECT TYPE:  Program                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
*  WRICEF ID :  D2_OTC_EDD_0285                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: This is a BDC program to run ATP check                  *
* using Call Transaction to VA02.                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 05-OCT-2015 DARUMUG  E2DK915626  INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
REPORT zotce0285b_sord_atp_check
          NO STANDARD PAGE HEADING
          LINE-SIZE 132
          LINE-COUNT 70
          MESSAGE-ID zotc_msg.

************************************************************************
*               INCLUDE DECLARATION
************************************************************************
* TOP INCLUDE
INCLUDE zotce0285b_sord_atp_check_top.
* Common Include for Conversion Programs
INCLUDE zdevnoxxx_common_include. " Include ZDEVNOXXX_COMMON_INCLUDE
* Selection Screen Include
INCLUDE zotce0285b_sord_atp_check_sel.
* Include for all subroutines
INCLUDE zotce0285b_sord_atp_check_form.

************************************************************************
*           AT-SELECTION-SCREEN OUTPUT
************************************************************************
AT SELECTION-SCREEN OUTPUT.
* Modify the screen based on User action.
  PERFORM f_modify_screen.

************************************************************************
*          AT-SELECTION-SCREEN VALUE REQUEST
************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_pfile.
  PERFORM f_help_l_path CHANGING p_pfile.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_afile.
  PERFORM f_help_as_path CHANGING p_afile.

***********************************************************************
*         AT-SELECTION-SCREEN VALIDATION
************************************************************************
* Validating Input File - Presentation Server
AT SELECTION-SCREEN ON p_pfile.

  IF rb_pres = c_true AND
     p_pfile IS NOT INITIAL.

** Selection Screen mandatory Check has done in PERFORM f_check_input.
*   Validating the Input File Name
    PERFORM f_validate_p_file USING p_pfile.
*   Checking for ".TXT" extension.
    PERFORM f_check_extension USING p_pfile.
  ENDIF. " IF rb_pres = c_true AND

* Validating Input File - Application Server
AT SELECTION-SCREEN ON p_afile.

  IF rb_app IS NOT INITIAL.
    IF p_afile IS NOT INITIAL.
*   Checking for ".TXT" extension.
      PERFORM f_check_extension USING p_afile.
    ENDIF. " IF p_afile IS NOT INITIAL
  ENDIF. " IF rb_app IS NOT INITIAL

* Validating Logical filename - Application Server
AT SELECTION-SCREEN ON p_alog.

  PERFORM f_validate_logicalpath USING p_alog.

************************************************************************
*         START-OF-SELECTION
************************************************************************
START-OF-SELECTION.
* Check if job run in background mode with presentation server
  IF rb_pres = abap_true AND
     p_pfile IS NOT INITIAL.
    IF sy-batch IS NOT INITIAL.
      MESSAGE i164. " Presentation server cannot be chosen in background mode
      LEAVE LIST-PROCESSING.
    ENDIF. " IF sy-batch IS NOT INITIAL
  ENDIF. " IF rb_pres = abap_true AND

*  * Checking on File Input
  PERFORM f_check_input.

*  * Setting the mode of processing
  PERFORM f_set_mode CHANGING gv_mode.

** Uploading the file from Presentation Server.

  IF rb_pres IS NOT INITIAL AND rb_sord IS INITIAL.
    CLEAR gv_file.
    REFRESH i_input.
    gv_file = p_pfile.
    PERFORM f_upload_pres USING    gv_file
                          CHANGING i_input[].
  ENDIF. " IF rb_pres IS NOT INITIAL

*  * Uploading the files from Application Server
  IF rb_app IS NOT INITIAL.
    PERFORM f_get_apps_server CHANGING gv_file
                                       i_input.
  ENDIF. " IF rb_app IS NOT INITIAL

  IF rb_sord EQ c_true.
    PERFORM fill_input.
*Successful & error count for validation in verify mode report
    CLEAR: gv_scount,
           gv_ecount.
*   Validating Input File
    PERFORM f_validate_input CHANGING i_report[].
  ELSE.
* Checking whether the uploaded file is empty or not. If empty, then
* Stopping program
    IF i_input IS INITIAL.
*   Input file contains no record. Please check your entry.
      MESSAGE i012. " Input file contains no record, check entry
      LEAVE LIST-PROCESSING.
    ELSE. " ELSE -> IF i_input IS INITIAL
* Validation for External File Fileds with DB.
*Deleting the header record of the input table.
*    DELETE i_input INDEX 1.

*Successful & error count for validation in verify mode report
      CLEAR: gv_scount,
             gv_ecount.
*   Validating Input File
      PERFORM f_validate_input CHANGING i_report[].
    ENDIF. " IF i_input IS INITIAL
  ENDIF.
***********************************************************************
*        END-OF-SELECTION
***********************************************************************

END-OF-SELECTION.

* Posting can only be done when 'Verify & Post'
* radio-button is checked
  IF i_final IS NOT INITIAL
    AND rb_post = c_true.

*    Call Transaction to update VA02
    PERFORM f_so_atp_check USING    i_final
                          CHANGING gv_scount
                                   gv_ecount .

  ENDIF. " IF i_final IS NOT INITIAL

* In case the file was uploaded from Application server, then
* Moving them in Processed / Error folder depending upon Final
* Status of Posting.
  PERFORM f_move_files USING gv_file.


* Displaying The Log Report
  IF i_report[] IS NOT INITIAL.
    PERFORM f_display_summary_report  USING i_report[]
                                            gv_file
                                            gv_mode
                                            gv_scount
                                            gv_ecount.

  ENDIF. " IF i_report[] IS NOT INITIAL

*  * Subroutine to clear global internal tables
  PERFORM f_clear.
