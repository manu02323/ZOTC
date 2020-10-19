************************************************************************
* PROG       :  ZOTC_EDD_0335_EU_NEU    (Include Program)              *
* TITLE      :  Populate the reporting country and destination Country *
*               as European Union or Not in KOMP Structure to pick up  *
*               the Valid access sequence for MWST Condition           *
* DEVELOPER  :  Srinivasa Gurijala                                     *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0035                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Population of KOMP ZZRLAND ZZDLAND ZTAXINC              *
*              for Tax reporting and Tax Destination                   *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER    TRANSPORT    DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 10/Jul/2016 U033814  E1DK919518  FB2_D3_OTC_EDD_0335_EHQ_EU_VAT_Ta   *
*======================================================================*
* 26/Oct/2016 U033814  E1DK919518  CR 216                              *
*======================================================================*
* 11/Nov/2016 U033814  E1DK919518  Defect 6303                         *
*======================================================================*
*======================================================================*
* 13/Dec/2016 U033814  E1DK919518  Defect 7392                        *
*======================================================================*
*======================================================================*
* 24/Feb/2017 U033814  E1DK925874  CR - 373                            *
*======================================================================*
*======================================================================*
* 14/Mar/2016 U033814  E1DK925874  Defect 10175                        *
*======================================================================*
*======================================================================*
* 14/Jul/2017 U033814  E1DK929174  Defect 3201                         *
*======================================================================*
*&---------------------------------------------------------------------*
*&  Include           ZOTC_EDD_0335_EU_NEU
*&---------------------------------------------------------------------*

  DATA : lv_taxkd    TYPE takld,                             " Tax classification for customer
         lv_xegld    TYPE xegld,                             " Indicator: European Union Member?
         lv_tabix    TYPE sy-tabix,                          " Index of Internal Tables
         lwa_vbpa    TYPE vbpa,                              " Sales Document: Partner
         lv_shipto   TYPE kunnr_we,                          " Foreign Trade: Legal Control: Customer number of ship-to p.
         lv_kunnr    TYPE kunnr,                             " Customer Number
         lv_stceg    TYPE stceg,                             " VAT Registration Number
         lwa_status  TYPE zdev_enh_status,                   " Enhancement Status
         lv_zshtco       TYPE land1_gp,                      " Customer Number
         ls_xvbap    TYPE vbapvb,                            " Document Structure for XVBAP/YVBAP
         lv_zshtrg       TYPE regio,                         " Region (State, Province, County)
         lwa_zshtco  TYPE zshtco ,                           " Custom table for third territories
         li_status   TYPE STANDARD TABLE OF zdev_enh_status. "Enhancement Status table
  DATA : li_vbpa TYPE STANDARD TABLE OF vbpa INITIAL SIZE 0. " Sales Document: Partner
  CONSTANTS :
       lc_criteria   TYPE z_criteria           VALUE 'VKORG',        " Enh. Criteria
       lc_edd_0335   TYPE z_enhancement        VALUE 'OTC_EDD_0335', " Enhancement No.
       lc_posnr      TYPE char6                VALUE '000000',       " Posnr of type CHAR6
       c_ics         TYPE char3                VALUE 'ICS',          " Ics of type CHAR3
       lc_null       TYPE char4                VALUE 'NULL',         " Null of type CHAR4
       c_eu          TYPE land1                VALUE 'EU',           " Country Key
       c_neu         TYPE land1                VALUE 'NEU',          " Country Key
       c_we          TYPE parvw                VALUE 'WE',           " Partner Function
       c_y           TYPE zztaxc1              VALUE 'Y',            " Tax Classification for Bio-Rad Vendor
       c_n           TYPE zztaxc1              VALUE 'N',            " Tax Classification for Bio-Rad Vendor
* Begin of CR 373
       c_0           TYPE zztaxc1              VALUE '0', " Tax Classification for Bio-Rad Vendor
* End of CR 373
       c_1           TYPE zztaxc1              VALUE '1', " Tax Classification for Bio-Rad Vendor
*--Begin of defect#3201 by mthatha
       c_x           TYPE zztaxc1              VALUE 'X'. " Tax Classification for Bio-Rad Vendor
*--End of defect#3201 by mthatha

*--Call to EMI Function Module To Get List Of EMI Statuses for Transportation Group Mapping
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_edd_0335
    TABLES
      tt_enh_status     = li_status.

  DELETE li_status WHERE active NE abap_true.

  READ TABLE li_status  INTO lwa_status  WITH KEY criteria = lc_null
                                                  active   = abap_true.
  IF sy-subrc EQ 0.

    READ TABLE li_status  INTO lwa_status  WITH KEY criteria = lc_criteria
                                                    sel_low  = vbak-vkorg
                                                      active   = abap_true.
    IF sy-subrc EQ 0.
* Get the Intercompany Customer based on Sales Order Company Code
*    CONCATENATE c_ics vbak-bukrs_vf INTO lv_kunnr.


** Begin of Defect 10175
* Populate the Tax Classification for Material Master
      IF tkomp-matnr IS NOT INITIAL AND vbap-zzrland IS NOT INITIAL.

        SELECT SINGLE taxm1 INTO tkomp-taxm1 FROM mlan " Tax Classification for Material
                                              WHERE matnr EQ tkomp-matnr
                                               AND aland EQ vbap-zzrland.
      ENDIF. " IF tkomp-matnr IS NOT INITIAL AND vbap-zzrland IS NOT INITIAL
** End of Defect 10175

* Get the Tax classification for Intercompany Customer
      SELECT SINGLE stceg FROM t001n INTO lv_stceg WHERE bukrs EQ vbak-bukrs_vf
                                                 AND land1 EQ vbap-zzrland.
      IF lv_stceg IS NOT INITIAL.
        MOVE c_n TO tkomp-zztaxc1.
      ELSE. " ELSE -> IF lv_stceg IS NOT INITIAL
        SELECT SINGLE stceg FROM t001 INTO lv_stceg WHERE bukrs EQ vbak-bukrs_vf
                                                   AND land1 EQ vbap-zzrland.
        IF lv_stceg IS NOT INITIAL.
          MOVE c_1 TO tkomp-zztaxc1.
* Begin of CR 373
        ELSE. " ELSE -> IF lv_stceg IS NOT INITIAL
          MOVE c_0 TO tkomp-zztaxc1.
* End of CR 373
        ENDIF. " IF lv_stceg IS NOT INITIAL
*--Begin of defect#3201 by mthatha
        If vbap-zzvatflow = space.
          MOVE c_x TO tkomp-zztaxc1.
        endif.
*--End of defect#3201 by mthatha
      ENDIF. " IF lv_stceg IS NOT INITIAL

* Populate the tax classification and reporting country in tkomp-zzrland and zztaxc1
*    MOVE lv_taxkd TO tkomp-zztaxc1.
      MOVE vbap-zzrland TO tkomp-zzrland.
* Based on the conditions populate the destination land TKOMP-ZZDLAND as European Union or not.
      IF vbap-zzrland NE vbap-zzdland.
        SELECT SINGLE xegld FROM t005 INTO lv_xegld
          WHERE land1 EQ vbap-zzdland.
        IF lv_xegld EQ abap_true.
*          Begin of cr 216
*                  move c_eu to tkomp-zzdland.
          li_vbpa[] = xvbpa[].
          READ TABLE li_vbpa  INTO lwa_vbpa WITH  KEY  vbeln = vbap-vbeln
                                                       posnr = vbap-posnr
                                                       parvw = c_we .
          IF sy-subrc NE 0.

            READ TABLE li_vbpa INTO lwa_vbpa WITH  KEY    vbeln = vbap-vbeln
                                                          posnr = lc_posnr
                                                          parvw = c_we.
          ENDIF. " IF sy-subrc NE 0
          IF lwa_vbpa-kunnr IS NOT INITIAL.
            SELECT SINGLE land1 regio FROM kna1 " General Data in Customer Master
              INTO (lv_zshtco , lv_zshtrg) WHERE kunnr EQ lwa_vbpa-kunnr.
            IF sy-subrc EQ 0.
              SELECT SINGLE * FROM zshtco INTO lwa_zshtco
                                          WHERE land1 EQ lv_zshtco
                                            AND regio EQ lv_zshtrg.
              IF lwa_zshtco-ztaxthird EQ c_y.
* Begin of Defect 6303
                MOVE c_neu TO tkomp-zzdland.
*                  MOVE c_eu TO tkomp-zzdland.
* End of Defect 6303
              ELSE. " ELSE -> IF lwa_zshtco-ztaxthird EQ c_y
* Begin of Defect 6303
*                  MOVE c_neu TO tkomp-zzdland.
                MOVE c_eu TO tkomp-zzdland.
* End of Defect 6303
              ENDIF. " IF lwa_zshtco-ztaxthird EQ c_y
            ENDIF. " IF sy-subrc EQ 0
          ELSE. " ELSE -> IF lwa_vbpa-kunnr IS NOT INITIAL
            MOVE c_eu TO tkomp-zzdland.
          ENDIF. " IF lwa_vbpa-kunnr IS NOT INITIAL
*End of CR 216
        ELSE. " ELSE -> IF lv_xegld EQ abap_true
          MOVE c_neu TO tkomp-zzdland.
        ENDIF. " IF lv_xegld EQ abap_true
      ELSE. " ELSE -> IF vbap-zzrland NE vbap-zzdland
* Begin of Defect - 7392
        SELECT SINGLE xegld FROM t005 INTO lv_xegld
          WHERE land1 EQ vbap-zzdland.
        IF lv_xegld EQ abap_true.
*          Begin of cr 216
*                  move c_eu to tkomp-zzdland.
          li_vbpa[] = xvbpa[].
          READ TABLE li_vbpa  INTO lwa_vbpa WITH  KEY  vbeln = vbap-vbeln
                                                       posnr = vbap-posnr
                                                       parvw = c_we .
          IF sy-subrc NE 0.

            READ TABLE li_vbpa INTO lwa_vbpa WITH  KEY    vbeln = vbap-vbeln
                                                          posnr = lc_posnr
                                                          parvw = c_we.
          ENDIF. " IF sy-subrc NE 0
          IF lwa_vbpa-kunnr IS NOT INITIAL.
            SELECT SINGLE land1 regio FROM kna1 " General Data in Customer Master
              INTO (lv_zshtco , lv_zshtrg) WHERE kunnr EQ lwa_vbpa-kunnr.
            IF sy-subrc EQ 0.
              SELECT SINGLE * FROM zshtco INTO lwa_zshtco
                                          WHERE land1 EQ lv_zshtco
                                            AND regio EQ lv_zshtrg.
              IF lwa_zshtco-ztaxthird EQ c_y.
* Begin of Defect 6303
                MOVE c_neu TO tkomp-zzdland.
*                  MOVE c_eu TO tkomp-zzdland.
              ENDIF. " IF lwa_zshtco-ztaxthird EQ c_y
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF lwa_vbpa-kunnr IS NOT INITIAL
        ENDIF. " IF lv_xegld EQ abap_true
* End of Defect - 7392
      ENDIF. " IF vbap-zzrland NE vbap-zzdland
      CLEAR lv_xegld.
* Based on the conditions populate the destination land TKOMP-ZZDLAND as European Union or not.
      IF tkomk-land1 NE vbap-zzdland.
        SELECT SINGLE xegld FROM t005 INTO lv_xegld
          WHERE land1 EQ tkomk-land1.
        IF lv_xegld EQ abap_true.
*  Begin of CR 216
*            MOVE c_eu TO tkomk-land1.
          SELECT SINGLE * FROM zshtco INTO lwa_zshtco
                                                  WHERE land1 EQ komk-land1
                                                    AND regio EQ komk-regio.
          IF lwa_zshtco-ztaxthird EQ c_y.
* Begin of Defect 6303
            MOVE c_neu TO tkomk-land1.
*              MOVE c_eu TO tkomk-land1.
* End of Defect 6303
          ELSE. " ELSE -> IF lwa_zshtco-ztaxthird EQ c_y
* Begin of Defect 6303
            MOVE c_eu TO tkomk-land1.
*              MOVE c_neu TO tkomk-land1.
* End of Defect 6303
          ENDIF. " IF lwa_zshtco-ztaxthird EQ c_y
*  End of CR 216
        ELSE. " ELSE -> IF lv_xegld EQ abap_true
          MOVE c_neu TO tkomk-land1.
        ENDIF. " IF lv_xegld EQ abap_true
      ENDIF. " IF tkomk-land1 NE vbap-zzdland

      CLEAR lv_xegld.
* Based on the conditions populate the destination land TKOMP-ZZDLAND as European Union or not.
      IF tkomk-aland NE vbap-zzrland.
        SELECT SINGLE xegld FROM t005 INTO lv_xegld
          WHERE land1 EQ tkomk-aland.
        IF lv_xegld EQ abap_true.
          MOVE c_eu TO tkomp-zzsland.
        ELSE. " ELSE -> IF lv_xegld EQ abap_true
          MOVE c_neu TO tkomp-zzsland.
        ENDIF. " IF lv_xegld EQ abap_true
      ENDIF. " IF tkomk-aland NE vbap-zzrland
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
