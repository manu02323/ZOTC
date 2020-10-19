*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 10/26/2016 at 19:23:07 by user U033814
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSHTCO..........................................*
DATA:  BEGIN OF STATUS_ZSHTCO                        .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSHTCO                        .
CONTROLS: TCTRL_ZSHTCO
            TYPE TABLEVIEW USING SCREEN '0200'.
*...processing: ZTAXINC.........................................*
DATA:  BEGIN OF STATUS_ZTAXINC                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTAXINC                       .
CONTROLS: TCTRL_ZTAXINC
            TYPE TABLEVIEW USING SCREEN '0300'.
*...processing: ZVATPROCES......................................*
DATA:  BEGIN OF STATUS_ZVATPROCES                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZVATPROCES                    .
CONTROLS: TCTRL_ZVATPROCES
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZSHTCO                        .
TABLES: *ZTAXINC                       .
TABLES: *ZVATPROCES                    .
TABLES: ZSHTCO                         .
TABLES: ZTAXINC                        .
TABLES: ZVATPROCES                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
