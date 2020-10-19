*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 07/24/2012 at 08:09:53 by user RNATHAK
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOTC_SALE_EMPMAP................................*
DATA:  BEGIN OF STATUS_ZOTC_SALE_EMPMAP              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOTC_SALE_EMPMAP              .
CONTROLS: TCTRL_ZOTC_SALE_EMPMAP
            TYPE TABLEVIEW USING SCREEN '0901'.
*.........table declarations:.................................*
TABLES: *ZOTC_SALE_EMPMAP              .
TABLES: ZOTC_SALE_EMPMAP               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
