*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 13.10.2016 at 05:27:04 by user ASHARMA8
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_BANK.......................................*
DATA:  BEGIN OF STATUS_ZOTC_BANK                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_BANK                     .
CONTROLS: TCTRL_ZOTC_BANK
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZOTC_BANK                     .
TABLES: ZOTC_BANK                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
