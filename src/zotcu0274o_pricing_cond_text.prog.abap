*&---------------------------------------------------------------------*
*&  Include           ZOTCU0274O_PRICING_COND_TEXT
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCU0274O_PRICING_COND_TEXT(User Exit)                *
* TITLE      :  D2_OTC_EDD_0274_Pricing upload program for pricing cond*
* DEVELOPER  :  Dhananjoy Moirangthem                                  *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_EDD_0274                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: Pricing Upload program for pricing condition            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER     TRANSPORT  DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 26-Oct-2015  DMOIRAN   E2DK913959 INITIAL DEVELOPMENT                *
* Defect 1209 PGL B development. Added logic for pricing condition     *
* text.                                                                *
* 12-Nov-2018  DDWIVED   E2DK920513 Defect# 7073: R6 Regression Testing*
*                                   of D3_OTC_EDD_0274_Price upload    *
*                                   program for pricing conditions     *
*&---------------------------------------------------------------------*
* Local variables declaration
  DATA:
    li_status       TYPE STANDARD TABLE OF zdev_enh_status, "Enhancement Status table
    lwa_e1komg      TYPE e1komg,                            " Filter segment with separated condition key
    lwa_e1konh      TYPE e1konh,                            " Filter segment with separated condition key
    lwa_z1otc_konp_ext TYPE z1otc_konp_ext,                 " KONP Extension
    lv_table        TYPE tablenam,                          " Name of table to be processed
    lref_row        TYPE REF TO cl_abap_structdescr,        " Runtime Type Services
    li_component    TYPE cl_abap_structdescr=>component_table,
    lref_line_type  TYPE REF TO cl_abap_structdescr,        " Runtime Type Services
    lref_dyn_wa     TYPE REF TO data,                       "  class
    lv_where        TYPE string,
    lv_knumh        TYPE knumh,                             " Condition record number
    lx_header       TYPE thead,                             " SAPscript: Text Header
    li_tline        TYPE STANDARD TABLE OF tline,           " SAPscript: Text Lines
    lv_tdname       TYPE tdobname,                          " Name
    lv_tdid         TYPE tdid.                              " Text ID

* Field Symbol
  FIELD-SYMBOLS:
*    <lfs_status> TYPE zdev_enh_status, " Enhancement Status
    <lfs_data>   TYPE edidd,           " Data record (IDoc)
    <lfs_component> TYPE cl_abap_structdescr=>component,
    <lfs_dyn_wa>      TYPE any,
    <lfs_tline>      TYPE tline.       " SAPscript: Text Lines

* Local constant
  CONSTANTS:
      lc_enh_no      TYPE z_enhancement  VALUE 'D2_OTC_EDD_0274',   " Enhancement No.
      lc_null        TYPE z_criteria     VALUE 'NULL',              " Enh. Criteria
      lc_seg_text    TYPE edilsegtyp     VALUE 'Z1OTC_KONP_EXT',    " Segment type
      lc_ext         TYPE edi_cimtyp     VALUE 'ZOTCE_COND_A01_01', " Extension
      lc_e1komg      TYPE edilsegtyp     VALUE 'E1KOMG',            " Segment type
      lc_e1konh      TYPE edilsegtyp     VALUE 'E1KONH',            " Segment type
      lc_a           TYPE char01         VALUE 'A',                 " A of type CHAR01
      lc_dot         TYPE char01         VALUE '.',                 " Dot of type CHAR01
      lc_konp        TYPE tdobject       VALUE 'KONP',  " Texts: Application Object
      lc_01          TYPE kopos          VALUE '01',    " Sequential number of the condition
      lc_mandt       TYPE fieldname      VALUE 'MANDT', " Field Name
      lc_kappl       TYPE fieldname      VALUE 'KAPPL', " Field Name
      lc_kschl       TYPE fieldname      VALUE 'KSCHL', " Field Name
      lc_datbi       TYPE fieldname      VALUE 'DATBI', " Field Name
      lc_datab       TYPE fieldname      VALUE 'DATAB', " Field Name
      lc_knumh       TYPE fieldname      VALUE 'KNUMH'. " Field Name

* Call to EMI Function Module To Get List Of EMI Statuses
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_no
    TABLES
      tt_enh_status     = li_status. "Enhancement status table

* Delete the entries which are not active and pick all the active entries.
  DELETE li_status WHERE active = space.
* check if EMI project is active.
  READ TABLE li_status WITH KEY criteria = lc_null
                 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
* Logic required for only  'ZOTCE_COND_A01_01' Extension IDoc type
    IF idoc_control-cimtyp = lc_ext.
* check if text segment is there
      READ TABLE idoc_data WITH KEY segnam = lc_seg_text
                       TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
* Find the condition record number
        READ TABLE idoc_data ASSIGNING <lfs_data>
                    WITH KEY segnam = lc_e1komg.
        IF sy-subrc = 0.
          lwa_e1komg = <lfs_data>-sdata.
        ENDIF. " IF sy-subrc = 0
* Read the E1KONH segment
        READ TABLE idoc_data ASSIGNING <lfs_data>
                    WITH KEY segnam = lc_e1konh.
        IF sy-subrc = 0.
          lwa_e1konh = <lfs_data>-sdata.
        ENDIF. " IF sy-subrc = 0
* find the condition table
        IF lwa_e1komg-kotabnr IS NOT INITIAL.
          CONCATENATE lc_a lwa_e1komg-kotabnr INTO lv_table.
        ELSE. " ELSE -> IF lwa_e1komg-kotabnr IS NOT INITIAL
          RETURN.

        ENDIF. " IF lwa_e1komg-kotabnr IS NOT INITIAL

        IF lv_table IS NOT INITIAL.
*  Get Structure of the table "   Condition table .
          lref_row ?= cl_abap_typedescr=>describe_by_name( p_name = lv_table ).


          IF lref_row IS NOT INITIAL.
            li_component = lref_row->get_components( ).
          ENDIF. " IF lref_row IS NOT INITIAL
* remove out fields which are not needed.
          DELETE li_component WHERE name = lc_mandt
                                 OR name = lc_kappl
                                 OR name = lc_kschl
                                 OR name = lc_datbi
                                 OR name = lc_datab
                                 OR name = lc_knumh.
          IF li_component IS NOT INITIAL.
* Build the dynamic structure
            TRY .
                lref_line_type = cl_abap_structdescr=>create(
                                    p_components = li_component
                                    p_strict = cl_abap_structdescr=>false ).
              CATCH cx_sy_struct_creation .
                RETURN.
            ENDTRY.

            IF lref_line_type IS NOT INITIAL.
              CREATE DATA lref_dyn_wa TYPE HANDLE lref_line_type. " Internal ID of an object
              ASSIGN lref_dyn_wa->* TO <lfs_dyn_wa>.
*VAKEY in IDoc is combination of keys in the condition table. So, break down to individual
* fields so that the condition record which has been used can be found.
              IF <lfs_dyn_wa> IS ASSIGNED.
                <lfs_dyn_wa> = lwa_e1komg-vakey.
* build up the dynamic where clause
                lv_where =  'KAPPL = lwa_e1komg-kappl and KSCHL = lwa_e1komg-KSCHL'.
                LOOP AT li_component ASSIGNING <lfs_component>.
                  CONCATENATE lv_where ' and ' <lfs_component>-name ' = <lfs_dyn_wa>-'
                              <lfs_component>-name INTO lv_where RESPECTING BLANKS.

                ENDLOOP. " LOOP AT li_component ASSIGNING <lfs_component>

* put the date
                IF lwa_e1konh-datab IS NOT INITIAL.
                  CONCATENATE lv_where ' and DATAB = lwa_e1konh-DATAB'
                              INTO lv_where RESPECTING BLANKS.
                ENDIF. " IF lwa_e1konh-datab IS NOT INITIAL

                IF lwa_e1konh-datbi IS NOT INITIAL.
                  CONCATENATE lv_where ' and DATBI = lwa_e1konh-DATBI'
                              INTO lv_where RESPECTING BLANKS.
                ENDIF. " IF lwa_e1konh-datbi IS NOT INITIAL
* add dot
*                CONCATENATE lv_where lc_dot INTO lv_where. (-) ddwivedi for #Defect #7073 D3_OTC_EDD_0274_Price upload

                SELECT SINGLE knumh
                       FROM (lv_table)
                       INTO lv_knumh
                       WHERE (lv_where).
                IF sy-subrc NE 0.
                  RETURN.
                ENDIF. " IF sy-subrc NE 0

              ENDIF. " IF <lfs_dyn_wa> IS ASSIGNED
            ENDIF. " IF lref_line_type IS NOT INITIAL
          ENDIF. " IF li_component IS NOT INITIAL

        ENDIF. " IF lv_table IS NOT INITIAL

* Get the TEXT id of the pricing condition text for the conditon type
        SELECT SINGLE tdid " Text ID for text edit control
               FROM t685a  " Conditions: Types: Additional Price Element Data
               INTO lv_tdid
               WHERE kappl = lwa_e1komg-kappl
                  AND kschl = lwa_e1komg-kschl.
        IF sy-subrc NE 0.
          RETURN.
        ENDIF. " IF sy-subrc NE 0

        LOOP AT idoc_data ASSIGNING <lfs_data>.

          IF <lfs_data>-segnam NE lc_seg_text.
            CONTINUE.
          ELSE. " ELSE -> IF <lfs_data>-segnam NE lc_seg_text

* update the pricing condition text
            lwa_z1otc_konp_ext = <lfs_data>-sdata.
            IF lwa_z1otc_konp_ext-ztext IS INITIAL.
              CONTINUE.
            ELSE. " ELSE -> IF lwa_z1otc_konp_ext-ztext IS INITIAL

              CLEAR lv_tdname.
              CONCATENATE lv_knumh lc_01 INTO lv_tdname.
              lx_header-tdobject = lc_konp.
              lx_header-tdname = lv_tdname.
              lx_header-tdid = lv_tdid.
              lx_header-tdspras = sy-langu.
* only single line of 72 characters only
              CLEAR li_tline.
              APPEND INITIAL LINE TO li_tline ASSIGNING <lfs_tline>.
              IF <lfs_tline> IS ASSIGNED.
                <lfs_tline>-tdformat = '*'.
                <lfs_tline>-tdline = lwa_z1otc_konp_ext-ztext.
              ENDIF. " IF <lfs_tline> IS ASSIGNED

              CALL FUNCTION 'SAVE_TEXT'
                EXPORTING
                  header          = lx_header
                  savemode_direct = abap_true
                TABLES
                  lines           = li_tline
                EXCEPTIONS
                  id              = 1
                  language        = 2
                  name            = 3
                  object          = 4
                  OTHERS          = 5.

            ENDIF. " IF lwa_z1otc_konp_ext-ztext IS INITIAL

          ENDIF. " IF <lfs_data>-segnam NE lc_seg_text
        ENDLOOP. " LOOP AT idoc_data ASSIGNING <lfs_data>

      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF idoc_control-cimtyp = lc_ext
  ENDIF. " IF sy-subrc = 0
