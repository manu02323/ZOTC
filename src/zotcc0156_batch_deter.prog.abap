*&---------------------------------------------------------------------*
* REPORT ZOTCC0156_BATCH_DETER
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* PROGRAM    : ZOTCC0156_BATCH_DETER                                   *
* TITLE      :D3_OTC_CDD_0156_Convert Batch Determination Records      *
* DEVELOPER  : Jahan Mazumder
* OBJECT TYPE:  Conversion                                             *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID: D3_OTC_CDD_0156
*----------------------------------------------------------------------*
* DESCRIPTION: Convert Batch Determination Records                     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER     TRANSPORT  DESCRIPTION                         *
* ===========  ======== ========== ====================================*
*06/01/2016   U029639   E1DK917995 Initial Development
*
*----------------------------------------------------------------------*
REPORT zotc_cdd_0156 MESSAGE-ID zotc_msg
LINE-COUNT 80
LINE-SIZE 132
NO STANDARD PAGE HEADING.

*----------------------------------------------------------------------*
*     INCLUDES
*----------------------------------------------------------------------*
* Top Include
INCLUDE zotcn0156b_batch_deter_top. " Include ZOTCN0156B_BATCH_DETER_TOP

* Common Include for Conversion Programs
INCLUDE zdevnoxxx_common_include. " Include ZDEVNOXXX_COMMON_INCLUDE

* Selection Screen Include
INCLUDE zotcn0156b_batch_deter_sel. " Include ZOTCN0156B_BATCH_DETER_SEL

* Subroutine include.
INCLUDE zotcn0156b_batch_deter_sub. " Include ZOTCN0156B_BATCH_DETER_SUB

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


************************************************************************
*---- AT-SELECTION-SCREEN VALIDATION ----------------------------------*
************************************************************************
* Validating Input File - Presentation Server
AT SELECTION-SCREEN ON p_pfile.
  IF rb_pres = c_true AND
     p_pfile IS NOT INITIAL.
* Validating the Input File Name
    PERFORM f_validate_p_file USING p_pfile.

* Checking for ".TXT" extension.
    PERFORM f_check_extension USING p_pfile.
  ENDIF. " IF rb_pres = c_true AND

* Validating Input File - Application Server
AT SELECTION-SCREEN ON p_afile.
  IF p_afile IS NOT INITIAL.
* Checking for ".TXT" extension.
    PERFORM f_check_extension USING p_afile.
  ENDIF. " IF p_afile IS NOT INITIAL


*--------------------------------------------------------------------*
* START OF SELECTIOn
*--------------------------------------------------------------------*
START-OF-SELECTION.

* Fetch Constant Values
  PERFORM f_get_constants.

* Checking on File Input
  PERFORM f_check_input.

* Get key combination from selection screen
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
*     Uploading the files from Application Server
    PERFORM f_upload_apps USING gv_file.
  ENDIF. " IF rb_app IS NOT INITIAL

**   Checking whether the uploaded file is empty or not. If empty, then
**   Stopping program
  IF i_final IS INITIAL.
*   Input file contains no record. Please check your entry.
    MESSAGE i000 WITH 'Input file contains no record'(037) 'Please check the entry'(038). " & & & &
    LEAVE LIST-PROCESSING.
  ELSE. " ELSE -> IF i_final IS INITIAL
***Input file validation.
    PERFORM f_validation.
  ENDIF. " IF i_final IS INITIAL

**BDC Call for VB01 Transaction
  IF i_valid IS NOT INITIAL
     AND rb_post IS NOT INITIAL.
    PERFORM f_vch01_bdc USING    i_valid[]
                        CHANGING i_error[].
  ENDIF. " IF i_valid IS NOT INITIAL

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
  PERFORM f_display_summary_report USING i_report
                                         gv_file
                                         gv_mode
                                         gv_scount
                                         gv_ecount.
