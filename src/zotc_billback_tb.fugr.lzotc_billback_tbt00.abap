*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 12/20/2012 at 21:25:10 by user ADAS1
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_BILLBACK...................................*
DATA:  BEGIN OF STATUS_ZOTC_BILLBACK                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_BILLBACK                 .
CONTROLS: TCTRL_ZOTC_BILLBACK
            TYPE TABLEVIEW USING SCREEN '9001'.
*.........table declarations:.................................*
TABLES: *ZOTC_BILLBACK                 .
TABLES: ZOTC_BILLBACK                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
