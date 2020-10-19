*&---------------------------------------------------------------------*
*&  Include           ZOTCN0101B_PRICE_DATE_UPD_SCR
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0101B_PRICE_DATE_UPD_SCR                          *
* TITLE      :  Pricing Date Update Report                             *
* DEVELOPER  :  ROHIT VERMA                                            *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_EDD_0101_Pricing Date Update                       *
*----------------------------------------------------------------------*
* DESCRIPTION: This is an include program of Report                    *
*              ZOTCR0101B_PRICE_DATE_UPD. All selection parameters of  *
*              selection screen are declared in this include program.  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 03-Oct-2013 RVERMA   E1DK913507 INITIAL DEVELOPMENT - CR#649         *
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-001.
  SELECT-OPTIONS s_data FOR gv_data  "Data String
                        NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK blk1.
