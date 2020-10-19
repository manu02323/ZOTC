*&---------------------------------------------------------------------*
*&  Include           ZOTCN091O_EXT_GRP_BOM_SUB
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    : ZOTCN091O_EXT_GRP_BOM_SUB                               *
* TITLE      : Convert Sales BOM                                       *
* DEVELOPER  : Rajiv Banerjee/Jayanta Ray                              *
* OBJECT TYPE: Conversion                                              *
* SAP RELEASE: SAP ECC 6.0                                             *
*----------------------------------------------------------------------*
* WRICEF ID: D3_OTC_CDD_0091_Convert Sales BOM                         *
*----------------------------------------------------------------------*
* DESCRIPTION: BOMs will be extended to plants using custom BDC program*
*              automating transaction code CS07.                       *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
*   DATE        USER    TRANSPORT    DESCRIPTION                       *
* =========== ======== ===========  ===================================*
* 09-MAY-2016  RBANERJ1  E1DK917998  Initial Development               *
*&---------------------------------------------------------------------*
* 19-Nov-2016  NGARG    E1DK917998  Defect#6766: Capture the specific  *
*                                   information type message as error  *
*                                   message.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
* This perform hide/ unhide selection screen parameters based on user
* selection
*----------------------------------------------------------------------*
FORM f_modify_screen .
  LOOP AT SCREEN .
*-- Presentation Server Option is NOT chosen
    IF rb_pres NE c_true.
*-- Hiding Presentation Server file paths with modifidd MI3.
      IF screen-group1 = c_groupmi3.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
*-- Presentation Server Option IS chosen
    ELSE. " ELSE -> IF rb_pres NE c_true
*-- Disaplying Presentation Server file paths with modifidd MI3.
      IF screen-group1 = c_groupmi3.
        screen-active = c_one.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
    ENDIF. " IF rb_pres NE c_true
*-- Application Server Option is NOT chosen
    IF rb_app NE c_true.
*-- Hiding 1) Application Server file Physical paths with modifid MI2
*     2) Logical Filename Radio Button with with modifid MI5
*     3) Logical Filename input with modifid MI7
      IF screen-group1 = c_groupmi2
         OR screen-group1 = c_groupmi5
         OR screen-group1 = c_groupmi7.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi2
*--  Application Server Option IS chosen
    ELSE. " ELSE -> IF rb_app NE c_true
*-- If Application Server Physical File Radio Button is chosen
      IF rb_aphy EQ c_true.
*       Dispalying Application Server Physical paths with modifid MI2
        IF screen-group1 = c_groupmi2.
          screen-active = c_one.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi2
*       Hiding Logical Filaename input with modifid MI7
        IF screen-group1 = c_groupmi7.
          screen-active = c_zero.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi7
*     If Application Server Logical File Radio Button is chosen
      ELSE. " ELSE -> IF rb_aphy EQ c_true
*       Hiding Application Server - Physical paths with modifidd MI2
        IF screen-group1 = c_groupmi2.
          screen-active = c_zero.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi2
*       Displaying Logical Filaename input with modifid MI7
        IF screen-group1 = c_groupmi7.
          screen-active = c_one.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi7
      ENDIF. " IF rb_aphy EQ c_true
    ENDIF. " IF rb_app NE c_true

  ENDLOOP. " LOOP AT SCREEN
ENDFORM. " F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_INPUT                                            *
*&---------------------------------------------------------------------*
*      Checking whether the file name has been entered or not          *
*----------------------------------------------------------------------*
FORM f_check_input .
* If No presentation Server file name is entered and Presentation
* Server Option has been chosen, then issuing the error message.
  IF rb_pres IS NOT INITIAL AND
     p_phdr IS INITIAL.
    MESSAGE i009.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF rb_pres IS NOT INITIAL AND

* For Application Server
  IF rb_app IS NOT INITIAL.
*   If No Application Server file name is entered and Application
*   Server Optin has been chosen, then issueing error message.
    IF rb_aphy IS NOT INITIAL AND
      p_ahdr IS INITIAL.
      MESSAGE i010.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF rb_aphy IS NOT INITIAL AND

* If No Logical File Path is entered and Logical File Path Option
* has been chosen, then issueing error message.
    IF rb_alog IS NOT INITIAL AND
       p_alog IS INITIAL.
      MESSAGE i011.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF rb_alog IS NOT INITIAL AND
  ENDIF. " IF rb_app IS NOT INITIAL
ENDFORM. " F_CHECK_INPUT
*&---------------------------------------------------------------------*
*&      Form  F_SET_MODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_SAVE  text
*      <--P_GV_MODE  text
*----------------------------------------------------------------------*
FORM f_set_mode  CHANGING  fp_gv_mode TYPE char10. " mode to decide post run or test run

* Choosing the Mode
  IF rb_post = c_true.
    fp_gv_mode = 'Post Run'(006).
  ELSE. " ELSE -> IF rb_post = c_true
    fp_gv_mode = 'Test Run'(007).
  ENDIF. " IF rb_post = c_true


ENDFORM. " F_SET_MODE
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_PRES
*&---------------------------------------------------------------------*

FORM f_upload_pres  USING     fp_p_file TYPE localfile. " Local file for upload/download
* Local Data Declaration
  DATA: lv_filename TYPE string,        "File Name
        lv_codepage TYPE abap_encoding. "code page
* Local Constant Declaration
  CONSTANTS: lc_true       TYPE char1  VALUE 'X',   " True of type CHAR1
             lc_file_type  TYPE char10 VALUE 'ASC', " ASC
             lc_11         TYPE sysubrc VALUE 11,   " Return Value of ABAP Statements
             lc_12         TYPE sysubrc VALUE 12,   " Return Value of ABAP Statements
             lc_13         TYPE sysubrc VALUE 13,   " Return Value of ABAP Statements
             lc_14         TYPE sysubrc VALUE 14,   " Return Value of ABAP Statements
             lc_15         TYPE sysubrc VALUE 15,   " Return Value of ABAP Statements
             lc_16         TYPE sysubrc VALUE 16,   " Return Value of ABAP Statements
             lc_17         TYPE sysubrc VALUE 17,   " Return Value of ABAP Statements
             lc_18         TYPE sysubrc VALUE 18,   " Return Value of ABAP Statements
             lc_19         TYPE sysubrc VALUE 19.   " Return Value of ABAP Statements

*if background mode is on,then file cannot be uploaded from presentation server
  IF sy-batch = lc_true.
    MESSAGE i164.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-batch = lc_true

  lv_filename = fp_p_file.

  IF gv_codepage IS NOT INITIAL.
    lv_codepage = gv_codepage.
  ELSE. " ELSE -> IF gv_codepage IS NOT INITIAL
    lv_codepage = space.
  ENDIF. " IF gv_codepage IS NOT INITIAL


* Uploading the file from Presentation Server
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_filename
      filetype                = lc_file_type
      has_field_separator     = cl_abap_char_utilities=>horizontal_tab
      codepage                = lv_codepage
    CHANGING
      data_tab                = i_final
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
      header_too_long         = lc_11
      unknown_dp_error        = lc_12
      access_denied           = lc_13
      dp_out_of_memory        = lc_14
      disk_full               = lc_15
      dp_timeout              = lc_16
      not_supported_by_gui    = lc_17
      error_no_gui            = lc_18
      OTHERS                  = lc_19.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE i162 WITH lv_filename.
    LEAVE LIST-PROCESSING.
  ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL

    DELETE i_final INDEX 1.

  ENDIF. " IF sy-subrc IS NOT INITIAL

ENDFORM. " F_UPLOAD_PRES
*&---------------------------------------------------------------------*
*&      Form  F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_ALOG  text
*      <--P_GV_FILE  text
*----------------------------------------------------------------------*
FORM f_logical_to_physical  USING    fp_p_alog  TYPE pathintern " Logical path name
                            CHANGING fp_gv_file TYPE localfile. " Local file for upload/download
* Local Constants
  CONSTANTS : lc_lp_ind TYPE char1 VALUE 'X'. "Value: X
* Local Data Declaration
  DATA: li_input   TYPE zdev_t_file_list_in,    "Local Input table
        lwa_input  TYPE zdev_file_list_in,      "Local work area
        li_output  TYPE zdev_t_file_list_out,   "Local Output Table
        lwa_output TYPE zdev_file_list_out,     "Local work area
        li_error   TYPE zdev_t_file_list_error. "Local error table

* Passing the logical file path to get the physical file path
  lwa_input-path = fp_p_alog.
  APPEND lwa_input TO li_input.
  CLEAR lwa_input.

* Retriving all files within the directory
  CALL FUNCTION 'ZDEV_DIRECTORY_FILE_LIST'
    EXPORTING
      im_identifier      = lc_lp_ind "Value: X
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
    MESSAGE i020. "No proper file exist for the logical file'.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc <> 0
  IF sy-subrc IS INITIAL AND
     li_error IS INITIAL.
*   Getting the file path
    READ TABLE li_output INTO lwa_output INDEX 1.
    IF sy-subrc IS INITIAL.
      CONCATENATE lwa_output-physical_path
                  lwa_output-filename
     INTO  fp_gv_file.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL AND

  FREE: li_input ,  "Local Input table
        li_output , "Local Output Table
        li_error  . "Local error table

ENDFORM. " F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_APPS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_FILE  text
*----------------------------------------------------------------------*
FORM f_upload_apps  USING  fp_p_file TYPE localfile. " Local file for upload/download

* Local constants
  CONSTANTS: lc_activity  TYPE char5  VALUE 'READ'. "File activity read/write
* Local Data Declaration
  DATA:   lv_msg          TYPE string,  "#EC NEEDED   " Message
          lv_flag         TYPE flag,    "General Flag
          lwa_final       TYPE ty_final,
          lv_subrc        TYPE sysubrc, " Return Value of ABAP Statements
          lv_input_line   TYPE string.  "Input Raw lines

  PERFORM f_authorization_check USING fp_p_file
                                      lc_activity
                             CHANGING lv_flag.
  IF lv_flag IS INITIAL.
 "---Authorized
    CLEAR lv_msg.
    CALL METHOD zdev_cl_abap_file_utilities=>meth_stat_pub_open_dataset
      EXPORTING
        im_file     = fp_p_file
        im_codepage = gv_codepage
      IMPORTING
        ex_subrc    = lv_subrc
        ex_message  = lv_msg.

    IF lv_subrc IS NOT INITIAL OR lv_msg IS NOT INITIAL.
      MESSAGE i967 WITH fp_p_file. "Error in opening the file.'
      LEAVE LIST-PROCESSING.
    ELSE. " ELSE -> IF lv_subrc IS NOT INITIAL OR lv_msg IS NOT INITIAL
      WHILE ( lv_subrc EQ 0 ).
        READ DATASET fp_p_file INTO lv_input_line.
        lv_subrc = sy-subrc.
        IF lv_subrc = 0.
          SPLIT lv_input_line AT cl_abap_char_utilities=>horizontal_tab
                 INTO lwa_final-matnr  " Material no.
                      lwa_final-werks. " Plant
          APPEND lwa_final TO i_final.
          CLEAR: lwa_final.
          CLEAR: lv_input_line.

        ENDIF. " IF lv_subrc = 0
      ENDWHILE.
    ENDIF. " IF lv_subrc IS NOT INITIAL OR lv_msg IS NOT INITIAL
    CLOSE DATASET fp_p_file.
    DELETE i_final INDEX 1.

  ELSE. " ELSE -> IF lv_flag IS INITIAL
                                 "Not Authorized
    MESSAGE i950 WITH fp_p_file. "No authorization for access to file &.
    LEAVE LIST-PROCESSING.

  ENDIF. " IF lv_flag IS INITIAL
ENDFORM. " F_UPLOAD_APPS
*&---------------------------------------------------------------------*
*&      Form  F_AUTHORIZATION_CHECK
*&---------------------------------------------------------------------*

FORM f_authorization_check  USING    fp_filename TYPE localfile " Local file for upload/download
                                     fp_activity TYPE char5     " Activity of type CHAR5
                            CHANGING fp_flag     TYPE flag.     " General Flag

* Local Data Declaration
  DATA: lv_file TYPE fileextern. " Physical file name

  lv_file = fp_filename.
*  Authorization for writing to dataset
  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
    EXPORTING
      activity         = fp_activity
      filename         = lv_file
    EXCEPTIONS
      no_authority     = 1
      activity_unknown = 2
      OTHERS           = 3.

  IF sy-subrc <> 0.
    fp_flag = abap_true.
  ELSE. " ELSE -> IF sy-subrc <> 0
    fp_flag = abap_false.
  ENDIF. " IF sy-subrc <> 0
ENDFORM. " F_AUTHORIZATION_CHECK
*&---------------------------------------------------------------------*
*&      Form  F_EXECUTE_BDC
*&---------------------------------------------------------------------*

FORM f_execute_bdc  USING    fp_i_valid TYPE ty_t_final
                    CHANGING fp_i_error TYPE ty_t_error.

* Local constants
  CONSTANTS: lc_cs07    TYPE char4 VALUE 'CS07', " Vd51 of type CHAR4
             lc_stlan_5 TYPE stlan VALUE '5',    " BOM Usage
             lc_mode    TYPE char1 VALUE 'N',    " Mode of type CHAR1
             lc_update  TYPE char1 VALUE 'S',    " Update of type CHAR4
*         Begin of change for Defect#6766 by NGARG
             lc_info    TYPE bdc_mart VALUE 'I',  " Batch input message type
             lc_29      TYPE bdc_mid VALUE '29',  " Batch input message ID
             lc_220     TYPE bdc_mnr VALUE '220'. " Batch input message number
*         End  of change for Defect#6766 by NGARG

* Local Data Declaration
  DATA:  li_valid     TYPE STANDARD TABLE OF ty_final,  "int.table for BoM data
         li_bdcmsg   TYPE STANDARD TABLE OF bdcmsgcoll. " Collecting messages in the SAP System

*-- Local work area
  DATA:lwa_error  TYPE ty_error,
       lwa_report TYPE ty_report.
*--Local variable
  DATA : lv_mode     TYPE char1, " Mode of type CHAR1
         lv_update   TYPE char1. " Update of type CHAR1

* Local field symbols
  FIELD-SYMBOLS : <lfs_valid> TYPE ty_final ,
                  <lfs_bdcmsg>  TYPE bdcmsgcoll. " Collecting messages in the SAP System

**if after passing the validation ,the BoM data is there in the table fp_i_valid[]
  IF fp_i_valid[] IS NOT INITIAL.

**assigning the table containing the valid records to a temporary table
    li_valid[] = fp_i_valid[].

**  sorting the li_valid based on marerial
    SORT li_valid BY matnr .
*
    LOOP AT fp_i_valid ASSIGNING <lfs_valid>.

      PERFORM f_bdc_dynpro      USING 'SAPLCSAL' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'RC29N-ZWERK'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
      PERFORM f_bdc_field       USING 'RC29N-MATNR'
                                      <lfs_valid>-matnr.
      PERFORM f_bdc_field       USING 'RC29N-STLAN'
                                       lc_stlan_5.
      PERFORM f_bdc_field       USING 'RC29N-ZWERK'
                                      <lfs_valid>-werks.

      PERFORM f_bdc_dynpro      USING 'SAPLCSAL' '0120'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'RC29K-STLNR'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                       '=FCBU'.
      PERFORM f_bdc_field       USING 'BDC_SUBSCR'
                                      'SAPLCSAL                                  0803BER_ZUORD'.

      IF i_bdcdata[] IS NOT INITIAL.

        lv_mode = lc_mode.
        lv_update = lc_update.
        CLEAR li_bdcmsg[].

        CALL TRANSACTION lc_cs07 USING i_bdcdata
                       MODE   lv_mode
                       UPDATE lv_update
                       MESSAGES INTO li_bdcmsg.

        IF li_bdcmsg IS NOT INITIAL.

 " Check if error exist
          READ TABLE li_bdcmsg ASSIGNING <lfs_bdcmsg>
                           WITH KEY msgtyp = c_error.
          IF sy-subrc IS INITIAL.
            lwa_report-msgtyp = c_error.
            PERFORM f_error_key_sub USING <lfs_valid>
                                  CHANGING lwa_report.
            CALL FUNCTION 'FORMAT_MESSAGE'
              EXPORTING
                id        = <lfs_bdcmsg>-msgid
                lang      = <lfs_bdcmsg>-msgspra
                no        = <lfs_bdcmsg>-msgnr
                v1        = <lfs_bdcmsg>-msgv1
                v2        = <lfs_bdcmsg>-msgv2
                v3        = <lfs_bdcmsg>-msgv3
                v4        = <lfs_bdcmsg>-msgv4
              IMPORTING
                msg       = lwa_report-msgtxt
              EXCEPTIONS
                not_found = 1
                OTHERS    = 2.
            IF sy-subrc <> 0.
              lwa_report-msgtxt = 'Error in call transaction'(018).
            ENDIF. " IF sy-subrc <> 0

            APPEND lwa_report TO i_report.

            PERFORM f_pop_error_file USING <lfs_valid>
                                CHANGING lwa_error.
            lwa_error-errmsg = lwa_report-msgtxt.
            APPEND lwa_error TO fp_i_error.
            CLEAR lwa_error.
            CLEAR lwa_report.
            gv_ecount = gv_ecount + 1.


          ELSE. " ELSE -> IF sy-subrc IS INITIAL

*         Begin of change for Defect#6766 by NGARG
*          Check for informatiom message with message number 220
*          No Binary search has been used, as reading with diff key
*          and addition of new ort can affect the read statements
*          from previous versions
            READ TABLE li_bdcmsg ASSIGNING <lfs_bdcmsg>
                         WITH KEY msgtyp = lc_info
                                  msgid = lc_29
                                  msgnr = lc_220.
            IF sy-subrc EQ 0.
              lwa_report-msgtyp = c_error.
              PERFORM f_error_key_sub USING <lfs_valid>
                                    CHANGING lwa_report.
              CALL FUNCTION 'FORMAT_MESSAGE'
                EXPORTING
                  id        = <lfs_bdcmsg>-msgid
                  lang      = <lfs_bdcmsg>-msgspra
                  no        = <lfs_bdcmsg>-msgnr
                  v1        = <lfs_bdcmsg>-msgv1
                  v2        = <lfs_bdcmsg>-msgv2
                  v3        = <lfs_bdcmsg>-msgv3
                  v4        = <lfs_bdcmsg>-msgv4
                IMPORTING
                  msg       = lwa_report-msgtxt
                EXCEPTIONS
                  not_found = 1
                  OTHERS    = 2.
              IF sy-subrc <> 0.
                lwa_report-msgtxt = 'Error in call transaction'(018).
              ENDIF. " IF sy-subrc <> 0

              APPEND lwa_report TO i_report.

              PERFORM f_pop_error_file USING <lfs_valid>
                                  CHANGING lwa_error.
              lwa_error-errmsg = lwa_report-msgtxt.
              APPEND lwa_error TO fp_i_error.
              CLEAR lwa_error.
              CLEAR lwa_report.
              gv_ecount = gv_ecount + 1.
            ELSE. " ELSE -> IF sy-subrc EQ 0

*         End  of change for Defect#6766 by NGARG
              gv_scount = gv_scount + 1. "success count

            ENDIF. " IF sy-subrc EQ 0
*         Begin  of change for Defect#6766 by NGARG
          ENDIF. " IF sy-subrc IS INITIAL
*         End  of change for Defect#6766 by NGARG

        ELSE. " ELSE -> IF li_bdcmsg IS NOT INITIAL
          gv_scount = gv_scount + 1. "success count
        ENDIF. " IF li_bdcmsg IS NOT INITIAL

        CLEAR i_bdcdata[].

      ENDIF. " IF i_bdcdata[] IS NOT INITIAL
    ENDLOOP. " LOOP AT fp_i_valid ASSIGNING <lfs_valid>


  ENDIF. " IF fp_i_valid[] IS NOT INITIAL

  FREE: li_valid,
        li_bdcmsg .

ENDFORM. " F_EXECUTE_BDC
*&---------------------------------------------------------------------*
*&      Form  F_MOVE
*&---------------------------------------------------------------------*
FORM f_move CHANGING fp_sourcefile TYPE localfile. " Local file for upload/download

* Local constants
  CONSTANTS: lc_tbp_fld    TYPE char5        VALUE   'TBP',  " constant declaration for TBP folder
             lc_done_fld   TYPE char5        VALUE   'DONE'. " constant declaration for DONE folder.

* Local Data Declaration
  DATA: lv_file TYPE localfile, " Local file for upload/download
                                " local variable declaration of type localfile
        lv_name TYPE localfile. " Local file for upload/download

  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_sourcefile
    IMPORTING
      pathname = lv_file
      filename = lv_name.

* First move the file to the Done folder
  REPLACE lc_tbp_fld  IN lv_file WITH lc_done_fld .
  CONCATENATE   lv_file  lv_name INTO lv_file.
*  Move the file
  PERFORM f_file_move  USING    fp_sourcefile
                                lv_file
                       CHANGING gv_return.
  IF gv_return IS INITIAL.
*   Exporting the archived file name in memory id 'ARCH_1'.
    gv_archive_gl_1 = lv_file.
  ENDIF. " IF gv_return IS INITIAL
ENDFORM. " F_MOVE
*&---------------------------------------------------------------------*
*&      Form  F_WRITE_ERROR_FILE
*&---------------------------------------------------------------------*

FORM f_write_error_file  USING   fp_p_afile TYPE localfile " Local file for upload/download
                                 fp_i_error TYPE ty_t_error.

* Local constants
  CONSTANTS: lc_tbp_fld    TYPE char5        VALUE   'TBP',   " constant declaration for TBP folder
             lc_error_fld  TYPE char5        VALUE   'ERROR'. " constant declaration ERROR folder

* Local data
  DATA: lv_file     TYPE localfile, "File Name
        lv_name     TYPE localfile, "File Name
        lv_data     TYPE string.    "Output data string

*  Local field symbols
  FIELD-SYMBOLS : <lfs_error> TYPE ty_error.

* Spitting Filae Path & File Name
  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_p_afile
    IMPORTING
      pathname = lv_file
      filename = lv_name.

* Changing the file path to ERROR folder
  REPLACE lc_tbp_fld  IN lv_file WITH lc_error_fld .
  CONCATENATE lv_file lv_name INTO lv_file.

* Write the records
  OPEN DATASET lv_file FOR OUTPUT IN TEXT MODE ENCODING UTF-8. " Output type
  IF sy-subrc NE 0.
    MESSAGE i019.
  ELSE. " ELSE -> IF sy-subrc NE 0
*   Forming the header text line
    PERFORM f_header_line_pop CHANGING lv_data.
    TRANSFER lv_data TO lv_file.
    CLEAR lv_data.

*   Passing the Erroneous data
    LOOP AT fp_i_error ASSIGNING <lfs_error>.
      PERFORM f_err_data_pop USING <lfs_error>
                            CHANGING lv_data.
*     Transferring the data into application server.
      TRANSFER lv_data TO lv_file.
      CLEAR lv_data.
    ENDLOOP. " LOOP AT fp_i_error ASSIGNING <lfs_error>
  ENDIF. " IF sy-subrc NE 0
  CLOSE DATASET lv_file.

ENDFORM. " F_WRITE_ERROR_FILE
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION
*&---------------------------------------------------------------------*
*       text

FORM f_validation .

*-- Local Structures
  TYPES:
   BEGIN OF lty_mara,
    matnr TYPE matnr,   " Material Number
   END OF lty_mara,

  BEGIN OF lty_werks,
    werks TYPE werks_d, " BOM Usage
  END OF lty_werks,

  BEGIN OF lty_marc,
    matnr TYPE matnr,   " Material Number
    werks TYPE werks_d, " Plant
  END OF lty_marc,

  BEGIN OF lty_mast,
    matnr TYPE matnr,   " Material Number
    werks TYPE werks_d, " Plant
    stlan	TYPE stlan,   " BOM Usage
    stlnr TYPE  stnum,  " Bill of material
    stlal TYPE  stalt,  " Alternative BOM
  END OF lty_mast.

*-Local constants
  CONSTANTS: lc_emsg       TYPE char1        VALUE   'E', " constant declaration for 'E' error message type
             lc_stlan_5    TYPE stlan        VALUE   '5'. " BOM Usage
*-Local field symbols
  FIELD-SYMBOLS: <lfs_final> TYPE ty_final.

*-- Local internal tables
  DATA: li_mara TYPE STANDARD TABLE OF lty_mara,
        li_werks TYPE STANDARD TABLE OF lty_werks,
        li_final TYPE ty_t_final,
        li_marc TYPE STANDARD TABLE OF lty_marc,
        li_mast TYPE STANDARD TABLE OF lty_mast.

*-- Local work area
  DATA:lwa_error  TYPE ty_error,
       lwa_report TYPE ty_report.
*-- Local variables
  DATA:
  lv_err_flg TYPE char1. " Err_flg of type CHAR1

  CLEAR :li_final[].
  LOOP AT i_final ASSIGNING <lfs_final>.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = <lfs_final>-matnr
      IMPORTING
        output = <lfs_final>-matnr.

  ENDLOOP. " LOOP AT i_final ASSIGNING <lfs_final>
**Get all the materials
  li_final[] = i_final[].
  SORT li_final BY matnr.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING matnr .
  IF li_final[] IS NOT INITIAL.
*-- get the materials from MARA for validation
    SELECT matnr " Material Number
      FROM mara  " General Material Data
      INTO TABLE li_mara
      FOR ALL ENTRIES IN li_final
      WHERE matnr = li_final-matnr.
    IF sy-subrc = 0.
      SORT li_mara BY matnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_final[] IS NOT INITIAL


  CLEAR :li_final[].
**Get all the plants
  li_final[] = i_final[].
  SORT li_final BY werks.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING werks .
  IF li_final[] IS NOT INITIAL.
*-- get the plant from T001W for validation
    SELECT werks " Plant
      FROM t001w " Plant check table
      INTO TABLE li_werks
      FOR ALL ENTRIES IN li_final
      WHERE werks = li_final-werks.
    IF sy-subrc = 0.
      SORT li_werks BY werks.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_final[] IS NOT INITIAL

  CLEAR :li_final[].
**Get all the plants
  li_final[] = i_final[].
  SORT li_final BY matnr werks.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING matnr werks .
  IF li_final[] IS NOT INITIAL.
*-- get the plant from T001W for validation
    SELECT matnr " Material Number
           werks " Plant
      FROM marc  " Plant check table
      INTO TABLE li_marc
      FOR ALL ENTRIES IN li_final
      WHERE matnr = li_final-matnr
        AND werks = li_final-werks.
    IF sy-subrc = 0.
      SORT li_marc BY matnr werks.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_final[] IS NOT INITIAL

  CLEAR :li_final[].
**Get all the plants
  li_final[] = i_final[].
  SORT li_final BY matnr werks.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING matnr werks .
  IF li_final[] IS NOT INITIAL.
*-- get the plant from T001W for validation
    SELECT matnr " Material Number
           werks " Plant
           stlan " BOM Usage
           stlnr " Bill of material
           stlal " Alternative BOM
      FROM mast  " Plant check table
      INTO TABLE li_mast
      FOR ALL ENTRIES IN li_final
      WHERE matnr = li_final-matnr
        AND werks = li_final-werks
        AND stlan = lc_stlan_5.
    IF sy-subrc = 0.
      SORT li_mast BY matnr werks stlan.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_final[] IS NOT INITIAL

  LOOP AT li_final ASSIGNING <lfs_final>.

    CLEAR: lv_err_flg.
**validate Exclusion type
    IF <lfs_final>-matnr IS INITIAL.
*      error flag
      lv_err_flg = abap_true.
      gv_ecount = gv_ecount + 1 .
      PERFORM f_error_key_sub USING <lfs_final>
                           CHANGING lwa_report.
      lwa_report-msgtyp = lc_emsg.
      lwa_report-msgtxt = 'Material Number can not be blank.'(009).
      APPEND lwa_report TO i_report.
      CLEAR lwa_report.

      PERFORM f_pop_error_file USING <lfs_final>
                               CHANGING lwa_error.
      lwa_error-errmsg = 'Material Number can not be blank.'(009).
      APPEND lwa_error TO i_error.
      CLEAR lwa_error.
      CONTINUE.

    ELSE. " ELSE -> IF <lfs_final>-matnr IS INITIAL
      READ TABLE li_mara TRANSPORTING NO FIELDS
                          WITH KEY matnr = <lfs_final>-matnr
                          BINARY SEARCH.
      IF sy-subrc <> 0.
** error
        lv_err_flg = c_true.
        gv_ecount = gv_ecount + 1 .
        PERFORM f_error_key_sub USING <lfs_final>
                                     CHANGING lwa_report.
        lwa_report-msgtyp = lc_emsg.
        lwa_report-msgtxt = 'Invalid Material Number.'(010).
        APPEND lwa_report TO i_report.
        CLEAR lwa_report.

        PERFORM f_pop_error_file USING <lfs_final>
                                 CHANGING lwa_error.
        lwa_error-errmsg = 'Invalid Material Number.'(010).
        APPEND lwa_error TO i_error.
        CLEAR lwa_error.
        CONTINUE.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF <lfs_final>-matnr IS INITIAL


    IF <lfs_final>-werks IS INITIAL.
*      error flag
      lv_err_flg = abap_true.
      gv_ecount = gv_ecount + 1 .
      PERFORM f_error_key_sub USING <lfs_final>
                              CHANGING lwa_report.
      lwa_report-msgtyp = lc_emsg.
      lwa_report-msgtxt = 'Plant can not be blank.'(011).
      APPEND lwa_report TO i_report.
      CLEAR lwa_report.

      PERFORM f_pop_error_file USING <lfs_final>
                               CHANGING lwa_error.
      lwa_error-errmsg = 'Plant can not be blank.'(011).
      APPEND lwa_error TO i_error.
      CLEAR lwa_error.
      CONTINUE.

    ELSE. " ELSE -> IF <lfs_final>-werks IS INITIAL
      READ TABLE li_werks TRANSPORTING NO FIELDS
                          WITH KEY werks = <lfs_final>-werks
                          BINARY SEARCH.
      IF sy-subrc <> 0.
** error
        lv_err_flg = c_true.
        gv_ecount = gv_ecount + 1 .
        PERFORM f_error_key_sub USING <lfs_final>
                              CHANGING lwa_report.
        lwa_report-msgtyp = lc_emsg.
        lwa_report-msgtxt = 'Invalid Plant.'(012).
        APPEND lwa_report TO i_report.
        CLEAR lwa_report.

        PERFORM f_pop_error_file USING <lfs_final>
                                CHANGING lwa_error.
        lwa_error-errmsg = 'Invalid Plant.'(012).
        APPEND lwa_error TO i_error.
        CLEAR lwa_error.
        CONTINUE.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF <lfs_final>-werks IS INITIAL

    READ TABLE li_marc TRANSPORTING NO FIELDS
                        WITH KEY matnr = <lfs_final>-matnr
                                 werks = <lfs_final>-werks
                                 BINARY SEARCH.
    IF sy-subrc <> 0.
** error
      lv_err_flg = c_true.
      gv_ecount = gv_ecount + 1 .
      PERFORM f_error_key_sub USING <lfs_final>
                           CHANGING lwa_report.
      lwa_report-msgtyp = lc_emsg.
      lwa_report-msgtxt = 'Plant does not exist in material master.'(021).
      APPEND lwa_report TO i_report.
      CLEAR lwa_report.

      PERFORM f_pop_error_file USING <lfs_final>
                             CHANGING lwa_error.
      lwa_error-errmsg = 'Plant does not exist in material master.'(021).
      APPEND lwa_error TO i_error.
      CLEAR lwa_error.
      CONTINUE.
    ENDIF. " IF sy-subrc <> 0

    READ TABLE li_mast TRANSPORTING NO FIELDS
                        WITH KEY matnr = <lfs_final>-matnr
                                 werks = <lfs_final>-werks
                                 stlan = lc_stlan_5
                                 BINARY SEARCH.
    IF sy-subrc = 0.
** error
      lv_err_flg = c_true.
      gv_ecount = gv_ecount + 1 .
      PERFORM f_error_key_sub USING <lfs_final>
                           CHANGING lwa_report.
      lwa_report-msgtyp = lc_emsg.
      lwa_report-msgtxt = 'Plant already extended.'(013).
      APPEND lwa_report TO i_report.
      CLEAR lwa_report.

      PERFORM f_pop_error_file USING <lfs_final>
                             CHANGING lwa_error.
      lwa_error-errmsg = 'Plant already extended.'(013).
      APPEND lwa_error TO i_error.
      CLEAR lwa_error.
      CONTINUE.
    ENDIF. " IF sy-subrc = 0
    IF lv_err_flg IS INITIAL.
**populate data for processing
      APPEND <lfs_final> TO i_valid.
    ENDIF. " IF lv_err_flg IS INITIAL

  ENDLOOP. " LOOP AT li_final ASSIGNING <lfs_final>

  IF  rb_post IS  INITIAL.
    gv_scount = lines( i_valid ).
  ENDIF. " IF rb_post IS INITIAL


  FREE: li_mara,
        li_werks ,
        li_final ,
        li_mast ,
        li_marc .




ENDFORM. " F_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_POP_ERROR_FILE
*&---------------------------------------------------------------------*

FORM f_pop_error_file  USING   fp_err_data TYPE ty_final
                       CHANGING fp_lwa_error TYPE ty_error .

  fp_lwa_error-matnr = fp_err_data-matnr.
  fp_lwa_error-werks = fp_err_data-werks.

ENDFORM. " F_POP_ERROR_FILE
*&---------------------------------------------------------------------*
*&      Form  F_ERROR_KEY_SUB
*&---------------------------------------------------------------------*

FORM f_error_key_sub  USING  fp_err_key TYPE ty_final
                      CHANGING fp_lwa_report TYPE ty_report.

  CONSTANTS: lc_fslash     TYPE char1        VALUE   '/'. " Forward slash
* populate error Key
  CONCATENATE
  fp_err_key-matnr
  fp_err_key-werks
 INTO fp_lwa_report-key
 SEPARATED BY lc_fslash.
ENDFORM. " F_ERROR_KEY_SUB
*&---------------------------------------------------------------------*
*&      Form  F_BDC_DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0751   text
*      -->P_0752   text
*----------------------------------------------------------------------*
FORM f_bdc_dynpro  USING    fp_v_program  TYPE bdc_prog  " BDC module pool
                            fp_v_dynpro   TYPE bdc_dynr. " BDC Screen number
* Local data declaration
  DATA: lwa_bdcdata TYPE bdcdata. " Batch input: New table field structure

  CLEAR lwa_bdcdata.
  lwa_bdcdata-program  = fp_v_program.
  lwa_bdcdata-dynpro   = fp_v_dynpro.
  lwa_bdcdata-dynbegin = c_true.
  APPEND lwa_bdcdata TO i_bdcdata.
ENDFORM. " F_BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  F_BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0756   text
*      -->P_0757   text
*----------------------------------------------------------------------*
FORM f_bdc_field  USING    fp_v_fnam    TYPE any
                           fp_v_fval    TYPE any.
  DATA: lwa_bdcdata TYPE bdcdata. " Batch input: New table field structure

  lwa_bdcdata-fnam = fp_v_fnam.
  lwa_bdcdata-fval = fp_v_fval.
  APPEND lwa_bdcdata TO i_bdcdata.
  CLEAR lwa_bdcdata.

ENDFORM. " F_BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  F_ALL_SUCCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_all_success .
* Local constants
  CONSTANTS: lc_smsg TYPE char1        VALUE   'S'. " constant declaration for 'S' success message type
* Local data
  DATA: lwa_report TYPE ty_report.

  CLEAR lwa_report.
  lwa_report-msgtyp = lc_smsg.
  IF rb_post = c_rbselected.
    lwa_report-msgtxt = 'All records are successfully uploaded'(019).
    APPEND lwa_report TO i_report.
    CLEAR lwa_report.
  ELSE. " ELSE -> IF rb_post = c_rbselected
    lwa_report-msgtxt = 'All records are verified and correct'(020).
    APPEND lwa_report TO i_report.
    CLEAR lwa_report.
  ENDIF. " IF rb_post = c_rbselected
ENDFORM. " F_ALL_SUCCESS
*&---------------------------------------------------------------------*
*&      Form  F_INITIALIZATION
*&---------------------------------------------------------------------*
*  Initialize all global variable and internal tables
*----------------------------------------------------------------------*

FORM f_initialization .
*--Global internal tables
  FREE:
  i_final,    " Table contain all data
  i_error ,   " Error details table
  i_report ,  " Table for report display
  i_valid  ,  " Valid entries after validation
  i_bdcdata . " bdc data for posting

*-- Global variables
  CLEAR:
  gv_mode   , " Mode of type CHAR10
  gv_file ,   " File name
  gv_scount , " Succes Count
  gv_ecount . " Error Count

ENDFORM. " F_INITIALIZATION
*&---------------------------------------------------------------------*
*&      Form  F_HEADER_LINE_POP
*&---------------------------------------------------------------------*

FORM f_header_line_pop  CHANGING fp_data TYPE string.
  CONCATENATE
              'Header Material'(015)
              'Plant'(016)
              INTO fp_data
              SEPARATED BY c_tab.
ENDFORM. " F_HEADER_LINE_POP
*&---------------------------------------------------------------------*
*&      Form  F_ERR_DATA_POP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<LFS_ERROR>  text
*      <--P_LV_DATA  text
*----------------------------------------------------------------------*
FORM f_err_data_pop  USING    fp_p_error TYPE ty_error
                     CHANGING fp_data    TYPE string.
* Pass the error data to application server
  CONCATENATE
fp_p_error-matnr
fp_p_error-werks
fp_p_error-errmsg
INTO fp_data
SEPARATED BY c_tab.

ENDFORM. " F_ERR_DATA_POP
*&---------------------------------------------------------------------*
*&      Form  F_GET_CONSTANTS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*       Get Constants From EMI Tool
*----------------------------------------------------------------------*
FORM f_get_constants .

*data declaration
  DATA: li_constants TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0. " Enhancement Status
*field symbol dclaration
  FIELD-SYMBOLS: <lfs_constant> TYPE zdev_enh_status. " Enhancement Status
*constant declaration
  CONSTANTS:
             lc_codepage      TYPE z_criteria    VALUE 'CODEPAGE',        " Enh. Criteria
             lc_enh_name      TYPE z_enhancement VALUE 'D3_OTC_CDD_0091'. "Enhancement No.

*get the constants
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_name
    TABLES
      tt_enh_status     = li_constants.
*If EMI table is not initial
  IF li_constants[] IS NOT INITIAL. "sy-subrc IS INITIAL AND
    SORT li_constants BY  criteria  active .
    READ TABLE li_constants ASSIGNING <lfs_constant> WITH KEY criteria = lc_codepage
                                                              active = abap_true
                                                              BINARY SEARCH.
    IF sy-subrc = 0.
      gv_codepage = <lfs_constant>-sel_low.

      IF gv_codepage IS NOT INITIAL.
        CALL METHOD zdev_cl_abap_file_utilities=>meth_stat_pub_check_codepage
          CHANGING
            ch_codepage = gv_codepage.
      ENDIF. " IF gv_codepage IS NOT INITIAL

    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_constants[] IS NOT INITIAL

  FREE : li_constants .

ENDFORM. " F_GET_CONSTANTS
