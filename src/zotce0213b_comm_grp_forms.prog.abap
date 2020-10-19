************************************************************************
* Include    :  ZOTC0213B_STORAGEBIN_TOP                               *
* TITLE      :  D2_OTC_EDD_0213_Commision Group Sales Role assignment  *
* DEVELOPER  :  Nic Lira                                               *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :    D2_OTC_EDD_0213                                      *
*----------------------------------------------------------------------*
* DESCRIPTION: Update table ZOTC_TERRIT_ASSN from tab delimited file.  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 29-Sep-2014  NLIRA   E2DK904939 INITIAL DEVELOPMENT                  *
* 23-Dec-2014 MBHATTA1 E2DK904939 Defect#2653 OTC Commission Tables to *
*                                 have Changed On Date Field always    *
*                                 populated                            *
* 28-APR-2016 SBEHERA  E2DK917651  Defect#1461: 1.Validation Customer  *
*                                    with sales area                   *
*                                  2.Validate customer not to allow an *
*                                    entry with account group ZREP     *
*&---------------------------------------------------------------------*
* 19-JUL-2016 PDEBARU E2DK917651  Defect # 1461 : Fut Issue : change  *
*                                  pointer included                    *
*&---------------------------------------------------------------------*
* 27-APR-2017 U029267 E1DK927361  Defect#2496 / INC0322445 :           *
*                                 1)Change pointer to be replaced by   *
*                                    BD12 call program.                *
*                                 2)Technical change to lock the       *
*                                   'Created on/Created by' flds on    *
*                                   Commission & Territory tab.        *
*                                 3)Territories duplicating incorrectly*
*                                   in the OTC territory tables in     *
*                                   T-Code ZOTC_MAINT_TERRASSN         *
*                                   (Old Def- 2210).                   *
*                                 4)Enhance t-code:ZOTC_MAINT_TERRASSN *
*                                   to be able to restrict to DISPLAY  *
*                                   only (Old Defect: 2209).           *
*                                 5)In the Display session of T-Code   *
*                                   ZOTC_MAINT_TERRASSN we can only see*
*                                  Canada sales org 1020.(Old Def-2211)*
*&---------------------------------------------------------------------*
* 27-Jul-2017 U029267 E1DK927361  Defect#2496/ INC0322445 : FUT issue: *
*                                 Date format validation missing.      *
*&---------------------------------------------------------------------*
* 02-Aug-2017 U029267 E1DK927361  Defect#2496_Part2 : FUT issue:       *
*                                 Authorization check added for        *
*                                 updating table.                      *
*&---------------------------------------------------------------------*
*18-SEP-2017 amangal E1DK930689  D3R2 Changes
*                                1. Allow mass update of date fields in*
*                                   Maintenance transaction            *
*                                2. Allow Load from AL11 with effective*
*                                   dates populated and properly       *
*                                   formatted                          *
*                                3.	Control the sending of IDoc on     *
*                                   request                            *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

*&  Include           ZOTCE0213B_COMM_GRP_FORMS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_EXTENSION
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  f_display_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_display_alv.
  PERFORM f_build_fieldcatalog.
  PERFORM f_build_layout.
  PERFORM f_build_events.
  PERFORM f_build_print_params.
  PERFORM f_display_alv_report.
ENDFORM. "f_display_alv

*&---------------------------------------------------------------------*
*&      Form  f_build_fieldcatalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_build_fieldcatalog.
  i_fieldcatalog-fieldname   = 'DATA'.
*  i_fieldcatalog-seltext_m   = 'Purchase Order'.
  i_fieldcatalog-col_pos     = 0.
  i_fieldcatalog-outputlen   = 80.
*  i_fieldcatalog-emphasize   = 'X'.
  i_fieldcatalog-key         = 'X'.
*  i_fieldcatalog-do_sum      = 'X'.
*  i_fieldcatalog-no_zero     = 'X'.
  APPEND i_fieldcatalog TO i_fieldcatalog.
  CLEAR  i_fieldcatalog.

ENDFORM. " f_build_fieldcatalog

*&---------------------------------------------------------------------*
*&      Form  f_build_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_build_layout.
  i_layout-no_input          = 'X'.
*  gd_layout-colwidth_optimize = 'X'.
*  gd_layout-totals_text       = 'Totals'(201).
*  gd_layout-totals_only        = 'X'.
*  gd_layout-f2code            = 'DISP'.  "Sets fcode for when double
*                                         "click(press f2)
*  gd_layout-zebra             = 'X'.
*  gd_layout-group_change_edit = 'X'.
*  gd_layout-header_text       = 'helllllo'.
ENDFORM. " f_build_layout

*&---------------------------------------------------------------------*
*&      Form  f_build_events
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_build_events.
  DATA: wa_event TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = i_events[].
  READ TABLE i_events WITH KEY name =  slis_ev_end_of_page
                           INTO wa_event.
  IF sy-subrc = 0.
    MOVE 'F_END_OF_PAGE' TO wa_event-form.
    APPEND wa_event TO i_events.
  ENDIF. " IF sy-subrc = 0

  READ TABLE i_events WITH KEY name =  slis_ev_end_of_list
                         INTO wa_event.
  IF sy-subrc = 0.
    MOVE 'F_END_OF_LIST' TO wa_event-form.
    APPEND wa_event TO i_events.
  ENDIF. " IF sy-subrc = 0
ENDFORM. " f_build_events

*&---------------------------------------------------------------------*
*&      Form  f_build_print_params
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_build_print_params.
  i_prntparams-reserve_lines = '3'. "Lines reserved for footer
  i_prntparams-no_coverpage = 'X'.
ENDFORM. " f_build_print_params

*&---------------------------------------------------------------------*
*&      Form  f_display_alv_report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_display_alv_report.
  gv_repid = sy-repid.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = gv_repid
      i_callback_top_of_page  = 'F_TOP_OF_PAGE2' "see FORM
      i_callback_user_command = 'USER_COMMAND'
*     i_grid_title            = outtext
      is_layout               = i_layout
      it_fieldcat             = i_fieldcatalog[]
*     it_special_groups       = gd_tabgroup
      it_events               = i_events
      is_print                = i_prntparams
      i_save                  = 'X'
*     is_variant              = z_template
    TABLES
      t_outtab                = i_display_data
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF. " IF sy-subrc <> 0
ENDFORM. " f_display_alv_report

*&---------------------------------------------------------------------*
*&      Form  top-of-page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_top_of_page2.
*ALV Header declarations
  DATA: li_header TYPE slis_t_listheader,
        wa_header TYPE slis_listheader,
        wa_line TYPE slis_entry,
        lv_lines TYPE i,      " Lines of type Integers
        lv_linesc(10) TYPE c. " Linesc(10) of type Character

* Title
  wa_header-typ  = 'H'.

  wa_header-info = 'Territory Assignment Load Report'(036).
  APPEND wa_header TO li_header.
  CLEAR wa_header.

* Date
  wa_header-typ  = 'S'.
  wa_header-key = 'Date: '(037).
  CONCATENATE  sy-datum+6(2) '.'
               sy-datum+4(2) '.'
               sy-datum(4) INTO wa_header-info. "todays date
  APPEND wa_header TO li_header.
  CLEAR: wa_header.

* Total number of records loaded
  lv_linesc = gv_recs_loaded.
  CONCATENATE 'Total number of records loaded: '(038) lv_linesc
                    INTO wa_line SEPARATED BY space.
  wa_header-typ  = 'A'.
  wa_header-info = wa_line.
  APPEND wa_header TO li_header.
  CLEAR: wa_header, wa_line.

* Total number of errored records
  lv_linesc = gv_error_line.
  CONCATENATE 'Total number of errored records: '(039) lv_linesc
                    INTO wa_line SEPARATED BY space.
  wa_header-typ  = 'A'.
  wa_header-info = wa_line.
  APPEND wa_header TO li_header.
  CLEAR: wa_header, wa_line.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = li_header.
*            i_logo             = 'Z_LOGO'.
ENDFORM. "top-of-page

*&---------------------------------------------------------------------*
*&      Form  f_user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM f_user_command USING fp_ucomm TYPE sy-ucomm " Function code that PAI triggered
                  fp_selfield TYPE slis_selfield.

* Check function code
  CASE fp_ucomm.
    WHEN '&IC1'.
*   Check field clicked on within ALVgrid report

  ENDCASE.
ENDFORM. "f_user_command

*&---------------------------------------------------------------------*
*&      Form  F_END_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_end_of_page.

  WRITE: sy-uline(50).
  SKIP.
  WRITE:/40 'Page:'(041), sy-pagno .
ENDFORM. "F_END_OF_PAGE


*&---------------------------------------------------------------------*
*&      Form  F_END_OF_LIST
*&---------------------------------------------------------------------*
FORM f_end_of_list.

  SKIP.
  WRITE:/40 'Page:'(041), sy-pagno .
ENDFORM. "F_END_OF_LIST

*----------------------------------------------------------------------*
* Form F_CHECK_FILE_EXTENSION
*       Check the file extension whether CSV or not .
*----------------------------------------------------------------------*
FORM f_check_extension  USING    fp_p_fileap TYPE localfile. " Local file for upload/download
  IF fp_p_fileap IS NOT INITIAL.
    CLEAR gv_extn.
*   Getting the file extension
    PERFORM f_file_extn_check USING fp_p_fileap
                           CHANGING gv_extn.
    IF gv_extn <> c_txt
*Begin of D3_OTC_EDD_0213 D3R2
      AND gv_extn <> c_csv.
*End of D3_OTC_EDD_0213 D3R2
      MESSAGE e000(zotc_msg) WITH 'Please provide TXT file'(001). " & & & &
    ENDIF. " IF gv_extn <> c_txt
  ENDIF. " IF fp_p_fileap IS NOT INITIAL
ENDFORM. " F_CHECK_EXTENSION

*&---------------------------------------------------------------------*
*&      Form  f_get_filename
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_filename.
  DATA: li_tab  TYPE filetable,   " File data
        lwa_file TYPE file_table, " Work area to read file data
        lv_subrc TYPE i,          " SY subrc check
        lv_dir TYPE string,       " File directory name
        lv_title TYPE string.     " Window title
  lv_title = 'File Open'(017).
  lv_dir = p_filepr. "Directory
*Adds a GUI-Supported Feature
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title      = lv_title
      initial_directory = lv_dir
    CHANGING
      file_table        = li_tab
      rc                = lv_subrc.
  IF li_tab IS NOT INITIAL.
    READ TABLE li_tab INTO lwa_file INDEX 1.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE i000 WITH 'File is empty'(035).
    ENDIF. " IF sy-subrc IS NOT INITIAL
  ENDIF. " IF li_tab IS NOT INITIAL
  p_filepr = lwa_file.
  CLEAR : lwa_file,
          li_tab.
ENDFORM. " GET_FILENAME
*&---------------------------------------------------------------------*
*&      Form  F_MOVEFILE
*&---------------------------------------------------------------------*
*       Move file to done folder.
*----------------------------------------------------------------------*
FORM f_movefile  USING  fp_sourcefile TYPE localfile. " Local file for upload/download
  DATA: lv_file TYPE localfile, " Local file for upload/download
                                " local variable declaration of type localfile
        lv_name TYPE localfile. " Local file for upload/download
  " local variable declaration of type localfile.
  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_sourcefile
    IMPORTING
      pathname = lv_file "gv_file
      filename = lv_name.
* First move the file to the Done folder
  REPLACE c_tbp_fld
          IN lv_file
          WITH c_done_fld .
  CONCATENATE lv_file lv_name
                INTO lv_file.
*  Move the file to the specified folder.
  PERFORM f_file_move  USING fp_sourcefile
                             lv_file
                       CHANGING gv_return.
  IF gv_return IS INITIAL.
*   Exporting the archived file name in memory id 'ARCH_1'.
    gv_archive_gl_1 = lv_file.
  ELSE. " ELSE -> IF gv_return IS INITIAL
    MESSAGE i000 WITH 'The file has not been moved to done folder'(040).
  ENDIF. " IF gv_return IS INITIAL
ENDFORM. " F_MOVEFILE
*&---------------------------------------------------------------------*
*&      Form  f_upload_filedata_ap
*&---------------------------------------------------------------------*
*       Processing of file data form application server.
*----------------------------------------------------------------------*
FORM f_upload_filedata_ap.
  DATA : lv_reihf TYPE char6, "Sort field for Storage bin (TO items, picking)
         lv_sorlp TYPE char6. "Sort field for Storage bin (cross-line storage)
  DATA:  lv_filedata type text60.

** Processing of File data.
  IF p_fileap IS NOT INITIAL.
    OPEN DATASET p_fileap IN TEXT MODE ENCODING DEFAULT FOR INPUT. " Set as Ready for Input
*If file open dataset is successful then proceed for reading else
*come out.
    IF sy-subrc = 0.
*Loop through the dataset using do....enddo loop
      DO.
*Read the dataset and place the records line by line in the work area
*for the internal table.
**Begin of R2
*        READ DATASET p_fileap INTO wa_filedata.
        READ DATASET p_fileap INTO lv_filedata.
**End of R2
*End of file is reached, so sy-subrc will be greater than zero and
*So come out of the loop
        IF sy-subrc <> 0.
          CLOSE DATASET p_fileap.
          EXIT.
        ELSE. " ELSE -> IF sy-subrc <> 0
*Data been read and hence append into the internal table
**Begin of R2
*          SPLIT wa_filedata AT c_delimiter INTO
          SPLIT lv_filedata AT c_delimiter INTO
**End of R2
                wa_territory_assn-vkorg
                wa_territory_assn-vtweg
                wa_territory_assn-spart
                wa_territory_assn-kunnr
                wa_territory_assn-territory_id
                wa_territory_assn-partrole

*Begin of D3_OTC_EDD_0213 D3R2
                wa_territory_assn-effective_from
                wa_territory_assn-effective_to.
*                CLEAR lv_date.
*                lv_date-year = wa_territory_assn-effective_from(4).
*                lv_date-mmdd = wa_territory_assn-effective_from+4(4).
*                wa_territory_assn-effective_from = lv_date.
*                CLEAR lv_date.
*                lv_date-year = wa_territory_assn-effective_to(4).
*                lv_date-mmdd = wa_territory_assn-effective_to+4(4).
*                wa_territory_assn-effective_to = lv_date.
*End of D3_OTC_EDD_0213 D3R2

          PERFORM f_zero_fill.
          APPEND wa_territory_assn TO i_territory_assn.
*Now clear the work area
        ENDIF. " IF sy-subrc <> 0
      ENDDO.
    ELSE. " ELSE -> IF sy-subrc = 0
      MESSAGE i000(zotc_msg) WITH 'Not able to open the dataset'(009). " & & & &
      LEAVE LIST-PROCESSING.
    ENDIF. " IF sy-subrc = 0
    DELETE i_territory_assn INDEX 1.
    IF i_territory_assn[] IS INITIAL.
      MESSAGE i000(zotc_msg) WITH 'File is empty'(035). " & & & &
      LEAVE LIST-PROCESSING.
    ENDIF. " IF i_territory_assn[] IS INITIAL
* Delimiter is ';'.
  ELSE. " ELSE -> IF p_fileap IS NOT INITIAL
    MESSAGE i000(zotc_msg) WITH 'Please give the file path'(034). " & & & &
    LEAVE LIST-PROCESSING.
  ENDIF. " IF p_fileap IS NOT INITIAL
ENDFORM. " f_upload_filedata_ap
*&---------------------------------------------------------------------*
*&      Form  f_upload_filedata_ps
*&---------------------------------------------------------------------*
*       Selection of data from presentation server
*----------------------------------------------------------------------*
FORM f_upload_filedata_ps.
  DATA : lv_filename    TYPE string. " File  export parameter

  IF p_filepr IS INITIAL.
    MESSAGE i000(zotc_msg) WITH 'Please give the file path'(034). " & & & &
    LEAVE LIST-PROCESSING.
  ENDIF. " IF p_filepr IS INITIAL
  lv_filename = p_filepr.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_filename
      filetype                = c_filetype
      has_field_separator     = 'X'
    CHANGING
      data_tab                = i_filedata
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
  IF sy-subrc <> 0.
    MESSAGE i000(zotc_msg) WITH 'Error while reading the file'(010). "Error while reading the file.
  ENDIF. " IF sy-subrc <> 0
  IF i_filedata[] IS NOT INITIAL.
    DELETE i_filedata INDEX 1.

    IF i_filedata[] IS INITIAL.
      MESSAGE i000(zotc_msg) WITH 'File is empty'(035). " & & & &
      LEAVE LIST-PROCESSING.
    ENDIF. " IF i_filedata[] IS INITIAL
    DATA: BEGIN OF lv_date,
            mmdd(4),
            year(4),
          END OF lv_date.
    LOOP AT i_filedata INTO wa_filedata.
      MOVE-CORRESPONDING wa_filedata TO wa_territory_assn.
*      CLEAR lv_date.
*      lv_date-year = wa_territory_assn-effective_from(4).
*      lv_date-mmdd = wa_territory_assn-effective_from+4(4).
*      wa_territory_assn-effective_from = lv_date.
*      CLEAR lv_date.
*      lv_date-year = wa_territory_assn-effective_to(4).
*      lv_date-mmdd = wa_territory_assn-effective_to+4(4).
*      wa_territory_assn-effective_to = lv_date.
      PERFORM f_zero_fill.
      APPEND wa_territory_assn TO i_territory_assn.
      CLEAR wa_territory_assn.
    ENDLOOP. " LOOP AT i_filedata INTO wa_filedata
  ELSE. " ELSE -> IF i_filedata[] IS NOT INITIAL
    MESSAGE i000(zotc_msg) WITH 'No File data to process'(007). " & & & &
    LEAVE LIST-PROCESSING.
  ENDIF. " IF i_filedata[] IS NOT INITIAL

ENDFORM. "f_upload_filedata_ps
*&---------------------------------------------------------------------*
*&      Form  SELECT_FROM_PRSERVERORAPSERVER
*&---------------------------------------------------------------------*
*       Decide weather file to be selected from presentation server
*       Application server
*----------------------------------------------------------------------*
FORM f_select_from_prsoraps.
  IF rb_pr EQ abap_true.
* To activate the screen for Transportation lanes upd only
    LOOP AT SCREEN.
      IF screen-group1 EQ c_group1. "'APS'.
        screen-active = 0.
        screen-input  = 0.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 EQ c_group1
    ENDLOOP. " LOOP AT SCREEN
  ELSEIF rb_ap EQ abap_true.
* To activate the screen for Means of transport upd only
    LOOP AT SCREEN.
      IF screen-group1 EQ c_group2. "'PRS'.
        screen-active = 0.
        screen-input  = 0.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 EQ c_group2
    ENDLOOP. " LOOP AT SCREEN
  ENDIF. " IF rb_pr EQ abap_true
ENDFORM. " SELECT_FROM_PRSERVERORAPSERVER
*&---------------------------------------------------------------------*
*&      Form  F_WRITE_ERROR_FILE
*&---------------------------------------------------------------------*
*       Write the error records.
*----------------------------------------------------------------------*
FORM f_write_error_file.
  DATA: lv_file TYPE localfile,   " Local file for upload/download
                                  " local variable declaration of type localfile
          lv_name TYPE localfile, "File name
          lv_data TYPE localfile. "File data
  FIELD-SYMBOLS : <lfs_error> TYPE ty_filedata.

  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = p_fileap
    IMPORTING
      pathname = lv_file
      filename = lv_name.
* Get the Error File Folder
  REPLACE c_tbp_fld
  IN lv_file
  WITH c_error_fld.
* The file name
  CONCATENATE lv_file lv_name
  INTO lv_file.

  gv_header = 'Errors'(024).
  NEW-LINE.
* Write the records
  OPEN DATASET lv_file FOR OUTPUT " Output type
                       IN TEXT MODE
                       ENCODING DEFAULT.
  IF sy-subrc NE 0.
    MESSAGE i000(zotc_msg) WITH 'Error Folder can not be opened.'(020). " & & & &
    LEAVE LIST-PROCESSING. " exit the program
  ENDIF. " IF sy-subrc NE 0
  TRANSFER gv_header TO lv_file.
  LOOP AT i_ebindata ASSIGNING <lfs_error>.
    CLEAR lv_data.
    CONCATENATE <lfs_error>-vkorg
                <lfs_error>-vtweg
                <lfs_error>-spart
                <lfs_error>-kunnr
                <lfs_error>-territory_id
                <lfs_error>-partrole
                INTO lv_data
                SEPARATED BY c_tab.
    TRANSFER lv_data TO lv_file.
  ENDLOOP. " LOOP AT i_ebindata ASSIGNING <lfs_error>
  CLOSE DATASET lv_file.

ENDFORM. " F_WRITE_ERROR_FILE
*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_INBOUND_FILE
*&---------------------------------------------------------------------*
* Purpose: Process the input data. Validate the data, create error lines
*         if necessary, save good records, update the custom table at
*         end of the process.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_inbound_file .
  DATA: lv_line(7). "Local variable to hold the line count in display mode
  DATA: li_terrassn_tmp  TYPE STANDARD TABLE OF zotc_territ_assn. " Comm Group: Territory Assignment
  DATA: BEGIN OF li_cust OCCURS 0, "Local table to hold the customer numbers and remove duplicates
          kunnr TYPE kna1-kunnr,   " Customer Number
        END OF li_cust.
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  TYPES: BEGIN OF lty_customer,
         kunnr TYPE kunnr, " Customer number
         END OF lty_customer.
  DATA: li_knvv TYPE STANDARD TABLE OF lty_customer INITIAL SIZE 0,
        li_enh_status TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Enhancement Status
        lv_flag TYPE flag,                                                   " General Flag
        lv_ktokd TYPE ktokd,                                                 " Flag
        li_kna1 TYPE STANDARD TABLE OF lty_customer INITIAL SIZE 0.
* Field Symbol Declaration
  FIELD-SYMBOLS: <lfs_enh_status> TYPE zdev_enh_status. " Enhancement Status
  CONSTANTS :
    lc_enh_no TYPE z_enhancement VALUE 'D2_OTC_EDD_0213', " Enhancement No
    lc_ktokd  TYPE z_criteria    VALUE 'KTOKD',           " Enh. Criteria
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461  by SBEHERA

* ---> Begin of Insert for D3_OTC_EDD_0213_Defect#2496 by u029267 on 27-Apr-2017
  lc_records TYPE z_criteria    VALUE 'RECORDS'. " Enh. Criteria
* <--- End of Insert for D3_OTC_EDD_0213_Defect#2496 by u029267 on 27-Apr-2017

* Prepare to load KNA1 entries into internal table for Check Table checking
* Duplicate the inbound data
  LOOP AT i_territory_assn INTO wa_territory_assn.
    li_cust-kunnr = wa_territory_assn-kunnr.
    APPEND li_cust.
    li_cust-kunnr = wa_territory_assn-territory_id.
    APPEND li_cust.
  ENDLOOP. " LOOP AT i_territory_assn INTO wa_territory_assn

* Sort duplicate data by KUNNR
  SORT li_cust BY kunnr.
* Delete duplicates
  DELETE ADJACENT DUPLICATES FROM li_cust COMPARING kunnr.

* Load KNA1 entries into internal table
  SELECT kunnr FROM kna1 INTO TABLE i_customers
    FOR ALL ENTRIES IN li_cust
    WHERE kunnr = li_cust-kunnr.

  IF sy-subrc = 0.
* Sort the customers table (only has one entry which is KUNNR)
    SORT i_customers BY kunnr.
  ENDIF. " IF sy-subrc = 0

  DATA: li_tvko TYPE STANDARD TABLE OF tvko, " Organizational Unit: Sales Organizations
        wa_tvko TYPE tvko.                   " Organizational Unit: Sales Organizations

  SELECT * FROM tvko INTO TABLE li_tvko.

  IF sy-subrc = 0.
    SORT li_tvko BY vkorg.
  ENDIF. " IF sy-subrc = 0

  li_terrassn_tmp[] = i_territory_assn.
  SORT li_terrassn_tmp BY vtweg.
  DELETE ADJACENT DUPLICATES FROM li_terrassn_tmp COMPARING vtweg.

  IF li_terrassn_tmp[] IS NOT INITIAL.

    SELECT vtweg " Distribution Channel
    INTO TABLE i_tvtw
    FROM tvtw    " Organizational Unit: Distribution Channels
    FOR ALL ENTRIES IN li_terrassn_tmp
    WHERE vtweg = li_terrassn_tmp-vtweg.

    IF sy-subrc IS INITIAL.
      SORT i_tvtw BY vtweg.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_terrassn_tmp[] IS NOT INITIAL


  li_terrassn_tmp[] = i_territory_assn.
  SORT li_terrassn_tmp BY spart.
  DELETE ADJACENT DUPLICATES FROM li_terrassn_tmp COMPARING spart.

  IF li_terrassn_tmp[] IS NOT INITIAL.
    SELECT spart " Division
    INTO TABLE i_tspa
    FROM tspa    " Organizational Unit: Sales Divisions
    FOR ALL ENTRIES IN li_terrassn_tmp
    WHERE spart = li_terrassn_tmp-spart.

    IF sy-subrc IS INITIAL.
      SORT i_tspa BY spart.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_terrassn_tmp[] IS NOT INITIAL
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
* Get constants from EMI tools
* Call FM to retrieve Enhancement Status
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_no
    TABLES
      tt_enh_status     = li_enh_status.

*&     If the value is space, then do not proceed further for this
*&     enhancement
* Delete the EMI records where the status is not active
  DELETE li_enh_status WHERE active EQ abap_false.

* Populate Values of Criteria KTOKD
  IF li_enh_status IS NOT INITIAL.
    READ TABLE li_enh_status ASSIGNING <lfs_enh_status> WITH KEY criteria = lc_ktokd.
    IF sy-subrc = 0 .
      lv_flag = abap_true.
      lv_ktokd = <lfs_enh_status>-sel_low.
    ENDIF. " IF sy-subrc = 0

* ---> Begin of Insert for D3_OTC_EDD_0213_Defect#2496 by u029267 on 27-Apr-2017
    READ TABLE li_enh_status ASSIGNING <lfs_enh_status> WITH KEY criteria = lc_records.
    IF sy-subrc = 0 .
      gv_records = <lfs_enh_status>-sel_low.
    ELSE. " ELSE -> IF sy-subrc = 0
      gv_records = 0.
    ENDIF. " IF sy-subrc = 0
* <--- End of Insert for D3_OTC_EDD_0213_Defect#2496 by u029267 on 27-Apr-2017

  ENDIF. " IF li_enh_status IS NOT INITIAL

* Get Data from KNVV table to validate customer with sales area
  REFRESH li_terrassn_tmp.
  li_terrassn_tmp[] = i_territory_assn.
  SORT li_terrassn_tmp BY kunnr vkorg vtweg spart.
  DELETE ADJACENT DUPLICATES FROM li_terrassn_tmp
                             COMPARING kunnr vkorg vtweg spart.
  IF li_terrassn_tmp[] IS NOT INITIAL.
    SELECT kunnr " Customer
      FROM knvv  " Customer Master Sales Data
      INTO TABLE li_knvv
      FOR ALL ENTRIES IN li_terrassn_tmp
      WHERE kunnr = li_terrassn_tmp-kunnr
          AND vkorg = li_terrassn_tmp-vkorg
          AND vtweg = li_terrassn_tmp-vtweg
          AND spart = li_terrassn_tmp-spart.
    IF sy-subrc = 0.
      SORT li_knvv BY kunnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_terrassn_tmp[] IS NOT INITIAL
* Get data from table KNA1 with account group ZREP
  REFRESH li_terrassn_tmp.
  li_terrassn_tmp[] = i_territory_assn.
  SORT li_terrassn_tmp BY kunnr .
  DELETE ADJACENT DUPLICATES FROM li_terrassn_tmp
                             COMPARING kunnr .
  IF li_terrassn_tmp[] IS NOT INITIAL AND lv_flag IS NOT INITIAL.
    SELECT kunnr " Customer
      FROM kna1  " Customer Master Sales Data
      INTO TABLE li_kna1
      FOR ALL ENTRIES IN li_terrassn_tmp
      WHERE kunnr = li_terrassn_tmp-kunnr
          AND ktokd = lv_ktokd.
    IF sy-subrc = 0.
      SORT li_kna1 BY kunnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_terrassn_tmp[] IS NOT INITIAL AND lv_flag IS NOT INITIAL
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461  by SBEHERA
  li_terrassn_tmp[] = i_territory_assn.
  SORT li_terrassn_tmp BY partrole.
  DELETE ADJACENT DUPLICATES FROM li_terrassn_tmp COMPARING partrole.

  IF li_terrassn_tmp[] IS NOT INITIAL.
    SELECT partrole     " Partner Role
    INTO TABLE i_partrole
    FROM zotc_part_role " Comm Group: Partner Roles
    FOR ALL ENTRIES IN li_terrassn_tmp
    WHERE partrole = li_terrassn_tmp-partrole.

    IF sy-subrc IS INITIAL.
      SORT i_partrole BY partrole.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_terrassn_tmp[] IS NOT INITIAL


* Process the input data
  LOOP AT i_territory_assn INTO wa_territory_assn.
*   Set default values
    MOVE sy-uname TO wa_territory_assn-zz_created_by.
    MOVE sy-datum TO wa_territory_assn-zz_created_on.
    MOVE sy-uzeit TO wa_territory_assn-zz_created_at.
*&-- Begin of Insert for D2_OTC_EDD_0213 by MBHATTA1 Defect#2653
    MOVE sy-uname TO wa_territory_assn-zz_changed_by.
    MOVE sy-datum TO wa_territory_assn-zz_changed_on.
    MOVE sy-uzeit TO wa_territory_assn-zz_changed_at.
*&-- End of Insert for D2_OTC_EDD_0213 by MBHATTA1 Defect#2653
*    MOVE sy-datum TO wa_territory_assn-effective_from.
*    MOVE c_effective_to TO wa_territory_assn-effective_to.


    CLEAR gv_flag. "Indicates an error has occurred
    CLEAR wa_errors. "Work area for error messages
    REFRESH i_errors. "Table that holds error messages

*&-- Begin of Insert for D3_OTC_EDD_0213_Defect#2496_Part2 by U029267 on 27-Jul-2017
*    Validate Effective_from date
    IF wa_territory_assn-effective_from IS NOT INITIAL.
      CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
        EXPORTING
          date                      = wa_territory_assn-effective_from
        EXCEPTIONS
          plausibility_check_failed = 1
          OTHERS                    = 2.
      IF sy-subrc <> 0.
        CONCATENATE 'Incorrect Date format in EFFECTIVE_FROM'(002)
        wa_territory_assn-effective_from INTO wa_errors SEPARATED BY space.
        APPEND wa_errors TO i_errors.
        gv_flag = 1.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF wa_territory_assn-effective_from IS NOT INITIAL
*    Validate Effective_to date
    IF wa_territory_assn-effective_to IS NOT INITIAL.
      CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
        EXPORTING
          date                      = wa_territory_assn-effective_to
        EXCEPTIONS
          plausibility_check_failed = 1
          OTHERS                    = 2.
      IF sy-subrc <> 0.
        CLEAR wa_errors.
        CONCATENATE 'Incorrect Date format in EFFECTIVE_TO'(003)
        wa_territory_assn-effective_to INTO wa_errors SEPARATED BY space.
        APPEND wa_errors TO i_errors.
        gv_flag = 1.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF wa_territory_assn-effective_to IS NOT INITIAL
*&-- End of Insert for D3_OTC_EDD_0213_Defect#2496 by U029267_Part2 on 27-Jul-2017

*   Check if Sales Org exists in check table
    READ TABLE li_tvko WITH KEY vkorg = wa_territory_assn-vkorg TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      CLEAR  wa_errors.
      CONCATENATE 'VKORG - no entry in check table TVKO for '(010) ' ' wa_territory_assn-vkorg INTO wa_errors RESPECTING BLANKS.
      APPEND wa_errors TO i_errors.
      gv_flag = 1.
    ENDIF. " IF sy-subrc <> 0
*   Check if Distribution Channel exists in check table
    READ TABLE i_tvtw INTO wa_tvtw WITH KEY vtweg = wa_territory_assn-vtweg
                                            BINARY SEARCH.
    IF sy-subrc <> 0.
      CLEAR  wa_errors.
      CONCATENATE 'VTWEG - no entry in check table TVTW for '(011) ' ' wa_territory_assn-vtweg INTO wa_errors RESPECTING BLANKS.
      APPEND wa_errors TO i_errors.
      gv_flag = 1.
    ENDIF. " IF sy-subrc <> 0
*   Check if Division exists in check table
    READ TABLE i_tspa INTO wa_tspa WITH KEY spart = wa_territory_assn-spart
                                            BINARY SEARCH.
    IF sy-subrc <> 0.
      CLEAR  wa_errors.
      CONCATENATE 'SPART - no entry in check table TSPA for '(012) ' ' wa_territory_assn-spart INTO wa_errors RESPECTING BLANKS.
      APPEND wa_errors TO i_errors.
      gv_flag = 1.
    ENDIF. " IF sy-subrc <> 0
*   Check if Customer exists in check table
    READ TABLE i_customers INTO wa_customers WITH KEY kunnr = wa_territory_assn-kunnr
      BINARY SEARCH.
    IF sy-subrc <> 0.
      CLEAR  wa_errors.
      CONCATENATE 'KUNNR - no entry in check table KNA1 for '(013) ' ' wa_territory_assn-kunnr INTO wa_errors RESPECTING BLANKS.
      APPEND wa_errors TO i_errors.
      gv_flag = 1.
    ENDIF. " IF sy-subrc <> 0
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
*   Check if Customer exists in table knvv
    READ TABLE li_knvv WITH KEY kunnr = wa_territory_assn-kunnr BINARY SEARCH
                                                                TRANSPORTING NO FIELDS
                                                                .
    IF sy-subrc <> 0.
      CLEAR  wa_errors.
      CONCATENATE 'KUNNR - no entry in table KNVV for '(021) ' ' wa_territory_assn-kunnr INTO wa_errors RESPECTING BLANKS.
      APPEND wa_errors TO i_errors.
      gv_flag = 1.
    ENDIF. " IF sy-subrc <> 0
*   Check if Customer with account group ZREP
    READ TABLE li_kna1 WITH KEY kunnr = wa_territory_assn-kunnr BINARY SEARCH
                                                                TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      CLEAR  wa_errors.
      CONCATENATE 'KUNNR - entry with Account Group'(022) ' ' lv_ktokd ' ' wa_territory_assn-kunnr INTO wa_errors RESPECTING BLANKS.
      APPEND wa_errors TO i_errors.
      gv_flag = 1.
    ENDIF. " IF sy-subrc = 0
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461  by SBEHERA
*   Check if Territory Id exists in check table
    READ TABLE i_customers INTO wa_customers WITH KEY kunnr = wa_territory_assn-territory_id
      BINARY SEARCH.
    IF sy-subrc <> 0.
      CLEAR  wa_errors.
      CONCATENATE 'TERRITORY_ID - no entry in check table KNA1 for '(014) ' ' wa_territory_assn-territory_id INTO wa_errors RESPECTING BLANKS.
      APPEND wa_errors TO i_errors.
      gv_flag = 1.
    ENDIF. " IF sy-subrc <> 0
*   Check if Partner Role exists in check table
    READ TABLE i_partrole INTO wa_partrole WITH KEY partrole =  wa_territory_assn-partrole
                                                    BINARY SEARCH.
    IF sy-subrc <> 0.
      CLEAR  wa_errors.
      CONCATENATE 'PARTROLE - no entry in check table ZOTC_PART_ROLE for '(015) ' ' wa_territory_assn-partrole INTO wa_errors RESPECTING BLANKS.
      APPEND wa_errors TO i_errors.
      gv_flag = 1.
    ENDIF. " IF sy-subrc <> 0

    IF gv_flag <> 0. "If not zero, then error(s) has/have occurred
      ADD 1 TO gv_error_line. "Increment the error count
      CLEAR wa_display_data. "Work area to build the line to be displayed on the report
      WRITE: gv_error_line LEFT-JUSTIFIED NO-ZERO TO lv_line.
*     Display line consists of the current record number + the actual record value
      CONCATENATE lv_line ' ' wa_territory_assn INTO wa_display_data RESPECTING BLANKS.
*     Append the display line to the display table (used in the ALV function module)
      APPEND wa_display_data TO i_display_data.
      LOOP AT i_errors INTO wa_errors.
        CLEAR wa_display_data.
        wa_display_data = wa_errors.
        APPEND wa_display_data TO i_display_data.
      ENDLOOP. " LOOP AT i_errors INTO wa_errors
      CLEAR wa_display_data.
*     Add a separator line to the error report
      APPEND wa_display_data TO i_display_data.
    ELSE. " ELSE -> IF gv_flag <> 0
*     The record had no errors
      ADD 1 TO gv_recs_loaded. "Increment good record counter
      APPEND wa_territory_assn TO i_territory_assn3. "Append to good records table
    ENDIF. " IF gv_flag <> 0
  ENDLOOP. " LOOP AT i_territory_assn INTO wa_territory_assn


  IF i_territory_assn3[] IS NOT INITIAL.

* Begin of Defect 1461

*&--As we are fetching all entries from 'Z' table select * is used to get
*&--the old values from table itself because by this time new values will
*&--not be updated in custom table
    SELECT *
      FROM zotc_territ_assn " Comm Group: Territory Assignment
      INTO TABLE i_oldvalues
      FOR ALL ENTRIES IN i_territory_assn3
      WHERE vkorg EQ i_territory_assn3-vkorg
        AND vtweg EQ i_territory_assn3-vtweg
        AND spart EQ i_territory_assn3-spart
        AND kunnr EQ i_territory_assn3-kunnr
        AND territory_id EQ i_territory_assn3-territory_id
        AND partrole     EQ i_territory_assn3-partrole.

    IF sy-subrc EQ 0.
      SORT i_oldvalues BY vkorg vtweg spart kunnr territory_id partrole effective_from effective_to.
    ENDIF. " IF sy-subrc EQ 0

* End   of Defect 1461

    CALL FUNCTION 'ENQUEUE_EZOTC_TERR_ASSN'
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.

    IF sy-subrc = 1.
      MESSAGE e000 WITH text-e07 DISPLAY LIKE 'E'.
    ELSEIF sy-subrc = 2.
      MESSAGE e000 WITH text-e08 DISPLAY LIKE 'E'.
    ELSEIF sy-subrc = 3.
      MESSAGE e000 WITH text-e09 DISPLAY LIKE 'E'.
    ELSE. " ELSE -> IF sy-subrc = 1

* ---> Begin of Insert for D3_OTC_EDD_0213_Defect#2496 by u029267 on 27-Apr-2017
      IF  i_oldvalues[] IS NOT INITIAL.
        DELETE zotc_territ_assn FROM TABLE i_oldvalues.
      ENDIF. " IF i_oldvalues[] IS NOT INITIAL
* <--- End of Insert for D3_OTC_EDD_0213_Defect#2496 by u029267 on 27-Apr-2017


* Update the custom table from the good records table
      MODIFY zotc_territ_assn FROM TABLE i_territory_assn3.
      IF sy-subrc = 0.
        COMMIT WORK.
      ELSE. " ELSE -> IF sy-subrc = 0
        ROLLBACK WORK.
      ENDIF. " IF sy-subrc = 0

      CALL FUNCTION 'DEQUEUE_EZOTC_TERR_ASSN'.
      IF sy-dbcnt > 0.
        CLEAR wa_display_data.
        wa_display_data = 'zotc_territ_assn updated successfully'(042).
        APPEND wa_display_data TO i_display_data.
      ELSE. " ELSE -> IF sy-dbcnt > 0
        wa_display_data = text-e10.
      ENDIF. " IF sy-dbcnt > 0
    ENDIF. " IF sy-subrc = 1
  ENDIF. " IF i_territory_assn3[] IS NOT INITIAL

ENDFORM. " F_PROCESS_INBOUND_FILE
*&---------------------------------------------------------------------*
*&      Form  F_ZERO_FILL
*&---------------------------------------------------------------------*
*  Purpose: Left fill all numeric fields with zeros
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_zero_fill .
  DATA: lv_out(10).
  CLEAR lv_out.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = wa_territory_assn-kunnr
    IMPORTING
      output = lv_out.
  wa_territory_assn-kunnr = lv_out.
  CLEAR lv_out.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = wa_territory_assn-vkorg
    IMPORTING
      output = lv_out.
  wa_territory_assn-vkorg = lv_out+6(4).
  CLEAR lv_out.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = wa_territory_assn-vtweg
    IMPORTING
      output = lv_out.
  wa_territory_assn-vtweg = lv_out+8(2).
  CLEAR lv_out.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = wa_territory_assn-spart
    IMPORTING
      output = lv_out.
  wa_territory_assn-spart = lv_out+8(2).
  CLEAR lv_out.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = wa_territory_assn-territory_id
    IMPORTING
      output = lv_out.
  wa_territory_assn-territory_id = lv_out.
  CLEAR lv_out.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = wa_territory_assn-partrole
    IMPORTING
      output = lv_out.
  wa_territory_assn-partrole = lv_out+5(5).

ENDFORM. " F_ZERO_FILL
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_SUMMARY_REPORT2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_LOG  text
*      -->P_P_FILEAP  text
*      -->P_GV_MODE  text
*      -->P_GV_SCOUNT  text
*      -->P_GV_ECOUNT  text
*----------------------------------------------------------------------*
FORM f_display_summary_report3 USING fp_i_report      TYPE ty_t_report_p
                                    fp_gv_filename_d TYPE localfile " Local file for upload/download
                                    fp_gv_mode       TYPE char10    " Gv_mode of type CHAR10
                                    fp_no_success    TYPE int4      " 2 byte integer (signed)
                                    fp_no_failed     TYPE int4.     " 2 byte integer (signed)
* Local Data declaration
  TYPES: BEGIN OF ty_report_b,
          msgtyp TYPE char1,   "Error Type
          msgtxt TYPE char256, "Error Text
          key    TYPE char256, "Error Key
         END OF ty_report_b.

  CONSTANTS: c_hline TYPE char100          " Dotted Line
             VALUE
'-----------------------------------------------------------',
             c_slash TYPE char1 VALUE '/'. " Slash of type CHAR1
  CONSTANTS : lc_150 TYPE char3 VALUE '150'. " 150 of type CHAR3
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
        lv_archive_1   TYPE localfile,                       "Archieve File Path
        lv_session_1   TYPE apq_grpn,                        "BDC Session Name
        lv_session_2   TYPE apq_grpn,                        "BDC Session Name
        lv_session_3   TYPE apq_grpn,                        "BDC Session Name
        lv_session(90) TYPE c,                               "All session names
        lv_row         TYPE i,                               "Row number
        lv_width_msg   TYPE outputlen,                       "Column Width
        lv_width_key   TYPE outputlen,                       "Column Width
        li_fieldcat    TYPE slis_t_fieldcat_alv,             "Field Catalog
        li_events      TYPE slis_t_event,
        lwa_events     TYPE slis_alv_event,
        li_report_b    TYPE STANDARD TABLE OF ty_report_b INITIAL SIZE 0,
        lwa_report_b   TYPE ty_report_b.

  FIELD-SYMBOLS: <lfs_report> TYPE ty_report_p.

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
  ENDIF. " IF lv_session_1 IS NOT INITIAL

  IF lv_session_2 IS NOT INITIAL.
    IF lv_session IS NOT INITIAL.
      CONCATENATE lv_session c_slash lv_session_2
      INTO lv_session SEPARATED BY space.
    ELSE. " ELSE -> IF lv_session IS NOT INITIAL
      lv_session = lv_session_2.
    ENDIF. " IF lv_session IS NOT INITIAL
  ENDIF. " IF lv_session_2 IS NOT INITIAL

  IF lv_session_3 IS NOT INITIAL.
    IF lv_session IS NOT INITIAL.
      CONCATENATE lv_session c_slash lv_session_3
      INTO lv_session SEPARATED BY space.
    ELSE. " ELSE -> IF lv_session IS NOT INITIAL
      lv_session = lv_session_3.
    ENDIF. " IF lv_session IS NOT INITIAL
  ENDIF. " IF lv_session_3 IS NOT INITIAL

  IF lv_session IS NOT INITIAL.
    CONCATENATE lv_session text-x32 INTO lv_session
    SEPARATED BY space.
  ENDIF. " IF lv_session IS NOT INITIAL

  LOOP AT fp_i_report ASSIGNING <lfs_report>.
    lwa_report_b-msgtyp = <lfs_report>-msgtyp.
    lwa_report_b-msgtxt = <lfs_report>-msgtxt.
    lwa_report_b-key = <lfs_report>-key.
    APPEND lwa_report_b TO li_report.
    CLEAR lwa_report_b.
  ENDLOOP. " LOOP AT fp_i_report ASSIGNING <lfs_report>
*
*  li_report[] = fp_i_report[].

  WRITE sy-uzeit TO lv_uzeit.
  WRITE sy-datum TO lv_datum.
  CONCATENATE lv_datum lv_uzeit INTO lv_datum SEPARATED BY space.

  lv_total = fp_no_success + fp_no_failed.
  IF lv_total <> 0.
    lv_rate = 100 * fp_no_success / lv_total.
  ENDIF. " IF lv_total <> 0

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
    ENDIF. " IF lv_archive_1 IS NOT INITIAL

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
    ENDIF. " IF lv_session IS NOT INITIAL

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
  ELSE. " ELSE -> IF sy-batch IS INITIAL
*   Passing local variable values to global variable to make it
*   avilable in top of page subroutine.
    gv_filename_d = fp_gv_filename_d.
    gv_filename_d_arch = lv_archive_1.
    gv_mode_b = fp_gv_mode.
    gv_session = lv_session.
    gv_total = lv_total.
    gv_no_success = fp_no_success.
    gv_no_failed = fp_no_failed.
    gv_rate_c = lv_rate_c.

    LOOP AT fp_i_report ASSIGNING <lfs_report>.
      lwa_report_b-msgtyp = <lfs_report>-msgtyp.
      lwa_report_b-msgtxt = <lfs_report>-msgtxt.
      lwa_report_b-key = <lfs_report>-key.
*     Getting the maximum length of columns MSGTXT.
      IF lv_width_msg   LT strlen( <lfs_report>-msgtxt ).
        lv_width_msg = strlen( <lfs_report>-msgtxt ).
      ENDIF. " IF lv_width_msg LT strlen( <lfs_report>-msgtxt )
*     Getting the maximum length of column KEY.
      IF lv_width_key   LT strlen( <lfs_report>-key ).
        lv_width_key = strlen( <lfs_report>-key ).
      ENDIF. " IF lv_width_key LT strlen( <lfs_report>-key )
      APPEND lwa_report_b TO li_report_b.
      CLEAR lwa_report_b.
    ENDLOOP. " LOOP AT fp_i_report ASSIGNING <lfs_report>

    IF lv_width_key LT lc_150.
      lv_width_key = lc_150.
    ENDIF. " IF lv_width_key LT lc_150

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
    lwa_events-form = 'F_TOP_OF_PAGE2'.
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
      MESSAGE e002(zca_msg). " Invalid file name. Please check your entry.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF sy-batch IS INITIAL

ENDFORM. " F_DISPLAY_SUMMARY_REPORT2
* ---> Begin of Delete for D3_OTC_EDD_0213_Defect#2496 by u029267 on 27-Apr-2017
**--> Begin of change for D2_OTC_EDD_0213 Defect # 1461 by PDEBARU on 19/07/2016
**&---------------------------------------------------------------------*
**&      Form  F_CHG_POINTER
**&---------------------------------------------------------------------*
**       change pointer sub-routine
**----------------------------------------------------------------------*
**      -->FP_I_TERRITORY_ASSN3  Looping the updated records
**----------------------------------------------------------------------*
*FORM f_chg_pointer  USING    fp_i_territory_assn3 TYPE ty_t_assn3.
*
**Types declaration
*  TYPES:
*    BEGIN OF lty_terr_assn,
*      mandt          TYPE mandt,          "Client
*      vkorg           TYPE vkorg,         " Sales Organization
*      vtweg           TYPE vtweg,         " Distribution Channel
*      spart           TYPE spart,         " Division
*      kunnr           TYPE kunnr,         " Customer Number
*      territory_id   TYPE  zterritory_id, " Partner Territory ID
*      partrole       TYPE  zpart_role,    " Partner Role
*      effective_from TYPE  zeffect_date,  " Effective From
*      effective_to   TYPE  zexpiry_date,  " Effective To
*      kz             TYPE char1,          "Chng Ind
*    END OF lty_terr_assn.
*
*  CONSTANTS:
*    lc_objectid TYPE cdobjectv VALUE 'ZOTC_TERRIT_ASSN',    "Object Id
*    lc_new      TYPE cdchngind VALUE 'N',                   "Chng Ind for New
*    lc_ins      TYPE cdchngind VALUE 'I',                   "Chng Ind for Insert
*    lc_upd      TYPE cdchngind VALUE 'U',                   "Chng Ind for Update
*    lc_change   TYPE cdchngind VALUE 'X',                   "Change Type (U, I, S, D)
*    lc_tcode    TYPE cdtcode   VALUE 'ZOTC_TERRIT_ASSN',    "T-Code
*    lc_mandt    TYPE name_feld VALUE 'MANDT',               "MANDT field name
*    lc_vkorg    TYPE name_feld VALUE 'VKORG',               "MANDT field name
*    lc_vtweg    TYPE name_feld VALUE 'VTWEG',               "MANDT field name
*    lc_spart    TYPE name_feld VALUE 'SPART',               "MANDT field name
*    lc_kunnr    TYPE name_feld VALUE 'KUNNR',               "MANDT field name
*    lc_territory_id    TYPE name_feld VALUE 'TERRITORY_ID', "MANDT field name
*    lc_partrole        TYPE name_feld VALUE 'PARTROLE',     "MANDT field name
*    lc_zeffect_date TYPE name_feld VALUE 'EFFECTIVE_FROM',  " Field name
*    lc_zexpiry_date TYPE name_feld VALUE 'EFFECTIVE_TO'.    " Field name
*
**Data Declaration
*
*  DATA:
*    lv_udate    TYPE cddatum,                             "Date
*    lv_utime    TYPE cduzeit,                             "Time
*    lv_uname    TYPE cdusername,                          "Userid
*    lv_upd      TYPE cdchngind,                           "Chng Ind
*    lv_objectid TYPE cdobjectv,                           " Object value
*
*    li_tabnewvals TYPE STANDARD TABLE OF lty_terr_assn
*                        INITIAL SIZE 0,                   "New Value table with chng ind
*    li_newvalues  TYPE STANDARD TABLE OF zotc_territ_assn " Comm Group: Territory Assignment
*                        INITIAL SIZE 0,                   "New value table
*    li_cdtxt      TYPE STANDARD TABLE OF cdtxt            " Change documents: Text changes
*                        INITIAL SIZE 0,                   "Text table
*
*    lwa_tabnewvals TYPE lty_terr_assn,                    "New value table wokarea with chng ind
*    lwa_oldvalues  TYPE zotc_territ_assn,                 "Old value table workarea
*    lwa_newvalues  TYPE zotc_territ_assn,                 "New value table workarea
*
*    lx_customer    TYPE cmds_customer_s,                  " Customer Data
*    lwa_kna1_n      TYPE kna1,                            " General Data in Customer Master
*    lwa_kna1_o      TYPE kna1,                            " General Data in Customer Master
*    lwa_territory_assn TYPE zotc_territ_assn.             " Comm Group: Territory Assignment
*
*  FIELD-SYMBOLS:
*    <lfs_tabnewvals> TYPE lty_terr_assn,   "New value table fieldsymbol
*    <lfs_mandt>      TYPE mandt,           "MANDT field's fieldsymbol
*    <lfs_vkorg>      TYPE vkorg,           " Sales Organization
*    <lfs_vtweg>      TYPE vtweg,           " Distribution Channel
*    <lfs_spart>      TYPE spart,           " Division
*    <lfs_kunnr>      TYPE kunnr,           " Division
*    <lfs_territory_id> TYPE zterritory_id, " Partner Territory ID
*    <lfs_partrole>     TYPE zpart_role,    " Partner Role
*    <lfs_zeffect_date> TYPE zeffect_date,  " Effective From
*    <lfs_zexpiry_date> TYPE zexpiry_date.  " Effective To
*
*
*** The details of the data which were successfully filtered
*** without error and are ready to be posted & updated
*  LOOP AT i_territory_assn3 INTO lwa_territory_assn .
*
*    lwa_newvalues-mandt          = lwa_territory_assn-mandt.
*    lwa_newvalues-vkorg          = lwa_territory_assn-vkorg.
*    lwa_newvalues-vtweg          = lwa_territory_assn-vtweg.
*    lwa_newvalues-spart          = lwa_territory_assn-spart.
*    lwa_newvalues-kunnr          = lwa_territory_assn-kunnr.
*    lwa_newvalues-territory_id   = lwa_territory_assn-territory_id.
*    lwa_newvalues-partrole       = lwa_territory_assn-partrole.
*    lwa_newvalues-effective_from = lwa_territory_assn-effective_from.
*    lwa_newvalues-effective_to   = lwa_territory_assn-effective_to.
*
**--Pass the effective as the change pointer creation date , so that the change pointer is
**--processed on the effective future date only.
*    lv_udate = lwa_territory_assn-effective_from.
*    lv_utime = sy-uzeit.
*    lv_uname = sy-uname.
*
**&--Fill old values when it is update or delete
*
*
*    READ TABLE i_oldvalues
*          INTO lwa_oldvalues
*    WITH KEY vkorg = lwa_territory_assn-vkorg
*      vtweg = lwa_territory_assn-vtweg
*      spart = lwa_territory_assn-spart
*      kunnr = lwa_territory_assn-kunnr
*      territory_id = lwa_territory_assn-territory_id
*      partrole     = lwa_territory_assn-partrole
*      effective_from = lwa_territory_assn-effective_from
*      effective_to   = lwa_territory_assn-effective_to
*          BINARY SEARCH.
*    IF sy-subrc NE 0.
*      CLEAR lwa_oldvalues.
*      lv_upd = lc_ins.
*    ELSE. " ELSE -> IF sy-subrc NE 0
*      lv_upd = lc_upd.
*    ENDIF. " IF sy-subrc NE 0
*
*
*
*    lv_objectid = lwa_territory_assn-kunnr.
*
*    IF lwa_territory_assn-kunnr IS NOT INITIAL.
*
*      SELECT SINGLE *
*        INTO lwa_kna1_n
*             FROM kna1 " General Data in Customer Master
*           WHERE kunnr = lwa_territory_assn-kunnr.
*      IF sy-subrc EQ 0.
*
**--Pass a dummy 'X' difference in KNA1 field name2, to force Idoc creation FM to trigger IDocs, other wise
**--it does not create any Idoc as it cannot find any difference between lwa_kna1_o & lwa_kna1_n.
*        lwa_kna1_o =  lwa_kna1_n.
*        IF lwa_kna1_n-name2 IS INITIAL.
*          lwa_kna1_n-name2 = lc_change.
*        ELSE. " ELSE -> IF lwa_kna1_n-name2 IS INITIAL
*          CLEAR lwa_kna1_n-name2 .
*        ENDIF. " IF lwa_kna1_n-name2 IS INITIAL
*
*        CALL FUNCTION 'DEBI_WRITE_DOCUMENT'
*          EXPORTING
*            objectid                = lv_objectid
*            tcode                   = lc_tcode
*            utime                   = lv_utime
*            udate                   = lv_udate
*            username                = lv_uname
*            planned_change_number   = space
*            object_change_indicator = lc_upd
*            planned_or_real_changes = space
*            no_change_pointers      = space
*            o_ykna1                 = lwa_kna1_o
*            n_kna1                  = lwa_kna1_n
*            upd_kna1                = lc_upd
*            upd_knas                = lx_customer-knas-upd
*            upd_knat                = lx_customer-knat-upd
*            o_yknb1                 = lx_customer-knb1-old_data
*            n_knb1                  = lx_customer-knb1-new_data
*            upd_knb1                = lx_customer-knb1-upd
*            upd_knb5                = lx_customer-knb5-upd
*            upd_knbk                = lx_customer-knbk-upd
*            upd_knbw                = lx_customer-knbw-upd
*            upd_knex                = lx_customer-knex-upd
*            upd_knva                = lx_customer-knva-upd
*            upd_knvd                = lx_customer-knvd-upd
*            upd_knvi                = lx_customer-knvi-upd
*            upd_knvk                = lx_customer-knvk-upd
*            upd_knvl                = lx_customer-knvl-upd
*            upd_knvp                = lx_customer-knvp-upd
*            upd_knvs                = lx_customer-knvs-upd
*            o_yknvv                 = lx_customer-knvv-old_data
*            n_knvv                  = lx_customer-knvv-new_data
*            upd_knvv                = lx_customer-knvv-upd
*            upd_knza                = lx_customer-knza-upd
*          TABLES
*            xknas                   = lx_customer-fknas-new_data
*            yknas                   = lx_customer-fknas-old_data
*            xknat                   = lx_customer-fknat-new_data
*            yknat                   = lx_customer-fknat-old_data
*            xknb5                   = lx_customer-fknb5-new_data
*            yknb5                   = lx_customer-fknb5-old_data
*            xknbk                   = lx_customer-fknbk-new_data
*            yknbk                   = lx_customer-fknbk-old_data
*            xknbw                   = lx_customer-fknbw-new_data
*            yknbw                   = lx_customer-fknbw-old_data
*            xknex                   = lx_customer-fknex-new_data
*            yknex                   = lx_customer-fknex-old_data
*            xknva                   = lx_customer-fknva-new_data
*            yknva                   = lx_customer-fknva-old_data
*            xknvd                   = lx_customer-fknvd-new_data
*            yknvd                   = lx_customer-fknvd-old_data
*            xknvi                   = lx_customer-fknvi-new_data
*            yknvi                   = lx_customer-fknvi-old_data
*            xknvk                   = lx_customer-fknvk-new_data
*            yknvk                   = lx_customer-fknvk-old_data
*            xknvl                   = lx_customer-fknvl-new_data
*            yknvl                   = lx_customer-fknvl-old_data
*            xknvp                   = lx_customer-fknvp-new_data
*            yknvp                   = lx_customer-fknvp-old_data
*            xknvs                   = lx_customer-fknvs-new_data
*            yknvs                   = lx_customer-fknvs-old_data
*            xknza                   = lx_customer-fknza-new_data
*            yknza                   = lx_customer-fknza-old_data.
*
*      ENDIF. " IF sy-subrc EQ 0
*
**&--Call the FM
*** Posting is done in Ztable
*
*      CALL FUNCTION 'ZOTC_COMM_GRP_WRITE_DOCUMENT'
*        EXPORTING
*          objectid                = lv_objectid
*          tcode                   = lc_tcode
*          utime                   = lv_utime
*          udate                   = lv_udate
*          username                = lv_uname
*          object_change_indicator = lv_upd
*          n_zotc_territ_assn      = lwa_newvalues
*          o_zotc_territ_assn      = lwa_oldvalues
*          upd_zotc_territ_assn    = lv_upd
*        TABLES
*          icdtxt_zotc_comm_grp    = li_cdtxt.
*
*    ENDIF. " IF lwa_territory_assn-kunnr IS NOT INITIAL
*  ENDLOOP. " LOOP AT i_territory_assn3 INTO lwa_territory_assn
*
*ENDFORM. " F_CHG_POINTER
**<--- End of change for D2_OTC_EDD_0213 Defect # 1461 by PDEBARU on 19/07/2016
* <--- End of Delete for D3_OTC_EDD_0213_Defect#2496 by u029267 on 27-Apr-2017
* ---> Begin of Insert for D3_OTC_EDD_0213_Defect#2496 by u029267 on 27-Apr-2017
*&---------------------------------------------------------------------*
*&      Form  F_CALL_BD12_PROG
*&---------------------------------------------------------------------*
*       call program BD12 for sending customers
*----------------------------------------------------------------------*
*      -->FP_I_TERRITORY_ASSN3  Looping the updated records
*----------------------------------------------------------------------*
FORM f_call_bd12_prog  USING    fp_i_territory_assn3 TYPE ty_t_assn3.

  DATA: lv_count  TYPE count,                                                      " Counter
        lv_tabix  TYPE sytabix,                                                    " Index of Internal Tables
        lv_lines  TYPE char5,                                                      " Lines of type CHAR5
        lr_kunnr  TYPE RANGE OF kunnr,                                             " Customer Number
        lwa_kunnr LIKE LINE OF lr_kunnr,
        li_territory_assn3 TYPE STANDARD TABLE OF zotc_territ_assn INITIAL SIZE 0. " Comm Group: Territory Assignment

  FIELD-SYMBOLS: <lfs_territory_assn3> TYPE zotc_territ_assn. " Comm Group: Territory Assignment
  CONSTANTS: lc_sign   TYPE sign       VALUE 'I',      " Debit/Credit Sign (+/-)
             lc_option TYPE option     VALUE 'EQ',     " Option for ranges tables
             lc_mestyp TYPE edi_mestyp VALUE 'DEBMAS'. " Message Type

  IF gv_records = 0.
    MESSAGE i803(zotc_msg). " Maintain maximum number of records in EMI
    LEAVE LIST-PROCESSING.
  ENDIF. " IF gv_records = 0
  CLEAR: lv_count, lv_tabix.



  li_territory_assn3[] = fp_i_territory_assn3[].
  DELETE ADJACENT DUPLICATES FROM li_territory_assn3 COMPARING kunnr.

  DESCRIBE TABLE li_territory_assn3 LINES lv_lines.

  LOOP AT li_territory_assn3 ASSIGNING <lfs_territory_assn3>.
    lv_count = lv_count + 1.
    lv_tabix = lv_tabix + 1.
* Whatever no is there in EMI that many no of records can be posted at a time
    IF lv_count <= gv_records.
      lwa_kunnr-sign   = lc_sign.
      lwa_kunnr-option = lc_option.
      lwa_kunnr-low =  <lfs_territory_assn3>-kunnr.
      APPEND lwa_kunnr TO lr_kunnr.

      IF lv_count = gv_records OR lv_tabix = lv_lines.
*       Call BD12 transaction to send the customers
        SUBMIT rbdsedeb WITH selkunnr IN lr_kunnr
                WITH mestyp   EQ lc_mestyp
                AND RETURN.
        CLEAR:  lv_count, lwa_kunnr.
        FREE: lr_kunnr.
      ENDIF. " IF lv_count = gv_records OR lv_tabix = lv_lines
    ENDIF. " IF lv_count <= gv_records
  ENDLOOP. " LOOP AT li_territory_assn3 ASSIGNING <lfs_territory_assn3>
  CLEAR: lv_tabix.
ENDFORM. " F_CALL_BD12_PROG
* <--- End of Insert for D3_OTC_EDD_0213_Defect#2496 by u029267 on 27-Apr-2017
*<-- Begin of Insert for D3_OTC_EDD_0213_Defect#2496_Part2 by U029267 on 02-Aug-2017
*&---------------------------------------------------------------------*
*&      Form  F_AUTHORIZATION_CHECK
*&---------------------------------------------------------------------*
*       Authorization check for updating table ZOTC_TERRIT_ASSN
*----------------------------------------------------------------------*
FORM f_authorization_check .

  CONSTANTS: lc_actvt      TYPE char5  VALUE 'ACTVT',            " Actvt of type CHAR5
             lc_table      TYPE char5  VALUE 'TABLE',            " Table of type CHAR5
             lc_chg        TYPE char2  VALUE '02',               " Disp of type CHAR2
             lc_tab_name   TYPE char16 VALUE 'ZOTC_TERRIT_ASSN', " Table name
             lc_s_tabu_nam TYPE char10 VALUE 'S_TABU_NAM'.       " Auth. obj name

  AUTHORITY-CHECK OBJECT lc_s_tabu_nam
  ID lc_actvt FIELD lc_chg
  ID lc_table FIELD lc_tab_name.

  IF  sy-subrc NE 0.
    MESSAGE e804(zotc_msg). " User has no authorization to Add/Change functionality
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_AUTHORIZATION_CHECK
*--> End of Insert for D3_OTC_EDD_0213_Defect#2496_Part2 by U029267 on 02-Aug-2017
