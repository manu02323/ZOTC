************************************************************************
* PROGRAM    :  ZOTCN0336O_INTERCOM_BILL_DATA                          *
* TITLE      :  EHQ_Delivery Output Routine                            *
* DEVELOPER  :  Salman Zahir                                           *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0336                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Fill intercompany billing data in the communication    *
*                structure when they are populated                     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 12-JUN-2016 U033959  E1DK918578 INITIAL DEVELOPMENT                  *
* =========== ======== ========== =====================================*

*&---------------------------------------------------------------------*
*&  Include           ZOTCN0336O_INTERCOM_BILL_DATA
*&---------------------------------------------------------------------*

*--CONSTANTS---------------------------------------------------------*
CONSTANTS : lc_otc_edd_0336 TYPE z_enhancement VALUE 'OTC_EDD_0336', " Enhancement No.
            lc_enh_id       TYPE z_criteria    VALUE 'NULL'.         " Enh. Criteria

*--TABLES------------------------------------------------------------*
DATA : li_status         TYPE STANDARD TABLE OF zdev_enh_status. " Enhancement Status table


* Checking whether enhancement is active or not from EMI Tool.
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_otc_edd_0336
  TABLES
    tt_enh_status     = li_status.

SORT li_status BY criteria active.

* Check if enhancement is active on EMI
READ TABLE li_status WITH KEY criteria = lc_enh_id
                                active = abap_true
                     BINARY SEARCH
                     TRANSPORTING NO FIELDS.
IF sy-subrc IS INITIAL.
* For intercompany billing below 3 fields should be populated, so before
* popuating the ZZ fields check they are not blank.
  IF com_likp-vkoiv IS NOT INITIAL AND
     com_likp-vtwiv IS NOT INITIAL AND
     com_likp-spaiv IS NOT INITIAL.

    com_kbv2-zzvkoiv = com_likp-vkoiv.
    com_kbv2-zzvtwiv = com_likp-vtwiv.
    com_kbv2-zzspaiv = com_likp-spaiv.

  ENDIF. " IF com_likp-vkoiv IS NOT INITIAL AND
ENDIF. " IF sy-subrc IS INITIAL
