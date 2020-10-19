************************************************************************
* PROGRAM    :  ZOTC_ORDER_LIST (Function Group)                               *
* TITLE      :  Interface for retrieving the order list from           *
*               Bio Rad SAP (ECC) based on the request from EVo        *
* DEVELOPER  :  AVIK PODDAR                                            *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_0091                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Population of Order List and Order Status               *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT  DESCRIPTION                        *
* ===========  ========  ========== ===================================*
* 16-MAY-2014  APODDAR   E2DK900460 S 8000004887:                      *
*                                   R2:DEV:D2_OTC_IDD_0091_GetOrderList*
*&---------------------------------------------------------------------*
*******************************************************************
*   System-defined Include-files.                                 *
*******************************************************************
  INCLUDE LZOTC_ORDER_LISTTOP.               " Global Data
  INCLUDE LZOTC_ORDER_LISTUXX.               " Function Modules

*******************************************************************
*   User-defined Include-files (if necessary).                    *
*******************************************************************
* INCLUDE LZOTC_ORDER_LISTF...               " Subroutines
* INCLUDE LZOTC_ORDER_LISTO...               " PBO-Modules
* INCLUDE LZOTC_ORDER_LISTI...               " PAI-Modules
* INCLUDE LZOTC_ORDER_LISTE...               " Events
* INCLUDE LZOTC_ORDER_LISTP...               " Local class implement.
* INCLUDE LZOTC_ORDER_LISTT99.               " ABAP Unit tests

*INCLUDE lzotc_order_listf01.

INCLUDE lzotc_order_listf01.
