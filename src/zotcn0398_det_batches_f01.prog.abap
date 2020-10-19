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
* 27-Jun-2018 DARUMUG  E1DK937390 Defect# 6508 Unlock SO's once batch  *
*                                              is determined           *
* 02-Jul-2018 DARUMUG  E1DK937511 INC0423487 Defect# 6633 Consider     *
*                                 validity dates from Condition Records*
*                                 for Prioritization rules             *
*                                                                      *
*&---------------------------------------------------------------------*
* 23-Aug-2018 ASk   E1DK938198    Defect# 6886 Correct ATP check       *
*                                 validation during excel upload mode  *
*                                                                      *
* 04-Oct-2018 APODDAR  E1DK938946 Defect# 7289: Enabling background    *
*                                 functionality for BDP tool           *
* 29-Oct-2019 U033959  E2DK927169 Defect#10665- INC0433610-01          *
*                                 When split file check box is selected*
*                                 for background mode, then the records*
*                                 in the uploaded file will be split   *
*                                 into multiple files & mulitple       *
*                                 background jobs will be triggered.   *
*                                 Each file file contain no.of records *
*                                 as maintained in EMI                 *
*&---------------------------------------------------------------------*
FORM f_get_emi_values .
  CONSTANTS: lc_edd_no TYPE z_enhancement  VALUE 'D3_OTC_EDD_0398'. " Enhancement No.
*  FIELD-SYMBOLS:

  gv_repid = sy-repid.

* Retrieve the constants values for D3_OTC_EDD_0398
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_edd_no
    TABLES
      tt_enh_status     = i_edd_emi.
  DELETE i_edd_emi WHERE active = abap_false.
  IF i_edd_emi[] IS NOT INITIAL.
    SORT i_edd_emi BY criteria sel_low.
  ENDIF. " IF i_edd_emi[] IS NOT INITIAL

ENDFORM. " F_GET_EMI_VALUES
*&---------------------------------------------------------------------*
*&      Form  F_GET_ORDERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_orders .
  DATA:
    lwa_vbcom TYPE vbcom. " Communication Work Area for Sales Doc.Access Methods

  DATA:
    li_lvbmtv TYPE TABLE OF vbmtv. " View: Order Items for Material

  lwa_vbcom-zuart     = 'A'.
  lwa_vbcom-trvog     = '0'.
  lwa_vbcom-stat_dazu = 'X'.
  lwa_vbcom-name_dazu = 'X'.
  lwa_vbcom-kopf_dazu = 'X'.
  lwa_vbcom-vboff     = 'X'.

  "From Selection Screen
  lwa_vbcom-werks = s_werks-low.

  PERFORM f_build_selection_tab.

  LOOP AT s_matnr.
    lwa_vbcom-matnr = s_matnr-low.
    CALL FUNCTION 'RV_SALES_DOCUMENT_VIEW_3'
      EXPORTING
        vbcom   = lwa_vbcom
      TABLES
        lvbmtv  = li_lvbmtv
        lseltab = i_lseltab.

    IF li_lvbmtv IS NOT INITIAL.
      APPEND LINES OF li_lvbmtv TO i_lvbmtv.
    ENDIF. " IF li_lvbmtv IS NOT INITIAL
    REFRESH: li_lvbmtv.
  ENDLOOP. " LOOP AT s_matnr

  "Get Sales Order Details
  PERFORM f_get_sales_order_details.

ENDFORM. " F_GET_ORDERS
*&---------------------------------------------------------------------*
*&      Form  F_GET_SALES_ORDER_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_sales_order_details .

  TYPES:
    BEGIN OF lty_objnum,
      objek TYPE objnum, " Key of object to be classified
      atinn TYPE atinn,  " Internal characteristic
      atnam TYPE atnam,  " Characteristic Name
    END OF lty_objnum,

    BEGIN OF lty_atinn,
      atinn TYPE atinn,  " Internal characteristic
    END OF lty_atinn,

    BEGIN OF lty_vbbe,
      vbeln TYPE vbeln,     " Sales and Distribution Document Number
      posnr TYPE posnr,     " Item number of the SD document
      etenr TYPE etenr,     " Delivery Schedule Line Number
      mbdat TYPE mbdat,     " Material Staging/Availability Date
      omeng TYPE omeng,     " Open Qty in Stockkeeping Units for Transfer of Reqmts to MRP
      meins TYPE meins,     " Base Unit of Measure
      auart TYPE auart,     " Sales Document Type
    END OF lty_vbbe,

    BEGIN OF lty_koth916,
      kappl	TYPE kappl,
      kschl	TYPE kschh,
      vkorg	TYPE vkorg,
      vtweg	TYPE vtweg,
      kunnr	TYPE kunnr,
      matnr	TYPE matnr,
      knumh	TYPE knumh,
    END OF lty_koth916,

    BEGIN OF lty_ausp,
      objek TYPE objnum,    " Key of object to be classified
      atinn TYPE atinn,     " Internal characteristic
      atwrt TYPE atwrt,     " Characteristic Value
    END OF lty_ausp,

    BEGIN OF lty_cabn,
      atinn TYPE atinn,     " Internal characteristic
      atnam TYPE atnam,     " Characteristic Name
    END OF lty_cabn.

  DATA:
    lwa_vbbe    TYPE lty_vbbe,
    lwa_vbep    TYPE ty_vbep,
    lwa_vbep_c  TYPE ty_vbep_c,

    li_koth916  TYPE TABLE OF lty_koth916,
    lwa_koth916 TYPE lty_koth916,

    li_kondh    TYPE TABLE OF kondh,   " Conditions: Batch Strategy - Data Division
    lwa_kondh   TYPE kondh,            " Conditions: Batch Strategy - Data Division

    li_ausp     TYPE TABLE OF lty_ausp,
    lwa_ausp    TYPE lty_ausp,

    lwa_objek   TYPE lty_objnum,
    li_objek    TYPE TABLE OF lty_objnum,

    lwa_atinn   TYPE lty_atinn,
    li_atinn    TYPE TABLE OF lty_atinn,

    li_vbbe     TYPE TABLE OF lty_vbbe,

    lwa_edd_emi TYPE zdev_enh_status. " Enhancement Status for EDD

  DATA:
    li_edd_emi    TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
    lv_atinn_anti TYPE atinn,                             " Internal characteristic
    lv_atinn_corr TYPE atinn,                             " Internal characteristic
    lv_index      TYPE sy-tabix,                          " Index of Internal Tables
    lwa_lvbmtv    TYPE vbmtv,                             " View: Order Items for Material
    lwa_batch     TYPE ty_batch_final,
    li_cabn       TYPE STANDARD TABLE OF lty_cabn INITIAL SIZE 0,
    lwa_cabn      TYPE lty_cabn.

  CONSTANTS:
    lc_ausp     TYPE char10 VALUE 'BATCH_CHAR',       " Ausp of type CHAR10
    lc_adzhl    TYPE char4 VALUE '0000',              " Adzhl of type CHAR4
    lc_antigens TYPE atnam VALUE 'ANTIGENS',          " Characteristic Name
    lc_cor      TYPE atnam VALUE 'CORRESPONDING',     " Characteristic Name
    lc_noncor   TYPE atnam VALUE 'NON CORRESPONDING', " Characteristic Name
    lc_corres   TYPE atnam VALUE 'CORR_PAP_BAT'.      " Characteristic Name

  CLEAR: lv_atinn_anti,
         lv_atinn_corr.

  LOOP AT i_edd_emi INTO lwa_edd_emi
                    WHERE criteria = lc_ausp.
    CLEAR lv_atinn_anti.
    SELECT atinn atnam
                 FROM cabn UP TO 1 ROWS
                 INTO lwa_cabn
                 WHERE atnam = lwa_edd_emi-sel_low
                 AND   adzhl = lc_adzhl.
    ENDSELECT.
    IF sy-subrc EQ 0.
      APPEND lwa_cabn TO li_cabn.
    ENDIF. " IF sy-subrc EQ 0
  ENDLOOP. " LOOP AT i_edd_emi INTO lwa_edd_emi

  SELECT SINGLE atinn FROM cabn " Characteristic
               INTO lv_atinn_anti
               WHERE atnam = 'ANTIGENS'.

  SELECT SINGLE atinn FROM cabn " Characteristic
               INTO lv_atinn_corr
               WHERE atnam = 'CORR_PAP_BAT'.

  IF i_lvbmtv IS NOT INITIAL.

    SELECT vbeln posnr etenr
           edatu wmeng lmeng mbuhr
             FROM vbep " Sales Document: Schedule Line Data
             INTO TABLE i_vbep
             FOR ALL ENTRIES IN i_lvbmtv
             WHERE vbeln = i_lvbmtv-vbeln AND
                   posnr = i_lvbmtv-posnr AND
                   edatu BETWEEN s_rqdate-low AND s_rqdate-high.
    SORT i_vbep BY vbeln posnr.
    LOOP AT i_vbep INTO lwa_vbep.
      lwa_vbep_c-vbeln = lwa_vbep-vbeln.
      lwa_vbep_c-posnr = lwa_vbep-posnr.
      lwa_vbep_c-wmeng = lwa_vbep-wmeng.
      lwa_vbep_c-lmeng = lwa_vbep-lmeng.
      COLLECT lwa_vbep_c INTO i_vbep_c.
    ENDLOOP. " LOOP AT i_vbep INTO lwa_vbep

    DELETE i_vbep WHERE etenr NE '0001'.

    CLEAR lv_index.
    LOOP AT i_lvbmtv INTO lwa_lvbmtv.
      lv_index = sy-tabix.
      READ TABLE i_vbep INTO lwa_vbep
                        WITH KEY vbeln = lwa_lvbmtv-vbeln
                                 posnr = lwa_lvbmtv-posnr
                        BINARY SEARCH.
      IF sy-subrc NE 0.
        DELETE i_lvbmtv INDEX lv_index.
      ENDIF. " IF sy-subrc NE 0
    ENDLOOP. " LOOP AT i_lvbmtv INTO lwa_lvbmtv

    SELECT vbeln posnr etenr mbdat
           omeng meins auart
             FROM vbbe " Sales Requirements: Individual Records
             INTO TABLE li_vbbe
             FOR ALL ENTRIES IN i_lvbmtv
             WHERE vbeln = i_lvbmtv-vbeln AND
                   posnr = i_lvbmtv-posnr AND
                   etenr = '0001'.
    SORT li_vbbe BY vbeln posnr.

    SELECT kappl kschl vkorg vtweg
           kunnr matnr knumh
             FROM koth916             " Sales org./Distr. Chl/Customer/Material
             INTO TABLE li_koth916
             FOR ALL ENTRIES IN i_lvbmtv
             WHERE vkorg = i_lvbmtv-vkorg AND
                   vtweg = i_lvbmtv-vtweg AND
                   matnr = i_lvbmtv-matnr AND
                   kunnr = i_lvbmtv-kunnr AND
                   datbi GT sy-datum. "INC0423487 Defect# 6633 - Consider Validity dates

    SORT li_koth916 BY knumh.

    IF li_koth916 IS NOT INITIAL.
      SELECT * FROM kondh             " Conditions: Batch Strategy - Data Division
              INTO TABLE li_kondh
              FOR ALL ENTRIES IN li_koth916
              WHERE knumh = li_koth916-knumh
              AND   loevm_ko = space. "INC0423487 Defect# 6633 - Consider deletion flag for Batch Strategy
      SORT li_kondh BY knumh.
    ENDIF. " IF li_koth916 IS NOT INITIAL

    IF li_kondh IS NOT INITIAL.
      LOOP AT li_kondh  INTO lwa_kondh.
        lwa_objek-objek = lwa_kondh-cuobj_ch.
        LOOP AT li_cabn INTO lwa_cabn.
          lwa_objek-atinn = lwa_cabn-atinn.
          lwa_objek-atnam = lwa_cabn-atnam.
          APPEND lwa_objek TO li_objek.
        ENDLOOP. " LOOP AT li_cabn INTO lwa_cabn
      ENDLOOP. " LOOP AT li_kondh INTO lwa_kondh

      IF li_objek IS NOT INITIAL.
        SELECT objek atinn atwrt FROM ausp " Characteristic Values
                INTO TABLE li_ausp
                FOR ALL ENTRIES IN li_objek
                WHERE objek = li_objek-objek
                AND   atinn = lv_atinn_anti.

        SELECT objek atinn atwrt FROM ausp " Characteristic Values
                APPENDING TABLE li_ausp
                FOR ALL ENTRIES IN li_objek
                WHERE objek = li_objek-objek
                AND   atinn = lv_atinn_corr.

      ENDIF. " IF li_objek IS NOT INITIAL
    ENDIF. " IF li_kondh IS NOT INITIAL

  ENDIF. " IF i_lvbmtv IS NOT INITIAL

  SORT li_koth916 BY vkorg vtweg matnr.

  LOOP AT i_lvbmtv INTO lwa_lvbmtv.

    READ TABLE i_vbep INTO lwa_vbep
                       WITH KEY vbeln = lwa_lvbmtv-vbeln
                                posnr = lwa_lvbmtv-posnr
                                BINARY SEARCH.
    IF sy-subrc EQ 0.
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

      READ TABLE li_vbbe INTO lwa_vbbe
                         WITH KEY vbeln = lwa_batch-vbeln
                                  posnr = lwa_batch-posnr
                                  BINARY SEARCH.
      IF sy-subrc EQ 0.
        lwa_batch-omeng = lwa_vbbe-omeng.
        lwa_batch-auart = lwa_vbbe-auart.
        lwa_batch-uom   = lwa_vbbe-meins.
        lwa_batch-mbdat = lwa_vbbe-mbdat.
      ENDIF. " IF sy-subrc EQ 0

      LOOP AT li_koth916 INTO lwa_koth916
                            WHERE vkorg = lwa_batch-vkorg AND
                                     vtweg = lwa_batch-vtweg AND
                                     matnr = lwa_batch-matnr AND
                                     kunnr = lwa_batch-kunnr.

        READ TABLE li_kondh INTO lwa_kondh
                              WITH KEY knumh = lwa_koth916-knumh
                              BINARY SEARCH.
        IF sy-subrc EQ 0.
          lwa_objek-objek = lwa_kondh-cuobj_ch.

          READ TABLE li_ausp INTO lwa_ausp
                             WITH KEY objek = lwa_objek-objek
                                      atinn = lv_atinn_anti.
          IF sy-subrc = 0.
            lwa_batch-antigens = lwa_ausp-atwrt.
          ENDIF. " IF sy-subrc = 0

          READ TABLE li_ausp INTO lwa_ausp
                             WITH KEY objek = lwa_objek-objek
                                      atinn = lv_atinn_corr.
          IF sy-subrc = 0.
            lwa_batch-corres = lwa_ausp-atwrt.
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF sy-subrc EQ 0
        CLEAR: lwa_ausp,
               lwa_objek.
      ENDLOOP. " LOOP AT li_koth916 INTO lwa_koth916

      APPEND lwa_batch TO i_batch.
    ENDIF. " IF sy-subrc EQ 0
    CLEAR lwa_batch.
  ENDLOOP. " LOOP AT i_lvbmtv INTO lwa_lvbmtv

  PERFORM f_insert_style.

  "Display the orders w/o batch
  IF p_unso IS NOT INITIAL.
    DELETE i_batch WHERE charg IS NOT INITIAL.
  ENDIF. " IF p_unso IS NOT INITIAL

ENDFORM. " F_GET_SALES_ORDER_DETAILS
*&---------------------------------------------------------------------*
*&      Form  F_INITIALIZE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_initialize_alv .

  DATA: li_excl_tools TYPE ui_functions, " Function code
        li_fcat       TYPE lvc_t_fcat,
        lwa_layout    TYPE lvc_s_layo.  " ALV control: Layout structure

  IF o_container IS INITIAL.
    "Initialize the container
    CREATE OBJECT o_container
      EXPORTING
        container_name = 'CCTL_ATP_GRID'.
  ENDIF. " IF o_container IS INITIAL

  IF o_alv IS INITIAL.
    "Initialize the ALV grid
    CREATE OBJECT o_alv
      EXPORTING
        i_parent = o_container.

    FREE o_alv_event.

    CREATE OBJECT o_alv_event.
    SET HANDLER:
                 o_alv_event->handle_toolbar_set  FOR o_alv,
                 o_alv_event->handle_user_command FOR o_alv,
                 o_alv_event->handle_button_click FOR o_alv,
                 o_alv_event->handle_data_changed FOR o_alv.

*  SOC by DDWIVEDI CR#231.

    CALL METHOD o_alv->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter
      EXCEPTIONS
        error      = 1
        OTHERS     = 2.
*   EOC by DDWIVEDI CR# 231.

    PERFORM f_build_field_catalog CHANGING li_fcat.

    APPEND:
            cl_gui_alv_grid=>mc_fc_info              TO li_excl_tools,
            cl_gui_alv_grid=>mc_fc_help              TO li_excl_tools,
            cl_gui_alv_grid=>mc_mb_view              TO li_excl_tools,
            cl_gui_alv_grid=>mc_fc_graph             TO li_excl_tools,
            cl_gui_alv_grid=>mc_mb_variant           TO li_excl_tools,
            cl_gui_alv_grid=>mc_fc_loc_cut           TO li_excl_tools,
            cl_gui_alv_grid=>mc_fc_loc_copy          TO li_excl_tools,
            cl_gui_alv_grid=>mc_fc_loc_paste         TO li_excl_tools,
            cl_gui_alv_grid=>mc_fc_loc_copy_row      TO li_excl_tools,
            cl_gui_alv_grid=>mc_fc_loc_move_row      TO li_excl_tools,
            cl_gui_alv_grid=>mc_fc_loc_delete_row    TO li_excl_tools,
            cl_gui_alv_grid=>mc_fc_loc_insert_row    TO li_excl_tools,
            cl_gui_alv_grid=>mc_fc_loc_append_row    TO li_excl_tools,
            cl_gui_alv_grid=>mc_fc_loc_paste_new_row TO li_excl_tools,
            cl_gui_alv_grid=>mc_fc_sort              TO li_excl_tools,
            cl_gui_alv_grid=>mc_fc_sort_asc          TO li_excl_tools,
            cl_gui_alv_grid=>mc_fc_sort_dsc          TO li_excl_tools.

    lwa_layout-edit       = c_true.
    lwa_layout-stylefname = c_field_style.
    lwa_layout-ctab_fname = c_color_cell.
    lwa_layout-info_fname = c_color_row.
    lwa_layout-zebra      = 'X'.
    lwa_layout-sel_mode   = 'A'.

    "Set up grid for first display
    CALL METHOD o_alv->set_table_for_first_display
      EXPORTING
        is_layout            = lwa_layout
        it_toolbar_excluding = li_excl_tools
      CHANGING
        it_fieldcatalog      = li_fcat
        it_outtab            = i_batch.

  ELSE. " ELSE -> IF o_alv IS INITIAL
    "Refresh Field Catalog
    PERFORM f_build_field_catalog CHANGING li_fcat.

    "Refresh ALV grid display
    CALL METHOD o_alv->refresh_table_display.
  ENDIF. " IF o_alv IS INITIAL

ENDFORM. " F_INITIALIZE_ALV
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_FCAT  text
*----------------------------------------------------------------------*
FORM f_build_field_catalog  CHANGING   ct_fcat TYPE lvc_t_fcat.
  DATA lwa_fcat TYPE lvc_s_fcat. " ALV control: Field catalog

  lwa_fcat-fieldname = 'VBELN'.
  lwa_fcat-col_pos   = 0.
  lwa_fcat-outputlen = 10.
  lwa_fcat-coltext   = 'Sales Document'(t01).
  APPEND lwa_fcat TO ct_fcat.
  CLEAR  lwa_fcat.

  lwa_fcat-fieldname = 'POSNR'.
  lwa_fcat-col_pos   = 1.
  lwa_fcat-outputlen = 4.
  lwa_fcat-coltext   = 'Item'(t02).
  APPEND lwa_fcat TO ct_fcat.
  CLEAR  lwa_fcat.

  lwa_fcat-fieldname = 'MATNR'.
  lwa_fcat-col_pos   = 2.
  lwa_fcat-outputlen = 15.
  lwa_fcat-coltext   = 'Material'(t03).
  APPEND lwa_fcat TO ct_fcat.
  CLEAR  lwa_fcat.

  lwa_fcat-fieldname = 'KWMENG'.
  lwa_fcat-col_pos   = 3.
  lwa_fcat-outputlen = 10.
  lwa_fcat-coltext   = 'Requested Quantity'(t04).
  lwa_fcat-decimals_o = 0. "Defect#5957
  APPEND lwa_fcat TO ct_fcat.
  CLEAR  lwa_fcat.

  lwa_fcat-fieldname = 'OMENG'.
  lwa_fcat-col_pos   = 4.
  lwa_fcat-outputlen = 10.
  lwa_fcat-coltext   = 'Open Quantity'(t05).
  lwa_fcat-decimals_o = 0. "Defect#5957
  APPEND lwa_fcat TO ct_fcat.
  CLEAR  lwa_fcat.

  lwa_fcat-fieldname = 'BMENG'.
  lwa_fcat-col_pos   = 5.
  lwa_fcat-outputlen = 10.
  lwa_fcat-coltext   = 'Confirmed Quantity'(t06).
  lwa_fcat-decimals_o = 0. "Defect#5957
  APPEND lwa_fcat TO ct_fcat.
  CLEAR  lwa_fcat.

  lwa_fcat-fieldname = 'KUNNR'.
  lwa_fcat-col_pos   = 6.
  lwa_fcat-outputlen = 10.
  lwa_fcat-coltext   = 'Customer'(t07).
  APPEND lwa_fcat TO ct_fcat.
  CLEAR  lwa_fcat.

  lwa_fcat-fieldname = 'NAME1'.
  lwa_fcat-col_pos   = 7.
  lwa_fcat-outputlen = 20.
  lwa_fcat-coltext   = 'Customer Description'(t08).
  APPEND lwa_fcat TO ct_fcat.
  CLEAR  lwa_fcat.

  lwa_fcat-fieldname = 'VKORG'.
  lwa_fcat-col_pos   = 8.
  lwa_fcat-outputlen = 4.
  lwa_fcat-coltext   = 'Sales Organization'(t09).
  APPEND lwa_fcat TO ct_fcat.
  CLEAR  lwa_fcat.

  lwa_fcat-fieldname = 'VTWEG'.
  lwa_fcat-col_pos   = 9.
  lwa_fcat-outputlen = 4.
  lwa_fcat-coltext   = 'Distribution Channel'(t10).
  APPEND lwa_fcat TO ct_fcat.
  CLEAR  lwa_fcat.

  lwa_fcat-fieldname = 'WERKS'.
  lwa_fcat-col_pos   = 10.
  lwa_fcat-outputlen = 4.
  lwa_fcat-coltext   = 'Plant'(t11).
  APPEND lwa_fcat TO ct_fcat.
  CLEAR  lwa_fcat.

  lwa_fcat-fieldname = 'EDATU'.
  lwa_fcat-col_pos   = 11.
  lwa_fcat-outputlen = 10.
  lwa_fcat-coltext   = 'Req. Delivery Date'(t12).
  APPEND lwa_fcat TO ct_fcat.
  CLEAR  lwa_fcat.

  lwa_fcat-fieldname = 'CHARG'.
  lwa_fcat-col_pos   = 12.
  lwa_fcat-outputlen = 10.
  lwa_fcat-coltext   = 'Batch'(t13).
  APPEND lwa_fcat TO ct_fcat.
  CLEAR  lwa_fcat.

  lwa_fcat-fieldname = 'LIFSK'.
  lwa_fcat-col_pos   = 13.
  lwa_fcat-outputlen = 9.
  lwa_fcat-coltext   = 'Delivery Block'(t14).
  APPEND lwa_fcat TO ct_fcat.
  CLEAR  lwa_fcat.

  lwa_fcat-fieldname = 'VTEXT'.
  lwa_fcat-col_pos   = 14.
  lwa_fcat-outputlen = 11.
  lwa_fcat-coltext   = 'Delivery Block Description'(t15).
  APPEND lwa_fcat TO ct_fcat.
  CLEAR  lwa_fcat.

  lwa_fcat-fieldname = 'ANTIGENS'.
  lwa_fcat-col_pos   = 14.
  lwa_fcat-outputlen = 10.
  lwa_fcat-coltext   = 'Antigens'(t16).
  APPEND lwa_fcat TO ct_fcat.
  CLEAR  lwa_fcat.

  lwa_fcat-fieldname = 'CORRES'.
  lwa_fcat-col_pos   = 15.
  lwa_fcat-outputlen = 10.
  lwa_fcat-coltext   = 'Corresponding'(t17).
  APPEND lwa_fcat TO ct_fcat.
  CLEAR  lwa_fcat.

ENDFORM. " F_BUILD_FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_display_report .
  CALL SCREEN 501.
ENDFORM. " F_DISPLAY_REPORT
*&---------------------------------------------------------------------*
*&      Form  F_LOCK_ORDERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_lock_orders .

  DATA:
    lv_index  TYPE sy-tabix, " Index of Internal Tables
    lwa_final TYPE ty_final,
    lwa_batch TYPE ty_batch_final.

  LOOP AT i_batch INTO lwa_batch.
    lv_index  = sy-tabix.
    CALL FUNCTION 'ENQUEUE_EVVBAKE'
      EXPORTING
        vbeln          = lwa_batch-vbeln
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc NE 0.
*       sales order could not be locked
      MESSAGE e000 WITH 'Sales Order could not be locked'(022) INTO lwa_final-message.
      MOVE 'E'      TO lwa_final-status.
      MOVE lwa_batch-vbeln TO lwa_final-vbeln.
      MOVE lwa_batch-posnr TO lwa_final-posnr.
      APPEND lwa_final TO i_log_f.
      DELETE i_batch INDEX lv_index.
    ENDIF. " IF sy-subrc NE 0
  ENDLOOP. " LOOP AT i_batch INTO lwa_batch

ENDFORM. " F_LOCK_ORDERS
*&---------------------------------------------------------------------*
*&      Form  F_SEQUENCE_BATCHES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_sequence_batches .

  CONSTANTS:
    lc_antigens   TYPE string VALUE 'ANTIGENS',
    lc_corres     TYPE string VALUE 'CORRESPONDING',
    lc_noncorres  TYPE string VALUE 'NON CORRESPONDING',
    lc_ordtyp_std TYPE string VALUE 'ZSTD',
    lc_ordtyp_or  TYPE string VALUE 'ZOR',
    lc_ordtyp_int TYPE string VALUE 'ZINT',
    lc_prior_1a   TYPE string VALUE 'A',
    lc_prior_1b   TYPE string VALUE 'B',
    lc_prior_1c   TYPE string VALUE 'C',
    lc_prior_2a   TYPE string VALUE 'D',
    lc_prior_2b   TYPE string VALUE 'E',
    lc_prior_2c   TYPE string VALUE 'F',
    lc_prior_3a   TYPE string VALUE 'G',
    lc_prior_3b   TYPE string VALUE 'H',
    lc_prior_3c   TYPE string VALUE 'I',
    lc_prior_4a   TYPE string VALUE 'J',
    lc_prior_4b   TYPE string VALUE 'K',
    lc_prior_4c   TYPE string VALUE 'L',
    lc_prior_5a   TYPE string VALUE 'M',
    lc_prior_5b   TYPE string VALUE 'N',
    lc_prior_5c   TYPE string VALUE 'O',
    lc_prior_5d   TYPE string VALUE 'P'.

  FIELD-SYMBOLS:
    <lfs_batch> TYPE ty_batch_final.

  SORT i_batch BY auart.

  LOOP AT i_batch ASSIGNING <lfs_batch>.
    CASE <lfs_batch>-auart.
      WHEN lc_ordtyp_std.
        IF <lfs_batch>-corres = lc_corres.
          <lfs_batch>-prior = lc_prior_1a.
        ELSEIF <lfs_batch>-corres = lc_noncorres.
          <lfs_batch>-prior = lc_prior_1b.
        ELSEIF <lfs_batch>-antigens NE space.
          <lfs_batch>-prior = lc_prior_1c.
        ELSEIF <lfs_batch>-antigens EQ space AND
               <lfs_batch>-corres   EQ space.
          <lfs_batch>-prior = lc_prior_5a.
        ENDIF. " IF <lfs_batch>-corres = lc_corres
      WHEN lc_ordtyp_or.
        IF <lfs_batch>-corres = lc_corres.
          <lfs_batch>-prior = lc_prior_2a.
        ELSEIF <lfs_batch>-corres = lc_noncorres.
          <lfs_batch>-prior = lc_prior_2b.
        ELSEIF <lfs_batch>-antigens NE space.
          <lfs_batch>-prior = lc_prior_2c.
        ELSEIF <lfs_batch>-antigens EQ space AND
               <lfs_batch>-corres   EQ space.
          <lfs_batch>-prior = lc_prior_5b.
        ENDIF. " IF <lfs_batch>-corres = lc_corres
      WHEN lc_ordtyp_int.
        IF <lfs_batch>-corres = lc_corres.
          <lfs_batch>-prior = lc_prior_3a.
        ELSEIF <lfs_batch>-corres = lc_noncorres.
          <lfs_batch>-prior = lc_prior_3b.
        ELSEIF <lfs_batch>-antigens NE space.
          <lfs_batch>-prior = lc_prior_3c.
        ELSEIF <lfs_batch>-antigens EQ space AND
               <lfs_batch>-corres   EQ space.
          <lfs_batch>-prior = lc_prior_5c.
        ENDIF. " IF <lfs_batch>-corres = lc_corres
      WHEN OTHERS.
        IF <lfs_batch>-corres = lc_corres.
          <lfs_batch>-prior = lc_prior_4a.
        ELSEIF <lfs_batch>-corres = lc_noncorres.
          <lfs_batch>-prior = lc_prior_4b.
        ELSEIF <lfs_batch>-antigens NE space.
          <lfs_batch>-prior = lc_prior_4c.
        ELSEIF <lfs_batch>-antigens EQ space AND
               <lfs_batch>-corres   EQ space.
          <lfs_batch>-prior = lc_prior_5d.
        ENDIF. " IF <lfs_batch>-corres = lc_corres
    ENDCASE.
  ENDLOOP. " LOOP AT i_batch ASSIGNING <lfs_batch>

  SORT i_batch BY prior ASCENDING.

ENDFORM. " F_SEQUENCE_BATCHES
*&---------------------------------------------------------------------*
*&      Form  F_DETERMINE_BATCHES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_determine_batches .

  DATA:
    lwa_komkh    TYPE komkh,            " Batch Determination Communication Block Header
    lwa_komph    TYPE komph,            " Batch Determination: Communication Record for Item
    lwa_bdcom    TYPE bdcom,            " Batch Determination Communication Structure
    lwa_final    TYPE ty_final,
    li_t459a     TYPE TABLE OF t459a,   " External requirements types
    lwa_t459a    TYPE t459a,            " External requirements types
    lwa_vbep     TYPE ty_vbep,
    lwa_bdbatch  TYPE bdbatch,          " Results Table for Batch Determination
    li_kna1      TYPE TABLE OF ty_kna1,
    li_vbap      TYPE TABLE OF ty_vbap,
    li_bdbatch   TYPE TABLE OF bdbatch, " Results Table for Batch Determination
    li_bdbatch_f TYPE TABLE OF bdbatch. " Results Table for Batch Determination

  FIELD-SYMBOLS:
    <lfs_kna1>  TYPE ty_kna1,
    <lfs_vbap>  TYPE ty_vbap,
    <lfs_vbep>  TYPE ty_vbep,
    <lfs_batch> TYPE ty_batch_final.

  CONSTANTS:
     lc_etenr TYPE etenr VALUE '0001'. " Delivery Schedule Line Number

  IF i_batch_a IS NOT INITIAL.
    SELECT vbeln posnr mtvfp
           mvgr2 bedae FROM vbap " Sales Document: Item Data
                       INTO TABLE i_vbap
                       FOR ALL ENTRIES IN i_batch_a
                       WHERE vbeln = i_batch_a-vbeln AND
                             posnr = i_batch_a-posnr.
    SORT i_vbap BY vbeln posnr.

    IF li_vbap IS NOT INITIAL.
      SELECT * FROM t459a " External requirements types
               INTO TABLE i_t459a
               FOR ALL ENTRIES IN i_vbap
               WHERE bedae EQ i_vbap-bedae.
    ENDIF. " IF li_vbap IS NOT INITIAL

    SELECT kunnr land1
           ort01 pstlz FROM kna1 " General Data in Customer Master
                       INTO TABLE i_kna1
                       FOR ALL ENTRIES IN i_batch_a
                       WHERE kunnr = i_batch_a-kunnr.
    SORT i_kna1 BY kunnr.

  ENDIF. " IF i_batch_a IS NOT INITIAL

  PERFORM f_determine_corres_batch.

  REFRESH: i_batch_d.
  i_batch_d = i_batch_a.
  LOOP AT i_batch_a ASSIGNING <lfs_batch>.
*                    where bmeng ne 0.
    DELETE i_batch_d WHERE vbeln = <lfs_batch>-vbeln AND
                           posnr = <lfs_batch>-posnr.
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

    READ TABLE i_vbap ASSIGNING <lfs_vbap>
                       WITH KEY vbeln = <lfs_batch>-vbeln
                                posnr = <lfs_batch>-posnr
                       BINARY SEARCH.
    IF sy-subrc EQ 0.
      lwa_komph-mvgr2 = <lfs_vbap>-mvgr2.
      lwa_bdcom-mtvfp = <lfs_vbap>-mtvfp.

      READ TABLE i_t459a INTO lwa_t459a WITH KEY bedae = <lfs_vbap>-bedae.
      IF sy-subrc EQ 0.
        lwa_bdcom-bedar = lwa_t459a-bedar.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0

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

    READ TABLE  i_vbep ASSIGNING <lfs_vbep>
                       WITH KEY vbeln = <lfs_batch>-vbeln
                                posnr = <lfs_batch>-posnr
                       BINARY SEARCH.
    IF sy-subrc EQ 0.
      lwa_bdcom-mbuhr = <lfs_vbep>-mbuhr.
    ENDIF. " IF sy-subrc EQ 0

    lwa_bdcom-nodia = 'X'.

    READ TABLE i_kna1 ASSIGNING <lfs_kna1>
                       WITH KEY kunnr = <lfs_batch>-kunnr
                       BINARY SEARCH.
    IF sy-subrc EQ 0.
      lwa_bdcom-ort01 = <lfs_kna1>-ort01.
      lwa_bdcom-land1 = <lfs_kna1>-land1.
      lwa_bdcom-pstlz = <lfs_kna1>-pstlz.
    ENDIF. " IF sy-subrc EQ 0

    CLEAR li_bdbatch.
    REFRESH: li_bdbatch.
    CALL FUNCTION 'VB_BATCH_DETERMINATION'
      EXPORTING
        i_komkh   = lwa_komkh
        i_komph   = lwa_komph
        x_bdcom   = lwa_bdcom
      TABLES
        e_bdbatch = li_bdbatch
      EXCEPTIONS
        no_plant  = 7
        OTHERS    = 99.
    IF sy-subrc <> 0 OR
       li_bdbatch IS INITIAL.
      MESSAGE e000 WITH 'No batch determined'(021) INTO lwa_final-message.
      MOVE 'E'      TO lwa_final-status.
      MOVE <lfs_batch>-vbeln TO lwa_final-vbeln.
      MOVE <lfs_batch>-posnr TO lwa_final-posnr.
      APPEND lwa_final TO i_log_f.
    ELSE. " ELSE -> IF sy-subrc <> 0 OR
      READ TABLE li_bdbatch INTO lwa_bdbatch INDEX 1.
      READ TABLE i_vbep INTO lwa_vbep WITH KEY vbeln = <lfs_batch>-vbeln
                                               posnr = <lfs_batch>-posnr.
      IF sy-subrc EQ 0.
        IF lwa_vbep-wmeng GT lwa_bdbatch-vrfmg.
          "Log
          MOVE <lfs_batch>-vbeln TO lwa_final-vbeln.
          MOVE <lfs_batch>-posnr TO lwa_final-posnr.
          lwa_final-status = 'E'.
          lwa_final-message = 'Ordered Quantity exceeds available quantity'.
          APPEND lwa_final TO i_log_f.

          REFRESH: li_bdbatch.
        ELSE. " ELSE -> IF lwa_vbep-wmeng GT lwa_bdbatch-vrfmg
          APPEND LINES OF li_bdbatch TO i_bdbatch_f.
          ASSIGN <lfs_batch> TO <fs_batch>.
          IF li_bdbatch IS NOT INITIAL.
*&-->Begin of changes for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018
*&--Transferring the records in another internal table
*            i_bdbatch[] = li_bdbatch[].
*&<--End of changes for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018
            PERFORM f_assign_batches.
          ENDIF. " IF li_bdbatch IS NOT INITIAL
        ENDIF. " IF lwa_vbep-wmeng GT lwa_bdbatch-vrfmg
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc <> 0 OR

    CLEAR : lwa_komkh,
            lwa_komph,
            lwa_bdcom.

    REFRESH: li_bdbatch,
             i_bdbatch_f.
  ENDLOOP. " LOOP AT i_batch_a ASSIGNING <lfs_batch>
ENDFORM. " F_DETERMINE_BATCHES
*&---------------------------------------------------------------------*
*&      Form  F_ASSIGN_BATCHES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_assign_batches .

  DATA:
    li_return            TYPE TABLE OF bapiret2,    " Return Parameter
    lwa_return           TYPE bapiret2,             " Return Parameter
    li_return_c          TYPE bapiret2,             " Return Parameter
    li_schedule_lines    TYPE TABLE OF bapischdl,   " Communication Fields for Maintaining SD Doc. Schedule Lines
    li_schedule_linesx   TYPE TABLE OF bapischdlx,  " Checkbox List for Maintaining Sales Document Schedule Line
    li_order_item_in     TYPE TABLE OF bapisditm,   " Communication Fields: Sales and Distribution Document Item
    li_order_item_inx    TYPE TABLE OF  bapisditmx, " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_in    TYPE bapisditm,            " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_inx   TYPE bapisditmx,           " Communication Fields: Sales and Distribution Document Item
    lwa_order_header_in  TYPE bapisdh1,             " Communication Fields: SD Order Header
    lwa_order_header_inx TYPE bapisdh1x,            " Checkbox List: SD Order Header
    lwa_bdbatch_f        TYPE bdbatch,              " Results Table for Batch Determination
    lwa_schedule_lines   TYPE bapischdl,            " Communication Fields for Maintaining SD Doc. Schedule Lines
    lwa_schedule_linesx  TYPE bapischdlx,           " Checkbox List for Maintaining Sales Document Schedule Line
    lv_logtext           TYPE string,
    lv_joblog            TYPE string,
    lwa_log              TYPE ty_final.

  FIELD-SYMBOLS:
    <lfs_batch>  TYPE ty_batch_final,
    <lfs_return> TYPE bapiret2. " Return Parameter

  CONSTANTS:
    lc_error             TYPE char1 VALUE 'E'. " Error of type CHAR1

  lwa_order_header_inx-updateflag = 'U'.
  lwa_order_item_in-itm_number = <fs_batch>-posnr.
  READ TABLE i_bdbatch_f INTO lwa_bdbatch_f INDEX 1.
  IF sy-subrc EQ 0.
    lwa_order_item_in-material = lwa_bdbatch_f-matnr.
    lwa_order_item_in-batch = lwa_bdbatch_f-charg.
    lwa_schedule_lines-req_qty = lwa_bdbatch_f-menge.
  ENDIF. " IF sy-subrc EQ 0
  APPEND lwa_order_item_in TO li_order_item_in.

  lwa_order_item_inx-itm_number = <fs_batch>-posnr.
  lwa_order_item_inx-updateflag = 'U'.
  lwa_order_item_inx-batch = 'X'.
  APPEND lwa_order_item_inx TO li_order_item_inx.

  CHECK <fs_batch> IS ASSIGNED.

  CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
    EXPORTING
      salesdocument    = <fs_batch>-vbeln
      order_header_inx = lwa_order_header_inx
    TABLES
      return           = li_return
      order_item_in    = li_order_item_in
      order_item_inx   = li_order_item_inx.

  READ TABLE li_return ASSIGNING <lfs_return>
                       WITH KEY type = lc_error. " Return assigning of type
  IF sy-subrc NE 0.

    READ TABLE i_batch_d TRANSPORTING NO FIELDS WITH KEY vbeln = <fs_batch>-vbeln.
    IF sy-subrc NE 0.
      PERFORM f_unlock_orders USING <fs_batch>. "Defect 6508
    ENDIF. " IF sy-subrc NE 0
    <fs_batch>-charg = lwa_bdbatch_f-charg.
    lwa_log-vbeln   = <fs_batch>-vbeln.
    lwa_log-posnr   = <fs_batch>-posnr.
    lwa_log-status  = 'S'.
    lwa_log-message = 'Sales Order successfully saved'.
    APPEND lwa_log TO i_log_f.

    CLEAR: li_return_c.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = 'X'
      IMPORTING
        return = li_return_c.

    APPEND li_return_c TO i_log.

    CLEAR: lwa_order_header_inx.
    REFRESH: li_return,
             li_order_item_in,
             li_order_item_inx,
             li_schedule_lines,
             li_schedule_linesx.
  ELSE. " ELSE -> IF sy-subrc NE 0
    IF sy-batch IS INITIAL.
      <fs_batch>-charg = lwa_bdbatch_f-charg.
      lwa_log-vbeln   = <fs_batch>-vbeln.
      lwa_log-posnr   = <fs_batch>-posnr.
      lwa_log-status  = 'E'.
      lwa_log-message = <lfs_return>-message.
      APPEND lwa_log TO i_log_f.
    ELSE. " ELSE -> IF sy-batch IS INITIAL
      CONCATENATE <fs_batch>-vbeln '/' <fs_batch>-posnr 'E' '/' <lfs_return>-message
            INTO lv_joblog.
      WRITE lv_joblog.
    ENDIF. " IF sy-batch IS INITIAL

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
      IMPORTING
        return = lwa_return.

    IF lwa_return IS NOT INITIAL.
      IF sy-batch IS INITIAL.
        <fs_batch>-charg = lwa_bdbatch_f-charg.

        lwa_log-vbeln   = <fs_batch>-vbeln.
        lwa_log-posnr   = <fs_batch>-posnr.
        lwa_log-status  = 'E'.
        lwa_log-message = 'Changes are NOT saved'.
        APPEND lwa_log TO i_log_f.

      ELSE. " ELSE -> IF sy-batch IS INITIAL
        lwa_log-message = 'Changes are NOT saved'.
        CONCATENATE <fs_batch>-vbeln '/' <fs_batch>-posnr 'E' '/' lwa_log-message
              INTO lv_joblog.
        WRITE lv_joblog.
      ENDIF. " IF sy-batch IS INITIAL
    ENDIF. " IF lwa_return IS NOT INITIAL
  ENDIF. " IF sy-subrc NE 0
*  endif.
ENDFORM. " F_ASSIGN_BATCHES
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_display_log .

  DATA:
    lref_chlog      TYPE REF TO cl_salv_table, " Basis Class for Simple Tables
    lv_start_column TYPE  i,                   " Start_column of type Integers
    lv_start_line   TYPE  i,                   " Start_line of type Integers
    lv_end_column   TYPE  i,                   " End_column of type Integers
    lv_end_line     TYPE  i,                   " End_line of type Integers
    lv_msg          TYPE  string,
    lv_popup        TYPE  string VALUE 'X',
    lv_ex_msg       TYPE REF TO cx_salv_msg.   "Message

  DATA:
    lr_functions TYPE REF TO cl_salv_functions_list, " Generic and User-Defined Functions in List-Type Tables
    lr_columns   TYPE REF TO cl_salv_columns_table,  " Columns in Simple, Two-Dimensional Tables
    lr_column    TYPE REF TO cl_salv_column_table.   " Column Description of Simple, Two-Dimensional Tables

  DATA:
    li_salv_not_found TYPE REF TO   cx_salv_not_found. " ALV: General Error Class (Checked During Syntax Check)

  CONSTANTS:
    lc_error  TYPE symsgty VALUE 'E',                   " Message Type
    lc_status TYPE sypfkey VALUE 'ZOTC_EDD0398_TABSTD'. " Current GUI Status


  IF i_log_f IS NOT INITIAL.
    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = lref_chlog
          CHANGING
            t_table      = i_log_f[] ).

      CATCH cx_salv_msg INTO lv_ex_msg.
        MESSAGE lv_ex_msg TYPE 'E'.

    ENDTRY.

    lref_chlog->set_screen_status( pfstatus      = lc_status
                                   report        = sy-repid
                                   set_functions = lref_chlog->c_functions_all ).
    lr_functions = lref_chlog->get_functions( ).
    lr_functions->set_all( abap_true ).

    TRY.
        lr_columns = lref_chlog->get_columns( ).
      CATCH cx_salv_not_found.
    ENDTRY.

    TRY.
        lr_column ?= lr_columns->get_column( 'VBELN' ).
      CATCH cx_salv_not_found.
        lr_column->set_visible( abap_false ).
    ENDTRY.

    lv_start_column = 20.
    lv_start_line   = 50.
    lv_end_column   = 170.
    lv_end_line     = 100.

    IF lref_chlog IS BOUND.
      IF lv_popup = 'X'.
        lref_chlog->set_screen_popup(
          start_column = lv_start_column
          end_column   = lv_end_column
          start_line   = lv_start_line
          end_line     = lv_end_line ).
      ENDIF. " IF lv_popup = 'X'

      lref_chlog->display( ).

    ENDIF. " IF lref_chlog IS BOUND
  ENDIF. " IF i_log_f IS NOT INITIAL
ENDFORM. " F_DISPLAY_LOG
*&---------------------------------------------------------------------*
*&      Form  F_INSERT_STYLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_insert_style .

  DATA:
    lx_stylerow          TYPE lvc_s_styl,          " ALV Control: Field Name + Styles
    lwa_color_cell_batch TYPE lvc_s_scol. " ALV control: Structure for cell coloring

  FIELD-SYMBOLS:
    <lfs_batch>      TYPE ty_batch_final,
    <lfs_color_cell> TYPE lvc_s_scol. " ALV control: Structure for cell coloring

  LOOP AT i_batch ASSIGNING <lfs_batch>.
    lx_stylerow-fieldname = 'VBELN'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    INSERT lx_stylerow INTO TABLE <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'POSNR'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    INSERT lx_stylerow INTO TABLE <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'MATNR'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    INSERT lx_stylerow INTO TABLE <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'KWMENG'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    INSERT lx_stylerow INTO TABLE <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'OMENG'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    INSERT lx_stylerow INTO TABLE <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'BMENG'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    INSERT lx_stylerow INTO TABLE <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'KUNNR'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    INSERT lx_stylerow INTO TABLE <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'NAME1'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    INSERT lx_stylerow INTO TABLE <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'VKORG'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    INSERT lx_stylerow INTO TABLE <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'VTWEG'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    INSERT lx_stylerow INTO TABLE <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'WERKS'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    INSERT lx_stylerow INTO TABLE <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'EDATU'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    INSERT lx_stylerow INTO TABLE <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'CHARG'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    INSERT lx_stylerow INTO TABLE <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'LIFSK'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    INSERT lx_stylerow INTO TABLE <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'VTEXT'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    INSERT lx_stylerow INTO TABLE <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'ANTIGENS'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    INSERT lx_stylerow INTO TABLE <lfs_batch>-field_style.

    lx_stylerow-fieldname = 'CORRES'.
    lx_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
    INSERT lx_stylerow INTO TABLE <lfs_batch>-field_style.
  ENDLOOP. " LOOP AT i_batch ASSIGNING <lfs_batch>

ENDFORM. " F_INSERT_STYLE
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_PLANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_plant .
  DATA: lv_plant TYPE werks_d. " Plant

  CONSTANTS: lc_ast TYPE char1 VALUE '*'. " Constant for '*'

  IF NOT s_werks CP lc_ast AND
         s_werks IS NOT INITIAL.
    SELECT werks " Plant
      FROM t001w " Plants/Branches
     UP TO 1 ROWS
      INTO lv_plant
     WHERE werks IN s_werks.
    ENDSELECT.
    IF sy-subrc EQ 0.
      CLEAR lv_plant.
    ELSE. " ELSE -> IF sy-subrc EQ 0
      MESSAGE e128 WITH lv_plant. " Invalid Plant
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF NOT s_werks CP lc_ast AND
ENDFORM. " F_VALIDATE_PLANT
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_MATNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_matnr .
  DATA lv_matnr TYPE matnr. " Material No.
  CONSTANTS: lc_ast TYPE char1 VALUE '*'. " Constant for '*'

  IF NOT s_matnr CP lc_ast.
    SELECT matnr " Material Number
      FROM mara  " General Material Data
     UP TO 1 ROWS
      INTO lv_matnr
     WHERE matnr IN s_matnr.
    ENDSELECT.
    IF sy-subrc EQ 0.
      CLEAR lv_matnr.
    ELSE. " ELSE -> IF sy-subrc EQ 0
      MESSAGE e128 WITH lv_matnr. " Invalid Material Number
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF NOT s_matnr CP lc_ast
ENDFORM. " F_VALIDATE_MATNR
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DOCNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_docno .

  DATA:  lv_docno TYPE vbeln. " Document Number

  IF s_docno[] IS NOT INITIAL.
    SELECT vbeln " Sales Document
      FROM vbak  " Sales Document: Header Data
     UP TO 1 ROWS
      INTO lv_docno
     WHERE vbeln IN s_docno[].
    ENDSELECT.
    IF sy-subrc EQ 0.
      CLEAR lv_docno.
    ELSE. " ELSE -> IF sy-subrc EQ 0
      MESSAGE e980. " Invalid Sales Order Number
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF s_docno[] IS NOT INITIAL
ENDFORM. " F_VALIDATE_DOCNO
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_batch .

  DATA lv_batch TYPE charg_d. " Batch Number
  CONSTANTS: lc_ast TYPE char1 VALUE '*'. " Constant for '*'

  IF NOT s_charg CP lc_ast.
    SELECT charg " Batch Number
      FROM mch1  " Batches (if Batch Management Cross-Plant)
     UP TO 1 ROWS
      INTO lv_batch
     WHERE charg IN s_charg.
    ENDSELECT.

    IF sy-subrc = 0.
      CLEAR lv_batch.
    ELSE. " ELSE -> IF sy-subrc = 0
      MESSAGE e273. "  Batch is Invalid
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF NOT s_charg CP lc_ast
ENDFORM. " F_VALIDATE_BATCH
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_VKORG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_vkorg .
  DATA: lv_vkorg TYPE vkorg. "local variable for Sales Organization

  SELECT vkorg     "Customer Sales Organization
         FROM tvko " Organizational Unit: Sales Organizations
         UP TO 1 ROWS
         INTO   lv_vkorg
         WHERE  vkorg IN s_vkorg.
  ENDSELECT.
  IF sy-subrc IS NOT INITIAL AND lv_vkorg IS INITIAL.
    MESSAGE e984.
  ENDIF. " IF sy-subrc IS NOT INITIAL AND lv_vkorg IS INITIAL

**//-->>Begin of changes - Defect # 5957
  IF s_vkorg IS NOT INITIAL.
    SELECT vkorg      "Customer Sales Organization
           FROM tvkwz " Org.Unit: Allowed Plants per Sales Organization
           UP TO 1 ROWS
           INTO   lv_vkorg
           WHERE  vkorg IN s_vkorg AND
                  werks IN s_werks.
    ENDSELECT.
    IF sy-subrc IS NOT INITIAL AND lv_vkorg IS INITIAL.
      MESSAGE e984.
    ENDIF. " IF sy-subrc IS NOT INITIAL AND lv_vkorg IS INITIAL
  ENDIF. " IF s_vkorg IS NOT INITIAL
**//-->>End of changes - Defect # 5957
ENDFORM. " F_VALIDATE_VKORG
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_KUNNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_kunnr .
  DATA: lv_kunnr TYPE kunnr. "local variable for Customer Number

  IF s_soldto IS NOT INITIAL.
    SELECT kunnr " Customer Number
      UP TO 1 ROWS
      INTO lv_kunnr
      FROM kna1  " General Data in Customer Master
      WHERE kunnr IN s_soldto.
    ENDSELECT.
    IF sy-subrc IS NOT INITIAL AND lv_kunnr IS INITIAL.
      MESSAGE e945.
    ENDIF. " IF sy-subrc IS NOT INITIAL AND lv_kunnr IS INITIAL
  ENDIF. " IF s_soldto IS NOT INITIAL
ENDFORM. " F_VALIDATE_KUNNR
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DOC_TYP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_doc_typ .

* Local data declaration
  DATA: lv_auart TYPE auart. "Sales Document Type.

  IF s_ordty[] IS NOT INITIAL.
* Select and validate the value for field plant against selection
*screen
    SELECT auart UP TO 1 ROWS "Sales Document Type
           FROM tvak          " Sales Document Types
           INTO lv_auart
           WHERE auart IN s_ordty[].
    ENDSELECT.

* Check sy-subrc after select
    IF sy-subrc NE 0.
* If sy-subrc is not equal to zero display error mesage
      MESSAGE e000 WITH 'Invalid document type'(002).
    ENDIF. " IF sy-subrc NE 0
  ENDIF. " IF s_ordty[] IS NOT INITIAL
ENDFORM. " F_VALIDATE_DOC_TYP
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_VTWEG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_vtweg .

  DATA: lv_vtweg TYPE vtweg. " Distribution Channel

  CONSTANTS: lc_ast TYPE char1 VALUE '*'. " Constant for '*'

  IF NOT s_vtweg CP lc_ast AND
         s_vtweg IS NOT INITIAL.

    SELECT vtweg UP TO 1 ROWS
        INTO lv_vtweg
        FROM tvtw " Organizational Unit: Distribution Channels
        WHERE vtweg IN s_vtweg.

    ENDSELECT.

    IF sy-subrc <> 0.
      MESSAGE e000 WITH 'Enter valid Distribution Channel'(e01).
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF NOT s_vtweg CP lc_ast AND
ENDFORM. " F_VALIDATE_VTWEG
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SELECTION_TAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_selection_tab .

  DATA:
    lv_lines    TYPE i,     " Lines of type Integers
    lwa_lseltab TYPE rkask. " Table of selection criteria

  IF s_soldto IS NOT INITIAL.
    lwa_lseltab-ktext = 'KUNNR'.
    DESCRIBE TABLE s_soldto LINES lv_lines.
    IF lv_lines GT 1.
      LOOP AT s_soldto.
        lwa_lseltab-vonsl = s_soldto-low.
        APPEND lwa_lseltab TO i_lseltab.
      ENDLOOP. " LOOP AT s_soldto
    ELSEIF lv_lines EQ 1.
      lwa_lseltab-vonsl = s_soldto-low.
      lwa_lseltab-bissl = s_soldto-high.
      APPEND lwa_lseltab TO i_lseltab.
    ENDIF. " IF lv_lines GT 1
  ENDIF. " IF s_soldto IS NOT INITIAL

  IF s_docno IS NOT INITIAL.
    lwa_lseltab-ktext = 'VBELN'.
    DESCRIBE TABLE s_docno LINES lv_lines.
    IF lv_lines GT 1.
      LOOP AT s_docno.
        lwa_lseltab-vonsl = s_docno-low.
        APPEND lwa_lseltab TO i_lseltab.
      ENDLOOP. " LOOP AT s_docno
    ELSEIF lv_lines EQ 1.
      lwa_lseltab-vonsl = s_docno-low.
      lwa_lseltab-bissl = s_docno-high.
      APPEND lwa_lseltab TO i_lseltab.
    ENDIF. " IF lv_lines GT 1
  ENDIF. " IF s_docno IS NOT INITIAL

  IF s_ordty IS NOT INITIAL.
    lwa_lseltab-ktext = 'AUART'.
    DESCRIBE TABLE s_ordty LINES lv_lines.
    IF lv_lines GT 1.
      LOOP AT s_ordty.
        lwa_lseltab-vonsl = s_ordty-low.
        APPEND lwa_lseltab TO i_lseltab.
      ENDLOOP. " LOOP AT s_ordty
    ELSEIF lv_lines EQ 1.
      lwa_lseltab-vonsl = s_ordty-low.
      lwa_lseltab-bissl = s_ordty-high.
      APPEND lwa_lseltab TO i_lseltab.
    ENDIF. " IF lv_lines GT 1
  ENDIF. " IF s_ordty IS NOT INITIAL

**//-->> Begin of changes - Defect# 5957
  IF s_vkorg IS NOT INITIAL.
    lwa_lseltab-ktext = 'VKORG'.
    DESCRIBE TABLE s_vkorg LINES lv_lines.
    IF lv_lines GT 1.
      LOOP AT s_vkorg.
        lwa_lseltab-vonsl = s_vkorg-low.
        APPEND lwa_lseltab TO i_lseltab.
      ENDLOOP. " LOOP AT s_vkorg
    ELSEIF lv_lines EQ 1.
      lwa_lseltab-vonsl = s_vkorg-low.
      lwa_lseltab-bissl = s_vkorg-high.
      APPEND lwa_lseltab TO i_lseltab.
    ENDIF. " IF lv_lines GT 1
  ENDIF. " IF s_vkorg IS NOT INITIAL

  IF s_vtweg IS NOT INITIAL.
    lwa_lseltab-ktext = 'VTWEG'.
    DESCRIBE TABLE s_vtweg LINES lv_lines.
    IF lv_lines GT 1.
      LOOP AT s_vtweg.
        lwa_lseltab-vonsl = s_vtweg-low.
        APPEND lwa_lseltab TO i_lseltab.
      ENDLOOP. " LOOP AT s_vtweg
    ELSEIF lv_lines EQ 1.
      lwa_lseltab-vonsl = s_vtweg-low.
      lwa_lseltab-bissl = s_vtweg-high.
      APPEND lwa_lseltab TO i_lseltab.
    ENDIF. " IF lv_lines GT 1
  ENDIF. " IF s_vtweg IS NOT INITIAL

**//-->> End of changes - Defect# 5957
ENDFORM. " F_BUILD_SELECTION_TAB
*&---------------------------------------------------------------------*
*&      Form  F_DETERMINE_CORRES_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_determine_corres_batch .

  TYPES: BEGIN OF lty_corr_batch.
  TYPES: vbeln         TYPE vbeln,       " Sales and Distribution Document Number
         posnn         TYPE posnr,       " Item number of the SD document
         vfdat         TYPE vfdat,       " Shelf Life Expiration or Best-Before Date
         ihd_batch     TYPE atwtb,       "for IHD_DISP_BAtch
         corr_batch    TYPE atwtb,       " Characteristic value description
         corresponding TYPE boole_d. " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
      INCLUDE STRUCTURE cdstock. " Results Table for Batch Determination / Stock Determination
  TYPES: END OF lty_corr_batch.

  DATA:
    lv_vbeln_comp       TYPE vbeln,                             " Sales and Distribution Document Number
    lv_vbeln_chng       TYPE vbeln,                             " Sales and Distribution Document Number
    lv_posnr_comp       TYPE posnr,                             " Item number of the SD document
    lv_posnr_chng       TYPE posnr,                             " Item number of the SD document
    lv_tab              TYPE sy-tabix,                          " Index of Internal Tables
    lv_no_cond_check    TYPE boole_d,                           " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
    lv_matnr_cbat       TYPE matnr,                             " Material Number
    lv_index            TYPE sy-index,                          " Loop Index
    lv_ord_qty          TYPE c,                                 " Ord_qty of type Character

    lwa_komkh           TYPE komkh,                             " Batch Determination Communication Block Header
    lwa_komph           TYPE komph,                             " Batch Determination: Communication Record for Item
    lwa_bdcom           TYPE bdcom,                             " Batch Determination Communication Structure
    lwa_enh_status      TYPE zdev_enh_status,                   " Enhancement Status
    lwa_enh_status_a    TYPE zdev_enh_status,                   " Enhancement Status
    lwa_final           TYPE ty_final,
    lwa_bdbatch         TYPE bdbatch,                           " Results Table for Batch Determination
    lwa_stock           TYPE cdstock,                           " Results Table for Batch Determination / Stock Determination
    lwa_t459a           TYPE t459a,                             " External requirements types
    lwa_vbep            TYPE ty_vbep,
    lwa_batch_det       TYPE clbatch,                           " Classification interface for batches
    lwa_stock_tmp       TYPE zptm_corres_batch,                 "cdstock,                           " Results Table for Batch Determination / Stock Determination
    lwa_corr_batch      TYPE zptm_corres_batch,                 "lty_corr_batch,
    lwa_corr_batch_comp TYPE zptm_corres_batch,                 "lty_corr_batch,
    lwa_corr_batch_chng TYPE zptm_corres_batch,                 "lty_corr_batch,

    li_t459a            TYPE TABLE OF t459a,                      " External requirements types
    li_kna1             TYPE TABLE OF ty_kna1,
    li_vbap             TYPE TABLE OF ty_vbap,
    li_bdbatch          TYPE TABLE OF bdbatch,                    " Results Table for Batch Determination
    li_bdbatch_f        TYPE TABLE OF bdbatch,                    " Results Table for Batch Determination
    li_corr_batch_comp  TYPE STANDARD TABLE OF zptm_corres_batch, "lty_corr_batch,
    li_corr_batch_chng  TYPE STANDARD TABLE OF zptm_corres_batch. "lty_corr_batch.

  CONSTANTS:
    lc_etenr      TYPE etenr         VALUE '0001',               " Delivery Schedule Line Number
    lc_matnr_comp TYPE z_criteria    VALUE 'MATNR_TO_COMP',      " Enh. Criteria
    lc_corr       TYPE z_criteria    VALUE 'CORRES_BATCH_MATNR', " Enh. Criteria
    lc_corres     TYPE string        VALUE 'CORRESPONDING',
    lc_lobm_vfdat TYPE atnam         VALUE 'LOBM_VFDAT',         " Characteristic Name
    lc_pap_bat    TYPE char12        VALUE 'CORR_PAP_BAT',       " Pap_bat of type CHAR12
    lc_disp_bat   TYPE atnam         VALUE 'ZM_DISP_BATCH'.      " Characteristic Name

  FIELD-SYMBOLS:
    <lfs_kna1>            TYPE ty_kna1,
    <lfs_vbap>            TYPE ty_vbap,
    <lfs_vbep>            TYPE ty_vbep,
    <lfs_bdbatch_c>       TYPE bdbatch,           " Results Table for Batch Determination
    <lfs_batch>           TYPE ty_batch_final,
    <lfs_batch_a>         TYPE ty_batch_final,
    <lfs_batch_b>         TYPE ty_batch_final,
    <lfs_batch_c>         TYPE ty_batch_final,
    <lfs_corr_batch_comp> TYPE zptm_corres_batch, " Corresponding Batch Information
    <lfs_corr_batch_chng> TYPE zptm_corres_batch. " Corresponding Batch Information

  REFRESH:
    i_batch_b,
    i_batch_c.

  READ TABLE i_edd_emi INTO lwa_enh_status
                         WITH KEY criteria  = lc_corr
                                  sel_high  = 'X'
                                  active   = abap_true.
  IF sy-subrc EQ 0.
    READ TABLE i_edd_emi INTO lwa_enh_status_a
                           WITH KEY criteria  = lc_corr
                                    sel_high  = space
                                    active   = abap_true.
    IF sy-subrc EQ 0.
      LOOP AT i_batch_a ASSIGNING <lfs_batch>
                        WHERE matnr EQ lwa_enh_status-sel_low.
        lv_tab = sy-tabix.
        IF <lfs_batch>-corres = lc_corres.
          READ TABLE i_batch_a ASSIGNING <lfs_batch_a> WITH KEY vbeln = <lfs_batch>-vbeln
                                                                matnr = lwa_enh_status_a-sel_low.
          IF sy-subrc EQ 0.
            APPEND <lfs_batch>   TO i_batch_c.
            APPEND <lfs_batch_a> TO i_batch_c.
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF <lfs_batch>-corres = lc_corres
      ENDLOOP. " LOOP AT i_batch_a ASSIGNING <lfs_batch>
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0

  LOOP AT i_batch_a ASSIGNING <lfs_batch_a>.
    lv_tab = sy-tabix.
    READ TABLE i_batch_c ASSIGNING <lfs_batch> WITH KEY vbeln = <lfs_batch_a>-vbeln
                                                        posnr = <lfs_batch_a>-posnr.
    IF sy-subrc EQ 0.
      DELETE i_batch_a INDEX lv_tab.
    ENDIF. " IF sy-subrc EQ 0
  ENDLOOP. " LOOP AT i_batch_a ASSIGNING <lfs_batch_a>

  SORT i_batch_c BY vbeln posnr.
  PERFORM f_sequence_batches_c.

  LOOP AT i_batch_c ASSIGNING <lfs_batch>.
    READ TABLE i_batch_b ASSIGNING <lfs_batch_b> WITH KEY vbeln = <lfs_batch>-vbeln.
    IF sy-subrc NE 0.
      APPEND <lfs_batch> TO i_batch_b.
    ENDIF. " IF sy-subrc NE 0
  ENDLOOP. " LOOP AT i_batch_c ASSIGNING <lfs_batch>

  APPEND LINES OF i_batch_a TO i_batch_d.
  APPEND LINES OF i_batch_b TO i_batch_d.

  LOOP AT i_batch_b ASSIGNING <lfs_batch_b>.
    DELETE i_batch_d WHERE vbeln = <lfs_batch_b>-vbeln
                     AND   posnr = <lfs_batch_b>-posnr.
    LOOP AT i_batch_c ASSIGNING <lfs_batch> WHERE vbeln = <lfs_batch_b>-vbeln.
      gv_vbeln =  <lfs_batch_b>-vbeln.
      READ TABLE i_edd_emi INTO lwa_enh_status
                            WITH KEY criteria = lc_corr
                                     sel_low  = <lfs_batch>-matnr
                                     active   = abap_true BINARY SEARCH.
      IF sy-subrc = 0 .

* Also for Material 05310, we dont need to check entries in KONDH, AUSP
        IF lv_matnr_cbat IS INITIAL. "below read only occurs once
          READ TABLE i_edd_emi INTO lwa_enh_status
                                 WITH KEY criteria = lc_matnr_comp
                                          active   = abap_true BINARY SEARCH.
          IF sy-subrc = 0.
            lv_matnr_cbat = lwa_enh_status-sel_low.
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF lv_matnr_cbat IS INITIAL

        CLEAR: lv_no_cond_check.
        IF lv_matnr_cbat = <lfs_batch>-matnr .
          lv_no_cond_check = abap_true.
        ENDIF. " IF lv_matnr_cbat = <lfs_batch>-matnr

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

        READ TABLE i_vbap ASSIGNING <lfs_vbap>
                           WITH KEY vbeln = <lfs_batch>-vbeln
                                    posnr = <lfs_batch>-posnr
                           BINARY SEARCH.
        IF sy-subrc EQ 0.
          lwa_komph-mvgr2 = <lfs_vbap>-mvgr2.
          lwa_bdcom-mtvfp = <lfs_vbap>-mtvfp.

          READ TABLE i_t459a INTO lwa_t459a WITH KEY bedae = <lfs_vbap>-bedae.
          IF sy-subrc EQ 0.
            lwa_bdcom-bedar = lwa_t459a-bedar.
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF sy-subrc EQ 0

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

        READ TABLE  i_vbep ASSIGNING <lfs_vbep>
                           WITH KEY vbeln = <lfs_batch>-vbeln
                                    posnr = <lfs_batch>-posnr
                           BINARY SEARCH.
        IF sy-subrc EQ 0.
          lwa_bdcom-mbuhr = <lfs_vbep>-mbuhr.
        ENDIF. " IF sy-subrc EQ 0

        lwa_bdcom-nodia = 'X'.

        READ TABLE i_kna1 ASSIGNING <lfs_kna1>
                           WITH KEY kunnr = <lfs_batch>-kunnr
                           BINARY SEARCH.
        IF sy-subrc EQ 0.
          lwa_bdcom-ort01 = <lfs_kna1>-ort01.
          lwa_bdcom-land1 = <lfs_kna1>-land1.
          lwa_bdcom-pstlz = <lfs_kna1>-pstlz.
          lwa_bdcom-simulation_mode = 'X'.
        ENDIF. " IF sy-subrc EQ 0

        CLEAR li_bdbatch.
        CALL FUNCTION 'VB_BATCH_DETERMINATION'
          EXPORTING
            i_komkh   = lwa_komkh
            i_komph   = lwa_komph
            x_bdcom   = lwa_bdcom
          TABLES
            e_bdbatch = li_bdbatch
          EXCEPTIONS
            no_plant  = 7
            OTHERS    = 99.
        IF sy-subrc <> 0.
          MESSAGE e000 WITH 'No batch determined'(021) INTO lwa_final-message.
          MOVE 'E'      TO lwa_final-status.
          MOVE <lfs_batch>-vbeln TO lwa_final-vbeln.
          MOVE <lfs_batch>-posnr TO lwa_final-posnr.
          APPEND lwa_final TO i_log_f.
        ELSE. " ELSE -> IF sy-subrc <> 0
          APPEND LINES OF li_bdbatch TO i_bdbatch_c.

          REFRESH: i_batch_cr,
                   i_batch_crr,
                   i_stock.
          LOOP AT li_bdbatch INTO lwa_bdbatch WHERE matnr IS NOT INITIAL
                                                AND charg IS NOT INITIAL .
            MOVE-CORRESPONDING lwa_bdbatch TO lwa_stock.
            APPEND lwa_stock TO i_stock.
            CLEAR: lwa_stock.
            CLEAR: i_batch_cr[].
            CALL FUNCTION 'VB_BATCH_GET_DETAIL'
              EXPORTING
                matnr              = lwa_bdbatch-matnr
                charg              = lwa_bdbatch-charg
                get_classification = abap_true
              TABLES
                char_of_batch      = i_batch_cr
              EXCEPTIONS
                no_material        = 1
                no_batch           = 2
                no_plant           = 3
                material_not_found = 4
                plant_not_found    = 5
                no_authority       = 6
                batch_not_exist    = 7
                lock_on_batch      = 8
                OTHERS             = 9.
            IF sy-subrc EQ 0.
              REFRESH i_batch_crr.
              APPEND LINES OF i_batch_cr TO i_batch_crr.
              CLEAR: i_batch_cr[].
            ELSE. " ELSE -> IF sy-subrc EQ 0
              MESSAGE e594(zptm_msg) RAISING no_batch_details. " No Batch details available
            ENDIF. " IF sy-subrc EQ 0

* Parallel Cursor
            READ TABLE i_stock INTO lwa_stock_tmp
                                      WITH KEY matnr = <lfs_batch>-matnr
                                               werks = <lfs_batch>-werks.
            IF sy-subrc = 0.
              CLEAR: lv_tab.
              lv_tab = sy-tabix.
              LOOP AT i_stock INTO lwa_stock FROM lv_tab.
                IF lwa_stock_tmp-matnr NE lwa_stock-matnr
                        AND lwa_stock_tmp-werks NE lwa_stock-werks.
                  EXIT.
                ENDIF. " IF lwa_stock_tmp-matnr NE lwa_stock-matnr
                lwa_corr_batch-vbeln = <lfs_batch>-vbeln.
                lwa_corr_batch-posnn = <lfs_batch>-posnr.
                MOVE-CORRESPONDING lwa_stock TO  lwa_corr_batch.
                lwa_corr_batch-posnr = <lfs_batch>-posnr.

* Move the corresponding batch details into final internal table
                READ TABLE i_batch_crr INTO lwa_batch_det
                                            WITH KEY atnam = lc_pap_bat.
                IF sy-subrc = 0.
                  lwa_corr_batch-corr_batch = lwa_batch_det-atwtb.

                  READ TABLE i_batch_crr INTO lwa_batch_det
                                            WITH KEY atnam = lc_disp_bat.
                  IF sy-subrc = 0.
                    lwa_corr_batch-ihd_batch = lwa_batch_det-atwtb.
                  ENDIF. " IF sy-subrc = 0
* Get the Batch Exp Date
                  READ TABLE i_batch_crr INTO lwa_batch_det
                                            WITH KEY atnam = lc_lobm_vfdat.
                  IF sy-subrc = 0.
                    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
                      EXPORTING
                        date_external            = lwa_batch_det-atwtb
                      IMPORTING
                        date_internal            = lwa_corr_batch-vfdat
                      EXCEPTIONS
                        date_external_is_invalid = 1
                        OTHERS                   = 2.
                    IF sy-subrc <> 0.
                      CLEAR: lwa_corr_batch-vfdat.
                    ENDIF. " IF sy-subrc <> 0
                  ENDIF. " IF sy-subrc = 0
*  Move the Contents of 04310 into one internal and 05310 into another
                  IF lwa_corr_batch-matnr = lv_matnr_cbat.
                    APPEND lwa_corr_batch TO li_corr_batch_comp.
                  ELSE. " ELSE -> IF lwa_corr_batch-matnr = lv_matnr_cbat
                    APPEND lwa_corr_batch TO li_corr_batch_chng.
                  ENDIF. " IF lwa_corr_batch-matnr = lv_matnr_cbat
                  CLEAR: lwa_batch_det,lwa_corr_batch.
                ENDIF. " IF sy-subrc = 0
              ENDLOOP. " LOOP AT i_stock INTO lwa_stock FROM lv_tab
            ENDIF. " IF sy-subrc = 0
            REFRESH: i_stock.
          ENDLOOP. " LOOP AT li_bdbatch INTO lwa_bdbatch WHERE matnr IS NOT INITIAL
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF sy-subrc = 0
    ENDLOOP. " LOOP AT i_batch_c ASSIGNING <lfs_batch> WHERE vbeln = <lfs_batch_b>-vbeln

* At this stage we group required batches for both the Materials(04310 and 5310)
    SORT li_corr_batch_comp BY  vbeln posnn vfdat ASCENDING.
    SORT li_corr_batch_chng BY  vbeln posnn vfdat ASCENDING.

    CLEAR: lv_vbeln_comp,lv_vbeln_chng, lv_posnr_comp, lv_posnr_chng.

    LOOP AT li_corr_batch_chng ASSIGNING <lfs_corr_batch_chng>.
* Make sure we run only once for a item(we can have multiple lines based on batch)
* dont consider the VBELN as in VA01 BELN will be blank
      IF  lv_posnr_chng = <lfs_corr_batch_chng>-posnn.
        EXIT.
      ENDIF. " IF lv_posnr_chng = <lfs_corr_batch_chng>-posnn

      READ TABLE i_vbep INTO lwa_vbep WITH KEY vbeln = <lfs_corr_batch_chng>-vbeln
                                               posnr = <lfs_corr_batch_chng>-posnn.
      IF sy-subrc EQ 0.
        IF lwa_vbep-wmeng GT <lfs_corr_batch_chng>-vrfmg.
          lv_ord_qty = abap_true.
          EXIT.
        ENDIF. " IF lwa_vbep-wmeng GT <lfs_corr_batch_chng>-vrfmg
      ENDIF. " IF sy-subrc EQ 0

* Parallel Cursor
      READ TABLE li_corr_batch_comp  INTO lwa_corr_batch_comp
                                        WITH KEY matnr          = lv_matnr_cbat
                                                 vfdat          = <lfs_corr_batch_chng>-vfdat
                                                 corr_batch     =  <lfs_corr_batch_chng>-corr_batch
                                                 ihd_batch+5(3) = <lfs_corr_batch_chng>-ihd_batch+5(3).
      IF sy-subrc = 0 .
        CLEAR: lv_tab.
        lv_tab = sy-tabix.

        CLEAR lv_index.

        LOOP AT li_corr_batch_comp  ASSIGNING <lfs_corr_batch_comp> FROM lv_tab.
*          lv_index = sy-tabix.
* Exit condition for Parallel cursor
          IF <lfs_corr_batch_comp>-matnr NE lv_matnr_cbat AND  <lfs_corr_batch_comp>-vfdat NE <lfs_corr_batch_chng>-vfdat
             AND  <lfs_corr_batch_comp>-corr_batch NE  <lfs_corr_batch_chng>-corr_batch
             AND  <lfs_corr_batch_comp>-ihd_batch+5(3) NE <lfs_corr_batch_chng>-ihd_batch+5(3)  .
            EXIT.
          ENDIF. " IF <lfs_corr_batch_comp>-matnr NE lv_matnr_cbat AND <lfs_corr_batch_comp>-vfdat NE <lfs_corr_batch_chng>-vfdat
* Exit condition for below logic to run only once for a item(we can have multiple lines based on batch)
          IF  lv_posnr_comp = <lfs_corr_batch_comp>-posnn.
            EXIT.
          ENDIF. " IF lv_posnr_comp = <lfs_corr_batch_comp>-posnn

          READ TABLE i_vbep INTO lwa_vbep WITH KEY vbeln = <lfs_corr_batch_comp>-vbeln
                                                   posnr = <lfs_corr_batch_comp>-posnn.
          IF sy-subrc EQ 0.
            IF lwa_vbep-wmeng GT <lfs_corr_batch_comp>-vrfmg.
              lv_ord_qty = abap_true.
              EXIT.
            ENDIF. " IF lwa_vbep-wmeng GT <lfs_corr_batch_comp>-vrfmg
          ENDIF. " IF sy-subrc EQ 0

          <lfs_corr_batch_chng>-corresponding = abap_true.
          <lfs_corr_batch_comp>-corresponding = abap_true.
          CLEAR lv_ord_qty.
** also change the batch for 04310 material with 05310

          lv_vbeln_comp =  <lfs_corr_batch_comp>-vbeln.
          lv_posnr_comp =  <lfs_corr_batch_comp>-posnn.
        ENDLOOP. " LOOP AT li_corr_batch_comp ASSIGNING <lfs_corr_batch_comp> FROM lv_tab
        lv_vbeln_chng =  <lfs_corr_batch_chng>-vbeln.
        lv_posnr_chng =  <lfs_corr_batch_chng>-posnn.
      ENDIF. " IF sy-subrc = 0

    ENDLOOP. " LOOP AT li_corr_batch_chng ASSIGNING <lfs_corr_batch_chng>

    IF li_corr_batch_chng[] IS NOT INITIAL.
      DELETE ADJACENT DUPLICATES FROM li_corr_batch_chng COMPARING vbeln posnr corresponding.
    ENDIF. " IF li_corr_batch_chng[] IS NOT INITIAL

    IF li_corr_batch_comp[] IS NOT INITIAL.
      DELETE ADJACENT DUPLICATES FROM li_corr_batch_comp COMPARING vbeln posnr corresponding.
    ENDIF. " IF li_corr_batch_comp[] IS NOT INITIAL

    LOOP AT li_corr_batch_chng ASSIGNING <lfs_corr_batch_chng> WHERE corresponding = abap_true.
* Change the 043010 material
      READ TABLE i_batch_c ASSIGNING <lfs_batch_c>
                          WITH KEY vbeln = <lfs_corr_batch_chng>-vbeln
                                   posnr = <lfs_corr_batch_chng>-posnr.
      IF sy-subrc = 0.
        <lfs_batch_c>-charg = <lfs_corr_batch_chng>-charg.
        READ TABLE i_bdbatch_c ASSIGNING <lfs_bdbatch_c>
                            WITH KEY matnr = <lfs_corr_batch_chng>-matnr.
        IF sy-subrc = 0.
          <lfs_bdbatch_c>-charg = <lfs_corr_batch_chng>-charg.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc = 0
    ENDLOOP. " LOOP AT li_corr_batch_chng ASSIGNING <lfs_corr_batch_chng> WHERE corresponding = abap_true

    LOOP AT li_corr_batch_comp ASSIGNING <lfs_corr_batch_comp> WHERE corresponding = abap_true.
      READ TABLE i_batch_c ASSIGNING <lfs_batch_c>
                          WITH KEY vbeln = <lfs_corr_batch_comp>-vbeln
                                   posnr = <lfs_corr_batch_comp>-posnr.
      IF sy-subrc = 0.
        <lfs_batch_c>-charg = <lfs_corr_batch_comp>-charg.
        READ TABLE i_bdbatch_c ASSIGNING <lfs_bdbatch_c>
                            WITH KEY matnr = <lfs_corr_batch_comp>-matnr.
        IF sy-subrc = 0.
          <lfs_bdbatch_c>-charg = <lfs_corr_batch_comp>-charg.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc = 0

    ENDLOOP. " LOOP AT li_corr_batch_comp ASSIGNING <lfs_corr_batch_comp> WHERE corresponding = abap_true

    IF lv_ord_qty NE abap_true.
      LOOP AT i_bdbatch_c ASSIGNING <lfs_bdbatch_c>.
        lv_tab = sy-tabix.
        READ TABLE i_batch_c ASSIGNING <lfs_batch_c>
                             WITH KEY matnr = <lfs_bdbatch_c>-matnr
                                      charg = <lfs_bdbatch_c>-charg.
        IF sy-subrc NE 0.
          DELETE i_bdbatch_c INDEX lv_tab.
        ENDIF. " IF sy-subrc NE 0
      ENDLOOP. " LOOP AT i_bdbatch_c ASSIGNING <lfs_bdbatch_c>
      APPEND LINES OF i_bdbatch_c TO i_bdbatch_f.
      IF i_bdbatch_f IS NOT INITIAL.
        PERFORM f_assign_corr_batches.
      ENDIF. " IF i_bdbatch_f IS NOT INITIAL
    ELSE. " ELSE -> IF lv_ord_qty NE abap_true
      "Log
      MOVE <lfs_batch>-vbeln TO lwa_final-vbeln.
      MOVE <lfs_batch>-posnr TO lwa_final-posnr.
      lwa_final-status = 'E'.
      lwa_final-message = 'Ordered Quantity exceeds available quantity'.
      APPEND lwa_final TO i_log_f.
    ENDIF. " IF lv_ord_qty NE abap_true
    CLEAR: li_corr_batch_chng[], li_corr_batch_comp[],lwa_corr_batch_chng,
           lwa_corr_batch_comp.
    UNASSIGN: <lfs_batch_c>, <lfs_corr_batch_comp>, <lfs_corr_batch_chng>.

    CLEAR : lwa_komkh,
            lwa_komph,
            lwa_bdcom.

    REFRESH: li_bdbatch,
             i_bdbatch_c,
             i_bdbatch_f.
  ENDLOOP. " LOOP AT i_batch_b ASSIGNING <lfs_batch_b>


ENDFORM. " F_DETERMINE_CORRES_BATCH
*&---------------------------------------------------------------------*
*&      Form  F_ASSIGN_CORR_BATCHES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_assign_corr_batches .
  DATA:
    li_return            TYPE TABLE OF bapiret2,    " Return Parameter
    lwa_return           TYPE bapiret2,             " Return Parameter
    li_return_c          TYPE bapiret2,             " Return Parameter
    li_schedule_lines    TYPE TABLE OF bapischdl,   " Communication Fields for Maintaining SD Doc. Schedule Lines
    li_schedule_linesx   TYPE TABLE OF bapischdlx,  " Checkbox List for Maintaining Sales Document Schedule Line
    li_order_item_in     TYPE TABLE OF bapisditm,   " Communication Fields: Sales and Distribution Document Item
    li_order_item_inx    TYPE TABLE OF  bapisditmx, " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_in    TYPE bapisditm,            " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_inx   TYPE bapisditmx,           " Communication Fields: Sales and Distribution Document Item
    lwa_order_header_in  TYPE bapisdh1,             " Communication Fields: SD Order Header
    lwa_order_header_inx TYPE bapisdh1x,            " Checkbox List: SD Order Header
    lwa_bdbatch_f        TYPE bdbatch,              " Results Table for Batch Determination
    lwa_schedule_lines   TYPE bapischdl,            " Communication Fields for Maintaining SD Doc. Schedule Lines
    lwa_schedule_linesx  TYPE bapischdlx,           " Checkbox List for Maintaining Sales Document Schedule Line
    lwa_log              TYPE ty_final,
    lv_logtext           TYPE string,
    lv_joblog            TYPE string.

  FIELD-SYMBOLS:
    <lfs_batch>   TYPE ty_batch_final,
    <lfs_batch_c> TYPE ty_batch_final,
    <lfs_return>  TYPE bapiret2, " Return Parameter
    <lfs_vbep_c>  TYPE ty_vbep_c.

  CONSTANTS:
    lc_error             TYPE char1 VALUE 'E'. " Error of type CHAR1

  LOOP AT i_batch_c ASSIGNING <lfs_batch>
                    WHERE vbeln = gv_vbeln.

    lwa_order_header_inx-updateflag = 'U'.
    lwa_order_item_in-itm_number = <lfs_batch>-posnr.
    READ TABLE i_bdbatch_f INTO lwa_bdbatch_f WITH KEY matnr = <lfs_batch>-matnr.
    IF sy-subrc EQ 0.
      lwa_order_item_in-material = lwa_bdbatch_f-matnr.
      lwa_order_item_in-batch = lwa_bdbatch_f-charg.
      <lfs_batch>-charg       = lwa_bdbatch_f-charg.
      READ TABLE i_vbep_c ASSIGNING <lfs_vbep_c>
                          WITH KEY vbeln = <lfs_batch>-vbeln
                                   posnr = <lfs_batch>-posnr.
      IF sy-subrc EQ 0.
        lwa_schedule_lines-req_qty = <lfs_vbep_c>-wmeng.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
    APPEND lwa_order_item_in TO li_order_item_in.

    lwa_order_item_inx-itm_number = <lfs_batch>-posnr.
    lwa_order_item_inx-updateflag = 'U'.
    lwa_order_item_inx-batch = 'X'.
    APPEND lwa_order_item_inx TO li_order_item_inx.

    lwa_schedule_lines-itm_number = <lfs_batch>-posnr.
    lwa_schedule_lines-sched_line = '0001'.
    APPEND lwa_schedule_lines TO li_schedule_lines.

    lwa_schedule_linesx-itm_number = <lfs_batch>-posnr.
    lwa_schedule_linesx-req_qty    = 'X'.
    lwa_schedule_linesx-updateflag = 'U'.
    lwa_schedule_linesx-sched_line = '0001'.
    APPEND lwa_schedule_linesx TO li_schedule_linesx.
  ENDLOOP. " LOOP AT i_batch_c ASSIGNING <lfs_batch>

  CHECK <lfs_batch> IS ASSIGNED.

  CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
    EXPORTING
      salesdocument    = <lfs_batch>-vbeln
      order_header_inx = lwa_order_header_inx
*     behave_when_error = 'X'
    TABLES
      return           = li_return
      order_item_in    = li_order_item_in
      order_item_inx   = li_order_item_inx.

  READ TABLE li_return ASSIGNING <lfs_return>
                       WITH KEY type = lc_error. " Return assigning of type
  IF sy-subrc <> 0.
    READ TABLE i_batch_d TRANSPORTING NO FIELDS WITH KEY vbeln = <lfs_batch>-vbeln.
    IF sy-subrc NE 0.
      PERFORM f_unlock_orders USING <lfs_batch>. "Defect 6508
    ENDIF. " IF sy-subrc NE 0
    IF sy-batch IS INITIAL.

      lwa_log-vbeln   = <lfs_batch>-vbeln.
      lwa_log-posnr   = <lfs_batch>-posnr.
      lwa_log-status  = 'S'.
      lwa_log-message = 'Sales Order successfully saved'.
      APPEND lwa_log TO i_log_f.

      LOOP AT i_batch_c ASSIGNING <lfs_batch_c>
                            WHERE vbeln = gv_vbeln.
        LOOP AT i_batch ASSIGNING <lfs_batch>
                            WHERE vbeln = gv_vbeln
                              AND posnr = <lfs_batch_c>-posnr.
          <lfs_batch>-charg = <lfs_batch_c>-charg.
        ENDLOOP. " LOOP AT i_batch ASSIGNING <lfs_batch>
      ENDLOOP. " LOOP AT i_batch_c ASSIGNING <lfs_batch_c>
    ELSE. " ELSE -> IF sy-batch IS INITIAL
      LOOP AT li_return INTO lwa_return.
        MESSAGE ID lwa_return-id TYPE lwa_return-type
                                 NUMBER lwa_return-number
                                 WITH lwa_return-message
            INTO lv_joblog.
        WRITE lv_joblog.
      ENDLOOP. " LOOP AT li_return INTO lwa_return
    ENDIF. " IF sy-batch IS INITIAL

    REFRESH: li_return.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = 'X'
      IMPORTING
        return = li_return_c.

    APPEND li_return_c TO i_log.

    CLEAR: lwa_order_header_inx.
    REFRESH: li_return,
             li_order_item_in,
             li_order_item_inx,
             li_schedule_lines,
             li_schedule_linesx.
  ELSE. " ELSE -> IF sy-subrc <> 0
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
      IMPORTING
        return = lwa_return.

    IF sy-batch IS INITIAL.
      APPEND lwa_return TO i_log.
    ELSE. " ELSE -> IF sy-batch IS INITIAL
      MESSAGE ID lwa_return-id TYPE lwa_return-type
                               NUMBER lwa_return-number
                               WITH lwa_return-message
          INTO lv_joblog.
      WRITE lv_joblog.
    ENDIF. " IF sy-batch IS INITIAL
  ENDIF. " IF sy-subrc <> 0
ENDFORM. " F_ASSIGN_CORR_BATCHES
*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_DATA_CHANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM f_handle_data_change  USING er_data_changed TYPE REF TO cl_alv_changed_data_protocol. " Message Log for Data Entry

  DATA: ls_good     TYPE lvc_s_modi, " ALV control: Modified cells for application
        lv_temp_str TYPE string,
        lv_row      TYPE i,                                 "#EC NEEDED
        lv_value    TYPE c,                                 "#EC NEEDED
        lv_col      TYPE i,                                 "#EC NEEDED
        ls_row_no   TYPE lvc_s_roid, " Assignment of line number to line ID
        ls_roid     TYPE lvc_s_row,  " ALV control: Line description
        ls_col_id   TYPE lvc_s_col.  " ALV Control: Column ID

  FIELD-SYMBOLS:
        <lfs_batch> TYPE ty_batch_final.

  CALL METHOD o_alv->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  LOOP AT er_data_changed->mt_good_cells INTO ls_good.

    CALL METHOD o_alv->get_current_cell
      IMPORTING
        e_row     = lv_row   "#EC NEEDED
        e_value   = lv_value "#EC NEEDED
        e_col     = lv_col   "#EC NEEDED
        es_row_id = ls_roid
        es_col_id = ls_col_id
        es_row_no = ls_row_no.

    CALL METHOD er_data_changed->get_cell_value
      EXPORTING
        i_row_id    = ls_good-row_id
        i_fieldname = ls_good-fieldname
      IMPORTING
        e_value     = lv_temp_str.
    IF sy-subrc EQ 0.
      CASE ls_good-fieldname.
        WHEN 'CHARG'.
          READ TABLE i_batch ASSIGNING <lfs_batch> INDEX ls_good-row_id.
          IF sy-subrc EQ 0.
            <lfs_batch>-charg = lv_temp_str.
            APPEND <lfs_batch> TO i_batch_s.
          ENDIF. " IF sy-subrc EQ 0
      ENDCASE.
    ENDIF. " IF sy-subrc EQ 0
  ENDLOOP. " LOOP AT er_data_changed->mt_good_cells INTO ls_good

  CALL METHOD o_alv->refresh_table_display.
ENDFORM. " F_HANDLE_DATA_CHANGE
*&---------------------------------------------------------------------*
*&      Form  F_SAVE_BATCH_CHANGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_batch_changes .
  DATA:
    li_return            TYPE TABLE OF bapiret2,    " Return Parameter
    lwa_return           TYPE bapiret2,             " Return Parameter
    li_return_c          TYPE bapiret2,             " Return Parameter
    li_schedule_lines    TYPE TABLE OF bapischdl,   " Communication Fields for Maintaining SD Doc. Schedule Lines
    li_schedule_linesx   TYPE TABLE OF bapischdlx,  " Checkbox List for Maintaining Sales Document Schedule Line
    li_order_item_in     TYPE TABLE OF bapisditm,   " Communication Fields: Sales and Distribution Document Item
    li_order_item_inx    TYPE TABLE OF  bapisditmx, " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_in    TYPE bapisditm,            " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_inx   TYPE bapisditmx,           " Communication Fields: Sales and Distribution Document Item
    lwa_order_header_in  TYPE bapisdh1,             " Communication Fields: SD Order Header
    lwa_order_header_inx TYPE bapisdh1x,            " Checkbox List: SD Order Header
    lwa_bdbatch_f        TYPE bdbatch,              " Results Table for Batch Determination
    lwa_schedule_lines   TYPE bapischdl,            " Communication Fields for Maintaining SD Doc. Schedule Lines
    lwa_schedule_linesx  TYPE bapischdlx,           " Checkbox List for Maintaining Sales Document Schedule Line
    lv_logtext           TYPE string,
    lv_joblog            TYPE string.

  FIELD-SYMBOLS:
    <lfs_batch>  TYPE ty_batch_final,
    <lfs_return> TYPE bapiret2, " Return Parameter
    <lfs_vbep_c> TYPE ty_vbep_c.

  CONSTANTS:
    lc_error             TYPE char1 VALUE 'E'. " Error of type CHAR1

  LOOP AT i_batch_s ASSIGNING <lfs_batch>.
    lwa_order_header_inx-updateflag = 'U'.
    lwa_order_item_in-itm_number = <lfs_batch>-posnr.
    APPEND lwa_order_item_in TO li_order_item_in.

    lwa_order_item_in-material = <lfs_batch>-matnr.
    lwa_order_item_in-batch = <lfs_batch>-charg.

    lwa_order_item_inx-itm_number = <lfs_batch>-posnr.
    lwa_order_item_inx-updateflag = 'U'.
    lwa_order_item_inx-batch = 'X'.
    APPEND lwa_order_item_inx TO li_order_item_inx.

    CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
      EXPORTING
        salesdocument    = <lfs_batch>-vbeln
        order_header_inx = lwa_order_header_inx
      TABLES
        return           = li_return
        order_item_in    = li_order_item_in
        order_item_inx   = li_order_item_inx.

    READ TABLE li_return ASSIGNING <lfs_return>
                         WITH KEY type = lc_error. " Return assigning of type
    IF sy-subrc <> 0.
      PERFORM f_unlock_orders USING <lfs_batch>. "Defect 6508
      APPEND LINES OF li_return TO i_log.
      IF sy-batch IS INITIAL.
      ELSE. " ELSE -> IF sy-batch IS INITIAL
        LOOP AT li_return INTO lwa_return.
          MESSAGE ID lwa_return-id TYPE lwa_return-type
                                   NUMBER lwa_return-number
                                   WITH lwa_return-message
              INTO lv_joblog.
          WRITE lv_joblog.
        ENDLOOP. " LOOP AT li_return INTO lwa_return
      ENDIF. " IF sy-batch IS INITIAL

      REFRESH: li_return.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait   = 'X'
        IMPORTING
          return = li_return_c.

      APPEND li_return_c TO i_log.

      CLEAR: lwa_order_header_inx.
      REFRESH: li_return,
               li_order_item_in,
               li_order_item_inx,
               li_schedule_lines,
               li_schedule_linesx.
    ELSE. " ELSE -> IF sy-subrc <> 0
      PERFORM f_unlock_orders USING <lfs_batch>. "Defect 6508
      CLEAR: lwa_order_header_inx.
      REFRESH: li_return,
               li_order_item_in,
               li_order_item_inx,
               li_schedule_lines,
               li_schedule_linesx.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
        IMPORTING
          return = lwa_return.

      IF sy-batch IS INITIAL.
        APPEND lwa_return TO i_log.
      ELSE. " ELSE -> IF sy-batch IS INITIAL
        MESSAGE ID lwa_return-id TYPE lwa_return-type
                                 NUMBER lwa_return-number
                                 WITH lwa_return-message
            INTO lv_joblog.
        WRITE lv_joblog.
      ENDIF. " IF sy-batch IS INITIAL
    ENDIF. " IF sy-subrc <> 0
  ENDLOOP. " LOOP AT i_batch_s ASSIGNING <lfs_batch>
ENDFORM. " F_SAVE_BATCH_CHANGES
*&---------------------------------------------------------------------*
*&      Form  f_sequence_batches_c
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_sequence_batches_c .

  CONSTANTS:
    lc_antigens   TYPE string VALUE 'ANTIGENS',
    lc_corres     TYPE string VALUE 'CORRESPONDING',
    lc_noncorres  TYPE string VALUE 'NON CORRESPONDING',
    lc_ordtyp_std TYPE string VALUE 'ZSTD',
    lc_ordtyp_or  TYPE string VALUE 'ZOR',
    lc_ordtyp_int TYPE string VALUE 'ZINT',
    lc_prior_1a   TYPE string VALUE 'A',
    lc_prior_1b   TYPE string VALUE 'B',
    lc_prior_1c   TYPE string VALUE 'C',
    lc_prior_2a   TYPE string VALUE 'D',
    lc_prior_2b   TYPE string VALUE 'E',
    lc_prior_2c   TYPE string VALUE 'F',
    lc_prior_3a   TYPE string VALUE 'G',
    lc_prior_3b   TYPE string VALUE 'H',
    lc_prior_3c   TYPE string VALUE 'I',
    lc_prior_4a   TYPE string VALUE 'J',
    lc_prior_4b   TYPE string VALUE 'K',
    lc_prior_4c   TYPE string VALUE 'L',
    lc_prior_5a   TYPE string VALUE 'M',
    lc_prior_5b   TYPE string VALUE 'N',
    lc_prior_5c   TYPE string VALUE 'O',
    lc_prior_5d   TYPE string VALUE 'P'.

  FIELD-SYMBOLS:
    <lfs_batch> TYPE ty_batch_final.

  SORT i_batch_c BY auart.

  LOOP AT i_batch_c ASSIGNING <lfs_batch>.
    CASE <lfs_batch>-auart.
      WHEN lc_ordtyp_std.
        IF <lfs_batch>-corres = lc_corres.
          <lfs_batch>-prior = lc_prior_1a.
        ELSEIF <lfs_batch>-corres = lc_noncorres.
          <lfs_batch>-prior = lc_prior_1b.
        ELSEIF <lfs_batch>-antigens NE space.
          <lfs_batch>-prior = lc_prior_1c.
        ELSEIF <lfs_batch>-antigens EQ space AND
               <lfs_batch>-corres   EQ space.
          <lfs_batch>-prior = lc_prior_5a.
        ENDIF. " IF <lfs_batch>-corres = lc_corres
      WHEN lc_ordtyp_or.
        IF <lfs_batch>-corres = lc_corres.
          <lfs_batch>-prior = lc_prior_2a.
        ELSEIF <lfs_batch>-corres = lc_noncorres.
          <lfs_batch>-prior = lc_prior_2b.
        ELSEIF <lfs_batch>-antigens NE space.
          <lfs_batch>-prior = lc_prior_2c.
        ELSEIF <lfs_batch>-antigens EQ space AND
               <lfs_batch>-corres   EQ space.
          <lfs_batch>-prior = lc_prior_5b.
        ENDIF. " IF <lfs_batch>-corres = lc_corres
      WHEN lc_ordtyp_int.
        IF <lfs_batch>-corres = lc_corres.
          <lfs_batch>-prior = lc_prior_3a.
        ELSEIF <lfs_batch>-corres = lc_noncorres.
          <lfs_batch>-prior = lc_prior_3b.
        ELSEIF <lfs_batch>-antigens NE space.
          <lfs_batch>-prior = lc_prior_3c.
        ELSEIF <lfs_batch>-antigens EQ space AND
               <lfs_batch>-corres   EQ space.
          <lfs_batch>-prior = lc_prior_5c.
        ENDIF. " IF <lfs_batch>-corres = lc_corres
      WHEN OTHERS.
        IF <lfs_batch>-corres = lc_corres.
          <lfs_batch>-prior = lc_prior_4a.
        ELSEIF <lfs_batch>-corres = lc_noncorres.
          <lfs_batch>-prior = lc_prior_4b.
        ELSEIF <lfs_batch>-antigens NE space.
          <lfs_batch>-prior = lc_prior_4c.
        ELSEIF <lfs_batch>-antigens EQ space AND
               <lfs_batch>-corres   EQ space.
          <lfs_batch>-prior = lc_prior_5d.
        ENDIF. " IF <lfs_batch>-corres = lc_corres
    ENDCASE.
  ENDLOOP. " LOOP AT i_batch_c ASSIGNING <lfs_batch>

  SORT i_batch_c BY prior ASCENDING.

ENDFORM. " F_SEQUENCE_BATCHES
*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_BATCH_IN_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_clear_batch_in_so .

  DATA:
    li_return            TYPE TABLE OF bapiret2,    " Return Parameter
    lwa_return           TYPE bapiret2,             " Return Parameter
    li_return_c          TYPE bapiret2,             " Return Parameter
    li_schedule_lines    TYPE TABLE OF bapischdl,   " Communication Fields for Maintaining SD Doc. Schedule Lines
    li_schedule_linesx   TYPE TABLE OF bapischdlx,  " Checkbox List for Maintaining Sales Document Schedule Line
    li_order_item_in     TYPE TABLE OF bapisditm,   " Communication Fields: Sales and Distribution Document Item
    li_order_item_inx    TYPE TABLE OF  bapisditmx, " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_in    TYPE bapisditm,            " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_inx   TYPE bapisditmx,           " Communication Fields: Sales and Distribution Document Item
    lwa_order_header_in  TYPE bapisdh1,             " Communication Fields: SD Order Header
    lwa_order_header_inx TYPE bapisdh1x,            " Checkbox List: SD Order Header
    lwa_bdbatch_f        TYPE bdbatch,              " Results Table for Batch Determination
    lwa_schedule_lines   TYPE bapischdl,            " Communication Fields for Maintaining SD Doc. Schedule Lines
    lwa_schedule_linesx  TYPE bapischdlx,           " Checkbox List for Maintaining Sales Document Schedule Line
    lv_logtext           TYPE string,
    lv_joblog            TYPE string.

  FIELD-SYMBOLS:
    <lfs_batch>  TYPE ty_batch_final,
    <lfs_return> TYPE bapiret2, " Return Parameter
    <lfs_vbep_c> TYPE ty_vbep_c.

  CONSTANTS:
    lc_error             TYPE char1 VALUE 'E'. " Error of type CHAR1

  REFRESH: i_batch_d.
  i_batch_d = i_batch_a.
  LOOP AT i_batch_a ASSIGNING <lfs_batch>.
    DELETE i_batch_d WHERE vbeln = <lfs_batch>-vbeln
                     AND   posnr = <lfs_batch>-posnr.
    lwa_order_header_inx-updateflag = 'U'.
    lwa_order_item_in-itm_number = <lfs_batch>-posnr.
    lwa_order_item_in-material = <lfs_batch>-matnr.
    CLEAR <lfs_batch>-charg .
    lwa_order_item_in-batch = <lfs_batch>-charg.
    APPEND lwa_order_item_in TO li_order_item_in.

    lwa_order_item_inx-itm_number = <lfs_batch>-posnr.
    lwa_order_item_inx-updateflag = 'U'.
    lwa_order_item_inx-batch = 'X'.
    APPEND lwa_order_item_inx TO li_order_item_inx.

    CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
      EXPORTING
        salesdocument    = <lfs_batch>-vbeln
        order_header_inx = lwa_order_header_inx
      TABLES
        return           = li_return
        order_item_in    = li_order_item_in
        order_item_inx   = li_order_item_inx.

    READ TABLE li_return ASSIGNING <lfs_return>
                         WITH KEY type = lc_error. " Return assigning of type
    IF sy-subrc <> 0.
      READ TABLE i_batch_d TRANSPORTING NO FIELDS WITH KEY vbeln = <lfs_batch>-vbeln.
      IF sy-subrc NE 0.
        PERFORM f_unlock_orders USING <lfs_batch>. "Defect 6508
      ENDIF. " IF sy-subrc NE 0

      APPEND LINES OF li_return TO i_log.
      IF sy-batch IS INITIAL.
      ELSE. " ELSE -> IF sy-batch IS INITIAL
        LOOP AT li_return INTO lwa_return.
          MESSAGE ID lwa_return-id TYPE lwa_return-type
                                   NUMBER lwa_return-number
                                   WITH lwa_return-message
              INTO lv_joblog.
          WRITE lv_joblog.
        ENDLOOP. " LOOP AT li_return INTO lwa_return
      ENDIF. " IF sy-batch IS INITIAL

      REFRESH: li_return.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait   = 'X'
        IMPORTING
          return = li_return_c.

      APPEND li_return_c TO i_log.

      CLEAR: lwa_order_header_inx.
      REFRESH: li_return,
               li_order_item_in,
               li_order_item_inx,
               li_schedule_lines,
               li_schedule_linesx.
    ELSE. " ELSE -> IF sy-subrc <> 0
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
        IMPORTING
          return = lwa_return.

      IF sy-batch IS INITIAL.
        APPEND lwa_return TO i_log.
      ELSE. " ELSE -> IF sy-batch IS INITIAL
        MESSAGE ID lwa_return-id TYPE lwa_return-type
                                 NUMBER lwa_return-number
                                 WITH lwa_return-message
            INTO lv_joblog.
        WRITE lv_joblog.
      ENDIF. " IF sy-batch IS INITIAL
    ENDIF. " IF sy-subrc <> 0
  ENDLOOP. " LOOP AT i_batch_a ASSIGNING <lfs_batch>

ENDFORM. " F_CLEAR_BATCH_IN_SO

*&---------------------------------------------------------------------*
*&      Form  f_validate_batches
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_validate_batches .

  DATA :li_log_f  TYPE TABLE OF ty_final,
        lwa_log_f TYPE ty_final.

  FIELD-SYMBOLS: <lfs_batch>          TYPE ty_batch_final.

  IF i_batch[] IS NOT INITIAL .
    SELECT matnr werks charg FROM mcha " Batches
             INTO TABLE i_mcha_data FOR ALL ENTRIES IN i_batch
             WHERE matnr = i_batch-matnr AND
                   werks = i_batch-werks AND
                   charg = i_batch-charg.
    SORT i_mcha_data BY matnr werks charg.
* Check invalid batchs and clean from the Screen.
    LOOP AT i_batch_a ASSIGNING <lfs_batch>.
      READ TABLE i_mcha_data WITH KEY matnr = <lfs_batch>-matnr
                                      werks = <lfs_batch>-werks
                                      charg = <lfs_batch>-charg BINARY SEARCH TRANSPORTING NO FIELDS .
      IF sy-subrc <> 0 AND <lfs_batch>-charg IS NOT INITIAL  .
*   Appned record to Log and clear Batch
        lwa_log_f-vbeln = <lfs_batch>-vbeln.
        lwa_log_f-posnr = <lfs_batch>-posnr.
        CONCATENATE 'Invalid Batch'(d00) <lfs_batch>-charg INTO  lwa_log_f-message SEPARATED BY space.
        APPEND lwa_log_f TO i_log_f .
        CLEAR <lfs_batch>-charg .
      ENDIF. " IF sy-subrc <> 0 AND <lfs_batch>-charg IS NOT INITIAL
    ENDLOOP . " LOOP AT i_batch_a ASSIGNING <lfs_batch>
  ENDIF. " IF i_batch[] IS NOT INITIAL
ENDFORM. " F_VALIDATE_BATCHES

*&---------------------------------------------------------------------*
*&      Form  F_ASSIGN_BATCHES_TO_ORDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

*SOC by DDWIVEDI CR#231
FORM f_assign_batches_to_order .

  DATA:
    li_return            TYPE TABLE OF bapiret2,    " Return Parameter
    lwa_return           TYPE bapiret2,             " Return Parameter
    li_return_c          TYPE bapiret2,             " Return Parameter
    li_schedule_lines    TYPE TABLE OF bapischdl,   " Communication Fields for Maintaining SD Doc. Schedule Lines
    li_schedule_linesx   TYPE TABLE OF bapischdlx,  " Checkbox List for Maintaining Sales Document Schedule Line
    li_order_item_in     TYPE TABLE OF bapisditm,   " Communication Fields: Sales and Distribution Document Item
    li_order_item_inx    TYPE TABLE OF  bapisditmx, " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_in    TYPE bapisditm,            " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_inx   TYPE bapisditmx,           " Communication Fields: Sales and Distribution Document Item
    lwa_order_header_in  TYPE bapisdh1,             " Communication Fields: SD Order Header
    lwa_order_header_inx TYPE bapisdh1x,            " Checkbox List: SD Order Header
    lwa_bdbatch_f        TYPE bdbatch,              " Results Table for Batch Determination
    lwa_schedule_lines   TYPE bapischdl,            " Communication Fields for Maintaining SD Doc. Schedule Lines
    lwa_schedule_linesx  TYPE bapischdlx,           " Checkbox List for Maintaining Sales Document Schedule Line
    lv_logtext           TYPE string,
    lv_joblog            TYPE string,
    lwa_log              TYPE ty_final.

  FIELD-SYMBOLS:
    <lfs_batch>  TYPE ty_batch_final,
    <lfs_return> TYPE bapiret2. " Return Parameter

  CONSTANTS:
    lc_error             TYPE char1 VALUE 'E'. " Error of type CHAR1

  lwa_order_header_inx-updateflag = 'U'.
  lwa_order_item_in-itm_number = <fs_batch>-posnr.
*  READ TABLE i_bdbatch_f INTO lwa_bdbatch_f INDEX 1.
*  IF sy-subrc EQ 0.
  lwa_order_item_in-material = <fs_batch>-matnr.
  lwa_order_item_in-batch = <fs_batch>-charg.
*    lwa_schedule_lines-req_qty = lwa_bdbatch_f-menge.
*  ENDIF. " IF sy-subrc EQ 0
  APPEND lwa_order_item_in TO li_order_item_in.

  lwa_order_item_inx-itm_number = <fs_batch>-posnr.
  lwa_order_item_inx-updateflag = 'U'.
  lwa_order_item_inx-batch = 'X'.
  APPEND lwa_order_item_inx TO li_order_item_inx.

  CHECK <fs_batch> IS ASSIGNED.

  CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
    EXPORTING
      salesdocument    = <fs_batch>-vbeln
      order_header_inx = lwa_order_header_inx
    TABLES
      return           = li_return
      order_item_in    = li_order_item_in
      order_item_inx   = li_order_item_inx.

  READ TABLE li_return ASSIGNING <lfs_return>
                       WITH KEY type = lc_error. " Return assigning of type
  IF sy-subrc NE 0.
    PERFORM f_unlock_orders USING <fs_batch>. "Defect 6508
    lwa_log-vbeln   = <fs_batch>-vbeln.
    lwa_log-posnr   = <fs_batch>-posnr.
    lwa_log-status  = 'S'.
    lwa_log-message = 'Sales Order successfully saved'.
    APPEND lwa_log TO i_log_f.

    CLEAR: li_return_c.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = 'X'
      IMPORTING
        return = li_return_c.

    APPEND li_return_c TO i_log.

    CLEAR: lwa_order_header_inx.
    REFRESH: li_return,
             li_order_item_in,
             li_order_item_inx,
             li_schedule_lines,
             li_schedule_linesx.
  ELSE. " ELSE -> IF sy-subrc NE 0
    IF sy-batch IS INITIAL.
      <fs_batch>-charg = lwa_bdbatch_f-charg.
      lwa_log-vbeln   = <fs_batch>-vbeln.
      lwa_log-posnr   = <fs_batch>-posnr.
      lwa_log-status  = 'E'.
      lwa_log-message = <lfs_return>-message.
      APPEND lwa_log TO i_log_f.
    ELSE. " ELSE -> IF sy-batch IS INITIAL
      CONCATENATE <fs_batch>-vbeln '/' <fs_batch>-posnr 'E' '/' <lfs_return>-message
            INTO lv_joblog.
      WRITE lv_joblog.
    ENDIF. " IF sy-batch IS INITIAL

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
      IMPORTING
        return = lwa_return.

    IF lwa_return IS NOT INITIAL.
      IF sy-batch IS INITIAL.
        <fs_batch>-charg = lwa_bdbatch_f-charg.

        lwa_log-vbeln   = <fs_batch>-vbeln.
        lwa_log-posnr   = <fs_batch>-posnr.
        lwa_log-status  = 'E'.
        lwa_log-message = 'Changes are NOT saved'.
        APPEND lwa_log TO i_log_f.

      ELSE. " ELSE -> IF sy-batch IS INITIAL
        lwa_log-message = 'Changes are NOT saved'.
        CONCATENATE <fs_batch>-vbeln '/' <fs_batch>-posnr 'E' '/' lwa_log-message
              INTO lv_joblog.
        WRITE lv_joblog.
      ENDIF. " IF sy-batch IS INITIAL
    ENDIF. " IF lwa_return IS NOT INITIAL
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_ASSIGN_BATCHES_TO_ORDER
*&---------------------------------------------------------------------*
*&      Form  F_MATERIAL_AVAILABILITY_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_material_availability_check .


  DATA :li_log_f      TYPE TABLE OF ty_final,
        li_wmdvsx     TYPE STANDARD TABLE OF bapiwmdvs, " Structure for Simulated Reqmts - ATP Internet Information
        li_wmdvex     TYPE STANDARD TABLE OF bapiwmdve, " Results of Availability Check - ATP Info in Internet
        lwa_wmdvex    TYPE bapiwmdve,                   " Results of Availability Check - ATP Info in Internet
        lwa_vbep      TYPE ty_vbep,
        lwa_final     TYPE ty_final,
        lwa_log_f     TYPE ty_final,
        lv_dialogflag TYPE char1.                      " Dialogflag of type CHAR1

  FIELD-SYMBOLS: <lfs_batch>          TYPE ty_batch_final.

  SORT i_mcha_data BY matnr werks charg.

* Check invalid batchs and clean from the Screen.
  LOOP AT i_batch_a ASSIGNING <lfs_batch>.
    CLEAR: lv_dialogflag.
    REFRESH: li_wmdvsx,
             li_wmdvex.

    READ TABLE i_mcha_data WITH KEY matnr = <lfs_batch>-matnr
                                    werks = <lfs_batch>-werks
                                    charg = <lfs_batch>-charg BINARY SEARCH TRANSPORTING NO FIELDS .
    IF sy-subrc = 0 AND <lfs_batch>-charg IS NOT INITIAL .

      CALL FUNCTION 'BAPI_MATERIAL_AVAILABILITY'
        EXPORTING
          plant      = <lfs_batch>-werks
          material   = <lfs_batch>-matnr
          unit       = <lfs_batch>-uom
          batch      = <lfs_batch>-charg
          doc_number = <lfs_batch>-vbeln
          itm_number = <lfs_batch>-posnr
        IMPORTING
          dialogflag = lv_dialogflag
        TABLES
          wmdvsx     = li_wmdvsx
          wmdvex     = li_wmdvex.

      IF lv_dialogflag IS INITIAL .
        READ TABLE li_wmdvex INTO lwa_wmdvex INDEX 1.
        IF sy-subrc = 0.
          READ TABLE i_vbep INTO lwa_vbep WITH KEY vbeln = <lfs_batch>-vbeln
                                                   posnr = <lfs_batch>-posnr BINARY SEARCH.
          IF sy-subrc EQ 0.
            IF lwa_vbep-wmeng GT lwa_wmdvex-com_qty. "Log
              MOVE <lfs_batch>-vbeln TO lwa_final-vbeln.
              MOVE <lfs_batch>-posnr TO lwa_final-posnr.
              lwa_final-status = 'E'.
              lwa_final-message = 'Ordered Quantity exceeds available quantity'(d04).
              CONCATENATE lwa_final-message 'Batch'(t13) <lfs_batch>-charg INTO lwa_final-message SEPARATED BY space.
              APPEND lwa_final TO i_log_f.
              CLEAR <lfs_batch>-charg.
            ELSE. " ELSE -> IF lwa_vbep-wmeng GT lwa_wmdvex-com_qty
              ASSIGN <lfs_batch> TO <fs_batch>.
              PERFORM f_assign_batches_to_order.
              UNASSIGN <fs_batch>.
            ENDIF. " IF lwa_vbep-wmeng GT lwa_wmdvex-com_qty
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF lv_dialogflag IS INITIAL
    ENDIF. " IF sy-subrc = 0 AND <lfs_batch>-charg IS NOT INITIAL
  ENDLOOP . " LOOP AT i_batch_a ASSIGNING <lfs_batch>
ENDFORM. " F_MATERIAL_AVAILABILITY_CHECK

*EOC by DDWIVEDI CR#231
*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK_ORDERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_unlock_orders USING lwa_bat TYPE ty_batch_final.

  DATA:
    lv_index  TYPE sy-tabix, " Index of Internal Tables
    lwa_final TYPE ty_final,
    lwa_batch TYPE ty_batch_final.

  lwa_batch = lwa_bat.

  CALL FUNCTION 'DEQUEUE_EVVBAKE'
    EXPORTING
      vbeln = lwa_batch-vbeln.
  IF sy-subrc NE 0.
    " Sales order could not be Unlocked
    MESSAGE e000 WITH 'Sales Order could not be Unlocked'(023) INTO lwa_final-message.
    MOVE 'E'      TO lwa_final-status.
    MOVE lwa_batch-vbeln TO lwa_final-vbeln.
    MOVE lwa_batch-posnr TO lwa_final-posnr.
    APPEND lwa_final TO i_log_f.
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_UNLOCK_ORDERS
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*         MODIFYING THE SCREEN ACCORDING TO THE RADIO BUTTON SELECTED
*----------------------------------------------------------------------*
FORM f_modify_screen .

  LOOP AT SCREEN.

    IF rb_onln IS NOT INITIAL.
      IF screen-group1 = 'MI2'
*&-->Begin of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
        OR screen-group1 = 'MI3'.
*&<--End of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
*        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'MI2'
*&-->Begin of delete for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
*    ELSE. " ELSE -> IF rb_onln IS NOT INITIAL
*&<--End of delete for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
*&-->Begin of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
    ELSEIF rb_file IS NOT INITIAL.
*&<--End of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
      IF screen-group1 = 'MI1'
*&-->Begin of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
        OR screen-group1 = 'MI3'.
*&<--End of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
        screen-input = 0.
        screen-invisible = 1.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'MI1'
*&-->Begin of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
    ELSEIF rb_back IS NOT INITIAL.
      IF screen-group1 = 'MI1'
        OR screen-group1 = 'MI2'.
        screen-input = 0.
        screen-invisible = 1.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = 'MI1'
*&<--End of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
    ENDIF. " IF rb_onln IS NOT INITIAL
  ENDLOOP. " LOOP AT SCREEN
ENDFORM. " F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  F_HELP_P_PATH
*&---------------------------------------------------------------------*
*        F4 help for Presentation Server
*----------------------------------------------------------------------*
*      CHANGING fp_v_filename TYPE char1024.
*----------------------------------------------------------------------*
FORM f_help_p_path  CHANGING fp_v_filename TYPE char1024. " Help_p_path changing fp of type CHAR1024

* Local Data Declaration
  DATA: li_table  TYPE filetable,  "Internal table for file
        lwa_table TYPE file_table, "Work area
        lv_rc     TYPE i.          "Return Code

* F4 help for presentation server file path.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    CHANGING
      file_table              = li_table
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc IS INITIAL.
*   Returning back the Full File path of selected file
    READ TABLE li_table INTO lwa_table INDEX 1.
    IF sy-subrc IS INITIAL.
      fp_v_filename = lwa_table-filename.
    ENDIF. " IF sy-subrc IS INITIAL
  ELSE. " ELSE -> IF sy-subrc IS INITIAL
    MESSAGE i016. "System is not able to read the input file
  ENDIF. " IF sy-subrc IS INITIAL

ENDFORM. " F_HELP_P_PATH
**&---------------------------------------------------------------------*
**&      Form  F_HELP_AS_PATH
**&---------------------------------------------------------------------*
**    F4 help for Application Server
**----------------------------------------------------------------------*
**     -->FP_V_FILENAME  Selected File Path from Application Server
**----------------------------------------------------------------------*
*FORM f_help_as_path  CHANGING fp_v_filename TYPE localfile. " Local file for upload/download
*
** Function  module for F4 help from Application  server
*  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
*    IMPORTING
*      serverfile       = fp_v_filename
*    EXCEPTIONS
*      canceled_by_user = 1
*      OTHERS           = 2.
*  IF sy-subrc IS NOT INITIAL.
*    CLEAR fp_v_filename.
*  ENDIF. " IF sy-subrc IS NOT INITIAL
*
*ENDFORM. " F_HELP_AS_PATH
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_P_INPUTFILE
*&---------------------------------------------------------------------*
*      Validate the input file (Presentation Server)
*----------------------------------------------------------------------*
*      -->FP_P_FILE          Input File name
*----------------------------------------------------------------------*
FORM f_validate_p_inputfile  USING fp_p_file TYPE char1024. " Validate_p_inputfile us of type CHAR1024

* Local Data Declaration
  DATA: lv_result TYPE abap_bool, "return messages
        lv_file   TYPE string.    "File Name
* Changing the data type of filename variable.
  lv_file = fp_p_file.
* Checking whether the entered file name exists
  CALL METHOD cl_gui_frontend_services=>file_exist
    EXPORTING
      file                 = lv_file
    RECEIVING
      result               = lv_result
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      wrong_parameter      = 3
      not_supported_by_gui = 4
      OTHERS               = 5.
  IF sy-subrc IS INITIAL.
    IF lv_result IS INITIAL.
      MESSAGE 'Invalid file name'(065) TYPE 'E'.
    ENDIF. " IF lv_result IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL

ENDFORM. " F_VALIDATE_P_INPUTFILE
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_P_EXTENSION
*&---------------------------------------------------------------------*
*        Check the file extension
*----------------------------------------------------------------------*
*      -->FP_P_FILE        File Name
*----------------------------------------------------------------------*
FORM f_check_p_extension  USING    fp_p_file TYPE char1024. " Check_p_extension using of type CHAR1024


  IF fp_p_file IS NOT INITIAL.
    CLEAR gv_extn.
* Getting the Extension of the Filename.
    CALL FUNCTION 'ZDEV_TRINT_FILE_GET_EXTENSION'
      EXPORTING
        im_filename  = fp_p_file
        im_uppercase = c_true
      IMPORTING
        ex_extension = gv_extn.

* No need to check SY-SUBRC as no exception is raised by the FM
* and it will always return SY-SUBRC = 0.
    IF gv_extn <> c_text.
      MESSAGE e968.
    ENDIF. " IF gv_extn <> c_text
  ENDIF. " IF fp_p_file IS NOT INITIAL

ENDFORM. " F_CHECK_P_EXTENSION
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_PRES
*&---------------------------------------------------------------------*
*   Uploading the file from presentation server
*----------------------------------------------------------------------*
*      -->FP_P_FILE     Presentation File path
*      <--FP_I_INPUT[]  Input table
*----------------------------------------------------------------------*
FORM f_upload_pres  USING    fp_p_file    TYPE char1024 " Local file for upload/download
                    CHANGING fp_i_input   TYPE ty_t_input.
* Local Data Declaration
  DATA: lv_filename TYPE localfile,         " Local file for upload/download
        it_raw      TYPE truxs_t_text_data. "Raw data

  lv_filename = fp_p_file.

* Uploading the file from Presentation Server (Used as Input table)
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_line_header        = c_sep
      i_tab_raw_data       = it_raw
      i_filename           = lv_filename
    TABLES
      i_tab_converted_data = fp_i_input[]
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE i023 WITH lv_filename. "File could not be read from &
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS NOT INITIAL

ENDFORM. " F_UPLOAD_PRES
*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_EXIT
*&---------------------------------------------------------------------*
* Performing conversion exit on Material, Sales Ord, Customer & UOM
*----------------------------------------------------------------------*
*      <--FP_I_INPUT[]  Input Table
*----------------------------------------------------------------------*
FORM f_conversion_exit  CHANGING fp_i_input TYPE ty_t_input.

* Local data declaration
  FIELD-SYMBOLS: <lfs_input> TYPE ty_input.

  LOOP AT fp_i_input ASSIGNING <lfs_input>.

*   Conversion Exit to convert Sales Order into Internal Format
    PERFORM f_cov_vbeln CHANGING <lfs_input>-vbeln.
*   Conversion Exit to convert Material number into Internal Format
    PERFORM f_cov_matnr CHANGING <lfs_input>-matnr.
*   Conversion Exit to convert Customer number into Internal Format
    PERFORM f_cov_kunnr CHANGING <lfs_input>-kunnr.
  ENDLOOP. " LOOP AT fp_i_input ASSIGNING <lfs_input>

ENDFORM. " F_CONVERSION_EXIT
*&---------------------------------------------------------------------*
*&      Form  F_COV_VBELN
*&---------------------------------------------------------------------*
*  Performing conversion exit on Sales Document number
*----------------------------------------------------------------------*
*      <--FP_V_VBELN   Sales Document number
*----------------------------------------------------------------------*
FORM f_cov_vbeln  CHANGING fp_v_vbeln TYPE vbeln. " Material Number.

* Sales Document number if filled up, then applying conversion exit to transform
* input Sales Document number in its internal format.
  IF fp_v_vbeln IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = fp_v_vbeln
      IMPORTING
        output = fp_v_vbeln.
    IF sy-subrc <> 0.
*     If conversion fails, then clearing the Sales Document number
      CLEAR fp_v_vbeln.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF fp_v_vbeln IS NOT INITIAL

ENDFORM. " F_COV_VBELN
*&---------------------------------------------------------------------*
*&      Form  F_COV_MATNR
*&---------------------------------------------------------------------*
*       Performing conversion exit on material number
*----------------------------------------------------------------------*
*    <--FP_V_MATNR   Material Number
*----------------------------------------------------------------------*
FORM f_cov_matnr  CHANGING fp_v_matnr TYPE matnr. " Material Number
* Material if filled up, then applying conversion exit to transform
* input material number in its internal format.
  IF fp_v_matnr IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input        = fp_v_matnr
      IMPORTING
        output       = fp_v_matnr
      EXCEPTIONS
        length_error = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
*     If conversion fails, then clearing the material
      CLEAR fp_v_matnr.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF fp_v_matnr IS NOT INITIAL

ENDFORM. " F_COV_MATNR
*&---------------------------------------------------------------------*
*&      Form  F_COV_KUNNR
*&---------------------------------------------------------------------*
*    Performing conversion exit on Customer
*----------------------------------------------------------------------*
*       <--FP_V_KUNNR   Customer Number
*----------------------------------------------------------------------*
FORM f_cov_kunnr  CHANGING fp_v_kunnr TYPE kunnr. " Material Number

* Customer number if filled up, then applying conversion exit to transform
* input Customer number in its internal format.
  IF fp_v_kunnr IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = fp_v_kunnr
      IMPORTING
        output = fp_v_kunnr.
    IF sy-subrc <> 0.
*     If conversion fails, then clearing the Customer number
      CLEAR fp_v_kunnr.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF fp_v_kunnr IS NOT INITIAL

ENDFORM. " F_COV_KUNNR
*&---------------------------------------------------------------------*
*&      Form  F_COV_AUART
*&---------------------------------------------------------------------*
*      Performing conversion exit on Sales Document Type
*----------------------------------------------------------------------*
*      <--FP_V_AUART  Sales Document Type
*----------------------------------------------------------------------*
FORM f_cov_auart  CHANGING fp_v_auart TYPE auart. " Sales Document Type

* Sales Document Type if filled up, then applying conversion exit to transform
* input Sales Document Type in its internal format.
  IF fp_v_auart IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_AUART_INPUT'
      EXPORTING
        input  = fp_v_auart
      IMPORTING
        output = fp_v_auart.

    IF sy-subrc <> 0.
*     If conversion fails, then clearing the Sales Document Type
      CLEAR fp_v_auart.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF fp_v_auart IS NOT INITIAL


ENDFORM. " F_COV_AUART
*&---------------------------------------------------------------------*
*&      Form  F_COV_MEINS
*&---------------------------------------------------------------------*
*     Conversion for UOM into internal format
*----------------------------------------------------------------------*
*       <--P_<LFS_INPUT>_MEINS  Base Unit of Measure
*----------------------------------------------------------------------*
FORM f_cov_meins  CHANGING fp_v_meins TYPE  meins. " Base Unit of Measure

  IF fp_v_meins IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input          = fp_v_meins
      IMPORTING
        output         = fp_v_meins
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF fp_v_meins IS NOT INITIAL

ENDFORM. " F_COV_MEINS
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION
*&---------------------------------------------------------------------*
*      Subroutine to validate the input data coming from file
*----------------------------------------------------------------------*
FORM f_validation .

*&--Structure Declaration.
  TYPES: BEGIN OF lty_matnr,
           matnr TYPE matnr,         " Material Number
           werks TYPE werks_d,       " Plant
           charg TYPE charg_d,       " Batch Number
           vfdat TYPE vfdat,         " Shelf Life Expiration or Best-Before Date
         END OF lty_matnr,


         BEGIN OF lty_vkorg,
           vkorg TYPE vkorg,         " Sales Organization
         END OF lty_vkorg,

         BEGIN OF lty_vtweg,
           vtweg TYPE vtweg,         " Distribution Channel
         END OF lty_vtweg,

         BEGIN OF lty_werks,
           werks TYPE werks_d,       " Plant
         END OF lty_werks,

         BEGIN OF lty_marc,
           matnr TYPE matnr,      " Material
           werks TYPE marc-werks, " Plant
           lvorm TYPE lvowk,      " Material for Deletion at Plant Level
         END OF lty_marc,

         BEGIN OF lty_mara,
           matnr TYPE matnr,         " Material Number
         END OF lty_mara,

         BEGIN OF lty_vbep,
           vbeln TYPE vbeln,         " Sales and Distribution Document Number
           posnr TYPE posnr,         " Item number of the SD document
           etenr TYPE etenr,         " Delivery Schedule Line Number
           edatu TYPE edatu,         " Schedule line date
           wmeng TYPE wmeng,         " Order quantity in sales units
           lmeng TYPE lmeng,         " Required quantity for mat.management in stockkeeping units
           mbuhr TYPE mbuhr,         " Material Staging Time (Local, Relating to a Plant)
         END OF  lty_vbep,

         BEGIN OF lty_vbbe,
           vbeln TYPE vbeln,         " Sales and Distribution Document Number
           posnr TYPE posnr,         " Item number of the SD document
           etenr TYPE etenr,         " Delivery Schedule Line Number
           mbdat TYPE mbdat,         " Material Staging/Availability Date
           omeng TYPE omeng,         " Open Qty in Stockkeeping Units for Transfer of Reqmts to MRP
           meins TYPE meins,         " Base Unit of Measure
           auart TYPE auart,         " Sales Document Type
         END OF lty_vbbe,

*&--Table Types Declarations
         lty_t_marc  TYPE STANDARD TABLE OF lty_marc,  "Material Plant validation
         lty_t_werks TYPE STANDARD TABLE OF lty_werks, "Plant Validation
         lty_t_vtweg TYPE STANDARD TABLE OF lty_vtweg, "Distribution channel validation
         lty_t_vkorg TYPE STANDARD TABLE OF lty_vkorg, "Sales Org validation
         lty_t_mara  TYPE STANDARD TABLE OF lty_mara,  "Material validation
         lty_t_vbep  TYPE STANDARD TABLE OF lty_vbep,
         lty_t_matnr TYPE STANDARD TABLE OF lty_matnr. "Material / Plant / Batch combination


*&--Local Work Area and Internal  table declarations
  DATA: lwa_input        TYPE ty_input,                    " Input WorkArea
        lwa_matnr        TYPE lty_matnr,
        lwa_vkorg        TYPE lty_vkorg,
        lwa_vtweg        TYPE lty_vtweg,
        lwa_vbap         TYPE ty_vbap,
        lwa_kunnr        TYPE ty_kna1,
        li_kunnr         TYPE STANDARD TABLE OF ty_kna1,
        li_kna1_val      TYPE STANDARD TABLE OF ty_kna1,
        li_vbap          TYPE STANDARD TABLE OF ty_vbap,
        li_vtweg         TYPE lty_t_vtweg,
        li_vtweg_val     TYPE lty_t_vtweg,
        li_vkorg         TYPE lty_t_vkorg,
        li_vkorg_val     TYPE lty_t_vkorg,
        li_matnr         TYPE lty_t_matnr,
        li_matnr_val     TYPE lty_t_matnr,
        lwa_vbcom        TYPE vbcom,                       " Communication Work Area for Sales Doc.Access Methods
        li_lseltab       TYPE TABLE OF rkask,              " Table of selection criteria
        li_lvbmtv        TYPE TABLE OF vbmtv,              " View: Order Items for Material
        li_vbbe          TYPE TABLE OF lty_vbbe,
        lwa_vbbe         TYPE lty_vbbe,
        lwa_final        TYPE ty_log_char,
        lwa_werks        TYPE lty_werks,
        li_werks_val     TYPE lty_t_werks,
        li_werks         TYPE lty_t_werks,
        lwa_marc         TYPE lty_marc,
        li_marc          TYPE lty_t_marc,
        li_marc_val      TYPE lty_t_marc,
        lwa_mara         TYPE lty_mara,
        li_mara          TYPE lty_t_mara,
        li_mara_val      TYPE lty_t_mara,
        lwa_mara_val     TYPE lty_mara,
        li_vbep          TYPE lty_t_vbep,
        lwa_vbep         TYPE ty_vbep,
        lv_dialogflag    TYPE char1,                       " Dialogflag of type CHAR1
        li_wmdvsx        TYPE STANDARD TABLE OF bapiwmdvs, " Structure for Simulated Reqmts - ATP Internet Information
        li_wmdvex        TYPE STANDARD TABLE OF bapiwmdve, " Results of Availability Check - ATP Info in Internet
        lwa_wmdvex       TYPE bapiwmdve,                   " Results of Availability Check - ATP Info in Internet
        lv_error_flg     TYPE flag,                        " General Flag
        lv_req_date      TYPE sy-datum,                    " Current Date of Application Server
        li_req_date      TYPE STANDARD TABLE OF selopt,    " Transfer Structure for Select Options
        lwa_final_output TYPE ty_input,
        lv_posnr         TYPE posnr_va,                    " Sales Document Item
        lwa_date         TYPE selopt,                      " Transfer Structure for Select Options
        lwa_log_char     TYPE ty_log_char,
        lv_date_int      TYPE char2,                       " Date_int(2) of type Numeric Text Fields
        lv_rest          TYPE char8,                       " Rest of type CHAR8
        lv_year          TYPE char4,                       " Year of type CHAR4
        lwa_qty_avail    TYPE ty_qty_avail,
        lv_month_int     TYPE char2.                       " Month_int(2) of type Numeric Text Fields

*&--Field symbols
  FIELD-SYMBOLS: <lfs_input>     TYPE ty_input, " Field symbols
                 <lfs_qty_avail> TYPE ty_qty_avail.

  CONSTANTS: lc_0 TYPE char1 VALUE '0'. " 0 of type CHAR1


  LOOP AT i_input ASSIGNING <lfs_input>.
*&--Appending material , plant and batch value.
    lwa_matnr-werks = <lfs_input>-werks.
    lwa_matnr-matnr = <lfs_input>-matnr.
    lwa_matnr-charg = <lfs_input>-charg.
    APPEND lwa_matnr TO li_matnr[].
    CLEAR lwa_matnr.

*Appending material number
    lwa_mara-matnr = <lfs_input>-matnr.
    APPEND lwa_mara TO li_mara[].
    CLEAR lwa_mara.

*&--Appending Plant
    lwa_werks-werks  = <lfs_input>-werks.
    APPEND lwa_werks TO li_werks[].
    CLEAR lwa_werks.

* Appending material and plant value
    lwa_marc-matnr = <lfs_input>-matnr.
    lwa_marc-werks = <lfs_input>-werks.
    APPEND lwa_marc TO li_marc[].
    CLEAR lwa_marc.

    lwa_vbcom-werks = <lfs_input>-werks.

*&--Appending Sales Org
    lwa_vkorg-vkorg = <lfs_input>-vkorg.
    APPEND lwa_vkorg TO li_vkorg[].
    CLEAR lwa_vkorg.

*&--Appending Distribution channel
    lwa_vtweg-vtweg = <lfs_input>-vtweg.
    APPEND lwa_vtweg TO li_vtweg[].
    CLEAR lwa_vtweg.

*&--Appending Document number
    lwa_vbap-vbeln = <lfs_input>-vbeln.
    lwa_vbap-posnr = <lfs_input>-posnr.
    APPEND lwa_vbap TO li_vbap[].
    CLEAR lwa_vbap.

*&--Appending Customer Number
    lwa_kunnr-kunnr = <lfs_input>-kunnr.
    APPEND lwa_kunnr TO li_kunnr[].
    CLEAR lwa_kunnr.

**&--Appending Document type
*    lwa_auart-auart = <lfs_input>-auart.
*    APPEND lwa_auart TO li_auart[].
*    CLEAR lwa_auart.

* Append Requirement dates to Range table
*    CONCATENATE <lfs_input>-edatu+6(4) <lfs_input>-edatu+3(2) <lfs_input>-edatu(2) INTO lv_req_date.
    SPLIT <lfs_input>-edatu AT '/' INTO lv_date_int lv_rest.
    IF sy-subrc <> 0.
      SPLIT <lfs_input>-edatu AT '-' INTO lv_date_int lv_rest.
    ENDIF. " IF sy-subrc <> 0
    IF strlen( lv_date_int ) EQ 1.
      CONCATENATE lc_0 lv_date_int INTO lv_date_int.
    ENDIF. " IF strlen( lv_date_int ) EQ 1
    SPLIT lv_rest AT '/' INTO lv_month_int lv_year.
    IF sy-subrc <> 0.
      SPLIT lv_rest AT '-' INTO lv_month_int lv_year.
    ENDIF. " IF sy-subrc <> 0
    IF strlen( lv_month_int ) EQ 1.
      CONCATENATE lc_0 lv_month_int INTO lv_month_int.
    ENDIF. " IF strlen( lv_month_int ) EQ 1
    CLEAR lv_req_date.

    CONCATENATE lv_year lv_date_int lv_month_int INTO lv_req_date.
    lwa_date-sign = 'I'.
    lwa_date-option = 'EQ'.
    lwa_date-low = lv_req_date.
    APPEND lwa_date TO li_req_date.
    CLEAR lwa_date.
  ENDLOOP. " LOOP AT i_input ASSIGNING <lfs_input>

  IF li_matnr[] IS NOT INITIAL.
*& MAterial * Plant & batch combine validation
    SELECT matnr " Material Number
           werks " Plant
           charg " Batch Number
           vfdat " Shelf Life Expiration or Best-Before Date
      FROM mcha  " Batch Stocks
      INTO TABLE li_matnr_val[]
      FOR ALL ENTRIES IN li_matnr[]
      WHERE matnr  EQ li_matnr-matnr
      AND   werks  EQ li_matnr-werks
      AND   charg  EQ li_matnr-charg.

    IF sy-subrc IS INITIAL.
      SORT li_matnr_val BY matnr werks charg.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_matnr[] IS NOT INITIAL

*validating material from mara table
  IF li_mara[] IS NOT INITIAL.
    SELECT matnr " Material Number
      FROM mara  " General Material Data
      INTO TABLE li_mara_val[]
      FOR ALL ENTRIES IN li_mara[]
      WHERE matnr EQ li_mara-matnr.
    IF sy-subrc IS INITIAL.
      SORT li_mara_val BY matnr.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_mara[] IS NOT INITIAL

  IF li_vkorg[] IS NOT INITIAL.
*&--Validating Sales Org
    SELECT vkorg " Sales Organization
     FROM  tvko  " Organizational Unit: Sales Organizations
     INTO TABLE li_vkorg_val
     FOR ALL ENTRIES IN li_vkorg[]
      WHERE vkorg EQ li_vkorg-vkorg.

    IF sy-subrc IS INITIAL.
      SORT li_vkorg_val[] BY vkorg.
    ENDIF. " IF sy-subrc IS INITIAL

  ENDIF. " IF li_vkorg[] IS NOT INITIAL

  IF li_vtweg[] IS NOT INITIAL.
*&--Validation Sales Distribution
    SELECT vtweg " Distribution Channel
      FROM tvtw  " Organizational Unit: Distribution Channels
      INTO TABLE li_vtweg_val[]
      FOR ALL ENTRIES IN li_vtweg[]
      WHERE vtweg EQ li_vtweg-vtweg.

    IF sy-subrc IS INITIAL.
      SORT li_vtweg_val BY vtweg.
    ENDIF. " IF sy-subrc IS INITIAL

  ENDIF. " IF li_vtweg[] IS NOT INITIAL

*  IF li_vbeln[] IS NOT INITIAL.
  IF li_vbap[] IS NOT INITIAL.
*&--Validation Document Number
    SELECT vbeln " Sales Document
           posnr " Sales Document Item
           mtvfp " Checking Group for Availability Check
           mvgr2 " Material group 2
           bedae " Requirements type
      FROM vbap  " Sales Document: Item Data
      INTO TABLE i_vbap_val[]
      FOR ALL ENTRIES IN li_vbap
      WHERE vbeln EQ li_vbap-vbeln
      AND   posnr EQ li_vbap-posnr.

    IF sy-subrc IS INITIAL.
      SORT i_vbap_val BY vbeln posnr.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_vbap[] IS NOT INITIAL

*&--Fetching records from VBEP
  IF i_vbap_val[] IS NOT INITIAL.
    SELECT vbeln " Sales Document
           posnr " Sales Document Item
           etenr " Delivery Schedule Line Number
           edatu " Schedule line date
           wmeng " Order quantity in sales units
           lmeng " Required quantity for mat.management in stockkeeping units
           mbuhr " Material Staging Time (Local, Relating to a Plant)
      FROM vbep  " Sales Document: Schedule Line Data
      INTO TABLE i_vbep
   FOR ALL ENTRIES IN i_vbap_val
     WHERE vbeln = i_vbap_val-vbeln
      AND posnr = i_vbap_val-posnr
      AND etenr = '0001'
      AND  edatu IN li_req_date.
    IF sy-subrc IS INITIAL.
      SORT i_vbep BY vbeln posnr.
    ENDIF. " IF sy-subrc IS INITIAL

  ENDIF. " IF i_vbap_val[] IS NOT INITIAL
  IF li_kunnr[] IS NOT INITIAL.
*&--Validation of Customer Number
    SELECT kunnr " Customer Number
*           loevm
           land1 " Country Key
           ort01 " City
           pstlz " Postal Code
      FROM kna1  " General Data in Customer Master
*      INTO TABLE li_kna1_val[]
      INTO TABLE i_kna1_val[]
      FOR ALL ENTRIES IN li_kunnr
      WHERE kunnr EQ li_kunnr-kunnr
      AND   loevm = space.

    IF sy-subrc IS INITIAL.
*      DELETE i_kna1_val WHERE loevm = abap_true.
*      IF i_kna1_val IS NOT INITIAL.
      SORT i_kna1_val BY kunnr.
*      ENDIF. " IF li_kna1_val IS NOT INITIAL
    ENDIF. " IF sy-subrc IS INITIAL

  ENDIF. " IF li_kunnr[] IS NOT INITIAL

*  IF li_auart[] IS NOT INITIAL.
**&--Validation of Sales Document type
*    SELECT auart " Sales Document Type
*      FROM tvak  " Sales Document Types
*      INTO TABLE li_auart_val[]
*      FOR ALL ENTRIES IN li_auart
*      WHERE auart EQ li_auart-auart.
*
*    IF sy-subrc IS INITIAL.
*      SORT li_auart_val BY auart.
*    ENDIF. " IF sy-subrc IS INITIAL
*  ENDIF. " IF li_auart[] IS NOT INITIAL

*validating Plant from T001w
  IF li_werks[] IS NOT INITIAL.
    SELECT werks " Plant
      FROM t001w " Plants/Branches
      INTO TABLE li_werks_val[]
      FOR ALL ENTRIES IN li_werks
      WHERE werks EQ li_werks-werks.
    IF sy-subrc IS INITIAL.
      SORT li_werks_val BY werks.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_werks[] IS NOT INITIAL

* Material Plant Validation
  IF li_marc[] IS NOT INITIAL.
    SELECT matnr " Material Number
           werks " Plant
           lvorm " Flag Material for Deletion at Plant Level
      FROM marc  " Plant Data for Material
      INTO TABLE li_marc_val
       FOR ALL ENTRIES IN li_marc
     WHERE matnr EQ li_marc-matnr
       AND werks EQ li_marc-werks.

    IF sy-subrc = 0.
      DELETE li_marc_val WHERE lvorm = abap_true.
      IF li_marc_val IS NOT INITIAL.
        SORT li_marc_val BY matnr werks.
      ENDIF. " IF li_marc_val IS NOT INITIAL
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_marc[] IS NOT INITIAL

*&--Logic to fetch UOM based on the initial logic.

  lwa_vbcom-zuart     = 'A'.
  lwa_vbcom-trvog     = '0'.
  lwa_vbcom-stat_dazu = 'X'.
  lwa_vbcom-name_dazu = 'X'.
  lwa_vbcom-kopf_dazu = 'X'.
  lwa_vbcom-vboff     = 'X'.


  LOOP AT li_mara_val INTO lwa_mara_val.
    lwa_vbcom-matnr = lwa_mara_val-matnr.
    CALL FUNCTION 'RV_SALES_DOCUMENT_VIEW_3'
      EXPORTING
        vbcom   = lwa_vbcom
      TABLES
        lvbmtv  = li_lvbmtv
        lseltab = i_lseltab.

    IF li_lvbmtv IS NOT INITIAL.
      APPEND LINES OF li_lvbmtv TO i_lvbmtv.
    ENDIF. " IF li_lvbmtv IS NOT INITIAL
    REFRESH: li_lvbmtv.
  ENDLOOP. " LOOP AT li_mara_val INTO lwa_mara_val

  IF i_lvbmtv IS NOT INITIAL.
    SELECT vbeln posnr etenr mbdat
           omeng meins auart
             FROM vbbe " Sales Requirements: Individual Records
             INTO TABLE li_vbbe
             FOR ALL ENTRIES IN i_lvbmtv
             WHERE vbeln = i_lvbmtv-vbeln AND
                   posnr = i_lvbmtv-posnr AND
                   etenr = '0001'.
    SORT li_vbbe BY vbeln posnr.

  ENDIF. " IF i_lvbmtv IS NOT INITIAL

*-------------------------- MAIN LOOP -------------------------------*

  IF i_vbap_val IS NOT INITIAL.
    SELECT * FROM t459a " External requirements types
             INTO TABLE i_t459a
             FOR ALL ENTRIES IN i_vbap_val
             WHERE bedae EQ i_vbap_val-bedae.
  ENDIF. " IF i_vbap_val IS NOT INITIAL
  IF sy-subrc IS INITIAL.
    SORT i_t459a BY bedae.
  ENDIF. " IF sy-subrc IS INITIAL

  LOOP AT i_input ASSIGNING <lfs_input>.
    CLEAR: lv_error_flg.
* Sales Order validation
    READ TABLE i_vbap_val TRANSPORTING NO FIELDS
      WITH KEY vbeln = <lfs_input>-vbeln
               posnr = <lfs_input>-posnr
               BINARY SEARCH.
    IF sy-subrc <> 0.
*&--Populate the error flag
      lv_error_flg = abap_true.
*&--Populate the log table
      MOVE <lfs_input>-vbeln TO lwa_final-vbeln.
      MOVE <lfs_input>-posnr TO lwa_final-posnr.
      lwa_final-status = 'E'.
      lwa_final-message = 'Sales Order/Item No is not valid'.
*      APPEND lwa_final TO i_log_f.
      APPEND lwa_final TO i_log_char.
      CLEAR lwa_final.
    ENDIF. " IF sy-subrc <> 0

*&--Material Validation
    READ TABLE li_mara_val TRANSPORTING NO FIELDS
     WITH KEY matnr = <lfs_input>-matnr
              BINARY SEARCH.
    IF sy-subrc <> 0.
*&--Populate the error flag
      lv_error_flg = abap_true.
*&--Populate the log table
      MOVE <lfs_input>-vbeln TO lwa_final-vbeln.
      MOVE <lfs_input>-posnr TO lwa_final-posnr.
      lwa_final-status = 'E'.
*      lwa_final-message = 'Material is blank in file'.
      lwa_final-message = 'Material provided is  file is blank/invalid'.
*      APPEND lwa_final TO i_log_f.
      APPEND lwa_final TO i_log_char.
      CLEAR lwa_final.
    ENDIF. " IF sy-subrc <> 0

*Plant Validation****************************
    IF <lfs_input>-werks IS NOT INITIAL.
      READ TABLE li_werks_val TRANSPORTING NO FIELDS
       WITH KEY werks = <lfs_input>-werks
        BINARY SEARCH.
      IF sy-subrc <> 0.
*&--Populate the error flag
        lv_error_flg = abap_true.
*&--Populate the log table
        MOVE <lfs_input>-vbeln TO lwa_final-vbeln.
        MOVE <lfs_input>-posnr TO lwa_final-posnr.
        lwa_final-status = 'E'.
        lwa_final-message = 'Plant does not exist'.
*      APPEND lwa_final TO i_log_f.
        APPEND lwa_final TO i_log_char.
        CLEAR lwa_final.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF <lfs_input>-werks IS NOT INITIAL

*Material Plant Validation
    READ TABLE li_marc_val TRANSPORTING NO FIELDS
     WITH KEY matnr = <lfs_input>-matnr
              werks = <lfs_input>-werks
              BINARY SEARCH.
    IF sy-subrc <> 0.
*&--Populate the error flag
      lv_error_flg = abap_true.
*&--Populate the log table
      MOVE <lfs_input>-vbeln TO lwa_final-vbeln.
      MOVE <lfs_input>-posnr TO lwa_final-posnr.
      lwa_final-status = 'E'.
      lwa_final-message = 'Material is not maintained in Plant'.
*      APPEND lwa_final TO i_log_f.
      APPEND lwa_final TO i_log_char.
      CLEAR lwa_final.
    ENDIF. " IF sy-subrc <> 0

* Customer Validation
    READ TABLE i_kna1_val TRANSPORTING NO FIELDS
      WITH KEY kunnr = <lfs_input>-kunnr
       BINARY SEARCH.
    IF sy-subrc <> 0.
*&--Populate the error flag
      lv_error_flg = abap_true.
*&--Populate the log table
      MOVE <lfs_input>-vbeln TO lwa_final-vbeln.
      MOVE <lfs_input>-posnr TO lwa_final-posnr.
      lwa_final-status = 'E'.
*      lwa_final-message = 'Customer is blank in file'.
      lwa_final-message = 'Customer provided in file is blank/invalid'.
*      APPEND lwa_final TO i_log_f.
      APPEND lwa_final TO i_log_char.
      CLEAR lwa_final.
    ENDIF. " IF sy-subrc <> 0

* Sales Org Validation
    READ TABLE li_vkorg_val TRANSPORTING NO FIELDS
      WITH KEY vkorg = <lfs_input>-vkorg
       BINARY SEARCH.
    IF sy-subrc <> 0.
*&--Populate the error flag
      lv_error_flg = abap_true.
*&--Populate the log table
      MOVE <lfs_input>-vbeln TO lwa_final-vbeln.
      MOVE <lfs_input>-posnr TO lwa_final-posnr.
      lwa_final-status = 'E'.
*      lwa_final-message = 'Customer is blank in file'.
      lwa_final-message = 'Sales Org in file is blank/invalid'.
*      APPEND lwa_final TO i_log_f.
      APPEND lwa_final TO i_log_char.
      CLEAR lwa_final.
    ENDIF. " IF sy-subrc <> 0

*&--Distribution Channel
    READ TABLE li_vtweg_val TRANSPORTING NO FIELDS
      WITH  KEY vtweg = <lfs_input>-vtweg
       BINARY SEARCH.
    IF sy-subrc <> 0.
*&--Populate the error flag
      lv_error_flg = abap_true.
*&--Populate the log table
      MOVE <lfs_input>-vbeln TO lwa_final-vbeln.
      MOVE <lfs_input>-posnr TO lwa_final-posnr.
      lwa_final-status = 'E'.
*      lwa_final-message = 'Distribution channel is blank in file'.
      lwa_final-message = 'Distribution channel in file is blank/invalid'.
*      APPEND lwa_final TO i_log_f.
      APPEND lwa_final TO i_log_char.
      CLEAR lwa_final.
    ENDIF. " IF sy-subrc <> 0

* Requirement Date Validation assuming DD-MM-YYYY format
    IF <lfs_input>-edatu IS INITIAL.
*&--Populate the error flag
      lv_error_flg = abap_true.
*&--Populate the log table
      MOVE <lfs_input>-vbeln TO lwa_final-vbeln.
      MOVE <lfs_input>-posnr TO lwa_final-posnr.
      lwa_final-status = 'E'.
      lwa_final-message = 'Req. Delivery Date is blank in file'.
*      APPEND lwa_final TO i_log_f.
      APPEND lwa_final TO i_log_char.
      CLEAR lwa_final.

    ELSE. " ELSE -> IF <lfs_input>-edatu IS INITIAL
*      lv_date_int = <lfs_input>-edatu(2).
*      lv_month_int = <lfs_input>-edatu+2(2).

      SPLIT <lfs_input>-edatu AT '/' INTO lv_date_int lv_rest.
      IF sy-subrc <> 0.
        SPLIT <lfs_input>-edatu AT '-' INTO lv_date_int lv_rest.
      ENDIF. " IF sy-subrc <> 0
      IF strlen( lv_date_int ) EQ 1.
        CONCATENATE lc_0 lv_date_int INTO lv_date_int.
      ENDIF. " IF strlen( lv_date_int ) EQ 1
      SPLIT lv_rest AT '/' INTO lv_month_int lv_year.
      IF sy-subrc <> 0.
        SPLIT lv_rest AT '-' INTO lv_month_int lv_year.
      ENDIF. " IF sy-subrc <> 0
      IF strlen( lv_month_int ) EQ 1.
        CONCATENATE lc_0 lv_month_int INTO lv_month_int.
      ENDIF. " IF strlen( lv_month_int ) EQ 1
      CLEAR lv_req_date.

*      CONCATENATE <lfs_input>-edatu+5(4) lv_month_int lv_date_int INTO lv_req_date.
      CONCATENATE lv_year lv_date_int lv_month_int INTO lv_req_date.
* Check the date validity
      CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
        EXPORTING
          date                      = lv_req_date
        EXCEPTIONS
          plausibility_check_failed = 1
          OTHERS                    = 2.

      IF sy-subrc <> 0.
*&--Populate the error flag
        lv_error_flg = abap_true.
*&--Populate the log table
        MOVE <lfs_input>-vbeln TO lwa_final-vbeln.
        MOVE <lfs_input>-posnr TO lwa_final-posnr.
        lwa_final-status = 'E'.
        lwa_final-message = 'Req. Delivery Date is not in correct format'.
*      APPEND lwa_final TO i_log_f.
        APPEND lwa_final TO i_log_char.
        CLEAR lwa_final.

      ELSE. " ELSE -> IF sy-subrc <> 0
* IF date format is correct, check if req delv date is within expiration date
        READ TABLE li_matnr_val INTO lwa_matnr
          WITH KEY matnr = <lfs_input>-matnr
                   werks = <lfs_input>-werks
                   charg = <lfs_input>-charg
          BINARY SEARCH.
        IF sy-subrc = 0 AND lwa_matnr-vfdat IS NOT INITIAL.
          IF lv_req_date GT lwa_matnr-vfdat.
*&--Populate the error flag
            lv_error_flg = abap_true.
*&--Populate the log table
            MOVE <lfs_input>-vbeln TO lwa_final-vbeln.
            MOVE <lfs_input>-posnr TO lwa_final-posnr.
            lwa_final-status = 'E'.
            lwa_final-message = 'Req. Delivery Date is greater than Expiry Date'.
*      APPEND lwa_final TO i_log_f.
            APPEND lwa_final TO i_log_char.
            CLEAR lwa_final.
          ENDIF. " IF lv_req_date GT lwa_matnr-vfdat
          CLEAR: lwa_matnr,
                 lv_req_date.
        ENDIF. " IF sy-subrc = 0 AND lwa_matnr-vfdat IS NOT INITIAL
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF <lfs_input>-edatu IS INITIAL

* Batch Number
* Case I : Batch number not provided in input file => Do nothing
* Case II: Batch number provided in input file
    IF <lfs_input>-charg IS NOT INITIAL.
*-- Batch number validation
*    PERFORM f_validate_batches.
* Check invalid batchs and clean from the Screen.
      READ TABLE li_matnr_val TRANSPORTING NO FIELDS
         WITH KEY matnr = <lfs_input>-matnr
                  werks = <lfs_input>-werks
                  charg = <lfs_input>-charg
          BINARY SEARCH.
      IF sy-subrc <> 0 AND <lfs_input>-charg IS NOT INITIAL.
*&--Populate the error flag
        lv_error_flg = abap_true.
*&--*   Append record to Log and clear Batch
        MOVE <lfs_input>-vbeln TO lwa_final-vbeln.
        MOVE <lfs_input>-posnr TO lwa_final-posnr.
        lwa_final-status = 'E'.
        CONCATENATE 'Invalid Batch'(d00) <lfs_input>-charg
                    'for Material'(d05) <lfs_input>-matnr
                    'and Plant'(d06) <lfs_input>-werks
           INTO  lwa_final-message SEPARATED BY space.
*      APPEND lwa_final TO i_log_f.
        APPEND lwa_final TO i_log_char.
        CLEAR lwa_final.
      ELSE. " ELSE -> IF sy-subrc <> 0 AND <lfs_input>-charg IS NOT INITIAL
        IF <lfs_input>-charg IS NOT INITIAL.
          lv_posnr = <lfs_input>-posnr.
          READ TABLE li_vbbe INTO lwa_vbbe
                        WITH KEY vbeln = <lfs_input>-vbeln
                                 posnr = <lfs_input>-posnr
                                 BINARY SEARCH.
          IF sy-subrc EQ 0.
            gv_uom   = lwa_vbbe-meins.
          ENDIF. " IF sy-subrc EQ 0
*** BOC By ASK for Defect 6886
          READ TABLE i_qty_avail ASSIGNING  <lfs_qty_avail>
                                 WITH KEY matnr = <lfs_input>-matnr
                                          werks = <lfs_input>-werks
                                          charg = <lfs_input>-charg.
          IF sy-subrc NE 0.
            CLEAR : li_wmdvsx,li_wmdvex.
*** EOC By ASK for Defect 6886
            CALL FUNCTION 'BAPI_MATERIAL_AVAILABILITY'
              EXPORTING
                plant      = <lfs_input>-werks
                material   = <lfs_input>-matnr
                unit       = gv_uom
                check_rule = 'A'
                batch      = <lfs_input>-charg
*               doc_number = <lfs_input>-vbeln
*               itm_number = lv_posnr "<lfs_input>-posnr
              IMPORTING
                dialogflag = lv_dialogflag
              TABLES
                wmdvsx     = li_wmdvsx
                wmdvex     = li_wmdvex.

*            IF rb_post IS INITIAL. "++SMUKHEr4
            IF lv_dialogflag IS INITIAL.
              READ TABLE li_wmdvex INTO lwa_wmdvex INDEX 1.
              IF sy-subrc IS INITIAL.
*** BOC By ASK for Defect 6886
                CLEAR lwa_qty_avail.
* Populate Available qty internal table
                lwa_qty_avail-matnr = <lfs_input>-matnr.
                lwa_qty_avail-werks = <lfs_input>-werks.
                lwa_qty_avail-charg = <lfs_input>-charg.
                lwa_qty_avail-wmeng = lwa_wmdvex-com_qty.
                APPEND lwa_qty_avail TO i_qty_avail.
*** EOC By ASK for Defect 6886
                READ TABLE i_vbep INTO lwa_vbep WITH KEY vbeln = <lfs_input>-vbeln
                                                     posnr = <lfs_input>-posnr BINARY SEARCH.
                IF sy-subrc IS INITIAL.
                  IF lwa_vbep-wmeng GT lwa_wmdvex-com_qty.
                    lv_error_flg = abap_true.
                    MOVE <lfs_input>-vbeln TO lwa_final-vbeln.
                    MOVE <lfs_input>-posnr TO lwa_final-posnr.
                    lwa_final-status = 'E'.
                    lwa_final-message = 'Ordered Quantity exceeds available quantity'(d04).
                    CONCATENATE lwa_final-message 'Batch'(t13) <lfs_input>-charg INTO lwa_final-message SEPARATED BY space.
*      APPEND lwa_final TO i_log_f.
                    APPEND lwa_final TO i_log_char.
                    CLEAR lwa_final.
                    CLEAR: <lfs_input>-charg,
                           <lfs_input>-vbeln.
*&++SMUKHER4
                  ELSE. " ELSE -> IF lwa_vbep-wmeng GT lwa_wmdvex-com_qty
*** BOC By ASK for Defect 6886
* Take down the qty assigned.
                    READ TABLE i_qty_avail ASSIGNING  <lfs_qty_avail>
                       WITH KEY matnr = <lfs_input>-matnr
                                werks = <lfs_input>-werks
                                charg = <lfs_input>-charg.
                    IF sy-subrc = 0.
                      <lfs_qty_avail>-wmeng = <lfs_qty_avail>-wmeng - lwa_vbep-wmeng.
                    ENDIF. " IF sy-subrc = 0

**  EOC by ASK for Defect 6886
                    MOVE <lfs_input>-vbeln TO lwa_final-vbeln.
                    MOVE <lfs_input>-posnr TO lwa_final-posnr.
                    lwa_final-status = 'S'.
                    lwa_final-message = 'Ordered Quantity can be assigned'(d07).
                    CONCATENATE lwa_final-message 'Batch'(t13) <lfs_input>-charg INTO lwa_final-message SEPARATED BY space.
*      APPEND lwa_final TO i_log_f.
                    APPEND lwa_final TO i_log_char.
                    CLEAR lwa_final.


                  ENDIF. " IF lwa_vbep-wmeng GT lwa_wmdvex-com_qty

                ENDIF. " IF sy-subrc IS INITIAL

              ENDIF. " IF sy-subrc IS INITIAL

            ENDIF. " IF lv_dialogflag IS INITIAL

*          ELSE. " ELSE -> IF rb_post IS INITIAL
*&--Checking how much inventory is available for the material x plant x batch combination
*            PERFORM f_determine_batches_excel USING <lfs_input>.   "By ASK for Defect 6886

*            ENDIF. " IF rb_post IS INITIAL  "By ASK for Defect 6886
*** BOC By ASK for Defect 6886
          ELSE. " ELSE -> IF sy-subrc NE 0

            READ TABLE i_vbep INTO lwa_vbep WITH KEY vbeln = <lfs_input>-vbeln
                                                                 posnr = <lfs_input>-posnr BINARY SEARCH.
            IF sy-subrc IS INITIAL.
              IF lwa_vbep-wmeng GT <lfs_qty_avail>-wmeng.
                lv_error_flg = abap_true.
                MOVE <lfs_input>-vbeln TO lwa_final-vbeln.
                MOVE <lfs_input>-posnr TO lwa_final-posnr.
                lwa_final-status = 'E'.
                lwa_final-message = 'Ordered Quantity exceeds available quantity'(d04).
                CONCATENATE lwa_final-message 'Batch'(t13) <lfs_input>-charg INTO lwa_final-message SEPARATED BY space.

                APPEND lwa_final TO i_log_char.
                CLEAR lwa_final.
                CLEAR: <lfs_input>-charg,
                       <lfs_input>-vbeln.
              ELSE. " ELSE -> IF lwa_vbep-wmeng GT <lfs_qty_avail>-wmeng
                <lfs_qty_avail>-wmeng = <lfs_qty_avail>-wmeng - lwa_vbep-wmeng.
                MOVE <lfs_input>-vbeln TO lwa_final-vbeln.
                MOVE <lfs_input>-posnr TO lwa_final-posnr.
                lwa_final-status = 'S'.
                lwa_final-message = 'Ordered Quantity can be assigned'(d07).
                CONCATENATE lwa_final-message 'Batch'(t13) <lfs_input>-charg INTO lwa_final-message SEPARATED BY space.
                APPEND lwa_final TO i_log_char.
                CLEAR lwa_final.

              ENDIF. " IF lwa_vbep-wmeng GT <lfs_qty_avail>-wmeng

            ENDIF. " IF sy-subrc IS INITIAL
          ENDIF. " IF sy-subrc NE 0
**  EOC by ASK for Defect 6886
        ELSE. " ELSE -> IF <lfs_input>-charg IS NOT INITIAL
          MOVE <lfs_input>-vbeln TO lwa_final-vbeln.
          MOVE <lfs_input>-posnr TO lwa_final-posnr.
          lwa_final-status = 'E'.
          lwa_final-message = 'Batch Number is Initial in the file' .
          APPEND lwa_final TO i_log_char.
        ENDIF. " IF <lfs_input>-charg IS NOT INITIAL
*&--Checking how much inventory is available for the material x plant x batch combination
*        IF rb_post IS NOT INITIAL.       "++SMUKHER4
*          PERFORM f_determine_batches_excel.
*        ENDIF. " IF rb_post IS NOT INITIAL
      ENDIF. " IF sy-subrc <> 0 AND <lfs_input>-charg IS NOT INITIAL
    ENDIF. " IF <lfs_input>-charg IS NOT INITIAL
    IF lv_error_flg IS INITIAL.
      lwa_final_output = <lfs_input>.
      APPEND lwa_final_output TO i_final_output.

      IF rb_post IS INITIAL. "SMUKHER4
        MOVE lwa_final_output-vbeln TO lwa_final-vbeln.
        MOVE lwa_final_output-posnr TO lwa_final-posnr.
        lwa_final-status = 'S'.
        lwa_final-message = 'Record verfied successfully' .
        APPEND lwa_final TO i_log_char.
        CLEAR lwa_final.
      ENDIF. " IF rb_post IS INITIAL

      CLEAR lwa_final_output.
    ENDIF. " IF lv_error_flg IS INITIAL
    CLEAR: gv_uom,
           lv_posnr,
           lv_dialogflag.
  ENDLOOP. " LOOP AT i_input ASSIGNING <lfs_input>

  SORT i_input BY vbeln posnr.
  DELETE i_input WHERE vbeln IS INITIAL.

*&--Checking how much inventory is available for the material x plant x batch combination
*        IF rb_post IS NOT INITIAL.       "++SMUKHER4
*          PERFORM f_determine_batches_excel.
*        ENDIF. " IF rb_post IS NOT INITIAL

  gv_scount = lines( i_final_output ).
  gv_ecount = lines( i_input ) - gv_scount.
ENDFORM. " F_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_LOG_HEADER
*&---------------------------------------------------------------------*
*    Create Header Line for Log Files
*----------------------------------------------------------------------*
FORM f_create_log_header .

  DATA : lwa_log_char TYPE ty_log_char.

* Forming the header text line
  lwa_log_char-vbeln = 'Sales Order'(031).
  lwa_log_char-posnr = 'Item No'(032).
  lwa_log_char-status = 'Message Type'(033).
  lwa_log_char-message = 'Message Text'(034).

*  IF rb_vrfy IS NOT INITIAL.
  APPEND lwa_log_char TO i_log_char_file.
  APPEND LINES OF i_log_char TO i_log_char_file.
  CLEAR lwa_log_char.
*  ENDIF. " IF rb_vrfy IS NOT INITIAL

ENDFORM. " F_CREATE_LOG_HEADER
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_BATCHES
*&---------------------------------------------------------------------*
*  Update the batches read from input file
*----------------------------------------------------------------------*
FORM f_update_batches .

  DATA:
    li_return            TYPE TABLE OF bapiret2,    " Return Parameter
    lwa_return           TYPE bapiret2,             " Return Parameter
    li_return_c          TYPE bapiret2,             " Return Parameter
    li_schedule_lines    TYPE TABLE OF bapischdl,   " Communication Fields for Maintaining SD Doc. Schedule Lines
    li_schedule_linesx   TYPE TABLE OF bapischdlx,  " Checkbox List for Maintaining Sales Document Schedule Line
    li_order_item_in     TYPE TABLE OF bapisditm,   " Communication Fields: Sales and Distribution Document Item
    li_order_item_inx    TYPE TABLE OF  bapisditmx, " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_in    TYPE bapisditm,            " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_inx   TYPE bapisditmx,           " Communication Fields: Sales and Distribution Document Item
    lwa_order_header_in  TYPE bapisdh1,             " Communication Fields: SD Order Header
    lwa_order_header_inx TYPE bapisdh1x,            " Checkbox List: SD Order Header
    lwa_bdbatch_f        TYPE bdbatch,              " Results Table for Batch Determination
    lwa_schedule_lines   TYPE bapischdl,            " Communication Fields for Maintaining SD Doc. Schedule Lines
    lwa_schedule_linesx  TYPE bapischdlx,           " Checkbox List for Maintaining Sales Document Schedule Line
    lv_logtext           TYPE string,
    lv_joblog            TYPE string,
    lwa_log              TYPE ty_final.

  FIELD-SYMBOLS:
    <lfs_input>  TYPE ty_input,
    <lfs_return> TYPE bapiret2. " Return Parameter

  CONSTANTS:
    lc_error             TYPE char1 VALUE 'E'. " Error of type CHAR1

  LOOP AT i_input ASSIGNING <fs_input>.
    lwa_order_header_inx-updateflag = 'U'.
    lwa_order_item_in-itm_number = <fs_input>-posnr.
    READ TABLE i_bdbatch_f INTO lwa_bdbatch_f INDEX 1.
    IF sy-subrc EQ 0.
      lwa_order_item_in-material = lwa_bdbatch_f-matnr.
      lwa_order_item_in-batch = lwa_bdbatch_f-charg.
      lwa_schedule_lines-req_qty = lwa_bdbatch_f-menge.
    ENDIF. " IF sy-subrc EQ 0
    APPEND lwa_order_item_in TO li_order_item_in.

    lwa_order_item_inx-itm_number = <fs_input>-posnr.
    lwa_order_item_inx-updateflag = 'U'.
    lwa_order_item_inx-batch = 'X'.
    APPEND lwa_order_item_inx TO li_order_item_inx.

    CHECK <lfs_input> IS ASSIGNED.

    CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
      EXPORTING
        salesdocument    = <fs_input>-vbeln
        order_header_inx = lwa_order_header_inx
      TABLES
        return           = li_return
        order_item_in    = li_order_item_in
        order_item_inx   = li_order_item_inx.

    READ TABLE li_return ASSIGNING <lfs_return>
                         WITH KEY type = lc_error. " Return assigning of type
    IF sy-subrc NE 0.

      READ TABLE i_batch_d TRANSPORTING NO FIELDS WITH KEY vbeln = <fs_input>-vbeln.
      IF sy-subrc NE 0.
        PERFORM f_unlock_batch_orders USING <fs_input>.
      ENDIF. " IF sy-subrc NE 0
      <lfs_input>-charg = lwa_bdbatch_f-charg.
      lwa_log-vbeln   = <fs_input>-vbeln.
      lwa_log-posnr   = <fs_input>-posnr.
      lwa_log-status  = 'S'.
      lwa_log-message = 'Sales Order successfully saved'.
      APPEND lwa_log TO i_log_f.

      CLEAR: li_return_c.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait   = 'X'
        IMPORTING
          return = li_return_c.

      APPEND li_return_c TO i_log.

      CLEAR: lwa_order_header_inx.
      REFRESH: li_return,
               li_order_item_in,
               li_order_item_inx,
               li_schedule_lines,
               li_schedule_linesx.
    ELSE. " ELSE -> IF sy-subrc NE 0
      IF sy-batch IS INITIAL.
        <lfs_input>-charg = lwa_bdbatch_f-charg.
        lwa_log-vbeln   = <fs_input>-vbeln.
        lwa_log-posnr   = <fs_input>-posnr.
        lwa_log-status  = 'E'.
        lwa_log-message = <lfs_return>-message.
        APPEND lwa_log TO i_log_f.
      ELSE. " ELSE -> IF sy-batch IS INITIAL
        CONCATENATE <fs_input>-vbeln '/' <fs_input>-posnr 'E' '/' <lfs_return>-message
              INTO lv_joblog.
        WRITE lv_joblog.
      ENDIF. " IF sy-batch IS INITIAL

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
        IMPORTING
          return = lwa_return.

      IF lwa_return IS NOT INITIAL.
        IF sy-batch IS INITIAL.
          <fs_input>-charg = lwa_bdbatch_f-charg.

          lwa_log-vbeln   = <fs_input>-vbeln.
          lwa_log-posnr   = <fs_input>-posnr.
          lwa_log-status  = 'E'.
          lwa_log-message = 'Changes are NOT saved'.
          APPEND lwa_log TO i_log_f.

        ELSE. " ELSE -> IF sy-batch IS INITIAL
          lwa_log-message = 'Changes are NOT saved'.
          CONCATENATE <fs_input>-vbeln '/' <fs_input>-posnr 'E' '/' lwa_log-message
                INTO lv_joblog.
          WRITE lv_joblog.
        ENDIF. " IF sy-batch IS INITIAL
      ENDIF. " IF lwa_return IS NOT INITIAL
    ENDIF. " IF sy-subrc NE 0
  ENDLOOP. " LOOP AT i_input ASSIGNING <fs_input>
  IF <fs_input> IS ASSIGNED.
    UNASSIGN <fs_input>.
  ENDIF. " IF <fs_input> IS ASSIGNED
ENDFORM. " F_UPDATE_BATCHES
*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK_BATCH_ORDERS
*&---------------------------------------------------------------------*
*   Unlock the batch orders
*----------------------------------------------------------------------*
*      -->lwa_input Input file work area
*----------------------------------------------------------------------*
FORM f_unlock_batch_orders  USING  lwa_input TYPE ty_input.

  DATA:
    lv_index      TYPE sy-tabix, " Index of Internal Tables
    lwa_final     TYPE ty_final,
    lwa_batch_inp TYPE ty_input.

  lwa_batch_inp = lwa_input.

  CALL FUNCTION 'DEQUEUE_EVVBAKE'
    EXPORTING
      vbeln = lwa_batch_inp-vbeln.
  IF sy-subrc NE 0.
    " Sales order could not be Unlocked
    MESSAGE e000 WITH 'Sales Order could not be Unlocked'(023) INTO lwa_final-message.
    MOVE 'E'      TO lwa_final-status.
    MOVE lwa_batch_inp-vbeln TO lwa_final-vbeln.
    MOVE lwa_batch_inp-posnr TO lwa_final-posnr.
    APPEND lwa_final TO i_log_f.
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_UNLOCK_BATCH_ORDERS
*&---------------------------------------------------------------------*
*&      Form  F_DETERMINE_BATCHES_EXCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_determine_batches_excel USING f_input TYPE ty_input.

  DATA:
    lwa_komkh    TYPE komkh,            " Batch Determination Communication Block Header
    lwa_komph    TYPE komph,            " Batch Determination: Communication Record for Item
    lwa_bdcom    TYPE bdcom,            " Batch Determination Communication Structure
    lwa_final    TYPE ty_log_char,
    li_t459a     TYPE TABLE OF t459a,   " External requirements types
    lwa_t459a    TYPE t459a,            " External requirements types
    lwa_vbep     TYPE ty_vbep,
    lwa_bdbatch  TYPE bdbatch,          " Results Table for Batch Determination
    li_kna1      TYPE TABLE OF ty_kna1,
    li_vbap      TYPE TABLE OF ty_vbap,
    li_bdbatch   TYPE TABLE OF bdbatch, " Results Table for Batch Determination
    li_bdbatch_f TYPE TABLE OF bdbatch. " Results Table for Batch Determination

  FIELD-SYMBOLS:
    <lfs_kna1>  TYPE ty_kna1,
    <lfs_vbap>  TYPE ty_vbap,
    <lfs_vbep>  TYPE ty_vbep,
    <lfs_input> TYPE ty_input.

  CONSTANTS:
     lc_etenr TYPE etenr VALUE '0001'. " Delivery Schedule Line Number

  BREAK apoddar.
  lwa_komkh-mandt = sy-mandt.
  lwa_komkh-kndnr = f_input-kunnr.
  lwa_komkh-knrze = f_input-kunnr.
  lwa_komkh-kunnr = f_input-kunnr.
  lwa_komkh-vkorg = f_input-vkorg.
  lwa_komkh-vtweg = f_input-vtweg.
  lwa_komkh-spart = f_input-kunnr.
  lwa_komph-matnr = f_input-matnr.
  lwa_komph-werks = f_input-werks.

  READ TABLE i_vbap_val ASSIGNING <lfs_vbap>
                     WITH KEY vbeln = f_input-vbeln
                              posnr = f_input-posnr
                     BINARY SEARCH.
  IF sy-subrc EQ 0.
    lwa_komph-mvgr2 = <lfs_vbap>-mvgr2.
    lwa_bdcom-mtvfp = <lfs_vbap>-mtvfp.

    READ TABLE i_t459a INTO lwa_t459a WITH KEY bedae = <lfs_vbap>-bedae
                                               BINARY SEARCH.
    IF sy-subrc EQ 0.
      lwa_bdcom-bedar = lwa_t459a-bedar.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0

  lwa_bdcom-kappl = 'V'.
  lwa_bdcom-kalsm = 'SD0001'.
  lwa_bdcom-umrez = '1'.
  lwa_bdcom-umren = '1'.
  lwa_bdcom-kzvbp = 'X'.
  lwa_bdcom-prreg = 'A'.
  lwa_bdcom-chasp = '001'.
  lwa_bdcom-delkz = 'VC'.

  lwa_bdcom-menge = f_input-omeng.
  lwa_bdcom-meins = gv_uom.
  lwa_bdcom-erfmg = f_input-omeng.
  lwa_bdcom-erfme = gv_uom.
  lwa_bdcom-kund1 = f_input-kunnr.
  lwa_bdcom-name1 = f_input-name1.
  lwa_bdcom-delnr = f_input-vbeln.
  lwa_bdcom-delps = f_input-posnr.

  READ TABLE  i_vbep ASSIGNING <lfs_vbep>
                     WITH KEY vbeln = f_input-vbeln
                              posnr = f_input-posnr
                     BINARY SEARCH.
  IF sy-subrc EQ 0.
    lwa_bdcom-mbuhr = <lfs_vbep>-mbuhr.
  ENDIF. " IF sy-subrc EQ 0

  lwa_bdcom-nodia = 'X'.

  READ TABLE i_kna1_val ASSIGNING <lfs_kna1>
                     WITH KEY kunnr = f_input-kunnr
                     BINARY SEARCH.
  IF sy-subrc EQ 0.
    lwa_bdcom-ort01 = <lfs_kna1>-ort01.
    lwa_bdcom-land1 = <lfs_kna1>-land1.
    lwa_bdcom-pstlz = <lfs_kna1>-pstlz.
  ENDIF. " IF sy-subrc EQ 0

  CLEAR li_bdbatch.
  REFRESH: li_bdbatch.
  CALL FUNCTION 'VB_BATCH_DETERMINATION'
    EXPORTING
      i_komkh   = lwa_komkh
      i_komph   = lwa_komph
      x_bdcom   = lwa_bdcom
    TABLES
      e_bdbatch = li_bdbatch
    EXCEPTIONS
      no_plant  = 7
      OTHERS    = 99.
  IF sy-subrc <> 0 OR
     li_bdbatch IS INITIAL.
    MESSAGE e000 WITH 'No batch determined'(021) INTO lwa_final-message.
    MOVE 'E'      TO lwa_final-status.
    MOVE f_input-vbeln TO lwa_final-vbeln.
    MOVE f_input-posnr TO lwa_final-posnr.
    APPEND lwa_final TO i_log_char[].
    CLEAR lwa_final.
    CLEAR f_input-vbeln.
  ELSE. " ELSE -> IF sy-subrc <> 0 OR
    READ TABLE li_bdbatch INTO lwa_bdbatch INDEX 1.

    READ TABLE i_vbep INTO lwa_vbep WITH KEY vbeln = f_input-vbeln
                                             posnr = f_input-posnr
                                             BINARY SEARCH.
    IF sy-subrc EQ 0.
      IF lwa_vbep-wmeng GT lwa_bdbatch-vrfmg.
        "Log
        MOVE f_input-vbeln TO lwa_final-vbeln.
        MOVE f_input-posnr TO lwa_final-posnr.
        lwa_final-status = 'E'.
        lwa_final-message = 'Ordered Quantity exceeds available quantity'(d04).
        CONCATENATE lwa_final-message 'Batch'(t13) f_input-charg INTO lwa_final-message SEPARATED BY space.
        APPEND lwa_final TO i_log_char[].
        CLEAR lwa_final.
        CLEAR f_input-vbeln.
        REFRESH: li_bdbatch.
*++SMUKHER4
      ELSE. " ELSE -> IF lwa_vbep-wmeng GT lwa_bdbatch-vrfmg
        MOVE f_input-vbeln TO lwa_final-vbeln.
        MOVE f_input-posnr TO lwa_final-posnr.
        lwa_final-status = 'S'.
        lwa_final-message = 'Ordered Quantity can be assigned'(d07).
        CONCATENATE lwa_final-message 'Batch'(t13) f_input-charg INTO lwa_final-message SEPARATED BY space.
        APPEND lwa_final TO i_log_char[].
        CLEAR lwa_final.
        REFRESH: li_bdbatch.

      ENDIF. " IF lwa_vbep-wmeng GT lwa_bdbatch-vrfmg
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc <> 0 OR

  CLEAR : lwa_komkh,
          lwa_komph,
          lwa_bdcom.

  REFRESH: li_bdbatch,
           i_bdbatch_f.

ENDFORM. " F_DETERMINE_BATCHES_EXCEL

*&---------------------------------------------------------------------*
*&      Form  F_MOVE
*&---------------------------------------------------------------------*
*    Move file from TBD to DONE Folder
*----------------------------------------------------------------------*
*      -->FP_SOURCEFILE  Application File Path
*----------------------------------------------------------------------*
FORM f_move  USING    fp_sourcefile TYPE localfile. " Local file for upload/download.

  DATA: lv_file TYPE localfile, " Local file for upload/download
        lv_name TYPE localfile. " Local file for upload/download

  CONSTANTS: lc_tbp_fld  TYPE char5        VALUE 'TBP',  " constant declaration for TBP folder
             lc_done_fld TYPE char5       VALUE 'DONE'. " constant declaration for DONE folder

  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_sourcefile
    IMPORTING
      pathname = lv_file
      filename = lv_name.

* First move the file to the Done folder
  REPLACE lc_tbp_fld  IN lv_file WITH lc_done_fld .
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
*&      Form  F_FILE_MOVE
*&---------------------------------------------------------------------*
*     Moving File from p_sourcepath to p_targetpath
*----------------------------------------------------------------------*
*      -->FP_V_SOURCEPATH  Source Path
*      -->FP_V_TARGETPATH  Target Path
*      <--FP_V_RETURN      Return Code
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
*&      Form  F_GET_APPL_FILES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_TBP_FILE  text
*      <--P_GV_DONE_FILE  text
*      <--P_GV_ERR_FILE  text
*----------------------------------------------------------------------*
FORM f_get_appl_files    USING fp_inputfile TYPE char1024  " Local file for upload/download
                      CHANGING fp_tbp_file  TYPE localfile  " Local file for upload/download
                               fp_done_file TYPE localfile  " Local file for upload/download
                               fp_err_file  TYPE localfile. " Local file for upload/download

  DATA: lv_file TYPE localfile, " Local file for upload/download
        lv_name TYPE localfile. " Local file for upload/download

  CONSTANTS: lc_appl TYPE string VALUE '/appl/',
             lc_rep  TYPE string VALUE '/ENH/OTC/OTC_EDD_0398/',
             lc_done TYPE string VALUE 'DONE/',
             lc_tbp  TYPE string VALUE 'TBP/',
             lc_err  TYPE string VALUE 'ERROR/'.

*  CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
*    EXPORTING
*      full_name     = fp_inputfile
*    IMPORTING
*      stripped_name = stripped
*      file_path     = file_path
*    EXCEPTIONS
*      x_error       = 1
*      OTHERS        = 2.
  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_inputfile
    IMPORTING
      pathname = lv_file
      filename = lv_name.

  IF sy-subrc = 0.
*&-- Create default path
    CONCATENATE lc_appl sy-sysid lc_rep lc_tbp  lv_name INTO fp_tbp_file.
    CONCATENATE lc_appl sy-sysid lc_rep lc_done lv_name INTO fp_done_file.
    CONCATENATE lc_appl sy-sysid lc_rep lc_err  lv_name INTO fp_err_file.
  ELSE. " ELSE -> IF sy-subrc = 0
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF. " IF sy-subrc = 0
ENDFORM. " F_GET_APPL_FILES
*&---------------------------------------------------------------------*
*&      Form  F_WRITE_FILE
*&---------------------------------------------------------------------*
*  Write the records in the application server in DONE folder
*----------------------------------------------------------------------*
*      -->FP_AFILE     Application server file path
*      -->FP_I_SOURCE  Input file
*----------------------------------------------------------------------*
FORM f_write_file  USING    fp_afile    TYPE localfile   " Local file for upload/download
                            fp_i_source TYPE ty_t_input. " Input file

* Local Data
  DATA: lv_data   TYPE char4000, "Output data string
        lwa_input TYPE ty_input. "Error work area

* Write the records
  OPEN DATASET fp_afile FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " Output type
  IF sy-subrc NE 0.
    MESSAGE i019.
  ELSE. " ELSE -> IF sy-subrc NE 0

*   Passing the Erroneous Header data
    LOOP AT fp_i_source INTO lwa_input.
      CONCATENATE
          lwa_input-vbeln
          lwa_input-posnr
          lwa_input-matnr
          lwa_input-kwmeng
          lwa_input-omeng
          lwa_input-bmeng
          lwa_input-kunnr
          lwa_input-name1
          lwa_input-vkorg
          lwa_input-vtweg
          lwa_input-werks
          lwa_input-edatu
          lwa_input-charg
          lwa_input-lifsk
          lwa_input-vtext
          lwa_input-antigens
          lwa_input-corres
           INTO lv_data
           SEPARATED BY c_tab.
* Transferring the data into application server.
      TRANSFER lv_data TO fp_afile.
      CLEAR lv_data.
    ENDLOOP. " LOOP AT fp_i_source INTO lwa_input
  ENDIF. " IF sy-subrc NE 0
  CLOSE DATASET fp_afile.
ENDFORM. " F_WRITE_FILE
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_LOG_FILE
*&---------------------------------------------------------------------*
*    Display the records in the ALV output
*----------------------------------------------------------------------*
*  -->  fp_i_log_char      Log file
*  <--  fp_log_verify      Log file for upload/download
*----------------------------------------------------------------------*
FORM f_display_log_file USING fp_i_log_char TYPE ty_t_log_char
                              fp_log_verify TYPE char1024. " Local file for upload/download

  TYPES:  lty_t_bapiret TYPE STANDARD TABLE OF bapiret2. "structure of type bapiret2
*&--Local Object & Variable declarations
  DATA: lo_alv              TYPE REF TO cl_salv_table,            " Basis Class for Simple Tables
        lv_column           TYPE REF TO cl_salv_column_table,     "Column
        lv_columns          TYPE REF TO cl_salv_columns_table,    "Column
        lv_func             TYPE REF TO cl_salv_functions_list,   "Toolbar
        lo_display_settings TYPE REF TO cl_salv_display_settings, " Appearance of the ALV Output
        lv_ex_msg           TYPE REF TO cx_salv_msg,              "Message
        lv_ex_notfound      TYPE REF TO cx_salv_not_found,        "Exception
        lv_grid             TYPE REF TO cl_salv_form_layout_grid, " Grid
        lv_gridx            TYPE REF TO cl_salv_form_layout_grid, " Grid X
        lv_no_success       TYPE int4,                            " Natural Number
        lv_uzeit            TYPE char20,                          " Time
        lv_datum            TYPE char20,                          " Date
        lv_lines            TYPE char10,                          "records count of final table
        lv_name             TYPE ad_namtext,                      " Full Name of Person
        lx_address          TYPE bapiaddr3,                       "User Address Data
        li_return           TYPE lty_t_bapiret,                   " Return table
        lv_row              TYPE int4,                            " Row number
        li_fieldcat         TYPE slis_t_fieldcat_alv,             "Field Catalog
        li_events           TYPE slis_t_event,
        lwa_events          TYPE slis_alv_event,
        lwa_log             TYPE ty_log_char,
        lv_records          TYPE int4,                            " Natural Number
* boc apoddar
        li_log_char         TYPE ty_t_log_char.
* eoc apoddar


*&--Local Constants.
  CONSTANTS: lc_colon   TYPE char1        VALUE ':', " Colon
             lc_error   TYPE char1        VALUE 'E', " Error of type CHAR1
             lc_success TYPE char1        VALUE 'S'. " Success of type CHAR1

*&--Deleting the header row
  DELETE fp_i_log_char INDEX 1.
  IF fp_i_log_char IS INITIAL.
    lwa_log-status = lc_success.
    lwa_log-message = 'All records are verified and correct'.
    APPEND lwa_log TO fp_i_log_char.
    CLEAR lwa_log.
  ENDIF. " IF fp_i_log_char IS INITIAL

  IF sy-batch IS INITIAL.
    TRY.
        CALL METHOD cl_salv_table=>factory
          EXPORTING
            list_display = if_salv_c_bool_sap=>false
          IMPORTING
            r_salv_table = lo_alv
          CHANGING
            t_table      = fp_i_log_char.

      CATCH cx_salv_msg INTO lv_ex_msg.
        MESSAGE lv_ex_msg TYPE lc_error. "'E'.
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE lc_error. "'E'.
    ENDTRY.

* Get user details
    CALL FUNCTION 'BAPI_USER_GET_DETAIL'
      EXPORTING
        username = sy-uname
      IMPORTING
        address  = lx_address
      TABLES
        return   = li_return.

    IF lx_address-fullname IS NOT INITIAL.
      MOVE lx_address-fullname TO lv_name.
    ELSE. " ELSE -> IF lx_address-fullname IS NOT INITIAL
      MOVE sy-uname TO lv_name.
    ENDIF. " IF lx_address-fullname IS NOT INITIAL

    WRITE sy-uzeit TO lv_uzeit.
    WRITE sy-datum TO lv_datum.
    CONCATENATE lv_datum lv_uzeit INTO lv_datum SEPARATED BY space.

* Display the number of records present in the header portion
*    lv_records = lines( i_source ).

    li_log_char[] =  fp_i_log_char[].
    SORT li_log_char BY vbeln posnr.
    DELETE ADJACENT DUPLICATES FROM li_log_char COMPARING vbeln posnr.
    IF li_log_char IS NOT INITIAL.
      lv_records = lines( li_log_char ).
    ENDIF. " IF li_log_char IS NOT INITIAL
    CREATE OBJECT lv_grid.
* Run Information
    lv_row = 1.
    lv_grid->create_header_information( row     = lv_row
                                        column  = lv_row
                                        text    = 'List of Records'(036) ).
    lv_row = lv_row + 1.
    lv_gridx = lv_grid->create_grid( row = lv_row  column = 1  ).

    lv_row = lv_row + 1.
* User / Processor
    lv_gridx->create_label( row = lv_row column = 1
                           text = 'Run By'(037)
                           tooltip = 'Run By'(037) ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_colon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = lv_name ).
    lv_row = lv_row + 1.
* Date / Time
    lv_gridx->create_label( row = lv_row column = 1
                           text = 'Date / Time'(038)
                           tooltip = 'Date / Time'(038) ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_colon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = lv_datum ).
    lv_row = lv_row + 1.
* Total Records
    lv_gridx->create_label( row = lv_row column = 1
                           text = 'Total Records'
                           tooltip = 'Total Records' ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_colon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = lv_records ).
    lv_row = lv_row + 1.
* Success Count
    lv_gridx->create_label( row = lv_row column = 1
                           text = 'No. of error records'(039) ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_colon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = lv_no_success ).
    lv_row = lv_row + 1.
* Input File
    lv_gridx->create_label( row = lv_row column = 1
                           text = 'Source File Path' ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_colon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = p_ifile ).
    lv_row = lv_row + 1.
* Log File Path
    lv_gridx->create_label( row = lv_row column = 1
                           text = 'Log File Path'(041) ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_colon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text =  fp_log_verify ).


    CALL METHOD lo_alv->set_top_of_list( lv_grid ).

    lo_display_settings = lo_alv->get_display_settings( ).

    lo_display_settings->set_list_header( 'List of Error Records'(040) ).

    lo_display_settings->set_list_header_size( cl_salv_display_settings=>c_header_size_large ).

    CALL METHOD lo_alv->set_top_of_list( lv_grid ).

    CALL METHOD lo_alv->get_columns
      RECEIVING
        value = lv_columns.
    TRY.
        lv_column ?= lv_columns->get_column( 'VBELN' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( TEXT-x12 ).
    lv_column->set_medium_text( TEXT-x12 ).
    lv_column->set_long_text( TEXT-x12 ).
    lv_columns->set_optimize( 'X' ).

    TRY.
        lv_column ?= lv_columns->get_column( 'POSNR' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.

    lv_column->set_short_text( TEXT-x13 ).
    lv_column->set_medium_text( TEXT-x13 ).
    lv_column->set_long_text( TEXT-x13 ).
    lv_columns->set_optimize( 'X' ).

    TRY.
        lv_column ?= lv_columns->get_column( 'STATUS' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( TEXT-x14 ).
    lv_column->set_medium_text( TEXT-x14 ).
    lv_column->set_long_text( TEXT-x14 ).
    lv_columns->set_optimize( 'X' ).

    TRY.
        lv_column ?= lv_columns->get_column( 'MESSAGE' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( TEXT-x15 ).
    lv_column->set_medium_text( TEXT-x15 ).
    lv_column->set_long_text( TEXT-x15 ).
    lv_columns->set_optimize( 'X' ).
* Function Tool bars
    lv_func = lo_alv->get_functions( ).
    lv_func->set_all( ).

    lo_alv->display( ).

  ELSE. " ELSE -> IF sy-batch IS INITIAL

* Preparing field-catalog
* Sales Order
    PERFORM f_fill_fieldcat USING 'VBELN'
                                  'I_LOG_CHAR'
                                  TEXT-031
                                  11
                          CHANGING li_fieldcat[].

* SO Item
    PERFORM f_fill_fieldcat USING 'POSNR'
                                  'I_LOG_CHAR'
                                  TEXT-032
                                  7
                          CHANGING li_fieldcat[].
* Status
    PERFORM f_fill_fieldcat USING 'STATUS'
                                  'I_LOG_CHAR'
                                  TEXT-033
                                  8
                          CHANGING li_fieldcat[].
* Message
    PERFORM f_fill_fieldcat USING 'MESSAGE'
                                  'I_LOG_CHAR'
                                  TEXT-034
                                  220
                          CHANGING li_fieldcat[].
*   Top of page subroutine
    lwa_events-name = 'TOP_OF_PAGE'.
    lwa_events-form = 'F_TOP_OF_PAGE10'.
    APPEND lwa_events TO li_events.
    CLEAR lwa_events.

*   ALV List Display for Background Run
    CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
      EXPORTING
        i_callback_program = sy-repid
        it_fieldcat        = li_fieldcat
        it_events          = li_events
      TABLES
        t_outtab           = i_log_char
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
      MESSAGE e002(zca_msg). " Invalid file name. Please check your entry.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF sy-batch IS INITIAL
ENDFORM. " F_DISPLAY_LOG_FILE
*&---------------------------------------------------------------------*
*&      Form  F_WRITE_LOG_FILE
*&---------------------------------------------------------------------*
*   Write log file in the application server
*----------------------------------------------------------------------*
*      -->FP__ERR_FILE      local file path
*      -->FP_I_LOG_F        Log file
*----------------------------------------------------------------------*
FORM f_write_log_file  USING    fp_err_file TYPE localfile " Local file for upload/download
                                fp_i_log_f  TYPE ty_t_log_char.

  DATA : lv_data TYPE string,
         lwa_log TYPE ty_final.

  OPEN DATASET fp_err_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " Output type
  IF sy-subrc NE 0.
    MESSAGE i019. " Error Folder could not be opened
  ELSE. " ELSE -> IF sy-subrc NE 0
    LOOP AT fp_i_log_f INTO lwa_log.
      CONCATENATE lwa_log-vbeln
                  lwa_log-posnr
                  lwa_log-status
                  lwa_log-message
             INTO lv_data
             SEPARATED BY c_tab.
      TRANSFER lv_data TO fp_err_file.
      CLEAR : lv_data,
              lwa_log.
    ENDLOOP. " LOOP AT fp_i_log_f INTO lwa_log
  ENDIF. " IF sy-subrc NE 0
  CLOSE DATASET fp_err_file.
ENDFORM. " F_WRITE_LOG_FILE
*&---------------------------------------------------------------------*
*&      Form  F_LOCK_UPDATE_SO
*&---------------------------------------------------------------------*
*  Update the Sales order in VA03.
*----------------------------------------------------------------------*
*  --> FP_I_FINAL        Input table
*----------------------------------------------------------------------*
FORM f_lock_update_so USING fp_i_final TYPE ty_t_input.

**  BOC APODDAR
  TYPES : BEGIN OF lty_vbap,
            vbeln TYPE vbeln_va, " Sales Document
            posnr TYPE posnr_va, " Sales Document Item
            matnr TYPE matnr,    " Material Number
            charg TYPE charg_d,  " Batch Number
          END OF lty_vbap.

*&--> Local data declarartions
  DATA :
    lwa_final            TYPE          ty_input,    "Input tab;le work area
    lwa_final_tmp        TYPE          ty_input,
    lwa_log              TYPE          ty_log_char, "Work area for log table
    li_return            TYPE TABLE OF bapiret2,    " Return Parameter
    lwa_return           TYPE          bapiret2,    " Return Parameter
    lx_return_c          TYPE          bapiret2,    " Return Parameter
    li_order_item_in     TYPE TABLE OF bapisditm,   " Communication Fields: Sales and Distribution Document Item
    li_order_item_inx    TYPE TABLE OF  bapisditmx, " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_in    TYPE bapisditm,            " Communication Fields: Sales and Distribution Document Item
    lwa_item             TYPE bapisditm,            " Communication Fields: Sales and Distribution Document Item
    lwa_temp             TYPE bapisditm,            " Communication Fields: Sales and Distribution Document Item
    lwa_order_item_inx   TYPE bapisditmx,           " Communication Fields: Sales and Distribution Document Item
    lwa_order_header_in  TYPE bapisdh1,             " Communication Fields: SD Order Header
    lwa_order_header_inx TYPE bapisdh1x,            " Checkbox List: SD Order Header
    lv_index             TYPE sy-tabix,             " Index of Internal Tables
    lv_logtext           TYPE string,
    lv_joblog            TYPE string,
    li_vbap_chk          TYPE STANDARD TABLE OF lty_vbap INITIAL SIZE 0,
    lwa_vbap_chk         TYPE lty_vbap,
    li_vbap              TYPE STANDARD TABLE OF lty_vbap INITIAL SIZE 0,
    li_log_temp          TYPE TABLE OF ty_log_char,
    lwa_temp_char        TYPE ty_log_char,
    lwa_vbap             TYPE lty_vbap,
    lv_posnr             TYPE posnr_va.             " Sales Document Item

  FIELD-SYMBOLS: <lfs_return> TYPE bapiret2, " Return Parameter
                 <lfs_char>   TYPE ty_log_char.

  CONSTANTS:
    lc_error  TYPE char1 VALUE 'E'. " Error of type CHAR1

  SORT fp_i_final BY vbeln posnr.


  LOOP AT fp_i_final INTO lwa_final_tmp.

    lwa_final = lwa_final_tmp. "  Defect 6886 By ASK
* Update Sales Order from input file
    lwa_order_header_inx-updateflag = 'U'.
    lwa_order_item_in-itm_number = lwa_final-posnr.
    lwa_order_item_in-material = lwa_final-matnr.
    lwa_order_item_in-batch = lwa_final-charg.
    APPEND lwa_order_item_in TO li_order_item_in.


    lwa_order_item_inx-itm_number = lwa_final-posnr.
    lwa_order_item_inx-updateflag = 'U'.
    lwa_order_item_inx-batch = 'X'.
    APPEND lwa_order_item_inx TO li_order_item_inx.

    AT END OF vbeln.

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
                              WITH KEY type = lc_error. " Return assigning of type
      IF sy-subrc NE 0.

        LOOP AT li_order_item_in INTO lwa_temp.
          lwa_log-vbeln   = lwa_final-vbeln.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = lwa_temp-itm_number
            IMPORTING
              output = lwa_temp-itm_number.

          lwa_log-posnr = lwa_temp-itm_number.
          lwa_log-status  = 'S'.
          lwa_log-message = 'Sales Order successfully saved'.
          APPEND lwa_log TO i_log_char.
          CLEAR lwa_log.
        ENDLOOP. " LOOP AT li_order_item_in INTO lwa_temp

        CLEAR: lx_return_c.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait   = 'X'
          IMPORTING
            return = lx_return_c.

        APPEND lx_return_c TO i_log.

        CLEAR: lwa_order_header_inx.
        REFRESH: li_return,
                 li_order_item_in,
                 li_order_item_inx.


      ELSE. " ELSE -> IF sy-subrc NE 0
        gv_scount = gv_scount - 1.
        gv_ecount = gv_ecount + 1.
        IF sy-batch IS INITIAL.
          lwa_log-vbeln   = lwa_final-vbeln.
          lwa_log-posnr   = lwa_order_item_inx-itm_number. "lwa_final-posnr.
          lwa_log-status  = 'E'.
          lwa_log-message = <lfs_return>-message.

          APPEND lwa_log TO i_log_char.
          CLEAR lwa_log.

        ENDIF. " IF sy-batch IS INITIAL

        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
          IMPORTING
            return = lwa_return.
        IF lwa_return IS NOT INITIAL.
          IF sy-batch IS INITIAL.
            lwa_log-vbeln   = lwa_final-vbeln.
            lwa_log-posnr   = lwa_order_item_inx-itm_number. "lwa_final-posnr.
            lwa_log-status  = 'E'.
            lwa_log-message = 'Changes are NOT saved'.

            APPEND lwa_log TO i_log_char.
            CLEAR lwa_log.

          ENDIF. " IF sy-batch IS INITIAL

        ENDIF. " IF lwa_return IS NOT INITIAL

        CLEAR: lwa_order_header_inx.
        REFRESH: li_return,
                 li_order_item_in,
                 li_order_item_inx.


      ENDIF. " IF sy-subrc NE 0

    ENDAT.
  ENDLOOP. " LOOP AT fp_i_final INTO lwa_final_tmp

  WAIT UP TO 4 SECONDS.

  IF fp_i_final IS NOT INITIAL.
    LOOP AT fp_i_final INTO lwa_final.
      MOVE lwa_final-vbeln TO lwa_vbap_chk-vbeln.
      MOVE lwa_final-posnr TO lwa_vbap_chk-posnr.
      MOVE lwa_final-matnr TO lwa_vbap_chk-matnr.
      MOVE lwa_final-charg TO lwa_vbap_chk-charg.
      APPEND lwa_vbap_chk TO li_vbap_chk.
      CLEAR : lwa_vbap_chk,
              lwa_final.
    ENDLOOP. " LOOP AT fp_i_final INTO lwa_final
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
              lwa_log-status  = 'E'.
              lwa_log-message = 'Batch Could not be refreshed for Order. Please re-run it'. " Sequence
*              APPEND lwa_log TO i_log_char.
              APPEND lwa_log TO li_log_temp[].
              CLEAR lwa_log.
            ENDIF. " IF lwa_vbap_chk-charg NE lwa_vbap-charg
          ENDIF. " IF sy-subrc = 0
        ENDLOOP. " LOOP AT li_vbap INTO lwa_vbap
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF li_vbap_chk IS NOT INITIAL
  ENDIF. " IF fp_i_final IS NOT INITIAL

  IF li_log_temp IS NOT INITIAL.

    LOOP AT li_log_temp INTO lwa_temp_char.
      READ TABLE i_log_char ASSIGNING <lfs_char> WITH KEY vbeln = lwa_temp_char-vbeln
                                                          posnr = lwa_temp_char-posnr
                                                          status = 'S'.
      IF sy-subrc IS INITIAL.
        <lfs_char>-vbeln = space.
      ENDIF. " IF sy-subrc IS INITIAL

      IF <lfs_char> IS ASSIGNED.
        UNASSIGN <lfs_char>.
      ENDIF. " IF <lfs_char> IS ASSIGNED
    ENDLOOP. " LOOP AT li_log_temp INTO lwa_temp_char

    DELETE i_log_char WHERE vbeln IS INITIAL.
    APPEND LINES OF li_log_temp TO i_log_char.
  ENDIF. " IF li_log_temp IS NOT INITIAL


  IF i_log_char IS NOT INITIAL.
    SORT i_log_char BY vbeln posnr.
  ENDIF. " IF i_log_char IS NOT INITIAL

*&--++EOC by SMUKHEr4
ENDFORM. " F_LOCK_UPDATE_SO
*&---------------------------------------------------------------------*
*&      Form  F_FILL_FIELDCAT
*&---------------------------------------------------------------------*
*       Subroutine to fill fieldcatalog table
*----------------------------------------------------------------------*
*  -->  FP_FIELDNAME    Field Name
*  -->  FP_TABNAME      Table Name
*  -->  FP_SELTEXT      Column Header
*  <--  FP_I_FIECAT     FielCatalog
*----------------------------------------------------------------------*
FORM f_fill_fieldcat USING fp_fieldname  TYPE slis_fieldname
                           fp_tabname    TYPE slis_tabname
                           fp_seltext    TYPE scrtext_l " Long Field Label
                           fp_collength  TYPE outputlen " Output Length
                  CHANGING fp_i_fieldcat TYPE slis_t_fieldcat_alv.
* Local Data
  DATA: lwa_fieldcat TYPE slis_fieldcat_alv.

  lwa_fieldcat-fieldname  = fp_fieldname.
  lwa_fieldcat-tabname    = fp_tabname.
  lwa_fieldcat-outputlen  = fp_collength.
  lwa_fieldcat-seltext_l  = fp_seltext.
  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.

ENDFORM. " F_FILL_FIELDCAT                   " F_FILL_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       Subroutine for header display
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_top_of_page.
* Horizontal Line.
  CONSTANTS: c_hline TYPE char50           " Dotted Line
             VALUE
'--------------------------------------------------',
             c_colon TYPE char1 VALUE ':'. " Colon of type CHAR1

* Run Information
  WRITE: / 'Run Information'.
* Horizontal Line
  WRITE: / c_hline.
* File Read
  WRITE: / 'File Read', 50(1) c_colon, 52 p_ifile.
* Client
  WRITE: / 'Client', 50(1) c_colon, 52 sy-mandt.
* Run By / User Id
  WRITE: / 'Run By/User ID', 50(1) c_colon, 52 sy-uname.
* Date / Time
  WRITE: / 'Date/Time', 50(1) c_colon, 52 sy-datum, 63 sy-uzeit.
* Log File
  WRITE: / 'Log File', 50(1) c_colon, 52 p_lfile.

** Execution Mode
*  WRITE: / text-x06, 50(1) c_colon, 52 gv_mode_b.
*  IF gv_session IS NOT INITIAL.
** Batch Session Details
*    WRITE: / text-x29, 50(1) c_colon, 52 gv_session.
*  ENDIF. " IF gv_session IS NOT INITIAL
** Horizontal Line
*  WRITE: / c_hline.
** Total number of records in the given file
*  WRITE: / text-x08, 50(1) c_colon, 52 gv_total LEFT-JUSTIFIED.
** Number of Success records
*  WRITE: / text-x09, 50(1) c_colon, 52 gv_no_success4 LEFT-JUSTIFIED.
** Number of Error records
*  WRITE: / text-x10, 50(1) c_colon, 52 gv_no_failed4 LEFT-JUSTIFIED.
** Success Rate
*  WRITE: / text-x11, 50(1) c_colon, 52 gv_rate_c LEFT-JUSTIFIED.
** Horizontal Line
*  WRITE: / c_hline.
ENDFORM. " F_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_FILE
*&---------------------------------------------------------------------*
*       Download the Log Files (Presentation Server)
*----------------------------------------------------------------------*
*      -->FP_LOG_FILE     Log File Name
*      -->FP_I_DATA       Internal Table with Error/Success records
*----------------------------------------------------------------------*
FORM f_download_file  USING    fp_log_file  TYPE char1024 " Local file for upload/download
                               fp_i_data    TYPE ty_t_log_char.

* Local Data Declaration
  DATA: lv_filename TYPE string.

  lv_filename = fp_log_file.

*&--Call method to download the file
  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename                = lv_filename
      filetype                = c_file_type
      write_field_separator   = c_sep
    CHANGING
      data_tab                = fp_i_data
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF. " IF sy-subrc IS NOT INITIAL
ENDFORM. " F_DOWNLOAD_FILE                 " F_DOWNLOAD_FILE
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_L_EXTENSION
*&---------------------------------------------------------------------*
*        Check the log file extension
*----------------------------------------------------------------------*
*      -->FP_P_FILE        File Name
*----------------------------------------------------------------------*
FORM f_check_l_extension  USING    fp_p_file TYPE char1024. " Local file for upload/download

  CONSTANTS : lc_xls TYPE char3 VALUE 'XLS'. " Xls of type CHAR3

  IF fp_p_file IS NOT INITIAL.
    CLEAR gv_extn.
* Getting the Extension of the Filename.
    CALL FUNCTION 'ZDEV_TRINT_FILE_GET_EXTENSION'
      EXPORTING
        im_filename  = fp_p_file
        im_uppercase = c_true
      IMPORTING
        ex_extension = gv_extn.

* No need to check SY-SUBRC as no exception is raised by the FM
* and it will always return SY-SUBRC = 0.
    IF gv_extn <> lc_xls.
      MESSAGE e000 WITH 'Please provide .xls file'.
    ENDIF. " IF gv_extn <> lc_xls
  ENDIF. " IF fp_p_file IS NOT INITIAL

ENDFORM. " F_CHECK_P_EXTENSION
*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LWA_FINAL  text
*----------------------------------------------------------------------*
FORM f_unlock_batch  USING  lwa_input TYPE ty_input.

  DATA:
    lv_index      TYPE sy-tabix, " Index of Internal Tables
    lwa_final     TYPE ty_final,
    lwa_batch_inp TYPE ty_input.

  lwa_batch_inp = lwa_input.

  CALL FUNCTION 'DEQUEUE_EVVBAKE'
    EXPORTING
      vbeln = lwa_batch_inp-vbeln.
  IF sy-subrc NE 0.
    " Sales order could not be Unlocked
    MESSAGE e000 WITH 'Sales Order could not be Unlocked'(023) INTO lwa_final-message.
    MOVE 'E'      TO lwa_final-status.
    MOVE lwa_batch_inp-vbeln TO lwa_final-vbeln.
    MOVE lwa_batch_inp-posnr TO lwa_final-posnr.
    APPEND lwa_final TO i_log_char[].
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_UNLOCK_BATCH
*&-->Begin of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
*&---------------------------------------------------------------------*
*&      Form  F_HELP_AS_PATH
*&---------------------------------------------------------------------*
*      F4 help for Application Server
*----------------------------------------------------------------------*
*      -->FP_V_FILENAME  Selected File Path from Application Server
*----------------------------------------------------------------------*
FORM f_help_as_path  CHANGING fp_v_filename TYPE localfile. " Local file for upload/download
* Function  module for F4 help from Application  server
  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    IMPORTING
      serverfile       = fp_v_filename
    EXCEPTIONS
      canceled_by_user = 1
      OTHERS           = 2.
  IF sy-subrc IS NOT INITIAL.
    CLEAR fp_v_filename.
  ENDIF. " IF sy-subrc IS NOT INITIAL

ENDFORM. " F_HELP_AS_PATH
*&---------------------------------------------------------------------*
*&      Form  F_GET_APPS_SERVER
*&---------------------------------------------------------------------*
*    Uploading the input file in the Application Server
*----------------------------------------------------------------------*
*      -->FP_I_INPUT[]  Final Internal Table
*      -->FP_P_FILE[]   Local file
*----------------------------------------------------------------------*
FORM f_get_apps_server  USING    fp_p_file                  TYPE char1024    " Local file for upload/download
                                 fp_i_final_output          TYPE ty_t_input  "Success records
                                 fp_i_input_error           TYPE ty_t_input. "Error records


  DATA: lv_path     TYPE string,
        lwa_output  TYPE ty_input,  "Input work area
        lv_flag     TYPE flag,       " General Flag
        lv_filename TYPE localfile,  " Local file for upload/download
        lv_string   TYPE char1792,   " String of type CHAR1792
        lv_lines    TYPE i,          "Local varibale to keep error records
        lv_dirname  TYPE eps2filnam. " Directory name

  CONSTANTS: lc_format      TYPE string VALUE '.txt', " File Format
             lc_slash       TYPE char1  VALUE '/',                  " Slash of type CHAR1
             lc_score       TYPE char1  VALUE '_',                  " Score of type CHAR1
             lc_tbp         TYPE char4  VALUE 'TBP',                "Folder path for TBP
             lc_pipe        TYPE char1  VALUE '|',                  "Pipe delimeter
             lc_object_name TYPE string  VALUE 'OTC_EDD_0398', "Local Constant for Object
             lc_appl        TYPE string VALUE '/appl/',
             lc_rep         TYPE string VALUE '/ENH/OTC/OTC_EDD_0398/'.


*&--Valid records will be move to the TBP folder.

*  CONCATENATE lv_path lc_tbp INTO lv_path.

*&-- Create default path
  CONCATENATE lc_appl sy-sysid lc_rep lc_tbp lc_slash INTO lv_path.
  CONCATENATE lv_path lc_object_name lc_score sy-datum sy-uzeit lc_score sy-uname lc_format INTO lv_filename.
*&-->Storing the application file path in a global variable.
  gv_file_appl = lv_filename.

  "Keeping the count for success records in a variable

  DESCRIBE TABLE fp_i_final_output LINES lv_lines.
  IF NOT lv_filename IS INITIAL.
**//Check file for authorization
    PERFORM f_check_file USING lv_filename
                      CHANGING lv_flag.
    IF lv_flag IS NOT INITIAL.
**//Transferring the Final table to Application Server.
      OPEN DATASET lv_filename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " Output type
      IF sy-subrc IS INITIAL.
**//Concatenating For Header in Application Server
        CONCATENATE 'Sales Document'(045) 'Item'(046) 'Material'(047) 'Requested Quantity'(048) 'Open Quantity'(049) 'Confirmed Quantity'(050)
                    'Customer'(051) 'Customer Description'(052) 'Sales Organization'(053) 'Distribution Channel'(064) 'Plant'(054) 'Req.Delivery Date'(058) 'Batch'(059)
                    'Delivery Block'(060) 'Delivery Block Description'(061) 'Antigens'(062) 'Corresponding'(063)

                    INTO lv_string SEPARATED BY lc_pipe.

        TRANSFER lv_string TO lv_filename.
        CLEAR lv_string.

        LOOP AT fp_i_final_output INTO lwa_output.

          CONCATENATE lwa_output-vbeln
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
                      lwa_output-corres
                INTO lv_string SEPARATED BY lc_pipe.
          TRANSFER lv_string TO lv_filename.
          CLEAR: lv_string,
                 lwa_output.

        ENDLOOP. " LOOP AT fp_i_final_output INTO lwa_output

        CLOSE DATASET lv_filename.
**&-- File uploaded
        gv_flag = abap_true.

      ENDIF. " IF sy-subrc IS INITIAL

    ENDIF. " IF lv_flag IS NOT INITIAL

  ENDIF. " IF NOT lv_filename IS INITIAL

  CLEAR lv_lines.

  "If Error table is filled then It will write in ERROR folder
  IF fp_i_input_error IS NOT INITIAL.

    PERFORM f_appl_server_error_upload USING fp_i_input_error[].

  ENDIF. " IF fp_i_input_error IS NOT INITIAL

ENDFORM. " F_GET_APPS_SERVER
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_FILENAME  text
*      <--P_LV_FLAG  text
*----------------------------------------------------------------------*
FORM f_check_file  USING    fp_filename TYPE localfile " Local file for upload/download
                   CHANGING fp_flag     TYPE flag.     " General Flag

  CONSTANTS: lc_act  TYPE char5 VALUE 'WRITE'. " Act of type Character
  DATA:      lv_file TYPE fileextern. " Physical file name

  CLEAR lv_file.

  lv_file = fp_filename.
*  Authorization for writing to dataset
  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
    EXPORTING
      activity         = lc_act
      filename         = lv_file
    EXCEPTIONS
      no_authority     = 1
      activity_unknown = 2
      OTHERS           = 3.

  IF sy-subrc IS INITIAL.
    fp_flag = abap_true.
  ELSE. " ELSE -> IF sy-subrc IS INITIAL
    fp_flag = abap_false.
  ENDIF. " IF sy-subrc IS INITIAL

ENDFORM. " F_CHECK_FILE
*&<--End of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
*&---------------------------------------------------------------------*
*&      Form  F_GET_ERROR_RECORDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_INPUT[]  text
*      -->P_I_LOG_CHAR[]  text
*      <--P_I_INPUT_ERROR[]  text
*----------------------------------------------------------------------*
FORM f_get_error_records  USING    fp_i_input      TYPE ty_t_input
                                   fp_i_log_char   TYPE ty_t_log_char
                          CHANGING fp_i_input_error TYPE ty_t_input.

*&--Local data declarations
  DATA: lwa_input   TYPE ty_input,        "Work Area for input file
        li_log_char TYPE ty_t_log_char, "Internal table Log file
        lwa_log     TYPE ty_log_char,     " Work area for log
        lwa_error   TYPE ty_input.        "Work area for error recods

  CONSTANTS: lc_s TYPE char1 VALUE 'S'. " S of type CHAR1  " Local constant for success records

*&--Get the error records from the file
  li_log_char[] = fp_i_log_char[].
  SORT li_log_char BY vbeln posnr.
  DELETE li_log_char WHERE status EQ lc_s.
  IF li_log_char IS NOT INITIAL.
    LOOP AT fp_i_input INTO lwa_input.

      READ TABLE li_log_char INTO lwa_log WITH KEY   vbeln = lwa_input-vbeln
                                                     posnr = lwa_input-posnr
                                                     BINARY SEARCH.
      IF sy-subrc IS INITIAL.

        lwa_error-vbeln = lwa_input-vbeln.
        lwa_error-posnr = lwa_input-posnr.
        lwa_error-matnr = lwa_input-matnr.
        lwa_error-kwmeng = lwa_input-kwmeng.
        lwa_error-omeng = lwa_input-omeng.
        lwa_error-bmeng = lwa_input-bmeng.
        lwa_error-kunnr = lwa_input-kunnr.
        lwa_error-name1 = lwa_input-name1.
        lwa_error-vkorg = lwa_input-vkorg.
        lwa_error-vtweg = lwa_input-vtweg.
        lwa_error-werks = lwa_input-werks.
        lwa_error-edatu = lwa_input-edatu.
        lwa_error-charg = lwa_input-charg.
        lwa_error-lifsk = lwa_input-lifsk.
        lwa_error-vtext = lwa_input-vtext.
        lwa_error-antigens = lwa_input-antigens.
        lwa_error-corres = lwa_input-corres.

        APPEND lwa_error TO fp_i_input_error.
        CLEAR: lwa_error,
               lwa_input,
               lwa_log.

      ENDIF. " IF sy-subrc IS INITIAL

    ENDLOOP. " LOOP AT fp_i_input INTO lwa_input
  ENDIF. " IF li_log_char IS NOT INITIAL

ENDFORM. " F_GET_ERROR_RECORDS
*&---------------------------------------------------------------------*
*&      Form  F_APPL_SERVER_ERROR_UPLOAD
*&---------------------------------------------------------------------*
*       Write File in ERROR Folder
*----------------------------------------------------------------------*
*      -->FP_I_INPUT_ERROR[]  Internal table with Error List
*----------------------------------------------------------------------*
FORM f_appl_server_error_upload  USING    fp_i_input_error TYPE ty_t_input.

  DATA: lv_path     TYPE string,
        lwa_output  TYPE ty_input,  "Input work area
        lv_flag     TYPE flag,       " General Flag
        lv_filename TYPE localfile,  " Local file for upload/download
        lv_lines    TYPE i,          "Local varibale to keep error records
        lv_string   TYPE char1792,   " String of type CHAR1792
        lv_dirname  TYPE eps2filnam. " Directory name

  CONSTANTS: lc_format      TYPE string VALUE '.txt', " File Format
             lc_slash       TYPE char1  VALUE '/',                  " Slash of type CHAR1
             lc_score       TYPE char1  VALUE '_',                  " Score of type CHAR1
             lc_error       TYPE char6 VALUE 'ERROR',                "Folder path for Error
             lc_pipe        TYPE char1  VALUE '|',                  "Pipe delimeter
             lc_object_name TYPE string  VALUE 'OTC_EDD_0398', "Local Constant for Object
             lc_appl        TYPE string VALUE '/appl/',
             lc_rep         TYPE string VALUE '/ENH/OTC/OTC_EDD_0398/'.


  DESCRIBE TABLE fp_i_input_error LINES lv_lines.

*&-- Create default path
  CONCATENATE lc_appl sy-sysid lc_rep lc_error lc_slash INTO lv_path.
  CONCATENATE lv_path lc_object_name lc_score sy-datum sy-uzeit lc_score sy-uname lc_format INTO lv_filename.

  IF lv_filename IS NOT INITIAL.

**//Check file for authorization
    PERFORM f_check_file USING lv_filename
                      CHANGING lv_flag.

    IF lv_flag IS NOT INITIAL.
**//Transferring the Final table to Application Server.
      OPEN DATASET lv_filename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " Output type
      IF sy-subrc IS INITIAL.

**//Concatenating For Header in Application Server
        CONCATENATE 'Sales Document'(045) 'Item'(046) 'Material'(047) 'Requested Quantity'(048) 'Open Quantity'(049) 'Confirmed Quantity'(050)
                    'Customer'(051) 'Customer Description'(052) 'Sales Organization'(053) 'Distribution Channel'(064) 'Plant'(054) 'Req.Delivery Date'(058) 'Batch'(059)
                    'Delivery Block'(060) 'Delivery Block Description'(061) 'Antigens'(062) 'Corresponding'(063)

                    INTO lv_string SEPARATED BY lc_pipe.

        TRANSFER lv_string TO lv_filename.
        CLEAR lv_string.

        LOOP AT fp_i_input_error INTO lwa_output.

          CONCATENATE lwa_output-vbeln
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
                      lwa_output-corres
                INTO lv_string SEPARATED BY lc_pipe.
          TRANSFER lv_string TO lv_filename.
          CLEAR: lv_string,
                 lwa_output.

        ENDLOOP. " LOOP AT fp_i_input_error INTO lwa_output

        CLOSE DATASET lv_filename.
*&-- File uploaded
        gv_flag = abap_true.

      ENDIF. " IF sy-subrc IS INITIAL
    ELSE. " ELSE -> IF lv_flag IS NOT INITIAL
*&-- File not uploaded
      MESSAGE i918 WITH lv_path. "No authorization to write file &
      LEAVE LIST-PROCESSING.
    ENDIF. " IF lv_flag IS NOT INITIAL
  ENDIF. " IF lv_filename IS NOT INITIAL
  CLEAR lv_lines.

ENDFORM. " F_APPL_SERVER_ERROR_UPLOAD
*&---------------------------------------------------------------------*
*&      Form  F_MOVE_FILES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_FILE_APPL  text
*      -->P_I_LOG_CHAR[]  text
*----------------------------------------------------------------------*
FORM f_move_files  USING    fp_gv_file   TYPE localfile " Local file for upload/download
                            fp_i_log_char TYPE ty_t_log_char.

*&--Local Data
  DATA: lv_file      TYPE localfile,      "File Name
        lv_flag      TYPE flag,           " General Flag
        lv_string    TYPE char1792,       " String of type CHAR1792
        lv_name      TYPE localfile,      "Path Name
        lv_return    TYPE sysubrc,        "Return Code
        lwa_log_char TYPE ty_log_char. "Report

  CONSTANTS: lc_tbp_fld  TYPE char5        VALUE 'TBP', " constant declaration for TBP folder
             lc_pipe     TYPE char1  VALUE '|',         "Pipe delimeter
             lc_done_fld TYPE char5       VALUE 'DONE'. " constant declaration for DONE folder

  IF rb_back IS NOT INITIAL AND
     fp_i_log_char IS NOT INITIAL.
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


  ENDIF. " IF rb_back IS NOT INITIAL AND
ENDFORM. " F_MOVE_FILES
*&<--End of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
*&---------------------------------------------------------------------*
*&      Form  F_FILL_FIELDCATLOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_3485   text
*      -->P_3486   text
*      -->P_3487   text
*----------------------------------------------------------------------*
FORM f_fill_fieldcatlog  USING fp_fieldname  TYPE slis_fieldname " Fieldname
                               fp_tabname    TYPE slis_tabname   " Table name
                               fp_seltext    TYPE scrtext_l.     " Long Field Label
* Local Data
  DATA: lwa_fieldcat TYPE slis_fieldcat_alv.

  gv_col_pos              = gv_col_pos + 1.
  lwa_fieldcat-col_pos    = gv_col_pos.
  lwa_fieldcat-fieldname  = fp_fieldname.
  lwa_fieldcat-tabname    = fp_tabname.
  lwa_fieldcat-seltext_l  = fp_seltext.
  APPEND lwa_fieldcat TO i_alv_fieldcat.
  CLEAR lwa_fieldcat.
ENDFORM. " F_FILL_FIELDCATLOG
*&---------------------------------------------------------------------*
*&      Form  f_top_of_page_bg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_top_of_page_bg ##called.
  CONSTANTS: lc_hline   TYPE char50 " Underline
                       VALUE '--------------------------------------------------'.

* Run Information
  WRITE: / 'Run Information'(011).
* Horizontal Line
  WRITE: / lc_hline.
* Client
  WRITE: / 'Client'(012),
           50(1) c_colon,
           sy-mandt.
* Run By / User Id
  WRITE: / 'Run By / User ID'(013),
           50(1) c_colon,
           sy-uname.
* Date / Time
  WRITE: / 'Date / Time'(014),
           50(1) c_colon,
           sy-datum,
           sy-uzeit.
ENDFORM. "f_top_of_page_bg
*&---------------------------------------------------------------------*
*&      Form  F_SUBMIT_FOR_UPLD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_AFILE  text
*----------------------------------------------------------------------*
FORM f_submit_for_upld  USING    fp_gv_afile TYPE localfile. " Local file for upload/download

  DATA: li_constant  TYPE TABLE OF zdev_enh_status, " Enhancement Status
        lv_prnt_par  TYPE pri_params,                " Structure for Passing Print Parameters
        lv_jobname   TYPE btcjob,                    " Background job name
        lv_jobrlsd   TYPE char1,                     " Reference type CHAR1 for background processing
        lv_mailid    TYPE ad_smtpadr,                " E-Mail Address
        lwa_constant TYPE zdev_enh_status,          " Enhancement Status
        lv_jobnum    TYPE btcjobcnt.                 " Job ID

*Local Constant Declaration
  CONSTANTS : lc_object_name TYPE string  VALUE 'OTC_EDD_0398', "Local Constant for Object
              lc_score       TYPE char1  VALUE '_'.                  " Score of type CHAR1

*&--Taking it another internal table
  i_log_backg[] = i_log_char[].
*&--We require these records in our submit program
  EXPORT i_log_backg TO DATABASE indx(zs) FROM wa_indx ID 'ZIDY'.

*&--Preparing the job name
  CONCATENATE lc_object_name lc_score sy-datum sy-uzeit INTO lv_jobname.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname          = lv_jobname
    IMPORTING
      jobcount         = lv_jobnum
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 4.

  IF sy-subrc IS INITIAL.
    TRY.
        "Submit for Background Process
        SUBMIT zotce0398b_det_batches_backg
         WITH  p_apsfil  = fp_gv_afile
         WITH  p_jobnam  = lv_jobname
         WITH  p_jobnum  = lv_jobnum
         WITH  p_mailid  = sy-uname
         TO SAP-SPOOL
         SPOOL PARAMETERS lv_prnt_par
         WITHOUT SPOOL DYNPRO
        VIA JOB lv_jobname NUMBER lv_jobnum
        AND RETURN.
    ENDTRY.

    IF sy-subrc IS INITIAL.
      CALL FUNCTION 'JOB_CLOSE'
        EXPORTING
          jobcount             = lv_jobnum
          jobname              = lv_jobname
          sdlstrtdt            = sy-datum
          sdlstrttm            = sy-uzeit
        IMPORTING
          job_was_released     = lv_jobrlsd
        EXCEPTIONS
          cant_start_immediate = 1
          invalid_startdate    = 2
          jobname_missing      = 3
          job_close_failed     = 4
          job_nosteps          = 5
          job_notex            = 6
          lock_failed          = 7
          invalid_target       = 8
          OTHERS               = 9.

      IF sy-subrc IS INITIAL.
        MESSAGE s000 WITH 'Job Scheduled Successfully Via Job Name'(055) lv_jobname
                          'and Job Number'(056) lv_jobnum.
        LEAVE LIST-PROCESSING.

      ENDIF. " IF sy-subrc IS INITIAL

    ELSE. " ELSE -> IF sy-subrc IS INITIAL
      PERFORM f_cancel_job  USING lv_jobname
                                  lv_jobnum.

    ENDIF. " IF sy-subrc IS INITIAL
  ELSE. " ELSE -> IF sy-subrc IS INITIAL
    MESSAGE s000 WITH 'Job could not be Scheduled Successfully Via Job Name'(057) lv_jobname.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS INITIAL

ENDFORM. " F_SUBMIT_FOR_UPLD
*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_JOB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_JOBNAME  text
*      -->P_LV_JOBNUM  text
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

      PERFORM f_send_cancel_mail USING fp_p_jobname
                                       fp_p_jobnum.

    ENDIF. " IF lv_status = lc_status

  ENDIF. " IF sy-subrc IS INITIAL


ENDFORM. " F_CANCEL_JOB                  " F_CANCEL_JOB
*&---------------------------------------------------------------------*
*&      Form  F_SEND_CANCEL_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_JOBNAM  text
*      -->P_P_JOBNUM  text
*----------------------------------------------------------------------*
FORM f_send_cancel_mail  USING   fp_p_jobname  TYPE btcjob      " Background job name
                                  fp_p_jobnum   TYPE btcjobcnt. " Job ID.  .

  DATA: li_msg_bdy       TYPE  bcsy_text,                   " Mail Body
        lwa_doc_data     TYPE sodocchgi1,                   " Data of an object which can be changed
        lwa_packing_list TYPE sopcklsti1,                   " SAPoffice: Descrip
        lwa_receivers    TYPE somlreci1,                    " SAPoffice: Structure of the API Recipient List
        li_receivers     TYPE STANDARD TABLE OF somlreci1,  " SAPoffice: Structure of the API Recipient List
        li_text_line     TYPE STANDARD TABLE OF tline,      " SAPscript: Text Lines
        li_packing_list  TYPE STANDARD TABLE OF sopcklsti1, " SAPoffice: Description of Imported Object Components
        lv_username      TYPE bapibname-bapibname,          " User Name in User Master Record
        li_return        TYPE STANDARD TABLE OF bapiret2,   " Return Parameter
        li_addsmtp       TYPE STANDARD TABLE OF bapiadsmtp, " BAPI Structure for E-Mail Addresses (Bus. Address Services)
        lwa_addsmtp      TYPE bapiadsmtp,                   " BAPI Structure for E-Mail Addresses (Bus. Address Services)
        lwa_msg_bdy      TYPE soli,                         " SAPoffice: line, length 255
        lv_date          TYPE xubname,                      " External Date
        lv_subjct        TYPE so_obj_des.                   " Short description of contents


  CONSTANTS: lc_rec_type TYPE so_escape  VALUE 'U',   " External receiver
             lc_doc_type TYPE so_obj_tp  VALUE 'RAW', " Document type
             lc_coma     TYPE char1      VALUE ',',   " Coma of type CHAR1
             lc_com_type TYPE so_snd_art VALUE 'INT'. " Communication type


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
  'Batch Job Cancelled -' lv_date
  INTO lv_subjct
  SEPARATED BY space.

*Body Content for Mail
  CONCATENATE 'Hi'(004) lc_coma
  INTO lwa_msg_bdy
   IN CHARACTER MODE.
  APPEND lwa_msg_bdy TO li_msg_bdy.

  CONCATENATE
 'Job Cancelled Via Job Name'(001)
 fp_p_jobname
 'and Job Number'(002)
 fp_p_jobnum
 INTO lwa_msg_bdy
 SEPARATED BY space.
  APPEND lwa_msg_bdy TO li_msg_bdy.

  lwa_msg_bdy = space.
  APPEND lwa_msg_bdy TO li_msg_bdy.

  CONCATENATE
          'Job Submitted by USER -'(007)
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


ENDFORM. " F_SEND_CANCEL_MAIL                   " F_SEND_CANCEL_MAIL
*&<--End of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
*--> Begin of Insert for INC0433610-01-Defect#10665 D3_OTC_EDD_0398 by U033959 dated 29-Oct-2019
*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_APP_SERVER
*&---------------------------------------------------------------------*
*       Split the records in different files
*----------------------------------------------------------------------*
*      -->FP_I_SPLIT_FILES    Split files
*      -->FP_I_INPUT_ERROR[]  Error records
*----------------------------------------------------------------------*
FORM f_split_app_server  USING    fp_i_split_files  TYPE ty_tt_split_files
                                  fp_i_input_error  TYPE ty_t_input.

  DATA: lv_path     TYPE string,     " File path
        lwa_output  TYPE ty_input,   " Input work area
        lv_flag     TYPE flag,       " General Flag
        lv_filename TYPE localfile,  " Local file for upload/download
        lv_string   TYPE char1792,   " String of type CHAR1792
        lv_lines    TYPE i,          " Local varibale to keep error records
        lv_dirname  TYPE eps2filnam, " Directory name
        lv_tabix    TYPE char3.      " Tabix

  CONSTANTS: lc_format      TYPE string VALUE '.txt',                  " File Format
             lc_slash       TYPE char1  VALUE '/',                     " Slash of type CHAR1
             lc_score       TYPE char1  VALUE '_',                     " Score of type CHAR1
             lc_tbp         TYPE char4  VALUE 'TBP',                   " Folder path for TBP
             lc_pipe        TYPE char1  VALUE '|',                     " Pipe delimeter
             lc_object_name TYPE string  VALUE 'OTC_EDD_0398',         " Local Constant for Object
             lc_appl        TYPE string VALUE '/appl/',                " Folder path in AL11
             lc_rep         TYPE string VALUE '/ENH/OTC/OTC_EDD_0398/'. " Folder path in AL11


*&--Valid records will be move to the TBP folder.

*&-- Create default path
  LOOP AT fp_i_split_files ASSIGNING FIELD-SYMBOL(<lfs_split_files>).
    lv_tabix = sy-tabix.
    CONCATENATE lc_appl sy-sysid lc_rep lc_tbp lc_slash INTO lv_path.
    CONCATENATE lv_path lc_object_name lc_score sy-datum sy-uzeit lc_score sy-uname lc_score lv_tabix lc_format
    INTO lv_filename .
    CONDENSE lv_filename NO-GAPS.

    <lfs_split_files>-fname_apl = lv_filename.

    DATA(li_input) = <lfs_split_files>-split.

    IF lv_filename IS NOT INITIAL.
*    Check file for authorization
      PERFORM f_check_file USING lv_filename
                        CHANGING lv_flag.
      IF lv_flag IS NOT INITIAL.
*    Transferring the Final table to Application Server.
        OPEN DATASET lv_filename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " Output type
        IF sy-subrc IS INITIAL.
*    Concatenating For Header in Application Server
          CONCATENATE 'Sales Document'(045) 'Item'(046) 'Material'(047) 'Requested Quantity'(048) 'Open Quantity'(049) 'Confirmed Quantity'(050)
                      'Customer'(051) 'Customer Description'(052) 'Sales Organization'(053) 'Distribution Channel'(064) 'Plant'(054) 'Req.Delivery Date'(058) 'Batch'(059)
                      'Delivery Block'(060) 'Delivery Block Description'(061) 'Antigens'(062) 'Corresponding'(063)

                      INTO lv_string SEPARATED BY lc_pipe.

          TRANSFER lv_string TO lv_filename.
          CLEAR lv_string.

          LOOP AT li_input INTO lwa_output.

            CONCATENATE lwa_output-vbeln
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
                        lwa_output-corres
                  INTO lv_string SEPARATED BY lc_pipe.
            TRANSFER lv_string TO lv_filename.
            CLEAR: lv_string,
                   lwa_output.

          ENDLOOP. " LOOP AT fp_i_final_output INTO lwa_output

          CLOSE DATASET lv_filename.
*     File uploaded
          gv_flag = abap_true.

        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF.
    ENDIF.
  ENDLOOP.


  "If Error table is filled then It will write in ERROR folder
  IF fp_i_input_error IS NOT INITIAL.

    PERFORM f_appl_server_error_upload USING fp_i_input_error[].

  ENDIF. " IF fp_i_input_error IS NOT INITIAL

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SUBMIT_FOR_SPLIT
*&---------------------------------------------------------------------*
*       Submit the split up files to background job
*----------------------------------------------------------------------*
*      -->FP_FNAME_APL  Filename
*      -->FP_TABIX      tab index
*      <--FP_I_JOB      Job name
*----------------------------------------------------------------------*
FORM f_submit_for_split  USING    fp_fname_apl TYPE localfile
                                  fp_tabix     TYPE sy-tabix
                         CHANGING fp_i_job     TYPE ty_tt_job.

  DATA: li_constant  TYPE TABLE OF zdev_enh_status,  " Enhancement Status
        lv_prnt_par  TYPE pri_params,                " Structure for Passing Print Parameters
        lv_jobname   TYPE btcjob,                    " Background job name
        lv_jobrlsd   TYPE char1,                     " Reference type CHAR1 for background processing
        lv_mailid    TYPE ad_smtpadr,                " E-Mail Address
        lwa_constant TYPE zdev_enh_status,           " Enhancement Status
        lv_jobnum    TYPE btcjobcnt,                 " Job ID
        lv_tabix     TYPE string.

*Local Constant Declaration
  CONSTANTS : lc_object_name TYPE string  VALUE 'OTC_EDD_0398', " Local Constant for Object
              lc_score       TYPE char1  VALUE '_'.             " Score of type CHAR1


  lv_tabix = fp_tabix.
*&--Taking it another internal table
  i_log_backg[] = i_log_char[].
*&--We require these records in our submit program
  EXPORT i_log_backg TO DATABASE indx(zs) FROM wa_indx ID 'ZIDY'.

*&--Preparing the job name
  CONCATENATE lc_object_name
              lc_score
              sy-datum
              sy-uzeit
              lc_score
              lv_tabix
         INTO lv_jobname.
  CONDENSE lv_jobname NO-GAPS.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname          = lv_jobname
    IMPORTING
      jobcount         = lv_jobnum
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 4.

  IF sy-subrc IS INITIAL.
    TRY.
        " Submit for Background Process
        SUBMIT zotce0398b_det_batches_backg
         WITH  p_apsfil  = fp_fname_apl
         WITH  p_jobnam  = lv_jobname
         WITH  p_jobnum  = lv_jobnum
         WITH  p_mailid  = sy-uname
         TO SAP-SPOOL
         SPOOL PARAMETERS lv_prnt_par
         WITHOUT SPOOL DYNPRO
        VIA JOB lv_jobname NUMBER lv_jobnum
        AND RETURN.
    ENDTRY.

    IF sy-subrc IS INITIAL.
      CALL FUNCTION 'JOB_CLOSE'
        EXPORTING
          jobcount             = lv_jobnum
          jobname              = lv_jobname
          sdlstrtdt            = sy-datum
          sdlstrttm            = sy-uzeit
        IMPORTING
          job_was_released     = lv_jobrlsd
        EXCEPTIONS
          cant_start_immediate = 1
          invalid_startdate    = 2
          jobname_missing      = 3
          job_close_failed     = 4
          job_nosteps          = 5
          job_notex            = 6
          lock_failed          = 7
          invalid_target       = 8
          OTHERS               = 9.

      IF sy-subrc IS INITIAL.
        APPEND INITIAL LINE TO fp_i_job ASSIGNING FIELD-SYMBOL(<lfs_job>).
        <lfs_job>-job_name   = lv_jobname.
        <lfs_job>-job_number = lv_jobnum.
        <lfs_job>-message    = 'Job Scheduled Successfully Via Job Name'(055).
        UNASSIGN <lfs_job>.
      ENDIF. " IF sy-subrc IS INITIAL

    ELSE. " ELSE -> IF sy-subrc IS INITIAL
      PERFORM f_cancel_job  USING lv_jobname
                                  lv_jobnum.

    ENDIF. " IF sy-subrc IS INITIAL
  ELSE. " ELSE -> IF sy-subrc IS INITIAL

    APPEND INITIAL LINE TO fp_i_job ASSIGNING <lfs_job>.
    <lfs_job>-job_name   = lv_jobname.
    <lfs_job>-job_number = lv_jobnum.
    <lfs_job>-message    = 'Job could not be Scheduled Successfully Via Job Name'(057).
    UNASSIGN <lfs_job>.
  ENDIF. " IF sy-subrc IS INITIAL

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_LIST
*&---------------------------------------------------------------------*
*       Display background jobs created
*----------------------------------------------------------------------*
*      -->FP_I_JOB  table with background job names
*----------------------------------------------------------------------*
FORM f_display_list  USING  fp_i_job TYPE ty_tt_job.

  DATA go_alv TYPE REF TO cl_salv_table.

  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = go_alv
        CHANGING
          t_table      = fp_i_job ).

    CATCH cx_salv_msg.
  ENDTRY.

  DATA: lr_functions TYPE REF TO cl_salv_functions_list.

  lr_functions = go_alv->get_functions( ).
  lr_functions->set_all( 'X' ).

  IF go_alv IS BOUND.
    go_alv->set_screen_popup(
      start_column = 25
      end_column  = 100
      start_line  = 6
      end_line    = 10 ).

    go_alv->display( ).

  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_MAIN_FILE
*&---------------------------------------------------------------------*
*       Split the records in the main file
*----------------------------------------------------------------------*
*  -->  FP_I_INPUT_ERROR         error records
*  -->  FP_I_FINAL_OUTPUT        Succes records
*  -->  FP_I_SPLIT_FILES         Split records
*----------------------------------------------------------------------*
FORM f_split_main_file  USING    fp_i_input_error   TYPE ty_t_input
                        CHANGING fp_i_final_output  TYPE ty_t_input         " Success records.
                                 fp_i_split_files   TYPE ty_tt_split_files. " Split files
  CONSTANTS : lc_records TYPE z_criteria VALUE 'RECORDS'. " Criteria for number of records
  DATA : li_input_temp TYPE STANDARD TABLE OF ty_input,   " Inpur records
         lv_index      TYPE syst_tabix,                   " Index
         lv_count1     TYPE i,                            " Records count
         lv_count2     TYPE i.                            " Records count

*Get the values maintained in EMI table
  PERFORM f_get_emi_values.
  READ TABLE i_edd_emi ASSIGNING FIELD-SYMBOL(<lfs_edd_emi>) WITH KEY criteria = lc_records.
  IF sy-subrc IS INITIAL.
*Read number of records from EMI
    DATA(lv_records) = <lfs_edd_emi>-sel_low.

    SORT fp_i_final_output BY vbeln posnr.
    WHILE fp_i_final_output[] IS NOT INITIAL.
*Get the record count of all the successfull records
*and based on the EMI count move the records into li_input_temp
      DATA(lv_count) = lines( fp_i_final_output ).
      IF lv_count < lv_records .
        APPEND LINES OF fp_i_final_output TO li_input_temp.
      ELSE.
        APPEND LINES OF fp_i_final_output FROM 1 TO lv_records TO li_input_temp.
      ENDIF.
*Find the last records appended in the table li_input_temp
      lv_count2 = lines( li_input_temp ).
      READ TABLE li_input_temp INTO DATA(lwa_input_temp) INDEX lv_count2.
*Search in the li_final_output table if there are anymore records with the same
*same sales order number as in the last record of li_input_temp.
*If yes, then move those records to li_input_temp as well, as there the requirement
*if to process all the line items of a SO in one file.
      lv_count1 = lv_records + 1.
      LOOP AT fp_i_final_output INTO DATA(lwa_final_output) FROM lv_count1.
        IF lwa_final_output-vbeln = lwa_input_temp-vbeln.
          APPEND INITIAL LINE TO li_input_temp ASSIGNING FIELD-SYMBOL(<lfs_input_temp>).
          <lfs_input_temp> = lwa_final_output.
          UNASSIGN <lfs_input_temp>.
          lv_count1 = lv_count1 + 1.
        ELSE.
          EXIT.
        ENDIF.
      ENDLOOP.
*Append the records of split file in table i_split_files.
      APPEND INITIAL LINE TO fp_i_split_files ASSIGNING FIELD-SYMBOL(<lfs_split_files>).
      lv_index = lv_index + 1.
      <lfs_split_files>-index = lv_index.
      <lfs_split_files>-split[] = li_input_temp[].
      UNASSIGN <lfs_split_files>.
*Delete those records from the main table i_final_ouput as they are alreay moved to split file
      lv_count1 = lv_count1 - 1.
      DELETE fp_i_final_output FROM 1 TO lv_count1.

      CLEAR : lv_count,
              lv_count1.
      FREE li_input_temp.

    ENDWHILE.
*Transfer the records from the split files to application server
    PERFORM f_split_app_server USING fp_i_split_files
                                     fp_i_input_error[].
    IF fp_i_final_output IS INITIAL AND
       fp_i_split_files IS INITIAL.
      PERFORM f_get_apps_server  USING     p_afile
                                           fp_i_final_output[]
                                           fp_i_input_error[].
*Submit Program in Background and Trigger Mail
      PERFORM f_submit_for_upld USING gv_file_appl.
    ELSE.
      LOOP AT fp_i_split_files ASSIGNING <lfs_split_files>.
*Submit Program in Background and Trigger Mail
        PERFORM f_submit_for_split USING <lfs_split_files>-fname_apl
                                       sy-tabix
                                 CHANGING i_job.
        WAIT UP TO 5 SECONDS.
      ENDLOOP.
*Display the background jobs create in ALV format
      IF i_job IS NOT INITIAL.
        PERFORM f_display_list USING i_job.
      ENDIF.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ELSE.
    MESSAGE e885. "'Number of records not maintained for file split scenario'
  ENDIF.

ENDFORM.
*<-- End of Insert for INC0433610-01-Defect#10665 D3_OTC_EDD_0398 by U033959 dated 29-Oct-2019
