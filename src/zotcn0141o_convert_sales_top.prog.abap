*&---------------------------------------------------------------------*
* PROGRAM     : ZOTCR0141O_CONVERT_SALES_TOP                           *
* TITLE       :  Reconciliation Report                                 *
*                                                                      *
* DEVELOPER   :  Khushboo Mishra                                        *
* OBJECT TYPE :  ALV report                                             *
* SAP RELEASE :  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_CDD_0141                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Top Include                        *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT  DESCRIPTION                        *
* ===========  ========  ========== ===================================*
* 05/16/2016   KMISHRA   E1DK917543 Initial Development
* ===========  ========  ========== ===================================*
*&---------------------------------------------------------------------*
****************************CONSTANT DECLARATION***********************
CONSTANTS:
      c_msgty      TYPE symsgty VALUE 'I', "Information msg type
      c_save       TYPE char1   VALUE 'A'. "used in alv for user save

***************************TYPES DECLARATION***************************
TYPES:
    BEGIN OF ty_vbak,
      vbeln      TYPE vbeln_va,     " Sales Document
      erdat      TYPE erdat,        " Date on Which Record Was Created
      auart      TYPE auart,        " Sales Document Type
      vkorg      TYPE vkorg,        " Sales Organization
      vtweg      TYPE vtweg,        " Distribution Channel
      spart      TYPE spart,        " Division
      vkbur      TYPE vkbur,        " Sales Office
      zzdocref   TYPE	z_docref,     " Legacy Doc Ref
      zzdoctyp   TYPE z_doctyp,     " Ref Doc type
    END OF ty_vbak,

    BEGIN OF ty_vbap,
      vbeln      TYPE vbeln_va,     " Sales Document
      posnr      TYPE posnr_va,     " Sales Document Item
      matnr      TYPE matnr,        " Material Number
      pstyv      TYPE pstyv,        " Sales document item category
      zmeng      TYPE dzmeng,       " Target quantity in sales units
      zieme      TYPE dzieme,       " Target quantity UoM
      netwr      TYPE netwr_ap,     " Net value of the order item in document currency
      waerk      TYPE waerk,        " SD Document Currency
      kwmeng     TYPE kwmeng,       " Cumulative Order Quantity in Sales Units
      vrkme      TYPE vrkme,        " Sales unit
      werks      TYPE werks_ext,    " Plant (Own or External)
      zzagmnt	   TYPE z_agmnt,      " Warr / Serv Plan ID
      zzagmnt_typ TYPE z_agmnt_typ, " ID Type
      zzitemref	 TYPE z_itemref,    " ServMax Obj ID
      zzquoteref TYPE	z_quoteref,   " Legacy Qtn Ref
      zz_bilmet	 TYPE z_bmethod,    " Billing Method
      zz_bilfr   TYPE z_bfrequency, " Billing Frequency
    END OF ty_vbap,

    BEGIN OF ty_vbpa,
      vbeln TYPE vbeln,             " Sales and Distribution Document Number
      posnr TYPE posnr,             " Item number of the SD document
      parvw TYPE parvw,             " Partner Function
      kunnr TYPE kunnr,             " Customer Number
    END OF ty_vbpa,

    BEGIN OF ty_ser02,
      obknr TYPE objknr,            " Object list number
      sdaufnr TYPE vbeln_va,        " Sales Document
      posnr   TYPE posnr_va,        " Sales Document Item
    END OF ty_ser02,

    BEGIN OF ty_objk,
      obknr TYPE objknr,            " Object list number
      sernr TYPE gernr,             " Serial Number
    END OF ty_objk,

    BEGIN OF ty_veda,
     vbeln       TYPE vbeln_va,     " Sales Document
     vposn       TYPE posnr_va ,    " Sales Document Item
     vbegdat     TYPE vbdat_veda,   "Contract start date
     venddat     TYPE vndat_veda,   "Contract end date
    END OF ty_veda,

    BEGIN OF ty_final,
     zzdocref    TYPE z_docref,     " Legacy Doc Ref
     zzdoctyp    TYPE z_doctyp,     " Ref Doc type
     auart       TYPE auart,        " Sales Document Type
     vbeln       TYPE vbeln_va,     " Sales Document
     vkorg       TYPE vkorg,        " Sales Organization
     vtweg       TYPE vtweg,        " Distribution Channel
     spart       TYPE spart,        " Division
     vkbur       TYPE vkbur,        " Sales Office
     zsoldto     TYPE kunnr,        " Customer Number
     zshipto     TYPE kunnr,        " Customer Number
     zbillto     TYPE kunnr,        " Customer Number
     zpayer      TYPE kunnr,        " Customer Number
     vbegdat     TYPE vbdat_veda,   "Contract start date
     venddat     TYPE vndat_veda,   "Contract end date
     vbegdat_h   TYPE vbdat_veda,   "Contract start date
     venddat_h   TYPE vndat_veda,   "Contract end date
     posnr       TYPE posnr_va,     " Sales Document Item
     matnr       TYPE matnr,        " Material Number
     werks       TYPE werks_ext,    " Plant (Own or External)
     pstyv       TYPE pstyv,        " Sales document item category
     zmeng       TYPE dzmeng,       " Target quantity in sales units
     zieme       TYPE dzieme,       " Target quantity UoM
     kwmeng      TYPE kwmeng,       " Cumulative Order Quantity in Sales Units
     vrkme       TYPE vrkme,        " Sales unit
     netwr       TYPE netwr_ap,     " Net value of the order item in document currency
     waerk       TYPE waerk,        " SD Document Currency
     vbegdat_i  TYPE vbdat_veda,    "Contract start date
     venddat_i   TYPE vndat_veda,   "Contract end date
     zzagmnt     TYPE z_agmnt,      " Warr / Serv Plan ID
     zzagmnt_typ TYPE z_agmnt_typ,  " ID Type
     zzitemref   TYPE z_itemref,    " ServMax Obj ID
     zzquoteref  TYPE	z_quoteref,   " Legacy Qtn Ref
     zz_bilmet   TYPE z_bmethod,    " Billing Method
     zz_bilfr    TYPE z_bfrequency, " Billing Frequency
     sernr      TYPE gernr,         " Serial Number
    END OF  ty_final,

    BEGIN OF ty_s_vkorg,
    sign   TYPE  char1,             " Sign of type CHAR1
    option TYPE  char2,             " Option of type CHAR2
    high   TYPE vkorg,              " Sales Organization
    low    TYPE vkorg,              " Sales Organization
    END OF ty_s_vkorg,

    BEGIN OF ty_s_vtweg,
    sign   TYPE  char1,             " Sign of type CHAR1
    option TYPE  char2,             " Option of type CHAR2
    high   TYPE vtweg,              " Distribution Channel
    low    TYPE vtweg,              " Distribution Channel
    END OF ty_s_vtweg,

    BEGIN OF ty_s_auart,
    sign   TYPE  char1,             " Sign of type CHAR1
    option TYPE  char2,             " Option of type CHAR2
    high   TYPE auart,              " Sales Document Type
    low    TYPE auart,              " Sales Document Type
    END OF ty_s_auart,

    ty_t_s_vkorg TYPE STANDARD TABLE OF ty_s_vkorg,
    ty_t_s_vtweg TYPE STANDARD TABLE OF ty_s_vtweg,
    ty_t_s_auart TYPE STANDARD TABLE OF ty_s_auart,
    ty_t_final TYPE STANDARD TABLE OF ty_final,
    ty_t_vbak  TYPE STANDARD TABLE OF ty_vbak,
    ty_t_vbap  TYPE STANDARD TABLE OF ty_vbap,
    ty_t_vbpa  TYPE STANDARD TABLE OF ty_vbpa,
    ty_t_ser02 TYPE STANDARD TABLE OF ty_ser02,
    ty_t_objk  TYPE STANDARD TABLE OF ty_objk,
    ty_t_veda  TYPE STANDARD TABLE OF ty_veda.
***************************VARIABLE DECLARATION************************
DATA:
      gv_vkorg    TYPE vkorg,             " Sales Organization
      gv_vtweg    TYPE vtweg,             " Distribution Channel
      gv_auart    TYPE auart,             " Sales Document Type
      gv_erdat    TYPE erdat,             " Date on Which Record Was Created
      gv_prog_name TYPE syrepid ##needed, " ABAP Program: Current Main Program
      gv_docref   TYPE z_docref.          "##NEEDED" Legacy Doc Ref


***************************INTERNAL TABLE DECLARATION******************
DATA:   i_vbak        TYPE ty_t_vbak ##needed,
        i_vbap        TYPE ty_t_vbap ##needed,
        i_vbpa        TYPE ty_t_vbpa ##needed,
        i_ser02       TYPE ty_t_ser02 ##needed,
        i_objk        TYPE ty_t_objk ##needed,
        i_veda        TYPE ty_t_veda ##needed,
        i_final       TYPE ty_t_final ##needed,
        i_listheader  TYPE slis_t_listheader ##needed,    "List header internal tab
        i_fieldcat    TYPE slis_t_fieldcat_alv ##needed , "Fieldcatalog Internal tab
        i_sort        TYPE slis_t_sortinfo_alv ##needed.

CONSTANTS:c_spart TYPE char5 VALUE '00'. " Spart of type CHAR5
