*&---------------------------------------------------------------------*
*&  Include           ZOTC_EDD0398_DET_BATCHES_F01
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
* 05-Mar-2018 DARUMUG  E1DK934038 CR# 212 Added Corresponding Batch    *
*                                 logic                                *
* 03-May-2018 DARUMUG  E1DK936439 Defect# 5957 Add Multiple SOrg's     *
*                                                                      *
* 11-Sep-2019 U033959  E1SK901543 HANAtization changes
*&---------------------------------------------------------------------*
form f_get_emi_values .
  constants: lc_edd_no type z_enhancement  value 'D3_OTC_EDD_0398'. " Enhancement No.
*  FIELD-SYMBOLS:

  gv_repid = sy-repid.

* Retrieve the constants values for D3_OTC_EDD_0398
  call function 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    exporting
      iv_enhancement_no = lc_edd_no
    tables
      tt_enh_status     = i_edd_emi.
  delete i_edd_emi where active = abap_false.
  if i_edd_emi[] is not initial.
    sort i_edd_emi by criteria sel_low.
  endif. " IF i_edd_emi[] IS NOT INITIAL

endform. " F_GET_EMI_VALUES
*&---------------------------------------------------------------------*
*&      Form  F_GET_ORDERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_get_orders .
  data:
    lwa_vbcom type vbcom. " Communication Work Area for Sales Doc.Access Methods

  data:
    li_lvbmtv type table of vbmtv. " View: Order Items for Material

  lwa_vbcom-zuart     = 'A'.
  lwa_vbcom-trvog     = '0'.
  lwa_vbcom-stat_dazu = 'X'.
  lwa_vbcom-name_dazu = 'X'.
  lwa_vbcom-kopf_dazu = 'X'.
  lwa_vbcom-vboff     = 'X'.

  "From Selection Screen
  lwa_vbcom-werks = s_werks-low.

  perform f_build_selection_tab.

  loop at s_matnr.
    lwa_vbcom-matnr = s_matnr-low.
    call function 'RV_SALES_DOCUMENT_VIEW_3'
      exporting
        vbcom   = lwa_vbcom
      tables
        lvbmtv  = li_lvbmtv
        lseltab = i_lseltab.

    if li_lvbmtv is not initial.
      append lines of li_lvbmtv to i_lvbmtv.
    endif. " IF li_lvbmtv IS NOT INITIAL
    refresh: li_lvbmtv.
  endloop. " LOOP AT s_matnr

  "Get Sales Order Details
  perform f_get_sales_order_details.

endform. " F_GET_ORDERS
*&---------------------------------------------------------------------*
*&      Form  F_GET_SALES_ORDER_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_get_sales_order_details .

  types:
     begin of lty_objnum,
       objek type objnum, " Key of object to be classified
       atinn type atinn,  " Internal characteristic
       atnam type atnam,  " Characteristic Name
     end of lty_objnum,

     begin of lty_atinn,
       atinn type atinn,  " Internal characteristic
     end of lty_atinn,

  begin of lty_vbbe,
    vbeln type vbeln,     " Sales and Distribution Document Number
    posnr type posnr,     " Item number of the SD document
    etenr type etenr,     " Delivery Schedule Line Number
    mbdat type mbdat,     " Material Staging/Availability Date
    omeng type omeng,     " Open Qty in Stockkeeping Units for Transfer of Reqmts to MRP
    meins type meins,     " Base Unit of Measure
    auart type auart,     " Sales Document Type
  end of lty_vbbe,

  begin of lty_koth916,
    kappl	type kappl,
    kschl	type kschh,
    vkorg	type vkorg,
    vtweg	type vtweg,
    kunnr	type kunnr,
    matnr	type matnr,
    knumh	type knumh,
  end of lty_koth916,

  begin of lty_ausp,
    objek type objnum,    " Key of object to be classified
    atinn type atinn,     " Internal characteristic
    atwrt type atwrt,     " Characteristic Value
  end of lty_ausp,

  begin of lty_cabn,
    atinn type atinn,     " Internal characteristic
    atnam type atnam,     " Characteristic Name
  end of lty_cabn.

  data:
   lwa_vbbe   type lty_vbbe,
   lwa_vbep   type ty_vbep,
   lwa_vbep_c type ty_vbep_c,

   li_koth916  type table of lty_koth916,
   lwa_koth916 type lty_koth916,

   li_kondh   type table of kondh,   " Conditions: Batch Strategy - Data Division
   lwa_kondh  type kondh,            " Conditions: Batch Strategy - Data Division

   li_ausp  type table of lty_ausp,
   lwa_ausp type lty_ausp,

   lwa_objek type lty_objnum,
   li_objek  type table of lty_objnum,

   lwa_atinn type lty_atinn,
   li_atinn  type table of lty_atinn,

   li_vbbe type table of lty_vbbe,

   lwa_edd_emi type zdev_enh_status. " Enhancement Status for EDD

  data:
   li_edd_emi    type standard table of zdev_enh_status, " Enhancement Status
   lv_atinn_anti type atinn,                             " Internal characteristic
   lv_atinn_corr type atinn,                             " Internal characteristic
   lv_index      type sy-tabix,                          " Index of Internal Tables
   lwa_lvbmtv    type vbmtv,                             " View: Order Items for Material
   lwa_batch     type ty_batch_final,
   li_cabn       type standard table of lty_cabn initial size 0,
   lwa_cabn      type lty_cabn.

  constants:
   lc_ausp     type char10 value 'BATCH_CHAR',       " Ausp of type CHAR10
   lc_adzhl    type char4 value '0000',              " Adzhl of type CHAR4
   lc_antigens type atnam value 'ANTIGENS',          " Characteristic Name
   lc_cor      type atnam value 'CORRESPONDING',     " Characteristic Name
   lc_noncor   type atnam value 'NON CORRESPONDING', " Characteristic Name
   lc_corres   type atnam value 'CORR_PAP_BAT'.      " Characteristic Name

  clear: lv_atinn_anti,
         lv_atinn_corr.

  loop at i_edd_emi into lwa_edd_emi
                    where criteria = lc_ausp.
    clear lv_atinn_anti.
    select atinn atnam
                 from cabn up to 1 rows
                 into lwa_cabn
                 where atnam = lwa_edd_emi-sel_low
                 and   adzhl = lc_adzhl.
    endselect.
    if sy-subrc eq 0.
      append lwa_cabn to li_cabn.
    endif. " IF sy-subrc EQ 0
  endloop. " LOOP AT i_edd_emi INTO lwa_edd_emi

  select single atinn from cabn " Characteristic
               into lv_atinn_anti
               where atnam = 'ANTIGENS'.

  select single atinn from cabn " Characteristic
               into lv_atinn_corr
               where atnam = 'CORR_PAP_BAT'.

  if i_lvbmtv is not initial.

    select vbeln posnr etenr
           edatu wmeng lmeng mbuhr
             from vbep " Sales Document: Schedule Line Data
             into table i_vbep
             for all entries in i_lvbmtv
             where vbeln = i_lvbmtv-vbeln and
                   posnr = i_lvbmtv-posnr and
                   edatu between s_rqdate-low and s_rqdate-high.
    sort i_vbep by vbeln posnr.
    loop at i_vbep into lwa_vbep.
      lwa_vbep_c-vbeln = lwa_vbep-vbeln.
      lwa_vbep_c-posnr = lwa_vbep-posnr.
      lwa_vbep_c-wmeng = lwa_vbep-wmeng.
      lwa_vbep_c-lmeng = lwa_vbep-lmeng.
      collect lwa_vbep_c into i_vbep_c.
    endloop. " LOOP AT i_vbep INTO lwa_vbep

    delete i_vbep where etenr ne '0001'.

    clear lv_index.
    loop at i_lvbmtv into lwa_lvbmtv.
      lv_index = sy-tabix.
      read table i_vbep into lwa_vbep
                        with key vbeln = lwa_lvbmtv-vbeln
                                 posnr = lwa_lvbmtv-posnr
                        binary search.
      if sy-subrc ne 0.
        delete i_lvbmtv index lv_index.
      endif. " IF sy-subrc NE 0
    endloop. " LOOP AT i_lvbmtv INTO lwa_lvbmtv

    select vbeln posnr etenr mbdat
           omeng meins auart
             from vbbe " Sales Requirements: Individual Records
             into table li_vbbe
             for all entries in i_lvbmtv
             where vbeln = i_lvbmtv-vbeln and
                   posnr = i_lvbmtv-posnr and
                   etenr = '0001'.
    sort li_vbbe by vbeln posnr.

    select kappl kschl vkorg vtweg
           kunnr matnr knumh
             from koth916 " Sales org./Distr. Chl/Customer/Material
             into table li_koth916
             for all entries in i_lvbmtv
             where vkorg = i_lvbmtv-vkorg and
                   vtweg = i_lvbmtv-vtweg and
                   matnr = i_lvbmtv-matnr and
                   kunnr = i_lvbmtv-kunnr.

    sort li_koth916 by knumh.

    if li_koth916 is not initial.
      select * from kondh " Conditions: Batch Strategy - Data Division
              into table li_kondh
              for all entries in li_koth916
              where knumh = li_koth916-knumh.
      sort li_kondh by knumh.
    endif. " IF li_koth916 IS NOT INITIAL

    if li_kondh is not initial.
      loop at li_kondh  into lwa_kondh.
        lwa_objek-objek = lwa_kondh-cuobj_ch.
        loop at li_cabn into lwa_cabn.
          lwa_objek-atinn = lwa_cabn-atinn.
          lwa_objek-atnam = lwa_cabn-atnam.
          append lwa_objek to li_objek.
        endloop. " LOOP AT li_cabn INTO lwa_cabn
      endloop. " LOOP AT li_kondh INTO lwa_kondh

      if li_objek is not initial.
        select objek atinn atwrt from ausp " Characteristic Values
                into table li_ausp
                for all entries in li_objek
                where objek = li_objek-objek
                and   atinn = lv_atinn_anti.

        select objek atinn atwrt from ausp " Characteristic Values
                appending table li_ausp
                for all entries in li_objek
                where objek = li_objek-objek
                and   atinn = lv_atinn_corr.

      endif. " IF li_objek IS NOT INITIAL
    endif. " IF li_kondh IS NOT INITIAL

  endif. " IF i_lvbmtv IS NOT INITIAL

  sort li_koth916 by vkorg vtweg matnr.

  loop at i_lvbmtv into lwa_lvbmtv.

    read table i_vbep into lwa_vbep
                       with key vbeln = lwa_lvbmtv-vbeln
                                posnr = lwa_lvbmtv-posnr
                                binary search.
    if sy-subrc eq 0.
      lwa_batch-edatu    = lwa_vbep-edatu.

      lwa_batch-vbeln    = lwa_lvbmtv-vbeln  .
      lwa_batch-posnr    = lwa_lvbmtv-posnr  .
      lwa_batch-matnr    = lwa_lvbmtv-matnr  .
      lwa_batch-kwmeng   = lwa_lvbmtv-kwmeng .
      lwa_batch-bmeng    = lwa_lvbmtv-bmeng  .
      lwa_batch-kunnr    = lwa_lvbmtv-kunnr  .
      lwa_batch-name1    = lwa_lvbmtv-name1  .
      lwa_batch-vkorg    = lwa_lvbmtv-vkorg  .
      lwa_batch-vtweg    = lwa_lvbmtv-vtweg  .
      lwa_batch-werks    = lwa_lvbmtv-werks  .
      lwa_batch-charg    = lwa_lvbmtv-charg  .
      lwa_batch-lifsk    = lwa_lvbmtv-lifsk  .
      lwa_batch-auart_sd = lwa_lvbmtv-auart  .

      read table li_vbbe into lwa_vbbe
                         with key vbeln = lwa_batch-vbeln
                                  posnr = lwa_batch-posnr
                                  binary search.
      if sy-subrc eq 0.
        lwa_batch-omeng = lwa_vbbe-omeng.
        lwa_batch-auart = lwa_vbbe-auart.
        lwa_batch-uom   = lwa_vbbe-meins.
        lwa_batch-mbdat = lwa_vbbe-mbdat.
      endif. " IF sy-subrc EQ 0

      loop at li_koth916 into lwa_koth916
                            where vkorg = lwa_batch-vkorg and
                                     vtweg = lwa_batch-vtweg and
                                     matnr = lwa_batch-matnr and
                                     kunnr = lwa_batch-kunnr.

        read table li_kondh into lwa_kondh
                              with key knumh = lwa_koth916-knumh
                              binary search.
        if sy-subrc eq 0.
          lwa_objek-objek = lwa_kondh-cuobj_ch.

          read table li_ausp into lwa_ausp
                             with key objek = lwa_objek-objek
                                      atinn = lv_atinn_anti.
          if sy-subrc = 0.
            lwa_batch-antigens = lwa_ausp-atwrt.
          endif. " IF sy-subrc = 0

          read table li_ausp into lwa_ausp
                             with key objek = lwa_objek-objek
                                      atinn = lv_atinn_corr.
          if sy-subrc = 0.
            lwa_batch-corres = lwa_ausp-atwrt.
          endif. " IF sy-subrc = 0
        endif. " IF sy-subrc EQ 0
        clear: lwa_ausp,
               lwa_objek.
      endloop. " LOOP AT li_koth916 INTO lwa_koth916

      append lwa_batch to i_batch.
    endif. " IF sy-subrc EQ 0
    clear lwa_batch.
  endloop. " LOOP AT i_lvbmtv INTO lwa_lvbmtv

  perform f_insert_style.

  "Display the orders w/o batch
  if p_unso is not initial.
    delete i_batch where charg is not initial.
  endif. " IF p_unso IS NOT INITIAL

endform. " F_GET_SALES_ORDER_DETAILS
*&---------------------------------------------------------------------*
*&      Form  F_INITIALIZE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_initialize_alv .

  data: li_excl_tools type ui_functions, " Function code
        li_fcat       type lvc_t_fcat,
        lwa_layout     type lvc_s_layo.  " ALV control: Layout structure

  if o_container is initial.
    "Initialize the container
    create object o_container
      exporting
        container_name = 'CCTL_ATP_GRID'.
  endif. " IF o_container IS INITIAL

  if o_alv is initial.
    "Initialize the ALV grid
    create object o_alv
      exporting
        i_parent = o_container.

    free o_alv_event.

    create object o_alv_event.
    set handler:
                 o_alv_event->handle_toolbar_set  for o_alv,
                 o_alv_event->handle_user_command for o_alv,
                 o_alv_event->handle_button_click for o_alv,
                 o_alv_event->handle_data_changed for o_alv.

*  SOC by DDWIVEDI CR#231.

    call method o_alv->register_edit_event
      exporting
        i_event_id = cl_gui_alv_grid=>mc_evt_enter
      exceptions
        error      = 1
        others     = 2.
*   EOC by DDWIVEDI CR# 231.

    perform f_build_field_catalog changing li_fcat.

    append:
            cl_gui_alv_grid=>mc_fc_info              to li_excl_tools,
            cl_gui_alv_grid=>mc_fc_help              to li_excl_tools,
            cl_gui_alv_grid=>mc_mb_view              to li_excl_tools,
            cl_gui_alv_grid=>mc_fc_graph             to li_excl_tools,
            cl_gui_alv_grid=>mc_mb_variant           to li_excl_tools,
            cl_gui_alv_grid=>mc_fc_loc_cut           to li_excl_tools,
            cl_gui_alv_grid=>mc_fc_loc_copy          to li_excl_tools,
            cl_gui_alv_grid=>mc_fc_loc_paste         to li_excl_tools,
            cl_gui_alv_grid=>mc_fc_loc_copy_row      to li_excl_tools,
            cl_gui_alv_grid=>mc_fc_loc_move_row      to li_excl_tools,
            cl_gui_alv_grid=>mc_fc_loc_delete_row    to li_excl_tools,
            cl_gui_alv_grid=>mc_fc_loc_insert_row    to li_excl_tools,
            cl_gui_alv_grid=>mc_fc_loc_append_row    to li_excl_tools,
            cl_gui_alv_grid=>mc_fc_loc_paste_new_row to li_excl_tools,
            cl_gui_alv_grid=>mc_fc_sort              to li_excl_tools,
            cl_gui_alv_grid=>mc_fc_sort_asc          to li_excl_tools,
            cl_gui_alv_grid=>mc_fc_sort_dsc          to li_excl_tools.

    lwa_layout-edit       = c_true.
    lwa_layout-stylefname = c_field_style.
    lwa_layout-ctab_fname = c_color_cell.
    lwa_layout-info_fname = c_color_row.
    lwa_layout-zebra      = 'X'.
    lwa_layout-sel_mode   = 'A'.

    "Set up grid for first display
    call method o_alv->set_table_for_first_display
      exporting
        is_layout            = lwa_layout
        it_toolbar_excluding = li_excl_tools
      changing
        it_fieldcatalog      = li_fcat
        it_outtab            = i_batch.

  else. " ELSE -> IF o_alv IS INITIAL
    "Refresh Field Catalog
    perform f_build_field_catalog changing li_fcat.

    "Refresh ALV grid display
    call method o_alv->refresh_table_display.
  endif. " IF o_alv IS INITIAL

endform. " F_INITIALIZE_ALV
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_FCAT  text
*----------------------------------------------------------------------*
form f_build_field_catalog  changing   ct_fcat type lvc_t_fcat.
  data lwa_fcat type lvc_s_fcat. " ALV control: Field catalog

  lwa_fcat-fieldname = 'VBELN'.
  lwa_fcat-col_pos   = 0.
  lwa_fcat-outputlen = 10.
  lwa_fcat-coltext   = 'Sales Document'(t01).
  append lwa_fcat to ct_fcat.
  clear  lwa_fcat.

  lwa_fcat-fieldname = 'POSNR'.
  lwa_fcat-col_pos   = 1.
  lwa_fcat-outputlen = 4.
  lwa_fcat-coltext   = 'Item'(t02).
  append lwa_fcat to ct_fcat.
  clear  lwa_fcat.

  lwa_fcat-fieldname = 'MATNR'.
  lwa_fcat-col_pos   = 2.
  lwa_fcat-outputlen = 15.
  lwa_fcat-coltext   = 'Material'(t03).
  append lwa_fcat to ct_fcat.
  clear  lwa_fcat.

  lwa_fcat-fieldname = 'KWMENG'.
  lwa_fcat-col_pos   = 3.
  lwa_fcat-outputlen = 10.
  lwa_fcat-coltext   = 'Requested Quantity'(t04).
  lwa_fcat-decimals_o = 0. "Defect#5957
  append lwa_fcat to ct_fcat.
  clear  lwa_fcat.

  lwa_fcat-fieldname = 'OMENG'.
  lwa_fcat-col_pos   = 4.
  lwa_fcat-outputlen = 10.
  lwa_fcat-coltext   = 'Open Quantity'(t05).
  lwa_fcat-decimals_o = 0. "Defect#5957
  append lwa_fcat to ct_fcat.
  clear  lwa_fcat.

  lwa_fcat-fieldname = 'BMENG'.
  lwa_fcat-col_pos   = 5.
  lwa_fcat-outputlen = 10.
  lwa_fcat-coltext   = 'Confirmed Quantity'(t06).
  lwa_fcat-decimals_o = 0. "Defect#5957
  append lwa_fcat to ct_fcat.
  clear  lwa_fcat.

  lwa_fcat-fieldname = 'KUNNR'.
  lwa_fcat-col_pos   = 6.
  lwa_fcat-outputlen = 10.
  lwa_fcat-coltext   = 'Customer'(t07).
  append lwa_fcat to ct_fcat.
  clear  lwa_fcat.

  lwa_fcat-fieldname = 'NAME1'.
  lwa_fcat-col_pos   = 7.
  lwa_fcat-outputlen = 20.
  lwa_fcat-coltext   = 'Customer Description'(t08).
  append lwa_fcat to ct_fcat.
  clear  lwa_fcat.

  lwa_fcat-fieldname = 'VKORG'.
  lwa_fcat-col_pos   = 8.
  lwa_fcat-outputlen = 4.
  lwa_fcat-coltext   = 'Sales Organization'(t09).
  append lwa_fcat to ct_fcat.
  clear  lwa_fcat.

  lwa_fcat-fieldname = 'VTWEG'.
  lwa_fcat-col_pos   = 9.
  lwa_fcat-outputlen = 4.
  lwa_fcat-coltext   = 'Distribution Channel'(t10).
  append lwa_fcat to ct_fcat.
  clear  lwa_fcat.

  lwa_fcat-fieldname = 'WERKS'.
  lwa_fcat-col_pos   = 10.
  lwa_fcat-outputlen = 4.
  lwa_fcat-coltext   = 'Plant'(t11).
  append lwa_fcat to ct_fcat.
  clear  lwa_fcat.

  lwa_fcat-fieldname = 'EDATU'.
  lwa_fcat-col_pos   = 11.
  lwa_fcat-outputlen = 10.
  lwa_fcat-coltext   = 'Req. Delivery Date'(t12).
  append lwa_fcat to ct_fcat.
  clear  lwa_fcat.

  lwa_fcat-fieldname = 'CHARG'.
  lwa_fcat-col_pos   = 12.
  lwa_fcat-outputlen = 10.
  lwa_fcat-coltext   = 'Batch'(t13).
  append lwa_fcat to ct_fcat.
  clear  lwa_fcat.

  lwa_fcat-fieldname = 'LIFSK'.
  lwa_fcat-col_pos   = 13.
  lwa_fcat-outputlen = 9.
  lwa_fcat-coltext   = 'Delivery Block'(t14).
  append lwa_fcat to ct_fcat.
  clear  lwa_fcat.

  lwa_fcat-fieldname = 'VTEXT'.
  lwa_fcat-col_pos   = 14.
  lwa_fcat-outputlen = 11.
  lwa_fcat-coltext   = 'Delivery Block Description'(t15).
  append lwa_fcat to ct_fcat.
  clear  lwa_fcat.

  lwa_fcat-fieldname = 'ANTIGENS'.
  lwa_fcat-col_pos   = 14.
  lwa_fcat-outputlen = 10.
  lwa_fcat-coltext   = 'Antigens'(t16).
  append lwa_fcat to ct_fcat.
  clear  lwa_fcat.

  lwa_fcat-fieldname = 'CORRES'.
  lwa_fcat-col_pos   = 15.
  lwa_fcat-outputlen = 10.
  lwa_fcat-coltext   = 'Corresponding'(t17).
  append lwa_fcat to ct_fcat.
  clear  lwa_fcat.

endform. " F_BUILD_FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_display_report .
  call screen 501.
endform. " F_DISPLAY_REPORT
*&---------------------------------------------------------------------*
*&      Form  F_LOCK_ORDERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_lock_orders .

  data:
    lv_index  type sy-tabix, " Index of Internal Tables
    lwa_final type ty_final,
    lwa_batch type ty_batch_final.

  loop at i_batch into lwa_batch.
    lv_index  = sy-tabix.
    call function 'ENQUEUE_EVVBAKE'
      exporting
        vbeln          = lwa_batch-vbeln
      exceptions
        foreign_lock   = 1
        system_failure = 2
        others         = 3.
    if sy-subrc ne 0.
*       sales order could not be locked
      message e000 with 'Sales Order could not be locked'(022) into lwa_final-message.
      move 'E'      to lwa_final-status.
      move lwa_batch-vbeln to lwa_final-vbeln.
      move lwa_batch-posnr to lwa_final-posnr.
      append lwa_final to i_log_f.
      delete i_batch index lv_index.
    endif. " IF sy-subrc NE 0
  endloop. " LOOP AT i_batch INTO lwa_batch

endform. " F_LOCK_ORDERS
*&---------------------------------------------------------------------*
*&      Form  F_SEQUENCE_BATCHES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_sequence_batches .

  constants:
      lc_antigens   type string value 'ANTIGENS',
      lc_corres     type string value 'CORRESPONDING',
      lc_noncorres  type string value 'NON CORRESPONDING',
      lc_ordtyp_std type string value 'ZSTD',
      lc_ordtyp_or  type string value 'ZOR',
      lc_ordtyp_int type string value 'ZINT',
      lc_prior_1a   type string value 'A',
      lc_prior_1b   type string value 'B',
      lc_prior_1c   type string value 'C',
      lc_prior_2a   type string value 'D',
      lc_prior_2b   type string value 'E',
      lc_prior_2c   type string value 'F',
      lc_prior_3a   type string value 'G',
      lc_prior_3b   type string value 'H',
      lc_prior_3c   type string value 'I',
      lc_prior_4a   type string value 'J',
      lc_prior_4b   type string value 'K',
      lc_prior_4c   type string value 'L',
      lc_prior_5a   type string value 'M',
      lc_prior_5b   type string value 'N',
      lc_prior_5c   type string value 'O',
      lc_prior_5d   type string value 'P'.

  field-symbols:
    <lfs_batch> type ty_batch_final.

  sort i_batch by auart.

  loop at i_batch assigning <lfs_batch>.
    case <lfs_batch>-auart.
      when lc_ordtyp_std.
        if <lfs_batch>-corres = lc_corres.
          <lfs_batch>-prior = lc_prior_1a.
        elseif <lfs_batch>-corres = lc_noncorres.
          <lfs_batch>-prior = lc_prior_1b.
        elseif <lfs_batch>-antigens ne space.
          <lfs_batch>-prior = lc_prior_1c.
        elseif <lfs_batch>-antigens eq space and
               <lfs_batch>-corres   eq space.
          <lfs_batch>-prior = lc_prior_5a.
        endif. " IF <lfs_batch>-corres = lc_corres
      when lc_ordtyp_or.
        if <lfs_batch>-corres = lc_corres.
          <lfs_batch>-prior = lc_prior_2a.
        elseif <lfs_batch>-corres = lc_noncorres.
          <lfs_batch>-prior = lc_prior_2b.
        elseif <lfs_batch>-antigens ne space.
          <lfs_batch>-prior = lc_prior_2c.
        elseif <lfs_batch>-antigens eq space and
               <lfs_batch>-corres   eq space.
          <lfs_batch>-prior = lc_prior_5b.
        endif. " IF <lfs_batch>-corres = lc_corres
      when lc_ordtyp_int.
        if <lfs_batch>-corres = lc_corres.
          <lfs_batch>-prior = lc_prior_3a.
        elseif <lfs_batch>-corres = lc_noncorres.
          <lfs_batch>-prior = lc_prior_3b.
        elseif <lfs_batch>-antigens ne space.
          <lfs_batch>-prior = lc_prior_3c.
        elseif <lfs_batch>-antigens eq space and
               <lfs_batch>-corres   eq space.
          <lfs_batch>-prior = lc_prior_5c.
        endif. " IF <lfs_batch>-corres = lc_corres
      when others.
        if <lfs_batch>-corres = lc_corres.
          <lfs_batch>-prior = lc_prior_4a.
        elseif <lfs_batch>-corres = lc_noncorres.
          <lfs_batch>-prior = lc_prior_4b.
        elseif <lfs_batch>-antigens ne space.
          <lfs_batch>-prior = lc_prior_4c.
        elseif <lfs_batch>-antigens eq space and
               <lfs_batch>-corres   eq space.
          <lfs_batch>-prior = lc_prior_5d.
        endif. " IF <lfs_batch>-corres = lc_corres
    endcase.
  endloop. " LOOP AT i_batch ASSIGNING <lfs_batch>

  sort i_batch by prior ascending.

endform. " F_SEQUENCE_BATCHES
*&---------------------------------------------------------------------*
*&      Form  F_DETERMINE_BATCHES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_determine_batches .

  data:
    lwa_komkh    type komkh,            " Batch Determination Communication Block Header
    lwa_komph    type komph,            " Batch Determination: Communication Record for Item
    lwa_bdcom    type bdcom,            " Batch Determination Communication Structure
    lwa_final    type ty_final,
    li_t459a     type table of t459a,   " External requirements types
    lwa_t459a    type t459a,            " External requirements types
    lwa_vbep     type ty_vbep,
    lwa_bdbatch  type bdbatch,          " Results Table for Batch Determination
    li_kna1      type table of ty_kna1,
    li_vbap      type table of ty_vbap,
    li_bdbatch   type table of bdbatch, " Results Table for Batch Determination
    li_bdbatch_f type table of bdbatch. " Results Table for Batch Determination

  field-symbols:
    <lfs_kna1>  type ty_kna1,
    <lfs_vbap>  type ty_vbap,
    <lfs_vbep>  type ty_vbep,
    <lfs_batch> type ty_batch_final.

  constants:
     lc_etenr type etenr value '0001'. " Delivery Schedule Line Number

  if i_batch_a is not initial.
    select vbeln posnr matnr mtvfp
           mvgr2 bedae from vbap " Sales Document: Item Data
                       into table i_vbap
                       for all entries in i_batch_a
                       where vbeln = i_batch_a-vbeln and
                             posnr = i_batch_a-posnr.
    sort i_vbap by vbeln posnr.

    if li_vbap is not initial.
*--->Begin of Changes for HANAtization on OTC_EDD_0398 by U033959 on 11-Sep-2019 in E1SK901543
      IF i_vbap IS NOT INITIAL.
*<---End of Changes for HANAtization on OTC_EDD_0398 by U033959 on 11-Sep-2019 in E1SK901543
      select * from t459a " External requirements types
               into table i_t459a
               for all entries in i_vbap
               where bedae eq i_vbap-bedae.
*--->Begin of Changes for HANAtization on OTC_EDD_0398 by U033959 on 11-Sep-2019 in E1SK901543
      ENDIF.
*<---End of Changes for HANAtization on OTC_EDD_0398 by U033959 on 11-Sep-2019 in E1SK901543
    endif. " IF li_vbap IS NOT INITIAL

    select kunnr land1
           ort01 pstlz from kna1 " General Data in Customer Master
                       into table i_kna1
                       for all entries in i_batch_a
                       where kunnr = i_batch_a-kunnr.
    sort i_kna1 by kunnr.

  endif. " IF i_batch_a IS NOT INITIAL

  perform f_determine_corres_batch.

  perform f_group_single_matnr_batch.

  loop at i_batch_a assigning <lfs_batch>.
*                    where bmeng ne 0.
    lwa_komkh-mandt = sy-mandt.
    lwa_komkh-kndnr = <lfs_batch>-kunnr.
    lwa_komkh-knrze = <lfs_batch>-kunnr.
    lwa_komkh-kunnr = <lfs_batch>-kunnr.
    lwa_komkh-vkorg = <lfs_batch>-vkorg.
    lwa_komkh-vtweg = <lfs_batch>-vtweg.
    lwa_komkh-spart = <lfs_batch>-kunnr.
    lwa_komkh-auart = <lfs_batch>-auart.
    lwa_komkh-auart_sd = <lfs_batch>-auart_sd.

    lwa_komph-matnr = <lfs_batch>-matnr.
    lwa_komph-werks = <lfs_batch>-werks.

    read table i_vbap assigning <lfs_vbap>
                       with key vbeln = <lfs_batch>-vbeln
                                posnr = <lfs_batch>-posnr
                       binary search.
    if sy-subrc eq 0.
      lwa_komph-mvgr2 = <lfs_vbap>-mvgr2.
      lwa_bdcom-mtvfp = <lfs_vbap>-mtvfp.

      read table i_t459a into lwa_t459a with key bedae = <lfs_vbap>-bedae.
      if sy-subrc eq 0.
        lwa_bdcom-bedar = lwa_t459a-bedar.
      endif. " IF sy-subrc EQ 0
    endif. " IF sy-subrc EQ 0

    lwa_bdcom-kappl = 'V'.
    lwa_bdcom-kalsm = 'SD0001'.
    lwa_bdcom-umrez = '1'.
    lwa_bdcom-umren = '1'.
    lwa_bdcom-kzvbp = 'X'.
    lwa_bdcom-prreg = 'A'.
    lwa_bdcom-chasp = '001'.
    lwa_bdcom-delkz = 'VC'.

    lwa_bdcom-menge = <lfs_batch>-omeng.
    lwa_bdcom-meins = <lfs_batch>-uom.
    lwa_bdcom-erfmg = <lfs_batch>-omeng.
    lwa_bdcom-erfme = <lfs_batch>-uom.
    lwa_bdcom-mbdat = <lfs_batch>-mbdat.
    lwa_bdcom-kund1 = <lfs_batch>-kunnr.
    lwa_bdcom-name1 = <lfs_batch>-name1.
    lwa_bdcom-delnr = <lfs_batch>-vbeln.
    lwa_bdcom-delps = <lfs_batch>-posnr.

    read table  i_vbep assigning <lfs_vbep>
                       with key vbeln = <lfs_batch>-vbeln
                                posnr = <lfs_batch>-posnr
                       binary search.
    if sy-subrc eq 0.
      lwa_bdcom-mbuhr = <lfs_vbep>-mbuhr.
    endif. " IF sy-subrc EQ 0

    lwa_bdcom-nodia = 'X'.

    read table i_kna1 assigning <lfs_kna1>
                       with key kunnr = <lfs_batch>-kunnr
                       binary search.
    if sy-subrc eq 0.
      lwa_bdcom-ort01 = <lfs_kna1>-ort01.
      lwa_bdcom-land1 = <lfs_kna1>-land1.
      lwa_bdcom-pstlz = <lfs_kna1>-pstlz.
    endif. " IF sy-subrc EQ 0

    clear li_bdbatch.
    refresh: li_bdbatch.
    call function 'VB_BATCH_DETERMINATION'
      exporting
        i_komkh   = lwa_komkh
        i_komph   = lwa_komph
        x_bdcom   = lwa_bdcom
      tables
        e_bdbatch = li_bdbatch
      exceptions
        no_plant  = 7
        others    = 99.
    if sy-subrc <> 0 or
       li_bdbatch is initial.
      message e000 with 'No batch determined'(021) into lwa_final-message.
      move 'E'      to lwa_final-status.
      move <lfs_batch>-vbeln to lwa_final-vbeln.
      move <lfs_batch>-posnr to lwa_final-posnr.
      append lwa_final to i_log_f.
    else. " ELSE -> IF sy-subrc <> 0 OR
      read table li_bdbatch into lwa_bdbatch index 1.
      read table i_vbep into lwa_vbep with key vbeln = <lfs_batch>-vbeln
                                               posnr = <lfs_batch>-posnr.
      if sy-subrc eq 0.
        if lwa_vbep-wmeng gt lwa_bdbatch-vrfmg.
          "Log
          move <lfs_batch>-vbeln to lwa_final-vbeln.
          move <lfs_batch>-posnr to lwa_final-posnr.
          lwa_final-status = 'E'.
          lwa_final-message = 'Ordered Quantity exceeds available quantity'.
          append lwa_final to i_log_f.

          refresh: li_bdbatch.
        else. " ELSE -> IF lwa_vbep-wmeng GT lwa_bdbatch-vrfmg
          append lines of li_bdbatch to i_bdbatch_f.
          assign <lfs_batch> to <fs_batch>.
          if li_bdbatch is not initial.
            perform f_assign_batches.
          endif. " IF li_bdbatch IS NOT INITIAL
        endif. " IF lwa_vbep-wmeng GT lwa_bdbatch-vrfmg
      endif. " IF sy-subrc EQ 0
    endif. " IF sy-subrc <> 0 OR

    clear : lwa_komkh,
            lwa_komph,
            lwa_bdcom.

    refresh: li_bdbatch,
             i_bdbatch_f.
  endloop. " LOOP AT i_batch_a ASSIGNING <lfs_batch>
endform. " F_DETERMINE_BATCHES
*&---------------------------------------------------------------------*
*&      Form  F_ASSIGN_BATCHES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_assign_batches .

  data:
    li_return            type table of bapiret2,    " Return Parameter
    lwa_return           type bapiret2,             " Return Parameter
    li_return_c          type bapiret2,             " Return Parameter
    li_schedule_lines    type table of bapischdl,   " Communication Fields for Maintaining SD Doc. Schedule Lines
    li_schedule_linesx   type table of bapischdlx,  " Checkbox List for Maintaining Sales Document Schedule Line
    li_order_item_in     type table of bapisditm,   " Communication Fields: Sales and Distribution Document Item
    li_order_item_inx    type table of  bapisditmx, " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_in    type bapisditm,            " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_inx   type bapisditmx,           " Communication Fields: Sales and Distribution Document Item
    lwa_order_header_in  type bapisdh1,             " Communication Fields: SD Order Header
    lwa_order_header_inx type bapisdh1x,            " Checkbox List: SD Order Header
    lwa_bdbatch_f        type bdbatch,              " Results Table for Batch Determination
    lwa_schedule_lines   type bapischdl,            " Communication Fields for Maintaining SD Doc. Schedule Lines
    lwa_schedule_linesx  type bapischdlx,           " Checkbox List for Maintaining Sales Document Schedule Line
    lv_logtext           type string,
    lv_joblog            type string,
    lwa_log              type ty_final.

  field-symbols:
    <lfs_batch>          type ty_batch_final,
    <lfs_return>         type bapiret2. " Return Parameter

  constants:
    lc_error             type char1 value 'E'. " Error of type CHAR1

  lwa_order_header_inx-updateflag = 'U'.
  lwa_order_item_in-itm_number = <fs_batch>-posnr.
  read table i_bdbatch_f into lwa_bdbatch_f index 1.
  if sy-subrc eq 0.
    lwa_order_item_in-material = lwa_bdbatch_f-matnr.
    lwa_order_item_in-batch = lwa_bdbatch_f-charg.
    lwa_schedule_lines-req_qty = lwa_bdbatch_f-menge.
  endif. " IF sy-subrc EQ 0
  append lwa_order_item_in to li_order_item_in.

  lwa_order_item_inx-itm_number = <fs_batch>-posnr.
  lwa_order_item_inx-updateflag = 'U'.
  lwa_order_item_inx-batch = 'X'.
  append lwa_order_item_inx to li_order_item_inx.

  check <fs_batch> is assigned.

  call function 'BAPI_SALESORDER_CHANGE'
    exporting
      salesdocument    = <fs_batch>-vbeln
      order_header_inx = lwa_order_header_inx
    tables
      return           = li_return
      order_item_in    = li_order_item_in
      order_item_inx   = li_order_item_inx.

  read table li_return assigning <lfs_return>
                       with key type = lc_error. " Return assigning of type
  if sy-subrc ne 0.

    <fs_batch>-charg = lwa_bdbatch_f-charg.
    lwa_log-vbeln   = <fs_batch>-vbeln.
    lwa_log-posnr   = <fs_batch>-posnr.
    lwa_log-status  = 'S'.
    lwa_log-message = 'Sales Order successfully saved'.
    append lwa_log to i_log_f.

    clear: li_return_c.
    call function 'BAPI_TRANSACTION_COMMIT'
      exporting
        wait   = 'X'
      importing
        return = li_return_c.

    append li_return_c to i_log.

    clear: lwa_order_header_inx.
    refresh: li_return,
             li_order_item_in,
             li_order_item_inx,
             li_schedule_lines,
             li_schedule_linesx.
  else. " ELSE -> IF sy-subrc NE 0
    if sy-batch is initial.
      <fs_batch>-charg = lwa_bdbatch_f-charg.
      lwa_log-vbeln   = <fs_batch>-vbeln.
      lwa_log-posnr   = <fs_batch>-posnr.
      lwa_log-status  = 'E'.
      lwa_log-message = <lfs_return>-message.
      append lwa_log to i_log_f.
    else. " ELSE -> IF sy-batch IS INITIAL
      concatenate <fs_batch>-vbeln '/' <fs_batch>-posnr 'E' '/' <lfs_return>-message
            into lv_joblog.
      write lv_joblog.
    endif. " IF sy-batch IS INITIAL

    call function 'BAPI_TRANSACTION_ROLLBACK'
      importing
        return = lwa_return.

    if lwa_return is not initial.
      if sy-batch is initial.
        <fs_batch>-charg = lwa_bdbatch_f-charg.

        lwa_log-vbeln   = <fs_batch>-vbeln.
        lwa_log-posnr   = <fs_batch>-posnr.
        lwa_log-status  = 'E'.
        lwa_log-message = 'Changes are NOT saved'.
        append lwa_log to i_log_f.

      else. " ELSE -> IF sy-batch IS INITIAL
        lwa_log-message = 'Changes are NOT saved'.
        concatenate <fs_batch>-vbeln '/' <fs_batch>-posnr 'E' '/' lwa_log-message
              into lv_joblog.
        write lv_joblog.
      endif. " IF sy-batch IS INITIAL
    endif. " IF lwa_return IS NOT INITIAL
  endif. " IF sy-subrc NE 0
*  endif.
endform. " F_ASSIGN_BATCHES
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_display_log .

  data:
    lref_chlog        type ref to cl_salv_table, " Basis Class for Simple Tables
    lv_start_column   type  i,                   " Start_column of type Integers
    lv_start_line     type  i,                   " Start_line of type Integers
    lv_end_column     type  i,                   " End_column of type Integers
    lv_end_line       type  i,                   " End_line of type Integers
    lv_msg            type  string,
    lv_popup          type  string value 'X',
    lv_ex_msg         type ref to cx_salv_msg.   "Message

  data:
    lr_functions      type ref to cl_salv_functions_list, " Generic and User-Defined Functions in List-Type Tables
    lr_columns        type ref to cl_salv_columns_table,  " Columns in Simple, Two-Dimensional Tables
    lr_column         type ref to cl_salv_column_table.   " Column Description of Simple, Two-Dimensional Tables

  data:
    li_salv_not_found type ref to   cx_salv_not_found. " ALV: General Error Class (Checked During Syntax Check)

  constants:
    lc_error    type symsgty value 'E',                   " Message Type
    lc_status   type sypfkey value 'ZOTC_EDD0398_TABSTD'. " Current GUI Status


  if i_log_f is not initial.
    try.
        cl_salv_table=>factory(
          importing
            r_salv_table = lref_chlog
          changing
            t_table      = i_log_f[] ).

      catch cx_salv_msg into lv_ex_msg.
        message lv_ex_msg type 'E'.

    endtry.

    lref_chlog->set_screen_status( pfstatus      = lc_status
                                   report        = sy-repid
                                   set_functions = lref_chlog->c_functions_all ).
    lr_functions = lref_chlog->get_functions( ).
    lr_functions->set_all( abap_true ).

    try.
        lr_columns = lref_chlog->get_columns( ).
      catch cx_salv_not_found.
    endtry.

    try.
        lr_column ?= lr_columns->get_column( 'VBELN' ).
      catch cx_salv_not_found.
        lr_column->set_visible( abap_false ).
    endtry.

    lv_start_column = 20.
    lv_start_line   = 50.
    lv_end_column   = 170.
    lv_end_line     = 100.

    if lref_chlog is bound.
      if lv_popup = 'X'.
        lref_chlog->set_screen_popup(
          start_column = lv_start_column
          end_column   = lv_end_column
          start_line   = lv_start_line
          end_line     = lv_end_line ).
      endif. " IF lv_popup = 'X'

      lref_chlog->display( ).

    endif. " IF lref_chlog IS BOUND
  endif. " IF i_log_f IS NOT INITIAL
endform. " F_DISPLAY_LOG
*&---------------------------------------------------------------------*
*&      Form  F_INSERT_STYLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_insert_style .

  data:
     lx_stylerow type lvc_s_styl,          " ALV Control: Field Name + Styles
     lwa_color_cell_batch type lvc_s_scol. " ALV control: Structure for cell coloring

  field-symbols:
   <lfs_batch>      type ty_batch_final,
   <lfs_color_cell> type lvc_s_scol. " ALV control: Structure for cell coloring

  loop at i_batch assigning <lfs_batch>.
    lx_stylerow-fieldname = 'VBELN'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    insert lx_stylerow into table <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'POSNR'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    insert lx_stylerow into table <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'MATNR'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    insert lx_stylerow into table <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'KWMENG'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    insert lx_stylerow into table <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'OMENG'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    insert lx_stylerow into table <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'BMENG'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    insert lx_stylerow into table <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'KUNNR'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    insert lx_stylerow into table <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'NAME1'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    insert lx_stylerow into table <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'VKORG'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    insert lx_stylerow into table <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'VTWEG'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    insert lx_stylerow into table <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'WERKS'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    insert lx_stylerow into table <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'EDATU'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    insert lx_stylerow into table <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'CHARG'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    insert lx_stylerow into table <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'LIFSK'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    insert lx_stylerow into table <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'VTEXT'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    insert lx_stylerow into table <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'ANTIGENS'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    insert lx_stylerow into table <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'CORRES'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    insert lx_stylerow into table <lfs_batch>-field_style.
  endloop. " LOOP AT i_batch ASSIGNING <lfs_batch>

endform. " F_INSERT_STYLE
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_PLANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_validate_plant .
  data: lv_plant type werks_d. " Plant

  constants: lc_ast type char1 value '*'. " Constant for '*'

  if not s_werks cp lc_ast and
         s_werks is not initial.
    select werks " Plant
      from t001w " Plants/Branches
     up to 1 rows
      into lv_plant
     where werks in s_werks.
    endselect.
    if sy-subrc eq 0.
      clear lv_plant.
    else. " ELSE -> IF sy-subrc EQ 0
      message e128 with lv_plant. " Invalid Plant
    endif. " IF sy-subrc EQ 0
  endif. " IF NOT s_werks CP lc_ast AND
endform. " F_VALIDATE_PLANT
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_MATNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_validate_matnr .
  data lv_matnr type matnr. " Material No.
  constants: lc_ast type char1 value '*'. " Constant for '*'

  if not s_matnr cp lc_ast.
    select matnr " Material Number
      from mara  " General Material Data
     up to 1 rows
      into lv_matnr
     where matnr in s_matnr.
    endselect.
    if sy-subrc eq 0.
      clear lv_matnr.
    else. " ELSE -> IF sy-subrc EQ 0
      message e128 with lv_matnr. " Invalid Material Number
    endif. " IF sy-subrc EQ 0
  endif. " IF NOT s_matnr CP lc_ast
endform. " F_VALIDATE_MATNR
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DOCNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_validate_docno .

  data:  lv_docno type vbeln. " Document Number

  if s_docno[] is not initial.
    select vbeln " Sales Document
      from vbak  " Sales Document: Header Data
     up to 1 rows
      into lv_docno
     where vbeln in s_docno[].
    endselect.
    if sy-subrc eq 0.
      clear lv_docno.
    else. " ELSE -> IF sy-subrc EQ 0
      message e980. " Invalid Sales Order Number
    endif. " IF sy-subrc EQ 0
  endif. " IF s_docno[] IS NOT INITIAL
endform. " F_VALIDATE_DOCNO
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_validate_batch .

  data lv_batch type charg_d. " Batch Number
  constants: lc_ast type char1 value '*'. " Constant for '*'

  if not s_charg cp lc_ast.
    select charg " Batch Number
      from mch1  " Batches (if Batch Management Cross-Plant)
     up to 1 rows
      into lv_batch
     where charg in s_charg.
    endselect.

    if sy-subrc = 0.
      clear lv_batch.
    else. " ELSE -> IF sy-subrc = 0
      message e273. "  Batch is Invalid
    endif. " IF sy-subrc = 0
  endif. " IF NOT s_charg CP lc_ast
endform. " F_VALIDATE_BATCH
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_VKORG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_validate_vkorg .
  data: lv_vkorg type vkorg. "local variable for Sales Organization

  select vkorg     "Customer Sales Organization
         from tvko " Organizational Unit: Sales Organizations
         up to 1 rows
         into   lv_vkorg
         where  vkorg in s_vkorg.
  endselect.
  if sy-subrc is not initial and lv_vkorg is initial.
    message e984.
  endif. " IF sy-subrc IS NOT INITIAL AND lv_vkorg IS INITIAL

**//-->>Begin of changes - Defect # 5957
  if s_vkorg is not initial.
    select vkorg                 "Customer Sales Organization
           from tvkwz
           up to 1 rows
           into   lv_vkorg
           where  vkorg in s_vkorg and
                  werks in s_werks.
    endselect.
    if sy-subrc is not initial and lv_vkorg is initial.
      message e984.
    endif.
  endif.
**//-->>End of changes - Defect # 5957
endform. " F_VALIDATE_VKORG
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_KUNNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_validate_kunnr .
  data: lv_kunnr type kunnr. "local variable for Customer Number

  if s_soldto is not initial.
    select kunnr " Customer Number
      up to 1 rows
      into lv_kunnr
      from kna1  " General Data in Customer Master
      where kunnr in s_soldto.
    endselect.
    if sy-subrc is not initial and lv_kunnr is initial.
      message e945.
    endif. " IF sy-subrc IS NOT INITIAL AND lv_kunnr IS INITIAL
  endif. " IF s_soldto IS NOT INITIAL
endform. " F_VALIDATE_KUNNR
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DOC_TYP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_validate_doc_typ .

* Local data declaration
  data: lv_auart type auart. "Sales Document Type.

  if s_ordty[] is not initial.
* Select and validate the value for field plant against selection
*screen
    select auart up to 1 rows "Sales Document Type
           from tvak          " Sales Document Types
           into lv_auart
           where auart in s_ordty[].
    endselect.

* Check sy-subrc after select
    if sy-subrc ne 0.
* If sy-subrc is not equal to zero display error mesage
      message e000 with 'Invalid document type'(002).
    endif. " IF sy-subrc NE 0
  endif. " IF s_ordty[] IS NOT INITIAL
endform. " F_VALIDATE_DOC_TYP
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_VTWEG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_validate_vtweg .

  data: lv_vtweg type vtweg. " Distribution Channel

  constants: lc_ast type char1 value '*'. " Constant for '*'

  if not s_vtweg cp lc_ast and
         s_vtweg is not initial.

    select vtweg up to 1 rows
        into lv_vtweg
        from tvtw " Organizational Unit: Distribution Channels
        where vtweg in s_vtweg.

    endselect.

    if sy-subrc <> 0.
      message e000 with 'Enter valid Distribution Channel'(e01).
    endif. " IF sy-subrc <> 0
  endif. " IF NOT s_vtweg CP lc_ast AND
endform. " F_VALIDATE_VTWEG
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SELECTION_TAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_build_selection_tab .

  data:
    lv_lines    type i,     " Lines of type Integers
    lwa_lseltab type rkask. " Table of selection criteria

  if s_soldto is not initial.
    lwa_lseltab-ktext = 'KUNNR'.
    describe table s_soldto lines lv_lines.
    if lv_lines gt 1.
      loop at s_soldto.
        lwa_lseltab-vonsl = s_soldto-low.
        append lwa_lseltab to i_lseltab.
      endloop. " LOOP AT s_soldto
    elseif lv_lines eq 1.
      lwa_lseltab-vonsl = s_soldto-low.
      lwa_lseltab-bissl = s_soldto-high.
      append lwa_lseltab to i_lseltab.
    endif. " IF lv_lines GT 1
  endif. " IF s_soldto IS NOT INITIAL

  if s_docno is not initial.
    lwa_lseltab-ktext = 'VBELN'.
    describe table s_docno lines lv_lines.
    if lv_lines gt 1.
      loop at s_docno.
        lwa_lseltab-vonsl = s_docno-low.
        append lwa_lseltab to i_lseltab.
      endloop. " LOOP AT s_docno
    elseif lv_lines eq 1.
      lwa_lseltab-vonsl = s_docno-low.
      lwa_lseltab-bissl = s_docno-high.
      append lwa_lseltab to i_lseltab.
    endif. " IF lv_lines GT 1
  endif. " IF s_docno IS NOT INITIAL

  if s_ordty is not initial.
    lwa_lseltab-ktext = 'AUART'.
    describe table s_ordty lines lv_lines.
    if lv_lines gt 1.
      loop at s_ordty.
        lwa_lseltab-vonsl = s_ordty-low.
        append lwa_lseltab to i_lseltab.
      endloop. " LOOP AT s_ordty
    elseif lv_lines eq 1.
      lwa_lseltab-vonsl = s_ordty-low.
      lwa_lseltab-bissl = s_ordty-high.
      append lwa_lseltab to i_lseltab.
    endif. " IF lv_lines GT 1
  endif. " IF s_ordty IS NOT INITIAL

**//-->> Begin of changes - Defect# 5957
  if s_vkorg is not initial.
    lwa_lseltab-ktext = 'VKORG'.
    describe table s_vkorg lines lv_lines.
    if lv_lines gt 1.
      loop at s_vkorg.
        lwa_lseltab-vonsl = s_vkorg-low.
        append lwa_lseltab to i_lseltab.
      endloop. " LOOP AT s_ordty
    elseif lv_lines eq 1.
      lwa_lseltab-vonsl = s_vkorg-low.
      lwa_lseltab-bissl = s_vkorg-high.
      append lwa_lseltab to i_lseltab.
    endif. " IF lv_lines GT 1
  endif.

  if s_vtweg is not initial.
    lwa_lseltab-ktext = 'VTWEG'.
    describe table s_vtweg lines lv_lines.
    if lv_lines gt 1.
      loop at s_vtweg.
        lwa_lseltab-vonsl = s_vtweg-low.
        append lwa_lseltab to i_lseltab.
      endloop. " LOOP AT s_ordty
    elseif lv_lines eq 1.
      lwa_lseltab-vonsl = s_vtweg-low.
      lwa_lseltab-bissl = s_vtweg-high.
      append lwa_lseltab to i_lseltab.
    endif. " IF lv_lines GT 1
  endif.

**//-->> End of changes - Defect# 5957
endform. " F_BUILD_SELECTION_TAB
*&---------------------------------------------------------------------*
*&      Form  F_DETERMINE_CORRES_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_determine_corres_batch .

  types: begin of lty_corr_batch.
  types: vbeln      type vbeln,       " Sales and Distribution Document Number
         posnn      type posnr,       " Item number of the SD document
         vfdat      type vfdat,       " Shelf Life Expiration or Best-Before Date
         ihd_batch  type atwtb,       "for IHD_DISP_BAtch
         corr_batch type atwtb,       " Characteristic value description
         corresponding  type boole_d. " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
          include structure cdstock. " Results Table for Batch Determination / Stock Determination
  types: end of lty_corr_batch.

  data:
    lv_vbeln_comp       type vbeln,                             " Sales and Distribution Document Number
    lv_vbeln_chng       type vbeln,                             " Sales and Distribution Document Number
    lv_posnr_comp       type posnr,                             " Item number of the SD document
    lv_posnr_chng       type posnr,                             " Item number of the SD document
    lv_tab              type sy-tabix,                          " Index of Internal Tables
    lv_no_cond_check    type boole_d,                           " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
    lv_matnr_cbat       type matnr,                             " Material Number
    lv_index            type sy-index,                          " Loop Index
    lv_ord_qty          type c,                                 " Ord_qty of type Character

    lwa_komkh           type komkh,                             " Batch Determination Communication Block Header
    lwa_komph           type komph,                             " Batch Determination: Communication Record for Item
    lwa_bdcom           type bdcom,                             " Batch Determination Communication Structure
    lwa_enh_status      type zdev_enh_status,                   " Enhancement Status
    lwa_enh_status_a    type zdev_enh_status,                   " Enhancement Status
    lwa_final           type ty_final,
    lwa_bdbatch         type bdbatch,                           " Results Table for Batch Determination
    lwa_stock           type cdstock,                           " Results Table for Batch Determination / Stock Determination
    lwa_t459a           type t459a,                             " External requirements types
    lwa_vbep            type ty_vbep,
    lwa_batch_det       type clbatch,                           " Classification interface for batches
    lwa_stock_tmp       type zptm_corres_batch,                 "cdstock,                           " Results Table for Batch Determination / Stock Determination
    lwa_corr_batch      type zptm_corres_batch,                 "lty_corr_batch,
    lwa_corr_batch_comp type zptm_corres_batch,                 "lty_corr_batch,
    lwa_corr_batch_chng type zptm_corres_batch,                 "lty_corr_batch,

  li_t459a            type table of t459a,                      " External requirements types
  li_kna1             type table of ty_kna1,
  li_vbap             type table of ty_vbap,
  li_bdbatch          type table of bdbatch,                    " Results Table for Batch Determination
  li_bdbatch_f        type table of bdbatch,                    " Results Table for Batch Determination
  li_corr_batch_comp  type standard table of zptm_corres_batch, "lty_corr_batch,
  li_corr_batch_chng  type standard table of zptm_corres_batch. "lty_corr_batch.

  constants:
     lc_etenr      type etenr         value '0001',               " Delivery Schedule Line Number
     lc_matnr_comp type z_criteria    value 'MATNR_TO_COMP',      " Enh. Criteria
     lc_corr       type z_criteria    value 'CORRES_BATCH_MATNR', " Enh. Criteria
     lc_corres     type string        value 'CORRESPONDING',
     lc_lobm_vfdat type atnam         value 'LOBM_VFDAT',         " Characteristic Name
     lc_pap_bat    type char12        value 'CORR_PAP_BAT',       " Pap_bat of type CHAR12
     lc_disp_bat   type atnam         value 'ZM_DISP_BATCH'.      " Characteristic Name

  field-symbols:
    <lfs_kna1>            type ty_kna1,
    <lfs_vbap>            type ty_vbap,
    <lfs_vbep>            type ty_vbep,
    <lfs_bdbatch_c>       type bdbatch,           " Results Table for Batch Determination
    <lfs_batch>           type ty_batch_final,
    <lfs_batch_a>         type ty_batch_final,
    <lfs_batch_b>         type ty_batch_final,
    <lfs_batch_c>         type ty_batch_final,
    <lfs_corr_batch_comp> type zptm_corres_batch, " Corresponding Batch Information
    <lfs_corr_batch_chng> type zptm_corres_batch. " Corresponding Batch Information

  refresh:
    i_batch_b,
    i_batch_c.

  read table i_edd_emi into lwa_enh_status
                         with key criteria  = lc_corr
                                  sel_high  = 'X'
                                  active   = abap_true.
  if sy-subrc eq 0.
    read table i_edd_emi into lwa_enh_status_a
                           with key criteria  = lc_corr
                                    sel_high  = space
                                    active   = abap_true.
    if sy-subrc eq 0.
      loop at i_batch_a assigning <lfs_batch>
                        where matnr eq lwa_enh_status-sel_low.
        lv_tab = sy-tabix.
        if <lfs_batch>-corres = lc_corres.
          read table i_batch_a assigning <lfs_batch_a> with key vbeln = <lfs_batch>-vbeln
                                                                matnr = lwa_enh_status_a-sel_low.
          if sy-subrc eq 0.
            append <lfs_batch>   to i_batch_c.
            append <lfs_batch_a> to i_batch_c.
          endif. " IF sy-subrc EQ 0
        endif.
      endloop. " LOOP AT i_batch_a ASSIGNING <lfs_batch>
    endif. " IF sy-subrc EQ 0
  endif. " IF sy-subrc EQ 0

  loop at i_batch_a assigning <lfs_batch_a>.
    lv_tab = sy-tabix.
    read table i_batch_c assigning <lfs_batch> with key vbeln = <lfs_batch_a>-vbeln
                                                        posnr = <lfs_batch_a>-posnr.
    if sy-subrc eq 0.
      delete i_batch_a index lv_tab.
    endif. " IF sy-subrc EQ 0
  endloop. " LOOP AT i_batch_a ASSIGNING <lfs_batch_a>

  sort i_batch_c by vbeln posnr.
  perform f_sequence_batches_c.

  loop at i_batch_c assigning <lfs_batch>.
    read table i_batch_b assigning <lfs_batch_b> with key vbeln = <lfs_batch>-vbeln.
    if sy-subrc ne 0.
      append <lfs_batch> to i_batch_b.
    endif. " IF sy-subrc NE 0
  endloop. " LOOP AT i_batch_c ASSIGNING <lfs_batch>

  loop at i_batch_b assigning <lfs_batch_b>.
    loop at i_batch_c assigning <lfs_batch> where vbeln = <lfs_batch_b>-vbeln.
      gv_vbeln =  <lfs_batch_b>-vbeln.
      read table i_edd_emi into lwa_enh_status
                            with key criteria = lc_corr
                                     sel_low  = <lfs_batch>-matnr
                                     active   = abap_true binary search.
      if sy-subrc = 0 .

* Also for Material 05310, we dont need to check entries in KONDH, AUSP
        if lv_matnr_cbat is initial. "below read only occurs once
          read table i_edd_emi into lwa_enh_status
                                 with key criteria = lc_matnr_comp
                                          active   = abap_true binary search.
          if sy-subrc = 0.
            lv_matnr_cbat = lwa_enh_status-sel_low.
          endif. " IF sy-subrc = 0
        endif. " IF lv_matnr_cbat IS INITIAL

        clear: lv_no_cond_check.
        if lv_matnr_cbat = <lfs_batch>-matnr .
          lv_no_cond_check = abap_true.
        endif. " IF lv_matnr_cbat = <lfs_batch>-matnr

        lwa_komkh-mandt = sy-mandt.
        lwa_komkh-kndnr = <lfs_batch>-kunnr.
        lwa_komkh-knrze = <lfs_batch>-kunnr.
        lwa_komkh-kunnr = <lfs_batch>-kunnr.
        lwa_komkh-vkorg = <lfs_batch>-vkorg.
        lwa_komkh-vtweg = <lfs_batch>-vtweg.
        lwa_komkh-spart = <lfs_batch>-kunnr.
        lwa_komkh-auart = <lfs_batch>-auart.
        lwa_komkh-auart_sd = <lfs_batch>-auart_sd.

        lwa_komph-matnr = <lfs_batch>-matnr.
        lwa_komph-werks = <lfs_batch>-werks.

        read table i_vbap assigning <lfs_vbap>
                           with key vbeln = <lfs_batch>-vbeln
                                    posnr = <lfs_batch>-posnr
                           binary search.
        if sy-subrc eq 0.
          lwa_komph-mvgr2 = <lfs_vbap>-mvgr2.
          lwa_bdcom-mtvfp = <lfs_vbap>-mtvfp.

          read table i_t459a into lwa_t459a with key bedae = <lfs_vbap>-bedae.
          if sy-subrc eq 0.
            lwa_bdcom-bedar = lwa_t459a-bedar.
          endif. " IF sy-subrc EQ 0
        endif. " IF sy-subrc EQ 0

        lwa_bdcom-kappl = 'V'.
        lwa_bdcom-kalsm = 'SD0001'.
        lwa_bdcom-umrez = '1'.
        lwa_bdcom-umren = '1'.
        lwa_bdcom-kzvbp = 'X'.
        lwa_bdcom-prreg = 'A'.
        lwa_bdcom-chasp = '001'.
        lwa_bdcom-delkz = 'VC'.

        lwa_bdcom-menge = <lfs_batch>-omeng.
        lwa_bdcom-meins = <lfs_batch>-uom.
        lwa_bdcom-erfmg = <lfs_batch>-omeng.
        lwa_bdcom-erfme = <lfs_batch>-uom.
        lwa_bdcom-mbdat = <lfs_batch>-mbdat.
        lwa_bdcom-kund1 = <lfs_batch>-kunnr.
        lwa_bdcom-name1 = <lfs_batch>-name1.
        lwa_bdcom-delnr = <lfs_batch>-vbeln.
        lwa_bdcom-delps = <lfs_batch>-posnr.

        read table  i_vbep assigning <lfs_vbep>
                           with key vbeln = <lfs_batch>-vbeln
                                    posnr = <lfs_batch>-posnr
                           binary search.
        if sy-subrc eq 0.
          lwa_bdcom-mbuhr = <lfs_vbep>-mbuhr.
        endif. " IF sy-subrc EQ 0

        lwa_bdcom-nodia = 'X'.

        read table i_kna1 assigning <lfs_kna1>
                           with key kunnr = <lfs_batch>-kunnr
                           binary search.
        if sy-subrc eq 0.
          lwa_bdcom-ort01 = <lfs_kna1>-ort01.
          lwa_bdcom-land1 = <lfs_kna1>-land1.
          lwa_bdcom-pstlz = <lfs_kna1>-pstlz.
          lwa_bdcom-simulation_mode = 'X'.
        endif. " IF sy-subrc EQ 0

        clear li_bdbatch.
        call function 'VB_BATCH_DETERMINATION'
          exporting
            i_komkh   = lwa_komkh
            i_komph   = lwa_komph
            x_bdcom   = lwa_bdcom
          tables
            e_bdbatch = li_bdbatch
          exceptions
            no_plant  = 7
            others    = 99.
        if sy-subrc <> 0.
          message e000 with 'No batch determined'(021) into lwa_final-message.
          move 'E'      to lwa_final-status.
          move <lfs_batch>-vbeln to lwa_final-vbeln.
          move <lfs_batch>-posnr to lwa_final-posnr.
          append lwa_final to i_log_f.
        else. " ELSE -> IF sy-subrc <> 0
          append lines of li_bdbatch to i_bdbatch_c.

          refresh: i_batch_cr,
                   i_batch_crr,
                   i_stock.
          loop at li_bdbatch into lwa_bdbatch where matnr is not initial
                                                and charg is not initial .
            move-corresponding lwa_bdbatch to lwa_stock.
            append lwa_stock to i_stock.
            clear: lwa_stock.
            clear: i_batch_cr[].
            call function 'VB_BATCH_GET_DETAIL'
              exporting
                matnr              = lwa_bdbatch-matnr
                charg              = lwa_bdbatch-charg
                get_classification = abap_true
              tables
                char_of_batch      = i_batch_cr
              exceptions
                no_material        = 1
                no_batch           = 2
                no_plant           = 3
                material_not_found = 4
                plant_not_found    = 5
                no_authority       = 6
                batch_not_exist    = 7
                lock_on_batch      = 8
                others             = 9.
            if sy-subrc eq 0.
              refresh i_batch_crr.
              append lines of i_batch_cr to i_batch_crr.
              clear: i_batch_cr[].
            else. " ELSE -> IF sy-subrc EQ 0
              message e594(zptm_msg) raising no_batch_details. " No Batch details available
            endif. " IF sy-subrc EQ 0

* Parallel Cursor
            read table i_stock into lwa_stock_tmp
                                      with key matnr = <lfs_batch>-matnr
                                               werks = <lfs_batch>-werks.
            if sy-subrc = 0.
              clear: lv_tab.
              lv_tab = sy-tabix.
              loop at i_stock into lwa_stock from lv_tab.
                if lwa_stock_tmp-matnr ne lwa_stock-matnr
                        and lwa_stock_tmp-werks ne lwa_stock-werks.
                  exit.
                endif. " IF lwa_stock_tmp-matnr NE lwa_stock-matnr
                lwa_corr_batch-vbeln = <lfs_batch>-vbeln.
                lwa_corr_batch-posnn = <lfs_batch>-posnr.
                move-corresponding lwa_stock to  lwa_corr_batch.
                lwa_corr_batch-posnr = <lfs_batch>-posnr.

* Move the corresponding batch details into final internal table
                read table i_batch_crr into lwa_batch_det
                                            with key atnam = lc_pap_bat.
                if sy-subrc = 0.
                  lwa_corr_batch-corr_batch = lwa_batch_det-atwtb.

                  read table i_batch_crr into lwa_batch_det
                                            with key atnam = lc_disp_bat.
                  if sy-subrc = 0.
                    lwa_corr_batch-ihd_batch = lwa_batch_det-atwtb.
                  endif. " IF sy-subrc = 0
* Get the Batch Exp Date
                  read table i_batch_crr into lwa_batch_det
                                            with key atnam = lc_lobm_vfdat.
                  if sy-subrc = 0.
                    call function 'CONVERT_DATE_TO_INTERNAL'
                      exporting
                        date_external            = lwa_batch_det-atwtb
                      importing
                        date_internal            = lwa_corr_batch-vfdat
                      exceptions
                        date_external_is_invalid = 1
                        others                   = 2.
                    if sy-subrc <> 0.
                      clear: lwa_corr_batch-vfdat.
                    endif. " IF sy-subrc <> 0
                  endif. " IF sy-subrc = 0
*  Move the Contents of 04310 into one internal and 05310 into another
                  if lwa_corr_batch-matnr = lv_matnr_cbat.
                    append lwa_corr_batch to li_corr_batch_comp.
                  else. " ELSE -> IF lwa_corr_batch-matnr = lv_matnr_cbat
                    append lwa_corr_batch to li_corr_batch_chng.
                  endif. " IF lwa_corr_batch-matnr = lv_matnr_cbat
                  clear: lwa_batch_det,lwa_corr_batch.
                endif. " IF sy-subrc = 0
              endloop. " LOOP AT i_stock INTO lwa_stock FROM lv_tab
            endif. " IF sy-subrc = 0
            refresh: i_stock.
          endloop. " LOOP AT li_bdbatch INTO lwa_bdbatch WHERE matnr IS NOT INITIAL
        endif. " IF sy-subrc <> 0
      endif. " IF sy-subrc = 0
    endloop. " LOOP AT i_batch_c ASSIGNING <lfs_batch> WHERE vbeln = <lfs_batch_b>-vbeln

* At this stage we group required batches for both the Materials(04310 and 5310)
    sort li_corr_batch_comp by  vbeln posnn vfdat ascending.
    sort li_corr_batch_chng by  vbeln posnn vfdat ascending.

    clear: lv_vbeln_comp,lv_vbeln_chng, lv_posnr_comp, lv_posnr_chng.

    loop at li_corr_batch_chng assigning <lfs_corr_batch_chng>.
* Make sure we run only once for a item(we can have multiple lines based on batch)
* dont consider the VBELN as in VA01 BELN will be blank
      if  lv_posnr_chng = <lfs_corr_batch_chng>-posnn.
        exit.
      endif. " IF lv_posnr_chng = <lfs_corr_batch_chng>-posnn

      read table i_vbep into lwa_vbep with key vbeln = <lfs_corr_batch_chng>-vbeln
                                               posnr = <lfs_corr_batch_chng>-posnn.
      if sy-subrc eq 0.
        if lwa_vbep-wmeng gt <lfs_corr_batch_chng>-vrfmg.
          lv_ord_qty = abap_true.
          exit.
        endif. " IF lwa_vbep-wmeng GT <lfs_corr_batch_chng>-vrfmg
      endif. " IF sy-subrc EQ 0

* Parallel Cursor
      read table li_corr_batch_comp  into lwa_corr_batch_comp
                                        with key matnr          = lv_matnr_cbat
                                                 vfdat          = <lfs_corr_batch_chng>-vfdat
                                                 corr_batch     =  <lfs_corr_batch_chng>-corr_batch
                                                 ihd_batch+5(3) = <lfs_corr_batch_chng>-ihd_batch+5(3).
      if sy-subrc = 0 .
        clear: lv_tab.
        lv_tab = sy-tabix.

        clear lv_index.

        loop at li_corr_batch_comp  assigning <lfs_corr_batch_comp> from lv_tab.
*          lv_index = sy-tabix.
* Exit condition for Parallel cursor
          if <lfs_corr_batch_comp>-matnr ne lv_matnr_cbat and  <lfs_corr_batch_comp>-vfdat ne <lfs_corr_batch_chng>-vfdat
             and  <lfs_corr_batch_comp>-corr_batch ne  <lfs_corr_batch_chng>-corr_batch
             and  <lfs_corr_batch_comp>-ihd_batch+5(3) ne <lfs_corr_batch_chng>-ihd_batch+5(3)  .
            exit.
          endif. " IF <lfs_corr_batch_comp>-matnr NE lv_matnr_cbat AND <lfs_corr_batch_comp>-vfdat NE <lfs_corr_batch_chng>-vfdat
* Exit condition for below logic to run only once for a item(we can have multiple lines based on batch)
          if  lv_posnr_comp = <lfs_corr_batch_comp>-posnn.
            exit.
          endif. " IF lv_posnr_comp = <lfs_corr_batch_comp>-posnn

          read table i_vbep into lwa_vbep with key vbeln = <lfs_corr_batch_comp>-vbeln
                                                   posnr = <lfs_corr_batch_comp>-posnn.
          if sy-subrc eq 0.
            if lwa_vbep-wmeng gt <lfs_corr_batch_comp>-vrfmg.
              lv_ord_qty = abap_true.
              exit.
            endif. " IF lwa_vbep-wmeng GT <lfs_corr_batch_comp>-vrfmg
          endif. " IF sy-subrc EQ 0

          <lfs_corr_batch_chng>-corresponding = abap_true.
          <lfs_corr_batch_comp>-corresponding = abap_true.
          clear lv_ord_qty.
** also change the batch for 04310 material with 05310

          lv_vbeln_comp =  <lfs_corr_batch_comp>-vbeln.
          lv_posnr_comp =  <lfs_corr_batch_comp>-posnn.
        endloop. " LOOP AT li_corr_batch_comp ASSIGNING <lfs_corr_batch_comp> FROM lv_tab
        lv_vbeln_chng =  <lfs_corr_batch_chng>-vbeln.
        lv_posnr_chng =  <lfs_corr_batch_chng>-posnn.
      endif. " IF sy-subrc = 0

    endloop. " LOOP AT li_corr_batch_chng ASSIGNING <lfs_corr_batch_chng>

    if li_corr_batch_chng[] is not initial.
      delete adjacent duplicates from li_corr_batch_chng comparing vbeln posnr corresponding.
    endif. " IF li_corr_batch_chng[] IS NOT INITIAL

    if li_corr_batch_comp[] is not initial.
      delete adjacent duplicates from li_corr_batch_comp comparing vbeln posnr corresponding.
    endif. " IF li_corr_batch_comp[] IS NOT INITIAL

    loop at li_corr_batch_chng assigning <lfs_corr_batch_chng> where corresponding = abap_true.
* Change the 043010 material
      read table i_batch_c assigning <lfs_batch_c>
                          with key vbeln = <lfs_corr_batch_chng>-vbeln
                                   posnr = <lfs_corr_batch_chng>-posnr.
      if sy-subrc = 0.
        <lfs_batch_c>-charg = <lfs_corr_batch_chng>-charg.
        read table i_bdbatch_c assigning <lfs_bdbatch_c>
                            with key matnr = <lfs_corr_batch_chng>-matnr.
        if sy-subrc = 0.
          <lfs_bdbatch_c>-charg = <lfs_corr_batch_chng>-charg.
        endif. " IF sy-subrc = 0
      endif. " IF sy-subrc = 0
    endloop. " LOOP AT li_corr_batch_chng ASSIGNING <lfs_corr_batch_chng> WHERE corresponding = abap_true

    loop at li_corr_batch_comp assigning <lfs_corr_batch_comp> where corresponding = abap_true.
      read table i_batch_c assigning <lfs_batch_c>
                          with key vbeln = <lfs_corr_batch_comp>-vbeln
                                   posnr = <lfs_corr_batch_comp>-posnr.
      if sy-subrc = 0.
        <lfs_batch_c>-charg = <lfs_corr_batch_comp>-charg.
        read table i_bdbatch_c assigning <lfs_bdbatch_c>
                            with key matnr = <lfs_corr_batch_comp>-matnr.
        if sy-subrc = 0.
          <lfs_bdbatch_c>-charg = <lfs_corr_batch_comp>-charg.
        endif. " IF sy-subrc = 0
      endif. " IF sy-subrc = 0

    endloop. " LOOP AT li_corr_batch_comp ASSIGNING <lfs_corr_batch_comp> WHERE corresponding = abap_true

    if lv_ord_qty ne abap_true.
      loop at i_bdbatch_c assigning <lfs_bdbatch_c>.
        lv_tab = sy-tabix.
        read table i_batch_c assigning <lfs_batch_c>
                             with key matnr = <lfs_bdbatch_c>-matnr
                                      charg = <lfs_bdbatch_c>-charg.
        if sy-subrc ne 0.
          delete i_bdbatch_c index lv_tab.
        endif. " IF sy-subrc NE 0
      endloop. " LOOP AT i_bdbatch_c ASSIGNING <lfs_bdbatch_c>
      append lines of i_bdbatch_c to i_bdbatch_f.
      if i_bdbatch_f is not initial.
        perform f_assign_corr_batches.
      endif. " IF i_bdbatch_f IS NOT INITIAL
    else. " ELSE -> IF lv_ord_qty NE abap_true
      "Log
      move <lfs_batch>-vbeln to lwa_final-vbeln.
      move <lfs_batch>-posnr to lwa_final-posnr.
      lwa_final-status = 'E'.
      lwa_final-message = 'Ordered Quantity exceeds available quantity'.
      append lwa_final to i_log_f.
    endif. " IF lv_ord_qty NE abap_true
    clear: li_corr_batch_chng[], li_corr_batch_comp[],lwa_corr_batch_chng,
           lwa_corr_batch_comp.
    unassign: <lfs_batch_c>, <lfs_corr_batch_comp>, <lfs_corr_batch_chng>.

    clear : lwa_komkh,
            lwa_komph,
            lwa_bdcom.

    refresh: li_bdbatch,
             i_bdbatch_c,
             i_bdbatch_f.
  endloop. " LOOP AT i_batch_b ASSIGNING <lfs_batch_b>


endform. " F_DETERMINE_CORRES_BATCH
*&---------------------------------------------------------------------*
*&      Form  F_ASSIGN_CORR_BATCHES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_assign_corr_batches .
  data:
    li_return            type table of bapiret2,    " Return Parameter
    lwa_return           type bapiret2,             " Return Parameter
    li_return_c          type bapiret2,             " Return Parameter
    li_schedule_lines    type table of bapischdl,   " Communication Fields for Maintaining SD Doc. Schedule Lines
    li_schedule_linesx   type table of bapischdlx,  " Checkbox List for Maintaining Sales Document Schedule Line
    li_order_item_in     type table of bapisditm,   " Communication Fields: Sales and Distribution Document Item
    li_order_item_inx    type table of  bapisditmx, " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_in    type bapisditm,            " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_inx   type bapisditmx,           " Communication Fields: Sales and Distribution Document Item
    lwa_order_header_in  type bapisdh1,             " Communication Fields: SD Order Header
    lwa_order_header_inx type bapisdh1x,            " Checkbox List: SD Order Header
    lwa_bdbatch_f        type bdbatch,              " Results Table for Batch Determination
    lwa_schedule_lines   type bapischdl,            " Communication Fields for Maintaining SD Doc. Schedule Lines
    lwa_schedule_linesx  type bapischdlx,           " Checkbox List for Maintaining Sales Document Schedule Line
    lwa_log              type ty_final,
    lv_logtext           type string,
    lv_joblog            type string.

  field-symbols:
    <lfs_batch>          type ty_batch_final,
    <lfs_batch_c>        type ty_batch_final,
    <lfs_return>         type bapiret2, " Return Parameter
    <lfs_vbep_c>         type ty_vbep_c.

  constants:
    lc_error             type char1 value 'E'. " Error of type CHAR1

  loop at i_batch_c assigning <lfs_batch>
                    where vbeln = gv_vbeln.

    lwa_order_header_inx-updateflag = 'U'.
    lwa_order_item_in-itm_number = <lfs_batch>-posnr.
    read table i_bdbatch_f into lwa_bdbatch_f with key matnr = <lfs_batch>-matnr.
    if sy-subrc eq 0.
      lwa_order_item_in-material = lwa_bdbatch_f-matnr.
      lwa_order_item_in-batch = lwa_bdbatch_f-charg.
      <lfs_batch>-charg       = lwa_bdbatch_f-charg.
      read table i_vbep_c assigning <lfs_vbep_c>
                          with key vbeln = <lfs_batch>-vbeln
                                   posnr = <lfs_batch>-posnr.
      if sy-subrc eq 0.
        lwa_schedule_lines-req_qty = <lfs_vbep_c>-wmeng.
      endif. " IF sy-subrc EQ 0
    endif. " IF sy-subrc EQ 0
    append lwa_order_item_in to li_order_item_in.

    lwa_order_item_inx-itm_number = <lfs_batch>-posnr.
    lwa_order_item_inx-updateflag = 'U'.
    lwa_order_item_inx-batch = 'X'.
    append lwa_order_item_inx to li_order_item_inx.

    lwa_schedule_lines-itm_number = <lfs_batch>-posnr.
    lwa_schedule_lines-sched_line = '0001'.
    append lwa_schedule_lines to li_schedule_lines.

    lwa_schedule_linesx-itm_number = <lfs_batch>-posnr.
    lwa_schedule_linesx-req_qty    = 'X'.
    lwa_schedule_linesx-updateflag = 'U'.
    lwa_schedule_linesx-sched_line = '0001'.
    append lwa_schedule_linesx to li_schedule_linesx.
  endloop. " LOOP AT i_batch_c ASSIGNING <lfs_batch>

  check <lfs_batch> is assigned.

  call function 'BAPI_SALESORDER_CHANGE'
    exporting
      salesdocument     = <lfs_batch>-vbeln
      order_header_inx  = lwa_order_header_inx
*     behave_when_error = 'X'
    tables
      return            = li_return
      order_item_in     = li_order_item_in
      order_item_inx    = li_order_item_inx.

  read table li_return assigning <lfs_return>
                       with key type = lc_error. " Return assigning of type
  if sy-subrc <> 0.

    if sy-batch is initial.

      lwa_log-vbeln   = <lfs_batch>-vbeln.
      lwa_log-posnr   = <lfs_batch>-posnr.
      lwa_log-status  = 'S'.
      lwa_log-message = 'Sales Order successfully saved'.
      append lwa_log to i_log_f.

      loop at i_batch_c assigning <lfs_batch_c>
                            where vbeln = gv_vbeln.
        loop at i_batch assigning <lfs_batch>
                            where vbeln = gv_vbeln
                              and posnr = <lfs_batch_c>-posnr.
          <lfs_batch>-charg = <lfs_batch_c>-charg.
        endloop. " LOOP AT i_batch ASSIGNING <lfs_batch>
      endloop. " LOOP AT i_batch_c ASSIGNING <lfs_batch_c>
    else. " ELSE -> IF sy-batch IS INITIAL
      loop at li_return into lwa_return.
        message id lwa_return-id type lwa_return-type
                                 number lwa_return-number
                                 with lwa_return-message
            into lv_joblog.
        write lv_joblog.
      endloop. " LOOP AT li_return INTO lwa_return
    endif. " IF sy-batch IS INITIAL

    refresh: li_return.
    call function 'BAPI_TRANSACTION_COMMIT'
      exporting
        wait   = 'X'
      importing
        return = li_return_c.

    append li_return_c to i_log.

    clear: lwa_order_header_inx.
    refresh: li_return,
             li_order_item_in,
             li_order_item_inx,
             li_schedule_lines,
             li_schedule_linesx.
  else. " ELSE -> IF sy-subrc <> 0
    call function 'BAPI_TRANSACTION_ROLLBACK'
      importing
        return = lwa_return.

    if sy-batch is initial.
      append lwa_return to i_log.
    else. " ELSE -> IF sy-batch IS INITIAL
      message id lwa_return-id type lwa_return-type
                               number lwa_return-number
                               with lwa_return-message
          into lv_joblog.
      write lv_joblog.
    endif. " IF sy-batch IS INITIAL
  endif. " IF sy-subrc <> 0
endform. " F_ASSIGN_CORR_BATCHES
*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_DATA_CHANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
form f_handle_data_change  using er_data_changed type ref to cl_alv_changed_data_protocol. " Message Log for Data Entry

  data: ls_good     type lvc_s_modi, " ALV control: Modified cells for application
        lv_temp_str type string,
        lv_row      type i,                                 "#EC NEEDED
        lv_value    type c,                                 "#EC NEEDED
        lv_col      type i,                                 "#EC NEEDED
        ls_row_no   type lvc_s_roid, " Assignment of line number to line ID
        ls_roid     type lvc_s_row,  " ALV control: Line description
        ls_col_id   type lvc_s_col.  " ALV Control: Column ID

  field-symbols:
        <lfs_batch> type ty_batch_final.

  call method o_alv->register_edit_event
    exporting
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  loop at er_data_changed->mt_good_cells into ls_good.

    call method o_alv->get_current_cell
      importing
        e_row     = lv_row                                  "#EC NEEDED
        e_value   = lv_value                                "#EC NEEDED
        e_col     = lv_col                                  "#EC NEEDED
        es_row_id = ls_roid
        es_col_id = ls_col_id
        es_row_no = ls_row_no.

    call method er_data_changed->get_cell_value
      exporting
        i_row_id    = ls_good-row_id
        i_fieldname = ls_good-fieldname
      importing
        e_value     = lv_temp_str.
    if sy-subrc eq 0.
      case ls_good-fieldname.
        when 'CHARG'.
          read table i_batch assigning <lfs_batch> index ls_good-row_id.
          if sy-subrc eq 0.
            <lfs_batch>-charg = lv_temp_str.
            append <lfs_batch> to i_batch_s.
          endif. " IF sy-subrc EQ 0
      endcase.
    endif. " IF sy-subrc EQ 0
  endloop. " LOOP AT er_data_changed->mt_good_cells INTO ls_good

  call method o_alv->refresh_table_display.
endform. " F_HANDLE_DATA_CHANGE
*&---------------------------------------------------------------------*
*&      Form  F_SAVE_BATCH_CHANGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_save_batch_changes .
  data:
    li_return            type table of bapiret2,    " Return Parameter
    lwa_return           type bapiret2,             " Return Parameter
    li_return_c          type bapiret2,             " Return Parameter
    li_schedule_lines    type table of bapischdl,   " Communication Fields for Maintaining SD Doc. Schedule Lines
    li_schedule_linesx   type table of bapischdlx,  " Checkbox List for Maintaining Sales Document Schedule Line
    li_order_item_in     type table of bapisditm,   " Communication Fields: Sales and Distribution Document Item
    li_order_item_inx    type table of  bapisditmx, " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_in    type bapisditm,            " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_inx   type bapisditmx,           " Communication Fields: Sales and Distribution Document Item
    lwa_order_header_in  type bapisdh1,             " Communication Fields: SD Order Header
    lwa_order_header_inx type bapisdh1x,            " Checkbox List: SD Order Header
    lwa_bdbatch_f        type bdbatch,              " Results Table for Batch Determination
    lwa_schedule_lines   type bapischdl,            " Communication Fields for Maintaining SD Doc. Schedule Lines
    lwa_schedule_linesx  type bapischdlx,           " Checkbox List for Maintaining Sales Document Schedule Line
    lv_logtext           type string,
    lv_joblog            type string.

  field-symbols:
    <lfs_batch>          type ty_batch_final,
    <lfs_return>         type bapiret2, " Return Parameter
    <lfs_vbep_c>         type ty_vbep_c.

  constants:
    lc_error             type char1 value 'E'. " Error of type CHAR1

  loop at i_batch_s assigning <lfs_batch>.
    lwa_order_header_inx-updateflag = 'U'.
    lwa_order_item_in-itm_number = <lfs_batch>-posnr.
    append lwa_order_item_in to li_order_item_in.

    lwa_order_item_in-material = <lfs_batch>-matnr.
    lwa_order_item_in-batch = <lfs_batch>-charg.

    lwa_order_item_inx-itm_number = <lfs_batch>-posnr.
    lwa_order_item_inx-updateflag = 'U'.
    lwa_order_item_inx-batch = 'X'.
    append lwa_order_item_inx to li_order_item_inx.

    call function 'BAPI_SALESORDER_CHANGE'
      exporting
        salesdocument    = <lfs_batch>-vbeln
        order_header_inx = lwa_order_header_inx
      tables
        return           = li_return
        order_item_in    = li_order_item_in
        order_item_inx   = li_order_item_inx.

    read table li_return assigning <lfs_return>
                         with key type = lc_error. " Return assigning of type
    if sy-subrc <> 0.
      append lines of li_return to i_log.
      if sy-batch is initial.
      else. " ELSE -> IF sy-batch IS INITIAL
        loop at li_return into lwa_return.
          message id lwa_return-id type lwa_return-type
                                   number lwa_return-number
                                   with lwa_return-message
              into lv_joblog.
          write lv_joblog.
        endloop. " LOOP AT li_return INTO lwa_return
      endif. " IF sy-batch IS INITIAL

      refresh: li_return.
      call function 'BAPI_TRANSACTION_COMMIT'
        exporting
          wait   = 'X'
        importing
          return = li_return_c.

      append li_return_c to i_log.

      clear: lwa_order_header_inx.
      refresh: li_return,
               li_order_item_in,
               li_order_item_inx,
               li_schedule_lines,
               li_schedule_linesx.
    else. " ELSE -> IF sy-subrc <> 0
      call function 'BAPI_TRANSACTION_ROLLBACK'
        importing
          return = lwa_return.

      if sy-batch is initial.
        append lwa_return to i_log.
      else. " ELSE -> IF sy-batch IS INITIAL
        message id lwa_return-id type lwa_return-type
                                 number lwa_return-number
                                 with lwa_return-message
            into lv_joblog.
        write lv_joblog.
      endif. " IF sy-batch IS INITIAL
    endif. " IF sy-subrc <> 0
  endloop. " LOOP AT i_batch_s ASSIGNING <lfs_batch>
endform. " F_SAVE_BATCH_CHANGES
*&---------------------------------------------------------------------*
*&      Form  f_sequence_batches_c
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form f_sequence_batches_c .

  constants:
      lc_antigens   type string value 'ANTIGENS',
      lc_corres     type string value 'CORRESPONDING',
      lc_noncorres  type string value 'NON CORRESPONDING',
      lc_ordtyp_std type string value 'ZSTD',
      lc_ordtyp_or  type string value 'ZOR',
      lc_ordtyp_int type string value 'ZINT',
      lc_prior_1a   type string value 'A',
      lc_prior_1b   type string value 'B',
      lc_prior_1c   type string value 'C',
      lc_prior_2a   type string value 'D',
      lc_prior_2b   type string value 'E',
      lc_prior_2c   type string value 'F',
      lc_prior_3a   type string value 'G',
      lc_prior_3b   type string value 'H',
      lc_prior_3c   type string value 'I',
      lc_prior_4a   type string value 'J',
      lc_prior_4b   type string value 'K',
      lc_prior_4c   type string value 'L',
      lc_prior_5a   type string value 'M',
      lc_prior_5b   type string value 'N',
      lc_prior_5c   type string value 'O',
      lc_prior_5d   type string value 'P'.

  field-symbols:
    <lfs_batch> type ty_batch_final.

  sort i_batch_c by auart.

  loop at i_batch_c assigning <lfs_batch>.
    case <lfs_batch>-auart.
      when lc_ordtyp_std.
        if <lfs_batch>-corres = lc_corres.
          <lfs_batch>-prior = lc_prior_1a.
        elseif <lfs_batch>-corres = lc_noncorres.
          <lfs_batch>-prior = lc_prior_1b.
        elseif <lfs_batch>-antigens ne space.
          <lfs_batch>-prior = lc_prior_1c.
        elseif <lfs_batch>-antigens eq space and
               <lfs_batch>-corres   eq space.
          <lfs_batch>-prior = lc_prior_5a.
        endif. " IF <lfs_batch>-corres = lc_corres
      when lc_ordtyp_or.
        if <lfs_batch>-corres = lc_corres.
          <lfs_batch>-prior = lc_prior_2a.
        elseif <lfs_batch>-corres = lc_noncorres.
          <lfs_batch>-prior = lc_prior_2b.
        elseif <lfs_batch>-antigens ne space.
          <lfs_batch>-prior = lc_prior_2c.
        elseif <lfs_batch>-antigens eq space and
               <lfs_batch>-corres   eq space.
          <lfs_batch>-prior = lc_prior_5b.
        endif. " IF <lfs_batch>-corres = lc_corres
      when lc_ordtyp_int.
        if <lfs_batch>-corres = lc_corres.
          <lfs_batch>-prior = lc_prior_3a.
        elseif <lfs_batch>-corres = lc_noncorres.
          <lfs_batch>-prior = lc_prior_3b.
        elseif <lfs_batch>-antigens ne space.
          <lfs_batch>-prior = lc_prior_3c.
        elseif <lfs_batch>-antigens eq space and
               <lfs_batch>-corres   eq space.
          <lfs_batch>-prior = lc_prior_5c.
        endif. " IF <lfs_batch>-corres = lc_corres
      when others.
        if <lfs_batch>-corres = lc_corres.
          <lfs_batch>-prior = lc_prior_4a.
        elseif <lfs_batch>-corres = lc_noncorres.
          <lfs_batch>-prior = lc_prior_4b.
        elseif <lfs_batch>-antigens ne space.
          <lfs_batch>-prior = lc_prior_4c.
        elseif <lfs_batch>-antigens eq space and
               <lfs_batch>-corres   eq space.
          <lfs_batch>-prior = lc_prior_5d.
        endif. " IF <lfs_batch>-corres = lc_corres
    endcase.
  endloop. " LOOP AT i_batch_c ASSIGNING <lfs_batch>

  sort i_batch_c by prior ascending.

endform. " F_SEQUENCE_BATCHES
*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_BATCH_IN_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_clear_batch_in_so .

  data:
    li_return            type table of bapiret2,    " Return Parameter
    lwa_return           type bapiret2,             " Return Parameter
    li_return_c          type bapiret2,             " Return Parameter
    li_schedule_lines    type table of bapischdl,   " Communication Fields for Maintaining SD Doc. Schedule Lines
    li_schedule_linesx   type table of bapischdlx,  " Checkbox List for Maintaining Sales Document Schedule Line
    li_order_item_in     type table of bapisditm,   " Communication Fields: Sales and Distribution Document Item
    li_order_item_inx    type table of  bapisditmx, " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_in    type bapisditm,            " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_inx   type bapisditmx,           " Communication Fields: Sales and Distribution Document Item
    lwa_order_header_in  type bapisdh1,             " Communication Fields: SD Order Header
    lwa_order_header_inx type bapisdh1x,            " Checkbox List: SD Order Header
    lwa_bdbatch_f        type bdbatch,              " Results Table for Batch Determination
    lwa_schedule_lines   type bapischdl,            " Communication Fields for Maintaining SD Doc. Schedule Lines
    lwa_schedule_linesx  type bapischdlx,           " Checkbox List for Maintaining Sales Document Schedule Line
    lv_logtext           type string,
    lv_joblog            type string.

  field-symbols:
    <lfs_batch>          type ty_batch_final,
    <lfs_return>         type bapiret2, " Return Parameter
    <lfs_vbep_c>         type ty_vbep_c.

  constants:
    lc_error             type char1 value 'E'. " Error of type CHAR1

  loop at i_batch_a assigning <lfs_batch>.
    lwa_order_header_inx-updateflag = 'U'.
    lwa_order_item_in-itm_number = <lfs_batch>-posnr.
    lwa_order_item_in-material = <lfs_batch>-matnr.
    clear <lfs_batch>-charg .
    lwa_order_item_in-batch = <lfs_batch>-charg.
    append lwa_order_item_in to li_order_item_in.

    lwa_order_item_inx-itm_number = <lfs_batch>-posnr.
    lwa_order_item_inx-updateflag = 'U'.
    lwa_order_item_inx-batch = 'X'.
    append lwa_order_item_inx to li_order_item_inx.

    call function 'BAPI_SALESORDER_CHANGE'
      exporting
        salesdocument    = <lfs_batch>-vbeln
        order_header_inx = lwa_order_header_inx
      tables
        return           = li_return
        order_item_in    = li_order_item_in
        order_item_inx   = li_order_item_inx.

    read table li_return assigning <lfs_return>
                         with key type = lc_error. " Return assigning of type
    if sy-subrc <> 0.
      append lines of li_return to i_log.
      if sy-batch is initial.
      else. " ELSE -> IF sy-batch IS INITIAL
        loop at li_return into lwa_return.
          message id lwa_return-id type lwa_return-type
                                   number lwa_return-number
                                   with lwa_return-message
              into lv_joblog.
          write lv_joblog.
        endloop. " LOOP AT li_return INTO lwa_return
      endif. " IF sy-batch IS INITIAL

      refresh: li_return.
      call function 'BAPI_TRANSACTION_COMMIT'
        exporting
          wait   = 'X'
        importing
          return = li_return_c.

      append li_return_c to i_log.

      clear: lwa_order_header_inx.
      refresh: li_return,
               li_order_item_in,
               li_order_item_inx,
               li_schedule_lines,
               li_schedule_linesx.
    else. " ELSE -> IF sy-subrc <> 0
      call function 'BAPI_TRANSACTION_ROLLBACK'
        importing
          return = lwa_return.

      if sy-batch is initial.
        append lwa_return to i_log.
      else. " ELSE -> IF sy-batch IS INITIAL
        message id lwa_return-id type lwa_return-type
                                 number lwa_return-number
                                 with lwa_return-message
            into lv_joblog.
        write lv_joblog.
      endif. " IF sy-batch IS INITIAL
    endif. " IF sy-subrc <> 0
  endloop. " LOOP AT i_batch_a ASSIGNING <lfs_batch>

endform. " F_CLEAR_BATCH_IN_SO

*&---------------------------------------------------------------------*
*&      Form  f_validate_batches
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form f_validate_batches .

  data :li_log_f     type table of ty_final,
        lwa_log_f    type ty_final.

  field-symbols: <lfs_batch>          type ty_batch_final.

  if i_batch[] is not initial .
    select matnr werks charg from mcha " Batches
             into table i_mcha_data for all entries in i_batch
             where matnr = i_batch-matnr and
                   werks = i_batch-werks and
                   charg = i_batch-charg.
    sort i_mcha_data by matnr werks charg.
* Check invalid batchs and clean from the Screen.
    loop at i_batch_a assigning <lfs_batch>.
      read table i_mcha_data with key matnr = <lfs_batch>-matnr
                                      werks = <lfs_batch>-werks
                                      charg = <lfs_batch>-charg binary search transporting no fields .
      if sy-subrc <> 0 and <lfs_batch>-charg is not initial  .
*   Appned record to Log and clear Batch
        lwa_log_f-vbeln = <lfs_batch>-vbeln.
        lwa_log_f-posnr = <lfs_batch>-posnr.
        concatenate 'Invalid Batch'(d00) <lfs_batch>-charg into  lwa_log_f-message separated by space.
        append lwa_log_f to i_log_f .
        clear <lfs_batch>-charg .
      endif. " IF sy-subrc <> 0 AND <lfs_batch>-charg IS NOT INITIAL
    endloop . " LOOP AT i_batch_a ASSIGNING <lfs_batch>
  endif. " IF i_batch[] IS NOT INITIAL
endform. " F_VALIDATE_BATCHES

*&---------------------------------------------------------------------*
*&      Form  F_ASSIGN_BATCHES_TO_ORDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

*SOC by DDWIVEDI CR#231
form f_assign_batches_to_order .

  data:
    li_return            type table of bapiret2,    " Return Parameter
    lwa_return           type bapiret2,             " Return Parameter
    li_return_c          type bapiret2,             " Return Parameter
    li_schedule_lines    type table of bapischdl,   " Communication Fields for Maintaining SD Doc. Schedule Lines
    li_schedule_linesx   type table of bapischdlx,  " Checkbox List for Maintaining Sales Document Schedule Line
    li_order_item_in     type table of bapisditm,   " Communication Fields: Sales and Distribution Document Item
    li_order_item_inx    type table of  bapisditmx, " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_in    type bapisditm,            " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_inx   type bapisditmx,           " Communication Fields: Sales and Distribution Document Item
    lwa_order_header_in  type bapisdh1,             " Communication Fields: SD Order Header
    lwa_order_header_inx type bapisdh1x,            " Checkbox List: SD Order Header
    lwa_bdbatch_f        type bdbatch,              " Results Table for Batch Determination
    lwa_schedule_lines   type bapischdl,            " Communication Fields for Maintaining SD Doc. Schedule Lines
    lwa_schedule_linesx  type bapischdlx,           " Checkbox List for Maintaining Sales Document Schedule Line
    lv_logtext           type string,
    lv_joblog            type string,
    lwa_log              type ty_final.

  field-symbols:
    <lfs_batch>          type ty_batch_final,
    <lfs_return>         type bapiret2. " Return Parameter

  constants:
    lc_error             type char1 value 'E'. " Error of type CHAR1

  lwa_order_header_inx-updateflag = 'U'.
  lwa_order_item_in-itm_number = <fs_batch>-posnr.
*  READ TABLE i_bdbatch_f INTO lwa_bdbatch_f INDEX 1.
*  IF sy-subrc EQ 0.
  lwa_order_item_in-material = <fs_batch>-matnr.
  lwa_order_item_in-batch = <fs_batch>-charg.
*    lwa_schedule_lines-req_qty = lwa_bdbatch_f-menge.
*  ENDIF. " IF sy-subrc EQ 0
  append lwa_order_item_in to li_order_item_in.

  lwa_order_item_inx-itm_number = <fs_batch>-posnr.
  lwa_order_item_inx-updateflag = 'U'.
  lwa_order_item_inx-batch = 'X'.
  append lwa_order_item_inx to li_order_item_inx.

  check <fs_batch> is assigned.

  call function 'BAPI_SALESORDER_CHANGE'
    exporting
      salesdocument    = <fs_batch>-vbeln
      order_header_inx = lwa_order_header_inx
    tables
      return           = li_return
      order_item_in    = li_order_item_in
      order_item_inx   = li_order_item_inx.

  read table li_return assigning <lfs_return>
                       with key type = lc_error. " Return assigning of type
  if sy-subrc ne 0.

    lwa_log-vbeln   = <fs_batch>-vbeln.
    lwa_log-posnr   = <fs_batch>-posnr.
    lwa_log-status  = 'S'.
    lwa_log-message = 'Sales Order successfully saved'.
    append lwa_log to i_log_f.

    clear: li_return_c.
    call function 'BAPI_TRANSACTION_COMMIT'
      exporting
        wait   = 'X'
      importing
        return = li_return_c.

    append li_return_c to i_log.

    clear: lwa_order_header_inx.
    refresh: li_return,
             li_order_item_in,
             li_order_item_inx,
             li_schedule_lines,
             li_schedule_linesx.
  else. " ELSE -> IF sy-subrc NE 0
    if sy-batch is initial.
      <fs_batch>-charg = lwa_bdbatch_f-charg.
      lwa_log-vbeln   = <fs_batch>-vbeln.
      lwa_log-posnr   = <fs_batch>-posnr.
      lwa_log-status  = 'E'.
      lwa_log-message = <lfs_return>-message.
      append lwa_log to i_log_f.
    else. " ELSE -> IF sy-batch IS INITIAL
      concatenate <fs_batch>-vbeln '/' <fs_batch>-posnr 'E' '/' <lfs_return>-message
            into lv_joblog.
      write lv_joblog.
    endif. " IF sy-batch IS INITIAL

    call function 'BAPI_TRANSACTION_ROLLBACK'
      importing
        return = lwa_return.

    if lwa_return is not initial.
      if sy-batch is initial.
        <fs_batch>-charg = lwa_bdbatch_f-charg.

        lwa_log-vbeln   = <fs_batch>-vbeln.
        lwa_log-posnr   = <fs_batch>-posnr.
        lwa_log-status  = 'E'.
        lwa_log-message = 'Changes are NOT saved'.
        append lwa_log to i_log_f.

      else. " ELSE -> IF sy-batch IS INITIAL
        lwa_log-message = 'Changes are NOT saved'.
        concatenate <fs_batch>-vbeln '/' <fs_batch>-posnr 'E' '/' lwa_log-message
              into lv_joblog.
        write lv_joblog.
      endif. " IF sy-batch IS INITIAL
    endif. " IF lwa_return IS NOT INITIAL
  endif. " IF sy-subrc NE 0

endform. " F_ASSIGN_BATCHES_TO_ORDER
*&---------------------------------------------------------------------*
*&      Form  F_MATERIAL_AVAILABILITY_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_material_availability_check .


  data :li_log_f     type table of ty_final,
        li_wmdvsx    type standard table of bapiwmdvs, " Structure for Simulated Reqmts - ATP Internet Information
        li_wmdvex    type standard table of bapiwmdve, " Results of Availability Check - ATP Info in Internet
        lwa_wmdvex   type bapiwmdve,                   " Results of Availability Check - ATP Info in Internet
        lwa_vbep     type ty_vbep,
        lwa_final    type ty_final,
        lwa_log_f    type ty_final,
        lv_dialogflag type char1.                      " Dialogflag of type CHAR1

  field-symbols: <lfs_batch>          type ty_batch_final.

  sort i_mcha_data by matnr werks charg.

* Check invalid batchs and clean from the Screen.
  loop at i_batch_a assigning <lfs_batch>.
    clear: lv_dialogflag.
    refresh: li_wmdvsx,
             li_wmdvex.

    read table i_mcha_data with key matnr = <lfs_batch>-matnr
                                    werks = <lfs_batch>-werks
                                    charg = <lfs_batch>-charg binary search transporting no fields .
    if sy-subrc = 0 and <lfs_batch>-charg is not initial .

      call function 'BAPI_MATERIAL_AVAILABILITY'
        exporting
          plant      = <lfs_batch>-werks
          material   = <lfs_batch>-matnr
          unit       = <lfs_batch>-uom
          batch      = <lfs_batch>-charg
          doc_number = <lfs_batch>-vbeln
          itm_number = <lfs_batch>-posnr
        importing
          dialogflag = lv_dialogflag
        tables
          wmdvsx     = li_wmdvsx
          wmdvex     = li_wmdvex.

      if lv_dialogflag is initial .
        read table li_wmdvex into lwa_wmdvex index 1.
        if sy-subrc = 0.
          read table i_vbep into lwa_vbep with key vbeln = <lfs_batch>-vbeln
                                                   posnr = <lfs_batch>-posnr binary search.
          if sy-subrc eq 0.
            if lwa_vbep-wmeng gt lwa_wmdvex-com_qty. "Log
              move <lfs_batch>-vbeln to lwa_final-vbeln.
              move <lfs_batch>-posnr to lwa_final-posnr.
              lwa_final-status = 'E'.
              lwa_final-message = 'Ordered Quantity exceeds available quantity'(d04).
              concatenate lwa_final-message 'Batch'(t13) <lfs_batch>-charg into lwa_final-message separated by space.
              append lwa_final to i_log_f.
              clear <lfs_batch>-charg.
            else. " ELSE -> IF lwa_vbep-wmeng GT lwa_wmdvex-com_qty
              assign <lfs_batch> to <fs_batch>.
              perform f_assign_batches_to_order.
              unassign <fs_batch>.
            endif. " IF lwa_vbep-wmeng GT lwa_wmdvex-com_qty
          endif. " IF sy-subrc EQ 0
        endif. " IF sy-subrc = 0
      endif. " IF lv_dialogflag IS INITIAL
    endif. " IF sy-subrc = 0 AND <lfs_batch>-charg IS NOT INITIAL
  endloop . " LOOP AT i_batch_a ASSIGNING <lfs_batch>
endform. " F_MATERIAL_AVAILABILITY_CHECK

*EOC by DDWIVEDI CR#231
*&---------------------------------------------------------------------*
*&      Form  F_GROUP_SINGLE_MATNR_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_group_single_matnr_batch .

  data:
    lv_count type i.

  data:
    lwa_komkh    type komkh,            " Batch Determination Communication Block Header
    lwa_komph    type komph,            " Batch Determination: Communication Record for Item
    lwa_bdcom    type bdcom,            " Batch Determination Communication Structure
    lwa_final    type ty_final,
    li_t459a     type table of t459a,   " External requirements types
    lwa_t459a    type t459a,            " External requirements types
    lwa_vbep     type ty_vbep,
    lwa_bdbatch  type bdbatch,          " Results Table for Batch Determination
    li_kna1      type table of ty_kna1,
    li_vbap      type table of ty_vbap,
    li_bdbatch   type table of bdbatch, " Results Table for Batch Determination
    li_bdbatch_f type table of bdbatch. " Results Table for Batch Determination

  field-symbols:
    <lfs_kna1>  type ty_kna1,
    <lfs_vbap>  type ty_vbap,
    <lfs_vbep>  type ty_vbep,
    <lfs_batch> type ty_batch_final.

  i_batch_m = i_batch_a.
  sort i_batch_m by vbeln matnr.
  delete adjacent duplicates from i_batch_m comparing vbeln matnr.

  clear lv_count.
  loop at i_batch_m assigning <lfs_batch>.
    loop at i_vbap assigning <lfs_vbap>
                   where vbeln = <lfs_batch>-vbeln
                   and   matnr = <lfs_batch>-matnr.
      lv_count = lv_count + 1.
    endloop.
    if lv_count eq 1.
      append <lfs_batch> to i_batch_d.
      delete i_batch_a where vbeln eq <lfs_batch>-posnr and posnr eq <lfs_batch>-posnr.
    else.
      clear lv_count.
    endif.
  endloop.

  loop at i_batch_d assigning <lfs_batch>.
*                    where bmeng ne 0.
    lwa_komkh-mandt = sy-mandt.
    lwa_komkh-kndnr = <lfs_batch>-kunnr.
    lwa_komkh-knrze = <lfs_batch>-kunnr.
    lwa_komkh-kunnr = <lfs_batch>-kunnr.
    lwa_komkh-vkorg = <lfs_batch>-vkorg.
    lwa_komkh-vtweg = <lfs_batch>-vtweg.
    lwa_komkh-spart = <lfs_batch>-kunnr.
    lwa_komkh-auart = <lfs_batch>-auart.
    lwa_komkh-auart_sd = <lfs_batch>-auart_sd.

    lwa_komph-matnr = <lfs_batch>-matnr.
    lwa_komph-werks = <lfs_batch>-werks.

    read table i_vbap assigning <lfs_vbap>
                       with key vbeln = <lfs_batch>-vbeln
                                posnr = <lfs_batch>-posnr
                       binary search.
    if sy-subrc eq 0.
      lwa_komph-mvgr2 = <lfs_vbap>-mvgr2.
      lwa_bdcom-mtvfp = <lfs_vbap>-mtvfp.

      read table i_t459a into lwa_t459a with key bedae = <lfs_vbap>-bedae.
      if sy-subrc eq 0.
        lwa_bdcom-bedar = lwa_t459a-bedar.
      endif. " IF sy-subrc EQ 0
    endif. " IF sy-subrc EQ 0

    lwa_bdcom-kappl = 'V'.
    lwa_bdcom-kalsm = 'SD0001'.
    lwa_bdcom-umrez = '1'.
    lwa_bdcom-umren = '1'.
    lwa_bdcom-kzvbp = 'X'.
    lwa_bdcom-prreg = 'A'.
    lwa_bdcom-chasp = '001'.
    lwa_bdcom-delkz = 'VC'.

    lwa_bdcom-menge = <lfs_batch>-omeng.
    lwa_bdcom-meins = <lfs_batch>-uom.
    lwa_bdcom-erfmg = <lfs_batch>-omeng.
    lwa_bdcom-erfme = <lfs_batch>-uom.
    lwa_bdcom-mbdat = <lfs_batch>-mbdat.
    lwa_bdcom-kund1 = <lfs_batch>-kunnr.
    lwa_bdcom-name1 = <lfs_batch>-name1.
    lwa_bdcom-delnr = <lfs_batch>-vbeln.
    lwa_bdcom-delps = <lfs_batch>-posnr.

    read table  i_vbep assigning <lfs_vbep>
                       with key vbeln = <lfs_batch>-vbeln
                                posnr = <lfs_batch>-posnr
                       binary search.
    if sy-subrc eq 0.
      lwa_bdcom-mbuhr = <lfs_vbep>-mbuhr.
    endif. " IF sy-subrc EQ 0

    lwa_bdcom-nodia = 'X'.

    read table i_kna1 assigning <lfs_kna1>
                       with key kunnr = <lfs_batch>-kunnr
                       binary search.
    if sy-subrc eq 0.
      lwa_bdcom-ort01 = <lfs_kna1>-ort01.
      lwa_bdcom-land1 = <lfs_kna1>-land1.
      lwa_bdcom-pstlz = <lfs_kna1>-pstlz.
    endif. " IF sy-subrc EQ 0

    clear li_bdbatch.
    refresh: li_bdbatch.
    call function 'VB_BATCH_DETERMINATION'
      exporting
        i_komkh   = lwa_komkh
        i_komph   = lwa_komph
        x_bdcom   = lwa_bdcom
      tables
        e_bdbatch = li_bdbatch
      exceptions
        no_plant  = 7
        others    = 99.
    if sy-subrc <> 0 or
       li_bdbatch is initial.
      message e000 with 'No batch determined'(021) into lwa_final-message.
      move 'E'      to lwa_final-status.
      move <lfs_batch>-vbeln to lwa_final-vbeln.
      move <lfs_batch>-posnr to lwa_final-posnr.
      append lwa_final to i_log_f.
    else. " ELSE -> IF sy-subrc <> 0 OR
      read table li_bdbatch into lwa_bdbatch index 1.
      read table i_vbep into lwa_vbep with key vbeln = <lfs_batch>-vbeln
                                               posnr = <lfs_batch>-posnr.
      if sy-subrc eq 0.
        if lwa_vbep-wmeng gt lwa_bdbatch-vrfmg.
          "Log
          move <lfs_batch>-vbeln to lwa_final-vbeln.
          move <lfs_batch>-posnr to lwa_final-posnr.
          lwa_final-status = 'E'.
          lwa_final-message = 'Ordered Quantity exceeds available quantity'.
          append lwa_final to i_log_f.

          refresh: li_bdbatch.
        else. " ELSE -> IF lwa_vbep-wmeng GT lwa_bdbatch-vrfmg
          append lines of li_bdbatch to i_bdbatch_f.
          <lfs_batch>-charg = lwa_bdbatch-charg.
          assign <lfs_batch> to <fs_batch>.

*          if li_bdbatch is not initial.
*           perform f_assign_multi_batches.
*          endif. " IF li_bdbatch IS NOT INITIAL
        endif. " IF lwa_vbep-wmeng GT lwa_bdbatch-vrfmg
      endif. " IF sy-subrc EQ 0
    endif. " IF sy-subrc <> 0 OR

    clear : lwa_komkh,
            lwa_komph,
            lwa_bdcom.

    refresh: li_bdbatch.
*             i_bdbatch_f.
  endloop. " LOOP AT i_batch_a ASSIGNING <lfs_batch>

  if i_bdbatch_f is not initial.
    perform f_assign_multi_batches.
  endif. " IF li_bdbatch IS NOT INITIAL

endform.                    " F_GROUP_SINGLE_MATNR_BATCH
*&---------------------------------------------------------------------*
*&      Form  F_ASSIGN_MULTI_BATCHES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_assign_multi_batches .

  data:
    li_return            type table of bapiret2,    " Return Parameter
    lwa_return           type bapiret2,             " Return Parameter
    li_return_c          type bapiret2,             " Return Parameter
    li_schedule_lines    type table of bapischdl,   " Communication Fields for Maintaining SD Doc. Schedule Lines
    li_schedule_linesx   type table of bapischdlx,  " Checkbox List for Maintaining Sales Document Schedule Line
    li_order_item_in     type table of bapisditm,   " Communication Fields: Sales and Distribution Document Item
    li_order_item_inx    type table of  bapisditmx, " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_in    type bapisditm,            " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_inx   type bapisditmx,           " Communication Fields: Sales and Distribution Document Item
    lwa_order_header_in  type bapisdh1,             " Communication Fields: SD Order Header
    lwa_order_header_inx type bapisdh1x,            " Checkbox List: SD Order Header
    lwa_bdbatch_f        type bdbatch,              " Results Table for Batch Determination
    lwa_schedule_lines   type bapischdl,            " Communication Fields for Maintaining SD Doc. Schedule Lines
    lwa_schedule_linesx  type bapischdlx,           " Checkbox List for Maintaining Sales Document Schedule Line
    lwa_log              type ty_final,
    lv_logtext           type string,
    lv_joblog            type string.

  field-symbols:
    <lfs_batch>          type ty_batch_final,
    <lfs_batch_c>        type ty_batch_final,
    <lfs_return>         type bapiret2, " Return Parameter
    <lfs_vbep_c>         type ty_vbep_c.

  constants:
    lc_error             type char1 value 'E'. " Error of type CHAR1

  loop at i_batch_d assigning <lfs_batch>
                    where charg ne space.

    lwa_order_header_inx-updateflag = 'U'.
    lwa_order_item_in-itm_number = <lfs_batch>-posnr.
*    read table i_bdbatch_f into lwa_bdbatch_f with key matnr = <lfs_batch>-matnr.
*    if sy-subrc eq 0.
    lwa_order_item_in-material = <lfs_batch>-matnr. "lwa_bdbatch_f-matnr.
    lwa_order_item_in-batch = <lfs_batch>-charg.
*      lwa_order_item_in-batch = lwa_bdbatch_f-charg.
*      <lfs_batch>-charg       = lwa_bdbatch_f-charg.
    read table i_vbep_c assigning <lfs_vbep_c>
                        with key vbeln = <lfs_batch>-vbeln
                                 posnr = <lfs_batch>-posnr.
    if sy-subrc eq 0.
      lwa_schedule_lines-req_qty = <lfs_vbep_c>-wmeng.
    endif. " IF sy-subrc EQ 0
*    endif. " IF sy-subrc EQ 0
    append lwa_order_item_in to li_order_item_in.

    lwa_order_item_inx-itm_number = <lfs_batch>-posnr.
    lwa_order_item_inx-updateflag = 'U'.
    lwa_order_item_inx-batch = 'X'.
    append lwa_order_item_inx to li_order_item_inx.

    lwa_schedule_lines-itm_number = <lfs_batch>-posnr.
    lwa_schedule_lines-sched_line = '0001'.
    append lwa_schedule_lines to li_schedule_lines.

    lwa_schedule_linesx-itm_number = <lfs_batch>-posnr.
    lwa_schedule_linesx-req_qty    = 'X'.
    lwa_schedule_linesx-updateflag = 'U'.
    lwa_schedule_linesx-sched_line = '0001'.
    append lwa_schedule_linesx to li_schedule_linesx.
  endloop. " LOOP AT i_batch_c ASSIGNING <lfs_batch>
  break-point.
  check <lfs_batch> is assigned.

  call function 'BAPI_SALESORDER_CHANGE'
    exporting
      salesdocument     = <lfs_batch>-vbeln
      order_header_inx  = lwa_order_header_inx
*     behave_when_error = 'X'
    tables
      return            = li_return
      order_item_in     = li_order_item_in
      order_item_inx    = li_order_item_inx.

  read table li_return assigning <lfs_return>
                       with key type = lc_error. " Return assigning of type
  if sy-subrc <> 0.

    if sy-batch is initial.

      lwa_log-vbeln   = <lfs_batch>-vbeln.
      lwa_log-posnr   = <lfs_batch>-posnr.
      lwa_log-status  = 'S'.
      lwa_log-message = 'Sales Order successfully saved'.
      append lwa_log to i_log_f.

      loop at i_batch_c assigning <lfs_batch_c>
                            where vbeln = gv_vbeln.
        loop at i_batch assigning <lfs_batch>
                            where vbeln = gv_vbeln
                              and posnr = <lfs_batch_c>-posnr.
          <lfs_batch>-charg = <lfs_batch_c>-charg.
        endloop. " LOOP AT i_batch ASSIGNING <lfs_batch>
      endloop. " LOOP AT i_batch_c ASSIGNING <lfs_batch_c>
    else. " ELSE -> IF sy-batch IS INITIAL
      loop at li_return into lwa_return.
        message id lwa_return-id type lwa_return-type
                                 number lwa_return-number
                                 with lwa_return-message
            into lv_joblog.
        write lv_joblog.
      endloop. " LOOP AT li_return INTO lwa_return
    endif. " IF sy-batch IS INITIAL

    refresh: li_return.
    call function 'BAPI_TRANSACTION_COMMIT'
      exporting
        wait   = 'X'
      importing
        return = li_return_c.

    append li_return_c to i_log.

    clear: lwa_order_header_inx.
    refresh: li_return,
             li_order_item_in,
             li_order_item_inx,
             li_schedule_lines,
             li_schedule_linesx.
  else. " ELSE -> IF sy-subrc <> 0
    call function 'BAPI_TRANSACTION_ROLLBACK'
      importing
        return = lwa_return.

    if sy-batch is initial.
      append lwa_return to i_log.
    else. " ELSE -> IF sy-batch IS INITIAL
      message id lwa_return-id type lwa_return-type
                               number lwa_return-number
                               with lwa_return-message
          into lv_joblog.
      write lv_joblog.
    endif. " IF sy-batch IS INITIAL
  endif. " IF sy-subrc <> 0

endform.                    " F_ASSIGN_MULTI_BATCHES
