class ZCL_OTC_INV_SPLIT definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_FI_INVOICE_RECEIPT_SPLIT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_OTC_INV_SPLIT IMPLEMENTATION.


METHOD if_ex_fi_invoice_receipt_split~activate_automatic_split.
***********************************************************************
*Method     : IF_EX_FI_INVOICE_RECEIPT_SPLIT~ACTIVATE_AUTOMATIC_SPLIT *
*Title      :  Delivery Doc to Biling Doc Copy Control Routines       *
*Developer  : Sayantan Mukherjee                                      *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_EDD_0022                                           *
*---------------------------------------------------------------------*
*Description: inter-company STO invoices are getting split after a    *
*             certain number of line items are reached                *
*             (as maintained in EMI table)                            *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*20-May-2016 SMUKHER4      E2DK917425   D2_OTC_EDD_0022 Defect # 1605 *
*---------------------------------------------------------------------*
*--> Begin of change for D2_OTC_EDD_0022 Def#1605 by SMUKHER4 on 20-MAY-2016

  CONSTANTS: lc_enhancement TYPE z_enhancement VALUE 'D2_OTC_EDD_0022', " Default Status
             lc_value TYPE z_criteria VALUE 'NULL'.                 " Criteria = VALUE

  DATA : li_zdev_emi TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0.

  FIELD-SYMBOLS                                     "<lfs_zdev_emi> TYPE zdev_enh_status, " Field-symbol for ZDEV_ENH_STATUS
                 <lfs_value> TYPE zdev_enh_status . " Field symbol
*Function Module to fetch EMI entries from EMI table
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enhancement
    TABLES
      tt_enh_status     = li_zdev_emi.

*&--First thing is to check for field criterion,for value “VALUE_AP” and
*&--field Active value:
  IF sy-subrc IS INITIAL.
    READ TABLE li_zdev_emi ASSIGNING <lfs_value>
                           WITH KEY criteria = lc_value
                                    active = abap_true.
    IF sy-subrc IS INITIAL.
      e_automatic_split = abap_true.
    ENDIF.
  ENDIF.
*--> End of change for D2_OTC_EDD_0022 Def#1605 by SMUKHER4 on 20-MAY-2016

ENDMETHOD.


method IF_EX_FI_INVOICE_RECEIPT_SPLIT~SET_DOCUMENT_TYPE_SUBSEQ.
endmethod.


METHOD if_ex_fi_invoice_receipt_split~set_number_of_invoice_items.
***********************************************************************
*Method     :IF_EX_FI_INVOICE_RECEIPT_SPLIT~SET_NUMBER_OF_INVOICE_ITEMS*
*Title      :  Delivery Doc to Biling Doc Copy Control Routines       *
*Developer  : Sayantan Mukherjee                                      *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_EDD_0022                                           *
*---------------------------------------------------------------------*
*Description: inter-company STO invoices are getting split after a    *
*             certain number of line items are reached                *
*             (as maintained in EMI table)                            *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*20-May-2016 SMUKHER4      E2DK917425   D2_OTC_EDD_0022 Defect # 1605 *
*---------------------------------------------------------------------*


  DATA: li_zdev_emi TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Local internal Table
        lv_value TYPE i.                                                   " Local Variable to store EMI entry


  CONSTANTS: lc_enhancement TYPE z_enhancement VALUE 'D2_OTC_EDD_0022', " Default Status
             lc_value TYPE z_criteria VALUE 'VALUE_AP'.                 " Criteria = VALUE

  FIELD-SYMBOLS                                     "<lfs_zdev_emi> TYPE zdev_enh_status, " Field-symbol for ZDEV_ENH_STATUS
                 <lfs_value> TYPE zdev_enh_status . " Field symbol
*Function Module to fetch EMI entries from EMI table
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enhancement
    TABLES
      tt_enh_status     = li_zdev_emi.

*&--First thing is to check for field criterion,for value “VALUE_AP” and
*&--field Active value:
  IF sy-subrc IS INITIAL.
    DELETE li_zdev_emi WHERE active <> abap_true.
    SORT li_zdev_emi BY criteria.
    READ TABLE li_zdev_emi ASSIGNING <lfs_value>
                           WITH KEY criteria = lc_value
                           BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lv_value = <lfs_value>-sel_low.

    ENDIF. " IF sy-subrc IS INITIAL
    UNASSIGN <lfs_value>.
  ENDIF. " IF sy-subrc IS INITIAL

  IF lv_value IS NOT INITIAL.
    e_number_of_invoice_items = lv_value.

  ENDIF. " IF lv_value IS NOT INITIAL

ENDMETHOD.
ENDCLASS.
