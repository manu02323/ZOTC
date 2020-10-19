*&---------------------------------------------------------------------*
*&  Include           ZOTCR0123O_REVENUE_AUDIT_TOP
*&---------------------------------------------------------------------*
* PROGRAM    :  ZOTCR0121O_REVENUE_AUDITREPORT                         *
* TITLE      :  Revenue Report for Audit                               *
* DEVELOPER  :  Sumanpreet Kaur                                        *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  : D3_OTC_RDD_0123                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: Revenue Report for Audit                                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER    TRANSPORT     DESCRIPTION                      *
* =========== ======== ========== =====================================*
* 07-MAY-2018 U034334  E1DK936497 Initial Development                  *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* 20-Sep-2018 U033814  E1DK936497 SCTASK0736901 Add some 9 new fields
*                                 remove some unwanted fiedls and change
*                                 the description for the mentioned fields
*&---------------------------------------------------------------------*
* 22-Oct-2018 U033814  E1DK938998 – Defect 7311 Add 3 new additional
* fields to capture Local amount & currency
*&---------------------------------------------------------------------*


*&--Global Constants
CONSTANTS: c_rr  TYPE blart   VALUE 'RR', " Revenue Recognition
           c_err TYPE char1   VALUE 'E'.  " Error

*&--Global Structure Types
TYPES:
* Deliveries from VBFA
       BEGIN OF ty_vbfa_dlv,
         vbelv   TYPE vbeln_von,  " Preceding sales and distribution document
         posnv   TYPE posnr_von,  " Preceding item of an SD document
         vbeln   TYPE vbeln_nach, " Subsequent sales and distribution document
         posnn   TYPE posnr_nach, " Subsequent item of an SD document
         vbtyp_n TYPE vbtyp_n,    " Document category of subsequent document
         rfmng   TYPE rfmng,      " Referenced quantity in base unit of measure
       END OF ty_vbfa_dlv,

* Delivery Header
        BEGIN OF ty_likp,
          vbeln  TYPE char35,       " Delivery
          lfart  TYPE lfart,        " Delivery Type
          inco1  TYPE inco1,        " Incoterms (Part 1)
          inco2  TYPE inco2,        " Incoterms (Part 2)
          route  TYPE route,        " Route
          kunnr  TYPE kunwe,        " Ship-to party
          kunag  TYPE kunag,        " Sold-to party
          anzpk  TYPE anzpk,        " Total number of packages in delivery
          wadat_ist TYPE wadat_ist, " Actual Goods Movement Date
          podat  TYPE podat,        " Date (proof of delivery)
          tu_num TYPE char18,       " Num of type CHAR18
        END OF ty_likp,

* Delivery Items
        BEGIN OF ty_lips,
          vbeln TYPE vbeln_vl, " Delivery
          posnr TYPE posnr_vl, " Delivery Item
          lfimg TYPE lfimg,    " Actual quantity delivered (in sales units)
          uecha TYPE uecha,    " Higher-Level Item of Batch Split Item
        END OF ty_lips,

* Accounting Document Header
        BEGIN OF ty_bkpf,
         bukrs TYPE bukrs,   " Company Code
         belnr TYPE belnr_d, " Accounting Document Number
         gjahr TYPE gjahr,   " Fiscal Year
         blart TYPE blart,   " Document Type
         budat TYPE budat,   " Posting Date in the Document
* Begin of Defect 7311
         hwaer TYPE hwaer, " Local Currency
         kursf TYPE kursf, " Exchange Rate for Price Determination
* End of Defect 7311
         awkey TYPE awkey, " Reference Key
        END OF ty_bkpf,

* Sales Document Items
        BEGIN OF ty_vbap,
          vbeln TYPE vbeln_va, " Sales Document
          posnr TYPE posnr_va, " Sales Document Item
          pstyv TYPE pstyv,    " Sales document item category
* Begin of SCTASK0736901
          matnr TYPE matnr,   " Material Number
          werks TYPE werks_d, " Plant
          mvgr1 TYPE mvgr1,   " Material group 1
* End of SCTASK0736901
          ktgrm TYPE ktgrm, " Account assignment group for this material
        END OF ty_vbap,

* Material Document Header
        BEGIN OF ty_mkpf,
          usnam  TYPE usnam,  " User name
          xblnr  TYPE xblnr1, " Reference Document Number
          tcode2 TYPE tcode,  " Transaction Code
        END OF ty_mkpf,

* Invoice Items
        BEGIN OF ty_vbrp,
          vbeln TYPE vbeln_vf, " Billing Document
          posnr TYPE posnr_vf, " Billing item
          vgbel TYPE vgbel,    " Document number of the reference document
          vgpos TYPE vgpos,    " Item number of the reference item
* ---> Begin of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
          aubel TYPE vbeln_va, " Sales Document
          aupos TYPE posnr_va, " Sales Document Item
* <--- End   of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
        END OF ty_vbrp,

* ---> Begin of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
        BEGIN OF ty_vbrk,
          vbeln TYPE vbeln_vf, " Billing Document
          vbtyp TYPE vbtyp,    " SD document category
          fksto TYPE fksto,    " Billing document is cancelled
        END OF ty_vbrk,
* <--- End   of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018

* Final table for ALV
        BEGIN OF ty_final,
* Begin of SCTASK0736901
          vbeln    TYPE vbeln_va,        " Sales Document
          posnr    TYPE posnr_va,        " Sales Document Item
          sakrv    TYPE saknr,           " G/L Account Number
          bdjpoper TYPE rr_bdjpoper,     " Posting year and posting period (YYYYMMM format)
          popupo   TYPE rr_popupo,       " Period sub-item
          vbeln_n  TYPE vbeln_nach,      " Subsequent sales and distribution document
          posnr_n  TYPE posnr_nach,      " Subsequent item of an SD document
          wrbtr    TYPE wrbtr,           " Amount in Document Currency
          rvamt    TYPE rr_rvamt,        " Revenue amount
          waerk    TYPE waers,           " Currency Key
          accpd    TYPE rr_accpd,        " Accrual period
          vbtyp_n  TYPE vbtyp_n,         " Document category of subsequent document
          paobjnr  TYPE rkeobjnr,        " Profitability Segment Number (CO-PA)
          prctr    TYPE prctr,           " Profit Center
          sakdr    TYPE rr_sakdr,        " Account for Deferred Revenues/Costs
          sakur    TYPE rr_sakur,        " Account for Unbilled Receivables/Costs
          gsber    TYPE gsber,           " Business Area
          bukrs    TYPE bukrs,           " Company Code
          bemot    TYPE bemot,           " Accounting Indicator
          sammg    TYPE sammg,           " Group
          reffld   TYPE rr_reffld,       " FI document reference number
          rrsta    TYPE rr_status,       " Revenue determination status
          kunag    TYPE kunag,           " Sold-to party
          ps_psp_pnr TYPE ps_psp_pnr,    " Work Breakdown Structure Element (WBS Element)
          vbelv    TYPE vbelv,           " Originating document
          posnv    TYPE posnv,           " Originating item
          aufnr    TYPE aufnr,           " Order Number
          kostl    TYPE kostl,           " Cost Center
          kstat    TYPE kstat,           " Condition is used for statistics
          erdat    TYPE erdat,           " Date on Which Record Was Created
          erzet    TYPE erzet,           " Entry time
          budat    TYPE budat,           " Posting Date in the Document
          revfix   TYPE rr_revfix,       " Fixed Revenue Line Indicator
          revvbtyp_source TYPE vbtyp_n,  " Document category of subsequent document
          revevtyp TYPE rr_revevtyp,     " Revenue Event Type
          revevdocn TYPE rr_revevdocn,   " Revenue Event Document Number
          revevdocni TYPE rr_revevdocni, " Item Number of Revenue Event
          revevdat TYPE rr_revevdat,     " Revenue Event Date
          revpoblck TYPE rr_revpoblck,   " Revenue Posting Block
          dmbtr    TYPE dmbtr,           " Amount in Local Currency
          rvamt_lc TYPE rr_rvamt_lc,     " Revenue Amount in First Local Currency
          hwaer    TYPE hwaer,           " Local Currency
          kruek    TYPE kruek,           " Condition is Relevant for Accrual  (e.g. Freight)
          costrec  TYPE rr_costrec_flag, " Relevant for Cost Recognition
          invnum   TYPE vbeln_vf,        " Billing Document
          invpos   TYPE posnr_vf,        " Billing item
          delnum   TYPE vbeln_vl,        " Delivery
          delpos   TYPE posnr_vl,        " Delivery Item
          inco1    TYPE inco1,           " Incoterms (Part 1)
          inco2    TYPE inco2,           " Incoterms (Part 2)
          route    TYPE route,           " Route
          kunnr    TYPE kunwe,           " Ship-to party
          anzpk    TYPE anzpk,           " Total number of packages in delivery
          podat    TYPE podat,           " Date (proof of delivery)
          wadat_ist TYPE wadat_ist,      " Actual Goods Movement Date
          usnam    TYPE usnam,           " User name
          belnr    TYPE belnr_d,         " Accounting Document Number
          blart    TYPE blart,           " Document Type
          rev_budat TYPE budat,          " Posting Date in the Document
          awkey    TYPE awkey,           " Reference Key
          pstyv    TYPE pstyv,           " Sales document item category
          ktgrm    TYPE ktgrm,           " Account assignment group for this material
          export   TYPE char1,           " Export Indicator
          tu_num   TYPE char18,          " TU
          soline   TYPE char16,          " Soline of type CHAR16
          name1    TYPE name1,           " Name
          name2    TYPE name1,           " Name
          matnr    TYPE matnr,           " Material Number
          maktx    TYPE maktx,           " Material Description (Short Text)
          werks    TYPE werks_d,         " Plant
          name3    TYPE name1,           " Name
          mvgr1    TYPE mvgr1,           " Material group 1
          bezei    TYPE bezei,           " Name of the controlling area
* Begin of Defect 7311
          kursf    type char16,
* End of Defect 7311
*          dmbtr    type dmbtr,
*          bukrs    TYPE bukrs, " Company Code
*          vbeln    TYPE vbeln_va,    " Sales Document
*          posnr    TYPE posnr_va,    " Sales Document Item
*          soline   TYPE char16,  " Soline of type CHAR16
*          kunag    TYPE kunag,     " Sold-to party
*          name2    TYPE name1,   " Name
*          kunnr    type kunwe,
*          name1    TYPE name1,   " Name
*          matnr    TYPE matnr,   " Material Number
*          maktx    TYPE maktx,   " Material Description (Short Text)
*          werks    TYPE werks_d, " Plant
*          name3    TYPE name1,   " Name
*          prctr    TYPE prctr,    " Profit Center
*          pstyv    TYPE pstyv,   " Sales document item category
*          mvgr1    TYPE mvgr1,   " Material group 1
*          ktgrm    TYPE ktgrm,   " Account assignment group for this material
*          wrbtr    TYPE wrbtr,      " Amount in Document Currency
*          rvamt    TYPE rr_rvamt,   " Revenue amount
*          waerk    TYPE waers,      " Currency Key
*          accpd    TYPE rr_accpd,   " Accrual period
*          invnum   TYPE vbeln_vf,   " Billing Document
*          invpos   TYPE posnr_vf,   " Billing item
*          delnum   TYPE vbeln_vl,   " Delivery
*          delpos   TYPE posnr_vl,   " Delivery Item
*          inco1    TYPE inco1,      " Incoterms (Part 1)
*          inco2    TYPE inco2,      " Incoterms (Part 2)
*          route    TYPE route,      " Route
*          bezei    TYPE bezei,   " Name of the controlling area
*          podat    TYPE podat,      " Date (proof of delivery)
*          wadat_ist TYPE wadat_ist, " Actual Goods Movement Date
*          usnam    TYPE usnam,      " User name
*          anzpk    TYPE anzpk,      " Total number of packages in delivery
*          belnr    TYPE belnr_d,    " Accounting Document Number
*          blart    TYPE blart,      " Document Type
*          rev_budat TYPE budat,     " Posting Date in the Document
*          rrsta    TYPE rr_status, " Revenue determination status
*          vbeln_n  TYPE vbeln_nach, " Subsequent sales and distribution document
*          posnr_n  TYPE posnr_nach, " Subsequent item of an SD document
*          sakrv    TYPE saknr,       " G/L Account Number
*          bdjpoper TYPE rr_bdjpoper, " Posting year and posting period (YYYYMMM format)
*          sakdr    TYPE rr_sakdr, " Account for Deferred Revenues/Costs
*          sammg    TYPE sammg,     " Group
*          reffld   TYPE rr_reffld, " FI document reference number
*          sakur    TYPE rr_sakur, " Account for Unbilled Receivables/Costs
*          budat    TYPE budat, " Posting Date in the Document
*          export   TYPE char1,   " Export Indicator
*          tu_num   TYPE char18,  " TU
** End of SCTASK0736901
        END OF ty_final,

*&--Global Table Types
       ty_t_vbfa_dlv    TYPE STANDARD TABLE OF ty_vbfa_dlv, " Deliveries from VBFA
       ty_t_likp        TYPE STANDARD TABLE OF ty_likp,     " Delivery Header
       ty_t_lips        TYPE STANDARD TABLE OF ty_lips,     " Delivery Items
       ty_t_vbreve      TYPE STANDARD TABLE OF vbreve,      " Revenue Recognition: Revenue Recognition Lines
       ty_t_bkpf        TYPE STANDARD TABLE OF ty_bkpf,     " Accounting Document Header
       ty_t_vbap        TYPE STANDARD TABLE OF ty_vbap,     " Sales Document Item
       ty_t_mkpf        TYPE STANDARD TABLE OF ty_mkpf,     " material Document Header
       ty_t_vbrp        TYPE STANDARD TABLE OF ty_vbrp,     " Invoice Items
* ---> Begin of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
       ty_t_vbrk        TYPE STANDARD TABLE OF ty_vbrk, " Invoice Header
* <--- End   of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
       ty_t_final       TYPE STANDARD TABLE OF ty_final,        " Final Table for ALV
       ty_t_emi         TYPE STANDARD TABLE OF zdev_enh_status. " Table Type for Enhancement Status

*&--Global Variables
DATA : gv_bukrs     TYPE bukrs,      " Company Code
       gv_budat     TYPE budat,      " Posting Date in the Document
       gv_vbeln     TYPE vbeln_va,   " Sales Document
       gv_sakrv     TYPE saknr,      " G/L Account Number
       gv_blart     TYPE bkpf-blart, " Document Type
       gv_col_pos   TYPE sycucol,    " Horizontal Cursor Position at PAI

*&--Global Internal Tables
       i_final       TYPE ty_t_final,          " Final Table for ALV
       i_fieldcat    TYPE slis_t_fieldcat_alv, " Field catalogue for ALV
       i_enh_status  TYPE ty_t_emi.            " Enhancement Status
