*&---------------------------------------------------------------------*
*& Report  ZOTCC091O_EXTEND_GROUP_BOM
*&
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    : ZOTCC091O_EXTEND_GROUP_BOM                              *
* TITLE      : Convert Sales BOM                                       *
* DEVELOPER  : Rajiv Banerjee/Jayanta Ray                              *
* OBJECT TYPE: Conversion                                              *
* SAP RELEASE: SAP ECC 6.0                                             *
*----------------------------------------------------------------------*
* WRICEF ID: D3_OTC_CDD_0091_Convert Sales BOM                         *
*----------------------------------------------------------------------*
* DESCRIPTION: BOMs will be extended to plants using custom BDC program*
*              automating transaction code CS07.                       *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
*   DATE        USER    TRANSPORT    DESCRIPTION                       *
* =========== ======== ===========  ===================================*
* 09-MAY-2016  RBANERJ1  E1DK917998  Initial Development               *
*&---------------------------------------------------------------------*
* 19-Nov-2016  NGARG    E1DK917998  Defect#6766: Capture the specific  *
*                                   information type message as error  *
*                                   message.
*&---------------------------------------------------------------------*

REPORT zotcc091o_extend_group_bom NO STANDARD PAGE HEADING MESSAGE-ID zotc_msg
                                                               LINE-SIZE 132
                                                               LINE-COUNT 65.

*----------------------------------------------------------------------*
*                     I N C L U D E S                                  *
*----------------------------------------------------------------------*

*-- Common Include for Conversion Programs
INCLUDE zdevnoxxx_common_include.  " Include ZDEVNOXXX_COMMON_INCLUDE
*&--Top Include
INCLUDE zotcn091o_ext_grp_bom_top. " Include ZOTCN091O_CUST_EXT_GRP_BOM_TOP
*&--Selection Screen Include
INCLUDE zotcn091o_ext_grp_bom_scr. " Include ZOTCN091O_CUST_EXT_GRP_BOM_SCR
*&--Subroutine Include
INCLUDE zotcn091o_ext_grp_bom_sub. " Include ZOTCN091O_EXT_GRP_BOM_SUB

*----------------------------------------------------------------------*
*                 I N I T I A L I Z A T I O N                          *
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM f_initialization.
*----------------------------------------------------------------------*
*                 AT SELECTION SCREEN OUTPUT                           *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen.         "Control screen elements visibility

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

*&--Fetch Constant Values
  PERFORM f_get_constants.

*&--Checking on File Input.
  PERFORM f_check_input.

** Setting the mode of processing
  PERFORM f_set_mode CHANGING  gv_mode.

* Uploading the file from Presentation Server
  IF rb_pres IS NOT INITIAL.
    gv_file = p_phdr.
    PERFORM f_upload_pres USING gv_file.
  ENDIF. " IF rb_pres IS NOT INITIAL

** Uploading the files from Application Server
  IF rb_app IS NOT INITIAL.
*  If Logical File option is selected.
    IF rb_alog IS NOT INITIAL.
*  Retriving physical file paths from logical file name
      PERFORM f_logical_to_physical USING p_alog
                                    CHANGING gv_file.
    ELSE. " ELSE -> IF rb_alog IS NOT INITIAL
      gv_file = p_ahdr.
    ENDIF. " IF rb_alog IS NOT INITIAL
*     Uploading the files from Application Server
    PERFORM f_upload_apps USING gv_file.
  ENDIF. " IF rb_app IS NOT INITIAL

**Input file validation.
  PERFORM f_validation.

**BDC Call for CS07 Transaction(Extend to plant)
  IF i_valid IS NOT INITIAL
     AND rb_post IS NOT INITIAL.
    PERFORM f_execute_bdc USING i_valid[]
                       CHANGING i_error[].
  ENDIF. " IF i_valid IS NOT INITIAL

*************************************************************************
*        END-OF-SELECTION                                               *
*************************************************************************
END-OF-SELECTION.

* Now put the file in error or done folder.
  IF rb_post IS NOT INITIAL AND
     rb_app IS NOT INITIAL.
    PERFORM f_move CHANGING gv_file.
  ENDIF. " IF rb_post IS NOT INITIAL AND

  IF gv_ecount IS NOT INITIAL AND
      rb_pres IS INITIAL AND rb_post IS NOT INITIAL.
* Write the error records in error file
    PERFORM f_write_error_file USING gv_file
                                     i_error[] .
  ENDIF. " IF gv_ecount IS NOT INITIAL AND
*
  IF i_report IS INITIAL.
    PERFORM f_all_success.
  ENDIF. " IF i_report IS INITIAL

* Now show the summary report
  PERFORM f_display_summary_report2 USING i_report
                                          gv_file
                                          gv_mode
                                          gv_scount
                                          gv_ecount.
