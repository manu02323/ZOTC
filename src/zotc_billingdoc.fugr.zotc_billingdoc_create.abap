************************************************************************
* PROGRAM    :  ZOTC_BILLINGDOC_CREATE                                 *
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
FUNCTION zotc_billingdoc_create.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     VALUE(CHNG_BILLINGDATAIN) TYPE  ZOTC_TT_BILLINGDATAIN
*"----------------------------------------------------------------------
  DATA : li_errors        TYPE STANDARD TABLE OF bapivbrkerrors,  " Information on Incorrect Processing of Preceding Items
         li_return        TYPE STANDARD TABLE OF bapiret1,        " Return Parameter
         li_success       TYPE STANDARD TABLE OF bapivbrksuccess. " Information for Successfully Processing Billing Doc. Items
  CALL FUNCTION 'BAPI_BILLINGDOC_CREATEMULTIPLE'
    TABLES
      billingdatain = chng_billingdatain
      errors        = li_errors
      return        = li_return
      success       = li_success.

* Error handling is not done here after calling the BAPI, as the BAPI---
* ---was called earlier in test run mode in include program ZOTCN0336O_IC_INVOICE_FORM --
* ---to check for any errors.
ENDFUNCTION.
