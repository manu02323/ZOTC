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
* 22-Dec-2014 MBHATTA1 E2DK904939  Defect# 2653 OTC Commission Tables  *
*                                  to have Changed On Date Field always*
*                                  populated                           *
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
*                                                                      *
* 16-DEC-2016 SMUKHER4 E2DK919885  Defect#2210 : Discarding the        *
*                                  duplicate entries and keeping only  *
*                                  the modified ones.
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
*----------------------------------------------------------------------*
* 12-JUN-2017 U033959 E1DK927361  Defect#2496/SCTASK0537273 -          *
*                                 Customer account group should        *
*                                 be fetched from EMI                  *
*                                 while validating customer            *
*&---------------------------------------------------------------------*
* 25-SEP-2017 ASK E1DK930990  Defect#3534 Data is getting deleted from *
*                                 custom table when in ADD mode data is*
*                                 entered using PAGE DOWN option.This  *
*                                 code change will fix that            *
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
*                                 when there is a case of expired user.*
*&---------------------------------------------------------------------*
* 16-May-2019 U105654 E2DK923970  Defect# 8248: Territory Assignment   *
*                                 Tables Accepts Customer Which Doesn't*
*                                 Exist in a Particular Sales Area     *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           ZOTCE0213O_MAINT_TAB_TERR_SUB
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_HIDE_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hide_fields .
* For Radio button Add hide all the input fields as blank table control
*needs to be displayed
* ---> Begin of Delete for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
*  LOOP AT SCREEN.
*    IF screen-group1 = 'GR1'.
*      IF rb_add = c_check.
*        screen-active = 0.
*      ELSE. " ELSE -> IF rb_add = c_check
*        screen-active = 1.
*      ENDIF. " IF rb_add = c_check
*      MODIFY SCREEN.
*    ENDIF. " IF screen-group1 = 'GR1'
*  ENDLOOP. " LOOP AT SCREEN
* <--- End of Delete for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
*  When one radio button selected hide all other input fields as
* blank table control needs to be displayed
  LOOP AT SCREEN.
    IF screen-group1 = c_group1 AND rb_add = c_check.
      screen-active = 0.
      MODIFY SCREEN.
      CONTINUE.
    ELSEIF screen-group1 = c_group1 AND rb_dis = c_check.
      screen-active = 0.
      MODIFY SCREEN.
      CONTINUE.
    ELSEIF screen-group1 = c_group1 AND rb_chg = c_check.
      screen-active = 1.
      MODIFY SCREEN.
      CONTINUE.
    ELSEIF screen-group1 = c_group2 AND rb_chg = c_check.
      screen-active = 0.
      MODIFY SCREEN.
      CONTINUE.
    ELSEIF screen-group1 = c_group2 AND rb_add = c_check.
      screen-active = 0.
      MODIFY SCREEN.
      CONTINUE.
    ELSEIF screen-group1 = c_group2 AND rb_dis = c_check.
      screen-active = 1.
      MODIFY SCREEN.
      CONTINUE.
    ENDIF. " IF screen-group1 = c_group1 AND rb_add = c_check
  ENDLOOP. " LOOP AT SCREEN
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
ENDFORM. " F_HIDE_FIELDS
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SALESORG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_salesorg
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
                         USING fp_vkorg  LIKE s_vkorg[].
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  DATA: lv_vkorg TYPE tvko-vkorg. " Sales Organization
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  IF fp_vkorg[] IS NOT INITIAL.
* <--- End of insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
    SELECT vkorg UP TO 1 ROWS
    INTO lv_vkorg
    FROM tvko " Organizational Unit: Sales Organizations
    WHERE vkorg IN
* ---> Begin of Delete for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
*                  s_vkorg.
* <--- End of Delete for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
                   fp_vkorg.
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
    ENDSELECT.
    IF sy-subrc <> 0.
      MESSAGE e000 WITH 'Enter valid Sales Org.'(e00).
    ENDIF. " IF sy-subrc <> 0
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  ENDIF. " IF fp_vkorg[] IS NOT INITIAL
* <--- End of insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
ENDFORM. " F_VALIDATE_SALESORG
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DIST_CHANNEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_dist_channel
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
                            USING fp_vtweg  LIKE s_vtweg[].
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  DATA: lv_vtweg TYPE vtweg. " Distribution Channel
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  IF fp_vtweg[] IS NOT INITIAL.
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
    SELECT vtweg UP TO 1 ROWS
        INTO lv_vtweg
        FROM tvtw " Organizational Unit: Distribution Channels
        WHERE vtweg IN
* ---> Begin of Delete for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
*                      s_vtweg.
* <--- End of Delete for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
                       fp_vtweg.
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
    ENDSELECT.
    IF sy-subrc <> 0.
      MESSAGE e000 WITH 'Enter valid Distribution Channel'(e01).
    ENDIF. " IF sy-subrc <> 0
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  ENDIF. " IF fp_vtweg[] IS NOT INITIAL
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
ENDFORM. " F_VALIDATE_DIST_CHANNEL
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DIVISION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_division
* <--- Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
                         USING fp_spart LIKE s_spart[].
* ---> End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  DATA: lv_spart TYPE spart. " Division
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  IF fp_spart IS NOT INITIAL.
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
    SELECT spart UP TO 1 ROWS
      INTO lv_spart
      FROM tspa " Organizational Unit: Sales Divisions
      WHERE spart IN
* ---> Begin of Delete for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
*                    s_spart.
* <--- End of Delete for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
* <--- Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
                     fp_spart.
* ---> End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
    ENDSELECT.
    IF sy-subrc <> 0.
      MESSAGE e000 WITH 'Enter valid Division'(e03).
    ENDIF. " IF sy-subrc <> 0
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  ENDIF. " IF fp_spart IS NOT INITIAL
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
ENDFORM. " F_VALIDATE_DIVISION
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_CUSTACC_ID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_custacc_id
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
                           USING fp_kunnr LIKE s_kunnr[].
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  DATA: lv_kunnr TYPE kunnr. " Customer Number
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  IF fp_kunnr IS NOT INITIAL.
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
    SELECT kunnr UP TO 1 ROWS
      INTO lv_kunnr
      FROM kna1 " General Data in Customer Master
      WHERE kunnr IN
* ---> Begin of Delete for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
*                    s_kunnr
* <--- End of Delete for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
                     fp_kunnr
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
* ---> Begin of Delete for D3_OTC_EDD_0213 Defect#2496/SCTASK0537273 by U033959 on 12-Jun-2017
*      AND ktokd IN (c_soldto, c_shipto).
* <--- End of Delete for D3_OTC_EDD_0213 Defect#2496/SCTASK0537273 by U033959 on 12-Jun-2017
* ---> Begin of Insert for D3_OTC_EDD_0213 Defect#2496/SCTASK0537273 by U033959 on 12-Jun-2017
       AND ktokd IN i_account_grp.
* <--- End of Insert for D3_OTC_EDD_0213 Defect#2496/SCTASK0537273 by U033959 on 12-Jun-2017
    ENDSELECT.
    IF sy-subrc <> 0.
      MESSAGE e000 WITH 'Enter valid Customer Account Id'(e04).
    ENDIF. " IF sy-subrc <> 0
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  ENDIF. " IF fp_kunnr IS NOT INITIAL
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
ENDFORM. " F_VALIDATE_CUSTACC_ID
*&---------------------------------------------------------------------*
*&      Module  STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9001 OUTPUT.
  SET PF-STATUS 'ZSTAT_9001'.
  SET TITLEBAR 'TAS'.

ENDMODULE. " STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_data OUTPUT.
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  TYPES: BEGIN OF lty_custname,
           kunnr TYPE kunnr,      " Customer Number
           name1 TYPE name1,      " Name 1
           adrnr TYPE ad_addrnum, " Address number
         END OF lty_custname,
         BEGIN OF lty_cust,
           kunnr TYPE kunnr,      " Customer Number
         END OF lty_cust,
*-->Begin of Change for D3_OTC_EDD_0213_Defect#8248 by U105654 on 16-May-2019
         BEGIN OF lty_cust1,
           kunnr TYPE kunnr,      " Customer Number
           vkorg TYPE vkorg,      "Sales Organisation
           vtweg TYPE vtweg,      "Distribution Channel
           spart TYPE spart,      "Division
         END OF lty_cust1.
*<--End of Change for D3_OTC_EDD_0213_Defect#8248 by U105654 on 16-May-2019

  DATA :li_custname     TYPE STANDARD TABLE OF lty_custname INITIAL SIZE 0,
        li_terrassn_tmp TYPE STANDARD TABLE OF zotc_territ_assn INITIAL SIZE 0, " Comm Group: Territory Assignment
        li_cust         TYPE STANDARD TABLE OF lty_cust INITIAL SIZE 0,
        lwa_cust        TYPE lty_cust,
*-->Begin of Change for D3_OTC_EDD_0213_Defect#8248 by U105654 on 16-May-2019
        li_tabctrlx_tmp TYPE TABLE OF zotc_tabctrl_terrassn,
        li_cust1        TYPE STANDARD TABLE OF lty_cust1 INITIAL SIZE 0,
        lwa_cust1       TYPE lty_cust1,
        lwa_tabc        TYPE zotc_tabctrl_terrassn.
*<--End of Change for D3_OTC_EDD_0213_Defect#8248 by U105654 on 16-May-2019
* Field Symbol Declaration
  FIELD-SYMBOLS: <lfs_terrassn_tmp>  TYPE zotc_tabctrl_terrassn, " Comm Group: Territory Assignment
                 <lfs_terrassn_tmp1> TYPE zotc_territ_assn,     " Comm Group: Territory Assignment
                 <lfs_custadr>       TYPE ty_custadr,                 " Customer Address
                 <lfs_emp>           TYPE ty_emp,                     " Employee
                 <lfs_empname>       TYPE ty_empname,                 " Employee Name
                 <lfs_partrole>      TYPE ty_partrole,               " Partner Role
                 <lfs_custname>      TYPE lty_custname,              " Customer Table
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
* <--- Begin of Insert for D3_OTC_EDD_0213_D3R2 by amangal
                 <lfs_terrassn_eff>  TYPE zotc_tabctrl_terrassn.
* <--- End of Insert for D3_OTC_EDD_0213_D3R2 by amangal

*-->Begin of Change for D3_OTC_EDD_0213_Defect#8248 by U105654 on 16-May-2019
  CONSTANTS : lc_e TYPE char1 VALUE 'E'.     "Local Constant for type E error
*<--End of Change for D3_OTC_EDD_0213_Defect#8248 by U105654 on 16-May-2019

  IF gv_ind = c_change OR
     gv_ind = c_add. " Defect # 3534
*For add only blank screen is displayed, so no data retieval logic is reqd.
*Fetch data from Territory Assignment table based on the input
    IF i_tabctrlx[] IS INITIAL AND
       gv_ind = c_change. " Defect # 3534
      SELECT *
          FROM zotc_territ_assn " Comm Group: XREF Partner to Employee
          INTO TABLE i_terrassn_tmp
          WHERE vkorg IN s_vkorg[]
          AND vtweg IN s_vtweg[]
          AND spart IN s_spart[]
          AND kunnr IN s_kunnr[].

      IF sy-subrc = 0.
        LOOP AT i_terrassn_tmp INTO wa_terrassn_tmp.

          MOVE: wa_terrassn_tmp-vkorg TO wa_tabctrl-vkorg,
                wa_terrassn_tmp-vtweg TO wa_tabctrl-vtweg,
                wa_terrassn_tmp-spart TO wa_tabctrl-spart,
                wa_terrassn_tmp-kunnr TO wa_tabctrl-kunnr,
                wa_terrassn_tmp-territory_id TO wa_tabctrl-territory_id,
                wa_terrassn_tmp-partrole TO wa_tabctrl-partrole,
                wa_terrassn_tmp-effective_from TO wa_tabctrl-effective_from,
                wa_terrassn_tmp-effective_to TO wa_tabctrl-effective_to.

          APPEND wa_tabctrl TO i_tabctrlx.
        ENDLOOP. " LOOP AT i_terrassn_tmp INTO wa_terrassn_tmp
      ELSE. " ELSE -> IF sy-subrc = 0
*   Throw message if no data found
        MESSAGE i000 WITH TEXT-i01.
        LEAVE LIST-PROCESSING.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF i_tabctrlx[] IS INITIAL AND

*-->Begin of Change for D3_OTC_EDD_0213_Defect#8248 by U105654 on 16-May-2019
* Validating if Customer Number , Distribution Channel and Division relevant to Sales Organization from KNVV table
    IF i_tabctrlx[] IS NOT INITIAL.
      li_tabctrlx_tmp = i_tabctrlx.
      SORT li_tabctrlx_tmp BY kunnr vkorg vtweg spart.
      DELETE ADJACENT DUPLICATES FROM li_tabctrlx_tmp[] COMPARING kunnr vkorg vtweg spart.

      SELECT kunnr " Customer
             vkorg " Sales Organization
             vtweg " Distribution Channel
             spart " Division
        FROM knvv  " Customer Master Sales Data
        INTO TABLE li_cust1
        FOR ALL ENTRIES IN li_tabctrlx_tmp
        WHERE   kunnr = li_tabctrlx_tmp-kunnr
            AND vkorg = li_tabctrlx_tmp-vkorg
            AND vtweg = li_tabctrlx_tmp-vtweg
            AND spart = li_tabctrlx_tmp-spart.

      IF sy-subrc IS INITIAL.
        SORT li_cust1 BY kunnr vkorg vtweg spart.
        LOOP AT li_tabctrlx_tmp INTO lwa_tabc.
          READ TABLE li_cust1 INTO lwa_cust1 WITH KEY kunnr = lwa_tabc-kunnr
                                                      vkorg = lwa_tabc-vkorg
                                                      vtweg = lwa_tabc-vtweg
                                                      spart = lwa_tabc-spart
                                                      BINARY SEARCH.

          IF sy-subrc IS NOT INITIAL.
** If we can't find valid entry from customer master table KNVV with key
** combination, then populate the message.
            MESSAGE i890 WITH  lwa_tabc-kunnr
                               lwa_tabc-vkorg
                               lwa_tabc-vtweg
                               lwa_tabc-spart DISPLAY LIKE lc_e.
            EXIT.
          ENDIF.
        ENDLOOP.
      ELSE.
        READ TABLE li_tabctrlx_tmp INTO lwa_tabc INDEX 1.
        IF sy-subrc IS INITIAL.
          MESSAGE i890 WITH  lwa_tabc-kunnr
                   lwa_tabc-vkorg
                   lwa_tabc-vtweg
                   lwa_tabc-spart DISPLAY LIKE lc_e.
          EXIT.
        ENDIF.
      ENDIF.
      REFRESH li_cust1[].
      REFRESH li_tabctrlx_tmp[].
    ENDIF. " IF i_tabctrlx[] IS NOT INITIAL
*<--End of Change for D3_OTC_EDD_0213_Defect#8248 by U105654 on 16-May-2019

*    Fetch employee id and nmame
    i_tabctrl_tmp[] = i_tabctrlx[].
    SORT i_tabctrl_tmp BY vkorg vtweg spart territory_id.
    DELETE ADJACENT DUPLICATES FROM i_tabctrl_tmp
                  COMPARING vkorg vtweg spart territory_id.
    IF i_tabctrl_tmp[] IS NOT INITIAL.
      SELECT vkorg            " Sales Organization
        vtweg                 " Distribution Channel
        spart                 " Division
        territory_id          " Partner Territory ID
        empid                 " Employee ID
*&-- Begin of changes for D3_OTC_EDD_0213 Defect# 6019 by SMUKHER on 25-May-2018
        effective_from        " Effective From
        effective_to          " Effective To
*&-- End of changes for D3_OTC_EDD_0213 Defect# 6019 by SMUKHER on 25-May-2018
        INTO TABLE i_emp
        FROM zotc_part_to_emp " Comm Group: XREF Partner to Employee
        FOR ALL ENTRIES IN i_tabctrl_tmp
        WHERE vkorg = i_tabctrl_tmp-vkorg
        AND vtweg = i_tabctrl_tmp-vtweg
        AND spart = i_tabctrl_tmp-spart
        AND territory_id = i_tabctrl_tmp-territory_id.

      IF sy-subrc = 0.
*&-- Begin of changes for D3_OTC_EDD_0213 Defect# 6019 by SMUKHER on 25-May-2018
*& We delete the EMP records which are not active on today's date.
        DELETE i_emp WHERE effective_to LT sy-datum.
        DELETE i_emp WHERE effective_from GT sy-datum.
*&-- End of changes for D3_OTC_EDD_0213 Defect# 6019 by SMUKHER on 25-May-2018
        SORT i_emp BY vkorg vtweg spart territory_id.

        SELECT lifnr " Account Number of Vendor or Creditor
        name1        " Name 1
        FROM lfa1    " Vendor Master (General Section)
        INTO TABLE i_empname
        FOR ALL ENTRIES IN i_emp
        WHERE lifnr = i_emp-empid.

        IF sy-subrc = 0.
          SORT i_empname BY lifnr.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF i_tabctrl_tmp[] IS NOT INITIAL
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
* Fetch Customer Name from table KNA1
    REFRESH i_tabctrl_tmp.
    i_tabctrl_tmp[] = i_tabctrlx[].
* Sort and Delete duplicate entries comparing kunnr
    SORT i_tabctrl_tmp BY kunnr.
    DELETE ADJACENT DUPLICATES FROM i_tabctrl_tmp COMPARING kunnr.
    IF i_tabctrl_tmp[] IS NOT INITIAL.
      SELECT kunnr " Customer Number
        name1      " Name 1
        adrnr      " Address
        FROM kna1  " General Data in Customer Master
        INTO TABLE i_custname1
        FOR ALL ENTRIES IN i_tabctrl_tmp
        WHERE kunnr = i_tabctrl_tmp-kunnr.

      IF sy-subrc = 0.
        SORT i_custname1 BY kunnr.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF i_tabctrl_tmp[] IS NOT INITIAL
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
*    Fetch Partner Role Desc,
    i_tabctrl_tmp[] = i_tabctrlx[].
    SORT i_tabctrl_tmp BY partrole.
    DELETE ADJACENT DUPLICATES FROM i_tabctrl_tmp COMPARING partrole.

    IF i_tabctrl_tmp IS NOT INITIAL.
      SELECT partrole       " Partner Role
        partrole_desc       " Partner Role description
        FROM zotc_part_role " Comm Group: Partner Roles
        INTO TABLE i_partrole
        FOR ALL ENTRIES IN i_tabctrl_tmp
        WHERE partrole = i_tabctrl_tmp-partrole.

      IF sy-subrc = 0.
        SORT i_partrole BY partrole.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF i_tabctrl_tmp IS NOT INITIAL

*    Fetch Partner nmame and addr number from KNA1
    i_tabctrl_tmp[] = i_tabctrlx[].
    SORT i_tabctrl_tmp BY territory_id.
    DELETE ADJACENT DUPLICATES FROM i_tabctrl_tmp COMPARING territory_id.

    IF i_tabctrl_tmp[] IS NOT INITIAL.
      SELECT kunnr " Customer Number
        name1      " Name 1
        adrnr      " Address
        FROM kna1  " General Data in Customer Master
        INTO TABLE i_custname
        FOR ALL ENTRIES IN i_tabctrl_tmp
        WHERE kunnr = i_tabctrl_tmp-territory_id.

      IF sy-subrc = 0.
        SORT i_custname BY kunnr.

        SELECT addrnumber " Address number
          house_num1      " House Number
          street          " Street
          city1           " City
          region          " Region (State, Province, County)
          post_code1      " City postal code
          country         " Country Key
          str_suppl1      " Street 2
          str_suppl2      " Street 3
          building        " Building (Number or Code)
          floor           " Floor in building
          roomnumber      " Room or Appartment Number
          po_box          " PO Box
          FROM adrc       " Addresses (Business Address Services)
          INTO TABLE i_custadr
          FOR ALL ENTRIES IN i_custname
          WHERE addrnumber = i_custname-adrnr.

        IF sy-subrc = 0.
          SORT i_custadr BY addrnumber.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc = 0

*Populate actual table control itab
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
      IF i_tabctrl[] IS INITIAL.
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
        LOOP AT i_tabctrlx INTO wa_tabctrl.
*    get partner territory name
          READ TABLE i_custname INTO wa_custname WITH KEY
                                        kunnr = wa_tabctrl-territory_id
                                        BINARY SEARCH.
          IF sy-subrc = 0.
            wa_tabctrl-territoryid_name = wa_custname-name1.
*Get Customer Address
            READ TABLE i_custadr INTO wa_custadr  WITH KEY
                                              addrnumber = wa_custname-adrnr
                                              BINARY SEARCH.
            IF sy-subrc = 0.
              wa_tabctrl-house_num1  = wa_custadr-house_num1.
              wa_tabctrl-street   = wa_custadr-street .
              wa_tabctrl-city1    = wa_custadr-city1  .
              wa_tabctrl-region  = wa_custadr-region.
              wa_tabctrl-post_code1  = wa_custadr-post_code1.
              wa_tabctrl-country  = wa_custadr-country.
              wa_tabctrl-str_suppl1  = wa_custadr-str_suppl1.
              wa_tabctrl-str_suppl2  = wa_custadr-str_suppl2.
              wa_tabctrl-building   = wa_custadr-building .
              wa_tabctrl-floor    = wa_custadr-floor  .
              wa_tabctrl-roomnumber   = wa_custadr-roomnumber .
            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF sy-subrc = 0

*    get employee id and name
          READ TABLE i_emp INTO wa_emp WITH KEY vkorg = wa_tabctrl-vkorg
                                                vtweg = wa_tabctrl-vtweg
                                                spart = wa_tabctrl-spart
                                                territory_id = wa_tabctrl-territory_id
                                                BINARY SEARCH.
          IF sy-subrc = 0.
            wa_tabctrl-empid = wa_emp-empid.
            READ TABLE i_empname INTO wa_empname WITH KEY
                                          lifnr = wa_tabctrl-empid.
            IF sy-subrc = 0.
              wa_tabctrl-empname = wa_empname-name1.
            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF sy-subrc = 0
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
* Get Customer Name
          CLEAR wa_custname.
          READ TABLE i_custname1 INTO wa_custname WITH KEY
                                        kunnr = wa_tabctrl-kunnr
                                        BINARY SEARCH.
          IF sy-subrc = 0.
            wa_tabctrl-name1 = wa_custname-name1.
          ENDIF. " IF sy-subrc = 0
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
*Get Partner role Desc
          READ TABLE i_partrole INTO wa_partrole WITH KEY
                                         partrole = wa_tabctrl-partrole.
          IF sy-subrc = 0.
            wa_tabctrl-partrole_desc = wa_partrole-partrole_desc.
          ENDIF. " IF sy-subrc = 0
          APPEND wa_tabctrl TO i_tabctrl.
        ENDLOOP. " LOOP AT i_tabctrlx INTO wa_tabctrl
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
      ENDIF. " IF i_tabctrl[] IS INITIAL
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
    ENDIF. " IF i_tabctrl_tmp[] IS NOT INITIAL
  ENDIF. " IF gv_ind = c_change or
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
*  For Radio Button Display

*  ELSEIF gv_ind = c_disp. " For Display only  " Defect # 3534
  IF gv_ind = c_disp. " For Display only  " Defect # 3534
* Fetch data from Territory Assignment table based on the input
    IF i_tabctrlx[] IS INITIAL.
      SELECT *
          FROM zotc_territ_assn " Comm Group: XREF Partner to Employee
          INTO TABLE i_terrassn_tmp
*-->Begin of delete for D3_OTC_EDD_0213_Defect# 2496 by U029267 on 27-Apr-2017
*          WHERE vkorg IN s_vkorg[]
*            AND vtweg IN s_vtweg[]
*            AND spart IN s_spart[]
*            AND kunnr IN s_kunnr[]
*<--End of delete for D3_OTC_EDD_0213_Defect# 2496 by U029267 on 27-Apr-2017
* ---> Begin of Insert for D3_OTC_EDD_0213_Defect#2496 by U029267 on 27-Apr-2017
           WHERE vkorg IN s_vkorg1[]
            AND vtweg IN s_vtweg1[]
            AND spart IN s_spart1[]
            AND kunnr IN s_kunnr1[]
* <--- End of Insert for D3_OTC_EDD_0213_Defect#2496 by U029267 on 27-Apr-2017
            AND territory_id IN s_terrid[]
            AND partrole IN s_partrl[].
      IF sy-subrc = 0.

        LOOP AT i_terrassn_tmp ASSIGNING <lfs_terrassn_tmp1>.
          wa_tabctrl-vkorg = <lfs_terrassn_tmp1>-vkorg .
          wa_tabctrl-vtweg = <lfs_terrassn_tmp1>-vtweg .
          wa_tabctrl-spart = <lfs_terrassn_tmp1>-spart .
          wa_tabctrl-kunnr = <lfs_terrassn_tmp1>-kunnr .
          wa_tabctrl-territory_id = <lfs_terrassn_tmp1>-territory_id.
          wa_tabctrl-partrole = <lfs_terrassn_tmp1>-partrole.
          wa_tabctrl-effective_from = <lfs_terrassn_tmp1>-effective_from.
          wa_tabctrl-effective_to =   <lfs_terrassn_tmp1>-effective_to.

          APPEND wa_tabctrl TO i_tabctrlx.
          CLEAR : wa_tabctrl.
        ENDLOOP. " LOOP AT i_terrassn_tmp ASSIGNING <lfs_terrassn_tmp1>
      ELSE. " ELSE -> IF sy-subrc = 0
*   Throw message if no data found
        MESSAGE i927(zotc_msg). " No data found
        LEAVE LIST-PROCESSING.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF i_tabctrlx[] IS INITIAL
*    Fetch employee id and name
    i_tabctrl_tmp[] = i_tabctrlx[].
*   Sort and Delete duplicate entries
    SORT i_tabctrl_tmp BY vkorg vtweg spart territory_id.
    DELETE ADJACENT DUPLICATES FROM i_tabctrl_tmp
                  COMPARING vkorg vtweg spart territory_id.
    IF i_tabctrl_tmp[] IS NOT INITIAL.
      SELECT vkorg            " Sales Organization
        vtweg                 " Distribution Channel
        spart                 " Division
        territory_id          " Partner Territory ID
        empid                 " Employee ID
*&-- Begin of changes for D3_OTC_EDD_0213 Defect# 6019 by SMUKHER on 25-May-2018
        effective_from        " Effective From
        effective_to          " Effective To
*&-- End of changes for D3_OTC_EDD_0213 Defect# 6019 by SMUKHER on 25-May-2018
        INTO TABLE i_emp
        FROM zotc_part_to_emp " Comm Group: XREF Partner to Employee
        FOR ALL ENTRIES IN i_tabctrl_tmp
        WHERE vkorg = i_tabctrl_tmp-vkorg
        AND vtweg = i_tabctrl_tmp-vtweg
        AND spart = i_tabctrl_tmp-spart
        AND territory_id = i_tabctrl_tmp-territory_id.

      IF sy-subrc = 0 .
*&-- Begin of changes for D3_OTC_EDD_0213 Defect# 6019 by SMUKHER on 25-May-2018
*& We delete the EMP records which are not active on today's date.
        DELETE i_emp WHERE effective_to LT p_date.
        DELETE i_emp WHERE effective_from GT p_date.
*&-- End of changes for D3_OTC_EDD_0213 Defect# 6019 by SMUKHER on 25-May-2018
        SORT i_emp BY vkorg vtweg spart territory_id.
      ENDIF. " IF sy-subrc = 0
      i_emp_temp[] = i_emp[].
* Sort and Delete duplicate entries comparing empid
      SORT i_emp_temp BY empid.
      DELETE ADJACENT DUPLICATES FROM i_emp_temp COMPARING empid.

      IF i_emp_temp[] IS NOT INITIAL.
        SELECT lifnr " Account Number of Vendor or Creditor
        name1        " Name 1
        FROM lfa1    " Vendor Master (General Section)
        INTO TABLE i_empname
        FOR ALL ENTRIES IN i_emp_temp
        WHERE lifnr = i_emp_temp-empid.

        IF sy-subrc = 0.
          SORT i_empname BY lifnr.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF i_emp_temp[] IS NOT INITIAL
    ENDIF. " IF i_tabctrl_tmp[] IS NOT INITIAL
* Fetch Customer Name and Partner name and addr number from KNA1
    REFRESH i_tabctrl_tmp[].
    i_tabctrl_tmp[] = i_tabctrlx[].
* Sort and delete duplicate entries
    SORT i_tabctrl_tmp BY kunnr territory_id.
    DELETE ADJACENT DUPLICATES FROM i_tabctrl_tmp COMPARING kunnr territory_id.
    IF i_tabctrl_tmp[] IS NOT INITIAL.
      LOOP AT i_tabctrl_tmp ASSIGNING <lfs_terrassn_tmp>.
        lwa_cust-kunnr = <lfs_terrassn_tmp>-kunnr.
        APPEND lwa_cust TO li_cust.
        CLEAR lwa_cust.
        lwa_cust-kunnr = <lfs_terrassn_tmp>-territory_id.
        APPEND lwa_cust TO li_cust.
        CLEAR lwa_cust.
      ENDLOOP. " LOOP AT i_tabctrl_tmp ASSIGNING <lfs_terrassn_tmp>
* Sort and delete duplicate entries
      SORT li_cust BY kunnr .
      DELETE ADJACENT DUPLICATES FROM li_cust COMPARING kunnr.
      IF li_cust IS NOT INITIAL.
        SELECT kunnr " Customer Number
          name1      " Name 1
          adrnr      " Address
          FROM kna1  " General Data in Customer Master
          INTO TABLE li_custname
          FOR ALL ENTRIES IN li_cust
          WHERE  kunnr = li_cust-kunnr.
        IF sy-subrc = 0.
          SORT li_custname BY kunnr.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF li_cust IS NOT INITIAL
    ENDIF. " IF i_tabctrl_tmp[] IS NOT INITIAL

*    Fetch Partner Role Desc. from table ZOTC_PART_ROLE
    REFRESH i_tabctrl_tmp[].
    i_tabctrl_tmp[] = i_tabctrlx[].
* Sort and delete duplicate entries
    SORT i_tabctrl_tmp BY partrole.
    DELETE ADJACENT DUPLICATES FROM i_tabctrl_tmp COMPARING partrole.
    IF i_tabctrl_tmp[] IS NOT INITIAL.
      SELECT partrole       " Partner Role
        partrole_desc       " Partner Role description
        FROM zotc_part_role " Comm Group: Partner Roles
        INTO TABLE i_partrole
        FOR ALL ENTRIES IN i_tabctrl_tmp
        WHERE partrole = i_tabctrl_tmp-partrole.

      IF sy-subrc = 0.
        SORT i_partrole BY partrole.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF i_tabctrl_tmp[] IS NOT INITIAL
* Get Address
    i_custname_temp[] = li_custname.
* Sort and delete duplicate entries
    SORT i_custname_temp[] BY adrnr.
    DELETE ADJACENT DUPLICATES FROM i_custname_temp COMPARING adrnr.
    IF i_custname_temp[] IS NOT INITIAL.
      SELECT addrnumber " Address number
        house_num1      " House Number
        street          " Street
        city1           " City
        region          " Region (State, Province, County)
        post_code1      " City postal code
        country         " Country Key
        str_suppl1      " Street 2
        str_suppl2      " Street 3
        building        " Building (Number or Code)
        floor           " Floor in building
        roomnumber      " Room or Appartment Number
        po_box          " PO Box
        FROM adrc       " Addresses (Business Address Services)
        INTO TABLE i_custadr
        FOR ALL ENTRIES IN i_custname_temp
        WHERE addrnumber = i_custname_temp-adrnr.

      IF sy-subrc = 0.
        SORT i_custadr BY addrnumber.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF i_custname_temp[] IS NOT INITIAL

* Populate actual table control itab
    IF i_tabctrl[] IS INITIAL.
      LOOP AT i_tabctrlx ASSIGNING <lfs_terrassn_tmp>.
*    Get partner territory name
        READ TABLE li_custname ASSIGNING <lfs_custname> WITH KEY
                                      kunnr = <lfs_terrassn_tmp>-territory_id
                                      BINARY SEARCH.
        IF sy-subrc = 0.
          <lfs_terrassn_tmp>-territoryid_name = <lfs_custname>-name1.
* Get Customer Address
          READ TABLE i_custadr ASSIGNING <lfs_custadr>  WITH KEY
                                            addrnumber = <lfs_custname>-adrnr
                                            BINARY SEARCH.
          IF sy-subrc = 0.
            <lfs_terrassn_tmp>-house_num1  = <lfs_custadr>-house_num1.
            <lfs_terrassn_tmp>-street   = <lfs_custadr>-street .
            <lfs_terrassn_tmp>-city1    = <lfs_custadr>-city1  .
            <lfs_terrassn_tmp>-region  = <lfs_custadr>-region.
            <lfs_terrassn_tmp>-post_code1  = <lfs_custadr>-post_code1.
            <lfs_terrassn_tmp>-country  = <lfs_custadr>-country.
            <lfs_terrassn_tmp>-str_suppl1  = <lfs_custadr>-str_suppl1.
            <lfs_terrassn_tmp>-str_suppl2  = <lfs_custadr>-str_suppl2.
            <lfs_terrassn_tmp>-building   = <lfs_custadr>-building .
            <lfs_terrassn_tmp>-floor    = <lfs_custadr>-floor  .
            <lfs_terrassn_tmp>-roomnumber   = <lfs_custadr>-roomnumber .
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF sy-subrc = 0

*    Get employee id and name
        READ TABLE i_emp ASSIGNING <lfs_emp> WITH KEY vkorg = <lfs_terrassn_tmp>-vkorg
                                              vtweg = <lfs_terrassn_tmp>-vtweg
                                              spart = <lfs_terrassn_tmp>-spart
                                              territory_id = <lfs_terrassn_tmp>-territory_id
                                              BINARY SEARCH.
        IF sy-subrc = 0.
          <lfs_terrassn_tmp>-empid = <lfs_emp>-empid.
*    Get Employee Name
          READ TABLE i_empname ASSIGNING <lfs_empname> WITH KEY
                                        lifnr = <lfs_terrassn_tmp>-empid
                                        BINARY SEARCH.
          IF sy-subrc = 0.
            <lfs_terrassn_tmp>-empname = <lfs_empname>-name1.
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF sy-subrc = 0
* Get Customer Name
        READ TABLE li_custname ASSIGNING <lfs_custname> WITH KEY
                                      kunnr = <lfs_terrassn_tmp>-kunnr
                                      BINARY SEARCH.
        IF sy-subrc = 0.
          <lfs_terrassn_tmp>-name1 = <lfs_custname>-name1.
        ENDIF. " IF sy-subrc = 0
* Get Partner role Desc
        READ TABLE i_partrole ASSIGNING <lfs_partrole> WITH KEY
                                       partrole = <lfs_terrassn_tmp>-partrole
                                       BINARY SEARCH.
        IF sy-subrc = 0.
          <lfs_terrassn_tmp>-partrole_desc = <lfs_partrole>-partrole_desc.
        ENDIF. " IF sy-subrc = 0

        APPEND <lfs_terrassn_tmp> TO i_tabctrl.
      ENDLOOP. " LOOP AT i_tabctrlx ASSIGNING <lfs_terrassn_tmp>
    ENDIF. " IF i_tabctrl[] IS INITIAL
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  ENDIF. " IF gv_ind = c_disp
ENDMODULE. " GET_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_PROPERTY  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_property OUTPUT.
  IF rb_chg = c_check.
    LOOP AT SCREEN.
      IF screen-group1 = 'PK'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'PK'
    ENDLOOP. " LOOP AT SCREEN
  ENDIF. " IF rb_chg = c_check
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  IF rb_dis = c_check.
    LOOP AT SCREEN.
      IF screen-group1 = c_grp_pk
        OR screen-group1 = c_grp_sk.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_grp_pk
    ENDLOOP. " LOOP AT SCREEN
  ENDIF. " IF rb_dis = c_check
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
ENDMODULE. " MODIFY_PROPERTY  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  POPULATE_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE populate_screen OUTPUT.

  IF sy-stepl = 1.
    tc_terrassn-lines = tc_terrassn-top_line + sy-loopc - 1.
  ENDIF. " IF sy-stepl = 1

  MOVE wa_tabctrl TO zotc_tabctrl_terrassn.

ENDMODULE. " POPULATE_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.

*--Begin of Insert for D2_OTC_EDD_0213_Defect#3534
*  IF i_tabctrl[] IS NOT INITIAL.
**   In PAI if there is data in tab control then
**    indicator is set to change
*    gv_ind = c_change.
*  ENDIF. " IF i_tabctrl[] IS NOT INITIAL

*--End of Insert for D2_OTC_EDD_0213_Defect#3534
  CASE gv_okcode.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      PERFORM f_save_to_table.
    WHEN 'ENTR'.
      PERFORM f_refresh_tab.
*--Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
    WHEN c_download.
      PERFORM f_download_output.
*--End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
*--Begin of Insert for D2_OTC_EDD_0213_Defect#3534

*--Begin of Insert for D3_OTC_EDD_0213_D3R2 by amangal
    WHEN c_apply. " Clicked the Mass Change Date button
      lv_cancel = space.
      CALL SCREEN 9002 STARTING AT 10 08
                       ENDING AT 90 12.

      IF lv_cancel NE 'X'.
        IF lv_effdate_fr IS NOT INITIAL
          OR lv_effdate_to IS NOT INITIAL.
          PERFORM f_mass_update_date.
        ENDIF.
      ENDIF.

*--End of Insert for D3_OTC_EDD_0213_D3R2 by amangal
    WHEN OTHERS.
      PERFORM f_refresh_tab.
*--End of Insert for D2_OTC_EDD_0213_Defect#3534
  ENDCASE.
ENDMODULE. " USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_SAVE_TO_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_to_table .

*--Begin of Insert for D2_OTC_EDD_0213_Defect#3534
  DATA : lv_delete TYPE int2, " 2 byte integer (signed)
         lv_modify TYPE int2. " 2 byte integer (signed)
*--End of Insert for D2_OTC_EDD_0213_Defect#3534

  LOOP AT i_tabctrl INTO wa_tabctrl.
    wa_final_save-vkorg = wa_tabctrl-vkorg.
    wa_final_save-vtweg = wa_tabctrl-vtweg.
    wa_final_save-spart = wa_tabctrl-spart.
    wa_final_save-kunnr = wa_tabctrl-kunnr.
    wa_final_save-territory_id = wa_tabctrl-territory_id.
    wa_final_save-partrole = wa_tabctrl-partrole.
    wa_final_save-effective_from = wa_tabctrl-effective_from.
    wa_final_save-effective_to = wa_tabctrl-effective_to.

    IF rb_add = c_check.
*&-- Begin of Insert for D2_OTC_EDD_0213 by MBHATTA1 Defect#2653
      wa_final_save-zz_created_by = wa_final_save-zz_changed_by = sy-uname.
      wa_final_save-zz_created_on = wa_final_save-zz_changed_on = sy-datum.
      wa_final_save-zz_created_at = wa_final_save-zz_changed_at = sy-uzeit.
*&-- End of Insert for D2_OTC_EDD_0213 by MBHATTA1 Defect#2653
    ELSE. " ELSE -> IF rb_add = c_check

* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#2210 by SMUKHER4 on 16.12.2016
      READ TABLE i_terrassn_tmp INDEX sy-tabix INTO wa_final_del.
      IF sy-subrc IS INITIAL.
        wa_final_save-zz_created_by = wa_final_del-zz_created_by.
        wa_final_save-zz_created_on = wa_final_del-zz_created_on.
        wa_final_save-zz_created_at = wa_final_del-zz_created_at.
      ENDIF. " IF sy-subrc IS INITIAL
* <--- End of Insert for D2_OTC_EDD_0213_Defect#2210 by SMUKHER4 on 16.12.2016

      wa_final_save-zz_changed_by = sy-uname.
      wa_final_save-zz_changed_on = sy-datum.
      wa_final_save-zz_changed_at = sy-uzeit.
    ENDIF. " IF rb_add = c_check
    APPEND wa_final_save TO i_final_save.
  ENDLOOP. " LOOP AT i_tabctrl INTO wa_tabctrl

*--Begin of Insert for D2_OTC_EDD_0213_Defect#3534
  DESCRIBE TABLE i_terrassn_tmp LINES lv_delete.
  DESCRIBE TABLE i_final_save LINES lv_modify.

  IF lv_modify < lv_delete.
    MESSAGE e000 WITH TEXT-e20 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF. " IF lv_modify < lv_delete
*--End of Insert for D2_OTC_EDD_0213_Defect#3534

  IF i_final_save[] IS NOT INITIAL.
    CALL FUNCTION 'ENQUEUE_EZOTC_TERR_ASSN'
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.

    IF sy-subrc = 1.
      MESSAGE e000 WITH TEXT-e07 DISPLAY LIKE 'E'.
    ELSEIF sy-subrc = 2.
      MESSAGE e000 WITH TEXT-e08 DISPLAY LIKE 'E'.
    ELSEIF sy-subrc = 3.
      MESSAGE e000 WITH TEXT-e09 DISPLAY LIKE 'E'.
    ELSE. " ELSE -> IF sy-subrc = 1

* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#2210 by SMUKHER4 on 16.12.2016
*&--Previously duplicate record which we were changing already coming in the output with the modified entries.
*We will consider only the modified entries. So, we are deleting the previous records from the database table
*and inserting the new ones.

      DELETE zotc_territ_assn FROM TABLE i_terrassn_tmp.
* <--- End of Insert for D2_OTC_EDD_0213_Defect#2210 by SMUKHER4 on 16.12.2016

      MODIFY zotc_territ_assn FROM TABLE i_final_save.

      IF sy-subrc = 0.
        COMMIT WORK.
      ELSE. " ELSE -> IF sy-subrc = 0
        ROLLBACK WORK.
      ENDIF. " IF sy-subrc = 0

      CALL FUNCTION 'DEQUEUE_EZOTC_TERR_ASSN'.
      IF sy-dbcnt > 0.
        MESSAGE s000 WITH 'Data saved successfully'(s00).
      ELSE. " ELSE -> IF sy-dbcnt > 0
        MESSAGE s000 WITH TEXT-e10 DISPLAY LIKE 'E'.
      ENDIF. " IF sy-dbcnt > 0
    ENDIF. " IF sy-subrc = 1
  ENDIF. " IF i_final_save[] IS NOT INITIAL
  PERFORM f_refresh_tab.
ENDFORM. " F_SAVE_TO_TABLE
*&---------------------------------------------------------------------*
*&      Form  F_REFRESH_TAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_refresh_tab .
  i_tabctrlx[] = i_tabctrl[].
  REFRESH i_tabctrl[].
ENDFORM. " F_REFRESH_TAB
*&---------------------------------------------------------------------*
*&      Module  VALIDTE_ENTRIES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validte_entries INPUT.
  IF gv_okcode = 'ENTR' OR gv_okcode = 'SAVE'.
    PERFORM f_validate_table_entries USING zotc_tabctrl_terrassn.
  ENDIF. " IF gv_okcode = 'ENTR' OR gv_okcode = 'SAVE'
ENDMODULE. " VALIDTE_ENTRIES  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_TABLE_ENTRIES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZOTC_TABCTRL_TERRASSN  text
*----------------------------------------------------------------------*
FORM f_validate_table_entries  USING  fp_tabctrl TYPE zotc_tabctrl_terrassn. " Struct for tab ctrl for Territory Assignment table
  DATA: lv_vkorg    TYPE vkorg,         " Sales Organization
        lv_vtweg    TYPE vtweg,         " Distribution Channel
        lv_spart    TYPE spart,         " Division
        lv_kunnr    TYPE kunnr,         " Customer Number
        lv_lifnr    TYPE lifnr,         " Account Number of Vendor or Creditor
        lv_partrole TYPE zpart_role. " Partner Role

  IF fp_tabctrl-vkorg IS NOT INITIAL.
    SELECT SINGLE vkorg " Sales Organization
    INTO lv_vkorg
    FROM tvko           " Organizational Unit: Sales Organizations
    WHERE vkorg = fp_tabctrl-vkorg.

    IF sy-subrc <> 0.
      MESSAGE e000 WITH TEXT-e00.
    ENDIF. " IF sy-subrc <> 0

  ENDIF. " IF fp_tabctrl-vkorg IS NOT INITIAL

  IF fp_tabctrl-vtweg IS NOT INITIAL.
    SELECT SINGLE vtweg " Distribution Channel
      INTO lv_vtweg
      FROM tvtw         " Organizational Unit: Distribution Channels
      WHERE vtweg = fp_tabctrl-vtweg.

    IF sy-subrc <> 0.
      MESSAGE e000 WITH TEXT-e01.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF fp_tabctrl-vtweg IS NOT INITIAL

  IF fp_tabctrl-spart IS NOT INITIAL.
    SELECT SINGLE spart " Division
      INTO lv_spart
      FROM tspa         " Organizational Unit: Sales Divisions
      WHERE spart = fp_tabctrl-spart.

    IF sy-subrc <> 0.
      MESSAGE e000  WITH TEXT-e03.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF fp_tabctrl-spart IS NOT INITIAL

  IF fp_tabctrl-kunnr IS NOT INITIAL.
    SELECT SINGLE kunnr " Customer Number
      INTO lv_kunnr
      FROM kna1         " General Data in Customer Master
      WHERE kunnr =
* ---> Begin of Delete for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
*                   fp_tabctrl-spart
* <--- End of Delete for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
                    fp_tabctrl-kunnr
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
* ---> Begin of Delete for D3_OTC_EDD_0213 Defect#2496/SCTASK0537273 by U033959 on 12-JUN-2017
*      AND ktokd IN (c_soldto, c_shipto).
* <--- End of Delete for D3_OTC_EDD_0213 Defect#2496/SCTASK0537273 by U033959 on 12-JUN-2017
* ---> Begin of Insert for D3_OTC_EDD_0213 Defect#2496/SCTASK0537273 by U033959 on 12-JUN-2017
      AND ktokd IN i_account_grp.
* <--- End of Insert for D3_OTC_EDD_0213 Defect#2496/SCTASK0537273 by U033959 on 12-JUN-2017
    IF sy-subrc <> 0.
      MESSAGE e000  WITH TEXT-e11.
    ENDIF. " IF sy-subrc <> 0

  ENDIF. " IF fp_tabctrl-kunnr IS NOT INITIAL

  IF fp_tabctrl-territory_id IS NOT INITIAL.
    SELECT SINGLE kunnr " Customer Number
      INTO lv_kunnr
      FROM kna1         " General Data in Customer Master
      WHERE kunnr = fp_tabctrl-territory_id
      AND ktokd = c_rep.

    IF sy-subrc <> 0.
      MESSAGE e000 WITH TEXT-e04.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF fp_tabctrl-territory_id IS NOT INITIAL

  IF fp_tabctrl-partrole IS NOT INITIAL.
    SELECT SINGLE partrole " Partner Role
      INTO lv_partrole
      FROM zotc_part_role  " Comm Group: Partner Roles
      WHERE partrole = fp_tabctrl-partrole.

    IF sy-subrc <> 0.
      MESSAGE e000 WITH TEXT-e05.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF fp_tabctrl-partrole IS NOT INITIAL

  IF fp_tabctrl-effective_from > fp_tabctrl-effective_to.
    MESSAGE e000 WITH TEXT-e06.
  ENDIF. " IF fp_tabctrl-effective_from > fp_tabctrl-effective_to

ENDFORM. " F_VALIDATE_TABLE_ENTRIES
*&---------------------------------------------------------------------*
*&      Module  MODIFY_TAB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_tab INPUT.
  MODIFY i_tabctrl FROM zotc_tabctrl_terrassn INDEX tc_terrassn-current_line.

  IF sy-subrc <> 0 AND rb_add = c_check
                  AND zotc_tabctrl_terrassn IS NOT INITIAL.
    APPEND zotc_tabctrl_terrassn TO i_tabctrl.
  ENDIF. " IF sy-subrc <> 0 AND rb_add = c_check
ENDMODULE. " MODIFY_TAB  INPUT
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_TERRITORY_ID
*&---------------------------------------------------------------------*
*       Validate Partner Territory ID
*----------------------------------------------------------------------*
FORM f_validate_territory_id .
  DATA: lv_terrid TYPE kunnr. " Customer Number
  IF s_terrid IS NOT INITIAL.
    SELECT kunnr UP TO 1 ROWS
      INTO lv_terrid
      FROM kna1 " General Data in Customer Master
      WHERE kunnr IN s_terrid.
    ENDSELECT.

    IF sy-subrc <> 0.
      MESSAGE e928(zotc_msg). " Enter valid Partner Territory ID
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF s_terrid IS NOT INITIAL
ENDFORM. " F_VALIDATE_TERRITORY_ID
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_PARTNER_ROLE
*&---------------------------------------------------------------------*
*       Validate Partner Role
*----------------------------------------------------------------------*
FORM f_validate_partner_role .
  DATA: lv_partrole TYPE zpart_role. " Partner Role
  IF s_partrl IS NOT INITIAL.
    SELECT partrole UP TO 1 ROWS
      INTO lv_partrole
      FROM zotc_part_role " Comm Group: Partner Roles
      WHERE partrole IN s_partrl.
    ENDSELECT.

    IF sy-subrc <> 0.
      MESSAGE e929(zotc_msg). " Enter valid Partner Role
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF s_partrl IS NOT INITIAL
ENDFORM. " F_VALIDATE_PARTNER_ROLE
*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_OUTPUT
*&---------------------------------------------------------------------*
*       Download output in local
*----------------------------------------------------------------------*
FORM f_download_output.

  DATA: lv_path     TYPE string,  " Path
        lv_filename TYPE string , " File name
        lv_fullpath TYPE string . " Fullpath
  TYPES : BEGIN OF lty_fields,
            fields TYPE char20, " Header Fields
          END OF lty_fields.
  DATA : li_fields TYPE STANDARD TABLE OF lty_fields INITIAL SIZE 0,
         wa_fields TYPE lty_fields.

  CONSTANTS:
    lc_file_type     TYPE char10 VALUE 'ASC',   " File Type ASC
    lc_fld_separator TYPE char01 VALUE 'X', " Field Separator
    lc_header        TYPE xstring VALUE '00'.      " Header

*  Fill All the field name for file header in the download file
*  Sales_org
  CLEAR wa_fields.
  wa_fields-fields = 'Sales Org.'(001).
  APPEND wa_fields TO li_fields.

* Division
  CLEAR wa_fields.
  wa_fields-fields = 'Distr. Channel'(002).
  APPEND wa_fields TO li_fields.

* Distr_channel
  CLEAR wa_fields.
  wa_fields-fields = 'Division'(003).
  APPEND wa_fields TO li_fields.

* Customer
  CLEAR wa_fields.
  wa_fields-fields = 'Customer'(004).
  APPEND wa_fields TO li_fields.

* Territory ID
  CLEAR wa_fields.
  wa_fields-fields = 'Territory ID'(005).
  APPEND wa_fields TO li_fields.

* Partner Role
  CLEAR wa_fields.
  wa_fields-fields = 'Partner Role'(006).
  APPEND wa_fields TO li_fields.

* Effective From
  CLEAR wa_fields.
  wa_fields-fields = 'Effective From'(007).
  APPEND wa_fields TO li_fields.

* Effective To
  CLEAR wa_fields.
  wa_fields-fields = 'Effective To'(008).
  APPEND wa_fields TO li_fields.

* Employee ID
  CLEAR wa_fields.
  wa_fields-fields = 'Employee ID'(009).
  APPEND wa_fields TO li_fields.

* Customer Name
  CLEAR wa_fields.
  wa_fields-fields = 'Customer Name'(010).
  APPEND wa_fields TO li_fields.

* Employee Name
  CLEAR wa_fields.
  wa_fields-fields = 'Employee Name'(011).
  APPEND wa_fields TO li_fields.

* Partner Territory Name
  CLEAR wa_fields.
  wa_fields-fields = 'Partner Territ Name'(012).
  APPEND wa_fields TO li_fields.

* Partner Role Description
  CLEAR wa_fields.
  wa_fields-fields = 'Partner Role Descrip'(013).
  APPEND wa_fields TO li_fields.

* House Number
  CLEAR wa_fields.
  wa_fields-fields = 'House Number'(014).
  APPEND wa_fields TO li_fields.

* Street
  CLEAR wa_fields.
  wa_fields-fields = 'Street'(015).
  APPEND wa_fields TO li_fields.

* City
  CLEAR wa_fields.
  wa_fields-fields = 'City'(016).
  APPEND wa_fields TO li_fields.

* Region
  CLEAR wa_fields.
  wa_fields-fields = 'Region'(017).
  APPEND wa_fields TO li_fields.

* Postal Code
  CLEAR wa_fields.
  wa_fields-fields = 'Postal Code'(018).
  APPEND wa_fields TO li_fields.

* Country
  CLEAR wa_fields.
  wa_fields-fields = 'Country'(019).
  APPEND wa_fields TO li_fields.

* Street 2
  CLEAR wa_fields.
  wa_fields-fields = 'Street 2'(020).
  APPEND wa_fields TO li_fields.

* Street 3
  CLEAR wa_fields.
  wa_fields-fields = 'Street 3'(021).
  APPEND wa_fields TO li_fields.

* Building Code
  CLEAR wa_fields.
  wa_fields-fields = 'Building Code'(022).
  APPEND wa_fields TO li_fields.

* Floor
  CLEAR wa_fields.
  wa_fields-fields = 'Floor'(023).
  APPEND wa_fields TO li_fields.

* Room Number
  CLEAR wa_fields.
  wa_fields-fields = 'Room Number'(024).
  APPEND wa_fields TO li_fields.

* PO Box
  CLEAR wa_fields.
  wa_fields-fields = 'PO Box'(025).
  APPEND wa_fields TO li_fields.

* Save dialog on the client PC that allows the user to select a folder and
* specify a name for a file.
  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    CHANGING
      path     = lv_path
      filename = lv_filename
      fullpath = lv_fullpath.

* Downloading the file to Presentation Server
  IF i_tabctrl[] IS NOT INITIAL.
    IF lv_filename IS NOT INITIAL.
      CALL METHOD cl_gui_frontend_services=>gui_download
        EXPORTING
          filetype                = lc_file_type
          filename                = lv_fullpath
          write_field_separator   = lc_fld_separator
          header                  = lc_header
          fieldnames              = li_fields
        CHANGING
          data_tab                = i_tabctrl
        EXCEPTIONS
          invalid_type            = 3
          no_batch                = 4
          unknown_error           = 5
          gui_refuse_filetransfer = 6
          OTHERS                  = 7.
      IF sy-subrc IS NOT INITIAL.
        MESSAGE i933(zotc_msg). " Error in creating file.
        LEAVE LIST-PROCESSING.
      ENDIF. " IF sy-subrc IS NOT INITIAL
    ELSE. " ELSE -> IF lv_filename IS NOT INITIAL
*   Throw message if file name not filled
      MESSAGE i925(zotc_msg). " Enter file name.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF lv_filename IS NOT INITIAL
  ELSE. " ELSE -> IF i_tabctrl[] IS NOT INITIAL
*   Throw message if no data found
    MESSAGE i926(zotc_msg). " No data found to download.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF i_tabctrl[] IS NOT INITIAL
ENDFORM. " F_DOWNLOAD_OUTPUT
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461  by SBEHERA
* ---> Begin of Insert for D3_OTC_EDD_0213_Defect#2496 by U029267 on 27-Apr-2017
*&---------------------------------------------------------------------*
*&      Form  F_AUTHORIZATION_CHECK
*&---------------------------------------------------------------------*
*       Authorization check for the radiobuttons add/display/change
*----------------------------------------------------------------------*
FORM f_authorization_check.

  CONSTANTS: lc_actvt      TYPE char5  VALUE 'ACTVT',            " Actvt of type CHAR5
             lc_table      TYPE char5  VALUE 'TABLE',            " Table of type CHAR5
             lc_chg        TYPE char2  VALUE '02',               " Disp of type CHAR2
             lc_disp       TYPE char2  VALUE '03',               " Disp of type CHAR2
             lc_tab_name   TYPE char16 VALUE 'ZOTC_TERRIT_ASSN', " Table name
             lc_s_tabu_nam TYPE char10 VALUE 'S_TABU_NAM'.       " Auth. obj name


  IF rb_add IS NOT INITIAL.

    AUTHORITY-CHECK OBJECT lc_s_tabu_nam
    ID lc_actvt FIELD lc_chg
    ID lc_table FIELD lc_tab_name.

    IF  sy-subrc NE 0.
      MESSAGE e802(zotc_msg). " User has no authorization to add functionality
    ENDIF. " IF sy-subrc NE 0

  ELSEIF rb_chg IS NOT INITIAL.

    AUTHORITY-CHECK OBJECT lc_s_tabu_nam
    ID lc_actvt FIELD lc_chg
    ID lc_table FIELD lc_tab_name.

    IF  sy-subrc NE 0.
      MESSAGE e801(zotc_msg). " User has no authorization to change functionality
    ENDIF. " IF sy-subrc NE 0

  ELSEIF rb_dis IS NOT INITIAL.

    AUTHORITY-CHECK OBJECT lc_s_tabu_nam
    ID lc_actvt FIELD lc_disp
    ID lc_table FIELD lc_tab_name.

    IF  sy-subrc NE 0.
      MESSAGE e800(zotc_msg). " User has no authorization to display functionality
    ENDIF. " IF sy-subrc NE 0

  ENDIF. " IF rb_add IS NOT INITIAL

ENDFORM. " F_AUTHORIZATION_CHECK
* <--- End of Insert for D3_OTC_EDD_0213_Defect#2496 by U029267 on 27-Apr-2017
* ---> Begin of Insert for D3_OTC_EDD_0213 Defect#2496/SCTASK0537273 by U033959 on 12-JUN-2017
*&---------------------------------------------------------------------*
*&      Form  F_GET_CUST_ACC_GRP
*&---------------------------------------------------------------------*
*       Fetch customer account group from EMI
*----------------------------------------------------------------------*
FORM f_get_cust_acc_grp .
*--CONSTANTS---------------------------------------------------------*
  CONSTANTS : lc_otc_edd_0213 TYPE z_enhancement VALUE 'D2_OTC_EDD_0213', " Enhancement No.
              lc_acc_grp      TYPE z_criteria    VALUE 'CUST_ACC_GRP'.    " Enh. Criteria


*--TABLES------------------------------------------------------------*
  DATA : li_status             TYPE STANDARD TABLE OF zdev_enh_status. " Enhancement Status table


*--FIELD SYMBOLS-----------------------------------------------------*
  FIELD-SYMBOLS : <lfs_status>      TYPE zdev_enh_status, " Enhancement Status table
                  <lfs_account_grp> TYPE ty_account_grp.

* Fetch customer account group from EMI Tool.
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_otc_edd_0213
    TABLES
      tt_enh_status     = li_status.

  LOOP AT li_status ASSIGNING <lfs_status> WHERE active IS NOT INITIAL.
    IF <lfs_status>-criteria = lc_acc_grp.
      APPEND INITIAL LINE TO i_account_grp ASSIGNING <lfs_account_grp>.
      <lfs_account_grp>-sign    = c_i.
      <lfs_account_grp>-option  = c_eq.
      <lfs_account_grp>-low     = <lfs_status>-sel_low.
      UNASSIGN <lfs_account_grp>.
    ENDIF. " IF <lfs_status>-criteria = lc_acc_grp
  ENDLOOP. " LOOP AT li_status ASSIGNING <lfs_status> WHERE active IS NOT INITIAL
ENDFORM. " F_GET_CUST_ACC_GRP
* <--- End of Insert for D3_OTC_EDD_0213 Defect#2496/SCTASK0537273 by U033959 on 12-JUN-2017

*&---------------------------------------------------------------------*
*&      Form  F_MASS_UPDATE_DATE
*&---------------------------------------------------------------------*
*       Mass update of from and to effective dates                     *
*----------------------------------------------------------------------*
* 18-SEP-2017 amangal E1DK930689  D3R2 Changes                         *
*----------------------------------------------------------------------*
FORM f_mass_update_date .

  DATA: lv_flag TYPE flag.

  lv_flag = space.

  LOOP AT i_tabctrl ASSIGNING <lfs_terrassn_eff>.

    IF lv_effdate_fr IS NOT INITIAL.
      <lfs_terrassn_eff>-effective_from = lv_effdate_fr.
      lv_flag = 'Y'.
    ENDIF.

    IF lv_effdate_to IS NOT INITIAL.
      lv_flag = 'Y'.
      <lfs_terrassn_eff>-effective_to = lv_effdate_to.
      lv_flag = 'Y'.
    ENDIF.

  ENDLOOP.

  REFRESH CONTROL 'tc_terrassn' FROM SCREEN 9001.

ENDFORM.                    " F_MASS_UPDATE_DATE
