*&---------------------------------------------------------------------*
*& Include  LZOTC_0028_PRICING_REP_FGF01
*&---------------------------------------------------------------------*
************************************************************************
* INCLUDE    :  LZOTC_0028_PRICING_REP_FGF01                           *
* TITLE      :  Pricing Report for Mass Price Upload                   *
* DEVELOPER  :  ROHIT VERMA                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_RDD_0028_Pricing Report for Mass Price Upload      *
*----------------------------------------------------------------------*
* DESCRIPTION: Subroutine include for function group                   *
*              ZOTC_0028_PRICING_REP_FG                                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 22-Jul-2013 RVERMA   E1DK910844 INITIAL DEVELOPMENT - CR#410         *
*----------------------------------------------------------------------*
* 06-Sep-2013 RVERMA   E1DK910844 Defect#2056: When putting Sales      *
*                                 Representative in selection parameter*
*                                 is considering all the customers     *
*                                 irrespective of Distribution Channel.*
* 25-Mar-2013 SNIGAM   E1DK912987 Defect#1302: Pricing Report not      *
*                                 fetching correct Sold-to Ship-to list*
*                                 based on territory. To rectify this, *
*                                 remove the condition of PARZA as'0000'
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_GET_INITIAL_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FP_LV_PROGRAM  text
*      <--FP_LI_CODE  text
*----------------------------------------------------------------------*
FORM f_get_initial_code USING fp_v_program TYPE programm
                     CHANGING fp_i_code    TYPE zrcg_bag_rssource
                              fp_v_count   TYPE numc4.

  DATA:
    lwa_code TYPE rssource, "Source Code
    lv_date  TYPE char10,   "Date
    lv_time  TYPE char08.   "Time

  CONCATENATE sy-datum+4(2)
              '/'
              sy-datum+6(2)
              '/'
              sy-datum+0(4)
    INTO lv_date.

  CONCATENATE sy-uzeit+0(2)
              ':'
              sy-uzeit+2(2)
              ':'
              sy-uzeit+4(2)
    INTO lv_time.

  lwa_code-line = '*&---------------------------------------------------------------------*'(001).
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  lwa_code-line = '*& Report                                                              *'(002).
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  lwa_code-line = '*&---------------------------------------------------------------------*'(001).
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  CONCATENATE '* PROGRAM    :'(003)
              fp_v_program
    INTO lwa_code-line
    SEPARATED BY space.
  lwa_code-line+71(1) = c_star.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  lwa_code-line = '* DEVELOPER  : ROHIT VERMA                                             *'(004).
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  lwa_code-line = '* OBJECT TYPE: REPORT                                                  *'(005).
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  lwa_code-line = '* SAP RELEASE: SAP ECC 6.0                                             *'(006).
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  lwa_code-line = '*----------------------------------------------------------------------*'(007).
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  lwa_code-line = '* WRICEF ID  : OTC_RDD_0028_Pricing Report for Mass Price Upload       *'(008).
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  lwa_code-line = '*----------------------------------------------------------------------*'(007).
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  CONCATENATE '* Report-Generation from'(009)
              lv_date
              lv_time
    INTO lwa_code-line
    SEPARATED BY space.
  lwa_code-line+71(1) = c_star.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  lwa_code-line = '*----------------------------------------------------------------------*'(007).
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  lwa_code-line = '* !! This report is generated dynamically.!!                           *'(010).
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  lwa_code-line = '*                                                                      *'(011).
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  lwa_code-line = '* !! Please do not call this coding directly.  You must first call  !! *'(012).
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  lwa_code-line = '* !! the function ZOTC_CRE_PRICING_REP_CODE to insure that the      !! *'(013).
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  lwa_code-line = '* !! report exists and/or is up-to-date.                            !! *'(014).
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  lwa_code-line = '*                                                                      *'(011).
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  lwa_code-line = '* !! Do not change this report; your changes will be lost !!           *'(015).
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  lwa_code-line = '*----------------------------------------------------------------------*'(007).
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  lwa_code-line = ''.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  fp_v_count = fp_v_count + 1.

  CONCATENATE 'REPORT'(016)
              fp_v_program
              'NO STANDARD PAGE HEADING'(017)
    INTO lwa_code-line
    SEPARATED BY space.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'MESSAGE-ID'(018)
              c_msgid_otc
              c_dot
         INTO lwa_code-line
         SEPARATED BY space.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

ENDFORM.                    " F_GET_INITIAL_CODE
*&---------------------------------------------------------------------*
*&      Form  F_GET_SELECTION_CODE
*&---------------------------------------------------------------------*
*       Suboutine to get Report Code
*----------------------------------------------------------------------*
*  -->  FP_X_T681        Conditions: Structures Data
*  <--  FP_I_CODE        Source Code Table
*  <--  FO_I_TPOOL       Text Pool Table
*----------------------------------------------------------------------*
FORM f_get_report_code USING fp_x_t681  TYPE t681
                    CHANGING fp_i_code  TYPE zrcg_bag_rssource
                             fp_i_tpool TYPE textpool_table.

  DATA:
    li_t681e        TYPE ty_t_t681e,  "Fast-Entry Fields Table
    li_tab_info     TYPE ty_t_dfies,  "Table of Fields Info
    li_tab_info_tmp TYPE ty_t_dfies,  "Table of Fields Info
    li_sel_tab      TYPE ty_t_sel_tab, "Select-Option Table
    li_tab_fld      TYPE ty_t_tab_fld, "Field Info Table
    li_int_tab      TYPE ty_t_tab_fld, "Field Info Table
    li_str_fld      TYPE ty_t_str_fld, "Structres fields Table
    li_tvarvc       TYPE ty_t_tvarvc,  "TVARVC table

    lwa_code       TYPE rssource,   "Source Code Workarea
    lwa_code_tmp   TYPE rssource,   "Source Code Workarea
    lwa_tpool      TYPE textpool,   "Text Pool Workarea
    lwa_sel_tab    TYPE ty_sel_tab, "Select-Option Workarea
    lwa_tab_fld    TYPE ty_tab_fld, "Field Info Workare
    lwa_str_fld    TYPE ty_str_fld, "Structre Field Workarea

    lv_field       TYPE char30,   "Field Entry
    lv_selname     TYPE char08,   "Select Name/Field Entry
    lv_textkey     TYPE char08,   "Text Key
    lv_ty_tab      TYPE char30,   "Structure/Table/Field Entry
    lv_tab_nam     TYPE char30,   "Structure/Table/Field Entry
    lv_col_pos     TYPE numc2,    "Colomn Position
    lv_col_pos_v   TYPE char40,   "Colomn Position
    lv_kunweag_flg TYPE char01,   "Sold-to/Ship-to flag
    lv_kunwe_flg   TYPE char01,   "Ship-to flag
    lv_kunag_flg   TYPE char01,   "Sold-to flag
    lv_kunnr_flg   TYPE char01,   "Customer flag
    lv_kvgr1_flg   TYPE char01,   "Customer Grp1 flag
    lv_kvgr2_flg   TYPE char01,   "Customer Grp2 flag
    lv_matnr_flg   TYPE char01,   "Material flag
    lv_spart       TYPE spart,    "Division
*    lv_parza       TYPE parza,    "Partner Function Counter  "Commented by SNIGAM : CR1302 : 3/25/2014
    lv_parvw_sr    TYPE parvw.    "Partner function for sales rep

  FIELD-SYMBOLS:
    <lfs_tab_info>     TYPE dfies, "Field/Table Info
    <lfs_tab_info_tmp> TYPE dfies, "Field/Table Info
    <lfs_t681e>        TYPE t681e, "Fast-Entry Fields
    <lfs_tvarvc>       TYPE ty_tvarvc,  "TVARVC field-symbol
    <lfs_sel_tab>      TYPE ty_sel_tab, "Field Info
    <lfs_tab_fld>      TYPE ty_tab_fld. "Field Info

*&--Get constant values from TVARVC table
  SELECT name type numb
         sign opti low
    FROM tvarvc
    INTO TABLE li_tvarvc
    WHERE name IN (c_name_parvw_sr,
*                   c_name_parza, "Commented by SNIGAM : CR1302 : 3/25/2014
                   c_name_spart)
      AND type EQ c_type_p
      AND numb EQ c_numb_00.

  IF sy-subrc EQ 0.
    SORT li_tvarvc BY name.
*&--Get value of partner function for sales rep
    READ TABLE li_tvarvc ASSIGNING <lfs_tvarvc>
                         WITH KEY name = c_name_parvw_sr
                         BINARY SEARCH.
    IF sy-subrc EQ 0.
      lv_parvw_sr = <lfs_tvarvc>-low+0(2).
    ENDIF.
*BOC : SNIGAM : CR1302 : 3/25/2014
* Commented code below because PARZA as '00000' is no more required while fetching data from KNVP table
**&--Get value of partner counter for sales rep
*    READ TABLE li_tvarvc ASSIGNING <lfs_tvarvc>
*                         WITH KEY name = c_name_parza
*                         BINARY SEARCH.
*    IF sy-subrc EQ 0.
*      lv_parza = <lfs_tvarvc>-low+0(3).
*    ENDIF.
*EOC : SNIGAM : CR1302 : 3/25/2014

*&--Get value of division for sales rep
    READ TABLE li_tvarvc ASSIGNING <lfs_tvarvc>
                         WITH KEY name = c_name_spart
                         BINARY SEARCH.
    IF sy-subrc EQ 0.
      lv_spart = <lfs_tvarvc>-low+0(2).
    ENDIF.
  ENDIF.

*&--Get Conditions: Fast-Entry Fields
  SELECT *
    FROM t681e
    INTO TABLE li_t681e
    WHERE kvewe   EQ fp_x_t681-kvewe
      AND kotabnr EQ fp_x_t681-kotabnr
      AND setyp   EQ fp_x_t681-setyp.

  IF sy-subrc EQ 0.
    SORT li_t681e BY fsetyp fselnr.
  ENDIF.

*&--Get fields info for access sequence table
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = fp_x_t681-kotab
    TABLES
      dfies_tab      = li_tab_info
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.

  IF sy-subrc EQ 0.
*&--Sort info table based on data element
    SORT li_tab_info BY rollname.

*&--Check for Sold-to Party field's data element and make its flag yes
    READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                           WITH KEY rollname = c_kunag
                           BINARY SEARCH.
    IF sy-subrc EQ 0.
      lv_kunag_flg = c_yes.
    ENDIF.

*&--Check for Ship-to Party field's data element and make its flag yes
    READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                           WITH KEY rollname = c_kunwe
                           BINARY SEARCH.
    IF sy-subrc EQ 0.
      lv_kunwe_flg = c_yes.
    ENDIF.

*&--Check for customer group1 field's data element and make its flag yes
    READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                           WITH KEY rollname = c_kvgr1
                           BINARY SEARCH.
    IF sy-subrc EQ 0.
      lv_kvgr1_flg = c_yes.
    ENDIF.

*&--Check for customer group2 field's data element and make its flag yes
    READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                           WITH KEY rollname = c_kvgr2
                           BINARY SEARCH.
    IF sy-subrc EQ 0.
      lv_kvgr2_flg = c_yes.
    ENDIF.

*&--Check for customer number data element
    READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                           WITH KEY rollname = c_kunnr_v
                           BINARY SEARCH.
    IF sy-subrc EQ 0.
      lv_kunnr_flg = c_yes.
    ENDIF.

*&--Check for Material Number data element
    READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                           WITH KEY rollname = c_matnr
                           BINARY SEARCH.
    IF sy-subrc EQ 0.
      lv_matnr_flg = c_yes.
    ENDIF.

*&--Check for Customer Number field
    IF lv_kunnr_flg IS INITIAL.
      READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                             WITH KEY rollname = c_kunnr
                             BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_kunnr_flg = c_yes.
      ENDIF.
    ENDIF.

*&--SORT LI_TAB_INFO by fieldname
    SORT li_tab_info BY fieldname.

  ENDIF.

***********************************************************************
*--------Code for Tables Declaration----------------------------------*
***********************************************************************
*&--Build Code for TABLES decalaration
*&--Polpulating Tables statement for acces seq table
  CONCATENATE 'TABLES: '
              fp_x_t681-kotab
              c_dot
    INTO lwa_code-line.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_code TO fp_i_code. "Blank Line

***********************************************************************
*--------Code for Type Declaration------------------------------------*
***********************************************************************
*&--Build Code for TYPES Statement
  lwa_code-line = 'TYPES:'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_code TO fp_i_code. "Blank Line

*&--If ship-to or Sold-to party or Cutomer number is present in access seq table
  IF lv_kunag_flg IS NOT INITIAL OR
     lv_kunwe_flg IS NOT INITIAL OR
     lv_kunnr_flg IS NOT INITIAL.


*&--Build code to define structre of KNA1 table
    lwa_str_fld-field1 = c_kunnr.
    lwa_str_fld-field2 = c_kunnr_v.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    lwa_str_fld-field1 = c_name1.
    lwa_str_fld-field2 = c_name1_gp.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    lwa_str_fld-field1 = c_ort01.
    lwa_str_fld-field2 = c_ort01_gp.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    lwa_str_fld-field1 = c_kukla.
    lwa_str_fld-field2 = c_kukla.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    PERFORM f_get_str_dec_code USING c_kna1
                                     ''
                                     li_str_fld
                            CHANGING fp_i_code.

    CLEAR li_str_fld.
    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code to define structre for KNVV table
    lwa_str_fld-field1 = c_kunnr.
    lwa_str_fld-field2 = c_kunnr.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    lwa_str_fld-field1 = c_vkorg.
    lwa_str_fld-field2 = c_vkorg.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    lwa_str_fld-field1 = c_vtweg.
    lwa_str_fld-field2 = c_vtweg.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    lwa_str_fld-field1 = c_kdgrp.
    lwa_str_fld-field2 = c_kdgrp.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    lwa_str_fld-field1 = c_kvgr1.
    lwa_str_fld-field2 = c_kvgr1.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    lwa_str_fld-field1 = c_kvgr2.
    lwa_str_fld-field2 = c_kvgr2.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    PERFORM f_get_str_dec_code USING c_knvv
                                     ''
                                     li_str_fld
                            CHANGING fp_i_code.

    CLEAR li_str_fld.
    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code to define structre for KNVP table
    lwa_str_fld-field1 = c_kunnr.
    lwa_str_fld-field2 = c_kunnr.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    lwa_str_fld-field1 = c_vkorg.
    lwa_str_fld-field2 = c_vkorg.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    lwa_str_fld-field1 = c_vtweg.
    lwa_str_fld-field2 = c_vtweg.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    lwa_str_fld-field1 = c_spart.
    lwa_str_fld-field2 = c_spart.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    lwa_str_fld-field1 = c_parvw.
    lwa_str_fld-field2 = c_parvw.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    lwa_str_fld-field1 = c_parza.
    lwa_str_fld-field2 = c_parza.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.


    lwa_str_fld-field1 = c_kunn2.
    lwa_str_fld-field2 = c_kunn2.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    PERFORM f_get_str_dec_code USING c_knvp
                                     ''
                                     li_str_fld
                            CHANGING fp_i_code.

    CLEAR li_str_fld.
    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Bulid code to define structre for T151T table
    lwa_str_fld-field1 = c_kdgrp.
    lwa_str_fld-field2 = c_kdgrp.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    lwa_str_fld-field1 = c_ktext.
    lwa_str_fld-field2 = c_vtxtk.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    PERFORM f_get_str_dec_code USING c_t151t
                                     ''
                                     li_str_fld
                            CHANGING fp_i_code.

    CLEAR li_str_fld.
    APPEND lwa_code TO fp_i_code. "Blank Line


*&--Bulid code to define structre for TKUKT table
    lwa_str_fld-field1 = c_kukla.
    lwa_str_fld-field2 = c_kukla.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    lwa_str_fld-field1 = c_vtext.
    lwa_str_fld-field2 = c_bezei20.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    PERFORM f_get_str_dec_code USING c_tkukt
                                     ''
                                     li_str_fld
                            CHANGING fp_i_code.

    CLEAR li_str_fld.
    APPEND lwa_code TO fp_i_code. "Blank Line

  ENDIF.

*&--If ship-to or Sold-to party or Customer Group1 is present in access seq table
  IF lv_kunag_flg IS NOT INITIAL OR
     lv_kunwe_flg IS NOT INITIAL OR
     lv_kunnr_flg IS NOT INITIAL OR
     lv_kvgr1_flg IS NOT INITIAL.

*&--Bulid code to define structre for TVV1T table
    lwa_str_fld-field1 = c_kvgr1.
    lwa_str_fld-field2 = c_kvgr1.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    lwa_str_fld-field1 = c_bezei.
    lwa_str_fld-field2 = c_bezei20.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    PERFORM f_get_str_dec_code USING c_tvv1t
                                     ''
                                     li_str_fld
                            CHANGING fp_i_code.

    CLEAR li_str_fld.
    APPEND lwa_code TO fp_i_code. "Blank Line

  ENDIF.

*&--If ship-to or Sold-to party or customer group2 is present in access seq table
  IF lv_kunag_flg IS NOT INITIAL OR
     lv_kunwe_flg IS NOT INITIAL OR
     lv_kunnr_flg IS NOT INITIAL OR
     lv_kvgr2_flg IS NOT INITIAL.

*&--Buliding structre for TVV2T table
    lwa_str_fld-field1 = c_kvgr2.
    lwa_str_fld-field2 = c_kvgr2.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    lwa_str_fld-field1 = c_bezei.
    lwa_str_fld-field2 = c_bezei20.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    PERFORM f_get_str_dec_code USING c_tvv2t
                                     ''
                                     li_str_fld
                            CHANGING fp_i_code.

    CLEAR li_str_fld.
    APPEND lwa_code TO fp_i_code. "Blank Line

  ENDIF.

*&--If Material number is present in access seq table
  IF lv_matnr_flg IS NOT INITIAL.

*&--Bulid code to define structre for MAKT table
    lwa_str_fld-field1 = c_matnr.
    lwa_str_fld-field2 = c_matnr.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    lwa_str_fld-field1 = c_maktx.
    lwa_str_fld-field2 = c_maktx.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

    PERFORM f_get_str_dec_code USING c_makt
                                     ''
                                     li_str_fld
                            CHANGING fp_i_code.

    CLEAR li_str_fld.
    APPEND lwa_code TO fp_i_code. "Blank Line

  ENDIF.

*&--Build code to define structure for KONP table
  lwa_str_fld-field1 = c_knumh.
  lwa_str_fld-field2 = c_knumh.
  APPEND lwa_str_fld TO li_str_fld.
  CLEAR lwa_str_fld.

  lwa_str_fld-field1 = c_kopos.
  lwa_str_fld-field2 = c_kopos.
  APPEND lwa_str_fld TO li_str_fld.
  CLEAR lwa_str_fld.

  lwa_str_fld-field1 = c_krech.
  lwa_str_fld-field2 = c_krech.
  APPEND lwa_str_fld TO li_str_fld.
  CLEAR lwa_str_fld.

  lwa_str_fld-field1 = c_kbetr.
  lwa_str_fld-field2 = c_kbetr_kond.
  APPEND lwa_str_fld TO li_str_fld.
  CLEAR lwa_str_fld.

  lwa_str_fld-field1 = c_konwa.
  lwa_str_fld-field2 = c_konwa.
  APPEND lwa_str_fld TO li_str_fld.
  CLEAR lwa_str_fld.

  lwa_str_fld-field1 = c_kpein.
  lwa_str_fld-field2 = c_kpein.
  APPEND lwa_str_fld TO li_str_fld.
  CLEAR lwa_str_fld.

  lwa_str_fld-field1 = c_kmein.
  lwa_str_fld-field2 = c_kmein.
  APPEND lwa_str_fld TO li_str_fld.
  CLEAR lwa_str_fld.

  PERFORM f_get_str_dec_code USING c_konp
                                   ''
                                   li_str_fld
                          CHANGING fp_i_code.

  CLEAR li_str_fld.
  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code to define final structure
  CONCATENATE 'BEGIN OF'
              c_ty_final
              c_comma
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Get code for TYPE statement and final table information
*&--for Application field
  PERFORM f_get_field_code USING c_kappl
                                 c_kappl
                                 'Application'(056)
                        CHANGING lwa_code
                                 lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Condition Type field
  PERFORM f_get_field_code USING c_kschl
                                 c_kscha
                                 'Condition Type'(019)
                        CHANGING lwa_code
                                 lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Sales Org field
  PERFORM f_get_field_code USING c_vkorg
                                 c_vkorg
                                 'Sales Organization'(020)
                        CHANGING lwa_code
                                 lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Distribution Channel field
  PERFORM f_get_field_code USING c_vtweg
                                 c_vtweg
                                 'Distribution Channel'(021)
                        CHANGING lwa_code
                                 lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--If Customer Number is present
  IF lv_kunnr_flg IS NOT INITIAL.

*&--Get code for TYPE statement and final table information
*&--for Customer Number field
    PERFORM f_get_field_code USING c_fld1
                                   c_kunnr
                                   'Sold-to-Party'(024)
                          CHANGING lwa_code
                                   lwa_tab_fld.

    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.
    APPEND lwa_tab_fld TO li_tab_fld.
    CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Customer Name field
    PERFORM f_get_field_desc_code USING c_fld1
                                        c_name1_gp
                                        'Sold-to Description'(025)
                               CHANGING lwa_code
                                        lwa_tab_fld.

    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.
    APPEND lwa_tab_fld TO li_tab_fld.
    CLEAR lwa_tab_fld.

*&--If Sold-to field is present
  ELSEIF lv_kunag_flg IS NOT INITIAL.

*&--Get code for TYPE statement and final table information
*&--for Sold-to-Party field
    PERFORM f_get_field_code USING c_fld1
                                   c_kunag
                                   'Sold-to-Party'(024)
                          CHANGING lwa_code
                                   lwa_tab_fld.

    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.
    APPEND lwa_tab_fld TO li_tab_fld.
    CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Sold-to Description field
    PERFORM f_get_field_desc_code USING c_fld1
                                        c_name1_gp
                                        'Sold-to Description'(025)
                               CHANGING lwa_code
                                        lwa_tab_fld.

    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.
    APPEND lwa_tab_fld TO li_tab_fld.
    CLEAR lwa_tab_fld.

*&--If Ship-to field is present
  ELSEIF lv_kunwe_flg IS NOT INITIAL.

*&--Get code for TYPE statement and final table information
*&--for Ship-to-Party field
    PERFORM f_get_field_code USING c_fld1
                                   c_kunwe
                                   'Ship-to-Party'(026)
                          CHANGING lwa_code
                                   lwa_tab_fld.

    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.
    APPEND lwa_tab_fld TO li_tab_fld.
    CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Ship-to Description field
    PERFORM f_get_field_desc_code USING c_fld1
                                        c_name1_gp
                                        'Ship-to Description'(027)
                               CHANGING lwa_code
                                        lwa_tab_fld.

    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.
    APPEND lwa_tab_fld TO li_tab_fld.
    CLEAR lwa_tab_fld.

*&--If Customer Grp1 is present
  ELSEIF lv_kvgr1_flg IS NOT INITIAL.

*&--Get code for TYPE statement and final table information
*&--for Buying Group field
    PERFORM f_get_field_code USING c_fld1
                                   c_kvgr1
                                   'Buying Group'(028)
                          CHANGING lwa_code
                                   lwa_tab_fld.

    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.
    APPEND lwa_tab_fld TO li_tab_fld.
    CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Buying Group Description field
    PERFORM f_get_field_desc_code USING c_fld1
                                        c_bezei20
                                        'Buying Grp Description'(029)
                               CHANGING lwa_code
                                        lwa_tab_fld.

    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.
    APPEND lwa_tab_fld TO li_tab_fld.
    CLEAR lwa_tab_fld.

*&--If Customer Grp2 field is present
  ELSEIF lv_kvgr2_flg IS NOT INITIAL.

*&--Get code for TYPE statement and final table information
*&--for IDN Code field
    PERFORM f_get_field_code USING c_fld1
                                   c_kvgr2
                                   'IDN Code'(030)
                          CHANGING lwa_code
                                   lwa_tab_fld.

    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.
    APPEND lwa_tab_fld TO li_tab_fld.
    CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for IDN Description field
    PERFORM f_get_field_desc_code USING c_fld1
                                        c_bezei
                                        'IDN Description'(031)
                               CHANGING lwa_code
                                        lwa_tab_fld.

    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.
    APPEND lwa_tab_fld TO li_tab_fld.
    CLEAR lwa_tab_fld.

*&--If Material Number is present
  ELSEIF lv_matnr_flg IS NOT INITIAL.

*&--Get code for TYPE statement and final table information
*&--for Material field
    PERFORM f_get_field_code USING c_fld1
                                   c_matnr
                                   'Material'(032)
                          CHANGING lwa_code
                                   lwa_tab_fld.

    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.
    APPEND lwa_tab_fld TO li_tab_fld.
    CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Material Description field
    PERFORM f_get_field_desc_code USING c_fld1
                                        c_maktx
                                        'Material Description'(033)
                               CHANGING lwa_code
                                        lwa_tab_fld.

    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.
    APPEND lwa_tab_fld TO li_tab_fld.
    CLEAR lwa_tab_fld.

  ENDIF.

*&--Get code for TYPE statement and final table information
*&--for Material field
  PERFORM f_get_field_code USING c_matnr
                                 c_matnr
                                 'Material'(032)
                        CHANGING lwa_code
                                 lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Material Description field
  PERFORM f_get_field_desc_code USING c_matnr
                                      c_maktx
                                      'Material Description'(033)
                             CHANGING lwa_code
                                      lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.


*&--Get code for TYPE statement and final table information
*&--for City Type field
  PERFORM f_get_field_code USING c_ort01
                                 c_ort01_gp
                                 'City'(034)
                        CHANGING lwa_code
                                 lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Buying Group field
  PERFORM f_get_field_code USING c_kvgr1
                                 c_kvgr1
                                 'Buying Group'(028)
                        CHANGING lwa_code
                                 lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Buying Group Description field
  PERFORM f_get_field_desc_code USING c_kvgr1
                                      c_bezei20
                                      'Buying Grp Description'(029)
                             CHANGING lwa_code
                                      lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for IDN Code field
  PERFORM f_get_field_code USING c_kvgr2
                                 c_kvgr2
                                 'IDN Code'(030)
                        CHANGING lwa_code
                                 lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for IDn Description field
  PERFORM f_get_field_desc_code USING c_kvgr2
                                      c_bezei20
                                      'IDN Description'(031)
                             CHANGING lwa_code
                                      lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for GPO Code field
  PERFORM f_get_field_code USING c_kdgrp
                                 c_kdgrp
                                 'GPO Code'(039)
                        CHANGING lwa_code
                                 lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for GPO Description field
  PERFORM f_get_field_desc_code USING c_kdgrp
                                      c_vtxtk
                                      'GPO Description'(040)
                             CHANGING lwa_code
                                      lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Customer Class field
  PERFORM f_get_field_code USING c_kukla
                                 c_kukla
                                 'Customer Class'(041)
                        CHANGING lwa_code
                                 lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Customer Class Description field
  PERFORM f_get_field_desc_code USING c_kukla
                                      c_bezei20
                                      'Customer Class Description'(042)
                             CHANGING lwa_code
                                      lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Valid From field
  PERFORM f_get_field_code USING c_datab
                                 c_char10
                                 'Valid From'(043)
                        CHANGING lwa_code
                                 lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Valid To field
  PERFORM f_get_field_code USING c_datbi
                                 c_char10
                                 'Valid To'(044)
                        CHANGING lwa_code
                                 lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Amount field
  PERFORM f_get_field_code USING c_kbetr
                                 c_kbetr_kond
                                 'Amount'(045)
                        CHANGING lwa_code
                                 lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_tab_fld-fname_c = c_konwa.
  lwa_tab_fld-fdataty = c_curr.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Condition Currency field
  PERFORM f_get_field_code USING c_konwa
                                 c_konwa
                                 'Condition Currency'(046)
                        CHANGING lwa_code
                                 lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Pricing Unit field
  PERFORM f_get_field_code USING c_kpein
                                 c_kpein
                                 'Pricing Unit'(047)
                        CHANGING lwa_code
                                 lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_tab_fld-fname_q = c_kmein.
  lwa_tab_fld-fdataty = c_quan.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Unit Of Measurement field
  PERFORM f_get_field_code USING c_kmein
                                 c_kmein
                                 'UoM'
                        CHANGING lwa_code
                                 lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Sales Rep field
  PERFORM f_get_field_code USING c_kunn2
                                 c_kunn2
                                 'Sales Representative'(048)
                        CHANGING lwa_code
                                 lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Sales Rep Description field
  PERFORM f_get_field_desc_code USING c_kunn2
                                      c_name1_gp
                                      'Sales Rep Description'(049)
                             CHANGING lwa_code
                                      lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Internal Comment field
  PERFORM f_get_field_code USING c_ltx01
                                 c_ltext72
                                 'Internal Comment'(050)
                        CHANGING lwa_code
                                 lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Internal Comment Indicator field
  PERFORM f_get_field_desc_code USING c_ltx01
                                      c_char01
                                      'Internal Cmnt Indicator'(051)
                             CHANGING lwa_code
                                      lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

*&--Get code for TYPE statement and final table information
*&--for Condition Table field
  PERFORM f_get_field_code USING c_kotab
                                 c_kotab
                                 'Condition Table'(055)
                        CHANGING lwa_code
                                 lwa_tab_fld.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_tab_fld TO li_tab_fld.
  CLEAR lwa_tab_fld.

  CONCATENATE 'END OF'
              c_ty_final
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line


***********************************************************************
*--------Code for Data Declaration------------------------------------*
***********************************************************************

*&--Build Code for data statement
  lwa_code-line = 'DATA:'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--If ship-to or sold-to or customer number is present in access seq table
  IF lv_kunag_flg IS NOT INITIAL OR
     lv_kunwe_flg IS NOT INITIAL OR
     lv_kunnr_flg IS NOT INITIAL.

*&--Bulid code to define internal table and Workarea for KNA1 table
    PERFORM f_get_i_wa_code USING c_kna1
                                  c_yes
                                  ''
                         CHANGING fp_i_code
                                  li_int_tab.

    APPEND lwa_code TO fp_i_code. " Blank Line

*&--Bulid code to define temporary internal table for KNA1 table
    PERFORM f_get_i_wa_code USING c_kna1
                                  ''
                                  c_yes
                         CHANGING fp_i_code
                                  li_int_tab.

    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Bulid code to define internal table & workarea for KNVV table
    PERFORM f_get_i_wa_code USING c_knvv
                                  c_yes
                                  ''
                         CHANGING fp_i_code
                                  li_int_tab.

    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Bulid code to define temp internal table & workarea for KNVV table
    PERFORM f_get_i_wa_code USING c_knvv
                                  c_yes
                                  c_yes
                         CHANGING fp_i_code
                                  li_int_tab.

    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Bulid code to define internal table & workarea for KNVP table
    PERFORM f_get_i_wa_code USING c_knvp
                                  c_yes
                                  ''
                         CHANGING fp_i_code
                                  li_int_tab.

    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Bulid code to define temp internal table for KNVP table
    PERFORM f_get_i_wa_code USING c_knvp
                                  ''
                                  c_yes
                         CHANGING fp_i_code
                                  li_int_tab.

    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Bulid code to define internal table & workarea for T151T table
    PERFORM f_get_i_wa_code USING c_t151t
                                  c_yes
                                  ''
                         CHANGING fp_i_code
                                  li_int_tab.

    APPEND lwa_code TO fp_i_code. "Blank Line


*&--Bulid code to define internal table & workarea for TKUKT table
    PERFORM f_get_i_wa_code USING c_tkukt
                                  c_yes
                                  ''
                         CHANGING fp_i_code
                                  li_int_tab.

    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Bulid code to define internal table for CUSTOMER table
    CONCATENATE c_i_customer
                'TYPE STANDARD TABLE OF'
                c_selopt
                c_comma
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_tab_fld-fname = c_i_customer.
    APPEND lwa_tab_fld TO li_int_tab.
    CLEAR lwa_tab_fld.

    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Bulid code to define internal table for CUSTOMER table
    CONCATENATE c_i_salesorg
                'TYPE STANDARD TABLE OF'
                c_selopt
                c_comma
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_tab_fld-fname = c_i_salesorg.
    APPEND lwa_tab_fld TO li_int_tab.
    CLEAR lwa_tab_fld.

    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Bulid code to define internal table for CUSTOMER table
    CONCATENATE c_i_salesdis
                'TYPE STANDARD TABLE OF'
                c_selopt
                c_comma
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_tab_fld-fname = c_i_salesdis.
    APPEND lwa_tab_fld TO li_int_tab.
    CLEAR lwa_tab_fld.

    APPEND lwa_code TO fp_i_code. "Blank Line

  ENDIF.

*&--If ship-to or sold-to or customer group1 is present in access seq table
  IF lv_kunag_flg IS NOT INITIAL OR
     lv_kunwe_flg IS NOT INITIAL OR
     lv_kunnr_flg IS NOT INITIAL OR
     lv_kvgr1_flg IS NOT INITIAL.

*&--Bulid code to define internal table & workarea for TVV1T table
    PERFORM f_get_i_wa_code USING c_tvv1t
                                  c_yes
                                  ''
                         CHANGING fp_i_code
                                  li_int_tab.

    APPEND lwa_code TO fp_i_code. "Blank Line

  ENDIF.

*&--If ship-to or sold-to or customer group2 is present in access seq table
  IF lv_kunag_flg IS NOT INITIAL OR
     lv_kunwe_flg IS NOT INITIAL OR
     lv_kunnr_flg IS NOT INITIAL OR
     lv_kvgr2_flg IS NOT INITIAL.

*&--Bulid code to define internal table & workarea for TVV2T table
    PERFORM f_get_i_wa_code USING c_tvv2t
                                  c_yes
                                  ''
                         CHANGING fp_i_code
                                  li_int_tab.

    APPEND lwa_code TO fp_i_code. "Blank Line

  ENDIF.

*&--If material number is present in access seq table
  IF lv_matnr_flg IS NOT INITIAL.

*&--Bulid code to define internal table & workarea for MAKT table
    PERFORM f_get_i_wa_code USING c_makt
                                  c_yes
                                  ''
                         CHANGING fp_i_code
                                  li_int_tab.

    APPEND lwa_code TO fp_i_code. "Blank Line

  ENDIF.

*&--Bulid code to define internal table & workarea for Access Sequence table
  CONCATENATE c_i
              fp_x_t681-kotab
    INTO lwa_code-line.

  lwa_tab_fld-fname = lwa_code-line.
  APPEND lwa_tab_fld TO li_int_tab.
  CLEAR lwa_tab_fld.

  CONCATENATE lwa_code-line
              'TYPE STANDARD TABLE OF'
              fp_x_t681-kotab
              c_comma
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Bulid code to define workarea for Access Sequence table
  CONCATENATE c_wa
              fp_x_t681-kotab
    INTO lwa_code-line.
  CONCATENATE lwa_code-line
              'TYPE'
              fp_x_t681-kotab
              c_comma
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Bulid code to define temp internal table & workarea for Access Sequence table
  CONCATENATE c_i
              fp_x_t681-kotab
              c_uscore
              c_tmp
    INTO lwa_code-line.

  lwa_tab_fld-fname = lwa_code-line.
  APPEND lwa_tab_fld TO li_int_tab.
  CLEAR lwa_tab_fld.

  CONCATENATE lwa_code-line
              'TYPE STANDARD TABLE OF'
              fp_x_t681-kotab
              c_comma
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Bulid code to define temp workarea for Access Sequence table
  CONCATENATE c_wa
              fp_x_t681-kotab
              c_uscore
              c_tmp
    INTO lwa_code-line.
  CONCATENATE lwa_code-line
              'TYPE'
              fp_x_t681-kotab
              c_comma
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Bulid code to define internal table for KONP table
  PERFORM f_get_i_wa_code USING c_konp
                                c_yes
                                ''
                       CHANGING fp_i_code
                                li_int_tab.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Bulid code to define internal table for LINES table
  CONCATENATE c_i_lines
              'TYPE STANDARD TABLE OF'
              c_tlines
              c_comma
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_tab_fld-fname = c_i_lines.
  APPEND lwa_tab_fld TO li_int_tab.
  CLEAR lwa_tab_fld.

*&--Bulid code to define workarea for LINES table
  CONCATENATE c_wa_lines
              'TYPE'
              c_tlines
              c_comma
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Bulid code to define internal table for FINAL table
  CONCATENATE c_i_final
              'TYPE STANDARD TABLE OF'
              c_ty_final
              c_comma
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Bulid code to define workarea for FINAL table
  CONCATENATE c_wa_final
              'TYPE'
              c_ty_final
              c_comma
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Declaring global variables of fields------------------------------&*

*&--Bulid code to define variable of access sequence table fields
  LOOP AT li_t681e ASSIGNING <lfs_t681e>.

*&--Check if there is field KFRST then dont define
    IF <lfs_t681e>-sefeld+0(5) EQ c_kfrst.
      CONTINUE.
    ENDIF.

*&--Read field info table to get data element name
    READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                           WITH KEY fieldname = <lfs_t681e>-sefeld
                           BINARY SEARCH.
    IF sy-subrc EQ 0.
*&--Defining variable
      lwa_str_fld-field1+0(3) = c_gv.
      lwa_str_fld-field1+3    = <lfs_t681e>-sefeld.
      lwa_str_fld-field2      = <lfs_tab_info>-rollname.
      APPEND lwa_str_fld TO li_str_fld.
      CLEAR lwa_str_fld.

    ENDIF.
  ENDLOOP.

*&--If sold-to or ship-to is present
  IF lv_kunag_flg IS NOT INITIAL OR
     lv_kunwe_flg IS NOT INITIAL OR
     lv_kunnr_flg IS NOT INITIAL.

*&--Bulid code to define variable for Sales Representative field
    lwa_str_fld-field1 = c_gv_salesrep.
    lwa_str_fld-field2 = c_kunn2.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

*&--Bulid code to define variable for Sales Representative flag field
    lwa_str_fld-field1 = c_gv_salesflg.
    lwa_str_fld-field2 = c_char01.
    APPEND lwa_str_fld TO li_str_fld.
    CLEAR lwa_str_fld.

  ENDIF.

*&--Bulid code to define variable for Valid From field
  lwa_str_fld-field1 = c_gv_datab.
  lwa_str_fld-field2 = c_kodatab.
  APPEND lwa_str_fld TO li_str_fld.
  CLEAR lwa_str_fld.

*&--Bulid code to define variable for Valid To field
  lwa_str_fld-field1 = c_gv_datbi.
  lwa_str_fld-field2 = c_kodatbi.
  APPEND lwa_str_fld TO li_str_fld.
  CLEAR lwa_str_fld.

*&--Bulid code to define variable for Index field
  lwa_str_fld-field1 = c_gv_index.
  lwa_str_fld-field2 = c_sytabix.
  APPEND lwa_str_fld TO li_str_fld.
  CLEAR lwa_str_fld.

*&--Bulid code to define variable for Object Name field
  lwa_str_fld-field1 = c_gv_name.
  lwa_str_fld-field2 = c_tdobname.
  APPEND lwa_str_fld TO li_str_fld.
  CLEAR lwa_str_fld.

*&--Bulid code to define variable for final record count
  lwa_str_fld-field1 = c_gv_total.
  lwa_str_fld-field2 = c_sign_i.
  APPEND lwa_str_fld TO li_str_fld.
  CLEAR lwa_str_fld.

*&--Call subroutine to build code for variable declaration
  PERFORM f_get_var_dec_code USING li_str_fld
                          CHANGING fp_i_code.

  CLEAR li_str_fld.
  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Bulid code to define ALV Components
  CONCATENATE c_i_fieldcat
              'TYPE'
              c_t_fieldcat
              c_comma
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE c_wa_fieldcat
              'TYPE'
              c_fieldcat
              c_comma
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_tab_fld-fname = c_i_fieldcat.
  APPEND lwa_tab_fld TO li_int_tab.
  CLEAR lwa_tab_fld.

  APPEND lwa_code TO fp_i_code. "Blank Line


  CONCATENATE c_i_listhead
              'TYPE'
              c_t_listhead
              c_comma
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE c_wa_listhead
              'TYPE'
              c_listhead
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_tab_fld-fname = c_i_listhead.
  APPEND lwa_tab_fld TO li_int_tab.
  CLEAR lwa_tab_fld.

  APPEND lwa_code TO fp_i_code. "Blank Line
  APPEND lwa_code TO fp_i_code. "Blank Line


***********************************************************************
*--------Code for Selection Screen------------------------------------*
***********************************************************************

*&--Code for selection screen event
  gv_textkey_no = gv_textkey_no + 1.
  lv_textkey = c_textkey.
  lv_textkey+5(3) = gv_textkey_no.
  CONCATENATE 'SELECTION-SCREEN BEGIN OF BLOCK'
              c_scr_block1
              'WITH FRAME TITLE'
              lv_textkey
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Code for text element: text-001
  lwa_tpool-id = c_tpool_id_i.
  lwa_tpool-key = gv_textkey_no.
  lwa_tpool-entry = 'Selection Screen'(052).
  APPEND lwa_tpool TO fp_i_tpool.
  CLEAR: lwa_tpool,
         lv_textkey.

*&--Code for parameter: Application
  CONCATENATE 'PARAMETERS'
              c_p_kappl
              'TYPE'
              c_kappl
              'NO-DISPLAY'
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Code for parameter: Condition Type
  CONCATENATE 'PARAMETERS'
              c_p_kschl
              'TYPE'
              c_kscha
              'NO-DISPLAY'
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Code for parameter: Condition Type
  CONCATENATE 'PARAMETERS'
              c_p_kotab
              'TYPE'
              c_kotab
              'NO-DISPLAY'
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  LOOP AT li_t681e ASSIGNING <lfs_t681e>.
*&--T681E-SEFELD is KFRST then it should not come in selection screen
    IF <lfs_t681e>-sefeld+0(5) EQ c_kfrst.
      CONTINUE.
    ENDIF.

*&--Code for select options
    CONCATENATE fp_x_t681-kotab
                <lfs_t681e>-sefeld
      INTO lv_field
      SEPARATED BY c_hyphen.
    CONCATENATE c_so
                <lfs_t681e>-sefeld+0(6)
      INTO lv_selname.

*&--Check T681E-SEFELD for Sales Org and Distr Channel and make these mandatory
    IF <lfs_t681e>-sefeld+0(5) EQ c_vkorg OR
       <lfs_t681e>-sefeld+0(5) EQ c_vtweg.
      CONCATENATE 'SELECT-OPTIONS'
                  lv_selname
                  'FOR'
                  lv_field
                  'OBLIGATORY'
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
    ELSE.
      CONCATENATE 'SELECT-OPTIONS'
                  lv_selname
                  'FOR'
                  lv_field
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
    ENDIF.

*&--Populating Select-Option table
    lwa_sel_tab-selname = lv_selname.
    lwa_sel_tab-field = <lfs_t681e>-sefeld.
    APPEND lwa_sel_tab TO li_sel_tab.
    CLEAR lwa_sel_tab.

*&--Code for Text elements of select options
    READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                           WITH KEY fieldname = <lfs_t681e>-sefeld
                           BINARY SEARCH.
    IF sy-subrc EQ 0.
      lwa_tpool-id = c_tpool_id_s.
      lwa_tpool-key = lv_selname.
      lwa_tpool-entry+8 = <lfs_tab_info>-scrtext_m.

      APPEND lwa_tpool TO fp_i_tpool.

*&--Check if Sold-to or Ship-to field are present or not
      IF <lfs_tab_info>-rollname EQ c_kunwe OR
         <lfs_tab_info>-rollname EQ c_kunag OR
         <lfs_tab_info>-rollname EQ c_kunnr OR
         <lfs_tab_info>-rollname EQ c_kunnr_v.
*&--If present then set the sold-to ship-to flag
        IF lv_kunweag_flg IS INITIAL.

*&--Code for parameter: Sales Representative
          CONCATENATE 'PARAMETERS P_KUNN2 TYPE KUNN2'
                      'MATCHCODE OBJECT DEBI'
                      c_dot
                 INTO lwa_code_tmp-line
                 SEPARATED BY space.
          APPEND lwa_code_tmp TO fp_i_code.
          CLEAR lwa_code_tmp.

*&--Code for text element: : Sales Representative
          lwa_tpool-id = c_tpool_id_s.
          lwa_tpool-key = c_p_kunn2.
          lwa_tpool-entry+8 = 'Sales Representative'(048).
          APPEND lwa_tpool TO fp_i_tpool.

*&--Mark the Sold-to Ship-to flag
          lv_kunweag_flg = c_yes.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND lwa_code TO fp_i_code.

    CLEAR: lwa_code,
           lwa_tpool,
           lv_field,
           lv_selname.
  ENDLOOP.

  CLEAR lv_kunweag_flg.

*&--Code for Selection Screen Skip
  lwa_code-line = 'SELECTION-SCREEN SKIP.'.
  APPEND lwa_code TO fp_i_code.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Code for select option: Valid From
  CONCATENATE 'SELECT-OPTIONS'
              c_s_datab
              'FOR'
              c_gv_datab
              'OBLIGATORY'
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.

*&--Code for text element: Valid From
  lwa_tpool-id = c_tpool_id_s.
  lwa_tpool-key = c_s_datab.
  lwa_tpool-entry+8 = 'Valid From'(043).
  APPEND lwa_tpool TO fp_i_tpool.

  CLEAR: lwa_code,
         lwa_tpool.

*&--Code for select option: Valid To
  CONCATENATE 'SELECT-OPTIONS'
              c_s_datbi
              'FOR'
              c_gv_datbi
              'OBLIGATORY'
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.

*&--Code for text element: Valid To
  lwa_tpool-id = c_tpool_id_s.
  lwa_tpool-key = c_s_datbi.
  lwa_tpool-entry+8 = 'Valid To'(044).
  APPEND lwa_tpool TO fp_i_tpool.

  CLEAR: lwa_code,
         lwa_tpool.

  CONCATENATE 'SELECTION-SCREEN END OF BLOCK'
              c_scr_block1
              c_dot
    INTO lwa_code-line
  SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line
  APPEND lwa_code TO fp_i_code. "Blank Line

***********************************************************************
*--------Code for At Selection Screen---------------------------------*
***********************************************************************

  CLEAR: lv_selname.

  LOOP AT li_t681e ASSIGNING <lfs_t681e>.
*&--Check if there is field KFRST then do not validate as it is not on selection screen
    IF <lfs_t681e>-sefeld+0(5) EQ c_kfrst.
      CONTINUE.
    ENDIF.

*&--Check if check table is present then validate that corresponding field value with its check table
    READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                           WITH KEY fieldname = <lfs_t681e>-sefeld
                           BINARY SEARCH.
    IF sy-subrc EQ 0.
      IF <lfs_tab_info>-checktable IS NOT INITIAL.

        CLEAR: li_tab_info_tmp.

        CALL FUNCTION 'DDIF_FIELDINFO_GET'
          EXPORTING
            tabname        = <lfs_tab_info>-checktable
          TABLES
            dfies_tab      = li_tab_info_tmp
          EXCEPTIONS
            not_found      = 1
            internal_error = 2
            OTHERS         = 3.

        IF sy-subrc EQ 0.
          SORT li_tab_info_tmp BY fieldname.
*&--Get fieldname from check table based on fieldname
          READ TABLE li_tab_info_tmp ASSIGNING <lfs_tab_info_tmp>
                                     WITH KEY fieldname = <lfs_tab_info>-fieldname
                                     BINARY SEARCH.
          IF sy-subrc EQ 0.
            lv_field = <lfs_tab_info_tmp>-fieldname.
          ELSE.
            SORT li_tab_info_tmp BY domname keyflag.
*&--Get fieldname from check table based on domain
            READ TABLE li_tab_info_tmp ASSIGNING <lfs_tab_info_tmp>
                                       WITH KEY domname = <lfs_tab_info>-domname
                                                keyflag = c_yes
                                       BINARY SEARCH.
            IF sy-subrc EQ 0.
              lv_field = <lfs_tab_info_tmp>-fieldname.
            ENDIF.
          ENDIF.

          IF lv_field IS NOT INITIAL.

            APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code of AT SELECTION SCREEN event
            CONCATENATE c_so
                        <lfs_t681e>-sefeld+0(6)
              INTO lv_selname.
            CONCATENATE 'AT SELECTION-SCREEN ON'
                        lv_selname
                        c_dot
              INTO lwa_code-line
              SEPARATED BY space.
            APPEND lwa_code TO fp_i_code.
            CLEAR lwa_code.

*&--Build code of IF statement
            CONCATENATE 'IF'
                        lv_selname
                        'IS NOT INITIAL'
                        c_dot
              INTO lwa_code-line
              SEPARATED BY space.
            APPEND lwa_code TO fp_i_code.
            CLEAR lwa_code.

*&--Build code of SLECT query
            CONCATENATE 'SELECT'
                        lv_field
                        'UP TO 1 ROWS'
              INTO lwa_code-line
              SEPARATED BY space.
            APPEND lwa_code TO fp_i_code.
            CLEAR lwa_code.

            CONCATENATE 'FROM'
                        <lfs_tab_info>-checktable
              INTO lwa_code-line
              SEPARATED BY space.
            APPEND lwa_code TO fp_i_code.
            CLEAR lwa_code.

            CONCATENATE c_gv
                        <lfs_t681e>-sefeld
              INTO lwa_code-line.
            CONDENSE lwa_code-line.
            CONCATENATE 'INTO'
                        lwa_code-line
              INTO lwa_code-line
              SEPARATED BY space.
            CONDENSE lwa_code-line.
            APPEND lwa_code TO fp_i_code.
            CLEAR lwa_code.

            CONCATENATE 'WHERE'
                        lv_field
                        'IN'
                        lv_selname
                        c_dot
              INTO lwa_code-line
              SEPARATED BY space.
            APPEND lwa_code TO fp_i_code.
            CLEAR lwa_code.

            lwa_code-line = 'ENDSELECT.'.
            APPEND lwa_code TO fp_i_code.
            CLEAR lwa_code.

            APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code of IF statement
            lwa_code-line = 'IF SY-SUBRC NE 0.'.
            APPEND lwa_code TO fp_i_code.
            CLEAR lwa_code.

*&--Build Code of Error Message Statement
            CONCATENATE 'MESSAGE'
                        'E128'
                        'WITH'
                        ''''
                        <lfs_tab_info>-scrtext_m
                        ''''
                        c_dot
              INTO lwa_code-line
              SEPARATED BY space.
            APPEND lwa_code TO fp_i_code.
            CLEAR lwa_code.

*&--Build Code of ENDIF statement
            lwa_code-line = 'ENDIF.'.
            APPEND lwa_code TO fp_i_code.
            CLEAR lwa_code.

*&--Build Code of ENDIF statement
            lwa_code-line = 'ENDIF.'.
            APPEND lwa_code TO fp_i_code.
            CLEAR lwa_code.

          ENDIF. "IF lv_field IS NOT INITIAL
        ENDIF.   " SY-subrc check of FM 'DDIF_FIELDINFO_GET'
      ENDIF.    "IF <lfs_tab_info>-checktable IS NOT INITIAL
    ENDIF.      "READ check on table li_tab_info

    CLEAR: li_tab_info_tmp,
           lv_field,
           lv_selname.

  ENDLOOP.      "LOOP on table li_t681e

*&--If sold-to or ship-to or customer field is present
  IF lv_kunag_flg IS NOT INITIAL OR
     lv_kunwe_flg IS NOT INITIAL OR
     lv_kunnr_flg IS NOT INITIAL.

*&--Build Code of AT SELECTION SCREEn event
    CONCATENATE 'AT SELECTION-SCREEN ON'
                c_p_kunn2
                c_dot
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build Code of IF statement
    CONCATENATE 'IF'
                c_p_kunn2
                'IS NOT INITIAL'
                c_dot
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    APPEND lwa_code TO fp_i_code. "Blank Line

*&--BOC for Defect#2056 on 06-Sep-2013

    SORT li_t681e BY SEFELD.

*&--Code to build append values of select option of sales org
    READ TABLE li_t681e ASSIGNING <lfs_t681e>
                           WITH KEY sefeld = c_vkorg
                           BINARY SEARCH.
    IF sy-subrc EQ 0.
      CONCATENATE c_so
                  <lfs_t681e>-sefeld+0(6)
        INTO lwa_code-line.
      CONCATENATE 'APPEND LINES OF'
                  lwa_code-line
                  'TO'
                  c_i_salesorg
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO FP_i_code. "Blank Line
    ENDIF.

*&--Code to build append values of select option of Distr Chnl
    READ TABLE li_t681e ASSIGNING <lfs_t681e>
                           WITH KEY sefeld = c_vtweg
                           BINARY SEARCH.
    IF sy-subrc EQ 0.

      CONCATENATE c_so
                  <lfs_t681e>-sefeld+0(6)
        INTO lwa_code-line.
      CONCATENATE 'APPEND LINES OF'
                  lwa_code-line
                  'TO'
                  c_i_salesdis
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line
    ENDIF.

*&--EOC for Defect#2056 on 06-Sep-2013

*&--Build Code to call FM
    CONCATENATE ''''
                'ZOTC_GET_CUSTOMER_SALES_REP'
                ''''
      INTO lwa_code-line.
    CONCATENATE 'CALL FUNCTION'
                lwa_code-line
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build Code of EXPORTING statements
    lwa_code-line = 'EXPORTING'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CONCATENATE 'IM_SALES_REP'
                c_equal
                c_p_kunn2
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    IF lv_kunag_flg IS NOT INITIAL OR
       lv_kunnr_flg IS NOT INITIAL.
      CONCATENATE ''''
                  c_sales_idn_01
                  ''''
        INTO lwa_code-line.
    ELSEIF lv_kunwe_flg IS NOT INITIAL.
      CONCATENATE ''''
                  c_sales_idn_02
                  ''''
        INTO lwa_code-line.
    ENDIF.

    CONCATENATE 'IM_SALES_IDN'
                c_equal
                lwa_code-line
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--BOC for Defect#2056 on 06-Sep-2013
*&--Passing Sales Org and Distr Chnl value to FM
    CONCATENATE 'IM_SALES_ORG'
                c_equal
                c_i_salesorg
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.

    CONCATENATE 'IM_SALES_DIS'
                c_equal
                c_i_salesdis
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.

*&--EOC for Defect#2056 on 06-Sep-2013

*&--Build Code of IMPORTING statement
    lwa_code-line = 'IMPORTING'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CONCATENATE 'EX_CUSTOMER'
                c_equal
                c_i_customer
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build Code of EXCEPTIONS statement
    lwa_code-line = 'EXCEPTIONS'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'INVALID_SALES_IDN = 1'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'INVALID_SALES_REP = 2'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'DATA_NOT_FOUND = 3'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'OTHERS = 4.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build Code of CASE statement on SY-SUBRC
    lwa_code-line = 'CASE SY-SUBRC.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'WHEN 0.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'WHEN 2.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build Code of Error Message
    CONCATENATE 'MESSAGE'
                'E128'
                'WITH'
                ''''
                'Sales Representative'(048)
                ''''
                c_dot
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'WHEN OTHERS.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build Code of Error Message
    CONCATENATE 'MESSAGE'
                'E131'
                'WITH'
                c_p_kunn2
                c_dot
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build Code of ENDCASE statement
    lwa_code-line = 'ENDCASE.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of ENDIF statement
    lwa_code-line = 'ENDIF.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Sort Info table based in dataelement
    SORT li_tab_info BY rollname.

*&--If Sold-to field is present
    IF lv_kunag_flg IS NOT INITIAL.
*&--Read Info table data for Sold-to field
      READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                             WITH KEY rollname = c_kunag
                             BINARY SEARCH.

*&--If Ship-to field is present
    ELSEIF lv_kunwe_flg IS NOT INITIAL.
*&--Read Info table data for Ship-to field
      READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                             WITH KEY rollname = c_kunwe
                             BINARY SEARCH.

*&--If Ship-to field is present
    ELSEIF lv_kunnr_flg IS NOT INITIAL.
*&--Read Info table data for Customer
      READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                             WITH KEY rollname = c_kunnr_v
                             BINARY SEARCH.
      IF sy-subrc NE 0.
*&--Read Info table data for Customer (Sold-to)
        READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                               WITH KEY rollname = c_kunnr
                               BINARY SEARCH.
      ENDIF.
    ENDIF.

*&--If field symbol is assigned
    IF sy-subrc EQ 0 AND
       <lfs_tab_info> IS ASSIGNED.

*&--Build Code of AT SELECTION SCREEN OUTPUT event
      lwa_code-line = 'AT SELECTION-SCREEN.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of IF statement
      CONCATENATE 'IF'
                  c_p_kunn2
                  'IS NOT INITIAL.'
                  INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code to assign value to GV_SALESFLG
      CONCATENATE ''''
                  c_yes
                  ''''
        INTO lwa_code-line.
      CONCATENATE c_gv_salesflg
                  c_equal
                  lwa_code-line
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CLEAR lv_selname.

*&--Build Code of REFRESH statement
      CONCATENATE c_so
                  <lfs_tab_info>-fieldname+0(6)
       INTO lv_selname.
      CONCATENATE 'REFRESH'
                  lv_selname
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of APPEND LINES OF statement
      CONCATENATE 'APPEND LINES OF'
                  c_i_customer
                  'TO'
                  lv_selname
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of MODIFY SCREEN statement
      lwa_code-line = 'MODIFY SCREEN.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of ENDIF statement
      lwa_code-line = 'ENDIF.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of IF P_KUNN2 IS INITIAL statement
      CONCATENATE 'IF'
                  c_p_kunn2
                  'IS INITIAL'
                  'AND'
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE c_gv_salesflg
                  'IS NOT INITIAL'
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of REFRESH statement
      CONCATENATE 'REFRESH'
                  lv_selname
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of CLEAR statement
      CONCATENATE 'CLEAR'
                  c_gv_salesflg
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of MODIFY SCREEN statement
      lwa_code-line = 'MODIFY SCREEN.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of ENDIF statement
      lwa_code-line = 'ENDIF.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

      lwa_code-line = 'AT SELECTION-SCREEN OUTPUT.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'IF'
                  c_p_kunn2
                  'IS NOT INITIAL'
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code to assign value to GV_SALESFLG
      CONCATENATE ''''
                  c_yes
                  ''''
        INTO lwa_code-line.
      CONCATENATE c_gv_salesflg
                  c_equal
                  lwa_code-line
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of LOOP At SCREEN statement
      lwa_code-line = 'LOOP AT SCREEN.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE ''''
                  lv_selname
                  c_hyphen
                  'LOW'
                  ''''
        INTO lwa_code-line.
      CONCATENATE 'IF'
                  'SCREEN-NAME'
                  'EQ'
                  lwa_code-line
                  'OR'
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE ''''
                  lv_selname
                  c_hyphen
                  'HIGH'
                  ''''
        INTO lwa_code-line.
      CONCATENATE 'SCREEN-NAME'
                  'EQ'
                  lwa_code-line
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE ''''
                  c_zero
                  ''''
        INTO lwa_code-line.
      CONCATENATE 'SCREEN-INPUT'
                  c_equal
                  lwa_code-line
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of MODIFY SCREEn statement
      lwa_code-line = 'MODIFY SCREEN.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of ENDIF statement
      lwa_code-line = 'ENDIF.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of ENDLOOP statement
      lwa_code-line = 'ENDLOOP.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      lwa_code-line = 'ENDIF.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

    ENDIF.

  ENDIF.

***********************************************************************
*--------Code for Start of Selection----------------------------------*
***********************************************************************
  APPEND lwa_code TO fp_i_code. "Blank Line
  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of START-OF-SELECTION statement
  lwa_code-line = 'START-OF-SELECTION.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code of IF statement
  CONCATENATE 'IF'
              c_p_kappl
              'IS INITIAL'
              'OR'
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE c_p_kschl
              'IS INITIAL'
              'OR'
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE c_p_kotab
              'IS INITIAL'
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Build Code of Error Message Statement
  CONCATENATE 'MESSAGE'
              'I133'
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'LEAVE PROGRAM.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'ENDIF.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of SELECT query on Access Sequence table
  CONCATENATE 'SELECT'
              c_star
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'FROM'
              fp_x_t681-kotab
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE c_i
              fp_x_t681-kotab
    INTO lwa_code-line.
  CONCATENATE 'INTO TABLE'
              lwa_code-line
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'WHERE'
              c_kappl
              'EQ'
              c_p_kappl
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'AND'
              c_kschl
              'EQ'
              c_p_kschl
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  LOOP AT li_sel_tab ASSIGNING <lfs_sel_tab>.
    CONCATENATE 'AND'
                <lfs_sel_tab>-field
                'IN'
                <lfs_sel_tab>-selname
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.
  ENDLOOP.

  CONCATENATE 'AND'
              c_datbi
              'IN'
              c_s_datbi
     INTO lwa_code-line
     SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'AND'
              c_datab
              'IN'
              c_s_datab
              c_dot
     INTO lwa_code-line
     SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of SY-SUBRC check
  lwa_code-line = 'IF SY-SUBRC EQ 0.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Copying data of access seq table to temporary table
  PERFORM f_get_table_copy_code USING fp_x_t681-kotab
                             CHANGING lwa_code.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Sort and Delete temporary access seq table based on KNUMH
  CONCATENATE c_i
              fp_x_t681-kotab
              c_uscore
              c_tmp
    INTO lv_ty_tab.
  CONCATENATE 'SORT'
              lv_ty_tab
              'BY'
              c_knumh
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'DELETE ADJACENT DUPLICATES FROM'
              lv_ty_tab
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'COMPARING'
              c_knumh
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of SELECT query of KONP table
  CONCATENATE 'SELECT'
              c_knumh
              c_kopos
              c_krech
              c_kbetr
              c_konwa
              c_kpein
              c_kmein
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'FROM'
              c_konp
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE c_i
              c_konp
    INTO lwa_code-line.
  CONCATENATE 'INTO TABLE'
              lwa_code-line
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'FOR ALL ENTRIES IN'
              lv_ty_tab
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE lv_ty_tab
              c_hyphen
              c_knumh
    INTO lwa_code-line.
  CONCATENATE 'WHERE'
              c_knumh
              'EQ'
              lwa_code-line
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'AND'
              c_kappl
              'EQ'
              c_p_kappl
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'AND'
              c_kschl
              'EQ'
              c_p_kschl
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'AND'
              c_loevm_ko
              'EQ'
              c_space
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of SY-SUBRC check
  lwa_code-line = 'IF SY-SUBRC EQ 0.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Build Code of SORT statement on KONP table
  CONCATENATE c_i
              c_konp
    INTO lwa_code-line.
  CONCATENATE 'SORT'
              lwa_code-line
              'BY'
              c_knumh
              c_kopos
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Build Code of ENDIF statement
  lwa_code-line = 'ENDIF.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of CLEAR statement
  CONCATENATE 'CLEAR'
              lv_ty_tab
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Sorting LI_TAB_INFO based on dataelement
  SORT li_tab_info BY rollname.

*&--If material is present in access seq
  IF lv_matnr_flg IS NOT INITIAL.

*&--Read info table for material
    READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                           WITH KEY rollname = c_matnr
                           BINARY SEARCH.

    IF sy-subrc EQ 0.

*&--Copying data of access seq table to temporary table
      PERFORM f_get_table_copy_code USING fp_x_t681-kotab
                                 CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Sort and Delete temporary access seq table based on MATNR
      CONCATENATE 'SORT'
                  lv_ty_tab
                  'BY'
                  <lfs_tab_info>-fieldname
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'DELETE ADJACENT DUPLICATES FROM'
                  lv_ty_tab
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'COMPARING'
                  <lfs_tab_info>-fieldname
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code of SELECT query on MAKT table
      CONCATENATE 'SELECT'
                  c_matnr
                  c_maktx
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'FROM'
                  c_makt
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE c_i
                  c_makt
        INTO lwa_code-line.
      CONCATENATE 'INTO TABLE'
                  lwa_code-line
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'FOR ALL ENTRIES IN'
                  lv_ty_tab
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE lv_ty_tab
                  c_hyphen
                  <lfs_tab_info>-fieldname
        INTO lwa_code-line.
      CONCATENATE 'WHERE'
                  c_matnr
                  'EQ'
                  lwa_code-line
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'AND'
                  c_spras
                  'EQ'
                  c_langu
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of SY-SUBRC check
      lwa_code-line = 'IF SY-SUBRC EQ 0.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of SORT statement on table MAKT
      CONCATENATE c_i
                  c_makt
        INTO lwa_code-line.
      CONCATENATE 'SORT'
                  lwa_code-line
                  'BY'
                  c_matnr
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of ENDIF statement
      lwa_code-line = 'ENDIF.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Clear temporary table.
      CONCATENATE 'CLEAR'
                  lv_ty_tab
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.
      APPEND lwa_code TO fp_i_code. "Blank Line

    ENDIF.

  ENDIF.

*&--If Customer Number/Sold-to/Ship-to field is present
  IF lv_kunag_flg IS NOT INITIAL OR
     lv_kunwe_flg IS NOT INITIAL OR
     lv_kunnr_flg IS NOT INITIAL.

*&--If Ship-to field is present
    IF lv_kunwe_flg IS NOT INITIAL.
*&--Read Info table for Shipt-to field
      READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                             WITH KEY rollname = c_kunwe
                             BINARY SEARCH.

*&--If Sold-to is present
    ELSEIF lv_kunag_flg IS NOT INITIAL.
*&--Read Info table for Sold-to field
      READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                             WITH KEY rollname = c_kunag
                             BINARY SEARCH.

*&--If Customer field is present
    ELSEIF lv_kunnr_flg IS NOT INITIAL.
*&--Read INfo table for Customer field
      READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                             WITH KEY rollname = c_kunnr_v
                             BINARY SEARCH.
      IF sy-subrc NE 0.
*&--Read Info table for Customer field
        READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                               WITH KEY rollname = c_kunnr
                               BINARY SEARCH.
      ENDIF.
    ENDIF.

*&--If field symbol is assigned
    IF sy-subrc EQ 0 AND
       <lfs_tab_info> IS ASSIGNED.

*&--Copying data of access seq table to temporary table
      PERFORM f_get_table_copy_code USING fp_x_t681-kotab
                                 CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Sort and delete temporary access seq table based on KUNNR/KUNAG/KUNWE
      CONCATENATE 'SORT'
                  lv_ty_tab
                  'BY'
                  <lfs_tab_info>-fieldname
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'DELETE ADJACENT DUPLICATES FROM'
                  lv_ty_tab
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'COMPARING'
                  <lfs_tab_info>-fieldname
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of SELECT query on KNA1 table
      CONCATENATE 'SELECT'
                  c_kunnr
                  c_name1
                  c_ort01
                  c_kukla
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'FROM'
                  c_kna1
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE c_i
                  c_kna1
        INTO lwa_code-line.
      CONCATENATE 'INTO TABLE'
                  lwa_code-line
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'FOR ALL ENTRIES IN'
                  lv_ty_tab
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE lv_ty_tab
                  c_hyphen
                  <lfs_tab_info>-fieldname
        INTO lwa_code-line.
      CONCATENATE 'WHERE'
                  c_kunnr
                  'EQ'
                  lwa_code-line
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Code to check sy-subrc
      lwa_code-line = 'IF SY-SUBRC EQ 0.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Code to Sort KNA1 table
      CONCATENATE c_i
                  c_kna1
        INTO lwa_code-line.
      CONCATENATE 'SORT'
                  lwa_code-line
                  'BY'
                  c_kunnr
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Copy KNA1 table data to its temporary table
      CLEAR lv_tab_nam.

      lv_tab_nam = c_kna1.

      PERFORM f_get_table_copy_code USING lv_tab_nam
                                 CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Code for Sort and Delete
      CLEAR lv_tab_nam.

      CONCATENATE c_i
                  c_kna1
                  c_uscore
                  c_tmp
        INTO lv_tab_nam.
      CONCATENATE 'SORT'
                  lv_tab_nam
                  'BY'
                  c_kukla
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'DELETE ADJACENT DUPLICATES FROM'
                  lv_tab_nam
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'COMPARING'
                  c_kukla
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code to SELECT query on TKUKT table
      CONCATENATE 'SELECT'
                  c_kukla
                  c_vtext
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'FROM'
                  c_tkukt
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE c_i
                  c_tkukt
        INTO lwa_code-line.
      CONCATENATE 'INTO TABLE'
                  lwa_code-line
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'FOR ALL ENTRIES IN'
                  lv_tab_nam
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'WHERE'
                  c_spras
                  'EQ'
                  c_langu
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE lv_tab_nam
                  c_hyphen
                  c_kukla
        INTO lwa_code-line.
      CONCATENATE 'AND'
                  c_kukla
                  'EQ'
                  lwa_code-line
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code for Sy-Subrc check
      lwa_code-line = 'IF SY-SUBRC EQ 0.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of SORT statment on TKUKT table
      CONCATENATE c_i
                  c_tkukt
        INTO lwa_code-line.
      CONCATENATE 'SORT'
                  lwa_code-line
                  'BY'
                  c_kukla
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of ENDIF statement
      lwa_code-line = 'ENDIF.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code for clearing data of temp table of KNA1
      CONCATENATE 'CLEAR'
                  lv_tab_nam
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of ENDIF statement
      lwa_code-line = 'ENDIF.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Code for clearing data from temp internal table of access seq
      CONCATENATE 'CLEAR'
                  lv_ty_tab
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Copying data of access seq table to temporary table
      PERFORM f_get_table_copy_code USING fp_x_t681-kotab
                                 CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Sort and Delete temporary access seq table based on KUNAG/KUNWE VKORG VTWEG
      CONCATENATE 'SORT'
                  lv_ty_tab
                  'BY'
                  <lfs_tab_info>-fieldname
                  c_vkorg
                  c_vtweg
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'DELETE ADJACENT DUPLICATES FROM'
                  lv_ty_tab
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'COMPARING'
                  <lfs_tab_info>-fieldname
                  c_vkorg
                  c_vtweg
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Bulid code of SELECT query on KNVV table
      CONCATENATE 'SELECT'
                  c_kunnr
                  c_vkorg
                  c_vtweg
                  c_kdgrp
                  c_kvgr1
                  c_kvgr2
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'FROM'
                  c_knvv
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE c_i
                  c_knvv
        INTO lwa_code-line.
      CONCATENATE 'INTO TABLE'
                  lwa_code-line
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'FOR ALL ENTRIES IN'
                  lv_ty_tab
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE lv_ty_tab
                  c_hyphen
                  <lfs_tab_info>-fieldname
        INTO lwa_code-line.
      CONCATENATE 'WHERE'
                  c_kunnr
                  'EQ'
                  lwa_code-line
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE lv_ty_tab
                  c_hyphen
                  c_vkorg
        INTO lwa_code-line.
      CONCATENATE 'AND'
                  c_vkorg
                  'EQ'
                  lwa_code-line
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE lv_ty_tab
                  c_hyphen
                  c_vtweg
        INTO lwa_code-line.
      CONCATENATE 'AND'
                  c_vtweg
                  'EQ'
                  lwa_code-line
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE ''''
                  lv_spart
                  ''''
        INTO lwa_code-line.
      CONCATENATE 'AND'
                  c_spart
                  'EQ'
                  lwa_code-line
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Sy-subrc check and sort the internal table
      lwa_code-line = 'IF SY-SUBRC EQ 0.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Sort KNVV table
      CONCATENATE c_i
                  c_knvv
        INTO lwa_code-line.
      CONCATENATE 'SORT'
                  lwa_code-line
                  'BY'
                  c_kunnr
                  c_vkorg
                  c_vtweg
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Copy KNVV table data to its temp table
      lv_tab_nam = c_knvv.
      PERFORM f_get_table_copy_code USING lv_tab_nam
                                 CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Populate temp internal table name of KNVV
      CLEAR lv_tab_nam.

      CONCATENATE c_i
                  c_knvv
                  c_uscore
                  c_tmp
        INTO lv_tab_nam.

*&--Building code to sort and delete based on KVGR1
      CONCATENATE 'SORT'
                  lv_tab_nam
                  'BY'
                  c_kvgr1
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'DELETE ADJACENT DUPLICATES FROM'
              lv_tab_nam
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'COMPARING'
                  c_kvgr1
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code of SELECT query for TVV1T
      CONCATENATE 'SELECT'
                  c_kvgr1
                  c_bezei
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'FROM'
                  c_tvv1t
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE c_i
                  c_tvv1t
        INTO lwa_code-line.
      CONCATENATE 'INTO TABLE'
                  lwa_code-line
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'FOR ALL ENTRIES IN'
                  lv_tab_nam
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'WHERE'
                  c_spras
                  'EQ'
                  c_langu
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE lv_tab_nam
                  c_hyphen
                  c_kvgr1
        INTO lwa_code-line.
      CONCATENATE 'AND'
                  c_kvgr1
                  'EQ'
                  lwa_code-line
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code for sy-subrc check and sort
      lwa_code-line = 'IF SY-SUBRC EQ 0.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of SORT statement on TVV1T table
      CONCATENATE c_i
                  c_tvv1t
        INTO lwa_code-line.
      CONCATENATE 'SORT'
                  lwa_code-line
                  'BY'
                  c_kvgr1
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of ENDIF statement
      lwa_code-line = 'ENDIF.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Code for Clearing Temp internal table
      CONCATENATE 'CLEAR'
                  lv_tab_nam
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Copy KNVV table data to its temp table
      CLEAR lv_tab_nam.
      lv_tab_nam = c_knvv.
      PERFORM f_get_table_copy_code USING lv_tab_nam
                                 CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Populate temp internal table name of KNVV
      CLEAR lv_tab_nam.

      CONCATENATE c_i
                  c_knvv
                  c_uscore
                  c_tmp
        INTO lv_tab_nam.

*&--Building code to sort and delete based on KVGR2
      CONCATENATE 'SORT'
                  lv_tab_nam
                  'BY'
                  c_kvgr2
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'DELETE ADJACENT DUPLICATES FROM'
              lv_tab_nam
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'COMPARING'
                  c_kvgr2
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code of SELECT query for TVV2T
      CONCATENATE 'SELECT'
                  c_kvgr2
                  c_bezei
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'FROM'
                  c_tvv2t
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE c_i
                  c_tvv2t
        INTO lwa_code-line.
      CONCATENATE 'INTO TABLE'
                  lwa_code-line
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'FOR ALL ENTRIES IN'
                  lv_tab_nam
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'WHERE'
                  c_spras
                  'EQ'
                  c_langu
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE lv_tab_nam
                  c_hyphen
                  c_kvgr2
        INTO lwa_code-line.
      CONCATENATE 'AND'
                  c_kvgr2
                  'EQ'
                  lwa_code-line
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code for sy-subrc check and sort
      lwa_code-line = 'IF SY-SUBRC EQ 0.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of SORT statement on TVV2T table
      CONCATENATE c_i
                  c_tvv2t
        INTO lwa_code-line.
      CONCATENATE 'SORT'
                  lwa_code-line
                  'BY'
                  c_kvgr2
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of ENDIF statement
      lwa_code-line = 'ENDIF.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Code for Clearing Temp internal table
      CONCATENATE 'CLEAR'
                  lv_tab_nam
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

      CLEAR lv_tab_nam.

*&--Copy KNVV data to temporary table
      lv_tab_nam = c_knvv.
      PERFORM f_get_table_copy_code USING lv_tab_nam
                                 CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Populate temp internal table name of KNVV
      CLEAR lv_tab_nam.

      CONCATENATE c_i
                  c_knvv
                  c_uscore
                  c_tmp
        INTO lv_tab_nam.

*&--Building code to sort and delete based on KDGRP
      CONCATENATE 'SORT'
                  lv_tab_nam
                  'BY'
                  c_kdgrp
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'DELETE ADJACENT DUPLICATES FROM'
              lv_tab_nam
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'COMPARING'
                  c_kdgrp
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Building select query for T151T
      CONCATENATE 'SELECT'
                  c_kdgrp
                  c_ktext
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'FROM'
                  c_t151t
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE c_i
                  c_t151t
        INTO lwa_code-line.
      CONCATENATE 'INTO TABLE'
                  lwa_code-line
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'FOR ALL ENTRIES IN'
                  lv_tab_nam
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'WHERE'
                  c_spras
                  'EQ'
                  c_langu
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE lv_tab_nam
                  c_hyphen
                  c_kdgrp
        INTO lwa_code-line.
      CONCATENATE 'AND'
                  c_kdgrp
                  'EQ'
                  lwa_code-line
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code for sy-subrc check and sort
      lwa_code-line = 'IF SY-SUBRC EQ 0.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of SORT statement
      CONCATENATE c_i
                  c_t151t
        INTO lwa_code-line.
      CONCATENATE 'SORT'
                  lwa_code-line
                  'BY'
                  c_kdgrp
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of ENDIF statement
      lwa_code-line = 'ENDIF.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Code for Clearing Temp internal table
      CONCATENATE 'CLEAR'
                  lv_tab_nam
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of ENDIF statement
      lwa_code-line = 'ENDIF.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Check if Sales Rep is entered
      CONCATENATE 'IF'
                  c_p_kunn2
                  'IS INITIAL'
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of SLECT query on KNVP table
      CONCATENATE 'SELECT'
                  c_kunnr
                  c_vkorg
                  c_vtweg
                  c_spart
                  c_parvw
                  c_parza
                  c_kunn2
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'FROM'
                  c_knvp
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE c_i
                  c_knvp
        INTO lwa_code-line.
      CONCATENATE 'INTO TABLE'
                  lwa_code-line
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'FOR ALL ENTRIES IN'
                  lv_ty_tab
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE lv_ty_tab
                  c_hyphen
                  <lfs_tab_info>-fieldname
        INTO lwa_code-line.
      CONCATENATE 'WHERE'
                  c_kunnr
                  'EQ'
                  lwa_code-line
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE lv_ty_tab
                  c_hyphen
                  c_vkorg
        INTO lwa_code-line.
      CONCATENATE 'AND'
                  c_vkorg
                  'EQ'
                  lwa_code-line
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE lv_ty_tab
                  c_hyphen
                  c_vtweg
        INTO lwa_code-line.
      CONCATENATE 'AND'
                  c_vtweg
                  'EQ'
                  lwa_code-line
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE ''''
                  lv_spart
                  ''''
        INTO lwa_code-line.
      CONCATENATE 'AND'
                  c_spart
                  'EQ'
                  lwa_code-line
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE ''''
                  lv_parvw_sr
                  ''''
        INTO lwa_code-line.
      CONCATENATE 'AND'
                  c_parvw
                  'EQ'
                  lwa_code-line
                  c_dot       " Added by SNIGAM : CR1302 : 3/25/2014
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

* BOC : SNIGAM : CR1302 : 3/25/2014
*      CONCATENATE ''''
*                  lv_parza
*                  ''''
*        INTO lwa_code-line.
*      CONCATENATE 'AND'
*                  c_parza
*                  'EQ'
*                  lwa_code-line
*                  c_dot
*        INTO lwa_code-line
*        SEPARATED BY space.
*      APPEND lwa_code TO fp_i_code.
*      CLEAR lwa_code.
* EOC : SNIGAM : CR1302 : 3/25/2014

*&--Build Code of SY-SUBRC check
      lwa_code-line = 'IF SY-SUBRC EQ 0.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of SORT statement
      CONCATENATE c_i
                  c_knvp
        INTO lwa_code-line.
      CONCATENATE 'SORT'
                  lwa_code-line
                  'BY'
                  c_kunnr
                  c_vkorg
                  c_vtweg
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Copy KNVP data to its temporary table
      lv_tab_nam = c_knvp.
      PERFORM f_get_table_copy_code USING lv_tab_nam
                                 CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Sort and Delete temporary table based on KUNN2
      CLEAR lv_tab_nam.

      CONCATENATE c_i
                  c_knvp
                  c_uscore
                  c_tmp
        INTO lv_tab_nam.
      CONCATENATE 'SORT'
                  lv_tab_nam
                  'BY'
                  c_kunn2
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'DELETE ADJACENT DUPLICATES FROM'
                  lv_tab_nam
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'COMPARING'
                  c_kunn2
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of ENDIF statement
      lwa_code-line = 'ENDIF.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of ELSE statement
      lwa_code-line = 'ELSE.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

      CONCATENATE c_wa
                  c_knvp
                  c_hyphen
                  c_kunn2
        INTO lwa_code-line.
      CONCATENATE lwa_code-line
                  c_equal
                  c_p_kunn2
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE c_wa
                  c_knvp
        INTO lwa_code-line.
      CONCATENATE 'APPEND'
                  lwa_code-line
                  'TO'
                  lv_tab_nam
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of ENDIF statement
      lwa_code-line = 'ENDIF.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Clear temporary table.
      CONCATENATE 'CLEAR'
                  lv_ty_tab
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank line

*&--Code to build select query to get sales rep names
      CONCATENATE lv_tab_nam
                  c_bracket
        INTO lwa_code-line.
      CONCATENATE 'IF'
                  lwa_code-line
                  'IS NOT INITIAL'
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of SELECT query on KNA1
      CONCATENATE 'SELECT'
                  c_kunnr
                  c_name1
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'FROM'
                  c_kna1
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE c_i
                  c_kna1
                  c_uscore
                  c_tmp
        INTO lwa_code-line.
      CONCATENATE 'INTO TABLE'
                  lwa_code-line
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE 'FOR ALL ENTRIES IN'
                  lv_tab_nam
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      CONCATENATE lv_tab_nam
                  c_hyphen
                  c_kunn2
        INTO lwa_code-line.
      CONCATENATE 'WHERE'
                  c_kunnr
                  'EQ'
                  lwa_code-line
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of SY-SUBRC check
      lwa_code-line = 'IF SY-SUBRC EQ 0.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of SORT statement on KNA1
      CONCATENATE c_i
                  c_kna1
                  c_uscore
                  c_tmp
        INTO lwa_code-line.
      CONCATENATE 'SORT'
                  lwa_code-line
                  'BY'
                  c_kunnr
                  c_dot
        INTO lwa_code-line
        SEPARATED BY space.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

*&--Build Code of ENDIF statement
      lwa_code-line = 'ENDIF.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of ENDIF statement
      lwa_code-line = 'ENDIF.'.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

      APPEND lwa_code TO fp_i_code. "Blank Line

    ENDIF.

*&--If customer grp1 or customer grp2 is present in access seq table
  ELSEIF lv_kvgr1_flg IS NOT INITIAL OR
         lv_kvgr2_flg IS NOT INITIAL.

*&--If customer grp1 is present in access seq table
    IF lv_kvgr1_flg IS NOT INITIAL.

*&--Read Info Table for Customer grp1
      READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                             WITH KEY rollname = c_kvgr1
                             BINARY SEARCH.
      IF sy-subrc EQ 0.

*&--copying data of access seq table to temporary table
        PERFORM f_get_table_copy_code USING fp_x_t681-kotab
                                   CHANGING lwa_code.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        APPEND lwa_code TO fp_i_code. "Blank Line

*&--Sort and delete temporary access seq table based on ZZKVGR1
        CONCATENATE 'SORT'
                    lv_ty_tab
                    'BY'
                    <lfs_tab_info>-fieldname
                    c_dot
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        CONCATENATE 'DELETE ADJACENT DUPLICATES FROM'
                    lv_ty_tab
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        CONCATENATE 'COMPARING'
                    <lfs_tab_info>-fieldname
                    c_dot
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build Code of SELECT query on TVV1T
        CONCATENATE 'SELECT'
                    c_kvgr1
                    c_bezei
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        CONCATENATE 'FROM'
                    c_tvv1t
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        CONCATENATE c_i
                    c_tvv1t
          INTO lwa_code-line.
        CONCATENATE 'INTO TABLE'
                    lwa_code-line
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        CONCATENATE 'FOR ALL ENTRIES IN'
                    lv_ty_tab
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        CONCATENATE 'WHERE'
                    c_spras
                    'EQ'
                    c_langu
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        CONCATENATE lv_ty_tab
                    c_hyphen
                    <lfs_tab_info>-fieldname
          INTO lwa_code-line.
        CONCATENATE 'AND'
                    c_kvgr1
                    'EQ'
                    lwa_code-line
                    c_dot
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        APPEND lwa_code TO fp_i_code. "Blank Line

*&--Code for SY-SUBRC Check
        lwa_code-line = 'IF SY-SUBRC EQ 0.'.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

*&--Build Code of SORT on TVV1T
        CONCATENATE c_i
                    c_tvv1t
          INTO lwa_code-line.
        CONCATENATE 'SORT'
                    lwa_code-line
                    'BY'
                    c_kvgr1
                    c_dot
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

*&--Build Code of ENDIF statement
        lwa_code-line = 'ENDIF.'.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        APPEND lwa_code TO fp_i_code. "Blank Line

*&--Code to clear temp data of access seq table
        CONCATENATE 'CLEAR'
                    lv_ty_tab
                    c_dot
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        APPEND lwa_code TO fp_i_code. "Blank Line

      ENDIF.

*&--If customer group2 field is  present
    ELSEIF lv_kvgr2_flg IS NOT INITIAL.

*&--Read Info table for customer grp2 field
      READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                             WITH KEY rollname = c_kvgr2
                             BINARY SEARCH.
      IF sy-subrc EQ 0.

*&--copying data of access seq table to temporary table
        PERFORM f_get_table_copy_code USING fp_x_t681-kotab
                                   CHANGING lwa_code.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

*&--Blank Line
        APPEND lwa_code TO fp_i_code.

*&--Sort and delete temporary access seq table based on ZZKVGR2
        CONCATENATE 'SORT'
                    lv_ty_tab
                    'BY'
                    <lfs_tab_info>-fieldname
                    c_dot
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        CONCATENATE 'DELETE ADJACENT DUPLICATES FROM'
                    lv_ty_tab
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        CONCATENATE 'COMPARING'
                    <lfs_tab_info>-fieldname
                    c_dot
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        APPEND lwa_code TO fp_i_code. "Blank Line

*&--Building select query for table TVV2T
        CONCATENATE 'SELECT'
                    c_kvgr2
                    c_bezei
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        CONCATENATE 'FROM'
                    c_tvv2t
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        CONCATENATE c_i
                    c_tvv2t
          INTO lwa_code-line.
        CONCATENATE 'INTO TABLE'
                    lwa_code-line
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        CONCATENATE 'FOR ALL ENTRIES IN'
                    lv_ty_tab
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        CONCATENATE 'WHERE'
                    c_spras
                    'EQ'
                    c_langu
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        CONCATENATE lv_ty_tab
                    c_hyphen
                    <lfs_tab_info>-fieldname
          INTO lwa_code-line.
        CONCATENATE 'AND'
                    c_kvgr2
                    'EQ'
                    lwa_code-line
                    c_dot
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        APPEND lwa_code TO fp_i_code. "Blank Line

*&--Code for SY-SUBRC Check
        lwa_code-line = 'IF SY-SUBRC EQ 0.'.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

*&--Build Code of SORT statement
        CONCATENATE c_i
                    c_tvv2t
          INTO lwa_code-line.
        CONCATENATE 'SORT'
                    lwa_code-line
                    'BY'
                    c_kvgr2
                    c_dot
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

*&--Build Code of ENDIF statement
        lwa_code-line = 'ENDIF.'.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        APPEND lwa_code TO fp_i_code. "Blank Line

*&--Code to clear temp data of access seq table
        CONCATENATE 'CLEAR'
                    lv_ty_tab
                    c_dot
          INTO lwa_code-line
          SEPARATED BY space.
        APPEND lwa_code TO fp_i_code.
        CLEAR lwa_code.

        APPEND lwa_code TO fp_i_code. "Blank Line

      ENDIF.

    ENDIF.

  ENDIF.

*&--Build Code of ENDIF statement
  lwa_code-line = 'ENDIF.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line
  APPEND lwa_code TO fp_i_code. "Blank Line

***********************************************************************
*--------Code for End of Selection------------------------------------*
***********************************************************************
  lwa_code-line = 'END-OF-SELECTION.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

  CLEAR: lv_ty_tab,
         lv_tab_nam.

*&--Build Code of LOOP statement on Access Seq table
  CONCATENATE c_wa
              fp_x_t681-kotab
    INTO lv_ty_tab.
  CONCATENATE c_i
              fp_x_t681-kotab
    INTO lwa_code-line.
  CONCATENATE 'LOOP AT'
              lwa_code-line
              'INTO'
              lv_ty_tab
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Populating KSCHL of final workarea
  CONCATENATE c_wa_final
              c_hyphen
              c_kschl
    INTO lwa_code-line.
  CONCATENATE lwa_code-line
              c_equal
              c_p_kschl
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Populating KAPPL of final workarea
  CONCATENATE c_wa_final
              c_hyphen
              c_kappl
    INTO lwa_code-line.
  CONCATENATE lwa_code-line
              c_equal
              c_p_kappl
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Populating KOTAB of final workarea
  CONCATENATE c_wa_final
              c_hyphen
              c_kotab
    INTO lwa_code-line.
  CONCATENATE lwa_code-line
              c_equal
              c_p_kotab
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Sort Info table based in data element
  SORT li_tab_info BY rollname.

*&--Read Info table for Sales Org
  READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                         WITH KEY rollname = c_vkorg
                         BINARY SEARCH.
  IF sy-subrc EQ 0.
*&--Populating VKORG of final workarea
    PERFORM f_get_final_wa_code USING fp_x_t681-kotab
                                      <lfs_tab_info>-fieldname
                                      c_vkorg
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.
  ENDIF.

*&--Read Info table for Distribution Channel
  READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                         WITH KEY rollname = c_vtweg
                         BINARY SEARCH.
  IF sy-subrc EQ 0.
*&--Populating VTWEG of final workarea
    PERFORM f_get_final_wa_code USING fp_x_t681-kotab
                                      <lfs_tab_info>-fieldname
                                      c_vtweg
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.
  ENDIF.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Read Info table for Valid From field
  READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                         WITH KEY rollname = c_kodatab
                         BINARY SEARCH.
  IF sy-subrc EQ 0.
*&--Populating DATAB of final workarea
    PERFORM f_get_date_code USING fp_x_t681-kotab
                                  <lfs_tab_info>-fieldname
                                  c_datab
                         CHANGING fp_i_code.
  ELSE.
*&--Populating DATAB of final workarea
    PERFORM f_get_date_code USING fp_x_t681-kotab
                                  c_datab
                                  c_datab
                         CHANGING fp_i_code.
  ENDIF.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Read Info table for Valid To field
  READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                         WITH KEY rollname = c_kodatbi
                         BINARY SEARCH.
  IF sy-subrc EQ 0.
*&--Populating DATBI of final workarea
    PERFORM f_get_date_code USING fp_x_t681-kotab
                                  <lfs_tab_info>-fieldname
                                  c_datbi
                         CHANGING fp_i_code.
  ELSE.
*&--Populating DATBI of final workarea
    PERFORM f_get_date_code USING fp_x_t681-kotab
                                  c_datbi
                                  c_datbi
                         CHANGING fp_i_code.
  ENDIF.

  CLEAR lv_field.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--If Customer field is present
  IF lv_kunnr_flg IS NOT INITIAL.
*&--Read Info table for Customer field
    READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                           WITH KEY rollname = c_kunnr_v
                           BINARY SEARCH.
    IF sy-subrc NE 0.
*&--Read Info table for Customer field
      READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                             WITH KEY rollname = c_kunnr
                             BINARY SEARCH.
    ENDIF.

    IF sy-subrc EQ 0 AND
       <lfs_tab_info> IS ASSIGNED.
*&--Populating KUNNR of final workarea
      PERFORM f_get_final_wa_code USING fp_x_t681-kotab
                                        <lfs_tab_info>-fieldname
                                        c_fld1
                               CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.
      lv_field = <lfs_tab_info>-fieldname.
    ELSE.
*&--Populating KUNNR of final workarea
      PERFORM f_get_final_wa_code USING fp_x_t681-kotab
                                        c_kunnr
                                        c_fld1
                               CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.
      lv_field = c_kunnr.
    ENDIF.

*&--If Sold-to field is present
  ELSEIF lv_kunag_flg IS NOT INITIAL.
*&--Read INfo table for Sold-to field
    READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                           WITH KEY rollname = c_kunag
                           BINARY SEARCH.
    IF sy-subrc EQ 0.
*&--Populating KUNAG of final workarea
      PERFORM f_get_final_wa_code USING fp_x_t681-kotab
                                        <lfs_tab_info>-fieldname
                                        c_fld1
                               CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.
      lv_field = <lfs_tab_info>-fieldname.
    ELSE.
*&--Populating KUNAG of final workarea
      PERFORM f_get_final_wa_code USING fp_x_t681-kotab
                                        c_kunag
                                        c_fld1
                               CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.
      lv_field = c_kunag.
    ENDIF.

*&--If Ship-to field is present
  ELSEIF lv_kunwe_flg IS NOT INITIAL.
*&--Read Info table for Ship-to field
    READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                           WITH KEY rollname = c_kunwe
                           BINARY SEARCH.
    IF sy-subrc EQ 0.
*&--Populating KUNWE of final workarea
      PERFORM f_get_final_wa_code USING fp_x_t681-kotab
                                        <lfs_tab_info>-fieldname
                                        c_fld1
                               CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.
      lv_field = <lfs_tab_info>-fieldname.
    ELSE.
*&--Populating KUNWE of final workarea
      PERFORM f_get_final_wa_code USING fp_x_t681-kotab
                                        c_kunwe
                                        c_fld1
                               CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.
      lv_field = c_kunwe.
    ENDIF.

*&--If Customer grp1 field is present
  ELSEIF lv_kvgr1_flg IS NOT INITIAL.
*&--Read Info table for customer grp1 field
    READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                           WITH KEY rollname = c_kvgr1
                           BINARY SEARCH.
    IF sy-subrc EQ 0.
*&--Populating KVGR1 of final workarea
      PERFORM f_get_final_wa_code USING fp_x_t681-kotab
                                        <lfs_tab_info>-fieldname
                                        c_fld1
                               CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.
      lv_field = <lfs_tab_info>-fieldname.
    ELSE.
*&--Populating KVGR1 of final workarea
      PERFORM f_get_final_wa_code USING fp_x_t681-kotab
                                        c_zzkvgr1
                                        c_fld1
                               CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.
      lv_field = c_zzkvgr1.
    ENDIF.

*&--If customer grp2 field is present
  ELSEIF lv_kvgr2_flg IS NOT INITIAL.
*&--Read INfo table for customer grp2 field
    READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                           WITH KEY rollname = c_kvgr2
                           BINARY SEARCH.
    IF sy-subrc EQ 0.
*&--Populating KVGR2 of final workarea
      PERFORM f_get_final_wa_code USING fp_x_t681-kotab
                                        <lfs_tab_info>-fieldname
                                        c_fld1
                               CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.
      lv_field = <lfs_tab_info>-fieldname.
    ELSE.
*&--Populating KVGR2 of final workarea
      PERFORM f_get_final_wa_code USING fp_x_t681-kotab
                                        c_zzkvgr2
                                        c_fld1
                               CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.
      lv_field = c_zzkvgr2.
    ENDIF.

*&--If material field is present
  ELSEIF lv_matnr_flg IS NOT INITIAL.
*&--Read INfo table for material field
    READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                           WITH KEY rollname = c_matnr
                           BINARY SEARCH.
    IF sy-subrc EQ 0.
*&--Populating MATNR of final workarea
      PERFORM f_get_final_wa_code USING fp_x_t681-kotab
                                        <lfs_tab_info>-fieldname
                                        c_fld1
                               CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.
      lv_field = <lfs_tab_info>-fieldname.
    ELSE.
*&--Populating MATNR of final workarea
      PERFORM f_get_final_wa_code USING fp_x_t681-kotab
                                        c_matnr
                                        c_fld1
                               CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.
      lv_field = c_matnr.
    ENDIF.

  ENDIF.

  APPEND lwa_code TO fp_i_code. "Blank Line

  CLEAR: lv_ty_tab,
         lv_tab_nam.

*&--If customer grp1 field is present
  IF lv_kvgr1_flg IS NOT INITIAL.

*&--Build code for READ statement on TVV1T table
    CONCATENATE c_wa
                c_tvv1t
      INTO lv_ty_tab.
    CONCATENATE c_i
                c_tvv1t
      INTO lwa_code-line.
    CONCATENATE 'READ TABLE'
                lwa_code-line
                'INTO'
                lv_ty_tab
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CONCATENATE c_wa
                fp_x_t681-kotab
                c_hyphen
                lv_field
      INTO lwa_code-line.
    CONCATENATE 'WITH KEY'
                c_kvgr1
                c_equal
                lwa_code-line
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'BINARY SEARCH.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build Code for SY-SUBRC check
    lwa_code-line = 'IF SY-SUBRC EQ 0.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Populating FLD1_NAME of final workarea
    CONCATENATE c_fld1
                c_name
      INTO lv_tab_nam.
    PERFORM f_get_final_wa_code USING c_tvv1t
                                      c_bezei
                                      lv_tab_nam
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build code for ENDIF statement
    lwa_code-line = 'ENDIF.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    APPEND lwa_code TO fp_i_code. "Blank Line

*&--If customer grp2 is present
  ELSEIF lv_kvgr2_flg IS NOT INITIAL.

*&--Build code for READ statement on table TVV2T
    CONCATENATE c_wa
                c_tvv2t
      INTO lv_ty_tab.
    CONCATENATE c_i
                c_tvv2t
      INTO lwa_code-line.
    CONCATENATE 'READ TABLE'
                lwa_code-line
                'INTO'
                lv_ty_tab
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CONCATENATE c_wa
                fp_x_t681-kotab
                c_hyphen
                lv_field
      INTO lwa_code-line.
    CONCATENATE 'WITH KEY'
                c_kvgr2
                c_equal
                lwa_code-line
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'BINARY SEARCH.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build code for SY-SUBRC check
    lwa_code-line = 'IF SY-SUBRC EQ 0.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Populating fld1_NAME of final workarea
    CONCATENATE c_fld1
                c_name
      INTO lv_tab_nam.
    PERFORM f_get_final_wa_code USING c_tvv2t
                                      c_bezei
                                      lv_tab_nam
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build code for ENDIF statement
    lwa_code-line = 'ENDIF.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    APPEND lwa_code TO fp_i_code. "Blank Line

  ENDIF.

*&--If customer or ship-to or sold-to field is present
  IF lv_kunnr_flg IS NOT INITIAL OR
     lv_kunag_flg IS NOT INITIAL OR
     lv_kunwe_flg IS NOT INITIAL.

*&--Build code for READ statement on KNA1 table
    CONCATENATE c_wa
                c_kna1
      INTO lv_ty_tab.
    CONCATENATE c_i
                c_kna1
      INTO lwa_code-line.
    CONCATENATE 'READ TABLE'
                lwa_code-line
                'INTO'
                lv_ty_tab
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CONCATENATE c_wa
                fp_x_t681-kotab
                c_hyphen
                lv_field
      INTO lwa_code-line.
    CONCATENATE 'WITH KEY'
                c_kunnr
                c_equal
                lwa_code-line
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'BINARY SEARCH.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build code for SY-SUBRC check
    lwa_code-line = 'IF SY-SUBRC EQ 0.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Populating KUNNR_NAME/KUNAG_NAME/KUNWE_NAME of final workarea
    CONCATENATE c_fld1
                c_name
      INTO lv_tab_nam.
    PERFORM f_get_final_wa_code USING c_kna1
                                      c_name1
                                      lv_tab_nam
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Populating ORT01 of final workarea
    PERFORM f_get_final_wa_code USING c_kna1
                                      c_ort01
                                      c_ort01
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Populating KUKLA of final workarea
    PERFORM f_get_final_wa_code USING c_kna1
                                      c_kukla
                                      c_kukla
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CLEAR: lv_ty_tab,
           lv_tab_nam.

    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code for READ statement on TKUKT table
    CONCATENATE c_wa
                c_tkukt
      INTO lv_ty_tab.
    CONCATENATE c_i
                c_tkukt
      INTO lwa_code-line.
    CONCATENATE 'READ TABLE'
                lwa_code-line
                'INTO'
                lv_ty_tab
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CONCATENATE c_wa
                c_kna1
                c_hyphen
                c_kukla
      INTO lwa_code-line.
    CONCATENATE 'WITH KEY'
                c_kukla
                c_equal
                lwa_code-line
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'BINARY SEARCH.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build Code for SY-SUBRC check
    lwa_code-line = 'IF SY-SUBRC EQ 0.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Populating KUKLA_NAME of final workarea
    CONCATENATE c_kukla
                c_name
      INTO lv_tab_nam.
    PERFORM f_get_final_wa_code USING c_tkukt
                                      c_vtext
                                      lv_tab_nam
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build code for ENDIF statement
    lwa_code-line = 'ENDIF.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build code for ENDIF statement
    lwa_code-line = 'ENDIF.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CLEAR: lv_field,
           lv_ty_tab,
           lv_tab_nam.

  ENDIF.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--If material field is present
  IF lv_matnr_flg IS NOT INITIAL.
*&--Read Info table for material field
    READ TABLE li_tab_info ASSIGNING <lfs_tab_info>
                           WITH KEY rollname = c_matnr
                           BINARY SEARCH.
    IF sy-subrc EQ 0.
*&--Populating MATNR of final workarea
      PERFORM f_get_final_wa_code USING fp_x_t681-kotab
                                        <lfs_tab_info>-fieldname
                                        c_matnr
                               CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.
      lv_field = <lfs_tab_info>-fieldname.
    ELSE.
*&--Populating MATNR of final workarea
      PERFORM f_get_final_wa_code USING fp_x_t681-kotab
                                        c_matnr
                                        c_matnr
                               CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.
      lv_field = c_matnr.
    ENDIF.

    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code for READ statement on MAKT table
    CONCATENATE c_wa
                c_makt
      INTO lv_ty_tab.
    CONCATENATE c_i
                c_makt
      INTO lwa_code-line.
    CONCATENATE 'READ TABLE'
                lwa_code-line
                'INTO'
                lv_ty_tab
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CONCATENATE c_wa
                fp_x_t681-kotab
                c_hyphen
                lv_field
      INTO lwa_code-line.
    CONCATENATE 'WITH KEY'
                c_matnr
                c_equal
                lwa_code-line
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'BINARY SEARCH.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build code for SY-SUBRC check
    lwa_code-line = 'IF SY-SUBRC EQ 0.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Populating MATNR_NAME of final workarea
    CONCATENATE c_matnr
                c_name
      INTO lv_tab_nam.
    PERFORM f_get_final_wa_code USING c_makt
                                      c_maktx
                                      lv_tab_nam
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    IF lv_kunnr_flg IS INITIAL AND
       lv_kunag_flg IS INITIAL AND
       lv_kunwe_flg IS INITIAL AND
       lv_kvgr1_flg IS INITIAL AND
       lv_kvgr2_flg IS INITIAL AND
       lv_matnr_flg IS NOT INITIAL.

*&--Populating MATNR_NAME of final workarea
      CONCATENATE c_fld1
                  c_name
        INTO lv_tab_nam.
      PERFORM f_get_final_wa_code USING c_makt
                                        c_maktx
                                        lv_tab_nam
                               CHANGING lwa_code.
      APPEND lwa_code TO fp_i_code.
      CLEAR lwa_code.

    ENDIF.

*&--Build code for ENDIF statement
    lwa_code-line = 'ENDIF.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CLEAR: lv_field,
           lv_ty_tab,
           lv_tab_nam.

    APPEND lwa_code TO fp_i_code. "Blank Line
  ENDIF.

*&--If Ship-to or Sold-to field is present in access seq table
  IF lv_kunag_flg IS NOT INITIAL OR
     lv_kunwe_flg IS NOT INITIAL OR
     lv_kunnr_flg IS NOT INITIAL.

*&--Build code for READ statement on table KNVV
    CONCATENATE c_wa
                c_knvv
      INTO lv_ty_tab.
    CONCATENATE c_i
                c_knvv
      INTO lwa_code-line.
    CONCATENATE 'READ TABLE'
                lwa_code-line
                'INTO'
                lv_ty_tab
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CONCATENATE c_wa_final
                c_hyphen
                c_fld1
      INTO lwa_code-line.
    CONCATENATE 'WITH KEY'
                c_kunnr
                c_equal
                lwa_code-line
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CONCATENATE c_wa_final
                c_hyphen
                c_vkorg
      INTO lwa_code-line.
    CONCATENATE c_vkorg
                c_equal
                lwa_code-line
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CONCATENATE c_wa_final
                c_hyphen
                c_vtweg
      INTO lwa_code-line.
    CONCATENATE c_vtweg
                c_equal
                lwa_code-line
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'BINARY SEARCH.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build code for SY-SUBRC check
    lwa_code-line = 'IF SY-SUBRC EQ 0.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Populating KVGR1 of final workarea
    PERFORM f_get_final_wa_code USING c_knvv
                                      c_kvgr1
                                      c_kvgr1
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Populating KVGR2 of final workarea
    PERFORM f_get_final_wa_code USING c_knvv
                                      c_kvgr2
                                      c_kvgr2
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Populating KDGRP of final workarea
    PERFORM f_get_final_wa_code USING c_knvv
                                      c_kdgrp
                                      c_kdgrp
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CLEAR lv_ty_tab.

    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code for READ statement on table TVV1T
    CONCATENATE c_wa
                c_tvv1t
      INTO lv_ty_tab.
    CONCATENATE c_i
                c_tvv1t
      INTO lwa_code-line.
    CONCATENATE 'READ TABLE'
                lwa_code-line
                'INTO'
                lv_ty_tab
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CONCATENATE c_wa
                c_knvv
                c_hyphen
                c_kvgr1
      INTO lwa_code-line.
    CONCATENATE 'WITH KEY'
                c_kvgr1
                c_equal
                lwa_code-line
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'BINARY SEARCH.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build code for Sy-SUBRC check
    lwa_code-line = 'IF SY-SUBRC EQ 0.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Populating KVGR1_NAME of final workarea
    CONCATENATE c_kvgr1
                c_name
      INTO lv_tab_nam.
    PERFORM f_get_final_wa_code USING c_tvv1t
                                      c_bezei
                                      lv_tab_nam
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build Code for ENDIF statement
    lwa_code-line = 'ENDIF.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CLEAR: lv_ty_tab,
           lv_tab_nam.

    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code for READ statement on TVV2T table
    CONCATENATE c_wa
                c_tvv2t
      INTO lv_ty_tab.
    CONCATENATE c_i
                c_tvv2t
      INTO lwa_code-line.
    CONCATENATE 'READ TABLE'
                lwa_code-line
                'INTO'
                lv_ty_tab
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CONCATENATE c_wa
                c_knvv
                c_hyphen
                c_kvgr2
      INTO lwa_code-line.
    CONCATENATE 'WITH KEY'
                c_kvgr2
                c_equal
                lwa_code-line
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'BINARY SEARCH.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'IF SY-SUBRC EQ 0.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Populating KVGR2_NAME of final workarea
    CONCATENATE c_kvgr2
                c_name
      INTO lv_tab_nam.
    PERFORM f_get_final_wa_code USING c_tvv2t
                                      c_bezei
                                      lv_tab_nam
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'ENDIF.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CLEAR: lv_ty_tab,
           lv_tab_nam.

    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code for READ statement on T151T table
    CONCATENATE c_wa
                c_t151t
      INTO lv_ty_tab.
    CONCATENATE c_i
                c_t151t
      INTO lwa_code-line.
    CONCATENATE 'READ TABLE'
                lwa_code-line
                'INTO'
                lv_ty_tab
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CONCATENATE c_wa
                c_knvv
                c_hyphen
                c_kdgrp
      INTO lwa_code-line.
    CONCATENATE 'WITH KEY'
                c_kdgrp
                c_equal
                lwa_code-line
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'BINARY SEARCH.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'IF SY-SUBRC EQ 0.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Populating KDGRP_NAME of final workarea
    CONCATENATE c_kdgrp
                c_name
      INTO lv_tab_nam.
    PERFORM f_get_final_wa_code USING c_t151t
                                      c_ktext
                                      lv_tab_nam
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'ENDIF.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'ENDIF.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code for IF statement on P_KUNN2 field
    CONCATENATE 'IF'
                c_p_kunn2
                'IS NOT INITIAL'
                c_dot
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Populating KUNN2 of final workarea
    CONCATENATE c_wa_final
                c_hyphen
                c_kunn2
      INTO lwa_code-line.
    CONCATENATE lwa_code-line
                c_equal
                c_p_kunn2
                c_dot
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build code for ELSE statement
    lwa_code-line = 'ELSE.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CLEAR: lv_ty_tab,
           lv_tab_nam.

*&--Build code for READ statment on KNVP table
    CONCATENATE c_wa
                c_knvp
      INTO lv_ty_tab.
    CONCATENATE c_i
                c_knvp
      INTO lwa_code-line.
    CONCATENATE 'READ TABLE'
                lwa_code-line
                'INTO'
                lv_ty_tab
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CONCATENATE c_wa_final
                c_hyphen
                c_fld1
      INTO lwa_code-line.
    CONCATENATE 'WITH KEY'
                c_kunnr
                c_equal
                lwa_code-line
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CONCATENATE c_wa_final
                c_hyphen
                c_vkorg
      INTO lwa_code-line.
    CONCATENATE c_vkorg
                c_equal
                lwa_code-line
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CONCATENATE c_wa_final
                c_hyphen
                c_vtweg
      INTO lwa_code-line.
    CONCATENATE c_vtweg
                c_equal
                lwa_code-line
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'BINARY SEARCH.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'IF SY-SUBRC EQ 0.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Populating KUNN2 of final workarea
    PERFORM f_get_final_wa_code USING c_knvp
                                      c_kunn2
                                      c_kunn2
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'ENDIF.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'ENDIF.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code for IF statement on WA_FINAL-KUNN2
    CONCATENATE c_wa_final
                c_hyphen
                c_kunn2
      INTO lwa_code-line.
    CONCATENATE 'IF'
                lwa_code-line
                'IS NOT INITIAL'
                c_dot
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build code for CLEAR statement on WA_KNA1
    CONCATENATE c_wa
                c_kna1
      INTO lwa_code-line.
    CONCATENATE 'CLEAR'
                lwa_code-line
                c_dot
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CLEAR: lv_ty_tab,
           lv_tab_nam.

    APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code for READ statement on temp tbale of KNA1
    CONCATENATE c_wa
                c_kna1
      INTO lv_ty_tab.

    CONCATENATE c_i
                c_kna1
                c_uscore
                c_tmp
      INTO lwa_code-line.
    CONCATENATE 'READ TABLE'
                lwa_code-line
                'INTO'
                lv_ty_tab
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CONCATENATE c_wa_final
                c_hyphen
                c_kunn2
      INTO lwa_code-line.
    CONCATENATE 'WITH KEY'
                c_kunnr
                c_equal
                lwa_code-line
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'BINARY SEARCH.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'IF SY-SUBRC EQ 0.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Populating KUNN2_NAME of final workarea
    CONCATENATE c_kunn2
                c_name
      INTO lv_tab_nam.
    PERFORM f_get_final_wa_code USING c_kna1
                                      c_name1
                                      lv_tab_nam
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'ENDIF.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    lwa_code-line = 'ENDIF.'.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    APPEND lwa_code TO fp_i_code. "Blank Line

  ENDIF.

  CLEAR: lv_ty_tab,
         lv_tab_nam.

*&--Build code for READ statement on table KONP
  CONCATENATE c_wa
              c_konp
    INTO lv_ty_tab.
  CONCATENATE c_i
              c_konp
    INTO lwa_code-line.
  CONCATENATE 'READ TABLE'
              lwa_code-line
              'INTO'
              lv_ty_tab
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE c_wa
              fp_x_t681-kotab
              c_hyphen
              c_knumh
    INTO lwa_code-line.
  CONCATENATE 'WITH KEY'
              c_knumh
              c_equal
              lwa_code-line
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'BINARY SEARCH.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'IF SY-SUBRC EQ 0.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Build code to assign index variable with SY-TABIX value
  CONCATENATE c_gv_index
              c_equal
              c_sy_tabix
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Build code for CLEAR statement
  CONCATENATE 'CLEAR'
              lv_ty_tab
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code for LOOP statement on KONP table using parallel cursor method
  CONCATENATE c_i
              c_konp
    INTO lwa_code-line.
  CONCATENATE 'LOOP AT'
              lwa_code-line
              'INTO'
              lv_ty_tab
              'FROM'
              c_gv_index
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Build code for EXIT command if condition of KNUMH is not met
  CONCATENATE lv_ty_tab
              c_hyphen
              c_knumh
    INTO lv_ty_tab.
  CONCATENATE c_wa
              fp_x_t681-kotab
              c_hyphen
              c_knumh
    INTO lwa_code-line.
  CONCATENATE 'IF'
              lv_ty_tab
              'NE'
              lwa_code-line
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'CLEAR'
              c_gv_index
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'EXIT.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'ENDIF.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Populating KBETR of final workarea
  PERFORM f_get_final_wa_code USING c_konp
                                    c_kbetr
                                    c_kbetr
                           CHANGING lwa_code.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Build code to calculate if calculation type field is percentage
  CONCATENATE c_wa
              c_konp
              c_hyphen
              c_krech
    INTO lwa_code-line.
  CONCATENATE 'IF'
              lwa_code-line
              c_equal
              c_krech_a
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Formula build
*&--WA_FINAL-KBETR = WA_FINAL-KBETR / 10 .
  CONCATENATE c_wa_final
              c_hyphen
              c_kbetr
    INTO lwa_code-line.
  CONCATENATE lwa_code-line
              c_equal
              lwa_code-line
              c_fslash
              c_ten
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'ENDIF.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Populating KONWA of final workarea
  PERFORM f_get_final_wa_code USING c_konp
                                    c_konwa
                                    c_konwa
                           CHANGING lwa_code.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Populating KPEIN of final workarea
  PERFORM f_get_final_wa_code USING c_konp
                                    c_kpein
                                    c_kpein
                           CHANGING lwa_code.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Populating KMEIN of final workarea
  PERFORM f_get_final_wa_code USING c_konp
                                    c_kmein
                                    c_kmein
                           CHANGING lwa_code.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Building code to assign value in variable GV_NAME
  CLEAR lv_ty_tab.

  CONCATENATE c_wa
              c_konp
              c_hyphen
              c_knumh
    INTO lv_ty_tab.
  CONCATENATE ''''
              c_text_proc
              ''''
    INTO lwa_code-line.
  CONCATENATE 'CONCATENATE'
              lv_ty_tab
              lwa_code-line
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'INTO'
              c_gv_name
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'CONDENSE'
              c_gv_name
              'NO-GAPS'
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code to call FM 'READ_TEXT'
  CONCATENATE ''''
              'READ_TEXT'
              ''''
    INTO lwa_code-line.
  CONCATENATE 'CALL FUNCTION'
              lwa_code-line
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'EXPORTING'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE ''''
              c_tdid_0001
              ''''
    INTO lwa_code-line.
  CONCATENATE 'ID'
              c_equal
              lwa_code-line
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'LANGUAGE'
              c_equal
              c_langu
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'NAME'
              c_equal
              c_gv_name
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE ''''
              c_konp
              ''''
    INTO lwa_code-line.
  CONCATENATE 'OBJECT'
              c_equal
              lwa_code-line
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'TABLES'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'LINES'
              c_equal
              c_i_lines
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'EXCEPTIONS'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'OTHERS = 1 .'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'IF SY-SUBRC EQ 0.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Build code for READ statement on table I_LINES
  CONCATENATE 'READ TABLE'
              c_i_lines
              'INTO'
              c_wa_lines
              'INDEX 1'
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'IF SY-SUBRC EQ 0.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CLEAR lv_ty_tab.

*&--Populating LTX01 of final workarea
  CONCATENATE c_wa_lines
              c_hyphen
              c_tdline
    INTO lwa_code-line.
  CONCATENATE c_wa_final
              c_hyphen
              c_ltx01
    INTO lv_ty_tab.
  CONCATENATE lv_ty_tab
              c_equal
              lwa_code-line
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CLEAR lv_tab_nam.

*&--Populating LTX01_NAME of final workarea
  CONCATENATE c_wa_final
              c_hyphen
              c_ltx01
              c_name
    INTO lv_tab_nam.
  CONCATENATE ''''
              c_text_ind_y
              ''''
  INTO lwa_code-line.
  CONCATENATE lv_tab_nam
              c_equal
              lwa_code-line
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Build code for ELSE statement
  lwa_code-line = 'ELSE.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Build code for CLEAR statement
  CONCATENATE 'CLEAR'
              lv_ty_tab
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Populating LTX01_NAME of final workarea
  CONCATENATE ''''
              c_text_ind_n
              ''''
  INTO lwa_code-line.
  CONCATENATE lv_tab_nam
              c_equal
              lwa_code-line
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'ENDIF.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'ELSE.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Build code for ELSE statement
  CONCATENATE 'CLEAR'
              lv_ty_tab
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Populating LTX01_NAME of final workarea
  CONCATENATE ''''
              c_text_ind_n
              ''''
  INTO lwa_code-line.
  CONCATENATE lv_tab_nam
              c_equal
              lwa_code-line
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'ENDIF.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code for APPEND statement from WA_FINAL to I_FINAL
  CONCATENATE 'APPEND'
              c_wa_final
              'TO'
              c_i_final
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.

  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code for CLEAR statement
  CONCATENATE c_wa
              c_konp
    INTO lwa_code-line.
  CONCATENATE 'CLEAR'
              lwa_code-line
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.


  lwa_code-line = 'ENDLOOP.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

  lwa_code-line = 'ENDIF.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code for CLEAR statement
  CONCATENATE 'CLEAR'
              c_wa_final
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE c_wa
              fp_x_t681-kotab
    INTO lwa_code-line.
  CONCATENATE 'CLEAR'
              lwa_code-line
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'ENDLOOP.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_code TO fp_i_code. "Blank Line

  CONCATENATE c_i_final
              c_bracket
    INTO lwa_code-line.
  CONCATENATE 'IF'
              lwa_code-line
              'IS INITIAL'
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Build code Error Message
  CONCATENATE 'MESSAGE'
              'I134'
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

  lwa_code-line = 'LEAVE LIST-PROCESSING.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'ENDIF.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

  CLEAR lv_col_pos.

*&--Build code for populating data in fieldcatalog table
  LOOP AT li_tab_fld ASSIGNING <lfs_tab_fld>.

    lv_col_pos = lv_col_pos + 1.
    MOVE lv_col_pos TO lv_col_pos_v.

*&--Build code for populating fieldname
    PERFORM f_get_fieldcat_code USING c_fieldname
                                      <lfs_tab_fld>-fname
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build code for currency populating fieldname
    PERFORM f_get_fieldcat_code USING c_cfieldname
                                      <lfs_tab_fld>-fname_c
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build code for populating quantity fieldname
    PERFORM f_get_fieldcat_code USING c_qfieldname
                                      <lfs_tab_fld>-fname_q
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build code for populating text of field
    PERFORM f_get_fieldcat_code USING c_seltext_l
                                      <lfs_tab_fld>-fdesc
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build code for populating field colomun number
    PERFORM f_get_fieldcat_code USING c_col_pos
                                      lv_col_pos_v
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build code for populating field datatype; CURR or QUAN
    PERFORM f_get_fieldcat_code USING c_datatype
                                      <lfs_tab_fld>-fdataty
                             CHANGING lwa_code.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

*&--Build code for APPEND statement for filling fieldcatalog table
    CONCATENATE 'APPEND'
                c_wa_fieldcat
                'TO'
                c_i_fieldcat
                c_dot
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CONCATENATE 'CLEAR'
                c_wa_fieldcat
                c_dot
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.

    CLEAR lv_col_pos_v.

    APPEND lwa_code TO fp_i_code. "Blank Line
  ENDLOOP.

  CLEAR lv_col_pos.

***********************************************************************
*--------Code for ALV FM----------------------------------------------*
***********************************************************************

*&--Build code to call FM 'REUSE_ALV_GRID_DISPLAY' to display ALV
  CONCATENATE ''''
              'REUSE_ALV_GRID_DISPLAY'
              ''''
    INTO lwa_code-line.
  CONCATENATE 'CALL FUNCTION'
              lwa_code-line
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'EXPORTING'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'I_CALLBACK_PROGRAM'
              c_equal
              c_sy_repid
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE ''''
              'F_TOP_OF_PAGE'
              ''''
    INTO lwa_code-line.
  CONCATENATE 'I_CALLBACK_TOP_OF_PAGE'
              c_equal
              lwa_code-line
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'IT_FIELDCAT'
              c_equal
              c_i_fieldcat
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE ''''
              c_save_a
              ''''
    INTO lwa_code-line.
  CONCATENATE 'I_SAVE'
              c_equal
              lwa_code-line
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'TABLES'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'T_OUTTAB'
              c_equal
              c_i_final
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'EXCEPTIONS'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'PROGRAM_ERROR = 1'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'OTHERS = 2.'
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'IF SY-SUBRC NE 0.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Build code Error Message
  CONCATENATE 'MESSAGE'
              'E132'
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'ENDIF.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.
  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code to REFRESH all internal tables defined
  lwa_code-line = 'REFRESH:'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  LOOP AT li_int_tab ASSIGNING <lfs_tab_fld>.
    CONCATENATE <lfs_tab_fld>-fname
                c_comma
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.
  ENDLOOP.

  CONCATENATE c_i_final
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code for sub-routine of top-of-page
  lwa_code-line = '*&---------------------------------------------------------------------*'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = '*&      Form  F_TOP_OF_PAGE'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = '*&---------------------------------------------------------------------*'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = '*       Subroutine for header display'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = '*----------------------------------------------------------------------*'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = '*  -->  p1        text'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = '*  <--  p2        text'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = '*----------------------------------------------------------------------*'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'FORM'
              c_top_of_page
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code to describe total number of rows in I_FINAL
  CONCATENATE c_i_final
              c_bracket
    INTO lwa_code-line.
  CONCATENATE 'DESCRIBE TABLE'
              lwa_code-line
              'LINES'
              c_gv_total
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code to call FM 'ZOTC_PRICING_TOP_OF_PAGE'
  CONCATENATE ''''
              'ZOTC_PRICING_TOP_OF_PAGE'
              ''''
    INTO lwa_code-line.
  CONCATENATE 'CALL FUNCTION'
              lwa_code-line
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'EXPORTING'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'IM_TOT_RECORDS'
              c_equal
              c_gv_total
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'IMPORTING'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'EX_LISTHEADER'
              c_equal
              c_i_listhead
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

*&--Build code to call FM 'REUSE_ALV_COMMENTARY_WRITE'
  CONCATENATE ''''
              'REUSE_ALV_COMMENTARY_WRITE'
              ''''
    INTO lwa_code-line.
  CONCATENATE 'CALL FUNCTION'
              lwa_code-line
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = 'EXPORTING'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE 'IT_LIST_COMMENTARY'
              c_equal
              c_i_listhead
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  APPEND lwa_code TO fp_i_code. "Blank Line

  lwa_code-line = 'ENDFORM.'.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

ENDFORM.                    " F_GET_REPORT_CODE
*&---------------------------------------------------------------------*
*&      Form  f_get_fieldcat_code
*&---------------------------------------------------------------------*
*       Subroutine to get fieldcatalog text
*----------------------------------------------------------------------*
*      -->FP_V_FIELDN  Field name
*      -->FP_V_FIELDV  Field value
*      -->FP_X_CODE    Source Code
*----------------------------------------------------------------------*
FORM f_get_fieldcat_code USING fp_v_fieldn TYPE char30
                               fp_v_fieldv TYPE char40
                      CHANGING fp_x_code   TYPE rssource.

  DATA:
    lv_fieldval TYPE char40. "Field Value

  CONCATENATE ''''
              fp_v_fieldv
              ''''
    INTO lv_fieldval.
  CONDENSE lv_fieldval.

  CONCATENATE c_wa_fieldcat
              c_hyphen
              fp_v_fieldn
    INTO fp_x_code.
  CONDENSE fp_x_code.

  CONCATENATE fp_x_code
              c_equal
              lv_fieldval
              c_dot
    INTO fp_x_code
    SEPARATED BY space.

ENDFORM.                    "f_get_fieldcat_code
*&---------------------------------------------------------------------*
*&      Form  f_get_table_copy_code
*&---------------------------------------------------------------------*
*       Get statement to copy table into tamporary table
*----------------------------------------------------------------------*
*      -->FP_V_TABLE Table Name
*      -->FP_X_CODE  Source Code
*----------------------------------------------------------------------*
FORM f_get_table_copy_code USING fp_v_table TYPE char30
                        CHANGING fp_x_code  TYPE rssource.

  DATA:
    lv_table TYPE char30. "Table Name

  CONCATENATE c_i
              fp_v_table
              c_uscore
              c_tmp
              c_bracket
    INTO lv_table.

  CONCATENATE c_i
              fp_v_table
              c_bracket
    INTO fp_x_code-line.

  CONCATENATE lv_table
              c_equal
              fp_x_code-line
              c_dot
    INTO fp_x_code-line
    SEPARATED BY space.

ENDFORM.                    "f_get_table_copy_code
*&---------------------------------------------------------------------*
*&      Form  f_get_field_code
*&---------------------------------------------------------------------*
*       Subroutine to get code for TYPE statement and structure for
*       final table information
*----------------------------------------------------------------------*
*      -->FP_V_FNAME1   First field name
*      -->FP_V_FNAME2   Second field name
*      -->FP_V_FDESC    Description of field
*      <--FP_X_CODE     Source Code Structure
*      <--FP_X_TAB_FLD  Field Info structure
*----------------------------------------------------------------------*
FORM f_get_field_code USING fp_v_fname1  TYPE char30
                            fp_v_fname2  TYPE char30
                            fp_v_fdesc   TYPE scrtext_l
                   CHANGING fp_x_code    TYPE rssource
                            fp_x_tab_fld TYPE ty_tab_fld.

  CONCATENATE fp_v_fname1
              'TYPE'
              fp_v_fname2
              c_comma
    INTO fp_x_code-line
    SEPARATED BY space.

  fp_x_tab_fld-fname = fp_v_fname1.
  fp_x_tab_fld-fdesc = fp_v_fdesc.

ENDFORM.                    "f_get_field_code
*&---------------------------------------------------------------------*
*&      Form  f_get_field_desc_code
*&---------------------------------------------------------------------*
*       Subroutine to get code for TYPE statement and structure for
*       final table information for description field like MATNR_NAME
*       KUNNR_NAME etc
*----------------------------------------------------------------------*
*      -->FP_V_FNAME1   Field Name
*      -->FP_V_FNAME2   Data Element Name
*      -->FP_V_FDESC    Field Description
*      -->FP_X_CODE     Source Code
*      -->FP_X_TAB_FLD  Table Field Info structure
*----------------------------------------------------------------------*
FORM f_get_field_desc_code USING fp_v_fname1  TYPE char30
                                 fp_v_fname2  TYPE char30
                                 fp_v_fdesc   TYPE scrtext_l
                        CHANGING fp_x_code    TYPE rssource
                                 fp_x_tab_fld TYPE ty_tab_fld.

  CONCATENATE fp_v_fname1
              c_name
    INTO fp_x_code-line.

  fp_x_tab_fld-fname = fp_x_code-line+0(30).

  CONCATENATE fp_x_code-line
              'TYPE'
              fp_v_fname2
              c_comma
    INTO fp_x_code-line
    SEPARATED BY space.

  fp_x_tab_fld-fdesc = fp_v_fdesc.

ENDFORM.                    "f_get_field_desc_code
*&---------------------------------------------------------------------*
*&      Form  f_get_final_wa_code
*&---------------------------------------------------------------------*
*       Subrouine to get source code to populate of the given field
*----------------------------------------------------------------------*
*      -->FP_V_KOTAB   Table name
*      -->FP_V_FIELD1  Table's field name
*      -->FP_V_FIELD2  Final Workarea Field Name
*      -->FP_X_CODE    Source Code
*----------------------------------------------------------------------*
FORM f_get_final_wa_code USING fp_v_kotab  TYPE char30
                               fp_v_field1 TYPE char30
                               fp_v_field2 TYPE char30
                      CHANGING fp_x_code   TYPE rssource.

  DATA:
    lv_field1 TYPE char40, "Field Name
    lv_field2 TYPE char40. "Field Name

  CONCATENATE c_wa_final
              c_hyphen
              fp_v_field2
    INTO lv_field2.

  CONCATENATE c_wa
              fp_v_kotab
              c_hyphen
              fp_v_field1
    INTO lv_field1.

  CONCATENATE lv_field2
              c_equal
              lv_field1
              c_dot
    INTO fp_x_code-line
    SEPARATED BY space.


ENDFORM.                    "f_get_final_wa_code
*&---------------------------------------------------------------------*
*&      Form  f_get_date_code
*&---------------------------------------------------------------------*
*       Get Source Code to populate date field in format MM.DD.YYYY
*       which is the date format for object id OTC_CDD_0008
*----------------------------------------------------------------------*
*      -->FP_V_KOTAB   table name
*      -->FP_V_FIELD1  table's field name of date
*      -->FP_V_FIELD2  final table fieldname
*      -->FP_I_CODE    Source Code table
*----------------------------------------------------------------------*
FORM f_get_date_code USING fp_v_kotab  TYPE char30
                           fp_v_field1 TYPE char30
                           fp_v_field2 TYPE char30
                  CHANGING fp_i_code   TYPE zrcg_bag_rssource.

  CONSTANTS:
    lc_mm TYPE char05 VALUE '+4(2)', "for month
    lc_dd TYPE char05 VALUE '+6(2)', "for date
    lc_yy TYPE char05 VALUE '+0(4)'. "for year

  DATA:
    lv_field_dd TYPE char30, "Field variable for date
    lv_field_mm TYPE char30, "Field variable for month
    lv_field_yy TYPE char30, "Field variable for year
    lv_dot      TYPE char03, "Field variable for dot separator
    lwa_code    TYPE rssource. "Source Code

  CONCATENATE c_wa
              fp_v_kotab
              c_hyphen
              fp_v_field1
              lc_mm
    INTO lv_field_mm.
  CONDENSE lv_field_mm NO-GAPS.

  CONCATENATE c_wa
              fp_v_kotab
              c_hyphen
              fp_v_field1
              lc_dd
    INTO lv_field_dd.
  CONDENSE lv_field_dd NO-GAPS.

  CONCATENATE c_wa
              fp_v_kotab
              c_hyphen
              fp_v_field1
              lc_yy
    INTO lv_field_yy.
  CONDENSE lv_field_yy NO-GAPS.

  CONCATENATE ''''
              c_fslash
              ''''
    INTO lv_dot.
  CONDENSE lv_dot NO-GAPS.

*&--Code to build CONCATENATE statement for date fields
  CONCATENATE 'CONCATENATE'
              lv_field_mm
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = lv_dot.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = lv_field_dd.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = lv_dot.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  lwa_code-line = lv_field_yy.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

  CONCATENATE c_wa_final
              c_hyphen
              fp_v_field2
    INTO lwa_code-line.
  CONCATENATE 'INTO'
              lwa_code-line
              c_dot
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

ENDFORM.                    "f_get_date_code
*&---------------------------------------------------------------------*
*&      Form  f_get_str_dec_code
*&---------------------------------------------------------------------*
*       Subroutine to build Code for Structres
*----------------------------------------------------------------------*
*      -->FP_V_STRUC   Structre name
*      -->FP_V_INDIC   Indicator
*      -->FP_I_FIELD   Strucre fields table
*      -->FP_I_CODE    Source Code table
*----------------------------------------------------------------------*
FORM f_get_str_dec_code USING fp_v_struc TYPE char30
                              fp_v_indic TYPE char01
                              fp_i_field TYPE ty_t_str_fld
                     CHANGING fp_i_code  TYPE zrcg_bag_rssource.

  DATA:
    lwa_code    TYPE rssource,   "Source Code
    lv_struc    TYPE char30,     "Strcutre Name
    lv_indic    TYPE char01.     "Indicator; 'X' = dot at end

  FIELD-SYMBOLS:
    <lfs_field> TYPE ty_str_fld. "Structre Declaration FS

*&--Assigning name of structre
  CONCATENATE c_ty
              fp_v_struc
    INTO lv_struc.

*&--Build code for BEGIN OF statement
  CONCATENATE 'BEGIN OF'
              lv_struc
              c_comma
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--Process and build code for defining fields of structre
  LOOP AT fp_i_field ASSIGNING <lfs_field>.
    CONCATENATE <lfs_field>-field1
                'TYPE'
                <lfs_field>-field2
                c_comma
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.
  ENDLOOP.

*&--If indicator is not initial then dot will come at end else comma
  IF fp_v_indic IS NOT INITIAL.
    lv_indic = c_dot.
  ELSE.
    lv_indic = c_comma.
  ENDIF.

*&--Build code for END OF statement
  CONCATENATE 'END OF'
              lv_struc
              lv_indic
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

ENDFORM.                    "f_get_str_dec_code
*&---------------------------------------------------------------------*
*&      Form  f_get_i_wa_code
*&---------------------------------------------------------------------*
*       Subroutine to build Code for declaration of Internal Table and
*       Workarea
*----------------------------------------------------------------------*
*      -->FP_V_STRUC   Structre name
*      -->FP_V_INDIC   Indicator that work area needed or not
*      -->FP_V_TEMP    Indicator; X=Temporary Internal Table & Workarea
*      -->FP_I_CODE    Source Code table
*      -->FP_I_TABLE   Stores the name of Internal Table generated
*----------------------------------------------------------------------*
FORM f_get_i_wa_code USING fp_v_struc    TYPE char30
                           fp_v_indic    TYPE char01
                           fp_v_temp     TYPE char01
                  CHANGING fp_i_code     TYPE zrcg_bag_rssource
                           fp_i_table    TYPE ty_t_tab_fld.

  DATA:
    lwa_code   TYPE rssource,   "Source Code
    lwa_table  TYPE ty_tab_fld, "WA to stores the name of internal table
    lv_struc   TYPE char30,     "Structure name
    lv_tab_nam TYPE char30,     "Internal Table Name
    lv_wrk_nam TYPE char30.     "Workarea Name

*&--Assign the structure name
  CONCATENATE c_ty
              fp_v_struc
    INTO lv_struc.
  CONDENSE lv_struc NO-GAPS.

*&--Assign the internal table name
  IF fp_v_temp IS INITIAL.
    CONCATENATE c_i
                fp_v_struc
      INTO lv_tab_nam.
  ELSE.
    CONCATENATE c_i
                fp_v_struc
                c_uscore
                c_tmp
      INTO lv_tab_nam.
  ENDIF.

  CONDENSE lv_tab_nam NO-GAPS.

*&--Populate the name of internal table
  lwa_table-fname = lv_tab_nam.
  APPEND lwa_table TO fp_i_table.

*&--Code for declaration internal table
  CONCATENATE lv_tab_nam
              'TYPE STANDARD TABLE OF'
              lv_struc
              c_comma
    INTO lwa_code-line
    SEPARATED BY space.
  APPEND lwa_code TO fp_i_code.
  CLEAR lwa_code.

*&--If workarea indicator is not initial then build code
*&--to generate declaration of workarea
  IF fp_v_indic IS NOT INITIAL.
*&--Assign the workarea name
    IF fp_v_temp IS INITIAL.
      CONCATENATE c_wa
                  fp_v_struc
        INTO lv_wrk_nam.
    ELSE.
      CONCATENATE c_wa
                  fp_v_struc
                  c_uscore
                  c_tmp
        INTO lv_wrk_nam.
    ENDIF.

    CONDENSE lv_wrk_nam NO-GAPS.

*&--Code for declaration workarea
    CONCATENATE lv_wrk_nam
                'TYPE'
                lv_struc
                c_comma
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
  ENDIF.

ENDFORM.                    "f_get_i_wa_code
*&---------------------------------------------------------------------*
*&      Form  f_get_var_dec_code
*&---------------------------------------------------------------------*
*       Subroutine to build Code for declaration of Variable
*----------------------------------------------------------------------*
*      -->FP_I_FIELD   Information of fields and dataelements
*      -->FP_I_CODE    Source Code table
*----------------------------------------------------------------------*
FORM f_get_var_dec_code USING fp_i_field    TYPE ty_t_str_fld
                     CHANGING fp_i_code     TYPE zrcg_bag_rssource.
  DATA:
    lwa_code    TYPE rssource.   "Source Code

  FIELD-SYMBOLS:
    <lfs_field> TYPE ty_str_fld. "FS for variable fields table

*&--Process on records and build the code
  LOOP AT fp_i_field ASSIGNING <lfs_field>.
    CONCATENATE <lfs_field>-field1
                'TYPE'
                <lfs_field>-field2
                c_comma
      INTO lwa_code-line
      SEPARATED BY space.
    APPEND lwa_code TO fp_i_code.
    CLEAR lwa_code.
  ENDLOOP.

ENDFORM.                    "f_get_var_dec_code
