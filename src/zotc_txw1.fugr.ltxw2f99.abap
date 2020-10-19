*----------------------------------------------------------------------*
***INCLUDE LTXW2F99 .
* This include contains coding that is release dependent
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F99_DDIF_FIELDINFO_GET
*&---------------------------------------------------------------------*
*       get field info
*----------------------------------------------------------------------*
*      -->P_TABNAME   table/structure name
*      <--P_FIELDTAB  field tab
*      <--P_SUBRC     return code
*----------------------------------------------------------------------*
FORM F99_DDIF_FIELDINFO_GET
     TABLES   P_FIELDTAB       STRUCTURE DFIES
     USING    VALUE(P_TABNAME) TYPE C
     CHANGING P_SUBRC          LIKE SY-SUBRC.

  DATA: TABNAME  LIKE DFIES-TABNAME,
        WA_DFIES LIKE DFIES.


  TABNAME = P_TABNAME.
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      TABNAME   = TABNAME                                "#EC DOM_EQUAL
    TABLES
      DFIES_TAB = P_FIELDTAB
    EXCEPTIONS
      OTHERS    = 5.
  IF SY-SUBRC <> 0.                    "try without texts
    CALL FUNCTION 'DDIF_NAMETAB_GET'
      EXPORTING
        TABNAME   = TABNAME                              "#EC DOM_EQUAL
      TABLES
        DFIES_TAB = P_FIELDTAB
      EXCEPTIONS
        OTHERS    = 5.
    P_SUBRC = SY-SUBRC.
  ELSE.
    P_SUBRC = SY-SUBRC.
*   check if all texts are available
    LOOP AT P_FIELDTAB WHERE LANGU IS INITIAL.
*     read text from corresponding source table field
      SELECT SRC_STRUCT FROM TXW_C_SOEX INTO TABNAME
             WHERE EXP_STRUCT = P_TABNAME.
        CALL FUNCTION 'DDIF_FIELDINFO_GET'
             EXPORTING
                  TABNAME        = TABNAME               "#EC DOM_EQUAL
*                 LANGU          = SY-LANGU
                  LFIELDNAME     = P_FIELDTAB-LFIELDNAME
             IMPORTING
                  DFIES_WA       = WA_DFIES
             EXCEPTIONS
                  OTHERS         = 3.
        IF SY-SUBRC = 0.
          P_FIELDTAB-FIELDTEXT = WA_DFIES-FIELDTEXT.
          P_FIELDTAB-REPTEXT = WA_DFIES-REPTEXT.
          P_FIELDTAB-SCRTEXT_S = WA_DFIES-SCRTEXT_S.
          P_FIELDTAB-SCRTEXT_M = WA_DFIES-SCRTEXT_M.
          P_FIELDTAB-SCRTEXT_L = WA_DFIES-SCRTEXT_L.
          MODIFY P_FIELDTAB.
          EXIT.
        ENDIF.
      ENDSELECT.
    ENDLOOP.
  ENDIF.

ENDFORM.                               " F99_DDIF_FIELDINFO_GET
*&---------------------------------------------------------------------*
*&      Form  F99_DDIF_DOMA_GET
*&---------------------------------------------------------------------*
*       get domain values
*----------------------------------------------------------------------*
*      -->P_DD07V_TAB
*      -->P_DOMAIN
*----------------------------------------------------------------------*
FORM F99_DDIF_DOMA_GET
     TABLES P_DD07V_TAB     STRUCTURE DD07V
     USING  VALUE(P_DOMAIN) TYPE C.

  DATA: DOMAIN LIKE DCOBJDEF-NAME.

  DOMAIN = P_DOMAIN.
  CALL FUNCTION 'DDIF_DOMA_GET'
    EXPORTING
      NAME      = DOMAIN
      LANGU     = SY-LANGU
    TABLES
      DD07V_TAB = P_DD07V_TAB.

ENDFORM.                               " F99_DDIF_DOMA_GET
*&---------------------------------------------------------------------*
*&      Form  F99_GET_FIELD_DESCRIPTION
*&---------------------------------------------------------------------*
*       get field description
*----------------------------------------------------------------------*
*      -->P_TABLE  table                                               *
*      -->P_FIELD  field                                               *
*      -->P_LANGU  language                                            *
*      <--P_TEXT   description                                         *
*----------------------------------------------------------------------*
FORM F99_GET_FIELD_DESCRIPTION
     USING    P_TABLE TYPE C
              P_FIELD TYPE C
              P_LANGU LIKE SY-LANGU
     CHANGING P_TEXT  TYPE C.

  CONSTANTS: ENGLISH LIKE SY-LANGU VALUE 'E'.

  DATA: TABNAME    LIKE DFIES-TABNAME, " or DCOBJECT-tabname
        LFIELDNAME LIKE DFIES-LFIELDNAME,
        WA_DFIES   LIKE DFIES.


  TABNAME = P_TABLE.
  LFIELDNAME = P_FIELD.
  CALL FUNCTION 'DDIF_FIELDINFO_GET'                        "#EC *
       EXPORTING
            TABNAME    = TABNAME                         "#EC DOM_EQUAL
            LFIELDNAME = LFIELDNAME
       IMPORTING
            DFIES_WA   = WA_DFIES
       EXCEPTIONS
            OTHERS     = 5.
  IF WA_DFIES-SCRTEXT_M IS INITIAL.
*   read text from corresponding source table field
    SELECT SRC_STRUCT FROM TXW_C_SOEX INTO TABNAME
           WHERE EXP_STRUCT = P_TABLE.
      CALL FUNCTION 'DDIF_FIELDINFO_GET'
           EXPORTING
                TABNAME        = TABNAME                 "#EC DOM_EQUAL
*               LANGU          = SY-LANGU
                LFIELDNAME     = LFIELDNAME
           IMPORTING
                DFIES_WA       = WA_DFIES
           EXCEPTIONS
                OTHERS         = 3.
      IF SY-SUBRC = 0.
        EXIT.
      ENDIF.
    ENDSELECT.
  ENDIF.

  IF NOT WA_DFIES-SCRTEXT_M IS INITIAL.
    P_TEXT = WA_DFIES-SCRTEXT_M.
  ELSEIF NOT WA_DFIES-SCRTEXT_S IS INITIAL.
    P_TEXT = WA_DFIES-SCRTEXT_S.
  ELSEIF NOT WA_DFIES-REPTEXT IS INITIAL.
    P_TEXT = WA_DFIES-REPTEXT.
  ELSEIF NOT WA_DFIES-SCRTEXT_L IS INITIAL.
    P_TEXT = WA_DFIES-SCRTEXT_L.
  ELSEIF NOT WA_DFIES-FIELDTEXT IS INITIAL.
    P_TEXT = WA_DFIES-FIELDTEXT.
  ELSEIF P_LANGU <> ENGLISH.
    PERFORM F99_GET_FIELD_DESCRIPTION
            USING    P_TABLE
                     P_FIELD
                     ENGLISH
            CHANGING P_TEXT.
  ELSE.
    P_TEXT = P_FIELD.
  ENDIF.


ENDFORM.                               " F99_GET_FIELD_DESCRIPTION
*&---------------------------------------------------------------------*
*&      Form  F99_GET_FIELD_LENGTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TABLE    table                                             *
*      -->P_FIELD    field                                             *
*      <--P_LEN      field length                                      *
*----------------------------------------------------------------------*
FORM F99_GET_FIELD_LENGTH
     USING    P_TABLE TYPE C
              P_FIELD TYPE C
     CHANGING P_LEN   TYPE I.

  DATA: TABNAME    LIKE DFIES-TABNAME,
        LFIELDNAME LIKE DFIES-LFIELDNAME,
        WA_DFIES   LIKE DFIES.


  TABNAME = P_TABLE.
  LFIELDNAME = P_FIELD.
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      TABNAME    = TABNAME                               "#EC DOM_EQUAL
      LFIELDNAME = LFIELDNAME
    IMPORTING
      DFIES_WA   = WA_DFIES.
  P_LEN = WA_DFIES-LENG.

ENDFORM.                               " F99_GET_FIELD_LENGTH
*&---------------------------------------------------------------------*
*&      Form  F99_GET_STRUCT_TEXT
*&---------------------------------------------------------------------*
*       get structure description
*----------------------------------------------------------------------*
*      -->P_STRUCT          structure                                  *
*      <--P_TEXT            description                                *
*      <--P_SUBRC           returncode                                 *
*----------------------------------------------------------------------*
FORM F99_GET_STRUCT_TEXT
     USING    P_STRUCT TYPE C
     CHANGING P_TEXT   TYPE C
              P_SUBRC  TYPE I.

* redesign with note 2285084 - segment texts stored in own text table
  CONSTANTS: lc_langu_e TYPE sy-langu VALUE 'E'.

  DATA: ld_tabnm TYPE ddobjname,
        ld_subrc TYPE sy-subrc.

  CLEAR P_TEXT.
  CHECK NOT P_STRUCT IS INITIAL.

  ld_tabnm = p_struct.
  CALL FUNCTION 'TXW_SEGMENT_TEXT_GET'
    EXPORTING
      id_segment   = ld_tabnm
    IMPORTING
      ed_text      = p_text
    EXCEPTIONS
      illegal_name = 1
      not_active   = 2.
  IF sy-subrc <> 0.
    ld_subrc = sy-subrc.
  ELSEIF p_text IS INITIAL.
*   try to get english text instead
    CALL FUNCTION 'TXW_SEGMENT_TEXT_GET'
      EXPORTING
        id_segment   = ld_tabnm
        id_langu     = lc_langu_e
      IMPORTING
        ed_text      = p_text
     EXCEPTIONS
        illegal_name = 1
        not_active   = 2.
    IF sy-subrc <> 0.
      ld_subrc = sy-subrc.
    ENDIF.
  ENDIF.

  IF ld_subrc IS INITIAL.
    CLEAR p_subrc.
  ELSE.
      MESSAGE I148(XW) WITH P_STRUCT.
      P_TEXT = '????'.
      P_SUBRC = 4.
  ENDIF.

ENDFORM.                               " F99_GET_STRUCT_TEXT
