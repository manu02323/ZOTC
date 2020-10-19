************************************************************************
* PROGRAM    :  ZOTCR0014O_GPO_ROASTER_UPLOAD                           *
* TITLE      :  OTC_IDD_0014_GPO Roaster Upload                        *
* DEVELOPER  :  Kiran R Durshanapally                                  *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_0014_Upload GPO Roster
*----------------------------------------------------------------------*
* DESCRIPTION: Uploading GPO Roaster into Customer Master              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 03-APR-2012 KDURSHA  E1DK900679 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_Read_excel_file
*&---------------------------------------------------------------------*
*       To Read the Excel file from presentation server.
*----------------------------------------------------------------------*
*               fp_i_gporoaster_info
*               fp_p_phdr
*               fp_gv_scol
*               fp_gv_srow
*               fp_gv_ecol
*               fp_gv_erow
*----------------------------------------------------------------------*
form f_read_excel_file tables   fp_i_gporoaster_info type ty_t_gporoaster_info
                       using    fp_p_phdr type localfile
                                fp_gv_scol type i
                                fp_gv_srow type i
                                fp_gv_ecol type i
                                fp_gv_erow type i.

  data : il_intern type  standard table of alsmex_tabline,
         lwa_intern type alsmex_tabline.

  data : lv_index type i,
         lv_msg   type string.       " local variable for message
  field-symbols : <fs>.


  call function 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    exporting
      filename                = fp_p_phdr
      i_begin_col             = fp_gv_scol
      i_begin_row             = fp_gv_srow
      i_end_col               = fp_gv_ecol
      i_end_row               = fp_gv_erow
    tables
      intern                  = il_intern
    exceptions
      inconsistent_parameters = 1
      upload_ole              = 2
      others                  = 3.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno into lv_msg
         with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    write: / lv_msg.

  endif.

  if il_intern[] is initial.
    format color col_background intensified.
    write:/ text-014.
    return.
  else.
    sort il_intern by row col.
    loop at il_intern into lwa_intern.
      move lwa_intern-col to lv_index.
      assign component lv_index of structure fp_i_gporoaster_info to <fs>.
      move lwa_intern-value to <fs>.
      at end of row.
        append fp_i_gporoaster_info.
        clear fp_i_gporoaster_info.
      endat.
    endloop.
  endif.
endform.                    "f_Read_excel_file
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_EXTENSION
*&---------------------------------------------------------------------*
*       Checking whetehr the file has .XLS extension.
*----------------------------------------------------------------------*
*      -->P_P_PHDR  text
*----------------------------------------------------------------------*
form f_check_extension_pres  using fp_p_file type localfile.

  if fp_p_file is not initial.
    clear gv_extn.
    perform f_file_extn_check using fp_p_file
                           changing gv_extn.
    if gv_extn <> c_text_pres.
      message e000 with text-011.
    endif.
  endif.
endform.              " F_CHECK_EXTENSION
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_EXTENSION_APPL
*&---------------------------------------------------------------------*
*      Checking whetehr the file has .CSV extension.
*----------------------------------------------------------------------*
*      -->P_P_AHDR  text
*----------------------------------------------------------------------*
form f_check_extension_appl  using fp_p_file type localfile.

  if fp_p_file is not initial.
    clear gv_extn.
    perform f_file_extn_check using fp_p_file
                           changing gv_extn.
    if gv_extn <> c_text_appl.
      message e000 with text-012.
    endif.
  endif.
endform.                    "f_check_extension_appl
*&---------------------------------------------------------------------*
*&      Form  F_READ_FILE_FROM_APPSERVER
*&---------------------------------------------------------------------*
*       Read the data from CSV file and prepares the Internal Table
*----------------------------------------------------------------------*
*      -->P_I_GPOROASTER_INFO  text
*      -->P_P_AHDR  text
*      -->P_GV_SCOL  text
*      -->P_GV_SROW  text
*      -->P_GV_ECOL  text
*      -->P_GV_EROW  text
*----------------------------------------------------------------------*
form f_read_file_from_appserver  tables   fp_i_gporoaster_info type ty_t_gporoaster_info
                                 using    fp_gv_file type localfile.


  data:lv_input_line(255) type c,
       lv_subrc           type sysubrc,
       lwa_error_report   type ty_input_e.

* Opening the Dataset for File Read
  open dataset fp_gv_file for input in text mode encoding default.

  if sy-subrc is initial.
*   Reading the Header Input File
    while ( lv_subrc eq 0 ).

      read dataset fp_gv_file into lv_input_line.
*     Sotring the SY-SUBRC value. To be used as loop-breaking condn.
      lv_subrc = sy-subrc.
*       Aligning the values as per the structure
      split lv_input_line at c_comma into wa_gporoaster_info-kunnr
                                          wa_gporoaster_info-vkorg
                                          wa_gporoaster_info-vtweg
                                          wa_gporoaster_info-spart
                                          wa_gporoaster_info-name1
                                          wa_gporoaster_info-kdkg1
                                          wa_gporoaster_info-kdkg2
                                          wa_gporoaster_info-kdkg3
                                          wa_gporoaster_info-kvgr1
                                          wa_gporoaster_info-kvgr2
                                          wa_gporoaster_info-kdgrp.

      if not wa_gporoaster_info is initial.
        replace c_crlf(1) in wa_gporoaster_info with ''.
        append wa_gporoaster_info to fp_i_gporoaster_info.
        clear wa_gporoaster_info.
      endif.
      clear lv_input_line.
    endwhile.
  else.
*  If File Open fails, then populating the Error Log
    message e000 with text-013 into gv_mtext.
    gv_flag_err = c_true.
    lwa_error_report-err_msg = gv_mtext.
    append lwa_error_report to i_error_report.
    clear: lwa_error_report.
  endif.
  close dataset fp_gv_file.
* Deleting the First Index Line from the table
  delete fp_i_gporoaster_info index 1.
endform.                    " F_READ_FILE_FROM_APPSERVER
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_CUSTOMER_MASTER
*&---------------------------------------------------------------------*
*       Updates the customer with the GPO information
*----------------------------------------------------------------------*
*      -->P_I_GPROASTER_INFO  text
*      -->P_ENDFORM  text
*----------------------------------------------------------------------*
form f_update_customer_master  using    fp_i_gporoaster_info type ty_t_gporoaster_info
                               changing fp_i_error_report type ty_t_input_e
                                        fp_i_succ_report type ty_t_gporoaster_info.

* Local Data
  data: li_bdcdata   type ty_t_bdcdata.

  loop at fp_i_gporoaster_info into wa_gporoaster_info.

*       Initial Screen
    perform f_bdc_dynpro using 'SAPMF02D'
                               '0101'
                              changing  li_bdcdata.

    perform f_bdc_field  using 'BDC_CURSOR'
                               'RF02D-D0310'
                              changing  li_bdcdata.

    perform f_bdc_field  using 'BDC_OKCODE'
                               '/00'
                              changing  li_bdcdata.

    perform f_bdc_field  using 'RF02D-KUNNR'
                                wa_gporoaster_info-kunnr
                              changing  li_bdcdata.

    perform f_bdc_field  using 'RF02D-BUKRS'
                               c_compcode
                              changing  li_bdcdata.

    perform f_bdc_field  using 'RF02D-VKORG'
                                wa_gporoaster_info-vkorg
                              changing  li_bdcdata.

    perform f_bdc_field  using 'RF02D-VTWEG'
                                wa_gporoaster_info-vtweg
                              changing  li_bdcdata.

    perform f_bdc_field  using 'RF02D-SPART'
                                wa_gporoaster_info-spart
                              changing  li_bdcdata.

    perform f_bdc_field  using 'RF02D-D0110'
                               'X'
                              changing  li_bdcdata.

    perform f_bdc_field  using 'RF02D-D0310'
                               'X'
                              changing  li_bdcdata.

    perform f_bdc_dynpro using 'SAPMF02D'
                               '0110'
                              changing  li_bdcdata.

    perform f_bdc_field  using 'BDC_CURSOR'
                               'KNA1-ANRED'
                              changing  li_bdcdata.

    perform f_bdc_field  using 'BDC_OKCODE'
                               '=ZUDA'
                              changing  li_bdcdata.

    perform f_bdc_dynpro using 'SAPLV02Z'
                               '0100'
                              changing  li_bdcdata.

    perform f_bdc_field  using 'BDC_CURSOR'
                               'KNA1-KDKG3'
                              changing  li_bdcdata.

    perform f_bdc_field  using 'BDC_OKCODE'
                               '=BACK'
                              changing  li_bdcdata.

    perform f_bdc_field  using 'KNA1-KDKG1'
                                wa_gporoaster_info-kdkg1
                              changing  li_bdcdata.

    perform f_bdc_field  using 'KNA1-KDKG2'
                                wa_gporoaster_info-kdkg2
                              changing  li_bdcdata.

    perform f_bdc_field  using 'KNA1-KDKG3'
                                wa_gporoaster_info-kdkg3
                              changing  li_bdcdata.

    perform f_bdc_dynpro using 'SAPMF02D'
                               '0110'
                              changing  li_bdcdata.

    perform f_bdc_field  using 'BDC_CURSOR'
                               'KNA1-ANRED'
                              changing  li_bdcdata.

    perform f_bdc_field  using 'BDC_OKCODE'
                               '/00'
                              changing  li_bdcdata.

    perform f_bdc_dynpro using 'SAPMF02D'
                               '0310'
                              changing  li_bdcdata.

    perform f_bdc_field  using 'BDC_CURSOR'
                               'KNVV-BZIRK'
                              changing  li_bdcdata.

    perform f_bdc_field  using 'BDC_OKCODE'
                               '=ZUDA'
                              changing  li_bdcdata.

    perform f_bdc_field  using 'KNVV-KDGRP'
                                wa_gporoaster_info-kdgrp
                              changing  li_bdcdata.

    perform f_bdc_dynpro using 'SAPLV02Z'
                               '0200'
                              changing  li_bdcdata.

    perform f_bdc_field  using 'BDC_CURSOR'
                               'KNVV-KVGR2'
                              changing  li_bdcdata.

    perform f_bdc_field  using 'BDC_OKCODE'
                               '=BACK'
                              changing  li_bdcdata.

    perform f_bdc_field  using 'KNVV-KVGR1'
                                wa_gporoaster_info-kvgr1
                              changing  li_bdcdata.

    perform f_bdc_field  using 'KNVV-KVGR2'
                                wa_gporoaster_info-kvgr2
                              changing  li_bdcdata.

    perform f_bdc_dynpro using 'SAPMF02D'
                               '0310'
                              changing  li_bdcdata.

    perform f_bdc_field  using 'BDC_CURSOR'
                               'KNVV-KDGRP'
                              changing  li_bdcdata.

    perform f_bdc_field  using 'BDC_OKCODE'
                               '=UPDA'
                              changing  li_bdcdata.

*       Posting the data using BDC Sessions.
*       Inserting BDC Dataable in the session
*       Only BDC session related errors are captured in Report table
*       It does not track the transactional data post related error
    perform f_insert_bdc_session using    li_bdcdata
                                 changing fp_i_error_report
                                          fp_i_succ_report.



*       Refreshing BDCDATA for next set of data records.
    refresh: li_bdcdata.
    clear wa_gporoaster_info.
  endloop.
endform.                    " F_UPDATE_CUSTOMER_MASTER

" F_VALIDATE_APP_FILE
*&---------------------------------------------------------------------*
*&      Form  F_HELP_APPL_PATH
*&---------------------------------------------------------------------*
*       F4 Help for selecting file from Application Server
*----------------------------------------------------------------------*
*      <--fP_P_AHDR  text
*----------------------------------------------------------------------*
form f_help_appl_path  changing fp_v_filename type localfile.

* Function  module for F4 help from Application  server
  call function '/SAPDMC/LSM_F4_SERVER_FILE'
    importing
      serverfile       = fp_v_filename
    exceptions
      canceled_by_user = 1
      others           = 2.
  if sy-subrc is not initial.
    clear fp_v_filename.
  endif.
endform.                    " F_HELP_APPL_PATH
*&---------------------------------------------------------------------*
*&      Form  F_MOVE
*&---------------------------------------------------------------------*
*     Moving the Processed input file from TBP folder to DONE folder
*----------------------------------------------------------------------*
*      -->fp_v_source text
*----------------------------------------------------------------------*
form f_move  using fp_v_source type localfile.
* Local Data
  data: lv_file   type localfile,   "File Name
        lv_name   type localfile,   "Path Name
        lv_return type sysubrc.     "Return Code

* Spitting File Path & File Name
  call function '/SAPDMC/LSM_PATH_FILE_SPLIT'
    exporting
      pathfile = fp_v_source
    importing
      pathname = lv_file
      filename = lv_name.

* Changing the file path to DONE folder
  replace 'TBP'  in lv_file with 'DONE' .
  concatenate lv_file '/' lv_name into lv_file.
* Move the file
  perform f_file_move  using    fp_v_source
                                lv_file
                       changing lv_return.
endform.                    " F_MOVE
*&---------------------------------------------------------------------*
*&      Form  F_MOVE_ERROR
*&---------------------------------------------------------------------*
*      Moving the Error File to Error Folder
*----------------------------------------------------------------------*
form f_move_error  using fp_p_ahdr  type localfile
                         fp_i_input_e type ty_t_input_e.

* Local Data
  data: lv_file    type localfile,   "File Name
        lv_name    type localfile,   "File Name
        lv_data    type string,      "Output data string
        lwa_input_e type ty_input_e. "Input Error work area

* Spitting File Path & File Name
  call function '/SAPDMC/LSM_PATH_FILE_SPLIT'
    exporting
      pathfile = fp_p_ahdr
    importing
      pathname = lv_file
      filename = lv_name.

* Changing the file path to ERROR folder
  replace 'TBP'  in lv_file with 'ERROR' .
  concatenate lv_file '/' lv_name into lv_file.

* Write the records
  open dataset lv_file for output in text mode encoding default.
  if sy-subrc ne 0.
    message e000 with text-015.

  else.
*   Forming the header text line
    concatenate  text-h01
                 text-h02
                 text-h03
                 text-h04
                 text-h05
                 text-h06
                 text-h07
                 text-h08
                 text-h09
                 text-h10
                 text-h11
                 text-004
         into lv_data
         separated by c_comma.
    transfer lv_data to lv_file.

    clear lv_data.
*start change CR 82 modified header and seq
*   Passing the Erroneous Header data
    loop at fp_i_input_e into lwa_input_e.

      concatenate lwa_input_e-kunnr
                  lwa_input_e-vkorg
                  lwa_input_e-vtweg
                  lwa_input_e-spart
                  lwa_input_e-name1
                  lwa_input_e-kdkg1
                  lwa_input_e-kdkg2
                  lwa_input_e-kdkg3
                  lwa_input_e-kvgr1
                  lwa_input_e-kvgr2
                  lwa_input_e-kdgrp
                  lwa_input_e-err_msg
                into lv_data
             separated by c_comma.
*    move lwa_REPORT-msgtxt to lv_data.
      transfer lv_data to lv_file.
      clear lv_data.
    endloop.
*end change CR 82 modified header and seq
  endif.
endform.                    " F_MOVE_ERROR
*&---------------------------------------------------------------------*
*&      Form  F_BDC_DYNPRO
*&---------------------------------------------------------------------*
*      This is used for populating program name and screen number
*----------------------------------------------------------------------*
form f_bdc_dynpro   using fp_v_program  type bdc_prog
                         fp_v_dynpro   type bdc_dynr
                changing fp_i_bdcdata  type ty_t_bdcdata.

* Local data declaration
  data: lwa_bdcdata type bdcdata.
* Filling the BDC Data table for Program name, screen no and dyn begin
  clear lwa_bdcdata.
  lwa_bdcdata-program  = fp_v_program.
  lwa_bdcdata-dynpro   = fp_v_dynpro.
  lwa_bdcdata-dynbegin = c_true.
  append lwa_bdcdata to fp_i_bdcdata.

endform.                    " F_BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  F_BDC_FIELD
*&---------------------------------------------------------------------*
*       This subroutine is used to populate field name and values
*----------------------------------------------------------------------*
*      -->FP_V_FNAM      Field Name
*      -->FP_V_FVAL      Field Value
*      <--FP_I_BDCDATA   Populated BDC Data
*----------------------------------------------------------------------*
form f_bdc_field  using fp_v_fnam    type any
                        fp_v_fval    type any
                  changing fp_i_bdcdata type ty_t_bdcdata.

* Local data declaration
  data: lwa_bdcdata type ty_bdcdata.
* Filling the BDC Data table for Field value and Field name
  if not fp_v_fval is initial.
    clear lwa_bdcdata.
    lwa_bdcdata-fnam = fp_v_fnam.
    lwa_bdcdata-fval = fp_v_fval.
    append lwa_bdcdata to fp_i_bdcdata.
  endif.

endform.                    " F_BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  F_INSERT_BDC_SESSION
*&---------------------------------------------------------------------*
*       Inserting BDCDATA table into BDC session
*----------------------------------------------------------------------*
*      -->FP_LI_BDCDATA   BCDATA table
*      -->FP_LV_SESSION   Session Name
*      <--FP_I_REPORT[]   Report Table: Only BDC session related errors
*                         are captured in Report table. It does not
*                         track data post related error
*      <--FP_LV_SUBRC     Return Code
*----------------------------------------------------------------------*
form f_insert_bdc_session  using    fp_li_bdcdata type ty_t_bdcdata
                           changing fp_i_error_report type ty_t_input_e
                                    fp_i_succ_report type ty_t_gporoaster_info.


* Local data declaration
  data: lv_errmsg   like t100-text,
        lwa_error_report type ty_input_e,
        lv_mode    type c value 'N'.


*  Call Transaction for BDC

  call transaction c_tcode using fp_li_bdcdata mode lv_mode update 'S'
                                           messages into messtab.
  if sy-subrc is not initial.
    gv_flag_err = c_true.

*    Retrieve error messages displayed during BDC update
    loop at messtab where msgtyp = c_error.
      message id messtab-msgid type messtab-msgtyp number messtab-msgnr into lv_errmsg
           with messtab-msgv1 messtab-msgv2 messtab-msgv3 messtab-msgv4.
    endloop.


    lwa_error_report-kunnr  = wa_gporoaster_info-kunnr.
    lwa_error_report-vkorg  = wa_gporoaster_info-vkorg.
    lwa_error_report-vtweg  = wa_gporoaster_info-vtweg.
    lwa_error_report-spart  = wa_gporoaster_info-spart.
    lwa_error_report-name1  = wa_gporoaster_info-name1.
    lwa_error_report-kdkg1  = wa_gporoaster_info-kdkg1.
    lwa_error_report-kdkg2  = wa_gporoaster_info-kdkg2.
    lwa_error_report-kdkg3  = wa_gporoaster_info-kdkg3.
    lwa_error_report-kvgr1  = wa_gporoaster_info-kvgr1.
    lwa_error_report-kvgr2  = wa_gporoaster_info-kvgr2.
    lwa_error_report-kdgrp  = wa_gporoaster_info-kdgrp.
    lwa_error_report-err_msg = lv_errmsg.
    append lwa_error_report to fp_i_error_report.
    clear: lwa_error_report.

  else.
    add 1 to gv_succ_update.
    append wa_gporoaster_info to fp_i_succ_report.
  endif.
  refresh messtab.
endform.                    " F_INSERT_BDC_SESSION
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ERROR_REPORT
*&---------------------------------------------------------------------*
*       Subroutine to display error report on the screen.
*----------------------------------------------------------------------*
*      -->FP_I_REPORT  text
*----------------------------------------------------------------------*
form f_display_error_report tables fp_i_error_report type ty_t_input_e.
  perform display_error_column_headings.
  perform display_error_records.
endform.                    " F_DISPLAY_ERROR_REPORT
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_SUCCESS_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_GPOROASTER_INFO  text
*----------------------------------------------------------------------*
form f_display_success_report  tables fp_i_success_report type ty_t_gporoaster_info.
  perform display_succ_column_headings.
  perform display_success_records.
endform.                    " F_DISPLAY_SUCCESS_REPORT
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_COLUMN_HEADINGS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form display_succ_column_headings .
  skip.
  write:2 text-007 color col_positive.
  skip.
  write:2 text-008.
  format color col_heading.
  write: sy-uline.
  write:/ sy-vline,
  (15) text-h01, sy-vline,
  (09) text-h02, sy-vline,
  (18) text-h03, sy-vline,
  (08) text-h04, sy-vline,
  (40) text-h05, sy-vline,
  (24) text-h06, sy-vline,
  (23) text-h07, sy-vline,
  (19) text-h08, sy-vline,
  (10) text-h09, sy-vline,
  (06) text-h10, sy-vline,
  (49) text-h11, sy-vline,
    255  sy-vline.
  write: sy-uline.
endform.                    " DISPLAY_COLUMN_HEADINGS
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form display_success_records .
  format color col_normal.
*start change CR 82 modified header and seq
  loop at i_succ_report into wa_succ_report.
    perform f_highlight_line.
    write:/ sy-vline,
    (15) wa_succ_report-kunnr, sy-vline,
    (09) wa_succ_report-vkorg, sy-vline,
    (18) wa_succ_report-vtweg, sy-vline,
    (08) wa_succ_report-spart, sy-vline,
    (40) wa_succ_report-name1, sy-vline,
    (24) wa_succ_report-kdkg1, sy-vline,
    (23) wa_succ_report-kdkg2, sy-vline,
    (19) wa_succ_report-kdkg3, sy-vline,
    (10) wa_succ_report-kvgr1, sy-vline,
    (06) wa_succ_report-kvgr2, sy-vline,
    (49) wa_succ_report-kdgrp,255 sy-vline.
    clear: wa_succ_report.
  endloop.
  write: sy-uline(255).
  refresh: i_succ_report.
  format color col_background.
*end change CR 82 modified header and seq
endform.                    " DISPLAY_REPORT
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ERROR_COLUMN_HEADINGS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form display_error_column_headings .
  skip.
  write:2 text-009 color col_negative .
  skip.
  write:2 text-010.
  format color col_heading.
  write: sy-uline.
  write:/ sy-vline,
  (13) text-h01,
       sy-vline,
  (80) text-004,
  255 sy-vline.
  write: sy-uline.
endform.                    " DISPLAY_ERROR_COLUMN_HEADINGS
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ERROR_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form display_error_records .
  loop at i_error_report into wa_error_report.
    perform f_highlight_line.
    write:/ sy-vline,
    (13) wa_error_report-kunnr, sy-vline,
    (80) wa_error_report-err_msg, 255 sy-vline.
    clear: wa_error_report.
  endloop.
  write: sy-uline.
  refresh: i_error_report.
endform.                    " DISPLAY_ERROR_REPORT
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       Modify the selection screen based on radio button selection.
*----------------------------------------------------------------------*

form f_modify_screen .

  loop at screen .
*   Presentation Server Option is NOT chosen
    if rb_pres ne c_true.
*     Hiding Presentation Server file paths with modifidd MI3.
      if screen-group1 = c_groupmi3.
        screen-active = c_zero.
        modify screen.
      endif.
*   Presentation Server Option IS chosen
    else.  "IF rb_pres EQ c_true.
*     Disaplying Presentation Server file paths with modifidd MI3.
      if screen-group1 = c_groupmi3.
        screen-active = c_one.
        modify screen.
      endif.
    endif.
*   Application Server Option is NOT chosen
    if rb_app ne c_true.
*     Hiding 1) Application Server file Physical paths with modifid MI2
*     2) Logical Filename Radio Button with with modifid MI5
*     3) Logical Filename input with modifid MI7
      if screen-group1 = c_groupmi2
         or screen-group1 = c_groupmi5
         or screen-group1 = c_groupmi7.
        screen-active = c_zero.
        modify screen.
      endif.
*   Application Server Option IS chosen
    else.  "IF rb_app EQ c_true.
*     If Application Server Physical File Radio Button is chosen
      if rb_aphy eq c_true.
*       Dispalying Application Server Physical paths with modifid MI2
        if screen-group1 = c_groupmi2.
          screen-active = c_one.
          modify screen.
        endif.
*       Hiding Logical Filaename input with modifid MI7
        if screen-group1 = c_groupmi7.
          screen-active = c_zero.
          modify screen.
        endif.
*     If Application Server Logical File Radio Button is chosen
      else.   "IF rb_alog EQ c_true.
*       Hiding Application Server - Physical paths with modifidd MI2
        if screen-group1 = c_groupmi2.
          screen-active = c_zero.
          modify screen.
        endif.
*       Displaying Logical Filaename input with modifid MI7
        if screen-group1 = c_groupmi7.
          screen-active = c_one.
          modify screen.
        endif.
      endif.
    endif.
  endloop.
endform.                    " F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*       Retriving physical file paths from logical file name
*----------------------------------------------------------------------*
*      -->FP_P_ALOG    Logical File Name
*      <--FP_GV_FILE   Physical File Path
*----------------------------------------------------------------------*
form f_logical_to_physical  using    fp_p_alog      type pathintern
                            changing fp_gv_file     type localfile.
* Local Data Declaration
  data: li_input   type zdev_t_file_list_in,    "Local Input table
        lwa_input  type zdev_file_list_in,      "Local work area
        li_output  type zdev_t_file_list_out,   "Local Output Table
        lwa_output type zdev_file_list_out,     "Local work area
        li_error   type zdev_t_file_list_error. "Local error table

* Passing the logical file path to get the physical file path
  lwa_input-path = fp_p_alog.
  append lwa_input to li_input.
  clear lwa_input.

* Retriving all files within the directory
  call function 'ZDEV_DIRECTORY_FILE_LIST'
    exporting
      im_identifier      = c_lp_ind
      im_input           = li_input
    importing
      ex_output          = li_output
      ex_error           = li_error
    exceptions
      no_input           = 1
      invalid_identifier = 2
      no_data_found      = 3
      others             = 4.
  if sy-subrc is initial and
     li_error is initial.
*   Getting the file path
    read table li_output into lwa_output index 1.
    if sy-subrc is initial.
      concatenate lwa_output-physical_path
             lwa_output-filename
             into fp_gv_file.
    endif.
  endif.

endform.                    " F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_EXIT
*&---------------------------------------------------------------------*
*        Applying conversion exit on input record.
*----------------------------------------------------------------------*
*      <--FP_I_INPUT[]  text
*----------------------------------------------------------------------*
form f_conversion_exit  changing fp_i_input type ty_t_gporoaster_info.
* Local data declaration
  field-symbols: <lfs_input> type ty_gporoaster_info.

  loop at fp_i_input assigning <lfs_input>.
*   Conversion Exit to convert Material number into Internal Format
    perform f_cov_kdgrp changing <lfs_input>-kdgrp.
*   Conversion Exit to convert Customer number into Internal Format
    perform f_cov_kunnr changing <lfs_input>-kunnr.
  endloop.

endform.                    " F_CONVERSION_EXIT
*&---------------------------------------------------------------------*
*&       Form  F_COV_KUNNR
*&---------------------------------------------------------------------*
*       Conversion Exit to convert Customer number into Internal Format
*----------------------------------------------------------------------*
*       <--FP_V_KUNNR  Customer Number
*----------------------------------------------------------------------*
form f_cov_kunnr  changing fp_v_kunnr type kunnr.
* Customer if filled up, then applying conversion exit to transform
* input Customer number in its internal format.
  if fp_v_kunnr is not initial.
    call function 'CONVERSION_EXIT_ALPHA_INPUT'
      exporting
        input  = fp_v_kunnr
      importing
        output = fp_v_kunnr.
  endif.

endform.                    " F_COV_KUNNR
*&---------------------------------------------------------------------*
*&      Form  F_COV_KDGRP
*&---------------------------------------------------------------------*
*       Conversion Exit to convert Customer Grp into Internal Format
*----------------------------------------------------------------------*
*       <--FP_V_KUNNR  Customer Number
*----------------------------------------------------------------------*
form f_cov_kdgrp  changing  fp_v_kdgrp type kdgrp.
* Customer Grp if filled up, then applying conversion exit to transform
* input Customer number in its internal format.
  if fp_v_kdgrp is not initial.
    call function 'CONVERSION_EXIT_ALPHA_INPUT'
      exporting
        input  = fp_v_kdgrp
      importing
        output = fp_v_kdgrp.
  endif.

endform.                    " F_COV_CUSTGRP
*&---------------------------------------------------------------------*
*&      Form  F_HIGHLIGHT_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_highlight_line .

  statics: lv_flag type c.

  if lv_flag = 'X'.
    format color col_normal intensified on.
    clear lv_flag.
  else.
    format color col_normal intensified off.
    lv_flag = 'X'.
  endif.

endform.                    " F_HIGHLIGHT_LINE
