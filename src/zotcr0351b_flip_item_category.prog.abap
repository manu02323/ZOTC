************************************************************************
* PROGRAM    :  ZOTCR0351B_FLIP_ITEM_CATEGORY                          *
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
* =========== ======== ========== =====================================*

REPORT zotcr0351b_flip_item_category NO STANDARD PAGE HEADING
                                             LINE-COUNT 80
                                             LINE-SIZE 80
                                             MESSAGE-ID zotc_msg.

*--INCLUDES------------------------------------------------------------*
INCLUDE zotcn0351b_flip_item_cat_top IF FOUND.

INCLUDE zotcn0351b_flip_item_cat_sel IF FOUND.

INCLUDE zotcn0351b_flip_item_cat_form IF FOUND.

INITIALIZATION.

* Fetch EMI entries
  PERFORM f_fetch_emi_values CHANGING gv_lfsta
                                      r_lfstk.

AT SELECTION-SCREEN.
* check authorizaiton for sales organizaiton
  PERFORM f_check_authorizaiton USING i_sales_org.

* Validation for Sales Organization.
AT SELECTION-SCREEN ON s_vbeln.
  IF s_vbeln[] IS NOT INITIAL.
    PERFORM f_check_sales_doc.
  ENDIF. " IF s_vbeln[] IS NOT INITIAL

* Validation for Sales Organization.
AT SELECTION-SCREEN ON s_vkorg.
  PERFORM f_check_sales_org.

* Validation for distribution channel
AT SELECTION-SCREEN ON s_vtweg.
  IF s_vtweg[] IS NOT INITIAL.
    PERFORM f_check_dist_channel.
  ENDIF. " IF s_vtweg[] IS NOT INITIAL

* Validation for Sales document type
AT SELECTION-SCREEN ON s_auart.
  IF s_auart[] IS NOT INITIAL.
    PERFORM f_check_doc_type.
  ENDIF. " IF s_auart[] IS NOT INITIAL

* Validation for delivery status
AT SELECTION-SCREEN ON p_lfstk.
  PERFORM f_check_delv_status USING r_lfstk.



START-OF-SELECTION.

* Fetch open sales order items
  PERFORM f_fetch_open_salerorder USING    gv_lfsta
                                  CHANGING i_so_header
                                           i_so_item.
  IF i_so_header IS INITIAL OR
     i_so_item IS INITIAL.
    MESSAGE i000 WITH 'No Sales Order selected'(014). " & & & &
    LEAVE LIST-PROCESSING.
  ENDIF. " IF i_so_header IS INITIAL OR

* Flip item category for open sales order item
  PERFORM f_flip_item_category USING    i_so_header
                                        i_so_item
                               CHANGING i_bapi_msg.


END-OF-SELECTION.

* Display BAPI return message in ALV
  IF i_bapi_msg IS NOT INITIAL.
    PERFORM f_display_bapi_msg USING i_bapi_msg.
  ELSE. " ELSE -> IF i_bapi_msg IS NOT INITIAL
    IF gv_so_upd = abap_true.
      MESSAGE i000 WITH 'Item category changed successfully'(015). " & & & &
    ELSE.
      MESSAGE i000 WITH 'No Item category changed'(017).
    ENDIF. " if gv_so_upd = abap_true
  ENDIF. " IF i_bapi_msg IS NOT INITIAL
