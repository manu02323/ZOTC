*&---------------------------------------------------------------------*
*&  Include           ZOTCN014O_GPO_ROASTER_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCR0014O_GPO_ROASTER_UPLOAD                           *
* TITLE      :  OTC_IDD_0014_GPO Roaster Upload                        *
* DEVELOPER  :  Kiran R Durshanapally                                  *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_0014_Upload GPO Roster
*----------------------------------------------------------------------*
* DESCRIPTION: Uploading GPO Roaster into Customer Master              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 03-APR-2012 KDURSHA  E1DK900679 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*

*       Type Declarations

*       Input File Structure with GPO Info
TYPES:  BEGIN OF ty_gporoaster_info,
         KUNNR Type KUNNR,      "Customer Number/GPO Number
         VKORG type vkorg,      "Sales Organization
         VTWEG type VTWEG,      "Distribution Channel
         SPART type SPART,      "Division
         NAME1 Type NAME1_GP,   "Customer Name
         KDKG1 Type KDKG1,      "Customer Condition grp1
         KDKG2 Type KDKG2,      "Customer Condition grp2
         KDKG3 Type KDKG3,      "Customer Condition grp3
         KVGR1 Type KVGR1,      "Customer grp1
         KVGR2 Type KVGR2,      "Customer grp2
         KDGRP TYPE KDGRP,      "Customer group
        END OF ty_gporoaster_info,

*       Error File Structure with GPO Info
        BEGIN OF ty_input_e,
         KUNNR Type KUNNR,      "Customer Number/GPO Number
         VKORG type vkorg,      "Sales Organization
         VTWEG type VTWEG,      "Distribution Channel
         SPART type SPART,      "Division
         NAME1 Type NAME1_GP,   "Customer Name
         KDKG1 Type KDKG1,      "Customer Condition grp1
         KDKG2 Type KDKG2,      "Customer Condition grp2
         KDKG3 Type KDKG3,      "Customer Condition grp3
         KVGR1 Type KVGR1,      "Customer grp1
         KVGR2 Type KVGR2,      "Customer grp2
         KDGRP TYPE KDGRP,      "Customer group
         err_msg type string,
        END OF ty_input_e,

*       Final Report Display Structure
        BEGIN OF ty_report,
          msgtyp TYPE char1,   "Message Type
          pos    TYPE char6,   "Position - Hedaer / Item
          msgtxt TYPE string,  "Message Text
          key    TYPE string,  "Message Key
        END OF ty_report,

*        Type for BDCDATA
         ty_bdcdata TYPE bdcdata.  "BDC data type

*        Used to stores error information from CALL TRANSACTION Function Module

        DATA: BEGIN OF messtab OCCURS 0.
        INCLUDE STRUCTURE bdcmsgcoll.
        DATA: END OF messtab.

*       Table Type Declaration
  TYPES: ty_t_gporoaster_info TYPE STANDARD TABLE OF ty_gporoaster_info, "GPO Information
         ty_t_report          type standard table of ty_report,          "Report
         ty_t_input_e         TYPE STANDARD TABLE OF ty_input_e,         "Work Area for errored records
         ty_t_bdcdata         TYPE STANDARD TABLE OF ty_bdcdata.         "BDC Data


*       Internal Table Declaration
DATA: i_gporoaster_info TYPE  ty_t_gporoaster_info,  "GPO Information
      i_report          TYPE  ty_t_report,           "Report Internal Table
      i_succ_report     type ty_t_gporoaster_info,   "Success Report
      i_error_report    type ty_t_input_e.           "Error Report


*       Global Work Area Declaration
DATA: wa_gporoaster_info TYPE ty_gporoaster_info, "Work Area for GPO Roaster Info
      wa_succ_report     TYPE ty_gporoaster_info, "Work Area for Success Report
      wa_error_report    TYPE ty_input_e,         "Work Area for error Report
      wa_report          TYPE ty_report.          "Work Area for Report

*       Constants
DATA : c_scol         TYPE i VALUE '1',               "Start Column value
       c_srow         TYPE i VALUE '2',               "Start Row value
       c_ecol         TYPE i VALUE '256',             "End Column value
       c_erow         TYPE i VALUE '65536',           "End Row value
       c_text_pres    TYPE char3 VALUE 'XLS',         "TXT value
       c_text_appl    TYPE char3 VALUE 'CSV',         "CSV value
       c_seson        TYPE char5 VALUE 'OTC14',       "OTC14
       c_error        TYPE char1 VALUE 'E',           "Success Indicator
       c_tcode        TYPE sytcode VALUE 'XD02',      "T-code to upload
       c_comma        type char1 value ',',           "Comma Value
       C_CRLF         TYPE CHAR1 VALUE CL_ABAP_CHAR_UTILITIES=>CR_LF,
       c_lp_ind       TYPE char1 VALUE 'X',           "X = Logical File Path
       c_compcode     type char4 VALUE '1000'.        "Company code

*       Variable Declarations
DATA: gv_mkey             TYPE string,          "Message Key
      gv_mtext            TYPE string,          "Message Text
      gv_flag_err         TYPE char1,           "Flag to check if file has error
      gv_session_1        type apq_grpn,        "BDC Session 1
      gv_succ_update      type i,
      gv_lines            type i,
      gv_file             TYPE localfile.       "File name
