************************************************************************
* PROGRAM    :  ZOTCN0099B_SAP_INV_SERVICEMAX                          *
* TITLE      :  D2_OTC_IDD_0099                                        *
* DEVELOPER  :  Avik Poddar                                            *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_IDD_0099_SAP Invoice to ServiceMax              *
*----------------------------------------------------------------------*
* DESCRIPTION: SAP Invoice to ServiceMax                               *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 20-JUN-2014 APODDAR  E2DK900887 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*
* 07-OCT-2014 APODDAR  E2DK900887 CR D2_73  Addtn of Segmt. E1EDK14    *
*                                 CR D2_135 Addtn of Segmt. E1EDP19    *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* 05-Nov-2014 APODDAR  E2DK900887 CR D2_237  Restriction of Segments   *
*                                 based on Partner and Material Group  *
* 18-Nov-2014 MBAGDA   E2DK900887 Def# 1729 Fix for Serial Number      *
* 11-Dec-2014 APODDAR  E2DK900887 CR D2_256 E1EDP segment extended for *
*                                 Z03 Only if VBRP-ZZLNREF is not blank*
*                                 value passed to E1EDP02- ZEILE       *
* 19-JAN-2015 NLIRA   E2DK900887  Defect 2676. E1EDP02 QUALF AG is not *
* when missing in the case where multiple invoices are created         *
* simultaneously. The cause is that the internal table for VBRP is not *
* refreshed for the subsequent invopices (IDocs). Fix is to check if   *
* the current IDoc table has only one entry (signifies new IDoc) and if*
* so, refresh the table.                                               *
* 24-Mar-2015 DMOIRAN E2DK900887  Defect 5214. Service Max ref doc
* number in E1EDK02 segment with qualifier Z1 is not populated correctly
* when collective billing for multiples delivery is done.
* 2-JUL-2015 MCHATTE E2DK913689 "Defect# 8300: Corrected index value
* 17-AUG-2015 BMAJI  E2DK914756 Defect# 894: I-DOC for invoice for
* replacement has wrong order type.
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           ZOTCN0099B_SAP_INV_SERVICEMAX                    *
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
       END OF lty_vbrp,
**   Begin of Changes CR D2_135 by APODDAR
       BEGIN OF lty_ser01,
         obknr   TYPE objknr,   " Object list number
         lief_nr TYPE vbeln_vl, " Delivery
         posnr   TYPE posnr_vl, " Delivery Item
        END OF lty_ser01,

       BEGIN OF lty_objk,
         obknr TYPE objknr,     " Object list number
         obzae TYPE objza,      " Object list counters
         sernr TYPE gernr,      " Serial Number
         matnr TYPE matnr,      " Material Number
        END OF lty_objk.

**   End of Changes CR D2_135 by APODDAR

**----------Internal Table Declaration-----------**
    DATA:  li_constant  TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Enhancement Status
           li_mvgr1     TYPE RANGE OF mvgr1,                                   " Material group 1
           li_vbrp      TYPE TABLE OF lty_vbrp,                                " VBRP Int. Table
**   Begin of Changes CR D2_135 by APODDAR
           li_vbfa  TYPE TABLE OF vbfa, " Sales Document Flow
           li_ser01 TYPE TABLE OF lty_ser01,
           li_objk  TYPE TABLE OF lty_objk.
**   End of Changes CR D2_135 by APODDAR

**--------------Data Declaration--------------**
    DATA:
       lwa_e1edk01_id99     TYPE e1edk01,    " IDoc: Document header general data
       lwa_e1edk02_id99     TYPE e1edk02,    " IDoc: Document header reference data
       lwa_e1edk03_id99     TYPE e1edk03,    " IDoc: Document header date segment
       lwa_e1edk14_id99     TYPE e1edk14,    " IDoc: Document Header Organizational Data
       lwa_e1edp02_id99     TYPE e1edp02,    " IDoc: Document Item Reference Data
       lwa_e1edp19_id99     TYPE e1edp19,    " IDoc: Document Item Reference Data
       lwa_edidd_id99       TYPE edidd,      " Data record (IDoc)
       lwa_vbco6            TYPE vbco6,      " Sales Document Access Methods: Key Fields
       lwa_mvgr1            TYPE rsdsselopt, " Structure of generic SELECT-OPTION for (dynamic selections)

       lv_vbeln             TYPE vbeln_va,   " Sales Document
       lv_belnr_01          TYPE vbeln_va,   " Sales Document
       lv_audat             TYPE angdt_v,    " Quotation/Inquiry is valid from
       lv_auart             TYPE auart,      " Sales Document Type
       lv_docref            TYPE z_docref,   " Legacy Doc Ref
       lv_tfill             TYPE sy-tfill,   " Processed Database Table Rows
       lv_subrc             TYPE abap_bool,  " Return Value of ABAP Statements
       lv_idx               TYPE sy-tabix,   " Index of Internal Tables
       lv_partn             TYPE partner,    " Partnership
       lv_po_type           TYPE bsark,
       lv_tabix             TYPE sy-tabix,   " Index of Internal Tables
       lv_del_flag          TYPE flag,       " General Flag
       lv_tab_lim           TYPE sy-tabix,   " Index of Internal Tables
       lv_mestyp            TYPE edi_mestyp, " Message Type
       lv_rcvprn            TYPE edi_rcvprn, " Partner Number of Receiver
       lv_idoctp            TYPE edi_idoctp. " Basic type

**--------------Field Symbol Declaration--------------**
    FIELD-SYMBOLS : <lfs_edidd_id99> TYPE edidd, " Data record (IDoc)
                    <lfs_vbrp>  TYPE lty_vbrp,
**   Begin of Changes CR D2_135 by APODDAR
                    <lfs_vbfa>  TYPE vbfa, " Sales Document Flow
                    <lfs_ser01> TYPE lty_ser01,
                    <lfs_objk>  TYPE lty_objk,
**   End of Changes CR D2_135 by APODDAR
**--- Begin of Changes for CR D2_237 by APODDAR on 05th Nov 2014
                    <lfs_status> TYPE zdev_enh_status. " Enhancement Status
**--- End of Changes for CR D2_237 by APODDAR on 05th Nov 2014

**-------------Constants Declaration-----------**
    CONSTANTS :
                lc_seg_e1edk01_id99 TYPE edilsegtyp VALUE 'E1EDK01',            " Name of SAP segment
                lc_seg_e1edk02_id99 TYPE edilsegtyp VALUE 'E1EDK02',            " Name of SAP segment
                lc_seg_e1edk03_id99 TYPE edilsegtyp VALUE 'E1EDK03',            " Name of SAP segment
                lc_seg_e1edp01_id99 TYPE edilsegtyp VALUE 'E1EDP01',            " Name of SAP segment
                lc_seg_e1edp02_id99 TYPE edilsegtyp VALUE 'E1EDP02',            " Name of SAP segment
                lc_qualf_z01_id99   TYPE edi_qualfr VALUE 'Z01',                " IDOC qualifier reference document
                lc_qualf_z02_id99   TYPE edi_qualfr VALUE 'Z02',                " IDOC qualifier reference document
                lc_qualf_002_id99   TYPE edi_qualfr VALUE '002',                " IDOC qualifier reference document
                lc_iddat_id99       TYPE edi_iddat  VALUE '029',                " Qualifier for IDOC date segment
                lc_doctyp_two       TYPE z_doctyp   VALUE '02',                 " Ref Doc type
                lc_null_99          TYPE z_criteria     VALUE 'NULL',           " Enh. Criteria
                lc_0099             TYPE z_enhancement VALUE 'D2_OTC_IDD_0099', " Enhancement No.
**--- Begin of Changes for CR D2_73 D2_135 by APODDAR on 07th OCT 2014
                lc_qualf_012_id99   TYPE edi_qualfr VALUE '012',     " IDOC qualifier reference document
                lc_qualf_014_id99   TYPE edi_qualfr VALUE '014',     " IDOC qualifier reference document
                lc_seg_e1edk14_id99 TYPE edilsegtyp VALUE 'E1EDK14', " Name of SAP segment
                lc_seg_e1edp19_id99 TYPE edilsegtyp VALUE 'E1EDP19', " Name of SAP segment
                lc_j                TYPE flag       VALUE 'J',       " General Flag
                lc_zero             TYPE flag       VALUE '0',       " General Flag
**--- End of Changes CR D2_73 D2_135 by APODDAR on 07th Oct 2014
**--- Begin of Changes for CR D2_237 by APODDAR on 05th Nov 2014
                lc_mvgr1            TYPE  z_criteria " Mat. group 1
                                    VALUE 'MVGR1',   " Mat Group
                lc_partner          TYPE z_criteria  " Enh. Criteria
                                    VALUE 'PARTNER',
                lc_posnr            TYPE posnr       " Item number of the SD document
                                    VALUE '000000',
                lc_segnam_e1edp01   TYPE edilsegtyp  " Segment type
                                    VALUE 'E1EDP01',
                lc_mestyp           TYPE  z_criteria " Enh. Criteria
                                    VALUE 'MESTYP',
                lc_idoctp           TYPE  z_criteria " Enh. Criteria
                                    VALUE 'IDOCTP',
                lc_rcvprn           TYPE  z_criteria " Enh. Criteria
                                    VALUE 'RCVPRN',
                lc_inclusive        TYPE char1       " Inclusive of type CHAR1
                                    VALUE 'I',
                lc_equal            TYPE char2       " Equal of type CHAR2
                                    VALUE 'EQ',

**--- End of Changes CR D2_237 by APODDAR on 05th Nov 2014

**--- Begin of Changes CR D2_256 by APODDAR on 11th Dec 2014
                lc_qualf_z03_id99   TYPE edi_qualfr VALUE 'Z03'. " IDOC qualifier reference document
**--- End of Changes CR D2_256 by APODDAR on 11th Dec 2014


**--->Begin Of Change for Def#894 by BMAJI on 17-Aug-2015
*In the case where multiple Invoices are created simultaneously, the
*internal VBRP table needs to be refreshed, otherwise, the next IDoc
*(for subsequent invoices) will be using the values
*       from the first IDoc as the table is only populated when it is empty
    DESCRIBE TABLE int_edidd LINES lv_tfill.
    IF lv_tfill = 1. "If there is only one segment, it must be a new IDoc
      READ TABLE int_edidd INTO lwa_edidd INDEX 1. "Get the first IDoc entry
      IF sy-subrc = 0.
        IF lwa_edidd-segnam = lc_seg_e1edk01_id99. "Check that it is E1EDK01
          CLEAR: lv_del_flag,
                 lv_tabix,
                 lv_docref,
                 lv_auart,
                 lv_audat,
                 lv_po_type.

          REFRESH: li_vbrp,
                   li_ser01,
                   li_objk,
                   li_vbfa. "Refrsh the table

*&&-- Reset all the GLOBAL veriables & internal tables
          CALL FUNCTION 'ZOTC_SET_PARAM'
            EXPORTING
              im_del_flag  = lv_del_flag
              im_tabix     = lv_tabix
              im_tbl_vbrp  = li_vbrp
              im_tbl_ser01 = li_ser01
              im_tbl_objk  = li_objk
              im_docref    = lv_docref
              im_tbl_vbfa  = li_vbfa
              im_auart     = lv_auart
              im_audat     = lv_audat
              im_po_type   = lv_po_type.
        ENDIF. " IF sy-subrc = 0
      ENDIF.
    ENDIF.
    CLEAR lv_tfill.
**<-- End Of Change for Def#894 by BMAJI on 17-Aug-2015

    CALL FUNCTION 'ZOTC_GET_PARAM'
      IMPORTING
        ex_status_emi = li_constant.
    IF li_constant IS INITIAL.
* Setting all the constant values.
      CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
        EXPORTING
          iv_enhancement_no = lc_0099
        TABLES
          tt_enh_status     = li_constant.

 "Delete Inactive Status
      DELETE li_constant WHERE active NE abap_true.

      CALL FUNCTION 'ZOTC_SET_PARAM'
        EXPORTING
          im_status_emi = li_constant.
    ENDIF. " IF li_constant IS INITIAL

    READ TABLE li_constant WITH KEY criteria = lc_null_99
                                    TRANSPORTING NO FIELDS.

    IF sy-subrc EQ 0.
**--- Begin of Changes CR D2_237 by APODDAR on 05th Nov 2014

** --> Material Group Check
      LOOP AT li_constant ASSIGNING <lfs_status>.
        IF <lfs_status>-criteria EQ lc_mvgr1.
          lwa_mvgr1-sign   = lc_inclusive.
          lwa_mvgr1-option = lc_equal.
          lwa_mvgr1-low    = <lfs_status>-sel_low.
          APPEND lwa_mvgr1 TO li_mvgr1.
        ENDIF. " IF <lfs_status>-criteria EQ lc_mvgr1
      ENDLOOP. " LOOP AT li_constant ASSIGNING <lfs_status>

      IF <lfs_status> IS ASSIGNED.
        UNASSIGN <lfs_status>.
      ENDIF. " IF <lfs_status> IS ASSIGNED

      READ TABLE li_constant
        ASSIGNING <lfs_status>  WITH KEY criteria = lc_partner. "NULL
      IF sy-subrc EQ 0.
        lv_partn = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0

      READ TABLE li_constant ASSIGNING <lfs_status>
          WITH KEY criteria = lc_mestyp.
      IF sy-subrc EQ 0.
        lv_mestyp = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0

      READ TABLE li_constant ASSIGNING <lfs_status>
                    WITH KEY criteria = lc_rcvprn.
      IF sy-subrc EQ 0.
        lv_rcvprn = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0

      READ TABLE li_constant ASSIGNING <lfs_status>
                    WITH KEY criteria = lc_idoctp.
      IF sy-subrc EQ 0.
        lv_idoctp = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0

**--- End of Changes CR D2_237 by APODDAR on 05th Nov 2014

      IF control_record_out-mestyp = lv_mestyp
        AND control_record_out-rcvprn = lv_rcvprn
        AND control_record_out-idoctp = lv_idoctp.

**-----------Get record count-----------**
        DESCRIBE TABLE int_edidd LINES lv_tfill.
**--------Read Segment E1EDK01---------**
        READ TABLE int_edidd ASSIGNING <lfs_edidd_id99> WITH KEY segnam = lc_seg_e1edk01_id99.
        IF sy-subrc EQ 0.
          lwa_e1edk01_id99 = <lfs_edidd_id99>-sdata.
          lv_belnr_01 = lwa_e1edk01_id99-belnr.
        ENDIF. " IF sy-subrc EQ 0

* Begin Defect 2676 - NLIRA
*       In the case where multiple Invoices are created simultaneously, the internal VBRP table needs
*       to be refreshed, otherwise, the next IDoc (for subsequent invoices) will be using the values
*       from the first IDoc as the table is only populated when it is empty
        IF lv_tfill = 1. "If there is only one segment, it must be a new IDoc
          READ TABLE int_edidd INTO lwa_edidd INDEX 1. "Get the first IDoc entry
          IF sy-subrc = 0.
            IF lwa_edidd-segnam = lc_seg_e1edk01_id99. "Check that it is E1EDK01
              REFRESH li_vbrp. "Refrsh the table
              CLEAR li_vbrp.
              CALL FUNCTION 'ZOTC_SET_PARAM'
                EXPORTING
                  im_tabix    = 0 "Defect# 8300
                  im_tbl_vbrp = li_vbrp.
            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF control_record_out-mestyp = lv_mestyp
        ENDIF. " IF sy-subrc EQ 0

* End Defect 2676

        UNASSIGN <lfs_edidd_id99>.
**--------Read Segment E1EDK02---------**
        READ TABLE int_edidd ASSIGNING <lfs_edidd_id99> WITH KEY segnam = lc_seg_e1edk02_id99
                                                                 sdata(3) = lc_qualf_002_id99.
        IF sy-subrc EQ 0.
          lwa_e1edk02_id99 = <lfs_edidd_id99>-sdata.
          lv_vbeln = lwa_e1edk02_id99-belnr.
        ENDIF. " IF sy-subrc EQ 0

* ---> Begin of Delete for D2_OTC_IDD_0099 Defect 5214 by DMOIRAN
* Below code has been commented out and re-written.

*        READ TABLE int_edidd TRANSPORTING NO FIELDS WITH KEY segnam = lc_seg_e1edk02_id99.
*        IF sy-subrc EQ 0.
*
*          CALL FUNCTION 'ZOTC_GET_PARAM'
*            IMPORTING
*              ex_docref = lv_docref.
*
*          IF lv_docref IS INITIAL.
*
*            SELECT SINGLE
*              zzdocref " Legacy Doc Ref
*             FROM vbrk " Billing Document: Header Data
*            INTO lv_docref
*            WHERE vbeln = lv_belnr_01
*             AND zzdoctyp = lc_doctyp_two.
*            IF sy-subrc EQ 0.
*              CALL FUNCTION 'ZOTC_SET_PARAM'
*                EXPORTING
*                  im_docref = lv_docref.
*            ENDIF. " IF sy-subrc EQ 0
*          ENDIF. " IF lv_docref IS INITIAL
*          CLEAR lwa_edidd_id99.
*          lwa_e1edk02_id99-qualf = lc_qualf_z01_id99.
*          lwa_e1edk02_id99-belnr = lv_docref.
*          lwa_edidd_id99-segnam  = lc_seg_e1edk02_id99.
*          lwa_edidd_id99-sdata   = lwa_e1edk02_id99.
*          READ TABLE int_edidd TRANSPORTING NO FIELDS WITH KEY segnam = lc_seg_e1edk02_id99
*                                                             sdata(3) = lc_qualf_z01_id99.
*
*          IF sy-subrc NE 0.
*            APPEND lwa_edidd_id99 TO int_edidd.
*          ENDIF. " IF sy-subrc NE 0
*
*        ENDIF. " IF sy-subrc EQ 0
* <--- End    of Delete for D2_OTC_IDD_0099 Defect 5214 by DMOIRAN

* ---> Begin of Insert for D2_OTC_IDD_0099 Defect 5214 by DMOIRAN
* Segment E1EDK02 with qualifer Z01 should be added once E1EDK02 has been added by standard
* SAP code.
        READ TABLE int_edidd TRANSPORTING NO FIELDS WITH KEY segnam = lc_seg_e1edk02_id99.
        IF sy-subrc EQ 0.
* This user exit is called for each segment so check if segment with qualifer has already been
* added or not.
          READ TABLE int_edidd TRANSPORTING NO FIELDS WITH KEY segnam = lc_seg_e1edk02_id99
                                                             sdata(3) = lc_qualf_z01_id99.
          IF sy-subrc NE 0.
            SELECT SINGLE
              zzdocref " Legacy Doc Ref
             FROM vbrk " Billing Document: Header Data
            INTO lv_docref
            WHERE vbeln = lv_belnr_01
             AND zzdoctyp = lc_doctyp_two.
            IF sy-subrc EQ 0 AND lv_docref IS NOT INITIAL.

              CLEAR lwa_edidd_id99.
              lwa_e1edk02_id99-qualf = lc_qualf_z01_id99.
              lwa_e1edk02_id99-belnr = lv_docref.
              lwa_edidd_id99-segnam  = lc_seg_e1edk02_id99.
              lwa_edidd_id99-sdata   = lwa_e1edk02_id99.
              APPEND lwa_edidd_id99 TO int_edidd.

            ENDIF. " IF sy-subrc EQ 0 AND lv_docref IS NOT INITIAL
          ENDIF. " IF sy-subrc NE 0
        ENDIF. " IF sy-subrc EQ 0
* <--- End    of Insert for D2_OTC_IDD_0099 Defect 5214 by DMOIRAN

        READ TABLE int_edidd TRANSPORTING NO FIELDS WITH KEY segnam = lc_seg_e1edk03_id99.
        IF sy-subrc EQ 0.
          CALL FUNCTION 'ZOTC_GET_PARAM'
            IMPORTING
              ex_auart = lv_auart
              ex_audat = lv_audat.

          IF lv_audat IS INITIAL
           OR lv_auart IS INITIAL.
            SELECT SINGLE audat " Document Date (Date Received/Sent)
                          auart " Sales Document Type
            FROM vbak           " Sales Document: Header Data
            INTO (lv_audat, lv_auart)
            WHERE vbeln = lv_vbeln.
            IF sy-subrc = 0.
              CALL FUNCTION 'ZOTC_SET_PARAM'
                EXPORTING
                  im_auart = lv_auart
                  im_audat = lv_audat.

            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF lv_audat IS INITIAL
          lwa_e1edk03_id99-iddat = lc_iddat_id99.
          lwa_e1edk03_id99-datum = lv_audat.
          lwa_edidd_id99-segnam  = lc_seg_e1edk03_id99.
          lwa_edidd_id99-sdata   = lwa_e1edk03_id99.
          READ TABLE int_edidd TRANSPORTING NO FIELDS WITH KEY segnam = lc_seg_e1edk03_id99
                                                               sdata(3) = lc_iddat_id99.
          IF sy-subrc NE 0.
            APPEND lwa_edidd_id99 TO int_edidd.
          ENDIF. " IF sy-subrc NE 0
        ENDIF. " IF sy-subrc EQ 0

**--- Begin of Changes CR D2_73 D2_135 by APODDAR on 07th Oct 2014
*----Append E1EDK14 with Identifier 012------*
        READ TABLE int_edidd TRANSPORTING NO FIELDS WITH KEY segnam   = lc_seg_e1edk14_id99.
        IF sy-subrc EQ 0.
          lwa_e1edk14_id99-qualf = lc_qualf_012_id99.
          lwa_e1edk14_id99-orgid = lv_auart.
          lwa_edidd_id99-segnam  = lc_seg_e1edk14_id99.
          lwa_edidd_id99-sdata   = lwa_e1edk14_id99.
          READ TABLE int_edidd TRANSPORTING NO FIELDS WITH KEY segnam   = lc_seg_e1edk14_id99
                                                               sdata(3) = lc_qualf_012_id99.
          IF sy-subrc NE 0.
            APPEND lwa_edidd_id99 TO int_edidd.
          ENDIF. " IF sy-subrc NE 0
        ENDIF. " IF sy-subrc EQ 0
**--- End of Changes CR D2_73 D2_135 by APODDAR on 07th Oct 2014
**-----Check if Segment already Created-----**
        IF lv_belnr_01 IS NOT INITIAL.
          CALL FUNCTION 'ZOTC_GET_PARAM'
            IMPORTING
              ex_tbl_vbrp = li_vbrp.

          IF li_vbrp IS INITIAL.
            SELECT vbeln  " Billing Document
               posnr      " Billing item
               aubel      " Sales Document
               mvgr1      " Material group 1
               zzitemref  " ServMax Obj ID
               zzquoteref " Legacy Qtn Ref
               zzlnref    " Instrument Reference
            FROM vbrp     " Billing Document: Item Data
          INTO TABLE li_vbrp
            WHERE vbeln = lv_belnr_01.
            IF sy-subrc EQ 0.
              SORT li_vbrp BY vbeln posnr.
              CALL FUNCTION 'ZOTC_SET_PARAM'
                EXPORTING
                  im_tbl_vbrp = li_vbrp.

            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF li_vbrp IS INITIAL

**   Begin of Changes for CR D2_135 by APODDAR
          UNASSIGN <lfs_vbrp>.
          READ TABLE li_vbrp ASSIGNING <lfs_vbrp> INDEX 1.
          IF sy-subrc = 0.
            lwa_vbco6-vbeln = <lfs_vbrp>-aubel.
            CALL FUNCTION 'ZOTC_GET_PARAM'
              IMPORTING
                ex_tbl_vbfa = li_vbfa.

            IF li_vbfa IS INITIAL.
              CALL FUNCTION 'RV_ORDER_FLOW_INFORMATION' "Approval taken for D2_OTC_IDD_0092
              EXPORTING
                comwa         = lwa_vbco6
              TABLES
                vbfa_tab      = li_vbfa
              EXCEPTIONS
                no_vbfa       = 1
                no_vbuk_found = 2
                OTHERS        = 3.
              IF sy-subrc EQ 0.
                SORT li_vbfa BY vbelv vbtyp_n posnv.
                CALL FUNCTION 'ZOTC_SET_PARAM'
                  EXPORTING
                    im_tbl_vbfa = li_vbfa.

              ENDIF. " IF sy-subrc EQ 0
            ENDIF. " IF li_vbfa IS INITIAL

          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF lv_belnr_01 IS NOT INITIAL

        IF li_vbfa IS NOT INITIAL.
          CALL FUNCTION 'ZOTC_GET_PARAM'
            IMPORTING
              ex_tbl_ser01 = li_ser01.

          IF li_ser01 IS INITIAL.
            SELECT
            obknr    " Object list number
            lief_nr  " Delivery
            posnr    " Delivery Item
          FROM ser01 " Document Header for Serial Numbers for Delivery
          INTO TABLE li_ser01
          FOR ALL ENTRIES IN li_vbfa
          WHERE lief_nr = li_vbfa-vbeln
            AND posnr   = li_vbfa-posnv.
            IF sy-subrc EQ 0.
              SORT li_ser01 BY lief_nr posnr.
              CALL FUNCTION 'ZOTC_SET_PARAM'
                EXPORTING
                  im_tbl_ser01 = li_ser01.
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF li_ser01 IS INITIAL

          IF li_ser01 IS NOT INITIAL. "Changes due to Defect # 1729 LI_OBJK to be populated from FM
            CALL FUNCTION 'ZOTC_GET_PARAM'
              IMPORTING
                ex_tbl_objk = li_objk.
            IF li_objk IS INITIAL.
              SELECT
                obknr   " Object list number
                obzae   " Object list counters
                sernr   " Serial Number
                matnr   " Material Number
              FROM objk " Plant Maintenance Object List
              INTO TABLE li_objk
              FOR ALL ENTRIES IN li_ser01
              WHERE obknr = li_ser01-obknr.
              IF sy-subrc = 0.
                SORT li_objk BY obknr.
                CALL FUNCTION 'ZOTC_SET_PARAM'
                  EXPORTING
                    im_tbl_objk = li_objk.
              ENDIF. " IF sy-subrc = 0
            ENDIF. " IF li_objk IS INITIAL
          ENDIF. " IF li_vbfa IS NOT INITIAL
        ENDIF. " IF sy-subrc EQ 0

**        End of Changes for CR D2_135 by APODDAR

        UNASSIGN <lfs_edidd_id99>.
        READ TABLE int_edidd ASSIGNING <lfs_edidd_id99> INDEX lv_tfill.
        IF sy-subrc = 0.
          lv_subrc = abap_true.
        ENDIF. " IF sy-subrc = 0
        UNASSIGN <lfs_vbrp>.

**--- Begin of Changes for CR D2_237 by APODDAR on 05th Nov 2014

        IF dobject-kschl = lv_partn.
          CALL FUNCTION 'ZOTC_GET_PARAM'
            IMPORTING
              ex_del_flag = lv_del_flag
              ex_tabix    = lv_tabix.
          CALL FUNCTION 'ZOTC_GET_PARAM'
            IMPORTING
              ex_po_type = lv_po_type.

          IF lv_po_type IS INITIAL.
            SELECT SINGLE
           bsark     " Customer purchase order type
           FROM vbkd " Sales Document: Business Data
           INTO lv_po_type
           WHERE vbeln = lv_vbeln
             AND posnr = lc_posnr.
            IF sy-subrc = 0.
              CALL FUNCTION 'ZOTC_SET_PARAM'
                EXPORTING
                  im_po_type = lv_po_type.

            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF lv_po_type IS INITIAL

          IF lv_po_type NE lv_partn.
            DELETE li_vbrp WHERE mvgr1 NOT IN li_mvgr1.
            DELETE li_vbrp WHERE mvgr1 NOT IN li_mvgr1.
            IF lv_del_flag = abap_true.
              lv_tab_lim = lv_tfill - 1.
              IF lv_tabix IS NOT INITIAL AND lv_tab_lim IS NOT INITIAL. "Defect# 8300
                DELETE int_edidd FROM lv_tabix TO lv_tab_lim.
              ENDIF. " IF lv_del_flag = abap_true
            ENDIF. " IF lv_po_type NE lv_partn
          ENDIF. " IF dobject-kschl = lv_partn


          IF <lfs_edidd_id99>-segnam = lc_seg_e1edp01_id99.
            READ TABLE li_vbrp TRANSPORTING NO FIELDS
                WITH KEY posnr = <lfs_edidd_id99>-sdata(6).
            IF sy-subrc NE 0.
              lv_del_flag = abap_true.
              DESCRIBE TABLE int_edidd LINES lv_tabix.
              CALL FUNCTION 'ZOTC_SET_PARAM'
                EXPORTING
                  im_del_flag = lv_del_flag
                  im_tabix    = lv_tabix.
            ELSE. " ELSE -> IF sy-subrc NE 0
              CLEAR lv_tabix.
              lv_del_flag = abap_false.
              CALL FUNCTION 'ZOTC_SET_PARAM'
                EXPORTING
                  im_del_flag = lv_del_flag
                  im_tabix    = lv_tabix.
            ENDIF. " IF sy-subrc NE 0
          ENDIF. " IF <lfs_edidd_id99>-segnam = lc_seg_e1edp01_id99

        ENDIF. " IF dobject-kschl = lv_partn

        IF lv_del_flag NE abap_true.

          LOOP AT li_vbrp ASSIGNING <lfs_vbrp>.
*&-- Determine the current item no being processed
            IF lv_subrc = abap_true.
              IF <lfs_edidd_id99>-segnam = lc_seg_e1edp01_id99
             AND <lfs_edidd_id99>-sdata(6) = <lfs_vbrp>-posnr.

                IF <lfs_vbrp>-zzitemref IS NOT INITIAL.
*----Append E1EDP02 with Identifier Z01------*
                  CLEAR: lwa_edidd_id99,
                         lwa_e1edp02_id99.
                  lwa_e1edp02_id99-qualf = lc_qualf_z01_id99.
                  lwa_e1edp02_id99-belnr = <lfs_vbrp>-zzitemref.
                  lwa_edidd_id99-segnam  = lc_seg_e1edp02_id99.
                  lwa_edidd_id99-sdata   = lwa_e1edp02_id99.
                  APPEND lwa_edidd_id99 TO int_edidd.
                ENDIF. " IF <lfs_vbrp>-zzitemref IS NOT INITIAL

                IF <lfs_vbrp>-zzquoteref IS NOT INITIAL.
*----Append E1EDP02 with Identifier Z02------*
                  CLEAR: lwa_edidd_id99,
                         lwa_e1edp02_id99.
                  lwa_e1edp02_id99-qualf = lc_qualf_z02_id99.
                  lwa_e1edp02_id99-ihrez = <lfs_vbrp>-zzquoteref.
                  lwa_edidd_id99-segnam  = lc_seg_e1edp02_id99.
                  lwa_edidd_id99-sdata   = lwa_e1edp02_id99.
                  APPEND lwa_edidd_id99 TO int_edidd.
                ENDIF. " IF <lfs_vbrp>-zzquoteref IS NOT INITIAL

**--- Begin of Changes CR D2_256 by APODDAR on 11th Dec 2014
                IF <lfs_vbrp>-zzlnref IS NOT INITIAL.
*----Append E1EDP02 with Identifier Z02------*
                  CLEAR: lwa_edidd_id99,
                         lwa_e1edp02_id99.
                  lwa_e1edp02_id99-qualf = lc_qualf_z03_id99.
                  lwa_e1edp02_id99-zeile = <lfs_vbrp>-zzlnref.
                  lwa_edidd_id99-segnam  = lc_seg_e1edp02_id99.
                  lwa_edidd_id99-sdata   = lwa_e1edp02_id99.
                  APPEND lwa_edidd_id99 TO int_edidd.
                ENDIF. " IF <lfs_vbrp>-zzlnref IS NOT INITIAL
              ENDIF. " IF <lfs_edidd_id99>-segnam = lc_seg_e1edp01_id99
**--- End of Changes CR D2_256 by APODDAR on 11th Dec 2014

**        Begin of Changes for CR D2_135 by APODDAR
              IF <lfs_edidd_id99>-segnam = lc_seg_e1edp19_id99.
                READ TABLE li_vbfa ASSIGNING <lfs_vbfa>
                                    WITH KEY vbelv = <lfs_vbrp>-aubel
                                             vbtyp_n = lc_j
                                             posnv   = <lfs_vbrp>-zzlnref
                                             BINARY SEARCH.
                IF sy-subrc = 0.
                  READ TABLE li_ser01 ASSIGNING <lfs_ser01>
                                       WITH KEY lief_nr = <lfs_vbfa>-vbeln
                                                posnr   = <lfs_vbfa>-posnv
                                                BINARY SEARCH.
                  IF sy-subrc = 0.
                    READ TABLE li_objk TRANSPORTING NO FIELDS
                                     WITH KEY obknr = <lfs_ser01>-obknr
                                     BINARY SEARCH.
                    IF sy-subrc = 0.

                      lv_idx = sy-tabix.
                      LOOP AT li_objk ASSIGNING <lfs_objk> FROM lv_idx.
                        IF <lfs_ser01>-obknr NE <lfs_objk>-obknr.
                          EXIT.
                        ENDIF. " IF <lfs_ser01>-obknr NE <lfs_objk>-obknr
*----Append E1EDP19 with Identifier 014------*
                        CLEAR: lwa_edidd_id99,
                               lwa_e1edp19_id99.
                        SHIFT <lfs_objk>-sernr LEFT DELETING LEADING lc_zero.
                        lwa_e1edp19_id99-qualf = lc_qualf_014_id99.
                        lwa_e1edp19_id99-idtnr = <lfs_objk>-sernr.
                        lwa_e1edp19_id99-mfrpn = <lfs_objk>-matnr.

                        lwa_edidd_id99-segnam  = lc_seg_e1edp19_id99.
                        lwa_edidd_id99-sdata   = lwa_e1edp19_id99.

                        APPEND lwa_edidd_id99 TO int_edidd.

                      ENDLOOP. " LOOP AT li_objk ASSIGNING <lfs_objk> FROM lv_idx
                    ENDIF. " IF sy-subrc = 0
                  ENDIF. " IF sy-subrc = 0
                ENDIF. " IF sy-subrc = 0
              ENDIF. " IF <lfs_edidd_id99>-segnam = lc_seg_e1edp19_id99
**        End of Changes for CR D2_135 by APODDAR
            ENDIF. " IF lv_subrc = abap_true
          ENDLOOP. " LOOP AT li_vbrp ASSIGNING <lfs_vbrp>
        ENDIF. " IF lv_del_flag NE abap_true

**--- End of Changes for CR D2_237 by APODDAR on 05th Nov 2014

        CLEAR lv_subrc.
      ENDIF. " IF sy-subrc EQ 0

    ENDIF. " IF sy-subrc EQ 0
