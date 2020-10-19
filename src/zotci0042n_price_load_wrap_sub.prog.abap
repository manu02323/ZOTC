*&---------------------------------------------------------------------*
*&  Include           ZOTCI0042N_PRICE_LOAD_WRAP_SUB
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCI0042B_PRICE_LOAD_WRAPPER                          *
* TITLE      :  OTC_IDD_42_Price Load                                  *
* DEVELOPER  :  Shushant Nigam                                         *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D2_OTC_IDD_42_Price Load
*----------------------------------------------------------------------*
* DESCRIPTION: This is the wrapper program to ZOTCI0042B_PRICE_LOAD. Si*
* nce original program is taking lot of time to finish, hence objective*
* is to split the file into smaller files and schedule job with smaller*
* files                                                                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
*19-Nov-2015 SNIGAM   E2DK916145  Defect 1351                          *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_files
*&---------------------------------------------------------------------*
*       Get list of all files available in TBP folder of OTC_IDD_0042
*----------------------------------------------------------------------*
*  <--  fp_i_directory        Files in Folder
*----------------------------------------------------------------------*
FORM f_get_files CHANGING fp_i_directory TYPE ty_t_btcxpm.

  CONSTANTS: lc_commandname TYPE sxpglogcmd VALUE 'ZCA_LIST'. " Logical command name

  DATA: lv_dir         TYPE btcxpgpar,                    "Longer file name
        lv_exit_status TYPE extcmdexex-status   ##needed, "Start or exit status of an external program
        lv_exit_code   TYPE extcmdexex-exitcode ##needed. "Exit code of an external program

* Processing of File data.
  lv_dir = p_file.

  CALL FUNCTION 'SXPG_COMMAND_EXECUTE'
    EXPORTING
      commandname                   = lc_commandname
      additional_parameters         = lv_dir
      operatingsystem               = sy-opsys
      stdout                        = abap_true
      stderr                        = abap_true
      terminationwait               = abap_true
    IMPORTING
      status                        = lv_exit_status
      exitcode                      = lv_exit_code
    TABLES
      exec_protocol                 = fp_i_directory
    EXCEPTIONS
      no_permission                 = 1
      command_not_found             = 2
      parameters_too_long           = 3
      security_risk                 = 4
      wrong_check_call_interface    = 5
      program_start_error           = 6
      program_termination_error     = 7
      x_error                       = 8
      parameter_expected            = 9
      too_many_parameters           = 10
      illegal_command               = 11
      wrong_asynchronous_parameters = 12
      cant_enq_tbtco_entry          = 13
      jobcount_generation_error     = 14
      OTHERS                        = 15.
  IF sy-subrc <> 0.
    MESSAGE i000 WITH 'Not able to open the directory'(003). " & & & &
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc <> 0

ENDFORM. " F_GETDATA
*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_FILE
*&---------------------------------------------------------------------*
*       Process Each File in Folder
*----------------------------------------------------------------------*
*  -->  fp_i_directory        Files in Folder
*  <--  fp_i_job_log          Job Log
*----------------------------------------------------------------------*
FORM f_process_file USING    fp_i_directory TYPE ty_t_btcxpm
                    CHANGING fp_i_job_log   TYPE ty_t_job_log.
  CONSTANTS:
    lc_job               TYPE char25  VALUE 'OTC_CHG_PPM_INTERFACE', " Job of type CHAR27
    lc_underscore        TYPE char1   VALUE '_',                     "Underscore
    lc_filepattern       TYPE char20  VALUE 'SAP_OTC_0042a'.         "File Name Pattern

  DATA:   lv_file        TYPE localfile, "File Type of CHAR
          lv_count       TYPE i,         "SY-SUBRC
          lv_leg_tab     TYPE string,    "local variale declaration foR FILE RECORD
          lv_jobname     TYPE btcjob,    "Job name
* ---> Begin of Change for D2_OTC_IDD_0042 Defect # 1430 by PDEBARU
* Below line is commented
*          lv_job_counter TYPE char1,                   "Counter for Suffix
          lv_job_counter TYPE char4 , "Counter for Suffix
* <--- End    of Change for D2_OTC_IDD_0042 Defect # 1430 by PDEBARU
          lv_jobcount    TYPE btcjobcnt,               "Job ID
          lv_jobrel      TYPE btcchar1 ##needed,       "Job Released
          lv_start_date  TYPE btcsdate,                "Start Date
          lv_start_time  TYPE btcstime,                "Start Time,
          lv_start_time2 TYPE btcstime,                "Start Time,
          lv_wait_second TYPE i,                       "Wait time in Seconds
          lwa_job_log    TYPE ty_job_log,              "Workarea for Job Log
          lv_time_diff   TYPE i,                       "Time difference in seconds
          li_tbtco       TYPE STANDARD TABLE OF tbtco. " Job Status Overview Table

  FIELD-SYMBOLS:
     <lfs_dir>        TYPE btcxpm,     " Log message from external program to calling program
     <lfs_job_log>    TYPE ty_job_log, "Workarea for Job Log
     <lfs_tbtco>      TYPE tbtco.      " Job Status Overview Table

* Calculate wait time in Seconds
  lv_wait_second = p_delay * 60.

* Read all files one by one in the folder entered on Selection Screen
  LOOP AT fp_i_directory ASSIGNING <lfs_dir>.
    IF <lfs_dir>-message CS lc_filepattern.
* The file processing will continue
      lv_job_counter = lv_job_counter + 1.
    ELSE. " ELSE -> IF <lfs_dir>-message CS lc_filepattern
* Ignore such file not following the file name pattern
      CONTINUE.
    ENDIF. " IF <lfs_dir>-message CS lc_filepattern

*   Prepare file path on App Server
    CONDENSE: p_file,            "Folder Name on Selection Screen
              <lfs_dir>-message. "File Name in Folder

    CONCATENATE p_file            "Folder Name on Selection Screen
                <lfs_dir>-message "File Name in Folder
           INTO lv_file.          "Complete File path

*   Open file on App Server
    OPEN DATASET lv_file FOR INPUT IN TEXT MODE ENCODING DEFAULT. "Set as Ready for Input
    IF sy-subrc EQ 0.
*     Count Number of records in the file
      WHILE ( sy-subrc EQ 0 ).
        READ DATASET lv_file INTO lv_leg_tab.
        IF sy-subrc =  0 AND
          lv_leg_tab IS NOT INITIAL.
          lv_count = lv_count + 1.
        ENDIF. " IF sy-subrc = 0 AND
      ENDWHILE.
*     Close file
      CLOSE DATASET lv_file.
* Number of Records in File (Ignore Header)
      lv_count = lv_count - 1.
    ENDIF. " IF sy-subrc EQ 0

*   Prepare Job Name
* ---> Begin of Change for D2_OTC_IDD_0042 Defect # 1430 by PDEBARU
    CONDENSE lv_job_counter.
* ---> End of Change for D2_OTC_IDD_0042 Defect # 1430 by PDEBARU
    CONCATENATE sy-sysid
                lc_job
                lv_job_counter
          INTO  lv_jobname
          SEPARATED BY lc_underscore.


*   Job Start Date & Time
    IF lv_job_counter = 1.
      GET TIME.
      IF sy-subrc = 0.
        lv_start_date = sy-datum.
        lv_start_time = sy-uzeit.
      ENDIF. " IF sy-subrc = 0
    ELSE. " ELSE -> IF sy-subrc = 0
      CLEAR:
        lv_start_time2,
        lv_time_diff.
* Start Time for next job
      lv_start_time   = lv_start_time + lv_wait_second.

* Determining the Start date for next job
      lv_start_time2  = lv_start_time.
      lv_time_diff    = lv_start_time2 - lv_start_time.

      IF lv_time_diff < 0.
        lv_start_date = lv_start_date + 1.
      ENDIF. " IF lv_time_diff < 0
    ENDIF. " IF lv_job_counter = 1

*   Call FM to Start Background Job
    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        jobname          = lv_jobname
        sdlstrtdt        = lv_start_date
        sdlstrttm        = lv_start_time
      IMPORTING
        jobcount         = lv_jobcount
      EXCEPTIONS
        cant_create_job  = 1
        invalid_job_data = 2
        jobname_missing  = 3
        OTHERS           = 4.
    IF sy-subrc <> 0 ##needed.
*   Implement suitable error handling here
    ENDIF. " IF sy-subrc <> 0 ##needed

*   Submit Report to update pricing
    SUBMIT zotci0042b_price_load
    WITH rb_pres = space
    WITH rb_app = abap_true
    WITH p_ahdr = lv_file
    WITH cb_map = p_map
    USER sy-uname
    VIA JOB lv_jobname
    NUMBER lv_jobcount
    AND RETURN.

*   Call FM to Close Background Job
    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        jobcount             = lv_jobcount
        jobname              = lv_jobname
        sdlstrtdt            = lv_start_date
        sdlstrttm            = lv_start_time
      IMPORTING
        job_was_released     = lv_jobrel
      EXCEPTIONS
        cant_start_immediate = 1
        invalid_startdate    = 2
        jobname_missing      = 3
        job_close_failed     = 4
        job_nosteps          = 5
        job_notex            = 6
        lock_failed          = 7
        invalid_target       = 8
        OTHERS               = 9.
    IF sy-subrc <> 0 ##needed.
*   Implement suitable error handling here
    ENDIF. " IF sy-subrc <> 0 ##needed

* Writing Job log
    MESSAGE i000 WITH 'Job Submitted:'(005)
                      lv_jobname.
    MESSAGE i000 WITH 'File name read:'(004)
                      <lfs_dir>-message.
    MESSAGE i000 WITH 'Record count in file:'(006)
                      lv_count.
    MESSAGE i000 WITH 'Job Scheduled Start Date/ Time:'(007)
                      lv_start_date
                      lv_start_time.


*   Populate table for Job Log
    lwa_job_log-name        = lv_jobname. "Job name
    lwa_job_log-id          = lv_jobcount. "Job ID
    lwa_job_log-file        = lv_file. "File Name
    lwa_job_log-count       = lv_count. "Number of Records in File (Ignore Header)
    APPEND lwa_job_log TO fp_i_job_log.

    CLEAR: lwa_job_log,
           lv_count,
           lv_jobcount,
           lv_jobname,
           lv_file,
           lv_leg_tab,
           lv_jobrel.

  ENDLOOP. " LOOP AT fp_i_directory ASSIGNING <lfs_dir>

*   Get job Host Server and update into App Log
  IF lines( fp_i_job_log[] ) > 0.
    SELECT *
      INTO TABLE li_tbtco
      FROM tbtco " Job Status Overview Table
  FOR ALL ENTRIES IN fp_i_job_log
      WHERE jobname  = fp_i_job_log-name
      AND   jobcount = fp_i_job_log-id.
    IF sy-subrc = 0 ##needed.
      LOOP AT fp_i_job_log ASSIGNING <lfs_job_log>.
        READ TABLE li_tbtco ASSIGNING <lfs_tbtco>
             WITH KEY jobname = <lfs_job_log>-name
                     jobcount = <lfs_job_log>-id.
        IF sy-subrc = 0.
          <lfs_job_log>-reaxserver  = <lfs_tbtco>-reaxserver. "Host Server
        ENDIF. " IF sy-subrc = 0
      ENDLOOP. " LOOP AT fp_i_job_log ASSIGNING <lfs_job_log>
    ENDIF. " IF sy-subrc = 0 ##needed
  ENDIF. " IF lines( fp_i_job_log[] ) > 0

  FREE:
    li_tbtco[].

ENDFORM. " F_PROCESS_FILE
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_SUMMARY
*&---------------------------------------------------------------------*
*       Display Job Log (Parent)
*----------------------------------------------------------------------*
*      -->FP_I_JOB_LOG   Job Log table
*----------------------------------------------------------------------*
FORM f_display_summary  USING  fp_i_job_log TYPE ty_t_job_log.

  DATA: lwa_layout  TYPE slis_layout_alv,     " Layout
        li_fieldcat TYPE slis_t_fieldcat_alv. "alv field catalog

* Prepare Field Catalog
  PERFORM f_fill_fieldcat USING 'REAXSERVER'   'HOST SERVER'  CHANGING li_fieldcat.
  PERFORM f_fill_fieldcat USING 'NAME'         'JOB NAME'     CHANGING li_fieldcat.
  PERFORM f_fill_fieldcat USING 'ID'           'JOB NUMBER'   CHANGING li_fieldcat.
  PERFORM f_fill_fieldcat USING 'FILE'         'FILE NAME'    CHANGING li_fieldcat.
  PERFORM f_fill_fieldcat USING 'COUNT'        'RECORD COUNT' CHANGING li_fieldcat.

* Set layout
  lwa_layout-colwidth_optimize = abap_true.

* Display ALV List
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = lwa_layout
      it_fieldcat        = li_fieldcat[]
    TABLES
      t_outtab           = fp_i_job_log[]
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    MESSAGE i000 WITH 'Report Display Failed'(002).
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc <> 0

ENDFORM. " F_DISPLAY_SUMMARY

*&---------------------------------------------------------------------*
*&      Form  F_FILL_FIELDCAT
*&---------------------------------------------------------------------*
*      Subroutine to fill fieldcatalog table
*----------------------------------------------------------------------*
*     -->  FP_FIELDNAME    Field Name
*     -->  FP_SELTEXT      Selection Text
*     <--  FP_FIELDCAT     Field Catalog
*----------------------------------------------------------------------*
FORM f_fill_fieldcat  USING  fp_fieldname  TYPE slis_fieldname
                             fp_seltext    TYPE scrtext_l " Long Field Label
                    CHANGING fp_fieldcat   TYPE slis_t_fieldcat_alv.

  STATICS lv_count   TYPE sycucol. " Horizontal Cursor Position at PAI

  DATA: lwa_fieldcat TYPE slis_fieldcat_alv. "Fieldcatalog Workarea

  lv_count = lv_count + 1.

  lwa_fieldcat-fieldname  = fp_fieldname.
  lwa_fieldcat-seltext_l  = fp_seltext.
  lwa_fieldcat-col_pos    = lv_count.

  APPEND lwa_fieldcat TO fp_fieldcat.
  CLEAR lwa_fieldcat.

ENDFORM. " F_FILL_FIELDCAT
