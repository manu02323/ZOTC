*----------------------------------------------------------------------*
***INCLUDE LZOTC_BATCHMATCHF01
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_WRITE_CHANGE_DOCUMENT
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  LZOTC_BATCHMATCHF01                                    *
* TITLE      :  OTC_RDD_0010_BATCH_MATCHING Report                     *
* DEVELOPER  :  Pallavi Gupta                                          *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0010_BATCH_MATCHING Report                       *
*----------------------------------------------------------------------*
* DESCRIPTION:  This Include will write the change document for Custom *
*               table ZOTC_BATCHMATCH and validate Complatibility code *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 16-Jul-2012 PGUPTA2  E1DK901335 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*

FORM f_write_change_document .

*Data Declaration
*Types declaration
  TYPES:
    BEGIN OF lty_batchmatch,
      mandt    TYPE mandt,      "Client
      matnr    TYPE z_kit,      "Kit Material
      zlevel   TYPE z_level,    "Level
      matnr2   TYPE matnr,      "Material
      compcode TYPE z_compcode, "Company Code
      kz       TYPE char1,      "Change Ind
    END OF lty_batchmatch.

  CONSTANTS:
    lc_objectid TYPE cdobjectv VALUE 'ZOTC_RDD_0010',    "Object Id
    lc_new      TYPE cdchngind VALUE 'N',                "Chng Ind for New
    lc_ins      TYPE cdchngind VALUE 'I',                "Chng Ind for Insert
    lc_upd      TYPE cdchngind VALUE 'U',                "Chng Ind for Update
    lc_del      TYPE cdchngind VALUE 'D',                "Chng Ind for Delete
    lc_tcode    TYPE cdtcode   VALUE 'ZOTC_BATCHMATCHING',"T-Code
    lc_mandt    TYPE name_feld VALUE 'MANDT',             "MANDT field name
    lc_matnr    TYPE name_feld VALUE 'MATNR',             "MATNR field name
    lc_zlevel   TYPE name_feld VALUE 'ZLEVEL',            "ZLEVEL field name
    lc_matnr2   TYPE name_feld VALUE 'MATNR2',            "MATNR2 field name
    lc_compcode TYPE name_feld VALUE 'COMPCODE'.          "COMPCODE field name

  DATA:
    lv_udate TYPE cddatum,     "Date
    lv_utime TYPE cduzeit,     "Time
    lv_uname TYPE cdusername,  "Userid
    lv_upd   TYPE cdchngind,   "Chng Ind

    li_tabnewvals TYPE STANDARD TABLE OF lty_batchmatch,  "New Value table with chng ind
    li_oldvalues  TYPE STANDARD TABLE OF zotc_batchmatch, "Old value table
    li_newvalues  TYPE STANDARD TABLE OF zotc_batchmatch, "New value table
    li_cdtxt      TYPE STANDARD TABLE OF cdtxt,           "Text table

    lwa_tabnewvals TYPE lty_batchmatch,   "New value table wokarea with chng ind
    lwa_oldvalues  TYPE zotc_batchmatch, "Old value table workarea
    lwa_newvalues  TYPE zotc_batchmatch. "New value table workarea

  FIELD-SYMBOLS:
    <lfs_tabnewvals> TYPE lty_batchmatch, "New value table fieldsymbol
    <lfs_mandt>      TYPE mandt,         "MANDT field's fieldsymbol
    <lfs_matnr>      TYPE z_kit,         "KIT field's fieldsymbol
    <lfs_zlevel>     TYPE z_level,       "ZLEVEL field's fieldsymbol
    <lfs_matnr2>     TYPE matnr,         "MATNR field's fieldsymbol
    <lfs_compcode>   TYPE z_compcode.    "COMPCODE field's fieldsymbol

*&--Get the new values to be filled in CDHDR and CDPOS tables
  LOOP AT total.

*&--Populate the fields to one new internal table when it is
*&--only insert, update and delete
    IF <action> EQ lc_new OR
       <action> EQ lc_upd OR
       <action> EQ lc_del.

*&--Populate new field values entered in table maintenance
*&--from "total" table

      ASSIGN COMPONENT:
        lc_mandt    OF STRUCTURE <vim_total_struc> TO <lfs_mandt>,
        lc_matnr    OF STRUCTURE <vim_total_struc> TO <lfs_matnr>,
        lc_zlevel   OF STRUCTURE <vim_total_struc> TO <lfs_zlevel>,
        lc_matnr2   OF STRUCTURE <vim_total_struc> TO <lfs_matnr2>,
        lc_compcode OF STRUCTURE <vim_total_struc> TO <lfs_compcode>.

      lwa_tabnewvals-mandt    = <lfs_mandt>.
      lwa_tabnewvals-matnr    = <lfs_matnr>.
      lwa_tabnewvals-zlevel   = <lfs_zlevel>.
      lwa_tabnewvals-matnr2   = <lfs_matnr2>.
      lwa_tabnewvals-compcode = <lfs_compcode>.
      lwa_tabnewvals-kz       = <action>.

      APPEND lwa_tabnewvals TO li_tabnewvals.
      CLEAR lwa_tabnewvals.
    ENDIF.
  ENDLOOP.

  IF li_tabnewvals[] IS NOT INITIAL.
*&--As we are fetching all entries from 'Z' table select * is used to get
*&--the old values from table itself because by this time new values will
*&--not be updated in custom table
    SELECT *
      FROM zotc_batchmatch
      INTO TABLE li_oldvalues
      FOR ALL ENTRIES IN li_tabnewvals
      WHERE matnr    EQ li_tabnewvals-matnr
        AND zlevel   EQ li_tabnewvals-zlevel
        AND matnr2   EQ li_tabnewvals-matnr2
        AND compcode EQ li_tabnewvals-compcode.

    IF sy-subrc EQ 0.
      SORT li_oldvalues BY matnr zlevel
                           matnr2 compcode.
    ENDIF.

  ENDIF.

  lv_udate = sy-datum.
  lv_utime = sy-uzeit.
  lv_uname = sy-uname.

  LOOP AT li_tabnewvals ASSIGNING <lfs_tabnewvals>.

    IF <lfs_tabnewvals>-kz EQ lc_new.
      lv_upd = lc_ins.
    ELSE.
      lv_upd = <lfs_tabnewvals>-kz.
    ENDIF.

    lwa_newvalues-mandt    = <lfs_tabnewvals>-mandt.
    lwa_newvalues-matnr    = <lfs_tabnewvals>-matnr.
    lwa_newvalues-zlevel   = <lfs_tabnewvals>-zlevel.
    lwa_newvalues-matnr2   = <lfs_tabnewvals>-matnr2.
    lwa_newvalues-compcode = <lfs_tabnewvals>-compcode.

*&--Fill old values when it is update or delete
    IF lv_upd EQ lc_upd OR
       lv_upd EQ lc_del.

      READ TABLE li_oldvalues
            INTO lwa_oldvalues
            WITH KEY matnr    = <lfs_tabnewvals>-matnr
                     zlevel   = <lfs_tabnewvals>-zlevel
                     matnr2   = <lfs_tabnewvals>-matnr2
                     compcode = <lfs_tabnewvals>-compcode
            BINARY SEARCH.
      IF sy-subrc NE 0.
        CLEAR lwa_oldvalues.
      ENDIF.
    ENDIF.

*&--Call the FM
    CALL FUNCTION 'ZBATCH_MATCH_WRITE_DOCUMENT'
      EXPORTING
        objectid                = lc_objectid
        tcode                   = lc_tcode
        utime                   = lv_utime
        udate                   = lv_udate
        username                = lv_uname
        object_change_indicator = lv_upd
        n_zotc_batchmatch       = lwa_newvalues
        o_zotc_batchmatch       = lwa_oldvalues
        upd_zotc_batchmatch     = lv_upd
      TABLES
        icdtxt_zbatch_match     = li_cdtxt.

  ENDLOOP.


ENDFORM.                    " F_WRITE_CHANGE_DOCUMENT
* Validate Compatibility Code
FORM f_validate_compcode.
* Validate Compatibility Code from CABN table
  DATA:lv_compcode TYPE atnam.
  IF zotc_batchmatch-compcode IS NOT INITIAL.
    SELECT atnam
           FROM cabn
           INTO lv_compcode
           UP TO 1 ROWS
           WHERE atnam = zotc_batchmatch-compcode.
    ENDSELECT.

    IF sy-subrc IS NOT INITIAL.
      MESSAGE e000(zotc_msg) WITH
              text-001
              zotc_batchmatch-compcode
              text-002.
    ENDIF.
  ENDIF.
  CLEAR: lv_compcode.
ENDFORM.                    "F_VALIDATE_COMPCODE
