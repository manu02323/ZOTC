*----------------------------------------------------------------------*
***INCLUDE LZOTC_DC_CODEF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_WRITE_CHANGE_DOCUMENT
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  LZOTC_DC_CODEF01                                       *
* TITLE      :  OTC_RDD_0010_BATCH_MATCHING Report                     *
* DEVELOPER  :  Pallavi Gupta                                          *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0010_BATCH_MATCHING Report                       *
*----------------------------------------------------------------------*
* DESCRIPTION:  This Include will write the change document for Custom *
*               table ZOTC_DC_CODE                                     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 16-Jul-2012 PGUPTA2  E1DK901335 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*
FORM f_write_change_document.

*Data Declaration
*Types declaration
  TYPES:
    BEGIN OF lty_dc_code,
      mandt    TYPE mandt,      "Client
      compcode TYPE z_compcode, "Compatibility Code
      kz       TYPE char1,      "Chng Ind
    END OF lty_dc_code.

  CONSTANTS:
    lc_objectid TYPE cdobjectv VALUE 'ZOTC_RDD_0010', "Object Id
    lc_new      TYPE cdchngind VALUE 'N',             "Chng Ind for New
    lc_ins      TYPE cdchngind VALUE 'I',             "Chng Ind for Insert
    lc_upd      TYPE cdchngind VALUE 'U',             "Chng Ind for Update
    lc_del      TYPE cdchngind VALUE 'D',             "Chng Ind for Delete
    lc_tcode    TYPE cdtcode   VALUE 'ZOTC_DC_CODE',  "T-Code
    lc_mandt    TYPE name_feld VALUE 'MANDT',         "MANDT field name
    lc_compcode TYPE name_feld VALUE 'COMPCODE'.      "COMPCODE field name

  DATA:
    lv_udate TYPE cddatum,     "Date
    lv_utime TYPE cduzeit,     "Time
    lv_uname TYPE cdusername,  "Userid
    lv_upd   TYPE cdchngind,   "Chng Ind

    li_tabnewvals TYPE STANDARD TABLE OF lty_dc_code,  "New Value table with chng ind
    li_oldvalues  TYPE STANDARD TABLE OF zotc_dc_code,"Old value table
    li_newvalues  TYPE STANDARD TABLE OF zotc_dc_code,"New value table
    li_cdtxt      TYPE STANDARD TABLE OF cdtxt,       "Text table

    lwa_tabnewvals TYPE lty_dc_code,   "New value table wokarea with chng ind
    lwa_oldvalues  TYPE zotc_dc_code, "Old value table workarea
    lwa_newvalues  TYPE zotc_dc_code. "New value table workarea

  FIELD-SYMBOLS:
    <lfs_tabnewvals> TYPE lty_dc_code, "New value table fieldsymbol
    <lfs_mandt>      TYPE mandt,      "MANDT field's fieldsymbol
    <lfs_compcode>   TYPE z_compcode. "COMPCODE field's fieldsymbol

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
        lc_compcode OF STRUCTURE <vim_total_struc> TO <lfs_compcode>.

      lwa_tabnewvals-mandt    = <lfs_mandt>.
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
      FROM zotc_dc_code
      INTO TABLE li_oldvalues
      FOR ALL ENTRIES IN li_tabnewvals
      WHERE compcode EQ li_tabnewvals-compcode.

    IF sy-subrc EQ 0.
      SORT li_oldvalues BY compcode.
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
    lwa_newvalues-compcode = <lfs_tabnewvals>-compcode.

*&--Fill old values when it is update or delete
    IF lv_upd EQ lc_upd OR
       lv_upd EQ lc_del.

      READ TABLE li_oldvalues
            INTO lwa_oldvalues
            WITH KEY compcode = <lfs_tabnewvals>-compcode
            BINARY SEARCH.
      IF sy-subrc NE 0.
       CLEAR lwa_oldvalues.
      ENDIF.

    ENDIF.

*&--Call the FM
    CALL FUNCTION 'ZDC_CODE_WRITE_DOCUMENT'
      EXPORTING
        objectid                = lc_objectid
        tcode                   = lc_tcode
        utime                   = lv_utime
        udate                   = lv_udate
        username                = lv_uname
        object_change_indicator = lv_upd
        n_zotc_dc_code          = lwa_newvalues
        o_zotc_dc_code          = lwa_oldvalues
        upd_zotc_dc_code        = lv_upd
      TABLES
        icdtxt_zdc_code         = li_cdtxt.

  ENDLOOP.


ENDFORM.                    " F_WRITE_CHANGE_DOCUMENT
