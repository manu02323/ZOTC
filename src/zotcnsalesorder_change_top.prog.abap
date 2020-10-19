************************************************************************
* PROGRAM    :  ZOTCNSALESORDER_CHANGE_TOP                             *
* TITLE      :  Update SO with Contract Item number                    *
* DEVELOPER  :  Raghu Achar                                            *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  RTR_EDD_0059 - CR 369, Defect 3630                       *
*----------------------------------------------------------------------*
* DESCRIPTION: Update SO history with Contract Item number             *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT  DESCRIPTION                         *
* =========== ========  ========== ====================================*
* 15-APR-2013 SPANDIT  E1DK910058 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*
************************************************************************
*          DATA DECLARATION
************************************************************************
*Types
 TYPES:
*      Sales Document: Header Data
       BEGIN OF ty_vbak,
         vbeln TYPE vbeln_va,   "Sales Document
       END OF ty_vbak,
*      Sales Document Flow
       BEGIN OF ty_vbfa,
         vbelv TYPE vbeln_von, "Preceding sales and distribution document
         posnv TYPE posnr_von, "Preceding item of an SD document
         vbeln TYPE vbeln_nach, "Subsequent sales and distribution document
         posnn TYPE posnr_nach, "Subsequent item of an SD document
       END OF ty_vbfa,
*      Sales Document: Item Data
       BEGIN OF ty_vbap,
        vbeln TYPE vbeln_va,  "Sales Document
        posnr TYPE posnr_va,  "Sales Document Item
        matnr TYPE matnr,
       END OF ty_vbap,
*      Sales Order Line Item Status
       BEGIN OF ty_vbup,
        vbeln TYPE vbeln_va,  "Sales and Distribution Document Number
        posnr TYPE posnr_va,  "Sales Document Item
        lfsta TYPE lfsta,     "Delivery status
       END OF ty_vbup.
*Table types
 TYPES:
*      table type for Sales Document: Header Data
        ty_t_vbak TYPE STANDARD TABLE OF ty_vbak,
*      table type for Sales Document Flow
        ty_t_vbfa TYPE STANDARD TABLE OF ty_vbfa,
*      table type for sales order item status
        ty_t_vbup TYPE STANDARD TABLE OF ty_vbup,
*      table type for Sales Document: Item Data
        ty_t_vbap TYPE SORTED  TABLE OF ty_vbap WITH  NON-UNIQUE KEY vbeln matnr,
*      table type sorted for Sales Document Flow
        ty_t_vbfa_contract TYPE SORTED TABLE OF ty_vbfa WITH NON-UNIQUE KEY vbelv.

*Internal table
 DATA:
*      Internal table for Sales Document: Header Data
       i_vbak TYPE ty_t_vbak,
*      Internal table  for Sales Document Flow
       i_vbfa TYPE ty_t_vbfa,
*      Internal table for Sales Document: Item Data
       i_vbap_contract TYPE ty_t_vbap,
*      Internal table of Sales Order Item Status
       i_vbup TYPE ty_t_vbup,
*      Internal table sorted for Sales Document Flow
       i_vbfa_contract TYPE ty_t_vbfa_contract,
*      Internal table for Document Numbers to Be Selected
       i_sales_documents TYPE STANDARD TABLE OF sales_key INITIAL SIZE 0,
*      Internal table for Order Headers for Document Numbers
       i_order_headers_out TYPE STANDARD TABLE OF bapisdhd INITIAL SIZE 0,
*      Internal table for Order Item Data for Document Numbers
       i_order_items_out TYPE STANDARD TABLE OF bapisdit INITIAL SIZE 0,
*      Internal table for Order Items
       i_order_item_in TYPE STANDARD TABLE OF bapisditm INITIAL SIZE 0,
*      Internal table for Sales Order Items Check Table
       i_order_item_inx TYPE STANDARD TABLE OF bapisditmx INITIAL SIZE 0,
*      Internal table for Return Code
       i_return TYPE STANDARD TABLE OF bapiret2 INITIAL SIZE 0.

* Workarea/structure
 DATA:
*      Bapi View for Data Reduction
       wa_bapi_view TYPE order_view,
*      Order Number
       wa_sales_documents TYPE sales_key,
*      Order Headers for Document Numbers
       wa_order_items_out TYPE bapisdit,
*      Order Header
       wa_order_header_in TYPE bapisdh1,
*      Sales Order Check List
       wa_order_header_inx TYPE bapisdh1x,
*      Order Items
       wa_order_item_in TYPE bapisditm,
*      Sales Order Items Check Table
       wa_order_item_inx TYPE bapisditmx,
*      Return Code
       wa_return TYPE bapiret2.

*Variables
 DATA: gv_vbeln TYPE  vbak-vbeln, "Sales Order no
       gv_auart TYPE  vbak-auart, "Sales Document Type
       gv_erdat TYPE  erdat,      "Date on Which Record Was Created
       gv_text  TYPE  bapi_msg,   "text
       gv_flag  TYPE  char1.      "Flag

*Constants
 CONSTANTS: c_flag_on     TYPE char1 VALUE 'X',      "Flag
            c_ref_doc_ca  TYPE vbtyp_v VALUE 'G',    "Ref doc category
            c_update_flag TYPE updkz_d VALUE 'U',    "Update flag
            c_bapi_flag   TYPE char1 VALUE 'P',      "Behave when error value
            c_type_e      TYPE bapi_mtype VALUE 'E', "Message type E
            c_type_a      TYPE bapi_mtype VALUE 'A', "Message type A
            c_complete    type lfsta value 'C'.      "Completely Processed

*Field-symbols
 FIELD-SYMBOLS: <fs_vbak> TYPE ty_vbak,
                <fs_vbap_contract> TYPE ty_vbap.
