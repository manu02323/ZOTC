*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZOTC_BILPLN_CTRL
*   generation date: 20.03.2015 at 21:15:49 by user ASK
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZOTC_BILPLN_CTRL   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
