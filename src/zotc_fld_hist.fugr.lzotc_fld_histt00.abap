*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 02/01/2013 at 19:54:00 by user BGUNDAB
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_FLD_HISTORY................................*
DATA:  BEGIN OF STATUS_ZOTC_FLD_HISTORY              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_FLD_HISTORY              .
CONTROLS: TCTRL_ZOTC_FLD_HISTORY
            TYPE TABLEVIEW USING SCREEN '9001'.
*.........table declarations:.................................*
TABLES: *ZOTC_FLD_HISTORY              .
TABLES: ZOTC_FLD_HISTORY               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
