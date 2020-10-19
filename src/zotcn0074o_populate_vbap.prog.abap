************************************************************************
* PROGRAM    :  ZOTCN0074O_POPULATE_VBAP(Include)                      *
* TITLE      :  Sales Rep Cost Center Assignment                       *
* DEVELOPER  :  Suman K Pandit                                         *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   CR192(OTC_EDD_0074)                                     *
*----------------------------------------------------------------------*
* DESCRIPTION: Population of VBAP LPRIO from Ship-To customer record.
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 01-NOV-2012  SPANDIT E1DK907442  INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 24-DEC-2015 SAGARWA1 E2DK916565  Defect#1345: Change for check item  *
*                                  creation before setting the flag to *
*                                  update Delivery Priority.           *
*&---------------------------------------------------------------------*

* Local types
  TYPES: BEGIN OF lty_auart,
           mvalue1 TYPE z_mvalue_low,     "Select Options: Value Low
         END OF lty_auart,

         BEGIN OF lty_ivbap,
           posnr TYPE posnr,              "Item no
           tabix TYPE sytabix,            "Index
           selkz TYPE char1,              "Indicator
         END OF lty_ivbap,

         lty_t_auart TYPE STANDARD TABLE OF lty_auart,
         lty_r_auart TYPE RANGE OF auart, " Sales Document Type
         lty_auart_r TYPE LINE OF lty_r_auart.

* Local constants
  CONSTANTS:lc_prog_name        TYPE char50       VALUE 'EDD0074',    "Program Name
            lc_fld_name         TYPE char50       VALUE 'VBAK-AUART', "Field Name
            lc_sign_i           TYPE char1        VALUE 'I',          "Inclusive
            lc_option_eq        TYPE char2        VALUE 'EQ',         "Option
            lc_active           TYPE char1        VALUE 'X',          "Active
            lc_trtyp_v          TYPE trtyp        VALUE 'V',          "Creation mode
            lc_trtyp_h          TYPE trtyp        VALUE 'H',          "Change Mode
*& --> Begin of Insert for Defect#1345 by SAGARWA1
            lc_insert           TYPE updkz        VALUE 'I'. " Insert a new line item
*& --> End of Insert for Defect#1345 by SAGARWA1

* Local data declaration
  DATA: lr_auart TYPE lty_r_auart,    "Range table of order type
        lwa_auart_r TYPE lty_auart_r, "Workarea for Order type
        li_auart TYPE lty_t_auart,    "Int Table for Order type
        lv_flag TYPE char1.           "Flag

* Local field symbols
  FIELD-SYMBOLS: <lfs_auart> TYPE lty_auart,
                 <lfs_ivbap> TYPE lty_ivbap.

* Flag should be active for the first time or if Ship-to-Party is updated
* IVBAP populated and SVBAP blank means data getting populated for 1st time
  READ TABLE ivbap[] ASSIGNING <lfs_ivbap>
    WITH KEY posnr = vbap-posnr.
  IF sy-subrc IS INITIAL.
    READ TABLE svbap[] TRANSPORTING NO FIELDS
    WITH KEY tabix = <lfs_ivbap>-tabix.
    IF sy-subrc IS NOT INITIAL.
*& --> Begin of Insert for Defect#1345 by SAGARWA1
**** If a new line item is inserted into sales order then only set the flag.
      IF xvbap-updkz = lc_insert. "'I'
*& --> End of Insert for Defect#1345 by SAGARWA1
        lv_flag = lc_active.
      ENDIF. " IF sy-subrc IS NOT INITIAL   " Defect # 1345
    ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL
*      Ship-to-party is updated
      IF xvbak-weupda = lc_active.
        lv_flag = lc_active.
      ENDIF. " IF xvbak-weupda = lc_active
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF.

  IF lv_flag = lc_active.

*   If transaction is in creation/change mode
    IF t180-trtyp = lc_trtyp_v OR
       t180-trtyp = lc_trtyp_h.

*     Get order types from OTC Control table
      SELECT mvalue1           " Select Options: Value Low
        FROM  zotc_prc_control " OTC Process Team Control Table
        INTO  TABLE li_auart
        WHERE vkorg      = vbak-vkorg   AND
              vtweg      = vbak-vtweg   AND
              mprogram   = lc_prog_name  AND
              mparameter = lc_fld_name   AND
              mactive    = lc_active     AND
              soption    = lc_option_eq.
      IF sy-subrc IS INITIAL.

        LOOP AT li_auart ASSIGNING <lfs_auart>.
          lwa_auart_r-sign = lc_sign_i.
          lwa_auart_r-option = lc_option_eq.
          lwa_auart_r-low = <lfs_auart>-mvalue1.
          APPEND lwa_auart_r TO lr_auart.
        ENDLOOP. " LOOP AT li_auart ASSIGNING <lfs_auart>

*       If Order type matches, then update delivery priority
        IF vbak-auart IN lr_auart AND lr_auart IS NOT INITIAL.
          vbap-lprio = kuwev-zzlprio.
        ENDIF. " IF vbak-auart IN lr_auart AND lr_auart IS NOT INITIAL
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF t180-trtyp = lc_trtyp_v OR
  ENDIF. " IF lv_flag = lc_active
