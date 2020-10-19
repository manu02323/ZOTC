*&---------------------------------------------------------------------*
*& Title: Adapt the billing relevance to current customizing           *
*&---------------------------------------------------------------------*
REPORT ZZFKREL0.

TABLES: VBAP, TVAP.

DATA: XTVAP LIKE TVAP OCCURS 0 WITH HEADER LINE,
      UPDATED.

SELECT-OPTIONS: VBELN FOR VBAP-VBELN MEMORY ID AUN,
                PSTYV FOR VBAP-PSTYV DEFAULT 'TAS'.

PARAMETERS: CHCKONLY AS CHECKBOX DEFAULT 'X'.

SELECT * FROM TVAP INTO TABLE XTVAP WHERE PSTYV IN PSTYV.
SORT XTVAP.

IF CHCKONLY EQ SPACE.
  WRITE: / 'Update mode - database update will be performed.'.
ELSE.
  WRITE: / 'Display mode - no database update will be performed.'.
ENDIF.


SELECT * FROM VBAP WHERE VBELN IN VBELN
                     AND PSTYV IN PSTYV.
  IF XTVAP-PSTYV NE VBAP-PSTYV.
    READ TABLE XTVAP WITH KEY PSTYV = VBAP-PSTYV BINARY SEARCH.
  ENDIF.
  IF XTVAP-FKREL NE VBAP-FKREL.
    WRITE: / VBAP-VBELN, VBAP-POSNR, VBAP-MATNR, VBAP-FKREL, '->',
             XTVAP-FKREL.
    IF CHCKONLY = SPACE.
      VBAP-FKREL = XTVAP-FKREL.
      UPDATE VBAP.
      UPDATED = 'X'.
    ENDIF.
  ENDIF.
ENDSELECT.

IF UPDATED = 'X'.
  MESSAGE I999(V1) WITH 'Now start report SDVBUK00 to update status!'.
ENDIF.
