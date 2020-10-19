************************************************************************
* PROGRAM    :  ZOTCN0351B_FLIP_ITEM_CAT_TOP                           *
* TITLE      :  Update open Sales Order                                *
* DEVELOPER  :  Salman Zahir                                           *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0351                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update open Sales Order                                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 12-SEP-2016 U033959  E1DK921540 INITIAL DEVELOPMENT                  *
* =========== ======== ========== =====================================*
*INCLUDE : <icon>. " Assign Icon Font Characters for Lists to ASCII Codes
TYPE-POOLS : icon.
TYPES : BEGIN OF ty_so_header,
          vbeln TYPE vbeln_va,   " Sales Document
          auart TYPE auart,      " Sales Document Type
          vkorg TYPE vkorg,      " Sales Organization
          vtweg TYPE vtweg,      " Distribution Channel
          lfstk TYPE lfstk,      " Delivery status
        END OF ty_so_header,
        BEGIN OF ty_so_item,
          vbeln TYPE vbeln_va,   " Sales Document
          posnr TYPE posnr_va,   " Sales Document Item
          matnr TYPE matnr,      " Material Number
          pstyv TYPE pstyv,      " Sales document item category
          lfsta TYPE lfsta,      " Delivery status
        END OF ty_so_item,
        BEGIN OF ty_bapi_msg,
          vbeln TYPE vbeln_va,   " Sales Document
          posnr TYPE posnr_va,   " Sales Document Item
          auart TYPE auart,      " Sales Document Type
          vkorg TYPE vkorg,      " Sales Organization
          message TYPE bapi_msg, " Message Text
          icon    TYPE icon_d,   " Icon in text fields (substitute display, alias)
        END OF ty_bapi_msg,
        BEGIN OF ty_sales_org,
          vkorg TYPE vkorg,      " Sales Organization
        END OF ty_sales_org,
        BEGIN OF ty_vkorg,
          sign   TYPE char1,     " Sign of type CHAR1
          option TYPE char2,     " Option of type CHAR2
          low    TYPE char4,     " Low of type CHAR4
          high   TYPE char4,     " High of type CHAR4
        END OF ty_vkorg,
        BEGIN OF ty_lfstk,
          sign   TYPE char1,     " Sign of type CHAR1
          option TYPE char2,     " Option of type CHAR2
          low    TYPE lfstk,     " Delivery status
          high   TYPE lfstk,     " Delivery status
        END OF ty_lfstk.

TYPES : ty_tt_so_header   TYPE STANDARD TABLE OF ty_so_header, " SO header
        ty_tt_so_item     TYPE STANDARD TABLE OF ty_so_item,   " SO items
        ty_tt_sales_org   TYPE STANDARD TABLE OF ty_sales_org, " SO Sales org
        ty_tt_bapi_msg    TYPE STANDARD TABLE OF ty_bapi_msg,  " BAPI return message
        ty_tt_bapisditm   TYPE STANDARD TABLE OF bapisditm,    " Communication Fields: Sales and Distribution Document Item
        ty_tt_bapiret2    TYPE STANDARD TABLE OF bapiret2,     " Return Parameter
        ty_tt_lfstk       TYPE STANDARD TABLE OF ty_lfstk.     " Delivery status


DATA : i_so_header   TYPE ty_tt_so_header ##needed, " SO header
       i_so_item     TYPE ty_tt_so_item   ##needed, " SO items
       i_bapi_msg    TYPE ty_tt_bapi_msg  ##needed, " BAPI return message
       i_sales_org   TYPE ty_tt_sales_org ##needed, " sales org
       r_lfstk       TYPE ty_tt_lfstk     ##needed. " Delivery status

DATA : gv_vkorg TYPE vkorg,          " Sales Organization
       gv_vtweg TYPE vtweg,          " Distribution Channel
       gv_auart TYPE auart,          " Sales Document Type
       gv_lfsta TYPE lfsta ##needed, " Delivery status
       gv_vbeln TYPE vbeln_va,       " Sales Document
       gv_erdat TYPE erdat,          " Date on Which Record Was Created
       gv_so_upd TYPE flag.          " General Flag
