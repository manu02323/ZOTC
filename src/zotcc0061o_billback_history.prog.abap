*&---------------------------------------------------------------------*
*& Report  ZOTCC0061O_BILLBACK_HISTORY
*&
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCC0061O_BILLBACK_HISTORY                            *
* TITLE      :  OTC_CDD_0061_Convert 1 year history data for billback  *
*               and commission.
* DEVELOPER  :  Deepa Sharma                                           *
* OBJECT TYPE:  Conversion                                             *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_CDD_0061_SAP                                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Convert 1 year history data for billback & commission. *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 16-MAY-2012 DSHARMA1 E1DK901626  INITIAL DEVELOPMENT                 *
* 16-Oct-2012 SPURI    E1DK906961  Defect 492 :Skip Header Record from
*                                  Input File                          *
*                                  Defect 628 :Do not Check Customer   *
*                                  Material Number From MARA
* 25-Oct-2012 ADAS1    E1DK906961  Defect 597 : EXPNR fields should not
*                                  be mandatory for loading.
* 02-Nov-2012 SPURI    E1DK906961  Defect 1353: In case no product
*                                  hierarchy is passed from input file
*                                  read it from table MARA for a given
*                                  material
*&---------------------------------------------------------------------*
REPORT  zotcc0061o_billback_history NO   STANDARD PAGE HEADING
                                         LINE-SIZE 132
                                         MESSAGE-ID zotc_msg.
************************************************************************
*---- INCLUDES --------------------------------------------------------*
************************************************************************
* Top Include
INCLUDE zotcn0061o_billback_top.
* Common Include for Conversion Programs
INCLUDE zdevnoxxx_common_include.
* Selection Screen Include
INCLUDE zotcn0061o_billback_sel.
* Include for all subroutines
INCLUDE zotcn0061o_billback_form.

************************************************************************
*---- AT-SELECTION-SCREEN OUTPUT --------------------------------------*
************************************************************************
AT SELECTION-SCREEN OUTPUT.
*   Modify the screen based on User action.
  PERFORM f_modify_screen.

************************************************************************
*---- AT-SELECTION-SCREEN VALUE REQUEST -------------------------------*
************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_pfile.
  PERFORM f_help_l_path_txt CHANGING p_pfile.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_afile.
  PERFORM f_help_as_path CHANGING p_afile.
************************************************************************
*---- AT-SELECTION-SCREEN VALIDATION ----------------------------------*
************************************************************************
* Validating Input File - Presentation Server
AT SELECTION-SCREEN ON p_pfile.
  IF rb_pres = c_true AND
     p_pfile IS NOT INITIAL.
*     Validating the Input File Name
    PERFORM f_validate_p_file USING p_pfile.
*     Checking for ".TXT" extension.
    PERFORM f_check_extension USING p_pfile.
  ENDIF.

* Validating Input File - Application Server
AT SELECTION-SCREEN ON p_afile.
  IF p_afile IS NOT INITIAL.
*     Checking for ".TXT" extension.
    PERFORM f_check_extension USING p_afile.
  ENDIF.

************************************************************************
*---- START-OF-SELECTION ----------------------------------------------*
************************************************************************
START-OF-SELECTION.
*   Checking on File Input
  PERFORM f_check_input.

*   Setting the mode of processing
  PERFORM f_set_mode CHANGING gv_mode.

*   Uploading the file from Presentation Server
  IF rb_pres IS NOT INITIAL.
    gv_file = p_pfile.
    PERFORM f_upload_pres USING gv_file
                       CHANGING i_input[].
  ENDIF.

*   Uploading the files from Application Server
  IF rb_app IS NOT INITIAL.
*     If Logical File option is selected.
    IF rb_alog IS NOT INITIAL.
*       Retriving physical file paths from logical file name
      PERFORM f_logical_to_physical USING p_alog
                                 CHANGING gv_file.
    ELSE.
      gv_file = p_afile.
    ENDIF.
*     Uploading the files from Application Server
    PERFORM f_upload_apps USING gv_file
                       CHANGING i_input[].
  ENDIF.

*   Checking whether the uploaded file is empty or not. If empty, then
*   Stopping program
  IF i_input IS INITIAL.
*   No record found to upload. Please check your entry.
    MESSAGE i000 WITH 'No record found to upload.Please check your entry.'(m03).
    LEAVE LIST-PROCESSING.
  ELSE.
*     Retrieve value from DB for input file validation.
    PERFORM f_get_db_values CHANGING i_input[]
                                     i_mara[]
                                     i_tvko[]
                                     i_tvtw[]
                                     i_kna1[]
                                     i_t151[]
                                     i_tvv1[]
                                     i_tvv2[]
                                     i_edpar[].
  ENDIF.

************************************************************************
*---- END-OF-SELECTION ------------------------------------------------*
************************************************************************
END-OF-SELECTION.
*     Validating Input File
  PERFORM f_validate_input USING  i_mara[]
                                  i_tvko[]
                                  i_tvtw[]
                                  i_kna1[]
                                  i_t151[]
                                  i_tvv1[]
                                  i_tvv2[]
                                  i_edpar[]
                         CHANGING i_report[]
                                  i_input_e[]
                                  i_input[].

*     Refresh all the internal tables not required anymore
  PERFORM f_refresh.

*Check if some valid records exist need to be upload
  IF i_input IS NOT INITIAL
    AND rb_post IS NOT INITIAL.
*   Insert the Records to Custom Table ZOTC_BILLBACK
    PERFORM f_insert USING i_input
                  CHANGING i_report.
  ENDIF.

*   In case the file was uploaded from Application server, then
*   Moving them in Processed / Error folder depending upon Final
*   Status of Posting.
  IF rb_app IS NOT INITIAL.
*     If Posting is done, then moving the files to DONE folder
    IF rb_post IS NOT INITIAL.
*       Moving Input File
      PERFORM f_move USING gv_file
                     CHANGING i_report[].
    ENDIF.
*     In case of error, passing it to Error folder.
    IF gv_err_flg IS NOT INITIAL.
*       Moving Error File
      IF i_input_e IS NOT INITIAL.
        PERFORM f_move_error USING gv_file
                                   i_input_e[].
      ENDIF.
    ENDIF.
  ENDIF.

*   Displaying The Log Report
  IF i_report[] IS NOT INITIAL.
*defect 1241
*    PERFORM f_display_summary_report  USING i_report[]
*                                            gv_file
*                                            gv_mode
*                                            gv_succ
*                                            gv_error.

    PERFORM f_display_summary_report1  USING i_report[]
                                             gv_file
                                             gv_mode
                                             gv_succ
                                             gv_error.
*defect 1241
  ENDIF.


*&---------------------------------------------------------------------*
*&      Form  f_display_summary_report
*&---------------------------------------------------------------------*
*       Dispalying Summary Report for ONE INPUT FILE.
*&---------------------------------------------------------------------*
*      -->FP_P_REPORT     Report Table
*      -->FP_gv_filename_d  Input File Name
*      -->FP_GV_MODE      Mode of execution of program
*      -->FP_NO_SUCCESS   Number of successfully processed record.
*      -->FP_NO_FAILED    Number of record failed.
*----------------------------------------------------------------------*
FORM f_display_summary_report1 USING fp_i_report      TYPE ty_t_report_p
                                    fp_gv_filename_d TYPE localfile
                                    fp_gv_mode       TYPE char10
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
             c_slash TYPE char1 VALUE '/'.

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
        li_events      TYPE slis_t_event,
        lwa_events     TYPE slis_alv_event,
        li_report_b    TYPE STANDARD TABLE OF ty_report_b INITIAL SIZE 0,
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
*Defect 1241
*    gv_total = lv_total.
*    gv_no_success = fp_no_success.
*    gv_no_failed = fp_no_failed.
    gv_total2      = lv_total.
    gv_no_success2 = fp_no_success.
    gv_no_failed2  = fp_no_failed.
    gv_rate_c = lv_rate_c.
*Defect 1241

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
ENDFORM.                    "display_summary_report
*&---------------------------------------------------------------------*
*&      Form  F_TOP_OF_PAGE
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
ENDFORM.                    " F_TOP_OF_PAGE
