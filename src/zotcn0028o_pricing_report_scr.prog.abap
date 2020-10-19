*&---------------------------------------------------------------------*
*&  Include           ZOTCR0028O_PRICING_REPORT_SCR
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCR0028O_PRICING_REPORT_SCR                          *
* TITLE      :  Pricing Report for Mass Price Upload                   *
* DEVELOPER  :  ROHIT VERMA                                            *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_RDD_0028_Pricing Report for Mass Price Upload      *
*----------------------------------------------------------------------*
* DESCRIPTION: This is an include program of Report                    *
*              ZOTCN0028O_PRICING_REPORT. All selection parameters of  *
*              selection screen are declared in this include program.  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 22-Jul-2013 RVERMA   E1DK910844 INITIAL DEVELOPMENT - CR#410         *
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
  PARAMETERS: p_kschl TYPE kscha OBLIGATORY.  "Condition Type
SELECTION-SCREEN END OF BLOCK b1.
