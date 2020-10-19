************************************************************************
* Include    :  ZOTC0213B_STORAGEBIN_TOP                               *
* TITLE      :  D2_OTC_EDD_0213_Commision Group Sales Role assignment  *
* DEVELOPER  :  Nic Lira                                               *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :    D2_OTC_EDD_0213                                      *
*----------------------------------------------------------------------*
* DESCRIPTION: Update table ZOTC_TERRIT_ASSN from tab delimited file.  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 29-Sep-2014  NLIRA   E2DK904939 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*
* 19-JUL-2016 PDEBARU E2DK917651  Defect # 1461 : Fut Issue : change  *
*                                  pointer included                    *
*&---------------------------------------------------------------------*
* 27-APR-2017 U029267 E1DK927361  Defect#2496 / INC0322445 :           *
*                                 1)Change pointer to be replaced by   *
*                                    BD12 call program.                *
*                                 2)Technical change to lock the       *
*                                   'Created on/Created by' flds on    *
*                                   Commission & Territory tab.        *
*                                 3)Territories duplicating incorrectly*
*                                   in the OTC territory tables in     *
*                                   T-Code ZOTC_MAINT_TERRASSN         *
*                                   (Old Def- 2210).                   *
*                                 4)Enhance t-code:ZOTC_MAINT_TERRASSN *
*                                   to be able to restrict to DISPLAY  *
*                                   only (Old Defect: 2209).           *
*                                 5)In the Display session of T-Code   *
*                                   ZOTC_MAINT_TERRASSN we can only see*
*                                  Canada sales org 1020.(Old Def-2211)*
*&---------------------------------------------------------------------*
*18-SEP-2017 amangal E1DK930689  D3R2 Changes
*                                1. Allow mass update of date fields in*
*                                   Maintenance transaction            *
*                                2. Allow Load from AL11 with effective*
*                                   dates populated and properly       *
*                                   formatted                          *
*                                3.	Control the sending of IDoc on     *
*                                   request                            *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZOTC0213B_STORAGEBIN_TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   data definition
*----------------------------------------------------------------------*
TYPES :
** Begin of D3R2
       BEGIN OF ty_filedata,
          vkorg           TYPE zotc_territ_assn-vkorg,          " Sales Organization
          vtweg           TYPE zotc_territ_assn-vtweg,          " Distribution Channel
          spart           TYPE zotc_territ_assn-spart,          " Division
          kunnr           TYPE zotc_territ_assn-kunnr,          " Customer Number
          territory_id    TYPE zotc_territ_assn-territory_id,   " Partner Territory ID
          partrole        TYPE zotc_territ_assn-partrole,       " Partner Role
          effective_from  TYPE zotc_territ_assn-effective_from, " Effective From
          effective_to    TYPE zotc_territ_assn-effective_to,   " Effective To
        END OF ty_filedata,
*End of D3R2
        BEGIN OF ty_report,                                     "Final Report Display Structure
          msgtyp TYPE char1,                                    "Message Type E / S
          msgtxt TYPE string,                                   "Message Text
          key    TYPE string,                                   "Key of message
        END OF ty_report.

TYPES: BEGIN OF ty_customers,
        kunnr   TYPE kna1-kunnr, " Customer Number
       END OF ty_customers,
       BEGIN OF ty_errors,
         error(80),
       END OF ty_errors,
       BEGIN OF ty_display_data,
         data(80),
       END OF ty_display_data.

TYPES: BEGIN OF ty_tvtw,
       vtweg TYPE tvtw-vtweg, " Distribution Channel
       END OF ty_tvtw.

TYPES: BEGIN OF ty_tspa,
       spart TYPE tspa-spart, " Division
       END OF ty_tspa.

TYPES: BEGIN OF ty_partrole,
       partrole TYPE zotc_part_role-partrole, " Partner Role
       END OF ty_partrole,
*--> Begin of change for D2_OTC_EDD_0213 Defect # 1461 by PDEBARU on 19/07/2016
 ty_t_assn3 TYPE STANDARD TABLE OF zotc_territ_assn. " Comm Group: Territory Assignment

*<-- End of change for D2_OTC_EDD_0213 Defect # 1461 by PDEBARU on 19/07/2016

* Constants Decrartion
CONSTANTS:
     BEGIN OF c_upload_lagps,
      tab1 TYPE sy-ucomm VALUE 'DISPLAY',                                  "The Loaded sorting tab
      tab2 TYPE sy-ucomm VALUE 'SHWR',                                     "The Successful chages tab user command
      tab3 TYPE sy-ucomm VALUE 'SHWF',                                     "The failed record  tab user command
     END OF c_upload_lagps,
     c_filetype   TYPE char10 VALUE 'ASC',                                 " The ascii file type
     c_group1     TYPE char3  VALUE 'APS',                                 " Apllication server group
     c_group2     TYPE char3  VALUE 'PRS',                                 " presentation server group
     c_delimiter  TYPE char1  VALUE ',',                                   " delimiter for split
     c_ext        TYPE char3 VALUE 'CSV',                                  " file extension.
     c_txt        TYPE char3 VALUE 'TXT',                                  " file extension.
*Begin of D3_OTC_EDD_0213 D3R2
     c_csv        TYPE char3 VALUE 'CSV',                                  " csv file extension
*End of D3_OTC_EDD_0213 D3R2
     c_tab        TYPE char1 VALUE cl_abap_char_utilities=>horizontal_tab, "for tab
     c_tbp_fld    TYPE char5 VALUE 'TBP',                                  " constant declaration for TBP folder
     c_error_fld  TYPE char5 VALUE 'ERROR',                                " ERROR folder
     c_done_fld   TYPE char5 VALUE 'DONE',                                 " DONE folder
     c_mode       TYPE char1    VALUE 'N',                                 " screen calling mode
     c_upd        TYPE char01   VALUE 'A',                                 " Update mode
     c_type       TYPE char1    VALUE 'E',                                 " Message type
     c_dynnr1     TYPE sy-dynnr VALUE '0101',                              " Screen 101
     c_dynnr2     TYPE sy-dynnr VALUE '0102',                              " Screen 102
     c_dynnr3     TYPE sy-dynnr VALUE '0103',                              " Screen 103
     c_smsg       TYPE char1    VALUE 'S',                                 " 'S' success message type
     c_status     TYPE char12   VALUE 'STATUS0200',                        " for the status 1
     c_status2    TYPE char12   VALUE 'STATUS0100',                        " for the status 2
     c_back       TYPE char4    VALUE 'BACK',                              " user command back
     c_struct     TYPE tabname  VALUE 'ZOTC_TERRIT_ASSN',                  " Binmaster structure.
     c_effective_to TYPE zotc_territ_assn-effective_to VALUE '99991231'.   " Effective To

DATA:
   BEGIN OF x_upload_lagps,
    subscreen   TYPE sy-dynnr,                                      " Sub screen no
    prog        TYPE sy-repid VALUE 'ZOTCE0213B_COMM_GRP_SLS_ROLE', " Report name
    pressed_tab TYPE sy-ucomm VALUE c_upload_lagps-tab1,            " Pressed tab whether display file/Successful records/error records
   END OF x_upload_lagps.

DATA :
        gv_rc                   TYPE sy-subrc,                                     " Return Value of ABAP Statements
        i_filedata              TYPE STANDARD TABLE OF ty_filedata INITIAL SIZE 0,
        wa_filedata             TYPE ty_filedata,
        i_bindata               TYPE STANDARD TABLE OF ty_filedata INITIAL SIZE 0,
        i_ebinfore              TYPE STANDARD TABLE OF ty_filedata INITIAL SIZE 0,
        i_ebindata              TYPE STANDARD TABLE OF ty_filedata INITIAL SIZE 0,
        i_sbindata              TYPE STANDARD TABLE OF ty_filedata INITIAL SIZE 0,
        wa_bindata              TYPE ty_filedata,
        wa_ebindata             TYPE ty_filedata,
        i_log                   TYPE STANDARD TABLE OF ty_report INITIAL SIZE 0,   " To show final log in spool
        wa_log                  TYPE ty_report,                                    " To show final log in spool
        gv_index                TYPE char8,                                        "Table index
        gv_mode                 TYPE char10,                                       "Mode of transaction
        gv_scount               TYPE int4,                                         " Succes Count
        gv_ecount               TYPE int4,                                         " Error Count
        gv_header               TYPE localfile,                                    " Header
        i_bdcdata               TYPE STANDARD TABLE OF bdcdata INITIAL SIZE 0,     " For BDC recording.
        i_lagps                 TYPE STANDARD TABLE OF ty_filedata INITIAL SIZE 0, "To display the records.
        i_lagps1                TYPE STANDARD TABLE OF ty_filedata INITIAL SIZE 0, "To display all the file records.
*       messages of call transaction
        i_messtab               TYPE STANDARD TABLE OF bdcmsgcoll INITIAL SIZE 0, " Collecting messages in the SAP System
        wa_bdcdata              TYPE bdcdata,                                     " Batch input: New table field structure
* Dynpro 100
        gv_container            TYPE REF TO cl_gui_custom_container, "Reference for container
        gv_alv                  TYPE REF TO cl_gui_alv_grid,         "Reference for grid display on container
        gv_chk                  TYPE int2,                           "Checking whether the screen initiated
                                                                     "file that should be uploaded
        gv_ok_code              TYPE sy-ucomm,                       "Ok code from screen
        gv_first_call           TYPE char1,                          " First call check for screen
* ---> Begin of Insert for D3_OTC_EDD_0213_Defect#2496 by u029267 on 27-Apr-2017
        gv_records              TYPE char5.                           " no of records maintained in EMI
* <--- End of Insert for D3_OTC_EDD_0213_Defect#2496 by u029267 on 27-Apr-2017

DATA:
        i_territory_assn  TYPE STANDARD TABLE OF zotc_territ_assn, " Comm Group: Territory Assignment
        i_territory_assn3 TYPE STANDARD TABLE OF zotc_territ_assn, " Comm Group: Territory Assignment
        i_oldvalues       TYPE STANDARD TABLE OF zotc_territ_assn, "Old value table  " Defect 1461
        wa_territory_assn TYPE zotc_territ_assn,                   " Comm Group: Territory Assignment
        i_customers       TYPE STANDARD TABLE OF ty_customers,
        wa_customers      TYPE ty_customers,
        i_errors          TYPE STANDARD TABLE OF ty_errors,
        i_display_data    TYPE STANDARD TABLE OF ty_display_data,
        i_tvtw            TYPE TABLE OF ty_tvtw ,
        wa_tvtw           TYPE ty_tvtw ,
        i_tspa            TYPE TABLE OF ty_tspa ,
        wa_tspa           TYPE ty_tspa,
        i_partrole        TYPE TABLE OF ty_partrole ,
        wa_partrole       TYPE ty_partrole,
        wa_display_data   TYPE ty_display_data,
        wa_errors         TYPE ty_errors,
        gv_error_line     TYPE i,                                  " Error_line of type Integers
        gv_recs_loaded    TYPE i,                                  " Recs_loaded of type Integers
        gv_value(10),
        gv_field(30),
        gv_len            TYPE i,                                  " Len of type Integers
        gv_num            TYPE i,                                  " Num of type Integers
        gv_flag,
        gv_vkorg          TYPE tvko-vkorg,                         " Sales Organization
        gv_kunnr          TYPE kna1-kunnr,                         " Customer Number
        gv_vtweg          TYPE tvtw-vtweg,                         " Distribution Channel
        gv_spart          TYPE tspa-spart,                         " Division
        gv_partrole       TYPE zotc_part_role-partrole.            " Partner Role

DATA: i_fieldcatalog      TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      i_tab_group         TYPE slis_t_sp_group_alv,
      i_layout            TYPE slis_layout_alv,
      gv_repid            TYPE sy-repid,
      i_events            TYPE slis_t_event,
      i_prntparams        TYPE slis_print_alv.
* Tabstrip Control parameters
CONTROLS:  upload_lagps   TYPE TABSTRIP. " Structure of tab data in flexible detail display
