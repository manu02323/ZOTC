class ZCL_IM_CL_IM_OTC_IDD_0099 definition
  public
  final
  create public .

public section.

  interfaces IF_EX_IDOC_CREATION_CHECK .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_CL_IM_OTC_IDD_0099 IMPLEMENTATION.


METHOD if_ex_idoc_creation_check~idoc_data_check.
************************************************************************
* IMPLEMENTATION  :  ZCL_IM_CL_IM_OTC_IDD_0099                         *
* TITLE      :  D2_OTC_IDD_0099 Idoc Creation Check                    *
* DEVELOPER  :  Avik Poddar                                            *
* OBJECT TYPE:  BADI                                                   *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D2_OTC_IDD_0099                                          *
*----------------------------------------------------------------------*
* DESCRIPTION: Business requirement is, not to allow creation of new   *
*              Idoc if Document does not contain any material          *
*              with MVGR1 = 001 or 007                                 *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 10-Nov-2014 APODDAR  E2DK900887 CR D2_237 Invoice does not contain any
*                                 material outside of permissible range
*                                 Hence ZSMX output should get processed,
*                                 without idoc getting generated.
*&---------------------------------------------------------------------*

**-------------Table Type Declaration------------**
  TYPES:
     BEGIN OF lty_vbrp,
       vbeln      TYPE vbeln_vf,   " Billing Document
       posnr      TYPE posnr_vf,   " Billing item
       aubel      TYPE vbeln_va,   " Sales Document
       mvgr1      TYPE mvgr1,      " Material group 1 "inserted by APODDAR for CR D2_237
       zzitemref  TYPE z_itemref,  " ServMax Obj ID
       zzquoteref TYPE z_quoteref, " Legacy Qtn Ref
       zzlnref    TYPE z_lnref,    " Instrument Reference
     END OF lty_vbrp.

**----------Internal Table Declaration-----------**
  DATA:
      li_vbrp      TYPE TABLE OF lty_vbrp,        " VBRP Int. Table
      li_status    TYPE TABLE OF zdev_enh_status, " Enhancement Status
      li_mvgr1     TYPE RANGE OF mvgr1.           " Material group 1

**--------------Data Declaration--------------**
  DATA:
         lx_e1edk01_id99      TYPE e1edk01,    " IDoc: Document header general data
         lwa_mvgr1            TYPE rsdsselopt, " Structure of generic SELECT-OPTION for (dynamic selections)
         lx_e1edk02_id99      TYPE e1edk02,    " IDoc: Document header reference data

         lv_vbeln             TYPE vbeln_vf,   " Billing Document
         lv_mestyp            TYPE edi_mestyp, " Message Type
         lv_rcvprn            TYPE edi_rcvprn, " Partner Number of Receiver
         lv_po_type           TYPE bsark,
         lv_mvgr1_1           TYPE mvgr1,      " Material group 1
         lv_mvgr1_7           TYPE mvgr1,      " Material group 1
         lv_tfill             TYPE sy-tfill,   " Processed Database Table Rows
         lv_idoctp            TYPE edi_idoctp, " Basic type
         lv_doc_no            TYPE vbeln_va,   " Sales Document
         lv_partn             TYPE partner.    " Partnership

**-------------Field Symbols--------------------**
  FIELD-SYMBOLS:    <lfs_edidd_99>  TYPE edidd,           " Data record (IDoc)
                    <lfs_status>    TYPE zdev_enh_status. " Enhancement Status

**-------------Constants Declaration-----------**
  CONSTANTS :
              lc_seg_e1edk01_id99 TYPE edilsegtyp VALUE 'E1EDK01', " Name of SAP segment
              lc_idd_0099         TYPE z_enhancement               " Enh. No.
                                  VALUE 'D2_OTC_IDD_0099',         " Enh. No.
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
              lc_inclusive        TYPE char1                       " Inclusive of type CHAR1
                                  VALUE 'I',
              lc_equal            TYPE char2                       " Equal of type CHAR2
                                  VALUE 'EQ',
              lc_seg_e1edk02_id99 TYPE edilsegtyp                  " Segment type
                                  VALUE 'E1EDK02',                 " Name of SAP segment
              lc_qualf_002_id99   TYPE edi_qualfr                  " IDOC qualifier reference document
                                  VALUE '002',                     " IDOC qualifier reference document
              lc_posnr            TYPE posnr                       " Item number of the SD document
                                  VALUE '000000',
              lc_partner          TYPE z_criteria                  " Enh. Criteria
                                  VALUE 'PARTNER'.

* Get constants from EMI tools
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_idd_0099 "D2_OTC_IDD_0099
    TABLES
      tt_enh_status     = li_status.

 "Delete Inactive Status
  DELETE li_status WHERE active NE abap_true.

  READ TABLE li_status WITH KEY criteria = lc_null "NULL
                                TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.

    IF <lfs_status> IS ASSIGNED.
      UNASSIGN <lfs_status>.
    ENDIF. " IF <lfs_status> IS ASSIGNED

    READ TABLE li_status
      ASSIGNING <lfs_status>  WITH KEY criteria = lc_partner. "NULL
    IF sy-subrc EQ 0.
      lv_partn = <lfs_status>-sel_low.
    ENDIF. " IF sy-subrc EQ 0

    READ TABLE li_status ASSIGNING <lfs_status>
              WITH KEY criteria = lc_mestyp.
    IF sy-subrc EQ 0.
      lv_mestyp = <lfs_status>-sel_low.
    ENDIF. " IF sy-subrc EQ 0

    READ TABLE li_status ASSIGNING <lfs_status>
                  WITH KEY criteria = lc_rcvprn.
    IF sy-subrc EQ 0.
      lv_rcvprn = <lfs_status>-sel_low.
    ENDIF. " IF sy-subrc EQ 0

    READ TABLE li_status ASSIGNING <lfs_status>
                  WITH KEY criteria = lc_idoctp.
    IF sy-subrc EQ 0.
      lv_idoctp = <lfs_status>-sel_low.
    ENDIF. " IF sy-subrc EQ 0

** -> Material Group
    LOOP AT li_status ASSIGNING <lfs_status>.
      IF <lfs_status>-criteria EQ lc_mvgr1.
        lwa_mvgr1-sign   = lc_inclusive.
        lwa_mvgr1-option = lc_equal.
        lwa_mvgr1-low    = <lfs_status>-sel_low.
        APPEND lwa_mvgr1 TO li_mvgr1.
      ENDIF. " IF <lfs_status>-criteria EQ lc_mvgr1
    ENDLOOP. " LOOP AT li_status ASSIGNING <lfs_status>

    IF idoc_control-mestyp = lv_mestyp
      AND idoc_control-rcvprn = lv_rcvprn
      AND idoc_control-idoctp = lv_idoctp.

      READ TABLE idoc_data ASSIGNING <lfs_edidd_99>
                     WITH KEY segnam = lc_seg_e1edk01_id99.
      IF sy-subrc = 0.
        lx_e1edk01_id99 = <lfs_edidd_99>-sdata.
        lv_vbeln = lx_e1edk01_id99-belnr.

        UNASSIGN <lfs_edidd_99>.
**--------Read Segment E1EDK02---------**
        READ TABLE idoc_data ASSIGNING <lfs_edidd_99> WITH KEY segnam = lc_seg_e1edk02_id99
                                                                 sdata(3) = lc_qualf_002_id99.
        IF sy-subrc EQ 0.
          lx_e1edk02_id99 = <lfs_edidd_99>-sdata.
          lv_doc_no       = lx_e1edk02_id99-belnr.
        ENDIF. " IF sy-subrc EQ 0

        SELECT SINGLE
           bsark     " Customer purchase order type
           FROM vbkd " Sales Document: Business Data
           INTO lv_po_type
           WHERE vbeln = lv_doc_no
             AND posnr = lc_posnr.
        IF sy-subrc EQ 0.
          IF lv_po_type NE lv_partn .
            SELECT vbeln      " Billing Document
                   posnr      " Billing item
                   aubel      " Sales Document
                   mvgr1      " Material group 1
                   zzitemref  " ServMax Obj ID
                   zzquoteref " Legacy Qtn Ref
                   zzlnref    " Instrument Reference
                  FROM vbrp   " Billing Document: Item Data
                  INTO TABLE li_vbrp
                  WHERE vbeln = lv_vbeln.
            IF sy-subrc = 0.

              DELETE li_vbrp WHERE mvgr1 NOT IN li_mvgr1.
              DELETE li_vbrp WHERE mvgr1 NOT IN li_mvgr1.

              DESCRIBE TABLE li_vbrp LINES lv_tfill.
              IF lv_tfill IS INITIAL.
                create_idoc = space.
              ELSE. " ELSE -> IF lv_tfill IS INITIAL
                create_idoc = abap_true.
              ENDIF. " IF lv_tfill IS INITIAL
            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF lv_po_type NE lv_partn
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF idoc_control-mestyp = lv_mestyp
  ENDIF. " IF sy-subrc = 0

ENDMETHOD.
ENDCLASS.
