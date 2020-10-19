*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 19.03.2015 at 14:35:43 by user PMISHRA
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_BOM_CREATE.................................*
DATA:  BEGIN OF STATUS_ZOTC_BOM_CREATE               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_BOM_CREATE               .
CONTROLS: TCTRL_ZOTC_BOM_CREATE
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZOTC_BOM_CREATE               .
TABLES: ZOTC_BOM_CREATE                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
