*&---------------------------------------------------------------------*
*& Program      ZOTCE0285B_SORD_ATP_CHECK_TOP
*&
************************************************************************
* PROGRAM    :  ZOTCE0285B_SORD_ATP_CHECK_TOP                          *
* TITLE      :  ATP Check for Sales orders                             *
* DEVELOPER  :  Dhanasekar Arumugam                                    *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
*  WRICEF ID :  D2_OTC_EDD_0285                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: This is a BDC program to run ATP check                  *
* using Call Transaction to VA02.                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 05-OCT-2015 DARUMUG  E2DK915626  INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*

TYPES:
*Input file structure.
       BEGIN OF ty_input,
        vbeln TYPE vbeln,
        posnr TYPE posnr,
       END OF ty_input,

*Final Report Display Structure
       BEGIN OF ty_report,
        msgtyp TYPE char1,  "Message Type E / S
        msgtxt TYPE string, "Message Text
        key    TYPE string, "Key of message
       END OF ty_report,

*Input Structure containing the Error Message
        BEGIN OF ty_input_e,
        vbeln TYPE vbeln,
        posnr TYPE posnr,
        message TYPE cacl_string, " message text
       END OF ty_input_e,

*structure for Successful records
       BEGIN OF ty_input_f,
        vbeln TYPE vbeln,
        posnr TYPE posnr,
        success TYPE char1,      " Success of type CHAR1
       END OF ty_input_f.

*Table type Declaration.
TYPES:
ty_t_input      TYPE STANDARD TABLE OF ty_input        INITIAL SIZE 0, "Table type of Input.
ty_t_report     TYPE STANDARD TABLE OF ty_report       INITIAL SIZE 0, "Report Display
ty_t_input_e    TYPE STANDARD TABLE OF ty_input_e      INITIAL SIZE 0, "Table type of Error
ty_t_input_f    TYPE STANDARD TABLE OF ty_input_f      INITIAL SIZE 0, "Table type of final
ty_t_bdcdata    TYPE STANDARD TABLE OF bdcdata         INITIAL SIZE 0, "For BDC data
ty_t_bdcmsg     TYPE STANDARD TABLE OF bdcmsgcoll      INITIAL SIZE 0. "BDC message

***********************************************************************
*Internal Table  declaration                                          *
***********************************************************************
DATA:
      i_input      TYPE         ty_t_input,     "file to upload
      i_report     TYPE         ty_t_report,    "For Report display
      i_vbeln      TYPE STANDARD TABLE OF ty_input,
      i_input_e    TYPE         ty_t_input_e,   "For error in records
      i_final      TYPE         ty_t_input_f,   "For final display
      i_bdcdata    TYPE         ty_t_bdcdata,   "For BDC data
      i_bdcmsg     TYPE         ty_t_bdcmsg.    "For BDC msg

* Global variable declaration
* These variables are used in multiple subroutines/performs
* hence declaring as global.
DATA:   gv_itm      TYPE posnr,
        gv_file     TYPE localfile, "File name
        gv_mode     TYPE char10,    "Mode of transaction
        gv_scount   TYPE int2,      "Success counter
        gv_ecount   TYPE int2.      "Error Count


***********************************************************************
*Constants Declaration                                                *
**********************************************************************

CONSTANTS:
c_update     TYPE char1         VALUE 'L',                           "Transaction update
c_text       TYPE char3         VALUE 'TXT',                         "Extension .TXT
c_filetype   TYPE char10        VALUE 'ASC',                         "File type
c_tobeprscd  TYPE char3         VALUE 'TBP',                         "TBP Folder
c_slash      TYPE char1         VALUE '/',                           "Slash\
c_error      TYPE char1         VALUE 'E',                           "Error Indicator
c_success    TYPE char1         VALUE 'S',                           "Success Indicator
c_info       TYPE bapi_mtype    VALUE 'I',                           "Information Message type
c_warning    TYPE bapi_mtype    VALUE 'W',                           "Warning Message Type
c_err_fold   TYPE cacl_string   VALUE 'ERROR',                       "Error folder
*c_crlf       TYPE flag          VALUE cl_abap_char_utilities=>cr_lf, "New file feed
c_va02       TYPE sytcode       VALUE 'VA02'.
