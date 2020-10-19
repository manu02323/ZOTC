*&---------------------------------------------------------------------*
*&  Include           ZOTC_EDD0323_CON_BATCH_REC_F01
*&---------------------------------------------------------------------*
*&**********************************************************************
* PROGRAM    :  ZOTC_EDD0323_CON_BATCH_REC                             *
* TITLE      :  Convert Batch Determination Records                    *
* DEVELOPER  :  Dhanasekar Arumugam                                    *
* OBJECT TYPE:  Enhancement Program                                    *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0323                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Batch determination process will assign a batch based  *
* on Business selection criteria for a combination of values, such as  *
* Material, Ship-to or Country of Destination.                         *
*                                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 26-Jul-2016 DARUMUG  E1DK919220 INITIAL DEVELOPMENT                  *
* 04-Nov-2016 DARUMUG  E1DK919220 CR 190: Defect # 3039                *
*                                 Batch Determination using enhancement*
*                                   ->Remove all the BDC logic         *
*                                   ->Replace it w/ enhancements below *
*                                 User Exit:                           *
*                                    1.	Class: ZIM_BATCH_SELECTION     *
*                                       Method PRESELECT_BATCHES       *
*                                    2.	Enhancement:                   *
*                                        ZIM_BATCH_DETERMINATION2 at   *
*                                        VB_BATCH_DETERMINATION        *
*                                        function module.              *
* 01-Jul-2019 U103061  E2DK924987  Defect 9407 Incident: INC0426256-03 *
*                                 Modification required during         *
*                                 Deletion/Updation/Copying/Filtering  *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MANAGE_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_manage_grid .
  "If container has not yet been initiated, create it
  IF go_container_0501 IS INITIAL.
    "Container
    CREATE OBJECT go_container_0501
      EXPORTING
        container_name = c_container.

    "ALV Grid
    CREATE OBJECT go_grid_501
      EXPORTING
        i_parent = go_container_0501.

    "Events
    CREATE OBJECT go_alv_event_0501.

    "Event Handlers
    SET HANDLER:
                 go_alv_event_0501->handle_toolbar_set      FOR go_grid_501,
                 go_alv_event_0501->handle_user_command     FOR go_grid_501,
                 go_alv_event_0501->handle_data_changed     FOR go_grid_501.

    "Prepare data and display batches
    PERFORM f_display_batches.
  ELSE.
    PERFORM f_display_batches.
  ENDIF.
ENDFORM.                    " F_MANAGE_GRID
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_BATCHES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_display_batches .


  DATA:
    lwa_output      TYPE zotc_custgrp_matbatch_str,
    lwa_layout_0501 TYPE lvc_s_layo.                        "#EC NEEDED

  "Get Material/Ship to and Batch information
  PERFORM f_get_batch_data.

  "Build field catalog
  PERFORM f_build_fieldcatalog.

  "Exclude toolbar buttons
  PERFORM f_exclude_toolbar_buttons.

  lwa_layout_0501-stylefname = c_field_style.
  lwa_layout_0501-info_fname = c_color_row.

  SET HANDLER go_alv_event_0501->handle_data_changed     FOR go_grid_501.
  SET HANDLER go_alv_event_0501->handle_user_command     FOR go_grid_501.

*  delete i_output where charg eq space.
  SORT i_output BY matnr kunwe DESCENDING.

  IF i_output IS INITIAL.
    APPEND lwa_output TO i_output.
  ENDIF.

  IF i_output IS NOT INITIAL.
    CALL METHOD go_grid_501->set_table_for_first_display
      EXPORTING
        i_bypassing_buffer   = 'X'
        is_layout            = lwa_layout_0501
        it_toolbar_excluding = i_exclude_0501
      CHANGING
        it_fieldcatalog      = i_fcat_0501
        it_outtab            = i_output.

    IF sy-subrc NE 0.
      MESSAGE s044 DISPLAY LIKE 'E'. " Error calling method set_table_for_first_display
    ENDIF.

    CALL METHOD go_grid_501->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified
      EXCEPTIONS
        error      = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE s045 DISPLAY LIKE 'E'. " Error calling method register_edit_event
    ENDIF.

    CALL METHOD go_grid_501->refresh_table_display.
  ENDIF.

ENDFORM.                    " F_DISPLAY_BATCHES
*&---------------------------------------------------------------------*
*&      Form  F_GET_BATCH_DATA
*&---------------------------------------------------------------------*
*  CR 190 - Removed all the previous logic
*  using koth921/koth922 tables and removed updating VCH1/VCH2 through BDC
*  as assigning batches will happen through enhancements
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_batch_data .

  TYPES:
    BEGIN OF ty_kna1,
      kunnr TYPE kunnr,
      name1 TYPE name1_gp,
    END OF ty_kna1.

  DATA:
    lwa_custgrp TYPE zotc_custgrp_asn,
    lwa_matbat  TYPE zotc_custgrp_matbatch_str,
    li_makt     TYPE TABLE OF makt,
    lwa_makt    TYPE makt,
    lwa_t005t   TYPE t005t,
    lwa_kna1    TYPE ty_kna1,
    li_kna1     TYPE TABLE OF ty_kna1,
    li_t005t    TYPE TABLE OF t005t,
    li_custgrp  TYPE TABLE OF zotc_custgrp_asn.

  FIELD-SYMBOLS:
    <fs_matbat>  TYPE zotc_custgrp_matbatch_str.

  REFRESH : i_output,
*--->Begin of Insert for D3_OTC_EDD_0323_Defect#9407 by U103061 on 01-Jul-2019
            li_custgrp.
*--->Begin of Insert for D3_OTC_EDD_0323_Defect#9407 by U103061 on 01-Jul-2019

* Selections from koth921/koth922 tables are removed and replaced from
* zotc_custgrp_asn Customer Group Assignment table.
  IF ( p_matcus EQ c_true   AND
       p_matctr EQ c_true ) OR
     ( p_matcus EQ ' '      AND
       p_matctr EQ ' ' ) .
    "Get Customer Group Assignment
    SELECT * FROM zotc_custgrp_asn
             INTO TABLE li_custgrp
             WHERE matnr    IN s_matnr
             AND   kunnr    IN s_kunnr
             AND   land1    IN s_cntry
             AND   zcustgrp IN s_cusgrp
             AND   batch    IN s_batch.
    IF sy-subrc NE 0.
      MESSAGE i115(zotc_msg).
    ENDIF.
  ELSEIF p_matcus EQ c_true.
    "Get Customer Group Assignment
    SELECT * FROM zotc_custgrp_asn
             INTO TABLE li_custgrp
             WHERE matnr    IN s_matnr
             AND   kunnr    IN s_kunnr
             AND   zcustgrp IN s_cusgrp
             AND   batch    IN s_batch.
    IF sy-subrc NE 0.
      MESSAGE i115(zotc_msg).
    ENDIF.
  ELSEIF  p_matctr EQ c_true.
    "Get Customer Group Assignment
    SELECT * FROM zotc_custgrp_asn
             INTO TABLE li_custgrp
             WHERE matnr    IN s_matnr
             AND   land1    IN s_cntry
             AND   zcustgrp IN s_cusgrp
             AND   batch    IN s_batch.
    IF sy-subrc NE 0.
      MESSAGE i115(zotc_msg).
    ENDIF.
  ENDIF.

  IF li_custgrp IS NOT INITIAL.
    "Get the Customer and Name
    SELECT kunnr name1 FROM kna1
             INTO TABLE li_kna1
             FOR ALL ENTRIES IN li_custgrp
             WHERE kunnr EQ li_custgrp-kunnr.
  ENDIF.

  IF li_custgrp IS NOT INITIAL.
    "Get the country details
    SELECT * FROM t005t
             INTO TABLE li_t005t
             FOR ALL ENTRIES IN li_custgrp
             WHERE spras = 'EN' AND
                   land1 = li_custgrp-land1.
  ENDIF.

  "Get the Material description
  SELECT * FROM makt
           INTO TABLE li_makt
           WHERE matnr IN s_matnr.

  SORT li_kna1 BY kunnr.
  SORT li_makt BY matnr.
  SORT li_t005t BY land1.

  "Loop through the Customer Group Assignment table and fill the output table
  LOOP AT li_custgrp INTO lwa_custgrp.

    lwa_matbat-matnr = lwa_custgrp-matnr.
    lwa_matbat-kunwe = lwa_custgrp-kunnr.
    lwa_matbat-land1 = lwa_custgrp-land1.
    lwa_matbat-charg = lwa_custgrp-batch.
    lwa_matbat-zcustgrp = lwa_custgrp-zcustgrp.

    "Get Customer Name
    READ TABLE li_kna1 INTO lwa_kna1
                       WITH KEY kunnr = lwa_custgrp-kunnr
                       BINARY SEARCH.
    IF sy-subrc EQ 0.
      lwa_matbat-cust_des = lwa_kna1-name1.
    ENDIF.

    "Get material description
    READ TABLE li_makt INTO lwa_makt
                       WITH KEY matnr = lwa_custgrp-matnr
                       BINARY SEARCH.
    IF sy-subrc EQ 0.
      lwa_matbat-mat_des = lwa_makt-maktx.
    ENDIF.

    "Get Country Name
    READ TABLE li_t005t INTO lwa_t005t
                       WITH KEY land1 = lwa_custgrp-land1
                       BINARY SEARCH.
    IF sy-subrc EQ 0.
      lwa_matbat-ctry_des = lwa_t005t-landx.
    ENDIF.

    APPEND lwa_matbat TO i_output.

    CLEAR lwa_matbat.
  ENDLOOP.
ENDFORM.                    " F_GET_BATCH_DATA
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_fieldcatalog .

  DATA :
    li_tabdescr   TYPE abap_compdescr_tab,
    li_ref_tab    TYPE REF TO cl_abap_structdescr,
    li_output     TYPE zotc_custgrp_matbatch_tt,

    lwa_tabdescr  TYPE abap_compdescr,
    lwa_tmp       TYPE zotc_custgrp_matbatch_str,
    lwa_fcat_0501 TYPE lvc_s_fcat,

    lv_field      TYPE abap_compname.

  FIELD-SYMBOLS :
    <lfs_fval> TYPE any,
    <lfs_val>  TYPE any.

  REFRESH : i_fcat_0501.

  li_ref_tab ?= cl_abap_typedescr=>describe_by_name( 'ZOTC_CUSTGRP_MATBATCH_STR' ).
  li_tabdescr[] = li_ref_tab->components[].

  IF i_output IS INITIAL.
    lwa_tmp-flag = 'A'.
    APPEND lwa_tmp TO i_output.
  ENDIF.

  li_output = i_output.
  LOOP AT li_tabdescr INTO lwa_tabdescr.
    CLEAR lwa_fcat_0501.
    ASSIGN lwa_tabdescr-name TO <lfs_fval>.                "#EC RC_READ
    CHECK sy-subrc = 0.
    SORT li_output BY (<lfs_fval>) DESCENDING.
    CONCATENATE 'lwa_tmp' '-' <lfs_fval> INTO lv_field .  "#NO_TEXT
    ASSIGN (lv_field) TO <lfs_val>.
    CHECK sy-subrc = 0.

    READ TABLE li_output INTO lwa_tmp INDEX 1 TRANSPORTING (<lfs_fval>).
    IF sy-subrc = 0. " and ( not <lfs_val> is initial ).
      lwa_fcat_0501-fieldname = lwa_tabdescr-name.
      lwa_fcat_0501-coltext = lwa_tabdescr-name.
      APPEND lwa_fcat_0501 TO i_fcat_0501.
      CLEAR lwa_fcat_0501.
    ENDIF.
  ENDLOOP.

  LOOP AT i_fcat_0501 ASSIGNING <gfs_fcat>.
    CASE <gfs_fcat>-fieldname.
      WHEN 'KAPPL' OR
           'KSCHL' OR
           'DATBI' OR
           'DATAB' OR
           'KNUMH' OR
           'KUNNR' OR
           'COLOR_CELL'  OR
           'FIELD_STYLE' OR
           'FLAG'.
        <gfs_fcat>-no_out = c_true.
    ENDCASE.
  ENDLOOP.

  LOOP AT i_fcat_0501 ASSIGNING <gfs_fcat>.
    CASE <gfs_fcat>-fieldname.

      WHEN 'MATNR'.
        <gfs_fcat>-coltext     = 'Material'.                "#EC NOTEXT
        <gfs_fcat>-just        = 'R'.
        <gfs_fcat>-outputlen   = 11.
        <gfs_fcat>-col_pos     = 1.
        <gfs_fcat>-edit        = 'X'.

      WHEN 'ZCUSTGRP'.
        <gfs_fcat>-coltext     = 'Customer Group'.          "#EC NOTEXT
        <gfs_fcat>-just        = 'R'.
        <gfs_fcat>-outputlen   = 11.
        <gfs_fcat>-col_pos     = 2.
        <gfs_fcat>-edit        = 'X'.

      WHEN 'LAND1'.
        <gfs_fcat>-coltext     = 'Country'.                 "#EC NOTEXT
        <gfs_fcat>-just        = 'R'.
        <gfs_fcat>-outputlen   = 11.
        <gfs_fcat>-col_pos     = 3.
        <gfs_fcat>-edit        = 'X'.

      WHEN 'KUNWE'.
        <gfs_fcat>-coltext     = 'Ship to'.                 "#EC NOTEXT
        <gfs_fcat>-just        = 'R'.
        <gfs_fcat>-outputlen   = 11.
        <gfs_fcat>-col_pos     = 4.
        <gfs_fcat>-edit        = 'X'.

      WHEN 'CHARG'.
        <gfs_fcat>-coltext     = 'Batch'.                   "#EC NOTEXT
        <gfs_fcat>-just        = 'R'.
        <gfs_fcat>-outputlen   = 11.
        <gfs_fcat>-col_pos     = 5.
        <gfs_fcat>-edit        = 'X'.

      WHEN 'MAT_DES'.
        <gfs_fcat>-coltext     = 'Material Description'.    "#EC NOTEXT
        <gfs_fcat>-just        = 'R'.
        <gfs_fcat>-outputlen   = 20.
        <gfs_fcat>-col_pos     = 6.

      WHEN 'CUST_DES'.
        <gfs_fcat>-coltext     = 'Customer Description'.    "#EC NOTEXT
        <gfs_fcat>-just        = 'R'.
        <gfs_fcat>-outputlen   = 12.
        <gfs_fcat>-col_pos     = 7.

      WHEN 'CTRY_DES'.
        <gfs_fcat>-coltext     = 'Country Description'.     "#EC NOTEXT
        <gfs_fcat>-just        = 'R'.
        <gfs_fcat>-outputlen   = 18.
        <gfs_fcat>-col_pos     = 8.

    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*&      Form  F_EXCLUDE_TOOLBAR_BUTTONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_exclude_toolbar_buttons .

  DATA: lwa_exclude TYPE ui_func.

  lwa_exclude = cl_gui_alv_grid=>mc_fc_check.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_fc_select_all.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_mb_view.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_mb_sum.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_mb_subtot.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_fc_graph.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_fc_detail.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_mb_variant.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_fc_sum.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_fc_subtot.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_fc_sort_dsc.
  APPEND lwa_exclude TO i_exclude_0501.
  lwa_exclude = cl_gui_alv_grid=>mc_fc_sort_asc.
  APPEND lwa_exclude TO i_exclude_0501.

ENDFORM.                    " F_EXCLUDE_TOOLBAR_BUTTONS
*&---------------------------------------------------------------------*
*&      Form  UPDATE_CUST_GROUP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_cust_group .

  DATA: lwa_custgrp TYPE zotc_custgrp_asn,
        lwa_output  TYPE zotc_custgrp_matbatch_str.

  IF i_output_add IS NOT INITIAL.
    LOOP AT i_output_add INTO lwa_output.
      lwa_custgrp-matnr = lwa_output-matnr.
      lwa_custgrp-kunnr = lwa_output-kunwe.
      lwa_custgrp-land1 = lwa_output-land1.
      lwa_custgrp-zcustgrp = lwa_output-zcustgrp.
      lwa_custgrp-batch    = lwa_output-charg.
      IF lwa_custgrp-zcustgrp IS NOT INITIAL.
*--->Begin of Delete for D3_OTC_EDD_0323_Defect#9407 by U103061 on 01-Jul-2019
*        insert zotc_custgrp_asn from lwa_custgrp.
*--->End of Delete for D3_OTC_EDD_0323_Defect#9407 by U103061 on 01-Jul-2019
*--->Begin of Insert for D3_OTC_EDD_0323_Defect#9407 by U103061 on 01-Jul-2019
        MODIFY zotc_custgrp_asn FROM lwa_custgrp."Modify will update new as well existing records
*--->End of Insert for D3_OTC_EDD_0323_Defect#9407 by U103061 on 01-Jul-2019
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " UPDATE_CUST_GROUP
*&---------------------------------------------------------------------*
*&      Form  F_FLUSH_GLOBAL_OBJECTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_flush_global_objects .

  FREE:
   go_container_0501,
   go_grid_501.

  CLEAR:
   go_grid_501,
   go_container_0501,
   gv_set_ok_hit.

  REFRESH:
   i_output,
   i_fcat_0501,
   i_exclude_0501.

ENDFORM.                    " F_FLUSH_GLOBAL_OBJECTS
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_EXTENSION
*&---------------------------------------------------------------------*
*       Checking whetehr the file has .TXT extension
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
      MESSAGE e055. " Please provide text file
    ENDIF. " IF gv_extn <> c_text
  ENDIF. " IF fp_p_file IS NOT INITIAL

ENDFORM. " F_CHECK_EXTENSION
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_PRES
*&---------------------------------------------------------------------*
*       Upload input file from Presentation Server
*----------------------------------------------------------------------*
*       -->FP_GV_FILE      Input File location
*      <--fp_i_input[]     Input Data
*----------------------------------------------------------------------*
FORM f_upload_pres  USING    fp_p_file TYPE localfile " Local file for upload/download
                    CHANGING fp_i_input TYPE ty_t_input.
* Local Data Declaration
  DATA: lv_filename TYPE string. "File Name
  FIELD-SYMBOLS: <lfs_input> TYPE ty_input.

  lv_filename = fp_p_file.

* Uploading the file from Presentation Server
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_filename
      filetype                = c_filetype
      has_field_separator     = c_true
    CHANGING
      data_tab                = fp_i_input[]
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
    MESSAGE i053 WITH lv_filename. " File could not be read from &
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS NOT INITIAL

ENDFORM. " F_UPLOAD_PRES
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_input .

* Local Data Declaration.
  FIELD-SYMBOLS: <lfs_input> TYPE ty_input. "Field symbol for input data

* Local variable declaration
  DATA : lv_key       TYPE string,       "Key for error log
         lv_error     TYPE char1,        "Error Flag
         lv_count     TYPE char2,        "Indicating the current record
         lv_err_flag  TYPE char1,
         lv_mcount    TYPE int2,         "matching count
         lv_cnt_lqua  TYPE int2,         "Number of quant record
         lv_message   TYPE string,       "Message local variable
         lwa_final    TYPE ty_input_f,
         lwa_error    TYPE ty_input_e,   "Work area for Error input
         li_input_err TYPE ty_t_input_e. "Local Internal Table for error ty_input_e

  FIELD-SYMBOLS:
*         <lfs_input>   type ty_input,
         <fs_final>    TYPE ty_input_f.

  LOOP AT i_input ASSIGNING <lfs_input> .

*   Get the line number of the file incrementing index by 1
    lv_count = sy-tabix. " For indicating the current record

    lwa_final-mandt = sy-mandt.
    IF <lfs_input>-matnr IS INITIAL.
      MOVE  'Material is Blank'(040)
      TO lv_message.

*    Populating Error file
      CLEAR: lwa_error.
*      lwa_error-material     = <lfs_input>-material.
*      lwa_error-batch        = <lfs_input>-batch.

      lwa_error-recno = lv_count.
      PERFORM f_populate_error USING lv_message
                      CHANGING lwa_error
                               li_input_err.
      lv_err_flag = 'X'.
    ELSE.
      lwa_final-matnr = <lfs_input>-matnr.
    ENDIF.
    lwa_final-kunnr = <lfs_input>-kunnr.
    lwa_final-land1 = <lfs_input>-land1.

    IF <lfs_input>-batch IS INITIAL.
      MOVE  'Batch is Blank'(041)
      TO lv_message.
*    Populating Error file
      CLEAR: lwa_error.
*      lwa_error-material     = <lfs_input>-material.
*      lwa_error-batch        = <lfs_input>-batch.

      lwa_error-recno = lv_count.
      PERFORM f_populate_error USING lv_message
                      CHANGING lwa_error
                               li_input_err.
      lv_err_flag = 'X'.
    ELSE.
      lwa_final-batch = <lfs_input>-batch.
    ENDIF.

    lwa_final-zcustgrp = <lfs_input>-zcustgrp.

    IF lv_err_flag NE 'X'.
      APPEND lwa_final TO i_final.
    ELSE.
      APPEND LINES OF li_input_err TO i_input_err.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " F_VALIDATE_INPUT
*&---------------------------------------------------------------------*
*&      Form  F_LOAD_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_load_file .


  MODIFY zotc_custgrp_asn FROM TABLE i_final.
  IF sy-subrc EQ 0.
    MESSAGE 'File loaded Successfully' TYPE 'I'.
  ENDIF.

ENDFORM.                    " F_LOAD_FILE
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_ERROR
*&---------------------------------------------------------------------*
*       Populate Error table
*----------------------------------------------------------------------*
*      -->FP_v_message     Message Text
*      <--FP_LWA_ERROR     Error records
*      <--i_input_E        Error log
*----------------------------------------------------------------------*
FORM f_populate_error  USING     fp_v_message    TYPE string        "message text
                       CHANGING  fp_wa_error     TYPE ty_input_e    "work area for error value
                                 fp_input_err    TYPE ty_t_input_e. "Error file

* Populating the Error Record table for Application server download
* in case Application Server option is chosen
  fp_wa_error-message = fp_v_message. " Message Text
  APPEND fp_wa_error TO fp_input_err.

ENDFORM. " F_POPULATE_ERROR
