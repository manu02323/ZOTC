*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZOTC_VAT_PROCESS
*   generation date: 06/27/2016 at 22:07:04 by user U033814
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZOTC_VAT_PROCESS   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
