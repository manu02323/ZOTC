************************************************************************
* PROGRAM    :  ZOTCN0351B_FLIP_ITEM_CAT_FORM                          *
* TITLE      :  Update open Sales Order                                *
* DEVELOPER  :  Salman Zahir                                           *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0351                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update open Sales Order                                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 12-SEP-2016 U033959  E1DK921540 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*
* 26-Jan-2017 DMOIRAN  E1DK921540 Defect 8919.
*Ignore line item with reason for rejection.
*&---------------------------------------------------------------------*
* 21-Feb-2017 DMOIRAN  E1DK925972 Defect 9890.
* Used 01 for activity and asterik (*) for Dist channel and division in*
* authorization check.                                                 *
* =========== ======== ========== =====================================*
*&---------------------------------------------------------------------*
*&      Form  f_check_delivery_status
*&---------------------------------------------------------------------*
*       Check delivery statys
*----------------------------------------------------------------------*
*      -->FP_R_LFSTK        Delivery status
*----------------------------------------------------------------------*
FORM f_check_delv_status  USING fp_r_lfstk TYPE ty_tt_lfstk. " Delivery status
  DATA : lv_message TYPE string.

  IF p_lfstk IN fp_r_lfstk.
    CONCATENATE p_lfstk
                'as delivery status not allowed'(006)
                INTO lv_message
                SEPARATED BY space.
    MESSAGE e000 WITH lv_message.
  ENDIF. " IF p_lfstk IN fp_r_lfstk

ENDFORM. " F_CHECK_DELV_STATUS
*&---------------------------------------------------------------------*
*&      Form  f_fetch_open_salerorder
*&---------------------------------------------------------------------*
*       Fetch open sales order item
*----------------------------------------------------------------------*
*      -->FP_LFSTA        Delivery status
*      <--FP_I_SO_HEADER  SO header
*      <--FP_I_SO_ITEM    SO items
*----------------------------------------------------------------------*
FORM f_fetch_open_salerorder  USING    fp_lfsta       TYPE lfsta           " Delivery status
                              CHANGING fp_i_so_header TYPE ty_tt_so_header " SO Header
                                       fp_i_so_item   TYPE ty_tt_so_item.  " SO items


  TYPES : BEGIN OF lty_vbak,
            vbeln TYPE vbeln_va, " Sales Document
            auart TYPE auart,    " Sales Document Type
            vkorg TYPE vkorg,    " Sales Organization
            vtweg TYPE vtweg,    " Distribution Channel
          END OF lty_vbak,
          BEGIN OF lty_vbuk,
            vbeln TYPE vbeln_va, " Sales Document
            lfstk TYPE lfstk,    " Delivery status
          END OF lty_vbuk,
          BEGIN OF lty_vbup,
            vbeln TYPE vbeln_va, " Sales Document
            posnr TYPE posnr_va, " Sales Document Item
            lfsta TYPE lfsta,    " Delivery status
          END OF lty_vbup,
          BEGIN OF lty_vbap,
            vbeln TYPE vbeln_va, " Sales Document
            posnr TYPE posnr_va, " Sales Document Item
            matnr TYPE matnr,    " Material Number
            pstyv TYPE pstyv,    " Sales document item category
            abgru TYPE abgru_va, " Reason for rejection of quotations and sales orders "++Defect 8919
          END OF lty_vbap.

  DATA : li_so_header        TYPE STANDARD TABLE OF lty_vbak,
         li_so_header_status TYPE STANDARD TABLE OF lty_vbuk,
         li_so_item          TYPE STANDARD TABLE OF lty_vbap,
         li_so_item_status   TYPE STANDARD TABLE OF lty_vbup.

  FIELD-SYMBOLS :  <lfs_so_header>        TYPE lty_vbak,
                   <lfs_so_header_status> TYPE lty_vbuk,
                   <lfs_so_item>          TYPE lty_vbap,
                   <lfs_so_item_status>   TYPE lty_vbup,
                   <lfs_i_so_header>      TYPE ty_so_header,
                   <lfs_i_so_item>        TYPE ty_so_item.

  SELECT  vbeln " Sales Document
          auart " Sales Document Type
          vkorg " Sales Organization
          vtweg " Distribution Channel
    FROM vbak   " Sales Document: Header Data
    INTO TABLE li_so_header
       WHERE vbeln IN s_vbeln
         AND erdat IN s_erdat
         AND auart IN s_auart
         AND vkorg IN s_vkorg
         AND vtweg IN s_vtweg.
  IF sy-subrc IS INITIAL.
    SORT li_so_header BY vbeln.
    IF li_so_header IS NOT INITIAL.
      SELECT vbeln   " Sales and Distribution Document Number
             lfstk   " Delivery status
           FROM vbuk " Sales Document: Header Status and Administrative Data
           INTO TABLE li_so_header_status
           FOR ALL ENTRIES IN li_so_header
           WHERE vbeln = li_so_header-vbeln.
      IF sy-subrc IS INITIAL.
        IF li_so_header_status IS NOT INITIAL.
          SELECT  vbeln " Sales and Distribution Document Number
                  posnr " Item number of the SD document
                  lfsta " Delivery status
            FROM vbup   " Sales Document: Item Status
            INTO TABLE li_so_item_status
            FOR ALL ENTRIES IN li_so_header_status
            WHERE vbeln = li_so_header_status-vbeln
              AND lfsta = fp_lfsta.
          IF sy-subrc IS INITIAL.
            SORT li_so_item_status BY vbeln posnr.
            IF li_so_item_status IS NOT INITIAL.
              SELECT  vbeln  " Sales Document
                      posnr  " Sales Document Item
                      matnr  " Material Number
                      pstyv  " Sales document item category
                      abgru  " Reason for rejection of quotations and sales orders "+Defect 8919
                   FROM vbap " Sales Document: Item Data
                   INTO TABLE li_so_item
                   FOR ALL ENTRIES IN li_so_item_status
                   WHERE vbeln = li_so_item_status-vbeln
                     AND posnr = li_so_item_status-posnr.
              IF sy-subrc IS INITIAL.
* Remove line item which has reason for rejection
                DELETE li_so_item WHERE abgru IS NOT INITIAL. "+Defect 8919
                SORT li_so_item BY vbeln posnr.
              ENDIF. " IF sy-subrc IS INITIAL
            ENDIF. " IF li_so_item_status IS NOT INITIAL
          ENDIF. " IF sy-subrc IS INITIAL
        ENDIF. " IF li_so_header_status IS NOT INITIAL
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF li_so_header IS NOT INITIAL
  ENDIF. " IF sy-subrc IS INITIAL

  LOOP AT li_so_header_status ASSIGNING <lfs_so_header_status>.
    APPEND INITIAL LINE TO fp_i_so_header ASSIGNING <lfs_i_so_header>.
    READ TABLE li_so_header ASSIGNING <lfs_so_header>
                             WITH KEY vbeln = <lfs_so_header_status>-vbeln
                             BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      <lfs_i_so_header>-vbeln = <lfs_so_header>-vbeln.
      <lfs_i_so_header>-auart = <lfs_so_header>-auart.
      <lfs_i_so_header>-vkorg = <lfs_so_header>-vkorg.
      <lfs_i_so_header>-vtweg = <lfs_so_header>-vtweg.
    ENDIF. " IF sy-subrc IS INITIAL
    <lfs_i_so_header>-lfstk = <lfs_so_header_status>-lfstk.
  ENDLOOP. " LOOP AT li_so_header_status ASSIGNING <lfs_so_header_status>
  LOOP AT li_so_item ASSIGNING <lfs_so_item>.
    APPEND INITIAL LINE TO fp_i_so_item ASSIGNING <lfs_i_so_item>.
    <lfs_i_so_item>-vbeln = <lfs_so_item>-vbeln.
    <lfs_i_so_item>-posnr = <lfs_so_item>-posnr.
    <lfs_i_so_item>-matnr = <lfs_so_item>-matnr.
    <lfs_i_so_item>-pstyv = <lfs_so_item>-pstyv.
    READ TABLE li_so_item_status ASSIGNING <lfs_so_item_status>
                                WITH KEY vbeln = <lfs_so_item>-vbeln
                                         posnr = <lfs_so_item>-posnr
                                         BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      <lfs_i_so_item>-lfsta = <lfs_so_item_status>-lfsta.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDLOOP. " LOOP AT li_so_item ASSIGNING <lfs_so_item>

  SORT fp_i_so_header BY vbeln.
ENDFORM. " F_FETCH_OPEN_SALERORDER
*&---------------------------------------------------------------------*
*&      Form  f_flip_item_category
*&---------------------------------------------------------------------*
*       Call BAPI to change item category
*----------------------------------------------------------------------*
*      -->FP_I_SO_HEADER  SO Header
*      -->FP_I_SO_ITEM    SO items
*      <--FP_I_BAPI_MSG   BAPI return msg
*----------------------------------------------------------------------*
FORM f_flip_item_category  USING    fp_i_so_header TYPE ty_tt_so_header
                                    fp_i_so_item   TYPE ty_tt_so_item
                           CHANGING fp_i_bapi_msg  TYPE ty_tt_bapi_msg.

  CONSTANTS : lc_separator        TYPE xfeld   VALUE '.', " Checkbox
              lc_name_appl        TYPE string  VALUE 'ZA_OTC_EDD_0339_FLIP_ITEM_CATG', " BRFPlus Application
              lc_name_func_item   TYPE string  VALUE 'ZF_OTC_EDD_0339_FLIP_ITEM_CATG', " BRFPlus Function
              lc_vkorg            TYPE char10  VALUE 'EL_VKORG',                       " VKORG
              lc_vtweg            TYPE char10  VALUE 'VTWEG',                          " VTWEG
              lc_el_auart         TYPE char10  VALUE 'AUART',                          " AUART
              lc_pstyv_t184       TYPE char10  VALUE 'PSTYV_T184',                     " PSTYV_T184
              lc_update           TYPE updkz_d VALUE 'U',                              " Update indicator
              lc_msg_e            TYPE char1   VALUE 'E',                              " Msg_e of type CHAR1
              lc_msg_a            TYPE char1   VALUE 'A',                              " Msg_a of type CHAR1
              lc_msg_s            TYPE char1   VALUE 'S',                              " Msg_s of type CHAR1
              lc_price_type_c     TYPE knprs   VALUE 'C'.                              " Pricing type

  DATA : li_bapiret2       TYPE STANDARD TABLE OF bapiret2,   " Return Parameter
         li_order_item_in  TYPE STANDARD TABLE OF bapisditm,  " Communication Fields: Sales and Distribution Document Item
         li_order_item_inx TYPE STANDARD TABLE OF bapisditmx. " Communication Fields: Sales and Distribution Document Item

  DATA: lv_pstyv           TYPE        pstyv,             " Sales document item category
        lref_utility       TYPE REF TO /bofu/cl_fdt_util, " BRFplus Utilities
        lref_admin_data    TYPE REF TO if_fdt_admin_data, " FDT: Administrative Data
        lref_function      TYPE REF TO if_fdt_function,   " FDT: Function
        lref_context       TYPE REF TO if_fdt_context,    " FDT: Context
        lref_result        TYPE REF TO if_fdt_result,     " FDT: Result
        lref_fdt           TYPE REF TO cx_fdt,            " FDT: Abstract Exception Class   ##NEEDED
        lv_query_in        TYPE        string,            " Query in
        lv_query_out       TYPE        if_fdt_types=>id,  " Quesry out
        lv_exception_msg   TYPE string.


  DATA : lwa_order_header_inx TYPE bapisdh1x, " Checkbox List: SD Order Header
         lwa_logic_switch     TYPE bapisdls.  " SD Checkbox for the Logic Switch

  FIELD-SYMBOLS : <lfs_so_item>        TYPE ty_so_item,   " SO items
                  <lfs_so_header>      TYPE ty_so_header, " SO header
                  <lfs_order_item_in>  TYPE bapisditm,    " Communication Fields: Sales and Distribution Document Item
                  <lfs_order_item_inx> TYPE bapisditmx.   " Communication Fields: Sales and Distribution Document Item


  CLEAR: lref_utility,
         lv_query_in,
         lv_query_out.

*-- Create an instance of BRFPlus Utility class
  lref_utility ?= /bofu/cl_fdt_util=>get_instance( ).

*-- Make BRF query by concatenation of BRF application name and BRF Function name
  CONCATENATE lc_name_appl lc_name_func_item
         INTO lv_query_in
         SEPARATED BY lc_separator.
*-- To get GUID of query string
  IF lref_utility IS BOUND.
    CALL METHOD lref_utility->convert_function_input
      EXPORTING
        iv_input  = lv_query_in
      IMPORTING
        ev_output = lv_query_out
      EXCEPTIONS
        failed    = 1
        OTHERS    = 2.
    IF sy-subrc IS INITIAL.
*-- Set the variable value(s)
      cl_fdt_factory=>get_instance_generic( EXPORTING iv_id = lv_query_out
                                            IMPORTING eo_instance = lref_admin_data ).
      lref_function ?= lref_admin_data.
      lref_context  ?= lref_function->get_process_context( ).

      LOOP AT fp_i_so_item ASSIGNING <lfs_so_item>.
        AT NEW vbeln.
          READ TABLE fp_i_so_header ASSIGNING <lfs_so_header> WITH KEY
                                           vbeln = <lfs_so_item>-vbeln
                                           BINARY SEARCH.
        ENDAT.
        IF <lfs_so_header> IS ASSIGNED.
* Set the value of Sales Organization
          lref_context->set_value( iv_name = lc_vkorg  ia_value = <lfs_so_header>-vkorg ).
* Set the value of Distribution Channel
          lref_context->set_value( iv_name = lc_vtweg  ia_value = <lfs_so_header>-vtweg ).
* Set the value of Sales Document Type
          lref_context->set_value( iv_name = lc_el_auart  ia_value = <lfs_so_header>-auart ).
* Set the value of Sales document item category(old)
          lref_context->set_value( iv_name = lc_pstyv_t184  ia_value = <lfs_so_item>-pstyv ).
          TRY.
              lref_function->process( EXPORTING io_context = lref_context
                                      IMPORTING eo_result = lref_result ).

              lref_result->get_value( IMPORTING ea_value = lv_pstyv ).

            CATCH cx_fdt INTO lref_fdt ##no_handler.
              CLEAR lv_pstyv.
              lv_exception_msg = lref_fdt->if_message~get_text( ).
              MESSAGE e000 WITH lv_exception_msg.
          ENDTRY.

          IF lv_pstyv IS NOT INITIAL.

            lwa_order_header_inx-updateflag = lc_update.
            lwa_logic_switch-pricing        = lc_price_type_c.

            APPEND INITIAL LINE TO li_order_item_in ASSIGNING <lfs_order_item_in>.
            <lfs_order_item_in>-itm_number = <lfs_so_item>-posnr.
            <lfs_order_item_in>-material   = <lfs_so_item>-matnr.
            <lfs_order_item_in>-item_categ = lv_pstyv.
            UNASSIGN <lfs_order_item_in>.
            CLEAR lv_pstyv.

            APPEND INITIAL LINE TO li_order_item_inx ASSIGNING <lfs_order_item_inx>.
            <lfs_order_item_inx>-itm_number = <lfs_so_item>-posnr.
            <lfs_order_item_inx>-updateflag = lc_update.
            <lfs_order_item_inx>-item_categ = abap_true.
            UNASSIGN <lfs_order_item_inx>.

          ENDIF. " IF lv_pstyv IS NOT INITIAL

          AT END OF vbeln.
            IF li_order_item_in IS NOT INITIAL.
              CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
                EXPORTING
                  salesdocument    = <lfs_so_item>-vbeln
                  order_header_inx = lwa_order_header_inx
                  logic_switch     = lwa_logic_switch
                TABLES
                  return           = li_bapiret2
                  order_item_in    = li_order_item_in
                  order_item_inx   = li_order_item_inx.

              READ TABLE li_bapiret2 WITH KEY type = lc_msg_e TRANSPORTING NO FIELDS. " Bapiret2 with ke of type
              IF sy-subrc IS INITIAL.

                PERFORM f_collect_bapi_msg USING    li_bapiret2
                                                    <lfs_so_header>
                                                    li_order_item_in
                                                    lc_msg_e
                                           CHANGING fp_i_bapi_msg.
                CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
                  .


              ELSE. " ELSE -> IF sy-subrc IS INITIAL

                READ TABLE li_bapiret2 WITH KEY type = lc_msg_a TRANSPORTING NO FIELDS. " Bapiret2 with ke of type
                IF sy-subrc IS INITIAL.

                  PERFORM f_collect_bapi_msg USING    li_bapiret2
                                                      <lfs_so_header>
                                                      li_order_item_in
                                                      lc_msg_a
                                             CHANGING fp_i_bapi_msg.
                  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
                    .

                ELSE. " ELSE -> IF sy-subrc IS INITIAL
                  gv_so_upd = abap_true.
                  PERFORM f_collect_bapi_msg USING    li_bapiret2
                                                      <lfs_so_header>
                                                      li_order_item_in
                                                      lc_msg_s
                                             CHANGING fp_i_bapi_msg.
                  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                    EXPORTING
                      wait = abap_true.

                ENDIF. " IF sy-subrc IS INITIAL
              ENDIF. " IF sy-subrc IS INITIAL
            ENDIF. " IF li_order_item_in IS NOT INITIAL
            CLEAR : li_bapiret2,
                    li_order_item_in,
                    li_order_item_inx.
            UNASSIGN : <lfs_so_header>.
            IF <lfs_so_header> IS ASSIGNED.
              UNASSIGN <lfs_so_header>.
            ENDIF. " IF <lfs_so_header> IS ASSIGNED
          ENDAT.
        ENDIF. " IF <lfs_so_header> IS ASSIGNED
      ENDLOOP. " LOOP AT fp_i_so_item ASSIGNING <lfs_so_item>
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF lref_utility IS BOUND


ENDFORM. " F_FLIP_ITEM_CATEGORY
*&---------------------------------------------------------------------*
*&      Form  f_collect_bapi_msg
*&---------------------------------------------------------------------*
*       Collect BAPI msg
*----------------------------------------------------------------------*
*      -->FP_LI_BAPIRET2  BAPI return msg
*      -->FP_SO_HEADER    SO Header
*      -->FP_I_SO_ITEM    SO Items
*      -->FP_MSG_TYPE     Msg type
*      <--FP_I_BAPI_MSG   BAPI msg
*----------------------------------------------------------------------*
FORM f_collect_bapi_msg  USING    fp_li_bapiret2      TYPE ty_tt_bapiret2  " BAPI return msg
                                  fp_so_header        TYPE ty_so_header    " SO header
                                  fp_i_so_item        TYPE ty_tt_bapisditm " SO items
                                  fp_msg_type         TYPE char1           " Msg type
                         CHANGING fp_i_bapi_msg       TYPE ty_tt_bapi_msg. " BAPI msg
  CONSTANTS : lc_warning TYPE char1 VALUE 'W',     " Warning of type CHAR1
              lc_msg_s   TYPE char1 VALUE 'S',     " Msg_s of type CHAR1
              lc_icon_s  TYPE icon_d VALUE '@5B@', " Icon in text fields (substitute display, alias)
              lc_icon_e  TYPE icon_d VALUE '@5C@'. " Icon in text fields (substitute display, alias)

  DATA : li_bapiret2_temp TYPE STANDARD TABLE OF bapiret2. " Return Parameter

  FIELD-SYMBOLS : <lfs_bapiret2_temp> TYPE bapiret2,    " Return Parameter
                  <lfs_bapi_msg>      TYPE ty_bapi_msg, " BAPI Msg
                  <lfs_i_so_item>     TYPE bapisditm.   " Communication Fields: Sales and Distribution Document Item


  li_bapiret2_temp = fp_li_bapiret2.

  LOOP AT li_bapiret2_temp ASSIGNING <lfs_bapiret2_temp>.
    IF <lfs_bapiret2_temp>-type <> lc_warning.
      APPEND INITIAL LINE TO fp_i_bapi_msg ASSIGNING <lfs_bapi_msg>.
      <lfs_bapi_msg>-vbeln = fp_so_header-vbeln.
      READ TABLE fp_i_so_item ASSIGNING <lfs_i_so_item> INDEX <lfs_bapiret2_temp>-row.
      IF sy-subrc IS INITIAL.
        <lfs_bapi_msg>-posnr = <lfs_i_so_item>-itm_number.
      ENDIF. " IF sy-subrc IS INITIAL
      <lfs_bapi_msg>-auart = fp_so_header-auart.
      <lfs_bapi_msg>-vkorg = fp_so_header-vkorg.
      <lfs_bapi_msg>-message = <lfs_bapiret2_temp>-message.
      IF <lfs_bapiret2_temp>-type = lc_msg_s.
        <lfs_bapi_msg>-icon = lc_icon_s.
      ELSE. " ELSE -> IF <lfs_bapiret2_temp>-type = lc_msg_s
        <lfs_bapi_msg>-icon = lc_icon_e.
      ENDIF. " IF <lfs_bapiret2_temp>-type = lc_msg_s
      UNASSIGN <lfs_bapi_msg>.
    ENDIF. " IF <lfs_bapiret2_temp>-type <> lc_warning
  ENDLOOP. " LOOP AT li_bapiret2_temp ASSIGNING <lfs_bapiret2_temp>

  IF fp_msg_type <> lc_msg_s.
    APPEND INITIAL LINE TO fp_i_bapi_msg ASSIGNING <lfs_bapi_msg>.
    <lfs_bapi_msg>-vbeln = fp_so_header-vbeln.
    <lfs_bapi_msg>-auart = fp_so_header-auart.
    <lfs_bapi_msg>-vkorg = fp_so_header-vkorg.
    <lfs_bapi_msg>-icon = lc_icon_e.
    <lfs_bapi_msg>-message = 'Document not saved as some item contain error'(013).
    UNASSIGN <lfs_bapi_msg>.
  ELSE. " ELSE -> IF fp_msg_type <> lc_msg_s
    APPEND INITIAL LINE TO fp_i_bapi_msg ASSIGNING <lfs_bapi_msg>.
    <lfs_bapi_msg>-vbeln = fp_so_header-vbeln.
    <lfs_bapi_msg>-auart = fp_so_header-auart.
    <lfs_bapi_msg>-vkorg = fp_so_header-vkorg.
    <lfs_bapi_msg>-icon = lc_icon_s.
    <lfs_bapi_msg>-message = 'Document saved successfully'(018).
    UNASSIGN <lfs_bapi_msg>.
  ENDIF. " IF fp_msg_type <> lc_msg_s

ENDFORM. " F_COLLECT_BAPI_MSG
*&---------------------------------------------------------------------*
*&      Form  f_display_bapi_msg
*&---------------------------------------------------------------------*
*       Display BAPI msg
*----------------------------------------------------------------------*
*      -->FP_I_BAPI_MSG  BAPI return msg
*----------------------------------------------------------------------*
FORM f_display_bapi_msg  USING   fp_i_bapi_msg       TYPE ty_tt_bapi_msg. " BAPI return msg

  CONSTANTS : lc_true       TYPE char1 VALUE 'X',                      " True of type CHAR1
              lc_vbeln      TYPE slis_fieldname VALUE 'VBELN',         " field name
              lc_posnr      TYPE slis_fieldname VALUE 'POSNR',         " field name
              lc_auart      TYPE slis_fieldname VALUE 'AUART',         " field name
              lc_vkorg      TYPE slis_fieldname VALUE 'VKORG',         " field name
              lc_message    TYPE slis_fieldname VALUE 'MESSAGE',       " field name
              lc_icon       TYPE slis_fieldname VALUE 'ICON',          " field name
              lc_tabname    TYPE slis_tabname   VALUE 'FP_I_BAPI_MSG'. " table name

  DATA : li_fieldcat  TYPE slis_t_fieldcat_alv, " ALV field catalogue
         lwa_fieldcat TYPE slis_fieldcat_alv,   " Fieldcat work area
         lv_col_pos   TYPE sycucol.             " ALV Column position


  lv_col_pos = lv_col_pos + 1.
  lwa_fieldcat-col_pos   = lv_col_pos.
  lwa_fieldcat-fieldname = lc_vbeln.
  lwa_fieldcat-tabname   = lc_tabname.
  lwa_fieldcat-seltext_l = 'Sales Order Number'(008).
  lwa_fieldcat-outputlen = 10.
  APPEND lwa_fieldcat TO li_fieldcat.
  CLEAR lwa_fieldcat.

  lv_col_pos = lv_col_pos + 1.
  lwa_fieldcat-col_pos   = lv_col_pos.
  lwa_fieldcat-fieldname = lc_posnr.
  lwa_fieldcat-tabname   = lc_tabname.
  lwa_fieldcat-seltext_l = 'Sales Order Item'(009).
  lwa_fieldcat-outputlen = 10.
  APPEND lwa_fieldcat TO li_fieldcat.
  CLEAR lwa_fieldcat.

  lv_col_pos = lv_col_pos + 1.
  lwa_fieldcat-col_pos   = lv_col_pos.
  lwa_fieldcat-fieldname = lc_auart.
  lwa_fieldcat-tabname   = lc_tabname.
  lwa_fieldcat-seltext_l = 'Sales Doc Type'(010).
  lwa_fieldcat-outputlen = 10.
  APPEND lwa_fieldcat TO li_fieldcat.
  CLEAR lwa_fieldcat.

  lv_col_pos = lv_col_pos + 1.
  lwa_fieldcat-col_pos   = lv_col_pos.
  lwa_fieldcat-fieldname = lc_vkorg.
  lwa_fieldcat-tabname   = lc_tabname.
  lwa_fieldcat-seltext_l = 'Sales Org.'(011).
  lwa_fieldcat-outputlen = 10.
  APPEND lwa_fieldcat TO li_fieldcat.
  CLEAR lwa_fieldcat.

  lv_col_pos = lv_col_pos + 1.
  lwa_fieldcat-col_pos   = lv_col_pos.
  lwa_fieldcat-fieldname = lc_icon.
  lwa_fieldcat-tabname   = lc_tabname.
  lwa_fieldcat-seltext_l = 'E/S Icon'(019).
  lwa_fieldcat-outputlen = 8.
  lwa_fieldcat-icon      = abap_true.
  APPEND lwa_fieldcat TO li_fieldcat.
  CLEAR lwa_fieldcat.

  lv_col_pos = lv_col_pos + 1.
  lwa_fieldcat-col_pos   = lv_col_pos.
  lwa_fieldcat-fieldname = lc_message.
  lwa_fieldcat-tabname   = lc_tabname.
  lwa_fieldcat-seltext_l = 'Error/Success Message'(012).
  lwa_fieldcat-outputlen = 80.
  APPEND lwa_fieldcat TO li_fieldcat.
  CLEAR lwa_fieldcat.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      it_fieldcat        = li_fieldcat
      i_save             = lc_true
    TABLES
      t_outtab           = fp_i_bapi_msg
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
*   display message for failure
    MESSAGE 'Program Error in ALV display'(001) TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc <> 0



ENDFORM. " F_DISPLAY_BAPI_MSG

*&---------------------------------------------------------------------*
*&      Form  f_check_authorizaiton
*&---------------------------------------------------------------------*
*       Authorization check
*----------------------------------------------------------------------*
*      -->FP_I_SALES_ORG  sales org
*----------------------------------------------------------------------*
FORM f_check_authorizaiton USING fp_i_sales_org TYPE ty_tt_sales_org.

  CONSTANTS : lc_vkorg      TYPE char5  VALUE 'VKORG',      " Vkorg of type CHAR5
              lc_vtweg      TYPE char5  VALUE 'VTWEG',      " Vtweg of type CHAR5
              lc_spart      TYPE char5  VALUE 'SPART',      " Spart of type CHAR5
              lc_actvt      TYPE char5  VALUE 'ACTVT',      " Actvt of type CHAR5
              lc_dummy      TYPE char5  VALUE 'DUMMY',      " Dummy of type CHAR5
              lc_v_vbak_vko TYPE char10 VALUE 'V_VBAK_VKO', " V_vbak_vko of type CHAR10
              lc_i          TYPE char1  VALUE 'I',          " I of type CHAR1
              lc_eq         TYPE char2  VALUE 'EQ',         " Eq of type CHAR2
              lc_01         TYPE activ_auth VALUE '01',     " Activity +D3 Defect 9890
              lc_all        TYPE activ_auth VALUE '*'.      " Activity +D3 Defect 9890

  DATA : li_sales_org TYPE STANDARD TABLE OF ty_sales_org.

  FIELD-SYMBOLS : <lfs_sales_org> TYPE ty_sales_org, " Sales Org
                  <lfs_vkorg>     TYPE ty_vkorg.

  li_sales_org = fp_i_sales_org.

  LOOP AT li_sales_org ASSIGNING <lfs_sales_org>.
    AUTHORITY-CHECK OBJECT lc_v_vbak_vko
     ID lc_vkorg FIELD <lfs_sales_org>-vkorg
* ---> Begin of Delete for D3 Defect 9890 by DMOIRAN
*     ID lc_vtweg FIELD lc_dummy
*     ID lc_spart FIELD lc_dummy
*     ID lc_actvt FIELD lc_dummy.
* <--- End    of Delete for D3 Defect 9890 by DMOIRAN
* ---> Begin of Insert for D3 Defect 9890 by DMOIRAN
     ID lc_vtweg FIELD lc_all
     ID lc_spart FIELD lc_all
     ID lc_actvt FIELD lc_01.
* <--- End    of Insert for D3 Defect 9890 by DMOIRAN


    IF sy-subrc IS NOT INITIAL.
      <lfs_sales_org>-vkorg = abap_true.
    ENDIF. " IF sy-subrc IS NOT INITIAL
  ENDLOOP. " LOOP AT li_sales_org ASSIGNING <lfs_sales_org>
  DELETE li_sales_org WHERE vkorg = abap_true.
  IF li_sales_org IS INITIAL.
    MESSAGE e000 WITH 'No Authorization for Sales Organization'(002).
  ELSE. " ELSE -> IF li_sales_org IS INITIAL
    CLEAR : s_vkorg,
            s_vkorg[].
    LOOP AT li_sales_org ASSIGNING <lfs_sales_org>.
      APPEND INITIAL LINE TO s_vkorg ASSIGNING <lfs_vkorg>.
      <lfs_vkorg>-sign   = lc_i.
      <lfs_vkorg>-option = lc_eq.
      <lfs_vkorg>-low    = <lfs_sales_org>-vkorg.
      UNASSIGN <lfs_vkorg>.
    ENDLOOP. " LOOP AT li_sales_org ASSIGNING <lfs_sales_org>
  ENDIF. " IF li_sales_org IS INITIAL
ENDFORM. " F_CHECK_AUTHORIZAITON
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_SALES_ORG
*&---------------------------------------------------------------------*
*       validate sales org
*----------------------------------------------------------------------*
FORM f_check_sales_org .
  SELECT vkorg     " Sales Organization
         FROM tvko " Organizational Unit: Sales Organizations
         INTO TABLE i_sales_org
         WHERE vkorg IN s_vkorg.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE e000 WITH 'Invalid Sales organization'(003).
  ENDIF. " IF sy-subrc IS NOT INITIAL
ENDFORM. " F_CHECK_SALES_ORG
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_DIST_CHANNEL
*&---------------------------------------------------------------------*
*       validate dist channel
*----------------------------------------------------------------------*
FORM f_check_dist_channel .
  DATA : lv_vtweg TYPE vtweg. " Distribution Channel

  SELECT vtweg UP TO 1 ROWS
     FROM tvtw " Organizational Unit: Distribution Channels
     INTO lv_vtweg
     WHERE vtweg IN s_vtweg.
  ENDSELECT.
  IF sy-subrc IS NOT INITIAL AND
     lv_vtweg IS INITIAL.
    MESSAGE e000 WITH 'Invalid distribution channel'(004).
  ENDIF. " IF sy-subrc IS NOT INITIAL AND

ENDFORM. " F_CHECK_DIST_CHANNEL
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_DOC_TYPE
*&---------------------------------------------------------------------*
*       validate doc type
*----------------------------------------------------------------------*
FORM f_check_doc_type .
  DATA : lv_auart TYPE auart. " Sales Document Type

  SELECT auart UP TO 1 ROWS
     FROM tvak " Sales Document Types
    INTO lv_auart
    WHERE auart IN s_auart.
  ENDSELECT.
  IF sy-subrc IS NOT INITIAL AND
     lv_auart IS INITIAL.
    MESSAGE e000 WITH 'Invalid sales document type'(005).
  ENDIF. " IF sy-subrc IS NOT INITIAL AND

ENDFORM. " F_CHECK_DOC_TYPE
*&---------------------------------------------------------------------*
*&      Form  f_fetch_emi_values
*&---------------------------------------------------------------------*
*       fetch EMI entry for delv status
*----------------------------------------------------------------------*
*      <--FP_LFSTA   delvery status
*      <--FP_R_LFSTK   delvery status
*----------------------------------------------------------------------*
FORM f_fetch_emi_values  CHANGING fp_lfsta   TYPE lfsta        " Delivery status
                                  fp_r_lfstk TYPE ty_tt_lfstk. " Delivery status

  CONSTANTS : lc_enh_id  TYPE z_enhancement VALUE 'OTC_EDD_0351', " Enh. Criteria
              lc_lfsta   TYPE z_criteria    VALUE 'LFSTA',        " Enh. Criteria
              lc_lfstk   TYPE z_criteria    VALUE 'LFSTK',        " Enh. Criteria
              lc_i       TYPE char1         VALUE 'I',            " I of type CHAR1
              lc_eq      TYPE char2         VALUE 'EQ'.           " Eq of type CHAR2


  DATA : li_status  TYPE STANDARD TABLE OF zdev_enh_status. " Enhancement Status

  FIELD-SYMBOLS : <lfs_status> TYPE zdev_enh_status, " Enhancement Status
                  <lfs_lfstk>  TYPE ty_lfstk.        " Delivery status

* Fetch values from EMI Tool.
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_id
    TABLES
      tt_enh_status     = li_status.

  LOOP AT li_status ASSIGNING <lfs_status>.
    IF <lfs_status>-active = abap_true.
      CASE  <lfs_status>-criteria.
        WHEN  lc_lfsta.
          fp_lfsta = <lfs_status>-sel_low.
        WHEN lc_lfstk.
          APPEND INITIAL LINE TO fp_r_lfstk ASSIGNING <lfs_lfstk>.
          <lfs_lfstk>-sign   = lc_i.
          <lfs_lfstk>-option = lc_eq.
          <lfs_lfstk>-low    = <lfs_status>-sel_low.
          UNASSIGN <lfs_lfstk>.
        WHEN OTHERS.
      ENDCASE.
    ENDIF. " IF <lfs_status>-active = abap_true
  ENDLOOP. " LOOP AT li_status ASSIGNING <lfs_status>

ENDFORM. " F_FETCH_EMI_VALUES
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_SALES_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_sales_doc .
  DATA : lv_vbeln TYPE vbeln_va. " Sales Document

  SELECT vbeln UP TO 1 ROWS
     FROM vbak " Sales Document Types
    INTO lv_vbeln
    WHERE vbeln IN s_vbeln.
  ENDSELECT.
  IF sy-subrc IS NOT INITIAL AND
     lv_vbeln IS INITIAL.
    MESSAGE e000 WITH 'Invalid sales document number'(016).
  ENDIF. " IF sy-subrc IS NOT INITIAL AND
ENDFORM. " F_CHECK_SALES_DOC
