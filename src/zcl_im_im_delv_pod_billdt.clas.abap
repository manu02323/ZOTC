class ZCL_IM_IM_DELV_POD_BILLDT definition
  public
  final
  create public .

public section.
*"* public components of class ZCL_IM_IM_DELV_POD_BILLDT
*"* do not include other source files here!!!

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_LE_SHP_DELIVERY_PROC .
protected section.
*"* protected components of class ZCL_IM_IM_DELV_POD_BILLDT
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_IM_DELV_POD_BILLDT
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_IM_DELV_POD_BILLDT IMPLEMENTATION.


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


method IF_EX_LE_SHP_DELIVERY_PROC~FILL_DELIVERY_HEADER.
endmethod.


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


METHOD if_ex_le_shp_delivery_proc~save_document_prepare.
************************************************************************
* Class      :  ZCL_IM_CL_IM_DELIVERY_POD                              *
* Title      :  Add custom columns to MRP list                         *
* Developer  :  Babli Samanta                                          *
* Object Type:  BADI / Class Method                                    *
* SAP Release:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0090 - Billing Date Equals POD Date In Delivery  *
*----------------------------------------------------------------------*
* Description: The required functionality is to populate the Billing
*              Date equal to the POD Date in the Delivery Document
*              when the POD is done
*----------------------------------------------------------------------*
* Modification History:                                                *
*======================================================================*
* Date        User     Transport  Description                          *
* =========== ======== ========== =====================================*
* 24-Jun-2013 BMAJI    E1DK910836 Initial development                  *
* 18-May-2016 AMOHAPA  E2DK917883 Defect#1520 for Inter-company billing*
*                                 delivery POD Date is copied to       *
*                                 Intercompany Billing Date            *
* 05-Dec-2016 PDEBARU  E1DK922143 CR# 256 : Deactivate BADI for all    *
*                                 sales org except 2045 (Spain)        *
*&---------------------------------------------------------------------*
  FIELD-SYMBOLS: <lfs_xlikp_date> TYPE likpvb. "Data of XLIKP

  CONSTANTS: lc_v_change TYPE trtyp VALUE 'V', "Transaction type-change
             lc_h_add    TYPE trtyp VALUE 'H'. "Transaction type-add

*--->Begin of change for D2_OTC_EDD_0090 Defect#1520 By AMOHAPA on 17-May-2016
  CONSTANTS: lc_lfart  TYPE z_criteria VALUE 'LFART',                     " Enh. Criteria
*--->Begin of insert for D3_OTC_EDD_0090 CR# 256 By PDEBARU
            lc_vkorg  TYPE z_criteria VALUE 'VKORG',
*<---End of insert for D3_OTC_EDD_0090 CR# 256  By PDEBARU

            lc_enhancement TYPE z_enhancement VALUE 'D2_OTC_EDD_0090'. " Enhancement No.

  DATA:     li_zdev_emi TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Enhancement Status
            lr_lfart TYPE RANGE OF lfart,                                      " Structure: Select Options
*--->Begin of insert for D3_OTC_EDD_0090 CR# 256 By PDEBARU
            lv_flg   TYPE flag,                                               " flag to check sales org
*<---End of insert for D3_OTC_EDD_0090 CR# 256  By PDEBARU
            lwa_lfart LIKE LINE OF lr_lfart.                                   " Structure: Select Options

  FIELD-SYMBOLS: <lfs_zdev_emi> TYPE zdev_enh_status, " Field-symbol for ZDEV_ENH_STATUS
*<---End of change for D2_OTC_EDD_0090 Defect#1520  By AMOHAPA on 17-May-2016
*--->Begin of insert for D3_OTC_EDD_0090 CR# 256 By PDEBARU
                <lfs_xlikp>    TYPE likpvb.
*<---End of insert for D3_OTC_EDD_0090 CR# 256  By PDEBARU

  IF if_trtyp = lc_v_change OR if_trtyp = lc_h_add.

*--->Begin of change for D2_OTC_EDD_0090 Defect#1520  By AMOHAPA on 17-May-2016
*Creating EMI entry for LFART value 'ZNC3'.
    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
      EXPORTING
        iv_enhancement_no = lc_enhancement
      TABLES
        tt_enh_status     = li_zdev_emi.

    IF sy-subrc IS INITIAL.
      DELETE li_zdev_emi WHERE active <> abap_true.
      LOOP AT li_zdev_emi ASSIGNING <lfs_zdev_emi> WHERE criteria = lc_lfart.
        lwa_lfart-sign = <lfs_zdev_emi>-sel_sign.
        lwa_lfart-option = <lfs_zdev_emi>-sel_option.
        lwa_lfart-low = <lfs_zdev_emi>-sel_low.
        APPEND lwa_lfart TO lr_lfart.
        CLEAR lwa_lfart.
      ENDLOOP. " LOOP AT li_zdev_emi ASSIGNING <lfs_zdev_emi> WHERE criteria = lc_lfart
      UNASSIGN: <lfs_zdev_emi>.
    ENDIF. " IF sy-subrc IS INITIAL
*<---End of Change for D2_OTC_EDD_0090 Defect#1520  By AMOHAPA on 17-May-2016

*--->Begin of insert for D3_OTC_EDD_0090 CR# 256 By PDEBARU
    READ TABLE ct_xlikp ASSIGNING <lfs_xlikp> INDEX 1.
    IF  sy-subrc = 0.
* No Binary search required as table will take low entries
      READ TABLE li_zdev_emi TRANSPORTING NO FIELDS WITH KEY criteria = lc_vkorg
                                                             sel_low = <lfs_xlikp>-vkorg. " vkorg = 2045
      IF sy-subrc = 0.
        lv_flg = abap_true.
      ENDIF.
    ENDIF.
    UNASSIGN <lfs_xlikp>.
    IF lv_flg IS NOT INITIAL.
*<--- End of insert for D3_OTC_EDD_0090 CR# 256 By PDEBARU

      LOOP AT ct_xlikp ASSIGNING <lfs_xlikp_date>.
        IF <lfs_xlikp_date>-podat IS NOT INITIAL.
*--->Begin of Change for D2_OTC_EDD_0090 Defect#1520  By AMOHAPA on 17-May-2016
*In case of Inter-Company Billing Delivery
*POD Date is copied to InterCompany Billing Date
*and not the Billing date
          IF <lfs_xlikp_date>-lfart IN lr_lfart.
            <lfs_xlikp_date>-fkdiv = <lfs_xlikp_date>-podat.
          ELSE. " ELSE -> IF <lfs_xlikp_date>-lfart IN lr_lfart
*<---End of Change for D2_OTC_EDD_0090 Defect#1520  By AMOHAPA on 17-May-2016
*&&-- Modify the Billing Date from POD Date
            <lfs_xlikp_date>-fkdat = <lfs_xlikp_date>-podat.
*--->Begin of Change for D2_OTC_EDD_0090 Defect#1520  By AMOHAPA on 17-May-2016
          ENDIF. " IF <lfs_xlikp_date>-lfart IN lr_lfart
*<---End of Change for D2_OTC_EDD_0090 Defect#1520  By AMOHAPA on 17-May-2016
        ENDIF. " IF <lfs_xlikp_date>-podat IS NOT INITIAL
      ENDLOOP. " LOOP AT ct_xlikp ASSIGNING <lfs_xlikp_date>
*--->Begin of insert for D3_OTC_EDD_0090 CR# 256 By PDEBARU
    ENDIF.
*<--- End of insert for D3_OTC_EDD_0090 CR# 256 By PDEBARU
  ENDIF. " IF if_trtyp = lc_v_change OR if_trtyp = lc_h_add

ENDMETHOD.
ENDCLASS.
