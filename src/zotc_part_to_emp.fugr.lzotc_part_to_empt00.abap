*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 10/08/2014 at 18:09:59 by user JMAZUMD
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_PART_TO_EMP................................*
DATA:  BEGIN OF STATUS_ZOTC_PART_TO_EMP              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_PART_TO_EMP              .
CONTROLS: TCTRL_ZOTC_PART_TO_EMP
            TYPE TABLEVIEW USING SCREEN '9001'.
*.........table declarations:.................................*
TABLES: *ZOTC_PART_TO_EMP              .
TABLES: ZOTC_PART_TO_EMP               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
