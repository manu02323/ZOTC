*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZOTC_BILLBK_STG
*   generation date: 24.08.2016 at 11:51:46 by user AMOHAPA
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZOTC_BILLBK_STG    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
