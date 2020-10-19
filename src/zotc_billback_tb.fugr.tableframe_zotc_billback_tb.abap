*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZOTC_BILLBACK_TB
*   generation date: 12/20/2012 at 21:25:10 by user ADAS1
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZOTC_BILLBACK_TB   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
