*&---------------------------------------------------------------------*
*&  Include           MZOTC_0362_CREATE_ENTRY_ICL
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  MZOTC_0362_ORDER_ENTRY_ICL                             *
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
CLASS lcl_event_handler IMPLEMENTATION. " Event_handler class

  METHOD top_of_page. "implementation
*   Top-of-page event
    PERFORM f_event_top_of_page USING gref_dyndoc_id.
  ENDMETHOD. "top_of_page

  METHOD handle_double_click .
*   Double click event
    PERFORM f_display_order USING e_row
                                  e_column.
  ENDMETHOD. "handle_double_click


ENDCLASS. "LCL_EVENT_HANDLER IMPLEMENTATION
