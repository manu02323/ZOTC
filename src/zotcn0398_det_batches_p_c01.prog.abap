*&---------------------------------------------------------------------*
*&  Include           ZOTC_EDD0398_DET_BATCHES_C01
*&---------------------------------------------------------------------*
*&**********************************************************************
* PROGRAM    :  ZOTC_EDD0398_DET_BATCHES                               *
* TITLE      :  Batch Determination at Sales Order                     *
* DEVELOPER  :  Dhanasekar Arumugam                                    *
* OBJECT TYPE:  Enhancement Program                                    *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0398                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Batch determination program will be used as a tool for *
*               automatic batch assignment to sales order lines,       *
*               specifically red-blood cells materials                 *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 24-Jan-2018 DARUMUG  E1DK934038 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*
* 08-April-2018 DDWIVED E1DK934038 CR231- Batch validation and         *
*                                  Clear Batch Functionality           *
*&---------------------------------------------------------------------*

class lcl_alv_event_handler definition final. " Alv_event_handler class
  public section.
    methods handle_toolbar_set
    for event toolbar of cl_gui_alv_grid
    importing e_object.

    methods handle_user_command
        for event user_command of cl_gui_alv_grid
        importing e_ucomm.

    methods   handle_button_click
        for event button_click of cl_gui_alv_grid
        importing es_col_id  es_row_no.

    methods handle_data_changed
        for event data_changed of cl_gui_alv_grid
        importing er_data_changed.

endclass. "lcl_alv_event_handler DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_alv_event_handler IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class lcl_alv_event_handler implementation. " Alv_event_handler class
  method handle_toolbar_set.

    data: lwa_toolbar  type stb_button. " Toolbar Button
    clear lwa_toolbar.
    move 3 to lwa_toolbar-butn_type.
    append lwa_toolbar to e_object->mt_toolbar.
    clear lwa_toolbar.

    move 'CHECKB' to lwa_toolbar-function.
    move icon_checked to lwa_toolbar-icon.
    move 'Check Batch(Ctrl+F11)'(007) to lwa_toolbar-quickinfo.
    move ' ' to lwa_toolbar-disabled.
    append lwa_toolbar to e_object->mt_toolbar.

    move 'CHANGE' to lwa_toolbar-function.
    move icon_change to lwa_toolbar-icon.
    move 'Change(Ctrl+F12)'(008) to lwa_toolbar-quickinfo.
    move ' ' to lwa_toolbar-disabled.
    append lwa_toolbar to e_object->mt_toolbar.

    move 'BATDET' to lwa_toolbar-function.
    move icon_batch to lwa_toolbar-icon.
    move 'Determine Batch(Ctrl+F1)'(009) to lwa_toolbar-quickinfo.
    move ' ' to lwa_toolbar-disabled.
    append lwa_toolbar to e_object->mt_toolbar.

    move 'LOG' to lwa_toolbar-function.
    move icon_history to lwa_toolbar-icon.
    move 'Display Log(Ctrl+F2)'(010) to lwa_toolbar-quickinfo.
    move ' ' to lwa_toolbar-disabled.
    append lwa_toolbar to e_object->mt_toolbar.
*    SOC DDWIVEDI #CR231
    move 'CLEARB' to lwa_toolbar-function.
    move icon_view_refresh to lwa_toolbar-icon.
    move 'Clear Batch(Ctrl+F3)'(011) to lwa_toolbar-quickinfo.
    move ' ' to lwa_toolbar-disabled.
    append lwa_toolbar to e_object->mt_toolbar.
* EOD DDWIVEDI CR#231

  endmethod. "handle_toolbar_set

  method handle_button_click.
    case es_col_id-fieldname.
      when 'CHANGE'.
    endcase.
  endmethod. "handle_button_click

  method handle_user_command.

    data :
      i_selected_rows_501 type lvc_t_row,                   "#EC NEEDED
      lwa_row_no_501      type lvc_s_roid, " Assignment of line number to line ID
      i_row_no_501        type lvc_t_roid,
      lwa_final           type ty_final,
      lv_index            type sy-index.   " Loop Index

    field-symbols:
      <lfs_style>      type lvc_s_styl, " ALV Control: Field Name + Styles
      <lfs_batch>      type ty_batch_final,
      <lfs_batch_t>      type ty_batch_final,
      <lfs_batch_f>    type ty_batch_final,
      <lfs_color_cell> type lvc_s_scol. " ALV control: Structure for cell coloring

    call method o_alv->set_function_code
      changing
        c_ucomm = e_ucomm.

    case e_ucomm.
      when 'CHANGE'.
        loop at i_batch assigning <lfs_batch>.
          loop at <lfs_batch>-field_style assigning <lfs_style>
                                        where fieldname = 'CHARG'.
            <lfs_style>-style = cl_gui_alv_grid=>mc_style_enabled.
          endloop. " LOOP AT <lfs_batch>-field_style ASSIGNING <lfs_style>
        endloop. " LOOP AT i_batch ASSIGNING <lfs_batch>

        call method o_alv->refresh_table_display.

      when 'BATDET'.
        call method o_alv->get_selected_rows
          importing
            et_index_rows = i_selected_rows_501
            et_row_no     = i_row_no_501.

        loop at i_batch assigning <lfs_batch>.
          lv_index = sy-tabix.
          loop at i_row_no_501 into lwa_row_no_501 where row_id = lv_index.
            append <lfs_batch> to i_batch_a.
          endloop. " LOOP AT i_row_no_501 INTO lwa_row_no_501 WHERE row_id = lv_index
        endloop. " LOOP AT i_batch ASSIGNING <lfs_batch>

        perform f_determine_batches.

        loop at i_batch_a assigning <lfs_batch>.
          loop at i_batch assigning <lfs_batch_f>
                          where vbeln = <lfs_batch>-vbeln
                          and   posnr = <lfs_batch>-posnr.
            <lfs_batch_f>-charg = <lfs_batch>-charg.
          endloop. " LOOP AT i_batch ASSIGNING <lfs_batch_f>
        endloop. " LOOP AT i_batch_a ASSIGNING <lfs_batch>
        call method o_alv->refresh_table_display.
      when 'LOG'.
        perform f_display_log.
*     SOC by DDWIVEDI CR#231
      when 'CLEARB'.

        call method o_alv->get_selected_rows
          importing
            et_index_rows = i_selected_rows_501
            et_row_no     = i_row_no_501.

        loop at i_row_no_501 into lwa_row_no_501 .
          read table i_batch  assigning <lfs_batch> index lwa_row_no_501-row_id.
          if sy-subrc eq 0.
            clear <lfs_batch>-charg.
            append <lfs_batch> to i_batch_a.
          endif.
        endloop. " LOOP AT i_row_no_501 INTO lwa_row_no_501
        perform f_clear_batch_in_so.
        call method o_alv->refresh_table_display.
        refresh:  i_selected_rows_501, i_row_no_501 .

      when 'CHECKB'.

        refresh i_batch_a .

        call method o_alv->get_selected_rows
          importing
            et_index_rows = i_selected_rows_501
            et_row_no     = i_row_no_501.

        loop at i_row_no_501 into lwa_row_no_501 .
          read table i_batch  assigning <lfs_batch> index lwa_row_no_501-row_id.
          append <lfs_batch> to i_batch_a.
        endloop. " LOOP AT i_row_no_501 INTO lwa_row_no_501
        perform f_validate_batches.
        perform f_material_availability_check.

        loop at i_batch_a assigning <lfs_batch>.
          if <lfs_batch> is assigned .
            read table i_batch  assigning <lfs_batch_t> with key vbeln  = <lfs_batch>-vbeln
             posnr  = <lfs_batch>-posnr
             matnr   = <lfs_batch>-matnr.
            if <lfs_batch_t> is assigned .
              if sy-subrc = 0 and <lfs_batch>-charg is initial .
                clear <lfs_batch_t>-charg.
              endif. " IF sy-subrc = 0 AND <lfs_batch>-charg IS INITIAL
            endif. " IF <lfs_batch_t> IS ASSIGNED
          endif. " IF <lfs_batch> IS ASSIGNED
        endloop . " LOOP AT i_batch_a ASSIGNING <lfs_batch>
        message ' Check the notes in the log'(d03) type 'S' .
        call method o_alv->refresh_table_display.
        refresh:  i_selected_rows_501, i_row_no_501 , i_batch_a .
*     EOC by DDWIVED
    endcase.

  endmethod. "handle_user_command

  method handle_data_changed.

    perform f_handle_data_change using er_data_changed.
  endmethod. "handle_data_changed
endclass. "lcl_alv_event_handler IMPLEMENTATION
