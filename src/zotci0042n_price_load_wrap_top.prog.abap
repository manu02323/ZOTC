*&---------------------------------------------------------------------*
*&  Include           ZOTCI0042N_PRICE_LOAD_WRAP_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCI0042B_PRICE_LOAD_WRAPPER                          *
* TITLE      :  D2_OTC_IDD_42_Price Load                               *
* DEVELOPER  :  Shushant Nigam                                         *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D2_OTC_IDD_42_Price Load
*----------------------------------------------------------------------*
* DESCRIPTION: This is the wrapper program to ZOTCI0042B_PRICE_LOAD. Si*
* nce original program is taking lot of time to finish, hence objective*
* is to split the file into smaller files and schedule job with smaller*
* files                                                                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
*19-Nov-2015 SNIGAM   E2DK916145  Defect 1351                          *
*&---------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_job_log,
    reaxserver TYPE btcsrvname,                   "Server name
    name       TYPE btcjob,                       " Background job name
    id         TYPE btcjobcnt,                    " Job ID
    file       TYPE localfile,                    " Local file for upload/download
    count      TYPE i,                            " Count of type Integers
  END OF ty_job_log,
  ty_t_job_log TYPE STANDARD TABLE OF ty_job_log, " Table type for Job Log table
  ty_t_btcxpm  TYPE STANDARD TABLE OF btcxpm.     " Log message from external program to calling program

DATA:
  i_directory  TYPE STANDARD TABLE OF btcxpm ##needed,     "Log message from external program to calling program
  i_job_log    TYPE STANDARD TABLE OF ty_job_log ##needed. "Table for Job Log
