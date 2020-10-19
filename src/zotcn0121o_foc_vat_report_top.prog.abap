*&---------------------------------------------------------------------*
*&  Include           ZOTCN0121O_FOC_VAT_REPORT_TOP
*&---------------------------------------------------------------------*
* PROGRAM    :  ZOTCR0121O_FOC_VAT_REPORT                              *
* TITLE      :  FOC VAT Report                                         *
* DEVELOPER  :  Sumanpreet Kaur                                        *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  : D3_OTC_RDD_0121                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: FOC Report for VAT                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER    TRANSPORT     DESCRIPTION                      *
* =========== ======== ========== =====================================*
* 20-APR-2018 U034334  E1DK936059 Initial Development                  *
* 16-MAY-2018 U034334  E1DK936059 Defect_6082: Include Drop-Ship Sales *
*                                 Orders in the ALV, add Inv Unit Price*
* 25-JUL-2018 U034334  E1DK937964 Defect_6735:Print SO item, Display IC*
*                                 Invoice for Batch Split, Display Cost*
*                                 centre from SO header if not at item *
*&---------------------------------------------------------------------*

*&--Global Constants
CONSTANTS: c_prsfd TYPE prsfd  VALUE 'B', " Carry out pricing
           c_err   TYPE char1  VALUE 'E', " Error
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
           c_eur   TYPE waerk  VALUE 'EUR'. " SD Document Currency
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

*&--Global Structure Types
TYPES:
* Delivery Items
         BEGIN OF ty_lips,
           vbeln TYPE vbeln_vl, " Delivery
           posnr TYPE posnr_vl, " Delivery Item
           werks TYPE werks_d,  " Plant
           meins TYPE meins,    " Base Unit of Measure
           lgmng TYPE lgmng,    " Actual quantity delivered in stockkeeping units
           vgbel TYPE vgbel,    " Document number of the reference document
           vgpos TYPE vgpos,    " Item number of the reference item
           uecha TYPE uecha,    " Higher-Level Item of Batch Split Item
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
           wadat_ist  TYPE wadat_ist, " Actual Goods Movement Date
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
         END OF ty_lips,

* Delivery Header
         BEGIN OF ty_likp,
           vbeln     TYPE vbeln_vl,  " Delivery
           vkorg     TYPE vkorg,     " Sales Organization
           wadat_ist TYPE wadat_ist, " Actual Goods Movement Date
         END OF ty_likp,

* Sales Order Header
         BEGIN OF ty_vbak,
           vbeln TYPE vbeln_va, " Sales Document
           auart TYPE auart,    " Sales Document Type
           augru TYPE augru,    " Order reason (reason for the business transaction)
           waerk TYPE waerk,    " SD Document Currency
           vtweg TYPE vtweg,    " Distribution Channel
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
           kostl TYPE kostl, " Cost Centre
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
         END OF ty_vbak,

* Sales Order Items
         BEGIN OF ty_vbap,
           vbeln  TYPE vbeln_va, " Sales Document
           posnr  TYPE posnr_va, " Sales Document Item
           matnr  TYPE matnr,    " Material Number
           arktx  TYPE arktx,    " Short text for sales order item
           pstyv  TYPE pstyv,    " Sales document item category
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
           zmeng  TYPE dzmeng, " Target quantity in sales units
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
           kwmeng TYPE kwmeng, " Cumulative Order Quantity in Sales Units
           wavwr  TYPE wavwr,  " Cost in document currency
           prctr  TYPE prctr,  " Profit Center
           kostl  TYPE kostl,  " Cost Center
         END OF ty_vbap,

* Invoice Header
         BEGIN OF ty_vbrk,
           vbeln TYPE vbeln_vf, " Billing Document
           waerk TYPE waerk,    " SD Document Currency
           fkdat TYPE fkdat,    " Billing date for billing index and printout
         END OF ty_vbrk,

* Invoice Items
         BEGIN OF ty_vbrp,
           vbeln TYPE vbeln_vf, " Billing Document
           posnr TYPE posnr_vf, " Billing item
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
           fklmg TYPE fklmg, " Billing quantity in stockkeeping unit
           fbuda TYPE fbuda, " Date on which services rendered
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
           netwr TYPE netwr_fp, " Net value of the billing item in document currency
           werks TYPE werks_d,  " Plant
         END OF ty_vbrp,

* Invoices from Delivery
         BEGIN OF ty_vbfa,
           vbelv TYPE vbeln_von,  " Preceding sales and distribution document
           posnv TYPE posnr_von,  " Preceding item of an SD document
           vbeln TYPE vbeln_nach, " Subsequent sales and distribution document
           posnn TYPE posnr_nach, " Subsequent item of an SD document
* ---> Begin of Delete for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
*           rfmng TYPE rfmng,      " Referenced quantity in base unit of measure
*           rfwrt TYPE rfwrt,      " Reference value
* <--- End   of Delete for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
           plmin TYPE plmin, " Quantity is calculated positively, negatively or not at all
         END OF ty_vbfa,

* Plant Details
         BEGIN OF ty_t001w,
           werks TYPE werks_d, " Plant
           name1 TYPE name1,   " Name
         END OF ty_t001w,

* Cost Centre texts
         BEGIN OF ty_cskt,
           kostl TYPE kostl, " Cost Center
           datbi TYPE datbi, " Valid To Date
           ktext TYPE ktext, " General Name
         END OF ty_cskt,

* Profit Centre texts
         BEGIN OF ty_cepct,
           prctr TYPE prctr, " Profit Center
           datbi TYPE datbi, " Valid To Date
           ktext TYPE ktext, " General Name
         END OF ty_cepct,

* Customer Details
         BEGIN OF ty_kna1,
           kunnr TYPE kunnr,    " Customer Number
           name1 TYPE name1_gp, " Name 1
           loevm TYPE loevm_x,  " Central Deletion Flag for Master Record
         END OF ty_kna1,

* Partners Data
         BEGIN OF ty_vbpa,
           vbeln TYPE vbeln, " Sales and Distribution Document Number
           posnr TYPE posnr, " Item number of the SD document
           parvw TYPE parvw, " Partner Function
           kunnr TYPE kunnr, " Customer Number
         END OF ty_vbpa,

* Order Reason texts
         BEGIN OF ty_tvaut,
           augru TYPE augru,   " Order reason (reason for the business transaction)
           bezei TYPE bezei40, " Description
         END OF ty_tvaut,

* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
* Range Table
         BEGIN OF ty_range,
           sign TYPE char1,   " Sign of type CHAR1
           option TYPE char2, " Option of type CHAR2
           low TYPE char4,    " Low of type CHAR24
           high TYPE char4,   " High of type CHAR24
         END OF ty_range,

* Order Type texts
         BEGIN OF ty_tvakt,
           auart TYPE auart,   " Sales Document Type
           bezei TYPE bezei20, " Description
         END OF ty_tvakt,

* Item Catogory texts
         BEGIN OF ty_tvapt,
           pstyv TYPE pstyv,         " Sales document item category
           vtext TYPE bezei20,       " Description
         END OF ty_tvapt,

         BEGIN OF ty_foc_lips,
           vbeln TYPE vbeln_vl,      " Delivery
           posnr TYPE posnr_vl,      " Delivery Item
           werks TYPE werks_d,       " Plant
           meins TYPE meins,         " Base Unit of Measure
           lgmng TYPE lgmng,         " Actual quantity delivered in stockkeeping units
           vgbel TYPE vgbel,         " Document number of the reference document
           vgpos TYPE vgpos,         " Item number of the reference item
           uecha TYPE uecha,         " Higher-Level Item of Batch Split Item
           wadat_ist TYPE wadat_ist, " Actual Goods Movement Date
         END OF ty_foc_lips,
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

* Final table for Display
         BEGIN OF ty_final,
           so_vtweg     TYPE vtweg,    " Distribution Channel
           so_matnr     TYPE matnr,    " Material Number
           so_arktx     TYPE arktx,    " Material Description
           so_vbeln     TYPE vbeln_va, " Sales Order No.
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
           so_item      TYPE posnr_va, " Sales Order Item
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
           so_auart     TYPE auart,   " Sales Document Type
           so_descr     TYPE bezei20, " Description
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
           delv_vbeln   TYPE vbeln_vl, " Delivery No.
           delv_item    TYPE posnr_vl, " Delivery Item
           delv_date    TYPE lfdat,    " Delivery Date
           inv_vbeln    TYPE vbeln_vf, " Invoice No.
           inv_item     TYPE posnr_vf, " Invoice Item
           inv_date     TYPE fkdat,    " Invoice Date
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
           inv_unitprice TYPE netwr_fp, " Invoice Unit Price
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
           inv_amt      TYPE netwr_fp, " Net value of the billing item in document currency
           doc_curr     TYPE waerk,    " Invoice Document Currency
           unit_price   TYPE kbetr,    " Rate (condition amount or percentage)
           net_price    TYPE kwert,    " Condition value
           delv_qty     TYPE lgmng,    " Actual quantity delivered in stockkeeping units
           delv_uom     TYPE meins,    " Base Unit of Measure
           delv_plant   TYPE werks_d,  " Plant
           plant_txt    TYPE name1,    " Plant Name
           cost_centre  TYPE kostl,    " Cost Center
           cost_ctr_txt TYPE ktext,    " Cost Centre Name
           profit_ctr   TYPE pctrf,    " Profit Center for Billing
           prft_ctr_txt TYPE mctxt,    " Profit Centre Name
           so_item_cat  TYPE pstyv,    " Sales Order item category
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
           item_cat_txt TYPE bezei20, " SO Item Category Description
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
           so_soldto    TYPE kunnr,    " Sold-to party
           soldto_txt   TYPE name1_gp, " Sold-to Name
           so_shipto    TYPE kunnr,    " Ship-to party
           shipto_txt   TYPE name1_gp, " Ship-to Name
           order_reason TYPE bezei40,  " Order reason (reason for the business transaction)
         END OF ty_final,

*&--Global Table Types
       ty_t_lips     TYPE STANDARD TABLE OF ty_lips,  " Table Type for LIPS
       ty_t_likp     TYPE STANDARD TABLE OF ty_likp,  " Table Type for LIKP
       ty_t_vbak     TYPE STANDARD TABLE OF ty_vbak,  " Table Type for VBAK
       ty_t_vbap     TYPE STANDARD TABLE OF ty_vbap,  " Table Type for VBAP
       ty_t_vbrk     TYPE STANDARD TABLE OF ty_vbrk,  " Table Type for VBRK
       ty_t_vbrp     TYPE STANDARD TABLE OF ty_vbrp,  " Table Type for VBRP
       ty_t_t001w    TYPE STANDARD TABLE OF ty_t001w, " Table Type for T001W
       ty_t_cskt     TYPE STANDARD TABLE OF ty_cskt,  " Table Type for CSKT
       ty_t_cepct    TYPE STANDARD TABLE OF ty_cepct, " Table type for CEPCT
       ty_t_kna1     TYPE STANDARD TABLE OF ty_kna1,  " Table Type for KNA1
       ty_t_vbpa     TYPE STANDARD TABLE OF ty_vbpa,  " Table Type for VBPA
       ty_t_tvaut    TYPE STANDARD TABLE OF ty_tvaut, " Table Type for TVAUT
       ty_t_vbfa     TYPE STANDARD TABLE OF ty_vbfa,  " Table Type for Doc Flow
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
       ty_t_tvakt    TYPE STANDARD TABLE OF ty_tvakt, " Table Type for Sales Order Type Texts
       ty_t_tvapt    TYPE STANDARD TABLE OF ty_tvapt, " Table Type for SO Item Category Texts
       ty_t_range    TYPE STANDARD TABLE OF ty_range,
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
       ty_t_final    TYPE STANDARD TABLE OF ty_final,        " Table Type for I_FINAL
       ty_t_emi      TYPE STANDARD TABLE OF zdev_enh_status. " Table Type for Enhancement Status

*&--Global Varibles
DATA: gv_date      TYPE wadat_ist,  " Actual Goods Movement Date
      gv_vtweg     TYPE vtweg,      " Distribution Channel
      gv_lfart     TYPE likp-lfart, " Delivery Type
      gv_kunag     TYPE kunnr,      " Sold-to party
      gv_kunwe     TYPE kunnr,      " Ship-to party
      gv_auart     TYPE vbak-auart, " Sales Document Type
      gv_pstyv     TYPE vbap-pstyv, " Sales document item category
      gv_prsfd     TYPE prsfd,      " Carry out pricing
      gv_col_pos   TYPE sycucol,    " Horizontal Cursor Position at PAI
      gv_vkorg_txt TYPE vtxtk,      " Sales Org Name
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
      gv_werks     TYPE werks_d, " Plant
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

*&--Global Internal Tables
      i_enh_status  TYPE ty_t_emi,            " Enhancement Status
      i_final       TYPE ty_t_final,          " Final table for ALV display
      i_fieldcat    TYPE slis_t_fieldcat_alv. " Field catalogue for ALV
