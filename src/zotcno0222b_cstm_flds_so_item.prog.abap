*--Begin of Insert for D3_OTC_IDD_0222 by U029267- SCTASK0768763
* EHNO       :  ZIM_OTC_VAT_CUSTOM_FIELDS  (Enh. Implementation)       *
* TITLE      :  Populate Created by in BOM child item in VBAP Table    *
* DEVELOPER  :  Suparna Paul                                           *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_0222                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Population of VBAP-ERNAM with VBAK-ERNAM                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER    TRANSPORT    DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 21-Jan-2019 U029267  E1DK939532  SCTASK0768763 Add created by logic  *
*======================================================================*
*&---------------------------------------------------------------------*
*&  Include           ZOTCNO0222B_CSTM_FLDS_SO_ITEM
*&---------------------------------------------------------------------*

   DATA:
        li_status_t1      TYPE STANDARD TABLE OF zdev_enh_status,     " Enhancement Status
        lwa_status1       TYPE zdev_enh_status,                       " Enhancement Status
        lv_doc_typ_eskar  TYPE auart.                                 " Sales Document Type

   CONSTANTS :
        lc_null_0222        TYPE z_criteria           VALUE 'NULL',         " Enh. Criteria
        lc_edd_0222         TYPE z_enhancement        VALUE 'OTC_IDD_0222', " Enhancement No.
        lc_crit_doc_typ     TYPE z_criteria           VALUE 'AUART'.        " Enh. Criteria

   FIELD-SYMBOLS: <lfs_vbap1> TYPE vbap. " Sales Document: Item Data

*--Call to EMI Function Module To Get List Of EMI Statuses for Transportation Group Mapping
   CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
     EXPORTING
       iv_enhancement_no = lc_edd_0222
     TABLES
       tt_enh_status     = li_status_t1.

   DELETE li_status_t1 WHERE active NE abap_true.
* Check if the EMI Status is Active
   READ TABLE li_status_t1  INTO lwa_status  WITH KEY criteria = lc_null_0222
                                                      active   = abap_true.
   IF sy-subrc EQ 0.

     READ TABLE li_status_t1  INTO lwa_status1  WITH KEY criteria = lc_crit_doc_typ
                                                         active   = abap_true.
     IF sy-subrc EQ 0.
       lv_doc_typ_eskar = lwa_status1-sel_low. "Value 08
     ENDIF. " IF sy-subrc EQ 0

     IF vbak-zzdoctyp = lv_doc_typ_eskar AND vbak-ernam IS NOT INITIAL.
       vbap-ernam = vbak-ernam.
     ENDIF. " IF vbak-zzdoctyp = lv_doc_typ_eskar AND vbak-ernam IS NOT INITIAL
   ENDIF. " IF sy-subrc EQ 0
