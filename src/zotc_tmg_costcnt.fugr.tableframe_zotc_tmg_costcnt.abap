*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZOTC_TMG_COSTCNT
*   generation date: 06/20/2012 at 08:20:51 by user RNATHAK
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZOTC_TMG_COSTCNT   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
