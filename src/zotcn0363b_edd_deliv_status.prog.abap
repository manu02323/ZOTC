*&---------------------------------------------------------------------*
*&  Include           ZOTCN0363B_EDD_DELIV_STATUS
*&---------------------------------------------------------------------*
************************************************************************
* PROG       :  ZOTCN0363B_EDD_DELIV_STATUS (Include Program)          *
* TITLE      :  Delivery Status Verification                           *
* DEVELOPER  :  Raghavendra Sureddi                                    *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D3_OTC_EDD_0363                                            *
*----------------------------------------------------------------------*
* DESCRIPTION: Verify Deliv status and item qty before prof inv create *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER    TRANSPORT    DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 14/Sep/2016 U033876  E1DK921779  FB2_D3_OTC_EDD_0363_Delivery Stat   *
* 01/Jul/2019 U033632  E2DK924878  Defect#9943/INC0487265-02-To avoid  *
*                                  failure of batch job                *
*                                  'E1P_OTC_PROFORMA_INV_SUB_CONT_PO'  *
*                                   error message ZOTC_MSG 219 is      *
*                                  replaced with information message   *
*                                   ZOTC_MSG 000 with text             *
*======================================================================*


  DATA: li_constants_363 TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
        wa_constants_363 TYPE zdev_enh_status,                   " Enhancement Status
*Begin of insert for D3_OTC_EDD_0363_Defect#9943/INC0487265-02 by U033632 on 01-Jul-2019
        lv_text          TYPE string.                           "text to be displayed in message
*End of insert for D3_OTC_EDD_0363_Defect#9943/INC0487265-02 by U033632 on 01-Jul-2019
  CONSTANTS: lc_enh_name_0363 TYPE z_enhancement VALUE 'OTC_EDD_0363', " Enhancement No.
             lc_nul           TYPE z_criteria    VALUE 'NULL',         " Constant table.
             lc_fkart         TYPE z_criteria    VALUE 'FKART',        " Enh. Criteria
             lc_pkstk         TYPE z_criteria    VALUE 'PKSTK',        " Enh. Criteria
*Begin of insert for D3_OTC_EDD_0363_Defect#9943/INC0487265-02 by U033632 on 01-Jul-2019
             lc_text1         TYPE  char50       VALUE 'Packing not complete for Delivery', "Message text
             lc_text2         TYPE  char50       VALUE '.Proforma Invoice not allowed.'.    "Message text
*End of insert for D3_OTC_EDD_0363_Defect#9943/INC0487265-02 by U033632 on 01-Jul-2019


* Get enhancement name and deliv status from Constant table
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_name_0363
    TABLES
      tt_enh_status     = li_constants_363.

  READ TABLE  li_constants_363 INTO wa_constants_363
              WITH KEY criteria =  lc_nul
                       active = abap_true.
  IF sy-subrc = 0.
    CLEAR: wa_constants_363.
* Only check for billing types which exists in EMI
    READ TABLE li_constants_363 INTO wa_constants_363
              WITH KEY criteria =  lc_fkart
                       sel_low  =  vbrk-fkart
                       active   =  abap_true.
    IF sy-subrc = 0.
      CLEAR: wa_constants_363.
* Only check for overstatus exists in EMI and is completed
      READ TABLE li_constants_363 INTO wa_constants_363
                WITH KEY criteria =  lc_pkstk
                         sel_low  =  vbuk-pkstk
                         active   =  abap_true.
      IF sy-subrc NE 0.
*Begin of delete for D3_OTC_EDD_0363_Defect#9943/INC0487265-02 by U033632 on 01-Jul-2019
*        MESSAGE e219(zotc_msg).
*End of delete for D3_OTC_EDD_0363_Defect#9943/INC0487265-02 by U033632 on 01-Jul-2019
*Begin of insert for D3_OTC_EDD_0363_Defect#9943/INC0487265-02 by U033632 on 01-Jul-2019
*To avoid failure of batch job 'E1P_OTC_PROFORMA_INV_SUB_CONT_PO' error message ZOTC_MSG 219 is  replaced with information message
*ZOTC_MSG 000 with text. This message gets populated in batch job log.
        CONCATENATE lc_text1 xvbuk-vbeln INTO lv_text SEPARATED BY space.
        MESSAGE i000(zotc_msg) WITH lv_text lc_text2. "Packing not complete for delivery.Proforma Invoice not allowed
*Clearing the VBRP, VBRK and LIKP data so that Proforma invoice will not get created when packing is incomplete
        CLEAR:vbrp,
        vbrk,
        likp.
*End of insert for D3_OTC_EDD_0363_Defect#9943/INC0487265-02 by U033632 on 01-Jul-2019
      ENDIF. " IF sy-subrc NE 0

    ENDIF. " IF sy-subrc = 0

  ENDIF. " IF sy-subrc = 0
