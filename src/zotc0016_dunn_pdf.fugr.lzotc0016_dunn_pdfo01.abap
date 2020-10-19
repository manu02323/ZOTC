*-------------------------------------------------------------------
***INCLUDE LF150O01 .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Module  STATUS_1001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1001 OUTPUT.
   SET PF-STATUS '1001'.
   SET TITLEBAR 'MAN'.
ENDMODULE.                 " STATUS_1001  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SUPPRESS_DIALOG  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SUPPRESS_DIALOG OUTPUT.
    SUPPRESS DIALOG.
    LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
ENDMODULE.                 " SUPPRESS_DIALOG  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_1002  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1002 OUTPUT.
  REFRESH EXCLTAB.

  IF H_OFI = SPACE.
    F150V-OFIST = TEXT-202.
  ELSE.
    F150V-OFIST = SPACE.
  ENDIF.

  IF H_REPRINT = 'X'.
    EXCLTAB-OKCODE = 'PRIE'. APPEND EXCLTAB.
    EXCLTAB-OKCODE = 'PLOG'. APPEND EXCLTAB.
  ENDIF.

  SET PF-STATUS '1002' EXCLUDING EXCLTAB.
  SET TITLEBAR 'SDU'.

* EHP5: called from Collections Management
  IF GX_COLLECT_SINGLE_DUNN_INFO = 'X'.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'F150V-LIFNR'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " STATUS_1002  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_1003  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1003 OUTPUT.
   IF EDD_DISP = 'X'.
     SET PF-STATUS '1003' EXCLUDING 'CHCK'.
     SET TITLEBAR 'DDU'.
   ELSE.
     SET PF-STATUS '1003' EXCLUDING 'DISP'.
     SET TITLEBAR 'CDU'.
   ENDIF.

ENDMODULE.                 " STATUS_1003  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_1003  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_1003 OUTPUT.
* display only
*  if edd_disp = ' '.
*    loop at screen.
*      screen-input = 0.
*      modify screen.
*    endloop.
*  endif.
  CLEAR OK-CODE-1003.
ENDMODULE.                 " INIT_1003  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_TC_MHND_1003  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_MHND_1003_PBO OUTPUT.

*  tab_idx = tc_mhnd-current_line - 1.
*  read table edd_mhnd index tab_idx.
  MHND = EDD_MHND.

* display only
  IF EDD_DISP = 'X'.
    LOOP AT SCREEN.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " FILL_TC_MHND_1003  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_MHNK_1003_PBO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_MHNK_1003_PBO OUTPUT.
  MHNK = EDD_MHNK.
  IF MHNK-KOART = 'D'.
    F150V-KOVER = MHNK-KUNNR.
  ELSE.
    F150V-KOVER = MHNK-LIFNR.
  ENDIF.

* display only
  IF EDD_DISP = 'X'.
    LOOP AT SCREEN.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.


ENDMODULE.                 " TC_MHNK_1003_PBO  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_1004  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1004 OUTPUT.
   SET PF-STATUS '1004'.
   SET TITLEBAR 'CPY'.

ENDMODULE.                 " STATUS_1004  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0110 OUTPUT.
  SET PF-STATUS '0110'.
  SET TITLEBAR '110'.
ENDMODULE.                 " STATUS_0110  OUTPUT
