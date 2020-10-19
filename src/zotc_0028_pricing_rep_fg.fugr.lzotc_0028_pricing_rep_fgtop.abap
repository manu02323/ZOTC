*&---------------------------------------------------------------------*
*& Include  LZOTC_0028_PRICING_REP_FGTOP
*&---------------------------------------------------------------------*
************************************************************************
* INCLUDE    :  LZOTC_0028_PRICING_REP_FGTOP                           *
* TITLE      :  Pricing Report for Mass Price Upload                   *
* DEVELOPER  :  ROHIT VERMA                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_RDD_0028_Pricing Report for Mass Price Upload      *
*----------------------------------------------------------------------*
* DESCRIPTION: Top include for function group ZOTC_0028_PRICING_REP_FG *
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

FUNCTION-POOL zotc_0028_pricing_rep_fg.     "MESSAGE-ID ..

* INCLUDE LZOTC_0028_PRICING_REP_FGD...      " Local class definition

TYPES:
*&--Table Type: T681E
  ty_t_t681e   TYPE STANDARD TABLE OF t681e,

*&--Table Type: DFIES
  ty_t_dfies   TYPE STANDARD TABLE OF dfies,

*&--Structure for TVARVC table
  BEGIN OF ty_tvarvc,
    name TYPE rvari_vnam,	"Name of Variant Variable
    type TYPE rsscr_kind,	"Type of selection
    numb TYPE tvarv_numb,	"Current selection number
    sign TYPE tvarv_sign,	"ID: I/E (include/exclude values)
    opti TYPE tvarv_opti,	"Selection option (EQ/BT/CP/...)
    low  TYPE tvarv_val,  "Selection value Low
  END OF ty_tvarvc,

*&--Table Type for TVARVC table
  ty_t_tvarvc TYPE STANDARD TABLE OF ty_tvarvc,

*&--Structure for KNVP table
  BEGIN OF ty_knvp,
    kunnr TYPE kunnr, "Customer Number
    vkorg TYPE vkorg, "Sales Organization
    vtweg TYPE vtweg, "Distribution Channel
    spart TYPE spart, "Division
    parvw TYPE parvw, "Partner Function
    parza TYPE parza, "Partner counter
    kunn2 TYPE kunn2, "Sales Representative
  END OF ty_knvp,

*&--Table Type for KNVP table
  ty_t_knvp TYPE STANDARD TABLE OF ty_knvp,

*&--Structure: KNA1
  BEGIN OF ty_kna1,
    kunnr TYPE kunnr, "Customer Number
  END OF ty_kna1,
*&--Table Type: KNA1
  ty_t_kna1     TYPE STANDARD TABLE OF ty_kna1,

*&--Structure: Select-Options
  BEGIN OF ty_sel_tab,
    selname TYPE char08, "Select-Option
    field   TYPE char30, "Field Name
  END OF ty_sel_tab,
*&--Table Type: Select-Options
  ty_t_sel_tab TYPE STANDARD TABLE OF ty_sel_tab,

*&--Structure: Structre Declaration
  BEGIN OF ty_str_fld,
    field1 TYPE char30, "Field Name/Data Element Name
    field2 TYPE char30, "Field Name/Data Element Name
  END OF ty_str_fld,
*&--Table Type: Structre Declaration
  ty_t_str_fld TYPE STANDARD TABLE OF ty_str_fld,

*&--Structure: Fieldcatalog Table
  BEGIN OF ty_tab_fld,
    fname   TYPE char40,  "Field Name
    fname_c TYPE char40,  "Curr Field Name
    fname_q TYPE char40,  "Quan Field Name
    fdesc   TYPE char40,  "Field Description
    fdataty TYPE char40,  "Field Datatype
  END OF ty_tab_fld,
*&--Table Type: Fieldcatalog Table
  ty_t_tab_fld TYPE STANDARD TABLE OF ty_tab_fld.


CONSTANTS:
  c_zero        TYPE char01     VALUE '0',  "Zero
  c_yes         TYPE char01     VALUE 'X',  "Check
  c_program_x   TYPE char11     VALUE 'ZOTCR0028O_',  "Program Initial
  c_scr_block1  TYPE char04     VALUE 'BLK1', "Selection-Screen Block1
  c_tpool_id_i  TYPE textpoolid VALUE 'I',  "Text-Pool Id 'I'
  c_tpool_id_r  TYPE textpoolid VALUE 'R',  "Text-Pool Id 'R'
  c_tpool_id_s  TYPE textpoolid VALUE 'S',  "Text-Pool Id 'S'
  c_textkey     TYPE char08     VALUE 'TEXT-XXX', "Text Key
  c_dot         TYPE char01     VALUE '.',  "Dot
  c_colon       TYPE char01     VALUE ':',  "Colon
  c_comma       TYPE char01     VALUE ',',  "Comma
  c_hyphen      TYPE char01     VALUE '-',  "Hyphen
  c_uscore      TYPE char01     VALUE '_',  "Underscore
  c_fslash      TYPE char01     VALUE '/',  "Forward Slash
  c_curr        TYPE char04     VALUE 'CURR', "Currency
  c_quan        TYPE char04     VALUE 'QUAN', "Quantity
  c_msgid_otc   TYPE symsgid    VALUE 'ZOTC_MSG', "ZOTC message id
  c_ltx01       TYPE char30     VALUE 'LTX01',  "Field Name/Data Element Name
  c_ltext72     TYPE char30     VALUE 'LTEXT72',"Field Name/Data Element Name
  c_p_kappl     TYPE char10     VALUE 'P_KAPPL',"Parameter Name
  c_kappl       TYPE char30     VALUE 'KAPPL',  "Field Name/Data Element Name
  c_p_kschl     TYPE char10     VALUE 'P_KSCHL',"Parameter Name
  c_kschl       TYPE char30     VALUE 'KSCHL',  "Field Name/Data Element Name
  c_kscha       TYPE char30     VALUE 'KSCHA',  "Field Name/Data Element Name
  c_so          TYPE char02     VALUE 'S_',     "Select-Option Initial
  c_kunwe       TYPE char30     VALUE 'KUNWE',  "Field Name/Data Element Name
  c_kunag       TYPE char30     VALUE 'KUNAG',  "Field Name/Data Element Name
  c_kunnr_v     TYPE char30     VALUE 'KUNNR_V',"Field Name/Data Element Name
  c_kunnr       TYPE char30     VALUE 'KUNNR',  "Field Name/Data Element Name
  c_kvgr1       TYPE char30     VALUE 'KVGR1',  "Field Name/Data Element Name
  c_kvgr2       TYPE char30     VALUE 'KVGR2',  "Field Name/Data Element Name
  c_zzkvgr1     TYPE char30     VALUE 'ZZKVGR1',"Field Name/Data Element Name
  c_zzkvgr2     TYPE char30     VALUE 'ZZKVGR2',"Field Name/Data Element Name
  c_name1       TYPE char30     VALUE 'NAME1',  "Field Name/Data Element Name
  c_name1_gp    TYPE char30     VALUE 'NAME1_GP',"Field Name/Data Element Name
  c_ort01       TYPE char30     VALUE 'ORT01',   "Field Name/Data Element Name
  c_ort01_gp    TYPE char30     VALUE 'ORT01_GP',"Field Name/Data Element Name
  c_vkorg       TYPE char30     VALUE 'VKORG',   "Field Name/Data Element Name
  c_vtweg       TYPE char30     VALUE 'VTWEG',   "Field Name/Data Element Name
  c_parvw       TYPE char30     VALUE 'PARVW',   "Field Name/Data Element Name
  c_parza       TYPE char30     VALUE 'PARZA',   "Field Name/Data Element Name
  c_fld1        TYPE char30     VALUE 'FLD1',    "Field Name/Data Element Name
  c_p_kunn2     TYPE char10     VALUE 'P_KUNN2', "Parameter Name
  c_kunn2       TYPE char30     VALUE 'KUNN2',   "Field Name/Data Element Name
  c_kfrst       TYPE char30     VALUE 'KFRST',   "Field Name/Data Element Name
  c_datab       TYPE char30     VALUE 'DATAB',   "Field Name/Data Element Name
  c_gv_datab    TYPE char10     VALUE 'GV_DATAB',"Variable Name
  c_kodatab     TYPE char30     VALUE 'KODATAB', "Field Name/Data Element Name
  c_s_datab     TYPE char10     VALUE 'S_DATAB', "Select-Option Name
  c_datbi       TYPE char30     VALUE 'DATBI',   "Field Name/Data Element Name
  c_gv_datbi    TYPE char10     VALUE 'GV_DATBI',"Variable Name
  c_kodatbi     TYPE char30     VALUE 'KODATBI', "Field Name/Data Element Name
  c_s_datbi     TYPE char10     VALUE 'S_DATBI', "Select-Option Name
  c_gv_salesrep TYPE char11     VALUE 'GV_SALESREP',"Variable Name
  c_gv_salesflg TYPE char11     VALUE 'GV_SALESFLG',"Variable Name
  c_char01      TYPE char30     VALUE 'CHAR01',   "Field Name/Data Element Name
  c_char10      TYPE char30     VALUE 'CHAR10',   "Field Name/Data Element Name
  c_i_customer  TYPE char10     VALUE 'I_CUSTOMER',"Internal Table Name
  c_selopt      TYPE char30     VALUE 'SELOPT',   "Field Name/Data Element Name
  c_gv          TYPE char03     VALUE 'GV_',      "Variable Initial
  c_i           TYPE char02     VALUE 'I_',       "Internal Table Initial
  c_wa          TYPE char03     VALUE 'WA_',      "Workarea Initial
  c_ty          TYPE char03     VALUE 'TY_',      "Structure Initial
  c_star        TYPE char01     VALUE '*',        "Star
  c_konp        TYPE char30     VALUE 'KONP',     "Table Name
  c_knumh       TYPE char30     VALUE 'KNUMH',    "Field Name/Data Element Name
  c_kopos       TYPE char30     VALUE 'KOPOS',    "Field Name/Data Element Name
  c_krech       TYPE char30     VALUE 'KRECH',    "Field Name/Data Element Name
  c_krech_a     TYPE char05     VALUE '''A''',    "A=Percentage (Calculation type for condition)
  c_ten         TYPE char02     VALUE '10',       "Number '10'
  c_kbetr       TYPE char30     VALUE 'KBETR',    "Field Name/Data Element Name
  c_kbetr_kond  TYPE char30     VALUE 'KBETR_KOND',"Field Name/Data Element Name
  c_konwa       TYPE char30     VALUE 'KONWA',    "Field Name/Data Element Name
  c_kpein       TYPE char30     VALUE 'KPEIN',    "Field Name/Data Element Name
  c_kmein       TYPE char30     VALUE 'KMEIN',    "Field Name/Data Element Name
  c_kna1        TYPE char30     VALUE 'KNA1',     "Table Name
  c_kukla       TYPE char30     VALUE 'KUKLA',    "Field Name/Data Element Name
  c_kdgrp       TYPE char30     VALUE 'KDGRP',    "Field Name/Data Element Name
  c_t151t       TYPE char30     VALUE 'T151T',    "Table Name
  c_ktext       TYPE char30     VALUE 'KTEXT',    "Field Name/Data Element Name
  c_vtxtk       TYPE char30     VALUE 'VTXTK',    "Field Name/Data Element Name
  c_knvv        TYPE char30     VALUE 'KNVV',     "Table Name
  c_tvv1t       TYPE char30     VALUE 'TVV1T',    "Table Name
  c_tvv2t       TYPE char30     VALUE 'TVV2T',    "Table Name
  c_bezei       TYPE char30     VALUE 'BEZEI',    "Field Name/Data Element Name
  c_bezei20     TYPE char30     VALUE 'BEZEI20',  "Field Name/Data Element Name
  c_matnr       TYPE char30     VALUE 'MATNR',    "Field Name/Data Element Name
  c_maktx       TYPE char30     VALUE 'MAKTX',    "Field Name/Data Element Name
  c_makt        TYPE char30     VALUE 'MAKT',     "Table Name
  c_tkukt       TYPE char30     VALUE 'TKUKT',    "Table Name
  c_vtext       TYPE char30     VALUE 'VTEXT',    "Field Name/Data Element Name
  c_knvp        TYPE char30     VALUE 'KNVP',     "Table Name
  c_tmp         TYPE char03     VALUE 'TMP',      "TMP text
  c_bracket     TYPE char02     VALUE '[]',       "Brackets
  c_equal       TYPE char01     VALUE '=',        "Equal/Assign
  c_spras       TYPE char30     VALUE 'SPRAS',    "Field Name/Data Element Name
  c_langu       TYPE char08     VALUE 'SY-LANGU', "System Language Constant
  c_spart       TYPE char30     VALUE 'SPART',    "Field Name/Data Element Name
  c_sales_idn_01 TYPE char02    VALUE '01',       "Sold-to Idenitification
  c_sales_idn_02 TYPE char02    VALUE '02',       "Ship-to Identification
  c_sign_i       TYPE char01    VALUE 'I',        "Sign 'I'; Include
  c_option_eq    TYPE char02    VALUE 'EQ',       "Option 'EQ'; Equal
  c_name         TYPE char05    VALUE '_NAME',    "Name subsequent for description fields
  c_ty_final     TYPE char08    VALUE 'TY_FINAL', "Structure Name for Final table
  c_i_final      TYPE char07    VALUE 'I_FINAL',  "Internal Table Name for Final table
  c_wa_final     TYPE char08    VALUE 'WA_FINAL', "Workarea for Final table
  c_gv_index     TYPE char10    VALUE 'GV_INDEX', "Index used for parallel cursor
  c_sytabix      TYPE char10    VALUE 'SYTABIX',  "Field Name/Data Element Name
  c_sy_tabix     TYPE char10    VALUE 'SY-TABIX', "System Variable for Index
  c_i_lines      TYPE char10    VALUE 'I_LINES',  "INternal table for internal comments lines
  c_wa_lines     TYPE char10    VALUE 'WA_LINES', "Workarea for internal comments lines
  c_tlines       TYPE char10    VALUE 'TLINE',    "Field Name/Data Element Name
  c_tdid_0001    TYPE tdid      VALUE '0001',     "TDID = 0001
  c_gv_name      TYPE char10    VALUE 'GV_NAME',  "Variable Name
  c_text_proc    TYPE char02    VALUE '01',       "Text Procedure
  c_gv_total     TYPE char10    VALUE 'GV_TOTAL',  "Variable Name
  c_tdobname     TYPE char10    VALUE 'TDOBNAME', "Field Name/Data Element Name
  c_tdline       TYPE char10    VALUE 'TDLINE',   "Field Name/Data Element Name
  c_text_ind_y   TYPE char01    VALUE 'Y',        "Yes
  c_text_ind_n   TYPE char01    VALUE 'N',        "No
  c_i_fieldcat   TYPE char10    VALUE 'I_FIELDCAT', "Internal Table for Fieldcatalog
  c_wa_fieldcat  TYPE char11    VALUE 'WA_FIELDCAT',"Workarea for Fieldcatalog
  c_t_fieldcat   TYPE char30    VALUE 'SLIS_T_FIELDCAT_ALV',"Field Name/Data Element Name
  c_fieldcat     TYPE char30    VALUE 'SLIS_FIELDCAT_ALV',  "Field Name/Data Element Name
  c_i_listhead   TYPE char30    VALUE 'I_LISTHEADER', "Internal Table for Fieldcatalog
  c_wa_listhead  TYPE char30    VALUE 'WA_LISTHEADER',"Workarea for Fieldcatalog
  c_t_listhead   TYPE char30    VALUE 'SLIS_T_LISTHEADER',"Field Name/Data Element Name
  c_listhead     TYPE char30    VALUE 'SLIS_LISTHEADER',  "Field Name/Data Element Name
  c_fieldname    TYPE char30    VALUE 'FIELDNAME',  "Field Name/Data Element Name
  c_cfieldname   TYPE char30    VALUE 'CFIELDNAME', "Field Name/Data Element Name
  c_qfieldname   TYPE char30    VALUE 'QFIELDNAME', "Field Name/Data Element Name
  c_seltext_l    TYPE char30    VALUE 'SELTEXT_L', "Field Name/Data Element Name
  c_col_pos      TYPE char30    VALUE 'COL_POS',   "Field Name/Data Element Name
  c_datatype     TYPE char30    VALUE 'DATATYPE',  "Field Name/Data Element Name
  c_sy_repid     TYPE char30    VALUE 'SY-REPID',  "System Variable for program name
  c_save_a       TYPE char01    VALUE 'A',         "A; Standard+User save in ALV
  c_p_kotab      TYPE char10    VALUE 'P_KOTAB',   "Parameter
  c_kotab        TYPE char30    VALUE 'KOTAB',     "Field Name/Data Element Name
  c_top_of_page  TYPE char30    VALUE 'F_TOP_OF_PAGE',"Top-Of-Page
  c_loevm_ko     TYPE char30    VALUE 'LOEVM_KO',     "Field Name/Data Element Name
  c_space        TYPE char30    VALUE 'SPACE',        "System Field Name

  c_type_p        TYPE rsscr_kind VALUE 'P',"Variant Type
  c_numb_00       TYPE tvarv_numb VALUE '0000',"Variant Selction Number
*  c_name_parza    TYPE rvari_vnam VALUE 'ZOTC_0028_PARZA',"Variant Name  "Commented by SNIGAM : CR1302 : 3/25/2014
  c_name_spart    TYPE rvari_vnam VALUE 'ZOTC_0028_SPART',"Variant Name
  c_name_ktokd_ag TYPE rvari_vnam VALUE 'ZOTC_0028_KTOKD_AG',"Variant Name
  c_name_ktokd_we TYPE rvari_vnam VALUE 'ZOTC_0028_KTOKD_WE',"Variant Name
  c_name_parvw_sr TYPE rvari_vnam VALUE 'ZOTC_0028_PARVW_SR',"Variant Name

*&--BOC for Defect#2056 on 06-Sep-2013
  c_i_salesorg  TYPE char11     VALUE 'I_SALES_ORG', "Sales Org table
  c_i_salesdis  TYPE char11     VALUE 'I_SALES_DIS'. "Sales Distr Chnl table
*&--EOC for Defect#2056 on 06-Sep-2013

DATA:
  gv_textkey_no TYPE numc3.  "KeyNumber
