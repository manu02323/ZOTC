************************************************************************
* PROGRAM    :  ZOTCN0136O_CUSTOM_FIELDS                               *
* TITLE      :  D2_OTC_EDD_0136_Custom fields in Sales Order           *
* DEVELOPER  :  Rajendra K Panigrahy                                   *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  D2_OTC_EDD_0136                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: Include for D2_OTC_EDD_0136                             *
*                                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 13-MAY-2014 RPANIGR  E2DK900492 Initial Development                  *
*&---------------------------------------------------------------------*
* 10-Oct-2014 RPANIGR  E2DK900492 D2_OTC_EDD_0136/CR-174               *
* CR-174 Screen validation for Reference document when Doc. type input *
* is 06(SAP Document No.)                                              *
* 13-JAN-2015 SGUPTA4  E2DK900492 D2_OTC_EDD_0136/CR D2_253, screen    *
*                                 validation for fields ZZ_BILMET and  *
*                                 ZZ_BILFR.                            *
*30-JAN-2015  SGUPTA4  E2DK900492 CR D2_253/2nd Change, Authorization  *
*                                 check has been added for ServiceMax  *
*                                 Obj ID.                              *
* 18-Feb-2015  DMOIRAN E2DK900492  D2_OTC_IDD_0235 Added logic for ship
*                                  complete field.
*06-May-2016  LMAHEND  E2DK917765  D2_OTC_EDD_0136_Defect# 1060,Diasble*
*                                  BOM Component fields while          *
*                                  creating/Changing Sales order With  *
*                                  BOM Material                        *
*{   INSERT         E1DK919119                                        1
* 21-Nov-16   APAUL    E1DK919119  D3 CR#246 Validation and  value help*
*                                  for new fields  for  Cost centre at *
*                                  item   level.                       *
*}   INSERT
* 29-Aug-2017   SMUKHER4   E1DK930261
*                                    D3_OTC_EDD_0136_Defect# 2831,Enable *
*                                    couple fields to be editable for    *
*                                    sales order with BOM Material which *
*                                    were disabled with Defect# 1060     *
*                                   No fields of BOM components should be*
*                                   editable except Batch and schedule   *
*                                  line delivery block. Batch field      *
*                                  should be editable only if material   *
*                                  is batch managed.
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
***INCLUDE ZOTCN0136O_CUSTOM_FIELDS.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  ZZMOD_HEADER_SUBSCR_ENABLE  OUTPUT
*&---------------------------------------------------------------------*
*       Module for order header additional screen fields enable/disable
*----------------------------------------------------------------------*
MODULE zzmod_header_subscr_enable OUTPUT.
  PERFORM f_hdr_custom_fields.
ENDMODULE. " ZZMOD_HEADER_SUBSCR_ENABLE  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  F_HDR_CUSTOM_FIELDS
*&---------------------------------------------------------------------*
*       Form Routine for Screen fields enable/disable based on order create/change/display
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_hdr_custom_fields .
*******************************************************************
*=======================Data Declaration==========================*
*******************************************************************
*Constants declaration for Transaction Type
  CONSTANTS: lc_h TYPE char1 VALUE 'H',                     " H of type CHAR1
             lc_v TYPE char1 VALUE 'V',                     " V of type CHAR1
             lc_docref  TYPE char14 VALUE 'VBAK-ZZDOCREF',  " Docref of type CHAR14
             lc_doctype TYPE char14 VALUE 'VBAK-ZZDOCTYP',  " Doctype of type char14
             lc_caseref TYPE char14 VALUE 'VBAK-ZZCASEREF', " Caseref of type CHAR14
* ---> Begin of Insert for D2_OTC_EDD_0235 by DMOIRAN
             lc_shipcomp    TYPE fieldname        VALUE 'VBAK-ZZSHIPCOMP', " Field Name
             lc_edd_0235    TYPE z_enhancement    VALUE 'D2_OTC_EDD_0235', " Enhancement
             lc_lfstk       TYPE z_criteria       VALUE 'LFSTK',           " Enh. Criteria
             lc_vbtyp       TYPE z_criteria       VALUE 'VBTYP'.           " Enh. Criteria

  DATA:  li_edd_0235_status  TYPE STANDARD TABLE OF zdev_enh_status. " Enhancement Status
* <--- End    of Insert for D2_OTC_EDD_0235 by DMOIRAN
*******************************************************************
*=======================Screen processing=========================*
*******************************************************************
* ---> Begin of Insert for D2_OTC_EDD_0235 by DMOIRAN
* Call to EMI Function Module To Get List Of EMI Statuses
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_edd_0235
    TABLES
      tt_enh_status     = li_edd_0235_status. "Enhancement status table

*Non active entries are removed.
  DELETE li_edd_0235_status WHERE active EQ abap_false.
* <--- End    of Insert for D2_OTC_EDD_0235 by DMOIRAN
*Screen Enable/Disable based on transaction type
  IF t180-trtyp = lc_h OR t180-trtyp = lc_v.
    LOOP AT SCREEN.
      IF screen-name = lc_docref OR screen-name =  lc_doctype OR screen-name =  lc_caseref.
        screen-input = 1.
      ENDIF. " IF screen-name = lc_docref OR screen-name = lc_doctype OR screen-name = lc_caseref

* ---> Begin of Insert for D2_OTC_EDD_0235 by DMOIRAN
* Check Order type and delivery status before making screen field Ship complete field editable
      IF screen-name = lc_shipcomp.
* check if delivery is not yet created.
        READ TABLE li_edd_0235_status WITH KEY criteria = lc_lfstk
                                               sel_low = vbuk-lfstk
                                               TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
* check order type is C
          READ TABLE li_edd_0235_status WITH KEY criteria = lc_vbtyp
                                                 sel_low = vbak-vbtyp
                                                TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            screen-input = 1.
          ELSE. " ELSE -> IF sy-subrc = 0
            screen-input = 0.
          ENDIF. " IF sy-subrc = 0
        ELSE. " ELSE -> IF sy-subrc = 0
          screen-input = 0.
        ENDIF. " IF sy-subrc = 0

      ENDIF. " IF screen-name = lc_shipcomp
* <--- End    of Insert for D2_OTC_EDD_0235 by DMOIRAN

      MODIFY SCREEN.
    ENDLOOP. " LOOP AT SCREEN
  ELSE. " ELSE -> IF t180-trtyp = lc_h OR t180-trtyp = lc_v
    LOOP AT SCREEN.
      IF screen-name = lc_docref OR screen-name =  lc_doctype OR screen-name =  lc_caseref.
        screen-input = 0.
      ENDIF. " IF screen-name = lc_docref OR screen-name = lc_doctype OR screen-name = lc_caseref
* ---> Begin of Insert for D2_OTC_EDD_0235 by DMOIRAN
* Check Order type and delivery status before making screen field Ship complete field editable
      IF screen-name = lc_shipcomp.
        screen-input = 0.
      ENDIF. " IF screen-name = lc_shipcomp
* <--- End    of Insert for D2_OTC_EDD_0235 by DMOIRAN
      MODIFY SCREEN.
    ENDLOOP. " LOOP AT SCREEN
  ENDIF. " IF t180-trtyp = lc_h OR t180-trtyp = lc_v


ENDFORM. " F_HDR_CUSTOM_FIELDS
*&---------------------------------------------------------------------*
*&      Module  ZZMOD_ITEM_SUBSCR_ENABLE  OUTPUT
*&---------------------------------------------------------------------*
*        Module for order item additional screen fields enable/disable
*----------------------------------------------------------------------*
MODULE zzmod_item_subscr_enable OUTPUT.
  PERFORM f_item_custom_fields.
ENDMODULE. " ZZMOD_ITEM_SUBSCR_ENABLE  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  F_ITEM_CUSTOM_FIELDS
*&---------------------------------------------------------------------*
*       Form Routine for Screen fields enable/disable based on order create/change/display
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_item_custom_fields .
*******************************************************************
*=======================Data Declaration==========================*
*******************************************************************
*Constants declaration for Transaction Type
  CONSTANTS: lc_h TYPE char1 VALUE 'H',                       " H of type CHAR1
             lc_v TYPE char1 VALUE 'V',                       " V of type CHAR1
             lc_servid   TYPE char14 VALUE 'VBAP-ZZAGMNT',    " Servid of type CHAR14
             lc_servtype TYPE char16 VALUE 'VBAP-ZZAGMNT_TYP',
             lc_quotref  TYPE char16 VALUE 'VBAP-ZZQUOTEREF', " Quotref of type CHAR16
             lc_itemref  TYPE char16 VALUE 'VBAP-ZZITEMREF',  " Itemref of type CHAR16
* ---> Begin of Insert for CR D2_253, D2_OTC_EDD_0136 by SGUPTA4
             lc_bilmeth     TYPE char14        VALUE 'VBAP-ZZ_BILMET',  " Bilmeth of type CHAR14
             lc_bilfreq     TYPE char13        VALUE 'VBAP-ZZ_BILFR',   " Bilfreq of type CHAR13
             lc_i           TYPE updkz_d       VALUE 'I',               " Update indicator
             lc_edd_0136    TYPE z_enhancement VALUE 'D2_OTC_EDD_0136', " Enhancement
             lc_pstyvv      TYPE z_criteria    VALUE 'PSTYVV'.          " Enh. Criteria

*Field Symbol Declaration
  FIELD-SYMBOLS: <lfs_edd_0136_status> TYPE zdev_enh_status. " Enhancement Status

* Local Data Declaration
  DATA: lv_pstyvv_zpln     TYPE                   pstyv,           " Sales document item category
        li_edd_0136_status TYPE STANDARD TABLE OF zdev_enh_status. " Enhancement Status
* <--- End   of Insert for CR D2_253, D2_OTC_EDD_0136 by SGUPTA4


*******************************************************************
*=======================Screen processing=========================*
*******************************************************************
*Screen Enable/Disable based on transaction type.
  IF t180-trtyp = lc_h OR t180-trtyp = lc_v.
    LOOP AT SCREEN.
      IF screen-name = lc_servid OR screen-name = lc_servtype OR screen-name = lc_quotref.
        screen-input = 1.
* ---> Begin of Insert for CR D2_253 2nd Change, D2_OTC_EDD_0136 by SGUPTA
      ELSEIF screen-name = lc_itemref.
*If user has authorization of below 'Authorization object' & transaction is for
*'Create/Change Sales Order',then make 'ServiceMax Obj ID' field as 'Editable'
        AUTHORITY-CHECK OBJECT 'ZZITEMREF' ID 'ACTVT' FIELD '02'.
*           If user does not have the authorizations, make it as 'display' only
        IF sy-subrc EQ 0.
*             Make Field Input editable
          screen-input = 1.
          MODIFY SCREEN.
        ELSE. " ELSE -> IF sy-subrc EQ 0
*             Make Field Input Disable (Display Only)
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF. " IF sy-subrc EQ 0
* <--- End   of Insert for CR D2_253 2nd Change, D2_OTC_EDD_0136 by SGUPTA4
      ENDIF. " IF screen-name = lc_servid OR screen-name = lc_servtype OR screen-name = lc_quotref
      MODIFY SCREEN.
    ENDLOOP. " LOOP AT SCREEN
  ELSE. " ELSE -> IF t180-trtyp = lc_h OR t180-trtyp = lc_v
    LOOP AT SCREEN.
      IF screen-name = lc_servid OR screen-name = lc_servtype OR screen-name = lc_quotref. "OR screen-name = lc_itemref.
        screen-input = 0.
      ELSEIF screen-name = lc_itemref.
* ---> Begin of Insert for CR D2_253 2nd Change, D2_OTC_EDD_0136 by SGUPTA4
        screen-input = 0.
* <--- End   of Insert for CR D2_253 2nd Change, D2_OTC_EDD_0136 by SGUPTA4
      ENDIF. " IF screen-name = lc_servid OR screen-name = lc_servtype OR screen-name = lc_quotref
      MODIFY SCREEN.
    ENDLOOP. " LOOP AT SCREEN
  ENDIF. " IF t180-trtyp = lc_h OR t180-trtyp = lc_v

ENDFORM. " F_ITEM_CUSTOM_FIELDS
*-->> Begin of change for D2_OTC_EDD_136-CR174/10-Oct-2014 by RPANIGR
*&---------------------------------------------------------------------*
*&      Module  ZZHEADER_CUSTFLD_VALIDATE  INPUT
*&---------------------------------------------------------------------*
*       Module to validate Reference documnet when Ref document type   *
*       is 06(SAP doc.)                                                *
*----------------------------------------------------------------------*
MODULE zzheader_custfld_validate INPUT.

* Cosnatants Declaration
  CONSTANTS: lc_doctyp_sapdoc TYPE z_doctyp      VALUE '06', " Ref Doc type
             lc_doc_ordertyp  TYPE vbtyp         VALUE 'C'.  " SD document category

* Data Declaration
  DATA: lv_vbeln TYPE vbeln_va. " Sales Document

* Check if the Reference document type being entered is a SAP Document number type
  IF vbak-zzdoctyp = lc_doctyp_sapdoc.

* If Reference document is left blank, raise Document must be a SAP document number
    IF vbak-zzdocref IS INITIAL.
      MESSAGE e166(zotc_msg). " Document number must be entered and should be a valid sales document
    ELSE. " ELSE -> IF vbak-zzdocref IS INITIAL

* If Reference document number is entered , check it is a SAP sales document only...
* ...if not, raise an error message as below
      SELECT SINGLE vbeln " Sales Document
             FROM vbak    " Sales Document: Header Data
             INTO lv_vbeln
             WHERE vbeln = vbak-zzdocref
             AND vbtyp = lc_doc_ordertyp.
      IF sy-subrc <> 0.
        MESSAGE e167(zotc_msg). " Document number entered is not a valid sales document
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF vbak-zzdocref IS INITIAL
  ENDIF. " IF vbak-zzdoctyp = lc_doctyp_sapdoc
ENDMODULE. " ZZHEADER_CUSTFLD_VALIDATE  INPUT
*--<< End of change for D2_OTC_EDD_136-CR174/10-Oct-2014 by RPANIGR

* Retrofit
************************************************************************
* PROGRAM    :  ZPTMN0098O_SCREEN_8459(Include)                        *
* TITLE      :  Update Screen 8459 (Additional Data-B) for the Z-field *
* DEVELOPER  :  Shushant Nigam                                         *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   CR544(PTM_EDD_0098)                                     *
*----------------------------------------------------------------------*
* DESCRIPTION: Do not allow auto ATP confirmation for BPX material     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================   *
* DATE         USER     TRANSPORT  DESCRIPTION                            *
* ============ ======== ========== ====================================   *
* 30-SEP-2013  SNIGAM   E1DK911644 INITIAL DEVELOPMENT                    *
* 19-Nov-2013  SGHOSH   E1DK911644 NEW ZFIELD ADDITION                    *
* 17-Apr-2014  SNIGAM   E1DK911644 For 'Customer Group' field, add        *
*                                  Authorization object so that it will   *
*                                 be in editable mode only for Customer   *
*                                  service people in VA01/VA02            *
* 29-Aug-2017   SMUKHER4   E1DK930261 D3_OTC_EDD_0136_Defect# 2831,Enable  *
*                                    couple fields to be editable for     *
*                                    sales order with BOM Material which  *
*                                    were disabled with Defect# 1060      *
*                                   No fields of BOM components should be *
*                                   editable except Batch and schedule    *
*                                   line delivery block. Batch field      *
*                                   should be editable only if material   *
*                                   is batch managed.                     *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_8459  OUTPUT
*&---------------------------------------------------------------------*
*       Module to Modify screen 8459
*----------------------------------------------------------------------*
MODULE modify_screen_8459 OUTPUT.

* Local Constants Decleration
  CONSTANTS: lc_screen_no TYPE sydynnr VALUE '8459',           " Current Screen Number
             lc_display   TYPE trtyp   VALUE 'A',              " Transaction type
             lc_change    TYPE trtyp   VALUE 'V',              "Added under CR-1280: SNIGAM : 04/17/2014
             lc_create    TYPE trtyp   VALUE 'H',              "Added under CR-1280: SNIGAM : 04/17/2014
             lc_zfield    TYPE char14  VALUE 'VBAP-ZZCONFIRM', " Zfield of type CHAR14
             lc_zfield1   TYPE char14  VALUE 'VBAP-ZZCUSTGRP'. "Customer Group New field added CR#128
* ---> Begin of Changes for D2_OTC_EDD_0136_Defect#1060 by LMAHEND on 06th May 2016

  FIELD-SYMBOLS: <lfs_status> TYPE zdev_enh_status, " Enhancement Status
                 <lfs_vbak>   TYPE vbak,            " Sales Document: Header Data
                 <lfs_vbap>   TYPE vbapvb.          " Document Structure for XVBAP/YVBAP

  CONSTANTS:lc_edd_0136    TYPE z_enhancement VALUE 'D2_OTC_EDD_0136', " Enhancement
            lc_auart       TYPE z_criteria    VALUE 'AUART_ZCPR',      " Enh. Criteria
*&-->Begin of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
            lc_field       TYPE z_criteria    VALUE 'NAME_FELD',  " Enh. Criteria
            lc_vbap_charg  TYPE char30        VALUE 'VBAP-CHARG', " Screen field
*&<--End of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
            lc_vbap        TYPE char30        VALUE '(SAPMV45A)XVBAP', " Vbap of type CHAR30
            lc_exclude     TYPE char1         VALUE 'E',               " Exclude of type CHAR1
            lc_vbak        TYPE char30        VALUE '(SAPMV45A)VBAK'.  " Vbak of type CHAR30

**//Data Declaration.
  DATA: li_edd_0136_status  TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status

*&-->Begin of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
        lv_xchpf TYPE flag,                             " General Flag
        li_emi_field TYPE STANDARD TABLE OF fkk_ranges, " Structure: Select Options
        lwa_status   TYPE zdev_enh_status,              " Enhancement Status
        lwa_field TYPE fkk_ranges.                      " Structure: Select Options
*&<--End of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
**//Authority Check
  AUTHORITY-CHECK OBJECT 'ZZITEMBOM'
  ID 'ACTVT' FIELD '02'.
  IF sy-subrc NE 0.
**//Call Function Module To Get the EMI Entries.
    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
      EXPORTING
        iv_enhancement_no = lc_edd_0136
      TABLES
        tt_enh_status     = li_edd_0136_status. "Enhancement status table

**//Non active entries are removed.
    DELETE li_edd_0136_status WHERE active   EQ abap_false.
*&-->Begin of delete for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
*    DELETE li_edd_0136_status WHERE sel_sign NE lc_exclude.
*&-->End of delete for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
    SORT li_edd_0136_status BY criteria sel_low.


*&-->Begin of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
*&--Exclusion list is maintained for changes at sales order level by the users.
    IF li_edd_0136_status IS NOT INITIAL.
      LOOP AT li_edd_0136_status INTO lwa_status.

        CASE lwa_status-criteria.
          WHEN lc_field.
            lwa_field-sign   = lwa_status-sel_sign.
            lwa_field-option = lwa_status-sel_option.
            lwa_field-low    = lwa_status-sel_low.
            lwa_field-high   = lwa_status-sel_high.
            APPEND lwa_field TO li_emi_field.
            CLEAR lwa_field.
        ENDCASE.
        CLEAR lwa_status.
      ENDLOOP. " LOOP AT li_edd_0136_status INTO lwa_status
    ENDIF. " IF li_edd_0136_status IS NOT INITIAL
*&<--End of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017

    ASSIGN (lc_vbak) TO <lfs_vbak>.
    ASSIGN (lc_vbap) TO <lfs_vbap>.

  ENDIF. " IF sy-subrc NE 0
* <--- End of Changes for D2_OTC_EDD_0136_Defect#1060 by LMAHEND on 06th May 2016

* Check the screen Number
  CASE sy-dynnr.

    WHEN  lc_screen_no.

* Commented below condition and moved it inside LOOP for field 'ZZCONFIRM'
** If its a Display Transaction     "Commented by SNIGAM : CR1280 : 04/17/2014
*      IF t180-trtyp EQ lc_display. "Commented by SNIGAM : CR1280 : 04/17/2014

*&-->Begin of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017

 ASSIGN (lc_vbak) TO <lfs_vbak>.
    ASSIGN (lc_vbap) TO <lfs_vbap>.

    if <lfs_vbap> is  assigned.
*&--Checking whether material is batch managed or not
      CLEAR lv_xchpf.
      IF <lfs_vbap>-matnr IS NOT INITIAL.
        SELECT SINGLE xchpf " Batch management requirement indicator
        FROM mara           " General Material Data
        INTO lv_xchpf
        WHERE matnr = <lfs_vbap>-matnr.
        IF sy-subrc IS INITIAL.
*   do nothing.
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF <lfs_vbap>-matnr IS NOT INITIAL
      endif.
*&<--End of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017

*     Loop at SCREEN and modify it
      LOOP AT SCREEN.

* ---> Begin of Changes for D2_OTC_EDD_0136_Defect#1060 by LMAHEND on 06th May 2016
**//Disabling the BOM Component.
**//Enable when the Order Type is ZCPR.

        IF <lfs_vbak> IS ASSIGNED.
        READ TABLE li_edd_0136_status ASSIGNING <lfs_status> WITH KEY criteria = lc_auart
                                                                      sel_low  = <lfs_vbak>-auart
                                                                      BINARY SEARCH.
        IF sy-subrc <> 0.
          IF <lfs_vbap> IS ASSIGNED.
            IF <lfs_vbap>-uepos IS NOT INITIAL.
*&-->Begin of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
*&--If the criteria does not exist in the exclusion list table,then it should disable the BOM components otherwise it should enable.

*No fields of BOM components should be editable except Batch and schedule line delivery block
              IF li_emi_field IS NOT INITIAL.
                IF screen-name IN li_emi_field.
*Batch field should be editable only if material is batch managed.
                  IF screen-name = lc_vbap_charg.
                    IF lv_xchpf = abap_true.
                      screen-input = 1.
                    ELSE. " ELSE -> IF lv_xchpf = abap_true
                      screen-input = 0.
                    ENDIF. " IF lv_xchpf = abap_true
                  ELSE. " ELSE -> IF screen-name = lc_vbap_charg
                    screen-input = 1.
                  ENDIF. " IF screen-name = lc_vbap_charg
                ELSE. " ELSE -> IF screen-name IN li_emi_field
*&<--End of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017

*         Make Field Input Disable (Display Only)
                  screen-input = 0.
*         Midify the SCREEN
                  MODIFY SCREEN.
*&-->Begin of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
                ENDIF. " IF screen-name IN li_emi_field
                ELSE.
                  screen-input = 0.
              ENDIF. " IF li_emi_field IS NOT INITIAL
*&<--End of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
            ENDIF. " IF <lfs_vbap>-uepos IS NOT INITIAL
          ENDIF. " IF <lfs_vbap> IS ASSIGNED
        ENDIF. " IF sy-subrc <> 0
        ENDIF. " IF <lfs_vbak> IS ASSIGNED
* <--- End of Changes for D2_OTC_EDD_0136_Defect#1060 by LMAHEND on 06th May 2016


        IF screen-name = lc_zfield AND t180-trtyp EQ lc_display. "Added by SNIGAM : CR1280 : 04/17/2014
*         Make Field Input Disable (Display Only)
          screen-input = '0'.
*         Midify the SCREEN
          MODIFY SCREEN.
        ENDIF. " IF screen-name = lc_zfield AND t180-trtyp EQ lc_display

*&&---BEGIN OF CR#128
*        ELSEIF screen-name = lc_zfield1.  "Commented by SNIGAM : CR1280 : 04/17/2014
        IF screen-name = lc_zfield1. "Added by SNIGAM : CR1280 : 04/17/2014

* BOC : CR1280 : SNIGAM : 04/17/2014
* Add User Authorization for 'Customer group' field. If user has authorization of below
* 'Authorization object' & transaction is for 'Create/Change Sales Order',
* then make 'Customer Group' field as 'Editable'

*         Check if the t-code is for Change or Create Sales Order
          IF ( ( t180-trtyp EQ lc_create ) OR ( t180-trtyp EQ lc_change ) ).
*           Check if the user has authorization to make changes in 'Customer Group'
            AUTHORITY-CHECK OBJECT 'ZZCUSTGRP' ID 'ZZCUSTGRP' FIELD '02'.
*           If user does not have the authorizations, make it as 'display' only
            IF sy-subrc NE 0.
*             Make Field Input Disable (Display Only)
              screen-input = '0'.
*             Midify the SCREEN
              MODIFY SCREEN.
            ENDIF. " IF sy-subrc NE 0
          ELSE. " ELSE -> IF ( ( t180-trtyp EQ lc_create ) OR ( t180-trtyp EQ lc_change ) )
* EOC : CR1280 : SNIGAM : 04/17/2014
*           Make Field Input Disable (Display Only)
            screen-input = '0'.
*           Midify the SCREEN
            MODIFY SCREEN.
          ENDIF. " IF ( ( t180-trtyp EQ lc_create ) OR ( t180-trtyp EQ lc_change ) )
*&&---END OF CR#128
        ENDIF. " IF screen-name = lc_zfield1
      ENDLOOP. " LOOP AT SCREEN
*      ENDIF.    "Commented by SNIGAM : CR1280 : 04/17/2014
  ENDCASE.
ENDMODULE. " MODIFY_SCREEN_8459  OUTPUT

*{   INSERT         E1DK919119                                        1
* <--- Begin  of Insert for D3_OTC_EDD_0136_CR_D3_0246 by APAUL
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_8459_246  OUTPUT
*&---------------------------------------------------------------------*
*       Screen field enable /  disable based on order type
*----------------------------------------------------------------------*
MODULE modify_screen_8459_246 OUTPUT.

* Local Constants Decleration
  CONSTANTS:
              lc_zfield2      TYPE char14        VALUE 'VBAP-KOSTL',   " Zfield2 of type CHAR14
              lc_zfield3      TYPE char14        VALUE 'VBAP-ZKOSTL' , " Zfield3 of type CHAR14
              lc_auart_zicm   TYPE z_criteria    VALUE 'AUART_CREDIT', " Enh. Criteria
              lc_auart_zidm   TYPE z_criteria    VALUE 'AUART_DEBIT',  " Enh. Criteria
              lc_null         TYPE z_criteria    VALUE 'NULL'.         " Enh. Criteria

  CLEAR li_edd_0136_status .


**//Call Function Module To Get the EMI Entries.
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_edd_0136
    TABLES
      tt_enh_status     = li_edd_0136_status. "Enhancement status table



*  Did  not use  Binary Search as internal table is very
* Check Null active or not
  READ TABLE  li_edd_0136_status
               WITH KEY criteria =  lc_null
                        active   =  abap_true
                        TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.

    ASSIGN (lc_vbak) TO <lfs_vbak>.
    ASSIGN (lc_vbap) TO <lfs_vbap>.


* Check the screen Number
    CASE sy-dynnr.

      WHEN  lc_screen_no.

        LOOP AT SCREEN.

* If screen element  is Sender Cost center or  Reciever Cost center
          IF ( screen-name EQ lc_zfield2 ) OR
             ( screen-name EQ lc_zfield3 ) .

*         Check if the t-code is for Change or Create Sales Order
            IF ( ( t180-trtyp NE lc_create ) AND ( t180-trtyp NE lc_change ) ).
* Disbale field
              screen-input = '0'.
              MODIFY SCREEN .

            ELSE. " ELSE -> IF ( ( t180-trtyp NE lc_create ) AND ( t180-trtyp NE lc_change ) )

              IF <lfs_vbak> IS ASSIGNED.
*  Did  not use  Binary Search as internal table is very
* Check order type ZICM enable in EMI
                READ TABLE li_edd_0136_status
                          ASSIGNING <lfs_status>
                          WITH KEY criteria = lc_auart_zicm
                           sel_low  = <lfs_vbak>-auart
                           active   =  abap_true .

                IF sy-subrc NE  0.
*  Did  not use  Binary Search as internal table is very
* Check order type ZIDM enable in EMI
                  READ TABLE li_edd_0136_status
                             ASSIGNING <lfs_status>
                             WITH KEY criteria = lc_auart_zidm
                                      sel_low  = <lfs_vbak>-auart
                                      active   =  abap_true.

                  IF sy-subrc NE  0 .
* Disbale field
                    screen-input = '0'.
                    MODIFY SCREEN .
                  ENDIF. " IF sy-subrc NE 0
                ENDIF. " IF sy-subrc NE 0
              ENDIF. " IF <lfs_vbak> IS ASSIGNED
            ENDIF. " IF ( ( t180-trtyp NE lc_create ) AND ( t180-trtyp NE lc_change ) )
          ENDIF . " IF ( screen-name EQ lc_zfield2 ) OR
        ENDLOOP. " LOOP AT SCREEN
    ENDCASE.
  ENDIF . " IF sy-subrc EQ 0

ENDMODULE. " MODIFY_SCREEN_8459_246  OUTPUT

* <--- End  of Insert for D3_OTC_EDD_0136_CR_D3_0246 by APAUL


*}   INSERT

*{   INSERT         E1DK919119                                        2
* <--- Begin  of Insert for D3_OTC_EDD_0136_CR_D3_0246 by APAUL

*&---------------------------------------------------------------------*
*&      Module  POPULATE_KOSTL  INPUT
*&---------------------------------------------------------------------*
*       Populate F4 help  for Sender Cost center
*----------------------------------------------------------------------*

MODULE populate_kostl INPUT.


* Cost Center
  TYPES: BEGIN OF lty_csks,
             kostl TYPE kostl, " Cost Center
             ltext TYPE kltxt, "  Description
        END OF  lty_csks.

  CONSTANTS: lc_field_kostl   TYPE fieldname VALUE 'KOSTL' ,     " Field Name
             lc_field_ltext   TYPE fieldname VALUE 'LTEXT' ,     " Field Name
             lc_dyn_fieldname TYPE dynfnam   VALUE 'VBAP-KOSTL', " Field name
             lc_value_org     TYPE ddbool_d  VALUE 'S',          " DD: truth value
             lc_pos_1          TYPE tabfdpos  VALUE '1',         "  Position of the field in the table
             lc_pos_2          TYPE tabfdpos  VALUE '2'.         "  Position of the field in the table

* Data object
  DATA: lv_bukrs      TYPE bukrs,                " Company Code
        li_csks       TYPE TABLE OF    lty_csks ,
        li_return     TYPE TABLE OF ddshretval , " Interface Structure Search Help <-> Help System
        li_field_tab TYPE TABLE OF dfies ,       " DD Interface: Table Fields for DDIF_FIELDINFO_GET
        lwa_field_tab  TYPE dfies.               " DD Interface: Table Fields for DDIF_FIELDINFO_GET

  FIELD-SYMBOLS : <lfs_csks> TYPE lty_csks .

  ASSIGN (lc_vbak) TO <lfs_vbak>.
  IF <lfs_vbak> IS  ASSIGNED.
    CLEAR lv_bukrs.
*  Select  Company code for  Sales organisation
    SELECT SINGLE bukrs  FROM tvko " Organizational Unit: Sales Organizations
                         INTO lv_bukrs
                        WHERE vkorg = <lfs_vbak>-vkorg .
    IF sy-subrc  EQ 0.
      CLEAR li_csks .
* Select Cost center  for company code
      SELECT  csks~kostl cskt~ltext
          INTO TABLE li_csks
          FROM csks INNER JOIN cskt
          ON csks~kokrs = cskt~kokrs
        AND  csks~kostl = cskt~kostl
        AND  csks~datbi = cskt~datbi
       WHERE csks~bukrs =  lv_bukrs
        AND  cskt~spras = sy-langu.

      IF sy-subrc EQ 0.
        SORT  li_csks BY kostl .
        DELETE ADJACENT DUPLICATES FROM li_csks  COMPARING  kostl.

      ENDIF. " IF sy-subrc EQ 0
    ENDIF . " IF sy-subrc EQ 0
  ENDIF. " IF <lfs_vbak> IS ASSIGNED


  CLEAR:   lwa_field_tab,
           li_field_tab .

*  Display description
  lwa_field_tab-fieldname = lc_field_kostl .
  lwa_field_tab-intlen = 20.
  lwa_field_tab-outputlen = 10.
  lwa_field_tab-scrtext_m = 'Sender Cost center'(019).
  lwa_field_tab-position = lc_pos_1.
  APPEND lwa_field_tab TO li_field_tab .

  CLEAR: lwa_field_tab .

  lwa_field_tab-fieldname = lc_field_ltext .
  lwa_field_tab-intlen = 80.
  lwa_field_tab-outputlen = 40.
  lwa_field_tab-offset    = 20.
  lwa_field_tab-scrtext_m = 'Description'(026).
  lwa_field_tab-position = lc_pos_2.
  APPEND lwa_field_tab TO li_field_tab .

* Populate  F4 help
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = lc_field_kostl
      dynpprog    = sy-cprog
      dynpnr      = sy-dynnr
      dynprofield = lc_dyn_fieldname
      value_org   = lc_value_org
    TABLES
      value_tab   = li_csks
      field_tab   = li_field_tab.

ENDMODULE. " POPULATE_KOSTL  INPUT
* <---  End  of Insert for D3_OTC_EDD_0136_CR_D3_0246 by APAUL
*}   INSERT

*{   INSERT         E1DK919119                                        3


* <--- Begin  of Insert for D3_OTC_EDD_0136_CR_D3_0246 by APAUL
*&---------------------------------------------------------------------*
*&      Module  POPULATE_ZKOSTL  INPUT
*&---------------------------------------------------------------------*
*       Populate F4 help  for Receiver Cost center
*----------------------------------------------------------------------*

MODULE populate_zkostl INPUT .

* Assignemnt type
  TYPES: BEGIN OF lty_tvko,
             bukrs TYPE bukrs, " Company Code
         END OF  lty_tvko  .

  CONSTANTS: lc_field_zkostl   TYPE fieldname VALUE 'ZKOSTL' ,     " Field Name
             lc_dyn_fieldname1 TYPE dynfnam   VALUE 'VBAP-ZKOSTL'. " Field name


  DATA: li_tvko TYPE TABLE OF  lty_tvko .


  ASSIGN (lc_vbak) TO <lfs_vbak>.
  CLEAR : li_tvko .

* Get company code based  on Sold to party
  SELECT  bukrs FROM tvko INTO     TABLE li_tvko
        WHERE  kunnr  = <lfs_vbak>-kunnr  .

  IF sy-subrc  EQ 0.

    CLEAR li_csks.
* Get  Cost center based on comapny code
    SELECT  csks~kostl cskt~ltext
       FROM csks INNER JOIN cskt
          ON csks~kokrs = cskt~kokrs
        AND  csks~kostl = cskt~kostl
        AND  csks~datbi = cskt~datbi
        INTO TABLE li_csks
        FOR ALL ENTRIES IN li_tvko
        WHERE csks~bukrs =  li_tvko-bukrs .


    IF sy-subrc EQ 0.
      SORT  li_csks BY kostl .
      DELETE ADJACENT DUPLICATES FROM li_csks  COMPARING  kostl.

    ENDIF. " IF sy-subrc EQ 0
  ENDIF . " IF sy-subrc EQ 0


  CLEAR:   lwa_field_tab,
           li_field_tab .

  lwa_field_tab-fieldname = lc_field_zkostl .
  lwa_field_tab-intlen = 20.
  lwa_field_tab-outputlen = 10.
  lwa_field_tab-scrtext_m = 'Receiver Cost center'(023).
  lwa_field_tab-position = lc_pos_1.

  APPEND lwa_field_tab TO li_field_tab .


  CLEAR: lwa_field_tab .

  lwa_field_tab-fieldname = lc_field_ltext .
  lwa_field_tab-intlen = 80.
  lwa_field_tab-outputlen = 40.
  lwa_field_tab-offset    = 20.
  lwa_field_tab-scrtext_m = 'Description'(026).
  lwa_field_tab-position = lc_pos_2.
  APPEND lwa_field_tab TO li_field_tab .

* Populate F4 help for Receiver cost center
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = lc_field_zkostl
      dynpprog    = sy-cprog
      dynpnr      = sy-dynnr
      dynprofield = lc_dyn_fieldname1
      value_org   = lc_value_org
    TABLES
      value_tab   = li_csks
      field_tab   = li_field_tab.

ENDMODULE  . "POPULATE_ZKOSTL INPUT
* <--- End  of Insert for D3_OTC_EDD_0136_CR_D3_0246 by APAUL

* <--- Begin  of Insert for D3_OTC_EDD_0136_CR_D3_0246 by APAUL

*&---------------------------------------------------------------------*
*&      Module  VALIDATE_KOSTL  INPUT
*&---------------------------------------------------------------------*
*       Validate  Cost center
*----------------------------------------------------------------------*
MODULE validate_kostl INPUT.

* Cost center  type
  TYPES: BEGIN OF lty_csks_bukrs,
             kostl TYPE kostl, " Cost Center
             bukrs TYPE bukrs, " Company Code
         END OF  lty_csks_bukrs .

  DATA :
          li_csks_bukrs TYPE TABLE OF lty_csks_bukrs.

  FIELD-SYMBOLS : <lfs_csks_bukrs> TYPE lty_csks_bukrs.

* Validate if  Sender Cost center is populated
  IF vbap-kostl IS NOT INITIAL.
    ASSIGN (lc_vbak) TO <lfs_vbak>.

    IF <lfs_vbak> IS ASSIGNED .
      CLEAR lv_bukrs .
* Get   company code from   sales organisation
      SELECT SINGLE bukrs FROM tvko " Organizational Unit: Sales Organizations
              INTO lv_bukrs
             WHERE vkorg = <lfs_vbak>-vkorg .
      IF sy-subrc  EQ 0.
        CLEAR li_csks_bukrs.
* Get cost center from  company code
        SELECT  kostl bukrs FROM csks " Cost Center Master Data
              INTO TABLE   li_csks_bukrs
               WHERE kostl =  vbap-kostl.
        IF sy-subrc EQ 0 .
          SORT li_csks_bukrs BY kostl bukrs.
* Check Cost center assigned to company code of sales organisation
          READ TABLE li_csks_bukrs WITH KEY
                     kostl = vbap-kostl
                     bukrs = lv_bukrs
                     BINARY SEARCH
                     TRANSPORTING NO FIELDS .

          IF sy-subrc NE 0.
* If Cost center not assigned to company of sales organisation,   then get the assigned company code
            READ TABLE li_csks_bukrs ASSIGNING <lfs_csks_bukrs>  INDEX 1.

            IF sy-subrc EQ 0.
              MESSAGE  e276(zotc_msg)                   " Sender Cost Centre belongs to company code &, not &
                 WITH <lfs_csks_bukrs>-bukrs lv_bukrs . " Sender Cost Centre belongs to company code &, not &
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF sy-subrc NE 0
        ELSE. " ELSE -> IF sy-subrc EQ 0

          MESSAGE  e277(zotc_msg)  . " Sender Cost Centre not found
        ENDIF. " IF sy-subrc EQ 0
      ENDIF   . " IF sy-subrc EQ 0
    ENDIF   . " IF <lfs_vbak> IS ASSIGNED
  ENDIF  . " IF vbap-kostl IS NOT INITIAL
ENDMODULE. " VALIDATE_KOSTL  INPUT
* <--- End   of Insert for D3_OTC_EDD_0136_CR_D3_0246 by APAUL

* <--- Begin  of Insert for D3_OTC_EDD_0136_CR_D3_0246 by APAUL


*&---------------------------------------------------------------------*
*&      Module   VALIDATE_ZKOSTL  INPUT
*&---------------------------------------------------------------------*
*       Validate Reciever Cost center
*----------------------------------------------------------------------*

MODULE validate_zkostl INPUT.

* Data  object
  DATA: lv_incorrect TYPE  i   . " Incorrect of type Integers


  FIELD-SYMBOLS :  <lfs_tvko>  TYPE    lty_tvko.

* Validate Receiver cost  center if  populated
  IF vbap-zkostl IS NOT INITIAL.
    ASSIGN (lc_vbak) TO <lfs_vbak>.

    IF <lfs_vbak> IS ASSIGNED .
      CLEAR li_tvko .

*  Get company code based on Customers
      SELECT  bukrs FROM tvko " Organizational Unit: Sales Organizations
             INTO  TABLE  li_tvko
        WHERE  kunnr   = <lfs_vbak>-kunnr .

      IF sy-subrc  EQ 0.

        SORT li_tvko   BY        bukrs  .
        CLEAR  li_csks_bukrs   .
*   Get  cost center from comapany code
        SELECT  kostl " Cost Center
                bukrs " Company Code
          FROM csks   " Cost Center Master Data
          INTO TABLE   li_csks_bukrs
         WHERE kostl =  vbap-zkostl.

        IF sy-subrc EQ 0  .
          SORT li_csks_bukrs BY kostl bukrs.
          CLEAR  lv_incorrect        .


* Check cost center is from company code of customers
          LOOP AT   li_csks_bukrs  ASSIGNING   <lfs_csks_bukrs> .
            IF  <lfs_csks_bukrs>-kostl   =  vbap-zkostl.

* Check comapny presents in assignment table
              READ TABLE li_tvko WITH KEY   bukrs = <lfs_csks_bukrs>-bukrs
                      BINARY SEARCH  TRANSPORTING NO FIELDS .
              IF   sy-subrc  EQ 0.
                lv_incorrect  =  1.
                EXIT.
              ENDIF . " IF sy-subrc EQ 0
            ENDIF. " IF <lfs_csks_bukrs>-kostl = vbap-zkostl
          ENDLOOP . " LOOP AT li_csks_bukrs ASSIGNING <lfs_csks_bukrs>

* If not presents, populate error  message
          IF lv_incorrect IS  INITIAL.
            READ TABLE li_csks_bukrs ASSIGNING <lfs_csks_bukrs>  WITH KEY kostl = vbap-zkostl BINARY SEARCH .
            IF sy-subrc EQ 0.
              READ TABLE li_tvko ASSIGNING <lfs_tvko> INDEX 1.
              IF sy-subrc EQ   0.
                MESSAGE  e278(zotc_msg) WITH <lfs_csks_bukrs>-bukrs  <lfs_tvko>-bukrs  . " Receiver Cost Centre belongs to company code &, not &
              ENDIF. " IF sy-subrc EQ 0
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF lv_incorrect IS INITIAL

        ELSE. " ELSE -> IF sy-subrc EQ 0

* If cost center not presents
          MESSAGE  e279(zotc_msg)  . " Receiver Cost Centre not found
        ENDIF. " IF sy-subrc EQ 0
      ENDIF   . " IF sy-subrc EQ 0
    ENDIF   . " IF <lfs_vbak> IS ASSIGNED
  ENDIF  . " IF vbap-zkostl IS NOT INITIAL
ENDMODULE . "validate_Zkostl INPUT
* <--- End  of Insert for D3_OTC_EDD_0136_CR_D3_0246 by APAUL
*}   INSERT
