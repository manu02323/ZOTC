*&---------------------------------------------------------------------*
*&  Include           ZOTCN0165B_AUTO_FILLUP_TOP
*&---------------------------------------------------------------------*
***********************************************************************
*Program    : Include ZOTCN0165B_AUTO_FILLUP_TOP                      *
*Title      : ZOTCN0165B_AUTO_FILLUP_TOP                              *
*Developer  : Moushumi Bhattacharya                                   *
*Object type: Report Include                                          *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_EDD_0165                                           *
*---------------------------------------------------------------------*
*Description: This include has been created for the global data       *
*             declaration prt of the report                           *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*08-Aug-2014  MBHATTA1      E2DK901527     R2:DEV:D2_OTC_EDD_0165_Auto*
*                                          fill up orders             *
*---------------------------------------------------------------------*
*25-MAR-2014  ASK          E2DK901527    Defect 5267 : Making TVARVC  *
*                                        parameter Based On Sales Area*
*---------------------------------------------------------------------*
*25-MAR-2014  MBHATTA1     E2DK901527    Defect 5267 : Changed BDC for*
*                                        updating STVARV for new      *
*                                        variables                    *
*---------------------------------------------------------------------*
*04-Nov-2015  SAGARWA1     E2DK915951    Defect#1058 :Add Sales Office*
*                                        on Selection screen          *
*---------------------------------------------------------------------*
*12-Aug-2016  SAGARWA1      E2DK918614   Defect#1882 :Declare VBKD str*
*                                        ucture.                      *
*21-Nov-2017  AMOHAPA     E1DK931603    Defect# 4255: Unconfirmed     *
*                                       lines should transfer from ZKE*
*                                       to ZKB as per the design      *
*---------------------------------------------------------------------*
*06-Mar-2018  U033814     E1DK934326    R3 Changes Copy customer PO   *
*                                       from Sales order header to Item
*&---------------------------------------------------------------------*
*04-Jul-2018  PDEBARU     E1DK937536    Defect # 6345 : Sales BOM     *
*                                       components need to be ignored *
*                                       for copy from ZKE to ZKB as the*
*                                       Sales BOM header is exploding *
*                                       the BOM in ZKB                *
*&--------------------------------------------------------------------*
**********************************************************************
****************************TYPES*************************************
TYPES: BEGIN OF ty_vbak,
         vbeln TYPE vbeln, " Sales and Distribution Document Number
         erdat TYPE erdat, " Date on Which Record Was Created
         auart TYPE auart, " Sales Document Type
         vkorg TYPE vkorg, " Sales Organization
         vtweg TYPE vtweg, " Distribution Channel
         spart TYPE spart, " Division
*& -->Begin of Insert for Defect#1058 by SAGARWA1
         vkbur TYPE vkbur, " Sales Office
*& -->End   of Insert for Defect#1058 by SAGARWA1
* Begin of R3
         bstnk  TYPE bstnk, " Customer purchase order number
* End of R3
         bsark TYPE bsark, " Customer purchase order type
* Begin of R3
        bstdk  TYPE bstdk, " Customer purchase order date
* End of R3
       END OF ty_vbak,

       BEGIN OF ty_vbap,
         vbeln  TYPE vbeln_va, " Sales Document
         posnr  TYPE posnr_va, " Sales Document Item
         matnr  TYPE matnr,    " Material Number
*---> Begin of insert for Defect # 6345 D3_OTC_EDD_0165 by Pdebaru
         uepos  TYPE uepos, " Higher-level item in bill of material structures
*<--- End of insert for Defect # 6345 D3_OTC_EDD_0165 by Pdebaru
         abgru  TYPE abgru_va, " Reason for rejection of quotations and sales orders
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
         kwmeng TYPE kwmeng, " Cumulative Order Quantity in Sales Units
         vrkme  TYPE vrkme,  " Sales unit
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
* Begin of R3
        bstnk  TYPE bstnk, " Customer purchase order number
        bstdk  TYPE bstdk, " Customer purchase order date
* End of R3
       END OF ty_vbap,

       BEGIN OF ty_vbup,
         vbeln TYPE vbeln,              " Sales and Distribution Document Number
         posnr TYPE posnr,              " Item number of the SD document
         lfsta TYPE lfsta,              " Delivery status
       END OF ty_vbup,

       BEGIN OF ty_vbpa,
         vbeln TYPE vbeln,              " Sales and Distribution Document Number
         posnr TYPE posnr,              " Item number of the SD document
         parvw TYPE parvw,              " Partner Function
         kunnr TYPE kunnr,              " Customer Number
       END OF ty_vbpa,

       BEGIN OF ty_spool,
         kunnr_sp TYPE kunnr,           " Customer Number sold to
         kunnr_sh TYPE kunnr,           " Customer Number ship to
         vbeln    TYPE bapivbeln-vbeln, " Sales Document
         idoc_num TYPE edidc-docnum,    " IDoc number
       END OF ty_spool,

*--> Begin of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
*       BEGIN OF ty_lips,
*         vbeln TYPE vbeln_vl,           " Sales and Distribution Document Number
*         posnr TYPE posnr_vl,           " Delivery Item
*         matnr TYPE matnr,              " Material Number
*         lfimg TYPE lfimg,              " Actual quantity delivered (in sales units)
*         meins TYPE meins,              " Base Unit of Measure
*         vgbel TYPE vgbel,              " Document number of the reference document
*         vgpos TYPE vgpos,              " Item number of the reference item
*       END OF ty_lips,
*<-- End of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017

       BEGIN OF ty_final,
         soldto TYPE kunnr, " Customer Number
         shipto TYPE kunnr, " Customer Number
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
         vbeln  TYPE vbeln_va, " Sales Document
         bstkd  TYPE bstkd,    " Customer purchase order number
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
       END OF ty_final,

       BEGIN OF ty_kna1,
         kunnr TYPE kunnr,        " Customer Number
         katr2 TYPE katr2,        " Attribute 2
       END OF ty_kna1,

       BEGIN OF ty_matnr,
           soldto     TYPE kunnr, " Customer Number
           shipto     TYPE kunnr, " Customer Number
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
           vbeln  TYPE vbeln_va, " Sales Document
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
           material   TYPE matnr,  " Material Number
           target_qty TYPE kwmeng, " Cumulative Order Quantity in Sales Units
           target_qu  TYPE dzieme, " Target quantity UoM
* Begin of R3
        bstnk  TYPE bstnk, " Customer purchase order number
        bstdk  TYPE bstdk, " Customer purchase order date
* End of R3
       END OF ty_matnr,

*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
       BEGIN OF ty_vbkd,
         vbeln  TYPE vbeln, " Sales and Distribution Document Number
         bstkd  TYPE bstkd, " Customer purchase order number
       END OF ty_vbkd.
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
**********************************************************************
**********************Table Type Declaration**************************

TYPES: ty_t_vbak  TYPE STANDARD TABLE OF ty_vbak, "table type declaration for VBAK
       ty_t_vbap  TYPE STANDARD TABLE OF ty_vbap, "table type declaration for VBAP
       ty_t_vbup  TYPE STANDARD TABLE OF ty_vbup, "table type declaration for VBUP
       ty_t_vbpa  TYPE STANDARD TABLE OF ty_vbpa, "table type declaration for VBPA
*--> Begin of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
*       ty_t_lips  TYPE STANDARD TABLE OF ty_lips,  "table type declaration for LIPS
*<-- End of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
       ty_t_kna1  TYPE STANDARD TABLE OF ty_kna1,                   "table type declaration for KNA1
       ty_t_matnr TYPE STANDARD TABLE OF ty_matnr,                  "table type declaration for material
       ty_t_spool TYPE STANDARD TABLE OF ty_spool,                  "table type declaration for spool
       ty_t_final TYPE STANDARD TABLE OF ty_final,                  "table type declaration for final
       ty_t_zdev_enh_status TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
       ty_t_vbkd  TYPE STANDARD TABLE OF ty_vbkd INITIAL SIZE 0. " Table type  declaration for VBKD
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016

TYPES: ty_t_bdcdata TYPE STANDARD TABLE OF bdcdata . " Batch input: New table field structure

**********************************************************************
****************************CONSTANTS*********************************

CONSTANTS: c_var      TYPE char20     VALUE 'ZOTC_AUTOFILL', " Var of type CHAR20           ##NEEDED
* Begin   of Change for Defect 5267
           c_type     TYPE rsscr_kind VALUE 'S', " Parameter type               ##NEEDED
           c_undrscr  TYPE c          VALUE '_', " Undrscr of type Character
* End   of Change for Defect 5267
           c_shipto   TYPE parvw      VALUE 'WE', " Partner Function             ##NEEDED
           c_soldto   TYPE parvw      VALUE 'AG', " Partner Function             ##NEEDED
           c_splstk   TYPE parvw      VALUE 'SB'. " Partner Function             ##NEEDED

**********************************************************************
****************************VARIABLES*********************************

DATA: gv_kunnr TYPE kunnr,      " Customer Number                                  ##NEEDED
      gv_date  TYPE sy-datum,   " Date                                             ##NEEDED
      gv_vbeln TYPE vbak-vbeln, " Sales and Distribution Document Number           ##NEEDED
      gv_name  TYPE rvari_vnam, " ABAP: Name of Variant Variable " Defect 5267
      gv_incpo TYPE incpo.      " Increment of item number in the SD document      ##NEEDED

**********************************************************************
************************INTERNAL TABLES*******************************

DATA: i_vbak      TYPE ty_t_vbak, "table declaration for VBAK                     ##NEEDED
      i_vbap      TYPE ty_t_vbap, "table declaration for VBAP                     ##NEEDED
      i_vbup      TYPE ty_t_vbup, "table declaration for VBUP                     ##NEEDED
      i_vbpa      TYPE ty_t_vbpa, "table declaration for VBPA                     ##NEEDED
*--> Begin of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
*      i_lips      TYPE ty_t_lips,           "table declaration for LIPS                     ##NEEDED
*<-- End of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
      i_bdcdata   TYPE ty_t_bdcdata,        "For BDC data                                   ##NEEDED
      i_fieldcat  TYPE slis_t_fieldcat_alv, "alv field catalog                              ##NEEDED
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
      i_vbkd      TYPE ty_t_vbkd. " Table declaration for VBKD
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
**********************************************************************
