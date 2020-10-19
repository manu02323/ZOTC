*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZOTC_DC_CODE
*   generation date: 08/03/2012 at 16:23:49 by user PGUPTA2
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZOTC_DC_CODE       .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
