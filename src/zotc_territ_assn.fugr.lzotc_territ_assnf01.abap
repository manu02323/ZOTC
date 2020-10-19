************************************************************************
* PROGRAM    :  LZOTC_TERRIT_ASSNF01                                   *
* TITLE      :  D2_MDM_CDD_0071_Customer Master Enhancement            *
* DEVELOPER  :  JAHAN MAZUMDER                                         *
* OBJECT TYPE:  INCLUDE                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  D2_MDM_CDD_0071 / CR_33                                *
*----------------------------------------------------------------------*
*DESCRIPTION:  Triggering Change Pointers /Customer Master Idoc based  *
*              on table fields  'Effective Date/ Expiration            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER     TRANSPORT  DESCRIPTION                         *
* ===========  ======== ========== ====================================*
* 10-Sep-2014  JAHAN    E2DK901331 D2_MDM_EDD_0071_Customer Master     *
*                                  -Enhancement - D2_CR_33             *
************************************************************************

FORM f_write_change_document.

*Data Declaration
*Types declaration
  TYPES:
    BEGIN OF lty_terr_assn,
      mandt          TYPE mandt, "Client
      vkorg	         TYPE vkorg, " Sales Organization
      vtweg	         TYPE vtweg, " Distribution Channel
      spart	         TYPE spart, " Division
      kunnr	         TYPE kunnr, " Customer Number
      territory_id   TYPE	zterritory_id,
      partrole       TYPE	zpart_role,
      effective_from TYPE	zeffect_date,
      effective_to   TYPE	zexpiry_date,
      kz             TYPE char1, "Chng Ind
    END OF lty_terr_assn.

  CONSTANTS:
    lc_objectid TYPE cdobjectv VALUE 'ZOTC_TERRIT_ASSN',    "Object Id
    lc_new      TYPE cdchngind VALUE 'N',                   "Chng Ind for New
    lc_ins      TYPE cdchngind VALUE 'I',                   "Chng Ind for Insert
    lc_upd      TYPE cdchngind VALUE 'U',                   "Chng Ind for Update
    lc_del      TYPE cdchngind VALUE 'D',                   "Chng Ind for Delete
    lc_change   TYPE cdchngind VALUE 'X',                   "Change Type (U, I, S, D)
    lc_tcode    TYPE cdtcode   VALUE 'ZOTC_TERRIT_ASSN',    "T-Code
    lc_mandt    TYPE name_feld VALUE 'MANDT',               "MANDT field name
    lc_vkorg    TYPE name_feld VALUE 'VKORG',               "MANDT field name
    lc_vtweg    TYPE name_feld VALUE 'VTWEG',               "MANDT field name
    lc_spart    TYPE name_feld VALUE 'SPART',               "MANDT field name
    lc_kunnr    TYPE name_feld VALUE 'KUNNR',               "MANDT field name
    lc_territory_id    TYPE name_feld VALUE 'TERRITORY_ID', "MANDT field name
    lc_partrole        TYPE name_feld VALUE 'PARTROLE',     "MANDT field name
    lc_zeffect_date TYPE name_feld VALUE 'EFFECTIVE_FROM',  " Field name
    lc_zexpiry_date TYPE name_feld VALUE 'EFFECTIVE_TO'.    " Field name


  DATA:
    lv_udate    TYPE cddatum,                              "Date
    lv_utime    TYPE cduzeit,                              "Time
    lv_uname    TYPE cdusername,                           "Userid
    lv_upd      TYPE cdchngind,                            "Chng Ind
    lv_objectid TYPE cdobjectv,                            " Object value

    li_tabnewvals TYPE STANDARD TABLE OF lty_terr_assn,    "New Value table with chng ind
    li_oldvalues  TYPE STANDARD TABLE OF zotc_territ_assn, "Old value table
    li_newvalues  TYPE STANDARD TABLE OF zotc_territ_assn, "New value table
    li_cdtxt      TYPE STANDARD TABLE OF cdtxt,            "Text table

    lwa_tabnewvals TYPE lty_terr_assn,                     "New value table wokarea with chng ind
    lwa_oldvalues  TYPE zotc_territ_assn,                  "Old value table workarea
    lwa_newvalues  TYPE zotc_territ_assn,                  "New value table workarea

    ls_customer    TYPE cmds_customer_s,                   " Customer Data
    lw_kna1_n      TYPE kna1,                              " General Data in Customer Master
    lw_kna1_o      TYPE kna1.                              " General Data in Customer Master

  FIELD-SYMBOLS:
    <lfs_tabnewvals> TYPE lty_terr_assn,   "New value table fieldsymbol
    <lfs_mandt>      TYPE mandt,           "MANDT field's fieldsymbol
    <lfs_vkorg>      TYPE vkorg,           " Sales Organization
    <lfs_vtweg>      TYPE vtweg,           " Distribution Channel
    <lfs_spart>      TYPE spart,           " Division
    <lfs_kunnr>      TYPE kunnr,           " Division
    <lfs_territory_id> TYPE zterritory_id, " Partner Territory ID
    <lfs_partrole>     TYPE zpart_role,    " Partner Role
    <lfs_zeffect_date> TYPE zeffect_date,  " Effective From
    <lfs_zexpiry_date> TYPE zexpiry_date.  " Effective To

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
        lc_vkorg    OF STRUCTURE <vim_total_struc> TO <lfs_vkorg>,
        lc_vtweg    OF STRUCTURE <vim_total_struc> TO <lfs_vtweg>,
        lc_spart    OF STRUCTURE <vim_total_struc> TO <lfs_spart>,
        lc_kunnr    OF STRUCTURE <vim_total_struc> TO <lfs_kunnr>,
        lc_territory_id OF STRUCTURE <vim_total_struc> TO <lfs_territory_id>,
        lc_partrole     OF STRUCTURE <vim_total_struc> TO <lfs_partrole>,
        lc_zeffect_date OF STRUCTURE <vim_total_struc> TO <lfs_zeffect_date>,
        lc_zexpiry_date OF STRUCTURE <vim_total_struc> TO <lfs_zexpiry_date>.


      lwa_tabnewvals-mandt    = <lfs_mandt>.
      lwa_tabnewvals-vkorg   = <lfs_vkorg>.
      lwa_tabnewvals-vtweg   = <lfs_vtweg>.
      lwa_tabnewvals-spart   = <lfs_spart>.
      lwa_tabnewvals-kunnr   = <lfs_kunnr>.
      lwa_tabnewvals-territory_id   = <lfs_territory_id>.
      lwa_tabnewvals-partrole       = <lfs_partrole>.
      lwa_tabnewvals-effective_from = <lfs_zeffect_date>.
      lwa_tabnewvals-effective_to   = <lfs_zexpiry_date>.
      lwa_tabnewvals-kz             = <action>.

      APPEND lwa_tabnewvals TO li_tabnewvals.
      CLEAR lwa_tabnewvals.
    ENDIF. " IF <action> EQ lc_new OR
  ENDLOOP. " LOOP AT total

  IF li_tabnewvals[] IS NOT INITIAL.
*&--As we are fetching all entries from 'Z' table select * is used to get
*&--the old values from table itself because by this time new values will
*&--not be updated in custom table
    SELECT *
      FROM zotc_territ_assn " Comm Group: Territory Assignment
      INTO TABLE li_oldvalues
      FOR ALL ENTRIES IN li_tabnewvals
      WHERE vkorg EQ li_tabnewvals-vkorg
        AND vtweg EQ li_tabnewvals-vtweg
        AND spart EQ li_tabnewvals-spart
        AND kunnr EQ li_tabnewvals-kunnr
        AND territory_id EQ li_tabnewvals-territory_id
        AND partrole     EQ li_tabnewvals-partrole.

    IF sy-subrc EQ 0.
      SORT li_oldvalues BY vkorg vtweg spart kunnr territory_id partrole effective_from effective_to.
    ENDIF. " IF sy-subrc EQ 0

  ENDIF. " IF li_tabnewvals[] IS NOT INITIAL


  LOOP AT li_tabnewvals ASSIGNING <lfs_tabnewvals>.

    IF <lfs_tabnewvals>-kz EQ lc_new.
      lv_upd = lc_ins.
    ELSE. " ELSE -> IF <lfs_tabnewvals>-kz EQ lc_new
      lv_upd = <lfs_tabnewvals>-kz.
    ENDIF. " IF <lfs_tabnewvals>-kz EQ lc_new

    lwa_newvalues-mandt          = <lfs_tabnewvals>-mandt.
    lwa_newvalues-vkorg          = <lfs_tabnewvals>-vkorg.
    lwa_newvalues-vtweg          = <lfs_tabnewvals>-vtweg.
    lwa_newvalues-spart          = <lfs_tabnewvals>-spart.
    lwa_newvalues-kunnr          = <lfs_tabnewvals>-kunnr.
    lwa_newvalues-territory_id   = <lfs_tabnewvals>-territory_id.
    lwa_newvalues-partrole       = <lfs_tabnewvals>-partrole.
    lwa_newvalues-effective_from = <lfs_tabnewvals>-effective_from.
    lwa_newvalues-effective_to   = <lfs_tabnewvals>-effective_to.


*--Pass the effective as the change pointer creation date , so that the change pointer is
*--processed on the effective future date only.
    lv_udate = lwa_newvalues-effective_from.
    lv_utime = sy-uzeit.
    lv_uname = sy-uname.

*&--Fill old values when it is update or delete
    IF lv_upd EQ lc_upd OR
       lv_upd EQ lc_del.

      READ TABLE li_oldvalues
            INTO lwa_oldvalues
      WITH KEY vkorg = <lfs_tabnewvals>-vkorg
        vtweg = <lfs_tabnewvals>-vtweg
        spart = <lfs_tabnewvals>-spart
        kunnr = <lfs_tabnewvals>-kunnr
        territory_id = <lfs_tabnewvals>-territory_id
        partrole     = <lfs_tabnewvals>-partrole
            BINARY SEARCH.
      IF sy-subrc NE 0.
        CLEAR lwa_oldvalues.
      ENDIF. " IF sy-subrc NE 0

    ENDIF. " IF lv_upd EQ lc_upd OR

    lv_objectid = lwa_oldvalues-kunnr.

    IF <lfs_tabnewvals>-kunnr IS NOT INITIAL.

      SELECT SINGLE *
        INTO lw_kna1_n
             FROM kna1 " General Data in Customer Master
           WHERE kunnr = <lfs_tabnewvals>-kunnr.
      IF sy-subrc EQ 0.

*--Pass a dummy 'X' difference in KNA1 field name2, to force Idoc creation FM to trigger IDocs, other wise
*--it does not create any Idoc as it cannot find any difference between lw_kna1_o & lw_kna1_n.
        lw_kna1_o =  lw_kna1_n.
        IF lw_kna1_n-name2 IS INITIAL.
          lw_kna1_n-name2 = lc_change.
        ELSE. " ELSE -> IF lw_kna1_n-name2 IS INITIAL
          CLEAR lw_kna1_n-name2 .
        ENDIF. " IF lw_kna1_n-name2 IS INITIAL

        CALL FUNCTION 'DEBI_WRITE_DOCUMENT'
          EXPORTING
            objectid                = lv_objectid
            tcode                   = lc_tcode
            utime                   = lv_utime
            udate                   = lv_udate
            username                = lv_uname
            planned_change_number   = space
            object_change_indicator = lv_upd
            planned_or_real_changes = space
            no_change_pointers      = space
            o_ykna1                 = lw_kna1_o
            n_kna1                  = lw_kna1_n
            upd_kna1                = lv_upd
            upd_knas                = ls_customer-knas-upd
            upd_knat                = ls_customer-knat-upd
            o_yknb1                 = ls_customer-knb1-old_data
            n_knb1                  = ls_customer-knb1-new_data
            upd_knb1                = ls_customer-knb1-upd
            upd_knb5                = ls_customer-knb5-upd
            upd_knbk                = ls_customer-knbk-upd
            upd_knbw                = ls_customer-knbw-upd
            upd_knex                = ls_customer-knex-upd
            upd_knva                = ls_customer-knva-upd
            upd_knvd                = ls_customer-knvd-upd
            upd_knvi                = ls_customer-knvi-upd
            upd_knvk                = ls_customer-knvk-upd
            upd_knvl                = ls_customer-knvl-upd
            upd_knvp                = ls_customer-knvp-upd
            upd_knvs                = ls_customer-knvs-upd
            o_yknvv                 = ls_customer-knvv-old_data
            n_knvv                  = ls_customer-knvv-new_data
            upd_knvv                = ls_customer-knvv-upd
            upd_knza                = ls_customer-knza-upd
          TABLES
            xknas                   = ls_customer-fknas-new_data
            yknas                   = ls_customer-fknas-old_data
            xknat                   = ls_customer-fknat-new_data
            yknat                   = ls_customer-fknat-old_data
            xknb5                   = ls_customer-fknb5-new_data
            yknb5                   = ls_customer-fknb5-old_data
            xknbk                   = ls_customer-fknbk-new_data
            yknbk                   = ls_customer-fknbk-old_data
            xknbw                   = ls_customer-fknbw-new_data
            yknbw                   = ls_customer-fknbw-old_data
            xknex                   = ls_customer-fknex-new_data
            yknex                   = ls_customer-fknex-old_data
            xknva                   = ls_customer-fknva-new_data
            yknva                   = ls_customer-fknva-old_data
            xknvd                   = ls_customer-fknvd-new_data
            yknvd                   = ls_customer-fknvd-old_data
            xknvi                   = ls_customer-fknvi-new_data
            yknvi                   = ls_customer-fknvi-old_data
            xknvk                   = ls_customer-fknvk-new_data
            yknvk                   = ls_customer-fknvk-old_data
            xknvl                   = ls_customer-fknvl-new_data
            yknvl                   = ls_customer-fknvl-old_data
            xknvp                   = ls_customer-fknvp-new_data
            yknvp                   = ls_customer-fknvp-old_data
            xknvs                   = ls_customer-fknvs-new_data
            yknvs                   = ls_customer-fknvs-old_data
            xknza                   = ls_customer-fknza-new_data
            yknza                   = ls_customer-fknza-old_data.

      ENDIF. " IF sy-subrc EQ 0

*&--Call the FM

      CALL FUNCTION 'ZOTC_COMM_GRP_WRITE_DOCUMENT'
        EXPORTING
          objectid                = lv_objectid
          tcode                   = lc_tcode
          utime                   = lv_utime
          udate                   = lv_udate
          username                = lv_uname
          object_change_indicator = lv_upd
          n_zotc_territ_assn      = lwa_newvalues
          o_zotc_territ_assn      = lwa_oldvalues
          upd_zotc_territ_assn    = lv_upd
        TABLES
          icdtxt_zotc_comm_grp    = li_cdtxt.

    ENDIF. " IF <lfs_tabnewvals>-kunnr IS NOT INITIAL
  ENDLOOP. " LOOP AT li_tabnewvals ASSIGNING <lfs_tabnewvals>
ENDFORM. " F_WRITE_CHANGE_DOCUMENT
