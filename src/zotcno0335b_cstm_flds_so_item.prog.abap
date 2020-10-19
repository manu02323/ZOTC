************************************************************************
* PROGRAM    :  ZOTCNO0335_CSTM_FLDS_SO_ITEM  (Include Program)        *
* TITLE      :  Populate Tax Reporting and Tax Destination Country in  *
*               VBAP Table                                             *
* DEVELOPER  :  Srinivasa Gurijala                                     *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_00335                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Population of VBAP ZZRLAND ZZDLAND ZZRLANDIC ZZDLANDIC  *
*              for Tax reporting and Tax Destination                   *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER    TRANSPORT    DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 10/Jul/2016 U033814  E1DK919518  FB2_D3_OTC_EDD_0335_EHQ_EU_VAT_Ta   *
*======================================================================*
*&---------------------------------------------------------------------*
*&  Include           ZOTCNO0335_CSTM_FLDS_SO_ITEM                     *
*&---------------------------------------------------------------------*

   DATA:lt_vbpa           TYPE STANDARD TABLE OF vbpa INITIAL SIZE 0, " Sales Document: Partner
        li_status_t       TYPE STANDARD TABLE OF zdev_enh_status,     " Enhancement Status
        lwa_status        TYPE zdev_enh_status.                       " Enhancement Status

   CONSTANTS :
        lc_criteria         TYPE z_criteria           VALUE 'VKORG',        " Enh. Criteria
        lc_null_0335        TYPE z_criteria           VALUE 'NULL',
        lc_edd_0335         TYPE z_enhancement        VALUE 'OTC_EDD_0335'. " Enhancement No.

*--Call to EMI Function Module To Get List Of EMI Statuses for Transportation Group Mapping
   CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
     EXPORTING
       iv_enhancement_no = lc_edd_0335
     TABLES
       tt_enh_status     = li_status_t.

   DELETE li_status_t WHERE active NE abap_true.
* Check if the EMI Status is Active
   READ TABLE li_status_t  INTO lwa_status  WITH KEY criteria = lc_null_0335
                                                     active   = abap_true.
   IF sy-subrc EQ 0.
     active   = abap_true.
     READ TABLE li_status_t  INTO lwa_status  WITH KEY criteria = lc_criteria
                                                     sel_low  = vbak-vkorg
                                                     active   = abap_true.
     IF sy-subrc EQ 0.
       lt_vbpa[] = xvbpa[].

* Call the FM ZOTC_0335_VAT_PROCESSFLOW to populate the Detination and Reporting Countries.
       CALL FUNCTION 'ZOTC_0335_VAT_PROCESSFLOW'
         EXPORTING
           im_vbak   = vbak
           im_vbap   = vbap
           it_vbpa   = lt_vbpa
           im_vbkd   = vbkd
         CHANGING
           chng_vbap = vbap.
     ENDIF. " IF sy-subrc EQ 0
   ENDIF. " if sy-subrc eq 0
