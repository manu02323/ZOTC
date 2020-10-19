*----------------------------------------------------------------------*
***INCLUDE /SAPSLL/LCUS_INV_INTACT_R3F03 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DELIVERY_DATA_SELECT
*&---------------------------------------------------------------------*
*       Selektion der Lieferungsdaten
*----------------------------------------------------------------------*
*      -->IT_DELVRY  Tabelle der Lieferungsnummern
*      <--CT_LIKP    Tabelle der Lieferungsköpfe
*      <--CT_LIPS    Tabelle der Lieferungspositionen
*      <--CT_VTTK    Tabelle der Transportköpfe
*      <--CT_VTTP    Tabelle der Transportpartner
*      <--CT_VBPA    Tabelle der Lieferungspartner
*      <--CT_EIKP    Tabelle der Aussenhandelsdaten Kopf
*----------------------------------------------------------------------*
FORM delivery_data_select  USING    it_delvry TYPE /sapsll/delvry_t
                           CHANGING ct_likp   TYPE /sapsll/likp_r3_t
                                    ct_lips   TYPE /sapsll/lips_r3_t
                                    ct_vttk   TYPE vttk_tab
                                    ct_vttp   TYPE vttp_tab
                                    ct_vbpa   TYPE tab_vbpa
                                    ct_eikp   TYPE /sapsll/eikp_r3_t.

  CHECK NOT it_delvry[] IS INITIAL.
  SELECT * FROM likp INTO TABLE ct_likp
           FOR ALL ENTRIES IN it_delvry
           WHERE vbeln = it_delvry-deliv_numb.
  CHECK NOT ct_likp[] IS INITIAL.
  SELECT * FROM lips INTO TABLE ct_lips
           FOR ALL ENTRIES IN ct_likp
           WHERE vbeln = ct_likp-vbeln.
  SELECT * FROM eikp INTO TABLE ct_eikp
           FOR ALL ENTRIES IN ct_likp
           WHERE exnum = ct_likp-exnum.
  SELECT * FROM vbpa INTO TABLE ct_vbpa
           FOR ALL ENTRIES IN ct_likp
           WHERE vbeln = ct_likp-vbeln.

ENDFORM.                    " DELIVERY_DATA_SELECT
*&---------------------------------------------------------------------*
*&      Form  CHECK_BILL_TYPE
*&---------------------------------------------------------------------*
*       Überprüfen bzw. ermitteln der Fakturaart
*----------------------------------------------------------------------*
*      <--CV_FKART  Fakturaart
*----------------------------------------------------------------------*
FORM check_bill_type  CHANGING cv_fkart.

  DATA: lt_tler3b TYPE TABLE OF /sapsll/tler3b.
  DATA: ls_tler3b TYPE /sapsll/tler3b.
  DATA: lt_tvfk   TYPE TABLE OF tvfk.
  DATA: ls_tvfk   TYPE tvfk.
  DATA: lv_lines  TYPE sytabix.
  DATA: BEGIN OF lt_tvfk_key OCCURS 0,
          fkart  TYPE fkart,
        END OF lt_tvfk_key.


  IF cv_fkart IS INITIAL.
    SELECT * FROM /sapsll/tler3b INTO TABLE lt_tler3b
             WHERE apevs_r3 = gc_application_level-invoice
             AND   gcuma_r3 = gc_true.
    IF NOT lt_tler3b IS INITIAL.
      LOOP AT lt_tler3b INTO ls_tler3b.
        lt_tvfk_key-fkart = ls_tler3b-barvs_r3.
        APPEND lt_tvfk_key.
      ENDLOOP.
    ENDIF.
    SELECT * FROM tvfk INTO TABLE lt_tvfk
             FOR ALL ENTRIES IN lt_tvfk_key
             WHERE fkart = lt_tvfk_key-fkart
             AND vbtyp   = 'U'.
    DESCRIBE TABLE lt_tvfk LINES lv_lines.
    IF lv_lines = 1.
      READ TABLE lt_tvfk INDEX 1 INTO ls_tvfk.
      cv_fkart = ls_tvfk-fkart.
    ENDIF.
  ENDIF.
  IF cv_fkart IS INITIAL.
    MESSAGE a228 RAISING invalid_bill_type.
  ENDIF.
  SELECT SINGLE * FROM tvfk INTO ls_tvfk
         WHERE fkart = cv_fkart.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE a229 WITH cv_fkart.
  ENDIF.
  IF ls_tvfk-vbtyp NE 'U'.
    MESSAGE a229 WITH cv_fkart.
  ENDIF.

ENDFORM.                    " CHECK_BILL_TYPE
