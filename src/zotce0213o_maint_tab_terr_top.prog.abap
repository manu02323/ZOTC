************************************************************************
* PROGRAM    :  ZOTCE0213O_MAINT_TAB_TERRASSN                          *
* TITLE      :  Program to maintain Territory Assignment table         *
* DEVELOPER  :  Mayukh CHatterjee                                      *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
*  WRICEF ID :  D2_OTC_EDD_0213                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Program for online maintenance of Territory Assignment *
*               table                                                  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 02-OCT-2014 MCHATTE  E2DK904939  INITIAL DEVELOPMENT                 *
* 03-MAY-2016 SBEHERA  E2DK917651  Defect#1461 : 1.Radio button Display*
*                                  Added with display functionality    *
*                                  2.Customer name column is added in  *
*                                    the report output                 *
*                                  3.Download option with download     *
*                                    functionality added in application*
*                                    toolbar in report output          *
*                                  4.Screen display of the output      *
*                                    changed to full screen            *
*                                  5.Remove error message at the time  *
*                                    of any change in the report output*
*                                  6.Duplicate entries removed in the  *
*                                    report output while opening and   *
*                                    closing configuration             *
* 16-DEC-2016 SMUKHER4 E2DK919885  Defect#2210 : Discarding the        *
*                                  duplicate entries and keeping only  *
*                                  the modified ones.
* 12-JUN-2017 U033959 E1DK927361  Defect#2496/SCTASK0537273 -          *
*                                 Customer account group should        *
*                                 be fetched from EMI                  *
*                                 while validating customer            *
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
* 25-May-2018 SMUKHER E1DK936893  Defect# 6019: The wrong employee name*
*                                 is showing in the territory assignment
*                                 when there is a case of expired user *
*&---------------------------------------------------------------------*
*&  Include           ZOTCE0213O_MAINT_TAB_TERR_TOP
*&---------------------------------------------------------------------*

***-----------Structure Declaration------------*****
TYPES: BEGIN OF ty_custname,
         kunnr TYPE kna1-kunnr,                      " Customer Number
         name1 TYPE kna1-name1,                      " Name 1
         adrnr TYPE ad_addrnum,                      " Address number
       END OF ty_custname,

       BEGIN OF ty_custadr,
         addrnumber TYPE ad_addrnum,                 " Address number
         house_num1 TYPE  ad_hsnm1,                  " House Number
         street TYPE  ad_street,                     " Street
         city1  TYPE  ad_city1,                      " City
         region TYPE  regio,                         " Region (State, Province, County)
         post_code1 TYPE  ad_pstcd1,                 " City postal code
         country  TYPE  land1,                       " Country Key
         str_suppl1 TYPE  ad_strspp1,                " Street 2
         str_suppl2 TYPE  ad_strspp2,                " Street 3
         building TYPE  ad_bldng,                    " Building (Number or Code)
         floor  TYPE  ad_floor,                      " Floor in building
         roomnumber TYPE  ad_roomnum,                " Room or Appartment Number
         po_box TYPE  ad_pobx,                       " PO Box
       END OF ty_custadr,

       BEGIN OF ty_empname,
         lifnr TYPE lfa1-lifnr,                      " Account Number of Vendor or Creditor
         name1 TYPE lfa1-name1,                      " Name 1
       END OF ty_empname,

       BEGIN OF ty_addr,
         kunnr TYPE kunnr,                           " Customer Number
         house_num1 TYPE  ad_hsnm1,                  " House Number
         street  TYPE  ad_street,                    " Street
         city1 TYPE  ad_city1,                       " City
         region  TYPE  regio,                        " Region (State, Province, County)
         post_code1  TYPE ad_pstcd1,                 " City postal code
         country  TYPE  land1,                       " Country Key
         str_suppl1  TYPE ad_strspp1,                " Street 2
         str_suppl2  TYPE ad_strspp2,                " Street 3
         building  TYPE ad_bldng,                    " Building (Number or Code)
         floor  TYPE  ad_floor,                      " Floor in building
         roomnumber  TYPE ad_roomnum,                " Room or Appartment Number
         po_box  TYPE ad_pobx,                       " PO Box
       END OF ty_addr,

       BEGIN OF ty_emp,
         vkorg  TYPE vkorg,                          " Sales Organization
         vtweg  TYPE vtweg,                          " Distribution Channel
         spart  TYPE spart,                          " Division
         territory_id	TYPE zterritory_id,
         empid  TYPE zempid,                         " Employee ID
*&-- Begin of changes for D3_OTC_EDD_0213 Defect# 6019 by SMUKHER on 25-May-2018
         effective_from TYPE zeffect_date,           " Effective From
         effective_to  TYPE zexpiry_date,             " Effective To
*&-- End of changes for D3_OTC_EDD_0213 Defect# 6019 by SMUKHER on 25-May-2018
       END OF ty_emp,
       BEGIN OF ty_partrole,
         partrole TYPE zpart_role,                   " Partner Role
         partrole_desc TYPE zpart_role_desc,         " Partner Role description
       END OF ty_partrole,
* ---> Begin of Insert for D3_OTC_EDD_0213 Defect#2496/SCTASK0537273 by U033959 on 12-JUN-2017
*--TYPES-------------------------------------------------------------*
       BEGIN OF ty_account_grp,
         sign   TYPE char1,                          " Sign
         option TYPE char2,                          " Option
         low    TYPE ktokd,                          " Low
         high   TYPE ktokd,                          " High
       END OF ty_account_grp,
* <--- End of Insert for D3_OTC_EDD_0213 Defect#2496/SCTASK0537273 by U033959 on 12-JUN-2017
       t_ty_addr TYPE TABLE OF ty_addr,
       t_ty_terrassn TYPE TABLE OF zotc_territ_assn. " Comm Group: Territory Assignment

***-----------Tables Declaration------------*****

TABLES: zotc_tabctrl_terrassn. " Struct for tab ctrl for Territory Assignment table

***-----------Table Control Declaration------------*****
CONTROLS tc_terrassn TYPE TABLEVIEW USING SCREEN 9001.

***-----------Global Varible Declaration------------*****
DATA: gv_vkorg TYPE tvko-vkorg,  " Sales Organization
      gv_vtweg TYPE tvtw-vtweg,  " Distribution Channel
      gv_spart TYPE tspa-spart,  " Division
      gv_terrid TYPE kna1-kunnr, " Customer Number
      gv_kunnr TYPE kunnr,       " Customer Number
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
      gv_terrid1  TYPE zterritory_id, " Partner Territory ID
      gv_partrole TYPE zpart_role,    " Partner Role
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
      gv_okcode TYPE sy-ucomm,               " Function code that PAI triggered
* ---> Begin of Insert for D3_OTC_EDD_0213_D3R2 by amangal
      gv_okcode2 TYPE sy-ucomm,              " Function code that PAI triggered for screen 9002
* ---> End of Insert for D2_OTC_EDD_0213_D3R2 by amangal
      gv_ind TYPE char1,                     " Ind of type CHAR1
      gv_tabctrl TYPE zotc_tabctrl_terrassn. " Struct for tab ctrl for Territory Assignment table


***------Internal table and Work Area Declaration----*****
DATA: i_tabctrl TYPE TABLE OF zotc_tabctrl_terrassn,  " Struct for tab ctrl for Territory Assignment table
      i_tabctrlx TYPE TABLE OF zotc_tabctrl_terrassn, " Struct for tab ctrl for Territory Assignment table
      wa_tabctrl TYPE zotc_tabctrl_terrassn,          " Struct for tab ctrl for Territory Assignment table
      i_terrassn_tmp TYPE t_ty_terrassn,
      wa_terrassn_tmp TYPE zotc_territ_assn,          " Comm Group: Territory Assignment
      i_final_save TYPE TABLE OF zotc_territ_assn,    " Comm Group: Territory Assignment
      wa_final_save TYPE zotc_territ_assn,            " Comm Group: Territory Assignment
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#2210 by SMUKHER4 on 16.12.2016
      wa_final_del     TYPE zotc_territ_assn, " Comm Group: Territory Assignment
* <--- End of Insert for D2_OTC_EDD_0213_Defect#2210 by SMUKHER4 on 16.12.2016
      wa_terrassn TYPE zotc_tabctrl_terrassn, " Struct for tab ctrl for Territory Assignment table
      i_custname TYPE TABLE OF ty_custname,
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
      i_custname1 TYPE TABLE OF ty_custname,
      i_emp_temp TYPE TABLE OF ty_emp ,
      i_custname_temp TYPE TABLE OF ty_custname,
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
      wa_custname TYPE ty_custname,
      i_custadr TYPE TABLE OF ty_custadr,
      wa_custadr TYPE ty_custadr,
      i_partrole TYPE TABLE OF ty_partrole,
      wa_partrole TYPE ty_partrole,
      i_emp TYPE TABLE OF ty_emp,
      wa_emp TYPE ty_emp,
      i_tabctrl_tmp TYPE TABLE OF zotc_tabctrl_terrassn, " Struct for tab ctrl for Territory Assignment table
      i_empname  TYPE TABLE OF ty_empname,
      wa_empname TYPE ty_empname,
* ---> Begin of Insert for D3_OTC_EDD_0213 Defect#2496/SCTASK0537273 by U033959 on 12-JUN-2017
      i_account_grp TYPE STANDARD TABLE OF ty_account_grp. " Table from customer account group
* <--- End of Insert for D3_OTC_EDD_0213 Defect#2496/SCTASK0537273 by U033959 on 12-JUN-2017

***-----------Constants Declaration------------*****
CONSTANTS: c_check TYPE char1 VALUE 'X',      " Check of type CHAR1
           c_rep TYPE ktokd VALUE 'ZREP',     " Customer Account Group
           c_soldto TYPE ktokd VALUE 'Z001',  " Customer Account Group
           c_shipto TYPE ktokd VALUE 'Z002',  " Customer Account Group
           c_onli TYPE sy-ucomm VALUE 'ONLI', " Function code that PAI triggered
           c_add TYPE char1 VALUE 'A',        " Add of type CHAR1
           c_change TYPE char1 VALUE 'C',     " Change of type CHAR1
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
           c_disp TYPE char1 VALUE 'D',        " Display of type CHAR1
           c_group1 TYPE char3 VALUE 'GR1',    " Screen Group1
           c_group2 TYPE char3 VALUE 'GR2',    " Screen Group1
           c_download TYPE char4 VALUE 'DOWN', " Download
           c_grp_pk TYPE char2 VALUE 'PK',     " Screen Group PK
           c_grp_sk TYPE char2 VALUE 'SK',     " Screen Group SK
* ---> End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
* ---> Begin of Insert for D3_OTC_EDD_0213 Defect#2496/SCTASK0537273 by U033959 on 12-JUN-2017
           c_i             TYPE char1         VALUE 'I', " Sign I
           c_eq            TYPE char2         VALUE 'EQ'." Option EQ
* <--- End of Insert for D3_OTC_EDD_0213 Defect#2496/SCTASK0537273 by U033959 on 12-JUN-2017

* ---> Begin of Insert for D2_OTC_EDD_0213_D3R2 by amangal

DATA: lv_effdate_fr TYPE sy-datum, " Effective date from
      lv_effdate_to TYPE sy-datum, " Effective date to
      lv_cancel     TYPE flag.     " Cancel flag

CONSTANTS: c_apply TYPE char5 VALUE 'APPLY'. " Mass Change Date button

* ---> End of Insert for D2_OTC_EDD_0213_D3R2 by amangal
