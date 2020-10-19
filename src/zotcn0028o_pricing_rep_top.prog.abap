*&---------------------------------------------------------------------*
*&  Include         ZOTCN0028O_PRICING_REP_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :      ZOTCN0028O_PRICING_REP_TOP                          *
* TITLE      :  Pricing Report for Mass Price Upload                   *
* DEVELOPER  :  Vinita Choudhary                                       *
* OBJECT TYPE:  Include                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_RDD_0028_Pricing Report for Mass Price Upload      *
*----------------------------------------------------------------------*
* DESCRIPTION: This is an include program of Report                    *
*              ZOTCR0028O_PRICING_REPORT_NEW, Data Declaration.

*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 22-Jul-2015 VCHOUDH   E2DK914250 INITIAL DEVELOPMENT -               *
*&---------------------------------------------------------------------*
* 30-June-2017 MGARG  E1DK928877  Defect#3034:  Sales rep Filteration  *
*                                 logic updated                        *
*&---------------------------------------------------------------------*
*28-Oct-2019 RNATHAK E2DK927757 INC0524176-01 : Performance Issue fix
************************************************************************

**  Data declaration for the variables and tables used in the program.


TYPE-POOLS : rsds,abap.

TYPES : BEGIN OF ty_knvp_temp,
          kunnr TYPE  knvp-kunnr, " Customer Number
          vkorg TYPE  knvp-vkorg, " Sales Organization
          vtweg TYPE  knvp-vtweg, " Distribution Channel
        END OF ty_knvp_temp.

TYPES : BEGIN OF ty_knvp,
          kunnr TYPE knvp-kunnr,  " Customer Number
          vkorg TYPE knvp-vkorg,  " Sales Organization
          vtweg TYPE knvp-vtweg,  " Distribution Channel
          spart TYPE knvp-spart,  " Division
          parvw TYPE knvp-parvw, " Partner Function
          parza TYPE knvp-parza,  " Partner counter
          kunn2 TYPE knvp-kunn2,  " Customer number of business partner
        END OF ty_knvp.

TYPES : BEGIN OF ty_konp,
          knumh    TYPE   konp-knumh, " Condition record number
          kopos    TYPE   konp-kopos, " Sequential number of the condition
          kappl    TYPE   konp-kappl, " Application
          kschl    TYPE   konp-kschl, " Condition type
          stfkz    TYPE   konp-stfkz, " Scale Type
          kzbzg    TYPE   konp-kzbzg, " Scale basis indicator
          kstbm    TYPE   konp-kstbm, " Condition scale quantity
          konws    TYPE   konp-konws, " Scale currency
          kbetr    TYPE   konp-kbetr, " Rate (condition amount or percentage) where no scale exists
*  Begin of Change for Defect#913 by SAGARWA1
          konwa    TYPE   konwa, " Rate unit (currency or percentage)
*  End   of Change for Defect#913 by SAGARWA1
          kpein    TYPE   konp-kpein,    " Condition pricing unit
          kmein    TYPE   konp-kmein,    " Condition unit
          prsch    TYPE   konp-prsch,    " Scale Group
          kwaeh    TYPE   kwaeh,         " Condition currency (for cumulation fields)
          loevm_ko TYPE   konp-loevm_ko, " Deletion Indicator for Condition Item
        END OF ty_konp.



TYPES : BEGIN OF ty_scale,
          knumh TYPE    konp-knumh, " Condition record number
          kstbm TYPE    konp-kstbm, " Condition scale quantity
          konms TYPE    konp-konms, " Condition scale unit of measure
          konwa TYPE    konp-konwa, " Rate unit (currency or percentage)
          kbetr TYPE    konp-kbetr, " Rate (condition amount or percentage) where no scale exists
          konws TYPE     konp-konws, " Scale currency
          kpein TYPE    konp-kpein, " Condition pricing unit
          kmein TYPE    konp-kmein, " Condition unit
        END OF ty_scale.

TYPES : BEGIN OF ty_dd04t,
          rollname   TYPE  dd04t-rollname,   " Data element (semantic domain)
          ddlanguage TYPE  dd04t-ddlanguage, " Language Key
          as4local   TYPE  dd04t-as4local,   " Activation Status of a Repository Object
          as4vers    TYPE  dd04t-as4vers,    " Version of the entry (not used)
          scrtext_l  TYPE  dd04t-scrtext_l,  " Long Field Label
        END OF ty_dd04t.


TYPES : BEGIN OF ty_dd03l ,
          tabname   TYPE  dd03l-tabname,   " Table Name
          fieldname TYPE  dd03l-fieldname, " Field Name
          as4local  TYPE  dd03l-as4local,  " Activation Status of a Repository Object
          as4vers   TYPE  dd03l-as4vers,   " Version of the entry (not used)
          position  TYPE  dd03l-position,  " Position of the field in the table
          rollname  TYPE  dd03l-rollname,  " Data element (semantic domain)
        END OF ty_dd03l.


TYPES : BEGIN OF ty_fdtl,
          tabname   TYPE  dd03l-tabname,   " Table Name
          fieldname TYPE  dd03l-fieldname, " Field Name
          rollname  TYPE  dd03l-rollname,  " Data element (semantic domain)
          scrtext_l TYPE  dd04t-scrtext_l, " Long Field Label
        END OF ty_fdtl.

*----------------------------------------------------------------------*
*    Internal Tables
*----------------------------------------------------------------------*
DATA : i_dd03l TYPE TABLE OF ty_dd03l,
       i_dd04t TYPE TABLE OF ty_dd04t,
*&-- Begin of changes for D3_OTC_RDD_0028 INC0524176-01 by RNATHAK on 28-Oct-2019
*        i_fdtl TYPE TABLE OF ty_fdtl.
       i_fdtl  TYPE STANDARD TABLE OF ty_fdtl.
*&-- End of changes for D3_OTC_RDD_0028 INC0524176-01 by RNATHAK on 28-Oct-2019

DATA : gt_tab           TYPE REF TO data,      "  class
       gs_row           TYPE REF TO data,      "  class
       gt_tab_str       TYPE REF TO data,  "  class
       gt_tdesc         TYPE REF TO data,    "  class
       gs_rdesc         TYPE REF TO data,    "  class
       wa_row_str       TYPE REF TO data,  "  class
       gt_tab_temp      TYPE REF TO data, "  class
*--> Begin of Insert for D2_OTC_RDD_0028/Defect 913 by VCHOUDH.
       gt_tab_temp1     TYPE REF TO data, "  class
*<-- End of Insert for D2_OTC_RDD_0028/Defect913 by VCHOUDH.
*---> Begin of Insert for D3_OTC_RDD_0028_Defect#3034 by MGARG
       gt_tab_temp_srep TYPE REF TO data, "  class
*---> End of Insert for D3_OTC_RDD_0028_Defect#3034 by MGARG
       gs_row_temp      TYPE REF TO data. "  class


*----------------------------------------------------------------------*
*    Work-Area
*----------------------------------------------------------------------*

DATA : wa_dd03l TYPE  ty_dd03l.
DATA : wa_fdtl  TYPE ty_fdtl,
       wa_dd04t TYPE ty_dd04t.

FIELD-SYMBOLS: <gfs_dd04t> TYPE  ty_dd04t.
FIELD-SYMBOLS : <gfs_fdtl> TYPE ty_fdtl.
DATA : wa_tmc1t TYPE tmc1t. " Short Texts on Generated DDIC Structures

*----------------------------------------------------------------------*
*    Data
*----------------------------------------------------------------------*

DATA : gv_table TYPE tabname. " Table Name

DATA : gv_val_index TYPE sy-tabix. " Index of Internal Tables

DATA : gv_kappl TYPE char04, " Kappl of type CHAR04
       gv_kschl TYPE char6.  " Kschl of type CHAR6

DATA : gv_tab_counter TYPE i . " Tab_counter of type Integers


*----------------------------------------------------------------------*
*    Constants.
*----------------------------------------------------------------------*
DATA : c_kbetr    TYPE char10 VALUE 'KBETR',         " Kbetr of type CHAR10
       c_kbetr_de TYPE char15 VALUE 'KBETR_KOND', " Kbetr_de of type CHAR15
       c_counter  TYPE char10 VALUE 'ZCOUNTER',    " Counter of type CHAR10
       c_kschl    TYPE char10 VALUE 'KSCHL',        " Kschl of type CHAR10
       c_kotabnr  TYPE char10 VALUE 'KOTABNR',     " Kotabnr of type CHAR10
       c_kunnr    TYPE char10 VALUE 'KUNNR' ,      " Kunnr of type CHAR10
       c_kunn2    TYPE char10 VALUE 'KUNN2',       " Kunn2 of type CHAR10
       c_kstbm    TYPE char10 VALUE 'KSTBM',         " Kstbm of type CHAR10
       c_konms    TYPE char10 VALUE 'KONMS',         " Konms of type CHAR10
       c_kbetr1   TYPE char10 VALUE 'KBETR1',       " Kbetr1 of type CHAR10
       c_konws    TYPE char10 VALUE 'KONWS',         " Konws of type CHAR10
       c_kpein    TYPE char10 VALUE 'KPEIN',        " Kpein of type CHAR10
       c_kmein    TYPE char10 VALUE 'KMEIN',        " Kmein of type CHAR10
       c_loevm_ko TYPE char10 VALUE 'LOEVM_KO'  , " Loevm_ko of type CHAR10
       c_vkorg    TYPE char10 VALUE 'VKORG' ,       " Vkorg of type CHAR10
       c_vtweg    TYPE char10 VALUE 'VTWEG',         " Vtweg of type CHAR10
       c_knvp     TYPE char10 VALUE 'KNVP',           " Knvp of type CHAR10
       c_knumh    TYPE char10 VALUE 'KNUMH',         " Knumh of type CHAR10
       c_konp     TYPE char10 VALUE 'KONP',          " Konp of type CHAR10
       c_mandt    TYPE char10 VALUE 'MANDT',         " Mandt of type CHAR10
       c_kappl    TYPE char10 VALUE 'KAPPL' .        " Kappl of type CHAR10

*  Begin of Change for Defect#913 by SAGARWA1
CONSTANTS : c_datbi        TYPE char10 VALUE 'DATBI',  " Datbi of type CHAR10
            c_matnr        TYPE char10 VALUE 'MATNR',  " Matnr of type CHAR10
            c_maktx        TYPE char10 VALUE 'MAKTX',  " Maktx of type CHAR10
            c_table        TYPE char10 VALUE 'ZTABLE', " Table of type CHAR10
*--> Begin of Addition for D2_OTC_RDD_0028/Defect 1191 by VCHOUDH
            c_record       TYPE char10 VALUE 'ZRECORD',         " Record of type CHAR10
            c_zrecord      TYPE char5 VALUE 'CHAR2',           " Zrecord of type CHAR5
            c_kukla        TYPE char10 VALUE 'KUKLA',            " Kukla of type CHAR10
            c_kdgrp        TYPE char10 VALUE 'KDGRP',            " Kdgrp of type CHAR10
            c_zzkvgr1      TYPE char10 VALUE 'ZZKVGR1',       " Zzkvgr1 of type CHAR10
            c_zzkvgr2      TYPE char10 VALUE 'ZZKVGR2',       " Zzkvgr2 of type CHAR10
            c_kukla_desc_d TYPE char10 VALUE 'BEZEI20',   " Kukla_desc_d of type CHAR10
            c_kukla_desc   TYPE char12 VALUE 'KUKLA_DESC', " Kukla_desc of type CHAR12
            c_record_txt   TYPE char15 VALUE 'ZTEXT',       " Record_txt of type CHAR15
            c_zrecord_txt  TYPE char10 VALUE 'CHAR72',     " Zrecord_txt of type CHAR10
*<-- End of Addition for D2_OTC_RDD_0028/Defect 1191 by VCHOUDH.

            c_konwa        TYPE char10 VALUE 'KONWA',       " Konwa of type CHAR10
            c_ztable       TYPE char10 VALUE 'CHAR1',      " Ztable of type CHAR10
            c_kodatbi      TYPE char10 VALUE 'KODATBI' . " Kodatbi of type CHAR10
DATA      : gv_datab TYPE char10. " Datab of type CHAR10

*  End   of Change for Defect#913 by SAGARWA1


*----------------------------------------------------------------------*
*    Field-Symbol
*----------------------------------------------------------------------*

FIELD-SYMBOLS : <gfs_tab>           TYPE STANDARD TABLE,
                <gfs_tab_temp>      TYPE STANDARD TABLE,
                <gfs_tab_temp1>     TYPE STANDARD TABLE,
*---> Begin of Insert for D3_OTC_RDD_0028_Defect#3034 by MGARG
                <gfs_tab_temp_srep> TYPE STANDARD TABLE,
*---> End of Insert for D3_OTC_RDD_0028_Defect#3034 by MGARG
                <gfs_tab_str>       TYPE STANDARD TABLE,
                <gfs_row>           TYPE any,
                <gfs_row_str>       TYPE any,
                <gfs_row_temp>      TYPE any,
                <gfs_fld>           TYPE any,
                <gfs_tdesc>         TYPE STANDARD TABLE,
                <gfs_rdesc>         TYPE any,
                <gfs_desc>          TYPE any.

*----------------------------------------------------------------------*
*  Defintions for Dynamic Structures **
*----------------------------------------------------------------------*

DATA : i_tab             TYPE REF TO cl_abap_tabledescr,        " Runtime Type Services
       i_tab_str         TYPE REF TO cl_abap_tabledescr,    " Runtime Type Services
       wa_row            TYPE REF TO cl_abap_structdescr,      " Runtime Type Services
       wa_frow           TYPE REF TO cl_abap_structdescr,     " Runtime Type Services
       wa_frow_str       TYPE REF TO cl_abap_structdescr, " Runtime Type Services
       i_component       TYPE cl_abap_structdescr=>component_table,
       wa_component      TYPE cl_abap_structdescr=>component,
       i_component_temp  TYPE cl_abap_structdescr=>component_table,
       wa_component_temp TYPE cl_abap_structdescr=>component,
*       i_comp_desc type cl_abap_structdescr=>component_table,
*       wa_comp_desc TYPE cl_abap_structdescr=>component ,
       i_component_str   TYPE cl_abap_structdescr=>component_table,
       wa_component_str  TYPE cl_abap_structdescr=>component.



*----------------------------------------------------------------------*
*  Defintions for ALV Grid
*----------------------------------------------------------------------*

DATA : gv_table_alv TYPE REF TO cl_salv_table. " Basis Class for Simple Tables

DATA : gv_columns_alv TYPE REF TO cl_salv_columns_table, " Columns in Simple, Two-Dimensional Tables
       gv_column_alv  TYPE REF TO cl_salv_column_table,  " Column Description of Simple, Two-Dimensional Tables
       i_columns_alv  TYPE salv_t_column_ref,
       wa_columns_alv TYPE salv_s_column_ref,            " Column of ALV List
       gv_domname_alv TYPE domname.                      " Domain name

DATA : gv_functions_alv TYPE REF TO cl_salv_functions_list. " Generic and User-Defined Functions in List-Type Tables

DATA : gv_layout_alv     TYPE REF TO cl_salv_layout, " Settings for Layout
       gv_layout_key_alv TYPE salv_s_layout_key.    " Layout Key

DATA : gv_content_alv TYPE REF TO cl_salv_form_element. " General Element in Design Object



*----------------------------------------------------------------------*
*  Defintions for Free Selection.
*----------------------------------------------------------------------*


DATA : i_tables   TYPE STANDARD TABLE OF rsdstabs,     " Tables and any differing field names for dynamic selections
       wa_tables  TYPE rsdstabs,                      " Tables and any differing field names for dynamic selections
       i_fields   TYPE STANDARD TABLE OF rsdsfields,   " Selected fields for dynamic selections
       wa_fields  TYPE rsdsfields,                    " Selected fields for dynamic selections
       i_fields_n TYPE STANDARD TABLE OF rsdsfields. " Selected fields for dynamic selections


DATA : gv_sid  TYPE dynselid,       " Dynamic selection ID
       wa_dyns TYPE rsds_type,
       gv_num  TYPE sy-tfill, " Row Number of Internal Tables
       gv_kind TYPE char01.   " Kind of type CHAR01


*----------------------------------------------------------------------*
*  Defintions for Free Selection.
*----------------------------------------------------------------------*


** Declarations for Table Properties **
DATA : i_field_list  TYPE ddfields,
       wa_field_list TYPE dfies. " DD Interface: Table Fields for DDIF_FIELDINFO_GET



** Declaration for Dynamic Where Clause **
DATA : "i_clause TYPE STANDARD TABLE OF rsds_where,
       wa_clause TYPE rsds_where.

DATA : i_where     TYPE STANDARD TABLE OF rsdswhere,     " Line for WHERE clauses (dynamic selections)
       i_where_add TYPE STANDARD TABLE OF rsdswhere, " Line for WHERE clauses (dynamic selections)
       i_where_new TYPE STANDARD TABLE OF rsdswhere, " Line for WHERE clauses (dynamic selections)
       wa_where    TYPE rsdswhere.                      " Line for WHERE clauses (dynamic selections)



CONSTANTS : c_enhancement_no TYPE z_enhancement VALUE 'D2_OTC_RDD_0028'. " Enhancement No.
DATA : i_enh_status  TYPE TABLE OF zdev_enh_status, " Enhancement Status
       wa_enh_status TYPE zdev_enh_status.         " Enhancement Status


DATA :   gv_srep_flag TYPE char1 . " Srep_flag of type CHAR1

DATA: i_fieldcatalog  TYPE slis_t_fieldcat_alv,   "reuse alv field catalog table
      wa_fieldcatalog TYPE slis_fieldcat_alv,     "reuse alv field catalog workarea
      i_header        TYPE slis_t_listheader,     "reuse alv field top of page table
      wa_header       TYPE slis_listheader,       "reuse alv field top of page workarea
      gv_layout       TYPE slis_layout_alv.       "reuse alv layout
