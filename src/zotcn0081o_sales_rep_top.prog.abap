************************************************************************
* PROGRAM    :  ZOTCN0081O_SALES_REP_TOP                               *
* TITLE      :  OTC_IDD_0081 UPLOAD SALES REP TERRITORY                *
* DEVELOPER  :  ANKIT PURI                                             *
* OBJECT TYPE:  INCLUDE                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  OTC_IDD_0081                                           *
*----------------------------------------------------------------------*
* DESCRIPTION:  INCLUDE FOR GLOBAL DECLARATION                         *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT    DESCRIPTION                      *
* ===========  ========  ==========   =================================*
* 27-JUNE-2012 APURI     E1DK903418   INITIAL DEVELOPMENT              *
*----------------------------------------------------------------------*

TYPES:

BEGIN OF ty_input,
 kunnr  TYPE kunnr,         "Customer Number
 pstlz  TYPE pstlz,         "Postal Code
 stdate TYPE sy-datum,      "start date
 eddate TYPE sy-datum,      "end date
 mtart  TYPE mtart,         "material type
 matkl  TYPE matkl,         "material group
 prdha  TYPE prodh_d,       "Product hierarchy
 prctr  TYPE prctr,         "Profit Center
 ktokd  TYPE z_emprole,     "BR employee role
 empno  TYPE z_emp_number,  "Bio-Rad Employee Number
 comments TYPE char30,      "comments
END OF ty_input,


*Final Report Display Structure
BEGIN OF ty_report,
 msgtyp  TYPE char1,        "Message Type
 msgtxt  TYPE string,       "Message Text
 key     TYPE string,       "Message Key
END OF ty_report,

* KNA1 structure for validation of customer number
BEGIN OF ty_kunnr,
 kunnr TYPE kunnr,          "Customer number
 name1 TYPE name1_gp,       "customer name
END OF ty_kunnr,

BEGIN OF ty_pstlz,
 pstlz TYPE pstlz,          "postal code
END OF ty_pstlz,

*T134 structure for validation of material type
BEGIN OF ty_mtart,
 mtart TYPE mtart,          "Material type
END OF ty_mtart,

*T023 structure for validation material group
BEGIN OF ty_matkl,
 matkl TYPE matkl,          "Material group
END OF ty_matkl,

*T179 structure for validation of product hierarchy
BEGIN OF ty_prdha,
 prdha   TYPE prodh_d,      "Product hierarchy
END OF ty_prdha,

*CEPC structure for validation of profit centre
BEGIN OF ty_prctr,
 prctr TYPE prctr,          "Profit centre
END OF ty_prctr,

*zotc_prc_control structure for validation of employee role
BEGIN OF ty_ktokd,
 ktokd TYPE z_mvalue_low,   "Employee role
END OF ty_ktokd,

*KNA1 structure for validation of customer number
BEGIN OF ty_kna1_empno,
 empno   TYPE z_emp_number, "Bio-Rad Employee Number
 empname TYPE z_emp_name,   "employee name
END OF ty_kna1_empno,


BEGIN OF ty_zotc_sale_empmap,
 kunnr    TYPE kunnr,      "Ship To Customer Number
 pstlz    TYPE pstlz,      "Postal Code
 emprole  TYPE z_emprole,  "Emp role
 stdate   TYPE datab,      "Valid-From Date
 eddate   TYPE datbi,      "Valid To Date
END OF ty_zotc_sale_empmap,

BEGIN OF ty_shptocst,
 kunnr TYPE z_shipto_no,    "ship to customer
END OF ty_shptocst,

* Table Type Declaration

ty_t_input   TYPE STANDARD TABLE OF ty_input
             INITIAL SIZE 0, "For Input data
ty_t_report  TYPE STANDARD TABLE OF ty_report
             INITIAL SIZE 0, "Report
ty_t_kunnr   TYPE STANDARD TABLE OF ty_kunnr
             INITIAL SIZE 0, "customer number
ty_t_pstlz   TYPE STANDARD TABLE OF ty_pstlz
             INITIAL SIZE 0, "postal code
ty_t_mtart   TYPE STANDARD TABLE OF ty_mtart
             INITIAL SIZE 0, "material type
ty_t_matkl   TYPE STANDARD TABLE OF ty_matkl
             INITIAL SIZE 0, "material group
ty_t_prdha   TYPE STANDARD TABLE OF ty_prdha
             INITIAL SIZE 0, "product hierarchy
ty_t_prctr   TYPE STANDARD TABLE OF ty_prctr
             INITIAL SIZE 0, "profit centre
ty_t_ktokd   TYPE STANDARD TABLE OF ty_ktokd
             INITIAL SIZE 0, "Bio-Rad employee role
ty_t_kna1_empno
             TYPE STANDARD TABLE OF ty_kna1_empno
             INITIAL SIZE 0, "Bio-Rad employee number
ty_t_shptocst
             TYPE STANDARD TABLE OF ty_shptocst
             INITIAL SIZE 0, "ship to customer

ty_t_zotc_sale_empmap
             TYPE STANDARD TABLE OF ty_zotc_sale_empmap
             INITIAL SIZE 0. "zotc_sale-empmap

* Constants
CONSTANTS:

c_rbselected TYPE char1    VALUE  'X',    "constant declaration
c_info       TYPE char1    VALUE  'I',    "info message
c_ext        TYPE string   VALUE  'XLS',  "constant for extension
c_error      TYPE char1    VALUE  'E',    "Error Indicator
c_success    TYPE char1    VALUE  'S',    "Success Indicator
c_slash      TYPE char1    VALUE  '/',    "For slash
c_mactive    TYPE char1    VALUE  'X',    "mactive
c_fstcol     TYPE char4    VALUE  '0001', "fst column
c_scdcol     TYPE char4    VALUE  '0002', "second column
c_trdcol     TYPE char4    VALUE  '0003', "third column
c_fourtcol   TYPE char4    VALUE  '0004', "fourth column
c_fifthcol   TYPE char4    VALUE  '0005', "fifth column
c_sixcol     TYPE char4    VALUE  '0006', "sixth column
c_svncol     TYPE char4    VALUE  '0007', "seventh column
c_eghtcol    TYPE char4    VALUE  '0008', "eighth column
c_ninecol    TYPE char4    VALUE  '0009', "nineth column
c_tencol     TYPE char4    VALUE  '0010', "tenth column
c_elevencol  TYPE char4    VALUE  '0011', "eleven column
c_mprogram   TYPE string   VALUE  'ZOTCI0081O_SALES_REP_TERRITORY',"pgm
c_inclusive  TYPE char1    VALUE  'I',    "Inclusive
c_equal      TYPE char2    VALUE  'EQ',   "equal
c_mode       TYPE char1    VALUE  'E',    "mode
c_mparameter TYPE string   VALUE  'EMP_ROLE',"emp role
c_ktokd      TYPE string   VALUE  'ZREP'.    "ktokd

* Internal Table Declaration.
DATA:

i_input      TYPE ty_t_input,  " For Input data
i_report     TYPE ty_t_report, " Report Internal Table
i_final      TYPE STANDARD TABLE OF ty_input
             INITIAL SIZE 0,   " final internal table
i_kunnr      TYPE ty_t_kunnr,  " Customer number
i_pstlz      TYPE ty_t_pstlz,  " postal code
i_mtart      TYPE ty_t_mtart,  " Material type
i_matkl      TYPE ty_t_matkl,  " Material grp
i_prdha      TYPE ty_t_prdha,  " Prdct hierarchy
i_prctr      TYPE ty_t_prctr,  " Profit centre
i_ktokd      TYPE ty_t_ktokd,  " Bio-Rad employee role
i_date       TYPE STANDARD TABLE OF zotc_sale_empmap
             INITIAL SIZE 0,   " table contng all database records
i_table_insert
             TYPE STANDARD TABLE OF zotc_sale_empmap
             INITIAL SIZE 0,          "insert table
i_kna1_empno TYPE ty_t_kna1_empno,    "employee no and name
i_shptocst   TYPE ty_t_shptocst,      "ship to cust
i_zotc_sale_empmap
             TYPE ty_t_zotc_sale_empmap, "custom table
i_delete     TYPE STANDARD TABLE OF zotc_sale_empmap
             INITIAL SIZE 0,             "delete table

* Global Work area / structure declaration.
wa_report    TYPE ty_report,          "work area for report
wa_shptocst  TYPE ty_shptocst,        "shp to cst
wa_pstlz     TYPE ty_pstlz,           "postal code
wa_table_insert
             TYPE zotc_sale_empmap,   "work area for insrt tbl
wa_change_date TYPE zotc_sale_empmap, "to change date


* Variable Declaration.
gv_mode     TYPE char10,     " Mode of transaction
gv_scount   TYPE int2,       " Succes Count
gv_ecount   TYPE int2,       " Error Count
gv_stdate   TYPE sy-datum,   " start date
gv_eddate   TYPE sy-datum.   " end date

CLASS   cl_abap_char_utilities DEFINITION LOAD. "Class for Characters
