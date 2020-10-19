*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 21.08.2019 at 16:47:59
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_RULE_VALUE.................................*
DATA:  BEGIN OF STATUS_ZOTC_RULE_VALUE               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_RULE_VALUE               .
CONTROLS: TCTRL_ZOTC_RULE_VALUE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZOTC_RULE_VALUE               .
TABLES: ZOTC_RULE_VALUE                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
