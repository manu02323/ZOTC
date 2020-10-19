*&---------------------------------------------------------------------*
*& Report ZZCORR_SITKZ1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZZCORR_SITKZ1.

TABLES: LIPS, LIKP.

SELECT-OPTIONS: I_VBELN FOR LIKP-VBELN MATCHCODE OBJECT VMVL
                                       MEMORY ID VL.

SELECT * FROM LIPS WHERE VBELN IN I_VBELN
                     AND BWART = '687'
                     AND SITKZ = ' '.
  IF LIPS-KZPOD IS INITIAL.
    LIPS-KZPOD = 'X'.
  ENDIF.
  LIPS-SITKZ = '3'.
  UPDATE LIPS.
  WRITE: / 'LIPS-SITKZ has been updated for delivery item', LIPS-VBELN, LIPS-POSNR.
ENDSELECT.
