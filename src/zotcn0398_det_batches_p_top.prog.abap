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
*                                                                      *
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
         matnr TYPE matnr,
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

DATA:
      i_batch     TYPE TABLE OF ty_batch_final,
      i_batch_a   TYPE TABLE OF ty_batch_final,
      i_batch_b   TYPE TABLE OF ty_batch_final,
      i_batch_c   TYPE TABLE OF ty_batch_final,
      i_batch_s   TYPE TABLE OF ty_batch_final,
      i_batch_m   TYPE TABLE OF ty_batch_final,
      i_batch_d   TYPE TABLE OF ty_batch_final,
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
      gv_repid       TYPE sy-repid.

* Internal Table Declaration
DATA:
      i_edd_emi      TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status for EDD
      i_orders       TYPE TABLE OF bapiorders,               " View: Order Items for Material
      i_lvbmtv       TYPE TABLE OF vbmtv,                    " View: Order Items for Material
      i_lseltab      TYPE TABLE OF rkask.                    " Table of selection criteria

CONSTANTS :
      c_true            TYPE c VALUE 'X', " True of type Character
      c_field_style     TYPE string VALUE 'FIELD_STYLE',
      c_color_cell      TYPE string VALUE 'COLOR_CELL',
      c_color_row       TYPE string VALUE 'COLOR_ROW'.

FIELD-SYMBOLS:
      <fs_batch> TYPE ty_batch_final.
*      <fs_repid> TYPE string.
