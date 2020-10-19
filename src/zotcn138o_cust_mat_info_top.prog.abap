*&---------------------------------------------------------------------*
*&  Include           ZOTCC0138O_CUST_MAT_INFO_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    : ZOTCC0138O_CUST_MAT_INFO_TOP (Include)                  *
* TITLE      : Convert Customer Material info records                  *
* DEVELOPER  : Rajiv Banerjee                                          *
* OBJECT TYPE: Conversion                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID: D3_OTC_CDD_0138_Convert Customer Material Info Records    *
*----------------------------------------------------------------------*
* DESCRIPTION: Customer material info records are used if the          *
* customer’s material number differs from the Bio-Rad’s material       *
* number, some customer’s would also require their own material number *
* be printed or transmitted in all of their communications.            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
*   DATE        USER    TRANSPORT    DESCRIPTION                       *
* =========== ======== ===========  ===================================*
* 20-APR-2016  RBANERJ1  E1DK917457  Initial Development               *
*&---------------------------------------------------------------------*


*----------------------------------------------------------------------*
*            C L A S S                                                 *
*----------------------------------------------------------------------*
CLASS cl_abap_char_utilities DEFINITION LOAD. " Class for tab Delimiter

*----------------------------------------------------------------------*
*           GLOBAL TYPE DECLARATIONS                                   *
*----------------------------------------------------------------------*
TYPES:
       BEGIN OF ty_string ,
         string TYPE string,          "string file record
       END OF ty_string,

       BEGIN OF ty_report,
         msgtyp TYPE char1,           " Message type
         msgtxt TYPE string,          " Message text
         vkorg  TYPE vkorg,           "Sales Organization
         kunnr  TYPE kunnr_v,         "Customer number
         matnr  TYPE matnr,           "Material Number
       END OF ty_report,

       BEGIN OF ty_data,
         vkorg  TYPE vkorg,           "Sales Organization
         vtweg  TYPE vtweg,           "Distribution Channel
         kunnr  TYPE kunnr_v,         "Customer number
         matnr  TYPE matnr,           "Material Number
         sortl  TYPE sortl,           "Sort field
         kdmat  TYPE matnr_ku,        "Material Number Used by Customer
         postx  TYPE kdptx,           "Customer description of material
         lprio  TYPE lprio,           "Delivery Priority
         minlf  TYPE minlf,           "Minimum delivery quantity in delivery note processing
         meins  TYPE meins,           "Base Unit of Measure
         chspl  TYPE chspl,           "Batch split allowed
         kztlf  TYPE kztlf,           "Partial delivery at item level
         antlf  TYPE antlf,           "Maximum Number of Partial Deliveries Allowed Per Item
         untto  TYPE untto,           "Underdelivery Tolerance Limit
         uebto  TYPE uebto,           "Overdelivery Tolerance Limit
         uebtk  TYPE uebtk_v,         "Unlimited overdelivery allowed
         werks  TYPE werks_ext,       "Plant (Own or External)
         rdprf  TYPE rdprf,           "Rounding Profile
         megru  TYPE megru,           "Unit of Measure Group
         j_1btxsdc   TYPE j_1btxsdc_, "SD tax code
         vwpos  TYPE vwpos,           "Item usage
         spras1 TYPE char2,           "Language Key 1
         text1  TYPE string,          "Text 1
         spras2 TYPE char2,           "Language Key 2
         text2  TYPE string,          "Text 2
         spras3 TYPE char2,           "Language Key 3
         text3  TYPE string,          "Text 3
         spras4 TYPE char2,           "Language Key 4
         text4  TYPE string,          "Text 4
         spras5 TYPE char2,           "Language Key 5
         text5  TYPE string,          "Text 5
         string TYPE string,
         e_flag TYPE flag,            " Error Flag
       END OF ty_data,

       BEGIN OF ty_kna1,
         kunnr  TYPE kunnr,           "Customer Number
       END OF ty_kna1,

       BEGIN OF ty_mara,
         matnr  TYPE matnr,           "Material Number
       END OF ty_mara,

       BEGIN OF ty_knvv,
         kunnr  TYPE  kunnr,          "Customer Number
         vkorg  TYPE  vkorg,          "Sales Organization
         vtweg  TYPE  vtweg,          "Distribution Channel
         spart  TYPE  spart,          "Division
       END OF ty_knvv,

       BEGIN OF ty_mvke,
         matnr  TYPE  matnr,          "Material Number
         vkorg  TYPE  vkorg,          "Sales Organization
         vtweg  TYPE  vtweg,          "Distribution Channel
       END OF ty_mvke,

       BEGIN OF ty_knmt,
         vkorg  TYPE vkorg,           "Sales Organization
         vtweg  TYPE vtweg,           "Distribution Channel
         kunnr  TYPE kunnr_v,         "Customer number
         matnr  TYPE matnr,           "Material Number
       END OF ty_knmt,

*----------------------------------------------------------------------*
*           TABLE TYPE DECLARATIONS                                    *
*----------------------------------------------------------------------*
    ty_t_report  TYPE STANDARD TABLE OF ty_report, " Report display
    ty_t_data    TYPE STANDARD TABLE OF ty_data,   " Data
    ty_t_string  TYPE STANDARD TABLE OF ty_string. " String data


*----------------------------------------------------------------------*
*           INTERNAL TABLE DECLARATIONS                                *
*----------------------------------------------------------------------*
DATA:
      i_string     TYPE STANDARD TABLE OF ty_string INITIAL SIZE 0, " Input file table
      i_data       TYPE STANDARD TABLE OF ty_data   INITIAL SIZE 0, " Load File Data
      i_report     TYPE STANDARD TABLE OF ty_report INITIAL SIZE 0, " Internal table for Error log
      i_bdcdata    TYPE STANDARD TABLE OF bdcdata INITIAL SIZE 0,   " For BDC data.
      i_kna1       TYPE STANDARD TABLE OF ty_kna1,
      i_mara       TYPE STANDARD TABLE OF ty_mara,
      i_knvv       TYPE STANDARD TABLE OF ty_knvv,
      i_mvke       TYPE STANDARD TABLE OF ty_mvke,
      i_knmt       TYPE STANDARD TABLE OF ty_knmt,
      i_error      TYPE STANDARD TABLE OF ty_string,
      i_done       TYPE STANDARD TABLE OF ty_string.

*----------------------------------------------------------------------*
*           GLOBAL DATA DECLERATIONS                                   *
*----------------------------------------------------------------------*
DATA: gv_modify       TYPE localfile,  " Input Data
      gv_filename     TYPE localfile,  " Directory name
      gv_file         TYPE localfile,  " Local file for upload/download
      gv_subrc        TYPE sy-subrc,   " Return Value of ABAP Statements
      gv_header       TYPE string,
      gv_success      TYPE int2,       " 2 byte integer (signed)
      gv_mode         TYPE char15,     " Mode of type CHAR10
      gv_error        TYPE int2,       " Error Count
      gv_bdc_flag     TYPE flag,       " BDC Flag
      gv_codepage     TYPE cpcodepage. "SAP Character Set ID
*----------------------------------------------------------------------*
*           C O N S T A N T S                                          *
*----------------------------------------------------------------------*
CONSTANTS: c_extn       TYPE char3 VALUE 'TXT', " Constant sring with value 'TXT'
           c_error      TYPE char1 VALUE 'E',   " Error of type CHAR1
           c_success    TYPE char1 VALUE 'S',   " Success of type CHAR1
           c_info       TYPE char1 VALUE 'I',   " Info of type CHAR1
           c_1          TYPE char1 VALUE '1',   " constant val 1
           c_2          TYPE char1 VALUE '2',   " constant val 2
           c_3          TYPE char1 VALUE '3',   " constant val 3
           c_4          TYPE char1 VALUE '4',   " constant val 4
           c_5          TYPE char1 VALUE '5',   " constant val 5
           c_6          TYPE char1 VALUE '6',   " constant val 6
           c_7          TYPE char1 VALUE '7',   " constant val 7
           c_8          TYPE char1 VALUE '8',   " constant val 8
           c_9          TYPE char1 VALUE '9',   " constant val 9
           c_10         TYPE char2 VALUE '10',  " constant val 10
           c_11         TYPE char2 VALUE '11'.  " constant val 11
