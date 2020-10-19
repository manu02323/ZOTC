*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZOTC_BATCHMATCH
*   generation date: 08/16/2012 at 09:13:49 by user PGUPTA2
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZOTC_BATCHMATCH    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
