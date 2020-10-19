*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZOTC_TERRIT_ASSN
*   generation date: 10/08/2014 at 17:39:11 by user JMAZUMD
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZOTC_TERRIT_ASSN   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
