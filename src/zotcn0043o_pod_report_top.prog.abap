************************************************************************
* PROGRAM    :  ZOTCR0043O_POD_REPORT                                  *
* TITLE      :  OTC_RDD_0043_Comprehensive POD Report                  *
* DEVELOPER  :  Sneha Mukherjee                                        *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0043_Comprehensive POD Report                    *
*----------------------------------------------------------------------*
* DESCRIPTION: This report contains the POD relevant information which *
*              will improve the Business operations and will address to*
*              the issue of not automatically generated PODs.          *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 26-FEB-14  SMUKHER   E1DK912803  INITIAL DEVELOPMENT(Defect#1149)    *
* 25-MAR-14  SMUKHER   E1DK912803  HPQC Defect 1149                    *
* 09-APR-14  SMUKHER   E1DK912803  ADDITIONAL CHANGES ON CR#1149       *
* 13-MAY-14  SMUKHER   E1DK913409  ADDITION OF NEW FIELD 'SALES OFFICE'*
* 17-JUL-14  SMUKHER   E1DK913409  ADDITION OF DATE LIMIT RANGE ON BACK*
*                                  GROUND MODE.                        *
* 06-OCT-14  SMUKHER   E1DK913409  ADDITIONAL CHANGES ON DELIVERY NUMBE*
*                                  -R AND ACTUAL PGI DATE              *
* 29-MAY-17  U034229   E1DK928313  Defect# 2933: 1)Actual PGI date and *
*                                  Sales organization as mandatory     *
*                                  field.                              *
*                                  2) Profit Center, Serial Number     *
*                                  Profile & POD Date are added in the *
*                                  output.                             *
*                                  3) Sales Org, Dist.Channel, Div,    *
*                                  Del.Type are made as range.         *
*                                  4) Performance Tuning.              *
* 13-Jul-17  U034229   E1DK929131  Defect# 3179 1) Cost column should  *
*                                  be replaced with MBEW-STPRS field.  *
*                                  2) Non-POD relevant shipments should*
*                                  check the PGI Status in POD Report. *
*                                  3) Item Category field is added in  *
*                                  the output.                         *
*                                  4) Multiple Handaling Units issue   *
*                                  need to be solved.                  *
*                                  5) Incorporating the standard ALV   *
*                                  output functionality in PF status.  *
* 29-Aug-17  ASK   E1DK930275  Defect# 3399 1) Cost column logic should*
*                                   be reset to old logic from KONV    *
* 10-Jul-18 U103565 E1DK937670  Defect #6638 1) Addition of new fields *
*                                       Higher Level HU,Tracking Number*
*                                       ESS carrier delivery date      *
*                                       Planned Carrier delivery date  *
*                                       Transit time from route        *
*                                       Installable delivery flag      *
*                                       Customer Acceptance date       *
*                                       Error Message                  *
*                                    2) "POD Relevant" is changed to   *
*                                     "Pending POD" on selection screen*
*12-Sep-2018 AMOHAPA E1DK937670 Defect#6638_FUT_Issue:1) Planned       *
*                               carrier date is not showing properly   *
*                               2)Filter is not working on Transit time*
*----------------------------------------------------------------------*
**&& -- Type-Pools

TYPE-POOLS: icon. " for displaying icon.

**&& -- Types Declaration

TYPES: BEGIN OF ty_likp,
       vbeln TYPE vbeln_vl, " Delivery
       erdat TYPE erdat,    " Created on
       vkorg TYPE vkorg,    " Sales Organization
       lfart TYPE lfart,    " Delivery Type
       wadat TYPE wadak,    " Planned goods movement date
       inco1 TYPE inco1,    " Incoterms(Part 1)
       inco2 TYPE inco2,    " Incoterms(Part 2)
       route TYPE route,    " Route
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
       knfak TYPE knfak, " Customer factory calendar
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
       vsbed TYPE vsbed,         " Shipping Conditions
       kunnr TYPE kunwe,         " Ship-to party
       kunag TYPE kunag,         " Sold-to party
       waerk TYPE waerk,         " SD Document Currency
       wadat_ist TYPE wadat_ist, " Actual Goods Movement Date
       podat TYPE podat,         " Date(Proof Of Delivery)
       vbeln_xblnr TYPE xblnr1,  " Reference Document Number
       END OF ty_likp,

       BEGIN OF ty_kna1,
       kunnr TYPE kunnr,         " Customer Number
       name1 TYPE name1_gp,      " Name 1
       END OF ty_kna1,

       BEGIN OF ty_tvsbt,
       spras TYPE	spras,         " Language Key
       vsbed TYPE	vsbed,         " Shipping Conditions
       vtext TYPE vsbed_bez,     " Description of the shipping conditions
       END OF ty_tvsbt,

       BEGIN OF ty_tvrot,
       spras TYPE	spras,         " Language Key
       route TYPE route,         "  Route
       bezei TYPE routbez,       "  Description of Route
       END OF ty_tvrot,

       BEGIN OF ty_bkpf,
       bukrs TYPE bukrs,         " Company Code
       belnr TYPE	belnr_d,       " Accounting Document Number
       gjahr TYPE	gjahr,         " Fiscal Year
       xblnr TYPE xblnr1,        " Reference Document Number
       tcode TYPE tcode,         " Transaction Code
       END OF ty_bkpf,

       BEGIN OF ty_bseg,
       bukrs TYPE bukrs,         " Company Code
       belnr TYPE belnr_d,       " Accounting Document Number
       gjahr TYPE gjahr,         " fiscal year
       buzei TYPE buzei,         " Number of line item within accounting document
       buzid TYPE buzid,         " Identification of the Line Item
       bschl TYPE	bschl,         " Posting Key
       hkont TYPE hkont,         " General Ledger Account
       END OF ty_bseg,

       BEGIN OF ty_lips,
       vbeln TYPE	vbeln_vl,      " Delivery
       posnr TYPE	posnr_vl,      " Delivery Item
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
       pstyv TYPE pstyv_vl, " Delivery item category
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
       matnr TYPE matnr,   " Material Number
       werks TYPE werks_d, " Plant
       charg TYPE charg_d, " Batch
       lfimg TYPE lfimg,   " Actual quantity delivered (in sales units)
       vrkme TYPE vrkme,   " Sales unit
       vgbel TYPE vgbel,   " Document number of the reference document
       vgpos TYPE vgpos,   " Item number of the reference item
**&& -- BOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
       vkbur TYPE vkbur, " Sales Office
**&& -- EOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
       vtweg TYPE vtweg, " Distribution Channel
       spart TYPE spart, " Division
       mvgr1 TYPE mvgr1, " Material group 1
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
       prctr TYPE prctr, " Profit Center
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
       kcmeng TYPE kcmeng, " Cumulative batch quantity of all split items (in StckUnit)
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
         serail TYPE serail, " Serial Number Profile
         bom_head TYPE flag, "BOM Header flag check
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018

       END OF ty_lips,

       BEGIN OF ty_vbak,
       vbeln TYPE vbeln_va, " Sales Document
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
       ernam TYPE ernam, " Name of Person who Created the Object
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
       auart TYPE auart,    " Sales Document Type
       vkorg TYPE vkorg,    " Sales Organization
       vtweg TYPE vtweg,    " Distribution Channel
       spart TYPE spart,    " Division
       knumv TYPE knumv,    " Number of the document condition
       bstnk TYPE bstnk,    " Customer purchase order number
       END OF ty_vbak,

       BEGIN OF ty_vbkd,
       vbeln TYPE vbeln,    " Sales and Distribution Document Number
       posnr TYPE posnr,    " Item number of the SD document
       bstkd TYPE bstkd,    " Customer purchase order number
       END OF ty_vbkd,

       BEGIN OF ty_vbup,
       vbeln TYPE	vbeln,    " Sales and Distribution Document Number
       posnr TYPE posnr,    " Item number of the SD document
       pdsta TYPE pdsta,    " POD status on item level
       END OF ty_vbup,

       BEGIN OF ty_tvm1t,
       spras TYPE spras,    " Language Key
       mvgr1 TYPE	mvgr1,    " Material group 1
       bezei TYPE bezei40,  "  Description
       END OF ty_tvm1t,

       BEGIN OF ty_vbap,
       vbeln TYPE	vbeln_va, "	Sales Document
       posnr TYPE	posnr_va, "	Sales Document Item
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
       charg TYPE charg_d, " Batch Number
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
       uepos TYPE uepos, " Higher-level item in bill of material structures
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
       netwr TYPE netwr_ap, " Net value of the order item in document currency
**&& -- BOC : HPQC Defect 1149 : SMUKHER : 25-MAR-14
       kwmeng TYPE kwmeng, " Cumulative Order Quantity in Sales Units
**&& -- EOC : HPQC Defect 1149 : SMUKHER : 25-MAR-14
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
       mvgr1      TYPE mvgr1, "Material Group 1.
       inst_check TYPE flag,  " General Flag
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
       END OF ty_vbap,
*---> Begin of Change for D3_OTC_RDD_0043_Defect# 3399
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
       BEGIN OF ty_konv,
       knumv TYPE  knumv,  " Number of the document condition
       kposn TYPE kposn,   " Condition item number
       stunr TYPE  stunr,  " Step number
       zaehk TYPE dzaehk,  "  Condition counter
       kschl TYPE kscha,   " Condition type
       kwert_k TYPE kwert, " Condition value
       END OF ty_konv,
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*<--- End of Change for D3_OTC_RDD_0043_Defect# 3399

       BEGIN OF ty_vepo,
       venum TYPE	venum,        " Internal Handling Unit Number
       vepos TYPE vepos,        " Handling Unit Item
       vbeln TYPE	vbeln_vl,     " Delivery
       posnr TYPE	posnr_vl,     " Delivery Item
       END OF ty_vepo,

       BEGIN OF ty_vekp,
       venum        TYPE venum, " Internal Handling Unit Number
       exidv        TYPE exidv, " External Handling Unit Identification
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018
       uevel        TYPE uevel, "Higher-Level Handling Unit
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018
       spe_idart_01	TYPE /spe/de_huidart, " Handling Unit Identification Type
       spe_ident_01 TYPE /spe/de_ident,   " Alternative HU Identification
       spe_idart_02	TYPE /spe/de_huidart, " Handling Unit Identification Type
       spe_ident_02 TYPE /spe/de_ident,   "	Alternative HU Identification
       spe_idart_03	TYPE /spe/de_huidart, " Handling Unit Identification Type
       spe_ident_03 TYPE /spe/de_ident,   "  Alternative HU Identification
       spe_idart_04 TYPE /spe/de_huidart, " Handling Unit Identification Type
       spe_ident_04 TYPE /spe/de_ident,   " Alternative HU Identification
       END OF ty_vekp,
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
       BEGIN OF ty_makt,
       matnr TYPE	matnr, " Material Number
       spras TYPE	spras, " Language Key
       maktx TYPE	maktx, " Material Description (Short Text)
       END OF ty_makt,
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 02-Jun-2017
       BEGIN OF ty_marc,
       matnr TYPE	 matnr,   " material Number
       werks TYPE  werks_d, " Plant
       sernp TYPE	 serail,  " Serial Number Profile
       END OF ty_marc,

       BEGIN OF ty_zlex_pod,
       hunum  TYPE exidv,   "External Handling Unit Identification
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
       tracking_number TYPE	/spe/de_ident,
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
       pod_date	TYPE datum, " Date
       END OF ty_zlex_pod,
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 02-Jun-2017
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
       BEGIN OF ty_pod_his,
       hunum           TYPE exidv, "External Handling Unit Identification
       tracking_number TYPE	/spe/de_ident,
       pod_date        TYPE datum, " Date
       END OF ty_pod_his,
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
**&& Material Valuation- MBEW table type declaration
       BEGIN OF ty_mbew,
       matnr TYPE	matnr,   " Material Number
       bwkey TYPE	bwkey,   " Valuation Area
       bwtar TYPE	bwtar_d, " Valuation Type
       stprs TYPE	stprs,   " Standard price
       END OF ty_mbew,

**&& Sales Document: Header Status and Administrative Data- VBUK table type declaration
       BEGIN OF ty_vbuk,
       vbeln TYPE vbeln, " Sales and Distribution Document Number
       wbstk TYPE wbstk, " Total goods movement status
       pdstk TYPE pdstk, " POD status on header level
       END OF ty_vbuk,
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017

      BEGIN OF ty_final,
      vkorg TYPE vkorg,   " Sales Organization
      vtweg TYPE vtweg,   " Distribution Channel
      spart TYPE spart,   " Division
      werks TYPE werks_d, " Plant
**&& -- BOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
      vkbur TYPE vkbur, " Sales Office
**&& -- EOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
      vbeln TYPE vbeln_vl, " Delivery Number
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
      pstyv TYPE pstyv_vl, " Delivery item category
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
      lfart TYPE lfart,          " Delivery Type
      erdat TYPE erdat,          " Delivery Date
      wadat TYPE wadak,          " Planned PGI Date
      wadat_ist TYPE wadat_ist,  " Actual PGI Date
      podat TYPE podat,          " Actual POD Date
      kunag TYPE kunag,          " Sold-to party
      name1_kunag TYPE name1_gp, " Sold-to-name
      kunnr TYPE kunwe,          " Ship-to-party
      name1_kunnr TYPE name1_gp, " Ship-to-name
      inco1 TYPE inco1,          " Incoterm (Part 1)
      inco2 TYPE inco2,          " Incoterm (Part 2)
      vsbed TYPE vsbed,          " Shipping Conditions
      vtext TYPE vsbed_bez,      " Description of the shipping conditions
      route TYPE route,          " Route
      bezei_r TYPE routbez,      " Description of Route
      vgbel TYPE vbeln_va,       " Document number of the reference document
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
      prctr    TYPE prctr,  " Profit Center
      sernp	   TYPE serail, " Serial Number Profile
      pod_date TYPE	datum,  " Date
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
      ernam TYPE ernam, " Sales Order Created By
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
      posnr TYPE posnr_vl, " Delivery Item
      auart TYPE auart,    " Sales Document Type
      bstnk TYPE bstnk,    " Customer purchase order number
      vgpos TYPE vgpos,    " Item number of the reference item
      pdsta TYPE char4,    " POD status on item level
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
      pdsta_value TYPE char4, " POD Status on an item level
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
      matnr TYPE matnr, " Material Number
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
      maktx TYPE maktx, " Material Description
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
      lfimg TYPE lfimg,    " Actual quantity delivered (in sales units)
      vrkme TYPE vrkme,    " Sales unit
      charg TYPE charg_d,  " Batch Number
      bezei TYPE bezei40,  " Description
      netwr TYPE netwr_ap, " Net value of the order item in document currency
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
      stprs TYPE stprs, " Sales document item category
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
      kwert_k TYPE kwert, " Condition value   " Defect 3399
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
      waerk TYPE waerk,                  " SD Document Currency
      exidv TYPE exidv,                  " External Handling Unit Identification
      spe_idart_01 TYPE /spe/de_huidart, " Handling Unit Identification Type
      spe_ident_01 TYPE  /spe/de_ident,  " Alternative HU Identification
      spe_idart_02 TYPE /spe/de_huidart, " Handling Unit Identification Type
      spe_ident_02 TYPE  /spe/de_ident,  " Alternative HU Identification
      spe_idart_03 TYPE /spe/de_huidart, " Handling Unit Identification Type
      spe_ident_03 TYPE /spe/de_ident,   " Alternative HU Identification
      spe_idart_04 TYPE /spe/de_huidart, " Handling Unit Identification Type
      spe_ident_04 TYPE /spe/de_ident,   " Alternative HU Identification
      hkont TYPE hkont,                  " General Ledger Account
* *---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
      higher_hu     TYPE exidv,         "Higher level HU
      inst_delivery TYPE flag,          "Flag for Installable deliveries
*---> Begin of delete for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
*      traztd        TYPE traztd,        "  Transit time
*<--- End of delete for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
*---> Begin of insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
"As filter is not working in the output
"so making it into character field
       traztd       TYPE char10,
*<--- End of insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
      trac_no       TYPE /spe/de_ident, "Tracking no.
      status        TYPE z_msg1,        "message
      pcdate        TYPE datum,         "Planned carrier delivery date
      start_date    TYPE datum,         "Customer acceptance date
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018

      END OF ty_final,
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
      BEGIN OF ty_tvro,
      route  TYPE route,           " Route
      traztd TYPE traztd,          " Transit duration in calendar days
      END OF ty_tvro,
      BEGIN OF ty_error,
      vbeln  TYPE  vbeln,          " sales and distribution number
      status TYPE	z_msg1,          " message variable
      END OF ty_error,
      BEGIN OF ty_vbpa,
      vbeln TYPE vbeln,            " Sales and Distribution Document Number
      parvw TYPE  parvw,           " Partner Function
      land1 TYPE land1,            " Country Key
      END OF ty_vbpa,
      BEGIN OF ty_ser01,
      obknr    TYPE objknr,        "Object list number
      lief_nr  TYPE vbeln_vl,      "Delivery
      posnr    TYPE posnr_vl,      " Delivery Item
      END OF   ty_ser01,
      BEGIN OF ty_objk,
      obknr  TYPE objknr,          "Object list number
      obzae  TYPE objza,           "Object list counters
      equnr  TYPE equnr,           "Equipment Number
      sernr  TYPE gernr,           "Serial Number
      matnr  TYPE matnr,           " Material Number
      END OF ty_objk,

      BEGIN OF ty_equi,
      equnr  TYPE equnr,           "Equipment Number
      inbdt  TYPE ilom_datab,      "Start-up Date of the Technical Object
      END OF ty_equi,
      BEGIN OF ty_inst,
      vbeln         TYPE vbeln_vl, " Sales and Distribution Document Number
      inst_delivery TYPE flag,     " General Flag
      END OF ty_inst,
     BEGIN OF ty_serial_num,
       vbeln TYPE vbeln_va,        " Sales Document
       posnr TYPE posnr_va,        " Sales Document Item
       obknr TYPE objknr,          "Object list number
       equnr TYPE equnr,           "Equipment Number
       sernr TYPE gernr,           "Serial Number
       inbdt TYPE ilom_datab,      "Start-up Date of the Technical Object
     END OF ty_serial_num,
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018



*******TABLE TYPE DECLARATION.
ty_t_likp TYPE STANDARD TABLE OF ty_likp,   "table type declaration for LIKP
ty_t_kna1 TYPE STANDARD TABLE OF ty_kna1,   "table type declaration for KNA1
ty_t_tvsbt TYPE STANDARD TABLE OF ty_tvsbt, "table type declaration for TVSBT
ty_t_tvrot TYPE STANDARD TABLE OF ty_tvrot, "table type declaration for TVROT
ty_t_bkpf TYPE STANDARD TABLE OF ty_bkpf,   "table type declaration for BKPF
ty_t_bseg TYPE STANDARD TABLE OF ty_bseg,   "table type declaration for BSEG
ty_t_lips TYPE STANDARD TABLE OF ty_lips,   "table type declaration for LIPS
ty_t_vbak TYPE STANDARD TABLE OF ty_vbak,   "table type declaration for VBAK
ty_t_vbkd TYPE STANDARD TABLE OF ty_vbkd,   "table type declaration for VBKD
ty_t_vbup TYPE STANDARD TABLE OF ty_vbup,   "table type declaration for VBUP
ty_t_tvm1t TYPE STANDARD TABLE OF ty_tvm1t, "table type declaration for TVM1
ty_t_vbap TYPE STANDARD TABLE OF ty_vbap,   "table type declaration for VBAP
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
ty_t_konv TYPE STANDARD TABLE OF ty_konv, "table type declaration for KONV  " Defect # 3399
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
ty_t_vepo TYPE STANDARD TABLE OF ty_vepo, "table type declaration for VEPO
ty_t_vekp TYPE STANDARD TABLE OF ty_vekp, "table type declaration for VEKP
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
ty_t_makt TYPE STANDARD TABLE OF ty_makt,              "table type declaration for MAKT
ty_r_wadat_ist TYPE RANGE OF wadat_ist INITIAL SIZE 0, "Range table for Actual PGI Date
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
*---> Begin of Insert For D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
ty_t_marc     TYPE STANDARD TABLE OF ty_marc,     " Table type declaration for MARC
ty_t_zlex_pod TYPE STANDARD TABLE OF ty_zlex_pod, " Table type declaration for ZLEX_POD
*<--- End of Insert For D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*---> Begin of Insert For D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
ty_t_mbew     TYPE STANDARD TABLE OF ty_mbew, " Table type declaration for MBEW
ty_t_vbuk     TYPE STANDARD TABLE OF ty_vbuk, " Table type declaration for VBUK
*<--- End of Insert For D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017

ty_t_final TYPE STANDARD TABLE OF ty_final, "table type declaration for FINAL
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
ty_t_tvro       TYPE STANDARD TABLE OF ty_tvro,
ty_t_error      TYPE STANDARD TABLE OF ty_error,
ty_t_vbpa       TYPE STANDARD TABLE OF ty_vbpa,
ty_t_ser01      TYPE STANDARD TABLE OF ty_ser01,   "table type for Serial Numbers for Delivery
ty_t_objk       TYPE STANDARD TABLE OF ty_objk,    "table type for Object list
ty_t_equi       TYPE STANDARD TABLE OF ty_equi,    "table type for Equipment header
ty_t_inst       TYPE STANDARD TABLE OF ty_inst,
ty_t_serial_num TYPE STANDARD TABLE OF ty_serial_num,
ty_t_pod_his    TYPE STANDARD TABLE OF ty_pod_his,
ty_t_fkk        TYPE STANDARD TABLE OF fkk_ranges. " Structure: Select Options
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018

*---> Begin of Insert For D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
******Constant Declaration.
CONSTANTS c_wbstk TYPE wbstk VALUE 'C'. "Constant Declaration of Total goods Movement status
*<--- End of Insert For D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017

*******INTERNAL TABLE DECLARATION.
DATA : i_likp TYPE STANDARD TABLE OF ty_likp INITIAL SIZE 0,   "internal table for LIKP
       i_kna1 TYPE STANDARD TABLE OF ty_kna1 INITIAL SIZE 0,   "internal table for KNA1
       i_tvsbt TYPE STANDARD TABLE OF ty_tvsbt INITIAL SIZE 0, "internal table for TSVBT
       i_tvrot TYPE STANDARD TABLE OF ty_tvrot INITIAL SIZE 0, "internal table for TVROT
       i_bkpf TYPE STANDARD TABLE OF ty_bkpf INITIAL SIZE 0,   "internal table for BKPF
       i_bseg TYPE STANDARD TABLE OF ty_bseg INITIAL SIZE 0,   "internal table for BSEG
       i_lips TYPE STANDARD TABLE OF ty_lips INITIAL SIZE 0,   "internal table for LIPS
       i_vbak TYPE STANDARD TABLE OF ty_vbak INITIAL SIZE 0,   "internal table for VBAK
       i_vbkd TYPE STANDARD TABLE OF ty_vbkd INITIAL SIZE 0,   "internal table for VBKD
       i_vbup TYPE STANDARD TABLE OF ty_vbup INITIAL SIZE 0,   "internal table for VBUP
       i_tvm1t TYPE STANDARD TABLE OF ty_tvm1t INITIAL SIZE 0, "internal table for TVM1
       i_vbap TYPE STANDARD TABLE OF ty_vbap INITIAL SIZE 0,   "internal table for VBAP
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
       i_konv TYPE STANDARD TABLE OF ty_konv INITIAL SIZE 0, "internal table for KONV  " Defect 3399
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
       i_vekp TYPE STANDARD TABLE OF ty_vekp INITIAL SIZE 0, "internal table for VBUK
       i_vepo TYPE STANDARD TABLE OF ty_vepo INITIAL SIZE 0, "internal table for VEPO
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
       i_makt TYPE STANDARD TABLE OF ty_makt INITIAL SIZE 0, "internal table fpr MAKT
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
       i_final TYPE STANDARD TABLE OF ty_final INITIAL SIZE 0,  "internal table for FINAL
       i_listheader TYPE slis_t_listheader,                     "List header internal tab

       i_hu_vbeln TYPE STANDARD TABLE OF selopt INITIAL SIZE 0, " internal table
       i_po_vbeln TYPE STANDARD TABLE OF selopt INITIAL SIZE 0, " internal table
       i_so_vbeln TYPE STANDARD TABLE OF selopt INITIAL SIZE 0, " internal table

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
       i_marc     TYPE STANDARD TABLE OF ty_marc     INITIAL SIZE 0, " Internal table for MARC
       i_zlex_pod TYPE STANDARD TABLE OF ty_zlex_pod INITIAL SIZE 0, " Internal table for ZLEX_POD
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
      i_mbew TYPE STANDARD TABLE OF ty_mbew INITIAL SIZE 0, " Internal table for MBEW
      i_vbuk TYPE STANDARD TABLE OF ty_vbuk INITIAL SIZE 0, " Internal table for VBUK
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017

**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
       i_hu_date TYPE ty_r_wadat_ist, " internal table
       i_po_date TYPE ty_r_wadat_ist, " internal table
       i_so_date TYPE ty_r_wadat_ist, " internal table
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
**&& -- BOC : ADDITIONAL CHANGES ON DELIVERY NUMBER AND ACTUAL PGI DATE : SMUKHER : 06-OCT-14
       i_pgi_date TYPE ty_r_wadat_ist, " internal table
**&& -- EOC : ADDITIONAL CHANGES ON DELIVERY NUMBER AND ACTUAL PGI DATE : SMUKHER : 06-OCT-14
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
       i_tvro TYPE ty_t_tvro,             " internal table
       i_pod_history TYPE ty_t_pod_his,   "internal table
       i_ser01        TYPE  ty_t_ser01  , "Internal table for Serial Numbers for Delivery
       i_objk         TYPE  ty_t_objk   , "Internal table for Object list
       i_equi         TYPE  ty_t_equi   , "Internal table for Equipment header
       i_inst TYPE STANDARD TABLE OF ty_inst,
       i_serial_num   TYPE  ty_t_serial_num,
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
**&& -- Global Variable Declaration
      gv_wadat_ist TYPE likp-wadat_ist, " global variable
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017.
      gv_vkorg     TYPE vkorg, "likp-vkorg, " global variable
      gv_vtweg     TYPE vtweg, "lips-vtweg, " global variable
      gv_spart     TYPE spart, "lips-spart, " global variable
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017.
      gv_werks     TYPE lips-werks, " global variable
      gv_vbeln     TYPE likp-vbeln, " global variable
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 08-Jun-2017
      gv_lfart     TYPE likp-lfart, " Delivery Type
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 08-Jun-2017
      gv_route     TYPE likp-route,   " global variable
      gv_vsbed     TYPE likp-vsbed,   " global variable
      gv_kunnr     TYPE likp-kunnr,   " global variable
      gv_kunag     TYPE likp-kunag,   " global variable
      gv_venum     TYPE vekp-exidv,   " global variable
      gv_vbelnp    TYPE vbkd-bstkd,   " global variable
      gv_vbelns    TYPE vbak-vbeln,   " global variable
      gv_value_forgrnd     TYPE num2, " global variable
**&& -- BOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
      gv_value_backgr TYPE num2, " global variable
**&& -- EOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
      gv_days      TYPE num4,  " global variable
      gv_kschl     TYPE kschl, " global variable
      gv_bschl     TYPE bschl, " global variable
      gv_flag      TYPE char1, " flag
**&& -- BOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
      gv_vkbur     TYPE lips-vkbur, " global variable
**&& -- EOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
*******ALV DATA DECLARATION
      i_fieldcat   TYPE  slis_t_fieldcat_alv, "Fieldcatalog Internal tab
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
       gv_day      TYPE num2 ,                                       " 2-Digit Numeric Value
       i_hu_header TYPE hum_hu_header_t,
       i_mat_group TYPE STANDARD TABLE OF fkk_ranges INITIAL SIZE 0, " Structure: Select Options
       i_bom_hd    TYPE STANDARD TABLE OF fkk_ranges INITIAL SIZE 0, " Structure: Select Options
       i_error     TYPE STANDARD TABLE OF ty_error   INITIAL SIZE 0,
       i_vbpa      TYPE STANDARD TABLE OF ty_vbpa    INITIAL SIZE 0.
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018

********Constants Declaration
CONSTANTS: gc_save TYPE char1 VALUE 'A', " I_SAVE
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
           gc_e TYPE char1 VALUE 'E'. " message type 'E'
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
