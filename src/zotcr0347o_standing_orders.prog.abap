************************************************************************
* PROGRAM    :  ZOTCR0347O_STANDING_ORDERS                             *
* TITLE      :  D3_OTC_EDD_0347_Upload Standing Orders                 *
* DEVELOPER  :  Debasish Maiti / Bijayeeta Banerjee                    *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_EDD_0347                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: Upload Standing Orders                                  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 15.06.2016  BBANERJ   E1DK919242  Initial Development                *
*&---------------------------------------------------------------------*
* 27.07.2016  U034088   E1DK919242  Defect# 2741: Change output Layout *
*&---------------------------------------------------------------------*
* 07-Mar-2017 NALI   E1DK926115  D3 CR 378.
* Added sales office in selection screen. It will be pre-populated with
* value in user profile from parameter VKB.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZOTCR0347O_STANDING_ORDERS
*&---------------------------------------------------------------------*

REPORT zotcr0347o_standing_orders NO STANDARD PAGE HEADING MESSAGE-ID zotc_msg
                                                              LINE-SIZE 132
                                                              LINE-COUNT 65.

*-- Common Include for Conversion Programs
INCLUDE zdevnoxxx_common_include. " Include ZDEVNOXXX_COMMON_INCLUDE
*&---------------------------------------------------------------------*
*& Include for top declaration
*&---------------------------------------------------------------------*
INCLUDE zotcn0347o_standing_orders_top. " " Include ZOTCN0347O_STANDING_ORDERS_TOP

*&---------------------------------------------------------------------*
*& Include for Selection screen
*&---------------------------------------------------------------------*
INCLUDE zotcn0347o_standing_orders_sel. " " Include ZOTCN0347O_STANDING_ORDERS_SEL

*&---------------------------------------------------------------------*
*& Include for Validation of selection screen fields
*&---------------------------------------------------------------------*
INCLUDE zotcn0347o_standing_orders_f01. " " Include ZOTCN0347O_STANDING_ORDERS_F01

*----------------------------------------------------------------------*
*                 I N I T I A L I Z A T I O N                          *
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM f_initialization.

*----------------------------------------------------------------------*
*                 AT SELECTION SCREEN OUTPUT                           *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen. "Control screen elements visibility

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
      MESSAGE e183. "Please provide CSV file
    ENDIF. " IF gv_extn <> c_extn
  ENDIF. " IF p_phdr IS NOT INITIAL


AT SELECTION-SCREEN ON p_ahdr.
  IF  p_ahdr IS NOT INITIAL.
    CLEAR gv_extn.
*&--Check for valid file extn
    PERFORM f_file_extn_check USING p_ahdr
                              CHANGING gv_extn.
    IF gv_extn <> c_extn.
      MESSAGE e183. "Please provide CSV file
    ENDIF. " IF gv_extn <> c_extn
  ENDIF. " IF p_ahdr IS NOT INITIAL


* ---> Begin of Change for D3_OTC_EDD_0347_CR#378 by NALI
AT SELECTION-SCREEN ON p_vkbur.
  IF p_vkbur  IS NOT INITIAL.
*&--Validate Sales Office
    PERFORM f_validate_p_vkbur  USING p_vkbur.
  ENDIF.
* <--- End of Change for D3_OTC_EDD_0347_CR#378 by NALI
*----------------------------------------------------------------------*
*     START OF SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

*&--Fetch Constant Values
  PERFORM f_get_constants.

*&--Checking on File Input.
  PERFORM f_check_input.

*& Setting the mode of processing
  PERFORM f_set_mode CHANGING  gv_mode.

*& Uploading the file from Presentation Server
  IF rb_pres IS NOT INITIAL.
    gv_file = p_phdr.
    PERFORM f_upload_pres   USING gv_file.
  ENDIF. " IF rb_pres IS NOT INITIAL

*& Uploading the files from Application Server
  IF rb_app IS NOT INITIAL.
* Commented Logical path section by RAJENDRA
*&  If Logical File option is selected.
*    IF rb_alog IS NOT INITIAL.
**&  Retriving physical file paths from logical file name
*      PERFORM f_logical_to_physical USING p_alog
*                                    CHANGING gv_file.
*    ELSE. " ELSE -> IF rb_alog IS NOT INITIAL
      gv_file = p_ahdr.
*    ENDIF. " IF rb_alog IS NOT INITIAL
*&     Uploading the files from Application Server
    PERFORM f_upload_apps  USING  gv_file.
  ENDIF. " IF rb_app IS NOT INITIAL

*&Input file validation.
  PERFORM f_validation.

*& Posting Sales order
  PERFORM f_bapi_posting  USING i_leg_tab_c.

*----------------------------------------------------------------------*
*     END OF SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.

*& Move to done folder in case all success / Error in Post
  IF rb_app EQ abap_true
    AND rb_post EQ abap_true.

    PERFORM f_move CHANGING gv_file.

  ENDIF. " IF rb_app EQ abap_true

*& Move to Error folder in case any error in Post
  IF rb_app EQ abap_true
    AND rb_post EQ abap_true
    AND gv_ecount GE 1.       " Write Error file if there is any error only
*& Write the error records in error file
    PERFORM f_write_error_file USING gv_file
                                     i_leg_tab_msg[].
  ENDIF. " IF rb_app EQ abap_true

*& Populate Messages and the Keys for displaying in Output
  PERFORM f_all_message.

*---> Begin of Delete for Defect# 2741 by U034088 on 27.07.2016
*& Now show the summary report
*  PERFORM f_display_summary_report2 USING i_report
*                                          gv_file
*                                          gv_mode
*                                          gv_scount
*                                          gv_ecount.
*<--- End of Delete for Defect# 2741 by U034088 on 27.07.2016

*---> Begin of Insert for Defect# 2741 by U034088 on 27.07.2016
*& Now show the summary report
* f_display_summary_report3 copied from f_display_summary_report2

  PERFORM f_display_summary_report3 USING i_report
                                          gv_file
                                          gv_mode
                                          gv_scount
                                          gv_ecount.
*<--- End of Insert for Defect# 2741 by U034088 on 27.07.2016
