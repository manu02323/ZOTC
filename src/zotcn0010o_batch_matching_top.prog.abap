*&---------------------------------------------------------------------*
*&  Include           ZOTCN0010O_BATCH_MATCHING_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0010O_BATCH_MATCHING_TOP                          *
* TITLE      :  Batch Matching Report                                  *
* DEVELOPER  :  Pallavi Gupta                                          *
* OBJECT TYPE:  INCLUDE                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0010_BATCH_MATCHING Report                       *
*----------------------------------------------------------------------*
* DESCRIPTION:  Include for data declaration for Report                *
*               ZOTCR0010O_BATCH_MATCHING                              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 16-Jul-2012 PGUPTA2  E1DK901335 INITIAL DEVELOPMENT                  *
* 17-Dec-2012 RVERMA   E1DK908486 Defect#2164: Performance Issues      *
* 06-AUG-2014 PROUT    E1DK913381 INC0140560 / CR1286:                 *
*                                 Updated selection screen with extra  *
*                                 checkbox 'Without Order History'. If *
*                                 the indicator got checked sales ord. *
*                                 details for the customer will not be *
*                                 displayed in the report output. Also *
*                                 Material Number and Batch Number will*
*                                 have multiple selections. If the     *
*                                 indicator is not checked then        *
*                                 Material No and Batch No will have   *
*                                 single entry and sales order history *
*                                 for the customer needs to be fetched *
*                                 for the customer in the report o/p.  *
*&---------------------------------------------------------------------*
* 16-SEP-2014 SPAUL2   E1DK913381 INC0140560 / CR1286:                 *
*                                 Added some additional requirements   *
*                                 as per business user demand.         *
*                                 1.New selection parameter of Ship-to *
*                                 2.New rept output column of Ship-to  *
*                                 3.Ship-to value fetching logic       *
*                                 4.Shift of column Unrest. Stock to   *
*                                   the end of the output              *
* 08-Oct-2014 SPAUL2   E1DK913381 INC0140560 / CR1286:                 *
*                                 Field description changes recommended*
*                                 by business in the selection screen  *
*                                 and report output.                   *
*                                 Customer desc not getting populated. *
*&---------------------------------------------------------------------*


************************************************************************
*             Types Declaration                                        *
************************************************************************
TYPES: BEGIN OF ty_final,
         atwrt     TYPE atwrt, " Prod Group
         atwrt_dec TYPE atwrt, " PG Description
         kunnr     TYPE kunnr, " Customer No
         name1     TYPE name1, " Cust. Description
         vbeln     TYPE vbeln, " Sales Order Number
**&& -- Begin of insert: CR #1286 : SPAUL2 : 16-SEP-2014
         shipto    TYPE kunnr,   " Ship-to
         description TYPE name1, " Ship-to description
**&& -- End of insert: CR #1286 : SPAUL2 : 16-SEP-2014
         audat     TYPE audat,           " Sales Order Creation Date
         vbelv     TYPE vbeln_von,       " Delivery no
         wadat_ist TYPE wadat_ist,       " Post Goods Issue Date realted to sales Order line item
         bstkd     TYPE bstkd,           " Purchase Oder in sales order Document
         matnr     TYPE matnr,           " Material Number
         posnr     TYPE maktx,           " Material Description
         charg     TYPE charg_d,         " Batch number in Sales Order
         hsdat     TYPE hsdat,           " Manufacturing date of Batch number
         vfdat     TYPE vfdat,           " Shelf life expiration date of batch number
         kwmeng    TYPE i,               " Sales Order Quantity
         vrkme     TYPE vrkme,           " Sales unit for material
         netwr     TYPE i,               " Price in sales Order
         waers     TYPE waers,           "SD Document Currency
         clabs     TYPE i,               " Unrestricted stock Quantity
         werks     TYPE werks_d,         " Unrest. Qty Plant
         atinn     TYPE atinn ,          " Characteristics based on material
         atnam     TYPE atnam,           " Characteristic description
         atwrt_m   TYPE char100,         "atwrt ,        " Characteristic Value "Changed by SNIGAM on 04-Nov-14
         ec_code   TYPE char50,          "char3,         " EC Code
         warning   TYPE char10,          " Warning
         cuobj_bm  TYPE cuobj_bm ,       " Internal object no.: Batch classification
         atnam1    TYPE atnam,           " characteristic description from cabn
         kunnr0     TYPE kunnr,          " customer no with preceeding zero
         matnr_p   TYPE matnr,           " Parent Material
       END OF ty_final,

       BEGIN OF ty_batch,
         matnr          TYPE z_kit,      " Kit
         zlevel         TYPE z_level,    " Level
         matnr2         TYPE matnr,      " Material no
         compcode       TYPE z_compcode, " Compatibility Code
         ccode          TYPE atinn,      "Internal char
       END OF ty_batch,

       BEGIN OF ty_ausp,
         objek TYPE matnr,               " Key of object to be classified
         atinn TYPE atinn,               " Internal characteristic
         atzhl TYPE wzaehl,              " Characteristic value counter
         mafid TYPE klmaf,               " Indicator: Object/Class
         klart TYPE klassenart,          " Class Type
         adzhl TYPE adzhl,               " Internal counter for archiving objects via engin. chg. mgmt
         atwrt TYPE atwrt,               " Characteristic Value
         atflv TYPE atflv,               " Internal floating point from
         cuobj TYPE cuobj_bm,            " Internal characteristic
      END OF ty_ausp,

      BEGIN OF ty_vbkd,
        vbeln TYPE vbeln,                " Sales and Distribution Document Number
        posnr TYPE posnr,                " Item number of the SD document
        bstkd TYPE bstkd,                " Customer purchase order number
      END OF ty_vbkd,

      BEGIN OF ty_cabn,
       atinn TYPE atinn,                 " Internal characteristic
       adzhl TYPE adzhl,                 " Internal counter for archiving objects via engin. chg. mgmt
       atnam TYPE atnam,                 " Characteristic Name
       atfor TYPE atfor,                 "Data type of characteristic
      END OF ty_cabn,

      BEGIN OF ty_kna1,
        kunnr TYPE kunnr,                " Customer No
        name1 TYPE name1,                " Customer Name
      END OF ty_kna1,

      BEGIN OF ty_likp,
        vbeln     TYPE vbeln,            " Sales and Distribution Document Number
        wadat_ist TYPE wadat_ist,        " Actual Goods Movement Date
      END OF ty_likp,

      BEGIN OF ty_vbfa,
        vbelv   TYPE vbeln_von,          " Preceding sales and distribution document
        posnv   TYPE posnr_von,          " Preceding item of an SD document
        vbeln   TYPE vbeln_nach,         " Sales and Distribution Document Number
        posnn   TYPE posnr_nach,         " Subsequent item of an SD document
        vbtyp_n TYPE vbtyp_n,            " Document category of subsequent document
     END OF ty_vbfa,

     BEGIN OF ty_mchb,
        matnr TYPE matnr,                " Material Number
        werks TYPE werks_d,              " Plant
        lgort TYPE lgort_d,              " Storage Location
        charg TYPE charg_d,              " Batch Number
        clabs TYPE labst,                " Valuated Unrestricted-Use Stock
        cumlm TYPE umlmd,                " Stock in transfer (from one storage location to another)
        cinsm TYPE insme,                " Stock in Quality Inspection
        ceinm TYPE einme,                " Total Stock of All Restricted Batches
        inv   TYPE einme,                " var for Sum of four above fields
        del   TYPE char2,                " Indicator for deletion
     END OF ty_mchb,

     BEGIN OF ty_mch1,
        matnr    TYPE matnr,             " Material Number
        charg    TYPE charg_d,           " Batch Number
        vfdat    TYPE vfdat,             " Shelf Life Expiration or Best-Before Date
        hsdat    TYPE hsdat,             " Date of Manufacture
        cuobj_bm TYPE cuobj_bm,          " Internal object no.: Batch classification
     END OF ty_mch1,

     BEGIN OF ty_vbap,
      vbeln  TYPE vbeln,                 " Sales Order
      posnr  TYPE posnr,                 " Item No
      matnr  TYPE matnr,                 " MAterial No
      charg  TYPE charg_d,               " Characteristics
      netwr  TYPE netwr_ap,              " Net value of the order item in document currency
      waerk  TYPE waerk,                 "SD Document Currency
      kwmeng TYPE kwmeng,                " Cumulative Order Quantity in Sales Units
      vrkme  TYPE vrkme,                 " Sales Unit
      werks  TYPE werks_d,               " Plant
    END OF ty_vbap,

    BEGIN OF ty_lips,
      vbeln TYPE vbeln_vl,               "Delivery
      posnr TYPE posnr_vl,               "Delivery Item
      charg TYPE charg_d,                "charg
    END OF ty_lips,

    BEGIN OF ty_vapma,
      matnr  TYPE matnr,                 " Material Number
      vkorg  TYPE vkorg,                 " Sales Organization
      trvog  TYPE trvog,                 " Transaction group
      audat  TYPE audat,                 " Document Date (Date Received/Sent)
      vtweg  TYPE vtweg,                 " Distribution Channel
      spart  TYPE spart,                 " Division
      auart  TYPE auart,                 " Sales Document Type
      kunnr  TYPE kunnr,                 " Customer Number
      vkbur  TYPE vkbur,                 " Sales Office
      vkgrp  TYPE vkgrp,                 " Sales Group
      bstnk  TYPE bstnk,                 " Customer purchase order number
      ernam  TYPE ernam,                 " Name of Person who Created the Object
      vbeln  TYPE vbeln,                 " Sales and Distribution Document Number
      posnr  TYPE posnr,                 " Item number of the SD document
   END OF ty_vapma,

**&& -- Begin of insert: CR #1286 : SPAUL2 : 16-SEP-2014
   BEGIN OF ty_vbpa,
     vbeln TYPE vbeln, " Sales and Distribution Document Number
     posnr TYPE posnr, " Item number of the SD document
     parvw TYPE parvw, " Partner Function
     kunnr TYPE kunnr, " Customer Number
   END OF ty_vbpa,
**&& -- End of insert: CR #1286 : SPAUL2 : 16-SEP-2014

**&& -- Begin of Insert: CR #1286 : SPAUL2 : 08-OCT-2014
    BEGIN OF ty_kunnr,
      kunnr TYPE kunnr, " Customer Number
    END OF ty_kunnr,
**&& -- End of Insert: CR #1286 : SPAUL2 : 08-OCT-2014

   BEGIN OF ty_cawnt,
     atinn TYPE atinn,                   "Internal characteristic
     atzhl TYPE atzhl,                   "Internal Counter
     spras TYPE spras,                   " Language Key
     adzhl TYPE adzhl,                   " Internal counter for archiving objects via engin. chg. mgmt
     atwtb TYPE atwtb,                   "Characteristic value description
   END OF ty_cawnt,

       BEGIN OF ty_batch_1,
         matnr          TYPE z_kit,      " Kit
         zlevel         TYPE z_level,    " Level
         matnr2         TYPE objnum,     " Material no
         compcode       TYPE z_compcode, " Compatibility Code
         ccode          TYPE atinn,      "Internal char
       END OF ty_batch_1,

   BEGIN OF ty_inob,
     cuobj TYPE cuobj,                   "Configuration (internal object number)
     klart TYPE klassenart,              "Class Type
     obtab TYPE tabelle,                 "Name of database table for object
     objek TYPE cuobn,                   "Key of Object to be Classified
   END OF ty_inob,

   BEGIN OF ty_cabnt,
     atinn TYPE atinn,                   "Internal characteristic
     spras TYPE spras,                   " Language Key
     adzhl TYPE adzhl,                   " Internal counter for archiving objects via engin. chg. mgmt
*     spras TYPE spras,  "Language Key   "Commented for Defect#2164
     atbez TYPE atbez, "Characteristic description
  END OF ty_cabnt,

  BEGIN OF ty_makt,
    matnr TYPE matnr,  "Material Number
    spras TYPE spras,  " Language Key
*    spras TYPE spras,    "Language Key  "Commented for Defect#2164
    maktx TYPE maktx, "Material Des
  END OF ty_makt,

  BEGIN OF ty_atinn,
    atinn TYPE atinn, "Internal charactersitic
  END OF ty_atinn.


**Table Type Declaration
TYPES:  ty_t_batch     TYPE STANDARD TABLE OF ty_batch,   " Table type for ty_batch
        ty_t_batch_1   TYPE STANDARD TABLE OF ty_batch_1, " Table type for ty_batch
        ty_t_makt      TYPE STANDARD TABLE OF ty_makt,    " Table type for ty_makt
        ty_t_final     TYPE STANDARD TABLE OF ty_final,   " Table type for ty_final
        ty_t_ausp      TYPE STANDARD TABLE OF ty_ausp,    " Table type for ty_ausp
        ty_t_atinn     TYPE STANDARD TABLE OF ty_atinn,   " Table type for ty_atinn
        ty_t_cawnt     TYPE STANDARD TABLE OF ty_cawnt,   "Table type for ty_cawnt
        ty_t_mch1      TYPE STANDARD TABLE OF ty_mch1,    " Table type for ty_mch1
        ty_t_mchb      TYPE STANDARD TABLE OF ty_mchb,    " Table type for ty_mchb_temp
        ty_t_vbap      TYPE STANDARD TABLE OF ty_vbap,    " Table type for ty_vbap
        ty_t_vbfa      TYPE STANDARD TABLE OF ty_vbfa,    " Table type for ty_vbfa
        ty_t_lips      TYPE STANDARD TABLE OF ty_lips,    " Table type for ty_lips
        ty_t_likp      TYPE STANDARD TABLE OF ty_likp,    " Table type for ty_likp
        ty_t_kna1      TYPE STANDARD TABLE OF ty_kna1,    " Table type for ty_kna1
        ty_t_vbkd      TYPE STANDARD TABLE OF ty_vbkd,    " Table type for ty_vbkd
        ty_t_cabn      TYPE STANDARD TABLE OF ty_cabn,    " Table type for ty_cabn
        ty_t_vapma     TYPE STANDARD TABLE OF ty_vapma,   " Table type for ty_vapma
**&& -- Begin of insert: CR #1286 : SPAUL2 : 16-SEP-2014
        ty_t_vbpa      TYPE STANDARD TABLE OF  ty_vbpa, " Table type for ty_vbpa
**&& -- End of insert: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 08-OCT-2014
        ty_t_kunnr     TYPE STANDARD TABLE OF ty_kunnr,
**&& -- End of Insert: CR #1286 : SPAUL2 : 08-OCT-2014
        ty_t_inob      TYPE STANDARD TABLE OF ty_inob,  " Table type for ty_inob
        ty_t_cabnt     TYPE STANDARD TABLE OF ty_cabnt, " Table type for cabnt
        ty_t_retrn1    TYPE STANDARD TABLE OF bapiret2. " Table Type for Return Parameters

************************************************************************
*             Constants Declaration                                   *
************************************************************************
CONSTANTS:    c_left   TYPE char1   VALUE 'L',                   " Left justifaction in ALV display
              c_inv    TYPE char1   VALUE 'X',                   " Constants for inv
              c_vbtyp  TYPE vbtyp_n VALUE 'J',                   " Constants for delivery type as J
              c_zero   TYPE char1  VALUE '0',                    " Constants for Zero Inv
              c_colon  TYPE char1  VALUE ':',                    "Constant for colon
              c_slash  TYPE char1  VALUE '/',                    "Constant for slash
              c_top    TYPE slis_formname VALUE 'F_TOP_OF_PAGE', "Constant for top of page
              c_save   TYPE char1  VALUE 'A',                    "Used in alv for user save
              c_bm     TYPE atnam  VALUE 'BM_PRODGROUP',         "BM_PRODGROUP
              c_12     TYPE numc3  VALUE '012',                  "Constant for 012.
              c_atinn  TYPE atnam  VALUE 'ZM_TECH_TYPE',         "Constant for 99
              c_ch     TYPE char5  VALUE 'CHECK',                "Constant for check
              c_fut    TYPE char6  VALUE 'FUTURE',               "Constant for future
              c_atfor  TYPE char4  VALUE 'CHAR',                 "Constant for char data type
              c_sign   TYPE char1  VALUE 'I',                    "Constant for sign
              c_option TYPE char2  VALUE 'BT',                   "Constant for option
              c_posnr  TYPE posnr  VALUE '000000',               "Constant for posnr
              c_shead  TYPE char1  VALUE 'S',                    "Constant for S
              c_head   TYPE char1  VALUE 'H',                    "Constant for H
              c_class  TYPE char3  VALUE '001',                  "Constant for class type
**&& -- Begin of insert: CR #1286 : SPAUL2 : 16-SEP-2014
              c_parvw_we TYPE parvw VALUE 'WE'. "Constant for partne function ship to
**&& -- End of insert: CR #1286 : SPAUL2 : 16-SEP-2014

************************************************************************
*                 Global Internal Table Declaration                    *
************************************************************************

DATA:    i_final      TYPE ty_t_final,   "Final internal table
         i_final_tmp  TYPE ty_t_final,   "Final temp internal table
         i_final_tmp1 TYPE ty_t_final,   "Final temp internal table
         i_final_tmp2 TYPE ty_t_final,
         i_batch      TYPE ty_t_batch,   " Internal Table for Batch
         i_makt       TYPE ty_t_makt,    " Internal table for makt
         i_batch_1    TYPE ty_t_batch_1, " Internal Table for Batch
         i_batch_tmp  TYPE ty_t_batch,   " Internal Table for Batch
         i_ausp       TYPE ty_t_ausp,    " Internal Table for Ausp
         i_ausp_1     TYPE ty_t_ausp,    " Internal Table for Ausp
         i_cawnt      TYPE ty_t_cawnt,   " Internal table for Cawnt
         i_cabn       TYPE ty_t_cabn,    " Internal Table for Cabn
         i_cabnt      TYPE ty_t_cabnt,   " Interna Table for char des
         i_mch1       TYPE ty_t_mch1,    " Internal Table for Mch1
         i_mchb       TYPE ty_t_mchb,    " Internal Table for Mchb
         i_vbap       TYPE ty_t_vbap,    " Internal Table for Vbap
         i_vbap_tmp   TYPE ty_t_vbap,    " Internal Table for Vbap
         i_vbfa       TYPE ty_t_vbfa,    " Internal Table for Vbfa
         i_lips       TYPE ty_t_lips,    " Internal table for lips
         i_vapma      TYPE ty_t_vapma,   " Internal Table for Vapma
**&& -- Begin of insert: CR #1286 : SPAUL2 : 16-SEP-2014
         i_vbpa       TYPE ty_t_vbpa, " Internal table for VBPA
**&& -- End of insert: CR #1286 : SPAUL2 : 16-SEP-2014
         i_kna1       TYPE ty_t_kna1, " Internal Table for Kna1
         i_vbkd       TYPE ty_t_vbkd, " Internal Table for Vbkd
         i_likp       TYPE ty_t_likp, " Internal Table for Likp
         i_inob       TYPE ty_t_inob, " Internal Table for Inob

************************************************************************
*                   ALV Data Declaration                               *
************************************************************************
      i_fieldcat         TYPE slis_t_fieldcat_alv, "Fieldcatalog Internal tab
      i_listheader       TYPE slis_t_listheader,   "List header internal tabab
      wa_fieldcat        TYPE slis_fieldcat_alv,   "Fieldcatalog Workarea

************************************************************************
*             Variables Declaration                                   *
************************************************************************
      gv_date   TYPE sy-datum,      "Current date
      gv_kunnr  TYPE kunag,         " Customer No.
      gv_charg  TYPE dfbatch-charg, "Batch No.
      gv_atinn  TYPE atinn,         "Internal characteristic
**&& -- BOC : CR# 1286 : PROUT : 06-AUG-2014
      gv_matnr  TYPE matnr. "Material number
**&& -- EOC : CR# 1286 : PROUT : 06-AUG-2014
