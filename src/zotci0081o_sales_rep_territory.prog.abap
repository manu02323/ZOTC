************************************************************************
* PROGRAM    :  ZOTCI0081O_SALES_REP_TERRITORY                         *
* TITLE      :  OTC_IDD_0081 UPLOAD SALES REP TERRITORY                *
* DEVELOPER  :  ANKIT PURI                                             *
* OBJECT TYPE:  INTERFACE                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  OTC_IDD_0081                                           *
*----------------------------------------------------------------------*
* DESCRIPTION:  Upload sales rep territory assignment                  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT    DESCRIPTION                      *
* ===========  ========  ==========   =================================*
* 27-JUNE-2012 APURI     E1DK903418   INITIAL DEVELOPMENT              *
*----------------------------------------------------------------------*

REPORT  zotci0081o_sales_rep_territory NO STANDARD PAGE HEADING
        LINE-SIZE 132
        MESSAGE-ID zotc_msg.


************************************************************************
*---- INCLUDES --------------------------------------------------------*
************************************************************************

* Top Include
INCLUDE zotcn0081o_sales_rep_top.
* Common Include
INCLUDE zdevnoxxx_common_include.
* Include for selection screen having a file to process
INCLUDE zotcn0081o_sales_rep_selscrn.
* Include for all subroutines
INCLUDE zotcn0081o_sales_rep_form.

************************************************************************
*---- AT-SELECTION-SCREEN VALUE REQUEST -------------------------------*
************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_pfile.
  PERFORM f_help_l_path CHANGING p_pfile.

***********************************************************************
*--- AT-SELECTION-SCREEN VALIDATION ----------------------------------*
***********************************************************************
*Validating Input File - Presentation Server
AT SELECTION-SCREEN ON p_pfile.
  IF p_pfile IS NOT INITIAL.
*   Validating the File Name
    PERFORM f_validate_p_file USING p_pfile.
*   Checking for ".XLS" extension.
    PERFORM f_check_extension USING p_pfile.
  ENDIF.

************************************************************************
*---- START-OF-SELECTION ----------------------------------------------*
************************************************************************
START-OF-SELECTION.
* Uploading the file from Presentation Server
  PERFORM f_upload_presnt_files USING    p_pfile
                                CHANGING i_input[].

* Checking whether the uploaded file is empty or not. If empty, then
* Stop the execution of program
  IF i_input IS INITIAL.
*   Input file contains no record. Please check your entry.
    MESSAGE i000 WITH 'Input file contains no record'(031).
    LEAVE LIST-PROCESSING.
  ENDIF.

* Retrieve value from DB for input file validation.
  PERFORM f_get_db_values .

* Performing Validations on the input data
  PERFORM f_validate_input .

* Posting of data from input file into databese tabel
* will take place only when verify and post radio button is
* selected
  IF rb_post IS NOT INITIAL AND
  gv_scount IS  NOT INITIAL.
    PERFORM f_insert_into_table.
  ENDIF.

************************************************************************
*---- END-OF-SELECTION ------------------------------------------------*
************************************************************************

END-OF-SELECTION.

* Choose the Mode (either Verify only or Verify & Post Mode)
* Populate the gv_mode variable with mode of run.
  IF rb_post = c_rbselected .
    gv_mode = 'Post Run'(032).
  ELSE.
    gv_mode = 'Test Run'(033).
  ENDIF.

* If all the records are success records and report table is initial
* all the records will be verified .
  IF gv_ecount IS INITIAL.
    CLEAR wa_report.
    wa_report-msgtyp = c_success.
    IF rb_post = c_true.
      wa_report-msgtxt = 'All records are successfully uploaded'(034).
      APPEND wa_report TO i_report.
      CLEAR wa_report.
    ELSE.
      wa_report-msgtxt = 'All records are verified and correct'(035).
      APPEND wa_report TO i_report.
      CLEAR wa_report.
    ENDIF.
  ENDIF.
* Displaying The Log Report
  IF i_report[] IS NOT INITIAL.
    PERFORM f_display_summary_report USING i_report
                                           p_pfile
                                           gv_mode
                                           gv_scount
                                           gv_ecount.
  ENDIF.
