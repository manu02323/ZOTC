************************************************************************
* PROGRAM    :  ZOTCNO0424B_QTY_FIX_THIRD_PTY1  (Include Program)       *
* TITLE      :  Qty and Date Fixed Third Party PO                      *
* DEVELOPER  :  Srinivasa Gurijala                                     *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0424  SCTASK0783635                              *
*----------------------------------------------------------------------*
* DESCRIPTION: Populate FIXMG based on Item categery                   *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER    TRANSPORT    DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 10/Feb/2019 U033814  E2DK923499 Date and Qty Fixed for Third Party PO*
*======================================================================*
*&---------------------------------------------------------------------*
*&  Include           ZOTCNO0424B_QTY_FIX_THIRD_PTY
*&---------------------------------------------------------------------*

   DATA:lwa_xvbap           TYPE vbapvb,                           " Document Structure for XVBAP/YVBAP
        li_status_tt       TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
        lwa_statust        TYPE zdev_enh_status.                   " Enhancement Status

   CONSTANTS :
        lc_criteria1         TYPE z_criteria           VALUE 'PSTYV',       " Enh. Criteria
        lc_null_0424        TYPE z_criteria           VALUE 'NULL',         " Enh. Criteria
        lc_edd_0424         TYPE z_enhancement        VALUE 'OTC_EDD_0424'. " Enhancement No.

*--Call to EMI Function Module To Get List Of EMI Statuses for Transportation Group Mapping
   CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
     EXPORTING
       iv_enhancement_no = lc_edd_0424
     TABLES
       tt_enh_status     = li_status_tt.

   DELETE li_status_tt WHERE active NE abap_true.
* Check if the EMI Status is Active
   READ TABLE li_status_tt  INTO lwa_statust  WITH KEY criteria = lc_null_0424
                                                     active   = abap_true.
   IF sy-subrc EQ 0.

     READ TABLE li_status_tt  INTO lwa_statust  WITH KEY criteria = lc_criteria1
                                                     sel_low  = vbap-pstyv
                                                     active   = abap_true.
     IF sy-subrc EQ 0.
        vbap-fixmg = abap_true.
     ENDIF. " IF sy-subrc EQ 0
   ENDIF. " IF sy-subrc EQ 0
