*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 24.08.2016 at 11:51:47 by user AMOHAPA
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_BILLBK_STG.................................*
DATA:  BEGIN OF STATUS_ZOTC_BILLBK_STG               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_BILLBK_STG               .
CONTROLS: TCTRL_ZOTC_BILLBK_STG
            TYPE TABLEVIEW USING SCREEN '9001'.
*.........table declarations:.................................*
TABLES: *ZOTC_BILLBK_STG               .
TABLES: ZOTC_BILLBK_STG                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
