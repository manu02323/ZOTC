*&---------------------------------------------------------------------*
*&  Include           ZXVVAU01
*&---------------------------------------------------------------------*
* INCLUDE    :  EXIT_SAPMV45A_001  ( ZXVVAU01 )                        *
* TITLE      :   D2_OTC_EDD_0179_ Billing Plan Type Update             *
* DEVELOPER  :  Paramita Bose                                          *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 7.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:     D2_OTC_EDD_0179_ Billing Plan Type Update             *
*----------------------------------------------------------------------*
* DESCRIPTION: Implement the logic to populate Billing plan type(FPART)*
*              whenService Max Feed is equal to 2.                     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE             USER         TRANSPORT      DESCRIPTION             *
* ===========    ========      ==========     =========================*
* 18-JUL-2014    PBOSE         E2DK901255     INITIAL DEVELOPMENT      *
*&---------------------------------------------------------------------*
* 03-FEB-2015    APODDAR       E2DK901255     CR D2_254 Initial Check  *
*                                             for ZZBMTD , ZZBFRQ      *
*&---------------------------------------------------------------------*
* 01-APR-2015    ASK       E2DK901255     CR D2_541 Taking Billing     *
*                                         Meth. and Freq. from IVBAP   *
*&---------------------------------------------------------------------*

* Type Declaration of IVBAP
TYPES : BEGIN OF lty_ivbap,
          posnr TYPE posnr_va, " Sales Document Item
          tabix TYPE sy-tabix, " Index
          selkz TYPE char1,    " Selkz of type CHAR1
        END OF lty_ivbap.

* Table type Declaration
TYPES : lty_t_ivbap         TYPE STANDARD TABLE OF lty_ivbap INITIAL SIZE 0.

* Data Declaration
DATA :  li_status        TYPE STANDARD TABLE OF zdev_enh_status,                 " Enhancement Status table
        li_bilpln_ctrl   TYPE STANDARD TABLE OF zotc_bilpln_ctrl INITIAL SIZE 0, " Billing Plan
        li_soitem        TYPE sapplco_sls_ord_erpcrte_r_tab7,                    " Internal table
        li_ivbap         TYPE lty_t_ivbap,                                       " Internal table
        lv_fpart         TYPE fpart,                                             " Billing/Invoicing Plan Type
        lv_billmethod    TYPE z_bmethod,                                         " Billing Method
        lv_bilfrequency  TYPE z_bfrequency,                                      " Billing Frequency
        lr_auart         TYPE RANGE OF  auart,                                   " Order Type
        lr_zzdoctyp      TYPE RANGE OF  z_doctyp,                                " ZZDOCTYP
        lwa_auart        LIKE LINE OF lr_auart,                                  " Work area
        lwa_zzdoctyp     LIKE LINE OF lr_zzdoctyp.                               " Work area

CONSTANTS : lc_null      TYPE z_criteria    VALUE 'NULL',              " Enh. Criteria
            lc_eq        TYPE char2         VALUE 'EQ',                " Equal
            lc_i         TYPE char1         VALUE 'I',                 " Integer
            lc_auart     TYPE z_criteria    VALUE 'AUART',             " Enh. Criteria
            lc_zzdoctyp  TYPE z_criteria    VALUE 'ZZDOCTYP',          " Enh. Criteria
            lc_ivbap     TYPE char20        VALUE '(SAPMV45A)IVBAP[]', " ('(SAPMV45A)IVBAP[]')
            lc_edd_0179  TYPE z_enhancement VALUE 'D2_OTC_EDD_0179'.   " Enhancement No.

* Field Symbol Declaration
FIELD-SYMBOLS : <lfs_soitem> TYPE sapplco_sls_ord_erpcrte_req_21, " IDT SalesOrderERPCreateRequest_sync_V2 Item
               <lfs_status> TYPE zdev_enh_status,                 " Status
               <lfs_ivbap_tab> TYPE lty_t_ivbap,                  " IVBAP_TAB
               <lfs_ivbap> TYPE lty_ivbap.                        " IVBAP


* Call to EMI Function Module To Get List Of EMI Statuses
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_edd_0179
  TABLES
    tt_enh_status     = li_status.

DELETE li_status WHERE active <> abap_true.

IF li_status IS NOT INITIAL.

*--Check for Global user exit activation check
  READ TABLE li_status WITH KEY criteria = lc_null
                       TRANSPORTING NO FIELDS.
  IF sy-subrc EQ  0.

    LOOP AT li_status ASSIGNING <lfs_status>. " WHERE criteria = lc_auart.

      CASE <lfs_status>-criteria.
        WHEN  lc_auart.
          lwa_auart-sign = lc_i.
          lwa_auart-option = lc_eq.
          lwa_auart-low = <lfs_status>-sel_low.
          APPEND lwa_auart TO lr_auart.
          CLEAR lwa_auart.

        WHEN lc_zzdoctyp.
          lwa_zzdoctyp-sign = lc_i.
          lwa_zzdoctyp-option = lc_eq.
          lwa_zzdoctyp-low = <lfs_status>-sel_low.
          APPEND lwa_zzdoctyp TO lr_zzdoctyp.
          CLEAR lwa_zzdoctyp.
        WHEN OTHERS.
* Do nothing in other case.
      ENDCASE.

    ENDLOOP. " IF sy-subrc EQ 0
    UNASSIGN <lfs_status>.

    "Begin of Changes for D2_OTC_EDD_0179 CR D2_254 by APODDAR on Feb 5th 2015

* Begin of Comment for CR D2_541
* Now no need to use this FM to get Billing Method and Frequency
* Now the interface IDD_0090 will pass these fields directly to VBAP
* So, we can use them directly.

*To fetch the data tables from memory
*    CALL FUNCTION 'ZOTC_BILLING_GET'
*      IMPORTING
*        ex_so_item = li_soitem.
*
* " Check Li_Soitem to find whether its a manual or a Proxy Generated Order
*    IF li_soitem IS INITIAL.
* End of Comment for CR D2_541
                                            "This is a Manual Order
      IF ivbap-posnr IS NOT INITIAL
        AND ivbak-auart IN lr_auart
        AND ivbap-zz_bilmet IS NOT INITIAL
        AND ivbap-zz_bilfr  IS NOT INITIAL.

* Fetch Billing/Invoicing Plan Type from table ZOTC_BILPLN_CTRL
        SELECT SINGLE   fpart   " Billing/Invoicing Plan Type
        FROM   zotc_bilpln_ctrl " Billing Plan
        INTO lv_fpart
        WHERE       vkorg   = ivbak-vkorg
                AND  vtweg   = ivbak-vtweg
                AND  auart   = ivbak-auart
                AND  pstyv   = ivbap-pstyv
                AND z_bilmet = ivbap-zz_bilmet
                AND z_bilfr  = ivbap-zz_bilfr.

        IF  sy-subrc EQ 0 AND lv_fpart IS NOT INITIAL.
          billingplantype = lv_fpart.

        ELSE. " ELSE -> IF sy-subrc EQ 0 AND lv_fpart IS NOT INITIAL

          MESSAGE e042(zotc_msg) WITH lv_billmethod lv_bilfrequency. " No Billing Plan Found for Billing Method and Billing Frequency

        ENDIF. " IF sy-subrc EQ 0 AND lv_fpart IS NOT INITIAL
      ENDIF. " IF ivbap-posnr IS NOT INITIAL

* Begin of Comment for CR D2_541
*    ELSE. " ELSE -> IF ivbap-posnr IS NOT INITIAL
* " End of Changes for D2_OTC_EDD_0179 CR D2_254 by APODDAR on Feb 5th 2015
*
* "This is a Proxy Generated Order
*      IF ivbap-posnr IS NOT INITIAL.
*
*        IF ivbak-auart IN lr_auart. " Order type equal to ZOR
*          IF ivbak-zzdoctyp IN lr_zzdoctyp. " Reference Doc Type equal to 02 for service Max Feed
*
*
** Read table IVBAP from Stack
*            ASSIGN (lc_ivbap) TO <lfs_ivbap_tab>.
*            IF sy-subrc IS INITIAL.
*              li_ivbap = <lfs_ivbap_tab>.
*            ENDIF. " IF sy-subrc IS INITIAL
*
*            READ TABLE li_ivbap ASSIGNING <lfs_ivbap>
*              WITH KEY posnr = ivbap-posnr.
*            IF sy-subrc IS INITIAL.
*              READ TABLE li_soitem ASSIGNING <lfs_soitem> INDEX <lfs_ivbap>-tabix.
*              IF sy-subrc IS INITIAL.
** Assign the value of Bill method and Bill frequency.
*                lv_billmethod = <lfs_soitem>-z01otc_zbill_method.
*                lv_bilfrequency = <lfs_soitem>-z01otc_zbill_frequency.
*              ENDIF. " IF sy-subrc IS INITIAL
*            ENDIF. " IF sy-subrc IS INITIAL
*
** Fetch Billing/Invoicing Plan Type from table ZOTC_BILPLN_CTRL
*            SELECT SINGLE   fpart   " Billing/Invoicing Plan Type
*            FROM   zotc_bilpln_ctrl " Billing Plan
*            INTO lv_fpart
*            WHERE       vkorg   = ivbak-vkorg
*                    AND  vtweg   = ivbak-vtweg
*                    AND  auart   = ivbak-auart
*                    AND  pstyv   = ivbap-pstyv
*                    AND z_bilmet = lv_billmethod
*                    AND z_bilfr  = lv_bilfrequency.
*
*            IF  sy-subrc EQ 0 AND lv_fpart IS NOT INITIAL.
*              billingplantype = lv_fpart.
*            ELSE. " ELSE -> IF sy-subrc EQ 0 AND lv_fpart IS NOT INITIAL
*              MESSAGE e042(zotc_msg) WITH lv_billmethod lv_bilfrequency. " No Billing Plan Found for Billing Method and Billing Frequency
*            ENDIF. " IF sy-subrc EQ 0 AND lv_fpart IS NOT INITIAL
*          ENDIF. " IF ivbap-posnr IS NOT INITIAL
*        ENDIF. " IF li_soitem IS INITIAL
*      ENDIF. " IF li_status IS NOT INITIAL
*
*    ENDIF.
* End of Comment for CR D2_541
  ENDIF.
ENDIF.
