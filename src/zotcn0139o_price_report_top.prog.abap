***********************************************************************
*Program    : ZOTCN0139O_PRICE_REPORT_TOP                             *
*Title      : PRICE OVERRIDE REPORT_TOP                               *
*Developer  : Devendra Battala                                        *
*Object type: Report                                                  *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_RDD_0139                                           *
*---------------------------------------------------------------------*
*Description:  Business requires a report monthly, for Invoices, whose*
* prices, have been manually overridden. They need a report at an Item*
* level, which contains the details of the prices of such Invoices    *
* along with their Order details.                                     *
* As this is a huge extract, this is to be scheduled as a background  *
* job, and user can get the output in the system spool.               *                                                       *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport                     Description *
*=========== ============== ============== ===========================*
*14-Jun-2019  U105652       E2DK924628     SCTASK0840194: Initial     *
*                                          Development                *
*&--------------------------------------------------------------------*
*=========== ============== ============== ===========================*
*06-Aug-2019  U105652       E2DK924628    SCTASK0840194: Additional   *
*                                         Changes from constants part *
*                                         deleted constant c_e        *                                                                   *
*&--------------------------------------------------------------------*

TYPES:BEGIN OF ty_vbrk,
        vbeln    TYPE vbeln_vf,     " Billing Doucment
        fkart    TYPE fkart,        " Billing Type
        waerk    TYPE waerk,        " currency
        vkorg    TYPE vkorg,        " Sales Org
        knumv    TYPE knumv,        " Doc condition No
        fkdat    TYPE fkdat,        " Invoice Creation Date
        netwr    TYPE netwr,        " Net value
        erdat    TYPE erdat,        " Billing date
        kunag    TYPE kunag,        " Sold to party
        knuma    TYPE knuma,        " Agreement Information
        bstnk_vf TYPE bstkd,        " po#
      END OF ty_vbrk,

      BEGIN OF ty_vbrp,
        vbeln      TYPE vbeln_vf,   " Billing Document
        posnr      TYPE posnr_vf,   " Billing item
        fkimg      TYPE fkimg,      " Actual billed quantity
        netwr      TYPE netwr_fp,   " Net value of the billing item in document currency
        aubel      TYPE vbeln_va,   " Sales Document
        aupos      TYPE posnr_va,   " Sales Document Item
        matnr      TYPE matnr,      " Material Number
        zzquoteref TYPE z_quoteref, " quntity ref number

      END OF ty_vbrp,
      BEGIN OF ty_vbak,
        vbeln    TYPE vbeln_va,     " Sales Document
        erdat    TYPE erdat,        " Date on Which Record Was Created
        ernam    TYPE ernam,        " Name of Person Who Created the Object
        auart    TYPE auart,        " Sales Document Type
        vkbur    TYPE vkbur,        " Sales Office
        zzdocref TYPE z_docref,     " Legacy Doc Ref
        zzdoctyp TYPE z_doctyp,     " Ref Doc type
      END OF ty_vbak,

      BEGIN OF ty_vbap,
        vbeln TYPE vbeln_va,        " Sales Document
        posnr TYPE posnr_va,        " Sales Document Item
        matkl TYPE matkl,           " Material Group
        werks TYPE werks,           " Plant (Own or External)
        prctr TYPE prctr,           " Profit Center
      END OF ty_vbap,

      BEGIN OF ty_t023,
        spras TYPE spras,           " Language Key
        matkl TYPE matkl,           " Material Group description
        wgbez TYPE wgbez,           " Material Group Description
      END OF ty_t023,

      BEGIN OF ty_konv,
        knumv TYPE knumv,           " Number of the document condition
        kposn TYPE kposn,           " Condition item number
        kschl TYPE kscha,           " Condition Type
        kbetr TYPE kbetr,           " Rate (condition amount or percentage)
        waers TYPE waers,           " Currency Key
        ksteu TYPE ksteu,           " Condition control
      END OF ty_konv,

      BEGIN OF ty_vbpa,
        vbeln TYPE vbeln,           " Sales and Distribution Document Number
        posnr TYPE posnr,           " Sales Item Number
        parvw TYPE parvw,           " Profit Center
        kunnr TYPE kunnr,           " Customer Number
      END OF ty_vbpa,
      BEGIN OF ty_kna1,
        kunnr TYPE kunnr,           " Customer Number
        name1 TYPE name1_gp,        " Name 1
      END OF ty_kna1,

      BEGIN OF ty_cepct,
        spras TYPE spras,           " Language Key
        prctr TYPE prctr,           " profit center
        ktext TYPE ktext,           " General Name
      END OF ty_cepct,

      BEGIN OF ty_makt,
        matnr TYPE matnr,           " Material Number
        spras TYPE spras,           " Language Key
        maktx TYPE maktx,           " Material Description
      END OF ty_makt,


      BEGIN OF ty_final,
        vbeln      TYPE vbeln_vf,   " Billing Doucment
        posnr      TYPE posnr_vf,   " Billing item
        knumv      TYPE knuma,      " Agreement Information
        fkimg      TYPE fkimg,      " Actual billed quantity
        vrkme      TYPE vrkme,      " unit for quantity
        netwr      TYPE netwr_fp,   " Net value of the billing item in document currency
        erdat      TYPE char10,      " Date on Which Record Was Created
        aubel      TYPE vbeln_va,   " Sales Document
        aupos      TYPE posnr_va,   " Sales Document Item
        zzquoteref TYPE z_quoteref, " quntity ref number
        zzdocref   TYPE z_docref,   " Legacy Doc Ref
        zzdoctyp   TYPE z_doctyp,   " Ref Doc type
        werks      TYPE werks,      " plant
        prctr      TYPE prctr,      " Profit Center
        ktext      TYPE ktext,      " General text
        matnr      TYPE matnr,      " Material Number
        maktx      TYPE maktx,      " Material Description
        matkl      TYPE matkl,      " Material Group
        wgbez      TYPE matkl,      " Material Group description
        erdat1     TYPE char10,      " Creation Date
        kbetr      TYPE kbetr,      " Rate (condition amount or percentage)
        ksteu      TYPE ksteu,      " Condition control
        vkorg      TYPE vkorg,      " Sales Org
        fkart      TYPE fkart,      " Billing Type
        waerk      TYPE waerk,      " currency
        fkdat      TYPE char10,      " Invoice Creation Date
        netwr1     TYPE netwr,      " Net value
        kunag      TYPE kunag,      " Sold To Party
        name1      TYPE name1_gp,   " Name1
        ernam      TYPE ernam,      " Name of Person Who Created the Object
        auart      TYPE auart,      " Sales Document Type
        bstnk_vf   TYPE bstkd,      " PO#
        vkbur      TYPE vkbur,      " Sales Office
        kunnr      TYPE kunnr,      " Customer number
        name12     TYPE name1_gp,   " Name
      END OF ty_final.
DATA:
  i_vbrk     TYPE STANDARD TABLE OF ty_vbrk,  " Internal table of vbrk
  i_vbrp     TYPE STANDARD TABLE OF ty_vbrp,  " Internal table of vbrp
  i_vbak     TYPE STANDARD TABLE OF ty_vbak,  " Internal table of vbak
  i_vbap     TYPE STANDARD TABLE OF ty_vbap,  " Internal table of vbap
  i_t023     TYPE STANDARD TABLE OF ty_t023,  " Internal table of t023
  i_konv     TYPE STANDARD TABLE OF ty_konv,  " Internal table of konv
  i_kna1     TYPE STANDARD TABLE OF ty_kna1,  " Internal table of kna1
  i_cepct    TYPE STANDARD TABLE OF ty_cepct, " Internal table of cepct
  i_makt     TYPE STANDARD TABLE OF ty_makt,  " Internal table of makt
  i_vbpa     TYPE STANDARD TABLE OF ty_vbpa,  " Internal table of vbpa
  i_final    TYPE STANDARD TABLE OF ty_final, " Internal table of final
  i_emikschl TYPE STANDARD TABLE OF fkk_ranges, " Structure: Select Options
  gv_bity    TYPE fkart,                      " Billing type
  gv_sorg    TYPE vkorg,                      " Sales org
  gv_disch   TYPE vtweg,                      " Distribution Channel
  gv_records TYPE syst_dbcnt.                 " Table Rows



TYPES:ty_t_vbrk     TYPE STANDARD TABLE OF ty_vbrk INITIAL SIZE 0,  " Table type of vbrk
      ty_t_vbrp     TYPE STANDARD TABLE OF ty_vbrp INITIAL SIZE 0,  " Table type of vbrp
      ty_t_vbak     TYPE STANDARD TABLE OF ty_vbak INITIAL SIZE 0,  " Table type of vbak
      ty_t_vbap     TYPE STANDARD TABLE OF ty_vbap INITIAL SIZE 0,  " Table type of vbap
      ty_t_t023     TYPE STANDARD TABLE OF ty_t023 INITIAL SIZE 0,  " Table type of t023
      ty_t_konv     TYPE STANDARD TABLE OF ty_konv INITIAL SIZE 0,  " Table type of konv
      ty_t_kna1     TYPE STANDARD TABLE OF ty_kna1 INITIAL SIZE 0,  " Table type of kna1
      ty_t_cepct    TYPE STANDARD TABLE OF ty_cepct INITIAL SIZE 0, " Table type of cepct
      ty_t_makt     TYPE STANDARD TABLE OF ty_makt INITIAL SIZE 0,  " Table type of makt
      ty_t_vbpa     TYPE STANDARD TABLE OF ty_vbpa INITIAL SIZE 0,  " Table type of vbpa
      ty_t_final    TYPE STANDARD TABLE OF ty_final INITIAL SIZE 0, " Table type of final
      ty_t_emikschl TYPE STANDARD TABLE OF fkk_ranges INITIAL SIZE 0.

CONSTANTS:
  c_enh_num TYPE z_enhancement VALUE 'OTC_RDD_0139', " Enhancement No.

*->Begin of delete for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
*   c_e       TYPE char1 VALUE 'E'.  " Error
*<-End of delete for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
  c_eq      TYPE char2 VALUE 'EQ', " Equal
  c_i       TYPE char1 VALUE 'I'.  " Integer
