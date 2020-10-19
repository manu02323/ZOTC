*-------------------------------------------------------------------
***INCLUDE LF150F0D .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  DETERMINE_MIN_AMOUNTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_MHNK_EXT-MAHNA  text                                     *
*      -->P_H_MAHSK  text                                              *
*      -->P_I_T001-WAERS  text                                         *
*      -->P_E_MHNK_EXT-WAERS  text                                     *
*      <--P_H_MINHW  text                                              *
*      <--P_H_MINFW  text                                              *
*----------------------------------------------------------------------*
FORM DETERMINE_MIN_AMOUNTS TABLES   T_T047H  STRUCTURE T047H
                           USING    I_SALHW  LIKE MHNK_EXT-SALHW
                                    I_SALFW  LIKE MHNK_EXT-SALDO
                                    I_MAHNA  LIKE MHNK_EXT-MAHNA
                                    I_MAHNS  LIKE MHNK_EXT-MAHNS
                                    I_HWAERS LIKE T001-WAERS
                                    I_FWAERS LIKE MHNK_EXT-WAERS
                           CHANGING E_MINHW  LIKE LSUMTAB-DMSHB
                                    E_MINFW  LIKE LSUMTAB-WRSHB
                                    E_MINHWP LIKE LSUMTAB-DMSHB
                                    E_MINFWP LIKE LSUMTAB-WRSHB.

* init the output fields
  E_MINFW  = 0.
  E_MINFWP = 0.
  E_MINHW  = 0.
  E_MINHWP = 0.

  if i_fwaers <> space.                           "1133338
*   determine min amount for transaction currency
  READ TABLE T_T047H WITH KEY MAHNA = I_MAHNA
                              WAERS = I_FWAERS
                              MAHNS = I_MAHNS.
  endif.                                          "1133338
  IF SY-SUBRC <> 0 or i_fwaers = space.           "1133338
*   second guess determine min amount for company transaction
    IF I_HWAERS <> I_FWAERS.
      READ TABLE T_T047H WITH KEY MAHNA = I_MAHNA
                                  WAERS = I_HWAERS
                                  MAHNS = I_MAHNS.

      IF SY-SUBRC = 0.
        E_MINHW  = T_T047H-MINBT.
        E_MINHWP = I_SALHW * T_T047H-MINPR / 10000.
      ENDIF.
    ENDIF.
  ELSE.
    E_MINFW  = T_T047H-MINBT.
    E_MINFWP = I_SALFW * T_T047H-MINPR / 10000.
  ENDIF.

ENDFORM.                    " DETERMINE_MIN_AMOUNTS

*&---------------------------------------------------------------------*
*&      Form  DETERMINE_MIN_INTEREST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_MHNK_EXT-MAHNA  text                                     *
*      -->P_H_MAHSK  text                                              *
*      -->P_I_T001-WAERS  text                                         *
*      -->P_E_MHNK_EXT-WAERS  text                                     *
*      <--P_H_MINHW  text                                              *
*      <--P_H_MINFW  text                                              *
*----------------------------------------------------------------------*
FORM DETERMINE_MIN_INTEREST TABLES   T_T047H  STRUCTURE T047H
                            USING    I_MAHNA  LIKE MHNK_EXT-MAHNA
                                     I_MAHNS  LIKE MHNK_EXT-MAHNS
                                     I_HWAERS LIKE T001-WAERS
                                     I_FWAERS LIKE MHNK_EXT-WAERS
                            CHANGING E_MINZHW LIKE LSUMTAB-DMSHB
                                     E_MINZFW LIKE LSUMTAB-WRSHB.

* init the output fields
  E_MINZHW = 0.
  E_MINZFW = 0.

* determine min amount for transaction currency
  READ TABLE T_T047H WITH KEY MAHNA = I_MAHNA
                              WAERS = I_FWAERS
                              MAHNS = I_MAHNS.

*  select single * from  t047h where  mahna = i_mahna
*                              and    waers = i_fwaers
*                              and    mahns = i_mahns.
  IF SY-SUBRC <> 0.
*   second guess determine min amount for company transaction
    IF I_HWAERS <> I_FWAERS.
      READ TABLE T_T047H WITH KEY MAHNA = I_MAHNA
                                  WAERS = I_HWAERS
                                  MAHNS = I_MAHNS.

*      select single * from  t047h where  mahna = i_mahna
*                                  and    waers = i_hwaers
*                                  and    mahns = i_mahns.
      IF SY-SUBRC = 0.
        E_MINZHW = T_T047H-MINZS.
      ENDIF.
    ENDIF.
  ELSE.
    E_MINZFW = T_T047H-MINZS.
  ENDIF.

ENDFORM.                    " DETERMINE_MIN_INTEREST
*&---------------------------------------------------------------------*
*&      Form  DETERMINE_INTEREST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_MHND_EXT-WAERS  text                                     *
*      -->P_E_MHNK_EXT-VZSKZ  text                                     *
*      -->P_I_AUSDT  text                                              *
*      <--P_E_MHND_EXT-ZINSS  text                                     *
*      <--P_E_MHND_EXT-ZINST  text                                     *
*      <--P_E_MHND_EXT-WZSBT  text                                     *
*      <--P_E_MHND_EXT-ZSBTR  text                                     *
*----------------------------------------------------------------------*
FORM DETERMINE_INTEREST USING    I_AUSDT    LIKE F150V-AUSDT
                                 I_MHNK_EXT LIKE MHNK_EXT
                                 I_MHND_EXT LIKE MHND_EXT
                        CHANGING E_ZINSS LIKE MHND_EXT-ZINSS
                                 E_ZINST LIKE MHND_EXT-ZINST
                                 E_WZSBT LIKE MHND_EXT-WZSBT
                                 E_ZSBTR LIKE MHND_EXT-ZSBTR.
* declaration
  DATA:    H_REF1(16) TYPE P.
  DATA:    BEGIN OF DATH,
            NUM(8)       TYPE N,        "Zum Rechnen mit Datuemern
          END OF DATH.

* read interest customizing
  T056Z-VZSKZ = I_MHNK_EXT-VZSKZ.
  t056z-waers = i_mhnd_ext-waers.
  DATH = I_AUSDT.
  DATH-NUM = 99999999 - DATH-NUM.
  T056Z-DATAB      = DATH.
  READ TABLE T056Z SEARCH FKGE.
  IF SY-SUBRC NE 0
  or t056z-waers ne i_mhnd_ext-waers
  OR T056Z-VZSKZ NE I_MHNK_EXT-VZSKZ.
    T056Z-WAERS = SPACE.
    T056Z-VZSKZ = I_MHNK_EXT-VZSKZ.
    T056Z-DATAB = DATH.
    READ TABLE T056Z SEARCH FKGE.
    IF SY-SUBRC NE 0 OR T056Z-VZSKZ NE I_MHNK_EXT-VZSKZ
                     OR T056Z-WAERS NE SPACE.
*   no interst calc procedure found for the data
      IF 0 = 1. MESSAGE S836. ENDIF.
    perform log_msg using '836' i_mhnk_ext-vzskz i_mhnd_ext-waers
                                  SPACE SPACE.
      EXIT.
    ENDIF.
  ENDIF.
*   determine interest foreign currency
    IF I_MHND_EXT-SHKZG = 'S'.
      E_ZINSS = T056Z-ZINSO.
    ELSE.
      E_ZINSS = T056Z-ZINHA.
    ENDIF.
    H_REF1 = I_MHND_EXT-WRSHB * E_ZINSS.
    H_REF1 = H_REF1 * I_MHND_EXT-VERZN.
    E_WZSBT = H_REF1 / 36000000.      "360*1000*100
    CALL FUNCTION 'ROUND_AMOUNT'
         EXPORTING
              COMPANY    = I_MHND_EXT-BUKRS
              CURRENCY   = I_MHND_EXT-WAERS
              AMOUNT_IN  = E_WZSBT
         IMPORTING
              AMOUNT_OUT = E_WZSBT.

*  conversion to company currency
   call function 'CONVERT_TO_LOCAL_CURRENCY'
        exporting
          date             = i_mhnk_ext-ausdt
          foreign_amount   = e_wzsbt
          foreign_currency = i_mhnd_ext-waers
          local_currency   = i_mhnk_ext-hwaers
        importing
          local_amount     = e_zsbtr.

    E_ZINST = I_MHND_EXT-VERZN.

ENDFORM.                    " DETERMINE_INTEREST
