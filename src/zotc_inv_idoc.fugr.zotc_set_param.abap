************************************************************************
* PROGRAM    :  ZOTC_SET_PARAM                                         *
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
* 05-Nov-2014 APODDAR  E2DK900887 CR D2_237  Restriction of Segments   *
*                                 based on Partner and Material Group  *
*&---------------------------------------------------------------------*

FUNCTION zotc_set_param.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_DEL_FLAG) TYPE  FLAG OPTIONAL
*"     REFERENCE(IM_TABIX) TYPE  SY-TABIX OPTIONAL
*"     REFERENCE(IM_STATUS_EMI) TYPE  ZOTC_TT_DEV_ENH_STATUS OPTIONAL
*"     REFERENCE(IM_TBL_VBRP) TYPE  ZOTC_TT_VBRP OPTIONAL
*"     REFERENCE(IM_TBL_SER01) TYPE  ZOTC_TT_SER01 OPTIONAL
*"     REFERENCE(IM_TBL_OBJK) TYPE  ZOTC_TT_OBJK OPTIONAL
*"     REFERENCE(IM_DOCREF) TYPE  Z_DOCREF OPTIONAL
*"     REFERENCE(IM_TBL_VBFA) TYPE  ZOTC_TT_VBFA OPTIONAL
*"     REFERENCE(IM_AUART) TYPE  AUART OPTIONAL
*"     REFERENCE(IM_AUDAT) TYPE  ANGDT_V OPTIONAL
*"     REFERENCE(IM_PO_TYPE) TYPE  BSARK OPTIONAL
*"----------------------------------------------------------------------

  IF im_del_flag IS SUPPLIED.
    gv_del_flag = im_del_flag.
  ENDIF.
  IF im_tabix IS SUPPLIED.
    gv_tabix    = im_tabix.
  ENDIF.
  IF im_status_emi IS SUPPLIED.
    i_status_emi[] = im_status_emi[].
  ENDIF.
  IF im_tbl_vbrp IS SUPPLIED.
    i_vbrp[] = im_tbl_vbrp[].
  ENDIF.
  IF im_tbl_ser01 IS SUPPLIED.
    i_ser01[] = im_tbl_ser01[].
  ENDIF.
  IF im_tbl_objk IS SUPPLIED.
    i_objk[] = im_tbl_objk[].
  ENDIF.
  IF im_docref IS SUPPLIED.
    gv_docref = im_docref.
  ENDIF.
  IF im_auart IS SUPPLIED.
    gv_auart = im_auart.
  ENDIF.
  IF im_po_type IS SUPPLIED.
    gv_po_type = im_po_type.
  ENDIF.
  IF im_audat IS SUPPLIED.
    gv_audat = im_audat.
  ENDIF.
  IF im_tbl_vbfa IS SUPPLIED.
    i_vbfa[] = im_tbl_vbfa[].
  ENDIF.

ENDFUNCTION.
