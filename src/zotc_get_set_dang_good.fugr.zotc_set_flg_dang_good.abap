************************************************************************
* PROGRAM    :  ZOTC_SET_FLG_DANG_GOOD(Function Module)                *
* TITLE      :  ES Sales Order Simulation                              *
* DEVELOPER  :  Shruti Gupta                                           *
* OBJECT TYPE:  Function Module                                        *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  D2_OTC_IDD_0095                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: Function Module for D2_OTC_IDD_0095.To identify the     *
*              order containing a Hazardous Product.                   *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 27-JAN-2015 SGUPTA4  E2DK900492 CR D2_437, To identify the order     *
*                                 containing a Hazardous Product       *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

FUNCTION ZOTC_SET_FLG_DANG_GOOD.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(EX_SET_DANG_GOOD) TYPE  CHAR1
*"----------------------------------------------------------------------


* Sets the value of Exporting parameter whose value is passed on to
* VBAK-CONT_DG, which is used to identify a Hazardous Product.
ex_set_dang_good = gv_dang_good.

*Clear the value of flag gv_dang_good
CLEAR gv_dang_good.

ENDFUNCTION.
