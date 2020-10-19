************************************************************************
* PROGRAM    :  ZOTC_GET_PARAM                                         *
* TITLE      :  D2_OTC_IDD_0099                                        *
* DEVELOPER  :  Avik Poddar                                            *
* OBJECT TYPE:  Function Module                                        *
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
*&---------------------------------------------------------------------*
* 05-Nov-2014 APODDAR  E2DK900887 CR D2_237  Restriction of Segments   *
*                                 based on Partner and Material Group  *
*&---------------------------------------------------------------------*

FUNCTION zotc_get_param.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     REFERENCE(EX_DEL_FLAG) TYPE  FLAG
*"     REFERENCE(EX_TABIX) TYPE  SY-TABIX
*"     REFERENCE(EX_STATUS_EMI) TYPE  ZOTC_TT_DEV_ENH_STATUS
*"     REFERENCE(EX_TBL_VBRP) TYPE  ZOTC_TT_VBRP
*"     REFERENCE(EX_TBL_SER01) TYPE  ZOTC_TT_SER01
*"     REFERENCE(EX_TBL_OBJK) TYPE  ZOTC_TT_OBJK
*"     REFERENCE(EX_DOCREF) TYPE  Z_DOCREF
*"     REFERENCE(EX_TBL_VBFA) TYPE  ZOTC_TT_VBFA
*"     REFERENCE(EX_AUART) TYPE  AUART
*"     REFERENCE(EX_AUDAT) TYPE  ANGDT_V
*"     REFERENCE(EX_PO_TYPE) TYPE  BSARK
*"----------------------------------------------------------------------

  IF ex_del_flag IS REQUESTED.
    ex_del_flag     = gv_del_flag.
  ENDIF.
  IF ex_tabix IS REQUESTED.
    ex_tabix        = gv_tabix.
  ENDIF.
  IF ex_status_emi IS REQUESTED.
    ex_status_emi[] = i_status_emi[].
  ENDIF.
  IF ex_tbl_vbrp IS REQUESTED.
    ex_tbl_vbrp[]   = i_vbrp[].
  ENDIF.
  IF ex_tbl_ser01 IS REQUESTED.
    ex_tbl_ser01[]  = i_ser01[].
  ENDIF.
  IF ex_tbl_objk IS REQUESTED.
    ex_tbl_objk[]   = i_objk[].
  ENDIF.
  IF ex_docref IS REQUESTED.
    ex_docref       = gv_docref.

  ENDIF.
  IF ex_tbl_vbfa IS REQUESTED.
    ex_tbl_vbfa[]   = i_vbfa[].
  ENDIF.
  IF ex_auart IS REQUESTED.
    ex_auart        = gv_auart.
  ENDIF.
  IF ex_audat IS REQUESTED.
    ex_audat        = gv_audat.
  ENDIF.
  IF ex_po_type IS REQUESTED.
    ex_po_type      = gv_po_type.
  ENDIF.

ENDFUNCTION.
