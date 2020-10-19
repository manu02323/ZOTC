*&---------------------------------------------------------------------*
*&  Include           MZOTC_0362_ORDER_ENTRY_F01
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  MZOTC_0362_ORDER_ENTRY_F01                              *
* TITLE      :  EHQ_USPA_Order Entry                                   *
* DEVELOPER  :  Neha Garg                                              *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0362                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:   Create order using Split Idoc logic for EHQ/USPA      *
*                scenarios and Biorad/Diamed Scenarios.                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT  DESCRIPTION                        *
* ===========  ========  ========== ===================================*
* 04-10-2016   NGARG     E1DK922236 Initial Development
* ===========  ========  ========== ===================================*
* 27-10-2016   NGARG     E1DK922236 Defect#5694:                       *
*                                   a)No option to come out of the     *
*                                   Custom Order entry screen          *
*                                   b)Fix table control to take more   *
*                                   than one entry at once             *
*                                   c) Error message should come for   *
*                                   the material it is generated for,  *
*                                   not all
* ===========  ========  ========== ===================================*
* 08-11-2016   U033814   E1DK922236 Defect # 6154 :
*                                   Material Validation is incorrect
*&---------------------------------------------------------------------*
*&      Form  F_USER_OK_TC                                             *
*&---------------------------------------------------------------------*
*       Table control user command functionality
*&---------------------------------------------------------------------*
 FORM f_user_ok_tc USING  fp_tc_name TYPE dynfnam   " Field name
                          fp_table_name  TYPE any
                          fp_mark_name   TYPE any
                 CHANGING fp_ok      TYPE sy-ucomm. " Function code that PAI triggered


   CONSTANTS : lc_insert TYPE sy-ucomm VALUE  'INSR', " Function code that PAI triggered
               lc_delete TYPE sy-ucomm VALUE  'DELE', " Function code that PAI triggered
               lc_top    TYPE sy-ucomm VALUE  'P--',  " Function code that PAI triggered
               lc_prev   TYPE sy-ucomm VALUE  'P-',   " Function code that PAI triggered
               lc_next   TYPE sy-ucomm VALUE  'P+',   " Function code that PAI triggered
               lc_bottom TYPE sy-ucomm VALUE  'P++',  " Function code that PAI triggered
               lc_mark   TYPE sy-ucomm VALUE  'MARK', " Function code that PAI triggered
               lc_demark TYPE sy-ucomm VALUE  'DMRK'. " Function code that PAI triggered

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA: lv_ok              TYPE sy-ucomm. " Function code that PAI triggered
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: execute general and TC specific operations                 *

   CASE fp_ok.

*    Insert row
     WHEN lc_insert.
       PERFORM f_code_insert_row USING    fp_tc_name
                                         fp_table_name.
       CLEAR fp_ok.

*    Delete Row
     WHEN lc_delete. "delete row

       PERFORM f_code_delete_row USING    fp_tc_name
                                         fp_table_name
                                         fp_mark_name.
       CLEAR fp_ok.

*    Scrolling
     WHEN lc_top OR   "top of list
          lc_prev  OR "previous page
          lc_next  OR "next page
          lc_bottom.  "bottom of list

       PERFORM f_compute_scrolling_in_tc USING fp_tc_name
                                             lv_ok.
       CLEAR fp_ok.

*    Mark rows
     WHEN lc_mark. "mark all filled lines
       PERFORM f_code_tc_mark_lines USING fp_tc_name
                                         fp_table_name
                                         fp_mark_name   .
       CLEAR fp_ok.

*    Demark Rows
     WHEN lc_demark. "demark all filled lines
       PERFORM f_code_tc_demark_lines USING fp_tc_name
                                           fp_table_name
                                           fp_mark_name .
       CLEAR fp_ok.
   ENDCASE.

 ENDFORM. " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  F_CODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
*       Insert row to table control
*&---------------------------------------------------------------------*

 FORM f_code_insert_row USING    fp_tc_name           TYPE dynfnam " Field name
                                 fp_table_name  TYPE any .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA lv_lines_name       TYPE scrfname. " Name of a Screen Element
   DATA lv_selline          TYPE sy-stepl. " Index of Current Step Loop Line
   DATA lv_lastline         TYPE i  . " Lastline of type Integers
   DATA lv_line             TYPE i. " Line of type Integers
   DATA lv_table_name       TYPE scrfname. " Name of a Screen Element
   FIELD-SYMBOLS <lfs_tc>                 TYPE cxtab_control.
   FIELD-SYMBOLS <lfs_table>              TYPE STANDARD TABLE.
   FIELD-SYMBOLS <lfs_lines>              TYPE i. " Field-symbols <lines> of type Integers
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   CONSTANTS : lc_g TYPE char3 VALUE 'GV_',         " G of type CHAR2
               lc_lines  TYPE char6 VALUE '_LINES', " Lines of type CHAR6
               lc_bracket TYPE char2 VALUE '[]'.    " Bracket of type CHAR2

   ASSIGN (fp_tc_name) TO <lfs_tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE fp_table_name
               lc_bracket
          INTO lv_table_name. "table body
   ASSIGN (lv_table_name) TO <lfs_table>. "not headerline

*&SPWIZARD: get looplines of TableControl                              *
   CONCATENATE lc_g
               fp_tc_name
               lc_lines
          INTO lv_lines_name.
   ASSIGN (lv_lines_name) TO <lfs_lines>.

*&SPWIZARD: get current line                                           *
   GET CURSOR LINE lv_selline.
   IF sy-subrc <> 0. " append line to table
     lv_selline = <lfs_tc>-lines + 1.
*&SPWIZARD: set top line                                               *
     IF lv_selline > <lfs_lines>.
       <lfs_tc>-top_line = lv_selline - <lfs_lines> + 1 .
     ELSE. " ELSE -> IF lv_selline > <lfs_lines>
       <lfs_tc>-top_line = 1.
     ENDIF. " IF lv_selline > <lfs_lines>
   ELSE. " ELSE -> IF sy-subrc <> 0
     lv_selline = <lfs_tc>-top_line + lv_selline - 1.
     lv_lastline = <lfs_tc>-top_line + <lfs_lines> - 1.
   ENDIF. " IF sy-subrc <> 0
*&SPWIZARD: set new cursor line                                        *
   lv_line = lv_selline - <lfs_tc>-top_line + 1.

*&SPWIZARD: insert initial line                                        *
   INSERT INITIAL LINE INTO <lfs_table> INDEX lv_selline.
   <lfs_tc>-lines = <lfs_tc>-lines + 1.
*&SPWIZARD: set cursor                                                 *
   SET CURSOR LINE lv_line.
   CLEAR lv_lastline.
 ENDFORM. " F_CODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  F_CODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
*     Delete row from table control
*&---------------------------------------------------------------------*

 FORM f_code_delete_row     USING    fp_tc_name           TYPE dynfnam " Field name
                                     fp_table_name  TYPE any
                                     fp_mark_name   TYPE any.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA lv_table_name       TYPE scrfname. " Name of a Screen Element

   FIELD-SYMBOLS <lfs_tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <lfs_table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <lfs_wa>  TYPE any. "Type ANY is used as the type of the structure is determined at runtime
   FIELD-SYMBOLS <lfs_mark_field> TYPE any . "Type ANY is used as the type of the structure is determined at runtime
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*
   CONSTANTS : lc_bracket TYPE char2 VALUE '[]'. " Bracket of type CHAR2


   ASSIGN (fp_tc_name) TO <lfs_tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE fp_table_name lc_bracket INTO lv_table_name. "table body
   ASSIGN (lv_table_name) TO <lfs_table>. "not headerline

*&SPWIZARD: delete marked lines                                        *
   DESCRIBE TABLE <lfs_table> LINES <lfs_tc>-lines.

   LOOP AT <lfs_table> ASSIGNING <lfs_wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT fp_mark_name OF STRUCTURE <lfs_wa> TO <lfs_mark_field>.

     IF <lfs_mark_field> = abap_true.
       DELETE <lfs_table> INDEX syst-tabix.
       IF sy-subrc = 0.
         <lfs_tc>-lines = <lfs_tc>-lines - 1.
       ENDIF. " IF sy-subrc = 0
     ENDIF. " IF <lfs_mark_field> = abap_true
   ENDLOOP. " LOOP AT <lfs_table> ASSIGNING <lfs_wa>

 ENDFORM. " F_CODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       Scrolling functionality in table control
*----------------------------------------------------------------------*
 FORM f_compute_scrolling_in_tc USING    fp_tc_name TYPE any
                                         fp_ok  TYPE any.
*&SPWIZARD: BEGIN OF LOCAL DATA---  -------------------------------------*
   DATA lv_tc_new_top_line     TYPE i. " Tc_new_top_line of type Integers
   DATA lv_tc_name             TYPE scrfname. " Name of a Screen Element
   DATA lv_tc_lines_name       TYPE scrfname. " Name of a Screen Element
   DATA lv_tc_field_name       TYPE scrfname. " Name of a Screen Element

   FIELD-SYMBOLS <lfs_tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <lfs_lines>      TYPE i. " Field-symbols <lines> of type Integers
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*
   CONSTANTS : lc_g TYPE char3 VALUE 'GV_',         " G of type CHAR2
               lc_lines  TYPE char6 VALUE '_LINES'. " Lines of type CHAR6

   ASSIGN (fp_tc_name) TO <lfs_tc>.
*&SPWIZARD: get looplines of TableControl                              *
   CONCATENATE lc_g fp_tc_name lc_lines INTO lv_tc_lines_name.
   ASSIGN (lv_tc_lines_name) TO <lfs_lines>.


*&SPWIZARD: is no line filled?                                         *
   IF <lfs_tc>-lines = 0.
*&SPWIZARD: yes, ...                                                   *
     lv_tc_new_top_line = 1.
   ELSE. " ELSE -> IF <lfs_tc>-lines = 0
*&SPWIZARD: no, ...                                                    *
     CALL FUNCTION 'SCROLLING_IN_TABLE'
       EXPORTING
         entry_act      = <lfs_tc>-top_line
         entry_from     = 1
         entry_to       = <lfs_tc>-lines
         last_page_full = abap_true
         loops          = <lfs_lines>
         ok_code        = fp_ok
         overlapping    = abap_true
       IMPORTING
         entry_new      = lv_tc_new_top_line
       EXCEPTIONS
         OTHERS         = 0.
   ENDIF. " IF <lfs_tc>-lines = 0

*&SPWIZARD: get actual tc and column                                   *
   GET CURSOR FIELD lv_tc_field_name
              AREA  lv_tc_name.

   IF syst-subrc = 0.
     IF lv_tc_name = fp_tc_name.
*&SPWIZARD: et actual column                                           *
       SET CURSOR FIELD lv_tc_field_name LINE 1.
     ENDIF. " IF lv_tc_name = fp_tc_name
   ENDIF. " IF syst-subrc = 0

*&SPWIZARD: set the new top line                                       *
   <lfs_tc>-top_line = lv_tc_new_top_line.


 ENDFORM. " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
 FORM f_code_tc_mark_lines USING fp_tc_name TYPE any
                                fp_table_name TYPE any
                                fp_mark_name  TYPE any.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
   DATA lv_table_name       TYPE scrfname. " Name of a Screen Element

   FIELD-SYMBOLS <lfs_tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <lfs_table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <lfs_wa> TYPE any. "Type ANY is used as the type of the structure is determined at runtime
   FIELD-SYMBOLS <lfs_mark_field> TYPE any. "Type ANY is used as the type of the structure is determined at runtime
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*
   CONSTANTS : lc_bracket TYPE char2 VALUE '[]'. " Bracket of type CHAR2

   ASSIGN (fp_tc_name) TO <lfs_tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE fp_table_name lc_bracket INTO lv_table_name. "table body
   ASSIGN (lv_table_name) TO <lfs_table>. "not headerline

*&SPWIZARD: mark all filled lines                                      *
   LOOP AT <lfs_table> ASSIGNING <lfs_wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT fp_mark_name OF STRUCTURE <lfs_wa> TO <lfs_mark_field>.

     <lfs_mark_field> = abap_true.
   ENDLOOP. " LOOP AT <lfs_table> ASSIGNING <lfs_wa>
 ENDFORM. "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
 FORM f_code_tc_demark_lines USING fp_tc_name TYPE any
                                  fp_table_name TYPE any
                                  fp_mark_name TYPE any.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA lv_table_name       TYPE scrfname. " Name of a Screen Element

   FIELD-SYMBOLS <lfs_tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <lfs_table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <lfs_wa> TYPE any. "Type ANY is used as the type of the structure is determined at runtime
   FIELD-SYMBOLS <lfs_mark_field> TYPE any. "Type ANY is used as the type of the structure is determined at runtime
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*
   CONSTANTS : lc_bracket TYPE char2 VALUE '[]'. " Bracket of type CHAR2

   ASSIGN (fp_tc_name) TO <lfs_tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE fp_table_name lc_bracket INTO lv_table_name. "table body
   ASSIGN (lv_table_name) TO <lfs_table>. "not headerline

*&SPWIZARD: demark all filled lines                                    *
   LOOP AT <lfs_table> ASSIGNING <lfs_wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT fp_mark_name OF STRUCTURE <lfs_wa> TO <lfs_mark_field>.

     <lfs_mark_field> = space.
   ENDLOOP. " LOOP AT <lfs_table> ASSIGNING <lfs_wa>
 ENDFORM. "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_DOC_TYPE
*&---------------------------------------------------------------------*
*      Validate Sales order doc type
*----------------------------------------------------------------------*
 FORM f_check_doc_type USING fp_gv_doc_type TYPE auart .

   DATA : lv_auart TYPE auart. " Sales Document Type

   IF gv_doc_type IS NOT INITIAL.
     SELECT SINGLE auart " Sales Document Type
       INTO lv_auart
       FROM tvak         " Sales Document Types
       WHERE auart = fp_gv_doc_type.
     IF sy-subrc NE 0.
       MESSAGE e100.
       LEAVE LIST-PROCESSING.
     ENDIF. " IF sy-subrc NE 0
   ENDIF. " IF gv_doc_type IS NOT INITIAL
 ENDFORM. " F_CHECK_DOC_TYPE
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_VTWEG
*&---------------------------------------------------------------------*
*       Validate Distribution Channel
*----------------------------------------------------------------------*
 FORM f_check_vtweg USING fp_gv_vtweg TYPE vtweg . " Distribution Channel

   DATA : lv_vtweg TYPE vtweg. " Distribution Channel

   SELECT SINGLE vtweg " Distribution Channel
     INTO lv_vtweg
     FROM tvtw         " Organizational Unit: Distribution Channels
     WHERE vtweg = fp_gv_vtweg.
   IF sy-subrc NE 0.
     MESSAGE e985.
     LEAVE LIST-PROCESSING.
   ENDIF. " IF sy-subrc NE 0

 ENDFORM. " F_CHECK_VTWEG
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_SOLD_TO
*&---------------------------------------------------------------------*
*       Check Sold to Partner number
*----------------------------------------------------------------------*
 FORM f_check_sold_to CHANGING fp_gv_sold_to TYPE kunnr       " Sold-to party
                               fp_gv_sold_name TYPE name1_gp. " Name 1

   DATA : lv_error TYPE flag. " General Flag

   CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
     EXPORTING
       input  = fp_gv_sold_to
     IMPORTING
       output = fp_gv_sold_to.
   CLEAR lv_error.
   PERFORM f_check_kunnr USING fp_gv_sold_to
                 CHANGING fp_gv_sold_name
                          lv_error.
   IF lv_error IS NOT INITIAL.
     MESSAGE e993.
     LEAVE LIST-PROCESSING.
   ENDIF. " IF lv_error IS NOT INITIAL

 ENDFORM. " F_CHECK_SOLD_TO
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_SHIP_TO
*&---------------------------------------------------------------------*
*       Check Sip to Number
*----------------------------------------------------------------------*
 FORM f_check_ship_to CHANGING fp_gv_ship_to TYPE kunnr       " Customer Number
                               fp_gv_ship_name TYPE name1_gp. " Name 1

   DATA : lv_error TYPE flag. " General Flag

   CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
     EXPORTING
       input  = fp_gv_ship_to
     IMPORTING
       output = fp_gv_ship_to.

   CLEAR lv_error.
   PERFORM f_check_kunnr USING fp_gv_ship_to
                CHANGING fp_gv_ship_name
                         lv_error.
   IF lv_error IS NOT INITIAL.
     MESSAGE e992.
     LEAVE LIST-PROCESSING.
   ENDIF. " IF lv_error IS NOT INITIAL
 ENDFORM. "f_check_ship_to
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_BSARK
*&---------------------------------------------------------------------*
*       Check PO type
*----------------------------------------------------------------------*
 FORM f_check_bsark  USING    fp_gv_bsark TYPE bsark. " Customer purchase order type

   DATA: lv_bsark TYPE bsark. " Customer purchase order type

   SELECT SINGLE bsark " Customer purchase order type
      FROM t176        " Sales Documents: Customer Order Types
      INTO lv_bsark
     WHERE bsark EQ fp_gv_bsark.
   IF sy-subrc NE 0.
     MESSAGE e102.
     LEAVE LIST-PROCESSING.
   ENDIF. " IF sy-subrc NE 0

 ENDFORM. " F_CHECK_BSARK
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_VSBED
*&---------------------------------------------------------------------*
*       Check Shipping Conditions
*----------------------------------------------------------------------*
 FORM f_check_vsbed  USING    fp_v_vsbed TYPE vsbed. " Shipping Conditions

   DATA : lv_vsbed TYPE vsbed. " Shipping Conditions

   SELECT SINGLE vsbed " Shipping Conditions
      INTO lv_vsbed
     FROM tvsb         " Shipping Conditions
     WHERE vsbed EQ fp_v_vsbed.
   IF sy-subrc NE 0.
     MESSAGE e036.
   ENDIF. " IF sy-subrc NE 0
 ENDFORM. " F_CHECK_VSBED
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_ORDER
*&---------------------------------------------------------------------*
*       Validate order data
*----------------------------------------------------------------------*
 FORM f_validate_order  CHANGING fp_i_error_log TYPE ty_t_error.


   DATA : lwa_head    TYPE zotc_850_so_header, " Sales Order Header for IDD 0009 - 850
          li_item     TYPE zotc_tt_850_so_item.

   PERFORM f_prepare_data CHANGING  lwa_head
                                       li_item.

   PERFORM f_validate_order_data USING lwa_head
                              CHANGING  li_item
                                       fp_i_error_log.
 ENDFORM. " F_VALIDATE_ORDER
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_ORDER
*&---------------------------------------------------------------------*
*       Create order
*----------------------------------------------------------------------*
 FORM f_create_order CHANGING  fp_i_error TYPE ty_t_error.

   DATA : lref_object TYPE REF TO zotc_cl_inb_so_edi_850, " Inbound Sales Order EDI 850
          lwa_head    TYPE zotc_850_so_header,            " Sales Order Header for IDD 0009 - 850
          li_item     TYPE zotc_tt_850_so_item,
          lwa_error    TYPE ty_error.

   FIELD-SYMBOLS : <lfs_item> TYPE zotc_850_so_item. " Sales Order Item for IDD 0009 - 850

   PERFORM f_prepare_data CHANGING  lwa_head
                                    li_item.

*   PERFORM f_validate_order_data USING lwa_head
*                              CHANGING li_item
*                                       fp_i_error.

   READ TABLE fp_i_error WITH KEY type = c_error TRANSPORTING NO FIELDS . " I_error with key of type
   IF sy-subrc NE 0.
     CLEAR fp_i_error.
     CREATE OBJECT lref_object.

     CALL METHOD lref_object->determine_orders
       EXPORTING
         im_head = lwa_head
       CHANGING
         ch_item = li_item.

     LOOP AT li_item ASSIGNING <lfs_item>.
*    Begin of change for defect#5694 by NGARG
       IF <lfs_item>-type IS NOT INITIAL
       OR <lfs_item>-message IS NOT INITIAL.
*    End of change for defect#5694 by NGARG
         lwa_error-type = <lfs_item>-type.
         lwa_error-message = <lfs_item>-message.
         lwa_error-order   = <lfs_item>-vbeln.
         lwa_error-matnr = <lfs_item>-matnr.
         APPEND lwa_error TO fp_i_error.
         CLEAR lwa_error.
*    Begin of change for defect#5694 by NGARG
       ENDIF. " IF <lfs_item>-type IS NOT INITIAL
*    End of change for defect#5694 by NGARG
     ENDLOOP. " LOOP AT li_item ASSIGNING <lfs_item>
   ENDIF. " IF sy-subrc NE 0
 ENDFORM. " F_CREATE_ORDER
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_AND_INIT_ALV
*&---------------------------------------------------------------------*
*       Create and Initialize ALV
*----------------------------------------------------------------------*
 FORM f_create_and_init_alv .

   DATA : lwa_variant TYPE disvariant,             " Layout (External Use)
          lwa_layout TYPE lvc_s_layo,              " ALV control: Layout structure
          li_fieldcat    TYPE lvc_t_fcat ##needed. "Global Variable required to aceess data across screens/modules                           "Fieldcatalog Internal tab


   CONSTANTS: lc_save TYPE char1 VALUE 'A', " Save of type CHAR1
              lc_1 TYPE i VALUE 1,          " 1 of type Integers
              lc_2 TYPE i  VALUE 2,         " 2 of type Integers
              lc_19 TYPE i VALUE 19.        " 10 of type Integers


*Create the container
   CREATE OBJECT gref_custom_container
     EXPORTING
       container_name = c_cont.

*  *Create TOP-Document

   CREATE OBJECT gref_dyndoc_id
     EXPORTING
       style = c_alv.

*Split the custom_container to two containers and move the reference
*to receiving containers g_parent_html and g_parent_grid
*allocating the space for grid and top of page

*Create Splitter for custom_container
   CREATE OBJECT gref_splitter
     EXPORTING
       parent  = gref_custom_container
       rows    = lc_2
       columns = lc_1.

   CALL METHOD gref_splitter->get_container
     EXPORTING
       row       = lc_1
       column    = lc_1
     RECEIVING
       container = gref_parent_grid1.

   CALL METHOD gref_splitter->get_container
     EXPORTING
       row       = lc_2
       column    = lc_1
     RECEIVING
       container = gref_parent_grid.

*Set height
   CALL METHOD gref_splitter->set_row_height
     EXPORTING
       id     = lc_1
       height = lc_19.

*specify parent as splitter part which we alloted for grid
   CREATE OBJECT gref_grid
     EXPORTING
       i_appl_events = abap_true
       i_parent      = gref_parent_grid.

   CREATE OBJECT gref_handler.
*   SET HANDLER gref_handler->handle_double_click FOR gref_grid.
   SET HANDLER gref_handler->top_of_page FOR gref_grid.
   SET HANDLER gref_handler->handle_double_click FOR gref_grid.
*   Build fieldcat
   PERFORM f_build_fieldcat CHANGING li_fieldcat.
* Layout Variant
   lwa_variant-report = sy-repid.
   lwa_variant-username = sy-uname.


* Layout of ALV
   lwa_layout-zebra = abap_true.
   lwa_layout-cwidth_opt = abap_true.


   CALL METHOD gref_grid->set_table_for_first_display
     EXPORTING
       is_layout       = lwa_layout
       is_variant      = lwa_variant
       i_save          = lc_save
     CHANGING
       it_fieldcatalog = li_fieldcat[]
       it_outtab       = i_error_log[].

*Initializing document
   CALL METHOD gref_dyndoc_id->initialize_document.

* Processing events
   CALL METHOD gref_grid->list_processing_events
     EXPORTING
       i_event_name = c_top
       i_dyndoc_id  = gref_dyndoc_id.

* Setting focus for created grid control
   CALL METHOD cl_gui_control=>set_focus
     EXPORTING
       control = gref_grid.

 ENDFORM. " F_CREATE_AND_INIT_ALV
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       Build fieldcatalog
*----------------------------------------------------------------------*
 FORM f_build_fieldcat CHANGING fp_i_fieldcat TYPE lvc_t_fcat .

   CONSTANTS: lc_error_log TYPE tabname     VALUE 'I_ERROR_LOG', " Table Name
              lc_msgtyp    TYPE fieldname   VALUE 'TYPE',        " Field Name
              lc_matnr     TYPE fieldname   VALUE 'MATNR',       " Field Name
              lc_220       TYPE outputlen   VALUE 220,           " 220 of type Integers
              lc_0         TYPE col_pos     VALUE 0,             " Position of column in output list
              lc_1         TYPE col_pos     VALUE 1,             " Position of column in output list
              lc_2         TYPE col_pos     VALUE 2.             " Position of column in output list


   PERFORM f_fill_fieldcat USING lc_msgtyp
                                 lc_error_log
                                 'Message Type'(006)
                                 lc_220
                                 lc_0
                                 abap_true
                      CHANGING   fp_i_fieldcat.
   PERFORM f_fill_fieldcat USING lc_matnr
                                    lc_error_log
                                    'Material No'(005)
                                    lc_220
                                    lc_1
                                    abap_true
                           CHANGING fp_i_fieldcat.

   PERFORM f_fill_fieldcat USING c_message
                                 lc_error_log
                                 'Message'(004)
                                 lc_220
                                 lc_2
                                 abap_true
                      CHANGING  fp_i_fieldcat.




 ENDFORM. " F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_FILL_FIELDCAT
*&---------------------------------------------------------------------*
*       Fill fieldcatalog
*----------------------------------------------------------------------*
 FORM f_fill_fieldcat USING fp_fieldname  TYPE fieldname " Field Name
                            fp_tabname    TYPE tabname   " Table Name
                            fp_seltext    TYPE scrtext_l " Long Field Label
                            fp_collength  TYPE outputlen " Output Length
                            fp_col_pos    TYPE col_pos   " Position of column in output list
                            fp_just       TYPE just      " Justification: 'R'ight, 'L'eft, 'C'entered
                  CHANGING fp_i_fieldcat  TYPE lvc_t_fcat.


   DATA:        lwa_fieldcat   TYPE lvc_s_fcat. " ALV control: Field catalog

   CLEAR lwa_fieldcat.
   lwa_fieldcat-fieldname  = fp_fieldname.
   lwa_fieldcat-tabname    = fp_tabname.
   lwa_fieldcat-outputlen  = fp_collength.
   lwa_fieldcat-scrtext_l  = fp_seltext.
   lwa_fieldcat-col_pos    = fp_col_pos.
   lwa_fieldcat-just       = fp_just.
   APPEND lwa_fieldcat TO fp_i_fieldcat.
   CLEAR: lwa_fieldcat.
 ENDFORM. " F_FILL_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_EVENT_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       Top Of Page
*----------------------------------------------------------------------*
 FORM f_event_top_of_page  USING    fp_ref_dyndoc_id TYPE REF TO cl_dd_document. " Dynamic Documents: Document

* Create TOP-Document
   CREATE OBJECT fp_ref_dyndoc_id
     EXPORTING
       style = c_alv.

* Populating header to top-of-page
   CALL METHOD fp_ref_dyndoc_id->add_text
     EXPORTING
       text      = 'Order Entry'(001)
       sap_style = cl_dd_area=>heading.


   PERFORM f_top_values CHANGING  fp_ref_dyndoc_id.

*  Merge Lines to form a document
   CALL METHOD fp_ref_dyndoc_id->merge_document.

* Display Top-of-Page Document.
   CALL METHOD fp_ref_dyndoc_id->display_document
     EXPORTING
       reuse_control      = abap_true
       parent             = gref_parent_grid1
     EXCEPTIONS
       html_display_error = 1.

 ENDFORM. " F_EVENT_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  F_TOP_VALUES
*&---------------------------------------------------------------------*
*       Populate values in Top of page
*----------------------------------------------------------------------*
 FORM f_top_values  CHANGING fp_gref_dyndoc_id TYPE REF TO cl_dd_document. " Dynamic Documents: Document

   DATA: lx_address TYPE bapiaddr3,                                   "User Address Data
           li_return  TYPE STANDARD TABLE OF bapiret2 INITIAL SIZE 0, "return table
           lv_text    TYPE sdydo_text_element,                        "Text
           lv_date    TYPE char10,                                    "date variable
           lv_time    TYPE char10.                                    "time variable

   CONSTANTS : lc_slash TYPE char1 VALUE '/', " Slash of type CHAR1
               lc_colon TYPE char1 VALUE ':', " Colon of type CHAR1
               lc_15   TYPE i VALUE 15.       " 15 of type Integers

   CALL METHOD fp_gref_dyndoc_id->new_line.

*Populating user name
   CALL METHOD fp_gref_dyndoc_id->new_line.

   CALL METHOD fp_gref_dyndoc_id->add_text
     EXPORTING
       text         = 'User Name'(002)
       sap_emphasis = cl_dd_area=>strong. " For bold

* Adding GAP
   CALL METHOD fp_gref_dyndoc_id->add_gap
     EXPORTING
       width = lc_15.
* Get user details
   CALL FUNCTION 'BAPI_USER_GET_DETAIL'
     EXPORTING
       username = sy-uname
     IMPORTING
       address  = lx_address
     TABLES
       return   = li_return.

   lv_text = lx_address-fullname.

   CALL METHOD fp_gref_dyndoc_id->add_text
     EXPORTING
       text = lv_text.

*Populating date and time
   CALL METHOD fp_gref_dyndoc_id->new_line.

   CALL METHOD fp_gref_dyndoc_id->add_text
     EXPORTING
       text         = 'Date and Time'(003)
       sap_emphasis = cl_dd_area=>strong. " For bold

* Adding GAP
   CALL METHOD fp_gref_dyndoc_id->add_gap
     EXPORTING
       width = 9.

   CONCATENATE   sy-uzeit+0(2)
                 sy-uzeit+2(2)
                 sy-uzeit+4(2)
            INTO lv_time
            SEPARATED BY lc_colon.

   CONCATENATE sy-datum+4(2)
               sy-datum+6(2)
               sy-datum+0(4)
          INTO lv_date
          SEPARATED BY lc_slash.
   CLEAR lv_text.
   CONCATENATE lv_date lv_time INTO lv_text SEPARATED BY space.

   CALL METHOD fp_gref_dyndoc_id->add_text
     EXPORTING
       text = lv_text.


* Adding GAP
   CALL METHOD fp_gref_dyndoc_id->add_gap
     EXPORTING
       width = 10.

   CLEAR lv_text.


 ENDFORM. " F_TOP_VALUES
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_MATERIAL
*&---------------------------------------------------------------------*
*       Validate material number input by user in screen
*----------------------------------------------------------------------*
 FORM f_check_material  CHANGING    fp_matnr TYPE matnr . " Material Number

   DATA : lv_matnr TYPE matnr. " Material Number

*   remove any gaps
   CONDENSE fp_matnr.

*  Get Material details
   SELECT SINGLE matnr " Material Number
     FROM mara         " General Material Data
     INTO lv_matnr
     WHERE matnr EQ fp_matnr.
* Begin of Defect - 6151
*   IF sy-subrc NE 0.
**    No material is found hence try with deleteing leading zeroes (if any) in material number
*     CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*       EXPORTING
*         input  = fp_matnr
*       IMPORTING
*         output = fp_matnr.
*
*     SELECT SINGLE matnr " Material Number
*       FROM mara         " General Material Data
*       INTO lv_matnr
*       WHERE matnr EQ fp_matnr.
* End of Defect -6151
     IF sy-subrc NE 0.
*      Show error message
       MESSAGE e274 WITH fp_matnr.
     ENDIF. " IF sy-subrc NE 0
*   ENDIF. " IF sy-subrc NE 0

 ENDFORM. " F_CHECK_MATERIAL
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_BATCH
*&---------------------------------------------------------------------*
*       Check Batch number input by user in screen
*----------------------------------------------------------------------*
 FORM f_check_batch  USING    fp_matnr     TYPE matnr     " Material Number
                              fp_charg     TYPE charg_d . " Batch Number

   DATA : lv_batch TYPE charg_d. " Batch Number

   SELECT SINGLE charg " Batch Number
     FROM mch1         " Batches (if Batch Management Cross-Plant)
     INTO lv_batch
     WHERE matnr EQ fp_matnr
     AND charg EQ fp_charg.
   IF sy-subrc NE 0.
     MESSAGE e104 WITH fp_charg fp_matnr.
   ENDIF. " IF sy-subrc NE 0


 ENDFORM. " F_CHECK_BATCH
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
*       Prepare order data to pass to method
*----------------------------------------------------------------------*
 FORM f_prepare_data  CHANGING fp_wa_head TYPE zotc_850_so_header " Sales Order Header for IDD 0009 - 850
                               fp_i_item TYPE zotc_tt_850_so_item.

   DATA : lwa_item TYPE zotc_850_so_item. " Sales Order Item for IDD 0009 - 850

   FIELD-SYMBOLS : <lfs_items> TYPE ty_items.

   fp_wa_head-auart = gv_doc_type.
   fp_wa_head-vtweg = gv_vtweg.
   fp_wa_head-kunnr_we = gv_ship_to.
   fp_wa_head-name1 = gv_ship_to_name.
   fp_wa_head-kunnr_ag = gv_sold_to.
   fp_wa_head-bstnk = gv_bstnk.
   fp_wa_head-bsark = gv_bsark.
   fp_wa_head-bstdk = gv_bstdk.
   fp_wa_head-vsbed = gv_vsbed.
   fp_wa_head-name1_gp = gv_contact_name.
   fp_wa_head-ad_bldng = gv_building.
   fp_wa_head-ad_roomnum = gv_room.
   fp_wa_head-floor = gv_floor.
   fp_wa_head-telf1 = gv_contact_phone.
   fp_wa_head-ad_smtpadr = gv_contact_email.
   fp_wa_head-edi4040_a = gv_attention.

   IF gv_sold_to IS INITIAL.
     fp_wa_head-skip_soldto = abap_true.
   ENDIF. " IF gv_sold_to IS INITIAL

   LOOP AT i_items[] ASSIGNING <lfs_items>.
     lwa_item-matnr = <lfs_items>-matnr.
     lwa_item-maktx = <lfs_items>-matxt.
     lwa_item-kwmeng = <lfs_items>-kwmeng.
     lwa_item-charg = <lfs_items>-charg.
     APPEND lwa_item TO fp_i_item.
     CLEAR lwa_item.
   ENDLOOP. " LOOP AT i_items[] ASSIGNING <lfs_items>

 ENDFORM. " F_PREPARE_DATA
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_ORDER_DATA
*&---------------------------------------------------------------------*
*       Validate Order data
*----------------------------------------------------------------------*
 FORM f_validate_order_data  USING    fp_head    TYPE zotc_850_so_header " Sales Order Header for IDD 0009 - 850
                             CHANGING fp_i_item  TYPE zotc_tt_850_so_item
                                      fp_i_error TYPE ty_t_error.

   DATA : lref_object TYPE REF TO   zotc_cl_inb_so_edi_850, " Inbound Sales Order EDI 850
          lwa_error   TYPE ty_error,
          lwa_head    TYPE zotc_850_so_header.              " Sales Order Header for IDD 0009 - 850

   FIELD-SYMBOLS : <lfs_item> TYPE zotc_850_so_item. " Sales Order Item for IDD 0009 - 850

   CREATE OBJECT lref_object.

   lwa_head = fp_head.

   lwa_head-testrun = abap_true.

   CALL METHOD lref_object->determine_orders
     EXPORTING
       im_head = lwa_head
     CHANGING
       ch_item = fp_i_item.

   LOOP AT fp_i_item ASSIGNING <lfs_item> .
*    Begin of change for defect#5694 by NGARG
     IF <lfs_item>-type IS NOT INITIAL
     OR <lfs_item>-message IS NOT INITIAL.
*    End of change for defect#5694 by NGARG
       lwa_error-type = <lfs_item>-type.
       lwa_error-message = <lfs_item>-message.
       lwa_error-matnr = <lfs_item>-matnr.
       APPEND lwa_error TO fp_i_error.
       CLEAR lwa_error.
*    Begin of change for defect#5694 by NGARG

     ENDIF. " IF <lfs_item>-type IS NOT INITIAL
*    End of change for defect#5694 by NGARG

   ENDLOOP. " LOOP AT fp_i_item ASSIGNING <lfs_item>

 ENDFORM. " F_VALIDATE_ORDER_DATA
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ORDER
*&---------------------------------------------------------------------*
*       Display Order in VA03 on double click
*----------------------------------------------------------------------*
 FORM f_display_order  USING    fp_row_id TYPE lvc_s_row " ALV control: Line description
                                fp_col TYPE lvc_s_col.   " ALV Control: Column ID

   FIELD-SYMBOLS : <lfs_error_log> TYPE ty_error.

   CONSTANTS : lc_message   TYPE lvc_fname VALUE 'MESSAGE', " Field Name
               lc_aun       TYPE char3     VALUE 'AUN',     " Aun of type CHAR3
               lc_va03      TYPE char4     VALUE 'VA03'.    " Va03 of type CHAR4

   IF fp_col-fieldname EQ lc_message.

     READ TABLE i_error_log ASSIGNING <lfs_error_log> INDEX fp_row_id-index.

     IF sy-subrc EQ 0
        AND <lfs_error_log>-order IS NOT INITIAL.
       SET PARAMETER ID lc_aun FIELD <lfs_error_log>-order.
       CALL TRANSACTION lc_va03  AND SKIP FIRST SCREEN.
     ENDIF. " IF sy-subrc EQ 0
   ENDIF. " IF fp_col-fieldname EQ lc_message
 ENDFORM. " F_DISPLAY_ORDER
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_KUNNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_SHIP_TO  text
*      <--P_GV_SHIP_NAME  text
*----------------------------------------------------------------------*
 FORM f_check_kunnr  USING    fp_v_kunnr   TYPE kunnr    " Customer Number
                     CHANGING fp_name      TYPE name1_gp " Name 1
                              fp_flag_error TYPE flag.   " General Flag

   DATA : lv_kunnr TYPE kunag. " Sold-to party

   SELECT SINGLE kunnr " Customer Number
                 name1 " Name
    FROM kna1          " General Data in Customer Master
    INTO (lv_kunnr , fp_name)
     WHERE kunnr EQ fp_v_kunnr.
   IF sy-subrc NE 0 AND lv_kunnr IS INITIAL.
     fp_flag_error = abap_true.
   ENDIF. " IF sy-subrc NE 0 AND lv_kunnr IS INITIAL

 ENDFORM. " F_CHECK_KUNNR
