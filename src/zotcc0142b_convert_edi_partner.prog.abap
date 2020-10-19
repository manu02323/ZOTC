*&---------------------------------------------------------------------*
*& Report  ZOTCC0142B_CONVERT_EDI_PARTNER
*&
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCC0142B_CONVERT_EDI_PARTNER                         *
* TITLE      :  Order to Cash D3_OTC_CDD_0142_Convert EDI Ext Partner  *
*               to Internal Partner (EDPAR)                            *
* DEVELOPER  :  Nasrin Ali                                             *
* OBJECT TYPE:  Conversion Program                                     *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_CDD_0142                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Convert EDI Ext Partner                                *
*               to Internal Partner (EDPAR)                            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 18-MAY-2016 NALI     E1DK918180 INITIAL DEVELOPMENT                  *
* =========== ======== ========== =====================================*

REPORT zotcc0142b_convert_edi_partner NO STANDARD PAGE HEADING
                                         LINE-SIZE 132
                                         LINE-COUNT 72
                                         MESSAGE-ID zotc_msg.
** TOP Include
INCLUDE zotcn0142b_convert_edi_top. " TOP Include for Convert EDI Ext Partner to Internal Partner (EDPAR)

** Common Include for Conversion Programs
INCLUDE zdevnoxxx_common_include ##INCL_OK.   " Include ZDEVNOXXX_COMMON_INCLUDE

** Selection Screen include
INCLUDE zotcn0142b_convert_edi_ss. " Selection Screen for Convert EDI Ext Partner to Internal Partner (EDPA

** Subroutine include.
INCLUDE zotcn0142b_convert_edi_sub. " Subroutine include for Convert EDI Ext Partner to Internal Partner (ED

************************************************************************
*---- INITIALIZATION --------------------------------------------------*
************************************************************************
INITIALIZATION.
  REFRESH:  i_report,
            i_final,
            i_error,
            i_valid.
  CLEAR:    gv_save,
            gv_file,
            gv_mode,
            gv_save,
            gv_scount,
            gv_ecount.
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
  IF p_pfile IS NOT INITIAL.
*     Validating the Input File Name
    PERFORM f_validate_p_file USING p_pfile.

*     Checking for ".TXT" extension.
    PERFORM f_check_extension USING p_pfile.
  ENDIF. " IF p_pfile IS NOT INITIAL

* Validating Input File - Application Server
AT SELECTION-SCREEN ON p_afile.
  IF p_afile IS NOT INITIAL.
*     Checking for ".TXT" extension.
    PERFORM f_check_extension USING p_afile.
  ENDIF. " IF p_afile IS NOT INITIAL

*************************************************************************
**---- START-OF-SELECTION ----------------------------------------------*
*************************************************************************
START-OF-SELECTION.

*&--Fetch Constant Values
  PERFORM f_get_constants.

*   Checking on File Input
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
    PERFORM f_upload_apps USING gv_file
                          CHANGING i_kunnr.
  ENDIF. " IF rb_app IS NOT INITIAL

**   Checking whether the uploaded file is empty or not. If empty, then
**   Stopping program
  IF i_final IS INITIAL.
*   Input file contains no record. Please check your entry.
    MESSAGE i000 WITH 'Input file contains no record.'(086) 'Please check the entry'(087). " & & & &
    LEAVE LIST-PROCESSING.
  ELSE. " ELSE -> IF i_final IS INITIAL

***Input file validation.
    PERFORM f_validation USING i_kunnr
                          CHANGING i_final
                                  i_valid
                                  i_error
                                  i_report.
  ENDIF. " IF i_final IS INITIAL

**BDC Call for VOE4 Transaction
  IF i_valid IS NOT INITIAL AND
     rb_post IS NOT INITIAL.
    PERFORM f_voe4_bdc USING    i_valid[]
                       CHANGING i_error[].
  ENDIF. " IF i_valid IS NOT INITIAL AND

*********************************************************************************
**End of selection event
END-OF-SELECTION.

* Now put the file in error or done folder.
  IF rb_post IS NOT INITIAL AND
     rb_app IS NOT INITIAL.
    PERFORM f_move USING gv_file.
  ENDIF. " IF rb_post IS NOT INITIAL AND

  IF gv_ecount IS NOT INITIAL AND
     rb_app IS NOT INITIAL AND
     rb_post IS NOT INITIAL.
* Write the error records in error file
    PERFORM f_write_error_file USING gv_file
                                     i_error[] .
  ENDIF. " IF gv_ecount IS NOT INITIAL AND

  IF i_report IS INITIAL.
    CLEAR wa_report.
    wa_report-msgtyp = c_smsg.
    IF rb_post = abap_true.
      wa_report-msgtxt = 'All records are successfully uploaded'(094).
      APPEND wa_report TO i_report.
      CLEAR wa_report.
    ELSE. " ELSE -> IF rb_post = abap_true
      wa_report-msgtxt = 'All records are verified and correct'(095).
      APPEND wa_report TO i_report.
      CLEAR wa_report.
    ENDIF. " IF rb_post = abap_true
  ENDIF. " IF i_report IS INITIAL

* Now show the summary report
  PERFORM f_display_summary_report USING i_report
                                         gv_file
                                         gv_mode
                                         gv_scount
                                         gv_ecount.
