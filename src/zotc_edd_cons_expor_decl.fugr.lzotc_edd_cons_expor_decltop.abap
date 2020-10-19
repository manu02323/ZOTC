************************************************************************
* PROGRAM    :  ZOTC_EDD_CONS_EXPOR_DECLTOP                            *
* TITLE      :  ConsolExport Decl For HTS                              *
* DEVELOPER  :  Raghav sureddi                                         *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0415                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Create Consolidated invoice by calling                 *
*                     BAPI_BILLINGDOC_CREATEMULTIPLE                   *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 1-JUL-2018 U033876  E1DK918578 INITIAL DEVELOPMENT                  *
* =========== ======== ========== =====================================*

FUNCTION-POOL zotc_edd_cons_expor_decl. "MESSAGE-ID ..

* INCLUDE LZOTC_EDD_CONS_EXPOR_DECLD...      " Local class definition

*--TYPES---------------------------------------------------------------*
TYPES : BEGIN OF ty_delivery_header,
          vbeln TYPE vbeln_vl, " Delivery
          vkorg TYPE vkorg,    " Sales Organization
          lfart TYPE lfart,    " Delivery Type
          vbtyp TYPE vbtyp,    " SD document category
          kunag TYPE kunag,    " Sold-to party
          vkoiv TYPE vkoiv,    " Sales organization for intercompany billing
          vtwiv TYPE vtwiv,    " Distribution channel for intercompany billing
          waerk TYPE waerk,    " SD Document Currency
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
          vgbel TYPE vgbel,    " Document number of the reference document
          vgpos TYPE vgpos,    " Item number of the reference item
          uecha TYPE uecha,
        END OF ty_delivery_items,
*--TABLE TYPES---------------------------------------------------------*
        ty_t_delv_header    TYPE STANDARD TABLE OF ty_delivery_header, "Delivery header
        ty_t_delv_items     TYPE STANDARD TABLE OF ty_delivery_items,  "Delivery item
        ty_t_zdev_enh       TYPE STANDARD TABLE OF zdev_enh_status,    " Enhancement Status
        ty_t_bapikomv       TYPE STANDARD TABLE OF bapikomv,           " Communication Fields for Conditions
        ty_t_billingdatain  TYPE STANDARD TABLE OF bapivbrk,           " Communication Fields for Billing Header Fields
        ty_t_bapikomfktx    TYPE STANDARD TABLE OF bapikomfktx,        " Communication Structure Texts for Billing Interface
        ty_t_errors         TYPE STANDARD TABLE OF bapivbrkerrors,     " Information on Incorrect Processing of Preceding Items
        ty_t_return         TYPE STANDARD TABLE OF bapiret1,           " Return Parameter
        ty_t_success        TYPE STANDARD TABLE OF bapivbrksuccess.    " Information for Successfully Processing Billing Doc. Items
DATA:   gv_copy_cond        TYPE boole_d, " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
        gv_bom              TYPE boole_d. " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
*--CONSTANTS-----------------------------------------------------------*
CONSTANTS : c_succe_s    TYPE bapi_mtype   VALUE 'S',   " Message type: S Success, E Error, W Warning, I Info, A Abort
            c_error_e    TYPE bapi_mtype   VALUE 'E',   " Message type: S Success, E Error, W Warning, I Info, A Abort
            c_error_a    TYPE bapi_mtype   VALUE 'A',   " Message type: S Success, E Error, W Warning, I Info, A Abort
            c_zhu        TYPE fkart        VALUE 'ZHU'. " Billing Type
