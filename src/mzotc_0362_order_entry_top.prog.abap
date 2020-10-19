*&---------------------------------------------------------------------*
*&  Include           MZOTC_0362_ORDER_ENTRY_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  MZOTC_0362_ORDER_ENTRY_TOP                             *
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

*======================================================================*
*               TYPES
*======================================================================*

TYPES:

* Table control
BEGIN OF ty_items,
  mark   TYPE char1,   " Mark of type CHAR1
  matnr  TYPE matnr,   " Material Number
  matxt  TYPE matxt,   " Short Text for Task
  kwmeng TYPE kwmeng,  " Target quantity in sales units
  charg  TYPE charg_d, " Batch Number
END OF ty_items,

* ALV table
BEGIN OF ty_error,
  type    TYPE bapi_mtype,
  message TYPE bapi_msg, " Message Text
  order   TYPE vbeln,    " Sales and Distribution Document Number
  matnr   TYPE matnr,    " Material Number
END OF ty_error,

ty_t_error    TYPE STANDARD TABLE OF ty_error   INITIAL SIZE  0.

*======================================================================*
*                 GLOBAL VARIABLES and TABLES
*======================================================================*

DATA : i_items       TYPE STANDARD TABLE OF ty_items,
       i_error_log   TYPE ty_t_error ##needed,     "Global Variable required to aceess data across screens/modules                          " Return Parameter
       wa_items      TYPE ty_items ##needed,        "Global Variable required to aceess data across screens/modules
       gv_doc_type   TYPE auart ##needed,           "Global Variable required to aceess data across screens/modules
       gv_vtweg      TYPE vtweg ##needed,           "Global Variable required to aceess data across screens/modules                                 " Distribution Channel
       gv_sold_to    TYPE kunag ##needed,           "Global Variable required to aceess data across screens/modules                         " Sold-to party
       gv_sold_to_name TYPE name1_gp ##needed,      "Global Variable required to aceess data across screens/modules                         " Name 1
       gv_ship_to      TYPE kunwe ##needed,         "Global Variable required to aceess data across screens/modules                         " Ship-to party
       gv_ship_to_name TYPE name1_gp ##needed,       "Global Variable required to aceess data across screens/modules                        " Name 1
       gv_bstnk        TYPE bstnk ##needed,          "Global Variable required to aceess data across screens/modules                        " Customer purchase order number
       gv_bstdk        TYPE datum ##needed,           "Global Variable required to aceess data across screens/modules                       " Date
       gv_bsark        TYPE bsark ##needed,           "Global Variable required to aceess data across screens/modules                       " Customer purchase order type
       gv_vsbed        TYPE vsbed ##needed,            "Global Variable required to aceess data across screens/modules                      " Shipping Conditions
       gv_attention    TYPE edi4040_a ##needed,         "Global Variable required to aceess data across screens/modules                     " Name 1
       gv_contact_name TYPE name1_gp ##needed,          "Global Variable required to aceess data across screens/modules                     " Name 1
       gv_contact_phone  TYPE telf1 ##needed,          "Global Variable required to aceess data across screens/modules                      " First telephone number
       gv_contact_email  TYPE ad_smtpadr ##needed,      "Global Variable required to aceess data across screens/modules                     " E-Mail Address
       gv_room           TYPE ad_roomnum ##needed,      "Global Variable required to aceess data across screens/modules                     " Room or Appartment Number
       gv_building       TYPE ad_bldng ##needed,        "Global Variable required to aceess data across screens/modules                     " Building (Number or Code)
       gv_floor          TYPE ad_floor ##needed,         "Global Variable required to aceess data across screens/modules                    " Floor in building
       gv_okcode         TYPE sy-ucomm ##needed,           "Global Variable required to aceess data across screens/modules                  " Function Code
       gref_custom_container TYPE REF TO cl_gui_custom_container ##needed, "Global Variable required to aceess data across screens/modules  "Container1
       gref_handler          TYPE REF TO lcl_event_handler ##needed,      "Global Variable required to aceess data across screens/modules   " Event_handler class
       gref_grid             TYPE REF TO cl_gui_alv_grid ##needed,        "Global Variable required to aceess data across screens/modules   "Refernce to grid
       gref_dyndoc_id        TYPE REF TO cl_dd_document ##needed,            "reference TO document
       gref_splitter         TYPE REF TO cl_gui_splitter_container ##needed,"Global Variable required to aceess data across screens/modules "Reference to split container
       gref_parent_grid      TYPE REF TO cl_gui_container ##needed,        "Global Variable required to aceess data across screens/modules  "Reference to grid container
       gref_parent_grid1     TYPE REF TO cl_gui_container ##needed,      "Global Variable required to aceess data across screens/modules    "Reference to html container
       gv_okcode2            TYPE sy-ucomm.                                  " Assignment of line number to line ID

*&SPWIZARD: LINES OF TABLECONTROL 'TAB_CTRL_ITEM'
DATA:     gv_tc_tab_ctrl_item_lines  TYPE sy-loopc ##needed. " Visible Lines of a Step Loop

*======================================================================*
*                 CONTROLS
*======================================================================*
*&SPWIZARD: DECLARATION OF TABLECONTROL 'TAB_CTRL_ITEM' ITSELF
CONTROLS: tc_tab_ctrl_item TYPE TABLEVIEW USING SCREEN 9001.
*======================================================================*
*                CONSTANTS
*======================================================================*
CONSTANTS:  c_10              TYPE char2    VALUE '10',               " 10 of type CHAR2
            c_create          TYPE okcode   VALUE 'CRT',              " Function Code
            c_cont            TYPE char14   VALUE 'GV_CONTAINER1',    "Container name
            c_alv             TYPE char50   VALUE 'ALV_GRID',         "constant for alv grid
            c_top             TYPE char30   VALUE 'TOP_OF_PAGE',      "'TOP_OF_PAGE' constant
            c_bck             TYPE char5    VALUE 'BAACK',            "constant for BACK
            c_ext             TYPE char4    VALUE 'EXIT',             "constant for EXIT
            c_cncl            TYPE char6    VALUE 'CANCEL',           "constant for CANCEL
            c_tab_ctrl_item   TYPE dynfnam  VALUE 'TC_TAB_CTRL_ITEM', " Field name
            c_error           TYPE bapi_mtype VALUE 'E',              " Message type: S Success, E Error, W Warning, I Info, A Abort
            c_i_items         TYPE string     VALUE 'I_ITEMS',
            c_mark            TYPE char4      VALUE 'MARK',           " Mark of type CHAR4
            c_message         TYPE fieldname  VALUE 'MESSAGE',        " Field Name
            c_validate        TYPE okcode     VALUE 'VALID'.          " Function Code
