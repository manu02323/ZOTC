class ZCL_IM_OTC_ORDER_STATUS definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_SLS_APPL_SE_SOERPIDQR3 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_OTC_ORDER_STATUS IMPLEMENTATION.


METHOD if_sls_appl_se_soerpidqr3~inbound_processing.
************************************************************************
* Method  : IF_SLS_APPL_SE_SOERPIDQR3~INBOUND_PROCESSING (proxy method)*
* TITLE      :  Get Order Status                                       *
* DEVELOPER  :  Abhishek Gupta3                                        *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D2_OTC_IDD_0092_SAP                                      *
*----------------------------------------------------------------------*
* DESCRIPTION: Population of Sales Order number based on Web Ref ID    *
*               and Document ID                                        *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT  DESCRIPTION                        *
* ===========  ========  ========== ===================================*
* 02-June-2014  AGUPTA3  E2DK900484 Initial Development                *
* 22-Jul-2014   AGUPTA3  E2DK900484 CR_D2_50                           *
*                                                                      *
*&---------------------------------------------------------------------*
  TYPES: BEGIN OF lty_vbak,
         vbeln    TYPE vbeln,    " Sales and Distribution Document Number
         zzdocref TYPE z_docref, " Legacy Doc Ref
         zzdoctyp TYPE z_doctyp, " Ref Doc type
         END OF lty_vbak.

  DATA: lv_sales_ord TYPE vbeln,                             " Sales and Distribution Document Number
        lv_docref    TYPE z_docref,                          " Legacy Doc Ref
        lv_doc_typ   TYPE z_doctyp,                          " Ref Doc type
        lwa_docref   TYPE lty_vbak,                          "Web Ref ID
        lv_error     TYPE char1,                             " Error of type CHAR1
        lwa_message  TYPE bapiret2,                          " Return Parameter
        li_dev_stat  TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
        lv_msg_v1    TYPE string.

  CONSTANTS: lc_msg_typ TYPE bapi_mtype VALUE 'E',                      " Message Class
             lc_msg_std TYPE symsgid VALUE 'V_OPS_SE_SLS',              " Message Class
             lc_msg_otc TYPE symsgid VALUE 'ZOTC_MSG',                  " Message Class
             lc_msg_num TYPE symsgno VALUE '105',                       " Message Number
             lc_msg_num1 TYPE symsgno VALUE '152',                      " Message Number
             lc_null    TYPE z_criteria    VALUE 'NULL',                " Enh. Criteria
            lc_dev_stat TYPE z_enhancement VALUE 'D2_OTC_IDD_0092_001'. " Enhancement No.


  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_dev_stat
    TABLES
      tt_enh_status     = li_dev_stat.

*first thing is to check for field criterion,for value “NULL” and field Active value:
*i.If the value is: “X”, the overall Enhancement is active and can proceed further for checks
*ii.If the  value is:space, then do not proceed further for this enhancement

  READ TABLE li_dev_stat WITH KEY criteria = lc_null "NULL
                                  active = abap_true "X"
                       TRANSPORTING NO FIELDS.
  IF sy-subrc EQ  0.

    CLEAR: lv_msg_v1.

**Get sales order ID
    lv_sales_ord = is_input-sales_order_erpby_idquery_syn-sales_order_erpselection_by_id-id-content.

**get Web Ref ID
    lv_docref = is_input-sales_order_erpby_idquery_syn-sales_order_erpselection_by_id-z01otc_zdocref.
    lv_doc_typ = is_input-sales_order_erpby_idquery_syn-sales_order_erpselection_by_id-z01otc_zdoctyp.

    CLEAR: lv_error.

* ---> Begin of Change for D2_OTC_IDD_0092_CR_D2_50 by MBAGDA

**Delete existing message for missing ID
    DELETE ct_message_log WHERE type   = lc_msg_typ " Message_log where of type
                            AND id     = lc_msg_std
                            AND number = lc_msg_num.
* ---> End of Change for D2_OTC_IDD_0092_CR_D2_50 by MBAGDA

    IF lv_sales_ord IS INITIAL AND
       lv_docref IS NOT INITIAL.

**Get sales document from VBAK
      SELECT
          vbeln    " Sales Document
          zzdocref " Legacy Doc Ref
          zzdoctyp " Ref Doc type
        UP TO 1 ROWS
        FROM vbak  " Sales Document: Header Data
        INTO lwa_docref
        WHERE zzdocref = lv_docref
        AND   zzdoctyp = lv_doc_typ.
      ENDSELECT.

      IF sy-subrc = 0.
**Populate sales Order ID
        cv_sales_order_id = lwa_docref-vbeln.
      ELSE. " ELSE -> IF sy-subrc = 0
**error
* ---> Begin of Change for D2_OTC_IDD_0092_CR_D2_50 by AGUPTA3
        CONCATENATE 'Web Reference ID'(003) lv_docref
         INTO lv_msg_v1 SEPARATED BY space.
* ---> End of Change for D2_OTC_IDD_0092_CR_D2_50 by AGUPTA3
        lv_error = abap_true.
      ENDIF. " IF sy-subrc = 0
    ELSEIF lv_sales_ord IS NOT INITIAL AND
           lv_docref IS INITIAL.

**Get sales document from VBAK
      SELECT SINGLE
          vbeln    " Sales Document
          zzdocref " Legacy Doc Ref
          zzdoctyp " Ref Doc type
        FROM vbak  " Sales Document: Header Data
        INTO lwa_docref
        WHERE vbeln = lv_sales_ord.

      IF sy-subrc = 0.
        cv_sales_order_id = lwa_docref-vbeln.
      ELSE. " ELSE -> IF sy-subrc = 0
* ---> Begin of Change for D2_OTC_IDD_0092_CR_D2_50 by AGUPTA3
*        CONCATENATE 'Sales Doc'(001) lv_sales_ord 'And'(002)
        CONCATENATE 'Sales Doc'(001) lv_sales_ord
* ---> Begin of Change for D2_OTC_IDD_0092_CR_D2_50 by AGUPTA3
          INTO lv_msg_v1 SEPARATED BY space.
        lv_error = abap_true.
      ENDIF. " IF sy-subrc = 0

    ELSEIF lv_sales_ord IS NOT INITIAL AND
           lv_docref IS NOT INITIAL.

**Get sales document from VBAK
      SELECT SINGLE
          vbeln    " Sales Document
          zzdocref " Legacy Doc Ref
          zzdoctyp " Ref Doc type
        FROM vbak  " Sales Document: Header Data
        INTO lwa_docref
        WHERE vbeln = lv_sales_ord
        AND   zzdocref = lv_docref
        AND   zzdoctyp = lv_doc_typ.

      IF sy-subrc = 0.
        cv_sales_order_id = lwa_docref-vbeln.
      ELSE. " ELSE -> IF sy-subrc = 0
* ---> Begin of Change for D2_OTC_IDD_0092_CR_D2_50 by AGUPTA3
*        CONCATENATE 'Sales Doc'(001) lv_sales_ord 'And'(002)
        CONCATENATE 'Sales Doc'(001) lv_sales_ord 'And'(002) 'Web Reference ID'(003) lv_docref
* ---> End of Change for D2_OTC_IDD_0092_CR_D2_50 by AGUPTA3
          INTO lv_msg_v1 SEPARATED BY space.
        lv_error = abap_true.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF lv_sales_ord IS INITIAL AND

**populate error
    IF lv_error = abap_true.
      lwa_message-type   = lc_msg_typ.
      lwa_message-id     = lc_msg_otc.
      lwa_message-number = lc_msg_num1.
      lwa_message-message_v1 = lv_msg_v1.
* ---> Begin of delete for D2_OTC_IDD_0092_CR_D2_50 by AGUPTA3
*      lwa_message-message_v2 = lv_docref.
* ---> Begin of delete for D2_OTC_IDD_0092_CR_D2_50 by AGUPTA3
      APPEND lwa_message TO ct_message_log.
    ENDIF. " IF lv_error = abap_true

  ENDIF. " IF sy-subrc EQ 0
ENDMETHOD.


METHOD if_sls_appl_se_soerpidqr3~outbound_processing.
************************************************************************
* Method  : IF_SLS_APPL_SE_SOERPIDQR3~OUTBOUND_PROCESSING(Proxy method)*
* TITLE      :  Get Order Status                                       *
* DEVELOPER  :  Abhishek Gupta3                                        *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D2_OTC_IDD_0092_SAP                                      *
*----------------------------------------------------------------------*
* DESCRIPTION: Population of shipped date and shipped quantity         *
*              also planned date and confirmed quantity along with     *
*              tracking number and Invoices.                           *
*CR D2_146 : Add Name3/Building/Floor/Room/Suite/Street2 to response   *
*            for SP, SH and BP functions.                              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT  DESCRIPTION                        *
* ===========  ========  ========== ===================================*
* 02-June-2014  AGUPTA3  E2DK900484 Initial Development                *
*&---------------------------------------------------------------------*
* 10-Nov-2014   HBADLAN  E2DK900484 CR D2_146                          *
*&---------------------------------------------------------------------*
* 20-Nov-2013   SGUPTA4  E2DK900484 Defect#1843, Added Partner Function*
*                                   'Payer' i.e RG and Value of  Bill  *
*                                   to party constant was changed to RE*
*&---------------------------------------------------------------------*
* 16-Dec-2014   DMOIRAN E2DK900484 Defect#1956. Get Z015 text and      *
*                                  pouplate it.                        *
*&---------------------------------------------------------------------*
* 7-Jan-2015   DMOIRAN E2DK900484 Defect#1956 2nd change for Z015 text *
* 22-Jan-2015   NBAIS    E2DK900484 Defect 3084/3086 – CR 447 (As per  *
*                                    defect 3084: For Tracking no      *
*                                    instead of SPE IDENT 01           *
*                                    now we will check SPE IDENT 01,   *
*                                    SPE IDENT 02,SPE IDENT 03,        *
*                                    SPE IDENT 04.                     *
*                                    defect:3086:For 3rd Party delivery*
*                                    "Tracking number" will be populate*
*                                    by LIKP-LIFEX instead of BOLNR.   *
* 16-Apr-2015  DMOIRAN  E2DK900484   Defect 5842 - In case of 3rd party and
* delivery based scenario in same sales order route id is incorrectly fetched.
*&---------------------------------------------------------------------*


***Structure for header data
  TYPES: BEGIN OF lty_head,
           vbeln    TYPE vbeln_va, " Sales Document
           erzet    TYPE erzet,    " Entry time
* ---> Begin of Insert for Defect 1956 by DMOIRAN
           bsark    TYPE bsark, " Customer purchase order type
* <--- End    of Insert for Defect 1956 by DMOIRAN
           zzdocref TYPE z_docref, " Legacy Doc Ref
         END OF lty_head,
**structure for item data
         BEGIN OF lty_vbap,
            vbeln TYPE vbeln_va,   " Sales Document
            posnr TYPE posnr_va,   " Sales Document Item
            posex TYPE posex,      " Item Number of the Underlying Purchase Order
       zzquoteref TYPE z_quoteref, " Legacy Qtn Ref
         END OF lty_vbap.

***Local data declaration
  DATA: lv_order_num  TYPE vbeln,                             " Sales and Distribution Document Number
        lwa_order     TYPE zotc_sales_ordr,                   " Sales Order Number
        lwa_head      TYPE lty_head,                          "Header data
        li_item       TYPE sapplco_sls_ord_erpby_id_tab10,    "Proxy Item
        li_invoice    TYPE zotc_order_invc_tbl,               "Invoice
        li_invoic_list TYPE z01otc_dte_invoice_res_zin_tab,   "Invoice list
        li_status     TYPE zotc_put_ordr_status_tbl,          "Order status
        li_order      TYPE zotc_sales_ordr_tbl,               "Order detail
        li_ship_data  TYPE zotc_delv_data,                    "Shipping data
        li_itm_tmp    TYPE z01otc_dte_item_data_res_z_tab,    "Temp table for Item
        li_zitem      TYPE zotc_schline,                      "Schedule line data
        li_temp       TYPE sapplco_sls_ord_erpby_idr_tab2,    "temp Proxy Item
        li_vbap       TYPE STANDARD TABLE OF lty_vbap,        "Item data
        lwa_zitm      TYPE z01otc_dte_item_data_res_zitem,    " Proxy Structure (generated)
        lv_net        TYPE sapplco_amount_content,            " Proxy Data Element (Generated)
        lv_tax        TYPE sapplco_amount_content,            " Proxy Data Element (Generated)
        lv_handle_amt TYPE sapplco_amount_content,            " Proxy Data Element (Generated)
        lv_ship_amt   TYPE sapplco_amount_content,            " Proxy Data Element (Generated)
        lv_total      TYPE sapplco_amount_content,            " Proxy Data Element (Generated)
        lv_langu      TYPE char2,                             " Language of type CHAR2
        lv_curr       TYPE sapplco_currency_code,             " Proxy Data Element (Generated)
        li_dev_stat   TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
* ---> Begin of Insert for Defect 1956 by DMOIRAN
        lv_posnr      TYPE posnr_va, " Sales Document Item
        lv_tdname     TYPE tdobname, " Name
        lv_spras      TYPE spras,    " Language Key
        lv_space      TYPE flag,     " General Flag
        lv_string     TYPE string,   "line item text
        li_tdline     TYPE tlinetab, "line item text in tdline length
* ---> Begin of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS
        lv_flag       TYPE char1. "to check the delivery based scenario
* <--- End of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS
* <--- End    of Insert for Defect 1956 by DMOIRAN

  CONSTANTS: lc_ztfr   TYPE sapplco_price_specification_el VALUE 'ZTFR',        " Proxy Datenelement (generiert)
             lc_handle TYPE sapplco_medium_name_content VALUE 'Total Handling', " Proxy Data Element (Generated)
             lc_null    TYPE z_criteria    VALUE 'NULL',                        " Enh. Criteria
             lc_dev_stat TYPE z_enhancement VALUE 'D2_OTC_IDD_0092_001',        " Enhancement No.
             lc_stat_can TYPE wbstk         VALUE '5',                          " Total goods movement status
* ---> Begin of Insert for Defect 1956 by DMOIRAN
             lc_z015      TYPE tdid VALUE 'Z015',     " Text ID
             lc_e         TYPE spras VALUE 'E',       " Language Key
             lc_obj_vbbp  TYPE tdobject VALUE 'VBBP', " Texts: Application Object
             lc_zweb      TYPE bsark    VALUE 'ZWEB'. " Customer purchase order type
* <--- End    of Insert for Defect 1956 by DMOIRAN


**Field symbols
  FIELD-SYMBOLS: <lfs_invc>   TYPE zotc_order_invc,                 " Sales Order and Invoice List
                 <lfs_stat>   TYPE zotc_put_status_struc,           " Structure to Return Status with Order List
                 <lfs_ship>   TYPE zotc_get_delv_data,              " Get delivery date and Quantity
                 <lfs_ship_1> TYPE zotc_get_schline,                " Schedule line data
                 <lfs_vbap>   TYPE lty_vbap,                        "Item data
                 <lfs_item>   TYPE sapplco_sls_ord_erpby_idrsp_62,  " IDT SlsOrdERPByIDRsp_s_V3Itm
                <lfs_ship_amt> TYPE sapplco_sls_ord_erpby_idrsp_19, " IDT SlsOrdERPByIDRsp_s_V3PrComp
               <lfs_hadle_amt> TYPE sapplco_sls_ord_erpby_idrsp_19, " IDT SlsOrdERPByIDRsp_s_V3PrComp
* ---> Begin of Insert for Defect 1956 by DMOIRAN
                  <lfs_text>    TYPE sapplco_sls_ord_erpby_idrsp_s4, " IDT SlsOrdERPByIDRsp_s_V3TxtCollTxt
                  <lfs_t_text>  TYPE sapplco_sls_ord_erpby_idrs_tab, "table for text
                  <lfs_tdline>  TYPE tline.                          " SAPscript: Text Lines
* <--- End    of Insert for Defect 1956 by DMOIRAN

* ---> Begin of Change for CR D2_146 by HBADLAN
  TYPES : BEGIN OF lty_adrc,
          addrnumber TYPE ad_addrnum, " Address number
          date_from  TYPE ad_date_fr, " Valid-from date - in current Release only 00010101 possible
          nation     TYPE ad_nation,  " Version ID for International Addresses
          name3      TYPE ad_name3,   " Name 3
          house_num2 TYPE ad_hsnm2,   " House number supplement
          str_suppl1 TYPE ad_strspp1, " Street 2
          building   TYPE ad_bldng,   " Building (Number or Code)
          floor      TYPE ad_floor,   " Floor in building
          roomnumber TYPE ad_roomnum, " Room or Appartment Number
          END OF lty_adrc,

          BEGIN OF lty_adrnr,
          parvw TYPE parvw,           " Partner Function
          adrnr TYPE adrnr,           " Address
          END OF lty_adrnr.

  DATA: li_adrnr TYPE STANDARD TABLE OF lty_adrnr, " Address
        li_adrc  TYPE STANDARD TABLE OF lty_adrc.

  FIELD-SYMBOLS: <lfs_party> TYPE sapplco_sls_ord_erpby_idrsp_63, " IDT SlsOrdERPByIDRsp_s_V3Pty
                 <lfs_adrc>  TYPE lty_adrc,
                 <lfs_adrnr> TYPE lty_adrnr.

  CONSTANTS : lc_sold_to TYPE parvw VALUE 'AG', "Partner Function
              lc_ship_to TYPE parvw VALUE 'WE', "Partner Function

* ---> Begin of Change for Defect#1843, D2_OTC_IDD_0092 by SGUPTA4
*             lc_bill_to TYPE parvw VALUE 'RG', "Partner Function Bill to Party
              lc_payer   TYPE parvw VALUE 'RG', "Partner Function
              lc_bill_to TYPE parvw VALUE 'RE', "Partner Function Bill to Party
* <--- End  of Change Defect#1843, D2_OTC_IDD_0092 by SGUPTA4

              lc_posnr   TYPE posnr VALUE '000000'. "Item number of the SD document

* ---> End of Change for CR D2_146 by HBADLAN


  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_dev_stat
    TABLES
      tt_enh_status     = li_dev_stat.

*first thing is to check for field criterion,for value “NULL” and field Active value:
*i.If the value is: “X”, the overall Enhancement is active and can proceed further for checks
*ii.If the  value is:space, then do not proceed further for this enhancement

  READ TABLE li_dev_stat WITH KEY criteria = lc_null "NULL
                                  active = abap_true "X"
                       TRANSPORTING NO FIELDS.
  IF sy-subrc EQ  0.
**Get sales order number
    lv_order_num = cs_output-sales_order_erpby_idresponse-sales_order-id-content.

**Get order net value
    CLEAR: lv_net,
           lv_curr.
    lv_net = cs_output-sales_order_erpby_idresponse-sales_order-total_values-net_amount-content.
    lv_curr = cs_output-sales_order_erpby_idresponse-sales_order-total_values-net_amount-currency_code.

**Total taxes
    lv_tax = cs_output-sales_order_erpby_idresponse-sales_order-total_values-tax_amount-content.

**Get final shipping charge
    li_temp[] =  cs_output-sales_order_erpby_idresponse-sales_order-price_component[].
    SORT li_temp BY price_specification_element_t1-content.
    READ TABLE li_temp ASSIGNING <lfs_ship_amt>
                      WITH KEY price_specification_element_t1-content = lc_ztfr
                      BINARY SEARCH.
    IF sy-subrc = 0.
      lv_ship_amt = <lfs_ship_amt>-calculated_amount-content.
    ENDIF. " IF sy-subrc = 0

**Get handling charges
    CALL FUNCTION 'CONVERSION_EXIT_ISOLA_OUTPUT'
      EXPORTING
        input  = sy-langu
      IMPORTING
        output = lv_langu.

    SORT li_temp BY price_specification_element_t-content ASCENDING
                    price_specification_element_t-language_code ASCENDING.
    READ TABLE li_temp ASSIGNING <lfs_hadle_amt>
                      WITH KEY price_specification_element_t-content = lc_handle
                               price_specification_element_t-language_code = lv_langu
                      BINARY SEARCH.
    IF sy-subrc = 0.
      lv_handle_amt = <lfs_hadle_amt>-calculated_amount-content.
    ENDIF. " IF sy-subrc = 0

**Get Order total
    lv_total = lv_net + lv_tax + lv_ship_amt + lv_handle_amt.

    cs_output-sales_order_erpby_idresponse-sales_order-total_values-z01otc_ztotalamt-content
                                                                            = lv_total.
    cs_output-sales_order_erpby_idresponse-sales_order-total_values-z01otc_ztotalamt-currency_code
                                                                            = lv_curr.

**Convert Sales order number to internal format
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_order_num
      IMPORTING
        output = lv_order_num.

** get header data
    SELECT SINGLE
           vbeln " Sales Document
           erzet " Entry time
* ---> Begin of Insert for Defect 1956 by DMOIRAN
           bsark "Customer purchase order type
* <--- End    of Insert for Defect 1956 by DMOIRAN
           zzdocref " Legacy Doc Ref
      FROM vbak     " Sales Document: Header Data
      INTO lwa_head
      WHERE vbeln = lv_order_num.
    IF sy-subrc = 0.
**External Doc reference
      cs_output-sales_order_erpby_idresponse-sales_order-z01otc_zdocref = lwa_head-zzdocref.
**Created time
      cs_output-sales_order_erpby_idresponse-sales_order-z01otc_ztime = lwa_head-erzet.
    ENDIF. " IF sy-subrc = 0


    lwa_order-sales_order_number = lv_order_num.
    APPEND lwa_order TO li_order.

**Get Header status and Ivoice list
    CALL FUNCTION 'ZOTC_GET_ORDER_STATUS'
      EXPORTING
        im_order_req     = li_order
      IMPORTING
        ex_order_inv     = li_invoice
        ex_order_res     = li_status
      EXCEPTIONS
        no_order_found   = 1
        no_data_provided = 2
        OTHERS           = 3.
    IF sy-subrc = 0.

**Order Status
      READ TABLE li_status ASSIGNING <lfs_stat> INDEX 1.
      IF sy-subrc = 0.
        cs_output-sales_order_erpby_idresponse-sales_order-z01otc_zstatus = <lfs_stat>-status.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0
*****************************************************************************
**Do not process Item data for cancelled order
    IF <lfs_stat> IS ASSIGNED.
      IF <lfs_stat>-status NE lc_stat_can.
**Get the list of invoices from table
        LOOP AT li_invoice ASSIGNING <lfs_invc>.
          APPEND <lfs_invc>-invoice_number TO li_invoic_list.
        ENDLOOP. " LOOP AT li_invoice ASSIGNING <lfs_invc>
**Invoce list
        cs_output-sales_order_erpby_idresponse-sales_order-z01otc_zinvoice[] = li_invoic_list[].

** get item data

        SELECT vbeln       " Sales Document
                posnr      " Sales Document Item
                posex      " Item Number of the Underlying Purchase Order
                zzquoteref " Legacy Qtn Ref
          FROM vbap        " Sales Document: Item Data
          INTO TABLE li_vbap
          WHERE vbeln = lv_order_num.
        IF sy-subrc = 0.
          SORT li_vbap BY posnr.
        ENDIF. " IF sy-subrc = 0
** get item data from proxy
        li_item[] = cs_output-sales_order_erpby_idresponse-sales_order-item[].

** Call function to get shipping data record
        CALL FUNCTION 'ZOTC_GET_SHP_DTE_N_QUAN_FM'
          EXPORTING
            im_sals_order = lv_order_num
          IMPORTING
            ex_delv_data  = li_ship_data
* ---> Begin of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS
            ex_flag       = lv_flag.
* <--- End of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS

        SORT li_ship_data BY posnr.

        LOOP AT li_item ASSIGNING <lfs_item>.

          READ TABLE li_vbap ASSIGNING <lfs_vbap>
                                       WITH KEY posnr = <lfs_item>-id
                                       BINARY SEARCH.
          IF sy-subrc = 0.
**Line Item ID
            <lfs_item>-z01otc_zline_id    = <lfs_vbap>-posex.
**Quote ID
            <lfs_item>-z01otc_zquote_ref1 = <lfs_vbap>-zzquoteref.
          ENDIF. " IF sy-subrc = 0

          CLEAR: li_zitem[].
          READ TABLE li_ship_data ASSIGNING <lfs_ship>
                                  WITH KEY posnr = <lfs_item>-id
                                  BINARY SEARCH.
          IF sy-subrc = 0.
            li_zitem[] = <lfs_ship>-zdelv_data[].
            REFRESH: li_itm_tmp.
            LOOP AT li_zitem ASSIGNING <lfs_ship_1>.
**Expected delivery date
              lwa_zitm-expected_delvry_date         = <lfs_ship_1>-zex_delv_dte.
**Confirmed quantity
              lwa_zitm-expected_delvry_qty-content  = <lfs_ship_1>-zconf_quan.
**Sales unit
              lwa_zitm-expected_delvry_qty-unit_code  = <lfs_ship_1>-zunit.
**Delivered quantity
              lwa_zitm-shipped_qty-content          = <lfs_ship_1>-zdelv_quan.
**Sales Unit
              lwa_zitm-shipped_qty-unit_code          = <lfs_ship_1>-zunit.
**Delivery date
              lwa_zitm-shipped_date                 = <lfs_ship_1>-zdelv_dte.

* ---> Begin of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS
**Route ID for delivery based scenario
* ---> Begin of Change for D2_OTC_IDD_0092_Defect 5842 by DMOIRAN
* In case of mixed scenario of delivery based and 3rd party based the flag won't work.
* And ZSCAC_CODE is only populated for 3rd party scenario. So, instead of flag use
* check on ZSCAC_CODE
*              IF lv_flag = abap_true.
              IF <lfs_ship_1>-zscac_code IS INITIAL.
* <--- End of Change for D2_OTC_IDD_0092_Defect 5842 by DMOIRAN
                lwa_zitm-route_idname                 = <lfs_item>-delivery_terms-route_id.
              ELSE. " ELSE -> IF <lfs_ship_1>-zscac_code IS INITIAL
**Route ID
                lwa_zitm-route_idname                 = <lfs_ship_1>-zscac_code.
              ENDIF. " IF <lfs_ship_1>-zscac_code IS INITIAL

* <--- End of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS

**Tracking number
              lwa_zitm-tracking_number[]            = <lfs_ship_1>-ztrack_number.
              APPEND lwa_zitm TO li_itm_tmp.
              CLEAR : lwa_zitm,
                      <lfs_ship_1>.
            ENDLOOP. " LOOP AT li_zitem ASSIGNING <lfs_ship_1>
            <lfs_item>-z01otc_zitem_data[] = li_itm_tmp[].
          ENDIF. " IF sy-subrc = 0

* ---> Begin of Insert for Defect 1956 by DMOIRAN

* Fetch Z015 text and populate it again as special character identifier in string is needed
          IF lwa_head-bsark NE lc_zweb.
            ASSIGN <lfs_item>-text_collection-text TO <lfs_t_text>.
* ---> Begin of Change for Defect 1956 2nd Change by DMOIRAN
*            IF sy-subrc = 0.
            IF <lfs_t_text> IS ASSIGNED.
* <--- End    of Change for Defect 1956 2nd change by DMOIRAN

              READ TABLE <lfs_t_text> ASSIGNING <lfs_text> WITH KEY type_code-content = lc_z015.
              IF sy-subrc = 0.
                CLEAR: lv_posnr, lv_tdname, lv_spras, li_tdline[], lv_space, lv_string.
* convert line item to input format
                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = <lfs_item>-id
                  IMPORTING
                    output = lv_posnr.

                CALL FUNCTION 'CONVERSION_EXIT_ISOLA_INPUT'
                  EXPORTING
                    input            = <lfs_text>-content_text-language_code
                  IMPORTING
                    output           = lv_spras
                  EXCEPTIONS
                    unknown_language = 1
                    OTHERS           = 2.
                IF sy-subrc <> 0.
* set to default - English
                  lv_spras = lc_e.
                ENDIF. " IF sy-subrc <> 0

                CONCATENATE lv_order_num lv_posnr INTO lv_tdname.

                CALL FUNCTION 'READ_TEXT'
                  EXPORTING
                    client                  = sy-mandt
                    id                      = lc_z015
                    language                = lv_spras
                    name                    = lv_tdname
                    object                  = lc_obj_vbbp
                  TABLES
                    lines                   = li_tdline
                  EXCEPTIONS
                    id                      = 1
                    language                = 2
                    name                    = 3
                    not_found               = 4
                    object                  = 5
                    reference_check         = 6
                    wrong_access_to_archive = 7
                    OTHERS                  = 8.
                IF sy-subrc = 0.
                  LOOP AT li_tdline ASSIGNING <lfs_tdline>.
                    IF lv_space = abap_true.
                      CONCATENATE lv_string <lfs_tdline>-tdline INTO lv_string SEPARATED BY space.
                      CLEAR lv_space.
                    ELSE. " ELSE -> IF lv_space = abap_true
                      CONCATENATE lv_string <lfs_tdline>-tdline INTO lv_string.
                    ENDIF. " IF lv_space = abap_true

* As tdline is of 132 characters, reduce by 1 and check if it is blank
                    IF <lfs_tdline>-tdline+131 = space.
                      lv_space = abap_true.
                    ENDIF. " IF <lfs_tdline>-tdline+131 = space
                  ENDLOOP. " LOOP AT li_tdline ASSIGNING <lfs_tdline>
                ENDIF. " IF sy-subrc = 0

* overwrite with special characters.
                IF lv_string IS NOT INITIAL.
                  <lfs_text>-content_text-content = lv_string.
                ENDIF. " IF lv_string IS NOT INITIAL
              ENDIF. " IF sy-subrc = 0

            ENDIF. " IF <lfs_t_text> IS ASSIGNED
          ENDIF. " IF lwa_head-bsark NE lc_zweb
* <--- End    of Insert for Defect 1956 by DMOIRAN

        ENDLOOP. " LOOP AT li_item ASSIGNING <lfs_item>

**Pass Item data to Proxy
        cs_output-sales_order_erpby_idresponse-sales_order-item[] = li_item[].

* ---> Begin of Change for CR D2_146 by HBADLAN
*As per CR D2_146 :Name3,Building,Floor,Room,Suite,Street2  fields are to be added to
*response for SP, SH and BP functions i.e Ship to party,Sold to party,Bill to party and Payer.

*Fetching Address number from VBPA based on sales order number,Partner function
        SELECT parvw " Partner Function
               adrnr " Address
        FROM vbpa    " Sales Document: Partner
        INTO TABLE li_adrnr
        WHERE vbeln = cs_output-sales_order_erpby_idresponse-sales_order-id-content
        AND   posnr = lc_posnr
* ---> Begin of Change for Defect#1843, D2_OTC_IDD_0092 by SGUPTA4
        AND   parvw IN (lc_sold_to,lc_ship_to,lc_bill_to, lc_payer).
* <--- End   of Change for Defect#1843, D2_OTC_IDD_0092 by SGUPTA4
        IF sy-subrc EQ 0.
          SORT li_adrnr BY parvw adrnr.
          DELETE ADJACENT DUPLICATES FROM li_adrnr COMPARING parvw adrnr.
          IF li_adrnr IS NOT INITIAL.
*Fetching Name3,Building,Floor,Room,Suite,Street2 from ADRC table based on address number.
            SELECT addrnumber " Address number
                   date_from  " Valid-from date - in current Release only 00010101 possible
                   nation     " Version ID for International Addresses
                   name3      " Name 3
                   house_num2 " House number supplement
                   str_suppl1 " Street 2
                   building   " Building (Number or Code)
                   floor      " Floor in building
                   roomnumber " Room or Appartment Number
            FROM adrc         " Addresses (Business Address Services)
            INTO TABLE li_adrc
            FOR ALL ENTRIES IN li_adrnr
            WHERE addrnumber EQ li_adrnr-adrnr.
            IF sy-subrc EQ 0.
              SORT li_adrc BY addrnumber.
              LOOP AT li_adrnr ASSIGNING <lfs_adrnr>.
                READ TABLE li_adrc ASSIGNING <lfs_adrc> WITH KEY addrnumber = <lfs_adrnr>-adrnr
                                                        BINARY SEARCH.
                IF sy-subrc EQ 0.
*Binary search not used below as sorting cannot be done on below table.
                  READ TABLE cs_output-sales_order_erpby_idresponse-sales_order-party ASSIGNING <lfs_party>
                                                                                      WITH KEY role_code = <lfs_adrnr>-parvw.
                  IF sy-subrc EQ 0.
                    <lfs_party>-z01otc_zname3 = <lfs_adrc>-name3.
                    <lfs_party>-address-z01otc_zaddl_addr-house_num2  = <lfs_adrc>-house_num2.
                    <lfs_party>-address-z01otc_zaddl_addr-str_suppl1  = <lfs_adrc>-str_suppl1.
                    <lfs_party>-address-z01otc_zaddl_addr-building_id = <lfs_adrc>-building.
                    <lfs_party>-address-z01otc_zaddl_addr-floor_id    = <lfs_adrc>-floor.
                    <lfs_party>-address-z01otc_zaddl_addr-room_id     = <lfs_adrc>-roomnumber.
                  ENDIF. " IF sy-subrc EQ 0
                ENDIF. " IF sy-subrc EQ 0
              ENDLOOP. " LOOP AT li_adrnr ASSIGNING <lfs_adrnr>
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF li_adrnr IS NOT INITIAL
        ENDIF. " IF sy-subrc EQ 0
        FREE : li_adrnr,
               li_adrc.
* <--- End of Change for CR D2_146 by HBADLAN
      ENDIF. " IF <lfs_stat>-status NE lc_stat_can
    ENDIF. " IF <lfs_stat> IS ASSIGNED



  ENDIF. " IF sy-subrc EQ 0
ENDMETHOD.
ENDCLASS.
