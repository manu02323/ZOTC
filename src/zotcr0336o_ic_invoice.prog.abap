************************************************************************
* PROGRAM    :  ZOTCR0336O_IC_INVOICE                                  *
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
*& Report  ZOTCR0336O_IC_INVOICE
*&
*&---------------------------------------------------------------------*

REPORT zotcr0336o_ic_invoice MESSAGE-ID zotc_msg
                          LINE-COUNT 80
                          LINE-SIZE  80
                          NO STANDARD PAGE HEADING.

*--INCLUDES------------------------------------------------------------*
INCLUDE zotcn0336o_ic_invoice_top  IF FOUND.
INCLUDE zotcn0336o_ic_invoice_form IF FOUND.
