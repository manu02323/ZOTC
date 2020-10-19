*&---------------------------------------------------------------------*
*&  Include           ZOTCN0101O_PRICE_DATE_UPD_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0101O_PRICE_DATE_UPD_TOP                          *
* TITLE      :  Pricing Date Update Report                             *
* DEVELOPER  :  ROHIT VERMA                                            *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_EDD_0101_Pricing Date Update                       *
*----------------------------------------------------------------------*
* DESCRIPTION: This is a top include program of Report                 *
*              ZOTCR0101O_PRICE_DATE_UPD. All global declaration of    *
*              this report are declared in this include program        *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 03-Oct-2013 RVERMA   E1DK913507 INITIAL DEVELOPMENT - CR#649         *
*&---------------------------------------------------------------------*
* 07-Feb-2014 RVERMA   E1DK913507 MOD-001: Def#649 - Additional changes*
*                                 related to data fetching from VBUK   *
*                                 (Order Status data), VBKD (Business  *
*                                 data) and VBAP (Order Item) table.   *
*&---------------------------------------------------------------------*
* 27-Mar-2014 RVERMA   E1DK913507 MOD-002: Def#649 - Addition of Screen*
*                                 fields Customer Grp1 and Customer    *
*                                 Grp2. Also make the screen field     *
*                                 Sold-to single entry field.          *
*&---------------------------------------------------------------------*
* 31-AUG-2017 SMUKHER4 E1DK930340/ Defect#3400 -Following changes are done
*                      E1DK930342  in the program:                     *
*                                 1)The selection will have a field    *
*                                 (Range) for Requested Delivery Date  *
*                                  (non-Mandatory).                    *
*                                 2)The mandatory fields should only be*
*                                   removed for background mode, when  *
*                                   the user executes a transaction in *
*                                   the foreground, the mandatory fields*
*                                   should be activated.               *
*                                 3)The system will consider all the   *
*                                  orders line items with requested    *
*                                   delivery date + 1 Day.             *
*                                 4)Once the job is completed          *
*                                  successfully, the date (req del date+1)
*                                 is added to EMI table, this date     *
*                                 will be populated in the requested   *
*                                  delivery date field in the next run.*
*                                5)Currently when the report is executed*
*                                  in the foreground, the user is      *
*                                  expected to select all the lines and*
*                                  click on update button, however, in *
*                                  the background, this should be done *
*                                  automatically.                      *
*                                6)All efforts needs to be made to     *
*                                 increase the performance of program  *
*                                 while executing during background.   *
*08-Aug-2018  AMOHAPA E1DK930340  Defect#3400(Part 2): 1)Program to be *
*                                 Later taged with Defect#7955         *
*                                 made to process D3 sales organization*
*                                 records with different logic from    *
*                                 existing program                     *
*                                 2) Output of Batchjob to be import   *
*                                    in an excel sheet                 *
*25-Oct-2018  AMOHAPA E1DK930340  Defect#3400(Part 2)_FUT Issues:      *
*                                 Later taged with Defect#7955         *
*                                 1)Actual good movement date (LIKP-   *
*                                 WADAT_IST) is added in the selection *
*                                 screen                               *
*                                 2) Now pricing date is updated with  *
*                                 Actual good movement date            *
*                                 3)Instead of VBUK,now we are checking*
*                                 VBUP for Billing,POD and PGI status  *
*                                 4) We will update the pricing date   *
*                                 where pricing date is not same as    *
*                                 Actual goods movement date           *
*&---------------------------------------------------------------------*

***************************TYPES DECLARATION****************************
TYPES:
  BEGIN OF ty_vbak,      "Sales Document: Header Data
    vbeln TYPE vbeln_va, "Sales Document Number
    erdat TYPE erdat,    "Date on Which Record Was Created
    auart TYPE auart,    "Sales Document Type
    vkorg TYPE vkorg,    "Sales Organization
    vtweg TYPE vtweg,    "Distribution Channel
    spart TYPE spart,    "Division
    kunag TYPE kunag,    "Sold-to Party
  END OF ty_vbak,
*&--Table type for Sales Document: Header Data
  ty_t_vbak TYPE STANDARD TABLE OF ty_vbak,

  BEGIN OF ty_vbap,       "Sales Document: Item Data
    vbeln  TYPE vbeln_va, "Sales Document Number
    posnr  TYPE posnr_va, "Sales Document Item Number
    matnr  TYPE matnr,    "Material Number
*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
    abgru  TYPE abgru_va, " Reason for rejection of quotations and sales orders
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
    meins  TYPE meins,     "Base Unit of Measure
    kwmeng TYPE kwmeng,    "Order Quantity
    werks  TYPE werks_ext, "Delivering Plant
  END OF ty_vbap,
*&--Table type for Sales Document: Item Data
  ty_t_vbap TYPE STANDARD TABLE OF ty_vbap,

  BEGIN OF ty_vbpa,   "Sales Document: Partner Data
    vbeln TYPE vbeln, "Document Number
    posnr TYPE posnr, "Item Number
    parvw TYPE parvw, "Partner Function
    kunnr TYPE kunnr, "Ship-to Party
  END OF ty_vbpa,
*&--Table type for Sales Document: Partner Data
  ty_t_vbpa TYPE STANDARD TABLE OF ty_vbpa,

  BEGIN OF ty_vbup,      "Sales Document: Item Status
    vbeln TYPE vbeln,    "Document Number
    posnr TYPE posnr,    "Item Number
    lfsta TYPE lfsta,    "Delivery status
    fksta TYPE fksta,    "Billing status of delivery-related billing documents
    fksaa TYPE fksaa,    "Billing Status for Order-Related Billing Documents
    absta TYPE absta_vb, "Rejection status for SD item
  END OF ty_vbup,
*&--Table type for Sales Document: Item Status
  ty_t_vbup TYPE STANDARD TABLE OF ty_vbup,

  BEGIN OF ty_vbep,      "Sales Document: Schedule Line Data
    vbeln TYPE vbeln_va, "Document Number
    posnr TYPE posnr_va, "Item Number
    etenr TYPE etenr,    "Delivery Schedule Line Number
    edatu TYPE edatu,    "Schedule line date/First Date
    bmeng TYPE bmeng,    " Defect # 3400
  END OF ty_vbep,
*&--Table type for Sales Document: Schedule Line Data
  ty_t_vbep TYPE STANDARD TABLE OF ty_vbep,

  BEGIN OF ty_vbkd,   "Sales Document: Business Data
    vbeln TYPE vbeln, "Document Number
    posnr TYPE posnr, "Item Number
    prsdt TYPE prsdt, "Pricing Date
  END OF ty_vbkd,
*&--Table type for Sales Document: Business Data
  ty_t_vbkd TYPE STANDARD TABLE OF ty_vbkd,

  BEGIN OF ty_kna1,      "Customer General Data
    kunnr TYPE kunnr,    "Customer Number/Ship-to Party
    name1 TYPE name1_gp, "Ship-to Party Name
  END OF ty_kna1,
*&--Table type for Customer general data
  ty_t_kna1 TYPE STANDARD TABLE OF ty_kna1,

  BEGIN OF ty_knvv,   "Customer Master Sales Data
    kunnr TYPE kunnr, "Customer Number
    vkorg TYPE vkorg, "Sales Org
    vtweg TYPE vtweg, "Distribution Channel
    spart TYPE spart, "Division
*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
    loevm TYPE loevm_v, "Deletion flag for customer (sales level)
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
    kvgr1 TYPE kvgr1, "Customer Group1
    kvgr2 TYPE kvgr2, "Customer Group2
  END OF ty_knvv,
*&--Table type for Customer Master Sales Data
  ty_t_knvv TYPE STANDARD TABLE OF ty_knvv,

  BEGIN OF ty_tvv1t,    "Customer group 1: Description
    kvgr1 TYPE kvgr1,   "Customer Group1
    bezei TYPE bezei20, "Description
  END OF ty_tvv1t,
*&--Table type for Customer group 1: Description
  ty_t_tvv1t TYPE STANDARD TABLE OF ty_tvv1t,

  BEGIN OF ty_tvv2t,    "Customer group 2: Description
    kvgr2 TYPE kvgr2,   "Customer Group2
    bezei TYPE bezei20, "Description
  END OF ty_tvv2t,
*&--Table type for Customer group 2: Description
  ty_t_tvv2t TYPE STANDARD TABLE OF ty_tvv2t,

  BEGIN OF ty_makt,   "Material Descriptions
    matnr TYPE matnr, "Material Number
    maktx TYPE maktx, "Description
  END OF ty_makt,
*&--Table type for Material Description
  ty_t_makt TYPE STANDARD TABLE OF ty_makt,

  BEGIN OF ty_final_hdr,    "Final Header Data
    sel      TYPE xfeld,    "Checkbox field
    vkorg    TYPE vkorg,    "Sales Org
    vtweg    TYPE vtweg,    "Distributin Channel
    spart    TYPE spart,    "Division
    auart    TYPE auart,    "Sales Doc type
    vbeln    TYPE vbeln_va, "Sales Doc Number
    kunag    TYPE kunag,    "Sold-to Party
    name1_ag TYPE name1_gp, "Sold-to Party Name
    kunnr    TYPE kunnr,    "Ship-to Party
    name1_we TYPE name1_gp, "Ship-to Party Name
    kvgr1    TYPE kvgr1,    "Customer Group1
    bezei_1  TYPE bezei20,  "Customer Group1 Description
    kvgr2    TYPE kvgr2,    "Customer Group2
    bezei_2  TYPE bezei20,  "Customer Group2 Description
    expand   TYPE char1,    "Expand Field
  END OF ty_final_hdr,
*&--Table type for Final Header Data
  ty_t_final_hdr TYPE STANDARD TABLE OF ty_final_hdr,

  BEGIN OF ty_final,         "Final Item Data
    sel      TYPE xfeld,     "Checkbox field
    vkorg    TYPE vkorg,     "Sales Org
    vtweg    TYPE vtweg,     "Distribution Channel
    spart    TYPE spart,     "Division
    auart    TYPE auart,     "Sales Doc Type
    vbeln    TYPE vbeln_va,  "Sales Doc Number
    kunag    TYPE kunag,     "Sold-to Party
    name1_ag TYPE name1_gp,  "Sold-to Party Name
    posnr    TYPE posnr_va,  "Sales Doc Item Number
    matnr    TYPE matnr,     "Material Number
    maktx    TYPE maktx,     "Material Description
    werks    TYPE werks_ext, "Delivering Plant
    kunnr    TYPE kunnr,     "Ship-to Party
    name1_we TYPE name1_gp,  "Ship-to Party Name
    prsdt    TYPE prsdt,     "Pricing Date
    edatu    TYPE edatu,     "First Date/Delivery Date
    meins    TYPE meins,     "UoM
    kwmeng   TYPE kwmeng,    "Order Quantity
    kvgr1    TYPE kvgr1,     "Customer Group1
    bezei_1  TYPE bezei20,   "Customer Group1 Description
    kvgr2    TYPE kvgr2,     "Customer Group2
    bezei_2  TYPE bezei20,   "Customer Group2 Description
  END OF ty_final,
*&--Table type Final Item Data
  ty_t_final TYPE STANDARD TABLE OF ty_final,
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
  ty_t_status TYPE STANDARD TABLE OF zdev_enh_status, "Table type for EMI table

  BEGIN OF ty_likp,
  vbeln	TYPE vbeln_vl,                                "Delivery
  erdat	TYPE erdat,                                   "Date on Which Record Was Created
  vkorg	TYPE vkorg,                                   "Sales Organization
  lfart	TYPE lfart,                                   "Delivery Type
  vtwiv	TYPE vtwiv,                                   "Distribution channel for intercompany billing
  spaiv	TYPE spaiv,                                   "Division for intercompany billing
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
  wadat_ist	TYPE wadat_ist,
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
  END OF ty_likp,
*--> Begin of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
"We will use VBUP table to check with the Item level status
*  BEGIN OF ty_vbuk,
*  vbeln  TYPE vbeln,                                   "Sales and Distribution Document Number
*  fkstk  TYPE fkstk,                                   "Billing status
*  END OF ty_vbuk,
*<-- End of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
   BEGIN OF ty_vbup_d3,
   vbeln  TYPE vbeln, " Sales and Distribution Document Number
   posnr  TYPE posnr, " Item number of the SD document
   wbsta  TYPE wbsta, " Goods movement status
   fksta  TYPE fksta, " Billing status of delivery-related billing documents
   pdsta  TYPE pdsta, " POD status on item level
   END OF ty_vbup_d3,
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
  BEGIN OF ty_lips,
  vbeln	TYPE vbeln_vl,                                           "Delivery
  erdat TYPE erdat,                                              " Date on Which Record Was Created
  vgbel	TYPE vgbel,                                              "Document number of the reference document
  vgpos	TYPE vgpos,                                              "Item number of the reference item
  END OF ty_lips,

  BEGIN OF ty_vkorg,
  sign   TYPE char1,                                             " Sign of type CHAR1
  option TYPE char2,                                             " Option of type CHAR2
  low    TYPE vkorg,                                             " Sales Organization
  high   TYPE vkorg,                                             " Sales Organization
  END OF ty_vkorg,
  ty_t_vkorg   TYPE STANDARD TABLE OF ty_vkorg   INITIAL SIZE 0, "Table type for VKORG
  ty_t_likp    TYPE STANDARD TABLE OF ty_likp    INITIAL SIZE 0, "Table type for likp
  ty_t_lips    TYPE STANDARD TABLE OF ty_lips    INITIAL SIZE 0, "Table type for lips
*--> Begin of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*  ty_t_vbuk    TYPE STANDARD TABLE OF ty_vbuk    INITIAL SIZE 0. "Table type for vbuk
*<-- End of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
    ty_t_vbup_d3  TYPE STANDARD TABLE OF ty_vbup_d3    INITIAL SIZE 0.
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018

***************************CONSTANT DECLARATION*************************
CONSTANTS:
*&--Item Number '000000'
  c_posnr_00    TYPE posnr   VALUE '000000', " Item number of the SD document
*&--Delivery Schedule Line Number '0001'
  c_etenr_01    TYPE etenr   VALUE '0001', " Delivery Schedule Line Number
*&--Partner Function: Ship-to Party 'WE'
  c_parvw_we    TYPE parvw   VALUE 'WE', " Partner Function
*&--Status Not yet processed
  c_status_a    TYPE lfsta   VALUE 'A', "MOD-001 ++
*&--Status Partially Processes
**  c_status_b    TYPE lfsta   VALUE 'B',   "MOD-001 --
*&--Status Completely Processed
**  c_status_c    TYPE lfsta   VALUE 'C',   "MOD-001 --
*&--Header indicator.
  c_type        TYPE char1   VALUE 'S',
*&--Function Code: Select All
  c_sall        TYPE syucomm VALUE '&SALL', " Function code that PAI triggered
*&--Function Code: Deselect All
  c_dall        TYPE syucomm VALUE '&DALL', " Function code that PAI triggered
*&--Function Code: Update
  c_updt        TYPE syucomm VALUE '&UPDT', " Function code that PAI triggered
*&--Function Code: Checkbox
  c_chkd        TYPE syucomm VALUE '&IC1', " Function code that PAI triggered
*&--Check
  c_check       TYPE char1   VALUE 'X', " Check of type CHAR1
*&--Field: SEL
  c_field_sel   TYPE slis_fieldname VALUE 'SEL',
*&--Ans Button '1'
  c_ans_1       TYPE char1   VALUE '1', " Ans_1 of type CHAR1
*&--Ans Button '2'
  c_ans_2       TYPE char1   VALUE '2', " Ans_2 of type CHAR1
*&--Hash
  c_hash        TYPE char1   VALUE '#', " Hash of type CHAR1
*&--GUI Status (PF Status)
  c_gui_status  TYPE gui_status VALUE 'ZOTC_0101_PF', " Menu Painter: Status code
*&--Select Option Name
  c_selname     TYPE rsscr_name VALUE 'S_DATA', " ABAP/4: Name of SELECT-OPTION / PARAMETER
*&--Sign 'I'
  c_sign_i      TYPE tvarv_sign VALUE 'I', " ABAP: ID: I/E (include/exclude values)
*&--Kind 'S'
  c_kind_s      TYPE rsscr_kind VALUE 'S', " ABAP: Type of selection
*&--Option 'EQ'
  c_option_eq   TYPE tvarv_opti VALUE 'EQ', " ABAP: Selection option (EQ/BT/CP/...)
*&-->Begin of change for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
  c_enhancement TYPE z_enhancement VALUE 'OTC_EDD_0101', " Default Status
*&-->Begin of delete for FUT changes D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 23-OCT-2017
*  c_date        TYPE z_criteria    VALUE 'DATE_FIELDS',  " Enh. Criteria
*&<--End of delete for FUT changes D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 23-OCT-2017
  c_sign        TYPE bapisign      VALUE 'I',  " Inclusion/exclusion criterion SIGN for range tables
  c_eq          TYPE bapioption    VALUE 'EQ'. " Selection operator OPTION for range tables
*&<--End of change for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017


***************************INTERNAL TABLE DECLARATION*******************
DATA:
  i_vbak      TYPE ty_t_vbak,      "SO Header Internal Table
  i_vbap      TYPE ty_t_vbap,      "SO Item Internal Table
  i_vbpa      TYPE ty_t_vbpa,      "SO Partner Internal Table
  i_vbup      TYPE ty_t_vbup,      "SO Item Status Table
  i_vbep      TYPE ty_t_vbep,      "SO Schedule Line Data Table
  i_vbkd      TYPE ty_t_vbkd,      "SO Business data table
  i_kna1      TYPE ty_t_kna1,      "Customer's General Data Table
  i_knvv      TYPE ty_t_knvv,      "Customer Master Sales Data Table
  i_tvv1t     TYPE ty_t_tvv1t,     "Customer group 1: Description Table
  i_tvv2t     TYPE ty_t_tvv2t,     "Customer group 2: Description Table
  i_makt      TYPE ty_t_makt,      "Material Descriptions Table
  i_final_itm TYPE ty_t_final,     "Final Item data table
  i_final_hdr TYPE ty_t_final_hdr, "Final Header table
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
  i_likp      TYPE STANDARD TABLE OF ty_likp         INITIAL SIZE 0, "Internal table for LIKP
  i_lips      TYPE STANDARD TABLE OF ty_lips         INITIAL SIZE 0, "Internal table for LIPS
*--> Begin of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*  i_vbuk      TYPE STANDARD TABLE OF ty_vbuk         INITIAL SIZE 0, "Internal table for VBUK
*<-- End of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
   i_vbup_d3  TYPE STANDARD TABLE OF ty_vbup_d3      INITIAL SIZE 0,
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 13-Dec-2018
"Range table to hold POD status for filiter the records from VBUP
   i_pdsta    TYPE STANDARD TABLE OF fkk_ranges      INITIAL SIZE 0,
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 13-Dec-2018
*--> Begin of delete D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*  i_zdev_emi  TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Enhancement Status
*<-- End of delete D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
  gv_lfart    TYPE lfart,                                            " Delivery Type
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
  gv_wadat    TYPE wadat_ist, " Actual Goods Movement Date
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018

***************************VARIABLE DECLARATION*************************
  gv_vkorg    TYPE vkorg,      "Sales Organization
  gv_vtweg    TYPE vtweg,      "Distribution Channel
  gv_spart    TYPE spart,      "Division
  gv_auart    TYPE vbak-auart, "Sales Doc Type
  gv_vbeln    TYPE vbak-vbeln, "Sales Doc Number
  gv_erdat    TYPE erdat,      "Sales Doc Creation Date
*&-->Begin of change for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
  gv_deldat   TYPE vbep-edatu, "  Requested Delivery Date
*&<--End of change for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
  gv_kunag    TYPE kunnr, "Sold-to-Party
  gv_kunnr    TYPE kunnr, "Ship-to-Party
  gv_matnr    TYPE matnr, "Material

*&--BOC for MOD-002
  gv_kvgr1    TYPE vbak-kvgr1, " Customer group 1
  gv_kvgr2    TYPE vbak-kvgr2, " Customer group 2
*&--EOC for MOD-002

*&-->Begin of change for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
gv_days   TYPE psen_durdd. " Days
*&<--End of change for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
