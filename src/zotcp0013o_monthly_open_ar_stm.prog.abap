*&---------------------------------------------------------------------*
*& REPORT  ZOTCP0013O_MONTHLY_OPEN_AR_STM
*&---------------------------------------------------------------------*

************************************************************************
* PROGRAM    :  ZOTCP0013O_MONTHLY_OPEN_AR_STM                         *
* TITLE      :  Driver program for Monthly Open AR Statement           *
* DEVELOPER  :  Vivek Gaur                                             *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   OTC_FDD_0013_Monthly Open AR Statement                  *
*----------------------------------------------------------------------*
* DESCRIPTION: Driver program for Monthly Open AR Statement This       *
*              program is copied from standard program RFKORD11_PDF and*
*              necessary modifications are made for PDF form generation*
*              The changes in the code are tagged with the TR number   *
*              E1DK901190                                              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 15-May-2012 VGAUR    E1DK901190 Initial Development                  *
************************************************************************
* 04-Jan-2013 ADAS1    E1DK908816 Comment code to Remove Block customers
************************************************************************
* 10-Apr-2013 AMANGAL  E1DK909861 CR357 Defect 3453. Send email only in*
*                       background mode. Form f_adobe_form_processing  *
*=======================================================================
************************************************************************
* 25-Jan-2018 SMUKHER4  E1DK931140 D3R3 Development:                   *
*1.Check box added for multiple spool generation in the selection screen*
*2.Copy of standard include RFKORI90 into custom include and custom     *
*  logic has been added for multiple spool generation.                 *
*=======================================================================
*{   INSERT         E2DK923798                                        3
************************************************************************
* 8-May-2019 U105235  E2DK923798 Defect 9480. Customer statement was   *
*                     giving dump becoz of upgrade changes in the TOP  *
*                     Include internal table declarations, from EHP6   *
*                     version TOP INCLUDE is copied                    *
*=======================================================================
*}   INSERT
*       Druckprogramm: Customer Statement (South Africa)
*=======================================================================


*=======================================================================
*       Das Programm includiert
*
*       RFKORI00 Datendeklaration
*       RFKORI02 Datendeklaration
*       RFKORI16 Customer Statement (South Africa)
*       RFKORI80 Leseroutinen
*       RFKORI90 Allgemeine Unterroutinen
*       RFKORI91 Routinen für Extract
*       RFKORI92 Allgemeine Unterroutinen
*       RFKORI93 Allgemeine Unterroutinen für Messages und Protokoll
*       RFKORIEX User-Exits für Korrespondenz
*=======================================================================


*=======================================================================
*       Report-Header
*=======================================================================
REPORT zotcp0013o_monthly_open_ar_stm MESSAGE-ID fb
                                      NO STANDARD PAGE HEADING.

*=======================================================================
*       Datenteil
*=======================================================================
*{   REPLACE        E2DK923798                                        1
*\
*Begin of code changes - U105235 - Defect 9480-8000020107-Customer statement Dump
*The below Top Include rfkori00 has been replaced with the custom Top Include
*by copying the declarations from EHP6 Version as the internal table declaration
*is giving the Dump
*}   REPLACE
*{   REPLACE        E2DK923798                                        2
*\INCLUDE rfkori00.
INCLUDE ZOTCP0013O_RFKORI00_TOP.
*End of code changes - U105235 - Defect 9480-8000020107-Customer statement Dump

*}   REPLACE
INCLUDE rfkori02.

************************************************************************
*  Start of changes for PDF generation
*  Copy of Standard Program RFKORD11_PDF
*----------------------------------------------------------------------*
*  User      Transport
*----------------------------------------------------------------------*
*  VGAUR     E1DK901190
************************************************************************
CONSTANTS:
*&--Program Name
 c_prog_name TYPE sy-repid VALUE 'ZOTCP0013O_MONTHLY_OPEN_AR_STM'.
************************************************************************
*  Start of changes for PDF generation
*  Copy of Standard Program RFKORD11_PDF
*----------------------------------------------------------------------*
*  User      Transport
*----------------------------------------------------------------------*
*  VGAUR     E1DK901190
************************************************************************

*-----------------------------------------------------------------------
*       Tables (RFKORI00)
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
*       Datenfelder für den Report RFKORD10
*
*       Teil 1 : Einzelfelder (RFKORI00)
*       Teil 2 : Strukturen (RFKORI00 und RFKORI02)
*       Teil 3 : Interne Tabellen (RFKORI00 und RFKORI02)
*       Teil 4 : Konstanten (RFKORI00)
*       Teil 5 : Field-Symbols
*       Teil 6 : Select-Options und Parameter
*       Teil 7 : Field-Groups
*-----------------------------------------------------------------------


*-----------------------------------------------------------------------
*       Teil 5 : Field-Symbols
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
*       Teil 6 : Select-Options und Parameter
*-----------------------------------------------------------------------
begin_of_block 2.
PARAMETERS:     rforid   LIKE rfpdo1-allgevfo,
                rtkoid   LIKE rfpdo1-allgevst.

PARAMETERS:     sortvk   LIKE rfpdo1-kordvark.
PARAMETERS:     sortvp   LIKE rfpdo1-kordvarp.
PARAMETERS:     sortvp2  LIKE rfpdo1-kordvarp.

*ARAMETERS:     PSORT    LIKE RFPDO1-KORD10PS DEFAULT '1'.
*ARAMETERS:     RXOPOS   LIKE RFPDO1-KORD10OP DEFAULT ' '.
PARAMETERS:     rxopol   LIKE rfpdo1-kord10ol DEFAULT ' '.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS      rxekvb   LIKE rfpdo2-kordekvb.
SELECTION-SCREEN COMMENT 03(28) text-106 FOR FIELD rxekvb.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS      rxekep   LIKE rfpdo2-kordekep.
SELECTION-SCREEN COMMENT 36(15) text-107 FOR FIELD rxekep.
SELECTION-SCREEN POSITION POS_HIGH.
PARAMETERS      rxeksu   LIKE rfpdo2-kordeksu.
SELECTION-SCREEN COMMENT 61(15) text-108 FOR FIELD rxeksu.
SELECTION-SCREEN END OF LINE.
PARAMETERS:     rxverr   LIKE rfpdo2-kordverr DEFAULT ' '.
PARAMETERS:     rxdezv   LIKE knb1-xdezv      DEFAULT ' '.
PARAMETERS:     rxkpos   LIKE rfpdo1-kord10ao DEFAULT ' '.
PARAMETERS:     rxknus   LIKE rfpdo1-kord10ns DEFAULT ' ' NO-DISPLAY.
SELECT-OPTIONS: rsaldo   FOR  rfsdo-kord10sa.

PARAMETERS:     rdatar   LIKE rfpdo1-f140data.
SELECT-OPTIONS: bschl    FOR  bseg-bschl,
                umskz    FOR  bseg-umskz.
PARAMETERS:     statbl   LIKE rfpdo-bpetsbel.
PARAMETERS:     vorebl   LIKE rfpdo2-sopovbel.
PARAMETERS:     raugbl   LIKE rfpdo2-kord10ab.
PARAMETERS:     rzlsch   LIKE t048y-zlsch.
PARAMETERS:     rxavis   LIKE rfpdo3-allgavis.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) text-101 FOR FIELD vstid.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS      vstid    LIKE rf140-vstid.
SELECTION-SCREEN POSITION POS_HIGH.
PARAMETERS      dvstid   LIKE rfpdo1-kord10dv DEFAULT ' '.
SELECTION-SCREEN COMMENT 61(9) text-102 FOR FIELD dvstid.
SELECTION-SCREEN END OF LINE.

PARAMETERS:     rvztag   LIKE rfpdo1-kord10va DEFAULT ' '.
PARAMETERS:     rart-net LIKE rfpdo1-kord10r1 DEFAULT ' '.
PARAMETERS:     rart-sk1 LIKE rfpdo1-kord10r2 DEFAULT ' '.
PARAMETERS:     rart-sk2 LIKE rfpdo1-kord10r3 DEFAULT ' '.
PARAMETERS:     rart-ueb LIKE rfpdo1-kord10r4 DEFAULT ' '.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS      rart-alt LIKE rfpdo2-kord10r5.
SELECTION-SCREEN COMMENT 03(28) text-105 FOR FIELD rart-alt.
SELECTION-SCREEN POSITION POS_HIGH.
PARAMETERS      rbldat   LIKE rfpdo2-kord10bd.
SELECTION-SCREEN COMMENT 61(12) text-104 FOR FIELD rbldat.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(30) text-103 FOR FIELD rastbis1.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS:     rastbis1    LIKE rfpdo1-allgrogr DEFAULT '000'.
PARAMETERS:     rastbis2    LIKE rfpdo1-allgrogr DEFAULT '030'.
PARAMETERS:     rastbis3    LIKE rfpdo1-allgrogr DEFAULT '060'.
PARAMETERS:     rastbis4    LIKE rfpdo1-allgrogr DEFAULT '000'.
PARAMETERS:     rastbis5    LIKE rfpdo1-allgrogr DEFAULT '000'.
SELECTION-SCREEN END OF LINE.
end_of_block 2.
begin_of_block 8.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) text-110 FOR FIELD tddest.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS      tddest   LIKE tsp01-rqdest VISIBLE LENGTH 11.
SELECTION-SCREEN POSITION POS_HIGH.
PARAMETERS      rimmd    LIKE rfpdo2-f140immd DEFAULT ' '.
SELECTION-SCREEN COMMENT 61(15) text-111 FOR FIELD rimmd.
SELECTION-SCREEN END OF LINE.
PARAMETERS:     prdest   LIKE tsp01-rqdest VISIBLE LENGTH 11.
end_of_block 8.
begin_of_block 4.
SELECT-OPTIONS: rbukrs   FOR  bkorm-bukrs,
                rkoart   FOR  rf140-koart_f140,
                rkonto   FOR  bkorm-konto,
                rbelnr   FOR  bkorm-belnr NO-DISPLAY,
                rgjahr   FOR  bkorm-gjahr NO-DISPLAY.
PARAMETERS:     rxbukr   LIKE rf022-xbukr.
PARAMETERS:     rxbkor   LIKE rfpdo-kordbkor.
PARAMETERS:     revent   LIKE bkorm-event.
SELECT-OPTIONS: rusnam   FOR  bkorm-usnam.
SELECT-OPTIONS: rdatum   FOR  bkorm-datum.
SELECT-OPTIONS: ruzeit   FOR  bkorm-uzeit.
SELECT-OPTIONS: rerldt   FOR  bkorm-erldt.
PARAMETERS:     rxtsub   LIKE xtsubm NO-DISPLAY.
PARAMETERS:     rxkont   LIKE xkont NO-DISPLAY,
                rxbelg   LIKE xbelg NO-DISPLAY,
                ranzdt   LIKE anzdt NO-DISPLAY,
                rkauto   TYPE c     NO-DISPLAY,
                rsimul   TYPE c     NO-DISPLAY,
                rpdest   LIKE syst-pdest NO-DISPLAY,
                title    LIKE rfpdo1-allgline NO-DISPLAY.

PARAMETERS:     rindko   LIKE rfpdo1-kordindk.
PARAMETERS:     rspras   LIKE rf140-spras.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) text-100 FOR FIELD budat01.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS budat01    LIKE rf140-datu1.
SELECTION-SCREEN POSITION POS_HIGH.
PARAMETERS budat02    LIKE rf140-datu2.
SELECTION-SCREEN END OF LINE.
*---> Begin of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
*&--Check box added for multiple spool generation.
*--Multiple spool will only be generated when this check box will be checked.
PARAMETERS: p_chkbox AS CHECKBOX USER-COMMAND chk.
*<--- End of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
end_of_block 4.

*-----------------------------------------------------------------------
*       Teil 7 : Field-Groups
*-----------------------------------------------------------------------

*=======================================================================
*       Vor dem Selektionsbild
*=======================================================================

*-----------------------------------------------------------------------
*       Initialization
*-----------------------------------------------------------------------
INITIALIZATION.
  get_frame_title: 2, 4, 8.

*=======================================================================
*       Hauptablauf
*=======================================================================

*-----------------------------------------------------------------------
*       Eingabenkonvertierung und Eingabenprüfung
*-----------------------------------------------------------------------
AT SELECTION-SCREEN.
  PERFORM check_eingabe.

*-----------------------------------------------------------------------
*       Start-of-Selection
*-----------------------------------------------------------------------
  SET BLANK LINES ON.

START-OF-SELECTION.
***<<<pdf-enabling
************************************************************************
*  Start of changes for PDF generation
*  Copy of Standard Program RFKORD11_PDF
*----------------------------------------------------------------------*
*  User      Transport
*----------------------------------------------------------------------*
*  VGAUR     E1DK901190
************************************************************************
  save_repid = c_prog_name.
  rastbis4 = 90.
************************************************************************
*  End of changes for PDF generation
*  Copy of Standard Program RFKORD11_PDF
*----------------------------------------------------------------------*
*  User      Transport
*----------------------------------------------------------------------*
*  VGAUR     E1DK901190
************************************************************************
  save_repid_alw   = 'RFKORD11'.
  save_ftype       = '3'. "PDF
***>>>pdf-enabling

* IF NOT RXBKOR IS INITIAL.
  save_event  = revent.
* ENDIF.
* IF  NOT RAUGBL IS INITIAL
* AND RXOPOL     IS INITIAL.
*   CLEAR RAUGBL.
* ENDIF.
  save_forid   = rforid.
  save_tkoid   = rtkoid.
  save_tddest  = tddest.
  save_prdest  = prdest.
  save_pdest   = rpdest.
  save_stida   = budat01.
  save_statbl  = statbl.
  save_rdatar  = rdatar.
  save_rxopol  = rxopol.
  save_rxtsub  = rxtsub.
  save_rxekvb  = rxekvb.
  save_rxverr  = rxverr.
  save_rxdezv  = rxdezv.
  save_rimmd   = rimmd.
  save_sortvk  = sortvk.
  save_sortvp  = sortvp.
  save_sortvp2 = sortvp2.
  save_rsimul = rsimul.
  save_rzlsch = rzlsch.
  save_rxavis = rxavis.
  save_rxbukr = rxbukr.
  CLEAR hlp_t021m_k.
  CLEAR hlp_t021m_p.
  CLEAR hlp_t021m_p2.
  IF NOT save_sortvk  IS INITIAL.
    PERFORM sort_felder USING 'K' 'K'.
  ENDIF.
  IF NOT save_sortvp  IS INITIAL.
    PERFORM sort_felder USING 'P' '1'.
    IF hlp_t021m_p-feld1 = 'UMSKZ'.
      hpumsk = '1'.
      xumskz = 'X'.
    ENDIF.
    IF hlp_t021m_p-feld2 = 'UMSKZ'.
      hpumsk = '2'.
      xumskz = 'X'.
    ENDIF.
    IF hlp_t021m_p-feld3 = 'UMSKZ'.
      hpumsk = '3'.
      xumskz = 'X'.
    ENDIF.
    IF hlp_t021m_p-feld4 = 'UMSKZ'.
      hpumsk = '4'.
      xumskz = 'X'.
    ENDIF.
    IF hlp_t021m_p-feld5 = 'UMSKZ'.
      hpumsk = '5'.
      xumskz = 'X'.
    ENDIF.
    PERFORM umskz_assign.
    IF NOT rxekvb IS INITIAL.
      IF hlp_t021m_p-feld1 = 'KONTO'.
        hpkont = '1'.
        xpkont = 'X'.
      ENDIF.
      IF hlp_t021m_p-feld2 = 'KONTO'.
        hpkont = '2'.
        xpkont = 'X'.
      ENDIF.
      IF hlp_t021m_p-feld3 = 'KONTO'.
        hpkont = '3'.
        xpkont = 'X'.
      ENDIF.
      IF hlp_t021m_p-feld4 = 'KONTO'.
        hpkont = '4'.
        xpkont = 'X'.
      ENDIF.
      IF hlp_t021m_p-feld5 = 'KONTO'.
        hpkont = '5'.
        xpkont = 'X'.
      ENDIF.
      IF hpkont IS INITIAL
      AND NOT rxekep IS INITIAL.
        MESSAGE e852.
      ENDIF.
      IF NOT xpkont IS INITIAL.
        PERFORM konto_assign.
      ENDIF.
    ENDIF.
  ENDIF.
  IF NOT save_sortvp2 IS INITIAL.
    PERFORM sort_felder USING 'P' '2'.
    IF NOT rxekvb IS INITIAL.
      IF hlp_t021m_p2-feld1 = 'KONTO'.
        hpkon2 = '1'.
      ENDIF.
      IF hlp_t021m_p2-feld2 = 'KONTO'.
        hpkon2 = '2'.
      ENDIF.
      IF hlp_t021m_p2-feld3 = 'KONTO'.
        hpkon2 = '3'.
      ENDIF.
      IF hlp_t021m_p2-feld4 = 'KONTO'.
        hpkon2 = '4'.
      ENDIF.
      IF hlp_t021m_p2-feld5 = 'KONTO'.
        hpkon2 = '5'.
      ENDIF.
      IF hpkon2 IS INITIAL
      AND NOT rxekep IS INITIAL.
        MESSAGE e852.
      ENDIF.
    ENDIF.
  ENDIF.
  kautofl = rkauto.
  CLEAR xbkorm.
  CLEAR countp.
  LOOP AT bschl.
    MOVE-CORRESPONDING bschl TO hbschl.
    APPEND hbschl.
  ENDLOOP.
  LOOP AT umskz.
    MOVE-CORRESPONDING umskz TO humskz.
    APPEND humskz.
  ENDLOOP.
  CLEAR   hbukrs.
  REFRESH hbukrs.
  LOOP AT rbukrs.
    MOVE-CORRESPONDING rbukrs TO hbukrs.
    APPEND hbukrs.
  ENDLOOP.
  IF NOT rxtsub IS INITIAL.
    PERFORM prot_import.
  ENDIF.
  PERFORM message_init.
  IF NOT rart-net IS INITIAL
  OR NOT rart-sk1 IS INITIAL
  OR NOT rart-sk2 IS INITIAL
  OR NOT rart-ueb IS INITIAL
  OR NOT rart-alt IS INITIAL.
    PERFORM raster_aufbau.
  ENDIF.
  PERFORM currency_check_for_process USING save_repid_alw.
  IF  alwcheck IS INITIAL
  AND NOT alwlines IS INITIAL.
    LOOP AT alw_bukrs.
      IF alw_bukrs-bukrs IN rbukrs.
        alwcheck = 'X'.
      ENDIF.
    ENDLOOP.
  ENDIF.

*-----------------------------------------------------------------------
*       Datenselektion
*-----------------------------------------------------------------------
  IF t048-event NE save_event.
    PERFORM read_t048.
  ENDIF.
  IF NOT rxbkor IS INITIAL.
    PERFORM fill_selection_bkorm.
* SORTID = ' '.
    PERFORM read_bkorm.
  ELSE.
    PERFORM selection_ohne_bkorm.
  ENDIF.

*-----------------------------------------------------------------------
*       End-of-Selection
*-----------------------------------------------------------------------
END-OF-SELECTION.

*-------Daten extrahiert ?----------------------------------------------
  IF xextra IS INITIAL.
    PERFORM message_no_selection.
  ELSE.
*-----------------------------------------------------------------------
*       Sortierung
*-----------------------------------------------------------------------
    SORT BY hdbukrs sortk1  sortk2  sortk3  sortk4  sortk5  hdkoart
            hdkonto hdusnam hddatum hduzeit.

*-----------------------------------------------------------------------
*       Ausgabe
*-----------------------------------------------------------------------

    PERFORM kontoauszuege.

  ENDIF.

*=======================================================================
*       TOP-OF-PAGE
*=======================================================================
TOP-OF-PAGE.

  PERFORM batch-heading(rsbtchh0).
  ULINE.

*=======================================================================
*       Interne Perform-Routinen
*=======================================================================

*-----------------------------------------------------------------------
*       Customer Statement Formulardruck
*-----------------------------------------------------------------------

************************************************************************
*  Start of changes for PDF generation
*  Copy of Standard Program RFKORD11_PDF
*----------------------------------------------------------------------*
*  User      Transport
*----------------------------------------------------------------------*
*  VGAUR     E1DK901190
************************************************************************

*  INCLUDE rfkori16pdf.
  INCLUDE zotcn0013o_rfkori16pdf.

************************************************************************
*  End of changes for PDF generation
*  Copy of Standard Program RFKORD11_PDF
*----------------------------------------------------------------------*
*  User      Transport
*----------------------------------------------------------------------*
*  VGAUR     E1DK901190
************************************************************************

*-----------------------------------------------------------------------
*       Leseroutinen
*-----------------------------------------------------------------------

  INCLUDE rfkori80.
*---> Begin of Changes for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
*-----------------------------------------------------------------------
*       Allgemeine Unterroutinen
*-----------------------------------------------------------------------
************************************************************************
*  Start of changes for spool generation
*  Copy of Standard Program RFKORI90
*----------------------------------------------------------------------*
*  User      Transport
*----------------------------------------------------------------------*
*  SMUKHER4    E1DK931140
************************************************************************
*&--Standard include is commented since we have added custom logic in the custom include
*for multiple spool generation.
*  INCLUDE rfkori90.
  INCLUDE zotcn0013o_rfkori90_spool_gen.

*-----------------------------------------------------------------------
*       Allgemeine Unterroutinen
*-----------------------------------------------------------------------
************************************************************************
*  End of changes for spool generation
*  Copy of Standard Program RFKORD11_PDF
*----------------------------------------------------------------------*
*  User      Transport
*----------------------------------------------------------------------*
*  SMUKHER4    E1DK931140
************************************************************************
*<--- End of Changes for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018

  INCLUDE rfkori92.

*-----------------------------------------------------------------------
*       Routinen für Extract
*-----------------------------------------------------------------------
  INCLUDE rfkori91.

*-----------------------------------------------------------------------
*       Allgemeine Unterroutinen für Messages und Protokoll
*-----------------------------------------------------------------------
  INCLUDE rfkori93.

*-----------------------------------------------------------------------
*       User-Exits für Korrespondenz
*-----------------------------------------------------------------------
*NCLUDE RFKORIEX.

*-----------------------------------------------------------------------
*       FORM ANALYSE_UND_AUSGABE
*-----------------------------------------------------------------------
FORM analyse_und_ausgabe.
  CLEAR xnach.
  CLEAR *knb1.
  CLEAR *lfb1.
  IF hdkoart = 'D'.
    CLEAR save_kunnr.
    save_kunnr = hdkonto.
    PERFORM read_kna1.
    IF sy-subrc NE 0.
      xkausg = 'X'.
    ENDIF.
    IF kna1-xcpdk IS INITIAL.
      PERFORM read_knb1.
      IF sy-subrc NE 0.
        xkausg = 'X'.
      ENDIF.
*Begin of change By SBASU *********************
* BOC DEL ADAS1 D#2244
*    if knb1-XAUSZ  is initial.
*      xkausg = 'X'.
*    endif.
* EOC DEL ADAS1 D#2244
*End of change by SBASU************************
      IF      save_rxekvb IS INITIAL
      AND NOT save_rxdezv IS INITIAL
      AND NOT knb1-knrze  IS INITIAL.
        save2_bukrs = knb1-bukrs.
        save2_kunnr = knb1-knrze.
        PERFORM read_knb1_2.
        IF sy-subrc NE 0.
          xkausg = 'X'.
        ENDIF.
      ENDIF.
      IF  NOT save_rxverr IS INITIAL
      AND NOT kna1-lifnr  IS INITIAL
      AND NOT knb1-xverr  IS INITIAL.
        xverr  = 'X'.
        save_lifnr = kna1-lifnr.
        PERFORM read_lfa1.
        IF sy-subrc NE 0.
          xkausg = 'X'.
        ENDIF.
        IF lfa1-xcpdk IS INITIAL.
          PERFORM read_lfb1.
          IF sy-subrc NE 0.
            xkausg = 'X'.
          ENDIF.
          IF      save_rxekvb IS INITIAL
          AND NOT save_rxdezv IS INITIAL
          AND NOT lfb1-lnrze  IS INITIAL.
            save2_bukrs = lfb1-bukrs.
            save2_lifnr = lfb1-lnrze.
            PERFORM read_lfb1_2.
            IF sy-subrc NE 0.
              xkausg = 'X'.
            ENDIF.
          ENDIF.
        ELSE.
          xverr  = ' '.
          CLEAR save_lifnr.
        ENDIF.
      ELSE.
        xverr  = ' '.
        CLEAR save_lifnr.
      ENDIF.
      IF NOT save_rxekvb IS INITIAL.
        PERFORM verband.
      ENDIF.
      IF xkausg IS INITIAL.
        PERFORM posten.
*       PERFORM POSTEN_BEARBEITEN.
*         IF NOT KNB1-KNRZE IS INITIAL.
*           PERFORM FILIALE.
*         ELSE.
        IF save_rxekvb IS INITIAL.
          PERFORM zentrale.
        ENDIF.
*         ENDIF.
*-------Abarbeiten normaler Debitor bzw. Zentrale-----------------------
        CLEAR didlines.
        CLEAR doplines.
        CLEAR dmplines.
        DESCRIBE TABLE hbsid LINES didlines.
        DESCRIBE TABLE dopos LINES doplines.
        DESCRIBE TABLE dmpos LINES dmplines.
*         CLEAR ABSID.
*         REFRESH ABSID.
*         CLEAR ADOPO.
*         REFRESH ADOPO.
*         CLEAR ADMPO.
*         REFRESH ADMPO.
*         IF DIDLINES GT 0
*         OR DOPLINES GT 0
*         OR DMPLINES GT 0.
*           LOOP AT HBSID.
*             MOVE-CORRESPONDING HBSID TO ABSID.
*             APPEND ABSID.
*           ENDLOOP.
*           LOOP AT DOPOS.
*             MOVE-CORRESPONDING DOPOS TO ADOPO.
*             APPEND ADOPO.
*           ENDLOOP.
*           LOOP AT DMPOS.
*             MOVE-CORRESPONDING DMPOS TO ADMPO.
*             APPEND ADMPO.
*           ENDLOOP.
*         ENDIF.
        CLEAR untyp.
*         PERFORM FIND_EMPFAENGER_ADRESSE.
        PERFORM save_empfaenger_adresse.
        PERFORM find_sachbearbeiter.
        IF didlines GT 0
        OR doplines GT 0
        OR dmplines GT 0.
          SORT hbsid BY sortp1 sortp2 sortp3 sortp4 sortp5.
          SORT dopos BY sortp1 sortp2 sortp3 sortp4 sortp5.
          SORT dmpos BY sortp1 sortp2 sortp3 sortp4 sortp5.

*           CASE PSORT.
*             WHEN  '1'.
*               SORT HBSID BY AUGDT AUGBL BLDAT HXBLN.
*               SORT DOPOS BY BLDAT HXBLN BUZEI.
*               SORT DMPOS BY BLDAT HXBLN BUZEI.
*             WHEN  '2'.
*               SORT HBSID BY AUGDT AUGBL BLDAT HXBLN.
*               SORT DOPOS BY UMSKZ BLDAT HXBLN BUZEI.
*               SORT DMPOS BY UMSKZ BLDAT HXBLN BUZEI.
*             WHEN  '3'.
*               SORT HBSID BY AUGDT AUGBL BLDAT HXBLN.
*               SORT DOPOS BY BLDAT BELNR BUZEI.
*               SORT DMPOS BY BLDAT BELNR BUZEI.
*             WHEN  '4'.
*               SORT HBSID BY AUGDT AUGBL BLDAT HXBLN.
*               SORT DOPOS BY BLDAT XBLNR BUZEI.
*               SORT DMPOS BY BLDAT XBLNR BUZEI.
*           ENDCASE.
        ENDIF.
        PERFORM fill_bkorm.

***<<<pdf-enabling
        PERFORM check_output.                               "N854148
        PERFORM form_open_pdf.
        PERFORM ausgabe_customer_stat_pdf.
*        PERFORM form_close_pdf.
* not necessary (paymo is transfered directly to the form)
*        PERFORM paymed_print_openclose.
***>>>pdf-enabling

      ENDIF.
*-------Abarbeiten dezentrale Filialen----------------------------------
*       CLEAR DIDLINES.
*       CLEAR DOPLINES.
*       DESCRIBE TABLE FBSID LINES DIDLINES.
*       DESCRIBE TABLE DFOPO LINES DOPLINES.
*       IF DIDLINES GT 0
*       OR DOPLINES GT 0.
*         CLEAR SAVE2_KUNNR.
*         CLEAR SAVE2_BUKRS.
*         WHILE XENDE NE 'X'.
*           LOOP AT FBSID.
*             IF FBSID-BEARB = ' ' AND XSATZ IS INITIAL.
*               SAVE2_KUNNR = FBSID-FILKD.
*               XSATZ = 'X'.
*               CLEAR   ABSID.
*               REFRESH ABSID.
*               CLEAR   ADOPO.
*               REFRESH ADOPO.
*               IF NOT SAVE2_KUNNR IS INITIAL.
*                 LOOP AT DFOPO
*                   WHERE FILKD = SAVE2_KUNNR.
*                   MOVE-CORRESPONDING DFOPO TO ADOPO.
*                   APPEND ADOPO.
*                   DFOPO-BEARB = 'X'.
*                   MODIFY DFOPO.
*                 ENDLOOP.
*               ENDIF.
*             ENDIF.
*             IF NOT SAVE2_KUNNR IS INITIAL.
*               IF FBSID-FILKD = SAVE2_KUNNR.
*                 MOVE-CORRESPONDING FBSID TO ABSID.
*                 APPEND ABSID.
*                 FBSID-BEARB = 'X'.
*                 MODIFY FBSID.
*               ELSE.
*                 EXIT.
*               ENDIF.
*             ENDIF.
*           ENDLOOP.
*
*           IF NOT XSATZ IS INITIAL.
*             UNTYP = 'F'.
*             PERFORM FIND_EMPFAENGER_ADRESSE.
*             PERFORM SAVE_EMPFAENGER_ADRESSE.
*             PERFORM FIND_SACHBEARBEITER.
*             PERFORM SAVE_ZENTRALE_ADRESSE.
*             CASE PSORT.
*               WHEN  '1'.
*                 SORT ABSID BY BLDAT.
*                 SORT ADOPO BY BLDAT.
*               WHEN  '2'.
*                 SORT ABSID BY UMSKZ BLDAT.
*                 SORT ADOPO BY UMSKZ BLDAT.
*             ENDCASE.
*             PERFORM AUSGABE_CUSTOMER_STAT.
*             CLEAR UNTYP.
*             CLEAR ADRZE.
*           ELSE.
*             XENDE = 'X'.
*           ENDIF.
*
*           CLEAR SAVE2_KUNNR.
*           CLEAR XSATZ.
*           CLEAR ABSID.
*           REFRESH ABSID.
*         ENDWHILE.
*         CLEAR SAVE2_KUNNR.
**        CLEAR SAVE2_BUKRS.
*         WHILE XENDE NE 'X'.
*           LOOP AT DFOPO.
*             IF DFOPO-BEARB = ' ' AND XSATZ IS INITIAL.
*               SAVE2_KUNNR = DFOPO-FILKD.
*               XSATZ = 'X'.
*               CLEAR   ABSID.
*               REFRESH ABSID.
*               CLEAR   ADOPO.
*               REFRESH ADOPO.
*             ENDIF.
*             IF NOT SAVE2_KUNNR IS INITIAL.
*               IF DFOPO-FILKD = SAVE2_KUNNR.
*                 MOVE-CORRESPONDING DFOPO TO ADOPO.
*                 APPEND ADOPO.
*                 DFOPO-BEARB = 'X'.
*                 MODIFY DFOPO.
*               ELSE.
*                 EXIT.
*               ENDIF.
*             ENDIF.
*           ENDLOOP.
*
*           IF NOT XSATZ IS INITIAL.
*             UNTYP = 'F'.
**            XOPOS = 'X'.
*             PERFORM FIND_EMPFAENGER_ADRESSE.
**            CLEAR XOPOS.
*             PERFORM SAVE_EMPFAENGER_ADRESSE.
*             PERFORM FIND_SACHBEARBEITER.
*             PERFORM SAVE_ZENTRALE_ADRESSE.
*             CASE PSORT.
*               WHEN  '1'.
*                 SORT ABSID BY BLDAT.
*                 SORT ADOPO BY BLDAT.
*               WHEN  '2'.
*                 SORT ABSID BY UMSKZ BLDAT.
*                 SORT ADOPO BY UMSKZ BLDAT.
*             ENDCASE.
*             PERFORM AUSGABE_CUSTOMER_STAT.
*             CLEAR UNTYP.
*             CLEAR ADRZE.
*           ELSE.
*             XENDE = 'X'.
*           ENDIF.
*
*           CLEAR SAVE2_KUNNR.
*           CLEAR XSATZ.
*           CLEAR ABSID.
*           REFRESH ABSID.
*           CLEAR ADOPO.
*           REFRESH ADOPO.
*         ENDWHILE.
*       ENDIF.
    ELSE.
      CLEAR fimsg.
      fimsg-msort = '    '. fimsg-msgid = 'FB'.
      fimsg-msgty = 'I'.
      fimsg-msgno = '812'.
      fimsg-msgv1 = hdkoart.
      fimsg-msgv2 = hdkonto.
      PERFORM message_append.
      xkausg = 'X'.
    ENDIF.
  ELSE.
    CLEAR save_lifnr.
    save_lifnr = hdkonto.
    PERFORM read_lfa1.
    IF sy-subrc NE 0.
      xkausg = 'X'.
    ENDIF.
    IF lfa1-xcpdk IS INITIAL.
      PERFORM read_lfb1.
      IF sy-subrc NE 0.
        xkausg = 'X'.
      ENDIF.
      IF      save_rxekvb IS INITIAL
      AND NOT save_rxdezv IS INITIAL
      AND NOT lfb1-lnrze  IS INITIAL.
        save2_bukrs = lfb1-bukrs.
        save2_lifnr = lfb1-lnrze.
        PERFORM read_lfb1_2.
        IF sy-subrc NE 0.
          xkausg = 'X'.
        ENDIF.
      ENDIF.
      IF  NOT save_rxverr IS INITIAL
      AND NOT lfa1-kunnr  IS INITIAL
      AND NOT lfb1-xverr  IS INITIAL.
        xkausg = 'X'.
      ENDIF.
      IF xkausg IS INITIAL.
        PERFORM posten.
*       PERFORM POSTEN_BEARBEITEN.
*         IF NOT LFB1-LNRZE IS INITIAL.
*           PERFORM FILIALE.
*         ELSE.
        PERFORM zentrale.
*         ENDIF.
*-------Abarbeiten normaler Debitor bzw. Zentrale-----------------------
        CLEAR kiklines.
        CLEAR koplines.
        CLEAR kmplines.
        DESCRIBE TABLE hbsik LINES kiklines.
        DESCRIBE TABLE kopos LINES koplines.
        DESCRIBE TABLE kmpos LINES kmplines.
*         CLEAR ABSIK.
*         REFRESH ABSIK.
*         CLEAR AKOPO.
*         REFRESH AKOPO.
*         CLEAR AKMPO.
*         REFRESH AKMPO.
*         IF KIKLINES GT 0
*         OR KOPLINES GT 0
*         OR KMPLINES GT 0.
*           LOOP AT HBSIK.
*             MOVE-CORRESPONDING HBSIK TO ABSIK.
*             APPEND ABSIK.
*           ENDLOOP.
*           LOOP AT KOPOS.
*             MOVE-CORRESPONDING KOPOS TO AKOPO.
*             APPEND AKOPO.
*           ENDLOOP.
*           LOOP AT KMPOS.
*             MOVE-CORRESPONDING KMPOS TO AKMPO.
*             APPEND AKMPO.
*           ENDLOOP.
*         ENDIF.
        CLEAR untyp.
*         PERFORM FIND_EMPFAENGER_ADRESSE.
        PERFORM save_empfaenger_adresse.
        PERFORM find_sachbearbeiter.
        IF kiklines GT 0
        OR koplines GT 0
        OR kmplines GT 0.
          SORT hbsik BY sortp1 sortp2 sortp3 sortp4 sortp5.
          SORT kopos BY sortp1 sortp2 sortp3 sortp4 sortp5.
          SORT kmpos BY sortp1 sortp2 sortp3 sortp4 sortp5.

*           CASE PSORT.
*             WHEN  '1'.
*               SORT HBSIK BY AUGDT AUGBL BLDAT HXBLN.
*               SORT KOPOS BY BLDAT HXBLN BUZEI.
*               SORT KMPOS BY BLDAT HXBLN BUZEI.
*             WHEN  '2'.
*               SORT HBSIK BY AUGDT AUGBL BLDAT HXBLN.
*               SORT KOPOS BY UMSKZ BLDAT HXBLN BUZEI.
*               SORT KMPOS BY UMSKZ BLDAT HXBLN BUZEI.
*             WHEN  '3'.
*               SORT HBSIK BY AUGDT AUGBL BLDAT HXBLN.
*               SORT KOPOS BY BLDAT BELNR BUZEI.
*               SORT KMPOS BY BLDAT BELNR BUZEI.
*             WHEN  '4'.
*               SORT HBSIK BY AUGDT AUGBL BLDAT HXBLN.
*               SORT KOPOS BY BLDAT XBLNR BUZEI.
*               SORT KMPOS BY BLDAT XBLNR BUZEI.
*           ENDCASE.
        ENDIF.
        PERFORM fill_bkorm.

***<<<pdf-enabling
        PERFORM check_output.                               "N854148
        PERFORM form_open_pdf.
        PERFORM ausgabe_customer_stat_pdf.
*        PERFORM form_close_pdf.
* not necessary (paymo is transfered directly to the form)
*        PERFORM paymed_print_openclose.
***>>>pdf-enabling

      ENDIF.
*-------Abarbeiten dezentrale Filialen----------------------------------
*       CLEAR KIKLINES.
*       CLEAR KOPLINES.
*       DESCRIBE TABLE FBSIK LINES KIKLINES.
*       DESCRIBE TABLE KFOPO LINES KOPLINES.
*       IF KIKLINES GT 0
*       OR KOPLINES GT 0.
*         CLEAR SAVE2_LIFNR.
**        CLEAR SAVE2_BUKRS.
*         WHILE XENDE NE 'X'.
*           LOOP AT FBSIK.
*             IF FBSIK-BEARB = ' ' AND XSATZ IS INITIAL.
*               SAVE2_LIFNR = FBSIK-FILKD.
*               XSATZ = 'X'.
*               CLEAR   ABSIK.
*               REFRESH ABSIK.
*               CLEAR   AKOPO.
*               REFRESH AKOPO.
*               IF NOT SAVE2_LIFNR IS INITIAL.
*                 LOOP AT KFOPO
*                   WHERE FILKD = SAVE2_LIFNR.
*                   MOVE-CORRESPONDING KFOPO TO AKOPO.
*                   APPEND AKOPO.
*                   KFOPO-BEARB = 'X'.
*                   MODIFY KFOPO.
*                 ENDLOOP.
*               ENDIF.
*             ENDIF.
*             IF NOT SAVE2_LIFNR IS INITIAL.
*               IF FBSID-FILKD = SAVE2_LIFNR.
*                 MOVE-CORRESPONDING FBSIK TO ABSIK.
*                 APPEND ABSIK.
*                 FBSIK-BEARB = 'X'.
*                 MODIFY FBSIK.
*               ELSE.
*                 EXIT.
*               ENDIF.
*             ENDIF.
*           ENDLOOP.
*
*           IF NOT XSATZ IS INITIAL.
*             UNTYP = 'F'.
*             PERFORM FIND_EMPFAENGER_ADRESSE.
*             PERFORM SAVE_EMPFAENGER_ADRESSE.
*             PERFORM FIND_SACHBEARBEITER.
*             PERFORM SAVE_ZENTRALE_ADRESSE.
*             CASE PSORT.
*               WHEN  '1'.
*                 SORT ABSIK BY BLDAT.
*                 SORT AKOPO BY BLDAT.
*               WHEN  '2'.
*                 SORT ABSIK BY UMSKZ BLDAT.
*                 SORT AKOPO BY UMSKZ BLDAT.
*             ENDCASE.
*             PERFORM AUSGABE_CUSTOMER_STAT.
*             CLEAR UNTYP.
*             CLEAR ADRZE.
*           ELSE.
*             XENDE = 'X'.
*           ENDIF.
*
*           CLEAR SAVE2_LIFNR.
*           CLEAR XSATZ.
*           CLEAR ABSIK.
*           REFRESH ABSIK.
*         ENDWHILE.
*         CLEAR SAVE2_LIFNR.
*         CLEAR SAVE2_BUKRS.
*         WHILE XENDE NE 'X'.
*           LOOP AT KFOPO.
*             IF KFOPO-BEARB = ' ' AND XSATZ IS INITIAL.
*               SAVE2_LIFNR = KFOPO-FILKD.
*               XSATZ = 'X'.
*               CLEAR   ABSIK.
*               REFRESH ABSIK.
*               CLEAR   AKOPO.
*               REFRESH AKOPO.
*             ENDIF.
*             IF NOT SAVE2_LIFNR IS INITIAL.
*               IF KFOPO-FILKD = SAVE2_LIFNR.
*                 MOVE-CORRESPONDING KFOPO TO AKOPO.
*                 APPEND AKOPO.
*                 KFOPO-BEARB = 'X'.
*                 MODIFY KFOPO.
*               ELSE.
*                 EXIT.
*               ENDIF.
*             ENDIF.
*           ENDLOOP.
*
*           IF NOT XSATZ IS INITIAL.
*             UNTYP = 'F'.
**            XOPOS = 'X'.
*             PERFORM FIND_EMPFAENGER_ADRESSE.
**            CLEAR XOPOS.
*             PERFORM SAVE_EMPFAENGER_ADRESSE.
*             PERFORM FIND_SACHBEARBEITER.
*             PERFORM SAVE_ZENTRALE_ADRESSE.
*             CASE PSORT.
*               WHEN  '1'.
*                 SORT ABSIK BY BLDAT.
*                 SORT AKOPO BY BLDAT.
*               WHEN  '2'.
*                 SORT ABSIK BY UMSKZ BLDAT.
*                 SORT AKOPO BY UMSKZ BLDAT.
*             ENDCASE.
*             PERFORM AUSGABE_CUSTOMER_STAT.
*             CLEAR UNTYP.
*             CLEAR ADRZE.
*           ELSE.
*             XENDE = 'X'.
*           ENDIF.
*
*           CLEAR SAVE2_LIFNR.
*           CLEAR XSATZ.
*           CLEAR ABSIK.
*           REFRESH ABSIK.
*           CLEAR AKOPO.
*           REFRESH AKOPO.
*         ENDWHILE.
*       ENDIF.
    ELSE.
      CLEAR fimsg.
      fimsg-msort = '    '. fimsg-msgid = 'FB'.
      fimsg-msgty = 'I'.
      fimsg-msgno = '812'.
      fimsg-msgv1 = hdkoart.
      fimsg-msgv2 = hdkonto.
      PERFORM message_append.
      xkausg = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                    "ANALYSE_UND_AUSGABE

*-----------------------------------------------------------------------
*       FORM CFAKTOR
*-----------------------------------------------------------------------
FORM cfaktor.
  IF t001-waers NE tcurx-currkey.
    SELECT SINGLE * FROM tcurx WHERE currkey = t001-waers.
    IF sy-subrc NE 0.
      tcurx-currkey = t001-waers.
      cfakt = 100.
    ELSE.
      cfakt = 1.
      DO tcurx-currdec TIMES.
        cfakt = cfakt * 10.
      ENDDO.
    ENDIF.
  ENDIF.
ENDFORM.                    "CFAKTOR

*-----------------------------------------------------------------------
*       FORM CHECK_EINGABE
*-----------------------------------------------------------------------
FORM check_eingabe.
  DESCRIBE TABLE rerldt LINES erllines.
  IF NOT erllines IS INITIAL.
    IF  erllines    = '1'
    AND rerldt-low  IS INITIAL
    AND rerldt-high IS INITIAL.
      CLEAR xerdt.
    ELSE.
      xerdt = 'X'.
    ENDIF.
  ELSE.
    CLEAR xerdt.
  ENDIF.
  IF NOT rxtsub   IS INITIAL.
    print = 'X'.
  ELSE.
    IF sy-batch IS INITIAL.
      IF sscrfields-ucomm EQ 'PRIN'.   "no difference between starting
        sscrfields-ucomm = 'ONLI'.     "with F8 or F13
*     IF SY-UCOMM = 'PRIN'.
*       SY-UCOMM = 'ONLI'.
        print = 'X'.
        xonli = 'X'.
      ENDIF.
    ELSE.
*     IF SY-UCOMM = 'PRIN'.
      print = 'X'.
*     ENDIF.
    ENDIF.

    IF    NOT sy-batch IS INITIAL
    OR  (     sy-batch IS INITIAL
    AND   (   sscrfields-ucomm = 'PRIN'
    OR        sscrfields-ucomm = 'ONLI' ) ).
*   AND   (   SY-UCOMM = 'PRIN'
*   OR        SY-UCOMM = 'ONLI' ) ).

      IF rxbkor IS INITIAL.
        IF  budat01 IS INITIAL
        AND budat02 IS INITIAL.
          IF sy-batch IS INITIAL.
            SET CURSOR FIELD 'BUDAT01'.
          ENDIF.
          MESSAGE e453.
        ENDIF.

        IF  budat01 IS INITIAL.
          IF sy-batch IS INITIAL.
            SET CURSOR FIELD 'BUDAT01'.
          ENDIF.
          MESSAGE e456.
        ENDIF.

        IF  NOT  budat01 IS INITIAL
        AND NOT  budat02 IS INITIAL.
          IF budat01 GT budat02.
            IF sy-batch IS INITIAL.
              SET CURSOR FIELD 'BUDAT01'.
            ENDIF.
            MESSAGE e454.
          ENDIF.
        ENDIF.

        IF NOT rxopol IS INITIAL.
          IF NOT budat02 IS INITIAL.
            IF sy-batch IS INITIAL.
              SET CURSOR FIELD 'BUDAT02'.
            ENDIF.
            MESSAGE e455.
          ENDIF.
        ENDIF.

        IF rxopol IS INITIAL.
          IF budat02 IS INITIAL.
            IF sy-batch IS INITIAL.
              SET CURSOR FIELD 'BUDAT02'.
            ENDIF.
            MESSAGE e549.
          ENDIF.
        ENDIF.
      ELSE.
        IF  NOT budat01 IS INITIAL
        OR  NOT budat02 IS INITIAL.
          IF sy-batch IS INITIAL.
            SET CURSOR FIELD 'BUDAT01'.
          ENDIF.
          MESSAGE e477.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF    NOT sy-batch IS INITIAL
  OR  (     sy-batch IS INITIAL
* AND   (   SY-UCOMM = 'PRIN'
* OR        SY-UCOMM = 'ONLI' ) ).
  AND   (   sscrfields-ucomm = 'PRIN'
  OR        sscrfields-ucomm = 'ONLI' ) ).

    IF sortvk IS INITIAL.
      IF sy-batch IS INITIAL.
        SET CURSOR FIELD 'SORTVK'.
      ENDIF.
      MESSAGE e830.
    ELSE.
      SELECT SINGLE * FROM t021m
        WHERE progn = 'RFKORD*'
        AND   anwnd = 'KORK'
        AND   srvar = sortvk.
      IF sy-subrc NE 0.
        IF sy-batch IS INITIAL.
          SET CURSOR FIELD 'SORTVK'.
        ENDIF.
        MESSAGE e832 WITH sortvk.
      ENDIF.
    ENDIF.

    IF sortvp IS INITIAL.
      IF sy-batch IS INITIAL.
        SET CURSOR FIELD 'SORTVP'.
      ENDIF.
      MESSAGE e831.
    ELSE.
      SELECT SINGLE * FROM t021m
        WHERE progn = 'RFKORD*'
        AND   anwnd = 'KORP'
        AND   srvar = sortvp.
      IF sy-subrc NE 0.
        IF sy-batch IS INITIAL.
          SET CURSOR FIELD 'SORTVP'.
        ENDIF.
        MESSAGE e833 WITH sortvp.
      ENDIF.
    ENDIF.

    IF sortvp2 IS INITIAL.
      IF rxopol IS INITIAL.
        IF sy-batch IS INITIAL.
          SET CURSOR FIELD 'SORTVP2'.
        ENDIF.
        MESSAGE e831.
      ENDIF.
    ELSE.
      SELECT SINGLE * FROM t021m
        WHERE progn = 'RFKORD*'
        AND   anwnd = 'KORP'
        AND   srvar = sortvp2.
      IF sy-subrc NE 0.
        IF sy-batch IS INITIAL.
          SET CURSOR FIELD 'SORTVP2'.
        ENDIF.
        MESSAGE e833 WITH sortvp2.
      ENDIF.
    ENDIF.

    IF      rxopol IS INITIAL
    AND NOT rxdezv IS INITIAL.
      IF sy-batch IS INITIAL.
        SET CURSOR FIELD 'RXDEZV'.
      ENDIF.
      MESSAGE e615.
    ENDIF.

    IF  NOT  vstid IS INITIAL
    AND NOT dvstid IS INITIAL.
      IF sy-batch IS INITIAL.
        SET CURSOR FIELD 'VSTID'.
      ENDIF.
      MESSAGE e457.
    ENDIF.

    IF NOT rart-net IS INITIAL
    OR NOT rart-sk1 IS INITIAL
    OR NOT rart-sk2 IS INITIAL
    OR NOT rart-ueb IS INITIAL
    OR NOT rart-alt IS INITIAL
    OR NOT rvztag   IS INITIAL.
      IF  vstid IS INITIAL
      AND dvstid IS INITIAL.
        IF sy-batch IS INITIAL.
          SET CURSOR FIELD 'DVSTID'.
        ENDIF.
        MESSAGE e524.
      ENDIF.
    ENDIF.

    IF rastbis1 GT '998'
    OR rastbis2 GT '998'
    OR rastbis3 GT '998'
    OR rastbis4 GT '998'
    OR rastbis5 GT '998'.
      IF sy-batch IS INITIAL.
        SET CURSOR FIELD 'RASTBIS1'.
      ENDIF.
      MESSAGE e816.
    ENDIF.

    IF NOT rastbis5 IS INITIAL.
      IF  rastbis5 GT rastbis4
      AND rastbis4 GT rastbis3
      AND rastbis3 GT rastbis2
      AND rastbis2 GT rastbis1.
      ELSE.
        MESSAGE e817.
      ENDIF.
    ELSE.
      IF NOT rastbis4 IS INITIAL.
        IF  rastbis4 GT rastbis3
        AND rastbis3 GT rastbis2
        AND rastbis2 GT rastbis1.
        ELSE.
          MESSAGE e817.
        ENDIF.
      ELSE.
        IF NOT rastbis3 IS INITIAL.
          IF  rastbis3 GT rastbis2
          AND rastbis2 GT rastbis1.
          ELSE.
            MESSAGE e817.
          ENDIF.
        ELSE.
          IF NOT rastbis2 IS INITIAL.
            IF  rastbis2 GT rastbis1.
            ELSE.
              MESSAGE e817.
            ENDIF.
          ELSE.
*         nichts zu tun
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

*   IF  NOT RXOPOL IS INITIAL
*   AND NOT RXOPOS IS INITIAL.
*     IF SY-BATCH IS INITIAL.
*       SET CURSOR FIELD 'RXOPOS'.
*     ENDIF.
*     MESSAGE E   .
*   ENDIF.

*   IF      RXOPOL IS INITIAL
*   AND     RXOPOS IS INITIAL.
*     IF SY-BATCH IS INITIAL.
*       SET CURSOR FIELD 'RXOPOS'.
*     ENDIF.
*     MESSAGE E   .
*   ENDIF.

    IF rxbkor IS INITIAL.
      IF sy-batch IS INITIAL.
        IF  NOT rindko IS INITIAL
        AND rspras IS INITIAL.
*         IF SY-BATCH IS INITIAL.
          SET CURSOR FIELD 'RSPRAS'.
*         ENDIF.
          MESSAGE e490.
        ENDIF.
      ELSE.
        IF  NOT rindko IS INITIAL.
          MESSAGE e499.
        ENDIF.
      ENDIF.
*     IF  NOT REVENT IS INITIAL
*     AND RINDKO IS INITIAL.
*       IF SY-BATCH IS INITIAL.
*         SET CURSOR FIELD 'REVENT'.
*       ENDIF.
*       MESSAGE W451.
*     ENDIF.
      IF revent IS INITIAL.
        IF sy-batch IS INITIAL.
          SET CURSOR FIELD 'REVENT'.
        ENDIF.
        MESSAGE e450.
      ENDIF.
      DESCRIBE TABLE rerldt LINES erllines.
      IF NOT erllines IS INITIAL.
        IF sy-batch IS INITIAL.
          SET CURSOR FIELD 'RERLDT-LOW'.
        ENDIF.
        MESSAGE w452.
      ENDIF.
      DESCRIBE TABLE rusnam LINES usrlines.
      IF NOT usrlines IS INITIAL.
        IF sy-batch IS INITIAL.
          SET CURSOR FIELD 'RUSNAM-LOW'.
        ENDIF.
        MESSAGE w478.
      ENDIF.
      DESCRIBE TABLE rdatum LINES datlines.
      IF NOT datlines IS INITIAL.
        IF sy-batch IS INITIAL.
          SET CURSOR FIELD 'RDATUM-LOW'.
        ENDIF.
        MESSAGE w479.
      ENDIF.
      DESCRIBE TABLE ruzeit LINES timlines.
      IF NOT timlines IS INITIAL.
        IF sy-batch IS INITIAL.
          SET CURSOR FIELD 'RUZEIT-LOW'.
        ENDIF.
        MESSAGE w480.
      ENDIF.
    ELSE.
      IF  NOT rindko IS INITIAL
      AND NOT rspras IS INITIAL.
        IF sy-batch IS INITIAL.
          SET CURSOR FIELD 'RSPRAS'.
        ENDIF.
        MESSAGE e491.
      ENDIF.

      IF revent IS INITIAL.
        IF sy-batch IS INITIAL.
          SET CURSOR FIELD 'REVENT'.
        ENDIF.
        MESSAGE e450.
      ENDIF.

      IF NOT revent IS INITIAL.
        CLEAR t048.
        SELECT SINGLE * FROM t048
          WHERE event = revent.

        IF sy-subrc =  0.
          CASE t048-anzdt.
            WHEN '0'.
              IF sy-batch IS INITIAL.
                SET CURSOR FIELD 'REVENT'.
              ENDIF.
              MESSAGE e461 WITH revent.
            WHEN OTHERS.
              IF NOT t048-xbelg IS INITIAL.
                IF sy-batch IS INITIAL.
                  SET CURSOR FIELD 'REVENT'.
                ENDIF.
                MESSAGE e464 WITH revent.
              ENDIF.
          ENDCASE.
        ELSE.
          IF sy-batch IS INITIAL.
            SET CURSOR FIELD 'REVENT'.
          ENDIF.
          MESSAGE e460 WITH revent.
        ENDIF.
      ENDIF.

      IF NOT rspras IS INITIAL.
        IF sy-batch IS INITIAL.
          SET CURSOR FIELD 'RSPRAS'.
        ENDIF.
        MESSAGE e491.
      ENDIF.
    ENDIF.

    IF  NOT rindko IS INITIAL
    AND revent IS INITIAL.
      IF sy-batch IS INITIAL.
        SET CURSOR FIELD 'REVENT'.
      ENDIF.
      MESSAGE e450.
    ENDIF.

    IF  NOT rindko IS INITIAL
    AND NOT revent IS INITIAL.
      IF t048-event NE revent.
        SELECT SINGLE * FROM t048
          WHERE event = revent.
        IF sy-subrc NE 0.
          IF sy-batch IS INITIAL.
            SET CURSOR FIELD 'REVENT'.
          ENDIF.
          MESSAGE e460 WITH revent.
        ENDIF.
      ENDIF.
      IF t048-xspra IS INITIAL.
        IF sy-batch IS INITIAL.
          SET CURSOR FIELD 'RINDKO'.
        ENDIF.
        MESSAGE e500 WITH revent.
      ENDIF.
    ENDIF.

    IF  rindko IS INITIAL
    AND NOT revent IS INITIAL.
      IF t048-event NE revent.
        SELECT SINGLE * FROM t048
          WHERE event = revent.
        IF sy-subrc NE 0.
          IF sy-batch IS INITIAL.
            SET CURSOR FIELD 'REVENT'.
          ENDIF.
          MESSAGE e460 WITH revent.
        ENDIF.
      ENDIF.
      IF NOT t048-xspra IS INITIAL.
        IF sy-batch IS INITIAL.
          SET CURSOR FIELD 'RINDKO'.
        ENDIF.
        MESSAGE e501 WITH revent.
      ENDIF.
    ENDIF.

*   IF  NOT RXKNUS IS INITIAL
*   AND NOT RXOPOL IS INITIAL
*   AND NOT RXKPOS IS INITIAL.
*     IF SY-BATCH IS INITIAL.
*       SET CURSOR FIELD 'RXKNUS'.
*     ENDIF.
*     MESSAGE E502.
*   ENDIF.

    IF NOT tddest IS INITIAL.
      SELECT SINGLE * FROM tsp03
        WHERE padest EQ tddest.
      IF sy-subrc NE 0.
        IF sy-batch IS INITIAL.
          SET CURSOR FIELD 'TDDEST'.
        ENDIF.
        MESSAGE e441 WITH tddest.
      ENDIF.
    ENDIF.

  ENDIF.
  IF rxtsub IS INITIAL.
    DESCRIBE TABLE rdatum LINES datlines.
    IF NOT datlines IS INITIAL.
      PERFORM check_date.
    ENDIF.
    DESCRIBE TABLE ruzeit LINES timlines.
    IF NOT timlines IS INITIAL.
      PERFORM check_time.
    ENDIF.
  ENDIF.
ENDFORM.                    "CHECK_EINGABE

*-----------------------------------------------------------------------
*       FORM DEBITOREN_DATEN
*-----------------------------------------------------------------------
FORM debitoren_daten.
  IF xopos IS INITIAL.
    IF xmpos IS INITIAL.
      MOVE hbsid-filkd TO save2_kunnr.
      MOVE hbsid-bukrs TO save2_bukrs.
    ELSE.
      MOVE dmpos-filkd TO save2_kunnr.
      MOVE dmpos-bukrs TO save2_bukrs.
    ENDIF.
  ELSE.
    MOVE dopos-filkd TO save2_kunnr.
    MOVE dopos-bukrs TO save2_bukrs.
  ENDIF.
  LOOP AT hkna1
    WHERE kunnr = save2_kunnr.
    EXIT.
  ENDLOOP.
  IF sy-subrc NE 0.
    PERFORM read_kna1_2.
    MOVE-CORRESPONDING *kna1 TO hkna1.
    APPEND hkna1.
  ENDIF.
  LOOP AT hknb1
    WHERE kunnr = save2_kunnr
    AND   bukrs = save2_bukrs.
    EXIT.
  ENDLOOP.
  IF sy-subrc NE 0.
    PERFORM read_knb1_2.
    MOVE-CORRESPONDING *knb1 TO hknb1.
    APPEND hknb1.
  ENDIF.
ENDFORM.                    "DEBITOREN_DATEN

*-----------------------------------------------------------------------
*       FORM FIND_EMPFAENGER_ADRESSE
*-----------------------------------------------------------------------
FORM find_empfaenger_adresse.
* IF HDKOART = 'D'.
*   CLEAR *KNA1.
*   CLEAR *KNB1.
*
*   IF UNTYP = ' '.
*     *KNA1 = KNA1.
*     *KNB1 = KNB1.
*   ENDIF.
*   IF UNTYP = 'F'.
*     LOOP AT HKNA1
*       WHERE KUNNR = SAVE2_KUNNR.
*       MOVE-CORRESPONDING HKNA1 TO *KNA1.
*       EXIT.
*     ENDLOOP.
*     IF SY-SUBRC NE 0.
**      message
*     ENDIF.
*   ENDIF.
*     LOOP AT HKNB1
*       WHERE KUNNR = SAVE2_KUNNR
*       AND   BUKRS = SAVE_BUKRS.
*       MOVE-CORRESPONDING HKNB1 TO *KNB1.
*       EXIT.
*     ENDLOOP.
*     IF SY-SUBRC NE 0.
**      message
*     ENDIF.
* ELSE.
*   CLEAR *LFA1.
*   CLEAR *LFB1.
*
*   IF UNTYP = ' '.
*     *LFA1 = LFA1.
*     *LFB1 = LFB1.
*   ENDIF.
*   IF UNTYP = 'F'.
*     LOOP AT HLFA1
*       WHERE LIFNR = SAVE2_LIFNR.
*       MOVE-CORRESPONDING HLFA1 TO *LFA1.
*       EXIT.
*     ENDLOOP.
*     IF SY-SUBRC NE 0.
**      message
*     ENDIF.
*   ENDIF.
*     LOOP AT HLFB1
*       WHERE LIFNR = SAVE2_LIFNR
*       AND   BUKRS = SAVE_BUKRS.
*       MOVE-CORRESPONDING HLFB1 TO *LFB1.
*       EXIT.
*     ENDLOOP.
*     IF SY-SUBRC NE 0.
**      message
*     ENDIF.
* ENDIF.
ENDFORM.                    "FIND_EMPFAENGER_ADRESSE

*-----------------------------------------------------------------------
*       FORM FIND_SACHBEARBEITER
*-----------------------------------------------------------------------
FORM find_sachbearbeiter.
  CLEAR save_busab.
  IF hdkoart = 'D'.
    save_busab = knb1-busab.
  ELSE.
    save_busab = lfb1-busab.
  ENDIF.
* PERFORM READ_T001S.
ENDFORM.                    "FIND_SACHBEARBEITER

*-----------------------------------------------------------------------
*       FORM FILIALE
*-----------------------------------------------------------------------
*ORM FILIALE.
* CLEAR *KNB1.
* CLEAR *LFB1.
* IF HDKOART = 'D'.
*   SELECT SINGLE * FROM KNB1 INTO *KNB1
*     WHERE BUKRS = SAVE_BUKRS
*     AND   KUNNR = KNB1-KNRZE.
*-------nachlesen der offenen Posten bei Zentralen für dezentral--------
*-------verwaltete Filialen---------------------------------------------
*     IF NOT *KNB1-XDEZV IS INITIAL.
*       PERFORM READ_BSID_2.
*       PERFORM READ_BSAD_2.
*     ENDIF.
* ELSE.
*   SELECT SINGLE * FROM LFB1 INTO *LFB1
*     WHERE BUKRS = SAVE_BUKRS
*     AND   LIFNR = LFB1-LNRZE.
*     IF NOT *LFB1-XDEZV IS INITIAL.
*       PERFORM READ_BSIK_2.
*       PERFORM READ_BSAK_2.
*     ENDIF.
* ENDIF.
*NDFORM.

*----------------------------------------------------------------------*
* FORM FORM_CHECK
*----------------------------------------------------------------------*
FORM form_check.
  oldform = 'X'.
  LOOP AT htline
    WHERE tdformat = '/E'.
    IF htline-tdline(3) = '503'
    OR htline-tdline(3) = '504'.
      CLEAR oldform.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "FORM_CHECK

*----------------------------------------------------------------------*
* FORM FORM_START_AS
*----------------------------------------------------------------------*
FORM form_start_as.

  IF xopen = 'Y'.
    CLEAR form.
    IF  finaa-nacha = '2'
    AND NOT finaa-fornr IS INITIAL.
      form = finaa-fornr.
      save_form = finaa-fornr.
    ELSE.
      form = t001f-fornr.
      save_form = t001f-fornr.
    ENDIF.
    startpage = 'FIRST'.
    language = save_langu.
    flkform = 'Z'.
    CLEAR flspras.

    PERFORM form_start USING save_form language 'FIRST'.
*   CALL FUNCTION 'START_FORM'
*                    EXPORTING  FORM      = SAVE_FORM
*                               LANGUAGE  = LANGUAGE
*                               STARTPAGE = 'FIRST'
*                    IMPORTING  LANGUAGE  = LANGUAGE
*                    EXCEPTIONS FORM      = 5.
**                              UNENDED   = 7
**                              UNOPENED  = 3.
**                              IF SY-SUBRC = '3'.
**                                PERFORM MESSAGE_UNOPENED.
**                              ENDIF.
    IF sy-subrc = '5'.
      MESSAGE e229 WITH t001f-fornr
                        'FIRST'.
    ENDIF.
*                               IF SY-SUBRC = '7'.
*                                 PERFORM MESSAGE_UNENDED.
*                               ENDIF.
    IF sy-subrc = '0'.
      IF language NE save_langu.
*       IF SAVE_LANGU NE T001-SPRAS.
*         IF LANGUAGE NE T001-SPRAS.
*           PERFORM FORM_END.
*           LANGUAGE = T001-SPRAS.
*           CALL FUNCTION 'START_FORM'
*                            EXPORTING  FORM      = SAVE_FORM
*                                       LANGUAGE  = LANGUAGE
*                                       STARTPAGE = 'FIRST'
*                            IMPORTING  LANGUAGE  = LANGUAGE
*                            EXCEPTIONS FORM      = 5.
**                                      UNENDED   = 7
**                                      UNOPENED  = 3.
**                                    IF SY-SUBRC = '3'.
**                                      PERFORM MESSAGE_UNOPENED.
**                                    ENDIF.
*                                     IF SY-SUBRC = '5'.
**                                      MESSAGE E412 WITH KNB1-BUKRS.
*                                     ENDIF.
**                                    IF SY-SUBRC = '7'.
**                                      PERFORM MESSAGE_UNENDED.
**                                    ENDIF.
*
*                             IF SY-SUBRC = '0'.
*                               XSTART = 'J'.
*                               IF LANGUAGE NE T001-SPRAS.
*                                 FLSPRAS = 'A'.
**                                PERFORM MESSAGE_LANGUAGE.
*                               ELSE.
*                                 FLSPRAS = 'X'.
**                                PERFORM MESSAGE_LANGUAGE.
*                               ENDIF.
*                             ENDIF.
*         ELSE.
*           XSTART = 'J'.
*           FLSPRAS = 'X'.
**          PERFORM MESSAGE_LANGUAGE.
*         ENDIF.            "language <> t001
*       ELSE.
*         XSTART = 'J'.
*         FLSPRAS = 'A'.
**        PERFORM MESSAGE_LANGUAGE.
*       ENDIF.            "save_langu <> t001
        xstart = 'J'.                  "language <> save_langu
        flspras = 'X'.
        CLEAR fimsg.
        fimsg-msort = '    '. fimsg-msgid = 'FB'.
        fimsg-msgty = 'I'.
        fimsg-msgno = '559'.
        fimsg-msgv1 = save_form.
        fimsg-msgv2 = save_langu.
        fimsg-msgv3 = language.
        PERFORM message_append.
      ELSE.                            "language =  save_langu
        xstart = 'J'.
      ENDIF.                           "language <> save_langu
    ELSE.
      CLEAR xstart.
    ENDIF.                             "sy-subrc
  ENDIF.                               "xopen
ENDFORM.                    "FORM_START_AS

*-----------------------------------------------------------------------
*       FORM KONTO_ASSIGN
*-----------------------------------------------------------------------
FORM konto_assign.
  IF NOT rxekvb IS INITIAL.
    CASE hpkont.
      WHEN '1'.
        ASSIGN dopos-sortp1 TO <konto1>.
        ASSIGN kopos-sortp1 TO <konto2>.
        ASSIGN hbsid-sortp1 TO <konto3>.
        ASSIGN hbsik-sortp1 TO <konto4>.
        ASSIGN dmpos-sortp1 TO <konto5>.
        ASSIGN kmpos-sortp1 TO <konto6>.
      WHEN '2'.
        ASSIGN dopos-sortp2 TO <konto1>.
        ASSIGN kopos-sortp2 TO <konto2>.
        ASSIGN hbsid-sortp2 TO <konto3>.
        ASSIGN hbsik-sortp2 TO <konto4>.
        ASSIGN dmpos-sortp2 TO <konto5>.
        ASSIGN kmpos-sortp2 TO <konto6>.
      WHEN '3'.
        ASSIGN dopos-sortp3 TO <konto1>.
        ASSIGN kopos-sortp3 TO <konto2>.
        ASSIGN hbsid-sortp3 TO <konto3>.
        ASSIGN hbsik-sortp3 TO <konto4>.
        ASSIGN dmpos-sortp3 TO <konto5>.
        ASSIGN kmpos-sortp3 TO <konto6>.
      WHEN '4'.
        ASSIGN dopos-sortp4 TO <konto1>.
        ASSIGN kopos-sortp4 TO <konto2>.
        ASSIGN hbsid-sortp4 TO <konto3>.
        ASSIGN hbsik-sortp4 TO <konto4>.
        ASSIGN dmpos-sortp4 TO <konto5>.
        ASSIGN kmpos-sortp4 TO <konto6>.
      WHEN '5'.
        ASSIGN dopos-sortp5 TO <konto1>.
        ASSIGN kopos-sortp5 TO <konto2>.
        ASSIGN hbsid-sortp5 TO <konto3>.
        ASSIGN hbsik-sortp5 TO <konto4>.
        ASSIGN dmpos-sortp5 TO <konto5>.
        ASSIGN kmpos-sortp5 TO <konto6>.
    ENDCASE.
  ENDIF.
ENDFORM.                    "KONTO_ASSIGN

*-----------------------------------------------------------------------
*       FORM KONTOAUSZUEGE
*-----------------------------------------------------------------------
FORM kontoauszuege.

*-------Abarbeiten der extrahierten Daten-------------------------------
  LOOP.
    AT NEW hdbukrs.
      save_bukrs = hdbukrs.
      IF NOT rxtsub IS INITIAL.
        mbukrs = hdbukrs.
      ENDIF.
      PERFORM read_t001.
      PERFORM find_bukrs_adresse.
      PERFORM save_bukrs_adresse.      "für Formularausgabe
      PERFORM read_t001f.
***<<<pdf-enabling
*      CLEAR found.
*      PERFORM form_read USING t001f-fornr found.
*      IF NOT found IS INITIAL.
*        PERFORM form_check.
*      ENDIF.
***>>>pdf-enabling
      PERFORM read_t001g.
      CLEAR countp.
      IF NOT rsimul IS INITIAL.
        CLEAR   hbkorm.
        REFRESH hbkorm.
      ENDIF.
*     PERFORM FORM_OPEN.
      xknid = ' '.
      REFRESH ubukrs.
      IF NOT t048-xbukr IS INITIAL.
        CLEAR    dbukrs.
        REFRESH  dbukrs.

        CALL FUNCTION 'CORRESPONDENCE_GET_DEPEND_CC'
          EXPORTING
            i_bukrs = hdbukrs
          TABLES
            t_bukrs = dbukrs.

        LOOP AT dbukrs.
          lbukrs-low    = dbukrs-bukrs.
          lbukrs-option = 'EQ'.
          lbukrs-sign   = 'I'.
          APPEND lbukrs.
          lbukrs-low    = hdbukrs.
          lbukrs-option = 'EQ'.
          lbukrs-sign   = 'I'.
          COLLECT lbukrs.
        ENDLOOP.
      ELSE.
        ubukrs-low    = hdbukrs.
        ubukrs-option = 'EQ'.
        ubukrs-sign   = 'I'.
        APPEND  ubukrs.
      ENDIF.
    ENDAT.

    AT NEW hdkoart.
      save_koart = hdkoart.
    ENDAT.

    CLEAR xprint.

    IF  datum01 IS INITIAL
    AND datum02 IS INITIAL.
      CLEAR fimsg.
      fimsg-msort = '    '. fimsg-msgid = 'FB'.
      fimsg-msgty = 'I'.
      fimsg-msgno = '813'.
      PERFORM message_append.
      xkausg = 'X'.
    ELSE.
      IF rxopol IS INITIAL.            "Kontoauszug
        IF  ( datum01 IS INITIAL OR datum01 = space )
        AND NOT datum02 IS INITIAL.
          MOVE datum02 TO datum01.
        ENDIF.
        IF  ( datum02 IS INITIAL OR datum02 = space )
        AND NOT datum01 IS INITIAL.
          MOVE datum01 TO datum02.
        ENDIF.
        IF datum01 GT datum02.
          CLEAR fimsg.
          fimsg-msort = '    '. fimsg-msgid = 'FB'.
          fimsg-msgty = 'I'.
          fimsg-msgno = '814'.
          fimsg-msgv1 = datum01.
          fimsg-msgv2 = datum02.
          PERFORM message_append.
          xkausg = 'X'.
        ENDIF.
      ELSE.                            "OP-Liste
        IF datum01 IS INITIAL
        AND NOT datum02 IS INITIAL.
          MOVE datum02 TO datum01.
        ENDIF.
        datum02 = datum01.
        CLEAR refe1.
        refe1 = datum01.
        refe1 = refe1 + 1.
        datum01 = refe1.
      ENDIF.
    ENDIF.
    save2_datum = datum02.

*-------Felder für druck füllen-----------------------------------------
    IF rxopol IS INITIAL.
      rf140-datu1 = datum01.
      rf140-datu2 = datum02.
      refe1       = datum01.
      refe1       = refe1 - 1.
      rf140-stida = refe1.
      CLEAR refe1.
    ELSE.
      rf140-stida = datum02.
    ENDIF.

    IF NOT rindko IS INITIAL.
      CLEAR rf140-tdname.
      CLEAR rf140-tdid.
      CLEAR rf140-tdspras.
      rf140-tdname  = paramet+22(40).
      rf140-tdspras = paramet+62(1).
      save_langu    = paramet+62(1).
    ENDIF.

    IF NOT vstid IS INITIAL.
      rf140-vstid = vstid.
    ELSE.
      CASE dvstid.
        WHEN '1'.
          rf140-vstid = datum02.
        WHEN '2'.
          rf140-vstid = sy-datum.
      ENDCASE.
    ENDIF.

    CLEAR xkausg.

*-------Übergreifende Vorgänge------------------------------------------
    IF NOT t048-xbukr IS INITIAL.
      CLEAR    ubukrs.
      REFRESH  ubukrs.
      IF dabbukr IS INITIAL.
        ubukrs[] = lbukrs[].
      ELSE.
        ubukrs-low    = dabbukr.
        ubukrs-option = 'EQ'.
        ubukrs-sign   = 'I'.
        APPEND  ubukrs.
      ENDIF.
    ENDIF.

*-------Where-Bedingungen-----------------------------------------------
    PERFORM where_klausel.

*-------Analyse und Ausgabe---------------------------------------------
    PERFORM analyse_und_ausgabe.

*-------BKORM Fortschreibung--------------------------------------------
    IF NOT xbkorm IS INITIAL.
      IF rsimul IS INITIAL.
        PERFORM updata_bkorm.
      ELSE.
        PERFORM updata_bkorm_store.
      ENDIF.
    ELSE.
      PERFORM message_output.
    ENDIF.

    AT END OF hdbukrs.
*     PERFORM FORM_CLOSE.
      IF  NOT rsimul          IS INITIAL
      AND NOT itcpp-tddevice  IS INITIAL
      AND NOT itcpp-tdspoolid IS INITIAL.
        PERFORM updata_bkorm_2.
      ENDIF.
    ENDAT.
  ENDLOOP.
  PERFORM form_close_pdf.

  PERFORM delete_text.

  PERFORM message_check.
  IF sy-subrc = 0.
    PERFORM message_print.
  ENDIF.

  IF NOT rxtsub IS INITIAL.
    PERFORM prot_export.
  ELSE.
    IF rsimul IS INITIAL.
      save_proid = 'KORD'.
      PERFORM prot_print.
    ELSE.
      PERFORM prot_export.
    ENDIF.
  ENDIF.
ENDFORM.                    "KONTOAUSZUEGE

*-----------------------------------------------------------------------
*       FORM KREDITOREN_DATEN
*-----------------------------------------------------------------------
FORM kreditoren_daten.
  IF xopos IS INITIAL.
    IF xmpos IS INITIAL.
      MOVE hbsik-filkd TO save2_lifnr.
      MOVE hbsik-bukrs TO save2_bukrs.
    ELSE.
      MOVE kmpos-filkd TO save2_lifnr.
      MOVE kmpos-bukrs TO save2_bukrs.
    ENDIF.
  ELSE.
    MOVE kopos-filkd TO save2_lifnr.
    MOVE kopos-bukrs TO save2_bukrs.
  ENDIF.
  LOOP AT hlfa1
    WHERE lifnr = save2_lifnr.
    EXIT.
  ENDLOOP.
  IF sy-subrc NE 0.
    PERFORM read_lfa1_2.
    MOVE-CORRESPONDING *lfa1 TO hlfa1.
    APPEND hlfa1.
  ENDIF.
  LOOP AT hlfb1
    WHERE lifnr = save2_lifnr
    AND   bukrs = save2_bukrs.
    EXIT.
  ENDLOOP.
  IF sy-subrc NE 0.
    PERFORM read_lfb1_2.
    MOVE-CORRESPONDING *lfb1 TO hlfb1.
    APPEND hlfb1.
  ENDIF.
ENDFORM.                    "KREDITOREN_DATEN

*-----------------------------------------------------------------------
*       FORM NULLSALDO_PRUEFEN
*-----------------------------------------------------------------------
FORM nullsaldo_pruefen.
  CLEAR sldblines.
  DESCRIBE TABLE saldob LINES sldblines.
  IF sldblines GT '0'.
    xkausg = 'X'.
*   IF NOT RXKNUS IS INITIAL.
*     LOOP AT SALDOB.
*       IF SALDOB-SALDOW NE 0.
*         CLEAR XKAUSG.
*       ENDIF.
*     ENDLOOP.
*   ELSE.
    CLEAR hsaldo2.
    LOOP AT saldob.
      hsaldo2 = hsaldo2 + saldob-saldoh.
    ENDLOOP.
    PERFORM cfaktor.
    IF cfakt GT 0.
      checksaldo = hsaldo2 / cfakt.
    ELSE.
      checksaldo = hsaldo2.
    ENDIF.
*- Bei 0,xxx Werten wird immer auf-/abgerundet------------------------*
*- ansonsten wird kaufmännisch gerundet-------------------------------*
    IF  checksaldo =  0
    AND hsaldo2    NE 0.
      IF hsaldo2 GT 0.
        checksaldo = 1.
      ELSE.
        checksaldo = -1.
      ENDIF.
    ENDIF.
    IF checksaldo IN rsaldo.
      CLEAR xkausg.
    ENDIF.
*   ENDIF.
  ENDIF.
ENDFORM.                    "NULLSALDO_PRUEFEN

*-----------------------------------------------------------------------
*       FORM NULLSALDO_SUMME_1
*-----------------------------------------------------------------------
FORM nullsaldo_summe_1.
  CLEAR saldob.
  IF hdkoart = 'D'.
    saldob-waers = hbsid-pswsl.
    IF hbsid-shkzg = 'S'.
      saldob-saldoh = hbsid-dmbtr.
      saldob-saldow = hbsid-pswbt.
    ELSE.
      saldob-saldoh = 0 - hbsid-dmbtr.
      saldob-saldow = 0 - hbsid-pswbt.
    ENDIF.
  ELSE.
    saldob-waers = hbsik-pswsl.
    IF hbsik-shkzg = 'S'.
      saldob-saldoh = hbsik-dmbtr.
      saldob-saldow = hbsik-pswbt.
    ELSE.
      saldob-saldoh = 0 - hbsik-dmbtr.
      saldob-saldow = 0 - hbsik-pswbt.
    ENDIF.
  ENDIF.
  COLLECT saldob.
ENDFORM.                    "NULLSALDO_SUMME_1

*-----------------------------------------------------------------------
*       FORM NULLSALDO_SUMME_2
*-----------------------------------------------------------------------
FORM nullsaldo_summe_2.
  CLEAR saldob.
  IF hdkoart = 'D'.
    saldob-waers = hbsad-pswsl.
    IF hbsad-shkzg = 'S'.
      saldob-saldoh = hbsad-dmbtr.
      saldob-saldow = hbsad-pswbt.
    ELSE.
      saldob-saldoh = 0 - hbsad-dmbtr.
      saldob-saldow = 0 - hbsad-pswbt.
    ENDIF.
  ELSE.
    saldob-waers = hbsak-pswsl.
    IF hbsak-shkzg = 'S'.
      saldob-saldoh = hbsak-dmbtr.
      saldob-saldow = hbsak-pswbt.
    ELSE.
      saldob-saldoh = 0 - hbsak-dmbtr.
      saldob-saldow = 0 - hbsak-pswbt.
    ENDIF.
  ENDIF.
  COLLECT saldob.
ENDFORM.                    "NULLSALDO_SUMME_2

*-----------------------------------------------------------------------
*       FORM POSTEN
*-----------------------------------------------------------------------
FORM posten.
  CLEAR xzent.

  CLEAR   xmpos.
  CLEAR   dmpos.
  REFRESH dmpos.
  CLEAR   kmpos.
  REFRESH kmpos.
  CLEAR   dopos.
  REFRESH dopos.
  CLEAR   kopos.
  REFRESH kopos.
  CLEAR   rtab.
  REFRESH rtab.
* IF NOT RXKNUS IS INITIAL.
  CLEAR saldob.
  REFRESH saldob.
* ENDIF.

  IF hdkoart = 'D'.
    IF ( NOT save_rxekvb IS INITIAL )
    OR ( NOT  knb1-knrze IS INITIAL
    AND NOT *knb1-xdezv IS INITIAL
    AND NOT save_rxdezv IS INITIAL
    AND     save_rxekvb IS INITIAL ).
      CLEAR   hbsid.
      REFRESH hbsid.
      CLEAR save2_kunnr.
      CLEAR save2_lifnr.
    ENDIF.
    PERFORM read_bsid.
    IF NOT vorebl IS INITIAL.
      PERFORM read_vbsid.
    ENDIF.
    IF  NOT  knb1-knrze IS INITIAL
    AND NOT *knb1-xdezv IS INITIAL
    AND NOT save_rxdezv IS INITIAL
    AND     save_rxekvb IS INITIAL.
      save2_kunnr = save_kunnr.
      save_kunnr  = *knb1-kunnr.
      PERFORM read_bsid.
      IF NOT vorebl IS INITIAL.
        PERFORM read_vbsid.
      ENDIF.
      save_kunnr = save2_kunnr.
      CLEAR xzent.
    ENDIF.
    IF  NOT save_rxverr IS INITIAL
    AND NOT xverr       IS INITIAL.
      PERFORM read_bsik.
      IF NOT vorebl IS INITIAL.
        PERFORM read_vbsik.
      ENDIF.
      IF  NOT  lfb1-lnrze IS INITIAL
      AND NOT *lfb1-xdezv IS INITIAL
      AND NOT save_rxdezv IS INITIAL
      AND     save_rxekvb IS INITIAL.
        save2_lifnr = save_lifnr.
        save_lifnr  = *lfb1-lifnr.
        PERFORM read_bsik.
        IF NOT vorebl IS INITIAL.
          PERFORM read_vbsik.
        ENDIF.
        save_lifnr = save2_lifnr.
        CLEAR xzent.
      ENDIF.
    ENDIF.
    IF NOT save_rxekvb IS INITIAL.
      save2_kunnr = save_kunnr.
      LOOP AT filialen.
        save_kunnr = filialen-filiale.
        PERFORM read_bsid.
        IF NOT vorebl IS INITIAL.
          PERFORM read_vbsid.
        ENDIF.
      ENDLOOP.
      save_kunnr = save2_kunnr.
      CLEAR save2_kunnr.
    ENDIF.
    LOOP AT hbsid.
      save2_bukrs = hbsid-bukrs.
      save2_belnr = hbsid-belnr.
      save2_gjahr = hbsid-gjahr.
      save2_buzei = hbsid-buzei.
      CLEAR bkpf.
      MOVE-CORRESPONDING hbsid TO bkpf.
      MOVE-CORRESPONDING hbsid TO *bkpf.
      IF hbsid-bukrs NE *t001-bukrs.
        SELECT SINGLE * FROM t001 INTO *t001
          WHERE bukrs = hbsid-bukrs.
      ENDIF.
      alw_waers = bkpf-waers.
      PERFORM currency_get_subsequent
                  USING
                     save_repid_alw
                     datum02
                     bkpf-bukrs
                  CHANGING
                     alw_waers.
      IF alw_waers NE bkpf-waers.
        bkpf-waers = alw_waers.
      ENDIF.
*     PERFORM READ_BKPF_2.
*     IF SY-SUBRC NE 0.
*       XKAUSG = 'X'.
*     ENDIF.
      IF NOT hbsid-xzahl IS INITIAL
      OR     hbsid-pswsl IS INITIAL.
        IF hbsid-xarch IS INITIAL.
          PERFORM read_bseg_2.
        ELSE.
          PERFORM read_bseg_arc.
        ENDIF.
        IF sy-subrc NE 0.
          xkausg = 'X'.
        ENDIF.
        MOVE bseg-pswbt TO hbsid-pswbt.
        MOVE bseg-pswsl TO hbsid-pswsl.
        MOVE bseg-nebtr TO hbsid-nebtr.
      ELSE.
        CLEAR bseg.
        MOVE-CORRESPONDING hbsid TO bseg.
        MOVE 'D'                 TO bseg-koart.
      ENDIF.
      IF NOT hbsid-xblnr IS INITIAL.
        hbsid-hxbln = hbsid-xblnr.
      ELSE.
        hbsid-hxbln = hbsid-belnr.
      ENDIF.
      IF NOT bseg-xanet IS INITIAL.
        hbsid-wrbtr = hbsid-wrbtr + hbsid-wmwst.
        hbsid-dmbtr = hbsid-dmbtr + hbsid-mwsts.
        hbsid-dmbe2 = hbsid-dmbe2 + hbsid-mwst2.
        hbsid-dmbe3 = hbsid-dmbe3 + hbsid-mwst3.
        hbsid-pswbt = hbsid-pswbt + hbsid-wmwst.
        bseg-pswbt  = bseg-pswbt  + bseg-wmwst.
      ENDIF.
      MODIFY hbsid.
       *bseg = bseg.
      IF bkpf-waers NE *bkpf-waers.
        PERFORM curr_document_convert_bseg
                    USING
                       datum02
                       *bkpf-waers
                       *t001-waers
                       bkpf-waers
                    CHANGING
                       bseg.

      ENDIF.
      IF NOT rf140-vstid IS INITIAL.
        PERFORM verzugstage.
        hbsid-waers = bkpf-waers.
        PERFORM posten_rastern.
        hbsid-waers = *bkpf-waers.
      ENDIF.
*     CLEAR SAVE_DATUM.
*     CASE SAVE_RDATAR.
*       WHEN ' '.
*         SAVE_DATUM = HBSID-BUDAT.
*       WHEN '1'.
*         SAVE_DATUM = HBSID-CPUDT.
*       WHEN '2'.
*         SAVE_DATUM = HBSID-BLDAT.
*     ENDCASE.
*     IF save_datum  LT DATUM01.
      IF hbsid-bstat = 'S'.
        MOVE-CORRESPONDING hbsid TO dmpos.
        PERFORM sortierung USING 'P' '1' ' '.
        dmpos-sortp1 = sortp1.
        dmpos-sortp2 = sortp2.
        dmpos-sortp3 = sortp3.
        dmpos-sortp4 = sortp4.
        dmpos-sortp5 = sortp5.
        APPEND dmpos.
*         IF NOT RXKNUS IS INITIAL.
        xmpos = 'X'.
*         ENDIF.
        DELETE hbsid.
      ELSE.
        MOVE-CORRESPONDING hbsid TO dopos.
        PERFORM sortierung USING 'P' '1' ' '.
        dopos-sortp1 = sortp1.
        dopos-sortp2 = sortp2.
        dopos-sortp3 = sortp3.
        dopos-sortp4 = sortp4.
        dopos-sortp5 = sortp5.
        APPEND dopos.
*         IF NOT RXKNUS IS INITIAL.
        PERFORM nullsaldo_summe_1.
*         ENDIF.
        DELETE hbsid.
      ENDIF.
    ENDLOOP.
    IF raugbl IS INITIAL.
      IF ( NOT save_rxekvb IS INITIAL )
      OR ( NOT  knb1-knrze IS INITIAL
      AND NOT *knb1-xdezv IS INITIAL
      AND NOT save_rxdezv IS INITIAL
      AND     save_rxekvb IS INITIAL ).
        CLEAR   hbsad.
        REFRESH hbsad.
        CLEAR save2_kunnr.
        CLEAR save2_lifnr.
      ENDIF.
      PERFORM read_bsad_2.
      IF  NOT  knb1-knrze IS INITIAL
      AND NOT *knb1-xdezv IS INITIAL
      AND NOT save_rxdezv IS INITIAL
      AND     save_rxekvb IS INITIAL.
        save2_kunnr = save_kunnr.
        save_kunnr  = *knb1-kunnr.
        PERFORM read_bsad_2.
        save_kunnr = save2_kunnr.
        CLEAR xzent.
      ENDIF.
      IF  NOT save_rxverr IS INITIAL
      AND NOT xverr       IS INITIAL.
        PERFORM read_bsak_2.
        IF  NOT  lfb1-lnrze IS INITIAL
        AND NOT *lfb1-xdezv IS INITIAL
        AND NOT save_rxdezv IS INITIAL
        AND     save_rxekvb IS INITIAL.
          save2_lifnr = save_lifnr.
          save_lifnr  = *lfb1-lifnr.
          PERFORM read_bsak_2.
          save_lifnr = save2_lifnr.
          CLEAR xzent.
        ENDIF.
      ENDIF.
      IF NOT save_rxekvb IS INITIAL.
        save2_kunnr = save_kunnr.
        LOOP AT filialen.
          save_kunnr = filialen-filiale.
          PERFORM read_bsad_2.
        ENDLOOP.
        save_kunnr = save2_kunnr.
        CLEAR save2_kunnr.
      ENDIF.
    ENDIF.
    PERFORM pruefen_bsad.
    LOOP AT hbsad.
      save2_bukrs = hbsad-bukrs.
      save2_belnr = hbsad-belnr.
      save2_gjahr = hbsad-gjahr.
      save2_buzei = hbsad-buzei.
      CLEAR bkpf.
      MOVE-CORRESPONDING hbsad TO bkpf.
      MOVE-CORRESPONDING hbsad TO *bkpf.
      IF hbsad-bukrs NE *t001-bukrs.
        SELECT SINGLE * FROM t001 INTO *t001
          WHERE bukrs = hbsad-bukrs.
      ENDIF.
      alw_waers = bkpf-waers.
      PERFORM currency_get_subsequent
                  USING
                     save_repid_alw
                     datum02
                     bkpf-bukrs
                  CHANGING
                     alw_waers.
      IF alw_waers NE bkpf-waers.
        bkpf-waers = alw_waers.
      ENDIF.
*     PERFORM READ_BKPF_2.
*     IF SY-SUBRC NE 0.
*       XKAUSG = 'X'.
*     ENDIF.
      IF NOT hbsad-xzahl IS INITIAL
      OR     hbsad-pswsl IS INITIAL.
        IF hbsad-xarch IS INITIAL.
          PERFORM read_bseg_2.
        ELSE.
          PERFORM read_bseg_arc.
        ENDIF.
        IF sy-subrc NE 0.
          xkausg = 'X'.
        ENDIF.
        MOVE bseg-pswbt TO hbsad-pswbt.
        MOVE bseg-pswsl TO hbsad-pswsl.
        MOVE bseg-nebtr TO hbsad-nebtr.
      ELSE.
        CLEAR bseg.
        MOVE-CORRESPONDING hbsad TO bseg.
        MOVE 'D'                 TO bseg-koart.
      ENDIF.
      IF NOT hbsad-xblnr IS INITIAL.
        hbsad-hxbln = hbsad-xblnr.
      ELSE.
        hbsad-hxbln = hbsad-belnr.
      ENDIF.
      IF NOT bseg-xanet IS INITIAL.
        hbsad-wrbtr = hbsad-wrbtr + hbsad-wmwst.
        hbsad-dmbtr = hbsad-dmbtr + hbsad-mwsts.
        hbsad-dmbe2 = hbsad-dmbe2 + hbsad-mwst2.
        hbsad-dmbe3 = hbsad-dmbe3 + hbsad-mwst3.
        hbsad-pswbt = hbsad-pswbt + hbsad-wmwst.
        bseg-pswbt  = bseg-pswbt  + bseg-wmwst.
      ENDIF.
      MODIFY hbsad.
       *bseg = bseg.
      IF bkpf-waers NE *bkpf-waers.
        PERFORM curr_document_convert_bseg
                    USING
                       datum02
                       *bkpf-waers
                       *t001-waers
                       bkpf-waers
                    CHANGING
                       bseg.

      ENDIF.
*      IF HBSAD-BSTAT = 'S'.
*        DELETE HBSAD.
*      ELSE.
*        IF NOT HBSAD-BSTAT = 'S'.                     "Note 702919
      IF NOT rf140-vstid IS INITIAL.
        IF NOT rvztag IS INITIAL.
          PERFORM verzugstage_2.
          hbsad-waers = bkpf-waers.
          PERFORM posten_rastern_2.
          hbsad-waers = *bkpf-waers.
        ENDIF.
      ENDIF.
*        ENDIF.                                       "Note 702919
      IF NOT rxopol IS INITIAL.
        CLEAR save_datum.
        CASE save_rdatar.
          WHEN ' '.
            save_datum = hbsad-budat.
          WHEN '1'.
            save_datum = hbsad-cpudt.
          WHEN '2'.
            save_datum = hbsad-bldat.
        ENDCASE.
        IF  save_datum  LT datum01
        AND hbsad-augdt GE datum01.
          IF hbsad-bstat = 'S'.
            MOVE-CORRESPONDING hbsad TO dmpos.
            PERFORM sortierung USING 'P' '1' ' '.
            dmpos-sortp1 = sortp1.
            dmpos-sortp2 = sortp2.
            dmpos-sortp3 = sortp3.
            dmpos-sortp4 = sortp4.
            dmpos-sortp5 = sortp5.
            APPEND dmpos.
            xmpos = 'X'.
            DELETE hbsad.
          ELSE.
            MOVE-CORRESPONDING hbsad TO dopos.
            PERFORM sortierung USING 'P' '1' ' '.
            dopos-sortp1 = sortp1.
            dopos-sortp2 = sortp2.
            dopos-sortp3 = sortp3.
            dopos-sortp4 = sortp4.
            dopos-sortp5 = sortp5.
            APPEND dopos.
*             IF NOT RXKNUS IS INITIAL.
            PERFORM nullsaldo_summe_2.
*             ENDIF.
            DELETE hbsad.
          ENDIF.
        ENDIF.
      ELSE.
        IF hbsad-bstat = 'S'.
          IF  save_datum  LT datum02
          AND hbsad-augdt GE datum02.
            MOVE-CORRESPONDING hbsad TO dmpos.
            PERFORM sortierung USING 'P' '1' ' '.
            dmpos-sortp1 = sortp1.
            dmpos-sortp2 = sortp2.
            dmpos-sortp3 = sortp3.
            dmpos-sortp4 = sortp4.
            dmpos-sortp5 = sortp5.
            APPEND dmpos.
            xmpos = 'X'.
            DELETE hbsad.
          ENDIF.
        ELSE.
          IF hbsad-augdt GT datum02.
            MOVE-CORRESPONDING hbsad TO dopos.
            PERFORM sortierung USING 'P' '1' ' '.
            dopos-sortp1 = sortp1.
            dopos-sortp2 = sortp2.
            dopos-sortp3 = sortp3.
            dopos-sortp4 = sortp4.
            dopos-sortp5 = sortp5.
            APPEND dopos.
*             IF NOT RXKNUS IS INITIAL.
            PERFORM nullsaldo_summe_2.
*             ENDIF.
            DELETE hbsad.
          ELSE.
            MOVE-CORRESPONDING hbsad TO hbsid.
            PERFORM sortierung USING 'P' '2' ' '.
            hbsid-sortp1 = sortp1.
            hbsid-sortp2 = sortp2.
            hbsid-sortp3 = sortp3.
            hbsid-sortp4 = sortp4.
            hbsid-sortp5 = sortp5.
            APPEND hbsid.
*             IF NOT RXKNUS IS INITIAL.
            PERFORM nullsaldo_summe_2.
*             ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
*      ENDIF.
    ENDLOOP.
    REFRESH zahltab.
    LOOP AT hbsid.
      CHECK hbsid-nebtr NE 0.
      CLEAR   zahltab.
      MOVE hbsid-kunnr TO zahltab-konto.
      MOVE hbsid-bukrs TO zahltab-bukrs.
      MOVE hbsid-belnr TO zahltab-belnr.
      MOVE hbsid-gjahr TO zahltab-gjahr.
      IF hbsid-shkzg = 'S'.
        zahltab-zalbt = hbsid-nebtr.
      ELSE.
        zahltab-zalbt = 0 - hbsid-nebtr.
      ENDIF.
      COLLECT zahltab.
    ENDLOOP.
    LOOP AT dopos.
      CHECK dopos-nebtr NE 0.
      CLEAR   zahltab.
      MOVE dopos-kunnr TO zahltab-konto.
      MOVE dopos-bukrs TO zahltab-bukrs.
      MOVE dopos-belnr TO zahltab-belnr.
      MOVE dopos-gjahr TO zahltab-gjahr.
      MOVE dopos-kunnr TO zahltab-konto.
      IF hbsid-shkzg = 'S'.
        zahltab-zalbt = dopos-nebtr.
      ELSE.
        zahltab-zalbt = 0 - dopos-nebtr.
      ENDIF.
      COLLECT zahltab.
    ENDLOOP.
    LOOP AT zahltab.
      LOOP AT hbsid
        WHERE kunnr = zahltab-konto
        AND   bukrs = zahltab-bukrs
        AND   belnr = zahltab-belnr
        AND   gjahr = zahltab-gjahr.
        hbsid-zalbt = zahltab-zalbt.
        MODIFY hbsid.
      ENDLOOP.
      LOOP AT dopos
        WHERE kunnr = zahltab-konto
        AND   bukrs = zahltab-bukrs
        AND   belnr = zahltab-belnr
        AND   gjahr = zahltab-gjahr.
        dopos-zalbt = zahltab-zalbt.
        MODIFY dopos.
      ENDLOOP.
    ENDLOOP.
  ELSE.
    IF ( NOT  lfb1-lnrze IS INITIAL
    AND NOT *lfb1-xdezv IS INITIAL
    AND NOT save_rxdezv IS INITIAL
    AND     save_rxekvb IS INITIAL ).
      CLEAR   hbsik.
      REFRESH hbsik.
      CLEAR save2_kunnr.
      CLEAR save2_lifnr.
    ENDIF.
    PERFORM read_bsik.
    IF NOT vorebl IS INITIAL.
      PERFORM read_vbsik.
    ENDIF.
    IF  NOT  lfb1-lnrze IS INITIAL
    AND NOT *lfb1-xdezv IS INITIAL
    AND NOT save_rxdezv IS INITIAL
    AND     save_rxekvb IS INITIAL.
      save2_lifnr = save_lifnr.
      save_lifnr  = *lfb1-lifnr.
      PERFORM read_bsik.
      IF NOT vorebl IS INITIAL.
        PERFORM read_vbsik.
      ENDIF.
      save_lifnr = save2_lifnr.
      CLEAR xzent.
    ENDIF.
    LOOP AT hbsik.
      save2_bukrs = hbsik-bukrs.
      save2_belnr = hbsik-belnr.
      save2_gjahr = hbsik-gjahr.
      save2_buzei = hbsik-buzei.
      CLEAR bkpf.
      MOVE-CORRESPONDING hbsik TO bkpf.
      MOVE-CORRESPONDING hbsik TO *bkpf.
      IF hbsik-bukrs NE *t001-bukrs.
        SELECT SINGLE * FROM t001 INTO *t001
          WHERE bukrs = hbsik-bukrs.
      ENDIF.
      alw_waers = bkpf-waers.
      PERFORM currency_get_subsequent
                  USING
                     save_repid_alw
                     datum02
                     bkpf-bukrs
                  CHANGING
                     alw_waers.
      IF alw_waers NE bkpf-waers.
        bkpf-waers = alw_waers.
      ENDIF.
*     PERFORM READ_BKPF_2.
*     IF SY-SUBRC NE 0.
*       XKAUSG = 'X'.
*     ENDIF.
      IF NOT hbsik-xzahl IS INITIAL
      OR     hbsik-pswsl IS INITIAL.
        IF hbsik-xarch IS INITIAL.
          PERFORM read_bseg_2.
        ELSE.
          PERFORM read_bseg_arc.
        ENDIF.
        IF sy-subrc NE 0.
          xkausg = 'X'.
        ENDIF.
        MOVE bseg-pswbt TO hbsik-pswbt.
        MOVE bseg-pswsl TO hbsik-pswsl.
        MOVE bseg-nebtr TO hbsik-nebtr.
      ELSE.
        CLEAR bseg.
        MOVE-CORRESPONDING hbsik TO bseg.
        MOVE 'K'                 TO bseg-koart.
      ENDIF.
      IF NOT hbsik-xblnr IS INITIAL.
        hbsik-hxbln = hbsik-xblnr.
      ELSE.
        hbsik-hxbln = hbsik-belnr.
      ENDIF.
      IF NOT bseg-xanet IS INITIAL.
        hbsik-wrbtr = hbsik-wrbtr + hbsik-wmwst.
        hbsik-dmbtr = hbsik-dmbtr + hbsik-mwsts.
        hbsik-dmbe2 = hbsik-dmbe2 + hbsik-mwst2.
        hbsik-dmbe3 = hbsik-dmbe3 + hbsik-mwst3.
        hbsik-pswbt = hbsik-pswbt + hbsik-wmwst.
        bseg-pswbt  = bseg-pswbt  + bseg-wmwst.
      ENDIF.
      MODIFY hbsik.
       *bseg = bseg.
      IF bkpf-waers NE *bkpf-waers.
        PERFORM curr_document_convert_bseg
                    USING
                       datum02
                       *bkpf-waers
                       *t001-waers
                       bkpf-waers
                    CHANGING
                       bseg.

      ENDIF.
      IF NOT rf140-vstid IS INITIAL.
        PERFORM verzugstage.
        hbsik-waers = bkpf-waers.
        PERFORM posten_rastern.
        hbsik-waers = *bkpf-waers.
      ENDIF.
*     CLEAR SAVE_DATUM.
*     CASE SAVE_RDATAR.
*       WHEN ' '.
*         SAVE_DATUM = HBSIk-BUDAT.
*       WHEN '1'.
*         SAVE_DATUM = HBSIk-CPUDT.
*       WHEN '2'.
*         SAVE_DATUM = HBSIk-BLDAT.
*     ENDCASE.
*     IF save_datum  LT DATUM01.
      IF hbsik-bstat = 'S'.
        MOVE-CORRESPONDING hbsik TO kmpos.
        PERFORM sortierung USING 'P' '1' ' '.
        kmpos-sortp1 = sortp1.
        kmpos-sortp2 = sortp2.
        kmpos-sortp3 = sortp3.
        kmpos-sortp4 = sortp4.
        kmpos-sortp5 = sortp5.
        APPEND kmpos.
*         IF NOT RXKNUS IS INITIAL.
        xmpos = 'X'.
*         ENDIF.
        DELETE hbsik.
      ELSE.
        MOVE-CORRESPONDING hbsik TO kopos.
        PERFORM sortierung USING 'P' '1' ' '.
        kopos-sortp1 = sortp1.
        kopos-sortp2 = sortp2.
        kopos-sortp3 = sortp3.
        kopos-sortp4 = sortp4.
        kopos-sortp5 = sortp5.
        APPEND kopos.
*         IF NOT RXKNUS IS INITIAL.
        PERFORM nullsaldo_summe_1.
*         ENDIF.
        DELETE hbsik.
      ENDIF.
    ENDLOOP.
    IF raugbl IS INITIAL.
      IF ( NOT  lfb1-lnrze IS INITIAL
      AND NOT *lfb1-xdezv IS INITIAL
      AND NOT save_rxdezv IS INITIAL
      AND     save_rxekvb IS INITIAL ).
        CLEAR   hbsak.
        REFRESH hbsak.
        CLEAR save2_kunnr.
        CLEAR save2_lifnr.
      ENDIF.
      PERFORM read_bsak_2.
      IF  NOT  lfb1-lnrze IS INITIAL
      AND NOT *lfb1-xdezv IS INITIAL
      AND NOT save_rxdezv IS INITIAL
      AND     save_rxekvb IS INITIAL.
        save2_lifnr = save_lifnr.
        save_lifnr  = *lfb1-lifnr.
        PERFORM read_bsak_2.
        save_lifnr = save2_lifnr.
        CLEAR xzent.
      ENDIF.
    ENDIF.
    PERFORM pruefen_bsak.
    LOOP AT hbsak.
      save2_bukrs = hbsak-bukrs.
      save2_belnr = hbsak-belnr.
      save2_gjahr = hbsak-gjahr.
      save2_buzei = hbsak-buzei.
      CLEAR bkpf.
      MOVE-CORRESPONDING hbsak TO bkpf.
      MOVE-CORRESPONDING hbsak TO *bkpf.
      IF hbsak-bukrs NE *t001-bukrs.
        SELECT SINGLE * FROM t001 INTO *t001
          WHERE bukrs = hbsak-bukrs.
      ENDIF.
      alw_waers = bkpf-waers.
      PERFORM currency_get_subsequent
                  USING
                     save_repid_alw
                     datum02
                     bkpf-bukrs
                  CHANGING
                     alw_waers.
      IF alw_waers NE bkpf-waers.
        bkpf-waers = alw_waers.
      ENDIF.
*     PERFORM READ_BKPF_2.
*     IF SY-SUBRC NE 0.
*       XKAUSG = 'X'.
*     ENDIF.
      IF NOT hbsak-xzahl IS INITIAL
      OR     hbsak-pswsl IS INITIAL.
        IF hbsak-xarch IS INITIAL.
          PERFORM read_bseg_2.
        ELSE.
          PERFORM read_bseg_arc.
        ENDIF.
        IF sy-subrc NE 0.
          xkausg = 'X'.
        ENDIF.
        MOVE bseg-pswbt TO hbsak-pswbt.
        MOVE bseg-pswsl TO hbsak-pswsl.
        MOVE bseg-nebtr TO hbsak-nebtr.
      ELSE.
        CLEAR bseg.
        MOVE-CORRESPONDING hbsak TO bseg.
        MOVE 'K'                 TO bseg-koart.
      ENDIF.
      IF NOT hbsak-xblnr IS INITIAL.
        hbsak-hxbln = hbsak-xblnr.
      ELSE.
        hbsak-hxbln = hbsak-belnr.
      ENDIF.
      IF NOT bseg-xanet IS INITIAL.
        hbsak-wrbtr = hbsak-wrbtr + hbsak-wmwst.
        hbsak-dmbtr = hbsak-dmbtr + hbsak-mwsts.
        hbsak-dmbe2 = hbsak-dmbe2 + hbsak-mwst2.
        hbsak-dmbe3 = hbsak-dmbe3 + hbsak-mwst3.
        hbsak-pswbt = hbsak-pswbt + hbsak-wmwst.
        bseg-pswbt  = bseg-pswbt  + bseg-wmwst.
      ENDIF.
      MODIFY hbsak.
       *bseg = bseg.
      IF bkpf-waers NE *bkpf-waers.
        PERFORM curr_document_convert_bseg
                    USING
                       datum02
                       *bkpf-waers
                       *t001-waers
                       bkpf-waers
                    CHANGING
                       bseg.

      ENDIF.
      IF hbsak-bstat = 'S'.
        DELETE hbsak.
      ELSE.
        IF NOT rf140-vstid IS INITIAL.
          IF NOT rvztag IS INITIAL.
            PERFORM verzugstage_2.
            hbsak-waers = bkpf-waers.
            PERFORM posten_rastern_2.
            hbsak-waers = *bkpf-waers.
          ENDIF.
        ENDIF.
        IF NOT rxopol IS INITIAL.
          CLEAR save_datum.
          CASE save_rdatar.
            WHEN ' '.
              save_datum = hbsak-budat.
            WHEN '1'.
              save_datum = hbsak-cpudt.
            WHEN '2'.
              save_datum = hbsak-bldat.
          ENDCASE.
          IF  save_datum  LT datum01
          AND hbsak-augdt GE datum01.
            MOVE-CORRESPONDING hbsak TO kopos.
            PERFORM sortierung USING 'P' '1' ' '.
            kopos-sortp1 = sortp1.
            kopos-sortp2 = sortp2.
            kopos-sortp3 = sortp3.
            kopos-sortp4 = sortp4.
            kopos-sortp5 = sortp5.
            APPEND kopos.
*           IF NOT RXKNUS IS INITIAL.
            PERFORM nullsaldo_summe_2.
*           ENDIF.
            DELETE hbsak.
          ENDIF.
        ELSE.
          IF hbsak-augdt GT datum02.
            MOVE-CORRESPONDING hbsak TO kopos.
            PERFORM sortierung USING 'P' '1' ' '.
            kopos-sortp1 = sortp1.
            kopos-sortp2 = sortp2.
            kopos-sortp3 = sortp3.
            kopos-sortp4 = sortp4.
            kopos-sortp5 = sortp5.
            APPEND kopos.
*           IF NOT RXKNUS IS INITIAL.
            PERFORM nullsaldo_summe_2.
*           ENDIF.
            DELETE hbsak.
          ELSE.
            MOVE-CORRESPONDING hbsak TO hbsik.
            PERFORM sortierung USING 'P' '2' ' '.
            hbsik-sortp1 = sortp1.
            hbsik-sortp2 = sortp2.
            hbsik-sortp3 = sortp3.
            hbsik-sortp4 = sortp4.
            hbsik-sortp5 = sortp5.
            APPEND hbsik.
*           IF NOT RXKNUS IS INITIAL.
            PERFORM nullsaldo_summe_2.
*           ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
    REFRESH zahltab.
    LOOP AT hbsik.
      CHECK hbsik-nebtr NE 0.
      CLEAR   zahltab.
      MOVE hbsik-lifnr TO zahltab-konto.
      MOVE hbsik-bukrs TO zahltab-bukrs.
      MOVE hbsik-belnr TO zahltab-belnr.
      MOVE hbsik-gjahr TO zahltab-gjahr.
      IF hbsik-shkzg = 'S'.
        zahltab-zalbt = hbsik-nebtr.
      ELSE.
        zahltab-zalbt = 0 - hbsik-nebtr.
      ENDIF.
      COLLECT zahltab.
    ENDLOOP.
    LOOP AT kopos.
      CHECK kopos-nebtr NE 0.
      CLEAR   zahltab.
      MOVE kopos-lifnr TO zahltab-konto.
      MOVE kopos-bukrs TO zahltab-bukrs.
      MOVE kopos-belnr TO zahltab-belnr.
      MOVE kopos-gjahr TO zahltab-gjahr.
      MOVE kopos-lifnr TO zahltab-konto.
      IF hbsik-shkzg = 'S'.
        zahltab-zalbt = kopos-nebtr.
      ELSE.
        zahltab-zalbt = 0 - kopos-nebtr.
      ENDIF.
      COLLECT zahltab.
    ENDLOOP.
    LOOP AT zahltab.
      LOOP AT hbsik
        WHERE lifnr = zahltab-konto
        AND   bukrs = zahltab-bukrs
        AND   belnr = zahltab-belnr
        AND   gjahr = zahltab-gjahr.
        hbsik-zalbt = zahltab-zalbt.
        MODIFY hbsik.
      ENDLOOP.
      LOOP AT kopos
        WHERE lifnr = zahltab-konto
        AND   bukrs = zahltab-bukrs
        AND   belnr = zahltab-belnr
        AND   gjahr = zahltab-gjahr.
        kopos-zalbt = zahltab-zalbt.
        MODIFY kopos.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

* IF NOT RXKNUS IS INITIAL.
  IF xmpos IS INITIAL.
    PERFORM nullsaldo_pruefen.
  ENDIF.
* ENDIF.
  CLEAR xmpos.

  SORT rtab.
ENDFORM.                    "POSTEN

*-----------------------------------------------------------------------
*       FORM POSTEN_BEARBEITEN
*-----------------------------------------------------------------------
*ORM POSTEN_BEARBEITEN.
* CLEAR   XMPOS.
* CLEAR   DMPOS.
* REFRESH DMPOS.
* CLEAR   KMPOS.
* REFRESH KMPOS.
* CLEAR   DOPOS.
* REFRESH DOPOS.
* CLEAR   KOPOS.
* REFRESH KOPOS.
* CLEAR   RTAB.
* REFRESH RTAB.
* IF NOT RXKNUS IS INITIAL.
*   CLEAR SALDOB.
*   REFRESH SALDOB.
* ENDIF.
*
* IF HDKOART = 'D'.
*   LOOP AT HBSID.
*     IF NOT RF140-VSTID IS INITIAL.
*       PERFORM VERZUGSTAGE.
*       PERFORM POSTEN_RASTERN.
*     ENDIF.
**    CLEAR SAVE_DATUM.
**    CASE SAVE_RDATAR.
**      WHEN ' '.
**        SAVE_DATUM = HBSID-BUDAT.
**      WHEN '1'.
**        SAVE_DATUM = HBSID-CPUDT.
**      WHEN '2'.
**        SAVE_DATUM = HBSID-BLDAT.
**    ENDCASE.
**    IF save_datum  LT DATUM01.
*       IF HBSID-BSTAT = 'S'.
*         MOVE-CORRESPONDING HBSID TO DMPOS.
*         APPEND DMPOS.
*         IF NOT RXKNUS IS INITIAL.
*           XMPOS = 'X'.
*         ENDIF.
*         DELETE HBSID.
*       ELSE.
*         MOVE-CORRESPONDING HBSID TO DOPOS.
*         APPEND DOPOS.
*         IF NOT RXKNUS IS INITIAL.
*           PERFORM NULLSALDO_SUMME_1.
*         ENDIF.
*         DELETE HBSID.
*       ENDIF.
**    ELSE.
**      IF HBSID-BSTAT = 'S'.
**        MOVE-CORRESPONDING HBSID TO DMPOS.
**        APPEND DMPOS.
**        IF NOT RXKNUS IS INITIAL.
**          XMPOS = 'X'.
**        ENDIF.
**        DELETE HBSID.
**      ELSE.
**        IF NOT RF140-VSTID IS INITIAL.
**          MODIFY HBSID.
**        ENDIF.
**        IF NOT RXKNUS IS INITIAL.
**          PERFORM NULLSALDO_SUMME_1.
**        ENDIF.
**      ENDIF.
**    ENDIF.
*   ENDLOOP.
*   LOOP AT HBSAD.
*     IF HBSAD-BSTAT = 'S'.
*       DELETE HBSAD.
*     ELSE.
*       IF NOT RF140-VSTID IS INITIAL.
*         IF NOT RVZTAG IS INITIAL.
*           PERFORM VERZUGSTAGE_2.
*           PERFORM POSTEN_RASTERN_2.
*         ENDIF.
*       ENDIF.
*       IF NOT RXOPOL IS INITIAL.
*         CLEAR SAVE_DATUM.
*         CASE SAVE_RDATAR.
*           WHEN ' '.
*             SAVE_DATUM = HBSAD-BUDAT.
*           WHEN '1'.
*             SAVE_DATUM = HBSAD-CPUDT.
*           WHEN '2'.
*             SAVE_DATUM = HBSAD-BLDAT.
*         ENDCASE.
*         IF  SAVE_DATUM  LT DATUM01
*         AND HBSAD-AUGDT GE DATUM01.
*           MOVE-CORRESPONDING HBSAD TO DOPOS.
*           APPEND DOPOS.
*           IF NOT RXKNUS IS INITIAL.
*             PERFORM NULLSALDO_SUMME_2.
*           ENDIF.
*           DELETE HBSAD.
*         ENDIF.
*       ELSE.
*         IF HBSAD-AUGDT GT DATUM02.
*           MOVE-CORRESPONDING HBSAD TO DOPOS.
*           APPEND DOPOS.
*           IF NOT RXKNUS IS INITIAL.
*             PERFORM NULLSALDO_SUMME_2.
*           ENDIF.
*           DELETE HBSAD.
*         ELSE.
*           MOVE-CORRESPONDING HBSAD TO HBSID.
*           APPEND HBSID.
*           IF NOT RXKNUS IS INITIAL.
*             PERFORM NULLSALDO_SUMME_2.
*           ENDIF.
*         ENDIF.
*       ENDIF.
*     ENDIF.
*   ENDLOOP.
* ELSE.
*   LOOP AT HBSIK.
*     IF NOT RF140-VSTID IS INITIAL.
*       PERFORM VERZUGSTAGE.
*       PERFORM POSTEN_RASTERN.
*     ENDIF.
**    CLEAR SAVE_DATUM.
**    CASE SAVE_RDATAR.
**      WHEN ' '.
**        SAVE_DATUM = HBSIk-BUDAT.
**      WHEN '1'.
**        SAVE_DATUM = HBSIk-CPUDT.
**      WHEN '2'.
**        SAVE_DATUM = HBSIk-BLDAT.
**    ENDCASE.
**    IF save_datum  LT DATUM01.
*       IF HBSIK-BSTAT = 'S'.
*         MOVE-CORRESPONDING HBSIK TO KMPOS.
*         APPEND KMPOS.
*         IF NOT RXKNUS IS INITIAL.
*           XMPOS = 'X'.
*         ENDIF.
*         DELETE HBSIK.
**      ELSE.
**        MOVE-CORRESPONDING HBSIK TO KOPOS.
**        APPEND KOPOS.
**        IF NOT RXKNUS IS INITIAL.
**          PERFORM NULLSALDO_SUMME_1.
**        ENDIF.
**        DELETE HBSIK.
**      ENDIF.
*     ELSE.
*       IF HBSIK-BSTAT = 'S'.
*         MOVE-CORRESPONDING HBSIK TO KMPOS.
*         APPEND KMPOS.
*         IF NOT RXKNUS IS INITIAL.
*           XMPOS = 'X'.
*         ENDIF.
*         DELETE HBSIK.
*       ELSE.
*         IF NOT RF140-VSTID IS INITIAL.
*           MODIFY HBSIK.
*         ENDIF.
*         IF NOT RXKNUS IS INITIAL.
*           PERFORM NULLSALDO_SUMME_1.
*         ENDIF.
*       ENDIF.
*     ENDIF.
*   ENDLOOP.
*   LOOP AT HBSAK.
*     IF HBSAD-BSTAT = 'S'.
*       DELETE HBSAK.
*     ELSE.
*       IF NOT RF140-VSTID IS INITIAL.
*         IF NOT RVZTAG IS INITIAL.
*           PERFORM VERZUGSTAGE_2.
*           PERFORM POSTEN_RASTERN_2.
*         ENDIF.
*       ENDIF.
*       IF NOT RXOPOL IS INITIAL.
*         CLEAR SAVE_DATUM.
*         CASE SAVE_RDATAR.
*           WHEN ' '.
*             SAVE_DATUM = HBSAK-BUDAT.
*           WHEN '1'.
*             SAVE_DATUM = HBSAK-CPUDT.
*           WHEN '2'.
*             SAVE_DATUM = HBSAK-BLDAT.
*         ENDCASE.
*         IF  SAVE_DATUM  LT DATUM01
*         AND HBSAK-AUGDT GE DATUM01.
*           MOVE-CORRESPONDING HBSAK TO KOPOS.
*           APPEND KOPOS.
*           IF NOT RXKNUS IS INITIAL.
*             PERFORM NULLSALDO_SUMME_2.
*           ENDIF.
*           DELETE HBSAK.
*         ENDIF.
*       ELSE.
*         IF HBSAK-AUGDT GT DATUM02.
*           MOVE-CORRESPONDING HBSAK TO KOPOS.
*           APPEND KOPOS.
*           IF NOT RXKNUS IS INITIAL.
*             PERFORM NULLSALDO_SUMME_2.
*           ENDIF.
*           DELETE HBSAK.
*         ELSE.
*           MOVE-CORRESPONDING HBSAK TO HBSIK.
*           APPEND HBSIK.
*           IF NOT RXKNUS IS INITIAL.
*             PERFORM NULLSALDO_SUMME_2.
*           ENDIF.
*         ENDIF.
*       ENDIF.
*     ENDIF.
*   ENDLOOP.
* ENDIF.
*
* IF NOT RXKNUS IS INITIAL.
*   IF XMPOS IS INITIAL.
*     PERFORM NULLSALDO_PRUEFEN.
*   ENDIF.
* ENDIF.
* CLEAR XMPOS.
*
* SORT RTAB.
*NDFORM.

*-----------------------------------------------------------------------
*       FORM POSTEN_RASTERN
*-----------------------------------------------------------------------
FORM posten_rastern.
  CLEAR ntage.
  CLEAR stage.
  CLEAR ttage.
  CLEAR utage.

  IF hdkoart = 'D'.
    IF hbsid-augbl IS INITIAL.
      IF NOT rart-net IS INITIAL.
        ntage = hbsid-netdt - rf140-vstid.
        PERFORM fill_waehrungsfelder_bseg.
        PERFORM rastern USING hbsid-bukrs  hbsid-bstat ntage    '1'
                              rf140-wrshb  hbsid-waers.
      ENDIF.
      IF NOT rart-sk1 IS INITIAL.
*       IF  NOT BSID-ZBD1T IS INITIAL
*       AND NOT BSID-ZBD2T IS INITIAL.
*         IF NOT HBSID-ZFBDT IS INITIAL.
*           STAGE = HBSID-ZFBDT + HBSID-ZBD1T - RF140-VSTID.
*         ELSE.
*           STAGE = HBSID-BLDAT + HBSID-ZBD1T - RF140-VSTID.
*         ENDIF.
        stage = faede-sk1dt - rf140-vstid.
        PERFORM fill_waehrungsfelder_bseg.
        PERFORM rastern USING hbsid-bukrs  hbsid-bstat stage    '2'
                              rf140-wrshb  hbsid-waers.
*       ENDIF.
      ENDIF.
      IF NOT rart-sk2 IS INITIAL.
*       IF  NOT BSID-ZBD2T IS INITIAL
*       AND NOT BSID-ZBD3T IS INITIAL.
*         IF NOT HBSID-ZBD2T IS INITIAL.
*           IF NOT HBSID-ZFBDT IS INITIAL.
*             TTAGE = HBSID-ZFBDT +  HBSID-ZBD2T - RF140-VSTID.
*           ELSE.
*             TTAGE = HBSID-BLDAT +  HBSID-ZBD2T - RF140-VSTID.
*           ENDIF.
*         ELSE.
*           IF NOT HBSID-ZFBDT IS INITIAL.
*             TTAGE = HBSID-ZFBDT +  HBSID-ZBD1T - RF140-VSTID.
*           ELSE.
*             TTAGE = HBSID-BLDAT +  HBSID-ZBD1T - RF140-VSTID.
*           ENDIF.
*         ENDIF.
        ttage = faede-sk2dt - rf140-vstid.
        PERFORM fill_waehrungsfelder_bseg.
        PERFORM rastern USING hbsid-bukrs  hbsid-bstat ttage    '3'
                              rf140-wrshb  hbsid-waers.
*       ENDIF.
      ENDIF.
      IF NOT rart-ueb IS INITIAL.
        utage =  rf140-vstid - hbsid-netdt.
        PERFORM fill_waehrungsfelder_bseg.
        PERFORM rastern USING hbsid-bukrs  hbsid-bstat utage    '4'
                              rf140-wrshb  hbsid-waers.
      ENDIF.
      IF NOT rart-alt IS INITIAL.
        IF rbldat IS INITIAL.
          atage =  rf140-vstid - hbsid-budat.
        ELSE.
          atage =  rf140-vstid - hbsid-bldat.
        ENDIF.
        PERFORM fill_waehrungsfelder_bseg.
        PERFORM rastern USING hbsid-bukrs  hbsid-bstat atage    '5'
                              rf140-wrshb  hbsid-waers.
      ENDIF.
    ENDIF.
  ELSE.
    IF hbsik-augbl IS INITIAL.
      IF NOT rart-net IS INITIAL.
        ntage = hbsik-netdt - rf140-vstid.
        PERFORM fill_waehrungsfelder_bseg.
        PERFORM rastern USING hbsik-bukrs  hbsik-bstat ntage    '1'
                              rf140-wrshb  hbsik-waers.
      ENDIF.
      IF NOT rart-sk1 IS INITIAL.
*       IF  NOT BSIK-ZBD1T IS INITIAL
*       AND NOT BSIK-ZBD2T IS INITIAL.
*         IF NOT HBSIK-ZFBDT IS INITIAL.
*           STAGE = HBSIK-ZFBDT + HBSIK-ZBD1T - RF140-VSTID.
*         ELSE.
*           STAGE = HBSIK-BLDAT + HBSIK-ZBD1T - RF140-VSTID.
*         ENDIF.
        stage = faede-sk1dt - rf140-vstid.
        PERFORM fill_waehrungsfelder_bseg.
        PERFORM rastern USING hbsik-bukrs  hbsik-bstat stage    '2'
                              rf140-wrshb  hbsik-waers.
*       ENDIF.
      ENDIF.
      IF NOT rart-sk2 IS INITIAL.
*       IF  NOT BSIK-ZBD2T IS INITIAL
*       AND NOT BSIK-ZBD3T IS INITIAL.
*         IF NOT HBSIK-ZBD2T IS INITIAL.
*           IF NOT HBSIK-ZFBDT IS INITIAL.
*             TTAGE = HBSIK-ZFBDT +  HBSIK-ZBD2T - RF140-VSTID.
*           ELSE.
*             TTAGE = HBSIK-BLDAT +  HBSIK-ZBD2T - RF140-VSTID.
*           ENDIF.
*         ELSE.
*           IF NOT HBSIK-ZFBDT IS INITIAL.
*             TTAGE = HBSIK-ZFBDT +  HBSIK-ZBD1T - RF140-VSTID.
*           ELSE.
*             TTAGE = HBSIK-BLDAT +  HBSIK-ZBD1T - RF140-VSTID.
*           ENDIF.
*         ENDIF.
        ttage = faede-sk2dt - rf140-vstid.
        PERFORM fill_waehrungsfelder_bseg.
        PERFORM rastern USING hbsik-bukrs  hbsik-bstat ttage    '3'
                              rf140-wrshb  hbsik-waers.
*       ENDIF.
      ENDIF.
      IF NOT rart-ueb IS INITIAL.
        utage =  rf140-vstid - hbsik-netdt.
        PERFORM fill_waehrungsfelder_bseg.
        PERFORM rastern USING hbsik-bukrs  hbsik-bstat utage    '4'
                              rf140-wrshb  hbsik-waers.
      ENDIF.
      IF NOT rart-alt IS INITIAL.
        IF rbldat IS INITIAL.
          atage =  rf140-vstid - hbsik-budat.
        ELSE.
          atage =  rf140-vstid - hbsik-bldat.
        ENDIF.
        PERFORM fill_waehrungsfelder_bseg.
        PERFORM rastern USING hbsik-bukrs  hbsik-bstat atage    '5'
                              rf140-wrshb  hbsik-waers.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "POSTEN_RASTERN

*-----------------------------------------------------------------------
*       FORM POSTEN_RASTERN_2
*-----------------------------------------------------------------------
FORM posten_rastern_2.
  CLEAR ntage.
  CLEAR stage.
  CLEAR ttage.
  CLEAR utage.

  IF hdkoart = 'D'.
    IF hbsad-augdt GT rf140-vstid.
      IF NOT rart-net IS INITIAL.
        ntage = hbsad-netdt - rf140-vstid.
        PERFORM fill_waehrungsfelder_bseg.
        PERFORM rastern USING hbsad-bukrs  hbsad-bstat ntage    '1'
                              rf140-wrshb  hbsad-waers.
      ENDIF.
      IF NOT rart-sk1 IS INITIAL.
*       IF  NOT BSAD-ZBD1T IS INITIAL
*       AND NOT BSAD-ZBD2T IS INITIAL.
*         IF NOT HBSAD-ZFBDT IS INITIAL.
*           STAGE = HBSAD-ZFBDT + HBSAD-ZBD1T - RF140-VSTID.
*         ELSE.
*           STAGE = HBSAD-BLDAT + HBSAD-ZBD1T - RF140-VSTID.
*         ENDIF.
        stage = faede-sk1dt - rf140-vstid.
        PERFORM fill_waehrungsfelder_bseg.
        PERFORM rastern USING hbsad-bukrs  hbsad-bstat stage    '2'
                              rf140-wrshb  hbsad-waers.
*       ENDIF.
      ENDIF.
      IF NOT rart-sk2 IS INITIAL.
*       IF  NOT BSAD-ZBD2T IS INITIAL
*       AND NOT BSAD-ZBD3T IS INITIAL.
*         IF NOT HBSAD-ZBD2T IS INITIAL.
*           IF NOT HBSAD-ZFBDT IS INITIAL.
*             TTAGE = HBSAD-ZFBDT +  HBSAD-ZBD2T - RF140-VSTID.
*           ELSE.
*             TTAGE = HBSAD-BLDAT +  HBSAD-ZBD2T - RF140-VSTID.
*           ENDIF.
*         ELSE.
*           IF NOT HBSAD-ZFBDT IS INITIAL.
*             TTAGE = HBSAD-ZFBDT +  HBSAD-ZBD1T - RF140-VSTID.
*           ELSE.
*             TTAGE = HBSAD-BLDAT +  HBSAD-ZBD1T - RF140-VSTID.
*           ENDIF.
*         ENDIF.
        ttage = faede-sk2dt - rf140-vstid.
        PERFORM fill_waehrungsfelder_bseg.
        PERFORM rastern USING hbsad-bukrs  hbsad-bstat ttage    '3'
                              rf140-wrshb  hbsad-waers.
*       ENDIF.
      ENDIF.
      IF NOT rart-ueb IS INITIAL.
        utage =  rf140-vstid - hbsad-netdt.
        PERFORM fill_waehrungsfelder_bseg.
        PERFORM rastern USING hbsad-bukrs  hbsad-bstat utage    '4'
                              rf140-wrshb  hbsad-waers.
      ENDIF.
      IF NOT rart-alt IS INITIAL.
        IF rbldat IS INITIAL.
          atage =  rf140-vstid - hbsad-budat.
        ELSE.
          atage =  rf140-vstid - hbsad-bldat.
        ENDIF.
        PERFORM fill_waehrungsfelder_bseg.
        PERFORM rastern USING hbsad-bukrs  hbsad-bstat atage    '5'
                              rf140-wrshb  hbsad-waers.
      ENDIF.
    ENDIF.
  ELSE.
    IF hbsak-augdt GT rf140-vstid.
      IF NOT rart-net IS INITIAL.
        ntage = hbsak-netdt - rf140-vstid.
        PERFORM fill_waehrungsfelder_bseg.
        PERFORM rastern USING hbsak-bukrs  hbsak-bstat ntage    '1'
                              rf140-wrshb  hbsak-waers.
      ENDIF.
      IF NOT rart-sk1 IS INITIAL.
*       IF  NOT BSAK-ZBD1T IS INITIAL
*       AND NOT BSAK-ZBD2T IS INITIAL.
*         IF NOT HBSAK-ZFBDT IS INITIAL.
*           STAGE = HBSAK-ZFBDT + HBSAK-ZBD1T - RF140-VSTID.
*         ELSE.
*           STAGE = HBSAK-BLDAT + HBSAK-ZBD1T - RF140-VSTID.
*         ENDIF.
        stage = faede-sk1dt - rf140-vstid.
        PERFORM fill_waehrungsfelder_bseg.
        PERFORM rastern USING hbsak-bukrs  hbsak-bstat stage    '2'
                              rf140-wrshb  hbsak-waers.
*       ENDIF.
      ENDIF.
      IF NOT rart-sk2 IS INITIAL.
*       IF  NOT BSIK-ZBD2T IS INITIAL
*       AND NOT BSIK-ZBD3T IS INITIAL.
*         IF NOT HBSAK-ZBD2T IS INITIAL.
*           IF NOT HBSAK-ZFBDT IS INITIAL.
*             TTAGE = HBSAK-ZFBDT +  HBSAK-ZBD2T - RF140-VSTID.
*           ELSE.
*             TTAGE = HBSAK-BLDAT +  HBSAK-ZBD2T - RF140-VSTID.
*           ENDIF.
*         ELSE.
*           IF NOT HBSAK-ZFBDT IS INITIAL.
*             TTAGE = HBSAK-ZFBDT +  HBSAK-ZBD1T - RF140-VSTID.
*           ELSE.
*             TTAGE = HBSAK-BLDAT +  HBSAK-ZBD1T - RF140-VSTID.
*           ENDIF.
*         ENDIF.
        ttage = faede-sk2dt - rf140-vstid.
        PERFORM fill_waehrungsfelder_bseg.
        PERFORM rastern USING hbsak-bukrs  hbsak-bstat ttage    '3'
                              rf140-wrshb  hbsak-waers.
*       ENDIF.
      ENDIF.
      IF NOT rart-ueb IS INITIAL.
        utage =  rf140-vstid - hbsak-netdt.
        PERFORM fill_waehrungsfelder_bseg.
        PERFORM rastern USING hbsak-bukrs  hbsak-bstat utage    '4'
                              rf140-wrshb  hbsak-waers.
      ENDIF.
      IF NOT rart-alt IS INITIAL.
        IF rbldat IS INITIAL.
          atage =  rf140-vstid - hbsak-budat.
        ELSE.
          atage =  rf140-vstid - hbsak-bldat.
        ENDIF.
        PERFORM fill_waehrungsfelder_bseg.
        PERFORM rastern USING hbsak-bukrs  hbsak-bstat atage    '5'
                              rf140-wrshb  hbsak-waers.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "POSTEN_RASTERN_2

*-----------------------------------------------------------------------
*       FORM PRUEFEN_BSAD
*-----------------------------------------------------------------------
FORM pruefen_bsad.
  CLEAR hbetrag.
  CLEAR augbetr.
  LOOP AT hbsad.
    IF hbsad-bstat NE 'S'.
      IF hbsad-augdt LE datum02.
        IF hbsad-shkzg = 'H'.
          hbetrag = hbsad-dmbtr * -1.
          augbetr = augbetr + hbetrag.
          CLEAR hbetrag.
        ELSE.
          augbetr = augbetr + hbsad-dmbtr.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF augbetr NE '0'.
*   evtl fehler durch zu frühen reorg von ausgeglichenen Belegen
    CLEAR fimsg.
    fimsg-msort = '    '. fimsg-msgid = 'FB'.
    fimsg-msgty = 'I'.
    fimsg-msgno = '815'.
    fimsg-msgv1 = save_bukrs.
    fimsg-msgv2 = 'D'.
    fimsg-msgv3 = save_kunnr.
    PERFORM message_append.
  ENDIF.
ENDFORM.                    "PRUEFEN_BSAD

*-----------------------------------------------------------------------
*       FORM PRUEFEN_BSAK
*-----------------------------------------------------------------------
FORM pruefen_bsak.
  CLEAR hbetrag.
  CLEAR augbetr.
  LOOP AT hbsak.
    IF hbsak-bstat NE 'S'.
      IF hbsak-augdt LE datum02.
        IF hbsak-shkzg = 'H'.
          hbetrag = hbsak-dmbtr * -1.
          augbetr = augbetr + hbetrag.
          CLEAR hbetrag.
        ELSE.
          augbetr = augbetr + hbsak-dmbtr.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF augbetr NE '0'.
*   evtl fehler durch zu frühen reorg von ausgeglichenen Belegen
    CLEAR fimsg.
    fimsg-msort = '    '. fimsg-msgid = 'FB'.
    fimsg-msgty = 'I'.
    fimsg-msgno = '815'.
    fimsg-msgv1 = save_bukrs.
    fimsg-msgv2 = 'D'.
    fimsg-msgv3 = save_lifnr.
    PERFORM message_append.
  ENDIF.

ENDFORM.                    "PRUEFEN_BSAK

*-----------------------------------------------------------------------
*       FORM RASTER_AUSBAU
*-----------------------------------------------------------------------
FORM raster_aufbau.

* Obergrenze Intervall -----------------------------------------------*
  rp01 = rastbis1.
  rp02 = rastbis2.
  rp03 = rastbis3.
  rp04 = rastbis4.
  rp05 = rastbis5.

* Untergrenze Intervall -----------------------------------------------*

  rp06 = rp01 + 1.
  IF NOT rp02 IS INITIAL.
    rp07 = rp02 + 1.
  ENDIF.
  IF NOT rp03 IS INITIAL.
    rp08 = rp03 + 1.
  ENDIF.
  IF NOT rp04 IS INITIAL.
    rp09 = rp04 + 1.
  ENDIF.
  IF NOT rp05 IS INITIAL.
    rp10 = rp05 + 1.
  ENDIF.

  CLEAR rf140-rpt01. rf140-rpt01 = rp01.
  CLEAR rf140-rpt02. rf140-rpt02 = rp02.
  CLEAR rf140-rpt03. rf140-rpt03 = rp03.
  CLEAR rf140-rpt04. rf140-rpt04 = rp04.
  CLEAR rf140-rpt05. rf140-rpt05 = rp05.
  CLEAR rf140-rpt06. rf140-rpt06 = rp06.
  CLEAR rf140-rpt07. rf140-rpt07 = rp07.
  CLEAR rf140-rpt08. rf140-rpt08 = rp08.
  CLEAR rf140-rpt09. rf140-rpt09 = rp09.
  CLEAR rf140-rpt10. rf140-rpt10 = rp10.

ENDFORM.                    "RASTER_AUFBAU

*-----------------------------------------------------------------------
*       FORM RASTERN
*-----------------------------------------------------------------------
FORM rastern USING r_bukrs r_bstat r_tage r_art r_betrag r_waers.
  CLEAR rtab.
  rtab-bukrs = r_bukrs.
* RTAB-BSTAT = R_BSTAT.
  rtab-raart = r_art.
  rtab-waers = r_waers.
  rtab-opsum = r_betrag.

  IF r_tage <= rp01.
    MOVE: r_betrag TO rtab-rast1.
  ELSE.
    IF r_tage <= rp02
    OR rp07 IS INITIAL.
      MOVE: r_betrag TO rtab-rast2.
    ELSE.
      IF r_tage <= rp03
      OR rp08 IS INITIAL.
        MOVE: r_betrag TO rtab-rast3.
      ELSE.
        IF r_tage <= rp04
        OR rp09 IS INITIAL.
          MOVE: r_betrag TO rtab-rast4.
        ELSE.
          IF r_tage <= rp05
          OR rp10 IS INITIAL.
            MOVE: r_betrag TO rtab-rast5.
          ELSE.
            MOVE: r_betrag TO rtab-rast6.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  COLLECT rtab.
ENDFORM.                    "RASTERN

*-----------------------------------------------------------------------
*       FORM SAVE_EMPFAENGER_ADRESSE
*-----------------------------------------------------------------------
FORM save_empfaenger_adresse.
  IF rindko IS INITIAL.
    CLEAR save_langu.
  ENDIF.
  IF hdkoart = 'D'.
    CLEAR dkadr.
    MOVE-CORRESPONDING kna1 TO dkadr.
    MOVE-CORRESPONDING knb1 TO dkadr.
    MOVE kna1-kunnr         TO dkadr-konto.
    MOVE t001-land1         TO dkadr-inlnd.
    IF rindko IS INITIAL.
      save_langu = kna1-spras.
    ENDIF.
  ELSE.
    CLEAR dkadr.
    MOVE-CORRESPONDING lfa1 TO dkadr.
    MOVE-CORRESPONDING lfb1 TO dkadr.
    MOVE lfa1-lifnr         TO dkadr-konto.
    MOVE t001-land1         TO dkadr-inlnd.
    IF rindko IS INITIAL.
      save_langu = lfa1-spras.
    ENDIF.
  ENDIF.
  save_koart = hdkoart.
  SET COUNTRY dkadr-land1.
ENDFORM.                    "SAVE_EMPFAENGER_ADRESSE

*-----------------------------------------------------------------------
*       FORM SAVE_ZENTRALE_ADRESSE
*-----------------------------------------------------------------------
FORM save_zentrale_adresse.
* CLEAR SAVE_LANGU.
* IF HDKOART = 'D'.
*   CLEAR ADRZE.
*   MOVE-CORRESPONDING KNA1 TO ADRZE.
*   MOVE-CORRESPONDING KNB1 TO ADRZE.
*   MOVE KNA1-KUNNR         TO ADRZE-KONTO.
*   MOVE T001-LAND1         TO ADRZE-INLND.
*
* ELSE.
*   CLEAR ADRZE.
*   MOVE-CORRESPONDING LFA1 TO ADRZE.
*   MOVE-CORRESPONDING LFB1 TO ADRZE.
*   MOVE LFA1-LIFNR         TO ADRZE-KONTO.
*   MOVE T001-LAND1         TO ADRZE-INLND.
* ENDIF.
ENDFORM.                    "SAVE_ZENTRALE_ADRESSE

*-----------------------------------------------------------------------
*       FORM SELECTION_OHNE_BKORM
*-----------------------------------------------------------------------
FORM selection_ohne_bkorm.
  IF 'D' IN rkoart.
    SELECT * FROM kna1
      WHERE kunnr IN rkonto.
*     CLEAR XKAUSG.
*     IF NOT KNA1-XCPDK IS INITIAL.
*       CLEAR FIMSG.
*       FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
*       FIMSG-MSGTY = 'I'.
*       FIMSG-MSGNO = '812'.
*       FIMSG-MSGV1 = 'D'.
*       FIMSG-MSGV2 = KNA1-KUNNR.
*       PERFORM MESSAGE_APPEND.
*       XKAUSG = 'X'.
*       CHECK KNA1-XCPDK = SPACE.
*     ENDIF.
      SELECT * FROM knb1
        WHERE bukrs IN rbukrs
        AND   kunnr =  kna1-kunnr.
        CLEAR save_bbukr.
        IF NOT t048-xbukr IS INITIAL.
          save_bbukr = knb1-bukrs.
          CALL FUNCTION 'CORRESPONDENCE_GET_LEADING_CC'
            EXPORTING
              i_bukrs = knb1-bukrs
            IMPORTING
              e_bukrs = save_bukrs.
        ELSE.
          save_bukrs = knb1-bukrs.
        ENDIF.

        IF rindko IS INITIAL.
*-------Headerfelder für Extract----------------------------------------
          hdbukrs       = save_bukrs.
          hdkoart       = 'D'.
          hdkonto       = knb1-kunnr.
          hdbelgj       = '    '.
          hdkoar2       = 'D'.
          hdkont2       = knb1-kunnr.
          hdusnam       = sy-uname.
          hddatum       = sy-datum.
          hduzeit       = sy-uzeit.

*-------Datenfelder für Extract-----------------------------------------
          extract(1)    = 'X'.
          datum01       = budat01.
          datum02       = budat02.
          IF NOT save_rxbukr IS INITIAL.
            dabbukr = save_bbukr.
          ELSE.
            dabbukr = '    '.
          ENDIF.
          xbkorm        = ' '.
          save_koart = 'D'.
          save_kunnr = knb1-kunnr.
*         SAVE_BUKRS = KNB1-BUKRS.
          PERFORM sortierung USING 'K' 'K' ' '.
          PERFORM extract.
        ELSE.
          CLEAR hhead.
          hhead-hdbukrs       = save_bukrs.
          hhead-hdkoart       = 'D'.
          hhead-hdkonto       = knb1-kunnr.
          hhead-hdbelgj       = '    '.
          hhead-hdusnam       = sy-uname.
          hhead-hddatum       = sy-datum.
          hhead-hduzeit       = sy-uzeit.
          save_koart = 'D'.
          save_kunnr = knb1-kunnr.
*         SAVE_BUKRS = KNB1-BUKRS.
          PERFORM sortierung USING 'K' 'K' ' '.
          hhead-sortk1 = sortk1.
          hhead-sortk2 = sortk2.
          hhead-sortk3 = sortk3.
          hhead-sortk4 = sortk4.
          hhead-sortk5 = sortk5.
          IF NOT save_rxbukr IS INITIAL.
            hhead-dabbukr = save_bbukr.
          ELSE.
            hhead-dabbukr = '    '.
          ENDIF.
          APPEND hhead.

          htexterf = 'X'.
        ENDIF.
      ENDSELECT.
    ENDSELECT.
  ENDIF.
  IF 'K' IN rkoart.
    SELECT * FROM lfa1
      WHERE lifnr IN rkonto.
*     CLEAR XKAUSG.
*     IF NOT LFA1-XCPDK IS INITIAL.
*       CLEAR FIMSG.
*       FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
*       FIMSG-MSGTY = 'I'.
*       FIMSG-MSGNO = '812'.
*       FIMSG-MSGV1 = 'K'.
*       FIMSG-MSGV2 = LFA1-LIFNR.
*       PERFORM MESSAGE_APPEND.
*       XKAUSG = 'X'.
*       CHECK LFA1-XCPDK = SPACE.
*     ENDIF.
      SELECT * FROM lfb1
        WHERE bukrs IN rbukrs
        AND   lifnr =  lfa1-lifnr.
        CLEAR save_bbukr.
        IF NOT t048-xbukr IS INITIAL.
          save_bbukr = lfb1-bukrs.
          CALL FUNCTION 'CORRESPONDENCE_GET_LEADING_CC'
            EXPORTING
              i_bukrs = lfb1-bukrs
            IMPORTING
              e_bukrs = save_bukrs.
        ELSE.
          save_bukrs = lfb1-bukrs.
        ENDIF.

        IF rindko IS INITIAL.
*-------Headerfelder für Extract----------------------------------------
          hdbukrs       = save_bukrs.
          hdkoart       = 'K'.
          hdkonto       = lfb1-lifnr.
          hdbelgj       = '    '.
          hdkoar2       = 'K'.
          hdkont2       = lfb1-lifnr.
          hdusnam       = sy-uname.
          hddatum       = sy-datum.
          hduzeit       = sy-uzeit.

*-------Datenfelder für Extract-----------------------------------------
          extract(1)    = 'X'.
          datum01       = budat01.
          datum02       = budat02.
          IF NOT save_rxbukr IS INITIAL.
            dabbukr = save_bbukr.
          ELSE.
            dabbukr = '    '.
          ENDIF.
          xbkorm        = ' '.
          save_koart = 'K'.
          save_lifnr = lfb1-lifnr.
*         SAVE_BUKRS = LFB1-BUKRS.
          PERFORM sortierung USING 'K' 'K' ' '.
          PERFORM extract.
        ELSE.
          CLEAR hhead.
          hhead-hdbukrs       = save_bukrs.
          hhead-hdkoart       = 'K'.
          hhead-hdkonto       = lfb1-lifnr.
          hhead-hdbelgj       = '    '.
          hhead-hdusnam       = sy-uname.
          hhead-hddatum       = sy-datum.
          hhead-hduzeit       = sy-uzeit.
          save_koart = 'K'.
          save_lifnr = lfb1-lifnr.
*         SAVE_BUKRS = LFB1-BUKRS.
          PERFORM sortierung USING 'K' 'K' ' '.
          hhead-sortk1 = sortk1.
          hhead-sortk2 = sortk2.
          hhead-sortk3 = sortk3.
          hhead-sortk4 = sortk4.
          hhead-sortk5 = sortk5.
          IF NOT save_rxbukr IS INITIAL.
            hhead-dabbukr = save_bbukr.
          ELSE.
            hhead-dabbukr = '    '.
          ENDIF.
          APPEND hhead.

          htexterf = 'X'.
        ENDIF.
      ENDSELECT.
    ENDSELECT.
  ENDIF.
  IF NOT htexterf IS INITIAL.
    SORT hhead.
    LOOP AT hhead.
      CLEAR   hfunktion.
      CLEAR   htdname.
      CLEAR   htdspras.
      CLEAR   htheader.
      CLEAR   htlines.
      REFRESH htlines.

      CALL FUNCTION 'CORRESPONDENCE_TEXT'
        EXPORTING
          i_bukrs        = hhead-hdbukrs
          i_event        = revent
          i_spras        = rspras
        IMPORTING
          e_function     = hfunktion
          e_tdname       = htdname
          e_tdspras      = htdspras
          e_thead        = htheader
        TABLES
          lines          = htlines
        EXCEPTIONS
          no_event_found = 02
          no_spras       = 06.

      CASE sy-subrc.
        WHEN 0.
          CASE hfunktion.
            WHEN ' '.
              MESSAGE e500 WITH revent.
            WHEN '1'.
*-------Headerfelder für Extract ---------------------------------------
              hdbukrs = hhead-hdbukrs.
              hdkoart = hhead-hdkoart.
              hdkonto = hhead-hdkonto.
              hdbelgj = hhead-hdbelgj.
              hdkoar2 = hhead-hdkoart.
              hdkont2 = hhead-hdkonto.
              hdusnam = hhead-hdusnam.
              hddatum = hhead-hddatum.
              hduzeit = hhead-hduzeit.
              sortk1  = hhead-sortk1.
              sortk2  = hhead-sortk2.
              sortk3  = hhead-sortk3.
              sortk4  = hhead-sortk4.
              sortk5  = hhead-sortk5.

*-------Datenfelder für Extract-----------------------------------------
              extract(1)    = 'X'.
              datum01       = budat01.
              datum02       = budat02.
              dabbukr       = hhead-dabbukr.
              xbkorm        = ' '.

              CALL FUNCTION 'SAVE_TEXT'
                EXPORTING
                  header          = htheader
*                 INSERT          = 'X'
                  savemode_direct = 'X'
                IMPORTING
                  newheader       = htheader
                TABLES
                  lines           = htlines.
*                   EXCEPTIONS
*                       ID              = 01
*                       LANGUAGE        = 02
*                       NAME            = 03
*                       OBJECT          = 04.

              CLEAR hthead.
              MOVE-CORRESPONDING htheader TO hthead.
              APPEND hthead.

              paramet+22(40) = htdname.
              paramet+62(1)  = htdspras.
              PERFORM extract.
            WHEN '2'.
              MESSAGE i807 WITH hhead-hdbukrs
                                hhead-dabelnr hhead-dagjahr.
          ENDCASE.
        WHEN 2.
          MESSAGE e806 WITH hhead-hdbukrs revent.
        WHEN 6.
          MESSAGE e511 WITH rspras.
      ENDCASE.
    ENDLOOP.
  ENDIF.
  CLEAR   hhead.
  REFRESH hhead.
ENDFORM.                    "SELECTION_OHNE_BKORM

*-----------------------------------------------------------------------
*       FORM UMSKZ_ASSIGN
*-----------------------------------------------------------------------
FORM umskz_assign.
  IF NOT xumskz IS INITIAL.
    CASE hpumsk.
      WHEN '1'.
        ASSIGN dopos-sortp1 TO <umskz1>.
        ASSIGN kopos-sortp1 TO <umskz2>.
*       ASSIGN HBSID-SORTP1 TO <UMSKZ3>.
*       ASSIGN HBSIK-SORTP1 TO <UMSKZ4>.
        ASSIGN dmpos-sortp1 TO <umskz5>.
        ASSIGN kmpos-sortp1 TO <umskz6>.
      WHEN '2'.
        ASSIGN dopos-sortp2 TO <umskz1>.
        ASSIGN kopos-sortp2 TO <umskz2>.
*       ASSIGN HBSID-SORTP2 TO <UMSKZ3>.
*       ASSIGN HBSIK-SORTP2 TO <UMSKZ4>.
        ASSIGN dmpos-sortp2 TO <umskz5>.
        ASSIGN kmpos-sortp2 TO <umskz6>.
      WHEN '3'.
        ASSIGN dopos-sortp3 TO <umskz1>.
        ASSIGN kopos-sortp3 TO <umskz2>.
*       ASSIGN HBSID-SORTP3 TO <UMSKZ3>.
*       ASSIGN HBSIK-SORTP3 TO <UMSKZ4>.
        ASSIGN dmpos-sortp3 TO <umskz5>.
        ASSIGN kmpos-sortp3 TO <umskz6>.
      WHEN '4'.
        ASSIGN dopos-sortp4 TO <umskz1>.
        ASSIGN kopos-sortp4 TO <umskz2>.
*       ASSIGN HBSID-SORTP4 TO <UMSKZ3>.
*       ASSIGN HBSIK-SORTP4 TO <UMSKZ4>.
        ASSIGN dmpos-sortp4 TO <umskz5>.
        ASSIGN kmpos-sortp4 TO <umskz6>.
      WHEN '5'.
        ASSIGN dopos-sortp5 TO <umskz1>.
        ASSIGN kopos-sortp5 TO <umskz2>.
*       ASSIGN HBSID-SORTP5 TO <UMSKZ3>.
*       ASSIGN HBSIK-SORTP5 TO <UMSKZ4>.
        ASSIGN dmpos-sortp5 TO <umskz5>.
        ASSIGN kmpos-sortp5 TO <umskz6>.
    ENDCASE.
  ENDIF.
ENDFORM.                    "UMSKZ_ASSIGN

*-----------------------------------------------------------------------
*       FORM VERBAND
*-----------------------------------------------------------------------
FORM verband.
  IF hdkoart = 'D'.
    CLEAR   hkna1.
    REFRESH hkna1.
    CLEAR   hknb1.
    REFRESH hknb1.
*   CLEAR   HLFA1.
*   REFRESH HLFA1.
*   CLEAR   HLFB1.
*   REFRESH HLFB1.
    CLEAR   filialen.
    REFRESH filialen.

    SELECT * FROM knb1 INTO *knb1                       "#EC CI_NOFIRST
      WHERE bukrs = save_bukrs
      AND   ekvbd = save_kunnr.
      filialen-zentrale = save_kunnr.
      filialen-filiale  = *knb1-kunnr.
      APPEND filialen.
      MOVE-CORRESPONDING *knb1 TO hknb1.
      APPEND hknb1.
      SELECT SINGLE * FROM kna1 INTO *kna1
        WHERE kunnr = *knb1-kunnr.
      MOVE-CORRESPONDING *kna1 TO hkna1.
      APPEND hkna1.
    ENDSELECT.
  ENDIF.
ENDFORM.                    "VERBAND

*-----------------------------------------------------------------------
*       FORM VERZUGSTAGE
*-----------------------------------------------------------------------
FORM verzugstage.
  CLEAR refe3.
  CLEAR netdt.
  CLEAR faede.
  IF hdkoart = 'D'.
    IF hbsid-augbl IS INITIAL.
*     NETDT = HBSID-ZFBDT.
*     IF NETDT IS INITIAL.
*       NETDT = HBSID-BLDAT.
*     ENDIF.
*     IF NOT HBSID-ZBD3T IS INITIAL.
*       REFE3 = HBSID-ZBD3T.
*     ELSE.
*       IF NOT HBSID-ZBD2T IS INITIAL.
*         REFE3 = HBSID-ZBD2T.
*       ELSE.
*         REFE3 = HBSID-ZBD1T.
*       ENDIF.
*     ENDIF.
*     IF HBSID-SHKZG = 'H'.
*       IF HBSID-REBZG IS INITIAL.
*         REFE3 = 0.
*       ENDIF.
*     ENDIF.
*     NETDT = NETDT + REFE3.

      CLEAR faede.
      MOVE-CORRESPONDING hbsid TO faede.
      faede-koart = 'D'.
      CALL FUNCTION 'DETERMINE_DUE_DATE'
        EXPORTING
          i_faede = faede
        IMPORTING
          e_faede = faede
        EXCEPTIONS
          OTHERS  = 1.

      hbsid-vztas = rf140-vstid - faede-netdt.
      hbsid-netdt = faede-netdt.
    ENDIF.
    CLEAR refe3.
    CLEAR netdt.
  ELSE.
    IF hbsik-augbl IS INITIAL.
*     NETDT = HBSIK-ZFBDT.
*     IF NETDT IS INITIAL.
*       NETDT = HBSIK-BLDAT.
*     ENDIF.
*     IF NOT HBSIK-ZBD3T IS INITIAL.
*       REFE3 = HBSIK-ZBD3T.
*     ELSE.
*       IF NOT HBSIK-ZBD2T IS INITIAL.
*         REFE3 = HBSIK-ZBD2T.
*       ELSE.
*         REFE3 = HBSIK-ZBD1T.
*       ENDIF.
*     ENDIF.
*     IF HBSIK-SHKZG = 'S'.
*       IF HBSIK-REBZG IS INITIAL.
*         REFE3 = 0.
*       ENDIF.
*     ENDIF.
*     NETDT = NETDT + REFE3.

      CLEAR faede.
      MOVE-CORRESPONDING hbsik TO faede.
      faede-koart = 'K'.
      CALL FUNCTION 'DETERMINE_DUE_DATE'
        EXPORTING
          i_faede = faede
        IMPORTING
          e_faede = faede
        EXCEPTIONS
          OTHERS  = 1.

      hbsik-vztas = rf140-vstid - faede-netdt.
      hbsik-netdt = faede-netdt.
    ENDIF.
    CLEAR refe3.
    CLEAR netdt.
  ENDIF.
ENDFORM.                    "VERZUGSTAGE

*-----------------------------------------------------------------------
*       FORM VERZUGSTAGE_2
*-----------------------------------------------------------------------
FORM verzugstage_2.
  CLEAR refe3.
  CLEAR netdt.
  CLEAR faede.
  IF hdkoart = 'D'.
    IF hbsad-augdt GT rf140-vstid.
*     NETDT = HBSAD-ZFBDT.
*     IF NETDT IS INITIAL.
*       NETDT = HBSAD-BLDAT.
*     ENDIF.
*     IF NOT HBSAD-ZBD3T IS INITIAL.
*       REFE3 = HBSAD-ZBD3T.
*     ELSE.
*       IF NOT HBSAD-ZBD2T IS INITIAL.
*         REFE3 = HBSAD-ZBD2T.
*       ELSE.
*         REFE3 = HBSAD-ZBD1T.
*       ENDIF.
*     ENDIF.
*     IF HBSAD-SHKZG = 'H'.
*       IF HBSAD-REBZG IS INITIAL.
*         REFE3 = 0.
*       ENDIF.
*     ENDIF.
*     NETDT = NETDT + REFE3.

      CLEAR faede.
      MOVE-CORRESPONDING hbsad TO faede.
      faede-koart = 'D'.
      CALL FUNCTION 'DETERMINE_DUE_DATE'
        EXPORTING
          i_faede = faede
        IMPORTING
          e_faede = faede
        EXCEPTIONS
          OTHERS  = 1.

      hbsad-vztas = rf140-vstid - faede-netdt.
      hbsad-netdt = faede-netdt.
    ENDIF.
    CLEAR refe3.
    CLEAR netdt.
  ELSE.
    IF hbsak-augdt GT rf140-vstid.
*     NETDT = HBSAK-ZFBDT.
*     IF NETDT IS INITIAL.
*       NETDT = HBSAK-BLDAT.
*     ENDIF.
*     IF NOT HBSAK-ZBD3T IS INITIAL.
*       REFE3 = HBSAK-ZBD3T.
*     ELSE.
*       IF NOT HBSAK-ZBD2T IS INITIAL.
*         REFE3 = HBSAK-ZBD2T.
*       ELSE.
*         REFE3 = HBSAK-ZBD1T.
*       ENDIF.
*     ENDIF.
*     IF HBSAK-SHKZG = 'S'.
*       IF HBSAK-REBZG IS INITIAL.
*         REFE3 = 0.
*       ENDIF.
*     ENDIF.
*     NETDT = NETDT + REFE3.

      CLEAR faede.
      MOVE-CORRESPONDING hbsak TO faede.
      faede-koart = 'K'.
      CALL FUNCTION 'DETERMINE_DUE_DATE'
        EXPORTING
          i_faede = faede
        IMPORTING
          e_faede = faede
        EXCEPTIONS
          OTHERS  = 1.

      hbsak-vztas = rf140-vstid - faede-netdt.
      hbsak-netdt = faede-netdt.
    ENDIF.
    CLEAR refe3.
    CLEAR netdt.
  ENDIF.
ENDFORM.                    "VERZUGSTAGE_2

*-----------------------------------------------------------------------
*       FORM WHERE_KLAUSEL
*-----------------------------------------------------------------------
FORM where_klausel.
  REFRESH bsi_where.
  REFRESH bsa_where.
  CASE save_rdatar.
    WHEN ' '.
      CONCATENATE 'BUDAT LE ''' datum02 '''' INTO bsi_where.
      APPEND bsi_where.
      CONCATENATE 'BUDAT LE ''' datum02 '''' INTO bsa_where.
      APPEND bsa_where.
    WHEN '1'.
      CONCATENATE 'CPUDT LE ''' datum02 '''' INTO bsi_where.
      APPEND bsi_where.
      CONCATENATE 'CPUDT LE ''' datum02 '''' INTO bsa_where.
      APPEND bsa_where.
    WHEN '2'.
      CONCATENATE 'BLDAT LE ''' datum02 '''' INTO bsi_where.
      APPEND bsi_where.
      CONCATENATE 'BLDAT LE ''' datum02 '''' INTO bsa_where.
      APPEND bsa_where.
  ENDCASE.
ENDFORM.                    "WHERE_KLAUSEL

*-----------------------------------------------------------------------
*       FORM ZENTRALE
*-----------------------------------------------------------------------
FORM zentrale.
* CLEAR   DFOPO.
* REFRESH DFOPO.
* CLEAR   FBSID.
* REFRESH FBSID.
* CLEAR   FBSIK.
* REFRESH FBSIK.
  CLEAR   hkna1.
  REFRESH hkna1.
  CLEAR   hknb1.
  REFRESH hknb1.
  CLEAR   hlfa1.
  REFRESH hlfa1.
  CLEAR   hlfb1.
  REFRESH hlfb1.
* CLEAR   KFOPO.
* REFRESH KFOPO.
  CLEAR   filialen.
  REFRESH filialen.
* CLEAR HXDEZV.

  IF hdkoart = 'D'.
    IF NOT xzent IS INITIAL.
*------ löschen von Filialsätzen bei Zentralen mit dezentraler Verw.----
*------ und Übernahme in eigene Hilfstabelle----------------------------
      LOOP AT hbsid.
        IF NOT hbsid-filkd IS INITIAL.
*         IF NOT KNB1-XDEZV IS INITIAL.
*           MOVE-CORRESPONDING HBSID TO FBSID.
*           APPEND FBSID.
*           PERFORM DEBITOREN_DATEN.
*           DELETE HBSID.
*           HXDEZV = 'X'.
*         ELSE.
          MOVE hbsid-kunnr TO filialen-zentrale.
          MOVE hbsid-filkd TO filialen-filiale.
          COLLECT filialen.
          PERFORM debitoren_daten.
*         ENDIF.
        ENDIF.
      ENDLOOP.
      LOOP AT dopos.
        IF NOT dopos-filkd IS INITIAL.
*         IF NOT KNB1-XDEZV IS INITIAL.
*           MOVE-CORRESPONDING DOPOS TO DFOPO.
*           APPEND DFOPO.
*           XOPOS = 'X'.
*           PERFORM DEBITOREN_DATEN.
*           CLEAR XOPOS.
*           DELETE DOPOS.
*           HXDEZV = 'X'.
*         ELSE.
          MOVE dopos-kunnr TO filialen-zentrale.
          MOVE dopos-filkd TO filialen-filiale.
          COLLECT filialen.
          xopos = 'X'.
          PERFORM debitoren_daten.
          CLEAR xopos.
*         ENDIF.
        ENDIF.
      ENDLOOP.
      LOOP AT dmpos.
        IF NOT dmpos-filkd IS INITIAL.
*         IF NOT KNB1-XDEZV IS INITIAL.
*           MOVE-CORRESPONDING DOPOS TO DFOPO.
*           APPEND DFOPO.
*           XOPOS = 'X'.
*           PERFORM DEBITOREN_DATEN.
*           CLEAR XOPOS.
*           DELETE DOPOS.
*           HXDEZV = 'X'.
*         ELSE.
          MOVE dmpos-kunnr TO filialen-zentrale.
          MOVE dmpos-filkd TO filialen-filiale.
          COLLECT filialen.
          xmpos = 'X'.
          PERFORM debitoren_daten.
          CLEAR xmpos.
*         ENDIF.
        ENDIF.
      ENDLOOP.
*     LOOP AT HBSAD.
*       IF NOT HBSAD-FILKD IS INITIAL.
*         IF NOT KNB1-XDEZV IS INITIAL.
*           MOVE-CORRESPONDING HBSAD TO FBSID.
*           APPEND FBSID.
*           DELETE HBSAD.
*           HXDEZV = 'X'.
*         ELSE.
*           MOVE HBSAD-KUNNR TO FILIALEN-ZENTRALE.
*           MOVE HBSAD-FILKD TO FILIALEN-FILIALE.
*           COLLECT FILIALEN.
*         ENDIF.
*       ENDIF.
*     ENDLOOP.
*     IF HXDEZV IS INITIAL.
      SORT filialen.
*     ELSE.
*       SORT FBSID BY FILKD.
*       SORT DFOPO BY FILKD.
*     ENDIF.
    ENDIF.
  ELSE.
    IF NOT xzent IS INITIAL.
      LOOP AT hbsik.
        IF NOT hbsik-filkd IS INITIAL.
*         IF NOT LFB1-XDEZV IS INITIAL.
*           MOVE-CORRESPONDING HBSIK TO FBSIK.
*           APPEND FBSIK.
*           PERFORM KREDITOREN_DATEN.
*           DELETE HBSIK.
*           HXDEZV = 'X'.
*         ELSE.
          MOVE hbsik-lifnr TO filialen-zentrale.
          MOVE hbsik-filkd TO filialen-filiale.
          COLLECT filialen.
          PERFORM kreditoren_daten.
*         ENDIF.
        ENDIF.
      ENDLOOP.
      LOOP AT kopos.
        IF NOT kopos-filkd IS INITIAL.
*         IF NOT LFB1-XDEZV IS INITIAL.
*           MOVE-CORRESPONDING KOPOS TO KFOPO.
*           APPEND KFOPO.
*           XOPOS = 'X'.
*           PERFORM KREDITOREN_DATEN.
*           CLEAR XOPOS.
*           DELETE KOPOS.
*           HXDEZV = 'X'.
*         ELSE.
          MOVE kopos-lifnr TO filialen-zentrale.
          MOVE kopos-filkd TO filialen-filiale.
          COLLECT filialen.
          xopos = 'X'.
          PERFORM kreditoren_daten.
          CLEAR xopos.
*         ENDIF.
        ENDIF.
      ENDLOOP.
      LOOP AT kmpos.
        IF NOT kmpos-filkd IS INITIAL.
*         IF NOT LFB1-XDEZV IS INITIAL.
*           MOVE-CORRESPONDING KOPOS TO KFOPO.
*           APPEND KFOPO.
*           XOPOS = 'X'.
*           PERFORM KREDITOREN_DATEN.
*           CLEAR XOPOS.
*           DELETE KOPOS.
*           HXDEZV = 'X'.
*         ELSE.
          MOVE kmpos-lifnr TO filialen-zentrale.
          MOVE kmpos-filkd TO filialen-filiale.
          COLLECT filialen.
          xmpos = 'X'.
          PERFORM kreditoren_daten.
          CLEAR xmpos.
*         ENDIF.
        ENDIF.
      ENDLOOP.
*     LOOP AT HBSAK.
*       IF NOT HBSAK-FILKD IS INITIAL.
*         IF NOT LFB1-XDEZV IS INITIAL.
*           MOVE-CORRESPONDING HBSAK TO FBSIK.
*           APPEND FBSIK.
*           DELETE HBSAK.
*           HXDEZV = 'X'.
*         ELSE.
*           MOVE HBSAK-LIFNR TO FILIALEN-ZENTRALE.
*           MOVE HBSAK-FILKD TO FILIALEN-FILIALE.
*           COLLECT FILIALEN.
*         ENDIF.
*       ENDIF.
*     ENDLOOP.
*     IF HXDEZV IS INITIAL.
      SORT filialen.
*     ELSE.
*       SORT FBSIK BY FILKD.
*       SORT KFOPO BY FILKD.
*     ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "ZENTRALE
