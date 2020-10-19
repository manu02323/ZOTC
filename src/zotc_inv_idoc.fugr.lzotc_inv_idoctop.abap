************************************************************************
* PROGRAM    :  LZOTC_INV_IDOCTOP                          *
* TITLE      :  D2_OTC_IDD_0099                                        *
* DEVELOPER  :  Avik Poddar                                            *
* OBJECT TYPE:  Include                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_IDD_0099_SAP Invoice to ServiceMax              *
*----------------------------------------------------------------------*
* DESCRIPTION: SAP Invoice to ServiceMax                               *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 05-Nov-2014 APODDAR  E2DK900887 CR D2_237  Restriction of Segments   *
*                                 based on Partner and Material Group  *
*&---------------------------------------------------------------------*
FUNCTION-POOL zotc_inv_idoc. "MESSAGE-ID ..

* INCLUDE LZOTC_INV_IDOCD...                 " Local class definition

DATA: gv_del_flag TYPE flag,     " General Flag
      gv_tabix    TYPE sy-tabix, " Index of Internal Tables
      gv_docref   TYPE z_docref, " Legacy Doc Ref
      gv_auart    TYPE auart,    " Sales Document Type
      gv_audat    TYPE angdt_v,  " Quotation/Inquiry is valid from
      gv_po_type  TYPE bsark,

i_status_emi type table of zdev_enh_status, " Enhancement Status
i_vbrp       type          zotc_tt_vbrp,
i_ser01      type          zotc_tt_ser01,
i_objk       type          zotc_tt_objk,
i_vbfa       type          zotc_tt_vbfa.
