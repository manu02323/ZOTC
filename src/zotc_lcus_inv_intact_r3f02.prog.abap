*----------------------------------------------------------------------*
***INCLUDE /SAPSLL/LCUS_INV_INTACT_R3F02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  result_table_fill
*&---------------------------------------------------------------------*
*       Aufbau der Ergebnistabelle
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Modification History:                                                *
*======================================================================*
* Date        User      Transport  Description                         *
* =========== ========  ========== ====================================*
* 16-Aug-2018  MTHATHA  E1DK937760 INITIAL DEVELOPMENT                 *
* 19-Nov-2018  U033632  E1DK939349 SCTASK0753994:1.Code added to create*
*                                  proforma invoice for ZDF8 billing   *
*                                  type                                *
*17-Dec-2018 U033632    E1DK939349 Defect#7847/SCTASK0753994:1. Removed*
*                                  EXPKZ check from selection of LIKP  *
*                                  table.                              *
*                                  2.Fixed issue of duplicate invoices *
*                                  3.Changed the text Proforma CI for  *
*                                  Sales BOM"  to "Customer Proforma   *
*                                  for HU Level CI" on sel screen      *
*                                  4.Changed delivery type to multiple *
*                                   selection                          *
*03-Feb-2019 MTHATHA    E1DK940386 D#8283 Add Sales org,Shipping point *
*----------------------------------------------------------------------*
FORM result_table_fill  USING    it_likp    TYPE /sapsll/likp_r3_t
                                 it_lips    TYPE /sapsll/lips_r3_t
                                 it_vttk    TYPE vttk_tab
                                 it_vttp    TYPE vttp_tab
                                 it_vbpa    TYPE tab_vbpa
                                 it_eikp    TYPE /sapsll/eikp_r3_t
                        CHANGING ct_cus_inv TYPE /sapsll/cus_inv_r3_t.
  DATA: ls_lips      TYPE lips. " SD document: Delivery: Item data
  DATA: ls_vttp      TYPE vttp. " Shipment Item
  DATA: ls_vttk      TYPE vttk. " Shipment Header
  DATA: ls_likp      TYPE likp. " SD Document: Delivery Header Data
  DATA: ls_eikp      TYPE eikp. " Foreign Trade: Export/Import Header Data
  DATA: ls_vbpa      TYPE vbpa. " Sales Document: Partner
  DATA: ls_cus_inv   TYPE /sapsll/cus_inv_r3_s. " GTS: Shipment Consolidation
*-- Positionsweiser Aufbau der Ergebnisanzeige
  LOOP AT it_lips INTO ls_lips.
    READ TABLE it_likp WITH KEY vbeln = ls_lips-vbeln
     INTO ls_likp.
    IF sy-subrc <> 0.
      MESSAGE x115.
    ENDIF. " IF sy-subrc <> 0
    ls_cus_inv-vbeln = ls_lips-vbeln.
    ls_cus_inv-posnr = ls_lips-posnr.
    ls_cus_inv-vtweg = ls_lips-vtweg.
    ls_cus_inv-spart = ls_lips-spart.
    ls_cus_inv-werks = ls_lips-werks.
    ls_cus_inv-lfimg = ls_lips-lfimg.
    ls_cus_inv-vrkme = ls_lips-vrkme.
    ls_cus_inv-matnr = ls_lips-matnr.
    ls_cus_inv-pstyv = ls_lips-pstyv.
    ls_cus_inv-grkor = ls_lips-grkor.
    ls_cus_inv-wenr  = ls_likp-kunnr.
    ls_cus_inv-kunag = ls_likp-kunag.
    ls_cus_inv-wadat = ls_likp-wadat.
    ls_cus_inv-fkdat = ls_likp-wadat.
    ls_cus_inv-vkorg = ls_likp-vkorg.
    ls_cus_inv-vsbed = ls_likp-vsbed.
    ls_cus_inv-inco1 = ls_likp-inco1.
    ls_cus_inv-route = ls_likp-route.
    ls_cus_inv-vstel = ls_likp-vstel.
    ls_cus_inv-lstel = ls_likp-lstel.
    ls_cus_inv-lgtor = ls_likp-lgtor.
    ls_cus_inv-vbtyp = ls_likp-vbtyp.
    ls_cus_inv-lfart = ls_likp-lfart.
*-- Transportbezogene Daten
    READ TABLE it_vttp WITH KEY vbeln = ls_lips-vbeln
      INTO ls_vttp.
    IF sy-subrc = 0.
      ls_cus_inv-tknum  = ls_vttp-tknum.
      READ TABLE it_vttk WITH KEY tknum = ls_vttp-tknum
       INTO ls_vttk.
      IF sy-subrc = 0.
        ls_cus_inv-vsart = ls_vttk-vsart.
        ls_cus_inv-spnrt = ls_vttk-tdlnr.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0
    READ TABLE it_vbpa WITH KEY vbeln = ls_vttk-tknum
                                parvw = 'SP'
         INTO ls_vbpa.
    IF sy-subrc = 0.
      ls_cus_inv-spnrt = ls_vbpa-lifnr.
    ENDIF. " IF sy-subrc = 0
*-- Spediteur der Liferungs
    CLEAR ls_vbpa.
    READ TABLE it_vbpa WITH KEY vbeln = ls_likp-vbeln
                                parvw = 'SP'
         INTO ls_vbpa.
    IF sy-subrc = 0.
      ls_cus_inv-spnrl = ls_vbpa-lifnr.
    ENDIF. " IF sy-subrc = 0
*-- Land des Warenempfängers
    READ TABLE it_vbpa WITH KEY vbeln = ls_likp-vbeln
                                kunnr = ls_likp-kunnr
         INTO ls_vbpa.
    IF sy-subrc = 0.
      ls_cus_inv-land1 = ls_vbpa-land1.
    ENDIF. " IF sy-subrc = 0
*-- Außenhandelsdaten
    READ TABLE it_eikp WITH KEY exnum = ls_likp-exnum
       INTO ls_eikp.
    IF sy-subrc = 0.
      ls_cus_inv-kzabe = ls_eikp-kzabe.
      ls_cus_inv-kzgbe = ls_eikp-kzgbe.
    ENDIF. " IF sy-subrc = 0
    APPEND ls_cus_inv TO ct_cus_inv.
    CLEAR ls_likp.
    CLEAR ls_vbpa.
    CLEAR ls_vttp.
    CLEAR ls_vttk.
    CLEAR ls_eikp.
    CLEAR ls_cus_inv.
  ENDLOOP. " LOOP AT it_lips INTO ls_lips
ENDFORM. " result_table_fill
*&---------------------------------------------------------------------*
*&      Form  shipment_tables_select
*&---------------------------------------------------------------------*
*       Tabellen zur Sendungsbildung selektieren
*----------------------------------------------------------------------*
FORM shipment_tables_select
        USING    is_crit TYPE /sapsll/cus_inv_crit_r3_s " GTS: Shipment Consolidation Selection Criteria
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
*                 iv_lfart TYPE lfart                    " Delivery Type
*End of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
                 fp_im_lfart TYPE /isdfps/rg_t_lfart " Delivery type
*End of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
                 ir_agmdat TYPE /sapsll/wadat_r_t
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
                 fp_im_erdat TYPE /sapsll/erdat_r3_r_t " Creatin date
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
                             CHANGING ct_likp TYPE /sapsll/likp_r3_t
                                      ct_lips TYPE /sapsll/lips_r3_t
                                      ct_vttk TYPE vttk_tab
                                      ct_vttp TYPE vttp_tab
                                      ct_vbpa TYPE tab_vbpa
                                      ct_eikp TYPE /sapsll/eikp_r3_t.
  DATA: lr_vbeln       TYPE /sapsll/vbeln_r3_r_t.
*Begin of insert for D3_OTC_EDD_0414 D#8283 by mthatha
*  DATA: lr_exnum       TYPE /sapsll/exnum_r3_r_t.
  DATA: lr_exnum       TYPE  zotc_exnum_r3_r_t.
*End of insert for D3_OTC_EDD_0414 D#8283 by mthatha
  DATA: lr_vbeln_del   TYPE /sapsll/vbeln_r3_r_t.
  DATA: lr_expkz       TYPE /sapsll/expkz_r3_r_t.
  DATA: ls_vbeln       TYPE /sapsll/vbeln_r3_r_s. " Range Structure for Data Element /SAPSLL/VBELN_R3
  DATA: ls_exnum       TYPE /sapsll/exnum_r3_r_s. " Number of Foreign Trade Data
  DATA: ls_expkz       TYPE /sapsll/expkz_r3_r_s. " Export ID
  DATA: lt_vbpa_t      TYPE tab_vbpa.
  DATA: lt_vbpa_l      TYPE tab_vbpa.
  DATA: ls_eikp        TYPE eikp. " Foreign Trade: Export/Import Header Data
  DATA: ls_vttp        TYPE vttp. " Shipment Item
  DATA: ls_likp        TYPE likp. " SD Document: Delivery Header Data
  DATA: ls_lips        TYPE lips. "#EC NEEDED
  DATA: lv_wide_select TYPE xfeld. " Checkbox
*-- Exportkennzeichen zur Selektion vorbeiten
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
*The check for expkz is not required for selection of data from LIKP as confirmed with functional
*  ls_expkz-sign   = 'I'.
*  ls_expkz-option = 'EQ'.
*  ls_expkz-low    = 'X'.
*  APPEND ls_expkz TO lr_expkz.
*  ls_expkz-low  = 'Y'.
*  APPEND ls_expkz TO lr_expkz.
*  ls_expkz-low  = 'Z'.
*  APPEND ls_expkz TO lr_expkz.
*End of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
*-- Selektion mit leerem Selektionsbildschirm
  IF is_crit-kzabe IS INITIAL AND
     is_crit-kzgbe IS INITIAL AND
     is_crit-vbeln IS INITIAL AND
     is_crit-vkorg IS INITIAL AND
     is_crit-vstel IS INITIAL AND
     is_crit-vsbed IS INITIAL AND
     is_crit-inco1 IS INITIAL AND
     is_crit-grkor IS INITIAL AND
     is_crit-wadat IS INITIAL AND
*--BEGIN OF CHANGES Manoj
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
*     iv_lfart      IS INITIAL AND
*End of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
     fp_im_lfart IS INITIAL AND
*End of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
     ir_agmdat     IS INITIAL AND
*--End of Changes Manoj
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
     fp_im_erdat IS INITIAL AND
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
     is_crit-kunnr IS INITIAL AND
     is_crit-land  IS INITIAL AND
     is_crit-spedl IS INITIAL AND
     is_crit-tknum IS INITIAL AND
     is_crit-route IS INITIAL AND
     is_crit-vsart IS INITIAL AND
     is_crit-spedt IS INITIAL AND
     is_crit-lstel IS INITIAL AND
     is_crit-lgtor IS INITIAL.
    lv_wide_select = gc_true.
  ENDIF. " IF is_crit-kzabe IS INITIAL AND
*-- Selektionskriterium Lieferungsnummer oder
*-- komplett leerer Selektionsbildschirm
  IF NOT is_crit-vbeln IS INITIAL OR
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Checking if creation date is not initial
    fp_im_erdat IS NOT INITIAL OR
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
         lv_wide_select = gc_true.
    SELECT * FROM likp INTO TABLE ct_likp
      WHERE vbeln IN is_crit-vbeln
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
      AND erdat IN fp_im_erdat
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 D#8283 by mthatha
      AND vstel IN is_crit-vstel
      AND vkorg IN is_crit-vkorg
*End of insert for D3_OTC_EDD_0414 D#8283 by mthatha
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
      AND lfart IN fp_im_lfart " Delivery type
*End of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
*This check is not required as confirmed with functional team
*        AND expkz IN lr_expkz
*End of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
        AND vbtyp = 'J'.
    IF sy-subrc <> 0.
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*In case of batch job scheduled and if message 'no data found' is triggered then status
*of batch job will be cancelled.To avoid this and make the status of batch job as finished we have modified the message
*      MESSAGE i110 RAISING no_data.
*End of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
      MESSAGE i110 DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
    ENDIF. " IF sy-subrc <> 0
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Replacing standard subroutine with customized  to add some new code as per requirement
*    PERFORM likp_complete_filter CHANGING ct_likp
*    lr_vbeln
*    lr_exnum.
*End of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
    PERFORM f_likp_complete_filter CHANGING   ct_likp
                                              lr_vbeln
                                              lr_exnum.
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
    IF ct_likp IS INITIAL.
      "      IF sy-subrc <> 0.
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*In case of batch job scheduled and if message 'no data found' is triggered then status
*of batch job will be cancelled.To avoid this and make the status of batch job as finished we have modified the message
*      MESSAGE i110 RAISING no_data.
*End of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
      MESSAGE i110 DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
           "      ENDIF.
    ENDIF. " IF ct_likp IS INITIAL
  ENDIF. " IF NOT is_crit-vbeln IS INITIAL OR
*-- Selektionskriterien des Transports
  IF NOT is_crit-tknum IS INITIAL OR
     NOT is_crit-vsart IS INITIAL OR
     NOT is_crit-spedt IS INITIAL.
    IF NOT is_crit-vsart IS INITIAL OR
       NOT is_crit-spedt IS INITIAL.
      SELECT * FROM vttk INTO TABLE ct_vttk
        WHERE tknum IN is_crit-tknum
          AND vsart IN is_crit-vsart
          AND tdlnr IN is_crit-spedt.
      IF sy-subrc <> 0.
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*In case of batch job scheduled and if message 'no data found' is triggered then status
*of batch job will be cancelled.To avoid this and make the status of batch job as finished we have modified the message
*      MESSAGE i110 RAISING no_data.
*End of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
        MESSAGE i110 DISPLAY LIKE 'E'.
        LEAVE LIST-PROCESSING.
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
      ENDIF. " IF sy-subrc <> 0
      SELECT * FROM vttp INTO TABLE ct_vttp
        FOR ALL ENTRIES IN ct_vttk
        WHERE tknum = ct_vttk-tknum.
 "AND vbeln IN lr_vbeln.
      IF NOT lr_vbeln IS INITIAL.
        DELETE ct_vttp WHERE NOT vbeln IN lr_vbeln.
      ENDIF. " IF NOT lr_vbeln IS INITIAL
      IF lines( ct_vttp ) = 0.
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*In case of batch job scheduled and if message 'no data found' is triggered then status
*of batch job will be cancelled.To avoid this and make the status of batch job as finished we have modified the message
*      MESSAGE i110 RAISING no_data.
*End of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
        MESSAGE i110 DISPLAY LIKE 'E'.
        LEAVE LIST-PROCESSING.
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
      ENDIF. " IF lines( ct_vttp ) = 0
    ELSE. " ELSE -> IF NOT is_crit-vsart IS INITIAL OR
      SELECT * FROM vttp INTO TABLE ct_vttp
       WHERE tknum IN is_crit-tknum.
 "AND vbeln IN lr_vbeln.
      IF NOT lr_vbeln IS INITIAL.
        DELETE ct_vttp WHERE NOT vbeln IN lr_vbeln.
      ENDIF. " IF NOT lr_vbeln IS INITIAL
      IF lines( ct_vttp ) = 0.
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*        MESSAGE i110 RAISING no_data.
*End of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
        MESSAGE i110 DISPLAY LIKE 'E'.
        LEAVE LIST-PROCESSING.
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
      ENDIF. " IF lines( ct_vttp ) = 0
    ENDIF. " IF NOT is_crit-vsart IS INITIAL OR
*-- Zutreffende Lieferungsnummer weiter einengen bzw. aufbauen
    CLEAR lr_vbeln.
    LOOP AT ct_vttp INTO ls_vttp.
      READ TABLE lr_vbeln WITH KEY low = ls_vttp-vbeln
       TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF. " IF sy-subrc = 0
      ls_vbeln-sign   = 'I'.
      ls_vbeln-option = 'EQ'.
      ls_vbeln-low    = ls_vttp-vbeln.
      APPEND ls_vbeln TO lr_vbeln.
    ENDLOOP. " LOOP AT ct_vttp INTO ls_vttp
  ENDIF. " IF NOT is_crit-tknum IS INITIAL OR
  IF NOT is_crit-kzabe IS INITIAL OR
     NOT is_crit-kzgbe IS INITIAL.
    SELECT * FROM eikp INTO TABLE ct_eikp
      WHERE exnum IN lr_exnum
        AND kzabe = is_crit-kzabe
        AND kzgbe = is_crit-kzgbe.
    IF sy-subrc <> 0.
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*      MESSAGE i110 RAISING no_data.
*End of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
      MESSAGE i110 DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
    ELSE. " ELSE -> IF sy-subrc <> 0
      LOOP AT ct_eikp INTO ls_eikp.
        ls_exnum-sign   = 'I'.
        ls_exnum-option = 'EQ'.
        ls_exnum-low    = ls_eikp-exnum.
        APPEND ls_exnum TO lr_exnum.
      ENDLOOP. " LOOP AT ct_eikp INTO ls_eikp
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF NOT is_crit-kzabe IS INITIAL OR
*-- Mindestens eins der Lieferungs-Kriterien muss hier gefüllt sein
  IF NOT is_crit-vkorg IS INITIAL OR
     NOT is_crit-vstel IS INITIAL OR
     NOT is_crit-vsbed IS INITIAL OR
     NOT is_crit-inco1 IS INITIAL OR
     NOT is_crit-wadat IS INITIAL OR
     NOT is_crit-kunnr IS INITIAL OR
     NOT is_crit-route IS INITIAL OR
     NOT is_crit-lstel IS INITIAL OR
     NOT is_crit-lgtor IS INITIAL OR
     NOT is_crit-grkor IS INITIAL OR
     NOT is_crit-land  IS INITIAL OR
     NOT lr_vbeln IS INITIAL      OR
     NOT lr_exnum IS INITIAL.
*----------------------------------------------------
* Liefergruppe als einziges LIPS-Kriterium vorziehen
*----------------------------------------------------
    IF NOT is_crit-grkor IS INITIAL.
      IF lines( lr_vbeln ) = 0.
        SELECT * FROM lips INTO TABLE ct_lips
            WHERE grkor IN is_crit-grkor. "#EC CI_NOFIELD
      ELSE. " ELSE -> IF lines( lr_vbeln ) = 0
        SELECT * FROM lips INTO TABLE ct_lips
          FOR ALL ENTRIES IN lr_vbeln
          WHERE vbeln = lr_vbeln-low
            AND grkor IN is_crit-grkor.
      ENDIF. " IF lines( lr_vbeln ) = 0
      IF lr_vbeln IS INITIAL.
        LOOP AT ct_lips INTO ls_lips.
          ls_vbeln-sign   = 'I'.
          ls_vbeln-option = 'EQ'.
          ls_vbeln-low    = ls_likp-vbeln.
          APPEND ls_vbeln TO lr_vbeln.
        ENDLOOP. " LOOP AT ct_lips INTO ls_lips
      ELSE. " ELSE -> IF lr_vbeln IS INITIAL
        LOOP AT lr_vbeln INTO ls_vbeln.
          READ TABLE ct_lips WITH KEY ls_vbeln-low
            TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0.
            APPEND ls_vbeln TO lr_vbeln_del.
          ENDIF. " IF sy-subrc <> 0
        ENDLOOP. " LOOP AT lr_vbeln INTO ls_vbeln
        IF NOT lr_vbeln_del IS INITIAL.
          DELETE lr_vbeln WHERE low IN lr_vbeln_del.
        ENDIF. " IF NOT lr_vbeln_del IS INITIAL
      ENDIF. " IF lr_vbeln IS INITIAL
    ENDIF. " IF NOT is_crit-grkor IS INITIAL
*-------------------------------------
* Lieferkopf-Kriterien außer VBELN
*-------------------------------------
    IF lv_wide_select = gc_false.
      CLEAR ct_likp. " ist gewollt, da vorige Eingrenzung über lr_vbeln
      IF NOT is_crit-inco1 IS INITIAL.
        IF NOT lr_vbeln IS INITIAL.
          SELECT * FROM likp INTO TABLE ct_likp
            FOR ALL ENTRIES IN lr_vbeln
            WHERE vbeln = lr_vbeln-low
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
              AND erdat IN fp_im_erdat
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
              AND vkorg IN is_crit-vkorg
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
              AND lfart IN fp_im_lfart " Delivery type
*End of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
              AND vstel IN is_crit-vstel
              AND vsbed IN is_crit-vsbed
              AND inco1 = is_crit-inco1
              AND wadat IN is_crit-wadat
              AND kunnr IN is_crit-kunnr
              AND route IN is_crit-route
              AND lstel IN is_crit-lstel
              AND lgtor IN is_crit-lgtor
 "         AND vbeln IN lr_vbeln
              AND exnum IN lr_exnum
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
*This check is not required as confirmed with functional team
*              AND expkz IN lr_expkz
*End of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
              AND vbtyp = 'J'.
        ELSE. " ELSE -> IF NOT lr_vbeln IS INITIAL
          SELECT * FROM likp INTO TABLE ct_likp
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
            WHERE erdat IN fp_im_erdat
*end of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*            WHERE vkorg IN is_crit-vkorg
*End of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
**Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
            AND vkorg IN is_crit-vkorg
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
*As delivery type is changed from single to multiple selection
*--BEGIN OF CHANGES MANOJ
*              AND lfart = iv_lfart
*--END OF CHANGES MANOJ
*End of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
              AND lfart IN fp_im_lfart
*End of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
              AND vstel IN is_crit-vstel
              AND vsbed IN is_crit-vsbed
              AND inco1 = is_crit-inco1
              AND wadat IN is_crit-wadat
              AND kunnr IN is_crit-kunnr
              AND route IN is_crit-route
              AND lstel IN is_crit-lstel
*--BEGIN OF CHANGES MANOJ
              AND wadat_ist IN ir_agmdat
*--END OF CHANGES MANOJ
              AND lgtor IN is_crit-lgtor
              AND exnum IN lr_exnum
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
*This check is not required as confirmed with functional
*              AND expkz IN lr_expkz
*End of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
              AND vbtyp = 'J'. "#EC CI_NOFIELD
        ENDIF. " IF NOT lr_vbeln IS INITIAL
      ELSE. " ELSE -> IF NOT is_crit-inco1 IS INITIAL
        IF NOT lr_vbeln IS INITIAL.
          SELECT * FROM likp INTO TABLE ct_likp
            FOR ALL ENTRIES IN lr_vbeln
            WHERE vbeln = lr_vbeln-low
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
              AND erdat IN fp_im_erdat
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
              AND vkorg IN is_crit-vkorg
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
              AND lfart IN fp_im_lfart " Delivery type
*End of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
              AND vstel IN is_crit-vstel
              AND vsbed IN is_crit-vsbed
              AND wadat IN is_crit-wadat
              AND kunnr IN is_crit-kunnr
              AND route IN is_crit-route
              AND lstel IN is_crit-lstel
              AND lgtor IN is_crit-lgtor
*             AND vbeln IN lr_vbeln
              AND exnum IN lr_exnum
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
*              AND expkz IN lr_expkz
*End of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
              AND vbtyp = 'J'. "#EC CI_NOFIELD
        ELSE. " ELSE -> IF NOT lr_vbeln IS INITIAL
          SELECT * FROM likp INTO TABLE ct_likp
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
            WHERE erdat IN fp_im_erdat
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*            WHERE vkorg IN is_crit-vkorg
*End of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
            AND vkorg IN is_crit-vkorg
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
*As delivery type is changed from single to multiple selection
*--BEGIN OF CHANGES MANOJ
*              AND lfart = iv_lfart
*--END OF CHANGES MANOJ
*End of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
             AND lfart IN fp_im_lfart " Delivery type
*End of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
              AND vstel IN is_crit-vstel
              AND vsbed IN is_crit-vsbed
              AND wadat IN is_crit-wadat
              AND kunnr IN is_crit-kunnr
              AND route IN is_crit-route
              AND lstel IN is_crit-lstel
*--BEGIN OF CHANGES MANOJ
              AND wadat_ist IN ir_agmdat
*--END OF CHANGES MANOJ
              AND lgtor IN is_crit-lgtor
              AND exnum IN lr_exnum
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
*This check is not required as confirmed with functional team
*              AND expkz IN lr_expkz
*End of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
              AND vbtyp = 'J'. "#EC CI_NOFIELD
        ENDIF. " IF NOT lr_vbeln IS INITIAL
      ENDIF. " IF NOT is_crit-inco1 IS INITIAL
      IF ct_likp IS INITIAL.
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*        MESSAGE i110 RAISING no_data.
*End of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
        MESSAGE i110 DISPLAY LIKE 'E'.
        LEAVE LIST-PROCESSING.
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
      ENDIF. " IF ct_likp IS INITIAL

*-- Erledigte Ausfiltern
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*      PERFORM likp_complete_filter CHANGING ct_likp
*                                            lr_vbeln
*                                            lr_exnum.
*End of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
      PERFORM f_likp_complete_filter  CHANGING ct_likp
                                              lr_vbeln
                                             lr_exnum.
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
      IF ct_likp IS INITIAL.
*Begin of  delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*        MESSAGE i110 RAISING no_data..
*End delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
        MESSAGE i110 DISPLAY LIKE 'E'.
        LEAVE LIST-PROCESSING.
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
      ENDIF. " IF ct_likp IS INITIAL
    ENDIF. " IF lv_wide_select = gc_false
*--------------------------
* Land des Warenempängers
*--------------------------
    IF NOT is_crit-land IS INITIAL.
      SELECT * FROM vbpa " Sales Document: Partner
        INTO TABLE ct_vbpa
        FOR ALL ENTRIES IN ct_likp
        WHERE vbeln = ct_likp-vbeln
          AND parvw = 'WE'
          AND kunnr = ct_likp-kunnr
          AND land1 IN is_crit-land.
      IF sy-subrc <> 0.
*Begin of  delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*        MESSAGE i110 RAISING no_data.
*End of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
        MESSAGE i110 DISPLAY LIKE 'E'.
        LEAVE LIST-PROCESSING.
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
      ELSE. " ELSE -> IF sy-subrc <> 0
        LOOP AT ct_likp INTO ls_likp.
          READ TABLE ct_vbpa WITH KEY vbeln = ls_likp-vbeln
          TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0.
            ls_vbeln-sign   = 'I'.
            ls_vbeln-option = 'EQ'.
            ls_vbeln-low    = ls_likp-vbeln.
            APPEND ls_vbeln TO lr_vbeln_del.
          ENDIF. " IF sy-subrc <> 0
        ENDLOOP. " LOOP AT ct_likp INTO ls_likp
        IF NOT lr_vbeln_del IS INITIAL.
          DELETE ct_likp WHERE vbeln IN lr_vbeln_del.
        ENDIF. " IF NOT lr_vbeln_del IS INITIAL
      ENDIF. " IF sy-subrc <> 0
    ELSE. " ELSE -> IF NOT is_crit-land IS INITIAL
      SELECT * FROM vbpa " Sales Document: Partner
         INTO TABLE ct_vbpa
         FOR ALL ENTRIES IN ct_likp
         WHERE vbeln = ct_likp-vbeln
           AND parvw = 'WE'
           AND kunnr = ct_likp-kunnr.
    ENDIF. " IF NOT is_crit-land IS INITIAL
*-----------------
* Lieferpositionen
*-----------------
    IF ct_lips IS INITIAL.
      SELECT * FROM lips  INTO TABLE ct_lips
        FOR ALL ENTRIES IN ct_likp
        WHERE vbeln = ct_likp-vbeln.
    ENDIF. " IF ct_lips IS INITIAL
*-----------------
* Transport
*-----------------
    IF ct_vttp IS INITIAL.
      SELECT * FROM vttp INTO TABLE ct_vttp
         FOR ALL ENTRIES IN ct_likp
         WHERE vbeln = ct_likp-vbeln.
    ENDIF. " IF ct_vttp IS INITIAL
    IF ct_vttk IS INITIAL AND NOT
       ct_vttp IS INITIAL.
      SELECT * FROM vttk INTO TABLE ct_vttk
        FOR ALL ENTRIES IN ct_vttp
        WHERE tknum = ct_vttp-tknum
          AND tdlnr IN is_crit-spedt.
    ENDIF. " IF ct_vttk IS INITIAL AND NOT
*-------------------
* Außenhandelsdaten
*-------------------
    IF ct_eikp IS INITIAL.
      SELECT * FROM eikp INTO TABLE ct_eikp
        FOR ALL ENTRIES IN ct_likp
        WHERE exnum = ct_likp-exnum.
    ENDIF. " IF ct_eikp IS INITIAL
*-----------------
* Partner
*-----------------
    SELECT * FROM vbpa INTO TABLE lt_vbpa_l
      FOR ALL ENTRIES IN ct_likp
      WHERE vbeln = ct_likp-vbeln
        AND parvw = 'SP'
        AND lifnr IN is_crit-spedl. "#EC CI_NOFIRST
    IF sy-subrc <> 0 AND NOT is_crit-spedl IS INITIAL.
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*      MESSAGE i110 RAISING no_data.
*End of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
      MESSAGE i110 DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
    ENDIF. " IF sy-subrc <> 0 AND NOT is_crit-spedl IS INITIAL
    APPEND LINES OF lt_vbpa_l TO ct_vbpa.
*-- Nach Partnerselektion Lieferungsnummer nochmals filtern
*-- aber nur, wenn die Partner auch eingrenzendes Kriterium sind
    IF NOT is_crit-spedl IS INITIAL.
      LOOP AT ct_likp INTO ls_likp.
        IF NOT is_crit-spedl IS INITIAL.
          READ TABLE lt_vbpa_l
             WITH KEY vbeln = ls_likp-vbeln
             TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0 AND NOT lt_vbpa_l IS INITIAL.
            ls_vbeln-sign   = 'I'.
            ls_vbeln-option = 'EQ'.
            ls_vbeln-low    = ls_likp-vbeln.
            APPEND ls_vbeln TO lr_vbeln_del.
          ENDIF. " IF sy-subrc <> 0 AND NOT lt_vbpa_l IS INITIAL
        ENDIF. " IF NOT is_crit-spedl IS INITIAL
      ENDLOOP. " LOOP AT ct_likp INTO ls_likp
      IF NOT lr_vbeln_del IS INITIAL.
        DELETE ct_likp WHERE vbeln IN lr_vbeln_del.
        DELETE ct_lips WHERE vbeln IN lr_vbeln_del.
      ENDIF. " IF NOT lr_vbeln_del IS INITIAL
      IF ct_likp IS INITIAL.
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*        MESSAGE i110 RAISING no_data.
*End of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
        MESSAGE i110 DISPLAY LIKE 'E'.
        LEAVE LIST-PROCESSING.
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
      ENDIF. " IF ct_likp IS INITIAL
    ENDIF. " IF NOT is_crit-spedl IS INITIAL
*------------------------------
* Selektion nur über Partner
*------------------------------
  ELSE. " ELSE -> IF NOT is_crit-vkorg IS INITIAL OR
    SELECT * FROM vbpa INTO TABLE ct_vbpa "#EC CI_NOFIRST
     WHERE parvw = 'SP'                   "#EC CI_NOFIELD
        AND  lifnr IN is_crit-spedl.
    IF sy-subrc <> 0.
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*      MESSAGE i110 RAISING no_data.
*End of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
      MESSAGE i110 DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
    ENDIF. " IF sy-subrc <> 0
*-----------------
* Transport
*-----------------
    SELECT * FROM vttp INTO TABLE ct_vttp
      FOR ALL ENTRIES IN ct_vbpa
      WHERE vbeln = ct_vbpa-vbeln.
    LOOP AT ct_vttp INTO ls_vttp.
      ls_vbeln-sign   = 'I'.
      ls_vbeln-option = 'EQ'.
      ls_vbeln-low    = ls_vttp-vbeln.
      APPEND ls_vbeln TO lr_vbeln.
    ENDLOOP. " LOOP AT ct_vttp INTO ls_vttp
    SELECT * FROM vttk INTO TABLE ct_vttk
      FOR ALL ENTRIES IN ct_vttp
      WHERE tknum = ct_vttp-tknum.
*-----------------
* Lieferkopf
*-----------------
    SELECT * FROM likp INTO TABLE ct_likp
      FOR ALL ENTRIES IN ct_vbpa
      WHERE vbeln = ct_vbpa-vbeln
        AND vbeln IN lr_vbeln
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
        AND erdat IN fp_im_erdat
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
        AND lfart IN fp_im_lfart " Delivery type
*End of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
        AND vbtyp = 'J'.
    IF sy-subrc <> 0.
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*      MESSAGE i110 RAISING no_data.
*End of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
      MESSAGE i110 DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
    ELSE. " ELSE -> IF sy-subrc <> 0
*-- Erledigte Ausfiltern
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*      PERFORM likp_complete_filter CHANGING ct_likp
*                                            lr_vbeln
*                                            lr_exnum.
*End of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
      PERFORM f_likp_complete_filter  CHANGING ct_likp
                                               lr_vbeln
                                               lr_exnum.

*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
    ENDIF. " IF sy-subrc <> 0
*--------------------------
* Land des Warenempfängers
*--------------------------
    SELECT * FROM vbpa "#EC CI_NOFIELD
      INTO TABLE lt_vbpa_l
      FOR ALL ENTRIES IN ct_likp
      WHERE vbeln = ct_likp-vbeln
        AND parvw = 'WE'
        AND kunnr = ct_likp-kunnr.
    IF sy-subrc <> 0.
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*      MESSAGE i110 RAISING no_data.
*End of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
      MESSAGE i110 DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
    ELSE. " ELSE -> IF sy-subrc <> 0
      APPEND LINES OF lt_vbpa_l TO ct_vbpa.
    ENDIF. " IF sy-subrc <> 0
*-----------------
* Lieferpositionen
*-----------------
    IF ct_lips IS INITIAL.
      SELECT * FROM lips INTO TABLE ct_lips
        FOR ALL ENTRIES IN ct_likp
        WHERE vbeln = ct_likp-vbeln.
    ENDIF. " IF ct_lips IS INITIAL
*-------------------
* Außenhandelsdaten
*-------------------
    IF ct_eikp IS INITIAL.
      SELECT * FROM eikp INTO TABLE ct_eikp
        FOR ALL ENTRIES IN ct_likp
        WHERE exnum = ct_likp-exnum.
    ENDIF. " IF ct_eikp IS INITIAL
  ENDIF. " IF NOT is_crit-vkorg IS INITIAL OR
ENDFORM. " shipment_tables_select
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*----------------------------------------------------------------------*
***INCLUDE /SAPSLL/LCUS_INV_INTACT_R3F02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  result_table_modify
*&---------------------------------------------------------------------*
*       -->FP_IT_LIKP     LIKP  Table                                  *
*        --->FP_ct_cus_inv   Result  Table                              *
*----------------------------------------------------------------------*
FORM result_table_modify  USING  fp_it_likp    TYPE /sapsll/likp_r3_t
                        CHANGING fp_ct_cus_inv TYPE /sapsll/cus_inv_r3_t.
* Local type declaration
*Structure for LIKP data table
  TYPES: BEGIN OF ty_likp_modif,
         vbeln TYPE vbeln_vl, " Sales and Distribution Document Number
         lgnum TYPE char4,    " Warehouse Number / Warehouse Complex
         country TYPE land1,  " Country Key
         tzone TYPE lzone,    " Transportation zone to or from which the goods are delivered
         route TYPE char10,   " Route
         END OF ty_likp_modif,

*Structure for ADRC data table
        BEGIN OF ty_adrc,
         addrnumber TYPE ad_addrnum, " Address number
         transpzone TYPE lzone,      " Transportation zone to or from which the goods are delivered
         country TYPE land1,         " Country Key
        END OF ty_adrc,
*Structure for KNA1 data table
        BEGIN OF ty_kna1,
          kunnr TYPE kunnr, " Customer Number
          adrnr TYPE adrnr, " Address
        END OF ty_kna1.
*Local data declaration
  DATA:li_adrc TYPE STANDARD TABLE OF ty_adrc,
       li_likp_modif TYPE STANDARD TABLE OF ty_likp_modif,
       li_kna1 TYPE STANDARD TABLE OF ty_kna1,
       li_enh_status TYPE STANDARD TABLE OF  zdev_enh_status, " Enhancement Status
       lwa_kna1 TYPE ty_kna1,
       lwa_adrc TYPE ty_adrc,
       lwa_likp_modif TYPE ty_likp_modif,
       lwa_likp TYPE likp,                                    " SD Document: Delivery Header Data
       lwa_enh_status TYPE zdev_enh_status.                   " Enhancement Status
*Local constant declaration
  CONSTANTS: lc_enhancement_no TYPE z_enhancement VALUE 'OTC_EDD_0414', " Enhancement No.
             lc_rfcdes    TYPE z_criteria VALUE 'RFC_DEST'.             " RFC Destination
*Local variable declaration
  DATA :
          lv_rfcdest     TYPE rfcdest,    " RFC Logical Destination
          lv_rfc_dest    TYPE recvsystem, " Receiving logical system
          lv_source      TYPE logsys,     " Calling System
          lv_lgnum TYPE char4.            " Lgnum of type CHAR4

*Get EMI entries
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enhancement_no
    TABLES
      tt_enh_status     = li_enh_status.

  DELETE li_enh_status WHERE active = abap_false.

  REFRESH: li_kna1,
           li_adrc.
  IF fp_it_likp[] IS NOT INITIAL.
*Get address no for all KUNNR
    SELECT kunnr " Customer Number
           adrnr " Address
      FROM kna1  " General Data in Customer Master
      INTO TABLE li_kna1
      FOR ALL ENTRIES IN fp_it_likp
      WHERE kunnr = fp_it_likp-kunnr.
    IF sy-subrc EQ 0.
      SORT li_kna1 BY kunnr.
*Get Country and Transportation zone
      SELECT addrnumber " Address number
             transpzone " Transportation zone to or from which the goods are delivered
             country    " Country Key
       FROM adrc        " Addresses (Business Address Services)
        INTO TABLE  li_adrc
       FOR ALL ENTRIES IN li_kna1
        WHERE addrnumber = li_kna1-adrnr.
      IF sy-subrc EQ 0.
        SORT li_adrc BY addrnumber.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
    REFRESH: li_likp_modif.

    LOOP AT fp_it_likp INTO lwa_likp.
      lwa_likp_modif-vbeln = lwa_likp-vbeln.
      lwa_likp_modif-route = lwa_likp-route.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lwa_likp-lgnum
        IMPORTING
          output = lv_lgnum.

      lwa_likp_modif-lgnum = lv_lgnum.
      READ TABLE li_kna1 INTO lwa_kna1 WITH KEY kunnr = lwa_likp-kunnr
                                                BINARY SEARCH.
      IF sy-subrc EQ 0.
        READ TABLE li_adrc INTO lwa_adrc WITH KEY addrnumber = lwa_kna1-adrnr
                                                  BINARY SEARCH.
        IF sy-subrc EQ 0.
          lwa_likp_modif-country = lwa_adrc-country.
          lwa_likp_modif-tzone = lwa_adrc-transpzone.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc EQ 0
      APPEND lwa_likp_modif TO li_likp_modif.
      CLEAR:lwa_likp,
            lwa_likp_modif,
            lwa_adrc,
            lwa_kna1,
            lv_lgnum.
    ENDLOOP. " LOOP AT fp_it_likp INTO lwa_likp

* i) Get the logical name of calling system
    CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
      IMPORTING
        own_logical_system             = lv_source
      EXCEPTIONS
        own_logical_system_not_defined = 1
        OTHERS                         = 2.

    IF sy-subrc = 0.
* ii) Get the target system from EMI
      READ TABLE li_enh_status INTO lwa_enh_status
        WITH KEY criteria = lc_rfcdes " 'RFC_DEST'
                 sel_low  = lv_source.
      IF sy-subrc = 0.
        lv_rfcdest = lwa_enh_status-sel_high.
        CLEAR lwa_enh_status.

* iii) Check the RFC connection
        SELECT SINGLE logsys     " Receiving logical system
                 FROM tblsysdest " RFC Destination of Logical System
                 INTO lv_rfc_dest
                WHERE logsys = lv_rfcdest.
        IF sy-subrc = 0.
* iv) Call RFC FM and modify result table
          CALL FUNCTION 'ZOTC_VAT_EXEMPT'
            DESTINATION lv_rfc_dest
            TABLES
              tbl_likp    = li_likp_modif
              tbl_cus_inv = fp_ct_cus_inv.

* Sy-Subrc not checked, because no error handling is required
          IF fp_ct_cus_inv[] IS INITIAL.
            MESSAGE i110 DISPLAY LIKE 'E'.
            LEAVE LIST-PROCESSING.
          ENDIF. " IF fp_ct_cus_inv[] IS INITIAL
        ELSE. " ELSE -> IF sy-subrc = 0
          MESSAGE i101. " RFC Connection to EWM Failed
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0

    CLEAR : lv_source,
            lv_rfc_dest.

  ENDIF. " IF fp_it_likp[] IS NOT INITIAL

ENDFORM. "result_table_modify
*&---------------------------------------------------------------------*
*&      Form  F_LIKP_COMPLETE_FILTER
*&---------------------------------------------------------------------*
*       LIKP complete Filter
*----------------------------------------------------------------------*
*      -->ct_likp     LIKP table
*      -->cr_vbeln    VBELN table
*      -->cr_exnum   EXNUM Table
*----------------------------------------------------------------------*
*This subroutine is copied from standard subroutine LIKP_COMPLETE_FILTER.
*We have added ZDF8 billing type line item to lr_fkart.
*It checks that if proforma invoice is created for the delivery
*with any billing type then it will not allow to create invoice again for that delivery
*Previously the lr_fkart has only six billing type and as per new requirement
*we need proforma for ZDF8 billing type also. So we have added this in lr_lfart to
*enable the functionality of this code for ZDF8 billing type

FORM f_likp_complete_filter CHANGING ct_likp  TYPE /sapsll/likp_r3_t
                                    cr_vbeln TYPE /sapsll/vbeln_r3_r_t
                                    cr_exnum TYPE /sapsll/exnum_r3_r_t.

  DATA: lt_vbfa      TYPE /sapsll/vbfa_r3_t.
  DATA: ls_vbfa      TYPE vbfa. " Sales Document Flow
  DATA: ls_likp      TYPE likp. " SD Document: Delivery Header Data
  DATA: lt_vbrk      TYPE tab_vbrk.
  DATA: ls_vbrk      TYPE vbrk. " Billing Document: Header Data
  DATA: ls_vbeln     TYPE /sapsll/vbeln_r3_r_s. " Range Structure for Data Element /SAPSLL/VBELN_R3
  DATA: ls_exnum     TYPE /sapsll/exnum_r3_r_s. " Number of Foreign Trade Data
  DATA: lr_vbeln_del TYPE /sapsll/vbeln_r3_r_t.
  DATA: lt_tler3b    TYPE  sllr3_doc_type_t.
  DATA: ls_tler3b    TYPE  sllr3_doc_type_s.
  DATA: lv_tfill     TYPE sy-tfill. " Row Number of Internal Tables

  TYPES: BEGIN OF /sapsll/fkart_r_s,
           sign   TYPE ddsign,   " Type of SIGN component in row type of a Ranges type
           option TYPE ddoption, " Type of OPTION component in row type of a Ranges type
           low    TYPE fkart,    " Billing Type
           high   TYPE fkart,    " Billing Type
         END OF /sapsll/fkart_r_s.

  DATA: ls_fkart TYPE /sapsll/fkart_r_s.
  DATA: lr_fkart TYPE STANDARD TABLE OF /sapsll/fkart_r_s.

  CONSTANTS: lc_i TYPE char1 VALUE 'I',        " I of type CHAR1
             lc_eq TYPE char2 VALUE 'EQ',      " Eq of type CHAR2
             lc_zdf8 TYPE char10 VALUE 'ZDF8'. " Zdf8 of type CHAR10

  CLEAR cr_vbeln.
  CLEAR cr_exnum.

*-----------------------------------------------------------------------
*- Rechnungs-Check
*-----------------------------------------------------------------------
*-- Belegfluss nachlesen
  DESCRIBE TABLE ct_likp LINES lv_tfill.
  IF lv_tfill > 0.
    SELECT * FROM vbfa INTO TABLE lt_vbfa
      FOR ALL ENTRIES IN ct_likp
      WHERE vbelv = ct_likp-vbeln
        AND vbtyp_n = vbtyp_rech. " Rechnungen
  ENDIF. " IF lv_tfill > 0

  IF sy-subrc = 0.
*-- Nur GTS-relevante Fakturen nachlesen
    SELECT * FROM /sapsll/tler3b " SLL: R/3 BS: Control: Call Customs Server: Doc. Types
        INTO CORRESPONDING FIELDS OF TABLE lt_tler3b
          WHERE apevs_r3 = gc_application_level-invoice
            AND gcuma_r3 = gc_true.

    LOOP AT lt_tler3b INTO ls_tler3b.
      ls_fkart-sign   = 'I'.
      ls_fkart-option = 'EQ'.
      ls_fkart-low    = ls_tler3b-barvs_r3.
      APPEND ls_fkart TO lr_fkart.
    ENDLOOP. " LOOP AT lt_tler3b INTO ls_tler3b
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632
*Adding ZDF8 line item to lr_fkart to avoid duplicate creation of Proforma
    CLEAR: ls_fkart.
    ls_fkart-sign   = lc_i.
    ls_fkart-option = lc_eq.
    ls_fkart-low    = lc_zdf8.
    APPEND ls_fkart TO lr_fkart.
*End of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect 7847 by U033632

*-- Fakturen aus dem Belegfluss nachlesen (nur Überleitungsrelevante)
    DESCRIBE TABLE lt_vbfa LINES lv_tfill.
    IF lv_tfill > 0.
      SELECT * FROM vbrk INTO TABLE lt_vbrk
         FOR ALL ENTRIES IN lt_vbfa
          WHERE vbeln = lt_vbfa-vbeln
          AND   fkart IN lr_fkart
          AND   fksto = ' '.
    ENDIF. " IF lv_tfill > 0

*-- Lieferungen zu nicht stornierten Fakturen ausschließen
    IF sy-subrc = 0.
      LOOP AT ct_likp INTO ls_likp.
        LOOP AT lt_vbfa INTO ls_vbfa
          WHERE vbelv = ls_likp-vbeln.
          READ TABLE lt_vbrk INTO ls_vbrk
              WITH KEY vbeln = ls_vbfa-vbeln.
          IF sy-subrc = 0.
            ls_vbeln-sign   = 'I'.
            ls_vbeln-option = 'EQ'.
            ls_vbeln-low    = ls_likp-vbeln.
            APPEND ls_vbeln TO lr_vbeln_del.
          ENDIF. " IF sy-subrc = 0
        ENDLOOP. " LOOP AT lt_vbfa INTO ls_vbfa
      ENDLOOP. " LOOP AT ct_likp INTO ls_likp
*---- Lieferungen aussortieren fuer Kundenfakturen, die
*---- GTS-ueberleitungsrelevant
*---- Annahme: Zollanmeldung auf Basis Kundenfaktura bereits erstellt;
*---- erzeugen einer Proforma nicht sinnvoll - Doppelanlage
      IF NOT lr_vbeln_del IS INITIAL.
        DELETE ct_likp WHERE vbeln IN lr_vbeln_del.
        DESCRIBE TABLE ct_likp LINES sy-tfill.
        IF sy-tfill = 0.
          EXIT.
        ENDIF. " IF sy-tfill = 0
      ENDIF. " IF NOT lr_vbeln_del IS INITIAL
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF sy-subrc = 0

*-----------------------------------------------------------------------
*- Pro-Forma-Check
*-----------------------------------------------------------------------
*-- Belegfluss nachlesen
  CLEAR lt_vbfa.
  DESCRIBE TABLE ct_likp LINES lv_tfill.
  IF lv_tfill > 0.
    SELECT * FROM vbfa INTO TABLE lt_vbfa
      FOR ALL ENTRIES IN ct_likp
      WHERE vbelv = ct_likp-vbeln
        AND ( vbtyp_n = vbtyp_prof      OR " Pro-Forma
              vbtyp_n = vbtyp_fkiv_last OR "IV Lastschrift
              vbtyp_n = vbtyp_fkiv_gut ).  "IV Gutschrift
  ENDIF. " IF lv_tfill > 0

  IF sy-subrc <> 0.
*-- Zulässige Lieferungen zur weiteren Selektion vorbereiten
    LOOP AT ct_likp INTO ls_likp.
      ls_vbeln-sign   = 'I'.
      ls_vbeln-option = 'EQ'.
      ls_vbeln-low    = ls_likp-vbeln.
      APPEND ls_vbeln TO cr_vbeln.

      ls_exnum-sign   = 'I'.
      ls_exnum-option = 'EQ'.
      ls_exnum-low    = ls_likp-exnum.
      APPEND ls_exnum TO cr_exnum.
    ENDLOOP. " LOOP AT ct_likp INTO ls_likp
    EXIT.
  ENDIF. " IF sy-subrc <> 0

  IF lr_fkart IS INITIAL.
*-- Nur GTS-relevante Fakturen nachlesen
    SELECT * FROM /sapsll/tler3b " SLL: R/3 BS: Control: Call Customs Server: Doc. Types
        INTO CORRESPONDING FIELDS OF TABLE lt_tler3b
          WHERE apevs_r3 = gc_application_level-invoice
            AND gcuma_r3 = gc_true.

    LOOP AT lt_tler3b INTO ls_tler3b.
      ls_fkart-sign   = 'I'.
      ls_fkart-option = 'EQ'.
      ls_fkart-low    = ls_tler3b-barvs_r3.
      APPEND ls_fkart TO lr_fkart.
    ENDLOOP. " LOOP AT lt_tler3b INTO ls_tler3b
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Adding ZDF8 line item to lr_fkart
    ls_fkart-sign   = lc_i.
    ls_fkart-option = lc_eq.
    ls_fkart-low    = lc_zdf8.
    APPEND ls_fkart TO lr_fkart.
  ENDIF. " IF lr_fkart IS INITIAL
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*-- Selektiere Fakturen, die keine Erledigung besitzen, also gültig
*-- und GTS-relevant sind
  CLEAR lt_vbrk.
  DESCRIBE TABLE lt_vbfa LINES lv_tfill.
  IF lv_tfill > 0.
    SELECT * FROM vbrk INTO TABLE lt_vbrk
       FOR ALL ENTRIES IN lt_vbfa
        WHERE vbeln = lt_vbfa-vbeln
          AND fkart IN lr_fkart
          AND rfbsk NE 'E'.
  ENDIF. " IF lv_tfill > 0

*-- Lieferungsnummer über den Belegfluss prüfen, ob es
*-- offene GTS-relevante Fakturen gibt
  LOOP AT ct_likp INTO ls_likp.
*-- Es kann mehrere Pro-Forma-Fakturen geben
    LOOP AT lt_vbfa INTO ls_vbfa
      WHERE vbelv = ls_likp-vbeln.
      READ TABLE lt_vbrk INTO ls_vbrk
          WITH KEY vbeln = ls_vbfa-vbeln.
      IF sy-subrc = 0.
        ls_vbeln-sign   = 'I'.
        ls_vbeln-option = 'EQ'.
        ls_vbeln-low    = ls_likp-vbeln.
        APPEND ls_vbeln TO lr_vbeln_del.
*-- Eine offene Faktura ist ausreichend -> Verlassen der Schleife
        EXIT.
      ENDIF. " IF sy-subrc = 0
    ENDLOOP. " LOOP AT lt_vbfa INTO ls_vbfa
  ENDLOOP. " LOOP AT ct_likp INTO ls_likp

*-- Lieferungen löschen, die bereits erledigte Fakturen besitzen
  IF NOT lr_vbeln_del IS INITIAL.
    DELETE ct_likp WHERE vbeln IN lr_vbeln_del.
  ENDIF. " IF NOT lr_vbeln_del IS INITIAL

*-- Zulässige Lieferungen zur weiteren Selektion vorbereiten
  LOOP AT ct_likp INTO ls_likp.
    ls_vbeln-sign   = 'I'.
    ls_vbeln-option = 'EQ'.
    ls_vbeln-low    = ls_likp-vbeln.
    APPEND ls_vbeln TO cr_vbeln.
*Begin of insert for D3_OTC_EDD_0414 D#8283 by mthatha
*    IF ls_likp-exnum IS NOT INITIAL.
*End of insert for D3_OTC_EDD_0414 D#8283 by mthatha
    ls_exnum-sign   = 'I'.
    ls_exnum-option = 'EQ'.
    ls_exnum-low    = ls_likp-exnum.
    APPEND ls_exnum TO cr_exnum.
*Begin of insert for D3_OTC_EDD_0414 D#8283 by mthatha
*    ENDIF. " IF ls_likp-exnum IS NOT INITIAL
*End of insert for D3_OTC_EDD_0414 D#8283 by mthatha
  ENDLOOP. " LOOP AT ct_likp INTO ls_likp
ENDFORM. "f_likp_complete_filter
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
