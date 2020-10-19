*&---------------------------------------------------------------------*
*&  Include           ZOTCN0011O_ORDER_REPRICE
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* INCLUDE    :  ZOTCN0011O_ORDER_REPRICE                               *
* TITLE      :  D3_OTC_EDD_0011 Pricing Routines                       *
* DEVELOPER  :  Abdus Salam Sk                                         *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0011 Pricing Routines                       *
*----------------------------------------------------------------------*
* DESCRIPTION:  From Credit/Debit Memo, or Web Orders when any item    *
*               data is changed repricing should happen                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT   DESCRIPTION                        *
* =========== ========  ==========  ===================================*
* 22-Jun-17   ASK       E1DK928763  INITIAL DEVELOPMENT for Defect 3083*
*----------------------------------------------------------------------*

CONSTANTS :
    lc_update       TYPE flag VALUE 'U',                                " General Flag
    lc_insert       TYPE flag VALUE 'I',                                " General Flag
    lc_enhancem_no  TYPE z_enhancement VALUE 'D3_OTC_EDD_0011_REPRICE', " Enhancement No.
    lc_item_cat     TYPE z_criteria    VALUE 'PSTYV',                   " Enh. Criteria
    lc_null1        TYPE z_criteria    VALUE 'NULL',                   " Enh. Criteria
    lc_value        TYPE z_criteria    VALUE 'VALUE',                   " Enh. Criteria
    lc_sign_i       TYPE sign          VALUE 'I',                       " Sign
    lc_option_eq    TYPE option        VALUE 'EQ',                      " Option
    lc_ord_type     TYPE z_criteria    VALUE 'AUART'.

DATA :
    lwa_enh_status   TYPE zdev_enh_status,                                  " Enhancement Status
    li_enh_status    TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Enhancement Status
    lv_value         TYPE flag,                                             " General Flag
    lr_auart1        TYPE RANGE OF auart,                                   " Sales Document Type
    lr_pstyv         TYPE RANGE OF pstyv,                                   " Sales document item category
    lwa_r_auart      LIKE LINE OF  lr_auart,
    lwa_r_pstyv      LIKE LINE OF  lr_pstyv.


* First check if repricing already happening or not.
IF new_pricing IS INITIAL.

* Then check if Line item is being changed or inserted
  IF xvbap-posnr IS NOT INITIAL AND
     ( xvbap-updkz = lc_update OR
       xvbap-updkz = lc_insert ).

    CLEAR li_enh_status.
* Bring the condition type from the EMI Table.
* Check Enh is active in EMI tool
    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
      EXPORTING
        iv_enhancement_no = lc_enhancem_no
      TABLES
        tt_enh_status     = li_enh_status.

    DELETE li_enh_status WHERE active IS INITIAL.

* Check if enhancement is active on EMI
    READ TABLE  li_enh_status
                WITH KEY criteria = lc_null1
                         TRANSPORTING NO FIELDS.
    IF sy-subrc IS INITIAL.
      LOOP AT li_enh_status INTO lwa_enh_status.

* Collect the new pricing value
        IF  lwa_enh_status-criteria = lc_value.
          lv_value = lwa_enh_status-sel_low.
        ENDIF. " IF lwa_enh_status-criteria = lc_value
        IF  lwa_enh_status-criteria = lc_ord_type.
* Populate Range table for AUART
          lwa_r_auart-sign   = lc_sign_i.
          lwa_r_auart-option = lc_option_eq.
          lwa_r_auart-low    = lwa_enh_status-sel_low.
          APPEND lwa_r_auart TO lr_auart1.
        ENDIF. " IF lwa_enh_status-criteria = lc_ord_type
        CLEAR lwa_r_auart.


        IF  lwa_enh_status-criteria = lc_item_cat.
* Populate Range table for PSTYV
          lwa_r_pstyv-sign   = lc_sign_i.
          lwa_r_pstyv-option = lc_option_eq.
          lwa_r_pstyv-low    = lwa_enh_status-sel_low.
          APPEND lwa_r_pstyv TO lr_pstyv.
        ENDIF. " IF lwa_enh_status-criteria = lc_item_cat
        CLEAR lwa_r_pstyv.
      ENDLOOP. " LOOP AT li_enh_status INTO lwa_enh_status

* Check if the Order and item category is maintained in EMi, thenonly do it.

      IF vbak-auart IN lr_auart1[] AND
         xvbap-pstyv IN lr_pstyv[] .
        new_pricing = lv_value.
      ENDIF. " IF vbak-auart IN lr_auart1[] AND
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF xvbap-posnr IS NOT INITIAL AND
ENDIF. " IF new_pricing IS INITIAL
