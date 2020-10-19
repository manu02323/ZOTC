*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 05.04.2012 at 11:25:09 by user VGAUR
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_PRC_CONTROL................................*
DATA:  BEGIN OF STATUS_ZOTC_PRC_CONTROL              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_PRC_CONTROL              .
CONTROLS: TCTRL_ZOTC_PRC_CONTROL
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZOTC_PRC_CONTROL              .
TABLES: ZOTC_PRC_CONTROL               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
