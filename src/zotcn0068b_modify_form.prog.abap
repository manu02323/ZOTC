*&---------------------------------------------------------------------*
*&  Include           ZOTCN0068B_MODIFY_FORM
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0068B_MODIFY_FORM                                 *
* TITLE      :  OTC_CDD_0068B SALES ORDER OUTPUT                       *
* DEVELOPER  :  Pallavi Gupta                                          *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  OTC_CDD_0068_SALES ORDER OUTPUT CONVERSION             *
*----------------------------------------------------------------------*
* DESCRIPTION:  Subroutines include for uploading Conditional Records  *
*              into SAP from text file                                 *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 06-JUN-2012 PGUPTA2  E1DK901630 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*
* 06-JUN-2012 ASK        E1DK906733 Defect 380, remove hardcoding for  *
*                                   key combination starting with Z855 *
* 23-JUN-2014 KNAMALA    E2DK901634 D2 Changes, Condition Type Z855    *
*                                   to Accommodate the Keycombination  *
*                                   changes                            *
* 07-MAR-2014 U104864    E2DK922518 D3 Changes in KeyCombination of    *
*                                   903(ZBA0,ZBA1),904(ZBA0,ZBA1)      *
*                                   Add KeyCombination 909(ZBA0,ZBA1)  *
*                                   SCTASK0801091                      *
*&---------------------------------------------------------------------*
*     Modify the selection screen based on radio button selection.
*----------------------------------------------------------------------*
FORM f_modify_screen .
  LOOP AT SCREEN .
*   Presentation Server Option is NOT chosen
    IF rb_pres NE c_true.
*     Hiding Presentation Server file paths with modify id MI3.
      IF screen-group1 = c_groupmi3.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
*   Presentation Server Option IS chosen
    ELSE. " ELSE -> IF screen-group1 = c_groupmi3
*     Disaplying Presentation Server file paths with modify id MI3.
      IF screen-group1 = c_groupmi3.
        screen-active = c_one.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
    ENDIF. " IF rb_pres NE c_true
*   Application Server Option is NOT chosen
    IF rb_app NE c_true.
*     Hiding 1) Application Server file Physical paths with modify id MI2
*     2) Logical Filename Radio Button with with modify id MI5
*     3) Logical Filename input with modify id MI7
      IF screen-group1 = c_groupmi2
         OR screen-group1 = c_groupmi5
         OR screen-group1 = c_groupmi7.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi2
*   Application Server Option IS chosen
    ELSE. " ELSE -> IF screen-group1 = c_groupmi2
*     If Application Server Physical File Radio Button is chosen
      IF rb_aphy EQ c_true.
*       Displaying Application Server Physical paths with modify id MI2
        IF screen-group1 = c_groupmi2.
          screen-active = c_one.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi2
*       Hiding Logical Filaename input with modify id MI7
        IF screen-group1 = c_groupmi7.
          screen-active = c_zero.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi7
*     If Application Server Logical File Radio Button is chosen
      ELSEIF rb_alog EQ c_true.
*       Hiding Application Server - Physical paths with modify id MI2
        IF screen-group1 = c_groupmi2.
          screen-active = c_zero.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi2
*       Displaying Logical File name input with modify id MI7
        IF screen-group1 = c_groupmi7.
          screen-active = c_one.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi7
      ENDIF. " IF rb_aphy EQ c_true
    ENDIF. " IF rb_app NE c_true
  ENDLOOP. " LOOP AT SCREEN
ENDFORM. " F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_EXTENSION
*&---------------------------------------------------------------------*
*       Checking whetehr the file has .TXT extension.
*----------------------------------------------------------------------*
*      -->FP_P_FILE  Input file path
*----------------------------------------------------------------------*
FORM f_check_extension  USING fp_p_file TYPE localfile. " Local file for upload/download
  IF fp_p_file IS NOT INITIAL.
    CLEAR gv_extn.
*   Getting the file extension
    PERFORM f_file_extn_check USING fp_p_file
                              CHANGING gv_extn.
*Checking the extension whether its of CSV
    IF gv_extn <> c_ext .
      MESSAGE e000 WITH 'Please provide CSV file'(065).
    ENDIF. " IF gv_extn <> c_ext
  ENDIF. " IF fp_p_file IS NOT INITIAL
ENDFORM. " F_CHECK_EXTENSION
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_INPUT
*&---------------------------------------------------------------------*
*       Checking whether file names have entered for chosen option at
*       Run time.
*----------------------------------------------------------------------*
FORM f_check_input .

* If No presentation Server file name is entered and Presentation
* Server Option has been chosen, then issueing error message.
  IF rb_pres IS NOT INITIAL AND
     p_pfile IS INITIAL.
    MESSAGE i009.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF rb_pres IS NOT INITIAL AND

* For Application Server
  IF rb_app IS NOT INITIAL.
*   If No Application Server file name is entered and Application
*   Server Option has been chosen, then issueing error message.
    IF rb_aphy IS NOT INITIAL AND
       p_afile IS INITIAL.
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
*&      Form  F_UPLOAD_PRESNT_FILES
*&---------------------------------------------------------------------*
*       Upload input file from Presentation Server
*----------------------------------------------------------------------*
*      -->FP_P_PFILE        Input File location
*      <--FP_I_MODIFY       Input Data
*----------------------------------------------------------------------*

FORM f_upload_presnt_files  USING fp_p_pfile TYPE localfile " Local file for upload/download
                         CHANGING fp_i_modify TYPE ty_t_modify.
* Local Data Declaration
  DATA: lv_filename TYPE string,    "localfile name
        li_str      TYPE STANDARD TABLE OF string
                    INITIAL SIZE 0, "table of type string
*       local work area of type string to split records in csv file.
        lwa_str     TYPE string,      "lwa_str type string
        li_string   TYPE ty_t_modify, "table type ty_t_modify
        lwa_string  TYPE ty_modify.   "type ty_modify.

  lv_filename = fp_p_pfile.

* Uploading the file from Presentation Server
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_filename
      filetype                = c_filetype
    CHANGING
      data_tab                = li_str[]
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
    MESSAGE i017.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS NOT INITIAL

  LOOP AT li_str INTO lwa_str.
    SPLIT lwa_str AT c_comma INTO
        lwa_string-keycombi
        lwa_string-kschl
        lwa_string-vkorg
        lwa_string-vtweg
        lwa_string-auart
        lwa_string-kunnr
        lwa_string-kunwe
        lwa_string-parvw
        lwa_string-nacha
        lwa_string-vsztp
        lwa_string-tcode
        lwa_string-ldest
        lwa_string-tdarmod
        lwa_string-tdschedule
        lwa_string-dimme
        lwa_string-zzbsark
        lwa_string-parnr.

    APPEND lwa_string TO li_string.
    CLEAR  lwa_string.
  ENDLOOP. " LOOP AT li_str INTO lwa_str
  fp_i_modify = li_string[].
*   Deleting the Header Line
  DELETE fp_i_modify INDEX 1.
ENDFORM. " F_UPLOAD_PRESNT_FILES
*&---------------------------------------------------------------------*
*&      Form  F_MOVE
*&---------------------------------------------------------------------*
*       Moving Source File to DONE Folder if Validate & Post option is
*       chosen
*----------------------------------------------------------------------*
*      -->FP_V_SOURCE  Source File Path
*      -->FP_I_REPORT  Error log (report) table
*----------------------------------------------------------------------*
FORM f_move  USING   fp_v_source TYPE localfile " Local file for upload/download
            CHANGING fp_i_report TYPE ty_t_report.
* Local Data
  DATA: lv_file    TYPE localfile,  "File Name
        lv_name    TYPE localfile,  "Path Name
        lv_return  TYPE sysubrc,    "Return Code
        lwa_report TYPE ty_report. "local work area for error log

* Splitting File Path & File Name
  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_v_source
    IMPORTING
      pathname = lv_file
      filename = lv_name.

* First move the file to the Done folder
  REPLACE c_tbp_fld
          IN lv_file
          WITH c_done_fld .
  CONCATENATE lv_file lv_name
                INTO lv_file.

* Move the file
  PERFORM f_file_move  USING    fp_v_source
                                lv_file
                       CHANGING lv_return.

  IF lv_return IS INITIAL.
    gv_archive_gl_1 = lv_file.
  ELSE. " ELSE -> IF lv_return IS INITIAL
* Populating the error message in case Input Header file not moved
    lwa_report-msgtyp = c_error.
* Forming the text.
    MESSAGE i000 WITH 'Input file'(056)
                       lv_file
                      'not moved.'(057)
            INTO lwa_report-msgtxt.
    APPEND lwa_report TO fp_i_report.
    CLEAR lwa_report.
  ENDIF. " IF lv_return IS INITIAL

ENDFORM. " F_MOVE
*&---------------------------------------------------------------------*
*&      Form  F_MOVE_ERROR
*&---------------------------------------------------------------------*
*       Moving Error file to Error folder.
*----------------------------------------------------------------------*
*      -->FP_P_AFILE      Source file path
*      -->FP_I_ERROR[]   Error File with errorneous records
*----------------------------------------------------------------------*
FORM f_move_error USING   fp_p_afile    TYPE localfile " Local file for upload/download
                          fp_i_error    TYPE ty_t_error.
* Local Data
  DATA: lv_file   TYPE localfile,   "File Name
        lv_name   TYPE localfile,   "File Name
        lv_data   TYPE string,      "Output data string
        lwa_error TYPE ty_modify_e. "Error work area

* Spitting Filae Path & File Name
  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_p_afile
    IMPORTING
      pathname = lv_file
      filename = lv_name.

* Changing the file path to ERROR folder
  REPLACE c_tbp_fld
  IN lv_file
  WITH c_error_fld .
  CONCATENATE lv_file c_slash lv_name INTO lv_file.

* Write the records
  OPEN DATASET lv_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " Output type
  IF sy-subrc NE 0.
    MESSAGE i019.
  ELSE. " ELSE -> IF sy-subrc NE 0
*   Forming the header text line
    CONCATENATE  'Key combination'(h01)
                 'Condition type'(h17)
                 'Sales organization'(h02)
                 'Distribution Channel'(h25)
                 'Sales Document Type'(h03)
                 'Sold to party'(h05)
                 'Ship to party'(h24)
                 'Partner function'(h06)
                 'Message transmission medium'(h18)
                 'Dispatch time'(h19)
                 'Communication strategy'(h20)
                 'Spool : output device'(h07)
                 'Print: Archiving mode'(h10)
                 'Send time request'(h08)
                 'Print immediately'(h09)
                 'Purchase Order Type'(h66)
                 'Partner Number'(h67)
                 'Error Message'(h16)
         INTO lv_data
         SEPARATED BY c_tab.
    TRANSFER lv_data TO lv_file.
    CLEAR lv_data.

*   Passing the Error Header data
    LOOP AT fp_i_error INTO lwa_error.
      CONCATENATE
                    lwa_error-keycombi
                    lwa_error-kschl
                    lwa_error-vkorg
                    lwa_error-vtweg
                    lwa_error-auart
                    lwa_error-kunnr
                    lwa_error-kunwe
                    lwa_error-parvw
                    lwa_error-nacha
                    lwa_error-vsztp
                    lwa_error-tcode
                    lwa_error-ldest
                    lwa_error-tdarmod
                    lwa_error-tdschedule
                    lwa_error-dimme
                    lwa_error-zzbsark
                    lwa_error-parnr
                    lwa_error-errormsg
           INTO lv_data
           SEPARATED BY c_tab.
*     Transferring the data into application server.
      TRANSFER lv_data TO lv_file.
      CLEAR lv_data.
    ENDLOOP. " LOOP AT fp_i_error INTO lwa_error
  ENDIF. " IF sy-subrc NE 0
  CLOSE DATASET lv_file.


ENDFORM. " F_MOVE_ERROR
*&---------------------------------------------------------------------*
*&      Form  F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*       Retriving physical file paths from logical file name
*----------------------------------------------------------------------*
*      -->FP_P_ALOG      Logical File Name
*      <--FP_GV_MODIFY   Physical File Path
*----------------------------------------------------------------------*
FORM f_logical_to_physical  USING fp_p_alog  TYPE pathintern      " Logical path name
                            CHANGING fp_gv_modify TYPE localfile. " Local file for upload/download
* Local Data Declaration
  DATA: li_input   TYPE zdev_t_file_list_in,
        lwa_input  TYPE zdev_file_list_in,  " Input for FM ZDEV_DIRECTORY_FILE_LIST
        li_output  TYPE zdev_t_file_list_out,
        lwa_output TYPE zdev_file_list_out, " Output for FM ZDEV_DIRECTORY_FILE_LIST
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
  ENDIF. " IF sy-subrc <> 0

  IF sy-subrc IS INITIAL AND
     li_error IS INITIAL.

*   Getting the file path
    READ TABLE li_output INTO lwa_output INDEX 1.
    IF sy-subrc IS INITIAL.
      CONCATENATE lwa_output-physical_path
      lwa_output-filename
      INTO fp_gv_modify.
    ENDIF. " IF sy-subrc IS INITIAL
  ELSE. " ELSE -> IF sy-subrc IS INITIAL
*   Logical file path & could not be read for input files.
    MESSAGE i037 WITH fp_p_alog.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS INITIAL AND

* If Header file could not be retrieved, then issuing an error message
  IF fp_gv_modify IS INITIAL.
    MESSAGE i103 WITH fp_p_alog.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF fp_gv_modify IS INITIAL


ENDFORM. " F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_APPLCN_FILES
*&---------------------------------------------------------------------*
*       Uploading Header File from Applicatoin Server.
*----------------------------------------------------------------------*
*      -->FP_P_FILE        Input file path @ Application Server
*      <--FP_I_MODIFY       Input Data
*----------------------------------------------------------------------*

FORM f_upload_applcn_files  USING    fp_p_afile  TYPE localfile " Local file for upload/download
                            CHANGING fp_i_modify TYPE ty_t_modify.


* Local Variables
  DATA: lv_input_line TYPE string,    "Input Raw lines
        lwa_modify    TYPE ty_modify, "Input work area
        lv_subrc      TYPE sysubrc.   "SY-SUBRC value

* Opening the Dataset for File Read

  OPEN DATASET fp_p_afile FOR INPUT IN TEXT MODE ENCODING DEFAULT. " Set as Ready for Input
  IF sy-subrc IS INITIAL.
*   Reading the Input File
    WHILE ( lv_subrc EQ 0 ).
*      sy-subrc is checked in while codition
      READ DATASET fp_p_afile INTO lv_input_line.
*     Sotring the SY-SUBRC value. To be used as loop-breaking condition.
      lv_subrc = sy-subrc.
      IF lv_subrc IS INITIAL.
*       Aligning the values as per the structure
        SPLIT lv_input_line AT c_comma
        INTO        lwa_modify-keycombi
                    lwa_modify-kschl
                    lwa_modify-vkorg
                    lwa_modify-vtweg
                    lwa_modify-auart
                    lwa_modify-kunnr
                    lwa_modify-kunwe
                    lwa_modify-parvw
                    lwa_modify-nacha
                    lwa_modify-vsztp
                    lwa_modify-tcode
                    lwa_modify-ldest
                    lwa_modify-tdarmod
                    lwa_modify-tdschedule
                    lwa_modify-dimme
                    lwa_modify-zzbsark
                    lwa_modify-parnr.

*       If the last entry is a Line Feed (i.e. CR_LF), then ignore.
        IF lwa_modify-parnr = c_crlf.
          CLEAR lwa_modify-parnr.
        ELSEIF lwa_modify-parnr CA c_crlf.
*       If the last field does not fills up the full length of
*       field, then the last character will be CR-LF. Replacing the
*       CR-LF from the last field if it contains CR-LF.
          REPLACE ALL OCCURRENCES OF c_crlf IN lwa_modify-parnr
          WITH space.
*         Removing the space.
          CONDENSE lwa_modify-parnr.
        ENDIF. " IF lwa_modify-parnr = c_crlf

        IF NOT lwa_modify IS INITIAL.
          APPEND lwa_modify TO fp_i_modify.
          CLEAR lwa_modify.
        ENDIF. " IF NOT lwa_modify IS INITIAL
      ENDIF. " IF lv_subrc IS INITIAL
      CLEAR lv_input_line.
    ENDWHILE.
* If File Open fails, then populating the Error Log
  ELSE. " ELSE -> IF NOT lwa_modify IS INITIAL
*   Forming the Message
    MESSAGE i016.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS INITIAL
* Closing the Dataset.
  CLOSE DATASET fp_p_afile.

* Deleting the First Index Line from the table
  DELETE fp_i_modify INDEX 1.

ENDFORM. " F_UPLOAD_APPLCN_FILES
*&---------------------------------------------------------------------*
*&      Form  F_DATA
*&---------------------------------------------------------------------*
*       Retrieving existing data for validation purpose
*----------------------------------------------------------------------*
*      -->FP_I_MODIFY[]     Input Records
*----------------------------------------------------------------------*

FORM f_data USING fp_i_modify  TYPE  ty_t_modify.
*Local Data
* Work Area Declaration
  DATA: lwa_vkorg TYPE ty_vkorg, " work area decalration for sales organization
        lwa_vtweg TYPE ty_tvtw,  " work area decalration for Distribution Channel
        lwa_kunnr TYPE ty_kunnr, " work area declaration for customer number : Sold to Party
        lwa_parvw TYPE ty_parvw, " work area declaration for partner function
        lwa_auart TYPE ty_auart, " work area declaration for Sales Document Type
        lwa_kschl TYPE ty_kschl, " work area declaration for condition type
        lwa_dup   TYPE ty_dup.   "work area for dup

* Internal Table Declaration
  DATA: li_vkorg_val TYPE ty_t_vkorg, "Sales Organization
        li_vtweg_val TYPE ty_t_vtweg, "Distribution Channel
        li_kunnr_val TYPE ty_t_kunnr, "Sold to Party
        li_parvw_val TYPE ty_t_parvw, "Partner Function
        li_auart_val TYPE ty_t_auart, "Sales Document Type
        li_kschl_val TYPE ty_t_kschl, "Conditioning type
        li_dup       TYPE ty_t_dup,   "duplicate recrds
        li_dup_902   TYPE ty_t_dup.   "duplicate recrds

* Field Symbols Declaration
  FIELD-SYMBOLS: <lfs_modify> TYPE ty_modify.

*  Validating sales organization from tvko table
  LOOP AT fp_i_modify ASSIGNING <lfs_modify>.
*  Appending vkorg to li_vkorg_val table
    IF <lfs_modify>-vkorg IS NOT INITIAL.
      CLEAR lwa_vkorg.
      lwa_vkorg-vkorg = <lfs_modify>-vkorg.
      APPEND lwa_vkorg TO li_vkorg_val.
    ENDIF. " IF <lfs_modify>-vkorg IS NOT INITIAL
*  Appending vtweg to li_vtweg_val table
    IF <lfs_modify>-vtweg IS NOT INITIAL.
      CLEAR lwa_vtweg.
      lwa_vtweg-vtweg = <lfs_modify>-vtweg.
      APPEND lwa_vtweg TO li_vtweg_val.
    ENDIF. " IF <lfs_modify>-vtweg IS NOT INITIAL
*  Appending kunnr to li_kunnr_val table
*     customer : Sold to party
    IF <lfs_modify>-kunnr IS NOT INITIAL.
      CLEAR lwa_kunnr.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <lfs_modify>-kunnr
        IMPORTING
          output = <lfs_modify>-kunnr.

      lwa_kunnr-kunnr = <lfs_modify>-kunnr.
      APPEND lwa_kunnr TO li_kunnr_val.
    ENDIF. " IF <lfs_modify>-kunnr IS NOT INITIAL
    IF <lfs_modify>-kunwe IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <lfs_modify>-kunwe
        IMPORTING
          output = <lfs_modify>-kunwe.

      lwa_kunnr-kunnr = <lfs_modify>-kunwe.
      APPEND lwa_kunnr TO li_kunnr_val.
    ENDIF. " IF <lfs_modify>-kunwe IS NOT INITIAL

*  Appending parvw to li_parvw_val table
    IF <lfs_modify>-parvw IS NOT INITIAL.
      CLEAR lwa_parvw.
      CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
        EXPORTING
          input  = <lfs_modify>-parvw
        IMPORTING
          output = <lfs_modify>-parvw.

      lwa_parvw-parvw = <lfs_modify>-parvw.
      APPEND lwa_parvw TO li_parvw_val.
    ENDIF. " IF <lfs_modify>-parvw IS NOT INITIAL

*  Appending auart to li_auart_val table
    IF <lfs_modify>-auart IS NOT INITIAL.
      CLEAR lwa_auart.
      lwa_auart-auart = <lfs_modify>-auart.
      APPEND lwa_auart TO li_auart_val.
    ENDIF. " IF <lfs_modify>-auart IS NOT INITIAL
*Appending kschl to li_kschl_val table
    IF <lfs_modify>-kschl IS NOT INITIAL.
      CLEAR lwa_kschl.
      lwa_kschl-kschl = <lfs_modify>-kschl.
      APPEND lwa_kschl TO li_kschl_val.
    ENDIF. " IF <lfs_modify>-kschl IS NOT INITIAL

*Appending values for checking duplicate records
    CLEAR lwa_dup.
    lwa_dup-kschl = <lfs_modify>-kschl.
    lwa_dup-vkorg = <lfs_modify>-vkorg.
    lwa_dup-auart = <lfs_modify>-auart.
    lwa_dup-kunnr = <lfs_modify>-kunnr.
    lwa_dup-vtweg = <lfs_modify>-vtweg.
    lwa_dup-zzbsark = <lfs_modify>-zzbsark.
    APPEND lwa_dup TO li_dup.

    CLEAR lwa_dup.
    lwa_dup-kschl = <lfs_modify>-kschl.
    lwa_dup-vkorg = <lfs_modify>-vkorg.
    lwa_dup-auart = <lfs_modify>-auart.
    lwa_dup-kunnr = <lfs_modify>-kunwe.
    APPEND lwa_dup TO li_dup_902.
  ENDLOOP. " LOOP AT fp_i_modify ASSIGNING <lfs_modify>

*  Validating vkorg from tvko table
  SORT li_vkorg_val BY vkorg.
  DELETE ADJACENT DUPLICATES FROM li_vkorg_val
                             COMPARING vkorg.

  IF li_vkorg_val IS NOT INITIAL.
    SELECT vkorg     " Sales Organization
           FROM tvko " Organizational Unit: Sales Organizations
           INTO TABLE i_vkorg
           FOR ALL ENTRIES IN li_vkorg_val
           WHERE vkorg EQ li_vkorg_val-vkorg.
    IF sy-subrc EQ 0.
      SORT i_vkorg BY vkorg.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_vkorg_val IS NOT INITIAL

*  Validating vtweg from tvtw table
  SORT li_vtweg_val BY vtweg.
  DELETE ADJACENT DUPLICATES FROM li_vtweg_val
                             COMPARING vtweg.
  IF li_vtweg_val IS NOT INITIAL.
    SELECT vtweg     " Distribution Channel
           FROM tvtw " Organizational Unit: Distribution Channels
           INTO TABLE i_vtweg
           FOR ALL ENTRIES IN li_vtweg_val
           WHERE vtweg EQ li_vtweg_val-vtweg.
    IF sy-subrc EQ 0.
      SORT i_vtweg BY vtweg.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_vtweg_val IS NOT INITIAL

*  Validating kunnr a kunwe from kna1 table
  SORT li_kunnr_val BY kunnr.

  DELETE ADJACENT DUPLICATES FROM li_kunnr_val
                             COMPARING kunnr.
  IF li_kunnr_val IS NOT INITIAL.
    SELECT kunnr " Customer Number
    FROM kna1    " General Data in Customer Master
    INTO TABLE i_kunnr
    FOR ALL ENTRIES IN li_kunnr_val
    WHERE kunnr EQ li_kunnr_val-kunnr.

    IF  sy-subrc EQ 0.
      SORT i_kunnr BY kunnr.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_kunnr_val IS NOT INITIAL

*  Validating parvw from tpar table.
  SORT li_parvw_val BY parvw.
  DELETE ADJACENT DUPLICATES FROM li_parvw_val
                             COMPARING parvw.
  IF  li_parvw_val IS NOT INITIAL.
    SELECT parvw     " Partner Function
           FROM tpar " Business Partner: Functions
           INTO TABLE i_parvw
           FOR ALL ENTRIES IN li_parvw_val
           WHERE parvw EQ li_parvw_val-parvw.
    IF sy-subrc EQ 0.
      SORT i_parvw BY parvw.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_parvw_val IS NOT INITIAL

*  Validating auart from tvak table
  SORT li_auart_val BY auart.
  DELETE ADJACENT DUPLICATES FROM li_auart_val
                             COMPARING auart.
  IF li_auart_val IS NOT INITIAL.
    SELECT auart     " Sales Document Type
           FROM tvak " Sales Document Types
           INTO TABLE i_auart
           FOR ALL ENTRIES IN li_auart_val
           WHERE auart EQ li_auart_val-auart.
    IF  sy-subrc EQ 0.
      SORT i_auart BY auart.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_auart_val IS NOT INITIAL

*  Validating kschl from t685 table
  SORT li_kschl_val BY kschl.
  DELETE ADJACENT DUPLICATES FROM li_kschl_val
                             COMPARING kschl.
  IF li_kschl_val IS NOT INITIAL.
    SELECT kschl     " Condition Type
           FROM t685 " Conditions: Types
           INTO TABLE i_kschl
           FOR ALL ENTRIES IN li_kschl_val
           WHERE kschl EQ li_kschl_val-kschl.
    IF sy-subrc EQ 0.
      SORT i_kschl BY kschl.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_kschl_val IS NOT INITIAL

  SORT li_dup BY kschl
                 vkorg
                 auart
                 kunnr
                 vtweg
                 zzbsark.
  DELETE ADJACENT DUPLICATES FROM li_dup COMPARING ALL FIELDS.

  SORT li_dup_902 BY kschl
                     vkorg
                     auart
                     kunnr
                     vtweg
                     zzbsark.
  DELETE ADJACENT DUPLICATES FROM li_dup_902 COMPARING ALL FIELDS.


  IF li_dup IS NOT INITIAL .
*  Validating duplicate record from b901 table
    SELECT kappl     " Application
           kschl     " Output Type
           vkorg     " Sales Organization
           auart     " Sales Document Type
           kunnr     " Sold-to party
           knumh     " Number of output condition record
           FROM b901 " Sales org./SalesDocTy/Sold-to pt
           INTO TABLE i_b901
           FOR ALL ENTRIES IN li_dup
           WHERE kschl = li_dup-kschl AND
                 vkorg = li_dup-vkorg AND
                 auart = li_dup-auart AND
                 kunnr = li_dup-kunnr.

    IF sy-subrc = 0.
      SORT i_b901 BY kappl
                     kschl
                     vkorg
                     auart
                     kunnr.
    ENDIF. " IF sy-subrc = 0

*  Validating duplicate record from b903 table
    SELECT kappl     " Application
           kschl     " Output Type
           vkorg     " Sales Organization
           kunnr     " Sold-to party
           knumh     " Number of output condition record
           FROM b903 " Sales org./Sold-to pt
           INTO TABLE i_b903
           FOR ALL ENTRIES IN li_dup
           WHERE kschl = li_dup-kschl AND
                 vkorg = li_dup-vkorg AND
                 kunnr = li_dup-kunnr.

    IF sy-subrc = 0.
      SORT i_b903 BY kappl
                     kschl
                     vkorg
                     kunnr.
    ENDIF. " IF sy-subrc = 0
*  Validating duplicate record from b907 table
    SELECT kappl         " Application
               kschl     " Output Type
               vkorg     " Sales Organization
               vtweg     " Distribution Channel
               auart     " Sales Document Type
               knumh     " Number of output condition record
               FROM b907 " Sales org./Distr. Chl/SalesDocTy
               INTO TABLE i_b907
               FOR ALL ENTRIES IN li_dup
               WHERE kschl = li_dup-kschl AND
                     vkorg = li_dup-vkorg AND
                     vtweg = li_dup-vtweg AND
                     auart = li_dup-auart.

    IF sy-subrc = 0.
      SORT i_b907 BY kappl
                     kschl
                     vkorg
                     auart.
    ENDIF. " IF sy-subrc = 0

*  Validating duplicate record from b908 table
    SELECT kappl        " Application
              kschl     " Output Type
              vkorg     " Sales Organization
              auart     " Sales Document Type
              zzbsark   " Customer purchase order type
              kunnr     " Sold-to party
              knumh     " Number of output condition record
              FROM b908 " Sales org./SalesDocTy/PO type/Sold-to pt
              INTO TABLE i_b908
              FOR ALL ENTRIES IN li_dup
              WHERE kschl = li_dup-kschl AND
                    vkorg = li_dup-vkorg AND
                    auart = li_dup-auart AND
                    zzbsark = li_dup-zzbsark AND
                    kunnr = li_dup-kunnr.


    IF sy-subrc = 0.
      SORT i_b908 BY kappl
                     kschl
                     vkorg
                     auart
                     zzbsark.

    ENDIF. " IF sy-subrc = 0

*  Validating duplicate record from b909 table
    SELECT kappl     " Application
           kschl     " Output Type
           vkorg     " Sales Organization
           zzbsark   " Customer purchase order type
           kunnr     " Sold-to party
           knumh     " Number of output condition record
           FROM b909 " Sales org./PO type/Sold-to pt
           INTO TABLE i_b909
           FOR ALL ENTRIES IN li_dup
           WHERE kschl = li_dup-kschl AND
                 vkorg = li_dup-vkorg AND
                 zzbsark = li_dup-zzbsark AND
                 kunnr = li_dup-kunnr.

    IF sy-subrc = 0.
      SORT i_b909 BY kappl
                     kschl
                     vkorg
                     zzbsark.
    ENDIF. " IF sy-subrc = 0

  ENDIF. " IF li_dup IS NOT INITIAL

*  Validating duplicate record from b902 table
  IF li_dup_902 IS NOT INITIAL .

    SELECT kappl     " Application
           kschl     " Output Type
           vkorg     " Sales Organization
           auart     " Sales Document Type
           kunwe     " Ship-to party
           knumh     " Number of output condition record
           FROM b902 " Sales org./SalesDocTy/Ship-to
           INTO TABLE i_b902
           FOR ALL ENTRIES IN li_dup_902
           WHERE kschl = li_dup_902-kschl AND
                 vkorg = li_dup_902-vkorg AND
                 auart = li_dup_902-auart AND
                 kunwe = li_dup_902-kunnr.

    IF sy-subrc = 0.
      SORT i_b902 BY kappl
                     kschl
                     vkorg
                     auart
                     kunwe.
    ENDIF. " IF sy-subrc = 0

*  Validating duplicate record from b904 table
    SELECT kappl     " Application
           kschl     " Output Type
           vkorg     " Sales Organization
           kunwe     " Ship-to party
           knumh     " Number of output condition record
           FROM b904 " Sales org./Ship-to
           INTO TABLE i_b904
           FOR ALL ENTRIES IN li_dup_902
           WHERE kschl = li_dup_902-kschl AND
                 vkorg = li_dup_902-vkorg AND
                 kunwe = li_dup_902-kunnr.
    IF sy-subrc = 0.
      SORT i_b904 BY kappl
                     kschl
                     vkorg
                     kunwe.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_dup_902 IS NOT INITIAL

ENDFORM. " F_DATA

*&---------------------------------------------------------------------*
*&      Form  f_bdc_dynpro
*&---------------------------------------------------------------------*
*       This is used for populating program name and screen number
*----------------------------------------------------------------------*
*      -->FP_V_PROGRAM        BDC Program Name
*      -->FP_V_DYNPRO         BDC Screen Dynpro No.
*      <--FP_I_BDCDATA        Filled up BDC Data
*----------------------------------------------------------------------*
FORM f_bdc_dynpro  USING fp_v_program  TYPE bdc_prog  " BDC module pool
                         fp_v_dynpro   TYPE bdc_dynr. " BDC Screen number
* Local data declaration
  DATA: lwa_bdcdata TYPE bdcdata. " Batch input: New table field structure
  CLEAR lwa_bdcdata.
  lwa_bdcdata-program  = fp_v_program.
  lwa_bdcdata-dynpro   = fp_v_dynpro.
  lwa_bdcdata-dynbegin = c_true.
  APPEND lwa_bdcdata TO i_bdcdata.
ENDFORM. " F_f_bdc_dynpro
*&---------------------------------------------------------------------*
*&      Form  F_bdc_field
*&---------------------------------------------------------------------*
*       This subroutine is used to populate field name and values
*----------------------------------------------------------------------*
*      -->FP_V_FNAM      Field Name
*      -->FP_V_FVAL      Field Value
*      <--FP_I_BDCDATA   Populated BDC Data
*----------------------------------------------------------------------*
FORM f_bdc_field  USING fp_v_fnam    TYPE any
                        fp_v_fval    TYPE any.
* Local data declaration
  DATA: lwa_bdcdata TYPE bdcdata. " Batch input: New table field structure
  IF NOT fp_v_fval IS INITIAL.
    CLEAR lwa_bdcdata.
    lwa_bdcdata-fnam = fp_v_fnam.
    lwa_bdcdata-fval = fp_v_fval.
    APPEND lwa_bdcdata TO i_bdcdata.
  ENDIF. " IF NOT fp_v_fval IS INITIAL
ENDFORM. " F_f_bdc_field
*&---------------------------------------------------------------------*
*&      Form  F_BDCRECORD_VV11
*&---------------------------------------------------------------------*
*       This subroutine is used to populate field name and values
*----------------------------------------------------------------------*
*      -->FP_I_FINAL     Input Final Table
*      -->FP_I_error     Error Table
*      <--fp_gv_ecount   error count
*----------------------------------------------------------------------*
FORM f_bdcrecord_vv11  USING    fp_i_final   TYPE ty_t_modify
                       CHANGING fp_i_error   TYPE ty_t_error
                                fp_gv_ecount TYPE int2 " 2 byte integer (signed)
                                fp_i_report  TYPE ty_t_report.


  DATA:  lwa_error TYPE ty_modify_e. " Local work area for input file with error message
  FIELD-SYMBOLS:  <lfs_final>  TYPE ty_modify. " Field symbol declaration

  LOOP AT fp_i_final ASSIGNING <lfs_final>.
    REFRESH i_bdcdata.


* If the keycombination field is ZBA0901
* use ZBA0901 recording
    IF   ( <lfs_final>-keycombi =  c_ba901                  "'ZBA0901'
       OR  <lfs_final>-keycombi =  c_zrga    "'ZRGA901'
       OR  <lfs_final>-keycombi =  c_zko0 ).                "'ZKO0901'

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV13B-KSCHL'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                    <lfs_final>-kschl. "'ZBA0'.
      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV130-SELKZ(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=WEIT'.

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1901'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'NACH-VSZTP(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                      <lfs_final>-vkorg. "'1000'.
      PERFORM f_bdc_field       USING 'KOMB-AUART'
                                      <lfs_final>-auart. " 'zor
      PERFORM f_bdc_field       USING 'KOMB-KUNNR(01)'
                                      <lfs_final>-kunnr.    "'1000022'.
      PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                      <lfs_final>-parvw.
      PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                      <lfs_final>-nacha.
      PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                      <lfs_final>-vsztp.

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1901'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'KOMB-KUNNR(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=KOMM'.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0211'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                             'NACH-TDARMOD'.

      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                 '=SICH'.
      PERFORM f_bdc_field       USING 'NACH-LDEST'
                                   <lfs_final>-ldest. "'LP01'.
      PERFORM f_bdc_field       USING 'NACH-TDSCHEDULE'
                                   <lfs_final>-tdschedule. "'IMM
      PERFORM f_bdc_field       USING 'NACH-DIMME'
                              <lfs_final>-dimme. "'X'.

      PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                             <lfs_final>-tdarmod. " '3'.


* If the keycombination field is ZRD0902
* use ZBA0901 recording
    ELSEIF      ( <lfs_final>-keycombi = c_zba02
              OR  <lfs_final>-keycombi = c_zrga2
              OR  <lfs_final>-keycombi = c_zko02 ).

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV13B-KSCHL'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                    <lfs_final>-kschl. "'ZBA0'.
      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV130-SELKZ(02)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=WEIT'.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                    ''.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(02)'
                                    'X'.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1902'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-VSZTP(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                     <lfs_final>-vkorg. "'1000'.
      PERFORM f_bdc_field       USING 'KOMB-AUART'
                                     <lfs_final>-auart. " 'ZOR'.
      PERFORM f_bdc_field       USING 'KOMB-KUNWE(01)'
                                      <lfs_final>-kunwe.    "'1000030'.
      PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                      <lfs_final>-parvw. "'SH'.
      PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                      <lfs_final>-nacha.
      PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                      <lfs_final>-vsztp.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1902'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'KOMB-KUNWE(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                   '=KOMM'.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0211'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                             'NACH-TDARMOD'.

      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                 '=SICH'.
      PERFORM f_bdc_field       USING 'NACH-LDEST'
                                   <lfs_final>-ldest. "'LP01'.
      PERFORM f_bdc_field       USING 'NACH-TDSCHEDULE'
                                   <lfs_final>-tdschedule. "'IMM
      PERFORM f_bdc_field       USING 'NACH-DIMME'
                              <lfs_final>-dimme. "'X'.

      PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                             <lfs_final>-tdarmod. " '3'.

* If the keycombination field is ZBA0903
* use ZBA0903 recording
    ELSEIF    ( <lfs_final>-keycombi = c_zbao3              "'ZBA0903'
           OR <lfs_final>-keycombi   = c_zrga3    "'ZRGA903'
           OR <lfs_final>-keycombi   = c_zko03 ).           "'ZKO0903'


      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV13B-KSCHL'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                    <lfs_final>-kschl.
      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV130-SELKZ(03)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=WEIT'.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                    ' '.
*---Begin of Insert SCTASK0801091 by U104864 on 07-March-2019.
*Field Change based on the keyCombination
      IF    <lfs_final>-keycombi = c_zbao3 . "'ZBA0903' If KeyCombi eq  ZBA0903
        PERFORM f_bdc_field       USING 'RV130-SELKZ(05)' "Use KeyField = 05
                                        'X'.
      ELSE. "If KeyCombi eq  'ZRGA903' or 'ZKO0903'
*---End of Insert SCTASK0801091 by U104864 on 07-March-2019.
        PERFORM f_bdc_field       USING 'RV130-SELKZ(03)' "Use KeyField = 03
                                        'X'.
*---Begin of Insert SCTASK0801091 by U104864 on 07-March-2019.
      ENDIF. "End of KeyCombi eq  ZBA0903
*---End of Insert SCTASK0801091 by U104864 on 07-March-2019.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1903'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-VSZTP(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                       <lfs_final>-vkorg.
      PERFORM f_bdc_field       USING 'KOMB-KUNNR(01)'
                                       <lfs_final>-kunnr.
      PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                        <lfs_final>-parvw.
      PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                        <lfs_final>-nacha.
      PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                       <lfs_final>-vsztp.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1903'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                 'KOMB-KUNNR(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=KOMM'.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0211'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                             'NACH-TDARMOD'.

      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                 '=SICH'.
      PERFORM f_bdc_field       USING 'NACH-LDEST'
                                   <lfs_final>-ldest. "'LP01'.
      PERFORM f_bdc_field       USING 'NACH-TDSCHEDULE'
                                   <lfs_final>-tdschedule. "'IMM
      PERFORM f_bdc_field       USING 'NACH-DIMME'
                              <lfs_final>-dimme. "'X'.

      PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                             <lfs_final>-tdarmod. " '3'.

* If the keycombination field is ZBA0904
* use ZBA0904 recording
    ELSEIF     ( <lfs_final>-keycombi = c_zba04             "'ZBA0904'
              OR <lfs_final>-keycombi = c_zrga4 "'ZRGA904'
              OR <lfs_final>-keycombi = c_zko04 ).


      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV13B-KSCHL'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                     <lfs_final>-kschl.
      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV130-SELKZ(02)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=WEIT'.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                    ''.
*---Begin of Insert SCTASK0801091 by U104864 on 07-March-2019.
*Field Change based on the keyCombination
      IF    <lfs_final>-keycombi = c_zba04 . "'ZBA0904' If KeyCombi eq  ZBA0904
        PERFORM f_bdc_field       USING 'RV130-SELKZ(06)' "Use KeyField = 06
                                      'X'.
      ELSE. "If KeyCombi eq 'ZRGA904' or 'ZKO0904'.
*---End of Insert SCTASK0801091 by U104864 on 07-March-2019.
        PERFORM f_bdc_field       USING 'RV130-SELKZ(04)' "Use KeyField = 04
                                      'X'.
*---Begin of Insert SCTASK0801091 by U104864 on 07-March-2019.
      ENDIF."End of KeyCombi eq  ZBA0904
*---End of Insert SCTASK0801091 by U104864 on 07-March-2019.

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1904'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-VSZTP(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                     <lfs_final>-vkorg.
      PERFORM f_bdc_field       USING 'KOMB-AUART'
                                     <lfs_final>-auart.
      PERFORM f_bdc_field       USING 'KOMB-KUNWE(01)'
                                      <lfs_final>-kunwe.
      PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                       <lfs_final>-parvw.
      PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                       <lfs_final>-nacha.
      PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                       <lfs_final>-vsztp.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1904'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'KOMB-KUNWE(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=KOMM'.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0211'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                             'NACH-TDARMOD'.

      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                 '=SICH'.
      PERFORM f_bdc_field       USING 'NACH-LDEST'
                                   <lfs_final>-ldest. "'LP01'.
      PERFORM f_bdc_field       USING 'NACH-TDSCHEDULE'
                                   <lfs_final>-tdschedule. "'IMM
      PERFORM f_bdc_field       USING 'NACH-DIMME'
                              <lfs_final>-dimme. "'X'.

      PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                             <lfs_final>-tdarmod. " '3'.



    ELSEIF ( <lfs_final>-keycombi = c_zba0f2
       OR  <lfs_final>-keycombi = c_zrgaf2
       OR  <lfs_final>-keycombi = c_zko0f2 ).

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV13B-KSCHL'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                    <lfs_final>-kschl. "'ZBA0'.
      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV130-SELKZ(02)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=WEIT'.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                    ''.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(02)'
                                    'X'.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1902'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-VSZTP(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                     <lfs_final>-vkorg. "'1000'.
      PERFORM f_bdc_field       USING 'KOMB-AUART'
                                     <lfs_final>-auart. " 'ZOR'.
      PERFORM f_bdc_field       USING 'KOMB-KUNWE(01)'
                                      <lfs_final>-kunwe.    "'1000030'.
      PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                      <lfs_final>-parvw. "'SH'.
      PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                      <lfs_final>-nacha.
      PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                      <lfs_final>-vsztp.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1902'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'KOMB-KUNWE(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=KOMM'.

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0233'.

      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                  'NACH-TDARMOD'.

      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'.
      PERFORM f_bdc_field       USING 'NACH-TDSCHEDULE'
                                  <lfs_final>-tdschedule. "IMM
      PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                <lfs_final>-tdarmod  . " '3'.

    ELSEIF ( <lfs_final>-keycombi = c_zba0f4 "'ZBA0F904'
         OR <lfs_final>-keycombi = c_zrgaf4  "'ZRGAF904'
         OR <lfs_final>-keycombi = c_zko0f4 ).


      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV13B-KSCHL'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                     <lfs_final>-kschl.
      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV130-SELKZ(02)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=WEIT'.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                    ''.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(04)'
                                    'X'.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1904'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-VSZTP(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                     <lfs_final>-vkorg.
      PERFORM f_bdc_field       USING 'KOMB-AUART'
                                     <lfs_final>-auart.
      PERFORM f_bdc_field       USING 'KOMB-KUNWE(01)'
                                      <lfs_final>-kunwe.
      PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                       <lfs_final>-parvw.
      PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                       <lfs_final>-nacha.
      PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                       <lfs_final>-vsztp.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1904'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'KOMB-KUNWE(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=KOMM'.

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0233'.

      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                  'NACH-TDARMOD'.

      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'.
      PERFORM f_bdc_field       USING 'NACH-TDSCHEDULE'
                                  <lfs_final>-tdschedule. "IMM
      PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                <lfs_final>-tdarmod  . " '3'.

    ELSEIF ( <lfs_final>-keycombi =  c_zba0f "'ZBA0F901'
         OR  <lfs_final>-keycombi =  c_zrgaf "'ZRGAF901'
         OR  <lfs_final>-keycombi =  c_zko0f ).




      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV13B-KSCHL'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                    <lfs_final>-kschl. "'ZBA0'.
      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV130-SELKZ(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=WEIT'.

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1901'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'NACH-VSZTP(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                      <lfs_final>-vkorg. "'1000'.
      PERFORM f_bdc_field       USING 'KOMB-AUART'
                                      <lfs_final>-auart. " 'zor
      PERFORM f_bdc_field       USING 'KOMB-KUNNR(01)'
                                      <lfs_final>-kunnr.    "'1000022'.
      PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                      <lfs_final>-parvw.
      PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                      <lfs_final>-nacha.
      PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                      <lfs_final>-vsztp.

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1901'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'KOMB-KUNNR(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=KOMM'.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0233'.

      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                  'NACH-TDARMOD'.

      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'.
      PERFORM f_bdc_field       USING 'NACH-TDSCHEDULE'
                                  <lfs_final>-tdschedule. "IMM
      PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                <lfs_final>-tdarmod  . " '3'.


    ELSEIF (   <lfs_final>-keycombi  = c_zba03       "'ZBA0F903'
               OR <lfs_final>-keycombi = c_zrgaf3    "'ZRGAF903'
               OR <lfs_final>-keycombi = c_zko0f3 ). "'ZKO0F901'

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV13B-KSCHL'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                    <lfs_final>-kschl.
      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV130-SELKZ(03)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=WEIT'.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                    ''.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(03)'
                                    'X'.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1903'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-VSZTP(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                       <lfs_final>-vkorg.
      PERFORM f_bdc_field       USING 'KOMB-KUNNR(01)'
                                       <lfs_final>-kunnr.
      PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                        <lfs_final>-parvw.
      PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                        <lfs_final>-nacha.
      PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                       <lfs_final>-vsztp.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1903'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                 'KOMB-KUNNR(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                        '=KOMM'.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0233'.

      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                  'NACH-TDARMOD'.

      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'.
      PERFORM f_bdc_field       USING 'NACH-TDSCHEDULE'
                                  <lfs_final>-tdschedule. "IMM
      PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                <lfs_final>-tdarmod  . " '3'.

      " '3'.
* If the keycombination field is 'ZBA1901' or 'ZRGB901' or 'ZKO1901'
* use 'ZBA1901' recording for above key combinations
    ELSEIF ( <lfs_final>-keycombi = c_zba11     " 'ZBA1901'
          OR <lfs_final>-keycombi = c_zrgb1     " 'ZRGB901'
          OR <lfs_final>-keycombi = c_zko11  ). " 'ZKO1901'

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV13B-KSCHL'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                    <lfs_final>-kschl.
      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV130-SELKZ(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=WEIT'.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1901'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-VSZTP(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                    <lfs_final>-vkorg.
      PERFORM f_bdc_field       USING 'KOMB-AUART'
                                    <lfs_final>-auart.
      PERFORM f_bdc_field       USING 'KOMB-KUNNR(01)'
                                    <lfs_final>-kunnr.
      PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                    <lfs_final>-parvw.
      PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                    <lfs_final>-nacha.
      PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                    <lfs_final>-vsztp.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1901'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'KOMB-KUNNR(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=KOMM'.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0235'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-TCODE'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'NACH-TCODE'
 " 'CS01'.
                                   <lfs_final>-tcode.
      PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                   <lfs_final>-tdarmod.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0235'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-LDEST'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'NACH-TCODE'
                                   <lfs_final>-tcode.
      PERFORM f_bdc_field       USING 'NACH-LDEST'
                                   <lfs_final>-ldest.
      PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                   <lfs_final>-tdarmod.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0235'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-TCODE'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=SICH'.
      PERFORM f_bdc_field       USING 'NACH-TCODE'
                                   <lfs_final>-tcode.
      PERFORM f_bdc_field       USING 'NACH-LDEST'
                                   <lfs_final>-ldest.
      PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                   <lfs_final>-tdarmod.

* If the keycombination field is 'ZBA1902' or 'ZRGB902' or 'ZKO1902'
* use 'ZBA1902' recording for above key combinations
    ELSEIF ( <lfs_final>-keycombi = c_zba12                 "'ZBA1902'
          OR <lfs_final>-keycombi = c_zrgb2    "'ZRGB902'
          OR <lfs_final>-keycombi = c_zko12 ).              "'ZKO1902'

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV13B-KSCHL'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                   <lfs_final>-kschl.
      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV130-SELKZ(02)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=WEIT'.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                    ''.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(02)'
                                    'X'.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1902'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'KOMB-AUART'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                  <lfs_final>-vkorg.
      PERFORM f_bdc_field       USING 'KOMB-AUART'
                                  <lfs_final>-auart.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1902'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-VSZTP(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                  <lfs_final>-vkorg.
      PERFORM f_bdc_field       USING 'KOMB-AUART'
                                  <lfs_final>-auart.
      PERFORM f_bdc_field       USING 'KOMB-KUNWE(01)'
                                   <lfs_final>-kunwe.
      PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                   <lfs_final>-parvw.
      PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                   <lfs_final>-nacha.
      PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                    <lfs_final>-vsztp.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1902'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'KOMB-KUNWE(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=MARL'.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1902'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'KOMB-KUNWE(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=KOMM'.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0235'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-LDEST'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=SICH'.
      PERFORM f_bdc_field       USING 'NACH-TCODE'
                                     <lfs_final>-tcode.
      PERFORM f_bdc_field       USING 'NACH-LDEST'
                                     <lfs_final>-ldest.
      PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                    <lfs_final>-tdarmod.

* If the keycombination field is 'ZBA1903' or 'ZRGB903' or 'ZKO1903'
* use 'ZBA1903' recording for above key combinations
    ELSEIF ( <lfs_final>-keycombi = c_zba13                 "'ZBA1903'
          OR <lfs_final>-keycombi = c_zrgb3    "'ZRGB903'
          OR <lfs_final>-keycombi = c_zko13 ).              "'ZKO1903'

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV13B-KSCHL'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                   <lfs_final>-kschl.
      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV130-SELKZ(03)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=WEIT'.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                    ''.
*---Begin of Insert SCTASK0801091 by U104864 on 07-March-2019.
*Field Change based on the keyCombination
      IF    <lfs_final>-keycombi = c_zba13 . "'ZBA1903' If KeyCombi eq  ZBA1903
        PERFORM f_bdc_field       USING 'RV130-SELKZ(05)'"Use KeyField = 05
                                      'X'.
      ELSE. "If KeyCombi eq  'ZRGB903' or 'ZKO1903'
*---End of Insert SCTASK0801091 by U104864 on 07-March-2019.
        PERFORM f_bdc_field       USING 'RV130-SELKZ(03)'"Use KeyField = 03
                                      'X'.
*---Begin of Insert SCTASK0801091 by U104864 on 07-March-2019.
      ENDIF."End of KeyCombi eq  ZBA1903
*---End of Insert SCTASK0801091 by U104864 on 07-March-2019.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1903'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'KOMB-VKORG'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                   <lfs_final>-vkorg.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1903'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-VSZTP(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                     <lfs_final>-vkorg.
      PERFORM f_bdc_field       USING 'KOMB-KUNNR(01)'
                                     <lfs_final>-kunnr.
      PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
 "'SP'.
                                    <lfs_final>-parvw.
      PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                    <lfs_final>-nacha.
      PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                    <lfs_final>-vsztp.
      IF <lfs_final>-nacha NE '8'.    " SCTASK0801091
        PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1903'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'KOMB-KUNNR(01)'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=MARL'.
        PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1903'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'KOMB-KUNNR(01)'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=KOMM'.
        PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0235'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'NACH-LDEST'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM f_bdc_field       USING 'NACH-TCODE'
                                    <lfs_final>-tcode.
        PERFORM f_bdc_field       USING 'NACH-LDEST'
                                    <lfs_final>-ldest.
        PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                    <lfs_final>-tdarmod.
        PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0235'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'NACH-TCODE'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=SICH'.
        PERFORM f_bdc_field       USING 'NACH-TCODE'
                                     <lfs_final>-tcode.
        PERFORM f_bdc_field       USING 'NACH-LDEST'
                                      <lfs_final>-ldest.
        PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                     <lfs_final>-tdarmod.
* Begin of SCTASK0801091
      ELSE.
        PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1903'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'KOMB-KUNNR(01)'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=SICH'.
      ENDIF.
* End of SCTASK0801091
* If the keycombination field is 'ZBA1904' or 'ZRGB904' or 'ZKO1904'
* use 'ZBA1904' recording for above key combinations
    ELSEIF ( <lfs_final>-keycombi = c_zba14                 "'ZBA1904'
          OR <lfs_final>-keycombi = c_zrgb4    "'ZRGB904'
          OR <lfs_final>-keycombi = c_zko14 ).              "'ZKO1904'

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV13B-KSCHL'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                    <lfs_final>-kschl.
      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV130-SELKZ(04)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=WEIT'.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                    ''.
*---Begin of Insert SCTASK0801091 by U104864 on 07-March-2019.
*Field Change based on the keyCombination
      IF    <lfs_final>-keycombi = c_zba14 . "'ZBA1904' If KeyCombi eq  ZBA1904
        PERFORM f_bdc_field       USING 'RV130-SELKZ(06)' "Use KeyField = 06
                                      'X'.
      ELSE. "If KeyCombi eq 'ZRGB904' or 'ZKO1904'.
*---End of Insert SCTASK0801091 by U104864 on 07-March-2019.
        PERFORM f_bdc_field       USING 'RV130-SELKZ(04)' "Use KeyField = 04
                                      'X'.
*---Begin of Insert SCTASK0801091 by U104864 on 07-March-2019.
      ENDIF."End of KeyCombi eq  ZBA1904
*---End of Insert SCTASK0801091 by U104864 on 07-March-2019.

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1904'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-VSZTP(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                  <lfs_final>-vkorg.
      PERFORM f_bdc_field       USING 'KOMB-KUNWE(01)'
                                  <lfs_final>-kunwe.
      PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                  <lfs_final>-parvw.
      PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                   <lfs_final>-nacha.
      PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                   <lfs_final>-vsztp.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1904'.
      IF <lfs_final>-nacha NE '8'.    " SCTASK0801091
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'KOMB-KUNWE(01)'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=MARL'.
        PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1904'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'KOMB-KUNWE(01)'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=KOMM'.
        PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0235'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'NACH-LDEST'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM f_bdc_field       USING 'NACH-TCODE'
                                    <lfs_final>-tcode.
        PERFORM f_bdc_field       USING 'NACH-LDEST'
                                     <lfs_final>-ldest.
        PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                    <lfs_final>-tdarmod.
        PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0235'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'NACH-TCODE'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=SICH'.
        PERFORM f_bdc_field       USING 'NACH-TCODE'
                                      <lfs_final>-tcode.
        PERFORM f_bdc_field       USING 'NACH-LDEST'
                                       <lfs_final>-ldest.
        PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                     <lfs_final>-tdarmod.
* Begin of SCTASK0801091
      ELSE.
        PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1904'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-VSZTP(01)'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                        '=SICH'.
      ENDIF.
* End of  SCTASK0801091
* If the keycombination field is Z855901
* use Z855901 recording
    ELSEIF <lfs_final>-keycombi = c_z8551.                  "'Z855901'.

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV13B-KSCHL'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                 <lfs_final>-kschl.
** D2 changes, begin of commenting
*      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
*      PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                    'RV130-SELKZ(03)'.
*      PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                    '=WEIT'.
*      PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
*                                    ''.
*      PERFORM f_bdc_field       USING 'RV130-SELKZ(03)'
*                                    'X'.
** D2 changes, end of commenting
** D2 changes
      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV130-SELKZ(04)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=WEIT'.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                    ''.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(02)'
                                    ''.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(03)'
                                    ''.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(04)'
                                    'X'.
** End of D2 changes
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1901'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-SPRAS(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                    <lfs_final>-vkorg.      " '1000'.
      PERFORM f_bdc_field       USING 'KOMB-AUART'
                                     <lfs_final>-auart. "'ZOR'.
      PERFORM f_bdc_field       USING 'KOMB-KUNNR(01)'
                                      <lfs_final>-kunnr.    "'1000005'.
      PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
*                                    'LS'.                     " Defect 380
                                      <lfs_final>-parvw. " Defect 380
      PERFORM f_bdc_field       USING 'RV13B-PARNR(01)'
*                                    'E1DCLNT300'.
                                      <lfs_final>-parnr.
      PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
*                                    '6'.                      " Defect 380
                                      <lfs_final>-nacha. " Defect 380
      PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
*                                    '1'.                      " Defect 380
                                      <lfs_final>-vsztp. " Defect 380
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1901'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'KOMB-KUNNR(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=SICH'.


* If the keycombination field is Z855903
* use Z855903 recording
    ELSEIF <lfs_final>-keycombi = c_z855.                   "'Z855903'.

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV13B-KSCHL'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                    <lfs_final>-kschl. " 'Z855'.
** D2 Changes, begin of commenting
*      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
*      PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                    'RV130-SELKZ(04)'.
*      PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                    '=WEIT'.
*      PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
*                                    ''.
*      PERFORM f_bdc_field       USING 'RV130-SELKZ(04)'
*                                    'X'.
** D2 changes, end of commenting
** Begin of D2 Changes
      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV130-SELKZ(05)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=WEIT'.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                    ''.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(02)'
                                    ''.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(03)'
                                    ''.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(04)'
                                    ''.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(05)'
                                    'X'.
**** end of D2 Changes
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1903'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-VSZTP(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                    <lfs_final>-vkorg. "'1000'.
      PERFORM f_bdc_field       USING 'KOMB-KUNNR(01)'
                                     <lfs_final>-kunnr.     "'1000005'.
      PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
*                                    'LS'.                     " Defect 380
                                      <lfs_final>-parvw. " Defect 380
      PERFORM f_bdc_field       USING 'RV13B-PARNR(01)'
*                                    'E1DCLNT300'.
                                      <lfs_final>-parnr.
      PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
*                                    '6'.                        " Defect 380
                                      <lfs_final>-nacha. " Defect 380
      PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
*                                    '1'.                        " Defect 380
                                      <lfs_final>-vsztp. " Defect 380
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1903'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'KOMB-KUNNR(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=SICH'.


* If the keycombination field is Z855908
* use Z855908 recording
    ELSEIF <lfs_final>-keycombi = c_z8558.                  "'Z855908'.

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV13B-KSCHL'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                 <lfs_final>-kschl.
** D2 Changes, commented below lines
*      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
*      PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                    'RV130-SELKZ(01)'.
*      PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                    'RV130-SELKZ(02)'.
*      PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                    '=WEIT'.
** D2 end of commenting
** Begin of D2 Changes
      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV130-SELKZ(02)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=WEIT'.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                    ''.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(02)'
                                    'X'.
**** end of D2 Changes
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1908'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'KOMB-AUART'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                    <lfs_final>-vkorg.
      PERFORM f_bdc_field       USING 'KOMB-AUART'
                                     <lfs_final>-auart.
      PERFORM f_bdc_field       USING 'KOMB-ZZBSARK'
                                 <lfs_final>-zzbsark.

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1908'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-VSZTP(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG'
*                                    '1000'.            " Hardcode '1000'   " Defect 380
                                      <lfs_final>-vkorg. " Defect 380

      PERFORM f_bdc_field       USING 'KOMB-AUART'
                                    <lfs_final>-auart.
      PERFORM f_bdc_field       USING 'KOMB-KUNNR(01)'
                                    <lfs_final>-kunnr.
      PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
*                                    'LS'.        " Hardcode LS       " Defect 380
                                      <lfs_final>-parvw. " Defect 380
      PERFORM f_bdc_field       USING 'RV13B-PARNR(01)'
*                                    'E1DCLNT300'.
                                     <lfs_final>-parnr.
      PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
*                                    '6'.                 "Hardcode '6'   " Defect 380
                                      <lfs_final>-nacha. " Defect 380
      PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                   <lfs_final>-vsztp.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1908'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'KOMB-KUNNR(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=SICH'.

* If the keycombination field is Z855909
* use Z855909 recording
    ELSEIF ( <lfs_final>-keycombi = c_z8559   " 'Z855909'.
*---Begin of Insert SCTASK0801091 by U104864 on 07-March-2019.
          OR <lfs_final>-keycombi = c_zba09   " 'ZBA0909'.
          OR <lfs_final>-keycombi = c_zba19 )." 'ZBA1909'.
*---End of Insert SCTASK0801091 by U104864 on 07-March-2019.

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV13B-KSCHL'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                 <lfs_final>-kschl.
** D2 Changes , begin of commenting
*      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
*      PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                    'RV130-SELKZ(02)'.
*      PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                    '=WEIT'.
*      PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
*                                    ''.
*      PERFORM f_bdc_field       USING 'RV130-SELKZ(02)'
*                                    'X'.
** End of Commenting
** Begin of D2 Changes
      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV130-SELKZ(03)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=WEIT'.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                    ''.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(02)'
                                    ''.
      PERFORM f_bdc_field       USING 'RV130-SELKZ(03)'
                                    'X'.
**** end of D2 Changes

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1909'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'KOMB-KUNNR(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                  <lfs_final>-vkorg.
      PERFORM f_bdc_field       USING 'KOMB-ZZBSARK'
                                  <lfs_final>-zzbsark.

      PERFORM f_bdc_field       USING 'KOMB-KUNNR(01)'
                                    <lfs_final>-kunnr.
      PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
*                                    'LS'.                   " Defect 380
                                      <lfs_final>-parvw. " Defect 380
      PERFORM f_bdc_field       USING 'RV13B-PARNR(01)'
*                                    'E1DCLNT300'.
                                     <lfs_final>-parnr.
      PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
*                                    '6'.                     " Defect 380
                                      <lfs_final>-nacha. " Defect 380
      PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                    <lfs_final>-vsztp.

*---Begin of Insert SCTASK0801091 by U033876 on 08-March-2019.
      IF  <lfs_final>-keycombi = c_zba09   " 'ZBA0909'.
          OR <lfs_final>-keycombi = c_zba19.

        PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1909'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'KOMB-KUNNR(01)'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=KOMM'.


        PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0233'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'NACH-DIMME'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=SICH'.
        PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                       <lfs_final>-tdarmod.
        PERFORM f_bdc_field       USING 'NACH-DIMME'
                                <lfs_final>-dimme.
      ELSE.
*---End of Insert SCTASK0801091 by U033876 on 07-March-2019.

        PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1909'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'KOMB-KUNNR(01)'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=SICH'.
*---Begin of Insert SCTASK0801091 by U033876 on 08-March-2019.
      ENDIF.
*---End of Insert SCTASK0801091 by U033876 on 07-March-2019.

* If the keycombination field is ZRRC907
* use ZRRC907 recording
    ELSEIF <lfs_final>-keycombi = c_zrcc . "'ZRRC907'.

      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV13B-KSCHL'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=ANTA'.
      PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                   <lfs_final>-kschl.
      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV130-SELKZ(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=WEIT'.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1907'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-VSZTP(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                      <lfs_final>-vkorg.
      PERFORM f_bdc_field       USING 'KOMB-VTWEG'
                                   <lfs_final>-vtweg.
      PERFORM f_bdc_field       USING 'KOMB-AUART(01)'
                                   <lfs_final>-auart.
      PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                  <lfs_final>-nacha.
      PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                 <lfs_final>-vsztp.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1907'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'KOMB-AUART(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=MARL'.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1907'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'KOMB-AUART(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=KOMM'.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0235'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-LDEST'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'NACH-TCODE'
                                  <lfs_final>-tcode.
      PERFORM f_bdc_field       USING 'NACH-LDEST'
                                  <lfs_final>-ldest.
      PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                  <lfs_final>-tdarmod.
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0235'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-TCODE'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=SICH'.
      PERFORM f_bdc_field       USING 'NACH-TCODE'
                                  <lfs_final>-tcode.
      PERFORM f_bdc_field       USING 'NACH-LDEST'
                                  <lfs_final>-ldest.
      PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                   <lfs_final>-tdarmod.
** D2 Changes
    ELSEIF <lfs_final>-keycombi = c_z855921.                "'Z855921'
** Screen : Condition record
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV13B-KSCHL'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=ANTA'.
      PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                   <lfs_final>-kschl.
** Screen : Provide the Key Combination
      PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'RV130-SELKZ(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=WEIT'.
** Provide the Condition Record details
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1921'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'NACH-SPRAS(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field       USING 'KOMB-VKORG' "Sales Organization
                                   <lfs_final>-vkorg.
      PERFORM f_bdc_field       USING 'KOMB-VTWEG' "Distribution Channel
                                   <lfs_final>-vtweg.
      PERFORM f_bdc_field       USING 'KOMB-AUART' "Order Type
                                   <lfs_final>-auart.
      PERFORM f_bdc_field       USING 'KOMB-ZZBSARK(01)' "Customer Purchase Order Type
                                   <lfs_final>-zzbsark.
      PERFORM f_bdc_field       USING 'NACH-PARVW(01)' "Partner Function
                                   <lfs_final>-parvw.
      PERFORM f_bdc_field       USING 'RV13B-PARNR(01)' "Partner Function
                                   <lfs_final>-parnr.
      PERFORM f_bdc_field       USING 'NACH-NACHA(01)' "Message transmission medium
                                   <lfs_final>-nacha.
      PERFORM f_bdc_field       USING 'NACH-VSZTP(01)' "Dispatch time
                                   <lfs_final>-vsztp.
      PERFORM f_bdc_field       USING 'NACH-SPRAS(01)' "Language
                                       sy-langu.
** Save the Condition Record
      PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1921'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'KOMB-ZZBSARK(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=SICH'.
** End of Changes

    ENDIF. " LOOP AT fp_i_final ASSIGNING <lfs_final>

    " BDC Insert Function module
    CALL FUNCTION 'BDC_INSERT'
      EXPORTING
        tcode            = c_tcode
      TABLES
        dynprotab        = i_bdcdata
      EXCEPTIONS
        internal_error   = 1
        not_open         = 2
        queue_error      = 3
        tcode_invalid    = 4
        printing_invalid = 5
        posting_invalid  = 6
        OTHERS           = 7.
    IF sy-subrc <> 0.
*write  an error message to i_report with the header record.
      lwa_error-keycombi   = <lfs_final>-keycombi.
      lwa_error-kschl      = <lfs_final>-kschl.
      lwa_error-vkorg      = <lfs_final>-vkorg.
      lwa_error-vtweg      = <lfs_final>-vtweg.
      lwa_error-auart      = <lfs_final>-auart.
      lwa_error-kunnr      = <lfs_final>-kunnr.
      lwa_error-kunwe      = <lfs_final>-kunwe.
      lwa_error-parvw      = <lfs_final>-parvw.
      lwa_error-nacha      = <lfs_final>-nacha.
      lwa_error-vsztp      = <lfs_final>-vsztp.
      lwa_error-tcode      = <lfs_final>-tcode.
      lwa_error-ldest      = <lfs_final>-ldest.
      lwa_error-tdarmod    = <lfs_final>-tdarmod.
      lwa_error-tdschedule = <lfs_final>-tdschedule.
      lwa_error-dimme      = <lfs_final>-dimme.
      lwa_error-zzbsark    = <lfs_final>-zzbsark.
      lwa_error-parnr      = <lfs_final>-parnr.

* Writing error message if insertion fails.
      CONCATENATE
      'BDC insert failed for key combination'(024) " Synchronization key
      <lfs_final>-keycombi
      INTO lwa_error-errormsg SEPARATED BY space.
      APPEND lwa_error TO fp_i_error.

      fp_gv_ecount = fp_gv_ecount + 1.
      gv_err_flg = c_true.

* Report update
      wa_report-key    = <lfs_final>-keycombi.
      wa_report-msgtyp = c_error.
      wa_report-msgtxt =
      'BDC insert failed for key combination'(024). " Synchronization key
      APPEND wa_report TO fp_i_report.
      CLEAR wa_report.
    ENDIF. " IF sy-subrc <> 0
  ENDLOOP.


ENDFORM. " F_BDCRECORD_VV11
*&---------------------------------------------------------------------*
*&      Form  F_SET_MODE
*&---------------------------------------------------------------------*
*       Setting the mode of processing
*       SPACE - for Verify only mode
*       "X"   - for Verify and Post mode
*----------------------------------------------------------------------*
*      <--FP_GV_MODE  Mode of Processing - Text
*----------------------------------------------------------------------*

FORM f_set_mode  CHANGING fp_gv_mode TYPE char10. " Set_mode changing fp_gv of type CHAR10

* Choosin the Mode
  IF rb_post = c_true.
    fp_gv_mode = 'Post Run'(013).
  ELSE. " ELSE -> IF rb_post = c_true
    fp_gv_mode = 'Test Run'(014).
  ENDIF. " IF rb_post = c_true

ENDFORM. " F_SET_MODE
*&---------------------------------------------------------------------*
*&      Form  F_ASSIGN_VV11
*&---------------------------------------------------------------------*
*       Assigning VV11
*----------------------------------------------------------------------*
*      -->FP_I_FINAL   Input Data
*      <--FP_I_REPORT  Input Error Data
*      <--FP_I_ERROR   Report
*----------------------------------------------------------------------*
FORM f_assign_vv11  USING    fp_i_final TYPE ty_t_modify
                    CHANGING fp_i_report TYPE ty_t_report
                             fp_i_error  TYPE ty_t_error.


  DATA : lv_session TYPE apq_grpn, "BDC Session Name
         lv_error   TYPE char1.    "To check BDC session created or not

  MOVE c_seson TO lv_session.

  PERFORM f_open_group USING    lv_session
                       CHANGING lv_error
                                fp_i_report.

  IF lv_error IS INITIAL.
* Performing recording for the transaction VV11
    PERFORM f_bdcrecord_vv11 USING    fp_i_final
                             CHANGING fp_i_error
                                      gv_ecount
                                      fp_i_report.


* close BDC Session Group
    PERFORM f_close_group USING    lv_session
                          CHANGING fp_i_report.

  ENDIF. " IF lv_error IS INITIAL
ENDFORM. " F_ASSIGN_VV11
*&---------------------------------------------------------------------*
*&      Form  F_OPEN_GROUP
*&---------------------------------------------------------------------*
*& Create BDC session
*----------------------------------------------------------------------
*      -->FP_LV_SESSION       Session Name
*      <--FP_LV_ERROR        Open group is success or failed
*      <--FP_I_REPORT[]  Report Table: Only BDC session related errors
*                        are captured in Report table. It does not
*                        track data post related error
*----------------------------------------------------------------------*

FORM f_open_group USING    fp_lv_session TYPE apq_grpn " Group name: Batch input session name
                  CHANGING fp_lv_error   TYPE char1    " Lv_error of type CHAR1
                           fp_i_report   TYPE ty_t_report.

* Local data declaration
  DATA: lv_qid     TYPE apq_quid,  "queue id
        lwa_report TYPE ty_report. "report table work are

  CALL FUNCTION 'BDC_OPEN_GROUP'
    EXPORTING
      client              = sy-mandt
      group               = fp_lv_session
      keep                = c_true
      user                = sy-uname
      prog                = sy-cprog
    IMPORTING
      qid                 = lv_qid
    EXCEPTIONS
      client_invalid      = 1
      destination_invalid = 2
      group_invalid       = 3
      group_is_locked     = 4
      holddate_invalid    = 5
      internal_error      = 6
      queue_error         = 7
      running             = 8
      system_lock_error   = 9
      user_invalid        = 10
      OTHERS              = 11.
  IF sy-subrc <> 0.
*set flag that open group fails
    fp_lv_error = c_error.
*   Populating the error message in case BDC Open is in error
    lwa_report-msgtyp = c_error.
*   Forming the text.
    MESSAGE i000 WITH 'Error in creating batch input session'(064)
                INTO lwa_report-msgtxt.
    APPEND lwa_report TO fp_i_report.
    CLEAR lwa_report.
  ENDIF. " IF sy-subrc <> 0
ENDFORM. " F_OPEN_GROUP
*&---------------------------------------------------------------------*
*&      Form  F_CLOSE_GROUP
*&---------------------------------------------------------------------*
*& Close BDC session
*----------------------------------------------------------------------
*      -->FP_I_REPORT        Error Log table
*----------------------------------------------------------------------*
FORM f_close_group USING    fp_lv_session TYPE apq_grpn " Group name: Batch input session name
                   CHANGING fp_i_report   TYPE ty_t_report.

  DATA: lwa_report  TYPE ty_report. "Local work area for error log

  " BDC Close Function Module
  CALL FUNCTION 'BDC_CLOSE_GROUP'
    EXCEPTIONS
      not_open    = 1
      queue_error = 2
      OTHERS      = 3.
  IF sy-subrc <> 0.
*     Populating the error message in case BDC Close is in error
    lwa_report-msgtyp = c_error.
*     Forming the text.
    MESSAGE i051 WITH fp_lv_session
                 INTO lwa_report-msgtxt.
    APPEND lwa_report TO fp_i_report.
    CLEAR lwa_report.
  ELSE. " ELSE -> IF sy-subrc <> 0
*     Populating the success message in case BDC Close is successfull
    lwa_report-msgtyp = c_success.
*     Forming the text.
    MESSAGE i052 WITH fp_lv_session
                 INTO lwa_report-msgtxt.
    APPEND lwa_report TO fp_i_report.
    CLEAR lwa_report.
*Exporting the BDC Session name to memory id
    MOVE fp_lv_session TO gv_session_gl_1.
  ENDIF. " IF sy-subrc <> 0
ENDFORM. " F_CLOSE_GROUP
*&---------------------------------------------------------------------*
*&      Form  F_FORM_KEY
*&---------------------------------------------------------------------*
*       Forming the message key based on Chosen option
*----------------------------------------------------------------------*
*      -->FP_LFS_MODIFY       Input record
*      <--FP_lwa_report_KEY  Message Key
*----------------------------------------------------------------------*
FORM f_form_key  USING    fp_lfs_modify      TYPE ty_modify
                 CHANGING fp_lwa_report_key  TYPE string.

* Forming the Key
*Key is formed based on Material/Plant/Production Version
  CONCATENATE         fp_lfs_modify-keycombi
                      fp_lfs_modify-kschl
                      fp_lfs_modify-vkorg
*-- Begin of Defect 1889
                      fp_lfs_modify-vtweg
                      fp_lfs_modify-auart
                      fp_lfs_modify-kunnr
*-- End of defect 1889
          INTO fp_lwa_report_key
          SEPARATED BY c_slash.
ENDFORM. " F_FORM_KEY
*&---------------------------------------------------------------------*
*&      Form  F_VAL
*&---------------------------------------------------------------------*
*       Validations
*----------------------------------------------------------------------*
*      -->FP_I_MODIFY[]  Input table
*      <--FP_I_OUTPUT[]  Table for BDC data
*      <--FP_I_REPORT[]  Report Table
*      <--FP_I_ERROR[]   Erroneous Record List
*----------------------------------------------------------------------*
FORM f_val  USING    fp_i_modify TYPE ty_t_modify
         CHANGING    fp_i_final  TYPE ty_t_final
                     fp_i_report TYPE ty_t_report
                     fp_i_error  TYPE ty_t_error.

*Local Data
* Field Symbols Declaration
  FIELD-SYMBOLS: <lfs_modify> TYPE ty_modify.

  DATA : lv_key     TYPE string,    "Message Key
         lwa_report TYPE ty_report, "work area for report table
         lwa_final  TYPE ty_modify, "Final internal table
         lv_error   TYPE char1.     "Error flag


  LOOP AT fp_i_modify ASSIGNING <lfs_modify>.

*   Forming the Message key from record in case error report is needed.
    PERFORM f_form_key USING    <lfs_modify>
                       CHANGING lv_key.

*Mandatory fields validation
    CLEAR lv_error.
*Key Combination is Mandatory
    IF <lfs_modify>-keycombi IS INITIAL.
      lv_error = c_true.
      lwa_report-msgtyp = c_error.
*   Forming the text.
      lwa_report-key = lv_key.
      MESSAGE i000 WITH 'Mandatory field "Key Combination" is missing'(060)
          INTO lwa_report-msgtxt.
      APPEND  lwa_report TO fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
      PERFORM f_error_file_application_make USING <lfs_modify>
                                                  lwa_report
                                         CHANGING fp_i_error.
      CLEAR lwa_report.
    ENDIF. " IF <lfs_modify>-keycombi IS INITIAL

*Condition Type is Mandatory
    IF <lfs_modify>-kschl IS INITIAL.
      lv_error = c_true.
      lwa_report-msgtyp = c_error.
*   Forming the text.
      lwa_report-key = lv_key.
      MESSAGE i000 WITH 'Mandatory field Condition Type is missing'(058)
          INTO lwa_report-msgtxt.
      APPEND  lwa_report TO fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
      PERFORM f_error_file_application_make USING <lfs_modify>
                                                  lwa_report
                                         CHANGING fp_i_error.
      CLEAR lwa_report.
    ELSE. " ELSE -> IF <lfs_modify>-kschl IS INITIAL
      READ TABLE i_kschl TRANSPORTING NO FIELDS
                         WITH KEY kschl = <lfs_modify>-kschl
                         BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_error = c_true.
        lwa_report-msgtyp = c_error.
*-- Begin of Defect 1889
*        lwa_report-msgtxt = 'Condition type does not exist'(022).
        CONCATENATE 'Condition type'(022)
                    <lfs_modify>-kschl
                    'does not exist'(066)
               INTO lwa_report-msgtxt
               SEPARATED BY space.
*-- End of defect 1889
        lwa_report-key = lv_key.
        APPEND lwa_report TO fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
        PERFORM f_error_file_application_make USING <lfs_modify>
                                                    lwa_report
                                           CHANGING fp_i_error.
        CLEAR lwa_report.
      ENDIF. " IF sy-subrc NE 0
    ENDIF. " IF <lfs_modify>-kschl IS INITIAL

*Sales Organisation is Mandatory
    IF <lfs_modify>-vkorg IS INITIAL.
      lv_error = c_true.
      lwa_report-msgtyp = c_error.
*   Forming the text.
      lwa_report-key = lv_key.
      MESSAGE i000 WITH 'Mandatory field Sales Organisation is missing'(059)
          INTO lwa_report-msgtxt.
      APPEND  lwa_report TO fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
      PERFORM f_error_file_application_make USING <lfs_modify>
                                                  lwa_report
                                         CHANGING fp_i_error.
      CLEAR lwa_report.
    ELSE. " ELSE -> IF <lfs_modify>-vkorg IS INITIAL
      READ TABLE i_vkorg TRANSPORTING NO FIELDS
                         WITH KEY vkorg = <lfs_modify>-vkorg
                         BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_error = c_true.
        lwa_report-msgtyp = c_error.
*-- Begin of Defect 1889
*        lwa_report-msgtxt = 'Sales organization does not exist'(017).
        CONCATENATE 'Sales organization'(017)
                    <lfs_modify>-vkorg
                    'does not exist'(066)
               INTO lwa_report-msgtxt
               SEPARATED BY space.
*-- End of Defect 1889
        lwa_report-key = lv_key.

        APPEND lwa_report TO fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
        PERFORM f_error_file_application_make USING <lfs_modify>
                                                    lwa_report
                                           CHANGING fp_i_error.
        CLEAR lwa_report.
      ENDIF. " IF sy-subrc NE 0
    ENDIF. " IF <lfs_modify>-vkorg IS INITIAL

*Sold to party or ship to party is Mandatory
    IF <lfs_modify>-kschl NE c_ctype.
** D2 Changes
      IF <lfs_modify>-keycombi NE c_z855921.
** End of D2 changes

        IF <lfs_modify>-kunnr IS INITIAL AND
           <lfs_modify>-kunwe IS INITIAL.
          lv_error = c_true.
          lwa_report-msgtyp = c_error.
*   Forming the text.
          lwa_report-key = lv_key.
          MESSAGE i000 WITH 'Mandatory field Customer is missing'(061)
              INTO lwa_report-msgtxt.
          APPEND  lwa_report TO fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
          PERFORM f_error_file_application_make USING <lfs_modify>
                                                      lwa_report
                                             CHANGING fp_i_error.
          CLEAR lwa_report.
        ENDIF. " IF <lfs_modify>-kunnr IS INITIAL AND
** D2 Changes
      ENDIF. " IF <lfs_modify>-keycombi NE c_z855921
** End of D2 changes
    ENDIF. " IF <lfs_modify>-kschl NE c_ctype

*Message transmission medium is Mandatory
    IF <lfs_modify>-nacha IS INITIAL.
      lv_error = c_true.
      lwa_report-msgtyp = c_error.
*   Forming the text.
      lwa_report-key = lv_key.
      MESSAGE i000 WITH 'Mandatory field transmission medium is missing'(062)
          INTO lwa_report-msgtxt.
      APPEND  lwa_report TO fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
      PERFORM f_error_file_application_make USING <lfs_modify>
                                                  lwa_report
                                         CHANGING fp_i_error.
      CLEAR lwa_report.
    ENDIF. " IF <lfs_modify>-nacha IS INITIAL

*Dispatch time is Mandatory
    IF <lfs_modify>-vsztp IS INITIAL.
      lv_error = c_true.
      lwa_report-msgtyp = c_error.
*   Forming the text.
      lwa_report-key = lv_key.
      MESSAGE i000 WITH 'Mandatory field Dispatch time is missing'(063)
          INTO lwa_report-msgtxt.
      APPEND  lwa_report TO fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
      PERFORM f_error_file_application_make USING <lfs_modify>
                                                  lwa_report
                                         CHANGING fp_i_error.
      CLEAR lwa_report.
    ENDIF. " IF <lfs_modify>-vsztp IS INITIAL

*    Distribution channel
    IF <lfs_modify>-vtweg IS NOT INITIAL.
      READ TABLE i_vtweg TRANSPORTING NO FIELDS
       WITH KEY vtweg = <lfs_modify>-vtweg
       BINARY SEARCH .

      IF sy-subrc NE 0 .
        lv_error = c_true.
        lwa_report-msgtyp = c_error.
*-- Begin of Defect 1889
*        lwa_report-msgtxt = 'Distribution Channel does not exist'(027).
        CONCATENATE 'Distribution Channel'(027)
                    <lfs_modify>-vtweg
                    'does not exist'(066)
               INTO  lwa_report-msgtxt
            SEPARATED BY space.
*-- End of Defect 1889
        lwa_report-key = lv_key.
        APPEND lwa_report TO fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
        PERFORM f_error_file_application_make USING <lfs_modify>
                                                    lwa_report
                                           CHANGING fp_i_error.
        CLEAR lwa_report.
      ENDIF. " IF sy-subrc NE 0
    ENDIF. " IF <lfs_modify>-vtweg IS NOT INITIAL

*  Customer number ( sold-to party )
    IF <lfs_modify>-kunnr IS NOT INITIAL.

      READ TABLE i_kunnr TRANSPORTING NO FIELDS
           WITH KEY kunnr = <lfs_modify>-kunnr
           BINARY SEARCH .
      IF sy-subrc NE 0.
        lv_error = c_true.
        lwa_report-msgtyp = c_error.
*-- Begin of Defect 1889
*        lwa_report-msgtxt = 'Sold to party does not exist'(019).
        CONCATENATE 'Sold to party'(019)
                    <lfs_modify>-kunnr
                    'does not exist'(066)
               INTO lwa_report-msgtxt
            SEPARATED BY space.
*-- End of Defect 1889
        lwa_report-key = lv_key.
        APPEND lwa_report TO fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
        PERFORM f_error_file_application_make USING <lfs_modify>
                                                    lwa_report
                                           CHANGING fp_i_error.
        CLEAR lwa_report.
      ENDIF. " IF sy-subrc NE 0
    ENDIF. " IF <lfs_modify>-kunnr IS NOT INITIAL

*Customer number ( ship-to party )
    IF  <lfs_modify>-kunwe IS NOT INITIAL.

      READ TABLE i_kunnr TRANSPORTING NO FIELDS
           WITH KEY kunnr = <lfs_modify>-kunwe
           BINARY SEARCH .
      IF sy-subrc NE 0.
        lv_error = c_true.
        lwa_report-msgtyp = c_error.
*-- Begin of Defect 1889
*        lwa_report-msgtxt = 'Ship to party does not exist'(031).
        CONCATENATE 'Ship to party'(031)
                    <lfs_modify>-kunwe
                    'does not exist'(066)
               INTO lwa_report-msgtxt
            SEPARATED BY space.
*-- End of Defect 1889
        lwa_report-key = lv_key.
        APPEND lwa_report TO fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
        PERFORM f_error_file_application_make USING <lfs_modify>
                                                    lwa_report
                                           CHANGING fp_i_error.
        CLEAR lwa_report.
      ENDIF. " IF sy-subrc NE 0
    ENDIF. " IF <lfs_modify>-kunwe IS NOT INITIAL

*Partner function
    IF <lfs_modify>-parvw IS NOT INITIAL.
      READ TABLE i_parvw TRANSPORTING NO FIELDS
           WITH KEY parvw = <lfs_modify>-parvw
           BINARY SEARCH.

      IF sy-subrc NE 0.
        lv_error = c_true.
        lwa_report-msgtyp = c_error.
*-- Begin of Defect 1889
*        lwa_report-msgtxt = 'Partner function does not exist'(020).
        CONCATENATE 'Partner function'(020)
                    <lfs_modify>-parvw
                    'does not exist'(066)
               INTO lwa_report-msgtxt
            SEPARATED BY space.
*-- End of Defect 1889
        lwa_report-key = lv_key.
        APPEND lwa_report TO fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
        PERFORM f_error_file_application_make USING <lfs_modify>
                                                    lwa_report
                                           CHANGING fp_i_error.
        CLEAR lwa_report.
      ENDIF. " IF sy-subrc NE 0
    ENDIF. " IF <lfs_modify>-parvw IS NOT INITIAL

*Sales document type
    IF  <lfs_modify>-auart IS NOT INITIAL.
      READ TABLE i_auart TRANSPORTING NO FIELDS
          WITH KEY auart = <lfs_modify>-auart
          BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_error = c_true.
        lwa_report-msgtyp = c_error.
*-- Begin of Defect 1889
*        lwa_report-msgtxt = 'Sales Document Type does not exist'(021).
        CONCATENATE 'Sales Document Type'(021)
                    <lfs_modify>-auart
                    'does not exist'(066)
               INTO lwa_report-msgtxt
            SEPARATED BY space.
*-- End of Defect 1889
        lwa_report-key = lv_key.
        APPEND lwa_report TO fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
        PERFORM f_error_file_application_make USING <lfs_modify>
                                                    lwa_report
                                           CHANGING fp_i_error.
        CLEAR lwa_report.
      ENDIF. " IF sy-subrc NE 0
    ENDIF. " IF <lfs_modify>-auart IS NOT INITIAL

*Validating condition record in table b901

    IF <lfs_modify>-zzbsark IS INITIAL.
      READ TABLE i_b901 TRANSPORTING NO FIELDS
           WITH KEY kappl  =  c_v "'V1'
                    kschl  = <lfs_modify>-kschl
                    vkorg  = <lfs_modify>-vkorg
                    auart =  <lfs_modify>-auart
                    kunnr =  <lfs_modify>-kunnr
                   BINARY SEARCH.

      IF sy-subrc EQ 0.
        lv_error = c_true.
        lwa_report-msgtyp = c_error.
        lwa_report-msgtxt = 'Condition record already exists in b901 table'(032).
        lwa_report-key = lv_key.
        APPEND lwa_report TO fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
        PERFORM f_error_file_application_make USING <lfs_modify>
                                                    lwa_report
                                           CHANGING fp_i_error.
        CLEAR lwa_report.

      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF <lfs_modify>-zzbsark IS INITIAL

*Validating condition record in table b902

    READ TABLE i_b902 TRANSPORTING NO FIELDS
         WITH KEY kappl  =  c_v "'V1'
                  kschl  = <lfs_modify>-kschl
                  vkorg  = <lfs_modify>-vkorg
                  auart =  <lfs_modify>-auart
                  kunwe =  <lfs_modify>-kunwe
                BINARY SEARCH.

    IF sy-subrc EQ 0.
      lv_error = c_true.
      lwa_report-msgtyp = c_error.
      lwa_report-msgtxt = 'Condition record already exists in b902 table'(033).
      lwa_report-key = lv_key.
      APPEND lwa_report TO fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
      PERFORM f_error_file_application_make USING <lfs_modify>
                                                  lwa_report
                                         CHANGING fp_i_error.
      CLEAR lwa_report.
    ENDIF. " IF sy-subrc EQ 0

    IF <lfs_modify>-auart IS INITIAL.
*Vvalidating condition record in table b903

      READ TABLE i_b903 TRANSPORTING NO FIELDS
      WITH KEY kappl  = c_v
               kschl  = <lfs_modify>-kschl
               vkorg  = <lfs_modify>-vkorg
               kunnr  = <lfs_modify>-kunnr
              BINARY SEARCH.


      IF sy-subrc EQ 0.
        lv_error = c_true.
        lwa_report-msgtyp = c_error.
        lwa_report-msgtxt = 'Condition record already exists in b903 table'(034).
        lwa_report-key = lv_key.
        APPEND lwa_report TO fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
        PERFORM f_error_file_application_make USING <lfs_modify>
                                                    lwa_report
                                           CHANGING fp_i_error.
        CLEAR lwa_report.

      ENDIF. " IF sy-subrc EQ 0

*Validating condition record in table b904

      READ TABLE i_b904 TRANSPORTING NO FIELDS
           WITH KEY kappl  = c_v
                    kschl  = <lfs_modify>-kschl
                    vkorg  = <lfs_modify>-vkorg
                    kunwe =  <lfs_modify>-kunwe
                  BINARY SEARCH.

      IF sy-subrc EQ 0.
        lv_error = c_true.
        lwa_report-msgtyp = c_error.
        lwa_report-msgtxt = 'Condition record already exists in b904 table'(035).
        lwa_report-key = lv_key.
        APPEND lwa_report TO fp_i_report.

*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
        PERFORM f_error_file_application_make USING <lfs_modify>
                                                    lwa_report
                                           CHANGING fp_i_error.
        CLEAR lwa_report.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF <lfs_modify>-auart IS INITIAL

*Validating condition record in table b907

    READ TABLE i_b907 TRANSPORTING NO FIELDS
         WITH KEY kappl  = c_v
                  kschl  = <lfs_modify>-kschl
                  vkorg  = <lfs_modify>-vkorg
                  auart  = <lfs_modify>-auart
                BINARY SEARCH.

    IF sy-subrc EQ 0.
      lv_error = c_true.
      lwa_report-msgtyp = c_error.
      lwa_report-msgtxt = 'Condition record already exists in b907 table'(055).
      lwa_report-key = lv_key.
      APPEND lwa_report TO fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
      PERFORM f_error_file_application_make USING <lfs_modify>
                                                  lwa_report
                                         CHANGING fp_i_error.
      CLEAR lwa_report.
    ENDIF. " IF sy-subrc EQ 0

*Validating condition record in table b908

    READ TABLE i_b908 TRANSPORTING NO FIELDS
         WITH KEY kappl  =   c_v
                  kschl  =  <lfs_modify>-kschl
                  vkorg  =  <lfs_modify>-vkorg
                  auart  =  <lfs_modify>-auart
                  zzbsark = <lfs_modify>-zzbsark
                BINARY SEARCH.

    IF sy-subrc EQ 0.
      lv_error = c_true.
      lwa_report-msgtyp = c_error.
      lwa_report-msgtxt = 'Condition record already exists in b908 table'(054).
      lwa_report-key = lv_key.
      APPEND lwa_report TO fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
      PERFORM f_error_file_application_make USING <lfs_modify>
                                                  lwa_report
                                         CHANGING fp_i_error.
      CLEAR lwa_report.
    ENDIF. " IF sy-subrc EQ 0


*Validating condition record in table b909
* Begin of D2 changes: Defect # 1007 by PGOLLA
* Added customer number for 909 validation
    READ TABLE i_b909 TRANSPORTING NO FIELDS
         WITH KEY kappl  =   c_v
                  kschl  =  <lfs_modify>-kschl
                  vkorg  =  <lfs_modify>-vkorg
                  zzbsark = <lfs_modify>-zzbsark
                  kunnr   = <lfs_modify>-kunnr
                 BINARY SEARCH.
* End of D2 changes: Defect # 1007 by PGOLLA

    IF sy-subrc EQ 0.
      lv_error = c_true.
      lwa_report-msgtyp = c_error.
      lwa_report-msgtxt = 'Condition record already exists in b909 table'(053).
      lwa_report-key = lv_key.
      APPEND lwa_report TO fp_i_report.
*   Populating the Error Record table for Application server download
*   in case Application Server option is chosen
      PERFORM f_error_file_application_make USING <lfs_modify>
                                                  lwa_report
                                         CHANGING fp_i_error.
      CLEAR lwa_report.
    ENDIF. " IF sy-subrc EQ 0

*IF error flag IS NOT 'X' THEN the record IS NOT IN error
*so populating FINAL INTERNAL TABLE
    IF lv_error NE c_true.
      lwa_report-msgtyp = c_success.
      lwa_report-msgtxt = 'Record verified'(030).
      lwa_report-key = lv_key.
      APPEND lwa_report TO fp_i_report.
      CLEAR lwa_report.
*      Populating final table
      CLEAR lwa_final.
      lwa_final = <lfs_modify>.
      APPEND lwa_final TO fp_i_final.
      CLEAR lwa_final.
    ELSE. " ELSE -> IF lv_error NE c_true
*      Increasing error count
      gv_ecount = gv_ecount + 1.
      gv_err_flg = c_true. "Putting Error Flag ON
    ENDIF. " IF lv_error NE c_true

  ENDLOOP. " LOOP AT fp_i_modify ASSIGNING <lfs_modify>

ENDFORM. " F_VAL
*&---------------------------------------------------------------------*
*&      Form  F_ERROR_FILE_APPLICATION_MAKE
*&---------------------------------------------------------------------*
*       Populating the Error Record table for Application server
*       download in case Application Server option is chosen
*----------------------------------------------------------------------*
*      -->FP_LFS_Modify  Input record
*      -->FP_lwa_report  Error details
*      <--FP_I_ERROR    Error file to download
*----------------------------------------------------------------------*
FORM f_error_file_application_make  USING    fp_lfs_modify  TYPE ty_modify
                                             fp_lwa_report  TYPE ty_report
                                    CHANGING fp_i_error     TYPE ty_t_error.

* Local Data
  DATA: lwa_error TYPE ty_modify_e. "work area for error file
* Forming the record.

  lwa_error-keycombi   = fp_lfs_modify-keycombi.
  lwa_error-kschl      = fp_lfs_modify-kschl.
  lwa_error-vkorg      = fp_lfs_modify-vkorg.
  lwa_error-vtweg      = fp_lfs_modify-vtweg.
  lwa_error-auart      = fp_lfs_modify-auart.
  lwa_error-kunnr      = fp_lfs_modify-kunnr.
  lwa_error-kunwe      = fp_lfs_modify-kunwe.
  lwa_error-parvw      = fp_lfs_modify-parvw.
  lwa_error-nacha      = fp_lfs_modify-nacha.
  lwa_error-vsztp      = fp_lfs_modify-vsztp.
  lwa_error-tcode      = fp_lfs_modify-tcode.
  lwa_error-ldest      = fp_lfs_modify-ldest.
  lwa_error-tdarmod    = fp_lfs_modify-tdarmod.
  lwa_error-tdschedule = fp_lfs_modify-tdschedule.
  lwa_error-dimme      = fp_lfs_modify-dimme.
  lwa_error-zzbsark    = fp_lfs_modify-zzbsark.
  lwa_error-parnr      = fp_lfs_modify-parnr.
  lwa_error-errormsg   = fp_lwa_report-msgtxt.

  APPEND lwa_error TO fp_i_error.

ENDFORM. " F_ERROR_FILE_APPLICATION_MAKE
