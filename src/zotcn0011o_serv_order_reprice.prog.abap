*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0011O_SERV_ORDER_REPRICE(Include)                 *
* TITLE      :  Pricing Routine enhancement                            *
* DEVELOPER  :  Suparna Paul                                           *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 7.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   Def#2866: CR1499(OTC_EDD_0011)Retrofited from D1 to D2  *
*----------------------------------------------------------------------*
* DESCRIPTION: Repricing of service orders.
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 09-JAN-2015 SPAUL2    E2DK908553  REPRICING OF SERVICE ORDERS        *
*&---------------------------------------------------------------------*
*&  Include           ZOTCN0011O_SERV_ORDER_REPRICE
*&---------------------------------------------------------------------*
* Local types
  TYPES: BEGIN OF lty_auart,
           mvalue1 TYPE z_mvalue_low, "Select Options: Value Low
         END OF lty_auart.

* Local constants
  CONSTANTS:lc_prog_name        TYPE char50       VALUE 'EDD0011-MV45AFZB',    "Program Name
            lc_fld_name         TYPE char50       VALUE 'VBAK-AUART',          "Field Name
            lc_new_price1       TYPE char5        VALUE 'B',                   "Pricing Type
            lc_trtyp_v          TYPE trtyp        VALUE 'V',                   "Change mode
            lc_trtyp_h          TYPE trtyp        VALUE 'H',                   "Creation mode
            lc_sign             TYPE char2        VALUE 'I',                   "Integer
            lc_option           TYPE char2        VALUE 'EQ',                  "Equal
            lc_active           TYPE char1        VALUE 'X'.                   "Active
* Local data declaration
  DATA:    lr_auart TYPE RANGE OF auart,                     " Range Table for Order Types
           lwa_auart LIKE LINE OF lr_auart,                  " Work area for Order Types
           li_auart TYPE STANDARD TABLE OF lty_auart.        " Int Table for Order type
* Local field symbols
  FIELD-SYMBOLS: <lfs_auart> TYPE lty_auart.

*The enhancement should work only if transaction is change/creation mode
*   If transaction is in creation/change mode
  IF t180-trtyp = lc_trtyp_v
  OR t180-trtyp = lc_trtyp_h.

*     Get order types from OTC Control table
    SELECT mvalue1
      FROM  zotc_prc_control
      INTO  TABLE li_auart
      WHERE vkorg      = vbak-vkorg   AND
            vtweg      = vbak-vtweg   AND
            mprogram   = lc_prog_name  AND
            mparameter = lc_fld_name   AND
            mactive    = lc_active.

    IF sy-subrc IS INITIAL.

      LOOP AT li_auart ASSIGNING <lfs_auart>.
        lwa_auart-sign = lc_sign.
        lwa_auart-option = lc_option.
        lwa_auart-low = <lfs_auart>-mvalue1.
        APPEND lwa_auart TO lr_auart.
        CLEAR lwa_auart.
      ENDLOOP.
*When the service order type ZSER was created with an order reason then pricing should be updated with a condition type
*Where (B   = Carry out new pricing)
      IF vbak-auart IN lr_auart
      AND vbak-augru IS NOT INITIAL.
        new_pricing = lc_new_price1.
      ENDIF.
    ENDIF.
  ENDIF.
