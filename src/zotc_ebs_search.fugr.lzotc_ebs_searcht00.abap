*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 06/13/2019 at 21:56:29
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_EBS_SEARCH.................................*
DATA:  BEGIN OF STATUS_ZOTC_EBS_SEARCH               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_EBS_SEARCH               .
CONTROLS: TCTRL_ZOTC_EBS_SEARCH
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZOTC_EBS_SEARCH               .
TABLES: ZOTC_EBS_SEARCH                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
