***********************************************************************
*Program    : ZOTCN0095O_CHK_HAZD_PROD                                *
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
*13-APR-2015  MBAGDA       E2DK900468      Defect 5866                *
*                                          Order containing hazardous *
*                                          product.
*                                          Reusing the code for D2_437*
*10-SEP-2015  DARUMUG      E2DK905281      D# 536, 1162 and 1019      *
*                                          Performance tuning changes *
*---------------------------------------------------------------------*
*08-Jun-2016  SMUKHER4     E2DK918037      Def# 1715 :Supress Revenue *
*                                          Split Condition for Ortho  *
*                                          Materials at Sales Order   *
*                                          level.
*&---------------------------------------------------------------------*
*&  Include           ZOTCN0095O_CHK_HAZD_PROD
*&---------------------------------------------------------------------*

CONSTANTS:  lc_null              TYPE z_criteria    VALUE 'NULL',                 " Enh. Criteria
            lc_otc_idd_0095_0007 TYPE z_enhancement VALUE 'D2_OTC_IDD_0095_0007'. " Enhancement


DATA:  li_status  TYPE STANDARD TABLE OF zdev_enh_status. " Enhancement Status

**--> Begin of Change for D2_OTC_EDD_0011 Def#1715 by SMUKHER4 on 08.06.2016
DATA :      lv_pstyp TYPE pstyp,                                " Item Category in Purchasing Document
            li_enh_stat TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
            lr_kschl TYPE RANGE OF kschl,                       " Range table to populate EMI entries
            lwa_kschl LIKE LINE OF lr_kschl.                    " Local Work Area


CONSTANTS : lc_pstyp TYPE pstyp VALUE '5',          " Item Category in Purchasing Document
            lc_kschl TYPE z_criteria VALUE 'KSCHL', " Enh. Criteria
            lc_incl TYPE char01 VALUE 'I',          " Incl of type CHAR01
            lc_eq TYPE char02 VALUE 'EQ'.           " Eq of type CHAR02

FIELD-SYMBOLS: <lfs_enh_stat> TYPE zdev_enh_status. " Enhancement Status


* Call to EMI Function Module To Get List Of EMI Statuses
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_otc_idd_0095_0007 "D2_OTC_IDD_0095_0005
  TABLES
    tt_enh_status     = i_enh_stat.          "Enhancement status table
**<-- End of Change for D2_OTC_EDD_0011 Def#1715 by SMUKHER4 on 08.06.2016
**//-->> Begin of changes - D# 1019 - DARUMUG - 08/27/2015
IF call_activity EQ gc_activity_lord.
  IF gv_hazd_prod NE 'X'.
**//-->> End of changes - D# 1019 - DARUMUG - 08/27/2015
**--> Begin of Delete for D2_OTC_EDD_0011 Def#1715 by SMUKHER4 on 08.06.2016
* Call to EMI Function Module To Get List Of EMI Statuses
*    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
*      EXPORTING
*        iv_enhancement_no = lc_otc_idd_0095_0007 "D2_OTC_IDD_0095_0005
*      TABLES
*        tt_enh_status     = i_enh_stat.          "Enhancement status table
**<-- End of Delete for D2_OTC_EDD_0011 Def#1715 by SMUKHER4 on 08.06.2016
*Non active entries are removed.
    DELETE i_enh_stat WHERE active EQ abap_false.
**//-->> Begin of changes -D# 1019 - DARUMUG - 08/27/2015
  ENDIF. " IF gv_hazd_prod NE 'X'
  READ TABLE i_enh_stat WITH KEY criteria = lc_null TRANSPORTING NO FIELDS. "NULL.
  IF sy-subrc EQ 0.
    gv_hazd_prod = 'X'.
*If call is from Enterprise service(ES) then CALL_ACTIVITY will be equal
*to "LORD" and setting of flag logic for Dangerous Goods is only needed
*for ES call.

*  IF call_activity EQ gc_activity_lord.   "D2_PGL

* Set VBAK-CONT_DG if the product is dangerous
    CALL FUNCTION 'ZOTC_SET_FLG_DANG_GOOD'
      IMPORTING
        ex_set_dang_good = vbak-cont_dg.

  ENDIF. " IF sy-subrc EQ 0

ENDIF. " IF call_activity EQ gc_activity_lord
**//-->> End of changes - D# 1019 - DARUMUG - 08/27/2015

**--> Begin of Change for D2_OTC_EDD_0011 Def#1715 by SMUKHER4 on 08.06.2016
*Copying the contents in the local internal table
li_enh_stat[] = i_enh_stat[].
*Non active entries are removed.
DELETE li_enh_stat WHERE active EQ abap_false.

*Previous NULl check is within call_activity  check  and
*hence cannot be  reused for this  change. Hence another null  check is added
READ TABLE li_enh_stat WITH KEY criteria = lc_null TRANSPORTING NO FIELDS. "NULL.

IF sy-subrc IS INITIAL.
  DELETE li_enh_stat WHERE criteria <> lc_kschl.
*Populating the values maintained in the EMI in a range table

  LOOP AT li_enh_stat ASSIGNING <lfs_enh_stat>.
    lwa_kschl-sign = lc_incl.
    lwa_kschl-option = lc_eq.
    lwa_kschl-low = <lfs_enh_stat>-sel_low.
    lwa_kschl-high = <lfs_enh_stat>-sel_high.
    APPEND lwa_kschl TO lr_kschl.
    CLEAR lwa_kschl.
  ENDLOOP. " LOOP AT li_enh_stat ASSIGNING <lfs_enh_stat>

  UNASSIGN <lfs_enh_stat>.

  IF xkomv[] IS NOT INITIAL.
    SELECT SINGLE pstyp " Item Category in Purchasing Document
      INTO lv_pstyp
      FROM tvep         " Sales Document: Schedule Line Categories
      WHERE ettyp = vbep-ettyp.

* Considered as Dropshipment Scenario
    IF sy-subrc IS INITIAL AND
       lv_pstyp = lc_pstyp.
* Delete condition types ZRER, ZSER and ZEQR
      DELETE xkomv WHERE kposn = vbep-posnr
                   AND   kschl IN lr_kschl.
    ENDIF. " IF sy-subrc IS INITIAL AND
  ENDIF. " IF xkomv[] IS NOT INITIAL
ENDIF. " IF sy-subrc IS INITIAL
**<-- End of Change for D2_OTC_EDD_0011 Def#1715 by SMUKHER4 on 08.06.2016
