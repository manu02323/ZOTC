************************************************************************
* PROGRAM    :  LZOTC_TERRIT_ASSNF02                                   *
* TITLE      :  Routine to track create/change detail                  *
* DEVELOPER  :  Mayukh CHatterjee                                      *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
*  WRICEF ID :  D2_OTC_EDD_0213                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Routine to track create/change detail                  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 09-OCT-2014 MCHATTE  E2DK904939  INITIAL DEVELOPMENT                 *
* 28-APR-2016 SBEHERA  E2DK917651  Defect#1461: 1.Validation Customer  *
*                                    with sales area                   *
*                                  2.Validate customer not to allow an *
*                                    entry with account group ZREP     *
*                                  3.Validate effect from date and     *
*                                    effect to date for same sales are *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE LZOTC_TERRIT_ASSNF02.
*----------------------------------------------------------------------*
FORM f_track_create.
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
* Types declaration
  TYPES:
    BEGIN OF lty_terr_assn,
      vkorg	         TYPE vkorg,         " Sales Organization
      vtweg	         TYPE vtweg,         " Distribution Channel
      spart	         TYPE spart,         " Division
      kunnr	         TYPE kunnr,         " Customer Number
      territory_id   TYPE	zterritory_id, " Partner Territory ID
      partrole       TYPE	zpart_role,    " Partner Role
      effective_from TYPE	zeffect_date,  " Effective From
      effective_to   TYPE	zexpiry_date,  " Effective To
      kz             TYPE char1,         " Chng Ind
    END OF lty_terr_assn.
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461  by SBEHERA
  FIELD-SYMBOLS:
    <lfs_tab_name> TYPE any, "Table name
    <lfs_field>    TYPE any, "Field name
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
    <lfs_vkorg>      TYPE vkorg,            " Sales Organization
    <lfs_vtweg>      TYPE vtweg,            " Distribution Channel
    <lfs_spart>      TYPE spart,            " Division
    <lfs_kunnr>      TYPE kunnr,            " Customer
    <lfs_territory_id> TYPE zterritory_id,  " Partner Territory ID
    <lfs_partrole>   TYPE zpart_role,       " Partner Role
    <lfs_effective_from> TYPE zeffect_date, " Effective From
    <lfs_effective_to> TYPE zexpiry_date,   " Effective To
    <lfs_tabnewvals> TYPE lty_terr_assn,    " New value table fieldsymbol
    <lfs1_vkorg>      TYPE vkorg,           " Sales Organization
    <lfs1_vtweg>      TYPE vtweg,           " Distribution Channel
    <lfs1_spart>      TYPE spart,           " Division
    <lfs1_kunnr>      TYPE kunnr,           " Division
    <lfs1_territory_id> TYPE zterritory_id, " Partner Territory ID
    <lfs1_partrole>     TYPE zpart_role,    " Partner Role
    <lfs1_zeffect_date> TYPE zeffect_date,  " Effective From
    <lfs1_zexpiry_date> TYPE zexpiry_date,  " Effective To
    <lfs_enh_status> TYPE zdev_enh_status.  " Enhancement Status
  DATA :
    lv_kunnr TYPE kunnr,                                                 " Customer Number
    li_tabnewvals TYPE STANDARD TABLE OF lty_terr_assn,                  " New Value table with chng ind
    lv_ktokd TYPE ktokd,                                                 " KTOKD Value
    lv_flag TYPE flag,                                                   " Flag
    li_enh_status TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Enhancement Status
    lwa_tabnewvals TYPE lty_terr_assn.                                   " New value table wokarea with chng ind
  CONSTANTS :
    lc_ktokd    TYPE z_criteria VALUE 'KTOKD',              " Customer Account Group
    lc_value_s  TYPE char01    VALUE 'S',                   " Value S
    lc_new      TYPE cdchngind VALUE 'N',                   " Chng Ind for New
    lc_upd      TYPE cdchngind VALUE 'U',                   " Chng Ind for Update
    lc_del      TYPE cdchngind VALUE 'D',                   " Chng Ind for Delete
    lc_vkorg    TYPE name_feld VALUE 'VKORG',               " Sales Organization
    lc_vtweg    TYPE name_feld VALUE 'VTWEG',               " Distribution Channel
    lc_spart    TYPE name_feld VALUE 'SPART',               " Division
    lc_kunnr    TYPE name_feld VALUE 'KUNNR',               " Customer
    lc_territory_id    TYPE name_feld VALUE 'TERRITORY_ID', " Partner Territory ID
    lc_partrole        TYPE name_feld VALUE 'PARTROLE',     " Partner Role
    lc_zeffect_date TYPE name_feld VALUE 'EFFECTIVE_FROM',  " Effective From
    lc_enh_no TYPE z_enhancement VALUE 'D2_OTC_EDD_0213',   " Enhancement No
    lc_zexpiry_date TYPE name_feld VALUE 'EFFECTIVE_TO'.    " Effective To
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461  by SBEHERA
* Get table name
 "ASSIGN (master_name) TO <lfs_tab_name>.
  ASSIGN (vim_object) TO <lfs_tab_name>.
  IF sy-subrc IS INITIAL.
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
    ASSIGN COMPONENT lc_vkorg OF STRUCTURE <lfs_tab_name> TO <lfs_vkorg>.
    ASSIGN COMPONENT lc_vtweg OF STRUCTURE <lfs_tab_name> TO <lfs_vtweg>.
    ASSIGN COMPONENT lc_spart OF STRUCTURE <lfs_tab_name> TO <lfs_spart>.
    ASSIGN COMPONENT lc_kunnr OF STRUCTURE <lfs_tab_name> TO <lfs_kunnr>.
    ASSIGN COMPONENT lc_partrole OF STRUCTURE <lfs_tab_name> TO <lfs_partrole>.
    ASSIGN COMPONENT lc_territory_id OF STRUCTURE <lfs_tab_name> TO <lfs_territory_id>.
    ASSIGN COMPONENT lc_zeffect_date OF STRUCTURE <lfs_tab_name> TO <lfs_effective_from>.
    ASSIGN COMPONENT lc_zexpiry_date OF STRUCTURE <lfs_tab_name> TO <lfs_effective_to>.
*  Validation for Customer from table KNVV
    SELECT SINGLE kunnr " Customer
      FROM knvv         " Customer Master Sales Data
      INTO lv_kunnr
      WHERE kunnr = <lfs_kunnr>
        AND vkorg = <lfs_vkorg>
        AND vtweg = <lfs_vtweg>
        AND spart = <lfs_spart>.
    IF sy-subrc IS INITIAL.
*       Do Nothing
    ELSE. " ELSE -> IF sy-subrc IS INITIAL
      MESSAGE e930(zotc_msg) DISPLAY LIKE lc_value_s. " Please Enter a Valid Customer Number
    ENDIF. " IF sy-subrc IS INITIAL
* Get constants from EMI tools
* Call FM to retrieve Enhancement Status
    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
      EXPORTING
        iv_enhancement_no = lc_enh_no
      TABLES
        tt_enh_status     = li_enh_status.
*&      proceed further for checks
*&     If the value is space, then do not proceed further for this
*&     enhancement
* Delete the EMI records where the status is not active
    DELETE li_enh_status WHERE active EQ abap_false.

* Populate Values of Criteria KTOKD
    IF li_enh_status IS NOT INITIAL.
      READ TABLE li_enh_status ASSIGNING <lfs_enh_status> WITH KEY criteria = lc_ktokd.
      IF sy-subrc = 0.
        lv_flag = abap_true.
        lv_ktokd = <lfs_enh_status>-sel_low.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF li_enh_status IS NOT INITIAL
*  Validation for Customer from table KNA1 which does not belongs to Account Group ZREP
    IF lv_flag IS NOT INITIAL.
      CLEAR lv_kunnr.
      SELECT SINGLE kunnr " Customer
        FROM kna1         " General Data in Customer Master
        INTO lv_kunnr
        WHERE kunnr = <lfs_kunnr>
          AND ktokd = lv_ktokd.
      IF sy-subrc IS INITIAL.
        MESSAGE e931(zotc_msg) WITH lv_ktokd            " & & & &
                               DISPLAY LIKE lc_value_s. " Customer is not allowed with Account Group ZREP
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF lv_flag IS NOT INITIAL
*  Validation effective from and effective to
*  Get the new values to be filled
    LOOP AT total.
      IF <action> EQ lc_new OR
       <action> EQ lc_upd OR
       <action> EQ lc_del.
* Populate new field values entered in table maintenance
* from "Extarct" table
        ASSIGN COMPONENT:
          lc_vkorg    OF STRUCTURE <vim_total_struc> TO <lfs1_vkorg>,
          lc_vtweg    OF STRUCTURE <vim_total_struc> TO <lfs1_vtweg>,
          lc_spart    OF STRUCTURE <vim_total_struc> TO <lfs1_spart>,
          lc_kunnr    OF STRUCTURE <vim_total_struc> TO <lfs1_kunnr>,
          lc_territory_id OF STRUCTURE <vim_total_struc> TO <lfs1_territory_id>,
          lc_partrole     OF STRUCTURE <vim_total_struc> TO <lfs1_partrole>,
          lc_zeffect_date OF STRUCTURE <vim_total_struc> TO <lfs1_zeffect_date>,
          lc_zexpiry_date OF STRUCTURE <vim_total_struc> TO <lfs1_zexpiry_date>.


        lwa_tabnewvals-vkorg   = <lfs1_vkorg>.
        lwa_tabnewvals-vtweg   = <lfs1_vtweg>.
        lwa_tabnewvals-spart   = <lfs1_spart>.
        lwa_tabnewvals-kunnr   = <lfs1_kunnr>.
        lwa_tabnewvals-territory_id   = <lfs1_territory_id>.
        lwa_tabnewvals-partrole       = <lfs1_partrole>.
        lwa_tabnewvals-effective_from = <lfs1_zeffect_date>.
        lwa_tabnewvals-effective_to   = <lfs1_zexpiry_date>.
        lwa_tabnewvals-kz             = <action>.
        APPEND lwa_tabnewvals TO li_tabnewvals.
        CLEAR lwa_tabnewvals.
      ENDIF. " IF <action> EQ lc_new OR
    ENDLOOP. " LOOP AT total
    LOOP AT extract .
      READ TABLE li_tabnewvals INTO lwa_tabnewvals INDEX 1.
*      READ TABLE li_tabnewvals INTO lwa_tabnewvals
*                               WITH KEY vkorg = extract-vkorg
*                                        vtweg = extract-vtweg
*                                        spart = extract-spart
*                                        kunnr = extract-kunnr.
      IF sy-subrc = 0.
        IF <lfs_vkorg> = lwa_tabnewvals-vkorg AND
          <lfs_vtweg> = lwa_tabnewvals-vtweg AND
          <lfs_spart> = lwa_tabnewvals-spart AND
          <lfs_kunnr> = lwa_tabnewvals-kunnr AND
          <lfs_territory_id> = lwa_tabnewvals-territory_id AND
          <lfs_effective_from> = lwa_tabnewvals-effective_from AND
          <lfs_effective_to> = lwa_tabnewvals-effective_to.
          MESSAGE e932(zotc_msg) DISPLAY LIKE lc_value_s. " Entry already exits
        ENDIF. " IF <lfs_vkorg> = lwa_tabnewvals-vkorg AND
      ENDIF. " IF sy-subrc = 0
    ENDLOOP. " LOOP AT extract
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461  by SBEHERA
* Record User ID
    ASSIGN COMPONENT 'ZZ_CREATED_BY' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-uname.
    ENDIF. " IF sy-subrc IS INITIAL

* Record Date
    ASSIGN COMPONENT 'ZZ_CREATED_ON' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-datum.
    ENDIF. " IF sy-subrc IS INITIAL

* Record Time
    ASSIGN COMPONENT 'ZZ_CREATED_AT' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-uzeit.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL

ENDFORM. "f_track_create
*&---------------------------------------------------------------------*
*&      Form  F_TRACK_CHANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_track_change.
  FIELD-SYMBOLS:
      <lfs_tab_name> TYPE any, "Table name
      <lfs_field>    TYPE any. "Field name

* Get table name
 "ASSIGN (master_name) TO <lfs_tab_name>.
  ASSIGN (vim_object) TO <lfs_tab_name>.

  IF sy-subrc IS INITIAL.
* Record User ID
    ASSIGN COMPONENT 'ZZ_CHANGED_BY' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-uname.
    ENDIF. " IF sy-subrc IS INITIAL

* Record Date
    ASSIGN COMPONENT 'ZZ_CHANGED_ON' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-datum.
    ENDIF. " IF sy-subrc IS INITIAL

* Record Time
    ASSIGN COMPONENT 'ZZ_CHANGED_AT' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-uzeit.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL
ENDFORM. "F_TRACK_CHANGE
