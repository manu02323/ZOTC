*&---------------------------------------------------------------------*
*&  Include           ZOTCR0028O_PRICING_REPORT_SUB
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCR0028O_PRICING_REPORT_SUB                          *
* TITLE      :  Pricing Report for Mass Price Upload                   *
* DEVELOPER  :  ROHIT VERMA                                            *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_RDD_0028_Pricing Report for Mass Price Upload      *
*----------------------------------------------------------------------*
* DESCRIPTION: This is an include program of Report                    *
*              ZOTCN0028O_PRICING_REPORT. All subroutines for this     *
*              report is written in this include program.              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 22-Jul-2013 RVERMA   E1DK910844 INITIAL DEVELOPMENT - CR#410         *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_GET_F4_COND_TYPE
*&---------------------------------------------------------------------*
*       Subroutine to get list of condition type
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_get_f4_cond_type .
*&--Call FM to get list of condition type
  CALL FUNCTION 'RV_CONDITION_RECORD_DISPLAY'
    EXPORTING
      application            = gv_appl
      condition_classes_excl = c_cond_class
      condition_use          = gv_usage
      for_maintenance_only   = c_yes
      get_condition_type     = c_yes
    IMPORTING
      condition_type         = p_kschl
    EXCEPTIONS
      invalid_condition_type = 1
      OTHERS                 = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.                    " F_GET_F4_COND_TYPE
*&---------------------------------------------------------------------*
*&      Form  F_GET_INITIAL
*&---------------------------------------------------------------------*
*       Load initial values Application and Cond Usage from TVARVC table
*----------------------------------------------------------------------*
*      <--FP_GV_USAGE  Condition Usage
*      <--FP_GV_APPL   Application
*----------------------------------------------------------------------*
FORM f_get_initial  CHANGING fp_gv_usage TYPE kvewe
                             fp_gv_appl  TYPE kappl.

  DATA:
    li_tvarvc  TYPE ty_t_tvarvc, "TVARVC internal table
    lwa_tvarvc TYPE ty_tvarvc,   "TVARVC workarea
    lv_flg_err TYPE char01,      "Error flag
    lv_kvewe   TYPE kvewe,       "Usage Variable
    lv_kappl   TYPE kappl.       "Application Variable

*&--Fetch data from TVARVC table
  SELECT name type numb
         sign opti low
    FROM tvarvc
    INTO TABLE li_tvarvc
    WHERE name IN (c_name_usg, c_name_apl)
      AND type EQ c_type_p
      AND numb EQ c_numb_00.

  IF sy-subrc EQ 0.
*&--If data is fetched then sort the internal table by name
    SORT li_tvarvc BY name.

*&--Read tvarvc table to get usage value
    READ TABLE li_tvarvc INTO lwa_tvarvc
                         WITH KEY name = c_name_usg
                         BINARY SEARCH.
    IF sy-subrc EQ 0.
      fp_gv_usage = lwa_tvarvc-low+0(1).

      IF fp_gv_usage IS NOT INITIAL.
*&--Validate usage value with its check table; if invalid then
*&--raise error flag
        SELECT SINGLE kvewe
          FROM t681v
          INTO lv_kvewe
          WHERE kvewe EQ fp_gv_usage.
        IF sy-subrc NE 0.
          lv_flg_err = c_yes.
        ENDIF.

      ELSE.
*&--If usage value is balnk then raise error flag
        lv_flg_err = c_yes.
      ENDIF.

    ELSE.
*&--If usage value not found in tvarvc then raise error flag
      lv_flg_err = c_yes.
    ENDIF.

    CLEAR lwa_tvarvc.

*&--Read tvarvc table to get application value
    READ TABLE li_tvarvc INTO lwa_tvarvc
                         WITH KEY name = c_name_apl
                         BINARY SEARCH.
    IF sy-subrc EQ 0.
      fp_gv_appl = lwa_tvarvc-low+0(2).

      IF fp_gv_appl IS NOT INITIAL.
*&--Validate application value with its check table; if invalid
*&--then raise error flag
        SELECT SINGLE kappl
          FROM t681a
          INTO lv_kappl
          WHERE kappl EQ fp_gv_appl.
        IF sy-subrc NE 0.
          lv_flg_err = c_yes.
        ENDIF.
      ELSE.
*&--if application value is balnk then raise error flag
        lv_flg_err = c_yes.
      ENDIF.

    ELSE.
*&--If application value not found in tvarvc table then raise error flag
      lv_flg_err = c_yes.
    ENDIF.

  ELSE.
*&--If variant is not maintained in tvarvc table then raise error flag
    lv_flg_err = c_yes.
  ENDIF.

*&--If error flag is raised
  IF lv_flg_err EQ c_yes.
    MESSAGE E135
       WITH c_name_usg
            c_name_apl.
  ENDIF.

ENDFORM.                    " F_GET_INITIAL
*&---------------------------------------------------------------------*
*&      Form  F_GET_ACESS_SEQ
*&---------------------------------------------------------------------*
*       Subroutine to get access sequance table
*----------------------------------------------------------------------*
*      -->FP_GV_USAGE  text
*      -->FP_GV_APPL  text
*      -->FP_KSCHL  text
*      <--FP_X_T681  text
*      <--FP_X_TMC1T  text
*----------------------------------------------------------------------*
FORM f_get_acess_seq  USING fp_gv_usage TYPE kvewe
                            fp_gv_appl  TYPE kappl
                            fp_kschl    TYPE kscha
                   CHANGING fp_x_t681   TYPE t681
                            fp_x_tmc1t  TYPE tmc1t.

  DATA:
    lv_con_tab TYPE kotabnr,"Access Sequence Table

    lv_kozgf   TYPE kozgf.  "Access Sequence

*&--Fetch data from T685 table
  SELECT SINGLE kozgf
    FROM t685
    INTO lv_kozgf
    WHERE kvewe EQ fp_gv_usage AND
          kappl EQ fp_gv_appl AND
          kschl EQ fp_kschl.

  IF sy-subrc EQ 0.
*&--If data is fetched then check KOZGF and KSCHL; if different then
*&--raise an error
    IF lv_kozgf NE fp_kschl.
      MESSAGE I000
         WITH 'The Cond. type has a reference'(006)
              'Cond. type. Enter records for'(007)
              'Cond. type'(008)
              lv_kozgf.
    ENDIF.

  ELSE.
    MESSAGE I000
       WITH 'Incorrect Cond. type.'(009)
            fp_kschl.
       LEAVE LIST-PROCESSING.
  ENDIF.

  IF lv_kozgf IS NOT INITIAL.
*&--Call FM to get access sequence table list
    CALL FUNCTION 'RV_GET_CONDITION_TABLES'
      EXPORTING
        access_sequence        = lv_kozgf
        application            = fp_gv_appl
        condition_table        = lv_con_tab
        condition_type         = fp_kschl
        condition_use          = fp_gv_usage
        display_always         = c_yes
        get_text               = c_yes
        table_check_rule       = ''
      IMPORTING
        table_t681             = fp_x_t681
        table_tmc1t            = fp_x_tmc1t
      EXCEPTIONS
        invalid_condition_type = 1
        missing_parameter      = 2
        no_selection_done      = 3
        no_table_found         = 4
        table_not_valid        = 5
        OTHERS                 = 6.
    IF sy-subrc NE 0.
      LEAVE LIST-PROCESSING.
    ENDIF.

  ENDIF.

ENDFORM.                    " F_GET_ACESS_SEQ
