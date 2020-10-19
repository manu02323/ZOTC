*&---------------------------------------------------------------------*
*&  Include  FZA_RFKORI00
*&---------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 07-May-2019 U105235  E2DK923798 Defect 9480  Dump issue Customer     *
*                                 statement due to change in internal  *
*                                 table declaration in TOP INCLUDE,so  *
*                                 the TOP INCLUDE is copied from EHP6  *
*                                 version to avoid the dumps           *
************************************************************************
*=======================================================================
*       Datenteil
*=======================================================================

*-----------------------------------------------------------------------
*       Tabellen
*-----------------------------------------------------------------------

*-------Datenbanktabellen-----------------------------------------------
TABLES: bkdf,
        bkpf,
        *bkpf,
        bkorm,
        *bkorm,
        bseg,
        *bseg,
        bsega,
        *bsega,
        bsegh,
        bsec,
        bsed,
        bset,
        *bset,
        with_item,
        *with_item,
        bsid,
        *bsid,
        bsad,
        *bsad,
        bsik,
        *bsik,
        bsak,
        *bsak,
        bvor,
        vbsegd,
        vbsegk,
        vbsegs,
        vbsega,
        vbsec,
        vbset,
        v_vbsegd,
        v_vbsegk,
        v_vbsegs,

        kna1,
        *kna1,
        knb1,
        *knb1,
        knbk,

        lfa1,
        *lfa1,
        lfb1,
        *lfb1,
        lfbk,

        ska1,
        skat,
        *skat,
        skb1,

        bnka,
        *bnka,

        vf_debi,
        vf_kred,

        cpdvs,

*-------DDIC-Tabellen---------------------------------------------------
        dd07l,
        dd07t,

*-------ATAB-Tabellen---------------------------------------------------
        t001,
        *t001,
        t001f,
        t001g,
        t001s,
        *t001s,
        t001u,
        t001w,
        t001z,
        t002,
        t003,
        t003t,
        t004,
        t005,
        *t005,
        t005t,
        t007b,
        t007s,
        t012,
        t012k,
        t015l,
        t021m,
        t030,
        t031t,
        t041a,
        t042h,
        t048,
        t048a,
        t048b,
        t048i,
        t048t,
        t050t,
        t052,
        t053r,
        t053s,
        t054t,
        t057t,
        t074t,
        t687t,

        tabwt,
        tbsl,
        tbslt,
        tcurx,
        tinso,
        tsp01,
        tsp03,
        ttxjt,
*       TZB0T,

*-------Adressaufbereitung----------------------------------------------
        adrs,
        *adrs,
        addr,
        sadr,
        bkadr,
        dkadr,
        dkad2,
        raadr,
        fiadr,
        adrze,
        fsabe,
        *fsabe,

*-------Sendemedium-----------------------------------------------------
        finaa,

*-------Benutzerdaten---------------------------------------------------
        usr01,
        usr03,                                              "USR0340A
        *usr03,                                             "USR0340A

*-------Kontierungsblock------------------------------------------------
        cobl,

*-------Umsatzsteuer----------------------------------------------------
        rtax1u15,
        konp,

*-------Printeroptionen-------------------------------------------------
        itcpo,
        itcpp,
        itcoo,
        itcfx,
        pri_params,

*-------Systemfelder----------------------------------------------------
        sscrfields,

*-------Batch-Heading---------------------------------------------------
        bhdgd,

*-------Archivierung----------------------------------------------------
        farc_xread,

*-------Arbeitsfelder---------------------------------------------------
        rf140,
        *rf140,

        rf140u,
        rf140v,
        rf140w,

        faede,

*-------Zahlungstr?ger--------------------------------------------------
        paymi,
        paymo,

*-------Avise-----------------------------------------------------------
        avico,
        avik,

*-------Doku-Felder-----------------------------------------------------
        rfpdo,
        rfpdo1,
        rfsdo,

*-------Textverarbeitung------------------------------------------------
        tline,
        thead,

*-------Fehlermeldungen-------------------------------------------------
        fimsg,

*-------W?hrungsumrechnung----------------------------------------------
        icurr.

*-------Kassenbuch------------------------------------------------------
TABLES: tcj_c_journals,
        tcj_cj_names,
        tcj_documents,
        *tcj_documents,
        tcj_positions,
        *tcj_positions,
        tcj_transactions,
        tcj_trans_names,
        tcj_print,
        tcj_wtax_items.

*-----------------------------------------------------------------------
*       Datenfelder f?r den Report SAPF140
*
*       Teil 1 : Einzelfelder
*       Teil 2 : Strukturen
*       Teil 3 : Interne Tabellen
*       Teil 4 : Konstanten
*       Teil 5 : Field-Symbols
*       Teil 6 : Select-Options und Parameter
*       Teil 7 : Field-Groups
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
*       Teil 1 : Einzelfelder
*-----------------------------------------------------------------------

*-------Headerfelder f?r Extract----------------------------------------
DATA:   hdbukrs       LIKE bseg-bukrs,
        hdkoart       LIKE bseg-koart,
        hdkonto       LIKE bseg-kunnr,
        hdbelgj(20)   TYPE c,
        hdkoar2       LIKE bseg-koart,
        hdkont2       LIKE bseg-kunnr,
        hdempfg       LIKE bsec-empfg,
        hdusnam       LIKE bkorm-usnam,
        hddatum       LIKE bkorm-datum,
        hduzeit       LIKE bkorm-uzeit,

*-------Datenfelder f?r Extract-----------------------------------------
        extract(1)    TYPE c,
        dabelnr       LIKE bseg-belnr,
        dagjahr       LIKE bseg-gjahr,
        daerldt       LIKE bkorm-erldt,
        datum01       LIKE syst-datum,
        datum02       LIKE syst-datum,
        paramet(64)   TYPE c,
        davsid        LIKE bkorm-avsid,
        dabbukr       LIKE bkorm-bbukr,
        dacajon       LIKE bkorm-cajon,
        dabstat       LIKE bkpf-bstat,

        hparame(64)   TYPE c.

*-------Trigger
DATA:   anzdt         LIKE t048-anzdt.

*-------Flags-----------------------------------------------------------

DATA:   xaconz(1)     TYPE c.                   "Aconto-Zahlung
DATA:   xanzaz(1)     TYPE c.                   "Anzahlung
DATA:   xaugbl(1)     TYPE c.                   "Ausgleichsbeleg
DATA:   xapos(1)      TYPE c.                   "AP
DATA:   xopos(1)      TYPE c.                   "OP
DATA:   xmpos(1)      TYPE c.                   "Merkposten
DATA:   xbvorg(1)     TYPE c.                   "Buchungskreis?bergr.V.
DATA:   xbkorm(1)     TYPE c.                   "Daten aus BKORm
DATA:   xtsubm(1)     TYPE c.                   "Rep. durch Trigger subm
DATA:   xindko(1)     TYPE c.                   "individuelle Korresp.
DATA:   xextra(1)     TYPE c.                   "Daten extrahiert
DATA:   xverr(1)      TYPE c.                   "Verr. Debi./Kred.
DATA:   xvorh(1)      TYPE c.                   "vorhanden Flag
DATA:   xvorh2(1)     TYPE c.                   "vorhanden Flag
DATA:   xdezv(1)      TYPE c.                   "dezv Filialen
DATA:   xnzgz(1)      TYPE c.                   "nicht zugeordn. Buzei
DATA:   print(1)      TYPE c.                   "Flag f?r print
DATA:   xonli(1)      TYPE c.                   "Fl. f. online Protokoll
DATA:   xopen(1)      TYPE c.                   "Flag f?r open_form
DATA:   xopen_executed(1)  TYPE c.              " open executed at least once
DATA:   xkausg(1)     TYPE c.                   "Flag keine ausgabe
DATA:   xkausgzt(1)   TYPE c.                   "Flag keine ausgabe
DATA:   xacpd(1)      TYPE c.                   "Flag cpd-Adresse
DATA:   xadrs(1)      TYPE c.                   "Flag adresse vorhanden
DATA:   xadr2(1)      TYPE c.                   "Flag adresse vorhanden
DATA:   xopausg(1)    TYPE c.                   "Flag OP vorhanden
DATA:   xzent(1)      TYPE c.                   "Flag f?r Zentrale
DATA:   hxdezv(1)     TYPE c.                   "Flag f?r dezentr. Ver.
DATA:   xende(1)      TYPE c.                   "Ende-Flag
DATA:   xsatz(1)      TYPE c.                   "Flag f?r Datensatz
DATA:   xsel(1)       TYPE c.                   "Flag f?r Datensatz
DATA:   xsel2(1)      TYPE c.                   "Flag f?r Datensatz
DATA:   untyp(1)      TYPE c.                   "Flag f. Unternehmenstyp
DATA:   hkoar(1)      TYPE c.                   "Flag f. kontoart
DATA:   anzko(1)      TYPE c.                   "Flag f. Anzahl kontoart
DATA:   xbegin(1)     TYPE c.                   "Flag f. Beginn
DATA:   xbegin2(1)    TYPE c.                   "Flag f. Beginn
DATA:   xbela(1)      TYPE c.                   "Flag f?r Belastung
DATA:   xguts(1)      TYPE c.                   "Flag f?r Gutschrift.
DATA:   xprol(1)      TYPE c.                   "Flag f?r W.prolongation
DATA:   xtop1(1)      TYPE c.                   "Flag f?r Top-ausgabe
DATA:   xsort(1)      TYPE c.                   "Flag f?r Sortierung
DATA:   xprint(1)     TYPE c.                   "Flag f?r Druck
DATA:   xpriim(1)     TYPE c.                   "Flag f?r Druck
DATA:   xsumme(1)     TYPE c.                   "Flag f?r summe
DATA:   xteilz(1)     TYPE c.                   "Flag f?r Teilzahlung
DATA:   xkdel(1)      TYPE c.                   "Flag f?r nicht l?schen
DATA:   xinit(1)      TYPE c.                   "Flag Fehlermeldungen
DATA:   xnach(1)      TYPE c.                   "Flag Fehlermeldungen
DATA:   xumskz(1)     TYPE c.                   "Flag Sort. nach UMSKZ
DATA:   xpkont(1)     TYPE c.                   "Flag Sort. nach Konto
DATA:   xkauth(1)     TYPE c.                   "Flag keine Berechtigung
DATA:   xkaut2(1)     TYPE c.                   "Flag keine Berechtigung
DATA:   xkaut3(1)     TYPE c.                   "Flag keine Berechtigung
DATA:   xmultk(1)     TYPE c.                   "Flag mehrere Konten
DATA:   xactiv(1)     TYPE c.                   "Flag Aktiv
DATA:   xexter(1)     TYPE c.                   "Flag Extern
*DATA:   Xsubc(1)      TYPE C.                   "Flag ALW
DATA    xrun(1)       TYPE c.                   "Sperrflag für SAPF140

DATA:   xstart(1)    TYPE c,                    "Flag f?r Formularstart
        xstart2(1)   TYPE c,                    "Flag f?r Formularstart
        xstart3(1)   TYPE c,                    "Flag f?r Formularstart
        xstart4(1)   TYPE c,                    "Flag f?r Formularstart
        xstart5(1)   TYPE c,                    "Flag f?r Formularstart
        xstart6(1)   TYPE c,                    "Flag f?r Formularstart
        xknid(1)     TYPE c,                    "Flag f?r Open Form
        xspid(1)     TYPE c,                    "Flag f?r Spool ID
        xtop(1)      TYPE c,                    "Flag f?r ?berschrift
        flprotect(1) TYPE c,                    "Flag f?r Seiten?berlauf
        flspras(1)   TYPE c,                    "Flag f?r Ausgabesprache
        flkform(1)   TYPE c.                  "Flag f?r Form. an Debitor

DATA:   hfunktion(1) TYPE c.                    "Flag indiv. Texterfass.
DATA:   htexterf(1)  TYPE c.                    "Flag Text direkt erfa?t
DATA:   hindtext(1)  TYPE c.                    "Flag individuell. Text

DATA:   function(1)  TYPE c.                    "Flag Texteditor
DATA:   found(1)     TYPE c.                    "Flag Formular gefunden
DATA:   oldform(1)   TYPE c.                    "Flag Formular alt
DATA:   xtdnewid     LIKE itcpo-tdnewid.        "Neuer Spoolauftrag?

DATA:   sortid(2)    TYPE p.                    "Flag f?r Sortierung bei
"bestimmtem Druckreport

*-------Trigger
DATA:   xkont         LIKE t048-xkont.
DATA:   xbelg         LIKE t048-xbelg.
DATA:   kautofl(1)    TYPE c.

DATA:   xerdt(1)      TYPE c.

DATA:   delete(1)     TYPE c.
DATA:   insert(1)     TYPE c.
DATA:   update(1)     TYPE c.

*-------Internet--------------------------------------------------------
DATA:   x_sent_to_all LIKE sonv-flag.
DATA:   doc_size(12) TYPE c.

DATA:   hfeld(500) TYPE c.
DATA:   hkora(50)  TYPE c.
DATA:   off1       TYPE p.
DATA:   fle1(2)    TYPE p.
DATA:   fle2(2)    TYPE p.
DATA:   htabix     LIKE sy-tabix.

DATA:   hprofil    LIKE soprd.

DATA: hformat(10) TYPE c.

DATA: document_type LIKE soodk-objtp.
DATA: linecnt      TYPE p.

*-------Rechenfelder----------------------------------------------------
DATA:   refe1         TYPE p.
DATA:   refe2         TYPE p.
DATA:   refe3         TYPE p.
DATA:   refe4         TYPE p.
DATA:   hvztage       LIKE rf140-vztas.
DATA:   hbetrag       LIKE rf140-saldo.
DATA:   augbetr       LIKE rf140-saldo.
DATA:   hwbetr        LIKE bseg-dmbtr.
DATA:   fwbetr        LIKE bseg-wrbtr.
DATA:   hbetr         LIKE bseg-wrbtr.
DATA:   hsaldo        LIKE rfsdo-doprsal2.
DATA:   hsaldo2       LIKE rf140-saldo.
DATA:   checksaldo(8) TYPE p.
DATA:   checksald1(8) TYPE p DECIMALS 1.
DATA:   checksald2(8) TYPE p DECIMALS 2.
DATA:   checksald3(8) TYPE p DECIMALS 3.

DATA:   cfakt(3)      TYPE p.
DATA:   anzdru(3)     TYPE n.                      "Anzahl Ausdrucke
DATA:   anzdr2(3)     TYPE n.                      "Anzahl Ausdrucke
DATA:   anzwie(2)     TYPE n.                      "Anzahl Wiederungen

*-------Counts----------------------------------------------------------
DATA:   count1        TYPE p.
DATA:   count2        TYPE p.

DATA:   counta        TYPE p.                     "Auswahl Zeilen

DATA:   countm        TYPE p.                     "Hilfsz?hler f?r

DATA:   countp        TYPE p.                     "Ausgabe Seiten

DATA:   counts        TYPE p.                     "Satze BKORM

DATA:   countz        TYPE p.                     "Zeilencount

DATA:   countd        TYPE p.                     "Debitoren
DATA:   countk        TYPE p.                     "Kreditoren

DATA:   i             TYPE i.

DATA:   blosp         TYPE i.                   "Flag Belast. oh. Spesen
DATA:   blmsp         TYPE i.                   "Flag Belast. mit Spesen
DATA:   gsosp         TYPE i.                   "Flag Gutschr. o. Spesen
DATA:   gsmsp         TYPE i.                   "Flag Gutschr. m. Spesen

DATA:   aagzlines     TYPE i.                     "Zeilen aagz
DATA:   admplines     TYPE i.                     "Zeilen merkposten
DATA:   akmplines     TYPE i.                     "Zeilen merkposten
DATA:   aaazlines     TYPE i.                     "Zeilen aaaz
DATA:   aabzlines     TYPE i.                     "Zeilen aabz
DATA:   atzzlines     TYPE i.                     "Zeilen atzz
DATA:   arpzlines     TYPE i.                     "Zeilen arpz
DATA:   aaczlines     TYPE i.                     "Zeilen aacZ
DATA:   anzzlines     TYPE i.                     "Zeilen anzZ
DATA:   opstlines     TYPE i.                     "Zeilen hopsort
DATA:   sldalines     TYPE i.                     "Zeilen saldoa
DATA:   sldelines     TYPE i.                     "Zeilen saldoe
DATA:   sldflines     TYPE i.                     "Zeilen saldof
DATA:   sldmlines     TYPE i.                     "Zeilen saldom
DATA:   sldblines     TYPE i.                     "Zeilen saldob
DATA:   sldglines     TYPE i.                     "Zeilen saldog

DATA:   bkplines      TYPE i.                     "Zeilen hbkpf
DATA:   bkdlines      TYPE i.                     "Zeilen hbkdf
DATA:   kunlines      TYPE i.                     "Zeilen KUNNR_BSEG
DATA:   kualines      TYPE i.                     "Zeilen aKUNNR_WESPE
DATA:   kuwlines      TYPE i.                     "Zeilen KUNNR_WESPE
DATA:   kuawlines     TYPE i.                     "Zeilen KUNNR_aWESPE
DATA:   liflines      TYPE i.                     "Zeilen LIFNR_BSEG
DATA:   lialines      TYPE i.                     "Zeilen aLIFNR_WESPE
DATA:   liwlines      TYPE i.                     "Zeilen LIFNR_WESPE
DATA:   liawlines     TYPE i.                     "Zeilen LIFNR_aWESPE
DATA:   awsplines     TYPE i.                     "Zeilen ahwespe

DATA:   didlines      TYPE i.                     "Zeilen hbsid
DATA:   aidlines      TYPE i.                     "Zeilen hbsid
DATA:   dmplines      TYPE i.                     "Zeilen dmpos
DATA:   doplines      TYPE i.                     "Zeilen dopos

DATA:   kiklines      TYPE i.                     "Zeilen hbsik
DATA:   aiklines      TYPE i.                     "Zeilen hbsik
DATA:   aoplines      TYPE i.                     "Zeilen dopos,kopos
DATA:   amplines      TYPE i.                     "Zeilen dmpos,kmpos
DATA:   kmplines      TYPE i.                     "Zeilen kmpos
DATA:   koplines      TYPE i.                     "Zeilen kopos

DATA:   spelines      TYPE i.                     "Zeilen NEWsp

DATA:   tgrlines      TYPE i.                     "Zeilen htxgrp

DATA:   taxlines      TYPE i.                     "Zeilen atax

DATA:   buklines      TYPE i.                     "Zeilen rbukrs

DATA:   hbklines      TYPE i.                     "Zeilen hbkorm

DATA:   hsolines      TYPE i.                     "Zeilen sort

DATA:   hkolines      TYPE i.                     "Zeilen hbkorm_bearb

DATA:   hltlines      TYPE i.                     "Zeilen HLTDNAM
"Zeilen HTLINES

DATA:   av1lines      TYPE i.                     "Zeilen avis
DATA:   av2lines      TYPE i.

DATA:   cntlines      TYPE i.                     "Zeilen
DATA:   cn2lines      TYPE i.                     "Zeilen

*-------Trigger
DATA:   derldt        TYPE p.
DATA:   daktdt        TYPE p.

DATA:   htage         TYPE p.

DATA:   dellines      TYPE i.
DATA:   koalines      TYPE i.
DATA:   ktolines      TYPE i.
DATA:   blnlines      TYPE i.
DATA:   gjalines      TYPE i.

DATA:   erllines      TYPE i.
DATA:   usrlines      TYPE i.
DATA:   datlines      TYPE i.
DATA:   timlines      TYPE i.

DATA:   evelines      TYPE i.
DATA:   cajlines      TYPE i.

DATA:   fldlines      TYPE i.

DATA:   count3        TYPE p.
DATA:   count4        TYPE p.

*-------Commitz?hler----------------------------------------------------
DATA:   commit_c(4)   TYPE n,             "count f?r Commit
        commit_m(4)   TYPE n VALUE '20',  "max. Anzahl bis Commit
        commit_m2(4)   TYPE n VALUE '200'.  "max. Anzahl bis Commit

*-------Hilfsfelder ----------------------------------------------------
DATA:   ereignis(4)  TYPE c,            "Ereignis f?r die Textverarbeit.
        form         LIKE t001f-fornr,      "Hilfsfeld f?r Messages
        window       LIKE rsscf-tdelement,  "Hilfsfeld f?r Messages
        ftext        LIKE rf130-texte,      "Hilfsfeld f?r Messages
        startpage    LIKE itcta-tdfirstpag, "Hilfsfeld f?r Messages
        mbukrs       LIKE knb1-bukrs,       "Hilfsfeld f?r Messages
        language     LIKE kna1-spras,  "Hilfsfeld Korrespondenzsprache
        language2    LIKE kna1-spras,  "Hilfsfeld Korrespondenzsprache
        netdt        LIKE rf140-netdt. "Hilfsfeld Verzugsberechnung

DATA:   htdid        LIKE thead-tdid,    "Hilfsfeld f?r individuelle
        htdname      LIKE thead-tdname,  "Texterfassung
        htdnam2      LIKE thead-tdname,  "Texterfassung
        htdspras     LIKE thead-tdspras,
        htdobject    LIKE thead-tdobject,
        hline        LIKE tline-tdline.

DATA:   hstaro       LIKE sy-staro.
DATA:   hlsind       LIKE sy-lsind.

DATA:   hanswer      TYPE c.
DATA:   htext35(35)  TYPE c.
DATA:   hfeld16(16)  TYPE c.

DATA:   char40(40)   TYPE c.

*ATA:   CHAR132(132) TYPE C VALUE      '--------------------------------
*-----------------------------------------------------------------------
*---------------------------'.

DATA:   posnum1(1)   TYPE n.
DATA:   posnum2(1)   TYPE c.
DATA:   posnum3(1)   TYPE c.

DATA:   ok_code      LIKE syst-ucomm.

DATA:   feldname(20) TYPE c.

DATA:   htext(7)     TYPE c.

DATA:   koarttxt(4)  TYPE c.

DATA:   prolistn     LIKE itcpo-tdsuffix2.

DATA:   belegkey(18) TYPE c.

DATA:   memokey(20)  TYPE c.

DATA:   hmsort       LIKE fimsg-msort.

DATA:   hpkont(1)    TYPE n.
DATA:   hpkon2(1)    TYPE n.
DATA:   hpumsk(1)    TYPE n.

DATA:   deldatum     LIKE sy-datum.

DATA:   htddevice    LIKE itcpp-tddevice.
DATA:   hdialog      TYPE c.

*-------SAVE-Felder ----------------------------------------------------
DATA:   save_anbwa    LIKE bseg-anbwa.
DATA:   save_anln1    LIKE bseg-anln1.
DATA:   save_anln2    LIKE bseg-anln2.
DATA:   save_anzzl    LIKE adrs-anzzl.
DATA:   save_aufnr    LIKE bseg-aufnr.
DATA:   save_augbl    LIKE bseg-augbl.
DATA:   save_augdt    LIKE bseg-augdt.
DATA:   save_bankl    LIKE bsec-bankl.
DATA:   save_bankn    LIKE bsec-bankn.
DATA:   save_banks    LIKE bsec-banks.
DATA:   save_iban     TYPE iban.
DATA:   save_bbukr    LIKE bseg-bukrs.
DATA:   save_belnr    LIKE bseg-belnr.
DATA:   save2_belnr   LIKE bseg-belnr.
DATA:   save_bewar    LIKE bseg-bewar.
DATA:   save_blart    LIKE bkpf-blart.
DATA:   save_blnkz    LIKE bseg-blnkz.
DATA:   save_bschl    LIKE bseg-bschl.
DATA:   save_budat    LIKE bkpf-budat.
DATA:   save_bukrs    LIKE bseg-bukrs.
DATA:   save2_bukrs   LIKE bseg-bukrs.
DATA:   save3_bukrs   LIKE bseg-bukrs.
DATA:   save_buzei    LIKE bseg-buzei.
DATA:   save2_buzei   LIKE bseg-buzei.
DATA:   save3_buzei   LIKE bseg-buzei.
DATA:   save_busab    LIKE knb1-busab.
DATA:   save2_busab   LIKE knb1-busab.
DATA:   save_bvorg    LIKE bkpf-bvorg.
DATA:   save_bvtyp    LIKE bseg-bvtyp.
DATA:   save_bwtar    LIKE bseg-bwtar.
DATA:   save_cajon    LIKE tcj_documents-cajo_number.
DATA:   save_datum    LIKE syst-datum.
DATA:   save2_datum   LIKE syst-datum.
DATA:   save3_datum   LIKE syst-datum.
DATA:   save_dbakz    LIKE bkdf-dbakz.
DATA:   save_dspras   TYPE c.
DATA:   save_domname  LIKE dd07l-domname.
DATA:   save_domvalue LIKE dd07l-domvalue_l.
DATA:   save_ddtext   LIKE dd07t-ddtext.
DATA:   save_egrup    LIKE bseg-egrup.
DATA:   save_empfg    LIKE bsec-empfg.
DATA:   save_empf1    LIKE bsec-empfg.
DATA:   save2_empfg   LIKE bsec-empfg.
DATA:   save3_empfg   LIKE bsec-empfg.
DATA:   save_ereign   LIKE ereignis.
DATA:   save2_event   LIKE bkorm-event.
DATA:   save3_event   LIKE bkorm-event.
DATA:   save_faedt    LIKE bsega-netdt.
DATA:   save_fbelg    TYPE c.
DATA:   save_fdgrp    LIKE bseg-fdgrp.
DATA:   save_fdlev    LIKE bseg-fdlev.
DATA:   save_forid    LIKE t001f-event.
DATA:   save_form     LIKE t001f-fornr.
DATA:   save_fwnav    LIKE bset-fwste.
DATA:   save_fwste    LIKE bset-fwste.
DATA:   save_gjahr    LIKE bseg-gjahr.
DATA:   save2_gjahr   LIKE bseg-gjahr.
DATA:   save_gsber    LIKE bseg-gsber.
DATA:   save_hbkid    LIKE bseg-hbkid.
DATA:   save_idpos    LIKE tinso-idpos.
DATA:   save_kagza    TYPE c.
DATA:   save_koar1    LIKE bseg-koart.
DATA:   save_koart    LIKE bseg-koart.
DATA:   save2_koart   LIKE bseg-koart.
DATA:   save3_koart   LIKE bseg-koart.
DATA:   save4_koart   LIKE bseg-koart.
DATA:   save_kokrs    LIKE bseg-kokrs.
DATA:   save_kalsm    LIKE t007s-kalsm.
DATA:   save_kont1    LIKE bseg-kunnr.
DATA:   save_konto    LIKE bseg-kunnr.
DATA:   save2_konto   LIKE bseg-kunnr.
DATA:   save3_konto   LIKE bseg-kunnr.
DATA:   save_ktopl    LIKE t001-ktopl.
DATA:   save_ktosl    LIKE t030-ktosl.
DATA:   save_kostl    LIKE bseg-kostl.
DATA:   save_kunnr    LIKE bseg-kunnr.
DATA:   save2_kunnr   LIKE bseg-kunnr.
DATA:   save_kursf    LIKE bkpf-kursf.
DATA:   save_land1    LIKE t001-land1.
DATA:   save2_land1   LIKE t001-land1.
DATA:   save3_land1   LIKE t001-land1.
DATA:   save_langu    LIKE syst-langu.
DATA:   save2_langu   LIKE syst-langu.
DATA:   save_lifnr    LIKE bseg-lifnr.
DATA:   save2_lifnr   LIKE bseg-lifnr.
DATA:   save_lzbkz    LIKE bseg-lzbkz.
DATA:   save_maber    LIKE bseg-maber.
DATA:   save_mansp    LIKE bseg-mansp.
DATA:   save_matnr    LIKE bseg-matnr.
DATA:   save_msehi    LIKE t006a-msehi.
DATA:   save_mschl    LIKE bseg-mschl.
DATA:   save_mwskz    LIKE bseg-mwskz.
DATA:   save_mwsk1    LIKE bseg-mwsk1.
DATA:   save_mwsk2    LIKE bseg-mwsk2.
DATA:   save_mwsk3    LIKE bseg-mwsk3.
DATA:   save_pdest    LIKE syst-pdest.
DATA:   save_proid(4) TYPE c.
DATA:   save_prctr    LIKE bseg-prctr.
DATA:   save_prdest   LIKE itcpo-tddest.
DATA:   save_qsskz    LIKE t059q-qsskz.
DATA:   save_rdatar   LIKE rfpdo1-f140data.
DATA:   save_rxavis   TYPE c.
DATA:   save_recid    LIKE bseg-recid.
DATA:   save_repid    LIKE t048b-progn.
DATA:   save2_repid   LIKE t048b-progn.
DATA:   save_rsimul   TYPE c.
DATA:   save_rstgr    LIKE bseg-rstgr.
DATA:   save_rxopol   TYPE c.
DATA:   save_rxdifa   TYPE c.
DATA:   save_rxtsub   LIKE xtsubm.
DATA:   save_rindko   LIKE xindko.
DATA:   save_rimmd    TYPE c.
DATA:   save_rimmd_prot TYPE c.
DATA:   save_rxbkor   TYPE c.
DATA:   save_rxfaed   TYPE c.
DATA:   save_rxekvb   TYPE c.
DATA:   save_rxverr   TYPE c.
DATA:   save_rxdezv   TYPE c.
DATA:   save_rzlsch   LIKE paymi-zlsch.
DATA:   save_rxbukr   LIKE rf022-xbukr.
DATA:   save_saknr    LIKE skat-saknr.
*ATA:   SAVE_SORT     TYPE C.
DATA:   save_sortvk   LIKE rfpdo1-kordvark.
DATA:   save_sortvp   LIKE rfpdo1-kordvarp.
DATA:   save_sortvp2  LIKE rfpdo1-kordvarp.
DATA:   save_shkzg    LIKE bseg-shkzg.
DATA:   save_spras    LIKE t687t-spras.
DATA:   save2_spras   LIKE t687t-spras.
DATA:   save_statbl   TYPE c.
DATA:   save_statu(4) TYPE c.
DATA:   save_stida    LIKE bkpf-budat.
DATA:   save_subrc    LIKE syst-subrc.
DATA:   save_tabix    LIKE syst-tabix.
DATA:   save2_tabix   LIKE syst-tabix.
DATA:   save_tkoid    LIKE t001g-txtid.
DATA:   save_tddest   LIKE itcpo-tddest.
DATA:   save_txgrp    LIKE bset-txgrp.
DATA:   save_txjcd    LIKE bseg-txjcd.
DATA:   save_txtnr    LIKE t050t-txtnr.
DATA:   save_umskz    LIKE bseg-umskz.
DATA:   save_usnam    LIKE bkpf-usnam.
DATA:   save_uzawe    LIKE bseg-uzawe.
DATA:   save_uzeit    LIKE syst-uzeit.
DATA:   save_vbewa    LIKE bseg-vbewa.
DATA:   save_vbund    LIKE bseg-vbund.
DATA:   save_vname    LIKE bseg-vname.
DATA:   save_vtext    LIKE t687t-vtext.
DATA:   save_waers    LIKE bkpf-waers.
DATA:   save_werks    LIKE bseg-werks.
DATA:   save_wevwv    LIKE bsed-wevwv.
DATA:   save_wrbtr    LIKE bseg-wrbtr.
DATA:   save_wstat    LIKE bsed-wstat.
DATA:   save_wstkz    LIKE bsed-wstkz.
DATA:   save_wwert    LIKE bkpf-wwert.
DATA:   save_xblnr    LIKE bkpf-xblnr.
DATA:   save_xumstn   TYPE c.
DATA:   save_zalbt    LIKE rf140-zalbt.
DATA:   save2_zalbt   LIKE rf140-zalbt.
DATA:   save_zlhbt    LIKE rf140-zalbt.
DATA:   save_zlsbt    LIKE rf140-zalbt.
DATA:   save_zalfw    LIKE rf140-zalbt.
DATA:   save_zlspr    LIKE t008t-zahls.
DATA:   save_zlsch    LIKE bseg-zlsch.
DATA:   save_bshkonto LIKE bseg-hkont.
DATA:   save_bsskonto LIKE bseg-hkont.
DATA:   save_ubhkonto LIKE bseg-hkont.
DATA:   save_ubskonto LIKE bseg-hkont.

***<<<pdf-enabling
DATA:   save_repid_alw LIKE t048b-progn.
DATA:   save_ftype     TYPE rfkord_ftype. "space, 2 smartforms, 3 pdf
DATA:   save_fm_name   TYPE rs38l_fnam.
DATA:   save_outputdone TYPE fpoutdone.
DATA:   gd_is_open TYPE c.
***>>>pdf-enabling

DATA:   auszbsd       LIKE t041a-bskso.
DATA:   einzbsd       LIKE t041a-bskso.
DATA:   auszbsk       LIKE t041a-bskso.
DATA:   einzbsk       LIKE t041a-bskso.

*-------Sortierfelder---------------------------------------------------
DATA:   sort1(35)     TYPE c.
*ATA:   SORT2(35)     TYPE C.
*ATA:   SORT3(35)     TYPE C.

DATA:   sortk1(18)    TYPE c.
DATA:   sortk2(18)    TYPE c.
DATA:   sortk3(18)    TYPE c.
DATA:   sortk4(18)    TYPE c.
DATA:   sortk5(18)    TYPE c.

DATA:   sortp1(18)    TYPE c.
DATA:   sortp2(18)    TYPE c.
DATA:   sortp3(18)    TYPE c.
DATA:   sortp4(18)    TYPE c.
DATA:   sortp5(18)    TYPE c.

*-------Trigger

DATA:   save_event    LIKE bkorm-event.
DATA:   save_progn    LIKE t048b-progn.
DATA:   save_varia    LIKE t048b-varia.

*-------Konstanten -----------------------------------------------------
DATA:   taxbasis      LIKE bseg-wrbtr VALUE '100000'.

*-------Auslaufende Waehrungen------------------------------------------
DATA:  alw_waers      LIKE bkpf-waers,
       hfixed_rate    LIKE tcurr-ukurs.

*-------Währungsumstellung----------------------------------------------
DATA:  pcc_waers      LIKE bkpf-waers,
       process        TYPE char08,
       pcc_nocheck    TYPE  xfeld.
DATA:  save_xpccss    TYPE xfeld VALUE 'X'.  "Split Balances by old currency

*-----------------------------------------------------------------------
*       Teil 2 : Strukturen
*-----------------------------------------------------------------------
DATA: BEGIN OF COMMON PART.                                "#EC PART_OK

*-------Hilfs-BKPF zur Sicherung des Einzelbeleges----------------------
DATA:   BEGIN OF save_bkpf.
        INCLUDE STRUCTURE bkpf.
DATA:   END OF save_bkpf.

*-------Hilfsstruktur f?r Bearbeitetkennzeichen-------------------------
DATA:   BEGIN OF bearb,
          bearb(1) TYPE c,
        END OF bearb.

*-------Hilfsstruktur f?r Saldenberechnung bei mehreren W?hrungen ------
*-------und Verzugstage bei offenen Posten------------------------------
DATA:   BEGIN OF saldw,
          hxbln LIKE bkpf-xblnr,
*         PSWBT LIKE BSEG-PSWBT,
*         PSWSL LIKE BSEG-PSWSL,
          vztas LIKE rf140-vztas,
          netdt LIKE rf140-netdt,
          nebtr LIKE bseg-nebtr,
          zalbt LIKE rf140-zalbt,
        END OF saldw.

*-------Hilfsstruktur BSIK-Felder die nicht in BSID sind ---------------
DATA:   BEGIN OF difbsidk,
          diekz LIKE bsik-diekz,
          ebeln LIKE bsik-ebeln,
          ebelp LIKE bsik-ebelp,
          kzbtr LIKE bsik-kzbtr,
          lifnr LIKE bsik-lifnr,
          lnran LIKE bsik-lnran,
          qbshb LIKE bsik-qbshb,
          qsfbt LIKE bsik-qsfbt,
          qsshb LIKE bsik-qsshb,
          qsznr LIKE bsik-qsznr,
          xesrd LIKE bsik-xesrd,
          zekkn LIKE bsik-zekkn,
          zolld LIKE bsik-zolld,
          zollt LIKE bsik-zollt,
        END   OF difbsidk.

*-------Hilfsstruktur f?r individuelle Texterfassung--------------------
DATA:   BEGIN OF htheader.
        INCLUDE STRUCTURE thead.
DATA:   END OF htheader.

DATA:   BEGIN OF htheader2.
        INCLUDE STRUCTURE thead.
DATA:   END OF htheader2.

DATA:   BEGIN OF hheader,
          hdbukrs LIKE hdbukrs,
          sort1   LIKE sort1,
*         SORT2   LIKE SORT2,
*         SORT3   LIKE SORT3,
          sortk1  LIKE sortk1,
          sortk2  LIKE sortk2,
          sortk3  LIKE sortk3,
          sortk4  LIKE sortk4,
          sortk5  LIKE sortk5,
          hdkoart LIKE hdkoart,
          hdkonto LIKE hdkonto,
          hdbelgj LIKE hdbelgj,
          hdusnam LIKE hdusnam,
          hddatum LIKE hddatum,
          hduzeit LIKE hduzeit,
          dabelnr LIKE dabelnr,
          dagjahr LIKE dagjahr,
          dabbukr LIKE dabbukr,
          dacajon LIKE dacajon,
        END OF hheader.

*-------Hilfsstruktur f?r Sortierreihenfolge----------------------------
DATA: BEGIN OF sortf,
        pos1(7)  TYPE c,
        space    TYPE c,
        pos2(7)  TYPE c,
        space    TYPE c,
        pos3(7)  TYPE c,
        space    TYPE c,
        pos4(7)  TYPE c,
        space    TYPE c,
        pos5(7)  TYPE c,
        space    TYPE c,
        pos6(7)  TYPE c,
        space    TYPE c,
        pos7(7)  TYPE c,
        space    TYPE c,
        pos8(7)  TYPE c,
        space    TYPE c,
        pos9(7)  TYPE c,
        space    TYPE c,
      END   OF sortf.

DATA: BEGIN OF hsortp,
        sortp1 LIKE sortp1,
        sortp2 LIKE sortp2,
        sortp3 LIKE sortp3,
        sortp4 LIKE sortp4,
        sortp5 LIKE sortp5,
*         EKVBD  LIKE KNB1-EKVBD,
      END   OF hsortp.

DATA: BEGIN OF hlp_t021m_k.
        INCLUDE STRUCTURE t021m.
DATA: END   OF hlp_t021m_k.

DATA: BEGIN OF hlp_t021m_p.
        INCLUDE STRUCTURE t021m.
DATA: END   OF hlp_t021m_p.

DATA: BEGIN OF hlp_t021m_p2.
        INCLUDE STRUCTURE t021m.
DATA: END   OF hlp_t021m_p2.

*-------Hilfsstruktur f?r Messages--------------------------------------
DATA: BEGIN OF hbkormkey,
        bukrs LIKE bkorm-bukrs,
        space TYPE c,
        koart LIKE bkorm-koart,
        space TYPE c,
        konto LIKE bkorm-konto,
        space TYPE c,
        belnr LIKE bkorm-belnr,
        space TYPE c,
        gjahr(4) TYPE c,
      END   OF hbkormkey.

DATA: BEGIN OF herdata,
        usnam LIKE bkorm-usnam,
        space TYPE c,
        datum LIKE bkorm-datum,
        space TYPE c,
        uzeit LIKE bkorm-uzeit,
        space TYPE c,
        erldt(8) TYPE c,
      END   OF herdata.

DATA: BEGIN OF hkokrst,
        kokrs LIKE cskt-kokrs,
        space TYPE c,
        kostl LIKE cskt-kostl,
      END   OF hkokrst.

DATA: BEGIN OF hjvkey,
        vname LIKE t8jft-vname,
        space TYPE c,
        egrup LIKE t8jft-egrup,
      END   OF hjvkey.

DATA: BEGIN OF hkokon,
        koart LIKE bkorm-koart,
        space TYPE c,
        konto LIKE bkorm-konto,
      END   OF hkokon.

*-------Stuktur f?r Skontoermittlung------------------------------------
DATA: BEGIN OF sktlit,
        bukrs LIKE bseg-bukrs,
        belnr LIKE bseg-belnr,
        buzei LIKE bseg-buzei,
        koart LIKE bseg-koart,
        shkzg LIKE bseg-shkzg,
        rebzg LIKE bseg-rebzg,
        rebzj LIKE bseg-rebzj,
        rebzz LIKE bseg-rebzz,
        waers LIKE bkpf-waers,
        wrbtr LIKE bseg-wrbtr,
        skfbt LIKE bseg-skfbt,
        wskto LIKE bseg-wskto,
        zfbdt LIKE bseg-zfbdt,
        zbd1t LIKE bseg-zbd1t,
        zbd1p LIKE bseg-zbd1p,
        zbd2t LIKE bseg-zbd2t,
        zbd2p LIKE bseg-zbd2p,
        zbd3t LIKE bseg-zbd3t,
        zbfix LIKE bseg-zbfix,
        sktd1 LIKE bseg-zfbdt,
        wskt1 LIKE bseg-wskto,
        sktd2 LIKE bseg-zfbdt,
        wskt2 LIKE bseg-wskto,
        wskta LIKE bseg-wskto,
        netdt LIKE bseg-zfbdt,
        xnetb LIKE bsid-xnetb,
     END   OF sktlit.

DATA: selection     LIKE addr1_sel,
      address_value LIKE addr1_val,
      user_address  LIKE addr3_val.

DATA: h_archive_index   LIKE toa_dara,
      h_archive_params  LIKE arc_params.

DATA: xbkpf             LIKE bkpf.

*-----------------------------------------------------------------------
*       Teil 3 : Interne Tabellen
*-----------------------------------------------------------------------

*-------Hilfs-BKDF -----------------------------------------------------
DATA:   BEGIN OF hbkdf OCCURS 10.
        INCLUDE STRUCTURE bkdf.
DATA:   END OF hbkdf.

*-------Hilfs-BKPF -----------------------------------------------------
DATA:   BEGIN OF hbkpf OCCURS 10.
        INCLUDE STRUCTURE bkpf.
DATA:   END OF hbkpf.

DATA:   BEGIN OF habkpf OCCURS 10.
        INCLUDE STRUCTURE abkpf.
DATA:   END OF habkpf.

*-------Belegliste------------------------------------------------------
DATA:   BEGIN OF lbelnr OCCURS 10,
          bukrs  LIKE bseg-bukrs,
          belnr  LIKE bseg-belnr,
          gjahr  LIKE bseg-gjahr,
        END OF lbelnr.

*-------Belegzeilen mit Debi oder Kred.---------------------------------
DATA:   BEGIN OF hbuzei OCCURS 10,
          buzei  LIKE bseg-buzei,
          xbearb TYPE c,
          xcheck TYPE c,
        END OF hbuzei.

*-------Belegzeilen f?r Extract von Debi oder Kred----------------------
DATA:   BEGIN OF hbuzei2 OCCURS 10,
          bukrs  LIKE bseg-bukrs,
          belnr  LIKE bseg-belnr,
          gjahr  LIKE bseg-gjahr,
          buzei  LIKE bseg-buzei,
          koart  LIKE bseg-koart,
          kunnr  LIKE bseg-kunnr,
          lifnr  LIKE bseg-lifnr,
        END OF hbuzei2.

*-------Hilfstabelle BSEG-----------------------------------------------
DATA:   BEGIN OF hbseg OCCURS 10.
        INCLUDE STRUCTURE hsortp.
        INCLUDE STRUCTURE bseg.
DATA:   END OF hbseg.

*-------Hilfstabelle BSEG zur Sicherung des Einzelbeleges---------------
DATA:   BEGIN OF save_bseg OCCURS 10.
        INCLUDE STRUCTURE hsortp.
        INCLUDE STRUCTURE bseg.
DATA:   END OF save_bseg.

*-------offne Posten---------------------------------------------------
DATA:   BEGIN OF hbsid OCCURS 10.
        INCLUDE STRUCTURE hsortp.
        INCLUDE STRUCTURE bsid.
        INCLUDE STRUCTURE saldw.
        INCLUDE STRUCTURE difbsidk.
DATA:   END OF hbsid.

DATA:   BEGIN OF hbsik OCCURS 10.
        INCLUDE STRUCTURE hsortp.
        INCLUDE STRUCTURE bsik.
        INCLUDE STRUCTURE saldw.
DATA:   END OF hbsik.

*-------Ausgleichspositionen-------------------------------------------
DATA:   BEGIN OF hbsad OCCURS 10.
        INCLUDE STRUCTURE hsortp.
        INCLUDE STRUCTURE bsad.
        INCLUDE STRUCTURE saldw.
        INCLUDE STRUCTURE difbsidk.
DATA:   END OF hbsad.

DATA:   BEGIN OF dabseg OCCURS 10.
        INCLUDE STRUCTURE bseg.
DATA:   END OF dabseg.

DATA:   BEGIN OF hbsak OCCURS 10.
        INCLUDE STRUCTURE hsortp.
        INCLUDE STRUCTURE bsak.
        INCLUDE STRUCTURE saldw.
DATA:   END OF hbsak.

DATA:   BEGIN OF kabseg OCCURS 10.
        INCLUDE STRUCTURE bseg.
DATA:   END OF kabseg.

*-------Hilfstabelle VBKPF----------------------------------------------
DATA:   BEGIN OF hvbkpf OCCURS 10.
        INCLUDE STRUCTURE fvbkpf.
DATA:   END OF hvbkpf.

*-------Hilfstabelle VBSEG----------------------------------------------
DATA:   BEGIN OF hvbseg OCCURS 10.
        INCLUDE STRUCTURE fvbseg.
DATA:   END OF hvbseg.

*-------Hilfstabelle VBSEC----------------------------------------------
DATA:   BEGIN OF hvbsec OCCURS 10.
        INCLUDE STRUCTURE fvbsec.
DATA:   END OF hvbsec.

*-------Hilfstabelle VBSET----------------------------------------------
DATA:   BEGIN OF hvbset OCCURS 10.
        INCLUDE STRUCTURE fvbset.
DATA:   END OF hvbset.

*-------Hilfstabelle XBSEG----------------------------------------------
DATA:   BEGIN OF xbseg OCCURS 10.
        INCLUDE STRUCTURE bseg.
DATA:   END OF xbseg.

*******note # 858320
DATA:   BEGIN OF par_bseg OCCURS 10.
          INCLUDE STRUCTURE bseg.
DATA:   END OF par_bseg.
DATA : wa_bseg LIKE LINE OF par_bseg.
*******note # 858320

*-------Saldenangaben bei korrespondenz--------------------------------
DATA:  BEGIN OF saldoa OCCURS 10,               "Anfangssaldo
         waers  LIKE bsid-waers,
         saldoh LIKE rf140-saldo,
         saldow LIKE rf140-saldo,
         salsk  LIKE rf140-salsk,
         saldn  LIKE rf140-saldn,
         waerso LIKE bsid-waers,
         saldoo LIKE rf140-saldo,
       END OF saldoa.

DATA:  BEGIN OF saldoe OCCURS 10,               "Endsaldo
         waers  LIKE bsid-waers,
         saldoh LIKE rf140-saldo,
         saldow LIKE rf140-saldo,
         salsk  LIKE rf140-salsk,
         saldn  LIKE rf140-saldn,
         waerso LIKE bsid-waers,
         saldoo LIKE rf140-saldo,
       END OF saldoe.

DATA:  BEGIN OF saldof OCCURS 10,               "F?llige Posten
         waers  LIKE bsid-waers,
         saldoh LIKE rf140-saldo,
         saldow LIKE rf140-saldo,
         salsk  LIKE rf140-salsk,
         saldn  LIKE rf140-saldn,
       END OF saldof.

DATA:  BEGIN OF saldom OCCURS 10,               "Merkposten
         waers  LIKE bsid-waers,
         saldoh LIKE rf140-saldo,
         saldow LIKE rf140-saldo,
         salsk  LIKE rf140-salsk,
         saldn  LIKE rf140-saldn,
         waerso LIKE bsid-waers,
         saldoo LIKE rf140-saldo,
       END OF saldom.

DATA:  BEGIN OF saldob OCCURS 10,               "Belastungen
         waers  LIKE bsid-waers,                "und Nullsaldentest
         saldoh LIKE rf140-saldo,
         saldow LIKE rf140-saldo,
       END OF saldob.

DATA:  BEGIN OF saldog OCCURS 10,               "Gutschriften
         waers  LIKE bsid-waers,
         saldoh LIKE rf140-saldo,
         saldow LIKE rf140-saldo,
       END OF saldog.

DATA:  BEGIN OF saldok OCCURS 10,               "Saldo pro Konto
         konto  LIKE kna1-kunnr,
         waers  LIKE bsid-waers,
         saldoh LIKE rf140-saldo,
         saldow LIKE rf140-saldo,
         saldop LIKE rf140-saldo,               "saldo soll
         saldon LIKE rf140-saldo,               "saldo haben
         nebtr  LIKE rf140-saldo,
*        SALSK  LIKE RF140-SALSK,
*        SALDN  LIKE RF140-SALDN,
         waerso LIKE bsid-waers,
         saldoo LIKE rf140-saldo,
       END OF saldok.

DATA:  BEGIN OF saldoz OCCURS 10,               "Zwischensummen
         waers  LIKE bsid-waers,
         saldoh LIKE rf140-saldo,
         saldow LIKE rf140-saldo,
         salsk  LIKE rf140-salsk,
         saldn  LIKE rf140-saldn,
         waerso LIKE bsid-waers,
         saldoo LIKE rf140-saldo,
       END OF saldoz.

*-------Zentralen/Filialen   in einem Beleg----------------------------
DATA:   BEGIN OF dzentfil OCCURS 10,
          bukrs LIKE bsad-bukrs,
          kunnr LIKE bsad-kunnr,
          filkd LIKE bsad-filkd,
          lifnr LIKE bsak-lifnr,
          xdezv LIKE knb1-xdezv,
        END OF dzentfil.

DATA:   BEGIN OF kzentfil OCCURS 10,
          bukrs LIKE bsak-bukrs,
          lifnr LIKE bsak-lifnr,
          filkd LIKE bsak-filkd,
          kunnr LIKE bsad-kunnr,
          xdezv LIKE lfb1-xdezv,
        END OF kzentfil.

DATA:   BEGIN OF azentfil OCCURS 10,
          bukrs LIKE bsak-bukrs,
          koart LIKE bseg-koart,
          konto LIKE bsad-kunnr,
          filkd LIKE bsak-filkd,
        END OF azentfil.

*-------CpD-Kunden/CpD-Lieferanten in einem Beleg----------------------
DATA:   BEGIN OF dcpdk_bseg OCCURS 10,
          bukrs   LIKE bseg-bukrs,
          kunnr   LIKE bseg-kunnr,
          empfg   LIKE bsec-empfg,
          aghbt   LIKE rf140-wrshb,
          agsbt   LIKE rf140-wrshb,
          skhbt   LIKE rf140-wsshb,
          sksbt   LIKE rf140-wsshb,
          tzhbt   LIKE rf140-wrshb,
          tzsbt   LIKE rf140-wrshb,
          rphbt   LIKE rf140-wrshb,
          rpsbt   LIKE rf140-wrshb,
          achbt   LIKE rf140-wrshb,
          acsbt   LIKE rf140-wrshb,
          azhbt   LIKE rf140-wrshb,
          azsbt   LIKE rf140-wrshb,
          zlhbt   LIKE rf140-wrshb,
          zlsbt   LIKE rf140-wrshb,
          xbearb   TYPE c,
        END OF dcpdk_bseg.

DATA:   BEGIN OF kcpdk_bseg OCCURS 10,
          bukrs   LIKE bseg-bukrs,
          lifnr   LIKE bseg-lifnr,
          empfg   LIKE bsec-empfg,
          aghbt   LIKE rf140-wrshb,
          agsbt   LIKE rf140-wrshb,
          skhbt   LIKE rf140-wsshb,
          sksbt   LIKE rf140-wsshb,
          tzhbt   LIKE rf140-wrshb,
          tzsbt   LIKE rf140-wrshb,
          rphbt   LIKE rf140-wrshb,
          rpsbt   LIKE rf140-wrshb,
          achbt   LIKE rf140-wrshb,
          acsbt   LIKE rf140-wrshb,
          azhbt   LIKE rf140-wrshb,
          azsbt   LIKE rf140-wrshb,
          zlhbt   LIKE rf140-wrshb,
          zlsbt   LIKE rf140-wrshb,
          xbearb   TYPE c,
        END OF kcpdk_bseg.

*-------Adressdaten----------------------------------------------------
DATA:   BEGIN OF hkna1 OCCURS 10.
        INCLUDE STRUCTURE kna1.
DATA:   END OF hkna1.

DATA:   BEGIN OF hlfa1 OCCURS 10.
        INCLUDE STRUCTURE lfa1.
DATA:   END OF hlfa1.

DATA:   BEGIN OF hknb1 OCCURS 10.
        INCLUDE STRUCTURE knb1.
DATA:   END OF hknb1.

DATA:   BEGIN OF hlfb1 OCCURS 10.
        INCLUDE STRUCTURE lfb1.
DATA:   END OF hlfb1.

DATA:   BEGIN OF hbsec OCCURS 10.
        INCLUDE STRUCTURE bsec.
DATA:   END OF hbsec.

*-------Texttabellen---------------------------------------------------
DATA:   BEGIN OF hdd07t OCCURS 10,
          domname    LIKE dd07l-domname,
          domvalue_l LIKE dd07l-domvalue_l,
          ddlanguage LIKE dd07t-ddlanguage,
          ddtext     LIKE dd07t-ddtext,
        END OF hdd07t.

DATA:   BEGIN OF htbslt OCCURS 10.
        INCLUDE STRUCTURE tbslt.
DATA:   END OF htbslt.

DATA:   BEGIN OF ht050t OCCURS 10.
        INCLUDE STRUCTURE t050t.
DATA:   END OF ht050t.

DATA:   BEGIN OF hskat OCCURS 10.
        INCLUDE STRUCTURE skat.
DATA:   END OF hskat.

*-------Buchungsschl?ssel bei Ausgleich--------------------------------
DATA:   BEGIN OF augbschl OCCURS 60,
          koart LIKE bseg-koart,
          bschl LIKE t041a-bskso,
          shkzg LIKE bseg-shkzg,
          buart TYPE c,                       "Art der Buchung
          auglv LIKE t041a-auglv,
        END OF augbschl.

*-------gescheiterte Zahlungen -----------------------------------------
DATA:   BEGIN OF htinso OCCURS 0.
        INCLUDE STRUCTURE tinso.
DATA:   END   OF htinso.

*------- interene Tabelle f?r Quellensteuer-Daten ----------------------
*DATA:  XWITH_ITEM TYPE TABLE OF WITH_ITEM with header line.
DATA: BEGIN OF xwith_item OCCURS 0.
        INCLUDE STRUCTURE with_item.
DATA: END OF xwith_item.

*------- interne Tabellen f?r Mehrwertsteuer-Daten----------------------
DATA: BEGIN OF tax OCCURS 10,
        bukrs LIKE bkpf-bukrs,
        mwskz LIKE bseg-mwskz,
        ktosl LIKE rtax1u15-ktosl,
        msatz LIKE rtax1u15-msatz,
        stazf LIKE t007b-stazf,
      END OF tax.

DATA: BEGIN OF htax OCCURS 10,
        bukrs LIKE bkpf-bukrs,
        mwskz LIKE bseg-mwskz,
        ktosl LIKE rtax1u15-ktosl,
        msatz LIKE rtax1u15-msatz,
        stazf LIKE t007b-stazf,
      END OF htax.

DATA: BEGIN OF mwdat OCCURS 10.
        INCLUDE STRUCTURE rtax1u15.
DATA: END OF mwdat.

DATA: BEGIN OF taxtxt OCCURS 10,
        kvsl1 LIKE t687t-kvsl1,
        spras LIKE t687t-spras,
        vtext LIKE t687t-vtext,
      END OF taxtxt.

DATA: BEGIN OF htxgrp OCCURS 3,
        mwskz LIKE bset-mwskz,
        txgrp LIKE bset-txgrp,
      END OF htxgrp.

DATA: BEGIN OF atax OCCURS 10,
        msatz LIKE rtax1u15-msatz,
        vtext LIKE t687t-vtext,
        waers LIKE bkpf-waers,
        wmwst LIKE rtax1u15-wmwst,
      END OF atax.

DATA: BEGIN OF hbset OCCURS 10.
        INCLUDE STRUCTURE bset.
DATA: END   OF hbset.

*------- interne Tabellen f?r Filialen ---------------------------------
DATA: BEGIN OF filialen OCCURS 10,
        zentrale LIKE bsid-kunnr,
        filiale  LIKE bsid-filkd,
      END OF filialen.

*------- interne Tabellen f?r Extract-Vorbereitung und Beleganalyse-----
DATA: BEGIN OF hextract OCCURS 10,
        bukrs LIKE bseg-bukrs,
        koar1 LIKE bseg-koart,
        kont1 LIKE bseg-kunnr,
        empf1 LIKE bsec-empfg,
        koar2 LIKE bseg-koart,
        kont2 LIKE bseg-lifnr,
        empf2 LIKE bsec-empfg,
        belnr LIKE bseg-belnr,
        gjahr LIKE bseg-gjahr,
        buzei LIKE bseg-buzei,
        bearb TYPE c,
      END OF hextract.

DATA: BEGIN OF hextractd OCCURS 10,
        bukrs  LIKE bseg-bukrs,
        koar1  LIKE bseg-koart,
        kont1  LIKE bseg-kunnr,
        empf1  LIKE bsec-empfg,
        belnr  LIKE bseg-belnr,
        gjahr  LIKE bseg-gjahr,
        buzei  LIKE bseg-buzei,
        xbearb TYPE c,
      END OF hextractd.

DATA: BEGIN OF hextractk OCCURS 10,
        bukrs  LIKE bseg-bukrs,
        koar1  LIKE bseg-koart,
        kont1  LIKE bseg-kunnr,
        empf1  LIKE bsec-empfg,
        belnr  LIKE bseg-belnr,
        gjahr  LIKE bseg-gjahr,
        buzei  LIKE bseg-buzei,
        xbearb TYPE c,
      END OF hextractk.

*------- interne Tabelle f?r Benutzerdaten------------------------------
DATA: BEGIN OF husr03 OCCURS 10.
        INCLUDE STRUCTURE usr03.                            "USR0340A
DATA: END   OF husr03.

*-------interne Tabelle f?r individuelle Texterfassung------------------
DATA:   BEGIN OF hthead OCCURS 10.
        INCLUDE STRUCTURE thead.
DATA:   END OF hthead.

DATA:   BEGIN OF htlines OCCURS 10.
        INCLUDE STRUCTURE tline.
DATA:   END OF htlines.

DATA:   BEGIN OF hhead OCCURS 10.
        INCLUDE STRUCTURE hheader.
DATA:   END OF hhead.

DATA:   BEGIN OF hltdnam OCCURS 10,
          event LIKE bkorm-event,
          tdnam LIKE thead-tdname,
          spras LIKE thead-tdspras,
        END OF hltdnam.

*-------interne Tabelle f?r Formularanalyse-----------------------------
DATA: BEGIN OF htline OCCURS 10.
        INCLUDE STRUCTURE tline.
DATA: END   OF htline.

DATA: BEGIN OF hitctg OCCURS 10.
        INCLUDE STRUCTURE itctg.
DATA: END   OF hitctg.

DATA: BEGIN OF hitcth OCCURS 10.
        INCLUDE STRUCTURE itcth.
DATA: END   OF hitcth.

DATA: BEGIN OF hitcdp OCCURS 10.
        INCLUDE STRUCTURE itcdp.
DATA: END   OF hitcdp.

DATA: BEGIN OF hitcds OCCURS 10.
        INCLUDE STRUCTURE itcds.
DATA: END   OF hitcds.

DATA: BEGIN OF hitcdq OCCURS 10.
        INCLUDE STRUCTURE itcdq.
DATA: END   OF hitcdq.

DATA: BEGIN OF hitctw OCCURS 10.
        INCLUDE STRUCTURE itctw.
DATA: END   OF hitctw.

*------- interne Tabelle f?r Sortierung---------------------------------
DATA: BEGIN OF sort OCCURS 10,
        sopos1   TYPE c,
        sopos2   TYPE c,
        feld(20) TYPE c,
      END   OF sort.

*------- interne Tabellen f?r dynamische WHERE-Klauseln  ---------------
DATA: BEGIN OF bsi_where OCCURS 10.
        INCLUDE STRUCTURE rsdswhere.
DATA: END OF bsi_where.

DATA: BEGIN OF bsa_where OCCURS 10.
        INCLUDE STRUCTURE rsdswhere.
DATA: END OF bsa_where.

*------- interne Tabelle f?r Protokoll ---------------------------------
DATA: BEGIN OF prot_ausgabe OCCURS 10,
        bukrs      LIKE t001-bukrs,
        event      LIKE t048t-event,
        repid      LIKE syst-repid,
        tdspoolid  TYPE n LENGTH 10,                            "1926253
        tdfaxid    LIKE itcpp-tdfaxid,
        tdteleland LIKE itcpp-tdteleland,
        tdtelenum  LIKE itcpp-tdtelenum,
        tddevice   LIKE itcpp-tddevice,
        tdpreview  LIKE itcpp-tdpreview,
        tddataset  LIKE itcpp-tddataset,
        tdsuffix1  LIKE itcpp-tdsuffix1,
        tdsuffix2  LIKE itcpp-tdsuffix2,
        tdimmed    LIKE itcpp-tdimmed,
        intad      LIKE finaa-intad,
        countp     LIKE countp,
        xkausg     LIKE xkausg,
      END   OF prot_ausgabe.

DATA: BEGIN OF hfimsg OCCURS 10.
        INCLUDE STRUCTURE fimsg.
DATA: END   OF hfimsg.

DATA: BEGIN OF msort_tab OCCURS 10.
        INCLUDE STRUCTURE fimsg.
DATA: END   OF msort_tab.

*------- interne Tabellen f?r Druckwiederholung ------------------------
DATA: BEGIN OF druckw OCCURS 10,
        event LIKE bkorm-event,
        bukrs LIKE bkorm-bukrs,
        koart LIKE bkorm-koart,
        konto LIKE bkorm-konto,
        belnr LIKE bkorm-belnr,
        gjahr LIKE bkorm-gjahr,
        usnam LIKE bkorm-usnam,
        datum LIKE bkorm-datum,
        uzeit LIKE bkorm-uzeit,
      END OF druckw.

*------- interne Tabelle f?r Avise--------------------------------------
DATA: BEGIN OF havico OCCURS 10.
        INCLUDE STRUCTURE avico.
DATA: END   OF havico.

DATA: BEGIN OF havip OCCURS 10.
        INCLUDE STRUCTURE avip.
DATA: END   OF havip.

*------- interne Tabelle Kassenbuch-------------------------------------
DATA: BEGIN OF htcj_positions OCCURS 10.
        INCLUDE STRUCTURE tcj_positions.
DATA: END   OF htcj_positions.

DATA: BEGIN OF htcj_trans_names OCCURS 10.
        INCLUDE STRUCTURE tcj_trans_names.
DATA: END   OF htcj_trans_names.

DATA: BEGIN OF htcj_transactions  OCCURS 10.
        INCLUDE STRUCTURE tcj_transactions.
DATA: END   OF htcj_transactions.

DATA: BEGIN OF htcj_wtax_items  OCCURS 10.
        INCLUDE STRUCTURE tcj_wtax_items.
DATA: END   OF htcj_wtax_items.

*------- interne Tabelle f?r ?bergreifende Vorg?nge---------------------
DATA:   dbukrs LIKE ibkrtab OCCURS 0 WITH HEADER LINE.
DATA:   xbukrs LIKE ibkrtab OCCURS 0 WITH HEADER LINE.
RANGES: ubukrs FOR bkorm-bukrs.
RANGES: lbukrs FOR bkorm-bukrs.
DATA:   xt048a LIKE t048a   OCCURS 0 WITH HEADER LINE.
DATA:   hbvor  LIKE bvor    OCCURS 0 WITH HEADER LINE.

DATA: fieldlist_bsid LIKE ddfldnam OCCURS 0 WITH HEADER LINE.
DATA: fieldlist_bsik LIKE ddfldnam OCCURS 0 WITH HEADER LINE.
DATA: fieldlist_bseg LIKE ddfldnam OCCURS 0 WITH HEADER LINE.
DATA: fieldlist_bset LIKE ddfldnam OCCURS 0 WITH HEADER LINE.
DATA: fieldlist_rf140 LIKE ddfldnam OCCURS 0 WITH HEADER LINE.
DATA: fieldlist_with_item LIKE ddfldnam OCCURS 0 WITH HEADER LINE.
DATA: fieldlist_tcj_p LIKE ddfldnam OCCURS 0 WITH HEADER LINE.
DATA: fieldlist_tcj_d LIKE ddfldnam OCCURS 0 WITH HEADER LINE.
DATA: xdfies         LIKE dfies    OCCURS 0 WITH HEADER LINE.
DATA: xalw_bukrs     TYPE c.
DATA: alw_bukrs      LIKE tcur_bukrs OCCURS 0 WITH HEADER LINE.
DATA: alwlines       TYPE i.
DATA: alwcheck       TYPE c.
DATA: xalw_f140      TYPE c.
DATA: pcccheck       TYPE c.

*------- interne Tabellen f?r die ?bergabe von select-Options-----------
RANGES: hbukrs FOR bkorm-bukrs.
RANGES: sbukrs FOR bkorm-bukrs.
RANGES: hkoart FOR bkorm-koart.
RANGES: hkonto FOR bkorm-konto.
RANGES: hbelnr FOR bkorm-belnr.
RANGES: hgjahr FOR bkorm-gjahr.
RANGES: husnam FOR bkorm-usnam.
RANGES: hdatum FOR bkorm-datum.
RANGES: huzeit FOR bkorm-uzeit.
RANGES: herldt FOR bkorm-erldt.
RANGES: herld2 FOR bkorm-erldt.
RANGES: dempfg FOR bsec-empfg.
RANGES: kempfg FOR bsec-empfg.
RANGES: humska FOR bseg-umskz.
RANGES: humskz FOR bseg-umskz.
RANGES: hbschl FOR bseg-bschl.
RANGES: hcajon FOR tcj_c_journals-cajo_number.

*------- Interne Tabelle f?r BSAD/BSAK Selektion
RANGES: skunnr FOR bsad-kunnr.
RANGES: slifnr FOR bsak-lifnr.

*------- Trigger
DATA:  BEGIN OF delbkorm OCCURS 100.
        INCLUDE STRUCTURE bkorm.
DATA:  END OF delbkorm.

DATA:  BEGIN OF hbkorm OCCURS 100.
        INCLUDE STRUCTURE bkorm.
DATA:  END OF hbkorm.

DATA:  BEGIN OF event_bukrs OCCURS 100,
         event LIKE bkorm-event,
         bukrs LIKE bkorm-bukrs,
         count TYPE i,
       END OF event_bukrs.

*------- Pflegereports
DATA:  BEGIN OF hbkorm_bearb OCCURS 100.
        INCLUDE STRUCTURE bkorm.
        INCLUDE STRUCTURE bearb.
DATA:  END OF hbkorm_bearb.

*-------interne Tabelle Internet----------------------------------------
DATA:   BEGIN OF hotfdata OCCURS 10.
        INCLUDE STRUCTURE itcoo.
DATA:   END   OF hotfdata.

*-SO_OBJECT_SEND
DATA:   BEGIN OF x_object_hd_change.
        INCLUDE STRUCTURE sood1.
DATA:   END OF x_object_hd_change.

DATA:   BEGIN OF x_objcont OCCURS 0.
        INCLUDE STRUCTURE soli.
DATA:   END OF x_objcont.

DATA: BEGIN OF x_objhead OCCURS 1.
        INCLUDE STRUCTURE soli.
DATA: END   OF x_objhead.

DATA:   BEGIN OF x_receivers OCCURS 0.
        INCLUDE STRUCTURE soos1.
DATA:   END OF x_receivers.

DATA:   BEGIN OF lt_solix OCCURS 0.
        INCLUDE STRUCTURE solix.
DATA:   END OF lt_solix.
*-------sending PDF                                             "1636232
DATA:   gb_send         TYPE c,                                 "1636232
        gb_preview      TYPE fppreview,                         "1636232
        gb_archive      TYPE c,                                 "1636232
        gd_sender       TYPE so_rec_ext,                        "1636232
        gd_sender_type  TYPE so_adr_typ,                        "1636232
        gs_outputparams TYPE sfpoutputparams,                   "1636232
        gt_mail_recip   TYPE TABLE OF somlreci1,                "1636232
        gt_fax_recip    TYPE TABLE OF somlreci1.                "1636232
*-----------------------------------------------------------------------
*       Teil 4 : Konstanten
*-----------------------------------------------------------------------
***<<<pdf-enabling
CONSTANTS:

* CORRIDs
co_rfkord_oil   TYPE rfkord_header_corrid VALUE 'OIL',  "open item list
co_rfkord_ast   TYPE rfkord_header_corrid VALUE 'AST',  "account statement
co_rfkord_cst   TYPE rfkord_header_corrid VALUE 'CST',  "customer statement
co_rfkord_mpo   TYPE rfkord_header_corrid VALUE 'MPO',  "noted items
co_rfkord_rec   TYPE rfkord_address_corrid VALUE 'REC',  "receiver address
co_rfkord_raa   TYPE rfkord_address_corrid VALUE 'RAA',  "return address
co_rfkord_fil   TYPE rfkord_address_corrid VALUE 'FIL',  "subsidiary address
co_rfkord_prd   TYPE rfkord_address_corrid VALUE 'PRD',  "pre decade
co_rfkord_dec   TYPE rfkord_address_corrid VALUE 'DEC',  "actual decade
co_rfkord_pod   TYPE rfkord_address_corrid VALUE 'POD',  "post decade

* SUM_IDs
co_rfkord_sda   TYPE rfkord_sumid  VALUE 'SDA',  "balnace carried-forward
co_rfkord_sde   TYPE rfkord_sumid  VALUE 'SDE',  "final balance
co_rfkord_sdm   TYPE rfkord_sumid  VALUE 'SDM',  "balance planed items
co_rfkord_sdf   TYPE rfkord_sumid  VALUE 'SDF',  "balance per due date
co_rfkord_sdzo  TYPE rfkord_sumid  VALUE 'SDZO', "subtotal (open item list)
co_rfkord_sdza  TYPE rfkord_sumid  VALUE 'SDZA', "subtotal (acc. statement)
co_rfkord_sdzm  TYPE rfkord_sumid  VALUE 'SDZM', "subtotal (noted items)
co_rfkord_sdko  TYPE rfkord_sumid  VALUE 'SDKO', "balance per account (oil)
co_rfkord_sdka  TYPE rfkord_sumid  VALUE 'SDKA', "balance per account (ast)
co_rfkord_sdkm  TYPE rfkord_sumid  VALUE 'SDKM'. "bal per acc.(notes items)
***>>>pdf-enabling


DATA: END OF COMMON PART.
*-----------------------------------------------------------------------
*       Teil 5 : Field-Symbols
*-----------------------------------------------------------------------
FIELD-SYMBOLS: <konto1>, <konto2>, <konto3>, <konto4>, <konto5>,
               <konto6>.
FIELD-SYMBOLS: <umskz1>, <umskz2>, <umskz3>, <umskz4>, <umskz5>,
               <umskz6>.

* Note 1633721: field-symbols in internal table loops do not work
* anymore - to be replaced with field name holders
DATA: name_konto1 TYPE string,
      name_konto2 TYPE string,
      name_konto3 TYPE string,
      name_konto4 TYPE string,
      name_konto5 TYPE string,
      name_konto6 TYPE string,
      name_umskz1 TYPE string,
      name_umskz2 TYPE string,
      name_umskz3 TYPE string,
      name_umskz4 TYPE string,
      name_umskz5 TYPE string,
      name_umskz6 TYPE string.

*-----------------------------------------------------------------------
*       Teil 6 : Select-Options und Parameter
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
*       Teil 7 : Field-Groups
*-----------------------------------------------------------------------
FIELD-GROUPS: header, daten, daten2.

INSERT hdbukrs
       sort1
*      SORT2
*      SORT3
       sortk1
       sortk2
       sortk3
       sortk4
       sortk5
       hdkoart
       hdkonto
       hdbelgj                                 "Belegnr und GJahr
       hdkoar2
       hdkont2
       hdempfg
       hdusnam
       hddatum
       hduzeit
       counts     INTO header.

INSERT extract
       dabelnr
       dagjahr
       daerldt
       datum01
       datum02
       paramet
       davsid
       dabbukr
       dacajon
       xbkorm
       bseg     INTO daten.

INSERT bkorm    INTO daten2.

*-----------------------------------------------------------------------
*       Macro's
*-----------------------------------------------------------------------
INCLUDE rfdbrmac.

*-----------------------------------------------------------------------
*       Einzelpostenanzeige/ Ausgleichsvorg?nge
*-----------------------------------------------------------------------
INCLUDE rfeposc1.
DATA: yaccnt  LIKE rf05r_acct OCCURS 0 WITH HEADER LINE.

*-----------------------------------------------------------------------
*       ALV
*-----------------------------------------------------------------------
TYPE-POOLS: slis.

****************start of pdf changes by c5112660***********
DATA : gs_docparams TYPE sfpdocparams,                 " Form Processing Form Parameter
       gs_info TYPE ides_info_pdf,
       gs_info_pdf_t TYPE ides_info_pdf_t,
       gs_address_pdf TYPE t001_pdf,
       gs_dkad2_pdf TYPE dkad2_pdf,
       gs_ides_form_pdf_t TYPE ides_form_pdf_t,
       gs_ides_form_pdf TYPE ides_form_pdf,
       ztotal TYPE total_pdf ,
       ztotal_t TYPE total_pdf_t ,
       display_pdf(1) TYPE c.
*****************end of pdf changes by c5112660*************
*--------------------------------------------------------------------*
* BEGIN OF CVP Enablement declaration
* for report RFKORDES    **C5164187
TYPES: BEGIN OF ty_bukrs_lifnr,
       bukrs TYPE bukrs,
       lifnr TYPE lifnr,
  END OF ty_bukrs_lifnr.

DATA: gt_bukrs_lifnr TYPE TABLE OF ty_bukrs_lifnr,
      gs_bukrs_lifnr TYPE ty_bukrs_lifnr.

DATA: gv_msg_ind.

*     End OF CVP Enablement declaration
