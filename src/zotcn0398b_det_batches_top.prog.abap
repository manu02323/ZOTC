*&**********************************************************************
* PROGRAM    :  ZOTCN0398B_DET_BATCHES_TOP                             *
* TITLE      :  Batch Determination at Sales Order                     *
* DEVELOPER  :  Avik Poddar                                            *
* OBJECT TYPE:  Enhancement Program                                    *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0398                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Batch determination program will be used as a tool for *
*               automatic batch assignment to sales order lines,       *
*               specifically red-blood cells materials in background   *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER        TRANSPORT         DESCRIPTION                *
* 11-OCT-2018  APODDAR   E1DK938946      Initial Development           *
* =========== ======== ========== =====================================*
*&---------------------------------------------------------------------*
*&  Include           ZOTCN0398B_DET_BATCHES_TOP
*&---------------------------------------------------------------------*

*&-->Types Include
TYPES: BEGIN OF ty_input,
           vbeln       TYPE  char10  , " Sales and Distribution Document Number
           posnr       TYPE  char6  ,  " Item number of the SD document
           matnr       TYPE  char18  , " Material Number
           kwmeng      TYPE  char15 ,  " Cumulative Order Quantity in Sales Units
           omeng       TYPE  char18,   " Open Qty in Stockkeeping Units for Transfer of Reqmts to MRP
           bmeng       TYPE  char16  , " Confirmed Quantity
           kunnr       TYPE  char10  , " Sold-to party
           name1       TYPE  char35  , " Name 1
           vkorg       TYPE  char4  ,  " Sales Organization
           vtweg       TYPE  char2  ,  " Distribution Channel
           werks       TYPE  char4  ,  " Plant
           edatu       TYPE  char10,   " Schedule line date
           charg       TYPE  char10  , " Batch Number
           lifsk       TYPE  char2  ,  " Delivery block (document header)
           vtext       TYPE  char20  , " Description
           antigens    TYPE  char30,   " Characteristic Value
           corres      TYPE  char30,   " Characteristic Value
  END OF ty_input,

      BEGIN OF ty_log_char,
            vbeln   TYPE char11,       " Sales and Distribution Document Number
            posnr   TYPE char7,        " Item number of the SD document
            status  TYPE char1,        " Message type: S Success, E Error, W Warning, I Info, A Abort
            message TYPE bapi_msg,     " Message Text
       END OF ty_log_char,

         ty_t_input     TYPE STANDARD TABLE OF ty_input,
         ty_t_log_char  TYPE STANDARD TABLE OF ty_log_char.

*Data Declaration
DATA:
      i_final_output   TYPE ty_t_input,        "Success records table
      i_log_char       TYPE ty_t_log_char,     "Log table
      i_log            TYPE TABLE OF bapiret2, " Return Parameter
      i_log_backg      TYPE ty_t_log_char,
      i_elog           TYPE TABLE OF ty_input, " Error Log Structure
      i_slog           TYPE TABLE OF ty_input, " Success Log Structure
      i_alv_fieldcat   TYPE lvc_t_fcat,        "#EC NEEDED " Field Catalog internal table
      gv_col_pos       TYPE sycucol,           " Horizontal Cursor Position at PAI
      gv_scount        TYPE int4,              "Succes Count
      gv_ecount        TYPE int4,              "Error Count
      gv_archive_gl_1  TYPE localfile,         "Archived file path 1
      wa_indx          TYPE indx,              " System Table INDX
      gv_spoolid       TYPE rspoid,            " Spool request number
*&-->Begin of change for D3_OTC_EDD_0398 Defect# 7289_FUT_ISSUE by SMUKHER4 on 17-Jan-2019
      gv_repid         TYPE sy-repid.          " Program Name
*&<-- End of change for D3_OTC_EDD_0398 Defect# 7289_FUT_ISSUE by SMUKHER4 on 17-Jan-2019

*Constant Declaration
CONSTANTS: c_etyp     TYPE char1       VALUE 'E',     " Error Type
           c_tbp      TYPE char3       VALUE 'TBP',   " To Be Processed
           c_err      TYPE char5       VALUE 'ERROR', " Error
           c_done     TYPE char4       VALUE 'DONE'.  " Done
