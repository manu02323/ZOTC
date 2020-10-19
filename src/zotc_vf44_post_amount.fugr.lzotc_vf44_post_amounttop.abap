************************************************************************
* Program          :  ZOTC_VF44_POST_AMOUNT (Function pool)            *
* TITLE            :  Transfer of Quantity and Value Fields            *
* DEVELOPER        :  NASRIN ALI                                       *
* OBJECT TYPE      :  ENHANCEMENT                                      *
* SAP RELEASE      :  SAP ECC 6.0                                      *
*----------------------------------------------------------------------*
*  WRICEF ID       :  D3_OTC_EDD_0337                                  *
*----------------------------------------------------------------------*
* DESCRIPTION      :  Transfer of Quantity and Value Fields            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER     TRANSPORT   DESCRIPTION                        *
* ===========  ======== ==========  ===================================*
* 01-JUN-2016  NALI     E1DK918440  INITIAL DEVELOPMENT                *
*&---------------------------------------------------------------------*
FUNCTION-POOL zotc_vf44_post_amount. "MESSAGE-ID ..

* INCLUDE LZOTC_VF44_POST_AMOUNTD...         " Local class definition

*TYPES: BEGIN OF ty_xlips,
*        vbeln  TYPE vbeln_vl,
*        posnr  TYPE posnr_vl,
*        lfimg  TYPE lfimg,
*        meins  TYPE meins,
*        vrkme  TYPE vrkme,
*       END OF ty_xlips,


types: BEGIN OF ty_fklmg_sum,
         vbeln TYPE vbeln_va, " Sales Document
         posnr TYPE posnr_va, " Sales Document Item
         sakrv TYPE saknr,    " G/L Account Number
         fklmg TYPE fklmg,    " Billing quantity in stockkeeping unit
         vrkme TYPE vrkme,    " Sales unit
         meins TYPE meins,    " Base Unit of Measure
       END OF ty_fklmg_sum.

DATA: "i_xlips TYPE STANDARD TABLE OF ty_xlips INITIAL SIZE 0 ##NEEDED,
      i_fklmg_sum TYPE STANDARD TABLE OF ty_fklmg_sum INITIAL SIZE 0 ##NEEDED.

DATA: BEGIN OF i_XLIPS OCCURS 0.
  INCLUDE STRUCTURE LIPS.
DATA: END OF i_XLIPS.
