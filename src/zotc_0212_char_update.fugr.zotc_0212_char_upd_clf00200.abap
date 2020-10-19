FUNCTION zotc_0212_char_upd_clf00200.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IDOC_HEADER) LIKE  EDIDC STRUCTURE  EDIDC
*"     REFERENCE(FLG_APPEND_STATUS) TYPE  XFELD
*"  TABLES
*"      IDOC_DATA STRUCTURE  EDIDD
*"      IDOC_STATUS STRUCTURE  BDIDOCSTAT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
************************************************************************
* FUNCTION MODULE  :  ZOTC_0212_CHAR_UPD_CLF00200                      *
* TITLE            :  Update Characteristic Detail for Material        *
* DEVELOPER        :  NEHA KUMARI                                      *
* OBJECT TYPE      :  ENHANCEMENT                                      *
* SAP RELEASE      :  SAP ECC 6.0                                      *
*----------------------------------------------------------------------*
*  WRICEF ID       :  D2_OTC_EDD_0212                                  *
*----------------------------------------------------------------------*
* DESCRIPTION      :  Update Characteristic Detail for IDoc Material   *
*                      - P/S - CLF00200                                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER     TRANSPORT   DESCRIPTION                        *
* ===========  ======== ==========  ===================================*
* 27-SEP-2014  NKUMARI  E2DK904869  INITIAL DEVELOPMENT                *
*&---------------------------------------------------------------------*
* 24-Feb-2015 NKUMARI  E2DK904869  Defect 4058: Check for the material *
*                                  type = Z004 to update custom table  *
*&---------------------------------------------------------------------*

* Event rissen by the ALE inbound process for CLFMAS.

* It allows to modify the idoc data submitted by the ALE layer.

* Raising the EXCEPTION ERROR will end the IDOC's inbound process with
* the IDOC status set to 51.
**--------------Data Declaration--------------**
  DATA:
     lx_e1oclfm   TYPE  e1oclfm,         " Master Object Classification
     lx_e1auspm   TYPE  e1auspm,         " Distribution of Classification: Assigned Char. Values
     lwa_bom_data TYPE  zotc_bom_create, " Characteristics information for sales BOM creation
     lv_matnr     TYPE  matnr,           " Material Number
     lv_mtpos     TYPE  mtpos,           " Item category group from material master
     lv_flag      TYPE  xfeld,           " Checkbox
* ---> Begin of change for Defect #4058 by NKUMARI
     lv_matnr_temp TYPE matnr, " Material Number
     lv_mtart     TYPE  mtart. " Material Type
* <--- End of change for Defect #4058 by NKUMARI

  DATA:
     li_bom_data TYPE STANDARD TABLE OF zotc_bom_create INITIAL SIZE 0, " Characteristics information for sales BOM creation
     li_status   TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0. " Enhancement Status

**--------------Field Symbol Declaration--------------**
  FIELD-SYMBOLS:
            <lfs_edidd>      TYPE  edidd,           " Data record (IDoc)
            <lfs_status>     TYPE  zdev_enh_status. " Enhancement Status

***---------Constant Declaration---------*****
  CONSTANTS:
      lc_segnam_e1oclfm TYPE  edilsegtyp    VALUE 'E1OCLFM', " Segment type
      lc_segnam_e1auspm TYPE  edilsegtyp    VALUE 'E1AUSPM', " Segment type
      lc_stat_insert    TYPE  xfeld         VALUE 'I'   ,    " Status of Processing
      lc_objtab_mara    TYPE  catabelle     VALUE 'MARA',    " Name of database table for object
      lc_atnam          TYPE  atnam         VALUE 'ATNAM',   " Characteristic Field Name
      lc_mtpos          TYPE  z_criteria    VALUE 'MTPOS',   " Item category group from material master
      lc_null           TYPE  z_criteria    VALUE 'NULL',    " Item category group from material master
* ---> Begin of change for Defect #4058 by NKUMARI
      lc_mtart          TYPE  z_criteria    VALUE 'MTART', " Material Type from material master
* <--- End of change for Defect #4058 by NKUMARI
      lc_enh_id         TYPE  z_enhancement VALUE 'D2_OTC_EDD_0212'. " Enhancement No.

**& Read the IDOC table for header segment
  READ TABLE idoc_data ASSIGNING <lfs_edidd>
                       WITH KEY segnam = lc_segnam_e1oclfm.
  IF sy-subrc EQ 0
 AND <lfs_edidd> IS ASSIGNED.
    lx_e1oclfm = <lfs_edidd>-sdata.
** Check for table name as 'MARA' in IDOC Header Segment
    IF lx_e1oclfm-obtab = lc_objtab_mara.

*&-- Get the Material No
      lv_matnr = lx_e1oclfm-objek.

* ---> Begin of change for Defect #4058 by NKUMARI
*&-- Check before Inserting the record in custom table
**   If material does not exit in table, then continue
      SELECT SINGLE matnr    " Material Number
        FROM zotc_bom_create " Characteristics information for sales BOM creation
        INTO lv_matnr_temp
        WHERE matnr = lv_matnr.

      IF sy-subrc NE 0.
* <--- End of change for Defect #4058 by NKUMARI

* Checking Enhancement Status
        CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
          EXPORTING
            iv_enhancement_no = lc_enh_id
          TABLES
            tt_enh_status     = li_status.
* Delete the records of the internal which is not active
        DELETE li_status WHERE active IS INITIAL.

        READ TABLE li_status TRANSPORTING NO FIELDS
                                 WITH KEY criteria = lc_null.
        IF sy-subrc = 0.
* Read Enhancement status table for Item category group = ZKIT
          READ TABLE li_status ASSIGNING <lfs_status>
                                WITH KEY  criteria = lc_mtpos.
          IF sy-subrc = 0.
*** Select Item category group from material from table MVKE
            SELECT mtpos " Item category group from material master
            FROM mvke    " Sales Data for Material
            INTO lv_mtpos
            UP TO 1 ROWS
            WHERE matnr = lv_matnr.
            ENDSELECT.
            IF sy-subrc EQ 0
           AND lv_mtpos = <lfs_status>-sel_low.
              UNASSIGN <lfs_edidd>.
* ---> Begin of change for Defect #4058 by NKUMARI
** Set the success flag
*            lv_flag = abap_true.

              DATA lv_val_low TYPE fpb_low. " From Value
              CLEAR: lv_mtart, lv_val_low.
*&-- Get Material Type
              SELECT SINGLE mtart " Material Type
              FROM mara           " General Material Data
              INTO lv_mtart
              WHERE matnr = lv_matnr.
              IF sy-subrc = 0.
                lv_val_low = lv_mtart.

                UNASSIGN <lfs_status>.
**& Material Type EQ Z004 AND MTPOS EQ ZKIT for the Material to update the custom table
                READ TABLE li_status ASSIGNING <lfs_status>
                                      WITH KEY criteria = lc_mtart
                                               sel_low = lv_val_low.
                IF sy-subrc EQ 0.
** Set the flag
                  lv_flag = abap_true.
                ENDIF. " IF sy-subrc EQ 0
              ENDIF. " IF sy-subrc = 0
* <--- End of change for Defect #4058 by NKUMARI
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF sy-subrc = 0
          UNASSIGN <lfs_status>.
** If flag is set
          IF lv_flag IS NOT INITIAL.
* Read Enhancement status table for Characteristic field name as ATNAM
            READ TABLE li_status ASSIGNING <lfs_status>
                                  WITH KEY  criteria = lc_atnam.
            IF sy-subrc = 0.
**& Read the idoc table for the Segment 'E1AUSPM' to get the Characteristic value
              LOOP AT idoc_data ASSIGNING <lfs_edidd>
                                    WHERE segnam = lc_segnam_e1auspm.
                lx_e1auspm = <lfs_edidd>-sdata.
** Check for characteristic field as 'ZTARGET' in IDOC Segment
                IF lx_e1auspm-atnam = <lfs_status>-sel_low. "lc_atnam.

** Append the Characteristic value in internal table
                  lwa_bom_data-matnr     = lv_matnr.
                  lwa_bom_data-component = lx_e1auspm-atwrt.
                  lwa_bom_data-status    = lc_stat_insert.

                  CONVERT DATE sy-datum
                          TIME sy-uzeit
                          INTO TIME STAMP lwa_bom_data-created
                          TIME ZONE sy-zonlo.

                  APPEND lwa_bom_data TO li_bom_data.
                ENDIF. " LOOP AT idoc_data ASSIGNING <lfs_edidd>
                CLEAR lwa_bom_data.
              ENDLOOP. " IF sy-subrc = 0
*&-- Insert the details in custom table 'ZOTC_BOM_CREATE' by calling Update task FM
              CALL FUNCTION 'ZOTC_0212_INSERT_CHAR_VALUE'
* ---> Begin of change for Defect #4058 by NKUMARI
                IN UPDATE TASK
* <--- End of change for Defect #4058 by NKUMARI
                EXPORTING
                  im_bom_data = li_bom_data.
            ENDIF. " IF lv_flag IS NOT INITIAL
          ENDIF. " IF sy-subrc = 0
* ---> Begin of change for Defect #4058 by NKUMARI
        ENDIF. " IF sy-subrc NE 0
* <--- End of change for Defect #4058 by NKUMARI
      ENDIF. " IF lx_e1oclfm-obtab = lc_objtab_mara
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0

ENDFUNCTION.
