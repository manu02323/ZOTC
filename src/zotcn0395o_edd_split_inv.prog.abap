*----------------------------------------------------------------------*
* Include    :  ZOTCN0395O_EDD_SPLIT_INV                               *
* TITLE      :  Populate the Billing item gross weight based on value  *
*               from EWM HU weights and Delivery weights               *
* DEVELOPER  :  Raghav Sureddi                                         *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0395                                            *
*----------------------------------------------------------------------*
* DESCRIPTION: Populate the Billing item gross weight for Split invoice*
*                                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER    TRANSPORT    DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 12/Oct/2019 U033876  E2DK927830  Billing Item gross weight for split *
*                                  incident: INC0520561 and INC0519091 *
*======================================================================*

  TYPES:BEGIN OF lty_vbeln,
          refdocno  TYPE vbeln_vl,
          refitmno  TYPE posnr_vl,
          refdoccat TYPE char3,
        END OF   lty_vbeln.
  TYPES:BEGIN OF lty_lips,
          vbeln TYPE vbeln_vl,
          posnr TYPE posnr_vl,
          pstyv TYPE pstyv_vl,
          brgew TYPE brgew_15,
          uepos TYPE uepos,
        END OF   lty_lips.
  TYPES: BEGIN OF lty_hu_info,
           hu_number  TYPE  exidv,
           hu_weight  TYPE  brgew,
           weight_uom TYPE  meins,
           ice_wgt    TYPE  brgew,
         END OF   lty_hu_info.
  DATA: li_lips1              TYPE STANDARD TABLE OF lty_lips,
        li_hu_info            TYPE STANDARD TABLE OF lty_hu_info,
        lwa_hu_info           TYPE lty_hu_info,
        lwa_lips1             TYPE lty_lips,
        lv_hu_tot             TYPE brgew,
        lv_deliv_itm_gros_tot TYPE brgew.
  DATA: lv_lines TYPE sy-tabix.
  DATA: lv_hu_level_ci TYPE boole_d,
        li_hu_det      TYPE zlex_tt_hu_details_from_ewm,
        li_bapi_ret    TYPE bapiret2_t,
        li_vbeln       TYPE STANDARD TABLE OF lty_vbeln,
        lwa_vbeln      TYPE lty_vbeln,
        lwa_komfk      TYPE komfk,
        lv_brgew       TYPE brgew,
        lv_ewm_logsys  TYPE recvsystem, " Receiving logical system
        lv_ewm_rfcdest TYPE bdbapidst.  " RFC destination
  DATA : li_en_status  TYPE STANDARD TABLE OF zdev_enh_status. "Enhancement Status table
  DATA: li_bomh   TYPE TABLE OF selopt, " Emi entries for bom headers
        li_werks  TYPE TABLE OF selopt, " Emi entries for Plant
        lwa_werks TYPE selopt,          " Transfer Structure for Select Options
        lwa_bomh  TYPE selopt.          " Transfer Structure for Select Options
  STATICS: lv_ewm_call       TYPE  sy-tabix,
           lv_stat_hu_tot    TYPE  brgew,
           lv_stat_deliv_tot TYPE brgew,
           lwa_395_status    TYPE zdev_enh_status.
  FIELD-SYMBOLS:
    <lfs_status> TYPE zdev_enh_status, "For Reading enhancement table
    <lfs_vbrk>   TYPE vbrkvb,
    <lfs_vbrp>   TYPE vbrpvb.
  CONSTANTS: lc_edd_0395 TYPE z_enhancement   VALUE 'OTC_EDD_0395', "Enhancement No.
             lc_werks    TYPE z_criteria      VALUE 'WERKS',
             lc_nul      TYPE z_criteria      VALUE 'NULL',         "Enh. Criteria
             lc_tcode    TYPE z_criteria      VALUE 'TCODE',
             lc_j        TYPE vbtyp           VALUE 'J',
             lc_w        TYPE char1           VALUE 'W',    " W of type CHAR1
             lc_clnt     TYPE char4           VALUE 'CLNT', " Clnt of type CHAR4
             lc_erp      TYPE char3           VALUE 'ERP',
             lc_bomh     TYPE z_criteria      VALUE 'BOMH_PSTYV'.   " Enh. Criteria
  DESCRIBE TABLE xvbrk LINES lv_lines.

  IF lv_lines > 1. "Split happend
    zcl_otc_edd_0415_hu_lvl_ci=>get_hu_lvl_ci_data(
       IMPORTING
       ex_hu_det = li_hu_det ).

    IF li_hu_det[] IS NOT INITIAL.
      lv_hu_level_ci = abap_true.
    ENDIF.

    IF lv_hu_level_ci = abap_false.
      CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
        EXPORTING
          iv_enhancement_no = lc_edd_0395
        TABLES
          tt_enh_status     = li_en_status. "Enhancement status table
      DELETE li_en_status WHERE active = abap_false.
      SORT li_en_status BY criteria active.

      READ TABLE li_en_status   TRANSPORTING NO FIELDS
                                WITH KEY criteria = lc_nul "NULL
                                         active = abap_true
                                    BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        READ TABLE li_en_status   TRANSPORTING NO FIELDS
                                 WITH KEY criteria = lc_tcode
                                          sel_low  = sy-tcode
                                          sel_high = sy-ucomm
                                          active = abap_true
                                     BINARY SEARCH.
        IF sy-subrc = 0.
          LOOP AT li_en_status INTO lwa_395_status.
            CASE  lwa_395_status-criteria.
              WHEN lc_bomh.
                lwa_bomh-sign   = lwa_395_status-sel_sign. "Sign is I for Include
                lwa_bomh-option = lwa_395_status-sel_option. " Option is EQ
                lwa_bomh-low    = lwa_395_status-sel_low. " Low Value of Range
                lwa_bomh-high   = lwa_395_status-sel_high. " High Value of Range
                APPEND lwa_bomh TO li_bomh.
                CLEAR lwa_bomh.
              WHEN lc_werks.
                lwa_werks-sign  = lwa_395_status-sel_sign. "Sign is I for Include
                lwa_werks-option = lwa_395_status-sel_option. " Option is EQ
                lwa_werks-low    = lwa_395_status-sel_low. " Low Value of Range
                lwa_werks-high   = lwa_395_status-sel_high. " High Value of Range
                APPEND lwa_werks TO li_werks.
                CLEAR lwa_werks.
              WHEN OTHERS.
            ENDCASE.

          ENDLOOP. " LOOP AT li_415_status INTO lwa_415_status

*&--Build Logical System name of EWM
          CONCATENATE lc_w
                      sy-sysid+1
                      lc_clnt
                      sy-mandt
            INTO lv_ewm_logsys.
          CONDENSE lv_ewm_logsys NO-GAPS.
*&--EWM System Update  - Testing
*&--Get RFC detination from table TBLSYSDEST
          SELECT SINGLE rfcdest " Standard RFC destination for synchronous BAPI calls
            FROM tblsysdest     " RFC Destination of Logical System
            INTO lv_ewm_rfcdest
            WHERE logsys EQ lv_ewm_logsys.
          IF sy-subrc NE 0.
            CLEAR: lv_ewm_rfcdest.
          ENDIF.
          CLEAR:lv_deliv_itm_gros_tot,lv_hu_tot.
          LOOP AT xvbrk ASSIGNING <lfs_vbrk>.

            AT NEW vbeln.
              CLEAR: lv_ewm_call,
                     lv_stat_hu_tot,
                     lv_stat_deliv_tot,
                     lwa_vbeln,
                     li_vbeln[].
              LOOP AT xvbrp ASSIGNING <lfs_vbrp> WHERE vbeln = <lfs_vbrk>-vbeln
                                                 AND   werks IN li_werks.

                lwa_vbeln-refdocno  = <lfs_vbrp>-vgbel .
                lwa_vbeln-refdoccat = lc_erp.
                APPEND lwa_vbeln TO li_vbeln.
                CLEAR:lwa_vbeln.
              ENDLOOP.
              SORT li_vbeln BY refdocno refdoccat.
              DELETE ADJACENT DUPLICATES FROM li_vbeln COMPARING refdocno refdoccat.
              CHECK li_vbeln[] IS NOT INITIAL.   " INC0520561 FUT Issue
              SELECT vbeln posnr pstyv brgew uepos FROM lips
                        INTO TABLE li_lips1
                        FOR ALL ENTRIES IN li_vbeln
                        WHERE vbeln = li_vbeln-refdocno.
              IF sy-subrc = 0.
                SORT li_lips1.
              ENDIF.
              IF lv_ewm_call = 0.

                IF lv_ewm_rfcdest IS NOT INITIAL .
* Call EWM FM to get Hu weights from EWM
                  CLEAR: li_hu_info[].
                  CALL FUNCTION 'ZOTC_0395_GROSS_WEIGHT'
                    DESTINATION lv_ewm_rfcdest
                    EXPORTING
                      im_ref                = li_vbeln
                    IMPORTING
                      ex_bapiret            = li_bapi_ret
                      ex_hu_det             = li_hu_info
                    EXCEPTIONS
                      system_failure        = 1
                      communication_failure = 2
                      OTHERS                = 3.
                  IF sy-subrc = 0 AND li_hu_info[] IS NOT INITIAL.
                    lv_ewm_call = lv_ewm_call + 1.
                    CLEAR: lv_hu_tot.
                    LOOP AT li_hu_info INTO lwa_hu_info.
                      lv_hu_tot = lv_hu_tot + lwa_hu_info-hu_weight.
                    ENDLOOP.
                    lv_stat_hu_tot = lv_hu_tot.
* Get the delivery item gross weights total from li_vbeln
                    IF li_vbeln[] IS NOT INITIAL.

* consider Delivery total with only bom items and dont consider bom header value
                      CLEAR:lv_deliv_itm_gros_tot.
                      LOOP AT li_lips1 INTO lwa_lips1 WHERE pstyv NOT IN li_bomh .
                        lv_deliv_itm_gros_tot = lv_deliv_itm_gros_tot + lwa_lips1-brgew.
                      ENDLOOP.
                      lv_stat_deliv_tot = lv_deliv_itm_gros_tot.
                    ENDIF.

                  ENDIF.
                ENDIF.

              ELSE.
                lv_hu_tot = lv_stat_hu_tot .
                lv_deliv_itm_gros_tot = lv_stat_deliv_tot.
              ENDIF.

              LOOP AT xvbrp ASSIGNING <lfs_vbrp> WHERE vbeln = <lfs_vbrk>-vbeln
                                                 AND   werks IN li_werks.
* fornula to calculate Invoice Item Weight
* Invoice Item(product) weight = Delivery Item Gross Weight *(Total Delivery Weight + Sum of all HU total Weights) / Total Delivery Weight
* for BOm Header jut pas initial value as gross weight else use below formula
                IF <lfs_vbrp>-pstyv IN li_bomh.  " BOMHeader
                  CLEAR: <lfs_vbrp>-brgew .
                ELSE.
                  IF lv_deliv_itm_gros_tot IS NOT INITIAL .
                    READ TABLE li_lips1 INTO lwa_lips1 WITH KEY vbeln = <lfs_vbrp>-vgbel
                                                                posnr = <lfs_vbrp>-vgpos.
                    IF sy-subrc = 0.
                      lv_brgew = <lfs_vbrp>-brgew.
                      IF lv_deliv_itm_gros_tot IS NOT INITIAL.
                        <lfs_vbrp>-brgew  =  lwa_lips1-brgew  * ( lv_deliv_itm_gros_tot  + lv_hu_tot ) / lv_deliv_itm_gros_tot.
* Begin of Change For INC0520561 FUT Issue
                        IF <lfs_vbrp>-brgew  LE 0.
                          <lfs_vbrp>-brgew = lv_brgew.
                        ELSE.
                          IF <lfs_vbrp>-brgew < <lfs_vbrp>-ntgew.
                            <lfs_vbrp>-ntgew = <lfs_vbrp>-brgew.
                          ENDIF.
                        ENDIF.
* End of Change For INC0520561 FUT Issue
                      ENDIF.
                    ENDIF.
                  ELSE.
                    <lfs_vbrp>-brgew  = likp-btgew.
                  ENDIF.

                ENDIF.
              ENDLOOP.

            ENDAT.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
