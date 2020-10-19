*----------------------------------------------------------------------*
***INCLUDE LTXW1I01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  TC_XFILES_MARK_LINE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_XFILES_MARK_LINE INPUT.

  MODIFY TC_XFILES_TAB INDEX TC_XFILES-CURRENT_LINE.

ENDMODULE.                             " TC_XFILES_MARK_LINE  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE SY-UCOMM.

    WHEN 'CANC'.                       "Cancel
      GLO_CANCELED = 'X'.
      SET SCREEN 0. LEAVE SCREEN.

    WHEN 'CONT'.                       "Continue
      SET SCREEN 0. LEAVE SCREEN.

    WHEN 'DELL'.                       "Delete line
      DELETE TC_XFILES_TAB WHERE MARK = 'X'.

    WHEN 'DSAL'.                       "Deselect all
      LOOP AT TC_XFILES_TAB.
        CLEAR TC_XFILES_TAB-MARK.
        MODIFY TC_XFILES_TAB.
      ENDLOOP.

    WHEN 'INSL'.                       "Insert line
      LOOP AT TC_XFILES_TAB WHERE MARK = 'X'.
        INSERT INITIAL LINE INTO TC_XFILES_TAB INDEX SY-TABIX.
        ADD 1 TO TC_XFILES-LINES.
      ENDLOOP.
      LOOP AT TC_XFILES_TAB.
        TC_XFILES_TAB-MARK = ' '.
        MODIFY TC_XFILES_TAB.
      ENDLOOP.

    WHEN 'SALL'.                       "Select all
      LOOP AT TC_XFILES_TAB.
        TC_XFILES_TAB-MARK = 'X'.
        MODIFY TC_XFILES_TAB.
      ENDLOOP.


  ENDCASE.

ENDMODULE.                             " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  TC_XFILES_PROCESS_LINE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_XFILES_PROCESS_LINE INPUT.

  SHIFT TXW_XFILES-VOL_SET LEFT DELETING LEADING SPACE.
  SHIFT TXW_XFILES-L_FILE LEFT DELETING LEADING SPACE.
  MOVE-CORRESPONDING TXW_XFILES TO TC_XFILES_TAB.

* check input
  CALL FUNCTION 'TXW_EXTRACT_READ_CLOSE'.
  CALL FUNCTION 'TXW_EXTRACT_READ_INIT'
       EXPORTING
            FILE_NAME  = TXW_XFILES-L_FILE
            VOLDIR_SET = TXW_XFILES-VOL_SET.

* add entry
  DESCRIBE TABLE TC_XFILES_TAB LINES TC_XFILES-LINES.
  IF TC_XFILES-CURRENT_LINE <= TC_XFILES-LINES.
    MODIFY TC_XFILES_TAB INDEX TC_XFILES-CURRENT_LINE.
  ELSEIF NOT TC_XFILES_TAB IS INITIAL.
    APPEND TC_XFILES_TAB.
  ENDIF.

ENDMODULE.                             " TC_XFILES_PROCESS_LINE  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALUE_HELP_L_FILE  INPUT
*&---------------------------------------------------------------------*
*       value help for file
*----------------------------------------------------------------------*
*MODULE VALUE_HELP_L_FILE INPUT.
*
*  CALL FUNCTION 'TXW_DATA_FILE_VALUE_HELP'
*       IMPORTING
*            DATA_FILE = TXW_XFILES-L_FILE
*       EXCEPTIONS
*            CANCELED  = 1
*            OTHERS    = 2.
*
*ENDMODULE.                 " VALUE_HELP_L_FILE  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_TEXTEDIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_textedit input.
  CASE textnote_ok_code.

    WHEN 'BACK'.
      PERFORM back_program.

    WHEN 'CONT'.
*   retrieve table from control
      CALL METHOD textnote_editor->get_text_as_r3table
              IMPORTING table = textnote_table.
      textnote_itxw_note[] = textnote_table[].
      PERFORM back_program.

    WHEN 'EXIT'.
      PERFORM back_program.

    WHEN 'BREAK'.
      PERFORM back_program.

    WHEN 'CANC'.
      PERFORM back_program.

  ENDCASE.

  CLEAR textnote_ok_code.

endmodule.                 " USER_COMMAND_TEXTEDIT  INPUT
MODULE elog_user_command_0101 INPUT.
  DATA wa_txw_dir2 TYPE dart1_dir2.
  DATA: returncode(1) TYPE c,
        nrecords type n.

  CASE g_seg_ok_code.

    WHEN 'EXIT' OR 'BACK' OR 'CANC' OR 'INFO'.
      PERFORM exit_program USING g_Seg_ok_code.

    WHEN 'DISP' OR 'DETL'.
      LEAVE TO LIST-PROCESSING.
       CLEAR gt_seg_select_outtab.
      CALL METHOD g_seg_tree->get_selected_item
            IMPORTING
      e_index_outtab    = gt_seg_select_outtab.
      IF gt_seg_select_outtab IS INITIAL.
        CALL METHOD g_seg_tree->get_selected_nodes
           CHANGING
        ct_index_outtab    = gt_seg_selects[].
        READ TABLE gt_seg_selects INDEX 1.
        gt_seg_select_outtab = gt_seg_selects.
      ENDIF.
*      CLEAR: wa_txw_dir2, itxw_dirsg2.
      READ TABLE gt_seg_outtab INDEX gt_seg_select_outtab.
*      READ TABLE itxw_dirsg2 WITH KEY segtype = gt_seg_outtab-segtype
*                                    segdata = gt_seg_outtab-segdata.
*      READ TABLE itxw_dir2 INTO wa_txw_dir2
*          WITH KEY vol_id = itxw_dirsg2-vol_id.
*
*      REFRESH query_fields.
*
*      query_fields-fieldname = 'FILE_NAME'.
*      query_fields-tabname = 'TXW_DIR2'.
*      query_fields-value = wa_txw_dir2-file_name.
*      query_fields-field_obl = 'X'.
*      query_fields-novaluehlp = ' '.
*      APPEND query_fields.
*      query_fields-fieldname = 'ADDRESS'.
*      query_fields-tabname = 'TXW_DIRSG2'.
*      query_fields-value = itxw_dirsg2-address.
*      query_fields-field_obl = 'X'.
*      query_fields-novaluehlp = ' '.
*      APPEND query_fields.
*
*      if itxw_dirsg2-records > 100.
*           nrecords = 100.
*      else.
*           nrecords = itxw_dirsg2-records.
*      endif.
*      query_fields-fieldname = 'RECORDS'.
*      query_fields-tabname = 'TXW_DIRSG2'.
*      query_fields-field_obl = 'X'.
*      query_fields-novaluehlp = ' '.
*      query_fields-value = nrecords.
*      APPEND query_fields.
*
*      CALL FUNCTION 'POPUP_GET_VALUES'
*           EXPORTING
**               NO_VALUE_CHECK  = ' '
*                popup_title     = text-025
**               START_COLUMN    = '5'
**               START_ROW       = '5'
*          IMPORTING
*               returncode      = returncode
*           TABLES
*                fields          = query_fields
**          EXCEPTIONS
**               ERROR_IN_FIELDS = 1
**               OTHERS          = 2
*                .
*      IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*      ENDIF.
*
*      IF returncode IS INITIAL.
*        loop at query_fields.
*           case query_fields-fieldname.
*             when 'RECORDS'.
*                nrecords = query_fields-value.
*             when 'ADDRESS'.
*                itxw_dirsg2-address = query_fields-value.
*             when 'FILE_NAME'.
*                wa_txw_dir2-file_name = query_fields-value.
*           endcase.
*        endloop.
*      ENDIF.
*    refresh query_fields.
*
    WHEN OTHERS.
      CALL METHOD cl_gui_cfw=>dispatch.

  ENDCASE.
  CLEAR g_seg_ok_code.

ENDMODULE.                             " ELOG_USER_COMMAND_0101  INPUT







