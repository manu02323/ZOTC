*&---------------------------------------------------------------------*
*&  Include           ZOTCN091O_CUST_EXT_GRP_BOM_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    : ZOTCN091O_CUST_EXT_GRP_BOM_TOP                          *
* TITLE      : Convert Sales BOM                                       *
* DEVELOPER  : Rajiv Banerjee/Jayanta Ray                              *
* OBJECT TYPE: Conversion                                              *
* SAP RELEASE: SAP ECC 6.0                                             *
*----------------------------------------------------------------------*
* WRICEF ID: D3_OTC_CDD_0091_Convert Sales BOM                         *
*----------------------------------------------------------------------*
* DESCRIPTION: BOMs will be extended to plants using custom BDC program*
*              automating transaction code CS07.                       *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
*   DATE        USER    TRANSPORT    DESCRIPTION                       *
* =========== ======== ===========  ===================================*
* 09-MAY-2016  RBANERJ1  E1DK917998  Initial Development               *
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*           C O N S T A N T S                                          *
*----------------------------------------------------------------------*

TYPES:
BEGIN OF ty_report,
  msgtyp  TYPE char1,   "Message Type E / S
  msgtxt  TYPE string,  "Message Text
  key     TYPE string,  "Key of message
END OF ty_report,

BEGIN OF ty_error,
  matnr   TYPE matnr,   " Material Number
  werks   TYPE werks_d, " Plant
  errmsg  TYPE string,  " Error message
END OF ty_error,

*-- Input File structure
BEGIN OF ty_final,
  matnr   TYPE matnr,   " Material Number
  werks   TYPE werks_d, " Plant
END OF ty_final.


*-- Table type declarationsTYPES:
TYPES:
ty_t_final  TYPE STANDARD TABLE OF ty_final,  " table for data from file
ty_t_error  TYPE STANDARD TABLE OF ty_error,  " Error records
ty_t_report TYPE STANDARD TABLE OF ty_report, " Report details
ty_t_bdcdata TYPE STANDARD TABLE OF bdcdata.  " Batch input: New table field structure

*-- Internal table declarations
DATA:
i_final   TYPE ty_t_final,  "#EC NEEDED  " table for data from file
i_error   TYPE ty_t_error,  "#EC NEEDED  " Error records
i_report  TYPE ty_t_report, "#EC NEEDED  " Report details
i_valid   TYPE ty_t_final,  "#EC NEEDED  " Valid Records
i_bdcdata TYPE ty_t_bdcdata."#EC NEEDED " BDC data Table

*-- Global variables
DATA:
gv_mode     TYPE char10,    "#EC NEEDED  " Mode of type CHAR10
gv_file     TYPE localfile, "#EC NEEDED  " File name
gv_scount   TYPE int4,      "#EC NEEDED  " Succes Count
gv_codepage TYPE cpcodepage,"#EC NEEDED " SAP Character Set ID
gv_ecount   TYPE int4.      "#EC NEEDED  " Error Count

CONSTANTS: c_extn       TYPE char3        VALUE 'TXT',               " Constant sring with value 'TXT'
           c_tab        TYPE char1        VALUE                      " Tab of type CHAR1
                             cl_abap_char_utilities=>horizontal_tab, " Tab
           c_rbselected TYPE char1        VALUE   'X',               " constant declaration for radio button selected
           c_error      TYPE char1        VALUE   'E'.               "Error
