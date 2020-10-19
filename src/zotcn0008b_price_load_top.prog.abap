*&---------------------------------------------------------------------*
*&  Include     ZOTCC0008B_PRICE_LOAD_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0008_PRICE_LOAD_TOP                              *
* TITLE      :  OTC_CDD_0008_Price Load                                *
* DEVELOPER  :  Shammi Puri                                            *
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
* 05-June-2012 SPURI   E1DK901614  INITIAL DEVELOPMENT                 *
* 23-July-2012 SPURI   E1DK901614  CR100-Addition of amount column     *
* 12-Oct-2012  SPURI   E1DK906586  Defect:264 Inc ALV count Size /
*                                  Defect:267 Corrected selection
*                                  from table KNA1
* 23-Oct-2012  SPURI   E1DK906586  Defect 1025 . Make Buying group
*                                  mandatory for A901 and A904
* 29-Oct-2012  SPURI   E1DK906586  Defect 1177 . Add check to verify valid
*                                  buying group exist in table TVV1. Right
*                                  now Standard FM raises a error and it halts
*                                  the program. With the new change , it will
*                                  pass the record in error log
*09-Jan-2013   SPURI   E1DK906586  Defect 2390 Add condition table A911
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*TABLES                                                                *
*----------------------------------------------------------------------*
tables : zmdm_legcy_cross. " Legacy Cross Reference Table
*----------------------------------------------------------------------*
*CLASS                                                                 *
*----------------------------------------------------------------------*
class cl_abap_char_utilities definition load. " Class for tab Delimiter
*----------------------------------------------------------------------*
*TYPES                                                                 *
*----------------------------------------------------------------------*
types:  begin of ty_leg_tab,
               kappl   type  kappl,       "application
               kschl   type  kschl ,      "condition type
               vkorg   type  vkorg ,      "sales organization
               vtweg   type  vtweg ,      "distribution channel
               kunnr   type  kunnr ,      "Sold to party
               matnr   type  matnr ,      "material
               datab   type  char10 ,     "validity start date
               datbi   type  char10 ,     "validity end date
               prod    type  z_product_h4,"product hierarchy
               zzkvgr1 type  a901-zzkvgr1,"buying group
               zzkvgr2 type  a901-zzkvgr1,"IDN
               kbetr   type  komv-kbetr,  "Rate
               konwa   type  konp-konwa,  "Rate unit
               kpein   type  komv-kpein,  "Condition Price Unit
               kmein   type  komv-kmein,  "Condition Unit
         end of ty_leg_tab,





        begin of ty_005,
                       kappl type  kappl, "application
                       kschl type  kschl ,"condition type
                       vkorg type  vkorg ,"sales organization
                       vtweg type  vtweg ,"distribution channel
                       kunnr type  kunnr ,"Sold to party
                       matnr type  matnr ,"material
                       datab type  datum ,"validity start date
                       datbi type  datum ,"validity end date
                       kbetr   type  komv-kbetr,
                       konwa   type  konp-konwa,  "Rate unit
                       kpein   type  komv-kpein,  "Condition Price Unit
                       kmein   type  komv-kmein,  "Condition Unit

        end of ty_005,


        begin of ty_901,
                       kappl   type  kappl, "application
                       kschl   type  kschl ,"condition type
                       vkorg   type  vkorg ,"salesorganization
                       vtweg   type  vtweg ,"distribution channel
                       zzkvgr1 type  kvgr1, "buying group
                       matnr   type  matnr ,"material
                       datab   type  datum ,"validity start date
                       datbi   type  datum ,"validity end date
                       kbetr   type  komv-kbetr,
                       konwa   type  konp-konwa,  "Rate unit
                       kpein   type  komv-kpein,  "Condition Price Unit
                       kmein   type  komv-kmein,  "Condition Unit

        end of ty_901,


        begin of ty_903,
                       kappl   type  kappl,        "application
                       kschl   type  kschl ,       "condition type
                       vkorg   type  vkorg ,       "sales organization
                       vtweg   type  vtweg ,       "distribution channel
                       kunnr   type  kunnr ,       "Sold to party
                       prod    type  z_product_h4,"product hierarchy
                       datab   type  datum ,       "validity start date
                       datbi   type  datum ,        "validity end date
                       kbetr   type  komv-kbetr,
                       konwa   type  konp-konwa,  "Rate unit
                       kpein   type  komv-kpein,  "Condition Price Unit
                       kmein   type  komv-kmein,  "Condition Unit

        end of ty_903,

        begin of ty_904,
                       kappl   type  kappl ,      "application
                       kschl   type  kschl ,      "condition type
                       vkorg   type  vkorg ,      "sales organization
                       vtweg   type  vtweg ,      "distribution channel
                       zzkvgr1 type  kvgr1,       "buying group
                       prod    type  z_product_h4,"product hierarchy
                       datab   type  datum ,      "validity start date
                       datbi   type  datum ,      "validity end date
                       kbetr   type  komv-kbetr,
                       konwa   type  konp-konwa,  "Rate unit
                       kpein   type  komv-kpein,  "Condition Price Unit
                       kmein   type  komv-kmein,  "Condition Unit

        end of ty_904,

        begin of ty_902,
                       kappl   type  kappl ,      "application
                       kschl   type  kschl ,      "condition type
                       vkorg   type  vkorg ,      "sales organization
                       vtweg   type  vtweg ,      "distribution channel
                       zzkvgr2 type  kvgr2,       "IDN
                       matnr   type  matnr ,      "material
                       datab   type  datum ,      "validity start date
                       datbi   type  datum ,      "validity end date
                       kbetr   type  komv-kbetr,
                       konwa   type  konp-konwa,  "Rate unit
                       kpein   type  komv-kpein,  "Condition Price Unit
                       kmein   type  komv-kmein,  "Condition Unit

        end of ty_902,

        begin of ty_905,
                       kappl   type  kappl ,       "application
                       kschl   type  kschl ,       "condition type
                       vkorg   type  vkorg ,       "sales organization
                       vtweg   type  vtweg ,       "distribution channel
                       zzkvgr2 type  kvgr2,        " IDN
                       prod    type  z_product_h4, "product hierarchy
                       datab   type  datum ,       "validity start date
                       datbi   type  datum ,       "validity end date
                       kbetr   type  komv-kbetr,
                       konwa   type  konp-konwa,  "Rate unit
                       kpein   type  komv-kpein,  "Condition Price Unit
                       kmein   type  komv-kmein,  "Condition Unit

        end of ty_905,


        begin of ty_004,
                       kappl type  kappl ,          "application
                       kschl type  kschl ,          "condition type
                       vkorg type  vkorg ,          "sales organization
                       vtweg type  vtweg ,          "distribution channel
                       matnr type  matnr ,          "material
                       datab type  datum ,          "validity start date
                       datbi type  datum ,          "validity end date
                       kbetr   type  komv-kbetr,
                       konwa   type  konp-konwa,  "Rate unit
                       kpein   type  komv-kpein,  "Condition Price Unit
                       kmein   type  komv-kmein,  "Condition Unit

        end of ty_004,
*START DEFECT 2390 01/08/2013
        begin of ty_911,
                       kappl type  kappl, "application
                       kschl type  kschl ,"condition type
                       vkorg type  vkorg ,"sales organization
                       vtweg type  vtweg ,"distribution channel
                       kunnr type  kunnr ,"Ship to party
                       matnr type  matnr ,"material
                       datab type  datum ,"validity start date
                       datbi type  datum ,"validity end date
                       kbetr   type  komv-kbetr,  "Rate
                       konwa   type  konp-konwa,  "Rate unit
                       kpein   type  komv-kpein,  "Condition Price Unit
                       kmein   type  komv-kmein,  "Condition Unit

        end of ty_911,
*END DEFECT 2390 01/08/2013
         begin of ty_report,
            msgtyp type char1,                      "message type
            msgtxt type string,                     "message text
            key    type string,                     "message key
         end of ty_report,

          begin of ty_string ,
             string type string,                    "string file record
          end of ty_string,

          begin of ty_t685,
                  kschl type  kschl ,               "condition type
          end of ty_t685,

         begin of ty_tvko,
                  vkorg type  vkorg,               "sales organization
          end of ty_tvko,

         begin of ty_tvtw,
                  vtweg type  vtweg ,              "distribution channel
          end of ty_tvtw,

          begin of ty_kna1,
            kunnr type kna1-kunnr,                 "customer
            aufsd type kna1-aufsd,                 "block indicator
          end of ty_kna1,

          begin of ty_mvke,
            matnr type mvke-matnr,                "material
            vkorg type mvke-vkorg,                "sales organization
            vtweg type mvke-vtweg,                "distribution channel
          end of ty_mvke,

          ty_t_report type standard table of ty_report,"Report display

*START OF DEFECT 1177
          begin of ty_tvv1,
            KVGR1 type tvv1-KVGR1,                "Customer Group
          end of ty_tvv1.
*START OF DEFECT 1177



*----------------------------------------------------------------------*
*CONSTANTS                                                             *
*----------------------------------------------------------------------*
constants:
c_tab        type char1 value cl_abap_char_utilities=>horizontal_tab, " Horizontal Tab Stop Character
c_selected   type char1 value 'X',                                    " Constant char1 with value 'X'
c_extn       type char3 value 'TXT',                                  " Constant sring with value 'TXT'
c_tobeprscd  type char3 value 'TBP',                                  " TBP Folder
c_done_fold  type char4 value 'DONE',                                 " Done Folder
c_err_fold   type char5 value 'ERROR',                                " Error folder
c_error      type char1  value 'E',                                   " Error Indicator
c_mode_a(1)  type c      value 'A',                                   " Mode
c_004(3)     type c      value '004',                                 " Condition table 004
c_005(3)     type c      value '005',                                 " Condition table 005
c_901(3)     type c      value '901',                                 " Condition table 901
c_902(3)     type c      value '902',                                 " Condition table 902
c_903(3)     type c      value '903',                                 " Condition table 903
c_904(3)     type c      value '904',                                 " Condition table 904
c_905(3)     type c      value '905',                                 " Condition table 905
*START DEFECT 2390  01/08/2013
c_911(3)     type c      value '911'.                                 " Condition table 911
*END  2390 DEFECT 01/08/2013


*----------------------------------------------------------------------*
*GLOBAL DATA DECLERATIONS                                              *
*----------------------------------------------------------------------*
data:
gv_mkey       type string,       " key used in concaenation
gv_file       type localfile,    " Local file for upload/download
gv_mode       type char50,       " Character Field Length = 10
gv_subrc      type sy-subrc,     " Return Value of ABAP Statements
gv_header     type string,       " Header String
gv_filename   type localfile,    " Directory name
gv_no_success1 type int4,        " Failure counter
gv_error       type int4,        " Error Count
gv_skip       type int4,         " Skip Count
gv_tot        type int4,         " alv total count
gv_table      type t681-kotabnr, " condition table
gv_datab      type char10,       " date from
gv_datbi      type char10,       " date to
gv_return1    type c,            " indicator error
gv_fname      type string ,      " file name
gv_extn1      type string ,      " extension
gv_length     type i,            " length
gv_modify     type localfile,    " Input Data
gv_error_check type c  ,         " Error indicator
gv_total2       TYPE int4,       "Total Record "Defect 264++
gv_no_success2  TYPE int4,       "Succes       "Defect 264++
gv_no_failed2   TYPE int4.       "Failed       "Defect 264++


*----------------------------------------------------------------------*
*INTERNAL TABLES                                                       *
*----------------------------------------------------------------------*
data:
i_leg_tab           type standard table of ty_leg_tab initial size 0,"final table to load
i_leg_tab_temp      type standard table of ty_leg_tab initial size 0,"temp table to delete duplicates while doing select for all enteries
i_leg_tab_temp1     type standard table of ty_leg_tab initial size 0,"temp table to delete duplicates while doing select for all enteries "Defect 267++
i_leg_tab_err       type standard table of ty_leg_tab initial size 0,"error table
i_report            type ty_t_report,"alv report table
i_legacy_tab        type standard table of zzlegacy_ecc_translate initial size 0,"legacy to ECC material mapping table
i_string            type standard table of ty_string initial size 0, "input file table
i_t685              type standard table of ty_t685    initial size 0,"check table for t685
i_tvko              type standard table of ty_tvko    initial size 0,"check table for tvko
i_tvtw              type standard table of ty_tvtw    initial size 0,"check table for tvtw
i_mvke              type standard table of ty_mvke    initial size 0,"check table for imvke
i_kna1              type standard table of ty_kna1    initial size 0,"check table for kna1
*START OF DEFECT 1177
i_tvv1              type standard table of ty_tvv1    initial size 0."check table for kna1 ++DEFECT#1177
*END OF DEFECT 1177
*----------------------------------------------------------------------*
*  WORKAREAS                                                           *
*----------------------------------------------------------------------*
data:
wa_leg_tab      type ty_leg_tab, " final table workarea
wa_005          type ty_005, " workarea for condition record 005
wa_903          type ty_903, " workarea for condition record 903
wa_901          type ty_901, " workarea for condition record 901
wa_904          type ty_904, " workarea for condition record 904
wa_902          type ty_902, " workarea for condition record 902
wa_905          type ty_905, " workarea for condition record 905
wa_004          type ty_004, " workarea for condition record 004
*START DEFECT  2390 01/08/2013
wa_911          type ty_911, " workarea for condition record 911
*END DEFECT 2390 01/08/2013
wa_report       type ty_report," workarea for alv report
wa_legacy_tab   type zzlegacy_ecc_translate, " workarea for legacy table
wa_string       type ty_string," workarea for file record
wa_t685         type ty_t685,  " workarea for check table t685
wa_tvko         type ty_tvko,  " workarea for check table tvko
wa_tvtw         type ty_tvtw.  " workarea for check table tvtw
*----------------------------------------------------------------------*
*FIELD SYMBOLS                                                         *
*----------------------------------------------------------------------*
field-symbols : <fs_leg_tab>   type ty_leg_tab." final table field symbol
