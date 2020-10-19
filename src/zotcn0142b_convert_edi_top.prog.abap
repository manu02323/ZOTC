*&---------------------------------------------------------------------*
*&  Include           ZOTCN0142B_CONVERT_EDI_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0142B_CONVERT_EDI_TOP                             *
* TITLE      :  Order to Cash D3_OTC_CDD_0142_Convert EDI Ext Partner  *
*               to Internal Partner (EDPAR)                            *
* DEVELOPER  :  Nasrin Ali                                             *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_CDD_0142                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Convert EDI Ext Partner                                *
*               to Internal Partner (EDPAR)                            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 18-MAY-2016 NALI     E1DK918180 INITIAL DEVELOPMENT                  *
* =========== ======== ========== =====================================*

TYPES : BEGIN OF ty_report,
       msgtyp TYPE char1,  "Message Type E / S
       msgtxt TYPE string, "Message Text
       key    TYPE string, "Key of message
      END OF ty_report,

***Structure for input file
      BEGIN OF ty_final,
        kunnr TYPE kunnr,     " Customer Number
        parvw TYPE parvw,     " Partner Function
        expnr TYPE edi_expnr, " External partner number (in customer system)
        inpnr TYPE edi_inpnr, " Internal partner number (in SAP System)
     END OF ty_final,

***Structure for Customer
        BEGIN OF ty_kunnr,
          kunnr TYPE kunnr, " Customer Number
         END OF ty_kunnr,

***Structure for error file
     BEGIN OF ty_error,
        kunnr TYPE kunnr,     " Customer Number
        parvw TYPE parvw,     " Partner Function
        expnr TYPE edi_expnr, " External partner number (in customer system)
        inpnr TYPE edi_inpnr, " Internal partner number (in SAP System)
        errmsg TYPE string,
     END OF ty_error.

**Table Type declaration
TYPES: ty_t_report    TYPE STANDARD TABLE OF ty_report INITIAL SIZE 0, " Report
       ty_t_final TYPE STANDARD TABLE OF ty_final INITIAL SIZE 0,
       ty_t_error TYPE STANDARD TABLE OF ty_error INITIAL SIZE 0,
       ty_t_kunnr TYPE STANDARD TABLE OF ty_kunnr INITIAL SIZE 0,
       ty_t_bdcdata   TYPE STANDARD TABLE OF bdcdata   INITIAL SIZE 0. " For bdc data

* Constants
CONSTANTS :c_text      TYPE char3 VALUE 'TXT',                        "Extension .TXT
           c_file_type TYPE char10 VALUE 'ASC',                       "ASC
           c_tab       TYPE char1 VALUE                               " Tab of type CHAR1
                              cl_abap_char_utilities=>horizontal_tab, " Tab
           c_tcode     TYPE tcode   VALUE 'VOE4',                     " Tcode name
           c_group     TYPE apq_grpn VALUE 'OTC_0142',                " Session Name
           c_emsg      TYPE char1 VALUE 'E',                          " constant declaration for 'E' error message type
           c_fslash    TYPE char1 VALUE '/',                          " Forward slash
           c_error     TYPE char1      VALUE 'E',                     "Success Indicator
           c_tbp_fld    TYPE char5      VALUE 'TBP',                  " constant declaration for TBP folder
           c_done_fld   TYPE char5 VALUE 'DONE',                      " constant declaration for DONE folder.
           c_error_fld  TYPE char5 VALUE 'ERROR',                     " constant declaration ERROR folder
           c_smsg       TYPE char1 VALUE 'S'.                         " constant declaration for 'S' success message type


* Variable Declaration.
DATA: gv_save     TYPE char1 ##needed ,      "= X for Post; = Space for Verify Only
      gv_file     TYPE localfile ##needed ,  "File name
      gv_codepage TYPE cpcodepage ##needed , " SAP Character Set ID
      gv_mode     TYPE char10 ##needed ,     "Mode of transaction
      gv_scount   TYPE int2 ##needed ,       " Succes Count
      gv_ecount   TYPE int2 ##needed .       " Error Count

**Internal Tables
DATA: i_report    TYPE ty_t_report ##needed ,            "Report table
      i_final TYPE STANDARD TABLE OF ty_final ##needed , " Final internal table
      i_error TYPE STANDARD TABLE OF ty_error ##needed , " Error table
      i_kunnr TYPE STANDARD TABLE OF ty_kunnr ##needed , " Customer table
      i_bdcdata TYPE ty_t_bdcdata ##needed ,             " BDC table
      i_valid TYPE STANDARD TABLE OF ty_final ##needed . " Valid table


*WorkArea
DATA: wa_report TYPE ty_report ##needed , " Report
      wa_error TYPE ty_error ##needed .   " Error
