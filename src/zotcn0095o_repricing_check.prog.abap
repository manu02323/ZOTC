*&---------------------------------------------------------------------*
*&  Include           ZOTCN0095O_REPRICING_CHECK
*&---------------------------------------------------------------------*
***********************************************************************
*Program    :  ZOTCN0095O_REPRICING_CHECK                             *
*Title      : Item Category flip  on 100 % discount                   *
*Developer  : Harshit Badlani                                         *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0095                                           *
*---------------------------------------------------------------------*
*Description:Simulate Sales Order to retrieve ATP information, prices,*
*            taxes and handling charges for subscribing applications  *
*CR D2_37   : This CR invloves Item Category flip  whenever 100 %     *
*discount is given on a line item in order to change 'NET PRICE' to 0 *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*05-Aug-2014  HBADLAN      E2DK900468      CR: D2_37
*21-JAN-2014  SGUPTA4      E2DK900468      Defect#3128,Making EMI     *
*                                          enhancement number unique. *
*---------------------------------------------------------------------*
* ---> Begin of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
*CONSTANTS : lc_idd_0095_001 TYPE z_enhancement VALUE 'D2_OTC_IDD_0095_001', " Enhancement No.
CONSTANTS : lc_idd_0095_0004 TYPE z_enhancement VALUE 'D2_OTC_IDD_0095_0004', " Enhancement No.
* <--- End   of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
            lc_new_price    TYPE char1         VALUE 'C',                   " Nprice of type CHAR1
            lc_null         TYPE z_criteria    VALUE 'NULL'.                " Enh. Criteria

DATA : li_status   TYPE STANDARD TABLE OF zdev_enh_status. "Enhancement Status table

*Call to EMI Function Module To Get List Of EMI Statuses. Then checking NULL
*criteria for active flag. If it's active then only further code is excuted.
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
* ---> Begin of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
*    iv_enhancement_no = lc_idd_0095_001 "D2_OTC_IDD_0095_001
    iv_enhancement_no = lc_idd_0095_0004 "D2_OTC_IDD_0095_0004
* <--- End   of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
  TABLES
    tt_enh_status     = li_status.      "Enhancement status table

READ TABLE li_status WITH KEY criteria = lc_null "NULL
                              active = abap_true "X"
                     TRANSPORTING NO FIELDS.
IF sy-subrc EQ 0.
  IF gv_flip_flag =  abap_true.
    new_pricing = lc_new_price.
  ENDIF. " IF gv_flip_flag = abap_true
  CLEAR gv_flip_flag.
ENDIF. " IF sy-subrc EQ 0
