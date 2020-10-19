***********************************************************************
*Program    : ZOTCN0136O_UPD_ITEM_CAT                                 *
*Title      : Custom Fields on Sales Document                         *
*Developer  : Shruti Gupta                                            *
*Object type: Include                                                 *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_EDD_0136                                           *
*---------------------------------------------------------------------*
*Description: Custom Fields on Sales Document Header & Item           *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*06-FEB-2015  SGUPTA4       E2DK900492      CR D2_484, Updating the   *
*                                           Item Category on the basis*
*                                           of doc type,billing method*
*                                           and billing frequency     *
*                                           whose values are entered  *
*                                           in a popup by the user.   *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZOTCN0136O_UPD_ITEM_CAT
*&---------------------------------------------------------------------*

*---------------------------------------------------------------------*
*           CONSTANT DECLARATION                                      *
*---------------------------------------------------------------------*
CONSTANTS: lc_tabname       TYPE tabname       VALUE 'VBAP',                "Table Name
           lc_fldname_meth  TYPE fieldname     VALUE 'ZZ_BILMET',           "Field Name
           lc_fldname_freq  TYPE fieldname     VALUE 'ZZ_BILFR',            "Field Name
           lc_edd_0136_001  TYPE z_enhancement VALUE 'D2_OTC_EDD_0136_001', " Enhancement
           lc_null_0136     TYPE z_criteria    VALUE 'NULL',                " Enh. Criteria
           lc_mtpos         TYPE z_criteria    VALUE 'MTPOS',               " Enh. Criteria
           lc_auart         TYPE z_criteria    VALUE 'AUART',               " Enh. Criteria
           lc_h_create      TYPE char1         VALUE 'H',                   " H of type CHAR1
           lc_v_change      TYPE char1         VALUE 'V',                   " V of type CHAR1
           lc_vkorg         TYPE z_criteria    VALUE 'VKORG',               " Enh. Criteria
           lc_vtweg         TYPE z_criteria    VALUE 'VTWEG',               " Enh. Criteria
           lc_sign_i        TYPE bapisign      VALUE 'I',                   " Inclusion/exclusion criterion SIGN for range tables
           lc_eq            TYPE bapioption    VALUE 'EQ',                  " Selection operator OPTION for range tables
           lc_auart_ic_flip TYPE z_criteria    VALUE 'AUART_IC_FLIP'.       " Sales Document Type

*---------------------------------------------------------------------*
*           LOCAL DATA DECLARATION                                    *
*---------------------------------------------------------------------*
DATA: lv_pstyv           TYPE                   pstyv,           "Item Category
      lwa_fields         TYPE                   sval,            "Interface for function group SPO4
      li_fields          TYPE TABLE OF          sval,            "Interface for function group SPO4
      li_soitem          TYPE sapplco_sls_ord_erpcrte_r_tab7,    " SalesOrderERPCreateRequest_sync_V2 Item Table
      li_edd_0136_status TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
      lr_vkorg_range     TYPE RANGE OF          vkorg,           " Sales Organization
      lwa_r_vkorg        LIKE LINE OF           lr_vkorg_range,  " Sales Organization
      lr_auart_range     TYPE RANGE OF          auart,           " Sales Document Type
      lwa_r_auart        LIKE LINE OF           lr_auart_range,  " Sales Document Type
      lr_zor_range       TYPE RANGE OF          auart,           " Sales Document Type
      lwa_r_zor          LIKE LINE OF           lr_zor_range.    " Sales Document Type

FIELD-SYMBOLS:
     <lfs_status>   TYPE          zdev_enh_status,       " Enhancement Status
     <lfs_soitem>   TYPE sapplco_sls_ord_erpcrte_req_21. " IDT SalesOrderERPCreateRequest_sync_V2 Item
*Screen Enable/Disable based on transaction type: If ADD or CHNAGE
*Then fields are available for user entry.
IF  t180-trtyp = lc_h_create OR t180-trtyp = lc_v_change .


* If Item Category is ZPLN then
* Billing Method and Billing Frequency fields are avialable for user entry.
* These fields are available for input in below scenario
* 1. When a line item is added
* 2. Item category is ZPLN
* 3. If both fields are populated then it can't be changed.
* Call to EMI Function Module To Get List Of EMI Statuses
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_edd_0136_001     "D2_OTC_EDD_0136_001
    TABLES
      tt_enh_status     = li_edd_0136_status. "Enhancement status table

*Non active entries are removed.
  DELETE li_edd_0136_status WHERE active EQ abap_false.

  READ TABLE li_edd_0136_status WITH KEY criteria = lc_null_0136 TRANSPORTING NO FIELDS. "NULL.
  IF sy-subrc EQ 0.

*Preparing range table for Salaes Organization(VKORG) and order type (AUART).
    IF li_edd_0136_status IS NOT INITIAL.
      lwa_r_vkorg-sign   = lc_sign_i. "I
      lwa_r_vkorg-option = lc_eq. "EQ
      lwa_r_auart-sign   = lc_sign_i. "I
      lwa_r_auart-option = lc_eq. "EQ
      lwa_r_zor-sign     = lc_sign_i. "I
      lwa_r_zor-option   = lc_eq. "EQ

      LOOP AT li_edd_0136_status ASSIGNING <lfs_status>.
*Range table for VKORG
        IF <lfs_status>-criteria = lc_vkorg. "Value:'VKORG'
*Clearing out the low value.
          CLEAR lwa_r_vkorg-low.
          lwa_r_vkorg-low    = <lfs_status>-sel_low.
          APPEND lwa_r_vkorg TO lr_vkorg_range.
        ENDIF. " LOOP AT li_edd_0136_status ASSIGNING <lfs_status>

*Range table for AUART: ZCMR and ZDMR
        IF <lfs_status>-criteria = lc_auart. "Value:'AUART'
*Clearing out the low value.
          CLEAR lwa_r_auart-low.
          lwa_r_auart-low    = <lfs_status>-sel_low.
          APPEND lwa_r_auart TO lr_auart_range.
        ENDIF. " IF li_edd_0136_status IS NOT INITIAL

*Range table for AUART:ZOR
        IF <lfs_status>-criteria = lc_auart_ic_flip. "Value: AUART_IC_FLIP
*Clearing out the low value.
          CLEAR lwa_r_zor-low.
          lwa_r_zor-low    = <lfs_status>-sel_low.
          APPEND lwa_r_zor TO lr_zor_range.
        ENDIF. " IF sy-subrc EQ 0

      ENDLOOP. " IF t180-trtyp = lc_h_create OR t180-trtyp = lc_v_change
    ENDIF. " IF t180-trtyp = lc_h_create OR t180-trtyp = lc_v_change


*If either of the range table is initial then Exit from the include.
    IF lr_vkorg_range IS INITIAL OR lr_auart_range IS INITIAL OR lr_zor_range IS INITIAL.
      EXIT.
    ENDIF. " IF lr_vkorg_range IS INITIAL OR lr_auart_range IS INITIAL OR lr_zor_range IS INITIAL

*Fetching the value of ZZ_BILMET and ZZ_BILFR in case of creating Sales Order
*with reference
    IF i_vbrp IS INITIAL.
      SELECT vbeln     " Billing Document
             posnr     " Billing item
             zz_bilmet " Billing Method
             zz_bilfr  " Billing Frequency
        FROM vbap      " Billing Document: Item Data
        INTO TABLE i_vbrp
        WHERE vbeln = vbap-vgbel.
    ENDIF. " IF i_vbrp IS INITIAL

*For Document types ZCMR and ZDMR, the pop-up will be enabled if:
*1. The order is created without reference, i.e. VBAP-VGBEL is initial.
*2. The order is created with reference and ZZ_BILMET and ZZ_BILFR are not filled.
    IF i_vbrp IS NOT INITIAL.
      READ TABLE i_vbrp INTO wa_vbrp WITH KEY vbeln = vbap-vgbel
                                              posnr = vbap-vgpos.
      IF sy-subrc EQ 0.
        IF  vbak-auart IN lr_auart_range AND vbap-vgbel IS  NOT INITIAL
          AND wa_vbrp-zz_bilmet IS NOT INITIAL AND wa_vbrp-zz_bilfr IS NOT INITIAL.
          wa_vbap-vbeln = vbap-vbeln.
          wa_vbap-posnr = vbap-posnr.
          IF vbap-posnr IS NOT INITIAL.
            APPEND wa_vbap TO i_vbap.
          ENDIF. " IF vbap-posnr IS NOT INITIAL
          EXIT.
        ENDIF. " IF vbak-auart IN lr_auart_range AND vbap-vgbel IS NOT INITIAL
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF i_vbrp IS NOT INITIAL

**The popup logic should work for:
*1. Order Type(AUART) : ZOR,ZCMR and ZDMR
*2. Sales Organization(VKORG): 1000(USA) and Canada(1020)
*3. Distributution channel(VTWEG): 10
*4. Item Category(MTPOS): ZPLN

    IF ( vbak-auart IN lr_auart_range OR vbak-auart IN lr_zor_range ) AND  vbak-vkorg IN lr_vkorg_range.
      READ TABLE li_edd_0136_status WITH KEY criteria = lc_vtweg "10
                                             sel_low = vbak-vtweg TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
        READ TABLE li_edd_0136_status WITH KEY criteria = lc_mtpos "ZPLN
                                               sel_low  = maapv-mtpos TRANSPORTING NO FIELDS.
        IF sy-subrc EQ 0.

*        From Interface the pop up should not come
          IF call_activity NE gc_activity_lord.
            IF vbap-zz_bilmet IS INITIAL AND
               vbap-zz_bilfr IS INITIAL. "LORD
              lwa_fields-tabname = lc_tabname. "VBAP
              lwa_fields-fieldname = lc_fldname_meth. "ZZ_BILMET
              APPEND lwa_fields TO li_fields.
              lwa_fields-fieldname = lc_fldname_freq. "ZZ_BILFR
              APPEND lwa_fields TO li_fields.

              CLEAR lwa_fields.


***When Sales Order gets created with reference, the pop-up comes twice for
*every line item, so to enable the popup only once checking i_vbap table if
*it is already populated or not.
              READ TABLE i_vbap INTO wa_vbap
                                 WITH KEY vbeln = vbap-vbeln
                                          posnr = vbap-posnr .

              IF sy-subrc NE 0.

*Until the user enters both  billing method and billing frequency or leave both of them blank, the pop-up is needed
                DO.
*Pop up to input values from the user for Billing Method and Billing Frequency.
                  CALL FUNCTION 'POPUP_GET_VALUES'
                    EXPORTING
                      popup_title     = 'Enter the value of Billing Method and Billing Frequency'(067)
                    TABLES
                      fields          = li_fields
                    EXCEPTIONS
                      error_in_fields = 1
                      OTHERS          = 2.

                  IF sy-subrc EQ 0.

*Read value of Billing Method
**Binary Search not used as there are only two records in the table li_fields
                    READ TABLE li_fields INTO lwa_fields WITH KEY fieldname = lc_fldname_meth.
                    IF sy-subrc EQ 0.
                      vbap-zz_bilmet = lwa_fields-value.
                    ENDIF. " IF sy-subrc EQ 0
*Read value of Billing Frequency
**Binary Search not used as there are only two records in the table li_fields
                    READ TABLE li_fields INTO lwa_fields WITH KEY fieldname = lc_fldname_freq.
                    IF sy-subrc EQ 0.
                      vbap-zz_bilfr = lwa_fields-value.
                    ENDIF. " IF sy-subrc EQ 0

                    IF ( vbap-zz_bilmet IS INITIAL AND vbap-zz_bilfr IS INITIAL )
                     OR ( vbap-zz_bilmet IS NOT INITIAL AND vbap-zz_bilfr IS NOT INITIAL ) .
*If Billing Method and Billing Frequency both are empty or both are filled
*then EXIT from do-endo loop in case of ZOR
**And for ZCMR and ZDMR, populate the i_vbap table to enable the popup only once when creating sales order
*with refrence and then EXIT.
                      IF vbak-auart IN lr_auart_range.
                        wa_vbap-vbeln = vbap-vbeln.
                        wa_vbap-posnr = vbap-posnr.
                        wa_vbap-zz_bilmet = vbap-zz_bilmet.
                        wa_vbap-zz_bilfr = vbap-zz_bilfr.
                        IF vbap-posnr IS NOT INITIAL.
                          APPEND wa_vbap TO i_vbap.
                        ENDIF. " IF vbap-posnr IS NOT INITIAL
                        EXIT.
                      ELSEIF vbak-auart IN lr_zor_range.
                        EXIT.
                      ENDIF. " IF vbak-auart IN lr_auart_range
                    ELSE. " ELSE -> IF vbap-posnr IS NOT INITIAL
*If either of Billing Method and Billing Frequency is initial, display an information message
                      MESSAGE i000(zotc_msg) WITH 'Enter both Billing Method and Billing Frequency'(018). " & & & &
                    ENDIF. " IF ( vbap-zz_bilmet IS INITIAL AND vbap-zz_bilfr IS INITIAL )
                  ENDIF. " IF sy-subrc EQ 0
                ENDDO.
              ELSE. " ELSE -> IF vbak-auart IN lr_auart_range
                vbap-zz_bilmet = wa_vbap-zz_bilmet.
                vbap-zz_bilfr  = wa_vbap-zz_bilfr.
              ENDIF. " IF sy-subrc NE 0
            ENDIF. " IF vbap-zz_bilmet IS INITIAL AND
          ENDIF. " IF call_activity NE gc_activity_lord

* Item Category flip logic should only work for AUART = "ZOR"
          IF vbak-auart IN lr_zor_range.
*Fetch the Item Category on the basis of Sales org, Distribution Channel,
*Sales Document Type, Billing Method and Billing Frequency.
            SELECT pstyv          " Sales document item category
            UP TO 1 ROWS
            FROM zotc_bilpln_ctrl " Billing Plan
            INTO lv_pstyv
            WHERE vkorg    EQ vbak-vkorg
            AND   vtweg    EQ vbak-vtweg
            AND   auart    EQ vbak-auart
            AND   z_bilmet EQ vbap-zz_bilmet
            AND   z_bilfr  EQ vbap-zz_bilfr.
            ENDSELECT.
**If entry is found, it replaces Item category on sales order (VBAP-PSTYV)
**with the new value as per ZOTC_BILPLN_CTRL table
            IF sy-subrc EQ 0 AND lv_pstyv IS NOT INITIAL.
              vbap-pstyv = lv_pstyv.
            ENDIF. " IF sy-subrc EQ 0 AND lv_pstyv IS NOT INITIAL
          ENDIF. " IF vbak-auart IN lr_zor_range
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF ( vbak-auart IN lr_auart_range OR vbak-auart IN lr_zor_range ) AND vbak-vkorg IN lr_vkorg_range

  ENDIF. " IF t180-trtyp = lc_h_create OR t180-trtyp = lc_v_change
ENDIF. " IF t180-trtyp = lc_h_create OR t180-trtyp = lc_v_change
