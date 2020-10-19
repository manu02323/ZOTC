*&---------------------------------------------------------------------*
*&  Include           ZOTC0093_ROUTINES_TO_DET_CP
*&---------------------------------------------------------------------*

*&--------------------------------------------------------------------*
*&INCLUDE            :  ZOTC0093_ROUTINES_TO_DET_CP                   *
* TITLE              :  get active change pointer and delete          *
* DEVELOPER          :  Deepanker Dwivedi                             *
* OBJECT TYPE        :  INTERFACE                                     *
* SAP RELEASE        :  SAP ECC 6.0                                   *
*---------------------------------------------------------------------*
* WRICEF ID  :  D3_OTC_IDD_0093                                       *
*---------------------------------------------------------------------*
* DESCRIPTION:   Based on selection criteria , select the active      *
*                      change pointers and delete from BDCp2 tables   *
*---------------------------------------------------------------------*
*10-Jun-2019    SMUKHER     E2DK924514      Defect# 8512 - Customer   *
*                                           Price Interface from SAP to
*                                           DiagDirect requires the   *
*                                           Bill-To partner code to be*
*                                           sent as well.             *
*---------------------------------------------------------------------*

* Global Data Declaration  .

TYPES: ty_bdcp2       TYPE STANDARD TABLE OF bdcp2. " Aggregated Change Pointers (BDCP, BDCPS)

TYPES : tt_vkorg TYPE RANGE OF vkorg, " Sales Organization
        tt_vtweg TYPE RANGE OF vtweg, " Distribution Channel
        tt_matnr TYPE RANGE OF matnr. " Material Number

*&---------------------------------------------------------------------*
*&      Form  f_fetch_active_records
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FP_KOTAB   text
*      <--FP_ITAB    text
*----------------------------------------------------------------------*
FORM get_active_records  USING    fp_kotab    TYPE kotab          " Condition table
                             CHANGING fp_itab     TYPE ANY TABLE. " Table of type ANY


  CONSTANTS : lc_kappl TYPE kappl VALUE 'V',     " Application
              lc_kschl TYPE char5 VALUE 'KSCHL', " Condition type
              lc_a004  TYPE kotab VALUE 'A004',  " Condition table
              lc_a005  TYPE kotab VALUE 'A005',  " Condition table
              lc_a911  TYPE kotab VALUE 'A911',  " Condition table
              lc_a935  TYPE kotab VALUE 'A935'.  " Condition table


* Select * has been used as the tables have no more that 12 fields and
* more that 90% of the fields are used in processing the records
  CASE fp_kotab.
    WHEN lc_a004.
      SELECT mandt
             kappl
             kschl
             vkorg
             vtweg
             matnr
             datbi
             datab
             knumh
        FROM (fp_kotab)
        INTO TABLE fp_itab
        WHERE kappl = lc_kappl
          AND kschl = p_cond
          AND vkorg IN s_vkorg
          AND vtweg IN s_vtweg
          AND matnr IN s_matnr
          AND datbi >= p_ersda
          AND datab <= p_ersda.
      IF sy-subrc IS INITIAL.
        SORT fp_itab BY (lc_kschl).
      ENDIF. " IF sy-subrc IS INITIAL
    WHEN lc_a005.
      SELECT mandt
             kappl
             kschl
             vkorg
             vtweg
             kunnr
             matnr
             datbi
             datab
             knumh
        FROM (fp_kotab)
        INTO TABLE fp_itab
        WHERE kappl = lc_kappl
          AND kschl = p_cond
          AND vkorg IN s_vkorg
          AND vtweg IN s_vtweg
          AND kunnr IN s_kunag
          AND matnr IN s_matnr
          AND datbi >= p_ersda
          AND datab <= p_ersda.
      IF sy-subrc IS INITIAL.
        SORT fp_itab BY (lc_kschl).
      ENDIF. " IF sy-subrc IS INITIAL
    WHEN lc_a911.
      SELECT mandt
             kappl
             kschl
             vkorg
             vtweg
             kunwe
             matnr
             kfrst
             datbi
             datab
             kbstat
             knumh
        FROM (fp_kotab)
        INTO TABLE fp_itab
        WHERE kappl = lc_kappl
          AND kschl = p_cond
          AND vkorg IN s_vkorg
          AND vtweg IN s_vtweg
          AND kunwe IN s_kunwe
          AND matnr IN s_matnr
          AND datbi >= p_ersda
          AND datab <= p_ersda.
      IF sy-subrc IS INITIAL.
        SORT fp_itab BY (lc_kschl).
      ENDIF. " IF sy-subrc IS INITIAL
    WHEN lc_a935.
      SELECT mandt
             kappl
             kschl
             vkorg
             vtweg
             kunag
             kunwe
             matnr
             kfrst
             datbi
             datab
             kbstat
             knumh
        FROM (fp_kotab)
        INTO TABLE fp_itab
        WHERE kappl = lc_kappl
          AND kschl = p_cond
          AND vkorg IN s_vkorg
          AND vtweg IN s_vtweg
          AND kunag IN s_kunag
          AND kunwe IN s_kunwe
          AND matnr IN s_matnr
          AND datbi >= p_ersda
          AND datab <= p_ersda.
      IF sy-subrc IS INITIAL.
        SORT fp_itab BY (lc_kschl).
      ENDIF. " IF sy-subrc IS INITIAL
    WHEN OTHERS.
*     do nothing
  ENDCASE.

ENDFORM. " F_FETCH_ACTIVE_RECORDS
*&---------------------------------------------------------------------*
*&      Form  F_GET_CHANGE_POINTER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<LFS_ITAB>  text
*      <--P_GIT_BDCP2  text
*----------------------------------------------------------------------*
FORM get_change_pointer_data  USING    p_lfs_itab TYPE ANY TABLE
                                CHANGING p_git_bdcp2 TYPE ty_bdcp2.
  TABLES : bdcp2. " Aggregated Change Pointers (BDCP, BDCPS)
  FIELD-SYMBOLS : <itab1>         TYPE ANY TABLE,
                  <ls_itab1>      TYPE any,
*&-- Begin of change for D3_OTC_IDD_0093 Defect# 8512 by SMUKHER on 10-Jun-2019
                  <lfs_git_bdcp2> TYPE bdcp2, " field symbol
*&-- End of change for D3_OTC_IDD_0093 Defect# 8512 by SMUKHER on 10-Jun-2019
                  <lv_knumh>      TYPE any.

  DATA : lwa_bdcp2   TYPE LINE OF ty_bdcp2,
         lit_condtab TYPE ty_bdcp2.

  CONSTANTS: lc_msgtype TYPE char30 VALUE 'ZOTC_COND_A' .

  LOOP AT p_lfs_itab ASSIGNING <ls_itab1> .
    IF <lv_knumh> IS NOT ASSIGNED .
      ASSIGN COMPONENT 'KNUMH' OF STRUCTURE <ls_itab1> TO <lv_knumh>.
      IF <lv_knumh> IS ASSIGNED .
        IF <lv_knumh> IS NOT INITIAL .
          lwa_bdcp2-cdobjid = <lv_knumh> .
          lwa_bdcp2-mestype = lc_msgtype .
          APPEND lwa_bdcp2 TO lit_condtab .
        ENDIF. " IF <lv_knumh> IS NOT INITIAL
      ENDIF. " IF <lv_knumh> IS ASSIGNED
      UNASSIGN <lv_knumh> .
    ENDIF. " IF <lv_knumh> IS NOT ASSIGNED
  ENDLOOP . " LOOP AT p_lfs_itab ASSIGNING <ls_itab1>
  UNASSIGN <ls_itab1> .


  IF lit_condtab IS NOT INITIAL .

    SORT lit_condtab BY mestype.
*&-- Begin of delete for D3_OTC_IDD_0093 Defect# 8512 by SMUKHER on 10-Jun-2019
*&-- For performance indexing , we will use just message type and process in
* where clause of the SELECT query below .
*cdobjid .
*&-- End of delete for D3_OTC_IDD_0093 Defect# 8512 by SMUKHER on 10-Jun-2019
    DELETE ADJACENT DUPLICATES FROM lit_condtab COMPARING mestype.
*&-- Begin of delete for D3_OTC_IDD_0093 Defect# 8512 by SMUKHER on 10-Jun-2019
*cdobjid .
*&-- End of delete for D3_OTC_IDD_0093 Defect# 8512 by SMUKHER on 10-Jun-2019
    SELECT * FROM bdcp2 INTO TABLE p_git_bdcp2 FOR ALL ENTRIES IN lit_condtab
    WHERE mestype = lit_condtab-mestype
    AND process = ' '.
*&-- Begin of delete for D3_OTC_IDD_0093 Defect# 8512 by SMUKHER on 10-Jun-2019
*    cdobjid = lit_condtab-cdobjid.
*&-- End of delete for D3_OTC_IDD_0093 Defect# 8512 by SMUKHER on 10-Jun-2019

    IF sy-subrc = 0 .
*&-- Begin of change for D3_OTC_IDD_0093 Defect# 8512 by SMUKHER on 10-Jun-2019
*&-- Filter out the entries based on CDOBJID.
      LOOP AT p_git_bdcp2 ASSIGNING <lfs_git_bdcp2>.
        READ TABLE lit_condtab TRANSPORTING NO FIELDS
                               WITH KEY cdobjid = <lfs_git_bdcp2>-cdobjid.
        IF sy-subrc IS NOT INITIAL.
          <lfs_git_bdcp2>-mestype = space.
        ENDIF.
      ENDLOOP.
      DELETE p_git_bdcp2 WHERE mestype = space.

      IF <lfs_git_bdcp2> IS ASSIGNED.
        UNASSIGN: <lfs_git_bdcp2>.
      ENDIF.
*&-- End of change for D3_OTC_IDD_0093 Defect# 8512 by SMUKHER on 10-Jun-2019
    ENDIF. " IF sy-subrc = 0

  ENDIF. " IF lit_condtab IS NOT INITIAL

ENDFORM. " F_GET_CHANGE_POINTER_DATA
*&---------------------------------------------------------------------*
*&      Form  F_DELETE_BDCP2_RECORDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GIT_BDCP2  text
*----------------------------------------------------------------------*
FORM delete_bdcp2_records  USING    p_git_bdcp2 TYPE ty_bdcp2
                           CHANGING p_flag      TYPE char1. " Flag of type CHAR1

  IF p_git_bdcp2 IS NOT INITIAL.
    DELETE bdcp2 FROM TABLE p_git_bdcp2.
    IF sy-subrc = 0.
      COMMIT WORK.
      p_flag = 'X' .
    ELSE . " ELSE -> IF sy-subrc = 0
      CLEAR p_flag .
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF p_git_bdcp2 IS NOT INITIAL

ENDFORM. " F_DELETE_BDCP2_RECORDS
*&---------------------------------------------------------------------*
*&      Form  DELETE_ACTIVE_CP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TAB  text
*----------------------------------------------------------------------*
FORM delete_active_cp  TABLES   s_vkorg TYPE tt_vkorg
                                s_vtweg  TYPE tt_vtweg
                                s_matnr TYPE tt_matnr
                       USING    p_ersda TYPE ersda " Created On
                                p_tab TYPE kotabnr " Condition table
                                p_cond TYPE kschl  " Condition Type
                       CHANGING p_flag TYPE char1. " Flag of type CHAR1

  TYPES: ty_bdcp2       TYPE STANDARD TABLE OF bdcp2. " Aggregated Change Pointers (BDCP, BDCPS)

  DATA : lit_bdcp2 TYPE STANDARD TABLE OF   bdcp2, " Change Pointer Table
         li_itab   TYPE REF TO             data.   " Class

  DATA :  lwa_itab        TYPE REF TO       data. " Class

  CONSTANTS : lc_cond_use TYPE  kvewe          VALUE 'A', " Usage of the condition table
              lc_app      TYPE  kappl          VALUE 'V'. " Application

  DATA : lv_kbetr         TYPE        char10,              " Kbetr of type CHAR10
         lv_ref_tabletype TYPE REF TO cl_abap_tabledescr,  " Runtime Type Services
         lv_ref_rowtype   TYPE REF TO cl_abap_structdescr, " Runtime Type Services
         lv_kotab         TYPE        kotab.               " Condition table

  FIELD-SYMBOLS : <lfs_itab> TYPE ANY TABLE, " Dynamic Internal Table
                  <lfs_work> TYPE any.       " Dynamic Workarea
  "<lfs_konp>   TYPE lty_konp.        " Condition Record


  CONCATENATE lc_cond_use p_tab INTO lv_kotab.

*  Create dynamic table
  lv_ref_rowtype ?= cl_abap_typedescr=>describe_by_name( p_name = lv_kotab ).
  lv_ref_tabletype = cl_abap_tabledescr=>create( p_line_type = lv_ref_rowtype ).
  CREATE DATA li_itab TYPE HANDLE lv_ref_tabletype. " Internal ID of an object
  CREATE DATA lwa_itab TYPE HANDLE lv_ref_rowtype. " Internal ID of an object
  ASSIGN li_itab->* TO <lfs_itab>.
  ASSIGN lwa_itab->* TO <lfs_work>.


  PERFORM get_active_records USING    lv_kotab
                                      CHANGING <lfs_itab>.

  PERFORM get_change_pointer_data USING <lfs_itab>
                                    CHANGING lit_bdcp2 .
  PERFORM delete_bdcp2_records USING lit_bdcp2
                               CHANGING p_flag .



ENDFORM. " DELETE_ACTIVE_CP
