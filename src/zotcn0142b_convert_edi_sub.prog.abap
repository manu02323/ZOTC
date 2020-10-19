*&---------------------------------------------------------------------*
*&  Include           ZOTCN0142B_CONVERT_EDI_SUB
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0142B_CONVERT_EDI_SUB                             *
* TITLE      :  Order to Cash D3_OTC_CDD_0142_Convert EDI Ext Partner  *
*               to Internal Partner (EDPAR)                            *
* DEVELOPER  :  Nasrin Ali                                             *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_CDD_0142                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Convert EDI Ext Partner                                *
*               to Internal Partner (EDPAR)                            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 18-MAY-2016 NALI     E1DK918180 INITIAL DEVELOPMENT                  *
* =========== ======== ========== =====================================*
* 20-Oct-2016 MTHATHA  E1DK918180 Defect#5278 change validation error  *
* =========== ======== ========== =====================================*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*         Screen Modification based on user selection
*----------------------------------------------------------------------*
FORM f_modify_screen .
  LOOP AT SCREEN .
*   Presentation Server Option is NOT chosen
    IF rb_pres NE c_true.
*     Hiding Presentation Server file paths with modifidd MI3.
      IF screen-group1 = c_groupmi3.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
*   Presentation Server Option IS chosen
    ELSE. " ELSE -> IF rb_pres NE c_true
*     Disaplying Presentation Server file paths with modifidd MI3.
      IF screen-group1 = c_groupmi3.
        screen-active = c_one.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
    ENDIF. " IF rb_pres NE c_true
*   Application Server Option is NOT chosen
    IF rb_app NE c_true.
*     Hiding 1) Application Server file Physical paths with modifid MI2
*     2) Logical Filename Radio Button with with modifid MI5
*     3) Logical Filename input with modifid MI7
      IF screen-group1 = c_groupmi2
         OR screen-group1 = c_groupmi5
         OR screen-group1 = c_groupmi7.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi2
*   Application Server Option IS chosen
    ELSE. " ELSE -> IF rb_app NE c_true
*     If Application Server Physical File Radio Button is chosen
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
*&      Form  F_CHECK_EXTENSION
*&---------------------------------------------------------------------*
*      Check the file extension whether it is .TXT or not
*----------------------------------------------------------------------*
*      -->fP_P_PFILE      file name
*----------------------------------------------------------------------*
FORM f_check_extension  USING    fp_p_file TYPE localfile. " Local file for upload/download
  CLEAR gv_extn.
*   Getting the file extension
  PERFORM f_file_extn_check USING fp_p_file
                         CHANGING gv_extn.
  IF gv_extn <> c_text.
    MESSAGE e182. "Please provide file in .TXT format
  ENDIF. " IF gv_extn <> c_text
ENDFORM. " F_CHECK_EXTENSION
*&---------------------------------------------------------------------*
*&      Form  F_GET_CONSTANTS
*&---------------------------------------------------------------------*
*       Get constants from EMI table
*----------------------------------------------------------------------*
FORM f_get_constants .
*data declaration
  DATA: li_constants TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0. " Enhancement Status
*field symbol dclaration
  FIELD-SYMBOLS: <lfs_constant> TYPE zdev_enh_status. " Enhancement Status
*constant declaration
  CONSTANTS:
             lc_codepage      TYPE z_criteria    VALUE 'CODEPAGE',        " Enh. Criteria
             lc_enh_name      TYPE z_enhancement VALUE 'D3_OTC_CDD_0142'. "Enhancement No.
  REFRESH li_constants.
*get the constants
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_name
    TABLES
      tt_enh_status     = li_constants.
*If EMI table is not initial
  IF li_constants[] IS NOT INITIAL.
    SORT li_constants BY criteria active.
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
ENDFORM. " F_GET_CONSTANTS
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_INPUT
*&---------------------------------------------------------------------*
*      Check if file name is provided or not
*----------------------------------------------------------------------*
FORM f_check_input .

* If No presentation Server file name is entered and Presentation
* Server Optin has been chosen, then issueing error message.
  IF rb_pres IS NOT INITIAL AND
     p_pfile IS INITIAL.
    MESSAGE i080. "File from Presentation Server is not valid
    LEAVE LIST-PROCESSING.
  ENDIF. " IF rb_pres IS NOT INITIAL AND

* For Application Server
  IF rb_app IS NOT INITIAL.
*   If No Application Server file name is entered and Application
*   Server Optin has been chosen, then issueing error message.
    IF rb_aphy IS NOT INITIAL AND
       p_afile IS INITIAL.
      MESSAGE i081. "File from Application Server is not valid
      LEAVE LIST-PROCESSING.
    ENDIF. " IF rb_aphy IS NOT INITIAL AND

* If No Logical File Path is entered and Logical File Path Option
* has been chosen, then issueing error message.
    IF rb_alog IS NOT INITIAL AND
       p_alog IS INITIAL.
      MESSAGE i082. "Logical File Path is not valid
      LEAVE LIST-PROCESSING.
    ENDIF. " IF rb_alog IS NOT INITIAL AND
  ENDIF. " IF rb_app IS NOT INITIAL
ENDFORM. " F_CHECK_INPUT
*&---------------------------------------------------------------------*
*&      Form  F_SET_MODE
*&---------------------------------------------------------------------*
*        Set the execution mode
*----------------------------------------------------------------------*
*      <--fP_GV_SAVE   flag
*      <--fP_GV_MODE   mode
*----------------------------------------------------------------------*
FORM f_set_mode  CHANGING fp_gv_save TYPE char1   " Set_mode changing fp_gv of type CHAR1
                          fp_gv_mode TYPE char10. " Gv_mode of type CHAR10

* If Verify and Post is selected, then putting the Flag ON
  IF rb_post IS NOT INITIAL.
    fp_gv_save = c_true.
    fp_gv_mode = 'Post Mode'(005). "Post Mode
  ELSE. " ELSE -> IF rb_post IS NOT INITIAL
    fp_gv_save = space.
    fp_gv_mode = 'Test Mode'(006). "Test Mode
  ENDIF. " IF rb_post IS NOT INITIAL

ENDFORM. " F_SET_MODE
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_PRES
*&---------------------------------------------------------------------*
*    Upload application server file data
*----------------------------------------------------------------------*
*      -->fP_p_FILE  presentation server file name
*----------------------------------------------------------------------*
FORM f_upload_pres  USING    fp_p_file  TYPE localfile. " Local file for upload/download

* Local Data Declaration
  DATA: lv_filename TYPE string,        "File Name
        lv_filetype TYPE char10,        "File Name
        lv_codepage TYPE abap_encoding. "code page
  REFRESH i_final.
  IF sy-batch = abap_true.
    MESSAGE i083. "Presentation Server Can not be selected in Background mode.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-batch = abap_true

  lv_filename = fp_p_file.
  lv_filetype = c_file_type.
  IF gv_codepage IS NOT INITIAL.
    lv_codepage = gv_codepage.
  ELSE. " ELSE -> IF gv_codepage IS NOT INITIAL
    lv_codepage = space.
  ENDIF. " IF gv_codepage IS NOT INITIAL


* Uploading the file from Presentation Server
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_filename
      filetype                = lv_filetype
      has_field_separator     = c_tab
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
    MESSAGE i084 WITH lv_filename. "File could not be read from &
    LEAVE LIST-PROCESSING.
  ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL
* Deleting the First Index Line from the table
    DELETE i_final INDEX 1.
  ENDIF. " IF sy-subrc IS NOT INITIAL

ENDFORM. " F_UPLOAD_PRES

*&---------------------------------------------------------------------*
*&      Form  F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*     get the physical file path from logical path
*----------------------------------------------------------------------*
*      -->FP_P_ALOG    file path
*      <--FP_GV_FILE   file name
*----------------------------------------------------------------------*
FORM f_logical_to_physical  USING    fp_p_alog TYPE pathintern  " Logical path name
                            CHANGING fp_gv_file TYPE localfile. " Local file for upload/download

* Local Data Declaration
  DATA: li_input   TYPE zdev_t_file_list_in,    "Local Input table
        lwa_input  TYPE zdev_file_list_in,      "Local work area
        li_output  TYPE zdev_t_file_list_out,   "Local Output Table
        lwa_output TYPE zdev_file_list_out,     "Local work area
        li_error   TYPE zdev_t_file_list_error. "Local error table

  REFRESH: li_input.
* Passing the logical file path to get the physical file path
  lwa_input-path = fp_p_alog.
  APPEND lwa_input TO li_input.
  CLEAR lwa_input.

* Retriving all files within the directory
  CALL FUNCTION 'ZDEV_DIRECTORY_FILE_LIST'
    EXPORTING
      im_identifier      = abap_true
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
    MESSAGE i000 WITH 'No proper file exist for the logical file.'(085).
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc <> 0
  IF sy-subrc IS INITIAL AND
     li_error IS INITIAL.
*   Getting the file path
    READ TABLE li_output INTO lwa_output INDEX 1.
    IF sy-subrc IS INITIAL.
      CONCATENATE lwa_output-physical_path
             lwa_output-filename
             INTO fp_gv_file.
    ENDIF. " IF sy-subrc IS INITIAL
    REFRESH li_output.
  ENDIF. " IF sy-subrc IS INITIAL AND
  REFRESH li_error.

ENDFORM. " F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_APPS
*&---------------------------------------------------------------------*
*     download data from application server
*----------------------------------------------------------------------*
*      -->FP_P_FILE  file name
*      <--FP_I_KUNNR  Customer table
*----------------------------------------------------------------------*
FORM f_upload_apps  USING    fp_p_file TYPE localfile    " Local file for upload/download
                    CHANGING fp_i_kunnr TYPE ty_t_kunnr. " Internal table for all KUNNR
* Local Variables
  DATA: lv_input_line TYPE string,  "Input Raw lines
        lv_message    TYPE string,
        lv_subrc      TYPE sysubrc. "SY-SUBRC value

* Local Workarea
  DATA: lwa_final TYPE ty_final,
        lwa_kunnr TYPE ty_kunnr.

  CLEAR lwa_kunnr.
  REFRESH fp_i_kunnr.
* Opening the Dataset for File Read
  CALL METHOD zdev_cl_abap_file_utilities=>meth_stat_pub_open_dataset
    EXPORTING
      im_file     = fp_p_file
      im_codepage = gv_codepage
    IMPORTING
      ex_subrc    = lv_subrc
      ex_message  = lv_message.

  IF lv_message IS NOT INITIAL.
    MESSAGE i000 WITH lv_message.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF lv_message IS NOT INITIAL

*  IF sy-subrc IS INITIAL.
  IF  lv_message IS INITIAL.
*   Reading the Header Input File
    WHILE ( lv_subrc EQ 0 ).
      READ DATASET fp_p_file INTO lv_input_line.
*     Sotring the SY-SUBRC value. To be used as loop-breaking condn.
      lv_subrc = sy-subrc.
      IF lv_subrc IS INITIAL AND sy-index > 1.
        SPLIT lv_input_line AT c_tab
        INTO
              lwa_final-kunnr
              lwa_final-parvw
              lwa_final-expnr
              lwa_final-inpnr.

** Convert KUNNR to internal format
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lwa_final-kunnr
          IMPORTING
            output = lwa_final-kunnr.
** Populate KUNNR table
        lwa_kunnr-kunnr = lwa_final-kunnr.
        APPEND lwa_kunnr TO fp_i_kunnr.
        CLEAR lwa_kunnr.

** Convert INPNR to internal format
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lwa_final-inpnr
          IMPORTING
            output = lwa_final-inpnr.
** Populate KUNNR table
        lwa_kunnr-kunnr = lwa_final-inpnr.
        APPEND lwa_kunnr TO fp_i_kunnr.
        CLEAR lwa_kunnr.
** Convert PARVW to internal format
        CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
          EXPORTING
            input  = lwa_final-parvw
          IMPORTING
            output = lwa_final-parvw.

        APPEND lwa_final TO i_final.
        CLEAR: lwa_final.
        CLEAR lv_input_line.

      ENDIF. " IF lv_subrc IS INITIAL AND sy-index > 1
    ENDWHILE.
*    DELETE i_final INDEX 1.
* If File Open fails, then populating the Error Log
  ELSE. " ELSE -> IF lv_message IS INITIAL
*   Leaving the program if OPEN Dataset fails for data upload
    MESSAGE i163 WITH fp_p_file. "System is not able to read the file &.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF lv_message IS INITIAL
* Closing the Dataset.
  TRY.
      CLOSE DATASET fp_p_file.

    CATCH cx_sy_file_close.
      MESSAGE i021 WITH fp_p_file. "Field Modified & & & &
      LEAVE LIST-PROCESSING.
  ENDTRY.
  IF  fp_i_kunnr IS NOT INITIAL.
    SORT fp_i_kunnr BY kunnr.
    DELETE ADJACENT DUPLICATES FROM fp_i_kunnr COMPARING kunnr.
  ENDIF. " IF fp_i_kunnr IS NOT INITIAL
  CLEAR:lv_input_line,
        lv_message,
        lv_subrc.

ENDFORM. " F_UPLOAD_APPS
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION
*&---------------------------------------------------------------------*
*       Validate all the input fields from file
*----------------------------------------------------------------------*
*      -->FP_I_KUNNR[]  Customer records
*      <--FP_I_FINAL[]  Input records
*      <--FP_I_VALID[]  Input records
*      <--FP_I_ERROR[]  Error records
*      <--FP_I_Report[]  Report records
*----------------------------------------------------------------------*
FORM f_validation USING    fp_i_kunnr TYPE ty_t_kunnr
                  CHANGING fp_i_final TYPE ty_t_final
                           fp_i_valid TYPE ty_t_final
                           fp_i_error TYPE ty_t_error
                           fp_i_report TYPE ty_t_report.
** Local Structure

**  For EDPAR entry validation
  TYPES: BEGIN OF lty_edpar,
           kunnr TYPE kunnr,     " Customer Number
           parvw TYPE parvw,     " Partner Function
           expnr TYPE edi_expnr, " Internal partner number (in SAP System)
         END OF lty_edpar,

         BEGIN OF lty_parvw,
           parvw TYPE parvw,     " Partner Function
         END OF lty_parvw.

** Local Internal Table
  DATA : li_final  TYPE STANDARD TABLE OF ty_final,
         li_kunnr  TYPE STANDARD TABLE OF ty_kunnr,
         li_kunnr1 TYPE STANDARD TABLE OF ty_kunnr,
         li_parvw  TYPE STANDARD TABLE OF lty_parvw,
         li_edpar  TYPE STANDARD TABLE OF lty_edpar.
**Local variables
  DATA:  lwa_final   TYPE ty_final,
         lwa_kunnr   TYPE ty_kunnr.

**Local variables
  DATA:  lv_err_flg TYPE char1. " Err_flg of type CHAR1
**Local Field symbols
  FIELD-SYMBOLS: <lfs_final> TYPE ty_final.

  REFRESH : li_final.

  IF rb_pres IS NOT INITIAL.
    REFRESH li_kunnr1.
    CLEAR lwa_kunnr.
** Convert KUNNR and INPNR to system format
** and populate all KUNNR and INPNR values in a single internal table
    LOOP AT fp_i_final ASSIGNING <lfs_final>.

** Convert KUNNR to internal format
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <lfs_final>-kunnr
        IMPORTING
          output = <lfs_final>-kunnr.
**  Populate KUNNR table
      lwa_kunnr = <lfs_final>-kunnr.
      APPEND lwa_kunnr TO li_kunnr1.
      CLEAR lwa_kunnr.
** Convert INPNR to internal format
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <lfs_final>-inpnr
        IMPORTING
          output = <lfs_final>-inpnr.
**  Populate KUNNR table
      lwa_kunnr = <lfs_final>-inpnr.
      APPEND lwa_kunnr TO li_kunnr1.
      CLEAR lwa_kunnr.

** Convert PARVW to internal format
      CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
        EXPORTING
          input  = <lfs_final>-parvw
        IMPORTING
          output = <lfs_final>-parvw.
    ENDLOOP. " LOOP AT fp_i_final ASSIGNING <lfs_final>
    IF li_kunnr1 IS NOT INITIAL.
      SORT li_kunnr1 BY kunnr.
      DELETE ADJACENT DUPLICATES FROM li_kunnr1 COMPARING kunnr.
    ENDIF. " IF li_kunnr1 IS NOT INITIAL
  ENDIF. " IF rb_pres IS NOT INITIAL

** Get all EDPAR entries for corresponding data in file
  REFRESH li_final.
  li_final[] = fp_i_final[].
  SORT li_final BY kunnr parvw expnr.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING kunnr parvw expnr.
  IF li_final[] IS NOT INITIAL.
    REFRESH li_edpar.
    SELECT kunnr   " Customer Number
           parvw   " Partner Function
           expnr   " External partner number (in customer system)
        FROM edpar " Convert External <  > Internal Partner Number
      INTO TABLE li_edpar
      FOR ALL ENTRIES IN li_final
      WHERE kunnr = li_final-kunnr
      AND   parvw = li_final-parvw
      AND   expnr = li_final-expnr.
    IF sy-subrc = 0.
      SORT li_edpar BY kunnr parvw expnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_final[] IS NOT INITIAL

**  Get all Customers
  REFRESH li_kunnr.
  IF rb_pres IS NOT INITIAL.
    IF li_kunnr1 IS NOT INITIAL.
      SELECT kunnr " Customer Number
    FROM kna1      " General Data in Customer Master
    INTO TABLE li_kunnr
    FOR ALL ENTRIES IN li_kunnr1
    WHERE kunnr = li_kunnr1-kunnr.
      IF sy-subrc = 0.
        SORT li_kunnr BY kunnr.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF li_kunnr1 IS NOT INITIAL
  ELSE. " ELSE -> IF rb_pres IS NOT INITIAL
    IF fp_i_kunnr IS NOT INITIAL.
      SELECT kunnr " Customer Number
      FROM kna1    " General Data in Customer Master
      INTO TABLE li_kunnr
      FOR ALL ENTRIES IN fp_i_kunnr
      WHERE kunnr = fp_i_kunnr-kunnr.
      IF sy-subrc = 0.
        SORT li_kunnr BY kunnr.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF fp_i_kunnr IS NOT INITIAL

  ENDIF. " IF rb_pres IS NOT INITIAL

** Get all Partner Functions
  REFRESH li_final.
  li_final[] = fp_i_final[].
  SORT li_final BY parvw.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING parvw.
  IF li_final IS NOT INITIAL.
    REFRESH li_parvw.
    SELECT parvw " Partner Function
      FROM tpar  " Business Partner: Functions
      INTO TABLE li_parvw
      FOR ALL ENTRIES IN li_final
      WHERE parvw = li_final-parvw.
    IF sy-subrc = 0.
      SORT li_parvw BY parvw.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_final IS NOT INITIAL

**Validate Input fields
  REFRESH:  li_final.

  LOOP AT fp_i_final ASSIGNING <lfs_final>.
    CLEAR: lv_err_flg.
    IF li_final IS NOT INITIAL.

      READ TABLE li_final TRANSPORTING NO FIELDS
      WITH KEY kunnr = <lfs_final>-kunnr
               parvw = <lfs_final>-parvw
*--Begin of changes for defect#5278 by mthatha
*               inpnr = <lfs_final>-inpnr.
               expnr = <lfs_final>-EXPNR.
*--End of changes for defect#5278 by mthatha
      IF sy-subrc = 0.
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Entry already exists in the file with the same key'(012).
        APPEND wa_report TO fp_i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Entry already exists in the file with the same key'(012).
        APPEND wa_error TO fp_i_error.
        CLEAR wa_error.
        CONTINUE.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF li_final IS NOT INITIAL
    MOVE <lfs_final> TO lwa_final.
    APPEND lwa_final TO li_final.
    CLEAR lwa_final.

**validate Sold-to party Number
    IF <lfs_final>-kunnr IS INITIAL.
*      error flag
      lv_err_flg = c_true.
      PERFORM f_error_key_sub USING <lfs_final>.
      wa_report-msgtyp = c_emsg.
      wa_report-msgtxt = 'Sold-to Party Number can not be blank.'(010).
      APPEND wa_report TO fp_i_report.
      CLEAR wa_report.

      PERFORM f_pop_error_file USING <lfs_final>.
      wa_error-errmsg = 'Sold-to Party Number can not be blank.'(010).
      APPEND wa_error TO fp_i_error.
      CLEAR wa_error.
      CONTINUE.

    ELSE. " ELSE -> IF <lfs_final>-kunnr IS INITIAL
      READ TABLE li_kunnr TRANSPORTING NO FIELDS
                          WITH KEY kunnr = <lfs_final>-kunnr
                          BINARY SEARCH.
      IF sy-subrc <> 0.
** error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Invalid Sold-to Party Number'(011).
        APPEND wa_report TO fp_i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Invalid Sold-to Party Number'(011).
        APPEND wa_error TO fp_i_error.
        CLEAR wa_error.
        CONTINUE.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF <lfs_final>-kunnr IS INITIAL

**validate Internal Partner Type
    IF <lfs_final>-parvw IS INITIAL.
*      error flag
      lv_err_flg = c_true.
      PERFORM f_error_key_sub USING <lfs_final>.
      wa_report-msgtyp = c_emsg.
      wa_report-msgtxt = 'Internal Partner Type can not be blank.'(013).
      APPEND wa_report TO fp_i_report.
      CLEAR wa_report.

      PERFORM f_pop_error_file USING <lfs_final>.
      wa_error-errmsg = 'Internal Partner Type can not be blank.'(013).
      APPEND wa_error TO fp_i_error.
      CLEAR wa_error.
      CONTINUE.

    ELSE. " ELSE -> IF <lfs_final>-parvw IS INITIAL
      READ TABLE li_parvw TRANSPORTING NO FIELDS
                          WITH KEY parvw = <lfs_final>-parvw
                          BINARY SEARCH.
      IF sy-subrc <> 0.
** error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Invalid Internal Partner Type'(014).
        APPEND wa_report TO fp_i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Invalid Internal Partner Type'(014).
        APPEND wa_error TO fp_i_error.
        CLEAR wa_error.
        CONTINUE.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF <lfs_final>-parvw IS INITIAL


**validate Sold-to party Number
    IF <lfs_final>-inpnr IS INITIAL.
*      error flag
      lv_err_flg = c_true.
      PERFORM f_error_key_sub USING <lfs_final>.
      wa_report-msgtyp = c_emsg.
      wa_report-msgtxt = 'Ship-to Party Number can not be blank.'(015).
      APPEND wa_report TO fp_i_report.
      CLEAR wa_report.

      PERFORM f_pop_error_file USING <lfs_final>.
      wa_error-errmsg = 'Ship-to Party Number can not be blank.'(015).
      APPEND wa_error TO fp_i_error.
      CLEAR wa_error.
      CONTINUE.

    ELSE. " ELSE -> IF <lfs_final>-inpnr IS INITIAL
      READ TABLE li_kunnr TRANSPORTING NO FIELDS
                          WITH KEY kunnr = <lfs_final>-inpnr
                          BINARY SEARCH.
      IF sy-subrc <> 0.
** error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Invalid Ship-to Party Number'(016).
        APPEND wa_report TO fp_i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Invalid Ship-to Party Number'(016).
        APPEND wa_error TO fp_i_error.
        CLEAR wa_error.
        CONTINUE.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF <lfs_final>-inpnr IS INITIAL

**validate required entry for Legacy Cutomer Number (External)
    IF <lfs_final>-expnr IS INITIAL.
*      error flag
      lv_err_flg = c_true.
      PERFORM f_error_key_sub USING <lfs_final>.
      wa_report-msgtyp = c_emsg.
      wa_report-msgtxt = 'Legacy Cutomer Number (External) can not be blank.'(017).
      APPEND wa_report TO fp_i_report.
      CLEAR wa_report.

      PERFORM f_pop_error_file USING <lfs_final>.
      wa_error-errmsg = 'Legacy Cutomer Number (External) can not be blank.'(017).
      APPEND wa_error TO fp_i_error.
      CLEAR wa_error.
      CONTINUE.
    ENDIF. " IF <lfs_final>-expnr IS INITIAL

** Validate if the entry already exists in EDPAR
    IF <lfs_final>-kunnr IS NOT INITIAL OR <lfs_final>-parvw IS NOT INITIAL
      OR <lfs_final>-expnr IS NOT INITIAL.
      READ TABLE li_edpar TRANSPORTING NO FIELDS
                          WITH KEY kunnr = <lfs_final>-kunnr
                                   parvw = <lfs_final>-parvw
                                   expnr = <lfs_final>-expnr
                          BINARY SEARCH.
      IF sy-subrc = 0.
** error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Entry already exists in table with the same key.'(018).
        APPEND wa_report TO fp_i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Entry already exists in table with the same key.'(018).
        APPEND wa_error TO fp_i_error.
        CLEAR wa_error.
        CONTINUE.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF <lfs_final>-kunnr IS NOT INITIAL OR <lfs_final>-parvw IS NOT INITIAL
    IF lv_err_flg IS INITIAL.
**populate data for processing
      APPEND <lfs_final> TO fp_i_valid.
    ENDIF. " IF lv_err_flg IS INITIAL
  ENDLOOP. " LOOP AT fp_i_final ASSIGNING <lfs_final>
  REFRESH li_final.
**Successful records
  gv_scount = lines( fp_i_valid ).
**Error records
  gv_ecount = lines( fp_i_report ).

  FREE:  li_final,
         li_kunnr,
         li_parvw,
         li_edpar.

  CLEAR lv_err_flg.

ENDFORM. " F_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_VOE4_BDC
*&---------------------------------------------------------------------*
*       Process BDC data
*----------------------------------------------------------------------*
*      -->FP_I_FINAL[]  valid records
*      <--FP_I_ERROR[]  Error records
*----------------------------------------------------------------------*
FORM f_voe4_bdc  USING    fp_i_final TYPE ty_t_final
                 CHANGING fp_i_error TYPE ty_t_error.
**  Local Data Declarations
  DATA :    lv_mode      TYPE char1,                        " Mode of type CHAR1
            lv_update    TYPE char1,                        " Update of type CHAR1
            lv_msg       TYPE char255,                      " Msg(255) of type Character
            li_bdcmsg    TYPE STANDARD TABLE OF bdcmsgcoll, " Collecting messages in the SAP System
            lwa_bdcmsg   TYPE bdcmsgcoll,                   " Collecting messages in the SAP System
            lv_error_lines TYPE sytabix.                    " Error_lines of type Integers

**  Local Constants
  CONSTANTS: lc_keep TYPE apq_qdel VALUE 'X',  " Queue deletion indicator for processed sessions
             lc_mode     TYPE char1 VALUE 'N', " Mode of type CHAR1
             lc_update   TYPE char1 VALUE 'A'. " Update of type CHAR1

**  Local Field-symbols
  FIELD-SYMBOLS: <lfs_final> TYPE ty_final.

  IF fp_i_final[] IS NOT INITIAL.
    CALL FUNCTION 'BDC_OPEN_GROUP'
      EXPORTING
        client              = sy-mandt
        group               = c_group
        keep                = lc_keep
        user                = sy-uname
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
      MESSAGE i051 WITH c_group. "Error in BDC Session &
    ELSE. " ELSE -> IF sy-subrc <> 0
      LOOP AT fp_i_final ASSIGNING <lfs_final>.

        PERFORM f_bdc_dynpro      USING 'SAPL0VED' '0102'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'V_EDPAR-VTEXT_PAR(01)'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=NEWL'.
        PERFORM f_bdc_dynpro      USING 'SAPL0VED' '0102'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'V_EDPAR-INPNR(01)'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM f_bdc_field       USING 'V_EDPAR-KUNNR(01)'
                                      <lfs_final>-kunnr.
        PERFORM f_bdc_field       USING 'V_EDPAR-PARVW(01)'
                                      <lfs_final>-parvw.
        PERFORM f_bdc_field       USING 'V_EDPAR-EXPNR(01)'
                                      <lfs_final>-expnr.
        PERFORM f_bdc_field       USING 'V_EDPAR-INPNR(01)'
                                      <lfs_final>-inpnr.
        PERFORM f_bdc_dynpro      USING 'SAPL0VED' '0102'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'V_EDPAR-KUNNR(02)'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=SAVE'.
        PERFORM f_bdc_dynpro      USING 'SAPL0VED' '0102'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'V_EDPAR-KUNNR(02)'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=BACK'.
        PERFORM f_bdc_dynpro      USING 'SAPL0VED' '0102'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'V_EDPAR-KUNNR(02)'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=SAVE'.
        PERFORM f_bdc_dynpro      USING 'SAPL0VED' '0102'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'V_EDPAR-KUNNR(02)'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=BACK'.

        lv_mode = lc_mode.
        lv_update = lc_update.

        CALL TRANSACTION c_tcode USING i_bdcdata
                MODE   lv_mode
                UPDATE lv_update
                MESSAGES INTO li_bdcmsg.

        READ TABLE li_bdcmsg INTO lwa_bdcmsg WITH KEY msgtyp = c_error.
        IF sy-subrc = 0.
          MESSAGE ID lwa_bdcmsg-msgid
                TYPE lwa_bdcmsg-msgtyp
                NUMBER lwa_bdcmsg-msgnr
                WITH lwa_bdcmsg-msgv1
                      lwa_bdcmsg-msgv2
                      lwa_bdcmsg-msgv3
                      lwa_bdcmsg-msgv4
                 INTO lv_msg.
        ENDIF. " IF sy-subrc = 0

        IF lwa_bdcmsg-msgtyp = c_error.
***Populate unsucessful records to error file and report.
          PERFORM f_error_key_sub USING <lfs_final>.
          wa_report-msgtyp = c_error.
          wa_report-msgtxt = lv_msg.
          APPEND wa_report TO i_report.
          CLEAR wa_report.

          PERFORM f_pop_error_file USING <lfs_final>.
          wa_error-errmsg = lv_msg.
          APPEND wa_error TO fp_i_error.
          CLEAR wa_error.
          lv_error_lines = lv_error_lines + 1.

*create BDC session for error records
*Insert a transaction in BDC session
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
***Populate unsucessful records to error file and report.
            PERFORM f_error_key_sub USING <lfs_final>.
            wa_report-msgtyp = c_emsg.
            wa_report-msgtxt = 'BDC INSERT failed'(088).
            APPEND wa_report TO i_report.
            CLEAR wa_report.
          ENDIF. " IF sy-subrc <> 0
        ENDIF. " IF lwa_bdcmsg-msgtyp = c_error

        CLEAR: lwa_bdcmsg,
               lv_msg.

        REFRESH: i_bdcdata,
                 li_bdcmsg.
      ENDLOOP. " LOOP AT fp_i_final ASSIGNING <lfs_final>

      CALL FUNCTION 'BDC_CLOSE_GROUP'
        EXCEPTIONS
          not_open    = 1
          queue_error = 2
          OTHERS      = 3.
      IF sy-subrc <> 0.
        CLEAR wa_report.
        MESSAGE i051 WITH c_group  INTO wa_report-msgtxt. " Error in BDC Session &
        wa_report-msgtyp = c_error.
        APPEND wa_report TO i_report.
      ELSE. " ELSE -> IF sy-subrc <> 0
        gv_session_gl_1 = c_group.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF fp_i_final[] IS NOT INITIAL

  gv_scount = gv_scount - lv_error_lines.
  gv_ecount = gv_ecount + lv_error_lines.

  CLEAR:      lv_mode,
              lv_update,
              lv_msg,
              lwa_bdcmsg,
              lv_error_lines.

ENDFORM. " F_VOE4_BDC
*&---------------------------------------------------------------------*
*&      Form  F_ERROR_KEY_SUB
*&---------------------------------------------------------------------*
*   Populate error Key for report display
*----------------------------------------------------------------------*
*      -->FP_ERR_KEY    Error record
*----------------------------------------------------------------------*
FORM f_error_key_sub  USING    fp_err_key TYPE ty_final.

**Populate error Key based on Key combination
  CONCATENATE fp_err_key-kunnr
              fp_err_key-parvw
              fp_err_key-expnr
              fp_err_key-inpnr
  INTO wa_report-key SEPARATED BY c_fslash.
ENDFORM. " F_ERROR_KEY_SUB
*&---------------------------------------------------------------------*
*&      Form  F_POP_ERROR_FILE
*&---------------------------------------------------------------------*
*      populate error record to file
*----------------------------------------------------------------------*
*      -->FP_ERR_DATA  error data record
*----------------------------------------------------------------------*
FORM f_pop_error_file  USING    fp_err_data TYPE ty_final.
  wa_error-kunnr = fp_err_data-kunnr.
  wa_error-parvw = fp_err_data-parvw.
  wa_error-expnr = fp_err_data-expnr.
  wa_error-inpnr = fp_err_data-inpnr.
ENDFORM. " F_POP_ERROR_FILE
*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*      BDC screen
*----------------------------------------------------------------------*
*      -->fp_v_program     BDC program
*      -->fp_v_dynpro      BDC screen
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
ENDFORM. " BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  F_BDC_FIELD
*&---------------------------------------------------------------------*
*       BDC field population
*----------------------------------------------------------------------*
*      -->fp_v_fnam   field name
*      -->fp_v_fval    field value
*----------------------------------------------------------------------*
FORM f_bdc_field  USING fp_v_fnam    TYPE any
                        fp_v_fval    TYPE any.
  DATA: lwa_bdcdata TYPE bdcdata. " Batch input: New table field structure
  lwa_bdcdata-fnam = fp_v_fnam.
  lwa_bdcdata-fval = fp_v_fval.
  APPEND lwa_bdcdata TO i_bdcdata.
  CLEAR lwa_bdcdata.
ENDFORM. " F_BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  F_MOVE
*&---------------------------------------------------------------------*
*     Move file to the Done folder
*----------------------------------------------------------------------*
*      -->fp_sourcefile     file path
*----------------------------------------------------------------------*
FORM f_move  USING    fp_sourcefile TYPE localfile. " Local file for upload/download

  DATA: lv_file TYPE localfile,   " Local file for upload/download
                                  " local variable declaration of type localfile
          lv_name TYPE localfile. " Local file for upload/download
 " local variable declaration of type localfile.

  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_sourcefile
    IMPORTING
      pathname = lv_file
      filename = lv_name.

* First move the file to the Done folder
  REPLACE c_tbp_fld  IN lv_file WITH c_done_fld .
  CONCATENATE lv_file lv_name INTO lv_file.
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
*   Populate error records to ERROR folder
*----------------------------------------------------------------------*
*      -->FP_P_AFILE     file name
*      -->FP_I_ERROR[]    error records
*----------------------------------------------------------------------*
FORM f_write_error_file  USING    fp_p_afile TYPE localfile " Local file for upload/download
                                  fp_i_error TYPE ty_t_error.

* Local Data
  DATA: lv_file     TYPE localfile, "File Name
        lv_name     TYPE localfile, "File Name
        lv_data     TYPE string.    "Output data string

  FIELD-SYMBOLS : <lfs_error> TYPE ty_error.
* Spitting Filae Path & File Name
  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_p_afile
    IMPORTING
      pathname = lv_file
      filename = lv_name.

* Changing the file path to ERROR folder
  REPLACE c_tbp_fld  IN lv_file WITH c_error_fld .
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
*&      Form  F_HEADER_LINE_POP
*&---------------------------------------------------------------------*
*    Populate Header text line
*----------------------------------------------------------------------*
*  -->  fp_data    header line
*----------------------------------------------------------------------*
FORM f_header_line_pop CHANGING fp_data TYPE string.

***Populate header based on Key combination
  CONCATENATE 'Sold-to Party Number'(089)
              'Internal Partner type'(090)
              'Legacy Customer Number (External)'(091)
              'Ship-to Party Number'(092)
              'Error message'(093)
        INTO fp_data
        SEPARATED BY c_tab.


ENDFORM. " F_HEADER_LINE_POP
*&---------------------------------------------------------------------*
*&      Form  F_ERR_DATA_POP
*&---------------------------------------------------------------------*
*     Populate the error record
*----------------------------------------------------------------------*
*      -->FP_P_ERROR  Error record
*      <--FP_DATA     error data string
*----------------------------------------------------------------------*
FORM f_err_data_pop  USING    fp_p_error TYPE ty_error
                     CHANGING fp_data TYPE string.

*** Pass the error data to application server
** based on Key combination
  CONCATENATE  fp_p_error-kunnr
               fp_p_error-parvw
               fp_p_error-expnr
               fp_p_error-inpnr
               fp_p_error-errmsg
               INTO fp_data
          SEPARATED BY c_tab.

ENDFORM. " F_ERR_DATA_POP
