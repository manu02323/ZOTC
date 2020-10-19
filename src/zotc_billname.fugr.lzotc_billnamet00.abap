*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 13.10.2016 at 05:23:18 by user ASHARMA8
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_BILLNAME...................................*
DATA:  BEGIN OF STATUS_ZOTC_BILLNAME                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_BILLNAME                 .
CONTROLS: TCTRL_ZOTC_BILLNAME
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZOTC_BILLNAME                 .
TABLES: ZOTC_BILLNAME                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
