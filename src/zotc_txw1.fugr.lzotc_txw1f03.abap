*----------------------------------------------------------------------*
***INCLUDE LTXW1F03 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SCHEDULE_ARCHIVE_EXPORT
*&---------------------------------------------------------------------*
*       create/schedule a batch job for asynchronous export to
*       archive
*----------------------------------------------------------------------*
*      -->I_OBJ_TYPE  type of the object (extract or view)
*      -->I_OBJ_UUID  UUID of the object
*      -->I_VOLDIR  DART directory of the object
*----------------------------------------------------------------------*
FORM schedule_archive_export  USING i_obj_type TYPE char1
                                    it_uuid TYPE txw_t_uuid
                                    i_mode TYPE char1
                                    i_voldir TYPE txw_volset.

  DATA: lt_dir2 TYPE dart1_t_dir2,
        l_failed_only TYPE char1,
        l_dummy_rerun TYPE txw_repeat_export,
        l_dummy_failed TYPE txw_repeat_export,
        l_jobname TYPE tbtcjob-jobname,
        l_jobnum TYPE tbtcjob-jobcount,
        l_count TYPE i,
        l_subrc TYPE sy-subrc.

* get all files for the object
  PERFORM dir2_get_ex USING i_obj_type
                            it_uuid
                            i_voldir
                   CHANGING lt_dir2.

* confirm export to archive
  PERFORM confirm_export USING i_obj_type
                               lt_dir2
                               l_dummy_rerun
                               l_dummy_failed
                      CHANGING l_failed_only.

* initialize message handler
  CALL FUNCTION 'MESSAGES_INITIALIZE'.

* open batch job
  PERFORM job_open USING lt_dir2
                         'EX'
                CHANGING l_jobname
                         l_jobnum.

* insert export extract/view files as steps for the job
  PERFORM job_steps_insert_ex USING lt_dir2
                                    l_jobname
                                    l_jobnum
                                    l_failed_only
                                    i_obj_type
                                    i_mode
                           CHANGING l_count.
* schedule batch job
  PERFORM job_close USING l_jobname
                          l_jobnum
                          l_count
                 CHANGING l_subrc.
  CASE l_subrc.
    WHEN 0.
*     ok
    WHEN 2.
*     no steps availabe - ok.
    WHEN 4.                                               "H1476424
*     SUBRC = 4 - job scheduling was canceled
      PERFORM archive_status_reset USING lt_dir2
                                         'EX'
                                         i_obj_type.
      RAISE canceled_by_user.
    WHEN OTHERS.                                          "H1476424
*     major error - error message already stored
      PERFORM archive_status_reset USING lt_dir2
                                         'EX'
                                         i_obj_type.
  ENDCASE.

* show messages
  CALL FUNCTION 'MESSAGES_STOP'
    EXCEPTIONS
      OTHERS = 0.
  CALL FUNCTION 'MESSAGES_SHOW'
    EXPORTING
      show_linno = ' '
      object     = text-030.

ENDFORM.                    " SCHEDULE_ARCHIVE_EXPORT
*&---------------------------------------------------------------------*
*&      Form  DIR2_GET_EX
*&---------------------------------------------------------------------*
*   get all the files for the actual object (EXPORT)
*   in case of extract you can find this information in TXW_DIR2
*        and TXW_DIRAL2 - if TXW_DIRAL2 is empty an entry will be
*        created here.
*   in case of views the information is selected from TXW_VWLOG2
*        and TXW_VWLOGAL2 - if TXW_VWLOGAL2 is empty a check for the
*        existence of the _MT-file (meta file) is done and a entrie in
*        TXW_VWLOGAL2 is created.
*   in all cases the information is mapped to a table of structure
*   TXW_DIR2 - later on only the XTRCT_UUID, the VOL_ID, the VOL_SET
*   and the achive parameters are used!
*----------------------------------------------------------------------*
FORM dir2_get_ex USING  i_obj_type TYPE char1
                        it_uuid TYPE txw_t_uuid
                        i_voldir TYPE txw_volset
               CHANGING ct_dir2 TYPE dart1_t_dir2.

  REFRESH ct_dir2.

  CASE i_obj_type.
    WHEN 'E'.
*     get files for selected extract
      PERFORM dir2_get_ex_extract USING sy-batch
                                        it_uuid
                                        i_voldir
                               CHANGING ct_dir2.

    WHEN 'V'.
*     get files for selected view query
      PERFORM dir2_get_ex_view USING it_uuid
                                     i_voldir
                            CHANGING ct_dir2.

  ENDCASE.
  SORT ct_dir2 BY xtrct_uuid vol_id.

ENDFORM.                                                 " DIR2_GET_EX
*&---------------------------------------------------------------------*
*&      Form  FILE_EXISTENCE_CHECK
*&---------------------------------------------------------------------*
*       check for existence of a file
*----------------------------------------------------------------------*
FORM file_existence_check  USING    i_file_name TYPE clike
                                    i_message TYPE char1
                           CHANGING c_subrc TYPE sy-subrc.

  OPEN DATASET i_file_name FOR INPUT IN TEXT MODE
                              ENCODING DEFAULT.
  c_subrc = sy-subrc.
  IF sy-subrc = 0.
    CLOSE DATASET i_file_name.
  ELSEIF i_message = 'X'.
    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        arbgb = 'XW'
        msgty = 'E'
        msgv1 = i_file_name
        txtnr = '203'.
    IF 1 = 2.               "just for message reference
      MESSAGE s203(xw) WITH i_file_name.
    ENDIF.
  ENDIF.

ENDFORM.                    " FILE_EXISTENCE_CHECK
*&---------------------------------------------------------------------*
*&      Form  CONFIRM_EXPORT
*&---------------------------------------------------------------------*
*       get a user confirmation for the export to archive
*----------------------------------------------------------------------*
FORM confirm_export  USING    i_obj_type TYPE char1
                              it_dir2 TYPE dart1_t_dir2
                              i_rerun TYPE txw_repeat_export
                              i_failed_only TYPE txw_repeat_export
                     CHANGING c_failed_only TYPE char1.

  DATA: l_exported TYPE char1,
        ls_dir2 TYPE dart1_dir2,
        l_answer TYPE char1,
        l_text(60) TYPE c.

* check if an export was done before.
  LOOP AT it_dir2 INTO ls_dir2
                  WHERE alestat EQ dart1_al_ok.
    l_exported = 'X'.
    EXIT.
  ENDLOOP.

  IF l_exported = space.
*   not yet exported to archive
    IF sy-batch = 'X'.
      EXIT.              "OK !
    ENDIF.
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        defaultoption = 'N'
        textline1     = text-a01
        textline2     = text-a02
        titel         = text-q01
      IMPORTING
        answer        = l_answer.
    IF l_answer NE 'J'.
      RAISE canceled_by_user.
    ENDIF.
    CLEAR: c_failed_only.
  ELSE.
*   was exported before
    IF sy-batch = 'X'.
      IF i_rerun = SPACE OR i_obj_type NE 'E'.
        MESSAGE e262(xw) WITH ls_dir2-l_file.
      ELSE.
*       re-run for batch (extracts only) should be executed
*       set flag for failed files
        c_failed_only = i_failed_only.
      ENDIF.
      EXIT.      "no further checks for batch processing
    ENDIF.
    LOOP AT it_dir2 TRANSPORTING NO FIELDS
                           WHERE alestat NE dart1_al_ok.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 0.
*     not all files are exported correctly before
      CALL FUNCTION 'POPUP_TO_DECIDE'
        EXPORTING
          textline1    = text-e01
          textline2    = text-e02
          textline3    = text-e03
          text_option1 = text-e11
          text_option2 = text-e12
          titel        = text-q01
        IMPORTING
          answer       = l_answer.
      CASE l_answer.
        WHEN '1'.                      "export failed files only
          c_failed_only = 'X'.
        WHEN '2'.                      "export all files (again)
          CLEAR c_failed_only.
        WHEN 'A'.                      "cancel
          RAISE canceled_by_user.
      ENDCASE.
    ELSE.
*     all files were exported correctly before
      IF i_obj_type = 'E'.
        l_text = text-c01.
      ELSE.
        l_text = text-c03.
      ENDIF.
      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
        EXPORTING
          defaultoption = 'N'
          textline1     = l_text
          textline2     = text-c02
          titel         = text-q01
        IMPORTING
          answer        = l_answer.
      IF l_answer = 'J'.
        CLEAR c_failed_only.
      ELSE.                   "do not export again - cancel
        RAISE canceled_by_user.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " CONFIRM_EXPORT
*&---------------------------------------------------------------------*
*&      Form  JOB_OPEN
*&---------------------------------------------------------------------*
*       open a batch job
*----------------------------------------------------------------------*
FORM job_open USING it_dir2 TYPE dart1_t_dir2
                    i_mode TYPE clike
           CHANGING c_jobname TYPE tbtcjob-jobname
                    c_jobnum TYPE tbtcjob-jobcount.

  DATA: ls_dir2 TYPE dart1_dir2.

* set jobname - export/import - program name - file
  READ TABLE it_dir2 INTO ls_dir2 INDEX 1.
  CONCATENATE i_mode 'P_' sy-cprog INTO c_jobname.
  CONCATENATE c_jobname ls_dir2-l_file INTO c_jobname
                      SEPARATED BY space.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname  = c_jobname
    IMPORTING
      jobcount = c_jobnum.


ENDFORM.                    " JOB_OPEN
*&---------------------------------------------------------------------*
*&      Form  JOB_CLOSE
*&---------------------------------------------------------------------*
*       schedule/close the job
*----------------------------------------------------------------------*
FORM job_close  USING i_jobname TYPE tbtcjob-jobname
                      i_jobnum TYPE tbtcjob-jobcount
                      i_count TYPE i
             CHANGING c_subrc TYPE sy-subrc.

  DATA: lt_steps TYPE TABLE OF tbtcstep.

  CLEAR c_subrc.

  IF i_count EQ 0.
* do not schedule - delete this job
    CALL FUNCTION 'BP_JOB_DELETE'
      EXPORTING
        jobcount = i_jobnum
        jobname  = i_jobname
      EXCEPTIONS
        OTHERS   = 0.
    c_subrc = 2.
    EXIT.
  ENDIF.

* schedule batch job
  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      jobcount     = i_jobnum
      jobname      = i_jobname
      dont_release = 'X'
    EXCEPTIONS
      OTHERS       = 0.

  CALL FUNCTION 'BP_JOB_MODIFY'
    EXPORTING
      dialog              = 'Y'
      jobcount            = i_jobnum
      jobname             = i_jobname
      opcode              = 16
    TABLES
      new_steplist        = lt_steps
    EXCEPTIONS
*                       message handling with note 1476424
      CANT_DERELEASE_JOB         = 01
      CANT_ENQ_JOB               = 02
      CANT_READ_JOBDATA          = 03
      CANT_RELEASE_JOB           = 04
      CANT_SET_JOBSTATUS_IN_DB   = 05
      CANT_START_JOB_IMMEDIATELY = 06
      CANT_UPDATE_JOBDATA        = 07
      EVENTCNT_GENERATION_ERROR  = 08
      INVALID_DIALOG_TYPE        = 09
      INVALID_NEW_JOBDATA        = 10
      INVALID_NEW_JOBSTATUS      = 11
      INVALID_OPCODE             = 12
      INVALID_STARTDATE          = 13
      JOB_EDIT_FAILED            = 14
      JOB_MODIFY_CANCELED        = 15
      JOB_NOT_MODIFIABLE_ANYMORE = 16
      NOTHING_TO_DO              = 17
      NO_BATCH_ON_TARGET_HOST    = 18
      NO_BATCH_SERVER_FOUND      = 19
      NO_BATCH_WP_FOR_JOBCLASS   = 20
      NO_MODIFY_PRIVILEGE_GIVEN  = 21
      NO_RELEASE_PRIVILEGE_GIVEN = 22
      NO_STARTDATE_NO_RELEASE    = 23
      TARGET_HOST_NOT_DEFINED    = 24
      TGT_HOST_CHK_HAS_FAILED    = 25
      OTHERS                     = 99.

  IF sy-subrc EQ 0.
*  ok
  ELSEIF sy-subrc = 15.                                   "H1476424
* do not schedule - delete this job
    CALL FUNCTION 'BP_JOB_DELETE'
      EXPORTING
        jobcount = i_jobnum
        jobname  = i_jobname
      EXCEPTIONS
        OTHERS   = 0.
    c_subrc = 4.
    EXIT.
*    RAISE canceled_by_user.
  ELSE.
*   major error - delete the job                          "H1476424
    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        arbgb = 'XW'
        msgty = 'E'
        msgv1 = i_jobname
        msgv2 = sy-subrc
        txtnr = '240'.
    if 1 = 2.        " just as reference
      MESSAGE e240(xw) with i_jobname sy-subrc.
    endif.
    CALL FUNCTION 'BP_JOB_DELETE'
      EXPORTING
        jobcount = i_jobnum
        jobname  = i_jobname
      EXCEPTIONS
        OTHERS   = 0.
    c_subrc = 8.                                          "H1476424
    EXIT.
  ENDIF.
  COMMIT WORK.

ENDFORM.                    " JOB_CLOSE
*&---------------------------------------------------------------------*
*&      Form  JOB_STEPS_INSERT_EX
*&---------------------------------------------------------------------*
*       insert a step per file to the batch job
*----------------------------------------------------------------------*
FORM job_steps_insert_ex USING it_dir2 TYPE dart1_t_dir2
                               i_jobname TYPE tbtcjob-jobname
                               i_jobnum TYPE tbtcjob-jobcount
                               i_failed_only TYPE char1
                               i_obj_type TYPE char1
                               i_mode TYPE char1
                      CHANGING c_count TYPE i.

  DATA: l_bus4010 TYPE dart1_bo_extract_key,
        l_al_obj_id TYPE sapb-sapobjid,
        l_al_path TYPE sapb-sappfad,
        l_file_name TYPE txw_dir2-file_name,
        l_type TYPE toaom-ar_object,
        l_sobj TYPE toaom-sap_object,
        l_subrc TYPE sy-subrc.

  FIELD-SYMBOLS: <ls_dir2> TYPE dart1_dir2.

  LOOP AT it_dir2 ASSIGNING <ls_dir2>.
    IF i_failed_only = 'X' AND <ls_dir2>-alestat = dart1_al_ok.
      CONTINUE.
    ENDIF.

*   get object id (for views FILE_UUID is stored in XTRCT_UUID also)
    MOVE-CORRESPONDING <ls_dir2> TO l_bus4010.
    l_al_obj_id = l_bus4010.
    PERFORM archiv_object_get USING i_obj_type
                                    'EX'
                                    <ls_dir2>-xtrct_uuid
                                    <ls_dir2>-vol_set
                           CHANGING l_sobj
                                    l_type.

*   get achiv link path
    PERFORM archiv_link_path_get USING <ls_dir2>
                                      i_obj_type
                             CHANGING l_al_path
                                      l_file_name.

*   check, if file still is available
    PERFORM file_existence_check USING l_al_path
                                       'X'
                              CHANGING l_subrc.
    IF l_subrc NE 0.
      CONTINUE.
    ENDIF.

*   set archiv SUBRC
    PERFORM set_al_subrc USING l_al_path
                               'EX'
                               l_sobj
                               l_type
                               l_file_name
                      CHANGING l_subrc.
    IF l_subrc NE 0.
      CONTINUE.
    ENDIF.

*   check, if file is still in an archiv process - update DB flags
    PERFORM archiv_status_update USING <ls_dir2>
                                       i_obj_type
                                       l_file_name
                                       'EX'
                              CHANGING l_subrc.
    IF l_subrc NE 0.
      CONTINUE.
    ENDIF.

*   delete links for this file that already exist
    PERFORM delete_links USING l_al_obj_id
                               l_file_name
                               i_obj_type.
    IF NOT i_jobnum IS INITIAL.
*     send file to archive (synchronous command via job)
      SUBMIT rtxwlgex VIA JOB i_jobname NUMBER i_jobnum AND RETURN
               WITH p_sobj = l_sobj
               WITH p_obj_id = l_al_obj_id
               WITH p_path = l_al_path
               WITH p_type = l_type.
    ELSE.
*     send file to archive (synchronous command directly)
      SUBMIT rtxwlgex AND RETURN
               WITH p_sobj = l_sobj
               WITH p_obj_id = l_al_obj_id
               WITH p_path = l_al_path
               WITH p_type = l_type.
    ENDIF.

*   send message
    PERFORM message_send_ex_im USING <ls_dir2>
                                     i_obj_type
                                     l_file_name
                                     l_al_path
                                     'EX'
                                     i_mode.

*   add step count
    c_count = c_count + 1.

  ENDLOOP.

ENDFORM.                    " JOB_STEPS_INSERT_EX
*&---------------------------------------------------------------------*
*&      Form  DELETE_LINKS
*&---------------------------------------------------------------------*
*       Delete already existing link table entries
*----------------------------------------------------------------------*
FORM delete_links  USING  i_al_obj_id TYPE sapb-sapobjid
                          i_file_name TYPE txw_dir2-file_name
                          i_obj_type TYPE char1.

  DATA: lt_toaco TYPE TABLE OF toaco,
        lt_links TYPE TABLE OF toa01,
        l_obj_type_id TYPE toaom-sap_object.

  FIELD-SYMBOLS: <ls_toaco> TYPE toaco.

  IF i_obj_type = 'E'.
    l_obj_type_id = dart1_bo_dart_extract.
  ELSE.
    l_obj_type_id = dart1_bo_dart_view.
  ENDIF.

* process each available link table
  SELECT * FROM toaco INTO TABLE lt_toaco.
  LOOP AT lt_toaco ASSIGNING <ls_toaco>.
    SELECT * FROM (<ls_toaco>-connection) INTO TABLE lt_links
           WHERE sap_object = l_obj_type_id
             AND object_id = i_al_obj_id.
    IF NOT lt_links[] IS INITIAL.
      DELETE (<ls_toaco>-connection) FROM TABLE lt_links.
      CALL FUNCTION 'MESSAGE_STORE'
        EXPORTING
          arbgb = 'XW'
          msgty = 'I'
          msgv1 = i_file_name
          txtnr = '271'.
      IF 1 = 2.                        "just for message reference
        MESSAGE s271(xw) WITH i_file_name.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " DELETE_LINKS
*&---------------------------------------------------------------------*
*&      Form  SET_AL_SUBRC
*&---------------------------------------------------------------------*
*       Set SUBRC for archiv link
*----------------------------------------------------------------------*
FORM set_al_subrc  USING    i_path TYPE sapb-sappfad
                            i_mode TYPE clike
                            i_obj_type TYPE toaom-sap_object
                            i_doc_type TYPE toaom-ar_object
                            i_file_name TYPE txw_dir2-file_name
                   CHANGING c_subrc TYPE sy-subrc.

  DATA: l_archivid LIKE toav0-archiv_id,
        l_basicpath LIKE sapb-sappfad,
        l_archivpath LIKE  sapb-sappfad,
        l_length TYPE i,
        l_lengthpath TYPE i,
        l_diff TYPE i.

  CLEAR c_subrc.

  CALL FUNCTION 'ARCHIV_CONNECTDEFINITION_GET'
    EXPORTING
      objecttype    = i_obj_type
      documenttype  = i_doc_type
      client        = sy-mandt
    IMPORTING
      archivid      = l_archivid
    EXCEPTIONS
      nothing_found = 2
      OTHERS        = 9.

  IF sy-subrc <> 0.
    c_subrc = sy-subrc.
*   add a message
    PERFORM al_subrc_message USING c_subrc i_file_name i_mode.
    EXIT.
  ENDIF.

  CALL FUNCTION 'ARCHIV_GET_ARCHIVINFOS'
    EXPORTING
      archiv_id                = l_archivid
    IMPORTING
      phys_basicpath           = l_basicpath
      phys_archivpath          = l_archivpath
    EXCEPTIONS
      error_communicationtable = 2
      OTHERS                   = 9.

  IF sy-subrc <> 0.
    c_subrc = sy-subrc.
*   add a message
    PERFORM al_subrc_message USING c_subrc i_file_name i_mode.
    EXIT.
  ENDIF.

  IF i_mode EQ 'EX'.
    l_length = STRLEN( l_basicpath ).
    IF i_path(l_length) NE l_basicpath.
      c_subrc = 5.
*     add a message
      PERFORM al_subrc_message USING c_subrc i_file_name i_mode.
      EXIT.
    ENDIF.
  ELSEIF i_mode EQ 'IM'.
    l_length = STRLEN( l_archivpath ).
    IF i_path(l_length) NE l_archivpath.
      c_subrc = 5.
*     add a message
      PERFORM al_subrc_message USING c_subrc i_file_name i_mode.
      EXIT.
    ENDIF.
  ENDIF.

  l_lengthpath = STRLEN( i_path ).
  l_diff = l_lengthpath - l_length.
  WHILE i_path+l_length(1) = '/' AND c_subrc = 0.
    l_length = l_length + 1.
    l_diff = l_diff - 1.
    IF l_diff <= 0.
      c_subrc = 5.
*     add a message
      PERFORM al_subrc_message USING c_subrc i_file_name i_mode.
      EXIT.
    ENDIF.
  ENDWHILE.

ENDFORM.                    " SET_AL_SUBRC
*&---------------------------------------------------------------------*
*&      Form  DIRECT_ARCHIVE_EXPORT
*&---------------------------------------------------------------------*
*       execute the export to archive directly/synchronous
*----------------------------------------------------------------------*
FORM direct_archive_export  USING i_obj_type TYPE char1
                                  it_uuid TYPE txw_t_uuid
                                  i_mode TYPE char1
                                  i_voldir TYPE txw_volset
                                  i_rerun TYPE txw_repeat_export
                                  i_failed_only TYPE txw_repeat_export.

  DATA: lt_dir2 TYPE dart1_t_dir2,
        l_failed_only TYPE char1,
        l_jobname TYPE tbtcjob-jobname,
        l_jobnum TYPE tbtcjob-jobcount,
        l_count TYPE i.

* get all files for the object
  PERFORM dir2_get_ex USING i_obj_type
                            it_uuid
                            i_voldir
                   CHANGING lt_dir2.

* confirm export to archive - online only
  PERFORM confirm_export USING i_obj_type
                               lt_dir2
                               i_rerun
                               i_failed_only
                      CHANGING l_failed_only.

* initialize message handler
  CALL FUNCTION 'MESSAGES_INITIALIZE'.

* export extract/view files (job is initial!)
  PERFORM job_steps_insert_ex USING lt_dir2
                                    l_jobname
                                    l_jobnum
                                    l_failed_only
                                    i_obj_type
                                    i_mode
                           CHANGING l_count.

* show messages
  CALL FUNCTION 'MESSAGES_STOP'
    EXCEPTIONS
      OTHERS = 0.
  CALL FUNCTION 'MESSAGES_SHOW'
    EXPORTING
      show_linno = ' '
      object     = text-030.

ENDFORM.                    " DIRECT_ARCHIVE_EXPORT
*&---------------------------------------------------------------------*
*&      Form  DIR2_GET_EX_EXTRACT
*&---------------------------------------------------------------------*
*       get all files that belong to the selected extract
*----------------------------------------------------------------------*
FORM dir2_get_ex_extract USING i_batch TYPE sy-batch
                               it_uuid TYPE txw_t_uuid
                               i_voldir TYPE txw_volset
                      CHANGING ct_dir2 TYPE dart1_t_dir2.

  DATA: ls_diral2 TYPE txw_diral2,
        lt_dir2 TYPE dart1_t_dir2,
        ls_dir2 TYPE dart1_dir2,
        l_answer TYPE char1.

  FIELD-SYMBOLS: <ls_dir2> TYPE dart1_dir2,
                 <ls_obj> TYPE txw_s_uuid.

  LOOP AT it_uuid ASSIGNING <ls_obj>.
    CLEAR lt_dir2.
    SELECT SINGLE * FROM txw_dir2 INTO ls_dir2
                           WHERE xtrct_uuid = <ls_obj>-uuid
                             AND vol_id = 00.
    IF sy-subrc NE 0.
      RAISE wrong_call.
    ENDIF.
*   open the extract file for reading - check if files are available
    CALL FUNCTION 'TXW_EXTRACT_READ_INIT'
      EXPORTING
        file_name  = ls_dir2-l_file
        voldir_set = i_voldir
      TABLES
        t_txw_dir2 = lt_dir2
      EXCEPTIONS
        OTHERS     = 8.
    IF sy-subrc <> 0 AND i_batch IS INITIAL.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
        EXPORTING
          defaultoption = 'N'
          textline1     = text-d01
          textline2     = text-d02
          titel         = text-q01
        IMPORTING
          answer        = l_answer.
      CALL FUNCTION 'TXW_EXTRACT_READ_CLOSE'.
      IF l_answer = 'J'.
        REFRESH lt_dir2.
        SELECT * FROM txw_dir2 INTO TABLE lt_dir2
                               WHERE xtrct_uuid = <ls_obj>-uuid.
      ELSE.
        RAISE canceled_by_user.
      ENDIF.
    ELSEIF sy-subrc <> 0. "SY-BATCH = 'X'
*   batch processing - stop with error message
      CALL FUNCTION 'TXW_EXTRACT_READ_CLOSE'.
      MESSAGE e203(xw) WITH ls_dir2-l_file.
    ELSE.
* update the ALE/ALI informations...
      LOOP AT lt_dir2 ASSIGNING <ls_dir2>.
        SELECT SINGLE * FROM txw_dir2 INTO ls_dir2
                     WHERE xtrct_uuid = <ls_dir2>-xtrct_uuid
                       AND vol_id = <ls_dir2>-vol_id.
        <ls_dir2>-aleuser = ls_dir2-aleuser.
        <ls_dir2>-aledate = ls_dir2-aledate.
        <ls_dir2>-aletime = ls_dir2-aletime.
        <ls_dir2>-alestat = ls_dir2-alestat.
        <ls_dir2>-x_ale   = ls_dir2-x_ale.
        <ls_dir2>-aliuser = ls_dir2-aliuser.
        <ls_dir2>-alidate = ls_dir2-alidate.
        <ls_dir2>-alitime = ls_dir2-alitime.
        <ls_dir2>-alistat = ls_dir2-alistat.
        <ls_dir2>-x_ali   = ls_dir2-x_ali.
        <ls_dir2>-deluser = ls_dir2-deluser.
        <ls_dir2>-deldate = ls_dir2-deldate.
        <ls_dir2>-deltime = ls_dir2-deltime.
      ENDLOOP.
    ENDIF.
    CALL FUNCTION 'TXW_EXTRACT_READ_CLOSE'.

* add the entry for the _DR-file
    SELECT SINGLE * FROM txw_diral2 INTO ls_diral2
                           WHERE xtrct_uuid = <ls_obj>-uuid
                             AND vol_id = 99.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_diral2 TO ls_dir2.
    ELSE.
*   no TXW_DIRAL2 entry exists rigth now - create one
      READ TABLE lt_dir2 INTO ls_dir2
                     WITH KEY xtrct_uuid = <ls_obj>-uuid
                              vol_id     = 00.
      ls_dir2-vol_id = 99.
      MOVE-CORRESPONDING ls_dir2 TO ls_diral2.
      CALL FUNCTION 'TXW_FILE_NAME_GET'
        EXPORTING
          voldir_set   = ls_dir2-vol_set
          vol_id       = 'DR'
          log_filename = ls_dir2-l_file
        IMPORTING
          phy_filename = ls_diral2-file_name.
      INSERT txw_diral2 FROM ls_diral2.
      COMMIT WORK.
    ENDIF.
    APPEND ls_dir2 TO lt_dir2.
    APPEND LINES OF lt_dir2 TO ct_dir2.
  ENDLOOP.
* use the input directory - clear out the FILE_NAME
  LOOP AT ct_dir2 ASSIGNING <ls_dir2>.
    <ls_dir2>-vol_set = i_voldir.
    CLEAR <ls_dir2>-file_name.
  ENDLOOP.


ENDFORM.                    " DIR2_GET_EX_EXTRACT
*&---------------------------------------------------------------------*
*&      Form  DIR2_GET_EX_VIEW
*&---------------------------------------------------------------------*
*       get all files that belong to the selected view
*----------------------------------------------------------------------*
FORM dir2_get_ex_view USING it_uuid TYPE txw_t_uuid
                            i_voldir TYPE txw_volset
                   CHANGING ct_dir2 TYPE dart1_t_dir2.

  DATA: lt_vwlog2 TYPE TABLE OF txw_vwlog2,
        ls_vwlogal2 TYPE txw_vwlogal2,
        ls_vwlog2 TYPE txw_vwlog2,
        ls_dir2 TYPE dart1_dir2,
        l_subrc TYPE sy-subrc.

  FIELD-SYMBOLS: <ls_vwlog2> TYPE txw_vwlog2,
                 <ls_obj> TYPE txw_s_uuid.

  LOOP AT it_uuid ASSIGNING <ls_obj>.
    SELECT * FROM txw_vwlog2 APPENDING TABLE lt_vwlog2
                           WHERE file_uuid = <ls_obj>-uuid.
    IF sy-subrc NE 0.
      RAISE wrong_call.
    ENDIF.
*   add the entries for the _MT-files
    SELECT SINGLE * FROM txw_vwlogal2 INTO ls_vwlogal2
                           WHERE file_uuid = <ls_obj>-uuid
                             AND vol_id = 99.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_vwlogal2 TO ls_vwlog2.          "#EC ENHOK
      APPEND ls_vwlog2 TO lt_vwlog2.
    ELSE.
*     no TXW_VWLOGAL2 entry exists rigth now - create one
      READ TABLE lt_vwlog2 INTO ls_vwlog2
                            WITH KEY file_uuid = <ls_obj>-uuid
                                     vol_id    = 00.
      ls_vwlog2-vol_id = 99.
      MOVE-CORRESPONDING ls_vwlog2 TO ls_vwlogal2.          "#EC ENHOK
      CALL FUNCTION 'TXW_FILE_NAME_GET'
        EXPORTING
          voldir_set   = ls_vwlogal2-vol_set
          vol_id       = 'MT'
          log_filename = ls_vwlogal2-l_file
        IMPORTING
          phy_filename = ls_vwlogal2-file_name.
*     check if the file exists
      PERFORM file_existence_check USING ls_vwlogal2-file_name
                                         space
                                CHANGING l_subrc.
      IF l_subrc = 0.
        INSERT txw_vwlogal2 FROM ls_vwlogal2.
        COMMIT WORK.
        APPEND ls_vwlog2 TO lt_vwlog2.
      ELSE.
*       maybe the file was moved - check with I_VOLDIR
        CLEAR ls_vwlogal2-file_name.
        ls_vwlogal2-vol_set = i_voldir.
        CALL FUNCTION 'TXW_FILE_NAME_GET'
          EXPORTING
            voldir_set   = ls_vwlogal2-vol_set
            vol_id       = 'MT'
            log_filename = ls_vwlogal2-l_file
          IMPORTING
            phy_filename = ls_vwlogal2-file_name.
*       check if the file exists
        PERFORM file_existence_check USING ls_vwlogal2-file_name
                                           space
                                  CHANGING l_subrc.
        IF l_subrc = 0.
          INSERT txw_vwlogal2 FROM ls_vwlogal2.
          COMMIT WORK.
          APPEND ls_vwlog2 TO lt_vwlog2.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

* move the view file informations to corresponding DIR2 fields.
  LOOP AT lt_vwlog2 ASSIGNING <ls_vwlog2>.
    CLEAR ls_dir2.
    MOVE-CORRESPONDING <ls_vwlog2> TO ls_dir2.
*   for views use the view file UUID similar to the extract UUID
    ls_dir2-xtrct_uuid = <ls_vwlog2>-file_uuid.
    ls_dir2-vol_set = i_voldir.
    APPEND ls_dir2 TO ct_dir2.
  ENDLOOP.

ENDFORM.                    " DIR2_GET_EX_VIEW
*&---------------------------------------------------------------------*
*&      Form  ARCHIV_LINK_PATH_GET
*&---------------------------------------------------------------------*
*       get the path for the file
*----------------------------------------------------------------------*
FORM archiv_link_path_get USING is_dir2 TYPE txw_dir2
                                i_obj_type TYPE char1
                       CHANGING c_al_path TYPE sapb-sappfad
                                c_file_name TYPE txw_dir2-file_name.

  DATA: l_vol_id(2) TYPE c.

* get volume id
  IF is_dir2-vol_id = '99' AND i_obj_type = 'E'.
    l_vol_id = 'DR'.
  ELSEIF is_dir2-vol_id = '99' AND i_obj_type = 'V'.
    l_vol_id = 'MT'.
  ELSEIF is_dir2-vol_id = '00'.
    l_vol_id = space.
  ELSE.
    l_vol_id = is_dir2-vol_id.
  ENDIF.

* get file name with path
  CALL FUNCTION 'TXW_FILE_NAME_GET'
    EXPORTING
      voldir_set         = is_dir2-vol_set
      vol_id             = l_vol_id
      log_filename       = is_dir2-l_file
    IMPORTING
      logical_volid_name = c_file_name
      phy_filename       = c_al_path
    EXCEPTIONS
      OTHERS             = 0.

ENDFORM.                    " ARCHIV_LINK_PATH_GET
*&---------------------------------------------------------------------*
*&      Form  ARCHIV_STATUS_UPDATE
*&---------------------------------------------------------------------*
*       set flag 'file scheduled for archive'
*----------------------------------------------------------------------*
FORM archiv_status_update  USING is_dir2 TYPE txw_dir2
                                 i_obj_type TYPE char1
                                 i_file_name TYPE txw_dir2-file_name
                                 i_mode TYPE clike
                        CHANGING c_subrc TYPE sy-subrc.

  IF i_mode = 'EX'.
*   set export flag
    IF is_dir2-vol_id = '99' AND i_obj_type = 'E'.
      UPDATE txw_diral2 SET x_ale = 'X'
             WHERE xtrct_uuid = is_dir2-xtrct_uuid
               AND vol_id     = is_dir2-vol_id
               AND x_ale      = space
               AND x_ali      = space.
    ELSEIF i_obj_type = 'E'.
      UPDATE txw_dir2 SET x_ale = 'X'
                          vol_set = is_dir2-vol_set       "H1558600
               WHERE xtrct_uuid = is_dir2-xtrct_uuid
                 AND vol_id     = is_dir2-vol_id
                 AND x_ale      = space
                 AND x_ali      = space.
    ELSEIF is_dir2-vol_id = '99' AND i_obj_type = 'V'.
      UPDATE txw_vwlogal2 SET x_ale = 'X'
                              vol_set = is_dir2-vol_set   "H1558600
             WHERE file_uuid = is_dir2-xtrct_uuid
               AND vol_id    = is_dir2-vol_id
               AND x_ale     = space
               AND x_ali     = space.
    ELSEIF i_obj_type = 'V'.
      UPDATE txw_vwlog2 SET x_ale = 'X'
                            vol_set = is_dir2-vol_set     "H1558600
             WHERE file_uuid = is_dir2-xtrct_uuid
               AND vol_id    = is_dir2-vol_id
               AND x_ale     = space
               AND x_ali     = space.
    ENDIF.
  ELSEIF i_mode = 'IM'.
*   set import flag
    IF is_dir2-vol_id = '99' AND i_obj_type = 'E'.
      UPDATE txw_diral2 SET x_ali = 'X'
             WHERE xtrct_uuid = is_dir2-xtrct_uuid
               AND vol_id     = is_dir2-vol_id
               AND x_ale      = space
               AND x_ali      = space.
    ELSEIF i_obj_type = 'E'.
      UPDATE txw_dir2 SET x_ali = 'X'
                          vol_set = is_dir2-vol_set       "H1558600
               WHERE xtrct_uuid = is_dir2-xtrct_uuid
                 AND vol_id     = is_dir2-vol_id
                 AND x_ale      = space
                 AND x_ali      = space.
    ELSEIF is_dir2-vol_id = '99' AND i_obj_type = 'V'.
      UPDATE txw_vwlogal2 SET x_ali = 'X'
                              vol_set = is_dir2-vol_set   "H1558600
             WHERE file_uuid = is_dir2-xtrct_uuid
               AND vol_id    = is_dir2-vol_id
               AND x_ale     = space
               AND x_ali     = space.
    ELSEIF i_obj_type = 'V'.
      UPDATE txw_vwlog2 SET x_ali = 'X'
                            vol_set = is_dir2-vol_set     "H1558600
             WHERE file_uuid = is_dir2-xtrct_uuid
               AND vol_id    = is_dir2-vol_id
               AND x_ale     = space
               AND x_ali     = space.
    ENDIF.
  ENDIF.
  c_subrc = sy-subrc.
  IF c_subrc NE 0.
*     file is used in other archiv process
    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        arbgb = 'XW'
        msgty = 'E'
        msgv1 = i_file_name
        txtnr = '272'.
    IF 1 = 2.              "just for message reference
      MESSAGE s272(xw) WITH i_file_name.
    ENDIF.
  ELSE.
    COMMIT WORK.
  ENDIF.


ENDFORM.                    " ARCHIV_STATUS_UPDATE
*&---------------------------------------------------------------------*
*&      Form  DIR2_GET_IM
*&---------------------------------------------------------------------*
*   get all the files for the actual object (IMPORT)
*   in case of extract you can find this information in TXW_DIR2
*        and TXW_DIRAL2
*   in case of views the information is selected from TXW_VWLOG2
*        and TXW_VWLOGAL2
*   in all cases the information is mapped to a table of structure
*   TXW_DIR2 - later on only the XTRCT_UUID, the VOL_ID, the VOL_SET
*   and the achive parameters are used!
*----------------------------------------------------------------------*
FORM dir2_get_im USING  i_obj_type TYPE char1
                        it_uuid TYPE txw_t_uuid
                        i_voldir TYPE txw_volset
               CHANGING ct_dir2 TYPE dart1_t_dir2.

  REFRESH ct_dir2.

  CASE i_obj_type.
    WHEN 'E'.
*     get files for selected extract
      PERFORM dir2_get_im_extract USING i_obj_type
                                        it_uuid
                                        i_voldir
                               CHANGING ct_dir2.

    WHEN 'V'.
*     get files for selected view query
      PERFORM dir2_get_im_view USING i_obj_type
                                     it_uuid
                                     i_voldir
                            CHANGING ct_dir2.

  ENDCASE.
  SORT ct_dir2 BY xtrct_uuid vol_id.

ENDFORM.                                                 " DIR2_GET_EX
*&---------------------------------------------------------------------*
*&      Form  DIR2_GET_IM_EXTRACT
*&---------------------------------------------------------------------*
*       get all files that belong to the selected extract
*----------------------------------------------------------------------*
FORM dir2_get_im_extract USING i_obj_type TYPE char1
                               it_uuid TYPE txw_t_uuid
                               i_voldir TYPE txw_volset
                      CHANGING ct_dir2 TYPE dart1_t_dir2.

  DATA: ls_diral2 TYPE txw_diral2,
        ls_dir2 TYPE dart1_dir2,
        l_al_path TYPE sapb-sappfad.

  FIELD-SYMBOLS: <ls_dir2> TYPE dart1_dir2,
                 <ls_obj> TYPE txw_s_uuid.

  LOOP AT it_uuid ASSIGNING <ls_obj>.
* get the files for the extract
    SELECT * FROM txw_dir2 APPENDING TABLE ct_dir2
                           WHERE xtrct_uuid = <ls_obj>-uuid.
    IF sy-subrc NE 0.
      RAISE wrong_call.
    ENDIF.

* add the entry for the _DR-file
    SELECT SINGLE * FROM txw_diral2 INTO ls_diral2
                           WHERE xtrct_uuid = <ls_obj>-uuid
                             AND vol_id = 99.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_diral2 TO ls_dir2.
      APPEND ls_dir2 TO ct_dir2.
    ENDIF.
  ENDLOOP.

* use the input directory - set FILE_NAME
  LOOP AT ct_dir2 ASSIGNING <ls_dir2>.
    <ls_dir2>-vol_set = i_voldir.
    CLEAR <ls_dir2>-file_name.
    PERFORM archiv_link_path_get USING <ls_dir2>
                                       i_obj_type
                              CHANGING l_al_path
                                       <ls_dir2>-file_name.
  ENDLOOP.

ENDFORM.                    " DIR2_GET_IM_EXTRACT
*&---------------------------------------------------------------------*
*&      Form  DIR2_GET_IM_VIEW
*&---------------------------------------------------------------------*
*       get all files that belong to the selected view
*----------------------------------------------------------------------*
FORM dir2_get_im_view USING i_obj_type TYPE char1
                            it_uuid TYPE txw_t_uuid
                            i_voldir TYPE txw_volset
                   CHANGING ct_dir2 TYPE dart1_t_dir2.

  DATA: lt_vwlog2 TYPE TABLE OF txw_vwlog2,
        ls_vwlog2 TYPE txw_vwlog2,
        ls_vwlogal2 TYPE txw_vwlogal2,
        l_al_path TYPE sapb-sappfad,
        ls_dir2 TYPE dart1_dir2.

  FIELD-SYMBOLS: <ls_vwlog2> TYPE txw_vwlog2,
                 <ls_obj> TYPE txw_s_uuid.

  LOOP AT it_uuid ASSIGNING <ls_obj>.
    REFRESH lt_vwlog2.
    SELECT * FROM txw_vwlog2 INTO TABLE lt_vwlog2
                             WHERE file_uuid = <ls_obj>-uuid.
    IF sy-subrc NE 0.
      RAISE wrong_call.
    ENDIF.

*   add the entry for the _MT-file
    SELECT SINGLE * FROM txw_vwlogal2 INTO ls_vwlogal2
                           WHERE file_uuid = <ls_obj>-uuid
                             AND vol_id = 99.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_vwlogal2 TO ls_vwlog2.          "#EC ENHOK
      APPEND ls_vwlog2 TO lt_vwlog2.
    ENDIF.

*   move the view file informations to corresponding DIR2 fields.
    LOOP AT lt_vwlog2 ASSIGNING <ls_vwlog2>.
      CLEAR ls_dir2.
      MOVE-CORRESPONDING <ls_vwlog2> TO ls_dir2.
*     for views use the view file UUID similar to the extract UUID
      ls_dir2-xtrct_uuid = <ls_vwlog2>-file_uuid.
      ls_dir2-vol_set = i_voldir.
      PERFORM archiv_link_path_get USING ls_dir2
                                         i_obj_type
                                CHANGING l_al_path
                                         ls_dir2-file_name.
      APPEND ls_dir2 TO ct_dir2.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " DIR2_GET_IM_VIEW
*&---------------------------------------------------------------------*
*&      Form  SCHEDULE_ARCHIVE_IMPORT
*&---------------------------------------------------------------------*
*       create/schedule a batch job for asynchronous import from
*       archive
*----------------------------------------------------------------------*
*      -->I_OBJ_TYPE  type of the object (extract or view)
*      -->I_OBJ_UUID  UUID of the object
*      -->I_VOLDIR  DART directory of the object
*----------------------------------------------------------------------*
FORM schedule_archive_import  USING i_obj_type TYPE char1
                                    it_uuid TYPE txw_t_uuid
                                    i_mode TYPE char1
                                    i_voldir TYPE txw_volset.

  DATA: lt_dir2 TYPE dart1_t_dir2,
        l_failed_only TYPE char1,
        l_dummy_rerun TYPE txw_repeat_export,
        l_dummy_failed TYPE txw_repeat_export,
        l_jobname TYPE tbtcjob-jobname,
        l_jobnum TYPE tbtcjob-jobcount,
        l_count TYPE i,
        l_subrc TYPE sy-subrc.

* get all files for the objects
  PERFORM dir2_get_im USING i_obj_type
                            it_uuid
                            i_voldir
                   CHANGING lt_dir2.

* confirm import from archive
  PERFORM confirm_import USING i_obj_type
                               lt_dir2
                               l_dummy_rerun
                               l_dummy_failed
                      CHANGING l_failed_only.

* check disk for freespace
  PERFORM freespace_check USING i_voldir
                                lt_dir2.

* initialize message handler
  CALL FUNCTION 'MESSAGES_INITIALIZE'.

* open batch job
  PERFORM job_open USING lt_dir2
                         'IM'
                CHANGING l_jobname
                         l_jobnum.

* insert import extract/view files as steps for the job
  PERFORM job_steps_insert_im USING lt_dir2
                                    l_jobname
                                    l_jobnum
                                    l_failed_only
                                    i_obj_type
                                    i_mode
                           CHANGING l_count.

* schedule batch job
  PERFORM job_close USING l_jobname
                          l_jobnum
                          l_count
                 CHANGING l_subrc.
  CASE l_subrc.
    WHEN 0.
*     ok
    WHEN 2.
*     no steps availabe - ok.
    WHEN 4.                                               "H1476424
*     SUBRC = 4 - job scheduling was canceled
      PERFORM archive_status_reset USING lt_dir2
                                         'IM'
                                         i_obj_type.
      RAISE canceled_by_user.
    WHEN OTHERS.                                          "H1476424
*     major error - error message already stored
      PERFORM archive_status_reset USING lt_dir2
                                         'IM'
                                         i_obj_type.
  ENDCASE.

* show messages
  CALL FUNCTION 'MESSAGES_STOP'
    EXCEPTIONS
      OTHERS = 0.
  CALL FUNCTION 'MESSAGES_SHOW'
    EXPORTING
      show_linno = ' '
      object     = text-030.

ENDFORM.                    " SCHEDULE_ARCHIVE_IMPORT
*&---------------------------------------------------------------------*
*&      Form  DIRECT_ARCHIVE_IMPORT
*&---------------------------------------------------------------------*
*       execute the import from archive directly/synchronous
*----------------------------------------------------------------------*
FORM direct_archive_import  USING i_obj_type TYPE char1
                                  it_uuid TYPE txw_t_uuid
                                  i_mode TYPE char1
                                  i_voldir TYPE txw_volset
                                  i_rerun TYPE txw_repeat_export
                                  i_failed_only TYPE txw_repeat_export.

  DATA: lt_dir2 TYPE dart1_t_dir2,
        l_failed_only TYPE char1,
        l_jobname TYPE tbtcjob-jobname,
        l_jobnum TYPE tbtcjob-jobcount,
        l_count TYPE i.

* get all files for the object
  PERFORM dir2_get_im USING i_obj_type
                            it_uuid
                            i_voldir
                   CHANGING lt_dir2.

  IF sy-batch IS INITIAL.
*   confirm export to archive - online only
    PERFORM confirm_import USING i_obj_type
                                 lt_dir2
                                 i_rerun
                                 i_failed_only
                        CHANGING l_failed_only.
  ENDIF.

* check disk for freespace
  PERFORM freespace_check USING i_voldir
                                lt_dir2.

* initialize message handler
  CALL FUNCTION 'MESSAGES_INITIALIZE'.

* import extract/view files (job is initial!)
  PERFORM job_steps_insert_im USING lt_dir2
                                    l_jobname
                                    l_jobnum
                                    l_failed_only
                                    i_obj_type
                                    i_mode
                           CHANGING l_count.

* show messages
  CALL FUNCTION 'MESSAGES_STOP'
    EXCEPTIONS
      OTHERS = 0.
  CALL FUNCTION 'MESSAGES_SHOW'
    EXPORTING
      show_linno = ' '
      object     = text-030.

ENDFORM.                    " DIRECT_ARCHIVE_EXPORT
*&---------------------------------------------------------------------*
*&      Form  CONFIRM_IMPORT
*&---------------------------------------------------------------------*
*       get a user confirmation for the import from archive
*----------------------------------------------------------------------*
FORM confirm_import  USING    i_obj_type TYPE char1
                              it_dir2 TYPE dart1_t_dir2
                              i_rerun TYPE txw_repeat_export
                              i_failed_only TYPE txw_repeat_export
                     CHANGING c_failed_only TYPE char1.

  DATA: ls_dir2 TYPE dart1_dir2,
        l_imported TYPE char1,
        l_answer TYPE char1,
        l_text(60) TYPE c,
        l_subrc TYPE sy-subrc.

* check if an import was done before.
  LOOP AT it_dir2 INTO ls_dir2
                  WHERE aliuser NE space.
    l_imported = 'X'.
    EXIT.
  ENDLOOP.

  IF l_imported = space.
*   not yet imported
    IF sy-batch = 'X'.
      EXIT.              "OK !
    ENDIF.
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        defaultoption = 'N'
        textline1     = text-b01
        textline2     = text-b02
        titel         = text-q02
      IMPORTING
        answer        = l_answer.
    IF l_answer NE 'J'.
      RAISE canceled_by_user.
    ENDIF.
    CLEAR: c_failed_only.
  ELSE.
*   was imported before
    IF sy-batch = 'X'.
      IF i_rerun = SPACE OR i_obj_type NE 'E'.
        MESSAGE e263(xw) WITH ls_dir2-l_file.
      ELSE.
*       re-run for batch (extracts only) should be executed
*       set flag for failed files
        c_failed_only = i_failed_only.
      ENDIF.
      EXIT.      "no further checks for batch processing
    ENDIF.
    LOOP AT it_dir2 TRANSPORTING NO FIELDS
                           WHERE alistat NE dart1_al_ok.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 0.
*     not all files are imported correctly before
      CALL FUNCTION 'POPUP_TO_DECIDE'
        EXPORTING
          textline1    = text-i01
          textline2    = text-i02
          textline3    = text-i03
          text_option1 = text-e11
          text_option2 = text-e12
          titel        = text-q02
        IMPORTING
          answer       = l_answer.
      CASE l_answer.
        WHEN '1'.                      "import failed files only
          c_failed_only = 'X'.
        WHEN '2'.                      "import all files (again)
          CLEAR c_failed_only.
        WHEN 'A'.                      "cancel
          RAISE canceled_by_user.
      ENDCASE.
    ELSE.
*     check if files are avialable
      LOOP AT it_dir2 INTO ls_dir2.
        PERFORM file_existence_check USING ls_dir2-file_name
                                           space
                                  CHANGING l_subrc.
        IF l_subrc NE 0.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF l_subrc = 0.
*       all files were imported correctly before
        IF i_obj_type = 'E'.
          l_text = text-c11.
        ELSE.
          l_text = text-c13.
        ENDIF.
        CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
          EXPORTING
            defaultoption = 'N'
            textline1     = l_text
            textline2     = text-c12
            titel         = text-q02
          IMPORTING
            answer        = l_answer.
        IF l_answer = 'J'.
          CLEAR c_failed_only.
        ELSE.                   "do not import again - cancel
          RAISE canceled_by_user.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " CONFIRM_IMPORT
*&---------------------------------------------------------------------*
*&      Form  FREESPACE_CHECK
*&---------------------------------------------------------------------*
*       check freespace for import
*----------------------------------------------------------------------*
FORM freespace_check  USING i_voldir TYPE txw_volset
                            it_dir2 TYPE dart1_t_dir2.

  DATA: l_file_size TYPE txw_fsize,
        l_freespace TYPE diskspace,
        l_answer TYPE char1.

  FIELD-SYMBOLS: <ls_dir2> TYPE dart1_dir2.

* get size of files
  LOOP AT it_dir2 ASSIGNING <ls_dir2>.
    l_file_size = l_file_size + <ls_dir2>-file_size.
  ENDLOOP.

* check if there is enough freespace on disk to retrieve from
  CALL FUNCTION 'TXW_FILEPATH_FREESPACE'
    EXPORTING
      voldir_set            = i_voldir
    IMPORTING
      free_space            = l_freespace
    EXCEPTIONS
      space_not_determined  = 1
      directory_set_invalid = 2
      OTHERS                = 3.
  IF sy-subrc = 1.
    MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSEIF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
*   test for 90% condition next
    MULTIPLY l_freespace BY 9.
    DIVIDE l_freespace BY 10.
    MULTIPLY l_freespace BY 1024.          "To kilobytes
    MULTIPLY l_freespace BY 1024.          "To bytes
    IF l_freespace <= l_file_size.
      IF sy-batch IS INITIAL.
        MESSAGE i097(xw) WITH l_freespace l_file_size.
      ELSE.
        MESSAGE e097(xw) WITH l_freespace l_file_size.
      ENDIF.
*     confirm import from archive
      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
        EXPORTING
          defaultoption = 'N'
          textline1     = text-f01
          textline2     = text-f02
          titel         = text-q02
        IMPORTING
          answer        = l_answer.
      IF l_answer NE 'J'.    "do not import - cancel
        RAISE canceled_by_user.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " FREESPACE_CHECK
*&---------------------------------------------------------------------*
*&      Form  JOB_STEPS_INSERT_IM
*&---------------------------------------------------------------------*
*       insert a step per file to the batch job
*----------------------------------------------------------------------*
FORM job_steps_insert_im USING it_dir2 TYPE dart1_t_dir2
                               i_jobname TYPE tbtcjob-jobname
                               i_jobnum TYPE tbtcjob-jobcount
                               i_failed_only TYPE char1
                               i_obj_type TYPE char1
                               i_mode TYPE char1
                      CHANGING c_count TYPE i.

  DATA: l_bus4010 TYPE dart1_bo_extract_key,
        l_al_obj_id TYPE sapb-sapobjid,
        l_al_path TYPE sapb-sappfad,
        l_file_name TYPE txw_dir2-file_name,
        l_type TYPE toaom-ar_object,
        l_sobj TYPE toaom-sap_object,
        l_subrc TYPE sy-subrc.


  FIELD-SYMBOLS: <ls_dir2> TYPE dart1_dir2.

  LOOP AT it_dir2 ASSIGNING <ls_dir2>.
    IF i_failed_only = 'X' AND <ls_dir2>-alistat = dart1_al_ok.
      CONTINUE.
    ENDIF.

*   get object id (for views FILE_UUID is stored in XTRCT_UUID also)
    MOVE-CORRESPONDING <ls_dir2> TO l_bus4010.
    l_al_obj_id = l_bus4010.
    PERFORM archiv_object_get USING i_obj_type
                                    'IM'
                                    <ls_dir2>-xtrct_uuid
                                    <ls_dir2>-vol_set
                           CHANGING l_sobj
                                    l_type.

*   get achiv link path
    PERFORM archiv_link_path_get USING <ls_dir2>
                                       i_obj_type
                              CHANGING l_al_path
                                       l_file_name.

*   set archiv SUBRC
    PERFORM set_al_subrc USING l_al_path
                               'IM'
                               l_sobj
                               l_type
                               l_file_name
                      CHANGING l_subrc.
    IF l_subrc NE 0.
      CONTINUE.
    ENDIF.

*   check, if file is still in an archiv process - update DB flags
*   if an error occure later on the DB flags need to be reset!
    PERFORM archiv_status_update USING <ls_dir2>
                                       i_obj_type
                                       l_file_name
                                       'IM'
                              CHANGING l_subrc.
    IF l_subrc NE 0.
      CONTINUE.
    ENDIF.

    IF NOT i_jobnum IS INITIAL.
*     send file to archive (synchronous command via job)
      SUBMIT rtxwlgim VIA JOB i_jobname NUMBER i_jobnum AND RETURN
               WITH p_sobj = l_sobj
               WITH p_obj_id = l_al_obj_id
               WITH p_path = l_al_path
               WITH p_type = l_type
               WITH p_volset = <ls_dir2>-vol_set.
    ELSE.
*     send file to archive (synchronous command directly)
      SUBMIT rtxwlgim AND RETURN
               WITH p_sobj = l_sobj
               WITH p_obj_id = l_al_obj_id
               WITH p_path = l_al_path
               WITH p_type = l_type
               WITH p_volset = <ls_dir2>-vol_set.
    ENDIF.

    UPDATE TXW_DIR2
        SET VOL_SET   = <ls_dir2>-vol_set
            FILE_NAME = l_al_path
        WHERE
            xtrct_uuid = <ls_dir2>-xtrct_uuid
        AND vol_id     = <ls_dir2>-vol_id.

*   send message
    PERFORM message_send_ex_im USING <ls_dir2>
                                     i_obj_type
                                     l_file_name
                                     l_al_path
                                     'IM'
                                     i_mode.

*   add step count
    c_count = c_count + 1.

  ENDLOOP.

  UPDATE TXW_DIRAL2
      SET FILE_NAME = l_al_path
      WHERE
          xtrct_uuid = <ls_dir2>-xtrct_uuid.

ENDFORM.                    " JOB_STEPS_INSERT_IM
*&---------------------------------------------------------------------*
*&      Form  AL_SUBRC_MESSAGE
*&---------------------------------------------------------------------*
*       send a message if there is some returncode
*----------------------------------------------------------------------*
FORM al_subrc_message  USING i_subrc TYPE sy-subrc
                             i_file_name TYPE txw_dir2-file_name
                             i_mode TYPE clike.

  IF i_mode = 'EX'.
    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        arbgb = 'XW'
        msgty = 'E'
        msgv1 = i_file_name
        msgv2 = i_subrc
        txtnr = '236'.
    IF 1 = 2.                          "just for message reference
      MESSAGE s236(xw) WITH i_file_name i_subrc.
    ENDIF.
  ELSEIF i_mode = 'IM'.
    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        arbgb = 'XW'
        msgty = 'E'
        msgv1 = i_file_name
        msgv2 = i_subrc
        txtnr = '238'.
    IF 1 = 2.                          "just for message reference
      MESSAGE s238(xw) WITH i_file_name i_subrc.
    ENDIF.

  ENDIF.

ENDFORM.                    " AL_SUBRC_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*       authority check for the called objects
*----------------------------------------------------------------------*
FORM authority_check  USING i_obj_type TYPE char1
                            i_mode TYPE clike
                            it_obj_uuid TYPE txw_t_uuid.

  DATA: l_tax_view TYPE txw_vwlog2-tax_view,
        l_activity TYPE tact-actvt,
        l_v_uuid     Type txw_vwlog2-file_uuid,              "H1490831
        ls_vwlog2_u  TYPE txw_vwlog2_u.                      "H1490831

* set activity
  IF i_mode = 'EX'.
    l_activity = dart1_act-archive_exp.
  ELSEIF i_mode = 'IM'.
    l_activity = dart1_act-archive_imp.
  ENDIF.

* do the check for the objects
  CASE i_obj_type.
    WHEN 'E'.
*     same check for each extract - only one check is needed
      AUTHORITY-CHECK OBJECT 'F_TXW_TF'
               ID 'ACTVT' FIELD l_activity
               ID 'BUKRS' DUMMY.
      IF sy-subrc <> 0.
        MESSAGE e011(xw).
      ENDIF.
    WHEN 'V'.
***--> Begin of Insert for OTC_EDD_0011 Hanatization by APODDAR
      IF it_obj_uuid IS NOT INITIAL.
***<-- End of Insert for OTC_EDD_0011 Hanatization by APODDAR
      SELECT tax_view file_uuid FROM txw_vwlog2              "H1490831
                 INTO (l_tax_view, l_v_uuid)                 "H1490831
                        FOR ALL ENTRIES IN it_obj_uuid
                   WHERE file_uuid = it_obj_uuid-uuid
                     AND vol_id = 00
                 GROUP BY tax_view file_uuid.                "H1490831

        IF l_tax_view = dart1_tax_view-associated_data.      "H1490831
          SELECT SINGLE * FROM txw_vwlog2_u INTO ls_vwlog2_u "H1490831
                 WHERE file_uuid = l_v_uuid.                 "H1490831
          CHECK sy-subrc IS INITIAL.                         "H1490831
          l_tax_view = ls_vwlog2_u-tax_view.                 "H1490831
        ENDIF.                                               "H1490831

        IF l_tax_view NE space.
          CALL FUNCTION 'TXW_DATA_VIEW_AUTHORITY_CHECK'
            EXPORTING
              activity  = l_activity
              data_view = l_tax_view.
        ENDIF.
      ENDSELECT.
***--> Begin of Insert for OTC_EDD_0011 Hanatization by APODDAR
      ENDIF.
***<-- End of Insert for OTC_EDD_0011 Hanatization by APODDAR
  ENDCASE.

ENDFORM.                    " AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*&      Form  ARCHIVE_STATUS_RESET
*&---------------------------------------------------------------------*
*       reset ArchiveLink status flags on DB
*----------------------------------------------------------------------*
FORM archive_status_reset  USING it_dir2 TYPE dart1_t_dir2
                                 i_mode TYPE clike
                                 i_obj_type TYPE char1.

  FIELD-SYMBOLS: <ls_dir2> TYPE dart1_dir2.

  LOOP AT it_dir2 ASSIGNING <ls_dir2>.
    AT NEW xtrct_uuid.
      IF i_mode = 'EX' AND i_obj_type = 'E'.
*       export status - extract
        UPDATE txw_dir2 SET x_ale = ' '
            WHERE xtrct_uuid = <ls_dir2>-xtrct_uuid
              AND x_ale = 'X'.
        UPDATE txw_diral2 SET x_ale = ' '
            WHERE xtrct_uuid = <ls_dir2>-xtrct_uuid
              AND x_ale = 'X'.
      ELSEIF i_mode = 'EX' AND i_obj_type = 'V'.
*       export status - view
        UPDATE txw_vwlog2 SET x_ale = ' '
            WHERE file_uuid = <ls_dir2>-xtrct_uuid
              AND x_ale = 'X'.
        UPDATE txw_vwlogal2 SET x_ale = ' '
            WHERE file_uuid = <ls_dir2>-xtrct_uuid
              AND x_ale = 'X'.
      ELSEIF i_mode = 'IM' AND i_obj_type = 'E'.
*       import status - extract
        UPDATE txw_dir2 SET x_ali = ' '
            WHERE xtrct_uuid = <ls_dir2>-xtrct_uuid
              AND x_ali = 'X'.
        UPDATE txw_diral2 SET x_ali = ' '
            WHERE xtrct_uuid = <ls_dir2>-xtrct_uuid
              AND x_ali = 'X'.
      ELSEIF i_mode = 'IM' AND i_obj_type = 'V'.
*       import status - view
        UPDATE txw_vwlog2 SET x_ali = ' '
            WHERE file_uuid = <ls_dir2>-xtrct_uuid
              AND x_ali = 'X'.
        UPDATE txw_vwlogal2 SET x_ali = ' '
            WHERE file_uuid = <ls_dir2>-xtrct_uuid
              AND x_ali = 'X'.
      ENDIF.
    ENDAT.
  ENDLOOP.
  COMMIT WORK.

ENDFORM.                    " ARCHIVE_STATUS_RESET
*&---------------------------------------------------------------------*
*&      Form  MESSAGE_SEND_EX_IM
*&---------------------------------------------------------------------*
*       send message for job step
*----------------------------------------------------------------------*
FORM message_send_ex_im  USING is_dir2 TYPE dart1_dir2
                               i_obj_type TYPE char1
                               i_file_name  TYPE txw_dir2-file_name
                               i_al_path TYPE sapb-sappfad
                               i_ex_im TYPE clike
                               i_mode TYPE char1.

  DATA: l_msgno TYPE sy-msgno,
        l_msgty TYPE sy-msgty,
        l_stat TYPE dart1_dir2-alestat.

  IF i_mode = 'J' AND i_ex_im = 'EX'.
*   schedule the file for exporting
    l_msgty = 'S'.
    l_msgno = 237.
  ELSEIF i_mode = 'D' AND i_ex_im = 'EX'.
*   file was exported directly - check result
    PERFORM archive_status_get USING is_dir2
                                     i_obj_type
                                     i_ex_im
                            CHANGING l_stat.
    IF l_stat = dart1_al_ok.
*     ok
      l_msgty = 'S'.
      l_msgno = 248.
    ELSE.
*     not ok
      l_msgty = 'W'.
      l_msgno = 264.
    ENDIF.
  ELSEIF i_mode = 'J' AND i_ex_im = 'IM'.
*   schedule the file for importing
    l_msgty = 'S'.
    l_msgno = 239.
  ELSEIF i_mode = 'D' AND i_ex_im = 'IM'.
*   file was imported directly - check result
    PERFORM archive_status_get USING is_dir2
                                     i_obj_type
                                     i_ex_im
                            CHANGING l_stat.
    IF l_stat = dart1_al_ok.
*     ok
      l_msgty = 'S'.
      l_msgno = 249.
    ELSE.
*     not ok
      l_msgty = 'W'.
      l_msgno = 265.
    ENDIF.
  ENDIF.
  CALL FUNCTION 'MESSAGE_STORE'
    EXPORTING
      arbgb = 'XW'
      msgty = l_msgty
      msgv1 = i_file_name
      msgv2 = i_al_path
      txtnr = l_msgno.
  IF 1 = 2.                          "just for message reference
    MESSAGE s237(xw) WITH i_file_name i_al_path.
    MESSAGE s239(xw) WITH i_file_name i_al_path.
    MESSAGE s248(xw) WITH i_file_name.
    MESSAGE s249(xw) WITH i_file_name.
    MESSAGE s264(xw) WITH i_file_name.
    MESSAGE s265(xw) WITH i_file_name.
  ENDIF.

ENDFORM.                    " MESSAGE_SEND_EX_IM
*&---------------------------------------------------------------------*
*&      Form  ARCHIVE_STATUS_GET
*&---------------------------------------------------------------------*
*       get archiv status of a file
*----------------------------------------------------------------------*
FORM archive_status_get  USING is_dir2 TYPE dart1_dir2
                               i_obj_type TYPE char1
                               i_ex_im TYPE clike
                      CHANGING c_stat TYPE dart1_dir2-alestat.

  DATA: l_field TYPE fieldname,
        l_table TYPE tabname,
        l_where(72) TYPE c.

* set table / field for selection
  IF i_ex_im = 'EX'.
    l_field = 'ALESTAT'.
  ELSE.
    l_field = 'ALISTAT'.
  ENDIF.
  IF i_obj_type = 'E' AND is_dir2-vol_id = '99'.
    l_table = 'TXW_DIRAL2'.
    l_where = 'XTRCT_UUID = is_dir2-xtrct_uuid'.        "#EC NOTEXT
  ELSEIF i_obj_type = 'E'.
    l_table = 'TXW_DIR2'.
    l_where = 'XTRCT_UUID = is_dir2-xtrct_uuid'.        "#EC NOTEXT
  ELSEIF i_obj_type = 'V' AND is_dir2-vol_id = '99'.
    l_table = 'TXW_VWLOGAL2'.
    l_where = 'FILE_UUID = is_dir2-xtrct_uuid'.         "#EC NOTEXT
  ELSEIF i_obj_type = 'V'.
    l_table = 'TXW_VWLOG2'.
    l_where = 'FILE_UUID = is_dir2-xtrct_uuid'.         "#EC NOTEXT
  ENDIF.

* do a dynamic selection
  SELECT SINGLE (l_field) FROM (l_table) INTO c_stat
                                 WHERE (l_where)
                                   AND vol_id = is_dir2-vol_id.
  IF sy-subrc NE 0.
    c_stat = '9999'.
  ENDIF.

ENDFORM.                    " ARCHIVE_STATUS_GET
*&---------------------------------------------------------------------*
*&      Form  ARCHIV_OBJECT_GET
*&---------------------------------------------------------------------*
*       get object informations for export/import
*----------------------------------------------------------------------*
form ARCHIV_OBJECT_GET  using    i_otype  TYPE char1
                                 i_mode   TYPE clike
                                 i_uuid   TYPE txw_uuid
                                 i_volset TYPE txw_volset
                        changing c_sobj   TYPE toaom-sap_object
                                 c_doc    TYPE toaom-ar_object.

  IF i_otype = 'E'.
*   get object informations for extract files
    c_sobj = dart1_bo_dart_extract.
    IF i_mode = 'IM'.
*     for import get information stored on DB
      SELECT SINGLE ar_object INTO c_doc FROM txw_diral2
                    WHERE xtrct_uuid = i_uuid
                      AND vol_id     = '99'.
    ELSE.
*     for export get information for the VOL_SET customizing
      SELECT SINGLE ar_object_extr INTO c_doc FROM txw_c_vol
                      WHERE vol_set = i_volset.
    ENDIF.
    IF sy-subrc NE 0 OR c_doc = SPACE.
*     use default if nothing found
      c_doc = dart1_doctype_extr.
    ENDIF.
  ELSE.
*   get object informations for view files
    c_sobj = dart1_bo_dart_view.
    IF i_mode = 'IM'.
*     for import get information stored on DB
      SELECT SINGLE ar_object INTO c_doc FROM txw_vwlogal2
                    WHERE file_uuid = i_uuid
                      AND vol_id    = '99'.
    ELSE.
*     for export get information for the VOL_SET customizing
      SELECT SINGLE ar_object_view INTO c_doc FROM txw_c_vol
                      WHERE vol_set = i_volset.
    ENDIF.
    IF sy-subrc NE 0 OR c_doc = SPACE.
*     use default if nothing found
      c_doc = dart1_doctype_view.
    ENDIF.
  ENDIF.

endform.                    " ARCHIV_OBJECT_GET
