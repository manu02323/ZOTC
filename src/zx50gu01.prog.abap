************************************************************************
* triangular deal VI98: set inclusion indicator
************************************************************************

CONSTANTS: zz_tri_country LIKE t005-land1 VALUE 'IT', "<-- country code
           zz_incl LIKE eipo-segal VALUE 'IN'. "<-- inclusion indicator

DATA: zz_shipto_country LIKE t005-land1.
DATA: selection         LIKE addr1_sel.
TABLES: vbpa, t001w, sadr, kna1.

IF i_country        EQ zz_tri_country AND     "reporting country
   i_reporting_type EQ 'I'            AND     "Intrastat
   i_direction      EQ '1'            AND     "arrival
   c_sd_invoice_header-vbtyp EQ '5'.          "internal invoice

* read country of plant
  SELECT SINGLE * FROM t001w
                 WHERE werks EQ c_sd_invoice_line_item-werks.
  IF sy-subrc EQ 0.
*   check: delivering country = EU country?
    SELECT SINGLE COUNT(*) FROM t005
                          WHERE land1 EQ t001w-land1
                            AND xegld NE space.
  ENDIF.

*-- determine ship-to party
  IF sy-subrc = 0.
*   ... from billing document
    SELECT SINGLE * FROM vbpa
                   WHERE vbeln = c_sd_invoice_header-vbeln
                     AND posnr = '000000'
                     AND parvw = 'WE'.
    IF sy-subrc NE 0.
      SELECT SINGLE * FROM vbpa
                     WHERE vbeln = c_sd_invoice_header-vbeln
                       AND posnr = c_sd_invoice_line_item-posnr
                       AND parvw = 'WE'.
    ENDIF.
*   ...from preceding document
    IF sy-subrc NE 0.
      SELECT SINGLE * FROM vbpa
                     WHERE vbeln = c_sd_invoice_line_item-vgbel
                       AND posnr = '000000'
                       AND parvw = 'WE'.
      IF sy-subrc NE 0.
        SELECT SINGLE * FROM vbpa
                       WHERE vbeln = c_sd_invoice_line_item-vgbel
                         AND posnr = c_sd_invoice_line_item-posnr
                         AND parvw = 'WE'.
      ENDIF.
    ENDIF.

*-- determine country of ship-to party
    IF sy-subrc EQ 0.
      IF NOT vbpa-adrnr IS INITIAL.
        selection-addrnumber = vbpa-adrnr.
        CALL FUNCTION 'ADDR_GET'
          EXPORTING
            address_selection = selection
            address_group     = 'BP'
          IMPORTING
            sadr              = sadr
          EXCEPTIONS
            parameter_error   = 1
            address_not_exist = 2
            version_not_exist = 3
            internal_error    = 4
            OTHERS            = 5.
        IF sy-subrc EQ 0.
          zz_shipto_country = sadr-land1.
        ENDIF.
      ELSE.
        SELECT SINGLE land1 INTO zz_shipto_country
                 FROM kna1 WHERE kunnr EQ vbpa-kunnr.
      ENDIF.
    ENDIF.

*-- check: ship-to country = EU country?
    IF sy-subrc EQ 0.
      SELECT SINGLE COUNT(*) FROM t005
                            WHERE land1 EQ zz_shipto_country
                              AND xegld NE space.
      IF sy-subrc EQ 0.
*       check: 3 different countries?
        IF zz_shipto_country NE i_country   AND
           zz_shipto_country NE t001w-land1 AND
           i_country         NE t001w-land1.
          c_foreign_trade_line_item-segal = zz_incl.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.
ENDIF.
*&---------------------------------------------------------------------*
*&  Include           ZX50GU01
*&---------------------------------------------------------------------*
