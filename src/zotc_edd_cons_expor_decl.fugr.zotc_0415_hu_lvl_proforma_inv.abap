***********************************************************************
*Program    : ZOTC_0415_HU_LVL_PROFORMA_INV(FM)                       *
*Title      : Create HU level Proforma invoice                        *
*Developer  : Raghahv Sureddi (U033876)                               *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_EDD_0415                                              *
*---------------------------------------------------------------------*
*Description: Create HU level Proforma invoice                        *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*======================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ============================*
*24-Aug-2018   U033876       E1DK938535      Initial Development
*---------------------------------------------------------------------*
FUNCTION zotc_0415_hu_lvl_proforma_inv .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_HU_DET) TYPE  ZLEX_TT_HU_DETAILS_FROM_EWM OPTIONAL
*"     VALUE(IM_HU_SERIAL_NR) TYPE  HUITEM_SERNR OPTIONAL
*"  EXPORTING
*"     VALUE(EX_BAPIRET) TYPE  BAPIRET2_T
*"  EXCEPTIONS
*"      SYSTEM_FAILURE
*"      COMMUNICATION_FAILURE
*"----------------------------------------------------------------------


*--Data--------------------------------------------------------------*

  DATA : lwa_return       TYPE bapiret2,                             " Return Parameter
         lwa_hudet        TYPE zlex_s_hu_details_from_ewm,           " HU Details from ewm for Hu level CI
         li_billingdatain TYPE STANDARD TABLE OF bapivbrk,           " Communication Fields for Billing Header Fields
         lv_price_error   TYPE boole_d,                              " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
         li_condition     TYPE ty_t_bapikomv,                        " Communication Fields for Conditions
         li_delv_header   TYPE STANDARD TABLE OF ty_delivery_header, " Delivery header
         li_status        TYPE ty_t_zdev_enh,
         li_hu_det        TYPE zlex_tt_hu_details_from_ewm,
         li_delv_items    TYPE STANDARD TABLE OF ty_delivery_items.  " Delivery item

*--VARIABLES-----------------------------------------------------------*
  DATA : lv_return_code   TYPE sy-subrc. " Return Value of ABAP Statements

  CONSTANTS:    lc_edd_0415         TYPE z_enhancement VALUE 'OTC_EDD_0415', "Enhancement No.
                lc_null             TYPE z_criteria    VALUE 'NULL'.         "Enh. Criteria
  CLEAR:  lv_return_code,
          lv_price_error,
          lwa_return,
          gv_copy_cond,
          gv_bom.


* get EMI entries.
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_edd_0415
    TABLES
      tt_enh_status     = li_status. "Enhancement status table

  IF li_status IS NOT INITIAL.
    SORT li_status BY criteria active.
  ENDIF. " IF li_status IS NOT INITIAL

  READ TABLE li_status   TRANSPORTING NO FIELDS
                         WITH KEY criteria = lc_null "NULL
                                active = abap_true
                                BINARY SEARCH.
  IF sy-subrc IS INITIAL.

* Changes for SCTASK0584928 begin
    PERFORM f_group_bom_items USING im_hu_det
                              CHANGING li_hu_det.
* Changes for SCTASK0584928 end

* Fetch delivery header and item data
    PERFORM f_fetch_delivery_data  USING    li_hu_det
                                   CHANGING li_delv_header " develiry header
                                            li_delv_items. " delivery items

* Fill BAPI structure
    PERFORM f_fill_bapi_structure  USING    li_delv_header " delivery header
                                            li_delv_items  " delivery items
                                            li_hu_det
                                            li_status
                                   CHANGING li_billingdatain.

*    IF gv_bom = abap_true AND  "not required as per defect 7678 - HU Level CI Price transfer Issue
    IF gv_copy_cond = abap_true.
      PERFORM f_fill_cond_structure
              USING li_delv_header " delivery header
                    li_delv_items  " delivery items
                    im_hu_det
                    li_billingdatain
                    li_status
              CHANGING lv_price_error
                       li_condition.

    ENDIF. " IF gv_copy_cond = abap_true

    IF lv_price_error IS INITIAL.
* Call BAPI to post invoice and Update the HU number in Header text
      PERFORM f_create_billingdoc   USING    li_billingdatain " BAPI billing header fields
                                             li_condition
                                             li_hu_det
                                    CHANGING lv_return_code
                                             ex_bapiret.      " return

      IF lv_return_code IS INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
      ELSE. " ELSE -> IF lv_return_code IS INITIAL
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ENDIF. " IF lv_return_code IS INITIAL
    ELSE. " ELSE -> IF lv_price_error IS INITIAL
      CLEAR: lwa_return.
      CALL FUNCTION 'BALW_BAPIRETURN_GET2'
        EXPORTING
          type   = c_error_e "  of type
          cl     = 'ZOTC_MSG'
          number = '307'
        IMPORTING
          return = lwa_return.
      APPEND lwa_return TO ex_bapiret.
      CLEAR: lwa_return.
    ENDIF. " IF lv_price_error IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL
ENDFUNCTION.
