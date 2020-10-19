*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZOTC_BILL_NUM_R
*   generation date: 08/09/2016 at 21:28:55 by user U033814
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZOTC_BILL_NUM_R    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
