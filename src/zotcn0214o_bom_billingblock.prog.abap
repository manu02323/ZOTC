***************************************************************************************************
* PROGRAM    :  ZOTCN0214O_BOM_BILLINGBLOCK                                                       *
* TITLE      :  OTC SAP enhancement on Sales BOMS to Block Sales Order for component conditions   *
* DEVELOPER  :  Sudhanshu Ranjan                                                                  *
* OBJECT TYPE:  Enhancement                                                                       *
* SAP RELEASE:  SAP ECC 6.0                                                                       *
*-------------------------------------------------------------------------------------------------*
* WRICEF ID  : D3_OTC_EDD_0214
*-------------------------------------------------------------------------------------------------*
* DESCRIPTION: Enhancement for D3_OTC_EDD_0214
*-------------------------------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                                           *
*=================================================================================================*
* DATE          USER      TRANSPORT      DESCRIPTION                                              *
* ===========  ========   =========  =============================================================*
* 08.03.2017   U100018    E1DK926641 Defect# 2190: Apply Billing Block on Sales Order for any of  *
*                                    the BOM Component Conditions:                                *
*                                    Case 1)If ZHPR is equal to zero                              *
*                                    Case 2)If ZM00 is greater than zero                          *
*                                    Case 3)Sum of all components for condition ZBCR is not equal *
*                                           to condition ZHPR                                     *
*                                    Case 4)ZPPM condition value for the BOM header is not equal  *
*                                           to ZPPM for BOM components.                           *
*&------------------------------------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZOTCN0214O_BOM_BILLINGBLOCK
*&---------------------------------------------------------------------*

*Declaration Of Field-Symbols
FIELD-SYMBOLS: <lfs_vbap_data>   TYPE vbapvb,          " Field-Symbol for XVBAP Structure
               <lfs_vbap_data1>  TYPE vbapvb,          " Field-Symbol for XVBAP Structure
               <lfs_komv2>       TYPE komv,            " Field-Symbol for Condition Record
               <lfs_komv3>       TYPE komv,            " Field-Symbol for Condition Record
               <lfs_komv4>       TYPE komv,            " Field-Symbol for Condition Record
               <lfs_komv5>       TYPE komv,            " Field-Symbol for Condition Record
               <lfs_komv6>       TYPE komv,            " Field-Symbol for Condition Record
               <lfs_enh_stat>    TYPE zdev_enh_status. " Enhancement Status

*Declaration Of Constants
CONSTANTS: lc_criteria_zppm  TYPE z_criteria    VALUE 'KSCHL_ZPPM',      " Condition type
           lc_criteria_zhpr  TYPE z_criteria    VALUE 'KSCHL_ZHPR',      " Condition type
           lc_criteria_zm00  TYPE z_criteria    VALUE 'KSCHL_ZM00',      " Condition type
           lc_criteria_zbcr  TYPE z_criteria    VALUE 'KSCHL_ZBCR',      " Condition type
           lc_criteria_faksk TYPE z_criteria    VALUE 'FAKSK',           " billing block
           lc_criteria_ucomm TYPE z_criteria    VALUE 'UCOMM',           " System command
           lc_criteria_trtyp TYPE z_criteria    VALUE 'TRTYP',           " Transaction
           lc_crit_trtyp_v   TYPE z_criteria    VALUE 'TRTYP_V',         " Transaction
           lc_criteria_xml   TYPE z_criteria    VALUE 'CALL_ACTIVITY',   " Check for executing xml file
           lc_edd_0214       TYPE z_enhancement VALUE 'D2_OTC_EDD_0214'. " Enhancement

*Local Internal table
DATA: li_edd_0214_status TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
      li_vbap_temp TYPE STANDARD TABLE OF vbapvb.                " Table of XVBAP Type

*Declaration Of Variables
DATA: lv_kschl_zhpr  TYPE kschl,                   " Condition Type ZHPR
      lv_kschl_zm00  TYPE kschl,                   " Condition Type ZM00
      lv_kschl_zbcr  TYPE kschl,                   " Condition Type ZBCR
      lv_kschl_zppm  TYPE kschl,                   " Condition Type ZPPM
      lv_faksk_pd    TYPE faksk,                   " Billing Block
      lv_trtyp_v     TYPE trtyp,                   " Transaction type for change
      lv_lord        TYPE char4,                   " LORD for calling xml file
      lv_zppm_posnr  TYPE posnr_va,                " Sales order item
      lv_zbcr_posnr  TYPE posnr_va,                " Sales order item
      lv_zbcr_comp   TYPE kwert,                   " ZBCR value of Items
      lv_zppm_comp   TYPE kwert,                   " ZPPM value of Items
      lv_zhpr_comp   TYPE kwert,                   " ZHPR value of Header
      lv_zppm_hdr    TYPE kwert,                   " ZPPM value of Header
      lr_trtyp_range TYPE RANGE OF trtyp,          " Transaction type value
      lwa_r_trtyp    LIKE LINE OF  lr_trtyp_range, " Transaction type value
      lr_ucomm_range TYPE RANGE OF syucomm,        " system command value
      lwa_r_ucomm    LIKE LINE OF  lr_ucomm_range. " system command value

CLEAR: lv_kschl_zhpr,
       lv_kschl_zm00,
       lv_kschl_zbcr,
       lv_kschl_zppm,
       lv_faksk_pd,
       lv_zppm_posnr,
       lv_zbcr_posnr,
       lv_zbcr_comp,
       lv_zppm_comp,
       lv_zhpr_comp,
       lv_zppm_hdr,
       lwa_r_trtyp,
       lv_trtyp_v,
       lv_lord,
       lwa_r_ucomm.

FREE:   li_edd_0214_status,
        lr_ucomm_range,
        lr_trtyp_range,
        li_vbap_temp.


CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_edd_0214
  TABLES
    tt_enh_status     = li_edd_0214_status. "Enhancement status table

*Non active entries are removed.
DELETE li_edd_0214_status WHERE active EQ abap_false.

IF li_edd_0214_status  IS NOT INITIAL.

  SORT li_edd_0214_status BY criteria.
* Check if enhancement is active on EMI
  READ TABLE  li_edd_0214_status
              WITH KEY criteria = lc_null
                       BINARY SEARCH
                       TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    LOOP AT li_edd_0214_status ASSIGNING <lfs_enh_stat>.

      IF  <lfs_enh_stat>-criteria = lc_criteria_ucomm.
*Range table for sy-ucomm
        lwa_r_ucomm-sign   = lc_sign_i.
        lwa_r_ucomm-option = lc_option_eq.
        lwa_r_ucomm-low    = <lfs_enh_stat>-sel_low.
        APPEND lwa_r_ucomm TO lr_ucomm_range.
      ENDIF. " IF <lfs_enh_stat>-criteria = lc_criteria_ucomm

      IF  <lfs_enh_stat>-criteria = lc_criteria_trtyp.
*Range table for sy-ucomm
        lwa_r_trtyp-sign   = lc_sign_i.
        lwa_r_trtyp-option = lc_option_eq.
        lwa_r_trtyp-low    = <lfs_enh_stat>-sel_low.
        APPEND lwa_r_trtyp TO lr_trtyp_range.
      ENDIF. " IF <lfs_enh_stat>-criteria = lc_criteria_trtyp
      CLEAR: lwa_r_ucomm, lwa_r_trtyp.

*Taking the call activity into a variable
      IF <lfs_enh_stat>-criteria = lc_criteria_xml.
        lv_lord = <lfs_enh_stat>-sel_low.
      ENDIF. " IF <lfs_enh_stat>-criteria = lc_criteria_xml
*Populating the values maintained in the EMI in a variables
      IF <lfs_enh_stat>-criteria = lc_criteria_zppm.
        lv_kschl_zppm = <lfs_enh_stat>-sel_low.
      ENDIF. " IF <lfs_enh_stat>-criteria = lc_criteria_zppm
      IF <lfs_enh_stat>-criteria = lc_criteria_zhpr.
        lv_kschl_zhpr = <lfs_enh_stat>-sel_low.
      ENDIF. " IF <lfs_enh_stat>-criteria = lc_criteria_zhpr
      IF <lfs_enh_stat>-criteria = lc_criteria_zbcr.
        lv_kschl_zbcr = <lfs_enh_stat>-sel_low.
      ENDIF. " IF <lfs_enh_stat>-criteria = lc_criteria_zbcr
      IF <lfs_enh_stat>-criteria = lc_criteria_zm00.
        lv_kschl_zm00 = <lfs_enh_stat>-sel_low.
      ENDIF. " IF <lfs_enh_stat>-criteria = lc_criteria_zm00
      IF <lfs_enh_stat>-criteria = lc_criteria_faksk.
        lv_faksk_pd = <lfs_enh_stat>-sel_low.
      ENDIF. " IF <lfs_enh_stat>-criteria = lc_criteria_faksk
    ENDLOOP. " LOOP AT li_edd_0214_status ASSIGNING <lfs_enh_stat>

*Trigger the enhancement if the transaction type is change or add
    IF t180-trtyp IN lr_trtyp_range.

* Will get triggred when we press on SAVE button for billing doc and
* and When user check the Release to accounting flag for a billing
* doc whose accounting is blocked
      IF sy-ucomm IN lr_ucomm_range
        OR call_activity = lv_lord. " 'LORD'

        IF xkomv[] IS NOT INITIAL.
*Assigning XVBAP to local internal table and Deleting all entries with UEPOS not equal to ZERO
          li_vbap_temp[] = xvbap[].
          DELETE li_vbap_temp WHERE uepos NE 0.
          LOOP AT li_vbap_temp ASSIGNING <lfs_vbap_data> WHERE stlnr IS NOT INITIAL..
*Case 4 : Check If ZPPM condition value for the BOM header is not equal to ZPPM for BOM components
*Since we are using Standard structure, so it will get hampered if Binary Search is used
*Reading XKOMV without Binary Search
            READ TABLE xkomv ASSIGNING <lfs_komv2>
            WITH KEY knumv = xvbak-knumv
                     kposn = <lfs_vbap_data>-posnr
                     kschl = lv_kschl_zppm.
            IF sy-subrc = 0.
              lv_zppm_hdr = <lfs_komv2>-kwert.
            ENDIF. " IF sy-subrc = 0
****************************************************************************************************
            LOOP AT xvbap ASSIGNING <lfs_vbap_data1> WHERE uepos = <lfs_vbap_data>-posnr.
*Since we are using Standard structure, so it will get hampered if Binary Search is used
*Reading XKOMV without Binary Search
              READ TABLE xkomv ASSIGNING <lfs_komv3>
                WITH KEY knumv = xvbak-knumv
                         kposn = <lfs_vbap_data1>-posnr
                         kschl = lv_kschl_zhpr.
              IF sy-subrc = 0.
*Case 1: Check If ZHPR equals 0 for BOM components
                IF <lfs_komv3>-kwert = 0.
                  xvbak-faksk = lv_faksk_pd.
                  vbak-faksk = lv_faksk_pd.
                  MESSAGE i935(zotc_msg) WITH <lfs_vbap_data1>-posnr. " Billing is blocked as ZHPR equals to 0 for line item &
                  EXIT.
                ELSE. " ELSE -> IF <lfs_komv3>-kwert = 0
*Case 3: Check If Sum of all components for condition ZBCR is not equal to condition ZHPR
                  lv_zhpr_comp = <lfs_komv3>-kwert.
                ENDIF. " IF <lfs_komv3>-kwert = 0
              ENDIF. " IF sy-subrc = 0
****************************************************************************************************
*Case 2 : Check If ZM00 is greater than zero for BOM components
*Since we are using Standard structure, so it will get hampered if Binary Search is used
*Reading XKOMV without Binary Search
              READ TABLE xkomv ASSIGNING <lfs_komv4>
              WITH KEY knumv = xvbak-knumv
                       kposn = <lfs_vbap_data1>-posnr
                       kschl = lv_kschl_zm00.
              IF sy-subrc = 0.
                IF <lfs_komv4>-kwert > 0.
                  xvbak-faksk = lv_faksk_pd.
                  vbak-faksk = lv_faksk_pd.
                  MESSAGE i936(zotc_msg) WITH <lfs_vbap_data1>-posnr. " Billing is blocked as ZM00 is greater than 0 for line item &
                  EXIT.
                ENDIF. " IF <lfs_komv4>-kwert > 0
              ENDIF. " IF sy-subrc = 0
****************************************************************************************************
*Contn. of Case 3: Check If Sum of all components for condition ZBCR is not equal to condition ZHPR
*Since we are using Standard structure, so it will get hampered if Binary Search is used
*Reading XKOMV without Binary Search
              READ TABLE xkomv ASSIGNING <lfs_komv5>
              WITH KEY knumv = xvbak-knumv
                       kposn = <lfs_vbap_data1>-posnr
                       kschl = lv_kschl_zbcr.
              IF sy-subrc = 0.
                lv_zbcr_comp = lv_zbcr_comp + <lfs_komv5>-kwert.
                lv_zbcr_posnr = <lfs_vbap_data1>-posnr.
              ENDIF. " IF sy-subrc = 0
*****************************************************************************************************
*Contn. of Case 4 : Check	If ZPPM condition value for the BOM header is not equal to ZPPM for BOM components
*Since we are using Standard structure, so it will get hampered if Binary Search is used
*Reading XKOMV without Binary Search
              READ TABLE xkomv ASSIGNING <lfs_komv6>
              WITH KEY knumv = xvbak-knumv
                       kposn = <lfs_vbap_data1>-posnr
                       kschl = lv_kschl_zppm.
              IF sy-subrc = 0.
                lv_zppm_comp = lv_zppm_comp + <lfs_komv6>-kwert.
                lv_zppm_posnr = <lfs_vbap_data1>-posnr.
              ENDIF. " IF sy-subrc = 0
            ENDLOOP. " LOOP AT xvbap ASSIGNING <lfs_vbap_data1> WHERE uepos = <lfs_vbap_data>-posnr

            IF xvbak-faksk IS INITIAL OR vbak-faksk IS INITIAL.
              IF lv_zppm_hdr NE lv_zppm_comp.
                xvbak-faksk = lv_faksk_pd.
                vbak-faksk  = lv_faksk_pd.
                MESSAGE i899(zotc_msg) WITH lv_zppm_posnr. " Billing blocked as ZPPM for BOM Header not equals ZPPM for line item &
                EXIT.
              ENDIF. " IF lv_zppm_hdr NE lv_zppm_comp
*****************************************************************************************************
*Contn. of Case 3: Check If Sum of all components for condition ZBCR is not equal to condition ZHPR
              IF lv_zhpr_comp NE lv_zbcr_comp.
                xvbak-faksk = lv_faksk_pd.
                vbak-faksk  = lv_faksk_pd.
                MESSAGE i898(zotc_msg) WITH lv_zbcr_posnr. " Billing blocked as sum of ZBCR components not equals ZHPR for line item &
                EXIT.
              ENDIF. " IF lv_zhpr_comp NE lv_zbcr_comp
            ENDIF. " IF xvbak-faksk IS INITIAL OR vbak-faksk IS INITIAL
            CLEAR: lv_zbcr_comp,lv_zhpr_comp,lv_zppm_comp, lv_zppm_hdr.
          ENDLOOP. " LOOP AT li_vbap_temp ASSIGNING <lfs_vbap_data> where stlnr is not initial

*Unassigning Of All Field-Symbols
          IF <lfs_vbap_data> IS ASSIGNED.
            UNASSIGN <lfs_komv2>.
          ENDIF. " IF <lfs_vbap_data> IS ASSIGNED

          IF <lfs_vbap_data1> IS ASSIGNED.
            UNASSIGN <lfs_komv2>.
          ENDIF. " IF <lfs_vbap_data1> IS ASSIGNED

          IF <lfs_komv2> IS ASSIGNED.
            UNASSIGN <lfs_komv2>.
          ENDIF. " IF <lfs_komv2> IS ASSIGNED

          IF <lfs_komv3> IS ASSIGNED.
            UNASSIGN <lfs_komv3>.
          ENDIF. " IF <lfs_komv3> IS ASSIGNED

          IF <lfs_komv4> IS ASSIGNED.
            UNASSIGN <lfs_komv4>.
          ENDIF. " IF <lfs_komv4> IS ASSIGNED

          IF <lfs_komv5> IS ASSIGNED.
            UNASSIGN <lfs_komv5>.
          ENDIF. " IF <lfs_komv5> IS ASSIGNED

          IF <lfs_komv6> IS ASSIGNED.
            UNASSIGN <lfs_komv6>.
          ENDIF. " IF <lfs_komv6> IS ASSIGNED

          IF <lfs_enh_stat> IS ASSIGNED.
            UNASSIGN <lfs_enh_stat>.
          ENDIF. " IF <lfs_enh_stat> IS ASSIGNED
        ENDIF. " IF xkomv[] IS NOT INITIAL
      ENDIF. " IF sy-ucomm IN lr_ucomm_range
    ENDIF. " IF t180-trtyp IN lr_trtyp_range
  ENDIF. " IF sy-subrc = 0
ENDIF. " IF li_edd_0214_status IS NOT INITIAL
