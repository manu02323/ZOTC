*&---------------------------------------------------------------------*
*&  Include           ZXVVFU04
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZXVVFU04                                               *
* TITLE      :  Revaluation due to new Budget Standard Cost            *
* DEVELOPER  :  Sneha Ghosh                                            *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   OTC_EDD_0103_Revaluation due to new Budget Standard Cost*
*----------------------------------------------------------------------*
* DESCRIPTION:  Revaluation due to new Budget Standard Cost            *
*                                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
*27-NOV-2013  SGHOSH    E1DK912332   INITIAL DEVELOPMENT - CR#781      *
*&---------------------------------------------------------------------*
*22-NOV-2016  SAGARWA1  E1DK923816   D3_OTC_EDD_0366 - PCR#244         *
*                                    re-determination of assignment    *
*                                    field value in billing accounting *
*                                    document.                         *
*&---------------------------------------------------------------------*

FIELD-SYMBOLS: <lfs_zotc_pctrl> TYPE ty_zotc_pctrl. "Field-Symbol for itab of ZOTC_PRC_CONTROL
CONSTANTS: lc_x TYPE z_mvalue_low VALUE 'X',                 "X
           lc_prog TYPE programm VALUE 'ZXVVFU04',           "ZXVVFU04
           lc_eq TYPE rmsae_option VALUE 'EQ',               "EQ
           lc_check TYPE enhee_parameter VALUE 'CHECK',      "CHECK
           lc_vgtyp TYPE enhee_parameter VALUE 'VBRP-VGTYP'. "VBRP-VGTYP

*& --> Begin of Insert for D3_OTC_EDD_0366 by SAGARWA1 on 22-Nov-2016

DATA: lv_hkont TYPE hkont. " General Ledger Account
STATICS li_status TYPE  TABLE OF zdev_enh_status . " Enhancement Status
CONSTANTS : lc_enhancement TYPE z_enhancement VALUE 'OTC_EDD_0366',        " Enhancement No.
            lc_criteria    TYPE z_criteria    VALUE 'CLEARING_GL_ACCOUNT', " Enh. Criteria
            lc_d           TYPE rr_reltyp     VALUE 'D',                   " Revenue recognition category
            lc_null        TYPE z_criteria    VALUE 'NULL'.                " Enh. Criteria
*& <-- End of Insert for D3_OTC_EDD_0366 by SAGARWA1 on 22-Nov-2016

*&--If a new document then only Actual Goods Movement Date will be fetched.
IF gv_vgbel <> xvbrp-vgbel.
  CLEAR: gv_wadat_ist,
         gv_vgbel.
  REFRESH i_zotc_pctrl[].

  SELECT mparameter       "Parameter
         mvalue1          "Value-low
    FROM zotc_prc_control " OTC Process Team Control Table
    INTO TABLE i_zotc_pctrl
    WHERE vkorg = vbrk-vkorg
      AND vtweg = vbrk-vtweg
      AND mprogram = lc_prog
      AND mactive = lc_x
      AND soption = lc_eq.

  IF sy-subrc IS INITIAL.
    SORT i_zotc_pctrl BY mparameter.

*&&-- Check 1
    READ TABLE i_zotc_pctrl ASSIGNING <lfs_zotc_pctrl>
                            WITH KEY mparameter = lc_check.
*&&-- No BINARY SEARCH is required for ONLY 3 items
    IF sy-subrc IS INITIAL AND
        <lfs_zotc_pctrl>-mvalue1 EQ lc_x.

*&&-- Check 2
      READ TABLE i_zotc_pctrl ASSIGNING <lfs_zotc_pctrl>
                              WITH KEY mparameter = lc_vgtyp
                                       mvalue1 = xvbrp-vgtyp.
*&&-- No BINARY SEARCH is required for ONLY 3 items
      IF sy-subrc IS INITIAL.

        SELECT SINGLE wadat_ist "Actual Goods Movement Date
          FROM likp             " SD Document: Delivery Header Data
          INTO gv_wadat_ist
          WHERE vbeln = xvbrp-vgbel.
        IF sy-subrc IS INITIAL.
          gv_vgbel = xvbrp-vgbel.
          xaccit-fbuda = gv_wadat_ist.
        ENDIF. " IF sy-subrc IS INITIAL

      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL AND
  ENDIF. " IF sy-subrc IS INITIAL

ELSE. " ELSE -> IF gv_vgbel <> xvbrp-vgbel
  gv_vgbel = xvbrp-vgbel.
  xaccit-fbuda = gv_wadat_ist.
ENDIF. " IF gv_vgbel <> xvbrp-vgbel


*& --> Begin of Insert for D3_OTC_EDD_0366 by SAGARWA1 on 22-Nov-2016

*** This enhancement is used for re-determination of assignment field
*** value in billing accounting document

* Select EMI entries only if the table is initial.
* Table is declared as static table for Perf. as the exit is called many times

** Get the EMI entry for deferred revenue account info
*IF li_status IS NOT INITIAL.
IF li_status IS INITIAL.
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enhancement
    TABLES
      tt_enh_status     = li_status.
ENDIF. " IF li_status IS NOT INITIAL

DELETE li_status WHERE active IS INITIAL.

IF li_status[] IS NOT INITIAL.
  SORT li_status BY criteria .

* Check EMI activated or not " Binary search is not required as we have limited entries
  READ TABLE  li_status
              WITH KEY criteria =  lc_null
                       active = abap_true
                       TRANSPORTING NO FIELDS.

  IF sy-subrc IS INITIAL.
    CLEAR lv_hkont.
    lv_hkont = xaccit-hkont.

* Converting HKONT without zeros to check with EMI entries
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = lv_hkont
      IMPORTING
        output = lv_hkont.

*Binary search is not used as it is a small table
 " Check if CLEARING_GL_ACCOUNT is maintained in EMI table
    READ TABLE li_status WITH KEY criteria = lc_criteria
                                  sel_low  = lv_hkont
                                  TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      IF xvbrp-rrrel = lc_d.
* If the revenue recognition category is D then assignment field should be populated
* with billing document number and item number.
        CONCATENATE vbrk-vbeln xvbrp-posnr  INTO xaccit-zuonr.
      ELSE. " ELSE -> IF xvbrp-rrrel = lc_d
* If the revenue recognition category is not D then assignment field should be populated
* with sales order number and item number.
        CONCATENATE xvbrp-aubel xvbrp-aupos INTO xaccit-zuonr.
      ENDIF. " IF xvbrp-rrrel = lc_d
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF sy-subrc IS INITIAL
ENDIF. " IF li_status[] IS NOT INITIAL

*& --> End of Insert for D3_OTC_EDD_0366 by SAGARWA1 on 22-Nov-2016
