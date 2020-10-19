************************************************************************
* PROGRAM    :  ZOTCC0069B_BILLING_OUTPUT                              *
* TITLE      :  OTC_CDD_0069B BILLING OUTPUT                           *
* DEVELOPER  :  ANKIT PURI                                             *
* OBJECT TYPE:  Conversion                                             *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  OTC_CDD_0069                                           *
*----------------------------------------------------------------------*
* DESCRIPTION:  BILLING OUTPUT CONVERSION                              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 19-MAY-2012 APURI    E1DK901634 INITIAL DEVELOPMENT                  *
* 23-Dec-2014 SMEKALA  E2DK907954 D2: Add new billing condition types  *
* 23-MAY-2016 U033830  E1DK918109 D3:1.Add new condition types:        *
*                                      ZED1 and ZEIN.                  *
*                                 2. Remove upload for table B911 for  *
*                                    conditions ZRD1 and ZRD0.         *
************************************************************************
*&---------------------------------------------------------------------*

REPORT  zotcc0069b_billing_output NO STANDARD PAGE HEADING
        LINE-SIZE 132
        LINE-COUNT 72
        MESSAGE-ID zotc_msg.

************************************************************************
*---- INCLUDES --------------------------------------------------------*
************************************************************************
* Top Include
INCLUDE zotcn0069b_modify_top.
* Selection Screen Include
INCLUDE zdevnoxxx_common_include.
*Include for selection screen having a file to process
INCLUDE zotcn0069b_modify_selscrn.
* Include for all subroutines
INCLUDE zotcn0069b_modify_form.

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

***********************************************************************
*--- AT-SELECTION-SCREEN VALIDATION ----------------------------------*
***********************************************************************
*Validating Input File - Presentation Server
AT SELECTION-SCREEN ON p_pfile.
  IF rb_pres = c_true.
    IF p_pfile IS NOT INITIAL.
*Validating the File Name
      PERFORM f_validate_p_file USING p_pfile.
*     Checking for ".CSV" extension.
      PERFORM f_check_extension USING p_pfile.
    ENDIF.
  ENDIF.

* Validating Input File - Application Server
AT SELECTION-SCREEN ON p_afile.
  IF p_afile IS NOT INITIAL.
*Checking for ".CSV" extension.
    PERFORM f_check_extension USING p_afile.
  ENDIF.

************************************************************************
*---- START-OF-SELECTION ----------------------------------------------*
************************************************************************
START-OF-SELECTION.
*  Checking on File Input.
  PERFORM f_check_input.

*   Uploading the files from Presentation Server
  IF rb_pres IS NOT INITIAL.
    gv_modify = p_pfile.

*     Uploading the file from Presentation Server
    PERFORM f_upload_presnt_files USING gv_modify
                               CHANGING i_modify[].
  ENDIF.

*   Uploading the files from Application Server
  IF rb_app IS NOT INITIAL.
*     If Logical File option is selected.
    IF rb_alog IS NOT INITIAL.
*       Retriving physical file paths from logical file name
      PERFORM f_logical_to_physical USING p_alog
                              CHANGING gv_modify.
    ELSE.
      gv_modify = p_afile.
    ENDIF.
*     Uploading the file from Application Server
    PERFORM f_upload_applcn_files USING gv_modify
                               CHANGING i_modify[].
  ENDIF.

*  Checking whether the uploaded file is empty or not. If empty, then
*   Stop the execution of program
  IF i_modify IS INITIAL.
*   Input file contains no record. Please check your entry.
    MESSAGE i000 WITH 'Input file contains no record'(034).
    LEAVE LIST-PROCESSING.
  ENDIF.

* Performing Validations on the input data
  PERFORM f_validation.
* Only in verify and post mode session will get created
  IF rb_post IS NOT INITIAL.
* Performing recording for the transaction VV31
    PERFORM f_bdcrecord_vv31 USING    i_final[]
                             CHANGING i_error[]
                                      gv_ecount
                                      gv_scount
                                      i_report.
  ENDIF.

************************************************************************
*---- END-OF-SELECTION ----------------------------------------------*
************************************************************************

END-OF-SELECTION.
*   In case the file was uploaded from Application server, then
*   Moving them in Processed / Error folder depending upon Final
*   Status of Posting.
  IF rb_app IS NOT INITIAL AND
     rb_post IS NOT INITIAL.
*     If Posting is done, then moving the files to DONE folder
*       Moving Input File
    PERFORM f_move USING gv_modify.
*     In case of error, passing it to Error folder.
*       Moving Error File
    IF i_error IS NOT INITIAL.
      PERFORM f_move_error USING gv_modify
                                 i_error[].
    ENDIF.
  ENDIF.

* Choose the Mode (either Verify only or Verify & Post Mode)
  IF rb_post = c_rbselected .
    gv_mode = 'Post Run'(013).
  ELSE.
    gv_mode = 'Test Run'(014).
  ENDIF.

  IF i_report IS INITIAL.
    CLEAR wa_report.
    wa_report-msgtyp = c_success.
    IF rb_post = c_true.
      wa_report-msgtxt = 'All records are successfully uploaded'(015).
      APPEND wa_report TO i_report.
      CLEAR wa_report.
    ELSE.
      wa_report-msgtxt = 'All records are verified and correct'(016).
      APPEND wa_report TO i_report.
      CLEAR wa_report.
    ENDIF.
  ENDIF.

*   Displaying The Log Report
  IF i_report[] IS NOT INITIAL.
    PERFORM f_display_summary_report USING i_report
                                           gv_modify
                                           gv_mode
                                           gv_scount
                                           gv_ecount.
  ENDIF.
