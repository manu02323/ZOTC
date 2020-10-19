*----------------------------------------------------------------------*
***INCLUDE LTXW1F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F01_UUID_CREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_TXW_UUID  text
*      -->P_SYSTEM_RL  text
*----------------------------------------------------------------------*
FORM f01_uuid_create USING    p_system_rl
                     CHANGING p_txw_uuid.
  DATA: uuidtemp LIKE rssgtpdir-uni_idc25.


  IF p_system_rl GT '45A'.             "#EC PORTABLE
    "supported after 99 system release
    CALL FUNCTION 'SYSTEM_UUID_C_CREATE'
         IMPORTING
              uuid = p_txw_uuid.
  ELSE.  " Actually in 40b function module exists and works
    CALL FUNCTION 'RSS_SYSTEM_GET_UNIQUE_ID'
         IMPORTING
              e_uni_idc25 = uuidtemp
         EXCEPTIONS
              OTHERS      = 1.
    IF sy-subrc <> 0.
      MESSAGE x016(xw).
    ENDIF.
    p_txw_uuid = uuidtemp.
  ENDIF.

ENDFORM.                               " F01_UUID_CREATE
*&---------------------------------------------------------------------*
*&      Form  F01_LOCK_DOWN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONV_STATUS  text
*      <--P_SUBRC  text
*----------------------------------------------------------------------*
FORM f01_conv_lock_down TABLES p_conv_status STRUCTURE conv_status
                   CHANGING p_subrc.
  DATA: tablename(50) TYPE c,
        status(1)     TYPE c.

* Pretend to lock down all tables....
  CALL FUNCTION 'ENQUEUE_E_TXW_DIR2'
       EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    p_subrc = sy-subrc.
  ELSE.
    tablename = 'TXW_DIR2'.  status = 'L'.
    PERFORM f01_conv_set_status TABLES p_conv_status
                                       USING  tablename status.
* pretend that txw-dir is locked properly like txw_dir2
    tablename = 'TXW_DIR'.  status = 'L'.
    PERFORM f01_conv_set_status TABLES p_conv_status
                                       USING  tablename status.

    CALL FUNCTION 'ENQUEUE_E_TXW_VWL2'
         EXCEPTIONS
              foreign_lock   = 1
              system_failure = 2
              OTHERS         = 3.
** report on error and exit if necessary
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      p_subrc = sy-subrc.
    ELSE.
      tablename = 'TXW_VWLOG2'.  status = 'L'.
      PERFORM f01_conv_set_status TABLES p_conv_status
                                         USING  tablename status.
* pretend that txw-vwlog is locked properly like txw_vwlog2
      tablename = 'TXW_VWLOG'.  status = 'L'.
      PERFORM f01_conv_set_status TABLES p_conv_status
                                         USING  tablename status.

* pretend that txw-diral2  is locked properly
      tablename = 'TXW_DIRAL2'.  status = 'L'.
      PERFORM f01_conv_set_status TABLES p_conv_status
                                         USING  tablename status.
* pretend that txw-diral is locked properly
      tablename = 'TXW_DIRAL'.  status = 'L'.
      PERFORM f01_conv_set_status TABLES p_conv_status
                                         USING  tablename status.

* pretend that txw-dirseg is locked properly
      tablename = 'TXW_DIRSEG'.  status = 'L'.
      PERFORM f01_conv_set_status TABLES p_conv_status
                                         USING  tablename status.
* pretend that txw-dirsg2 is locked properly
      tablename = 'TXW_DIRSG2'.  status = 'L'.
      PERFORM f01_conv_set_status TABLES p_conv_status
                                         USING  tablename status.
      p_subrc = 0.                     " success
    ENDIF.
  ENDIF.
ENDFORM.                               " F01_CONV_LOCK_DOWN
*&---------------------------------------------------------------------*
*&      Form  F01_CHECK_TABLES
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
*      -->P_CONV_STATUS  text
*----------------------------------------------------------------------*
FORM f01_conv_check_tables TABLES  itxw_dir STRUCTURE txw_dir
                                   itxw_dir2 STRUCTURE txw_dir2
                                   itxw_dirseg STRUCTURE txw_dirseg
                                   itxw_dirsg2 STRUCTURE txw_dirsg2
                                   itxw_vwlog STRUCTURE txw_vwlog
                                   itxw_vwlog2 STRUCTURE txw_vwlog2
                                   itxw_diral  STRUCTURE txw_diral
                                   itxw_diral2 STRUCTURE txw_diral2
                                   p_conv_status STRUCTURE conv_status.
* In general we should check all of the tables for name collisions
* In the future we will check name collisions from source to target.

  SELECT * FROM txw_dir2 CLIENT SPECIFIED INTO TABLE itxw_dir2.
  PERFORM f01_conv_set_init_cnt TABLES conv_status
                                USING 'TXW_DIR2' sy-dbcnt.


  SELECT * FROM txw_dir CLIENT SPECIFIED INTO TABLE itxw_dir.
  PERFORM f01_conv_set_init_cnt TABLES conv_status
                                USING 'TXW_DIR' sy-dbcnt.

  SELECT * FROM txw_diral2 CLIENT SPECIFIED INTO TABLE itxw_diral2.
  PERFORM f01_conv_set_init_cnt TABLES conv_status
                                USING 'TXW_DIRAL2' sy-dbcnt.

  SELECT * FROM txw_diral CLIENT SPECIFIED INTO TABLE itxw_diral.
  PERFORM f01_conv_set_init_cnt TABLES conv_status
                                USING 'TXW_DIRAL' sy-dbcnt.

  SELECT * FROM txw_dirsg2 CLIENT SPECIFIED INTO TABLE itxw_dirsg2.
  PERFORM f01_conv_set_init_cnt TABLES conv_status
                                USING 'TXW_DIRSG2' sy-dbcnt.

  SELECT * FROM txw_dirseg CLIENT SPECIFIED INTO TABLE itxw_dirseg.
  PERFORM f01_conv_set_init_cnt TABLES conv_status
                                USING 'TXW_DIRSEG' sy-dbcnt.

  SELECT * FROM txw_vwlog2 CLIENT SPECIFIED INTO TABLE itxw_vwlog2.
  PERFORM f01_conv_set_init_cnt TABLES conv_status
                                USING 'TXW_VWLOG2' sy-dbcnt.

  SELECT * FROM txw_vwlog CLIENT SPECIFIED INTO TABLE itxw_vwlog.
  PERFORM f01_conv_set_init_cnt TABLES conv_status
                                USING 'TXW_VWLOG' sy-dbcnt.

ENDFORM.                               " F01_CHECK_FILENAME_COLLISION
*&---------------------------------------------------------------------*
*&      Form  F01_CONV_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONV_STATUS  text
*----------------------------------------------------------------------*
FORM f01_conv_init TABLES p_conv_status STRUCTURE conv_status.

  REFRESH p_conv_status.
  CLEAR p_conv_status.
  PERFORM f01_conv_refresh_elem TABLES p_conv_status :
                                                     USING 'TXW_DIR',
                                                     USING 'TXW_DIR2',
                                                     USING 'TXW_DIRSEG',
                                                     USING 'TXW_DIRSG2',
                                                     USING 'TXW_DIRAL',
                                                     USING 'TXW_DIRAL2',
                                                     USING 'TXW_VWLOG',
                                                     USING 'TXW_VWLOG2',
                                                     USING 'TOACO'.

ENDFORM.                               " F01_INIT_CONV_STATUS

*&---------------------------------------------------------------------*
*&      Form  f01_conv_refresh_elem
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
*      -->P_P_CONV_STATUS  text
*      -->P_TABLENAME  text
*----------------------------------------------------------------------*
FORM f01_conv_refresh_elem TABLES   p_conv_status STRUCTURE conv_status
                           USING    p_tablename.

  READ TABLE p_conv_status WITH KEY tablename = p_tablename.
  IF sy-subrc = 0.
    p_conv_status-status = ' '.
    p_conv_status-init_cnt = 0.
    p_conv_status-conv_cnt = 0.
    MODIFY p_conv_status.
  ELSE.
    p_conv_status-tablename = p_tablename.
    p_conv_status-status = ' '.
    p_conv_status-init_cnt = 0.
    p_conv_status-conv_cnt = 0.
    APPEND p_conv_status.
  ENDIF.

ENDFORM.                               " f01_refresh_conv_elem
*&---------------------------------------------------------------------*
*&      Form  f01_conv_status_set_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_CONV_STATUS  text
*      -->P_0105   text
*      -->P_0106   text
*----------------------------------------------------------------------*
FORM f01_conv_set_status TABLES   p_conv_status STRUCTURE
                                         conv_status
                                USING    value(p_tablename)
                                         value(p_status).
  IF p_conv_status-tablename <> p_tablename.
    READ TABLE p_conv_status WITH KEY tablename = p_tablename.
  ENDIF.
  p_conv_status-status    = p_status.
  MODIFY p_conv_status TRANSPORTING status
                                          WHERE tablename = p_tablename.

ENDFORM.                               " f01_conv_status_set_status

*&---------------------------------------------------------------------*
*&      Form  f01_conv_set_init_cnt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONV_STATUS  text
*      -->P_TABLENAME  text
*      -->P_SY_DBCOUNT  text
*----------------------------------------------------------------------*
FORM f01_conv_set_init_cnt TABLES   p_conv_status STRUCTURE conv_status
  USING    p_tablename
           p_dbcount.

  IF p_conv_status-tablename <> p_tablename.
    READ TABLE p_conv_status WITH KEY tablename = p_tablename.
  ENDIF.
  p_conv_status-init_cnt = p_dbcount.
  MODIFY p_conv_status TRANSPORTING init_cnt
                                          WHERE tablename = p_tablename.

ENDFORM.                               " f01_conv_set_init_cnt
*&---------------------------------------------------------------------*
*&      Form  F01_CONV_CONVERT_EXTRACTS
*&---------------------------------------------------------------------*
*  Convert dir and dirseg to dirseg and dirseg2 directories.
*  update the conv_status for those tables conv and status fields.
*----------------------------------------------------------------------*
*      -->P_ITXW_DIR  text
*      -->P_ITXW_DIR2  text
*      -->P_ITXW_DIRSEG  text
*      -->P_ITXW_DIRSG2  text
*      -->P_CONV_STATUS  text
*      <--P_SUBRC  text
*----------------------------------------------------------------------*
FORM f01_conv_convert_extracts TABLES p_itxw_dir STRUCTURE txw_dir
                                      p_itxw_dir2 STRUCTURE txw_dir2
                                      p_itxw_dirseg STRUCTURE txw_dirseg
                                      p_itxw_dirsg2 STRUCTURE txw_dirsg2
                                 p_conv_status STRUCTURE conv_status
                               CHANGING p_subrc.
* Select all of txw_dir into itable txw_dir_table
* Loop through txw_dir finding corresponding element in txw_dirseg
*    Assumption: Everything in dirseg has a counterpart in dir
*    create new uuid
*    move data from txw_dir to txw_dir2 using new xtrct_uuid
*    append or insert to txw_dir2
*       update status structure for both txw_dir and txw_dir2
*       loop through all dirseg elements that correspond to txw_dir
*       move dirseg to dirsg2 using new xtrct_uuid
*       append to db
*       update status structure for dirseg and dirsg2
*  finished with txw_dir
  DATA old_itxw_dir2 LIKE p_itxw_dir2.
  SORT p_itxw_dir BY extract_id vol_id.
  SORT p_itxw_dirseg BY extract_id vol_id.
  CLEAR p_itxw_dir2.
  LOOP AT p_itxw_dir.
    old_itxw_dir2 = p_itxw_dir2.       "retain old extract id if around
    CLEAR p_itxw_dir2.
* check if old one exists in p_txw_dir2 and is the same.
    READ TABLE p_itxw_dir2             "client specified
                      WITH KEY extract_id = p_itxw_dir-extract_id
                               vol_id     = p_itxw_dir-vol_id
                               fisc_year  = p_itxw_dir-fisc_year
                               dirseg_adr = p_itxw_dir-dirseg_adr
                               first_rec  = p_itxw_dir-first_rec
                               last_rec   = p_itxw_dir-last_rec
                               check_sum  = p_itxw_dir-check_sum
                               mandt      = p_itxw_dir-mandt.

    p_subrc = sy-subrc.
    IF NOT p_subrc IS INITIAL. " doesnt exists in p_txw_dir2 table
      MOVE-CORRESPONDING p_itxw_dir TO p_itxw_dir2.
      IF ( ( old_itxw_dir2-extract_id <> p_itxw_dir2-extract_id ) OR
           ( old_itxw_dir2-mandt <> p_itxw_dir2-mandt ) ).
        CALL FUNCTION 'TXW_UUID_CREATE'
             IMPORTING
                  txw_uuid = p_itxw_dir2-xtrct_uuid.
      ELSE.                            "use old one
        p_itxw_dir2-xtrct_uuid = old_itxw_dir2-xtrct_uuid.
      ENDIF.
      APPEND p_itxw_dir2.              " Maybe collect.
      INSERT INTO txw_dir2 CLIENT SPECIFIED VALUES p_itxw_dir2.
      IF sy-subrc = 0.
        PERFORM f01_conv_incr_conv
                             TABLES p_conv_status USING :'TXW_DIR',
                                                             'TXW_DIR2'.
      ENDIF.
    ELSE.
      PERFORM f01_conv_incr_conv
                          TABLES p_conv_status USING :'TXW_DIR',
                                                            'TXW_DIR2'.
    ENDIF.
* Now do the directory segments associated with this extract.
    LOOP AT p_itxw_dirseg WHERE extract_id = p_itxw_dir-extract_id AND
                                 vol_id = p_itxw_dir-vol_id AND
                                 mandt = p_itxw_dir-mandt.
      CLEAR p_itxw_dirsg2.
      READ TABLE p_itxw_dirsg2 WITH KEY"client specified
                               xtrct_uuid = p_itxw_dir2-xtrct_uuid
                               seg_number = p_itxw_dirseg-seg_number
                               mandt      = p_itxw_dirseg-mandt.
      p_subrc = sy-subrc.
      IF NOT p_subrc IS INITIAL.       " doesn't exist in p_itxw_dirsg2
        MOVE-CORRESPONDING p_itxw_dirseg TO p_itxw_dirsg2.
        p_itxw_dirsg2-xtrct_uuid = p_itxw_dir2-xtrct_uuid.
        APPEND p_itxw_dirsg2.
        INSERT txw_dirsg2 CLIENT SPECIFIED FROM p_itxw_dirsg2.
        IF sy-subrc IS INITIAL.
          PERFORM f01_conv_incr_conv TABLES p_conv_status :
                                                   USING 'TXW_DIRSG2',
                                                   USING 'TXW_DIRSEG'.
        ENDIF.
      ELSE.
        PERFORM f01_conv_incr_conv TABLES p_conv_status :
                                                   USING 'TXW_DIRSG2',
                                                   USING 'TXW_DIRSEG'.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

* check the count = same as in txw_dir-init_cnt.
  p_subrc = 0.
ENDFORM.                               " F01_CONV_CONVERT_EXTRACTS

*&---------------------------------------------------------------------*
*&      Form  f01_conv_incr_conv
*&---------------------------------------------------------------------*
*     Increment converted counter for structure conv.
*----------------------------------------------------------------------*
*      -->P_P_CONV_STATUS  text
*      -->P_TABLENAME  text
*----------------------------------------------------------------------*
FORM f01_conv_incr_conv TABLES   p_conv_status STRUCTURE conv_status
                       USING    p_tablename.
  IF p_conv_status-tablename <> p_tablename.
    READ TABLE p_conv_status WITH KEY tablename = p_tablename.
  ENDIF.
  ADD 1 TO p_conv_status-conv_cnt.
  MODIFY p_conv_status TRANSPORTING conv_cnt
                                          WHERE tablename = p_tablename.

ENDFORM.                               " f01_conv_incr_conv

*&---------------------------------------------------------------------*
*&      Form  F01_CONV_CONVERT_VIEWLOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITXW_VWLOG  text
*      -->P_ITXW_DIR2  text
*      -->P_ITXW_VWLOG2  text
*      -->P_CONV_STATUS  text
*      <--P_SUBRC  text
*----------------------------------------------------------------------*
FORM f01_conv_convert_viewlog TABLES   p_itxw_vwlog STRUCTURE txw_vwlog
                                       p_itxw_dir2 STRUCTURE txw_dir2
                                p_itxw_vwlog2 STRUCTURE txw_vwlog2
                                p_conv_status STRUCTURE conv_status
                              CHANGING p_subrc.
* Select all of txw_vwlog into txw_vwlog
* loop through txw_vwlog
*    create new uuid for vwlog-file_uuid
*    find the corresponding txw_dir2 entry for xtrct_uuid
*    move data from txw_vwlog into txw_vwlog2 using new xtrct_uuid
*    append or insert to txw_vwlog2
*    update db.
*    update status structure for both txw_vwlog and txw_vwlog2
* finish with txw_vwlog
  LOOP AT p_itxw_vwlog.
* check if old one exists in p_txw_vwlog and is the same.
    CLEAR p_itxw_vwlog2.
    READ TABLE p_itxw_vwlog2
WITH KEY
                                 mandt     = p_itxw_vwlog-mandt
                                 fisc_year = p_itxw_vwlog-fisc_year
                                 tax_view  = p_itxw_vwlog-tax_view
                                 file_id   = p_itxw_vwlog-file_id
                                 vol_id    = p_itxw_vwlog-vol_id
                                 records   = p_itxw_vwlog-records.
    p_subrc = sy-subrc.
    IF NOT p_subrc IS INITIAL. " doesnt exists in p_txw_dir2 table
      MOVE-CORRESPONDING p_itxw_vwlog TO p_itxw_vwlog2.
      CALL FUNCTION 'TXW_UUID_CREATE'
           IMPORTING
                txw_uuid = p_itxw_vwlog2-file_uuid.
      READ TABLE p_itxw_dir2 WITH KEY
                                  mandt  = p_itxw_vwlog-mandt
                                  vol_id = p_itxw_vwlog-vol_id
                                  extract_id = p_itxw_vwlog-extract_id.
      p_itxw_vwlog2-xtrct_uuid = p_itxw_dir2-xtrct_uuid.
      APPEND p_itxw_vwlog2.            " Maybe collect.
      INSERT INTO txw_vwlog2 CLIENT SPECIFIED VALUES p_itxw_vwlog2.
      IF sy-subrc IS INITIAL.
        PERFORM f01_conv_incr_conv TABLES p_conv_status :
                                                      USING 'TXW_VWLOG',
                                                     USING 'TXW_VWLOG2'.
      ENDIF.
    ELSE.
      PERFORM f01_conv_incr_conv TABLES p_conv_status :
                                                     USING 'TXW_VWLOG',
                                                     USING 'TXW_VWLOG2'.
    ENDIF.
  ENDLOOP.

  p_subrc = 0.
ENDFORM.                               " F01_CONV_CONVERT_VIEWLOG
*&---------------------------------------------------------------------*
*&      Form  F01_CONV_CONVERT_ARCH_LINK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TXW_DIRAL  text
*      -->P_TXW_DIRAL2  text
*      -->P_TXW_DIR2  text
*      -->P_CONV_STATUS  text
*      <--P_SUBRC  text
*----------------------------------------------------------------------*
FORM f01_conv_convert_arch_link TABLES p_itxw_diral STRUCTURE txw_diral
                                      p_itxw_diral2 STRUCTURE txw_diral2
                                      p_itxw_dir2 STRUCTURE txw_dir2
                                   p_conv_status STRUCTURE conv_status
                                CHANGING p_subrc.
* Select through all of txw_diral
*    find corresponding txw_dir2 and txw_vwlog2
*    move data txw_diral to txw_diral2
*    append to txw_diral2
*    update db
*    update status structure for txw_diral
* endloop
  LOOP AT p_itxw_diral.
* check if old one exists in p_txw_diral2 and is the same.
    CLEAR p_itxw_diral2.
    READ TABLE p_itxw_diral2 WITH KEY
                                 fisc_year = p_itxw_diral-fisc_year
                                 extract_id   = p_itxw_diral-extract_id
                                 vol_id    = p_itxw_diral-vol_id
                                 alidate   = p_itxw_diral-alidate
                                 alitime   = p_itxw_diral-alitime
                                 aledate   = p_itxw_diral-aledate
                                 aletime   = p_itxw_diral-aletime
                                 mandt     = p_itxw_diral-mandt.
    p_subrc = sy-subrc.
    IF NOT p_subrc IS INITIAL. " doesnt exists in p_txw_diral2 table
      MOVE-CORRESPONDING p_itxw_diral TO p_itxw_diral2.
*  Assumption that if there is a link there is an entry in dir2
      READ TABLE p_itxw_dir2 WITH KEY
                                  mandt  = p_itxw_diral2-mandt
*                                  vol_id = p_itxw_diral2-vol_id
                                  extract_id = p_itxw_diral2-extract_id.
      p_itxw_diral2-xtrct_uuid = p_itxw_dir2-xtrct_uuid.
      APPEND p_itxw_diral2.            " Maybe collect.
      INSERT INTO txw_diral2 CLIENT SPECIFIED VALUES p_itxw_diral2.
      IF sy-subrc IS INITIAL.
        PERFORM f01_conv_incr_conv TABLES p_conv_status :
                                                      USING 'TXW_DIRAL',
                                                     USING 'TXW_DIRAL2'.
      ENDIF.
    ELSE.
      PERFORM f01_conv_incr_conv TABLES p_conv_status :
                                                      USING 'TXW_DIRAL',
                                                     USING 'TXW_DIRAL2'.
    ENDIF.
  ENDLOOP.

  p_subrc = 0.

ENDFORM.                               " F01_CONV_CONVERT_ARCH_LINK
*&---------------------------------------------------------------------*
*&      Form  F01_CONV_TRUE_ARCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITXW_DIR  text
*      -->P_ITXW_DIR2  text
*      -->P_ITXW_VWLOG  text
*      -->P_ITXW_VWLOG2  text
*      -->P_CONV_STATUS  text
*      <--P_SUBRC  text
*----------------------------------------------------------------------*
FORM f01_conv_true_arch TABLES   p_itxw_dir STRUCTURE txw_dir
                                 p_itxw_dir2 STRUCTURE txw_dir2
                                 p_itxw_diral STRUCTURE txw_diral
                                 p_itxw_diral2 STRUCTURE txw_diral2
                                 p_itxw_vwlog STRUCTURE txw_vwlog
                                 p_itxw_vwlog2 STRUCTURE txw_vwlog2
                                 p_conv_status STRUCTURE conv_status
                        CHANGING p_subrc.

* process each available link table
  SELECT * FROM toaco.
    PERFORM f01_convert_bus4010 TABLES
                                       p_itxw_dir
                                       p_itxw_dir2
                                       p_itxw_diral
                                       p_itxw_diral2
                                       p_conv_status
                                USING toaco-connection.
    PERFORM f01_convert_bus4011 TABLES p_itxw_vwlog
                                p_itxw_vwlog2
                                p_conv_status
                                USING toaco-connection.
  ENDSELECT.

ENDFORM.                               " F01_CONV_TRUE_ARCH

*&---------------------------------------------------------------------*
*&      Form  F01_CONVERT_BUS4010
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_ITXW_DIR  text
*      -->P_P_ITXW_DIR2  text
*      -->P_P_CONV_STATUS  text
*      -->P_TOACO_CONNECTION  text
*----------------------------------------------------------------------*
FORM f01_convert_bus4010 TABLES   p_itxw_dir STRUCTURE  txw_dir
                                  p_itxw_dir2 STRUCTURE txw_dir2
                                  p_itxw_diral STRUCTURE txw_diral
                                  p_itxw_diral2 STRUCTURE txw_diral2
                                  p_conv_status STRUCTURE conv_status
                         USING    value(link_table) TYPE c.
  DATA: t_toa01 LIKE toa01 OCCURS 0 WITH HEADER LINE.

  DATA: wa_toa01 LIKE toa01.

  DATA: BEGIN OF bus4010_id_old,
        extract_id LIKE txw_dir-extract_id,
        vol_id     LIKE txw_dir-vol_id,
        fisc_year  LIKE txw_dir-fisc_year,
        END   OF bus4010_id_old.

  DATA: BEGIN OF bus4010_id,
        xtrct_uuid TYPE dart1_xtrct_uuid,
        vol_id     LIKE txw_dir2-vol_id,
        END   OF bus4010_id.


* read all link table entries
  SELECT * FROM (link_table) CLIENT SPECIFIED
           INTO TABLE t_toa01
           WHERE sap_object = 'BUS4010'.

* process link table entries
  LOOP AT t_toa01.

*   check if this is an old-style entry that needs to be converted
    CHECK t_toa01-object_id CO '0123456789 '.
*   read corresponding log entry from old log table
    bus4010_id_old = t_toa01-object_id.
    IF bus4010_id_old-vol_id NE '99'.
      READ TABLE p_itxw_dir WITH KEY
                                   mandt      = t_toa01-mandt
                                 extract_id = bus4010_id_old-extract_id
                                   vol_id     = bus4010_id_old-vol_id.
      IF sy-subrc IS INITIAL.
*     read corresponding log entry from new log table
        READ TABLE p_itxw_dir2 WITH KEY
                                   mandt      = t_toa01-mandt
                                 extract_id = bus4010_id_old-extract_id
                                   vol_id     = bus4010_id_old-vol_id
                                  fisc_year  = bus4010_id_old-fisc_year.
        IF sy-subrc IS INITIAL.
*       create and insert converted link table entry
          MOVE-CORRESPONDING p_itxw_dir2 TO bus4010_id.
          wa_toa01 = t_toa01.
          wa_toa01-object_id = bus4010_id.
          PERFORM f01_conv_incr_conv TABLES p_conv_status USING 'TOACO'.
          INSERT (link_table) CLIENT SPECIFIED FROM wa_toa01.
          IF sy-subrc IS INITIAL.
*         delete old link table entry
*****     DELETE (LINK_TABLE) CLIENT SPECIFIED FROM T_TOA01.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      READ TABLE p_itxw_diral WITH KEY
                                   mandt      = t_toa01-mandt
                                 extract_id = bus4010_id_old-extract_id
                                   vol_id     = bus4010_id_old-vol_id.
      IF sy-subrc IS INITIAL.
*     read corresponding log entry from new log table
        READ TABLE p_itxw_diral2 WITH KEY
                                   mandt      = t_toa01-mandt
                                 extract_id = bus4010_id_old-extract_id
                                   vol_id     = bus4010_id_old-vol_id
                                  fisc_year  = bus4010_id_old-fisc_year.
        IF sy-subrc IS INITIAL.
*       create and insert converted link table entry
          MOVE-CORRESPONDING p_itxw_diral2 TO bus4010_id.
          wa_toa01 = t_toa01.
          wa_toa01-object_id = bus4010_id.
          PERFORM f01_conv_incr_conv TABLES p_conv_status USING 'TOACO'.
          INSERT (link_table) CLIENT SPECIFIED FROM wa_toa01.
          IF sy-subrc IS INITIAL.
*         delete old link table entry
*****     DELETE (LINK_TABLE) CLIENT SPECIFIED FROM T_TOA01.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " F01_CONVERT_BUS4010
*&---------------------------------------------------------------------*
*&      Form  F01_CONVERT_BUS4011
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITXW_VWLOG  text
*      -->P_ITXW_VWLOG2  text
*      -->P_CONV_STATUS  text
*      -->P_TOACO_CONNECTION  text
*----------------------------------------------------------------------*
FORM f01_convert_bus4011 TABLES   p_itxw_vwlog STRUCTURE txw_vwlog
                                  p_itxw_vwlog2 STRUCTURE txw_vwlog2
                                  p_conv_status STRUCTURE conv_status
                         USING value(link_table) TYPE c.
  DATA: t_toa01 LIKE toa01 OCCURS 0 WITH HEADER LINE.

  DATA: wa_toa01 LIKE toa01.

  DATA: BEGIN OF bus4011_id_old,
        fisc_year LIKE txw_vwlog-fisc_year,
        tax_view  LIKE txw_vwlog-tax_view,
        file_id   LIKE txw_vwlog-file_id,
        vol_id    LIKE txw_vwlog-vol_id,
        END   OF bus4011_id_old.

  DATA: BEGIN OF bus4011_id,
        file_uuid LIKE txw_vwlog2-file_uuid,
        vol_id    LIKE txw_vwlog2-vol_id,
        END   OF bus4011_id.


* read all link table entries
  SELECT * FROM (link_table) CLIENT SPECIFIED
           INTO TABLE t_toa01
           WHERE sap_object = 'BUS4011'.

* process link table entries
  LOOP AT t_toa01.

*   check if this is an old-style entry that needs to be converted
    CHECK: t_toa01-object_id+0(4)  CO '0123456789', "FISC_YEAR
           t_toa01-object_id+14(6) CO '0123456789', "FILE_ID
           t_toa01-object_id+20(2) CO '0123456789'. "VOL_ID

*   read corresponding log entry from old log table
    bus4011_id_old = t_toa01-object_id.
    READ TABLE p_itxw_vwlog WITH KEY
               mandt     = t_toa01-mandt
               fisc_year = bus4011_id_old-fisc_year
               tax_view  = bus4011_id_old-tax_view
               file_id   = bus4011_id_old-file_id
               vol_id    = bus4011_id_old-vol_id.
    IF sy-subrc IS INITIAL.
*     read corresponding log entry from new log table
      READ TABLE p_itxw_vwlog2 WITH KEY
               mandt     = t_toa01-mandt
               fisc_year = bus4011_id_old-fisc_year
               tax_view  = bus4011_id_old-tax_view
               file_id   = bus4011_id_old-file_id
               vol_id    = bus4011_id_old-vol_id.
      IF sy-subrc IS INITIAL.
*       create and insert converted link table entry
        MOVE-CORRESPONDING p_itxw_vwlog2 TO bus4011_id.
        wa_toa01 = t_toa01.
        PERFORM f01_conv_incr_conv TABLES p_conv_status USING 'TOACO'.
        wa_toa01-object_id = bus4011_id.
        INSERT (link_table) CLIENT SPECIFIED FROM wa_toa01.
        IF sy-subrc IS INITIAL.
*         delete old link table entry
*****     DELETE (LINK_TABLE) CLIENT SPECIFIED FROM T_TOA01.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.                               " f01_convert_bus4011
*&---------------------------------------------------------------------*
*&      Form  F01_REPORT_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONV_STATUS  text
*      -->P_FORCE_CONVERSION  text
*      -->P_REPORT_TYPE  text
*----------------------------------------------------------------------*
FORM f01_conv_report_status TABLES   p_conv_status STRUCTURE conv_status
                       USING p_report_type.

  DATA: status LIKE conv_status-status.


* compare and set new status of conversion
  PERFORM f01_conv_check_conv TABLES p_conv_status :
                                     USING 'TXW_DIR' 'TXW_DIR2',
                                     USING 'TXW_DIRSEG' 'TXW_DIRSG2',
                                     USING 'TXW_VWLOG' 'TXW_VWLOG2',
                                     USING 'TXW_DIRAL' 'TXW_DIRAL2'.

* Check the business object table check (any conversion occured)
*  read table p_conv_status into wa_conv_status
*                                      with key tablename = 'TOACO'.
*  if wa_conv_status-conv_cnt > 0.
*    status = 'X'.                      "Converted
*  else.
*    status = '?'.                      "Some Failure occurred
*  endif.
*  Do to condition that there may be nothing to convert, we don't
* have a good way to detect the successfull conversion.
  status = 'X'.
  PERFORM f01_conv_set_status TABLES p_conv_status
                                 USING 'TOACO' status.


  CASE p_report_type.
    WHEN 1.                            " Write a report detailed
      WRITE: / sy-datum, sy-uzeit.
      LOOP AT p_conv_status.
        WRITE: / p_conv_status-tablename, space ,
                 p_conv_status-status, space,
                  p_conv_status-init_cnt, p_conv_status-conv_cnt.
      ENDLOOP.
    WHEN 2.                            " Write a report for transports
      PERFORM f01_conv_write_tlog TABLES p_conv_status.

    WHEN OTHERS.                  "Write brief status message ok or fail
      READ TABLE p_conv_status WITH KEY status = '?'.
      IF sy-subrc = 0.
        MESSAGE w250(xw).
      ELSE.
        MESSAGE s251(xw).
      ENDIF.
  ENDCASE.

* Check if need to raise failure condition or write success to db.
  READ TABLE p_conv_status WITH KEY status = '?'.
  IF sy-subrc = 0.
    RAISE failed_to_convert.
  ELSE.            "Successful conversion : write to DB
    PERFORM f05_conv_update(sapmtxwc).
  ENDIF.

ENDFORM.                               " F01_REPORT_STATUS
*&---------------------------------------------------------------------*
*&      Form  f01_conv_check_conv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONV_STATUS  text
*      -->P_TABLENAME1  text
*      -->P_TABLENAME2  text
*----------------------------------------------------------------------*
FORM f01_conv_check_conv TABLES p_conv_status STRUCTURE conv_status
                         USING    p_tablename1
                                  p_tablename2.

  DATA: wa_conv_status1 LIKE conv_status,
        wa_conv_status2 LIKE conv_status,
        status          LIKE conv_status-status.

* read and determine status of conversion.
  READ TABLE p_conv_status INTO wa_conv_status1
                           WITH KEY tablename = p_tablename1.
  READ TABLE p_conv_status INTO wa_conv_status2
                                      WITH KEY tablename = p_tablename2.
  IF ( wa_conv_status1-init_cnt = wa_conv_status2-conv_cnt ) AND
     ( wa_conv_status1-init_cnt = wa_conv_status1-conv_cnt ).
* Data converted properly
    status = 'X'.                      "Converted
  ELSE.
    status = '?'.                      "Some Failure
  ENDIF.
  PERFORM f01_conv_set_status TABLES p_conv_status
                                 USING p_tablename1 status.
  PERFORM f01_conv_set_status TABLES p_conv_status
                                 USING p_tablename2 status.


ENDFORM.                               " f01_conv_check_conv
*&---------------------------------------------------------------------*
*&      Form  f01_conv_write_tlog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONV_STATUS  text
*----------------------------------------------------------------------*
FORM f01_conv_write_tlog TABLES   p_conv_status STRUCTURE conv_status.
  DATA: xpra_prot LIKE sprot_u OCCURS 0 WITH HEADER LINE.

  LOOP AT p_conv_status.
* initialize log
    xpra_prot-level    = '3'.          "Protocol layer
    IF p_conv_status-status = '?'.
      xpra_prot-severity = 'W'.        "Fehlerschwere (' ',W(arning),
    ELSE.
      xpra_prot-severity = ' '.        "Fehlerschwere (' ',W(arning),
    ENDIF.
    xpra_prot-langu    = 'E'.          "Sprachenschluessel
    xpra_prot-ag       = 'XW'.         "Arbeitsgebiet: allg. Basis
    xpra_prot-msgnr    = '001'.        "Messagenr
    xpra_prot-newobj   = ' '.          "neuer Abschnitt
    xpra_prot-var1     = p_conv_status-tablename.        " message text
    xpra_prot-var2     = p_conv_status-status.
    xpra_prot-var3     = p_conv_status-conv_cnt.
    APPEND xpra_prot.
  ENDLOOP.

* send it.
  CALL FUNCTION 'APPEND_PROTOCOL'
       EXPORTING
            accept_not_init = 'X'
       TABLES
            xmsg            = xpra_prot.

ENDFORM.                               " f01_conv_write_tlog
*&---------------------------------------------------------------------*
*&      Form  BACK_PROGRAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM back_program.
*     Destroy Control.
  IF NOT textnote_editor IS INITIAL.
    CALL METHOD textnote_editor->free
      EXCEPTIONS
          OTHERS = 1.
    IF sy-subrc NE 0.
*         add your handling
    ENDIF.
*       free ABAP object also
    FREE textnote_editor.
  ENDIF.

*     destroy container
  IF NOT textnote_custom_container IS INITIAL.
    CALL METHOD textnote_custom_container->free
      EXCEPTIONS
        OTHERS = 1.
    IF sy-subrc <> 0.
*         add your handling
    ENDIF.
*       free ABAP object also
    FREE textnote_custom_container.
  ENDIF.

  CALL METHOD cl_gui_cfw=>flush
      EXCEPTIONS
          OTHERS = 1.
  IF sy-subrc NE 0.
*         add your handling
  ENDIF.

  LEAVE TO SCREEN 0.

ENDFORM.                               " BACK_PROGRAM

