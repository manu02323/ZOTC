*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZOTC_PART_TO_EMP
*   generation date: 10/08/2014 at 18:09:59 by user JMAZUMD
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZOTC_PART_TO_EMP   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
