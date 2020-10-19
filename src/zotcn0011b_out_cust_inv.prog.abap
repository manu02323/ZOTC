*&---------------------------------------------------------------------*
*&  Include           ZOTCN011_OUT_CUST_INV
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZXEDFU02                                               *
* TITLE      :  D2_OTC_IDD_011                                         *
* DEVELOPER  :  Manmeet Singh                                          *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_IDD_011_SAP Outbound Customer Invoice           *
*----------------------------------------------------------------------*
* DESCRIPTION: SAP Invoice to ServiceMax
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 20-JUN-2014 MSINGH1  E2DK900763  INITIAL DEVELOPMENT
*&---------------------------------------------------------------------*
* 18-Nov-2014 SSHARMA E2DK900763  CR D2_161 - Add ZNET in E1EDP05      *
* segment.                                                             *
*&---------------------------------------------------------------------*
* 17-Jul-2015 DMOIRAN E2DK914082  INC0238201. When mass processing is  *
* done E1EDP05 doesn't have ZNET pricing condition data.               *
*&---------------------------------------------------------------------*
* 30-Nov-2016 JAHANM E1DK918526  CR_246 Add logic to update cost center*
*                                and qualifier Z01 in segment E1EDP02  *
*&---------------------------------------------------------------------*
*** Constant
CONSTANTS :
            lc_seg_e1edka1 TYPE edilsegtyp VALUE 'E1EDKA1',                    " Name of SAP segment
            lc_seg_e1edk02 TYPE edilsegtyp VALUE 'E1EDK02',                    " Name of SAP segment
            lc_seg_e1edk14 TYPE edilsegtyp VALUE 'E1EDK14',                    " Name of SAP segment
            lc_qualf_002   TYPE edi_qualfr VALUE '002',                        " IDOC qualifier reference document
            lc_qualf_019   TYPE edi_qualfr VALUE '019',                        " IDOC qualifier reference document
            lc_parv_we     TYPE edi3035_a  VALUE 'WE',                         " Partner function (e.g. sold-to party, ship-to party, ...)
            lc_idd_0011_001 TYPE z_enhancement    VALUE 'D2_OTC_IDD_0011_001', " Enhancement No.
            lc_null         TYPE z_criteria       VALUE 'NULL',                " Enh. Criteria
* ---> Begin of Insert for D2_OTC_IDD_0011 / CR D2_161 by SSHARMA
            lc_e1edp05      TYPE edilsegtyp VALUE 'E1EDP05', " Segment type
            lc_znet         TYPE kscha      VALUE 'ZNET',    " Condition type
            lc_plus         TYPE edi5463_a  VALUE '+',       " Surcharge or discount indicator
* <--- End    of Insert for D2_OTC_IDD_0011 / CR D2_161 by SSHARMA

*-->Begin of change by JAHANM for CR_246 of D3_OTC_IDD_0011

            lc_e1edp02_inv  TYPE edilsegtyp VALUE 'E1EDP02', " Segment type
            lc_e1edp01_inv  TYPE edilsegtyp VALUE 'E1EDP01', " Segment type
*-->End of change by JAHANM for CR_246 of D3_OTC_IDD_0011

* ---> Begin of Insert for D2_OTC_IDD_0011 / INC0238201 by DMOIRAN
            lc_seg_e1edk01  TYPE edi_segnam VALUE 'E1EDK01'. " Name of SAP segment
* <--- End    of Insert for D2_OTC_IDD_0011 / INC0238201 by DMOIRAN




FIELD-SYMBOLS:
                <lfs_edi_ka1> TYPE edidd, " Data record (IDoc)
                <lfs_edi_k02> TYPE edidd, " Data record (IDoc)
                <lfs_edi_k14> TYPE edidd, " Data record (IDoc)
* ---> Begin of Insert for D2_OTC_IDD_0011 / CR D2_161 by SSHARMA
               <lfs_xikomvd>  TYPE komvd, " Price Determination Communication-Cond.Record for Printing

* <--- End    of Insert for D2_OTC_IDD_0011 / CR D2_161 by SSHARMA
* ---> Begin of Insert for D2_OTC_IDD_0011 / INC0238201 by DMOIRAN
               <lfs_edidd_tmp>    TYPE edidd. " Data record (IDoc)
* <--- End    of Insert for D2_OTC_IDD_0011 / INC0238201 by DMOIRAN

*-->Begin of change by JAHANM for CR_246 of D3_OTC_IDD_0011

TYPES: BEGIN OF lty_vbrp_zkostl,
         vbeln TYPE vbeln,  " Sales and Distribution Document Number
         posnr TYPE posnr,  " Item number of the SD document
         zkostl TYPE kostl, " Cost Center
       END OF lty_vbrp_zkostl .
*-->End of change by JAHANM for CR_246 of D3_OTC_IDD_0011


*** Declaration

DATA :
            li_status          TYPE STANDARD TABLE OF zdev_enh_status, "Enhancement Status tabl
* ---> Begin of Insert for D2_OTC_IDD_0011 / CR D2_161 by SSHARMA
            li_xikomvd        TYPE STANDARD TABLE OF komvd. " Price Determination Communication-Cond.Record for Printing
* <--- End    of Insert for D2_OTC_IDD_0011 / CR D2_161 by SSHARMA
DATA :      li_edidd           TYPE STANDARD TABLE OF edidd. " Data record (IDoc)
DATA :      lv_pc_ind          TYPE sytabix. " Pc_ind of type Integers
DATA:
            lv_019_exists TYPE flag, " General Flag
            lv_index      TYPE i.    " Index of type Integers

DATA :      lv_lifnr     TYPE lifnr_ed1,   " Vendor Account Number
            lv_kposn     TYPE komvd-kposn, " Condition item number
            lwa_e1edka1  TYPE e1edka1.     " IDoc: Document Header Partner Information

DATA :      lv_bsark    TYPE bsark,   " Customer purchase order type
            lwa_e1edk02 TYPE e1edk02, " IDoc: Document header reference data
            lwa_e1edk14 TYPE e1edk14, " IDoc: Document Header Organizational Data
* ---> Begin of Insert for D2_OTC_IDD_0011 / CR D2_161 by SSHARMA
            lwa_e1edp05  TYPE e1edp05, " IDoc: Document Item Conditions
* <--- End    of Insert for D2_OTC_IDD_0011 / CR D2_161 by SSHARMA

* ---> Begin of Insert for D2_OTC_IDD_0011 / INC0238201 by DMOIRAN

           lx_e1edk01_idd_11   TYPE e1edk01,  " IDoc: Document header general data
           lv_invoice          TYPE vbeln_vf, " Billing Document
* <--- End of Insert for D2_OTC_IDD_0011 / INC0238201 by DMOIRAN

*-->Begin of change by JAHANM for CR_246 of D3_OTC_IDD_0011
           lx_edidd_inv        TYPE edidd,   " Data record (IDoc)
           lx_e1edp01_inv      TYPE e1edp01, " IDoc: Item General Data
           lx_e1edp02_inv      TYPE e1edp02, " IDoc: Item General Data
           lwa_vbrp            TYPE lty_vbrp_zkostl,
           lv_index_t          TYPE i.       " Index of type Integers
*--<End of change by JAHANM for CR_246 of D3_OTC_IDD_0011



* Call to EMI Function Module To Get List Of EMI Statuses
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_idd_0011_001 "D2_OTC_IDD_0011_001
  TABLES
    tt_enh_status     = li_status.      "Enhancement status table


*first thing is to check for field criterion,for value “NULL” and field Active value:
*i.If the value is: “X”, the overall Enhancement is active and can proceed further for checks
*ii.If the  value is:space, then do not proceed further for this enhancement
READ TABLE li_status WITH KEY criteria = lc_null "NULL
                              active = abap_true "X"
                     TRANSPORTING NO FIELDS.
IF sy-subrc EQ  0.

***  Logic for Vendor - Start
  IF <lfs_edidd> IS ASSIGNED.
    UNASSIGN <lfs_edidd>.
  ENDIF. " IF <lfs_edidd> IS ASSIGNED

*** Check of appropriate segment to fetch Sales order number
  READ TABLE int_edidd ASSIGNING <lfs_edidd> WITH KEY segnam = lc_seg_e1edk02 .
  IF sy-subrc = 0.
** Clear Variable
    CLEAR : lwa_edidd ,
            lv_index,
            lv_belnr,
            lv_lifnr.
    IF <lfs_edidd> IS ASSIGNED.
      UNASSIGN <lfs_edidd>.
    ENDIF. " IF <lfs_edidd> IS ASSIGNED

** Check the latest segment as the exit is being called for each segment
    DESCRIBE TABLE int_edidd LINES lv_index.
    READ TABLE int_edidd ASSIGNING <lfs_edidd> INDEX lv_index.
    IF sy-subrc EQ 0 AND <lfs_edidd>-segnam = lc_seg_e1edk02 .
      lwa_e1edk02 = <lfs_edidd>-sdata.
** Check Qualifier of latest segment
      IF lwa_e1edk02-qualf = lc_qualf_002.
** Sales order number retrieved
        lv_belnr = lwa_e1edk02-belnr.
*** Relevant Vendor is extracted
        CALL FUNCTION 'ZOTC_0011_SD_GET_LIFNR'
          EXPORTING
            im_belnr = lv_belnr
          IMPORTING
            ex_lifnr = lv_lifnr.

        REFRESH li_edidd[].
** Populating vendor to relevant segment
        IF <lfs_edi_ka1> IS ASSIGNED.
          UNASSIGN <lfs_edi_ka1>.
        ENDIF. " IF <lfs_edi_ka1> IS ASSIGNED

        LOOP AT int_edidd ASSIGNING <lfs_edi_ka1> WHERE segnam = lc_seg_e1edka1.
*** Check for Partner
          lwa_e1edka1 = <lfs_edi_ka1>-sdata.
          IF lwa_e1edka1-parvw EQ lc_parv_we.
            IF lv_lifnr IS NOT INITIAL.
              lwa_e1edka1-lifnr = lv_lifnr.
*Begin of Defect# 2794
*If LIFNR is blank populate 0
            ELSE. " ELSE -> IF lv_lifnr IS NOT INITIAL
              lwa_e1edka1-lifnr = 0.
*End of Defect# 2794
            ENDIF. " IF lv_lifnr IS NOT INITIAL
            <lfs_edi_ka1>-sdata = lwa_e1edka1.
            EXIT.
          ENDIF. " IF lwa_e1edka1-parvw EQ lc_parv_we
        ENDLOOP. " LOOP AT int_edidd ASSIGNING <lfs_edi_ka1> WHERE segnam = lc_seg_e1edka1
        IF <lfs_edi_ka1> IS ASSIGNED.
          UNASSIGN <lfs_edi_ka1>.
        ENDIF. " IF <lfs_edi_ka1> IS ASSIGNED

      ENDIF. " IF lwa_e1edk02-qualf = lc_qualf_002
    ENDIF. " IF sy-subrc EQ 0 AND <lfs_edidd>-segnam = lc_seg_e1edk02
  ENDIF. " IF sy-subrc = 0

  IF <lfs_edidd> IS ASSIGNED.
    UNASSIGN <lfs_edidd>.
  ENDIF. " IF <lfs_edidd> IS ASSIGNED
***  Logic for Vendor - End


***  Logic for Purchase Order Type - Start
** Check the latest segment as the exit is being called for each segment
  DESCRIBE TABLE int_edidd LINES lv_index.
  READ TABLE int_edidd ASSIGNING <lfs_edidd> INDEX lv_index.
  IF sy-subrc = 0 AND <lfs_edidd>-segnam = lc_seg_e1edk14.
** Initializing variables
    CLEAR : lwa_edidd ,
            lv_belnr.
*** parallel cursor
    li_edidd[] = int_edidd[].
    SORT li_edidd BY segnam.
    CLEAR lv_pc_ind.
    READ TABLE li_edidd ASSIGNING <lfs_edi_k14> WITH KEY segnam = lc_seg_e1edk14 BINARY SEARCH.
    IF sy-subrc EQ 0.
      lv_pc_ind = sy-tabix.
    ENDIF. " IF sy-subrc EQ 0
** Check whether 019 is appended
    lv_019_exists = abap_false.
    IF <lfs_edi_k14> IS ASSIGNED.
      UNASSIGN <lfs_edi_k14>.
    ENDIF. " IF <lfs_edi_k14> IS ASSIGNED
    LOOP AT li_edidd ASSIGNING <lfs_edi_k14> FROM lv_pc_ind .
      IF <lfs_edi_k14>-segnam NE lc_seg_e1edk14.
        EXIT.
      ENDIF. " IF <lfs_edi_k14>-segnam NE lc_seg_e1edk14
      lwa_e1edk14 = <lfs_edi_k14>-sdata.
      IF lwa_e1edk14-qualf = lc_qualf_019.
        lv_019_exists = abap_true.
        EXIT.
      ENDIF. " IF lwa_e1edk14-qualf = lc_qualf_019
    ENDLOOP. " LOOP AT li_edidd ASSIGNING <lfs_edi_k14> FROM lv_pc_ind
    CLEAR : lwa_e1edk14.
    IF <lfs_edi_k14> IS ASSIGNED.
      UNASSIGN <lfs_edi_k14>.
    ENDIF. " IF <lfs_edi_k14> IS ASSIGNED

    IF lv_019_exists = abap_false.
      IF <lfs_edi_k02> IS ASSIGNED.
        UNASSIGN <lfs_edi_k02>.
      ENDIF. " IF <lfs_edi_k02> IS ASSIGNED
      CLEAR lv_pc_ind.
      READ TABLE li_edidd ASSIGNING <lfs_edi_k02> WITH KEY segnam = lc_seg_e1edk02 BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_pc_ind = sy-tabix.
      ENDIF. " IF sy-subrc EQ 0
      IF <lfs_edi_k02> IS ASSIGNED.
        UNASSIGN <lfs_edi_k02>.
      ENDIF. " IF <lfs_edi_k02> IS ASSIGNED
*** All check cleared to Append Idoc
      LOOP AT li_edidd ASSIGNING <lfs_edi_k02> FROM lv_pc_ind.

        IF <lfs_edi_k02>-segnam NE lc_seg_e1edk02.
          EXIT.
        ENDIF. " IF <lfs_edi_k02>-segnam NE lc_seg_e1edk02
*** Check for appropriate Qualifier
        lwa_e1edk02 = <lfs_edi_k02>-sdata.
        IF lwa_e1edk02-qualf = lc_qualf_002.
*** Check for document number
          lv_belnr = lwa_e1edk02-belnr.
** Get PO Type
          SELECT SINGLE bsark " Customer purchase order type
            FROM vbak         " Sales Document: Header Data
            INTO lv_bsark
            WHERE vbeln = lv_belnr.
          IF sy-subrc EQ 0.

** Append Segment with required values
            lwa_e1edk14-qualf = lc_qualf_019.
            lwa_e1edk14-orgid = lv_bsark.
            lwa_edidd-sdata = lwa_e1edk14.
            lwa_edidd-segnam = lc_seg_e1edk14.
            APPEND lwa_edidd TO int_edidd.
            EXIT.
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF lwa_e1edk02-qualf = lc_qualf_002
      ENDLOOP. " LOOP AT li_edidd ASSIGNING <lfs_edi_k02> FROM lv_pc_ind
    ENDIF. " IF lv_019_exists = abap_false

    IF <lfs_edi_k02> IS ASSIGNED.
      UNASSIGN <lfs_edi_k02>.
    ENDIF. " IF <lfs_edi_k02> IS ASSIGNED
  ENDIF. " IF sy-subrc = 0 AND <lfs_edidd>-segnam = lc_seg_e1edk14

* ---> Begin of Insert for D2_OTC_IDD_0011 / CR D2_161 by SSHARMA

  CLEAR lv_index.
* This user exit is called for each segment. So, check the last segment and
* and then add ZNET in E1EDP05 segment if there is ZNET pricing condition type
  DESCRIBE TABLE int_edidd LINES lv_index.
  READ TABLE int_edidd ASSIGNING <lfs_edidd> INDEX lv_index.
  IF sy-subrc = 0.
    IF <lfs_edidd>-segnam = lc_e1edp05.
      CLEAR li_xikomvd[].
      li_xikomvd[] = xikomvd[].
      SORT li_xikomvd BY kschl.
      READ TABLE li_xikomvd ASSIGNING <lfs_xikomvd> WITH KEY kschl = lc_znet
                                                  BINARY SEARCH.
      IF sy-subrc = 0.
* populate data to E1EDP05 segment
        CLEAR lwa_e1edp05.
        lwa_e1edp05-alckz = lc_plus.
        lwa_e1edp05-kschl = lc_znet.

        lwa_e1edp05-betrg = <lfs_xikomvd>-kwert.
        SHIFT lwa_e1edp05-betrg LEFT DELETING LEADING space.

        lwa_e1edp05-krate = <lfs_xikomvd>-kbetr.
        SHIFT lwa_e1edp05-krate LEFT DELETING LEADING space.

        lwa_e1edp05-uprbs = <lfs_xikomvd>-kpein.
        SHIFT lwa_e1edp05-uprbs LEFT DELETING LEADING space.

        lwa_e1edp05-meaun = <lfs_xikomvd>-kmein.
        lwa_e1edp05-koein = <lfs_xikomvd>-koein.

* add the segment.
* ---> Begin of Delete for D2_OTC_IDD_0011 / INC0238201 by DMOIRAN
*        IF <lfs_xikomvd>-kposn <> gv_kposn.
* <--- End    of Delete for D2_OTC_IDD_0011 / INC0238201 by DMOIRAN

* ---> Begin of Insert for D2_OTC_IDD_0011 / INC0238201 by DMOIRAN
* As GV_KPOSN is a global variable when mass processing is done in
* scenario where first invoice has only 1 line item, E1EDP05 will not
* have ZNET data for next invoice. So, compare line item or invoice.

        READ TABLE int_edidd ASSIGNING <lfs_edidd_tmp> WITH KEY segnam = lc_seg_e1edk01.
        IF sy-subrc = 0.
          lx_e1edk01_idd_11 = <lfs_edidd_tmp>-sdata.
          lv_invoice = lx_e1edk01_idd_11-belnr.
        ENDIF. " IF sy-subrc = 0

        IF <lfs_xikomvd>-kposn <> gv_kposn OR
           lv_invoice NE gv_invoice.
* <--- End    of Insert for D2_OTC_IDD_0011 / INC0238201 by DMOIRAN
* Segment e1edp05 repeats multiple times for same item number.
*  to prevent this first check if the current item is already inserted
          CLEAR lwa_edidd.
          lwa_edidd-sdata = lwa_e1edp05.
          lwa_edidd-segnam = lc_e1edp05.
          APPEND lwa_edidd TO int_edidd.
          gv_kposn = <lfs_xikomvd>-kposn.

* ---> Begin of Insert for D2_OTC_IDD_0011 / INC0238201 by DMOIRAN
* Store the current invoice number to be compared later.
          gv_invoice = lv_invoice.
* <--- End    of Insert for D2_OTC_IDD_0011 / INC0238201 by DMOIRAN
        ENDIF. " IF <lfs_xikomvd>-kposn <> gv_kposn OR
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF <lfs_edidd>-segnam = lc_e1edp05

* -->Begin of change by JAHANM for CR_246 of D3_OTC_IDD_0011

    IF <lfs_edidd>-segnam = lc_e1edp02_inv.

      READ TABLE int_edidd ASSIGNING <lfs_edidd_tmp> INDEX lv_index.
      IF sy-subrc = 0 AND <lfs_edidd_tmp>-segnam = lc_e1edp02_inv.
        lv_index_t = lv_index - 1.
        lv_index = lv_index + 1.
      ENDIF. " IF sy-subrc = 0 AND <lfs_edidd>-segnam = lc_e1edp02_inv

      READ TABLE int_edidd ASSIGNING <lfs_edidd_tmp> INDEX lv_index_t.
      IF sy-subrc = 0 AND <lfs_edidd_tmp>-segnam = lc_e1edp01_inv..
        lx_e1edp01_inv = <lfs_edidd_tmp>-sdata.

        UNASSIGN: <lfs_edidd_tmp>.
        SELECT SINGLE vbeln posnr zkostl
                 FROM vbrp " Billing Document: Item Data
                 INTO lwa_vbrp
                WHERE vbeln = xvbdkr-vbeln
                  AND posnr = lx_e1edp01_inv-posex.
        IF sy-subrc = 0 .
          lx_e1edp02_inv-qualf   = 'Z01'.
          lx_e1edp02_inv-belnr   = lwa_vbrp-zkostl.
          lx_edidd_inv-segnam    = 'E1EDP02'.
          lx_edidd_inv-sdata     = lx_e1edp02_inv.
          INSERT lx_edidd_inv INTO int_edidd INDEX lv_index.
          CLEAR: lx_edidd_inv,
                 lv_index.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc = 0 AND <lfs_edidd>-segnam = lc_e1edp01_inv
    ENDIF. " IF <lfs_edidd>-segnam = lc_e1edp02_inv
* --<End of change by JAHANM for CR_246 of D3_OTC_IDD_0011

  ENDIF. " IF sy-subrc = 0


* <--- End    of Insert for D2_OTC_IDD_0011 / CR D2_161 by SSHARMA


  IF <lfs_edidd> IS ASSIGNED.
    UNASSIGN <lfs_edidd>.
  ENDIF. " IF <lfs_edidd> IS ASSIGNED
  FREE : li_edidd, li_status.
***  Logic for Purchase Order Type - End
ENDIF. " IF sy-subrc EQ 0
