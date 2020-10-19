*&---------------------------------------------------------------------*
*& Function Module  ZOTC_0335_VAT_PROCESSFLOW
*&---------------------------------------------------------------------*
************************************************************************
* FM         :  ZOTC_0335_VAT_PROCESSFLOW                              *
* FG         :  ZOTC_VAT_PROCESS                                       *
* TITLE      :  Determine Vat Process Flow to derive reporting and     *
*               and Destination Country                                *
* DEVELOPER  :  Srinivasa.G                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_EDD_0335_EHQ EU VAT Tax Code Determination         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Function Module to derive reporting and  Destination   *
*               Country and pupulate VBAP Custom Fields                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 7-Jun-2016 U033814   E1DK919518 INITIAL DEVELOPMENT - OTC_EDD#0335   *
*&---------------------------------------------------------------------*
* 26/Oct/2016 U033814  E1DK919518  CR 216                              *
*======================================================================*
*&---------------------------------------------------------------------*
* 07/Mar/2017 U033814  E1DK925874  Defect - 10175                      *
*======================================================================*
*&---------------------------------------------------------------------*
* 09/May/2017 U033814  E1DK927856  Defect - 2784                       *
*======================================================================*
*======================================================================*
* 23/May/2017 U033814  E1DK928183  Defect 2895                         *
*======================================================================*
*======================================================================*
* 29/May/2017 U033814  E1DK928331  Defect 2941  Revert 2895 Changes    *
*                                  Which accidentally moved to Prod    *
*======================================================================*

FUNCTION zotc_0335_vat_processflow.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_VBAK) TYPE  VBAK
*"     REFERENCE(IM_VBAP) TYPE  VBAP
*"     REFERENCE(IT_VBPA) TYPE  TAB1_VBPA
*"     REFERENCE(IM_VBKD) TYPE  VBKD
*"  CHANGING
*"     REFERENCE(CHNG_VBAP) TYPE  VBAP
*"----------------------------------------------------------------------
* Data Declarations
  DATA : lwa_vatprocess  TYPE zvatproces, " Custom configuration table for Vat scenario’s
         lwa_vatprocessa TYPE zvatproces, " Custom configuration table for Vat scenario’s
         lwa_vbpa        TYPE vbpa,       " Sales Document: Partner
         lv_soldtoc           TYPE land1, "Sold to Country
         lwa_vbkd        TYPE vbkd,       " Sales Document: Partner
         lwa_ztaxinc     TYPE ztaxinc,    " Custom table for incoterms
         lv_bukrs        TYPE bukrs,      " Company Code
         lv_zshtco       TYPE land1_gp,   " Customer Number
         lv_zshtrg       TYPE regio,      " Region (State, Province, County)
         lv_xegld        TYPE xegld,      " Indicator: European Union Member?
         lv_ztaxthird    TYPE zztaxthird, " Customer in Third Territory
         lv_zdplco       TYPE land1_gp,   " Country Key
         lv_zsocc        TYPE bukrs,      " Company Code
         lv_zplcc        TYPE bukrs,      " Company Code
         lv_land1        TYPE land1_gp,   " Country Key
         lv_stceg        TYPE stceg,      " VAT Registration Number
         lv_stceg1       TYPE stceg,      " VAT Registration Number
         lv_tvkocc       TYPE bukrs,      " Company Code
         lv_t001nco      TYPE land1_gp,   " Country Key
         lv_t001ncc      TYPE bukrs,      " Country Key
         lv_t001wco      TYPE land1_gp,   " Country Key
         lv_stcegt       TYPE stceg,      " VAT Registration Number
         lv_tabix        TYPE sy-tabix,   " Index of Internal Tables
         lv_zsoco        TYPE land1_gp.   " sales order Country
  DATA : lt_vatprocess TYPE STANDARD TABLE OF zvatproces INITIAL SIZE 0, " Custom configuration table for Vat scenario’s
       lwa_process_tmp TYPE zvatproces,                                  " Custom configuration table for Vat scenario’s
       lwa_vatprocessa1 TYPE zvatproces,                                 " Custom configuration table for Vat scenario’s
       lwa_status       TYPE zdev_enh_status,                            " Enhancement Status
       li_status        TYPE STANDARD TABLE OF zdev_enh_status,          "Enhancement Status table
  lv_index TYPE  char2,                                                  " Index of type CHAR1
  lv_field TYPE char30,                                                  " Field of type CHAR20
  lv_field1 TYPE char30.                                                 " Field1 of type CHAR20
  FIELD-SYMBOLS : <fsvalue1> TYPE any,
                  <fsvalue>  TYPE any.
  CONSTANTS : c_y        TYPE char1 VALUE 'Y',                 " Y of type CHAR1
              c_n        TYPE char1 VALUE 'N',                 " N of type CHAR1
              c_p        TYPE char1 VALUE 'P',                 " P of type CHAR1
              lc_criteria    TYPE z_criteria VALUE 'BSARK',    " Sales Document Type
              c_fr       TYPE land1                VALUE 'FR', " Country Key
              c_mc       TYPE land1                VALUE 'MC', " Country Key
              c_ag       TYPE parvw VALUE 'AG',                " Partner Function
              c_we       TYPE parvw VALUE 'WE'.                " Partner Function
  CONSTANTS : c_sourcequer TYPE char22 VALUE 'lwa_process_tmp-zvatq0'  ,     " Sourcequer of type CHAR22
              c_sourcequer1 TYPE char22 VALUE 'lwa_process_tmp-zvatq'  ,     " Sourcequer of type CHAR22
              c_destquesr  TYPE char23 VALUE 'lwa_vatprocessa1-zvatq0',      " Destquesr of type CHAR23
              c_destquesr1  TYPE char23 VALUE 'lwa_vatprocessa1-zvatq',      " Destquesr of type CHAR23
              lc_edd_0335   TYPE z_enhancement        VALUE 'OTC_EDD_0335',  " Enhancement No.
              lc_null       TYPE z_criteria            VALUE 'NULL',         " Enh. Criteria
              lc_flip       TYPE z_criteria            VALUE 'FLIP_COUNTRY'. " Enh. Criteria

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
    lv_zsocc = im_vbak-bukrs_vf.
* Retreive Company Code Country
    SELECT SINGLE land1 FROM t001 INTO lv_zsoco WHERE bukrs EQ lv_zsocc.
* Answer the 9 Questions to derive reporting Country and Destination Country
    DO 10 TIMES.
      lv_tabix = sy-index.
      CASE lv_tabix.

        WHEN 1.
* Check if Invoicing Company Code Not Equal to Plant Company Code
          SELECT SINGLE bukrs  FROM t001k " Valuation area
                       INTO  lv_zplcc
                       WHERE bwkey EQ im_vbap-werks.
          IF lv_zplcc NE im_vbak-bukrs_vf.
            MOVE c_y TO lwa_vatprocess-zvatq01.
          ELSE. " ELSE -> IF lv_zplcc NE im_vbak-bukrs_vf
            MOVE c_n TO lwa_vatprocess-zvatq01.
          ENDIF. " IF lv_zplcc NE im_vbak-bukrs_vf

        WHEN 2.
*To determine if the destination is within the EU VAT territory
          READ TABLE it_vbpa INTO lwa_vbpa WITH KEY vbeln = im_vbap-vbeln
                                                    posnr = im_vbap-posnr
                                                    parvw = c_we.
          IF sy-subrc NE 0.
            READ TABLE it_vbpa INTO lwa_vbpa WITH KEY vbeln = im_vbap-vbeln
                                                      parvw = c_we.
          ENDIF. " IF sy-subrc NE 0
          IF lwa_vbpa-kunnr IS NOT INITIAL.
            SELECT SINGLE land1 regio FROM kna1 " General Data in Customer Master
              INTO (lv_zshtco , lv_zshtrg) WHERE kunnr EQ lwa_vbpa-kunnr.
* Begin of CR 216
            IF lv_zshtco EQ c_mc.
              MOVE c_fr TO lv_zshtco.
            ENDIF. " IF lv_zshtco EQ c_mc
* End of CR 216
            IF sy-subrc EQ 0.
* Begin of Defect 2941
** begin of defect 2895
*              read table li_status  into lwa_status  with key criteria = lc_flip
*                                                              sel_low   = lv_zshtco.
*              if sy-subrc eq 0.
*                move lwa_status-sel_high to lv_zshtco.
*              endif. " if sy-subrc eq 0
** end of defect 2895
* End of Defect 2941
              SELECT SINGLE xegld FROM t005 " Countries
                  INTO lv_xegld WHERE land1 EQ lv_zshtco.
              SELECT SINGLE ztaxthird FROM zshtco " Custom table for third territories
                         INTO lv_ztaxthird
                         WHERE land1 EQ lv_zshtco
                           AND regio EQ lv_zshtrg.
              IF lv_ztaxthird EQ c_y OR lv_xegld NE abap_true.
                MOVE c_y TO lwa_vatprocess-zvatq02.
              ELSE. " ELSE -> IF lv_ztaxthird EQ c_y OR lv_xegld NE abap_true
*              IF lv_ztaxthird EQ c_n.
                MOVE c_n TO lwa_vatprocess-zvatq02.
*              ENDIF. " IF lv_ztaxthird EQ c_n
              ENDIF. " IF lv_ztaxthird EQ c_y OR lv_xegld NE abap_true
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF lwa_vbpa-kunnr IS NOT INITIAL

        WHEN 3.
* To determine if the supply plant country is equal to the ship to country
          SELECT SINGLE land1 FROM t001w INTO lv_zdplco
                         WHERE werks EQ im_vbap-werks.
          IF lv_zdplco EQ lv_zshtco.
            MOVE c_y TO lwa_vatprocess-zvatq03.
          ELSE. " ELSE -> IF lv_zdplco EQ lv_zshtco
            MOVE c_n TO lwa_vatprocess-zvatq03.
          ENDIF. " IF lv_zdplco EQ lv_zshtco

        WHEN 4.
* To determine if the title transfer is at plant based on the incoterm

          SELECT SINGLE * FROM ztaxinc INTO lwa_ztaxinc
                             WHERE inco1 EQ im_vbkd-inco1.
          IF lwa_ztaxinc-ztitle EQ c_p.
            MOVE c_y TO lwa_vatprocess-zvatq04.
          ELSE. " ELSE -> IF lwa_ztaxinc-ztitle EQ c_p
            MOVE c_n TO lwa_vatprocess-zvatq04.
          ENDIF. " IF lwa_ztaxinc-ztitle EQ c_p

        WHEN 5.
* To determine if the sales organization company code has a VAT registration number in the supply plant country

          SELECT SINGLE bukrs land1 stceg  FROM t001n INTO (lv_t001ncc , lv_t001nco , lv_stcegt)
                                WHERE bukrs EQ  lv_zsocc
                                  AND land1 EQ lv_zdplco.
          IF sy-subrc NE 0.
            SELECT SINGLE bukrs land1 stceg  FROM t001 INTO (lv_t001ncc , lv_t001nco , lv_stcegt)
                                  WHERE bukrs EQ  lv_zsocc
                                    AND land1 EQ lv_zdplco.

          ENDIF. " IF sy-subrc NE 0

          SELECT SINGLE bukrs FROM tvko INTO lv_tvkocc
                        WHERE vkorg EQ im_vbak-vkorg.

          IF lv_t001ncc EQ lv_tvkocc AND lv_t001nco EQ lv_zdplco AND lv_stcegt IS NOT INITIAL.
            MOVE c_y TO lwa_vatprocess-zvatq05.
          ELSE. " ELSE -> IF lv_t001ncc EQ lv_tvkocc AND lv_t001nco EQ lv_zdplco AND lv_stcegt IS NOT INITIAL
            MOVE c_n TO lwa_vatprocess-zvatq05.
          ENDIF. " IF lv_t001ncc EQ lv_tvkocc AND lv_t001nco EQ lv_zdplco AND lv_stcegt IS NOT INITIAL
          IF lwa_vatprocess-zvatq05  NE c_y.
            IF lv_zsocc EQ lv_tvkocc AND lv_t001nco EQ lv_zdplco AND lv_stcegt IS NOT INITIAL.
              MOVE c_y TO lwa_vatprocess-zvatq05.
            ELSE. " ELSE -> IF lv_zsocc EQ lv_tvkocc AND lv_t001nco EQ lv_zdplco AND lv_stcegt IS NOT INITIAL
              MOVE c_n TO lwa_vatprocess-zvatq05.
            ENDIF. " IF lv_zsocc EQ lv_tvkocc AND lv_t001nco EQ lv_zdplco AND lv_stcegt IS NOT INITIAL
          ENDIF. " IF lwa_vatprocess-zvatq05 NE c_y

        WHEN 6.
          CLEAR : lv_t001ncc , lv_t001nco , lv_stcegt.
* To determine if the sales organization company code has a VAT registration number in the ship to country
          SELECT SINGLE bukrs land1 stceg  FROM t001n INTO (lv_t001ncc , lv_t001nco , lv_stcegt)
                                WHERE bukrs EQ  lv_zsocc
                                  AND land1 EQ lv_zshtco.
          IF sy-subrc NE 0.
            SELECT SINGLE bukrs land1 stceg  FROM t001 INTO (lv_t001ncc , lv_t001nco , lv_stcegt)
                                WHERE bukrs EQ  lv_zsocc
                                  AND land1 EQ lv_zshtco.

          ENDIF. " IF sy-subrc NE 0

          SELECT SINGLE bukrs FROM tvko INTO lv_tvkocc
                        WHERE vkorg EQ im_vbak-vkorg.

          IF lv_t001ncc EQ lv_tvkocc AND lv_t001nco EQ lv_zshtco AND lv_stcegt IS NOT INITIAL.
            MOVE c_y TO lwa_vatprocess-zvatq06.
          ELSE. " ELSE -> IF lv_t001ncc EQ lv_tvkocc AND lv_t001nco EQ lv_zshtco AND lv_stcegt IS NOT INITIAL
            MOVE c_n TO lwa_vatprocess-zvatq06.
          ENDIF. " IF lv_t001ncc EQ lv_tvkocc AND lv_t001nco EQ lv_zshtco AND lv_stcegt IS NOT INITIAL
          IF lwa_vatprocess-zvatq06  NE c_y.
            IF lv_zsocc EQ lv_tvkocc AND lv_t001nco EQ lv_zdplco AND lv_stcegt IS NOT INITIAL.
              MOVE c_y TO lwa_vatprocess-zvatq06.
            ELSE. " ELSE -> IF lv_zsocc EQ lv_tvkocc AND lv_t001nco EQ lv_zdplco AND lv_stcegt IS NOT INITIAL
              MOVE c_n TO lwa_vatprocess-zvatq06.
            ENDIF. " IF lv_zsocc EQ lv_tvkocc AND lv_t001nco EQ lv_zdplco AND lv_stcegt IS NOT INITIAL
          ENDIF. " IF lwa_vatprocess-zvatq06 NE c_y

        WHEN 7.
* To determine if the sold to has a registration in the ship to country
          CLEAR lwa_vbpa.
          READ TABLE it_vbpa INTO lwa_vbpa WITH KEY vbeln = im_vbap-vbeln
                                                    posnr = im_vbap-posnr
                                                    parvw = c_ag.
          IF sy-subrc NE 0.
            READ TABLE it_vbpa INTO lwa_vbpa WITH KEY vbeln = im_vbap-vbeln
                                                      parvw = c_ag.
          ENDIF. " IF sy-subrc NE 0
          IF lwa_vbpa-kunnr IS NOT INITIAL.

            SELECT SINGLE land1  FROM  kna1 INTO lv_land1
                              WHERE kunnr EQ lwa_vbpa-kunnr.
* Begin of Defect 2784
            SELECT SINGLE stceg  FROM  kna1 INTO lv_stceg
                               WHERE kunnr EQ lwa_vbpa-kunnr
                                 AND land1 EQ lv_zshtco.
* End of Defect 2784
            SELECT SINGLE stceg FROM knas INTO lv_stceg1
                                WHERE kunnr EQ lwa_vbpa-kunnr
                                  AND land1 EQ lv_zshtco.
            MOVE lv_land1 TO lv_soldtoc.
            IF lv_stceg IS NOT INITIAL OR lv_stceg1 IS NOT INITIAL.
              MOVE c_y TO lwa_vatprocess-zvatq07.
            ELSE. " ELSE -> IF lv_stceg IS NOT INITIAL OR lv_stceg1 IS NOT INITIAL
              MOVE c_n TO lwa_vatprocess-zvatq07.
            ENDIF. " IF lv_stceg IS NOT INITIAL OR lv_stceg1 IS NOT INITIAL
          ENDIF. " IF lwa_vbpa-kunnr IS NOT INITIAL
        WHEN 8.
* To determine if the sales order should be treated as a sale of services
* Begin of Change CR-216
          READ TABLE li_status  INTO lwa_status  WITH KEY criteria = lc_criteria
                                                          sel_low  = im_vbak-bsark
                                                            active   = abap_true.
          IF sy-subrc EQ 0.
*        IF im_vbak-auart EQ c_auart.
* End of Change CR-216
            MOVE c_y TO lwa_vatprocess-zvatq08.
          ELSE. " ELSE -> IF sy-subrc EQ 0
            MOVE c_n TO lwa_vatprocess-zvatq08.
          ENDIF. " IF sy-subrc EQ 0

        WHEN 9.
* To determine if a final destination country was entered in the order header as Tax Destination Country
          IF im_vbak-stceg_l IS NOT INITIAL.
            MOVE c_y TO lwa_vatprocess-zvatq09.
          ELSE. " ELSE -> IF im_vbak-stceg_l IS NOT INITIAL
            MOVE c_n TO lwa_vatprocess-zvatq09.
          ENDIF. " IF im_vbak-stceg_l IS NOT INITIAL
* Begin of CR 216
        WHEN 10.
* To determine if Payer is a taxable person
          CLEAR : lwa_vbpa , lv_land1 , lv_stceg , lv_stceg1.
          READ TABLE it_vbpa INTO lwa_vbpa WITH KEY vbeln = im_vbap-vbeln
                                                    posnr = im_vbap-posnr
                                                    parvw = c_ag.
          IF sy-subrc NE 0.
            READ TABLE it_vbpa INTO lwa_vbpa WITH KEY vbeln = im_vbap-vbeln
                                                      parvw = c_ag.
          ENDIF. " IF sy-subrc NE 0
          IF lwa_vbpa-kunnr IS NOT INITIAL.
            SELECT SINGLE land1 stceg FROM  kna1 INTO (lv_land1 , lv_stceg)
                              WHERE kunnr EQ lwa_vbpa-kunnr.
            SELECT SINGLE stceg FROM knas INTO lv_stceg1
                                WHERE kunnr EQ lwa_vbpa-kunnr
                                  AND land1 EQ lv_land1.
            IF lv_stceg IS NOT INITIAL OR lv_stceg1 IS NOT INITIAL.
              MOVE c_y TO lwa_vatprocess-zvatq10.
            ELSE. " ELSE -> IF lv_stceg IS NOT INITIAL OR lv_stceg1 IS NOT INITIAL
              MOVE c_n TO lwa_vatprocess-zvatq10.
            ENDIF. " IF lv_stceg IS NOT INITIAL OR lv_stceg1 IS NOT INITIAL
          ENDIF. " IF lwa_vbpa-kunnr IS NOT INITIAL
* End of CR 216
      ENDCASE.
    ENDDO.
* Based on the Answers derived from the above questions
* make a query on TAX FLOW table to fill the reporting country & Destination country
    SELECT SINGLE * FROM zvatproces INTO lwa_vatprocessa
                        WHERE zvatq01 EQ lwa_vatprocess-zvatq01
                          AND zvatq02 EQ lwa_vatprocess-zvatq02
                          AND zvatq03 EQ lwa_vatprocess-zvatq03
                          AND zvatq04 EQ lwa_vatprocess-zvatq04
                          AND zvatq05 EQ lwa_vatprocess-zvatq05
                          AND zvatq06 EQ lwa_vatprocess-zvatq06
                          AND zvatq07 EQ lwa_vatprocess-zvatq07
                          AND zvatq08 EQ lwa_vatprocess-zvatq08
                          AND zvatq09 EQ lwa_vatprocess-zvatq09
                          AND zvatq10 EQ lwa_vatprocess-zvatq10.
* Based on the Answers we derived from the 9 questions if we dont find an
* entry in Tax Flow table then build a logic to replace the spaces
    IF  sy-subrc NE 0.

* Get all the Values from taxflow table into an Internal table.
      SELECT * FROM zvatproces INTO TABLE lt_vatprocess.
* Loop through the Internal table to find exact match for Vat Process Flow
      LOOP AT lt_vatprocess INTO lwa_process_tmp.
        MOVE-CORRESPONDING lwa_vatprocess TO lwa_vatprocessa1.
* Check each of the 10 questions if it matches the Vat Flow Answers.
        DO 10 TIMES.
          lv_index = sy-index.
          IF lv_index <= 9.
            CONCATENATE c_sourcequer lv_index INTO lv_field.
            CONCATENATE c_destquesr  lv_index INTO lv_field1.
          ELSE. " ELSE -> IF lv_index <= 9
            CONCATENATE c_sourcequer1 lv_index INTO lv_field.
            CONCATENATE c_destquesr1  lv_index INTO lv_field1.
          ENDIF. " IF lv_index <= 9
          ASSIGN (lv_field)  TO <fsvalue>.
          ASSIGN (lv_field1) TO <fsvalue1>.
          IF <fsvalue> = abap_true. " AND <fsvalue1> EQ c_n.
            CASE lv_index.
              WHEN 1.
                MOVE <fsvalue> TO lwa_vatprocessa1-zvatq01.
              WHEN 2.
                MOVE <fsvalue> TO lwa_vatprocessa1-zvatq02.
              WHEN 3.
                MOVE <fsvalue> TO lwa_vatprocessa1-zvatq03.
              WHEN 4.
                MOVE <fsvalue> TO lwa_vatprocessa1-zvatq04.
              WHEN 5.
                MOVE <fsvalue> TO lwa_vatprocessa1-zvatq05.
              WHEN 6.
                MOVE <fsvalue> TO lwa_vatprocessa1-zvatq06.
              WHEN 7.
                MOVE <fsvalue> TO lwa_vatprocessa1-zvatq07.
              WHEN 8.
                MOVE <fsvalue> TO lwa_vatprocessa1-zvatq08.
              WHEN 9.
                MOVE <fsvalue> TO lwa_vatprocessa1-zvatq09.
              WHEN 10.
                MOVE <fsvalue> TO lwa_vatprocessa1-zvatq10.
            ENDCASE.
          ENDIF. " IF <fsvalue> = abap_true
        ENDDO.
* Read the Internal table with the derived answers from the VATFLOW Table
        READ TABLE lt_vatprocess INTO lwa_vatprocessa  WITH KEY zvatq01 =  lwa_vatprocessa1-zvatq01
                                                                zvatq02 =  lwa_vatprocessa1-zvatq02
                                                                zvatq03 =  lwa_vatprocessa1-zvatq03
                                                                zvatq04 =  lwa_vatprocessa1-zvatq04
                                                                zvatq05 =  lwa_vatprocessa1-zvatq05
                                                                zvatq06 =  lwa_vatprocessa1-zvatq06
                                                                zvatq07 =  lwa_vatprocessa1-zvatq07
                                                                zvatq08 =  lwa_vatprocessa1-zvatq08
                                                                zvatq09 =  lwa_vatprocessa1-zvatq09
                                                                zvatq10 =  lwa_vatprocessa1-zvatq10.
        IF sy-subrc EQ 0.
* Once we find the Exact match exit from the Loop.
          EXIT.
        ENDIF. " IF sy-subrc EQ 0
      ENDLOOP. " LOOP AT lt_vatprocess INTO lwa_process_tmp
    ENDIF. " IF sy-subrc NE 0

* Check if we found an exact match for the VAT Process Flow.
    IF lwa_vatprocessa IS NOT INITIAL.
      MOVE-CORRESPONDING im_vbap TO chng_vbap.

* Populate Tax reporting country Trade
      IF lwa_vatprocessa-zzrland EQ 0.
        MOVE space TO chng_vbap-zzrland.
      ENDIF. " IF lwa_vatprocessa-zzrland EQ 0
      IF lwa_vatprocessa-zzrland EQ 1.
        MOVE lv_zdplco TO chng_vbap-zzrland.
      ENDIF. " IF lwa_vatprocessa-zzrland EQ 1
      IF lwa_vatprocessa-zzrland EQ 2.
        MOVE lv_zsoco TO chng_vbap-zzrland.
      ENDIF. " IF lwa_vatprocessa-zzrland EQ 2
* Begin of Defect - 10175
      IF lwa_vatprocessa-zzrland EQ 3.
        MOVE lv_zshtco TO chng_vbap-zzrland.
      ENDIF. " IF lwa_vatprocessa-zzrland EQ 3
* End of Defect - 10175

* Populate Intercompany Reporting Country
      IF lwa_vatprocessa-zzrlandic EQ 0.
        MOVE space TO chng_vbap-zzrlandic.
      ENDIF. " IF lwa_vatprocessa-zzrlandic EQ 0
      IF lwa_vatprocessa-zzrlandic EQ 1.
        MOVE lv_zdplco TO chng_vbap-zzrlandic.
      ENDIF. " IF lwa_vatprocessa-zzrlandic EQ 1
      IF lwa_vatprocessa-zzrlandic EQ 2.
        MOVE lv_zsoco TO chng_vbap-zzrlandic.
      ENDIF. " IF lwa_vatprocessa-zzrlandic EQ 2
* Begin of Defect - 10175
      IF lwa_vatprocessa-zzrlandic EQ 3.
        MOVE lv_zshtco TO chng_vbap-zzrlandic.
      ENDIF. " IF lwa_vatprocessa-zzrlandic EQ 3
* End of Defect - 10175

* Populate Intercompany Destination Country
      IF lwa_vatprocessa-zzdlandic EQ 0.
        MOVE space TO chng_vbap-zzdlandic.
      ENDIF. " IF lwa_vatprocessa-zzdlandic EQ 0
      IF lwa_vatprocessa-zzdlandic EQ 1.
        MOVE lv_zdplco TO chng_vbap-zzdlandic.
      ENDIF. " IF lwa_vatprocessa-zzdlandic EQ 1
      IF lwa_vatprocessa-zzdlandic EQ 2.
        MOVE lv_zsoco TO chng_vbap-zzdlandic.
      ENDIF. " IF lwa_vatprocessa-zzdlandic EQ 2
* Begin of Defect - 10175
      IF lwa_vatprocessa-zzdlandic EQ 3.
        MOVE lv_zshtco TO chng_vbap-zzdlandic.
      ENDIF. " IF lwa_vatprocessa-zzdlandic EQ 3
      IF lwa_vatprocessa-zzdlandic EQ 4.
        MOVE lv_soldtoc TO chng_vbap-zzdlandic.
      ENDIF. " IF lwa_vatprocessa-zzdlandic EQ 4
      IF lwa_vatprocessa-zzdlandic EQ 5.
        MOVE im_vbak-stceg_l TO chng_vbap-zzdlandic.
      ENDIF. " IF lwa_vatprocessa-zzdlandic EQ 5
* Begin of Defect - 10175
      IF lwa_vatprocessa-zzdlandic EQ 6.
        MOVE lv_zshtco TO chng_vbap-zzdlandic.
      ENDIF. " IF lwa_vatprocessa-zzdlandic EQ 6
* End of Defect - 10175
* End of Defect - 10175


* Populate Destination Country trade
      IF lwa_vatprocessa-zzdland EQ 0.
        MOVE space TO chng_vbap-zzdland.
      ENDIF. " IF lwa_vatprocessa-zzdland EQ 0
      IF lwa_vatprocessa-zzdland EQ 1.
        MOVE lv_zdplco TO chng_vbap-zzdland.
      ENDIF. " IF lwa_vatprocessa-zzdland EQ 1
      IF lwa_vatprocessa-zzdland EQ 2.
        MOVE lv_zsoco TO chng_vbap-zzdland.
      ENDIF. " IF lwa_vatprocessa-zzdland EQ 2
      IF lwa_vatprocessa-zzdland EQ 3.
        MOVE lv_zshtco TO chng_vbap-zzdland.
      ENDIF. " IF lwa_vatprocessa-zzdland EQ 3
      IF lwa_vatprocessa-zzdland EQ 4.
        MOVE lv_soldtoc TO chng_vbap-zzdland.
      ENDIF. " IF lwa_vatprocessa-zzdland EQ 4
      IF lwa_vatprocessa-zzdland EQ 5.
        MOVE im_vbak-stceg_l TO chng_vbap-zzdland.
      ENDIF. " IF lwa_vatprocessa-zzdland EQ 5
* Begin of Defect - 10175
      IF lwa_vatprocessa-zzdland EQ 6.
        MOVE lv_zshtco TO chng_vbap-zzdland.
      ENDIF. " IF lwa_vatprocessa-zzdland EQ 6
* End of Defect - 10175

    ENDIF. " IF lwa_vatprocessa IS NOT INITIAL
* Begin of CR 216

    IF chng_vbap-zzrland EQ c_mc.
      MOVE c_fr TO chng_vbap-zzrland.
    ENDIF. " IF chng_vbap-zzrland EQ c_mc
    IF chng_vbap-zzdland EQ c_mc.
      MOVE c_fr TO chng_vbap-zzdland.
    ENDIF. " IF chng_vbap-zzdland EQ c_mc
* End of CR 216
* Begin of Defect 2941
* Begin of Defect 2895
*    READ TABLE li_status  INTO lwa_status  WITH KEY criteria = lc_flip
*                                                    sel_low   = chng_vbap-zzrland.
*    IF sy-subrc EQ 0.
*      MOVE lwa_status-sel_high TO chng_vbap-zzrland.
*    ENDIF. " IF sy-subrc EQ 0
*
*    READ TABLE li_status  INTO lwa_status  WITH KEY criteria = lc_flip
*                                                    sel_low   = chng_vbap-zzdland.
*    IF sy-subrc EQ 0.
*      MOVE lwa_status-sel_high TO chng_vbap-zzdland.
*    ENDIF. " IF sy-subrc EQ 0
* End of Defect 2895
* End of Defect 2941
    IF lwa_vatprocessa-zvatflow IS NOT INITIAL.
      MOVE lwa_vatprocessa-zvatflow TO chng_vbap-zzvatflow.
    ENDIF. " IF lwa_vatprocessa-zvatflow IS NOT INITIAL
  ENDIF. " IF sy-subrc EQ 0
ENDFUNCTION.
