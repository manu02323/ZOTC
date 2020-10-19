*----------------------------------------------------------------------*
***INCLUDE LTXW1O01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       pbo "enter directory set / data file"
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

   SET PF-STATUS '0100'.
   SET TITLEBAR '100'.
   TC_XFILES-LINES = 16.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_XFILES_LOOP_LINE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_XFILES_LOOP_LINE OUTPUT.

  MOVE-CORRESPONDING TC_XFILES_TAB TO TXW_XFILES.

ENDMODULE.                 " TC_XFILES_LOOP_LINE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_TEXTEDIT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_textedit output.
  IF textnote_editor IS INITIAL.

*   set status
    SET PF-STATUS 'TEXTEDIT'.
    if not textnote_edit_mode is initial.
       SET TITLEBAR 'TEXTEDIT'.
    else.
       SET TITLEBAR 'TEXTDISP'.
    endif.

*   create control container
    CREATE OBJECT textnote_custom_container
        EXPORTING
            container_name = 'TEXTEDITOR1'
        EXCEPTIONS
            cntl_error = 1
            cntl_system_error = 2
            create_error = 3
            lifetime_error = 4
            lifetime_dynpro_dynpro_link = 5.
    IF sy-subrc NE 0.
*      add your handling
    ENDIF.
    textnote_container = 'TEXTEDITOR1'.

*   create calls constructor, which initializes, creats and links
*   TextEdit Control
    CREATE OBJECT textnote_editor
          EXPORTING
           parent = textnote_custom_container
           wordwrap_mode =
*               cl_gui_textedit=>wordwrap_off
              cl_gui_textedit=>wordwrap_at_fixed_position
*              cl_gui_textedit=>WORDWRAP_AT_WINDOWBORDER
           wordwrap_position = textnoteline_length
           wordwrap_to_linebreak_mode = cl_gui_textedit=>true.

  ENDIF.

  CALL METHOD textnote_custom_container->link
          EXPORTING
               repid = textnote_repid
               container = textnote_container.

*           show toolbar and statusbar on this screen
  CALL METHOD textnote_editor->set_toolbar_mode
     EXPORTING
         toolbar_mode = textnote_editor->true.
  CALL METHOD textnote_editor->set_statusbar_mode
     EXPORTING
         statusbar_mode = textnote_editor->true.

* Set edit mode
  if textnote_edit_mode is initial.
     call METHOD textnote_editor->set_readonly_mode.
  endif.

*   send table to control
  textnote_table[] = textnote_itxw_note[].
  CALL METHOD textnote_editor->set_text_as_r3table
          EXPORTING table = textnote_table.

* finally flush
  CALL METHOD cl_gui_cfw=>flush
         EXCEPTIONS
           OTHERS = 1.
  IF sy-subrc NE 0.
*   add your handling
  ENDIF.

endmodule.                 " STATUS_TEXTEDIT  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0101 output.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
  IF g_seg_tree IS INITIAL.
    PERFORM init_elog_tree.
  ENDIF.

endmodule.                 " STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  INIT_ELOG_TREE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_elog_tree.
* repid for saving variants
  DATA: ls_variant TYPE disvariant.

  CREATE OBJECT g_seg_custom_container
      EXPORTING
            container_name = g_seg_tree_container_name
      EXCEPTIONS
            cntl_error                  = 1
            cntl_system_error           = 2
            create_error                = 3
            lifetime_error              = 4
            lifetime_dynpro_dynpro_link = 5.

* create tree control
  CREATE OBJECT g_seg_tree
    EXPORTING
        i_parent              = g_seg_custom_container
        i_node_selection_mode = cl_gui_column_tree=>node_sel_mode_single
        i_item_selection      = 'X'
        i_no_html_header      = 'X'
        i_no_toolbar          = ''
    EXCEPTIONS
        cntl_error                   = 1
        cntl_system_error            = 2
        create_error                 = 3
        lifetime_error               = 4
        illegal_node_selection_mode  = 5
        failed                       = 6
        illegal_column_name          = 7.
  IF sy-subrc <> 0.
    MESSAGE x208(00) WITH 'ERROR'.     "#EC NOTEXT
  ENDIF.

* register events
  PERFORM register_events.

  ls_variant-report = sy-repid.

* create hierarchy
  CALL METHOD g_seg_tree->set_table_for_first_display
          EXPORTING
               i_save               = 'A'
               is_variant            = ls_variant
          CHANGING
               it_sort              = gt_seg_sort
               it_outtab            = gt_seg_outtab[]
               it_fieldcatalog      = gt_seg_fieldcatalog.

  CALL METHOD g_seg_tree->expand_tree
       EXPORTING
           i_level = 1.


  CALL METHOD cl_gui_control=>set_focus EXPORTING control = g_seg_tree.

ENDFORM.                               " INIT_ELOG_TREE


