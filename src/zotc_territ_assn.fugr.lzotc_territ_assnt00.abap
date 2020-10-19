*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 10/08/2014 at 17:39:12 by user JMAZUMD
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_TERRIT_ASSN................................*
DATA:  BEGIN OF STATUS_ZOTC_TERRIT_ASSN              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_TERRIT_ASSN              .
CONTROLS: TCTRL_ZOTC_TERRIT_ASSN
            TYPE TABLEVIEW USING SCREEN '9001'.
*.........table declarations:.................................*
TABLES: *ZOTC_TERRIT_ASSN              .
TABLES: ZOTC_TERRIT_ASSN               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
