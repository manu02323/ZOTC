*&---------------------------------------------------------------------*
*&  Include           ZOTC_EDD0323_CON_BATCH_REC_TOP
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
*01-Jul-2019 U103061  E2DK924987  Defect 9407 Incident: INC0426256-03  *
*                                 Modification required during         *
*                                 Deletion/Updation/Copying/Filtering  *
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_input,
         matnr    TYPE matnr,      " Material Number
         kunnr    TYPE kunnr,
         land1    TYPE land1_gp,
         batch    TYPE charg_d,    " Batch Number
         zcustgrp TYPE zcustgrp,
       END OF ty_input.

TYPES: BEGIN OF ty_input_f,
         mandt    TYPE mandt,
         matnr    TYPE matnr,      " Material Number
         kunnr    TYPE kunnr,
         land1    TYPE land1_gp,
         batch    TYPE charg_d,    " Batch Number
         zcustgrp TYPE zcustgrp,
       END OF ty_input_f.

*     Input Structure containing the Error Message
TYPES: BEGIN           OF ty_input_e,
         recno   TYPE string,
         matnr   TYPE matnr,      " Material Number
         kunnr   TYPE kunnr,
         land1   TYPE land1_gp,
         batch   TYPE charg_d,    " Batch Number
         message TYPE cacl_string, " message text
       END             OF ty_input_e.

* Table Type Declaration
TYPES: ty_t_input_e TYPE STANDARD TABLE OF ty_input_e      INITIAL SIZE 0, "For Input with error
       ty_t_input   TYPE STANDARD TABLE OF ty_input        INITIAL SIZE 0, "Table type of Input.
       ty_t_input_f TYPE STANDARD TABLE OF ty_input_f        INITIAL SIZE 0. "Table type of Input.

DATA: i_input     TYPE ty_t_input,    "For Input data
      i_final     TYPE ty_t_input_f,
      i_input_err TYPE ty_t_input_e.

DATA:
  go_grid_501       TYPE REF TO cl_gui_alv_grid, "#EC NEEDED "grid object
  go_container_0501 TYPE REF TO cl_gui_custom_container. "#EC NEEDED "container object

"Global Constants
CONSTANTS :
  c_container       TYPE char12 VALUE 'GC_CONTAINER'.

DATA:
  gv_matnr      TYPE matnr,
  gv_kunnr      TYPE kunnr,
  gv_cntry      TYPE kna1-land1,
  gv_batch      TYPE mch1-charg,
  gv_custgrp    TYPE zotc_custgrp_asn-zcustgrp,
  gv_okcode     TYPE syucomm,                               "#EC NEEDED
  gv_set_ok_hit TYPE char1    VALUE 'X', "#EC NEEDED     "flag for scr count
  gv_filter     TYPE flag VALUE 'X', "#EC NEEDED      "filter for expand/collapse
  gv_file       TYPE localfile,
*--->Begin of Insert for D3_OTC_EDD_0323_Defect#9407 by U103061 on 01-Jul-2019
  gv_land1      TYPE zotc_custgrp_asn-land1. " Country
*--->End of Insert for D3_OTC_EDD_0323_Defect#9407 by U103061 on 01-Jul-2019

CONSTANTS:
  c_update      TYPE char1        VALUE 'L',           "Transaction update
  c_text        TYPE char3         VALUE 'TXT',                         "Extension .TXT
  c_field_style TYPE string       VALUE 'FIELD_STYLE',
  c_color_row   TYPE string       VALUE 'COLOR_ROW',
  c_tcode_vch1  TYPE tstc-tcode   VALUE 'VCH1',        " Tcode name
  c_tcode_vch2  TYPE tstc-tcode   VALUE 'VCH2',
  c_add         TYPE c            VALUE 'A',
  c_chng        TYPE c            VALUE 'C',
  c_del         TYPE c            VALUE 'X',
  c_validto(8)  TYPE c            VALUE '99991231',
  c_filetype    TYPE char10       VALUE 'ASC'.                         "File type

TYPES:
  ty_t_bdcdata TYPE STANDARD TABLE OF bdcdata    INITIAL SIZE 0, " For bdc data
  ty_t_bdcmsg  TYPE STANDARD TABLE OF bdcmsgcoll INITIAL SIZE 0. "BDC message

DATA:
  i_output       TYPE zotc_custgrp_matbatch_tt,
  i_output_del   TYPE zotc_custgrp_matbatch_tt,
  i_output_add   TYPE zotc_custgrp_matbatch_tt,
  i_output_chg   TYPE zotc_custgrp_matbatch_tt,
  i_exclude_0501 TYPE ui_functions,                 "table to exclude toolbar buttons
  i_fcat_0501    TYPE STANDARD TABLE OF lvc_s_fcat. "fieldcatalog

FIELD-SYMBOLS:
  <gfs_fcat>   TYPE lvc_s_fcat,                             "#EC NEEDED
  <gfs_output> TYPE zotc_custgrp_matbatch_str.

*----------------------------------------------------------------------*
*       CLASS lcl_event_handlers DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handlers DEFINITION.                    "#EC CLAS_FINAL
  PUBLIC SECTION.

    METHODS handle_toolbar_set
                  FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object.

    METHODS handle_user_command
                  FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.

    METHODS handle_data_changed
                  FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed.

ENDCLASS.                    "lcl_event_handlers DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_event_handlers IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handlers IMPLEMENTATION.

  METHOD handle_toolbar_set.

    DATA: lwa_toolbar  TYPE stb_button.

    MOVE 'VIEW_LOG' TO lwa_toolbar-function.
    MOVE icon_view_list TO lwa_toolbar-icon.
    MOVE 'View Log'(017) TO lwa_toolbar-quickinfo.
    MOVE ' ' TO lwa_toolbar-disabled.
    APPEND lwa_toolbar TO e_object->mt_toolbar.

    MOVE 'COPY_ROW' TO lwa_toolbar-function.
    MOVE icon_copy_object TO lwa_toolbar-icon.
    MOVE 'Copy Row'(014) TO lwa_toolbar-quickinfo.
    MOVE ' ' TO lwa_toolbar-disabled.
    APPEND lwa_toolbar TO e_object->mt_toolbar.

    MOVE 'ADD_ROW' TO lwa_toolbar-function.
    MOVE icon_insert_row TO lwa_toolbar-icon.
    MOVE 'Add Row'(015) TO lwa_toolbar-quickinfo.
    MOVE ' ' TO lwa_toolbar-disabled.
    APPEND lwa_toolbar TO e_object->mt_toolbar.

    MOVE 'DEL_ROW' TO lwa_toolbar-function.
    MOVE icon_delete TO lwa_toolbar-icon.
    MOVE 'Delete Row'(016) TO lwa_toolbar-quickinfo.
    MOVE ' ' TO lwa_toolbar-disabled.
    APPEND lwa_toolbar TO e_object->mt_toolbar.

    MOVE 'LOAD_FILE' TO lwa_toolbar-function.
    MOVE icon_write_file TO lwa_toolbar-icon.
    MOVE 'Upload File'(018) TO lwa_toolbar-quickinfo.
    MOVE ' ' TO lwa_toolbar-disabled.
    APPEND lwa_toolbar TO e_object->mt_toolbar.

  ENDMETHOD.                    "handle_toolbar_set

  METHOD handle_user_command.

    DATA:
      li_row_no    TYPE lvc_t_roid,
      lwa_output   TYPE zotc_custgrp_matbatch_str,
      lwa_output_a TYPE zotc_custgrp_matbatch_str,
      lwa_row_no   TYPE lvc_s_roid,
      lv_index     TYPE i,
      lwa_custgrp  TYPE zotc_custgrp_asn,
      li_custgrp   TYPE TABLE OF zotc_custgrp_asn.

    FIELD-SYMBOLS:
      <fs_output>      TYPE zotc_custgrp_matbatch_str.

    CASE e_ucomm.
      WHEN 'COPY_ROW'.
        CALL METHOD go_grid_501->get_selected_rows
          IMPORTING
            et_row_no = li_row_no.

        LOOP AT li_row_no INTO lwa_row_no.
          LOOP AT i_output INTO lwa_output.
            lv_index = sy-tabix.
            IF lv_index EQ lwa_row_no-row_id.
              APPEND lwa_output TO i_output_add.
              lwa_output_a = lwa_output.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
        lwa_output_a-flag = 'A'.
        APPEND lwa_output_a TO i_output.
      WHEN 'ADD_ROW'.
        CLEAR : lwa_output.
        lwa_output-flag = 'A'.
        APPEND lwa_output TO i_output.
      WHEN 'DEL_ROW'.
        CALL METHOD go_grid_501->get_selected_rows
          IMPORTING
*           et_index_rows = li_selected_rows
            et_row_no = li_row_no.

        LOOP AT li_row_no INTO lwa_row_no.
          LOOP AT i_output ASSIGNING <fs_output>.
            lv_index = sy-tabix.
            IF lv_index EQ lwa_row_no-row_id.
              <fs_output>-flag = 'X'.
            ENDIF.
          ENDLOOP.
        ENDLOOP.

        LOOP AT i_output ASSIGNING <fs_output>
                         WHERE flag = 'X'.
          lwa_custgrp-mandt    = sy-mandt.
          lwa_custgrp-matnr    = <fs_output>-matnr.
          lwa_custgrp-kunnr    = <fs_output>-kunwe.
          lwa_custgrp-land1    = <fs_output>-land1.
          lwa_custgrp-batch    = <fs_output>-charg.
          lwa_custgrp-zcustgrp = <fs_output>-zcustgrp.
          APPEND lwa_custgrp TO li_custgrp.
        ENDLOOP.

        IF li_custgrp IS NOT INITIAL.
          DELETE zotc_custgrp_asn FROM TABLE li_custgrp.
          IF sy-subrc EQ 0.
*--->Begin of Insert for D3_OTC_EDD_0323_Defect#9407 by U103061 on 01-Jul-2019
            DELETE i_output WHERE flag = abap_true. "Delete selected Line from the screen.
*--->End of Insert for D3_OTC_EDD_0323_Defect#9407 by U103061 on 01-Jul-2019
            MESSAGE 'Successfully Deleted Records' TYPE 'I'.
          ENDIF.
        ENDIF.

        CALL METHOD go_grid_501->refresh_table_display.
      WHEN 'VIEW_LOG'.
        CALL METHOD go_grid_501->refresh_table_display.

      WHEN 'LOAD_FILE'.
        PERFORM f_help_l_path CHANGING gv_file.
*   Validating the Input File Name
        PERFORM f_validate_p_file USING gv_file.
*   Checking for ".TXT" extension.
        PERFORM f_check_extension USING gv_file.

        PERFORM f_upload_pres USING    gv_file
                              CHANGING i_input[].

        IF i_input IS INITIAL.
*   Input file contains no record. Please check your entry.
          MESSAGE 'Input file contains no record, check entry' TYPE 'I'.
          LEAVE LIST-PROCESSING.
        ELSE. " ELSE -> IF i_input IS INITIAL
*   Validating Input File
          PERFORM f_validate_input.

          PERFORM f_load_file.

        ENDIF.

        CALL METHOD go_grid_501->refresh_table_display.
    ENDCASE.
    SORT i_output BY matnr kunwe DESCENDING.
    CALL METHOD go_grid_501->refresh_table_display.
  ENDMETHOD.                    "handle_user_command

  METHOD handle_data_changed.

    DATA: lwa_good    TYPE lvc_s_modi,
          lv_temp_str TYPE string.

*--->Begin of Insert for D3_OTC_EDD_0323_Defect#9407 by U103061 on 01-Jul-2019
*Declaring Local Constant.
    CONSTANTS: lc_a    TYPE char1 VALUE 'A',         " To set Flag A for Append
               lc_c    TYPE char1 VALUE 'C',         " To set Flag C for Changes
               lc_land TYPE char10 VALUE 'LAND1'. " Fieldname
*--->End of Insert for D3_OTC_EDD_0323_Defect#9407 by U103061 on 01-Jul-2019

    FIELD-SYMBOLS:
          <fs_output>  TYPE zotc_custgrp_matbatch_str.

    CALL METHOD go_grid_501->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

    LOOP AT er_data_changed->mt_good_cells INTO lwa_good.
      CALL METHOD er_data_changed->get_cell_value
        EXPORTING
          i_row_id    = lwa_good-row_id
          i_fieldname = lwa_good-fieldname
        IMPORTING
          e_value     = lv_temp_str.
      IF sy-subrc EQ 0.
        CASE lwa_good-fieldname.
          WHEN 'MATNR'.
            gv_matnr = lv_temp_str.
            READ TABLE i_output ASSIGNING <fs_output> INDEX lwa_good-row_id.
            IF sy-subrc EQ 0.
              <fs_output>-matnr = gv_matnr.
              IF <fs_output>-flag NE 'A'.
                <fs_output>-flag  = 'C'.
              ENDIF.
            ENDIF.
          WHEN 'KUNWE'.
            gv_kunnr = lv_temp_str.
            READ TABLE i_output ASSIGNING <fs_output> INDEX lwa_good-row_id.
            IF sy-subrc EQ 0.
              <fs_output>-kunwe = gv_kunnr.
              IF <fs_output>-flag NE 'A'.
                <fs_output>-flag  = 'C'.
              ENDIF.
            ENDIF.
          WHEN 'CHARG'.
            gv_batch = lv_temp_str.
            IF gv_batch IS INITIAL.
              MESSAGE e093.
            ENDIF.

            READ TABLE i_output ASSIGNING <fs_output> INDEX lwa_good-row_id.
            IF sy-subrc EQ 0.
              <fs_output>-charg = gv_batch.
              IF <fs_output>-flag NE 'A'.
                <fs_output>-flag  = 'C'.
              ENDIF.
            ENDIF.
          WHEN 'ZCUSTGRP'.
            gv_custgrp = lv_temp_str.
            READ TABLE i_output ASSIGNING <fs_output> INDEX lwa_good-row_id.
            IF sy-subrc EQ 0.
              <fs_output>-zcustgrp = gv_custgrp.
              IF <fs_output>-flag NE 'A'.
                <fs_output>-flag  = 'C'.
              ENDIF.
            ENDIF.
*--->Begin of Insert for D3_OTC_EDD_0323_Defect#9407 by U103061 on 01-Jul-2019
          WHEN lc_land. "Country updating its flag
            gv_land1 = lv_temp_str.
            READ TABLE i_output ASSIGNING <fs_output> INDEX lwa_good-row_id.
            IF sy-subrc EQ 0.
              <fs_output>-land1 = gv_land1.
              IF <fs_output>-flag NE lc_a. "Value LC_A = 'A'
                <fs_output>-flag  = lc_c. "Value LC_C = 'C'
              ENDIF. " IF <fs_output>-flag NE lc_a
            ENDIF. " IF sy-subrc EQ 0
*--->End of Insert for D3_OTC_EDD_0323_Defect#9407 by U103061 on 01-Jul-2019
        ENDCASE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "handle_data_changed

ENDCLASS.                    "lcl_event_handlers IMPLEMENTATION

DATA:
  go_alv_event_0501  TYPE REF TO lcl_event_handlers.

SELECTION-SCREEN BEGIN OF SCREEN 0101 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
SELECT-OPTIONS:
  s_matnr  FOR gv_matnr MODIF ID 1 OBLIGATORY, " Product Number
  s_cusgrp FOR gv_custgrp,
  s_cntry  FOR gv_cntry,
  s_kunnr  FOR gv_kunnr,
  s_batch  FOR gv_batch.
PARAMETERS:
  p_matcus AS CHECKBOX DEFAULT 'X',
  p_matctr AS CHECKBOX
*--->Begin of Insert for D3_OTC_EDD_0323_Defect#9407 by U103061 on 01-Jul-2019
  DEFAULT abap_true. "default X is set
*--->End of Insert for D3_OTC_EDD_0323_Defect#9407 by U103061 on 01-Jul-2019
SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN END OF SCREEN 0101.
