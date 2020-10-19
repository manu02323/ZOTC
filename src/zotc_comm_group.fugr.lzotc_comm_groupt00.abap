*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 09/30/2014 at 20:55:18 by user MCHATTE
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_COMM_GROUP.................................*
DATA:  BEGIN OF STATUS_ZOTC_COMM_GROUP               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_COMM_GROUP               .
CONTROLS: TCTRL_ZOTC_COMM_GROUP
            TYPE TABLEVIEW USING SCREEN '9001'.
*.........table declarations:.................................*
TABLES: *ZOTC_COMM_GROUP               .
TABLES: ZOTC_COMM_GROUP                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
