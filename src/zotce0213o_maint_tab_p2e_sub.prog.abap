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
*&  Include           ZOTCE0213O_MAINT_TAB_P2E_SUB
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
  LOOP AT SCREEN.
    IF screen-group1 = 'GR1'.
      IF rb_add = c_check.
        screen-active = 0.
      ELSE. " ELSE -> IF rb_add = c_check
        screen-active = 1.
      ENDIF. " IF rb_add = c_check
      MODIFY SCREEN.
    ENDIF. " IF screen-group1 = 'GR1'
  ENDLOOP. " LOOP AT SCREEN

ENDFORM. " F_HIDE_FIELDS
*&---------------------------------------------------------------------*
*&      Module  POPULATE_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE populate_screen OUTPUT.

  IF sy-stepl = 1.
    tc_partemp-lines = tc_partemp-top_line + sy-loopc - 1.
  ENDIF. " IF sy-stepl = 1

  MOVE wa_tabctrl TO zotc_tabctrl_part2emp.
ENDMODULE. " POPULATE_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_data OUTPUT.

  IF gv_ind = c_change.
*For add only blank screen is displayed, so no data retieval logic is reqd.
*Fetch data from Part to Emp table based on the input
    IF i_tabctrlx[] IS INITIAL.
      SELECT *
        FROM zotc_part_to_emp " Comm Group: XREF Partner to Employee
        INTO TABLE i_partemp_tmp
        WHERE vkorg IN s_vkorg[]
        AND vtweg IN s_vtweg[]
        AND spart IN s_spart[]
        AND territory_id IN s_terrid[].

      IF sy-subrc = 0.
        LOOP AT i_partemp_tmp INTO wa_partemp_tmp.

          MOVE: wa_partemp_tmp-vkorg  TO wa_tabctrl-vkorg,
                wa_partemp_tmp-vtweg  TO wa_tabctrl-vtweg,
                wa_partemp_tmp-spart  TO wa_tabctrl-spart,
                wa_partemp_tmp-territory_id	TO wa_tabctrl-territory_id,
                wa_partemp_tmp-empid  TO wa_tabctrl-empid,
                wa_partemp_tmp-effective_from	TO wa_tabctrl-effective_from,
                wa_partemp_tmp-effective_to	TO wa_tabctrl-effective_to.

          APPEND wa_tabctrl TO i_tabctrlx.
        ENDLOOP. " LOOP AT i_partemp_tmp INTO wa_partemp_tmp
      ELSE. " ELSE -> IF sy-subrc = 0
*   Throw message if no data found
        MESSAGE i000 WITH text-i01.
        LEAVE LIST-PROCESSING.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF i_tabctrlx[] IS INITIAL

*    Fetch Partner nmame from KNA1
    i_tabctrl_tmp[] = i_tabctrlx[].
    SORT i_tabctrl_tmp BY territory_id.
    DELETE ADJACENT DUPLICATES FROM i_tabctrl_tmp COMPARING territory_id.

    IF i_tabctrl_tmp[] IS NOT INITIAL.
      SELECT kunnr " Customer Number
        name1      " Name 1
        FROM kna1  " General Data in Customer Master
        INTO TABLE i_custname
        FOR ALL ENTRIES IN i_tabctrl_tmp
        WHERE kunnr = i_tabctrl_tmp-territory_id.

      IF sy-subrc = 0.
        SORT i_custname BY kunnr.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF i_tabctrl_tmp[] IS NOT INITIAL
*    Fetch Emp nmame from LFA1
    i_tabctrl_tmp[] = i_tabctrlx[].
    SORT i_tabctrl_tmp BY empid.
    DELETE ADJACENT DUPLICATES FROM i_tabctrl_tmp COMPARING empid.

    IF i_tabctrl_tmp[] IS NOT INITIAL.
      SELECT lifnr " Account Number of Vendor or Creditor
        name1      " Name 1
        FROM lfa1  " Vendor Master (General Section)
        INTO TABLE i_vendname
        FOR ALL ENTRIES IN i_tabctrl_tmp
        WHERE lifnr = i_tabctrl_tmp-empid.

      IF sy-subrc = 0.
        SORT i_vendname BY lifnr.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF i_tabctrl_tmp[] IS NOT INITIAL

*Populate actual table control itab
    LOOP AT i_tabctrlx INTO wa_tabctrl.

*    get partner territory name
      READ TABLE i_custname INTO wa_custname WITH KEY
                                    kunnr = wa_tabctrl-territory_id
                                    BINARY SEARCH.
      IF sy-subrc = 0.
        wa_tabctrl-territoryid_name = wa_custname-name1.
      ENDIF. " IF sy-subrc = 0

*    get employee name

      READ TABLE i_vendname INTO wa_vendname WITH KEY
                                    lifnr = wa_tabctrl-empid.
      IF sy-subrc = 0.
        wa_tabctrl-empname = wa_vendname-name1.
      ENDIF. " IF sy-subrc = 0

      APPEND wa_tabctrl TO i_tabctrl.
    ENDLOOP. " LOOP AT i_tabctrlx INTO wa_tabctrl
  ENDIF. " IF gv_ind = c_change
ENDMODULE. " GET_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9001 OUTPUT.
  SET PF-STATUS 'ZSTAT_9001'.
  SET TITLEBAR 'PTE'.

ENDMODULE. " STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.

  IF i_tabctrl[] IS NOT INITIAL.
*   In PAI if there is data in tab control then
*    indicator is set to change
    gv_ind = c_change.
  ENDIF. " IF i_tabctrl[] IS NOT INITIAL

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

  LOOP AT i_tabctrl INTO wa_tabctrl.

    MOVE: wa_tabctrl-vkorg TO wa_final_save-vkorg,
          wa_tabctrl-vtweg TO wa_final_save-vtweg,
          wa_tabctrl-spart TO wa_final_save-spart,
          wa_tabctrl-territory_id TO wa_final_save-territory_id,
          wa_tabctrl-empid TO wa_final_save-empid,
          wa_tabctrl-effective_from TO wa_final_save-effective_from,
          wa_tabctrl-effective_to TO wa_final_save-effective_to.

    IF rb_add = c_check.
      wa_final_save-zz_created_by = sy-uname.
      wa_final_save-zz_created_on = sy-datum.
      wa_final_save-zz_created_at = sy-uzeit.
    ELSE. " ELSE -> IF rb_add = c_check
      wa_final_save-zz_changed_by = sy-uname.
      wa_final_save-zz_changed_on = sy-datum.
      wa_final_save-zz_changed_at = sy-uzeit.
    ENDIF. " IF rb_add = c_check
    APPEND wa_final_save TO i_final_save.
  ENDLOOP. " LOOP AT i_tabctrl INTO wa_tabctrl

  IF i_final_save[] IS NOT INITIAL.
*    Save data into database table.
    CALL FUNCTION 'ENQUEUE_EZOTC_PRT_TO_EMP'
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.

    IF sy-subrc = 1.
      MESSAGE s000 WITH text-e07 DISPLAY LIKE 'E'.
    ELSEIF sy-subrc = 2.
      MESSAGE s000 WITH text-e08 DISPLAY LIKE 'E'.
    ELSEIF sy-subrc = 3.
      MESSAGE s000 WITH text-e09 DISPLAY LIKE 'E'.
    ELSE. " ELSE -> IF sy-subrc = 0
      MODIFY zotc_part_to_emp FROM TABLE i_final_save.

      IF sy-subrc = 0.
        COMMIT WORK.
      ELSE. " ELSE -> IF sy-subrc = 0
        ROLLBACK WORK.
      ENDIF. " IF sy-subrc = 0

      CALL FUNCTION 'DEQUEUE_EZOTC_PRT_TO_EMP'.

      IF sy-dbcnt > 0.
        MESSAGE s000 WITH 'Data saved successfully'(s00).
      ELSE.
        MESSAGE s000 WITH text-e10 DISPLAY LIKE 'E'.
      ENDIF. " IF sy-dbcnt > 0
    ENDIF. " IF sy-subrc = 1
  ENDIF. " IF i_final_save[] IS NOT INITIAL

  PERFORM f_refresh_tab.
ENDFORM. " F_SAVE_TO_TABLE
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_NAMES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_refresh_tab .

  i_tabctrlx[] = i_tabctrl[].
  REFRESH i_tabctrl[].

ENDFORM. " F_POPULATE_NAMES
*&---------------------------------------------------------------------*
*&      Module  MODIFY_TAB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_tab INPUT.
  MODIFY i_tabctrl FROM zotc_tabctrl_part2emp INDEX tc_partemp-current_line.

  IF sy-subrc <> 0 AND rb_add = c_check
    AND zotc_tabctrl_part2emp IS NOT INITIAL.

    APPEND zotc_tabctrl_part2emp TO i_tabctrl.
  ENDIF. " IF sy-subrc <> 0 AND rb_add = c_check
ENDMODULE. " MODIFY_TAB  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SALESORG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_salesorg .

  DATA: lv_vkorg TYPE tvko-vkorg. " Sales Organization

  SELECT vkorg UP TO 1 ROWS
    INTO lv_vkorg
    FROM tvko " Organizational Unit: Sales Organizations
    WHERE vkorg IN s_vkorg.

  ENDSELECT.

  IF sy-subrc <> 0.
    MESSAGE e000 WITH 'Enter valid Sales Org.'(e00).
  ENDIF. " IF sy-subrc <> 0
ENDFORM. " F_VALIDATE_SALESORG
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DIST_CHANNEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_dist_channel .

  DATA: lv_vtweg TYPE vtweg. " Distribution Channel

  SELECT vtweg UP TO 1 ROWS
      INTO lv_vtweg
      FROM tvtw " Organizational Unit: Distribution Channels
      WHERE vtweg IN s_vtweg.

  ENDSELECT.

  IF sy-subrc <> 0.
    MESSAGE e000 WITH 'Enter valid Distribution Channel'(e01).
  ENDIF. " IF sy-subrc <> 0
ENDFORM. " F_VALIDATE_DIST_CHANNEL
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DIVISION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_division .
  DATA: lv_spart TYPE spart. " Division

  SELECT spart UP TO 1 ROWS
    INTO lv_spart
    FROM tspa " Organizational Unit: Sales Divisions
    WHERE spart IN s_spart.

  ENDSELECT.

  IF sy-subrc <> 0.
    MESSAGE e000 WITH 'Enter valid Division'(e03).
  ENDIF. " IF sy-subrc <> 0

ENDFORM. " F_VALIDATE_DIVISION
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_TERRITORY_ID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_territory_id .

  DATA: lv_kunnr TYPE kunnr. " Customer Number

  SELECT kunnr UP TO 1 ROWS
    INTO lv_kunnr
    FROM kna1 " General Data in Customer Master
    WHERE kunnr IN s_terrid
    AND ktokd = c_rep.

  ENDSELECT.

  IF sy-subrc <> 0.
    MESSAGE e000 WITH 'Enter valid Territory Id'(e04).
  ENDIF. " IF sy-subrc <> 0
ENDFORM. " F_VALIDATE_TERRITORY_ID
*&---------------------------------------------------------------------*
*&      Module  VALIDTE_ENTRIES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validte_entries INPUT.

  IF gv_okcode = 'ENTR' OR gv_okcode = 'SAVE'.
    PERFORM f_validate_table_entries USING zotc_tabctrl_part2emp.
  ENDIF. " IF gv_okcode = 'ENTR' OR gv_okcode = 'SAVE'
ENDMODULE. " VALIDTE_ENTRIES  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_TABLE_ENTRIES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZOTC_TABCTRL_PART2EMP  text
*----------------------------------------------------------------------*
FORM f_validate_table_entries  USING fp_tabctrl TYPE zotc_tabctrl_part2emp. " Struct for tab ctrl for Part 2 Emp table

  DATA: lv_vkorg TYPE vkorg,         " Sales Organization
        lv_vtweg TYPE vtweg,         " Distribution Channel
        lv_spart TYPE spart,         " Division
        lv_kunnr TYPE kunnr,         " Customer Number
        lv_lifnr TYPE lifnr,         " Account Number of Vendor or Creditor
        lv_partrole TYPE zpart_role. " Partner Role

  IF fp_tabctrl-vkorg IS NOT INITIAL.
    SELECT SINGLE vkorg " Sales Organization
    INTO lv_vkorg
    FROM tvko           " Organizational Unit: Sales Organizations
    WHERE vkorg = fp_tabctrl-vkorg.

    IF sy-subrc <> 0.
      MESSAGE e000 WITH text-e00.
    ENDIF. " IF sy-subrc <> 0

  ENDIF. " IF fp_tabctrl-vkorg IS NOT INITIAL

  IF fp_tabctrl-vtweg IS NOT INITIAL.
    SELECT SINGLE vtweg " Distribution Channel
      INTO lv_vtweg
      FROM tvtw         " Organizational Unit: Distribution Channels
      WHERE vtweg = fp_tabctrl-vtweg.

    IF sy-subrc <> 0.
      MESSAGE e000 WITH text-e01.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF fp_tabctrl-vtweg IS NOT INITIAL

  IF fp_tabctrl-spart IS NOT INITIAL.
    SELECT SINGLE spart " Division
      INTO lv_spart
      FROM tspa         " Organizational Unit: Sales Divisions
      WHERE spart = fp_tabctrl-spart.

    IF sy-subrc <> 0.
      MESSAGE e000  WITH text-e03.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF fp_tabctrl-spart IS NOT INITIAL

  IF fp_tabctrl-territory_id IS NOT INITIAL.
    SELECT SINGLE kunnr " Customer Number
      INTO lv_kunnr
      FROM kna1         " General Data in Customer Master
      WHERE kunnr = fp_tabctrl-territory_id
      AND ktokd = c_rep.

    IF sy-subrc <> 0.
      MESSAGE e000 WITH text-e04.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF fp_tabctrl-territory_id IS NOT INITIAL

  IF fp_tabctrl-empid IS NOT INITIAL.
    SELECT SINGLE lifnr " Account Number of Vendor or Creditor
      INTO lv_lifnr
      FROM lfa1         " Vendor Master (General Section)
      WHERE lifnr = fp_tabctrl-empid.

    IF sy-subrc <> 0.
      MESSAGE e000 WITH text-e02.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF fp_tabctrl-empid IS NOT INITIAL

  IF fp_tabctrl-effective_from > fp_tabctrl-effective_to.
    MESSAGE e000 WITH text-e06.
  ENDIF. " IF fp_tabctrl-effective_from > fp_tabctrl-effective_to

ENDFORM. " F_VALIDATE_TABLE_ENTRIES
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
ENDMODULE. " MODIFY_PROPERTY  OUTPUT
