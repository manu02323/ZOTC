class ZCL_IM_SIMULATE_SO definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_SLS_APPL_SE_SOERPCRTCHKQR .
protected section.
private section.

  methods GENERATE_RANDOM_PO
    importing
      !IM_NUMBER_CHARS type I
    exporting
      !EX_RANDOM_STRING type STRING .
ENDCLASS.



CLASS ZCL_IM_SIMULATE_SO IMPLEMENTATION.


METHOD generate_random_po.
***********************************************************************
*Program    : GENERATE_RANDOM_PO(METHOD)                              *
*Title      : ES Sales Order Simulation                               *
*Developer  : Shruti Gupta                                            *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0095                                           *
*---------------------------------------------------------------------*
*Description: This method is used to generate a random  35 character  *
*             purchase order number.                                  *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*12-FEB-2015  SGUPTA4       E2DK900468     CR D2_437,INITIAL DEVELOPMENT
*---------------------------------------------------------------------*


*************************Local Data Declaration************************
  DATA: lv_sign    TYPE     x,                     " Sign of type Byte fields
        lv_xpwd    TYPE     xstring,
        lv_seed    TYPE     i,                     " Seed of type Integers
        lv_random  TYPE     i,                     " Random of type Integers
        lref_conv  TYPE REF TO cl_abap_conv_in_ce, " Code Page and Endian Conversion (External -> System Format)
        lref_prnga TYPE REF TO cl_abap_random_int, " Abap_random_int class
        lref_prngc TYPE REF TO cl_abap_random_int, " Abap_random_int class
        lref_prngd TYPE REF TO cl_abap_random_int. " Abap_random_int class


  lv_seed = cl_abap_random=>seed( ).
* This function also inserts numbers
  lref_prnga = cl_abap_random_int=>create( seed = lv_seed min = 1 max = 2 ).
  lv_seed = cl_abap_random=>seed( ).
  lref_prngc = cl_abap_random_int=>create( seed = lv_seed min = 65 max = 90 ).
  lv_seed = cl_abap_random=>seed( ).
  lref_prngd = cl_abap_random_int=>create( seed = lv_seed min = 97 max = 122 ).


  DO im_number_chars TIMES.
* Loop will work 35 times
    lv_random = lref_prnga->get_next( ).
    CASE lv_random.
      WHEN 1.
        lv_sign = lref_prngd->get_next( ).
      WHEN 2.
        lv_sign = lref_prngc->get_next( ).
    ENDCASE.
    CONCATENATE lv_xpwd lv_sign INTO lv_xpwd IN BYTE MODE.
  ENDDO.
  lref_conv = cl_abap_conv_in_ce=>create( input = lv_xpwd ).
  lref_conv->read( IMPORTING data = ex_random_string ).

ENDMETHOD.


METHOD if_sls_appl_se_soerpcrtchkqr~inbound_processing.
***********************************************************************
*Program    : IF_SLS_APPL_SE_SOERPCRTCHKQR~INBOUND_PROCESSING         *
*Title      : ES Sales Order Simulation                               *
*Developer  : Harshit Badlani                                         *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0095                                           *
*---------------------------------------------------------------------*
*Description:Simulate Sales Order to retrieve ATP information, prices,*
*            taxes and handling charges for subscribing applications  *
*CR D2_8    : This CR invloves One time customer Freight calculation, *
*Serial and Batch validation.                                         *
*CR D2_93:In order to support EVO application to alert a web user     *
*for any error message returned by SAP at a line item level, the      *
*response XML is enhanced so that EVO can parse out messages per item *
*and alert user to take appropriate action                            *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*24-JUN-2014  HBADLAN      E2DK900468      CR:D2_8
*01-OCT-2014  HBADLAN      E2DK900468      CR:D2_93
*14-NOV-2014  HBADLAN      E2DK900468      Defect 1445
*08-DEC-2014  MCHATTE      E2DK900468      CR D2_302: Added sales office in COMV table
*21-JAN-2014  SGUPTA4      E2DK900468      Defect#3128,Making EMI     *
*                                          enhancement number unique. *
*04-Feb-2015  SGUPTA4      E2DK900468      CR D2_437: Populating the  *
*                                          PO number in order to make *
*                                          the response document      *
*                                          complete                   *
*31-MAR-2015  MBAGDA       E2DK911776      Defect 5169: Serial Number *
*                                          check per line item        *
*---------------------------------------------------------------------*

*Data Declarations
  TYPES : BEGIN OF lty_serial,
          sernr TYPE gernr, " Serial Number
          END OF lty_serial.

  DATA : li_item           TYPE sapplco_sls_ord_erpcrte_c_tab7,    "Input Item strcuture
         li_serial         TYPE STANDARD TABLE OF lty_serial,      "Table with serial numbers
         li_status         TYPE STANDARD TABLE OF zdev_enh_status, "Enhancement Status table
* ---> Begin of Delete for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
*         li_status1         TYPE STANDARD TABLE OF zdev_enh_status, "Enhancement Status table
* <--- End   of Delete for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
         li_serial_msg     TYPE bapirettab,                     "Table with messsgae from serial validation FM
         li_batch_msg      TYPE bapirettab,                     "Table with messsgae from Batch validation FM
         li_matser         TYPE zotc_t_matnr_sernr,             "Table with Material,serial combination
         li_matbatch_quan  TYPE zotc_t_matbatch_quan,           "Table with Material, Batch and quantity combination
         li_party          TYPE sapplco_sls_ord_erpcrte_c_tab8, "Table storing customer type and number
         lv_sold_to        TYPE kunag,                          "Sold-to party
         lv_ship_once      TYPE kunwe,                          "Ship-to party
         lv_ship_to        TYPE kunwe,                          "Ship-to party
         lv_kunnr          TYPE kunnr,                          "Customer Number
         lv_sales_org      TYPE vkorg,                          "Sales Organization
         lv_dist_chan      TYPE vtweg,                          "Distribution Channel
         lv_index          TYPE sytabix,                        "Index of Internal Tables
         lv_xcpdk          TYPE xcpdk,                          "Indicator: Is the account a one-time account?
         lv_sales_office   TYPE z_criteria,                     " Sales Office
         lwa_matbatch_quan TYPE zotc_matbatch_quan_s,           "Structure for Material,Batch and Requested quantity
         lwa_matser        TYPE zotc_matnr_sernr_s.             "Material Serial Number Combination structure

  FIELD-SYMBOLS: <lfs_serial>    TYPE lty_serial,                     "Serial no's structure
                <lfs_party_comv> TYPE tds_party_comv,                 "Lean Order - Partner Data (Values)
                <lfs_party>      TYPE sapplco_sls_ord_erpcrte_ck_q30, "IDT SalesOrderERPCreateCheckQueryParty
                <lfs_item>       TYPE sapplco_sls_ord_erpcrte_ck_q26, "IDT SalesOrderERPCreateCheckQueryItem
                <lfs_party_comx> TYPE tds_party_comc,                 "Lean Order - Partner Data (CHAR)
                <lfs_status>     TYPE zdev_enh_status,                " Enhancement Status
                <lfs_item_comv>  TYPE tds_item_comv.                  "Lean Order - Item Data (Values)

* ---> Begin of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
  CONSTANTS : lc_idd_0095_0001 TYPE z_enhancement VALUE 'D2_OTC_IDD_0095_0001', "Enhancement
*  CONSTANTS : lc_idd_0095_002 TYPE z_enhancement VALUE 'D2_OTC_IDD_0095_002', "Enhancement
*              lc_idd_0095_001 TYPE z_enhancement VALUE 'D2_OTC_IDD_0095_001', "CR D2_302 "Enhancement
* <--- End   of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
              lc_sales_office TYPE char12        VALUE 'SALES_OFFICE', " Sales_office of type CHAR12
              lc_underscr     TYPE char1         VALUE '_',            "Underscr of type CHAR1
              lc_null         TYPE z_criteria    VALUE 'NULL',         "Enh. Criteria
              lc_auart        TYPE z_criteria    VALUE 'AUART',        "Enh. Criteria
              lc_ship_to      TYPE parvw         VALUE 'WE',           "Partner type for Ship to customer
              lc_000000       TYPE posnr         VALUE '000000'.       "Item number of the SD documen

*Assigning data to local variables and tables.
  li_item[]    = is_input-sales_order_erpcreate_check_q-sales_order-item[]. "Input Item table
  li_party[]   = is_input-sales_order_erpcreate_check_q-sales_order-party. "Input party table
  lv_sold_to   = is_input-sales_order_erpcreate_check_q-sales_order-buyer_party-internal_id-content. "Sold to customer
  lv_sales_org = is_input-sales_order_erpcreate_check_q-sales_order-sales_and_service_business_ar-sales_organisation_id. "Sales Organization
  lv_dist_chan = is_input-sales_order_erpcreate_check_q-sales_order-sales_and_service_business_ar-distribution_channel_code-content. "Distribution Channel
  lv_ship_to   = is_input-sales_order_erpcreate_check_q-sales_order-goods_recipient_party-internal_id-content. "Ship to customer

**Pick Ship to customer from Recipient party .If not found then from PARTY structure for 'WE' partner type.
  IF is_input-sales_order_erpcreate_check_q-sales_order-goods_recipient_party-internal_id-content IS NOT INITIAL.
    lv_ship_to   = is_input-sales_order_erpcreate_check_q-sales_order-goods_recipient_party-internal_id-content. "Ship to customer
  ELSE. " ELSE -> IF is_input-sales_order_erpcreate_check_q-sales_order-goods_recipient_party-internal_id-content IS NOT INITIAL
    READ TABLE li_party ASSIGNING <lfs_party> WITH KEY role_code = lc_ship_to. "WE
    IF sy-subrc = 0.
      lv_ship_to = <lfs_party>-internal_id-content.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF is_input-sales_order_erpcreate_check_q-sales_order-goods_recipient_party-internal_id-content IS NOT INITIAL

* ---> Begin of Change for CR D2_437, D2_OTC_IDD_0095 by SGUPTA4


  CONSTANTS: lc_number_chars TYPE i VALUE '35'. " Number_chars of type Integers

  FIELD-SYMBOLS: <lfs_buyer_doc> TYPE sapplco_sls_ord_erpcrte_ck_qr1. " IDT SalesOrderERPCreateCheckQueryBuyerDocument

  DATA: lv_po_number TYPE string.

*Assign the Buyer document structure to the field symbol
  ASSIGN is_input-sales_order_erpcreate_check_q-sales_order-buyer_document TO <lfs_buyer_doc>.

* If Buyer Document's content is missing then call the FM
  IF <lfs_buyer_doc> IS ASSIGNED.
    IF <lfs_buyer_doc>-id-content IS INITIAL.

*Method is a copy of Function Module "GENERAL_GET_RANDOM_STRING"
*It is used to generate a random 35 character Purchase Order Number
      CALL METHOD me->generate_random_po
        EXPORTING
          im_number_chars  = lc_number_chars
        IMPORTING
          ex_random_string = lv_po_number.

*Populating the Customer Purchase order number with the 35 character
* Random string generated by the FM.
      cs_head_comv-bstkd = lv_po_number.
*Passing value X for purchase order number
      cs_head_comx-bstkd = abap_true. "X

    ENDIF. " IF <lfs_buyer_doc>-id-content IS INITIAL
  ENDIF. " IF <lfs_buyer_doc> IS ASSIGNED

* <--- End   of Change for CR D2_437, D2_OTC_IDD_0095 by SGUPTA4


* FREIGHT CALC FOR ONE TIME CUSTOMER  ONLY NEEDED FOR ZWEB ORDER TYPE
* MAINTIANED IN EMI TOOL.

* ---> Begin of Delete for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4

*Begin of CR D2_302
** Call to EMI Function Module To Get List Of EMI Statuses
*  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
*    EXPORTING
*      iv_enhancement_no = lc_idd_0095_001 "D2_OTC_IDD_0095_002
*    TABLES
*      tt_enh_status     = li_status1.      "Enhancement status table
*
**Non active entries are removed.
*  DELETE li_status1 WHERE active EQ abap_false.


**End of CR D2_302
* <--- End   of Delete for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4

* Call to EMI Function Module To Get List Of EMI Statuses
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
* ---> Begin of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
*      iv_enhancement_no = lc_idd_0095_002 "D2_OTC_IDD_0095_002
      iv_enhancement_no = lc_idd_0095_0001 "D2_OTC_IDD_0095_0001
* <--- End   of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
    TABLES
      tt_enh_status     = li_status. "Enhancement status table


*Non active entries are removed.
  DELETE li_status WHERE active EQ abap_false.


*First of all criteria “NULL” in LI_STATUS is checked ,If it has Active flag as “X”.
*Binary search not done as numnber of entries are less
  READ TABLE li_status WITH KEY criteria = lc_null "NULL
                       TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
* Validate Input order type with one maintained in EMI.
    READ TABLE li_status WITH KEY criteria = lc_auart "AUART
                                  sel_low  = is_input-sales_order_erpcreate_check_q-sales_order-processing_type_code
                         TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
*Binary search not done as numnber of entries are less.
*Taking ship to customer in input structure to local variable.
      READ TABLE li_party ASSIGNING <lfs_party> WITH KEY role_code = lc_ship_to. "WE
      IF sy-subrc = 0.
        lv_ship_once = <lfs_party>-internal_id-content. "One time ship to cusotmer
 "Applyin conversion exit on One time ship to cusotmer
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_ship_once
          IMPORTING
            output = lv_ship_once.
*Fetching customer and it's corresponding one time indicator
*from KNA1.
        SELECT SINGLE
               kunnr "Customer Number
               xcpdk " Indicator: Is the account a one-time account?
        FROM kna1    " General Data in Customer Master
        INTO (lv_kunnr,lv_xcpdk)
        WHERE kunnr = lv_ship_once.
        IF sy-subrc EQ 0.
          IF lv_xcpdk EQ abap_true. "X
*If it's one time customer
*CT_PARTY_COMV cannot be sorted,hence BINARY SEARCH not done.
            READ TABLE ct_party_comv ASSIGNING <lfs_party_comv> WITH KEY parvw = lc_ship_to "WE
                                                                         cntpa = lc_000000. "000000
            IF sy-subrc EQ 0.
              lv_index = sy-tabix.
              <lfs_party_comv>-kunnr    = lv_kunnr.
              <lfs_party_comv>-city     = <lfs_party>-z01otc_zaddress-physical_address-city_name. "City name
              <lfs_party_comv>-region   = <lfs_party>-z01otc_zaddress-physical_address-region_code-content. "Region code.
              <lfs_party_comv>-country  = <lfs_party>-z01otc_zaddress-physical_address-country_code. "Country code.
              <lfs_party_comv>-city2    = space. "County code-Clearing the variable value
            ENDIF. " IF sy-subrc EQ 0

*CT_PARTY_COMX cannot be sorted,hence BINARY SEARCH not done.
            READ TABLE ct_party_comx ASSIGNING <lfs_party_comx> INDEX lv_index.
            IF sy-subrc EQ 0.
              <lfs_party_comx>-kunnr    = abap_true. "X
              <lfs_party_comx>-city     = abap_true. "X
              <lfs_party_comx>-region   = abap_true. "X
              <lfs_party_comx>-country  = abap_true. "X
              <lfs_party_comx>-city2    = abap_true. "X
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0

*Begin of CR D2_302
    CONCATENATE lc_sales_office lv_sales_org INTO lv_sales_office SEPARATED BY lc_underscr.

* ---> Begin of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
*  READ TABLE li_status1  ASSIGNING <lfs_status>  WITH KEY criteria = lv_sales_office
*                                                           active = abap_true.
    READ TABLE li_status  ASSIGNING <lfs_status>  WITH KEY criteria = lv_sales_office
                                                             active = abap_true.
* <--- End   of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4

    IF sy-subrc = 0.
      cs_head_comv-vkbur  = <lfs_status>-sel_low.
      cs_head_comx-vkbur  = abap_true.
    ENDIF. " IF sy-subrc = 0
*End of CR D2_302
  ENDIF. " IF is_input-sales_order_erpcreate_check_q-sales_order-goods_recipient_party-internal_id-content IS NOT INITIAL
*************************************
*SERIAL NUMBER VALIDATION.

  LOOP AT li_item ASSIGNING <lfs_item>.
    CLEAR :lv_index.
    lv_index = sy-tabix.

*Taking all Material No's and batch no's  into a Internal table
* ---> Begin of Change for Defect 1445 by MBAGDA
    IF <lfs_item>-product-batch_id-content IS NOT INITIAL.
* <--- End of Change for Defect 1445 by MBAGDA
      lwa_matbatch_quan-matnr   = <lfs_item>-product-internal_id-content. "Material no.
      lwa_matbatch_quan-charg   = <lfs_item>-product-batch_id-content. "Batch no.
* ---> Begin of Change for CR D2_93 by HBADLAN
      lwa_matbatch_quan-item_id = <lfs_item>-buyer_document-item_id.
* <--- End of Change/Insert/Delete for CR D2_93 by HBADLAN

*--Stanadard Transformation prefix leading zeros in Batch number, which creates problem
*  in the back-end. Hence directly assiging the Input values from request
      READ TABLE ct_item_comv ASSIGNING <lfs_item_comv> INDEX lv_index.
      IF sy-subrc = 0.
        <lfs_item_comv>-charg = <lfs_item>-product-batch_id-content. "Batch no.
      ENDIF. " IF sy-subrc = 0

      lwa_matbatch_quan-req_qty = <lfs_item>-total_values-requested_quantity-content.
      APPEND lwa_matbatch_quan TO li_matbatch_quan.
      CLEAR lwa_matbatch_quan.
    ENDIF. " IF <lfs_item>-product-batch_id-content IS NOT INITIAL

*Making an internal table of Material and their corresponding serial Numbers.
    lwa_matser-matnr = <lfs_item>-product-internal_id-content. "Material no.
* ---> Begin of Change for CR D2_93 by HBADLAN
    lwa_matser-item_id = <lfs_item>-buyer_document-item_id.
* <--- End of Change for CR D2_93 by HBADLAN

    CLEAR: li_serial[]. "Def 5169-MBAGDA
    APPEND LINES OF <lfs_item>-product-z01otc_zserial_no TO li_serial.
    LOOP AT li_serial ASSIGNING <lfs_serial>.
* ---> Begin of Change for Defect 1445 by MBAGDA
      IF <lfs_item>-product-z01otc_zserial_no IS NOT INITIAL.
* <--- End of Change for Defect 1445 by MBAGDA
*Conversion exit on serial numbes.
        CALL FUNCTION 'CONVERSION_EXIT_GERNR_INPUT'
          EXPORTING
            input  = <lfs_serial>-sernr
          IMPORTING
            output = <lfs_serial>-sernr.
        lwa_matser-sernr = <lfs_serial>-sernr.
        APPEND lwa_matser TO li_matser.
        CLEAR lwa_matser-sernr.
      ENDIF. " IF <lfs_item>-product-z01otc_zserial_no IS NOT INITIAL
    ENDLOOP. " LOOP AT li_serial ASSIGNING <lfs_serial>
    CLEAR lwa_matser.
*---> Begin of Change for Defect 5169 by MBAGDA
*-- Validate Serial Numbers
    IF li_matser[] IS NOT INITIAL.
      CALL FUNCTION 'ZOTC_SERIAL_NUM_VALIDATE'
        EXPORTING
          im_vkorg              = lv_sales_org "Sales org
          im_vtweg              = lv_dist_chan "Distribution chaneel
          im_kunnr              = lv_ship_to   "Ship to customer
          im_matser_tab         = li_matser    "Material,serial num combination table
        IMPORTING
          ex_serial_msg         = li_serial_msg
        EXCEPTIONS
          invalid_serial_number = 1.           " Def# 2892-mbagda

      IF li_serial_msg IS NOT INITIAL.
        APPEND LINES OF li_serial_msg TO ct_message_log.
      ENDIF. " IF li_serial_msg IS NOT INITIAL
      CLEAR: li_serial_msg[], li_matser[].
    ENDIF. " IF li_matser[] IS NOT INITIAL
* <--- End of Change for Defect 5169 by MBAGDA
  ENDLOOP. " LOOP AT li_item ASSIGNING <lfs_item>

* ---> Begin of Change for Defect 5169 by MBAGDA
**FM to validate serial numbers
*  IF li_matser[] IS NOT INITIAL.
*    CALL FUNCTION 'ZOTC_SERIAL_NUM_VALIDATE'
*      EXPORTING
*        im_vkorg         = lv_sales_org "Sales org
*        im_vtweg         = lv_dist_chan "Distribution chaneel
** ---> Begin of Change for Defect 1445 by MBAGDA
**       im_kunnr      = lv_sold_to   "Sold to customer
*        im_kunnr          = lv_ship_to "Ship to customer
** <--- End of Change for Defect 1445 by MBAGDA
*        im_matser_tab     = li_matser "Material,serial num combination table
*      IMPORTING
*        ex_serial_msg = li_serial_msg
*      EXCEPTIONS
*        invalid_serial_number = 1.    " Def# 2892-mbagda
*
*    IF li_serial_msg IS NOT INITIAL.
*      APPEND LINES OF li_serial_msg TO ct_message_log.
*    ENDIF. " IF li_serial_msg IS NOT INITIAL
*  ENDIF. " IF li_matser[] IS NOT INITIAL
* <--- End of Change for Defect 5169 by MBAGDA

*****************************
*BATCH VALIDATION
  IF li_matbatch_quan[] IS NOT INITIAL.
*Once batch number itself has been validated it needs be ensured the material with
*the valid batch number has indeed been shipped to the customer consigned stock.
    CALL FUNCTION 'ZOTC_BATCH_ID_VALIDATE'
      EXPORTING
        im_vkorg         = lv_sales_org     "Sales org
        im_vtweg         = lv_dist_chan     "Distribution channel
        im_kunnr         = lv_ship_to       "Ship to customer
        im_matbatch_quan = li_matbatch_quan "Material,Batch combination table.
      IMPORTING
        ex_batch_msg     = li_batch_msg
* ---> Begin of Insert for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4
      EXCEPTIONS
        invalid_batch = 1.
* <--- End   of Insert for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4

    IF li_batch_msg IS NOT INITIAL.
      APPEND LINES OF li_batch_msg TO ct_message_log.
    ENDIF. " IF li_batch_msg IS NOT INITIAL
  ENDIF. " IF li_matbatch_quan[] IS NOT INITIAL
ENDMETHOD.


METHOD if_sls_appl_se_soerpcrtchkqr~outbound_processing.
***********************************************************************
*Program    : IF_SLS_APPL_SE_SOERPCRTCHKQR~OUTBOUND_PROCESSING        *
*Title      : ES Sales Order Simulation                               *
*Developer  : Harshit Badlani                                         *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0095                                           *
*---------------------------------------------------------------------*
*Description:Simulate Sales Order to retrieve ATP information, prices,*
*            taxes and handling charges for subscribing applications  *
*
*CR D2_93  :In order to support EVO application to alert a web user   *
*for any error message returned by SAP at a line item level, the      *
*response XML is enhanced so that EVO can parse out messages per item *
*and alert user to take appropriate action                            *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*16-May-2014  HBADLAN      E2DK900468      INITIAL DEVELOPMENT
*30-SEP-2014  HBADLAN      E2DK900468      CR D2_93
*11-NOV-2014  HBADLAN      E2DK900468      DEFECT 1035 and 1159
*09-JAN-2015  SGUPTA4      E2DK900468      Defect#2892, Displaying
*                                          ZReferenceID for warning
*                                          messages also.
*21-JAN-2014  SGUPTA4      E2DK900468      Defect#3128,Making EMI     *
*                                          enhancement number unique. *
*---------------------------------------------------------------------*

*Local data declarations
  DATA: lwa_output_item   TYPE sapplco_log_item,                  "Protocol message issued by an application
        lv_emi_active     TYPE flag,                              "Check if Enhancement is active
        lv_note           TYPE sapplco_log_item_note,             "A short text for the log message
        li_item           TYPE tdt_item_comv,                     "Item local internal Table
        li_status         TYPE STANDARD TABLE OF zdev_enh_status, "Enhancement Status table
        li_output_item    TYPE sapplco_log_item_tab,              "protocol message issued by an application
        li_contract_data  TYPE zotc_t_reagent_rental,             "Table  for Re-agent rental contracts data
        li_matnr          TYPE table_matnr,                       " Material Number
        li_temp           TYPE bapirettab,
        lv_contract_count TYPE i.                                 " Contract_count of type Integers

  FIELD-SYMBOLS: <lfs_criteria_field> TYPE any,                   "FS declared as any as it can takes value of any of criteria field
                 <lfs_contract>       TYPE zotc_reagent_rental_s, "Output strcuture for Re-agent rental contracts determination
                 <lfs_status>         TYPE zdev_enh_status,       "Enhancement Status
                 <lfs_bapiret>        TYPE bapiret2,              " Return Parameter
                 <lfs_log>            TYPE sapplco_log_item,      " protocol message issued by an application
                 <lfs_item>           TYPE tds_item_comv.         "Lean Order - Item Data (Values)

  CONSTANTS : lc_null          TYPE z_criteria                       VALUE 'NULL',                " Enh. Criteria
* ---> Begin of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
*              lc_idd_0095_001  TYPE z_enhancement                    VALUE 'D2_OTC_IDD_0095_001', " Enhancement No.
              lc_idd_0095_0002  TYPE z_enhancement                    VALUE 'D2_OTC_IDD_0095_0002', " Enhancement No.
* <--- End   of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
              lc_error_code    TYPE sapplco_log_item_severity_code   VALUE '3',                   " Proxy Data Element (Generated)
              lc_sev_code_2    TYPE sapplco_log_item_severity_code   VALUE '2',                   " Proxy Data Element (Generated)
* ---> Begin of Change for Def# 1035 and 1159 by HBADLAN
              lc_zero          TYPE sapplco_amount_content           VALUE '0'. " Proxy Data Element (Generated)
*<--- End of Change for Def# 1035 and 1159 by HBADLAN

* Call to EMI Function Module To Get List Of EMI Statuses
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
* ---> Begin of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
*      iv_enhancement_no = lc_idd_0095_001 "D2_OTC_IDD_0095_001
      iv_enhancement_no = lc_idd_0095_0002 "D2_OTC_IDD_0095_0002
* <--- End   of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
    TABLES
      tt_enh_status     = li_status.      "Enhancement status table


*first thing is to check for field criterion,for value “NULL” and field Active value:
*i.If the value is: “X”, the overall Enhancement is active and can proceed further for checks
*ii.If the  value is:space, then do not proceed further for this enhancement

  READ TABLE li_status WITH KEY criteria = lc_null "NULL
                                active = abap_true "X"
                       TRANSPORTING NO FIELDS.
  IF sy-subrc NE  0.
    CLEAR lv_emi_active.
  ELSE. " ELSE -> IF sy-subrc NE 0

    DELETE li_status WHERE criteria EQ lc_null.
* Now check for each criteria if enhancement is active or not
    LOOP AT li_status ASSIGNING <lfs_status>.
      UNASSIGN <lfs_criteria_field>.
* the assumption is that the criteria is from the header of the document
      ASSIGN COMPONENT <lfs_status>-criteria  OF STRUCTURE is_head_comv TO <lfs_criteria_field>.
      IF sy-subrc EQ 0.
        IF <lfs_criteria_field> IS ASSIGNED.
* compare the value in EMI table with that of the input field
          IF <lfs_criteria_field>  =   <lfs_status>-sel_low.
            lv_emi_active = abap_true.
          ELSE. " ELSE -> IF <lfs_criteria_field> = <lfs_status>-sel_low
            CLEAR lv_emi_active.
            EXIT.
          ENDIF. " IF <lfs_criteria_field> = <lfs_status>-sel_low
        ELSE. " ELSE -> IF <lfs_criteria_field> IS ASSIGNED
          CLEAR lv_emi_active.
          EXIT.
        ENDIF. " IF <lfs_criteria_field> IS ASSIGNED
      ENDIF. " IF sy-subrc EQ 0
    ENDLOOP. " LOOP AT li_status ASSIGNING <lfs_status>
  ENDIF. " IF sy-subrc NE 0

*If EMI_ACTIVE flag variable is 'X' then excute enhancement
*and validate each item for multiple contracts
  IF  lv_emi_active = abap_true.

    CLEAR li_item[].
*Moving item data into a local table and keeping unique Material no.
* entries in it.
    li_item[] = it_item_comv[].
    IF li_item[] IS NOT INITIAL.
      SORT li_item BY mabnr.
      DELETE ADJACENT DUPLICATES FROM li_item COMPARING mabnr.

*Moving only unique material no. to a Internal table.
      LOOP AT li_item ASSIGNING <lfs_item>.
        APPEND <lfs_item>-mabnr TO li_matnr.
      ENDLOOP. " LOOP AT li_item ASSIGNING <lfs_item>

*Calling FM for Re-agent rental contracts determination
      CALL FUNCTION 'ZOTC_DETERMINE_REAGENT_RENTAL'
        EXPORTING
          im_vkorg         = is_head_comv-vkorg "Sales org
          im_vtweg         = is_head_comv-vtweg "Distribution channel
          im_spart         = is_head_comv-spart "Divison
          im_sold_to       = is_head_comv-kunag "Sold to party
          im_ship_to       = is_head_comv-kunwe "Ship to party
          im_matnr_tab     = li_matnr           "Material Table
        IMPORTING
          ex_contract_data = li_contract_data.  "Table for contract data

*Validating each and every item :
*(a).If unique contract exists no action required
*(b).If multiple contract exists then return warning message

      SORT li_contract_data BY matnr.
      LOOP AT it_item_comv ASSIGNING <lfs_item>.
        READ TABLE li_contract_data ASSIGNING <lfs_contract> WITH KEY matnr = <lfs_item>-mabnr
                                                             BINARY SEARCH .
*If count of no. of contracts per material Greater than 1 then populate warning message
        IF sy-subrc EQ 0 .
          IF lv_contract_count GT 1.
*Message  : Multiple contracts found for item & and Material & .
            MESSAGE s136(zotc_msg)    " Multiple contracts found for item & and Material & .
               WITH  <lfs_item>-posnr "Item no.
                     <lfs_item>-mabnr "Material No.
               INTO lv_note.

            lwa_output_item-note = lv_note.
            lwa_output_item-type_id = '136(ZOTC_MSG)'.
            lwa_output_item-severity_code = lc_sev_code_2.
            APPEND lwa_output_item TO li_output_item.
          ENDIF. " IF lv_contract_count GT 1
        ENDIF. " IF sy-subrc EQ 0
*Clearing work areas.
        CLEAR :  lwa_output_item.
      ENDLOOP. " LOOP AT it_item_comv ASSIGNING <lfs_item>

*Appending messages per item into output log.
      IF li_output_item IS NOT INITIAL.
        APPEND LINES OF li_output_item TO cs_output-sales_order_erpcreate_check_r-log-item.
      ENDIF. " IF li_output_item IS NOT INITIAL
    ENDIF. " IF li_item[] IS NOT INITIAL
  ENDIF. " IF lv_emi_active = abap_true


* ---> Begin of Change for Def# 1035 and 1159 by MBAGDA
* If the Total Net Amount is Zero then set the value for these fields as zero:
* a. Gross Amount
* b. Tax Amount
  IF cs_output-sales_order_erpcreate_check_r-sales_order-total_values-net_amount-content = lc_zero.

    cs_output-sales_order_erpcreate_check_r-sales_order-total_values-gross_amount-content = lc_zero.
    cs_output-sales_order_erpcreate_check_r-sales_order-total_values-tax_amount-content = lc_zero.
  ENDIF. " IF cs_output-sales_order_erpcreate_check_r-sales_order-total_values-net_amount-content = lc_zero

*<--- End of Change for Def# 1035 and 1159 by MBAGDA

* ---> Begin of Change for CR:D2_93 by HBADLAN
  li_temp = ct_message_log.
*Checking for error entries in CS_OUTPUT. CS_OUTPUT needs to be modified hence
*LOOP WHERE check can't be removed.

  LOOP AT cs_output-sales_order_erpcreate_check_r-log-item ASSIGNING <lfs_log>
* ---> Begin of Change for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4
*                                                           WHERE severity_code = lc_error_code.
                                                           WHERE severity_code = lc_error_code or
                                                                 severity_code = lc_sev_code_2.
* <--- End of Change for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4

    READ TABLE li_temp ASSIGNING <lfs_bapiret> WITH KEY message =  <lfs_log>-note.
    IF sy-subrc EQ 0.
      READ TABLE it_item_comv ASSIGNING <lfs_item> WITH KEY handle = <lfs_bapiret>-parameter.
      IF sy-subrc EQ 0.
        <lfs_log>-z01otc_zreference_id = <lfs_item>-posex.
* Clear is done because in order to pick right item If there are multiple line items with
* same error message  else 1st item will be picked again.
        CLEAR <lfs_bapiret>.
      ELSEIF is_head_comv-handle = <lfs_bapiret>-parameter.
        CLEAR <lfs_log>-z01otc_zreference_id.
      ELSE. " ELSE -> IF sy-subrc EQ 0
        <lfs_log>-z01otc_zreference_id = <lfs_bapiret>-parameter.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
  ENDLOOP. " LOOP AT cs_output-sales_order_erpcreate_check_r-log-item ASSIGNING <lfs_log>
* <--- End of Change/ for CR D2_93 by HBADLAN.

ENDMETHOD.


method IF_SLS_APPL_SE_SOERPCRTCHKQR~OUTPUT_ADAPTION.
***********************************************************************
*Program    : IF_SLS_APPL_SE_SOERPCRTCHKQR~OUTPUT_ADAPTION            *
*Title      : ES Sales Order Simulation                               *
*Developer  : Harshit Badlani                                         *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0095                                           *
*---------------------------------------------------------------------*
*Description:Simulate Sales Order to retrieve ATP information, prices,
*            taxes and handling charges for subscribing applications  *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*16-May-2014  HBADLAN      E2DK900468      INITIAL DEVELOPMENT
*---------------------------------------------------------------------*

*This method not needed for this development
endmethod.
ENDCLASS.
