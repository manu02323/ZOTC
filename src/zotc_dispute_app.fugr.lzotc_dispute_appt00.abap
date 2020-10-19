*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 09.01.2015 at 06:31:26 by user PMISHRA
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_DISPUTE_APP................................*
DATA:  BEGIN OF STATUS_ZOTC_DISPUTE_APP              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_DISPUTE_APP              .
CONTROLS: TCTRL_ZOTC_DISPUTE_APP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZOTC_DISPUTE_APP              .
TABLES: ZOTC_DISPUTE_APP               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
