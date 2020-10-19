*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 09/30/2014 at 20:52:05 by user MCHATTE
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_PART_ROLE..................................*
DATA:  BEGIN OF STATUS_ZOTC_PART_ROLE                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_PART_ROLE                .
CONTROLS: TCTRL_ZOTC_PART_ROLE
            TYPE TABLEVIEW USING SCREEN '9001'.
*.........table declarations:.................................*
TABLES: *ZOTC_PART_ROLE                .
TABLES: ZOTC_PART_ROLE                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
