*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 08/08/2012 at 19:57:41 by user PGUPTA2
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_DC_CODE....................................*
DATA:  BEGIN OF STATUS_ZOTC_DC_CODE                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_DC_CODE                  .
CONTROLS: TCTRL_ZOTC_DC_CODE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZOTC_DC_CODE                  .
TABLES: ZOTC_DC_CODE                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
