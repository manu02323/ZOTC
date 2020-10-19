************************************************************************
* PROGRAM    :  ZOTC_GET_ORDER_LIST (FM)                               *
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
* 16-MAY-2014  APODDAR   E2DK900460 Initial Development                *
* 27-JUN-2014  APODDAR   E2DK900460 D2_OTC_IDD_0091_CR01
* 12-AUG-2014  APODDAR   E2DK900460 D2_OTC_IDD_0091_CR_D2_75                                                                 *
*&---------------------------------------------------------------------*

FUNCTION-POOL zotc_order_list. "MESSAGE-ID ..
"INCLUDE LZOTC_ORDER_LISTD.               " Local class definition

"Data Type Declaration
TYPES :  BEGIN OF ty_vbak,
             vbeln    TYPE vbeln,    " Sales and Distribution Document Number
             erdat    TYPE erdat,    " Date on Which Record Was Created
             netwr    TYPE netwr,    " Net Value in Document Currency
             waerk    TYPE waerk,    " SD Document Currency
             bstnk    TYPE bstnk,    " Customer purchase order number
             kunnr    TYPE kunnr,    " Customer Number
             zzdocref TYPE z_docref, " Legacy Doc Ref
             zzdoctyp TYPE z_doctyp, " Ref Doc type
         END OF ty_vbak,

        BEGIN OF ty_vbap,
          vbeln  TYPE vbeln_va,      " Sales Document
          posnr  TYPE posnr_va,      " Sales Document Item
* -- Begin of Changes by Avik Poddar for CR#75 on August 12th 2014 -- *
          pstyv  TYPE pstyv, " Sales document item category
* -- End of Changes by Avik Poddar for CR#75 on August 12th 2014 -- *
          fkrel  TYPE fkrel,    " Relevant for Billing
          abgru  TYPE abgru_va, " Reason for rejection of quotations and sales orders
          netwr  TYPE netwr_ap, " Net value of the order item in document currency
          kwmeng TYPE kwmeng,   " Cumulative Order Quantity in Sales Units
* -- Begin of Changes by Avik Poddar for CR#75 on August 12th 2014 -- *
          kowrr  TYPE kowrr, " Statistical values
          mwsbp  TYPE mwsbp, " Tax amount in document currency
* --  End of Changes by Avik Poddar for CR#75 on August 12th 2014  -- *
        END OF ty_vbap,

        BEGIN OF ty_ekes,
          ebeln TYPE ebeln,    " Purchasing Document Number
          ebelp TYPE ebelp,    " Item Number of Purchasing Document
          etens TYPE etens,    " Sequential Number of Vendor Confirmation
          erdat TYPE bberd,    " Creation Date of Confirmation
          menge TYPE bbmng,    " Quantity as Per Vendor Confirmation
          vbeln TYPE vbeln_vl, " Delivery
          vbelp TYPE posnr_vl, " Delivery Item
        END OF ty_ekes,

        BEGIN OF ty_ekes_tot,
          ebeln TYPE ebeln,    " Purchasing Document Number
* ---> Begin of Insert for Defect#5842, D2_OTC_IDD_0091 by APODDAR
          ebelp TYPE posnr_vl,      " Delivery Item
* <--- End of Insert for Defect#5842, D2_OTC_IDD_0091 by APODDAR
          menge TYPE bbmng,        " Quantity as Per Vendor Confirmation
         END OF ty_ekes_tot,

        BEGIN OF ty_vbuk,
          vbeln TYPE vbeln,        " Sales and Distribution Document Number
          wbstk TYPE wbstk,        " Total goods movement status
          abstk TYPE abstk,        " Overall rejection status of all document items
          gbstk TYPE gbstk,        " Overall processing status of document
        END OF ty_vbuk,

        BEGIN OF ty_status,
          sign   TYPE ddsign,      " Type of SIGN component in row type of a Ranges type
          option TYPE ddoption,    " Type of OPTION component in row type of a Ranges type
          low    TYPE wbstk,       " Total goods movement status
          high   TYPE wbstk,       " Total goods movement status
        END OF ty_status,

        BEGIN OF ty_vbup,
          vbeln TYPE vbeln,        " Sales and Distribution Document Number
          posnr TYPE posnr,        " Item number of the SD document
          absta TYPE absta_vb,     " Rejection status for SD item
          gbsta TYPE gbsta,        " Overall processing status of the SD document item
        END OF ty_vbup,

        BEGIN OF ty_vbfa,
          vbelv   TYPE vbeln_von,  " Preceding sales and distribution document
          posnv   TYPE posnr_von,  " Preceding item of an SD document
          vbeln   TYPE vbeln_nach, " Subsequent sales and distribution document
          posnn   TYPE posnr_nach, " Subsequent item of an SD document
          vbtyp_n TYPE vbtyp_n,    " Document category of subsequent document
          rfmng   TYPE rfmng,      " Referenced quantity in base unit of measure
          vbtyp_v TYPE vbtyp_v,    " Document category of preceding SD document
        END OF ty_vbfa,

* Begin of Change for D2_OTC_IDD_0091_CR01 by APODDAR ON 27TH Jun 2014
       BEGIN OF ty_vbkd,
         vbeln TYPE vbeln, " Sales and Distribution Document Number
         posnr TYPE posnr, " Item number of the SD document
         bstkd TYPE bstkd, " Customer purchase order number
         bstdk TYPE bstdk, " Customer purchase order date
         END OF ty_vbkd.
* End of Change for D2_OTC_IDD_0091_CR01 by APODDAR ON 27TH Jun 2014

"Declaration of Table Types
TYPES : ty_tt_vbuk_del  TYPE STANDARD TABLE OF ty_vbuk.

"Declaration for Internal Tables
DATA :   i_sales_doc TYPE TABLE OF ty_vbak,                                      "internal table VBAK
         i_vbak      TYPE zotc_sales_ordr_tbl,                                   "internal table SALES ORDER LIST
         i_vbap      TYPE TABLE OF ty_vbap,                                      "internal table VBAP
         i_vbap_tot  TYPE TABLE OF ty_vbap,                                      "internal table VBAP
         i_ekes      TYPE TABLE OF ty_ekes,                                      "internal table EKES
         i_ekes_tot  TYPE SORTED TABLE OF ty_ekes_tot WITH NON-UNIQUE KEY ebeln, "internal table EKES
         i_vbuk      TYPE TABLE OF ty_vbuk,                                      "internal table VBUK
         i_vbuk_del  TYPE TABLE OF ty_vbuk,                                      "internal table VBUK
         i_vbup      TYPE TABLE OF ty_vbup,                                      "internal table VBUP
         i_vbfa      TYPE TABLE OF ty_vbfa,                                      " Sales Document Flow
         i_vbfa_del  TYPE TABLE OF ty_vbfa,                                      " Sales Document Flow
         i_vbfa_po   TYPE TABLE OF ty_vbfa,                                      " Sales Document Flow
         i_order_res TYPE zotc_put_ordr_status_tbl,                              " return table ORDER LIST STATUS
         i_inv_list  TYPE zotc_order_invc_tbl,                                   " return table INVOICE LIST
         i_constant  TYPE TABLE OF zdev_enh_status,                              " Enhancement Status
         i_del_stat  TYPE TABLE OF ty_status,
         i_ord_stat  TYPE TABLE OF ty_status,
* Begin of Change for D2_OTC_IDD_0091_CR01 by APODDAR ON 27TH Jun 2014
         i_vbkd      TYPE TABLE OF ty_vbkd,
* End of Change for D2_OTC_IDD_0091_CR01 by APODDAR ON 27TH Jun 2014
* -- Begin of Change CR D2_75 by Avik Poddar on 12th August 2014 -- *
         i_doc_typ   TYPE TABLE OF ty_status,
* -- End of Change CR D2_75 by Avik Poddar on 12th August 2014 -- *

"Declaration for Work Areas
         wa_vbap_tot  TYPE ty_vbap,               " Sales Order Item
         wa_ekes_tot  TYPE ty_ekes_tot,           " Purchase Order Quantity
         wa_order_res TYPE zotc_put_status_struc, " Structure to Return Status with Order List
         wa_del_stat  TYPE ty_status,
         wa_ord_stat  TYPE ty_status,
* -- Begin of Change CR D2_75 by Avik Poddar on 12th August 2014 -- *
         wa_doc_typ   TYPE ty_status,
* -- End of Change CR D2_75 by Avik Poddar on 12th August 2014 -- *
         wa_inv_list  TYPE zotc_order_invc. " Sales Order and Invoice List

*------Field Symbol Declaration----------*
FIELD-SYMBOLS : <fs_vbap> TYPE ty_vbap,
* Begin of Change for D2_OTC_IDD_0091_CR01 by APODDAR ON 27TH Jun 2014
                <fs_vbkd> TYPE ty_vbkd,
* ---> Begin of Insert for Defect#5842, D2_OTC_IDD_0091 by SMEKALA
                <fs_ekes_tot> TYPE ty_ekes_tot.
* <--- End  of  Insert for Defect#5842, D2_OTC_IDD_0091 by SMEKALA

* End of Change for D2_OTC_IDD_0091_CR01 by APODDAR ON 27TH Jun 2014

"Declaration of Variables
DATA: gv_flg_del_part    TYPE int2 VALUE 0, " 2 byte integer (signed)
      gv_flg_del_ship    TYPE int2 VALUE 0, " 2 byte integer (signed)
      gv_flg_inprocess   TYPE int2 VALUE 0, " 2 byte integer (signed)
      gv_tabix_vbap      TYPE sy-tabix,     " Index of Internal Tables
      gv_tabix_vbfa      TYPE sy-tabix.     " Index of Internal Tables

"Declaration of Constants
CONSTANTS :  c_stat_c    TYPE vbtyp_n VALUE 'C',                      " Document category of subsequent document
             c_stat_m    TYPE vbtyp_n VALUE 'M',                      " Document category of subsequent document
             c_stat_a    TYPE vbtyp_n VALUE 'A',                      " Document category of subsequent document
             c_stat_b    TYPE vbtyp_n VALUE 'B',                      " Document category of subsequent document
             c_stat_j    TYPE vbtyp_n VALUE 'J',                      " Document category of subsequent document
             c_stat_v    TYPE vbtyp_n VALUE 'V',                      " Document category of subsequent document
             c_two       TYPE wbstk   VALUE '2',                      " 2 byte integer (signed)
             c_three     TYPE wbstk   VALUE '3',                      " 2 byte integer (signed)
             c_four      TYPE wbstk   VALUE '4',                      " 2 byte integer (signed)
             c_five      TYPE wbstk   VALUE '5',                      " 2 byte integer (signed)
             c_case_del  TYPE char20  VALUE 'CASE_DELIVERY',          " Enh. Criteria
             c_case_ord  TYPE char20  VALUE 'CASE_ORDER',             " Enh. Criteria
             c_doc_typ   TYPE char20  VALUE 'DOCUMENT_TYPE',          " Enh. Criteria "Changes for CR#75 by APODDAR 12th Aug 14
             c_idd_0091  TYPE z_enhancement  VALUE 'D2_OTC_IDD_0091', " Enhancement No.
             c_posnr     TYPE posnr          VALUE '000000'.          " Subsequent item of an SD document
