*&---------------------------------------------------------------------*
*&  Include           ZOTCN0116O_REVENUE_REPORT_TOP
*&---------------------------------------------------------------------*
************************************************************************
* Include       ZOTCN0116O_REVENUE_REPORT_TOP                          *
* TITLE      :  End to End Revenue Report                              *
* DEVELOPER  :  RAGHAV SUREDDI                                         *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0116_REVENUE_REPORT                              *
*----------------------------------------------------------------------*
* DESCRIPTION: This Report can be utilized by users to track Revenue   *
*               Documents created on a specific date or within a date  *
*               range. The report will provide all key information     *
*               about the Revenue.                                     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 30-Nov-2017 U033876   E1DK934630 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 11-Apr-2018 MGARG/    E1DK934630 Defect#4360                         *
*             U024694              Fix performance Issue, Add Search   *
*                                  help and change the description of  *
*                                  column headings                     *
*&---------------------------------------------------------------------*
* 10-May-2018 U100018   E1DK934630 Defect# 6027: Fix performance issue *
* 31-Oct-2018 U033876   E1DK939333 SCTASK0745122 Changes for POd project*
* 14-Jan-2019 U033876   E1DK939333 Sctask: SCTASK0745122 Intercompany  *
*                       Billing Accrual fields                         *
*&---------------------------------------------------------------------*
* 12-Apr-2019 PDEBARU   E1DK941048 Defect# 9070 : 1. VF01 authorization*
*                                  for all users allowed               *
*                                  2. Display of Payer Block & Sold to *
*                                  party block even if customer is     *
*                                  marked for deletion                 *
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_likp,
         vbeln      TYPE   vbeln_vl, " Delivery
         vstel      TYPE   vstel,    " Shipping Point/Receiving Point
         vkorg      TYPE   vkorg,    " Sales Organization
         lfart      TYPE   lfart,    " Delivery Type
         route      TYPE   route,    " Route
         kunnr      TYPE   kunwe,    " Ship-to party
         kunag      TYPE   kunag,    " Sold-to party
* Begin of Change for SCTASK0745122 by u033876
         vkoiv      TYPE   vkoiv, " Sales organization for intercompany billing
         vtwiv      TYPE   vtwiv, " Distribution channel for intercompany billing
         kuniv      TYPE   kuniv, " Customer number for intercompany billing
* End of change for SCTASK0745122 by U033876
         wadat_ist  TYPE   wadat_ist, " Actual Goods Movement Date
         podat      TYPE   podat,     " Date (proof of delivery)
         tu_num TYPE char18,          " Num of type CHAR18  "change for SCTASK0745122 by U033876
       END OF ty_likp,

       ty_likp_t    TYPE STANDARD TABLE OF ty_likp,

       BEGIN OF ty_lips,
         vbeln      TYPE  vbeln_vl,   " Delivery
***         vstel      TYPE  vstel,      " Shipping Point/Receiving Point
***         vkorg      TYPE  vkorg,      " Sales Organization
***         lfart      TYPE  lfart,      " Delivery Type
***         route      TYPE  route,      " Route
***         kunnr      TYPE  kunwe,      " Ship-to party
***         kunag      TYPE  kunag,      " Sold-to party
***         wadat_ist  TYPE  wadat_ist,  " Actual Goods Movement Date
***         podat      TYPE  podat,      " Date (proof of delivery)
         posnr      TYPE  posnr_vl, " Delivery Item
         pstyv      TYPE  pstyv_vl, " Delivery item category
         erdat      TYPE  erdat,    " Date on Which Record Was Created
         matnr      TYPE  matnr,    " Material Number
         werks      TYPE  werks_d,  " Plant
         lgort      TYPE  lgort_d,  " Storage Location
         lfimg      TYPE  lfimg,    " Actual quantity delivered (in sales units)
         meins      TYPE  meins,    " Base Unit of Measure
         arktx      TYPE  arktx,    " Short text for sales order item
         vgbel      TYPE  vgbel,    " Document number of the reference document
         vgpos      TYPE  vgpos,    " Item number of the reference item
         uepos      TYPE  uepos,    " Higher-level item in bill of material structures
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
** This change was done at onsite.We just put the tag at offshore
         uecha      TYPE  uecha, " Higher-Level Item of Batch Split Item
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
         vkbur      TYPE  vkbur, " Sales Office
         vtweg      TYPE  vtweg, " Distribution Channel
*--> Begin of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
         spart      TYPE  spart, " Division
*<-- End of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
         mvgr1      TYPE  mvgr1, " Material group 1
         mvgr4      TYPE  mvgr4, " Material group 4
         prctr      TYPE  prctr, " Profit Center
         kzpod      TYPE  kzpod, " POD indicator (relevance, verification, confirmation)
       END OF ty_lips,

       ty_lips_t    TYPE STANDARD TABLE OF ty_lips,

       BEGIN OF ty_vbup,
       vbeln TYPE	vbeln,         " Sales and Distribution Document Number
       posnr TYPE posnr,         " Item number of the SD document
       fkivp TYPE fkivp,         " SCtask: SCTASK0745122 Intercompany Billing Status
       pdsta TYPE pdsta,         " POD status on item level
       END OF ty_vbup,

       ty_vbup_t TYPE STANDARD TABLE OF ty_vbup,

* HU details
         BEGIN OF ty_vekp,
           venum TYPE venum,                  "Intrenal HU Number
           exidv TYPE exidv,                  "External HU Number
           vpobj TYPE vpobj,                  " Packing Object
           vpobjkey TYPE vpobjkey,            "Reference Object
           spe_idart_01 TYPE /spe/de_huidart, "Handling Unit Identification Type
           spe_ident_01 TYPE /spe/de_ident,   "Alternative HU Identification
           spe_idart_02 TYPE /spe/de_huidart, "Handling Unit Identification Type
           spe_ident_02 TYPE /spe/de_ident,   "Alternative HU Identification
           spe_idart_03 TYPE /spe/de_huidart, "Handling Unit Identification Type
           spe_ident_03 TYPE /spe/de_ident,   "Alternative HU Identification
           flag  TYPE char1,                  "Flag
         END OF ty_vekp,

       ty_vekp_t TYPE STANDARD TABLE OF ty_vekp,


       BEGIN OF ty_vbak,
         vbeln      TYPE  vbeln_va,           " Sales Document
         erdat      TYPE  erdat,              " Date on Which Record Was Created
         ernam      TYPE  ernam,              " Name of Person who Created the Object
         auart      TYPE  auart,              " Sales Document Type
         faksk      TYPE  faksk,              " Billing block in SD document
* Begin of Change for SCTASK0745122 by U033876
         waerk      TYPE  waerk, " SD Document Currency
* End of change for SCTASK0745122 by U033876
         knumv      TYPE  knumv,    " Number of the document condition
       END OF  ty_vbak,

       ty_vbak_t    TYPE STANDARD TABLE OF ty_vbak,

       BEGIN OF ty_konv,
       knumv TYPE  knumv,           " Number of the document condition
       kposn TYPE kposn,            " Condition item number
       stunr TYPE  stunr,           " Step number
       zaehk TYPE dzaehk,           "  Condition counter
       kschl TYPE kscha,            " Condition type
       kwert_k TYPE kwert,          " Condition value
       END OF  ty_konv,

       ty_konv_t    TYPE STANDARD TABLE OF ty_konv,

       BEGIN OF ty_vbap,
         vbeln      TYPE  vbeln_va, " Sales and Distribution Document Number
         posnr      TYPE  posnr,    " Item number of the SD document
         faksp      TYPE  faksp_ap, " Billing block in SD document
         netwr      TYPE  netwr_ap, " Net value of the order item in document currency
         waerk      TYPE  waerk,    " SD Document Currency
         kwmeng     TYPE  kwmeng,   " Cumulative Order Quantity in Sales Units
         ktgrm      TYPE  ktgrm,    " Account assignment group for this material
       END OF  ty_vbap,

       ty_vbap_t    TYPE STANDARD TABLE OF ty_vbap,

       BEGIN OF ty_tvkot,           " Sales and Distribution Document Number
         spras      TYPE  spras,    " Language Key
         vkorg      TYPE  vkorg,    " Sales Organization
         vtext      TYPE  vtext,    " Description
       END OF ty_tvkot,

        ty_tvkot_t   TYPE STANDARD TABLE OF ty_tvkot,

       BEGIN OF ty_tvm1t,           " Sales and Distribution Document Number
         spras      TYPE  spras,    " Language Key
         mvgr1      TYPE  mvgr1,    " Sales Organization
         bezei      TYPE  bezei40,  " Description
       END OF ty_tvm1t,

        ty_tvm1t_t   TYPE STANDARD TABLE OF ty_tvm1t,


       BEGIN OF ty_tvrot,
       spras TYPE	spras,            " Language Key
       route TYPE route,            "  Route
       bezei TYPE routbez,          "  Description of Route
       END OF ty_tvrot,

        ty_tvrot_t TYPE STANDARD TABLE OF ty_tvrot,

       BEGIN OF ty_tvkmt,           " Sales and Distribution Document Number
         spras      TYPE  spras,    " Language Key
         ktgrm      TYPE  ktgrm,    " Sales Organization
         vtext      TYPE  bezei20,  " Description
       END OF ty_tvkmt,

        ty_tvkmt_t   TYPE STANDARD TABLE OF ty_tvkmt,

       BEGIN OF ty_kna1,
         kunnr      TYPE  kunnr,    " Sales and Distribution Document Number
         name1      TYPE  name1_gp, " Name 1
         aufsd      TYPE  aufsd_x,  " Item number of the SD document
         faksd      TYPE  faksd_x,  " Billing block in SD document
         lifsd      TYPE  lifsd_x,  " Central delivery block for the customer
       END OF  ty_kna1,

       ty_kna1_t    TYPE STANDARD TABLE OF ty_kna1,
*--> Begin of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU

        BEGIN OF ty_knvv,
           kunnr      TYPE  kunnr,  " Customer Number
           vkorg      TYPE  vkorg,  " Sales Organization
           vtweg      TYPE  vtweg,  " Distribution Channel
           spart      TYPE  spart,  " Division
           faksd      TYPE  faksd_v, " Billing block for customer (sales and distribution)
         END OF  ty_knvv,

         ty_knvv_t    TYPE STANDARD TABLE OF ty_knvv,

*<-- End of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU

       BEGIN OF ty_vbfa,
         vbelv      TYPE  vbeln_von,  " Preceding sales and distribution document
         posnv      TYPE  posnr_von,  " Preceding item of an SD document
         vbeln      TYPE  vbeln_nach, " Subsequent sales and distribution document
         posnn      TYPE  posnr_nach, " Subsequent item of an SD document
         vbtyp_n    TYPE  vbtyp_n,    " Document category of subsequent document
         rfmng      TYPE  rfmng,      " Referenced quantity in base unit of measure
         meins      TYPE  meins,      " Base Unit of Measure
*         vbtyp_v    TYPE  vbtyp_v,     " Document category of preceding SD document
         plmin      TYPE  plmin,    " Quantity is calculated positively, negatively or not at all
         erdat      TYPE  erdat,    " Date on Which Record Was Created
         erzet      TYPE  erzet,    " Entry time
       END OF ty_vbfa,

       ty_vbfa_t    TYPE STANDARD TABLE OF ty_vbfa,

       BEGIN OF ty_vbrk,
         vbeln      TYPE  vbeln_vf, " Billing Document
         fkart      TYPE  fkart,    " Billing Type
         waerk      TYPE  waerk,    " SD Document Currency
         fkdat      TYPE  fkdat,    " Billing date for billing index and printout
         rfbsk      TYPE  rfbsk,    " Status for transfer to accounting
         netwr      TYPE  netwr,    " Net Value in Document Currency
         fksto      TYPE  fksto,    " Billing document is cancelled
       END OF ty_vbrk,

       ty_vbrk_t    TYPE  STANDARD TABLE OF ty_vbrk,

       BEGIN OF ty_vbrp,
         vbeln      TYPE  vbeln_vf, " Billing Document
         posnr      TYPE  posnr_vf, " Billing item
         netwr      TYPE  netwr_fp, " Net Value in Document Currency
* Begin of Change for SCTASK0745122 by U033876
         vgbel      TYPE  vgbel, " Document number of the reference document
         vgpos      TYPE  vgpos, " Item number of the reference item
* End of Change for SCTASK0745122 by U033876
       END OF ty_vbrp,

       ty_vbrp_t    TYPE  STANDARD TABLE OF ty_vbrp,

       BEGIN OF ty_vbreve,
         vbeln      TYPE  vbeln_va,    " Sales Document
         posnr      TYPE  posnr_va,    " Sales Document Item
         sakrv      TYPE  saknr,       " G/L Account Number
         bdjpoper   TYPE  rr_bdjpoper, " Posting year and posting period (YYYYMMM format)
         popupo     TYPE  rr_popupo,   " Period sub-item
         vbeln_n    TYPE  vbeln_nach,  " Subsequent sales and distribution document
         posnr_n    TYPE  posnr_nach,  " Subsequent item of an SD document
         wrbtr      TYPE  wrbtr,       " Amount in Document Currency
         waerk      TYPE  waers,       " Currency Key
         sammg      TYPE  sammg,       " Group
         reffld     TYPE  rr_reffld,   " FI document reference number
         rrsta      TYPE  rr_status,   " Revenue determination status
         budat      TYPE  budat,       " Posting Date in the Document
         revevdat   TYPE  rr_revevdat, " Revenue Event Date
       END OF ty_vbreve,

       ty_vbreve_t  TYPE  STANDARD TABLE OF  ty_vbreve,

       BEGIN OF ty_bkpf,
         bukrs      TYPE  bukrs,       " Company Code
         belnr      TYPE  belnr_d,     " Accounting Document Number
         gjahr      TYPE  gjahr,       " Fiscal Year
         awtyp      TYPE  awtyp,       " Reference Transaction
         awkey      TYPE  awkey,       " Reference Key
       END OF ty_bkpf,

       ty_bkpf_t    TYPE  STANDARD TABLE OF ty_bkpf,
*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
       BEGIN OF ty_payr,
         vbeln TYPE vbeln,   " Sales and Distribution Document Number
         parvw TYPE parvw,   " Partner Function
         kunnr TYPE kunnr,   " Customer Number
       END OF ty_payr,

       ty_payr_t TYPE STANDARD TABLE OF ty_payr,

       BEGIN OF ty_paybl,
         kunnr TYPE kunnr,   " Customer Number
         faksd TYPE faksd_x, " Central billing block for customer
       END OF ty_paybl,

       ty_paybl_t TYPE STANDARD TABLE OF ty_paybl,
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018

* Begin of Change for SCTASK0745122 by U033876
     BEGIN OF ty_ic_fields,
         vkoiv      TYPE   vkoiv,      " Sales organization for intercompany billing
         vtwiv      TYPE   vtwiv,      " Distribution channel for intercompany billing
         kuniv      TYPE   kuniv,      " Customer number for intercompany billing
         ic_vgbel   TYPE   vgbel,      " Document number of the reference document
         ic_vbeln   TYPE   vbeln,      " IC AR Billing Invoice
         ic_posnr   TYPE   posnr,      " IC AR Billing Invoice Item
         ic_kbetr   TYPE   kbetr_kond, " IC AR Revenue
         ic_waerk   TYPE   waerk,      " SD Document Currency
         ic_fkdat   TYPE   fkdat,      " Billing date for billing index and printout
         ic_rfbsk   TYPE   rfbsk,      " Status for transfer to accounting
         ic_belnr   TYPE   belnr,      " IC AP Invoice
         ic_bstat   TYPE   bstat,      " IC AP Posting status (LRD COGS)
         tu_num     TYPE   char18,     " TU Number
     END OF ty_ic_fields,
     ty_ic_fields_t TYPE STANDARD TABLE OF ty_ic_fields,

     BEGIN OF ty_ic_ar_bill,
         ic_vgbel   TYPE   vgbel,      " Document number of the reference document
         ic_vgpos   TYPE   vgpos,      " Item number of the reference item
         ic_vbeln   TYPE   vbeln,      " IC AR Billing Invoice
         ic_posnr   TYPE   posnr,      " IC AR Billing Invoice Item
         ic_netwr   TYPE   netwr_fp,   " Net value of the billing item in document currency
         ic_waerk   TYPE   waerk,      " SD Document Currency
         ic_fkdat   TYPE   fkdat,      " Billing date for billing index and printout
         ic_rfbsk   TYPE   rfbsk,      " Status for transfer to accounting
      END OF ty_ic_ar_bill,
    ty_ic_ar_bill_t TYPE STANDARD TABLE OF ty_ic_ar_bill,

* Begin of change for Sctask: SCTASK0745122 Intercompany Billing Accural fields by U033876
     BEGIN OF ty_ic_bill_acc,
         ic_bill_acc_vgbel   TYPE   vgbel,    " Document number of the reference document
         ic_bill_acc_vgpos   TYPE   vgpos,    " Item number of the reference item
         ic_bill_acc_vbeln   TYPE   vbeln,    " IC AR Billing Invoice
         ic_bill_acc_posnr   TYPE   posnr,    " IC AR Billing Invoice Item
         ic_bil_accu         TYPE   netwr_fp, "Intercompany billing value to be accrued
         ic_bil_waerk        TYPE   waerk,    " Currency of Intercompany billing
     END OF ty_ic_bill_acc,
         ty_ic_bill_acc_t TYPE STANDARD TABLE OF ty_ic_bill_acc,
* End of change for Sctask: SCTASK0745122 Intercompany Billing Accural fields by U033876

        BEGIN OF ty_bkpf_ap,
          bukrs TYPE bukrs,   " Company Code
          belnr TYPE belnr_d, " Accounting Document Number
          gjahr TYPE gjahr,   " Fiscal Year
          xblnr TYPE xblnr1,  " Reference Document Number
         END OF ty_bkpf_ap,
       ty_bkpf_ap_t TYPE STANDARD TABLE OF ty_bkpf_ap,
* End of change for SCTASK0745122 by U033876

     BEGIN OF ty_final,
         vbeln      TYPE  vbeln_vl,  " Delivery
         route      TYPE  route,     " Route
         bezei_r    TYPE  routbez,   " Description of Route
         kunnr      TYPE  kunwe,     " Ship-to party
         kwename    TYPE name1_gp,   " Name 1
         kunag      TYPE  kunag,     " Sold-to party
         kagname    TYPE  name1_gp,  " Name 1
         wadat_ist  TYPE  wadat_ist, " Actual Goods Movement Date
         podat      TYPE  podat,     " Date (proof of delivery)
         posnr      TYPE  posnr_vl,  " Delivery Item
         vkorg      TYPE  vkorg,     " Sales Organization
         vkorgt     TYPE  vtxtk,     " Name
         lfart      TYPE  lfart,     " Delivery Type
         vstel      TYPE  vstel,     " Shipping Point/Receiving Point
         pstyv      TYPE  pstyv_vl,  " Delivery item category
         erdat      TYPE  erdat,     " Date on Which Record Was Created
* ---> Begin of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
*         matnr      TYPE  matnr,          " Material Number
* <--- End of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
*Type change to accomadate custom change
         matnr      TYPE  char18, " Material Number
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
         werks      TYPE  werks_d,  " Plant
         lgort      TYPE  lgort_d,  " Storage Location
         lfimg      TYPE  lfimg,    " Actual quantity delivered (in sales units)
         meins      TYPE  meins,    " Base Unit of Measure
         arktx      TYPE  arktx,    " Short text for sales order item
         pdsta      TYPE  char4,    " POD status on item level
         pdsta_value TYPE pdsta,    "char4,                        " POD Status on an item level
         vgbel      TYPE  vgbel,    " Document number of the reference document
         vgpos      TYPE  vgpos,    " Item number of the reference item
         erdat_s    TYPE  erdat,    " Date on Which Record Was Created
         ernam_s    TYPE  ernam,    " Name of Person who Created the Object
         auart      TYPE  auart,    " Sales Document Type
         uepos      TYPE  uepos,    " Higher-level item in bill of material structures
         vkbur      TYPE  vkbur,    " Sales Office
         vtweg      TYPE  vtweg,    " Distribution Channel
         mvgr1      TYPE  mvgr1,    " Material group 1
         bezei1     TYPE  bezei40,  " Name of the controlling area
         prctr      TYPE  prctr,    " Profit Center
         kzpod      TYPE  kzpod,    " POD indicator (relevance, verification, confirmation)
         rfmng      TYPE  rfmng,    " Referenced quantity in base unit of measure
         meins_bill TYPE  meins,    " Base Unit of Measure
         netwr      TYPE  netwr_ap, " Net value of the order item in document currency
         ktgrm      TYPE  ktgrm,    " Account assignment group for this material
         ktgrmt     TYPE  bezei20,  " Description
         kwert_k    TYPE  kwert,    " Condition value
         vbeln_bill TYPE  vbeln_vf, " Subsequent sales and distribution document
         posnn_bill TYPE  posnr_vf, " Subsequent item of an SD document
         fkart      TYPE  fkart,    " Billing Type
         fkdat      TYPE  fkdat,    " Billing date for billing index and printout
         rfbsk      TYPE  rfbsk,    " Status for transfer to accounting
         netwr_vf   TYPE  netwr,    " Net Value in Document Currency
         waerk_vf   TYPE  waerk,    " SD Document Currency
         faksk      TYPE  faksk,    " Billing block in SD document
*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
         payer      TYPE  kunnr,   " Customer Number
         pay_bb     TYPE  faksd_x, " Central billing block for customer
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
         cust_block TYPE  char2,          " General Flag
         spe_ident_01 TYPE /spe/de_ident, " Alternative HU Identification
         track_num  TYPE  i,              " Num of type Integers
         ov_rrsta   TYPE  char2,          " Over all Revenue determination status
* Begin of Change for SCTASK0745122 by u033876
         vkoiv      TYPE   vkoiv, " Sales organization for intercompany billing
         vtwiv      TYPE   vtwiv, " Distribution channel for intercompany billing
         kuniv      TYPE   kuniv, " Customer number for intercompany billing
         ic_vbeln   TYPE   vbeln, " IC AR Billing Invoice
         ic_posnr   TYPE   posnr, " IC AR Billing Invoice Item
*         ic_kbetr   TYPE   kbetr_kond, " IC AR Revenue
         ic_netwr   TYPE   netwr_fp,         " IC AR Revenue
         ic_waerk   TYPE   waerk,            " SD Document Currency
         ic_fkdat   TYPE   fkdat,            " Billing date for billing index and printout
         ic_rfbsk   TYPE   rfbsk,            " Status for transfer to accounting
         ap_belnr   TYPE   belnr_d,          " IC AP Invoice
         ap_bstat   TYPE   bsta1,            " IC AP Posting status (LRD COGS)
         tu_num     TYPE   char18,           " TU Number
         ic_bil_accu         TYPE  netwr_fp, "Intercompany billing value to be accrued
         ic_bil_waerk        TYPE waerk,     " Currency of Intercompany billing
* End of change for SCTASK0745122 by U033876
* For first Rev Rec line
         sammg1      TYPE  sammg,       " Group
         reffld1     TYPE  rr_reffld,   " FI document reference number
         rrsta1      TYPE  rr_status,   " Revenue determination status
         budat1      TYPE  budat,       " Posting Date in the Document
         revevdat1   TYPE  rr_revevdat, " Revenue Event Date
         wrbtr_rev1  TYPE  wrbtr,       " Amount in Document Currency
         waerk_rev1  TYPE  waers,       " Currency Key
         belnr1      TYPE  belnr_d,     " Accounting Document Number
* For second Rev Rec line
         sammg2      TYPE  sammg,       " Group
         reffld2     TYPE  rr_reffld,   " FI document reference number
         rrsta2      TYPE  rr_status,   " Revenue determination status
         budat2      TYPE  budat,       " Posting Date in the Document
         revevdat2   TYPE  rr_revevdat, " Revenue Event Date
         wrbtr_rev2  TYPE  wrbtr,       " Amount in Document Currency
         waerk_rev2  TYPE  waers,       " Currency Key
         belnr2      TYPE  belnr_d,     " Accounting Document Number
* For third Rev Rec line
         sammg3      TYPE  sammg,       " Group
         reffld3     TYPE  rr_reffld,   " FI document reference number
         rrsta3      TYPE  rr_status,   " Revenue determination status
         budat3      TYPE  budat,       " Posting Date in the Document
         revevdat3   TYPE  rr_revevdat, " Revenue Event Date
         wrbtr_rev3  TYPE  wrbtr,       " Amount in Document Currency
         waerk_rev3  TYPE  waers,       " Currency Key
         belnr3      TYPE  belnr_d,     " Accounting Document Number
* For fourth Rev Rec line
         sammg4      TYPE  sammg,       " Group
         reffld4     TYPE  rr_reffld,   " FI document reference number
         rrsta4      TYPE  rr_status,   " Revenue determination status
         budat4      TYPE  budat,       " Posting Date in the Document
         revevdat4   TYPE  rr_revevdat, " Revenue Event Date
         wrbtr_rev4  TYPE  wrbtr,       " Amount in Document Currency
         waerk_rev4  TYPE  waers,       " Currency Key
         belnr4      TYPE  belnr_d,     " Accounting Document Number
* For fifth Rev Rec line
         sammg5      TYPE  sammg,       " Group
         reffld5     TYPE  rr_reffld,   " FI document reference number
         rrsta5      TYPE  rr_status,   " Revenue determination status
         budat5      TYPE  budat,       " Posting Date in the Document
         revevdat5   TYPE  rr_revevdat, " Revenue Event Date
         wrbtr_rev5  TYPE  wrbtr,       " Amount in Document Currency
         waerk_rev5  TYPE  waers,       " Currency Key
         belnr5      TYPE  belnr_d,     " Accounting Document Number
* For sixth Rev Rec line
         sammg6      TYPE  sammg,       " Group
         reffld6     TYPE  rr_reffld,   " FI document reference number
         rrsta6      TYPE  rr_status,   " Revenue determination status
         budat6      TYPE  budat,       " Posting Date in the Document
         revevdat6   TYPE  rr_revevdat, " Revenue Event Date
         wrbtr_rev6  TYPE  wrbtr,       " Amount in Document Currency
         waerk_rev6  TYPE  waers,       " Currency Key
         belnr6      TYPE  belnr_d,     " Accounting Document Number
* For seventh Rev Rec line
         sammg7      TYPE  sammg,       " Group
         reffld7     TYPE  rr_reffld,   " FI document reference number
         rrsta7      TYPE  rr_status,   " Revenue determination status
         budat7      TYPE  budat,       " Posting Date in the Document
         revevdat7   TYPE  rr_revevdat, " Revenue Event Date
         wrbtr_rev7  TYPE  wrbtr,       " Amount in Document Currency
         waerk_rev7  TYPE  waers,       " Currency Key
         belnr7      TYPE  belnr_d,     " Accounting Document Number
* For eigth Rev Rec line
         sammg8      TYPE  sammg,       " Group
         reffld8     TYPE  rr_reffld,   " FI document reference number
         rrsta8      TYPE  rr_status,   " Revenue determination status
         budat8      TYPE  budat,       " Posting Date in the Document
         revevdat8   TYPE  rr_revevdat, " Revenue Event Date
         wrbtr_rev8  TYPE  wrbtr,       " Amount in Document Currency
         waerk_rev8  TYPE  waers,       " Currency Key
         belnr8      TYPE  belnr_d,     " Accounting Document Number
* Begin of SCTASK
         rfwrt      TYPE rfwrt,    " Reference value
         waers      TYPE waers_v,  " Statistics currency
         usnam      TYPE usnam,    " User name
         faksp      TYPE faksp_ap, " Billing block for item
* End of SCTASK
       END OF ty_final,
       ty_emi_t       TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
       ty_final_t     TYPE  STANDARD TABLE OF  ty_final,
       ty_rrdocview_t TYPE STANDARD TABLE OF rrdocview,       " Revenue Recognition: Revenue Line View
       ty_rsrange_t   TYPE STANDARD TABLE OF rsrange.         " Include: Ranges in selection conditions

DATA:  i_likp      TYPE ty_likp_t,
       wa_likp     TYPE ty_likp,
       i_lips      TYPE ty_lips_t,
       i_vbup      TYPE ty_vbup_t,
       i_vekp      TYPE ty_vekp_t,
       i_vbap      TYPE ty_vbap_t,
       i_tvkot     TYPE ty_tvkot_t,
       i_tvm1t     TYPE ty_tvm1t_t,
       i_tvrot     TYPE ty_tvrot_t,
       i_tvkmt     TYPE ty_tvkmt_t,
       i_vbak      TYPE ty_vbak_t,
       i_konv      TYPE ty_konv_t,
       i_kna1      TYPE ty_kna1_t,
*--> Begin of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
       i_knvv      TYPE ty_knvv_t,
       i_knvv_soldto      TYPE ty_knvv_t,
*<-- End of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
       i_vbfa      TYPE ty_vbfa_t,
       i_vbrk      TYPE ty_vbrk_t,
       i_vbrp      TYPE ty_vbrp_t,
       i_vbreve    TYPE ty_vbreve_t,
       i_bkpf      TYPE ty_bkpf_t,
* Begin of change for SCTASK0745122 by U033876
*       i_icvbfa    TYPE ty_vbfa_t,
       i_icfields  TYPE ty_ic_fields_t,
       i_ic_ar_bill TYPE ty_ic_ar_bill_t,
*       i_a005_konp TYPE ty_ic_a005_konp_t,
       i_bkpf_ap   TYPE ty_bkpf_ap_t,
       i_ic_bill_acc TYPE ty_ic_bill_acc_t,
* End of change for SCTASK0745122 by U033876
       i_final     TYPE ty_final_t,
       i_fieldcat  TYPE lvc_t_fcat,
       i_accnt_det TYPE ty_rrdocview_t,
       i_enh_status TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
       wa_enh_status TYPE zdev_enh_status,                  " Enhancement Status
*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
       i_payr       TYPE ty_payr_t,
       i_paybl      TYPE ty_paybl_t.
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018


DATA: gv_vkorg            TYPE vkorg, " Sales organization
      gv_vtweg            TYPE vtweg, " Distribution channel
* ---> Begin of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
*      gv_lfart            TYPE lfart,                     " Delivery Type
* <--- End of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
      gv_werks            TYPE werks_d, " Plant
      gv_podat            TYPE podat,   " Date (proof of delivery)
* ---> Begin of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
*      gv_vbeln_vl         TYPE vbeln_vl,                     " Delivery
*      gv_vbeln            TYPE vbeln,                          " Sales and Distribution Document Number
*      gv_kunag            TYPE kunag,                          " Sold-to party
* <--- End of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
** Declare variables with table reference to get Search help
      gv_lfart            TYPE likp-lfart, " Delivery Type
      gv_vbeln_vl         TYPE likp-vbeln, " Delivery
      gv_vbeln            TYPE vbak-vbeln, " Sales and Distribution Document Number
      gv_kunag            TYPE likp-kunag, " Sold-to party
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
      gv_kunnr            TYPE kunnr,                           " Customer Number
      gv_kzpod            TYPE kzpod,                           " POD indicator (relevance, verification, confirmation)
      gv_wadat_ist        TYPE wadat_ist,                       " Actual Goods Movement Date
      go_custom_container TYPE REF TO cl_gui_custom_container,  " Container for Custom Controls in the Screen Area
      go_alv_grid         TYPE REF TO cl_gui_alv_grid,          " ALV List Viewer
      go_gui_cont_top     TYPE REF TO cl_gui_container,         " Abstract Container for GUI Controls
      go_gui_cont_alv     TYPE REF TO cl_gui_container,         " Abstract Container for GUI Controls
      go_dock_cont        TYPE REF TO cl_gui_docking_container, " Docking Control Container
      go_alv_grid_accnt   TYPE REF TO cl_gui_alv_grid,          " ALV List Viewer
      gv_days             TYPE int4,                            " Natural Number
      gv_kschl            TYPE kschl,                           " global variable
      gv_vpobj            TYPE vpobj.                           " Packing Object



***************************CLASS DECLARATION****************************
*&--Event handler Class of ALV
CLASS go_event_handler DEFINITION FINAL. " Event_handler class
  PUBLIC SECTION.
*&---for Common Header
    METHODS: meth_i_pub_handle_topofpage "Event handler top of page
                                  FOR EVENT top_of_page OF cl_gui_alv_grid
                                  IMPORTING e_dyndoc_id,
*&--On tool bar handler method for adding accounting button on alv
             meth_on_toolbar "Event handler for custom button
                            FOR EVENT toolbar OF  cl_gui_alv_grid
                            IMPORTING        e_object,
*&--Action to be performed when accounting button is pressed on alv
             meth_handle_user_comm "Event handler for User command action
                             FOR EVENT user_command OF cl_gui_alv_grid
                             IMPORTING e_ucomm.

ENDCLASS. "go_event_handler DEFINITION

CONSTANTS: c_vbrr         TYPE awtyp          VALUE 'VBRR',                   " Reference Transaction
           c_i            TYPE rssign         VALUE 'I',                      " Selection criteria: SIGN
           c_eq           TYPE rsoption       VALUE 'EQ',                     " Selection criteria: OPTION
           c_m            TYPE vbtyp_n        VALUE 'M',                      " Document category of subsequent document
           c_tab1         TYPE char4          VALUE 'TAB1',                   "Tab 1
           c_tab2         TYPE char4          VALUE 'TAB2',                   "Tab 2
           c_tab3         TYPE char4          VALUE 'TAB3',                   "Tab 3
           c_container    TYPE char8          VALUE 'ALV_CONT',               "Container
           c_style        TYPE lvc_fname      VALUE 'FIELD_STYLE',            " ALV control: Field name of internal table field
           c_back         TYPE syucomm        VALUE 'BACK',                   "OK code-BACK
           c_exit         TYPE syucomm        VALUE 'EXIT',                   "OK code-EXIT
           c_cancel       TYPE syucomm        VALUE 'CANCEL',                 "OK code-CANCEL
           c_null         TYPE z_criteria     VALUE 'NULL',                   " Enh. Criteria
           c_days         TYPE z_criteria     VALUE 'DAYS',                   " Enh. Criteria
           c_kschl        TYPE z_criteria     VALUE 'KSCHL',                  " Enh. Criteria
           c_acc          TYPE char10         VALUE 'Accounting',             " Acc of type CHAR10
           c_accnt        TYPE syucomm        VALUE 'SHOW_AC',                " Function code that PAI triggered
           c_act_can      TYPE char25         VALUE 'Accounting View Cancel', " Act_can of type CHAR25
           c_acnt_canc    TYPE syucomm        VALUE 'ACCNT_CANC',             " Function code that PAI triggered
           c_pdsta_a      TYPE pdsta          VALUE 'A',                      "A
           c_pdsta_b      TYPE pdsta          VALUE 'B',                      "B
           c_pdsta_c      TYPE pdsta          VALUE 'C',                      "C
           c_vprs         TYPE saknr          VALUE 'VPRS',                   " G/L Account Number
           c_vpobj        TYPE z_criteria     VALUE 'VPOBJ',                  " Enh. Criteria
           c_t            TYPE /spe/de_huidart  VALUE 'T',                    " Handling Unit Identification Type
* Begin of change for SCTASK0745122 by U033876
           c_v      TYPE kappl    VALUE 'V',    " Application
           c_zppm   TYPE kschl    VALUE 'ZPPM'. " Condition Type
* End of change for SCTASK0745122 by U033876
