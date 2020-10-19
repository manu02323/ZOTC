*----------------------------------------------------------------------*
***INCLUDE LF150F0L .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LOCK_MHNK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_C_MHNK  text                                               *
*----------------------------------------------------------------------*
FORM LOCK_MHNK USING I_MHNK LIKE MHNK.

* lock the actuall mhnk entry
  CALL FUNCTION 'ENQUEUE_EMHNK'
       EXPORTING
            LAUFD          = I_MHNK-LAUFD
            LAUFI          = I_MHNK-LAUFI
            KOART          = I_MHNK-KOART
            BUKRS          = I_MHNK-BUKRS
            KUNNR          = I_MHNK-KUNNR
            LIFNR          = I_MHNK-LIFNR
            CPDKY          = I_MHNK-CPDKY
            SKNRZE         = I_MHNK-SKNRZE
            SMABER         = I_MHNK-SMABER
            SMAHSK         = I_MHNK-SMAHSK
       EXCEPTIONS
            FOREIGN_LOCK   = 1
            SYSTEM_FAILURE = 2
            OTHERS         = 3.
  CASE SY-SUBRC.
    WHEN 1.
      MESSAGE E482 WITH F150V-BUSAB.
    WHEN 2.
      MESSAGE E149(F0).
    WHEN 3.
      MESSAGE E149(F0).
  ENDCASE.
ENDFORM.                    " LOCK_MHNK
