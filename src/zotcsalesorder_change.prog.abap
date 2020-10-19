************************************************************************
* PROGRAM    :  ZOTCSALESORDER_CHANGE                                  *
* TITLE      :  Update SO with Contract Item number                    *
* DEVELOPER  :  Raghu Achar                                            *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  RTR_EDD_0059 - CR 369, Defect 3630                       *
*----------------------------------------------------------------------*
* DESCRIPTION: Update SO history with Contract Item number             *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT  DESCRIPTION                         *
* =========== ========  ========== ====================================*
* 15-APR-2013 SPANDIT  E1DK910058 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*
REPORT  zotcsalesorder_change NO STANDARD PAGE HEADING
                              LINE-SIZE 132
                              MESSAGE-ID zotc_msg.

************************************************************************
*          INCLUDES
************************************************************************
INCLUDE zotcnsalesorder_change_top.


************************************************************************
*          SELECTION SCREEN DECLARATION
************************************************************************
SELECTION-SCREEN : BEGIN OF BLOCK order WITH FRAME TITLE text-001.
SELECTION-SCREEN SKIP.

SELECT-OPTIONS: s_vbeln FOR gv_vbeln,
                s_auart FOR gv_auart OBLIGATORY,
                s_erdat FOR gv_erdat.
SELECTION-SCREEN : END OF BLOCK order.

************************************************************************
*           START - OF - SELECTION
************************************************************************

START-OF-SELECTION.

* Fetch sales orders from VBAK based on selection criterion
  SELECT vbeln     "Sales Document
    FROM vbak
    INTO TABLE i_vbak
    WHERE vbeln IN s_vbeln AND
          auart IN s_auart AND
          erdat IN s_erdat.
  IF sy-subrc IS INITIAL.
*   Select VBFA entries. This has contract related to a SO
*   Retriving Contract Numbers as a preceding docuemnt of the
*   sales orders selected
    SELECT vbelv     "Preceding sales and distribution document
           posnv     "Preceding item of an SD document
           vbeln     "Subsequent sales and distribution document
           posnn     "Subsequent item of an SD document
      FROM  vbfa
      INTO TABLE i_vbfa
      FOR ALL ENTRIES IN i_vbak
      WHERE vbeln = i_vbak-vbeln.
    IF sy-subrc IS INITIAL.
*     no need to handle sy-subrc
    ENDIF. "If VBFA - selection SY-SUBRC = 0
*   Retriving Sales Order Line Item Status from VBUP table.
*   If the line items are delivered completely, then we will not
*   update the sales order with the contract numner
    SELECT vbeln   "Sales and Distribution Document Number
           posnr   "Item number of the SD document
           lfsta   "Delivery status
      FROM vbup
      INTO TABLE i_vbup
      FOR ALL ENTRIES IN i_vbak
      WHERE vbeln = i_vbak-vbeln AND
            lfsta = c_complete.      "C
    IF sy-subrc IS INITIAL.
      SORT i_vbup BY vbeln posnr.
    ENDIF.  "If VBUP - selection SY-SUBRC = 0
  ELSE.
    MESSAGE i053.
*   Sales order not found
    LEAVE LIST-PROCESSING.
  ENDIF.  "If VBAK - selection SY-SUBRC = 0

* Storing the Unique Contract Numbers as selected from VBFA
  i_vbfa_contract = i_vbfa.
  DELETE ADJACENT DUPLICATES FROM i_vbfa_contract COMPARING vbelv.

  IF i_vbfa_contract IS NOT INITIAL.
*   Get the contract line item details from VBAP table
    SELECT vbeln   "Sales Document
           posnr   "Sales Document Item
           matnr   "Material Number
      FROM vbap
      INTO TABLE i_vbap_contract
      FOR ALL ENTRIES IN i_vbfa_contract
      WHERE  vbeln = i_vbfa_contract-vbelv.
    IF sy-subrc IS INITIAL.
*     no need to handle sy-subrc
    ENDIF. "If VBAP - Selection SY-SUBRC is initial
  ENDIF.  "If I_VBAP_CONTRACT IS NOT INITIAL

* Reading the Contract line item numbers from VBAP entries mapping
* material number of Sales Order
  LOOP AT i_vbak ASSIGNING <fs_vbak>.

    REFRESH : i_sales_documents,
              i_order_headers_out,
              i_order_items_out.

    CLEAR : i_sales_documents,
            i_order_headers_out,
            i_order_items_out,
            wa_bapi_view.

    wa_bapi_view-header = c_flag_on.
    wa_bapi_view-item = c_flag_on.
    wa_sales_documents-vbeln = <fs_vbak>-vbeln.
    APPEND wa_sales_documents TO i_sales_documents.

*   Get Existing Sales Order Details
    CALL FUNCTION 'BAPISDORDER_GETDETAILEDLIST'
      EXPORTING
        i_bapi_view       = wa_bapi_view
      TABLES
        sales_documents   = i_sales_documents
        order_headers_out = i_order_headers_out
        order_items_out   = i_order_items_out.

    wa_order_header_inx-updateflag = c_update_flag.

*   Looping on each sales order line items to get corresponding contract
*   line item number mapping material number
    LOOP AT i_order_items_out INTO wa_order_items_out.
*     Checking if the Sales Order Line item is complete processed or not.
*     If it is completely processed, then we are not going to update the
*     contract line item number.
      READ TABLE i_vbup
      TRANSPORTING NO FIELDS
      WITH KEY vbeln = wa_order_items_out-doc_number
               posnr = wa_order_items_out-itm_number
               BINARY SEARCH.
      IF sy-subrc IS NOT INITIAL.
*       Get the contract reference mapping material number
        READ TABLE  i_vbap_contract ASSIGNING <fs_vbap_contract>
          WITH KEY vbeln = wa_order_items_out-ref_doc
                   matnr = wa_order_items_out-material
                   BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          wa_order_item_in-itm_number = wa_order_items_out-itm_number .
          wa_order_item_in-material =   wa_order_items_out-material.
          wa_order_item_in-ref_doc_it = <fs_vbap_contract>-posnr.
          wa_order_item_in-ref_doc_ca = c_ref_doc_ca.

          wa_order_item_inx-itm_number = wa_order_items_out-itm_number .
          wa_order_item_inx-material = wa_order_items_out-material.
          wa_order_item_inx-ref_doc_it = c_flag_on.
          wa_order_item_inx-ref_doc_ca = c_flag_on.

          APPEND: wa_order_item_in TO i_order_item_in,
                  wa_order_item_inx TO i_order_item_inx.

        ENDIF.    "IF I_VBAP_CONTRACT read SY-SUBRC is initial.
      ENDIF.    "IF VBUP read SY-SUBRC is NOT initial
    ENDLOOP.  "LOOP at I_ORDER_ITEMS_OUT

*   Update sales order
    CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
      EXPORTING
        salesdocument     = <fs_vbak>-vbeln
        order_header_in   = wa_order_header_in
        order_header_inx  = wa_order_header_inx
        behave_when_error = c_bapi_flag
      TABLES
        return            = i_return
        order_item_in     = i_order_item_in
        order_item_inx    = i_order_item_inx.

*   Handle return message - Only displaying the failed messages per
*   Sales Order change
    LOOP AT i_return INTO wa_return WHERE type = c_type_e
                                       OR type = c_type_a.

      MESSAGE ID wa_return-id TYPE wa_return-type NUMBER wa_return-number
              INTO gv_text
              WITH wa_return-message_v1
                   wa_return-message_v2
                   wa_return-message_v3
                   wa_return-message_v4.
      IF gv_flag IS INITIAL.
        gv_flag = c_flag_on.
        NEW-LINE.
        WRITE: <fs_vbak>-vbeln, 15 gv_text.
      ELSE.
        NEW-LINE.
        WRITE 15 gv_text.
      ENDIF.
    ENDLOOP.
*   If no Error / Abort message is returned, then calling COMMIT FM
    IF sy-subrc IS NOT INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = c_flag_on.

      WRITE:/ <fs_vbak>-vbeln, 'Sales Order Updated Successfully'(002).
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ENDIF.

    CLEAR: gv_flag,wa_order_header_in,wa_order_header_inx.
    REFRESH: i_return, i_order_item_in, i_order_item_inx.

  ENDLOOP.
