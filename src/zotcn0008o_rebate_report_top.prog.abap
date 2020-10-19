*&---------------------------------------------------------------------*
*&  Include           ZOTCN0008O_REBATE_REPORT_TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCR0008O_REBATE_REPORT_TOP                           *
* TITLE      :  REBATE REPORT (PRICING)                                *
* DEVELOPER  :  ROHIT VERMA                                            *
* OBJECT TYPE:  INCLUDE                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0008_REBATE_REPORT                               *
*----------------------------------------------------------------------*
* DESCRIPTION: This Include is for data delaration of Report           *
*               ZOTCR0008O_REBATE_REPORT_TOP (Rebate Report).          *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 09-MAR-2012 RVERMA   E1DK901226 INITIAL DEVELOPMENT                  *
*&---------------------CR#6--------------------------------------------*
* 17-APR-2012 RVERMA   E1DK901226 Addition of fields Payer Desc,       *
*                                 Ship-to-Party Desc, Material Desc,   *
*                                 Rebate Basis, Currency Key in ALV    *
*                                 output. Changes in the fetching      *
*                                 logic of Ship-to-Party Value         *
* 21-MAY-2012 RVERMA   E1DK901226 Fetching field for condition currency*
*                                 changed from WAERS to KWAEH          *
*&---------------------CR#34-------------------------------------------*
* 12-JUN-2012 RVERMA   E1DK901226 Adding fields KVGR1(GPO Code) & KVGR2*
*                                 (IDN Code) and their description     *
*                                 fields in the report and removing    *
*                                 leading zeroes from customer material*
*                                 field and dividing dividing          *
*                                 KONV-KBETR by 10.                    *
*&---------------------CR#67-------------------------------------------*
* 26-JUL-2012 RVERMA   E1DK901226 Adding fields Sold-to-Party,         *
*                                 Sold-to-Party Description,           *
*                                 Product Division, Sales Amount fields*
*                                 in the report.                       *
*&---------------------------------------------------------------------*

TYPE-POOLS: slis.

***************************TYPES DECLARATION***************************

TYPES:
  BEGIN OF ty_bkpf,
   bukrs TYPE bukrs,    "Company Code
   belnr TYPE belnr_d,  "Accounting Doc No.
   gjahr TYPE gjahr,    "Fiscal Year
   awkey TYPE awkey,   "Reference Doc No.
   awkey1 TYPE vbeln_vf,  "Reference Doc No.
  END OF ty_bkpf,

  BEGIN OF ty_vbrk,
   vbeln TYPE vbeln_vf, "Billing Document
   fkart TYPE fkart,    "Billing Type
   vkorg TYPE vkorg,    "Sales Organization
   vtweg TYPE vtweg,    "Distribution Channel       "Added for CR#34
   knumv TYPE knumv,    "Number of the document condition
   fkdat TYPE fkdat,    "Billing date
   kunrg TYPE kunrg,    "Payer
   kunag TYPE kunag,    "Sold-to party             "Added for CR#67
  END OF ty_vbrk,

  BEGIN OF ty_vbrp,
   vbeln TYPE vbeln_vf,   "Billing Document
   posnr TYPE posnr_vf,   "Billing item
   meins TYPE meins,      "UoM
   fklmg TYPE fklmg,      "Billing quantity
   netwr TYPE netwr_fp,   "Net value                  "Added for CR#67
   aubel TYPE vbeln_va,   "Sales Document             "Added for CR#6
   matnr TYPE matnr,      "Material
   arktx TYPE arktx,      "Material Description       "Added for CR#6
   werks TYPE werks_d,    "Plant                      "Added for CR#67
   kvgr1 TYPE kvgr1,      "Customer group 1           "Added for CR#34
   kvgr2 TYPE kvgr2,      "Customer group 2           "Added for CR#34
   bonba TYPE bonba,      "Rebate Basis               "Added for CR#6
   kokrs TYPE kokrs,      "Controlling Area           "Added for CR#67
   knumv TYPE knumv,      "Number of the document condition
  END OF ty_vbrp,

  BEGIN OF ty_konv,
   knumv TYPE	knumv,    "Number of the document condition
   kposn TYPE kposn,    "Condition item number
   stunr TYPE stunr,    "Step number
   zaehk TYPE dzaehk,   "Condition counter
   kschl TYPE kscha,    "Condition type
   kbetr TYPE kbetr,    "Rate
   waers TYPE waers,    "currency key               "Added for CR#6
   kwert TYPE kwert,    "Condition value (Amount)
   kwaeh TYPE kwaeh,    "Condition currency
  END OF ty_konv,

  BEGIN OF ty_vbpa,
   vbeln TYPE vbeln,    "Document Number
   posnr TYPE posnr,    "Item number
   parvw TYPE parvw,    "Partner Function
   kunnr TYPE kunnr,    "Customer Number
  END OF ty_vbpa,

*&--Begin of changes for CR#6 on 17-APR-2012

  BEGIN OF ty_kna1,
   kunnr TYPE kunnr,    "Customer Number
   name1 TYPE name1_gp, "Customer Name
  END OF ty_kna1,

*&--End of changes for CR#6 on 17-APR-2012

*&--Begin of changes for CR#34 on 12-Jun-2012
  BEGIN OF ty_knvv,
   kunnr  TYPE kunnr, "Customer Number
   vkorg  TYPE vkorg, "Sales Organization
   vtweg  TYPE vtweg, "Distribution Channel
   spart  TYPE spart, "Division
   kvgr1  TYPE kvgr1, "Customer Grp1
   kvgr2  TYPE kvgr2, "Customer Grp2
   kvgr1t TYPE bezei20, "Customer Grp1 Desc
   kvgr2t TYPE bezei20, "Customer Grp2 Desc
  END OF ty_knvv,
*&--End of changes for CR#34 on 12-Jun-2012

*&--Begin of changes for CR#67 on 26-Jul-2012
  BEGIN OF ty_marc,
   matnr     TYPE matnr,    "Material Number
   werks     TYPE werks_d,  "Plant
   prctr     TYPE prctr,    "Profit Center
   kokrs     TYPE kokrs,    "Controlling Area
   prctr_nam TYPE char46,   "Name
  END OF ty_marc,

  BEGIN OF ty_cepc,
   prctr TYPE prctr,    "Profit Center
   datbi TYPE datbi,    "Valid To Date
   kokrs TYPE kokrs,    "Controlling Area
   name1 TYPE name1_gp, "Name
  END OF ty_cepc,
*&--End of changes for CR#67 on 26-Jul-2012

  BEGIN OF ty_final,
   vbeln      TYPE char10,   "Billing Document
   posnr      TYPE posnr_vf, "Billing Item
   fkdat      TYPE char10,   "Billing Date
   kunag      TYPE char10,   "Sold-to Number        "Added for CR#67
   kunag_name TYPE name1_gp, "Sold-to Name          "Added for CR#67
   kunrg      TYPE char10,   "Payer
   kunrg_name TYPE name1_gp, "Payer Name            "Added for CR#6
   kunnr      TYPE char10,   "Customer Number
   kunnr_name TYPE name1_gp, "Customer Name         "Added for CR#6
   matnr      TYPE char18,   "Material
   arktx      TYPE arktx,    "Material description  "Added for CR#6
   prctr_name TYPE char46,   "Profit Center No. + Name "Added for CR#67
   fklmg      TYPE fklmg,    "Billing Quantity
   meins      TYPE meins,    "UoM
   kschl      TYPE kscha,    "Condition Type
   kvgr1      TYPE kvgr1,    "Customer grp1         "Added for CR#34
   kvgr1t     TYPE bezei20,  "Customer grp1 desc    "Added for CR#34
   kvgr2      TYPE kvgr2,    "Customer grp2         "Added for CR#34
   kvgr2t     TYPE bezei20,  "Customer grp2 desc    "Added for CR#34
   netwr      TYPE netwr_fp, "Net Value             "Added for CR#67
   bonba      TYPE bonba,    "Rebate Basis          "Added for CR#6
   kbetr      TYPE kbetr,    "Rate
   waers      TYPE waers,    "currency key          "Added for CR#6
   kwert      TYPE kwert,    "Amount
   kwaeh      TYPE kwaeh,    "condition currency
  END OF ty_final,


*&--Table Type Declaration

  ty_t_bkpf  TYPE STANDARD TABLE OF ty_bkpf,"Table Type for TY_BKPF
  ty_t_vbrk  TYPE STANDARD TABLE OF ty_vbrk,"Table Type for TY_VBRK
  ty_t_vbrp  TYPE STANDARD TABLE OF ty_vbrp,"Table Type for TY_VBRP
  ty_t_konv  TYPE STANDARD TABLE OF ty_konv,"Table Type for TY_KONV
  ty_t_vbpa  TYPE STANDARD TABLE OF ty_vbpa,"Table Type for TY_KONV
  ty_t_kna1  TYPE STANDARD TABLE OF ty_kna1,"Table Type for TY_KNA1
  ty_t_final TYPE STANDARD TABLE OF ty_final,"Table Type for TY_FINAL
  ty_t_bapiret   TYPE STANDARD TABLE OF bapiret2,"Bapi Returb Tab Type

*&--Begin of changes for CR#34 on 12-Jun-2012
  ty_t_knvv  TYPE STANDARD TABLE OF ty_knvv, "Customer Master Data
*&--End of changes for CR#34 on 12-Jun-2012

*&--Begin of changes for CR#67 on 26-Jul-2012
  ty_t_marc TYPE STANDARD TABLE OF ty_marc, "Table TYpe for TY_MARC
  ty_t_cepc TYPE STANDARD TABLE OF ty_cepc. "Table Type for TY_CEPC
*&--End of changes for CR#67 on 26-Jul-2012

****************************CONSTANT DECLARATION***********************

CONSTANTS:
  c_parvw_we   TYPE parvw VALUE 'WE',  "Partner Function
  c_save       TYPE char1 VALUE 'A',  "used in alv for user save
  c_awtyp      TYPE awtyp VALUE 'VBRK', "Reference transaction
  c_msgty      TYPE symsgty VALUE 'I', "Information msg type

*&--Begin of changes for CR#6 on 17-APR-2012
  c_posnr_init TYPE posnr VALUE '000000',"Item value initial
*&--End of changes for CR#6 on 17-APR-2012

*&--Begin of changes for CR#34 on 12-Jun-2012
  c_spart_00   TYPE spart VALUE '00'.   "Division
*&--End of changes for CR#34 on 12-Jun-2012

***************************INTERNAL TABLE DECLARATION******************

DATA:
  i_accnt_doc_head TYPE ty_t_bkpf,"Accounting Doc Header Inernal tab
  i_bill_doc_head  TYPE ty_t_vbrk, "Billing Doc Header Inernal tab
  i_bill_doc_item  TYPE ty_t_vbrp, "Billing Doc Item Inernal tab
  i_conditions     TYPE ty_t_konv, "Conditions Inernal tab
  i_sales_partner  TYPE ty_t_vbpa, "Sales Partner Inernal tab

*&--Begin of changes for CR#6 on 17-APR-2012
  i_customer       TYPE ty_t_kna1, "Customer data table
*&--End of changes for CR#6 on 17-APR-2012

*&--Begin of changes for CR#34 on 12-Jun-2012
  i_cust_master    TYPE ty_t_knvv, "Customer data table
*&--End of changes for CR#34 on 12-Jun-2012

*&--Begin of changes for CR#67 on 26-Jul-2012
  i_plant_mat      TYPE ty_t_marc,
*&--End of changes for CR#67 on 26-Jul-2012

  i_final          TYPE ty_t_final,"Final Inernal tab for output

***************************WORK AREA DECLARATION***********************

  wa_bill_doc_head  TYPE ty_vbrk, "Billing doc header Workarea

***************************VARIABLE DECLARATION************************

  gv_repid TYPE syrepid,  "Program name
  gv_bukrs TYPE bukrs,    "Company Code
  gv_vkorg TYPE vkorg,    "sales organization
  gv_vbeln TYPE vbeln_vf, "billing document number
  gv_fkart TYPE fkart,    "billing document type
  gv_fkdat TYPE fkdat,    "billing date
  gv_kunrg TYPE kunrg,    "payer
  gv_kschl TYPE kscha,    "condition type

***************************ALV DATA DECLARATION************************

  i_fieldcat    TYPE slis_t_fieldcat_alv, "Fieldcatalog Internal tab
  wa_fieldcat   TYPE slis_fieldcat_alv,   "Fieldcatalog Workarea
  i_listheader  TYPE slis_t_listheader,   "List header internal tab
  wa_listheader TYPE slis_listheader.     "List header Workarea

***************************FIELD-SYMBOLS DECLARATION*******************

FIELD-SYMBOLS:
  <fs_vbrp> TYPE ty_vbrp,    "Field symbol for VBRP table
  <fs_bkpf> TYPE ty_bkpf,    "Field symbol for BKPF table

*&--Begin of changes for CR#6 on 17-APR-2012
  <fs_vbrk> TYPE ty_vbrk,    "Field symbol for VBRK table
  <fs_vbpa> TYPE ty_vbpa,    "Field symbol for VBPA table
*&--End of changes for CR#6 on 17-APR-2012

  <fs_knvv> TYPE ty_knvv.
