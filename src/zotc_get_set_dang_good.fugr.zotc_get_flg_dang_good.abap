************************************************************************
* PROGRAM    :  ZOTC_GET_FLG_DANG_GOOD(Function Module)                *
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
FUNCTION ZOTC_GET_FLG_DANG_GOOD.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_GET_DANG_GOOD) TYPE  CHAR1 OPTIONAL
*"----------------------------------------------------------------------

*This Function Module gets the value of the flag to assign it to the
*global variable gv_dang_good.
gv_dang_good = im_get_dang_good.

ENDFUNCTION.
