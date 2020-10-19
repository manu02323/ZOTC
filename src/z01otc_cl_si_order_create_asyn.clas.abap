class Z01OTC_CL_SI_ORDER_CREATE_ASYN definition
  public
  create public .

public section.

  interfaces Z01OTC_II_SI_ORDER_CREATE_ASYN .

  methods CONSTRUCTOR .
protected section.
private section.
ENDCLASS.



CLASS Z01OTC_CL_SI_ORDER_CREATE_ASYN IMPLEMENTATION.


method CONSTRUCTOR.
************************************************************************
* PROGRAM    :  constructor (Method)                                  *
* TITLE      :  VAWeb to SAP for Service PR creation                  *
* DEVELOPER  :  Mani Rajput                                           *
* OBJECT TYPE:  Enhancement                                           *
* SAP RELEASE:  SAP ECC 6.0                                           *
*---------------------------------------------------------------------*
* WRICEF ID  :  D2_PTP_IDD_0119                                       *
*---------------------------------------------------------------------*
* DESCRIPTION:                                                        *
*  This developemnt involves Service PR creation in SAP with          *
* Validations on input data and FEH for error handling.               *
* the below code is copied from provide class CL_PUR_PURCHASEREQERPMNTRQ
* of standard enterprise sevice PurchaseRequestERPRequest_In
*---------------------------------------------------------------------*
* MODIFICATION HISTORY:                                               *
*=====================================================================*
* DATE            USER     TRANSPORT      DESCRIPTION                 *
* 4th-Sept-2014   MDUGGAL  E2DK902967     INITIAL DEVELOPMENT
* ============ ======= ========== =====================================*
  DATA lref_protocol_payload   TYPE REF TO if_wsprotocol_payload. " XI and WS: Access to Payload
  DATA lref_server_context     TYPE REF TO if_ws_server_context. " Proxy Server Context
  TRY.
      lref_server_context  = cl_proxy_access=>get_server_context( ).
      lref_protocol_payload ?= lref_server_context->get_protocol( protocol_name = if_wsprotocol=>payload ).
      CALL METHOD lref_protocol_payload->set_extended_xml_handling
        EXPORTING
          extended_xml_handling = abap_true.
    CATCH  cx_ai_system_fault.
  ENDTRY.
endmethod.


METHOD z01otc_ii_si_order_create_asyn~si_order_create_async_in.
***********************************************************************
***********************************************************************
***********************************************************************
*Method     : Z01OTC_II_SI_ORDER_CREATE_ASYN~SI_ORDER_CREATE_ASYNC_IN *
*Title      : Create Sales Order Async                                *
*Developer  : Manoj Thatha/ Raghav Sureddi                            *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_IDD_0222_SAP                                          *
*---------------------------------------------------------------------*
*Description: Create Sales Order Async                                *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*05-Dec-2018 Manoj Thatha/  E1DK939532     INITIAL DEVELOPMENT:Create *
*            Raghav Sureddi          Sales Order Async  SCTASK0768763 *
*            Srinivasa G             Sales Order Async  SCTASK0768763 *
* To Determine the Sales Orgs for D3 based on Sold to and Material    *
*---------------------------------------------------------------------*
*05-Apr-2019 ASK /E1DK940993     Defect 9035 Esker order not linking to ZRRC contract
*---------------------------------------------------------------------*
*09-Apr-2019 ASK /E1DK940993     Defect#9046/INC0475526 Esker order   *
*                                Text E-Invoice Reference             *
*---------------------------------------------------------------------*
*09-Sept-2019 U106407/E2DK926602 Defect#10357/INC0504191-03 population*
*                                of Z010 text from ship-to-party      *
*---------------------------------------------------------------------*
*16-Sept-2019 U106407/E2DK926602 Defect#10357/INC0504191-04 populating*
*                                sales order Z010 text as blank is    *
*                                both esker and from ship-to-party's  *
*                                e-invoicing reference is blank       *
*---------------------------------------------------------------------*

  DATA:lref_service_impl               TYPE REF TO  zotccl_order_create. " Asynch Sales Order Create

* Begin of SCTASK0768763
  TYPES : BEGIN OF lty_matnr,
          vkorg TYPE vkorg, " Sales Organization
          matnr TYPE matnr, " Material Number
         END OF lty_matnr.

  DATA :  lref_object      TYPE REF TO zotc_cl_inb_so_edi_850, " Inbound Sales Order EDI 850
          lref_feh         TYPE REF TO zotccl_order_create,    " Asynch Sales Order Create
          lwa_item         TYPE  zotc_850_so_item,             " Sales Order Item for IDD 0009 - 850
          li_item          TYPE  zotc_tt_850_so_item,
          li_matnr         TYPE STANDARD TABLE OF lty_matnr,
          lv_tabix         TYPE sy-tabix,                      " Index of Internal Tables
          lwa_matnr        TYPE lty_matnr,
          li_itemt1        TYPE  zotc_tt_850_so_item,
          li_itemt         TYPE  zotc_tt_850_so_item,
          lv_lines         TYPE  sy-tabix,                     " Index of Internal Tables
          lv_land1         TYPE land1,                         " Country Key
          lv_lrd           TYPE char1,                         " Lrd of type CHAR1
          lv_skip          TYPE char1 .                        " Skip of type CHAR1

  DATA :li_item1  TYPE sapplco_sls_ord_erpcrte_r_tab7,
        li_item2  TYPE sapplco_sls_ord_erpcrte_r_tab7,
        lv_msg_v1 TYPE string, "Message string
        lv_esker  TYPE flag,   " Defect 9035
*Begin of insert for D3_OTC_IDD_0222/Defect# 9046/INC0475526 by ASK on 09-Apr-2019
        lv_esker_einv  TYPE flag, " General Flag
*End of insert for D3_OTC_IDD_0222/Defect# 9046/INC0475526 by ASK on 09-Apr-2019
        lv_vbeln  TYPE vbeln,                          " Sales and Distribution Document Number
        lv_kunnr TYPE kunnr,                           " Customer Number
        lwa_message TYPE bapiret2,                     " Return Parameter
        li_input TYPE sls_sales_order_erpcreate_req1,  " Sales Order ERP Create Request V2
        lwa_item1 TYPE sapplco_sls_ord_erpcrte_req_21, " IDT SalesOrderERPCreateRequest_sync_V2 Item
*-->BEGIN OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-03 ID:D3_OTC_IDD_0222
        li_lines  TYPE STANDARD TABLE OF tline,         " local table for read text
        lw_lines  TYPE tline,                           " local work area for read text
        lv_tdname TYPE tdobname.                        " READ_TEXT key name
*<--END OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-03 ID:D3_OTC_IDD_0222
  CONSTANTS:
       lc_msg_typ          TYPE bapi_mtype           VALUE 'E',        " Message Class
       lc_msg_otc          TYPE symsgid              VALUE 'ZOTC_MSG', " Message Class
       lc_msg_num          TYPE symsgno              VALUE '000',      " Message Number
*-->BEGIN OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-03 ID:D3_OTC_IDD_0222
       lc_id               TYPE tdid                    VALUE 'Z010',  " READ_TEXT id
       lc_object           TYPE tdobject                VALUE 'KNVV',  " READ_TEXT object name
       lc_z010             TYPE sapplco_text_coll_text  VALUE 'Z010',  " Z010 text code
       lc_partype          TYPE sapplco_party_role_code VALUE 'WE'.    " Ship to Party Partner type
*<--END OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-03 ID:D3_OTC_IDD_0222
* End of SCTASK0768763


  CREATE OBJECT: lref_service_impl.
  SET UPDATE TASK LOCAL.

* Business Logic is in the below method.
* New Action Class Method meth_inst_pub_execute is created for Class
* zlexcl_outbound_del_chang and called here
* Begin of SCTASK0768763
  SELECT vbeln "Sales Document
       UP TO 1 ROWS
     FROM vbak "Sales Document: Header Data
     INTO lv_vbeln
    WHERE zzdocref EQ input-sales_order_erpcreate_request-sales_order-z01otc_zdocref1
      AND zzdoctyp EQ input-sales_order_erpcreate_request-sales_order-z01otc_zdoctyp1.
  ENDSELECT.
  IF lv_vbeln IS INITIAL.
* Begin of Defect 9035
    lv_esker = abap_true.
    EXPORT lv_esker FROM lv_esker TO MEMORY ID 'ESKER'.
* End of Defect 9035

*Begin of insert for D3_OTC_IDD_0222/Defect# 9046/INC0475526 by ASK on 09-Apr-2019
    lv_esker_einv = abap_true.
    EXPORT lv_esker_einv  FROM lv_esker_einv  TO MEMORY ID 'ESKER_EINV'.
*End of insert for D3_OTC_IDD_0222/Defect# 9046/INC0475526 by ASK on 09-Apr-2019
    IF input-sales_order_erpcreate_request-sales_order-sales_and_service_business_ar-sales_organisation_id NE 'D3'.
* End of SCTASK0768763
      lref_service_impl->meth_inst_pub_execute( input ).
* Begin of SCTASK0768763
    ELSE. " ELSE -> IF input-sales_order_erpcreate_request-sales_order-sales_and_service_business_ar-sales_organisation_id NE 'D3'
      lv_kunnr = input-sales_order_erpcreate_request-sales_order-buyer_party-internal_id-content.
      li_input = input.
      li_item1[] = li_input-sales_order_erpcreate_request-sales_order-item[].
      CREATE OBJECT lref_object.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lv_kunnr
        IMPORTING
          output = lv_kunnr.

      CALL METHOD lref_object->determine_sold_to_country
        EXPORTING
          im_kunnr_sp = lv_kunnr
        IMPORTING
          ex_land1    = lv_land1
          ex_lrd      = lv_lrd
          ex_skip     = lv_skip.


      LOOP AT li_item1 INTO lwa_item1.
        lwa_item-matnr = lwa_item1-product-internal_id-content.
        APPEND lwa_item TO    li_item.
      ENDLOOP. " LOOP AT li_item1 INTO lwa_item1

*** Check to see if the split logic needs to skipped
      IF lv_skip EQ abap_false.
* LRD Orders
        IF lv_lrd EQ abap_true.
          CALL METHOD lref_object->process_lrd
            EXPORTING
              im_land1                 = lv_land1
            CHANGING
              ch_item                  = li_item
            EXCEPTIONS
              material_class_not_found = 1
              OTHERS                   = 2.
        ELSE. " ELSE -> IF lv_lrd EQ abap_true
* Non LRD Orders
          CALL METHOD lref_object->process_nlrd
            CHANGING
              ch_item                   = li_item
            EXCEPTIONS
              lab_office_not_maintained = 1
              OTHERS                    = 2.
        ENDIF. " IF lv_lrd EQ abap_true
      ENDIF    . " IF lv_skip EQ abap_false
      li_itemt[]  = li_item[].
      li_itemt1[] = li_item[].
      SORT li_itemt BY vkorg.
      SORT li_item  BY vkorg.
      DELETE ADJACENT DUPLICATES FROM li_itemt COMPARING vkorg.

*-->BEGIN OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-03 ID:D3_OTC_IDD_0222

*      Get all the text information from the proxy data
      DATA(li_text) = li_input-sales_order_erpcreate_request-sales_order-text_collection-text.

*      Check if the Z010 text code is present
        READ TABLE li_text INTO DATA(lw_text) WITH KEY type_code-content = lc_Z010. "Max text coming from Esker will be less than 15, Skipping Binary Search
        IF sy-subrc NE 0.

*          Get the ship to party partner
          DATA(li_partner) = li_input-sales_order_erpcreate_request-sales_order-party.
          SORT li_partner BY role_code ASCENDING.
          READ TABLE li_partner INTO DATA(lw_shipparty) WITH KEY role_code = lc_partype BINARY SEARCH.
          IF sy-subrc EQ 0.

*            if data present, then fetch the sales org/dist/div to get the sales text
            DATA(lv_kunnrwe) = lw_shipparty-internal_id-content.
            lw_text-type_code-content = lc_Z010.

            DATA(lv_vkorg) = li_input-sales_order_erpcreate_request-sales_order-sales_and_service_business_ar-sales_organisation_id.
            DATA(lv_vtweg) = li_input-sales_order_erpcreate_request-sales_order-sales_and_service_business_ar-distribution_channel_code-content.
            DATA(lv_spart) = li_input-sales_order_erpcreate_request-sales_order-sales_and_service_business_ar-division_code-content.

*            get the language code
            CALL FUNCTION 'CONVERSION_EXIT_ISOLA_OUTPUT'
              EXPORTING
                INPUT         = sy-langu
              IMPORTING
                OUTPUT        = lw_text-content_text-language_code.

            DATA(lv_set_z010) = abap_true.
          ENDIF.
        ENDIF.
*<--END OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-03 ID:D3_OTC_IDD_0222

      DESCRIBE TABLE li_itemt LINES lv_lines.
      IF lv_lines EQ 1.
        READ TABLE li_itemt INTO lwa_item INDEX 1.
        IF sy-subrc EQ 0.
          li_input-sales_order_erpcreate_request-sales_order-sales_and_service_business_ar-sales_organisation_id = lwa_item-vkorg.
        ENDIF. " IF sy-subrc EQ 0

*-->BEGIN OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-03 ID:D3_OTC_IDD_0222

        IF lv_set_z010 EQ abap_true.

*          Based on the data, get the text
          lv_vkorg = li_input-sales_order_erpcreate_request-sales_order-sales_and_service_business_ar-sales_organisation_id.
          CONCATENATE lv_kunnrwe lv_vkorg lv_vtweg lv_spart INTO lv_tdname.

          CALL FUNCTION 'READ_TEXT'
            EXPORTING
              client                  = sy-mandt
              id                      = lc_id               "Z010
              language                = sy-langu            "System language
              name                    = lv_tdname           "Object Name
              object                  = lc_object           "KNVV
            TABLES
              lines                   = li_lines
            EXCEPTIONS
              id                      = 1
              language                = 2
              name                    = 3
              not_found               = 4
              object                  = 5
              reference_check         = 6
              wrong_access_to_archive = 7
              OTHERS                  = 8.

          IF sy-subrc EQ 0 AND li_lines IS NOT INITIAL.
*            merge the text in one line
            LOOP AT li_lines INTO lw_lines.
              CONCATENATE lw_text-content_text-content lw_lines-tdline INTO lw_text-content_text-content.
              CLEAR : lw_lines.
            ENDLOOP.
            CONDENSE lw_text-content_text-content.
*-->BEGIN OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-04 ID:D3_OTC_IDD_0222
          ENDIF.
*          APPEND blank data against Z010 ID if data is not found using above READ_TEXT
*<--END OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-04 ID:D3_OTC_IDD_0222

*            append the Z010 text to our text list
            APPEND lw_text TO li_text.

*            remove the previous text and replace with the new text table
            CLEAR : li_input-sales_order_erpcreate_request-sales_order-text_collection-text.
            li_input-sales_order_erpcreate_request-sales_order-text_collection-text[] = li_text[].
*-->BEGIN OF DELETE BY U106407 FOR DEFECT#10357/INC0504191-04 ID:D3_OTC_IDD_0222
*          ENDIF.
*<--END OF DELETE BY U106407 FOR DEFECT#10357/INC0504191-04 ID:D3_OTC_IDD_0222
        ENDIF.
        CLEAR:  lw_text,
                lw_lines,
                lv_tdname,
                lv_kunnrwe,
                lv_vkorg,
                lv_vtweg,
                lv_spart,
                lw_shipparty,
                lv_set_z010.

        REFRESH:li_lines,
                li_text,
                li_partner.

*<--END OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-03 ID:D3_OTC_IDD_0222

        lref_service_impl->meth_inst_pub_execute( li_input ).
      ELSE. " ELSE -> IF lv_lines EQ 1
        LOOP AT li_itemt1 INTO lwa_item.
          MOVE-CORRESPONDING lwa_item TO lwa_matnr.
          APPEND lwa_matnr TO li_matnr.
        ENDLOOP. " LOOP AT li_itemt1 INTO lwa_item
        LOOP AT li_matnr INTO lwa_matnr.
          AT NEW vkorg.
            CLEAR li_input.
            li_input = input.
            li_input-sales_order_erpcreate_request-sales_order-sales_and_service_business_ar-sales_organisation_id = lwa_matnr-vkorg.
          ENDAT.

* Read the proxy item table and remove the materials which are not releavent to the pariticular Sales Org.
          READ TABLE  li_item1 INTO lwa_item1 WITH KEY product-internal_id-content = lwa_matnr-matnr.
          IF sy-subrc EQ 0.
            lv_tabix = sy-tabix.
            APPEND lwa_item1 TO li_item2.
            DELETE li_item1 INDEX lv_tabix.
          ENDIF. " IF sy-subrc EQ 0

          AT END OF vkorg.
            CLEAR : li_input-sales_order_erpcreate_request-sales_order-item.
            li_input-sales_order_erpcreate_request-sales_order-item[] = li_item2[].
            CLEAR li_item2[].

*-->BEGIN OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-03 ID:D3_OTC_IDD_0222

            IF lv_set_z010 EQ abap_true.

*              Based on the data, get the text
              lv_vkorg = li_input-sales_order_erpcreate_request-sales_order-sales_and_service_business_ar-sales_organisation_id.
              CONCATENATE lv_kunnrwe lv_vkorg lv_vtweg lv_spart INTO lv_tdname.

              CALL FUNCTION 'READ_TEXT'
                EXPORTING
                  client                  = sy-mandt
                  id                      = lc_id           "Z010
                  language                = sy-langu        "System language
                  name                    = lv_tdname       "Object name
                  object                  = lc_object       "KNVV
                TABLES
                  lines                   = li_lines
                EXCEPTIONS
                  id                      = 1
                  language                = 2
                  name                    = 3
                  not_found               = 4
                  object                  = 5
                  reference_check         = 6
                  wrong_access_to_archive = 7
                  OTHERS                  = 8.

              IF sy-subrc IS INITIAL AND li_lines IS NOT INITIAL.
*                merge the text in one line
                LOOP AT li_lines INTO lw_lines.
                  CONCATENATE lw_text-content_text-content lw_lines-tdline INTO lw_text-content_text-content.
                  CLEAR : lw_lines.
                ENDLOOP.
                CONDENSE lw_text-content_text-content.
*-->BEGIN OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-04 ID:D3_OTC_IDD_0222
              ENDIF.
*             APPEND blank data against Z010 ID if data is not found using above READ_TEXT
*<--END OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-04 ID:D3_OTC_IDD_0222

*                append the Z010 text to our text list
                APPEND lw_text TO li_text.

*                remove the previous text and replace with the new text table
                CLEAR : li_input-sales_order_erpcreate_request-sales_order-text_collection-text.
                li_input-sales_order_erpcreate_request-sales_order-text_collection-text[] = li_text[].
*-->BEGIN OF DELETE BY U106407 FOR DEFECT#10357/INC0504191-04 ID:D3_OTC_IDD_0222
*              ENDIF.
*<--END OF DELETE BY U106407 FOR DEFECT#10357/INC0504191-04 ID:D3_OTC_IDD_0222
            ENDIF.
            CLEAR:  lw_text,
                    lw_lines,
                    lv_tdname,
                    lv_kunnrwe,
                    lv_vkorg,
                    lv_vtweg,
                    lv_spart,
                    lw_shipparty,
                    lv_set_z010.

            REFRESH:li_lines,
                    li_text,
                    li_partner.
*<--END OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-03 ID:D3_OTC_IDD_0222

            lref_service_impl->meth_inst_pub_execute( li_input ).
          ENDAT.
        ENDLOOP. " LOOP AT li_matnr INTO lwa_matnr
      ENDIF. " IF lv_lines EQ 1
    ENDIF. " IF input-sales_order_erpcreate_request-sales_order-sales_and_service_business_ar-sales_organisation_id NE 'D3'

*Begin of insert for D3_OTC_IDD_0222/Defect# 9046/INC0475526 by ASK on 09-Apr-2019
    lv_esker_einv = abap_false.
    EXPORT lv_esker_einv  FROM lv_esker_einv  TO MEMORY ID 'ESKER_EINV'.

   CLEAR lv_esker.
   EXPORT lv_esker FROM lv_esker TO MEMORY ID 'ESKER'.
*End of insert for D3_OTC_IDD_0222/Defect# 9046/INC0475526 by ASK on 09-Apr-2019
  ELSE. " ELSE -> IF lv_vbeln IS INITIAL

*    CREATE OBJECT: lref_feh.
    MESSAGE s000(zotc_msg) WITH " & & & &
          'SO Number'(001)
          lv_vbeln
          'already created'(002)
     INTO lv_msg_v1.

    lwa_message-type   = lc_msg_typ.
    lwa_message-id     = lc_msg_otc.
    lwa_message-number = lc_msg_num.
    lwa_message-message_v1 = lv_msg_v1.
    lref_service_impl->gref_message_container->add_bapi_message( lwa_message ).

    IF lref_service_impl->has_error( ) = abap_true.
      lref_service_impl->gref_message_container->set_err_category( zcacl_message_container=>c_post_err_category ).
      lref_service_impl->feh_prepare( input ).
    ENDIF. " IF lref_service_impl->has_error( ) = abap_true
  ENDIF. " IF lv_vbeln IS INITIAL
* End of SCTASK0768763.

*  Call FEH, if error occurred
  IF lref_service_impl->has_error( ) = abap_true.
    lref_service_impl->feh_execute( ).
  ENDIF. " IF lref_service_impl->has_error( ) = abap_true


ENDMETHOD. "z01otc_ii_si_order_create_asyn~si_order_create_async_in
ENDCLASS.
