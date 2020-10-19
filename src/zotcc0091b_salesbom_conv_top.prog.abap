*&---------------------------------------------------------------------*
*&  Include           ZOTCC0091B_SALESBOM_CONV_TOP
*&---------------------------------------------------------------------*
*&**********************************************************************
* PROGRAM    :  ZOTCC0091B_SALESBOM_CONV_TOP                           *
* TITLE      :  Sales BOM Conversion                                   *
* DEVELOPER  :  Shoban Mekala                                          *
* OBJECT TYPE:  Conversion Program                                     *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_CDD_0091                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Convert Sales BOM                                      *
*                                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 26-Sep-2014 SMEKALA  E2DK905288 INITIAL DEVELOPMENT                  *
*&
*&---------------------------------------------------------------------*

*-- Global TYPES declaration

TYPES:
*-- Input File structure
BEGIN OF ty_final,
  matnr   TYPE matnr,  " Material Number
  stlan   TYPE stlan,  " BOM Usage
  postp   TYPE postp,  " Item Category (Bill of Material)
  idnrk   TYPE idnrk,  " BOM component
  menge   TYPE char15, " Component quantity
  datuv   TYPE char10, " Valid-From Date
  datub   TYPE datub,  " Valid-to date
END OF ty_final,

BEGIN OF ty_error,
  matnr   TYPE matnr,  " Material Number
  stlan   TYPE stlan,  " BOM Usage
  postp   TYPE postp,  " Item Category (Bill of Material)
  idnrk   TYPE idnrk,  " BOM component
  menge   TYPE char15, " Component quantity
  datuv   TYPE datuv,  " Valid-From Date
  datub   TYPE datub,  " Valid-to date
  errmsg  TYPE string,
END OF ty_error,

BEGIN OF ty_mast,
  matnr TYPE matnr,    " Material Number
  werks TYPE werks_d,  " Plant
  stlan TYPE stlan,    " BOM Usage
  stlnr TYPE stnum,    " Bill of material
  stlal TYPE stalt,    " Alternative BOM
END OF ty_mast,

BEGIN OF ty_report,
  msgtyp  TYPE char1,  "Message Type E / S
  msgtxt  TYPE string, "Message Text
  key     TYPE string, "Key of message
END OF ty_report,

BEGIN OF ty_invbom,
matnr TYPE matnr,      " Material Number
END OF ty_invbom.

*-- Table type declarations
TYPES:
ty_t_final  TYPE STANDARD TABLE OF ty_final,
ty_t_error  TYPE STANDARD TABLE OF ty_error,
ty_t_report TYPE STANDARD TABLE OF ty_report,
ty_t_mast   TYPE STANDARD TABLE OF ty_mast,
ty_t_invbom TYPE STANDARD TABLE OF ty_invbom,
ty_t_bdcdata TYPE STANDARD TABLE OF bdcdata. " Batch input: New table field structure

*-- Internal table declarations
DATA:
i_final   TYPE ty_t_final,
i_error   TYPE ty_t_error,
i_report  TYPE ty_t_report,
i_valid   TYPE ty_t_final,
i_invbom  TYPE ty_t_invbom,
i_mast    TYPE ty_t_mast,
i_bdcdata TYPE ty_t_bdcdata,                       "BDC data Table
i_emiplant TYPE STANDARD TABLE OF zdev_enh_status. " Enhancement Status

*-- Work areas
DATA:
wa_final  TYPE ty_final, "Final Record Work area
wa_error  TYPE ty_error,
wa_report TYPE ty_report,
wa_invbom TYPE ty_invbom.

*-- Global variables
DATA:
gv_save     TYPE char1,     "= X for Post; = Space for Verify Only
gv_file     TYPE localfile, "File name
gv_mode     TYPE char10,    "Mode of transaction
gv_scount   TYPE int4,      " Succes Count
gv_ecount   TYPE int4,      " Error Count
gv_scr_num  TYPE bdc_dynr.  " BDC Screen number

*-- Constants
CONSTANTS:
c_text       TYPE char3        VALUE   'TXT',             "Extension .TXT
c_file_type  TYPE char10       VALUE   'ASC',             "ASC
c_sep        TYPE char01       VALUE   'X',               "Seprator
c_lp_ind     TYPE char1        VALUE   'X',               "X = Logical File Path
c_x          TYPE char1        VALUE   'X',               " X of type CHAR1
c_tab        TYPE char1        VALUE                      " Tab of type CHAR1
                  cl_abap_char_utilities=>horizontal_tab, " Tab
c_group      TYPE apqi-groupid VALUE   'OTC_0091',        " Session Name
c_emsg       TYPE char1        VALUE   'E',               " constant declaration for 'E' error message type
c_fslash     TYPE char1        VALUE   '/',               " Forward slash
c_error      TYPE char1        VALUE   'E',               "Success Indicator
c_tcode      TYPE tstc-tcode   VALUE   'CS01',            " Tcode name
c_ptcode     TYPE tstc-tcode   VALUE   'CS07',            " Tcode name
c_tbp_fld    TYPE char5        VALUE   'TBP',             " constant declaration for TBP folder
c_done_fld   TYPE char5        VALUE   'DONE',            " constant declaration for DONE folder.
c_error_fld  TYPE char5        VALUE   'ERROR',           " constant declaration ERROR folder
c_smsg       TYPE char1        VALUE   'S',               " constant declaration for 'S' success message type
c_rbselected TYPE char1        VALUE   'X'.               " constant declaration for radio button selected
