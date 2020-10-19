*&---------------------------------------------------------------------*
*&  Include           ZOTCN0092O_AR_AGING_REPORT_TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZOTCR0092O_AR_AGING_REPORT
************************************************************************
* PROGRAM    :  ZOTCN0092O_AR_AGING_REPORT_TOP                         *
* TITLE      :  AR Aging Report                                        *
* DEVELOPER  :  Sneha/Moushumi/Sayantan                                *
* OBJECT TYPE:  Report                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID: D2_OTC_RDD_0092
*----------------------------------------------------------------------*
* DESCRIPTION: AR Aging Report
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER      TRANSPORT      DESCRIPTION                   *
* ===========  ========   =========  ==================================*
* 18-Mar-2016  SMUKHER/   E2DK917181  AR Aging Report                  *
* 18-Jul-2016  U034192   E2DK918411  Defect #1804(SCTASK0357514).     *
*                                    DATA DECLARATION:                 *
*                                     Customer Group( KNKK- KDGRP) and *
*                                    Assignment(BSAD-ZUONR/BSID -ZUONR)*
* 13-Oct-2017 MGARG/     E1DK931620  Defect#2646:                      *
*             SGHOSH                 1.Execute AR Report for mutiple   *
*                                    company codes.                    *
*                                    2. FSCM Disptue Case ID field to  *
*                                    be added.                         *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
CONSTANTS: c_shkzg TYPE shkzg VALUE 'H'. " Debit/Credit Indicator

******************************************************************
"Global variable declaration for selection fields
******************************************************************
DATA: gv_reconn TYPE knb1-akont,  " Reconciliation Account in General Ledger
      gv_kunnr  TYPE kunnr,       " Customer number
      gv_bukrs  TYPE bukrs,       " Company code
      gv_sbgrp  TYPE t024b-sbgrp, " Credit representative group for credit management
      gv_knkli  TYPE kna1-kunnr.  " Customer's account number with credit limit reference

******************************************************************
"Structure declaration for range fields
******************************************************************
TYPES:BEGIN OF ty_reccon,
        sign   TYPE char1,     " Sign of type CHAR1
        option TYPE char2,     " Option of type CHAR2
        low    TYPE akont,     " Reconciliation Account in General Ledger
        high   TYPE akont,     " Reconciliation Account in General Ledger
      END OF ty_reccon,

      BEGIN OF ty_kunnr,
        sign   TYPE char1,     " Sign of type CHAR1
        option TYPE char2,     " Option of type CHAR2
        low    TYPE kunnr,     " Customer Number
        high   TYPE kunnr,     " Customer Number
      END OF ty_kunnr,

      BEGIN OF ty_bukrs,
        sign   TYPE char1,     " Sign of type CHAR1
        option TYPE char2,     " Option of type CHAR2
        low    TYPE bukrs,     " Company Code
        high   TYPE bukrs,     " Company Code
      END OF ty_bukrs,

      BEGIN OF ty_comp,
        bukrs TYPE bukrs,      " Company Code
      END OF ty_comp,

      BEGIN OF ty_sbgrp,
        sign   TYPE char1,     " Sign of type CHAR1
        option TYPE char2,     " Option of type CHAR2
        low    TYPE sbgrp_cm,  " Credit representative group for credit management
        high   TYPE sbgrp_cm,  " Credit representative group for credit management
      END OF ty_sbgrp,

      BEGIN OF ty_knkli,
        sign   TYPE char1,     " Sign of type CHAR1
        option TYPE char2,     " Option of type CHAR2
        low    TYPE knkli,     " Customer's account number with credit limit reference
        high   TYPE knkli,     " Customer's account number with credit limit reference
      END OF ty_knkli,

       BEGIN OF ty_knb1,
         kunnr TYPE kunnr,     "Customer Number
         bukrs TYPE bukrs,     "Company Code
         akont TYPE akont,     "Reconciliation Account in General Ledger
       END OF ty_knb1,

       BEGIN OF ty_t001,
         bukrs TYPE bukrs,     "Company Code
         waers TYPE waers,     "Currency Key
         kkber TYPE kkber,     "Credit Control Area
       END OF ty_t001,

       BEGIN OF ty_knkk,
         kunnr  TYPE kunnr,    "Customer Number
         kkber  TYPE kkber,    "Credit Control Area
         klimk  TYPE klimk,    "Customer's credit limit
         knkli  TYPE knkli,    "Customer's account number with credit limit reference
         skfor  TYPE skfor,    "Total receivables (for credit limit check)
         ctlpc  TYPE ctlpc_cm, "Credit management: Risk category
         dtrev  TYPE dtrev_cm, "Last internal review
         sbgrp  TYPE sbgrp_cm, "Credit representative group for credit management
         nxtrv  TYPE nxtrv_cm, "Next internal review
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
         kdgrp  TYPE kdgrp_cm, "Customer Group
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
         bukrs  TYPE bukrs,        "Company Code
         waers  TYPE waers,        "Local Currency Key
       END OF ty_knkk,

       BEGIN OF ty_kna1,
        kunnr  TYPE kunnr,         "Customer Number
        land1  TYPE land1_gp,      "Country Key
        name1  TYPE name1_gp,      "Name 1
       END OF ty_kna1,

       BEGIN OF ty_bsid,
         bukrs  TYPE  bukrs,       "Company Code
         kunnr  TYPE kunnr,        "Customer Number
         umsks  TYPE umsks,        " Transaction Type
         umskz  TYPE umskz,        "Special G/L Indicator
         augdt  TYPE augdt,        "Clearing Date
         augbl  TYPE augbl,        "Document Number of the Clearing Document
         zuonr  TYPE dzuonr,       "Assignment Number
         gjahr  TYPE gjahr,        "Fiscal Year
         belnr  TYPE belnr_d,      "Accounting Document Number
         buzei  TYPE buzei,        "Number of Line Item Within Accounting Document
         budat  TYPE budat,        "Posting Date in the Document
         bldat  TYPE bldat,        "Document Date in Document
         cpudt  TYPE cpudt,        "Day On Which Accounting Document Was Entered
         blart  TYPE blart,        "Document Type
         waers  TYPE waers,        "Currency Key
         xblnr  TYPE xblnr1,       "Reference Document Number
         monat  TYPE monat,        "Fiscal Period
         bschl  TYPE bschl,        "Posting Key
         shkzg  TYPE shkzg,        "Debit/Credit Indicator
         mwskz  TYPE mwskz,        "Tax on sales/purchases code
         dmbtr  TYPE dmbtr,        "Amount in Local Currency
         wrbtr  TYPE wrbtr,        "Amount in Document Currency
         sgtxt  TYPE sgtxt,        "Item Text
         hkont  TYPE hkont,        "General Ledger Account
         zfbdt  TYPE dzfbdt,       "Baseline Date for Due Date Calculation
         zterm  TYPE dzterm,       "Terms of Payment Key
         zbd1t  TYPE dzbd1t,       "Cash Discount Days 1
         zbd2t  TYPE dzbd2t,       "Cash Discount Days 2
         rebzg  TYPE rebzg,        "Number of the Invoice the Transaction Belongs to
         vbeln  TYPE vbeln_vf,     "Billing Document
         xref1  TYPE xref1,        "Business Partner Reference Key
         xref2  TYPE xref2,        "Business Partner Reference Key
         prctr  TYPE prctr,        "Profit Center
       END OF ty_bsid,

       BEGIN OF ty_bsad,
         bukrs  TYPE  bukrs,       "Company Code
         kunnr  TYPE kunnr,        "Customer Number
         umsks  TYPE umsks,        "Transaction Type
         umskz  TYPE umskz,        "Special G/L Indicator
         augdt  TYPE augdt,        "Clearing Date
         augbl  TYPE augbl,        "Document Number of the Clearing Document
         zuonr  TYPE dzuonr,       "Assignment Number
         gjahr  TYPE gjahr,        "Fiscal Year
         belnr  TYPE belnr_d,      "Accounting Document Number
         buzei  TYPE buzei,        "Number of Line Item Within Accounting Document
         budat  TYPE budat,        "Posting Date in the Document
         bldat  TYPE bldat,        "Document Date in Document
         cpudt  TYPE cpudt,        "Day On Which Accounting Document Was Entered
         blart  TYPE blart,        "Document Type
         waers  TYPE waers,        "Currency Key
         xblnr  TYPE xblnr1,       "Reference Document Number
         monat  TYPE monat,        "Fiscal Period
         bschl  TYPE bschl,        "Posting Key
         shkzg  TYPE shkzg,        "Debit/Credit Indicator
         mwskz  TYPE mwskz,        "Tax on sales/purchases code
         dmbtr  TYPE dmbtr,        "Amount in Local Currency
         wrbtr  TYPE wrbtr,        "Amount in Document Currency
         sgtxt  TYPE sgtxt,        "Item Text
         hkont  TYPE hkont,        "General Ledger Account
         zfbdt  TYPE dzfbdt,       "Baseline Date for Due Date Calculation
         zterm  TYPE dzterm,       "Terms of Payment Key
         zbd1t  TYPE dzbd1t,       "Cash Discount Days 1
         zbd2t  TYPE dzbd2t,       "Cash Discount Days 2
         rebzg  TYPE rebzg,        "Number of the Invoice the Transaction Belongs to
         vbeln  TYPE vbeln_vf,     "Billing Document
         xref1  TYPE xref1,        "Business Partner Reference Key
         xref2  TYPE xref2,        "Business Partner Reference Key
         prctr  TYPE prctr,        "Profit Center
       END OF ty_bsad,

       BEGIN OF ty_final_det,
          bukrs   TYPE bukrs,      "Company Code
          kunnr   TYPE kunnr,      "Customer Number
          land1   TYPE land1_gp,   "Country Key
          name1   TYPE name1_gp,   "Name 1
          hkont   TYPE hkont,      "General Ledger Account
          bschl   TYPE bschl,      "Posting Key
          blart   TYPE blart,      "Document Type
          belnr   TYPE belnr_d,    "Accounting Document Number
          xblnr   TYPE xblnr1,     "Reference Document Number
          dmbtr   TYPE dmbtr,      "Amount in Local Currency
          balance TYPE dmbtr,      "Balance
          waers   TYPE waers,      "Local Currency Key
          not_due TYPE dmbtr,      "Not Due
          calc1   TYPE dmbtr,      "amount calculations for 0-30days,
          calc2   TYPE dmbtr,      "amount calculations for 1-30days
          calc3   TYPE dmbtr,      "amount calculations for 31-60days,
          calc4   TYPE dmbtr,      "amount calculations for 61-90days
          calc5   TYPE dmbtr,      "amount calculations for 91-120days,
          calc6   TYPE dmbtr,      "amount calculations for 121-150days
          wrbtr   TYPE wrbtr,      "Amount in Document Currency
          waers1  TYPE waers,      "Currency Key
          bldat   TYPE bldat,      "Document Date in Document
          budat   TYPE budat,      "Posting Date in the Document
          cpudt   TYPE cpudt,      "Day On Which Accounting Document Was Entered
          augdt   TYPE augdt,      "Clearing Date
          augbl   TYPE augbl,      "Document Number of the Clearing Document
          zfbdt   TYPE dzfbdt,     "Baseline Date for Due Date Calculation
          zterm   TYPE dzterm,     "Terms of Payment Key
          mwskz   TYPE mwskz,      "Tax on sales/purchases code
          prctr   TYPE prctr,      "Profit Center
          rebzg   TYPE rebzg,      "Number of the Invoice the Transaction Belongs to
          vbeln   TYPE vbeln_vf,   "Billing Document
          aubel   TYPE vbeln_va,   "Sales Document
          bstnk	  TYPE bstnk,	     "Customer purchase order number
          bsark   TYPE bsark,      "Customer purchase order type
          umskz   TYPE umskz,      "Special G/L Indicator
          xref1   TYPE xref1,      "Business Partner Reference Key
          xref2   TYPE xref2,      "Business Partner Reference Key
          sgtxt   TYPE sgtxt,      "Item Text
          kkber   TYPE kkber,      "Credit Control Area
          knkli   TYPE knkli,      "Customer's account number with credit limit reference
          klimk   TYPE klimk,      "Customer's credit limit
          oblig   TYPE oblig_f02l, "Credit exposure (for credit limit check)
          klprz   TYPE klprz_f02l, "Credit limit used
          ctlpc   TYPE ctlpc_cm,   "Credit management: Risk category
          horda   TYPE horda_f02l, "Date of credit horizon
          skfor   TYPE skfor,      "Total receivables (for credit limit check)
          oeikw   TYPE mc_oeikw,   "Open sales order credit value (schedule lines)
          olikw   TYPE mc_olikw,   "Open delivery credit value
          ofakw   TYPE mc_ofakw,   "Open billing document credit value
          dtrev   TYPE dtrev_cm,   "Last internal review
          nxtrv   TYPE nxtrv_cm,   "Next internal review
          sbgrp   TYPE sbgrp_cm,   "Credit representative group for credit management
          stext   TYPE stext_cm,   "Name of the credit representative group
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
          kdgrp   TYPE kdgrp_cm, " Customer Group Name
          zuonr   TYPE dzuonr,   " Assignment number
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
**-->Begin of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
          case_id TYPE scmg_ext_ref, " External reference
**<--End of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
        END OF ty_final_det,

        BEGIN OF ty_vbrp,
          vbeln TYPE vbeln_vf, "Billing Document
          posnr TYPE posnr_vf, "Billing item
          aubel TYPE vbeln_va, "Sales Document
        END OF ty_vbrp,

        BEGIN OF ty_vbak,
          vbeln TYPE vbeln_va, "Sales Document
          bstnk	TYPE bstnk,	   "Customer purchase order number
          bsark	TYPE bsark,	   "Customer purchase order type
        END OF ty_vbak,

        BEGIN OF ty_t024b,
          sbgrp TYPE sbgrp_cm, "Credit representative group for credit management
          kkber TYPE kkber,    "Credit Control Area
          stext TYPE stext_cm, "Name of the credit representative group
        END OF ty_t024b.

***********************************************************
*&-- Table types Declarations....
***********************************************************
TYPES: ty_t_knb1      TYPE STANDARD TABLE OF ty_knb1      INITIAL SIZE 0,
       ty_t_t001      TYPE STANDARD TABLE OF ty_t001      INITIAL SIZE 0,
       ty_t_knkk      TYPE STANDARD TABLE OF ty_knkk      INITIAL SIZE 0,
       ty_t_kna1      TYPE STANDARD TABLE OF ty_kna1      INITIAL SIZE 0,
       ty_t_bsid      TYPE STANDARD TABLE OF ty_bsid      INITIAL SIZE 0,
       ty_t_bsad      TYPE STANDARD TABLE OF ty_bsad      INITIAL SIZE 0,
       ty_t_vbrp      TYPE STANDARD TABLE OF ty_vbrp      INITIAL SIZE 0,
       ty_t_vbak      TYPE STANDARD TABLE OF ty_vbak      INITIAL SIZE 0,
       ty_t_024b      TYPE STANDARD TABLE OF ty_t024b     INITIAL SIZE 0,
       ty_t_final_det TYPE STANDARD TABLE OF ty_final_det INITIAL SIZE 0,
       ty_t_reccon    TYPE STANDARD TABLE OF ty_reccon    INITIAL SIZE 0,
       ty_t_kunnr     TYPE STANDARD TABLE OF ty_kunnr     INITIAL SIZE 0,
       ty_t_bukrs     TYPE STANDARD TABLE OF ty_bukrs     INITIAL SIZE 0,
       ty_t_sbgrp     TYPE STANDARD TABLE OF ty_sbgrp     INITIAL SIZE 0,
       ty_t_knkli     TYPE STANDARD TABLE OF ty_knkli     INITIAL SIZE 0.

***********************************************************
*&-- Internal Table Declarations...
***********************************************************
DATA: i_knb1       TYPE STANDARD TABLE OF ty_knb1,
      i_t001       TYPE STANDARD TABLE OF ty_t001,
      i_knkk       TYPE STANDARD TABLE OF ty_knkk,
      i_kna1       TYPE STANDARD TABLE OF ty_kna1,
      i_bsid       TYPE STANDARD TABLE OF ty_bsid,
      i_bsad       TYPE STANDARD TABLE OF ty_bsid,
      i_vbrp       TYPE STANDARD TABLE OF ty_vbrp,
      i_vbak       TYPE STANDARD TABLE OF ty_vbak,
      i_t024b      TYPE STANDARD TABLE OF ty_t024b,
      i_final_det  TYPE STANDARD TABLE OF ty_final_det,
      i_comp       TYPE STANDARD TABLE OF ty_comp,
      i_fieldcat   TYPE slis_t_fieldcat_alv, " Fieldcatalog Internal tab
      i_listheader TYPE slis_t_listheader.   " List header internal tab

***********************************************************
*&-- Date declarations...
***********************************************************
DATA:   gv_date30    TYPE datum,   " Start Date
        gv_date31    TYPE datum,   " Start Date
        gv_date60    TYPE datum,   " Start Date
        gv_date61    TYPE datum,   " Start Date
        gv_date90    TYPE datum,   " Start Date
        gv_date91    TYPE datum,   " Start Date
        gv_date120   TYPE datum,   " Start Date
        gv_date121   TYPE datum,   " Start Date
        gv_date150   TYPE datum,   " Start Date
        gv_date151   TYPE datum,   " Start Date
        gv_ucomm     TYPE syucomm. " Function code that PAI triggered
