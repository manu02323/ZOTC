*&---------------------------------------------------------------------*
*&  Include           ZOTCO0093B_PROCESS_IDOC_TOP
*&---------------------------------------------------------------------*
*&--------------------------------------------------------------------*
* Report             :  ZOTC0093_DATA_SEL                             *
* TITLE              :  get active change pointer and delete          *
* DEVELOPER          :  Deepanker Dwivedi                             *
* OBJECT TYPE        :  INTERFACE                                     *
* SAP RELEASE        :  SAP ECC 6.0                                   *
*---------------------------------------------------------------------*
* WRICEF ID          :  D3_OTC_IDD_0093                               *
* Transport          :  E1DK918891
*---------------------------------------------------------------------*
* DESCRIPTION:   This application is to submit RSEOUT00 program into  *
*                 various job based on IDOC counts for each job       *
*---------------------------------------------------------------------*
***INCLUDE RSEIDOC_DAT .
TABLES: edidc. " , teds2.

TABLES: edpp1. " EDI Partner (general partner profiles - inb. and outb.)
DATA: gv_select_all_use TYPE char1 ##NEEDED.
DATA: gv_direction TYPE char1 ##NEEDED. " Direction of type CHAR1


DATA: gv_time_0 TYPE edidc-updtim VALUE '000000' ##NEEDED,              " Time at which control record was last changed
      gv_time_24 TYPE edidc-updtim VALUE '240000' ##NEEDED   ##value_ok. " Time at which control record was last changed


TYPES: BEGIN OF ty_int_edidc,
        docnum TYPE edidc-docnum, " Control record (IDoc)
 END OF ty_int_edidc.

DATA : git_edidc TYPE STANDARD TABLE OF ty_int_edidc ##NEEDED .

DATA : gwa_edidc TYPE ty_int_edidc ##NEEDED .

SELECTION-SCREEN BEGIN OF BLOCK sel1
                          WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_cretim  FOR edidc-cretim DEFAULT gv_time_0 TO gv_time_24. " IDoc Created at
SELECT-OPTIONS: s_credat  FOR edidc-credat DEFAULT sy-datum TO sy-datum,    " IDoc Created On
                s_updtim  FOR edidc-updtim DEFAULT gv_time_0 TO gv_time_24, " Time at which control record was last changed
                s_upddat  FOR edidc-upddat.                                 " Date on which control record was last changed
SELECTION-SCREEN SKIP.
SELECT-OPTIONS:                                          "direct  FOR edidc-direct NO-EXTENSION NO INTERVALS, " Direction for IDoc
                s_docnum  FOR edidc-docnum,              " IDoc number
                s_status  FOR edidc-status DEFAULT '30'. " Status of IDoc
SELECTION-SCREEN SKIP.
SELECT-OPTIONS: s_idoctp  FOR edidc-idoctp, " Basic type
                s_cimtyp  FOR edidc-cimtyp, " Extension
                s_mestyp  FOR edidc-mestyp, " Message Type
                s_mescod  FOR edidc-mescod, " Logical Message Variant
                s_mesfct  FOR edidc-mesfct. " Logical message function
SELECTION-SCREEN SKIP.
PARAMETERS : p_max TYPE i DEFAULT '5000'. " Created On
SELECTION-SCREEN SKIP.
SELECTION-SCREEN END OF BLOCK sel1.


SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK sel2
                          WITH FRAME TITLE text-002.
PARAMETERS:     p_queue    TYPE ediqo-qname,                    " Complete Queue Name
                p_compl    TYPE edi_help2-komplett DEFAULT 'Y', " Dispatch Completely
                p_rcvpor   TYPE edd13-rcvpor,                   " Receiver port
                p_rcvprt   TYPE edpp1-partyp,                   " Partner Type
                p_rcvpfc   TYPE edidc-rcvpfc.                   " Partner Function of Receiver
SELECT-OPTIONS: s_rcvprn FOR edidc-rcvprn. " Partner Number of Receiver

SELECTION-SCREEN SKIP.
PARAMETERS:
      p_outmod       TYPE edidc-outmod, " Output Mode
      p_test         TYPE edidc-test.   " Test Flag
SELECTION-SCREEN SKIP.
PARAMETERS:
      p_anzahl       TYPE edi_help2-anzahl DEFAULT 5000. " Data element for number_IDoc
PARAMETERS:
      p_show_w       TYPE edi_help-onl_option DEFAULT 'O' NO-DISPLAY. " EDI processing online or in batch
SELECTION-SCREEN END OF BLOCK sel2.


DATA: git_idoc  TYPE RANGE OF edidc-docnum ##NEEDED,  " IDoc number
      gwa_idoc  LIKE LINE OF git_idoc ##NEEDED,
      gv_max    TYPE i ##NEEDED,            " Max of type Integers
      gv_line   TYPE i ##NEEDED ,            " Line of type Integers
      gv_count             TYPE i ##NEEDED, " Count of type Integers
      gv_current_rc        TYPE i ##NEEDED, " Current_rc of type Integers
      gv_last              TYPE i ##NEEDED, " Max of type Integers
      gv_subm_count        TYPE i ##NEEDED, " Subm_count of type Integers
      gv_job_count         TYPE i ##NEEDED. " Loop_count of type Integers

RANGES : gwa_msgty FOR edidc-mestyp. " Message Type

TYPES: BEGIN OF ty_jobs,
           jobname TYPE tbtcjob-jobname, " Background job name
           count   TYPE i,               " Count of type Integers
        END OF ty_jobs.

DATA : git_job TYPE STANDARD TABLE OF ty_jobs ##NEEDED,
       gwa_job TYPE ty_jobs ##NEEDED .
