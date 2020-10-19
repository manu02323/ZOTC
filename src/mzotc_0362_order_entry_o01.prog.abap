*&---------------------------------------------------------------------*
*&  Include           MZOTC_0362_ORDER_ENTRY_O01
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  MZOTC_0362_ORDER_ENTRY_O01                             *
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
*&---------------------------------------------------------------------*
*&      Module  INITIAL_9001  OUTPUT
*&---------------------------------------------------------------------*
*       Initialise screen 9001
*----------------------------------------------------------------------*
MODULE initial_9001 OUTPUT.
  CLEAR: gv_okcode2.

  IF gv_vtweg IS INITIAL.
    gv_vtweg = c_10.
  ENDIF. " IF gv_vtweg IS INITIAL
ENDMODULE. " INITIAL_9001  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9002  OUTPUT
*&---------------------------------------------------------------------*
*       Set Status for screen 9002
*----------------------------------------------------------------------*
MODULE status_9002 OUTPUT.
  SET PF-STATUS 'ZOTC_9002'.
  SET TITLEBAR  '002'.

ENDMODULE. " STATUS_9002  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*       Set Status for screen 9002
*----------------------------------------------------------------------*
MODULE status_9001 OUTPUT.
  SET PF-STATUS 'ZOTC_9001'.
  SET TITLEBAR '001'.

ENDMODULE. " STATUS_9001  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TAB_CTRL_ITEM'. DO NOT CHANGE THIS LIN
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tab_ctrl_item_change_tc_attr OUTPUT.

  DESCRIBE TABLE i_items LINES tc_tab_ctrl_item-lines.
* Begin of Change for Defect#5694 by NGARG

  ADD 10 TO  tc_tab_ctrl_item-lines.
* End of Change for Defect#5694 by NGARG

ENDMODULE. "TAB_CTRL_ITEM_CHANGE_TC_ATTR OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_9002  OUTPUT
*&---------------------------------------------------------------------*
*       Initialize screen 9002
*----------------------------------------------------------------------*
MODULE init_9002 OUTPUT.

  CLEAR gv_okcode.

*  If first instance of ALV display, create container
  IF gref_custom_container IS INITIAL.
    PERFORM f_create_and_init_alv.
  ELSE. " ELSE -> IF gref_custom_container IS INITIAL
*   Else refresh ALV
    CALL METHOD gref_grid->refresh_table_display
      EXCEPTIONS
        finished = 1
        OTHERS   = 2.
  ENDIF. " IF gref_custom_container IS INITIAL
ENDMODULE. " INIT_9002  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TAB_CTRL_ITEM_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       Get lines
*----------------------------------------------------------------------*
MODULE tab_ctrl_item_get_lines OUTPUT.
  gv_tc_tab_ctrl_item_lines  = sy-loopc.
ENDMODULE. " TAB_CTRL_ITEM_GET_LINES  OUTPUT
