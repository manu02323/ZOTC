*&---------------------------------------------------------------------*
*&  Include           ZXVVFTOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZXVVFU04                                               *
* TITLE      :  Revaluation due to new Budget Standard Cost            *
* DEVELOPER  :  Sneha Ghosh                                            *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   OTC_EDD_0103_Revaluation due to new Budget Standard Cost*
*----------------------------------------------------------------------*
* DESCRIPTION:  Revaluation due to new Budget Standard Cost            *
*                                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
*27-NOV-2013  SGHOSH    E1DK912332   INITIAL DEVELOPMENT - CR#781      *
*&---------------------------------------------------------------------*
************************************************************************
*                     GLOBAL DATA DECLARATION                          *
************************************************************************

TYPES: BEGIN OF ty_zotc_pctrl,
        mparameter TYPE enhee_parameter,        "Parameter
        mvalue1 TYPE z_mvalue_low,              "Value-low
      END OF ty_zotc_pctrl.

DATA: gv_wadat_ist TYPE wadat_ist,      "Variable for Actual Goods Movement Date
      gv_vgbel TYPE vgbel.              "Variable for Reference document number

DATA: i_zotc_pctrl TYPE STANDARD TABLE OF ty_zotc_pctrl.  "Internal Table of ZOTC_PRC_CONTROL
