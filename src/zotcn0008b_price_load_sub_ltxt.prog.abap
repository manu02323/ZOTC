*&---------------------------------------------------------------------*
*&  Include           ZOTCC0008B_PRICE_LOAD_SUB_LTXT
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0008_PRICE_LOAD_SUB_LTXT                          *
* TITLE      :  OTC_CDD_0008_Price Load                                *
* DEVELOPER  :  Nagamani N M                                           *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_CDD_0008_Price Load
*----------------------------------------------------------------------*
* DESCRIPTION:
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
*16-Aug-2013   NNM     E1DK911313  INITIAL DEVELOPMENT: CR700:
*                                  Copied from program
*                                  ZOTCN0008B_PRICE_LOAD_SUB.
*                                  Change of Input file format - common
*                                  for all Condition Record Tables.
*                                  Addition of Internal Comment in VK11
*
*5-May-2014    PROUT  E1DK913354  CR#1289:The requirement is to update the
*                                 condition record instead of creating a new
*                                 record and also have the functionality
*                                 of mark the records for deletion
*                                 which is VK12 functionality
*19-Jun-2014 SMUKHER  E1DK913354  HPQC# 1289 : If the user tries to upload
*                                 a .txt file which does not have the last
*                                 coloumn "Parameter" , then a information
*                                 message is to be given to user regarding
*                                 the same.
*&---------------------------------------------------------------------*
*11-Sep-2019 APODDAR E1SK901521  Hanatization
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
      ENDIF.
    ELSE.
      IF screen-group1 = c_groupmi3.
        screen-active = c_one.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
    IF rb_app NE c_true.
      IF screen-group1    = c_groupmi2
         OR screen-group1 = c_groupmi5
         OR screen-group1 = c_groupmi7.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_MODIFY1_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_READ_FILE
*&---------------------------------------------------------------------*
* Load File into Internal table i_leg_tab
*&---------------------------------------------------------------------*
FORM f_read_file  .
  DATA:   lv_msg          TYPE string, " message
          lv_leg_tab      TYPE string, " legacy table record
          lv_datum        TYPE datum,  " date YYYYMMDD format
          lv_filename     TYPE string, " File name
          lwa_string      TYPE ty_string. "Record

*12/05/2012 Start Of change by Shammi Defect 1955
  DATA:   c_nline(1) TYPE c VALUE   cl_abap_char_utilities=>newline .
*12/05/2012 End of Change by Shammi Defect 1955

  CLEAR: gv_subrc,gv_header , gv_table,lv_filename.

*START OF DEFECT 1177
  SELECT kvgr1
  FROM   tvv1
  INTO TABLE i_tvv1.
  IF sy-subrc = 0.

    SORT i_tvv1 BY kvgr1.

  ENDIF.
*END OF DEFECT 1177

  IF rb_pres = c_selected.
    lv_filename = p_phdr.
    gv_filename = p_phdr.
    gv_file     = p_phdr.
  ELSEIF rb_app = c_selected.

    IF rb_aphy = c_selected.

      lv_filename = p_ahdr.
      gv_filename = p_ahdr.
      gv_file     = p_ahdr.
    ELSEIF rb_alog = c_selected.
      lv_filename = gv_filename.
      gv_file     = lv_filename.
    ENDIF.
  ENDIF.

*&&-- Begin of Comment for CR#700
** get condition table name from file name
*  PERFORM f_get_table_name.
*&&-- End of Comment for CR#700

* Presentation server
  IF rb_pres = c_selected.
* read file
    CALL METHOD cl_gui_frontend_services=>gui_upload
      EXPORTING
        filename                = lv_filename
      CHANGING
        data_tab                = i_string
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
    ELSE.
*populate internal tables based on condition table name
*      CASE gv_table.   "CR#700 --
*        WHEN c_005.    "CR#700 --

*&&-- Begin of CR#700
*&&-- Common Subroutine for reading input file data for ALL
*      Condition Record Tables - A005, A004, A901, A902,
*      A903, A904, A905, A911
      PERFORM f_read_record.

*&&-- End Of CR#700
**&& -- BOC : CR# 1289 : PROUT : 05-MAY-2014
***      IF rb_post = abap_true.
***        PERFORM f_check_processed_data
***                                       CHANGING i_leg_tab.
***      ENDIF.
**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014

*&&-- Begin of Comment for CR#700
*          PERFORM f_read_record_a005.
*        WHEN c_903.
*          PERFORM f_read_record_a903.
*        WHEN c_901.
*          PERFORM f_read_record_a901.
*        WHEN c_904.
*          PERFORM f_read_record_a904.
*        WHEN c_902.
*          PERFORM f_read_record_a902.
*        WHEN c_905.
*          PERFORM f_read_record_a905.
*        WHEN c_004.
*          PERFORM f_read_record_a004.
*START DEFECT  2390 01/08/2013
*        WHEN c_911.
*          PERFORM f_read_record_a911.
*END  DEFECT  2390 01/08/2013

*        WHEN OTHERS.
*          MESSAGE i000  WITH 'Invalid File Name.'(035).
*          LEAVE LIST-PROCESSING.
*      ENDCASE.
*&&-- End of Comment for CR#700

    ENDIF.
    gv_file = lv_filename.
  ELSE.
*App Server
    OPEN DATASET lv_filename FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc NE 0.
      MESSAGE i000  WITH 'Error in opening file.'(012).
      LEAVE LIST-PROCESSING.
    ELSE.
      WHILE ( gv_subrc EQ 0 ).
        CLEAR lv_leg_tab.
        READ DATASET lv_filename INTO lwa_string-string.
        gv_subrc = sy-subrc.
        IF gv_subrc = 0.
*12/05/2012 Start of change Shammi D#1955
          REPLACE ALL OCCURRENCES OF   cl_abap_char_utilities=>cr_lf(1) IN lwa_string-string WITH space.
*12/05/2012 End of change Shammi D#1955
          APPEND lwa_string TO i_string.
        ENDIF.
      ENDWHILE.
    ENDIF.
    CLOSE DATASET lv_filename.

*    CASE gv_table. "CR#700 --
*      WHEN '005'.  "CR#700 --
    PERFORM f_read_record.    "CR#700 ++
*&&-- Begin of Comment for CR#700
*        PERFORM f_read_record_a005.
*      WHEN '903'.
*        PERFORM f_read_record_a903.
*      WHEN '901'.
*        PERFORM f_read_record_a901.
*      WHEN '904'.
*        PERFORM f_read_record_a904.
*      WHEN '902'.
*        PERFORM f_read_record_a902.
*      WHEN '905'.
*        PERFORM f_read_record_a905.
*      WHEN '004'.
*        PERFORM f_read_record_a004.
*START DEFECT 2390 01/08/2013
*      WHEN c_911.
*        PERFORM f_read_record_a911.
*END  DEFECT  2390 01/08/2013
*
*      WHEN OTHERS.
*        MESSAGE i000  WITH 'Invalid File Name.'(035).
*        LEAVE LIST-PROCESSING.
*    ENDCASE.
*&&-- End of Comment for CR#700
  ENDIF.
ENDFORM.                    " F_READ_FILE
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_SUMMARY
*&---------------------------------------------------------------------*
* Display ALV Log
*&---------------------------------------------------------------------*
FORM f_display_summary .
  gv_no_success1  = gv_tot - gv_error.
  IF rb_post = c_selected .
    gv_mode = 'Post Run'(033).
  ELSE.
    gv_mode = 'Test Run'(032).
  ENDIF.
  IF rb_pres <> c_selected .
    IF rb_post = c_selected.
      PERFORM f_move USING    gv_file
                     CHANGING i_report[].
    ENDIF.
  ENDIF.
  PERFORM f_display_summary_report1  USING i_report[]
                                          gv_file
                                          gv_mode
                                          gv_no_success1
                                          gv_error.

ENDFORM.                    " F_DISPLAY_SUMMARY
*&---------------------------------------------------------------------*
*&      Form  F_MOVE
*&---------------------------------------------------------------------*
*  Move file from TBP to Done Folder & creates Error file in Folder
*  Error with Failed records for re-processing
*&---------------------------------------------------------------------*
FORM f_move USING fp_v_source TYPE localfile
            CHANGING fp_i_report TYPE ty_t_report.

  DATA: lv_file   TYPE localfile,   "File Name
        lv_name   TYPE localfile,   "Path Name
        lv_return TYPE sysubrc,     "Return Code
        lwa_report TYPE ty_report,  "Report
        lv_data    TYPE string,    "Output data string
        lwa_leg_tab_error TYPE ty_leg_tab.


  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_v_source
    IMPORTING
      pathname = lv_file
      filename = lv_name.


  REPLACE c_tobeprscd IN lv_file WITH c_done_fold .
  CONCATENATE lv_file lv_name INTO lv_file.
  PERFORM f_file_move  USING    fp_v_source
                                lv_file
                       CHANGING lv_return.
  IF lv_return IS INITIAL.
    gv_archive_gl_1 = lv_file.
  ELSE.
    lwa_report-msgtyp = c_error.
    MESSAGE i000 WITH 'Input file'(011)
                       lv_file
                      'not moved.'(013)
            INTO lwa_report-msgtxt.
    APPEND lwa_report TO fp_i_report.
    CLEAR lwa_report.
  ENDIF.


  IF gv_error > 0.
    REPLACE c_done_fold IN lv_file WITH c_err_fold.
    OPEN DATASET lv_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc NE 0.
      MESSAGE i006. "Error Folder could not be opened
      EXIT.
    ELSE.
      LOOP AT i_leg_tab_err INTO lwa_leg_tab_error.
        CONCATENATE
             lwa_leg_tab_error-kappl
             lwa_leg_tab_error-kschl
             lwa_leg_tab_error-vkorg
             lwa_leg_tab_error-vtweg
             lwa_leg_tab_error-kunnr
             lwa_leg_tab_error-matnr
             lwa_leg_tab_error-datab
             lwa_leg_tab_error-datbi
             lwa_leg_tab_error-prod
             lwa_leg_tab_error-zzkvgr1
             lwa_leg_tab_error-zzkvgr2
             INTO lv_data
             SEPARATED BY c_tab.
        TRANSFER lv_data TO lv_file.
        CLEAR lv_data.
      ENDLOOP.
    ENDIF.
    CLOSE DATASET lv_file.
  ENDIF.
ENDFORM.                    " F_MOVE
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_DATA
*&---------------------------------------------------------------------*
*    Creates Pricing Condition Records . Not released Function Modules
*     RV_CONDITION_COPY
*     RV_CONDITION_SAVE
*     RV_CONDITION_RESET
*     are warapped up into Z FM ZOTC_RV_CONDITION_COPY.
*&--------------------------------------------------------------------*
FORM f_upload_data .

*&&-- BOC : HPQC# 1289 : SMUKHER : 19-Jun-2014
  TYPES: BEGIN OF lty_t685,
          kvewe	TYPE kvewe, "Usage of the condition table
          kappl	TYPE kappl, "Application
          kschl	TYPE kschl, "Condition Type
          kozgf	TYPE kozgf, "Access sequence
         END OF lty_t685,

         BEGIN OF lty_t682i,
          kvewe	TYPE kvewe,"Usage of the condition table
          kappl	TYPE kappl,"Application
          kozgf	TYPE kozgf,"Access sequence
          kolnr	TYPE kolnr,"Access sequence - Access number
          kotabnr	TYPE kotabnr,"Condition table
         END OF lty_t682i.

  DATA: li_t685 TYPE STANDARD TABLE OF lty_t685,    " internal table
        li_t682i TYPE STANDARD TABLE OF lty_t682i,    " internal table
        li_leg_tab1 TYPE STANDARD TABLE OF ty_leg_tab, " internal table
        lv_access_seq TYPE char2. "sytabix.

  FIELD-SYMBOLS: <lfs_t685> TYPE lty_t685.
*&&-- EOC : HPQC# 1289 : SMUKHER : 19-Jun-2014

  DATA : lwa_komg     TYPE komg, " KOMG  Workarea
         lwa_komp     TYPE komp, " KOMP  Workarea
         lwa_komv     TYPE komv, " KOMV workarea
         lwa_komk     TYPE komk, " KOMK workarea
         li_komv      TYPE STANDARD TABLE OF komv INITIAL SIZE 0, " internal table KOMV
         lv_date_from TYPE datum, " Date YYYYMMDD format
         lv_date_to   TYPE datum, " Date YYYYMMDD format
         lv_new_record," New Rec indicator
         lv_krech TYPE t685a-krech,
**&& -- BOC : CR# 1289 : PROUT : 05-MAY-2014
         li_bdcdata TYPE STANDARD TABLE OF bdcdata, " BDC Data
         li_bdcmsg TYPE ty_t_bdcmsgcoll. " internal table for BDC messages
  CONSTANTS: lc_kvewe  TYPE char1 VALUE 'A',  " Usage of the condition table
             lc_insert TYPE char1 VALUE 'I',  " Insert = I
             lc_update TYPE char1 VALUE 'U',  " Update = U
             lc_delete TYPE char1 VALUE 'D'.  " Delete = D
**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014

*&&-- Begin of CR#700
  DATA: lv_knumh TYPE knumh,
        li_leg_tab TYPE STANDARD TABLE OF ty_leg_tab,
        lv_index TYPE syindex.

  FIELD-SYMBOLS: <lfs_leg_tab> TYPE ty_leg_tab.

  li_leg_tab[] = i_leg_tab[].   "CR#700 ++
*&&-- End of CR#700

*  FIELD-SYMBOLS : <lfs_mvke> TYPE ty_mvke,
*                  <lfs_kna1> TYPE ty_kna1.

  DESCRIBE TABLE i_leg_tab LINES gv_tot.
  gv_tot = gv_tot + gv_tot1.
  gv_tot = gv_tot + gv_skip.

  IF i_leg_tab[] IS NOT INITIAL.

*&&-- BOC : HPQC# 1289 : SMUKHER : 19-Jun-2014

    li_leg_tab1[] = i_leg_tab[].
    SORT li_leg_tab1 BY kappl
                        kschl
                        tabname.
    DELETE ADJACENT DUPLICATES FROM li_leg_tab1 COMPARING kappl
                                                          kschl
                                                          tabname.
    IF li_leg_tab1[] IS NOT INITIAL.
      SELECT kvewe
             kappl
             kschl
             kozgf
        FROM t685
        INTO TABLE li_t685
        FOR ALL ENTRIES IN li_leg_tab1
        WHERE kvewe = lc_kvewe
          AND kappl = li_leg_tab1-kappl
          AND kschl = li_leg_tab1-kschl.
      IF sy-subrc IS INITIAL.
        SORT li_t685 BY kappl kschl.

        SELECT kvewe
               kappl
               kozgf
               kolnr
               kotabnr
          FROM t682i
          INTO TABLE li_t682i
          FOR ALL ENTRIES IN li_t685
          WHERE kvewe = lc_kvewe
            AND kappl = li_t685-kappl
            AND kozgf = li_t685-kozgf.
        IF sy-subrc IS INITIAL.
          " we cannot sort this table since access seq number will be disturbed
        ENDIF.
      ENDIF.
    ENDIF.
*&&-- EOC : HPQC# 1289 : SMUKHER : 19-Jun-2014

* Mapping from Legacy System to ECC

    IF gv_table = c_005 OR
       gv_table = c_901 OR
       gv_table = c_902 OR
       gv_table = c_004 OR
       gv_table = c_903 OR
*START DEFECT  2390 01/08/2013
       gv_table = c_911.
*END  DEFECT 2390 01/08/2013
      PERFORM f_map_legacy.
    ENDIF.


    IF i_leg_tab[] IS NOT INITIAL.

      SELECT kschl
      FROM   t685
      INTO TABLE i_t685.
      IF sy-subrc = 0.
      ENDIF.


      SELECT vkorg
      FROM   tvko
      INTO TABLE i_tvko.
      IF sy-subrc = 0.
      ENDIF.


      SELECT vtweg
      FROM   tvtw
      INTO TABLE i_tvtw.
      IF sy-subrc = 0.
      ENDIF.

    ENDIF.


    SORT i_t685  ASCENDING BY kschl.
    SORT i_tvko  ASCENDING BY vkorg.
    SORT i_tvtw  ASCENDING BY vtweg.

    LOOP AT i_leg_tab INTO wa_leg_tab.

      lv_index = sy-tabix.  "CR#700 ++

      PERFORM f_verify_date.
      IF gv_error_check = c_selected.
        CONTINUE.
      ENDIF.
      CLEAR : lv_date_from , lv_date_to.
      lv_date_from = wa_leg_tab-datab.
      lv_date_to   = wa_leg_tab-datbi.

      CLEAR lwa_komg.
      lwa_komg-vkorg   = wa_leg_tab-vkorg.
      lwa_komg-vtweg   = wa_leg_tab-vtweg.

*START DEFECT 2390 01/08/2013
      IF gv_table = c_911.
        lwa_komg-kunwe   = wa_leg_tab-kunnr.
        lwa_komg-matnr   = wa_leg_tab-matnr.
      ENDIF.
*END   DEFECT 2390 01/08/2013

      IF gv_table = c_005.
        lwa_komg-kunnr   = wa_leg_tab-kunnr.
        lwa_komg-matnr = wa_leg_tab-matnr.
      ENDIF.

      IF gv_table = c_903.
        lwa_komg-kunnr   = wa_leg_tab-kunnr.
        lwa_komg-zzprodh4 = wa_leg_tab-prod.
      ENDIF.

      IF gv_table = c_901.
        lwa_komg-zzkvgr1 = wa_leg_tab-zzkvgr1.
        lwa_komg-matnr = wa_leg_tab-matnr.
      ENDIF.

      IF gv_table = c_904.
        lwa_komg-zzkvgr1  = wa_leg_tab-zzkvgr1.
        lwa_komg-zzprodh4 = wa_leg_tab-prod.
      ENDIF.

      IF gv_table = c_902.
        lwa_komg-zzkvgr2  = wa_leg_tab-zzkvgr2.
        lwa_komg-matnr = wa_leg_tab-matnr.
      ENDIF.

      IF gv_table = c_905.
        lwa_komg-zzkvgr2  = wa_leg_tab-zzkvgr2.
        lwa_komg-zzprodh4 = wa_leg_tab-prod.
      ENDIF.

      IF gv_table = c_004.
        lwa_komg-matnr = wa_leg_tab-matnr.
      ENDIF.

      CLEAR lwa_komv.
      REFRESH li_komv[].
      lwa_komv-kappl = wa_leg_tab-kappl.
      lwa_komv-kschl = wa_leg_tab-kschl.
* 23-July-2012 SPURI   E1DK901614  CR100-Addition of amount column     *

      lwa_komv-kbetr = wa_leg_tab-kbetr.


      CLEAR lv_krech.
      SELECT SINGLE krech
             FROM   t685a
             INTO   lv_krech
             WHERE  kschl = wa_leg_tab-kschl AND
                    kappl = lwa_komv-kappl.

      IF sy-subrc = 0.
        IF lv_krech = 'A'.
          lwa_komv-kbetr = lwa_komv-kbetr * 10.
        ENDIF.
      ENDIF.
* 23-July-2012 SPURI   E1DK901614  CR100-Addition of amount column     *
      lwa_komv-waers = wa_leg_tab-konwa.
      lwa_komv-kpein = wa_leg_tab-kpein.
      lwa_komv-kmein = wa_leg_tab-kmein.
      APPEND lwa_komv TO li_komv.



      IF  rb_post = c_selected.
**&& -- BOC : CR# 1289 : PROUT : 05-MAY-2014
**&& -- Now the records can be now updated and deleted without creating
**      Condition Record Number.

*&&-- BOC : HPQC# 1289 : SMUKHER : 19-Jun-2014
**&& -- The following logic works for the condition type ZEQR, ZRER and ZSER
**&&    apart from ZB00, for which the access sequence is not same as condition
**&&    type . Here we are using two tables T685 and T682I for configuring the
**&&    same.
*&&-- Get the Access Sequence for the condition type
        READ TABLE li_t685 ASSIGNING <lfs_t685>
                           WITH KEY kappl = wa_leg_tab-kappl
                                    kschl = wa_leg_tab-kschl
                                    BINARY SEARCH.
        IF sy-subrc IS INITIAL.
*&&-- Get the condition record tables for the access sequence
          READ TABLE li_t682i TRANSPORTING NO FIELDS
                              WITH KEY kappl = <lfs_t685>-kappl
                                       kozgf = <lfs_t685>-kozgf
                                       kotabnr = gv_table.
          IF sy-subrc IS INITIAL.
**&& -- We fetch the sequence number and use it in the BDC recording
            lv_access_seq = sy-tabix.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lv_access_seq
              IMPORTING
                output = lv_access_seq.
          ELSE.
            PERFORM f_log_msg1.
          ENDIF.
        ENDIF.
**&& -- In case the user provides the Parameter as smaller case in .txt file.
        TRANSLATE wa_leg_tab-parameter TO UPPER CASE.
*&&-- EOC : HPQC# 1289 : SMUKHER : 19-Jun-2014

**&& -- The Condition table is read from the file.
        IF gv_table = c_005.
          IF wa_leg_tab-parameter = lc_insert.
**      If the Condition Table = A005 and the Parameter = 'I'(Insert)
            PERFORM f_zotc_rv_condition_copy USING lwa_komv
                                                   wa_leg_tab
                                                   lv_date_from
                                                   lv_date_to
                                                   lwa_komg
*                                                   i_leg_tab
                                                   lv_index
                                          CHANGING i_leg_tab
                                                   lwa_komk
                                                   lwa_komp
                                                   lv_new_record
                                                   lv_knumh
                                                   li_komv.
**      If the Condition Table = A005 and the Parameter = 'U'(Update)
          ELSEIF wa_leg_tab-parameter = lc_update.
            PERFORM f_bdc_create USING wa_leg_tab
                                       lv_access_seq
                                 CHANGING li_bdcdata.
            PERFORM f_bdc_transaction USING gc_transaction
                                             li_bdcdata
                                      CHANGING li_bdcmsg.
            PERFORM f_log_msg USING wa_leg_tab
                                     li_bdcmsg.
            REFRESH: li_bdcdata[],
                     li_bdcmsg[].

***&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
*            IF wa_leg_tab-knumh EQ space.
*              PERFORM f_populate_knumh USING lv_index
*                                             wa_leg_tab
*                                       CHANGING i_leg_tab.
*            ENDIF.
***&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014

**      If the Condition Table = A005 and the Parameter = 'D'(Delete)
          ELSEIF wa_leg_tab-parameter = lc_delete.
            PERFORM f_bdc_create1 USING wa_leg_tab
                                        lv_access_seq
                                 CHANGING li_bdcdata.
            PERFORM f_bdc_transaction USING gc_transaction
                                             li_bdcdata
                                      CHANGING li_bdcmsg.
            PERFORM f_log_msg USING wa_leg_tab
                                     li_bdcmsg.
            REFRESH: li_bdcdata[],
                     li_bdcmsg[].
          ENDIF.
        ENDIF.
**&& -- The Condition table is read from the file.
        IF gv_table = c_004.
**      If the Condition Table = A004 and the Parameter = 'I'(Insert)
          IF wa_leg_tab-parameter = lc_insert.
            PERFORM f_zotc_rv_condition_copy USING lwa_komv
                                                   wa_leg_tab
                                                   lv_date_from
                                                   lv_date_to
                                                   lwa_komg
                                                   lv_index
*                                                   i_leg_tab
                                          CHANGING i_leg_tab
                                                   lwa_komk
                                                   lwa_komp
                                                   lv_new_record
                                                   lv_knumh
                                                   li_komv.
**      If the Condition Table = A005 and the Parameter = 'U'(Update)
          ELSEIF wa_leg_tab-parameter = lc_update.
            PERFORM f_bdc_create2 USING wa_leg_tab
                                        lv_access_seq
                                 CHANGING li_bdcdata.
            PERFORM f_bdc_transaction USING gc_transaction
                                             li_bdcdata
                                      CHANGING li_bdcmsg.
            PERFORM f_log_msg USING wa_leg_tab
                                     li_bdcmsg.

            REFRESH: li_bdcdata[],
                     li_bdcmsg[].

***&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
*            PERFORM f_populate_knumh USING lv_index
*                                           wa_leg_tab
*                                     CHANGING i_leg_tab.
***&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
**      If the Condition Table = A005 and the Parameter = 'D'(Delete)
          ELSEIF wa_leg_tab-parameter = lc_delete.
            PERFORM f_bdc_create3 USING wa_leg_tab
                                        lv_access_seq
                                 CHANGING li_bdcdata.
            PERFORM f_bdc_transaction USING gc_transaction
                                             li_bdcdata
                                      CHANGING li_bdcmsg.
            PERFORM f_log_msg USING wa_leg_tab
                                     li_bdcmsg.
            REFRESH: li_bdcdata[],
                     li_bdcmsg[].
          ENDIF.
        ENDIF.
**&& -- The Condition table is read from the file.
        IF gv_table = c_911.
**      If the Condition Table = A911 and the Parameter = 'I'(Insert)
          IF wa_leg_tab-parameter = lc_insert.
            PERFORM f_zotc_rv_condition_copy USING lwa_komv
                                                   wa_leg_tab
                                                   lv_date_from
                                                   lv_date_to
                                                   lwa_komg
                                                   lv_index
*                                                   i_leg_tab
                                          CHANGING i_leg_tab
                                                   lwa_komk
                                                   lwa_komp
                                                   lv_new_record
                                                   lv_knumh
                                                   li_komv.
**      If the Condition Table = A911 and the Parameter = 'U'(Update)
          ELSEIF wa_leg_tab-parameter = lc_update.
            PERFORM f_bdc_create4 USING wa_leg_tab
                                        lv_access_seq
                                 CHANGING li_bdcdata.
            PERFORM f_bdc_transaction USING gc_transaction
                                             li_bdcdata
                                      CHANGING li_bdcmsg.
            PERFORM f_log_msg USING wa_leg_tab
                                     li_bdcmsg.
            REFRESH: li_bdcdata[],
                     li_bdcmsg[].

**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
**            PERFORM f_populate_knumh USING lv_index
**                                           wa_leg_tab
**                                     CHANGING i_leg_tab.
**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
**      If the Condition Table = A911 and the Parameter = 'D'(Delete)
          ELSEIF wa_leg_tab-parameter = lc_delete.
            PERFORM f_bdc_create5 USING wa_leg_tab
                                        lv_access_seq
                                 CHANGING li_bdcdata.
            PERFORM f_bdc_transaction USING gc_transaction
                                             li_bdcdata
                                      CHANGING li_bdcmsg.
            PERFORM f_log_msg USING wa_leg_tab
                                     li_bdcmsg.
            REFRESH: li_bdcdata[],
                     li_bdcmsg[].
          ENDIF.
        ENDIF.
**&& -- The Condition table is read from the file.
        IF gv_table = c_903.
**      If the Condition Table = A903 and the Parameter = 'I'(Insert)
          IF wa_leg_tab-parameter = lc_insert.
            PERFORM f_zotc_rv_condition_copy USING lwa_komv
                                                   wa_leg_tab
                                                   lv_date_from
                                                   lv_date_to
                                                   lwa_komg
                                                   lv_index
*                                                   i_leg_tab
                                          CHANGING i_leg_tab
                                                   lwa_komk
                                                   lwa_komp
                                                   lv_new_record
                                                   lv_knumh
                                                   li_komv.
**      If the Condition Table = A903 and the Parameter = 'U'(Update)
          ELSEIF wa_leg_tab-parameter = lc_update.
            PERFORM f_bdc_create6 USING wa_leg_tab
                                        lv_access_seq
                                 CHANGING li_bdcdata.
            PERFORM f_bdc_transaction USING gc_transaction
                                             li_bdcdata
                                      CHANGING li_bdcmsg.
            PERFORM f_log_msg USING wa_leg_tab
                                     li_bdcmsg.
            REFRESH: li_bdcdata[],
                     li_bdcmsg[].

**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
**            PERFORM f_populate_knumh USING lv_index
**                                           wa_leg_tab
**                                     CHANGING i_leg_tab.
**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
**      If the Condition Table = A903 and the Parameter = 'D'(Delete)
          ELSEIF wa_leg_tab-parameter = lc_delete.
            PERFORM f_bdc_create7 USING wa_leg_tab
                                        lv_access_seq
                                 CHANGING li_bdcdata.
            PERFORM f_bdc_transaction USING gc_transaction
                                             li_bdcdata
                                      CHANGING li_bdcmsg.
            PERFORM f_log_msg USING wa_leg_tab
                                     li_bdcmsg.
            REFRESH: li_bdcdata[],
                     li_bdcmsg[].
          ENDIF.
        ENDIF.
**&& -- The Condition table is read from the file.
        IF gv_table = c_901.
**      If the Condition Table = A901 and the Parameter = 'I'(Insert)
          IF wa_leg_tab-parameter = lc_insert.
            PERFORM f_zotc_rv_condition_copy USING lwa_komv
                                                   wa_leg_tab
                                                   lv_date_from
                                                   lv_date_to
                                                   lwa_komg
                                                   lv_index
*                                                   i_leg_tab
                                          CHANGING i_leg_tab
                                                   lwa_komk
                                                   lwa_komp
                                                   lv_new_record
                                                   lv_knumh
                                                   li_komv.
**      If the Condition Table = A901 and the Parameter = 'U'(Update)
          ELSEIF wa_leg_tab-parameter = lc_update.
            PERFORM f_bdc_create8 USING wa_leg_tab
                                        lv_access_seq
                                 CHANGING li_bdcdata.
            PERFORM f_bdc_transaction USING gc_transaction
                                             li_bdcdata
                                      CHANGING li_bdcmsg.
            PERFORM f_log_msg USING wa_leg_tab
                                     li_bdcmsg.
            REFRESH: li_bdcdata[],
                     li_bdcmsg[].

**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
**            PERFORM f_populate_knumh USING lv_index
**                                           wa_leg_tab
**                                     CHANGING i_leg_tab.
**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
**      If the Condition Table = A901 and the Parameter = 'D'(Delete)
          ELSEIF wa_leg_tab-parameter = lc_delete.
            PERFORM f_bdc_create9 USING wa_leg_tab
                                        lv_access_seq
                                 CHANGING li_bdcdata.
            PERFORM f_bdc_transaction USING gc_transaction
                                             li_bdcdata
                                      CHANGING li_bdcmsg.
            PERFORM f_log_msg USING wa_leg_tab
                                     li_bdcmsg.
            REFRESH: li_bdcdata[],
                     li_bdcmsg[].
          ENDIF.
        ENDIF.
**&& -- The Condition table is read from the file.
        IF gv_table = c_902.
**      If the Condition Table = A902 and the Parameter = 'I'(Insert)
          IF wa_leg_tab-parameter = lc_insert.
            PERFORM f_zotc_rv_condition_copy USING lwa_komv
                                                   wa_leg_tab
                                                   lv_date_from
                                                   lv_date_to
                                                   lwa_komg
                                                   lv_index
*                                                   i_leg_tab
                                          CHANGING i_leg_tab
                                                   lwa_komk
                                                   lwa_komp
                                                   lv_new_record
                                                   lv_knumh
                                                   li_komv.
**      If the Condition Table = A902 and the Parameter = 'U'(Update)
          ELSEIF wa_leg_tab-parameter = lc_update.
            PERFORM f_bdc_create10 USING wa_leg_tab
                                         lv_access_seq
                                 CHANGING li_bdcdata.
            PERFORM f_bdc_transaction USING gc_transaction
                                             li_bdcdata
                                      CHANGING li_bdcmsg.
            PERFORM f_log_msg USING wa_leg_tab
                                     li_bdcmsg.
            REFRESH: li_bdcdata[],
                     li_bdcmsg[].

**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
**            PERFORM f_populate_knumh USING lv_index
**                                           wa_leg_tab
**                                     CHANGING i_leg_tab.
**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
**      If the Condition Table = A902 and the Parameter = 'D'(Delete)
          ELSEIF wa_leg_tab-parameter = lc_delete.
            PERFORM f_bdc_create11 USING wa_leg_tab
                                         lv_access_seq
                                 CHANGING li_bdcdata.
            PERFORM f_bdc_transaction USING gc_transaction
                                             li_bdcdata
                                      CHANGING li_bdcmsg.
            PERFORM f_log_msg USING wa_leg_tab
                                     li_bdcmsg.
            REFRESH: li_bdcdata[],
                     li_bdcmsg[].
          ENDIF.
        ENDIF.
**&& -- The Condition table is read from the file.
        IF gv_table = c_905.
**      If the Condition Table = A905 and the Parameter = 'I'(Insert)
          IF wa_leg_tab-parameter = lc_insert.
            PERFORM f_zotc_rv_condition_copy USING lwa_komv
                                                   wa_leg_tab
                                                   lv_date_from
                                                   lv_date_to
                                                   lwa_komg
                                                   lv_index
*                                                   i_leg_tab
                                          CHANGING i_leg_tab
                                                   lwa_komk
                                                   lwa_komp
                                                   lv_new_record
                                                   lv_knumh
                                                   li_komv.
**      If the Condition Table = A905 and the Parameter = 'U'(Update)
          ELSEIF wa_leg_tab-parameter = lc_update.
            PERFORM f_bdc_create12 USING wa_leg_tab
                                         lv_access_seq
                                 CHANGING li_bdcdata.
            PERFORM f_bdc_transaction USING gc_transaction
                                             li_bdcdata
                                      CHANGING li_bdcmsg.
            PERFORM f_log_msg USING wa_leg_tab
                                     li_bdcmsg.
            REFRESH: li_bdcdata[],
                     li_bdcmsg[].

**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
**            PERFORM f_populate_knumh USING lv_index
**                                           wa_leg_tab
**                                     CHANGING i_leg_tab.
**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
**      If the Condition Table = A905 and the Parameter = 'D'(Delete)
          ELSEIF wa_leg_tab-parameter = lc_delete.
            PERFORM f_bdc_create13 USING wa_leg_tab
                                         lv_access_seq
                                 CHANGING li_bdcdata.
            PERFORM f_bdc_transaction USING gc_transaction
                                             li_bdcdata
                                      CHANGING li_bdcmsg.
            PERFORM f_log_msg USING wa_leg_tab
                                     li_bdcmsg.
            REFRESH: li_bdcdata[],
                     li_bdcmsg[].
          ENDIF.
        ENDIF.
**&& -- The Condition table is read from the file.
        IF gv_table = c_904.
**      If the Condition Table = A904 and the Parameter = 'I'(Insert)
          IF wa_leg_tab-parameter = lc_insert.
            PERFORM f_zotc_rv_condition_copy USING lwa_komv
                                                   wa_leg_tab
                                                   lv_date_from
                                                   lv_date_to
                                                   lwa_komg
                                                   lv_index
*                                                   i_leg_tab
                                          CHANGING i_leg_tab
                                                   lwa_komk
                                                   lwa_komp
                                                   lv_new_record
                                                   lv_knumh
                                                   li_komv.
**      If the Condition Table = A905 and the Parameter = 'U'(Update)
          ELSEIF wa_leg_tab-parameter = lc_update.
            PERFORM f_bdc_create14 USING wa_leg_tab
                                         lv_access_seq
                                 CHANGING li_bdcdata.
            PERFORM f_bdc_transaction USING gc_transaction
                                             li_bdcdata
                                      CHANGING li_bdcmsg.
            PERFORM f_log_msg USING wa_leg_tab
                                     li_bdcmsg.
            REFRESH: li_bdcdata[],
                     li_bdcmsg[].

**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
**            PERFORM f_populate_knumh USING lv_index
**                                           wa_leg_tab
**                                     CHANGING i_leg_tab.
**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
**      If the Condition Table = A905 and the Parameter = 'D'(Delete)
          ELSEIF wa_leg_tab-parameter = lc_delete.
            PERFORM f_bdc_create15 USING wa_leg_tab
                                         lv_access_seq
                                 CHANGING li_bdcdata.
            PERFORM f_bdc_transaction USING gc_transaction
                                             li_bdcdata
                                      CHANGING li_bdcmsg.
            PERFORM f_log_msg USING wa_leg_tab
                                     li_bdcmsg.
            REFRESH: li_bdcdata[],
                     li_bdcmsg[].
          ENDIF.
        ENDIF.
**&& -- BOC : CR# 1289 : PROUT : 05-MAY-2014
      ENDIF.
    ENDLOOP.
*    COMMIT WORK AND WAIT.

*&&-- Check for the updated records and populate the KNUMH
    PERFORM f_populate_knumh CHANGING i_leg_tab.
*&&-- Populate the Internal Comment in Condition Record
    SORT i_leg_tab BY knumh.

*&&-- Populate the KNUMH in case of Update & Delete in li_leg_tab
*    PERFORM f_populate_knumh CHANGING li_leg_tab.
    PERFORM f_condition_record USING i_leg_tab
                               CHANGING i_konp.

**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
  ENDIF.
ENDFORM.                    " F_UPLOAD_DATA

*&---------------------------------------------------------------------*
*&      Form  F_LOG_ERROR
*&---------------------------------------------------------------------*
* Get Message Description
*&---------------------------------------------------------------------*
FORM f_log_msg USING fp_wa_leg_tab TYPE ty_leg_tab
                     fp_li_bdcmsg TYPE ty_t_bdcmsgcoll.

  DATA : lwa_return TYPE bapiret2, " bapi return
         lv_par1 TYPE char50," parameter1
         lv_par2 TYPE char50," parameter2
         lv_par3 TYPE char50," parameter3
         lv_par4 TYPE char50," parameter1
         lv_num  TYPE bapiret2-number."message number
** BOC : CR# 1289 :PROUT :5-MAY-2014
  FIELD-SYMBOLS : <lfs_bdc_msg> TYPE ty_bdcmsgcoll.

  CONSTANTS: lc_success TYPE char1 VALUE 'S', " Success
             lc_error TYPE char1 VALUE 'E', " Error
             lc_msgid_00 TYPE char4 VALUE '00', " Msg Id - 00
             lc_msgid_348 TYPE char4 VALUE '348', " Msg Id - 348
             lc_msgid_358 TYPE char4 VALUE '358', " Msg Id - 358
             lc_msgid_vk TYPE char4 VALUE 'VK', " Msg Id - VK
             lc_msgid_021 TYPE char4 VALUE '021', " Msg Id - 021
             lc_msgid_083 TYPE char4 VALUE '083'. " Msg Id - 083

  CLEAR wa_report.
  wa_report-msgtyp = wa_leg_tab-parameter.

**&& -- No Binary Search applied since Sorting will disrupt the order
**      in fp_li_bdcmsg.
  READ TABLE fp_li_bdcmsg ASSIGNING <lfs_bdc_msg>
                          WITH KEY msgtyp = c_error.
  IF sy-subrc IS NOT INITIAL.
    READ TABLE fp_li_bdcmsg ASSIGNING <lfs_bdc_msg>
                          WITH KEY msgtyp = lc_success.
    IF sy-subrc IS INITIAL.
*&&-- The below cases also goes to unsuccessful update
      IF ( <lfs_bdc_msg>-msgid = lc_msgid_00 AND <lfs_bdc_msg>-msgnr = lc_msgid_348 )
        OR ( <lfs_bdc_msg>-msgid = lc_msgid_00 AND <lfs_bdc_msg>-msgnr = lc_msgid_358 )
        OR ( <lfs_bdc_msg>-msgid = lc_msgid_vk AND <lfs_bdc_msg>-msgnr = lc_msgid_021 )
        OR ( <lfs_bdc_msg>-msgid = lc_msgid_vk AND <lfs_bdc_msg>-msgnr = lc_msgid_083 ).
*        OR ( <lfs_bdc_msg>-msgid = lc_msgid_vk AND <lfs_bdc_msg>-msgnr = '100' ).


        CLEAR : lwa_return, lv_par1, lv_par2, lv_par3, lv_par4, lv_num.
**&& -- Assigning the values from li_bdcmsg[] to local variables.
        lv_par1 = <lfs_bdc_msg>-msgv1.
        lv_par2 = <lfs_bdc_msg>-msgv2.
        lv_par3 = <lfs_bdc_msg>-msgv3.
        lv_par4 = <lfs_bdc_msg>-msgv4.
        lv_num  = <lfs_bdc_msg>-msgnr.

        CALL FUNCTION 'BALW_BAPIRETURN_GET2'
          EXPORTING
            type   = lc_error
            cl     = <lfs_bdc_msg>-msgid
            number = lv_num
            par1   = lv_par1
            par2   = lv_par2
            par3   = lv_par3
            par4   = lv_par4
          IMPORTING
            return = lwa_return.

        wa_report-msgtxt = lwa_return-message.
        gv_error = gv_error + 1.
      ELSE.   "msgtyp = 'S'

*&&-- Successfully Done
        CLEAR : lwa_return, lv_par1, lv_par2, lv_par3, lv_par4, lv_num.

        lv_par1 = <lfs_bdc_msg>-msgv1.
        lv_par2 = <lfs_bdc_msg>-msgv2.
        lv_par3 = <lfs_bdc_msg>-msgv3.
        lv_par4 = <lfs_bdc_msg>-msgv4.
        lv_num  = <lfs_bdc_msg>-msgnr.

        CALL FUNCTION 'BALW_BAPIRETURN_GET2'
          EXPORTING
            type   = lc_success
            cl     = <lfs_bdc_msg>-msgid
            number = lv_num
            par1   = lv_par1
            par2   = lv_par2
            par3   = lv_par3
            par4   = lv_par4
          IMPORTING
            return = lwa_return.
        wa_report-msgtxt = lwa_return-message.
      ENDIF.
    ENDIF.
  ELSE.

    CLEAR : lwa_return, lv_par1, lv_par2, lv_par3, lv_par4, lv_num.

    lv_par1 = <lfs_bdc_msg>-msgv1.
    lv_par2 = <lfs_bdc_msg>-msgv2.
    lv_par3 = <lfs_bdc_msg>-msgv3.
    lv_par4 = <lfs_bdc_msg>-msgv4.
    lv_num  = <lfs_bdc_msg>-msgnr.

    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type   = lc_error
        cl     = <lfs_bdc_msg>-msgid
        number = lv_num
        par1   = lv_par1
        par2   = lv_par2
        par3   = lv_par3
        par4   = lv_par4
      IMPORTING
        return = lwa_return.
    wa_report-msgtxt = lwa_return-message.
    gv_error = gv_error + 1.
  ENDIF.
**** EOC : CR# 1289 :PROUT :5-MAY-2014

  CONCATENATE wa_leg_tab-kappl
              wa_leg_tab-kschl
              wa_leg_tab-vkorg
              wa_leg_tab-vtweg
              wa_leg_tab-kunnr
              wa_leg_tab-matnr
              wa_leg_tab-datab
              wa_leg_tab-datbi
              wa_leg_tab-prod
              wa_leg_tab-zzkvgr1
              wa_leg_tab-zzkvgr2
             INTO gv_mkey SEPARATED BY space.

  wa_report-key    = gv_mkey.
  APPEND wa_report TO i_report.
  CLEAR wa_report.
ENDFORM.                    " F_LOG_ERROR
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_DATE
*&---------------------------------------------------------------------*
*      Check for valid date
*----------------------------------------------------------------------*
FORM f_check_date  USING  fp_text
                          fp_date
                          fp_lwa_file TYPE ty_file.         "CR#1289++.
*                   CHANGING fp_return TYPE c.

  DATA: lv_date_from TYPE char10,
        lv_date_to TYPE char10.

  CLEAR gv_return1.

  CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
    EXPORTING
      date                      = fp_date
    EXCEPTIONS
      plausibility_check_failed = 1
      OTHERS                    = 2.
*Invalid Date
  IF sy-subrc <> 0.
    CLEAR wa_report.
    wa_report-msgtyp = c_error.
    wa_report-msgtxt = fp_text.

    CONCATENATE fp_lwa_file-datab+4(2)
                '.'
                fp_lwa_file-datab+6(2)
                '.'
                fp_lwa_file-datab+0(4)
                INTO lv_date_from.
    CONCATENATE fp_lwa_file-datbi+4(2)
                '.'
                fp_lwa_file-datbi+6(2)
                '.'
                fp_lwa_file-datbi+0(4)
                INTO lv_date_to.
**** BOC : CR# 1289 :PROUT :5-MAY-2014
    CONCATENATE
             fp_lwa_file-kappl
             fp_lwa_file-kschl
             fp_lwa_file-vkorg
             fp_lwa_file-vtweg
             fp_lwa_file-kunnr
             fp_lwa_file-matnr
             lv_date_from
             lv_date_to
             fp_lwa_file-prod
             fp_lwa_file-zzkvgr1
             fp_lwa_file-zzkvgr2
             INTO gv_mkey SEPARATED BY space.
**** EOC : CR# 1289 :PROUT :5-MAY-2014
    wa_report-key    = gv_mkey.
    APPEND wa_report TO i_report.
    CLEAR wa_report.
    gv_error = gv_error + 1.
    gv_skip   = gv_skip + 1.
    APPEND  wa_leg_tab TO i_leg_tab_err.
*    fp_return = c_selected.
    gv_return1 = c_selected.
  ENDIF.
ENDFORM.                    " F_CHECK_DATE
*&---------------------------------------------------------------------*
*&      Form  F_DATE_CONVERT
*&---------------------------------------------------------------------*
*    Convert Date from MM.DD.YYYY to YYYYMMDD
*----------------------------------------------------------------------*
FORM f_date_convert  USING    fp_lv_date CHANGING fp_date TYPE datum.

  CONCATENATE fp_lv_date+6(4)
              fp_lv_date+0(2)
              fp_lv_date+3(2)
  INTO        fp_date.
ENDFORM.                    " F_DATE_CONVERT
*&---------------------------------------------------------------------*
*&      Form  F_LEGACY_MATERIAL
*&---------------------------------------------------------------------*
*    populate internal table i_legacy_tab to be mapped to ECC materials
*----------------------------------------------------------------------*
FORM f_legacy_material USING fp_matnr.
  CLEAR wa_legacy_tab.
  wa_legacy_tab-object_type      = 'MARA'.
  wa_legacy_tab-source_key_value = fp_matnr.
  APPEND wa_legacy_tab TO i_legacy_tab.
ENDFORM.                    " F_LEGACY_MATERIAL
*&---------------------------------------------------------------------*
*&      Form  F_MAP_LEGACY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_map_legacy .

  DATA : lwa_ecc_tab     TYPE zzlegacy_ecc_translate,
         li_ecc_tab      TYPE STANDARD TABLE OF zzlegacy_ecc_translate
                         INITIAL SIZE 0.
  IF cb_map = c_selected.
    REFRESH li_ecc_tab[].
    CALL FUNCTION 'ZMDM_TRANSLATION_LEGACY_ECC'
      EXPORTING
        im_translate               = 'E'
      TABLES
        tbl_input_tab              = i_legacy_tab
      CHANGING
        tbl_return_tab             = li_ecc_tab
      EXCEPTIONS
        no_ecc_value_found         = 1
        no_legacy_value_found      = 2
        invalid_translation_option = 3
        OTHERS                     = 4.


    SORT li_ecc_tab ASCENDING BY source_key_value.

    LOOP AT i_leg_tab ASSIGNING <fs_leg_tab>.
      CLEAR lwa_ecc_tab.
      READ TABLE li_ecc_tab INTO lwa_ecc_tab
                            WITH KEY source_key_value = <fs_leg_tab>-matnr
                            BINARY SEARCH.
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

      ELSE.
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            input        = <fs_leg_tab>-matnr
          IMPORTING
            output       = <fs_leg_tab>-matnr
          EXCEPTIONS
            length_error = 1
            OTHERS       = 2.
      ENDIF.
    ENDLOOP.

  ELSE.
    LOOP AT i_leg_tab ASSIGNING <fs_leg_tab>.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          input        = <fs_leg_tab>-matnr
        IMPORTING
          output       = <fs_leg_tab>-matnr
        EXCEPTIONS
          length_error = 1
          OTHERS       = 2.

    ENDLOOP.
  ENDIF.
* Check if material is allowed for a given sales org / distribution channel
  REFRESH i_leg_tab_temp[].
  i_leg_tab_temp[] = i_leg_tab[].
  SORT  i_leg_tab_temp ASCENDING BY matnr ASCENDING vkorg ASCENDING vtweg.
  DELETE ADJACENT DUPLICATES FROM i_leg_tab_temp COMPARING matnr vkorg vtweg.


*START CHANGE Defect 267
* populate internal table i_leg_tab_temp1 for all entries for KNA1
  REFRESH i_leg_tab_temp1[].
  i_leg_tab_temp1[] = i_leg_tab[].
  SORT  i_leg_tab_temp1 ASCENDING BY kunnr.
  DELETE ADJACENT DUPLICATES FROM i_leg_tab_temp1 COMPARING kunnr.
*END CHANGE Defect 267

  REFRESH i_mvke[].
  IF i_leg_tab_temp[] IS NOT INITIAL.
    SELECT  matnr
            vkorg
            vtweg
    FROM mvke
    INTO TABLE i_mvke
    FOR ALL ENTRIES IN i_leg_tab_temp
    WHERE   matnr =  i_leg_tab_temp-matnr AND
            vkorg =  i_leg_tab_temp-vkorg AND
            vtweg =  i_leg_tab_temp-vtweg.
    IF sy-subrc = 0.
      SORT i_mvke ASCENDING BY  matnr
                  ASCENDING     vkorg
                  ASCENDING     vtweg.

    ENDIF.
  ENDIF.

*START CHANGE Defect 267
*Get KNA1
  REFRESH i_kna1[].
  IF i_leg_tab_temp1[] IS NOT INITIAL.
    IF gv_table = c_005 OR
       gv_table = c_903 OR
*START DEFECT  2390 01/08/2013
       gv_table = c_911.
*END DEFECT 2390 01/08/2013
      SELECT  kunnr
              aufsd
       FROM kna1
       INTO TABLE i_kna1
       FOR ALL ENTRIES IN i_leg_tab_temp1
       WHERE   kunnr =  i_leg_tab_temp1-kunnr.
      IF sy-subrc = 0.
        SORT i_kna1 ASCENDING BY  kunnr.
      ENDIF.
    ENDIF.
  ENDIF.
*END CHANGE Defect 267

ENDFORM.                    " F_MAP_LEGACY
**&---------------------------------------------------------------------*
**&      Form  F_READ_RECORD_A005
**&---------------------------------------------------------------------*
**    populate internal table i_leg_tab for fields required for
**    condition table A005
**----------------------------------------------------------------------*
*FORM f_read_record_a005 .
*
*  DATA : lv_kbetr(16) TYPE c.
*  DATA : lv_konwa(5) TYPE c.
*  DATA : lv_kpein(5) TYPE c.
*  DATA : lv_kmein(3) TYPE c.
*
*
*  LOOP AT i_string INTO wa_string.
**skip header record
*    IF sy-tabix > 1.
*      CLEAR: gv_datab, gv_datbi, lv_kbetr.
*      SPLIT  wa_string-string AT c_tab INTO
*             lwa_file-kappl
*             lwa_file-kschl
*             lwa_file-vkorg
*             lwa_file-vtweg
*             lwa_file-kunnr
*             lwa_file-matnr
*             gv_datab
*             gv_datbi
*             lv_kbetr
*             lv_konwa
*             lv_kpein
*             lv_kmein
**START OF CR700 changed by nnm
*             lwa_file-ltx01. " Work area for Long text line
**END OF CR700
*
*      lwa_file-kbetr = lv_kbetr.
*
*      lwa_file-konwa = lv_konwa.
*      lwa_file-kpein = lv_kpein.
*      lwa_file-kmein = lv_kmein.
*
**convert from date from MM.DD.YYYY to YYYYMM DD
*      PERFORM f_date_convert USING gv_datab
*                             CHANGING lwa_file-datab.
**Check valid date
*      PERFORM f_check_date   USING text-024 lwa_file-datab.
**                             CHANGING gv_return1.
**Error skip record
*      IF gv_return1 = c_selected.
*        CONTINUE.
*      ENDIF.
*
**convert to date from MM.DD.YYYY to YYYYMM DD
*      PERFORM f_date_convert USING gv_datbi
*                             CHANGING lwa_file-datbi.
**Check valid date
*      PERFORM f_check_date   USING text-025 lwa_file-datbi.
**                             CHANGING gv_return1.
*      IF gv_return1 = c_selected.
**Error skip record
*        CONTINUE.
*      ENDIF.
*
**populate material mapping table
*      PERFORM f_legacy_material USING lwa_file-matnr.
**convert customer to ECC format
*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          input  = lwa_file-kunnr
*        IMPORTING
*          output = lwa_file-kunnr.
*      MOVE-CORRESPONDING lwa_file TO wa_leg_tab.
*      APPEND wa_leg_tab TO i_leg_tab.
*    ENDIF.
*  ENDLOOP.
*ENDFORM.                    " F_READ_RECORD_A005
**&---------------------------------------------------------------------*
**&      Form  F_READ_RECORD_A903
**&---------------------------------------------------------------------*
**    populate internal table i_leg_tab for fields required for
**    condition table A903
**----------------------------------------------------------------------*
*FORM f_read_record_a903 .
*  DATA : lv_kbetr(16) TYPE c.
*  DATA : lv_konwa(5) TYPE c.
*  DATA : lv_kpein(5) TYPE c.
*  DATA : lv_kmein(3) TYPE c.
*  .
*  LOOP AT i_string INTO wa_string.
*    IF sy-tabix > 1.
*      CLEAR: gv_datab, gv_datbi , lv_kbetr.
*      SPLIT  wa_string-string AT c_tab INTO
*             wa_903-kappl
*             wa_903-kschl
*             wa_903-vkorg
*             wa_903-vtweg
*             wa_903-kunnr
*             wa_903-prod
*             gv_datab
*             gv_datbi
*             lv_kbetr
*             lv_konwa
*             lv_kpein
*             lv_kmein
**START OF CR700 changed by nnm
*             wa_903-ltx01. " Work area for Long text line
**END OF CR700
*
*      wa_903-kbetr = lv_kbetr.
*      wa_903-konwa = lv_konwa.
*      wa_903-kpein = lv_kpein.
*      wa_903-kmein = lv_kmein.
*
*      PERFORM f_date_convert USING gv_datab
*                             CHANGING wa_903-datab.
*      PERFORM f_check_date   USING text-024 wa_903-datab.
**                             CHANGING gv_return1.
*      IF gv_return1 = c_selected.
*        CONTINUE.
*      ENDIF.
*
*      PERFORM f_date_convert USING gv_datbi
*                             CHANGING wa_903-datbi.
*      PERFORM f_check_date   USING text-025 wa_903-datbi.
**                             CHANGING gv_return1.
*      IF gv_return1 = c_selected.
*        CONTINUE.
*      ENDIF.
*
*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          input  = wa_903-kunnr
*        IMPORTING
*          output = wa_903-kunnr.
*
*      MOVE-CORRESPONDING wa_903 TO wa_leg_tab.
*      APPEND wa_leg_tab TO i_leg_tab.
*    ENDIF.
*  ENDLOOP.
*ENDFORM.                    " F_READ_RECORD_A903
**&---------------------------------------------------------------------*
**&      Form  F_READ_RECORD_A901
**&---------------------------------------------------------------------*
**    populate internal table i_leg_tab for fields required for
**    condition table A901
**----------------------------------------------------------------------*
*FORM f_read_record_a901 .
*  DATA : lv_kbetr(16) TYPE c.
*  DATA : lv_konwa(5) TYPE c.
*  DATA : lv_kpein(5) TYPE c.
*  DATA : lv_kmein(3) TYPE c.
*
*  LOOP AT i_string INTO wa_string.
*    IF sy-tabix > 1.
*      CLEAR: gv_datab, gv_datbi , lv_kbetr.
*      SPLIT  wa_string-string AT c_tab INTO
*             wa_901-kappl
*             wa_901-kschl
*             wa_901-vkorg
*             wa_901-vtweg
*             wa_901-zzkvgr1
*             wa_901-matnr
*             gv_datab
*             gv_datbi
*             lv_kbetr
*             lv_konwa
*             lv_kpein
*             lv_kmein
**START OF CR700 changed by nnm
*             wa_901-ltx01. " Work area for Long text line
**END OF CR700
*
*      wa_901-kbetr = lv_kbetr.
*      wa_901-konwa = lv_konwa.
*      wa_901-kpein = lv_kpein.
*      wa_901-kmein = lv_kmein.
*
*      CONCATENATE  wa_901-kappl
*                   wa_901-kschl
*                   wa_901-vkorg
*                   wa_901-vtweg
*                   wa_901-matnr
*                   gv_datab
*                   gv_datbi
*                   wa_901-zzkvgr1
*                  INTO gv_mkey SEPARATED BY space.
*
*      PERFORM f_date_convert USING gv_datab
*                             CHANGING wa_901-datab.
*      PERFORM f_check_date   USING text-024 wa_901-datab.
**                            CHANGING gv_return1.
*      IF gv_return1 = c_selected.
*        CONTINUE.
*      ENDIF.
*
*      PERFORM f_date_convert USING gv_datbi
*                             CHANGING wa_901-datbi.
*      PERFORM f_check_date   USING text-025 wa_901-datbi.
**                            CHANGING gv_return1.
*      IF gv_return1 = c_selected.
*        CONTINUE.
*      ENDIF.
*
**Start of Defect 1025
*      PERFORM f_check_buygrp   USING text-038 wa_901-zzkvgr1.
*
*      IF gv_return1 = c_selected.
*        CONTINUE.
*      ENDIF.
**End   of Defect 1025
*
**Start of Defect 1177
*
*      PERFORM f_valid_buygrp   USING text-039 wa_901-zzkvgr1.
*      IF gv_return1 = c_selected.
*        CONTINUE.
*      ENDIF.
**End   of Defect 1177
*
*      PERFORM f_legacy_material USING wa_901-matnr.
*      MOVE-CORRESPONDING wa_901 TO wa_leg_tab.
*      APPEND wa_leg_tab TO i_leg_tab.
*    ENDIF.
*  ENDLOOP.
*ENDFORM.                    " F_READ_RECORD_A901
**&---------------------------------------------------------------------*
**&      Form  F_READ_RECORD_A904
**&---------------------------------------------------------------------*
**    populate internal table i_leg_tab for fields required for
**    condition table A904
**----------------------------------------------------------------------*
*FORM f_read_record_a904 .
*  DATA : lv_kbetr(16) TYPE c.
*  DATA : lv_konwa(5) TYPE c.
*  DATA : lv_kpein(5) TYPE c.
*  DATA : lv_kmein(3) TYPE c.
*
*  LOOP AT i_string INTO wa_string.
*    IF sy-tabix > 1.
*      CLEAR: gv_datab, gv_datbi , lv_kbetr.
*      SPLIT  wa_string-string AT c_tab INTO
*             wa_904-kappl
*             wa_904-kschl
*             wa_904-vkorg
*             wa_904-vtweg
*             wa_904-zzkvgr1
*             wa_904-prod
*             gv_datab
*             gv_datbi
*             lv_kbetr
*             lv_konwa
*             lv_kpein
*             lv_kmein
**START OF CR700 changed by nnm
*             wa_904-ltx01. " Work area for Long text line
**END OF CR700
*
*      CONCATENATE  wa_904-kappl
*                   wa_904-kschl
*                   wa_904-vkorg
*                   wa_904-vtweg
*                   gv_datab
*                   gv_datbi
*                   wa_904-prod
*                   wa_904-zzkvgr1
*                  INTO gv_mkey SEPARATED BY space.
*
*      wa_904-kbetr = lv_kbetr.
*      wa_904-konwa = lv_konwa.
*      wa_904-kpein = lv_kpein.
*      wa_904-kmein = lv_kmein.
*
*      PERFORM f_date_convert USING gv_datab
*                             CHANGING wa_904-datab.
*      PERFORM f_check_date   USING text-024 wa_904-datab.
**                             CHANGING gv_return1.
*      IF gv_return1 = c_selected.
*        CONTINUE.
*      ENDIF.
*
*      PERFORM f_date_convert USING gv_datbi CHANGING wa_904-datbi.
*      PERFORM f_check_date   USING text-025 wa_904-datbi.
**                             CHANGING gv_return1.
*      IF gv_return1 = c_selected.
*        CONTINUE.
*      ENDIF.
*
**Start of Defect 1025
*      PERFORM f_check_buygrp   USING text-038 wa_904-zzkvgr1.
*      IF gv_return1 = c_selected.
*        CONTINUE.
*      ENDIF.
**End   of Defect 1025
*
**Start of Defect 1177
*      PERFORM f_valid_buygrp   USING text-039 wa_904-zzkvgr1.
*      IF gv_return1 = c_selected.
*        CONTINUE.
*      ENDIF.
**End   of Defect 1177
*
*      MOVE-CORRESPONDING wa_904 TO wa_leg_tab.
*      APPEND wa_leg_tab TO i_leg_tab.
*    ENDIF.
*  ENDLOOP.
*ENDFORM.                    " F_READ_RECORD_A904
**&---------------------------------------------------------------------*
**&      Form  F_READ_RECORD_A902
**&---------------------------------------------------------------------*
**    populate internal table i_leg_tab for fields required for
**    condition table A902
**----------------------------------------------------------------------*
*FORM f_read_record_a902 .
*  DATA : lv_kbetr(16) TYPE c.
*  DATA : lv_konwa(5) TYPE c.
*  DATA : lv_kpein(5) TYPE c.
*  DATA : lv_kmein(3) TYPE c.
*
*  LOOP AT i_string INTO wa_string.
*    IF sy-tabix > 1.
*      CLEAR: gv_datab, gv_datbi, lv_kbetr.
*      SPLIT  wa_string-string AT c_tab INTO
*             wa_902-kappl
*             wa_902-kschl
*             wa_902-vkorg
*             wa_902-vtweg
*             wa_902-zzkvgr2
*             wa_902-matnr
*             gv_datab
*             gv_datbi
*             lv_kbetr
*             lv_konwa
*             lv_kpein
*             lv_kmein
**START OF CR700 changed by nnm
*             wa_902-ltx01. " Work area for Long text line
**END OF CR700
*
*      wa_902-kbetr = lv_kbetr.
*      wa_902-konwa = lv_konwa.
*      wa_902-kpein = lv_kpein.
*      wa_902-kmein = lv_kmein.
*
*      PERFORM f_date_convert USING gv_datab
*                             CHANGING wa_902-datab.
*      PERFORM f_check_date   USING text-024 wa_902-datab.
**                             CHANGING gv_return1.
*      IF gv_return1 = c_selected.
*        CONTINUE.
*      ENDIF.
*
*      PERFORM f_date_convert USING gv_datbi
*                             CHANGING wa_902-datbi.
*      PERFORM f_check_date   USING text-025 wa_902-datbi.
**                             CHANGING gv_return1.
*      IF gv_return1 = c_selected.
*        CONTINUE.
*      ENDIF.
*
*      PERFORM f_legacy_material USING wa_902-matnr.
*
*      MOVE-CORRESPONDING wa_902 TO wa_leg_tab.
*      APPEND wa_leg_tab TO i_leg_tab.
*    ENDIF.
*  ENDLOOP.
*ENDFORM.                    " F_READ_RECORD_A902
**&---------------------------------------------------------------------*
**&      Form  F_READ_RECORD_A905
**&---------------------------------------------------------------------*
**    populate internal table i_leg_tab for fields required for
**    condition table A905
**----------------------------------------------------------------------*
*FORM f_read_record_a905 .
*  DATA : lv_kbetr(16) TYPE c.
*  DATA : lv_konwa(5) TYPE c.
*  DATA : lv_kpein(5) TYPE c.
*  DATA : lv_kmein(3) TYPE c.
*
*  LOOP AT i_string INTO wa_string.
*    IF sy-tabix > 1.
*      CLEAR: gv_datab, gv_datbi , lv_kbetr.
*      SPLIT  wa_string-string AT c_tab INTO
*             wa_905-kappl
*             wa_905-kschl
*             wa_905-vkorg
*             wa_905-vtweg
*             wa_905-zzkvgr2
*             wa_905-prod
*             gv_datab
*             gv_datbi
*             lv_kbetr
*             lv_konwa
*             lv_kpein
*             lv_kmein
**START OF CR700 changed by nnm
*             wa_905-ltx01. " Work area for Long text line
**END OF CR700
*
*      wa_905-kbetr = lv_kbetr.
*      wa_905-konwa = lv_konwa.
*      wa_905-kpein = lv_kpein.
*      wa_905-kmein = lv_kmein.
*
*      PERFORM f_date_convert USING gv_datab
*                             CHANGING wa_905-datab.
*      PERFORM f_check_date   USING text-024 wa_905-datab.
**                             CHANGING gv_return1.
*      IF gv_return1 = c_selected.
*        CONTINUE.
*      ENDIF.
*
*      PERFORM f_date_convert USING gv_datbi
*                             CHANGING wa_905-datbi.
*      PERFORM f_check_date   USING text-025 wa_905-datbi.
**                             CHANGING gv_return1.
*      IF gv_return1 = c_selected.
*        CONTINUE.
*      ENDIF.
*      MOVE-CORRESPONDING wa_905 TO wa_leg_tab.
*      APPEND wa_leg_tab TO i_leg_tab.
*    ENDIF.
*  ENDLOOP.
*ENDFORM.                    " F_READ_RECORD_A905
**&---------------------------------------------------------------------*
**&      Form  F_READ_RECORD_A004
**&---------------------------------------------------------------------*
**    populate internal table i_leg_tab for fields required for
**    condition table A004
**----------------------------------------------------------------------*
*FORM f_read_record_a004 .
*  DATA : lv_kbetr(16) TYPE c.
*  DATA : lv_konwa(5) TYPE c.
*  DATA : lv_kpein(5) TYPE c.
*  DATA : lv_kmein(3) TYPE c.
*
*  LOOP AT i_string INTO wa_string.
*    IF sy-tabix > 1.
*      CLEAR: gv_datab, gv_datbi , lv_kbetr.
*      SPLIT  wa_string-string AT c_tab INTO
*             wa_004-kappl
*             wa_004-kschl
*             wa_004-vkorg
*             wa_004-vtweg
*             wa_004-matnr
*             gv_datab
*             gv_datbi
*             lv_kbetr
*             lv_konwa
*             lv_kpein
*             lv_kmein
**START OF CR700 changed by nnm
*             wa_004-ltx01. " Work area for Long text line
**END OF CR700
*
*      wa_004-kbetr = lv_kbetr.
*      wa_004-konwa = lv_konwa.
*      wa_004-kpein = lv_kpein.
*      wa_004-kmein = lv_kmein.
*
*      PERFORM f_date_convert USING gv_datab   CHANGING wa_004-datab.
*      PERFORM f_check_date   USING text-024 wa_004-datab.
**                             CHANGING gv_return1.
*      IF gv_return1 = c_selected.
*        CONTINUE.
*      ENDIF.
*
*      PERFORM f_date_convert USING gv_datbi CHANGING wa_004-datbi.
*      PERFORM f_check_date   USING text-025 wa_004-datbi.
**                             CHANGING gv_return1.
*      IF gv_return1 = c_selected.
*        CONTINUE.
*      ENDIF.
*      PERFORM f_legacy_material USING wa_004-matnr.
*      MOVE-CORRESPONDING wa_004 TO wa_leg_tab.
*      APPEND wa_leg_tab TO i_leg_tab.
*    ENDIF.
*  ENDLOOP.
*ENDFORM.                    " F_READ_RECORD_A004
**&---------------------------------------------------------------------*
**&      Form  F_GET_TABLE_NAME
**&---------------------------------------------------------------------*
**    get condition table name from file name to be uploaded
**----------------------------------------------------------------------*
*FORM f_get_table_name .
*
**get condition table name from file name
**last 3 characters from .txt extension
*  CLEAR : gv_fname , gv_extn1 , gv_length , gv_table.
*  SPLIT gv_filename AT '.' INTO gv_fname gv_extn1.
*  gv_length = strlen( gv_fname ).
*  gv_length = gv_length - 3.
*  gv_table  = gv_fname+gv_length(3).
*
*
*ENDFORM.                    " F_GET_TABLE_NAME
*&---------------------------------------------------------------------*
*&      Form  F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_logical_to_physical  USING    fp_p_alog
                            CHANGING fp_gv_modify.

  DATA:   li_input   TYPE zdev_t_file_list_in,
          lwa_input  TYPE zdev_file_list_in,
          li_output  TYPE zdev_t_file_list_out,
          lwa_output TYPE zdev_file_list_out,
          li_error   TYPE zdev_t_file_list_error.

* Passing the logical file path to get the physical file path
  lwa_input-path = fp_p_alog.
  APPEND lwa_input TO li_input.
  CLEAR lwa_input.

* Retrieving all files within the directory
  CALL FUNCTION 'ZDEV_DIRECTORY_FILE_LIST'
    EXPORTING
      im_identifier      = c_true
      im_input           = li_input
    IMPORTING
      ex_output          = li_output
      ex_error           = li_error
    EXCEPTIONS
      no_input           = 1
      invalid_identifier = 2
      no_data_found      = 3
      OTHERS             = 4.

  IF sy-subrc <> 0.
    MESSAGE i020.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF sy-subrc IS INITIAL AND
     li_error IS INITIAL.

*   Getting the file path
    READ TABLE li_output INTO lwa_output INDEX 1.
    IF sy-subrc IS INITIAL.
      CONCATENATE lwa_output-physical_path
      lwa_output-filename
      INTO fp_gv_modify.
    ENDIF.
  ELSE.
*   Logical file path & could not be read for input files.
    MESSAGE i037 WITH fp_p_alog.
    LEAVE LIST-PROCESSING.
  ENDIF.

* If Header file could not be retrieved, then issuing an error message
  IF fp_gv_modify IS INITIAL.
    MESSAGE i103 WITH fp_p_alog.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.                    " F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*&      Form  F_VERIFY_DAT
*&---------------------------------------------------------------------*
* Check condition type , sales organization and distribution channel
*----------------------------------------------------------------------*
FORM f_verify_date .


  FIELD-SYMBOLS : <lfs_mvke> TYPE ty_mvke,
                  <lfs_kna1> TYPE ty_kna1.

  CLEAR:  wa_t685, gv_error_check.
  READ TABLE i_t685 INTO wa_t685 WITH KEY kschl = wa_leg_tab-kschl BINARY SEARCH.
  IF sy-subrc <> 0.
    gv_error_check = 'X'.
    CLEAR wa_report.
    wa_report-msgtyp = c_error.
    wa_report-msgtxt = text-026. "Invalid Condition Type
    CONCATENATE
             wa_leg_tab-kappl
             wa_leg_tab-kschl
             wa_leg_tab-vkorg
             wa_leg_tab-vtweg
             wa_leg_tab-kunnr
             wa_leg_tab-matnr
             wa_leg_tab-datab
             wa_leg_tab-datbi
             wa_leg_tab-prod
             wa_leg_tab-zzkvgr1
             wa_leg_tab-zzkvgr2

                  INTO gv_mkey SEPARATED BY space.

    wa_report-key    = gv_mkey.
    APPEND wa_report TO i_report.
    CLEAR wa_report.
    gv_error = gv_error + 1.
    APPEND  wa_leg_tab TO i_leg_tab_err.
    RETURN.
  ENDIF.

  CLEAR wa_tvko.
  READ TABLE i_tvko INTO wa_tvko WITH KEY vkorg = wa_leg_tab-vkorg BINARY SEARCH.
  IF sy-subrc <> 0.
    gv_error_check = 'X'.
    CLEAR wa_report.
    wa_report-msgtyp = c_error.
    wa_report-msgtxt = text-027. "Invalid Sales Organization
    CONCATENATE

             wa_leg_tab-kappl
             wa_leg_tab-kschl
             wa_leg_tab-vkorg
             wa_leg_tab-vtweg
             wa_leg_tab-kunnr
             wa_leg_tab-matnr
             wa_leg_tab-datab
             wa_leg_tab-datbi
             wa_leg_tab-prod
             wa_leg_tab-zzkvgr1
             wa_leg_tab-zzkvgr2

                  INTO gv_mkey SEPARATED BY space.

    wa_report-key    = gv_mkey.
    APPEND wa_report TO i_report.
    CLEAR wa_report.
    gv_error = gv_error + 1.
    APPEND  wa_leg_tab TO i_leg_tab_err.
    RETURN.
  ENDIF.

  CLEAR wa_tvtw.
  READ TABLE i_tvtw INTO wa_tvtw WITH KEY vtweg = wa_leg_tab-vtweg BINARY SEARCH.
  IF sy-subrc <> 0.
    gv_error_check = 'X'.
    CLEAR wa_report.
    wa_report-msgtyp = c_error.
    wa_report-msgtxt = text-028."Invalid Distribution Channe
    CONCATENATE
             wa_leg_tab-kappl
             wa_leg_tab-kschl
             wa_leg_tab-vkorg
             wa_leg_tab-vtweg
             wa_leg_tab-kunnr
             wa_leg_tab-matnr
             wa_leg_tab-datab
             wa_leg_tab-datbi
             wa_leg_tab-prod
             wa_leg_tab-zzkvgr1
             wa_leg_tab-zzkvgr2

                  INTO gv_mkey SEPARATED BY space.

    wa_report-key    = gv_mkey.
    APPEND wa_report TO i_report.
    CLEAR wa_report.
    gv_error = gv_error + 1.
    APPEND  wa_leg_tab TO i_leg_tab_err.
    RETURN.
  ENDIF.

  IF gv_table = c_005 OR
     gv_table = c_901 OR
     gv_table = c_902 OR
     gv_table = c_004.

    READ TABLE i_mvke ASSIGNING <lfs_mvke> WITH KEY matnr = wa_leg_tab-matnr
                                                     vkorg = wa_leg_tab-vkorg
                                                     vtweg = wa_leg_tab-vtweg
                                                     BINARY SEARCH.
    IF sy-subrc <> 0.

      CLEAR wa_report.
      wa_report-msgtyp = c_error.
      CONCATENATE text-034 ':' wa_leg_tab-matnr ','
                               wa_leg_tab-vkorg ','
                               wa_leg_tab-vtweg
      INTO              wa_report-msgtxt  .

      CONCATENATE   wa_leg_tab-kappl
                    wa_leg_tab-kschl
                    wa_leg_tab-vkorg
                    wa_leg_tab-vtweg
                    wa_leg_tab-kunnr
                    wa_leg_tab-matnr
                    wa_leg_tab-datab
                    wa_leg_tab-datbi
                    wa_leg_tab-prod
                    wa_leg_tab-zzkvgr1
                    wa_leg_tab-zzkvgr2
                    INTO gv_mkey SEPARATED BY space.
      wa_report-key    = gv_mkey.
      APPEND wa_report TO i_report.
      CLEAR wa_report.
      gv_error = gv_error + 1.
      gv_skip   = gv_skip + 1.
      APPEND  wa_leg_tab TO i_leg_tab_err.
      gv_error_check = 'X'.
      RETURN.
    ENDIF.
  ENDIF.

  IF gv_table = c_005 OR
     gv_table = c_903.

    READ TABLE i_kna1 ASSIGNING <lfs_kna1> WITH KEY    kunnr  = wa_leg_tab-kunnr
                                                       BINARY SEARCH.
    IF sy-subrc <> 0.
      CLEAR wa_report.
      wa_report-msgtyp = c_error.
      CONCATENATE text-036 ':' wa_leg_tab-kunnr
      INTO              wa_report-msgtxt  .

      CONCATENATE   wa_leg_tab-kappl
                    wa_leg_tab-kschl
                    wa_leg_tab-vkorg
                    wa_leg_tab-vtweg
                    wa_leg_tab-kunnr
                    wa_leg_tab-matnr
                    wa_leg_tab-datab
                    wa_leg_tab-datbi
                    wa_leg_tab-prod
                    wa_leg_tab-zzkvgr1
                    wa_leg_tab-zzkvgr2
                    INTO gv_mkey SEPARATED BY space.
      wa_report-key    = gv_mkey.
      APPEND wa_report TO i_report.
      CLEAR wa_report.
      gv_error = gv_error + 1.
      gv_skip   = gv_skip + 1.
      APPEND  wa_leg_tab TO i_leg_tab_err.
      gv_error_check = 'X'.
      RETURN.
    ENDIF.
  ENDIF.

  IF wa_leg_tab-datab > wa_leg_tab-datbi.
    CLEAR wa_report.
    wa_report-msgtyp = c_error.
    wa_report-msgtxt = text-037.
    CONCATENATE   wa_leg_tab-kappl
                  wa_leg_tab-kschl
                  wa_leg_tab-vkorg
                  wa_leg_tab-vtweg
                  wa_leg_tab-kunnr
                  wa_leg_tab-matnr
                  wa_leg_tab-datab
                  wa_leg_tab-datbi
                  wa_leg_tab-prod
                  wa_leg_tab-zzkvgr1
                  wa_leg_tab-zzkvgr2
                  INTO gv_mkey SEPARATED BY space.
    wa_report-key    = gv_mkey.
    APPEND wa_report TO i_report.
    CLEAR wa_report.
    gv_error = gv_error + 1.
    gv_skip   = gv_skip + 1.
    APPEND  wa_leg_tab TO i_leg_tab_err.
    gv_error_check = 'X'.
    RETURN.
  ENDIF.
ENDFORM.                    " F_VERIFY_DATE

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_SUMMARY_REPORT1
*&---------------------------------------------------------------------*
*       Display ALV report
*----------------------------------------------------------------------*
*      -->P_I_REPORT[]  text
*      -->P_GV_FILE  text
*      -->P_GV_MODE  text
*      -->P_GV_NO_SUCCESS  text
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM f_display_summary_report1 USING fp_i_report      TYPE ty_t_report_p
                                    fp_gv_filename_d TYPE localfile
                                    fp_gv_mode       TYPE char50
                                    fp_no_success    TYPE int4
                                    fp_no_failed     TYPE int4.
* Local Data declaration
  TYPES: BEGIN OF ty_report_b,
          msgtyp TYPE char1,    "Error Type
          msgtxt TYPE char256,  "Error Text
          key    TYPE char256,  "Error Key
         END OF ty_report_b.

  CONSTANTS: c_hline TYPE char100            " Dotted Line
             VALUE
'-----------------------------------------------------------',
             c_slash TYPE char1 VALUE '/'. "slash

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
        lv_archive_1   TYPE localfile,      "Archieve File Path
        lv_session_1   TYPE apq_grpn,       "BDC Session Name
        lv_session_2   TYPE apq_grpn,       "BDC Session Name
        lv_session_3   TYPE apq_grpn,       "BDC Session Name
        lv_session(90) TYPE c,              "All session names
        lv_row         TYPE i,              "Row number
        lv_width_msg   TYPE outputlen,      "Column Width
        lv_width_key   TYPE outputlen,      "Column Width
        li_fieldcat    TYPE slis_t_fieldcat_alv, "Field Catalog
        li_events      TYPE slis_t_event,"alv events
        lwa_events     TYPE slis_alv_event,"alv ebetns
        li_report_b    TYPE STANDARD TABLE OF ty_report_b INITIAL SIZE 0, " report table
        lwa_report_b   TYPE ty_report_b."report workarea

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
  ENDIF.

  IF lv_session_2 IS NOT INITIAL.
    IF lv_session IS NOT INITIAL.
      CONCATENATE lv_session c_slash lv_session_2
      INTO lv_session SEPARATED BY space.
    ELSE.
      lv_session = lv_session_2.
    ENDIF.
  ENDIF.

  IF lv_session_3 IS NOT INITIAL.
    IF lv_session IS NOT INITIAL.
      CONCATENATE lv_session c_slash lv_session_3
      INTO lv_session SEPARATED BY space.
    ELSE.
      lv_session = lv_session_3.
    ENDIF.
  ENDIF.

  IF lv_session IS NOT INITIAL.
    CONCATENATE lv_session text-x32 INTO lv_session
    SEPARATED BY space.
  ENDIF.

  LOOP AT fp_i_report ASSIGNING <fs>.
    lwa_report_b-msgtyp = <fs>-msgtyp.
    lwa_report_b-msgtxt = <fs>-msgtxt.
    lwa_report_b-key = <fs>-key.
    APPEND lwa_report_b TO li_report.
    CLEAR lwa_report_b.
  ENDLOOP.
*
*  li_report[] = fp_i_report[].

  WRITE sy-uzeit TO lv_uzeit.
  WRITE sy-datum TO lv_datum.
  CONCATENATE lv_datum lv_uzeit INTO lv_datum SEPARATED BY space.

  lv_total = fp_no_success + fp_no_failed.
  IF lv_total <> 0.
    lv_rate = 100 * fp_no_success / lv_total.
  ENDIF.

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
    ENDIF.

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
    ENDIF.

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
  ELSE.
*   Passing local variable values to global variable to make it
*   avilable in top of page subroutine.
    gv_filename_d = fp_gv_filename_d.
    gv_filename_d_arch = lv_archive_1.
    gv_mode_b = fp_gv_mode.
    gv_session = lv_session.

* START CHANGE Defect 264
* Increased Variables size to INT4 from INT2
*   gv_total = lv_total.
*   gv_no_success = fp_no_success.
*   gv_no_failed = fp_no_failed.
    gv_total2      = lv_total.
    gv_no_success2 = fp_no_success.
    gv_no_failed2  = fp_no_failed.
* END CHANGE Defect 264
    gv_rate_c = lv_rate_c.
    LOOP AT fp_i_report ASSIGNING <fs>.
      lwa_report_b-msgtyp = <fs>-msgtyp.
      lwa_report_b-msgtxt = <fs>-msgtxt.
      lwa_report_b-key = <fs>-key.
*     Getting the maximum length of columns MSGTXT.
      IF lv_width_msg   LT strlen( <fs>-msgtxt ).
        lv_width_msg = strlen( <fs>-msgtxt ).
      ENDIF.
*     Getting the maximum length of column KEY.
      IF lv_width_key   LT strlen( <fs>-key ).
        lv_width_key = strlen( <fs>-key ).
      ENDIF.
      APPEND lwa_report_b TO li_report_b.
      CLEAR lwa_report_b.
    ENDLOOP.

    IF lv_width_key LT 150.
      lv_width_key = 150.
    ENDIF.

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
      MESSAGE e002(zca_msg).
    ENDIF.
  ENDIF.

ENDFORM.                    " F_DISPLAY_SUMMARY_REPORT1
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_INPUT
*&---------------------------------------------------------------------*
*       Checking whether the file name has been entered or not
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_check_input .

* If No presentation Server file name is entered and Presentation
* Server Option has been chosen, then issueing error message.
  IF rb_pres IS NOT INITIAL AND
     p_phdr IS INITIAL.
    MESSAGE i000
    WITH 'Presentation server file has not been entered'(002).
    LEAVE LIST-PROCESSING.
  ENDIF.

* For Application Server
  IF rb_app IS NOT INITIAL.
*   If No Application Server file name is entered and Application
*   Server Option has been chosen, then issueing error message.
    IF rb_aphy IS NOT INITIAL AND
       p_ahdr IS INITIAL.
      MESSAGE i000
      WITH 'Application server file has not been entered'(019).
      LEAVE LIST-PROCESSING.
    ENDIF.

* If No Logical File Path is entered and Logical File Path Option
* has been chosen, then issueing error message.
    IF rb_alog IS NOT INITIAL AND
       p_alog IS INITIAL.
      MESSAGE i000
      WITH 'Logical File Path has not been entered'(020).
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_CHECK_INPUT


*&---------------------------------------------------------------------*
*&      Form  F_TOP_OF_PAGE1
*&---------------------------------------------------------------------*
*       Subroutine for header display
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_top_of_page1.
* Horizontal Line.
  CONSTANTS: c_hline TYPE char50            " Dotted Line
             VALUE
'--------------------------------------------------',
             c_colon TYPE char1 VALUE ':'.

* Run Information
  WRITE: / text-x01.
* Horizontal Line
  WRITE: / c_hline.
* File Read
  WRITE: / text-x02, 50(1) c_colon, 52 gv_filename_d.
  IF gv_filename_d_arch IS NOT INITIAL.
* File Archived
    WRITE: / text-x28, 50(1) c_colon, 52 gv_filename_d_arch.
  ENDIF.
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
  ENDIF.
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
ENDFORM.                    " F_TOP_OF_PAGE1
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_BUYGRP
*&---------------------------------------------------------------------*
* Defect 1025: Check for Buying Group. If no Buying Group is passed
* Set Record as Error record
*----------------------------------------------------------------------*
FORM f_check_buygrp  USING    fp_text_038
                              fp_wa_901_zzkvgr1.

  IF fp_wa_901_zzkvgr1 IS INITIAL.
    CLEAR wa_report.
    wa_report-msgtyp = c_error.
    wa_report-msgtxt = fp_text_038.
    wa_report-key    = gv_mkey.
    APPEND wa_report TO i_report.
    CLEAR wa_report.
    gv_error = gv_error + 1.
    gv_skip  = gv_skip + 1.
    APPEND  wa_leg_tab TO i_leg_tab_err.
    gv_return1 = c_selected.
  ENDIF.

ENDFORM.                    " F_CHECK_BUYGRP
*&---------------------------------------------------------------------*
*&      Form  F_VALID_BUYGRP
*&---------------------------------------------------------------------*
* Defect 1177: Check for valid Buying Group in table TVV1.
*-----------------------------*----------------------------------------*
FORM f_valid_buygrp  USING    fp_text_039
                              fp_wa_zzkvgr1.

  FIELD-SYMBOLS : <lfs_tvv1> TYPE ty_tvv1.

  READ TABLE i_tvv1 ASSIGNING <lfs_tvv1> WITH KEY kvgr1 = fp_wa_zzkvgr1 BINARY SEARCH.
  IF sy-subrc <> 0.
    CLEAR wa_report.
    wa_report-msgtyp = c_error.
    CONCATENATE fp_text_039 fp_wa_zzkvgr1 INTO
    wa_report-msgtxt.
    wa_report-key    = gv_mkey.
    APPEND wa_report TO i_report.
    CLEAR wa_report.
    gv_error = gv_error + 1.
    gv_skip  = gv_skip + 1.
    APPEND  wa_leg_tab TO i_leg_tab_err.
    gv_return1 = c_selected.
  ENDIF.
ENDFORM.                    " F_VALID_BUYGRP
**&---------------------------------------------------------------------*
**&      Form  F_READ_RECORD_A911
**&---------------------------------------------------------------------*
**    populate internal table i_leg_tab for fields required for
**    condition table A911
**----------------------------------------------------------------------*
*FORM f_read_record_a911 .
*
*  DATA : lv_kbetr(16) TYPE c.
*  DATA : lv_konwa(5) TYPE c.
*  DATA : lv_kpein(5) TYPE c.
*  DATA : lv_kmein(3) TYPE c.
*
*  LOOP AT i_string INTO wa_string.
**skip header record
*    IF sy-tabix > 1.
*      CLEAR: gv_datab, gv_datbi, lv_kbetr.
*      SPLIT  wa_string-string AT c_tab INTO
*
*             wa_911-kappl
*             wa_911-kschl
*             wa_911-vkorg
*             wa_911-vtweg
*             wa_911-kunnr
*             wa_911-matnr
*
*             gv_datab
*             gv_datbi
*
*             lv_kbetr
*             lv_konwa
*             lv_kpein
*             lv_kmein
*** START OF CR700 changed by nnm
*             wa_911-ltx01. " Work area for Long text line
*** END OF CR 700
*
*      wa_911-kbetr = lv_kbetr.
*      wa_911-konwa = lv_konwa.
*      wa_911-kpein = lv_kpein.
*      wa_911-kmein = lv_kmein.
*
**convert from date from MM.DD.YYYY to YYYYMM DD
*      PERFORM f_date_convert USING gv_datab
*                             CHANGING wa_911-datab.
**Check valid date
*      PERFORM f_check_date   USING text-024 wa_911-datab.
**                             CHANGING gv_return1.
**Error skip record
*      IF gv_return1 = c_selected.
*        CONTINUE.
*      ENDIF.
*
**convert to date from MM.DD.YYYY to YYYYMM DD
*      PERFORM f_date_convert USING gv_datbi
*                             CHANGING wa_911-datbi.
**Check valid date
*      PERFORM f_check_date   USING text-025 wa_911-datbi.
**                             CHANGING gv_return1.
*      IF gv_return1 = c_selected.
**Error skip record
*        CONTINUE.
*      ENDIF.
*
**populate material mapping table
*      PERFORM f_legacy_material USING wa_911-matnr.
**convert customer to ECC format
*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          input  = wa_911-kunnr
*        IMPORTING
*          output = wa_911-kunnr.
*      MOVE-CORRESPONDING wa_911 TO wa_leg_tab.
*      APPEND wa_leg_tab TO i_leg_tab.
*    ENDIF.
*  ENDLOOP.
*ENDFORM.                    " F_READ_RECORD_A911
*&---------------------------------------------------------------------*
*&      Form  F_CONDITION_RECORD
*&---------------------------------------------------------------------*
*       Save Internal Comments in Condition Record
*----------------------------------------------------------------------*
*      -->FP_KNUMH            Condition Record No
*      -->FP_WA_LEG_TAB_LTX01 Value for Internal Comments Text
*----------------------------------------------------------------------*
FORM f_condition_record  USING    fp_leg_tab TYPE ty_t_leg_tab
                         CHANGING fp_i_konp TYPE ty_t_konp.

*&&-- Declaration of Local variables
  DATA: lwa_komv   TYPE komv," Work area for condition record
        lwa_header TYPE thead, " Header workarea
        lwa_tline  TYPE tline, " Long Text
        li_tline   TYPE STANDARD TABLE OF tline, " Long text

        lwa_leg_tab TYPE ty_leg_tab,  "Workarea for File data
        lwa_konp TYPE ty_konp. "Workarea for KONP

*&&-- Declaration of Local Constants
  CONSTANTS: lc_condition TYPE tdobject VALUE 'KONP',
                                 "Texts: Application Object
             lc_id        TYPE tdid VALUE '0001'." Text ID


***--> Begin of Insert for OTC_CDD_0008 Hanatization by APODDAR
      IF fp_leg_tab IS NOT INITIAL.
***<-- End of Insert for OTC_CDD_0008 Hanatization by APODDAR

*&&-- Get the KOPOS from KONP
  SELECT knumh  "Condition record number
         kopos  "Sequential number of the condition
    FROM konp
    INTO TABLE fp_i_konp
    FOR ALL ENTRIES IN fp_leg_tab
    WHERE knumh = fp_leg_tab-knumh.
  IF sy-subrc IS INITIAL.
    SORT fp_i_konp BY knumh.
  ENDIF.

***--> Begin of Insert for OTC_CDD_0008 Hanatization by APODDAR
      ENDIF.
***<-- End of Insert for OTC_CDD_0008 Hanatization by APODDAR

*&&-- Populate Header Data for SAVE_TEXT
**Populate text object
  CLEAR lwa_header.
  lwa_header-tdobject = lc_condition.
**Populate Text ID
  lwa_header-tdid = lc_id.
**populate text language
  lwa_header-tdspras = sy-langu.

*&&-- If Long text exists in the file for the row, Long text is
*     updated using SAVE_TEXT
  LOOP AT fp_i_konp INTO lwa_konp.
**Populate text name
    CONCATENATE lwa_konp-knumh lwa_konp-kopos INTO lwa_header-tdname.

*&&-- Populate Item Data for SAVE_TEXT
**Populate long text
    REFRESH: li_tline.
    READ TABLE fp_leg_tab INTO lwa_leg_tab
    WITH KEY knumh = lwa_konp-knumh BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lwa_tline-tdformat = '*'.
      lwa_tline-tdline = lwa_leg_tab-ltx01.
      APPEND lwa_tline TO li_tline.
      CLEAR lwa_tline.
    ENDIF.

    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        client          = sy-mandt
        header          = lwa_header
        insert          = c_selected
        savemode_direct = c_selected
*        owner_specified = space
*        local_cat       = space
      TABLES
        lines           = li_tline
      EXCEPTIONS
        id              = 1
        language        = 2
        name            = 3
        object          = 4
        OTHERS          = 5.

        WAIT UP TO 2 SECONDS.

    IF sy-subrc IS NOT INITIAL.
* NO action required
    ELSE.
      CALL FUNCTION 'COMMIT_TEXT'
*        EXPORTING
*          OBJECT                = '*'
*          NAME                  = '*'
*          ID                    = '*'
*          LANGUAGE              = '*'
*          SAVEMODE_DIRECT       = ' '
*          KEEP                  = ' '
*          LOCAL_CAT             = ' '
*        IMPORTING
*          COMMIT_COUNT          =
*        TABLES
*          T_OBJECT              =
*          T_NAME                =
*          T_ID                  =
*          T_LANGUAGE            =
                .

    ENDIF.
    CLEAR lwa_header-tdname.
    REFRESH li_tline.
  ENDLOOP.

ENDFORM.                    " F_CONDITION_RECORD
*&---------------------------------------------------------------------*
*&      Form  F_READ_RECORD
*&---------------------------------------------------------------------*
*       Read the Input File and populate final Internal table
*       No CHANGING parameter is used as it is copied from existing
*       so global Internal table is directly populated
*----------------------------------------------------------------------*
FORM f_read_record .

  DATA : lv_kbetr(16) TYPE c.
  DATA : lv_konwa(5) TYPE c.
  DATA : lv_kpein(5) TYPE c.
  DATA : lv_kmein(3) TYPE c.

  CONSTANTS: lc_comma TYPE char1 VALUE ',', "CR#380
             lc_dot TYPE char1 VALUE '.', "CR#380
**&& -- BOC : CR# 1289 : PROUT : 05-MAY-2014
             lc_e TYPE char1 VALUE 'E', " Error
             lc_date_99991231 TYPE datum VALUE '99991231' . " Date - 9999/12/31
**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014

  DATA: lv_len TYPE i,      "CR#380
        lv_dec TYPE char1,  "CR#380
**&& -- BOC : HPQC#1289 : SMUKHER : 19-JUN-2014
        lv_flag TYPE char1. " Flag
**&& -- EOC : HPQC#1289 : SMUKHER : 19-JUN-2014

*&&--Begin of CR#700
  DATA: lwa_file TYPE ty_file,  "Workarea for Input file
        lv_blank1 TYPE string,
        lv_blank2 TYPE string.


*&&-- Delete 1st 10 rows from i_string in order to support the excel download
*  DELETE i_string FROM 1 TO 10. " Commented out by SMUKHER on 04-Mar-15 .
   DELETE i_string FROM 1 TO 8.  " Added by SMUKHER on 04-Mar-15 .
*&&--End of CR#700

  LOOP AT i_string INTO wa_string.
*skip header record
*    IF sy-tabix > 1.
    CLEAR: gv_datab, gv_datbi, lv_kbetr.
    SPLIT  wa_string-string AT c_tab INTO
           lv_blank1
           lwa_file-kappl     "Application
           lwa_file-kschl     "Condition type
           lv_blank2
           lwa_file-vkorg     "Sales Organization
           lwa_file-vtweg     "Distribution Channel
*&&--Begin of CR#700
           lwa_file-field1    "Field1
           lwa_file-fld1_desc "Field1 Description
           lwa_file-field2    "Field2
           lwa_file-fld2_desc "Field2 Description
           lwa_file-city      "City
           lwa_file-buy_grp   "Byuing Group
           lwa_file-buy_desc  "Byuing Group Desc
           lwa_file-idn_code  "IDN Code
           lwa_file-idn_desc  "IDN Desc
           lwa_file-gpo_code  "GPO Code
           lwa_file-gpo_desc  "GPO Code Desc
           lwa_file-cust_cls  "Customer Class
           lwa_file-cust_desc "Customer Class Desc
*&&--End of CR#700
           gv_datab           "Valid To
           gv_datbi           "Valid From
           lv_kbetr           "Amount
           lv_konwa           "Rate Unit
           lv_kpein           "Pricing Unit
           lv_kmein           "UoM
*&&--Begin of CR#700
           lwa_file-sale_rep  "Sales Rep
           lwa_file-sale_desc "Sales Rep Desc

           lwa_file-ltx01     "Internal Comment
           lwa_file-txt_ind   "Internal Comment Indicator
           lwa_file-tabname   "Condition Record Table Name
           lwa_file-parameter.   "Action required   "SMUKHER
*&&--End of CR#700

**&& -- BOC : HPQC#1289 : SMUKHER : 19-JUN-2014
    IF lwa_file-parameter IS NOT INITIAL AND lv_flag IS INITIAL.
      lv_flag = abap_true.
**&& -- EOC : HPQC#1289 : SMUKHER : 19-JUN-2014

      IF sy-tabix = 1.  "For the 1st ITEM line in File
*      IF sy-tabix = 2.  "For the 1st ITEM line in File
        gv_table = lwa_file-tabname+1(3).   "Condition Record Table Name
        IF gv_table = c_004 OR gv_table = c_005 OR gv_table = c_901
          OR gv_table = c_902 OR gv_table = c_902 OR gv_table = c_903
          OR gv_table = c_904 OR gv_table = c_905 OR gv_table = c_911.
*&&-- No Action
        ELSE.
          MESSAGE i000  WITH 'Invalid Condition Record Table Name in File.'(035).
          LEAVE LIST-PROCESSING.
        ENDIF.
      ENDIF.

*&&-- BOC of CR#380
*&&-- Remove the thousand separator from amount(string) field
      lv_len = strlen( lv_kbetr ).
      lv_len = lv_len - 2.
      IF lv_len >= 1.                                       "CR#1289++
        lv_dec = lv_kbetr+lv_len(1).                        "CR#1289++
      ENDIF.                                                "CR#1289++
      IF lv_dec = lc_comma.
        REPLACE ALL OCCURRENCES OF lc_dot IN lv_kbetr WITH space.
      ELSEIF lv_dec = lc_dot.
        REPLACE ALL OCCURRENCES OF lc_comma IN lv_kbetr WITH space.
      ENDIF.
*&&-- EOC of CR#380

      lwa_file-kbetr = lv_kbetr.
      lwa_file-konwa = lv_konwa.
      lwa_file-kpein = lv_kpein.
      lwa_file-kmein = lv_kmein.

*&&--Begin of CR#700
*&&-- Populate the dynamic fields as per the Table name
      IF lwa_file-tabname+1(3) = c_005.
        lwa_file-kunnr = lwa_file-field1. "Customer No
        lwa_file-matnr = lwa_file-field2. "Material No
      ELSEIF lwa_file-tabname+1(3) = c_004.
        lwa_file-matnr = lwa_file-field1. "Material No
      ELSEIF lwa_file-tabname+1(3) = c_901.
        lwa_file-zzkvgr1 = lwa_file-field1. "Buying Group
        lwa_file-matnr = lwa_file-field2. "Material No
      ELSEIF lwa_file-tabname+1(3) = c_902.
        lwa_file-zzkvgr2 = lwa_file-field1. "IDN
        lwa_file-matnr = lwa_file-field2. "Material No
      ELSEIF lwa_file-tabname+1(3) = c_903.
        lwa_file-prod = lwa_file-field2. "Product Hiererchy
        lwa_file-kunnr = lwa_file-field1. "Customer No
      ELSEIF lwa_file-tabname+1(3) = c_904.
        lwa_file-zzkvgr1 = lwa_file-field1. "Buying Group
        lwa_file-prod = lwa_file-field2. "Product Hiererchy
      ELSEIF lwa_file-tabname+1(3) = c_905.
        lwa_file-zzkvgr2 = lwa_file-field1. "IDN
        lwa_file-prod = lwa_file-field2. "Product Hiererchy
      ELSEIF lwa_file-tabname+1(3) = c_911.
        lwa_file-kunnr = lwa_file-field1. "Customer No
        lwa_file-matnr = lwa_file-field2. "Material No
      ENDIF.
*&&--End of CR#700

*convert from date from MM.DD.YYYY to YYYYMM DD
      PERFORM f_date_convert USING gv_datab CHANGING lwa_file-datab.
*Check valid date
      PERFORM f_check_date   USING text-024 lwa_file-datab
**&& -- BOC : CR# 1289 : PROUT : 05-MAY-2014
                                            lwa_file.
**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
*Error skip record
      IF gv_return1 = c_selected.
        CONTINUE.
      ENDIF.

*convert to date from MM.DD.YYYY to YYYYMM DD
      PERFORM f_date_convert USING gv_datbi CHANGING lwa_file-datbi.
*Check valid date
**&& -- BOC : CR# 1289 : PROUT : 05-MAY-2014
      IF lwa_file-datbi <> lc_date_99991231.
        PERFORM f_check_date   USING text-025 lwa_file-datbi
                                              lwa_file.     "CR#1289++
      ENDIF.
**&& -- EOC : CR# 1289 : PROUT : 05-MAY-2014
      IF gv_return1 = c_selected.
*Error skip record
        CONTINUE.
      ENDIF.

      IF lwa_file-tabname+1(3) = c_005 OR lwa_file-tabname+1(3) = c_901
        OR lwa_file-tabname+1(3) = c_902 OR lwa_file-tabname+1(3) = c_004
        OR lwa_file-tabname+1(3) = c_911.
*populate material mapping table
        PERFORM f_legacy_material USING lwa_file-matnr.
      ENDIF.

      IF lwa_file-tabname+1(3) = c_005 OR lwa_file-tabname = c_903
         OR lwa_file-tabname+1(3) = c_911.
*convert customer to ECC format
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lwa_file-kunnr
          IMPORTING
            output = lwa_file-kunnr.
      ENDIF.

      IF lwa_file-tabname+1(3) = c_901 OR lwa_file-tabname+1(3) = c_904.
        PERFORM f_check_buygrp   USING text-038 lwa_file-zzkvgr1.
        IF gv_return1 = c_selected.
          CONTINUE.
        ENDIF.
        PERFORM f_valid_buygrp   USING text-039 lwa_file-zzkvgr1.
        IF gv_return1 = c_selected.
          CONTINUE.
        ENDIF.
      ENDIF.
*&&-- Add the data to final internal table
      MOVE-CORRESPONDING lwa_file TO wa_leg_tab.
      APPEND wa_leg_tab TO i_leg_tab.
      CLEAR: lwa_file,
             wa_leg_tab,
             lv_kbetr,
             lv_konwa,
             lv_kpein,
             lv_kmein,
***             gv_datab,
***             gv_datbi,
             lv_flag.
**&& -- BOC : HPQC#1289 : SMUKHER : 19-JUN-2014
    ELSE.
      IF lv_flag = space.
        MESSAGE i997 DISPLAY LIKE lc_e.
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.
**&& -- EOC : HPQC#1289 : SMUKHER : 19-JUN-2014
*    ENDIF.  "Check SY-TABIX > 1
  ENDLOOP.

ENDFORM.                    " F_READ_RECORD
*&---------------------------------------------------------------------*
*&      form F_BDC_DYNPRO
*&---------------------------------------------------------------------*
*       This is used for populating program name and screen number
*----------------------------------------------------------------------*
*      -->FP_V_PROGRAM        BDC Program Name
*      -->FP_V_DYNPRO         BDC Screen Dynpro No.
*      <--FP_I_BDCDATA        Filled up BDC Data
*----------------------------------------------------------------------*
FORM f_bdc_dynpro  USING fp_v_program  TYPE bdc_prog
                         fp_v_dynpro   TYPE bdc_dynr
                CHANGING fp_i_bdcdata  TYPE ty_t_bdcdata.
* Local data declaration
  DATA: lwa_bdcdata TYPE bdcdata.
* Filling the BDC Data table for Program name, screen no and dyn begin
  CLEAR lwa_bdcdata.
  lwa_bdcdata-program  = fp_v_program.
  lwa_bdcdata-dynpro   = fp_v_dynpro.
  lwa_bdcdata-dynbegin = abap_true.
  APPEND lwa_bdcdata TO fp_i_bdcdata.
ENDFORM.                    " F_BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      form F_BDC_FIELD
*&---------------------------------------------------------------------*
*       This subroutine is used to populate field name and values
*----------------------------------------------------------------------*
*      -->FP_V_FNAM      Field Name
*      -->FP_V_FVAL      Field Value
*      <--FP_I_BDCDATA   Populated BDC Data
*----------------------------------------------------------------------*
FORM f_bdc_field  USING fp_v_fnam    TYPE any
                        fp_v_fval    TYPE any
               CHANGING fp_i_bdcdata TYPE bdcdata_tab.

* Local data declaration
  DATA: lwa_bdcdata TYPE ty_bdcdata.

* Filling the BDC Data table for Field value and Field name
  IF NOT fp_v_fval IS INITIAL.
    CLEAR lwa_bdcdata.
    lwa_bdcdata-fnam = fp_v_fnam.
    lwa_bdcdata-fval = fp_v_fval.
    APPEND lwa_bdcdata TO fp_i_bdcdata.
  ENDIF.

ENDFORM.                    "f_bdc_field
*&---------------------------------------------------------------------*
*&      Form  F_BDC_CREATE
*&---------------------------------------------------------------------*
*       BDC Recording for Update
*----------------------------------------------------------------------*
*      -->FP_LFS_LEG_TAB  Work area type ty_leg_tab
*      <--FP_LI_BDCDATA   Internal table
*----------------------------------------------------------------------*
FORM f_bdc_create  USING    fp_lfs_leg_tab TYPE ty_leg_tab
                            fp_access_seq  TYPE char2
                   CHANGING fp_li_bdcdata TYPE bdcdata_tab.

  DATA: lv_date_from TYPE datum,  " From date
        lv_date_to TYPE datum,  "  To Date
        lv_amount   TYPE char15,  " Amount condense
        lv_field    TYPE char20.  "Dynamic BDC field

  lv_date_from = fp_lfs_leg_tab-datab.
  lv_date_to = fp_lfs_leg_tab-datbi.

  CLEAR: fp_lfs_leg_tab-datab,
         fp_lfs_leg_tab-datbi.

**&& -- The date is converted from yyyymmdd to dd.mm.yyyy
  WRITE lv_date_from TO fp_lfs_leg_tab-datab.
  WRITE lv_date_to TO fp_lfs_leg_tab-datbi.
**&& -- The Amount is condensed to remove the leading spaces.
  lv_amount = fp_lfs_leg_tab-kbetr.
  CONDENSE lv_amount.

  PERFORM f_bdc_dynpro      USING'SAPMV13A' '0100'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-KSCHL'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-KSCHL'
                                fp_lfs_leg_tab-kschl
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'
                            CHANGING fp_li_bdcdata.

  CONCATENATE 'RV130-SELKZ('fp_access_seq')' INTO lv_field.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                lv_field
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING lv_field
                                'X'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'RV13A005' '1000'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'SEL_DATE'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ONLI'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F001'
                                fp_lfs_leg_tab-vkorg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F002'
                                fp_lfs_leg_tab-vtweg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F003'
                                fp_lfs_leg_tab-kunnr
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F004-LOW'
                                fp_lfs_leg_tab-matnr
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'SEL_DATE'
                                fp_lfs_leg_tab-datab
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1005'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-DATBI(01)'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'KONP-KBETR(01)'
                              lv_amount
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-DATAB(01)'
                              fp_lfs_leg_tab-datab
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-DATBI(01)'
                              fp_lfs_leg_tab-datbi
                            CHANGING fp_li_bdcdata.


ENDFORM.                    " F_BDC_CREATE
*&---------------------------------------------------------------------*
*&      Form  F_BDC_TRANSACTION
*&---------------------------------------------------------------------*
*       subroutine for BDC CALL TRANSACTION
*----------------------------------------------------------------------*
*      -->FP_TCODE         sytcode                                     *
*      -->FP_I_BDCDATA     internal table for BDC data                 *
*      -->FP_BDCMSG        internal table for BDC messages             *
*----------------------------------------------------------------------*
FORM f_bdc_transaction  USING fp_tcode TYPE sytcode
                               fp_i_bdcdata TYPE bdcdata_tab
                        CHANGING fp_bdcmsg TYPE ty_t_bdcmsgcoll.

  DATA: lv_bdc_mode TYPE char1, " BDC mode
        lv_update TYPE char1.

  CONSTANTS: lc_bdc_mode TYPE char1 VALUE 'N',
             lc_update TYPE char1 VALUE 'S'.   " BDC Mode

  lv_bdc_mode = lc_bdc_mode.
  lv_update = lc_update.
  CALL TRANSACTION fp_tcode USING fp_i_bdcdata
                            MODE lv_bdc_mode
                            UPDATE lv_update
                            MESSAGES INTO fp_bdcmsg.

ENDFORM.                    " F_CALL_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  F_BDC_CREATE1
*&---------------------------------------------------------------------*
*       BDC Recording for Delete
*----------------------------------------------------------------------*
*      -->FP_LFS_LEG_TAB  Work Area type ty_leg_tab
*      <--FP_LI_BDCDATA   Internal Table
*----------------------------------------------------------------------*
FORM f_bdc_create1  USING    fp_lfs_leg_tab TYPE ty_leg_tab
                             fp_access_seq  TYPE char2
                    CHANGING fp_li_bdcdata TYPE bdcdata_tab.

  DATA: lv_date_from TYPE datum,  " From Date
        lv_date_to TYPE datum,  " To Date
        lv_field    TYPE char20.  "Dynamic BDC field

  lv_date_from = fp_lfs_leg_tab-datab.
  lv_date_to = fp_lfs_leg_tab-datbi.

  CLEAR: fp_lfs_leg_tab-datab,
         fp_lfs_leg_tab-datbi.
* The Date is converted from yyyymmdd to dd.mm.yyyy
  WRITE lv_date_from TO fp_lfs_leg_tab-datab.
  WRITE lv_date_to TO fp_lfs_leg_tab-datbi.

  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '0100'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-KSCHL'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-KSCHL'
                                fp_lfs_leg_tab-kschl
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'
                          CHANGING fp_li_bdcdata.

  CONCATENATE 'RV130-SELKZ('fp_access_seq')' INTO lv_field.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                lv_field
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING lv_field
                                'X'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'RV13A005' '1000'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'SEL_DATE'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ONLI'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F001'
                                fp_lfs_leg_tab-vkorg
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F002'
                                fp_lfs_leg_tab-vtweg
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F003'
                                fp_lfs_leg_tab-kunnr
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F004-LOW'
                                fp_lfs_leg_tab-matnr
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'SEL_DATE'
                                fp_lfs_leg_tab-datab
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1005'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONP-KBETR(01)'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=PSTF'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '0303'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONM-KSTBM(01)'
                                CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'
                                CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-DATAB'
                                fp_lfs_leg_tab-datab
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-DATBI'
                                fp_lfs_leg_tab-datbi
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1005'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMG-MATNR(01)'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ENTF'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                'X'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1005'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMG-MATNR(01)'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'
                          CHANGING fp_li_bdcdata.

ENDFORM.                   " F_BDC_CREATE1
*&---------------------------------------------------------------------*
*&      Form  F_ZOTC_RV_CONDITION_COPY
*&---------------------------------------------------------------------*
*       subroutine to call the Function Module ZOTC_RV_CONDITION_COPY
*----------------------------------------------------------------------*
*      -->FP_LWA_KOMV       Structure for KOMV
*      -->FP_WA_LEG_TAB     Final structure
*      -->FP_LV_DATE_FROM   From Date
*      -->FP_LV_DATE_TO     To Date
*      -->FP_LWA_KOMG       Structure for KOMG
*      <--FP_LWA_KOMK       Structure for KOMK
*      <--FP_LWA_KOMP       Structure for KOMP
*      <--FP_LV_NEW_RECORD  New Record
*      <--FP_LV_KNUMH       Condition record Number
*      <--FP_LI_KOMV        Internal Table for KOMV
*----------------------------------------------------------------------*
FORM f_zotc_rv_condition_copy  USING    fp_lwa_komv TYPE komv
                                        fp_wa_leg_tab TYPE ty_leg_tab
                                        lv_date_from TYPE datum
                                        lv_date_to TYPE datum
                                        fp_lwa_komg TYPE komg
                                        fp_lv_index TYPE syindex
*                                        fp_li_leg_tab TYPE ty_t_leg_tab
                               CHANGING fp_li_leg_tab TYPE ty_t_leg_tab
                                        fp_lwa_komk TYPE komk
                                        fp_lwa_komp TYPE komp
                                        fp_lv_new_record TYPE char1
                                        fp_lv_knumh TYPE knumh
                                        fp_li_komv TYPE  ty_t_komv.

  FIELD-SYMBOLS: <lfs_leg_tab> TYPE ty_leg_tab. " field symbols
*  DATA:lv_index TYPE syindex. " Index

**&& -- Call the Z- function Module to create new record in the
**      Condition Table.
  CALL FUNCTION 'ZOTC_RV_CONDITION_COPY'
    EXPORTING
      application                 = fp_lwa_komv-kappl
      condition_table             = gv_table
      condition_type              = fp_wa_leg_tab-kschl
      date_from                   = lv_date_from
      date_to                     = lv_date_to
      enqueue                     = c_selected
      i_komk                      = fp_lwa_komk
      i_komp                      = fp_lwa_komp
      key_fields                  = fp_lwa_komg
      maintain_mode               = c_mode_a
      no_authority_check          = c_selected
      keep_old_records            = c_selected
      overlap_confirmed           = c_selected
      no_db_update                = space
    IMPORTING
      e_komk                      = fp_lwa_komk
      e_komp                      = fp_lwa_komp
      new_record                  = fp_lv_new_record
      e_knumh                     = fp_lv_knumh      "CR#700 ++
    TABLES
      copy_records                = fp_li_komv
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
*-- Begin Of CR#700
*&&-- Update the Condition Record No in Int Table
    READ TABLE fp_li_leg_tab ASSIGNING <lfs_leg_tab>
                          INDEX fp_lv_index.
    IF sy-subrc IS INITIAL.
      <lfs_leg_tab>-knumh = fp_lv_knumh.
    ENDIF.
*-- End Of CR#700
**&& -- BOC : CR#1289 : PROUT : 05-MAY-14
    PERFORM f_log_msg1.
**&& -- BOC : CR#1289 : PROUT : 05-MAY-14
  ELSE.
    gv_error = gv_error + 1.
    APPEND  wa_leg_tab TO i_leg_tab_err.
    PERFORM f_log_msg1.
  ENDIF.
ENDFORM.                    " F_ZOTC_RV_CONDITION_COPY
*&---------------------------------------------------------------------*
*&      Form  F_BDC_CREATE2
*&---------------------------------------------------------------------*
*       BDC Recording for Update
*----------------------------------------------------------------------*
*      -->FP_WA_LEG_TAB  Work Area type ty_leg_tab
*      <--FP_LI_BDCDATA  Internal table
*----------------------------------------------------------------------*
FORM f_bdc_create2  USING   fp_lfs_leg_tab TYPE ty_leg_tab
                            fp_access_seq  TYPE char2
                   CHANGING fp_li_bdcdata TYPE bdcdata_tab.

  DATA: lv_date_from TYPE datum,  " From Date
        lv_date_to TYPE datum,  " To Date
        lv_amount   TYPE char15,  " Amount
        lv_field    TYPE char20.  "Dynamic BDC field

  lv_date_from = fp_lfs_leg_tab-datab.
  lv_date_to = fp_lfs_leg_tab-datbi.

  CLEAR: fp_lfs_leg_tab-datab,
         fp_lfs_leg_tab-datbi.
**&& -- The Date is converted from yyyymmdd to dd.mm.yyyy
  WRITE lv_date_from TO fp_lfs_leg_tab-datab.
  WRITE lv_date_to TO fp_lfs_leg_tab-datbi.
**&& -- The Amount is condensed to remove the leading spaces.
  lv_amount = fp_lfs_leg_tab-kbetr.
  CONDENSE lv_amount.

  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '0100'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-KSCHL'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-KSCHL'
                                fp_lfs_leg_tab-kschl
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'
                          CHANGING fp_li_bdcdata.

  CONCATENATE 'RV130-SELKZ('fp_access_seq')' INTO lv_field.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                lv_field
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING lv_field
                                'X'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'RV13A004' '1000'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'F003-LOW'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ONLI'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F001'
                                fp_lfs_leg_tab-vkorg
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F002'
                                fp_lfs_leg_tab-vtweg
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F003-LOW'
                                fp_lfs_leg_tab-matnr
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'SEL_DATE'
                                fp_lfs_leg_tab-datab
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1004'
                           CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONP-KBETR(01)'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'KONP-KBETR(01)'
                              lv_amount
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-DATAB(01)'
                              fp_lfs_leg_tab-datab
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-DATBI(01)'
                              fp_lfs_leg_tab-datbi
                            CHANGING fp_li_bdcdata.

ENDFORM.                    " F_BDC_CREATE2
*&---------------------------------------------------------------------*
*&      Form  F_BDC_CREATE3
*&---------------------------------------------------------------------*
*       BDC Recording for Delete
*----------------------------------------------------------------------*
*      -->FP_WA_LEG_TAB  Work Area type ty_leg_tab
*      <--FP_LI_BDCDATA  Internal table
*----------------------------------------------------------------------*
FORM f_bdc_create3  USING    fp_lfs_leg_tab TYPE ty_leg_tab
                             fp_access_seq  TYPE char2
                    CHANGING fp_li_bdcdata TYPE bdcdata_tab.

  DATA: lv_date_from TYPE datum,  " From Date
        lv_date_to TYPE datum,  " To Date
        lv_field    TYPE char20.  "Dynamic BDC field

  lv_date_from = fp_lfs_leg_tab-datab.
  lv_date_to = fp_lfs_leg_tab-datbi.

  CLEAR: fp_lfs_leg_tab-datab,
         fp_lfs_leg_tab-datbi.
**&& -- The Date is converted yyyymmdd to dd.mm.yyyy
  WRITE lv_date_from TO fp_lfs_leg_tab-datab.
  WRITE lv_date_to TO fp_lfs_leg_tab-datbi.

  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '0100'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-KSCHL'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-KSCHL'
                                fp_lfs_leg_tab-kschl
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'
                          CHANGING fp_li_bdcdata.

  CONCATENATE 'RV130-SELKZ('fp_access_seq')' INTO lv_field.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                lv_field
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING lv_field
                                'X'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'RV13A004' '1000'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'F003-LOW'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ONLI'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F001'
                                fp_lfs_leg_tab-vkorg
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F002'
                                fp_lfs_leg_tab-vtweg
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F003-LOW'
                                fp_lfs_leg_tab-matnr
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'SEL_DATE'
                          fp_lfs_leg_tab-datab
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1004'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMG-MATNR(01)'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ENTF'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                'X'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1004'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMG-MATNR(01)'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'
                          CHANGING fp_li_bdcdata.

ENDFORM.                    " F_BDC_CREATE3
*&---------------------------------------------------------------------*
*&      Form  F_BDC_CREATE4
*&---------------------------------------------------------------------*
*       BDC Recording for Update
*----------------------------------------------------------------------*
*      -->FP_WA_LEG_TAB  Work area for type ty_leg_tab
*      <--FP_LI_BDCDATA  Internal table
*----------------------------------------------------------------------*
FORM f_bdc_create4  USING    fp_lfs_leg_tab TYPE ty_leg_tab
                             fp_access_seq  TYPE char2
                   CHANGING fp_li_bdcdata TYPE bdcdata_tab.

  DATA: lv_date_from TYPE datum,  " From Date
        lv_date_to TYPE datum,  " To Date
        lv_amount TYPE char15.  " Amount condense

  DATA: lv_field    TYPE char20.  "Dynamic BDC field

  lv_date_from = fp_lfs_leg_tab-datab.
  lv_date_to = fp_lfs_leg_tab-datbi.

  CLEAR: fp_lfs_leg_tab-datab,
         fp_lfs_leg_tab-datbi.
**&& -- The Date isd converted from yyyymmdd to dd.mm.yyyy
  WRITE lv_date_from TO fp_lfs_leg_tab-datab.
  WRITE lv_date_to TO fp_lfs_leg_tab-datbi.
**&& -- The Amount is condensed to remove the leading spaces.
  lv_amount = fp_lfs_leg_tab-kbetr.
  CONDENSE lv_amount.

  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '0100'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-KSCHL'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-KSCHL'
                                fp_lfs_leg_tab-kschl
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'
                            CHANGING fp_li_bdcdata.

  CONCATENATE 'RV130-SELKZ('fp_access_seq')' INTO lv_field.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                lv_field
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING lv_field
                              'X'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'RV13A911' '1000'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'F004-LOW '
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ONLI'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F001'
                                fp_lfs_leg_tab-vkorg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F002'
                                fp_lfs_leg_tab-vtweg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F003'
                                fp_lfs_leg_tab-kunnr
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F004-LOW'
                                fp_lfs_leg_tab-matnr
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'SEL_DATE'
                                fp_lfs_leg_tab-datab
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1911'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-DATBI(01)'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'KONP-KBETR(01)'
                                lv_amount
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-DATAB(01)'
                               fp_lfs_leg_tab-datab
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-DATBI(01)'
                               fp_lfs_leg_tab-datbi
                            CHANGING fp_li_bdcdata.

ENDFORM.                    " F_BDC_CREATE4
*&---------------------------------------------------------------------*
*&      Form  F_BDC_CREATE5
*&---------------------------------------------------------------------*
*       BDC Recording for Delete
*----------------------------------------------------------------------*
*      -->FP_WA_LEG_TAB  Work Area type ty_leg_tab
*      <--FP_LI_BDCDATA  Internal Table
*----------------------------------------------------------------------*
FORM f_bdc_create5  USING    fp_lfs_leg_tab TYPE ty_leg_tab
                             fp_access_seq  TYPE char2
                    CHANGING fp_li_bdcdata TYPE bdcdata_tab.

  DATA: lv_date_from TYPE datum,  " From Date
          lv_date_to TYPE datum.  " To Date

  DATA: lv_field    TYPE char20.  "Dynamic BDC field

  lv_date_from = fp_lfs_leg_tab-datab.
  lv_date_to = fp_lfs_leg_tab-datbi.

  CLEAR: fp_lfs_leg_tab-datab,
         fp_lfs_leg_tab-datbi.
**&& -- The Date is converted from yyyymmdd to dd.mm.yyyy
  WRITE lv_date_from TO fp_lfs_leg_tab-datab.
  WRITE lv_date_to TO fp_lfs_leg_tab-datbi.

  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '0100'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-KSCHL'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-KSCHL'
                                fp_lfs_leg_tab-kschl
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'
                            CHANGING fp_li_bdcdata.

  CONCATENATE 'RV130-SELKZ('fp_access_seq')' INTO lv_field.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                lv_field
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING
                                'RV130-SELKZ(01)'
                                ''
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING
                                lv_field
                                'X'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'RV13A911' '1000'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'SEL_DATE'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ONLI'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F001'
                                fp_lfs_leg_tab-vkorg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F002'
                                fp_lfs_leg_tab-vtweg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F003'
                                fp_lfs_leg_tab-kunnr
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F004-LOW'
                                fp_lfs_leg_tab-matnr
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'SEL_DATE'
                           fp_lfs_leg_tab-datab
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1911'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMG-MATNR(01)'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ENTF'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                'X'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1911'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMG-MATNR(01)'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'
                            CHANGING fp_li_bdcdata.
ENDFORM.                    " F_BDC_CREATE5
*&---------------------------------------------------------------------*
*&      Form  F_BDC_CREATE6
*&---------------------------------------------------------------------*
*       BDC Recording for Update
*----------------------------------------------------------------------*
*      -->FP_WA_LEG_TAB  Work Area type ty_leg_tab
*      <--FP_LI_BDCDATA  Internal Table
*----------------------------------------------------------------------*
FORM f_bdc_create6  USING    fp_lfs_leg_tab TYPE ty_leg_tab
                             fp_access_seq  TYPE char2
                   CHANGING fp_li_bdcdata TYPE bdcdata_tab.

  DATA: lv_date_from TYPE datum,  " From Date
        lv_date_to TYPE datum,  " To Date
        lv_amount TYPE char15. "Amount

  DATA: lv_field    TYPE char20.  "Dynamic BDC field

  lv_date_from = fp_lfs_leg_tab-datab.
  lv_date_to = fp_lfs_leg_tab-datbi.

  CLEAR: fp_lfs_leg_tab-datab,
         fp_lfs_leg_tab-datbi.
**&& -- The Date is converted from yyyymmdd to dd.mm.yyyy
  WRITE lv_date_from TO fp_lfs_leg_tab-datab.
  WRITE lv_date_to TO fp_lfs_leg_tab-datbi.
**&& -- The Amount  is condensed to remove the leading spaces.
  lv_amount = fp_lfs_leg_tab-kbetr.
  CONDENSE lv_amount.

  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '0100'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-KSCHL'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-KSCHL'
                                fp_lfs_leg_tab-kschl
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'
                            CHANGING fp_li_bdcdata.

  CONCATENATE 'RV130-SELKZ('fp_access_seq')' INTO lv_field.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                lv_field
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''
                                CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING lv_field
                                'X'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'RV13A903' '1000'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'F003'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ONLI'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F001'
                                fp_lfs_leg_tab-vkorg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F002'
                                fp_lfs_leg_tab-vtweg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F003'
                                fp_lfs_leg_tab-kunnr
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F004-LOW'
                               fp_lfs_leg_tab-prod
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'SEL_DATE'
                                fp_lfs_leg_tab-datab
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1903'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-DATBI(01)'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'KONP-KBETR(01)'
                                lv_amount
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-DATAB(01)'
                                fp_lfs_leg_tab-datab
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-DATBI(01)'
                                fp_lfs_leg_tab-datbi
                            CHANGING fp_li_bdcdata.
ENDFORM.                    " F_BDC_CREATE6
*&---------------------------------------------------------------------*
*&      Form  F_BDC_CREATE7
*&---------------------------------------------------------------------*
*       BDC Recording for Delete
*----------------------------------------------------------------------*
*      -->FP_WA_LEG_TAB  Work Area type ty_leg_tab
*      <--FP_LI_BDCDATA  Internal Table
*----------------------------------------------------------------------*
FORM f_bdc_create7  USING    fp_lfs_leg_tab TYPE ty_leg_tab
                             fp_access_seq  TYPE char2
                    CHANGING fp_li_bdcdata TYPE bdcdata_tab.

  DATA: lv_date_from TYPE datum,  " From Date
          lv_date_to TYPE datum.  " To Date

  DATA: lv_field    TYPE char20.  "Dynamic BDC field

  lv_date_from = fp_lfs_leg_tab-datab.
  lv_date_to = fp_lfs_leg_tab-datbi.

  CLEAR: fp_lfs_leg_tab-datab,
         fp_lfs_leg_tab-datbi.
**&& -- The Date is converted from yyyymmdd to dd.mm.yyyy
  WRITE lv_date_from TO fp_lfs_leg_tab-datab.
  WRITE lv_date_to TO fp_lfs_leg_tab-datbi.

  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '0100'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-KSCHL'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-KSCHL'
                                fp_lfs_leg_tab-kschl
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'
                          CHANGING fp_li_bdcdata.

  CONCATENATE 'RV130-SELKZ('fp_access_seq')' INTO lv_field.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                lv_field
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING lv_field
                                'X'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'RV13A903' '1000'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'SEL_DATE'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ONLI'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F001'
                                fp_lfs_leg_tab-vkorg
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F002'
                                fp_lfs_leg_tab-vtweg
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F003'
                                fp_lfs_leg_tab-kunnr
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F004-LOW'
                                fp_lfs_leg_tab-prod
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'SEL_DATE'
                                fp_lfs_leg_tab-datab
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1903'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMG-ZZPRODH4(01)'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ENTF'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(05)'
                                'X'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1903'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMG-ZZPRODH4(01)'
                          CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'
                          CHANGING fp_li_bdcdata.

ENDFORM.                    " F_BDC_CREATE7
*&---------------------------------------------------------------------*
*&      Form  F_BDC_CREATE8
*&---------------------------------------------------------------------*
*       BDC Recording for Update
*----------------------------------------------------------------------*
*      -->FP_WA_LEG_TAB  Work Area type ty_leg_tab
*      <--FP_LI_BDCDATA  Internal Table
*----------------------------------------------------------------------*
FORM f_bdc_create8  USING    fp_lfs_leg_tab TYPE ty_leg_tab
                             fp_access_seq  TYPE char2
                   CHANGING fp_li_bdcdata TYPE bdcdata_tab.

  DATA: lv_date_from TYPE datum,  " From Date
        lv_date_to TYPE datum,  " To Date
        lv_amount TYPE char15. " Amount

  DATA: lv_field    TYPE char20.  "Dynamic BDC field

  lv_date_from = fp_lfs_leg_tab-datab.
  lv_date_to = fp_lfs_leg_tab-datbi.

  CLEAR: fp_lfs_leg_tab-datab,
         fp_lfs_leg_tab-datbi.
**&& -- The Date is converted from yyyymmdd to dd.mm.yyyy
  WRITE lv_date_from TO fp_lfs_leg_tab-datab.
  WRITE lv_date_to TO fp_lfs_leg_tab-datbi.
**&& -- The Amount is condensed to remove the leading spaces.
  lv_amount = fp_lfs_leg_tab-kbetr.
  CONDENSE lv_amount.

  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '0100'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-KSCHL'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-KSCHL'
                                fp_lfs_leg_tab-kschl
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'
                            CHANGING fp_li_bdcdata.

  CONCATENATE 'RV130-SELKZ('fp_access_seq')' INTO lv_field.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                lv_field
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING lv_field
                                'X'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'RV13A901' '1000'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'F004-LOW'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ONLI'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F001'
                                fp_lfs_leg_tab-vkorg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F002'
                                fp_lfs_leg_tab-vtweg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F003'
                                fp_lfs_leg_tab-zzkvgr1
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F004-LOW'
                                fp_lfs_leg_tab-matnr
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'SEL_DATE'
                                fp_lfs_leg_tab-datab
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1901'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-DATBI(01)'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'KONP-KBETR(01)'
                                lv_amount
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-DATAB(01)'
                                fp_lfs_leg_tab-datab
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-DATBI(01)'
                                fp_lfs_leg_tab-datbi
                            CHANGING fp_li_bdcdata.
ENDFORM.                    " F_BDC_CREATE8
*&---------------------------------------------------------------------*
*&      Form  F_BDC_CREATE9
*&---------------------------------------------------------------------*
*       BDC Recording for Delete
*----------------------------------------------------------------------*
*      -->FP_WA_LEG_TAB  Work Area type ty_leg_tab
*      <--FP_LI_BDCDATA  Internal Table
*----------------------------------------------------------------------*
FORM f_bdc_create9  USING    fp_lfs_leg_tab TYPE ty_leg_tab
                             fp_access_seq  TYPE char2
                    CHANGING fp_li_bdcdata TYPE bdcdata_tab.

  DATA: lv_date_from TYPE datum,  " From Date
        lv_date_to TYPE datum.  " To Date

  DATA: lv_field    TYPE char20.  "Dynamic BDC field

  lv_date_from = fp_lfs_leg_tab-datab.
  lv_date_to = fp_lfs_leg_tab-datbi.

  CLEAR: fp_lfs_leg_tab-datab,
         fp_lfs_leg_tab-datbi.
**&& -- The Date is converted from yyyymmdd to dd.mm.yyyy
  WRITE lv_date_from TO fp_lfs_leg_tab-datab.
  WRITE lv_date_to TO fp_lfs_leg_tab-datbi.

  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '0100'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-KSCHL'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-KSCHL'
                                fp_lfs_leg_tab-kschl
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'
                            CHANGING fp_li_bdcdata.

  CONCATENATE 'RV130-SELKZ('fp_access_seq')' INTO lv_field.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                lv_field
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING lv_field
                                'X'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'RV13A901' '1000'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'SEL_DATE'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ONLI'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F001'
                                fp_lfs_leg_tab-vkorg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F002'
                                fp_lfs_leg_tab-vtweg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F003'
                                fp_lfs_leg_tab-zzkvgr1
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F004-LOW'
                                fp_lfs_leg_tab-matnr
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'SEL_DATE'
                               fp_lfs_leg_tab-datab
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1901'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMG-MATNR(01)'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ENTF'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                'X'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1901'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMG-MATNR(01)'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'
                            CHANGING fp_li_bdcdata.

ENDFORM.                    " F_BDC_CREATE9
*&---------------------------------------------------------------------*
*&      Form  F_BDC_CREATE10
*&---------------------------------------------------------------------*
*       BDC Recording for Update
*----------------------------------------------------------------------*
*      -->FP_WA_LEG_TAB  Work Area type ty_leg_tab
*      <--FP_LI_BDCDATA  Internal Table
*----------------------------------------------------------------------*
FORM f_bdc_create10  USING    fp_lfs_leg_tab TYPE ty_leg_tab
                              fp_access_seq  TYPE char2
                   CHANGING fp_li_bdcdata TYPE bdcdata_tab.

  DATA: lv_date_from TYPE datum,  " From Date,
        lv_date_to TYPE datum,  " To Date
        lv_amount TYPE char15. " Amount

  DATA: lv_field    TYPE char20.  "Dynamic BDC field

  lv_date_from = fp_lfs_leg_tab-datab.
  lv_date_to = fp_lfs_leg_tab-datbi.

  CLEAR: fp_lfs_leg_tab-datab,
         fp_lfs_leg_tab-datbi.
**&& -- The Date is converted from yyyymmdd to dd.mm.yyyy
  WRITE lv_date_from TO fp_lfs_leg_tab-datab.
  WRITE lv_date_to TO fp_lfs_leg_tab-datbi.
**&& -- The Amount is condensed to remove the leading spaces.
  lv_amount = fp_lfs_leg_tab-kbetr.
  CONDENSE lv_amount.

  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '0100'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-KSCHL'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-KSCHL'
                                fp_lfs_leg_tab-kschl
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'
                            CHANGING fp_li_bdcdata.

  CONCATENATE 'RV130-SELKZ('fp_access_seq')' INTO lv_field.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                lv_field
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING lv_field
                                'X'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'RV13A902' '1000'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'SEL_DATE'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ONLI'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F001'
                                fp_lfs_leg_tab-vkorg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F002'
                                fp_lfs_leg_tab-vtweg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F003'
                                fp_lfs_leg_tab-zzkvgr2
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F004-LOW'
                                fp_lfs_leg_tab-matnr
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'SEL_DATE'
                                fp_lfs_leg_tab-datab
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1902'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-DATBI(01)'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'KONP-KBETR(01)'
                                lv_amount
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-DATAB(01)'
                                fp_lfs_leg_tab-datab
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-DATBI(01)'
                                fp_lfs_leg_tab-datbi
                            CHANGING fp_li_bdcdata.

ENDFORM.                    " F_BDC_CREATE10
*&---------------------------------------------------------------------*
*&      Form  F_BDC_CREATE11
*&---------------------------------------------------------------------*
*       BDC Recording for Delete
*----------------------------------------------------------------------*
*      -->FP_WA_LEG_TAB  Work Area type ty_leg_tab
*      <--FP_LI_BDCDATA  Internal Table
*----------------------------------------------------------------------*
FORM f_bdc_create11  USING    fp_lfs_leg_tab TYPE ty_leg_tab
                              fp_access_seq  TYPE char2
                    CHANGING fp_li_bdcdata TYPE bdcdata_tab.

  DATA: lv_date_from TYPE datum,  " From Date
        lv_date_to TYPE datum.  " To Date

  DATA: lv_field    TYPE char20.  "Dynamic BDC field

  lv_date_from = fp_lfs_leg_tab-datab.
  lv_date_to = fp_lfs_leg_tab-datbi.

  CLEAR: fp_lfs_leg_tab-datab,
         fp_lfs_leg_tab-datbi.
**&& -- The Date is converted from yyyymmdd to dd.mm.yyyy
  WRITE lv_date_from TO fp_lfs_leg_tab-datab.
  WRITE lv_date_to TO fp_lfs_leg_tab-datbi.

  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '0100'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-KSCHL'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-KSCHL'
                                fp_lfs_leg_tab-kschl
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'
                            CHANGING fp_li_bdcdata.

  CONCATENATE 'RV130-SELKZ('fp_access_seq')' INTO lv_field.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                lv_field
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING lv_field
                                'X'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'RV13A902' '1000'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'SEL_DATE'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ONLI'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F001'
                                fp_lfs_leg_tab-vkorg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F002'
                                fp_lfs_leg_tab-vtweg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F003'
                                fp_lfs_leg_tab-zzkvgr2
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F004-LOW'
                                fp_lfs_leg_tab-matnr
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'SEL_DATE'
                               fp_lfs_leg_tab-datab
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1902'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMG-MATNR(01)'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ENTF'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                'X'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1902'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMG-MATNR(01)'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'
                            CHANGING fp_li_bdcdata.
ENDFORM.                    " F_BDC_CREATE11
*&---------------------------------------------------------------------*
*&      Form  F_BDC_CREATE12
*&---------------------------------------------------------------------*
*       BDC Recording for Update
*----------------------------------------------------------------------*
*      -->FP_WA_LEG_TAB  Work Area type ty_leg_tab
*      <--FP_LI_BDCDATA  Internal Table
*----------------------------------------------------------------------*
FORM f_bdc_create12  USING    fp_lfs_leg_tab TYPE ty_leg_tab
                              fp_access_seq  TYPE char2
                   CHANGING fp_li_bdcdata TYPE bdcdata_tab.

  DATA: lv_date_from TYPE datum,  " From Date
        lv_date_to TYPE datum,  " To Date
        lv_amount TYPE char15. " Amount

  DATA: lv_field    TYPE char20.  "Dynamic BDC field

  lv_date_from = fp_lfs_leg_tab-datab.
  lv_date_to = fp_lfs_leg_tab-datbi.

  CLEAR: fp_lfs_leg_tab-datab,
         fp_lfs_leg_tab-datbi.
**&& -- The Date is converted from yyyymmdd to dd.mm.yyyy
  WRITE lv_date_from TO fp_lfs_leg_tab-datab.
  WRITE lv_date_to TO fp_lfs_leg_tab-datbi.
**&& -- The Amount is condensed to remove leading spaces.
  lv_amount = fp_lfs_leg_tab-kbetr.
  CONDENSE lv_amount.

  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '0100'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-KSCHL'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-KSCHL'
                                fp_lfs_leg_tab-kschl
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'
                            CHANGING fp_li_bdcdata.

  CONCATENATE 'RV130-SELKZ('fp_access_seq')' INTO lv_field.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                lv_field
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING lv_field
                                'X'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'RV13A905' '1000'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'F003'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ONLI'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F001'
                                fp_lfs_leg_tab-vkorg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F002'
                                fp_lfs_leg_tab-vtweg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F003'
                                fp_lfs_leg_tab-zzkvgr2
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F004-LOW'
                                fp_lfs_leg_tab-prod
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'SEL_DATE'
                                fp_lfs_leg_tab-datab
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1905'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-DATBI(01)'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'KONP-KBETR(01)'
                                lv_amount
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-DATAB(01)'
                                fp_lfs_leg_tab-datab
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-DATBI(01)'
                                fp_lfs_leg_tab-datbi
                            CHANGING fp_li_bdcdata.

ENDFORM.                    " F_BDC_CREATE12
*&---------------------------------------------------------------------*
*&      Form  F_BDC_CREATE13
*&---------------------------------------------------------------------*
*       BDC Recording for Delete
*----------------------------------------------------------------------*
*      -->FP_WA_LEG_TAB  Work Area type ty_leg_tab
*      <--FP_LI_BDCDATA  Internal Table
*----------------------------------------------------------------------*
FORM f_bdc_create13  USING    fp_lfs_leg_tab TYPE ty_leg_tab
                             fp_access_seq  TYPE char2
                    CHANGING fp_li_bdcdata TYPE bdcdata_tab.

  DATA: lv_date_from TYPE datum,  " From Date
        lv_date_to TYPE datum.  " To Date

  DATA: lv_field    TYPE char20.  "Dynamic BDC field

  lv_date_from = fp_lfs_leg_tab-datab.
  lv_date_to = fp_lfs_leg_tab-datbi.

  CLEAR: fp_lfs_leg_tab-datab,
         fp_lfs_leg_tab-datbi.
**&& -- The Date is converted from yyyymmdd to dd.mm.yyyy
  WRITE lv_date_from TO fp_lfs_leg_tab-datab.
  WRITE lv_date_to TO fp_lfs_leg_tab-datbi.

  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '0100'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-KSCHL'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-KSCHL'
                                fp_lfs_leg_tab-kschl
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'
                            CHANGING fp_li_bdcdata.

  CONCATENATE 'RV130-SELKZ('fp_access_seq')' INTO lv_field.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                lv_field
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING lv_field
                                'X'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'RV13A905' '1000'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'SEL_DATE'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ONLI'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F001'
                                fp_lfs_leg_tab-vkorg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F002'
                                fp_lfs_leg_tab-vtweg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F003'
                                fp_lfs_leg_tab-zzkvgr2
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F004-LOW'
                                fp_lfs_leg_tab-prod
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'SEL_DATE'
                                fp_lfs_leg_tab-datab
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1905'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMG-ZZPRODH4(01)'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ENTF'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                'X'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1905'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMG-ZZPRODH4(01)'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'
                            CHANGING fp_li_bdcdata.

ENDFORM.                    " F_BDC_CREATE13
*&---------------------------------------------------------------------*
*&      Form  F_BDC_CREATE14
*&---------------------------------------------------------------------*
*       BDC Recording for Update
*----------------------------------------------------------------------*
*      -->FP_WA_LEG_TAB  Work Area type ty_leg_tab
*      <--FP_LI_BDCDATA  Internal Table
*----------------------------------------------------------------------*
FORM f_bdc_create14  USING    fp_lfs_leg_tab TYPE ty_leg_tab
                            fp_access_seq  TYPE char2
                   CHANGING fp_li_bdcdata TYPE bdcdata_tab.

  DATA: lv_date_from TYPE datum,  " From Date
        lv_date_to TYPE datum,  " To Date
        lv_amount TYPE char15.  " Amount

  DATA: lv_field    TYPE char20.  "Dynamic BDC field

  lv_date_from = fp_lfs_leg_tab-datab.
  lv_date_to = fp_lfs_leg_tab-datbi.

  CLEAR: fp_lfs_leg_tab-datab,
         fp_lfs_leg_tab-datbi.
**&& -- The Date is converted from yyyymmdd to dd.mm.yyyy
  WRITE lv_date_from TO fp_lfs_leg_tab-datab.
  WRITE lv_date_to TO fp_lfs_leg_tab-datbi.
**&& -- The Amount is condensed to remove the leading spaces.
  lv_amount = fp_lfs_leg_tab-kbetr.
  CONDENSE lv_amount.

  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '0100'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-KSCHL'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-KSCHL'
                                fp_lfs_leg_tab-kschl
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'
                            CHANGING fp_li_bdcdata.

  CONCATENATE 'RV130-SELKZ('fp_access_seq')' INTO lv_field.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                lv_field
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING lv_field
                                'X'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'RV13A904' '1000'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'SEL_DATE'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ONLI'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F001'
                                fp_lfs_leg_tab-vkorg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F002'
                                fp_lfs_leg_tab-vtweg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F003'
                                fp_lfs_leg_tab-zzkvgr1
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F004-LOW'
                                fp_lfs_leg_tab-prod
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'SEL_DATE'
                                fp_lfs_leg_tab-datab
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1904'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-DATBI(01)'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'KONP-KBETR(01)'
                              lv_amount
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-DATAB(01)'
                                fp_lfs_leg_tab-datab
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-DATBI(01)'
                                fp_lfs_leg_tab-datbi
                            CHANGING fp_li_bdcdata.

ENDFORM.                    " F_BDC_CREATE14
*&---------------------------------------------------------------------*
*&      Form  F_BDC_CREATE15
*&---------------------------------------------------------------------*
*       BDC Recording for Delete
*----------------------------------------------------------------------*
*      -->FP_WA_LEG_TAB  Work Area type ty_leg_tab
*      <--FP_LI_BDCDATA  Internal Table
*----------------------------------------------------------------------*
FORM f_bdc_create15  USING    fp_lfs_leg_tab TYPE ty_leg_tab
                              fp_access_seq  TYPE char2
                    CHANGING fp_li_bdcdata TYPE bdcdata_tab.

  DATA: lv_date_from TYPE datum,  " From Date
          lv_date_to TYPE datum,  " To Date
          lv_field    TYPE char20.  "Dynamic BDC field

  lv_date_from = fp_lfs_leg_tab-datab.
  lv_date_to = fp_lfs_leg_tab-datbi.

  CLEAR: fp_lfs_leg_tab-datab,
         fp_lfs_leg_tab-datbi.

**&& -- The Date is converted from yyyymmdd to dd.mm.yyyy
  WRITE lv_date_from TO fp_lfs_leg_tab-datab.
  WRITE lv_date_to TO fp_lfs_leg_tab-datbi.

  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '0100'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV13A-KSCHL'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV13A-KSCHL'
                                fp_lfs_leg_tab-kschl
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'
                            CHANGING fp_li_bdcdata.

  CONCATENATE 'RV130-SELKZ('fp_access_seq')' INTO lv_field.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                lv_field
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING lv_field
                                'X'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'RV13A904' '1000'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'SEL_DATE'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ONLI'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F001'
                                fp_lfs_leg_tab-vkorg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F002'
                                fp_lfs_leg_tab-vtweg
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F003'
                                fp_lfs_leg_tab-zzkvgr1
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'F004-LOW'
                                fp_lfs_leg_tab-prod
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'SEL_DATE'
                                fp_lfs_leg_tab-datab
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1904'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMG-ZZPRODH4(01)'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ENTF'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                'X'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_dynpro      USING 'SAPMV13A' '1904'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMG-ZZPRODH4(01)'
                            CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'
                            CHANGING fp_li_bdcdata.

ENDFORM.                    " F_BDC_CREATE15
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_LOG_ERROR1
*&---------------------------------------------------------------------*
* Get Message Description
*&---------------------------------------------------------------------*
FORM f_log_msg1.

  DATA : lwa_return TYPE bapiret2, " bapi return
         lv_date_from TYPE datum,
         lv_date_to TYPE datum,
         lv_par1 TYPE char50," parameter1
         lv_par2 TYPE char50," parameter2
         lv_par3 TYPE char50," parameter3
         lv_par4 TYPE char50," parameter1
         lv_num  TYPE bapiret2-number."message number


  lv_par1 = syst-msgv1.
  lv_par2 = syst-msgv2.
  lv_par3 = syst-msgv3.
  lv_par4 = syst-msgv4.
  lv_num  = syst-msgno.

  CALL FUNCTION 'BALW_BAPIRETURN_GET2'
    EXPORTING
      type   = syst-msgty
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
    wa_report-msgtxt = text-022.
  ELSE.
    wa_report-msgtxt = lwa_return-message.
  ENDIF.

  lv_date_from = wa_leg_tab-datab.
  lv_date_to = wa_leg_tab-datbi.
  WRITE lv_date_from TO wa_leg_tab-datab.
  WRITE lv_date_to TO wa_leg_tab-datbi.

  CONCATENATE wa_leg_tab-kappl
              wa_leg_tab-kschl
              wa_leg_tab-vkorg
              wa_leg_tab-vtweg
              wa_leg_tab-kunnr
              wa_leg_tab-matnr
              wa_leg_tab-datab
              wa_leg_tab-datbi
              wa_leg_tab-prod
              wa_leg_tab-zzkvgr1
              wa_leg_tab-zzkvgr2
             INTO gv_mkey SEPARATED BY space.

  wa_report-key    = gv_mkey.
  APPEND wa_report TO i_report.
  CLEAR wa_report.
ENDFORM.                    "f_log_msg1
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_KNUMH
*&---------------------------------------------------------------------*
*       Populate KNUMH in case of Item Change/Delete
*----------------------------------------------------------------------*
*      <--FP_LEG_TAB  Internal Table
*----------------------------------------------------------------------*
FORM f_populate_knumh CHANGING fp_leg_tab TYPE ty_t_leg_tab.

  FIELD-SYMBOLS: <lfs_leg_tab> TYPE ty_leg_tab, " field symbols
                 <lfs_a005> TYPE ty_005,
                 <lfs_a004> TYPE ty_004,
                 <lfs_a911> TYPE ty_911,
                 <lfs_a901> TYPE ty_901,
                 <lfs_a902> TYPE ty_902.

  DATA: lv_knumh TYPE knumh,
        li_leg_tab TYPE ty_t_leg_tab,
        lr_datbi TYPE RANGE OF datum,
        lwa_datbi LIKE LINE OF lr_datbi,
        lv_message TYPE char80.

  li_leg_tab[] = fp_leg_tab[].
  SORT li_leg_tab BY parameter.
  DELETE li_leg_tab WHERE parameter = 'I'
                      OR  parameter = 'D'
                      OR  parameter = 'i'
                      OR  parameter = 'd'.

  CASE gv_table.

** && -- If the Table = A005
    WHEN c_005.
      LOOP AT li_leg_tab ASSIGNING <lfs_leg_tab>.
        lwa_datbi-sign = 'I'.
        lwa_datbi-option = 'EQ'.
        lwa_datbi-low = <lfs_leg_tab>-datbi.
        APPEND lwa_datbi TO lr_datbi.
        CLEAR lwa_datbi.
      ENDLOOP.
      UNASSIGN <lfs_leg_tab>.

***--> Begin of Insert for OTC_CDD_0008 Hanatization by APODDAR
      IF li_leg_tab IS NOT INITIAL.
***<-- End of Insert for OTC_CDD_0008 Hanatization by APODDAR

      SELECT kappl
             kschl
             vkorg
             vtweg
             kunnr
             matnr
             datbi
             datab
             knumh
    FROM a005
    INTO TABLE i_005
    FOR ALL ENTRIES IN li_leg_tab
    WHERE kappl = li_leg_tab-kappl
    AND   kschl = li_leg_tab-kschl
    AND   vkorg = li_leg_tab-vkorg
    AND   vtweg = li_leg_tab-vtweg
    AND   kunnr = li_leg_tab-kunnr
    AND   matnr = li_leg_tab-matnr
    AND   datbi IN lr_datbi.

      IF sy-subrc IS INITIAL.
        SORT fp_leg_tab BY kappl kschl vkorg vtweg kunnr matnr datbi datab.

        UNASSIGN <lfs_a005>.
        LOOP AT i_005 ASSIGNING <lfs_a005>.
          UNASSIGN <lfs_leg_tab>.
          READ TABLE fp_leg_tab ASSIGNING <lfs_leg_tab> WITH KEY kappl = <lfs_a005>-kappl
                                                                 kschl = <lfs_a005>-kschl
                                                                 vkorg = <lfs_a005>-vkorg
                                                                 vtweg = <lfs_a005>-vtweg
                                                                 kunnr = <lfs_a005>-kunnr
                                                                 matnr = <lfs_a005>-matnr
                                                                 datbi = <lfs_a005>-datbi
                                                                 datab = <lfs_a005>-datab
                                                                 BINARY SEARCH.
          IF sy-subrc IS INITIAL.
*****            We need to use the Internal Comment Indicator here.
            IF <lfs_leg_tab>-txt_ind IS NOT INITIAL.
***** Populate the KNUMH
              <lfs_leg_tab>-knumh = <lfs_a005>-knumh.
            ELSE.
*              TRANSLATE <lfs_leg_tab>-parameter TO UPPER CASE.
*              lv_message = 'Saving not necessary. No changes were made'(004).
*              gv_tot1 = gv_tot1 + 1.
*              PERFORM f_log_msg2 USING <lfs_leg_tab>-kappl
*                                       <lfs_leg_tab>-kschl
*                                       <lfs_leg_tab>-vkorg
*                                       <lfs_leg_tab>-vtweg
*                                       <lfs_leg_tab>-kunnr
*                                       <lfs_leg_tab>-matnr
*                                       <lfs_leg_tab>-datbi
*                                       <lfs_leg_tab>-datab
*                                       <lfs_leg_tab>-parameter
*                                       lv_message.
*              CLEAR lv_message.
*              <lfs_leg_tab>-kappl = space.
            ENDIF.
          ENDIF.
        ENDLOOP.
**&&-- Delete the file lines where the record is in the DB condition
*        table and the Internal Comment Indicator is space.
*        DELETE fp_leg_tab WHERE txt_ind = space.
      ENDIF.

***--> Begin of Insert for OTC_CDD_0008 Hanatization by APODDAR
      ENDIF.
***<-- End of Insert for OTC_CDD_0008 Hanatization by APODDAR


** && -- If the Table = A004
    WHEN c_004.

      LOOP AT li_leg_tab ASSIGNING <lfs_leg_tab>.
        lwa_datbi-sign = 'I'.
        lwa_datbi-option = 'EQ'.
        lwa_datbi-low = <lfs_leg_tab>-datbi.
        APPEND lwa_datbi TO lr_datbi.
        CLEAR lwa_datbi.
      ENDLOOP.
      UNASSIGN <lfs_leg_tab>.

***--> Begin of Insert for OTC_CDD_0008 Hanatization by APODDAR
      IF li_leg_tab IS NOT INITIAL.
***<-- End of Insert for OTC_CDD_0008 Hanatization by APODDAR

      SELECT kappl
             kschl
             vkorg
             vtweg
             matnr
             datbi
             datab
             knumh
    FROM a004
    INTO TABLE i_004
    FOR ALL ENTRIES IN li_leg_tab
    WHERE kappl = li_leg_tab-kappl
    AND   kschl = li_leg_tab-kschl
    AND   vkorg = li_leg_tab-vkorg
    AND   vtweg = li_leg_tab-vtweg
    AND   matnr = li_leg_tab-matnr
    AND   datbi IN lr_datbi.

      IF sy-subrc IS INITIAL.
        SORT i_004 BY kappl kschl vkorg vtweg matnr datbi datab.
        UNASSIGN <lfs_a004>.
        LOOP AT i_004 ASSIGNING <lfs_a004>.
          UNASSIGN <lfs_leg_tab>.
          READ TABLE fp_leg_tab ASSIGNING <lfs_leg_tab> WITH KEY kappl = <lfs_a004>-kappl
                                                           kschl = <lfs_a004>-kschl
                                                           vkorg = <lfs_a004>-vkorg
                                                           vtweg = <lfs_a004>-vtweg
                                                           matnr = <lfs_a004>-matnr
                                                           datbi = <lfs_a004>-datbi
                                                           datab = <lfs_a004>-datab
                                                           BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            IF <lfs_leg_tab>-txt_ind IS NOT INITIAL.
              <lfs_leg_tab>-knumh = <lfs_a004>-knumh.
*            ELSE.
*              lv_message = 'Saving not necessary. No changes were made'(004).
*              gv_tot1 = gv_tot1 + 1.
*              PERFORM f_log_msg2 USING <lfs_leg_tab>-kappl
*                                       <lfs_leg_tab>-kschl
*                                       <lfs_leg_tab>-vkorg
*                                       <lfs_leg_tab>-vtweg
*                                        space
*                                       <lfs_leg_tab>-matnr
*                                       <lfs_leg_tab>-datbi
*                                       <lfs_leg_tab>-datab
*                                       <lfs_leg_tab>-parameter
*                                       lv_message.
*              CLEAR lv_message.
*              <lfs_leg_tab>-kappl = space.
            ENDIF.
          ENDIF.
        ENDLOOP.
*        DELETE fp_leg_tab WHERE kappl = space.
      ENDIF.

***--> Begin of Insert for OTC_CDD_0008 Hanatization by APODDAR
      ENDIF.
***<-- End of Insert for OTC_CDD_0008 Hanatization by APODDAR


** && -- If the Table = A911
    WHEN c_911.

      LOOP AT li_leg_tab ASSIGNING <lfs_leg_tab>.
        lwa_datbi-sign = 'I'.
        lwa_datbi-option = 'EQ'.
        lwa_datbi-low = <lfs_leg_tab>-datbi.
        APPEND lwa_datbi TO lr_datbi.
        CLEAR lwa_datbi.
      ENDLOOP.
      UNASSIGN <lfs_leg_tab>.

***--> Begin of Insert for OTC_CDD_0008 Hanatization by APODDAR
      IF li_leg_tab IS NOT INITIAL.
***<-- End of Insert for OTC_CDD_0008 Hanatization by APODDAR

      SELECT kappl
             kschl
             vkorg
             vtweg
             kunwe
             matnr
             kfrst
             datbi
             datab
             knumh
    FROM a911
    INTO TABLE i_911
    FOR ALL ENTRIES IN li_leg_tab
    WHERE kappl = li_leg_tab-kappl
    AND   kschl = li_leg_tab-kschl
    AND   vkorg = li_leg_tab-vkorg
    AND   vtweg = li_leg_tab-vtweg
    AND   kunwe = li_leg_tab-kunnr
    AND   matnr = li_leg_tab-matnr
    AND   kfrst = space
    AND   datbi IN lr_datbi.

      IF sy-subrc IS INITIAL.
        SORT i_911 BY kappl kschl vkorg vtweg kunwe matnr datab datbi.
        UNASSIGN <lfs_a911>.
        LOOP AT i_911 ASSIGNING <lfs_a911>.
          UNASSIGN <lfs_leg_tab>.
          READ TABLE fp_leg_tab ASSIGNING <lfs_leg_tab> WITH KEY kappl = <lfs_a911>-kappl
                                                           kschl = <lfs_a911>-kschl
                                                           vkorg = <lfs_a911>-vkorg
                                                           vtweg = <lfs_a911>-vtweg
                                                           kunnr = <lfs_a911>-kunwe
                                                           matnr = <lfs_a911>-matnr
                                                           datbi = <lfs_a911>-datbi
                                                           datab = <lfs_a911>-datab
                                                           BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            IF <lfs_leg_tab>-txt_ind IS NOT INITIAL.
              <lfs_leg_tab>-knumh = <lfs_a911>-knumh.
*            ELSE.
*              lv_message = 'Saving not necessary. No changes were made'(004).
*              gv_tot1 = gv_tot1 + 1.
*              PERFORM f_log_msg2 USING <lfs_leg_tab>-kappl
*                                       <lfs_leg_tab>-kschl
*                                       <lfs_leg_tab>-vkorg
*                                       <lfs_leg_tab>-vtweg
*                                       <lfs_leg_tab>-kunnr
*                                       <lfs_leg_tab>-matnr
*                                       <lfs_leg_tab>-datbi
*                                       <lfs_leg_tab>-datab
*                                       <lfs_leg_tab>-parameter
*                                       lv_message.
*              CLEAR lv_message.
*              <lfs_leg_tab>-kappl = space.
            ENDIF.
          ENDIF.
        ENDLOOP.
*        DELETE fp_leg_tab WHERE kappl = space.
      ENDIF.

***--> Begin of Insert for OTC_CDD_0008 Hanatization by APODDAR
      ENDIF.
***<-- End of Insert for OTC_CDD_0008 Hanatization by APODDAR


** && -- If the Table = A901
    WHEN c_901.

      LOOP AT li_leg_tab ASSIGNING <lfs_leg_tab>.
        lwa_datbi-sign = 'I'.
        lwa_datbi-option = 'EQ'.
        lwa_datbi-low = <lfs_leg_tab>-datbi.
        APPEND lwa_datbi TO lr_datbi.
        CLEAR lwa_datbi.
      ENDLOOP.
      UNASSIGN <lfs_leg_tab>.

***--> Begin of Insert for OTC_CDD_0008 Hanatization by APODDAR
      IF li_leg_tab IS NOT INITIAL.
***<-- End of Insert for OTC_CDD_0008 Hanatization by APODDAR


      SELECT kappl
             kschl
             vkorg
             vtweg
             zzkvgr1
             matnr
             kfrst
             datbi
             datab
             knumh
    FROM a901
    INTO TABLE i_901
    FOR ALL ENTRIES IN li_leg_tab
    WHERE kappl = li_leg_tab-kappl
    AND   kschl = li_leg_tab-kschl
    AND   vkorg = li_leg_tab-vkorg
    AND   vtweg = li_leg_tab-vtweg
    AND   matnr = li_leg_tab-matnr
    AND   kfrst = space
    AND   datbi IN lr_datbi.

      IF sy-subrc IS INITIAL.
        SORT i_901 BY kappl kschl vkorg vtweg matnr datab datbi.

        LOOP AT i_901 ASSIGNING <lfs_a901>.
          READ TABLE fp_leg_tab ASSIGNING <lfs_leg_tab> WITH KEY kappl = <lfs_a901>-kappl
                                                           kschl = <lfs_a901>-kschl
                                                           vkorg = <lfs_a901>-vkorg
                                                           vtweg = <lfs_a901>-vtweg
                                                           matnr = <lfs_a901>-matnr
                                                           datbi = <lfs_a901>-datbi
                                                           datab = <lfs_a901>-datab
                                                           BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            IF <lfs_leg_tab>-txt_ind IS NOT INITIAL.
              <lfs_leg_tab>-knumh = <lfs_a901>-knumh.
*            ELSE.
*              lv_message = 'Saving not necessary. No changes were made'(004).
*              gv_tot1 = gv_tot1 + 1.
*              PERFORM f_log_msg2 USING <lfs_leg_tab>-kappl
*                                       <lfs_leg_tab>-kschl
*                                       <lfs_leg_tab>-vkorg
*                                       <lfs_leg_tab>-vtweg
*                                       space
*                                       <lfs_leg_tab>-matnr
*                                       <lfs_leg_tab>-datbi
*                                       <lfs_leg_tab>-datab
*                                       <lfs_leg_tab>-parameter
*                                       lv_message.
*              CLEAR lv_message.
*              <lfs_leg_tab>-kappl = space.
            ENDIF.
          ENDIF.
          UNASSIGN <lfs_leg_tab>.
        ENDLOOP.
        UNASSIGN <lfs_a901>.
*        DELETE fp_leg_tab WHERE kappl = space.
      ENDIF.

***--> Begin of Insert for OTC_CDD_0008 Hanatization by APODDAR
      ENDIF.
***<-- End of Insert for OTC_CDD_0008 Hanatization by APODDAR


** && -- If the Table = A902
    WHEN c_902.

      LOOP AT li_leg_tab ASSIGNING <lfs_leg_tab>.
        lwa_datbi-sign = 'I'.
        lwa_datbi-option = 'EQ'.
        lwa_datbi-low = <lfs_leg_tab>-datbi.
        APPEND lwa_datbi TO lr_datbi.
        CLEAR lwa_datbi.
      ENDLOOP.
      UNASSIGN <lfs_leg_tab>.

***--> Begin of Insert for OTC_CDD_0008 Hanatization by APODDAR
      IF li_leg_tab IS NOT INITIAL.
***<-- End of Insert for OTC_CDD_0008 Hanatization by APODDAR

      SELECT kappl
             kschl
             vkorg
             vtweg
             zzkvgr2
             matnr
             kfrst
             datbi
             datab
             knumh
    FROM a902
    INTO TABLE i_902
    FOR ALL ENTRIES IN li_leg_tab
    WHERE kappl = li_leg_tab-kappl
    AND   kschl = li_leg_tab-kschl
    AND   vkorg = li_leg_tab-vkorg
    AND   vtweg = li_leg_tab-vtweg
    AND   matnr = li_leg_tab-matnr
    AND   kfrst = space
    AND   datbi IN lr_datbi.

      IF sy-subrc IS INITIAL.
        SORT i_902 BY kappl kschl vkorg vtweg matnr datab datbi.

        LOOP AT i_902 ASSIGNING <lfs_a902>.
          READ TABLE fp_leg_tab ASSIGNING <lfs_leg_tab> WITH KEY kappl = <lfs_a902>-kappl
                                                           kschl = <lfs_a902>-kschl
                                                           vkorg = <lfs_a902>-vkorg
                                                           vtweg = <lfs_a902>-vtweg
                                                           matnr = <lfs_a902>-matnr
                                                           datbi = <lfs_a902>-datbi
                                                           datab = <lfs_a902>-datab
                                                           BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            IF <lfs_leg_tab>-txt_ind IS NOT INITIAL.
              <lfs_leg_tab>-knumh = <lfs_a902>-knumh.
*            ELSE.
*              TRANSLATE <lfs_leg_tab>-parameter TO UPPER CASE.
*              lv_message = 'Saving not necessary. No changes were made'(004).
*              gv_tot1 = gv_tot1 + 1.
*              PERFORM f_log_msg2 USING <lfs_leg_tab>-kappl
*                                       <lfs_leg_tab>-kschl
*                                       <lfs_leg_tab>-vkorg
*                                       <lfs_leg_tab>-vtweg
*                                       space
*                                       <lfs_leg_tab>-matnr
*                                       <lfs_leg_tab>-datbi
*                                       <lfs_leg_tab>-datab
*                                       <lfs_leg_tab>-parameter
*                                       lv_message.
*              CLEAR lv_message.
*              <lfs_leg_tab>-kappl = space.
            ENDIF.
          ENDIF.
          UNASSIGN <lfs_leg_tab>.
        ENDLOOP.
        UNASSIGN <lfs_a902>.
*        DELETE fp_leg_tab WHERE kappl = space.
      ENDIF.

***--> Begin of Insert for OTC_CDD_0008 Hanatization by APODDAR
      ENDIF.
***<-- End of Insert for OTC_CDD_0008 Hanatization by APODDAR


  ENDCASE.

ENDFORM.                    " F_POPULATE_KNUMH
***&---------------------------------------------------------------------*
***&      Form  F_POPULATE_KNUMH
***&---------------------------------------------------------------------*
***       Populate KNUMH in case of Item Change/Delete
***----------------------------------------------------------------------*
***      <--FP_LEG_TAB  Internal Table
***----------------------------------------------------------------------*
**FORM f_populate_knumh  USING fp_lv_index TYPE syindex
**                             fp_leg_tab TYPE ty_leg_tab
**                       CHANGING fp_li_leg_tab TYPE ty_t_leg_tab.
**
**  FIELD-SYMBOLS: <lfs_leg_tab> TYPE ty_leg_tab, " field symbols
**                 <lfs_005> TYPE ty_005,
**                 <lfs_004> TYPE ty_004,
**                 <lfs_911> TYPE ty_911,
**                 <lfs_901> TYPE ty_901,
**                 <lfs_902> TYPE ty_902.
**
**  DATA: lv_knumh TYPE knumh.
**
**  CONCATENATE fp_leg_tab-datbi+6(4)
**              fp_leg_tab-datbi+0(2)
**              fp_leg_tab-datbi+3(2) INTO gv_date_to.
***              fp_leg_tab-datbi+3(2)
***              fp_leg_tab-datbi+0(2) INTO lv_to_date.
**  CONCATENATE fp_leg_tab-datab+6(4)
**              fp_leg_tab-datab+0(2)
**              fp_leg_tab-datab+3(2) INTO gv_date_to.
**
**  IF gv_table = c_005.
**    READ TABLE i_005 ASSIGNING <lfs_005> INDEX 1.
**    IF sy-subrc IS INITIAL.
***&&-- Update the Condition Record No in Int Table
**      READ TABLE fp_li_leg_tab ASSIGNING <lfs_leg_tab>
**                            INDEX fp_lv_index.
**      IF sy-subrc IS INITIAL.
**        <lfs_leg_tab>-knumh = <lfs_005>-knumh.
**      ENDIF.
**    ELSE.
**      gv_error = gv_error + 1.
**      APPEND  wa_leg_tab TO i_leg_tab_err.
**    ENDIF.
**    UNASSIGN <lfs_005>.
**
**  ELSEIF gv_table = c_004.
**    READ TABLE i_004 ASSIGNING <lfs_004> INDEX 1.
**    IF sy-subrc IS INITIAL.
***&&-- Update the Condition Record No in Int Table
**      READ TABLE fp_li_leg_tab ASSIGNING <lfs_leg_tab>
**                            INDEX fp_lv_index.
**      IF sy-subrc IS INITIAL.
**        <lfs_leg_tab>-knumh = <lfs_004>.
**      ENDIF.
**    ELSE.
**      gv_error = gv_error + 1.
**      APPEND  wa_leg_tab TO i_leg_tab_err.
**    ENDIF.
**    UNASSIGN <lfs_004>.
**
**  ELSEIF gv_table = c_911.
**    READ TABLE i_911 ASSIGNING <lfs_911> INDEX 1.
**    IF sy-subrc IS INITIAL.
***&&-- Update the Condition Record No in Int Table
**      READ TABLE fp_li_leg_tab ASSIGNING <lfs_leg_tab>
**                            INDEX fp_lv_index.
**      IF sy-subrc IS INITIAL.
**        <lfs_leg_tab>-knumh = <lfs_911>-knumh.
**      ENDIF.
**    ELSE.
**      gv_error = gv_error + 1.
**      APPEND  wa_leg_tab TO i_leg_tab_err.
**    ENDIF.
**    UNASSIGN <lfs_911>.
***ELSEIF gv_table = c_903.
***
***READ TABLE i_903 ASSIGNING <lfs_903> INDEX 1.
***  IF sy-subrc IS INITIAL.
****&&-- Update the Condition Record No in Int Table
***    READ TABLE fp_li_leg_tab ASSIGNING <lfs_leg_tab>
***                          INDEX fp_lv_index.
***    IF sy-subrc IS INITIAL.
***      <lfs_leg_tab>-knumh = lv_knumh.
***    ENDIF.
***  ELSE.
***    gv_error = gv_error + 1.
***    APPEND  wa_leg_tab TO i_leg_tab_err.
***  ENDIF.
**  ELSEIF gv_table = c_901.
**    READ TABLE i_901 ASSIGNING <lfs_901> INDEX 1.
**    IF sy-subrc IS INITIAL.
***&&-- Update the Condition Record No in Int Table
**      READ TABLE fp_li_leg_tab ASSIGNING <lfs_leg_tab>
**                            INDEX fp_lv_index.
**      IF sy-subrc IS INITIAL.
**        <lfs_leg_tab>-knumh = <lfs_901>-knumh.
**      ENDIF.
**    ELSE.
**      gv_error = gv_error + 1.
**      APPEND  wa_leg_tab TO i_leg_tab_err.
**    ENDIF.
**    UNASSIGN <lfs_901>.
**
**  ELSEIF gv_table = c_902.
**
**    READ TABLE i_902 ASSIGNING <lfs_902> INDEX 1.
**    IF sy-subrc IS INITIAL.
***&&-- Update the Condition Record No in Int Table
**      READ TABLE fp_li_leg_tab ASSIGNING <lfs_leg_tab>
**                            INDEX fp_lv_index.
**      IF sy-subrc IS INITIAL.
**        <lfs_leg_tab>-knumh = <lfs_902>-knumh.
**      ENDIF.
**    ELSE.
**      gv_error = gv_error + 1.
**      APPEND  wa_leg_tab TO i_leg_tab_err.
**    ENDIF.
***ELSEIF gv_table = c_905.
***  SELECT knumh
***    UP TO 1 ROWS
***    FROM a905
***    INTO lv_knumh
***    WHERE kappl = fp_leg_tab-kappl
***      AND kschl = fp_leg_tab-kschl
***      AND vkorg = fp_leg_tab-vkorg
***      AND vtweg = fp_leg_tab-vtweg
****        AND ZZKVGR2
****        AND ZZPRODH4
****        AND KFRST =
***      AND datbi = gv_date_to.
***  ENDSELECT.
***  IF sy-subrc IS INITIAL.
****&&-- Update the Condition Record No in Int Table
***    READ TABLE fp_li_leg_tab ASSIGNING <lfs_leg_tab>
***                          INDEX fp_lv_index.
***    IF sy-subrc IS INITIAL.
***      <lfs_leg_tab>-knumh = lv_knumh.
***    ENDIF.
***  ELSE.
***    gv_error = gv_error + 1.
***    APPEND  wa_leg_tab TO i_leg_tab_err.
***  ENDIF.
***ELSEIF gv_table = c_904.
***  SELECT knumh
***    UP TO 1 ROWS
***    FROM a904
***    INTO lv_knumh
***    WHERE kappl = fp_leg_tab-kappl
***      AND kschl = fp_leg_tab-kschl
***      AND vkorg = fp_leg_tab-vkorg
***      AND vtweg = fp_leg_tab-vtweg
****        AND ZZKVGR1
****        AND ZZPRODH4
****        AND KFRST =
***      AND datbi = gv_date_to.
***  ENDSELECT.
***  IF sy-subrc IS INITIAL.
****&&-- Update the Condition Record No in Int Table
***    READ TABLE fp_li_leg_tab ASSIGNING <lfs_leg_tab>
***                          INDEX fp_lv_index.
***    IF sy-subrc IS INITIAL.
***      <lfs_leg_tab>-knumh = lv_knumh.
***    ENDIF.
***  ELSE.
***    gv_error = gv_error + 1.
***    APPEND  wa_leg_tab TO i_leg_tab_err.
***  ENDIF.
**  ENDIF.
**
**
**ENDFORM.                    " F_POPULATE_KNUMH
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_PROCESSED_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_processed_data
                            CHANGING fp_leg_tab TYPE ty_t_leg_tab.


  DATA: li_leg_tab TYPE STANDARD TABLE OF ty_leg_tab,
        li_leg_tab_knumh TYPE STANDARD TABLE OF ty_leg_tab,
        lr_datbi TYPE RANGE OF datum,
        lwa_datbi LIKE LINE OF lr_datbi,
        lv_message TYPE char80.

  FIELD-SYMBOLS: <lfs_leg_tab> TYPE ty_leg_tab,
                 <lfs_a005> TYPE ty_005,
                 <lfs_a004> TYPE ty_004,
                 <lfs_a911> TYPE ty_911,
                 <lfs_a901> TYPE ty_901,
                 <lfs_a902> TYPE ty_902.


  li_leg_tab[] = fp_leg_tab[].

  SORT li_leg_tab BY parameter.
  DELETE li_leg_tab WHERE parameter = 'I'
                     OR   parameter = 'D'
                     OR   parameter = 'i'
                     OR   parameter = 'd'.

  CASE gv_table.

** && -- If the Table = A005
    WHEN c_005.

      LOOP AT li_leg_tab ASSIGNING <lfs_leg_tab>.
        lwa_datbi-sign = 'I'.
        lwa_datbi-option = 'EQ'.
        lwa_datbi-low = <lfs_leg_tab>-datbi.
        APPEND lwa_datbi TO lr_datbi.
        CLEAR lwa_datbi.
      ENDLOOP.
      UNASSIGN <lfs_leg_tab>.

      SELECT kappl
             kschl
             vkorg
             vtweg
             kunnr
             matnr
             datbi
             datab
             knumh
    FROM a005
    INTO TABLE i_005
    FOR ALL ENTRIES IN li_leg_tab
    WHERE kappl = li_leg_tab-kappl
    AND   kschl = li_leg_tab-kschl
    AND   vkorg = li_leg_tab-vkorg
    AND   vtweg = li_leg_tab-vtweg
    AND   kunnr = li_leg_tab-kunnr
    AND   matnr = li_leg_tab-matnr
    AND   datbi IN lr_datbi.
*        "Fetch data irrespective of the date as
*        From & To dates can be changed after BDC is done. So fetch
*        KNUMH based on the File Dates compared in A005

      IF sy-subrc IS INITIAL.
        SORT fp_leg_tab BY kappl kschl vkorg vtweg kunnr matnr datbi datab.

        LOOP AT i_005 ASSIGNING <lfs_a005>.
          READ TABLE fp_leg_tab ASSIGNING <lfs_leg_tab> WITH KEY kappl = <lfs_a005>-kappl
                                                                 kschl = <lfs_a005>-kschl
                                                                 vkorg = <lfs_a005>-vkorg
                                                                 vtweg = <lfs_a005>-vtweg
                                                                 kunnr = <lfs_a005>-kunnr
                                                                 matnr = <lfs_a005>-matnr
                                                                 datbi = <lfs_a005>-datbi
                                                                 datab = <lfs_a005>-datab
                                                                 BINARY SEARCH.
          IF sy-subrc IS INITIAL.
*****            We need to use the Internal Comment Indicator here.
            IF <lfs_leg_tab>-txt_ind IS NOT INITIAL.
***** Populate the KNUMH
              <lfs_leg_tab>-knumh = <lfs_a005>-knumh.

            ELSE.
              TRANSLATE <lfs_leg_tab>-parameter TO UPPER CASE.
              lv_message = 'Saving not necessary. No changes were made'(004).
              gv_tot1 = gv_tot1 + 1.
              PERFORM f_log_msg2 USING <lfs_leg_tab>-kappl
                                       <lfs_leg_tab>-kschl
                                       <lfs_leg_tab>-vkorg
                                       <lfs_leg_tab>-vtweg
                                       <lfs_leg_tab>-kunnr
                                       <lfs_leg_tab>-matnr
                                       <lfs_leg_tab>-datbi
                                       <lfs_leg_tab>-datab
                                       <lfs_leg_tab>-parameter
                                       lv_message.
              CLEAR lv_message.
              <lfs_leg_tab>-kappl = space.
            ENDIF.
          ENDIF.
          UNASSIGN <lfs_leg_tab>.
        ENDLOOP.
        UNASSIGN <lfs_a005>.
**&&-- Delete the file lines where the record is in the DB condition
*        table and the Internal Comment Indicator is space.
        DELETE fp_leg_tab WHERE txt_ind = space.
      ENDIF.

** && -- If the Table = A004
    WHEN c_004.

      LOOP AT li_leg_tab ASSIGNING <lfs_leg_tab>.
        lwa_datbi-sign = 'I'.
        lwa_datbi-option = 'EQ'.
        lwa_datbi-low = <lfs_leg_tab>-datbi.
        APPEND lwa_datbi TO lr_datbi.
        CLEAR lwa_datbi.
      ENDLOOP.
      UNASSIGN <lfs_leg_tab>.

      SELECT kappl
             kschl
             vkorg
             vtweg
             matnr
             datbi
             datab
             knumh
    FROM a004
    INTO TABLE i_004
    FOR ALL ENTRIES IN li_leg_tab
    WHERE kappl = li_leg_tab-kappl
    AND   kschl = li_leg_tab-kschl
    AND   vkorg = li_leg_tab-vkorg
    AND   vtweg = li_leg_tab-vtweg
    AND   matnr = li_leg_tab-matnr
    AND   datbi IN lr_datbi.

      IF sy-subrc IS INITIAL.
        SORT i_004 BY kappl kschl vkorg vtweg matnr datbi datab.
        LOOP AT i_004 ASSIGNING <lfs_a004>.

          READ TABLE fp_leg_tab ASSIGNING <lfs_leg_tab> WITH KEY kappl = <lfs_a004>-kappl
                                                           kschl = <lfs_a004>-kschl
                                                           vkorg = <lfs_a004>-vkorg
                                                           vtweg = <lfs_a004>-vtweg
                                                           matnr = <lfs_a004>-matnr
                                                           datbi = <lfs_a004>-datbi
                                                           datab = <lfs_a004>-datab
                                                           BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            IF <lfs_leg_tab>-txt_ind IS NOT INITIAL.
              <lfs_leg_tab>-knumh = <lfs_a004>-knumh.
            ELSE.
              lv_message = 'Saving not necessary. No changes were made'(004).
              gv_tot1 = gv_tot1 + 1.
              PERFORM f_log_msg2 USING <lfs_leg_tab>-kappl
                                       <lfs_leg_tab>-kschl
                                       <lfs_leg_tab>-vkorg
                                       <lfs_leg_tab>-vtweg
                                        space
                                       <lfs_leg_tab>-matnr
                                       <lfs_leg_tab>-datbi
                                       <lfs_leg_tab>-datab
                                       <lfs_leg_tab>-parameter
                                       lv_message.
              CLEAR lv_message.
              <lfs_leg_tab>-kappl = space.
            ENDIF.
          ENDIF.
          UNASSIGN <lfs_leg_tab>.
        ENDLOOP.
        UNASSIGN <lfs_a004>.
        DELETE fp_leg_tab WHERE kappl = space.
      ENDIF.

** && -- If the Table = A911
    WHEN c_911.

      LOOP AT li_leg_tab ASSIGNING <lfs_leg_tab>.
        lwa_datbi-sign = 'I'.
        lwa_datbi-option = 'EQ'.
        lwa_datbi-low = <lfs_leg_tab>-datbi.
        APPEND lwa_datbi TO lr_datbi.
        CLEAR lwa_datbi.
      ENDLOOP.
      UNASSIGN <lfs_leg_tab>.

      SELECT kappl
             kschl
             vkorg
             vtweg
             kunwe
             matnr
             kfrst
             datbi
             datab
             knumh
    FROM a911
    INTO TABLE i_911
    FOR ALL ENTRIES IN li_leg_tab
    WHERE kappl = li_leg_tab-kappl
    AND   kschl = li_leg_tab-kschl
    AND   vkorg = li_leg_tab-vkorg
    AND   vtweg = li_leg_tab-vtweg
    AND   kunwe = li_leg_tab-kunnr
    AND   matnr = li_leg_tab-matnr
    AND   kfrst = space
    AND   datbi IN lr_datbi.

      IF sy-subrc IS INITIAL.
        SORT i_911 BY kappl kschl vkorg vtweg kunwe matnr datab datbi.

        LOOP AT i_911 ASSIGNING <lfs_a911>.
          READ TABLE fp_leg_tab ASSIGNING <lfs_leg_tab> WITH KEY kappl = <lfs_a911>-kappl
                                                           kschl = <lfs_a911>-kschl
                                                           vkorg = <lfs_a911>-vkorg
                                                           vtweg = <lfs_a911>-vtweg
                                                           kunnr = <lfs_a911>-kunwe
                                                           matnr = <lfs_a911>-matnr
                                                           datbi = <lfs_a911>-datbi
                                                           datab = <lfs_a911>-datab
                                                           BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            IF <lfs_leg_tab>-txt_ind IS NOT INITIAL.
              <lfs_leg_tab>-knumh = <lfs_a004>-knumh.
            ELSE.
              lv_message = 'Saving not necessary. No changes were made'(004).
              gv_tot1 = gv_tot1 + 1.
              PERFORM f_log_msg2 USING <lfs_leg_tab>-kappl
                                       <lfs_leg_tab>-kschl
                                       <lfs_leg_tab>-vkorg
                                       <lfs_leg_tab>-vtweg
                                       <lfs_leg_tab>-kunnr
                                       <lfs_leg_tab>-matnr
                                       <lfs_leg_tab>-datbi
                                       <lfs_leg_tab>-datab
                                       <lfs_leg_tab>-parameter
                                       lv_message.
              CLEAR lv_message.
              <lfs_leg_tab>-kappl = space.
            ENDIF.
          ENDIF.
          UNASSIGN <lfs_leg_tab>.
        ENDLOOP.
        UNASSIGN <lfs_a911>.
        DELETE fp_leg_tab WHERE kappl = space.
      ENDIF.

** && -- If the Table = A901
    WHEN c_901.

      LOOP AT li_leg_tab ASSIGNING <lfs_leg_tab>.
        lwa_datbi-sign = 'I'.
        lwa_datbi-option = 'EQ'.
        lwa_datbi-low = <lfs_leg_tab>-datbi.
        APPEND lwa_datbi TO lr_datbi.
        CLEAR lwa_datbi.
      ENDLOOP.
      UNASSIGN <lfs_leg_tab>.

      SELECT kappl
             kschl
             vkorg
             vtweg
             zzkvgr1
             matnr
             kfrst
             datbi
             datab
             knumh
    FROM a901
    INTO TABLE i_901
    FOR ALL ENTRIES IN li_leg_tab
    WHERE kappl = li_leg_tab-kappl
    AND   kschl = li_leg_tab-kschl
    AND   vkorg = li_leg_tab-vkorg
    AND   vtweg = li_leg_tab-vtweg
    AND   matnr = li_leg_tab-matnr
    AND   kfrst = space
    AND   datbi IN lr_datbi.

      IF sy-subrc IS INITIAL.
        SORT i_901 BY kappl kschl vkorg vtweg matnr datab datbi.

        LOOP AT i_901 ASSIGNING <lfs_a901>.
          READ TABLE fp_leg_tab ASSIGNING <lfs_leg_tab> WITH KEY kappl = <lfs_a901>-kappl
                                                           kschl = <lfs_a901>-kschl
                                                           vkorg = <lfs_a901>-vkorg
                                                           vtweg = <lfs_a901>-vtweg
                                                           matnr = <lfs_a901>-matnr
                                                           datbi = <lfs_a901>-datbi
                                                           datab = <lfs_a901>-datab
                                                           BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            IF <lfs_leg_tab>-txt_ind IS NOT INITIAL.
              <lfs_leg_tab>-knumh = <lfs_a004>-knumh.
            ELSE.
              lv_message = 'Saving not necessary. No changes were made'(004).
              gv_tot1 = gv_tot1 + 1.
              PERFORM f_log_msg2 USING <lfs_leg_tab>-kappl
                                       <lfs_leg_tab>-kschl
                                       <lfs_leg_tab>-vkorg
                                       <lfs_leg_tab>-vtweg
                                       space
                                       <lfs_leg_tab>-matnr
                                       <lfs_leg_tab>-datbi
                                       <lfs_leg_tab>-datab
                                       <lfs_leg_tab>-parameter
                                       lv_message.
              CLEAR lv_message.
              <lfs_leg_tab>-kappl = space.
            ENDIF.
          ENDIF.
          UNASSIGN <lfs_leg_tab>.
        ENDLOOP.
        UNASSIGN <lfs_a901>.
        DELETE fp_leg_tab WHERE kappl = space.
      ENDIF.

** && -- If the Table = A902
    WHEN c_902.

      LOOP AT li_leg_tab ASSIGNING <lfs_leg_tab>.
        lwa_datbi-sign = 'I'.
        lwa_datbi-option = 'EQ'.
        lwa_datbi-low = <lfs_leg_tab>-datbi.
        APPEND lwa_datbi TO lr_datbi.
        CLEAR lwa_datbi.
      ENDLOOP.
      UNASSIGN <lfs_leg_tab>.

      SELECT kappl
             kschl
             vkorg
             vtweg
             zzkvgr2
             matnr
             kfrst
             datbi
             datab
             knumh
    FROM a902
    INTO TABLE i_902
    FOR ALL ENTRIES IN li_leg_tab
    WHERE kappl = li_leg_tab-kappl
    AND   kschl = li_leg_tab-kschl
    AND   vkorg = li_leg_tab-vkorg
    AND   vtweg = li_leg_tab-vtweg
    AND   matnr = li_leg_tab-matnr
    AND   kfrst = space
    AND   datbi IN lr_datbi.

      IF sy-subrc IS INITIAL.
        SORT i_902 BY kappl kschl vkorg vtweg matnr datab datbi.

        LOOP AT i_902 ASSIGNING <lfs_a902>.
          READ TABLE fp_leg_tab ASSIGNING <lfs_leg_tab> WITH KEY kappl = <lfs_a902>-kappl
                                                           kschl = <lfs_a902>-kschl
                                                           vkorg = <lfs_a902>-vkorg
                                                           vtweg = <lfs_a902>-vtweg
                                                           matnr = <lfs_a902>-matnr
                                                           datbi = <lfs_a902>-datbi
                                                           datab = <lfs_a902>-datab
                                                           BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            IF <lfs_leg_tab>-txt_ind IS NOT INITIAL.
              <lfs_leg_tab>-knumh = <lfs_a004>-knumh.
            ELSE.
              TRANSLATE <lfs_leg_tab>-parameter TO UPPER CASE.
              lv_message = 'Saving not necessary. No changes were made'(004).
              gv_tot1 = gv_tot1 + 1.
              PERFORM f_log_msg2 USING <lfs_leg_tab>-kappl
                                       <lfs_leg_tab>-kschl
                                       <lfs_leg_tab>-vkorg
                                       <lfs_leg_tab>-vtweg
                                       space
                                       <lfs_leg_tab>-matnr
                                       <lfs_leg_tab>-datbi
                                       <lfs_leg_tab>-datab
                                       <lfs_leg_tab>-parameter
                                       lv_message.
              CLEAR lv_message.
              <lfs_leg_tab>-kappl = space.
            ENDIF.
          ENDIF.
          UNASSIGN <lfs_leg_tab>.
        ENDLOOP.
        UNASSIGN <lfs_a902>.
        DELETE fp_leg_tab WHERE kappl = space.
      ENDIF.
  ENDCASE.


*&&-- Check for the file entry which exists in the DB Condition table
*  and the Internal Comment Indicator is NOT SPACE
  li_leg_tab_knumh[] = fp_leg_tab[].
  DELETE li_leg_tab_knumh WHERE knumh = space.
  PERFORM check_file_text USING li_leg_tab_knumh
                            CHANGING fp_leg_tab.

ENDFORM.                    " F_CHECK_PROCESSED_DATA
*&---------------------------------------------------------------------*
*&      Form  F_LOG_MSG2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_log_msg2 USING  fp_lfs_leg_tab_kappl TYPE kappl
                       fp_lfs_leg_tab_kschl TYPE kschl
                       fp_lfs_leg_tab_vkorg TYPE vkorg
                       fp_lfs_leg_tab_vtweg TYPE vtweg
                       fp_lfs_leg_tab_kunnr TYPE kunnr
                       fp_lfs_leg_tab_matnr TYPE matnr
                       fp_lfs_leg_tab_datbi TYPE char10
                       fp_lfs_leg_tab_datab TYPE char10
                       fp_lfs_leg_tab_parameter TYPE char1
                       fp_lv_msg TYPE char80.

  DATA: lv_datbi TYPE datum,
        lv_datab TYPE datum.

  lv_datbi = fp_lfs_leg_tab_datbi.
  lv_datab = fp_lfs_leg_tab_datab.

  WRITE lv_datbi TO fp_lfs_leg_tab_datbi.
  WRITE lv_datab TO fp_lfs_leg_tab_datab.

  wa_report-msgtyp = fp_lfs_leg_tab_parameter.
  wa_report-msgtxt = fp_lv_msg.

  CONCATENATE fp_lfs_leg_tab_kappl
                        fp_lfs_leg_tab_kschl
                        fp_lfs_leg_tab_vkorg
                        fp_lfs_leg_tab_vtweg
                        fp_lfs_leg_tab_matnr
                        fp_lfs_leg_tab_kunnr
                        fp_lfs_leg_tab_datbi
                        fp_lfs_leg_tab_datab
              INTO gv_mkey SEPARATED BY space.

  wa_report-key    = gv_mkey.
  gv_no_success1 = gv_no_success1 + 1.
  APPEND wa_report TO i_report.
  CLEAR wa_report.
ENDFORM.                    " F_LOG_MSG2
*&---------------------------------------------------------------------*
*&      Form  F_READ_TEXT
*&---------------------------------------------------------------------*
*      Read text (Internal Comment)
*----------------------------------------------------------------------*
*      -->FP_LFS_LEG_TAB-KNUMH    TYPE KNUMH
*----------------------------------------------------------------------*
FORM f_read_text  USING  fp_lfs_konp-knumh TYPE knumh
                         fp_lfs_konp-kopos TYPE kopos.

  DATA: lv_name TYPE tdobname,
        li_lines TYPE STANDARD TABLE OF tline.

  FIELD-SYMBOLS: <lfs_lines> TYPE tline.

  CONSTANTS: lc_id TYPE char4 VALUE '0001',
             lc_object TYPE char10 VALUE 'KONP'.

  CONCATENATE fp_lfs_konp-knumh fp_lfs_konp-kopos INTO lv_name.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = lc_id
      language                = sy-langu
      name                    = lv_name
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    UNASSIGN <lfs_lines>.
    READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 1.
    IF sy-subrc IS INITIAL.
      gv_tdline  =  <lfs_lines>-tdline.
    ENDIF.

  ENDIF.
ENDFORM.                    " F_READ_TEXT
*&---------------------------------------------------------------------*
*&      Form  CHECK_FILE_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_LEG_TAB_KNUMH  text
*      <--P_FP_LEG_TAB  text
*----------------------------------------------------------------------*
FORM check_file_text  USING    fp_li_leg_tab_knumh TYPE ty_t_leg_tab
                      CHANGING fp_leg_tab TYPE ty_t_leg_tab.

  FIELD-SYMBOLS: <lfs_leg_tab_knumh> TYPE ty_leg_tab,
                 <lfs_leg_tab> TYPE ty_leg_tab,
                 <lfs_konp> TYPE ty_konp.

  DATA: lv_message TYPE char80.

  SELECT knumh
         kopos
    FROM konp
    INTO TABLE i_konp
    FOR ALL ENTRIES IN fp_li_leg_tab_knumh
    WHERE knumh = fp_li_leg_tab_knumh-knumh.
  IF sy-subrc IS INITIAL.

    UNASSIGN <lfs_leg_tab_knumh>.
    LOOP AT fp_li_leg_tab_knumh ASSIGNING <lfs_leg_tab_knumh>.
      UNASSIGN <lfs_konp>.
      LOOP AT i_konp ASSIGNING <lfs_konp>.
        UNASSIGN <lfs_leg_tab>.
        READ TABLE fp_leg_tab ASSIGNING <lfs_leg_tab> WITH KEY kappl = <lfs_leg_tab_knumh>-kappl
                                                               kschl = <lfs_leg_tab_knumh>-kschl
                                                               vkorg = <lfs_leg_tab_knumh>-vkorg
                                                               vtweg = <lfs_leg_tab_knumh>-vtweg
                                                               kunnr = <lfs_leg_tab_knumh>-kunnr
                                                               matnr = <lfs_leg_tab_knumh>-matnr
                                                               datbi = <lfs_leg_tab_knumh>-datbi
                                                               datab = <lfs_leg_tab_knumh>-datab
                                                               BINARY SEARCH.
        IF sy-subrc IS INITIAL.

          PERFORM f_read_text USING <lfs_konp>-knumh
                                    <lfs_konp>-kopos.
          IF gv_tdline = <lfs_leg_tab>-ltx01.
            TRANSLATE <lfs_leg_tab>-parameter TO UPPER CASE.
            lv_message = 'Saving not necessary. No changes were made'(004).
            gv_tot1 = gv_tot1 + 1.
            PERFORM f_log_msg2 USING <lfs_leg_tab>-kappl
                                     <lfs_leg_tab>-kschl
                                     <lfs_leg_tab>-vkorg
                                     <lfs_leg_tab>-vtweg
                                     <lfs_leg_tab>-kunnr
                                     <lfs_leg_tab>-matnr
                                     <lfs_leg_tab>-datbi
                                     <lfs_leg_tab>-datab
                                     <lfs_leg_tab>-parameter
                                     lv_message.
            CLEAR lv_message.
            <lfs_leg_tab>-kappl = space.
            CLEAR gv_tdline.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
    DELETE fp_leg_tab WHERE kappl = space.
  ENDIF.
ENDFORM.                    " CHECK_FILE_TEXT
