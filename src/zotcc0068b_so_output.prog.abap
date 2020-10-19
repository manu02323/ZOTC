*&---------------------------------------------------------------------*
*& Report  ZOTCC0068B_SO_OUTPUT
************************************************************************
* PROGRAM    :  ZOTCC0068B_SO_OUTPUT                                   *
* TITLE      :  OTC_CDD_0068B SALES ORDER OUTPUT                       *
* DEVELOPER  :  Pallavi Gupta                                          *
* OBJECT TYPE:  Conversion                                             *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  OTC_CDD_0068_Sales Order Output Conversion             *
*----------------------------------------------------------------------*
* DESCRIPTION: Uploading Conditional Records into SAP from text file   *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 06-JUN-2012 PGUPTA2    E1DK901630 INITIAL DEVELOPMENT                *
*&---------------------------------------------------------------------*
* 06-JUN-2012 ASK        E1DK906733 Defect 380, remove hardcoding for  *
*                                   key combination starting with Z855 *
* 23-JUN-2014 KNAMALA    E2DK901634 D2 Changes, Condition Type Z855    *
*                                   to Accommodate the Keycombination  *
*                                   changes                            *
* 21-OCT-2014 PGOLLA     E2DK901634 Incorrect validation results for
*                                   table 909 in CDD 0068 program and
*                                   transfer of incorrect records
* 24-Dec-2014 SMEKALA    E2DK901634 Defect: 1889 Include soldto, shipto*
*                                   Partner fn values in error message *
*---------------------------------------------------------------------*



 REPORT  zotcc0068b_so_output  NO STANDARD PAGE HEADING
                               LINE-SIZE 132
                               MESSAGE-ID zotc_msg.

************************************************************************
*---- INCLUDES --------------------------------------------------------*
************************************************************************
* Top Include
 INCLUDE zotcn0068b_modify_top.
* Selection Screen Include
 INCLUDE zdevnoxxx_common_include.
*Include for selection screen
 INCLUDE zotcn0068b_modify_selscrn.
* Include for all subroutines
 INCLUDE zotcn0068b_modify_form.

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
   IF rb_pres = c_true AND
      p_pfile IS NOT INITIAL.

*Validating the File Name
     PERFORM f_validate_p_file USING p_pfile.
*     Checking for "CSV" extension.
     PERFORM f_check_extension USING p_pfile.

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

*   Setting the mode of processing
   PERFORM f_set_mode CHANGING gv_mode.

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
     MESSAGE i012.
     LEAVE LIST-PROCESSING.
   ELSE.
* Retrieving the data for validation
     PERFORM f_data USING i_modify[].

   ENDIF.

************************************************************************
*---- END-OF-SELECTION ----------------------------------------------*
************************************************************************

 END-OF-SELECTION.
*Validation of the input data
   PERFORM f_val USING i_modify[]
              CHANGING i_final[]
                       i_report[]
                       i_error[].

   IF rb_post IS NOT INITIAL AND
      i_final IS NOT INITIAL.
*Uploading the data
     PERFORM f_assign_vv11  USING i_final[]
                         CHANGING i_report[]
                                  i_error[].

   ENDIF.


*   In case the file was uploaded from Application server, then
*   Moving them in Processed / Error folder depending upon Final
*   Status of Posting.
   IF rb_app  IS NOT INITIAL.
     IF rb_post IS NOT INITIAL.
*     If Posting is done, then moving the files to DONE folder
*       Moving Input File
       PERFORM f_move USING gv_modify
                       CHANGING i_report[].
     ENDIF.
*     In case of error, passing it to Error folder.
*       Moving Error File
     IF gv_err_flg IS NOT INITIAL.
       IF i_error IS NOT INITIAL.
         PERFORM f_move_error USING gv_modify
                                    i_error[].
       ENDIF.
     ENDIF.
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

*Counting the success records
   DESCRIBE TABLE i_modify[] LINES gv_line.
   gv_scount = gv_line - gv_ecount.

*   Displaying The Log Report
   IF i_report[] IS NOT INITIAL.
     PERFORM f_display_summary_report USING i_report[]
                                            gv_modify
                                            gv_mode
                                            gv_scount
                                            gv_ecount.
   ENDIF.
