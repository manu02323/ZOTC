************************************************************************
* PROGRAM    :  ZOTCE0213O_MAINT_TAB_PART2EMP                          *
* TITLE      :  Program to maintain Partner to Employee table          *
* DEVELOPER  :  Mayukh CHatterjee                                      *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
*  WRICEF ID :  D2_OTC_EDD_0213                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Program for online maintenance of  Partner to Employee *
*               table                                                  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 02-OCT-2014 MCHATTE  E2DK904939  INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZOTCE0213O_MAINT_TAB_P2E_TOP
*&---------------------------------------------------------------------*

***-----------Structure Declaration------------*****
TYPES: BEGIN OF ty_tabctrl,
          vkorg TYPE zotc_part_to_emp-vkorg,                   " Sales Organization
          vtweg TYPE zotc_part_to_emp-vtweg,                   " Distribution Channel
          spart TYPE zotc_part_to_emp-spart,                   " Division
          territory_id TYPE zotc_part_to_emp-territory_id,     " Partner Territory ID
          empid TYPE zotc_part_to_emp-empid,                   " Employee ID
          effective_from TYPE zotc_part_to_emp-effective_from, " Effective From
          effective_to TYPE zotc_part_to_emp-effective_to,     " Effective To
          territory_id_name TYPE kna1-name1,                   " Name 1
          empname TYPE lfa1-name1,                             " Name 1
       END OF ty_tabctrl,

       BEGIN OF ty_custname,
         kunnr TYPE kna1-kunnr,                                " Customer Number
         name1 TYPE kna1-name1,                                " Name 1
       END OF ty_custname,

       BEGIN OF ty_vendname,
         lifnr TYPE lfa1-lifnr,                                " Account Number of Vendor or Creditor
         name1 TYPE lfa1-name1,                                " Name 1
       END OF ty_vendname,

       t_ty_partemp TYPE TABLE OF zotc_part_to_emp.            " Comm Group: XREF Partner to Employee

***-----------Tables Declaration------------*****
TABLES: zotc_tabctrl_part2emp. " Struct for tab ctrl for Part 2 Emp table

***-----------Table Control Declaration------------*****
CONTROLS tc_partemp TYPE TABLEVIEW USING SCREEN 9001.

***-----------Global Varible Declaration------------*****
DATA: gv_vkorg TYPE tvko-vkorg,              " Sales Organization
      gv_vtweg TYPE tvtw-vtweg,              " Distribution Channel
      gv_spart TYPE tspa-spart,              " Division
      gv_terrid TYPE kna1-kunnr,             " Customer Number
      gv_okcode TYPE sy-ucomm,               " Function code that PAI triggered
      gv_ind TYPE char1,                     " Ind of type CHAR1
      gv_tabctrl TYPE zotc_tabctrl_part2emp. " Struct for tab ctrl for Part 2 Emp table

***------Internal table and Work Area Declaration----*****
DATA: i_tabctrl TYPE TABLE OF zotc_tabctrl_part2emp,  " Struct for tab ctrl for Part 2 Emp table
      i_tabctrlx TYPE TABLE OF zotc_tabctrl_part2emp, " Struct for tab ctrl for Part 2 Emp table
      wa_tabctrl TYPE zotc_tabctrl_part2emp,          " Struct for tab ctrl for Part 2 Emp table
      i_partemp_tmp TYPE t_ty_partemp,
      wa_partemp_tmp TYPE zotc_part_to_emp,           " Comm Group: XREF Partner to Employee
      i_final_save TYPE TABLE OF zotc_part_to_emp,    " Comm Group: XREF Partner to Employee
      wa_final_save TYPE zotc_part_to_emp,            " Comm Group: XREF Partner to Employee
      wa_partemp TYPE zotc_tabctrl_part2emp,          " Struct for tab ctrl for Part 2 Emp table
      i_custname TYPE TABLE OF ty_custname,
      wa_custname TYPE ty_custname,
      i_tabctrl_tmp TYPE TABLE OF zotc_tabctrl_part2emp, " Struct for tab ctrl for Part 2 Emp table
      i_vendname TYPE TABLE OF ty_vendname,
      wa_vendname TYPE ty_vendname.

***-----------Constants Declaration------------*****
CONSTANTS: c_check TYPE char1 VALUE 'X',  " Check of type CHAR1
           c_rep TYPE ktokd VALUE 'ZREP',
           c_onli TYPE sy-ucomm VALUE 'ONLI',
           c_add TYPE char1 VALUE 'A',    " Add of type CHAR1
           c_change TYPE char1 VALUE 'C'. " Change of type CHAR1
