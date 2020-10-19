*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 20.03.2015 at 21:15:50 by user ASK
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_BILPLN_CTRL................................*
DATA:  BEGIN OF STATUS_ZOTC_BILPLN_CTRL              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_BILPLN_CTRL              .
CONTROLS: TCTRL_ZOTC_BILPLN_CTRL
            TYPE TABLEVIEW USING SCREEN '9001'.
*.........table declarations:.................................*
TABLES: *ZOTC_BILPLN_CTRL              .
TABLES: ZOTC_BILPLN_CTRL               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
