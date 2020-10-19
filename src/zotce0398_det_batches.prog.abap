*&**********************************************************************
* PROGRAM    :  ZOTC_EDD0398_DET_BATCHES                               *
* TITLE      :  Batch Determination at Sales Order                     *
* DEVELOPER  :  Dhanasekar Arumugam                                    *
* OBJECT TYPE:  Enhancement Program                                    *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0398                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Batch determination program will be used as a tool for *
*               automatic batch assignment to sales order lines,       *
*               specifically red-blood cells materials                 *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 24-Jan-2018 DARUMUG  E1DK934038 INITIAL DEVELOPMENT                  *
* 05-Mar-2018 DARUMUG  E1DK934038 CR# 212 Added Corresponding Batch    *
*                                 logic                                *
* 11-Mar-2018 DDWIVEDI E1DK934038 CR# 231 Manual batch inclusion       *
* 03-May-2018 DARUMUG  E1DK936439 Defect# 5957 Add Multiple SOrg's     *
* 27-Jun-2018 DARUMUG  E1DK937390 Defect# 6508 Unlock SO's once batch  *
*                                              is determined           *
* 02-Jul-2018 DARUMUG  E1DK937511 INC0423487 Defect# 6633 Consider     *
*                                 validity dates from Condition Records*
*                                 for Prioritization rules             *
* 08-Aug-2018 SMUKHER4 E1DK938198 CR# 307:Excel File upload for BDP tool*
* 04-Oct-2018 APODDAR  E1DK938946 Defect# 7289: Enabling background    *
*                                 functionality for BDP tool           *
* 29-Oct-2019 U033959  E2DK927169 Defect#10665- INC0433610-01          *
*                                 When split file check box is selected*
*                                 for background mode, then the records*
*                                 in the uploaded file will be split   *
*                                 into multiple files & mulitple       *
*                                 background jobs will be triggered.   *
*                                 Each file file contain no.of records *
*                                 as maintained in EMI                 *
*&---------------------------------------------------------------------*
REPORT zotce0398_det_batches MESSAGE-ID zotc_msg.

INCLUDE zotcn0398_det_batches_top. " Include ZOTC_EDD0398_DET_BATCHES_TOP
INCLUDE zotcn0398_det_batches_sel. " Include ZOTC_EDD0398_DET_BATCHES_SEL
INCLUDE zotcn0398_det_batches_o01. " Include ZOTC_EDD0398_DET_BATCHES_O01
INCLUDE zotcn0398_det_batches_i01. " Include ZOTC_EDD0398_DET_BATCHES_I01
INCLUDE zotcn0398_det_batches_c01. " Include ZOTC_EDD0398_DET_BATCHES_C01
INCLUDE zotcn0398_det_batches_f01. " Include ZOTC_EDD0398_DET_BATCHES_F01

*&-->Begin of changes for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018

*----------------------------------------------------------------------*
*                 AT SELECTION SCREEN OUTPUT                           *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
* Modify the screen based on User action.
  PERFORM f_modify_screen.

*----------------------------------------------------------------------*
*                 AT SELECTION SCREEN ON VALUE REQUEST                 *
*----------------------------------------------------------------------*
* For Input File from Presentation Server
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_ifile.
  PERFORM f_help_p_path CHANGING p_ifile.

** For Input File from Application Server
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_lfile.
  PERFORM f_help_p_path CHANGING p_lfile.
*&<--End of changes for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018

*&-->Begin of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_afile.
  PERFORM f_help_p_path CHANGING p_afile.
*&<--End of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018

*----------------------------------------------------------------------*
*                 AT SELECTION SCREEN ON                               *
*----------------------------------------------------------------------*
* Validation for Material
AT SELECTION-SCREEN ON s_matnr.
  PERFORM f_validate_matnr.

* Validation for Plant
AT SELECTION-SCREEN ON s_werks.
  PERFORM f_validate_plant.

* Validation on Sales Organization.
AT SELECTION-SCREEN ON s_vkorg.
  PERFORM f_validate_vkorg.

* Validation on Distribution Channel
AT SELECTION-SCREEN ON s_vtweg.
  PERFORM f_validate_vtweg.

* Validate Order type
AT SELECTION-SCREEN ON s_ordty.
  PERFORM f_validate_doc_typ.

* Validation for Documents
AT SELECTION-SCREEN ON s_docno.
  PERFORM f_validate_docno.

* Validation on Customer Number.
AT SELECTION-SCREEN ON s_soldto.
  PERFORM f_validate_kunnr.

* Validate Batches
AT SELECTION-SCREEN ON s_charg.
  PERFORM f_validate_batch.

*&-->Begin of changes for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018
* Validating Input File - Presentation Server
AT SELECTION-SCREEN ON p_ifile.
  IF rb_file = c_true AND p_ifile IS NOT INITIAL.
*   Validating the Input File Name
    PERFORM f_validate_p_inputfile USING p_ifile.
*   Checking for excel extension.
    PERFORM f_check_p_extension USING p_ifile.
  ENDIF. " IF rb_file = c_true AND p_ifile IS NOT INITIAL

* Validation for Log File
AT SELECTION-SCREEN ON p_lfile.
  IF rb_file = c_true AND p_lfile IS NOT INITIAL.
*   Checking for excel extension.
    PERFORM f_check_l_extension USING p_lfile.
  ENDIF. " IF rb_file = c_true AND p_lfile IS NOT INITIAL
*&<--End of changes for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018

*&-->Begin of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
* Validating Input File - Application Server
AT SELECTION-SCREEN ON p_afile.
  IF rb_back = c_true AND p_afile IS NOT INITIAL.
*   Validating the Input File Name
    PERFORM f_validate_p_inputfile USING p_afile.
*   Checking for excel extension.
    PERFORM f_check_p_extension USING p_afile.
  ENDIF. " IF rb_back = c_true AND p_afile IS NOT INITIAL

*&<--End of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018

*----------------------------------------------------------------------*
*                     START OF SELECTION                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.

*&-->Begin of changes for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018
*&&-- Check for mandatory fields

*&-- Sales Organization
  IF rb_onln IS NOT INITIAL.
    IF s_vkorg IS INITIAL.
      MESSAGE i977. " Please enter the Sales Organization.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF s_vkorg IS INITIAL

*&-- Requested delivery date
    IF s_rqdate IS INITIAL.
      MESSAGE i000 WITH 'Requested Delivery date is required'. " Company Code is required
      LEAVE LIST-PROCESSING.
    ENDIF. " IF s_rqdate IS INITIAL
*&<--End of changes for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018

* Get the values maintained in EMI table
    PERFORM f_get_emi_values.

* Get the Sales orders
    PERFORM f_get_orders.

    "Perform Lock Orders
    PERFORM f_lock_orders.

    PERFORM f_sequence_batches.

    IF sy-batch IS INITIAL.
      "Display the report to the user
      PERFORM f_display_report.
    ELSE. " ELSE -> IF sy-batch IS INITIAL
      i_batch_a[] = i_batch[].
      PERFORM f_determine_batches.
    ENDIF. " IF sy-batch IS INITIAL

*&-->Begin of changes for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018
  ELSE. " ELSE -> IF rb_onln IS NOT INITIAL
* Uploading the file from Presentation Server
*&--The below functionality should work when excel file radio button is pressed.
    IF rb_file IS NOT INITIAL AND p_ifile IS NOT INITIAL.
      gv_file = p_ifile.
      PERFORM f_upload_pres USING gv_file
                         CHANGING i_input[].
    ENDIF. " IF rb_file IS NOT INITIAL AND p_ifile IS NOT INITIAL

*&-->Begin of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
* For Application Server
    IF rb_back IS NOT INITIAL.
*   If No Application Server file name is entered and Application
*   Server Option has been chosen, then issueing error message.
      IF p_afile IS INITIAL.
        MESSAGE i033. " Application server file has not been entered.
        LEAVE LIST-PROCESSING.
      ENDIF. " IF p_afile IS INITIAL

*&--Uploading the files from applictaion server
* Uploading the files from Application Server
      IF p_afile IS NOT INITIAL.
        gv_file_app = p_afile.

        PERFORM f_upload_pres USING gv_file_app
                              CHANGING i_input[].

      ENDIF. " IF p_afile IS NOT INITIAL
    ENDIF. " IF rb_back IS NOT INITIAL
*&<--End of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018

    IF rb_file IS NOT INITIAL

*&-->Begin of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
      OR rb_back IS NOT INITIAL.
*&<--End of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018

*   Applying Conversion exit on input data
      PERFORM f_conversion_exit CHANGING i_input[].

* Checking the uploaded file; If it is empty, leave processing
      IF i_input[] IS INITIAL.
*   Input file contains no record. Please check your entry.
        MESSAGE i000 WITH 'Input file contains no record.'(029) 'Please check the entry'(030). " & & & &
        LEAVE LIST-PROCESSING.
      ELSE. " ELSE -> IF i_input[] IS INITIAL
*   Appending data to source table (kept as it is)
        i_source[] = i_input[].
*   Input file validation.
        PERFORM f_validation.

*&-->Begin of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
*&-->Sending the input file to the application server.
        IF rb_back IS NOT INITIAL AND p_afile IS NOT INITIAL.

          PERFORM f_get_error_records USING    i_source[]
                                               i_log_char[]
                                      CHANGING i_input_error[].
*--> Begin of Insert for INC0433610-01-Defect#10665 D3_OTC_EDD_0398 by U033959 dated 29-Oct-2019
*     Check if file split option is selected for background
          IF ch_split IS NOT INITIAL.

            PERFORM f_split_main_file USING    i_input_error[]
                                      CHANGING i_final_output[]
                                               i_split_files[].

          ELSE.
*<-- End of Insert for INC0433610-01-Defect#10665 D3_OTC_EDD_0398 by U033959 dated 29-Oct-2019
            PERFORM f_get_apps_server  USING     p_afile
                                                 i_final_output[]
                                                 i_input_error[].
* Submit Program in Background and Trigger Mail
            PERFORM f_submit_for_upld USING gv_file_appl.
*--> Begin of Insert for INC0433610-01-Defect#10665 D3_OTC_EDD_0398 by U033959 dated 29-Oct-2019
          ENDIF.
*<-- End of Insert for INC0433610-01-Defect#10665 D3_OTC_EDD_0398 by U033959 dated 29-Oct-2019
        ENDIF. " IF rb_back IS NOT INITIAL AND p_afile IS NOT INITIAL

*&<--End of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
      ENDIF. " IF i_input[] IS INITIAL
    ENDIF. " IF rb_file IS NOT INITIAL

*&--When Post radio button is pressed, it will update the data provided in the input file.
*    IF i_input[] IS NOT INITIAL AND
    IF i_final_output[] IS NOT INITIAL AND
       rb_post IS NOT INITIAL.
* Lock and Update Sales Orders one by one
      PERFORM f_lock_update_so USING i_final_output.
    ENDIF. " IF i_final_output[] IS NOT INITIAL AND
  ENDIF. " IF rb_onln IS NOT INITIAL

*----------------------------------------------------------------------*
*                     END OF SELECTION                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.

*&-->Begin of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
*  IF sy-batch IS INITIAL.
*&<--End of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
  IF rb_onln IS INITIAL.
*--------Application Server-----------------------
* Write the input file as-it-is from Presentation to TBP
*   Create the header line for log file
    PERFORM f_create_log_header.
* Get the file name for APPL server file
    PERFORM f_get_appl_files    USING p_ifile
                             CHANGING gv_tbp_file
                                      gv_done_file
                                      gv_err_file.

* Write the source file as-it-is to TBP
    PERFORM f_write_file USING gv_tbp_file
                               i_source.
* Write the final file to DONE folder
    PERFORM f_write_file USING gv_done_file
                               i_final_output.
*&--Download the log file in the presentation server.
    IF p_lfile IS NOT INITIAL.
      PERFORM f_download_file USING p_lfile
                                    i_log_char_file.
    ENDIF. " IF p_lfile IS NOT INITIAL

    IF rb_post IS NOT INITIAL. " AND gv_ecount IS NOT INITIAL.
* Write the log file to ERROR folder
      PERFORM f_write_log_file USING gv_err_file
                                     i_log_char_file.
    ENDIF. " IF rb_post IS NOT INITIAL

** Display the log file in ALV output
    PERFORM f_display_log_file USING i_log_char
                                     p_lfile.
  ENDIF. " IF rb_onln IS INITIAL
*&<--End of changes for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018
