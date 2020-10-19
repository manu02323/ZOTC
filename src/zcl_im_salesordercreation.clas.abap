class ZCL_IM_SALESORDERCREATION definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_SLS_APPL_SE_SOERPCRTRC2 .
protected section.
private section.

  type-pools ABAP .
  methods GET_ITEM_CATEGORY
    importing
      value(EX_BILLING_FREQUENCY) type ANY
      value(EX_BILLING_METHOD) type ANY
    exporting
      !IM_ITEM_CATEGORY type PSTYV
    changing
      !CV_FLAG_ERROR type ABAP_BOOL
      !CT_MESSAGE_LOG type BAPIRETTAB .
  methods MAP_ADDRESS_DATA
    importing
      !IM_KUNNR type KUNNR
    changing
      !CT_PARTY_COMV type TDT_PARTY_COMV
      !CT_PARTY_COMX type TDT_PARTY_COMC .
ENDCLASS.



CLASS ZCL_IM_SALESORDERCREATION IMPLEMENTATION.


METHOD get_item_category.
***********************************************************************
***********************************************************************
***********************************************************************
*Method     : IF_SLS_APPL_SE_SOERPCRTRC2~GET_ITEM_CATEGORY            *
*Title      : ES Sales Order Creation                                 *
*Developer  : Jahan Mazumder                                          *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0090 / CR - D2_36                              *
*---------------------------------------------------------------------*
*Description: Determine Item category based input parameters Billing  *
*             Frequency & Billing Method using BRF+ configuration     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:                                                *
*=====================================================================*
*Date           User        Transport       Description               *
*=========== ============== ============== ===========================*
*30-July-2014  JAHAN/MANISH E2DK900476      INITIAL DEVELOPMENT       *
*---------------------------------------------------------------------*

  CONSTANTS:
     lc_name_appl     TYPE string     VALUE 'ZA_OTC_IDD_0090_ITEM_CATEGORY',
     lc_name_func     TYPE string     VALUE 'ZF_OTC_IDD_0090_ITEM_CATEGORY',
     lc_msg_typ       TYPE bapi_mtype VALUE 'E',        " Message Class
     lc_msg_otc       TYPE symsgid    VALUE 'ZOTC_MSG', " Message Class
     lc_msg_num       TYPE symsgno    VALUE '159'.      " Message Number

  DATA:
   lwa_message      TYPE bapiret2,                 " Bapi return.
   lo_admin_data    TYPE REF TO if_fdt_admin_data, " FDT: Administrative Data
   lo_function      TYPE REF TO if_fdt_function,   " FDT: Function
   lo_context       TYPE REF TO if_fdt_context,    " FDT: Context
   lo_result        TYPE REF TO if_fdt_result,     " FDT: Result
   lo_util          TYPE REF TO /bofu/cl_fdt_util, " BRFplus Utilities
   lx_fdt           TYPE REF TO cx_fdt,            " FDT: Abstract Exception Class
   lv_msg_v         TYPE string,                   " Message string
   lv_query_in      TYPE string,
   lv_query_out     TYPE if_fdt_types=>id.

*-- Get GUID value of Function
  lo_util ?= /bofu/cl_fdt_util=>get_instance( ).
  CONCATENATE lc_name_appl lc_name_func
         INTO lv_query_in
         SEPARATED BY '.'.
  CALL METHOD lo_util->convert_function_input
    EXPORTING
      iv_input  = lv_query_in
    IMPORTING
      ev_output = lv_query_out
    EXCEPTIONS
      failed    = 1
      OTHERS    = 2.


*-- Set the variable value(s)
  cl_fdt_factory=>get_instance_generic( EXPORTING iv_id = lv_query_out
                                        IMPORTING eo_instance = lo_admin_data ).
  lo_function ?= lo_admin_data.
  lo_context ?= lo_function->get_process_context( ).
  lo_context->set_value( iv_name = 'BILLING_METHOD'    ia_value = ex_billing_method ).
  lo_context->set_value( iv_name = 'BILLING_FREQUENCY' ia_value = ex_billing_frequency ).

  TRY.
      lo_function->process( EXPORTING io_context = lo_context
                            IMPORTING eo_result = lo_result ).
      lo_result->get_value( IMPORTING ea_value = im_item_category ).
    CATCH cx_fdt INTO lx_fdt.
  ENDTRY.

  IF im_item_category IS INITIAL.

    lwa_message-type       = lc_msg_typ.
    lwa_message-id         = lc_msg_otc.
    lwa_message-number     = lc_msg_num.
    lwa_message-message_v1 = ex_billing_method.
    lwa_message-message_v2 = ex_billing_frequency.
    APPEND lwa_message TO ct_message_log.

*--Set error flag to terminate Sales Order creation process
    cv_flag_error = abap_true.

  ENDIF. " IF im_item_category IS INITIAL

ENDMETHOD.


METHOD if_sls_appl_se_soerpcrtrc2~inbound_processing.
***********************************************************************
***********************************************************************
***********************************************************************
*Method     : IF_SLS_APPL_SE_SOERPCRTRC2~INBOUND_PROCESSING           *
*Title      : ES Sales Order Creation                                 *
*Developer  : Jahan Mazumder                                          *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0090                                           *
*---------------------------------------------------------------------*
*Description: Create Sales Order in SAP using ESR Service Interface   *
*Create Request Confirmation_In V2                                    *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:                                                *
*=====================================================================*
*Date           User        Transport       Description               *
*=========== ============== ============== ===========================*
*21-May-2014  RACHAR        E2DK900476      INITIAL DEVELOPMENT       *
*06-Jun-2014  JAHAN         E2DK900476      INITIAL DEVELOPMENT       *
*30-Jul-2014  JAHAN         E2DK900476      CR D2_36                  *
*                                           Determine Item Catagory   *
*05-Aug-2014  PBOSE         E2DK900476      Populate Billing Plan Type*
*                                           for OTC_EDD-0179          *
*30-Oct-2014  JAHAN         E2DK904476      D2_CR_9, CR_20, CR_127    *
*                                           CR_137, CR_159            *
*19-Oct-2014  JAHAN         E2DK904476      Defect # 987 Shipping Cond*
*                                           override                  *
*18-Nov-2014  JAHAN         E2DK904476      Defect # 1763 Serial no.  *
*                                           validation failing        *
*30-Mar-2015  MBAGDA        E2DK911715      CR D2_541 Populate Billing*
*                                           Frequency & Billing Method*
*12-Feb-2016  SAGARWA1      E2DK916942      Defect#1485: Add logic for*
*                                           free goods with item usage*
*14-Feb-2018  BGUNDAB       E1DK934125      Changes for D3:R3 add     *
*                                           service rendered date plus*
*                                           dft # 4537 is included    *
*26-Nov-2018  U033876       E1DK939532     SCTASK0768763 Add attachment*
*                                           to the sales order GOS   *
*                                        object and add created by logic*
*07-May-2019  U103061       E2DK923819      Defect# 9394: Web Order   *
*                                           failed due to No          *
*                                           jurisdiction code could be*
*                                           determined                *
*29-July-2019 U105235       E2DK925588   SCTASK0855341 Cityname,country*
*                                        field values population for  *
*                                        contact person during sales  *
*                                        Order creation               *
*---------------------------------------------------------------------*
*15-August-2019 ASK       E2DK925588    Defect 10243 Wrong Ship to Party *
*                                        address issue fix            *
*29-Aug-2019  U105235     E2DK926286    SCTASK0835733 incoterms field *
*                                        mapping from the ESKER file  *
*---------------------------------------------------------------------*
*17-Sep-2019  U106407     E2DK926602    DEFECT#10357/INC0504191-04    *
*                                       populating Z010 text as blank *
*                                       if ship-to-party and esker's  *
*                                       e-invoicng reference is blank *
*---------------------------------------------------------------------*

*--Local Data declarations
  CONSTANTS :
    lc_null         TYPE z_criteria           VALUE 'NULL',                " Enh. Criteria
    lc_idd_0090     TYPE z_enhancement        VALUE 'D2_OTC_IDD_0090',     " Enhancement No.
    lc_idd_0090_001 TYPE z_enhancement        VALUE 'D2_OTC_IDD_0090_001', " Enhancement No.
    lc_msg_typ      TYPE bapi_mtype           VALUE 'E',                   " Message Class
    lc_msg_typ_i    TYPE bapi_mtype           VALUE 'I',                   " Message Class
    lc_msg_typ_w    TYPE bapi_mtype           VALUE 'W',                   " Message Class
    lc_msg_otc      TYPE symsgid              VALUE 'ZOTC_MSG',            " Message Class
    lc_msg_num      TYPE symsgno              VALUE '000',                 " Message Number
    lc_msg_num1     TYPE symsgno              VALUE '136',                 " Message Number
    lc_ap           TYPE parvw                VALUE 'AP',                  " Partner Function
    lc_we           TYPE parvw                VALUE 'WE',                  " Partner Function
    lc_zb           TYPE parvw                VALUE 'ZB',                  " Partner Function
    lc_000000       TYPE posnr                VALUE '000000',              " Item number of the SD document
*    lc_source_evo       TYPE z_doctyp             VALUE '01',                  " Source System- 01:eVo
    lc_source_smax  TYPE z_doctyp             VALUE '02',           " Source System- 02:ServiceMax
    lc_underscr     TYPE char1                VALUE '_',            "Underscr of type CHAR1
    lc_sales_office TYPE char12               VALUE 'SALES_OFFICE', " Sales_office of type CHAR12
    lc_memory_id    TYPE char15               VALUE 'SERIAL_NO',    " Memory ID for each item
*& --> Begin of Insert for Defect#1485 by SAGARWA1
    lc_content      TYPE z_criteria           VALUE 'CONTENT', " Criteria value for EMI entry for Proxy Datenelement (generiert)
    lc_vwpos        TYPE z_criteria           VALUE 'VWPOS',   " Criteria value for EMI entry for Item Usage
*& --> End of Insert for Defect#1485 by SAGARWA1
*-->BEGIN OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-04 ID:D3_OTC_IDD_0222
    lc_z010         TYPE tdid                 VALUE 'Z010'.    " Z010 text ID
*<--END OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-04 ID:D3_OTC_IDD_0222
  TYPES:
*       BEGIN OF lty_vbeln,  "decleration commented as part of SCI Checks
*           matnr TYPE matnr, "Material No
*           vbeln TYPE vbeln, "Document no
*         END OF lty_vbeln,

    BEGIN OF lty_sernr,
      sernr TYPE gernr, "Serial No
    END OF lty_sernr,

*& --> Begin of Insert for Defect#1485 by SAGARWA1
    BEGIN OF lty_mtpos,
      matnr      TYPE matnr,           " Material Number
      mtpos_mara TYPE mtpos_mara, " General item category group
    END OF lty_mtpos,

    BEGIN OF lty_matnr,
      matnr TYPE matnr,           " Material Number
    END OF lty_matnr,

    BEGIN OF lty_t184,
      auart TYPE auart,           " Sales Document Type
      mtpos TYPE mtpos,           " Item category group from material master
      vwpos TYPE vwpos,           " Item usage
      uepst TYPE uepst,           " Item category of the higher-level item
      pstyv TYPE pstyv,           " Sales document item category
    END OF lty_t184.
*& --> End of Insert for Defect#1485 by SAGARWA1

  DATA: lwa_output_item    TYPE sapplco_log_item,                  "##NEEDED         "Protocol message issued by an application
        lwa_message        TYPE bapiret2,                          "Bapi return.
        li_serial_msg      TYPE bapirettab,                        "Table with messsgae from serial validation FM
        li_matser          TYPE zotc_t_matnr_sernr,                "Table with Material,serial combination
        lwa_matser         TYPE zotc_matnr_sernr_s,                "Material Serial Number Combination structure
        li_batch_msg       TYPE bapirettab,                        "Table with messsgae from Batch validation FM
        li_matbatch_quan   TYPE zotc_t_matbatch_quan,              "Table with Material, Batch and quantity combination
        lwa_matbatch_quan  TYPE zotc_matbatch_quan_s,              "Structure for Material,Batch and Requested quantity
        lwa_status_pstyv   TYPE zdev_enh_status,                   "Work area for enhnacment status
        lv_vbeln           TYPE vbeln,                             "Sales Order Number
        lv_note            TYPE sapplco_log_item_note,             "A short text for the log message
        li_item            TYPE tdt_item_comv,                     "Item local internal Table
        li_status          TYPE STANDARD TABLE OF zdev_enh_status, "Enhancement Status table
        li_status_pstyv    TYPE STANDARD TABLE OF zdev_enh_status, "Enhancement Status table- Item Category
        li_contract_data   TYPE zotc_t_reagent_rental,             "Table  for Re-agent rental contracts data
        li_matnr           TYPE table_matnr,                       "Material Number
        li_st_prefix_tab   TYPE sapplco_languageindependen_tab,    "Table to get Street 2
        wa_st_prefix_tab   TYPE sapplco_languageindependent_me,    "Table to get Street 2
        li_serial_no       TYPE STANDARD TABLE OF lty_sernr,
        lv_msg_v0          TYPE string,                            "Message string
        lv_msg_v1          TYPE string,                            "Message string
        lv_msg_v2          TYPE string,                            "Message string
        lv_index           TYPE sytabix,                           " Index of Internal Tables
        lv_vkorg           TYPE vkorg,                             " Sales Organization
        lv_vtweg           TYPE vtweg,                             " Distribution Channel
        lv_spart           TYPE spart,                             " Division
        lv_kunag           TYPE kunag,                             " Sold-to party
        lv_kunwe           TYPE kunwe,                             " Ship-to party
*       lv_fldname        TYPE char20,                            " Fldname of type CHAR20
        lv_date            TYPE char8,   " Date of type CHAR8
        lv_month           TYPE char2,   " Month of type CHAR2
        lv_year            TYPE char4,   " Year of type CHAR4
        lv_contract_count  TYPE int4,    " Contract_count of type Integers
        lv_add_flag        TYPE char1,   " Adress change flag
        lv_pstyv           TYPE pstyv,   " Item Category
        lv_charg           TYPE charg_d, " Batch Number
        lv_sales_office    TYPE char17,  " Sales Office
        lv_memory_id       TYPE char15,  " Memory ID for each item
        lv_vsbed           TYPE vsbed,   " Defect # 987
*& --> Begin of Insert for Defect#1485 by SAGARWA1
        li_t184            TYPE STANDARD TABLE OF lty_t184  INITIAL SIZE 0, " Table for T184
        li_mtpos           TYPE STANDARD TABLE OF lty_mtpos INITIAL SIZE 0, " Table for MARA
        li_mtpos_tmp       TYPE STANDARD TABLE OF lty_mtpos INITIAL SIZE 0, " Temporary table for MARA
        li_matnr1          TYPE STANDARD TABLE OF lty_matnr INITIAL SIZE 0, " Temporary table for material numbers
        lwa_status         TYPE zdev_enh_status,                            " Structure for EMI entry
        lwa_matnr          TYPE lty_matnr,                                  " Structure for material number
        li_price_component TYPE sapplco_sls_ord_erpcrte_r_tab8,            " Table containing price component
        lv_content         TYPE sapplco_price_specification_el,             " Proxy Datenelement (generiert)
        lv_vwpos           TYPE vwpos,                                      " Item Usage
        lv_price_flag      TYPE flag,                                       " Flag for pricing type
        lwa_telephone      TYPE sapplco_telephone,                          " Telephone work area SCTASK0855341
        lv_auart           TYPE auart,                                      " Order Type
*& --> End of Insert for Defect#1485 by SAGARWA1
*-->BEGIN OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-04 ID:D3_OTC_IDD_0222
        lv_esker_einv      TYPE flag.                                       " flag for order creation from ESKER
*<--END OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-04 ID:D3_OTC_IDD_0222

**--Local data declaration for address change.                "decleration commented as part of SCI Checks
*  DATA : "li_address_keys TYPE STANDARD TABLE OF addr_key, " Structure with reference key fields and address type
*         li_adrc         TYPE TABLE OF vadrc,             " Addresses (Business Address Services)
*         li_adrct        TYPE TABLE OF vadrct,            " Address Texts (Business Address Services)
*         li_adr2         TYPE TABLE OF vadr2,             " Telephone Numbers (Business Address Services)
*         li_adr3         TYPE TABLE OF vadr3,             " Fax Numbers (Business Address Services)
*         li_adr4         TYPE TABLE OF vadr4,             " Teletex Numbers (Business Address Services)
*         li_adr5         TYPE TABLE OF vadr5,             " Telex Numbers (Business Address Services)
*         li_adr6         TYPE TABLE OF vadr6,             " E-Mail Addresses (Business Address Services)
*         li_adr7         TYPE TABLE OF vadr7,             " Remote Mail Addresses (SAP - SAP - Communication; BAS)
*         li_adr8         TYPE TABLE OF vadr8,             " X.400 Numbers (Business Address Services)
*         li_adr9         TYPE TABLE OF vadr9,             " RFC Destinations (Business Address Services)
*         li_adr10        TYPE TABLE OF vadr10,            " Printer (Business Address Services)
*         li_adr11        TYPE TABLE OF vadr11,            " SSF (Business Address Services)
*         li_adr12        TYPE TABLE OF vadr12,            " FTP and URL (Business Address Services)
*         li_adr13        TYPE TABLE OF vadr13,            " Pager (Business Address Services)
*         li_adrt         TYPE TABLE OF adrt.              " Communication Data Text (Business Address Services)

  FIELD-SYMBOLS:
*        <lfs_vbeln>           TYPE lty_vbeln,              "decleration commented as part of SCI Checks
    <lfs_item>            TYPE tds_item_comv,                  "Lean Order - Item Data (Values)
    <lfs_tds_item_comv>   TYPE tds_item_comv,                  " Lean Order - Item Data (Values)
    <lfs_tds_item_comx>   TYPE tds_item_comc,                  " Lean Order - Item Data (Values)
    <lfs_contract>        TYPE zotc_reagent_rental_s,          "Output strcuture for Re-agent rental contracts determination
    <lfs_input_item>      TYPE sapplco_sls_ord_erpcrte_req_21, " IDT SalesOrderERPCreateRequest_sync_V2 Item
    <lfs_party_comv>      TYPE tds_party_comv,                 " Lean Order - Partner Data (Values)
    <lfs_party_comx>      TYPE tds_party_comc,                 " Lean Order - Partner Data (CHAR)
    <lfs_input_party>     TYPE sapplco_sls_ord_erpcrte_req_14, " IDT SalesOrderERPCreateRequest_sync_V2 Party
*        <lfs_party_street>    TYPE sapplco_address,                " Proxy Structure (Generated) "decleration commented as part of SCI Checks
    <lfs_email>           TYPE sapplco_email, " Proxy Structure (Generated)
* Begin of Change for attachments in FEH retry
    <lfs_fax>             TYPE sapplco_facsimile,              " Fax
    <lfs_subs_id>         TYPE sapplco_phone_number_subscr_id, " Proxy Data Element (Generated)
* End of change for attachments in FEH retry
    <lfs_status>          TYPE zdev_enh_status, " Enhancement Status
*        <lfs_street2>         TYPE sapplco_languageindependent_me, " Get data for Street 2 from Table "decleration commented as part of SCI Checks
    <lfs_serial>          TYPE lty_sernr, "Serial no's structure
*& --> Begin of Insert for Defect#1485 by SAGARWA1
    <lfs_mtpos>           TYPE lty_mtpos,                      " Mara structure
    <lfs_price_component> TYPE sapplco_sls_ord_erpcrte_req_28, " Structure for Price component
    <lfs_t184>            TYPE lty_t184,                       " T184 structure
*& --> End of Insert for Defect#1485 by SAGARWA1

*&--> Begin of Change for D3_OTC_IDD_0090_Defect# 9394 by U103061 on 07-May-2019
    <lfs_ct_party_comx>   TYPE tds_party_comc,
*&<-- End of Change for D3_OTC_IDD_0090_Defect# 9394 by U103061 on 07-May-2019
*-->BEGIN OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-04 ID:D3_OTC_IDD_0222
    <lfs_text_comx>       TYPE tds_text_comc,                 "FS for text ID table
    <lfs_text_comv>       TYPE tds_text_comv.                 "FS for text ID update table
*<--END OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-04 ID:D3_OTC_IDD_0222

  DATA  : lv_ship TYPE flag,
          lv_inco TYPE flag.

*-->BEGIN OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-04 ID:D3_OTC_IDD_0222
* get the ESKER_EINV flag from Z01OTC_CL_SI_ORDER_CREATE_ASYNZ01OTC_II_SI_ORDER_CREATE_ASYN~SI_ORDER_CREATE_ASYNC_IN
  IMPORT lv_esker_einv TO lv_esker_einv FROM MEMORY ID 'ESKER_EINV'.

* For ESKER Invoice if Z010 text is coming as BLANK, then pass the same by changing CT_TEXT_COMX table
  IF lv_esker_einv = abap_true.

*    check if Z010 text value is present (no BINARY SEARCH necessary as no. of text ids are limited to < 15)
    READ TABLE ct_text_comv ASSIGNING <lfs_text_comv> WITH KEY ID = lc_z010.

*    Check if the text maintained is BLANK
    IF sy-subrc EQ 0 AND <lfs_text_comv>-text_string IS INITIAL.

*      get the corresponding update check character (no BINARY SEARCH necessary as no. of text ids are limited to < 15)
      READ TABLE ct_text_comx ASSIGNING <lfs_text_comx> INDEX sy-tabix.
      IF sy-subrc EQ 0.
        <lfs_text_comx>-text_string = abap_true.
      ENDIF.
    ENDIF.
    IF <lfs_text_comx> IS ASSIGNED.
      UNASSIGN: <lfs_text_comx>.
    ENDIF.
    IF <lfs_text_comx> IS ASSIGNED.
      UNASSIGN: <lfs_text_comv>.
    ENDIF.
  ENDIF.
  CLEAR lv_esker_einv.
*<--END OF INSERT BY U106407 FOR DEFECT#10357/INC0504191-04 ID:D3_OTC_IDD_0222

*--Call to EMI Function Module To Get List Of EMI Statuses
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_idd_0090
    TABLES
      tt_enh_status     = li_status.

*--Check for Global user exit activation check
  READ TABLE li_status WITH KEY criteria = lc_null
                                active = abap_true
                       TRANSPORTING NO FIELDS.
  IF sy-subrc EQ  0.
*--If EMI_ACTIVE then excute the enhancement
*--and validate each item for multiple contracts

* Begin of comment for Defect 10243 as this is causing wrong Ship to Party address
* update in Sales Order
*&--> Begin of Change for D3_OTC_IDD_0090_Defect# 9394 by U103061 on 07-May-2019
**   Logic implemented as per SAP Message: 292962/ 2018
*    READ TABLE ct_party_comx ASSIGNING <lfs_ct_party_comx> INDEX 1.
*    IF sy-subrc IS INITIAL.
*      IF <lfs_ct_party_comx>-city2 IS INITIAL.
*        <lfs_ct_party_comx>-city2 = abap_true.
*      ENDIF.
*    ENDIF.
**&<-- End of Change for D3_OTC_IDD_0090_Defect# 9394 by U103061 on 07-May-2019
* End of comment for Defect 10243

*--Start of CR D2_36
*--Call to EMI Function Module To Get List Of EMI Statuses for Item Category check
    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
      EXPORTING
        iv_enhancement_no = lc_idd_0090_001
      TABLES
        tt_enh_status     = li_status_pstyv.
*--Check for Global user exit activation check
    CLEAR : lwa_status_pstyv.
    READ TABLE li_status_pstyv INTO lwa_status_pstyv
                               WITH KEY criteria = lc_null
                                        active   = abap_true.
    IF sy-subrc EQ 0.
    ENDIF. " IF sy-subrc EQ 0
*--End of CR D2_36

*-- Local field: Sales org
    IF cs_head_comv-vkorg IS INITIAL.
      lv_vkorg = is_input-sales_order_erpcreate_request-sales_order-sales_and_service_business_ar-sales_organisation_id.
    ENDIF. " IF cs_head_comv-vkorg IS INITIAL

    IF cs_head_comv-vtweg IS INITIAL.
      lv_vtweg = is_input-sales_order_erpcreate_request-sales_order-sales_and_service_business_ar-distribution_channel_code-content.
    ENDIF. " IF cs_head_comv-vtweg IS INITIAL

    IF cs_head_comv-spart IS INITIAL.
      lv_spart = is_input-sales_order_erpcreate_request-sales_order-sales_and_service_business_ar-division_code-content.
    ENDIF. " IF cs_head_comv-spart IS INITIAL

    IF cs_head_comv-kunag IS INITIAL.
      lv_kunag = is_input-sales_order_erpcreate_request-sales_order-buyer_party-internal_id-content.
    ENDIF. " IF cs_head_comv-kunag IS INITIAL

    IF cs_head_comv-kunwe IS INITIAL.
      READ TABLE ct_party_comv ASSIGNING <lfs_party_comv> WITH KEY parvw = lc_we
                                                                   cntpa = lc_000000.
      IF sy-subrc = 0.
        lv_kunwe = <lfs_party_comv>-kunnr.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF cs_head_comv-kunwe IS INITIAL

*--Start of D2_CR_159
*--Update Sales office based on Sales Org.
    CONCATENATE lc_sales_office is_input-sales_order_erpcreate_request-sales_order-sales_and_service_business_ar-sales_organisation_id
           INTO lv_sales_office SEPARATED BY lc_underscr .

    READ TABLE li_status  ASSIGNING <lfs_status>  WITH KEY criteria = lv_sales_office
                                                           active = abap_true.
    IF sy-subrc EQ 0.
      IF is_input-sales_order_erpcreate_request-sales_order-sales_and_service_business_ar-sales_organisation_id IS NOT INITIAL.
        cs_head_comv-vkbur  = <lfs_status>-sel_low.
        cs_head_comx-vkbur  = 'X'.
      ENDIF. " IF is_input-sales_order_erpcreate_request-sales_order-sales_and_service_business_ar-sales_organisation_id IS NOT INITIAL
    ENDIF. " IF sy-subrc EQ 0
*--End of D2_CR_159

*--Fill the Ztable fields from the input structure
    IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zdocref1 IS NOT INITIAL.
      cs_head_comv-zzdocref  = is_input-sales_order_erpcreate_request-sales_order-z01otc_zdocref1.
      cs_head_comx-zzdocref  = 'X'.
    ENDIF. " IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zdocref1 IS NOT INITIAL

    IF  is_input-sales_order_erpcreate_request-sales_order-z01otc_zdoctyp1 IS NOT INITIAL.
      cs_head_comv-zzdoctyp  = is_input-sales_order_erpcreate_request-sales_order-z01otc_zdoctyp1.
      cs_head_comx-zzdoctyp  = 'X'.
    ENDIF. " IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zdoctyp1 IS NOT INITIAL

*-- Field: Case Reference Number
    IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-caseref IS NOT INITIAL.
      cs_head_comv-zzcaseref = is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-caseref.
      cs_head_comx-zzcaseref = 'X'.
    ENDIF. " IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-caseref IS NOT INITIAL

*-- Field: Your Reference Number
    IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-your_reference IS NOT INITIAL.
      cs_head_comv-zzihrez = is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-your_reference.
      cs_head_comx-zzihrez = 'X'.
    ENDIF. " IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-your_reference IS NOT INITIAL

*---> Begin of changes for D3:R3 by bgundab
* Service Rendered Date
    IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-zfbuda IS NOT INITIAL.
      cs_head_comv-zfbuda  = is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-zfbuda.
      cs_head_comx-zfbuda  = 'X'.
    ENDIF. " IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-zfbuda IS NOT INITIAL
*---> End of changes for D3:R3 by bgundab

*--Payment deatils : credit card type
    IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zpayment_terms-type_code IS NOT INITIAL.
      cs_head_comv-ccins = is_input-sales_order_erpcreate_request-sales_order-z01otc_zpayment_terms-type_code.
      cs_head_comx-ccins = 'X'.
    ENDIF. " IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zpayment_terms-type_code IS NOT INITIAL


*--Begin of changes for OTC_IDD_0222 by U033876- SCTASK0768763
    IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-created_by IS NOT INITIAL.
      cs_head_comv-zernam = is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-created_by.
      cs_head_comx-zernam = 'X'.
    ELSE. " ELSE -> IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-created_by IS NOT INITIAL
      cs_head_comv-zernam = sy-uname.
      cs_head_comx-zernam = 'X'.
    ENDIF. " IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-created_by IS NOT INITIAL
*--End of changes for OTC_IDD_0222 by U033876- SCTASK0768763
*--Payment deatils : credit card number
    IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zpayment_terms-type_code IS NOT INITIAL.
      cs_head_comv-ccnum = is_input-sales_order_erpcreate_request-sales_order-z01otc_zpayment_terms-id-content.
      cs_head_comx-ccnum = 'X'.
    ENDIF. " IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zpayment_terms-type_code IS NOT INITIAL

*--Payment deatils : credit card expiration date - format it into MMYYYY.
    IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zpayment_terms-type_code IS NOT INITIAL.
      lv_date = is_input-sales_order_erpcreate_request-sales_order-z01otc_zpayment_terms-expiration_date.
      lv_year = lv_date+0(4).
      lv_month = lv_date+4(2).
      CLEAR lv_date.
      CONCATENATE lv_month lv_year INTO lv_date.
      cs_head_comv-ccdatbi = lv_date.
      cs_head_comx-ccdatbi = 'X'.
    ENDIF. " IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zpayment_terms-type_code IS NOT INITIAL

*--Payment deatils : credit card holder name
    IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zpayment_terms-holder-content IS NOT INITIAL.
      cs_head_comv-ccname = is_input-sales_order_erpcreate_request-sales_order-z01otc_zpayment_terms-holder-content.
      cs_head_comx-ccname = 'X'.
    ENDIF. " IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zpayment_terms-holder-content IS NOT INITIAL

*--Payment deatils : Credit card CVV value - Sequence ID
    IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zpayment_terms-sequence_id IS NOT INITIAL.
      cs_head_comv-cvval = is_input-sales_order_erpcreate_request-sales_order-z01otc_zpayment_terms-sequence_id.
      cs_head_comx-cvval = 'X'.
    ENDIF. " IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zpayment_terms-sequence_id IS NOT INITIAL
*--Start of D2_CR_127
*--Shipping Condition
    IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-shipping_condition IS NOT INITIAL.
*Begin of code changes - SCTASK0835733 - U105235 - 29-Aug-2019
      lv_ship = 'X'.
      EXPORT lv_ship  FROM lv_ship  TO MEMORY ID 'SHIP'.
*End of code changes - SCTASK0835733 - U105235 - 29-Aug-2019
      cs_head_comv-vsbed = is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-shipping_condition.
      cs_head_comx-vsbed = 'X'.
      "Exporting the shipping cond to User Exit EXIT_MOVE_FIELD_TO_VBAK in include MV45AFZZ
      lv_vsbed = is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-shipping_condition.
      EXPORT lv_vsbed_t FROM lv_vsbed TO MEMORY ID 'IDD_90_VSBED'. " Defect # 987
    ENDIF. " IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-shipping_condition IS NOT INITIAL
*--End of D2_CR_127


*Begin of code changes - SCTASK0835733 - U105235 - 29-Aug-2019
*mapping the incoterms field coming from ESKER file
    IF is_input-sales_order_erpcreate_request-sales_order-delivery_terms-incoterms-classification_code IS NOT INITIAL.
      lv_inco = 'X'.
      EXPORT lv_inco  FROM lv_inco  TO MEMORY ID 'INCO'.
      cs_head_comv-inco1 = is_input-sales_order_erpcreate_request-sales_order-delivery_terms-incoterms-classification_code.
      cs_head_comx-inco1 = abap_true.
    ENDIF.
*End of code changes - SCTASK0835733 - U105235 - 29-Aug-2019

*& --> Begin of Insert for Defect#1485 by SAGARWA1
*    Get the Sales Document Type

    IF is_input-sales_order_erpcreate_request-sales_order-processing_type_code IS NOT INITIAL.
      lv_auart = is_input-sales_order_erpcreate_request-sales_order-processing_type_code.
    ENDIF. " IF is_input-sales_order_erpcreate_request-sales_order-processing_type_code IS NOT INITIAL

*--Moving item data into a local table.
    li_item[] = ct_item_comv[].
    IF li_item[] IS NOT INITIAL.
      SORT li_item BY mabnr.
      DELETE ADJACENT DUPLICATES FROM li_item COMPARING mabnr.
*--Moving only unique material no. to a Internal table.
      LOOP AT li_item ASSIGNING <lfs_item>.
        lwa_matnr-matnr = <lfs_item>-mabnr.
        APPEND lwa_matnr TO li_matnr1.
      ENDLOOP. " LOOP AT li_item ASSIGNING <lfs_item>
    ENDIF. " IF li_item[] IS NOT INITIAL

    IF li_matnr1 IS NOT INITIAL.
      SELECT     matnr " Material Number
                 mtpos " Item category group from material master
        INTO TABLE li_mtpos
        FROM mvke      " Sales Data for Material
        FOR ALL ENTRIES IN li_matnr1
        WHERE matnr = li_matnr1-matnr
        AND   vkorg = lv_vkorg
        AND   vtweg = lv_vtweg.
      IF sy-subrc IS INITIAL AND li_mtpos[] IS NOT INITIAL.
        SORT li_mtpos BY matnr.
        li_mtpos_tmp[] = li_mtpos[].
        SORT li_mtpos_tmp BY mtpos_mara.
        DELETE ADJACENT DUPLICATES FROM li_mtpos_tmp  COMPARING mtpos_mara.
        IF li_mtpos_tmp[] IS NOT INITIAL.
          READ TABLE li_status INTO lwa_status WITH KEY criteria = lc_vwpos
                                                        active   = abap_true.
          IF sy-subrc = 0.
            lv_vwpos = lwa_status-sel_low.
          ENDIF. " IF sy-subrc = 0
          SELECT        auart " Sales Document Type
                        mtpos " Item category group from material master
                        vwpos " Item usage
                        uepst " Item category of the higher-level item
                        pstyv " Default item category for the document
            FROM t184         " Sales Documents: Item Category Determination
            INTO  TABLE li_t184
            FOR ALL ENTRIES IN li_mtpos_tmp
            WHERE auart = lv_auart
            AND   mtpos = li_mtpos_tmp-mtpos_mara
            AND vwpos = lv_vwpos
            AND uepst = space.
          IF sy-subrc = 0 .
            SORT li_t184 BY mtpos.
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF li_mtpos_tmp[] IS NOT INITIAL
      ENDIF. " IF sy-subrc IS INITIAL AND li_mtpos[] IS NOT INITIAL
      CLEAR: li_item[], li_matnr1[].
    ENDIF. " IF li_matnr1 IS NOT INITIAL
*& --> End of Insert for Defect#1485 by SAGARWA1

*--- Item data handling
    LOOP AT ct_item_comv ASSIGNING <lfs_tds_item_comv>.
      lv_index = sy-tabix.
      READ TABLE is_input-sales_order_erpcreate_request-sales_order-item ASSIGNING <lfs_input_item> INDEX lv_index.

      IF sy-subrc = 0.
        READ TABLE ct_item_comx ASSIGNING <lfs_tds_item_comx> INDEX lv_index.
        IF sy-subrc = 0.
*--Begin of changes for OTC_IDD_0222 by U033876- SCTASK0768763
          IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-created_by IS NOT INITIAL.
            <lfs_tds_item_comv>-zernam = is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-created_by.
            <lfs_tds_item_comx>-zernam = 'X'.
          ELSE. " ELSE -> IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-created_by IS NOT INITIAL
            <lfs_tds_item_comv>-zernam = sy-uname.
            <lfs_tds_item_comx>-zernam = 'X'.
          ENDIF. " IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zadd_data-created_by IS NOT INITIAL
*--End of changes for OTC_IDD_0222 by U033876- SCTASK0768763
          IF <lfs_input_item>-z01otc_zadd_data-agreement_id IS NOT INITIAL.
            <lfs_tds_item_comv>-zzagmnt     = <lfs_input_item>-z01otc_zadd_data-agreement_id.
            <lfs_tds_item_comx>-zzagmnt     = 'X'.
          ENDIF. " IF <lfs_input_item>-z01otc_zadd_data-agreement_id IS NOT INITIAL

          IF <lfs_input_item>-z01otc_zadd_data-agreement_type IS NOT INITIAL.
            <lfs_tds_item_comv>-zzagmnt_typ = <lfs_input_item>-z01otc_zadd_data-agreement_type.
            <lfs_tds_item_comx>-zzagmnt_typ = 'X'.
          ENDIF. " IF <lfs_input_item>-z01otc_zadd_data-agreement_type IS NOT INITIAL

          IF <lfs_input_item>-z01otc_zitemref IS NOT INITIAL.
            <lfs_tds_item_comv>-zzitemref   = <lfs_input_item>-z01otc_zitemref.
            <lfs_tds_item_comx>-zzitemref   = 'X'.
          ENDIF. " IF <lfs_input_item>-z01otc_zitemref IS NOT INITIAL

          IF <lfs_input_item>-z01otc_zadd_data-quotref IS NOT INITIAL.
            <lfs_tds_item_comv>-zzquoteref  = <lfs_input_item>-z01otc_zadd_data-quotref.
            <lfs_tds_item_comx>-zzquoteref  = 'X'.
          ENDIF. " IF <lfs_input_item>-z01otc_zadd_data-quotref IS NOT INITIAL

          IF <lfs_input_item>-z01otc_zcontractdata-start_date IS NOT INITIAL.
            <lfs_tds_item_comv>-zzvbegdat  = <lfs_input_item>-z01otc_zcontractdata-start_date.
            <lfs_tds_item_comx>-zzvbegdat  = 'X'.
          ENDIF. " IF <lfs_input_item>-z01otc_zcontractdata-start_date IS NOT INITIAL

          IF <lfs_input_item>-z01otc_zcontractdata-end_date IS NOT INITIAL.
            <lfs_tds_item_comv>-zzvenddat  = <lfs_input_item>-z01otc_zcontractdata-end_date.
            <lfs_tds_item_comx>-zzvenddat  = 'X'.
          ENDIF. " IF <lfs_input_item>-z01otc_zcontractdata-end_date IS NOT INITIAL

          IF <lfs_input_item>-z01otc_zcontractdata-agreement_acceptance_date IS NOT INITIAL.
            <lfs_tds_item_comv>-zzvabndat  = <lfs_input_item>-z01otc_zcontractdata-agreement_acceptance_date.
            <lfs_tds_item_comx>-zzvabndat  = 'X'.
          ENDIF . " IF <lfs_input_item>-z01otc_zcontractdata-agreement_acceptance_date IS NOT INITIAL

          IF <lfs_input_item>-buyer_document-item_id IS NOT INITIAL.
            <lfs_tds_item_comv>-posex  = <lfs_input_item>-buyer_document-item_id.
            <lfs_tds_item_comx>-posex  = 'X'.
          ENDIF. " IF <lfs_input_item>-buyer_document-item_id IS NOT INITIAL

*--Start of D2_CR_127 - Rout
          IF <lfs_input_item>-z01otc_zadd_data-route IS NOT INITIAL.
            <lfs_tds_item_comv>-route  = <lfs_input_item>-z01otc_zadd_data-route.
            <lfs_tds_item_comx>-route  = 'X'.
          ENDIF. " IF <lfs_input_item>-z01otc_zadd_data-route IS NOT INITIAL
*--End of D2_CR_127 - Rout

*--Start of Defect # 615
          IF <lfs_input_item>-product-batch_id-content IS NOT INITIAL.

            lv_charg = <lfs_input_item>-product-batch_id-content.
*--Begin of change for defect # 4537
*            SHIFT lv_charg LEFT DELETING LEADING '0'.
*--End of change for defect # 4537
*--Start of D2_CR_9
*--Taking all Material No's and batch no's  into a Internal table
            lwa_matbatch_quan-matnr   = <lfs_input_item>-product-internal_id-content. "Material no.
            lwa_matbatch_quan-charg   = lv_charg. "Batch no.
            lwa_matbatch_quan-item_id = <lfs_input_item>-buyer_document-item_id.
            lwa_matbatch_quan-req_qty = <lfs_input_item>-total_values-requested_quantity-content.
            APPEND lwa_matbatch_quan TO li_matbatch_quan.
            CLEAR lwa_matbatch_quan.
            IF li_matbatch_quan[] IS NOT INITIAL.

              CALL FUNCTION 'ZOTC_BATCH_ID_VALIDATE'
                EXPORTING
                  im_vkorg         = lv_vkorg         "Sales org
                  im_vtweg         = lv_vtweg         "Distribution channel
                  im_kunnr         = lv_kunwe         "Ship to customer
                  im_matbatch_quan = li_matbatch_quan "Material,Batch combination table.
                IMPORTING
                  ex_batch_msg     = li_batch_msg
* ---> Begin of Insert for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4
                EXCEPTIONS "##FM_SUBRC_OK
                  invalid_batch    = 1.
* <--- End   of Insert for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4

              IF li_batch_msg IS NOT INITIAL.
                APPEND LINES OF li_batch_msg TO ct_message_log.
              ENDIF. " IF li_batch_msg IS NOT INITIAL
            ENDIF. " IF li_matbatch_quan[] IS NOT INITIAL
*--End of D2_CR_9

            <lfs_tds_item_comv>-charg  = lv_charg.
            <lfs_tds_item_comx>-charg  = 'X'.
          ENDIF. " IF <lfs_input_item>-product-batch_id-content IS NOT INITIAL
*--End of Defect # 615

*--Start of CR D2_36
          IF lwa_status_pstyv-active = abap_true.
            IF  is_input-sales_order_erpcreate_request-sales_order-z01otc_zdoctyp1 = lc_source_smax.
*& --> Begin of Insert for Defect#1485 by SAGARWA1
              li_price_component[] = <lfs_input_item>-price_component[]. "#EC ENHOK
              READ TABLE li_status INTO lwa_status WITH KEY criteria = lc_content
                                                            active   = abap_true.
              IF sy-subrc = 0.
                lv_content = lwa_status-sel_low.
              ENDIF. " IF sy-subrc = 0
              CLEAR : lv_price_flag.
              LOOP AT li_price_component ASSIGNING <lfs_price_component>.
                IF <lfs_price_component>-price_specification_element_t-content = lv_content.
                  lv_price_flag = abap_true.
                  EXIT.
                ENDIF. " IF <lfs_price_component>-price_specification_element_t-content = lv_content
              ENDLOOP. " LOOP AT li_price_component ASSIGNING <lfs_price_component>

              IF lv_price_flag IS INITIAL.
*& --> End of Insert for Defect#1485 by SAGARWA1
                IF <lfs_input_item>-z01otc_zbill_method IS NOT INITIAL AND
                   <lfs_input_item>-z01otc_zbill_frequency IS NOT INITIAL.
                  CLEAR lv_pstyv.
                  CALL METHOD me->get_item_category
                    EXPORTING
                      ex_billing_method    = <lfs_input_item>-z01otc_zbill_method
                      ex_billing_frequency = <lfs_input_item>-z01otc_zbill_frequency
                    IMPORTING
                      im_item_category     = lv_pstyv
                    CHANGING
                      cv_flag_error        = cv_flag_error
                      ct_message_log       = ct_message_log.
                  IF lv_pstyv IS NOT INITIAL.
                    <lfs_tds_item_comv>-pstyv  = lv_pstyv.
                    <lfs_tds_item_comx>-pstyv  = 'X'.
                  ENDIF. " IF lv_pstyv IS NOT INITIAL
                ENDIF. " IF <lfs_input_item>-z01otc_zbill_method IS NOT INITIAL AND
*& --> Begin of Insert for Defect#1485 by SAGARWA1
              ELSE. " ELSE -> IF lv_price_flag IS INITIAL
                READ TABLE li_mtpos ASSIGNING <lfs_mtpos> WITH  KEY
                                                            matnr = <lfs_input_item>-product-internal_id-content " #EC ENHOK.
                                                          BINARY SEARCH.
                IF sy-subrc IS INITIAL.
                  READ TABLE li_t184 ASSIGNING <lfs_t184> WITH KEY mtpos = <lfs_mtpos>-mtpos_mara
                                                          BINARY SEARCH.
                  IF sy-subrc IS INITIAL.
                    <lfs_tds_item_comv>-pstyv  = <lfs_t184>-pstyv.
                    <lfs_tds_item_comx>-pstyv  = abap_true.
                  ENDIF. " IF sy-subrc IS INITIAL
                ENDIF. " IF sy-subrc IS INITIAL
              ENDIF. " IF lv_price_flag IS INITIAL
*& --> End of Insert for Defect#1485 by SAGARWA1

            ENDIF. " IF is_input-sales_order_erpcreate_request-sales_order-z01otc_zdoctyp1 = lc_source_smax
          ENDIF. " IF lwa_status_pstyv-active = abap_true
*--End of CR D2_36
        ENDIF. " IF sy-subrc = 0

*--Start of D2_CR_9
*--Serial Number Validation and Export to User exit
        IF <lfs_input_item>-z01otc_zadd_data-serial_no IS NOT INITIAL.
          li_serial_no[] = <lfs_input_item>-z01otc_zadd_data-serial_no.

          LOOP AT li_serial_no ASSIGNING <lfs_serial>.
*--Conversion exit on serial numbes.
            CALL FUNCTION 'CONVERSION_EXIT_GERNR_INPUT'
              EXPORTING
                input  = <lfs_serial>-sernr
              IMPORTING
                output = <lfs_serial>-sernr.
            lwa_matser-matnr = <lfs_input_item>-product-internal_id-content. "Material no. by Jahan Defect # 1763
            lwa_matser-sernr = <lfs_serial>-sernr.
            APPEND lwa_matser TO li_matser.
            CLEAR lwa_matser-sernr.

          ENDLOOP. " LOOP AT li_serial_no ASSIGNING <lfs_serial>

*--FM to validate serial numbers
          IF li_matser[] IS NOT INITIAL.
            CALL FUNCTION 'ZOTC_SERIAL_NUM_VALIDATE'
              EXPORTING
                im_vkorg              = lv_vkorg  "Sales org
                im_vtweg              = lv_vtweg  "Distribution chaneel
                im_kunnr              = lv_kunwe  "Ship to customer
                im_matser_tab         = li_matser "Material,serial num combination table
              IMPORTING
                ex_serial_msg         = li_serial_msg
              EXCEPTIONS
                invalid_serial_number = 1.        " Def# 2892

            IF li_serial_msg IS NOT INITIAL.
              APPEND LINES OF li_serial_msg TO ct_message_log.
            ENDIF. " IF li_serial_msg IS NOT INITIAL

            CONCATENATE lc_memory_id <lfs_input_item>-buyer_document-item_id INTO lv_memory_id SEPARATED BY '_'.
            EXPORT li_serial_no_t FROM li_serial_no TO MEMORY ID lv_memory_id.
          ENDIF. " IF li_matser[] IS NOT INITIAL
          FREE  li_matser.
        ENDIF. " IF <lfs_input_item>-z01otc_zadd_data-serial_no IS NOT INITIAL
*--End of D2_CR_9

*---> Begin of CR: D2_541
* Billing Method
        IF <lfs_input_item>-z01otc_zbill_method IS NOT INITIAL.
          <lfs_tds_item_comv>-zz_bilmet  = <lfs_input_item>-z01otc_zbill_method.
          <lfs_tds_item_comx>-zz_bilmet  = 'X'.
        ENDIF. " IF <lfs_input_item>-z01otc_zbill_method IS NOT INITIAL

* Billing Frequency
        IF <lfs_input_item>-z01otc_zbill_frequency IS NOT INITIAL.
          <lfs_tds_item_comv>-zz_bilfr  = <lfs_input_item>-z01otc_zbill_frequency.
          <lfs_tds_item_comx>-zz_bilfr  = 'X'.
        ENDIF. " IF <lfs_input_item>-z01otc_zbill_frequency IS NOT INITIAL
*<--- End of CR: D2_541
      ENDIF. " IF sy-subrc = 0
    ENDLOOP. " LOOP AT ct_item_comv ASSIGNING <lfs_tds_item_comv>

*--- Party data handling-Header
    LOOP AT ct_party_comv ASSIGNING <lfs_party_comv> WHERE cntpa = lc_000000.
      lv_index = sy-tabix.

      CASE <lfs_party_comv>-parvw.
        WHEN lc_ap OR "AP-Contact Person
             lc_zb.   "ZB-
          READ TABLE ct_party_comx ASSIGNING <lfs_party_comx> INDEX lv_index.
          IF sy-subrc = 0.
            LOOP AT is_input-sales_order_erpcreate_request-sales_order-party ASSIGNING <lfs_input_party>
                                                                             WHERE role_code = <lfs_party_comv>-parvw.
              IF <lfs_input_party>-z01otc_zname1 IS NOT INITIAL.
                <lfs_party_comv>-name = <lfs_input_party>-z01otc_zname1.
                <lfs_party_comx>-name = 'X'.
              ENDIF. " IF <lfs_input_party>-z01otc_zname1 IS NOT INITIAL

              LOOP AT <lfs_input_party>-z01otc_zaddress-communication-email ASSIGNING <lfs_email> WHERE uri-content IS NOT INITIAL.
*                IF <lfs_email>-uri-content IS NOT INITIAL.
                <lfs_party_comv>-email = <lfs_email>-uri-content.
                <lfs_party_comx>-email = 'X'.
                <lfs_party_comv>-zzdeflt_comm = 'INT'.
                <lfs_party_comx>-zzdeflt_comm = 'X'.
*                ENDIF. " IF <lfs_email>-uri-content IS NOT INITIAL
              ENDLOOP. " LOOP AT <lfs_input_party>-z01otc_zaddress-communication-email ASSIGNING <lfs_email> WHERE uri-content IS NOT INITIAL

*Begin of Code changes - U105235 - SCTASK0855341 - July 29 -2019
*populating the city name, postal code, telephone and country for the AP-Contact person from the xml payload input data

              IF <lfs_input_party>-z01otc_zaddress-physical_address-country_code IS NOT INITIAL.
                <lfs_party_comv>-country = <lfs_input_party>-z01otc_zaddress-physical_address-country_code.
                <lfs_party_comx>-country = abap_true.
                lv_add_flag = abap_true.
              ENDIF.

              IF <lfs_input_party>-z01otc_zaddress-physical_address-city_name IS NOT INITIAL.
                <lfs_party_comv>-city = <lfs_input_party>-z01otc_zaddress-physical_address-city_name.
                <lfs_party_comx>-city = abap_true.
                lv_add_flag = abap_true.
              ENDIF.

              IF <lfs_input_party>-z01otc_zaddress-physical_address-street_postal_code IS NOT INITIAL.
                <lfs_party_comv>-pcode = <lfs_input_party>-z01otc_zaddress-physical_address-street_postal_code.
                <lfs_party_comx>-pcode = abap_true.
                lv_add_flag = abap_true.
              ENDIF.

              IF <lfs_input_party>-z01otc_zaddress-communication-telephone IS NOT INITIAL.
                CLEAR lwa_telephone.
                READ TABLE <lfs_input_party>-z01otc_zaddress-communication-telephone INTO lwa_telephone INDEX 1.
                IF sy-subrc = 0.
                  <lfs_party_comv>-telnum = lwa_telephone-number-subscriber_id.
                  <lfs_party_comx>-telnum = abap_true.
                  lv_add_flag = abap_true.
                ENDIF.
              ENDIF.

**End of Code changes - U105235 - SCTASK0855341 - July 29 -2019


* Begin of change for OTC_IDD_0222 by U033876- SCTASK0768763
              LOOP AT <lfs_input_party>-z01otc_zaddress-communication-facsimile ASSIGNING <lfs_fax> WHERE number-subscriber_id IS NOT INITIAL.
                <lfs_party_comv>-faxnum  = <lfs_fax>-number-subscriber_id.
                <lfs_party_comx>-faxnum  = abap_true.
              ENDLOOP. " LOOP AT <lfs_input_party>-z01otc_zaddress-communication-facsimile ASSIGNING <lfs_fax> WHERE number-subscriber_id IS NOT INITIAL
* End of Change for OTC_IDD_0222 by U033876- SCTASK0768763

            ENDLOOP. " LOOP AT is_input-sales_order_erpcreate_request-sales_order-party ASSIGNING <lfs_input_party>
          ENDIF. " IF sy-subrc = 0
        WHEN lc_we. "WE-Ship-to

          READ TABLE ct_party_comx ASSIGNING <lfs_party_comx> INDEX lv_index.
          IF sy-subrc = 0.
            LOOP AT is_input-sales_order_erpcreate_request-sales_order-party ASSIGNING <lfs_input_party>
                                                                              WHERE role_code = <lfs_party_comv>-parvw.


              IF <lfs_input_party>-z01otc_zaddress-physical_address-street_name IS NOT INITIAL.
                <lfs_party_comv>-street = <lfs_input_party>-z01otc_zaddress-physical_address-street_name.
                <lfs_party_comx>-street = 'X'.
                lv_add_flag = abap_true.
              ENDIF. " IF <lfs_input_party>-z01otc_zaddress-physical_address-street_name IS NOT INITIAL


              IF <lfs_input_party>-z01otc_zaddress-physical_address-care_of_name IS NOT INITIAL.
                <lfs_party_comv>-name2 = <lfs_input_party>-z01otc_zaddress-physical_address-care_of_name.
                <lfs_party_comx>-name2 = 'X'.
                lv_add_flag = abap_true.
              ENDIF. " IF <lfs_input_party>-z01otc_zaddress-physical_address-care_of_name IS NOT INITIAL
*--Start of D2_CR_20
              IF <lfs_input_party>-z01otc_zaddress-physical_address-building_id IS NOT INITIAL.
                <lfs_party_comv>-zzbuilding = <lfs_input_party>-z01otc_zaddress-physical_address-building_id.
                <lfs_party_comx>-zzbuilding = 'X'.
                lv_add_flag = abap_true.
              ENDIF. " IF <lfs_input_party>-z01otc_zaddress-physical_address-building_id IS NOT INITIAL
*--End of D2_CR_20

              IF <lfs_input_party>-z01otc_zaddress-physical_address-floor_id IS NOT INITIAL.
                <lfs_party_comv>-zzfloor = <lfs_input_party>-z01otc_zaddress-physical_address-floor_id.
                <lfs_party_comx>-zzfloor = 'X'.
                lv_add_flag = abap_true.
              ENDIF. " IF <lfs_input_party>-z01otc_zaddress-physical_address-floor_id IS NOT INITIAL

              IF <lfs_input_party>-z01otc_zaddress-physical_address-room_id IS NOT INITIAL.
                <lfs_party_comv>-zzroomnumber = <lfs_input_party>-z01otc_zaddress-physical_address-room_id.
                <lfs_party_comx>-zzroomnumber = 'X'.
                lv_add_flag = abap_true.
              ENDIF. " IF <lfs_input_party>-z01otc_zaddress-physical_address-room_id IS NOT INITIAL

*--Start of D2_CR_20
              IF <lfs_input_party>-z01otc_zaddress-physical_address-additional_house_id IS NOT INITIAL.
                <lfs_party_comv>-zzaddhouseid = <lfs_input_party>-z01otc_zaddress-physical_address-additional_house_id.
                <lfs_party_comx>-zzaddhouseid = 'X'.
                lv_add_flag = abap_true.
              ENDIF. " IF <lfs_input_party>-z01otc_zaddress-physical_address-additional_house_id IS NOT INITIAL
*--End of D2_CR_20

*--Start of D2_CR_137
              IF <lfs_input_party>-z01otc_zaddress-physical_address-street_prefix_name IS NOT INITIAL.
                li_st_prefix_tab[] = <lfs_input_party>-z01otc_zaddress-physical_address-street_prefix_name.
                READ TABLE li_st_prefix_tab INTO  wa_st_prefix_tab INDEX lv_index. "<lfs_party_comv>-zzstr_suppl1 INDEX lv_index.
                IF sy-subrc = 0.
                  <lfs_party_comv>-zzstr_suppl1 = wa_st_prefix_tab.
                  <lfs_party_comx>-zzstr_suppl1 = 'X'.
                  lv_add_flag = abap_true.
                ENDIF. " IF sy-subrc = 0
              ENDIF. " IF <lfs_input_party>-z01otc_zaddress-physical_address-street_prefix_name IS NOT INITIAL
            ENDLOOP. " LOOP AT is_input-sales_order_erpcreate_request-sales_order-party ASSIGNING <lfs_input_party>

            IF lv_add_flag = abap_true.

              IF <lfs_input_party>-z01otc_zaddress-physical_address-street_name IS INITIAL.
                <lfs_party_comv>-street = space .
                <lfs_party_comx>-street = 'X'.
              ENDIF. " IF <lfs_input_party>-z01otc_zaddress-physical_address-street_name IS INITIAL

              IF <lfs_input_party>-z01otc_zaddress-physical_address-care_of_name IS INITIAL.
                <lfs_party_comv>-name2 = space .
                <lfs_party_comx>-name2 = 'X'.
              ENDIF. " IF <lfs_input_party>-z01otc_zaddress-physical_address-care_of_name IS INITIAL

              IF <lfs_input_party>-z01otc_zaddress-physical_address-building_id IS INITIAL.
                <lfs_party_comv>-zzbuilding = space.
                <lfs_party_comx>-zzbuilding = 'X'.
              ENDIF. " IF <lfs_input_party>-z01otc_zaddress-physical_address-building_id IS INITIAL

              IF <lfs_input_party>-z01otc_zaddress-physical_address-floor_id IS INITIAL.
                <lfs_party_comv>-zzfloor = space.
                <lfs_party_comx>-zzfloor = 'X'.
              ENDIF. " IF <lfs_input_party>-z01otc_zaddress-physical_address-floor_id IS INITIAL

              IF <lfs_input_party>-z01otc_zaddress-physical_address-room_id IS INITIAL.
                <lfs_party_comv>-zzroomnumber = space.
                <lfs_party_comx>-zzroomnumber = 'X'.
              ENDIF. " IF <lfs_input_party>-z01otc_zaddress-physical_address-room_id IS INITIAL

              IF <lfs_input_party>-z01otc_zaddress-physical_address-additional_house_id IS INITIAL.
                <lfs_party_comv>-zzaddhouseid = space.
                <lfs_party_comx>-zzaddhouseid = 'X'.
              ENDIF. " IF <lfs_input_party>-z01otc_zaddress-physical_address-additional_house_id IS INITIAL

              IF <lfs_input_party>-z01otc_zaddress-physical_address-street_prefix_name IS INITIAL.
                <lfs_party_comv>-zzstr_suppl1 = space.
                <lfs_party_comx>-zzstr_suppl1 = 'X'.
              ENDIF. " IF <lfs_input_party>-z01otc_zaddress-physical_address-street_prefix_name IS INITIAL

              CALL METHOD me->map_address_data
                EXPORTING
                  im_kunnr      = <lfs_party_comv>-kunnr
                CHANGING
                  ct_party_comv = ct_party_comv
                  ct_party_comx = ct_party_comx.

            ENDIF. " IF lv_add_flag = abap_true
          ENDIF. " IF sy-subrc = 0
*--End of of D2_CR_137

      ENDCASE.
    ENDLOOP. " LOOP AT ct_party_comv ASSIGNING <lfs_party_comv> WHERE cntpa = lc_000000

*---> Begin of CR: D2_541
* As the Interface directly populates the fields: Billing Method and Billing Frequency
* no need to have OTC_EDD_0179 populate it saparetly
**-->Begin of Insert for D2_OTC_EDD-0179 by PBOSE
** Input parameter is_input is passed to a global data object to be used in OTC_EDD-0179.
*    CALL FUNCTION 'ZOTC_BILLING_SET'
*      EXPORTING
*        im_so_item = is_input-sales_order_erpcreate_request-sales_order-item.
**<-- End of Insert for D2_OTC_EDD-0179 by PBOSE
*<--- End of CR: D2_541

    CLEAR li_item[].
*--Moving item data into a local table.
    li_item[] = ct_item_comv[].

    IF li_item[] IS NOT INITIAL.
      SORT li_item BY mabnr.
      DELETE ADJACENT DUPLICATES FROM li_item COMPARING mabnr.
*--Moving only unique material no. to a Internal table.
      LOOP AT li_item ASSIGNING <lfs_item>.
        APPEND <lfs_item>-mabnr TO li_matnr.
      ENDLOOP. " LOOP AT li_item ASSIGNING <lfs_item>

*--Calling FM for Re-agent rental contracts determination
      CALL FUNCTION 'ZOTC_DETERMINE_REAGENT_RENTAL'
        EXPORTING
          im_vkorg          = lv_vkorg         "Sales org
          im_vtweg          = lv_vtweg         "Distribution channel
          im_spart          = lv_spart         "Divison
          im_sold_to        = lv_kunag         "Sold to party
          im_ship_to        = lv_kunwe         "Ship to party
          im_matnr_tab      = li_matnr         "Material Table
        IMPORTING
          ex_contract_data  = li_contract_data "Table for contract data
          ex_contract_count = lv_contract_count.

*--Validating each and every item for contract
*---a. If unique contract exists no action required
*---b. If multiple contract exists then return warning message

      SORT li_contract_data BY matnr.
      LOOP AT ct_item_comv ASSIGNING <lfs_item>.
        lv_index = sy-tabix.

        READ TABLE li_contract_data ASSIGNING <lfs_contract> WITH KEY matnr = <lfs_item>-mabnr
                                                             BINARY SEARCH .
*--If count of no. of contracts per material Greater than 1 then populate warning message
        IF sy-subrc EQ 0 .
          IF lv_contract_count GT 1.
*--Message - Multiple contracts found for item & and Material & .
            MESSAGE s136(zotc_msg)    " Multiple contracts found for item & and Material & .
               WITH  <lfs_item>-posnr "Item no.
                     <lfs_item>-mabnr "Material No.
               INTO lv_note.

            lwa_message-type       = lc_msg_typ_w.
            lwa_message-id         = lc_msg_otc.
            lwa_message-number     = lc_msg_num1.
            lwa_message-message_v1 = lv_note.
*          lwa_message-message_v2 = lc_sev_code_3.
            APPEND lwa_message TO ct_message_log.
          ENDIF. " IF lv_contract_count GT 1
        ENDIF. " IF sy-subrc EQ 0
*--Clearing work areas.
        CLEAR :  lwa_output_item,
                 lv_note.
      ENDLOOP. " LOOP AT ct_item_comv ASSIGNING <lfs_item>
    ENDIF. " IF li_item[] IS NOT INITIAL

*--Check duplicate order creation during timeout period
*--Read VBAK table using ZZDOCREF and ZZDOCTYPE if order is already created.

    IF NOT cs_head_comv-zzdocref IS INITIAL AND cs_head_comv-zzdoctyp NE '08'. "If doc ref is initial duplicate check is not required.

      SELECT vbeln "Sales Document
          UP TO 1 ROWS
        FROM vbak  "Sales Document: Header Data
        INTO lv_vbeln
       WHERE zzdocref EQ cs_head_comv-zzdocref
         AND zzdoctyp EQ cs_head_comv-zzdoctyp.
      ENDSELECT.

*--If Sales Order already created set error flag and populate error message.
      IF sy-subrc EQ  0.

        MESSAGE s000(zotc_msg) WITH " & & & &
                lv_vbeln
           INTO lv_msg_v0.
        lwa_message-type   = lc_msg_typ_i.
        lwa_message-id     = lc_msg_otc.
        lwa_message-number = lc_msg_num.
        lwa_message-message_v1 = lv_msg_v0.
        APPEND lwa_message TO ct_message_log.

        MESSAGE s000(zotc_msg) WITH " & & & &
                'SO Number'(001)
                lv_vbeln
                'already created'(002)
           INTO lv_msg_v1.

        lwa_message-type   = lc_msg_typ.
        lwa_message-id     = lc_msg_otc.
        lwa_message-number = lc_msg_num.
        lwa_message-message_v1 = lv_msg_v1.
        APPEND lwa_message TO ct_message_log.

        MESSAGE s000(zotc_msg) WITH " & & & &
                'For Doc Ref. number'(003)
                cs_head_comv-zzdocref
           INTO lv_msg_v2.

        lwa_message-type   = lc_msg_typ.
        lwa_message-id     = lc_msg_otc.
        lwa_message-number = lc_msg_num.
        lwa_message-message_v1 = lv_msg_v2.
        APPEND lwa_message TO ct_message_log.

*--Set error flag to terminate Sales Order creation process
        cv_flag_error = abap_true.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF NOT cs_head_comv-zzdocref IS INITIAL
  ENDIF. " IF sy-subrc EQ 0
ENDMETHOD.


METHOD if_sls_appl_se_soerpcrtrc2~outbound_processing.
***********************************************************************
***********************************************************************
***********************************************************************
*Method     : IF_SLS_APPL_SE_SOERPCRTRC2~OUTBOUND_PROCESSING          *
*Title      : ES Sales Order Creation                                 *
*Developer  : Jahan Mazumder                                          *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0090                                           *
*---------------------------------------------------------------------*
*Description: Create Sales Order in SAP using ESR Service Interface   *
*Create Request Confirmation_In V2                                    *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:                                                *
*=====================================================================*
*Date           User        Transport       Description               *
*=========== ============== ============== ===========================*
*06-Jun-2014  JAHAN         E2DK900476      INITIAL DEVELOPMENT       *
*---------------------------------------------------------------------*

  CONSTANTS :
*     lc_msg_typ          TYPE bapi_mtype           VALUE 'E',                   " Message Class "decleration commented as part of SCI Checks
     lc_msg_typ_i        TYPE bapi_mtype           VALUE 'I',                   " Message Class
     lc_result_code      TYPE char1                VALUE '3',                   " Result code for success '3'
     lc_msg_otc          TYPE symsgid              VALUE 'ZOTC_MSG',            " Message Class
     lc_idd_0090_002     TYPE z_enhancement        VALUE 'D2_OTC_IDD_0090_002', " Enhancement No.
     lc_null             TYPE z_criteria           VALUE 'NULL',                " Enh. Criteria
     lc_msg_num          TYPE symsgno              VALUE '000'.                 " Message Number

  DATA: li_status        TYPE STANDARD TABLE OF zdev_enh_status. "Enhancement Status table

  FIELD-SYMBOLS : <lfs_message> TYPE bapiret2. " Return Parameter

* Begin of CR D2_541
* Call to EMI Function Module To Get List Of EMI Statuses
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_idd_0090_002 "CR: D2_541 changed constant
    TABLES
      tt_enh_status     = li_status.

*Non active entries are removed.
  DELETE li_status WHERE active EQ abap_false.

  READ TABLE li_status WITH KEY criteria = lc_null "NULL
                       TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
* Endof CR D2_541
    IF NOT ct_message_log[] IS INITIAL.

      LOOP AT ct_message_log  ASSIGNING <lfs_message> WHERE type   = lc_msg_typ_i " Message_log assigni of type
                                                        AND id     = lc_msg_otc
                                                        AND number = lc_msg_num.
*      IF <lfs_message>-type   = lc_msg_typ_i AND
*         <lfs_message>-id     = lc_msg_otc AND
*         <lfs_message>-number = lc_msg_num.
        cs_output-sales_order_erpcreate_confirm-sales_order-sales_order-id-content = <lfs_message>-message_v1.
        cs_output-sales_order_erpcreate_confirm-log-business_document_processing = lc_result_code.
*      ENDIF. " IF <lfs_message>-type = lc_msg_typ_i AND
      ENDLOOP. " LOOP AT ct_message_log ASSIGNING <lfs_message> WHERE type = lc_msg_typ_i
    ENDIF. " IF NOT ct_message_log[] IS INITIAL

  ENDIF. " IF sy-subrc EQ 0
ENDMETHOD.


METHOD map_address_data.
***********************************************************************
***********************************************************************
***********************************************************************
*Method     : IF_SLS_APPL_SE_SOERPCRTRC2~GET_ITEM_CATEGORY            *
*Title      : ES Sales Order Creation                                 *
*Developer  : Jahan Mazumder                                          *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0090 / CR - D2_137                             *
*---------------------------------------------------------------------*
*Description: Customer address over ride                              *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:                                                *
*=====================================================================*
*Date           User        Transport       Description               *
*=========== ============== ============== ===========================*
*30-Aug-2014  JAHAN        E2DK900476      INITIAL DEVELOPMENT        *
*---------------------------------------------------------------------*

*--Type declaration for KNA1
  TYPES : BEGIN OF lty_kna1,
            kunnr TYPE kunnr, " Customer Number
            adrnr TYPE adrnr, " Address
          END OF lty_kna1.

*--Local data declaration
  CONSTANTS :
    lc_we     TYPE parvw                VALUE 'WE',     " Partner Function
    lc_000000 TYPE posnr                VALUE '000000'. " Item number of the SD document

  DATA : li_address_keys TYPE STANDARD TABLE OF addr_key, " Structure with reference key fields and address type
         li_adrc         TYPE STANDARD TABLE OF vadrc,    " Addresses (Business Address Services)
         li_adr2         TYPE STANDARD TABLE OF vadr2,    " Telephone Numbers (Business Address Services)
         lv_index        TYPE sytabix.                    " Index of Internal Tables

*--Internal table and Workarea Declarations
  DATA : lwa_address_keys TYPE addr_key, " Structure with reference key fields and address type
         li_kna1          TYPE STANDARD TABLE OF lty_kna1,
         lwa_kna1         TYPE lty_kna1.
*         lwa_adrc            TYPE adrc_tab, "decleration commented as part of SCI Checks
*         lwa_adr2            TYPE adr2_tab. "decleration commented as part of SCI Checks


  FIELD-SYMBOLS:
    <lfs_adrc>       TYPE vadrc,          " Change Document Structure; Generated by RSSCD000
*        <lfs_adr2>            TYPE vadr2,          " Change Document Structure; Generated by RSSCD000 "decleration commented as part of SCI Checks
    <lfs_party_comv> TYPE tds_party_comv, " Lean Order - Partner Data (Values)
    <lfs_party_comx> TYPE tds_party_comc. " Lean Order - Partner Data (CHAR)

  IF im_kunnr IS NOT INITIAL.

    SELECT kunnr adrnr
    FROM kna1 " General Data in Customer Master
    INTO TABLE li_kna1
    WHERE kunnr EQ im_kunnr.
    IF sy-subrc = 0.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF im_kunnr IS NOT INITIAL

  IF li_kna1[] IS NOT INITIAL.
    LOOP AT li_kna1 INTO lwa_kna1.
      CLEAR : lwa_address_keys.
      MOVE lwa_kna1-adrnr TO lwa_address_keys-addrnumber.
      MOVE '1'            TO lwa_address_keys-addr_type.
      APPEND lwa_address_keys TO li_address_keys.
    ENDLOOP. " LOOP AT li_kna1 INTO lwa_kna1
  ENDIF. " IF li_kna1[] IS NOT INITIAL

  IF li_address_keys[] IS NOT INITIAL.
    CALL FUNCTION 'ADDR1_EXTRACT_TABLES'
      TABLES
        t_address_keys = li_address_keys
        t_adrc         = li_adrc "<lfs_adrc>
        t_adr2         = li_adr2 "<lfs_adr2>
      EXCEPTIONS
        empty_table    = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF. " IF sy-subrc <> 0

*--- Party data handling-Header
    LOOP AT ct_party_comv ASSIGNING <lfs_party_comv> WHERE cntpa = lc_000000.
      lv_index = sy-tabix.
      CASE <lfs_party_comv>-parvw.
        WHEN lc_we. "WE-Ship-to
          READ TABLE ct_party_comx ASSIGNING <lfs_party_comx> INDEX lv_index.
          IF sy-subrc = 0.

            READ TABLE li_adrc ASSIGNING <lfs_adrc> WITH KEY addrnumber = lwa_address_keys-addrnumber.

            IF sy-subrc = 0.

              IF <lfs_adrc>-name1 IS NOT INITIAL.
                <lfs_party_comv>-name = <lfs_adrc>-name1.
                <lfs_party_comx>-name = 'X'.
              ELSE.                                   " Defect 10243
                <lfs_party_comx>-name = 'X'.          " Defect 10243
              ENDIF. " IF <lfs_adrc>-name1 IS NOT INITIAL

              IF <lfs_adrc>-name2 IS NOT INITIAL.
                <lfs_party_comv>-name2 = <lfs_adrc>-name2.
                <lfs_party_comx>-name2 = 'X'.
              ELSE.                                     " Defect 10243
                <lfs_party_comx>-name2 = 'X'.           " Defect 10243
              ENDIF. " IF <lfs_adrc>-name2 IS NOT INITIAL

              IF <lfs_adrc>-city1 IS NOT INITIAL.
                <lfs_party_comv>-city = <lfs_adrc>-city1.
                <lfs_party_comx>-city = 'X'.
              ELSE.                                                   " Defect 10243
                <lfs_party_comx>-city = 'X'.                           " Defect 10243
              ENDIF. " IF <lfs_adrc>-city1 IS NOT INITIAL

              IF <lfs_adrc>-city2 IS NOT INITIAL.
                <lfs_party_comv>-city2 = <lfs_adrc>-city2.   "Defect # 1958, by Jahan.
                <lfs_party_comx>-city2 = 'X'.
              ELSE.                                  " Defect 10243
                <lfs_party_comx>-city2 = 'X'.        " Defect 10243
              ENDIF. " IF <lfs_adrc>-city1 IS NOT INITIAL

              IF <lfs_adrc>-post_code1 IS NOT INITIAL.
                <lfs_party_comv>-pcode = <lfs_adrc>-post_code1.
                <lfs_party_comx>-pcode = 'X'.
              ELSE.                                       " Defect 10243
                <lfs_party_comx>-pcode = 'X'.             " Defect 10243
              ENDIF. " IF <lfs_adrc>-post_code1 IS NOT INITIAL

              IF <lfs_adrc>-po_box IS NOT INITIAL.
                <lfs_party_comv>-pbox = <lfs_adrc>-po_box.
                <lfs_party_comx>-pbox = 'X'.
              ELSE.                                      " Defect 10243
                <lfs_party_comx>-pbox = 'X'.             " Defect 10243
              ENDIF. " IF <lfs_adrc>-po_box IS NOT INITIAL

              IF <lfs_adrc>-post_code2 IS NOT INITIAL.
                <lfs_party_comv>-pbox_pcode = <lfs_adrc>-post_code2.
                <lfs_party_comx>-pbox_pcode = 'X'.
              ELSE.                                                " Defect 10243
                <lfs_party_comx>-pbox_pcode = 'X'.                 " Defect 10243
              ENDIF. " IF <lfs_adrc>-post_code2 IS NOT INITIAL

              IF <lfs_adrc>-street IS NOT INITIAL.
                IF <lfs_party_comv>-street IS INITIAL.
                  <lfs_party_comv>-street = <lfs_adrc>-street.
                  <lfs_party_comx>-street = 'X'.
                ELSE.                                             " Defect 10243
                  <lfs_party_comx>-street = 'X'.                  " Defect 10243
                ENDIF. " IF <lfs_party_comv>-street IS INITIAL
              ENDIF. " IF <lfs_adrc>-street IS NOT INITIAL

              IF <lfs_adrc>-house_num1 IS NOT INITIAL.
                <lfs_party_comv>-hnum = <lfs_adrc>-house_num1.
                <lfs_party_comx>-hnum = 'X'.
              ELSE.                                                    " Defect 10243
                <lfs_party_comx>-hnum = 'X'.                           " Defect 10243
              ENDIF. " IF <lfs_adrc>-house_num1 IS NOT INITIAL

              IF <lfs_adrc>-country IS NOT INITIAL.
                <lfs_party_comv>-country = <lfs_adrc>-country.
                <lfs_party_comx>-country = 'X'.
              ENDIF. " IF <lfs_adrc>-country IS NOT INITIAL

              IF <lfs_adrc>-langu IS NOT INITIAL.
                <lfs_party_comv>-langu_int = <lfs_adrc>-langu.
                <lfs_party_comx>-langu_int = 'X'.
              ELSE.                                               " Defect 10243
                <lfs_party_comx>-langu_int = 'X'.                 " Defect 10243
              ENDIF. " IF <lfs_adrc>-langu IS NOT INITIAL

              IF <lfs_adrc>-region IS NOT INITIAL.
                <lfs_party_comv>-region = <lfs_adrc>-region.
                <lfs_party_comx>-region = 'X'.
                ELSE.                                           " Defect 10243
                <lfs_party_comx>-region = 'X'.                  " Defect 10243
              ENDIF. " IF <lfs_adrc>-region IS NOT INITIAL

              IF <lfs_adrc>-tel_number IS NOT INITIAL.
                <lfs_party_comv>-telnum = <lfs_adrc>-tel_number.
                <lfs_party_comx>-telnum = 'X'.
              ELSE.                                        " Defect 10243
                <lfs_party_comx>-telnum = 'X'.             " Defect 10243
              ENDIF. " IF <lfs_adrc>-tel_number IS NOT INITIAL

              IF <lfs_adrc>-taxjurcode IS NOT INITIAL.
                <lfs_party_comv>-taxjurcode = <lfs_adrc>-taxjurcode.
                <lfs_party_comx>-taxjurcode = 'X'.
              ELSE.                                       " Defect 10243
                <lfs_party_comx>-taxjurcode = 'X'.        " Defect 10243
              ENDIF. " IF <lfs_adrc>-taxjurcode IS NOT INITIAL

              IF <lfs_adrc>-fax_number IS NOT INITIAL.
                <lfs_party_comv>-faxnum = <lfs_adrc>-fax_number.
                <lfs_party_comx>-faxnum = 'X'.
              ELSE.                                    " Defect 10243
                <lfs_party_comx>-faxnum = 'X'.         " Defect 10243
              ENDIF. " IF <lfs_adrc>-fax_number IS NOT INITIAL

              IF <lfs_adrc>-building IS NOT INITIAL.
                IF <lfs_party_comv>-zzbuilding IS INITIAL.
                  <lfs_party_comv>-zzbuilding = <lfs_adrc>-building.
                  <lfs_party_comx>-zzbuilding = 'X'.
                ELSE.                                          " Defect 10243
                  <lfs_party_comx>-zzbuilding = 'X'.           " Defect 10243
                ENDIF. " IF <lfs_party_comv>-zzbuilding IS INITIAL
              ENDIF. " IF <lfs_adrc>-building IS NOT INITIAL

              IF <lfs_adrc>-floor IS NOT INITIAL.
                IF <lfs_party_comv>-zzfloor IS INITIAL.
                  <lfs_party_comv>-zzfloor = <lfs_adrc>-floor.
                  <lfs_party_comx>-zzfloor = 'X'.
                ELSE.                               " Defect 10243
                  <lfs_party_comx>-zzfloor = 'X'.   " Defect 10243
                ENDIF. " IF <lfs_party_comv>-zzfloor IS INITIAL
              ENDIF. " IF <lfs_adrc>-floor IS NOT INITIAL

              IF <lfs_adrc>-roomnumber IS NOT INITIAL.
                IF <lfs_party_comv>-zzroomnumber IS INITIAL.
                  <lfs_party_comv>-zzroomnumber = <lfs_adrc>-roomnumber.
                  <lfs_party_comx>-zzroomnumber = 'X'.
                ELSE.                                    " Defect 10243
                  <lfs_party_comx>-zzroomnumber = 'X'.   " Defect 10243
                ENDIF. " IF <lfs_party_comv>-zzroomnumber IS INITIAL
              ENDIF. " IF <lfs_adrc>-roomnumber IS NOT INITIAL

              IF <lfs_adrc>-house_num2 IS NOT INITIAL.
                IF <lfs_party_comv>-zzaddhouseid IS INITIAL.
                  <lfs_party_comv>-zzaddhouseid = <lfs_adrc>-house_num2.
                  <lfs_party_comx>-zzaddhouseid = 'X'.
                ELSE.                                      " Defect 10243
                  <lfs_party_comx>-zzaddhouseid = 'X'.     " Defect 10243
                ENDIF. " IF <lfs_party_comv>-zzaddhouseid IS INITIAL
              ENDIF. " IF <lfs_adrc>-house_num2 IS NOT INITIAL

              IF <lfs_adrc>-str_suppl1 IS NOT INITIAL.
                IF <lfs_party_comv>-zzstr_suppl1 IS INITIAL.
                  <lfs_party_comv>-zzstr_suppl1 = <lfs_adrc>-str_suppl1.
                  <lfs_party_comx>-zzstr_suppl1 = 'X'.
                ELSE.                                            " Defect 10243
                  <lfs_party_comx>-zzstr_suppl1 = 'X'.           " Defect 10243
                ENDIF. " IF <lfs_party_comv>-zzstr_suppl1 IS INITIAL
              ENDIF. " IF <lfs_adrc>-str_suppl1 IS NOT INITIAL

            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF sy-subrc = 0
      ENDCASE.
    ENDLOOP. " LOOP AT ct_party_comv ASSIGNING <lfs_party_comv> WHERE cntpa = lc_000000

  ENDIF. " IF li_address_keys[] IS NOT INITIAL
ENDMETHOD.
ENDCLASS.
