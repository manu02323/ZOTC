*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZOTC_DISPUTE_APP
*   generation date: 19.12.2014 at 09:00:01 by user PMISHRA
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZOTC_DISPUTE_APP   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
