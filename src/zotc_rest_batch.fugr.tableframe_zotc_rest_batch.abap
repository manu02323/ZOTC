*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZOTC_REST_BATCH
*   generation date: 07/15/2016 at 12:34:26 by user MGARG
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZOTC_REST_BATCH    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
