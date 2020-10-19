class ZCL_IM_IM_SPLIT_DEL_CREATE definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_LE_SHP_GN_DLV_CREATE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_IM_SPLIT_DEL_CREATE IMPLEMENTATION.


METHOD if_ex_le_shp_gn_dlv_create~move_komdlgn_to_likp.
***********************************************************************
*Program    : ZIM_IM_IM_SPLIT_DEL_CREATE                              *
*Title      : Sales Doc to Delivery Doc                               *
*Developer  : Sneha Mukherjee                                         *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_EDD_0021                                           *
*---------------------------------------------------------------------*
*Description: Creation of outbound deliveries should not split based  *
* on the creation time.                                               *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*30-AUG-2017  SMUKHER       E1DK930277      Defect# 3365: INITIAL DEV
*07-Sep-2017  SMUKHER       E1DK930277      Defect# 3365_FUT_Issue:   *
*                                           Changing the document type*
*                                           field to BSTYP instead of *
*                                           VBTYP                     *
*---------------------------------------------------------------------*

*From EMI entry NULL check we will find the enhancement is active or not
*If it is active then only our code should get triggered.

  DATA:  li_zdev_emi   TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Local internal Table
         lr_dcat       TYPE STANDARD TABLE OF fkk_ranges      INITIAL SIZE 0, "Range table for document category
         lwa_emi_dcat  TYPE zdev_enh_status,                                  " Enhancement Status
         lwa_dcat      TYPE fkk_ranges,                                       "Local wokarea for document category
*-->Begin of insert for D3_OTC_EDD_0021_Defect# 3365_FUT_Issue by SMUKHER on 07-sept-2017
         lv_bstyp      TYPE ebstyp. "Local variable for Purchasing Document Category
*<--End of insert for D3_OTC_EDD_0021_Defect# 3365_FUT_Issue by SMUKHER on 07-sept-2017

  CONSTANTS:   lc_enhancement TYPE z_enhancement VALUE 'OTC_EDD_0021', " Enhancement Number
               lc_null        TYPE z_criteria    VALUE 'NULL',         " Null Criteria
*-->Begin of delete for D3_OTC_EDD_0021_Defect# 3365_FUT_Issue by SMUKHER on 07-sept-2017
*               lc_dcat        TYPE z_criteria    VALUE 'VBTYP'.        " Criteria for Document category
*<--End of delete for D3_OTC_EDD_0021_Defect# 3365_FUT_Issue by SMUKHER on 07-sept-2017

*-->Begin of insert for D3_OTC_EDD_0021_Defect# 3365_FUT_Issue by SMUKHER on 07-sept-2017
               lc_dcat        TYPE z_criteria    VALUE 'BSTYP'. " Criteria for Document category
*<--End of insert for D3_OTC_EDD_0021_Defect# 3365_FUT_Issue by SMUKHER on 07-sept-2017

 "calling the function module to get the values

  FREE li_zdev_emi.

  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enhancement
    TABLES
      tt_enh_status     = li_zdev_emi.

 "Deleting the emi entries where active is initial

  DELETE li_zdev_emi WHERE active <> abap_true.

  IF li_zdev_emi IS NOT INITIAL.

    READ TABLE li_zdev_emi WITH KEY criteria = lc_null TRANSPORTING NO FIELDS.

    IF sy-subrc IS INITIAL.

*-->Begin of insert for D3_OTC_EDD_0021_Defect# 3365_FUT_Issue by SMUKHER on 07-sept-2017
"As per the process owner VBTYP may not fill all the time, so instead of using VBTYP
"we have used BSTYP from EKKO

      SELECT SINGLE bstyp     " Purchasing Document Category
             FROM ekko " Purchasing Document Header
             INTO lv_bstyp
             WHERE ebeln = is_xkomdlgn-vgbel.

        IF sy-subrc IS INITIAL.

*<--End of insert for D3_OTC_EDD_0021_Defect# 3365_FUT_Issue by SMUKHER on 07-sept-2017

          LOOP AT li_zdev_emi INTO lwa_emi_dcat.

            CASE lwa_emi_dcat-criteria.

              WHEN lc_dcat.
                lwa_dcat-sign   = lwa_emi_dcat-sel_sign.
                lwa_dcat-option = lwa_emi_dcat-sel_option.
                lwa_dcat-low    = lwa_emi_dcat-sel_low.
                lwa_dcat-high   = lwa_emi_dcat-sel_high.
                APPEND lwa_dcat TO lr_dcat.
                CLEAR  lwa_dcat.
            ENDCASE.


          ENDLOOP. " LOOP AT li_zdev_emi INTO lwa_emi_dcat


          IF lr_dcat[] IS NOT INITIAL.
*-->Begin of delete for D3_OTC_EDD_0021_Defect# 3365_FUT_Issue by SMUKHER on 07-sept-2017
*          IF cs_likp-vbtyp IN lr_dcat.
*<--End of delete for D3_OTC_EDD_0021_Defect# 3365_FUT_Issue by SMUKHER on 07-sept-2017
*-->Begin of insert for D3_OTC_EDD_0021_Defect# 3365_FUT_Issue by SMUKHER on 07-sept-2017
            IF lv_bstyp IN lr_dcat.
*<--End of insert for D3_OTC_EDD_0021_Defect# 3365_FUT_Issue by SMUKHER on 07-sept-2017
*& We will clear out the creation time so that it does not split delivery.
              clear cs_likp-lfuhr .
            ENDIF. " IF lv_bstyp IN lr_dcat

          ENDIF. " IF lr_dcat[] IS NOT INITIAL

*-->Begin of insert for D3_OTC_EDD_0021_Defect# 3365_FUT_Issue by SMUKHER on 07-sept-2017
        CLEAR lv_bstyp.  "Clearing the local variable
        ENDIF. " IF sy-subrc IS INITIAL

*<--End of insert for D3_OTC_EDD_0021_Defect# 3365_FUT_Issue by SMUKHER on 07-sept-2017

      ENDIF. " IF sy-subrc IS INITIAL

    ENDIF. " IF li_zdev_emi IS NOT INITIAL

  ENDMETHOD.


method IF_EX_LE_SHP_GN_DLV_CREATE~MOVE_KOMDLGN_TO_LIPS.
endmethod.
ENDCLASS.
