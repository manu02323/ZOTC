*&---------------------------------------------------------------------*
*& Report  ZOTCI0008B_PRICE_LOAD_LTXT
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCC0008B_PRICE_LOAD_LTXT                             *
* TITLE      :  OTC_CDD_0008_Price Load                                *
* DEVELOPER  :  Nagamani N M                                           *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_CDD_0008_Price Load
*----------------------------------------------------------------------*
* DESCRIPTION:
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
*16-Aug-2013   NNM     E1DK911313  INITIAL DEVELOPMENT: CR700:
*                                  Copied from program
*                                  ZOTCN0008B_PRICE_LOAD_TOP.
*                                  Change of Input file format - common
*                                  for all Condition Record Tables.
*                                  Addition of Internal Comment in VK11
*&---------------------------------------------------------------------*

REPORT  zotcc0008b_price_load_ltxt MESSAGE-ID zotc_msg.
*----------------------------------------------------------------------*
*     INCLUDES
*----------------------------------------------------------------------*
INCLUDE zdevnoxxx_common_include.      " Common Include
INCLUDE zotcn0008b_price_load_top_ltxt." Data declerations
INCLUDE zotcn0008b_price_load_scr_ltxt." Selection Screen
INCLUDE zotcn0008b_price_load_sub_ltxt." Subroutine
*----------------------------------------------------------------------*
*     AT SELECTION SCREEN OUTPUT
*--------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify1_screen. "Control screen elements visibility
*----------------------------------------------------------------------*
*     AT SELECTION SCREEN ON
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_phdr.

  IF p_phdr IS NOT INITIAL.
*validate file on presentation server
    PERFORM f_validate_p_file USING p_phdr.
    CLEAR gv_extn.
    PERFORM f_file_extn_check USING    p_phdr "check for valid file extn
                              CHANGING gv_extn.
    IF gv_extn <> c_extn.
      MESSAGE e000 WITH 'Please provide text file for presentation server.'(007).
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON p_ahdr.
  IF  p_ahdr IS NOT INITIAL.
    CLEAR gv_extn.
    "check for valid file extn
    PERFORM f_file_extn_check USING p_ahdr
                              CHANGING gv_extn.
    IF gv_extn <> c_extn.
      MESSAGE e000  WITH 'Please provide text file for application server.'(008).
    ENDIF.
  ENDIF.
*----------------------------------------------------------------------*
*     AT SELECTION SCREEN ON VALUE REQUEST
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_phdr.
* provide f4 help for presentation server file
  PERFORM f_help_l_path CHANGING p_phdr.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_ahdr.
* provide f4 help for application server file
  PERFORM f_help_as_path CHANGING p_ahdr.
*----------------------------------------------------------------------*
*     START OF SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

* Checking on File Input.
  PERFORM f_check_input.

*Retriving physical file paths from logical file name
  IF rb_alog = c_selected.
    PERFORM f_logical_to_physical USING p_alog CHANGING gv_modify.
    gv_filename = gv_modify.
  ENDIF.
  PERFORM f_read_file.
  PERFORM f_upload_data.                             " Update Condition

*----------------------------------------------------------------------*
*     END OF SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.
  PERFORM f_display_summary. " Display Summary
