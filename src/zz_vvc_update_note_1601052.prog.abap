*&---------------------------------------------------------------------*
*& Report  ZZ_VVC_UPDATE_NOTE_1601052
*&
*& Version 1.00 09/11/2011
*&
*&---------------------------------------------------------------------*
*& This report belongs to note 1601052. It has to be executed
*& manually in the development system after the coding changes
*& within the automatic correction instruction of note 1601052
*& have been implemented.
*& The report adds routine V_T682_SAVE_CHECK to the save event of
*& certain view cluster variants.
*& IMPORTANT: 1. The report records the performed changes to a
*&               transport request. These changes should be
*&               transported together with the automatic coding changes
*&               from note 1601052.
*&               The report doesn't have to be executed in target
*&               systems.
*&            2. Hence it is not necessary to transport this report
*&               to any other system.
*&---------------------------------------------------------------------*
REPORT zz_vvc_update_note_1601052.

TYPE-POOLS: slis.

CONSTANTS: lc_formname(17) TYPE c VALUE 'V_T682_SAVE_CHECK',
           lc_event_save   TYPE vclmevent VALUE '04',
           lc_color_ok     TYPE i VALUE 5,
           lc_color_err    TYPE i VALUE 6.
* Types
TYPES: BEGIN OF ty_result,
         vcl_name TYPE vcl_name,
         message(60),
         trkorr TYPE trkorr,
         color TYPE slis_t_specialcol_alv,
       END OF ty_result.

* Tables
DATA: gt_vclname  TYPE STANDARD TABLE OF vcl_name.
DATA: gt_sellist  TYPE STANDARD TABLE OF vimsellist WITH HEADER LINE.
DATA: gt_ko200    TYPE STANDARD TABLE OF ko200 WITH HEADER LINE.
DATA: gt_result   TYPE STANDARD TABLE OF ty_result.
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv.

* Structures
DATA: gs_sellist TYPE vimsellist.
DATA: gs_ko200   TYPE ko200.
DATA: gs_layout  TYPE slis_layout_alv.
DATA: gs_vclmf   TYPE vclmf.
DATA: gs_vcldir  TYPE vcldir.

* Variables
DATA: gv_exists      TYPE xfeld.
DATA: gv_vclname     TYPE vcl_name.
DATA: gv_tadir_name  TYPE sobj_name.
DATA: gv_order       TYPE trkorr.
DATA: gv_message(72) TYPE c.

* Check whether FORM exists
PERFORM check_existence CHANGING gv_exists.
IF gv_exists IS INITIAL.
  CALL FUNCTION 'POPUP_TO_INFORM'
    EXPORTING
      titel = 'Error'
      txt1  = '@3U@ Note 1601052 not yet implemented !'
      txt2  = 'Implement coding changes and repeat this report'.
  EXIT.
ENDIF.

* Build list of View Cluster Variants to be processed
gv_vclname = 'V_T682'.      APPEND gv_vclname TO gt_vclname.
gv_vclname = 'VVC_T682_CQ'. APPEND gv_vclname TO gt_vclname.
gv_vclname = 'VVC_T682_FA'. APPEND gv_vclname TO gt_vclname.
gv_vclname = 'VVC_T682_KA'. APPEND gv_vclname TO gt_vclname.
gv_vclname = 'VVC_T682_KE'. APPEND gv_vclname TO gt_vclname.
gv_vclname = 'VVC_T682_MA'. APPEND gv_vclname TO gt_vclname.
gv_vclname = 'VVC_T682_MS'. APPEND gv_vclname TO gt_vclname.
gv_vclname = 'VVC_T682_TP'. APPEND gv_vclname TO gt_vclname.
gv_vclname = 'VVC_T682_TX'. APPEND gv_vclname TO gt_vclname.
gv_vclname = 'VVC_T682_VA'. APPEND gv_vclname TO gt_vclname.

gs_sellist-viewfield = 'VCLNAME'.
gs_sellist-operator = 'EQ'.
gs_sellist-tabix = 1.
gs_sellist-ddic = 'B'.

LOOP AT gt_vclname INTO gv_vclname.
* Check whether view cluster variant exists
  SELECT SINGLE * FROM vcldir INTO gs_vcldir
       WHERE vclname = gv_vclname.
  CHECK sy-subrc EQ 0.
* Read actual entry
  SELECT SINGLE * FROM vclmf INTO gs_vclmf
         WHERE vclname = gv_vclname
           AND event = lc_event_save.
  IF sy-subrc EQ 0.
    IF gs_vclmf-formname EQ lc_formname.
      PERFORM add_message USING gv_vclname lc_color_ok ''
              'View cluster already updated.'.
    ELSE.
      PERFORM add_message USING gv_vclname lc_color_err ''
              'View cluster already uses event ''04''.'.
    ENDIF.
    CONTINUE.
  ENDIF.

* Lock view cluster variant
  REFRESH: gt_sellist, gt_ko200.
  gs_sellist-value = gv_vclname.
  APPEND gs_sellist TO gt_sellist.

* Enqueue
  CALL FUNCTION 'VIEW_ENQUEUE'
    EXPORTING
      action        = 'E'
      enqueue_mode  = 'E'
      view_name     = 'V_VCLDIR'
      enqueue_range = 'X'
    TABLES
      sellist       = gt_sellist
    EXCEPTIONS
      OTHERS        = 1.
  IF sy-subrc NE 0.
    PERFORM add_message USING gv_vclname lc_color_err ''
            'View cluster locked. Please repeat report later.'.
    CONTINUE.
  ENDIF.

* Transport Objects
  gs_ko200-pgmid    = 'R3TR'.
  gs_ko200-object   = 'VCLS'.
  gs_ko200-obj_name = gv_vclname.
  gs_ko200-objfunc  = ' '.
  APPEND gs_ko200 TO gt_ko200.
  gs_ko200-pgmid    = 'R3TR'.
  gs_ko200-object   = 'TOBJ'.
  CALL FUNCTION 'CTO_OBJECT_GET_TADIR_KEY'
    EXPORTING
      iv_objectname = gv_vclname
      iv_objecttype = 'C'
    IMPORTING
      ev_obj_name   = gv_tadir_name.
  gs_ko200-obj_name = gv_tadir_name.
  gs_ko200-objfunc  = ' '.
  APPEND gs_ko200 TO gt_ko200.

* Check and insert entries
  CALL FUNCTION 'TR_OBJECTS_CHECK'
    EXPORTING
      iv_no_show_option = 'X'
    TABLES
      wt_ko200          = gt_ko200
    EXCEPTIONS
      OTHERS            = 1.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE 'I'
            NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            INTO gv_message.
    PERFORM add_message USING gv_vclname lc_color_err '' gv_message.
    CONTINUE.
  ENDIF.
  CALL FUNCTION 'TR_OBJECTS_INSERT'
    EXPORTING
      wi_order          = gv_order
      iv_no_show_option = 'X'
    IMPORTING
      we_order          = gv_order
    TABLES
      wt_ko200          = gt_ko200
    EXCEPTIONS
      OTHERS            = 01.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE 'I'
            NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            INTO gv_message.
    PERFORM add_message USING gv_vclname lc_color_err '' gv_message.
    CONTINUE.
  ENDIF.

* Update View Cluster Variant
  gs_vclmf-vclname = gv_vclname.
  gs_vclmf-event = lc_event_save.
  gs_vclmf-formname = lc_formname.
  INSERT vclmf FROM gs_vclmf.
  UPDATE vcldir
         SET author = sy-uname
         changedate = sy-datlo
         WHERE vclname = gv_vclname.

* Dequeue
  CALL FUNCTION 'VIEW_ENQUEUE'
    EXPORTING
      action        = 'D'
      enqueue_mode  = 'E'
      view_name     = 'V_VCLDIR'
      enqueue_range = 'X'
    TABLES
      sellist       = gt_sellist.

* Success Message
  PERFORM add_message USING gv_vclname lc_color_ok gv_order
          'View cluster successfully updated.'.
ENDLOOP.

PERFORM fieldcat_build_alv CHANGING gt_fieldcat.
PERFORM layout_alv_build CHANGING gs_layout.

CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
  EXPORTING
    is_layout   = gs_layout
    it_fieldcat = gt_fieldcat
  TABLES
    t_outtab    = gt_result.

*&---------------------------------------------------------------------*
*&      Form  fieldcat_build_alv
*&---------------------------------------------------------------------*
FORM fieldcat_build_alv CHANGING xt_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: gs_fieldcat TYPE slis_fieldcat_alv.

  gs_fieldcat-fieldname    = 'VCL_NAME'.
  gs_fieldcat-rollname     = 'VCL_NAME'.
  APPEND gs_fieldcat TO xt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname    = 'MESSAGE'.
  gs_fieldcat-reptext_ddic = 'Message'.
  APPEND gs_fieldcat TO xt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname    = 'TRKORR'.
  gs_fieldcat-rollname     = 'TRKORR'.
  APPEND gs_fieldcat TO xt_fieldcat.

ENDFORM.                    "fieldcat_build_alv

*&---------------------------------------------------------------------*
*&      Form  layout_alv_build
*&---------------------------------------------------------------------*
FORM layout_alv_build CHANGING xv_layout TYPE slis_layout_alv.

  xv_layout-colwidth_optimize = 'X'.
  xv_layout-zebra             = 'X'.
  xv_layout-coltab_fieldname  = 'COLOR'.

ENDFORM.                    " LAYOUT_ALV_BUILD

*&---------------------------------------------------------------------*
*&      Form  add_message
*&---------------------------------------------------------------------*
FORM add_message USING pv_vclname TYPE vcl_name
                       pv_color   TYPE i
                       pv_trkorr  TYPE trkorr
                       pv_message TYPE c.
  DATA: ls_result TYPE ty_result.
  DATA: ls_color  TYPE slis_specialcol_alv.

  ls_result-vcl_name = pv_vclname.
  ls_result-message = pv_message.
  ls_result-trkorr = pv_trkorr.
  REFRESH ls_result-color.
  ls_color-color-col = pv_color.
  ls_color-color-int = 0.
  ls_color-fieldname = 'MESSAGE'.
  APPEND ls_color TO ls_result-color.
  APPEND ls_result TO gt_result.

ENDFORM.                    "add_message

*&---------------------------------------------------------------------*
*&      Form  check_existence
*&---------------------------------------------------------------------*
FORM check_existence CHANGING xv_exists TYPE xfeld.

  DATA: lt_source TYPE STANDARD TABLE OF char100.
  DATA: ls_source TYPE string.

  CLEAR xv_exists.
  READ REPORT 'F080MF01' INTO lt_source.
  IF sy-subrc NE 0.
    READ REPORT 'SAPF080M' INTO lt_source.
  ENDIF.
  LOOP AT lt_source INTO ls_source.
    IF ls_source CS lc_formname.
      xv_exists = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "check_existence
