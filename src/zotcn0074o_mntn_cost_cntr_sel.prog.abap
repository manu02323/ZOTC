************************************************************************
* PROGRAM    :  ZOTCN0074O_MNTN_COST_CNTR_SEL                          *
* TITLE      :  OTC_EDD_0074_Sales Rep Cost Center Assignment          *
* DEVELOPER  :  Debraj Haldar                                         *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_EDD_0074                                           *
*----------------------------------------------------------------------*
* DESCRIPTION: Include for Selection Screen                            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 30-JUN-2012 DHALDAR  E1DK903043 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*

*Declaration of selection screen block with select options
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

SELECT-OPTIONS:
* Select option for Sales doc type
s_auart FOR gv_auart,
* Select option for vkorg
s_vkorg FOR gv_vkorg,
* Select option for customer
s_kunnr FOR gv_kunnr.

SELECTION-SCREEN SKIP.

PARAMETERS: rb_edt   RADIOBUTTON GROUP rb1  DEFAULT 'X',
            rb_src   RADIOBUTTON GROUP rb1 .



SELECTION-SCREEN END OF BLOCK b1.
