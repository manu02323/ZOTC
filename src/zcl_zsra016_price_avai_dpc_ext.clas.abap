class ZCL_ZSRA016_PRICE_AVAI_DPC_EXT definition
  public
  inheriting from ZCL_ZSRA016_PRICE_AVAI_DPC
  create public .

public section.

  types:
    BEGIN OF TS_MATERIAL.
          INCLUDE       TYPE cl_sra016_price_avail_mpc=>ts_product.
          TYPES:  seq_no TYPE i,
        END OF TS_MATERIAL .
  types:
    T_MATERIAL TYPE STANDARD TABLE OF TS_MATERIAL .

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM
    redefinition .
protected section.

  methods CUSTOMERCOLLECTI_GET_ENTITYSET
    redefinition .
  methods PRODUCTATTRIBUTE_GET_ENTITYSET
    redefinition .
  methods PRODUCTAVAILABIL_GET_ENTITYSET
    redefinition .
  methods PRODUCTCOLLECTIO_GET_ENTITY
    redefinition .
  methods PRODUCTCOLLECTIO_GET_ENTITYSET
    redefinition .
  methods SHIPTOSET_GET_ENTITY
    redefinition .
  methods SHIPTOSET_GET_ENTITYSET
    redefinition .
  methods SOLDTOSET_GET_ENTITY
    redefinition .
  methods SOLDTOSET_GET_ENTITYSET
    redefinition .
private section.

  methods CONVERT_TO_MATNR
    importing
      !IV_UNCONVERTED_MATERIAL type STRING
    returning
      value(RV_CONVERTED_MATERIAL) type MATNR .
  methods NO_CACHE .
  methods RETRIEVE_PRODUCTS
    importing
      !IV_CUSTOMER type KUNNR
      !IT_MATERIALS type T_MATERIAL
    exporting
      value(ET_PRODUCTS) type ZCL_ZSRA016_PRICE_AVAI_MPC=>TT_PRODUCT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION .
  methods FORMAT_MATERIAL_SEARCH
    importing
      !IV_SEARCH_STRING type STRING
    exporting
      value(EV_FORMATED_SEARCH) type ANY .
  class-methods GET_SALES_ORG
    importing
      value(IV_KUNNR) type KUNNR
      value(IV_MATNR) type MATNR_D optional
    exporting
      !EV_VKORG type VKORG
      !EV_VTWEG type VTWEG
      !EV_SPART type SPART .
ENDCLASS.



CLASS ZCL_ZSRA016_PRICE_AVAI_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~execute_action.

  ENDMETHOD.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITY.
  TRY.
      CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITY
        EXPORTING
          IV_ENTITY_NAME          = IV_ENTITY_NAME
          IV_ENTITY_SET_NAME      = IV_ENTITY_SET_NAME
          IV_SOURCE_NAME          = IV_SOURCE_NAME
          IT_KEY_TAB              = IT_KEY_TAB
          IT_NAVIGATION_PATH      = IT_NAVIGATION_PATH
          IO_TECH_REQUEST_CONTEXT = IO_TECH_REQUEST_CONTEXT
        IMPORTING
          ER_ENTITY               = ER_ENTITY.

    CATCH /IWBEP/CX_MGW_BUSI_EXCEPTION .
    CATCH /IWBEP/CX_MGW_TECH_EXCEPTION .
  ENDTRY.
  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET.
  TRY.
      CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET
        EXPORTING
          IV_ENTITY_NAME           = IV_ENTITY_NAME
          IV_ENTITY_SET_NAME       = IV_ENTITY_SET_NAME
          IV_SOURCE_NAME           = IV_SOURCE_NAME
          IT_FILTER_SELECT_OPTIONS = IT_FILTER_SELECT_OPTIONS
          IT_ORDER                 = IT_ORDER
          IS_PAGING                = IS_PAGING
          IT_NAVIGATION_PATH       = IT_NAVIGATION_PATH
          IT_KEY_TAB               = IT_KEY_TAB
          IV_FILTER_STRING         = IV_FILTER_STRING
          IV_SEARCH_STRING         = IV_SEARCH_STRING
          IO_TECH_REQUEST_CONTEXT  = IO_TECH_REQUEST_CONTEXT
        IMPORTING
          ER_ENTITYSET             = ER_ENTITYSET
          ES_RESPONSE_CONTEXT      = ES_RESPONSE_CONTEXT.

    CATCH /IWBEP/CX_MGW_BUSI_EXCEPTION .
    CATCH /IWBEP/CX_MGW_TECH_EXCEPTION .
  ENDTRY.


  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM.
DATA: ls_stream         TYPE         ty_s_media_resource,
        lv_material TYPE matnr,
        ls_key_tab TYPE /iwbep/s_mgw_name_value_pair.
  DATA  lo_prod_img_retriever     TYPE REF TO bd_sra016_prod_img_retriever.

  DATA  ls_t100key               TYPE scx_t100key.          "#EC NEEDED

  IF iv_entity_name = 'Product'.
    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'ProductID'.
    lv_material = ls_key_tab-value.

    TRY .
        GET BADI lo_prod_img_retriever .
      CATCH cx_badi_not_implemented.
        ls_t100key-msgid = 'CM_SRA016_PRC_AVL'.
        ls_t100key-msgno = 005. " Product Image retriever BadI not implemented
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_t100key.
    ENDTRY.

    CALL BADI lo_prod_img_retriever->get_product_image
      EXPORTING
        iv_material      = lv_material
      IMPORTING
        ev_image_xstring = ls_stream-value
        ev_mime_type     = ls_stream-mime_type.

    IF ls_stream-value IS INITIAL.
      ls_t100key-msgid = 'CM_SRA016_PRC_AVL'.
      ls_t100key-msgno = 002. " Image not available for the product
      ls_t100key-attr1 = lv_material.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
      EXPORTING
        textid = ls_t100key.
    ENDIF.

    copy_data_to_ref( EXPORTING is_data = ls_stream
                      CHANGING  cr_data = er_stream ).
  ENDIF.

  endmethod.


method CONVERT_TO_MATNR.
****************************************************************************
*Program    : CONVERT_TO_MATNR                                             *
*Title      : ZCL_ZSRA016_PRICE_AVAI_DPC_EXT~CONVERT_TO_MATNR              *
*Developer  : Nrupen Polasani                                              *
*Object type: OData Service                                                *
*SAP Release: SAP ECC 6.0                                                  *
*--------------------------------------------------------------------------*
*WRICEF ID: OTC_MDD_0002                                                   *
*--------------------------------------------------------------------------*
****************************************************************************
* Method (CONVERT_TO_MATNR): This method is used to convert material number*
* to its appropriate conversion routine                                    *
*--------------------------------------------------------------------------*
*MODIFICATION HISTORY:
*==========================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ================================*
*06-Dec-2018   U104997       E2DK923449      INITIAL DEVELOPMENT           *
*--------------------------------------------------------------------------*


  " Create data reference to either regular material or LAMA material
  data lr_matnr type ref to data.
  if cl_sra016_lama=>is_lama_active( ) eq abap_false.
    create data lr_matnr type matnr.
  else.
    create data lr_matnr type matnr_ext.
  endif.

  " Assign field symbols to dynamic material type
  field-symbols <fs_matnr> type any.
  assign lr_matnr->* to <fs_matnr>.

  " Convert and return material
  if <fs_matnr> is assigned.
    <fs_matnr> = iv_unconverted_material.
    call function 'CONVERSION_EXIT_MATN1_INPUT'
      exporting
        input        = <fs_matnr>
      importing
        output       = rv_converted_material
      exceptions
        length_error = 1
        others       = 2.
  endif.

endmethod.


  METHOD customercollecti_get_entityset.
***********************************************************************
*Program    : CUSTOMERCOLLECTI_GET_ENTITYSET                          *
*Title      : ZCL_ZSRA016_PRICE_AVAI_DPC_EXT~CUSTOMERCOLLECTI_GET_ENTITYSET*
*Developer  : Nrupen Polasani                                         *
*Object type: OData Service                                           *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_MDD_0002                                              *
*---------------------------------------------------------------------*
***********************************************************************
* Method (CUSTOMERCOLLECTI_GET_ENTITYSET) :This Method is not used    *
* This was used to get customers assigned to a user prior to making   *
* code changes. Please refer standard SAP class to see whats there.   *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*06-Dec-2018   U104997       E2DK923449      INITIAL DEVELOPMENT      *
*---------------------------------------------------------------------*



  ENDMETHOD.


METHOD format_material_search.
****************************************************************************
*Program    : FORMAT_MATERIAL_SEARCH                                       *
*Title      : ZCL_ZSRA016_PRICE_AVAI_DPC_EXT~FORMAT_MATERIAL_SEARCH        *
*Developer  : Nrupen Polasani                                              *
*Object type: OData Service                                                *
*SAP Release: SAP ECC 6.0                                                  *
*--------------------------------------------------------------------------*
*WRICEF ID: OTC_MDD_0002                                                   *
*--------------------------------------------------------------------------*
****************************************************************************
* Method (FORMAT_MATERIAL_SEARCH): This method is used to format the search*
* criteria when the user enters it on the screen                           *
*--------------------------------------------------------------------------*
*MODIFICATION HISTORY:
*==========================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ================================*
*06-Dec-2018   U104997       E2DK923449      INITIAL DEVELOPMENT           *
*--------------------------------------------------------------------------*

  DATA lv_input_string_length TYPE i.
  lv_input_string_length = strlen( iv_search_string ).

  DATA lv_max_char_length TYPE i.
  DESCRIBE FIELD ev_formated_search LENGTH lv_max_char_length IN CHARACTER MODE.

  " Do not insert wild card if exact length is inputed
  IF ( iv_search_string CS '*' ) OR ( lv_input_string_length EQ lv_max_char_length ).
    ev_formated_search = iv_search_string.
    RETURN.
  ENDIF.

  SUBTRACT 2 FROM lv_max_char_length. " make room for wild chard before and after search string

  IF lv_input_string_length GT lv_max_char_length. " if there too many characters in the input string,
    lv_input_string_length = lv_max_char_length.   " truncate characters off the end of the input string
  ENDIF.

  CONCATENATE '*' iv_search_string+0(lv_input_string_length) '*' INTO ev_formated_search.

ENDMETHOD.


METHOD get_sales_org.
****************************************************************************
*Program    : GET_SALES_ORG                                                *
*Title      : ZCL_ZSRA016_PRICE_AVAI_DPC_EXT~GET_SALES_ORG                 *
*Developer  : Nrupen Polasani                                              *
*Object type: OData Service                                                *
*SAP Release: SAP ECC 6.0                                                  *
*--------------------------------------------------------------------------*
*WRICEF ID: OTC_MDD_0002                                                   *
*--------------------------------------------------------------------------*
****************************************************************************
* Method (GET_SALES_ORG): This method is used to get the default sales org *
* based on the combination of sold to, ship to partner and material        *
*--------------------------------------------------------------------------*
*MODIFICATION HISTORY:
*==========================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ================================*
*06-Dec-2018   U104997       E2DK923449      INITIAL DEVELOPMENT           *
*--------------------------------------------------------------------------*



*-- Determine sales org

  DATA lo_object TYPE REF TO zotc_cl_inb_so_edi_850.
  DATA : lv_land1    TYPE land1,              " Country Key
         lv_lrd      TYPE char1,              " Lrd of type CHAR1
         lv_skip     TYPE char1,              " Skip of type CHAR1
         lt_item     TYPE zotc_tt_850_so_item,
         ls_item     TYPE zotc_850_so_item,
         ex_bapi_msg TYPE bapirettab.

  SELECT SINGLE land1 FROM kna1 INTO lv_land1 WHERE kunnr = iv_kunnr.
  IF sy-subrc = 0.
    CASE lv_land1.
      WHEN 'US'.
        ev_vkorg = '1000'.
      WHEN 'MX'.
        ev_vkorg = '1103'.
      WHEN 'CA'.
        ev_vkorg = '1020'.
      WHEN 'SG'.
        ev_vkorg = '3000'.
      WHEN OTHERS.
        CREATE OBJECT lo_object.
        IF lo_object IS BOUND.

          CALL METHOD lo_object->determine_sold_to_country
            EXPORTING
              im_kunnr_sp = iv_kunnr
            IMPORTING
              ex_land1    = lv_land1
              ex_lrd      = lv_lrd
              ex_skip     = lv_skip.
*** Check to see if the split logic
          IF lv_skip EQ abap_false.
* LRD Orders
            ls_item-matnr = iv_matnr.
            APPEND ls_item TO lt_item.
            IF lv_lrd EQ abap_true.
              CALL METHOD lo_object->process_lrd
                EXPORTING
                  im_land1                 = lv_land1
                IMPORTING
                  ex_bapi_msg              = ex_bapi_msg
                CHANGING
                  ch_item                  = lt_item
                EXCEPTIONS
                  material_class_not_found = 1
                  OTHERS                   = 2.
            ELSE. " ELSE -> IF lv_lrd EQ abap_true
* Non LRD Orders
              CALL METHOD lo_object->process_nlrd
                IMPORTING
                  ex_bapi_msg               = ex_bapi_msg
                CHANGING
                  ch_item                   = lt_item
                EXCEPTIONS
                  lab_office_not_maintained = 1
                  OTHERS                    = 2.
            ENDIF.
            IF lt_item IS NOT INITIAL.
              READ TABLE lt_item INTO ls_item INDEX 1.
              IF sy-subrc = 0.
                ev_vkorg = ls_item-vkorg.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDIF.

  ev_vtweg = '10'.
  ev_spart = '00'.
ENDMETHOD.


METHOD no_cache.
****************************************************************************
*Program    : NO_CACHE                                                     *
*Title      : ZCL_ZSRA016_PRICE_AVAI_DPC_EXT~NO_CACHE                      *
*Developer  : Nrupen Polasani                                              *
*Object type: OData Service                                                *
*SAP Release: SAP ECC 6.0                                                  *
*--------------------------------------------------------------------------*
*WRICEF ID: OTC_MDD_0002                                                   *
*--------------------------------------------------------------------------*
****************************************************************************
*--------------------------------------------------------------------------*
*MODIFICATION HISTORY:
*==========================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ================================*
*06-Dec-2018   U104997       E2DK923449      INITIAL DEVELOPMENT           *
*--------------------------------------------------------------------------*


  DATA header TYPE ihttpnvp.

  header-name = 'Cache-Control'.                            "#EC NOTEXT
  header-value = 'no-cache, no-store'.                      "#EC NOTEXT
  set_header( EXPORTING is_header = header ).

  header-name  = 'Pragma'.                                  "#EC NOTEXT
  header-value = 'no-cache'.                                "#EC NOTEXT
  set_header(  EXPORTING is_header = header ).

ENDMETHOD.


  METHOD productattribute_get_entityset.
****************************************************************************
*Program    : PRODUCTATTRIBUTE_GET_ENTITYSET                               *
*Title      : ZCL_ZSRA016_PRICE_AVAI_DPC_EXT~PRODUCTATTRIBUTE_GET_ENTITYSET*
*Developer  : Nrupen Polasani                                              *
*Object type: OData Service                                                *
*SAP Release: SAP ECC 6.0                                                  *
*--------------------------------------------------------------------------*
*WRICEF ID: OTC_MDD_0002                                                   *
*--------------------------------------------------------------------------*
****************************************************************************
* Method (PRODUCTATTRIBUTE_GET_ENTITYSET) :This method is used to get the  *
* the attributes of materials when searched by a user                      *
*--------------------------------------------------------------------------*
*MODIFICATION HISTORY:
*==========================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ================================*
*06-Dec-2018   U104997       E2DK923449      INITIAL DEVELOPMENT           *
*--------------------------------------------------------------------------*


*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
    DATA allocvaluesnum  TYPE if_bapi_objcl_getdetail1=>__bapi1003_alloc_values_num.
    DATA allocvaluescurr  TYPE if_bapi_objcl_getdetail1=>__bapi1003_alloc_values_curr.
    DATA allocvalueschar  TYPE if_bapi_objcl_getdetail1=>__bapi1003_alloc_values_char.
    DATA lo_filter TYPE  REF TO /iwbep/if_mgw_req_filter.
    DATA lt_filter_select_options TYPE /iwbep/t_mgw_select_option.
    DATA lv_filter_str TYPE string.
    DATA ls_gw_allocvalueschar LIKE LINE OF et_entityset.
    DATA lv_char(20) TYPE c.

    FIELD-SYMBOLS: <ls_filter_select_option> TYPE /iwbep/s_mgw_select_option,
                   <ls_sel_option>           TYPE /iwbep/s_cod_select_option,
                   <ls_allocvalueschar>      LIKE LINE OF allocvalueschar,
                   <ls_allocvaluescurr>      LIKE LINE OF allocvaluescurr,
                   <ls_allocvaluesnum>       LIKE LINE OF allocvaluesnum.
*-------------------------------------------------------------
*  Map the runtime request to the RFC - Only mapped attributes
*-------------------------------------------------------------
* Get all input information from the technical request context object
* Since DPC works with internal property names and runtime API interface holds external property names
* the process needs to get the all needed input information from the technical request context object
* Get filter or select option information
    lo_filter = io_tech_request_context->get_filter( ).
    lt_filter_select_options = lo_filter->get_filter_select_options( ).
    lv_filter_str = lo_filter->get_filter_string( ).

* Check if the supplied filter is supported by standard gateway runtime process
    IF  lv_filter_str            IS NOT INITIAL
    AND lt_filter_select_options IS INITIAL.

      " If the string of the Filter System Query Option is not automatically converted into
      " filter option table (lt_filter_select_options), then the filtering combination is not supported
      " Log message in the application log
      me->/iwbep/if_sb_dpc_comm_services~log_message(
        EXPORTING
          iv_msg_type   = 'E'
          iv_msg_id     = '/IWBEP/MC_SB_DPC_ADM'
          iv_msg_number = 025 ).
      " Raise Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
        EXPORTING
          textid = /iwbep/cx_mgw_tech_exception=>internal_error.
    ENDIF.


* Get source keys (converted)
    DATA: BEGIN OF ls_key_values,
            customer_no         TYPE kunnr,
            distributionchannel TYPE vtweg,
            division            TYPE spart,
            salesorganization   TYPE vkorg,
            material            TYPE matnr,
          END OF ls_key_values.
    io_tech_request_context->get_converted_source_keys( IMPORTING es_key_values = ls_key_values ).

    LOOP AT it_filter_select_options ASSIGNING <ls_filter_select_option>.

      LOOP AT <ls_filter_select_option>-select_options ASSIGNING <ls_sel_option>.
        CASE <ls_filter_select_option>-property.
          WHEN OTHERS.
            " Log message in the application log
            me->/iwbep/if_sb_dpc_comm_services~log_message(
              EXPORTING
                iv_msg_type   = 'E'
                iv_msg_id     = '/IWBEP/MC_SB_DPC_ADM'
                iv_msg_number = 020
                iv_msg_v1     = <ls_filter_select_option>-property ).
            " Raise Exception
            RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
              EXPORTING
                textid = /iwbep/cx_mgw_tech_exception=>internal_error.
        ENDCASE.
      ENDLOOP.
    ENDLOOP.

*-------------------------------------------------------------------------*
*             - Post Backend Call -
*-------------------------------------------------------------------------*

*  - Map properties from the backend to the Gateway output response table -
    LOOP AT allocvalueschar ASSIGNING <ls_allocvalueschar>."INTO ls_allocvalueschar.
*  Only fields that were mapped will be delivered to the response table
      ls_gw_allocvalueschar-productid = ls_key_values-material.
      ls_gw_allocvalueschar-value_char = <ls_allocvalueschar>-value_char.
      ls_gw_allocvalueschar-charact = <ls_allocvalueschar>-charact.
      ls_gw_allocvalueschar-charact_descr = <ls_allocvalueschar>-charact_descr.
      APPEND ls_gw_allocvalueschar TO et_entityset.
      CLEAR ls_gw_allocvalueschar.
    ENDLOOP.

    LOOP AT allocvaluesnum ASSIGNING <ls_allocvaluesnum>.
*  Only fields that were mapped will be delivered to the response table
      ls_gw_allocvalueschar-productid = ls_key_values-material.
      ls_gw_allocvalueschar-value_from = <ls_allocvaluesnum>-value_from.
      CLEAR lv_char.
      WRITE ls_gw_allocvalueschar-value_from EXPONENT 0 TO lv_char.
      CONDENSE lv_char.
      ls_gw_allocvalueschar-value_char = lv_char.
      ls_gw_allocvalueschar-value_to = <ls_allocvaluesnum>-value_to.
      ls_gw_allocvalueschar-unit_from = <ls_allocvaluesnum>-unit_from.
      ls_gw_allocvalueschar-unit_to = <ls_allocvaluesnum>-unit_to.
      ls_gw_allocvalueschar-charact_descr = <ls_allocvaluesnum>-charact_descr.
      ls_gw_allocvalueschar-charact = <ls_allocvaluesnum>-charact.
      APPEND ls_gw_allocvalueschar TO et_entityset.
      CLEAR ls_gw_allocvalueschar.
    ENDLOOP.

    LOOP AT allocvaluescurr ASSIGNING <ls_allocvaluescurr>.
*  Only fields that were mapped will be delivered to the response table
      ls_gw_allocvalueschar-productid = ls_key_values-material.
      ls_gw_allocvalueschar-value_from = <ls_allocvaluescurr>-value_from.
      CLEAR lv_char.
      WRITE ls_gw_allocvalueschar-value_from TO lv_char.
      CONDENSE lv_char.
      ls_gw_allocvalueschar-value_char = lv_char.
      ls_gw_allocvalueschar-unit_from = <ls_allocvaluescurr>-currency_from.
      ls_gw_allocvalueschar-value_to = <ls_allocvaluescurr>-value_to.
      ls_gw_allocvalueschar-currency_from = <ls_allocvaluescurr>-currency_from.
      ls_gw_allocvalueschar-unit_from = ls_gw_allocvalueschar-currency_from.
      ls_gw_allocvalueschar-currency_to = <ls_allocvaluescurr>-currency_to.
      ls_gw_allocvalueschar-charact = <ls_allocvaluescurr>-charact.
      ls_gw_allocvalueschar-charact_descr = <ls_allocvaluescurr>-charact_descr.
      APPEND ls_gw_allocvalueschar TO et_entityset.
      CLEAR ls_gw_allocvalueschar.
    ENDLOOP.
    UNASSIGN: <ls_allocvaluescurr>, <ls_allocvaluesnum>, <ls_allocvalueschar>.

    no_cache( ).
  ENDMETHOD.


  METHOD productavailabil_get_entityset.
****************************************************************************
*Program    : PRODUCTAVAILABIL_GET_ENTITYSET                               *
*Title      : ZCL_ZSRA016_PRICE_AVAI_DPC_EXT~PRODUCTAVAILABIL_GET_ENTITYSET*
*Developer  : Nrupen Polasani                                              *
*Object type: OData Service                                                *
*SAP Release: SAP ECC 6.0                                                  *
*--------------------------------------------------------------------------*
*WRICEF ID: OTC_MDD_0002                                                   *
*--------------------------------------------------------------------------*
****************************************************************************
* Method (PRODUCTAVAILABIL_GET_ENTITYSET) :This method is used to get the  *
* the price and availability of a product searched by user                 *
*--------------------------------------------------------------------------*
*MODIFICATION HISTORY:
*==========================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ================================*
*06-Dec-2018   U104997       E2DK923449      INITIAL DEVELOPMENT           *
*12-Aug-2019   U104997       E2DK925744      Defect # 10208 - Perf Improvements.*
*--------------------------------------------------------------------------*


*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------
    DATA lo_message_container TYPE REF TO /iwbep/if_message_container.
    DATA lo_filter TYPE  REF TO /iwbep/if_mgw_req_filter.
    DATA lt_filter_select_options TYPE /iwbep/t_mgw_select_option.
    DATA lv_filter_str TYPE string.
    DATA ls_gw_order_items_in LIKE LINE OF et_entityset.
    DATA lv_vrkme TYPE mvke-vrkme.
    DATA lv_reqqty TYPE mngpr.
    DATA lv_reqdate TYPE datpr.
    DATA ls_filter TYPE /iwbep/s_mgw_select_option.
    DATA ls_mat_det TYPE bapimatdoa.
    DATA lv_dest TYPE logsys.
    DATA: ls_ord_header_in TYPE bapisdhead,
          lt_items_in      TYPE STANDARD TABLE OF bapiitemin,
          lt_items_out     TYPE STANDARD TABLE OF bapiitemex,
          ls_items_out     TYPE bapiitemex,
          lt_partner       TYPE STANDARD TABLE OF bapipartnr,
          lt_schd_in       TYPE STANDARD TABLE OF bapischdl,
          lt_conditions_ex TYPE STANDARD TABLE OF  bapicond,
          lt_schd_ex       TYPE STANDARD TABLE OF  bapisdhedu,
          ls_schd_in       TYPE bapischdl,
          ls_items_in      TYPE bapiitemin,
          ls_partner       TYPE bapipartnr,
          ls_ret           TYPE bapireturn,
          ls_return        TYPE bapiret2,
          lt_return        TYPE TABLE OF bapiret2,
          lv_phone         TYPE char50,
          lv_auart         TYPE auart,
          lv_shiptoparty   TYPE kna1-kunnr.
    DATA lo_logger TYPE REF TO /iwbep/cl_cos_logger.
    DATA lv_amount_external TYPE bapicurr-bapicurr.
    DATA lv_lines TYPE i.

    DATA:
      lv_bezei TYPE string,
      lv_datab TYPE datab,
      lv_datbi TYPE datbi.
    DATA: lv_symsgid TYPE symsgid,
          lv_symsgno TYPE symsgno.

    FIELD-SYMBOLS: <ls_filter_select_option> TYPE /iwbep/s_mgw_select_option,
                   <ls_sel_option>           TYPE /iwbep/s_cod_select_option,
                   <ls_schd_ex>              TYPE bapisdhedu,
                   <ls_conditions_ex>        TYPE bapicond.

    lo_logger = mo_context->get_logger( ).

*-------------------------------------------------------------
*  Map the runtime request to the RFC - Only mapped attributes
*-------------------------------------------------------------
* Get all input information from the technical request context object
* Since DPC works with internal property names and runtime API interface holds external property names
* the process needs to get the all needed input information from the technical request context object
* Get filter or select option information
    lo_filter = io_tech_request_context->get_filter( ).
    lt_filter_select_options = lo_filter->get_filter_select_options( ).
    lv_filter_str = lo_filter->get_filter_string( ).

* Check if the supplied filter is supported by standard gateway runtime process
    IF  lv_filter_str            IS NOT INITIAL
    AND lt_filter_select_options IS INITIAL.
      " If the string of the Filter System Query Option is not automatically converted into
      " filter option table (lt_filter_select_options), then the filtering combination is not supported
      " Log message in the application log
      me->/iwbep/if_sb_dpc_comm_services~log_message(
        EXPORTING
          iv_msg_type   = 'E'
          iv_msg_id     = '/IWBEP/MC_SB_DPC_ADM'
          iv_msg_number = 025 ).
      " Raise Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
        EXPORTING
          textid = /iwbep/cx_mgw_tech_exception=>internal_error.
    ENDIF.

* Get source keys (converted)
    DATA: BEGIN OF ls_key_values,
            material            TYPE matnr,
            customer_no         TYPE kunnr,
            salesorganization   TYPE vkorg,
            division            TYPE spart,
            distributionchannel TYPE vtweg,
          END OF ls_key_values.
    io_tech_request_context->get_converted_source_keys( IMPORTING es_key_values = ls_key_values ).

* Maps key fields to function module parameters
    IF it_filter_select_options IS NOT INITIAL.

      LOOP AT it_filter_select_options ASSIGNING <ls_filter_select_option>.
        LOOP AT <ls_filter_select_option>-select_options ASSIGNING <ls_sel_option>.
          CASE <ls_filter_select_option>-property.
            WHEN 'ProductID'.
              ls_key_values-material = convert_to_matnr( <ls_sel_option>-low ).
            WHEN 'RequiredQty'.
              lv_reqqty = <ls_sel_option>-low.
            WHEN 'RequiredDate'.
              lv_reqdate = <ls_sel_option>-low.
            WHEN 'Shiptoparty'.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = <ls_sel_option>-low
                IMPORTING
                  output = lv_shiptoparty.
            WHEN OTHERS.
              " Log message in the application log
              me->/iwbep/if_sb_dpc_comm_services~log_message(
                EXPORTING
                  iv_msg_type   = 'E'
                  iv_msg_id     = '/IWBEP/MC_SB_DPC_ADM'
                  iv_msg_number = 021
                  iv_msg_v1     = ls_filter-property ).
              " Raise Exception
              RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
                EXPORTING
                  textid = /iwbep/cx_mgw_tech_exception=>internal_error.
          ENDCASE.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    lv_auart = 'ZOR'.

****************************************

    CLEAR ls_ret.

    CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'
      EXPORTING
        material              = ls_key_values-material
      IMPORTING
        material_general_data = ls_mat_det
        return                = ls_ret.

    IF ls_ret IS NOT INITIAL AND ls_ret-type = 'E'.
*      log BAPI  error
      MOVE-CORRESPONDING ls_ret TO ls_return.
      APPEND ls_return TO lt_return.
      CALL METHOD lo_logger->log_bapi_return
        EXPORTING
          it_bapi_messages = lt_return
          iv_agent         = 'DPC'.
      CLEAR: ls_return, lt_return.
    ENDIF.

*Get sales unit
    CLEAR lv_vrkme.
    CALL FUNCTION 'SRA016_GET_SALES_UNIT'
      EXPORTING
        i_product   = ls_key_values-material
        i_sales_org = ls_key_values-salesorganization
        i_distr_cha = ls_key_values-distributionchannel
      IMPORTING
        e_vrkme     = lv_vrkme
      EXCEPTIONS
        not_found   = 1
        OTHERS      = 2.
    IF sy-subrc = 0 AND lv_vrkme IS NOT INITIAL.
      ls_mat_det-base_uom = lv_vrkme.
    ENDIF.

    CLEAR ls_ret.
    REFRESH: lt_return.

*---------------------------------------
*Populate data for Order Simulate
*---------------------------
*Header Data
    ls_ord_header_in-sales_org = ls_key_values-salesorganization.
    ls_ord_header_in-division = ls_key_values-division.
    ls_ord_header_in-distr_chan = ls_key_values-distributionchannel.
    ls_ord_header_in-doc_type = lv_auart.
    ls_ord_header_in-req_date_h = lv_reqdate.
*Item Data
    ls_items_in-itm_number = '00010'.
    ls_items_in-material = ls_key_values-material.
*  ls_items_in-req_qty = lv_reqqty.
    ls_items_in-target_qu = ls_mat_det-base_uom.
    APPEND ls_items_in TO lt_items_in.

*Partner data
    ls_partner-partn_role = 'AG'.
    ls_partner-partn_numb = ls_key_values-customer_no.
    APPEND ls_partner TO lt_partner.
*- Ship to Partner data
    ls_partner-partn_role = 'WE'.
    ls_partner-partn_numb = lv_shiptoparty.
    APPEND ls_partner TO lt_partner.
*Schedule Line data
    ls_schd_in-itm_number = '000010'.
    ls_schd_in-req_date = lv_reqdate.
    ls_schd_in-req_qty = lv_reqqty.
    APPEND ls_schd_in TO lt_schd_in.
    CLEAR ls_ret.


    CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
      IMPORTING
        own_logical_system             = lv_dest
      EXCEPTIONS
        own_logical_system_not_defined = 1
        OTHERS                         = 2.
    IF sy-subrc <> 0.
    ENDIF.
    CALL FUNCTION 'BAPI_SALESORDER_SIMULATE'
      DESTINATION lv_dest
      EXPORTING
        order_header_in    = ls_ord_header_in
      IMPORTING
        return             = ls_ret
      TABLES
        order_items_in     = lt_items_in
        order_partners     = lt_partner
        order_schedule_in  = lt_schd_in
        order_items_out    = lt_items_out
        order_schedule_ex  = lt_schd_ex
        order_condition_ex = lt_conditions_ex.

    IF ls_ret IS NOT INITIAL AND ls_ret-type = 'E'.

      lv_symsgid = ls_ret-code+0(2).
      lv_symsgno = ls_ret-code+2(3).
      lo_message_container = me->mo_context->get_message_container( ).

      lo_message_container->add_message(
                 iv_msg_type          = 'E'
                 iv_msg_id            = lv_symsgid
                 iv_msg_number        = lv_symsgno
                 iv_msg_v1            = ls_ret-message_v1
                 iv_msg_v2            = ls_ret-message_v2
                 iv_msg_v3            = ls_ret-message_v3
                 iv_msg_v4            = ls_ret-message_v4
                 iv_is_leading_message     = abap_true
                 iv_add_to_response_header = abap_true

      ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error
          message_container = lo_message_container.

    ENDIF.
**-------------------------------------------------------------------------*
**             - Post Backend Call -
**-------------------------------------------------------------------------*
**  - Map properties from the backend to the Gateway output response table -


    READ TABLE lt_items_out ASSIGNING FIELD-SYMBOL(<ls_item_out>) WITH KEY material = ls_key_values-material.
    IF sy-subrc = 0.
      DATA(lv_line) = <ls_item_out>-itm_number.
      DELETE lt_schd_ex WHERE itm_number <> lv_line.
    ENDIF.

    LOOP AT lt_schd_ex ASSIGNING <ls_schd_ex>.
*  Provide the response entries according to the Top and Skip parameters that were provided at runtime
*  Only fields that were mapped will be delivered to the response table

*- Begin of insert - U104997 - Defect # 10208.
      DATA(lv_tabix) = sy-tabix.
*- End of insert - U104997 - Defect # 10208.
      ls_gw_order_items_in-material = ls_key_values-material.
      ls_gw_order_items_in-com_qty = <ls_schd_ex>-confir_qty.
      ls_gw_order_items_in-com_date = <ls_schd_ex>-req_date.
      ls_gw_order_items_in-req_date = lv_reqdate.
      ls_gw_order_items_in-req_qty = lv_reqqty.

*- Get price validity
      READ TABLE lt_conditions_ex ASSIGNING <ls_conditions_ex> WITH KEY itm_number = <ls_schd_ex>-itm_number cond_type = 'ZB00'.
      IF sy-subrc = 0.
        DATA(lv_cond_no) = <ls_conditions_ex>-cond_no.
      ENDIF.

      " This next block is used to obtain the List Price (the amount) that
      " will be displayed to the user.
      READ TABLE lt_conditions_ex ASSIGNING <ls_conditions_ex> WITH KEY itm_number = <ls_schd_ex>-itm_number cond_type = 'ZL00'.
      IF sy-subrc = 0.
        ls_gw_order_items_in-currency = <ls_conditions_ex>-currency.
        " Here we need to transform the amount so that it has the proper currency
        " format used for display.
        lv_amount_external = <ls_conditions_ex>-cond_value.
        CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
          EXPORTING
            currency             = ls_gw_order_items_in-currency
            amount_external      = lv_amount_external
            max_number_of_digits = '23'
          IMPORTING
            amount_internal      = ls_gw_order_items_in-price
          EXCEPTIONS
            error_message        = 1.
        IF sy-subrc NE 0.
          ls_gw_order_items_in-price = lv_amount_external.
        ENDIF.
        IF lv_cond_no IS INITIAL.
          lv_cond_no = <ls_conditions_ex>-cond_no.
        ENDIF.
      ENDIF.

      " Here we get the calculated Net Values (Net Amount) from ls_item_out populated
      " in the previous call to BAPI_SALESORDER_SIMULATE. We also calculate the
      " Net Price (Your Price)
      READ TABLE lt_conditions_ex ASSIGNING <ls_conditions_ex> WITH KEY itm_number = <ls_schd_ex>-itm_number cond_type = 'ZNET'.
      IF sy-subrc = 0.

        lv_amount_external = <ls_conditions_ex>-cond_value.
        CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
          EXPORTING
            currency             = ls_gw_order_items_in-currency
            amount_external      = lv_amount_external
            max_number_of_digits = '23'
          IMPORTING
            amount_internal      = ls_gw_order_items_in-customerprice
          EXCEPTIONS
            error_message        = 1.
        IF sy-subrc NE 0.
          ls_gw_order_items_in-customerprice = lv_amount_external.
        ENDIF.

      ENDIF.
      READ TABLE lt_items_out INTO ls_items_out INDEX 1.
      IF sy-subrc = 0.
        ls_gw_order_items_in-total_price = ls_gw_order_items_in-customerprice * <ls_schd_ex>-confir_qty.

        " If we have no quantity available, then we need to obtain the plant phone number for
        " display purposes.
        IF <ls_schd_ex>-confir_qty IS INITIAL AND lv_phone IS INITIAL.
          CALL FUNCTION 'SRA016_GET_PLANT_PHONE_NO'
            EXPORTING
              i_plant    = ls_items_out-plant
            IMPORTING
              e_phone_no = lv_phone
            EXCEPTIONS
              not_found  = 1
              OTHERS     = 2.
          IF sy-subrc = 0.
            ls_gw_order_items_in-contact_no = lv_phone.
          ENDIF.
        ENDIF.
      ENDIF.

      ls_gw_order_items_in-currency = ls_items_out-currency.

*- Begin of comment - U104997 - Defect # 10208.

*        CALL FUNCTION 'ZOTC_DISC_CHECK_SOURCE'
*          EXPORTING
*            it_cond  = lt_conditions_ex
*          IMPORTING
*            ex_bezei = lv_bezei
*            ex_datab = lv_datab
*            ex_datbi = lv_datbi.
*- End of comment - U104997 - Defect # 10208.
      IF lv_tabix = 1.

        CALL FUNCTION 'ZOTC_DISC_CHECK_SOURCE'
          EXPORTING
            it_cond     = lt_conditions_ex
            im_material = ls_key_values-material
            im_vkorg    = ls_key_values-salesorganization
*- Begin of insert - U104997 - Defect # 10208.
            im_vtweg    = ls_key_values-distributionchannel
            im_spart    = ls_key_values-division
            im_kunag    = ls_key_values-customer_no
            im_kunwe    = lv_shiptoparty
*- Begin of insert - U104997 - Defect # 10208.
          IMPORTING
            ex_bezei    = lv_bezei
            ex_datab    = lv_datab
            ex_datbi    = lv_datbi.

      ENDIF.
      MOVE: lv_datab TO ls_gw_order_items_in-datab,
            lv_datbi TO ls_gw_order_items_in-datbi.

      ls_gw_order_items_in-customer_group = lv_bezei.

      IF ls_gw_order_items_in-com_qty = 0.
        CLEAR ls_gw_order_items_in-com_date.
      ENDIF.

      APPEND ls_gw_order_items_in TO et_entityset.
      CLEAR ls_gw_order_items_in.
    ENDLOOP.

    DESCRIBE TABLE et_entityset LINES lv_lines.
    IF lv_lines > 1.
      DELETE et_entityset WHERE com_qty = 0.
    ENDIF.

    no_cache( ).

  ENDMETHOD.


  METHOD productcollectio_get_entity.
****************************************************************************
*Program    : PRODUCTCOLLECTIO_GET_ENTITY                                  *
*Title      : ZCL_ZSRA016_PRICE_AVAI_DPC_EXT~PRODUCTCOLLECTIO_GET_ENTITY   *
*Developer  : Nrupen Polasani                                              *
*Object type: OData Service                                                *
*SAP Release: SAP ECC 6.0                                                  *
*--------------------------------------------------------------------------*
*WRICEF ID: OTC_MDD_0002                                                   *
*--------------------------------------------------------------------------*
****************************************************************************
* Method (PRODUCTCOLLECTIO_GET_ENTITY) :This method is used to get the     *
* particular single material details when searched by a user               *
*--------------------------------------------------------------------------*
*MODIFICATION HISTORY:
*==========================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ================================*
*06-Dec-2018   U104997       E2DK923449      INITIAL DEVELOPMENT           *
*--------------------------------------------------------------------------*


    DATA  lv_customer             TYPE if_bapi_salesorder_getlist2=>bapi1007-customer.
    DATA  lv_product_id           TYPE matnr.
    DATA  ls_material             TYPE ts_material.
    DATA  lt_materials            TYPE t_material.
    DATA  lt_products             TYPE zcl_zsra016_price_avai_mpc=>tt_product.
    FIELD-SYMBOLS <fs_key_tab>    TYPE /iwbep/s_mgw_name_value_pair.

    LOOP AT it_key_tab ASSIGNING <fs_key_tab>.
      CASE <fs_key_tab>-name.
        WHEN 'CustomerID'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = <fs_key_tab>-value
            IMPORTING
              output = lv_customer.
        WHEN 'ProductID'.
          lv_product_id = convert_to_matnr( <fs_key_tab>-value ).
      ENDCASE.
    ENDLOOP.

    ls_material-material = lv_product_id.
    APPEND ls_material TO lt_materials.

    retrieve_products( EXPORTING iv_customer = lv_customer
                                 it_materials = lt_materials
                       IMPORTING et_products = lt_products ).

    READ TABLE lt_products INTO er_entity INDEX 1.

    no_cache( ).

  ENDMETHOD.


METHOD productcollectio_get_entityset.
****************************************************************************
*Program    : PRODUCTCOLLECTIO_GET_ENTITYSET                               *
*Title      : ZCL_ZSRA016_PRICE_AVAI_DPC_EXT~PRODUCTCOLLECTIO_GET_ENTITYSET*
*Developer  : Nrupen Polasani                                              *
*Object type: OData Service                                                *
*SAP Release: SAP ECC 6.0                                                  *
*--------------------------------------------------------------------------*
*WRICEF ID: OTC_MDD_0002                                                   *
*--------------------------------------------------------------------------*
****************************************************************************
* Method (PRODUCTCOLLECTIO_GET_ENTITYSET) :This method is used to get the  *
* table for all the material the customer was sold in last 90 days         *
*--------------------------------------------------------------------------*
*MODIFICATION HISTORY:
*==========================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ================================*
*06-Dec-2018   U104997       E2DK923449      INITIAL DEVELOPMENT           *
*--------------------------------------------------------------------------*
*05-Sep-2019   U104997       E2DK926561      SCTASK0867043                 *
*                                            Extending the number of orders*
*--------------------------------------------------------------------------*

*-------------------------------------------------------------
*  Data declaration
*-------------------------------------------------------------

  TYPES: BEGIN OF ty_sales,
           vbeln TYPE vbak-vbeln,
           erdat TYPE vbak-erdat,
           posnr TYPE vbap-posnr,
           matnr TYPE vbap-matnr,
           meins TYPE vbap-meins,
         END OF ty_sales.
*--> Begin of comment - SCTASK0867043 - U104997
  TYPES: BEGIN OF ty_likp,
           vbeln TYPE likp-vbeln,
           erdat TYPE likp-erdat,
           kunnr TYPE likp-kunnr,
           kunag TYPE likp-kunag,
         END OF ty_likp,

         BEGIN OF ty_lips,
           vbeln TYPE lips-vbeln,
           matnr TYPE lips-matnr,
           meins TYPE lips-meins,
         END OF ty_lips.

  DATA: lt_likp    TYPE STANDARD TABLE OF ty_likp,
        lt_lips    TYPE STANDARD TABLE OF ty_lips,
        ls_likp    TYPE ty_likp,
        ls_lips    TYPE ty_lips,
        lc_project TYPE z_enhancement VALUE 'OTC_MDD_0002',
        lc_days    TYPE z_criteria VALUE 'DAYS',
        lc_count   TYPE z_criteria VALUE 'COUNT',
        lv_days    TYPE i,
        lv_count   TYPE i,
        lt_status  TYPE TABLE OF zdev_enh_status,
        ls_status  TYPE zdev_enh_status.
*<-- End of comment - SCTASK0867043 - U104997

  DATA: lt_sales_orders    TYPE STANDARD TABLE OF ty_sales,
        lv_no              TYPE i VALUE 0,
        ls_material        TYPE ts_material,
        lt_material_all    TYPE t_material,
        lt_material_subset TYPE t_material,
        lt_return          TYPE STANDARD TABLE OF bapiret2,
        lt_matnr_sel       TYPE STANDARD TABLE OF bapimatram,
        ls_matnr_sel       TYPE bapimatram,
        ls_matnrdesc_sel   TYPE bapimatras,
        lt_matnrdesc_sel   TYPE STANDARD TABLE OF bapimatras,
        lt_matnr_list      TYPE STANDARD TABLE OF bapimatlst,
        ls_paging          TYPE /iwbep/s_mgw_paging,
        lv_start           TYPE int4 VALUE 1,
        lv_end             TYPE int4,
        ls_t100key         TYPE scx_t100key,                "#EC NEEDED
        lo_logger          TYPE REF TO /iwbep/cl_cos_logger.

  DATA lv_search_string TYPE string.

  DATA lv_startdate TYPE vbak-erdat.
  DATA lv_enddate TYPE vbak-erdat.

  FIELD-SYMBOLS:  <ls_sales_order>           TYPE ty_sales.
  FIELD-SYMBOLS:  <ls_filter_select_option>  TYPE /iwbep/s_mgw_select_option.
  FIELD-SYMBOLS:  <ls_sel_option>            TYPE /iwbep/s_cod_select_option.
  FIELD-SYMBOLS:  <ls_matnr_list>            TYPE bapimatlst.

*---logger----
  lo_logger = mo_context->get_logger( ).

* Get source keys (converted)
  DATA: BEGIN OF ls_key_values,
          customer_id         TYPE kunnr,
          distributionchannel TYPE vtweg,
          division            TYPE spart,
          salesorganization   TYPE vkorg,
          shiptoparty         TYPE kunwe,
        END OF ls_key_values.
  io_tech_request_context->get_converted_source_keys( IMPORTING es_key_values = ls_key_values ).

*-------------------------------------------------------------------------------------------------------------------------
* products based on sales order of customer
*-------------------------------------------------------------------------------------------------------------------------
  IF it_filter_select_options IS INITIAL.
*--------------------------------------------------------------------*
*get the materials based on sales order created by customer
*--------------------------------------------------------------------*
* Note 2094981 v1 starts

    lv_enddate = sy-datum.

*--> Begin of Insert - SCTASK0867043 - U104997
    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
      EXPORTING
        iv_enhancement_no = lc_project
      TABLES
        tt_enh_status     = lt_status.
    DELETE lt_status WHERE active EQ abap_false.

    READ TABLE lt_status INTO ls_status WITH KEY criteria = lc_days.
    IF sy-subrc = 0.
      lv_days = ls_status-sel_low.
    ENDIF.
    CLEAR ls_status.
    READ TABLE lt_status INTO ls_status WITH KEY criteria = lc_count.
    IF sy-subrc = 0.
      lv_count = ls_status-sel_low.
    ENDIF.
    CLEAR ls_status.
    lv_startdate = lv_enddate - lv_days.
*<-- End of Insert - SCTASK0867043 - U104997

*--> Begin of Comment - SCTASK0867043 - U104997
*    lv_startdate = lv_enddate - 180.
*<-- End of Comment - SCTASK0867043 - U104997
*--------------------------------------------------------------------*
*--> Begin of Insert - SCTASK0867043 - U104997

    SELECT vbeln erdat kunnr kunag
       UP TO lv_count ROWS
      FROM likp
      INTO TABLE lt_likp
      WHERE erdat > lv_startdate AND          " Past 180 days
            erdat <= lv_enddate AND           " Past 180 days
            kunnr = ls_key_values-shiptoparty " Ship to Party selected on sccreen
      ORDER BY erdat DESCENDING vbeln DESCENDING.

    IF sy-subrc = 0 AND lt_likp[] IS NOT INITIAL.
      DELETE lt_likp WHERE kunag <> ls_key_values-customer_id. " Delete all entries that do not match sold to
      IF lt_likp[] IS NOT INITIAL.
        SELECT vbeln
               matnr
               meins
          FROM lips
          INTO TABLE lt_lips
          FOR ALL ENTRIES IN lt_likp
          WHERE vbeln = lt_likp-vbeln.
        IF sy-subrc <> 0.
          ls_t100key-msgid = 'CM_SRA016_PRC_AVL'.
          ls_t100key-msgno = 011. " No product found
          ls_t100key-attr1 = sy-uname.
          RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
            EXPORTING
              textid = ls_t100key.
        ENDIF.
      ENDIF.
    ELSE.
      ls_t100key-msgid = 'CM_SRA016_PRC_AVL'.
      ls_t100key-msgno = 011. " No product found
      ls_t100key-attr1 = sy-uname.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid = ls_t100key.
    ENDIF.

*<-- End of Insert - SCTASK0867043 - U104997
*--> Begin of comment - SCTASK0867043 - U104997
*    SELECT vbeln erdat posnr matnr "meins_i
*      UP TO 10 ROWS
*      FROM rog_vbakap
*      INTO TABLE lt_sales_orders
*      WHERE erdat > lv_startdate AND
*            erdat <= lv_enddate AND
*            kunnr = ls_key_values-customer_id
*      ORDER BY erdat DESCENDING vbeln DESCENDING.
*    IF sy-subrc <> 0.
*      ls_t100key-msgid = 'CM_SRA016_PRC_AVL'.
*      ls_t100key-msgno = 011. " No product found
*      ls_t100key-attr1 = sy-uname.
*      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
*        EXPORTING
*          textid = ls_t100key.
*    ENDIF.
*    IF lt_sales_orders IS NOT INITIAL.
*      SELECT * FROM vbpa
*        INTO TABLE @DATA(lt_vbpa)
*        FOR ALL ENTRIES IN @lt_sales_orders
*        WHERE vbeln = @lt_sales_orders-vbeln
*        AND ( posnr = @lt_sales_orders-posnr OR posnr = '000000')
*        AND parvw = 'WE'
*        AND kunnr = @ls_key_values-shiptoparty.
*      IF sy-subrc = 0.
*        LOOP AT lt_sales_orders ASSIGNING FIELD-SYMBOL(<fs_sales_order>).
*          READ TABLE lt_vbpa ASSIGNING FIELD-SYMBOL(<fs_vbpa>) WITH KEY vbeln = <fs_sales_order>-vbeln.
*          IF sy-subrc <> 0.
*            CLEAR <fs_sales_order>-vbeln.
*          ENDIF.
*        ENDLOOP.
*        DELETE lt_sales_orders WHERE vbeln IS INITIAL.
*      ENDIF.
*    ENDIF.
*<-- End of comment - SCTASK0867043 - U104997
*--------------------------------------------------------------------*

    " Removing corrupt data - sales order which do not have a material assigned
*--> Begin of comment - SCTASK0867043 - U104997
*    SORT lt_sales_orders BY matnr.
*    DELETE ADJACENT DUPLICATES FROM lt_sales_orders COMPARING matnr.
*    SORT lt_sales_orders BY vbeln DESCENDING posnr ASCENDING.
*
*    " Extract material nos. from 10 latest sales order of a customer
*    LOOP AT lt_sales_orders ASSIGNING <ls_sales_order>.
*      lv_no = lv_no + 1.
*      ls_material-seq_no = lv_no.
*      ls_material-material = <ls_sales_order>-matnr.
*      ls_material-base_uom = <ls_sales_order>-meins.
*      APPEND ls_material TO lt_material_all.
*    ENDLOOP.
*<-- End of comment - SCTASK0867043 - U104997
*--> Begin of Insert - SCTASK0867043 - U104997
    SORT lt_lips BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_lips COMPARING matnr.
    SORT lt_lips BY vbeln DESCENDING.

    LOOP AT lt_lips ASSIGNING FIELD-SYMBOL(<ls_lips>).
      lv_no = lv_no + 1.
      ls_material-seq_no = lv_no.
      ls_material-material = <ls_lips>-matnr.
      ls_material-base_uom = <ls_lips>-meins.
      APPEND ls_material TO lt_material_all.
    ENDLOOP.

*<-- End of Insert - SCTASK0867043 - U104997
    CLEAR: lv_no.
    SORT lt_material_all BY seq_no.

*-------------------------------------------------------------------------------------------------------------------------
*  products based on search criteria given by customer
*-------------------------------------------------------------------------------------------------------------------------
  ELSE.
    LOOP AT it_filter_select_options ASSIGNING <ls_filter_select_option>.

      LOOP AT <ls_filter_select_option>-select_options ASSIGNING <ls_sel_option>.
        CASE <ls_filter_select_option>-property.
          WHEN 'PrdSearch'.
            lv_search_string = <ls_sel_option>-low.
          WHEN OTHERS.
            " Log message in the application log
            me->/iwbep/if_sb_dpc_comm_services~log_message(
              EXPORTING
                iv_msg_type   = 'E'
                iv_msg_id     = 'CM_SRA016_PRC_AVL'
                iv_msg_number = 001 ).
            " Raise Exception
            CLEAR ls_t100key.
            ls_t100key-msgid = 'CM_SRA016_PRC_AVL'.
            ls_t100key-msgno = 001. " Only 'PrdSearch' is a valid filter parameter
            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
              EXPORTING
                textid = ls_t100key.
        ENDCASE.
      ENDLOOP.
    ENDLOOP.

*----------prepare seach based on description----------*
    ls_matnr_sel-sign   = ls_matnrdesc_sel-sign   = 'I'.
    ls_matnr_sel-option = ls_matnrdesc_sel-option = 'CP'.

*      format_material_search( EXPORTING iv_search_string   = lv_search_string
*                              IMPORTING ev_formated_search = ls_matnrdesc_sel-descr_low ).
    ls_matnrdesc_sel-descr_low = lv_search_string.
    APPEND ls_matnrdesc_sel TO lt_matnrdesc_sel.

*----------prepare seach based on product----------*
    IF lv_search_string CO '*' " If search string is empty then always search on 18 character material.
      OR cl_sra016_lama=>is_lama_active( ) EQ abap_false. " LAMA is not active

      IF strlen( lv_search_string ) <= 18. " Search is possibly a material
*            format_material_search( EXPORTING iv_search_string   = lv_search_string
*                                    IMPORTING ev_formated_search = ls_matnr_sel-matnr_low ).
        ls_matnr_sel-matnr_low = lv_search_string.
        APPEND ls_matnr_sel TO lt_matnr_sel.
      ENDIF.

    ELSE. " LAMA is active

      DATA lr_matnr_sel TYPE REF TO data.
      CREATE DATA lr_matnr_sel TYPE bapimatram.

      FIELD-SYMBOLS <fs_ref_field> TYPE any.
      ASSIGN lr_matnr_sel->('matnr_low_external') TO <fs_ref_field>.
      IF <fs_ref_field> IS ASSIGNED.
        <fs_ref_field> = ls_matnrdesc_sel-descr_low.
      ENDIF.

      FIELD-SYMBOLS <fs_matnr_sel> TYPE bapimatram.
      ASSIGN lr_matnr_sel->* TO <fs_matnr_sel>.
      IF <fs_matnr_sel> IS ASSIGNED.
        <fs_matnr_sel>-sign = 'I'.
        <fs_matnr_sel>-option = 'EQ'.
        APPEND <fs_matnr_sel> TO lt_matnr_sel.
      ENDIF.

    ENDIF. " End of LAMA

*----------perform seach----------*
    CALL FUNCTION 'BAPI_MATERIAL_GETLIST'
      TABLES
        matnrselection       = lt_matnr_sel
        materialshortdescsel = lt_matnrdesc_sel
        matnrlist            = lt_matnr_list
        return               = lt_return.

    IF lt_return IS NOT INITIAL.
      lo_logger->log_bapi_return( it_bapi_messages = lt_return
                                  iv_agent         = 'DPC' ).
      CLEAR lt_return.
      RETURN.
    ENDIF.

    LOOP AT lt_matnr_list ASSIGNING <ls_matnr_list>.
      ls_material-material = <ls_matnr_list>-material.
      APPEND ls_material TO lt_material_all.
    ENDLOOP.
*------test ENDIF for Filter
  ENDIF.


*--------------------------------------------------------------------*
*  process $top and skip
*--------------------------------------------------------------------*

  " Get key table information
  ls_paging-top = io_tech_request_context->get_top( ).
  ls_paging-skip = io_tech_request_context->get_skip( ).

  IF ls_paging-skip IS NOT INITIAL.
    " If the Skip value was requested at runtime the response table will
    " provide backend entries from skip + 1, meaning start from skip + 1
    " for example: skip=5 means to start get results from the 6th row.
    lv_start = ls_paging-skip + 1.
  ENDIF.
  " The Top value was requested at runtime but was not handled as part of the function interface
  IF  ls_paging-top <> 0 AND lv_start IS NOT INITIAL.
    " if lv_start > 0 retrieve the entries from lv_start + Top - 1
    " for example: skip=5 and top=2 means to start get results from the 6th row and end in row number 7
    lv_end = ls_paging-top + lv_start - 1.
  ELSEIF ls_paging-top <> 0 AND    lv_start IS INITIAL.
    lv_end = ls_paging-top.
  ELSE.
    lv_end = lines( lt_material_all ).
  ENDIF.

  " Here we need to return the total count of materials found
  IF io_tech_request_context->has_inlinecount( ) = abap_true.
    es_response_context-inlinecount = lines( lt_material_all ).
  ENDIF.

  " Here we limit ourselve only to the materials that are going to be part of the
  " 'paging' batch that is going to be sent to UI.
  APPEND LINES OF lt_material_all FROM lv_start TO lv_end TO lt_material_subset.

  retrieve_products( EXPORTING iv_customer    = ls_key_values-customer_id
                               it_materials   = lt_material_subset
                     IMPORTING et_products    = et_entityset ).

  no_cache( ).
ENDMETHOD.


METHOD retrieve_products.
****************************************************************************
*Program    : RETRIEVE_PRODUCTS                                            *
*Title      : ZCL_ZSRA016_PRICE_AVAI_DPC_EXT~RETRIEVE_PRODUCTS             *
*Developer  : Nrupen Polasani                                              *
*Object type: OData Service                                                *
*SAP Release: SAP ECC 6.0                                                  *
*--------------------------------------------------------------------------*
*WRICEF ID: OTC_MDD_0002                                                   *
*--------------------------------------------------------------------------*
****************************************************************************
* Method (RETRIEVE_PRODUCTS): This method is used to get the materials     *
* based on the search criteria entered by the user                         *
*--------------------------------------------------------------------------*
*MODIFICATION HISTORY:
*==========================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ================================*
*06-Dec-2018   U104997       E2DK923449      INITIAL DEVELOPMENT           *
*--------------------------------------------------------------------------*

  TYPES: BEGIN OF ty_mvke,
           matnr TYPE matnr,
           vrkme TYPE vrkme,
         END OF ty_mvke.

  TYPES: BEGIN OF ty_t006a,
           msehi TYPE msehi,
           msehl TYPE msehl,
         END OF ty_t006a.

  TYPES: BEGIN OF ty_mat_desc,
           matnr TYPE matnr,
           bismt TYPE bismt,
           meins TYPE meins,
           maktx TYPE maktx,
         END OF ty_mat_desc.

  DATA  lt_sales_unit           TYPE STANDARD TABLE OF ty_mvke.
  DATA  lt_sales_unit_temp      TYPE STANDARD TABLE OF ty_mvke.
  DATA  lt_material_subset_temp TYPE t_material.
  DATA  lt_unit_desc            TYPE STANDARD TABLE OF ty_t006a.
  DATA  lt_mat_desc             TYPE STANDARD TABLE OF ty_mat_desc.
  DATA  lt_material_subset      TYPE t_material.
  DATA  lt_mat_desc_temp        TYPE STANDARD TABLE OF ty_mat_desc.
  DATA  ls_items_in             TYPE bapiitemin.
  DATA  lo_logger               TYPE REF TO /iwbep/cl_cos_logger.
  DATA  ls_product              LIKE LINE OF et_products.

  FIELD-SYMBOLS:  <ls_material>             TYPE ts_material.
  FIELD-SYMBOLS:  <ls_sales_unit>           TYPE ty_mvke.
  FIELD-SYMBOLS:  <ls_unit_desc>            TYPE ty_t006a.
  FIELD-SYMBOLS:  <ls_mat_desc>             TYPE ty_mat_desc.

*---logger----
  lo_logger = mo_context->get_logger( ).

  lt_material_subset = it_materials.

  lt_material_subset_temp = lt_material_subset.
  SORT lt_material_subset_temp BY base_uom ASCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_material_subset_temp COMPARING base_uom.

  IF lt_material_subset_temp[] IS NOT INITIAL.
*Select the Sales Unit of Measure for selected materials.
    SELECT matnr vrkme FROM mvke
      INTO TABLE lt_sales_unit
      FOR ALL ENTRIES IN lt_material_subset_temp
      WHERE matnr = lt_material_subset_temp-material.
    IF sy-subrc EQ 0.
      SORT lt_sales_unit BY matnr ASCENDING.
      lt_sales_unit_temp = lt_sales_unit.
      SORT lt_sales_unit_temp BY vrkme ASCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_sales_unit_temp COMPARING vrkme.

*select description for Unit of measure.
      IF lt_sales_unit_temp[] IS NOT INITIAL.
        SELECT msehi msehl FROM t006a
          INTO TABLE lt_unit_desc
          FOR ALL ENTRIES IN  lt_sales_unit_temp
          WHERE spras = sy-langu AND
          msehi = lt_sales_unit_temp-vrkme.
        REFRESH lt_sales_unit_temp.
      ENDIF.
    ENDIF.

*select Old Material number and Description for Material
    IF lt_material_subset[] IS NOT INITIAL.
      SELECT a~matnr a~bismt a~meins b~maktx
        INTO TABLE lt_mat_desc
        FROM mara AS a INNER JOIN makt AS b
        ON a~matnr = b~matnr
        FOR ALL ENTRIES IN lt_material_subset
        WHERE a~matnr = lt_material_subset-material AND
              b~spras = sy-langu.
      IF sy-subrc EQ 0.
        lt_mat_desc_temp = lt_mat_desc.
        SORT lt_mat_desc_temp BY meins ASCENDING.
        DELETE ADJACENT DUPLICATES FROM lt_mat_desc_temp COMPARING meins.

*select description for Unit of measure.
        IF lt_mat_desc[] IS NOT INITIAL.
          SORT lt_mat_desc[] BY matnr ASCENDING.
          SELECT msehi msehl FROM t006a
                  APPENDING TABLE lt_unit_desc
                  FOR ALL ENTRIES IN  lt_mat_desc
                  WHERE spras = sy-langu AND
                        msehi = lt_mat_desc-meins.
          REFRESH lt_mat_desc_temp.
        ENDIF.

      ENDIF.
    ENDIF.
    SORT lt_unit_desc BY msehi ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_unit_desc COMPARING msehi.

*------------------------------------------*
*  Process entries
*------------------------------------------*
    LOOP AT lt_material_subset ASSIGNING <ls_material>.

      UNASSIGN <ls_sales_unit>.
      READ TABLE lt_sales_unit ASSIGNING <ls_sales_unit> WITH KEY matnr = <ls_material>-material BINARY SEARCH.
      IF sy-subrc EQ 0 AND <ls_sales_unit>-vrkme IS NOT INITIAL.
        <ls_material>-base_uom = <ls_sales_unit>-vrkme.
      ENDIF.

      UNASSIGN <ls_unit_desc>.
      READ TABLE lt_unit_desc ASSIGNING <ls_unit_desc> WITH KEY msehi = <ls_material>-base_uom BINARY SEARCH.
      IF sy-subrc EQ 0.
        <ls_material>-base_uom_desc = <ls_unit_desc>-msehl.
      ENDIF.

      UNASSIGN <ls_mat_desc>.
      READ TABLE lt_mat_desc ASSIGNING <ls_mat_desc> WITH KEY matnr = <ls_material>-material." BINARY SEARCH.
      IF sy-subrc EQ 0.
        <ls_material>-old_mat_no = <ls_mat_desc>-bismt.
        <ls_material>-matl_desc  = <ls_mat_desc>-maktx.
        <ls_material>-base_uom   = <ls_mat_desc>-meins.
      ENDIF.

      ls_items_in-material = <ls_material>-material.
      ls_items_in-target_qu = <ls_material>-base_uom.
      ls_items_in-itm_number = ls_items_in-itm_number + 10.

    ENDLOOP.

    SORT lt_material_subset BY material.


*-------------------------------------------------------------------------*
*             - Post Backend Call -
*-------------------------------------------------------------------------*
*  - Map properties from the backend to the Gateway output response table -

    LOOP AT lt_material_subset ASSIGNING <ls_material>.
*  Only fields that were mapped will be delivered to the response table
      ls_product-material = <ls_material>-material.
      ls_product-matl_desc = <ls_material>-matl_desc.
      ls_product-old_mat_no = <ls_material>-old_mat_no.
      ls_product-net_price = <ls_material>-net_price.
      ls_product-currency = <ls_material>-currency.
      ls_product-base_uom = <ls_material>-base_uom.
      ls_product-base_uom_desc = <ls_material>-base_uom_desc.
      ls_product-customer_material = <ls_material>-customer_material.
      ls_product-customer_no = iv_customer.

      get_sales_org( EXPORTING iv_kunnr   = iv_customer
                               iv_matnr = <ls_material>-material
                     IMPORTING ev_vkorg = ls_product-salesorganization
                               ev_vtweg = ls_product-distributionchannel
                               ev_spart = ls_product-division ).

**
      APPEND ls_product TO et_products.
      CLEAR ls_product.
    ENDLOOP.
  ENDIF.
ENDMETHOD.


  METHOD shiptoset_get_entity.
****************************************************************************
*Program    : SHIPTOSET_GET_ENTITY                                         *
*Title      : ZCL_ZSRA016_PRICE_AVAI_DPC_EXT~SHIPTOSET_GET_ENTITY          *
*Developer  : Nrupen Polasani                                              *
*Object type: OData Service                                                *
*SAP Release: SAP ECC 6.0                                                  *
*--------------------------------------------------------------------------*
*WRICEF ID: OTC_MDD_0002                                                   *
*--------------------------------------------------------------------------*
****************************************************************************
* Method (SHIPTOSET_GET_ENTITY): This method is used to get validate the   *
* sold to partner entered on the screen by the user                        *
*--------------------------------------------------------------------------*
*MODIFICATION HISTORY:
*==========================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ================================*
*06-Dec-2018   U104997       E2DK923449      INITIAL DEVELOPMENT           *
*--------------------------------------------------------------------------*
*05-Sep-2019   U104997       E2DK926561      SCTASK0867043                 *
*                                            Add Po Box to Customer Address*
*--------------------------------------------------------------------------*

    DATA lv_customer TYPE if_bapi_salesorder_getlist2=>bapi1007-customer.
    DATA lo_message_container TYPE REF TO /iwbep/if_message_container.
    FIELD-SYMBOLS <fs_key_tab> TYPE /iwbep/s_mgw_name_value_pair.

    LOOP AT it_key_tab ASSIGNING <fs_key_tab>.
      CASE <fs_key_tab>-name.
        WHEN 'Kunwe'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = <fs_key_tab>-value
            IMPORTING
              output = lv_customer.
      ENDCASE.
    ENDLOOP.
    IF lv_customer IS NOT INITIAL.
      SELECT kunnr land1 name1
             ort01 pstlz regio stras
*--> Begin of Insert - SCTASK0867043 - U104997
             pfach
*<-- End of Insert - SCTASK0867043 - U104997
        FROM kna1
        INTO CORRESPONDING FIELDS OF er_entity
        WHERE kunnr = lv_customer
        AND aufsd eq space.
      ENDSELECT.
      IF sy-subrc <> 0.
        lo_message_container = me->mo_context->get_message_container( ).

        lo_message_container->add_message(
                   iv_msg_type          = 'E'
                   iv_msg_id            = 'ZOTC_MSG'
                   iv_msg_number        = 309
                   iv_msg_v1            = 'Error'
                   iv_is_leading_message     = abap_true
                   iv_add_to_response_header = abap_true
        ).

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid            = /iwbep/cx_mgw_busi_exception=>business_error
            message_container = lo_message_container.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD shiptoset_get_entityset.
****************************************************************************
*Program    : SHIPTOSET_GET_ENTITYSET                                      *
*Title      : ZCL_ZSRA016_PRICE_AVAI_DPC_EXT~SHIPTOSET_GET_ENTITYSET       *
*Developer  : Nrupen Polasani                                              *
*Object type: OData Service                                                *
*SAP Release: SAP ECC 6.0                                                  *
*--------------------------------------------------------------------------*
*WRICEF ID: OTC_MDD_0002                                                   *
*--------------------------------------------------------------------------*
****************************************************************************
* Method (SHIPTOSET_GET_ENTITYSET): This method is used to get all the sold*
* to partners in the system from the search criteria of user               *
*--------------------------------------------------------------------------*
*MODIFICATION HISTORY:
*==========================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ================================*
*06-Dec-2018   U104997       E2DK923449      INITIAL DEVELOPMENT           *
*--------------------------------------------------------------------------*
*05-Sep-2019   U104997       E2DK926561      SCTASK0867043                 *
*                                            Add Po Box to Customer Address*
*--------------------------------------------------------------------------*



    TYPES :
      BEGIN OF ty_knvp,
        kunnr TYPE knvp-kunnr,
        kunn2 TYPE knvp-kunn2,
      END OF ty_knvp,

      BEGIN OF ty_kna1,
        kunnr TYPE kna1-kunnr,
        name1 TYPE kna1-name1,
        regio TYPE kna1-regio,
        land1 TYPE kna1-land1,
        stras TYPE kna1-stras,
        ort01 TYPE kna1-ort01,
        pstlz TYPE kna1-pstlz,
        kunn2 TYPE knvp-kunn2,
*--> Begin of Insert - SCTASK0867043 - U104997
        pfach TYPE kna1-pfach,
*<-- End of Insert - SCTASK0867043 - U104997
      END OF ty_kna1.

    DATA:
      lt_filters  TYPE /iwbep/t_mgw_select_option,
      ls_filter   TYPE /iwbep/s_mgw_select_option,
      lv_table    TYPE tabname,
      lv_text     TYPE char45,
      lt_knvp     TYPE STANDARD TABLE OF ty_knvp,
      ls_cond_tab TYPE grpcrta_s_condtab,
      lt_cond_tab TYPE grpcrta_t_condtab,
      lt_where    TYPE STANDARD TABLE OF text132,
      lt_kna1     TYPE STANDARD TABLE OF ty_kna1,
      lv_kunnr    TYPE kna1-kunnr,
      ls_entity   TYPE zcl_zsra016_price_avai_mpc=>ts_shipto.

    FIELD-SYMBOLS: <ls_filter_select_option> TYPE /iwbep/s_mgw_select_option,
                   <ls_sel_option>           TYPE /iwbep/s_cod_select_option.
* Get filter
    lt_filters = io_tech_request_context->get_filter( )->get_filter_select_options( ).

    READ TABLE it_filter_select_options ASSIGNING <ls_filter_select_option> WITH KEY
      property = 'Kunnr'.
    IF sy-subrc = 0.
      READ TABLE <ls_filter_select_option>-select_options ASSIGNING <ls_sel_option> INDEX 1.
      IF sy-subrc = 0 AND <ls_sel_option>-low IS NOT INITIAL.
        lv_kunnr = <ls_sel_option>-low.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_kunnr
          IMPORTING
            output = lv_kunnr.
      ENDIF.
    ENDIF.

    IF lv_kunnr IS INITIAL.
      IF it_filter_select_options IS NOT INITIAL.
        LOOP AT it_filter_select_options ASSIGNING <ls_filter_select_option>.
          LOOP AT <ls_filter_select_option>-select_options ASSIGNING <ls_sel_option>.
            CASE <ls_filter_select_option>-property.
              WHEN 'Kunwe'.
                IF <ls_sel_option>-low IS NOT INITIAL.
                  DATA(lv_kunwe) = <ls_sel_option>-low.
                  ls_cond_tab-field  = 'KUNNR LIKE'.
                  CONCATENATE '%' <ls_sel_option>-low '%' INTO ls_cond_tab-low.
                  APPEND ls_cond_tab TO lt_cond_tab.
                  CLEAR ls_cond_tab.
                ENDIF.
              WHEN 'Pstlz'.
                IF <ls_sel_option>-low IS NOT INITIAL.
                  ls_cond_tab-field  = 'PSTLZ LIKE'.
                  CONCATENATE '%' <ls_sel_option>-low '%' INTO ls_cond_tab-low.
                  APPEND ls_cond_tab TO lt_cond_tab.
                  CLEAR ls_cond_tab.
                ENDIF.
              WHEN 'Land1'.
                IF <ls_sel_option>-low IS NOT INITIAL.
                  ls_cond_tab-field  = 'LAND1 LIKE'.
                  CONCATENATE '%' <ls_sel_option>-low '%' INTO ls_cond_tab-low.
                  APPEND ls_cond_tab TO lt_cond_tab.
                  CLEAR ls_cond_tab.
                ENDIF.
              WHEN 'Name1'.
                IF <ls_sel_option>-low IS NOT INITIAL.
                  MOVE <ls_sel_option>-low TO lv_text.
                  ls_cond_tab-field  = 'MCOD1 LIKE'.
                  TRANSLATE lv_text TO UPPER CASE.
                  CONCATENATE '%' lv_text '%' INTO ls_cond_tab-low.
                  APPEND ls_cond_tab TO lt_cond_tab.
                  CLEAR ls_cond_tab.
                ENDIF.
              WHEN 'Ort01'.
                IF <ls_sel_option>-low IS NOT INITIAL.
                  MOVE <ls_sel_option>-low TO lv_text.
                  ls_cond_tab-field  = 'MCOD3 LIKE'.
                  TRANSLATE lv_text TO UPPER CASE.
                  CONCATENATE '%' lv_text '%' INTO ls_cond_tab-low.
                  APPEND ls_cond_tab TO lt_cond_tab.
                  CLEAR ls_cond_tab.
                ENDIF.
              WHEN 'Regio'.
                IF <ls_sel_option>-low IS NOT INITIAL.
                  ls_cond_tab-field  = 'REGIO LIKE'.
                  CONCATENATE '%' <ls_sel_option>-low '%' INTO ls_cond_tab-low.
                  APPEND ls_cond_tab TO lt_cond_tab.
                  CLEAR ls_cond_tab.
                ENDIF.
              WHEN 'Stras'.
                IF <ls_sel_option>-low IS NOT INITIAL.
                  ls_cond_tab-field  = 'STRAS LIKE'.
                  CONCATENATE '%' <ls_sel_option>-low '%' INTO ls_cond_tab-low.
                  APPEND ls_cond_tab TO lt_cond_tab.
                  CLEAR ls_cond_tab.
                ENDIF.
*--> Begin of Insert - SCTASK0867043 - U104997
              WHEN 'Pfach'.
                IF <ls_sel_option>-low IS NOT INITIAL.
                  ls_cond_tab-field  = 'PFACH LIKE'.
                  CONCATENATE '%' <ls_sel_option>-low '%' INTO ls_cond_tab-low.
                  APPEND ls_cond_tab TO lt_cond_tab.
                  CLEAR ls_cond_tab.
                ENDIF.
*<-- End of Insert - SCTASK0867043 - U104997
              WHEN OTHERS.
                " Log message in the application log
                me->/iwbep/if_sb_dpc_comm_services~log_message(
                  EXPORTING
                    iv_msg_type   = 'E'
                    iv_msg_id     = '/IWBEP/MC_SB_DPC_ADM'
                    iv_msg_number = 021
                    iv_msg_v1     = ls_filter-property ).
                " Raise Exception
                RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
                  EXPORTING
                    textid = /iwbep/cx_mgw_tech_exception=>internal_error.
            ENDCASE.
          ENDLOOP.
        ENDLOOP.
      ENDIF.

      ls_cond_tab-field = 'AUFSD EQ'.
      ls_cond_tab-low = space.
      APPEND ls_cond_tab TO lt_cond_tab.
      CLEAR ls_cond_tab.


      CALL FUNCTION 'GRPCRTA_DYNAMIC_WHERE_BUILD'
        EXPORTING
          dbtable         = space
        TABLES
          condtab         = lt_cond_tab
          where_clause    = lt_where
        EXCEPTIONS
          empty_condtab   = 1
          no_db_field     = 2
          unknown_db      = 3
          wrong_condition = 4
          OTHERS          = 5.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      SELECT kunnr land1 name1
             ort01 pstlz regio stras
*--> Begin of Insert - SCTASK0867043 - U104997
             pfach
*<-- End of Insert - SCTASK0867043 - U104997
        FROM kna1
        INTO CORRESPONDING FIELDS OF TABLE lt_kna1
        WHERE (lt_where).
      IF lt_kna1 IS NOT INITIAL.
        IF lv_kunwe IS NOT INITIAL.
          SELECT kunnr kunn2
            FROM knvp
            INTO TABLE lt_knvp
           WHERE kunn2 = lv_kunwe
            AND parvw = 'AG'.
        ENDIF.
      ENDIF.
    ELSE.

      SELECT *
        FROM kna1
        INTO CORRESPONDING FIELDS OF TABLE lt_kna1
        WHERE kunnr = lv_kunnr.
      IF sy-subrc = 0.
        REFRESH lt_kna1.
        SELECT kunnr kunn2
          FROM knvp
          INTO TABLE lt_knvp
         WHERE kunnr = lv_kunnr
          AND parvw = 'WE'.
        IF sy-subrc = 0 AND lt_knvp[] IS NOT INITIAL.
          SELECT kunnr land1 name1
                 ort01 pstlz regio stras
*--> Begin of Insert - SCTASK0867043 - U104997
             pfach
*<-- End of Insert - SCTASK0867043 - U104997
            FROM kna1
            INTO CORRESPONDING FIELDS OF TABLE lt_kna1
            FOR ALL ENTRIES IN lt_knvp
            WHERE kunnr = lt_knvp-kunn2
            AND aufsd EQ space.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lt_kna1[] IS NOT INITIAL.
      LOOP AT lt_kna1 ASSIGNING FIELD-SYMBOL(<ls_kna1>).
        IF <ls_kna1> IS ASSIGNED.
          MOVE-CORRESPONDING <ls_kna1> TO ls_entity.
          READ TABLE lt_knvp ASSIGNING FIELD-SYMBOL(<ls_knvp>) INDEX 1.
          IF sy-subrc = 0.
            ls_entity-kunnr = <ls_kna1>-kunn2.
          ENDIF.
          ls_entity-kunwe = <ls_kna1>-kunnr.
          APPEND ls_entity TO et_entityset.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD soldtoset_get_entity.
****************************************************************************
*Program    : SOLDTOSET_GET_ENTITY                                         *
*Title      : ZCL_ZSRA016_PRICE_AVAI_DPC_EXT~SOLDTOSET_GET_ENTITY          *
*Developer  : Nrupen Polasani                                              *
*Object type: OData Service                                                *
*SAP Release: SAP ECC 6.0                                                  *
*--------------------------------------------------------------------------*
*WRICEF ID: OTC_MDD_0002                                                   *
*--------------------------------------------------------------------------*
****************************************************************************
* Method (SOLDTOSET_GET_ENTITY): This method is used to validate the ship  *
* to partner entered on the screen by the user                             *
*--------------------------------------------------------------------------*
*MODIFICATION HISTORY:
*==========================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ================================*
*06-Dec-2018   U104997       E2DK923449      INITIAL DEVELOPMENT           *
*--------------------------------------------------------------------------*
*05-Sep-2019   U104997       E2DK926561      SCTASK0867043                 *
*                                            Add Po Box to Customer Address*
*--------------------------------------------------------------------------*

    DATA lv_customer TYPE if_bapi_salesorder_getlist2=>bapi1007-customer.
    DATA lo_message_container TYPE REF TO /iwbep/if_message_container.
    FIELD-SYMBOLS <fs_key_tab> TYPE /iwbep/s_mgw_name_value_pair.

    LOOP AT it_key_tab ASSIGNING <fs_key_tab>.
      CASE <fs_key_tab>-name.
        WHEN 'Kunnr'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = <fs_key_tab>-value
            IMPORTING
              output = lv_customer.
      ENDCASE.
    ENDLOOP.
    IF lv_customer IS NOT INITIAL.
      SELECT kunnr land1 name1
             ort01 pstlz regio stras
*--> Begin of Insert - SCTASK0867043 - U104997
             pfach
*<-- End of Insert - SCTASK0867043 - U104997
        FROM kna1
        INTO CORRESPONDING FIELDS OF er_entity
        WHERE kunnr = lv_customer
        AND aufsd EQ space.
      ENDSELECT.
      IF sy-subrc <> 0.
        lo_message_container = me->mo_context->get_message_container( ).

        lo_message_container->add_message(
                   iv_msg_type          = 'E'
                   iv_msg_id            = 'ZOTC_MSG'
                   iv_msg_number        = 308
                   iv_msg_v1            = 'Error'
                   iv_is_leading_message     = abap_true
                   iv_add_to_response_header = abap_true
        ).
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid            = /iwbep/cx_mgw_busi_exception=>business_error
            message_container = lo_message_container.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD soldtoset_get_entityset.
****************************************************************************
*Program    : SOLDTOSET_GET_ENTITYSET                                      *
*Title      : ZCL_ZSRA016_PRICE_AVAI_DPC_EXT~SOLDTOSET_GET_ENTITYSET       *
*Developer  : Nrupen Polasani                                              *
*Object type: OData Service                                                *
*SAP Release: SAP ECC 6.0                                                  *
*--------------------------------------------------------------------------*
*WRICEF ID: OTC_MDD_0002                                                   *
*--------------------------------------------------------------------------*
****************************************************************************
* Method (SOLDTOSET_GET_ENTITYSET): This method is used to all the ship to *
* partners in the system based on users search criteria                    *
*--------------------------------------------------------------------------*
*MODIFICATION HISTORY:
*==========================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ================================*
*06-Dec-2018   U104997       E2DK923449      INITIAL DEVELOPMENT           *
*--------------------------------------------------------------------------*
*05-Sep-2019   U104997       E2DK926561      SCTASK0867043                 *
*                                            Add Po Box to Customer Address*
*--------------------------------------------------------------------------*

    TYPES :

      BEGIN OF ty_knvp,
        kunnr TYPE knvp-kunnr,
        kunn2 TYPE knvp-kunn2,
      END OF ty_knvp.

    DATA:
      lt_filters  TYPE /iwbep/t_mgw_select_option,
      ls_filter   TYPE /iwbep/s_mgw_select_option,
      lv_text     TYPE char45,
      ls_cond_tab TYPE grpcrta_s_condtab,
      lt_cond_tab TYPE grpcrta_t_condtab,
      lv_kunwe    TYPE knvp-kunn2,
      lt_knvp     TYPE STANDARD TABLE OF ty_knvp,
      lt_where    TYPE STANDARD TABLE OF text132,
      lt_soldto   TYPE zcl_zsra016_price_avai_mpc=>tt_soldto,
      es_entity   TYPE zcl_zsra016_price_avai_mpc=>ts_soldto.

    FIELD-SYMBOLS: <ls_filter_select_option> TYPE /iwbep/s_mgw_select_option,
                   <ls_sel_option>           TYPE /iwbep/s_cod_select_option.
* Get filter
    lt_filters = io_tech_request_context->get_filter( )->get_filter_select_options( ).
    READ TABLE it_filter_select_options ASSIGNING <ls_filter_select_option> WITH KEY
      property = 'Kunwe'.
    IF sy-subrc = 0.
      READ TABLE <ls_filter_select_option>-select_options ASSIGNING <ls_sel_option> INDEX 1.
      IF sy-subrc = 0 AND <ls_sel_option>-low IS NOT INITIAL.
        lv_kunwe = <ls_sel_option>-low.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_kunwe
          IMPORTING
            output = lv_kunwe.
      ENDIF.
    ENDIF.
    IF lv_kunwe IS INITIAL.

      IF it_filter_select_options IS NOT INITIAL.

        LOOP AT it_filter_select_options ASSIGNING <ls_filter_select_option>.
          LOOP AT <ls_filter_select_option>-select_options ASSIGNING <ls_sel_option>.
            CASE <ls_filter_select_option>-property.
              WHEN 'Kunnr'.
                IF <ls_sel_option>-low IS NOT INITIAL.
                  ls_cond_tab-field  = 'KUNNR LIKE'.
                  CONCATENATE '%' <ls_sel_option>-low '%' INTO ls_cond_tab-low.
                  APPEND ls_cond_tab TO lt_cond_tab.
                  CLEAR ls_cond_tab.
                ENDIF.
              WHEN 'Pstlz'.
                IF <ls_sel_option>-low IS NOT INITIAL.
                  ls_cond_tab-field  = 'PSTLZ LIKE'.
                  CONCATENATE '%' <ls_sel_option>-low '%' INTO ls_cond_tab-low.
                  APPEND ls_cond_tab TO lt_cond_tab.
                  CLEAR ls_cond_tab.
                ENDIF.
              WHEN 'Land1'.
                IF <ls_sel_option>-low IS NOT INITIAL.
                  ls_cond_tab-field  = 'LAND1 LIKE'.
                  CONCATENATE '%' <ls_sel_option>-low '%' INTO ls_cond_tab-low.
                  APPEND ls_cond_tab TO lt_cond_tab.
                  CLEAR ls_cond_tab.
                ENDIF.
              WHEN 'Name1'.
                IF <ls_sel_option>-low IS NOT INITIAL.
                  MOVE <ls_sel_option>-low TO lv_text.
                  ls_cond_tab-field  = 'MCOD1 LIKE'.
                  TRANSLATE lv_text TO UPPER CASE.
                  CONCATENATE '%' lv_text '%' INTO ls_cond_tab-low.
                  APPEND ls_cond_tab TO lt_cond_tab.
                  CLEAR: ls_cond_tab, lv_text.
                ENDIF.
              WHEN 'Ort01'.
                IF <ls_sel_option>-low IS NOT INITIAL.
                  MOVE <ls_sel_option>-low TO lv_text.
                  ls_cond_tab-field  = 'MCOD3 LIKE'.
                  TRANSLATE lv_text TO UPPER CASE.
                  CONCATENATE '%' lv_text '%' INTO ls_cond_tab-low.
                  APPEND ls_cond_tab TO lt_cond_tab.
                  CLEAR: ls_cond_tab, lv_text.
                ENDIF.
              WHEN 'Regio'.
                IF <ls_sel_option>-low IS NOT INITIAL.
                  ls_cond_tab-field  = 'REGIO LIKE'.
                  CONCATENATE '%' <ls_sel_option>-low '%' INTO ls_cond_tab-low.
                  APPEND ls_cond_tab TO lt_cond_tab.
                  CLEAR ls_cond_tab.
                ENDIF.
              WHEN 'Stras'.
                IF <ls_sel_option>-low IS NOT INITIAL.
                  ls_cond_tab-field  = 'STRAS LIKE'.
                  CONCATENATE '%' <ls_sel_option>-low '%' INTO ls_cond_tab-low.
                  APPEND ls_cond_tab TO lt_cond_tab.
                  CLEAR ls_cond_tab.
                ENDIF.
*--> Begin of Insert - SCTASK0867043 - U104997
              WHEN 'Pfach'.
                IF <ls_sel_option>-low IS NOT INITIAL.
                  ls_cond_tab-field  = 'PFACH LIKE'.
                  CONCATENATE '%' <ls_sel_option>-low '%' INTO ls_cond_tab-low.
                  APPEND ls_cond_tab TO lt_cond_tab.
                  CLEAR ls_cond_tab.
                ENDIF.
*<-- End of Insert - SCTASK0867043 - U104997
              WHEN OTHERS.
                " Log message in the application log
                me->/iwbep/if_sb_dpc_comm_services~log_message(
                  EXPORTING
                    iv_msg_type   = 'E'
                    iv_msg_id     = '/IWBEP/MC_SB_DPC_ADM'
                    iv_msg_number = 021
                    iv_msg_v1     = ls_filter-property ).
                " Raise Exception
                RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
                  EXPORTING
                    textid = /iwbep/cx_mgw_tech_exception=>internal_error.
            ENDCASE.
          ENDLOOP.
        ENDLOOP.
      ENDIF.

      ls_cond_tab-field = 'AUFSD EQ'.
      ls_cond_tab-low = space.
      APPEND ls_cond_tab TO lt_cond_tab.
      CLEAR ls_cond_tab.

      CALL FUNCTION 'GRPCRTA_DYNAMIC_WHERE_BUILD'
        EXPORTING
          dbtable         = space
        TABLES
          condtab         = lt_cond_tab
          where_clause    = lt_where
        EXCEPTIONS
          empty_condtab   = 1
          no_db_field     = 2
          unknown_db      = 3
          wrong_condition = 4
          OTHERS          = 5.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      SELECT kunnr land1 name1
             ort01 pstlz regio stras
*--> Begin of Insert - SCTASK0867043 - U104997
             pfach
*<-- End of Insert - SCTASK0867043 - U104997
        FROM kna1
        INTO CORRESPONDING FIELDS OF TABLE lt_soldto
        WHERE (lt_where).


    ELSE.
      SELECT kunnr kunn2
        FROM knvp
        INTO TABLE lt_knvp
       WHERE kunn2 = lv_kunwe
        AND parvw = 'WE'.
      IF sy-subrc = 0 AND lt_knvp[] IS NOT INITIAL.
        SELECT kunnr land1 name1
               ort01 pstlz regio stras
*--> Begin of Insert - SCTASK0867043 - U104997
             pfach
*<-- End of Insert - SCTASK0867043 - U104997
          FROM kna1
          INTO CORRESPONDING FIELDS OF TABLE lt_soldto
          FOR ALL ENTRIES IN lt_knvp
          WHERE kunnr = lt_knvp-kunnr
          AND aufsd EQ space.
        SORT lt_soldto BY kunnr.
        DELETE ADJACENT DUPLICATES FROM lt_soldto COMPARING kunnr.
      ENDIF.
    ENDIF.
    IF lt_soldto IS NOT INITIAL.
*- Do not show ship to customers, when searching for sold to customers
      DELETE lt_soldto WHERE kunnr CP '0002*'.
      DELETE lt_soldto WHERE kunnr CP '0003*'.
      LOOP AT lt_soldto ASSIGNING FIELD-SYMBOL(<ls_soldto>).
        MOVE-CORRESPONDING <ls_soldto> TO es_entity.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = es_entity-kunnr
          IMPORTING
            output = es_entity-kunnr.
        APPEND es_entity TO et_entityset.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
