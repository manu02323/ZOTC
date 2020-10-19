*&---------------------------------------------------------------------*
*&  Include           ZOTCN0398B_DET_BATCHES_SUB
*&---------------------------------------------------------------------*
*&**********************************************************************
* PROGRAM    :  ZOTCN0398B_DET_BATCHES_SUB                             *
* TITLE      :  Batch Determination at Sales Order                     *
* DEVELOPER  :  Avik Poddar                                            *
* OBJECT TYPE:  Enhancement Program                                    *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0398                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Batch determination program will be used as a tool for *
*               automatic batch assignment to sales order lines,       *
*               specifically red-blood cells materials in background   *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER        TRANSPORT         DESCRIPTION                *
* 11-OCT-2018  APODDAR   E1DK938946      Initial Development           *
* =========== ======== ========== =====================================*
*&---------------------------------------------------------------------*
*&      Form  F_READ_DATASET
*&---------------------------------------------------------------------*
*    Reading data from the file
*----------------------------------------------------------------------*
*      -->FP_P_APSFIL  File Path
*      <--FP_I_APFIL   Internal Tabble
*----------------------------------------------------------------------*
FORM f_read_dataset  USING    fp_p_apsfil TYPE localfile   " Local file for upload/download
                     CHANGING fp_i_apfil  TYPE ty_t_input. "Internal table

  DATA : lv_file     TYPE string, " DataSet
         lv_done     TYPE char1,  " Done of type CHAR1
         lwa_output   TYPE ty_input.

  CONSTANTS : lc_pipe TYPE char1 VALUE '|'. " Pipe

*Open Dataset to Read File
  TRY.
      OPEN DATASET fp_p_apsfil
      FOR INPUT IN TEXT MODE ENCODING DEFAULT. " Set as Ready for Input
    CATCH cx_sy_file_open.
      MESSAGE i021 WITH fp_p_apsfil.
      LEAVE LIST-PROCESSING.
    CATCH cx_sy_codepage_converter_init.
      MESSAGE i021 WITH fp_p_apsfil.
      LEAVE LIST-PROCESSING.
    CATCH cx_sy_file_authority.
      MESSAGE i021 WITH fp_p_apsfil.
      LEAVE LIST-PROCESSING.
    CATCH cx_sy_pipes_not_supported.
      MESSAGE i021 WITH fp_p_apsfil.
      LEAVE LIST-PROCESSING.
    CATCH cx_sy_too_many_files.
      MESSAGE i021 WITH fp_p_apsfil.
      LEAVE LIST-PROCESSING.
  ENDTRY.

*Take Data from Application Server to Internal Table
  IF sy-subrc IS INITIAL.

    WHILE lv_done IS INITIAL.
      READ DATASET fp_p_apsfil INTO lv_file.
      IF sy-subrc IS INITIAL.
        SPLIT lv_file AT lc_pipe INTO
                      lwa_output-vbeln
                      lwa_output-posnr
                      lwa_output-matnr
                      lwa_output-kwmeng
                      lwa_output-omeng
                      lwa_output-bmeng
                      lwa_output-kunnr
                      lwa_output-name1
                      lwa_output-vkorg
                      lwa_output-vtweg
                      lwa_output-werks
                      lwa_output-edatu
                      lwa_output-charg
                      lwa_output-lifsk
                      lwa_output-vtext
                      lwa_output-antigens
                      lwa_output-corres.

        APPEND lwa_output TO fp_i_apfil.
      ELSE. " ELSE -> IF sy-subrc IS INITIAL
        lv_done = abap_true.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDWHILE.

    IF fp_i_apfil IS NOT INITIAL.
      DELETE fp_i_apfil INDEX 1.
    ENDIF. " IF fp_i_apfil IS NOT INITIAL
*Close Dataset
    TRY.
        CLOSE DATASET fp_p_apsfil.
      CATCH cx_sy_file_close.
        MESSAGE i021 WITH fp_p_apsfil.
        LEAVE LIST-PROCESSING.
    ENDTRY.
  ELSE. " ELSE -> IF sy-subrc IS INITIAL
    MESSAGE i021 WITH fp_p_apsfil.
    LEAVE LIST-PROCESSING.

  ENDIF. " IF sy-subrc IS INITIAL


ENDFORM. " F_READ_DATASET
*&---------------------------------------------------------------------*
*&      Form  F_LOCK_UPDATE_SO
*&---------------------------------------------------------------------*
*    Sales order update
*----------------------------------------------------------------------*
*      -->P_I_FINAL_OUTPUT[]  final output table
*      <--P_I_LOG_CHAR[]      log table
*----------------------------------------------------------------------*
FORM f_lock_update_so  CHANGING    fp_i_final_output TYPE ty_t_input     "Final input table
                                   fp_i_log_char     TYPE ty_t_log_char. "Log table


  TYPES : BEGIN OF lty_vbap,
           vbeln TYPE vbeln_va, " Sales Document
           posnr TYPE posnr_va, " Sales Document Item
           matnr TYPE matnr,    " Material Number
           charg TYPE charg_d,  " Batch Number
          END OF lty_vbap.

*&--> Local data declarartions
  DATA :
        lwa_final            TYPE          ty_input,                         "Input tab;le work area
        lwa_final_tmp        TYPE          ty_input,
        lwa_log              TYPE          ty_log_char,                      "Work area for log table
        li_return            TYPE TABLE OF bapiret2,                         " Return Parameter
        lwa_return           TYPE          bapiret2,                         " Return Parameter
        lx_return_c          TYPE          bapiret2,                         " Return Parameter
        li_order_item_in     TYPE TABLE OF bapisditm,                        " Communication Fields: Sales and Distribution Document Item
        li_order_item_inx    TYPE TABLE OF  bapisditmx,                      " Communication Fields: Sales and Distribution Document Item
        lwa_order_item_in    TYPE bapisditm,                                 " Communication Fields: Sales and Distribution Document Item
        lwa_temp             TYPE bapisditm,                                 " Communication Fields: Sales and Distribution Document Item
        lwa_order_item_inx   TYPE bapisditmx,                                " Communication Fields: Sales and Distribution Document Item
        lwa_order_header_inx TYPE bapisdh1x,                                 " Checkbox List: SD Order Header
        li_vbap_chk          TYPE STANDARD TABLE OF lty_vbap INITIAL SIZE 0, "Internal table for filling VBAP
        lwa_vbap_chk         TYPE lty_vbap,                                  "Work area for VBAP
        li_vbap              TYPE STANDARD TABLE OF lty_vbap INITIAL SIZE 0, " VBAP internal table
        li_log_temp          TYPE TABLE OF ty_log_char,                      " Temporary log table
        lwa_temp_char        TYPE ty_log_char,                               " Work Area
        lwa_vbap             TYPE lty_vbap.                                  "Work Area

*&--Field Symbol declarations
  FIELD-SYMBOLS:  <lfs_return> TYPE bapiret2, " Return Parameter
                  <lfs_char>   TYPE ty_log_char.

*&--Local Constants
  CONSTANTS: lc_batch_x TYPE bapiupdate VALUE 'X', " Updated information in related user data field
             lc_success TYPE char1      VALUE 'S', " Success of type CHAR1
             lc_upd_flg TYPE updkz_d    VALUE 'U'. " Update indicator


  SORT fp_i_final_output BY vbeln posnr.

  LOOP AT fp_i_final_output INTO lwa_final_tmp.

    lwa_final = lwa_final_tmp.
* Update Sales Order from input file
    lwa_order_header_inx-updateflag = lc_upd_flg. "'Update flag for header.
    lwa_order_item_in-itm_number = lwa_final-posnr. "Item number
    lwa_order_item_in-material = lwa_final-matnr. "Material number
    lwa_order_item_in-batch = lwa_final-charg. "Batch
    APPEND lwa_order_item_in TO li_order_item_in.


    lwa_order_item_inx-itm_number = lwa_final-posnr. "Item number
    lwa_order_item_inx-updateflag = lc_upd_flg. "'Update flag for item.
    lwa_order_item_inx-batch = lc_batch_x.
    APPEND lwa_order_item_inx TO li_order_item_inx.

    AT END OF vbeln.
*&--Updating the sales order one by one
      CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
        EXPORTING
          salesdocument      = lwa_final-vbeln
          order_header_inx   = lwa_order_header_inx
          no_status_buf_init = abap_true
        TABLES
          return             = li_return
          order_item_in      = li_order_item_in
          order_item_inx     = li_order_item_inx.
      READ TABLE li_return ASSIGNING <lfs_return>
                              WITH KEY type = c_etyp. " Return assigning of type
      IF sy-subrc NE 0.


        LOOP AT li_order_item_in INTO lwa_temp.
          lwa_log-vbeln   = lwa_final-vbeln.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = lwa_temp-itm_number
            IMPORTING
              output = lwa_temp-itm_number.

          lwa_log-posnr = lwa_temp-itm_number.
          lwa_log-status  = lc_success. "Success message type
          lwa_log-message = 'Sales Order successfully saved'(001).
          APPEND lwa_log TO fp_i_log_char.
          CLEAR lwa_log.
        ENDLOOP. " LOOP AT li_order_item_in INTO lwa_temp

        CLEAR: lx_return_c.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait   = 'X'
          IMPORTING
            return = lx_return_c.

        APPEND lx_return_c TO i_log.

        CLEAR: lwa_order_header_inx,
               lx_return_c.
        REFRESH: li_return,
                 li_order_item_in,
                 li_order_item_inx.


      ELSE. " ELSE -> IF sy-subrc NE 0
        gv_scount = gv_scount - 1.
        gv_ecount = gv_ecount + 1.
        lwa_log-vbeln   = lwa_final-vbeln.
        lwa_log-posnr   = lwa_order_item_inx-itm_number.
        lwa_log-status  = c_etyp. "Error message type
        lwa_log-message = <lfs_return>-message.

        APPEND lwa_log TO fp_i_log_char.
        CLEAR lwa_log.


        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
          IMPORTING
            return = lwa_return.
        IF lwa_return IS NOT INITIAL.
          lwa_log-vbeln   = lwa_final-vbeln.
          lwa_log-posnr   = lwa_order_item_inx-itm_number.
          lwa_log-status  = c_etyp. "Error message type
          lwa_log-message = 'Changes are not saved'(022).

          APPEND lwa_log TO fp_i_log_char.
          CLEAR lwa_log.
        ENDIF. " IF lwa_return IS NOT INITIAL

        CLEAR: lwa_order_header_inx.
        REFRESH: li_return,
                 li_order_item_in,
                 li_order_item_inx.


      ENDIF. " IF sy-subrc NE 0

    ENDAT.

    lwa_vbap_chk-vbeln = lwa_final-vbeln.
    lwa_vbap_chk-posnr = lwa_final-posnr.
    lwa_vbap_chk-matnr = lwa_final-matnr.
    lwa_vbap_chk-charg = lwa_final-charg.

    APPEND lwa_vbap_chk TO li_vbap_chk.
    CLEAR : lwa_vbap_chk,
            lwa_final.
  ENDLOOP. " LOOP AT fp_i_final_output INTO lwa_final_tmp

  WAIT UP TO 4 SECONDS.

  SORT li_vbap_chk BY vbeln posnr.
  IF li_vbap_chk IS NOT INITIAL.
    SELECT vbeln " Sales Document
           posnr " Sales Document Item
           matnr " Material Number
           charg " Batch Number
      FROM vbap  " Sales Document: Item Data
      INTO TABLE li_vbap
      FOR ALL ENTRIES IN li_vbap_chk
      WHERE vbeln = li_vbap_chk-vbeln
        AND posnr = li_vbap_chk-posnr.
    IF sy-subrc = 0.
      SORT li_vbap BY vbeln posnr.
      LOOP AT  li_vbap INTO lwa_vbap.
        READ TABLE li_vbap_chk INTO lwa_vbap_chk
            WITH KEY vbeln = lwa_vbap-vbeln
                     posnr = lwa_vbap-posnr
                     BINARY SEARCH.
        IF sy-subrc = 0.
          IF lwa_vbap_chk-charg NE lwa_vbap-charg.
            lwa_log-vbeln   = lwa_vbap-vbeln.
            lwa_log-posnr   = lwa_vbap-posnr.
            lwa_log-status  = c_etyp. "E
            lwa_log-message = 'Batch Could not be refreshed for Order. Please re-run it'(002). " Sequence
            APPEND lwa_log TO li_log_temp[].
            CLEAR lwa_log.
          ENDIF. " IF lwa_vbap_chk-charg NE lwa_vbap-charg
        ENDIF. " IF sy-subrc = 0
      ENDLOOP. " LOOP AT li_vbap INTO lwa_vbap
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_vbap_chk IS NOT INITIAL


  IF li_log_temp IS NOT INITIAL.

    LOOP AT li_log_temp INTO lwa_temp_char.
      READ TABLE fp_i_log_char ASSIGNING <lfs_char> WITH KEY vbeln = lwa_temp_char-vbeln
                                                          posnr = lwa_temp_char-posnr
                                                          status = lc_success.
      IF sy-subrc IS INITIAL.
        <lfs_char>-vbeln = space.
      ENDIF. " IF sy-subrc IS INITIAL

      IF <lfs_char> IS ASSIGNED.
        UNASSIGN <lfs_char>.
      ENDIF. " IF <lfs_char> IS ASSIGNED
    ENDLOOP. " LOOP AT li_log_temp INTO lwa_temp_char

    DELETE fp_i_log_char WHERE vbeln IS INITIAL.
    APPEND LINES OF li_log_temp TO i_log_char.
  ENDIF. " IF li_log_temp IS NOT INITIAL


  IF fp_i_log_char IS NOT INITIAL.
    SORT fp_i_log_char BY vbeln posnr.
  ENDIF. " IF fp_i_log_char IS NOT INITIAL

  FREE: li_log_temp,
        li_vbap_chk.


ENDFORM. " F_LOCK_UPDATE_SO
*&---------------------------------------------------------------------*
*&      Form  F_MOVE_FILES
*&---------------------------------------------------------------------*
*   Move files from TBP to DONE folder
*----------------------------------------------------------------------*
*      -->FP_GV_FILE  Local file
*----------------------------------------------------------------------*
FORM f_move_files  USING   fp_gv_file   TYPE localfile. " Local file for upload/download


*&--Local Data
  DATA: lv_file   TYPE localfile, "File Name
        lv_name   TYPE localfile, "Path Name
        lv_return TYPE sysubrc.   "Return Code

*&--Local Constants
  CONSTANTS:  lc_tbp_fld     TYPE char5        VALUE 'TBP',  " constant declaration for TBP folder
              lc_done_fld    TYPE char5        VALUE 'DONE'. " constant declaration for DONE folder

*&--If posting is done, then moving the files to DONE folder.
* Spitting File Path & File Name
  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_gv_file
    IMPORTING
      pathname = lv_file
      filename = lv_name.

  REPLACE lc_tbp_fld IN lv_file WITH lc_done_fld.
  CONCATENATE lv_file lv_name INTO lv_file.
  IF lv_file IS NOT INITIAL.
**&--Move the file
    PERFORM f_file_move USING fp_gv_file
                              lv_file
                             CHANGING lv_return.
    IF lv_return IS INITIAL.
*   Assigning the archived file name to global variable
      gv_archive_gl_1 = lv_file.
    ENDIF. " IF lv_return IS INITIAL
  ENDIF. " IF lv_file IS NOT INITIAL

ENDFORM. " F_MOVE_FILES
*&---------------------------------------------------------------------*
*&      Form  F_FILE_MOVE
*&---------------------------------------------------------------------*
*    File move
*----------------------------------------------------------------------*
*      -->fp_v_sourcepath  Local file for upload/download
*      -->fp_v_targetpath  Local file for upload/download
*      <--fp_v_return      Return Value of ABAP Statements
*----------------------------------------------------------------------*
FORM f_file_move  USING    fp_v_sourcepath TYPE localfile " Local file for upload/download
                           fp_v_targetpath TYPE localfile " Local file for upload/download
                  CHANGING fp_v_return     TYPE sysubrc.  " Return Value of ABAP Statements

* Calling the FM to move the file from Source location to Target
* Location. Returning the SY-SUBRC value to identify whether the file
* movement was successful or not
  CALL FUNCTION 'ZDEV_FILE_MOVE'
    EXPORTING
      im_sourcepath = fp_v_sourcepath
      im_targetpath = fp_v_targetpath
    EXCEPTIONS
      error_file    = 1
      OTHERS        = 2.
* Passing the SY-SUBRC value
  IF sy-subrc NE 0.
    fp_v_return = sy-subrc.
  ELSE. " ELSE -> IF sy-subrc NE 0
    fp_v_return = 0.
  ENDIF. " IF sy-subrc NE 0


ENDFORM. " F_FILE_MOVE
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_SUMMARY
*&---------------------------------------------------------------------*
*   Display the summary table in ALV display
*----------------------------------------------------------------------*
*      -->FP_I_LOG_CHAR[]  Final Internal table
*----------------------------------------------------------------------*
FORM f_display_summary  USING    fp_i_log_char TYPE ty_t_log_char. "Final internal table

* Local Data Declaration
  DATA:  lwa_events   TYPE slis_alv_event, " ALV event workarea
         li_events    TYPE slis_t_event,   " ALV events
         lwa_layout   TYPE lvc_s_layo,     " ALV control: Layout structure
         lwa_alvly    TYPE slis_layout_alv,
         lwa_print    TYPE slis_print_alv, " Structure for Print Params
         lwa_pripar   TYPE pri_params,     " Structure for Passing Print Parameters
         lwa_arcpar   TYPE arc_params,     " ImageLink structure
         lv_val       TYPE char1.          " Val of type CHAR1

  CONSTANTS: lc_fieldname    TYPE xubname        VALUE 'RETURNTP',      " User Name in User Master Record
             lc_form         TYPE slis_formname  VALUE 'F_TOP_OF_PAGE', " Formname
             lc_a            TYPE flag           VALUE 'A',             " General Flag
             lc_vbeln        TYPE slis_fieldname VALUE 'VBELN',         " Sales order Number
             lc_posnr        TYPE slis_fieldname VALUE 'POSNR',         " Item Number
             lc_status       TYPE slis_fieldname VALUE 'STATUS',        " Status
             lc_message      TYPE slis_fieldname VALUE 'MESSAGE',       " Message
             lc_tablename    TYPE slis_tabname   VALUE 'FP_I_LOG_CHAR', " Log table name
             lc_itabname     TYPE xubname        VALUE 'I_LOG_CHAR'.    " User Name in User Master Record


  lwa_alvly-lights_fieldname  = lc_fieldname.
  lwa_alvly-colwidth_optimize = abap_true.
  lwa_alvly-lights_tabname    = lc_itabname.


*&--For background run, display in ALV list
*   Preparing Field Catalog.
  PERFORM f_fill_fieldcatlog USING: lc_vbeln   lc_tablename    'Sales Document'(003), " Sales Order
                                    lc_posnr   lc_tablename    'Item'(004),           " Item Number
                                    lc_status  lc_tablename    'Message type'(005),   " Message Status
                                    lc_message lc_tablename    'Message text'(006).   " Log message

*   Top of page subroutine
  lwa_events-name = 'TOP_OF_PAGE'.
  lwa_events-form = 'F_TOP_OF_PAGE'.
  APPEND lwa_events TO li_events.
  CLEAR lwa_events.
 "Read, determine, change spool print parameters and archive parameters
  CALL FUNCTION 'GET_PRINT_PARAMETERS'
    EXPORTING
      in_archive_parameters  = lwa_arcpar
      in_parameters          = lwa_pripar
      line_count             = 65
      line_size              = 255
      no_dialog              = abap_true
    IMPORTING
      out_archive_parameters = lwa_arcpar
      out_parameters         = lwa_pripar
      valid                  = lv_val
    EXCEPTIONS
      archive_info_not_found = 1
      invalid_print_params   = 2
      invalid_archive_params = 3.
  IF lv_val NE space
 AND sy-subrc = 0.
    lwa_pripar-prrel = space.
    lwa_pripar-primm = space.
    NEW-PAGE PRINT ON  NEW-SECTION PARAMETERS lwa_pripar ARCHIVE PARAMETERS lwa_arcpar NO DIALOG.
  ENDIF. " IF lv_val NE space
  lwa_print-no_print_listinfos = abap_true.
*   ALV List Display for Background Run
*  FM Call to display output in ALV
  lwa_layout-cwidth_opt = abap_true. " Set Column Width Optimizer
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program     = sy-repid
      i_callback_top_of_page = lc_form "F_TOP_OF_PAGE
      is_layout_lvc          = lwa_layout
      it_fieldcat_lvc        = i_alv_fieldcat
      i_save                 = lc_a    " A
    TABLES
      t_outtab               = fp_i_log_char
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.
  IF sy-subrc <> 0.
    MESSAGE e132. "Issue in ALV display
  ENDIF. " IF sy-subrc <> 0

  NEW-PAGE PRINT OFF.

  gv_spoolid = sy-spono.

ENDFORM. " F_DISPLAY_SUMMARY
*&---------------------------------------------------------------------*
*&      Form  F_FILL_FIELDCATLOG
*&---------------------------------------------------------------------*
*   Prepare the field catalog
*----------------------------------------------------------------------*
*      -->fp_fieldname   Fieldname
*      -->fp_tabname     Table name
*      -->fp_seltext     Long Field Label
*----------------------------------------------------------------------*
FORM f_fill_fieldcatlog  USING fp_fieldname  TYPE slis_fieldname " Fieldname
                               fp_tabname    TYPE slis_tabname   " Table name
                               fp_seltext    TYPE scrtext_l.     " Long Field Label
* Local Data
  DATA: lwa_fieldcat TYPE lvc_s_fcat. "lwa_fieldcat TYPE slis_fieldcat_alv.

  gv_col_pos              = gv_col_pos + 1.
  lwa_fieldcat-col_pos    = gv_col_pos.
  lwa_fieldcat-fieldname  = fp_fieldname.
  lwa_fieldcat-tabname    = fp_tabname.
  lwa_fieldcat-seltext  = fp_seltext.
  APPEND lwa_fieldcat TO i_alv_fieldcat.
  CLEAR lwa_fieldcat.

ENDFORM. " F_FILL_FIELDCATLOG
*&---------------------------------------------------------------------*
*&      Form  f_top_of_page
*&---------------------------------------------------------------------*
*  Top of page information
*----------------------------------------------------------------------*
FORM f_top_of_page ##called.
  CONSTANTS: lc_hline   TYPE char50                           " Underline
                       VALUE '--------------------------------------------------',
              lc_colon           TYPE char1        VALUE ':'. " Colon

* Run Information
  WRITE: / 'Run Information'(007).
* Horizontal Line
  WRITE: / lc_hline.
* Client
  WRITE: / 'Client'(008),
           50(1) lc_colon,
           sy-mandt.
* Run By / User Id
  WRITE: / 'Run By / User ID'(009),
           50(1) lc_colon,
           sy-uname.
* Date / Time
  WRITE: / 'Date / Time'(010),
           50(1) lc_colon,
           sy-datum,
           sy-uzeit.
ENDFORM. "f_top_of_page
*&---------------------------------------------------------------------*
*&      Form  F_GET_RECORDS
*&---------------------------------------------------------------------*
*  Get the records from the file
*----------------------------------------------------------------------*
*      -->FP_I_FINAL_OUTPUT     Output table
*      -->FP_I_LOG_CHAR         Final table
*      <--FP_I_ELOG            Error log table
*      <--FP_I_SLOG            Success log table
*----------------------------------------------------------------------*
FORM f_get_records  USING    fp_i_final_output TYPE ty_t_input    "Output table
                             fp_i_log_char     TYPE ty_t_log_char "Final table
                    CHANGING fp_i_elog         TYPE ty_t_input    "Error log table
                             fp_i_slog         TYPE ty_t_input.   "Success log table
*&--Local data declaration
  DATA: li_log_char_e TYPE ty_t_log_char,
        li_log_char_s TYPE ty_t_log_char,
        lwa_output  TYPE ty_input,
        lwa_error   TYPE ty_input,
        lwa_success TYPE ty_input,
        lwa_log   TYPE ty_log_char.

*&--Local Constants
  CONSTANTS: lc_success TYPE char1 VALUE 'S'. " Success of type CHAR1

*&--Get the error records from the file
  li_log_char_e[] = fp_i_log_char[].
  li_log_char_s[] = fp_i_log_char[].

*&--Get the error records.
  SORT li_log_char_e BY vbeln posnr.
  DELETE li_log_char_e WHERE status EQ lc_success.

  IF li_log_char_e IS NOT INITIAL.

    LOOP AT fp_i_final_output INTO lwa_output.

      READ TABLE li_log_char_e INTO lwa_log WITH KEY   vbeln = lwa_output-vbeln
                                                       posnr = lwa_output-posnr
                                                       BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        lwa_error-vbeln = lwa_output-vbeln.
        lwa_error-posnr = lwa_output-posnr.
        lwa_error-matnr = lwa_output-matnr.
        lwa_error-kwmeng = lwa_output-kwmeng.
        lwa_error-omeng = lwa_output-omeng.
        lwa_error-bmeng = lwa_output-bmeng.
        lwa_error-kunnr = lwa_output-kunnr.
        lwa_error-name1 = lwa_output-name1.
        lwa_error-vkorg = lwa_output-vkorg.
        lwa_error-vtweg = lwa_output-vtweg.
        lwa_error-werks = lwa_output-werks.
        lwa_error-edatu = lwa_output-edatu.
        lwa_error-charg = lwa_output-charg.
        lwa_error-lifsk = lwa_output-lifsk.
        lwa_error-vtext = lwa_output-vtext.
        lwa_error-antigens = lwa_output-antigens.
        lwa_error-corres = lwa_output-corres.

        APPEND lwa_error TO fp_i_elog.
        CLEAR: lwa_error,
               lwa_log,
               lwa_output.

      ENDIF. " IF sy-subrc IS INITIAL

    ENDLOOP. " LOOP AT fp_i_final_output INTO lwa_output

  ENDIF. " IF li_log_char_e IS NOT INITIAL

*&--Get the success records

  SORT li_log_char_s BY vbeln posnr.
  DELETE li_log_char_s WHERE status EQ c_etyp.

  IF li_log_char_s IS NOT INITIAL.

    LOOP AT fp_i_final_output INTO lwa_output.

      READ TABLE li_log_char_s INTO lwa_log WITH KEY   vbeln = lwa_output-vbeln
                                                       posnr = lwa_output-posnr
                                                     BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        lwa_success-vbeln = lwa_output-vbeln.
        lwa_success-posnr = lwa_output-posnr.
        lwa_success-matnr = lwa_output-matnr.
        lwa_success-kwmeng = lwa_output-kwmeng.
        lwa_success-omeng = lwa_output-omeng.
        lwa_success-bmeng = lwa_output-bmeng.
        lwa_success-kunnr = lwa_output-kunnr.
        lwa_success-name1 = lwa_output-name1.
        lwa_success-vkorg = lwa_output-vkorg.
        lwa_success-vtweg = lwa_output-vtweg.
        lwa_success-werks = lwa_output-werks.
        lwa_success-edatu = lwa_output-edatu.
        lwa_success-charg = lwa_output-charg.
        lwa_success-lifsk = lwa_output-lifsk.
        lwa_success-vtext = lwa_output-vtext.
        lwa_success-antigens = lwa_output-antigens.
        lwa_success-corres = lwa_output-corres.

        APPEND lwa_success TO fp_i_slog.
        CLEAR: lwa_success,
               lwa_log,
               lwa_output.

      ENDIF. " IF sy-subrc IS INITIAL

    ENDLOOP. " LOOP AT fp_i_final_output INTO lwa_output

  ENDIF. " IF li_log_char_s IS NOT INITIAL

ENDFORM. " F_GET_RECORDS
*&---------------------------------------------------------------------*
*&      Form  F_FAIL_LOG_APS
*&---------------------------------------------------------------------*
*  Fail log from application server file
*----------------------------------------------------------------------*
*      -->FP_I_ELOG    Error log table
*      -->FP_P_APSFIL  Local file for upload/download
*----------------------------------------------------------------------*
FORM f_fail_log_aps  USING    fp_i_elog TYPE ty_t_input   "Error log table
                              fp_p_apsfil TYPE localfile. " Local file for upload/download

* Local Data Declaration
  DATA : lv_string  TYPE string,
         lwa_elog TYPE ty_input,
         lv_postfil TYPE localfile. " Local file for upload/download

* Check for Log Data
  IF fp_i_elog IS NOT INITIAL.
* Set Path to Error Folder
    lv_postfil = fp_p_apsfil.
    REPLACE FIRST OCCURRENCE OF c_tbp
          IN lv_postfil WITH c_err.
* Open File to be Written
    TRY .
        OPEN DATASET lv_postfil
        FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " Output type
      CATCH cx_sy_file_open.
        MESSAGE i021 WITH lv_postfil.
        LEAVE LIST-PROCESSING.
      CATCH cx_sy_codepage_converter_init.
        MESSAGE i021 WITH lv_postfil.
        LEAVE LIST-PROCESSING.
      CATCH cx_sy_file_authority.
        MESSAGE i021 WITH lv_postfil.
        LEAVE LIST-PROCESSING.
      CATCH cx_sy_pipes_not_supported.
        MESSAGE i021 WITH lv_postfil.
        LEAVE LIST-PROCESSING.
      CATCH cx_sy_too_many_files.
        MESSAGE i021 WITH lv_postfil.
        LEAVE LIST-PROCESSING.
    ENDTRY.
*  Loop at Error Log to Write File
    LOOP AT fp_i_elog INTO lwa_elog.
      CONCATENATE lwa_elog-vbeln
                  lwa_elog-posnr
                  lwa_elog-matnr
                  lwa_elog-kwmeng
                  lwa_elog-omeng
                  lwa_elog-bmeng
                  lwa_elog-kunnr
                  lwa_elog-name1
                  lwa_elog-vkorg
                  lwa_elog-vtweg
                  lwa_elog-werks
                  lwa_elog-edatu
                  lwa_elog-charg
                  lwa_elog-lifsk
                  lwa_elog-vtext
                  lwa_elog-antigens
                  lwa_elog-corres

             INTO lv_string SEPARATED BY space.
*  Write File to Application Server
      TRY .
          TRANSFER lv_string TO lv_postfil.
        CATCH cx_sy_file_open.
          MESSAGE i021 WITH lv_postfil.
          LEAVE LIST-PROCESSING.
        CATCH cx_sy_codepage_converter_init.
          MESSAGE i021 WITH lv_postfil.
          LEAVE LIST-PROCESSING.
        CATCH cx_sy_file_authority.
          MESSAGE i021 WITH lv_postfil.
          LEAVE LIST-PROCESSING.
        CATCH cx_sy_pipes_not_supported.
          MESSAGE i021 WITH lv_postfil.
          LEAVE LIST-PROCESSING.
        CATCH cx_sy_too_many_files.
          MESSAGE i021 WITH lv_postfil.
          LEAVE LIST-PROCESSING.
      ENDTRY.

      CLEAR lv_string.
    ENDLOOP. " LOOP AT fp_i_elog INTO lwa_elog

*  Close Data Set after Writing File
    TRY.
        CLOSE DATASET lv_postfil.
      CATCH cx_sy_file_close.
        MESSAGE i021 WITH lv_postfil.
        LEAVE LIST-PROCESSING.
    ENDTRY.

  ENDIF. " IF fp_i_elog IS NOT INITIAL

ENDFORM. " F_FAIL_LOG_APS
*&---------------------------------------------------------------------*
*&      Form  F_SUCCS_LOG_APS
*&---------------------------------------------------------------------*
*    Success log from application server
*----------------------------------------------------------------------*
*      -->FP_I_SLOG     Success log table
*      -->FP_P_APSFIL   Local file for upload/download
*----------------------------------------------------------------------*
FORM f_succs_log_aps  USING    fp_i_slog TYPE ty_t_input   "Success log table
                               fp_p_apsfil TYPE localfile. " Local file for upload/download

* Local Data Declaration
  DATA : lv_string  TYPE string,
         lwa_slog TYPE ty_input,
         lv_postfil TYPE localfile. " Local file for upload/download

* Check for Log Data
  IF fp_i_slog IS NOT INITIAL.
* Set Path to Error Folder
    lv_postfil = fp_p_apsfil.
    REPLACE FIRST OCCURRENCE OF c_tbp
          IN lv_postfil WITH c_done.
* Open File to be Written
    TRY .
        OPEN DATASET lv_postfil
        FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " Output type
      CATCH cx_sy_file_open.
        MESSAGE i021 WITH lv_postfil.
        LEAVE LIST-PROCESSING.
      CATCH cx_sy_codepage_converter_init.
        MESSAGE i021 WITH lv_postfil.
        LEAVE LIST-PROCESSING.
      CATCH cx_sy_file_authority.
        MESSAGE i021 WITH lv_postfil.
        LEAVE LIST-PROCESSING.
      CATCH cx_sy_pipes_not_supported.
        MESSAGE i021 WITH lv_postfil.
        LEAVE LIST-PROCESSING.
      CATCH cx_sy_too_many_files.
        MESSAGE i021 WITH lv_postfil.
        LEAVE LIST-PROCESSING.
    ENDTRY.
*  Loop at Error Log to Write File
    LOOP AT fp_i_slog INTO lwa_slog.
      CONCATENATE lwa_slog-vbeln
                  lwa_slog-posnr
                  lwa_slog-matnr
                  lwa_slog-kwmeng
                  lwa_slog-omeng
                  lwa_slog-bmeng
                  lwa_slog-kunnr
                  lwa_slog-name1
                  lwa_slog-vkorg
                  lwa_slog-vtweg
                  lwa_slog-werks
                  lwa_slog-edatu
                  lwa_slog-charg
                  lwa_slog-lifsk
                  lwa_slog-vtext
                  lwa_slog-antigens
                  lwa_slog-corres

             INTO lv_string SEPARATED BY space.
*  Write File to Application Server
      TRY .
          TRANSFER lv_string TO lv_postfil.
        CATCH cx_sy_file_open.
          MESSAGE i021 WITH lv_postfil.
          LEAVE LIST-PROCESSING.
        CATCH cx_sy_codepage_converter_init.
          MESSAGE i021 WITH lv_postfil.
          LEAVE LIST-PROCESSING.
        CATCH cx_sy_file_authority.
          MESSAGE i021 WITH lv_postfil.
          LEAVE LIST-PROCESSING.
        CATCH cx_sy_pipes_not_supported.
          MESSAGE i021 WITH lv_postfil.
          LEAVE LIST-PROCESSING.
        CATCH cx_sy_too_many_files.
          MESSAGE i021 WITH lv_postfil.
          LEAVE LIST-PROCESSING.
      ENDTRY.

      CLEAR lv_string.
    ENDLOOP. " LOOP AT fp_i_slog INTO lwa_slog

*  Close Data Set after Writing File
    TRY.
        CLOSE DATASET lv_postfil.
      CATCH cx_sy_file_close.
        MESSAGE i021 WITH lv_postfil.
        LEAVE LIST-PROCESSING.
    ENDTRY.

  ENDIF. " IF fp_i_slog IS NOT INITIAL

ENDFORM. " F_SUCCS_LOG_APS
*&---------------------------------------------------------------------*
*&      Form  F_SEND_JOB_DETAILS
*&---------------------------------------------------------------------*
*  Send the job details by email to the user
*----------------------------------------------------------------------*
*      -->FP_I_LOGCHAR[]    Final table
*      -->FP_I_ELOG[]       error table
*      -->FP_I_SLOG[]       success table
*      -->FP_P_JOBNAM       Background job name
*      -->FP_P_JOBNUM       Job ID
*----------------------------------------------------------------------*
FORM f_send_job_details  USING    fp_i_logchar TYPE ty_t_log_char " log file
                                  fp_i_elog    TYPE ty_t_input    " Error log
                                  fp_i_slog    TYPE ty_t_input    " Success log
                                  fp_p_jobname  TYPE btcjob       " Background job name
                                  fp_p_jobnum   TYPE btcjobcnt.   " Job ID.


*Local Data Declaration for Sending Mail
  DATA  :
       li_msg_bdy   TYPE  bcsy_text,                     " Mail Body
       lwa_recipient TYPE zdev_receipients,              " InfoUser (SEM-BIC)
       lv_username    TYPE bapibname-bapibname,          " User Name in User Master Record
       li_return      TYPE STANDARD TABLE OF bapiret2,   " Return Parameter
       li_addsmtp     TYPE STANDARD TABLE OF bapiadsmtp, " BAPI Structure for E-Mail Addresses (Bus. Address Services)
       lwa_addsmtp    TYPE bapiadsmtp,                   " BAPI Structure for E-Mail Addresses (Bus. Address Services)
       lwa_msg_bdy  TYPE soli,                           " SAPoffice: line, length 255
       lv_subjct    TYPE so_obj_des,                     " Short description of contents
       lv_date      TYPE xubname,                        " External Date
       lv_elog_indx TYPE xubname,                        " Index of Internal Tables
       lv_slog_indx TYPE xubname,                        " Index of Internal Tables
       lv_flog_indx TYPE xubname,                        " Index of Internal Tables
       lv_res       TYPE boolean.                        " Boolean Variable (X=True, -=False, Space=Unknown)

*Local Constant Declaration
  CONSTANTS:
       lc_coma     TYPE char1           VALUE ',',               " Coma of type CHAR1
       lc_pdfname  TYPE char255         VALUE 'Job_Details.pdf'. " Pdf name

*  get the user email_id.

  lv_username = sy-uname.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = lv_username
    TABLES
      return   = li_return
      addsmtp  = li_addsmtp.

  READ TABLE li_addsmtp INTO lwa_addsmtp INDEX 1 . "   The table will always contain of single record .
  IF sy-subrc IS INITIAL.
    CLEAR lwa_recipient.
    lwa_recipient-iusrid = lv_username.
    lwa_recipient-email = lwa_addsmtp-e_mail .

  ENDIF. " IF sy-subrc IS INITIAL

*Convert Internal Date to External
  WRITE sy-datum TO lv_date.
*Subject Line for Mail
  CONCATENATE
  'Batch Determination at Sales Order Status in background mode -'(011) lv_date
  INTO lv_subjct
  SEPARATED BY space.

*Body Content for Mail
  CONCATENATE 'Hi'(012) lc_coma
  INTO lwa_msg_bdy
   IN CHARACTER MODE.
  APPEND lwa_msg_bdy TO li_msg_bdy.

  lwa_msg_bdy = space.
  APPEND lwa_msg_bdy TO li_msg_bdy.

  CONCATENATE
  'Job Scheduled Successfully Via Job Name'(013)
  fp_p_jobname
  'and Job Number'(014)
  fp_p_jobnum
  INTO lwa_msg_bdy
  SEPARATED BY space.
  APPEND lwa_msg_bdy TO li_msg_bdy.

  lwa_msg_bdy = space.
  APPEND lwa_msg_bdy TO li_msg_bdy.

  CONCATENATE
          'Job Submitted by USER -'(015)
          sy-uname
          INTO lwa_msg_bdy
          SEPARATED BY space.
  APPEND lwa_msg_bdy TO li_msg_bdy.

  lwa_msg_bdy = space.
  APPEND lwa_msg_bdy TO li_msg_bdy.

  DESCRIBE TABLE fp_i_logchar LINES lv_flog_indx.

  CONCATENATE 'Total Records Passed :'(016)
           lv_flog_indx
           INTO lwa_msg_bdy
           SEPARATED BY space.
  APPEND lwa_msg_bdy TO li_msg_bdy.

  lwa_msg_bdy = space.
  APPEND lwa_msg_bdy TO li_msg_bdy.

  DESCRIBE TABLE fp_i_elog LINES lv_elog_indx.

  CONCATENATE 'Error Records        :'(017)
              lv_elog_indx
              INTO lwa_msg_bdy
              SEPARATED BY space.
  APPEND lwa_msg_bdy TO li_msg_bdy.

  lwa_msg_bdy = space.
  APPEND lwa_msg_bdy TO li_msg_bdy.

  DESCRIBE TABLE fp_i_slog LINES lv_slog_indx.

  CONCATENATE 'Successful Records   :'(018)
              lv_slog_indx
              INTO lwa_msg_bdy
              SEPARATED BY space.
  APPEND lwa_msg_bdy TO li_msg_bdy.

  lwa_msg_bdy = space.
  APPEND lwa_msg_bdy TO li_msg_bdy.

  lwa_msg_bdy = 'Please find the attachment for details on Attempted, Successful and Failed Records.'(019).
  APPEND lwa_msg_bdy TO li_msg_bdy.

*Send mail with Inspection Details
  CALL FUNCTION 'ZDEV_SEND_EMAIL_ATCH_PDF'
    EXPORTING
      im_spoolid         = gv_spoolid
      im_subject         = lv_subjct
      im_message_body    = li_msg_bdy
      im_atch_name       = lc_pdfname
      im_recipient_mail  = lwa_recipient-email
    IMPORTING
      ex_result          = lv_res
    EXCEPTIONS
      pdf_not_generated  = 1
      no_document_format = 2
      mail_not_sent      = 3
      OTHERS             = 4.
  IF sy-subrc <> 0.
    MESSAGE e070. "Email Not Sent
  ENDIF. " IF sy-subrc <> 0

ENDFORM. " F_SEND_JOB_DETAILS
*&---------------------------------------------------------------------*
*&      Form  F_FILL_LOG
*&---------------------------------------------------------------------*
*  Fill the log table based on error and success records
*----------------------------------------------------------------------*
*      -->FP_I_LOG_BACKG[]
*      <--FP_I_LOG_CHAR[]
*----------------------------------------------------------------------*
FORM f_fill_log  USING    fp_i_log_backg  TYPE ty_t_log_char  "Log table for background
                 CHANGING fp_i_log_char   TYPE ty_t_log_char. " Log table

  DATA: lwa_log_backg TYPE ty_log_char,
        lwa_log_char  TYPE ty_log_char.

*&--Fill the log table

  LOOP AT fp_i_log_backg INTO lwa_log_backg.

    lwa_log_char-vbeln = lwa_log_backg-vbeln.
    lwa_log_char-posnr = lwa_log_backg-posnr.
    lwa_log_char-status = lwa_log_backg-status.
    lwa_log_char-message = lwa_log_backg-message.

    APPEND lwa_log_char TO fp_i_log_char[].
    CLEAR lwa_log_char.

  ENDLOOP. " LOOP AT fp_i_log_backg INTO lwa_log_backg

ENDFORM. " F_FILL_LOG
*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_JOB
*&---------------------------------------------------------------------*
*    Get the cancel job
*----------------------------------------------------------------------*
*      -->fp_p_jobname  Background job name                            *
*      -->fp_p_jobnum   Job ID
*----------------------------------------------------------------------*
FORM f_cancel_job  USING    fp_p_jobname  TYPE btcjob     " Background job name.
                            fp_p_jobnum   TYPE btcjobcnt. " Job ID.

  DATA: lv_status TYPE btcstatus. " State of Background Job
  CONSTANTS: lc_status TYPE btcstatus VALUE 'A'. " State of Background Job

*&--Get the cancel job status

  SELECT SINGLE status FROM tbtco INTO lv_status
                WHERE jobname = fp_p_jobname
                AND   jobcount = fp_p_jobnum.
  IF sy-subrc IS INITIAL.

    IF lv_status = lc_status.
*&--Trigger a mail to the user.

      PERFORM f_send_cancel_mail USING p_jobnam
                                       p_jobnum.

    ENDIF. " IF lv_status = lc_status

  ENDIF. " IF sy-subrc IS INITIAL


ENDFORM. " F_CANCEL_JOB
*&---------------------------------------------------------------------*
*&      Form  F_SEND_CANCEL_MAIL
*&---------------------------------------------------------------------*
*   send the mail with cancel job
*----------------------------------------------------------------------*
*  -->  fp_p_jobname        Background job name
*  -->  fp_p_jobnum         Job ID
*----------------------------------------------------------------------*
FORM f_send_cancel_mail  USING   fp_p_jobname  TYPE btcjob     " Background job name
                                 fp_p_jobnum   TYPE btcjobcnt. " Job ID.  .

  DATA: li_msg_bdy       TYPE  bcsy_text,                   " Mail Body
        lwa_doc_data     TYPE sodocchgi1,                   " Data of an object which can be changed
        lwa_packing_list TYPE sopcklsti1,                   " SAPoffice: Descrip
        lwa_receivers    TYPE somlreci1,                    " SAPoffice: Structure of the API Recipient List
        li_receivers     TYPE STANDARD TABLE OF somlreci1,  " SAPoffice: Structure of the API Recipient List
        li_packing_list  TYPE STANDARD TABLE OF sopcklsti1, " SAPoffice: Description of Imported Object Components
        lv_username      TYPE bapibname-bapibname,          " User Name in User Master Record
        li_return        TYPE STANDARD TABLE OF bapiret2,   " Return Parameter
        li_addsmtp       TYPE STANDARD TABLE OF bapiadsmtp, " BAPI Structure for E-Mail Addresses (Bus. Address Services)
        lwa_addsmtp      TYPE bapiadsmtp,                   " BAPI Structure for E-Mail Addresses (Bus. Address Services)
        lwa_msg_bdy      TYPE soli,                         " SAPoffice: line, length 255
        lv_date          TYPE xubname,                      " External Date
        lv_subjct        TYPE so_obj_des.                   " Short description of contents


  CONSTANTS: lc_rec_type  TYPE so_escape  VALUE 'U',   " External receiver
             lc_doc_type  TYPE so_obj_tp  VALUE 'RAW', " Document type
             lc_coma      TYPE char1      VALUE ',',   " Coma of type CHAR1
             lc_com_type  TYPE so_snd_art VALUE 'INT'. " Communication type


*  get the user email_id.

  lv_username = sy-uname.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = lv_username
    TABLES
      return   = li_return
      addsmtp  = li_addsmtp.

  READ TABLE li_addsmtp INTO lwa_addsmtp INDEX 1 . "   The table will always contain of single record .
  IF sy-subrc IS INITIAL.

*         Receivers email address
    CLEAR lwa_receivers.
    lwa_receivers-receiver   = lwa_addsmtp-e_mail . " Assign Email id
    lwa_receivers-rec_type   = lc_rec_type. " Send to External Email id
    lwa_receivers-com_type   = lc_com_type.
    lwa_receivers-notif_del  = abap_true.
    lwa_receivers-notif_ndel = abap_true.
    APPEND lwa_receivers TO li_receivers.

  ENDIF. " IF sy-subrc IS INITIAL

*Convert Internal Date to External
  WRITE sy-datum TO lv_date.
*Subject Line for Mail
  CONCATENATE
  'Batch Job Cancelled -'(020) lv_date
  INTO lv_subjct
  SEPARATED BY space.

*Body Content for Mail
  CONCATENATE 'Hi'(012) lc_coma
  INTO lwa_msg_bdy
   IN CHARACTER MODE.
  APPEND lwa_msg_bdy TO li_msg_bdy.

  CONCATENATE
 'Job Cancelled Via Job Name'(021)
 fp_p_jobname
 'and Job Number'(014)
 fp_p_jobnum
 INTO lwa_msg_bdy
 SEPARATED BY space.
  APPEND lwa_msg_bdy TO li_msg_bdy.

  lwa_msg_bdy = space.
  APPEND lwa_msg_bdy TO li_msg_bdy.

  CONCATENATE
          'Job Submitted by USER -'(015)
          sy-uname
          INTO lwa_msg_bdy
          SEPARATED BY space.
  APPEND lwa_msg_bdy TO li_msg_bdy.

*         Populate the subject/generic message attributes
  lwa_doc_data-doc_size = 1.
  lwa_doc_data-obj_langu = sy-langu.
  lwa_doc_data-obj_name = lv_subjct.
  lwa_doc_data-obj_descr = lv_subjct.

*         Describe the body of the message

  REFRESH li_packing_list.
  lwa_packing_list-transf_bin = space.
  lwa_packing_list-head_start = 1.
  lwa_packing_list-head_num = 0.
  lwa_packing_list-body_start = 1.
  lwa_packing_list-doc_type = lc_doc_type.
  DESCRIBE TABLE li_msg_bdy LINES lwa_packing_list-body_num.
  APPEND lwa_packing_list TO li_packing_list.
  CLEAR lwa_packing_list.

*         Call the Function Module to send the message to External id
  CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
    EXPORTING
      document_data              = lwa_doc_data
      put_in_outbox              = abap_true
      commit_work                = abap_true
    TABLES
      packing_list               = li_packing_list
      contents_txt               = li_msg_bdy
      receivers                  = li_receivers
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.


  IF sy-subrc <> 0.
    MESSAGE e070. "Email Not Sent
  ELSE. " ELSE -> IF sy-subrc <> 0
    LEAVE TO SCREEN 0.
  ENDIF. " IF sy-subrc <> 0


ENDFORM. " F_SEND_CANCEL_MAIL
