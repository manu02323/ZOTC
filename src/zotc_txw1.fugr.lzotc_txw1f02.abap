*----------------------------------------------------------------------*
***INCLUDE LTXW1F02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f4_lfile_values_get
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RECORD_TAB  text
*      -->P_SHLP_TAB  text
*      <--P_SHLP  text
*      <--P_CALLCONTROL  text
*      <--P_RC  text
*----------------------------------------------------------------------*
FORM f4_lfile_values_get
     TABLES   p_record_tab  STRUCTURE seahlpres
              p_shlp_tab    TYPE shlp_descr_tab_t
     CHANGING p_shlp        TYPE shlp_descr_t
              p_callcontrol LIKE ddshf4ctrl
              p_rc          TYPE i.

  DATA itxw_dir2  TYPE dart1_t_dir2 WITH HEADER LINE.
  DATA source_tab TYPE dart1_t_dir2 WITH HEADER LINE.

  DATA: BEGIN OF files OCCURS 0,
        l_file TYPE dart1_lfile,
        END   OF files.


*....... get available extracts .......................................*

* read all directory entries (only vol id 00)
  CALL FUNCTION 'TXW_DATA_FILE_CLEAN_LOG'
       TABLES
            t_txw_dir2 = itxw_dir2.

  DELETE itxw_dir2 WHERE vol_id <> '00'.
  SORT itxw_dir2 BY seldate seltime deldate deltime l_file.

  LOOP AT itxw_dir2.
* remove files deleted later than they were imported
      IF itxw_dir2-deluser <> space AND
         ( itxw_dir2-deldate > itxw_dir2-alidate OR
           itxw_dir2-deldate = itxw_dir2-alidate AND
           itxw_dir2-deltime > itxw_dir2-alitime ).
        DELETE itxw_dir2.
      ELSE.
* remove files not deleted and (exported but not imported)
        IF NOT itxw_dir2-aleuser IS initial
           AND itxw_dir2-alestat = dart1_al_ok           "H950365
           AND itxw_dir2-aliuser IS initial.
          DELETE itxw_dir2.
        ELSE.
* get all logical file names
          files-l_file = itxw_dir2-l_file.
          COLLECT files.
        ENDIF.
      ENDIF.
   ENDLOOP.

** remove all files that have been archived
*  DELETE itxw_dir2 WHERE NOT aleuser IS initial
*                    AND     aliuser IS initial.
*
* get all logical file names
*  LOOP AT itxw_dir2.
*    files-l_file = itxw_dir2-l_file.
*    COLLECT files.
*  ENDLOOP.

* get only last entry for each logical file name
  LOOP AT files.
    LOOP AT itxw_dir2 WHERE l_file = files-l_file.
    ENDLOOP.
    APPEND itxw_dir2 TO source_tab.
  ENDLOOP.

*....... map to structures for exit ...................................*

  CALL FUNCTION 'F4UT_RESULTS_MAP'
       EXPORTING
            source_structure   = 'TXW_DIR2'
*           APPLY_RESTRICTIONS = ' '
       TABLES
            shlp_tab           = p_shlp_tab
            record_tab         = p_record_tab
            source_tab         = source_tab
       CHANGING
            shlp               = p_shlp
            callcontrol        = p_callcontrol
      EXCEPTIONS
           illegal_structure  = 1
           OTHERS             = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  p_rc = sy-subrc.

ENDFORM.                               " f4_lfile_values_get
*&---------------------------------------------------------------------*
*&      Form  EXIT_PROGRAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM exit_program USING p_ok_code.
  CASE p_ok_code.
    WHEN 'EXIT' OR 'CANC'.
      CALL METHOD g_seg_tree->free.
      LEAVE PROGRAM.
    WHEN 'BACK'.
*      REFRESH gt_SEG_fieldcatalog[].
*      REFRESH gt_SEG_sort[].
*      REFRESH gt_seg_outtab[].

      CALL METHOD g_seg_tree->free.
      CALL METHOD g_seg_custom_container->free.
      CLEAR g_seg_tree.
      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.
ENDFORM.                               " EXIT_PROGRAM

*&---------------------------------------------------------------------*
*&      Form  REGISTER_EVENTS
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM register_events.
* define the events which will be passed to the backend
  DATA: lt_events TYPE cntl_simple_events,
        l_event TYPE cntl_simple_event.

* define the events which will be passed to the backend
  l_event-eventid = cl_gui_column_tree=>eventid_expand_no_children.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_header_click.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_item_keypress.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_node_double_click.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_item_double_click.
  APPEND l_event TO lt_events.

  CALL METHOD g_seg_tree->set_registered_events
    EXPORTING
      events = lt_events
    EXCEPTIONS
      cntl_error                = 1
      cntl_system_error         = 2
      illegal_event_combination = 3.

* set Handler
  DATA: l_event_receiver TYPE REF TO g_seg_event_receiver.
  CREATE OBJECT l_event_receiver.
*
  SET HANDLER l_event_receiver->handle_item_double_click FOR g_seg_tree.
  SET HANDLER l_event_receiver->handle_node_double_click FOR g_seg_tree.

ENDFORM.                               " REGISTER_EVENTS

*---------------------------------------------------------------------*
*       CLASS elog_tree_event_receiver IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS g_seg_event_receiver IMPLEMENTATION.

  METHOD handle_item_double_click.
* select the data that was chosen
    tabix = index_outtab.
    CALL METHOD cl_gui_cfw=>set_new_ok_code
      EXPORTING
        new_code = 'DISP'.
  ENDMETHOD.

  METHOD handle_node_double_click.
* select the data that was chosen
    tabix = index_outtab.
    CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING new_code = 'DISP'.
  ENDMETHOD.

ENDCLASS.

*&---------------------------------------------------------------------*
*&      Form  pre_check_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OBJECT_TYPE  text
*      -->P_FILE_NAME  text
*      -->P_VOL_ID  text
*      -->P_VOLDIR  text
*      -->P_T_TXW_VWLG2  text
*      <--P_SUBRC  text
*      <--P_PHY_NAME  text
*----------------------------------------------------------------------*
*FORM pre_check_file
*                    TABLES   P_T_TXW_VWLG2 STRUCTURE TXW_VWLOG2
*                     USING    P_OBJECT_TYPE
*                             P_FILE_NAME
*                             P_VOL_ID
*                             P_VOLDIR
*                             p_file_size
*                    CHANGING P_SUBRC
*                             P_PHY_NAME.
*
*data answer(1) type c.
*data dirset type txw_volset.
*data phys_file type txw_lfile.
*data al_filename type txw_lfile.
*data file_size type txw_dskspc.
*data freespace type txw_dskspc.
*p_subrc = 4.
**read table p_txw_vwlog2 with key file_uuid = glo_file_uuid.
*
** authorization check
*  if p_object_type = 'V'.
*CALL FUNCTION 'TXW_DATA_VIEW_AUTHORITY_CHECK'
*  EXPORTING
*    ACTIVITY                = dart1_act-archive_imp
*    DATA_VIEW               = p_t_txw_vwlg2-tax_view.
*  else.
** authorization check
*  AUTHORITY-CHECK OBJECT 'F_TXW_TF'
*           ID 'ACTVT' FIELD dart1_act-archive_imp
*           ID 'BUKRS' DUMMY.
*  endif.
*  IF sy-subrc <> 0.
*    MESSAGE e012(xw).
*  ENDIF.
*
** confirm export to archive
*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*       EXPORTING
*            defaultoption = 'N'
*            textline1     = text-d01
*            textline2     = text-d02
*            titel         = text-q02
*       IMPORTING
*            answer        = answer.
*  CHECK answer = 'J'.
*
** get directory set
*  dirset = p_voldir.
*  CALL FUNCTION 'TXW_DIRECTORY_SET_GET'
*       CHANGING
*            directory_set = dirset
*       EXCEPTIONS
*            canceled      = 1.
*  CHECK sy-subrc = 0.
*
** get file name
*  CALL FUNCTION 'TXW_FILE_NAME_GET'
*       EXPORTING
*            voldir_set         = dirset
*            vol_id             = p_vol_id
*            log_filename       = p_file_name "logical file name
*       IMPORTING
*            phy_filename       = phys_file
*            logical_volid_name = al_filename.
*
*  DELETE DATASET phys_file.
*  IF sy-subrc = 0.
*    MESSAGE s232(xw) WITH phys_file.
*  ELSE.
*    MESSAGE s233(xw) WITH phys_file.
*  ENDIF.
*
**
* file_size = p_file_size.
*
** check if there is enough freespace on disk to retrieve from
*  CALL FUNCTION 'TXW_FILEPATH_FREESPACE'
*    EXPORTING
*      VOLDIR_SET                  = dirset
*   IMPORTING
*     FREE_SPACE                  = freespace
*   EXCEPTIONS
*     SPACE_NOT_DETERMINED        = 1
*     DIRECTORY_SET_INVALID       = 2
*     OTHERS                      = 3.
*  IF SY-SUBRC <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
** test for 90% condition next
*  multiply freespace by 9.
*  divide freespace by 10.
*  multiply freespace by 1024. "To kilobytes
*  multiply freespace by 1024. "To bytes
*  answer = 'J'.
*  if freespace <= file_size.
*     message w097(xw) with freespace file_size.
** confirm export to archive
*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*       EXPORTING
*            defaultoption = 'N'
*            textline1     = text-d01
*            textline2     = text-d02
*            titel         = text-q02
*       IMPORTING
*            answer        = answer.
*  endif.
*  Check answer = 'J'.
*
*
*  p_subrc = 0. "success
*
*
*ENDFORM.                    " pre_check_file
