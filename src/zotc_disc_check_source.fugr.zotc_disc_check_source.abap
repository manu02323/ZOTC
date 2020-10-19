FUNCTION zotc_disc_check_source.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_COND) TYPE  CMP_T_COND
*"     REFERENCE(IM_MATERIAL) TYPE  MATNR
*"     REFERENCE(IM_VKORG) TYPE  VKORG
*"     REFERENCE(IM_VTWEG) TYPE  VTWEG
*"     REFERENCE(IM_SPART) TYPE  SPART
*"     REFERENCE(IM_KUNAG) TYPE  KUNAG
*"     REFERENCE(IM_KUNWE) TYPE  KUNWE
*"  EXPORTING
*"     REFERENCE(EX_BEZEI) TYPE  STRING
*"     REFERENCE(EX_RET) TYPE  BAPIRET2
*"     REFERENCE(EX_DATBI) TYPE  KODATBI
*"     REFERENCE(EX_DATAB) TYPE  KODATAB
*"----------------------------------------------------------------------
************************************************************************
* PROGRAM    :  ZOTC_DISC_CHECK_SOURCE                                 *
* TITLE      :  Check Source Price                                     *
* DEVELOPER  :  Srinivasa G                                            *
* OBJECT TYPE:  Function Module                                        *
* SAP RELEASE:  SAP ECC                                                *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_MDD_002                                              *
*----------------------------------------------------------------------*
* DESCRIPTION:This function Module is used to determine the source of  *
*             Price for Fiori Price Check Application                  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER      TRANSPORT  DESCRIPTION                       *
* ===========  ========  ==========  ==================================*
* 20-May-2019  U033814   E2DK923449   Initial Development              *
*----------------------------------------------------------------------*
* 06-Aug-2019  U033814   E2DK923449   Performance Issues Defect # 10208*
*----------------------------------------------------------------------*

  TYPES : BEGIN OF lty_kschl,
            sign   TYPE char1, " Sign of type CHAR1
            option TYPE char2, " Option of type CHAR2
            low    TYPE kschl, " Condition Type
            high   TYPE kschl, " Condition Type
          END OF lty_kschl.


  CONSTANTS: lc_project TYPE z_enhancement VALUE 'OTC_MDD_0002',   " Enhancement No.
             lc_null    TYPE z_criteria    VALUE 'NULL',           " Field name
             lc_kschl   TYPE z_criteria    VALUE 'DISC_CONDITION'. " Field name


* Local Data Declaration
  DATA: lwa_cond      TYPE bapicond,                          " Data record (IDoc)
        lv_tabname    TYPE char4,                             " Tabname of type CHAR4
        lv_tabix      TYPE sytabix,                           " Index of Internal Tables
        lv_name       TYPE ddobjname,                         " Name of ABAP Dictionary Object
*- Begin of insert - U033814 - Defect # 10208.
        lv_string     TYPE string,
        lv_string2    TYPE string,
*- End of insert - U033814 - Defect # 10208.
        lv_kvgr1      TYPE kvgr1,                             " Customer group 1
        lv_bezei      TYPE bezei,                             " Name of the controlling area
        lv_flag1      TYPE boolean,                           " Boolean Variable (X=True, -=False, Space=Unknown)
        lv_flag2      TYPE boolean,                           " Boolean Variable (X=True, -=False, Space=Unknown)
        lv_length     TYPE ddleng,                            " Length (No. of Characters)
        ref_tabletype TYPE REF TO cl_abap_tabledescr,         " Runtime Type Services
        ref_rowtype   TYPE REF TO cl_abap_structdescr,        " Runtime Type Services
        li_itab       TYPE REF TO data,                       " Class
        lwa_itab      TYPE REF TO data,                       " Class
        li_status     TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
        li_kschl      TYPE STANDARD TABLE OF lty_kschl,       " Condition Type
        lwa_t682i     TYPE t682i,                             " Conditions: Access Sequences (Generated Form)
        lwa_kschl     TYPE lty_kschl,
        li_fields     TYPE STANDARD TABLE OF dfies,           " Table for Internal Table fields
        lt_cond       TYPE STANDARD TABLE OF bapicond,        " Communication Fields for Maintaining Conditions in the Order
        lwa_fields    TYPE dfies.                             " DD Interface: Table Fields for DDIF_FIELDINFO_GET

* Local Field Symbol Declaration
  FIELD-SYMBOLS: <lfs_itab>   TYPE ANY TABLE,       " Dynamic Internal Table
                 <lfs_work>   TYPE any,             " Dynamic Workarea
                 <lfs_field>  TYPE any,             " Dynamic Field
                 <lfs_datbi>  TYPE any,             " Dynamic Field
                 <lfs_datab>  TYPE any,             " Dynamic Field
                 <lfs_fields> TYPE dfies,           " DD Interface: Table Fields for DDIF_FIELDINFO_GET
                 <lfs_status> TYPE zdev_enh_status. " Enhancement Status



  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_project
    TABLES
      tt_enh_status     = li_status.

*-- Check, if the Enh is active
* 1. If the value is: “X”, the overall Enhancement is active and can
*    proceed further for checks
  DELETE li_status WHERE active = abap_false.

  READ TABLE li_status WITH KEY criteria = lc_null "KSCHL_2
                       TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
    LOOP AT li_status ASSIGNING <lfs_status>
                        WHERE criteria = lc_kschl.
      lwa_kschl-sign   = <lfs_status>-sel_sign.
      lwa_kschl-option = <lfs_status>-sel_option.
      lwa_kschl-low    = <lfs_status>-sel_low.
      APPEND lwa_kschl TO li_kschl.
      CLEAR lwa_kschl.
    ENDLOOP. " LOOP AT li_status ASSIGNING <lfs_status>
  ENDIF. " IF sy-subrc EQ 0

  lt_cond[] = it_cond[].
  DELETE lt_cond WHERE cond_type NOT IN li_kschl.
  DELETE lt_cond WHERE condisacti EQ abap_true.

  CHECK lt_cond IS NOT INITIAL.
** Getting the Condition Record Table name

  LOOP AT lt_cond INTO lwa_cond.
    IF lwa_cond-cond_type  NE 'ZLMX'." and lwa_cond-CONBASEVAL gt 0.
      SELECT SINGLE * FROM t682i INTO lwa_t682i WHERE kvewe = 'A'
                                                  AND kappl = lwa_cond-applicatio
                                                  AND kozgf = lwa_cond-cond_type
                                                  AND kolnr = lwa_cond-access_seq.
      IF sy-subrc EQ 0.
        CONCATENATE   'A'  lwa_t682i-kotabnr INTO lv_tabname.
        EXIT.
      ENDIF. " IF sy-subrc EQ 0
    ELSE. " ELSE -> IF lwa_cond-cond_type NE 'ZLMX'
      IF lwa_cond-cond_value NE 0.
        READ TABLE it_cond INTO lwa_cond WITH KEY cond_type = 'ZB00'.
        IF sy-subrc = 0.
          SELECT SINGLE * FROM t682i INTO lwa_t682i WHERE kvewe = 'A'
                                                      AND kappl = lwa_cond-applicatio
                                                      AND kozgf = lwa_cond-cond_type
                                                      AND kolnr = lwa_cond-access_seq.
          IF sy-subrc EQ 0.
            CONCATENATE   'A'  lwa_t682i-kotabnr INTO lv_tabname.
            EXIT.
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF sy-subrc EQ 0
      ENDIF.
    ENDIF. " IF lwa_cond-cond_type NE 'ZLMX'
  ENDLOOP. " LOOP AT lt_cond INTO lwa_cond

  IF  lv_tabname NE space.
    lv_name = lv_tabname.
* Getting the field names of the dynamic table
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = lv_name
      TABLES
        dfies_tab      = li_fields
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
* No need to handle the -ve case

    IF sy-subrc = 0.
      LOOP AT li_fields INTO lwa_fields.
*- Begin of insert - U033814 - Defect # 10208.
        CASE lwa_fields-fieldname.
          WHEN 'KAPPL'.
            CLEAR lv_string2.
            CONCATENATE TEXT-001 'V' TEXT-001 INTO lv_string2.
            CONCATENATE lv_string 'KAPPL EQ' lv_string2 INTO lv_string SEPARATED BY space.
          WHEN 'KSCHL'.
            CLEAR lv_string2.
            IF lv_string IS NOT INITIAL.
              CONCATENATE lv_string 'AND' INTO lv_string SEPARATED BY space.
            ENDIF. " IF lv_string IS NOT INITIAL AND lwa_e1komg-kschl IS NOT INITIAL
            CONCATENATE TEXT-001 lwa_cond-cond_type TEXT-001 INTO lv_string2.
            CONCATENATE lv_string 'KSCHL EQ' lv_string2 INTO lv_string SEPARATED BY space.
          WHEN 'MATNR'.
            CLEAR lv_string2.
            IF lv_string IS NOT INITIAL.
              CONCATENATE lv_string 'AND' INTO lv_string SEPARATED BY space.
            ENDIF. " IF lv_string IS NOT INITIAL AND lwa_e1komg-kschl IS NOT INITIAL
            CONCATENATE TEXT-001 im_material TEXT-001 INTO lv_string2.
            CONCATENATE lv_string 'MATNR EQ' lv_string2 INTO lv_string SEPARATED BY space.
          WHEN 'VKORG'.
            CLEAR lv_string2.
            IF lv_string IS NOT INITIAL.
              CONCATENATE lv_string 'AND' INTO lv_string SEPARATED BY space.
            ENDIF. " IF lv_string IS NOT INITIAL AND lwa_e1komg-kschl IS NOT INITIAL
            CONCATENATE TEXT-001 im_vkorg TEXT-001 INTO lv_string2.
            CONCATENATE lv_string 'VKORG EQ' lv_string2 INTO lv_string SEPARATED BY space.

          WHEN 'VTWEG'.
            CLEAR lv_string2.
            IF lv_string IS NOT INITIAL.
              CONCATENATE lv_string 'AND' INTO lv_string SEPARATED BY space.
            ENDIF. " IF lv_string IS NOT INITIAL AND lwa_e1komg-kschl IS NOT INITIAL
            CONCATENATE TEXT-001 im_vtweg TEXT-001 INTO lv_string2.
            CONCATENATE lv_string 'VTWEG EQ' lv_string2 INTO lv_string SEPARATED BY space.

          WHEN 'SPART'.
            CLEAR lv_string2.
            IF lv_string IS NOT INITIAL.
              CONCATENATE lv_string 'AND' INTO lv_string SEPARATED BY space.
            ENDIF. " IF lv_string IS NOT INITIAL AND lwa_e1komg-kschl IS NOT INITIAL
            CONCATENATE TEXT-001 im_spart TEXT-001 INTO lv_string2.
            CONCATENATE lv_string 'SPART EQ' lv_string2 INTO lv_string SEPARATED BY space.

          WHEN 'KUNNR'.
            CLEAR lv_string2.
            IF lv_string IS NOT INITIAL.
              CONCATENATE lv_string 'AND' INTO lv_string SEPARATED BY space.
            ENDIF. " IF lv_string IS NOT INITIAL AND lwa_e1komg-kschl IS NOT INITIAL
            CONCATENATE TEXT-001 im_kunag TEXT-001 INTO lv_string2.
            CONCATENATE lv_string 'KUNNR EQ' lv_string2 INTO lv_string SEPARATED BY space.

          WHEN 'KUNAG'.
            CLEAR lv_string2.
            IF lv_string IS NOT INITIAL.
              CONCATENATE lv_string 'AND' INTO lv_string SEPARATED BY space.
            ENDIF. " IF lv_string IS NOT INITIAL AND lwa_e1komg-kschl IS NOT INITIAL
            CONCATENATE TEXT-001 im_kunag TEXT-001 INTO lv_string2.
            CONCATENATE lv_string 'KUNAG EQ' lv_string2 INTO lv_string SEPARATED BY space.

          WHEN 'KUNWE'.
            CLEAR lv_string2.
            IF lv_string IS NOT INITIAL.
              CONCATENATE lv_string 'AND' INTO lv_string SEPARATED BY space.
            ENDIF. " IF lv_string IS NOT INITIAL AND lwa_e1komg-kschl IS NOT INITIAL
            CONCATENATE TEXT-001 im_kunwe TEXT-001 INTO lv_string2.
            CONCATENATE lv_string 'KUNWE EQ' lv_string2 INTO lv_string SEPARATED BY space.

          WHEN 'KFRST'.
            CLEAR lv_string2.
            IF lv_string IS NOT INITIAL.
              CONCATENATE lv_string 'AND' INTO lv_string SEPARATED BY space.
            ENDIF.
            CONCATENATE TEXT-001 space TEXT-001 INTO lv_string2.
            CONCATENATE lv_string 'KFRST EQ' lv_string2 INTO lv_string SEPARATED BY space.

          WHEN OTHERS.

        ENDCASE.
*- Begin of insert - U033814 - Defect # 10208.
        lv_length = lv_length + lwa_fields-leng.
        IF lwa_fields-fieldname =  'ZZKVGR1'.
          lv_flag1 = abap_true.
        ENDIF. " IF lwa_fields-fieldname = 'ZZKVGR1'
        IF lwa_fields-fieldname =  'ZZKVGR2'.
          lv_flag2 = abap_true.
        ENDIF. " IF lwa_fields-fieldname = 'ZZKVGR2'
      ENDLOOP. " LOOP AT li_fields INTO lwa_fields
    ENDIF. " IF sy-subrc = 0
*- Begin of insert - U033814 - Defect # 10208.
    CLEAR lv_string2.
    IF lv_string IS NOT INITIAL.
      CONCATENATE lv_string 'AND' INTO lv_string SEPARATED BY space.
    ENDIF. " IF lv_string IS NOT INITIAL AND lwa_e1komg-kschl IS NOT INITIAL

    CONCATENATE TEXT-001 sy-datum TEXT-001 INTO lv_string2.
    CONCATENATE lv_string 'DATBI GE' lv_string2 INTO lv_string SEPARATED BY space.
    CONCATENATE lv_string 'AND' INTO lv_string SEPARATED BY space.
    CONCATENATE lv_string 'DATAB LE' lv_string2 INTO lv_string SEPARATED BY space.
    CLEAR lv_string2.

    IF lv_string IS NOT INITIAL.
      CONCATENATE lv_string 'AND' INTO lv_string SEPARATED BY space.
    ENDIF. " IF lv_string IS NOT INITIAL AND lwa_e1komg-kschl IS NOT INITIAL
    CONCATENATE TEXT-001 lwa_cond-cond_no TEXT-001 INTO lv_string2.
    CONCATENATE lv_string 'KNUMH EQ' lv_string2 INTO lv_string SEPARATED BY space.
*- End of insert - U033814 - Defect # 10208.

***>>> Begin of logic for Creation of Dynamic Internal table
    ref_rowtype ?= cl_abap_typedescr=>describe_by_name( p_name = lv_tabname ).
    ref_tabletype = cl_abap_tabledescr=>create( p_line_type = ref_rowtype ).
    CREATE DATA li_itab TYPE HANDLE ref_tabletype.
    CREATE DATA lwa_itab TYPE HANDLE ref_rowtype.
    ASSIGN li_itab->* TO <lfs_itab>.
    ASSIGN lwa_itab->* TO <lfs_work>.

    IF lv_flag1 IS NOT INITIAL OR lv_flag2 IS NOT INITIAL.

      IF lv_flag1 IS NOT INITIAL.
*- Begin of comment - U033814 - Defect # 10208.
*        SELECT SINGLE * FROM (lv_tabname) INTO <lfs_work> WHERE kappl = 'V'
*                                                        AND kschl = lwa_cond-cond_type
*                                                        AND datbi GE sy-datum
*                                                        AND datab LE sy-datum
*                                                        AND knumh = lwa_cond-cond_no.
*- End of comment - U033814 - Defect # 10208.
*- Begin of insert - U033814 - Defect # 10208.
        SELECT SINGLE * FROM (lv_tabname) INTO <lfs_work> WHERE (lv_string).
*- End of insert - U033814 - Defect # 10208.
        IF sy-subrc EQ 0.
          ASSIGN COMPONENT  'ZZKVGR1' OF STRUCTURE  <lfs_work> TO <lfs_field>.
          ASSIGN COMPONENT  'DATBI'   OF STRUCTURE  <lfs_work> TO <lfs_datbi>.
          ASSIGN COMPONENT  'DATAB'   OF STRUCTURE  <lfs_work> TO <lfs_datab>.
          ex_datbi = <lfs_datbi>.
          ex_datab = <lfs_datab>.

        ENDIF. " IF sy-subrc EQ 0
        IF <lfs_field> IS ASSIGNED.
          SELECT SINGLE bezei FROM tvv1t INTO lv_bezei WHERE spras EQ sy-langu
                                                         AND kvgr1 EQ <lfs_field>.
          CONCATENATE 'GRP1' <lfs_field> lv_bezei INTO ex_bezei SEPARATED BY space.
        ENDIF. " IF <lfs_field> IS ASSIGNED
      ELSE. " ELSE -> IF lv_flag1 IS NOT INITIAL
*- Begin of comment - U033814 - Defect # 10208.
*        SELECT SINGLE * FROM (lv_tabname) INTO <lfs_work> WHERE kappl = 'V'
*                                                        AND kschl = lwa_cond-cond_type
*                                                        AND datbi GE sy-datum
*                                                        AND datab LE sy-datum
*                                                        AND knumh = lwa_cond-cond_no.
*- End of comment - U033814 - Defect # 10208.
*- Begin of insert - U033814 - Defect # 10208.
        SELECT SINGLE * FROM (lv_tabname) INTO <lfs_work> WHERE (lv_string).
*- End of insert - U033814 - Defect # 10208.
        IF sy-subrc EQ 0.
          ASSIGN COMPONENT  'ZZKVGR2' OF STRUCTURE  <lfs_work> TO <lfs_field>.
          ASSIGN COMPONENT  'DATBI'   OF STRUCTURE  <lfs_work> TO <lfs_datbi>.
          ASSIGN COMPONENT  'DATAB'   OF STRUCTURE  <lfs_work> TO <lfs_datab>.
          ex_datbi = <lfs_datbi>.
          ex_datab = <lfs_datab>.
        ENDIF. " IF sy-subrc EQ 0
        IF <lfs_field> IS ASSIGNED.
          SELECT SINGLE bezei FROM tvv2t INTO lv_bezei WHERE spras EQ sy-langu
                                                         AND kvgr2 EQ <lfs_field>.
          CONCATENATE 'GRP2' <lfs_field> lv_bezei INTO ex_bezei SEPARATED BY space.
        ENDIF. " IF <lfs_field> IS ASSIGNED
      ENDIF. " IF lv_flag1 IS NOT INITIAL
    ELSE. " ELSE -> IF lv_flag1 IS NOT INITIAL OR lv_flag2 IS NOT INITIAL
*- Begin of comment - U033814 - Defect # 10208.
*      SELECT SINGLE * FROM (lv_tabname) INTO <lfs_work> WHERE kappl = 'V'
*                                                      AND kschl = lwa_cond-cond_type
*                                                      AND datbi GE sy-datum
*                                                      AND datab LE sy-datum
*                                                      AND knumh = lwa_cond-cond_no.
*- End of comment - U033814 - Defect # 10208.
*- Begin of insert - U033814 - Defect # 10208.
      SELECT SINGLE * FROM (lv_tabname) INTO <lfs_work> WHERE (lv_string).
*- End of insert - U033814 - Defect # 10208.
      IF sy-subrc EQ 0.
        ASSIGN COMPONENT  'DATBI'   OF STRUCTURE  <lfs_work> TO <lfs_datbi>.
        ASSIGN COMPONENT  'DATAB'   OF STRUCTURE  <lfs_work> TO <lfs_datab>.
        ex_datbi = <lfs_datbi>.
        ex_datab = <lfs_datab>.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF lv_flag1 IS NOT INITIAL OR lv_flag2 IS NOT INITIAL
  ENDIF. " IF lv_tabname IS NOT INITIAL
ENDFUNCTION.
