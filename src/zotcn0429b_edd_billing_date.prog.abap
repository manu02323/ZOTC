************************************************************************
* INCLUDE    :  ZOTCN0429B_EDD_BILLING_DATE(Enhancement Implementation)*
* TITLE      :  Populate Billng Date as Current date if period is close*
* DEVELOPER  :  Srinivasa Gurijala                                     *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0429                                            *
*----------------------------------------------------------------------*
* DESCRIPTION: Populate Billng Date as Current date if period is close *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER    TRANSPORT    DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 27/Feb/2019 U033814  E1DK940679   SCTASK0784263 Initial Development  *
*======================================================================*
*&---------------------------------------------------------------------*
*&  Include           ZOTCN0429B_EDD_BILLING_DATE
*&---------------------------------------------------------------------*

  DATA:li_status_0429    TYPE STANDARD TABLE OF zdev_enh_status,    "Enhancement Status table
       lwa_status_0429   TYPE zdev_enh_status,                      " Enhancement Status
       lv_gjahr          TYPE gjahr,                                " Fiscal Year
       lv_monat          TYPE monat,                                " Fiscal Period
       lv_monat1         TYPE FRPER,
       lv_poper          TYPE poper,                                " Posting period
       lv_oper           TYPE frper.                                " First Posting Period Allowed (in Interval 1)

  CONSTANTS :
       lc_edd_0429  TYPE z_enhancement        VALUE 'OTC_EDD_0429', " Enhancement No.
       lc_null_429  TYPE char4                VALUE 'NULL'.         " Null of type CHAR4

*--Call to EMI Function Module To Get List Of EMI Statuses for Transportation Group Mapping
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_edd_0429
    TABLES
      tt_enh_status     = li_status_0429.

  DELETE li_status_0429 WHERE active NE abap_true.

  READ TABLE li_status_0429  INTO lwa_status_0429  WITH KEY criteria = lc_null_429
                                                              active   = abap_true.
  IF sy-subrc EQ 0.
    IF xvbrk-fkdat IS NOT INITIAL.
      CALL FUNCTION 'FI_PERIOD_DETERMINE'
        EXPORTING
          i_budat        = xvbrk-fkdat
          i_bukrs        = xvbrk-bukrs
        IMPORTING
          e_gjahr        = lv_gjahr
          e_monat        = lv_monat
          e_poper        = lv_poper
        EXCEPTIONS
          fiscal_year    = 1
          period         = 2
          period_version = 3
          posting_period = 4
          special_period = 5
          version        = 6
          posting_date   = 7
          OTHERS         = 8.
      IF sy-subrc EQ 0.
        lv_monat1 = lv_monat.
        CALL FUNCTION 'FI_PERIOD_CHECK'
          EXPORTING
            i_bukrs          = xvbrk-bukrs
            i_gjahr          = lv_gjahr
            i_koart          = '+'
*           I_KONTO          = '+'
            i_monat          = lv_monat1
            i_glvor          = 'RFBU'
          IMPORTING
            e_oper           = lv_oper
          EXCEPTIONS
            error_period     = 1
            error_period_acc = 2
            invalid_input    = 3
            OTHERS           = 4.
        IF sy-subrc EQ 1.
          xvbrk-fkdat = sy-datum.
        ENDIF. " IF sy-subrc eq 1

      ENDIF. " IF sy-subrc EQ 0

    ENDIF. " IF vbrk-fkdat IS NOT INITIAL
  ENDIF. " IF sy-subrc EQ 0
