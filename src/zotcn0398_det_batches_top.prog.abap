*&---------------------------------------------------------------------*
*&  Include           ZOTC_EDD0398_DET_BATCHES_TOP
*&---------------------------------------------------------------------*
*&**********************************************************************
* PROGRAM    :  ZOTC_EDD0398_DET_BATCHES                               *
* TITLE      :  Batch Determination at Sales Order                     *
* DEVELOPER  :  Dhanasekar Arumugam                                    *
* OBJECT TYPE:  Enhancement Program                                    *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0398                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Batch determination program will be used as a tool for *
*               automatic batch assignment to sales order lines,       *
*               specifically red-blood cells materials                 *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 24-Jan-2018 DARUMUG  E1DK934038 INITIAL DEVELOPMENT                  *
* 05-Mar-2018 DARUMUG  E1DK934038 CR# 212 Added Corresponding Batch    *
*                                 logic                                *
*08-Aug-2018 SMUKHER4 E1DK938198 CR# 307:Excel File upload for BDP tool*
*04-Oct-2018 APODDAR  E1DK938946 Defect# 7289: Enabling background    *
*                                 functionality for BDP tool           *
* 29-Oct-2019 U033959  E2DK927169 Defect#10665- INC0433610-01          *
*                                 When split file check box is selected*
*                                 for background mode, then the records*
*                                 in the uploaded file will be split   *
*                                 into multiple files & mulitple       *
*                                 background jobs will be triggered.   *
*                                 Each file file contain no.of records *
*                                 as maintained in EMI                 *                                                                   *
*&---------------------------------------------------------------------*
CLASS lcl_alv_event_handler DEFINITION DEFERRED. " Alv_event_handler class

TYPES: BEGIN OF ty_batch_final,
            vbeln       TYPE  vbmtv-vbeln  , " Sales and Distribution Document Number
            posnr       TYPE  vbmtv-posnr  , " Item number of the SD document
            matnr       TYPE  vbmtv-matnr  , " Material Number
            kwmeng      TYPE  vbmtv-kwmeng , " Cumulative Order Quantity in Sales Units
            omeng       TYPE  omeng,         " Open Qty in Stockkeeping Units for Transfer of Reqmts to MRP
            bmeng       TYPE  vbmtv-bmeng  , " Confirmed Quantity
            kunnr       TYPE  vbmtv-kunnr  , " Sold-to party
            name1       TYPE  vbmtv-name1  , " Name 1
            vkorg       TYPE  vbmtv-vkorg  , " Sales Organization
            vtweg       TYPE  vbmtv-vtweg  , " Distribution Channel
            werks       TYPE  vbmtv-werks  , " Plant
            edatu       TYPE  edatu,         " Schedule line date
            charg       TYPE  vbmtv-charg  , " Batch Number
            lifsk       TYPE  vbmtv-lifsk  , " Delivery block (document header)
            vtext       TYPE  tvlst-vtext  , " Description
            antigens    TYPE atwrt,          " Characteristic Value
            corres      TYPE atwrt,          " Characteristic Value
            auart       TYPE auart,          " Sales Document Type
            auart_sd    TYPE auart,          " Sales Document Type
            spart       TYPE spart,          " Division
            prior       TYPE char2,          " Prior of type CHAR2
            mvgr2       TYPE mvgr2,          " Material group 2
            uom         TYPE meins,          " Base Unit of Measure
            mbdat       TYPE mbdat,          " Material Staging/Availability Date
            color_cell  TYPE lvc_t_scol,
            field_style TYPE lvc_t_styl,
       END OF  ty_batch_final,
       BEGIN OF ty_final,
            vbeln   TYPE vbeln,              " Sales and Distribution Document Number
            posnr   TYPE posnr,              " Item number of the SD document
            status  TYPE bapi_mtype,         " Message type: S Success, E Error, W Warning, I Info, A Abort
            message TYPE bapi_msg,           " Message Text
       END OF ty_final,
       BEGIN OF ty_vbep,
         vbeln TYPE vbeln,                   " Sales and Distribution Document Number
         posnr TYPE posnr,                   " Item number of the SD document
         etenr TYPE etenr,                   " Delivery Schedule Line Number
         edatu TYPE edatu,                   " Schedule line date
         wmeng TYPE wmeng,                   " Order quantity in sales units
         lmeng TYPE lmeng,                   " Required quantity for mat.management in stockkeeping units
         mbuhr TYPE mbuhr,                   " Material Staging Time (Local, Relating to a Plant)
       END OF  ty_vbep,
       BEGIN OF ty_vbep_c,
         vbeln TYPE vbeln,                   " Sales and Distribution Document Number
         posnr TYPE posnr,                   " Item number of the SD document
         edatu TYPE edatu,                   " Schedule line date
         wmeng TYPE wmeng,                   " Order quantity in sales units
         lmeng TYPE lmeng,                   " Required quantity for mat.management in stockkeeping units
         mbuhr TYPE mbuhr,                   " Material Staging Time (Local, Relating to a Plant)
       END OF  ty_vbep_c,

       BEGIN OF ty_vbap,
         vbeln TYPE vbeln,                   " Sales and Distribution Document Number
         posnr TYPE posnr,                   " Item number of the SD document
         mtvfp TYPE mtvfp,                   " Checking Group for Availability Check
         mvgr2 TYPE mvgr2,                   " Material group 2
         bedae TYPE bedae,                   " Requirements type
       END OF ty_vbap,

       BEGIN OF ty_kna1,
         kunnr  TYPE kunnr,                  " Customer Number
         land1  TYPE land1_gp,               " Country Key
         ort01  TYPE ort01_gp,               " City
         pstlz  TYPE pstlz,                  " Postal Code
       END OF   ty_kna1.

* SOC DDWIVED
TYPES:  BEGIN OF ty_mcha,
       matnr TYPE mcha-matnr, " Material Number
       werks TYPE mcha-werks, " Plant
       charg TYPE mcha-charg, " Batch Number
       END OF ty_mcha.
*EOC DDWIVEDI

TYPES:  BEGIN OF ty_qty_avail,
       matnr TYPE mcha-matnr, " Material Number
       werks TYPE mcha-werks, " Plant
       charg TYPE mcha-charg, " Batch Number
       wmeng TYPE wmeng,      " Order quantity in sales units
       END OF ty_qty_avail.


*&-->Begin of changes for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018
*&--Structures declaration
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

*&--Table types ddeclaration
  ty_t_input     TYPE STANDARD TABLE OF ty_input, "Input Tab
  ty_t_log_char  TYPE STANDARD TABLE OF ty_log_char.
*&<--End of changes for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018
*--> Begin of Insert for INC0433610-01-Defect#10665 D3_OTC_EDD_0398 by U033959 dated 29-Oct-2019
TYPES : BEGIN OF ty_split_files,
          index     TYPE  syst_tabix,    " Index
          fname_apl TYPE  localfile,     " File name
          fpath     TYPE  string,        " Filepath
          split     TYPE  zotc_tt_input, " Records
        END OF ty_split_files.
TYPES : BEGIN OF ty_job,
          job_name   TYPE btcjob,        " Job Name
          job_number TYPE btcjobcnt,     " Job Number
          message    TYPE string,        " Message
        END OF ty_job.
TYPES : ty_tt_split_files TYPE STANDARD TABLE OF ty_split_files, " Table type for split files
        ty_tt_job         TYPE STANDARD TABLE OF ty_job.         " Table type for jobs
DATA : i_split_files TYPE ty_tt_split_files,                     " Table for split files
       i_job         TYPE ty_tt_job.                             " Table for jobs
*<-- End of Insert for INC0433610-01-Defect#10665 D3_OTC_EDD_0398 by U033959 dated 29-Oct-2019
DATA:
      i_batch     TYPE TABLE OF ty_batch_final,
      i_batch_a   TYPE TABLE OF ty_batch_final,
      i_batch_b   TYPE TABLE OF ty_batch_final,
      i_batch_c   TYPE TABLE OF ty_batch_final,
      i_batch_d   TYPE TABLE OF ty_batch_final,
      i_batch_s   TYPE TABLE OF ty_batch_final,
      i_bdbatch_f TYPE TABLE OF bdbatch,                         " Results Table for Batch Determination
      i_bdbatch_c TYPE TABLE OF bdbatch,                         " Results Table for Batch Determination
      i_stock     TYPE TABLE OF zptm_corres_batch,               "cdstock,                                  " Results Table for Batch Determination / Stock Determination
      i_batch_cr  TYPE STANDARD TABLE OF clbatch INITIAL SIZE 0, " Classification interface for batches
      i_batch_crr TYPE STANDARD TABLE OF clbatch INITIAL SIZE 0, " Classification interface for batches
      i_vbep      TYPE TABLE OF ty_vbep,
      i_vbep_c    TYPE TABLE OF ty_vbep_c,
      i_log       TYPE TABLE OF bapiret2,                        " Return Parameter
      i_log_f     TYPE TABLE OF ty_final,
      i_kna1      TYPE TABLE OF ty_kna1,
      i_vbap      TYPE TABLE OF ty_vbap,
      i_t459a     TYPE TABLE OF t459a.                           " External requirements types

*SOC DDWIVEDI

DATA : i_mcha_data TYPE STANDARD TABLE OF ty_mcha,
        wa_mcha_data TYPE ty_mcha.

*EOC DDWIVEDI

DATA: o_alv       TYPE REF TO cl_gui_alv_grid,         "#EC NEEDED
      o_alv_event TYPE REF TO lcl_alv_event_handler,   "#EC NEEDED
      o_container TYPE REF TO cl_gui_custom_container. " Container for Custom Controls in the Screen Area

DATA:
      gv_plant       TYPE werks_d,  " Plant
      gv_matnr       TYPE matnr,    " Material Number
      gv_vkorg       TYPE vkorg,    " Sales Organization
      gv_vtweg       TYPE vtweg,    " Distribution Channel
      gv_vbeln       TYPE vbeln,    " Sales and Distribution Document Number
      gv_batch       TYPE charg_d,  " Batch Number
      gv_auart       TYPE auart,    " Order Type
      gv_docno       TYPE vbeln,    " Document Number
      gv_soldto      TYPE kunnr,    " Customer Number
      gv_rdate       TYPE wldat,    " Requested delivery date
      gv_okcode      TYPE sy-ucomm, " Function code that PAI triggered
      gv_repid       TYPE sy-repid,
*&-->Begin of changes for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018
*&--Internal table ,workarea and global variable declaration
      i_qty_avail     TYPE STANDARD TABLE OF ty_qty_avail,
      i_vbap_val      TYPE STANDARD TABLE OF ty_vbap,
      i_kna1_val      TYPE STANDARD TABLE OF ty_kna1,
      i_input         TYPE ty_t_input, "Input table
      i_source        TYPE ty_t_input, "Input table
      i_final_output  TYPE ty_t_input, "Success records table
*&-->Begin of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
      i_input_error   TYPE ty_t_input, "Error records in the input file
      gv_flag         TYPE flag,       " General Flag
      gv_file         TYPE char1024,   "localfile,  "File name
*&<--End of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
      gv_col_pos     TYPE sycucol,              " Horizontal Cursor Position at PAI
      i_alv_fieldcat  TYPE slis_t_fieldcat_alv, " ALV Field catalogue
      i_input_a       TYPE ty_t_input,          "Input table
      i_log_char      TYPE ty_t_log_char,       "Log table
      i_log_char_file TYPE ty_t_log_char,       "Log table
      wa_log          TYPE ty_final,            "Work Area for log table
      gv_uom          TYPE meins,               " Unit of Measure for Display
      gv_file_appl    TYPE localfile,           "File name
*&-->Begin of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
      wa_indx         TYPE indx,          " System Table INDX
      i_log_backg     TYPE ty_t_log_char, "Log table
      gv_file_app     TYPE char1024,     "File name
*&<--End of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
      gv_return       TYPE sysubrc,   "Return Code
      gv_archive_gl_1 TYPE localfile, "Archived file path 1
      gv_scount       TYPE int4,      "Succes Count
      gv_ecount       TYPE int4,      "Error Count
      gv_extn         TYPE char4,     "File Extension.
      gv_err_file     TYPE localfile, " Local file for upload/download
      gv_tbp_file     TYPE localfile, " Local file for upload/download
      gv_done_file    TYPE localfile. " Local file for upload/download
*&<--End of changes for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018

* Internal Table Declaration
DATA:
      i_edd_emi      TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status for EDD
      i_lvbmtv       TYPE  TABLE OF vbmtv,                   " View: Order Items for Material
      i_orders       TYPE TABLE OF bapiorders,               " View: Order Items for Material
      i_lseltab      TYPE TABLE OF rkask.                    " Table of selection criteria

CONSTANTS :
      c_true            TYPE c VALUE 'X', " True of type Character
      c_field_style     TYPE string VALUE 'FIELD_STYLE',
      c_color_cell      TYPE string VALUE 'COLOR_CELL',
      c_color_row       TYPE string VALUE 'COLOR_ROW',
*&-->Begin of changes for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018
       c_colon           TYPE char1        VALUE ':',                              " Colon
      c_tab             TYPE char1   VALUE cl_abap_char_utilities=>horizontal_tab, " Tab of type CHAR1
      c_file_type       TYPE char10  VALUE 'ASC',                                  " ASC
      c_sep             TYPE char01  VALUE 'X',                                    " Separator
      c_text            TYPE char4   VALUE 'XLSX'.                                 " Extension .TXT
*&<--End of changes for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018

FIELD-SYMBOLS:
      <fs_batch> TYPE ty_batch_final,
*      <fs_repid> TYPE string.
*&-->Begin of changes for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018
      <fs_input> TYPE ty_input.
*&<--End of changes for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018
