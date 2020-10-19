*-------------------------------------------------------------------
***INCLUDE LF150F0F .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  FILL_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHND_EXT  text                                           *
*      <--P_T_MHND_EXT-STATUS  text                                    *
*----------------------------------------------------------------------*
FORM FILL_STATUS USING    I_MHND_EXT LIKE MHND_EXT
                 CHANGING E_STATUS LIKE MHND_EXT-STATUS.
   E_STATUS = '<'.
   IF I_MHND_EXT-MANSP = SPACE.
     E_STATUS+1 = '.'.
   ELSE.
     E_STATUS+1 = I_MHND_EXT-MANSP.
   ENDIF.
   IF I_MHND_EXT-XFAEL = SPACE.
     E_STATUS+2 = 'd'.
   ELSE.
     E_STATUS+2 = 'D'.
   ENDIF.
   IF I_MHND_EXT-XZALB = SPACE.
     E_STATUS+3 = 'p'.
   ELSE.
     E_STATUS+3 = 'P'.
   ENDIF.
   IF I_MHND_EXT-XZINS = SPACE.
     E_STATUS+4 = 'I'.
   ELSE.
     E_STATUS+4 = 'i'.
   ENDIF.
   E_STATUS+5 = '>'.

   IF 0 = 1. MESSAGE S834. ENDIF.
   PERFORM LOG_MSG USING '834' I_MHND_EXT-BLINF I_MHND_EXT-MAHNN
                               I_MHND_EXT-VERZN I_MHND_EXT-STATUS.

ENDFORM.                    " FILL_STATUS
