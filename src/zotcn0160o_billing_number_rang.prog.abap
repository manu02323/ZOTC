*&---------------------------------------------------------------------*
*&  Include           ZOTCN0160O_BILLING_NUMBER_RANG
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0160O_BILLING_NUMBER_RANG                         *
* TITLE      :  EHQ_Invoice Number Range Determination                 *
* DEVELOPER  :  Salman Zahir                                           *
* OBJECT TYPE:  Enhancement Program                                    *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0160                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Determination of invoice number range based on entries *
*                maintained in table zotc_bill_num_r                   *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 30-MAY-2016 U033959  E1DK918369 INITIAL DEVELOPMENT                  *
* =========== ======== ========== =====================================*


*--CONSTANTS---------------------------------------------------------*
CONSTANTS : lc_otc_edd_0160 TYPE z_enhancement VALUE 'OTC_EDD_0160', " Enhancement No.
            lc_enh_id       TYPE z_criteria    VALUE 'NULL',         " Enh. Criteria
            lc_tcode        TYPE z_criteria    VALUE 'TCODE'.        " Enh. Criteria

*--TYPES-------------------------------------------------------------*
TYPES : BEGIN OF lty_tcodes,
          sign   TYPE tvarv_sign, " ABAP: ID: I/E (include/exclude values)
          option TYPE tvarv_opti, " ABAP: Selection option (EQ/BT/CP/...)
          low    TYPE tcode,      " Transaction Code
          high   TYPE tcode,      " Transaction Code
        END OF lty_tcodes.
*--TABLES------------------------------------------------------------*
DATA : li_status         TYPE STANDARD TABLE OF zdev_enh_status. " Enhancement Status table

*--VARIABLES---------------------------------------------------------*
DATA : lv_numki          TYPE numkr. " Number range

*--RANGES------------------------------------------------------------*
DATA : lr_tcode          TYPE RANGE OF tcode. " Transaction Code

*--FIELD SYMBOLS-----------------------------------------------------*
FIELD-SYMBOLS :
            <lfs_tcode>  TYPE lty_tcodes,      " Transaction Code
            <lfs_status> TYPE zdev_enh_status. " Enhancement Status


* Checking whether enhancement is active or not from EMI Tool.
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_otc_edd_0160
  TABLES
    tt_enh_status     = li_status.

SORT li_status BY criteria active.

* Check if enhancement is active on EMI
READ TABLE li_status WITH KEY criteria = lc_enh_id
                                active = abap_true
                      BINARY SEARCH
                      TRANSPORTING NO FIELDS.
IF sy-subrc IS INITIAL.

* Loop at EMI records to build range table for active entries
  LOOP AT li_status ASSIGNING <lfs_status>
                        WHERE criteria = lc_tcode
                          AND active   = abap_true.
    APPEND INITIAL LINE TO lr_tcode ASSIGNING <lfs_tcode>.
    <lfs_tcode>-sign   = <lfs_status>-sel_sign.
    <lfs_tcode>-option = <lfs_status>-sel_option.
    <lfs_tcode>-low    = <lfs_status>-sel_low.
    UNASSIGN <lfs_tcode>.
  ENDLOOP. " LOOP AT li_status ASSIGNING <lfs_status>

* check for allowed tcodes maitained in EMI tool
*  IF lr_tcode IS NOT INITIAL AND
*     sy-tcode IN lr_tcode.
*   Fetch the number range key
    SELECT numki         " Number range
    FROM zotc_bill_num_r " Billing Number Range Maintenance
    UP TO 1 ROWS
    INTO lv_numki
    WHERE vkorg   = xvbrk-vkorg
* Begin of CR EDD-0160
      AND zzrland = xvbrk-zzrland
* End of CR EDD-0160
*      AND vtweg   = xvbrk-vtweg
* End of CR EDD-0160
      AND fkart   = xvbrk-fkart.
    ENDSELECT.
    IF sy-subrc IS INITIAL AND lv_numki IS NOT INITIAL.
      us_range_intern = lv_numki.
* Begin of CR EDD-0160
    ELSE. " ELSE -> IF sy-subrc IS INITIAL AND lv_numki IS NOT INITIAL
*   Fetch the number range key
      SELECT numki         " Number range
      FROM zotc_bill_num_r " Billing Number Range Maintenance
      UP TO 1 ROWS
      INTO lv_numki
      WHERE vkorg   = xvbrk-vkorg
        AND zzrland EQ space
        AND fkart   = xvbrk-fkart.
      ENDSELECT.
      IF sy-subrc IS INITIAL AND lv_numki IS NOT INITIAL.
        us_range_intern = lv_numki.
      ENDIF. " IF sy-subrc IS INITIAL AND lv_numki IS NOT INITIAL
    ENDIF. " IF sy-subrc IS INITIAL AND lv_numki IS NOT INITIAL
* End of CR EDD-0160
*  ENDIF. " IF lr_tcode IS NOT INITIAL AND
ENDIF. " IF sy-subrc IS INITIAL
