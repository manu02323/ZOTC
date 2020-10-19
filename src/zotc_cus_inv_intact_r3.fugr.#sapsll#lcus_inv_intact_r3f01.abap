*----------------------------------------------------------------------*
***INCLUDE /SAPSLL/LCUS_INV_INTACT_R3F01 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  likp_complete_filter
*&---------------------------------------------------------------------*
*       Erledigte Lieferungen ausfiltern
*----------------------------------------------------------------------*
FORM likp_complete_filter  CHANGING ct_likp  TYPE /sapsll/likp_r3_t
                                    cr_vbeln TYPE /sapsll/vbeln_r3_r_t
                                    cr_exnum TYPE /sapsll/exnum_r3_r_t.

  DATA: lt_vbfa      TYPE /sapsll/vbfa_r3_t.
  DATA: ls_vbfa      TYPE vbfa.
  DATA: ls_likp      TYPE likp.
  DATA: lt_vbrk      TYPE tab_vbrk.
  DATA: ls_vbrk      TYPE vbrk.
  DATA: ls_vbeln     TYPE /sapsll/vbeln_r3_r_s.
  DATA: ls_exnum     TYPE /sapsll/exnum_r3_r_s.
  DATA: lr_vbeln_del TYPE /sapsll/vbeln_r3_r_t.
  DATA: lt_tler3b    TYPE  sllr3_doc_type_t.
  DATA: ls_tler3b    TYPE  sllr3_doc_type_s.
  DATA: lv_tfill     TYPE sy-tfill.

  TYPES: BEGIN OF /sapsll/fkart_r_s,
           sign   TYPE ddsign,
           option TYPE ddoption,
           low    TYPE fkart,
           high   TYPE fkart,
         END OF /sapsll/fkart_r_s.

  DATA: ls_fkart TYPE /sapsll/fkart_r_s.
  DATA: lr_fkart TYPE STANDARD TABLE OF /sapsll/fkart_r_s.

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
        AND vbtyp_n = vbtyp_rech.   " Rechnungen
  ENDIF.

  IF sy-subrc = 0.
*-- Nur GTS-relevante Fakturen nachlesen
    SELECT * FROM /sapsll/tler3b
        INTO CORRESPONDING FIELDS OF TABLE lt_tler3b
          WHERE apevs_r3 = gc_application_level-invoice
            AND gcuma_r3 = gc_true.

    LOOP AT lt_tler3b INTO ls_tler3b.
      ls_fkart-sign   = 'I'.
      ls_fkart-option = 'EQ'.
      ls_fkart-low    = ls_tler3b-barvs_r3.
      APPEND ls_fkart TO lr_fkart.
    ENDLOOP.

*-- Fakturen aus dem Belegfluss nachlesen (nur Überleitungsrelevante)
    DESCRIBE TABLE lt_vbfa LINES lv_tfill.
    IF lv_tfill > 0.
      SELECT * FROM vbrk INTO TABLE lt_vbrk
         FOR ALL ENTRIES IN lt_vbfa
          WHERE vbeln = lt_vbfa-vbeln
          AND   fkart IN lr_fkart
          AND   fksto = ' '.
    ENDIF.

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
          ENDIF.
        ENDLOOP.
      ENDLOOP.
*---- Lieferungen aussortieren fuer Kundenfakturen, die
*---- GTS-ueberleitungsrelevant
*---- Annahme: Zollanmeldung auf Basis Kundenfaktura bereits erstellt;
*---- erzeugen einer Proforma nicht sinnvoll - Doppelanlage
      IF NOT lr_vbeln_del IS INITIAL.
        DELETE ct_likp WHERE vbeln IN lr_vbeln_del.
        DESCRIBE TABLE ct_likp LINES sy-tfill.
        IF sy-tfill = 0.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

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
        AND ( vbtyp_n = vbtyp_prof      OR    " Pro-Forma
              vbtyp_n = vbtyp_fkiv_last OR    "IV Lastschrift
              vbtyp_n = vbtyp_fkiv_gut ).     "IV Gutschrift
  ENDIF.

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
    ENDLOOP.
    EXIT.
  ENDIF.

  IF lr_fkart IS INITIAL.
*-- Nur GTS-relevante Fakturen nachlesen
    SELECT * FROM /sapsll/tler3b
        INTO CORRESPONDING FIELDS OF TABLE lt_tler3b
          WHERE apevs_r3 = gc_application_level-invoice
            AND gcuma_r3 = gc_true.

    LOOP AT lt_tler3b INTO ls_tler3b.
      ls_fkart-sign   = 'I'.
      ls_fkart-option = 'EQ'.
      ls_fkart-low    = ls_tler3b-barvs_r3.
      APPEND ls_fkart TO lr_fkart.
    ENDLOOP.
  ENDIF.

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
  ENDIF.

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
      ENDIF.
    ENDLOOP.
  ENDLOOP.

*-- Lieferungen löschen, die bereits erledigte Fakturen besitzen
  IF NOT lr_vbeln_del IS INITIAL.
    DELETE ct_likp WHERE vbeln IN lr_vbeln_del.
  ENDIF.

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
  ENDLOOP.

ENDFORM.                    " likp_complete_filter


*&---------------------------------------------------------------------*
*&      Form  CONVERSION_EXIT_ALPHA_INPUT
*&---------------------------------------------------------------------*
*       Konvertierungs-Exit
*----------------------------------------------------------------------*
FORM conversion_exit_alpha_input
      USING    iv_input
      CHANGING cv_output.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = iv_input
    IMPORTING
      output = cv_output
    EXCEPTIONS
      OTHERS = 1.

  IF sy-subrc <> 0.
    CLEAR cv_output.
  ENDIF.

ENDFORM.                               " CONVERSION_EXIT_ALPHA_INPUT
