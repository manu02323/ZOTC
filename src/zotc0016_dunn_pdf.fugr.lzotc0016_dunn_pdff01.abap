*-------------------------------------------------------------------
***INCLUDE LF150F01 .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT_DUNNINGRUN.
*&---------------------------------------------------------------------*
*  Check input parameters of SCHEDULE_DUNNING_RUN                      *
*----------------------------------------------------------------------*
FORM CHECK_INPUT_DUNNINGRUN.

  IF NOT F150V-BHOST IS INITIAL.
    PERFORM SYSTEM_PRUEFEN(SAPFFHLP) USING F150V-BHOST.
  ENDIF.

  IF F150V-STRZT = '000000'
  AND F150V-XSTRF = SPACE.
    MESSAGE E336(F0) RAISING STARTDATE_WRONG.
*   Bitte einen Starttermin angeben oder sofort starten
  ENDIF.
  IF F150V-XDRAN = 'X'.
    PERFORM PDEST_PRUEFEN.
  ENDIF.
ENDFORM.                               " CHECK_INPUT_DUNNINGRUN.

*&---------------------------------------------------------------------*
*&      Form  PDEST_PRUEFEN
*&---------------------------------------------------------------------*
*       Testen der Druckerselektion                                    *
*----------------------------------------------------------------------*
FORM PDEST_PRUEFEN.
  IF F150V-PDEST = SPACE.
    PERFORM DEQUEUE.
    MESSAGE E158(F0) RAISING PRINTER_WRONG.
*   Bitte einen gültigen Druckernamen eingeben.
  ELSE.
    SELECT SINGLE * FROM TSP03 WHERE PADEST = F150V-PDEST.
    IF SY-SUBRC NE 0.
      PERFORM DEQUEUE.
      MESSAGE E159(F0) WITH F150V-PDEST RAISING PRINTER_WRONG.
*     Drucker & ist nicht vorgesehen
    ENDIF.
  ENDIF.
ENDFORM.                               " PDEST_PRUEFEN

*eject
*&---------------------------------------------------------------------*
*&      Form  CHECK_AUTHORITY
*&---------------------------------------------------------------------*
*       Check authority of USER                                        *
*----------------------------------------------------------------------*
FORM CHECK_AUTHORITY USING I_ACTVT TYPE C.
  RCODE = 0.
  CASE I_ACTVT.
    WHEN '02'.                         " Parameter bearbeiten
      ACTVT  = I_ACTVT.
      ERRTXT = TEXT-029.
    WHEN '11'.                         " Mahnlauf starten
      ACTVT  = I_ACTVT.
      ERRTXT = TEXT-030.
  ENDCASE.

  PERFORM BERXX_PRUEFEN USING RCODE.
  IF RCODE NE 0.
    SET SCREEN SY-DYNNR.
    LEAVE SCREEN.
  ENDIF.
ENDFORM.                               " CHECK_AUTHORITY

*&---------------------------------------------------------------------*
*&      Form  BERXX_PRUEFEN
*&---------------------------------------------------------------------*
*       Berechtigung pruefen, und Rcode setzen                        *
*       Feld ACTVT (Aktivitaet fuer Berechtigung )                    *
*       und ERRTXT (Text fuer Fehlermeldung muessen gesetzt sein.     *
*---------------------------------------------------------------------*
FORM BERXX_PRUEFEN USING
            B01-RCODE    LIKE RCODE.
  LOOP AT BUKTAB.
    AUTHORITY-CHECK OBJECT 'F_MAHN_BUK'
      ID 'FBTCH' FIELD ACTVT
      ID 'BUKRS' FIELD BUKTAB-BUKRS.
    IF SY-SUBRC NE 0.
      PERFORM DEQUEUE.
      MESSAGE S153(F0) WITH ERRTXT BUKTAB-BUKRS RAISING NO_AUTHORITY.
*     Keine Berechtigung für Aktivität & im Bukrs &
      B01-RCODE = 4.
    ENDIF.
  ENDLOOP.
  READ TABLE SLDTAB INDEX 1.
  IF SY-SUBRC = 0.
    AUTHORITY-CHECK OBJECT 'F_MAHN_KOA'
      ID 'FBTCH' FIELD ACTVT
      ID 'KOART' FIELD 'D'.
    IF SY-SUBRC NE 0.
      PERFORM DEQUEUE.
      MESSAGE S154(F0) WITH ERRTXT 'D' RAISING NO_AUTHORITY.
*     Keine Berechtigung für Aktivität & bei Kontoart &
      B01-RCODE = 4.
    ENDIF.
  ENDIF.
  READ TABLE SLKTAB INDEX 1.
  IF SY-SUBRC = 0.
    AUTHORITY-CHECK OBJECT 'F_MAHN_KOA'
      ID 'FBTCH' FIELD ACTVT
      ID 'KOART' FIELD 'K'.
    IF SY-SUBRC NE 0.
      PERFORM DEQUEUE.
      MESSAGE S154(F0) WITH ERRTXT 'K' RAISING NO_AUTHORITY.
*     Keine Berechtigung für Aktivität & bei Kontoart &
      B01-RCODE = 4.
    ENDIF.
  ENDIF.

ENDFORM.                               " BERXX_PRUEFEN

*eject
*&---------------------------------------------------------------------*
*&      Form  JOBNAME_PREPARE
*&---------------------------------------------------------------------*
*       prepare jobname for dunning run                               *
*---------------------------------------------------------------------*
FORM JOBNAME_PREPARE.
  JOBNAME-PROGN = 'F150'.
  JOBNAME-LAUFD = F150V-LAUFD.
  JOBNAME-LAUFI = F150V-LAUFI.
  JOBNAME-TYPE  = 'S'.                 " Selektion
  JOBNAME-FILL1 = '-'.
  JOBNAME-FILL2 = '-'.
  JOBNAME-FILL3 = '-'.
ENDFORM.                               " JOBNAME_PREPARE

*eject
*&---------------------------------------------------------------------*
*&      Form  JOB_PREPARATION
*&---------------------------------------------------------------------*
FORM JOB_PREPARATION USING  P_OLDDU TYPE C.

  TBTCO-JOBNAME = JOBNAME.

  CALL FUNCTION 'JOB_OPEN'
       EXPORTING
            JOBGROUP         = 'F150'
            JOBNAME          = TBTCO-JOBNAME
       IMPORTING
            JOBCOUNT         = JOBCOUNT
       EXCEPTIONS
            CANT_CREATE_JOB  = 01
            INVALID_JOB_DATA = 02
            JOBNAME_MISSING  = 03.

  IF SY-SUBRC <> 0.
    CALL FUNCTION 'BP_JOB_DELETE'
         EXPORTING
              JOBNAME    = TBTCO-JOBNAME
              JOBCOUNT   = JOBCOUNT
              FORCEDMODE = 'X'
         EXCEPTIONS
              OTHERS     = 04.
    PERFORM DEQUEUE.
    MESSAGE E352(F0) WITH TBTCO-JOBNAME RAISING JOB_OPEN_FAILED.
  ENDIF.
  IF P_OLDDU = SPACE.
    SUBMIT SAPF150S2   AND RETURN
                           USER SY-UNAME
                           VIA  JOB JOBNAME NUMBER JOBCOUNT
                           WITH LAUFD = F150V-LAUFD
                           WITH LAUFI = F150V-LAUFI
                           WITH OFI   = 'X'.

    IF F150V-XDRAN = 'X'.
      SUBMIT SAPF150D2     AND RETURN
                           USER SY-UNAME
                           VIA  JOB JOBNAME NUMBER JOBCOUNT
                           WITH P_LAUFD   = F150V-LAUFD
                           WITH P_LAUFI   = F150V-LAUFI
                           WITH P_UPDATE  = 'X'
                           WITH P_DISP    = SPACE
                           WITH P_DEST    = F150V-PDEST
                           WITH P_IMMED   = F150V-PIMMED
                           WITH P_OFI     = 'X'.
    ENDIF.
  ELSE.
    SUBMIT SAPF150S    AND RETURN
                           USER SY-UNAME
                           VIA  JOB JOBNAME NUMBER JOBCOUNT
                           WITH LAUFD = F150V-LAUFD
                           WITH LAUFI = F150V-LAUFI.

    IF F150V-XDRAN = 'X'.
      SUBMIT SAPF150D      AND RETURN
                           USER SY-UNAME
                           VIA  JOB JOBNAME NUMBER JOBCOUNT
                           WITH LAUFD   = F150V-LAUFD
                           WITH LAUFI   = F150V-LAUFI
                           WITH UPDATE  = 'X'
                           WITH DISPLAY = SPACE
                           WITH PDEST   = F150V-PDEST
                           WITH PIMMED  = F150V-PIMMED.
    ENDIF.
  ENDIF.
ENDFORM.                               " JOB_PREPARATION

*eject
*&---------------------------------------------------------------------*
*&      Form  JOB_FINISH
*&---------------------------------------------------------------------*
FORM JOB_FINISH.

  IF F150V-XSTRF = 'X'.
    CLEAR: F150V-STRDT, F150V-STRZT.
  ENDIF.

  IF F150V-XSTRF = 'X'.
    CALL FUNCTION 'JOB_CLOSE'
         EXPORTING
              JOBNAME              = TBTCO-JOBNAME
              JOBCOUNT             = JOBCOUNT
              STRTIMMED            = F150V-XSTRF
              TARGETSYSTEM         = F150V-BHOST
         EXCEPTIONS
              CANT_START_IMMEDIATE = 01
              INVALID_STARTDATE    = 02
              JOBNAME_MISSING      = 03
              JOB_CLOSE_FAILED     = 04
              JOB_NOSTEPS          = 05
              JOB_NOTEX            = 06
              LOCK_FAILED          = 07.

    IF SY-SUBRC <> 0.
      CALL FUNCTION 'BP_JOB_DELETE'
           EXPORTING
                JOBNAME    = TBTCO-JOBNAME
                JOBCOUNT   = JOBCOUNT
                FORCEDMODE = 'X'
           EXCEPTIONS
                OTHERS     = 04.
      PERFORM DEQUEUE.
      MESSAGE E339(F0) WITH TBTCO-JOBNAME RAISING JOB_CLOSE_FAILED.
*     Fehler innerhalb des FB 'JOB_CLOSE' aufgetreten (Job &)
    ENDIF.
  ELSE.
    CALL FUNCTION 'JOB_CLOSE'
         EXPORTING
              JOBNAME              = TBTCO-JOBNAME
              JOBCOUNT             = JOBCOUNT
              SDLSTRTDT            = F150V-STRDT
              SDLSTRTTM            = F150V-STRZT
              TARGETSYSTEM         = F150V-BHOST
         EXCEPTIONS
              CANT_START_IMMEDIATE = 01
              INVALID_STARTDATE    = 02
              JOBNAME_MISSING      = 03
              JOB_CLOSE_FAILED     = 04
              JOB_NOSTEPS          = 05
              JOB_NOTEX            = 06
              LOCK_FAILED          = 07.
    IF SY-SUBRC <> 0.
      CALL FUNCTION 'BP_JOB_DELETE'
           EXPORTING
                JOBNAME    = TBTCO-JOBNAME
                JOBCOUNT   = JOBCOUNT
                FORCEDMODE = 'X'
           EXCEPTIONS
                OTHERS     = 04.
      PERFORM DEQUEUE.
      MESSAGE E339(F0) WITH TBTCO-JOBNAME RAISING JOB_CLOSE_FAILED.
*     Fehler innerhalb des FB 'JOB_CLOSE' aufgetreten (Job &)
    ENDIF.
  ENDIF.

*------- Status in MAHNV setzen ----------------------------------------
  MAHNV-XMUPD = SPACE.
  IF F150V-XDRAN = 'X'.                " Selektion und Druck
    MAHNV-XMSEL = '1'.
    MAHNV-XMPRI = 'P'.
    MESSAGE S156(F0).
*   Mahnselektion und Druck sind eingeplant
  ELSE.                                " Nur Selektion
    MAHNV-XMSEL = 'P'.
    MAHNV-XMPRI = SPACE.
    MESSAGE S150(F0).
*   Mahnselektion ist eingeplant
  ENDIF.
  UPDATE MAHNV.

*------- JOBTAB ergänzen -----------------------------------------------
  CLEAR JOBTAB.
  JOBTAB-JOBCOUNT = JOBCOUNT.
  JOBTAB-JOBNAME  = TBTCO-JOBNAME.
  JOBTAB-JTYPE    = 'S'.
  APPEND JOBTAB.
  PERFORM PARAMETERS_SAVE.


ENDFORM.                               " JOB_FINISH

*eject
*&---------------------------------------------------------------------*
*&      Form  PARAMETERS_SAVE
*&---------------------------------------------------------------------*
FORM PARAMETERS_SAVE.
  F150ID-OBJKT = PARM.
  F150VERSIONPAR = F150VERSIONNEW.
  EXPORT F150V-AUSDT F150V-GRDAT
         BUKTAB BKLTAB FLDTAB JOBTAB SLDTAB SLKTAB TRDTAB TRKTAB
         F150VERSIONPAR


         TO DATABASE RFDT(FB) ID F150ID.
ENDFORM.                               " PARAMETERS_SAVE

*&---------------------------------------------------------------------*
*&      Form  PARAMETERS_DELETE
*&---------------------------------------------------------------------*
FORM PARAMETERS_DELETE.
  DELETE FROM RFDT WHERE RELID = 'FB'
                     AND SRTFD = F150ID.
  DELETE MAHNV.
  MESSAGE S102(F0).
* Parameter für Mahnlauf wurden gelöscht
ENDFORM.                               " PARAMETERS_DELETE

*eject
*&---------------------------------------------------------------------*
*&      Form  ENQUEUE
*&---------------------------------------------------------------------*
*       ENQUEUE dunning data                                           *
*----------------------------------------------------------------------*
FORM ENQUEUE.

  CALL FUNCTION 'ENQUEUE_EFMAHNV'
       EXPORTING
            LAUFI          = F150V-LAUFI
            LAUFD          = F150V-LAUFD
       EXCEPTIONS
            FOREIGN_LOCK   = 4
            SYSTEM_FAILURE = 8.
  RCODE = SY-SUBRC.
  CASE RCODE.
    WHEN 4.
      data user like sy-uname.
      user = sy-msgv1.
      MESSAGE E148(F0) WITH F150V-LAUFD F150V-LAUFI user
                                             RAISING LOCK_FAILED.
*     Mahnlauf & & ist von anderem Benutzer gesperrt
    WHEN 8.
      MESSAGE E149(F0) RAISING LOCK_FAILED.
*     Sperren ist zur Zeit nicht möglich - bitte erneut versuchen
  ENDCASE.
  ENQ-LAUFD = F150V-LAUFD.
  ENQ-LAUFI = F150V-LAUFI.

ENDFORM.                               " ENQUEUE

*&---------------------------------------------------------------------*
*&      Form  DEQUEUE
*&---------------------------------------------------------------------*
*       Dequeue dunning data                                          *
*---------------------------------------------------------------------*
FORM DEQUEUE.

  CALL FUNCTION 'DEQUEUE_EFMAHNV'
       EXPORTING
            LAUFI = ENQ-LAUFI
            LAUFD = ENQ-LAUFD.
  ENQ-LAUFD = SPACE.
  ENQ-LAUFI = SPACE.

ENDFORM.                               " DEQUEUE
