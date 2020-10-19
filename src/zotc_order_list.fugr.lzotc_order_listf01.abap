************************************************************************
* PROGRAM    :  ZOTC_GET_ORDER_LIST (FM)                               *
* TITLE      :  Interface for retrieving the order list from           *
*               Bio Rad SAP (ECC) based on the request from EVo        *
* DEVELOPER  :  AVIK PODDAR                                            *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D2_OTC_IDD_0091                                          *
*----------------------------------------------------------------------*
* DESCRIPTION: Population of Order List and Order Status               *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT  DESCRIPTION                        *
* ===========  ========  ========== ===================================*
* 16-MAY-2014  APODDAR   E2DK900460 Initial Development                *
* 27-JUN-2014  APODDAR   E2DK900460 D2_OTC_IDD_0091_CR01               *
* 12-AUG-2014  APODDAR   E2DK900460 D2_OTC_IDD_0091_CR_D2_75           *
* 04-APR-2015  APODDAR   E2DK900460 Defect 5762 VBAP Total Qty         *
* Calculation done for Order related Items only                        *
* 14-APR-2015  SMEKALA   E2DK900460 Defect#5842                        *
* 30-APR-2015  APODDAR   E2DK900460 Defect#6148                        *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE LZOTC_ORDER_LISTF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_ORDER_LIST
*&---------------------------------------------------------------------*
*       Calculate the Status of Orders and prepare Final List
*----------------------------------------------------------------------*
*      -->FP_I_VBAK  List of Sales Orders
*      <--FP_I_ORDER_RES  Final List with Status
*----------------------------------------------------------------------*
FORM f_get_order_list  CHANGING fp_i_vbak      TYPE zotc_sales_ordr_tbl
                                fp_i_order_res TYPE zotc_put_ordr_status_tbl.

  DATA: lv_ord_val  TYPE netwr_ap. " Net value of the order item in document currency

  SORT: fp_i_vbak   BY sales_order_number,
        i_vbap      BY vbeln,
        i_sales_doc BY vbeln.

  FIELD-SYMBOLS: <lfs_vbak>      TYPE zotc_sales_ordr, " Sales Order Number
                 <lfs_sales_doc> TYPE ty_vbak.


  LOOP AT fp_i_vbak ASSIGNING <lfs_vbak>.
 "Read Order List
    READ TABLE i_sales_doc ASSIGNING <lfs_sales_doc>
                       WITH KEY vbeln = <lfs_vbak>-sales_order_number
                       BINARY SEARCH.
    IF sy-subrc EQ 0.
 "storing order information in final table
      wa_order_res-sales_order_number   = <lfs_sales_doc>-vbeln.
      wa_order_res-reference_id         = <lfs_sales_doc>-zzdocref.
 "wa_order_res-po_number           = <lfs_sales_doc>-bstnk. "Change for CR01 APODDAR 26th June 2014
 "wa_order_res-order_value         = <lfs_sales_doc>-netwr. "Changes by Avik Poddar for CR D2_75 on August 12th 2014
      wa_order_res-order_value_currency = <lfs_sales_doc>-waerk.
* Begin of Change for D2_OTC_IDD_0091_CR01 by APODDAR ON 27TH Jun 2014
      READ TABLE i_vbkd ASSIGNING <fs_vbkd>
          WITH KEY vbeln = <lfs_sales_doc>-vbeln.
      IF sy-subrc = 0.
        wa_order_res-po_number          = <fs_vbkd>-bstkd.
        wa_order_res-po_date            = <fs_vbkd>-bstdk.
      ENDIF. " IF sy-subrc = 0
* End of Change for D2_OTC_IDD_0091_CR01 by APODDAR ON 27TH Jun 2014
    ENDIF. " IF sy-subrc EQ 0
    READ TABLE i_vbap TRANSPORTING NO FIELDS
                      WITH KEY vbeln = <lfs_vbak>-sales_order_number
                      BINARY SEARCH.
    IF sy-subrc = 0.
      CLEAR gv_tabix_vbap.
      gv_tabix_vbap = sy-tabix.
      LOOP AT i_vbap ASSIGNING <fs_vbap>
        FROM gv_tabix_vbap.
        IF <fs_vbap>-vbeln NE <lfs_vbak>-sales_order_number.
          EXIT.
        ENDIF. " IF <fs_vbap>-vbeln NE <lfs_vbak>-sales_order_number

        IF <fs_vbap>-fkrel IN i_del_stat.
          PERFORM f_get_order_status_del.
        ELSEIF <fs_vbap>-fkrel IN i_ord_stat.
          PERFORM f_get_order_status_ordr.
        ENDIF. " IF <fs_vbap>-fkrel IN i_del_stat

* -- Begin of Changes by Avik Poddar for CR D2_75 on August 12th 2014 -- *
 "Logic for Order Value Calculation
        IF ( <fs_vbap>-pstyv NOT IN i_doc_typ
       AND <fs_vbap>-kowrr IS INITIAL )
       AND <fs_vbap>-abgru IS INITIAL.
          lv_ord_val = lv_ord_val + <fs_vbap>-netwr + <fs_vbap>-mwsbp.
        ENDIF. " IF ( <fs_vbap>-pstyv NOT IN i_doc_typ
* -- End of Changes by Avik Poddar for CR D2_75 on August 12th 2014 -- *
      ENDLOOP. " LOOP AT i_vbap ASSIGNING <fs_vbap>
    ENDIF. " IF sy-subrc = 0
* -- Begin of Changes by Avik Poddar for CR D2_75 on August 12th 2014 -- *
    wa_order_res-order_value = lv_ord_val.
    CLEAR lv_ord_val.
* -- End of Changes by Avik Poddar for CR D2_75 on August 12th 2014 -- *
    UNASSIGN: <fs_vbap>.
 "Identifying Overall Order Status
    IF gv_flg_del_part GT 0.
      wa_order_res-status      = c_three. "
      wa_order_res-status_text = 'Partially Shipped'(002).
      APPEND wa_order_res TO fp_i_order_res.
      CLEAR wa_order_res.
    ELSEIF gv_flg_del_ship GT 0
      AND gv_flg_del_part  EQ 0
      AND gv_flg_inprocess EQ 0.
      wa_order_res-status      = c_four.
      wa_order_res-status_text = 'Shipped'(003).
      APPEND wa_order_res TO fp_i_order_res.
      CLEAR wa_order_res.
    ELSEIF gv_flg_inprocess GT 0
      AND gv_flg_del_ship   GT 0.
      wa_order_res-status      = c_three. "Partially Shipped
      wa_order_res-status_text = 'Partially Shipped'(002).
      APPEND wa_order_res TO fp_i_order_res.
      CLEAR wa_order_res.
    ELSEIF gv_flg_inprocess GT 0
       AND gv_flg_del_part  EQ 0
       AND gv_flg_del_ship  EQ 0.
      wa_order_res-status      = c_two. "In Process
      wa_order_res-status_text = 'In Process'(001).
      APPEND wa_order_res TO fp_i_order_res.
      CLEAR wa_order_res.
    ENDIF. " IF gv_flg_del_part GT 0
    CLEAR : gv_flg_inprocess,
            gv_flg_del_part,
            gv_flg_del_ship.
  ENDLOOP. " LOOP AT fp_i_vbak ASSIGNING <lfs_vbak>

ENDFORM. " F_GET_ORDER_LIST
*&---------------------------------------------------------------------*
*&      Form  F_GET_CANCELLED_ORDER
*&---------------------------------------------------------------------*
*       Interpret Cancelled Status and Delete those Orders
*----------------------------------------------------------------------*
*      -->FP_I_VBAK  List of Sales Orders
*      <--FP_I_ORDER_RES  Final List of Orders with Status
*----------------------------------------------------------------------*
FORM f_get_cancelled_order CHANGING fp_i_vbak TYPE zotc_sales_ordr_tbl
                               fp_i_order_res TYPE zotc_put_ordr_status_tbl.

* -- Begin of Changes by Avik Poddar for CR D2_75 12th Aug 14
  DATA:          lv_index    TYPE sy-tabix, " Index of a Table
                 lv_ord_val  TYPE netwr_ap. " Net value of the order item in document currency
* -- End of Changes by Avik Poddar for CR D2_75 12th Aug 14

  FIELD-SYMBOLS: <lfs_vbak>      TYPE zotc_sales_ordr, " Sales Order Number
                 <lfs_sales_doc> TYPE ty_vbak,         " Sales Order Details
                 <lfs_vbuk>      TYPE ty_vbuk.

  SORT i_vbap BY vbeln posnr.
  LOOP AT fp_i_vbak ASSIGNING <lfs_vbak>.
 "Read Order List
    READ TABLE i_sales_doc ASSIGNING <lfs_sales_doc>
                       WITH KEY vbeln = <lfs_vbak>-sales_order_number
                           BINARY SEARCH.
    IF sy-subrc = 0.
 "Storing Order Information in Final Table
      wa_order_res-sales_order_number   = <lfs_sales_doc>-vbeln.
      wa_order_res-reference_id         = <lfs_sales_doc>-zzdocref.
 "wa_order_res-po_number           = <lfs_sales_doc>-bstnk. "Change for CR01 by APODDAR
 "wa_order_res-order_value         = <lfs_sales_doc>-netwr. "Changes by Avik Poddar for CR D2_75 on August 12th 2014
      wa_order_res-order_value_currency = <lfs_sales_doc>-waerk.
* Begin of Change for D2_OTC_IDD_0091_CR01 by APODDAR ON 27TH Jun 2014
      READ TABLE i_vbkd ASSIGNING <fs_vbkd>
            WITH KEY vbeln = <lfs_sales_doc>-vbeln.
      IF sy-subrc = 0.
        wa_order_res-po_number          = <fs_vbkd>-bstkd.
        wa_order_res-po_date            = <fs_vbkd>-bstdk.
      ENDIF. " IF sy-subrc = 0
* End of Change for D2_OTC_IDD_0091_CR01 by APODDAR ON 27TH Jun 2014
    ENDIF. " IF sy-subrc = 0

* -- Begin of Changes by Avik Poddar for CR D2_75 12th Aug 14
    READ TABLE i_vbap TRANSPORTING NO FIELDS
                        WITH KEY vbeln = <lfs_vbak>-sales_order_number
                        BINARY SEARCH.
    IF sy-subrc = 0.
      CLEAR lv_index.
      lv_index = sy-tabix.
      LOOP AT i_vbap ASSIGNING <fs_vbap>
        FROM lv_index.
        IF <fs_vbap>-vbeln NE <lfs_vbak>-sales_order_number.
          EXIT.
        ENDIF. " IF <fs_vbap>-vbeln NE <lfs_vbak>-sales_order_number
* -- Begin of Changes by Avik Poddar for CR D2_75 on August 12th 2014 -- *
 "Logic for Order Value Calculation
        IF ( <fs_vbap>-pstyv NOT IN i_doc_typ
       AND <fs_vbap>-kowrr IS INITIAL )
       AND <fs_vbap>-abgru IS INITIAL.
          lv_ord_val = lv_ord_val + <fs_vbap>-netwr + <fs_vbap>-mwsbp.
        ENDIF. " IF ( <fs_vbap>-pstyv NOT IN i_doc_typ
      ENDLOOP. " LOOP AT i_vbap ASSIGNING <fs_vbap>
      wa_order_res-order_value = lv_ord_val.
      CLEAR lv_ord_val.
      UNASSIGN: <fs_vbap>.
    ENDIF. " IF sy-subrc = 0
* -- End of Changes by Avik Poddar for CR D2_75 12th Aug 14

 "Checking for Overall Rejection Status
    READ TABLE i_vbuk ASSIGNING <lfs_vbuk>
      WITH KEY vbeln = <lfs_vbak>-sales_order_number
      BINARY SEARCH.
    IF sy-subrc EQ 0.
      IF <lfs_vbuk>-abstk        = c_stat_c.
        wa_order_res-status      = c_five. "Cancelled
        wa_order_res-status_text = 'Cancelled'(004).
        APPEND wa_order_res TO fp_i_order_res.
        <lfs_vbak>-sales_order_number = space.
        CLEAR: wa_order_res.
      ENDIF. " IF <lfs_vbuk>-abstk = c_stat_c
    ENDIF. " IF sy-subrc EQ 0
  ENDLOOP. " LOOP AT fp_i_vbak ASSIGNING <lfs_vbak>

 "Delete Cancelled Sales Orders from Processing List
  DELETE fp_i_vbak WHERE sales_order_number IS INITIAL.

ENDFORM. " F_GET_CANCELLED_ORDER
*&---------------------------------------------------------------------*
*&      Form  F_GET_DELIVERY_DOCS
*&---------------------------------------------------------------------*
*       Store Sales Document Flow based on Delivery, PO, Order
*----------------------------------------------------------------------*
*      -->FP_I_VBAK  List of Sales Orders
*      <--FP_I_VBUK_DEL  Order Status List
*      <--FP_I_INV_LIST  Invoice List
*----------------------------------------------------------------------*
FORM f_get_delivery_docs  USING fp_i_vbak     TYPE zotc_sales_ordr_tbl
                       CHANGING fp_i_vbuk_del TYPE ty_tt_vbuk_del.

  FIELD-SYMBOLS: <lfs_vbfa> TYPE ty_vbfa,
                 <lfs_ekes> TYPE ty_ekes.

  DATA: li_vbtyp_v  TYPE TABLE OF ty_status,
        lwa_vbtyp_v TYPE          ty_status.

  CONSTANTS: lc_ordr_typ_i TYPE char1 VALUE 'I'. " Ordr_typ_i of type CHAR1

  lwa_vbtyp_v-sign   = 'I'.
  lwa_vbtyp_v-option = 'EQ'.
  lwa_vbtyp_v-low    = c_stat_c.
  APPEND lwa_vbtyp_v TO li_vbtyp_v.

  lwa_vbtyp_v-sign   = 'I'.
  lwa_vbtyp_v-option = 'EQ'.
  lwa_vbtyp_v-low    = lc_ordr_typ_i.
  APPEND lwa_vbtyp_v TO li_vbtyp_v.


  IF fp_i_vbak IS NOT INITIAL.

*--------Get Sales Document Flow----------*
    SELECT vbelv   " Preceding sales and distribution document
           posnv   " Preceding item of an SD document
           vbeln   " Subsequent sales and distribution document
           posnn   " Subsequent item of an SD document
           vbtyp_n " Document category of subsequent document
           rfmng   " Referenced quantity in base unit of measure
           vbtyp_v " Document category of preceding SD document
      FROM vbfa    " Sales Document Flow
      INTO TABLE i_vbfa
      FOR ALL ENTRIES IN fp_i_vbak
      WHERE vbelv = fp_i_vbak-sales_order_number.
    IF sy-subrc = 0.
      i_vbfa_del[]  = i_vbfa. "delivery
      i_vbfa_po[]   = i_vbfa. "order

      DELETE:  i_vbfa_del  WHERE vbtyp_n NE c_stat_j,
               i_vbfa_del  WHERE vbtyp_v NOT IN li_vbtyp_v,
               i_vbfa_po   WHERE vbtyp_n NE c_stat_v,
* ---> Begin of Change for Defect#5842, D2_OTC_IDD_0091 by SMEKALA
*               i_vbfa_po   WHERE vbtyp_v NE c_stat_c.
               i_vbfa_po   WHERE vbtyp_v NOT IN li_vbtyp_v.
* <--- End of Change for Defect#5842, D2_OTC_IDD_0091 by SMEKALA
      SORT:    i_vbfa_del  BY vbelv vbeln,
               i_vbfa_po   BY vbelv vbeln.

 "Collect Invoices
      LOOP AT i_vbfa ASSIGNING <lfs_vbfa>.
        IF <lfs_vbfa>-vbtyp_n EQ c_stat_m
          AND <lfs_vbfa>-vbtyp_v EQ c_stat_c.
          wa_inv_list-sales_order_number = <lfs_vbfa>-vbelv.
          wa_inv_list-invoice_number     = <lfs_vbfa>-vbeln.
          APPEND wa_inv_list TO i_inv_list.
          CLEAR wa_inv_list.
        ENDIF. " IF <lfs_vbfa>-vbtyp_n EQ c_stat_m
      ENDLOOP. " LOOP AT i_vbfa ASSIGNING <lfs_vbfa>
      SORT i_inv_list BY sales_order_number invoice_number.
      DELETE ADJACENT DUPLICATES FROM i_inv_list COMPARING ALL FIELDS.
    ENDIF. " IF sy-subrc = 0

 "Delivery Related Scenario
    IF NOT i_vbfa_del IS INITIAL.
      SELECT vbeln " Sales and Distribution Document Number
             wbstk " Total goods movement status
             abstk " Overall rejection status of all document items
             gbstk " Overall processing status of document
         FROM vbuk " Sales Document: Header Status and Administrative Data
         INTO TABLE fp_i_vbuk_del
         FOR ALL ENTRIES IN i_vbfa_del
         WHERE vbeln = i_vbfa_del-vbeln.
      IF sy-subrc = 0.
        SORT fp_i_vbuk_del BY vbeln.
        DELETE ADJACENT DUPLICATES FROM fp_i_vbuk_del COMPARING vbeln.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF NOT i_vbfa_del IS INITIAL

 "Collecting PO based on Order
    IF NOT i_vbfa_po IS INITIAL.
      SELECT ebeln " Purchasing Document Number
             ebelp " Item Number of Purchasing Document
             etens " Sequential Number of Vendor Confirmation
             erdat " Creation Date of Confirmation
             menge " Quantity as Per Vendor Confirmation
             vbeln " Delivery
             vbelp " Delivery Item
        FROM ekes  " Vendor Confirmations
        INTO TABLE i_ekes
        FOR ALL ENTRIES IN i_vbfa_po
        WHERE ebeln = i_vbfa_po-vbeln.
      IF sy-subrc = 0.
        DELETE i_ekes WHERE vbeln IS INITIAL.
* ---> Begin of Change for Defect#5842, D2_OTC_IDD_0091 by SMEKALA
        SORT i_ekes BY ebeln ebelp.
*        SORT i_ekes BY ebeln vbelp.
* <--- End of Change for Defect#5842, D2_OTC_IDD_0091 by SMEKALA
        LOOP AT i_ekes ASSIGNING <lfs_ekes>.

* ---> Begin of Change for Defect#5842, D2_OTC_IDD_0091 by SMEKALA
*          wa_ekes_tot-ebeln = <lfs_ekes>-ebeln.
*          wa_ekes_tot-menge = <lfs_ekes>-menge.
*          COLLECT wa_ekes_tot INTO i_ekes_tot.
          READ TABLE i_ekes_tot ASSIGNING <fs_ekes_tot>
                              WITH KEY ebeln = <lfs_ekes>-ebeln
*                                       vbelp = <lfs_ekes>-vbelp
* ---> Begin of Change for Defect#6148, D2_OTC_IDD_0091 by APODDAR
                                       ebelp = <lfs_ekes>-ebelp.
* <--- End of Change for Defect#6148, D2_OTC_IDD_0091 by APODDAR
* <--- End of Change for Defect#5842, D2_OTC_IDD_0091 by SMEKALA
          IF sy-subrc EQ 0.
            <fs_ekes_tot>-menge = <fs_ekes_tot>-menge +
                                  <lfs_ekes>-menge.
          ELSE. " ELSE -> IF sy-subrc EQ 0
            wa_ekes_tot-ebeln = <lfs_ekes>-ebeln.
* ---> Begin of Change for Defect#5842, D2_OTC_IDD_0091 by SMEKALA
            "wa_ekes_tot-vbelp = <lfs_ekes>-vbelp.
* ---> Begin of Change for Defect#6148, D2_OTC_IDD_0091 by APODDAR
            wa_ekes_tot-ebelp = <lfs_ekes>-ebelp.
* <--- End of Change for Defect#6148, D2_OTC_IDD_0091 by APODDAR
            wa_ekes_tot-menge = <lfs_ekes>-menge.
            APPEND wa_ekes_tot TO i_ekes_tot.
          ENDIF. " IF sy-subrc EQ 0
* <--- End of Change for Defect#5842, D2_OTC_IDD_0091 by SMEKALA

        ENDLOOP. " LOOP AT i_ekes ASSIGNING <lfs_ekes>
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF NOT i_vbfa_po IS INITIAL

  ENDIF. " IF fp_i_vbak IS NOT INITIAL

ENDFORM. " F_GET_DELIVERY_DOCS
*&---------------------------------------------------------------------*
*&      Form  F_FETCH_ORDER_DETAILS
*&---------------------------------------------------------------------*
*       Query on Database Tables based on Orders
*----------------------------------------------------------------------*
*      -->FP_I_VBAK List of Sales Orders
*----------------------------------------------------------------------*
FORM f_fetch_order_details USING fp_i_vbak TYPE zotc_sales_ordr_tbl.

* ---> Begin of Insert for Defect#5842,D2_OTC_IDD_0091 by SMEKALA
  CONSTANTS: lc_val_null TYPE fpb_low VALUE 'NULL'. " From Value
* <--- End   of Insert for Defect#5842,D2_OTC_IDD_0091 by SMEKALA

* Local Field Symbol Declaration
  FIELD-SYMBOLS: <lfs_constants> TYPE zdev_enh_status, " Enhancement Status
                 <lfs_vbap>      TYPE ty_vbap.
  IF fp_i_vbak IS NOT INITIAL.
    SORT fp_i_vbak BY sales_order_number.
    DELETE ADJACENT DUPLICATES FROM fp_i_vbak COMPARING sales_order_number.
*--------------------Fetch Sales Orders------------------------*
    SELECT vbeln    " Sales Document
           erdat    " Date on Which Record Was Created
           netwr    " Net Value of the Sales Order in Document Currency
           waerk    " SD Document Currency
           bstnk    " Customer purchase order number
           kunnr    " Sold-to party
           zzdocref " Legacy Doc Ref
           zzdoctyp " Ref Doc type
      FROM vbak     " Sales Document: Header Data
      INTO TABLE i_sales_doc
      FOR ALL ENTRIES IN fp_i_vbak
      WHERE vbeln = fp_i_vbak-sales_order_number.
    IF sy-subrc = 0
   AND i_sales_doc IS NOT INITIAL.
      SORT i_sales_doc BY vbeln.
* Begin of Change for D2_OTC_IDD_0091_CR01 by APODDAR ON 27TH Jun 2014
      DELETE ADJACENT DUPLICATES FROM i_sales_doc COMPARING vbeln.
      SELECT vbeln " Sales and Distribution Document Number
             posnr " Item number of the SD document
             bstkd " Customer purchase order number
             bstdk " Customer purchase order date
        FROM vbkd  " Sales Document: Business Data
        INTO TABLE i_vbkd
        FOR ALL ENTRIES IN i_sales_doc
        WHERE  vbeln = i_sales_doc-vbeln
        AND    posnr = c_posnr.
      IF sy-subrc = 0.
        SORT i_vbkd BY vbeln.
      ENDIF. " IF sy-subrc = 0
* End of Change for D2_OTC_IDD_0091_CR01 by APODDAR ON 27TH Jun 2014
    ELSE. " ELSE -> IF sy-subrc = 0
      RAISE no_order_found.
    ENDIF. " IF sy-subrc = 0
*---------------Fetching Header Status Data--------------------*
    SELECT vbeln "Sales and Distribution Document Number
           wbstk "Total goods movement status
           abstk "Overall rejection status of all document items
           gbstk "Overall processing status of document
      FROM vbuk  " Sales Document: Header Status and Administrative Data
      INTO TABLE i_vbuk
      FOR ALL ENTRIES IN fp_i_vbak
      WHERE vbeln = fp_i_vbak-sales_order_number.
    IF sy-subrc = 0
   AND fp_i_vbak IS NOT INITIAL.
      SORT i_vbuk BY vbeln.
*-------------------Fetching item Data------------------------*
      SELECT vbeln  "Sales Document
             posnr  "Sales Document Item
             pstyv  "Item Category
             fkrel  "Relevant for Billing
             abgru  "Reason for rejection
             netwr  "Currency Value
             kwmeng "Cumulative Order Quantity in Sales Units
* -- Begin of Changes by Avik Poddar for CR D2_75 on August 12th 2014 -- *
             kowrr "Statistical Values
             mwsbp "Tax amount in document currency
* -- End of Changes by Avik Poddar for CR D2_75 on August 12th 2014 -- *
        FROM vbap "Sales Document: Item Data
        INTO TABLE i_vbap
        FOR ALL ENTRIES IN fp_i_vbak
        WHERE vbeln = fp_i_vbak-sales_order_number.
      IF sy-subrc = 0
     AND i_vbap IS NOT INITIAL.
        SORT i_vbap BY vbeln posnr.
                     "Fetching Item Status
        SELECT vbeln "Sales and Distribution Document Number
               posnr "Item number of the SD document
               absta "Rejection status for SD item
               gbsta "Overall processing status of the SD document item
          FROM vbup  " Sales Document: Item Status
          INTO TABLE i_vbup
          FOR ALL ENTRIES IN i_vbap
          WHERE vbeln = i_vbap-vbeln
            AND posnr = i_vbap-posnr.
        IF sy-subrc = 0.
          SORT i_vbup BY vbeln posnr.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0

  ENDIF. " IF fp_i_vbak IS NOT INITIAL

* Begin of Change for Defect 5762
*  LOOP AT i_vbap ASSIGNING <lfs_vbap>.
*    wa_vbap_tot-vbeln  = <lfs_vbap>-vbeln.
*    wa_vbap_tot-kwmeng = <lfs_vbap>-kwmeng.
*      COLLECT wa_vbap_tot INTO i_vbap_tot.
*  ENDLOOP. " LOOP AT i_vbap ASSIGNING <lfs_vbap>
* End   of Change for Defect 5762

* Setting all the constant values.
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = c_idd_0091
    TABLES
      tt_enh_status     = i_constant.

*first thing is to check for field criterion,for value “NULL” and field Active value:
*i.If the value is: “X”, the overall Enhancement is active and can proceed further for checks
*ii.If the  value is:space, then do not proceed further for this enhancement

  DELETE i_constant WHERE active NE abap_true.
* Collecting the values for which the logic needs to be excluded.
  LOOP AT i_constant ASSIGNING <lfs_constants>.
    IF <lfs_constants>-criteria = c_case_del.
      wa_del_stat-sign   = <lfs_constants>-sel_sign.
      wa_del_stat-option = <lfs_constants>-sel_option.
* ---> Begin of Insert for Defect#5842,D2_OTC_IDD_0091 by SMEKALA
      IF <lfs_constants>-sel_low EQ lc_val_null.
        CLEAR wa_del_stat-low.
      ELSE. " ELSE -> IF <lfs_constants>-sel_low EQ lc_val_null
* <--- End   of Insert for Defect#5842,D2_OTC_IDD_0091 by SMEKALA
        wa_del_stat-low    = <lfs_constants>-sel_low.
      ENDIF. " IF <lfs_constants>-sel_low EQ lc_val_null
      wa_del_stat-high   = <lfs_constants>-sel_high.
      APPEND wa_del_stat TO i_del_stat.
      CLEAR wa_del_stat.
    ELSEIF <lfs_constants>-criteria = c_case_ord.
      wa_ord_stat-sign   = <lfs_constants>-sel_sign.
      wa_ord_stat-option = <lfs_constants>-sel_option.
* ---> Begin of Insert for Defect#5842,D2_OTC_IDD_0091 by SMEKALA
* For 3rd Party line item Relevant for Billing will be Null.
      IF <lfs_constants>-sel_low EQ lc_val_null.
        CLEAR wa_ord_stat-low.
      ELSE. " ELSE -> IF <lfs_constants>-sel_low EQ lc_val_null
* <--- End   of Insert for Defect#5842,D2_OTC_IDD_0091 by SMEKALA
        wa_ord_stat-low    = <lfs_constants>-sel_low.
      ENDIF. " IF <lfs_constants>-sel_low EQ lc_val_null
      wa_ord_stat-high   = <lfs_constants>-sel_high.
      APPEND wa_ord_stat TO i_ord_stat.
      CLEAR wa_ord_stat.
* -- Begin of Change CR D2_75 by Avik Poddar on 12th August 2014 -- *
    ELSEIF <lfs_constants>-criteria = c_doc_typ.
      wa_doc_typ-sign   = <lfs_constants>-sel_sign.
      wa_doc_typ-option = <lfs_constants>-sel_option.
      wa_doc_typ-low    = <lfs_constants>-sel_low.
      wa_doc_typ-high   = <lfs_constants>-sel_high.
      APPEND wa_doc_typ TO i_doc_typ.
* -- End of Change CR D2_75 by Avik Poddar on 12th August 2014 -- *
    ENDIF. " IF <lfs_constants>-criteria = c_case_del
  ENDLOOP. " LOOP AT i_constant ASSIGNING <lfs_constants>

* Begin of Change for Defect 5762
  LOOP AT i_vbap ASSIGNING <lfs_vbap>.
    wa_vbap_tot-vbeln  = <lfs_vbap>-vbeln.
    wa_vbap_tot-kwmeng = <lfs_vbap>-kwmeng.
    IF <lfs_vbap>-fkrel IN i_ord_stat.
      COLLECT wa_vbap_tot INTO i_vbap_tot.
    ENDIF. " IF <lfs_vbap>-fkrel IN i_ord_stat
  ENDLOOP. " LOOP AT i_vbap ASSIGNING <lfs_vbap>
*  End of Change for Defect 5762
ENDFORM. " F_FETCH_ORDER_DETAILS
*&---------------------------------------------------------------------*
*&      Form  f_get_order_status_del
*&---------------------------------------------------------------------*
*       Calculation of Status Delivery Based
*----------------------------------------------------------------------*
FORM f_get_order_status_del .

  FIELD-SYMBOLS : <lfs_vbfa_temp> TYPE ty_vbfa,
                  <lfs_vbup>      TYPE ty_vbup,
                  <lfs_vbuk_del>  TYPE ty_vbuk.

  READ TABLE i_vbup
    ASSIGNING <lfs_vbup>
    WITH KEY vbeln = <fs_vbap>-vbeln
             posnr = <fs_vbap>-posnr
             BINARY SEARCH.
  IF sy-subrc EQ 0.
    IF <lfs_vbup>-gbsta = c_stat_b  " Partially processed
    OR <lfs_vbup>-gbsta = c_stat_c. " Completely processed
      SORT i_vbfa_del BY vbelv posnv.
      READ TABLE i_vbfa_del
      TRANSPORTING NO FIELDS
      WITH KEY vbelv = <fs_vbap>-vbeln
               posnv = <fs_vbap>-posnr
               BINARY SEARCH.
      IF sy-subrc = 0.

        CLEAR gv_tabix_vbfa.
        gv_tabix_vbfa = sy-tabix.
        SORT i_vbuk_del BY vbeln.
        LOOP AT i_vbfa_del ASSIGNING <lfs_vbfa_temp>
          FROM gv_tabix_vbfa.
          IF <lfs_vbfa_temp>-vbelv NE <fs_vbap>-vbeln.
* ---> Begin of Insert for Defect#6148, D2_OTC_IDD_0091 by APODDAR
            EXIT.
          ELSEIF <lfs_vbfa_temp>-vbelv EQ <fs_vbap>-vbeln
           AND <lfs_vbfa_temp>-posnv NE <fs_vbap>-posnr.
            EXIT.
* <--- End   of Insert for Defect#6148, D2_OTC_IDD_0091 by APODDAR
          ENDIF. " IF <lfs_vbfa_temp>-vbelv NE <fs_vbap>-vbeln
          READ TABLE i_vbuk_del
          ASSIGNING <lfs_vbuk_del>
          WITH KEY vbeln = <lfs_vbfa_temp>-vbeln
          BINARY SEARCH.
          IF sy-subrc = 0.
            IF <lfs_vbuk_del>-wbstk = c_stat_a. "Not Yet Processed
              gv_flg_inprocess = gv_flg_inprocess + 1.
            ELSEIF <lfs_vbuk_del>-wbstk = c_stat_b. " Partially processed.
              gv_flg_del_part = gv_flg_del_part + 1.
            ELSEIF <lfs_vbuk_del>-wbstk = c_stat_c. " Completely processed
              IF <lfs_vbup>-gbsta = c_stat_c. " Completely processed
                gv_flg_del_ship = gv_flg_del_ship + 1.
              ELSEIF <lfs_vbup>-gbsta = c_stat_b. " Partially processed
                gv_flg_del_part = gv_flg_del_part + 1.
              ENDIF. " IF sy-subrc = 0
            ENDIF. " LOOP AT i_vbfa_del ASSIGNING <lfs_vbfa_temp>
          ELSE. " ELSE -> IF sy-subrc = 0
            gv_flg_inprocess = gv_flg_inprocess + 1.
          ENDIF. " IF sy-subrc = 0
        ENDLOOP. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc EQ 0
    ELSEIF <lfs_vbup>-gbsta = c_stat_a. " Not yet processed
      gv_flg_inprocess = gv_flg_inprocess + 1.
    ENDIF. " IF sy-subrc = 0

  ENDIF.
ENDFORM. " f_get_order_status_del
*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_ALL_DATA
*&---------------------------------------------------------------------*
*       Calculation of Status Order Based
*----------------------------------------------------------------------*
FORM f_clear_all_data .
*-------------Clear all Internal Tables and Work Area-------------*
  CLEAR : i_vbak,
          i_vbap,
          i_vbap_tot,
          i_vbuk,
          i_vbuk_del,
          i_vbup,
          i_vbfa,
          i_vbfa_del,
          i_vbfa_po,
          i_order_res,
          wa_order_res,
          i_ekes_tot,
          i_inv_list,
          i_del_stat,
          i_ord_stat,
          wa_ekes_tot.

ENDFORM. " F_CLEAR_ALL_DATA
*&---------------------------------------------------------------------*
*&      Form  f_get_order_status_ordr
*&---------------------------------------------------------------------*
*       Order Based Scenario Status Determination
*----------------------------------------------------------------------*
FORM f_get_order_status_ordr .

  FIELD-SYMBOLS : <lfs_vbfa_po>  TYPE ty_vbfa, " Sales Document Flow
                  <lfs_vbap_tot> TYPE ty_vbap, " Sales Document Line Total
                  <lfs_ekes_tot> TYPE ty_ekes_tot.
  CLEAR gv_tabix_vbfa.
  SORT i_vbfa_po BY vbelv posnv.
  READ TABLE i_vbfa_po TRANSPORTING NO FIELDS
    WITH KEY vbelv = <fs_vbap>-vbeln
             posnv = <fs_vbap>-posnr
             BINARY SEARCH.
  IF sy-subrc = 0.
    gv_tabix_vbfa = sy-tabix.
    LOOP AT i_vbfa_po ASSIGNING <lfs_vbfa_po>
      FROM gv_tabix_vbfa.
      IF <lfs_vbfa_po>-vbelv NE <fs_vbap>-vbeln.
* ---> Begin of Insert for Defect#6148, D2_OTC_IDD_0091 by APODDAR
        EXIT.
      ELSEIF <lfs_vbfa_po>-vbelv EQ <fs_vbap>-vbeln
       AND <lfs_vbfa_po>-posnv NE <fs_vbap>-posnr.
        EXIT.
* <--- End   of Insert for Defect#6148, D2_OTC_IDD_0091 by APODDAR
      ENDIF. " IF <lfs_vbfa_po>-vbelv NE <fs_vbap>-vbeln
      READ TABLE i_ekes_tot ASSIGNING <lfs_ekes_tot>
        WITH KEY ebeln = <lfs_vbfa_po>-vbeln
* ---> Begin of Insert for Defect#6148, D2_OTC_IDD_0091 by APODDAR
*                 ebelp = <lfs_vbfa_po>-posnv.
                 ebelp = <lfs_vbfa_po>-posnn.
* <--- End   of Insert for Defect#6148, D2_OTC_IDD_0091 by APODDAR
      IF sy-subrc NE 0.
        gv_flg_inprocess = gv_flg_inprocess + 1.
      ELSEIF <fs_vbap>-kwmeng GT <lfs_ekes_tot>-menge.
        gv_flg_del_part = gv_flg_del_part + 1.
      ELSEIF <fs_vbap>-kwmeng LT <lfs_ekes_tot>-menge.
        READ TABLE i_vbap_tot ASSIGNING <lfs_vbap_tot>
          WITH KEY vbeln = <fs_vbap>-vbeln.
        IF sy-subrc = 0.
          IF <lfs_ekes_tot>-menge EQ <lfs_vbap_tot>-kwmeng.
            gv_flg_del_ship = gv_flg_del_ship + 1.
          ELSEIF <lfs_ekes_tot>-menge LT <lfs_vbap_tot>-kwmeng.
            gv_flg_del_part = gv_flg_del_part + 1.
          ENDIF. " IF <lfs_ekes_tot>-menge EQ <lfs_vbap_tot>-kwmeng
        ENDIF. " IF sy-subrc = 0
      ELSEIF <fs_vbap>-kwmeng EQ <lfs_ekes_tot>-menge.
        gv_flg_del_ship = gv_flg_del_ship + 1.
      ENDIF. " IF sy-subrc NE 0
    ENDLOOP. " LOOP AT i_vbfa_po ASSIGNING <lfs_vbfa_po>
    IF sy-subrc NE 0.
      gv_flg_inprocess = gv_flg_inprocess + 1.
    ENDIF. " IF sy-subrc NE 0
  ELSE. " ELSE -> IF sy-subrc NE 0
    gv_flg_inprocess = gv_flg_inprocess + 1.
  ENDIF. " IF sy-subrc = 0

ENDFORM. " f_get_order_status_ordr
