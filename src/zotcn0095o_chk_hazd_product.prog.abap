***********************************************************************
*Program    : ZOTCN0095O_CHK_HAZD_PROD_1                              *
*Title      : ES Sales Order Simulation                               *
*Developer  : Shruti Gupta                                            *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0095                                           *
*---------------------------------------------------------------------*
*Description: To identify whether the order contains a Hazardous      *
*             Product                                                 *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*06-FEB-2015  SGUPTA4       E2DK900468      CR D2_437, Identify the   *
*                                           order containing hazardous*
*                                           product.                  *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZOTCN0095O_CHK_HAZD_PROD_1
*&---------------------------------------------------------------------*

CONSTANTS:  lc_null_dg           TYPE z_criteria    VALUE 'NULL',                 " Enh. Criteria
            lc_otc_idd_0095_0007 TYPE z_enhancement VALUE 'D2_OTC_IDD_0095_0007'. " Enhancement


DATA:  li_status_dg  TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
       lv_profl      TYPE adge_profl.                        " Dangerous Goods Indicator Profile

* Call to EMI Function Module To Get List Of EMI Statuses
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_otc_idd_0095_0007 "D2_OTC_IDD_0095_0005
  TABLES
    tt_enh_status     = li_status_dg.        "Enhancement status table

*Non active entries are removed.
DELETE li_status_dg WHERE active EQ abap_false.

READ TABLE li_status_dg WITH KEY criteria = lc_null_dg TRANSPORTING NO FIELDS. "NULL.
IF sy-subrc EQ 0.

  SELECT SINGLE profl " Dangerous Goods Indicator Profile
    FROM mara         " General Material Data
    INTO lv_profl
    WHERE matnr = vbap-matnr.

  IF lv_profl IS NOT INITIAL.

*Passing the value of flag to the importing parameter
    CALL FUNCTION 'ZOTC_GET_FLG_DANG_GOOD'
      EXPORTING
        im_get_dang_good = abap_true.

  ENDIF. " IF lv_profl IS NOT INITIAL

ENDIF. " IF sy-subrc EQ 0
