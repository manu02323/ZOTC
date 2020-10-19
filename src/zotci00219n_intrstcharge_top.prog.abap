*&---------------------------------------------------------------------*
*&  Include           ZOTCI00219N_INTRSTCHARGE_TOP
*&---------------------------------------------------------------------*
************************************************************************
* INCLUDE    : ZOTCI00219N_INTRSTCHARGE_TOP                            *
* TITLE      : Send Intrest Charges to fabn                            *
* DEVELOPER  : Manoj Thatha                                            *
* OBJECT TYPE: Interface                                               *
* SAP RELEASE: SAP ECC 6.0                                             *
*----------------------------------------------------------------------*
* WRICEF ID  : D3_OTC_IDD_0219                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: Include for Local Class Definition & Implementation     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT   DESCRIPTION                       *
* ===========  ========  ==========  ==================================*
* 10-FEB-2018  MTHATHA   E1DK934654  Initial Development               *
*----------------------------------------------------------------------*
TABLES:bkpf. " Accounting Document Header
*----------------------------------------------------------------------*
*          D E F E R R E D   C L A S S   D E F I N I T I O N           *
*----------------------------------------------------------------------*
CLASS lcl_sel_screen DEFINITION DEFERRED. " Selection Screen Class
CLASS lcl_process    DEFINITION DEFERRED. " Processing Class
*----------------------------------------------------------------------*
*               R E F E R E N C E   V A R I A B L E S                  *
*----------------------------------------------------------------------*
DATA:
*&--Selection  Screen Class
 ##needed gref_selscr  TYPE REF TO lcl_sel_screen,    " Sel Screen Class
*&--Processing Class
 ##needed gref_process TYPE REF TO lcl_process, " Process class
*&--Exception Class
 ##needed gref_exce    TYPE REF TO cx_crm_genil_general_error. " Exceptn
