*-------------------------------------------------------------------
***INCLUDE LF150F0G .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  GET_MASTER_DATA_CUSTOMER
*&---------------------------------------------------------------------*
*       determine the necessary customer information
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_MASTER_DATA_CUSTOMER TABLES   T_KNB5   STRUCTURE KNB5
                                       T_LFB5   STRUCTURE LFB5
                                       T_FLDTAB STRUCTURE IFLDTAB
                                       T_BUKRS  STRUCTURE BUKRS_SEL
                              USING    I_BUKRS    LIKE T001-BUKRS
                                       I_KUNNR    LIKE KNA1-KUNNR
                                       I_CHECKS   LIKE CHECKS
                              CHANGING E_VFM_KNXX LIKE VFM_KNXX
                                       E_VFM_LFXX LIKE VFM_LFXX
                                       E_KNB5     LIKE KNB5
                                       E_LFB5     LIKE LFB5
                                       E_LIFNR    LIKE LFA1-LIFNR
                                       E_KOART    LIKE MHNK_EXT-KOART
                                       E_MAHNA    LIKE VFM_KNXX-MAHNA
                                       E_DUNN_IT  LIKE BOOLE-BOOLE.
* declaration
  DATA: ERR        LIKE SY-SUBRC.

  E_DUNN_IT = 'X'.
  E_LIFNR   = SPACE.
  E_KOART   = 'D'.

* log the beginning of all dunning activities
  IF 0 = 1. MESSAGE S796. ENDIF.
  PERFORM LOG_MSG USING '796' SPACE SPACE SPACE SPACE.
  IF 0 = 1. MESSAGE S801. ENDIF.
  PERFORM LOG_MSG USING '801' E_KOART I_KUNNR I_BUKRS SPACE.
  PERFORM LOG_MSG USING '819' SPACE SPACE SPACE SPACE.

* get the dunning view for the customer
  SELECT SINGLE * FROM VFM_KNXX INTO E_VFM_KNXX
                                WHERE KUNNR = I_KUNNR
                                AND   BUKRS = I_BUKRS
                                AND   MABER = SPACE.
  ERR = ERR + SY-SUBRC.
  IF SY-SUBRC = 0.
    E_MAHNA = E_VFM_KNXX-MAHNA.
*   get the dunning master data for all dunning areas
    SELECT * FROM  KNB5 INTO TABLE T_KNB5
                        WHERE  KUNNR  = I_KUNNR
                        AND    BUKRS IN T_BUKRS.
    ERR = ERR + SY-SUBRC.
    if not i_bukrs in t_bukrs.
       select * from knb5 appending table t_knb5
                        where kunnr = i_kunnr
                        and   bukrs = i_bukrs.
       ERR = ERR + SY-SUBRC.
    endif.


*   get the default knb5 entry
    READ TABLE T_KNB5 INTO E_KNB5
                      WITH KEY BUKRS = I_BUKRS
                               KUNNR = I_KUNNR
                               MABER = SPACE.
    ERR = ERR + SY-SUBRC.

*   in case of vendor clearing get all vendor dunning master data
    IF E_VFM_KNXX-XVERR = 'X' AND E_VFM_KNXX-LIFNR <> SPACE.
      E_LIFNR = E_VFM_KNXX-LIFNR.

*     log the customer vendor clearing
      IF 0 = 1. MESSAGE S802. ENDIF.
      PERFORM LOG_MSG USING '802' E_KOART I_KUNNR
                                  'K' E_VFM_KNXX-LIFNR.

*     get the dunning view for the vendor
      SELECT SINGLE * FROM VFM_LFXX INTO E_VFM_LFXX
                                    WHERE LIFNR = E_VFM_KNXX-LIFNR
                                    AND   BUKRS = I_BUKRS
                                    AND   MABER = SPACE.

      SELECT * FROM  LFB5 INTO TABLE T_LFB5
                          WHERE  LIFNR = E_VFM_KNXX-LIFNR
                          AND    BUKRS IN T_BUKRS.

*     get the default knb5 entry
      READ TABLE T_LFB5 INTO E_LFB5
                        WITH KEY BUKRS = I_BUKRS
                                 LIFNR = E_VFM_KNXX-LIFNR
                                 MABER = SPACE.

*     check the clearing if clearing is allowed
      PERFORM CHECK_CLEARING  TABLES    T_KNB5  T_LFB5
                             USING    E_KOART
                             CHANGING E_VFM_KNXX E_VFM_LFXX.

    ENDIF.
  ENDIF.

  IF ERR <> 0.
    IF 0 = 1. MESSAGE S725. ENDIF.
    PERFORM LOG_MSG USING '725' E_KOART I_KUNNR SPACE SPACE.
    E_DUNN_IT = SPACE.
  ELSE.
    IF I_CHECKS-C_KNA1 = 'X'.
      SELECT SINGLE * FROM  KNA1 WHERE  KUNNR = I_KUNNR.
      PERFORM CHECK_FIELD TABLES   T_FLDTAB
                          USING    'KNA1'
                          CHANGING E_DUNN_IT.
    ENDIF.
    IF I_CHECKS-C_KNB1 = 'X' AND E_DUNN_IT = 'X'.
      SELECT SINGLE * FROM  KNB1 WHERE  KUNNR = I_KUNNR
                          AND    BUKRS = I_BUKRS.
      PERFORM CHECK_FIELD TABLES   T_FLDTAB
                          USING    'KNB1'
                          CHANGING E_DUNN_IT.
    ENDIF.
    IF E_DUNN_IT = SPACE.
      IF 0 = 1. MESSAGE S837. ENDIF.
      PERFORM LOG_MSG USING '837' E_KOART I_KUNNR SPACE SPACE.
    ENDIF.
  ENDIF.

* check additional fields
* if check failed
* h_dunn_it = space
* message
*...

ENDFORM.                    " GET_MASTER_DATA_CUSTOMER
*&---------------------------------------------------------------------*
*&      Form  GET_OPEN_ITEMS_CUSTOMER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHND  text                                               *
*      -->P_I_GRDAT  text                                              *
*      -->P_E_VFM_KNXX  text                                           *
*----------------------------------------------------------------------*
FORM GET_OPEN_ITEMS_CUSTOMER TABLES   T_MHND_EXT STRUCTURE MHND_EXT
                                      T_FLDTAB   STRUCTURE IFLDTAB
                                      T_KNB5     STRUCTURE KNB5
                                      T_LFB5     STRUCTURE LFB5
                                      T_T047R    STRUCTURE T047R
                                      T_BUKRS    STRUCTURE BUKRS_SEL
                             USING    I_GRDAT    LIKE F150V-GRDAT
                                      I_VFM_KNXX LIKE VFM_KNXX
                                      I_CHECKS   LIKE CHECKS
                                      i_t001     like t001
                             CHANGING E_HAS_ITEMS LIKE BOOLE-BOOLE.
* declaration
  DATA: H_COUNT   LIKE SY-TABIX,
        H_DUNN_IT LIKE BOOLE-BOOLE,
        KONTO(15) TYPE C,
        T_BSID    LIKE BSID OCCURS 10 WITH HEADER LINE,
        T_BSIK    LIKE BSIK OCCURS 10 WITH HEADER LINE,
        e_t001_cc LIKE t001.                                    "1486637



* get the open items and copy into mhnd
  SELECT * FROM BSID INTO   TABLE T_BSID
                       WHERE  BUKRS IN T_BUKRS
                       AND    KUNNR =  I_VFM_KNXX-KUNNR
                       AND    BUDAT <= I_GRDAT
                       and hkont in r_hkont.

  LOOP AT T_BSID.
*   save the work area
    BSID = T_BSID.

*   check the additional fields for items
    H_DUNN_IT = 'X'.
    IF I_CHECKS-C_KNB5 = 'X'.
      READ TABLE T_KNB5   INTO KNB5    WITH KEY KUNNR = I_VFM_KNXX-KUNNR
                                 BUKRS = I_VFM_KNXX-BUKRS
                                 MABER = BSID-MABER.
* XOW eingefügt: into knb5
      IF SY-SUBRC = 4.
         READ TABLE T_KNB5 INTO KNB5 WITH KEY KUNNR = I_VFM_KNXX-KUNNR
                                              BUKRS = I_VFM_KNXX-BUKRS
                                              MABER = SPACE.
      ENDIF.
      IF SY-SUBRC = 0.
        PERFORM CHECK_FIELD TABLES   T_FLDTAB
                           USING    'KNB5'
                           CHANGING H_DUNN_IT.
      ENDIF.
    ENDIF.
    IF I_CHECKS-C_BSID = 'X' AND H_DUNN_IT = 'X'.
      PERFORM CHECK_FIELD TABLES   T_FLDTAB
                          USING    'BSID'
                          CHANGING H_DUNN_IT.

    ENDIF.
    IF H_DUNN_IT = 'X'.
*     init the structure
      CLEAR T_MHND_EXT.
*     assign values
      T_MHND_EXT-BKOART = 'D'.
      MOVE-CORRESPONDING BSID TO T_MHND_EXT.
      if bsid-xanet ='X' and bsid-umskz = 'F'.
        t_mhnd_ext-dmbtr = bsid-dmbtr + bsid-mwsts.
        t_mhnd_ext-wrbtr = bsid-wrbtr + bsid-wmwst.
      endif.
*     assign the bukrs for inter-cc dunning
      T_MHND_EXT-BUKRS  = I_VFM_KNXX-BUKRS.
      T_MHND_EXT-BBUKRS = BSID-BUKRS.

*     check currency for inter-cc dunning and in case of        "1486637
*     different cc-Currenies calculate amounts in local         "1486637
*     currency of dunning CC                                    "1486637
      IF T_MHND_EXT-BUKRS NE T_MHND_EXT-BBUKRS.                 "1486637
         PERFORM READ_T001 USING T_MHND_EXT-BBUKRS CHANGING e_T001_cc.
         IF i_t001-WAERS NE e_T001_cc-waers.                    "1486637
           if bsid-waers = i_t001-WAERS.         " change values in cc-currency
             T_MHND_EXT-dmbtr = bsid-wrbtr.                     "1486637
           else.                                                "1486637
*          convert values in cc-currency T_MHND_EXT-WAERS       "1486637
             call function 'CONVERT_TO_LOCAL_CURRENCY'          "1486637
                exporting                                       "1486637
                  local_currency   = i_t001-WAERS               "1486637
                  foreign_currency = bsid-waers                 "1486637
                  foreign_amount   = bsid-wrbtr                 "1486637
                  date             = sy-datum                   "1486637
                importing                                       "1486637
                  local_amount     = T_MHND_EXT-dmbtr.          "1486637
           endif.                                               "1486637
         ENDIF.                                                 "1486637
      ENDIF.                                                    "1486637

*     call OFI to complete additional fields in mhnd (CI/SI) includes
      PERFORM OFI_DUN_COMPLETE_MHND_D USING    BSID
                                      CHANGING T_MHND_EXT.
*     create the group key if necessary using assigns from t047r
      IF I_VFM_KNXX-MGRUP <> SPACE.
        PERFORM CREATE_MGRUP_CUSTOMER TABLES   T_T047R
                                      USING    I_VFM_KNXX-MGRUP
                                      CHANGING T_MHND_EXT-GROUP1.
        T_MHND_EXT-MGRUP = I_VFM_KNXX-MGRUP.
      ENDIF.
      if convert_currency = 'T'.
        perform convert_currency using i_t001-waers
                                 changing t_mhnd_ext.
      endif.
*     save the data
      APPEND T_MHND_EXT.
    ELSE.
*     move-corresponding t_mhnd_ext to deleted_per_branch.
*     if t_mhnd_ext-mgrup <> space.
*       deleted_per_branch-cpdky = space.
*     endif.
*     collect deleted_per_branch.
      IF 0 = 1. MESSAGE S838. ENDIF.
      PERFORM LOG_MSG USING '838' 'D' I_VFM_KNXX-KUNNR
                                  BSID-BELNR BSID-BUZEI.
    ENDIF.
  ENDLOOP.

* check for clearing with vendor
  IF I_VFM_KNXX-LIFNR <> SPACE AND I_VFM_KNXX-XVERR = 'X'.

    SELECT * FROM  BSIK INTO   TABLE   T_BSIK
                        WHERE  BUKRS   IN T_BUKRS
                        AND    LIFNR   = I_VFM_KNXX-LIFNR
                        AND    BUDAT  <= I_GRDAT.

    LOOP AT T_BSIK.
*     save the work area
      BSIK = T_BSIK.

*     check the additional fields for items
      H_DUNN_IT = 'X'.
      IF I_CHECKS-C_LFB5 = 'X'.
        READ TABLE T_LFB5  INTO LFB5  WITH KEY LIFNR = I_VFM_KNXX-LIFNR
                                       BUKRS = I_VFM_KNXX-BUKRS
                                       MABER = BSIK-MABER.
* XOW eingefügt: into lfb5
        IF SY-SUBRC = 4.
           READ TABLE T_LFB5 INTO LFB5 WITH KEY LIFNR = I_VFM_KNXX-LIFNR
                                        BUKRS = I_VFM_KNXX-BUKRS
                                        MABER = SPACE.
        ENDIF.
        IF SY-SUBRC = 0.
          PERFORM CHECK_FIELD TABLES   T_FLDTAB
                             USING    'LFB5'
                             CHANGING H_DUNN_IT.
        ENDIF.
      ENDIF.
      IF I_CHECKS-C_BSIK = 'X' AND H_DUNN_IT = 'X'.
        PERFORM CHECK_FIELD TABLES   T_FLDTAB
                            USING    'BSIK'
                            CHANGING H_DUNN_IT.
      ENDIF.
      IF H_DUNN_IT = 'X'.
*       init the structure
        CLEAR T_MHND_EXT.

*       assign values
        T_MHND_EXT-BKOART = 'K'.
        MOVE-CORRESPONDING BSIK TO T_MHND_EXT.

*       assign the bukrs for inter-cc dunning
        T_MHND_EXT-BUKRS  = I_VFM_KNXX-BUKRS.
        T_MHND_EXT-BBUKRS = BSIK-BUKRS.

*       call OFI to complete additional fields in mhnd (CI/SI) includes
        PERFORM OFI_DUN_COMPLETE_MHND_K USING    BSIK
                                        CHANGING T_MHND_EXT.

*       create the group key if necessary using assigns from t047r
        IF I_VFM_KNXX-MGRUP <> SPACE.
          PERFORM CREATE_MGRUP_vendor TABLES   T_T047R
                                        USING    I_VFM_KNXX-MGRUP
                                        CHANGING T_MHND_EXT-GROUP1.
          T_MHND_EXT-MGRUP = I_VFM_KNXX-MGRUP.
        ENDIF.

        if convert_currency = 'T'.
          perform convert_currency using i_t001-waers
                                   changing t_mhnd_ext.
        ENDIF.
*       save the data
        APPEND T_MHND_EXT.
      ELSE.
        IF 0 = 1. MESSAGE S838. ENDIF.
        PERFORM LOG_MSG USING '838' 'D' I_VFM_KNXX-LIFNR
                                    BSIK-BELNR BSIK-BUZEI.
      ENDIF.
    ENDLOOP.
  ENDIF.

  KONTO   = 'D'.
  KONTO+2 = I_VFM_KNXX-KUNNR.
  DESCRIBE TABLE T_MHND_EXT LINES H_COUNT.
  IF H_COUNT > 0.
    IF 0 = 1. MESSAGE S803. ENDIF.
    PERFORM LOG_MSG USING '803' KONTO H_COUNT SPACE SPACE.
    E_HAS_ITEMS = 'X'.
  ELSE.
    IF 0 = 1. MESSAGE S833. ENDIF.
    PERFORM LOG_MSG USING '833' KONTO SPACE SPACE SPACE.
    IF 0 = 1. MESSAGE S816. ENDIF.
    PERFORM LOG_MSG USING '816' SPACE SPACE SPACE SPACE.
    IF 0 = 1. MESSAGE S807. ENDIF.
    PERFORM LOG_MSG USING '807' KONTO SPACE SPACE SPACE.
    E_HAS_ITEMS = SPACE.
  ENDIF.

ENDFORM.                    " GET_OPEN_ITEMS_CUSTOMER


*&---------------------------------------------------------------------*
*&      Form  GET_MASTER_DATA_VENDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_KNB5  text                                               *
*      -->P_T_LFB5  text                                               *
*      -->P_I_BUKRS  text                                              *
*      -->P_I_LIFNR  text                                              *
*      <--P_E_VFM_KNXX  text                                           *
*      <--P_E_VFM_LFXX  text                                           *
*      <--P_E_KNB5  text                                               *
*      <--P_E_LFB5  text                                               *
*      <--P_H_DUNN_IT  text                                            *
*----------------------------------------------------------------------*
FORM GET_MASTER_DATA_VENDOR   TABLES   T_KNB5   STRUCTURE KNB5
                                       T_LFB5   STRUCTURE LFB5
                                       T_FLDTAB STRUCTURE FLDTAB
                                       T_BUKRS  STRUCTURE BUKRS_SEL
                              USING    I_BUKRS    LIKE T001-BUKRS
                                       I_LIFNR    LIKE LFA1-LIFNR
                                       I_CHECKS   LIKE CHECKS
                              CHANGING E_VFM_KNXX LIKE VFM_KNXX
                                       E_VFM_LFXX LIKE VFM_LFXX
                                       E_KNB5     LIKE KNB5
                                       E_LFB5     LIKE LFB5
                                       E_KUNNR    LIKE KNA1-KUNNR
                                       E_KOART    LIKE MHNK_EXT-KOART
                                       E_MAHNA    LIKE VFM_LFXX-MAHNA
                                       E_DUNN_IT  LIKE BOOLE-BOOLE.
* declaration
  DATA: ERR LIKE SY-SUBRC.

  E_DUNN_IT = 'X'.
  E_KUNNR   = SPACE.
  E_KOART   = 'K'.

* log the beginning of all dunning activities
  IF 0 = 1. MESSAGE S796. ENDIF.
  PERFORM LOG_MSG USING '796' SPACE SPACE SPACE SPACE.
  IF 0 = 1. MESSAGE S801. ENDIF.
  PERFORM LOG_MSG USING '801' E_KOART I_LIFNR I_BUKRS SPACE.
  PERFORM LOG_MSG USING '819' SPACE SPACE SPACE SPACE.

* get the dunning view for the vendor
  SELECT SINGLE * FROM VFM_LFXX INTO E_VFM_LFXX
                                WHERE LIFNR = I_LIFNR
                                AND   BUKRS = I_BUKRS
                                AND   MABER = SPACE.
  ERR = ERR + SY-SUBRC.
  IF SY-SUBRC = 0.
    E_MAHNA = E_VFM_LFXX-MAHNA.

*   get the dunning master data for all dunning areas
    SELECT * FROM  LFB5 INTO TABLE T_LFB5
                        WHERE  LIFNR = I_LIFNR
                        AND    BUKRS IN T_BUKRS.
    ERR = ERR + SY-SUBRC.

    if not i_bukrs in t_bukrs.
       select * from lfb5 appending table t_lfb5
                        where lifnr = i_lifnr
                        and   bukrs = i_bukrs.
       err = err + sy-subrc.
    endif.

*   get the default knb5 entry
    READ TABLE T_LFB5 INTO E_LFB5
                      WITH KEY BUKRS = I_BUKRS
                               LIFNR = I_LIFNR
                               MABER = SPACE.
    ERR = ERR + SY-SUBRC.

*   in case of customer clearing get all customer dunning master data
    IF E_VFM_LFXX-XVERR = 'X' AND E_VFM_LFXX-KUNNR <> SPACE.

      E_KUNNR = E_VFM_LFXX-KUNNR.

*     log the customer vendor clearing
      IF 0 = 1. MESSAGE S802. ENDIF.
      PERFORM LOG_MSG USING '802' E_KOART I_LIFNR 'D' E_VFM_LFXX-KUNNR.

*     get the dunning view for the customer
      SELECT SINGLE * FROM VFM_KNXX INTO E_VFM_KNXX
                                    WHERE KUNNR = E_VFM_LFXX-KUNNR
                                    AND   BUKRS = I_BUKRS
                                    AND   MABER = SPACE.

      SELECT * FROM  KNB5 INTO TABLE T_KNB5
                          WHERE  KUNNR = E_VFM_LFXX-KUNNR
                          AND    BUKRS IN T_BUKRS.
      ERR = ERR + SY-SUBRC.

*     get the default knb5 entry
      READ TABLE T_KNB5 INTO E_KNB5
                        WITH KEY BUKRS = I_BUKRS
                                 KUNNR = E_VFM_LFXX-KUNNR
                                 MABER = SPACE.
      ERR = ERR + SY-SUBRC.
    ENDIF.
  ENDIF.

  IF ERR <> 0.
    IF 0 = 1. MESSAGE S725. ENDIF.
    PERFORM LOG_MSG USING '725' E_KOART I_LIFNR SPACE SPACE.
    E_DUNN_IT = SPACE.
  ELSE.
    IF I_CHECKS-C_LFA1 = 'X'.
      SELECT SINGLE * FROM  LFA1 WHERE  LIFNR = I_LIFNR.
      PERFORM CHECK_FIELD TABLES   T_FLDTAB
                          USING    'LFA1'
                          CHANGING E_DUNN_IT.
    ENDIF.
    if i_checks-c_lfb1 = 'X' and e_dunn_it = 'X'.
      SELECT SINGLE * FROM  LFB1 WHERE  LIFNR = I_LIFNR
                                 AND    BUKRS = I_BUKRS.
      PERFORM CHECK_FIELD TABLES   T_FLDTAB
                          USING    'LFB1'
                          CHANGING E_DUNN_IT.
    ENDIF.
    IF E_DUNN_IT = SPACE.
      IF 0 = 1. MESSAGE S837. ENDIF.
      PERFORM LOG_MSG USING '837' E_KOART I_LIFNR SPACE SPACE.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_MASTER_DATA_VENDOR
*&---------------------------------------------------------------------*
*&      Form  GET_OPEN_ITEMS_VENDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHND  text                                               *
*      -->P_I_GRDAT  text                                              *
*      -->P_E_VFM_KNXX  text                                           *
*----------------------------------------------------------------------*
FORM GET_OPEN_ITEMS_VENDOR   TABLES   T_MHND_EXT STRUCTURE MHND_EXT
                                      T_FLDTAB   STRUCTURE IFLDTAB
                                      T_KNB5     STRUCTURE KNB5
                                      T_LFB5     STRUCTURE LFB5
                                      T_T047R    STRUCTURE T047R
                                      T_BUKRS    STRUCTURE BUKRS_SEL
                             USING    I_GRDAT    LIKE F150V-GRDAT
                                      I_VFM_LFXX LIKE VFM_LFXX
                                      I_CHECKS   LIKE CHECKS
                                      i_t001     like t001
                             CHANGING E_HAS_ITEMS LIKE BOOLE-BOOLE.
* declaration
  DATA: H_COUNT LIKE SY-TABIX,
        H_DUNN_IT LIKE BOOLE-BOOLE,
        KONTO(15) TYPE C,
        T_BSID    LIKE BSID OCCURS 10 WITH HEADER LINE,
        T_BSIK    LIKE BSIK OCCURS 10 WITH HEADER LINE,
        e_t001_cc LIKE t001.                                    "1486637


* get the open items and copy into mhnd
  SELECT * FROM BSIK INTO TABLE T_BSIK
                     WHERE  BUKRS IN T_BUKRS
                     AND    LIFNR =  I_VFM_LFXX-LIFNR
                     AND    BUDAT <= I_GRDAT
                     and    hkont in r_hkont.
  LOOP AT T_BSIK.
*   save the work area
    BSIK = T_BSIK.

*   check the additional fields for items
    H_DUNN_IT = 'X'.
    IF I_CHECKS-C_LFB5 = 'X'.
      READ TABLE T_LFB5 INTO LFB5 WITH KEY LIFNR = I_VFM_LFXX-LIFNR
                                 BUKRS = I_VFM_LFXX-BUKRS
                                 MABER = BSIK-MABER.
*XOW eingefügt: into LFB5
      IF SY-SUBRC = 4.
         READ TABLE T_LFB5 INTO LFB5 WITH KEY LIFNR = I_VFM_LFXX-LIFNR
                                             BUKRS = I_VFM_LFXX-BUKRS
                                             MABER = SPACE.
      ENDIF.
      IF SY-SUBRC = 0.
        PERFORM CHECK_FIELD TABLES   T_FLDTAB
                           USING    'LFB5'
                           CHANGING H_DUNN_IT.
      ENDIF.
    ENDIF.
    IF I_CHECKS-C_BSIK = 'X' AND H_DUNN_IT = 'X'.
      PERFORM CHECK_FIELD TABLES   T_FLDTAB
                          USING    'BSIK'
                          CHANGING H_DUNN_IT.
    ENDIF.
    IF H_DUNN_IT = 'X'.
*     init the structure
      CLEAR T_MHND_EXT.

*     assign values
      T_MHND_EXT-BKOART = 'K'.
      MOVE-CORRESPONDING BSIK TO T_MHND_EXT.

*     assign the bukrs for inter-cc dunning
      T_MHND_EXT-BUKRS  = I_VFM_LFXX-BUKRS.
      T_MHND_EXT-BBUKRS = BSIK-BUKRS.

*     check currency for inter-cc dunning and in case of        "1486637
*     different cc-Currenies calculate amounts in local         "1486637
*     currency of dunning CC                                    "1486637
      IF T_MHND_EXT-BUKRS NE T_MHND_EXT-BBUKRS.                 "1486637
         PERFORM READ_T001 USING T_MHND_EXT-BBUKRS CHANGING e_T001_cc.
         IF i_t001-WAERS NE e_T001_cc-waers.                    "1486637
           if bsik-waers = i_t001-WAERS.         " change values in cc-currency
             T_MHND_EXT-dmbtr = bsik-wrbtr.                     "1486637
           else.                                                "1486637
*          convert values in cc-currency T_MHND_EXT-WAERS       "1486637
             call function 'CONVERT_TO_LOCAL_CURRENCY'          "1486637
                exporting                                       "1486637
                  local_currency   = i_t001-WAERS               "1486637
                  foreign_currency = bsik-waers                 "1486637
                  foreign_amount   = bsik-wrbtr                 "1486637
                  date             = sy-datum                   "1486637
                importing                                       "1486637
                  local_amount     = T_MHND_EXT-dmbtr.          "1486637
           endif.                                               "1486637
         ENDIF.                                                 "1486637
      ENDIF.                                                    "1486637

*     call OFI to complete additional fields in mhnd (CI/SI) includes
      PERFORM OFI_DUN_COMPLETE_MHND_K USING    BSIK
                                      CHANGING T_MHND_EXT.

*     create the group key if necessary using assigns from t047r
      IF I_VFM_LFXX-MGRUP <> SPACE.
        PERFORM CREATE_MGRUP_VENDOR TABLES   T_T047R
                                      USING    I_VFM_LFXX-MGRUP
                                      CHANGING T_MHND_EXT-GROUP1.
        T_MHND_EXT-MGRUP = I_VFM_LFXX-MGRUP.
      ENDIF.
      if convert_currency = 'T'.
        perform convert_currency using i_t001-waers
                                 changing t_mhnd_ext.
      endif.
*     save the data
      APPEND T_MHND_EXT.
    ELSE.
      IF 0 = 1. MESSAGE S838. ENDIF.
      PERFORM LOG_MSG USING '838' 'K' I_VFM_LFXX-LIFNR
                                  BSIK-BELNR BSIK-BUZEI.
    ENDIF.

  ENDLOOP.

* check for clearing with customer
  IF I_VFM_LFXX-KUNNR <> SPACE AND I_VFM_LFXX-XVERR = 'X'.

    SELECT * FROM  BSID INTO TABLE T_BSID
                        WHERE  BUKRS  IN T_BUKRS
                        AND    KUNNR   = I_VFM_LFXX-KUNNR
                        AND    BUDAT  <= I_GRDAT.
    LOOP AT T_BSID.
*     save the work area.
      BSID = T_BSID.

*     check the additional fields for items
      H_DUNN_IT = 'X'.
      IF I_CHECKS-C_KNB5 = 'X'.
        READ TABLE T_KNB5  INTO KNB5  WITH KEY KUNNR = I_VFM_LFXX-KUNNR
                                      BUKRS = I_VFM_LFXX-BUKRS
                                      MABER = BSID-MABER.
* XOW eingefügt: into KNB5
        IF SY-SUBRC = 4.
           READ TABLE T_KNB5 INTO KNB5 WITH KEY KUNNR = I_VFM_LFXX-KUNNR
                                                BUKRS = I_VFM_LFXX-BUKRS
                                                MABER = SPACE.
        ENDIF.
        IF SY-SUBRC = 0.
          PERFORM CHECK_FIELD TABLES   T_FLDTAB
                             USING    'KNB5'
                             CHANGING H_DUNN_IT.
        ENDIF.
      ENDIF.
      IF I_CHECKS-C_BSID = 'X' AND H_DUNN_IT = 'X'.
        PERFORM CHECK_FIELD TABLES   T_FLDTAB
                            USING    'BSID'
                            CHANGING H_DUNN_IT.
      ENDIF.
      IF H_DUNN_IT = 'X'.
*       init the structure
        CLEAR T_MHND_EXT.

*       assign values
        T_MHND_EXT-BKOART = 'D'.
        MOVE-CORRESPONDING BSID TO T_MHND_EXT.

*       assign the bukrs for inter-cc dunning
        T_MHND_EXT-BUKRS  = I_VFM_LFXX-BUKRS.
        t_mhnd_ext-bbukrs = bsid-bukrs.

*       call ofi to complete additional fields in mhnd (ci/si) includes
        PERFORM OFI_DUN_COMPLETE_MHND_D USING    BSID
                                        CHANGING T_MHND_EXT.

*       create the group key if necessary using assigns from t047r
        IF I_VFM_LFXX-MGRUP <> SPACE.
          PERFORM CREATE_MGRUP_CUSTOMER TABLES   T_T047R
                                        USING    I_VFM_LFXX-MGRUP
                                        CHANGING T_MHND_EXT-GROUP1.
          T_MHND_EXT-MGRUP = I_VFM_LFXX-MGRUP.
        ENDIF.
*       save the data
        if convert_currency = 'T'.
          perform convert_currency using i_t001-waers
                                   changing t_mhnd_ext.
        endif.
        APPEND T_MHND_EXT.
      ELSE.
        IF 0 = 1. MESSAGE S838. ENDIF.
        PERFORM LOG_MSG USING '838' 'D' I_VFM_LFXX-KUNNR
                                    BSID-BELNR BSID-BUZEI.
      ENDIF.

    ENDLOOP.
  ENDIF.

  KONTO   = 'K'.
  KONTO+2 = I_VFM_LFXX-LIFNR.
  DESCRIBE TABLE T_MHND_EXT LINES H_COUNT.
  IF H_COUNT > 0.
    IF 0 = 1. MESSAGE S803. ENDIF.
    PERFORM LOG_MSG USING '803' KONTO H_COUNT SPACE SPACE.
    E_HAS_ITEMS = 'X'.
  ELSE.
    IF 0 = 1. MESSAGE S833. ENDIF.
    PERFORM LOG_MSG USING '833' KONTO SPACE SPACE SPACE.
    IF 0 = 1. MESSAGE S816. ENDIF.
    PERFORM LOG_MSG USING '816' SPACE SPACE SPACE SPACE.
    IF 0 = 1. MESSAGE S807. ENDIF.
    PERFORM LOG_MSG USING '807' KONTO SPACE SPACE SPACE.
    E_HAS_ITEMS = SPACE.
  ENDIF.

ENDFORM.                    " GET_OPEN_ITEMS_VENDOR


form convert_currency  using i_local_currency like t001-waers
                       changing i_mhnd_ext structure mhnd_ext.
* check if currency is expiring, if so compute the amounts in new
* currency

  data new_curr like mhnd-waers.
  CALL FUNCTION 'CURRENCY_GET_SUBSEQUENT'
   EXPORTING
     CURRENCY           = i_mhnd_ext-waers
     PROCESS            = 'SAPF150'
     date               = F150V-AUSDT
     bukrs              = i_mhnd_ext-bbukrs
   IMPORTING
     CURRENCY_NEW       = new_curr.

  If i_mhnd_ext-waers ne new_curr.
    CALL FUNCTION 'CURRENCY_DOCUMENT_CONVERT'
     EXPORTING
       CONVERSION_MODE           = 'O'
       FROM_CURRENCY             = i_mhnd_ext-waers
       TO_CURRENCY               = new_curr
       DATE                      = F150V-AUSDT
       LOCAL_CURRENCY            = i_local_currency
     TABLES
       FIELDLIST                 = gt_fieldlist
     CHANGING
       LINE                      = i_mhnd_ext
     EXCEPTIONS
       FIELD_UNKNOWN             = 1
       FIELD_NOT_AMOUNT          = 2
       ERROR_IN_CONVERSION       = 3
       OTHERS                    = 4.
    IF SY-SUBRC <> 0.
      DATA: h_fimsg LIKE fimsg.
      h_fimsg-msgid =  SY-MSGID.
      h_fimsg-msgty = 'S'.
      h_fimsg-msgno = SY-MSGNO.
      h_fimsg-msgv1 = SY-MSGV1. CONDENSE h_fimsg-msgv1.
      h_fimsg-msgv2 = SY-MSGV2. CONDENSE h_fimsg-msgv2.
      h_fimsg-msgv3 = SY-MSGV3. CONDENSE h_fimsg-msgv3.
      h_fimsg-msgv4 = SY-MSGV4. CONDENSE h_fimsg-msgv4.
      CALL FUNCTION 'FI_MESSAGE_COLLECT'
           EXPORTING
                i_fimsg       = h_fimsg
                i_xappn       = 'X'
           EXCEPTIONS
                msgid_missing = 1
                msgno_missing = 2
                msgty_missing = 3
                OTHERS        = 4.
    ENDIF.
    i_mhnd_ext-waers = new_curr.
  endif.
endform.
