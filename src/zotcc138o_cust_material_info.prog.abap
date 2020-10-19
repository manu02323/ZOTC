*&---------------------------------------------------------------------*
*& Report  ZOTCC0138O_CUST_MATERIAL_INFO
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    : ZOTCC0138O_CUST_MATERIAL_INFO                           *
* TITLE      : Convert Customer Material info records                  *
* DEVELOPER  : Rajiv Banerjee                                          *
* OBJECT TYPE: Conversion                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID: D3_OTC_CDD_0138_Convert Customer Material Info Records    *
*----------------------------------------------------------------------*
* DESCRIPTION: Customer material info records are used if the          *
* customer’s material number differs from the Bio-Rad’s material       *
* number, some customer’s would also require their own material number *
* be printed or transmitted in all of their communications.            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
*   DATE        USER    TRANSPORT    DESCRIPTION                       *
* =========== ======== ===========  ===================================*
* 20-APR-2016  RBANERJ1  E1DK917457  Initial Development               *
*&---------------------------------------------------------------------*

REPORT zotcc0138o_cust_material_info NO STANDARD PAGE HEADING MESSAGE-ID zotc_msg
                                                               LINE-SIZE 132
                                                               LINE-COUNT 65.

*----------------------------------------------------------------------*
*                     I N C L U D E S                                  *
*----------------------------------------------------------------------*
*&--Common Include for conversion
INCLUDE zdevnoxxx_common_include. "Include ZDEVNOXXX_COMMON_INCLUDE
*&--Top Include
INCLUDE zotcn138o_cust_mat_info_top. "INCLUDE ZOTCC0138O_CUST_MAT_INFO_TOP
*&--Selection Screen Include
INCLUDE zotcn138o_cust_mat_info_scr. "INCLUDE ZOTCC0138O_CUST_MAT_INFO_SCR
*&--Subroutine Include
INCLUDE zotcn138o_cust_mat_info_sub. "INCLUDE ZOTCC0138O_CUST_MAT_INFO_SUB.

*----------------------------------------------------------------------*
*                 I N I T I A L I Z A T I O N                          *
*----------------------------------------------------------------------*
INITIALIZATION.

  FREE : i_string,
         i_data,
         i_report,
         i_bdcdata,
         i_kna1,
         i_mara,
         i_knvv,
         i_mvke,
         i_knmt,
         i_error,
         i_done.

  CLEAR : gv_modify,
          gv_filename,
          gv_file,
          gv_subrc,
          gv_header,
          gv_success,
          gv_mode,
          gv_error.
*----------------------------------------------------------------------*
*                 AT SELECTION SCREEN OUTPUT                           *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify1_screen. "Control screen elements visibility
*----------------------------------------------------------------------*
*                 AT SELECTION SCREEN ON VALUE REQUEST                 *
*----------------------------------------------------------------------*

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_phdr.
*&--Provide F4 help for Presentation Server File
  PERFORM f_help_l_path CHANGING p_phdr.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_ahdr.
*&--Provide F4 help for Application Server File
  PERFORM f_help_as_path CHANGING p_ahdr.
*----------------------------------------------------------------------*
*                AT SELECTION SCREEN ON                                *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_phdr.
  IF p_phdr IS NOT INITIAL.
*&--Validate file on Presentation Server
    PERFORM f_validate_p_file USING p_phdr.
    CLEAR gv_extn.
*&--Check for valid file extn
    PERFORM f_file_extn_check USING    p_phdr
                              CHANGING gv_extn.
    IF gv_extn <> c_extn.
      MESSAGE e008. "Please provide TXT file
    ENDIF. " IF gv_extn <> c_extn
  ENDIF. " IF p_phdr IS NOT INITIAL


AT SELECTION-SCREEN ON p_ahdr.
  IF  p_ahdr IS NOT INITIAL.
    CLEAR gv_extn.
*&--Check for valid file extn
    PERFORM f_file_extn_check USING p_ahdr
                              CHANGING gv_extn.
    IF gv_extn <> c_extn.
      MESSAGE e008. "Please provide TXT file
    ENDIF. " IF gv_extn <> c_extn
  ENDIF. " IF p_ahdr IS NOT INITIAL

*----------------------------------------------------------------------*
*                     START OF SELECTION                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.


*&--Checking on File Input.
  PERFORM f_check_input.

*&--Retriving Physical file paths from Logical file name
  IF rb_alog = abap_true
    AND rb_app = abap_true.

    PERFORM f_logical_to_physical USING p_alog
                                  CHANGING gv_modify.
    gv_filename = gv_modify.
  ENDIF. " IF rb_alog = abap_true

*&--Read file from Presentation/Application Server
  PERFORM f_read_file CHANGING i_string
                               i_report
                               i_data.

  IF rb_verif IS NOT INITIAL.
 "verify file structure
    PERFORM f_verify_file USING gv_header.

  ENDIF. " IF rb_verif IS NOT INITIAL

  IF rb_simu IS NOT INITIAL OR
     rb_post IS NOT INITIAL.

*&--Validate Data from Upload File
    PERFORM f_validate_data USING i_data.

*&--Populate Error Log based on Validation Result
    PERFORM f_populate_error_log CHANGING i_data
                                          i_report
                                          i_error.
  ENDIF. " IF rb_simu IS NOT INITIAL OR

*&--Call BDC with file records
  IF rb_post IS NOT INITIAL.
    PERFORM f_call_bdc  USING   i_data
                       CHANGING i_report
                                i_error
                                i_done.
  ENDIF. " IF rb_post IS NOT INITIAL

*----------------------------------------------------------------------*
*                     END OF SELECTION                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.

  IF rb_app IS NOT INITIAL AND
     rb_post IS NOT INITIAL.

*   In case the file was uploaded from Application server, then
*   Moving them in Processed Done/ Error folder depending upon Final
*   Status.
    IF gv_error IS NOT INITIAL
      AND i_error[] IS NOT INITIAL.

      PERFORM f_move_error USING gv_file
                                 i_error[]
                           CHANGING i_report[].
    ENDIF. " IF gv_error IS NOT INITIAL

    IF gv_success IS NOT INITIAL
       AND i_done[] IS NOT INITIAL.

      PERFORM f_move_success USING gv_file
                                   i_done[]
                           CHANGING i_report[].
    ENDIF. " IF gv_success IS NOT INITIAL
  ENDIF. " IF rb_app IS NOT INITIAL AND

  IF gv_error IS INITIAL
    AND rb_simu IS NOT INITIAL.

    PERFORM f_all_verified CHANGING i_report.

  ENDIF. " IF gv_error IS INITIAL

  IF gv_error IS INITIAL
    AND rb_post IS NOT INITIAL.

    PERFORM f_all_processed CHANGING i_report.

  ENDIF. " IF gv_error IS INITIAL

  IF rb_simu IS NOT INITIAL OR
     rb_post IS NOT INITIAL.

    IF rb_simu IS NOT INITIAL.
      gv_mode = 'Load Simulation'(077).
    ELSE. " ELSE -> IF rb_simu IS NOT INITIAL
      gv_mode = 'Verify & Post'(078).
    ENDIF. " IF rb_simu IS NOT INITIAL

                                                      "Display summary report
    PERFORM f_display_summary_report1 USING i_report  "Error Report
                                           gv_file    "Input file path
                                           gv_mode    "mode of processing
                                           gv_success "Valid record count
                                           gv_error.  "Error record count

  ENDIF. " IF rb_simu IS NOT INITIAL OR
