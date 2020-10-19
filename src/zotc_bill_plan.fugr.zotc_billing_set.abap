* Function   : ZOTC_BILLING_SET                       *
* TITLE      :   D2_OTC_EDD_0179_ Billing Plan Type Update             *
* DEVELOPER  :  Paramita Bose                                          *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 7.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:     D2_OTC_EDD_0179_ Billing Plan Type Update             *
*----------------------------------------------------------------------*
* DESCRIPTION: Implement the logic to populate Billing plan type(FPART)*
*              whenService Max Feed is equal to 2.                     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE             USER         TRANSPORT      DESCRIPTION             *
* ===========    ========      ==========     =========================*
* 18-JUL-2014    PBOSE         E2DK901255     INITIAL DEVELOPMENT      *
*&---------------------------------------------------------------------*

FUNCTION ZOTC_BILLING_SET.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_SO_ITEM) TYPE  SAPPLCO_SLS_ORD_ERPCRTE_R_TAB7
*"----------------------------------------------------------------------
 CLEAR: I_SO_ITEM.
 I_SO_ITEM = IM_SO_ITEM.
ENDFUNCTION.
