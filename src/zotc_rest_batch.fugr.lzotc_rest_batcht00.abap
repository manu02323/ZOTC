*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 07/15/2016 at 12:34:28 by user MGARG
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_REST_BATCH.................................*
DATA:  BEGIN OF STATUS_ZOTC_REST_BATCH               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_REST_BATCH               .
CONTROLS: TCTRL_ZOTC_REST_BATCH
            TYPE TABLEVIEW USING SCREEN '1100'.
*.........table declarations:.................................*
TABLES: *ZOTC_REST_BATCH               .
TABLES: ZOTC_REST_BATCH                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
