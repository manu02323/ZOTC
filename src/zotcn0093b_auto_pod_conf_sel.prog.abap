*&---------------------------------------------------------------------*
*&  Include           ZOTCN0093B_AUTO_POD_CONF_SEL
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCR0093B_AUTO_POD_CONF_SEL                           *
* TITLE      :  OTC_EDD_0093_AUTOMATE POD CONFIRMATION                 *
* DEVELOPER  :  Sneha Mukherjee                                        *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                           *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_EDD_0093_AUTOMATE POD CONFIRMATION                 *
*----------------------------------------------------------------------*
* DESCRIPTION: A program which will run in background through batch job*
*              to identify POD relevant deliveries with zero quality and
*              run VLPOD transaction for those deliveries.             *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 02-Dec-13  SMUKHER   E1DK912327  INITIAL DEVELOPMENT                 *
* 24-Feb-13  SMUKHER   E1DK912327  CR#1229: Included logic to fetch all*
*                                  Delivery documents in the report,   *
*                                  New output parameters included as   *
*                                  well and updated functionality to   *
*                                  update all deliveries as a radio    *
*                                  button                              *
*&---------------------------------------------------------------------*

*--------------------------------------------------------------------*
*            SELECTION SCREEN
*--------------------------------------------------------------------*

* Selection screen for parameters

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
* Select option for Incoterms Part1 which is optional.
SELECT-OPTIONS s_inco1 FOR gv_inco1 MATCHCODE OBJECT h_tinc.

* Select option for Shipping Conditions which is Optional.
SELECT-OPTIONS s_vsbed FOR gv_vsbed MATCHCODE OBJECT h_tvsb.

* Select option for Creation Date which is Mandatory.
SELECT-OPTIONS s_erdat FOR gv_erdat OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

*&&-- BOC CR#1229

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-001.
PARAMETERS : rb_dev RADIOBUTTON GROUP rad
             DEFAULT 'X', "Deliveries with 0 quantity
             rb_aldev RADIOBUTTON GROUP rad."All deliveries
SELECTION-SCREEN END OF BLOCK b2.

**&&-- EOC CR#1229
