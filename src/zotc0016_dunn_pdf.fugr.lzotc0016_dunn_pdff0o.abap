*----------------------------------------------------------------------*
***INCLUDE LF150F0O .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  OFI_DUN_DETERMINE_INTEREST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_AUSDT  text                                              *
*      -->P_I_MHNK_EXT  text                                           *
*      -->P_I_MHND_EXT  text                                           *
*      <--P_E_ZINSS  text                                              *
*      <--P_E_ZINST  text                                              *
*      <--P_E_WZSBT  text                                              *
*      <--P_E_ZSBTR  text                                              *
*      <--P_ENDFORM  text                                              *
*----------------------------------------------------------------------*
FORM OFI_DUN_DETERMINE_INTEREST USING    I_AUSDT    LIKE F150V-AUSDT
                                         I_MHNK_EXT LIKE MHNK_EXT
                                         I_MHND_EXT LIKE MHND_EXT
                                CHANGING E_ZINSS LIKE MHND-ZINSS
                                         E_ZINST LIKE MHND-ZINST
                                         E_WZSBT LIKE MHND-WZSBT
                                         E_ZSBTR LIKE MHND-ZSBTR
                                         E_XZINS LIKE MHND-XZINS.
* declaration
  DATA: H_MHNK LIKE MHNK,
        H_MHND LIKE MHND,
        T_FIMSG LIKE FIMSG OCCURS 10 WITH HEADER LINE.

  CHECK USE_OFI = 'X'.

* fields to be used by OFI
  MOVE-CORRESPONDING I_MHNK_EXT TO H_MHNK.
  MOVE-CORRESPONDING I_MHND_EXT TO H_MHND.

* call OpenFI
  CALL FUNCTION 'OPEN_FI_PERFORM_00001070_P'
       EXPORTING
            I_AUSDT = I_AUSDT
            I_MHNK  = H_MHNK
            I_MHND  = H_MHND
            I_APPLK = I_MHND_EXT-APPLK
       TABLES
            T_FIMSG = T_FIMSG
       CHANGING
            C_ZINSS = E_ZINSS
            C_ZINST = E_ZINST
            C_WZSBT = E_WZSBT
            C_ZSBTR = E_ZSBTR
            C_XZINS = E_XZINS
       EXCEPTIONS
            OTHERS  = 0.

* log the aprpriate messages
  PERFORM LOG_MSG_TAB TABLES T_FIMSG.

ENDFORM.                    " OFI_DUN_DETERMINE_INTEREST
*&---------------------------------------------------------------------*
*&      Form  OFI_DUN_COMPLETE_MHND_D
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BSID  text                                                 *
*      <--P_T_MHND_EXT  text                                           *
*----------------------------------------------------------------------*
FORM OFI_DUN_COMPLETE_MHND_D USING    I_BSID LIKE BSID
                             CHANGING E_MHND_EXT LIKE MHND_EXT.

* declaration
  DATA: H_MHND LIKE MHND,
        T_FIMSG LIKE FIMSG OCCURS 10 WITH HEADER LINE.

  CHECK USE_OFI = 'X'.

  MOVE-CORRESPONDING E_MHND_EXT TO H_MHND.

* set standard applk
  E_MHND_EXT-APPLK = C_APPLK.

* get application ID
  CALL FUNCTION 'OPEN_FI_PERFORM_00001761_E'
       EXPORTING
            I_MHND  = H_MHND
       CHANGING
            C_APPLK = E_MHND_EXT-APPLK
       EXCEPTIONS
            OTHERS  = 0.

* call OpenFI
  CALL FUNCTION 'OPEN_FI_PERFORM_00001051_P'
       EXPORTING
            I_BSID  = I_BSID
            I_APPLK = E_MHND_EXT-APPLK
       TABLES
            T_FIMSG = T_FIMSG
       CHANGING
            C_MHND  = H_MHND
       EXCEPTIONS
            OTHERS  = 0.

* save the additional values in the internal structure
  MOVE-CORRESPONDING H_MHND TO E_MHND_EXT.

  PERFORM LOG_MSG_TAB TABLES T_FIMSG.

ENDFORM.                    " OFI_DUN_COMPLETE_MHND_D
*&---------------------------------------------------------------------*
*&      Form  OFI_DUN_COMPLETE_MHND_K
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BSID  text                                                 *
*      <--P_T_MHND_EXT  text                                           *
*----------------------------------------------------------------------*
FORM OFI_DUN_COMPLETE_MHND_K USING    I_BSIK LIKE BSIK
                             CHANGING E_MHND_EXT LIKE MHND_EXT.
* declaration
  DATA: H_MHND LIKE MHND,
        T_FIMSG LIKE FIMSG OCCURS 10 WITH HEADER LINE.

  CHECK USE_OFI = 'X'.

  MOVE-CORRESPONDING E_MHND_EXT TO H_MHND.

* set standard applk
  E_MHND_EXT-APPLK = C_APPLK.

* get application ID
  CALL FUNCTION 'OPEN_FI_PERFORM_00001761_E'
       EXPORTING
            I_MHND  = H_MHND
       CHANGING
            C_APPLK = E_MHND_EXT-APPLK
       EXCEPTIONS
            OTHERS  = 0.

* call OpenFI
  CALL FUNCTION 'OPEN_FI_PERFORM_00001052_P'
       EXPORTING
            I_BSIK  = I_BSIK
            I_APPLK = E_MHND_EXT-APPLK
       TABLES
            T_FIMSG = T_FIMSG
       CHANGING
            C_MHND  = H_MHND
       EXCEPTIONS
            OTHERS  = 0.

* save the additional values in the internal structure
  MOVE-CORRESPONDING H_MHND TO E_MHND_EXT.

  PERFORM LOG_MSG_TAB TABLES T_FIMSG.

ENDFORM.                    " OFI_DUN_COMPLETE_MHND_K
*&---------------------------------------------------------------------*
*&      Form  OFI_DUN_CHECK_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHND_EXT  text                                           *
*      <--P_T_MHND_EXT-XFAEL  text                                     *
*      <--P_T_MHND_EXT-XZALB  text                                     *
*      <--P_T_MHND_EXT-MANSP  text                                     *
*----------------------------------------------------------------------*
FORM OFI_DUN_CHECK_ITEM USING    I_MHND_EXT  LIKE MHND_EXT
                                 i_mahna like mhnk-mahna
                        CHANGING E_XFAEL LIKE MHND-XFAEL
                                 E_XZALB LIKE MHND-XZALB
                                 E_MANSP LIKE MHND-MANSP
                                 E_FAEDT like mhnd-faedt
                                 e_verzn like mhnd-verzn.
* declaration
  DATA: H_MHND LIKE MHND,
        T_FIMSG LIKE FIMSG OCCURS 10 WITH HEADER LINE.

  CHECK USE_OFI = 'X'.

  MOVE-CORRESPONDING I_MHND_EXT TO H_MHND.

* call OpenFI
  CALL FUNCTION 'OPEN_FI_PERFORM_00001060_P'
       EXPORTING
            I_MHND  = H_MHND
            I_APPLK = I_MHND_EXT-APPLK
            i_mahna = i_mahna
       TABLES
            T_FIMSG = T_FIMSG
       CHANGING
            C_XFAEL = E_XFAEL
            C_XZALB = E_XZALB
            C_MANSP = E_MANSP
            c_faedt = e_faedt
            c_verzn = e_verzn
       EXCEPTIONS
            OTHERS  = 0.

  PERFORM LOG_MSG_TAB TABLES T_FIMSG.

ENDFORM.                    " OFI_DUN_CHECK_ITEM
*&---------------------------------------------------------------------*
*&      Form  OFI_DUN_DELETE_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHND_EXT  text                                           *
*      <--P_H_DEL_DU  text                                             *
*----------------------------------------------------------------------*
FORM OFI_DUN_DELETE_ITEM USING    I_MHND_EXT LIKE MHND_EXT
                         CHANGING E_DEL_DU LIKE BOOLE-BOOLE.
* declaration
  DATA: H_MHND LIKE MHND,
        T_FIMSG LIKE FIMSG OCCURS 10 WITH HEADER LINE.

  E_DEL_DU = SPACE.
  CHECK USE_OFI = 'X'.
  MOVE-CORRESPONDING I_MHND_EXT TO H_MHND.

* call OpenFI
  CALL FUNCTION 'OPEN_FI_PERFORM_00001061_P'
       EXPORTING
            I_MHND   = H_MHND
            I_APPLK  = I_MHND_EXT-APPLK
       TABLES
            T_FIMSG  = T_FIMSG
       CHANGING
            C_DEL_DU = E_DEL_DU
       EXCEPTIONS
            OTHERS   = 0.

  PERFORM LOG_MSG_TAB TABLES T_FIMSG.

ENDFORM.                    " OFI_DUN_DELETE_ITEM
*&---------------------------------------------------------------------*
*&      Form  OFI_DUN_COMPLETE_MHNK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_T_MHNK_EXT  text                                           *
*----------------------------------------------------------------------*
FORM OFI_DUN_COMPLETE_MHNK CHANGING E_MHNK_EXT LIKE MHNK_EXT.
* declaration
  DATA: H_MHNK LIKE MHNK,
  T_FIMSG LIKE FIMSG OCCURS 10 WITH HEADER LINE.

  CHECK USE_OFI = 'X'.

* determine data
  MOVE-CORRESPONDING E_MHNK_EXT TO H_MHNK.

* call OpenFI
  CALL FUNCTION 'OPEN_FI_PERFORM_00001050_P'
       exporting Min_it = e_mhnk_ext-min_it
       TABLES
            T_FIMSG = T_FIMSG
       CHANGING
            C_MHNK  = H_MHNK
       EXCEPTIONS
            OTHERS  = 0.

* read back data
  MOVE-CORRESPONDING H_MHNK TO E_MHNK_EXT.

  PERFORM LOG_MSG_TAB TABLES T_FIMSG.

ENDFORM.                    " OFI_DUN_COMPLETE_MHNK

*&---------------------------------------------------------------------*
*&      Form  LOG_MSG_TAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LOG_MSG_TAB TABLES T_FIMSG STRUCTURE FIMSG.
* log al the messges from the table
  LOOP AT T_FIMSG.
    CALL FUNCTION 'FI_MESSAGE_COLLECT'
       EXPORTING
            I_FIMSG       = T_FIMSG
            I_XAPPN       = 'X'
       EXCEPTIONS
            MSGID_MISSING = 1
            MSGNO_MISSING = 2
            MSGTY_MISSING = 3
            OTHERS        = 4.
  ENDLOOP.

ENDFORM.                    " LOG_MSG_TAB
*&---------------------------------------------------------------------*
*&      Form  OFI_DUN_DET_CPDKY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MHND_EXT  text                                           *
*      <--P_E_CPDKY  text                                              *
*----------------------------------------------------------------------*
FORM OFI_DUN_DET_CPDKY USING    I_MHND_EXT LIKE MHND_EXT
                       CHANGING E_CPDKY LIKE MHND-CPDKY.

* declaration
  DATA: H_MHND LIKE MHND,
  T_FIMSG LIKE FIMSG OCCURS 10 WITH HEADER LINE.

  CHECK USE_OFI = 'X'.

* determine data
  MOVE-CORRESPONDING I_MHND_EXT TO H_MHND.

* call Open FI
  CALL FUNCTION 'OPEN_FI_PERFORM_00001053_P'
       EXPORTING
            I_MHND  = H_MHND
            I_APPLK = I_MHND_EXT-APPLK
       TABLES
            T_FIMSG = T_FIMSG
       CHANGING
            C_CPDKY = E_CPDKY
       EXCEPTIONS
            OTHERS  = 0.

  PERFORM LOG_MSG_TAB TABLES T_FIMSG.

ENDFORM.                    " OFI_DUN_DET_CPDKY
*&---------------------------------------------------------------------*
*&      Form  OFI_DUN_MHNK_APPLK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHNK_EXT  text                                           *
*      <--P_T_MHNK_EXT_APPLK  text                                     *
*----------------------------------------------------------------------*
FORM OFI_DUN_MHNK_APPLK USING    I_MHNK_EXT LIKE MHNK_EXT
                        CHANGING E_APPLK LIKE MHNK-APPLK.
* declaration
  DATA: H_MHNK LIKE MHNK.

  CHECK USE_OFI = 'X'.

* determine data
  MOVE-CORRESPONDING I_MHNK_EXT TO H_MHNK.

* call OpenFI

  CALL FUNCTION 'OPEN_FI_PERFORM_00001760_E'
       EXPORTING
            I_MHNK  = H_MHNK
       CHANGING
            C_APPLK = E_APPLK
       EXCEPTIONS
            OTHERS  = 0.

ENDFORM.                    " OFI_DUN_MHNK_APPLK
*&---------------------------------------------------------------------*
*&      Form  OFI_DUN_DETERMINE_CHARGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_AUSDT  text
*      -->P_E_MHNK_EXT  text
*      <--P_E_MHNK_EXT_MHNGH  text
*      <--P_E_MHNK_EXT_MHNGF  text
*----------------------------------------------------------------------*
form ofi_dun_determine_charges tables   t_mhnd_ext
                               using    i_ausdt like f150v-ausdt
                                        I_MHNK_EXT LIKE MHNK_EXT
                               CHANGING E_MHNGH LIKE MHNK_EXT-MHNGH
                                        E_MHNGF LIKE MHNK_EXT-MHNGF.


* declaration
  DATA: H_MHNK LIKE MHNK,
        H_MHND LIKE MHND,
        T_FIMSG LIKE FIMSG OCCURS 10 WITH HEADER LINE.

  CHECK USE_OFI = 'X'.

* fields to be used by OFI
  MOVE-CORRESPONDING I_MHNK_EXT TO H_MHNK.

* call OpenFI
  CALL FUNCTION 'OPEN_FI_PERFORM_00001071_P'
       EXPORTING
            I_AUSDT = I_AUSDT
            I_MHNK  = H_MHNK
            I_APPLK = I_MHNK_EXT-APPLK
       TABLES
            T_FIMSG = T_FIMSG
            t_mhnd_ext  = t_mhnd_ext
       CHANGING
            C_MHNGH = E_MHNGH
            C_MHNGF = E_MHNGF.

* log the aprpriate messages
  PERFORM LOG_MSG_TAB TABLES T_FIMSG.

ENDFORM.                    " OFI_DUN_DETERMINE_CHARGES
