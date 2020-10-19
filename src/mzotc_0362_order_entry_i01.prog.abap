*&---------------------------------------------------------------------*
*&  Include           MZOTC_0362_ORDER_ENTRY_I01
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  MZOTC_0362_ORDER_ENTRY_I01                              *
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
*&      Module  CHECK_DOC_TYPE  INPUT
*&---------------------------------------------------------------------*
*      Check Order type
*----------------------------------------------------------------------*
MODULE check_doc_type INPUT.
  IF gv_doc_type IS NOT INITIAL.
    PERFORM f_check_doc_type USING gv_doc_type.
  ENDIF. " IF gv_doc_type IS NOT INITIAL
ENDMODULE. " CHECK_DOC_TYPE  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_VTWEG  INPUT
*&---------------------------------------------------------------------*
*       Check Distribution Channel
*----------------------------------------------------------------------*
MODULE check_vtweg INPUT.
  IF gv_vtweg IS NOT INITIAL.
    PERFORM f_check_vtweg USING gv_vtweg.
  ENDIF. " IF gv_vtweg IS NOT INITIAL
ENDMODULE. " CHECK_VTWEG  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_SOLD_TO  INPUT
*&---------------------------------------------------------------------*
*       Check Sold to party number
*----------------------------------------------------------------------*
MODULE check_sold_to INPUT.
  IF gv_sold_to IS NOT INITIAL.
    PERFORM f_check_sold_to CHANGING gv_sold_to
                                     gv_sold_to_name.
  ENDIF. " IF gv_sold_to IS NOT INITIAL

ENDMODULE. " CHECK_SOLD_TO  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_SHIP_TO  INPUT
*&---------------------------------------------------------------------*
*      Check ship to party number
*----------------------------------------------------------------------*
MODULE check_ship_to INPUT.
  IF gv_ship_to IS NOT INITIAL.

    PERFORM f_check_ship_to CHANGING gv_ship_to
                                     gv_ship_to_name.
  ENDIF. " IF gv_ship_to IS NOT INITIAL

ENDMODULE. " CHECK_SHIP_TO  INPUT
" CHECK_BSTKD  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_BSARK  INPUT
*&---------------------------------------------------------------------*
*       Check PO type
*----------------------------------------------------------------------*
MODULE check_bsark INPUT.
  IF gv_bsark IS NOT INITIAL.
    PERFORM f_check_bsark USING gv_bsark.
  ENDIF. " IF gv_bsark IS NOT INITIAL
ENDMODULE. " CHECK_BSARK  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_VSBED  INPUT
*&---------------------------------------------------------------------*
*       Check Shipping Conditions
*----------------------------------------------------------------------*
MODULE check_vsbed INPUT.
  IF gv_vsbed IS NOT INITIAL.
    PERFORM f_check_vsbed USING gv_vsbed.
  ENDIF. " IF gv_vsbed IS NOT INITIAL
ENDMODULE. " CHECK_VSBED  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       User command for Screen 9001
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.

  IF gv_okcode EQ c_create.
    CLEAR i_error_log[].
    PERFORM f_create_order CHANGING i_error_log.
  ENDIF. " IF gv_okcode EQ c_create

  IF gv_okcode EQ c_validate.
    CLEAR i_error_log[].
    PERFORM f_validate_order CHANGING i_error_log.
  ENDIF. " IF gv_okcode EQ c_validate

  IF i_error_log IS NOT INITIAL.
    CALL SCREEN 9002.
  ENDIF. " IF i_error_log IS NOT INITIAL
ENDMODULE. " USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
*       User command for screen 9002
*----------------------------------------------------------------------*
MODULE user_command_9002 INPUT.

*Assign Sy-ucomm value to a global variable
  gv_okcode2 = sy-ucomm.

  CASE gv_okcode2.
*   For BACK
    WHEN c_bck.
      CLEAR i_error_log[].
      LEAVE TO SCREEN 0.

*   For CANCEL
    WHEN c_cncl.
      CLEAR i_error_log[].
      CALL SCREEN 9001.

*   For EXIT
    WHEN c_ext.
      CLEAR i_error_log[].
      LEAVE PROGRAM.

  ENDCASE.

ENDMODULE. " USER_COMMAND_9002  INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TAB_CTRL_ITEM'. DO NOT CHANGE THIS LINE
*&SPWIZARD: MODIFY TABLE


*----------------------------------------------------------------------*
*  MODULE tab_ctrl_item_modify INPUT
*----------------------------------------------------------------------*
*     Check Table control entries and modify table control
*----------------------------------------------------------------------*
MODULE tab_ctrl_item_modify INPUT.


* Validate Material entered by user
  IF wa_items-matnr IS NOT INITIAL.
    PERFORM f_check_material CHANGING wa_items-matnr.
  ENDIF. " IF wa_items-matnr IS NOT INITIAL

  SELECT SINGLE maktx " Material Description (Short Text)
    FROM makt         " Material Descriptions
    INTO wa_items-matxt
    WHERE matnr EQ wa_items-matnr
    AND spras EQ sy-langu.
  IF sy-subrc EQ 0 ##needed.
*  do nothing
  ENDIF. " IF sy-subrc EQ 0 ##needed


* Validate batch entered by user
  IF wa_items-charg IS NOT INITIAL.
    PERFORM f_check_batch USING wa_items-matnr
                                wa_items-charg.
  ENDIF. " IF wa_items-charg IS NOT INITIAL

* Modify table control data
  MODIFY i_items
    FROM wa_items
    INDEX tc_tab_ctrl_item-current_line.
* Begin of Change for Defect#5694 by NGARG
  IF sy-subrc EQ 0.
    CLEAR wa_items.
  ENDIF. " IF sy-subrc EQ 0
* End of Change for Defect#5694 by NGARG

* Append data to table control table
* Begin of Change for Defect#5694 by NGARG

  IF wa_items IS NOT INITIAL.
* End of Change for Defect#5694 by NGARG
* Begin of Delete for Defect#5694 by NGARG\
*      if i_items[] is  NOT INITIAL.
* End of Delete for Defect#5694 by NGARG

    APPEND wa_items TO i_items[].
  ENDIF. " IF wa_items IS NOT INITIAL

ENDMODULE. "TAB_CTRL_ITEM_MODIFY INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TAB_CTRL_ITEM'. DO NOT CHANGE THIS LINE
*&SPWIZARD: PROCESS USER COMMAND
*----------------------------------------------------------------------*
*     MODULE tab_ctrl_item_user_command INPUT
*----------------------------------------------------------------------*
*     User command for table control
*----------------------------------------------------------------------*
MODULE tab_ctrl_item_user_command INPUT.
* Copy ok code
  gv_okcode = sy-ucomm.
*  Do action for corresponding user command
  PERFORM f_user_ok_tc USING c_tab_ctrl_item " 'TAB_CTRL_ITEM'
                             c_i_items       " 'I_ITEMS'
                             c_mark          " 'MARK'
                     CHANGING gv_okcode.
  sy-ucomm = gv_okcode.
ENDMODULE. "TAB_CTRL_ITEM_USER_COMMAND INPUT
* Begin of Change for Defect#5694 by NGARG
*&---------------------------------------------------------------------*
*&      Module  USER_EXIT  INPUT
*&---------------------------------------------------------------------*
*       Exit Program
*----------------------------------------------------------------------*
MODULE user_exit INPUT.

  LEAVE PROGRAM.


ENDMODULE. " USER_EXIT  INPUT
* End of Change for Defect#5694 by NGARG
