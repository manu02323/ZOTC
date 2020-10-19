*&---------------------------------------------------------------------*
*&  Include           ZOTCN0274B_PRICE_UPLOAD_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCE0274B_PRICE_UPLOAD                                *
* TITLE      :  D2_OTC_EDD_0274_Pricing upload program for pricing cond*
* DEVELOPER  :  Monika Garg                                            *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_EDD_0274                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: Pricing Upload program for pricing condition            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER     TRANSPORT  DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 18-Aug-2015  MGARG    E2DK913959 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
*  26-Oct-2015 DMOIRAN  E2DK913959 Defect 1209 PGL B development.      *
* To support pricing condition text upload changes done in excel       *
* upload to allow 72 characters field                                  *
*&---------------------------------------------------------------------*
* Declaring Constants
CONSTANTS:
 c_extn       TYPE char3     VALUE 'XLS',         " c_extn type string with value 'XLS'
 c_extn1      TYPE char4     VALUE 'XLSX',        " Extn1 of type CHAR4
 c_e          TYPE char1     VALUE 'E',           " E of type CHAR1
 c_s          TYPE char1     VALUE 'S',           " S of type CHAR1
 c_fslash     TYPE char1     VALUE '/',           " Forward slash
 c_rbselect   TYPE char1     VALUE 'X',           " constant declaration for radio button selected
 c_kvewe      TYPE kvewe     VALUE 'A',           " Usage of the condition table
 c_ucomm      TYPE sy-ucomm  VALUE 'ONLI',        " Function code that PAI triggered
 c_mod        TYPE char03    VALUE 'MOD',         " Mod of type CHAR03
 c_hline      TYPE char100                        " Dotted Line
 VALUE
'-----------------------------------------------------------',
 c_chktabtvak  TYPE tabname        VALUE 'TVAK',  " Table Name
 c_chktabtvv5  TYPE tabname        VALUE 'TVV5',  " Table Name
 c_chktabt005s TYPE tabname        VALUE 'T005S', " Table Name
 c_chktabtvm4  TYPE tabname        VALUE 'TVM4'.  " Table Name

* Types Declaration
TYPES:

* Error Report Display Structure
    BEGIN OF ty_ereport,
     msgtyp   TYPE char1, " Msgtyp of type CHAR1
     msgtxt   TYPE string,
     value    TYPE string,
    END OF ty_ereport,

* Field table
    BEGIN OF ty_ntype,
    name      TYPE string,
    ty        TYPE string,
    END OF ty_ntype,

* Range table
    BEGIN OF ty_t682i_r,
    sign    TYPE sign,    " Debit/Credit Sign (+/-)
    option  TYPE option,  " Option for ranges tables
    low     TYPE kotabnr, " Condition table
    high    TYPE kotabnr, " Condition table
   END OF ty_t682i_r,
*
    ty_t_t682i_r TYPE STANDARD TABLE OF ty_t682i_r,
* ---> Begin of Change for D2_OTC_EDD_0274 Defect 1209 by DMOIRAN
*    ty_t_intern  TYPE STANDARD TABLE OF alsmex_tabline. " Rows for Table with Excel Data
    ty_t_intern  TYPE STANDARD TABLE OF zotc_s_alsmex_tabline. " Rows for Table with Excel Data
* <--- End    of Change for D2_OTC_EDD_0274 Defect 1209 by DMOIRAN
* Variables declration
DATA:
    gv_tot       TYPE sytabix,               " Index of Internal Tables
    gv_succ        TYPE sytabix,             " Index of Internal Tables
    gv_err         TYPE sytabix,             " Index of Internal Tables
    gv_ref_tvak    TYPE fieldname,           " Field Name
    gv_ref_tvv5    TYPE fieldname,           " Field Name
    gv_ref_t005s   TYPE fieldname,           " Field Name
    gv_ref_tvm4    TYPE fieldname,           " Field Name
    gv_lpath       TYPE filepath-pathintern, " Logical path name
    gv_filenam     TYPE string,
    wa_ntype       TYPE ty_ntype,
    i_ntype        TYPE STANDARD TABLE OF ty_ntype,
    i_component    TYPE cl_abap_structdescr=>component_table,
    i_ereport      TYPE STANDARD TABLE OF ty_ereport,
    wa_ereport     TYPE ty_ereport,
    i_t682i_r      TYPE STANDARD TABLE OF ty_t682i_r,
* ---> Begin of Insert for Defect 959 by DMOIRAN
    i_status   TYPE STANDARD TABLE OF zdev_enh_status. "Enhancement Status table
* <--- End    of Insert for Defect 959 by DMOIRAN



* Field Symbol Declaration
FIELD-SYMBOLS :
     <fs_component>   TYPE cl_abap_structdescr=>component,
     <fs_dyn_tab>     TYPE STANDARD TABLE,
     <fs_dyn_tabtmp>  TYPE STANDARD TABLE,
     <fs_dyn_tab_s>   TYPE STANDARD TABLE,
     <fs_dyn_wa>      TYPE any.
