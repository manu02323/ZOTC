FUNCTION ZOTC0016_GET_DUNN_CUSTOMIZING.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MHNK) LIKE  MHNK STRUCTURE  MHNK
*"  EXPORTING
*"     VALUE(E_T001) LIKE  T001 STRUCTURE  T001
*"     VALUE(E_T047) LIKE  T047 STRUCTURE  T047
*"     VALUE(E_T047A) LIKE  T047A STRUCTURE  T047A
*"     VALUE(E_T047B) LIKE  T047B STRUCTURE  T047B
*"     VALUE(E_T047C) LIKE  T047C STRUCTURE  T047C
*"     VALUE(E_T047D) LIKE  T047D STRUCTURE  T047D
*"     VALUE(E_T047E) LIKE  T047E STRUCTURE  T047E
*"     VALUE(E_T047I) LIKE  T047I STRUCTURE  T047I
*"     VALUE(E_T056Z) LIKE  T056Z STRUCTURE  T056Z
*"     VALUE(E_T021M) LIKE  T021M STRUCTURE  T021M
*"  CHANGING
*"     VALUE(C_F150D) LIKE  F150D STRUCTURE  F150D
*"  EXCEPTIONS
*"      PARAM_ERROR_T001
*"      PARAM_ERROR_T047
*"      PARAM_ERROR_T047A
*"      PARAM_ERROR_T047B
*"      PARAM_ERROR_T047D
*"      PARAM_ERROR_T047E
*"--------------------------------------------------------------------
* declaration
  DATA: H_FORNR LIKE T047E-FORNR,
        H_LISTN LIKE T047E-LISTN,
        H_XAVIS LIKE T047E-XAVIS,
        H_ZLSCH LIKE T047E-ZLSCH.


* Get customizing first part
  CALL FUNCTION 'GET_DUNNING_CUSTOMIZING_SEL'
       EXPORTING
            I_BUKRS           = I_MHNK-BUKRS
            I_MAHNA           = I_MHNK-MAHNA
            I_MAHNS           = I_MHNK-MAHNS
       IMPORTING
            E_T001            = E_T001
            E_T047            = E_T047
            E_T047A           = E_T047A
            E_T047B           = E_T047B
       EXCEPTIONS
            PARAM_ERROR_T001  = 1
            PARAM_ERROR_T047  = 2
            PARAM_ERROR_T047A = 3
            PARAM_ERROR_T047B = 4
            OTHERS            = 5.
  CASE SY-SUBRC.
    WHEN '1'.
      RAISE PARAM_ERROR_T001.
    WHEN '2'.
      RAISE PARAM_ERROR_T047.
    WHEN '3'.
      RAISE PARAM_ERROR_T047A.
    WHEN '4'.
      RAISE PARAM_ERROR_T047B.
  ENDCASE.

* read dunning charges
  IF E_T047C IS REQUESTED.
    PERFORM READ_T047C USING    I_MHNK E_T001
                       CHANGING E_T047C C_F150D.
  ENDIF.

* determine the dunning print forms if applicable
  IF E_T047D IS REQUESTED OR E_T047E IS REQUESTED.
*   Determine Standard if Open FI failed
    IF NOT I_MHNK-GMVDT IS INITIAL.
      PERFORM READ_T047D USING    I_MHNK-KOART E_T047 E_T047A
                         CHANGING E_T047D.

      IF SY-SUBRC <> 0 OR E_T047D-FORNR = SPACE.
         MESSAGE E455 WITH E_T047A-MAHNR E_T047-RBUKM I_MHNK-KOART
                      RAISING PARAM_ERROR_T047D.
      ENDIF.
      MOVE-CORRESPONDING E_T047D TO E_T047E.
    ELSE.
      PERFORM READ_T047E USING    I_MHNK-KOART I_MHNK-SMABER
                                  I_MHNK-MAHNS E_T047 E_T047A
                         CHANGING E_T047E.

      IF SY-SUBRC <> 0 OR E_T047E-FORNR = SPACE.
        MESSAGE E456 WITH E_T047A-MAHNR E_T047-RBUKM I_MHNK-KOART
                     RAISING PARAM_ERROR_T047E.
      ENDIF.
      MOVE-CORRESPONDING E_T047E TO E_T047D.
    ENDIF.
*   Determine the form via open FI
    CALL FUNCTION 'OPEN_FI_PERFORM_00001030_P'
         EXPORTING
              I_MHNK  = I_MHNK
         CHANGING
              C_FORNR = E_T047E-FORNR
              C_LISTN = E_T047E-LISTN
              C_XAVIS = E_T047E-XAVIS
              C_ZLSCH = E_T047E-ZLSCH
         EXCEPTIONS
              OTHERS  = 0.
    E_T047D-FORNR = H_FORNR.
    E_T047D-LISTN = H_LISTN.
  ENDIF.

* Text elements for dunning
  IF E_T047I IS REQUESTED.
    PERFORM READ_T047I USING    I_MHNK-BUKRS I_MHNK-SMABER E_T047
                       CHANGING E_T047I.
  ENDIF.

* Dunning interest
  IF E_T056Z IS REQUESTED.
    PERFORM READ_T056Z USING    I_MHNK-VZSKZ I_MHNK-WAERS I_MHNK-AUSDT
                       CHANGING E_T056Z.
  ENDIF.

* MHND Sort variants
  IF E_T021M IS REQUESTED.
    PERFORM READ_T021M USING    E_T047-SMHND
                       CHANGING E_T021M.
  ENDIF.
ENDFUNCTION.

*&---------------------------------------------------------------------*
*&      Form  READ_T001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MHNK-BUKRS  text                                         *
*----------------------------------------------------------------------*
FORM READ_T001 USING I_BUKRS LIKE MHNK-BUKRS CHANGING E_T001 LIKE T001.
  SELECT SINGLE * FROM T001 INTO E_T001 WHERE BUKRS = I_BUKRS.
ENDFORM.                    " READ_T001
*&---------------------------------------------------------------------*
*&      Form  READ_T047A
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MHNK  text                                               *
*----------------------------------------------------------------------*
FORM READ_T047 USING I_BUKRS LIKE MHNK-BUKRS CHANGING E_T047 LIKE T047.
   SELECT SINGLE * FROM T047 INTO E_T047 WHERE BUKRS = I_BUKRS.
ENDFORM.                    " READ_T047A
*&---------------------------------------------------------------------*
*&      Form  READ_T047A
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MHNK  text                                               *
*----------------------------------------------------------------------*
FORM READ_T047A USING I_MAHNA LIKE MHNK-MAHNA
     CHANGING         E_T047A LIKE T047A.
   SELECT SINGLE * FROM T047A INTO E_T047A WHERE MAHNA = I_MAHNA.
ENDFORM.                    " READ_T047A
*&---------------------------------------------------------------------*
*&      Form  READ_T047B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MHNK  text                                               *
*----------------------------------------------------------------------*
FORM READ_T047B USING    I_MAHNA LIKE MHNK-MAHNA
                         I_MAHNS LIKE MHNK-MAHNS
                CHANGING E_T047B LIKE T047B.
   SELECT SINGLE * FROM T047B INTO E_T047B
                              WHERE MAHNA = I_MAHNA
                              AND   MAHNS = I_MAHNS.
ENDFORM.                    " READ_T047B
*&---------------------------------------------------------------------*
*&      Form  READ_T047C
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MHNK  text                                               *
*      -->P_CAHNGING  text                                             *
*      -->P_T047C  text                                                *
*----------------------------------------------------------------------*
FORM READ_T047C USING    I_MHNK  LIKE MHNK
                         I_T001  LIKE T001
                CHANGING E_T047C LIKE T047C
                         E_F150D LIKE F150D.
  DATA:
     REFE(8)    TYPE P.

*------- Mahngebuehren
  E_F150D-MHNGH = 0.
  E_F150D-MHNGF = 0.
  CLEAR E_T047C.
  SELECT * INTO *T047C FROM T047C
  WHERE MAHNA = I_MHNK-MAHNA
  AND   MAHNS = I_MHNK-MAHNS
  AND   WAERS = I_MHNK-WAERS.
    IF I_MHNK-FAEBT >= *T047C-MAHNB.
      E_T047C = *T047C.
      IF E_T047C-MAHNP NE 0.             "Mahngebuehr in %
        E_T047C-MAHNG = I_MHNK-FAEBT * E_T047C-MAHNP / 10000.
      ENDIF.
    ELSE.
      EXIT.
    ENDIF.
  ENDSELECT.

*------- Zweiter Versuch mit Hauswaehrung
  IF SY-SUBRC NE 0.
    SELECT * INTO *T047C FROM T047C
    WHERE MAHNA = I_MHNK-MAHNA
    AND   MAHNS = I_MHNK-MAHNS
    AND   WAERS = I_T001-WAERS.
      IF I_MHNK-FAEHW >= *T047C-MAHNB.
        E_T047C = *T047C.
        IF E_T047C-MAHNP NE 0.           "Mahngebuehr in %
          E_T047C-MAHNG = I_MHNK-FAEHW * E_T047C-MAHNP / 10000.
        ENDIF.
      ELSE.
        EXIT.
      ENDIF.
    ENDSELECT.
  ENDIF.

*------- Waehrungsumrechnung -----------------------------------------*
  IF E_T047C-MAHNG NE 0.
    IF E_T047C-WAERS NE I_T001-WAERS.
      E_F150D-MHNGF = E_T047C-MAHNG.
      REFE = E_T047C-MAHNG.
      CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
           EXPORTING
                LOCAL_CURRENCY   = I_T001-WAERS
                FOREIGN_CURRENCY = E_T047C-WAERS
                FOREIGN_AMOUNT   = REFE
                DATE             = I_MHNK-AUSDT
           IMPORTING
                LOCAL_AMOUNT     = E_F150D-MHNGH.
    ELSE.
      E_F150D-MHNGH = E_T047C-MAHNG.
      E_F150D-MHNGF = E_T047C-MAHNG.
    ENDIF.
    IF I_MHNK-WAERS NE E_T047C-WAERS.
      REFE = E_T047C-MAHNG.
      CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
           EXPORTING
                LOCAL_CURRENCY   = I_T001-WAERS
                FOREIGN_CURRENCY = I_MHNK-WAERS
                LOCAL_AMOUNT     = REFE
                DATE             = I_MHNK-AUSDT
           IMPORTING
                FOREIGN_AMOUNT   = E_F150D-MHNGF.
      E_T047C-WAERS = I_MHNK-WAERS.
      E_T047C-MAHNG = E_F150D-MHNGF.
    ENDIF.
  ENDIF.
ENDFORM.                    " READ_T047C
*&---------------------------------------------------------------------*
*&      Form  READ_T056Z
*&---------------------------------------------------------------------*
*       Reading the interest information
*----------------------------------------------------------------------*
*      -->P_I_MHNK  text                                               *
*      <--P_T056Z  text                                                *
*----------------------------------------------------------------------*
FORM READ_T056Z USING    I_VZSKZ LIKE MHNK-VZSKZ
                         I_WAERS LIKE MHNK-WAERS
                         I_AUSDT LIKE MHNK-AUSDT
                CHANGING E_T056Z LIKE T056Z.

  DATA:
    BEGIN OF DATH,
      NUM(8)   TYPE N,
    END OF DATH.
  IF I_VZSKZ NE SPACE.
    T056Z-VZSKZ = I_VZSKZ.
    T056Z-WAERS = I_WAERS.
    DATH = I_AUSDT.
    DATH-NUM = 99999999 - DATH-NUM.
    T056Z-DATAB      = DATH.
    READ TABLE T056Z SEARCH FKGE. E_T056Z = T056Z.
    IF SY-SUBRC NE 0
    OR E_T056Z-VZSKZ NE I_VZSKZ
    OR E_T056Z-WAERS NE I_WAERS.
       T056Z-WAERS = SPACE.
       t056z-vzskz = i_vzskz.
       t056z-datab = dath.
       READ TABLE T056Z SEARCH FKGE. E_T056Z = T056Z.
       IF SY-SUBRC NE 0
         OR E_T056Z-VZSKZ NE I_VZSKZ
         OR E_T056Z-WAERS NE space.
         CLEAR E_T056Z.
       ENDIF.
    ENDIF.
  ELSE.
    CLEAR E_T056Z.
  ENDIF.
ENDFORM.                    " READ_T056Z

*&---------------------------------------------------------------------*
*&      Form  READ_T047D
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MHNK  text                                               *
*      -->P_T047  text                                                 *
*      -->P_T047A  text                                                *
*      <--P_T047D  text                                                *
*----------------------------------------------------------------------*
FORM READ_T047D USING    I_KOART  LIKE MHNK-KOART
                         I_T047  LIKE T047
                         I_T047A LIKE T047A
                CHANGING E_T047D LIKE T047D.

   SELECT SINGLE * FROM  T047D INTO   E_T047D
                               WHERE  MAHNR  = I_T047A-MAHNR
                               AND    RBUKM  = I_T047-RBUKM
                               AND    KOART  = I_KOART.
   IF E_T047D-LISTN IS INITIAL AND SY-SUBRC = 0.
      E_T047D-LISTN = 'LIST1S'.
   ENDIF.
ENDFORM.                    " READ_T047D

*&---------------------------------------------------------------------*
*&      Form  READ_T047E
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MHNK  text                                               *
*      -->P_T047  text                                                 *
*      -->P_T047A  text                                                *
*      <--P_T047E  text                                                *
*----------------------------------------------------------------------*
FORM READ_T047E USING    I_KOART  LIKE MHNK-KOART
                         I_SMABER LIKE MHNK-SMABER
                         I_MAHNS  LIKE MHNK-MAHNS
                         I_T047   LIKE T047
                         I_T047A  LIKE T047A
                CHANGING E_T047E  LIKE T047E.
   SELECT SINGLE * FROM  T047E INTO E_T047E
          WHERE  MAHNR       = I_T047A-MAHNR
          AND    RBUKM       = I_T047-RBUKM
          AND    KOART       = I_KOART
          AND    MABER       = I_SMABER
          AND    MAHNS       = I_MAHNS.
   IF SY-SUBRC <> 0.
     SELECT SINGLE * FROM  T047E INTO E_T047E
            WHERE  MAHNR       = I_T047A-MAHNR
            AND    RBUKM       = I_T047-RBUKM
            AND    KOART       = I_KOART
            AND    MABER       = SPACE
            AND    MAHNS       = I_MAHNS.
   ENDIF.
   IF E_T047E-LISTN IS INITIAL AND SY-SUBRC = 0.
      E_T047E-LISTN = 'LIST1S'.
   ENDIF.
ENDFORM.                    " READ_T047E

*&---------------------------------------------------------------------*
*&      Form  READ_T047I
*&---------------------------------------------------------------------*
*       variable Formulartexte
*----------------------------------------------------------------------*
*      -->P_I_MHNK  text                                               *
*      <--P_T047I  text                                                *
*----------------------------------------------------------------------*
FORM READ_T047I USING    I_BUKRS  LIKE MHNK-BUKRS
                         I_SMABER LIKE MHNK-SMABER
                         I_T047  LIKE T047
                CHANGING E_T047I LIKE T047I.
  CLEAR E_T047I.
  IF I_T047-XMABE = 'X'.
    SELECT SINGLE * FROM T047I INTO E_T047I
                               WHERE BUKRS = I_BUKRS
                               AND   MABER = I_SMABER.
  ENDIF.
  IF SY-SUBRC <> 0 OR i_T047-XMABE  = SPACE.
    SELECT SINGLE * FROM T047I INTO E_T047I
                               WHERE BUKRS = I_BUKRS
                               AND   MABER = SPACE.
  ENDIF.
ENDFORM.                    " READ_T047I
*&---------------------------------------------------------------------*
*&      Form  READ_T021M
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_T047_SMHND  text                                         *
*      <--P_E_T021M  text                                              *
*----------------------------------------------------------------------*
FORM READ_T021M USING    I_SMHND LIKE T047-SMHND
                CHANGING E_T021M LIKE T021M.
  CLEAR E_T021M.
  SELECT SINGLE * FROM  T021M INTO E_T021M
                              WHERE  PROGN       = 'SAPF150D'
                              AND    ANWND       = 'MHND'
                              AND    SRVAR       = I_SMHND.
ENDFORM.                    " READ_T021M
