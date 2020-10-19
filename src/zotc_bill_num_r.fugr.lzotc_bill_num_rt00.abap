*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 08/09/2016 at 21:28:56 by user U033814
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_BILL_NUM_R.................................*
DATA:  BEGIN OF STATUS_ZOTC_BILL_NUM_R               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_BILL_NUM_R               .
CONTROLS: TCTRL_ZOTC_BILL_NUM_R
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZOTC_BILL_NUM_R               .
TABLES: ZOTC_BILL_NUM_R                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
