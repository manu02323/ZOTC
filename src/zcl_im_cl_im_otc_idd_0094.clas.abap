class ZCL_IM_CL_IM_OTC_IDD_0094 definition
  public
  final
  create public .

public section.

  interfaces IF_EX_IDOC_CREATION_CHECK .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_CL_IM_OTC_IDD_0094 IMPLEMENTATION.


METHOD if_ex_idoc_creation_check~idoc_data_check.
************************************************************************
* IMPLEMENTATION  :  ZCL_IM_CL_IM_OTC_IDD_0094                         *
* TITLE      :  D2_OTC_IDD_0094 Idoc Creation Check                    *
* DEVELOPER  :  Avik Poddar                                            *
* OBJECT TYPE:  BADI                                                   *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D2_OTC_IDD_0094                                          *
*----------------------------------------------------------------------*
* DESCRIPTION: Business requirement is, not to allow creation of new   *
*              Idoc if SO does not contain any material                *
*              with MVGR1 = 002 or 003                                 *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 08-Oct-2014 APODDAR  E2DK900871 CR D2_107 Sales Ordr does not contain
*                                 any material with MVGR1 = 002 or 003.
*                                 Hence ZSMX output should get processed,
*                                 without idoc getting generated.
*&---------------------------------------------------------------------*
* 11-Dec-2014 APODDAR  E2DK900871 CR D2_301 Sales Ordr Reason Code is
*                                 NCB. Value maintained in EMI for check
*                                 Hence ZSMX output should get processed,
*                                 without idoc getting generated.
*&---------------------------------------------------------------------*

**--------------Type Declaration--------------**
  TYPES:   BEGIN OF lty_vbap,
           vbeln TYPE vbeln_va, " Sales Document
           posnr TYPE posnr_va, " Sales Document Item
           uepos TYPE uepos,    " Higher-level item in bill of material structures
           stlnr TYPE stnum,    " Bill of material
           mvgr1 TYPE mvgr1,    " Material group 1
           END OF lty_vbap.

**--------------Data Declaration--------------**
  DATA:
         lx_e1edk01_id94     TYPE e1edk01,                  " IDoc: Document header general data
         lv_vbeln             TYPE vbeln_va,                 " Sales Document
         li_status            TYPE TABLE OF zdev_enh_status, " Enhancement Status
         li_vbap              TYPE TABLE OF lty_vbap,
         lv_tfill             TYPE sy-tfill,                 " Processed Database Table Rows
         lv_tflag             TYPE sy-tfill,                 " Processed Database Table Rows
         lv_mestyp            TYPE edi_mestyp,               " Message Type
         lv_rcvprn            TYPE edi_rcvprn,               " Partner Number of Receiver
         lv_idoctp            TYPE edi_idoctp,               " Basic type
** Begin of Changes for CR 301 by APODDAR on 12th Dec 2014 **
         li_mvgr1             TYPE TABLE OF zdev_enh_status,
         li_ordr_rsn          TYPE TABLE OF zdev_enh_status,
         lv_augru             TYPE augru.
** End of Changes for CR 301 by APODDAR on 12th Dec 2014 **

**-------------Field Symbols--------------------**
  FIELD-SYMBOLS:    <lfs_edidd_94>  TYPE edidd,           " Data record (IDoc)
                    <lfs_vbap>      TYPE lty_vbap,
                    <lfs_status>    TYPE zdev_enh_status. " Enhancement Status
**-------------Constants Declaration-----------**
  CONSTANTS :
              lc_seg_e1edk01_id94 TYPE edilsegtyp VALUE 'E1EDK01', " Name of SAP segment
              lc_seg_e1edp01_id94 TYPE edilsegtyp VALUE 'E1EDP01', " Name of SAP segment
              lc_idd_0094         TYPE z_enhancement               " Enh. No.
                                  VALUE 'D2_OTC_IDD_0094',         " Enh. No.
              lc_null             TYPE z_criteria                  " Enh. Criteria
                                  VALUE 'NULL',
              lc_mvgr1            TYPE  z_criteria                 " Mat. group 1
                                  VALUE 'MVGR1',                   " Mat Group
              lc_mestyp            TYPE  z_criteria                " Enh. Criteria
                                  VALUE 'MESTYP',
              lc_idoctp            TYPE  z_criteria                " Enh. Criteria
                                  VALUE 'IDOCTP',
              lc_rcvprn           TYPE  z_criteria                 " Enh. Criteria
                                  VALUE 'RCVPRN',

              lc_ordr_rsn         TYPE z_criteria
                                  VALUE 'ORDR_REASON'.

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

    READ TABLE li_status ASSIGNING <lfs_status>
                  WITH KEY criteria = lc_mestyp
                              active   = abap_true. "X"
    IF sy-subrc EQ 0.
      lv_mestyp = <lfs_status>-sel_low.
    ENDIF. " IF sy-subrc EQ 0

    READ TABLE li_status ASSIGNING <lfs_status>
                  WITH KEY criteria = lc_rcvprn
                              active   = abap_true. "X"
    IF sy-subrc EQ 0.
      lv_rcvprn = <lfs_status>-sel_low.
    ENDIF. " IF sy-subrc EQ 0

    READ TABLE li_status ASSIGNING <lfs_status>
                  WITH KEY criteria = lc_idoctp
                              active   = abap_true. "X"
    IF sy-subrc EQ 0.
      lv_idoctp = <lfs_status>-sel_low.
    ENDIF. " IF sy-subrc EQ 0

** Begin of Changes for CR 301 by APODDAR on 12th Dec 2014 **
       APPEND LINES OF li_status TO li_mvgr1.
       DELETE li_status WHERE active NE abap_true.
       DELETE li_status WHERE criteria NE lc_ordr_rsn.
       APPEND LINES OF li_status TO li_ordr_rsn.
** End of Changes for CR 301 by APODDAR on 12th Dec 2014 **


    IF idoc_control-mestyp = lv_mestyp
AND idoc_control-rcvprn = lv_rcvprn
AND idoc_control-idoctp = lv_idoctp.

      READ TABLE idoc_data ASSIGNING <lfs_edidd_94>
                           WITH KEY segnam = lc_seg_e1edp01_id94.

      IF sy-subrc NE 0.
        create_idoc = space.
      ENDIF. " IF sy-subrc NE 0

      READ TABLE idoc_data ASSIGNING <lfs_edidd_94>
                           WITH KEY segnam = lc_seg_e1edk01_id94.

      IF sy-subrc EQ 0.
        lx_e1edk01_id94 = <lfs_edidd_94>-sdata.
        lv_vbeln = lx_e1edk01_id94-belnr.

        SELECT
          vbeln     " Sales Document
          posnr     " Sales Document Item
          uepos     " Higher-level item in bill of material structures
          stlnr     " Bill of material
          mvgr1     " Material group 1
          FROM vbap " Sales Document: Item Data
          INTO TABLE li_vbap
          WHERE vbeln = lv_vbeln.
        IF sy-subrc = 0.
**-----------Get record count-----------**
          DESCRIBE TABLE li_vbap LINES lv_tfill.
          LOOP AT li_vbap ASSIGNING <lfs_vbap>.
            READ TABLE li_mvgr1 WITH KEY criteria = lc_mvgr1
                                   sel_low = <lfs_vbap>-mvgr1
                                   active   = abap_true "X"
                                    TRANSPORTING NO FIELDS.
            IF sy-subrc NE 0.
              lv_tflag = lv_tflag + 1.
            ENDIF. " IF sy-subrc NE 0
          ENDLOOP. " LOOP AT li_vbap ASSIGNING <lfs_vbap>
        ENDIF. " IF sy-subrc = 0
        IF lv_tflag = lv_tfill.
          create_idoc = space.
          ELSE.
          create_idoc = abap_true.
        ENDIF. " IF lv_tflag = lv_tfill
      ENDIF. " IF sy-subrc EQ 0

** Begin of Changes for CR 301 by APODDAR on 12th Dec 2014 **
      SELECT SINGLE augru
        FROM vbak
        INTO lv_augru
        WHERE vbeln = lv_vbeln.
        IF sy-subrc = 0.
          READ TABLE li_ordr_rsn TRANSPORTING NO FIELDS
           WITH KEY sel_low = lv_augru.
          IF sy-subrc = 0.
            create_idoc = space.
            ELSE.
              IF lv_tflag NE lv_tfill.
                create_idoc = abap_true.
              ENDIF.
          ENDIF.
        ENDIF.
** End of Changes for CR 301 by APODDAR on 12th Dec 2014 **
        CLEAR: lv_tflag,
               lv_tfill.
    ENDIF. " IF idoc_control-mestyp = lv_mestyp
  ENDIF. " IF sy-subrc = 0
ENDMETHOD.
ENDCLASS.
