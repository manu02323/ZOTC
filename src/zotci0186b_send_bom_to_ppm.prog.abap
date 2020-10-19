*&---------------------------------------------------------------------*
*& Report  ZOTCI0186B_SEND_BOM_TO_PPM
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCI0186B_SEND_BOM_TO_PPM                             *
* TITLE      :  D2_OTC_IDD_0186_Send Sales BOM structure to PPM        *
* DEVELOPER  :  Sneha Ghosh                                            *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 7.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_0186_Send Sales BOM structure to PPM             *
*----------------------------------------------------------------------*
* DESCRIPTION: The requirement is to send the BOM structure from SAP   *
* to PPM. From each Plant valid BOMs as on date will be extracted and  *
* stored in a flat file. This file subsequently will be uploaded to PPM*
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 15-Sep-2014 SGHOSH   E2DK914957 PGL- INITIAL DEVELOPMENT -           *
*                                 Task Number: E2DK915243,E2DK915041   *
*&---------------------------------------------------------------------*

REPORT zotci0186b_send_bom_to_ppm NO STANDARD PAGE HEADING
                                  LINE-SIZE 132
                                  LINE-COUNT 65(2)
                                  MESSAGE-ID zotc_msg.

************************************************************************
*          DATA DECLARATION INCLUDE                                    *
************************************************************************
*&& -- COMMON INCLUDE
INCLUDE zdevnoxxx_common_include. " Common Include
*&& -- TOP INCLUDE
INCLUDE zotcn0186b_send_bom_to_ppm_top. " Include ZOTCN0186B_SEND_BOM_TO_PPM_TOP
*&& -- SELECTION SCREEN INCLUDE
INCLUDE zotcn0186b_send_bom_to_ppm_sel. " Include ZOTCN0186B_SEND_BOM_TO_PPM_SEL
*&& -- SUBROUTINE INCLUDE
INCLUDE zotcn0186b_send_bom_to_ppm_f01. " Include ZOTCN0186B_SEND_BOM_TO_PPM_F01

*----------------------------------------------------------------------*
*           I N I T I A L I Z A T I O N                                *
*----------------------------------------------------------------------*
INITIALIZATION.
*&& -- Fetch data from EMI
PERFORM f_retrieve_data_emi CHANGING gv_file
                                     gv_pfile
                                     gv_bomtyp.
*----------------------------------------------------------------------*
*           AT SELECTION SCREEN OUTPUT                                 *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*&& -- Control screen elements visibility
  PERFORM f_modify_screen.

AT SELECTION-SCREEN.
*----------------------------------------------------------------------*
*           AT-SELECTION-SCREEN VALIDATION                             *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON s_werks.
*&& -- Validating Plant
  PERFORM f_validate_werks.

AT SELECTION-SCREEN ON p_phdr.
*&& -- Validate presentation server file name
  IF rb_fore IS NOT INITIAL AND
     p_phdr IS NOT INITIAL AND
     sy-batch IS INITIAL.
*&& -- Validate presentation server path
    PERFORM f_validate_phdr USING p_phdr.
    CLEAR gv_extn.
*&& -- Check for valid file extn
    PERFORM f_file_extn_check USING p_phdr
                            CHANGING gv_extn.

    IF gv_extn <> c_extn.
      MESSAGE e179. " Please provide TXT file for presentation server.
    ENDIF. " IF gv_extn <> c_extn
  ENDIF. " IF rb_fore IS NOT INITIAL AND
*----------------------------------------------------------------------*
*     AT SELECTION SCREEN ON VALUE REQUEST
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_phdr.
*&& -- Provide f4 help for presentation server file
  PERFORM f_help_l_path CHANGING p_phdr.
*----------------------------------------------------------------------*
*     START OF SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
*&& -- Check Selection Screen Input.
  PERFORM f_check_input CHANGING i_mast.
*&& -- Retrieve BOM data
  PERFORM f_retrieve_bom_data USING i_mast
                              CHANGING i_final.

*-----------------------------------------------------------------------*
*     END OF SELECTION
*-----------------------------------------------------------------------*
END-OF-SELECTION.
  IF p_ahdr IS NOT INITIAL.
*&& -- Write Output in Application Server File in Foreground Mode
    PERFORM f_write_app_data USING p_ahdr
                                   i_final
                             CHANGING i_log.
  ELSEIF p_ahdr1 IS NOT INITIAL. " ELSE -> IF p_ahdr IS NOT INITIAL
    IF sy-batch IS NOT INITIAL.
*&& -- Write Output in Application Server File in Background Mode
      PERFORM f_write_app_data USING p_ahdr1
                                     i_final
                               CHANGING i_log.
    ELSE. " ELSE -> IF sy-batch IS NOT INITIAL
* && -- Populate log table with error message if background option is used in foreground
      wa_log_err-msgtyp = c_msgtyp_e.
      wa_log_err-msgtxt = 'Background mode cannot be executed in foreground.'(022).
      APPEND wa_log_err TO i_log.
      CLEAR wa_log_err.
    ENDIF. " IF sy-batch IS NOT INITIAL
  ENDIF. " IF p_ahdr IS NOT INITIAL

  IF p_phdr IS NOT INITIAL.
*&& -- Write Output in Presentation Server File
    PERFORM f_write_pres_data USING i_final
                              CHANGING  p_phdr
                                        i_data
                                        i_log.
  ENDIF. " IF p_phdr IS NOT INITIAL

  IF i_log[] IS NOT INITIAL.
*&--Write log
    PERFORM f_write_log USING i_log.
  ENDIF. " IF i_log[] IS NOT INITIAL
