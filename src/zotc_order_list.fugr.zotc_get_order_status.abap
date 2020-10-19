************************************************************************
* PROGRAM    :  ZOTC_GET_ORDER_LIST (FM)                               *
* TITLE      :  Interface for retrieving the order list from           *
*               Bio Rad SAP (ECC) based on the request from EVo        *
* DEVELOPER  :  AVIK PODDAR                                            *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_IDD_0091                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: Population of Order List and Order Status               *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT  DESCRIPTION                        *
* ===========  ========  ========== ===================================*
* 16-MAY-2014  APODDAR   E2DK900460 Initial Development                *
* 27-JUN-2014  APODDAR   E2DK900460 D2_OTC_IDD_0091_CR01
* 12-AUG-2014  APODDAR   E2DK900460 D2_OTC_IDD_0091_CR_D2_75
* 21-APR-2015  APODDAR   E2DK900460 D2_OTC_IDD_0091 Defect # 6148                                                                      *
*&---------------------------------------------------------------------*
FUNCTION zotc_get_order_status .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_ORDER_REQ) TYPE  ZOTC_SALES_ORDR_TBL
*"  EXPORTING
*"     REFERENCE(EX_ORDER_RES) TYPE  ZOTC_PUT_ORDR_STATUS_TBL
*"     REFERENCE(EX_ORDER_INV) TYPE  ZOTC_ORDER_INVC_TBL
*"  EXCEPTIONS
*"      NO_ORDER_FOUND
*"      NO_DATA_PROVIDED
*"----------------------------------------------------------------------

 "Clear internal tables and work areas
  PERFORM f_clear_all_data.
 "Check if VBAK is having orders
  IF NOT im_order_req IS INITIAL.
    i_vbak[] = im_order_req[].
 "Hit Order Status, Line Item Data, Line Item Status Tables
    PERFORM f_fetch_order_details USING i_vbak.
 "Check if Order stands Cancelled
    PERFORM f_get_cancelled_order CHANGING i_vbak
                                           i_order_res.
 "Get document flow for orders
    PERFORM f_get_delivery_docs USING i_vbak
                                CHANGING i_vbuk_del.

 "Decide on the overall Status of Order
    PERFORM f_get_order_list CHANGING i_vbak i_order_res.
 "Send Resultant data
    IF NOT i_order_res IS INITIAL.
      ex_order_res[] = i_order_res[].
    ELSE. " ELSE -> IF NOT i_order_res IS INITIAL
      RAISE no_order_found.
    ENDIF. " IF NOT i_order_res IS INITIAL
  ELSE. " ELSE -> IF NOT im_order_req IS INITIAL
    RAISE no_data_provided.
  ENDIF. " IF NOT im_order_req IS INITIAL
  IF NOT i_inv_list IS INITIAL.
    ex_order_inv[] = i_inv_list[].
  ENDIF. " IF NOT i_inv_list IS INITIAL

ENDFUNCTION.
