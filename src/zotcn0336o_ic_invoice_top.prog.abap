************************************************************************
* PROGRAM    :  ZOTCR0336O_IC_INVOICE_TOP                              *
* TITLE      :  EHQ_Delivery Output Routine                            *
* DEVELOPER  :  Salman Zahir                                           *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0336                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Create intercompany invoice after PGI by calling       *
*                     BAPI_BILLINGDOC_CREATEMULTIPLE                   *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 12-JUN-2016 U033959  E1DK918578 INITIAL DEVELOPMENT                  *
* =========== ======== ========== =====================================*

*&---------------------------------------------------------------------*
*&  Include           ZOTCN0336O_IC_INVOICE_TOP
*&---------------------------------------------------------------------*


*--CONSTANTS-----------------------------------------------------------*
CONSTANTS : c_error_e    TYPE bapi_mtype  VALUE 'E',           " Message type: S Success, E Error, W Warning, I Info, A Abort
            c_error_a    TYPE bapi_mtype  VALUE 'A',           " Message type: S Success, E Error, W Warning, I Info, A Abort
            c_object     TYPE balobj_d    VALUE 'ZOTCLOG',     " Application Log: Object Name (Application Code)
            c_sub_object TYPE balsubobj   VALUE 'ZOTCEDD0336', " Application Log: Subobject
            c_nast       TYPE tabname     VALUE 'NAST'.        " Table Name

*--TYPES---------------------------------------------------------------*
TYPES : BEGIN OF ty_delivery_header,
          vbeln TYPE vbeln_vl, " Delivery
          vbtyp TYPE vbtyp,    " SD document category
          vkoiv TYPE vkoiv,    " Sales organization for intercompany billing
          vtwiv TYPE vtwiv,    " Distribution channel for intercompany billing
          spaiv TYPE spaiv,    " Division for intercompany billing
          fkaiv TYPE fkaiv,    " Billing type for intercompany billing
          fkdiv TYPE fkdiv,    " Billing date for intercompany billing
          kuniv TYPE kuniv,    " Customer number for intercompany billing
        END OF ty_delivery_header,
        BEGIN OF ty_delivery_items,
          vbeln TYPE vbeln_vl, " Delivery
          posnr TYPE posnr_vl, " Delivery Item
          pstyv TYPE pstyv_vl, " Delivery item category
          matnr TYPE matnr,    " Material Number
          werks TYPE werks_d,  " Plant
          lfimg TYPE lfimg,    " Actual quantity delivered (in sales units)
          vrkme TYPE vrkme,    " Sales unit
        END OF ty_delivery_items,
*--TABLE TYPES---------------------------------------------------------*
        ty_t_delv_header    TYPE STANDARD TABLE OF ty_delivery_header, "Delivery header
        ty_t_delv_items     TYPE STANDARD TABLE OF ty_delivery_items,  "Delivery item
        ty_t_billingdatain  TYPE STANDARD TABLE OF bapivbrk,           " Communication Fields for Billing Header Fields
        ty_t_errors         TYPE STANDARD TABLE OF bapivbrkerrors,     " Information on Incorrect Processing of Preceding Items
        ty_t_return         TYPE STANDARD TABLE OF bapiret1,           " Return Parameter
        ty_t_success        TYPE STANDARD TABLE OF bapivbrksuccess.    " Information for Successfully Processing Billing Doc. Items
