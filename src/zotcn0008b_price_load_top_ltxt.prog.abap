*&---------------------------------------------------------------------*
*&  Include     ZOTCC0008B_PRICE_LOAD_TOP_LTXT
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0008_PRICE_LOAD_TOP_LTXT                          *
* TITLE      :  OTC_CDD_0008_Price Load                                *
* DEVELOPER  :  Nagamani N M                                           *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_CDD_0008_Price Load
*----------------------------------------------------------------------*
* DESCRIPTION:
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
*16-Aug-2013   NNM     E1DK911313  INITIAL DEVELOPMENT: CR700:
*                                  Copied from program
*                                  ZOTCN0008B_PRICE_LOAD_TOP.
*                                  Change of Input file format - common
*                                  for all Condition Record Tables.
*                                  Addition of Internal Comment in VK11
*
*5-May-2014 PROUT   E1DK913354   CR#1289:The requirement is to update the
*                                condition record instead of creating a new
*                                record and also have the functionality
*                                of mark the records for deletion
*                                which is VK12 functionality
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*TABLES                                                                *
*----------------------------------------------------------------------*
TABLES : zmdm_legcy_cross. " Legacy Cross Reference Table
*----------------------------------------------------------------------*
*CLASS                                                                 *
*----------------------------------------------------------------------*
CLASS cl_abap_char_utilities DEFINITION LOAD. " Class for tab Delimiter
*----------------------------------------------------------------------*
*TYPES                                                                 *
*----------------------------------------------------------------------*
TYPES:  BEGIN OF ty_leg_tab,
               kappl   TYPE  kappl,       "application
               kschl   TYPE  kschl ,      "condition type
               vkorg   TYPE  vkorg ,      "sales organization
               vtweg   TYPE  vtweg ,      "distribution channel
               kunnr   TYPE  kunnr ,      "Sold to party
               matnr   TYPE  matnr ,      "material
               datab   TYPE  char10,     " validity start date
               datbi   TYPE  char10 ,     "validity end date
               prod    TYPE  z_product_h4,"product hierarchy
               zzkvgr1 TYPE  a901-zzkvgr1,"buying group
               zzkvgr2 TYPE  a901-zzkvgr1,"IDN
               kbetr   TYPE  komv-kbetr,  "Rate
               konwa   TYPE  konp-konwa,  "Rate unit
               kpein   TYPE  komv-kpein,  "Condition Price Unit
               kmein   TYPE  komv-kmein,  "Condition Unit
               ltx01 TYPE ltext72, "Long text line    "CR#700 ++
               txt_ind TYPE char1, " Text indicator
               knumh TYPE knumh,  "Cond rec no. "CR#700 ++
               tabname   TYPE datkz,       "Condition Record Table Name
**&& -- BOC : CR# 1289 : PROUT : 05-MAY-2014
               parameter TYPE char1, "Parameter
**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
         END OF ty_leg_tab,
         ty_t_leg_tab TYPE STANDARD TABLE OF ty_leg_tab,  "CR#700 ++

*&&-- Begin of CR#700
        BEGIN OF ty_file,
*          blank1    TYPE char1, "Blank column in excel file
          kappl     TYPE kappl, "application
          kschl     TYPE kschl ,"condition type
*          blank2    TYPE char1, "Blank column in excel file
          vkorg     TYPE vkorg ,"sales organization
          vtweg     TYPE vtweg ,"distribution channel
          field1    TYPE matnr,    "Field1
          fld1_desc TYPE maktx, "Field1 Description
          field2    TYPE matnr, "Field2
          fld2_desc TYPE maktx,  "Field2 Description
          city      TYPE ort01_gp, "City
          buy_grp   TYPE kvgr1,   "Byuing Group
          buy_desc  TYPE bezei20,  "Byuing Group Desc
          idn_code  TYPE kvgr2,  "IDN Code
          idn_desc  TYPE bezei20,  "IDN Desc
          gpo_code  TYPE kdgrp,  "GPO Code
          gpo_desc  TYPE vtxtk,  "GPO Code Desc
          cust_cls  TYPE kukla,  "Customer Class
          cust_desc TYPE bezei20, "Customer Class Desc

          datab     TYPE datum ,      "validity start date
          datbi     TYPE datum ,      "validity end date
          kbetr     TYPE kbetr,       "Rate (condition amount or %)
          konwa     TYPE konwa,       "Rate unit
          kpein     TYPE kpein,       "Condition Price Unit
          kmein     TYPE kvmei,       "Condition Unit

          sale_rep  TYPE kunn2,       "Sales Rep
          sale_desc TYPE name1_gp,    "Sales Rep Desc
          ltx01     TYPE ltext72,     "Internal Comment
          txt_ind   TYPE char1,       "Internal Comment Indicator
          tabname   TYPE datkz,       "Condition Record Table Name

          kunnr     TYPE kunnr ,      "Customer No
          matnr     TYPE matnr ,      "material no
          zzkvgr1   TYPE kvgr1,       "buying group
          prod      TYPE z_product_h4,"product hierarchy
          zzkvgr2   TYPE kvgr2,       "IDN
**&& -- BOC : CR# 1289 : PROUT : 05-MAY-2014
          parameter TYPE char1,       "Parameter
**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
        END OF ty_file,
*&&-- End of CR#700

        BEGIN OF ty_005,
                       kappl TYPE  kappl, "application
                       kschl TYPE  kschl ,"condition type
                       vkorg TYPE  vkorg ,"sales organization
                       vtweg TYPE  vtweg ,"distribution channel
                       kunnr TYPE  kunnr ,"Sold to party
                       matnr TYPE  matnr ,"material
                       datbi TYPE  kodatbi,"validity end date
                       datab TYPE  kodatab ,"validity start date
                       knumh TYPE  knumh ,
*                       ltx01 TYPE ltext72, "Long text line
        END OF ty_005,

        BEGIN OF ty_901,
                       kappl   TYPE  kappl, "application
                       kschl   TYPE  kschl ,"condition type
                       vkorg   TYPE  vkorg ,"salesorganization
                       vtweg   TYPE  vtweg ,"distribution channel
                       zzkvgr1 TYPE  kvgr1, "buying group
                       matnr   TYPE  matnr ,"material
                       kfrst   TYPE  kfrst, "release status
                       datbi   TYPE  kodatbi ,"validity end date
                       datab   TYPE  kodatab ,"validity start date
                       knumh   TYPE  knumh,
        END OF ty_901,

        BEGIN OF ty_902,
                       kappl   TYPE  kappl ,      "application
                       kschl   TYPE  kschl ,      "condition type
                       vkorg   TYPE  vkorg ,      "sales organization
                       vtweg   TYPE  vtweg ,      "distribution channel
                       zzkvgr2 TYPE  kvgr2,       "IDN
                       matnr   TYPE  matnr ,      "material
                       datbi   TYPE  kodatbi ,      "validity end date
                       datab   TYPE  kodatab,      "validity start date
                       knumh   TYPE  knumh,
        END OF ty_902,

*        BEGIN OF ty_905,
*                       kappl   TYPE  kappl ,       "application
*                       kschl   TYPE  kschl ,       "condition type
*                       vkorg   TYPE  vkorg ,       "sales organization
*                       vtweg   TYPE  vtweg ,       "distribution channel
*                       zzkvgr2 TYPE  kvgr2,        " IDN
*                       prod    TYPE  z_product_h4, "product hierarchy
*                       datab   TYPE  datum ,       "validity start date
*                       datbi   TYPE  datum ,       "validity end date
*                       kbetr   TYPE  komv-kbetr,
*                       konwa   TYPE  konp-konwa,  "Rate unit
*                       kpein   TYPE  komv-kpein,  "Condition Price Unit
*                       kmein   TYPE  komv-kmein,  "Condition Unit
*        END OF ty_905,

        BEGIN OF ty_004,
                       kappl TYPE  kappl ,          "application
                       kschl TYPE  kschl ,          "condition type
                       vkorg TYPE  vkorg ,          "sales organization
                       vtweg TYPE  vtweg ,          "distribution channel
                       matnr TYPE  matnr ,          "material
                       datbi TYPE  kodatbi ,          "validity end date
                       datab TYPE  kodatab,          "validity start date
                       knumh TYPE  knumh ,
        END OF ty_004,

        BEGIN OF ty_911,
                       kappl TYPE  kappl, "application
                       kschl TYPE  kschl ,"condition type
                       vkorg TYPE  vkorg ,"sales organization
                       vtweg TYPE  vtweg ,"distribution channel
                       kunwe TYPE  kunwe ,"Ship to party
                       matnr TYPE  matnr ,"material
                       kfrst TYPE  kfrst, "Release status
                       datbi TYPE  kodatbi ,"validity end date
                       datab TYPE  kodatab ,"validity start date
                       knumh TYPE  knumh,
        END OF ty_911,

        BEGIN OF ty_konp,
         knumh  TYPE knumh, "Condition record number
         kopos  TYPE kopos, "Sequential number of the condition
        END OF ty_konp,

*END DEFECT 2390 01/08/2013
         BEGIN OF ty_report,
            msgtyp TYPE char1,                      "message type
            msgtxt TYPE string,                     "message text
            key    TYPE string,                     "message key
         END OF ty_report,

          BEGIN OF ty_string ,
             string TYPE string,                    "string file record
          END OF ty_string,

          BEGIN OF ty_t685,
                  kschl TYPE  kschl ,               "condition type
          END OF ty_t685,

         BEGIN OF ty_tvko,
                  vkorg TYPE  vkorg,               "sales organization
          END OF ty_tvko,

         BEGIN OF ty_tvtw,
                  vtweg TYPE  vtweg ,              "distribution channel
          END OF ty_tvtw,

          BEGIN OF ty_kna1,
            kunnr TYPE kna1-kunnr,                 "customer
            aufsd TYPE kna1-aufsd,                 "block indicator
          END OF ty_kna1,

          BEGIN OF ty_mvke,
            matnr TYPE mvke-matnr,                "material
            vkorg TYPE mvke-vkorg,                "sales organization
            vtweg TYPE mvke-vtweg,                "distribution channel
          END OF ty_mvke,

          ty_t_report TYPE STANDARD TABLE OF ty_report,"Report display

*START OF DEFECT 1177
          BEGIN OF ty_tvv1,
            kvgr1 TYPE tvv1-kvgr1,                "Customer Group
          END OF ty_tvv1.
*START OF DEFECT 1177
**&& -- BOC : CR# 1289 : PROUT : 05-MAY-2014
TYPES:  ty_bdcdata type bdcdata,                         "BDC Data
        ty_bdcmsgcoll type bdcmsgcoll,                       " BDC message
        ty_t_bdcmsgcoll  type standard table of ty_bdcmsgcoll,   " BDC message
        ty_t_bdcdata type standard table of ty_bdcdata,  "BDC Data
**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
        ty_t_konp TYPE STANDARD TABLE OF ty_konp,
        ty_t_komv TYPE STANDARD TABLE OF komv. " KOMV Structure

*----------------------------------------------------------------------*
*CONSTANTS                                                             *
*----------------------------------------------------------------------*
CONSTANTS:
c_tab        TYPE char1 VALUE cl_abap_char_utilities=>horizontal_tab, " Horizontal Tab Stop Character
c_selected   TYPE char1 VALUE 'X',                                    " Constant char1 with value 'X'
c_extn       TYPE char3 VALUE 'TXT',                                  " Constant sring with value 'TXT'
c_tobeprscd  TYPE char3 VALUE 'TBP',                                  " TBP Folder
c_done_fold  TYPE char4 VALUE 'DONE',                                 " Done Folder
c_err_fold   TYPE char5 VALUE 'ERROR',                                " Error folder
c_error      TYPE char1  VALUE 'E',                                   " Error Indicator
c_mode_a(1)  TYPE c      VALUE 'A',                                   " Mode
c_004(3)     TYPE c      VALUE '004',                                 " Condition table 004
c_005(3)     TYPE c      VALUE '005',                                 " Condition table 005
c_901(3)     TYPE c      VALUE '901',                                 " Condition table 901
c_902(3)     TYPE c      VALUE '902',                                 " Condition table 902
c_903(3)     TYPE c      VALUE '903',                                 " Condition table 903
c_904(3)     TYPE c      VALUE '904',                                 " Condition table 904
c_905(3)     TYPE c      VALUE '905',                                 " Condition table 905
*START DEFECT 2390  01/08/2013
c_911(3)     TYPE c      VALUE '911',                                 " Condition table 911
*END  2390 DEFECT 01/08/2013
**&& -- BOC : CR# 1289 : PROUT : 05-MAY-2014
gc_transaction TYPE sytcode VALUE 'VK12'.                             " Transaction VK12
**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
*----------------------------------------------------------------------*
*GLOBAL DATA DECLERATIONS                                              *
*----------------------------------------------------------------------*
DATA:
gv_mkey       TYPE string,       " key used in concaenation
gv_file       TYPE localfile,    " Local file for upload/download
gv_mode       TYPE char50,       " Character Field Length = 10
gv_subrc      TYPE sy-subrc,     " Return Value of ABAP Statements
gv_header     TYPE string,       " Header String
gv_date_from  TYPE datum,        " From date
gv_date_to    TYPE datum,        " To date
gv_filename   TYPE localfile,    " Directory name
gv_no_success1 TYPE int4,        " Failure counter
gv_error       TYPE int4,        " Error Count
gv_skip       TYPE int4,         " Skip Count
gv_tot        TYPE int4,         " alv total count
gv_tot1      TYPE int4,
gv_table      TYPE t681-kotabnr, " condition table
gv_datab      TYPE char10,       " date from
gv_datbi      TYPE char10,       " date to
gv_return1    TYPE c,            " indicator error
gv_fname      TYPE string ,      " file name
gv_extn1      TYPE string ,      " extension
gv_length     TYPE i,            " length
gv_modify     TYPE localfile,    " Input Data
gv_error_check TYPE c  ,         " Error indicator
gv_tdline       TYPE tdline,
gv_knumh        TYPE tdobname,
gv_total2       TYPE int4,       "Total Record "Defect 264++
gv_no_success2  TYPE int4,       "Succes       "Defect 264++
gv_no_failed2   TYPE int4.       "Failed       "Defect 264++


*----------------------------------------------------------------------*
*INTERNAL TABLES                                                       *
*----------------------------------------------------------------------*
DATA:
i_leg_tab           TYPE STANDARD TABLE OF ty_leg_tab INITIAL SIZE 0,"final table to load
i_leg_tab_temp      TYPE STANDARD TABLE OF ty_leg_tab INITIAL SIZE 0,"temp table to delete duplicates while doing select for all enteries
i_leg_tab_temp1     TYPE STANDARD TABLE OF ty_leg_tab INITIAL SIZE 0,"temp table to delete duplicates while doing select for all enteries "Defect 267++
i_leg_tab_err       TYPE STANDARD TABLE OF ty_leg_tab INITIAL SIZE 0,"error table
i_report            TYPE ty_t_report,"alv report table
i_legacy_tab        TYPE STANDARD TABLE OF zzlegacy_ecc_translate INITIAL SIZE 0,"legacy to ECC material mapping table
i_string            TYPE STANDARD TABLE OF ty_string INITIAL SIZE 0, "input file table
i_t685              TYPE STANDARD TABLE OF ty_t685    INITIAL SIZE 0,"check table for t685
i_tvko              TYPE STANDARD TABLE OF ty_tvko    INITIAL SIZE 0,"check table for tvko
i_tvtw              TYPE STANDARD TABLE OF ty_tvtw    INITIAL SIZE 0,"check table for tvtw
i_mvke              TYPE STANDARD TABLE OF ty_mvke    INITIAL SIZE 0,"check table for imvke
i_kna1              TYPE STANDARD TABLE OF ty_kna1    INITIAL SIZE 0,"check table for kna1
*START OF DEFECT 1177
i_tvv1              TYPE STANDARD TABLE OF ty_tvv1    INITIAL SIZE 0,"check table for kna1 ++DEFECT#1177
*END OF DEFECT 1177
i_005               TYPE STANDARD TABLE OF ty_005 INITIAL SIZE 0,
i_004               TYPE STANDARD TABLE OF ty_004 INITIAL SIZE 0,
i_911               TYPE STANDARD TABLE OF ty_911 INITIAL SIZE 0,
i_901               TYPE STANDARD TABLE OF ty_901 INITIAL SIZE 0,
i_902               TYPE STANDARD TABLE OF ty_902 INITIAL SIZE 0,
i_konp              TYPE STANDARD TABLE OF ty_konp INITIAL SIZE 0.
*----------------------------------------------------------------------*
*  WORKAREAS                                                           *
*----------------------------------------------------------------------*
DATA:
wa_leg_tab      TYPE ty_leg_tab, " final table workarea
**&&-- Begin of Comment for CR#700
**wa_005          TYPE ty_005, " workarea for condition record 005
**wa_903          TYPE ty_903, " workarea for condition record 903
**wa_901          TYPE ty_901, " workarea for condition record 901
**wa_904          TYPE ty_904, " workarea for condition record 904
**wa_902          TYPE ty_902, " workarea for condition record 902
**wa_905          TYPE ty_905, " workarea for condition record 905
**wa_004          TYPE ty_004, " workarea for condition record 004
***START DEFECT  2390 01/08/2013
**wa_911          TYPE ty_911, " workarea for condition record 911
**END DEFECT 2390 01/08/2013
*&&-- End of Comment for CR#700
wa_report       TYPE ty_report," workarea for alv report
wa_legacy_tab   TYPE zzlegacy_ecc_translate, " workarea for legacy table
wa_string       TYPE ty_string," workarea for file record
wa_t685         TYPE ty_t685,  " workarea for check table t685
wa_tvko         TYPE ty_tvko,  " workarea for check table tvko
wa_tvtw         TYPE ty_tvtw.  " workarea for check table tvtw

*----------------------------------------------------------------------*
*FIELD SYMBOLS                                                         *
*----------------------------------------------------------------------*
FIELD-SYMBOLS : <fs_leg_tab>   TYPE ty_leg_tab." final table field symbol
