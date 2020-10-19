***********************************************************************
*Program    : ZOTC0142_VFX3_ACCURAL_REP                               *
*Title      : D3_OTC_RDD_0142_VFX3_Accural Report                     *
*Developer  : ShivaNagh Samala                                        *
*Object type: Report                                                  *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID:  D3_OTC_RDD_0142                                          *
*---------------------------------------------------------------------*
*Description: Batch Master Date 1 Report                              *
*                                                                     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport                     Description
*=========== ============== ============== ===========================*
*30-May-2019   U105235      E2DK924302     SCTASK0833109:Initial      *
*                                          development                *
*---------------------------------------------------------------------*
*16-July-2019  U105235     E2DK925308      Defect#10042 Item Category *
*                               description field value is truncating *
*&--------------------------------------------------------------------*

REPORT zotc0142_vfx3_accural_rep NO STANDARD PAGE HEADING
                                     MESSAGE-ID zotc_msg
                                     LINE-COUNT 145
                                     LINE-SIZE 132.

*include containing all the data declarations related to the program
INCLUDE zotc0142_vfx3_accural_rep_top.

*include containing the selection screen design
INCLUDE zotc0142_vfx3_accural_rep_sel.

*include containing all the subroutines
INCLUDE zotc0142_vfx3_accural_rep_sub.

INITIALIZATION.
*perform to initialize the internal tables and clear the work areas
  PERFORM f_initialization.

AT SELECTION-SCREEN.
*perform to validate the selection screen field values entered
  PERFORM f_screen_validation.

AT SELECTION-SCREEN OUTPUT.
*perform to modify the selection screen
  PERFORM f_modify_screen.

START-OF-SELECTION.

IF rb_back = abap_true AND  p_text IS INITIAL.
  MESSAGE i066.       "Enter Valid Email-ID
LEAVE LIST-PROCESSING.
ENDIF.
*perform to retrieve all the required data to be displayed in the output
PERFORM f_get_data.

END-OF-SELECTION.
*when the foreground radiobutton is selected in the selection screen
IF rb_fore = abap_true.
*if the final internal table has data to be displayed in the output
IF NOT i_final[] IS INITIAL.
*display the final internal table in the output
PERFORM f_display_data.
 ELSE.
MESSAGE e996.  "No data found matching to the selection criteria
ENDIF.
*when the background radiobutton is selected in the selection screen
ELSEIF rb_back = abap_true.

IF NOT i_final[] IS INITIAL.
*call the alv without display to capture the spool
PERFORM f_call_alv.
*perform to send the output data to email entered in the selection screen
PERFORM f_send_pdf_email.
 ELSE.
MESSAGE e996.  "No data found matching to the selection criteria
  ENDIF.
ENDIF.
*&--------------------------------------------------------------------*
*&      Form  F_DISPLAY_DATA
*&--------------------------------------------------------------------*
*       To display the retrieved data in the output
*---------------------------------------------------------------------*
FORM f_display_data.
*build fieldcatalog to display the fields in the output
PERFORM f_build_fieldcatalog CHANGING i_fieldcat[].
*call the alv display function module to display the data
PERFORM f_alv_display          USING i_fieldcat[]
                                     i_final[].
ENDFORM.
