class ZCL_IM_OTC_CHANGE_SO definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_SLS_APPL_SE_SOERPCHGRC .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_OTC_CHANGE_SO IMPLEMENTATION.


METHOD if_sls_appl_se_soerpchgrc~inbound_processing.
***********************************************************************
*Program    :if_sls_appl_se_soerpchgrc~inbound_processing(BAdI Method)*
*Title      : Populate custom field in Change Sales order ES          *
*Developer  : Dhananjoy Moirangthem                                   *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0102_SAP                                       *
*---------------------------------------------------------------------*
*Description: Service Max will send custom fields which needs to be   *
* updated in the Sales Order. To populate these custom fields, this   *
*BAdI method is used.                                                 *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*02-JUN-2014  DMOIRAN       E2DK900895     Initial Development
*---------------------------------------------------------------------*
*21-JUN-2014  DMOIRAN       E2DK900895     CR D2_52. For SO with bill *
* plan, check if there exist record in FPLT with completley processed *
* status (C) and settlement date is less than SMax contract end date. *
* If so, then don't update the contract end date.                     *
*                                                                     *
*09-Feb-2015  NSAXENA       E2DK900895     CR D2_284-Updating the line*
*             item details based on sales orderVBELN & ZZITEMREF field*
*             combination where line item (POSNR)is not required.     *
*             Checked the VA03 customised fields                      *
*---------------------------------------------------------------------*

  TYPES:
* line item work area
         BEGIN OF lty_vbap,
           vbeln TYPE vbeln_va, " Sales Document
           posnr TYPE posnr_va, " Sales Document Item
           pstyv TYPE pstyv,    " Sales document item category
           abgru TYPE abgru_va, " Reason for rejection of quotations and sales orders
         END OF lty_vbap,
* table type for line item
        lty_t_vbap TYPE STANDARD TABLE OF lty_vbap,
* item category data
      BEGIN OF lty_tvap,
        pstyv TYPE pstyv,      " Sales document item category
        fkrel  TYPE fkrel,     " Relevant for Billing
        fpart TYPE fpart,      " Billing/Invoicing Plan Type
        rrrel  TYPE rr_reltyp, " Revenue recognition category
      END OF lty_tvap,
* item category data table type
     lty_t_tvap TYPE STANDARD TABLE OF lty_tvap,

* contract data
     BEGIN OF lty_veda,
       vbeln TYPE vbeln_va,     " Sales Document
       vposn TYPE posnr_va,     " Sales Document Item
       vabndat TYPE vadat_veda, " Agreement acceptance date
     END OF lty_veda,
* contract data table type
     lty_t_veda TYPE STANDARD TABLE OF lty_veda,

* Revenue Recognition Lines
    BEGIN OF lty_vbreve,
      vbeln TYPE vbeln_va,       " Sales Document
      posnr TYPE posnr_va,       " Sales Document Item
      sakrv TYPE saknr,          " G/L Account Number
      bdjpoper TYPE rr_bdjpoper, " Posting year and posting period (YYYYMMM format)
      popupo TYPE rr_popupo,     " Period sub-item
      vbeln_n TYPE vbeln_nach,   " Subsequent sales and distribution document
      posnr_n TYPE posnr_nach,   " Subsequent item of an SD document
      rrsta TYPE rr_status,      " Revenue determination status
      revfix TYPE rr_revfix,     " Fixed Revenue Line Indicator
   END OF lty_vbreve,
   lty_t_vbreve TYPE STANDARD TABLE OF lty_vbreve,

* Sales Document: Business Data
   BEGIN OF lty_vbkd,
     vbeln TYPE vbeln, " Sales and Distribution Document Number
     posnr TYPE posnr, " Item number of the SD document
     fplnr TYPE fplnr, " Billing plan number / invoicing plan number
   END OF lty_vbkd,
   lty_t_vbkd TYPE STANDARD TABLE OF lty_vbkd,

   BEGIN OF lty_fplt,
     fplnr TYPE fplnr, " Billing plan number / invoicing plan number
     fpltr TYPE fpltr, " Item for billing plan/invoice plan/payment cards
     fkdat TYPE bfdat, " Settlement date for deadline
     fksaf TYPE fksaf, " Billing status for the billing plan/invoice plan date
     nfdat TYPE nfdat, " Settlement date for deadline
   END OF lty_fplt,
   lty_t_fplt TYPE STANDARD TABLE OF lty_fplt,

* ---> Begin of Change for D2_OTC_IDD_0102, CR D2_284 by NSAXENA.
*Line items
  BEGIN OF lty_item,
     vbeln TYPE vbeln_va,      " Sales Document
     posnr TYPE char6,         " Posnr of type CHAR6
     zzitemref TYPE z_itemref, " ServMax Obj ID
   END OF lty_item.
* <---End of Change for D2_OTC_IDD_0102, CR D2_284 by NSAXENA.


  DATA:

        lwa_sales_id        TYPE sapplco_sales_order_id,              " sales id
        lv_sale_order       TYPE sapplco_sales_order_id_content,      " sales order number
        li_status         TYPE STANDARD TABLE OF zdev_enh_status,     "Enhancement Status table
        lwa_bapiret        TYPE bapiret2,                             " Return Parameter
        li_vbap            TYPE lty_t_vbap,                           "sales order line item
        li_vbap_tmp        TYPE lty_t_vbap,                           "temp internal table
        li_tvap            TYPE lty_t_tvap,                           "item category data
        li_veda            TYPE lty_t_veda,                           "contract data
        li_vbreve          TYPE lty_t_vbreve,                         "Revenue Recognition Lines
        lv_acc_date_upd TYPE flag,                                    "acceptance date update flag
        lv_upd_beg_dt      TYPE flag,                                 " General Flag
        lv_upd_end_dt      TYPE flag,                                 " General Flag
        lv_vbtyp           TYPE vbtyp,                                " SD document category
        li_vbkd            TYPE lty_t_vbkd,                           "Sales Document: Business Data
        li_vbkd_tmp        TYPE lty_t_vbkd,                           "Sales Document: Business Data
        li_fplt            TYPE lty_t_fplt,                           "Billing Plan: Dates
        lv_index           TYPE sytabix,                              " Index of Internal Tables
        lv_const_fksaf     TYPE fksaf,                                " Billing status for the billing plan/invoice plan date
        lv_const_rrsta     TYPE rr_status,                            " Revenue determination status
        li_xi_lord_assign  TYPE STANDARD TABLE OF tds_xi_lord_assign, "TDT_XI_LORD_ASSIGN.
        lv_input_index     TYPE sytabix.                              " Index of Internal Tables
* ---> Begin of Change for D2_OTC_IDD_0102, CR D2_284 by NSAXENA.
*Data declarations
  DATA:
    li_item TYPE STANDARD TABLE OF lty_item,            "internal table for line items
    lwa_item TYPE lty_item,                             "Work area for line items
    li_input_item TYPE sapplco_sales_order_erpch_tab9,  "Internal table for line items details
    lx_input_temp TYPE  sls_sales_order_erpchange_requ. " Sales Order ERP Change Request
* <--- End of Change for D2_OTC_IDD_0102, CR D2_284 by NSAXENA.


  FIELD-SYMBOLS: <lfs_item>           TYPE tds_item_comv,                  " Lean Order - item Data (Values)
                 <lfs_item_x>         TYPE tds_item_comc,                  " Lean Order - item Data (CHAR)
                 <lfs_input_item>     TYPE sapplco_sales_order_erpchang38, " SlsOrdERPChgReq_sItm
                 <lfs_xi_lord_assign> TYPE tds_xi_lord_assign,             " XI - LORD Assignment
                 <lfs_vbap>           TYPE lty_vbap,                       "sale order item data
                 <lfs_tvap>           TYPE lty_tvap,                       "item category data
                 <lfs_veda>           TYPE lty_veda,                       "contract data
                 <lfs_vbkd>           TYPE lty_vbkd,                       " revenue recognition data
                 <lfs_fplt>           TYPE lty_fplt,                       "Billing Plan: Dates
                 <lfs_status>         TYPE zdev_enh_status.                " Enhancement Status

  CONSTANTS: lc_idd_0102_001            TYPE z_enhancement    VALUE 'D2_OTC_IDD_0102_001', " Enhancement No.
             lc_null                    TYPE z_criteria       VALUE 'NULL',                " Enh. Criteria
             lc_msg_id                  TYPE symsgid               VALUE 'ZOTC_MSG',       " Object ID of Business Event Offered
             lc_msg_type_w              TYPE bapi_mtype       VALUE 'W',                   " Message type: S Success, E Error, W Warning, I Info, A Abort
             lc_msg_no_144              TYPE symsgno          VALUE '144',                 " Message Number
             lc_msg_no_145              TYPE symsgno          VALUE '145',                 " Message Number
             lc_msg_no_147              TYPE symsgno          VALUE '147',                 " Message Number
             lc_msg_no_148              TYPE symsgno          VALUE '148',                 " Message Number
             lc_msg_no_157              TYPE symsgno          VALUE '157',                 " Message Number
             lc_msg_no_158              TYPE symsgno          VALUE '158',                 " Message Number
             lc_cri_vbtyp               TYPE z_criteria       VALUE 'VBTYP',               " Enh. Criteria
             lc_cri_fksaf               TYPE z_criteria       VALUE 'FKSAF',               " Enh. Criteria
             lc_cri_rrsta               TYPE z_criteria       VALUE 'RRSTA',               " Enh. Criteria
             lc_obj_item                TYPE tabname          VALUE 'ITEM'.                " Table Name

* Call to EMI Function Module To Get List Of EMI Statuses
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_idd_0102_001 "D2_OTC_IDD_0010_001
    TABLES
      tt_enh_status     = li_status.      "Enhancement status table


*first thing is to check for field criterion,for value “NULL” and field Active value:
*i.If the value is: “X”, the overall Enhancement is active and can proceed further for checks
*ii.If the  value is:space, then do not proceed further for this enhancement

  DELETE li_status WHERE active = space.


* as only active (after above delete statement) entries are there in LI_STATUS
* active field is not check in below read.

  READ TABLE li_status WITH KEY criteria = lc_null "NULL
                       TRANSPORTING NO FIELDS.
  IF sy-subrc EQ  0.

* get constant for Billing status for the billing plan/invoice plan date
    READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_cri_fksaf.
    IF sy-subrc = 0.
      lv_const_fksaf = <lfs_status>-sel_low.
    ENDIF. " IF sy-subrc = 0
* Get constant for Revenue determination status
    READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_cri_rrsta.
    IF sy-subrc = 0.
      lv_const_rrsta = <lfs_status>-sel_low.
    ENDIF. " IF sy-subrc = 0

* Check the criteria of enhancement


* get the sales order number
    lwa_sales_id = is_input-sales_order_erpchange_request-sales_order-id.
    lv_sale_order = lwa_sales_id-content.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_sale_order
      IMPORTING
        output = lv_sale_order.
* ---> Begin of Change for D2_OTC_IDD_0102, CR D2_284 by NSAXENA.
*Passing input values to temporary parameter.
    lx_input_temp = is_input.
*Fetching the data from VBAP table based on sales order number passed
* and get the item details under this sales order.
* get the sales order line item

    li_input_item[] = is_input-sales_order_erpchange_request-sales_order-item.
    READ TABLE li_input_item ASSIGNING <lfs_input_item> INDEX 1.
    IF sy-subrc EQ 0.
      IF <lfs_input_item>-id IS INITIAL.
        SELECT vbeln     " Sales Document
               posnr     " Sales Document Item
               zzitemref " ServMax Obj ID
               FROM vbap " Sales Document: Item Data
               INTO TABLE li_item
               WHERE vbeln = lv_sale_order.
        IF sy-subrc = 0.
          SORT li_item BY vbeln zzitemref.
        ENDIF. " IF sy-subrc = 0
*Assigning the input data of proxy to field symbol.
*    LOOP AT is_input-sales_order_erpchange_request-sales_order-item ASSIGNING <lfs_input_item>.
        LOOP AT lx_input_temp-sales_order_erpchange_request-sales_order-item ASSIGNING <lfs_input_item>.
*Once we get the data in field symbol we will check the line item table with sales order number
*and Item reference field as input to get the posnr.
          READ TABLE li_item INTO lwa_item WITH KEY
                                  vbeln = lv_sale_order
                                  zzitemref = <lfs_input_item>-z01otc_zadd_data-obj_ref_id
                                  BINARY SEARCH.
*Assign the posnr to line item number and now based on this number we get the confirmation
*in which line item of sales order we need to update the proxy data.
          IF sy-subrc = 0.
            <lfs_input_item>-id = lwa_item-posnr.
          ENDIF. " IF sy-subrc = 0
        ENDLOOP. " LOOP AT lx_input_temp-sales_order_erpchange_request-sales_order-item ASSIGNING <lfs_input_item>
      ENDIF. " IF <lfs_input_item>-id IS INITIAL
    ENDIF. " IF sy-subrc EQ 0
* <--- End of Change for D2_OTC_IDD_0102, CR D2_284 by NSAXENA.

* Check SD doc category
    SELECT SINGLE vbtyp FROM vbak " Sales Document: Header Data
                       INTO lv_vbtyp
                       WHERE vbeln = lv_sale_order.

    IF sy-subrc = 0.

      READ TABLE li_status WITH KEY criteria = lc_cri_vbtyp "NULL
                                    sel_low =  lv_vbtyp
                                    TRANSPORTING NO FIELDS.

      IF sy-subrc = 0.

* get data from sales order line item data
        SELECT vbeln   " Sales Document
               posnr   " Sales Document Item
               pstyv   " Sales document item category
               abgru   " Reason for rejection of quotations and sales orders
             FROM vbap " Sales Document: Item Data
             INTO TABLE li_vbap
             WHERE vbeln = lv_sale_order.

        IF sy-subrc = 0.
          SORT li_vbap BY vbeln posnr.

* get the contract data
          SELECT vbeln    " Sales Document
                 vposn    " Sales Document Item
                 vabndat  " Agreement acceptance date
                FROM veda " Contract Data
                INTO TABLE li_veda
                WHERE vbeln = lv_sale_order.
          IF sy-subrc = 0.
            SORT li_veda BY vbeln vposn.
          ENDIF. " IF sy-subrc = 0

          li_vbap_tmp[] = li_vbap[].
* get the item category data
          SORT li_vbap_tmp BY pstyv.
          DELETE ADJACENT DUPLICATES FROM li_vbap_tmp COMPARING pstyv.
          IF li_vbap_tmp IS NOT INITIAL.
            SELECT pstyv    " Sales document item category
                   fkrel    " Relevant for Billing
                   fpart    " Billing/Invoicing Plan Type
                   rrrel    " Revenue recognition category
                  FROM tvap " Sales Document: Item Categories
                  INTO TABLE li_tvap
                  FOR ALL ENTRIES IN li_vbap_tmp
                  WHERE pstyv = li_vbap_tmp-pstyv.
            IF sy-subrc = 0.
              SORT li_tvap BY pstyv.
            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF li_vbap_tmp IS NOT INITIAL

* fetch the revenue recognition data

          SELECT vbeln      " Sales Document
                 posnr      " Sales Document Item
                 sakrv      " G/L Account Number
                 bdjpoper   " Posting year and posting period (YYYYMMM format)
                 popupo     " Period sub-item
                 vbeln_n    " Subsequent sales and distribution document
                 posnr_n    " Subsequent item of an SD document
                 rrsta      " Revenue determination status
                 revfix     " Fixed Revenue Line Indicator
                FROM vbreve " Revenue Recognition: Revenue Recognition Lines
                INTO TABLE li_vbreve
                WHERE vbeln = lv_sale_order.
          IF sy-subrc = 0.

            SORT li_vbreve BY vbeln posnr rrsta revfix.

          ENDIF. " IF sy-subrc = 0

* get sales document business data
          SELECT vbeln    " Sales and Distribution Document Number
                 posnr    " Item number of the SD document
                 fplnr    " Billing plan number / invoicing plan number
                FROM vbkd " Sales Document: Business Data
                INTO TABLE li_vbkd
                WHERE vbeln = lv_sale_order.
          IF sy-subrc = 0.
            SORT li_vbkd BY vbeln posnr.
* get the billing plan data
            li_vbkd_tmp[] = li_vbkd[].
            SORT li_vbkd_tmp BY fplnr.
            DELETE ADJACENT DUPLICATES FROM li_vbkd_tmp COMPARING fplnr.

            IF li_vbkd_tmp[] IS NOT INITIAL.
              SELECT fplnr    " Billing plan number / invoicing plan number
                     fpltr    " Item for billing plan/invoice plan/payment cards
                     fkdat    " Settlement date for deadline
                     fksaf    " Billing status for the billing plan/invoice plan date
                     nfdat    " Settlement date for deadline
                    FROM fplt " Billing Plan: Dates
                    INTO TABLE li_fplt
                    FOR ALL ENTRIES IN li_vbkd_tmp
                   WHERE fplnr = li_vbkd_tmp-fplnr.
              IF sy-subrc = 0.

* Need only completely processed record only
                DELETE li_fplt WHERE fksaf NE lv_const_fksaf.
                SORT li_fplt BY fplnr fkdat nfdat.
              ENDIF. " IF sy-subrc = 0
            ENDIF. " IF li_vbkd_tmp[] IS NOT INITIAL

          ENDIF. " IF sy-subrc = 0

* Get only the ITEM data
          APPEND LINES OF ct_xi_lord_assign TO li_xi_lord_assign.
          DELETE li_xi_lord_assign WHERE object NE lc_obj_item.


* populate the custom fields
* ---> Begin of Change for D2_OTC_IDD_0102, CR D2_284 by NSAXENA.
*         LOOP AT is_input-sales_order_erpchange_request-sales_order-item ASSIGNING <lfs_input_item>.
          LOOP AT lx_input_temp-sales_order_erpchange_request-sales_order-item ASSIGNING <lfs_input_item>.
* <--- End of Change for D2_OTC_IDD_0102, CR D2_284 by NSAXENA.
            lv_input_index = sy-tabix.
* check if input line item exists on SAP side.
            READ TABLE li_vbap ASSIGNING <lfs_vbap> WITH KEY
                                                   vbeln = lv_sale_order
                                                   posnr = <lfs_input_item>-id
                                                   BINARY SEARCH.
            IF sy-subrc NE 0.
*if item doesn't exist then SAP will automatically put error message
              CONTINUE.
            ENDIF. " IF sy-subrc NE 0


* check if item has been rejected
            IF <lfs_vbap>-abgru IS NOT INITIAL.
              CLEAR lwa_bapiret.
              lwa_bapiret-type = lc_msg_type_w.
              lwa_bapiret-id = lc_msg_id.
              lwa_bapiret-number = lc_msg_no_145.
              lwa_bapiret-message_v1 = <lfs_input_item>-id.
              lwa_bapiret-message_v2 = <lfs_vbap>-abgru.
              MESSAGE w145(zotc_msg) WITH <lfs_input_item>-id " Item & has been cancelled with reason &.
                                          <lfs_vbap>-abgru
                                      INTO lwa_bapiret-message.
              APPEND lwa_bapiret TO ct_message_log.

              CONTINUE.

            ENDIF. " IF <lfs_vbap>-abgru IS NOT INITIAL

* check if contract data are passed in the interface

            lv_upd_beg_dt = abap_true.
            lv_upd_end_dt = abap_true.

* Check if Contract Start and End date should be updated or not
            IF <lfs_input_item>-z01otc_zcontractdata-end_date < sy-datum
              AND <lfs_input_item>-z01otc_zcontractdata-end_date IS NOT INITIAL.

              lv_upd_end_dt = abap_false.
              CLEAR lwa_bapiret.
              lwa_bapiret-type = lc_msg_type_w.
              lwa_bapiret-id = lc_msg_id.
              lwa_bapiret-number = lc_msg_no_147.
              lwa_bapiret-message_v1 = <lfs_input_item>-z01otc_zcontractdata-end_date.
              MESSAGE w147(zotc_msg) WITH <lfs_input_item>-z01otc_zcontractdata-end_date " End date & is less than current date.
                                    INTO lwa_bapiret-message.
              APPEND lwa_bapiret TO ct_message_log.

            ENDIF. " IF <lfs_input_item>-z01otc_zcontractdata-end_date < sy-datum

            READ TABLE li_tvap ASSIGNING <lfs_tvap> WITH KEY pstyv = <lfs_vbap>-pstyv BINARY SEARCH.
            IF sy-subrc = 0.

* check if the item has been posted/processed

              IF <lfs_tvap>-fpart IS INITIAL AND <lfs_tvap>-rrrel IS NOT INITIAL
                AND ( <lfs_input_item>-z01otc_zcontractdata-end_date IS NOT INITIAL
                      OR <lfs_input_item>-z01otc_zcontractdata-start_date IS NOT INITIAL ).

                READ TABLE li_vbreve  WITH KEY vbeln = lv_sale_order
                                               posnr = <lfs_input_item>-id
                                               rrsta = lv_const_rrsta "C
                                               revfix = space
                                               TRANSPORTING NO FIELDS BINARY SEARCH.
                IF sy-subrc = 0.

                  lv_upd_beg_dt = abap_false.
                  lv_upd_end_dt = abap_false.

                  CLEAR lwa_bapiret.
                  lwa_bapiret-type = lc_msg_type_w.
                  lwa_bapiret-id = lc_msg_id.
                  lwa_bapiret-number = lc_msg_no_144.
                  lwa_bapiret-message_v1 = <lfs_input_item>-id.
                  MESSAGE w144(zotc_msg) WITH <lfs_input_item>-id " Item & is already posted so Contract date cannot be changed.
                             INTO lwa_bapiret-message.

                  APPEND lwa_bapiret TO ct_message_log.

                ENDIF. " IF sy-subrc = 0

              ENDIF. " IF <lfs_tvap>-fpart IS INITIAL AND <lfs_tvap>-rrrel IS NOT INITIAL

* Periodic Billing
              IF <lfs_tvap>-fpart IS NOT INITIAL.
                READ TABLE li_vbkd ASSIGNING <lfs_vbkd> WITH KEY vbeln = lv_sale_order
                                                                 posnr = <lfs_input_item>-id
                                                                 BINARY SEARCH.
                IF sy-subrc = 0.
                  IF <lfs_vbkd>-fplnr IS NOT INITIAL.
* check for contract start date
                    IF <lfs_input_item>-z01otc_zcontractdata-start_date IS NOT INITIAL.

                      READ TABLE li_fplt WITH KEY fplnr = <lfs_vbkd>-fplnr
                                                  TRANSPORTING NO FIELDS BINARY SEARCH.
                      IF sy-subrc = 0.
* Don't update begin date
                        lv_upd_beg_dt = abap_false.

                        CLEAR lwa_bapiret.
                        lwa_bapiret-type = lc_msg_type_w.
                        lwa_bapiret-id = lc_msg_id.
                        lwa_bapiret-number = lc_msg_no_157.
                        lwa_bapiret-message_v1 = <lfs_input_item>-id.
                        MESSAGE w157(zotc_msg) WITH <lfs_input_item>-id " Item & has processed Bill status for bill Plan. Start dt not updated.
                                   INTO lwa_bapiret-message.

                        APPEND lwa_bapiret TO ct_message_log.
                      ENDIF. " IF sy-subrc = 0

                    ENDIF. " IF <lfs_input_item>-z01otc_zcontractdata-start_date IS NOT INITIAL

* Check for contract End date
                    IF   <lfs_input_item>-z01otc_zcontractdata-end_date IS NOT INITIAL.

* parallel cursor read
                      READ TABLE li_fplt WITH KEY fplnr = <lfs_vbkd>-fplnr TRANSPORTING NO FIELDS BINARY SEARCH.
                      IF sy-subrc = 0.
                        lv_index = sy-tabix.
                        LOOP AT li_fplt ASSIGNING <lfs_fplt> FROM lv_index.
                          IF <lfs_fplt>-fplnr NE <lfs_vbkd>-fplnr.
                            EXIT.
                          ENDIF. " IF <lfs_fplt>-fplnr NE <lfs_vbkd>-fplnr
* ---> Begin of Change for D2_OTC_IDD_0102/CR D2_52 by DMOIRAN
* Check if SO with bill plan has record in FPLT with completely proceesed status and
* settlement end date less than SMax contract end date

*                          IF <lfs_fplt>-fkdat <= <lfs_input_item>-z01otc_zcontractdata-end_date AND
*                            <lfs_input_item>-z01otc_zcontractdata-end_date <= <lfs_fplt>-nfdat.
                          IF <lfs_input_item>-z01otc_zcontractdata-end_date < <lfs_fplt>-nfdat.
* <--- End    of Change for D2_OTC_IDD_0102/CR D2_52 by DMOIRAN
* end date shouldn't be updated.
                            lv_upd_end_dt = abap_false.
                            CLEAR lwa_bapiret.
                            lwa_bapiret-type = lc_msg_type_w.
                            lwa_bapiret-id = lc_msg_id.
                            lwa_bapiret-number = lc_msg_no_158.
                            lwa_bapiret-message_v1 = <lfs_input_item>-id.
                            MESSAGE w158(zotc_msg) WITH <lfs_input_item>-id " Item & has processed Bill status for bill Plan. End date not updated.
                                       INTO lwa_bapiret-message.
                            APPEND lwa_bapiret TO ct_message_log.
                            EXIT.
                          ENDIF. " IF <lfs_input_item>-z01otc_zcontractdata-end_date < <lfs_fplt>-nfdat
                        ENDLOOP. " LOOP AT li_fplt ASSIGNING <lfs_fplt> FROM lv_index
                      ENDIF. " IF sy-subrc = 0
                    ENDIF. " IF <lfs_input_item>-z01otc_zcontractdata-end_date IS NOT INITIAL
                  ENDIF. " IF <lfs_vbkd>-fplnr IS NOT INITIAL
                ENDIF. " IF sy-subrc = 0

              ENDIF. " IF <lfs_tvap>-fpart IS NOT INITIAL



            ENDIF. " IF sy-subrc = 0

* Acceptance date
            IF <lfs_input_item>-z01otc_zcontractdata-agreement_acceptance_date IS NOT INITIAL.
              lv_acc_date_upd = abap_true.
* if acceptance date already exist then no update is required
              READ TABLE li_veda ASSIGNING <lfs_veda> WITH KEY vbeln = lv_sale_order
                                                               vposn = <lfs_input_item>-id
                                                      BINARY SEARCH.
              IF sy-subrc = 0.
                IF <lfs_veda>-vabndat IS NOT INITIAL.
                  lv_acc_date_upd = abap_false.
                  CLEAR lwa_bapiret.
                  lwa_bapiret-type = lc_msg_type_w.
                  lwa_bapiret-id = lc_msg_id.
*Line item & already has acceptance date.
                  lwa_bapiret-number = lc_msg_no_148.
                  lwa_bapiret-message_v1 = <lfs_input_item>-id.
                  MESSAGE w148(zotc_msg) WITH <lfs_input_item>-id " Line item & already has acceptance date.
                                         INTO lwa_bapiret-message.
                  APPEND lwa_bapiret TO ct_message_log.

                ENDIF. " IF <lfs_veda>-vabndat IS NOT INITIAL

              ENDIF. " IF sy-subrc = 0
            ENDIF. " IF <lfs_input_item>-z01otc_zcontractdata-agreement_acceptance_date IS NOT INITIAL

            READ TABLE li_xi_lord_assign ASSIGNING <lfs_xi_lord_assign> INDEX lv_input_index.
            CHECK sy-subrc = 0.

            IF <lfs_item> IS ASSIGNED OR <lfs_item_x> IS ASSIGNED.
              UNASSIGN: <lfs_item>,
                        <lfs_item_x>.
            ENDIF. " IF <lfs_item> IS ASSIGNED OR <lfs_item_x> IS ASSIGNED

* get the item which has to be modified
* Binary search not used as ct_item_comv and ct_item_comx can't be sorted by handle
* which will disturb the input data sequence

            READ TABLE ct_item_comv ASSIGNING <lfs_item>
                              WITH KEY handle = <lfs_xi_lord_assign>-handle.
            IF sy-subrc = 0.
              READ TABLE ct_item_comx ASSIGNING <lfs_item_x>
                              WITH KEY handle = <lfs_xi_lord_assign>-handle.
              IF sy-subrc NE 0.
                CONTINUE.
              ENDIF. " IF sy-subrc NE 0
            ELSE. " ELSE -> IF sy-subrc NE 0
              CONTINUE.
            ENDIF. " IF sy-subrc = 0



* Update aggreemnt id
            IF <lfs_input_item>-z01otc_zadd_data-agreement_id IS NOT INITIAL.
* pass the input field
              <lfs_item>-zzagmnt = <lfs_input_item>-z01otc_zadd_data-agreement_id.
* set the X flag for the change
              <lfs_item_x>-zzagmnt = abap_true.
            ENDIF. " IF <lfs_input_item>-z01otc_zadd_data-agreement_id IS NOT INITIAL

* Update agreement type
            IF  <lfs_input_item>-z01otc_zadd_data-agreement_type IS NOT INITIAL.
              <lfs_item>-zzagmnt_typ = <lfs_input_item>-z01otc_zadd_data-agreement_type.
              <lfs_item_x>-zzagmnt_typ = abap_true.
            ENDIF. " IF <lfs_input_item>-z01otc_zadd_data-agreement_type IS NOT INITIAL

* Update item ref
            IF <lfs_input_item>-z01otc_zadd_data-obj_ref_id IS NOT INITIAL.
              <lfs_item>-zzitemref = <lfs_input_item>-z01otc_zadd_data-obj_ref_id.
              <lfs_item_x>-zzitemref = abap_true.
            ENDIF. " IF <lfs_input_item>-z01otc_zadd_data-obj_ref_id IS NOT INITIAL

* if end date valiation fails but start date is successful then don't update Start date.
            IF lv_upd_beg_dt = abap_true AND lv_upd_end_dt = abap_false.
              lv_upd_beg_dt = abap_false.
            ENDIF. " IF lv_upd_beg_dt = abap_true AND lv_upd_end_dt = abap_false
* Update contract Start date
            IF <lfs_input_item>-z01otc_zcontractdata-start_date IS NOT INITIAL AND
              lv_upd_beg_dt = abap_true.
              <lfs_item>-zzvbegdat = <lfs_input_item>-z01otc_zcontractdata-start_date.
              <lfs_item_x>-zzvbegdat = abap_true.
            ENDIF. " IF <lfs_input_item>-z01otc_zcontractdata-start_date IS NOT INITIAL AND

* Update Contract end date
            IF <lfs_input_item>-z01otc_zcontractdata-end_date IS NOT INITIAL AND
               lv_upd_end_dt = abap_true.

              <lfs_item>-zzvenddat = <lfs_input_item>-z01otc_zcontractdata-end_date.
              <lfs_item_x>-zzvenddat = abap_true.
            ENDIF. " IF <lfs_input_item>-z01otc_zcontractdata-end_date IS NOT INITIAL AND

* Update agreement acceptance date
            IF <lfs_input_item>-z01otc_zcontractdata-agreement_acceptance_date IS NOT INITIAL
              AND  lv_acc_date_upd = abap_true.
              <lfs_item>-zzvabndat = <lfs_input_item>-z01otc_zcontractdata-agreement_acceptance_date.
              <lfs_item_x>-zzvabndat = abap_true.
            ENDIF. " IF <lfs_input_item>-z01otc_zcontractdata-agreement_acceptance_date IS NOT INITIAL


          ENDLOOP. " LOOP AT lx_input_temp-sales_order_erpchange_request-sales_order-item ASSIGNING <lfs_input_item>


        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF sy-subrc EQ 0
ENDMETHOD.


METHOD if_sls_appl_se_soerpchgrc~outbound_processing.

ENDMETHOD.
ENDCLASS.
