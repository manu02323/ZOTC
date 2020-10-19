*&---------------------------------------------------------------------*
*&  Include           ZOTCN0095O_DISCOUNT_ITEM_CATG
*&---------------------------------------------------------------------*
***********************************************************************
*Program    : ZOTCN0095O_DISCOUNT_ITEM_CATG                           *
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
*28-Jul-2014  HBADLAN      E2DK900468      CR: D2_37
*30-Dec-2014  SGOSWAM      E2DK900468      Fix for Defect 2684
*                                          Item Category not flipping
*                                          for BOM components in case
*                                          of Free of Charge BOM Header
*21-JAN-2014  SGUPTA4      E2DK900468      Defect#3128,Making EMI     *
*                                          enhancement number unique. *
*03-FEB-2015  SGUPTA4      E2DK900468      CR D2_437: Item Category   *
*                                          flip logic for a multilevel*
*                                          BOM item.                  *
*17-May-2016  AMOHAPA      E2DK917879      Defect#1718: Item category *
*                                          flipping functionality for *
*                                          FOC scenario in case of    *
*                                          BOM and dropship items     *
*26-APR-2017  U033959      E1DK927432      Defect#2503 - Net value for*
*                                          FOC material should be 0   *
*---------------------------------------------------------------------*

TYPES : BEGIN OF lty_t184,
        auart TYPE auart,     " Sales Document Type
        mtpos TYPE mtpos,     " Item category group from material master
        vwpos TYPE vwpos,     " Item usage
        uepst TYPE uepst,     " Item category of the higher-level item
        pstyv TYPE pstyv,     " Sales document item category
        END OF lty_t184,

        BEGIN OF lty_status,
        sign   TYPE ddsign,   " Type of SIGN component in row type of a Ranges type
        option TYPE ddoption, " Type of OPTION component in row type of a Ranges type
        low    TYPE wbstk,    " Total goods movement status
        high   TYPE wbstk,    " Total goods movement status
        END OF lty_status,
* ---> Begin of Insert for D3_OTC_IDD_0095 defect#2503 by U033959
        BEGIN OF lty_pstyv,
          sign   TYPE ddsign,   " Type of SIGN component in row type of a Ranges type
          option TYPE ddoption, " Type of OPTION component in row type of a Ranges type
          low    TYPE pstyv,    " Item category
          high   TYPE pstyv,    " Item category
        END OF lty_pstyv.
* <--- End of Insert for D3_OTC_IDD_0095 defect#2503 by U033959


* ---> Begin of Delete for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
*DATA : li_constant   TYPE TABLE OF zdev_enh_status,          " Enhancement Status
* <--- End   of Delete for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
DATA: li_status     TYPE STANDARD TABLE OF zdev_enh_status, "Enhancement Status table
      li_del_stat   TYPE TABLE OF lty_status,
      li_ord_stat   TYPE TABLE OF lty_status,
* ---> Begin of Insert for D3_OTC_IDD_0095 defect#2503 by U033959
      li_item_cat   TYPE TABLE OF lty_pstyv, " range for item category
* <--- End of Insert for D3_OTC_IDD_0095 defect#2503 by U033959
      lwa_del_stat  TYPE lty_status,
      lwa_ord_stat  TYPE lty_status,
      lwa_vbup      TYPE vbup,                              " Sales Document: Item Status
      lx_t184       TYPE lty_t184,
      lv_order_bill TYPE fkrel,                             " Relevant for Billing
      lv_zfre       TYPE vwpos,                             " Item usage
      lv_cond       TYPE kschl,                             " Condition Type
      lv_index      TYPE sytabix,                           " XVBAP local table index
* ---> Begin of Insert for CR D2_437, D2_OTC_IDD_0095 by SGUPTA4
      lv_uepos      TYPE uepos, " Higher-level item in bill of material structures
      lv_uepst      TYPE uepst, " Item category of the higher-level item
* <--- End   of Insert for CR D2_437, D2_OTC_IDD_0095 by SGUPTA4
* ---> Begin of Insert for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
      lv_flag1       TYPE char1,    "Set flag to avoide SCI+ error
* <--- End of Insert for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
* ---> Begin of Insert for D3_OTC_IDD_0095 defect#2503 by U033959
      lv_pricing     TYPE prsfd.   " pricing
* <--- End of Insert for D3_OTC_IDD_0095 defect#2503 by U033959


FIELD-SYMBOLS: <lfs_constants> TYPE zdev_enh_status, " Enhancement Status
               <lfs_status>    TYPE zdev_enh_status, " Enhancement Status
* ---> Begin of Insert for CR D2_437, D2_OTC_IDD_0095 by SGUPTA4
               <lfs_xvbap>  TYPE vbapvb, " Document Structure for XVBAP/YVBAP
               <lfs_xvbap1> TYPE vbapvb, " Document Structure for XVBAP/YVBAP
* <--- End   of Insert for CR D2_437, D2_OTC_IDD_0095 by SGUPTA4
* ---> Begin of Insert for D3_OTC_IDD_0095 defect#2503 by U033959
               <lfs_item_cat>  TYPE lty_pstyv. " item category
* <--- End of Insert for D3_OTC_IDD_0095 defect#2503 by U033959
* ---> Begin of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
*CONSTANTS : lc_0091          TYPE z_enhancement  VALUE 'D2_OTC_IDD_0091',      "Enhancement No.
*            lc_idd_0095_001  TYPE z_enhancement  VALUE 'D2_OTC_IDD_0095_001',  "Enhancement No.
*            lc_idd_0095_002  TYPE z_enhancement  VALUE 'D2_OTC_IDD_0095_002',  "Enhancement
CONSTANTS: lc_idd_0095_0006 TYPE z_enhancement  VALUE 'D2_OTC_IDD_0095_0006', "Enhancement
* <--- End   of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
           lc_null         TYPE z_criteria     VALUE 'NULL',          "Enh. Criteria
           lc_kschl        TYPE char5          VALUE 'KSCHL',         "Condition Type
           lc_item_usg     TYPE z_criteria     VALUE 'ITEM_USG',      "Item usage
           lc_lfsta        TYPE lfsta          VALUE 'A',             "Delivery status
           lc_fksta        TYPE fksta          VALUE 'A',             "Billing status of delivery-related billing documents
           lc_fksaa        TYPE fksaa          VALUE 'A',             "Billing Status for Order-Related Billing Documents
           lc_case_del     TYPE char13         VALUE 'CASE_DELIVERY', "Enh. Criteria
           lc_case_ord     TYPE char10         VALUE 'CASE_ORDER',    "Enh. Criteria
* ---> Begin of Insert for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
           lc_case_ord1    TYPE char10         VALUE 'CASE_ORDER_1', "Enh. Criteria
* <--- End   of Insert for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
* ---> Begin of Insert for D3_OTC_IDD_0095 defect#2503 by U033959
           lc_item_cat     TYPE z_criteria     VALUE 'PSTYV',        "Enh. Criteria
           lc_pricing      TYPE z_criteria     VALUE 'PRSFD'.        "Enh. Criteria
* <--- End of Insert for D3_OTC_IDD_0095 defect#2503 by U033959


* ---> Begin of Delete for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4

***Call to EMI Function Module To Get List Of EMI Statuses. Then checking NULL
***criteria for active flag. If it's active then only further code is excuted.
**CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
**  EXPORTING
**    iv_enhancement_no = lc_idd_0095_001 "D2_OTC_IDD_0095_001
**  TABLES
**    tt_enh_status     = li_status.      "Enhancement status table
**
*** Delete all deactive criteria
**DELETE li_status WHERE active = space.
**READ TABLE li_status WITH KEY criteria = lc_null "NULL
**                     TRANSPORTING NO FIELDS.
**IF sy-subrc EQ 0.
***Requirement is divided into Order related billing check and Delivery related
***billing check (depends on TVAP-FKREL values). Those constants are saved
***in EMI tool under enhancment no. 'D2_OTC_IDD_0091'
**
*** Setting all the constant values.
**  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
**    EXPORTING
**      iv_enhancement_no = lc_0091
**    TABLES
**      tt_enh_status     = li_constant.

* <--- End   of Delete for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4


* ---> Begin of Insert for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4

*Call to EMI Function Module To Get List Of EMI Statuses. Then checking NULL
*criteria for active flag. If it's active then only further code is excuted.
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_idd_0095_0006 "D2_OTC_IDD_0095_0006
  TABLES
    tt_enh_status     = li_status.       "Enhancement status table

* <--- End   of Insert for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4


*first thing is to check for field criterion,for value “NULL” and field Active value:
*i.If the value is: “X”, the overall Enhancement is active and can proceed further for checks
*ii.If the  value is:space, then do not proceed further for this enhancement
** Delete all deactive criteria

* ---> Begin of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
*  DELETE li_constant WHERE active = space.
*  READ TABLE li_constant WITH KEY criteria = lc_null
*                         TRANSPORTING NO FIELDS.
DELETE li_status WHERE active = space.
READ TABLE li_status WITH KEY criteria = lc_null
                       TRANSPORTING NO FIELDS.
* <--- End   of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
IF sy-subrc = 0.
* ---> Begin of Insert for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
   CLEAR lv_flag1.
* <--- End of Insert for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA

**Collecting the values for which the logic needs to be excluded.
* ---> Begin of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
*    LOOP AT li_constant ASSIGNING <lfs_constants>.
*      IF <lfs_constants>-criteria = lc_case_del. "CASE_DELIVERY
*        lwa_del_stat-sign   = <lfs_constants>-sel_sign.
*        lwa_del_stat-option = <lfs_constants>-sel_option.
*        lwa_del_stat-low    = <lfs_constants>-sel_low.
*        lwa_del_stat-high   = <lfs_constants>-sel_high.
*        APPEND lwa_del_stat TO li_del_stat.
*        CLEAR lwa_del_stat.
*      ELSEIF <lfs_constants>-criteria = lc_case_ord. "CASE_ORDER
*        lwa_ord_stat-sign   = <lfs_constants>-sel_sign.
*        lwa_ord_stat-option = <lfs_constants>-sel_option.
*        lwa_ord_stat-low    = <lfs_constants>-sel_low.
*        lwa_ord_stat-high   = <lfs_constants>-sel_high.
*        APPEND lwa_ord_stat TO li_ord_stat.
*        CLEAR lwa_ord_stat.
*      ENDIF. " LOOP AT li_constant ASSIGNING <lfs_constants>
*    ENDLOOP. " IF sy-subrc = 0
*  ENDIF. " IF sy-subrc EQ 0
*
*  REFRESH li_status[].

*Collecting the values for which the logic needs to be excluded.
  LOOP AT li_status ASSIGNING <lfs_status>.
    IF <lfs_status>-criteria = lc_case_del. "CASE_DELIVERY
      lwa_del_stat-sign   = <lfs_status>-sel_sign.
      lwa_del_stat-option = <lfs_status>-sel_option.
      lwa_del_stat-low    = <lfs_status>-sel_low.
      lwa_del_stat-high   = <lfs_status>-sel_high.
      APPEND lwa_del_stat TO li_del_stat.
      CLEAR lwa_del_stat.
    ELSEIF <lfs_status>-criteria = lc_case_ord. "CASE_ORDER
      lwa_ord_stat-sign   = <lfs_status>-sel_sign.
      lwa_ord_stat-option = <lfs_status>-sel_option.
      lwa_ord_stat-low    = <lfs_status>-sel_low.
      lwa_ord_stat-high   = <lfs_status>-sel_high.
      APPEND lwa_ord_stat TO li_ord_stat.
      CLEAR lwa_ord_stat.
* ---> Begin of Insert for D3_OTC_IDD_0095 defect#2503 by U033959
    ELSEIF <lfs_status>-criteria = lc_item_cat.
      APPEND INITIAL LINE TO li_item_cat ASSIGNING <lfs_item_cat>.
      <lfs_item_cat>-sign   = <lfs_status>-sel_sign.
      <lfs_item_cat>-option = <lfs_status>-sel_option.
      <lfs_item_cat>-low    = <lfs_status>-sel_low.
      UNASSIGN <lfs_item_cat>.
    ELSEIF <lfs_status>-criteria = lc_pricing.
        lv_pricing = <lfs_status>-sel_low.
* <--- End of Insert for D3_OTC_IDD_0095 defect#2503 by U033959
    ENDIF. " LOOP AT li_status ASSIGNING <lfs_status>
  ENDLOOP. " IF sy-subrc = 0
* <--- End   of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4

* ---> Begin of Delete for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4

**Calling EMI FM with Enhancement no. D2_OTC_IDD_0095_002
**to get all required constants.
*  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
*    EXPORTING
*      iv_enhancement_no = lc_idd_0095_002 "D2_OTC_IDD_0095_002
*    TABLES
*      tt_enh_status     = li_status.      "Enhancement status table
*
** Delete all deactive criteria
*  DELETE li_status WHERE active = space.
**Criteria “NULL” in LI_STATUS is checked ,If it has Active flag as “X”.
*  READ TABLE li_status WITH KEY criteria = lc_null "NULL
*                       TRANSPORTING NO FIELDS.
*  IF sy-subrc EQ 0.
**Fetching order related biling type from EMI

* <--- End   of Delete for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4

* ---> Begin of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
*    READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_case_ord.
  READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_case_ord1.
* <--- End   of Change for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
  IF sy-subrc EQ 0.
    lv_order_bill = <lfs_status>-sel_low.
  ENDIF. " IF sy-subrc EQ 0
  UNASSIGN <lfs_status>.
*Fetching Condition type for 100% discount from EMI.
  READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_kschl.
  IF sy-subrc EQ 0.
    lv_cond = <lfs_status>-sel_low.
  ENDIF. " IF sy-subrc EQ 0
  UNASSIGN <lfs_status>.
*Fetching Item usage (ZFRE)EMI.
  READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_item_usg.
  IF sy-subrc EQ 0.
    lv_zfre = <lfs_status>-sel_low.
  ENDIF. " IF sy-subrc EQ 0

*
*Enhancement needs to only for order types = ZWEB, ZOR, ZSTD & ZKE
*So fetching item category from T184 based on Item category group,
*Item usage ='ZFRE' (ZFRE  Free Item Cat Det),UEPST(Item cat of higher-level item)
  IF maapv-mtpos IS NOT INITIAL.

* ---> Begin of Insert for CR D2_437, D2_OTC_IDD_0095 by SGUPTA4
*In case of a multi-level BOM item
    READ TABLE xvbap ASSIGNING <lfs_xvbap> WITH KEY posnr = vbap-posnr.
    IF sy-subrc EQ 0.
      lv_uepos = <lfs_xvbap>-uepos.
*If UEPOS is initial, it means it is the higher level BOM item
      IF lv_uepos IS INITIAL.
        lv_uepst = space.
      ELSE. " ELSE -> IF lv_uepos IS INITIAL
*If UEPOS is not initial then it means it is a lower level BOM component
        READ TABLE xvbap ASSIGNING <lfs_xvbap1> WITH KEY posnr = lv_uepos.
        IF sy-subrc EQ 0.
          lv_uepst = <lfs_xvbap1>-pstyv.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF lv_uepos IS INITIAL
    ENDIF. " IF sy-subrc EQ 0

* <--- End   of Insert for CR D2_437, D2_OTC_IDD_0095 by SGUPTA4

    SELECT SINGLE auart     " Sales Document Type
                  mtpos     " Item category group from material master
                  vwpos     " Item usage
                  uepst     " Item category of the higher-level item
                  pstyv     " Default item category for the document
    FROM t184               " Sales Documents: Item Category Determination
    INTO lx_t184
    WHERE auart = vbak-auart
    AND mtpos   = maapv-mtpos
    AND vwpos   = lv_zfre
    AND uepst   = lv_uepst. "space.

    IF sy-subrc EQ 0.

*Now Check billing relevance (check TVAP-FKREL for the item category),pricing type
*indicator( TVAP-PRFSD.),Document number of the reference document

      IF tvap-prsfd EQ abap_true.
        IF vbap-vgbel IS INITIAL.
*DELIVERY RELATED BILLING CHECK
          IF  tvap-fkrel IN  li_del_stat.
            CLEAR lwa_vbup.
            READ TABLE xvbup INTO lwa_vbup WITH KEY posnr = vbap-posnr.
            IF sy-subrc EQ 0.
              IF lwa_vbup-lfsta = lc_lfsta OR "A
                 lwa_vbup-lfsta IS INITIAL.   " Bagda-For create order case
* ---> Begin of Insert for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
                IF vbap-uepos IS NOT INITIAL. "Check for higher line item
* Sort and Binary search not required for table XKOMV since it is retrieved in runtime
                  READ TABLE xkomv WITH KEY kposn = vbap-uepos
                                            kschl = lv_cond
                                   TRANSPORTING NO FIELDS .
                  IF sy-subrc = 0.
                    lv_flag1 = abap_true. "Set flag to avoide SCI+ error
                  ENDIF. " IF sy-subrc = 0
                ELSE. " ELSE -> IF sy-subrc = 0
* <--- End of Insert for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
                  READ TABLE xkomv WITH KEY kposn = vbap-posnr
                                            kschl = lv_cond
                                   TRANSPORTING NO FIELDS .
* ---> Begin of Insert for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
                  IF sy-subrc = 0.
                    lv_flag1 = abap_true."Set flag to avoide SCI+ error
                  ENDIF. " IF sy-subrc = 0
                ENDIF. " IF sy-subrc EQ 0
                IF lv_flag1 = abap_true.
* <--- End of Insert for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
* ---> Begin of Delete for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
*                IF sy-subrc EQ 0.
* <--- End of Delete for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
                  IF maapv-matnr EQ vbap-matnr.
                    IF ( ( lx_t184-auart EQ vbak-auart ) AND ( lx_t184-mtpos = maapv-mtpos ) ).
                      vbap-pstyv = lx_t184-pstyv.
* ---> Begin of Insert for D2_OTC_IDD_0095 Defect 2684 by SGOSWAM
*                     Pass the value of the Item Category to the corresponding
*                     Line item details in internal table XVBAP
                      xvbap-pstyv = lx_t184-pstyv.
                      READ TABLE xvbap[] WITH KEY posnr = vbap-posnr
                                         TRANSPORTING NO FIELDS.
                      IF sy-subrc = 0.
                        lv_index = sy-tabix.
                        MODIFY xvbap FROM xvbap INDEX lv_index
                                    TRANSPORTING pstyv.
                      ENDIF. " IF sy-subrc = 0
* <--- End    of Insert for D2_OTC_IDD_0095 Defect 2684 by SGOSWAM
*
                      gv_flip_flag = abap_true.
                    ENDIF. " IF ( ( lx_t184-auart EQ vbak-auart ) AND ( lx_t184-mtpos = maapv-mtpos ) )
                  ENDIF. " IF maapv-matnr EQ vbap-matnr
                ENDIF. " IF lv_flag1 = abap_true
              ENDIF. " IF tvap-fkrel IN li_del_stat
            ENDIF. " IF vbap-vgbel IS INITIAL

*ORDER RELATED BILLING CHECK
          ELSEIF  tvap-fkrel IN li_ord_stat.
            CLEAR lwa_vbup.
            READ TABLE xvbup INTO lwa_vbup WITH KEY posnr  = vbap-posnr.
            IF sy-subrc EQ 0.
              IF lwa_vbup-fksaa = lc_fksaa OR "A
                 lwa_vbup-fksaa IS INITIAL.   " Bagda-For create order case
* ---> Begin of Insert for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
                IF vbap-uepos IS NOT INITIAL. "Check for higher line item
* Sort and Binary search not required for table XKOMV since it is retrieved in runtime
                  READ TABLE xkomv WITH KEY kposn = vbap-uepos
                                            kschl = lv_cond
                                   TRANSPORTING NO FIELDS .
                  IF sy-subrc = 0.
                    lv_flag1 = abap_true."Set flag to avoide SCI+ error
                  ENDIF. " IF sy-subrc = 0
                ELSE. " ELSE -> IF sy-subrc = 0
* <--- End of Insert for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
                  READ TABLE xkomv WITH KEY kposn = vbap-posnr
                                            kschl = lv_cond
                                      TRANSPORTING NO FIELDS .
* ---> Begin of Insert for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
                  IF sy-subrc = 0.
                    lv_flag1 = abap_true."Set flag to avoide SCI+ error
                  ENDIF. " IF sy-subrc = 0
                ENDIF. " IF sy-subrc EQ 0
                IF lv_flag1 = abap_true.
* <--- End of Insert for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
* ---> Begin of Delete for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
*                IF sy-subrc EQ 0.
* <--- End of Delete for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
                  IF maapv-matnr EQ vbap-matnr.
                    IF ( ( lx_t184-auart EQ vbak-auart ) AND ( lx_t184-mtpos = maapv-mtpos ) ).
                      vbap-pstyv = lx_t184-pstyv.
                      gv_flip_flag = abap_true.
                    ENDIF. " IF ( ( lx_t184-auart EQ vbak-auart ) AND ( lx_t184-mtpos = maapv-mtpos ) )
                  ENDIF. " IF maapv-matnr EQ vbap-matnr
                ENDIF. " IF lv_flag1 = abap_true
              ENDIF. " IF tvap-prsfd EQ abap_true
            ENDIF. " IF sy-subrc EQ 0

          ELSEIF tvap-fkrel = lv_order_bill.
            CLEAR lwa_vbup.
            READ TABLE xvbup INTO lwa_vbup WITH KEY posnr  = vbap-posnr.
            IF sy-subrc EQ 0.
              IF lwa_vbup-fksta = lc_fksta OR "A
                 lwa_vbup-fksta IS INITIAL.   " Bagda-For create order case
* ---> Begin of Insert for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
                IF vbap-uepos IS NOT INITIAL. "Check for higher line item
* Sort and Binary search not required for table XKOMV since it is retrieved in runtime
                  READ TABLE xkomv WITH KEY kposn = vbap-uepos
                                            kschl = lv_cond
                                   TRANSPORTING NO FIELDS .
                  IF sy-subrc = 0.
                    lv_flag1 = abap_true."Set flag to avoide SCI+ error
                  ENDIF. " IF sy-subrc = 0
                ELSE. " ELSE -> IF sy-subrc = 0
* <--- End of Insert for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
                  READ TABLE xkomv WITH KEY kposn = vbap-posnr
                                            kschl = lv_cond
                                   TRANSPORTING NO FIELDS .
* ---> Begin of Insert for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
                  IF sy-subrc = 0.
                    lv_flag1 = abap_true."Set flag to avoide SCI+ error
                  ENDIF. " IF sy-subrc = 0
                ENDIF. " IF sy-subrc EQ 0
                IF lv_flag1 = abap_true.
* <--- End of Insert for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
* ---> Begin of Delete for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
*                IF sy-subrc EQ 0.
* <--- End of Delete for D2_OTC_IDD_0095 Defect#1718 by AMOHAPA
                  IF maapv-matnr EQ vbap-matnr.
                    IF ( ( lx_t184-auart EQ vbak-auart ) AND ( lx_t184-mtpos = maapv-mtpos ) ).
                      vbap-pstyv = lx_t184-pstyv.
                      gv_flip_flag = abap_true.
                    ENDIF. " IF ( ( lx_t184-auart EQ vbak-auart ) AND ( lx_t184-mtpos = maapv-mtpos ) )
                  ENDIF. " IF maapv-matnr EQ vbap-matnr
                ENDIF. " if lv_flag1 = abap_true
              ENDIF. " IF maapv-mtpos IS NOT INITIAL
            ENDIF. " IF tvap-prsfd EQ abap_true
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF maapv-mtpos IS NOT INITIAL
* ---> Begin of Insert for D3_OTC_IDD_0095 defect#2503 by U033959
*     If item category is flipped to ZYNN and pricing needs to be carried out
*     Set the global field GV_FLIP_FLAG to X. This will carry out the repricing
*     for the line item and set net amout to 0.
      ELSEIF tvap-prsfd EQ lv_pricing AND
             vbap-pstyv IN li_item_cat.

        gv_flip_flag = abap_true.

* <--- End of Insert for D3_OTC_IDD_0095 defect#2503 by U033959
      ENDIF.
    ENDIF.
  ENDIF.
ENDIF. " IF sy-subrc EQ 0
