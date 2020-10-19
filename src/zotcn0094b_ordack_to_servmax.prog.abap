*&---------------------------------------------------------------------*
*&  Include           ZOTCN0094B_ORDACK_TO_SERVMAX
*&---------------------------------------------------------------------*
***********************************************************************
*Program    : ZOTCN0094B_ORDACK_TO_SERVMAX                            *
*Title      : SAP Order Acknowledgement To ServiceMax                 *
*Developer  : Geetanjali Bajpai                                       *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0094                                           *
*---------------------------------------------------------------------*
*Description: For ZSMX Output type,items that have MVGR1 values of    *
*002/003 are only passed,others are deleted. For relevant items an    *
*additional E1EDP02 segment is added below E1EDP01 segment.           *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*26-May-2014  GBAJPAI       E2DK900755     Initial Development
*---------------------------------------------------------------------*
*=========== ============== ============== ===========================*
*08-Oct-2014  APODDAR       E2DK900871     CR D2_125 / CR D2_53
*                                          CHECK BOM MATERIAL GROUP   *
*                                          DEFECT 525
*                                          Partner Function - AP
*---------------------------------------------------------------------*
*09-Jul-2019  ASK           E2DK925166     INC0486880-02 Correct Idoc *
*                                          syntax error in case last  *
*                                          Item has MVGR1 as 002/003  *
*---------------------------------------------------------------------*
REFRESH li_status.

DATA : lv_index1 TYPE sy-tabix, " Index of Internal Tables
       lv_index2 TYPE sy-tabix. " Index of Internal Tables

CONSTANTS: lc_item_seg_e1edp01 TYPE  edi_segnam         " SAP segment
                               VALUE 'E1EDP01',         " Segment Name
           lc_item_seg_e1edp02 TYPE  edi_segnam         " SAP segment
                               VALUE 'E1EDP02',         " Segment Name
           lc_conf_seg_e1cucfg TYPE  edi_segnam         " Segment Name
                               VALUE 'E1CUCFG',         " Config. Data
           lc_huhd_seg_e1edl37 TYPE  edi_segnam         " Handling Unit
                               VALUE 'E1EDL37',
           lc_summ_seg_e1eds01 TYPE  edi_segnam         " Idoc Summary
                               VALUE 'E1EDS01',
           lc_idd_0094         TYPE  z_enhancement      " Enh. No.
                               VALUE 'D2_OTC_IDD_0094', " Enh. No.
           lc_mvgr1            TYPE  z_criteria         " Mat. group 1
                               VALUE 'MVGR1',           " Mat Group
           lc_partner          TYPE z_criteria          " Enh. Criteria
                               VALUE 'PARTNER',
           lc_parvw            TYPE z_criteria          " Enh. Criteria
                               VALUE 'PARVW',
           lc_qualf            TYPE  edi_qualfr         " IDOC qualif.
                               VALUE '056',
           lc_kschl            TYPE  z_criteria         " Condition Type
                               VALUE 'KSCHL',           " Output Type
** Begin of Chnages for Defect # 525 by APODDAR on 10-10-2014

           lc_seg_e1edka1      TYPE  edi_segnam " SAP segment
                               VALUE 'E1EDKA1'. " Segment Name

** End of Chnages for Defect # 525 by APODDAR on 10-10-2014


FIELD-SYMBOLS : <lfs_vbap>     TYPE vbap,  " Sales Document:Item Data
                <lfs_vbap_bom> TYPE vbap,  " Sales Document:Item Data
                <lfs_edidd1>   TYPE edidd, " Idoc data

                <lfs_vbpa>     TYPE vbpa.  " Sales Document: Partner

DATA : lwa_e1edp01    TYPE e1edp01, " Idoc Item
       lwa_e1edp02    TYPE e1edp02, " Idoc Item

** Begin of Chnages for Defect # 525 by APODDAR on 10-10-2014

       lwa_edidd      TYPE edidd,           " Idoc data
       lwa_status     TYPE zdev_enh_status, " Enhancement Status

       lv_e1edka1_idx TYPE sy-tabix,       " Index of Internal Tables
       lv_email       TYPE ad_smtpadr,     " E-Mail Address
       lv_name1       TYPE ad_name1,       " Name 1
       lv_telno       TYPE ad_tlnmbr1,     " First telephone no.: dialling code+number
       lv_parvw       TYPE parvw,         " Partner Function
       lv_partn       TYPE partner.       " Partnership

** End of Chnages for Defect # 525 by APODDAR on 10-10-2014


* Get constants from EMI tools
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_idd_0094 "D2_OTC_EDD_0094
  TABLES
    tt_enh_status     = li_status.

READ TABLE li_status WITH KEY criteria = lc_null   "NULL
                              active   = abap_true "X"
                              TRANSPORTING NO FIELDS.
IF sy-subrc = 0.

  READ TABLE li_status
  INTO lwa_status  WITH KEY criteria = lc_parvw   "NULL
                            active   = abap_true. "X"
  IF sy-subrc EQ 0.
    lv_parvw = lwa_status-sel_low.
  ENDIF. " IF sy-subrc EQ 0

  READ TABLE li_status
  INTO lwa_status  WITH KEY criteria = lc_partner "NULL
                            active   = abap_true. "X"
  IF sy-subrc EQ 0.
    lv_partn = lwa_status-sel_low.
  ENDIF. " IF sy-subrc EQ 0

** Begin of Chnages for Defect # 525 by APODDAR on 10-10-2014

  CLEAR : lwa_edidd,
          lwa_e1edka1.

  READ TABLE dxvbpa ASSIGNING <lfs_vbpa>
    WITH KEY parvw = lv_parvw.
  IF sy-subrc EQ 0.
    SELECT  name1      " Name 1
            tel_number " First telephone no.: dialling code+number
            UP TO 1 ROWS
      FROM adrc                    " Addresses (Business Address Services)
      INTO (lv_name1, lv_telno)
      WHERE addrnumber = <lfs_vbpa>-adrnr.
    ENDSELECT.
    IF sy-subrc EQ 0.
      lwa_e1edka1-parvw = lv_parvw.
      lwa_e1edka1-partn = lv_partn.
      lwa_e1edka1-name1 = lv_name1.
      lwa_e1edka1-telf1 = lv_telno.
    ENDIF. " IF sy-subrc EQ 0
    SELECT smtp_addr " E-Mail Address
      UP TO 1 ROWS
      FROM adr6                   " E-Mail Addresses (Business Address Services)
      INTO lv_email
      WHERE addrnumber = <lfs_vbpa>-adrnr.
    ENDSELECT.
    IF sy-subrc EQ 0.
      lwa_e1edka1-ilnnr = lv_email.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0

**--------Read Segment E1EDK01---------**
  READ TABLE dint_edidd ASSIGNING <lfs_edidd> WITH KEY segnam = lc_seg_e1edka1.
  IF sy-subrc EQ 0.
    lv_e1edka1_idx = sy-tabix.
    lwa_edidd-segnam = lc_seg_e1edka1.
    lwa_edidd-sdata = lwa_e1edka1.
    READ TABLE dint_edidd ASSIGNING <lfs_edidd> WITH KEY segnam = lc_seg_e1edka1
                                                        sdata(2) = lc_parvw.
    IF sy-subrc NE 0.
      INSERT lwa_edidd INTO dint_edidd INDEX lv_e1edka1_idx.
    ENDIF. " IF sy-subrc NE 0
  ENDIF. " IF sy-subrc EQ 0

** End of Chnages for Defect # 525 by APODDAR on 10-10-2014

  DELETE li_status WHERE active = space.
  IF li_status IS NOT INITIAL.
* Check if the sales order in the idoc contains any material that
* does not belong to Material Group 01/02.If any such material
* exists then delete all the data records related to these items.
* MVGR1 values for items can be read from table VBAP.
    lv_index1 = 1.
    SORT dxvbap BY posnr.
    UNASSIGN <lfs_edidd>.
    LOOP AT dint_edidd ASSIGNING <lfs_edidd> FROM lv_index1
                         WHERE segnam = lc_item_seg_e1edp01.
      lv_index1 = sy-tabix.
      lwa_e1edp01 = <lfs_edidd>-sdata.
      READ TABLE dxvbap ASSIGNING <lfs_vbap>
                        WITH KEY posnr = lwa_e1edp01-posex
                        BINARY SEARCH.
      IF sy-subrc = 0.

* Begin of Changes CR CR D2_125 / CR D2_53 by APODDAR on 08th August 2014
        IF <lfs_vbap>-stlnr IS NOT INITIAL
          AND <lfs_vbap>-uepos IS INITIAL.
          READ TABLE li_status WITH KEY criteria = lc_mvgr1
                                         sel_low = <lfs_vbap>-mvgr1
                                          TRANSPORTING NO FIELDS.
          IF sy-subrc EQ 0.
            ASSIGN <lfs_vbap> TO <lfs_vbap_bom>.
          ENDIF. " IF sy-subrc EQ 0
        ELSEIF <lfs_vbap>-stlnr IS INITIAL
        AND <lfs_vbap>-uepos IS INITIAL.
          UNASSIGN <lfs_vbap_bom>.
        ENDIF. " IF <lfs_vbap>-stlnr IS NOT INITIAL

* End of Changes CR CR D2_125 / CR D2_53 by APODDAR on 08th August 2014

*        Check if the output type is SERVICEMAX
        READ TABLE li_status WITH KEY criteria = lc_kschl
                                      sel_low = dobject-kschl
                                      TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          READ TABLE li_status WITH KEY criteria = lc_mvgr1
                                 sel_low = <lfs_vbap>-mvgr1
                                     TRANSPORTING NO FIELDS.
          IF sy-subrc EQ 0.

* Begin of Changes CR CR D2_125 / CR D2_53 by APODDAR on 08th August 2014

            IF <lfs_vbap_bom> IS ASSIGNED.
              IF <lfs_vbap>-uepos = <lfs_vbap_bom>-posnr.
                LOOP AT dint_edidd ASSIGNING <lfs_edidd1> FROM
                ( lv_index1 + 1 ) WHERE segnam = lc_item_seg_e1edp01.
                  lv_index2 = sy-tabix - 1.
                  EXIT.
                ENDLOOP. " LOOP AT dint_edidd ASSIGNING <lfs_edidd1> FROM
* Begin of INC0486880-02
                IF sy-subrc NE 0. " E1EDP01 segment not found
* If E1EDP01 is the last segment.We cannot use E1EDP01 as next segment
* for deleting the segments of the irrelevant material.We will read
* dint_edidd table with proceeding segments of segment E1EDP01.
* This is checked from WE30 transaction for ORDERS05 Basic Type
                  LOOP AT dint_edidd ASSIGNING <lfs_edidd1> WHERE
                          segnam = lc_conf_seg_e1cucfg OR
                          segnam = lc_huhd_seg_e1edl37 OR
                          segnam = lc_summ_seg_e1eds01.
                    lv_index2 = sy-tabix - 1.
                    EXIT.
                  ENDLOOP. " LOOP AT dint_edidd ASSIGNING <lfs_edidd1> WHERE
                ENDIF. " IF sy-subrc EQ 0
* End   of INC0486880-02
                DELETE dint_edidd FROM lv_index1 TO lv_index2.
              ENDIF. " IF <lfs_vbap>-uepos = <lfs_vbap_bom>-posnr
            ENDIF. " IF <lfs_vbap_bom> IS ASSIGNED

* End of Changes CR CR D2_125 / CR D2_53 by APODDAR on 08th August 2014

            " Material is relevant.Append E1EDP02 segment
            " if zzquoteref is not initial.

            IF <lfs_vbap>-zzquoteref IS NOT INITIAL.
              CLEAR lwa_e1edp02.
              lwa_e1edp02-qualf = lc_qualf.
              lwa_e1edp02-belnr = <lfs_vbap>-zzquoteref.
              lv_index1 = lv_index1 + 1.
*New record to be inserted below E1EDP01
              INSERT INITIAL LINE INTO dint_edidd INDEX lv_index1
              ASSIGNING <lfs_edidd1>.
              <lfs_edidd1>-segnam  = lc_item_seg_e1edp02.
              <lfs_edidd1>-sdata   = lwa_e1edp02.
            ENDIF. " IF <lfs_vbap>-zzquoteref IS NOT INITIAL
          ELSE. " ELSE -> IF <lfs_vbap>-zzquoteref IS NOT INITIAL
            "Material irrelevant,data should be deleted only for KSCHL = ZSMX
            LOOP AT dint_edidd ASSIGNING <lfs_edidd1> FROM
             ( lv_index1 + 1 ) WHERE segnam = lc_item_seg_e1edp01.
              lv_index2 = sy-tabix - 1.
              EXIT.
            ENDLOOP. " LOOP AT dint_edidd ASSIGNING <lfs_edidd1> FROM
            IF sy-subrc NE 0. " E1EDP01 segment not found
* If E1EDP01 is the last segment.We cannot use E1EDP01 as next segment
* for deleting the segments of the irrelevant material.We will read
* dint_edidd table with proceeding segments of segment E1EDP01.
* This is checked from WE30 transaction for ORDERS05 Basic Type
              LOOP AT dint_edidd ASSIGNING <lfs_edidd1> WHERE
                      segnam = lc_conf_seg_e1cucfg OR
                      segnam = lc_huhd_seg_e1edl37 OR
                      segnam = lc_summ_seg_e1eds01.
                lv_index2 = sy-tabix - 1.
                EXIT.
              ENDLOOP. " LOOP AT dint_edidd ASSIGNING <lfs_edidd1> WHERE
            ENDIF. " IF sy-subrc EQ 0
            DELETE dint_edidd FROM lv_index1 TO lv_index2.
          ENDIF. " IF sy-subrc = 0
        ELSE. " ELSE -> IF <lfs_vbap>-uepos = <lfs_vbap_bom>-posnr
*Append E1EDP02 segment for non ZSMX partners
          IF <lfs_vbap>-zzquoteref IS NOT INITIAL.
            CLEAR lwa_e1edp02.
            lwa_e1edp02-qualf = lc_qualf.
            lwa_e1edp02-belnr = <lfs_vbap>-zzquoteref.
            lv_index1 = lv_index1 + 1.
*New record to be inserted below E1EDP01
            INSERT INITIAL LINE INTO dint_edidd INDEX lv_index1
            ASSIGNING  <lfs_edidd1>.
            <lfs_edidd1>-segnam  = lc_item_seg_e1edp02.
            <lfs_edidd1>-sdata   = lwa_e1edp02.
          ENDIF. " IF <lfs_vbap>-zzquoteref IS NOT INITIAL
        ENDIF. " IF sy-subrc = 0
      ENDIF. " LOOP AT dint_edidd ASSIGNING <lfs_edidd> FROM lv_index1
    ENDLOOP. " IF li_status IS NOT INITIAL
  ENDIF. " IF sy-subrc = 0
ENDIF. " IF dobject-kschl = lc_kschl
