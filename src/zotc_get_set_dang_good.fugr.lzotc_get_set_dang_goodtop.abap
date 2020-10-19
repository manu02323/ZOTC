************************************************************************
* PROGRAM    :  LZOTC_GET_SET_DANG_GOODTOP(Include)                    *
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
FUNCTION-POOL zotc_get_set_dang_good. "MESSAGE-ID ..

* INCLUDE LZOTC_GET_SET_DANG_GOODD...        " Local class definition

DATA: gv_dang_good TYPE char1. " Item category group from material master
