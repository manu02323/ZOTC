FUNCTION-POOL ZOTC_TXW1.                    "MESSAGE-ID ..

TYPE-POOLS dart1.

TYPE-POOLS shlp.                       "search help


TABLES: txw_c_strc,
        txw_c_soex,
        txw_c_glo,
        txw_dir,     "obsolete after rel 99 use of uuid
        txw_diral,   "obsolete after rel 99 use of uuid
        txw_dirseg,  "obsolete after rel 99 use of uuid
        txw_vwlog,   "obsolete after rel 99 use of uuid
        txw_dir2,
        txw_diral2,
        txw_dirsg2,
        txw_vwlog2,
        txw_c_v0,
        txw_xfiles,
        toaco.      "For business object in archive link

* table control for multiple file entry
CONSTANTS: screen_xfiles LIKE sy-dynnr VALUE '0100'.
CONTROLS: tc_xfiles TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF tc_xfiles_tab OCCURS 0,
      mark(1) TYPE c.                  "table control checkbox
        INCLUDE STRUCTURE txw_xfiles.
DATA: END   OF tc_xfiles_tab.

DATA: glo_canceled(1) TYPE c.

* Status block to collect error messages for conversion
DATA: BEGIN OF conv_status OCCURS 0,
         tablename(50) TYPE c,
         init_cnt(6)   TYPE n,
         conv_cnt(6)   TYPE n,
         status(1)     TYPE c, "L - locked, ? - unknown, X - converted
      END OF conv_status.


*****  Data items for text editor
CONSTANTS: textnoteline_length TYPE i VALUE 72.

DATA:
* reference to wrapper class of control
      textnote_editor TYPE REF TO cl_gui_textedit,
*     reference to custom container: necessary to bind TextEdit Control
      textnote_custom_container TYPE REF TO cl_gui_custom_container,
      textnote_repid LIKE sy-repid,
      textnote_ok_code LIKE sy-ucomm,  " return code from screen
      textnote_table(textnoteline_length) TYPE c OCCURS 0,
      textnote_container(30) TYPE c.   " string for the containers

DATA: textnote_itxw_note TYPE STANDARD TABLE OF txw_note
          WITH HEADER LINE,
      textnote_edit_mode(1) TYPE c.

* necessary to flush the automation queue
CLASS cl_gui_cfw DEFINITION LOAD.
* components for ALV grid in statistics
DATA:
      gt_seg_fieldcatalog TYPE lvc_t_fcat, "Fieldcatalog
      gt_seg_sort         TYPE lvc_t_sort, "Sortiertabelle
      gt_seg_selects TYPE lvc_t_indx WITH HEADER LINE.
*
CLASS cl_gui_column_tree DEFINITION LOAD.
DATA  g_seg_ok_code LIKE sy-ucomm.      " belongs in top-include.
DATA  g_seg_tree  TYPE REF TO cl_gui_alv_tree_simple.
*DATA  g_header(1) TYPE c.
* create container for alv-tree
DATA: g_seg_tree_container_name(30) TYPE c VALUE 'SEGMENT_CONTAINER',
        g_seg_custom_container TYPE REF TO cl_gui_custom_container.

DATA gt_seg_select_outtab TYPE lvc_index.

DATA:  BEGIN OF gt_seg_outtab OCCURS 0,
           appl    LIKE txw_dirsg2-ddtext,
           ddtext  LIKE  dd07v-ddtext,
           segtype LIKE txw_dirsg2-segtype,
           segdata LIKE txw_dirsg2-segdata,
           exp_struct LIKE txw_dirsg2-exp_struct,
       END OF gt_seg_outtab.


*---------------------------------------------------------------------*
*       CLASS elog_tree_event_receiver DEFINITION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS g_seg_event_receiver DEFINITION.

  PUBLIC SECTION.

    METHODS handle_item_double_click
      FOR EVENT item_double_click OF cl_gui_alv_tree_simple
      IMPORTING fieldname
                index_outtab
                grouplevel.

    METHODS handle_node_double_click
      FOR EVENT node_double_click OF cl_gui_alv_tree_simple
      IMPORTING index_outtab
                grouplevel.

    data:  tabix like sy-tabix.

ENDCLASS.
