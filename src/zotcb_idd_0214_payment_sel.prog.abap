*&---------------------------------------------------------------------*
*&  Include           ZOTCB_EDD_0214_PAYMENT_SEL
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

SELECTION-SCREEN BEGIN OF BLOCK blk01 WITH FRAME
                                    TITLE text-001.
PARAMETERS : p_bukrs TYPE bukrs DEFAULT '1103' OBLIGATORY, " Company Code
             p_gjahr TYPE gjahr ,                          " Fiscal Year
             p_cpudt TYPE cpudt OBLIGATORY default sy-datum.                " Day On Which Accounting Document Was Entered


SELECT-OPTIONS :
                s_blart FOR gv_blart,
                s_belnr FOR gv_belnr,
                s_kunnr FOR gv_kunnr.
PARAMETERS :    P_REG AS CHECKBOX DEFAULT SPACE.

SELECTION-SCREEN END OF BLOCK blk01.
