*&---------------------------------------------------------------------*
*& Program      ZOTCE0285B_SORD_ATP_CHECK_FORM
*&
************************************************************************
* PROGRAM    :  ZOTCE0285B_SORD_ATP_CHECK_FORM                         *
* TITLE      :  ATP Check for Sales orders                             *
* DEVELOPER  :  Dhanasekar Arumugam                                    *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
*  WRICEF ID :  D2_OTC_EDD_0285                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: This is a BDC program to run ATP check                  *
* using Call Transaction to VA02.                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 05-OCT-2015 DARUMUG  E2DK915626  INITIAL DEVELOPMENT                 *
* 19-Aug-2019 SMUKHER  E1SK901419  HANAtization changes                *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*        Modify selection screen as per radio-button selection
*----------------------------------------------------------------------*

FORM f_modify_screen .
  LOOP AT SCREEN .
*   Presentation Server Option is NOT chosen
    IF rb_pres NE c_true.
*     Hiding Presentation Server file paths with modifidd MI3.
      IF screen-group1 = c_groupmi3. "MI3
        screen-active = c_zero. "0
        MODIFY SCREEN.
      ENDIF. " IF rb_pres NE c_true
*   Presentation Server Option IS chosen
    ELSE. " ELSE -> IF rb_pres NE c_true
*     Disaplying Presentation Server file paths with modifidd MI3.
      IF screen-group1 = c_groupmi3. "MI3
        screen-active = c_one. "1
        MODIFY SCREEN.
      ENDIF. " LOOP AT SCREEN
    ENDIF. " IF rb_pres NE c_true
*   Application Server Option is NOT chosen
    IF rb_app NE c_true.
*     Hiding 1) Application Server file Physical paths with modifid MI2
*     2) Logical Filename Radio Button with modifid MI5
*     3) Logical Filename input with modifid MI7
      IF screen-group1 = c_groupmi2     "MI2
         OR screen-group1 = c_groupmi5  "MI5
         OR screen-group1 = c_groupmi7. "MI7
        screen-active = c_zero. "0
        MODIFY SCREEN.
      ENDIF. " IF rb_app NE c_true
*   Application Server Option IS chosen
    ELSE. " ELSE -> IF rb_app NE c_true
*     If Application Server Physical File Radio Button is chosen
      IF rb_aphy EQ c_true.
*       Dispalying Application Server Physical paths with modifid MI2
        IF screen-group1 = c_groupmi2. "MI2
          screen-active = c_one. "1
          MODIFY SCREEN.
        ENDIF. " IF rb_aphy EQ c_true
*       Hiding Logical Filaename input with modifid MI7
        IF screen-group1 = c_groupmi7. "MI7
          screen-active = c_zero. "0
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi7
*     If Application Server Logical File Radio Button is chosen
      ELSE. " ELSE -> IF rb_aphy EQ c_true
*       Hiding Application Server - Physical paths with modifidd MI2
        IF screen-group1 = c_groupmi2. "MI2
          screen-active = c_zero. "0
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi2
*       Displaying Logical Filaename input with modifid MI7
        IF screen-group1 = c_groupmi7. "MI7
          screen-active = c_one. "1
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi7
      ENDIF. " IF rb_aphy EQ c_true
    ENDIF. " IF rb_app NE c_true
  ENDLOOP. " LOOP AT SCREEN

ENDFORM. " F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_EXTENSION
*&---------------------------------------------------------------------*
*        Checking whetehr the file has .TXT extension
*----------------------------------------------------------------------*
*      -->FP_P_PFILE  INPUT FILE PATH
*----------------------------------------------------------------------*
FORM f_check_extension  USING fp_p_file TYPE localfile. " Local file for upload/download
  IF fp_p_file IS NOT INITIAL.
    CLEAR gv_extn.
*   Getting the file extension
    PERFORM f_file_extn_check USING fp_p_file
                           CHANGING gv_extn.
    IF gv_extn <> c_text.
      MESSAGE e008. " Please provide text file
    ENDIF. " IF gv_extn <> c_text
  ENDIF. " IF fp_p_file IS NOT INITIAL
ENDFORM. " F_CHECK_EXTENSION
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_LOGICALPATH
*&---------------------------------------------------------------------*
*       Logical path validation
*----------------------------------------------------------------------*
*      -->FP_V_ALOG  text LOGICAL PATH
*----------------------------------------------------------------------*
FORM f_validate_logicalpath  USING fp_v_alog TYPE pathintern. " Logical path name
  DATA lv_path TYPE fileintern. " Logical file name

  IF fp_v_alog IS NOT INITIAL.
    SELECT SINGLE pathintern " Logical path name
      FROM filepath          " Logical File Path Definition
      INTO lv_path
      WHERE pathintern = fp_v_alog.
    IF sy-subrc <> 0.
       MESSAGE e037 WITH fp_v_alog.  "#EC_NEEDED "For future release
    ENDIF. " IF sy-subrc <> 0

  ENDIF. " IF fp_v_alog IS NOT INITIAL

ENDFORM. " F_VALIDATE_LOGICALPATH
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_INPUT
*&---------------------------------------------------------------------*
*       Checking whether file names have entered for chosen option at
*       Run time.
*----------------------------------------------------------------------*
FORM f_check_input .

  IF rb_sord IS NOT INITIAL.
    IF p_sord IS INITIAL.
      MESSAGE i059. "Sales order number is not valid
      LEAVE LIST-PROCESSING.
    ENDIF.
  ELSE.
*  * If No presentation Server file name is entered and Presentation
* Server Option has been chosen, then issueing error message.
    IF rb_pres IS NOT INITIAL AND
       p_pfile IS INITIAL.
      MESSAGE i032. "No filename entered for Presentation Server
      LEAVE LIST-PROCESSING.
    ENDIF. " IF rb_pres IS NOT INITIAL AND

* For Application Server
    IF rb_app IS NOT INITIAL.
*   If No Application Server file name is entered and Application
*   Server Option has been chosen, then issueing error message.
      IF rb_aphy IS NOT INITIAL AND
         p_afile IS INITIAL.
        MESSAGE i010. "No filename entered for Application Server
        LEAVE LIST-PROCESSING.
      ENDIF. " IF rb_aphy IS NOT INITIAL AND

* If No Logical File Path is entered and Logical File Path Option
* has been chosen, then issueing error message.
      IF rb_alog IS NOT INITIAL AND
         p_alog IS INITIAL.
        MESSAGE i011. "Please enter logical file path
        LEAVE LIST-PROCESSING.
      ENDIF. " IF rb_alog IS NOT INITIAL AND
    ENDIF. " IF rb_app IS NOT INITIAL
  ENDIF.


ENDFORM. " F_CHECK_INPUT
*&---------------------------------------------------------------------*
*&      Form  F_SET_MODE
*&---------------------------------------------------------------------*
*       Setting the mode of processing
*       SPACE - for Verify only mode
*       "X"   - for Verify and Post mode
*----------------------------------------------------------------------*
*      <--FP_GV_MODE  Variable for mode to see if its verify or post
*----------------------------------------------------------------------*
FORM f_set_mode  CHANGING fp_gv_mode TYPE char10. " Set_mode changing fp_gv of type CHAR10
* Choosing the Mode
  IF rb_post = c_true.
    fp_gv_mode =  'Post Run'(009). "Verify and post
  ELSE. " ELSE -> IF rb_post = c_true
    fp_gv_mode =  'Test Run'(010). "Verify
  ENDIF. " IF rb_post = c_true

ENDFORM. " F_SET_MODE
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_PRES
*&---------------------------------------------------------------------*
*       Upload input file from Presentation Server
*----------------------------------------------------------------------*
*      -->FP_P_FILE  INPUT FILE
*      <--FP_I_INPUT[]  INPUT DATA
*----------------------------------------------------------------------*
FORM f_upload_pres  USING    fp_p_file TYPE localfile " Local file for upload/download
                    CHANGING fp_i_input TYPE ty_t_input.
*  * Local Data Declaration
  DATA: lv_filename TYPE string. "File Name

  lv_filename = fp_p_file.

* Uploading the file from Presentation Server
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_filename
      filetype                = c_filetype
      has_field_separator     = c_true
    CHANGING
      data_tab                = fp_i_input[] "INPUT FILE
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
  IF sy-subrc IS NOT INITIAL.
    MESSAGE i023 WITH lv_filename. " File could not be read from &
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS NOT INITIAL



ENDFORM. " F_UPLOAD_PRES
*&---------------------------------------------------------------------*
*&      Form  F_GET_APPS_SERVER
*&---------------------------------------------------------------------*
*       Upload Files from Applicationn Server
*----------------------------------------------------------------------*
*      <--FP_GV_FILE  INPUT FILE
*      <--FP_I_INPUT  INPUT TABLE
*----------------------------------------------------------------------*
FORM f_get_apps_server  CHANGING fp_gv_file TYPE localfile " Local file for upload/download
                                 fp_i_input TYPE ty_t_input .
* Application file can be uploaded in 2 ways -
* Either from Logical file path or from direct application file
  IF rb_app IS NOT INITIAL.
*   If Logical File option is selected.
    IF rb_alog IS NOT INITIAL.
*     Retriving physical file paths from logical file name
      PERFORM f_logical_to_physical USING p_alog
                                 CHANGING fp_gv_file.
    ELSE. " ELSE -> IF rb_alog IS NOT INITIAL
      fp_gv_file = p_afile.
    ENDIF. " IF rb_alog IS NOT INITIAL
*   Uploading the files from Application Server
    PERFORM f_upload_apps USING fp_gv_file
                       CHANGING fp_i_input[].
  ENDIF. " IF rb_app IS NOT INITIAL

ENDFORM. " F_GET_APPS_SERVER
*&---------------------------------------------------------------------*
*&      Form  F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*       Retriving physical file paths from logical file name
*----------------------------------------------------------------------*
*      -->FP_P_ALOG  LOGICAL PATH NAME
*      <--FP_GV_FILE  LOGICAL FILE
*----------------------------------------------------------------------*
FORM f_logical_to_physical  USING    fp_p_alog TYPE pathintern  " Logical path name
                            CHANGING fp_gv_file TYPE localfile. " Local file for upload/download
* Local Data Declaration
  DATA: li_input   TYPE zdev_t_file_list_in,    "Local Input table
        lwa_input  TYPE zdev_file_list_in,      "Local work area
        li_output  TYPE zdev_t_file_list_out,   "Local Output Table
        li_error   TYPE zdev_t_file_list_error. "Local error table

  FIELD-SYMBOLS : <lfs_output> TYPE zdev_file_list_out. " Output for
*FM ZDEV_DIRECTORY_FILE_LIST
* Passing the logical file path to get the physical file path
  lwa_input-path = fp_p_alog. "ZLEX_CDD_0016_TBP Logical Path
  APPEND lwa_input TO li_input.
  CLEAR lwa_input.

* Retriving all files within the directory
  CALL FUNCTION 'ZDEV_DIRECTORY_FILE_LIST'
    EXPORTING
      im_identifier      = abap_true "X
      im_input           = li_input  "INPUT TABLE
    IMPORTING
      ex_output          = li_output "OUTPUT TABLE
      ex_error           = li_error  "EROR TABLE
    EXCEPTIONS
      no_input           = 1
      invalid_identifier = 2
      no_data_found      = 3
      OTHERS             = 4.
  IF sy-subrc IS INITIAL AND
     li_error IS INITIAL.
*   Getting the file path
    READ TABLE li_output ASSIGNING <lfs_output> INDEX 1.
    IF sy-subrc IS INITIAL.
      CONCATENATE <lfs_output>-physical_path
             <lfs_output>-filename
             INTO fp_gv_file.
    ENDIF. " IF sy-subrc IS INITIAL
    UNASSIGN <lfs_output>.
  ELSE. " ELSE -> IF sy-subrc IS INITIAL
*   Logical file path & could not be read for input files.
    MESSAGE i037 WITH fp_p_alog.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS INITIAL AND

* If Input file could not be retrieved, then issue an error message
  IF fp_gv_file IS INITIAL.
    MESSAGE i103 WITH fp_p_alog.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF fp_gv_file IS INITIAL

ENDFORM. " F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_APPS
*&---------------------------------------------------------------------*
*       Upload input file from Presentation Server
*----------------------------------------------------------------------*
*      -->FP_GV_FILE  INPUT FILE LOCATION
*      <--FP_I_INPUT[] INPUT DATA
*----------------------------------------------------------------------*
FORM f_upload_apps  USING    fp_p_file TYPE localfile    " Local file for upload/download
                    CHANGING fp_i_input TYPE ty_t_input. "INPUT FILE

* * Local Variables
  DATA: lv_input_line   TYPE cacl_string,    "Input Raw lines
        lwa_input       TYPE ty_input,       "Input work area
        lref_error      TYPE REF TO cx_root, " Abstract Superclass for
*All Global Exceptions
        lv_msg          TYPE cacl_string, " Message
        lv_subrc        TYPE sysubrc.     "SY-SUBRC value.

  TRY.
* Opening the Dataset for File Read
      OPEN DATASET fp_p_file FOR INPUT IN TEXT MODE ENCODING DEFAULT. " Set as Ready for Input
      " Set as Ready for Input
    CATCH cx_root INTO lref_error.
      lv_msg = lref_error->get_text( ).
      MESSAGE i000 WITH lv_msg.
      LEAVE LIST-PROCESSING.
  ENDTRY.

  IF sy-subrc IS INITIAL.
*   Reading the Header Input File
    WHILE ( lv_subrc EQ 0 ).
      TRY.
          READ DATASET fp_p_file INTO lv_input_line.
*     Sorting the SY-SUBRC value. To be used as loop-break condn.
          lv_subrc = sy-subrc.
          IF lv_subrc IS INITIAL.
*       Aligning the values as per the structure
            SPLIT lv_input_line AT
            cl_abap_char_utilities=>horizontal_tab
            INTO lwa_input-vbeln
                 lwa_input-posnr.

*  MOVE INPUT FROM WORK AREA INTO INPUT TABLE.
            APPEND lwa_input TO fp_i_input.

*  Clear work area.
            CLEAR: lv_input_line,
                   lwa_input.
          ENDIF. " IF lv_subrc IS INITIAL
        CATCH cx_root INTO lref_error.
          lv_msg = lref_error->get_text( ).
          MESSAGE i000 WITH lv_msg.
          LEAVE LIST-PROCESSING.
      ENDTRY.
    ENDWHILE.
* If File Open fails, then populating the Error Log
  ELSE. " ELSE -> IF lv_subrc IS INITIAL
*   Leaving the program if OPEN Dataset fails for data upload
*    MESSAGE i053 WITH fp_p_file.  ##MG_MISSING
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS INITIAL

  TRY.
* Closing the Dataset.
      CLOSE DATASET fp_p_file.
    CATCH cx_root INTO lref_error.
      lv_msg = lref_error->get_text( ).
      MESSAGE i000 WITH lv_msg.
      LEAVE LIST-PROCESSING.
  ENDTRY.


ENDFORM. " F_UPLOAD_APPS
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_INPUT
*&---------------------------------------------------------------------*
*       Validating all inputs
*----------------------------------------------------------------------*
*           <--fp_i_report      Report table
*----------------------------------------------------------------------*
FORM f_validate_input CHANGING fp_i_report TYPE ty_t_report.


** Local Data Declaration.
  FIELD-SYMBOLS: <lfs_input>            TYPE ty_input. "Field symbol for input data


* Local variable declaration
  DATA : lv_key        TYPE string,  "Key for error log
         lv_error      TYPE char1,   "Error Flag
         lv_count      TYPE sytabix, "Indicating the current record
         lv_message    TYPE string.  "Message local variable
*Local workarea declaration.
  DATA:
           lwa_error     TYPE ty_input_e, "Work area for Error input
           lwa_final     TYPE ty_input_f. "workarea for final table

*Local internal table declaration.
  DATA:  li_input_err   TYPE STANDARD TABLE OF ty_input_e. "Local Internal Table for error

  SELECT vbeln posnr
         FROM vbap INTO TABLE i_vbeln
         FOR ALL ENTRIES IN i_input
         WHERE vbeln = i_input-vbeln AND
               posnr = i_input-posnr.

*&-- Begin of changes for HANAtization on OTC_EDD_0285 by SMUKHER on 19-Aug-2019 in M1SK900335
    IF sy-subrc IS INITIAL.
     SORT i_vbeln BY vbeln posnr.
    ENDIF.
*&-- End of changes for HANAtization on OTC_EDD_0285 by SMUKHER on 19-Aug-2019 in M1SK900335

  LOOP AT i_input ASSIGNING <lfs_input> .

*   Get the line number of the file incrementing index by 1
    lv_count = sy-tabix. " For indicating the current record

    PERFORM f_validate_vbeln USING <lfs_input>
                                    lv_count
                           CHANGING fp_i_report
                                    li_input_err
                                    lwa_error.
* Writing in temporary internal table
    IF lwa_error IS NOT INITIAL.
      CLEAR lv_message.
      gv_ecount = gv_ecount + 1.
    ELSE. " ELSE -> IF lwa_error IS NOT INITIAL
      gv_scount = gv_scount + 1.

      lwa_final-vbeln = <lfs_input>-vbeln.
      lwa_final-posnr = <lfs_input>-posnr.

      INSERT lwa_final INTO TABLE i_final.
    ENDIF. " IF lwa_error IS NOT INITIAL
    CLEAR lwa_error.
  ENDLOOP. " LOOP AT i_input ASSIGNING <lfs_input>
  UNASSIGN <lfs_input>.
  IF li_input_err IS NOT INITIAL.
    APPEND  LINES OF li_input_err TO i_input_e.
  ENDIF. " IF li_input_err IS NOT INITIAL

  IF rb_vrfy = c_true.
    IF fp_i_report IS INITIAL.
      CLEAR: lv_error,
             lv_key,
             lv_message.
      MOVE  'All records are verified and correct'(048)
           TO lv_message.
*       Populating the report table
      PERFORM f_populate_report  USING lv_error
                                       lv_key
                                       lv_message
                              CHANGING fp_i_report.

* Total record in External File
      CLEAR: lv_error,
             lv_key,
             lv_message.
      MOVE  'Number of record in external data file'(049)
          TO lv_message.
      lv_key = lv_count.
*       Populating the report table
      PERFORM f_populate_report  USING lv_error
                                       lv_key
                                       lv_message
                              CHANGING fp_i_report.

*Remove similar records from error table.
* Sort final report with msgtyp and key so that errors of 1 record comes then error of 2nd
* record and so on.
      SORT fp_i_report BY msgtyp key.
      DELETE ADJACENT DUPLICATES FROM fp_i_report COMPARING ALL FIELDS.

    ENDIF. " IF fp_i_report IS INITIAL
  ENDIF. " IF rb_vrfy = c_true
  FREE: li_input_err[].
ENDFORM. " F_VALIDATE_INPUT
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_REPORT
*&---------------------------------------------------------------------*
*       populating Report
*----------------------------------------------------------------------*
*      -->FP_V_ERROR  Error identifier
*      -->FP_V_KEY  key combination of record and row
*      -->FP_V_MESSAGE  Message text
*      <--FP_I_REPORT  Report table
*----------------------------------------------------------------------*
FORM f_populate_report  USING    fp_v_error TYPE char1         " Populate_report using of type CHAR1
                                 fp_v_key  TYPE string         "key combination
                                 fp_v_message TYPE string      "message text
                        CHANGING fp_i_report TYPE ty_t_report. "report table

  DATA: lwa_report    TYPE ty_report. "Work area for error log table
  CLEAR lwa_report.
  lwa_report-key    = fp_v_key. " Record key
  IF fp_v_error = c_true.
    lwa_report-msgtyp = c_error. " Error flag
  ELSE. " ELSE -> IF fp_v_error = c_true
    lwa_report-msgtyp = c_success. " Success flag
  ENDIF. " IF fp_v_error = c_true
  lwa_report-msgtxt = fp_v_message. " Message text
  APPEND  lwa_report TO  fp_i_report.

ENDFORM. " F_POPULATE_REPORT
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_ERROR
*&---------------------------------------------------------------------*
*       Populate error table
*----------------------------------------------------------------------*
*      -->FP_V_MESSAGE  message text
*      <--FP_WA_ERROR  error record
*      <--FP_INPUT_ERR  error table
*----------------------------------------------------------------------*
FORM f_populate_error  USING    fp_v_message TYPE string        "message text
                       CHANGING fp_wa_error TYPE ty_input_e     "error record
                                fp_input_err TYPE ty_t_input_e. "error table

*  Populating the Error Record table for Application server download
* in case Application Server option is chosen
  fp_wa_error-message = fp_v_message. " Message Text
  APPEND fp_wa_error TO fp_input_err.

ENDFORM. "f_populate_error
*&---------------------------------------------------------------------*
*&      Form  F_MOVE_FILES
*&---------------------------------------------------------------------*
*   In case the file was uploaded from Application server, then
*   Moving them in Processed / Error folder depending upon Final
*   Status of Posting.
*----------------------------------------------------------------------*
*      -->FP_GV_FILE  File containing the Input File Path
*----------------------------------------------------------------------*
FORM f_move_files  USING    fp_gv_file TYPE localfile. " Local file for upload/download

*   In case the file was uploaded from Application server, then
*   Moving them in Processed / Error folder depending upon Final
*   Status of Posting.
  IF rb_app IS NOT INITIAL.
    IF rb_post = c_true.
*     If Posting is done, then moving the files to DONE folder
*     Moving Input File
      PERFORM f_move USING    fp_gv_file
                     CHANGING i_report.
    ENDIF. " IF rb_post = c_true
*       Moving Error File
    IF i_input_e IS NOT INITIAL.
      PERFORM f_move_error USING fp_gv_file
                                 i_input_e[].
    ENDIF. " IF i_input_e IS NOT INITIAL
  ENDIF. " IF rb_app IS NOT INITIAL


ENDFORM. " F_MOVE_FILES
*&---------------------------------------------------------------------*
*&      Form  F_MOVE
*&---------------------------------------------------------------------*
*       Moving Source File to DONE Folder if Validate & Post option is
*       chosen
*----------------------------------------------------------------------*
*      -->fp_v_source Source file
*      <--fP_I_REPORT  table containing the report
*----------------------------------------------------------------------*
FORM f_move  USING    fp_v_source TYPE localfile    " Local file for upload/download
             CHANGING fp_i_report TYPE ty_t_report. "report table

*  * Local Data
  DATA: lv_file    TYPE localfile, "File Name
        lv_name    TYPE localfile, "Path Name
        lv_return  TYPE sysubrc,   "Return Code
        lwa_report TYPE ty_report. "Report

* Spitting File Path & File Name
*if fp_i_final is not INITIAL.
  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_v_source
    IMPORTING
      pathname = lv_file
      filename = lv_name.

* Changing the file path to DONE folder
  REPLACE c_tobeprscd IN lv_file WITH 'DONE'(022) .
  CONCATENATE lv_file lv_name INTO lv_file.
* Move the file
  PERFORM f_file_move  USING    fp_v_source
                                lv_file
                       CHANGING lv_return.
  IF lv_return IS INITIAL.
*   Assigning the archived file name to global variable
    gv_archive_gl_1 = lv_file.
  ELSE. " ELSE -> IF lv_return IS INITIAL
*   Populating the error message in case Input Header file not moved
    lwa_report-msgtyp = c_error.
*   Forming the text.
    MESSAGE i000 WITH  'Input file'(023) " & & & &
                       lv_file
                       'Not moved'(024)
            INTO lwa_report-msgtxt.
    APPEND lwa_report TO fp_i_report.
    CLEAR lwa_report.
  ENDIF. " IF lv_return IS INITIAL
ENDFORM. " F_MOVE
*&---------------------------------------------------------------------*
*&      Form  F_MOVE_ERROR
*&---------------------------------------------------------------------*
*        Moving Error file to Error folder.
*----------------------------------------------------------------------*
*      -->FP_p_aFILE  Source file path
*      -->fP_I_INPUT_E[]  Error file with erroneous records
*----------------------------------------------------------------------*
FORM f_move_error  USING    fp_p_afile TYPE localfile " Local file for upload/download
                            fp_i_input_e TYPE ty_t_input_e.
*  * Local Data
  DATA: lv_file     TYPE localfile, "File Name
        lv_name     TYPE localfile, "File Name
        lv_data     TYPE string.    "Output data string

  FIELD-SYMBOLS: <lfs_input_e> TYPE ty_input_e.

* Spitting Filae Path & File Name
  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_p_afile
    IMPORTING
      pathname = lv_file
      filename = lv_name.

* Changing the file path to ERROR folder
  REPLACE c_tobeprscd  IN lv_file WITH c_err_fold .
  CONCATENATE lv_file c_slash lv_name INTO lv_file.

* Write the records
  OPEN DATASET lv_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " Output type
  IF sy-subrc NE 0.
    MESSAGE i006. "Error Folder could not be opened
*Only use EXIT within Loops otherwise use RETURN.
    RETURN.
  ELSE. " ELSE -> IF sy-subrc NE 0
*   Forming the header text line
    CONCATENATE 'Sales Order'(013)
                'Item'(014)
                'Message'(052)
             INTO lv_data
       SEPARATED BY c_slash.
    TRANSFER lv_data TO lv_file.
    CLEAR lv_data.

*   Passing the Erroneous Record
    LOOP AT fp_i_input_e ASSIGNING <lfs_input_e>. "INTO lwa_input_e.
      CONCATENATE <lfs_input_e>-vbeln
                  <lfs_input_e>-posnr
                  <lfs_input_e>-message
            INTO lv_data
           SEPARATED BY c_slash.
*     Transferring the data into application server.
      TRANSFER lv_data TO lv_file.
      CLEAR lv_data.
    ENDLOOP. " IF sy-subrc NE 0
  ENDIF. " IF sy-subrc NE 0
* Closing the Dataset.
  CLOSE DATASET lv_file.



ENDFORM. " F_MOVE_ERROR
*&---------------------------------------------------------------------*
*&      Form  F_BDC_SP_ATP_CHECK
*&---------------------------------------------------------------------*
*       call transaction for storage bin creation
*----------------------------------------------------------------------*
*      -->fP_<LFS_INPUT>          Field symbol for input
*      <--fP_V_ERROR              Error flag
*      <--FP_V_KEY                Key indicator
*      <--FP_V_MESSAGE            message text
*      <--FP_I_REPORT             Report table
*      <--FP_I_INPUT_E            error table
*      <--FP_V_ECOUNT             error count
*      <--FP_V_SCOUNT             Success count
*----------------------------------------------------------------------*
FORM  f_bdc_so_atp_check  USING   fp_lfs_input TYPE ty_input_f   "Field symbol for input
                  CHANGING fp_v_error   TYPE char1        " V_error of type CHAR1
                           fp_v_key     TYPE string       "Key indicator
                           fp_v_message TYPE string       "message text
                           fp_i_report  TYPE ty_t_report  "report table
                           fp_i_input_e TYPE ty_t_input_e "error table
                           fp_v_ecount  TYPE   int2       " 2 byte integer (signed)
                           fp_v_scount  TYPE   int2.      " 2 byte integer (signed)
  DATA: lv_sitm TYPE posnr,
        wa_input TYPE ty_input.
  REFRESH i_bdcdata[].

  PERFORM f_bdc_dynpro      USING 'SAPMV45A' '0102'
                            CHANGING i_bdcdata[].
  PERFORM f_bdc_field       USING 'BDC_CURSOR' 'VBAK-VBELN'
                            CHANGING i_bdcdata[].
  PERFORM f_bdc_field       USING 'BDC_OKCODE' '/00'
                            CHANGING i_bdcdata[].
  PERFORM f_bdc_field       USING 'VBAK-VBELN' fp_lfs_input-vbeln
                            CHANGING i_bdcdata[].

  LOOP AT i_final INTO wa_input
                  WHERE vbeln EQ fp_lfs_input-vbeln .
    PERFORM f_bdc_dynpro      USING 'SAPMV45A' '4001'
                              CHANGING i_bdcdata[].
    PERFORM f_bdc_field       USING 'BDC_OKCODE' '=PORE'
                              CHANGING i_bdcdata[].
    PERFORM f_bdc_dynpro      USING 'SAPMV45A' '4001'
                              CHANGING i_bdcdata[].
    PERFORM f_bdc_field       USING 'BDC_OKCODE' '=POPO'
                              CHANGING i_bdcdata[].
    PERFORM f_bdc_dynpro      USING 'SAPMV45A' '0251'
                              CHANGING i_bdcdata[].
    PERFORM f_bdc_field       USING 'BDC_CURSOR' 'RV45A-POSNR'
                              CHANGING i_bdcdata[].
    PERFORM f_bdc_field       USING 'BDC_OKCODE' '=POSI'
                              CHANGING i_bdcdata[].

    lv_sitm = wa_input-posnr.
    PERFORM f_bdc_field     USING 'RV45A-POSNR' lv_sitm
                            CHANGING i_bdcdata[].
  ENDLOOP.
  PERFORM f_bdc_dynpro      USING 'SAPMV45A' '4001'
                            CHANGING i_bdcdata[].
  PERFORM f_bdc_field       USING 'BDC_OKCODE' '=PORE'
                            CHANGING i_bdcdata[].
  PERFORM f_bdc_field       USING 'BDC_CURSOR' 'VBAP-POSNR(01)'
                            CHANGING i_bdcdata[].
  PERFORM f_bdc_field       USING 'RV45A-VBAP_SELKZ(01)' 'X'
                            CHANGING i_bdcdata[].
  PERFORM f_bdc_dynpro      USING 'SAPMV45A' '4001'
                            CHANGING i_bdcdata[].

  PERFORM f_bdc_field       USING 'BDC_OKCODE' '=SICH'
                            CHANGING i_bdcdata[].

  IF i_bdcdata[] IS NOT INITIAL.
* Call Transaction
    PERFORM f_call_transaction USING i_bdcdata
                                  fp_lfs_input
                                  c_va02
                         CHANGING fp_i_report
                                  fp_i_input_e
                                  fp_v_error
                                  fp_v_key
                                  fp_v_message
                                  fp_v_ecount
                                  fp_v_scount .
    CLEAR lv_sitm.
    REFRESH i_bdcdata.

    IF NOT fp_v_error EQ abap_true .
      CONCATENATE  fp_lfs_input-vbeln
                   fp_lfs_input-posnr
                    INTO fp_v_key
            SEPARATED BY c_slash.

*     Passing Successful message
      CLEAR: fp_v_message.
      MOVE 'ATP Check Run Successful'(045)
          TO fp_v_message.

*   Populating the report table
      PERFORM f_populate_report  USING fp_v_error
                                       fp_v_key
                                       fp_v_message
                             CHANGING  fp_i_report.
    ENDIF. " IF NOT fp_v_error EQ abap_true
  ENDIF. " IF i_bdcdata[] IS NOT INITIAL
ENDFORM. " F_BDC_VA02
*&---------------------------------------------------------------------*
*&      Form  F_CALL_TRANSACTION
*&---------------------------------------------------------------------*
*       Subroutine for Call transaction
*----------------------------------------------------------------------*
*      -->FP_I_BDCDATA                For BDC data
*      -->FP_LFS_INPUT                For final record
*      -->fP_lC_tcode                 current transaction code
*      <--FP_I_REPORT                 final report
*      <--FP_I_INPUT_E                error report
*      <--FP_lV_ERROR                 error
*      <--FP_lV_KEY                   key indicator
*      <--FP_lV_MESSAGE               message text
*      <--FP_V_ECOUNT                 error count
*      <--FP_V_SCOUNT                 success count
*----------------------------------------------------------------------*
FORM f_call_transaction  USING    fp_i_bdcdata  TYPE ty_t_bdcdata "For BDC data
                                  fp_lfs_input  TYPE ty_input_f   "For final record
                                  fp_lc_tcode   TYPE sytcode      " Current Transaction Code
                         CHANGING fp_i_report   TYPE ty_t_report  " final report
                                  fp_i_input_e  TYPE ty_t_input_e "error table
                                  fp_lv_error   TYPE char1        " Lv_error of type CHAR1
                                  fp_lv_key     TYPE string       " key indicator
                                  fp_lv_message TYPE string       "message text
                                  fp_v_ecount   TYPE int2         " 2 byte integer (signed)
                                  fp_v_scount   TYPE int2.        " 2 byte integer (signed)

*  * DataDeclaration
  DATA:    lwa_report TYPE ty_report,       "Local work area for error log
           lwa_bdcmsg TYPE bdcmsgcoll,      "BDC Message
           lwa_error  TYPE ty_input_e,      "work area for error table
           lwa_return TYPE bapiret2,        "To read BAPI message
           lv_par1    TYPE char50,          "Parameter1 to passed in BAPI
           lv_par2    TYPE char50,          "Parameter2 to passed in BAPI
           lv_par3    TYPE char50,          "Parameter3 to passed in BAPI
           lv_par4    TYPE char50,          "Parameter4 to passed in BAPI
           lv_num     TYPE bapiret2-number. "Message Number

  CONSTANTS: lc_mode  TYPE ctu_mode VALUE 'N'. "Update mode for call transaction
  DATA:   li_bdcmsg   TYPE STANDARD TABLE OF bdcmsgcoll. " Collecting messages in the SAP System
* create the record via call transaction and send errors to a BDC session.
*The records that fail here will NOT be part of the error file as they
*should be reprocessed through SM35
  REFRESH i_bdcmsg.
  CALL TRANSACTION fp_lc_tcode
        USING fp_i_bdcdata
              MODE lc_mode
              UPDATE c_update
              MESSAGES INTO i_bdcmsg.
*  IF sy-subrc = 0.
  IF i_bdcmsg IS NOT INITIAL.

    li_bdcmsg[] = i_bdcmsg[].
    DELETE li_bdcmsg WHERE msgtyp = c_success " Bdcmsg where of type
                     OR    msgtyp = c_warning " Or of type
                     OR    msgtyp = c_info.   " Or of type
*See if error exist while doing call transaction
    READ TABLE li_bdcmsg INTO lwa_bdcmsg INDEX 1.

*If error exist
    IF sy-subrc = 0.
      fp_lv_error = abap_true. " Setting error changing parameter
**      **Error Count
      fp_v_ecount = fp_v_ecount + 1.
      fp_v_scount  = fp_v_scount - 1.

*     Populating the error message in case Call transaction Fails
      lwa_report-msgtyp = c_error.
* Forming the Key
*Key is formed based on Sales order & Item
      CONCATENATE  fp_lfs_input-vbeln
                   fp_lfs_input-posnr

*  To reuse the internal tbl/structure/variable in different
*  performs we have passed the parameter in USING.
                   INTO fp_lv_key
                   SEPARATED BY c_slash.
      lwa_report-key = fp_lv_key.
*     Forming the text.
      CLEAR : lwa_return ,
              lv_par1 ,
              lv_par2 ,
              lv_par3 ,
              lv_par4,
              lv_num.

      lv_par1 = lwa_bdcmsg-msgv1.
      lv_par2 = lwa_bdcmsg-msgv2.
      lv_par3 = lwa_bdcmsg-msgv3.
      lv_par4 = lwa_bdcmsg-msgv4.
      lv_num  = lwa_bdcmsg-msgnr.

*Call BAPI to retrieve the Error Message Text
      CALL FUNCTION 'BALW_BAPIRETURN_GET2'
        EXPORTING
          type   = lwa_bdcmsg-msgtyp "  of type
          cl     = lwa_bdcmsg-msgid
          number = lv_num
          par1   = lv_par1
          par2   = lv_par2
          par3   = lv_par3
          par4   = lv_par4
        IMPORTING
          return = lwa_return.

**To reuse the internal tbl/structure/variable in different
*  performs we have passed the parameter in USING.
      lwa_report-msgtxt = lwa_return-message.
      fp_lv_message     = lwa_return-message.
*Populate the Error Log
      APPEND lwa_report TO fp_i_report.
      CLEAR lwa_report.

*if session ceation fails, then increase the error count by 1.
      fp_v_ecount = fp_v_ecount + 1.
      fp_v_scount = fp_v_scount - 1.
*         Populating Error file
      lwa_error-vbeln = fp_lfs_input-vbeln.
      lwa_error-posnr = fp_lfs_input-posnr.

      PERFORM f_populate_error USING fp_lv_message
                            CHANGING lwa_error
                                     fp_i_input_e.
    ENDIF. " IF sy-subrc = 0

  ENDIF. " IF i_bdcmsg IS NOT INITIAL
ENDFORM. " F_CALL_TRANSACTION
**&---------------------------------------------------------------------*
**&      Form  F_SO_ATP_CHECK
**&---------------------------------------------------------------------*
**       Call transaction for bin creation.
**----------------------------------------------------------------------*
**      -->fP_I_input       final table
*       <--fp_v_scount     success count
*       <--fp_v_ecount     error count
**----------------------------------------------------------------------*
FORM f_so_atp_check  USING    fp_i_input TYPE ty_t_input_f "final table
                    CHANGING fp_v_scount  TYPE int2       "success count
                             fp_v_ecount  TYPE int2.      "error count

*Local variable declaration.
  DATA:
           lv_error      TYPE  char1,  " Error flag
           lv_key        TYPE  string, " Key Indicator
           lv_message    TYPE  string. " Message Text


*local internal table declaration.
  DATA:
           li_report     TYPE  ty_t_report,  "Report File
           li_input_e    TYPE  ty_t_input_e, "Error File
           i_input_f     TYPE ty_t_input_f.

  FIELD-SYMBOLS: <lfs_input>     TYPE  ty_input_f. "Field symbol for the Input.

  i_input_f = fp_i_input.
  SORT i_input_f BY vbeln.
  DELETE ADJACENT DUPLICATES FROM i_input_f COMPARING vbeln.

*  if fp_i_input[] is not initial.
  IF i_input_f[] IS NOT INITIAL.
*   Looping at the final Table assigning it to its field symbol.
*    loop at fp_i_input assigning <lfs_input>.
    LOOP AT i_input_f ASSIGNING <lfs_input>.
      PERFORM f_bdc_so_atp_check USING <lfs_input>
                        CHANGING lv_error
                                 lv_key
                                 lv_message
                                 li_report
                                 li_input_e
                                 fp_v_ecount
                                 fp_v_scount.
*Preparing report file and Error file.
      APPEND LINES OF li_report  TO i_report. "Report file
      APPEND LINES OF li_input_e TO i_input_e. "Error file

      FREE: li_report,
            li_input_e.

    ENDLOOP. " LOOP AT fp_i_input ASSIGNING <lfs_input>
    UNASSIGN <lfs_input>.
*    Delete duplicate error records.
* Sort final report with msgtyp and key, so that errors of 1 record comes then error of 2nd
* record and so on.
    SORT i_report BY msgtyp key.

    DELETE ADJACENT DUPLICATES FROM i_report COMPARING ALL FIELDS.
  ENDIF. " IF fp_i_input[] IS NOT INITIAL
ENDFORM. " F_SO_ATP_CHECK
*&---------------------------------------------------------------------*
*&      Form  F_CLEAR
*&---------------------------------------------------------------------*
*      Subroutine to clear internal tables.
*----------------------------------------------------------------------*
FORM f_clear .

  REFRESH:    i_input[],   "file to upload
              i_report[],  "For Report display
              i_input_e[], "For error in records
              i_final[],   "For final display
              i_bdcdata[], "For BDC data
              i_bdcmsg[].  "For BDC msg

  FREE:       i_input[],   "file to upload
              i_report[],  "For Report display
              i_input_e[], "For error in records
              i_final[],   "For final display
              i_bdcdata[], "For BDC data
              i_bdcmsg[].  "For BDC msg

* Clear Global Variables:
  CLEAR: gv_ecount, gv_scount.
  FREE:  gv_ecount, gv_scount.
ENDFORM. " F_CLEAR
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_VBELN
*&---------------------------------------------------------------------*
*       Validate the Sales order number in file is not blank
*----------------------------------------------------------------------*
*      -->FP_INPUT        Input file
*      -->FP_COUNT        Index
*      <--FP_I_REPORT     Final report
*      <--FP_I_INPUT_ERR  Error table
*      <--FP_INPUT_E      Work area
*----------------------------------------------------------------------*
FORM f_validate_vbeln  USING    fp_input       TYPE  ty_input     "Input workarea
                                fp_count       TYPE  sytabix      " Index of Internal Tables
                       CHANGING fp_i_report    TYPE  ty_t_report  "rEPORT TABLE
                                fp_i_input_err TYPE  ty_t_input_e "Error table
                                fp_input_e     TYPE  ty_input_e.  "error workarea

*Local variable declaration.
  DATA: lv_message    TYPE string, "Message local variable
        lv_cnt_numc   TYPE numc10. "Counter of NUMC type for concatenating

*Pass value of index to counter.
  lv_cnt_numc = fp_count.

  SHIFT lv_cnt_numc LEFT DELETING LEADING c_zero.
* Checking Sales order no. is valid
  IF fp_input-vbeln IS INITIAL.
    CLEAR lv_message.

*       Forming the Message
    MOVE 'Sales order no has no value'(033)
    TO lv_message.

*Prepare error table.
    PERFORM f_error_record   USING fp_input        "Input workarea
                                   lv_cnt_numc     " Index of Internal Tables
                                   lv_message      "Message local variable
                         CHANGING  fp_i_report     "rEPORT TABLE
                                   fp_input_e      "Error workarea
                                   fp_i_input_err. "Error internal table

  ELSE. " ELSE -> IF fp_input-vbeln IS INITIAL
*Check Sales order no. is valid or not
    READ TABLE i_vbeln TRANSPORTING NO FIELDS
          WITH KEY vbeln = fp_input-vbeln BINARY SEARCH. "Sales order no.
    IF sy-subrc <> 0.
      CLEAR lv_message. "message

*       Forming the Message
      CONCATENATE 'Sales order no'(013) fp_input-vbeln
                  'is invalid'(016)
                  INTO lv_message SEPARATED BY space.

*Prepare error table.
      PERFORM f_error_record   USING fp_input        "Input workarea
                                     lv_cnt_numc     "Index of Internal Tables
                                     lv_message      "Message local variable
                           CHANGING  fp_i_report     "REPORT TABLE
                                     fp_input_e      "Error workarea
                                     fp_i_input_err. "Error internal table

    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF fp_input-vbeln IS INITIAL
ENDFORM. " F_VALIDATE_VBELN
*&---------------------------------------------------------------------*
*&      Form  F_ERROR_RECORD
*&---------------------------------------------------------------------*
*      Subroutine called in case of an error condition which
*       further populates the error table
*----------------------------------------------------------------------*
*           --> fp_input       input record
*           -->fp_cnt_numc     Numeric Character Field, Length 10
*           -->fp_message      message
*           <--fp_i_report    report table
*           <--fp_input_e     error workarea
*           <--fp_i_input_err error table
*----------------------------------------------------------------------*
FORM f_error_record  USING  fp_input       TYPE ty_input      "input record
                            fp_cnt_numc    TYPE numc10        " Numeric Character Field, Length 10
                            fp_message     TYPE string        "message
                   CHANGING fp_i_report    TYPE ty_t_report   "report table
                            fp_input_e     TYPE ty_input_e    "error workarea
                            fp_i_input_err TYPE ty_t_input_e. "error table.
*Local variable declaration.
  DATA: lv_error  TYPE char1,  "Error Flag
        lv_key    TYPE string. "Key for error log

*Populate this local flag to indicate error in the current line
  lv_error   = c_true.

  CONCATENATE fp_cnt_numc
                       fp_input-vbeln
                       fp_input-posnr
                 INTO lv_key SEPARATED BY c_slash.

* Populating the report table
  PERFORM f_populate_report  USING lv_error     "error flag
                                   lv_key       "key of error flag
                                   fp_message   "message
                          CHANGING fp_i_report. "report table
*       Populating Error file
*    CLEAR: lwa_error.
  fp_input_e-vbeln = fp_input-vbeln.
  fp_input_e-posnr = fp_input-posnr.
  PERFORM f_populate_error USING fp_message
                        CHANGING fp_input_e
                                 fp_i_input_err.

ENDFORM. " F_ERROR_RECORD
*&---------------------------------------------------------------------*
*&      Form  F_f_bdc_dynpro
*&---------------------------------------------------------------------*
*  Perform for populating the BDCDATA with Program name and Screen no
*----------------------------------------------------------------------*
*      -->fp_v_program    Program Name
*      -->fp_v_dynpro     Screen Number
*      <--fp_i_bdcdata    BDC Table
*----------------------------------------------------------------------*
FORM f_bdc_dynpro  USING  fp_v_program  TYPE bdc_prog " BDC module pool
                          fp_v_dynpro TYPE bdc_dynr   " BDC Screen number
                  CHANGING fp_i_bdcdata TYPE ty_t_bdcdata.
* Local data declaration
  DATA: lwa_bdcdata TYPE bdcdata. " Batch input: New table field structure
  lwa_bdcdata-program  = fp_v_program.
  lwa_bdcdata-dynpro   = fp_v_dynpro.
  lwa_bdcdata-dynbegin = c_true.
  APPEND lwa_bdcdata TO fp_i_bdcdata.
ENDFORM. " f_bdc_dynpro
*&---------------------------------------------------------------------*
*&      Form  F_f_bdc_field
*&---------------------------------------------------------------------*
*   Perform for populating the BDCDATA using Field name and Field val
*----------------------------------------------------------------------*
*      -->fp_v_name   Field name
*      -->fp_v_value  Field value
*     <--fp_i_bdcdata  BDC Table
*----------------------------------------------------------------------*
FORM f_bdc_field  USING   fp_v_name TYPE any
                         fp_v_value TYPE any
                CHANGING fp_i_bdcdata TYPE ty_t_bdcdata.
* Local data declaration
  DATA: lwa_bdcdata TYPE bdcdata. " Batch input: New table field structure
  IF NOT fp_v_value IS INITIAL.
    lwa_bdcdata-fnam = fp_v_name. "field name
    lwa_bdcdata-fval = fp_v_value. "field value.
    APPEND lwa_bdcdata TO fp_i_bdcdata.
  ENDIF. " IF NOT fp_v_value IS INITIAL

ENDFORM. " f_bdc_field
*&---------------------------------------------------------------------*
*&      Form  FILL_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_input .
  DATA: lwa_input TYPE ty_input.
  LOOP AT s_sitm.
    lwa_input-vbeln = p_sord.
    lwa_input-posnr = s_sitm-low.
    APPEND lwa_input TO i_input.
  ENDLOOP.
ENDFORM.                    " FILL_INPUT
