*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZOTC_BILLNAME
*   generation date: 06.10.2016 at 06:38:32 by user ASHARMA8
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZOTC_BILLNAME      .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
