*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZOTC_EBS_SEARCH
*   generation date: 06/13/2019 at 21:56:27
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZOTC_EBS_SEARCH    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
