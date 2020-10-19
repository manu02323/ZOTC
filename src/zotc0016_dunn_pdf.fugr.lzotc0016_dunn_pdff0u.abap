*----------------------------------------------------------------------*
***INCLUDE LF150F0U .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  UNLOCK_MHNK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_C_MHNK  text                                               *
*----------------------------------------------------------------------*
FORM unlock_mhnk USING i_mhnk LIKE mhnk.

  CALL FUNCTION 'DEQUEUE_EMHNK'
       EXPORTING
            laufd  = i_mhnk-laufd
            laufi  = i_mhnk-laufi
            koart  = i_mhnk-koart
            bukrs  = i_mhnk-bukrs
            kunnr  = i_mhnk-kunnr
            lifnr  = i_mhnk-lifnr
            cpdky  = i_mhnk-cpdky
            sknrze = i_mhnk-sknrze
            smaber = i_mhnk-smaber
            smahsk = i_mhnk-smahsk
       EXCEPTIONS
            OTHERS = 1.

ENDFORM.                               " UNLOCK_MHNK

FORM feldauswahl_letzte.
  DATA:    hlp_rc              LIKE sy-subrc.
*------- schlüsselworte lesen ----------------------------------------
  LOOP AT flstab WHERE fldtx = space.
    PERFORM schluesselwort_lesen1(sapfs003)
            USING flstab-feldn flstab-fldtx hlp_rc.
    MODIFY flstab.
  ENDLOOP.

*------- pop-up aufrufen ---------------------------------------------
  PERFORM feldauswahl_common.

*------- ... andere felder als die zuletzt verwendeten anbieten ------
  IF feldname_h = '...'.
    PERFORM feldauswahl_tabelle.
  ENDIF.
ENDFORM.

FORM feldauswahl_tabelle.
  CALL SCREEN 0110 STARTING AT 1 1.
  IF ok-code ne 'CNCL'.
    IF f110help-xflsb = 'X'.
      DESCRIBE TABLE beleg_tab LINES sy-tfill.
      IF sy-tfill = 0.
        PERFORM feldauswahl_nametab USING 'BELG'.
        beleg_tab[] = flstab[].
      ELSE.  flstab[] = beleg_tab[].
      ENDIF.
    ELSEIF f110help-xflsk = 'X'.
      DESCRIBE TABLE kredi_tab LINES sy-tfill.
      IF sy-tfill = 0.
        PERFORM feldauswahl_nametab USING 'KRED'.
        kredi_tab[] = flstab[].
      ELSE.  flstab[] = kredi_tab[].
      ENDIF.
      kredi_tab[] = flstab[].
    ELSE.
      IF sy-tfill = 0.
        PERFORM feldauswahl_nametab USING 'DEBI'.
        debi_tab[] = flstab[].
      ELSE.  flstab[] = debi_tab[].
      ENDIF.
    ENDIF.
    PERFORM feldauswahl_letzte.
  endif.
ENDFORM.

FORM feldauswahl_nametab USING par_object TYPE c.
  DATA: loc_tab1 LIKE dntab-tabname,
        loc_tab2 LIKE dntab-tabname,
        loc_tab3 LIKE dntab-tabname.
  CASE par_object.
    WHEN 'BELG'.
      loc_tab1 = 'BSID'.  loc_tab2 = 'BSIK'.  loc_tab3 = space.
    WHEN 'KRED'.
      loc_tab1 = 'LFA1'.  loc_tab2 = 'LFB1'.  loc_tab3 = 'LFB5'.
    WHEN 'DEBI'.
      loc_tab1 = 'KNA1'.  loc_tab2 = 'KNB1'.  loc_tab3 = 'KNB5'.
  ENDCASE.
  REFRESH flstab[].
  CALL FUNCTION 'NAMETAB_GET'
       EXPORTING  tabname = loc_tab1
       TABLES     nametab = hnamtab
       EXCEPTIONS OTHERS  = 0.
  PERFORM feldauswahl_flstab_fuellen.
  REFRESH hnamtab.
  IF loc_tab2 ne space.
    CALL FUNCTION 'NAMETAB_GET'
         EXPORTING  tabname = loc_tab2
         TABLES     nametab = hnamtab
         EXCEPTIONS OTHERS  = 0.
    PERFORM feldauswahl_flstab_fuellen.
  ENDIF.
  IF loc_tab3 ne space.
    CALL FUNCTION 'NAMETAB_GET'
         EXPORTING  tabname = loc_tab3
         TABLES     nametab = hnamtab
         EXCEPTIONS OTHERS  = 0.
    PERFORM feldauswahl_flstab_fuellen.
  ENDIF.
ENDFORM.

FORM feldauswahl_flstab_fuellen.
  LOOP AT hnamtab WHERE fieldname NE 'MANDT'
                  AND   fieldname NE 'KUNNR'
                  AND   fieldname NE 'LIFNR'
                  AND   fieldname NE 'BUKRS'
                  AND   fieldname NE 'ERNAM'
                  AND   fieldname NE 'ERDAT'
                  AND   fieldname NE 'MCOD1'
                  AND   fieldname NE 'MCOD2'
                  AND   fieldname NE 'MCOD3'
                  AND   fieldname NE 'INTAD'
                  AND   fieldname NE 'GRICD'
                  AND   fieldname NE 'GRIDT'
                  AND   fieldname NE 'LOEVM'.
    CASE hnamtab-tabname.
      WHEN 'LFA1'.
        CHECK hnamtab-fieldname ne 'ANRED'.
        CHECK hnamtab-fieldname ne 'BAHNS'.
        CHECK hnamtab-fieldname ne 'BUBKZ'.
        CHECK hnamtab-fieldname ne 'SPERM'.
        CHECK hnamtab-fieldname ne 'SEXKZ'.
        CHECK hnamtab-fieldname ne 'GBORT'.
        CHECK hnamtab-fieldname ne 'GBDAT'.
        CHECK hnamtab-fieldname ne 'LTSNA'.
        CHECK hnamtab-fieldname ne 'DUEFL'.
      WHEN 'LFB1'.
        CHECK hnamtab-fieldname ne 'ZUAWA'.
        CHECK hnamtab-fieldname ne 'ZINDT'.
        CHECK hnamtab-fieldname ne 'ZINRT'.
        CHECK hnamtab-fieldname ne 'REPRF'.
      WHEN 'KNA1'.
        CHECK hnamtab-fieldname ne 'ANRED'.
        CHECK hnamtab-fieldname ne 'ADRNR'.
        CHECK hnamtab-fieldname ne 'AUFSD'.
        CHECK hnamtab-fieldname ne 'BAHNE'.
        CHECK hnamtab-fieldname ne 'BAHNS'.
        CHECK hnamtab-fieldname ne 'EXABL'.
        CHECK hnamtab-fieldname ne 'FAKSD'.
        CHECK hnamtab-fieldname ne 'LIFSD'.
        CHECK hnamtab-fieldname ne 'RPMKR'.
        CHECK hnamtab-fieldname ne 'DEAR1'.
        CHECK hnamtab-fieldname ne 'DEAR2'.
        CHECK hnamtab-fieldname ne 'DEAR3'.
        CHECK hnamtab-fieldname ne 'DEAR4'.
        CHECK hnamtab-fieldname ne 'DEAR5'.
        CHECK hnamtab-fieldname ne 'BRAN1'.
        CHECK hnamtab-fieldname ne 'BRAN2'.
        CHECK hnamtab-fieldname ne 'BRAN3'.
        CHECK hnamtab-fieldname ne 'BRAN4'.
        CHECK hnamtab-fieldname ne 'BRAN5'.
        CHECK hnamtab-fieldname ne 'GFORM'.
        CHECK hnamtab-fieldname ne 'EKONT'.
        CHECK hnamtab-fieldname ne 'UMSAT'.
        CHECK hnamtab-fieldname ne 'UMJAH'.
        CHECK hnamtab-fieldname ne 'UWAER'.
        CHECK hnamtab-fieldname ne 'JMZAH'.
        CHECK hnamtab-fieldname ne 'JMJAH'.
        CHECK hnamtab-fieldname ne 'KATR1'.
        CHECK hnamtab-fieldname ne 'KATR2'.
        CHECK hnamtab-fieldname ne 'KATR3'.
        CHECK hnamtab-fieldname ne 'KATR4'.
        CHECK hnamtab-fieldname ne 'KATR5'.
        CHECK hnamtab-fieldname ne 'KATR6'.
        CHECK hnamtab-fieldname ne 'KATR7'.
        CHECK hnamtab-fieldname ne 'KATR8'.
        CHECK hnamtab-fieldname ne 'KATR9'.
        CHECK hnamtab-fieldname ne 'KATR10'.
        CHECK hnamtab-fieldname ne 'UMSA1'.
        CHECK hnamtab-fieldname ne 'ABRVW'.
        CHECK hnamtab-fieldname ne 'INSPBYDEBI'.
        CHECK hnamtab-fieldname ne 'INSPATDEBI'.
        CHECK hnamtab-fieldname ne 'DUEFL'.
        CHECK hnamtab-fieldname ne 'HZUOR'.
        CHECK hnamtab-fieldname ne 'SPERZ'.
        CHECK hnamtab-fieldname ne 'ETIKG'.
        CHECK hnamtab-fieldname ne 'CIVVE'.
        CHECK hnamtab-fieldname ne 'MILVE'.
        CHECK hnamtab-fieldname ne 'KDKG1'.
        CHECK hnamtab-fieldname ne 'KDKG2'.
        CHECK hnamtab-fieldname ne 'KDKG3'.
        CHECK hnamtab-fieldname ne 'KDKG4'.
        CHECK hnamtab-fieldname ne 'KDKG5'.
        CHECK hnamtab-fieldname ne 'XICMS'.
        CHECK hnamtab-fieldname ne 'XXIPI'.
        CHECK hnamtab-fieldname ne 'XSUBT'.
        CHECK hnamtab-fieldname ne 'CFOPC'.
        CHECK hnamtab-fieldname ne 'TXLW1'.
        CHECK hnamtab-fieldname ne 'TXLW2'.
        CHECK hnamtab-fieldname ne 'BUBKZ'.
      WHEN 'KNB1'.
        CHECK hnamtab-fieldname ne 'ZAMIM'.
        CHECK hnamtab-fieldname ne 'ZAMIV'.
        CHECK hnamtab-fieldname ne 'ZAMIR'.
        CHECK hnamtab-fieldname ne 'ZAMIB'.
        CHECK hnamtab-fieldname ne 'ZAMIO'.
        CHECK hnamtab-fieldname ne 'VLIBB'.
        CHECK hnamtab-fieldname ne 'VRSZL'.
        CHECK hnamtab-fieldname ne 'PERKZ'.
        CHECK hnamtab-fieldname ne 'XAUSZ'.
        CHECK hnamtab-fieldname ne 'SREGL'.
        CHECK hnamtab-fieldname ne 'XZVER'.
        CHECK hnamtab-fieldname ne 'VRSDG'.
        CHECK hnamtab-fieldname ne 'VRSPR'.
        CHECK hnamtab-fieldname ne 'DATLZ'.
      WHEN 'BSIK' OR 'BSID'.
        CHECK hnamtab-fieldname ne 'AUGDT'.
        CHECK hnamtab-fieldname ne 'AUGBL'.
        CHECK hnamtab-fieldname ne 'WMWST'.
        CHECK hnamtab-fieldname ne 'MWSTS'.
        CHECK hnamtab-fieldname ne 'MWST2'.
        CHECK hnamtab-fieldname ne 'MWST3'.
        CHECK hnamtab-fieldname ne 'BDIFF'.
        CHECK hnamtab-fieldname ne 'BDIF2'.
        CHECK hnamtab-fieldname ne 'BDIF3'.
        CHECK hnamtab-fieldname ne 'FKONT'.
        CHECK hnamtab-fieldname ne 'PROJN'.
        CHECK hnamtab-fieldname ne 'SKFBT'.
        CHECK hnamtab-fieldname ne 'SKNT2'.
        CHECK hnamtab-fieldname ne 'SKNT3'.
        CHECK hnamtab-fieldname ne 'DMBE2'.
        CHECK hnamtab-fieldname ne 'DMBE3'.
        CHECK hnamtab-fieldname ne 'REBZG'.
        CHECK hnamtab-fieldname ne 'REBZJ'.
        CHECK hnamtab-fieldname ne 'REBZZ'.
        CHECK hnamtab-fieldname ne 'ZOLLD'.
        CHECK hnamtab-fieldname ne 'ZOLLT'.
        CHECK hnamtab-fieldname ne 'MADAT'.
        CHECK hnamtab-fieldname ne 'MANST'.
        CHECK hnamtab-fieldname ne 'XNETB'.
        CHECK hnamtab-fieldname ne 'XANET'.
        CHECK hnamtab-fieldname ne 'XCPDD'.
        CHECK hnamtab-fieldname ne 'XESRD'.
        CHECK hnamtab-fieldname ne 'MWSK1'.
        CHECK hnamtab-fieldname ne 'DMBT1'.
        CHECK hnamtab-fieldname ne 'WRBT1'.
        CHECK hnamtab-fieldname ne 'MWSK2'.
        CHECK hnamtab-fieldname ne 'DMBT2'.
        CHECK hnamtab-fieldname ne 'WRBT2'.
        CHECK hnamtab-fieldname ne 'MWSK3'.
        CHECK hnamtab-fieldname ne 'DMBT3'.
        CHECK hnamtab-fieldname ne 'WRBT3'.
        CHECK hnamtab-fieldname ne 'QSSHB'.
        CHECK hnamtab-fieldname ne 'QBSHB'.
        CHECK hnamtab-fieldname ne 'ANFBN'.
        CHECK hnamtab-fieldname ne 'ANFBJ'.
        CHECK hnamtab-fieldname ne 'ANFBU'.
        CHECK hnamtab-fieldname ne 'REBZT'.
        CHECK hnamtab-fieldname ne 'DMB21'.
        CHECK hnamtab-fieldname ne 'DMB22'.
        CHECK hnamtab-fieldname ne 'DMB23'.
        CHECK hnamtab-fieldname ne 'DMB31'.
        CHECK hnamtab-fieldname ne 'DMB32'.
        CHECK hnamtab-fieldname ne 'DMB33'.
        CHECK hnamtab-fieldname ne 'KZBTR'.
        CHECK hnamtab-fieldname ne 'XARCH'.
        CHECK hnamtab-fieldname ne 'PSWSL'.
        CHECK hnamtab-fieldname ne 'PSWBT'.
        CHECK hnamtab-fieldname ne 'IMKEY'.
        CHECK hnamtab-fieldname ne 'VPOS2'.
        CHECK hnamtab-fieldname ne 'XNOZA'.
        CHECK hnamtab-fieldname ne 'INFAE'.
        CHECK hnamtab-fieldname ne 'ZEKKN'.
        CHECK hnamtab-fieldname ne 'ZBFIX'.
    ENDCASE.

    CONCATENATE hnamtab-tabname '-' hnamtab-fieldname INTO flstab-feldn.
    flstab-fldtx = space.
    APPEND flstab.
  ENDLOOP.
ENDFORM.


FORM feldauswahl_common.
*------- HFLDTAB füllen --------------------------------
  REFRESH hfldtab.
  CLEAR hfldtab.
  hfldtab-tabname    = 'F110HELP'.
  hfldtab-fieldname  = 'FLDTX'.
  APPEND hfldtab.
  CLEAR hfldtab.
  hfldtab-tabname    = 'F110HELP'.
  hfldtab-fieldname  = 'FELDN'.
  hfldtab-selectflag = 'X'.
  APPEND hfldtab.

*------- HVALTAB füllen --------------------------------
  REFRESH hvaltab.
  LOOP AT flstab.
    hvaltab-feld = flstab-fldtx.
    APPEND hvaltab.
    hvaltab-feld = flstab-feldn.
    APPEND hvaltab.
  ENDLOOP.

*------- Werthilfe aufrufen ----------------------------
  feldname_h = space.
  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE'
       EXPORTING
            cucol        = 10
            curow        = 5
            display      = space
            fieldname    = 'FELDN'
            tabname      = 'F110HELP'
       IMPORTING
            select_value = feldname_h
       TABLES
            fields       = hfldtab
            valuetab     = hvaltab.
ENDFORM.
