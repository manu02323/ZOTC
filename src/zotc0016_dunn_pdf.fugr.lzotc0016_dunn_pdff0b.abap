*-------------------------------------------------------------------
***INCLUDE LF150F0B .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  BUILD_SUM_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHND_EXT  text                                           *
*      -->P_T_SUMTAB  text                                             *
*----------------------------------------------------------------------*
FORM BUILD_SUM_TABLE TABLES   T_MHNK_EXT  STRUCTURE MHNK_EXT
                              T_MHND_EXT  STRUCTURE MHND_EXT
                              T_SUMTAB    STRUCTURE LSUMTAB
                     USING    SUMTYPE     TYPE C.

  REFRESH T_SUMTAB.

* build the summation table
  LOOP AT T_MHNK_EXT.
    LOOP AT T_MHND_EXT WHERE LAUFD  = T_MHNK_EXT-LAUFD AND
                             LAUFI  = T_MHNK_EXT-LAUFI AND
                             KOART  = T_MHNK_EXT-KOART AND
                             BUKRS  = T_MHNK_EXT-BUKRS AND
                             KUNNR  = T_MHNK_EXT-KUNNR AND
                             LIFNR  = T_MHNK_EXT-LIFNR AND
                             CPDKY  = T_MHNK_EXT-CPDKY AND
                             SKNRZE = T_MHNK_EXT-SKNRZE AND
                             SMABER = T_MHNK_EXT-SMABER AND
                             SMAHSK = T_MHNK_EXT-SMAHSK.
      CLEAR T_SUMTAB.
      MOVE-CORRESPONDING T_MHND_EXT TO T_SUMTAB.
*     get summs per account ignore dunning level in key
      IF SUMTYPE = 'ACCOUNT'.
        T_SUMTAB-MAHNN = 0.
      ENDIF.
*     All the items have the same foreign currency
      IF T_MHNK_EXT-WAERS <>  T_MHNK_EXT-HWAERS.
        T_SUMTAB-DMSHB  = T_MHND_EXT-DMSHB.
        T_SUMTAB-WRSHB  = T_MHND_EXT-WRSHB.
        IF T_MHND_EXT-MANSP <> SPACE AND T_MHND_EXT-XZALB = SPACE AND     "1247977
           T_MHND_EXT-XFAEL = 'X'.                                        "1247977
          T_SUMTAB-GSFHW  = T_MHND_EXT-DMSHB.
          T_SUMTAB-GSFFW  = T_MHND_EXT-WRSHB.
        ENDIF.
        IF T_MHND_EXT-MANSP <> SPACE AND T_MHND_EXT-XFAEL = SPACE.
          T_SUMTAB-GSNHW  = T_MHND_EXT-DMSHB.
          T_SUMTAB-GSNFW  = T_MHND_EXT-WRSHB.
        ENDIF.
        IF T_MHND_EXT-XFAEL = 'X' AND T_MHND_EXT-XZALB = SPACE AND
           T_MHND_EXT-MANSP = SPACE.
          T_SUMTAB-FAEFW  = T_MHND_EXT-WRSHB.
          T_SUMTAB-FAEHW  = T_MHND_EXT-DMSHB.
          IF T_MHND_EXT-MAHNN >= T_MHNK_EXT-SUM_LEV AND
             SUMTYPE = 'ACCOUNT'.
            T_SUMTAB-FAMSM = T_MHND_EXT-WRSHB.
            T_SUMTAB-FAMSH = T_MHND_EXT-DMSHB.
          ENDIF.
        ENDIF.
*     use in sumtab the cc currency
      ELSE.
        T_SUMTAB-WAERS  = T_MHNK_EXT-WAERS.
        T_SUMTAB-DMSHB  = T_MHND_EXT-DMSHB.
        T_SUMTAB-WRSHB  = T_SUMTAB-DMSHB.
        IF T_MHND_EXT-MANSP <> SPACE AND T_MHND_EXT-XZALB = SPACE AND     "1247977
           T_MHND_EXT-XFAEL = 'X'.                                        "1247977
          T_SUMTAB-GSFHW  = T_MHND_EXT-DMSHB.
          T_SUMTAB-GSFFW  = T_SUMTAB-GSFHW.
        ENDIF.
        IF T_MHND_EXT-MANSP <> SPACE AND T_MHND_EXT-XFAEL = SPACE.
          T_SUMTAB-GSNHW  = T_MHND_EXT-DMSHB.
          T_SUMTAB-GSNFW  = T_SUMTAB-GSNHW.
        ENDIF.
        IF T_MHND_EXT-XFAEL = 'X' AND T_MHND_EXT-XZALB = SPACE AND
           T_MHND_EXT-MANSP = SPACE.
          T_SUMTAB-FAEHW  = T_MHND_EXT-DMSHB.
          T_SUMTAB-FAEFW  = T_SUMTAB-FAEHW.
          IF T_MHND_EXT-MAHNN >= T_MHNK_EXT-SUM_LEV AND
             SUMTYPE = 'ACCOUNT'.
            T_SUMTAB-FAMSH = T_MHND_EXT-DMSHB.
            T_SUMTAB-FAMSM = T_SUMTAB-FAMSH.
          ENDIF.
        ENDIF.
      ENDIF.
      COLLECT T_SUMTAB.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " BUILD_SUM_TABLE
