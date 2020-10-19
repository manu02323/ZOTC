***********************************************************************
*Program    : ZOTCR344B_TRANSFER_BATCH_GTS                            *
*Title      : Transfer batch to GTS                                   *
*Developer  : Ayushi Jain                                             *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_EDD_0344                                           *
*---------------------------------------------------------------------*
*Description:Utility program to upload batch data in custom table     *
*            ZOTC_REST_BATCH and also update project master table in  *
*            GTS with batch data.                                     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*17-JUN-2016  U033830       E1DK918373      Initial Development       *
*25-JULY-2016 SBEHERA       E1DK918373      Defect#2932: 1.Changed By,*
*                           Changed On, and Changed Time  - To be auto*
*                           updated and to be Grey-out in display and *
*                           change mode on maintenance screen         *
*                                           2.Created By, Created On, *
*                           and Created Time  - To be auto updated and*
*                           to be Grey-out in display and change mode *
*                           on  maintenance screen.                   *
*                                           ITC1 Defect Issue fixed   *
*29-AUG-2016 SBEHERA        E1DK918373      Defect#3396: Picking file *
*                                           from application server   *
*                                           require authorization     *
*---------------------------------------------------------------------*

REPORT  zotcr344b_transfer_batch_gts NO STANDARD PAGE HEADING
        LINE-SIZE 132
        LINE-COUNT 72
        MESSAGE-ID zotc_msg.

************************************************************************
*---- INCLUDES --------------------------------------------------------*
************************************************************************
* Top Include
INCLUDE zotcn0344b_transfer_batch_top. " Include for global data declaration
* Common Include
INCLUDE zdevnoxxx_common_include. " Include ZDEVNOXXX_COMMON_INCLUDE
*Include for selection screen having a file to process
INCLUDE zotcn0344b_transfer_batch_sel. " Include for selection screen declaration
* Include for all subroutines
INCLUDE zotcn0344b_transfer_batch_sub. " Include for subroutinees

************************************************************************
*---- AT-SELECTION-SCREEN OUTPUT --------------------------------------*
************************************************************************
AT SELECTION-SCREEN OUTPUT.
* Modify the screen based on User action.
  PERFORM f_modify_screen.

***********************************************************************
*--- AT-SELECTION-SCREEN VALIDATION ----------------------------------*
***********************************************************************
*Validating Input File - Presentation Server
AT SELECTION-SCREEN ON p_pfile.
  IF rb_pres = c_true AND p_pfile IS NOT INITIAL.
*     Validating the File Name
    PERFORM f_validate_p_file USING p_pfile.
*     Checking for ".xls" extension.
    PERFORM f_check_extension USING p_pfile.
  ENDIF. " IF rb_pres = c_true AND p_pfile IS NOT INITIAL

* Validating Input File - Application Server
AT SELECTION-SCREEN ON p_afile.
  IF p_afile IS NOT INITIAL.
*   Checking for ".TXT" extension.
    PERFORM f_check_extension USING p_afile.
  ENDIF. " IF p_afile IS NOT INITIAL

************************************************************************
*---- AT-SELECTION-SCREEN VALUE REQUEST -------------------------------*
************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_pfile.
  PERFORM f_help_l_path CHANGING p_pfile.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_afile.
  PERFORM f_help_as_path CHANGING p_afile.

************************************************************************
*---- START-OF-SELECTION ----------------------------------------------*
************************************************************************
START-OF-SELECTION.

* Fetch EMI data
  PERFORM f_fetch_emi CHANGING gv_dest_system
                               gv_codepage.

*  Checking on File Input.
  PERFORM f_check_input USING p_pfile
                              p_afile.

* Uploading the files from Presentation Server
  IF rb_pres IS NOT INITIAL.
    gv_file = p_pfile.

*   Uploading the file from Presentation Server
    PERFORM f_upload_presnt_files USING gv_file
                               CHANGING i_batch[].
  ENDIF. " IF rb_pres IS NOT INITIAL

* Uploading the files from Application Server
  IF rb_app IS NOT INITIAL.

*   If Logical File option is selected.
    IF rb_alog IS NOT INITIAL.
*     Retriving physical file paths from logical file name
      PERFORM f_logical_to_physical USING p_alog
                                 CHANGING gv_file.
    ELSE. " ELSE -> if rb_alog is not initial
      gv_file = p_afile.
    ENDIF. " if rb_alog is not initial

*   Uploading the file from Application Server
    PERFORM f_upload_applcn_files USING gv_file
                               CHANGING i_batch[].
  ENDIF. " IF rb_app IS NOT INITIAL

* Checking whether the uploaded file is empty or not. If empty, then
* Stop the execution of program
  IF i_batch IS INITIAL.
    MESSAGE i012. " Input file contains no record.Please check entry
    LEAVE LIST-PROCESSING.
  ENDIF. " IF i_batch IS INITIAL

* Performing Validations on the input data
  PERFORM f_validation CHANGING i_batch[]
                                i_final[]
                                i_report[]
                                gv_scount
                                gv_ecount.

* Table should not be uploaded in test mode
  IF NOT cb_test = abap_true.
    gv_mode = text-x15. " Update
    IF NOT i_final IS INITIAL.
      PERFORM f_update USING i_final[].
    ELSE. " ELSE -> IF NOT i_final IS INITIAL
* ---> Begin of Change for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
      MESSAGE i088. " Records validated, no data are eligible for upload.
* <--- End of Change for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
    ENDIF. " IF NOT i_final IS INITIAL
  ELSE. " ELSE -> IF NOT cb_test = abap_true
    gv_mode = text-x16. " Test Run
  ENDIF. " IF NOT cb_test = abap_true

************************************************************************
*---- END-OF-SELECTION ----------------------------------------------*
************************************************************************

END-OF-SELECTION.

  IF i_report IS INITIAL.

    CLEAR wa_report.
    wa_report-msgtyp = c_success.
    IF cb_test = abap_true.
      wa_report-msgtxt = text-001. " All records are validated and correct.
      APPEND wa_report TO i_report.
      CLEAR wa_report.

    ELSE. " ELSE -> IF cb_test = abap_true
      wa_report-msgtxt = text-002. " Successfully validated records are uploaded.
      APPEND wa_report TO i_report.
      CLEAR wa_report.
    ENDIF. " IF cb_test = abap_true

  ENDIF. " IF i_report IS INITIAL

* Displaying The Log Report
  IF i_report[] IS NOT INITIAL.
    PERFORM f_display_summary_report USING i_report
                                           gv_file
                                           gv_mode
                                           gv_scount
                                           gv_ecount.
  ENDIF. " IF i_report[] IS NOT INITIAL
