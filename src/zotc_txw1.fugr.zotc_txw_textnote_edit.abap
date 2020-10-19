*&---------------------------------------------------------------------*
*& Function Module  ZOTC_TXW_TEXTNOTE_EDIT
*&---------------------------------------------------------------------*
************************************************************************
* FM         :  ZOTC_TXW_TEXTNOTE_EDIT                                 *
* FG         :  ZOTC_TXW1                                              *
* TITLE      :  Call textnote editor control                           *
* DEVELOPER  :  ROHIT VERMA                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_EDD_0011_Pricing Routine Enhancement               *
*----------------------------------------------------------------------*
* DESCRIPTION:  This function module is a copy of standard function    *
*               module TXW_TEXTNOTE_EDIT used to display consolidated  *
*               warning message for all the items of an Order/Contract *
*               where list price is charged.                           *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 16-May-2014 RVERMA   E1DK913520 INITIAL DEVELOPMENT - CR#1354        *
*&---------------------------------------------------------------------*

FUNCTION ZOTC_TXW_TEXTNOTE_EDIT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(EDIT_MODE) TYPE  C DEFAULT 'X'
*"  TABLES
*"      T_TXWNOTE STRUCTURE  TXW_NOTE
*"--------------------------------------------------------------------

* Put all of the functionality of the call screen in here
      textnote_itxw_note[] = t_txwnote[].
      textnote_edit_mode = edit_mode.

*      EDITOR-CALL FOR itxw_note TITLE text-011.
      CALL SCREEN '0205' STARTING AT 05 05 ENDING AT 77 24.

      if textnote_edit_mode = 'X'.
        t_txwnote[] = textnote_itxw_note[].
      endif.
ENDFUNCTION.
