*&---------------------------------------------------------------------*
*& REPORT  ZOTCC0050O_REBATE_CONVERSION
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    : ZOTCC0050O_REBATE_CONVERSION                            *
* TITLE      :  OTC_CDD_0050_Convert_Rebate                            *
* DEVELOPER  :  SATEERTH DAS                                           *
* OBJECT TYPE:  Conversion                                             *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_CDD_0050_Convert_Recipe                              *
*----------------------------------------------------------------------*
* DESCRIPTION: Uploads a user-generated spreadsheet (tab delimited)
*              file for a Call Transaction of VBO1 (create rebate).
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 26-Jul-2012 SDAS     E1DK903273 INITIAL DEVELOPMENT                  *
* 31-Oct-2012 SPURI    E1DK905593 Defect 1247 : Incorrect
*                                 number of Agreements created for a
*                                 unique combination of Customer  and
*                                 GPO number.  Code Change : Removed
*                                 AT NEW statement  instead declared a
*                                 local variable to hold previous value
*                                 of GPO and customer.
*&---------------------------------------------------------------------*

report  zotcc0050o_rebate_conversion message-id zotc_msg
line-count 80
line-size 132
no standard page heading.
*--------------------------------------------------------------------*
*     INCLUDES
*--------------------------------------------------------------------*
* Top Include
include zotcn0050o_rebate_conv_top.

* Common Include for Conversion Programs
include zdevnoxxx_common_include.

* Selection Screen Include
include zotcn0050o_rebate_conv_sel.

* Include for all subroutines
include zotcn0050o_rebate_conv_f01.

*---- AT-SELECTION-SCREEN OUTPUT --------------------------------------*
************************************************************************
at selection-screen output.
*   Modify the screen based on User action.
  perform f_modify_screen.

************************************************************************
*          AT-SELECTION-SCREEN VALUE REQUEST
************************************************************************
at selection-screen on value-request for p_pfile.
  perform f_help_l_path changing p_pfile.

at selection-screen on value-request for p_afile.
  perform f_help_as_path changing p_afile.


************************************************************************
*---- AT-SELECTION-SCREEN VALIDATION ----------------------------------*
************************************************************************
* Validating Input File - Presentation Server
at selection-screen on p_pfile.
  if rb_pres = c_true and
     p_pfile is not initial.
*     Validating the Input File Name
    perform f_validate_p_file using p_pfile.
*     Checking for ".TXT" extension.
    perform f_check_extension using p_pfile.
  endif.

* Validating Input File - Application Server
at selection-screen on p_afile.
  if p_afile is not initial.
*   Checking for ".TXT" extension.
    perform f_check_extension using p_afile.
  endif.

*---------------------------------------------------------------------*
*     START OF SELECTION
*---------------------------------------------------------------------*
start-of-selection.

* Checking on File Input
  perform f_check_input.

* Setting the mode of processing
  perform f_set_mode changing gv_mode.

* Uploading the file from Presentation Server
  if rb_pres is not initial.
    gv_file = p_pfile.
    perform f_upload_pres using gv_file.
  endif.
* Uploading the files from Application Server
  perform f_get_apps_server using gv_file.

*  subroutine to clear/refresh variables
  perform sub_clear_variables.

* Validate Selection Screen
  perform sub_fill_data.

*---------------------------------------------------------------------*
*    END-OF-SELECTION
*---------------------------------------------------------------------*
end-of-selection.

  if rb_post = c_x .

* open the bdc group
    perform f_bdc_open_group.

* populate the bdc data and call transaction
    perform f_bdc_insert_data.

* Close the BDC group
    perform f_bdc_close_group.

  endif .
