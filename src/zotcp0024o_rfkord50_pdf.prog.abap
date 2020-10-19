************************************************************************
* PROGRAM    :  ZOTCP0024O_RFKORD50_PDF                                *
* TITLE      :  OTC_FDD_0024: Print program for Debit/Credit form      *
* DEVELOPER  :  Gautam NAG                                             *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_FDD_0024                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: This report is copied form the std print program        *
*              RFKORD50_PDF to add the email sending functionality and *
*              add a document type check before sending the meil. The  *
*              output would be triggered only if the doucment type is  *
*              not DG or DR
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 24-SEP-2013 GNAG     E1DK911667 INITIAL DEVELOPMENT - CR#768         *
*&---------------------------------------------------------------------*

*=======================================================================
*       Druckprogramm: Belegauszüge
*=======================================================================


*=======================================================================
*       Das Programm includiert
*
*       RFKORI00 Datendeklaration
*       RFKORI35 Belegauszüge
*       RFKORI70 Beleganalyseroutinen
*       RFKORI73 Beleganalyseroutinen
*       RFKORI80 Leseroutinen
*       RFKORI90 Allgemeine Unterroutinen
*       RFKORI91 Routinen für Extract
*       RFKORI92 Allgemeine Unterroutinen für Druck
*       RFKORI93 Allgemeine Unterroutinen für Messages und Protokoll
*       RFKORIEX User-Exits für Korrespondenz
*=======================================================================


*=======================================================================
*       Report-Header
*=======================================================================
REPORT RFKORD50 MESSAGE-ID FB
                NO STANDARD PAGE HEADING.

*=======================================================================
*       Datenteil
*=======================================================================
INCLUDE RFKORI00.

*-----------------------------------------------------------------------
*       Tables (RFKORI00)
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
*       Datenfelder für den Report RFKORD00
*
*       Teil 1 : Einzelfelder (RFKORI00)
*       Teil 2 : Strukturen (RFKORI00 und RFKORI00)
*       Teil 3 : Interne Tabellen (RFKORI00 und RFKORI00)
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
BEGIN_OF_BLOCK 2.
PARAMETERS:     RFORID   LIKE RFPDO1-ALLGEVFO,
                RTKOID   LIKE RFPDO1-ALLGEVST.

PARAMETERS:     SORTVK   LIKE RFPDO1-KORDVARK.
PARAMETERS:     SORTVP   LIKE RFPDO1-KORDVARP.

SELECT-OPTIONS: BSCHL    FOR  BSEG-BSCHL,
                UMSKZ    FOR  BSEG-UMSKZ.
PARAMETERS:     STATBL   LIKE RFPDO-BPETSBEL.
PARAMETERS:     XUMSST   AS CHECKBOX.
PARAMETERS:     XUMStn   AS CHECKBOX.
END_OF_BLOCK 2.
BEGIN_OF_BLOCK 8.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) TEXT-110 FOR FIELD TDDEST.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS      TDDEST   LIKE TSP01-RQDEST VISIBLE LENGTH 11.
SELECTION-SCREEN POSITION POS_HIGH.
PARAMETERS      RIMMD    LIKE RFPDO2-F140IMMD DEFAULT ' '.
SELECTION-SCREEN COMMENT 61(15) TEXT-111 FOR FIELD RIMMD.
SELECTION-SCREEN END OF LINE.
PARAMETERS:     PRDEST   LIKE TSP01-RQDEST VISIBLE LENGTH 11.
END_OF_BLOCK 8.
BEGIN_OF_BLOCK 4.
SELECT-OPTIONS: RBUKRS   FOR  BKORM-BUKRS,
                RKOART   FOR  BKORM-KOART NO-DISPLAY,
                RKONTO   FOR  BKORM-KONTO NO-DISPLAY,
                RBELNR   FOR  BKORM-BELNR,
                RGJAHR   FOR  BKORM-GJAHR.

PARAMETERS:     RXBKOR   LIKE RFPDO-KORDBKOR.
PARAMETERS:     REVENT   LIKE BKORM-EVENT.
SELECT-OPTIONS: RUSNAM   FOR  BKORM-USNAM.
SELECT-OPTIONS: RDATUM   FOR  BKORM-DATUM.
SELECT-OPTIONS: RUZEIT   FOR  BKORM-UZEIT.
SELECT-OPTIONS: RERLDT   FOR  BKORM-ERLDT.
PARAMETERS:     RXTSUB   LIKE XTSUBM NO-DISPLAY.
PARAMETERS:     RXKONT   LIKE XKONT NO-DISPLAY,
                RXBELG   LIKE XBELG NO-DISPLAY,
                RANZDT   LIKE ANZDT NO-DISPLAY,
                RKAUTO   TYPE C     NO-DISPLAY,
                RSIMUL   TYPE C     NO-DISPLAY,
                RPDEST   LIKE SYST-PDEST NO-DISPLAY,
                TITLE    LIKE RFPDO1-ALLGLINE NO-DISPLAY.

PARAMETERS:     RINDKO   LIKE RFPDO1-KORDINDK.
PARAMETERS:     RSPRAS   LIKE RF140-SPRAS.
*ELECTION-SCREEN BEGIN OF LINE.
*ELECTION-SCREEN COMMENT 1(30) TEXT-100.
*ELECTION-SCREEN POSITION 32.
PARAMETERS KODAT01    LIKE RF140-DATU1.
*ELECTION-SCREEN POSITION 51.
PARAMETERS KODAT02    LIKE RF140-DATU2.
*ELECTION-SCREEN END OF LINE.
END_OF_BLOCK 4.

*=======================================================================
*       Vor dem Selektionsbild
*=======================================================================

*-----------------------------------------------------------------------
*       Initialization
*-----------------------------------------------------------------------
INITIALIZATION.
  GET_FRAME_TITLE: 2, 4, 8.

*=======================================================================
*       Hauptablauf
*=======================================================================

*-----------------------------------------------------------------------
*       Eingabenkonvertierung und Eingabenprüfung
*-----------------------------------------------------------------------
AT SELECTION-SCREEN.
  PERFORM CHECK_EINGABE.

*-----------------------------------------------------------------------
*       Start-of-Selection
*-----------------------------------------------------------------------
SET BLANK LINES ON.

START-OF-SELECTION.
***<<<pdf-enabling
* BEGIN of change - Def#768 / GNAG - 23-Sep-2013
*  save_repid       = 'RFKORD50_PDF'.
*  save_repid_alw   = 'RFKORD50'.
  save_repid       = 'ZOTCP0024O_RFKORD50_PDF'.
  save_repid_alw   = 'ZOTCP0024O_RFKORD50_PDF'.
* END of change - Def#768 / GNAG - 23-Sep-2013
  save_ftype       = '3'. "PDF
***>>>pdf-enabling

  SAVE_EVENT  = REVENT.
*  IF NOT RXBKOR IS INITIAL.
    SAVE_RXBKOR = RXBKOR.
*  ENDIF.
  SAVE_FORID  = RFORID.
  SAVE_TKOID  = RTKOID.
  SAVE_TDDEST = TDDEST.
  SAVE_PRDEST = PRDEST.
  SAVE_PDEST  = RPDEST.
  SAVE_STATBL = STATBL.
  SAVE_RXTSUB = RXTSUB.
  SAVE_RIMMD  = RIMMD.
  SAVE_RINDKO = RINDKO.
* IF SORTKZ =  '1'
* OR SORTKZ =  '2'.
* ELSE.
*   SORTKZ = '2'.
* ENDIF.
* SAVE_SORT   = SORTKZ.
  SAVE_SORTVK  = SORTVK.
  SAVE_SORTVP  = SORTVP.
  SAVE_RSIMUL = RSIMUL.
  SAVE_xumstn = xumstn.
  CLEAR HLP_T021M_K.
  CLEAR HLP_T021M_P.
  IF NOT SAVE_SORTVK  IS INITIAL.
    PERFORM SORT_FELDER USING 'K' 'K'.
  ENDIF.
  IF NOT SAVE_SORTVP  IS INITIAL.
    PERFORM SORT_FELDER USING 'P' '1'.
  ENDIF.
  KAUTOFL = RKAUTO.
  CLEAR XBKORM.
  CLEAR COUNTP.
  LOOP AT BSCHL.
    MOVE-CORRESPONDING BSCHL TO HBSCHL.
    APPEND HBSCHL.
  ENDLOOP.
  LOOP AT UMSKZ.
    MOVE-CORRESPONDING UMSKZ TO HUMSKZ.
    APPEND HUMSKZ.
  ENDLOOP.
  CLEAR   HBUKRS.
  REFRESH HBUKRS.
  LOOP AT RBUKRS.
    MOVE-CORRESPONDING RBUKRS TO HBUKRS.
    APPEND HBUKRS.
  ENDLOOP.
  IF NOT RXTSUB IS INITIAL.
    PERFORM PROT_IMPORT.
  ENDIF.
  PERFORM MESSAGE_INIT.
  perform CURRENCY_CHECK_FOR_PROCESS using save_repid.
  if  alwcheck is initial
  and not alwlines is initial.
    loop at alw_bukrs.
      if alw_bukrs-bukrs in rbukrs.
        alwcheck = 'X'.
      endif.
    endloop.
  endif.

*-----------------------------------------------------------------------
*       Datenselektion
*-----------------------------------------------------------------------
IF T048-EVENT NE SAVE_EVENT.
  PERFORM READ_T048.
ENDIF.
IF NOT RXBKOR IS INITIAL.
  PERFORM FILL_SELECTION_BKORM.
  SORTID = '3'.
  PERFORM READ_BKORM.
ELSE.
  PERFORM SELECTION_OHNE_BKORM.
ENDIF.

*-----------------------------------------------------------------------
*       End-of-Selection
*-----------------------------------------------------------------------
END-OF-SELECTION.

*-------Daten extrahiert ?----------------------------------------------
IF XEXTRA IS INITIAL.
  PERFORM MESSAGE_NO_SELECTION.
ELSE.
*-----------------------------------------------------------------------
*       Sortierung
*-----------------------------------------------------------------------
  SORT BY HDBUKRS SORTK1  SORTK2  SORTK3  SORTK4  SORTK5  HDKOART
          HDKONTO HDBELGJ HDKOAR2 HDKONT2 HDEMPFG HDUSNAM HDDATUM
          HDUZEIT.

*-----------------------------------------------------------------------
*       Ausgabe
*-----------------------------------------------------------------------

  PERFORM BELEGAUSZUG.

ENDIF.

*=======================================================================
*       TOP-OF-PAGE
*=======================================================================
TOP-OF-PAGE.

  PERFORM BATCH-HEADING(RSBTCHH0).
  ULINE.

*=======================================================================
*       Interne Perform-Routinen
*=======================================================================

*-----------------------------------------------------------------------
*       Belegauszug Formulardruck
*-----------------------------------------------------------------------

***<<<pdf-enabling
*INCLUDE RFKORI35pdf.             "(-) GNAG  CR#768
INCLUDE ZOTCN0024O_RFKORI35PDF.   "(+) GNAG  CR#768
***>>>pdf-enabling


*-----------------------------------------------------------------------
*       Beleganalyseroutinen
*-----------------------------------------------------------------------
INCLUDE RFKORI70.
INCLUDE RFKORI73.

*-----------------------------------------------------------------------
*       Leseroutinen
*-----------------------------------------------------------------------
INCLUDE RFKORI80.

*-----------------------------------------------------------------------
*       Allgemeine Unterroutinen
*-----------------------------------------------------------------------
INCLUDE RFKORI90.

*-----------------------------------------------------------------------
*       Routinen für Extract
*-----------------------------------------------------------------------
INCLUDE RFKORI91.

*-----------------------------------------------------------------------
*       Allgemeine Unterroutinen für Druck
*-----------------------------------------------------------------------
INCLUDE RFKORI92.

*-----------------------------------------------------------------------
*       Allgemeine Unterroutinen für Messages und Protokoll
*-----------------------------------------------------------------------
INCLUDE RFKORI93.

*-----------------------------------------------------------------------
*       User-Exits für Korrespondenz
*-----------------------------------------------------------------------
*NCLUDE RFKORIEX.

*-----------------------------------------------------------------------
*       FORM ANALYSE_UND_AUSGABE
*-----------------------------------------------------------------------
FORM ANALYSE_UND_AUSGABE.
      CLEAR XNACH.
      IF  NOT SAVE_BELNR IS INITIAL
      AND NOT SAVE_GJAHR IS INITIAL.
        IF SAVE_BELNR CO '* '.
          CLEAR HBKORMKEY.
          CLEAR HERDATA.
          HBKORMKEY-BUKRS = HDBUKRS.
          HBKORMKEY-KOART = HDKOART.
          HBKORMKEY-KONTO = HDKONTO.
          HBKORMKEY-BELNR = SAVE_BELNR.
          HBKORMKEY-GJAHR = SAVE_GJAHR.
          CONDENSE HBKORMKEY.
          HERDATA-USNAM = HDUSNAM.
          HERDATA-DATUM = HDDATUM.
          HERDATA-UZEIT = HDUZEIT.
          CLEAR FIMSG.
          FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
          FIMSG-MSGTY = 'I'.
          FIMSG-MSGNO = '294'.
          FIMSG-MSGV1 = SAVE_EVENT.
          FIMSG-MSGV2 = HBKORMKEY.
          FIMSG-MSGV3 = HERDATA.
          PERFORM MESSAGE_APPEND.
          XKAUSG = 'X'.
        ELSE.
          SORT HBSEG BY BUKRS BELNR GJAHR BUZEI.
          CLEAR XKAUSG.
          CLEAR XPRINT.
          CLEAR ANZDR2.
          PERFORM BELEG_ANALYSE_3.
        ENDIF.
      ELSE.
        CLEAR HBKORMKEY.
        CLEAR HERDATA.
        HBKORMKEY-BUKRS = HDBUKRS.
        HBKORMKEY-KOART = HDKOART.
        HBKORMKEY-KONTO = HDKONTO.
        HBKORMKEY-BELNR = SAVE_BELNR.
        HBKORMKEY-GJAHR = SAVE_GJAHR.
        CONDENSE HBKORMKEY.
        HERDATA-USNAM = HDUSNAM.
        HERDATA-DATUM = HDDATUM.
        HERDATA-UZEIT = HDUZEIT.
        CLEAR FIMSG.
        FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
        FIMSG-MSGTY = 'I'.
        FIMSG-MSGNO = '294'.
        FIMSG-MSGV1 = SAVE_EVENT.
        FIMSG-MSGV2 = HBKORMKEY.
        FIMSG-MSGV3 = HERDATA.
        PERFORM MESSAGE_APPEND.
        XKAUSG = 'X'.
      ENDIF.

      IF XKAUSG IS INITIAL.
        SORT HEXTRACT.
        CLEAR XENDE.
        CLEAR XSATZ.

        WHILE XENDE NE 'X'.
          LOOP AT HEXTRACT.
            IF HEXTRACT-BEARB = ' ' AND XSATZ IS INITIAL.
              SAVE_KONTO  = HEXTRACT-KONT1.
              SAVE2_KOART = HEXTRACT-KOAR1.
              CLEAR SAVE_KUNNR.
              CLEAR SAVE_LIFNR.
              CLEAR SAVE_EMPFG.
              CLEAR SAVE2_EMPFG.
              CLEAR ANZKO.
              PERFORM CLEAR_TABLES.
              XSATZ = 'X'.
            ENDIF.

            IF  NOT SAVE_KONTO IS INITIAL
            AND HEXTRACT-BEARB IS INITIAL.
              IF  SAVE_KONTO  = HEXTRACT-KONT1
              AND SAVE2_KOART = HEXTRACT-KOAR1.
                SAVE_BUKRS = HEXTRACT-BUKRS.
                IF HEXTRACT-KOAR1 = 'D'.
                  SAVE_KUNNR = HEXTRACT-KONT1.
                  SAVE_LIFNR = HEXTRACT-KONT2.
                ENDIF.
                IF HEXTRACT-KOAR1 = 'K'.
                  SAVE_LIFNR = HEXTRACT-KONT1.
                ENDIF.
                HEXTRACT-BEARB = 'X'.
                MODIFY HEXTRACT.
              ELSE.
                EXIT.
              ENDIF.
            ENDIF.
          ENDLOOP.

          IF NOT XSATZ IS INITIAL.
            RF140-DATU1   = DATUM01.
            RF140-DATU2   = DATUM02.
            IF NOT SAVE_RINDKO IS INITIAL.
              RF140-TDNAME  = HTDNAME.
              RF140-TDSPRAS = HTDSPRAS.
            ENDIF.
            IF NOT SAVE_KUNNR IS INITIAL.
              PERFORM ZENTFIL_DEBI.
            ENDIF.
            IF NOT SAVE_LIFNR IS INITIAL.
              PERFORM ZENTFIL_KRED.
            ENDIF.
            PERFORM FIND_EMPFAENGER_ADRESSE.
            PERFORM FILL_BKORM.

***<<<pdf-enabling
            PERFORM form_open_pdf.
            PERFORM AUSGABE_BELEGAUSZUG_PDF.    "RFKORI35PDF
*            PERFORM form_close_pdf.
***>>>pdf-enabling

            CLEAR XSATZ.
          ELSE.
            XENDE = 'X'.
            LOOP AT HEXTRACT.
              IF HEXTRACT-BEARB IS INITIAL.
                CLEAR XENDE.
              ENDIF.
            ENDLOOP.
          ENDIF.

        ENDWHILE.
      ENDIF.
ENDFORM.

*-----------------------------------------------------------------------
*       FORM BELEGAUSZUG
*-----------------------------------------------------------------------
FORM BELEGAUSZUG.

*-------Abarbeiten der extrahierten Daten-------------------------------
  LOOP.
    AT NEW HDBUKRS.
      SAVE_BUKRS = HDBUKRS.
      IF NOT RXTSUB IS INITIAL.
        MBUKRS = HDBUKRS.
      ENDIF.
      PERFORM READ_T001.
      PERFORM FIND_BUKRS_ADRESSE.
      PERFORM SAVE_BUKRS_ADRESSE.                   "für Formularausgabe
      PERFORM CHECK_JURISDICTION.
*     SAVE_KOART = HDKOART.
      PERFORM READ_T001F.
      CLEAR FOUND.
      PERFORM FORM_READ USING T001F-FORNR FOUND.
      IF NOT FOUND IS INITIAL.
        PERFORM FORM_CHECK.
      ENDIF.
      PERFORM READ_T001G.
      CLEAR COUNTP.
      IF NOT RSIMUL IS INITIAL.
        CLEAR   HBKORM.
        REFRESH HBKORM.
      ENDIF.
*     PERFORM FORM_OPEN.
      XKNID = ' '.
    ENDAT.

    AT NEW HDUZEIT.
      CLEAR   HBKPF.
      REFRESH HBKPF.
      CLEAR   HBSEG.
      REFRESH HBSEG.
      CLEAR SAVE_BELNR.
      CLEAR SAVE_GJAHR.
    ENDAT.

    AT DATEN.
      MOVE-CORRESPONDING BSEG TO HBSEG.
      APPEND HBSEG.
      IF NOT T048-XBUKR IS INITIAL.
        SAVE_BUKRS = DABBUKR.
      ENDIF.
      SAVE_BELNR = DABELNR.
      SAVE_GJAHR = DAGJAHR.
      CLEAR RF140-DATU1.
      CLEAR RF140-DATU2.
      RF140-DATU1 = DATUM01.
      RF140-DATU2 = DATUM02.
      IF NOT RINDKO IS INITIAL.
        CLEAR RF140-TDNAME.
        CLEAR RF140-TDID.
        CLEAR RF140-TDSPRAS.
        RF140-TDNAME  = PARAMET+22(40).
        RF140-TDSPRAS = PARAMET+62(1).
        SAVE_LANGU    = PARAMET+62(1).
      ENDIF.
    ENDAT.

    AT END OF HDUZEIT.
*-------Analyse und Ausgabe-------------------------------------------*
      PERFORM ANALYSE_UND_AUSGABE.

*-------BKORM Fortschreibung------------------------------------------*
      IF NOT XBKORM IS INITIAL.
        IF RSIMUL IS INITIAL.
          PERFORM UPDATA_BKORM.
        ELSE.
          PERFORM UPDATA_BKORM_STORE.
        ENDIF.
      ELSE.
        PERFORM MESSAGE_OUTPUT.
      ENDIF.
    ENDAT.

    AT END OF HDBUKRS.
*     PERFORM FORM_CLOSE.
      IF  NOT RSIMUL          IS INITIAL
      AND NOT ITCPP-TDDEVICE  IS INITIAL
      AND NOT ITCPP-TDSPOOLID IS INITIAL.
        PERFORM UPDATA_BKORM_2.
      ENDIF.
    ENDAT.
  ENDLOOP.
  PERFORM form_close_pdf.

  PERFORM DELETE_TEXT.

  PERFORM MESSAGE_CHECK.
  IF SY-SUBRC = 0.
    PERFORM MESSAGE_PRINT.
  ENDIF.

  IF NOT RXTSUB IS INITIAL.
    PERFORM PROT_EXPORT.
  ELSE.
    IF RSIMUL IS INITIAL.
      PERFORM PROT_PRINT.
    ELSE.
      PERFORM PROT_EXPORT.
    ENDIF.
  ENDIF.
ENDFORM.

*-----------------------------------------------------------------------
*       FORM CHECK_EINGABE
*-----------------------------------------------------------------------
FORM CHECK_EINGABE.
  DESCRIBE TABLE RERLDT LINES ERLLINES.
  IF NOT ERLLINES IS INITIAL.
    IF  ERLLINES    = '1'
    AND RERLDT-LOW  IS INITIAL
    AND RERLDT-HIGH IS INITIAL.
      CLEAR XERDT.
    ELSE.
      XERDT = 'X'.
    ENDIF.
  ELSE.
    CLEAR XERDT.
  ENDIF.
  IF NOT RXTSUB   IS INITIAL.
    PRINT = 'X'.
  ELSE.
    IF SY-BATCH IS INITIAL.
      IF SSCRFIELDS-UCOMM EQ 'PRIN'.    "no difference between starting
         SSCRFIELDS-UCOMM = 'ONLI'.     "with F8 or F13
*     IF SY-UCOMM = 'PRIN'.
*        SY-UCOMM = 'ONLI'.
         PRINT = 'X'.
         XONLI = 'X'.
      ENDIF.
    ELSE.
*     IF SY-UCOMM = 'PRIN'.
        PRINT = 'X'.
*     ENDIF.
    ENDIF.
  ENDIF.

  IF    NOT SY-BATCH IS INITIAL
  OR  (     SY-BATCH IS INITIAL
  AND   (   SSCRFIELDS-UCOMM = 'PRIN'
  OR        SSCRFIELDS-UCOMM = 'ONLI' ) ).
* AND   (   SY-UCOMM = 'PRIN'
* OR        SY-UCOMM = 'ONLI' ) ).

    IF RXBKOR IS INITIAL.
      IF SY-BATCH IS INITIAL.
        IF  NOT RINDKO IS INITIAL
        AND RSPRAS IS INITIAL.
*         IF SY-BATCH IS INITIAL.
            SET CURSOR FIELD 'RSPRAS'.
*         ENDIF.
          MESSAGE E490.
        ENDIF.
      ELSE.
        IF  NOT RINDKO IS INITIAL.
          MESSAGE E499.
        ENDIF.
      ENDIF.
*     IF  NOT REVENT IS INITIAL
*     AND RINDKO IS INITIAL.
*       IF SY-BATCH IS INITIAL.
*         SET CURSOR FIELD 'REVENT'.
*       ENDIF.
*       MESSAGE W451.
*     ENDIF.
      IF REVENT IS INITIAL.
        IF SY-BATCH IS INITIAL.
          SET CURSOR FIELD 'REVENT'.
        ENDIF.
        MESSAGE E450.
      ENDIF.
      DESCRIBE TABLE RERLDT LINES ERLLINES.
      IF NOT ERLLINES IS INITIAL.
        IF SY-BATCH IS INITIAL.
          SET CURSOR FIELD 'RERLDT-LOW'.
        ENDIF.
        MESSAGE W452.
      ENDIF.
      DESCRIBE TABLE RUSNAM LINES USRLINES.
      IF NOT USRLINES IS INITIAL.
        IF SY-BATCH IS INITIAL.
          SET CURSOR FIELD 'RUSNAM-LOW'.
        ENDIF.
        MESSAGE W478.
      ENDIF.
      DESCRIBE TABLE RDATUM LINES DATLINES.
      IF NOT DATLINES IS INITIAL.
        IF SY-BATCH IS INITIAL.
          SET CURSOR FIELD 'RDATUM-LOW'.
        ENDIF.
        MESSAGE W479.
      ENDIF.
      DESCRIBE TABLE RUZEIT LINES TIMLINES.
      IF NOT TIMLINES IS INITIAL.
        IF SY-BATCH IS INITIAL.
          SET CURSOR FIELD 'RUZEIT-LOW'.
        ENDIF.
        MESSAGE W480.
      ENDIF.
    ELSE.
      IF  NOT RINDKO IS INITIAL
      AND NOT RSPRAS IS INITIAL.
        IF SY-BATCH IS INITIAL.
          SET CURSOR FIELD 'RSPRAS'.
        ENDIF.
        MESSAGE E491.
      ENDIF.

      IF REVENT IS INITIAL.
        IF SY-BATCH IS INITIAL.
          SET CURSOR FIELD 'REVENT'.
        ENDIF.
        MESSAGE E450.
      ENDIF.

      IF NOT REVENT IS INITIAL.
        CLEAR T048.
        SELECT SINGLE * FROM T048
          WHERE EVENT = REVENT.

          IF SY-SUBRC =  0.
*           CASE T048-ANZDT.
*             WHEN '0'.
                IF NOT T048-XKONT IS INITIAL.
                  IF SY-BATCH IS INITIAL.
                    SET CURSOR FIELD 'REVENT'.
                  ENDIF.
                  MESSAGE E463 WITH REVENT.
                ENDIF.
*             WHEN OTHERS.
*               IF SY-BATCH IS INITIAL.
*                 SET CURSOR FIELD 'REVENT'.
*               ENDIF.
*               MESSAGE E462 WITH REVENT.
*           ENDCASE.
          ELSE.
            IF SY-BATCH IS INITIAL.
              SET CURSOR FIELD 'REVENT'.
            ENDIF.
            MESSAGE E460 WITH REVENT.
          ENDIF.
      ENDIF.
    ENDIF.

    IF SORTVK IS INITIAL.
      IF SY-BATCH IS INITIAL.
        SET CURSOR FIELD 'SORTVK'.
      ENDIF.
      MESSAGE E830.
    ELSE.
      SELECT SINGLE * FROM T021M
        WHERE PROGN = 'RFKORD*'
        AND   ANWND = 'KORK'
        AND   SRVAR = SORTVK.
        IF SY-SUBRC NE 0.
          IF SY-BATCH IS INITIAL.
            SET CURSOR FIELD 'SORTVK'.
          ENDIF.
          MESSAGE E832 WITH SORTVK.
        ENDIF.
    ENDIF.

    IF      SORTVP IS INITIAL.
**  AND NOT RXOPOS IS INITIAL.
*     IF SY-BATCH IS INITIAL.
*       SET CURSOR FIELD 'SORTVP'.
*     ENDIF.
*     MESSAGE E831.
    ELSE.
      SELECT SINGLE * FROM T021M
        WHERE PROGN = 'RFKORD*'
        AND   ANWND = 'KORP'
        AND   SRVAR = SORTVP.
        IF SY-SUBRC NE 0.
          IF SY-BATCH IS INITIAL.
            SET CURSOR FIELD 'SORTVP'.
          ENDIF.
          MESSAGE E833 WITH SORTVP.
        ENDIF.
    ENDIF.

    IF  NOT RINDKO IS INITIAL
    AND REVENT IS INITIAL.
      IF SY-BATCH IS INITIAL.
        SET CURSOR FIELD 'REVENT'.
      ENDIF.
      MESSAGE E450.
    ENDIF.

    IF  NOT RINDKO IS INITIAL
    AND NOT REVENT IS INITIAL.
      IF T048-EVENT NE REVENT.
        SELECT SINGLE * FROM T048
          WHERE EVENT = REVENT.
          IF SY-SUBRC NE 0.
            IF SY-BATCH IS INITIAL.
              SET CURSOR FIELD 'REVENT'.
            ENDIF.
            MESSAGE E460 WITH REVENT.
          ENDIF.
      ENDIF.
      IF T048-XSPRA IS INITIAL.
        IF SY-BATCH IS INITIAL.
          SET CURSOR FIELD 'RINDKO'.
        ENDIF.
        MESSAGE E500 WITH REVENT.
      ENDIF.
    ENDIF.

    IF  RINDKO IS INITIAL
    AND NOT REVENT IS INITIAL.
      IF T048-EVENT NE REVENT.
        SELECT SINGLE * FROM T048
          WHERE EVENT = REVENT.
          IF SY-SUBRC NE 0.
            IF SY-BATCH IS INITIAL.
              SET CURSOR FIELD 'REVENT'.
            ENDIF.
            MESSAGE E460 WITH REVENT.
          ENDIF.
      ENDIF.
      IF NOT T048-XSPRA IS INITIAL.
        IF SY-BATCH IS INITIAL.
          SET CURSOR FIELD 'RINDKO'.
        ENDIF.
        MESSAGE E501 WITH REVENT.
      ENDIF.
    ENDIF.

    IF NOT TDDEST IS INITIAL.
      SELECT SINGLE * FROM TSP03
        WHERE PADEST EQ TDDEST.
        IF SY-SUBRC NE 0.
          IF SY-BATCH IS INITIAL.
            SET CURSOR FIELD 'TDDEST'.
          ENDIF.
          MESSAGE E441 WITH TDDEST.
        ENDIF.
    ENDIF.

  ENDIF.
  IF RXTSUB IS INITIAL.
    DESCRIBE TABLE RDATUM LINES DATLINES.
    IF NOT DATLINES IS INITIAL.
      PERFORM CHECK_DATE.
    ENDIF.
    DESCRIBE TABLE RUZEIT LINES TIMLINES.
    IF NOT TIMLINES IS INITIAL.
      PERFORM CHECK_TIME.
    ENDIF.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
* FORM CLEAR_TABLES
*----------------------------------------------------------------------*
FORM CLEAR_TABLES.
  CLEAR   AZENTFIL.
  REFRESH AZENTFIL.
ENDFORM.

*----------------------------------------------------------------------*
* FORM FIND_EMPFAENGER_ADRESSE.
* Adresse des Empfägers der Belegauszüge ermitteln
*----------------------------------------------------------------------*
FORM FIND_EMPFAENGER_ADRESSE.
     CLEAR   DKADR.
     CLEAR   DKAD2.
*    CLEAR   XACPD.
     CLEAR   XADRS.
     CLEAR   XADR2.
     CLEAR   *T001S.
     CLEAR   T001S.
     CLEAR   *FSABE.
     CLEAR   FSABE.
     CLEAR   KNA1.
     CLEAR   KNB1.
     CLEAR   LFA1.
     CLEAR   LFB1.
     CLEAR   SAVE_KOART.
     IF RINDKO IS INITIAL.
       CLEAR SAVE_LANGU.
     ENDIF.

     IF NOT SAVE_KUNNR IS INITIAL.
       LOOP AT HKNA1
         WHERE KUNNR = SAVE_KUNNR.
         IF HKNA1-XCPDK IS INITIAL.
           IF RINDKO IS INITIAL.
             SAVE_LANGU = HKNA1-SPRAS.
           ENDIF.
           MOVE-CORRESPONDING HKNA1 TO DKADR.
           MOVE-CORRESPONDING HKNA1 TO KNA1.
           DKADR-KONTO = HKNA1-KUNNR.
           DKADR-INLND = T001-LAND1.
*          DKADR-ANZZL = '9'.
           SAVE_KOART = 'D'.
           XADRS = 'X'.
           LOOP AT HKNB1
             WHERE KUNNR = SAVE_KUNNR
             AND   BUKRS = SAVE_BUKRS.
             MOVE-CORRESPONDING HKNB1 TO KNB1.
             DKADR-EIKTO = HKNB1-EIKTO.
             DKADR-ZSABE = HKNB1-ZSABE.
             SAVE_BUSAB = HKNB1-BUSAB.
*            PERFORM READ_T001S.
           ENDLOOP.
         ELSE.
           IF RINDKO IS INITIAL.
             SAVE_LANGU = HKNA1-SPRAS.
           ENDIF.
           DKADR-KONTO = HKNA1-KUNNR.
           LOOP AT HKNB1
             WHERE KUNNR = SAVE_KUNNR
             AND   BUKRS = SAVE_BUKRS.
             MOVE-CORRESPONDING HKNB1 TO KNB1.
             DKADR-EIKTO = HKNB1-EIKTO.
             DKADR-ZSABE = HKNB1-ZSABE.
             SAVE_BUSAB = HKNB1-BUSAB.
*            PERFORM READ_T001S.
           ENDLOOP.
*          LOOP AT HEXTRACTD
*            WHERE KONT1 = SAVE_KUNNR.
             LOOP AT HBSEC
               WHERE EMPFG = HDEMPFG.
*              WHERE BUKRS = HEXTRACTD-BUKRS
*              AND   BELNR = HEXTRACTD-BELNR
*              AND   GJAHR = HEXTRACTD-GJAHR
*              AND   BUZEI = HEXTRACTD-BUZEI.

               MOVE-CORRESPONDING HBSEC TO DKADR.
               DKADR-INLND = T001-LAND1.
               IF NOT HBSEC-SPRAS IS INITIAL.
                 IF RINDKO IS INITIAL.
                   SAVE_LANGU = HBSEC-SPRAS.
                 ENDIF.
               ENDIF.
*              DKADR-ANZZL = '9'.
               IF NOT SAVE_LANGU IS INITIAL.
                 XADRS = 'X'.
                 SAVE_KOART = 'D'.
               ENDIF.
               EXIT.
             ENDLOOP.
*            XACPD = 'X'.
*            EXIT.
*          ENDLOOP.
         ENDIF.
       ENDLOOP.
     ENDIF.

     IF NOT SAVE_LIFNR IS INITIAL.
       LOOP AT HLFA1
         WHERE LIFNR = SAVE_LIFNR.
         IF HLFA1-XCPDK IS INITIAL.
           IF SAVE_KUNNR IS INITIAL.
             IF RINDKO IS INITIAL.
               SAVE_LANGU = HLFA1-SPRAS.
             ENDIF.
             MOVE-CORRESPONDING HLFA1 TO DKADR.
             MOVE-CORRESPONDING HLFA1 TO LFA1.
             DKADR-KONTO = HLFA1-LIFNR.
             DKADR-INLND = T001-LAND1.
*            DKADR-ANZZL = '9'.
             SAVE_KOART = 'K'.
             XADRS = 'X'.
             LOOP AT HLFB1
               WHERE LIFNR = SAVE_LIFNR
               AND   BUKRS = SAVE_BUKRS.
               MOVE-CORRESPONDING HLFB1 TO LFB1.
               DKADR-EIKTO = HLFB1-EIKTO.
               DKADR-ZSABE = HLFB1-ZSABE.
               SAVE_BUSAB = HLFB1-BUSAB.
*              PERFORM READ_T001S.
             ENDLOOP.
           ELSE.
             MOVE-CORRESPONDING HLFA1 TO DKAD2.
             MOVE-CORRESPONDING HLFA1 TO LFA1.
             DKAD2-KONTO = HLFA1-LIFNR.
             DKAD2-INLND = T001-LAND1.
*            DKAD2-ANZZL = '9'.
             LOOP AT HLFB1
               WHERE LIFNR = SAVE_LIFNR
               AND   BUKRS = SAVE_BUKRS.
               MOVE-CORRESPONDING HLFB1 TO LFB1.
               DKAD2-EIKTO = HLFB1-EIKTO.
               DKAD2-ZSABE = HLFB1-ZSABE.
               SAVE2_BUSAB = HLFB1-BUSAB.
*              PERFORM READ_T001S_2.
*              DKAD2-SNAME = *T001S-SNAME.
               XADR2 = 'X'.
             ENDLOOP.
           ENDIF.
         ELSE.
           IF       SAVE_KUNNR IS INITIAL.
*          OR ( NOT SAVE_KUNNR IS INITIAL
*          AND      XACPD      IS INITIAL ).
             IF RINDKO IS INITIAL.
               SAVE_LANGU = HLFA1-SPRAS.
             ENDIF.
             DKADR-KONTO = HLFA1-KUNNR.
             LOOP AT HLFB1
               WHERE LIFNR = SAVE_LIFNR
               AND   BUKRS = SAVE_BUKRS.
               MOVE-CORRESPONDING HLFB1 TO LFB1.
               DKADR-EIKTO = HLFB1-EIKTO.
               DKADR-ZSABE = HLFB1-ZSABE.
               SAVE_BUSAB = HLFB1-BUSAB.
*              PERFORM READ_T001S.
             ENDLOOP.
           ELSE.
             DKAD2-KONTO = HLFA1-LIFNR.
             LOOP AT HLFB1
               WHERE LIFNR = SAVE_LIFNR
               AND   BUKRS = SAVE_BUKRS.
               MOVE-CORRESPONDING HLFB1 TO LFB1.
               DKAD2-EIKTO = HLFB1-EIKTO.
               DKAD2-ZSABE = HLFB1-ZSABE.
               SAVE2_BUSAB = HLFB1-BUSAB.
*              PERFORM READ_T001S_2.
*              DKAD2-SNAME = *T001S-SNAME.
             ENDLOOP.
           ENDIF.
           LOOP AT HEXTRACTK
             WHERE KONT1 = SAVE_LIFNR.
             IF       SAVE_KUNNR IS INITIAL.
*            OR ( NOT SAVE_KUNNR IS INITIAL
*            AND      XACPD      IS INITIAL ).
               LOOP AT HBSEC
                 WHERE EMPFG = HDEMPFG.
                 MOVE-CORRESPONDING HBSEC TO DKADR.
                 DKADR-INLND = T001-LAND1.
                 IF NOT HBSEC-SPRAS IS INITIAL.
                   IF RINDKO IS INITIAL.
                     SAVE_LANGU = HBSEC-SPRAS.
                   ENDIF.
                 ENDIF.
*                DKADR-ANZZL = '9'.
                 IF NOT SAVE_LANGU IS INITIAL.
                   XADRS = 'X'.
                   SAVE_KOART = 'K'.
                 ENDIF.
                 EXIT.
               ENDLOOP.
               EXIT.
             ELSE.
               LOOP AT HBSEC
                 WHERE BUKRS = HEXTRACTK-BUKRS
                 AND   BELNR = HEXTRACTK-BELNR
                 AND   GJAHR = HEXTRACTK-GJAHR
                 AND   BUZEI = HEXTRACTK-BUZEI.
                 MOVE-CORRESPONDING HBSEC TO DKAD2.
                 DKAD2-INLND = T001-LAND1.
*                dkad2-ANZZL = '9'.
                 XADR2 = 'X'.
                 EXIT.
               ENDLOOP.
             ENDIF.
*            XACPD = 'X'.
             EXIT.
           ENDLOOP.
         ENDIF.
       ENDLOOP.
     ENDIF.

    IF SAVE_LANGU IS INITIAL.
      CLEAR FIMSG.
      FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
      FIMSG-MSGTY = 'I'.
      IF NOT SAVE_KUNNR IS INITIAL.
        FIMSG-MSGNO = '808'.
        FIMSG-MSGV1 = SAVE_KUNNR.
      ELSE.
        FIMSG-MSGNO = '810'.
        FIMSG-MSGV1 = SAVE_LIFNR.
      ENDIF.
      PERFORM MESSAGE_APPEND.
      CLEAR XADRS.
      XKAUSG = 'X'.
    ELSE.
      IF XADRS IS INITIAL.
        CLEAR FIMSG.
        FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
        FIMSG-MSGTY = 'I'.
        IF NOT SAVE_KUNNR IS INITIAL.
          FIMSG-MSGNO = '809'.
          FIMSG-MSGV1 = SAVE_KUNNR.
        ELSE.
          FIMSG-MSGNO = '811'.
          FIMSG-MSGV1 = SAVE_LIFNR.
        ENDIF.
        PERFORM MESSAGE_APPEND.
        XKAUSG = 'X'.
      ENDIF.
   ENDIF.

  SET COUNTRY DKADR-LAND1.
ENDFORM.

*----------------------------------------------------------------------*
* FORM FORM_CHECK
*----------------------------------------------------------------------*
FORM FORM_CHECK.
  CLEAR OLDFORM.
  LOOP AT HITCTG
    WHERE TDPAGE = 'BA_FIRST'.
    EXIT.
  ENDLOOP.
  IF SY-SUBRC = 0.
    OLDFORM = 'X'.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
* FORM FORM_START_BA
*----------------------------------------------------------------------*
FORM FORM_START_BA.

  IF XOPEN = 'Y'.
    CLEAR FORM.
    IF  FINAA-NACHA = '2'
    AND NOT FINAA-FORNR IS INITIAL.
      FORM = FINAA-FORNR.
      SAVE_FORM = FINAA-FORNR.
    ELSE.
      FORM = T001F-FORNR.
      SAVE_FORM = T001F-FORNR.
    ENDIF.
    IF OLDFORM IS INITIAL.
      STARTPAGE = 'FIRST'.
    ELSE.
      STARTPAGE = 'BA_FIRST'.
    ENDIF.
    LANGUAGE = SAVE_LANGU.
*   FLKFORM = 'Z'.
    CLEAR FLSPRAS.

    PERFORM FORM_START USING SAVE_FORM LANGUAGE STARTPAGE.
*   CALL FUNCTION 'START_FORM'
*                    EXPORTING  FORM      = SAVE_FORM
*                               LANGUAGE  = LANGUAGE
*                               STARTPAGE = STARTPAGE
*                    IMPORTING  LANGUAGE  = LANGUAGE
*                    EXCEPTIONS FORM      = 5.
**                              UNENDED   = 7
**                              UNOPENED  = 3.
**                              IF SY-SUBRC = '3'.
**                                PERFORM MESSAGE_UNOPENED.
**                              ENDIF.
                                IF SY-SUBRC = '5'.
                                  MESSAGE E229 WITH T001F-FORNR
                                                    STARTPAGE.
                                ENDIF.
*                               IF SY-SUBRC = '7'.
*                                 PERFORM MESSAGE_UNENDED.
*                               ENDIF.
    IF SY-SUBRC = '0'.
      IF LANGUAGE NE SAVE_LANGU.
*       IF SAVE_DSPRAS IS INITIAL.
*         IF SAVE_LANGU NE SY-LANGU.
*           IF LANGUAGE NE SY-LANGU.
*             PERFORM FORM_END.
*             LANGUAGE = SY-LANGU.
*             CALL FUNCTION 'START_FORM'
*                              EXPORTING  FORM      = SAVE_FORM
*                                         LANGUAGE  = LANGUAGE
*                                         STARTPAGE = 'BA_FIRST'
*                              IMPORTING  LANGUAGE  = LANGUAGE
*                              EXCEPTIONS FORM      = 5.
**                                        UNENDED   = 7
**                                        UNOPENED  = 3.
**                                      IF SY-SUBRC = '3'.
**                                        PERFORM MESSAGE_UNOPENED.
**                                      ENDIF.
*                                       IF SY-SUBRC = '5'.
**                                        MESSAGE E412 WITH KNB1-BUKRS.
*                                       ENDIF.
**                                      IF SY-SUBRC = '7'.
**                                        PERFORM MESSAGE_UNENDED.
**                                      ENDIF.
*
*                               IF SY-SUBRC = '0'.
*                                 XSTART = 'J'.
*                                 IF LANGUAGE NE SY-LANGU.
*                                   FLSPRAS = ' '.
**                                 PERFORM MESSAGE_LANGUAGE.
*                                 ENDIF.
*                               ENDIF.
*           ELSE.
*             XSTART = 'J'.
*             FLSPRAS = ' '.
**            PERFORM MESSAGE_LANGUAGE.
*           ENDIF.            "language <> sy
*         ELSE.
*           XSTART = 'J'.
*           FLSPRAS = ' '.
**          PERFORM MESSAGE_LANGUAGE.
*         ENDIF.            "save_langu <> sy
*       ELSE.
*         IF SAVE_LANGU NE T001-SPRAS.
*           IF LANGUAGE NE T001-SPRAS.
*             PERFORM FORM_END.
*             LANGUAGE = T001-SPRAS.
*             CALL FUNCTION 'START_FORM'
*                              EXPORTING  FORM      = SAVE_FORM
*                                         LANGUAGE  = LANGUAGE
*                                         STARTPAGE = 'BA_FIRST'
*                              IMPORTING  LANGUAGE  = LANGUAGE
*                              EXCEPTIONS FORM      = 5.
**                                        UNENDED   = 7
**                                        UNOPENED  = 3.
**                                      IF SY-SUBRC = '3'.
**                                        PERFORM MESSAGE_UNOPENED.
**                                      ENDIF.
*                                       IF SY-SUBRC = '5'.
**                                        MESSAGE E412 WITH KNB1-BUKRS.
*                                       ENDIF.
**                                      IF SY-SUBRC = '7'.
**                                        PERFORM MESSAGE_UNENDED.
**                                      ENDIF.
*
*                               IF SY-SUBRC = '0'.
*                                 XSTART = 'J'.
*                                 IF LANGUAGE NE T001-SPRAS.
*                                   FLSPRAS = ' '.
**                                 PERFORM MESSAGE_LANGUAGE.
*                                 ENDIF.
*                               ENDIF.
*           ELSE.
*             XSTART = 'J'.
*             FLSPRAS = ' '.
**            PERFORM MESSAGE_LANGUAGE.
*           ENDIF.            "language <> t001-spras
*         ELSE.
*           XSTART = 'J'.
*           FLSPRAS = ' '.
**          PERFORM MESSAGE_LANGUAGE.
*         ENDIF.            "save_langu <> t001-spras
*       ENDIF.
        XSTART = 'J'.      "language <> save_langu
        FLSPRAS = 'X'.
        CLEAR FIMSG.
        FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
        FIMSG-MSGTY = 'I'.
        FIMSG-MSGNO = '559'.
        FIMSG-MSGV1 = SAVE_FORM.
        FIMSG-MSGV2 = SAVE_LANGU.
        FIMSG-MSGV3 = LANGUAGE.
        PERFORM MESSAGE_APPEND.
      ELSE.               "language =  save_langu
        XSTART = 'J'.
      ENDIF.              "language <> save_langu
    ELSE.
      CLEAR XSTART.
    ENDIF.                "sy-subrc
  ENDIF.                  "xopen
ENDFORM.

*-----------------------------------------------------------------------
*       FORM SELECTION_OHNE_BKORM
*-----------------------------------------------------------------------
FORM SELECTION_OHNE_BKORM.
  SELECT * FROM BKPF
    WHERE BUKRS IN RBUKRS
    AND   BELNR IN RBELNR
    AND   GJAHR IN RGJAHR.

    CLEAR SAVE_BBUKR.
    IF NOT T048-XBUKR IS INITIAL.
      SAVE_BBUKR = BKPF-BUKRS.
      CALL FUNCTION 'CORRESPONDENCE_GET_LEADING_CC'
           EXPORTING
                I_BUKRS = BKPF-BUKRS
           IMPORTING
                E_BUKRS = SAVE_BUKRS.
    ELSE.
      SAVE_BUKRS = BKPF-BUKRS.
    ENDIF.
    IF RINDKO IS INITIAL.
*-------Headerfelder für Extract----------------------------------------
      HDBUKRS       = SAVE_BUKRS.
      HDKOART       = '   '.
      HDKONTO       = '   '.
      HDBELGJ(4)    = BKPF-GJAHR.
      HDBELGJ+4(10) = BKPF-BELNR.
      HDUSNAM       = SY-UNAME.
      HDDATUM       = SY-DATUM.
      HDUZEIT       = SY-UZEIT.

*-------Datenfelder für Extract-----------------------------------------
      EXTRACT(1)    = 'X'.
      DABELNR       = BKPF-BELNR.
      DAGJAHR       = BKPF-GJAHR.
      DATUM01       = KODAT01.
      DATUM02       = KODAT02.
      IF NOT T048-XBUKR IS INITIAL.
        DABBUKR = SAVE_BBUKR.
      ELSE.
        DABBUKR = '    '.
      ENDIF.
      XBKORM        = ' '.

      CLEAR SAVE_BUKRS.
      CLEAR SAVE_BELNR.
      CLEAR SAVE_GJAHR.
      SAVE_BUKRS = BKPF-BUKRS.
      SAVE_BELNR = BKPF-BELNR.
      SAVE_GJAHR = BKPF-GJAHR.

      CLEAR XKAUSG.
      PERFORM EXTRACT_VORBEREITUNG_3.

      IF XKAUSG IS INITIAL.
        CLEAR SAVE4_KOART.
        CLEAR SAVE3_KONTO.
        CLEAR HDEMPFG.
        SORT  HEXTRACT.
        LOOP AT HEXTRACT.
          IF SAVE4_KOART NE HEXTRACT-KOAR1
          OR SAVE3_KONTO NE HEXTRACT-KONT1.
            IF HEXTRACT-KOAR1 = 'D'.
              SAVE_KOART = HEXTRACT-KOAR1.
              SAVE_KUNNR = HEXTRACT-KONT1.
              SAVE_BUKRS = HEXTRACT-BUKRS.
              PERFORM PRUEFEN_HKNA1.
              IF XVORH IS INITIAL.
                XKAUSG = 'X'.
                IF SY-SUBRC NE 0.
                  CLEAR FIMSG.
                  FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
                  FIMSG-MSGTY = 'I'.
                  FIMSG-MSGNO = '574'.
                  FIMSG-MSGV1 = SAVE_KUNNR.
                  PERFORM MESSAGE_APPEND.
                ENDIF.
              ENDIF.
              PERFORM PRUEFEN_HKNB1.
              IF XVORH IS INITIAL.
                XKAUSG = 'X'.
                IF SY-SUBRC NE 0.
                  CLEAR FIMSG.
                  FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
                  FIMSG-MSGTY = 'I'.
                  FIMSG-MSGNO = '576'.
                  FIMSG-MSGV1 = SAVE_KUNNR.
                  FIMSG-MSGV2 = SAVE_BUKRS.
                  PERFORM MESSAGE_APPEND.
                ENDIF.
              ENDIF.
              IF NOT KNA1-XCPDK IS INITIAL.
                LOOP AT HBSEC
                  WHERE EMPFG = HEXTRACT-EMPF1.
                  BSEC = HBSEC.
                  HDEMPFG = BSEC-EMPFG.
                  EXIT.
                ENDLOOP.
                IF SY-SUBRC NE 0.
                  XKAUSG = 'X'.
                  IF SY-SUBRC NE 0.
                    CLEAR FIMSG.
                    FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
                    FIMSG-MSGTY = 'I'.
                    FIMSG-MSGNO = '834'.
                    FIMSG-MSGV1 = SAVE_BUKRS.
                    FIMSG-MSGV2 = SAVE_KUNNR.
                    FIMSG-MSGV3 = HEXTRACT-EMPF1.
                    PERFORM MESSAGE_APPEND.
                  ENDIF.
                ENDIF.
              ELSE.
                CLEAR BSEC.
                CLEAR HDEMPFG.
              ENDIF.
              PERFORM SORTIERUNG USING 'K' 'K' 'X'.
            ENDIF.
            IF HEXTRACT-KOAR1 = 'K'.
              SAVE_KOART = HEXTRACT-KOAR1.
              SAVE_LIFNR = HEXTRACT-KONT1.
              SAVE_BUKRS = HEXTRACT-BUKRS.
              PERFORM PRUEFEN_HLFA1.
              IF XVORH IS INITIAL.
                XKAUSG = 'X'.
                IF SY-SUBRC NE 0.
                  CLEAR FIMSG.
                  FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
                  FIMSG-MSGTY = 'I'.
                  FIMSG-MSGNO = '578'.
                  FIMSG-MSGV1 = SAVE_LIFNR.
                  PERFORM MESSAGE_APPEND.
                ENDIF.
              ENDIF.
              PERFORM PRUEFEN_HLFB1.
              IF XVORH IS INITIAL.
                XKAUSG = 'X'.
                IF SY-SUBRC NE 0.
                  CLEAR FIMSG.
                  FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
                  FIMSG-MSGTY = 'I'.
                  FIMSG-MSGNO = '580'.
                  FIMSG-MSGV1 = SAVE_LIFNR.
                  FIMSG-MSGV2 = SAVE_BUKRS.
                  PERFORM MESSAGE_APPEND.
                ENDIF.
              ENDIF.
              IF NOT LFA1-XCPDK IS INITIAL.
                LOOP AT HBSEC
                  WHERE EMPFG = HEXTRACT-EMPF1.
                  BSEC = HBSEC.
                  HDEMPFG = BSEC-EMPFG.
                  EXIT.
                ENDLOOP.
                IF SY-SUBRC NE 0.
                  XKAUSG = 'X'.
                  IF SY-SUBRC NE 0.
                    CLEAR FIMSG.
                    FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
                    FIMSG-MSGTY = 'I'.
                    FIMSG-MSGNO = '834'.
                    FIMSG-MSGV1 = SAVE_BUKRS.
                    FIMSG-MSGV2 = SAVE_LIFNR.
                    FIMSG-MSGV3 = HEXTRACT-EMPF1.
                    PERFORM MESSAGE_APPEND.
                  ENDIF.
                ENDIF.
              ELSE.
                CLEAR BSEC.
                CLEAR HDEMPFG.
              ENDIF.
              PERFORM SORTIERUNG USING 'K' 'K' 'X'.
            ENDIF.
            SAVE4_KOART  =  HEXTRACT-KOAR1.
            SAVE3_KONTO  =  HEXTRACT-KONT1.
          ENDIF.
          LOOP AT HBSEG
            WHERE BUKRS = HEXTRACT-BUKRS
            AND   BELNR = HEXTRACT-BELNR
            AND   GJAHR = HEXTRACT-GJAHR
            AND   BUZEI = HEXTRACT-BUZEI.
            CLEAR BSEG.
            MOVE-CORRESPONDING HBSEG TO BSEG.
            HDKOAR2 = HEXTRACT-KOAR1.
            HDKONT2 = HEXTRACT-KONT1.
            PERFORM EXTRACT.
*           CLEAR  SORT1.
*           CLEAR  SORT2.
*           CLEAR  SORT3.
*           CASE SORTKZ.
*             WHEN '1'.
*               SORT1 = HBSEG-GJAHR.
*               SORT2 = HBSEG-BELNR.
*               HDKOAR2 = HEXTRACT-KOAR1.
*               HDKONT2 = HEXTRACT-KONT1.
*               PERFORM EXTRACT.
*             WHEN '2'.
*               SORT1 = HEXTRACT-KOAR1.
*               SORT2 = HEXTRACT-KONT1.
*               HDKOAR2 = HEXTRACT-KOAR1.
*               HDKONT2 = HEXTRACT-KONT1.
*               PERFORM EXTRACT.
*             WHEN OTHERS.
*           ENDCASE.
          ENDLOOP.
        ENDLOOP.
      ENDIF.
    ELSE.
        CLEAR HHEAD.
        HHEAD-HDBUKRS       = SAVE_BUKRS.
        HHEAD-HDKOART       = ' '.
        HHEAD-HDKONTO       = '          '.
        HHEAD-HDBELGJ(4)    = BKPF-GJAHR.
        HHEAD-HDBELGJ+4(10) = BKPF-BELNR.
        HHEAD-HDUSNAM       = SY-UNAME.
        HHEAD-HDDATUM       = SY-DATUM.
        HHEAD-HDUZEIT       = SY-UZEIT.
        HHEAD-DABELNR       = BKPF-BELNR.
        HHEAD-DAGJAHR       = BKPF-GJAHR.
        IF NOT T048-XBUKR IS INITIAL.
          HHEAD-DABBUKR = SAVE_BBUKR.
        ELSE.
          HHEAD-DABBUKR = '    '.
        ENDIF.
        APPEND HHEAD.

        HTEXTERF = 'X'.
    ENDIF.
  ENDSELECT.
  IF NOT HTEXTERF IS INITIAL.
    SORT HHEAD.
    LOOP AT HHEAD.
      CLEAR   HFUNKTION.
      CLEAR   HTDNAME.
      CLEAR   HTDSPRAS.
      CLEAR   HTHEADER.
      CLEAR   HTLINES.
      REFRESH HTLINES.

      CALL FUNCTION 'CORRESPONDENCE_TEXT'
           EXPORTING  I_BUKRS    = HHEAD-HDBUKRS
                      I_EVENT    = REVENT
                      I_SPRAS    = RSPRAS
           IMPORTING  E_FUNCTION = HFUNKTION
                      E_TDNAME   = HTDNAME
                      E_TDSPRAS  = HTDSPRAS
                      E_THEAD    = HTHEADER
           TABLES     LINES      = HTLINES
           EXCEPTIONS NO_EVENT_FOUND = 02
                      NO_SPRAS       = 06.

      CASE SY-SUBRC.
        WHEN 0.
          CASE HFUNKTION.
            WHEN ' '.
              MESSAGE E500 WITH REVENT.
            WHEN '1'.
*-------Headerfelder für Extract ---------------------------------------
              HDBUKRS = HHEAD-HDBUKRS.
              HDKOART = HHEAD-HDKOART.
              HDKONTO = HHEAD-HDKONTO.
              HDBELGJ = HHEAD-HDBELGJ.
              HDUSNAM = HHEAD-HDUSNAM.
              HDDATUM = HHEAD-HDDATUM.
              HDUZEIT = HHEAD-HDUZEIT.

*-------Datenfelder für Extract-----------------------------------------
              EXTRACT(1)    = 'X'.
              DABELNR       = HHEAD-DABELNR.
              DAGJAHR       = HHEAD-DAGJAHR.
              DATUM01       = KODAT01.
              DATUM02       = KODAT02.
              DABBUKR       = HHEAD-DABBUKR.
              XBKORM        = ' '.

              CALL FUNCTION 'SAVE_TEXT'
                   EXPORTING
                        HEADER          = HTHEADER
*                       INSERT          = 'X'
                        SAVEMODE_DIRECT = 'X'
                    IMPORTING
                        NEWHEADER       = HTHEADER
                    TABLES
                        LINES           = HTLINES.
*                   EXCEPTIONS
*                       ID              = 01
*                       LANGUAGE        = 02
*                       NAME            = 03
*                       OBJECT          = 04.

              CLEAR HTHEAD.
              MOVE-CORRESPONDING HTHEADER TO HTHEAD.
              APPEND HTHEAD.

              PARAMET+22(40) = HTDNAME.
              PARAMET+62(1)  = HTDSPRAS.

              CLEAR SAVE_BUKRS.
              CLEAR SAVE_BELNR.
              CLEAR SAVE_GJAHR.
              SAVE_BUKRS = BKPF-BUKRS.
              SAVE_BELNR = BKPF-BELNR.
              SAVE_GJAHR = BKPF-GJAHR.

              CLEAR XKAUSG.
              PERFORM EXTRACT_VORBEREITUNG_3.

              IF XKAUSG IS INITIAL.
                CLEAR SAVE4_KOART.
                CLEAR SAVE3_KONTO.
                CLEAR HDEMPFG.
                LOOP AT HEXTRACT.
                  IF SAVE4_KOART NE HEXTRACT-KOAR1
                  OR SAVE3_KONTO NE HEXTRACT-KONT1.
                    IF HEXTRACT-KOAR1 = 'D'.
                      SAVE_KOART = HEXTRACT-KOAR1.
                      SAVE_KUNNR = HEXTRACT-KONT1.
                      SAVE_BUKRS = HEXTRACT-BUKRS.
                      PERFORM PRUEFEN_HKNA1.
                      IF XVORH IS INITIAL.
                        XKAUSG = 'X'.
                        IF SY-SUBRC NE 0.
                          CLEAR FIMSG.
                          FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
                          FIMSG-MSGTY = 'I'.
                          FIMSG-MSGNO = '574'.
                          FIMSG-MSGV1 = SAVE_KUNNR.
                          PERFORM MESSAGE_APPEND.
                        ENDIF.
                      ENDIF.
                      PERFORM PRUEFEN_HKNB1.
                      IF XVORH IS INITIAL.
                        XKAUSG = 'X'.
                        IF SY-SUBRC NE 0.
                          CLEAR FIMSG.
                          FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
                          FIMSG-MSGTY = 'I'.
                          FIMSG-MSGNO = '576'.
                          FIMSG-MSGV1 = SAVE_KUNNR.
                          FIMSG-MSGV2 = SAVE_BUKRS.
                          PERFORM MESSAGE_APPEND.
                        ENDIF.
                      ENDIF.
                      IF NOT KNA1-XCPDK IS INITIAL.
                        LOOP AT HBSEC
                          WHERE EMPFG = HEXTRACT-EMPF1.
                          BSEC = HBSEC.
                          HDEMPFG = BSEC-EMPFG.
                          EXIT.
                        ENDLOOP.
                        IF SY-SUBRC NE 0.
                          XKAUSG = 'X'.
                          IF SY-SUBRC NE 0.
                            CLEAR FIMSG.
                            FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
                            FIMSG-MSGTY = 'I'.
                            FIMSG-MSGNO = '834'.
                            FIMSG-MSGV1 = SAVE_BUKRS.
                            FIMSG-MSGV2 = SAVE_KUNNR.
                            FIMSG-MSGV3 = HEXTRACT-EMPF1.
                            PERFORM MESSAGE_APPEND.
                          ENDIF.
                        ENDIF.
                      ELSE.
                        CLEAR BSEC.
                        CLEAR HDEMPFG.
                      ENDIF.
                      PERFORM SORTIERUNG USING 'K' 'K' 'X'.
                    ENDIF.
                    IF HEXTRACT-KOAR1 = 'K'.
                      SAVE_KOART = HEXTRACT-KOAR1.
                      SAVE_LIFNR = HEXTRACT-KONT1.
                      SAVE_BUKRS = HEXTRACT-BUKRS.
                      PERFORM PRUEFEN_HLFA1.
                      IF XVORH IS INITIAL.
                        XKAUSG = 'X'.
                        IF SY-SUBRC NE 0.
                          CLEAR FIMSG.
                          FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
                          FIMSG-MSGTY = 'I'.
                          FIMSG-MSGNO = '578'.
                          FIMSG-MSGV1 = SAVE_LIFNR.
                          PERFORM MESSAGE_APPEND.
                        ENDIF.
                      ENDIF.
                      PERFORM PRUEFEN_HLFB1.
                      IF XVORH IS INITIAL.
                        XKAUSG = 'X'.
                        IF SY-SUBRC NE 0.
                          CLEAR FIMSG.
                          FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
                          FIMSG-MSGTY = 'I'.
                          FIMSG-MSGNO = '580'.
                          FIMSG-MSGV1 = SAVE_LIFNR.
                          FIMSG-MSGV2 = SAVE_BUKRS.
                          PERFORM MESSAGE_APPEND.
                        ENDIF.
                      ENDIF.
                      IF NOT LFA1-XCPDK IS INITIAL.
                        LOOP AT HBSEC
                          WHERE EMPFG = HEXTRACT-EMPF1.
                          BSEC = HBSEC.
                          HDEMPFG = BSEC-EMPFG.
                          EXIT.
                        ENDLOOP.
                        IF SY-SUBRC NE 0.
                          XKAUSG = 'X'.
                          IF SY-SUBRC NE 0.
                            CLEAR FIMSG.
                            FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
                            FIMSG-MSGTY = 'I'.
                            FIMSG-MSGNO = '834'.
                            FIMSG-MSGV1 = SAVE_BUKRS.
                            FIMSG-MSGV2 = SAVE_LIFNR.
                            FIMSG-MSGV3 = HEXTRACT-EMPF1.
                            PERFORM MESSAGE_APPEND.
                          ENDIF.
                        ENDIF.
                      ELSE.
                        CLEAR BSEC.
                        CLEAR HDEMPFG.
                      ENDIF.
                      PERFORM SORTIERUNG USING 'K' 'K' 'X'.
                    ENDIF.
                    SAVE4_KOART  =  HEXTRACT-KOAR1.
                    SAVE3_KONTO  =  HEXTRACT-KONT1.
                  ENDIF.
                  LOOP AT HBSEG
                    WHERE BUKRS = HEXTRACT-BUKRS
                    AND   BELNR = HEXTRACT-BELNR
                    AND   GJAHR = HEXTRACT-GJAHR
                    AND   BUZEI = HEXTRACT-BUZEI.
                    CLEAR BSEG.
                    MOVE-CORRESPONDING HBSEG TO BSEG.
                    HDKOAR2 = HEXTRACT-KOAR1.
                    HDKONT2 = HEXTRACT-KONT1.
                    PERFORM EXTRACT.
*                   CLEAR  SORT1.
*                   CLEAR  SORT2.
*                   CLEAR  SORT3.
*                   CASE SORTKZ.
*                     WHEN '1'.
*                       SORT1 = HBSEG-GJAHR.
*                       SORT2 = HBSEG-BELNR.
*                       HDKOAR2 = HEXTRACT-KOAR1.
*                       HDKONT2 = HEXTRACT-KONT1.
*                       PERFORM EXTRACT.
*                     WHEN '2'.
*                       SORT1 = HEXTRACT-KOAR1.
*                       SORT2 = HEXTRACT-KONT1.
*                       HDKOAR2 = HEXTRACT-KOAR1.
*                       HDKONT2 = HEXTRACT-KONT1.
*                       PERFORM EXTRACT.
*                     WHEN OTHERS.
*                   ENDCASE.
                  ENDLOOP.
                ENDLOOP.
              ENDIF.

            WHEN OTHERS.
              MESSAGE I807 WITH HHEAD-HDBUKRS
                                HHEAD-DABELNR HHEAD-DAGJAHR.
          ENDCASE.
        WHEN 2.
          MESSAGE E806 WITH HHEAD-HDBUKRS REVENT.
        WHEN 6.
          MESSAGE E511 WITH RSPRAS.
      ENDCASE.
    ENDLOOP.
  ENDIF.
  CLEAR   HHEAD.
  REFRESH HHEAD.
ENDFORM.
