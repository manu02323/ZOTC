*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 18.02.2015 at 05:04:26 by user DMOIRAN
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_TRAGR_PREF.................................*
DATA:  BEGIN OF STATUS_ZOTC_TRAGR_PREF               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_TRAGR_PREF               .
CONTROLS: TCTRL_ZOTC_TRAGR_PREF
            TYPE TABLEVIEW USING SCREEN '1100'.
*.........table declarations:.................................*
TABLES: *ZOTC_TRAGR_PREF               .
TABLES: ZOTC_TRAGR_PREF                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
