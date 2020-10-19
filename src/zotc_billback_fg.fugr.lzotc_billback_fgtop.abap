************************************************************************
* PROGRAM    :  LZOTC_BILLBACK_FGTOP (Include)                         *
* TITLE      :  Billback Enhancement for Billing User Exit             *
* DEVELOPER  :  ANANYA DAS                                             *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0043                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Update Custom table with Billing informations when
* Invoice is created and Accounting documement is genarated
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 25-APR-2012  RNATHAK  E1DK901257 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 19-APR-2013  ADAS1    E1DK910010 D#3611: Refresh Global table & create
*                                  logic for mass upload               *
*&---------------------------------------------------------------------*
FUNCTION-POOL zotc_billback_fg.             "MESSAGE-ID ..

* Structure declaration of Convert External <  > Internal Partner No
TYPES:  BEGIN OF ty_edpar,
         kunnr TYPE kunnr,     " Customer no
         parvw TYPE parvw,     " Partner function
         expnr TYPE edi_expnr, " External partner no
       END OF   ty_edpar,

*      Structure declaration of Customer master
       BEGIN OF ty_kna1,
         kunnr TYPE kunnr, " Customer no
         bbbnr TYPE bbbnr, " International location number  (part 1)
         bbsnr TYPE bbsnr, " International location number  (part 2)
         bubkz TYPE bubkz, " Check digit for international location no
       END OF   ty_kna1,

*      Structure declaration of Material master: Sales
       BEGIN OF ty_mvke,
         matnr TYPE matnr,  " Material no
         vkorg TYPE vkorg,  " Sales Org
         vtweg TYPE vtweg,  " Distribution channel
         prdha TYPE prodh_d," Product Hierarchy
         prodh TYPE char4,  " Product Family
       END OF   ty_mvke,

*      Structure declaration for Billback
       BEGIN OF ty_billback,
         vbeln TYPE vbeln_vf," Billing Document
         posnr TYPE posnr_vf," Billing item
         matnr TYPE matnr,   " Material Number
         vkorg TYPE vkorg,   " Sales Organization
         vtweg TYPE vtweg,   " Distribution Channel
         kunag TYPE kunag,   " Sold-to party
         kunnr TYPE kunnr,   " Customer Number
         bstkd TYPE bstkd,   " Customer purchase order number
         prodh TYPE prodh_d, " Product hierarchy
         zzold_new_ind TYPE z_old_new_ind, " Old/New Sale indicator
       END OF   ty_billback,

       BEGIN OF ty_vbrk_vbrp,
         vbeln_s TYPE vbeln_va, " SO document
         posnr_s TYPE posnr_va, " SO item
         vbeln_b TYPE vbeln_vf, " Billing Document
         posnr_b TYPE posnr_vf, " Billing item
       END OF   ty_vbrk_vbrp,

       BEGIN OF ty_billback_org,
         vbeln TYPE vbeln,
         posnr TYPE posnr,
         fkimg TYPE fkimg,
       END OF   ty_billback_org.


* Table type declaration
TYPES: ty_t_zotc_billback TYPE STANDARD TABLE OF zotc_billback,
       " Billback table type
       ty_t_billback      TYPE STANDARD TABLE OF ty_billback,
       " Billback table type
       ty_t_vbpa          TYPE STANDARD TABLE OF vbpavb,
       " SD: Partner table type
       ty_t_edpar         TYPE STANDARD TABLE OF ty_edpar,
       " Conv: Internal<>External table type
       ty_t_kna1          TYPE STANDARD TABLE OF ty_kna1,
       " Customer master table type
       ty_t_mvke          TYPE STANDARD TABLE OF ty_mvke,
" Material master table type
       ty_t_vbrk_vbrp     TYPE STANDARD TABLE OF ty_vbrk_vbrp,
       " Billing doc header, item table type
       ty_t_billback_org  TYPE STANDARD TABLE OF ty_billback_org.

* Global Internal table declaration
DATA: i_zotc_billback  TYPE ty_t_zotc_billback," Billback table
      i_billback       TYPE ty_t_billback," Billback table
      i_vbpa           TYPE ty_t_vbpa,         " SD: Partner table
      i_edpar          TYPE ty_t_edpar,        " External cust no
      i_kna1           TYPE ty_t_kna1,         " Customer master
      i_mvke           TYPE ty_t_mvke,         " Material master:Sales
      i_vbrk_vbrp_bill TYPE ty_t_vbrk_vbrp,    " Billing doc & item
      i_vbrk_vbrp_so    TYPE ty_t_vbrk_vbrp,   " Sales doc & item
      i_billback_org   TYPE ty_t_billback_org.

* Global Workarea declaration
DATA: x_kuagv         TYPE kuagv,             " Sold-to-party
      x_kuwev         TYPE kuwev,             " Ship-to-party
      x_vbkd          TYPE vbkd.              " SD: Business data

DATA: gv_index        type sytabix.           " Index counting
      " ADD ADAS1 D#3611

* Global constant declaration
CONSTANTS: c_ship_to   TYPE parvw  VALUE 'WE', " Ship-to partner fn
           c_sign      TYPE sign   VALUE 'I',  " Implicit
           c_option    TYPE option VALUE 'EQ', " Equal
           c_invoice   TYPE vbtyp  VALUE 'M',  " Billing Type - Inv
           c_credit    TYPE vbtyp  VALUE 'O',  " Credit Memo
           c_debit     TYPE vbtyp  VALUE 'P',  " Debit Memo
           c_return    TYPE vbtyp  VALUE 'H',  " Return
           c_true      TYPE flag   VALUE 'X'.  " Check
* INCLUDE LZOTC_BILLBACK_FGD...              " Local class definition
