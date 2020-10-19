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
*======================================================================*
* 11/Nov/2016 U033814  E1DK919518  Defect 6303                         *
*======================================================================*
*======================================================================*
* 16/Nov/2016 U033814  E1DK919518  Defect 6698                         *
*======================================================================*
*======================================================================*
* 13/Dec/2016 U033814  E1DK919518  Defect 7392                         *
*======================================================================*
*======================================================================*
* 18/Feb/2017 U033814  E1DK925874  Defect 9784                         *
*======================================================================*
*======================================================================*
* 24/Feb/2017 U033814  E1DK925874  CR - 373                            *
*======================================================================*
*======================================================================*
* 14/Mar/2016 U033814  E1DK925874  Defect 10175                        *
*======================================================================*
*======================================================================*
* 23/May/2017 U033814  E1DK928183  Defect 2895                         *
* When Populating EU/NEU  in Tax Destination Country Ignore Region     *
* Check for Intercompany Billing                                       *
*======================================================================*
*======================================================================*
* 14/Jul/2017 U033814  E1DK929174  Defect 3201                         *
*======================================================================*
*======================================================================*
* 20/DEC/2017 U100018  E1DK933276  Defect# 4487: Pricing Error -       *
*                                  Mandatory Condition MWST is missing *
*======================================================================*
*05/Dec/2018 U033814  E1DK939672   SCTASK0768865 Enable Pricing for
* EU to Canada Scenarious
*======================================================================*
*&---------------------------------------------------------------------*
*&  Include           ZOTC_EDD_0335_EU_NEU
*&---------------------------------------------------------------------*

  DATA : lv_taxkd    TYPE takld,                             " Tax classification for customer
         lv_xegld    TYPE xegld,                             " Indicator: European Union Member?
         lv_kunnr    TYPE kunnr,                             " Customer Number
         lv_stceg    TYPE stceg,                             " VAT Registration Number
         lv_vbtyp    TYPE vbtyp,                             " SD document category
         lv_bukrs    TYPE bukrs,                             " Company Code
         ls_vbak     TYPE vbak,                              " Sales Document: Header Data
         lv_zshtco   TYPE land1_gp,                          " Customer Number
         lv_zshtrg   TYPE regio,                             " Region (State, Province, County)
         lwa_zshtco  TYPE zshtco ,                           " Custom table for third territories
         lwa_vbpa    TYPE vbpa,                              " Sales Document: Partner
         ls_vbap     TYPE vbap,                              " Sales Document: Item Data
         lwa_status  TYPE zdev_enh_status,                   " Enhancement Status
         li_status   TYPE STANDARD TABLE OF zdev_enh_status. "Enhancement Status table

  CONSTANTS :
       lc_criteria   TYPE z_criteria           VALUE 'VKORG',        " Enh. Criteria
       lc_edd_0335   TYPE z_enhancement        VALUE 'OTC_EDD_0335', " Enhancement No.
       c_ics         TYPE char3                VALUE 'ICS',          " Ics of type CHAR3
       c_we          TYPE parvw                VALUE 'WE',           " Partner Function
       c_eu          TYPE land1                VALUE 'EU',           " Country Key
       c_neu         TYPE land1                VALUE 'NEU',          " Country Key
       lc_null       TYPE char4                VALUE 'NULL',         " Null of type CHAR4
       c_5           TYPE vbtyp                VALUE '5',            " SD document category
       c_6           TYPE vbtyp                VALUE '6',            " SD document category
       c_n           TYPE zztaxc1              VALUE 'N',            " Tax Classification for Bio-Rad Vendor
* Begin of CR 373
       c_0           TYPE zztaxc1              VALUE '0', " Tax Classification for Bio-Rad Vendor
* End of CR 373
       c_y           TYPE zztaxc1              VALUE 'Y', " Tax Classification for Bio-Rad Vendor
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
                                                    sel_low  = vbrk-vkorg
                                                    active   = abap_true.
    IF sy-subrc EQ 0.


** Begin of Defect 10175
* Populate the Tax Classification for Material Master
      IF tkomp-matnr IS NOT INITIAL AND vbap-zzrland IS NOT INITIAL.

        SELECT SINGLE taxm1 INTO tkomp-taxm1 FROM mlan " Tax Classification for Material
                                              WHERE matnr EQ tkomp-matnr
                                               AND aland EQ vbrk-zzrland.
      ENDIF. " IF tkomp-matnr IS NOT INITIAL AND vbap-zzrland IS NOT INITIAL
** End of Defect 10175


* Get the Tax classification for Intercompany Customer
      SELECT SINGLE * FROM vbak INTO ls_vbak WHERE vbeln EQ vbrp-aubel.

      SELECT SINGLE * FROM vbap INTO ls_vbap WHERE vbeln EQ vbrp-aubel
                                             AND posnr EQ vbrp-aupos.
      IF sy-subrc EQ 0.

        SELECT SINGLE vbtyp FROM tvfk INTO lv_vbtyp
                      WHERE fkart EQ vbrk-fkart.
        IF lv_vbtyp NE c_5 AND lv_vbtyp NE c_6.

          SELECT SINGLE stceg FROM t001n INTO lv_stceg WHERE bukrs EQ ls_vbak-bukrs_vf
                                                     AND land1 EQ ls_vbap-zzrland.
          IF lv_stceg IS NOT INITIAL.
            MOVE c_n TO tkomp-zztaxc1.
          ELSE. " ELSE -> IF lv_stceg IS NOT INITIAL
            SELECT SINGLE stceg FROM t001 INTO lv_stceg WHERE bukrs EQ ls_vbak-bukrs_vf
                                                          AND land1 EQ ls_vbap-zzrland.
            IF lv_stceg IS NOT INITIAL.
              MOVE c_1 TO tkomp-zztaxc1.
* Begin of CR 373
            ELSE. " ELSE -> IF lv_stceg IS NOT INITIAL
              MOVE c_0 TO tkomp-zztaxc1.
* End of CR 373
            ENDIF. " IF lv_stceg IS NOT INITIAL
          ENDIF. " IF lv_stceg IS NOT INITIAL
        ELSE. " ELSE -> IF lv_vbtyp NE c_5 AND lv_vbtyp NE c_6
* Begin of Defect 10175
          IF tkomp-matnr IS NOT INITIAL AND vbrk-zzrland IS NOT INITIAL.
            SELECT SINGLE taxm1 INTO tkomp-taxm1 FROM mlan " Tax Classification for Material
                                                  WHERE matnr EQ tkomp-matnr
                                                   AND aland EQ vbrk-zzrland.
          ENDIF. " IF tkomp-matnr IS NOT INITIAL AND vbrk-zzrland IS NOT INITIAL
* End of Defect 10175

          SELECT SINGLE bukrs FROM t001k INTO lv_bukrs WHERE bwkey EQ ls_vbap-werks.
          SELECT SINGLE stceg FROM t001n INTO lv_stceg WHERE bukrs EQ lv_bukrs
                                                        AND land1 EQ ls_vbap-zzrlandic.
          IF lv_stceg IS NOT INITIAL.
            MOVE c_n TO tkomp-zztaxc1.
          ELSE. " ELSE -> IF lv_stceg IS NOT INITIAL
            SELECT SINGLE stceg FROM t001 INTO lv_stceg WHERE bukrs EQ lv_bukrs
                                                       AND land1 EQ ls_vbap-zzrlandic.
            IF sy-subrc EQ 0.
              MOVE c_1 TO tkomp-zztaxc1.
* Begin of CR 373
            ELSE. " ELSE -> IF sy-subrc EQ 0
              MOVE c_0 TO tkomp-zztaxc1.
* End of CR 373
            ENDIF. " IF sy-subrc EQ 0
*--Begin of defect#3201 by mthatha
*--> Begin of delete for D3_OTC_EDD_0335_Defect# 4487 by U100018 on 20-DEC-2017
*            IF vbap-zzvatflow = space.
*<-- End of delete for D3_OTC_EDD_0335_Defect# 4487 by U100018 on 20-DEC-2017
*--> Begin of change for D3_OTC_EDD_0335_Defect# 4487 by U100018 on 20-DEC-2017

            IF ls_vbap-zzvatflow = space.
*<-- End of change for D3_OTC_EDD_0335_Defect# 4487 by U100018 on 20-DEC-2017
* Begin of SCTASK0768865
              READ TABLE li_status  INTO lwa_status  WITH KEY criteria = lc_criteria
                                                  sel_low  = vbak-vkorg
                                                    active   = abap_true.
              IF sy-subrc EQ 0.
* End of SCTASK0768865
                MOVE c_x TO tkomp-zztaxc1.
* Begin of SCTASK0768865
              ELSE. " ELSE -> IF sy-subrc EQ 0
                SELECT SINGLE stceg FROM t001n INTO lv_stceg WHERE bukrs EQ lv_bukrs
                                                           AND land1 EQ vbrk-zzrland.
                IF sy-subrc EQ 0.
                  move c_n to tkomp-zztaxc1.
                ENDIF. " if sy-subrc eq 0
              ENDIF. " IF sy-subrc EQ 0
* End of SCTASK0768865
            ENDIF. " IF ls_vbap-zzvatflow = space
*--End of defect#3201 by mthatha
          ENDIF. " IF lv_stceg IS NOT INITIAL
        ENDIF. " IF lv_vbtyp NE c_5 AND lv_vbtyp NE c_6
* Populate the tax classification and reporting country in tkomp-zzrland and zztaxc1
*      MOVE lv_taxkd TO tkomp-zztaxc1.
        MOVE vbrk-zzrland TO tkomp-zzrland.

* Based on the conditions populate the destination land TKOMP-ZZDLAND as European Union or not.
* Added on 08/09/2016
* Begin of Defect 2895
        IF lv_vbtyp NE c_5 AND lv_vbtyp NE c_6.
          IF vbrk-zzrland NE vbrk-zzdland.
            SELECT SINGLE xegld FROM t005 INTO lv_xegld
              WHERE land1 EQ vbrk-zzdland.
            IF lv_xegld EQ abap_true.
*  Begin of CR 216
*            MOVE c_eu TO tkomp-zzdland.
              SELECT SINGLE * FROM vbpa INTO lwa_vbpa WHERE vbeln  EQ ls_vbap-vbeln
                                                         AND posnr EQ ls_vbap-posnr
                                                         AND parvw EQ c_we.
              IF sy-subrc NE 0.
                SELECT SINGLE * FROM vbpa INTO lwa_vbpa WHERE vbeln  EQ ls_vbap-vbeln
                                                          AND parvw EQ c_we.
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
                  ENDIF. " IF lwa_zshtco-ztaxthird EQ c_y
                ENDIF. " IF sy-subrc EQ 0
              ENDIF. " IF lwa_vbpa-kunnr IS NOT INITIAL
*End of CR 216
            ELSE. " ELSE -> IF lv_xegld EQ abap_true
              MOVE c_neu TO tkomp-zzdland.
            ENDIF. " IF lv_xegld EQ abap_true
          ELSE. " ELSE -> IF vbrk-zzrland NE vbrk-zzdland
* Begin of Defect - 7392
            SELECT SINGLE xegld FROM t005 INTO lv_xegld
              WHERE land1 EQ vbap-zzdland.
            IF lv_xegld EQ abap_true.
*          Begin of cr 216
*                  move c_eu to tkomp-zzdland.
* Begin of Defect 9784
* Begin of Defect 4487 - Uncoment code from Defect 9784
              SELECT SINGLE * FROM vbpa INTO lwa_vbpa WHERE vbeln  EQ ls_vbap-vbeln
                                                         AND posnr EQ ls_vbap-posnr
                                                         AND parvw EQ c_we.
              IF sy-subrc NE 0.
                SELECT SINGLE * FROM vbpa INTO lwa_vbpa WHERE vbeln  EQ ls_vbap-vbeln
                                                          AND parvw EQ c_we.
              ENDIF. " IF sy-subrc NE 0
              IF lwa_vbpa-kunnr IS NOT INITIAL.

                SELECT SINGLE land1 regio FROM kna1 " General Data in Customer Master
                  INTO (lv_zshtco , lv_zshtrg) WHERE kunnr EQ lwa_vbpa-kunnr.

                SELECT SINGLE land1 regio FROM kna1 " General Data in Customer Master
*                INTO (lv_zshtco , lv_zshtrg) WHERE kunnr EQ vbrk-kunrg.
* Begin of Defect 2895
* Begin of Defect 4487
*                 INTO (lv_zshtco , lv_zshtrg) WHERE kunnr EQ vbrk-kunag.
                   INTO (lv_zshtco , lv_zshtrg) WHERE kunnr EQ lwa_vbpa-kunnr.
* End of Defect 4487
* End of Defect 2895
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
* Begin of Defect 4487
              ENDIF. " IF lwa_vbpa-kunnr IS NOT INITIAL
* End of Defect 4487
            ENDIF. " IF lv_xegld EQ abap_true
* End of Defect - 7392
          ENDIF. " IF vbrk-zzrland NE vbrk-zzdland
* Begin of Defect 2895
* For IC Invoice dont consider Region
        ELSE. " ELSE -> IF lv_vbtyp NE c_5 AND lv_vbtyp NE c_6
          IF vbrk-zzrland NE vbrk-zzdland.
            SELECT SINGLE xegld FROM t005 INTO lv_xegld
              WHERE land1 EQ vbrk-zzdland.
            IF lv_xegld EQ abap_true.
              MOVE c_eu TO tkomp-zzdland.
            ELSE. " ELSE -> IF lv_xegld EQ abap_true
              MOVE c_neu TO tkomp-zzdland.
            ENDIF. " IF lv_xegld EQ abap_true
          ENDIF. " IF vbrk-zzrland NE vbrk-zzdland
        ENDIF. " IF lv_vbtyp NE c_5 AND lv_vbtyp NE c_6

* End of Defect 2895
        CLEAR lv_xegld.
* Based on the conditions populate the destination land TKOMK-LAND1 as European Union or not.
        IF tkomk-land1 NE vbrk-zzdland.
          SELECT SINGLE xegld FROM t005 INTO lv_xegld
            WHERE land1 EQ tkomk-land1.
          IF lv_xegld EQ abap_true.
*  Begin of CR 216
*            MOVE c_eu TO tkomk-land1.
            SELECT SINGLE * FROM zshtco INTO lwa_zshtco
                                                    WHERE land1 EQ tkomk-land1
                                                      AND regio EQ tkomk-regio.
            IF lwa_zshtco-ztaxthird EQ c_y.
* Begin of Defect 6303
              MOVE c_neu TO tkomk-land1.
*              MOVE c_eu TO tkomk-land1.
* End of Defect 6303
            ELSE. " ELSE -> IF lwa_zshtco-ztaxthird EQ c_y
* Begin of Defect 6303
              MOVE c_eu TO tkomk-land1.
*              MOVE c_neu TO tkomk-land1.
            ENDIF. " IF lwa_zshtco-ztaxthird EQ c_y
*  End of CR 216
*            MOVE c_eu TO tkomk-land1.
          ELSE. " ELSE -> IF lv_xegld EQ abap_true
            MOVE c_neu TO tkomk-land1.
          ENDIF. " IF lv_xegld EQ abap_true
        ENDIF. " IF tkomk-land1 NE vbrk-zzdland

        CLEAR lv_xegld.
* Based on the conditions populate Ship to Country land TKOMP-ZZSLAND as European Union or not.
        IF tkomk-aland NE vbrk-zzrland.
          SELECT SINGLE xegld FROM t005 INTO lv_xegld
            WHERE land1 EQ tkomk-aland.
          IF lv_xegld EQ abap_true.
            MOVE c_eu TO tkomp-zzsland.
          ELSE. " ELSE -> IF lv_xegld EQ abap_true
            MOVE c_neu TO tkomp-zzsland.
          ENDIF. " IF lv_xegld EQ abap_true
        ENDIF. " IF tkomk-aland NE vbrk-zzrland

      ELSE. " ELSE -> IF sy-subrc EQ 0
* For Intercompany STO
        SELECT SINGLE bukrs FROM t001k INTO lv_bukrs WHERE bwkey EQ vbrp-werks.
        SELECT SINGLE stceg FROM t001n INTO lv_stceg WHERE bukrs EQ lv_bukrs
                                                      AND land1 EQ  vbrk-zzrland.
        IF lv_stceg IS NOT INITIAL.
          MOVE c_n TO tkomp-zztaxc1.
        ELSE. " ELSE -> IF lv_stceg IS NOT INITIAL
          SELECT SINGLE stceg FROM t001 INTO lv_stceg WHERE bukrs EQ lv_bukrs
                                                     AND land1 EQ vbrk-zzrland.
          IF lv_stceg IS NOT INITIAL.
            MOVE c_1 TO tkomp-zztaxc1.
* Begin of CR 373
          ELSE. " ELSE -> IF lv_stceg IS NOT INITIAL
            MOVE c_0 TO tkomp-zztaxc1.
* End of CR 373
          ENDIF. " IF lv_stceg IS NOT INITIAL
        ENDIF. " IF lv_stceg IS NOT INITIAL

        MOVE vbrk-zzrland TO tkomp-zzrland.
* Based on the conditions populate the destination land TKOMP-ZZDLAND as European Union or not.
        IF vbrk-zzrland NE vbrk-zzdland.
          SELECT SINGLE xegld FROM t005 INTO lv_xegld
            WHERE land1 EQ vbrk-zzdland.
          IF lv_xegld EQ abap_true.
*            MOVE c_eu TO tkomp-zzdland.
*  Begin of CR 216
*            MOVE c_eu TO tkomp-zzdland.
* Begin of Defect - 6698
*            SELECT SINGLE * FROM vbpa INTO lwa_vbpa WHERE vbeln  EQ ls_vbap-vbeln
*                                                       AND posnr EQ ls_vbap-posnr
*                                                       AND parvw EQ c_we.
*            IF sy-subrc NE 0.
*              SELECT SINGLE * FROM vbpa INTO lwa_vbpa WHERE vbeln  EQ ls_vbap-vbeln
*                                                        AND parvw EQ c_we.
*            ENDIF. " IF sy-subrc NE 0
            READ TABLE xvbpa INTO lwa_vbpa WITH KEY parvw = c_we.
* End of Defect 6698.
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
                ENDIF. " IF lwa_zshtco-ztaxthird EQ c_y
              ENDIF. " IF sy-subrc EQ 0
            ENDIF. " IF lwa_vbpa-kunnr IS NOT INITIAL
*End of CR 216
          ELSE. " ELSE -> IF lv_xegld EQ abap_true
            MOVE c_neu TO tkomp-zzdland.
          ENDIF. " IF lv_xegld EQ abap_true
        ENDIF. " IF vbrk-zzrland NE vbrk-zzdland

        CLEAR lv_xegld.
* Based on the conditions populate the destination land TKOMK-LAND1 as European Union or not.
        IF tkomk-land1 NE vbrk-zzdland.
          SELECT SINGLE xegld FROM t005 INTO lv_xegld
            WHERE land1 EQ tkomk-land1.
          IF lv_xegld EQ abap_true.
*  Begin of CR 216
*            MOVE c_eu TO tkomk-land1.
            SELECT SINGLE * FROM zshtco INTO lwa_zshtco
                                                    WHERE land1 EQ tkomk-land1
                                                      AND regio EQ tkomk-regio.
            IF lwa_zshtco-ztaxthird EQ c_y.
* Begin of Defect 6303
              MOVE c_neu TO tkomk-land1.
*              MOVE c_eu TO tkomk-land1.
* End of Defect 6303
            ELSE. " ELSE -> IF lwa_zshtco-ztaxthird EQ c_y
* Begin of Defect 6303
              MOVE c_eu TO tkomk-land1.
*              MOVE c_neu TO tkomk-land1.
            ENDIF. " IF lwa_zshtco-ztaxthird EQ c_y
*  End of CR 216
          ELSE. " ELSE -> IF lv_xegld EQ abap_true
            MOVE c_neu TO tkomk-land1.
          ENDIF. " IF lv_xegld EQ abap_true
        ENDIF. " IF tkomk-land1 NE vbrk-zzdland

        CLEAR lv_xegld.
* Based on the conditions populate the Ship to Country TKOMP-ZZSLAND as European Union or not.
        IF tkomk-aland NE vbrk-zzrland.
          SELECT SINGLE xegld FROM t005 INTO lv_xegld
            WHERE land1 EQ tkomk-aland.
          IF lv_xegld EQ abap_true.
            MOVE c_eu TO tkomp-zzsland.
          ELSE. " ELSE -> IF lv_xegld EQ abap_true
            MOVE c_neu TO tkomp-zzsland.
          ENDIF. " IF lv_xegld EQ abap_true
        ENDIF. " IF tkomk-aland NE vbrk-zzrland
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
