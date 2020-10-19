*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZOTC_FLD_HIST
*   generation date: 02/01/2013 at 19:53:59 by user BGUNDAB
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZOTC_FLD_HIST      .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
