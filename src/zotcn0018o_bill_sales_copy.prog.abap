*&---------------------------------------------------------------------*
*&  Include           ZOTCN0018O_BILL_SALES_COPY
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0018O_BILL_SALES_COPY                                 *
* TITLE      :  OTC_EDD_0018_BILL_SALES_COPY                        *
* DEVELOPER  :  Raghavendra Sureddi                                    *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0018                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: Based on EMi entries need to set to re-trigger the      *
*              pricing based on EMI entries                            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 13-Jun-2018 U033876  E1DK937223 INITIAL DEVELOPMENT - PCR 292 defect 6260*
*&---------------------------------------------------------------------*

CONSTANTS: lc_otc_edd_0018 TYPE z_enhancement VALUE 'D2_OTC_EDD_0018', " Enhancement No.
           lc_knprs_18     TYPE z_criteria    VALUE 'KNPRS'.           " Enh. Criteria
DATA :     lwa_status      TYPE zdev_enh_status, " Enhancement Status
           lv_vkorg_auart  TYPE char10.          " Vkorg_auart of type CHAR10
CLEAR: li_status[], lv_vkorg_auart.
*Call to EMI Function Module To Get List Of EMI entries. Then checking NULL
*criteria for active flag. If it's active then only further code is excuted.
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_otc_edd_0018
  TABLES
    tt_enh_status     = li_status. "Enhancement status table



READ TABLE li_status WITH KEY criteria = lc_null
                              active = abap_true
                     TRANSPORTING NO FIELDS.
IF sy-subrc EQ 0.

  CONCATENATE vbak-vkorg vbak-auart
            INTO lv_vkorg_auart SEPARATED BY '_'.
  READ TABLE li_status INTO lwa_status
                       WITH KEY
                              criteria = lc_knprs_18
                              sel_low  = lv_vkorg_auart
                              active = abap_true.
  IF sy-subrc = 0.
    new_pricing = lwa_status-sel_high.
  ENDIF. " IF sy-subrc = 0

ENDIF. " IF sy-subrc EQ 0
