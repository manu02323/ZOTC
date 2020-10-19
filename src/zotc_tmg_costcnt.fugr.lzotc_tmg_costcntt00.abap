*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 06/20/2012 at 08:20:53 by user RNATHAK
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_COSTCENTER.................................*
DATA:  BEGIN OF STATUS_ZOTC_COSTCENTER               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_COSTCENTER               .
CONTROLS: TCTRL_ZOTC_COSTCENTER
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZOTC_COSTCENTER               .
TABLES: ZOTC_COSTCENTER                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
