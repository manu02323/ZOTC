***********************************************************************
*Program    : ZOTCN0134O_REF_CONTRACT_PRCTR1                          *
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
*14-MAY-2018  MGARG         E1DK936586     Defect#6023: Set Reference *
*                                          contract in TKOMP by taking*
*                                          value from VBRP-AUBEL.     *
*---------------------------------------------------------------------*
*--CONSTANTS---------------------------------------------------------*
  CONSTANTS : lc_otc_edd_0134  TYPE z_enhancement VALUE 'D2_OTC_EDD_0134', " Enhancement No.
              lc_enh_active    TYPE z_criteria    VALUE 'NULL',            " Enh. Criteria
              lc_vgtyp         TYPE z_criteria    VALUE 'VGTYP'.           " criteria VGTYP

  TYPES: BEGIN OF lty_vbap_prctr,
           vbeln TYPE vbeln_va, " Sales Document
           posnr TYPE posnr_va, " Item number of the SD document
           uepos TYPE uepos,    " Higher-level item in bill of material structures
           vgbel TYPE vgbel,    " Document number of the reference document
           prctr TYPE prctr,    " Profit Center
           vgtyp TYPE vbtyp_v,  " Document category of preceding SD document
         END OF lty_vbap_prctr.

  DATA: li_vbap_prctr TYPE STANDARD TABLE OF lty_vbap_prctr INITIAL SIZE 0, " Profit centre in SO
        li_status1    TYPE STANDARD TABLE OF zdev_enh_status.               " Enhancement Status table
* ---> Begin of Delete for D3_OTC_EDD_0134_Defect#6023 by MGARG on 14-May-2018
*        li_xvbrp_temp TYPE STANDARD TABLE OF vbrpvb. " Reference Structure for XVBRP/YVBRP
* <--- End of Delete for D3_OTC_EDD_0134_Defect#6023 by MGARG on 14-May-2018

  DATA: lv_vgbel  TYPE  vgbel,   " Document number of the reference document
        lv_prctr  TYPE  prctr,   " Profit Center
        lv_vgtyp_g TYPE vbtyp_v. " Document category of preceding SD document

  FIELD-SYMBOLS: <lfs_vbrp_head>  TYPE vbrpvb,          " Reference Structure for XVBRP/YVBRP
                 <lfs_vbrp_comp>  TYPE vbrpvb,          " Reference Structure for XVBRP/YVBRP
                 <lfs_vbap_prctr> TYPE lty_vbap_prctr,  " Profit centre in SO
                 <lfs_status1>    TYPE zdev_enh_status. " Enhancement Status table

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

* ---> Begin of Delete for D3_OTC_EDD_0134_Defect#6023 by MGARG on 14-May-2018
*We are selecting data from VBAP based on  li_xvbrp_temp which is incorrect because
*in run time  li_xvbrp_temp won't be populated with the item details for which
*the user exit is being called. So, Changed the logic and picked the value from
* VBRP-AUBEL instead.

*    li_xvbrp_temp[] = xvbrp[].
*    SORT li_xvbrp_temp BY aubel.
*    DELETE ADJACENT DUPLICATES FROM li_xvbrp_temp COMPARING aubel.
* <--- End of Delete for D3_OTC_EDD_0134_Defect#6023 by MGARG on 14-May-2018

* ---> Begin of Delete for D3_OTC_EDD_0134_Defect#6023 by MGARG on 14-May-2018
*    IF li_xvbrp_temp[] IS NOT INITIAL.
* <--- End of Delete for D3_OTC_EDD_0134_Defect#6023 by MGARG on 14-May-2018
* ---> Begin of Insert for D3_OTC_EDD_0134_Defect#6023 by MGARG on 14-May-2018
    IF vbrp-aubel IS NOT INITIAL.
* <--- End of Insert for D3_OTC_EDD_0134_Defect#6023 by MGARG on 14-May-2018
      SELECT vbeln " Sales Document
             posnr " Sales Document Item
             uepos " Higher-level item in bill of material structures
             vgbel " Document number of the reference document
             prctr " Profit Center
             vgtyp " Document category of preceding SD document
        FROM vbap  " Sales Document: Item Data
        INTO TABLE li_vbap_prctr
* ---> Begin of Delete for D3_OTC_EDD_0134_Defect#6023 by MGARG on 14-May-2018
*        FOR ALL ENTRIES IN li_xvbrp_temp
*        WHERE vbeln = li_xvbrp_temp-aubel.
* <--- End of Delete for D3_OTC_EDD_0134_Defect#6023 by MGARG on 14-May-2018
* ---> Begin of Insert for D3_OTC_EDD_0134_Defect#6023 by MGARG on 14-May-2018
        WHERE vbeln = vbrp-aubel.
* <--- End of Insert for D3_OTC_EDD_0134_Defect#6023 by MGARG on 14-May-2018
      IF sy-subrc IS INITIAL.
        SORT li_vbap_prctr BY vbeln posnr.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF vbrp-aubel IS NOT INITIAL

    READ TABLE li_vbap_prctr ASSIGNING <lfs_vbap_prctr> WITH KEY vbeln = vbrp-aubel
                                                                 posnr = vbrp-aupos
                                                                 BINARY SEARCH.
    IF sy-subrc = 0.
      IF <lfs_vbap_prctr>-vgtyp = lv_vgtyp_g.
        tkomp-zzvgbel  = <lfs_vbap_prctr>-vgbel.
      ENDIF. " IF <lfs_vbap_prctr>-vgtyp = lv_vgtyp_g
    ENDIF. " IF sy-subrc = 0

* Begin of change by Rajendra on 09/30/2016
*    LOOP AT xvbrp ASSIGNING <lfs_vbrp_comp>.
**      IF <lfs_vbrp_comp>-posnr = tkomp-kposn.
*      IF <lfs_vbrp_comp>-uepos IS NOT INITIAL.
*
** Assigning the header Profit center to cpmponent materials
*        READ TABLE li_vbap_prctr ASSIGNING <lfs_vbap_prctr> WITH KEY vbeln = <lfs_vbrp_comp>-aubel
*                                                                     posnr = <lfs_vbrp_comp>-uepos
*                                                                     BINARY SEARCH.
*        IF sy-subrc = 0.
*          tkomp-zzuprctr = <lfs_vbap_prctr>-prctr.
*          EXIT.
*        ENDIF. " IF sy-subrc = 0
*      ENDIF. " IF <lfs_vbrp_comp>-uepos IS NOT INITIAL
**      ENDIF. " IF <lfs_vbrp_comp>-posnr = tkomp-kposn
*    ENDLOOP. " LOOP AT xvbrp ASSIGNING <lfs_vbrp_comp>

    IF vbrp-uepos IS NOT INITIAL.

      READ TABLE li_vbap_prctr ASSIGNING <lfs_vbap_prctr> WITH KEY vbeln = vbrp-aubel
                                                                   posnr = vbrp-uepos BINARY SEARCH.
      IF sy-subrc = 0.
        IF tkomp-kposn = vbrp-posnr.
          tkomp-zzuprctr = <lfs_vbap_prctr>-prctr.
          tkomp-prctr    = <lfs_vbap_prctr>-prctr.
        ENDIF. " IF tkomp-kposn = vbrp-posnr
      ENDIF. " IF sy-subrc = 0

    ELSEIF vbrp-uepos IS INITIAL.
      READ TABLE li_vbap_prctr ASSIGNING <lfs_vbap_prctr> WITH KEY vbeln = vbrp-aubel
                                                                   posnr = vbrp-posnr BINARY SEARCH.
      IF sy-subrc = 0.
        IF tkomp-kposn = vbrp-posnr.
          tkomp-prctr    = <lfs_vbap_prctr>-prctr.
        ENDIF. " IF tkomp-kposn = vbrp-posnr
      ENDIF. " IF sy-subrc = 0

    ENDIF. " IF vbrp-uepos IS NOT INITIAL
* End of change by Rajendra on 09/30/2016
    CLEAR : li_vbap_prctr[].

  ENDIF. " IF sy-subrc IS INITIAL
