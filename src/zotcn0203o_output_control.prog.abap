*&---------------------------------------------------------------------*
*&  Include           ZOTCN0203_OUTPUT_CONTROL
*&---------------------------------------------------------------------*
************************************************************************
* INCLUDE    :  ZOTCN0203_OUTPUT_CONTROL                               *
* TITLE      :  D2_OTC_EDD_0203_Change Sales Order Program             *
* DEVELOPER  :  Debopriya Halder                                       *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D2_OTC_EDD_0203                                          *
*----------------------------------------------------------------------*
* DESCRIPTION: Change Sales Order Program (OSS note 395569)            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT    DESCRIPTION                        *
* =========== ======== ==========  ====================================*
* 23-SEP-2014 DHALDER  E2DK904953   INITIAL DEVELOPMENT                *
* 12-Aug-2016  PDEBARU  E2DK918598 Defect # 1816 : Order Acknowledgement*
*                                  Output control for ServiceMax       *
*&---------------------------------------------------------------------*
  TYPES:
         BEGIN OF lty_vbpa,
           vbeln TYPE vbeln,    " Sales and Distribution Document Number
           posnr TYPE posnr,    " Item number of the SD document
           parvw TYPE parvw,    " Partner Function
         END OF lty_vbpa,

         BEGIN OF lty_vbap,
           vbeln TYPE vbeln_va, " Sales Document
           posnr TYPE posnr_va, " Sales Document Item
         END OF lty_vbap.

  DATA:
        li_vbpa      TYPE STANDARD TABLE OF lty_vbpa,
        li_vbap      TYPE STANDARD TABLE OF lty_vbap,
        li_constants TYPE STANDARD TABLE OF zdev_enh_status. " Enhancement Status

  DATA:
        lv_subrc TYPE sysubrc. " Return Value of ABAP Statements

  DATA:
        lr_bom       TYPE RANGE OF mvgr1, " Material group 1
        lr_nonbom    TYPE RANGE OF mvgr1, " Material group 1
        lr_lsg       TYPE RANGE OF mvgr1, " Material group 1
        lr_parvw_mdt TYPE RANGE OF parvw, " Partner Function
        lr_parvw_opt TYPE RANGE OF parvw. " Partner Function

  DATA:
        lwa_mvgr1 LIKE LINE OF lr_bom,
        lwa_parvw LIKE LINE OF lr_parvw_mdt.


  CONSTANTS:
             lc_tcode_va02   TYPE tcode         VALUE 'VA02',            " Tcode
             lc_trtyp_v      TYPE trtyp         VALUE 'V',               " Transaction type
             lc_null         TYPE z_criteria    VALUE 'NULL',            " Enh. Criteria
             lc_posnr_null   TYPE posnr         VALUE '000000',          " Line item
             lc_updkz_i      TYPE updkz_d       VALUE 'I',               " Update indicator
             lc_updkz_d      TYPE updkz_d       VALUE 'D',               " Update indicator
             lc_etenr_001    TYPE etenr         VALUE '001',             " Delivery Schedule Line Number
             lc_mvgr1_bom    TYPE z_criteria    VALUE 'MVGR1_BOM',       " Enh. Criteria
             lc_mvgr1_nonbom TYPE z_criteria    VALUE 'MVGR1_NONBOM',    " Enh. Criteria
             lc_mvgr1_lsg    TYPE z_criteria    VALUE 'MVGR1_LSG',       " Enh. Criteria
             lc_parvw_mdt    TYPE z_criteria    VALUE 'PARVW_MDT',       " Enh. Criteria
             lc_parvw_opt    TYPE z_criteria    VALUE 'PARVW_OPT',       " Enh. Criteria
             lc_0203         TYPE z_enhancement VALUE 'D2_OTC_EDD_0203'. " Enhancement No.


  FIELD-SYMBOLS:
                 <lfs_xvbep>         TYPE vbepvb,          " Structure of Document for XVBEP/YVBEP
                 <lfs_yvbep>         TYPE vbepvb,          " Structure of Document for XVBEP/YVBEP
                 <lfs_xvbap>         TYPE vbapvb,          " Document Structure for XVBAP/YVBAP
                 <lfs_yvbap>         TYPE vbapvb,          " Document Structure for XVBAP/YVBAP
                 <lfs_xvbpa>         TYPE vbpavb,          " Reference structure for XVBPA/YVBPA
                 <lfs_yvbpa>         TYPE vbpavb,          " Reference structure for XVBPA/YVBPA
                 <lfs_vbpa>          TYPE lty_vbpa,
                 <lfs_xvbkd>         TYPE vbkdvb,          " Reference structure for XVBKD/YVBKD
                 <lfs_yvbkd>         TYPE vbkdvb,          " Reference structure for XVBKD/YVBKD
                 <lfs_constants>     TYPE zdev_enh_status. " Enhancement Status
  lv_subrc = 4.

  IF t180-tcode = lc_tcode_va02
    AND t180-trtyp = lc_trtyp_v.

    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
      EXPORTING
        iv_enhancement_no = lc_0203
      TABLES
        tt_enh_status     = li_constants.

    DELETE li_constants WHERE active = abap_false.
* Check if enhancement is active
    READ TABLE li_constants ASSIGNING <lfs_constants> WITH KEY criteria = lc_null.
    IF sy-subrc = 0.
      LOOP AT li_constants ASSIGNING <lfs_constants>.
        IF <lfs_constants>-criteria = lc_mvgr1_bom.
          lwa_mvgr1-sign   = <lfs_constants>-sel_sign.
          lwa_mvgr1-option = <lfs_constants>-sel_option.
          lwa_mvgr1-low    = <lfs_constants>-sel_low.
          lwa_mvgr1-high   = <lfs_constants>-sel_high.

          APPEND lwa_mvgr1 TO lr_bom.
          CLEAR lwa_mvgr1.
        ELSEIF <lfs_constants>-criteria = lc_mvgr1_nonbom.
          lwa_mvgr1-sign   = <lfs_constants>-sel_sign.
          lwa_mvgr1-option = <lfs_constants>-sel_option.
          lwa_mvgr1-low    = <lfs_constants>-sel_low.
          lwa_mvgr1-high   = <lfs_constants>-sel_high.

          APPEND lwa_mvgr1 TO lr_nonbom.
          CLEAR lwa_mvgr1.
        ELSEIF <lfs_constants>-criteria = lc_mvgr1_lsg.
          lwa_mvgr1-sign   = <lfs_constants>-sel_sign.
          lwa_mvgr1-option = <lfs_constants>-sel_option.
          lwa_mvgr1-low    = <lfs_constants>-sel_low.
          lwa_mvgr1-high   = <lfs_constants>-sel_high.

          APPEND lwa_mvgr1 TO lr_lsg.
          CLEAR lwa_mvgr1.
        ELSEIF <lfs_constants>-criteria = lc_parvw_mdt.
          lwa_parvw-sign   = <lfs_constants>-sel_sign.
          lwa_parvw-option = <lfs_constants>-sel_option.
          lwa_parvw-low    = <lfs_constants>-sel_low.
          lwa_parvw-high   = <lfs_constants>-sel_high.

          APPEND lwa_parvw TO lr_parvw_mdt.
          CLEAR lwa_parvw.
        ELSEIF <lfs_constants>-criteria = lc_parvw_opt.
          lwa_parvw-sign   = <lfs_constants>-sel_sign.
          lwa_parvw-option = <lfs_constants>-sel_option.
          lwa_parvw-low    = <lfs_constants>-sel_low.
          lwa_parvw-high   = <lfs_constants>-sel_high.

          APPEND lwa_parvw TO lr_parvw_opt.
          CLEAR lwa_parvw.
        ENDIF. " IF <lfs_constants>-criteria = lc_mvgr1_bom
      ENDLOOP. " LOOP AT li_constants ASSIGNING <lfs_constants>
      UNASSIGN <lfs_constants>.
      IF lv_subrc NE 0 AND yvbkd[] IS NOT INITIAL.
        LOOP AT yvbkd ASSIGNING <lfs_yvbkd>.
          READ TABLE xvbkd ASSIGNING <lfs_xvbkd> WITH KEY vbeln = <lfs_yvbkd>-vbeln
                                                          posnr = <lfs_yvbkd>-posnr.
          IF sy-subrc = 0 AND <lfs_yvbkd>-bstkd NE <lfs_xvbkd>-bstkd.
            lv_subrc = 0.
            EXIT.
          ENDIF. " IF sy-subrc = 0 AND <lfs_yvbkd>-bstkd NE <lfs_xvbkd>-bstkd
        ENDLOOP. " LOOP AT yvbkd ASSIGNING <lfs_yvbkd>
        UNASSIGN:
                  <lfs_xvbkd>,
                  <lfs_yvbkd>.
      ENDIF. " IF lv_subrc NE 0 AND yvbkd[] IS NOT INITIAL
      IF lv_subrc NE 0 AND yvbpa[] IS NOT INITIAL.
        LOOP AT yvbpa ASSIGNING <lfs_yvbpa> WHERE parvw IN lr_parvw_mdt[]
                                               OR parvw IN lr_parvw_opt[].
          READ TABLE xvbpa ASSIGNING <lfs_xvbpa> WITH KEY posnr = lc_posnr_null
                                                          parvw = <lfs_yvbpa>-parvw.
          IF sy-subrc = 0.
            IF <lfs_yvbpa>-parvw IN lr_parvw_mdt.
              IF <lfs_yvbpa>-kunnr NE <lfs_xvbpa>-kunnr.
                lv_subrc = 0.
                EXIT.
              ENDIF. " IF <lfs_yvbpa>-kunnr NE <lfs_xvbpa>-kunnr
            ELSE. " ELSE -> IF <lfs_yvbpa>-kunnr NE <lfs_xvbpa>-kunnr
              IF <lfs_yvbpa>-pernr NE <lfs_xvbpa>-pernr.
                lv_subrc = 0.
                EXIT.
              ENDIF. " IF <lfs_yvbpa>-pernr NE <lfs_xvbpa>-pernr
            ENDIF. " IF <lfs_yvbpa>-parvw IN lr_parvw_mdt
          ENDIF. " IF sy-subrc = 0
        ENDLOOP. " LOOP AT yvbpa ASSIGNING <lfs_yvbpa> WHERE parvw IN lr_parvw_mdt[]
        UNASSIGN:
                  <lfs_xvbpa>,
                  <lfs_yvbpa>.
      ENDIF. " IF lv_subrc NE 0 AND yvbpa[] IS NOT INITIAL
      IF lv_subrc NE 0 AND yvbap[] IS NOT INITIAL.
        LOOP AT yvbap ASSIGNING <lfs_yvbap>.
          IF lv_subrc NE 0
            AND <lfs_yvbap>-mvgr1 IN lr_nonbom[]
            AND <lfs_yvbap>-stlnr IS INITIAL.
            READ TABLE xvbap ASSIGNING <lfs_xvbap>
                              WITH KEY posnr = <lfs_yvbap>-posnr
                                       matnr = <lfs_yvbap>-matnr.
            IF sy-subrc = 0.
              IF <lfs_yvbap>-kwmeng NE <lfs_xvbap>-kwmeng.
                lv_subrc = 0.
                EXIT.
              ELSEIF <lfs_yvbap>-abgru NE <lfs_xvbap>-abgru.
                lv_subrc = 0.
                EXIT.
              ELSEIF <lfs_yvbap>-zzquoteref NE <lfs_xvbap>-zzquoteref.
                lv_subrc = 0.
                EXIT.
              ELSEIF <lfs_yvbap>-kzwi1 NE <lfs_xvbap>-kzwi1.
                lv_subrc = 0.
                EXIT.
              ENDIF. " IF <lfs_yvbap>-kwmeng NE <lfs_xvbap>-kwmeng
            ENDIF. " IF sy-subrc = 0
            UNASSIGN <lfs_xvbap>.
          ENDIF. " IF lv_subrc NE 0
          IF lv_subrc NE 0
            AND <lfs_yvbap>-uepos IS NOT INITIAL
            AND <lfs_yvbap>-stlnr IS NOT INITIAL.
            READ TABLE xvbap ASSIGNING <lfs_xvbap>
                              WITH KEY posnr = <lfs_yvbap>-uepos.
            IF sy-subrc = 0
              AND <lfs_xvbap>-mvgr1 IN lr_bom[].
              UNASSIGN <lfs_xvbap>.
              READ TABLE xvbap ASSIGNING <lfs_xvbap>
                                WITH KEY posnr = <lfs_yvbap>-posnr
                                         matnr = <lfs_yvbap>-matnr.
              IF sy-subrc = 0
                AND <lfs_yvbap>-kzwi1 NE <lfs_xvbap>-kzwi1.
                lv_subrc = 0.
                EXIT.
              ENDIF. " IF sy-subrc = 0
              UNASSIGN <lfs_xvbap>.
            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF lv_subrc NE 0
          IF lv_subrc NE 0
            AND <lfs_yvbap>-mvgr1 IN lr_lsg[]
            AND <lfs_yvbap>-stlnr IS INITIAL.
            READ TABLE yvbep ASSIGNING <lfs_yvbep> WITH KEY vbeln = <lfs_yvbap>-vbeln
                                                            posnr = <lfs_yvbap>-posnr
                                                            etenr = lc_etenr_001.
            IF sy-subrc = 0.
              READ TABLE xvbep ASSIGNING <lfs_xvbep>
                                WITH KEY vbeln = <lfs_yvbep>-vbeln
                                         posnr = <lfs_yvbep>-posnr
                                         etenr = <lfs_yvbep>-etenr.
              IF sy-subrc = 0 AND <lfs_yvbep>-edatu NE <lfs_xvbep>-edatu.
                lv_subrc = 0.
                EXIT.
              ENDIF. " IF sy-subrc = 0 AND <lfs_yvbep>-edatu NE <lfs_xvbep>-edatu
            ENDIF. " IF sy-subrc = 0
            UNASSIGN:
                      <lfs_xvbep>,
                      <lfs_yvbep>.
          ENDIF. " IF lv_subrc NE 0
*          IF lv_subrc NE 0
*            AND <lfs_yvbap>-mvgr1 IN lr_lsg[]
*            AND <lfs_yvbap>-uepos IS INITIAL
*            AND <lfs_yvbap>-stlnr IS NOT INITIAL.
*            READ TABLE yvbep ASSIGNING <lfs_yvbep> WITH KEY vbeln = <lfs_yvbap>-vbeln
*                                                            posnr = <lfs_yvbap>-posnr
*                                                            etenr = lc_etenr_001.
*            IF sy-subrc = 0.
*              READ TABLE xvbep ASSIGNING <lfs_xvbep>
*                                WITH KEY vbeln = <lfs_yvbep>-vbeln
*                                         posnr = <lfs_yvbep>-posnr
*                                         etenr = <lfs_yvbep>-etenr.
*              IF sy-subrc = 0 AND <lfs_yvbep>-edatu NE <lfs_xvbep>-edatu.
*                lv_subrc = 0.
*                EXIT.
*              ENDIF. " IF sy-subrc = 0 AND <lfs_yvbep>-edatu NE <lfs_xvbep>-edatu
*            ENDIF. " IF sy-subrc = 0
*            UNASSIGN:
*                      <lfs_xvbep>,
*                      <lfs_yvbep>.
*          ENDIF. " IF lv_subrc NE 0
          IF lv_subrc NE 0
            AND <lfs_yvbap>-mvgr1 IN lr_bom[]
            AND <lfs_yvbap>-uepos IS INITIAL
            AND <lfs_yvbap>-stlnr IS NOT INITIAL.
            READ TABLE xvbap ASSIGNING <lfs_xvbap>
                              WITH KEY posnr = <lfs_yvbap>-posnr
                                       matnr = <lfs_yvbap>-matnr.
            IF sy-subrc = 0.
              IF <lfs_yvbap>-kwmeng NE <lfs_xvbap>-kwmeng.
                lv_subrc = 0.
                EXIT.
              ELSEIF <lfs_yvbap>-abgru NE <lfs_xvbap>-abgru.
                lv_subrc = 0.
                EXIT.
              ELSEIF <lfs_yvbap>-zzquoteref NE <lfs_xvbap>-zzquoteref.
                lv_subrc = 0.
                EXIT.
              ELSEIF <lfs_yvbap>-kzwi1 NE <lfs_xvbap>-kzwi1.
                lv_subrc = 0.
                EXIT.
              ENDIF. " IF <lfs_yvbap>-kwmeng NE <lfs_xvbap>-kwmeng
            ENDIF. " IF sy-subrc = 0
            UNASSIGN <lfs_xvbap>.
          ENDIF. " IF lv_subrc NE 0
        ENDLOOP. " LOOP AT yvbap ASSIGNING <lfs_yvbap>
      ENDIF. " IF lv_subrc NE 0 AND yvbap[] IS NOT INITIAL
      IF lv_subrc NE 0.
        LOOP AT xvbpa ASSIGNING <lfs_xvbpa> WHERE parvw IN lr_parvw_opt.
          IF <lfs_xvbpa>-updkz = lc_updkz_i
            OR <lfs_xvbpa>-updkz = lc_updkz_d.
            lv_subrc = 0.
            EXIT.
          ENDIF. " IF <lfs_xvbpa>-updkz = lc_updkz_i
        ENDLOOP. " LOOP AT xvbpa ASSIGNING <lfs_xvbpa> WHERE parvw IN lr_parvw_opt
        UNASSIGN <lfs_xvbpa>.
      ENDIF. " IF lv_subrc NE 0
      IF lv_subrc NE 0.
        LOOP AT xvbap ASSIGNING <lfs_xvbap>.
          IF <lfs_xvbap>-uepos IS INITIAL AND
            <lfs_xvbap>-stlnr IS NOT INITIAL AND
            <lfs_xvbap>-mvgr1 IN lr_bom[] AND
            <lfs_xvbap>-updkz = lc_updkz_i.
            lv_subrc = 0.
            EXIT.
          ELSEIF <lfs_xvbap>-stlnr IS INITIAL AND
            <lfs_xvbap>-mvgr1 IN lr_nonbom[] AND
            <lfs_xvbap>-updkz = lc_updkz_i.
            lv_subrc = 0.
            EXIT.
          ENDIF. " IF <lfs_xvbap>-uepos IS INITIAL AND
        ENDLOOP. " LOOP AT xvbap ASSIGNING <lfs_xvbap>
      ENDIF. " IF lv_subrc NE 0
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF t180-tcode = lc_tcode_va02

*---> Begin of change for D2_OTC_EDD_0019 Defect# 1816 by PDEBARU

  IF NOT xvbak-lifsk = yvbak-lifsk.
    lv_subrc = 0.
  ENDIF. " IF NOT xvbak-lifsk = yvbak-lifsk

*<--- End of change for D2_OTC_EDD_0019 Defect# 1816 by PDEBARU

  sy-subrc = lv_subrc.
