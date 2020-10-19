*&---------------------------------------------------------------------*
*& Include           ZOTCN0141O_ENH_FOR_DSMA
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0141O_ENH_FOR_DSMA                                *
* TITLE      :  Enhancement to add tax class to billing tab            *
* DEVELOPER  :  Raghav Sureddi                                         *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_CDD_0141_Convert Open Service Plans                *
*----------------------------------------------------------------------*
* DESCRIPTION: D3.R2,include program is triggered in user exit ZXVEDU04*
* to add additional tax classifi to the billing tab of the sales Order *
* when CDD_0141_ conversion is run and we have to populate the bdcdata *
* with the flag based on e1edk04 segment is available                  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
*    DATE       USER    TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 02-Oct-2017 U033876    E1DK931303  INITIAL DEVELOPMENT               *
*&---------------------------------------------------------------------*

DATA: lwa_edidd TYPE edidd,                                 " Data record (IDoc)
      lwa_e1edk04 TYPE e1edk04,                             " IDoc: Document header taxes
      lv_lines    TYPE i,                                   " Lines of type Integers
      li_constants TYPE STANDARD TABLE OF zdev_enh_status , " Enhancement Status
      lwa_constants TYPE zdev_enh_status .                  " Enhancement Status
CONSTANTS: lc_enh_name   TYPE z_enhancement VALUE 'OTC_CDD_0141', " Enhancement No.
           lc_crit_fnam  TYPE z_criteria    VALUE 'FNAM',         " Enh. Criteria
           lc_vbak_taxk1 TYPE char10 VALUE 'VBAK-TAXK1',  " Vbak_taxk1 of type CHAR10
           lc_taxk1      TYPE char5  VALUE 'TAXK1',       " Taxk1 of type CHAR5
           lc_e1edk04    TYPE edilsegtyp VALUE 'E1EDK04'. " Number of SAP segment

*get the constants
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_enh_name
  TABLES
    tt_enh_status     = li_constants.
IF li_constants IS NOT INITIAL.
  DELETE li_constants WHERE active = abap_false.
  SORT li_constants BY criteria sel_low active.
ENDIF. " IF li_constants IS NOT INITIAL

* Check the las line of BDc data to have any one value in Constants
CLEAR lv_lines.
DESCRIBE TABLE dxbdcdata LINES lv_lines.
READ TABLE dxbdcdata INTO lwa_bdcdata INDEX lv_lines.
IF sy-subrc EQ 0 .
  READ TABLE li_constants INTO lwa_constants
                          WITH KEY criteria = lc_crit_fnam
                                   sel_low  = lwa_bdcdata-fnam
                                   active   = abap_true
                                   BINARY SEARCH.
  IF sy-subrc = 0.
* Check in Idoc data for Segment e1edk04
    READ TABLE didoc_data INTO lwa_edidd
                               WITH KEY segnam = lc_e1edk04.
    IF sy-subrc = 0 .
      lwa_e1edk04 = lwa_edidd-sdata.
      IF lwa_e1edk04-mwskz = lc_taxk1.
        CLEAR lwa_bdcdata.
        lwa_bdcdata-fnam = lc_vbak_taxk1.
        CONDENSE lwa_e1edk04-ktext NO-GAPS.
        lwa_bdcdata-fval = lwa_e1edk04-ktext.
        APPEND lwa_bdcdata TO dxbdcdata.
      ENDIF. " IF lwa_e1edk04-mwskz = lc_taxk1
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF sy-subrc = 0
ENDIF. " IF sy-subrc EQ 0
