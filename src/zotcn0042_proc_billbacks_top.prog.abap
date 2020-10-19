************************************************************************
* PROGRAM    :  ZOTCN0042_PROC_BILLBACKS_TOP (Include)                 *
* TITLE      :  Process Billback data                                  *
* DEVELOPER  :  Santosh Vinapamula                                     *
* OBJECT TYPE:  Executable program                                     *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0042                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Process Billback data from EDI 867                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 15-JUN-2012  SVINAPA  E1DK901251 INITIAL DEVELOPMENT                 *
* 08-Aug-2016  AMOHAPA  E2DK917823 Defect# 1910:Match up logic should  *
*                                  pick the oldest invoice and quantity*
*                                  should count in the duration of 10  *
*                                  from the billing date and this is   *
*                                  applicable for all order type       *
*&---------------------------------------------------------------------*
* Billback staging table
TYPES: BEGIN OF ty_billbk_stg.
        INCLUDE STRUCTURE zotc_billbk_stg. "  Billback Processing Staging Table
TYPES: END OF ty_billbk_stg.

* ALV display table
TYPES: BEGIN OF ty_alv_tablex,
         gr_alv         TYPE REF TO cl_salv_table,         "ALV grid object
         gr_columns     TYPE REF TO cl_salv_columns_table, " Columns in Simple, Two-Dimensional Tables
         b_initialized  TYPE boolean,                      " Boolean Variable (X=True, -=False, Space=Unknown)
         b_displayed    TYPE boolean,                      " Boolean Variable (X=True, -=False, Space=Unknown)
       END OF ty_alv_tablex.

*&---------------------------------------------------------------------*
*   Constants
*&---------------------------------------------------------------------*
CONSTANTS:
  c_sales_org     TYPE vkorg VALUE '1000', " Sales org
  c_distr_channel TYPE vtweg VALUE '10'.   " Distribution channel

*&---------------------------------------------------------------------*
*   Global variables
*&---------------------------------------------------------------------*
DATA:
  gv_vkorg      TYPE vkorg,         " Sales organization
  gv_vtweg      TYPE vtweg,         " Distribution channel
  gv_vbeln      TYPE vbak-vbeln,    " Sales document
  gv_posnr      TYPE vbap-posnr,    " Sales document item
  gv_bstkd      TYPE bstkd,         " Customer PO number
  gv_bstdk      TYPE bstdk,         " PO date
  gv_erdat      TYPE erdat,         " Create date
  gv_ernam      TYPE vbak-ernam,    " Created by
  gv_kunnr      TYPE kunnr,         " Customer
  gv_auart      TYPE vbak-auart,    " Sales document type
  gv_fkdat      TYPE fkdat,         " Billing date ??
  gv_distr      TYPE z_dist_code,   " Distributor code
  gv_matnr      TYPE matnr,         " Material
  gv_clm_mtch   TYPE z_claim_match, " Claim Match
  gv_dup_clm    TYPE z_dup_clm_ind, " Duplicate claims
  gv_ful_proc   TYPE z_fully_proc,  " Fully processed
*--->Begin of Insert for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016
  gv_duration   TYPE dlydy. "Global variable for Duration
*<---End of Insert for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016

*&---------------------------------------------------------------------*
*   Internal Tables
*&---------------------------------------------------------------------*
DATA:
  i_billbk_stg      TYPE STANDARD TABLE OF ty_billbk_stg,
  i_tmp_bb_stg      TYPE STANDARD TABLE OF ty_billbk_stg,
  i_ord_data        TYPE STANDARD TABLE OF zotc_billback, " BillBack Process Control Table
  i_gpo_ident       TYPE STANDARD TABLE OF tvv1t,         " Customer group 1: Description
  i_vbuv            TYPE STANDARD TABLE OF vbuv.          " Sales Document: Incompletion Log

*&---------------------------------------------------------------------*
*   ALV declarations
*&---------------------------------------------------------------------*
DATA:
  i_fcode             TYPE TABLE OF sy-ucomm INITIAL SIZE 0, " Function code that PAI triggered
  gv_alv_obj          TYPE ty_alv_tablex,                    " ALV object
  gv_container        TYPE REF TO cl_gui_custom_container.   "Container

* Event Handling Declarations
DEFINE xalv_tablexmacro_dummy_beg.
  data: begin of &1, lv_dummy_beg type c.
END-OF-DEFINITION.

DEFINE xalv_tablexmacro_dummy_end.
  data: lv_dummy_end type c, end of &1.
END-OF-DEFINITION.


DATA: BEGIN OF event_handling_start.
xalv_tablexmacro_dummy_end event_handling_start.

*&---------------------------------------------------------------------*
* Event handler class definition
*&---------------------------------------------------------------------*
CLASS lcl_event_receiver DEFINITION. " Event_receiver class
  PUBLIC SECTION.
    DATA: gv_formname_dblclick TYPE formname,
          gv_formname_ucomm    TYPE formname.

    METHODS:
          meth_p_p_handle_double_click " Handle Double click
                FOR EVENT double_click
                OF cl_salv_events_table
                IMPORTING row column,
          meth_p_p_handle_link_click   " Handle Link click
                FOR EVENT link_click
                OF cl_salv_events_table
                IMPORTING row column,
          meth_p_p_handle_ucomm        " Handle User command
                FOR EVENT added_function
                OF cl_salv_events_table
                IMPORTING e_salv_function.

  PRIVATE SECTION.
ENDCLASS. "lcl_event_receiver DEFINITION

*&---------------------------------------------------------------------*
* Event handler class implementation
*&---------------------------------------------------------------------*
CLASS lcl_event_receiver IMPLEMENTATION. " Event_receiver class

  METHOD meth_p_p_handle_double_click.
    IF NOT me->gv_formname_dblclick IS INITIAL.
*     Handle double click
      PERFORM (me->gv_formname_dblclick)
            IN PROGRAM (sy-repid) IF FOUND
            USING row column.
    ELSE. " ELSE -> IF NOT me->gv_formname_dblclick IS INITIAL
*     Default double click handling
      PERFORM f_alv_default_dblclick
              USING row column.
    ENDIF. " IF NOT me->gv_formname_dblclick IS INITIAL
  ENDMETHOD. "handle_double_click

  METHOD meth_p_p_handle_link_click.
    IF NOT me->gv_formname_dblclick IS INITIAL.
*     Handle link click
      PERFORM (me->gv_formname_dblclick)
            IN PROGRAM (sy-repid) IF FOUND
            USING row column.
    ELSE. " ELSE -> IF NOT me->gv_formname_dblclick IS INITIAL
*     Default double click handling
      PERFORM f_alv_default_dblclick
              USING row column.
    ENDIF. " IF NOT me->gv_formname_dblclick IS INITIAL

  ENDMETHOD. "handle_link_click

  METHOD meth_p_p_handle_ucomm.
*   User command processing
    IF NOT me->gv_formname_dblclick IS INITIAL.
      PERFORM (me->gv_formname_ucomm)
            IN PROGRAM (sy-repid) IF FOUND
            USING e_salv_function.
    ELSE. " ELSE -> IF NOT me->gv_formname_dblclick IS INITIAL
      PERFORM f_alv_default_ucomm
            USING e_salv_function.
    ENDIF. " IF NOT me->gv_formname_dblclick IS INITIAL
  ENDMETHOD. "handle_ucomm

ENDCLASS. "lcl_event_receiver IMPLEMENTATION

xalv_tablexmacro_dummy_beg event_handling_end.
DATA: END OF event_handling_end.
