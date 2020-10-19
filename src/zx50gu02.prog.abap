************************************************************************
* triangular deal VE01: set plant country
************************************************************************

CONSTANTS: zz_tri_country LIKE t005-land1 VALUE 'IT'. "<-- country code

IF i_country        EQ zz_tri_country AND     "reporting country
   i_reporting_type EQ 'I'            AND     "Intrastat
   i_direction      EQ '2'            AND     "dispatch
   i_sd_invoice_header-vbtyp NA '56'.         "no internal invoice
  IF c_record_intrastat-werksland NE zz_tri_country.
    c_record_intrastat-werksland = zz_tri_country.
  ENDIF.
ENDIF.

*&---------------------------------------------------------------------*
*&  Include           ZX50GU02
*&---------------------------------------------------------------------*
