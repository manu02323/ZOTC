*&---------------------------------------------------------------------*
*&  Include           ZOTCB_EDD_0214_PAYMENT_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCB_EDD_0214_PAYMENT                                 *
* TITLE      :  Mexico Payment Supplement for Trailix                  *
* DEVELOPER  :  Srinivasa Gurijala                                     *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D3_OTC_IDD_0214 SCTASK0515243                            *
*----------------------------------------------------------------------*
* DESCRIPTION: This Program is to Create a Payment Supplement File for *
*              Mexico Trailix.                                         *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 31-Aug-2017 U033814  E1DK930729 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*

TYPES : BEGIN OF ty_final,
        belnr  TYPE belnr_d,    " Accounting Document Number
        xmlid TYPE sxmsmguid,   " IDoc number
        status TYPE bapi_mtype, " Message type: S Success, E Error, W Warning, I Info, A Abort
        message TYPE bapi_msg,  " Message Text
        END OF ty_final.


DATA : gt_bseg TYPE STANDARD TABLE OF bseg INITIAL SIZE 0 ##NEEDED, " Accounting Document Segment
       gt_bsegt TYPE STANDARD TABLE OF bseg INITIAL SIZE 0 ##NEEDED, " Accounting Document Segment
       gt_bkpf TYPE STANDARD TABLE OF bkpf INITIAL SIZE 0 ##NEEDED, " Accounting Document Header
       gt_bsad TYPE STANDARD TABLE OF bsad INITIAL SIZE 0 ##NEEDED, " Accounting: Secondary Index for Customers (Cleared Items)
       gt_bsid TYPE STANDARD TABLE OF bsid INITIAL SIZE 0 ##NEEDED, " Accounting: Secondary Index for Customers
       gv_belnr TYPE belnr_d,                              " Accounting Document Number
       gv_blart TYPE blart,                                " Document Type
       gv_msg   TYPE bapi_msg ##NEEDED,                            " Message Text
       gv_subrc   TYPE bapi_mtype ##NEEDED,                         " Message type: S Success, E Error, W Warning, I Info, A Abort
       gv_kunnr TYPE kunnr,                                " Customer Number
       gt_final  TYPE STANDARD TABLE OF ty_final INITIAL SIZE 0 ##needed,
       gt_fcat   TYPE slis_t_fieldcat_alv ##needed.

CONSTANTS:
            c_top_page    TYPE slis_formname  VALUE 'F_TOP_OF_PAGE',
            c_user        TYPE char30         VALUE 'F_USER_COMMAND' ##needed, " User of type CHAR30
            c_save_a      TYPE char1          VALUE 'A'.                       "A

TYPES :ty_t_bseg TYPE STANDARD TABLE OF bseg , " Accounting Document Segment
       ty_t_zrtr_mx_einvoice_i TYPE STANDARD TABLE OF  zrtr_mx_einvoice,
       ty_t_bkpf TYPE STANDARD TABLE OF bkpf , " Accounting Document Header
       ty_t_bsad TYPE STANDARD TABLE OF bsad,  " Accounting: Secondary Index for Customers (Cleared Items)
       ty_t_bsid TYPE STANDARD TABLE OF bsid . " Accounting: Secondary Index for Customers
