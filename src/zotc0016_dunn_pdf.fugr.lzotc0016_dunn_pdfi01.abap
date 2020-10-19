*-------------------------------------------------------------------
***INCLUDE LF150I01 .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE START_LISTE_1001 INPUT.
  DATA:
    I        LIKE SY-TFILL,
    J        LIKE SY-TFILL,
    XVERR    LIKE BOOLE-BOOLE VALUE SPACE,
    TXT(132) TYPE C.

* determine the number of ap/ar dunning sections
  DESCRIBE TABLE HT_KNB5 LINES I.
  DESCRIBE TABLE HT_LFB5 LINES J.

* Check if ap/ar clearing is active
  IF I > 0 AND J > 0.
    TXT = TEXT-002.
    REPLACE '&1' WITH HI_KNB1-KUNNR INTO TXT.
    REPLACE '&2' WITH HI_LFB1-LIFNR INTO TXT.
    XVERR = 'X'.
  ELSEIF I > 0.
    TXT = TEXT-003.
    REPLACE '&1' WITH HI_KNB1-KUNNR INTO TXT.
  ELSEIF J > 0.
    TXT = TEXT-004.
    REPLACE '&1' WITH HI_LFB1-LIFNR INTO TXT.
  ENDIF.
  FORMAT COLOR COL_NORMAL INTENSIFIED.
  WRITE: TXT.

* Check if dunning info is available
  IF HI_KNB1-KUNNR <> SPACE AND I = 0.
    TXT = TEXT-008.
    REPLACE '&1' WITH HI_KNB1-KUNNR INTO TXT.
    WRITE: / TXT.
  ENDIF.
  IF HI_LFB1-LIFNR <> SPACE AND J = 0.
    TXT = TEXT-009.
    REPLACE '&1' WITH HI_LFB1-LIFNR INTO TXT.
    WRITE: / TXT.
  ENDIF.

* Check if account has branches
  IF DEBI_HAS_BRANCHES = 'X'.
    TXT = TEXT-007.
    REPLACE '&1' WITH HI_KNB1-KUNNR INTO TXT.
    WRITE: / TXT.
  ENDIF.
  IF KRED_HAS_BRANCHES = 'X'.
    TXT = TEXT-007.
    REPLACE '&1' WITH HI_LFB1-LIFNR INTO TXT.
    WRITE: / TXT.
  ENDIF.

* Check if account is a branch
  IF NOT HI_KNB1-KNRZE IS INITIAL.
    TXT = TEXT-005.
    REPLACE '&1' WITH HI_KNB1-KUNNR INTO TXT.
    REPLACE '&2' WITH HI_KNB1-KNRZE INTO TXT.
    WRITE: / TXT.
  ENDIF.
  IF NOT HI_LFB1-LNRZE IS INITIAL.
    TXT = TEXT-006.
    REPLACE '&1' WITH HI_LFB1-LIFNR INTO TXT.
    REPLACE '&2' WITH HI_LFB1-LNRZE INTO TXT.
    WRITE: / TXT.
  ENDIF.

* Page header
  IF I > 0 OR J > 0.
    FORMAT COLOR COL_HEADING.
    WRITE: /  SY-ULINE(81).
    WRITE: /  SY-VLINE NO-GAP,
              TEXT-001,
           81 SY-VLINE NO-GAP.
    WRITE: /  SY-ULINE(81).
  ENDIF.

  FORMAT COLOR COL_NORMAL INTENSIFIED OFF.

* if xverr = 'X'.
*   txt = text-003.
*   replace '&1' with hi_knb1-kunnr into txt.
*   write : / sy-vline no-gap, txt(50), 91 sy-vline no-gap,
*           / sy-uline(91).
* endif.

  LOOP AT HT_KNB5.

    WRITE: /  SY-VLINE NO-GAP.
    AT NEW KUNNR.
      WRITE : 'D' , HT_KNB5-KUNNR.
    ENDAT.
    WRITE:    14 SY-VLINE NO-GAP,
              HT_KNB5-MABER,
              27 SY-VLINE NO-GAP,
              HT_KNB5-MAHNS,
              38 SY-VLINE NO-GAP,
              HT_KNB5-MADAT,
           81 SY-VLINE NO-GAP.

  ENDLOOP.

* if xverr = 'X'.
*   txt = text-004.
*   replace '&1' with hi_lfb1-lifnr into txt.
*   write : / sy-uline(91).
*   write : / sy-vline no-gap,txt(50), 91 sy-vline no-gap,
*           / sy-uline(91).
* endif.


  LOOP AT HT_LFB5.
    WRITE: /  SY-VLINE NO-GAP.

    AT NEW LIFNR.
      WRITE : 'K', HT_LFB5-LIFNR.
    ENDAT.
    WRITE:    14 SY-VLINE NO-GAP,
              HT_LFB5-MABER,
              27 SY-VLINE NO-GAP,
              HT_LFB5-MAHNS,
              38 SY-VLINE NO-GAP,
              HT_LFB5-MADAT,
           81 SY-VLINE NO-GAP.
  ENDLOOP.
  IF I > 0 OR J > 0.
    WRITE: /  SY-ULINE(81).
  ENDIF.
ENDMODULE.                             " USER_COMMAND_1001  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_1002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_1002 INPUT.
  CASE OK-CODE-1002.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                             " EXIT_1002  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_ACCOUNT_1002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_ACCOUNT_1002 INPUT.

* check authority (selection)
  CALL FUNCTION 'F150_CHECK_AUTHORITY'
       EXPORTING
            I_ACTVT       = '11'
            I_BUKRS       = F150V-BUKRS
            I_KUNNR       = F150V-KUNNR
            I_LIFNR       = F150V-LIFNR.

  if ok-code-1002 = 'PRID'.
    CALL FUNCTION 'F150_CHECK_AUTHORITY'
       EXPORTING
            I_ACTVT       = '22'
            I_BUKRS       = F150V-BUKRS
            I_KUNNR       = F150V-KUNNR
            I_LIFNR       = F150V-LIFNR.
  else.
* check authority (print)
  CALL FUNCTION 'F150_CHECK_AUTHORITY'
       EXPORTING
            I_ACTVT       = '21'
            I_BUKRS       = F150V-BUKRS
            I_KUNNR       = F150V-KUNNR
            I_LIFNR       = F150V-LIFNR.
  endif.

* check if either customer or vendor is entered (not both)
  IF F150V-KUNNR = SPACE AND F150V-LIFNR = SPACE.
    MESSAGE E844.
  ELSEIF F150V-KUNNR <> SPACE AND F150V-LIFNR <> SPACE.
    MESSAGE E844.
  ENDIF.

* test if reprint is possible
  H_REPRINT = SPACE.
  IF F150V-KUNNR <> SPACE.
    SELECT * FROM  MHNK WHERE  LAUFD  = F150V-LAUFD
                        AND    LAUFI  = SPACE
                        AND    BUKRS  = F150V-BUKRS
                        AND (  KUNNR  = F150V-KUNNR
                        OR     SKNRZE = F150V-KUNNR ) .
      H_REPRINT = 'X'.
      EXIT.
    ENDSELECT.
  ELSEIF F150V-LIFNR <> SPACE.
    SELECT * FROM  MHNK WHERE  LAUFD  = F150V-LAUFD
                        AND    LAUFI  = SPACE
                        AND    BUKRS  = F150V-BUKRS
                        AND (  LIFNR  = F150V-LIFNR
                        OR     SKNRZE = F150V-LIFNR ) .
      H_REPRINT = 'X'.
      EXIT.
    ENDSELECT.
  ENDIF.

ENDMODULE.                             " CHECK_ACCOUNT_1002  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1002 INPUT.
* declaration
  DATA: I_F150V LIKE F150V,
        H_OK    LIKE BOOLE-BOOLE,
        H_ANS   TYPE C.

  I_F150V = F150V.
  REFRESH TI_FIMSG.

  IF H_REPRINT = 'X' AND OK-CODE-1002 <> 'PRID'.
    OK-CODE-1002 = SPACE.
  ELSEIF H_REPRINT = 'X'.
    OK-CODE-1002 = 'PRIN'.
  ENDIF.

  IF H_REPRINT = 'X'.                                           "1624269
     if F150V-KUNNR <> space.                                   "1624269
       MESSAGE I472 with F150V-KUNNR F150V-LAUFD.               "1624269
     elseif F150V-LIFNR <> space.                               "1624269
       MESSAGE I473 with F150V-LIFNR F150V-LAUFD.               "1624269
     endif.                                                     "1624269
  ENDIF.                                                        "1624269

  CASE OK-CODE-1002.
    WHEN 'PRIN'.
*     authority check for reprint
      PERFORM AUTHORITY_CHECK_ACCOUNT USING F150V SPACE CHANGING H_OK.
      IF H_OK = 'X'.
*     reprint the dunning account
        CALL FUNCTION 'REPRINT_DUNNING_DATA_ACCOUNT'
             EXPORTING
                  I_LAUFD       = F150V-LAUFD
                  I_LAUFI       = SPACE
                  I_BUKRS       = F150V-BUKRS
                  I_KUNNR       = F150V-KUNNR
                  I_LIFNR       = F150V-LIFNR
                  I_ITCPO       = ITCPO
                  I_OFI         = H_OFI
             TABLES
                  T_FIMSG       = TI_FIMSG
             EXCEPTIONS
                  NO_DATA_FOUND = 1
                  OTHERS        = 2.
        CALL SCREEN 2001 STARTING AT  3 06
                         ENDING   AT 85 20.
      ENDIF.
    WHEN 'PRIE'.
*     authority check for reprint
      PERFORM AUTHORITY_CHECK_ACCOUNT USING F150V 'X' CHANGING H_OK.
      IF H_OK = 'X'.
*     dunning print
        CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
             EXPORTING
                  TEXTLINE1 = TEXT-201
                  TITEL     = TEXT-031
             IMPORTING
                  ANSWER    = H_ANS
             EXCEPTIONS
                  OTHERS    = 0.
        IF H_ANS = 'J'.
          CALL FUNCTION 'EXECUTE_DUNNING_ACCOUNT'
               EXPORTING
                    I_LAUFD  = F150V-LAUFD
                    I_GRDAT  = F150V-GRDAT
                    I_AUSDT  = F150V-AUSDT
                    I_BUKRS  = F150V-BUKRS
                    I_KUNNR  = F150V-KUNNR
                    I_LIFNR  = F150V-LIFNR
                    I_ITCPO  = ITCPO
                    I_UPDATE = 'X'
                    I_SONLY  = SPACE
                    I_OFI    = H_OFI
                    I_XMPRI  = 'X'
                    I_XICCD  = F150V-ICCD
               TABLES
                    T_FIMSG  = TI_FIMSG
               EXCEPTIONS
                    OTHERS   = 0.
          F150V = I_F150V.
*       display the log
          CALL SCREEN 2001 STARTING AT  3 06
                           ENDING   AT 85 20.
          IF GX_COLLECT_SINGLE_DUNN_INFO EQ 'X'. "EHP5 called by ´Collections Management
            LEAVE TO SCREEN 0.
          ENDIF.
        ENDIF.
      ENDIF.
    WHEN 'PRID'.
*     authority check for reprint
      PERFORM AUTHORITY_CHECK_ACCOUNT USING F150V SPACE CHANGING H_OK.
      IF H_OK = 'X'.
*     dunning print test
        CALL FUNCTION 'EXECUTE_DUNNING_ACCOUNT'
             EXPORTING
                  I_LAUFD  = F150V-LAUFD
                  I_GRDAT  = F150V-GRDAT
                  I_AUSDT  = F150V-AUSDT
                  I_BUKRS  = F150V-BUKRS
                  I_KUNNR  = F150V-KUNNR
                  I_LIFNR  = F150V-LIFNR
                  I_ITCPO  = ITCPO
                  I_UPDATE = SPACE
                  I_SONLY  = SPACE
                  I_OFI    = 'X'
                  I_XMPRI  = SPACE
                  I_XICCD  = F150V-ICCD
             TABLES
                  T_FIMSG  = TI_FIMSG
             EXCEPTIONS
                  OTHERS   = 0.
*     display the log
        CALL SCREEN 2001 STARTING AT  3 06
                         ENDING   AT 85 20.
      ENDIF.
    WHEN 'PLOG'.
*     authority check for reprint
      PERFORM AUTHORITY_CHECK_ACCOUNT USING F150V SPACE CHANGING H_OK.
      IF H_OK = 'X'.
*     display only the log
        CALL FUNCTION 'EXECUTE_DUNNING_ACCOUNT'
             EXPORTING
                  I_LAUFD  = F150V-LAUFD
                  I_GRDAT  = F150V-GRDAT
                  I_AUSDT  = F150V-AUSDT
                  I_BUKRS  = F150V-BUKRS
                  I_KUNNR  = F150V-KUNNR
                  I_LIFNR  = F150V-LIFNR
                  I_ITCPO  = ITCPO
                  I_UPDATE = SPACE
                  I_SONLY  = 'X'
                  I_OFI    = H_OFI
                  I_XMPRI  = SPACE
                  I_XICCD  = F150V-ICCD
             TABLES
                  T_FIMSG  = TI_FIMSG
             EXCEPTIONS
                  OTHERS   = 0.

*     display the log
        CALL SCREEN 2001 STARTING AT  3 06
                         ENDING   AT 85 20.

      ENDIF.
  ENDCASE.
  F150V = I_F150V.
  OK-CODE-1002 = SPACE.
ENDMODULE.                             " USER_COMMAND_1002  INPUT

MODULE START_LISTE_2001 INPUT.
  CALL FUNCTION 'FI_MESSAGE_INIT'.
  CALL FUNCTION 'FI_MESSAGE_SET'
       TABLES
            T_FIMSG    = TI_FIMSG
       EXCEPTIONS
            NO_MESSAGE = 1
            OTHERS     = 2.
  CALL FUNCTION 'FI_MESSAGE_PRINT'
       EXPORTING
            I_MSORT = ' '
            I_XAUSN = ' '                                   "X
            I_XEAUS = ' '
            I_XSKIP = ' '
            I_CEMSG = 0
            I_CWMSG = 0
            I_COMSG = 0
       EXCEPTIONS
            OTHERS  = 0.
ENDMODULE.                             " START_LISTE_2001  INPUT

at user-command.
  if sy-ucomm = 'ENTER'.
     leave list-processing.
  endif.

MODULE F4_TDDEST_1002 INPUT.
* declaration
  DATA: T_DYNPREAD LIKE DYNPREAD OCCURS 1 WITH HEADER LINE,
        H_REPID LIKE SY-REPID.

* read print params from dynp
  REFRESH T_DYNPREAD.
  T_DYNPREAD-FIELDNAME   = 'ITCPO-TDDEST'. APPEND T_DYNPREAD.
  H_REPID = SY-REPID.
  CALL FUNCTION 'DYNP_VALUES_READ'
       EXPORTING
            DYNAME                   = H_REPID
            DYNUMB                   = SY-DYNNR
            TRANSLATE_TO_UPPER       = 'X'
       TABLES
            DYNPFIELDS               = T_DYNPREAD
       EXCEPTIONS
            INVALID_ABAPWORKAREA     = 1
            INVALID_DYNPROFIELD      = 2
            INVALID_DYNPRONAME       = 3
            INVALID_DYNPRONUMMER     = 4
            INVALID_REQUEST          = 5
            NO_FIELDDESCRIPTION      = 6
            INVALID_PARAMETER        = 7
            UNDEFIND_ERROR           = 8
            OTHERS                   = 9.
  READ TABLE T_DYNPREAD INDEX 1.
  ITCPO-TDDEST = T_DYNPREAD-FIELDVALUE.

* print parameters
  CALL FUNCTION 'GET_TEXT_PRINT_PARAMETERS'
        EXPORTING
            OPTIONS          = ITCPO
*           FORMAT_ITF       = ' '
            NO_PRINT_BUTTONS = 'X'
        IMPORTING
            NEWOPTIONS       = ITCPO
*           PRINT_FORMAT     =
        EXCEPTIONS
            CANCELED         = 1
            OTHERS           = 2.

ENDMODULE.                 " F4_TDDEST_1002  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_BUKRS_1002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_BUKRS_1002 INPUT.
* declaration
  DATA: H_BUKRS LIKE MHND-BUKRS.

* determine if icc duuning is active
  CHECK F150V-ICCD = 'X'.

* determine leading cc
  CALL FUNCTION 'GET_DUNNING_ICCD_LEADING_CC'
       EXPORTING
            I_BUKRS = F150V-BUKRS
       IMPORTING
            E_BUKRS = H_BUKRS
       EXCEPTIONS
            OTHERS  = 1.
  IF F150V-BUKRS <> H_BUKRS.
    MESSAGE E421 WITH F150V-BUKRS H_BUKRS.
  ENDIF.

ENDMODULE.                 " CHECK_BUKRS_1002  INPUT

MODULE EXIT_1003 INPUT.
   CASE OK-CODE-1003.
     WHEN 'CANC'.
       LEAVE TO SCREEN 0.
   ENDCASE.
ENDMODULE.                 " EXIT_1003  INPUT

MODULE TC_MHND_1003_PAI INPUT.
  TAB_IDX = TC_MHND-CURRENT_LINE.
  READ TABLE EDD_MHND INDEX TAB_IDX.
  EDD_MHND-MANSP = MHND-MANSP.
  EDD_MHND-MAHNN = MHND-MAHNN.
  MODIFY EDD_MHND INDEX TAB_IDX.

ENDMODULE.                 " TC_MHND_1003_PAI  INPUT

MODULE USER_COMMAND_1003 INPUT.
  CASE OK-CODE-1003.
    WHEN 'OK'.
      PERFORM COMMAND_CHCK_1003 USING SPACE.
      LEAVE TO SCREEN 0.
    WHEN 'CHCK'.
      PERFORM COMMAND_CHCK_1003 USING 'X'.
      CLEAR OK-CODE-1003.
    WHEN 'DISP'.
      PERFORM COMMAND_PRIN_1003.
      CLEAR OK-CODE-1003.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_1003  INPUT

MODULE TC_MHNK_1003_PAI INPUT.

  READ TABLE EDD_MHNK INDEX TC_MHNK-CURRENT_LINE.
  EDD_MHNK-MANSP = MHNK-MANSP.
  MODIFY EDD_MHNK INDEX TC_MHNK-CURRENT_LINE.

ENDMODULE.                 " TC_MHNK_1003_PAI  INPUT

MODULE F4_LAUFD_1004 INPUT.
* declaration
  DATA: BEGIN OF TAB_UPDATE OCCURS 1.
          INCLUDE STRUCTURE DYNPREAD.
  DATA: END OF TAB_UPDATE.

  DATA: H_EXIT  LIKE BOOLE-BOOLE,
        H_LAUFD LIKE F150V-LAUFD,
        H_LAUFI LIKE F150V-LAUFI.

* save old data
  H_LAUFD = F150V-COPYD.
  H_LAUFI = F150V-COPYI.

  CALL FUNCTION 'F150_JOBS_DUNNING_RUN_F4'
      EXPORTING
           I_XDISPLAY  = SPACE
      IMPORTING
           E_LAUFD     = F150V-COPYD
           E_LAUFI     = F150V-COPYI
           E_EXIT      = H_EXIT.
  IF H_EXIT = 'X'.
    F150V-COPYD = H_LAUFD.
    F150V-COPYI = H_LAUFI.
    CLEAR OK-CODE-1004.
    EXIT.
  ENDIF.

* update dynp fields
  REFRESH TAB_UPDATE.
  CLEAR TAB_UPDATE.
  TAB_UPDATE-FIELDNAME    = 'F150V-COPYD'.
*  tab_update-fieldvalue   = f150v-laufd.
  WRITE F150V-COPYD TO TAB_UPDATE-FIELDVALUE DD/MM/YYYY.
  APPEND TAB_UPDATE.

  TAB_UPDATE-FIELDNAME    = 'F150V-COPYI'.
  TAB_UPDATE-FIELDVALUE   = F150V-COPYI.
  APPEND TAB_UPDATE.
*  write laufd to tab_update-fieldvalue dd/mm/yyyy.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
       EXPORTING
            DYNAME     = SY-CPROG
            DYNUMB     = SY-DYNNR
       TABLES
            DYNPFIELDS = TAB_UPDATE
       EXCEPTIONS
            OTHERS     = 8.

  CLEAR OK-CODE-1004.

ENDMODULE.                 " F4_LAUFD_1004  INPUT

MODULE EXIT_1004 INPUT.
  CLEAR OK-CODE-1004.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT_1004  INPUT

MODULE USER_COMMAND_1004 INPUT.
  CASE OK-CODE-1004.
    WHEN 'COPY'.
      OK-CODE-1004 = 'OK'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
      CLEAR OK-CODE-1004.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_1004  INPUT
