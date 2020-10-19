FUNCTION zotc_rv_condition_copy.
*"----------------------------------------------------------------------
*"*"Global Interface:
*"  IMPORTING
*"     VALUE(APPLICATION) LIKE  T681A-KAPPL
*"     VALUE(CONDITION_TABLE) LIKE  T681-KOTABNR
*"     VALUE(CONDITION_TYPE) LIKE  T685A-KSCHL
*"     VALUE(DATE_FROM) LIKE  RV13A-DATAB DEFAULT '00000000'
*"     VALUE(DATE_TO) LIKE  RV13A-DATBI DEFAULT '00000000'
*"     VALUE(ENQUEUE) DEFAULT ' '
*"     REFERENCE(I_KOMK) LIKE  KOMK STRUCTURE  KOMK OPTIONAL
*"     REFERENCE(I_KOMP) LIKE  KOMP STRUCTURE  KOMP OPTIONAL
*"     REFERENCE(KEY_FIELDS) LIKE  KOMG STRUCTURE  KOMG
*"     VALUE(MAINTAIN_MODE) DEFAULT 'B'
*"     VALUE(NO_AUTHORITY_CHECK) DEFAULT ' '
*"     VALUE(NO_FIELD_CHECK) DEFAULT ' '
*"     VALUE(SELECTION_DATE) LIKE  SYST-DATUM DEFAULT '00000000'
*"     VALUE(KEEP_OLD_RECORDS) DEFAULT ' '
*"     REFERENCE(MATERIAL_M) LIKE  MT06E STRUCTURE  MT06E OPTIONAL
*"     VALUE(USED_BY_IDOC) DEFAULT ' '
*"     REFERENCE(I_KONA) LIKE  KONA STRUCTURE  KONA OPTIONAL
*"     VALUE(OVERLAP_CONFIRMED) DEFAULT ' '
*"     VALUE(NO_DB_UPDATE) DEFAULT ' '
*"     VALUE(USED_BY_RETAIL) DEFAULT ' '
*"     REFERENCE(I_KNUMH) TYPE  KNUMH OPTIONAL
*"     REFERENCE(I_NO_POSTING) TYPE  XFELD OPTIONAL
*"     VALUE(FREE_MEMORY) TYPE  C OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_KOMK) LIKE  KOMK STRUCTURE  KOMK
*"     REFERENCE(E_KOMP) LIKE  KOMP STRUCTURE  KOMP
*"     VALUE(NEW_RECORD)
*"     VALUE(E_DATAB) LIKE  VAKE-DATAB
*"     VALUE(E_DATBI) LIKE  VAKE-DATBI
*"     VALUE(E_PRDAT) LIKE  VAKE-DATBI
*"     REFERENCE(E_KNUMH) TYPE  KNUMH
*"  TABLES
*"      COPY_RECORDS STRUCTURE  KOMV
*"      COPY_STAFFEL STRUCTURE  CONDSCALE OPTIONAL
*"      COPY_RECS_IDOC STRUCTURE  KOMV_IDOC OPTIONAL
*"      KNUMH_MAP STRUCTURE  KNUMH_COMP OPTIONAL
*"  EXCEPTIONS
*"      ENQUEUE_ON_RECORD
*"      INVALID_APPLICATION
*"      INVALID_CONDITION_NUMBER
*"      INVALID_CONDITION_TYPE
*"      NO_AUTHORITY_EKORG
*"      NO_AUTHORITY_KSCHL
*"      NO_AUTHORITY_VKORG
*"      NO_SELECTION
*"      TABLE_NOT_VALID
*"      NO_MATERIAL_FOR_SETTLEMENT
*"      NO_UNIT_FOR_PERIOD_COND
*"      NO_UNIT_REFERENCE_MAGNITUDE
*"      INVALID_CONDITION_TABLE
*"----------------------------------------------------------------------
************************************************************************
* Function Module    :  ZOTC_RV_CONDITION_COPY                         *
* TITLE      :  OTC_IDD_42_Price Load                                  *
* DEVELOPER  :  Shammi Puri                                            *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_42_Price Load
*----------------------------------------------------------------------*
* DESCRIPTION: Wrapper Function Module to Create Condition type. Since
* standard function modules are not released , these are copied into
* custom Function modules and called Wrapper FM.
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 05-June-2012 SPURI  E1DK901668 INITIAL DEVELOPMENT                   *
* 16-Aug-2013  NNM    E1DK911313 CR700: Added KNUMH to EXPORT for
*                                addition of Internal Comment in VK11
*&---------------------------------------------------------------------*

  CALL FUNCTION 'RV_CONDITION_COPY'
    EXPORTING
      application                 = application
      condition_table             = condition_table
      condition_type              = condition_type
      date_from                   = date_from
      date_to                     = date_to
      enqueue                     = enqueue
      i_komk                      = i_komk
      i_komp                      = i_komp
      key_fields                  = key_fields
      maintain_mode               = maintain_mode
      no_authority_check          = no_authority_check
      no_field_check              = no_field_check
      selection_date              = selection_date
      keep_old_records            = keep_old_records
      material_m                  = material_m
      used_by_idoc                = used_by_idoc
      i_kona                      = i_kona
      overlap_confirmed           = overlap_confirmed
      no_db_update                = no_db_update
      used_by_retail              = used_by_retail
    IMPORTING
      e_komk                      = e_komk
      e_komp                      = e_komp
      new_record                  = new_record
      e_datab                     = e_datab
      e_datbi                     = e_datbi
      e_prdat                     = e_prdat
    TABLES
      copy_records                = copy_records
      copy_staffel                = copy_staffel
      copy_recs_idoc              = copy_recs_idoc
    EXCEPTIONS
      enqueue_on_record           = 1
      invalid_application         = 2
      invalid_condition_number    = 3
      invalid_condition_type      = 4
      no_authority_ekorg          = 5
      no_authority_kschl          = 6
      no_authority_vkorg          = 7
      no_selection                = 8
      table_not_valid             = 9
      no_material_for_settlement  = 10
      no_unit_for_period_cond     = 11
      no_unit_reference_magnitude = 12
      invalid_condition_table     = 13
      OTHERS                      = 14.


  IF sy-subrc = 0.
    CALL FUNCTION 'ZOTC_RV_CONDITION_SAVE'
      EXPORTING
        i_knumh      = i_knumh
        i_no_posting = i_no_posting
      TABLES
        knumh_map    = knumh_map.
    COMMIT WORK AND WAIT.
    e_knumh = knumh_map-knumh_new.  "CR#700 ++

    CALL FUNCTION 'ZOTC_RV_CONDITION_RESET'
      EXPORTING
        free_memory = free_memory.

  ELSEIF sy-subrc = 1.
    RAISE   enqueue_on_record.
  ELSEIF sy-subrc = 2.
    RAISE   invalid_application.
  ELSEIF sy-subrc = 3.
    RAISE   invalid_condition_number.
  ELSEIF sy-subrc = 4.
    RAISE invalid_condition_type.
  ELSEIF sy-subrc = 5.
    RAISE no_authority_ekorg.
  ELSEIF sy-subrc = 6.
    RAISE no_authority_kschl.
  ELSEIF sy-subrc = 7.
    RAISE no_authority_vkorg .
  ELSEIF sy-subrc = 8.
    RAISE no_selection.
  ELSEIF sy-subrc = 9.
    RAISE table_not_valid.
  ELSEIF sy-subrc = 10.
    RAISE no_material_for_settlement.
  ELSEIF sy-subrc = 11.
    RAISE no_unit_for_period_cond.
  ELSEIF sy-subrc = 12.
    RAISE no_unit_reference_magnitude .
  ELSEIF sy-subrc = 13.
    RAISE invalid_condition_table.
  ELSEIF sy-subrc = 14.
    RAISE others.
  ENDIF.


































































ENDFUNCTION.
