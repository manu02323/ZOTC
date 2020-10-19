*&---------------------------------------------------------------------*
*& Include   ZOTC_EDD_0335_BILLING
*&
*&---------------------------------------------------------------------*
************************************************************************
* PROG       :  ZOTC_EDD_0335_BILLING    (Include Program)             *
* TITLE      :  Populate VAT Registration Number for Trade Invoice     *
* DEVELOPER  :  Srinivasa Gurijala                                     *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_00335                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Pupulate VAT Registration Number for Trade Invoice      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER    TRANSPORT    DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 10/Jul/2016 U033814  E1DK919518  FB2_D3_OTC_EDD_0335_EHQ_EU_VAT_Ta   *
*======================================================================*
* 26/Oct/2016 U033814  E1DK919518  CR 216                              *
*======================================================================*
* 13/Dec/2016 U033814  E1DK919518  Defect 7423                         *
*======================================================================*
*======================================================================*
* 23/May/2017 U033814  E1DK928183  Defect 2895                         *
* When Populating VAT Registration Number used Destination Country     *
* Instead of Reporting Country                                         *
*======================================================================*


  DATA : lv_zzrland TYPE land1,    " Country Key
         lv_zzdland TYPE land1,    " Country Key
         lv_bukrs   TYPE bukrs_vf, " Company code to be billed
         lv_vbtyp   TYPE vbtyp,    " SD document category
         lv_stceg   TYPE stceg,    " VAT Registration Number
         lv_kunnr   TYPE kunnr,    " Customer Number
         lv_land1   TYPE land1.    " Country Key

  DATA:li_status    TYPE STANDARD TABLE OF zdev_enh_status, "Enhancement Status table
      lwa_status    TYPE zdev_enh_status.                   " Enhancement Status

  CONSTANTS :
       lc_criteria  TYPE z_criteria           VALUE 'VKORG',        " Enh. Criteria
       lc_edd_0335  TYPE z_enhancement        VALUE 'OTC_EDD_0335', " Enhancement No.
       c_5          TYPE vbtyp                VALUE '5',            " SD document category
       lc_null      TYPE char4                VALUE 'NULL',         " Null of type CHAR4
       c_6          TYPE vbtyp                VALUE '6'.            " SD document category



*--Call to EMI Function Module To Get List Of EMI Statuses for Transportation Group Mapping
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_edd_0335
    TABLES
      tt_enh_status     = li_status.

  DELETE li_status WHERE active NE abap_true.

  READ TABLE li_status  INTO lwa_status  WITH KEY criteria = lc_null
                                                  active   = abap_true.
  IF sy-subrc EQ 0.

    READ TABLE li_status  INTO lwa_status  WITH KEY criteria = lc_criteria
                                                    sel_low  = vbrk-vkorg
                                                    active   = abap_true.

    IF sy-subrc EQ 0.
* Begin of Defect 7423
** Retreive the Customer from Sales Order Header
*      SELECT SINGLE kunnr  bukrs_vf FROM vbak INTO (lv_kunnr , lv_bukrs) WHERE vbeln EQ vbrp-aubel.
*
** Retreive the Destination Country and Reporting Country for Sales Order and Item Number
*      SELECT SINGLE zzrland zzdland FROM vbap INTO (lv_zzrland , lv_zzdland )
*                 WHERE vbeln EQ vbrp-aubel
*                   AND posnr EQ vbrp-aupos.
*      IF sy-subrc EQ 0.
      lv_kunnr = vbak-kunnr.
      lv_bukrs = vbak-bukrs_vf.
      lv_zzrland = vbap-zzrland.
      lv_zzdland = vbap-zzdland.
* End of Defect 7423
* Retreive the Sales Document Categeory Based on Billing Type
      SELECT SINGLE vbtyp FROM tvfk INTO lv_vbtyp
                    WHERE fkart EQ vbrk-fkart.
* If Document Categery is not Inter Company then populate reporting country
* Destination Country and VAT Registration Number in Billing Document
      IF lv_vbtyp NE c_5 AND lv_vbtyp NE c_6.
        MOVE lv_zzrland TO vbrk-zzrland.
        MOVE lv_zzdland TO vbrk-zzdland.

        SELECT SINGLE land1 FROM kna1 INTO lv_land1 WHERE kunnr EQ lv_kunnr.
        IF lv_land1 EQ lv_zzrland.
          SELECT SINGLE stceg FROM kna1 INTO vbrk-stceg
                      WHERE kunnr EQ lv_kunnr
* * Begin of Defect 2895
*              AND land1 EQ lv_zzrland.
              AND land1 EQ lv_zzdland.
* End of Defect 2895
        ELSE. " ELSE -> IF lv_land1 EQ lv_zzrland
          SELECT SINGLE stceg FROM knas INTO vbrk-stceg
            WHERE kunnr EQ lv_kunnr
* * Begin of Defect 2895
*              AND land1 EQ lv_zzrland.
              AND land1 EQ lv_zzdland.
* End of Defect 2895
        ENDIF. " IF lv_land1 EQ lv_zzrland
* Begin of Change CR-216
        IF lv_bukrs IS NOT INITIAL.
          SELECT SINGLE stceg INTO vbrk-zzvatnsf FROM t001n " Company Code - EC Tax Numbers / Notifications
                              WHERE bukrs EQ lv_bukrs
                                AND land1 EQ lv_zzrland.
          IF sy-subrc NE 0.
            SELECT SINGLE stceg INTO vbrk-zzvatnsf FROM t001 " Company Codes
                                WHERE bukrs EQ lv_bukrs.
          ENDIF. " IF sy-subrc NE 0
        ENDIF. " IF lv_bukrs IS NOT INITIAL
* End of Change CR-216
      ENDIF. " IF lv_vbtyp NE c_5 AND lv_vbtyp NE c_6
*      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
