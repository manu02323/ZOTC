***INCLUDE RFKORI90 .

*NCLUDE RFKORI00.
************************************************************************
* INCLUDE    :  ZOTCN0013O_RFKORI90                                    *
* TITLE      :  Copy of Standard Program RFKORI90                      *
* DEVELOPER  :  Vivek Gaur                                             *
* OBJECT TYPE:  Include Progarm                                        *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   OTC_FDD_0013_Monthly Open AR Statement                  *
*----------------------------------------------------------------------*
* DESCRIPTION: This include is copied from standard include RFKORI90   *
*              necessary modifications are made for PDF form generation*
*              and Print or Mail/Fax to customer                       *
*              The changes in the code are tagged with the TR number   *
*              E1DK901190                                              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 15-May-2012 VGAUR    E1DK901190 Initial Development                  *
************************************************************************
*=======================================================================
*       Interne Perform-Routinen
*=======================================================================

*----------------------------------------------------------------------*
* FORM AUFBEREITUNG_BUKRSADRESSE
* Aufbereitung der Buchungskreisadresse je nach Heimatland des Kunde
*----------------------------------------------------------------------*
FORM aufbereitung_bukrsadresse.
  MOVE dkadr-land1         TO raadr-inlnd.
ENDFORM.                    "AUFBEREITUNG_BUKRSADRESSE

*-----------------------------------------------------------------------
*       FORM CALCULATE_TAX_FROM_NET_AMOUNT
*-----------------------------------------------------------------------
FORM calculate_tax_from_net_amount.
  CLEAR   mwdat.
  REFRESH mwdat.
  CLEAR save_fwnav.
  CLEAR save_fwste.
  CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
    EXPORTING
      i_bukrs = save_bukrs
      i_mwskz = save_mwskz
      i_waers = save_waers
      i_wrbtr = save_wrbtr
    IMPORTING
      e_fwnav = save_fwnav
      e_fwste = save_fwste
    TABLES
      t_mwdat = mwdat.
ENDFORM.                    "CALCULATE_TAX_FROM_NET_AMOUNT

*----------------------------------------------------------------------*
* FORM CHECK_DATE
*----------------------------------------------------------------------*
FORM check_date.
  IF sy-datum NE sy-datlo.
    MESSAGE i854 WITH sy-datlo sy-datum.
  ENDIF.
ENDFORM.                    "CHECK_DATE

*----------------------------------------------------------------------*
* FORM CHECK_JURISDICTION
*----------------------------------------------------------------------*
FORM check_jurisdiction.
  CLEAR xactiv.
  CLEAR xexter.
  CALL FUNCTION 'CHECK_JURISDICTION_ACTIVE'
    EXPORTING
*     I_LAND             =
      i_bukrs            = save_bukrs
    IMPORTING
      e_isactive         = xactiv
      e_external         = xexter
    EXCEPTIONS
      input_incomplete   = 1
      input_inconsistent = 2
      OTHERS             = 3.
ENDFORM.                    "CHECK_JURISDICTION

*----------------------------------------------------------------------*
* FORM CHECK_TIME
*----------------------------------------------------------------------*
FORM check_time.
  IF sy-uzeit NE sy-timlo.
    DATA message_type LIKE sy-msgty.
    CALL FUNCTION 'READ_CUSTOMIZED_MESSAGE'
      EXPORTING
        i_arbgb = 'FB'
        i_dtype = 'I'
        i_msgnr = '853'
      IMPORTING
        e_msgty = message_type.
    IF message_type NE '-'.
      MESSAGE i853 WITH sy-timlo sy-uzeit.
    ENDIF.
  ENDIF.
ENDFORM.                    "CHECK_TIME

*----------------------------------------------------------------------*
* FORM DELETE_TEXT
*----------------------------------------------------------------------*
FORM delete_text.
  IF NOT htexterf IS INITIAL.
    LOOP AT hthead.
      CALL FUNCTION 'DELETE_TEXT'
        EXPORTING
          id              = hthead-tdid
          language        = hthead-tdspras
          name            = hthead-tdname
          object          = hthead-tdobject
          savemode_direct = 'X'
        EXCEPTIONS
          not_found       = 04.
      IF sy-subrc NE 0.
        MESSAGE e545 WITH hthead-tdname hthead-tdspras.
      ENDIF.
      COMMIT WORK.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "DELETE_TEXT

*----------------------------------------------------------------------*
* FORM ENDPROTECT
*----------------------------------------------------------------------*
FORM endprotect.
****************start of pdf changes by c5112660***********
  IF save_ftype = ' '.
****************end of pdf changes by c5112660*************
    CALL FUNCTION 'CONTROL_FORM'
      EXPORTING
        command = 'ENDPROTECT'.
****************start of pdf changes by c5112660***********
  ENDIF.
****************end of pdf changes by c5112660*************
ENDFORM.                    "ENDPROTECT

*-----------------------------------------------------------------------
*       FORM FILL_AUGBSCHL
*-----------------------------------------------------------------------
*ORM FILL_AUGBSCHL.
* MOVE 'K'          TO AUGBSCHL-KOART.
* MOVE T041A-BSKSO  TO AUGBSCHL-BSCHL.
* MOVE 'S'          TO AUGBSCHL-SHKZG.
* MOVE 'A'          TO AUGBSCHL-BUART.
* MOVE T041A-AUGLV  TO AUGBSCHL-AUGLV.
* APPEND AUGBSCHL.
* MOVE 'K'          TO AUGBSCHL-KOART.
* MOVE T041A-BSKHA  TO AUGBSCHL-BSCHL.
* MOVE 'H'          TO AUGBSCHL-SHKZG.
* MOVE 'A'          TO AUGBSCHL-BUART.
* MOVE T041A-AUGLV  TO AUGBSCHL-AUGLV.
* APPEND AUGBSCHL.
* MOVE 'K'          TO AUGBSCHL-KOART.
* MOVE T041A-BSKSS  TO AUGBSCHL-BSCHL.
* MOVE 'S'          TO AUGBSCHL-SHKZG.
* MOVE 'S'          TO AUGBSCHL-BUART.
* MOVE T041A-AUGLV  TO AUGBSCHL-AUGLV.
* APPEND AUGBSCHL.
* MOVE 'K'          TO AUGBSCHL-KOART.
* MOVE T041A-BSKHS  TO AUGBSCHL-BSCHL.
* MOVE 'H'          TO AUGBSCHL-SHKZG.
* MOVE 'S'          TO AUGBSCHL-BUART.
* MOVE T041A-AUGLV  TO AUGBSCHL-AUGLV.
* APPEND AUGBSCHL.
* MOVE 'K'          TO AUGBSCHL-KOART.
* MOVE T041A-RPKSO  TO AUGBSCHL-BSCHL.
* MOVE 'S'          TO AUGBSCHL-SHKZG.
* MOVE 'R'          TO AUGBSCHL-BUART.
* MOVE T041A-AUGLV  TO AUGBSCHL-AUGLV.
* APPEND AUGBSCHL.
* MOVE 'K'          TO AUGBSCHL-KOART.
* MOVE T041A-RPKHA  TO AUGBSCHL-BSCHL.
* MOVE 'H'          TO AUGBSCHL-SHKZG.
* MOVE 'R'          TO AUGBSCHL-BUART.
* MOVE T041A-AUGLV  TO AUGBSCHL-AUGLV.
* APPEND AUGBSCHL.
*
* MOVE 'D'          TO AUGBSCHL-KOART.
* MOVE T041A-BSDSO  TO AUGBSCHL-BSCHL.
* MOVE 'S'          TO AUGBSCHL-SHKZG.
* MOVE 'A'          TO AUGBSCHL-BUART.
* MOVE T041A-AUGLV  TO AUGBSCHL-AUGLV.
* APPEND AUGBSCHL.
* MOVE 'D'          TO AUGBSCHL-KOART.
* MOVE T041A-BSDHA  TO AUGBSCHL-BSCHL.
* MOVE 'H'          TO AUGBSCHL-SHKZG.
* MOVE 'A'          TO AUGBSCHL-BUART.
* MOVE T041A-AUGLV  TO AUGBSCHL-AUGLV.
* APPEND AUGBSCHL.
* MOVE 'D'          TO AUGBSCHL-KOART.
* MOVE T041A-BSDSS  TO AUGBSCHL-BSCHL.
* MOVE 'S'          TO AUGBSCHL-SHKZG.
* MOVE 'S'          TO AUGBSCHL-BUART.
* MOVE T041A-AUGLV  TO AUGBSCHL-AUGLV.
* APPEND AUGBSCHL.
* MOVE 'D'          TO AUGBSCHL-KOART.
* MOVE T041A-BSDHS  TO AUGBSCHL-BSCHL.
* MOVE 'H'          TO AUGBSCHL-SHKZG.
* MOVE 'S'          TO AUGBSCHL-BUART.
* MOVE T041A-AUGLV  TO AUGBSCHL-AUGLV.
* APPEND AUGBSCHL.
* MOVE 'D'          TO AUGBSCHL-KOART.
* MOVE T041A-RPDSO  TO AUGBSCHL-BSCHL.
* MOVE 'S'          TO AUGBSCHL-SHKZG.
* MOVE 'R'          TO AUGBSCHL-BUART.
* MOVE T041A-AUGLV  TO AUGBSCHL-AUGLV.
* APPEND AUGBSCHL.
* MOVE 'D'          TO AUGBSCHL-KOART.
* MOVE T041A-RPDHA  TO AUGBSCHL-BSCHL.
* MOVE 'H'          TO AUGBSCHL-SHKZG.
* MOVE 'R'          TO AUGBSCHL-BUART.
* MOVE T041A-AUGLV  TO AUGBSCHL-AUGLV.
* APPEND AUGBSCHL.
*
* MOVE 'S'          TO AUGBSCHL-KOART.
* MOVE T041A-BSSSO  TO AUGBSCHL-BSCHL.
* MOVE 'S'          TO AUGBSCHL-SHKZG.
* MOVE ' '          TO AUGBSCHL-BUART.
* MOVE T041A-AUGLV  TO AUGBSCHL-AUGLV.
* APPEND AUGBSCHL.
* MOVE 'S'          TO AUGBSCHL-KOART.
* MOVE T041A-BSSHA  TO AUGBSCHL-BSCHL.
* MOVE 'H'          TO AUGBSCHL-SHKZG.
* MOVE ' '          TO AUGBSCHL-BUART.
* MOVE T041A-AUGLV  TO AUGBSCHL-AUGLV.
* APPEND AUGBSCHL.
*NDFORM.

*-----------------------------------------------------------------------
*       FORM FILL_ITCFX
*-----------------------------------------------------------------------
FORM fill_itcfx.
  itcfx-rtitle     = dkadr-anred.
  itcfx-rname1     = dkadr-name1.
  itcfx-rname2     = dkadr-name2.
  itcfx-rname3     = dkadr-name3.
  itcfx-rname4     = dkadr-name4.
  itcfx-rpocode    = dkadr-pstlz.
  itcfx-rcity1     = dkadr-ort01.
  itcfx-rcity2     = dkadr-ort02.
  itcfx-rpocode2   = dkadr-pstl2.
  itcfx-rpobox     = dkadr-pfach.
  itcfx-rpoplace   = dkadr-pfort.
  itcfx-rstreet    = dkadr-stras.
  itcfx-rcountry   = dkadr-land1.
  itcfx-rregio     = dkadr-regio.
  itcfx-rlangu     = save_langu.
  itcfx-rhomecntry = dkadr-inlnd.
  itcfx-rlines     = '9'.
  itcfx-rctitle    = space.
  itcfx-rcfname    = space.
  itcfx-rclname    = space.
  itcfx-rcname1    = finaa-namep.
  itcfx-rcname2    = space.
  itcfx-rcdeptm    = finaa-abtei.
  itcfx-rcfaxnr    = finaa-tdtelenum.
  itcfx-stitle     = raadr-anred.
  itcfx-sname1     = raadr-name1.
  itcfx-sname2     = raadr-name2.
  itcfx-sname3     = raadr-name3.
  itcfx-sname4     = raadr-name4.
  itcfx-spocode    = raadr-pstlz.
  itcfx-scity1     = raadr-ort01.
  itcfx-scity2     = raadr-ort02.
  itcfx-spocode2   = raadr-pstl2.
  itcfx-spobox     = raadr-pfach.
  itcfx-spoplace   = raadr-pfort.
  itcfx-sstreet    = raadr-stras.
  itcfx-scountry   = raadr-land1.
  itcfx-sregio     = raadr-regio.
  itcfx-shomecntry = raadr-inlnd.
  itcfx-slines     = '9'.
  itcfx-sctitle    =  fsabe-salut.
  itcfx-scfname    =  fsabe-fname.
  itcfx-sclname    =  fsabe-lname.
  itcfx-scname1    =  fsabe-namp1.
  itcfx-scname2    =  fsabe-namp2.
  itcfx-scdeptm    =  fsabe-abtei.
  itcfx-sccostc    =  fsabe-kostl.
  itcfx-scroomn    =  fsabe-roomn.
  itcfx-scbuild    =  fsabe-build.
  CONCATENATE fsabe-telf1 fsabe-tel_exten1
              INTO itcfx-scphonenr1.
  CONCATENATE fsabe-telf2 fsabe-tel_exten2
              INTO itcfx-scphonenr2 .
  CONCATENATE fsabe-telfx fsabe-fax_extens
              INTO itcfx-scfaxnr.
  itcfx-header     =  t001g-txtko.
  itcfx-footer     =  t001g-txtfu.
  itcfx-signature  =  t001g-txtun.
  itcfx-tdid       =  t001g-ttxid.
  itcfx-tdlangu    =  t001-spras.
  itcfx-subject    =  space.
ENDFORM.                    "FILL_ITCFX

*-----------------------------------------------------------------------
*       FORM FILL_RF140U
*-----------------------------------------------------------------------
FORM fill_rf140u.
  MOVE-CORRESPONDING bkpf TO rf140u.
ENDFORM.                    "FILL_RF140U

*-----------------------------------------------------------------------
*       FORM FILL_RF140V
*-----------------------------------------------------------------------
FORM fill_rf140v USING xcpd.
  IF save_koart = 'D'.
    MOVE-CORRESPONDING kna1 TO rf140v.
    MOVE-CORRESPONDING knb1 TO rf140v.
    IF NOT kna1-xcpdk IS INITIAL.
      IF NOT xcpd IS INITIAL.
        CLEAR rf140v-anred.
        CLEAR rf140v-name1.
        CLEAR rf140v-name2.
        CLEAR rf140v-name3.
        CLEAR rf140v-name4.
        MOVE-CORRESPONDING bsec TO rf140v.
        IF bsec-pstl2 IS INITIAL.
          rf140v-hpstl = bsec-pstlz.
        ELSE.
          rf140v-hpstl = bsec-pstl2.
        ENDIF.
*     ELSE.
*       CLEAR FIMSG.
*       FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
*       FIMSG-MSGTY = 'I'.
*       FIMSG-MSGNO = '812'.
*       FIMSG-MSGV1 = SAVE_KOART.
*       FIMSG-MSGV2 = KNA1-KUNNR.
*       PERFORM MESSAGE_APPEND.
*       XKAUSG = 'X'.
      ENDIF.
    ELSE.
      IF kna1-pstl2 IS INITIAL.
        rf140v-hpstl = kna1-pstlz.
      ELSE.
        rf140v-hpstl = kna1-pstl2.
      ENDIF.
    ENDIF.
    rf140v-belnr = dabelnr.
    rf140v-gjahr = dagjahr.
    rf140v-koart = 'D'.
    rf140v-konto = kna1-kunnr.
    rf140v-ktogr = kna1-ktokd.
    rf140v-ktoze = knb1-knrze.
  ENDIF.
  IF save_koart = 'K'.
    MOVE-CORRESPONDING lfa1 TO rf140v.
    MOVE-CORRESPONDING lfb1 TO rf140v.
    IF NOT lfa1-xcpdk IS INITIAL.
      IF NOT xcpd IS INITIAL.
        CLEAR rf140v-anred.
        CLEAR rf140v-name1.
        CLEAR rf140v-name2.
        CLEAR rf140v-name3.
        CLEAR rf140v-name4.
        MOVE-CORRESPONDING bsec TO rf140v.
        IF bsec-pstl2 IS INITIAL.
          rf140v-hpstl = bsec-pstlz.
        ELSE.
          rf140v-hpstl = bsec-pstl2.
        ENDIF.
*     ELSE.
*       CLEAR FIMSG.
*       FIMSG-MSORT = '    '. FIMSG-MSGID = 'FB'.
*       FIMSG-MSGTY = 'I'.
*       FIMSG-MSGNO = '812'.
*       FIMSG-MSGV1 = SAVE_KOART.
*       FIMSG-MSGV2 = LFA1-LIFNR.
*       PERFORM MESSAGE_APPEND.
*       XKAUSG =  'X'.
      ENDIF.
    ELSE.
      IF lfa1-pstl2 IS INITIAL.
        rf140v-hpstl = lfa1-pstlz.
      ELSE.
        rf140v-hpstl = lfa1-pstl2.
      ENDIF.
    ENDIF.
    rf140v-belnr = dabelnr.
    rf140v-gjahr = dagjahr.
    rf140v-koart = 'K'.
    rf140v-konto = lfa1-lifnr.
    rf140v-ktogr = lfa1-ktokk.
    rf140v-ktoze = lfb1-lnrze.
  ENDIF.
ENDFORM.                    "FILL_RF140V

*-----------------------------------------------------------------------
*       FORM FILL_RF140W
*-----------------------------------------------------------------------
FORM fill_rf140w.
  MOVE-CORRESPONDING bkpf TO rf140w.
  MOVE-CORRESPONDING bseg TO rf140w.
  IF NOT bkpf-xblnr IS INITIAL.
    rf140w-hbeln = bkpf-xblnr.
  ELSE.
    rf140w-hbeln = bkpf-belnr.
  ENDIF.
  IF  bseg-rebzg IS INITIAL
  AND bseg-rebzt IS INITIAL.
    rf140w-rebzg = bseg-belnr.
  ENDIF.
  CASE bseg-koart.
    WHEN 'D'.
      rf140w-konto = bseg-kunnr.
    WHEN 'K'.
      rf140w-konto = bseg-lifnr.
    WHEN OTHERS.
      CLEAR rf140w-konto.
  ENDCASE.
ENDFORM.                    "FILL_RF140W

*-----------------------------------------------------------------------
*       FORM FILL_SKONTO_BSIDK
*-----------------------------------------------------------------------
FORM fill_skonto_bsidk.
  CLEAR sktlit.
  CLEAR rf140-wskta.
  CLEAR rf140-wrshn.
  CLEAR faede.
*-Skonto ermitteln-----------------------------------------------------*
  IF save_koart = 'D'.
    MOVE-CORRESPONDING bsid TO sktlit.
    sktlit-waers = bsid-waers.
    MOVE-CORRESPONDING bsid TO faede.
*   IF NOT BSID-REBZG IS INITIAL.
*     SELECT SINGLE * FROM  BSEG INTO *BSEG
*            WHERE  BUKRS       = BSID-BUKRS
*            AND    BELNR       = BSID-REBZG
*            AND    GJAHR       = BSID-REBZJ
*            AND    BUZEI       = BSID-REBZZ     .
*
*     SKTLIT-ZFBDT =  *BSEG-ZFBDT.
*     SKTLIT-ZBD1T =  *BSEG-ZBD1T.
*     SKTLIT-ZBD1P =  *BSEG-ZBD1P.
*     SKTLIT-ZBD2T =  *BSEG-ZBD2T.
*     SKTLIT-ZBD2P =  *BSEG-ZBD2P.
*     SKTLIT-ZBD3T =  *BSEG-ZBD3T.
*     SKTLIT-ZBFIX =  *BSEG-ZBFIX.
*   ENDIF.
    IF sktlit-zfbdt IS INITIAL.
      sktlit-zfbdt = bsid-bldat.
    ENDIF.
  ELSE.
    MOVE-CORRESPONDING bsik TO sktlit.
    sktlit-waers = bsik-waers.
    MOVE-CORRESPONDING bsik TO faede.
*   IF NOT BSIK-REBZG IS INITIAL.
*     SELECT SINGLE * FROM  BSEG INTO BSEG
*            WHERE  BUKRS       = BSIK-BUKRS
*            AND    BELNR       = BSIK-REBZG
*            AND    GJAHR       = BSIK-REBZJ
*            AND    BUZEI       = BSIK-REBZZ     .
*
*     SKTLIT-ZFBDT =   BSEG-ZFBDT.
*     SKTLIT-ZBD1T =   BSEG-ZBD1T.
*     SKTLIT-ZBD1P =   BSEG-ZBD1P.
*     SKTLIT-ZBD2T =   BSEG-ZBD2T.
*     SKTLIT-ZBD2P =   BSEG-ZBD2P.
*     SKTLIT-ZBD3T =   BSEG-ZBD3T.
*     SKTLIT-ZBFIX =   BSEG-ZBFIX.
*   ENDIF.
    IF sktlit-zfbdt IS INITIAL.
      sktlit-zfbdt = bsik-bldat.
    ENDIF.
  ENDIF.
  faede-koart = save_koart.
*-Skontofristen---------------------------------------------------------

  CALL FUNCTION 'DETERMINE_DUE_DATE'
    EXPORTING
      i_faede = faede
    IMPORTING
      e_faede = faede
    EXCEPTIONS
      OTHERS  = 1.

* SKTLIT-NETDT = SKTLIT-ZFBDT.
* IF NOT SKTLIT-ZBD3T IS INITIAL.
*   REFE3 = SKTLIT-ZBD3T.
* ELSE.
*   IF NOT SKTLIT-ZBD2T IS INITIAL.
*     REFE3 = SKTLIT-ZBD2T.
*   ELSE.
*     REFE3 = SKTLIT-ZBD1T.
*   ENDIF.
* ENDIF.
* SKTLIT-NETDT = SKTLIT-NETDT + REFE3.
  sktlit-netdt = faede-netdt.
  IF NOT sktlit-zbd1t IS INITIAL.
*   SKTLIT-SKTD1 = SKTLIT-ZFBDT + SKTLIT-ZBD1T.
    sktlit-sktd1 = faede-sk1dt.
  ENDIF.
  IF NOT sktlit-zbd2t IS INITIAL.
*   SKTLIT-SKTD2 = SKTLIT-ZFBDT + SKTLIT-ZBD2T.
    sktlit-sktd2 = faede-sk2dt.
  ENDIF.
*-Skontobeträge---------------------------------------------------------
* IF SKTLIT-SKFBT = 0.
*   SKTLIT-SKFBT = SKTLIT-WRBTR.
* ENDIF.
*  check sktlit-skfbt ne 0.                                  "note709164
  IF sktlit-skfbt NE 0.                                     "note709164
    IF NOT sktlit-zbd1t IS INITIAL.
      sktlit-wskt1 = sktlit-skfbt * sktlit-zbd1p / 100000.
    ENDIF.
    IF NOT sktlit-zbd2t IS INITIAL.
      sktlit-wskt2 = sktlit-skfbt * sktlit-zbd2p / 100000.
    ENDIF.
    IF  NOT sktlit-wskto IS INITIAL
    OR  NOT sktlit-xnetb IS INITIAL.
      sktlit-wskt1 = sktlit-wskto.
    ENDIF.
*------- Rappenrundung für die Schweiz ---------------------------------
* IF SKTLIT-WSKTO NE 0.
*   CALL FUNCTION 'ROUND_AMOUNT'
*        EXPORTING COMPANY     = SKTLIT-BUKRS
*                  CURRENCY    = SKTLIT-WAERS
*                  AMOUNT_IN   = SKTLIT-WSKTO
*        IMPORTING AMOUNT_OUT  = SKTLIT-WSKTO.
**                 DIFFERENCE  = REFE
**                 NO_ROUNDING = CHAR(1).
* ENDIF.
    IF sktlit-wskt1 NE 0.
      CALL FUNCTION 'ROUND_AMOUNT'
        EXPORTING
          company    = sktlit-bukrs
          currency   = sktlit-waers
          amount_in  = sktlit-wskt1
        IMPORTING
          amount_out = sktlit-wskt1.
*                  DIFFERENCE  = REFE
*                  NO_ROUNDING = CHAR(1).
    ENDIF.
    IF sktlit-wskt2 NE 0.
      CALL FUNCTION 'ROUND_AMOUNT'
        EXPORTING
          company    = sktlit-bukrs
          currency   = sktlit-waers
          amount_in  = sktlit-wskt2
        IMPORTING
          amount_out = sktlit-wskt2.
*                  DIFFERENCE  = REFE
*                  NO_ROUNDING = CHAR(1).
    ENDIF.
*-aktueller Skonto------------------------------------------------------
    IF NOT sktlit-zbfix IS INITIAL.
      IF sktlit-zbfix = '1'.
        sktlit-wskta = sktlit-wskt1.
      ELSE.
        sktlit-wskta = sktlit-wskt2.
      ENDIF.
    ELSE.
      IF save2_datum LE sktlit-sktd1.
        sktlit-wskta = sktlit-wskt1.
      ELSE.
        IF save2_datum LE sktlit-sktd2.
          sktlit-wskta = sktlit-wskt2.
        ENDIF.
      ENDIF.
    ENDIF.
    IF  save_koart = 'D'
    AND NOT bsid-augbl IS INITIAL.
      sktlit-wskta = sktlit-wskto.
    ENDIF.
    IF  save_koart = 'K'
    AND NOT bsik-augbl IS INITIAL.
      sktlit-wskta = sktlit-wskto.
    ENDIF.
    IF sktlit-shkzg = 'S'.
      rf140-wskta = sktlit-wskta.
    ELSE.
      rf140-wskta = 0 - sktlit-wskta.
    ENDIF.
  ENDIF.                                                    "note709164
  rf140-wrshn = rf140-wrshb - rf140-wskta.
ENDFORM.                    "FILL_SKONTO_BSIDK

*-----------------------------------------------------------------------
*       FORM FILL_WAEHRUNGSFELDER_BSEG
*-----------------------------------------------------------------------
FORM fill_waehrungsfelder_bseg.
  IF bseg-shkzg = 'S'.
    rf140-wrshb = bseg-wrbtr.
    rf140-dmshb = bseg-dmbtr.
    rf140-wsshb = bseg-wskto.
    rf140-skshb = bseg-sknto.
    rf140-wsshv = 0 - bseg-wskto.
    rf140-skshv = 0 - bseg-sknto.
*   RF140-ZLSHB = BSEG-NEBTR.
  ELSE.
    rf140-wrshb = 0 - bseg-wrbtr.
    rf140-dmshb = 0 - bseg-dmbtr.
    rf140-wsshb = 0 - bseg-wskto.
    rf140-skshb = 0 - bseg-sknto.
    rf140-wsshv = bseg-wskto.
    rf140-skshv = bseg-sknto.
*   RF140-ZLSHB = 0 - BSEG-NEBTR.
  ENDIF.
ENDFORM.                    "FILL_WAEHRUNGSFELDER_BSEG

*-----------------------------------------------------------------------
*       FORM FILL_WAEHRUNGSFELDER_RF140
*-----------------------------------------------------------------------
FORM fill_waehrungsfelder_rf140.
  IF hbseg-shkzg = 'H'.
    rf140-wrshb = hbseg-wrbtr.
    rf140-dmshb = hbseg-dmbtr.
    rf140-wsshb = hbseg-wskto .
    rf140-skshb = hbseg-sknto .
    rf140-zlshb = hbseg-nebtr.
  ELSE.
    rf140-wrshb = 0 - hbseg-wrbtr.
    rf140-dmshb = 0 - hbseg-dmbtr.
    rf140-wsshb = 0 - hbseg-wskto.
    rf140-skshb = 0 - hbseg-sknto.
    rf140-zlshb = 0 - hbseg-nebtr.
  ENDIF.
ENDFORM.                    "FILL_WAEHRUNGSFELDER_RF140

*-----------------------------------------------------------------------
*       FORM FILL_WAEHRUNGSFELDER_RF140_2
*-----------------------------------------------------------------------
FORM fill_waehrungsfelder_rf140_2.
  IF hbseg-shkzg = 'S'.
    rf140-wrshb = hbseg-wrbtr.
    rf140-dmshb = hbseg-dmbtr.
    rf140-wsshb = hbseg-wskto .
    rf140-skshb = hbseg-sknto .
    rf140-zlshb = hbseg-nebtr.
  ELSE.
    rf140-wrshb = 0 - hbseg-wrbtr.
    rf140-dmshb = 0 - hbseg-dmbtr.
    rf140-wsshb = 0 - hbseg-wskto.
    rf140-skshb = 0 - hbseg-sknto.
    rf140-zlshb = 0 - hbseg-nebtr.
  ENDIF.
ENDFORM.                    "FILL_WAEHRUNGSFELDER_RF140_2

*-----------------------------------------------------------------------
*       FORM FILL_WAEHRUNGSFELDER_BSIDK
*-----------------------------------------------------------------------
FORM fill_waehrungsfelder_bsidk.
  CLEAR rf140-wrshb.
  CLEAR rf140-dmshb.
  CLEAR rf140-wsshb.
  CLEAR rf140-skshb.
  CLEAR rf140-wsshv.
  CLEAR rf140-skshv.
  CLEAR rf140-zlshb.
  CLEAR rf140-zalbt.
  IF save_koart = 'D'.
    IF bsid-shkzg = 'S'.
      rf140-wrshb = bsid-wrbtr.
      rf140-dmshb = bsid-dmbtr.
      rf140-wsshb = bsid-wskto .
      rf140-skshb = bsid-sknto .
      rf140-wsshv = 0 - bsid-wskto .
      rf140-skshv = 0 - bsid-sknto .
    ELSE.
      rf140-wrshb = 0 - bsid-wrbtr.
      rf140-dmshb = 0 - bsid-dmbtr.
      rf140-wsshb = 0 - bsid-wskto.
      rf140-skshb = 0 - bsid-sknto.
      rf140-wsshv = bsid-wskto.
      rf140-skshv = bsid-sknto.
    ENDIF.
  ELSE.
    IF bsik-shkzg = 'S'.
      rf140-wrshb = bsik-wrbtr.
      rf140-dmshb = bsik-dmbtr.
      rf140-wsshb = bsik-wskto.
      rf140-skshb = bsik-sknto.
      rf140-wsshv = 0 - bsik-wskto.
      rf140-skshv = 0 - bsik-sknto.
    ELSE.
      rf140-wrshb = 0 - bsik-wrbtr.
      rf140-dmshb = 0 - bsik-dmbtr.
      rf140-wsshb = 0 - bsik-wskto.
      rf140-skshb = 0 - bsik-sknto.
      rf140-wsshv = bsik-wskto.
      rf140-skshv = bsik-sknto.
    ENDIF.
  ENDIF.
ENDFORM.                    "FILL_WAEHRUNGSFELDER_BSIDK

*-----------------------------------------------------------------------
*       FORM FILL_WAEHRUNGSFELDER_BSIDK_2.
*-----------------------------------------------------------------------
FORM fill_waehrungsfelder_bsidk_2.
  CLEAR rf140-wrshb.
  CLEAR rf140-dmshb.
* CLEAR RF140-WSSHB.
* CLEAR RF140-SKSHB.
* CLEAR RF140-ZLSHB.
  IF save_koart = 'D'.
    IF hbsid-shkzg = 'S'.
      rf140-wrshb = hbsid-wrbtr.
      rf140-dmshb = hbsid-dmbtr.
*     RF140-WSSHB = HBSID-WSKTO .
*     RF140-SKSHB = HBSID-SKNTO .
    ELSE.
      rf140-wrshb = 0 - hbsid-wrbtr.
      rf140-dmshb = 0 - hbsid-dmbtr.
*     RF140-WSSHB = 0 - HBSID-WSKTO.
*     RF140-SKSHB = 0 - HBSID-SKNTO.
    ENDIF.
  ELSE.
    IF hbsik-shkzg = 'S'.
      rf140-wrshb = hbsik-wrbtr.
      rf140-dmshb = hbsik-dmbtr.
*     RF140-WSSHB = HBSIK-WSKTO .
*     RF140-SKSHB = HBSIK-SKNTO .
    ELSE.
      rf140-wrshb = 0 - hbsik-wrbtr.
      rf140-dmshb = 0 - hbsik-dmbtr.
*     RF140-WSSHB = 0 - HBSIK-WSKTO.
*     RF140-SKSHB = 0 - HBSIK-SKNTO.
    ENDIF.
  ENDIF.
ENDFORM.                    "FILL_WAEHRUNGSFELDER_BSIDK_2

*-----------------------------------------------------------------------
*       FORM FILL_WAEHRUNGSFELDER_BSADK_2
*-----------------------------------------------------------------------
FORM fill_waehrungsfelder_bsadk_2.
  CLEAR rf140-wrshb.
  CLEAR rf140-dmshb.
* CLEAR RF140-WSSHB.
* CLEAR RF140-SKSHB.
* CLEAR RF140-ZLSHB.
  IF save_koart = 'D'.
    IF hbsad-shkzg = 'S'.
      rf140-wrshb = hbsad-wrbtr.
      rf140-dmshb = hbsad-dmbtr.
*     RF140-WSSHB = HBSAD-WSKTO .
*     RF140-SKSHB = HBSAD-SKNTO .
    ELSE.
      rf140-wrshb = 0 - hbsad-wrbtr.
      rf140-dmshb = 0 - hbsad-dmbtr.
*     RF140-WSSHB = 0 - HBSAD-WSKTO.
*     RF140-SKSHB = 0 - HBSAD-SKNTO.
    ENDIF.
  ELSE.
    IF hbsak-shkzg = 'S'.
      rf140-wrshb = hbsak-wrbtr.
      rf140-dmshb = hbsak-dmbtr.
*     RF140-WSSHB = HBSAK-WSKTO .
*     RF140-SKSHB = HBSAK-SKNTO .
    ELSE.
      rf140-wrshb = 0 - hbsak-wrbtr.
      rf140-dmshb = 0 - hbsak-dmbtr.
*     RF140-WSSHB = 0 - HBSAK-WSKTO.
*     RF140-SKSHB = 0 - HBSAK-SKNTO.
    ENDIF.
  ENDIF.
ENDFORM.                    "FILL_WAEHRUNGSFELDER_BSADK_2

*----------------------------------------------------------------------*
* FORM FLAG_KAUTO
*----------------------------------------------------------------------*
* Flag für Massenkorrespondenz setzten
*----------------------------------------------------------------------*
FORM flag_kauto.
  bkorm-param+79(1) = 'X'.
ENDFORM.                    "FLAG_KAUTO

*----------------------------------------------------------------------*
* FORM FORM_CLOSE
*----------------------------------------------------------------------*
FORM form_close.
  CASE finaa-nacha.
    WHEN 'I'.
      PERFORM close_internet.
    WHEN OTHERS.
      IF xopen = 'Y'.
****************start of pdf changes by c5112660***********
        IF save_ftype = ' '.
****************end of pdf changes by c5112660*************
          CALL FUNCTION 'CLOSE_FORM'
            IMPORTING
              result   = itcpp
            EXCEPTIONS
              unopened = 3.
          IF finaa-nacha = 2.
            COMMIT WORK.
          ENDIF.
          IF sy-subrc = 3.
            MESSAGE e403.
          ENDIF.
****************start of pdf changes by c5112660***********
        ENDIF.
****************end of pdf changes by c5112660*************
        IF  NOT itcpp-tddevice  IS INITIAL
        AND ( NOT itcpp-tdspoolid IS INITIAL
        OR NOT itcpp-tdfaxid IS INITIAL ) .
          CLEAR prot_ausgabe.
          prot_ausgabe-bukrs     = save_bukrs.
          prot_ausgabe-event     = save_event.
          prot_ausgabe-repid     = save_repid.
          IF xspid IS INITIAL.
            prot_ausgabe-tdspoolid = itcpp-tdspoolid.
          ENDIF.
          prot_ausgabe-tdfaxid   = itcpp-tdfaxid.
          prot_ausgabe-tddevice  = itcpp-tddevice.
          prot_ausgabe-tdpreview = itcpp-tdpreview.
          prot_ausgabe-tddataset = itcpp-tddataset.
          prot_ausgabe-tdsuffix1 = itcpp-tdsuffix1.
          prot_ausgabe-tdsuffix2 = itcpp-tdsuffix2.
          prot_ausgabe-countp    = itcpp-tdpages.
          prot_ausgabe-tdteleland = itcpp-tdteleland.
          prot_ausgabe-tdtelenum = itcpp-tdtelenum.
          IF finaa-nacha = '1'.
            IF  xpriim IS INITIAL.
              prot_ausgabe-tdimmed = save_rimmd.
              IF save_rimmd IS INITIAL.
                IF print IS INITIAL
                OR ( sy-batch IS INITIAL
                AND save_rxtsub   IS INITIAL ).
                  IF NOT pri_params-primm IS INITIAL.
                    prot_ausgabe-tdimmed = 'X'.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
          COLLECT prot_ausgabe.
        ELSE.
          IF finaa-nacha = '1'.
            LOOP AT prot_ausgabe
              WHERE bukrs      = save_bukrs
              AND   event      = save_event
              AND   repid      = save_repid
              AND   tddevice   = 'PRINTER'.
              EXIT.
            ENDLOOP.
            IF sy-subrc NE 0.
              IF NOT xknid IS INITIAL.
                CLEAR xknid.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
****************start of pdf changes by c5112660***********
        IF save_ftype = ' '.
****************end of pdf changes by c5112660*************
          CALL FUNCTION 'CLOSE_FORM'
            IMPORTING
              result   = itcpp
            EXCEPTIONS
              unopened = 3.
          IF finaa-nacha = 2.
            COMMIT WORK.
          ENDIF.
          IF finaa-nacha = '1'.
            LOOP AT prot_ausgabe
              WHERE bukrs      = save_bukrs
              AND   event      = save_event
              AND   repid      = save_repid
              AND   tddevice   = 'PRINTER'.
              EXIT.
            ENDLOOP.
            IF sy-subrc NE 0.
              IF NOT xknid IS INITIAL.
                CLEAR xknid.
              ENDIF.
            ENDIF.
          ENDIF.
****************start of pdf changes by c5112660***********
        ENDIF.
****************end of pdf changes by c5112660*************

*       IF SY-SUBRC = 3.
*         IF XOPEN = 'X'.
**                     MESSAGE S358.    "keine Ausgabe
*         ELSE.
**                      MESSAGE S359.    "keine Daten selektiert
*         ENDIF.
*       ENDIF.
*       IF  NOT ITCPP-TDDEVICE  IS INITIAL
*       AND NOT ITCPP-TDSPOOLID IS INITIAL.
*         CLEAR PROT_AUSGABE.
*         PROT_AUSGABE-BUKRS     = SAVE_BUKRS.
*         PROT_AUSGABE-EVENT     = SAVE_EVENT.
*         PROT_AUSGABE-REPID     = SAVE_REPID.
*         IF XSPID IS INITIAL.
*           PROT_AUSGABE-TDSPOOLID = ITCPP-TDSPOOLID.
*         ENDIF.
*         PROT_AUSGABE-TDDEVICE  = ITCPP-TDDEVICE.
*         PROT_AUSGABE-TDPREVIEW = ITCPP-TDPREVIEW.
*         PROT_AUSGABE-TDDATASET = ITCPP-TDDATASET.
*         PROT_AUSGABE-TDSUFFIX1 = ITCPP-TDSUFFIX1.
*         PROT_AUSGABE-TDSUFFIX2 = ITCPP-TDSUFFIX2.
*         PROT_AUSGABE-COUNTP    = ITCPP-TDPAGES.
*         COLLECT PROT_AUSGABE.
*       ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    "FORM_CLOSE

*----------------------------------------------------------------------*
* FORM FORM_END
*----------------------------------------------------------------------*
FORM form_end.
****************start of pdf changes by c5112660***********
  IF save_ftype = ' '.
****************end of pdf changes by c5112660*************
    CALL FUNCTION 'END_FORM'
      IMPORTING
        result = itcpp.
*               EXCEPTIONS UNOPENED = 3.

*               IF SY-SUBRC = 3.
*                 PERFORM MESSAGE_UNOPENED.
*               ENDIF.
    countp = countp + itcpp-tdpages.
****************start of pdf changes by c5112660***********
  ENDIF.
****************end of pdf changes by c5112660*************
ENDFORM.                    "FORM_END

*----------------------------------------------------------------------*
* FORM FORM_END_2
* Formularende mit commit work
*----------------------------------------------------------------------*
FORM form_end_2.
****************start of pdf changes by c5112660***********
  IF save_ftype = ' '.
****************end of pdf changes by c5112660*************
    CALL FUNCTION 'END_FORM'
      IMPORTING
        result = itcpp.
*               EXCEPTIONS UNOPENED = 3.
*
*               IF SY-SUBRC = 3.
*                 PERFORM MESSAGE_UNOPENED.
*               ELSE.
    countp = countp + itcpp-tdpages.
****************start of pdf changes by c5112660***********
  ENDIF.
****************end of pdf changes by c5112660*************
  commit_c = commit_c + 1.
  IF commit_c = commit_m.
    COMMIT WORK.
    CLEAR commit_c.
  ENDIF.
*               ENDIF.
ENDFORM.                                                    "FORM_END_2

*----------------------------------------------------------------------*
* FORM FORM_OPEN
*----------------------------------------------------------------------*
FORM form_open.
  IF sy-repid NE 'RFKORDES'.
    CLEAR xopen.
  ENDIF.
* CLEAR XKAUSG.
  CLEAR itcpo.
  CLEAR itcpp.
  CLEAR itcfx.
  CLEAR htddevice.
  CLEAR hdialog.
  CLEAR finaa.
  CLEAR h_archive_index.
  CLEAR h_archive_params.

  PERFORM fill_itcpo.

  PERFORM output_exit_001.

  PERFORM output_openfi.

  IF save_koart NA 'DK'
  OR ( save_koart = 'D' AND NOT kna1-xcpdk IS INITIAL )
  OR ( save_koart = 'K' AND NOT lfa1-xcpdk IS INITIAL ).
    finaa-nacha = '1'.
  ELSE.
    PERFORM output_check.
  ENDIF.

  CASE finaa-nacha.
    WHEN '1'.
      PERFORM printer.
    WHEN '2'.
      PERFORM telefax.
    WHEN 'I'.
      PERFORM internet.
  ENDCASE.

  PERFORM check_printer.
* CLEAR ITCPO-TDIMMED.

  IF xkausg IS INITIAL.
    xopen_executed = 'X'.
    CALL FUNCTION 'OPEN_FORM'
      EXPORTING
        archive_index  = h_archive_index
        archive_params = h_archive_params
        device         = htddevice
        dialog         = hdialog
        form           = '      '
        options        = itcpo
      IMPORTING
        result         = itcpp
      EXCEPTIONS
        form           = 5.
    IF sy-subrc = '5'.
*   Da hier noch kein Formular übergeben wird, muß die Fehlermeldung
*   abgefagen werden. Erst bei Start_Form wird Formular und Seite
*   angegeben.
    ENDIF.
  ENDIF.

  IF xkausg IS INITIAL.
    xopen = 'Y'.
* ELSE.
*   CLEAR XKAUSG.
  ENDIF.
* CLEAR USR01.

  IF  xopen = 'Y'
  AND finaa-nacha = '2'
  AND NOT finaa-formc IS INITIAL.
*   PERFORM FILL_ITCFX.
****************start of pdf changes by c5112660***********
    IF save_ftype = ' '.
****************end of pdf changes by c5112660*************
      CALL FUNCTION 'START_FORM'
        EXPORTING
          archive_index = h_archive_index
          form          = finaa-formc
          language      = save_langu
          startpage     = 'FIRST'
        IMPORTING
          language      = language.
****************start of pdf changes by c5112660***********
    ENDIF.
****************end of pdf changes by c5112660*************
    save_bukrs = hdbukrs.
    CLEAR t001s.
    CLEAR fsabe.
    IF NOT save_busab IS INITIAL.
      CALL FUNCTION 'CORRESPONDENCE_DATA_BUSAB'
        EXPORTING
          i_bukrs         = save_bukrs
          i_busab         = save_busab
          i_langu         = language
        IMPORTING
          e_t001s         = t001s
          e_fsabe         = fsabe
        EXCEPTIONS
          busab_not_found = 01
          OTHERS          = 02.

      IF sy-subrc = 01.
        CLEAR fimsg.
        fimsg-msort = '    '. fimsg-msgid = 'FB'.
        fimsg-msgty = 'I'.
        fimsg-msgno = '598'.
        fimsg-msgv1 = save_bukrs.
        fimsg-msgv2 = save_busab.
        PERFORM message_append.
      ENDIF.
      IF sy-subrc = 02.
        CLEAR fimsg.
        fimsg-msort = '    '. fimsg-msgid = 'FB'.
        fimsg-msgty = 'I'.
        fimsg-msgno = '849'.
        fimsg-msgv1 = save_bukrs.
        fimsg-msgv2 = save_busab.
        PERFORM message_append.
      ENDIF.
    ENDIF.

    PERFORM fill_itcfx.
****************start of pdf changes by c5112660***********
    IF save_ftype = ' '.
****************end of pdf changes by c5112660*************

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          window = 'RECEIVER'.
****************start of pdf changes by c5112660***********
    ENDIF.
    IF save_ftype = ' '.
****************end of pdf changes by c5112660*************
      CALL FUNCTION 'END_FORM'.
****************start of pdf changes by c5112660***********
    ENDIF.
****************end of pdf changes by c5112660*************
  ENDIF.
ENDFORM.                    "FORM_OPEN

*----------------------------------------------------------------------*
* FORM FORM_READ
*----------------------------------------------------------------------*
FORM form_read USING form found.
  CLEAR             oldform.
  CLEAR             htline.
  CLEAR             hitctg.
  CLEAR             hitcth.
  CLEAR             hitcdp.
  CLEAR             hitcds.
  CLEAR             hitcdq.
  CLEAR             hitctw.
  REFRESH           htline.
  REFRESH           hitctg.
  REFRESH           hitcth.
  REFRESH           hitcdp.
  REFRESH           hitcds.
  REFRESH           hitcdq.
  REFRESH           hitctw.

  CALL FUNCTION 'READ_FORM'
    EXPORTING
*     CLIENT          =
      form            = form
*     LANGUAGE        =
*     OLANGUAGE       =
*     OSTATUS         =
*     STATUS          =
*     THROUGHCLIENT   =
*     THROUGHLANGUAGE =
    IMPORTING
*     FORM_HEADER     =
      found           = found
*     HEADER          =
*     OLANGUAGE       =
    TABLES
      form_lines      = htline
      pages           = hitctg
      page_windows    = hitcth
      paragraphs      = hitcdp
      strings         = hitcds
      tabs            = hitcdq
      windows         = hitctw.
ENDFORM.                    "FORM_READ

*----------------------------------------------------------------------*
* FORM FORM_START
*----------------------------------------------------------------------*
FORM form_start USING form language startpage.

  CALL FUNCTION 'START_FORM'
    EXPORTING
      archive_index    = h_archive_index
      form             = form
      language         = language
      startpage        = startpage
*     PROGRAM          = ' '
*     MAIL_APPL_OBJECT = ' '
    IMPORTING
      language         = language
    EXCEPTIONS
      form             = 5.
* IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
* ENDIF.

ENDFORM.                    "FORM_START


*----------------------------------------------------------------------*
* FORM PAYMED_PRINT_OPENCLOSE
*----------------------------------------------------------------------*
FORM paymed_print_openclose.
  IF  NOT save_rzlsch IS INITIAL
  AND     xkausgzt    IS INITIAL.
    REFRESH hfimsg.
    CLEAR   hfimsg.
    CALL FUNCTION 'PAYMENT_MEDIUM_PRINT'
         EXPORTING
              i_paymo    = paymo
              i_itcpo    = itcpo
*             I_DEVICE   = 'PRINTER'
*             I_DIALOG   = ' '
              i_language = language
              i_xopen    = 'X'
              i_archive_index  = h_archive_index
              i_archive_params = h_archive_params
*        IMPORTING
*             E_LANGUAGE =
         TABLES
              t_fimsg = hfimsg
         EXCEPTIONS
              OTHERS     = 0.
    LOOP AT hfimsg.
      CALL FUNCTION 'FI_MESSAGE_COLLECT'
        EXPORTING
          i_fimsg       = hfimsg
*         I_XAPPN       = ' '
        EXCEPTIONS
*         MSGID_MISSING = 1
*         MSGNO_MISSING = 2
*         MSGTY_MISSING = 3
          OTHERS        = 4.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "PAYMED_PRINT_OPENCLOSE

*----------------------------------------------------------------------*
* FORM PROTECT
*----------------------------------------------------------------------*
FORM protect.
****************start of pdf changes by c5112660***********
  IF save_ftype = ' '.
****************end of pdf changes by c5112660*************
    CALL FUNCTION 'CONTROL_FORM'
      EXPORTING
        command = 'PROTECT'.
****************start of pdf changes by c5112660***********
  ENDIF.
*******************end of pdf changes by c5112660***********

* FLPROTECT = 'X'.
ENDFORM.                    "PROTECT

*-----------------------------------------------------------------------
*       FORM PRUEFEN_HBKPF
*-----------------------------------------------------------------------
FORM pruefen_hbkpf.
  CLEAR xvorh.
  CLEAR sy-subrc.
  LOOP AT hbkpf
    WHERE bukrs = save_bukrs
    AND   belnr = save_belnr
    AND   gjahr = save_gjahr.
    MOVE-CORRESPONDING hbkpf TO bkpf.
    EXIT.
  ENDLOOP.
  IF sy-subrc =  0.
    xvorh = 'X'.
  ENDIF.
ENDFORM.                    "PRUEFEN_HBKPF

*-----------------------------------------------------------------------
*       FORM PRUEFEN_HBSEC
*-----------------------------------------------------------------------
FORM pruefen_hbsec.
  CLEAR xvorh.
  CLEAR sy-subrc.
  LOOP AT hbsec
    WHERE bukrs = save_bukrs
    AND   belnr = save_belnr
    AND   gjahr = save_gjahr
    AND   buzei = save_buzei.
    MOVE-CORRESPONDING hbsec TO bsec.
    EXIT.
  ENDLOOP.
  IF sy-subrc =  0.
    xvorh = 'X'.
  ENDIF.
ENDFORM.                    "PRUEFEN_HBSEC

*-----------------------------------------------------------------------
*       FORM PRUEFEN_HKNA1
*-----------------------------------------------------------------------
FORM pruefen_hkna1.
  CLEAR xvorh.
  CLEAR sy-subrc.
  LOOP AT hkna1
    WHERE kunnr = save_kunnr.
    MOVE-CORRESPONDING hkna1 TO kna1.
    EXIT.
  ENDLOOP.
  IF sy-subrc =  0.
    xvorh = 'X'.
  ENDIF.
ENDFORM.                    "PRUEFEN_HKNA1

*-----------------------------------------------------------------------
*       FORM PRUEFEN_HLFA1
*-----------------------------------------------------------------------
FORM pruefen_hlfa1.
  CLEAR xvorh.
  CLEAR sy-subrc.
  LOOP AT hlfa1
    WHERE lifnr = save_lifnr.
    MOVE-CORRESPONDING hlfa1 TO lfa1.
    EXIT.
  ENDLOOP.
  IF sy-subrc =  0.
    xvorh = 'X'.
  ENDIF.
ENDFORM.                    "PRUEFEN_HLFA1

*-----------------------------------------------------------------------
*       FORM PRUEFEN_HKNB1
*-----------------------------------------------------------------------
FORM pruefen_hknb1.
  CLEAR xvorh.
  CLEAR sy-subrc.
  LOOP AT hknb1
    WHERE kunnr = save_kunnr
    AND   bukrs = save_bukrs.
    MOVE-CORRESPONDING hknb1 TO knb1.
    EXIT.
  ENDLOOP.
  IF sy-subrc =  0.
    xvorh = 'X'.
  ENDIF.
ENDFORM.                    "PRUEFEN_HKNB1

*-----------------------------------------------------------------------
*       FORM PRUEFEN_HLFB1
*-----------------------------------------------------------------------
FORM pruefen_hlfb1.
  CLEAR xvorh.
  CLEAR sy-subrc.
  LOOP AT hlfb1
    WHERE lifnr = save_lifnr
    AND   bukrs = save_bukrs.
    MOVE-CORRESPONDING hlfb1 TO lfb1.
    EXIT.
  ENDLOOP.
  IF sy-subrc =  0.
    xvorh = 'X'.
  ENDIF.
ENDFORM.                    "PRUEFEN_HLFB1

*-----------------------------------------------------------------------
*       FORM PRUEFEN_HSKAT
*-----------------------------------------------------------------------
FORM pruefen_hskat.
  CLEAR xvorh.
  CLEAR sy-subrc.
  LOOP AT hskat
    WHERE saknr = save_saknr.
    MOVE-CORRESPONDING hskat TO skat.
    EXIT.
  ENDLOOP.
  IF sy-subrc =  0.
    xvorh = 'X'.
  ENDIF.
ENDFORM.                    "PRUEFEN_HSKAT

*-----------------------------------------------------------------------
*       FORM PRUEFEN_HTINSO
*-----------------------------------------------------------------------
FORM pruefen_htinso.
  CLEAR xvorh.
  CLEAR sy-subrc.
  LOOP AT htinso
    WHERE repid = save2_repid
    AND   bukrs = save_bukrs
    AND   belnr = save_belnr
    AND   gjahr = save_gjahr
    AND   idpos = save_idpos.
    tinso = htinso.
    EXIT.
  ENDLOOP.
  IF sy-subrc = 0.
    xvorh = 'X'.
  ENDIF.
ENDFORM.                    "PRUEFEN_HTINSO

*-----------------------------------------------------------------------
*       FORM PRUEFEN_HUSR03
*-----------------------------------------------------------------------
FORM pruefen_husr03.
  CLEAR xvorh2.
  CLEAR sy-subrc.
  CLEAR usr03.                                              "USR0340A
  LOOP AT husr03
    WHERE bname = save_usnam.
    MOVE-CORRESPONDING husr03 TO usr03.                     "USR0340A
    EXIT.
  ENDLOOP.
  IF sy-subrc =  0.
    xvorh2 = 'X'.
  ENDIF.
ENDFORM.                    "PRUEFEN_HUSR03

*-----------------------------------------------------------------------
*       FORM PRUEFEN_HUSR03_2
*-----------------------------------------------------------------------
FORM pruefen_husr03_2.
  CLEAR xvorh2.
  CLEAR sy-subrc.
  CLEAR *usr03.                                             "USR0340A
  LOOP AT husr03
    WHERE bname = save_usnam.
    MOVE-CORRESPONDING husr03 TO *usr03.                    "USR0340A
    EXIT.
  ENDLOOP.
  IF sy-subrc =  0.
    xvorh2 = 'X'.
  ENDIF.
ENDFORM.                    "PRUEFEN_HUSR03_2

*----------------------------------------------------------------------*
* FORM SAVE_BUKRS_ADRESSE
* Sicherung der Buchungskreisadresse für spätere Ausgabe
* je nach Heimatland des Kunden
*----------------------------------------------------------------------*
FORM save_bukrs_adresse.
  CLEAR raadr.
  MOVE-CORRESPONDING sadr TO raadr.
  raadr-adrnr = t001-adrnr.
ENDFORM.                    "SAVE_BUKRS_ADRESSE

*-----------------------------------------------------------------------
*       FORM SAVE_BSEC
*-----------------------------------------------------------------------
FORM save_bsec.
  MOVE-CORRESPONDING bsec TO hbsec.
  APPEND hbsec.
ENDFORM.                    "SAVE_BSEC

*-----------------------------------------------------------------------
*       FORM SAVE_KNA1
*-----------------------------------------------------------------------
FORM save_kna1.
  MOVE-CORRESPONDING kna1 TO hkna1.
  APPEND hkna1.
ENDFORM.                                                    "SAVE_KNA1

*-----------------------------------------------------------------------
*       FORM SAVE_LFA1
*-----------------------------------------------------------------------
FORM save_lfa1.
  MOVE-CORRESPONDING lfa1 TO hlfa1.
  APPEND hlfa1.
ENDFORM.                                                    "SAVE_LFA1

*-----------------------------------------------------------------------
*       FORM SAVE_KNb1
*-----------------------------------------------------------------------
FORM save_knb1.
  MOVE-CORRESPONDING knb1 TO hknb1.
  APPEND hknb1.
ENDFORM.                                                    "SAVE_KNB1

*-----------------------------------------------------------------------
*       FORM SAVE_LFb1
*-----------------------------------------------------------------------
FORM save_lfb1.
  MOVE-CORRESPONDING lfb1 TO hlfb1.
  APPEND hlfb1.
ENDFORM.                                                    "SAVE_LFB1

*-----------------------------------------------------------------------
*       FORM SET_WAEHRUNGSFELDER_BSAD
*-----------------------------------------------------------------------
FORM set_waehrungsfelder_bsad.
  IF hbsad-shkzg = 'H'.
    hbsad-wrbtr = 0 - hbsad-wrbtr.
    hbsad-dmbtr = 0 - hbsad-dmbtr.
    hbsad-wskto = 0 - hbsad-wskto.
    hbsad-sknto = 0 - hbsad-sknto.
  ENDIF.
ENDFORM.                    "SET_WAEHRUNGSFELDER_BSAD

*-----------------------------------------------------------------------
*       FORM SET_WAEHRUNGSFELDER_BSAK
*-----------------------------------------------------------------------
FORM set_waehrungsfelder_bsak.
  IF hbsak-shkzg = 'H'.
    hbsak-wrbtr = 0 - hbsak-wrbtr.
    hbsak-dmbtr = 0 - hbsak-dmbtr.
    hbsak-wskto = 0 - hbsak-wskto.
    hbsak-sknto = 0 - hbsak-sknto.
  ENDIF.
ENDFORM.                    "SET_WAEHRUNGSFELDER_BSAK

*-----------------------------------------------------------------------
*       FORM SET_WAEHRUNGSFELDER_BSEG
*-----------------------------------------------------------------------
FORM set_waehrungsfelder_bseg.
  IF hbseg-shkzg = 'H'.
    hbseg-wrbtr = 0 - hbseg-wrbtr.
    hbseg-dmbtr = 0 - hbseg-dmbtr.
    hbseg-wskto = 0 - hbseg-wskto.
    hbseg-sknto = 0 - hbseg-sknto.
  ENDIF.
ENDFORM.                    "SET_WAEHRUNGSFELDER_BSEG

*----------------------------------------------------------------------*
* FORM SORT_FELDER
*----------------------------------------------------------------------*
* Parameter SATZ bestimmt ob Korrespondenz- oder Postensortierung
*                            (K oder P)
* Parameter ART  bestimmt ob bei Korrespondenzsortierung Konten oder
*                            Belegdaten (K oder B)
*                bestimmt ob bei Postensortierung den Zähler (1 oder 2)
*----------------------------------------------------------------------*
FORM sort_felder USING satz art.
  CASE satz.
    WHEN 'K'.
      CASE art.
        WHEN 'K'.
          IF NOT save_sortvk IS INITIAL.
            SELECT SINGLE * FROM t021m
              WHERE progn = 'RFKORD* '
              AND   anwnd = 'KORK'
              AND   srvar = save_sortvk.
            hlp_t021m_k = t021m.
            IF sy-subrc NE 0.
              MESSAGE e832 WITH save_sortvk.
            ENDIF.
*         ELSE.
**          message
          ENDIF.
        WHEN 'B'.
          IF NOT save_sortvk IS INITIAL.
            SELECT SINGLE * FROM t021m
              WHERE progn = 'RFKORD* '
              AND   anwnd = 'KORB'
              AND   srvar = save_sortvk.
            hlp_t021m_k = t021m.
            IF sy-subrc NE 0.
              MESSAGE e832 WITH save_sortvk.
            ENDIF.
*         ELSE.
**          message
          ENDIF.
      ENDCASE.
    WHEN 'P'.
      CASE art.
        WHEN '1'.
          IF NOT save_sortvp IS INITIAL.
            SELECT SINGLE * FROM t021m
              WHERE progn = 'RFKORD* '
              AND   anwnd = 'KORP'
              AND   srvar = save_sortvp.
            hlp_t021m_p = t021m.
            IF sy-subrc NE 0.
              MESSAGE e833 WITH save_sortvp.
            ENDIF.
*         ELSE.
**          message
          ENDIF.
        WHEN '2'.
          IF NOT save_sortvp2 IS INITIAL.
            SELECT SINGLE * FROM t021m
              WHERE progn  = 'RFKORD* '
              AND   anwnd  = 'KORP'
              AND   srvar  = save_sortvp2.
            hlp_t021m_p2 = t021m.
            IF sy-subrc NE 0.
              MESSAGE e833 WITH save_sortvp2.
            ENDIF.
*         ELSE.
**          message
          ENDIF.
      ENDCASE.
  ENDCASE.
ENDFORM.                    "SORT_FELDER

*----------------------------------------------------------------------*
* FORM SORTIERUNG
*----------------------------------------------------------------------*
* Parameter SATZ bestimmt ob Korrespondenz- oder Postensortierung
*                            (K oder P)
* Parameter ART  bestimmt ob bei Korrespondenzsortierung Konten oder
*                            Belegdaten (K oder B)
*                bestimmt ob bei Postensortierung den Zähler (1 oder 2)
* Parameter XCPD bestimmt ob bei Korrespondenzsortierung CPD-Konten
*                            zulässig (' ' oder X)
*----------------------------------------------------------------------*
FORM sortierung USING satz art xcpd.
  CLEAR sortk1.
  CLEAR sortk2.
  CLEAR sortk3.
  CLEAR sortk4.
  CLEAR sortk5.
  CLEAR sortp1.
  CLEAR sortp2.
  CLEAR sortp3.
  CLEAR sortp4.
  CLEAR sortp5.
  CLEAR rf140u.
  CLEAR rf140v.
  CLEAR rf140w.

  CASE satz.
    WHEN 'K'.
      IF NOT save_sortvk IS INITIAL.
        CASE art.
          WHEN 'K'.
            PERFORM fill_rf140v USING xcpd.
          WHEN 'B'.
            PERFORM fill_rf140u.
        ENDCASE.
        t021m = hlp_t021m_k.
        DO 5 TIMES.
          CASE sy-index.
            WHEN 1.
              PERFORM sortierung_assign USING t021m-tnam1
                t021m-feld1 t021m-offs1 t021m-leng1 sortk1.
            WHEN 2.
              PERFORM sortierung_assign USING t021m-tnam2
                t021m-feld2 t021m-offs2 t021m-leng2 sortk2.
            WHEN 3.
              PERFORM sortierung_assign USING t021m-tnam3
                t021m-feld3 t021m-offs3 t021m-leng3 sortk3.
            WHEN 4.
              PERFORM sortierung_assign USING t021m-tnam4
                t021m-feld4 t021m-offs4 t021m-leng4 sortk4.
            WHEN 5.
              PERFORM sortierung_assign USING t021m-tnam5
                t021m-feld5 t021m-offs5 t021m-leng5 sortk5.
          ENDCASE.
        ENDDO.
      ENDIF.
    WHEN 'P'.
      IF  NOT save_sortvp  IS INITIAL
      AND art = '1'.
        PERFORM fill_rf140w.
        t021m = hlp_t021m_p.
        DO 5 TIMES.
          CASE sy-index.
            WHEN 1.
              PERFORM sortierung_assign USING t021m-tnam1
                t021m-feld1 t021m-offs1 t021m-leng1 sortp1.
            WHEN 2.
              PERFORM sortierung_assign USING t021m-tnam2
                t021m-feld2 t021m-offs2 t021m-leng2 sortp2.
            WHEN 3.
              PERFORM sortierung_assign USING t021m-tnam3
                t021m-feld3 t021m-offs3 t021m-leng3 sortp3.
            WHEN 4.
              PERFORM sortierung_assign USING t021m-tnam4
                t021m-feld4 t021m-offs4 t021m-leng4 sortp4.
            WHEN 5.
              PERFORM sortierung_assign USING t021m-tnam5
                t021m-feld5 t021m-offs5 t021m-leng5 sortp5.
          ENDCASE.
        ENDDO.
      ENDIF.
      IF  NOT save_sortvp2 IS INITIAL
      AND art = '2'.
        PERFORM fill_rf140w.
        t021m = hlp_t021m_p2.
        DO 5 TIMES.
          CASE sy-index.
            WHEN 1.
              PERFORM sortierung_assign USING t021m-tnam1
                t021m-feld1 t021m-offs1 t021m-leng1 sortp1.
            WHEN 2.
              PERFORM sortierung_assign USING t021m-tnam2
                t021m-feld2 t021m-offs2 t021m-leng2 sortp2.
            WHEN 3.
              PERFORM sortierung_assign USING t021m-tnam3
                t021m-feld3 t021m-offs3 t021m-leng3 sortp3.
            WHEN 4.
              PERFORM sortierung_assign USING t021m-tnam4
                t021m-feld4 t021m-offs4 t021m-leng4 sortp4.
            WHEN 5.
              PERFORM sortierung_assign USING t021m-tnam5
                t021m-feld5 t021m-offs5 t021m-leng5 sortp5.
          ENDCASE.
        ENDDO.
      ENDIF.
  ENDCASE.
ENDFORM.                    "SORTIERUNG

*----------------------------------------------------------------------*
* FORM SORTIERUNG_ASSIGN
*----------------------------------------------------------------------*
FORM sortierung_assign USING tnam feld offs leng sort.

  FIELD-SYMBOLS <feld>.                "Inhalt des Sortierfeldes
  DATA up_feld(21) TYPE c.             "Name des Sortierfeldes aus T021M
  DATA l_describe TYPE REF TO cl_abap_typedescr.

  up_feld    = tnam.
  up_feld+10 = '-'.
  up_feld+11 = feld.                   "XBLNR etc.
  CONDENSE up_feld NO-GAPS.
  ASSIGN TABLE FIELD (up_feld) TO <feld>.
  CLEAR sort.                          "Sortierfeld nur füllen, wenn
  l_describe = cl_abap_typedescr=>describe_by_data( <feld> ).
  IF NOT l_describe->type_kind EQ 'P'.
    CHECK leng NE 0.                     "T021M-Eintrag nicht leer ist
    ASSIGN <feld>+offs(leng) TO <feld>.
  ENDIF.
  sort = <feld>.

ENDFORM.                    "SORTIERUNG_ASSIGN


*----------------------------------------------------------------------*
* FORM FORM_TABLE_SHIFT
*----------------------------------------------------------------------*
FORM table_shift.
*-Itab 134 Zeichen nach 255 zeichen überführen------------------------*
  DESCRIBE TABLE htline    LINES  hltlines.
  DESCRIBE FIELD htline    LENGTH fle1 IN CHARACTER MODE.
  DESCRIBE FIELD x_objcont LENGTH fle2 IN CHARACTER MODE.
  CLEAR   x_objcont.
  REFRESH x_objcont.
  CLEAR off1.
  CLEAR hfeld.
  LOOP AT htline.
    htabix = sy-tabix.
    MOVE htline TO hfeld+off1.
    IF htabix = hltlines.
      fle1 = strlen( htline ).
    ENDIF.
    off1 = off1 + fle1.
    IF off1 GE fle2.
      CLEAR x_objcont.
      x_objcont = hfeld(fle2).
      APPEND x_objcont.
      SHIFT hfeld BY fle2 PLACES.
      off1 = off1 - fle2.
    ENDIF.

    IF htabix = hltlines.
      IF off1 GT 0.
        CLEAR x_objcont.
        x_objcont = hfeld(off1).
        APPEND x_objcont.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "TABLE_SHIFT

*-----------------------------------------------------------------------
*       FORM UPDATA_BKORM
*-----------------------------------------------------------------------
FORM updata_bkorm.

  SELECT SINGLE * FROM bkorm
    WHERE event = save_event
    AND   bukrs = hdbukrs
    AND   koart = hdkoart
    AND   konto = hdkonto
    AND   belnr = dabelnr
    AND   gjahr = dagjahr
    AND   usnam = hdusnam
    AND   datum = hddatum
    AND   uzeit = hduzeit.
  IF bkorm-erldt NE sy-datum.
*       UPDATE BKORM SET ERLDT = SY-DATUM
*         WHERE EVENT = SAVE_EVENT
*         AND   BUKRS = HDBUKRS
*         AND   KOART = HDKOART
*         AND   KONTO = HDKONTO
*         AND   BELNR = DABELNR
*         AND   GJAHR = DAGJAHR
*         AND   USNAM = HDUSNAM
*         AND   DATUM = HDDATUM
*         AND   UZEIT = HDUZEIT.
    bkorm-erldt = sy-datum.
  ENDIF.
  IF NOT xprint IS INITIAL.
    IF xerdt IS INITIAL.
      IF bkorm-param+33(2) = '  '.
        bkorm-param+33(2) = '01'.
        bkorm-param+35(3) = '000'.
      ENDIF.
      CLEAR anzdru.
      IF anzdr2 IS INITIAL.
        anzdru = bkorm-param+35(3).
        anzdru = anzdru + 1.
      ELSE.
        anzdru = anzdr2.
      ENDIF.
      bkorm-param+35(3) = anzdru.
    ELSE.
      LOOP AT druckw
        WHERE event =  bkorm-event
        AND   bukrs =  bkorm-bukrs
        AND   koart =  bkorm-koart
        AND   konto =  bkorm-konto
        AND   belnr =  bkorm-belnr
        AND   gjahr =  bkorm-gjahr
        AND   usnam =  bkorm-usnam
        AND   datum =  bkorm-datum
        AND   uzeit =  bkorm-uzeit.
        EXIT.
      ENDLOOP.
      IF sy-subrc NE 0.
        IF bkorm-param+33(2) = '  '.
          bkorm-param+33(2) = '00'.
        ENDIF.
        anzwie = bkorm-param+33(2).
        anzwie = anzwie + 1.
        bkorm-param+33(2) = anzwie.
        bkorm-param+35(3) = '000'.
        MOVE-CORRESPONDING bkorm TO druckw.
        APPEND druckw.
      ENDIF.
      CLEAR anzdru.
      IF anzdr2 IS INITIAL.
        anzdru = bkorm-param+35(3).
        anzdru = anzdru + 1.
      ELSE.
        anzdru = anzdr2.
      ENDIF.
      bkorm-param+35(3) = anzdru.
    ENDIF.
  ENDIF.
  bkorm-avsid = rf140-avsid.
  UPDATE bkorm.
  IF sy-subrc NE 0.
    CLEAR hbkormkey.
    CLEAR herdata.
    hbkormkey-bukrs = bkorm-bukrs.
    hbkormkey-koart = bkorm-koart.
    hbkormkey-konto = bkorm-konto.
    hbkormkey-belnr = bkorm-belnr.
    hbkormkey-gjahr = bkorm-gjahr.
    CONDENSE hbkormkey.
    herdata-usnam = bkorm-usnam.
    herdata-datum = bkorm-datum.
    herdata-uzeit = bkorm-uzeit.
    MESSAGE e546 WITH 'BKORM' bkorm-event hbkormkey herdata.
  ENDIF.
  IF NOT xnach IS INITIAL.
    CLEAR hbkormkey.
    CLEAR herdata.
    CLEAR hkokon.
    hbkormkey-bukrs = bkorm-bukrs.
    hbkormkey-koart = bkorm-koart.
    hbkormkey-konto = bkorm-konto.
    hbkormkey-belnr = bkorm-belnr.
    hbkormkey-gjahr = bkorm-gjahr.
    CONDENSE hbkormkey.
    herdata-usnam = bkorm-usnam.
    herdata-datum = bkorm-datum.
    herdata-uzeit = bkorm-uzeit.
    IF NOT hdkoar2 IS INITIAL
    OR NOT hdkont2 IS INITIAL.
      hkokon-koart = hdkoar2.
      hkokon-konto = hdkont2.
    ENDIF.
    IF xkausg IS INITIAL.
      IF NOT hdkoar2 IS INITIAL
      OR NOT hdkont2 IS INITIAL.
        CLEAR fimsg.
        fimsg-msort = '    '. fimsg-msgid = 'FB'.
        fimsg-msgty = 'I'.
        fimsg-msgno = '826'.
        fimsg-msgv1 = bkorm-event.
        fimsg-msgv2 = hbkormkey.
        fimsg-msgv3 = herdata.
        fimsg-msgv4 = hkokon.
        PERFORM message_append.
      ELSE.
        CLEAR fimsg.
        fimsg-msort = '    '. fimsg-msgid = 'FB'.
        fimsg-msgty = 'I'.
        fimsg-msgno = '828'.
        fimsg-msgv1 = bkorm-event.
        fimsg-msgv2 = hbkormkey.
        fimsg-msgv3 = herdata.
        PERFORM message_append.
      ENDIF.
    ELSE.
      IF NOT hdkoar2 IS INITIAL
      OR NOT hdkont2 IS INITIAL.
        CLEAR fimsg.
        fimsg-msort = '    '. fimsg-msgid = 'FB'.
        fimsg-msgty = 'I'.
        fimsg-msgno = '827'.
        fimsg-msgv1 = bkorm-event.
        fimsg-msgv2 = hbkormkey.
        fimsg-msgv3 = herdata.
        fimsg-msgv4 = hkokon.
        PERFORM message_append.
      ELSE.
        CLEAR fimsg.
        fimsg-msort = '    '. fimsg-msgid = 'FB'.
        fimsg-msgty = 'I'.
        fimsg-msgno = '548'.
        fimsg-msgv1 = bkorm-event.
        fimsg-msgv2 = hbkormkey.
        fimsg-msgv3 = herdata.
        PERFORM message_append.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "UPDATA_BKORM

*-----------------------------------------------------------------------
*       FORM UPDATA_BKORM_2
*-----------------------------------------------------------------------
FORM updata_bkorm_2.
  CLEAR hbkorm.
  LOOP AT hbkorm.
    SELECT SINGLE * FROM bkorm
      WHERE event = hbkorm-event
      AND   bukrs = hbkorm-bukrs
      AND   koart = hbkorm-koart
      AND   konto = hbkorm-konto
      AND   belnr = hbkorm-belnr
      AND   gjahr = hbkorm-gjahr
      AND   usnam = hbkorm-usnam
      AND   datum = hbkorm-datum
      AND   uzeit = hbkorm-uzeit.
    IF sy-subrc = 0.
      bkorm = hbkorm.
      UPDATE bkorm.
      IF sy-subrc NE 0.
        CLEAR hbkormkey.
        CLEAR herdata.
        hbkormkey-bukrs = bkorm-bukrs.
        hbkormkey-koart = bkorm-koart.
        hbkormkey-konto = bkorm-konto.
        hbkormkey-belnr = bkorm-belnr.
        hbkormkey-gjahr = bkorm-gjahr.
        CONDENSE hbkormkey.
        herdata-usnam = bkorm-usnam.
        herdata-datum = bkorm-datum.
        herdata-uzeit = bkorm-uzeit.
        MESSAGE e546 WITH 'BKORM' bkorm-event hbkormkey herdata.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "UPDATA_BKORM_2

*-----------------------------------------------------------------------
*       FORM UPDATA_BKORM_STORE
*-----------------------------------------------------------------------
FORM updata_bkorm_store.

  CLEAR save_tabix.
  SELECT SINGLE * FROM bkorm
    WHERE event = save_event
    AND   bukrs = hdbukrs
    AND   koart = hdkoart
    AND   konto = hdkonto
    AND   belnr = dabelnr
    AND   gjahr = dagjahr
    AND   usnam = hdusnam
    AND   datum = hddatum
    AND   uzeit = hduzeit.
  LOOP AT hbkorm
    WHERE event = bkorm-event
    AND   bukrs = bkorm-bukrs
    AND   koart = bkorm-koart
    AND   konto = bkorm-konto
    AND   belnr = bkorm-belnr
    AND   gjahr = bkorm-gjahr
    AND   usnam = bkorm-usnam
    AND   datum = bkorm-datum
    AND   uzeit = bkorm-uzeit.
    save_tabix = sy-tabix.
    EXIT.
  ENDLOOP.
  IF sy-subrc NE 0.
    CLEAR hbkorm.
    hbkorm = bkorm.
    APPEND hbkorm.
    LOOP AT hbkorm
      WHERE event = bkorm-event
      AND   bukrs = bkorm-bukrs
      AND   koart = bkorm-koart
      AND   konto = bkorm-konto
      AND   belnr = bkorm-belnr
      AND   gjahr = bkorm-gjahr
      AND   usnam = bkorm-usnam
      AND   datum = bkorm-datum
      AND   uzeit = bkorm-uzeit.
      save_tabix = sy-tabix.
      EXIT.
    ENDLOOP.
  ENDIF.

  IF hbkorm-erldt NE sy-datum.
*       UPDATE BKORM SET ERLDT = SY-DATUM
*         WHERE EVENT = SAVE_EVENT
*         AND   BUKRS = HDBUKRS
*         AND   KOART = HDKOART
*         AND   KONTO = HDKONTO
*         AND   BELNR = DABELNR
*         AND   GJAHR = DAGJAHR
*         AND   USNAM = HDUSNAM
*         AND   DATUM = HDDATUM
*         AND   UZEIT = HDUZEIT.
    hbkorm-erldt = sy-datum.
  ENDIF.
  IF NOT xprint IS INITIAL.
    IF xerdt IS INITIAL.
      IF hbkorm-param+33(2) = '  '.
        hbkorm-param+33(2) = '01'.
        hbkorm-param+35(3) = '000'.
      ENDIF.
      CLEAR anzdru.
      IF anzdr2 IS INITIAL.
        anzdru = hbkorm-param+35(3).
        anzdru = anzdru + 1.
      ELSE.
        anzdru = anzdr2.
      ENDIF.
      hbkorm-param+35(3) = anzdru.
    ELSE.
      LOOP AT druckw
        WHERE event =  hbkorm-event
        AND   bukrs =  hbkorm-bukrs
        AND   koart =  hbkorm-koart
        AND   konto =  hbkorm-konto
        AND   belnr =  hbkorm-belnr
        AND   gjahr =  hbkorm-gjahr
        AND   usnam =  hbkorm-usnam
        AND   datum =  hbkorm-datum
        AND   uzeit =  hbkorm-uzeit.
        EXIT.
      ENDLOOP.
      IF sy-subrc NE 0.
        IF hbkorm-param+33(2) = '  '.
          hbkorm-param+33(2) = '00'.
        ENDIF.
        anzwie = hbkorm-param+33(2).
        anzwie = anzwie + 1.
        hbkorm-param+33(2) = anzwie.
        hbkorm-param+35(3) = '000'.
        MOVE-CORRESPONDING hbkorm TO druckw.
        APPEND druckw.
      ENDIF.
      CLEAR anzdru.
      IF anzdr2 IS INITIAL.
        anzdru = hbkorm-param+35(3).
        anzdru = anzdru + 1.
      ELSE.
        anzdru = anzdr2.
      ENDIF.
      hbkorm-param+35(3) = anzdru.
    ENDIF.
  ENDIF.
  hbkorm-avsid = rf140-avsid.
  IF NOT save_tabix IS INITIAL.
    MODIFY hbkorm INDEX save_tabix.
  ENDIF.
  IF NOT xnach IS INITIAL.
    CLEAR hbkormkey.
    CLEAR herdata.
    CLEAR hkokon.
    hbkormkey-bukrs = hbkorm-bukrs.
    hbkormkey-koart = hbkorm-koart.
    hbkormkey-konto = hbkorm-konto.
    hbkormkey-belnr = hbkorm-belnr.
    hbkormkey-gjahr = hbkorm-gjahr.
    CONDENSE hbkormkey.
    herdata-usnam = hbkorm-usnam.
    herdata-datum = hbkorm-datum.
    herdata-uzeit = hbkorm-uzeit.
    IF NOT hdkoar2 IS INITIAL
    OR NOT hdkont2 IS INITIAL.
      hkokon-koart = hdkoar2.
      hkokon-konto = hdkont2.
    ENDIF.
    IF xkausg IS INITIAL.
      IF NOT hdkoar2 IS INITIAL
      OR NOT hdkont2 IS INITIAL.
        CLEAR fimsg.
        fimsg-msort = '    '. fimsg-msgid = 'FB'.
        fimsg-msgty = 'I'.
        fimsg-msgno = '826'.
        fimsg-msgv1 = hbkorm-event.
        fimsg-msgv2 = hbkormkey.
        fimsg-msgv3 = herdata.
        fimsg-msgv4 = hkokon.
        PERFORM message_append.
      ELSE.
        CLEAR fimsg.
        fimsg-msort = '    '. fimsg-msgid = 'FB'.
        fimsg-msgty = 'I'.
        fimsg-msgno = '828'.
        fimsg-msgv1 = hbkorm-event.
        fimsg-msgv2 = hbkormkey.
        fimsg-msgv3 = herdata.
        PERFORM message_append.
      ENDIF.
    ELSE.
      IF NOT hdkoar2 IS INITIAL
      OR NOT hdkont2 IS INITIAL.
        CLEAR fimsg.
        fimsg-msort = '    '. fimsg-msgid = 'FB'.
        fimsg-msgty = 'I'.
        fimsg-msgno = '827'.
        fimsg-msgv1 = hbkorm-event.
        fimsg-msgv2 = hbkormkey.
        fimsg-msgv3 = herdata.
        fimsg-msgv4 = hkokon.
        PERFORM message_append.
      ELSE.
        CLEAR fimsg.
        fimsg-msort = '    '. fimsg-msgid = 'FB'.
        fimsg-msgty = 'I'.
        fimsg-msgno = '548'.
        fimsg-msgv1 = hbkorm-event.
        fimsg-msgv2 = hbkormkey.
        fimsg-msgv3 = herdata.
        PERFORM message_append.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "UPDATA_BKORM_STORE

*-----------------------------------------------------------------------
*       FORM ZENTFIL_DEBI
*-----------------------------------------------------------------------
FORM zentfil_debi.
  LOOP AT dzentfil
    WHERE kunnr = save_kunnr.
    MOVE  dzentfil-bukrs TO azentfil-bukrs.
    MOVE           'D'   TO azentfil-koart.
    MOVE  dzentfil-kunnr TO azentfil-konto.
    MOVE  dzentfil-filkd TO azentfil-filkd.
    APPEND azentfil.
    anzko = '1'.
  ENDLOOP.
ENDFORM.                    "ZENTFIL_DEBI

*-----------------------------------------------------------------------
*       FORM ZENTFIL_KRED
*-----------------------------------------------------------------------
FORM zentfil_kred.
  LOOP AT kzentfil
    WHERE lifnr = save_lifnr.
    MOVE  kzentfil-bukrs TO azentfil-bukrs.
    MOVE           'K'   TO azentfil-koart.
    MOVE  kzentfil-lifnr TO azentfil-konto.
    MOVE  kzentfil-filkd TO azentfil-filkd.
    APPEND azentfil.
    IF anzko = '1'.
      anzko = '2'.
    ELSE.
      anzko = '1'.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "ZENTFIL_KRED

*---------------------------------------------------------------------*
*       FORM OUTPUT_EXIT_001                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM output_exit_001.
  PERFORM exit_001(rfkoriex)
     USING bkorm
           save_koart
           kna1
           knb1
           lfa1
           lfb1
           finaa.
ENDFORM.                    "OUTPUT_EXIT_001

*---------------------------------------------------------------------*
*       FORM OUTPUT_CHECK                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM output_check.
  CASE finaa-nacha.                    "Ausgabe auf Fax
    WHEN space.
* User-Exit inaktiv
* -> Ausgabe auf Drucker
      finaa-nacha = '1'.
    WHEN '1'.
* -> Ausgabe auf Drucker
    WHEN '2'.                          "Ausgabe auf Fax gewünscht
*       CALL FUNCTION 'SK_NUMBER_TO_DEST' "Faxgerät bestimmen
*            EXPORTING  SERVICE                = 'TELEFAX'
*                       NUMBER                 = FINAA-TDTELENUM
*                       COUNTRY                = FINAA-TDTELELAND
*            EXCEPTIONS COUNTRY_NOT_CONFIGURED = 1
*                       SERVICE_NOT_SUPPORTED  = 2
*                       SERVER_NOT_FOUND       = 3
*                       NUMBER_EMPTIED         = 4
*                       NUMBER_EMPTY           = 5
*                       NUMBER_NOT_LEGAL       = 6.
      CALL FUNCTION 'TELECOMMUNICATION_NUMBER_CHECK'
        EXPORTING
          service = 'TELEFAX'
          number  = finaa-tdtelenum
          country = finaa-tdteleland
        EXCEPTIONS
          OTHERS  = 4.
      IF sy-subrc NE 0.
* Bei Bestimmung des Faxgerätes trat ein Fehler auf
* -> doch Ausgabe auf Drucker
        finaa-nacha = '1'.
      ENDIF.
    WHEN 'I'.                          "Ausgabe über Internet gewünscht
      CALL FUNCTION 'SO_PROFILE_READ'
*            EXPORTING
*                 LOCAL                 = ' '
           IMPORTING
                profile               = hprofil
           EXCEPTIONS
                communication_failure = 1
                profile_not_exist     = 2
                system_failure        = 3
                OTHERS                = 4.
      IF sy-subrc NE 0
      OR hprofil-smtp_exist NE 'X'.
* Beim Prüfen des Internetgateways trat ein Fehler auf
* -> doch Ausgabe auf Drucker
        finaa-nacha = '1'.
      ENDIF.
    WHEN OTHERS.
* Das Feld FINAA-NACHA wurde im User-Exit mit einem falschen Wert
* versorgt
* -> Ausgabe auf Drucker
      finaa-nacha = '1'.
  ENDCASE.
ENDFORM.                    "OUTPUT_CHECK

*---------------------------------------------------------------------*
*       FORM OUTPUT_OPENFI                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM output_openfi.
  DATA: t_fimsg LIKE fimsg OCCURS 10 WITH HEADER LINE.

  CALL FUNCTION 'OPEN_FI_PERFORM_00002310_P'
    EXPORTING
      i_bkorm          = bkorm
      i_koart          = save_koart
      i_kna1           = kna1
      i_knb1           = knb1
      i_lfa1           = lfa1
      i_lfb1           = lfb1
    TABLES
      t_fimsg          = t_fimsg
    CHANGING
      c_finaa          = finaa
      c_itcpo          = itcpo
      c_archive_index  = h_archive_index
      c_archive_params = h_archive_params.

  LOOP AT t_fimsg.
    CALL FUNCTION 'FI_MESSAGE_COLLECT'
      EXPORTING
        i_fimsg       = t_fimsg
        i_xappn       = 'X'
      EXCEPTIONS
        msgid_missing = 1
        msgno_missing = 2
        msgty_missing = 3
        OTHERS        = 4.
  ENDLOOP.
ENDFORM.                    "OUTPUT_OPENFI

*---------------------------------------------------------------------*
*       FORM FILL_ITCPO                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM fill_itcpo.
  IF save_tddest IS INITIAL.
    IF NOT syst-pdest  IS INITIAL.
      save_tddest = syst-pdest.
    ELSE.
      IF NOT save_pdest IS INITIAL.
        save_tddest = save_pdest.
      ENDIF.
    ENDIF.
  ENDIF.
  IF save_tddest IS INITIAL.
    SELECT SINGLE * FROM usr01
      WHERE bname = sy-uname.
    save_tddest = usr01-spld.
  ENDIF.
  itcpo-tddest     = save_tddest.      "Drucker
  IF itcpo-tddest IS INITIAL.
    IF ( print    IS INITIAL
    AND sy-batch IS INITIAL )
    OR ( NOT save_rxtsub IS INITIAL
    AND sy-batch IS INITIAL ).
      IF itcpo-tddest IS INITIAL.
        CLEAR usr01.
        CALL FUNCTION 'GET_PRINT_PARAM'
          EXPORTING
            i_bname = sy-uname
          IMPORTING
            e_usr01 = usr01.

        itcpo-tddest     = usr01-spld. "Drucker
      ENDIF.
    ENDIF.
  ENDIF.
  IF save_rxtsub IS INITIAL.
    PERFORM pri_param_get.
  ELSE.
    PERFORM pri_param_import.
  ENDIF.

  itcpo-tdcopies   = pri_params-prcop.
  itcpo-tddelete   = pri_params-prrel.
  CLEAR xpriim.
  IF  NOT sy-batch IS INITIAL
  OR  ( NOT print IS INITIAL
  OR  save_rsimul IS INITIAL ).
    itcpo-tdimmed    = ' '.              "KZ sofort drucken
  ELSE.
    itcpo-tdimmed = save_rimmd.
    IF save_rimmd IS INITIAL.
      IF NOT pri_params-primm IS INITIAL.
        itcpo-tdimmed = 'X'.
      ENDIF.
    ENDIF.
    xpriim = 'X'.
  ENDIF.
  itcpo-tdcover    = pri_params-prsap. "Deckblatt
  itcpo-tddataset  = save_event.       "Datasetname
  itcpo-tdsuffix1  = save_tddest.                           "Suffix1
  itcpo-tdsuffix2  = save_bukrs.                            "Suffix2
  itcpo-tdlifetime = '7'.              "Verfalltage
  itcpo-tdautority = pri_params-prber. "Berechtigung
  itcpo-tdreceiver = pri_params-prrec.
  itcpo-tddivision = pri_params-prabt.
  IF xknid IS INITIAL.
    itcpo-tdnewid    = 'X'.            "Neue Liste
  ENDIF.
  IF  print IS INITIAL
  AND sy-batch IS INITIAL.
    itcpo-tdpreview  = 'X'.            "Druckansicht
  ENDIF.
ENDFORM.                    "FILL_ITCPO

*---------------------------------------------------------------------*
*       FORM PRINTER                                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM printer.
  htddevice = 'PRINTER'.
* IF  print    IS INITIAL
* AND sy-batch IS INITIAL.
  hdialog = ' '.
* ELSE.
*   IF  sy-batch IS INITIAL
*   AND save_rxtsub   IS INITIAL.
*     hdialog = 'X'.
*   ELSE.
*     hdialog = ' '.
*   ENDIF.
* ENDIF.

  IF xknid IS INITIAL.
    xknid = 'X'.
    xspid = ' '.
  ELSE.
    xspid = 'X'.
  ENDIF.
  CLEAR usr01.
ENDFORM.                    "PRINTER

*---------------------------------------------------------------------*
*       FORM TELEFAX                                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM telefax.
  htddevice = 'TELEFAX'.

  IF itcpo-tdschedule IS INITIAL.
    itcpo-tdschedule = finaa-tdschedule.
  ENDIF.
  IF itcpo-tdteleland IS INITIAL.
    itcpo-tdteleland = finaa-tdteleland.
  ENDIF.
  IF itcpo-tdtelenum  IS INITIAL.
    itcpo-tdtelenum  = finaa-tdtelenum.
  ENDIF.
  IF itcpo-tdfaxuser  IS INITIAL.
    itcpo-tdfaxuser  = finaa-tdfaxuser.
  ENDIF.
  IF itcpo-tdschedule = save_tddest.
    itcpo-tdsuffix1  = 'FAX'.                               "Suffix1
  ENDIF.
  itcpo-tdnewid    = 'X'.              "Neue Liste

  IF  sy-batch IS INITIAL
  AND ( save_rxtsub   IS INITIAL
  OR  NOT save_rsimul IS INITIAL ).
    hdialog = 'X'.
  ENDIF.

* check if flag for no telefax popup is set
  STATICS : ls_memory_imported, ls_no_popup.
  DATA no_dialog_telefax.
  IF ls_memory_imported IS INITIAL AND sy-batch IS INITIAL.
    IMPORT no_dialog_telefax FROM MEMORY ID 'DIALOG_RFKORI90'.
    ls_no_popup = no_dialog_telefax.
    ls_memory_imported = 'X'.
  ENDIF.
  IF ls_no_popup = 'X'.
    CLEAR hdialog.
  ENDIF.
ENDFORM.                    "TELEFAX

*---------------------------------------------------------------------*
*       FORM INTERNET                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM internet.
  CLEAR countp.
  htddevice = 'PRINTER'.

  itcpo-tdgetotf   = 'X'.              "OTF Ausgabe für Internet
ENDFORM.                    "INTERNET

*---------------------------------------------------------------------*
*       FORM CHECK_PRINTER                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM check_printer.
  IF finaa-nacha = '1'
  OR finaa-nacha = 'I'.
    IF itcpo-tddest IS INITIAL.
      CLEAR fimsg.
      fimsg-msort = '    '. fimsg-msgid = 'FB'.
      fimsg-msgty = 'I'.
      fimsg-msgno = '517'.
      fimsg-msgv1 = save_repid.
      PERFORM message_append.
      xkausg = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                    "CHECK_PRINTER

*---------------------------------------------------------------------*
*       FORM CLOSE_INTERNET                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM close_internet.
  IF xopen = 'Y'.

    CLEAR   hotfdata.
    REFRESH hotfdata.
****************start of pdf changes by c5112660***********
    IF save_ftype = ' '.
****************end of pdf changes by c5112660*************
      CALL FUNCTION 'CLOSE_FORM'
        IMPORTING
          result   = itcpp
        TABLES
          otfdata  = hotfdata
        EXCEPTIONS
          unopened = 3.
****************start of pdf changes by c5112660***********
    ENDIF.
****************end of pdf changes by c5112660*************

    IF NOT itcpp-tdpages IS INITIAL.
      IF NOT itcpo-tdpreview IS INITIAL.
        itcpp-tdnoprint = 'X'.
        CALL FUNCTION 'DISPLAY_OTF'
          EXPORTING
            control = itcpp
          IMPORTING
            result  = itcpp
          TABLES
            otf     = hotfdata
          EXCEPTIONS
            OTHERS  = 1.

        CALL FUNCTION 'CORRESPONDENCE_POPUP_EMAIL'
          EXPORTING
            i_intad  = finaa-intad
          IMPORTING
            e_answer = hanswer
            e_intad  = finaa-intad
          EXCEPTIONS
            OTHERS   = 1.

      ENDIF.
      IF hanswer = space
      OR hanswer = 'J'.
        hformat = finaa-textf.
        IF hformat IS INITIAL.
          hformat = 'PDF'.               "PDF als Default
        ENDIF.
*       new version of sending mails, see note 1360070
        DATA : ld_text_existing,
               lt_lines TYPE soli_tab,
               ld_new_mail.
        PERFORM check_mail_text USING language CHANGING
            ld_text_existing lt_lines.
        IF ld_text_existing = space.
          PERFORM check_mail_new_version CHANGING ld_new_mail.
        ELSE.
          ld_new_mail = 'X'.
        ENDIF.
        IF ld_new_mail = 'X'.
          DATA : lt_solix_dummy TYPE solix_tab,
                 ld_error.
          REFRESH lt_solix_dummy[].
          PERFORM send_mail_with_attachm TABLES hotfdata
              lt_solix_dummy lt_lines USING ' ' CHANGING ld_error.
          IF ld_error = space.
            CLEAR prot_ausgabe.
            prot_ausgabe-bukrs     = save_bukrs.
            prot_ausgabe-event     = save_event.
            prot_ausgabe-repid     = save_repid.
            prot_ausgabe-intad     = finaa-intad.
            prot_ausgabe-countp    = countp.
            COLLECT prot_ausgabe.
            IF itcpo-tdarmod = '3'.
              CALL FUNCTION 'CONVERT_OTF_AND_ARCHIVE'
                EXPORTING
                  arc_p  = h_archive_params
                  arc_i  = h_archive_index
                TABLES
                  otf    = hotfdata
                EXCEPTIONS
                  OTHERS = 1.
              IF sy-subrc <> 0.
                DATA hs_fimsg LIKE fimsg.
                CLEAR hs_fimsg.
                hs_fimsg-msort = '    '.
                hs_fimsg-msgid = sy-msgid. hs_fimsg-msgty = sy-msgty.
                hs_fimsg-msgno = sy-msgno.
                hs_fimsg-msgv1 = sy-msgv1. hs_fimsg-msgv2 = sy-msgv2.
                hs_fimsg-msgv3 = sy-msgv3. hs_fimsg-msgv4 = sy-msgv4.
                CONDENSE hs_fimsg-msgv1. CONDENSE hs_fimsg-msgv2.
                CONDENSE hs_fimsg-msgv3. CONDENSE hs_fimsg-msgv4.
                CALL FUNCTION 'FI_MESSAGE_COLLECT'
                  EXPORTING
                    i_fimsg = hs_fimsg
                  EXCEPTIONS
                    OTHERS  = 4.
              ENDIF.
            ENDIF.
*-Hilfskonstrukt damit BKORM fortgeschrieben wird---------------------*
            itcpp-tdspoolid = '1'.
*-Commit fuer 6.10 Basis----------------------------------------------*
            COMMIT WORK.
            CLEAR commit_c.
          ENDIF.
        ELSE.
*       send mail in classic way method
          CLEAR   htline.
          REFRESH htline.
          DATA ld_binfile TYPE xstring.
          CALL FUNCTION 'CONVERT_OTF'
            EXPORTING
              format                = hformat
*             MAX_LINEWIDTH         = 132
            IMPORTING
              bin_filesize          = doc_size
              bin_file              = ld_binfile
            TABLES
              otf                   = hotfdata
              lines                 = htline
            EXCEPTIONS
              err_max_linewidth     = 1
              err_format            = 2
              err_conv_not_possible = 3
              OTHERS                = 4.

          DATA: i TYPE i, n TYPE i.
          CLEAR lt_solix.
          REFRESH lt_solix.
          CLEAR   x_objcont.
          REFRESH x_objcont.
          i = 0.
          n = xstrlen( ld_binfile ).
          WHILE i < n.
            lt_solix-line = ld_binfile+i.
            APPEND lt_solix.
            i = i + 255.
          ENDWHILE.

          DATA wa_soli TYPE soli.
          DATA wa_solix TYPE solix.
          FIELD-SYMBOLS: <ptr_hex> TYPE solix.

          LOOP AT lt_solix INTO wa_solix.
            CLEAR wa_soli.
            ASSIGN wa_soli TO <ptr_hex> CASTING.
            MOVE wa_solix TO <ptr_hex>.
            APPEND wa_soli TO x_objcont.
          ENDLOOP.

          IF hformat = 'PDF'.
*        PERFORM TABLE_SHIFT.
          ELSE.
            CLEAR   x_objcont.
            REFRESH x_objcont.
            LOOP AT htline.
*          X_OBJCONT = HTLINE.                       "Note 772389 (del)
              x_objcont-line = htline-tdline.            "Note 772389
              APPEND x_objcont.
            ENDLOOP.
          ENDIF.

          CLEAR x_object_hd_change.
          x_object_hd_change-objnam    = 'EMAIL'.
          IF itcpo-tdtitle IS INITIAL.
            hkora                      = text-204.
          ELSE.
            hkora                      = itcpo-tdtitle.
          ENDIF.
          x_object_hd_change-objdes    = hkora.
          x_object_hd_change-objla     = language.
          x_object_hd_change-objsns    = 'O'.
          x_object_hd_change-objlen    = doc_size.
          IF hformat = 'PDF'.
            x_object_hd_change-file_ext  = 'PDF'.             "<-
          ENDIF.

          CLEAR   x_receivers.
          REFRESH x_receivers.
*         X_RECEIVERS-RECNAM       = FINAA-INTAD.             "<-
          x_receivers-recextnam    = finaa-intad.             "<-
*         X_RECEIVERS-RECESC       = 'U'.                     "<-
          x_receivers-recesc       = 'E'.  "<-
          x_receivers-sndart       = 'INT'."<-
          APPEND x_receivers.

          DESCRIBE TABLE x_objcont LINES linecnt.
          CLEAR    x_objhead.
          REFRESH  x_objhead.

          IF hformat = 'PDF'.
            document_type = 'EXT'.         "<-
          ELSE.
            document_type = 'RAW'.
            x_objhead = linecnt.
            APPEND x_objhead.
          ENDIF.
          DATA: horiginator LIKE  soos1-recextnam.
          horiginator = fsabe-usrnam.

          CALL FUNCTION 'SO_OBJECT_SEND'
            EXPORTING
*             EXTERN_ADDRESS             = ' '
*             FOLDER_ID                  = ' '
*             FORWARDER                  = ' '
*             OBJECT_FL_CHANGE           = ' '
              object_hd_change           = x_object_hd_change
*             OBJECT_ID                  = ' '
              object_type                = document_type
*             OUTBOX_FLAG                = ' '
*             OWNER                      = FSABE-USRNAM
*             STORE_FLAG                 = ' '
*             DELETE_FLAG                = ' '
*             SENDER                     = FSABE-USRNAM
*             CHECK_ALREADY_SENT         = ' '
              originator                 = horiginator
              originator_type            = 'B'
            IMPORTING
*             OBJECT_ID_NEW              =
              sent_to_all                = x_sent_to_all
            TABLES
              objcont                    = x_objcont
              objhead                    = x_objhead
*             OBJPARA                    =
*             OBJPARB                    =
              receivers                  = x_receivers
*             PACKING_LIST               =
*             ATT_CONT                   =
*             ATT_HEAD                   =
*             NOTE_TEXT                  =
            EXCEPTIONS
              active_user_not_exist      = 1
              communication_failure      = 2
              component_not_available    = 3
              folder_not_exist           = 4
              folder_no_authorization    = 5
              forwarder_not_exist        = 6
              note_not_exist             = 7
              object_not_exist           = 8
              object_not_sent            = 9
              object_no_authorization    = 10
              object_type_not_exist      = 11
              operation_no_authorization = 12
              owner_not_exist            = 13
              parameter_error            = 14
              substitute_not_active      = 15
              substitute_not_defined     = 16
              system_failure             = 17
              too_much_receivers         = 18
              user_not_exist             = 19
              x_error                    = 20
              OTHERS                     = 21.

          IF  sy-subrc = 0
          AND NOT finaa-intad IS INITIAL.
            CLEAR prot_ausgabe.
            prot_ausgabe-bukrs     = save_bukrs.
            prot_ausgabe-event     = save_event.
            prot_ausgabe-repid     = save_repid.
            prot_ausgabe-intad     = finaa-intad.
            prot_ausgabe-countp    = countp.
            COLLECT prot_ausgabe.
            IF itcpo-tdarmod = '3'.
              CALL FUNCTION 'CONVERT_OTF_AND_ARCHIVE'       " 1343362
              EXPORTING
                arc_p  = h_archive_params
                arc_i  = h_archive_index
              TABLES
                otf    = hotfdata
              EXCEPTIONS
                OTHERS = 1.
              IF sy-subrc <> 0.
                DATA h_fimsg LIKE fimsg.
                CLEAR h_fimsg.
                h_fimsg-msort = '    '.
                h_fimsg-msgid = sy-msgid. h_fimsg-msgty = sy-msgty.
                h_fimsg-msgno = sy-msgno.
                h_fimsg-msgv1 = sy-msgv1. h_fimsg-msgv2 = sy-msgv2.
                h_fimsg-msgv3 = sy-msgv3. h_fimsg-msgv4 = sy-msgv4.
                CONDENSE h_fimsg-msgv1. CONDENSE h_fimsg-msgv2.
                CONDENSE h_fimsg-msgv3. CONDENSE h_fimsg-msgv4.
                CALL FUNCTION 'FI_MESSAGE_COLLECT'
                  EXPORTING
                    i_fimsg = h_fimsg
                  EXCEPTIONS
                    OTHERS  = 4.
              ENDIF.
            ENDIF.
*-Hilfskonstrukt damit BKORM fortgeschrieben wird---------------------*
            itcpp-tdspoolid = '1'.
*-Commit fuer 6.10 Basis----------------------------------------------*
            COMMIT WORK.
            CLEAR commit_c.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
****************start of pdf changes by c5112660***********
    IF save_ftype = ' '.
****************end of pdf changes by c5112660*************
      CALL FUNCTION 'CLOSE_FORM'
        IMPORTING
          result   = itcpp
        EXCEPTIONS
          unopened = 3.
****************start of pdf changes by c5112660***********
    ENDIF.
****************end of pdf changes by c5112660*************

**      IF SY-SUBRC = 3.
*        IF XOPEN = 'X'.
**                      MESSAGE S358.    "keine Ausgabe
*         ELSE.
**                      MESSAGE S359.    "keine Daten selektiert
*         ENDIF.
*       ENDIF.
*       Keine Ausgabe -> Protokoll?
  ENDIF.
ENDFORM.                    "CLOSE_INTERNET

*-----------------------------------------------------------------------
*       FORM FILL_WAEHRUNGSFELDER_BSEG_2
*-----------------------------------------------------------------------
FORM fill_waehrungsfelder_bseg_2.
  IF *bseg-shkzg = 'S'.
     *rf140-wrshb = *bseg-wrbtr.
     *rf140-dmshb = *bseg-dmbtr.
     *rf140-wsshb = *bseg-wskto.
     *rf140-skshb = *bseg-sknto.
     *rf140-wsshv = 0 - *bseg-wskto.
     *rf140-skshv = 0 - *bseg-sknto.
*   *RF140-ZLSHB = *BSEG-NEBTR.
  ELSE.
     *rf140-wrshb = 0 - *bseg-wrbtr.
     *rf140-dmshb = 0 - *bseg-dmbtr.
     *rf140-wsshb = 0 - *bseg-wskto.
     *rf140-skshb = 0 - *bseg-sknto.
     *rf140-wsshv = *bseg-wskto.
     *rf140-skshv = *bseg-sknto.
*   *RF140-ZLSHB = 0 - *BSEG-NEBTR.
  ENDIF.
ENDFORM.                    "FILL_WAEHRUNGSFELDER_BSEG_2


*---------------------------------------------------------------------*
*       FORM CURRENCY_GET_SUBSEQUENT
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM currency_get_subsequent USING    process   LIKE sy-repid
                                      idate     LIKE sy-datum
                                      ibukrs    LIKE bkpf-bukrs
                             CHANGING cwaers    LIKE bkpf-waers.
*                                     csubc     like xsubc.
  CHECK alwcheck = 'X'.
  DATA:  new_waers LIKE bkpf-waers.
  DATA: xprocess LIKE  tprcd-process.
  xprocess = process.
*    clear: csubc.
  IF xalw_f140 IS INITIAL.
  ELSE.
    xprocess = 'SAPF140'.
  ENDIF.
  CALL FUNCTION 'CURRENCY_GET_SUBSEQUENT'
    EXPORTING
      currency     = cwaers
      process      = xprocess
      date         = idate
      bukrs        = ibukrs
    IMPORTING
      currency_new = new_waers.
  IF new_waers NE cwaers.
    cwaers = new_waers.
*        csubc = 'X'.
  ENDIF.
ENDFORM.                    "CURRENCY_GET_SUBSEQUENT

*---------------------------------------------------------------------*
*       FORM CURR_DOCUMENT_CONVERT_BSID
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM curr_document_convert_bsid USING    idate    LIKE sy-datum
                                         iwaers   LIKE bkpf-waers
                                         ihwaer   LIKE bkpf-waers
                                         ewaers   LIKE bkpf-waers
                                CHANGING cbsid    STRUCTURE bsid.

  DESCRIBE TABLE fieldlist_bsid LINES fldlines.
  IF fldlines IS INITIAL.
    CLEAR   xdfies.
    REFRESH xdfies.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = 'BSID'
      TABLES
        dfies_tab      = xdfies
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    LOOP AT xdfies.
      IF  xdfies-datatype = 'CURR'
      AND xdfies-reftable = 'BSID'
      AND xdfies-reffield = 'WAERS'.
        fieldlist_bsid-name = xdfies-fieldname.
        APPEND fieldlist_bsid.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CALL FUNCTION 'CURRENCY_DOCUMENT_CONVERT'
    EXPORTING
*     RATE_TYPE           = 'M'
      from_currency       = iwaers
      to_currency         = ewaers
      local_currency      = ihwaer
      date                = idate
*     RATE                =
      conversion_mode     = 'O'
    TABLES
      fieldlist           = fieldlist_bsid
*     T_LINES             =
    CHANGING
      line                = cbsid
    EXCEPTIONS
*     FIELD_UNKNOWN       = 1
*     FIELD_NOT_AMOUNT    = 2
*     ERROR_IN_CONVERSION = 3
*     ILLEGAL_PARAMETERS  = 4
      OTHERS              = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    "CURR_DOCUMENT_CONVERT_BSID

*---------------------------------------------------------------------*
*       FORM CURR_DOCUMENT_CONVERT_BSIK
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM curr_document_convert_bsik USING    idate    LIKE sy-datum
                                         iwaers   LIKE bkpf-waers
                                         ihwaer   LIKE bkpf-waers
                                         ewaers   LIKE bkpf-waers
                                CHANGING cbsik    STRUCTURE bsik.

  DESCRIBE TABLE fieldlist_bsik LINES fldlines.
  IF fldlines IS INITIAL.
    CLEAR   xdfies.
    REFRESH xdfies.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = 'BSIK'
      TABLES
        dfies_tab      = xdfies
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    LOOP AT xdfies.
      IF  xdfies-datatype = 'CURR'
      AND xdfies-reftable = 'BSIK'
      AND xdfies-reffield = 'WAERS'.
        fieldlist_bsik-name = xdfies-fieldname.
        APPEND fieldlist_bsik.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CALL FUNCTION 'CURRENCY_DOCUMENT_CONVERT'
    EXPORTING
*     RATE_TYPE           = 'M'
      from_currency       = iwaers
      to_currency         = ewaers
      local_currency      = ihwaer
      date                = idate
*     RATE                =
      conversion_mode     = 'O'
    TABLES
      fieldlist           = fieldlist_bsik
*     T_LINES             =
    CHANGING
      line                = cbsik
    EXCEPTIONS
*     FIELD_UNKNOWN       = 1
*     FIELD_NOT_AMOUNT    = 2
*     ERROR_IN_CONVERSION = 3
*     ILLEGAL_PARAMETERS  = 4
      OTHERS              = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    "CURR_DOCUMENT_CONVERT_BSIK

*---------------------------------------------------------------------*
*       FORM CURR_DOCUMENT_CONVERT_BSEG
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM curr_document_convert_bseg USING    idate    LIKE sy-datum
                                         iwaers   LIKE bkpf-waers
                                         ihwaer   LIKE bkpf-waers
                                         ewaers   LIKE bkpf-waers
                                CHANGING cbseg    STRUCTURE bseg.

  DESCRIBE TABLE fieldlist_bseg LINES fldlines.
  IF fldlines IS INITIAL.
    CLEAR   xdfies.
    REFRESH xdfies.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = 'BSEG'
      TABLES
        dfies_tab      = xdfies
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    LOOP AT xdfies.
      IF  xdfies-datatype = 'CURR'
      AND xdfies-reftable = 'BKPF'
      AND xdfies-reffield = 'WAERS'.
        fieldlist_bseg-name = xdfies-fieldname.
        APPEND fieldlist_bseg.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CALL FUNCTION 'CURRENCY_DOCUMENT_CONVERT'
    EXPORTING
*     RATE_TYPE           = 'M'
      from_currency       = iwaers
      to_currency         = ewaers
      local_currency      = ihwaer
      date                = idate
*     RATE                =
      conversion_mode     = 'O'
    TABLES
      fieldlist           = fieldlist_bseg
*     T_LINES             =
    CHANGING
      line                = cbseg
    EXCEPTIONS
*     FIELD_UNKNOWN       = 1
*     FIELD_NOT_AMOUNT    = 2
*     ERROR_IN_CONVERSION = 3
*     ILLEGAL_PARAMETERS  = 4
      OTHERS              = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    "CURR_DOCUMENT_CONVERT_BSEG

*---------------------------------------------------------------------*
*       FORM CURR_DOCUMENT_CONVERT_BSET
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM curr_document_convert_bset USING    idate    LIKE sy-datum
                                         iwaers   LIKE bkpf-waers
                                         ihwaer   LIKE bkpf-waers
                                         ewaers   LIKE bkpf-waers
                                CHANGING cbset    STRUCTURE bset.

  DESCRIBE TABLE fieldlist_bset LINES fldlines.
  IF fldlines IS INITIAL.
    CLEAR   xdfies.
    REFRESH xdfies.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = 'BSET'
      TABLES
        dfies_tab      = xdfies
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    LOOP AT xdfies.
      IF  xdfies-datatype = 'CURR'
      AND xdfies-reftable = 'BKPF'
      AND xdfies-reffield = 'WAERS'.
        fieldlist_bset-name = xdfies-fieldname.
        APPEND fieldlist_bset.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CALL FUNCTION 'CURRENCY_DOCUMENT_CONVERT'
    EXPORTING
*     RATE_TYPE           = 'M'
      from_currency       = iwaers
      to_currency         = ewaers
      local_currency      = ihwaer
      date                = idate
*     RATE                =
      conversion_mode     = 'O'
    TABLES
      fieldlist           = fieldlist_bset
*     T_LINES             =
    CHANGING
      line                = cbset
    EXCEPTIONS
*     FIELD_UNKNOWN       = 1
*     FIELD_NOT_AMOUNT    = 2
*     ERROR_IN_CONVERSION = 3
*     ILLEGAL_PARAMETERS  = 4
      OTHERS              = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    "CURR_DOCUMENT_CONVERT_BSET

*---------------------------------------------------------------------*
*       FORM CURR_DOCUMENT_CONVERT_RF140
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM curr_document_convert_rf140 USING    idate    LIKE sy-datum
                                          iwaers   LIKE bkpf-waers
                                          ihwaer   LIKE bkpf-waers
                                          ewaers   LIKE bkpf-waers
                                 CHANGING crf140   STRUCTURE rf140.

  DESCRIBE TABLE fieldlist_rf140 LINES fldlines.
  IF fldlines IS INITIAL.
    CLEAR   xdfies.
    REFRESH xdfies.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = 'RF140'
      TABLES
        dfies_tab      = xdfies
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    LOOP AT xdfies.
      IF  xdfies-datatype = 'CURR'
      AND xdfies-reftable = 'RF140'
      AND xdfies-reffield = 'WAERS'.
        fieldlist_rf140-name = xdfies-fieldname.
        APPEND fieldlist_rf140.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CALL FUNCTION 'CURRENCY_DOCUMENT_CONVERT'
    EXPORTING
*     RATE_TYPE           = 'M'
      from_currency       = iwaers
      to_currency         = ewaers
      local_currency      = ihwaer
      date                = idate
*     RATE                =
      conversion_mode     = 'O'
    TABLES
      fieldlist           = fieldlist_rf140
*     T_LINES             =
    CHANGING
      line                = crf140
    EXCEPTIONS
*     FIELD_UNKNOWN       = 1
*     FIELD_NOT_AMOUNT    = 2
*     ERROR_IN_CONVERSION = 3
*     ILLEGAL_PARAMETERS  = 4
      OTHERS              = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    "CURR_DOCUMENT_CONVERT_rf140


*---------------------------------------------------------------------*
*       FORM CONVERT_FOREIGN_TO_FOREIGN_CUR
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM convert_foreign_to_foreign_cur USING    idate    LIKE sy-datum
                                             iwaers   LIKE bkpf-waers
                                             ihwaer   LIKE bkpf-waers
                                             ewaers   LIKE bkpf-waers
                                    CHANGING camnt.   "like bseg-wrbtr.
  CALL FUNCTION 'CONVERT_FOREIGN_TO_FOREIGN_CUR'
    EXPORTING
*       CLIENT                 = SY-MANDT
      date                   = idate
*       TYPE_OF_RATE           = 'M'
      from_amount            = camnt
      from_currency          = iwaers
      to_currency            = ewaers
      local_currency         = ihwaer
      conversion_mode        = 'X'
   IMPORTING
      to_amount              = camnt
*     EXCEPTIONS
*       NO_RATE_FOUND          = 1
*       OVERFLOW               = 2
*       NO_FACTORS_FOUND       = 3
*       NO_SPREAD_FOUND        = 4
*       DERIVED_2_TIMES        = 5
*       OTHERS                 = 6
            .
  IF sy-subrc <> 0.                                         "#EC *
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    "CONVERT_FOREIGN_TO_FOREIGN_CUR

*---------------------------------------------------------------------*
*       FORM CURRENCY_CHECK_FOR_PROCESS
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM currency_check_for_process USING process LIKE sy-repid.
  DATA: hprocess LIKE  tprcd-process.
  CLEAR   alwlines.
  CLEAR   alwcheck.
  CLEAR   xalw_bukrs.
  CLEAR   xalw_f140.
  CLEAR   alw_bukrs.
  REFRESH alw_bukrs.

  hprocess = process.
  CALL FUNCTION 'CURRENCY_CHECK_FOR_PROCESS'
    EXPORTING
      process                = hprocess
    IMPORTING
      all_bukrs              = xalw_bukrs
    TABLES
      t_bukrs                = alw_bukrs
    EXCEPTIONS
      process_not_maintained = 1
      OTHERS                 = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    CALL FUNCTION 'CURRENCY_CHECK_FOR_PROCESS'
      EXPORTING
        process                = 'SAPF140'
      IMPORTING
        all_bukrs              = xalw_bukrs
      TABLES
        t_bukrs                = alw_bukrs
      EXCEPTIONS
        process_not_maintained = 1
        OTHERS                 = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
      xalw_f140 = 'X'.
      IF xalw_bukrs IS INITIAL.
        DESCRIBE TABLE alw_bukrs LINES alwlines.
      ELSE.
        alwcheck = 'X'.
      ENDIF.
    ENDIF.
  ELSE.
    IF xalw_bukrs IS INITIAL.
      DESCRIBE TABLE alw_bukrs LINES alwlines.
    ELSE.
      alwcheck = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                    "CURRENCY_CHECK_FOR_PROCESS
*---------------------------------------------------------------------*
*       FORM CURR_DOCUMENT_CONVERT_WITH_I                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM curr_document_convert_with_i    USING idate    LIKE sy-datum
                                           iwaers   LIKE bkpf-waers
                                           ihwaer   LIKE bkpf-waers
                                           ewaers   LIKE bkpf-waers
                              CHANGING cwith_item   STRUCTURE with_item.

  DESCRIBE TABLE fieldlist_with_item LINES fldlines.
  IF fldlines IS INITIAL.
    CLEAR   xdfies.
    REFRESH xdfies.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = 'WITH_ITEM'
      TABLES
        dfies_tab      = xdfies
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    LOOP AT xdfies.
      IF  xdfies-datatype = 'CURR'
      AND xdfies-reftable = 'BKPF'
      AND xdfies-reffield = 'WAERS'.
        fieldlist_with_item-name = xdfies-fieldname.
        APPEND fieldlist_with_item.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CALL FUNCTION 'CURRENCY_DOCUMENT_CONVERT'
    EXPORTING
*     RATE_TYPE           = 'M'
      from_currency       = iwaers
      to_currency         = ewaers
      local_currency      = ihwaer
      date                = idate
*     RATE                =
      conversion_mode     = 'O'
    TABLES
      fieldlist           = fieldlist_with_item
*     T_LINES             =
    CHANGING
      line                = cwith_item
    EXCEPTIONS
*     FIELD_UNKNOWN       = 1
*     FIELD_NOT_AMOUNT    = 2
*     ERROR_IN_CONVERSION = 3
*     ILLEGAL_PARAMETERS  = 4
      OTHERS              = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    "CURR_DOCUMENT_CONVERT_WITH_I
*---------------------------------------------------------------------*
*       FORM CURR_DOCUMENT_CONVERT_TCJ_P                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM curr_document_convert_tcj_p USING idate    LIKE sy-datum
                                    iwaers   LIKE tcj_positions-currency
                                    ihwaer   LIKE tcj_positions-currency
                                    ewaers   LIKE tcj_positions-currency
                        CHANGING ctcj_positions STRUCTURE tcj_positions.

  DESCRIBE TABLE fieldlist_tcj_p LINES fldlines.
  IF fldlines IS INITIAL.
    CLEAR   xdfies.
    REFRESH xdfies.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = 'TCJ_POSITIONS'
      TABLES
        dfies_tab      = xdfies
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    LOOP AT xdfies.
      IF  xdfies-datatype = 'CURR'
      AND xdfies-reftable = 'TCJ_POSITIONS'
      AND xdfies-reffield = 'CURRENCY'.
        fieldlist_tcj_p-name = xdfies-fieldname.
        APPEND fieldlist_tcj_p.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CALL FUNCTION 'CURRENCY_DOCUMENT_CONVERT'
    EXPORTING
*     RATE_TYPE           = 'M'
      from_currency       = iwaers
      to_currency         = ewaers
      local_currency      = ihwaer
      date                = idate
*     RATE                =
      conversion_mode     = 'O'
    TABLES
      fieldlist           = fieldlist_tcj_p
*     T_LINES             =
    CHANGING
      line                = ctcj_positions
    EXCEPTIONS
*     FIELD_UNKNOWN       = 1
*     FIELD_NOT_AMOUNT    = 2
*     ERROR_IN_CONVERSION = 3
*     ILLEGAL_PARAMETERS  = 4
      OTHERS              = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    "CURR_DOCUMENT_CONVERT_TCJ_P

*---------------------------------------------------------------------*
*       FORM CURR_DOCUMENT_CONVERT_TCJ_D                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM curr_document_convert_tcj_d USING idate    LIKE sy-datum
                                    iwaers   LIKE tcj_documents-currency
                                    ihwaer   LIKE tcj_documents-currency
                                    ewaers   LIKE tcj_documents-currency
                        CHANGING ctcj_documents STRUCTURE tcj_documents.

  DESCRIBE TABLE fieldlist_tcj_d LINES fldlines.
  IF fldlines IS INITIAL.
    CLEAR   xdfies.
    REFRESH xdfies.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = 'TCJ_DOCUMENTS'
      TABLES
        dfies_tab      = xdfies
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    LOOP AT xdfies.
      IF  xdfies-datatype = 'CURR'
      AND xdfies-reftable = 'TCJ_DOCUMENTS'
      AND xdfies-reffield = 'CURRENCY'.
        fieldlist_tcj_d-name = xdfies-fieldname.
        APPEND fieldlist_tcj_d.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CALL FUNCTION 'CURRENCY_DOCUMENT_CONVERT'
    EXPORTING
*     RATE_TYPE           = 'M'
      from_currency       = iwaers
      to_currency         = ewaers
      local_currency      = ihwaer
      date                = idate
*     RATE                =
      conversion_mode     = 'O'
    TABLES
      fieldlist           = fieldlist_tcj_d
*     T_LINES             =
    CHANGING
      line                = ctcj_documents
    EXCEPTIONS
*     FIELD_UNKNOWN       = 1
*     FIELD_NOT_AMOUNT    = 2
*     ERROR_IN_CONVERSION = 3
*     ILLEGAL_PARAMETERS  = 4
      OTHERS              = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    "CURR_DOCUMENT_CONVERT_TCJ_D
*&---------------------------------------------------------------------*
*&      Form  form_open_pdf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM form_open_pdf .

  DATA fp_outputparams TYPE sfpoutputparams.
  STATICS fp_outputparams_last TYPE sfpoutputparams.

*  CLEAR xopen.
  CLEAR itcpo.
  CLEAR itcpp.
  CLEAR itcfx.
  CLEAR htddevice.
  CLEAR hdialog.
  CLEAR finaa.
  CLEAR h_archive_index.
  CLEAR h_archive_params.

  PERFORM fill_itcpo.

  PERFORM output_exit_001.

  PERFORM output_openfi.


  IF save_koart NA 'DK'
  OR ( save_koart = 'D' AND NOT kna1-xcpdk IS INITIAL )
  OR ( save_koart = 'K' AND NOT lfa1-xcpdk IS INITIAL ).
    finaa-nacha = '1'.
  ELSE.
***<<< only print is supported
    finaa-nacha = '1'.
  ENDIF.

  CASE finaa-nacha.
    WHEN '1'.
      PERFORM printer.
    WHEN '2'.
***<<< only print is supported
    WHEN 'I'.
***<<< only print is supported
  ENDCASE.

  PERFORM check_printer.


* get outputparameters
  PERFORM fill_outputparams_pdf USING itcpo
                                CHANGING fp_outputparams.

  IF xkausg IS INITIAL.

* set output parameters and open spool job

    IF fp_outputparams <> fp_outputparams_last
    OR fp_outputparams-preview = 'X'.
      xopen_executed = 'X'.
      IF NOT fp_outputparams_last IS INITIAL.
        xopen = 'Y'.
****************start of pdf changes by c5112660***********
        IF sy-repid NE 'RFKORDES'.
          PERFORM form_close_pdf.
          display_pdf = 'Y'.
        ENDIF.
****************end of pdf changes by c5112660*************
      ENDIF.
      IF sy-repid NE 'RFKORDES'.
        CLEAR xopen.
      ENDIF.
      fp_outputparams_last = fp_outputparams.
*      fp_outputparams-getpdf = abap_true.
      IF gd_is_open IS INITIAL.
        CALL FUNCTION 'FP_JOB_OPEN'
          CHANGING
            ie_outputparams = fp_outputparams
          EXCEPTIONS
            cancel          = 1
            usage_error     = 2
            system_error    = 3
            internal_error  = 4
            OTHERS          = 5.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ELSE.
          gd_is_open = 'X'.
          xopen = 'Y'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

*  IF xkausg IS INITIAL.
*    xopen = 'Y'.
*  ENDIF.
****************start of pdf changes by c5112660***********
  gs_address_pdf-land1 = t001-land1.
  gs_address_pdf-adrnr = t001-adrnr.
  gs_address_pdf-stceg = t001-stceg.
****************end of pdf changes by c5112660*************
ENDFORM.                    " form_open_pdf
*&---------------------------------------------------------------------*
*&      Form  form_close_pdf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM form_close_pdf .

  DATA  fp_joboutput TYPE sfpjoboutput.
  DATA: ld_spoolid   TYPE rspoid.
****************start of pdf changes by c5112660***********

  IF save_repid   = 'RFKORDES'.
    CALL FUNCTION save_fm_name      "   '/1BCDWB/SM00000474'
      EXPORTING
       /1bcdwb/docparams         = gs_docparams
        gs_address               = gs_address_pdf
        gs_info_pdf_t            = gs_info_pdf_t
        gs_ides_form_pdf_t       = gs_ides_form_pdf_t
        gs_dkad2_pdf             = gs_dkad2_pdf
        gs_total                 = ztotal_t
* IMPORTING
*   /1BCDWB/FORMOUTPUT       =
* EXCEPTIONS
*   USAGE_ERROR              = 1
*   SYSTEM_ERROR             = 2
*   INTERNAL_ERROR           = 3
*   OTHERS                   = 4
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.

****************end of pdf changes by c5112660*************
  CASE finaa-nacha.
    WHEN 'I'.
***<<< only print is supported
    WHEN OTHERS.
      IF xopen = 'Y'.
        CLEAR save_outputdone.
        IF gd_is_open = 'X'.
          CALL FUNCTION 'FP_JOB_CLOSE'
            IMPORTING
              e_result       = fp_joboutput
            EXCEPTIONS
              usage_error    = 1
              system_error   = 2
              internal_error = 3
              OTHERS         = 4.
          IF sy-subrc <> 0.
            MESSAGE e403.
          ELSE.
            CLEAR gd_is_open.
            save_outputdone = fp_joboutput-outputdone.
            LOOP AT fp_joboutput-spoolids INTO ld_spoolid.
              CLEAR prot_ausgabe.
              LOOP AT prot_ausgabe
                WHERE bukrs = save_bukrs
                AND   event = save_event
                AND   repid = save_repid
                AND  tddataset = 'PDF'
                AND  tdspoolid = ld_spoolid.
              ENDLOOP.
              IF sy-subrc <> 0.
                prot_ausgabe-bukrs     = save_bukrs.
                prot_ausgabe-event     = save_event.
                prot_ausgabe-repid     = save_repid.
                prot_ausgabe-tddataset = 'PDF'.
                prot_ausgabe-tdspoolid = ld_spoolid.
                IF finaa-nacha = '1'.
                  prot_ausgabe-tddevice = 'PRINTER'.        " 1529763
                  IF  xpriim IS INITIAL.
                    prot_ausgabe-tdimmed = save_rimmd.
                    IF save_rimmd IS INITIAL.
                      IF print IS INITIAL
                      OR ( sy-batch IS INITIAL
                      AND save_rxtsub   IS INITIAL ).
                        IF NOT pri_params-primm IS INITIAL.
                          prot_ausgabe-tdimmed = 'X'.
                        ENDIF.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
                APPEND prot_ausgabe.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.

ENDFORM.                    " form_close_pdf
*&---------------------------------------------------------------------*
*&      Form  fill_outputparams
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITCPO  text
*      <--P_FP_OUTPUTPARAMS  text
*----------------------------------------------------------------------*
FORM fill_outputparams_pdf USING    p_itcpo TYPE itcpo
                           CHANGING p_outputparams TYPE sfpoutputparams.

  p_outputparams-device       = p_itcpo-tdprinter.
  p_outputparams-nodialog     = 'X'.
  p_outputparams-preview      = p_itcpo-tdpreview.
*p_outputparams-GETPDF       =
*p_outputparams-GETPDL       =
*p_outputparams-CONNECTION   =

  p_outputparams-dest         = p_itcpo-tddest.
  p_outputparams-reqnew       = p_itcpo-tdnewid.
  p_outputparams-reqimm       = p_itcpo-tdimmed.
  p_outputparams-reqdel       = p_itcpo-tddelete.
  p_outputparams-reqfinal     = p_itcpo-tdfinal.
*p_outputparams-SPOOLID      =
  p_outputparams-senddate     = p_itcpo-tdsenddate.
  p_outputparams-sendtime     = p_itcpo-tdsendtime.
  p_outputparams-schedule     = p_itcpo-tdschedule.
  p_outputparams-copies       = p_itcpo-tdcopies.
  p_outputparams-dataset      = p_itcpo-tddataset.
  p_outputparams-suffix1      = p_itcpo-tdsuffix1.
  p_outputparams-suffix2      = p_itcpo-tdsuffix2.
  p_outputparams-covtitle     = p_itcpo-tdcovtitle.
  p_outputparams-cover        = p_itcpo-tdcover.
  p_outputparams-receiver     = p_itcpo-tdreceiver.
  p_outputparams-division     = p_itcpo-tddivision.
  p_outputparams-lifetime     = p_itcpo-tdlifetime.
*p_outputparams-AUTHORITY    =
  p_outputparams-rqposname    = p_itcpo-rqposname.
*p_outputparams-PDLTYPE      =
*p_outputparams-XDCNAME      =
*p_outputparams-NOPDF        =
*p_outputparams-SPONUMIV     =

  p_outputparams-arcmode      = p_itcpo-tdarmod.
  p_outputparams-noarmch      = p_itcpo-tdnoarmch.

  p_outputparams-title        = p_itcpo-tdtitle.
  p_outputparams-nopreview    = p_itcpo-tdnoprev.
  p_outputparams-noprint      = p_itcpo-tdnoprint.
*p_outputparams-NOARCHIVE    =
*p_outputparams-IMMEXIT      =
*p_outputparams-NOPRIBUTT    =

ENDFORM.                    " fill_outputparams
*&---------------------------------------------------------------------*
*&      Form  fill_docparams_pdf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LANGUAGE  text
*      -->P_DKADR_INLND  text
*      -->P_H_ARCHIVE_INDEX  text
*      <--P_FP_DOCPARAMS  text
*----------------------------------------------------------------------*
FORM fill_docparams_pdf USING p_language TYPE spras
                              p_country TYPE land1
                              p_archive_index TYPE toa_dara
                     CHANGING p_docparams TYPE sfpdocparams.

  DATA lt_archive_index TYPE tfpdara.

  p_docparams-langu = p_language.
  p_docparams-country = p_country.
  p_docparams-replangu1 = 'E'. "hardcoded fallback

  REFRESH lt_archive_index[].
  IF NOT p_archive_index IS INITIAL.
    APPEND p_archive_index TO lt_archive_index.

    p_docparams-daratab = lt_archive_index.
  ENDIF.
ENDFORM.                    " fill_docparams

*&---------------------------------------------------------------------*
*&      Form  check_mail_new_version
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->C_NEW_VERSION  text
*----------------------------------------------------------------------*
FORM check_mail_new_version CHANGING c_new_version.
  DATA : ld_text_existing,
        ld_address LIKE finaa-intad, ld_addr LIKE finaa-intad.
  c_new_version = space.
  ld_address = finaa-intad.
  IF finaa-nacha = 'I' AND
  ( ld_text_existing <> space OR
  finaa-mail_sensitivity <> space OR
  finaa-mail_importance <> space OR
  finaa-mail_send_prio <> space OR
  finaa-mail_send_addr <> space OR
  finaa-mail_status_attr <> space OR
  finaa-mail_body_text <> space OR
  finaa-mail_outbox_link <> space ).
    c_new_version = 'X'.
    EXIT.
  ENDIF.
* check for multiple mail-addresses in finaa-intad
  SPLIT ld_address AT ' ' INTO ld_addr ld_address.
  IF ld_addr <> space AND ld_address <> space.
    c_new_version = 'X'.
  ENDIF.
ENDFORM.                    "check_mail_new_version

*&---------------------------------------------------------------------*
*&      Form  check_mail_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ID_LANGU          text
*      -->CD_TEXT_EXISTING  text
*      -->CT_LINES          text
*----------------------------------------------------------------------*
FORM check_mail_text USING id_langu CHANGING cd_text_existing
                                    ct_lines TYPE soli_tab.
  DATA :
       ld_packing_list LIKE soxpl OCCURS 1 WITH HEADER LINE,
       ld_header LIKE thead,
       ld_lines  LIKE tline OCCURS 0 WITH HEADER LINE,
       ld_name TYPE tdobname,
       ld_no_lines TYPE i,
       selections LIKE  stxh OCCURS 0 WITH HEADER LINE.

  CLEAR ct_lines[].
  IF finaa-namep <> space.
    ld_name = finaa-namep.
  ELSE.
    ld_name = finaa-mail_body_text.
  ENDIF.
  cd_text_existing = space.
  IF ld_name = space.
    EXIT.
  ENDIF.
* read text for mail-body out of SO10
* with selected language
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      object    = 'TEXT'
      id        = 'FIKO'
      name      = ld_name
      language  = id_langu
    IMPORTING
      header    = ld_header
    TABLES
      lines     = ld_lines
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.
  IF sy-subrc = 0.
    cd_text_existing = 'X'.
  ELSE.
*     with logon language
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        object    = 'TEXT'
        id        = 'FIKO'
        name      = ld_name
        language  = sy-langu
      IMPORTING
        header    = ld_header
      TABLES
        lines     = ld_lines
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc = 0.
      cd_text_existing = 'X'.
    ELSE.
      SELECT * FROM stxh INTO TABLE selections
                   WHERE tdobject   = 'TEXT'
                     AND tdname     = ld_name
                     AND tdid       = 'FIKO'.
      DESCRIBE TABLE selections LINES ld_no_lines .
*     if unique text ld_name, then with available language
      IF ld_no_lines  = '1'.
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            object    = 'TEXT'
            id        = 'FIKO'
            name      = ld_name
            language  = selections-tdspras
          IMPORTING
            header    = ld_header
          TABLES
            lines     = ld_lines
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.
        IF sy-subrc = 0.
          cd_text_existing = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  ct_lines[] = ld_lines[].

ENDFORM.                    "check_mail_text


*&---------------------------------------------------------------------*
*&      Form  send_mail_with_attachm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IT_OTFDATA text
*----------------------------------------------------------------------*
FORM send_mail_with_attachm   TABLES  it_otfdata STRUCTURE itcoo
                                      it_advice  STRUCTURE solix
                                      it_lines   TYPE soli_tab
                              USING   id_call_from_pdf
                              CHANGING cd_error   LIKE boole-boole.

  DATA: so10_lines TYPE i,
        lt_hotfdata LIKE itcoo OCCURS 1 WITH HEADER LINE,
        htline LIKE tline OCCURS 1 WITH HEADER LINE,
        n_objcont TYPE soli_tab,
        ld_address LIKE finaa-intad,
        ld_addr TYPE adr6-smtp_addr,
        send_request TYPE REF TO cl_bcs,
        document TYPE REF TO cl_document_bcs,
        attachment TYPE REF TO cl_document_bcs,
        sender TYPE REF TO cl_sapuser_bcs,
        internet_recipient TYPE REF TO if_recipient_bcs,
        internet_sender TYPE REF TO if_sender_bcs,
        bcs_exception TYPE REF TO cx_bcs,
        sent_to_all TYPE os_boolean,
        lt_solix    TYPE solix_tab,
        BEGIN OF ls_tmp,                                    "1640757
           type    LIKE sxaddrtype-addr_type VALUE 'INT',   "1640757
           address LIKE soextreci1-receiver,                "1640757
        END OF ls_tmp.                                      "1640757


  DESCRIBE TABLE it_lines  LINES so10_lines.
  DATA lt_text_mail       TYPE soli_tab.

  CLEAR lt_text_mail[].
  IF so10_lines > 0.
*  convert gt_lines
    PERFORM convert_itf USING it_lines[] CHANGING lt_text_mail[].
*  the result is now in lt_text_mail[]
  ENDIF.

  TRY.
      send_request = cl_bcs=>create_persistent( ).
      IF finaa-mail_status_attr = space.
        send_request->set_status_attributes(
        i_requested_status =  'N'
        i_status_mail      =  'N' ).
      ELSE.
        send_request->set_status_attributes(
        i_requested_status =  finaa-mail_status_attr
        i_status_mail      =  finaa-mail_status_attr ).
      ENDIF.
*     create sender
      IF finaa-mail_send_addr <> space.
        ld_addr = finaa-mail_send_addr.
        internet_sender = cl_cam_address_bcs=>create_internet_address(
        i_address_string = ld_addr  ).
        CALL METHOD send_request->set_sender
          EXPORTING
            i_sender = internet_sender.
      ELSE.
        DATA: ld_originator TYPE uname.
        IF finaa-intuser <> space.
          ld_originator = finaa-intuser.
        ELSEIF fsabe-usrnam IS INITIAL.
          ld_originator = sy-uname.
        ELSE.
          ld_originator = fsabe-usrnam.
        ENDIF.
        sender = cl_sapuser_bcs=>create( ld_originator ).
        CALL METHOD send_request->set_sender
          EXPORTING
            i_sender = sender.
      ENDIF.
*     create recipients
      ld_address = finaa-intad.
      WHILE ld_address <> space.
        WHILE ld_address(1) = space.
          SHIFT ld_address BY 1 PLACES.
        ENDWHILE.
        SPLIT ld_address AT ' ' INTO ls_tmp-address ld_address. "1640757
        CALL FUNCTION 'SX_INTERNET_ADDRESS_TO_NORMAL'       "1640757
        EXPORTING address_unstruct = ls_tmp                 "1640757
        IMPORTING address_normal   = ls_tmp                 "1640757
        EXCEPTIONS error_address       = 2                  "1640757
                   error_group_address = 3.                 "1640757
        CHECK sy-subrc = 0.                                 "1640757
                                                            "1640757
        ld_addr = ls_tmp-address.                           "1640757
        internet_recipient =
        cl_cam_address_bcs=>create_internet_address(
                            i_address_string = ld_addr ).
        CALL METHOD send_request->add_recipient
          EXPORTING
            i_recipient = internet_recipient.
      ENDWHILE.

      document = cl_document_bcs=>create_document(
      i_type    = 'TXT'
      i_text    = lt_text_mail
      i_subject = itcpo-tdtitle ).

      IF id_call_from_pdf IS INITIAL.
        PERFORM convert_advice TABLES it_otfdata n_objcont lt_solix.
      ELSE.
        lt_solix[] = it_advice[].
      ENDIF.

      IF finaa-textf = 'PDF' OR finaa-textf = space.
        attachment = cl_document_bcs=>create_document(
        i_type    = 'PDF'
        i_hex     = lt_solix
        i_subject = itcpo-tdtitle ).
      ELSE.
        attachment = cl_document_bcs=>create_document(
        i_type    = 'RAW'
        i_text    = n_objcont
        i_subject = itcpo-tdtitle ).
      ENDIF.

      IF finaa-mail_sensitivity <> space.
*      'P' is confidential, * 'F' is functional
        document->set_sensitivity( finaa-mail_sensitivity ).
      ENDIF.
      IF finaa-mail_importance <> space.
        document->set_importance( finaa-mail_importance ).
      ENDIF.

      CALL METHOD document->add_document_as_attachment
        EXPORTING
          im_document = attachment.
      send_request->set_document( document ).

      IF finaa-mail_send_prio <> space.
        send_request->set_priority( finaa-mail_send_prio ).
      ENDIF.

      IF itcpo-tdsenddate IS NOT INITIAL.
        DATA : l_timestamp TYPE bcs_sndat, l_tzone TYPE timezone.
        l_tzone = sy-zonlo.
        CONVERT DATE itcpo-tdsenddate TIME itcpo-tdsendtime
          INTO TIME STAMP l_timestamp TIME ZONE l_tzone.
        send_request->send_request->set_send_at( l_timestamp ).
      ENDIF.

      IF finaa-mail_outbox_link <> space.
        send_request->send_request->set_link_to_outbox(
                                  EXPORTING i_link_to_outbox = 'X' ).
      ENDIF.

      sent_to_all = send_request->send(
      i_with_error_screen = space ).
      IF sent_to_all = space.
        fimsg-msgno = '750'.
        fimsg-msgv1 = sy-subrc.
*        PERFORM MESSAGE USING '750'.
      ENDIF.

    CATCH cx_bcs INTO bcs_exception.
      fimsg-msgno = '750'.
      fimsg-msgv1 = sy-subrc.
*      PERFORM MESSAGE USING '750'.
      cd_error = 'X'.
  ENDTRY.

ENDFORM.                    "send_mail_with_attachm

*&---------------------------------------------------------------------*
*&      Form  convert_itf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM convert_itf USING it_lines TYPE soli_tab
                 CHANGING ct_text_mail TYPE soli_tab.

  DATA : x_objcont TYPE soli_tab WITH HEADER LINE,
        x_objcont_line LIKE soli,
        hltlines TYPE i, so10_lines TYPE i,
        htabix LIKE sy-tabix,
        lp_fle1(2) TYPE p, lp_fle2(2) TYPE p, lp_off1 TYPE p,
        linecnt TYPE p,
        hfeld(500) TYPE c,
        ltxt_tdtab_c256(256) OCCURS 5 WITH HEADER LINE,
        ltxt_tdtab_x256 TYPE tdtab_x256,
        ls_tdtab_x256   TYPE LINE OF tdtab_x256.
  FIELD-SYMBOLS <cptr>  TYPE c.

* convert gt_lines to destination format
  CALL FUNCTION 'CONVERT_ITF_TO_ASCII'
    EXPORTING
      tabletype         = 'BIN'
    IMPORTING
      x_datatab         = ltxt_tdtab_x256
    TABLES
      itf_lines         = it_lines
    EXCEPTIONS
      invalid_tabletype = 1
      OTHERS            = 2.
  LOOP AT ltxt_tdtab_x256 INTO ls_tdtab_x256.
    ASSIGN ls_tdtab_x256 TO <cptr> CASTING.
    ltxt_tdtab_c256 = <cptr>.
    APPEND ltxt_tdtab_c256.
  ENDLOOP.

  IF cl_abap_char_utilities=>charsize > 1.
    DATA tab_c256(256) OCCURS 5 WITH HEADER LINE.
    DATA : i TYPE i, ld_appended(1) TYPE c.
    LOOP AT ltxt_tdtab_c256.
      i = sy-tabix MOD 2.
      ld_appended = space.
      IF i = 1.                         " uneven
        tab_c256 = ltxt_tdtab_c256.
      ELSE.
        tab_c256+128 = ltxt_tdtab_c256.  " even
        APPEND tab_c256.
        ld_appended = 'X'.
      ENDIF.
    ENDLOOP.
    IF  ld_appended = space.
      APPEND tab_c256.                   " append last line.
    ENDIF.
    ltxt_tdtab_c256[] = tab_c256[].
  ENDIF.

* convert to 255 for call to cl_bcs
  DESCRIBE TABLE ltxt_tdtab_c256 LINES  hltlines.
  DESCRIBE FIELD ltxt_tdtab_c256 LENGTH lp_fle1 IN CHARACTER MODE.
  DESCRIBE FIELD  x_objcont_line LENGTH lp_fle2 IN CHARACTER MODE.
  LOOP AT ltxt_tdtab_c256.
    htabix = sy-tabix.
    MOVE ltxt_tdtab_c256 TO hfeld+lp_off1.
    IF htabix = hltlines.
      lp_fle1 = strlen( ltxt_tdtab_c256 ).
    ENDIF.
    lp_off1 = lp_off1 + lp_fle1.
    IF lp_off1 GE lp_fle2.
      CLEAR x_objcont.  x_objcont = hfeld(lp_fle2).
      APPEND x_objcont. SHIFT hfeld BY lp_fle2 PLACES.
      lp_off1 = lp_off1 - lp_fle2.
    ENDIF.
    IF htabix = hltlines.
      IF lp_off1 GT 0.
        CLEAR x_objcont.
        x_objcont = hfeld(lp_off1).
        APPEND x_objcont.
      ENDIF.
    ENDIF.
  ENDLOOP.
  ct_text_mail[] = x_objcont[].

ENDFORM.                    "convert_itf

*&---------------------------------------------------------------------*
*&      Form  convert_advice
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IT_OTFDATA text
*      -->N_OBJCONT  text
*----------------------------------------------------------------------*
FORM convert_advice TABLES  it_otfdata STRUCTURE itcoo
                            n_objcont  TYPE soli_tab
                            e_solix    TYPE solix_tab.

  DATA: ld_hformat(10) TYPE c, doc_size(12) TYPE c,
        hltlines TYPE i, so10_lines TYPE i,
        htabix LIKE sy-tabix,
        lp_fle1(2) TYPE p, lp_fle2(2) TYPE p, lp_off1 TYPE p,
        linecnt TYPE p,
        hfeld(500) TYPE c,
        lt_hotfdata LIKE itcoo OCCURS 1 WITH HEADER LINE,
        htline LIKE tline OCCURS 1 WITH HEADER LINE,
        x_objcont TYPE soli_tab WITH HEADER LINE,
        x_objcont_line LIKE soli,
        ld_binfile TYPE xstring,
        lt_solix   TYPE solix_tab ,
        wa_soli TYPE soli,
        wa_solix TYPE solix,
        i TYPE i, n TYPE i.

  FIELD-SYMBOLS: <ptr_hex> TYPE solix.

* convert data
  LOOP AT it_otfdata INTO lt_hotfdata.
    APPEND lt_hotfdata.
  ENDLOOP.
  ld_hformat = finaa-textf.
  IF ld_hformat IS INITIAL OR ld_hformat = 'PDF'.
    ld_hformat = 'PDF'.               "PDF as default
  ELSE.
    ld_hformat = 'ASCII'.
  ENDIF.
  CALL FUNCTION 'CONVERT_OTF'
    EXPORTING
      format                = ld_hformat
    IMPORTING
      bin_filesize          = doc_size
      bin_file              = ld_binfile
    TABLES
      otf                   = lt_hotfdata
      lines                 = htline
    EXCEPTIONS
      err_max_linewidth     = 1
      err_format            = 2
      err_conv_not_possible = 3
      OTHERS                = 4.

  n = xstrlen( ld_binfile ).
  WHILE i < n.
    wa_solix-line = ld_binfile+i.
    APPEND wa_solix TO lt_solix.
    i = i + 255.
  ENDWHILE.

  e_solix[] = lt_solix[].

  IF ld_hformat <> 'PDF'.
    LOOP AT htline.
      x_objcont = htline-tdline.
      APPEND x_objcont TO n_objcont.
    ENDLOOP.
  ENDIF.

ENDFORM.                    "convert_advice
