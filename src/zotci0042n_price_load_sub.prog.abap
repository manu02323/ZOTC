*&---------------------------------------------------------------------*
*&  Include           ZOTCI0042B_PRICE_LOAD_SUB
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCI0042B_PRICE_LOAD                                  *
* TITLE      :  OTC_IDD_42_Price Load                                  *
* DEVELOPER  :  Shammi Puri                                            *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_42_Price Load
*----------------------------------------------------------------------*
* DESCRIPTION: Bio-Rad requires an interface to handle new entries and
* changes to the Transfer Price.This will not be a real time price
* update to the ECC system, but a periodic upload of the transfer price.
* This interface gives the ability to upload Transfer Price into the ECC
* system using a flat file. The format of the upload template will be a
* tab-delimited txt file. The upload program would read the flat file and
* create transfer price condition records in the SAP system. To load the
* data from the flat file, we will use a custom transaction, which will
* be scheduled to run every mid-night.
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 05-June-2012 SPURI  E1DK901668 INITIAL DEVELOPMENT                   *
* 01-Nov-2013  RRANA  E1DK912138 Restricting the file for getting      *
*                                saved in Application server DONE      *
*                                folder D#13                           *
* 09-Feb-2015  NBAIS  E2DK907039  Defect #1925-(Performance Improvement*
*                                 Improvement done in code for the     *
*                                 Performance issue in the program.    *
* 14-Feb-2015 MSINGH1 E2DK907039  Defect #1925-(Performance Improvement*
*                                 Improvement done in code for the     *
*                                 Performance issue in the program.    *
*19-Aug-2019  SMUKHER E1SK901423  HANAtization changes                 *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY1_SCREEN
*&---------------------------------------------------------------------*
* This perform hide/ unhide selection screen parameters based on user
* selection
*&---------------------------------------------------------------------*
FORM f_modify1_screen .
  LOOP AT SCREEN .
    IF rb_pres NE c_true.
      IF screen-group1    = c_groupmi3
         OR screen-group1 = c_groupmi4
         OR screen-group1 = c_groupmi6.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
    ELSE. " ELSE -> IF screen-group1 = c_groupmi3
      IF screen-group1 = c_groupmi3.
        screen-active = c_one.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
    ENDIF. " IF rb_pres NE c_true
    IF rb_app NE c_true.
      IF screen-group1    = c_groupmi2
         OR screen-group1 = c_groupmi5
         OR screen-group1 = c_groupmi7.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi2
    ENDIF. " IF rb_app NE c_true
  ENDLOOP. " LOOP AT SCREEN
ENDFORM. " F_MODIFY1_SCREEN
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_FILE1
*&---------------------------------------------------------------------*
* Load File into Internal table i_leg-tab
*&---------------------------------------------------------------------*
FORM f_upload_file1  USING    p_p_phdr
                              p_p_ahdr.


  TYPES : BEGIN OF lty_string ,
          string TYPE string,
          END OF lty_string.

  DATA:   lv_msg          TYPE string,                                                  "  local variable declaration for message
          lv_filename     TYPE string,                                                  "  local variale declaration for file name
          lv_leg_tab      TYPE string,                                                  "  local variale declaration foR FILE RECORD
          lv_date         TYPE datum,                                                   " Date
          li_legacy_tab   TYPE STANDARD TABLE OF zzlegacy_ecc_translate INITIAL SIZE 0, " Legacy to ECC Object Value Translate
          li_ecc_tab      TYPE SORTED TABLE OF zzlegacy_ecc_translate  WITH             " Legacy to ECC Object Value Translate
                          NON-UNIQUE KEY source_key_value INITIAL SIZE 0,               " Legacy to ECC Object Value Translate
          lwa_legacy_tab  TYPE zzlegacy_ecc_translate,                                  " Legacy to ECC Object Value Translate
          lwa_ecc_tab     TYPE zzlegacy_ecc_translate,                                  " Legacy to ECC Object Value Translate
          lv_datum        TYPE datum,                                                   " Date
          li_string       TYPE STANDARD TABLE OF lty_string,
          lwa_string      TYPE lty_string,
          lwa_leg_tab_c   TYPE ty_leg_tab_c.


  CLEAR: gv_subrc.
  CLEAR: gv_header.
* presentation server
  IF rb_pres = c_selected .
    lv_filename = p_phdr.
    CALL METHOD cl_gui_frontend_services=>gui_upload
      EXPORTING
        filename                = lv_filename
      CHANGING
        data_tab                = li_string
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        not_supported_by_gui    = 17
        error_no_gui            = 18
        OTHERS                  = 19.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno INTO lv_msg
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      WRITE: / lv_msg, ':', lv_filename.
    ELSE. " ELSE -> IF sy-subrc <> 0

      LOOP AT li_string INTO lwa_string.
        CLEAR lwa_leg_tab_c.
        SPLIT lwa_string-string AT ';' INTO
               lwa_leg_tab_c-kschl
               lwa_leg_tab_c-vkorg
               lwa_leg_tab_c-vtweg
               lwa_leg_tab_c-kunnr
               lwa_leg_tab_c-konwa
               lwa_leg_tab_c-matnr
               lwa_leg_tab_c-kbetr
               lwa_leg_tab_c-kpein
               lwa_leg_tab_c-kmein
               lwa_leg_tab_c-datab
               lwa_leg_tab_c-datbi.

        APPEND lwa_leg_tab_c TO i_leg_tab_c.
      ENDLOOP. " LOOP AT li_string INTO lwa_string

      ASSIGN wa_leg_tab TO <fs_leg_tab> .
      LOOP AT i_leg_tab_c ASSIGNING <fs_leg_tab_c>.

        IF sy-tabix > 1.

          CONCATENATE <fs_leg_tab_c>-datab+6(4)
                      <fs_leg_tab_c>-datab+3(2)
                      <fs_leg_tab_c>-datab+0(2)
          INTO        <fs_leg_tab_c>-datab.


          CONCATENATE <fs_leg_tab_c>-datbi+6(4)
                      <fs_leg_tab_c>-datbi+3(2)
                      <fs_leg_tab_c>-datbi+0(2)
          INTO        <fs_leg_tab_c>-datbi.


          CLEAR lv_datum .
          lv_datum = <fs_leg_tab_c>-datab.
          CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
            EXPORTING
              date                      = lv_datum
            EXCEPTIONS
              plausibility_check_failed = 1
              OTHERS                    = 2.
          IF sy-subrc <> 0.

            CLEAR wa_report.
            wa_report-msgtyp = c_error.
            wa_report-msgtxt = text-024.
            CONCATENATE   <fs_leg_tab_c>-kschl
                          <fs_leg_tab_c>-vkorg
                          <fs_leg_tab_c>-vtweg
                          <fs_leg_tab_c>-kunnr
                          <fs_leg_tab_c>-konwa
                          <fs_leg_tab_c>-matnr
                          <fs_leg_tab_c>-kmein
                          <fs_leg_tab_c>-datab
                          <fs_leg_tab_c>-datbi
                          INTO gv_mkey SEPARATED BY space.

            wa_report-key    = gv_mkey.
            APPEND wa_report TO i_report.
            CLEAR wa_report.
            gv_error = gv_error + 1.
            gv_skip   = gv_skip + 1.
            APPEND  wa_leg_tab TO i_leg_tab_err.
            CONTINUE.

          ENDIF. " IF sy-subrc <> 0

          CLEAR lv_datum .
          lv_datum = <fs_leg_tab_c>-datab.
          CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
            EXPORTING
              date                      = lv_datum
            EXCEPTIONS
              plausibility_check_failed = 1
              OTHERS                    = 2.
          IF sy-subrc <> 0.
            CLEAR wa_report.
            wa_report-msgtyp = c_error.
            wa_report-msgtxt = text-025.
            CONCATENATE   <fs_leg_tab_c>-kschl
                          <fs_leg_tab_c>-vkorg
                          <fs_leg_tab_c>-vtweg
                          <fs_leg_tab_c>-kunnr
                          <fs_leg_tab_c>-konwa
                          <fs_leg_tab_c>-matnr
                          <fs_leg_tab_c>-kmein
                          <fs_leg_tab_c>-datab
                          <fs_leg_tab_c>-datbi
                          INTO gv_mkey SEPARATED BY space.

            wa_report-key    = gv_mkey.
            APPEND wa_report TO i_report.
            CLEAR wa_report.
            gv_error = gv_error + 1.
            gv_skip   = gv_skip + 1.
            APPEND  wa_leg_tab TO i_leg_tab_err.
            CONTINUE.
          ENDIF. " IF sy-subrc <> 0

          CLEAR lwa_legacy_tab.
          lwa_legacy_tab-object_type      = 'MARA'.
          lwa_legacy_tab-source_key_value = <fs_leg_tab_c>-matnr.
          APPEND lwa_legacy_tab TO li_legacy_tab.


          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = <fs_leg_tab_c>-kunnr
            IMPORTING
              output = <fs_leg_tab_c>-kunnr.

          MOVE-CORRESPONDING <fs_leg_tab_c> TO <fs_leg_tab>.


          IF cb_map <> c_selected.

            CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
              EXPORTING
                input        = wa_leg_tab-matnr
              IMPORTING
                output       = wa_leg_tab-matnr
              EXCEPTIONS
                length_error = 1
                OTHERS       = 2.

          ENDIF. " IF cb_map <> c_selected


          APPEND wa_leg_tab TO i_leg_tab.
        ENDIF. " IF sy-tabix > 1

      ENDLOOP. " LOOP AT i_leg_tab_c ASSIGNING <fs_leg_tab_c>
    ENDIF. " IF sy-subrc <> 0

* If Field KONWA is blank in file replace with WAERS from KNVV
    IF i_leg_tab[] IS NOT INITIAL.
* ---> Begin of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS

      REFRESH i_leg_tab_temp[].
      i_leg_tab_temp[] = i_leg_tab[].
      SORT  i_leg_tab_temp BY kunnr vkorg vtweg ASCENDING.
      DELETE ADJACENT DUPLICATES FROM i_leg_tab_temp COMPARING kunnr vkorg vtweg.
* <--- End of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS
      REFRESH i_knvv[].
* ---> Begin of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS
      IF i_leg_tab_temp[] IS NOT INITIAL.
* <--- End of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS
        SELECT  kunnr " Customer Number
                vkorg " Sales Organization
                vtweg " Distribution Channel
                waers " Currency
        FROM knvv     " Customer Master Sales Data
        INTO TABLE i_knvv
* ---> Begin of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS
*         FOR ALL ENTRIES IN i_leg_tab
*              WHERE kunnr = i_leg_tab-kunnr AND
*              vkorg = i_leg_tab-vkorg AND
*              vtweg = i_leg_tab-vtweg.
        FOR ALL ENTRIES IN i_leg_tab_temp
        WHERE kunnr = i_leg_tab_temp-kunnr AND
              vkorg = i_leg_tab_temp-vkorg AND
              vtweg = i_leg_tab_temp-vtweg.
* <--- End of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS
        IF sy-subrc = 0.
        ENDIF. " IF sy-subrc = 0
* ---> Begin of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS
      ENDIF. " IF i_leg_tab_temp[] IS NOT INITIAL
* <--- End of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS

      REFRESH i_leg_tab_temp[].
      i_leg_tab_temp[] = i_leg_tab[].
      SORT  i_leg_tab_temp  BY kunnr ASCENDING.
      DELETE ADJACENT DUPLICATES FROM i_leg_tab_temp COMPARING kunnr.
      REFRESH i_kna1[].
      IF i_leg_tab_temp[] IS NOT INITIAL.
        SELECT  kunnr " Customer Number
                aufsd " Central order block for customer
        FROM kna1     " General Data in Customer Master
        INTO TABLE i_kna1
        FOR ALL ENTRIES IN i_leg_tab_temp
        WHERE kunnr = i_leg_tab_temp-kunnr.
        IF sy-subrc = 0.
*&-- Begin of changes for HANAtization on PLM_EDD_0192 by SMUKHER on 19-Aug-2019 in M1SK900335
         SORT i_kna1 BY kunnr.
*&-- End of changes for HANAtization on PLM_EDD_0192 by SMUKHER on 19-Aug-2019 in M1SK900335
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF i_leg_tab_temp[] IS NOT INITIAL
    ENDIF. " IF i_leg_tab[] IS NOT INITIAL

    gv_file = lv_filename.
  ELSE. " ELSE -> IF sy-subrc = 0
* application server
    IF rb_app = c_selected.
      OPEN DATASET p_ahdr FOR INPUT IN TEXT MODE ENCODING DEFAULT. " Set as Ready for Input
      IF sy-subrc NE 0.
        MESSAGE i000  WITH 'Error in opening file.'(012).
        LEAVE LIST-PROCESSING.
      ELSE. " ELSE -> IF sy-subrc NE 0
        WHILE ( gv_subrc EQ 0 ).
          READ DATASET p_ahdr INTO lv_leg_tab.
          gv_subrc = sy-subrc.

          IF gv_subrc = 0 AND sy-index > 1.
            CLEAR : gv_kbetr,
                    gv_kpein,
                    gv_date_from,
                    gv_date_to.

            SPLIT lv_leg_tab  AT c_semicolon INTO
              wa_leg_tab-kschl
              wa_leg_tab-vkorg
              wa_leg_tab-vtweg
              wa_leg_tab-kunnr
              wa_leg_tab-konwa
              wa_leg_tab-matnr
              gv_kbetr
              gv_kpein
              wa_leg_tab-kmein
              gv_date_from
              gv_date_to.

            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = wa_leg_tab-kunnr
              IMPORTING
                output = wa_leg_tab-kunnr.

            wa_leg_tab-kbetr = gv_kbetr.
            wa_leg_tab-kpein = gv_kpein.


            CLEAR lv_date.
            CONCATENATE gv_date_from+6(4)
                        gv_date_from+3(2)
                        gv_date_from+0(2)
            INTO        lv_date.



            wa_leg_tab-datab = lv_date.
            CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
              EXPORTING
                date                      = lv_date
              EXCEPTIONS
                plausibility_check_failed = 1
                OTHERS                    = 2.
            IF sy-subrc <> 0.
              CLEAR wa_report.
              wa_report-msgtyp = c_error.
              wa_report-msgtxt = text-025.
              CONCATENATE   wa_leg_tab-kschl
                            wa_leg_tab-vkorg
                            wa_leg_tab-vtweg
                            wa_leg_tab-kunnr
                            wa_leg_tab-konwa
                            wa_leg_tab-matnr
                            gv_kbetr
                            gv_kpein
                            wa_leg_tab-kmein
                            gv_date_from
                            gv_date_to
                            INTO gv_mkey SEPARATED BY space.

              wa_report-key    = gv_mkey.
              APPEND wa_report TO i_report.
              CLEAR wa_report.
              gv_error = gv_error + 1.
              gv_skip   = gv_skip + 1.
              wa_leg_tab-datab = gv_date_from.
              wa_leg_tab-datbi = gv_date_to.
              APPEND  wa_leg_tab TO i_leg_tab_err.
              CONTINUE.
            ENDIF. " IF sy-subrc <> 0

            CLEAR lv_date.
            CONCATENATE gv_date_to+6(4)
                        gv_date_to+3(2)
                        gv_date_to+0(2)
            INTO        lv_date.

            wa_leg_tab-datbi = lv_date.
            CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
              EXPORTING
                date                      = lv_date
              EXCEPTIONS
                plausibility_check_failed = 1
                OTHERS                    = 2.
            IF sy-subrc <> 0.
              CLEAR wa_report.
              wa_report-msgtyp = c_error.
              wa_report-msgtxt = text-025.
              CONCATENATE   wa_leg_tab-kschl
                            wa_leg_tab-vkorg
                            wa_leg_tab-vtweg
                            wa_leg_tab-kunnr
                            wa_leg_tab-konwa
                            wa_leg_tab-matnr
                            gv_kbetr
                            gv_kpein
                            wa_leg_tab-kmein
                            gv_date_from
                            gv_date_to
                            INTO gv_mkey SEPARATED BY space.

              wa_report-key    = gv_mkey.
              APPEND wa_report TO i_report.
              CLEAR wa_report.
              gv_error  = gv_error + 1.
              gv_skip   = gv_skip + 1.
              wa_leg_tab-datab = gv_date_from.
              wa_leg_tab-datbi = gv_date_to.
              APPEND  wa_leg_tab TO i_leg_tab_err.
              CONTINUE.
            ENDIF. " IF sy-subrc <> 0

            REPLACE ALL OCCURRENCES OF c_nline IN wa_leg_tab-datbi WITH ''.
            IF NOT wa_leg_tab IS INITIAL.
              CLEAR lwa_legacy_tab.
              lwa_legacy_tab-object_type      = 'MARA'.
              lwa_legacy_tab-source_key_value = wa_leg_tab-matnr.
              APPEND lwa_legacy_tab TO li_legacy_tab.

              IF cb_map <> c_selected.

                CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
                  EXPORTING
                    input        = wa_leg_tab-matnr
                  IMPORTING
                    output       = wa_leg_tab-matnr
                  EXCEPTIONS
                    length_error = 1
                    OTHERS       = 2.

              ENDIF. " IF cb_map <> c_selected


              APPEND wa_leg_tab TO i_leg_tab.
            ENDIF. " IF NOT wa_leg_tab IS INITIAL
            CLEAR wa_leg_tab.
          ENDIF. " IF gv_subrc = 0 AND sy-index > 1
        ENDWHILE.
      ENDIF. " IF sy-subrc NE 0
      CLOSE DATASET p_ahdr.
      REFRESH i_knvv[].
      IF i_leg_tab[] IS NOT INITIAL.
* ---> Begin of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS
        REFRESH i_leg_tab_temp[].
        i_leg_tab_temp[] = i_leg_tab[].
        SORT  i_leg_tab_temp BY kunnr vkorg vtweg ASCENDING.
        DELETE ADJACENT DUPLICATES FROM i_leg_tab_temp COMPARING kunnr vkorg vtweg.
        IF i_leg_tab_temp[] IS NOT INITIAL.
* <--- End of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS
          SELECT  kunnr " Customer Number
                  vkorg " Sales Organization
                  vtweg " Distribution Channel
                  waers " Currency
          FROM knvv     " Customer Master Sales Data
          INTO TABLE i_knvv
* ---> Begin of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS
*        FOR ALL ENTRIES IN i_leg_tab
*        WHERE kunnr = i_leg_tab-kunnr AND
*              vkorg = i_leg_tab-vkorg AND
*              vtweg = i_leg_tab-vtweg.
          FOR ALL ENTRIES IN i_leg_tab_temp
          WHERE kunnr = i_leg_tab_temp-kunnr AND
                vkorg = i_leg_tab_temp-vkorg AND
                vtweg = i_leg_tab_temp-vtweg.
* <--- End of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS
          IF sy-subrc = 0.
          ENDIF. " IF sy-subrc = 0
* ---> Begin of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS
        ENDIF. " IF i_leg_tab_temp[] IS NOT INITIAL
* <--- End of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS

        REFRESH i_leg_tab_temp[].
        i_leg_tab_temp[] = i_leg_tab[].
        SORT  i_leg_tab_temp ASCENDING BY kunnr.
        DELETE ADJACENT DUPLICATES FROM i_leg_tab_temp COMPARING kunnr.
        IF i_leg_tab_temp[] IS NOT INITIAL.
          REFRESH i_kna1[].
          SELECT  kunnr " Customer Number
                  aufsd " Central order block for customer
          FROM kna1     " General Data in Customer Master
          INTO TABLE i_kna1
          FOR ALL ENTRIES IN i_leg_tab_temp
          WHERE kunnr = i_leg_tab_temp-kunnr.
          IF sy-subrc = 0.
*&-- Begin of changes for HANAtization on PLM_EDD_0192 by SMUKHER on 19-Aug-2019 in M1SK900335
           SORT i_kna1 BY kunnr.
*&-- End of changes for HANAtization on PLM_EDD_0192 by SMUKHER on 19-Aug-2019 in M1SK900335
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF i_leg_tab_temp[] IS NOT INITIAL
      ENDIF. " IF i_leg_tab[] IS NOT INITIAL
      gv_file = p_ahdr.
    ENDIF. " IF rb_app = c_selected
  ENDIF. " IF rb_pres = c_selected

* Mapping from Legacy System to ECC
  IF cb_map = c_selected.
* ---> Begin of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS
*    Preparing table li_legacy_tab.

*    SORT  li_legacy_tab BY object_type source_key_value ASCENDING.
*    DELETE ADJACENT DUPLICATES FROM li_legacy_tab COMPARING object_type source_key_value.
    SORT  li_legacy_tab BY  source_key_value ASCENDING.
    DELETE ADJACENT DUPLICATES FROM li_legacy_tab COMPARING  source_key_value.

    REFRESH li_ecc_tab[].
*<--- End of Change for D2_OTC_IDD_0042_Defect #1925 by NBAIS.
* ---> Begin of Change for D2_OTC_IDD_0042_Defect # 1925  by MSINGH1
    IF li_legacy_tab IS NOT INITIAL.
*Read record from table ZMDM_LEGCY_CROSS
      SELECT source_system    " Source System
             object_type      " Table Name
             ecc_key_value    " ECC Key Value
             source_key_value " Legacy Key Value
             other_value1     " Alternate Value
             other_value2     " Alternate Value
      FROM   zmdm_legcy_cross " Legacy Cross Reference  Table
      INTO TABLE li_ecc_tab
* ---> Begin of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS
        FOR ALL ENTRIES IN li_legacy_tab
        WHERE object_type      = 'MARA'
        AND source_key_value = li_legacy_tab-source_key_value.

*<--- End  of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS
      IF sy-subrc = 0.

      ENDIF. " IF sy-subrc = 0

    ENDIF. " if li_legacy_tab is NOT INITIAL
* <--- End of Change for D2_OTC_IDD_0042_Defect # 1925  by MSINGH1
*    SORT li_ecc_tab ASCENDING BY source_key_value.
    LOOP AT i_leg_tab ASSIGNING <fs_leg_tab>.
      CLEAR lwa_ecc_tab.

* ---> Begin of Change for D2_OTC_IDD_0042_Defect # 1925  by MSINGH1
*      READ TABLE li_ecc_tab INTO lwa_ecc_tab WITH KEY source_key_value = <fs_leg_tab>-matnr BINARY SEARCH.
      READ TABLE li_ecc_tab INTO lwa_ecc_tab WITH KEY source_key_value = <fs_leg_tab>-matnr. "BINARY SEARCH.
* <--- End of Change for D2_OTC_IDD_0042_Defect # 1925  by MSINGH1

      IF sy-subrc = 0.
        <fs_leg_tab>-matnr = lwa_ecc_tab-ecc_key_value.
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            input        = <fs_leg_tab>-matnr
          IMPORTING
            output       = <fs_leg_tab>-matnr
          EXCEPTIONS
            length_error = 1
            OTHERS       = 2.
      ELSE. " ELSE -> IF sy-subrc = 0
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            input        = <fs_leg_tab>-matnr
          IMPORTING
            output       = <fs_leg_tab>-matnr
          EXCEPTIONS
            length_error = 1
            OTHERS       = 2.
      ENDIF. " IF sy-subrc = 0
    ENDLOOP. " LOOP AT i_leg_tab ASSIGNING <fs_leg_tab>
  ENDIF. " IF cb_map = c_selected
* Check if material is allowed for a given sales org / distribution channel
  REFRESH i_leg_tab_temp[].
  i_leg_tab_temp[] = i_leg_tab[].
  SORT  i_leg_tab_temp ASCENDING BY matnr ASCENDING vkorg ASCENDING vtweg.
  DELETE ADJACENT DUPLICATES FROM i_leg_tab_temp COMPARING matnr vkorg vtweg.
  REFRESH i_mvke[].
  IF i_leg_tab_temp[] IS NOT INITIAL.
    SELECT  matnr " Material Number
            vkorg " Sales Organization
            vtweg " Distribution Channel
    FROM mvke     " Sales Data for Material
    INTO TABLE i_mvke
    FOR ALL ENTRIES IN i_leg_tab_temp
    WHERE   matnr =  i_leg_tab_temp-matnr AND
            vkorg =  i_leg_tab_temp-vkorg AND
            vtweg =  i_leg_tab_temp-vtweg.
    IF sy-subrc = 0.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF i_leg_tab_temp[] IS NOT INITIAL


ENDFORM. " F_UPLOAD_FILE1
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_SUMMARY
*&---------------------------------------------------------------------*
* Display ALV Log
*&---------------------------------------------------------------------*
FORM f_display_summary .
  gv_no_success1  = gv_tot - gv_error.
  gv_mode = text-032.
  IF rb_pres <> c_selected .
    PERFORM f_move USING    gv_file
                   CHANGING i_report[].
  ENDIF. " IF rb_pres <> c_selected

  PERFORM f_display_summary_report1  USING i_report[]
                                          gv_file
                                          gv_mode
                                          gv_no_success1
                                          gv_error.

ENDFORM. " F_DISPLAY_SUMMARY

*&---------------------------------------------------------------------*
*&      Form  F_MOVE
*&---------------------------------------------------------------------*
*  Move file from TBP to Done Folder & creates Error file in Folder
*  Error with Failed records for re-processing
*&---------------------------------------------------------------------*
FORM f_move USING fp_v_source TYPE localfile " Local file for upload/download
            CHANGING fp_i_report TYPE ty_t_report.

  CONSTANTS: lc_sept TYPE char1  VALUE '_', "Constant for Separator
             lc_dot  TYPE char1  VALUE '.'. "Constant for Dot Extension

  DATA: lv_file   TYPE localfile,  "File Name
        lv_name   TYPE localfile,  "Path Name
        lv_return TYPE sysubrc,    "Return Code
        lwa_report TYPE ty_report, "Report
        lv_data    TYPE string,    "Output data string
        lv_date1   TYPE char10,    " Date1 of type CHAR10
        lv_date2   TYPE char10,    " Date2 of type CHAR10
        lv_kbert   TYPE char20,    " Kbert of type CHAR20
        lv_kpein   TYPE char10,    " Kpein of type CHAR10
        lwa_leg_tab_error TYPE ty_leg_tab,
* Changes done by RRANA 16-Dec-013
        lv_ext1    TYPE localfile, "For splitting the file name
        lv_ext2    TYPE localfile. "For splitting the file name
* EOC by RRANA on 16-Dec-2013


  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_v_source
    IMPORTING
      pathname = lv_file
      filename = lv_name.


  REPLACE c_tobeprscd IN lv_file WITH c_done_fold .
  CONCATENATE lv_file lv_name  INTO lv_file.
*------Change done by RRANA 01-NOV-2013, D#13---------------*
  SPLIT lv_file AT lc_dot      INTO lv_ext1 lv_ext2. "Splitting the String at "."
  CONCATENATE lc_dot lv_ext2   INTO lv_ext2. "Adding Dot to lv_ext2
  CONCATENATE lv_ext1 sy-datum sy-uzeit INTO lv_file SEPARATED BY lc_sept.
  CONCATENATE lv_file lv_ext2 INTO lv_file. "Adding the extenson without separator

  PERFORM f_file_move  USING    fp_v_source
                                lv_file
                       CHANGING lv_return.
  IF lv_return IS INITIAL.
    gv_archive_gl_1 = lv_file.
  ELSE. " ELSE -> IF lv_return IS INITIAL
*-----End of change done by RRANA 01-NOV-2013, D#13----------*
    lwa_report-msgtyp = c_error.
    MESSAGE i000 WITH 'Input file'(011)
                       lv_file
                      'not moved.'(013)
            INTO lwa_report-msgtxt.
    APPEND lwa_report TO fp_i_report.
    CLEAR lwa_report.
  ENDIF. " IF lv_return IS INITIAL

  IF gv_error > 0.
    REPLACE c_done_fold IN lv_file WITH c_err_fold.
    OPEN DATASET lv_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " Output type
    IF sy-subrc NE 0.
      MESSAGE i006. "Error Folder could not be opened
      EXIT.
    ELSE. " ELSE -> IF sy-subrc NE 0
      CONCATENATE
      text-002 "'Condition type'
      text-003 "'Sales Organisation'
      text-004 "'Distribution Channel'
      text-005 "'Customer'
      text-006 "'Rate Unit'
      text-010 "'Material'
      text-015 "'Rate'
      text-016 "'Condition pricing unit'
      text-017 "'Condition unit'
      text-018 "'Validity from Date'
      text-019 "'Validity to Date'
      INTO lv_data
      SEPARATED BY c_semicolon.
      TRANSFER lv_data TO lv_file.
      CLEAR lv_data.



      LOOP AT i_leg_tab_err INTO lwa_leg_tab_error.

        IF lwa_leg_tab_error-datab CA '.'.
          lv_date1 = lwa_leg_tab_error-datab.
        ELSE. " ELSE -> IF lwa_leg_tab_error-datab CA ' '
          CLEAR lv_date1.
          CONCATENATE lwa_leg_tab_error-datab+6(2) '.'
                      lwa_leg_tab_error-datab+4(2) '.'
                      lwa_leg_tab_error-datab+0(4)
                      INTO lv_date1.
        ENDIF. " IF lwa_leg_tab_error-datab CA ' '

        IF lwa_leg_tab_error-datbi CA '.'.
          lv_date2 = lwa_leg_tab_error-datbi.
        ELSE. " ELSE -> IF lwa_leg_tab_error-datbi CA ' '
          CLEAR lv_date2.
          CONCATENATE lwa_leg_tab_error-datbi+6(2) '.'
                      lwa_leg_tab_error-datbi+4(2) '.'
                      lwa_leg_tab_error-datbi+0(4)
                      INTO lv_date2.
        ENDIF. " IF lwa_leg_tab_error-datbi CA ' '

        CLEAR : lv_kbert , lv_kpein.
        lv_kbert   =       lwa_leg_tab_error-kbetr.
        lv_kpein   =       lwa_leg_tab_error-kpein.
        CONCATENATE    lwa_leg_tab_error-kschl
                       lwa_leg_tab_error-vkorg
                       lwa_leg_tab_error-vtweg
                       lwa_leg_tab_error-kunnr
                       lwa_leg_tab_error-konwa
                       lwa_leg_tab_error-matnr
                       lv_kbert
                       lv_kpein
                       lwa_leg_tab_error-kmein
                       lv_date1
                       lv_date2
                       INTO lv_data
                       SEPARATED BY c_semicolon.

        TRANSFER lv_data TO lv_file.
        CLEAR lv_data.

      ENDLOOP. " LOOP AT i_leg_tab_err INTO lwa_leg_tab_error
    ENDIF. " IF sy-subrc NE 0
    CLOSE DATASET lv_file.
  ENDIF. " IF gv_error > 0
ENDFORM. " F_MOVE
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_DATA
*&---------------------------------------------------------------------*
* Creates Pricing Condition Records . Not released Function modules :
* RV_CONDITION_COPY
* RV_CONDITION_SAVE
* RV_CONDITION_RESET
* are warapped up into Z FM ZOTC_RV_CONDITION_COPY.
*&--------------------------------------------------------------------*
FORM f_upload_data .

  DATA : lwa_komg TYPE komg,                                  " Allowed Fields for Condition Structures
         lwa_komp TYPE komp,                                  " Communication Item for Pricing
         lwa_komv TYPE komv,                                  " Pricing Communications-Condition Record
         lwa_komk TYPE komk,                                  " Communication Header for Pricing

         li_komv  TYPE STANDARD TABLE OF komv INITIAL SIZE 0, " Pricing Communications-Condition Record
         lv_new_record ,
         lv_date_from TYPE datum,                             " Date
         lv_date_to   TYPE datum.                             " Date
*---> Begin of Change for Defect# 1925 by KBANSAL.
  CONSTANTS:

            lc_v        TYPE kappl          VALUE 'V'. " Application
*<--- End of Change for Defect# 1925 by KBANSAL.

  FIELD-SYMBOLS : <lfs_mvke> TYPE ty_mvke.


  SORT i_knvv ASCENDING BY kunnr
              ASCENDING    vkorg
              ASCENDING    vtweg.


  DESCRIBE TABLE i_leg_tab LINES gv_tot.

  gv_tot = gv_tot + gv_skip.

  IF i_leg_tab[] IS NOT INITIAL.
* ---> Begin of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS
    REFRESH i_leg_tab_temp[].
    i_leg_tab_temp[] = i_leg_tab[].
    SORT  i_leg_tab_temp BY kschl vkorg vtweg kunnr matnr ASCENDING.
    DELETE ADJACENT DUPLICATES FROM i_leg_tab_temp COMPARING kschl vkorg vtweg kunnr matnr.

    IF i_leg_tab_temp[] IS NOT INITIAL.
* <--- End of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS

      SELECT  kappl " Application
              kschl " Condition type
              vkorg " Sales Organization
              vtweg " Distribution Channel
              kunnr " Customer number
              matnr " Material Number
              datbi " Validity end date of the condition record
              datab " Validity start date of the condition record
              knumh " Condition record number
      FROM a005 INTO TABLE i_a005
* ---> Begin of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS
*      FOR ALL ENTRIES IN i_leg_tab
*      WHERE   kschl  = i_leg_tab-kschl AND
*              vkorg  = i_leg_tab-vkorg AND
*              vtweg  = i_leg_tab-vtweg AND
*              kunnr  = i_leg_tab-kunnr AND
*              matnr  = i_leg_tab-matnr.
       FOR ALL ENTRIES IN i_leg_tab_temp
       WHERE   kappl  = lc_v                 AND
               kschl  = i_leg_tab_temp-kschl AND
               vkorg  = i_leg_tab_temp-vkorg AND
               vtweg  = i_leg_tab_temp-vtweg AND
               kunnr  = i_leg_tab_temp-kunnr AND
               matnr  = i_leg_tab_temp-matnr.
      IF sy-subrc = 0.
      ENDIF. " IF sy-subrc = 0
* ---> Begin of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS
    ENDIF. " IF i_leg_tab_temp[] IS NOT INITIAL
* <--- End of Change for D2_OTC_IDD_0042_Defect # 1925  by NBAIS



    SELECT kschl " Condition Type
    FROM   t685  " Conditions: Types
    INTO TABLE i_t685.
    IF sy-subrc = 0.
    ENDIF. " IF sy-subrc = 0


    SELECT vkorg " Sales Organization
    FROM   tvko  " Organizational Unit: Sales Organizations
    INTO TABLE i_tvko.
    IF sy-subrc = 0.
    ENDIF. " IF sy-subrc = 0


    SELECT vtweg " Distribution Channel
    FROM   tvtw  " Organizational Unit: Distribution Channels
    INTO TABLE i_tvtw.
    IF sy-subrc = 0.
    ENDIF. " IF sy-subrc = 0


    SELECT waers " Currency Key
    FROM   tcurc " Currency Codes
    INTO TABLE i_tcurc.
    IF sy-subrc = 0.
    ENDIF. " IF sy-subrc = 0

    SELECT msehi " Unit of Measurement
    FROM   t006  " Units of Measurement
    INTO TABLE i_t006.
    IF sy-subrc = 0.
    ENDIF. " IF sy-subrc = 0




  ENDIF. " IF i_leg_tab[] IS NOT INITIAL





  SORT i_a005 ASCENDING BY  kappl
              ASCENDING kschl
              ASCENDING vkorg
              ASCENDING vtweg
              ASCENDING kunnr
              ASCENDING matnr
              ASCENDING datbi
              ASCENDING datab.

  SORT i_t685  ASCENDING BY kschl.
  SORT i_tvko  ASCENDING BY vkorg.
  SORT i_tvtw  ASCENDING BY vtweg.
  SORT i_tcurc ASCENDING BY waers.
  SORT i_t006  ASCENDING BY msehi.






  CLEAR wa_leg_tab.
  LOOP AT i_leg_tab INTO wa_leg_tab.

*Start of CR 143 - Convert Currency to Internal SAP format
    DATA : lv_curr_amt TYPE bapicurr-bapicurr. " Currency amount in BAPI interfaces
    DATA : lv_kbetr    TYPE konp-kbetr. " Rate (condition amount or percentage) where no scale exists
    CLEAR lv_curr_amt.
    lv_curr_amt = wa_leg_tab-kbetr.
    CLEAR lv_kbetr.
* ---> Begin of Change for D2_OTC_IDD_0042_Defect #1925 by MSINGH1

* To avoid dump at the time of coversion of currency amount field.
    TRY .
        lv_kbetr = lv_curr_amt.

      CATCH cx_sy_conversion_overflow.
        CLEAR wa_report.
        wa_report-msgtyp = c_error.
        wa_report-msgtxt = text-034.
        CONCATENATE   wa_leg_tab-kschl
                      wa_leg_tab-vkorg
                      wa_leg_tab-vtweg
                      wa_leg_tab-kunnr
                      wa_leg_tab-konwa
                      wa_leg_tab-matnr
                      wa_leg_tab-kmein
                      wa_leg_tab-datab
                      wa_leg_tab-datbi
                      INTO gv_mkey SEPARATED BY space.
        wa_report-key    = gv_mkey.
        APPEND wa_report TO i_report.
        CLEAR wa_report.
        gv_error = gv_error + 1.
        APPEND  wa_leg_tab TO i_leg_tab_err.
        CONTINUE.
    ENDTRY.

    CLEAR lv_kbetr.
* <--- End  of Change for D2_OTC_IDD_0042_Defect #1925 by MSINGH1

    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
      EXPORTING
        currency             = wa_leg_tab-konwa
        amount_external      = lv_curr_amt
        max_number_of_digits = '23'
      IMPORTING
        amount_internal      = lv_kbetr.
*End of CR  143 - Convert Currency to Internal SAP format

* Check customer
    CLEAR wa_kna1.
    READ TABLE i_kna1 INTO wa_kna1 WITH KEY kunnr = wa_leg_tab-kunnr BINARY SEARCH.
    IF sy-subrc = 0.
* Customer is Blocked
      IF wa_kna1-aufsd IS NOT INITIAL.
        CLEAR wa_report.
        wa_report-msgtyp = c_error.
        wa_report-msgtxt = text-020.
        CONCATENATE   wa_leg_tab-kschl
                      wa_leg_tab-vkorg
                      wa_leg_tab-vtweg
                      wa_leg_tab-kunnr
                      wa_leg_tab-konwa
                      wa_leg_tab-matnr
                      wa_leg_tab-kmein
                      wa_leg_tab-datab
                      wa_leg_tab-datbi
                      INTO gv_mkey SEPARATED BY space.

        wa_report-key    = gv_mkey.
        APPEND wa_report TO i_report.
        CLEAR wa_report.
        gv_error = gv_error + 1.
        APPEND  wa_leg_tab TO i_leg_tab_err.
        CONTINUE.
      ENDIF. " IF wa_kna1-aufsd IS NOT INITIAL
    ELSE. " ELSE -> IF wa_kna1-aufsd IS NOT INITIAL
* Invalid Customer Number
      CLEAR wa_report.
      wa_report-msgtyp = c_error.
      wa_report-msgtxt = text-023.
      CONCATENATE   wa_leg_tab-kschl
                    wa_leg_tab-vkorg
                    wa_leg_tab-vtweg
                    wa_leg_tab-kunnr
                    wa_leg_tab-konwa
                    wa_leg_tab-matnr
                    wa_leg_tab-kmein
                    wa_leg_tab-datab
                    wa_leg_tab-datbi
                    INTO gv_mkey SEPARATED BY space.

      wa_report-key    = gv_mkey.
      APPEND wa_report TO i_report.
      CLEAR wa_report.
      gv_error = gv_error + 1.
      APPEND  wa_leg_tab TO i_leg_tab_err.
      CONTINUE.
    ENDIF. " IF sy-subrc = 0


    CLEAR wa_t685.
    READ TABLE i_t685 INTO wa_t685 WITH KEY kschl = wa_leg_tab-kschl BINARY SEARCH.
    IF sy-subrc <> 0.
      CLEAR wa_report.
      wa_report-msgtyp = c_error.
      wa_report-msgtxt = text-026.
      CONCATENATE   wa_leg_tab-kschl
                    wa_leg_tab-vkorg
                    wa_leg_tab-vtweg
                    wa_leg_tab-kunnr
                    wa_leg_tab-konwa
                    wa_leg_tab-matnr
                    wa_leg_tab-kmein
                    wa_leg_tab-datab
                    wa_leg_tab-datbi
                    INTO gv_mkey SEPARATED BY space.

      wa_report-key    = gv_mkey.
      APPEND wa_report TO i_report.
      CLEAR wa_report.
      gv_error = gv_error + 1.
      APPEND  wa_leg_tab TO i_leg_tab_err.
      CONTINUE.
    ENDIF. " IF sy-subrc <> 0


    CLEAR wa_tvko.
    READ TABLE i_tvko INTO wa_tvko WITH KEY vkorg = wa_leg_tab-vkorg BINARY SEARCH.
    IF sy-subrc <> 0.
      CLEAR wa_report.
      wa_report-msgtyp = c_error.
      wa_report-msgtxt = text-027.
      CONCATENATE   wa_leg_tab-kschl
                    wa_leg_tab-vkorg
                    wa_leg_tab-vtweg
                    wa_leg_tab-kunnr
                    wa_leg_tab-konwa
                    wa_leg_tab-matnr
                    wa_leg_tab-kmein
                    wa_leg_tab-datab
                    wa_leg_tab-datbi
                    INTO gv_mkey SEPARATED BY space.

      wa_report-key    = gv_mkey.
      APPEND wa_report TO i_report.
      CLEAR wa_report.
      gv_error = gv_error + 1.
      APPEND  wa_leg_tab TO i_leg_tab_err.
      CONTINUE.
    ENDIF. " IF sy-subrc <> 0


    CLEAR wa_tvtw.
    READ TABLE i_tvtw INTO wa_tvtw WITH KEY vtweg = wa_leg_tab-vtweg BINARY SEARCH.
    IF sy-subrc <> 0.
      CLEAR wa_report.
      wa_report-msgtyp = c_error.
      wa_report-msgtxt = text-028.
      CONCATENATE   wa_leg_tab-kschl
                    wa_leg_tab-vkorg
                    wa_leg_tab-vtweg
                    wa_leg_tab-kunnr
                    wa_leg_tab-konwa
                    wa_leg_tab-matnr
                    wa_leg_tab-kmein
                    wa_leg_tab-datab
                    wa_leg_tab-datbi
                    INTO gv_mkey SEPARATED BY space.

      wa_report-key    = gv_mkey.
      APPEND wa_report TO i_report.
      CLEAR wa_report.
      gv_error = gv_error + 1.
      APPEND  wa_leg_tab TO i_leg_tab_err.
      CONTINUE.
    ENDIF. " IF sy-subrc <> 0



    CLEAR wa_tcurc.
    READ TABLE i_tcurc INTO wa_tcurc WITH KEY waers = wa_leg_tab-konwa BINARY SEARCH.
    IF sy-subrc <> 0.
      CLEAR wa_report.
      wa_report-msgtyp = c_error.
      wa_report-msgtxt = text-029.
      CONCATENATE   wa_leg_tab-kschl
                    wa_leg_tab-vkorg
                    wa_leg_tab-vtweg
                    wa_leg_tab-kunnr
                    wa_leg_tab-konwa
                    wa_leg_tab-matnr
                    wa_leg_tab-kmein
                    wa_leg_tab-datab
                    wa_leg_tab-datbi
                    INTO gv_mkey SEPARATED BY space.

      wa_report-key    = gv_mkey.
      APPEND wa_report TO i_report.
      CLEAR wa_report.
      gv_error = gv_error + 1.
      APPEND  wa_leg_tab TO i_leg_tab_err.
      CONTINUE.
    ENDIF. " IF sy-subrc <> 0


    CLEAR wa_t006.
    READ TABLE i_t006 INTO wa_t006 WITH KEY msehi = wa_leg_tab-kmein BINARY SEARCH.
    IF sy-subrc <> 0.
      CLEAR wa_report.
      wa_report-msgtyp = c_error.
      wa_report-msgtxt = text-030.
      CONCATENATE   wa_leg_tab-kschl
                    wa_leg_tab-vkorg
                    wa_leg_tab-vtweg
                    wa_leg_tab-kunnr
                    wa_leg_tab-konwa
                    wa_leg_tab-matnr
                    wa_leg_tab-kmein
                    wa_leg_tab-datab
                    wa_leg_tab-datbi
                    INTO gv_mkey SEPARATED BY space.

      wa_report-key    = gv_mkey.
      APPEND wa_report TO i_report.
      CLEAR wa_report.
      gv_error = gv_error + 1.
      APPEND  wa_leg_tab TO i_leg_tab_err.
      CONTINUE.
    ENDIF. " IF sy-subrc <> 0


    CLEAR : lv_date_from , lv_date_to.
    lv_date_from = wa_leg_tab-datab.
    lv_date_to   = wa_leg_tab-datbi.
    CLEAR lwa_komg.
    lwa_komg-vkorg = wa_leg_tab-vkorg.
    lwa_komg-vtweg = wa_leg_tab-vtweg.
    lwa_komg-kunnr = wa_leg_tab-kunnr.
    lwa_komg-matnr = wa_leg_tab-matnr.

    CLEAR lwa_komv.
    REFRESH li_komv[].
    lwa_komv-kappl = c_app_area.
    lwa_komv-kschl = wa_leg_tab-kschl.

    lwa_komv-waers = wa_leg_tab-konwa.
    IF lwa_komv-waers IS INITIAL.
      CLEAR wa_knvv.
      READ TABLE i_knvv INTO wa_knvv WITH KEY  kunnr = wa_leg_tab-kunnr
                                               vkorg = wa_leg_tab-vkorg
                                               vtweg = wa_leg_tab-vtweg
                                      BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_komv-waers = wa_knvv-waers.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF lwa_komv-waers IS INITIAL

    lwa_komv-kmein = wa_leg_tab-kmein.
    lwa_komv-kpein = wa_leg_tab-kpein.
    lwa_komv-kbetr = lv_kbetr.

*    lwa_komv-kbetr = wa_leg_tab-kbetr.
*   LWA_KOMV-KRECH = 'C'.

* CHECK IF RECORD ALREADY EXISTS
    CLEAR wa_a005.
    READ TABLE i_a005 INTO wa_a005 WITH KEY
    kappl = c_app_area
    kschl = wa_leg_tab-kschl
    vkorg = wa_leg_tab-vkorg
    vtweg = wa_leg_tab-vtweg
    kunnr = wa_leg_tab-kunnr
    matnr = wa_leg_tab-matnr
    datbi = lv_date_to
    datab = lv_date_from BINARY SEARCH.

    IF sy-subrc <> 0.
*Create
      APPEND lwa_komv TO li_komv.

      READ TABLE i_mvke ASSIGNING <lfs_mvke> WITH KEY matnr = wa_leg_tab-matnr
                                                      vkorg = wa_leg_tab-vkorg
                                                      vtweg = wa_leg_tab-vtweg.

      IF sy-subrc = 0.


        CALL FUNCTION 'ZOTC_RV_CONDITION_COPY'
          EXPORTING
            application                 = lwa_komv-kappl
            condition_table             = c_table
            condition_type              = wa_leg_tab-kschl
            date_from                   = lv_date_from
            date_to                     = lv_date_to
            enqueue                     = c_selected
            i_komk                      = lwa_komk
            i_komp                      = lwa_komp
            key_fields                  = lwa_komg
            maintain_mode               = c_mode_a
            no_authority_check          = c_selected
            keep_old_records            = c_selected
            overlap_confirmed           = c_selected
            no_db_update                = space
          IMPORTING
            e_komk                      = lwa_komk
            e_komp                      = lwa_komp
            new_record                  = lv_new_record
          TABLES
            copy_records                = li_komv
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
          PERFORM f_log_msg.
        ELSE. " ELSE -> IF sy-subrc = 0
          gv_error = gv_error + 1.
          APPEND  wa_leg_tab TO i_leg_tab_err.
          PERFORM f_log_msg.
        ENDIF. " IF sy-subrc = 0
      ELSE. " ELSE -> IF sy-subrc = 0
        CLEAR wa_report.
        wa_report-msgtyp = c_error.
        CONCATENATE text-033 ': 'wa_leg_tab-matnr ','
                                 wa_leg_tab-vkorg ','
                                 wa_leg_tab-vtweg
        INTO              wa_report-msgtxt  .
        CONCATENATE   wa_leg_tab-kschl
                      wa_leg_tab-vkorg
                      wa_leg_tab-vtweg
                      wa_leg_tab-kunnr
                      wa_leg_tab-konwa
                      wa_leg_tab-matnr
                      wa_leg_tab-kmein
                      wa_leg_tab-datab
                      wa_leg_tab-datbi
                      INTO gv_mkey SEPARATED BY space.
        wa_report-key    = gv_mkey.
        APPEND wa_report TO i_report.
        CLEAR wa_report.
        gv_error = gv_error + 1.
        gv_skip   = gv_skip + 1.
        APPEND  wa_leg_tab TO i_leg_tab_err.
      ENDIF. " IF sy-subrc = 0

    ELSE. " ELSE -> IF sy-subrc <> 0
*Change
      lwa_komv-knumh = wa_a005-knumh.
*     LWA_KOMV-KPOSN = '01'.
      APPEND lwa_komv TO li_komv.

      READ TABLE i_mvke ASSIGNING <lfs_mvke> WITH KEY matnr = wa_leg_tab-matnr
                                                      vkorg = wa_leg_tab-vkorg
                                                      vtweg = wa_leg_tab-vtweg.

      IF sy-subrc = 0.

        CALL FUNCTION 'ZOTC_RV_CONDITION_COPY'
          EXPORTING
            application                 = lwa_komv-kappl
            condition_table             = c_table
            condition_type              = wa_leg_tab-kschl
            date_from                   = lv_date_from
            date_to                     = lv_date_to
            enqueue                     = c_selected
            key_fields                  = lwa_komg
            maintain_mode               = c_mode_b
            no_authority_check          = c_selected
            no_field_check              = 'X'
            selection_date              = lv_date_to
          TABLES
            copy_records                = li_komv
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
          PERFORM f_log_msg.
        ELSE. " ELSE -> IF sy-subrc = 0
          gv_error = gv_error + 1.
          APPEND  wa_leg_tab TO i_leg_tab_err.
          PERFORM f_log_msg.
        ENDIF. " IF sy-subrc = 0
      ELSE. " ELSE -> IF sy-subrc = 0
        CLEAR wa_report.
        wa_report-msgtyp = c_error.
        CONCATENATE text-033 ': 'wa_leg_tab-matnr ','
                                 wa_leg_tab-vkorg ','
                                 wa_leg_tab-vtweg
        INTO              wa_report-msgtxt .


        CONCATENATE   wa_leg_tab-kschl
                      wa_leg_tab-vkorg
                      wa_leg_tab-vtweg
                      wa_leg_tab-kunnr
                      wa_leg_tab-konwa
                      wa_leg_tab-matnr
                      wa_leg_tab-kmein
                      wa_leg_tab-datab
                      wa_leg_tab-datbi
                      INTO gv_mkey SEPARATED BY space.
        wa_report-key    = gv_mkey.
        APPEND wa_report TO i_report.
        CLEAR wa_report.
        gv_error = gv_error + 1.
        gv_skip   = gv_skip + 1.
        APPEND  wa_leg_tab TO i_leg_tab_err.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc <> 0
  ENDLOOP. " LOOP AT i_leg_tab INTO wa_leg_tab
ENDFORM. " F_UPLOAD_DATA

*&---------------------------------------------------------------------*
*&      Form  F_LOG_ERROR
*&---------------------------------------------------------------------*
* Get Message Description
*&---------------------------------------------------------------------*
FORM f_log_msg.
  DATA : lwa_return TYPE bapiret2,     " Return Parameter
         lv_par1 TYPE char50,          " Par1 of type CHAR50
         lv_par2 TYPE char50,          " Par2 of type CHAR50
         lv_par3 TYPE char50,          " Par3 of type CHAR50
         lv_par4 TYPE char50,          " Par4 of type CHAR50
         lv_num  TYPE bapiret2-number. " Message Number
  CLEAR : lwa_return ,
          lv_par1 ,
          lv_par2 ,
          lv_par3 ,
          lv_par4,
          lv_num.

  lv_par1 = syst-msgv1.
  lv_par2 = syst-msgv2.
  lv_par3 = syst-msgv3.
  lv_par4 = syst-msgv4.
  lv_num  = syst-msgno.

  CALL FUNCTION 'BALW_BAPIRETURN_GET2'
    EXPORTING
      type   = syst-msgty "  of type
      cl     = syst-msgid
      number = lv_num
      par1   = lv_par1
      par2   = lv_par2
      par3   = lv_par3
      par4   = lv_par4
    IMPORTING
      return = lwa_return.

  CLEAR wa_report.
  wa_report-msgtyp = syst-msgty.
  IF wa_report-msgtyp <> c_error.
    IF wa_a005 IS NOT INITIAL.
      wa_report-msgtxt = text-021.
    ELSE. " ELSE -> IF wa_a005 IS NOT INITIAL
      wa_report-msgtxt = text-022.
    ENDIF. " IF wa_a005 IS NOT INITIAL
  ELSE. " ELSE -> IF wa_report-msgtyp <> c_error
    wa_report-msgtxt = lwa_return-message.
  ENDIF. " IF wa_report-msgtyp <> c_error

  CLEAR : gv_kbetr , gv_kpein.
  gv_kbetr =          wa_leg_tab-kbetr.
  gv_kpein =          wa_leg_tab-kpein.

  CONCATENATE   wa_leg_tab-kschl
                wa_leg_tab-vkorg
                wa_leg_tab-vtweg
                wa_leg_tab-kunnr
                wa_leg_tab-konwa
                wa_leg_tab-matnr
                gv_kbetr
                gv_kpein
                wa_leg_tab-kmein
                wa_leg_tab-datab
                wa_leg_tab-datbi
                INTO gv_mkey SEPARATED BY space.

  wa_report-key    = gv_mkey.
  APPEND wa_report TO i_report.
  CLEAR wa_report.
ENDFORM. " F_LOG_ERROR
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_SUMMARY_REPORT1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_REPORT[]  text
*      -->P_GV_FILE  text
*      -->P_GV_MODE  text
*      -->P_GV_NO_SUCCESS  text
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM f_display_summary_report1 USING fp_i_report      TYPE ty_t_report_p
                                    fp_gv_filename_d TYPE localfile " Local file for upload/download
                                    fp_gv_mode       TYPE char10    " Gv_mode of type CHAR10
                                    fp_no_success    TYPE int4      " Natural Number
                                    fp_no_failed     TYPE int4.     " Natural Number
* Local Data declaration
  TYPES: BEGIN OF ty_report_b,
          msgtyp TYPE char1,   "Error Type
          msgtxt TYPE char256, "Error Text
          key    TYPE char256, "Error Key
         END OF ty_report_b.

  CONSTANTS: c_hline TYPE char100          " Dotted Line
             VALUE
'-----------------------------------------------------------',
             c_slash TYPE char1 VALUE '/'. " Slash of type CHAR1

  DATA: li_report      TYPE STANDARD TABLE OF ty_report_b
                                                     INITIAL SIZE 0,
        lv_uzeit       TYPE char20,                          "Time
        lv_datum       TYPE char20,                          "Date
        lv_total       TYPE i,                               "Total
        lv_rate        TYPE i,                               "Rate
        lv_rate_c      TYPE char5,                           "Rate text
        lv_alv         TYPE REF TO cl_salv_table,            "ALV Inst.
        lv_ex_msg      TYPE REF TO cx_salv_msg,              "Message
        lv_ex_notfound TYPE REF TO cx_salv_not_found,        "Exception
        lv_grid        TYPE REF TO cl_salv_form_layout_grid, "Grid
        lv_gridx       TYPE REF TO cl_salv_form_layout_grid, "Grid X
        lv_column      TYPE REF TO cl_salv_column_table,     "Column
        lv_columns     TYPE REF TO cl_salv_columns_table,    "Column X
        lv_func        TYPE REF TO cl_salv_functions_list,   "Toolbar
        lv_archive_1   TYPE localfile,                       "Archieve File Path
        lv_session_1   TYPE apq_grpn,                        "BDC Session Name
        lv_session_2   TYPE apq_grpn,                        "BDC Session Name
        lv_session_3   TYPE apq_grpn,                        "BDC Session Name
        lv_session(90) TYPE c,                               "All session names
        lv_row         TYPE i,                               "Row number
        lv_width_msg   TYPE outputlen,                       "Column Width
        lv_width_key   TYPE outputlen,                       "Column Width
        li_fieldcat    TYPE slis_t_fieldcat_alv,             "Field Catalog
        li_events      TYPE slis_t_event,
        lwa_events     TYPE slis_alv_event,
        li_report_b    TYPE STANDARD TABLE OF ty_report_b,
        lwa_report_b   TYPE ty_report_b.

  FIELD-SYMBOLS: <fs> TYPE ty_report_p.

* Getting the archieve file path from Global Variables
  lv_archive_1 = gv_archive_gl_1.

* Importing the First Session Names
  lv_session_1 = gv_session_gl_1.

* Importing the Second Session Names
  lv_session_2 = gv_session_gl_2.

* Importing the Third Session Names
  lv_session_3 = gv_session_gl_3.

* Forming the BDC session name
  IF lv_session_1 IS NOT INITIAL.
    lv_session = lv_session_1.
  ENDIF. " IF lv_session_1 IS NOT INITIAL

  IF lv_session_2 IS NOT INITIAL.
    IF lv_session IS NOT INITIAL.
      CONCATENATE lv_session c_slash lv_session_2
      INTO lv_session SEPARATED BY space.
    ELSE. " ELSE -> IF lv_session IS NOT INITIAL
      lv_session = lv_session_2.
    ENDIF. " IF lv_session IS NOT INITIAL
  ENDIF. " IF lv_session_2 IS NOT INITIAL

  IF lv_session_3 IS NOT INITIAL.
    IF lv_session IS NOT INITIAL.
      CONCATENATE lv_session c_slash lv_session_3
      INTO lv_session SEPARATED BY space.
    ELSE. " ELSE -> IF lv_session IS NOT INITIAL
      lv_session = lv_session_3.
    ENDIF. " IF lv_session IS NOT INITIAL
  ENDIF. " IF lv_session_3 IS NOT INITIAL

  IF lv_session IS NOT INITIAL.
    CONCATENATE lv_session text-x32 INTO lv_session
    SEPARATED BY space.
  ENDIF. " IF lv_session IS NOT INITIAL

  LOOP AT fp_i_report ASSIGNING <fs>.
    lwa_report_b-msgtyp = <fs>-msgtyp.
    lwa_report_b-msgtxt = <fs>-msgtxt.
    lwa_report_b-key = <fs>-key.
    APPEND lwa_report_b TO li_report.
    CLEAR lwa_report_b.
  ENDLOOP. " LOOP AT fp_i_report ASSIGNING <fs>
*
*  li_report[] = fp_i_report[].

  WRITE sy-uzeit TO lv_uzeit.
  WRITE sy-datum TO lv_datum.
  CONCATENATE lv_datum lv_uzeit INTO lv_datum SEPARATED BY space.

  lv_total = fp_no_success + fp_no_failed.
  IF lv_total <> 0.
    lv_rate = 100 * fp_no_success / lv_total.
  ENDIF. " IF lv_total <> 0

  WRITE lv_rate TO lv_rate_c.
  CONDENSE lv_rate_c.
  CONCATENATE lv_rate_c c_percentage INTO lv_rate_c SEPARATED BY space.

* For ONLINE run, ALV Grid Display
  IF sy-batch IS INITIAL.

    TRY.
        CALL METHOD cl_salv_table=>factory
          IMPORTING
            r_salv_table = lv_alv
          CHANGING
            t_table      = li_report.
      CATCH cx_salv_msg INTO lv_ex_msg.
        MESSAGE lv_ex_msg TYPE 'E'.
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.

    CREATE OBJECT lv_grid.
    lv_row = 1.
    lv_grid->create_header_information( row     = lv_row
                                        column  = lv_row
                                        text    = text-x01
                                        tooltip = text-x02 ).

    lv_row = lv_row + 1.
    lv_gridx = lv_grid->create_grid( row = lv_row  column = 1  ).

    lv_gridx->create_label( row = lv_row column = 1
                           text = c_hline ).
    lv_row = lv_row + 1.
* File Read
    lv_gridx->create_label( row = lv_row column = 1
                            text = text-x02 tooltip = text-x02 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = fp_gv_filename_d ).

    lv_row = lv_row + 1.
* File Archived.
    IF lv_archive_1 IS NOT INITIAL.
      lv_gridx->create_label( row = lv_row column = 1
                              text = text-x28 tooltip = text-x28 ).
      lv_gridx->create_label( row = lv_row column = 2
                              text = ':' ).
      lv_gridx->create_label( row = lv_row column = 3
                              text = lv_archive_1 ).
      lv_row = lv_row + 1.
    ENDIF. " IF lv_archive_1 IS NOT INITIAL

    lv_gridx->create_label( row = lv_row column = 1
                            text = text-x03 tooltip = text-x03 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = sy-mandt ).
    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                           text = text-x04 tooltip = text-x04 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = sy-uname ).
    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                           text = text-x05 tooltip = text-x05 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = lv_datum ).
    lv_row = lv_row + 1.

    lv_gridx->create_label( row = lv_row column = 1
                           text = text-x06 tooltip = text-x06 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = fp_gv_mode ).
    lv_row = lv_row + 1.

    IF lv_session IS NOT INITIAL.
      lv_gridx->create_label( row = lv_row column = 1
                             text = text-x29 tooltip = text-x29 ).
      lv_gridx->create_label( row = lv_row column = 2
                              text = ':' ).
      lv_gridx->create_label( row = lv_row column = 3
                              text = lv_session ).
      lv_row = lv_row + 1.
    ENDIF. " IF lv_session IS NOT INITIAL

    lv_gridx->add_row( ).

    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                           text = c_hline ).
    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                         text = text-x08 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = lv_total ).
    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                         text = text-x09 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = fp_no_success ).
    lv_row = lv_row + 1.

    lv_gridx->create_label( row = lv_row column = 1
                         text = text-x10 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = fp_no_failed ).
    lv_row = lv_row + 1.

    lv_gridx->create_label( row = lv_row column = 1
                         text = text-x11 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = lv_rate_c ).

    lv_row = lv_row + 1.

    lv_gridx->create_label( row = lv_row column = 1
                           text = c_hline ).

    CALL METHOD lv_alv->set_top_of_list( lv_grid ).

    CALL METHOD lv_alv->get_columns
      RECEIVING
        value = lv_columns.

    TRY.
        lv_column ?= lv_columns->get_column( 'MSGTYP' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( text-x12 ).
    lv_column->set_medium_text( text-x12 ).
    lv_column->set_long_text( text-x12 ).
*   lv_column->set_output_length( 20 ).
    lv_columns->set_optimize( 'X' ).

    TRY.
        lv_column ?= lv_columns->get_column( 'MSGTXT' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( text-x13 ).
    lv_column->set_medium_text( text-x13 ).
    lv_column->set_long_text( text-x13 ).
    lv_columns->set_optimize( 'X' ).

    TRY.
        lv_column ?= lv_columns->get_column( 'KEY' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( text-x14 ).
    lv_column->set_medium_text( text-x14 ).
    lv_column->set_long_text( text-x14 ).
    lv_columns->set_optimize( 'X' ).

* Function Tool bars
    lv_func = lv_alv->get_functions( ).
    lv_func->set_all( ).

* Displaying the report
    CALL METHOD lv_alv->display( ).

* For Background Run - ALV List
  ELSE. " ELSE -> IF lv_session IS NOT INITIAL
*   Passing local variable values to global variable to make it
*   avilable in top of page subroutine.
    gv_filename_d = fp_gv_filename_d.
    gv_filename_d_arch = lv_archive_1.
    gv_mode_b = fp_gv_mode.
    gv_session = lv_session.
*defect     1240
*    gv_total = lv_total.
*    gv_no_success = fp_no_success.
*    gv_no_failed = fp_no_failed.
    gv_total2      = lv_total.
    gv_no_success2 = fp_no_success.
    gv_no_failed2  = fp_no_failed.
*defect     1240
    gv_rate_c = lv_rate_c.

    LOOP AT fp_i_report ASSIGNING <fs>.
      lwa_report_b-msgtyp = <fs>-msgtyp.
      lwa_report_b-msgtxt = <fs>-msgtxt.
      lwa_report_b-key = <fs>-key.
*     Getting the maximum length of columns MSGTXT.
      IF lv_width_msg   LT strlen( <fs>-msgtxt ).
        lv_width_msg = strlen( <fs>-msgtxt ).
      ENDIF. " IF lv_width_msg LT strlen( <fs>-msgtxt )
*     Getting the maximum length of column KEY.
      IF lv_width_key   LT strlen( <fs>-key ).
        lv_width_key = strlen( <fs>-key ).
      ENDIF. " IF lv_width_key LT strlen( <fs>-key )
      APPEND lwa_report_b TO li_report_b.
      CLEAR lwa_report_b.
    ENDLOOP. " LOOP AT fp_i_report ASSIGNING <fs>

    IF lv_width_key LT 150.
      lv_width_key = 150.
    ENDIF. " IF lv_width_key LT 150

*   Preparing Field Catalog.
*   Message Type
    PERFORM f_fill_fieldcat USING 'MSGTYP'
                                  'LI_REPORT_B'
                                  text-x12
                                  7
                          CHANGING li_fieldcat[].
*   Message Text
    PERFORM f_fill_fieldcat USING 'MSGTXT'
                                  'LI_REPORT_B'
                                  text-x13
                                  lv_width_msg
                          CHANGING li_fieldcat[].
*   Message Key
    PERFORM f_fill_fieldcat USING 'KEY'
                                  'LI_REPORT_B'
                                  text-x14
                                  lv_width_key
                          CHANGING li_fieldcat[].
*   Top of page subroutine
    lwa_events-name = 'TOP_OF_PAGE'.
    lwa_events-form = 'F_TOP_OF_PAGE1'.
    APPEND lwa_events TO li_events.
    CLEAR lwa_events.
*   ALV List Display for Background Run
    CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
      EXPORTING
        i_callback_program = sy-repid
        it_fieldcat        = li_fieldcat
        it_events          = li_events
      TABLES
        t_outtab           = li_report_b
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
      MESSAGE e002(zca_msg). " Invalid file name. Please check your entry.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF sy-batch IS INITIAL


ENDFORM. " F_DISPLAY_SUMMARY_REPORT1



*&---------------------------------------------------------------------*
*&      Form  F_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       Subroutine for header display
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_top_of_page1.
* Horizontal Line.
  CONSTANTS: c_hline TYPE char50           " Dotted Line
             VALUE
'--------------------------------------------------',
             c_colon TYPE char1 VALUE ':'. " Colon of type CHAR1

* Run Information
  WRITE: / text-x01.
* Horizontal Line
  WRITE: / c_hline.
* File Read
  WRITE: / text-x02, 50(1) c_colon, 52 gv_filename_d.
  IF gv_filename_d_arch IS NOT INITIAL.
* File Archived
    WRITE: / text-x28, 50(1) c_colon, 52 gv_filename_d_arch.
  ENDIF. " IF gv_filename_d_arch IS NOT INITIAL
* Client
  WRITE: / text-x03, 50(1) c_colon, 52 sy-mandt.
* Run By / User Id
  WRITE: / text-x04, 50(1) c_colon, 52 sy-uname.
* Date / Time
  WRITE: / text-x05, 50(1) c_colon, 52 sy-datum, 63 sy-uzeit.
* Execution Mode
  WRITE: / text-x06, 50(1) c_colon, 52 gv_mode_b.
  IF gv_session IS NOT INITIAL.
* BDC Session Details
    WRITE: / text-x29, 50(1) c_colon, 52 gv_session.
  ENDIF. " IF gv_session IS NOT INITIAL
* Horizontal Line
  WRITE: / c_hline.
* Total number of records in the given file
  WRITE: / text-x08, 50(1) c_colon, 52 gv_total2 LEFT-JUSTIFIED.
* Number of Success records
  WRITE: / text-x09, 50(1) c_colon, 52 gv_no_success2 LEFT-JUSTIFIED.
* Number of Error records
  WRITE: / text-x10, 50(1) c_colon, 52 gv_no_failed2 LEFT-JUSTIFIED.
* Success Rate
  WRITE: / text-x11, 50(1) c_colon, 52 gv_rate_c LEFT-JUSTIFIED.
* Horizontal Line
  WRITE: / c_hline.
ENDFORM. " F_TOP_OF_PAGE
