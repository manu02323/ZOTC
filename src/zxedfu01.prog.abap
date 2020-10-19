*&---------------------------------------------------------------------*
*&  Include           ZXEDFU01
*&---------------------------------------------------------------------*
* Oss note 659590 - EDI: Stock transfer and cross-company sales
CHECK dvbdkr-vbtyp CA '56'.

READ TABLE dtvbdpr INDEX 1.

IF dtvbdpr-autyp EQ 'V'.
  control_record_out-mescod = 'MM'.
ELSE.
  control_record_out-mescod = 'FI'.
ENDIF.
