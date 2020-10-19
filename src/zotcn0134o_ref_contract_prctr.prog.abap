***********************************************************************
*Program    : ZOTCN0134O_REF_CONTRACT_PRCTR                           *
*Title      : Append pricing structures                               *
*Developer  : Salman Zahir                                            *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_EDD_0134                                           *
*---------------------------------------------------------------------*
*Description: Populate profit centre and reference contract in        *
*             pricing structure TKOMP                                 *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:                                                *
*=====================================================================*
*Date           User        Transport       Description               *
*=========== ============== ============== ===========================*
*21-SEP-2016  U033959       E1DK921266      Populate profit centre and*
*                                           reference contract in     *
*                                           pricing structure TKOMP   *
*---------------------------------------------------------------------*


  CONSTANTS : lc_otc_edd_0134  TYPE z_enhancement VALUE 'D2_OTC_EDD_0134', " Enhancement No.
              lc_enh_active    TYPE z_criteria    VALUE 'NULL',            " Enh. Criteria
              lc_vgtyp         TYPE z_criteria    VALUE 'VGTYP'.           " criteria VGTYP

  DATA : li_status1    TYPE STANDARD TABLE OF zdev_enh_status. " Enhancement Status table

  DATA: lv_prctr   TYPE prctr,   " Profit Center
        lv_vgtyp_g TYPE vbtyp_v. " Document category of preceding SD document

  FIELD-SYMBOLS: <lfs_vbap_head> TYPE vbapvb,          " Sales Document: Item Data
                 <lfs_vbap_comp> TYPE vbapvb,          " Sales Document: Item Data
                 <lfs_status1>   TYPE zdev_enh_status. " Enhancement Status table


* Checking whether enhancement is active or not from EMI Tool.
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_otc_edd_0134
    TABLES
      tt_enh_status     = li_status1.
  SORT li_status BY criteria active.

* Check if enhancement is active on EMI
  READ TABLE li_status1 WITH KEY criteria = lc_enh_active
                                 active   = abap_true
                                 BINARY SEARCH
                                 TRANSPORTING NO FIELDS.
  IF sy-subrc IS INITIAL.

    READ TABLE li_status1 ASSIGNING <lfs_status1> WITH KEY criteria = lc_vgtyp
                                                           active   = abap_true
                                                           BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lv_vgtyp_g = <lfs_status1>-sel_low.
    ENDIF. " IF sy-subrc IS INITIAL


    IF vbak-vbtyp = lv_vgtyp_g.
      tkomp-zzvgbel = vbak-vbeln.
    ELSE. " ELSE -> IF vbak-vbtyp = lv_vgtyp_g
      IF vbap-vgtyp = lv_vgtyp_g.
        tkomp-zzvgbel = vbap-vgbel.
      ENDIF. " IF vbap-vgtyp = lv_vgtyp_g
    ENDIF. " IF vbak-vbtyp = lv_vgtyp_g


    LOOP AT xvbap ASSIGNING <lfs_vbap_comp>.
      IF <lfs_vbap_comp>-posnr = tkomp-kposn.
        IF <lfs_vbap_comp>-uepos IS NOT INITIAL
          AND <lfs_vbap_comp>-stlnr IS NOT INITIAL.

* Assigning the header Profit center to cpmponent materials
          READ TABLE xvbap ASSIGNING <lfs_vbap_head> WITH KEY posnr = <lfs_vbap_comp>-uepos.
          IF sy-subrc = 0.
            tkomp-zzuprctr = <lfs_vbap_head>-prctr.
            EXIT.
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF <lfs_vbap_comp>-uepos IS NOT INITIAL
      ENDIF. " if <lfs_vbap_comp>-posnr = tkomp-kposn
    ENDLOOP. " LOOP AT xvbap ASSIGNING <lfs_vbap_comp> WHERE posnr = tkomp-kposn

  ENDIF. " IF sy-subrc IS INITIAL
