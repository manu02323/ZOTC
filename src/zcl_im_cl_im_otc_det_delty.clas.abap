class ZCL_IM_CL_IM_OTC_DET_DELTY definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_LE_SHP_DELIVERY_PROC .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_CL_IM_OTC_DET_DELTY IMPLEMENTATION.


method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_DELIVERY_HEADER.

endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_DELIVERY_ITEM.

endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_FCODE_ATTRIBUTES.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_FIELD_ATTRIBUTES.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~CHECK_ITEM_DELETION.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_DELETION.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_FINAL_CHECK.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~DOCUMENT_NUMBER_PUBLISH.
endmethod.


METHOD if_ex_le_shp_delivery_proc~fill_delivery_header.
************************************************************************
* PROGRAM    :  IF_EX_LE_SHP_DELIVERY_PROC~FILL_DELIVERY_HEADER        *
* TITLE      :  D2_OTC_EDD_0234 Determine Delivery type                *
* DEVELOPER  :  Rajendra Panigrahy                                     *
* OBJECT TYPE:  Enhancement(Method)                                    *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  D2_OTC_EDD_0234                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:                                                         *
* Determine Delivery type                                              *
*                                                                      *
* This BAdi is implemented to Determine Delivery type for              *
* Export Delivery                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER    TRANSPORT  DESCRIPTION                          *
* ============ ======= ========== =====================================*
* 25-AUG-2014  RPANIGR E2DK904272 Initial Development                  *
* Determine Delivery type                                              *
*                                                                      *
* This BAdi is implemented to Determine Delivery type for              *
* Export Delivery                                                      *
*&---------------------------------------------------------------------*

* Include program for Export delivery type determination
  INCLUDE zotcn0234o_detrmn_deliv_type. " Include ZPTPN0234O_DETRMN_DELIV_TYPE

ENDMETHOD.


method IF_EX_LE_SHP_DELIVERY_PROC~FILL_DELIVERY_ITEM.

endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~INITIALIZE_DELIVERY.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~ITEM_DELETION.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~PUBLISH_DELIVERY_ITEM.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~READ_DELIVERY.

endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~SAVE_AND_PUBLISH_BEFORE_OUTPUT.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~SAVE_AND_PUBLISH_DOCUMENT.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~SAVE_DOCUMENT_PREPARE.
endmethod.
ENDCLASS.
