*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 08/16/2012 at 09:13:50 by user PGUPTA2
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_BATCHMATCH.................................*
DATA:  BEGIN OF STATUS_ZOTC_BATCHMATCH               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_BATCHMATCH               .
CONTROLS: TCTRL_ZOTC_BATCHMATCH
            TYPE TABLEVIEW USING SCREEN '9001'.
*.........table declarations:.................................*
TABLES: *ZOTC_BATCHMATCH               .
TABLES: ZOTC_BATCHMATCH                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
