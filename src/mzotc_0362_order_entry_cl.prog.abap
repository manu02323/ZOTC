*&---------------------------------------------------------------------*
*&  Include           MZOTC_0362_CREATE_ENTRY_CL
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  MZOTC_0362_ORDER_ENTRY_CL                              *
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

CLASS lcl_event_handler DEFINITION  ##CLASS_FINAL. " Event_handler class
  PUBLIC SECTION .

    METHODS:

*   Top of page
    top_of_page
    FOR EVENT top_of_page "event handler
           OF cl_gui_alv_grid
    IMPORTING e_dyndoc_id                    ##NEEDED,


*    Handling Double Click
     handle_double_click
     FOR EVENT double_click " Time at which the RW interface is called up
            OF cl_gui_alv_grid
     IMPORTING e_row                              ##NEEDED
               e_column                          ##NEEDED.
ENDCLASS. "lcl_event_handler DEFINITION
