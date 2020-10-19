************************************************************************
* PROGRAM    : ZOTCN0136O_SOITEM_CUSTOMFLDS                            *
* TITLE      : Custom Fields on Sales Document Header and Item         *
* DEVELOPER  : Rajendra K Panigrahy                                    *
* OBJECT TYPE: ENHANCEMENT                                             *
* SAP RELEASE: SAP ECC 6.0                                             *
*----------------------------------------------------------------------*
* WRICEF ID :  D2_OTC_EDD_0136                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: Custom Fields on Sales Document Header & Item           *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER    TRANSPORT   DESCRIPTION                         *
* =========== ======== =========== ====================================*
* 10-Oct-2014  RPANIGR E2DK900492  DEVELOPMENT FOR                     *
*                                  D2_OTC_EDD_0136/CR-134              *
* For Instrument Reference at SO item level                            *
* Line item referenced is rejected for an Instrument or a Service item *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&  Include           ZOTCN0136O_SOITEM_CUSTOMFLDS
*&---------------------------------------------------------------------*

************************************************************************
*============================Data Declaration==========================*
************************************************************************
* Types Declaration
TYPES: BEGIN OF lty_serlzd_mvgr1,
       sign TYPE tvarv_sign, " ABAP: ID: I/E (include/exclude values)
       opti TYPE tvarv_opti, " ABAP: Selection option (EQ/BT/CP/...)
       low  TYPE fpb_low,    " ABAP/4: Selection value (LOW or HIGH value, external format)
       high TYPE fpb_high,   " ABAP/4: Selection value (LOW or HIGH value, external format)
       END OF lty_serlzd_mvgr1.

* Data Declaration
DATA: lr_serlzd_mvgr1  TYPE STANDARD TABLE OF lty_serlzd_mvgr1 INITIAL SIZE 0, " Range table for Serialized material
      li_enh136_status TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0,  " Internal table
      lwa_serlzd_mvgr1 TYPE lty_serlzd_mvgr1.                                  " Workarea for Serialized material



* Field-symbol Declaration
FIELD-SYMBOLS: <lfs_enh136_status> TYPE zdev_enh_status, " Enhancement Status
               <lfs_vbap_old>      TYPE vbapvb,          " Document Structure for XVBAP/YVBAP
               <lfs_vbap_new>      TYPE vbapvb.          " Document Structure for XVBAP/YVBAP



* Constants Declaration
CONSTANTS: lc_enh_number   TYPE z_enhancement VALUE 'D2_OTC_EDD_0136', " Enhancement NUMBER
           lc_actv_status  TYPE z_criteria    VALUE 'NULL',            " Enh. Criteria
           lc_auart        TYPE z_criteria    VALUE 'AUART',           " Enh. Criteria
           lc_serlzd_mvgr1 TYPE z_criteria    VALUE 'SERLZED_MVGR1',   " Enh. Criteria
           lc_servc_mvgr1  TYPE z_criteria    VALUE 'SERVC_MVGR1',     " Enh. Criteria
           lc_i            TYPE tvarv_sign    VALUE 'I',               " ABAP: ID: I/E (include/exclude values)
           lc_eq           TYPE tvarv_opti    VALUE 'EQ',              " ABAP: Selection option (EQ/BT/CP/...)
           lc_bill_block   TYPE faksp_ap      VALUE '10'.              " Billing block for item


************************************************************************
*============================Processing Logic==========================*
************************************************************************
* Check Enh is active in EMI tool
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_enh_number
  TABLES
    tt_enh_status     = li_enh136_status.

* We select only the active entries.
DELETE li_enh136_status WHERE active = space.

* If enh is active in EMI Tool
IF li_enh136_status IS NOT INITIAL.

* Prepare Range table for MVGR1 values of serialized materials
  LOOP AT li_enh136_status ASSIGNING <lfs_enh136_status>.
    IF <lfs_enh136_status>-criteria = lc_serlzd_mvgr1.
      lwa_serlzd_mvgr1-sign = lc_i.
      lwa_serlzd_mvgr1-opti = lc_eq.
      lwa_serlzd_mvgr1-low  = <lfs_enh136_status>-sel_low.
      lwa_serlzd_mvgr1-high = space.
      APPEND lwa_serlzd_mvgr1 TO lr_serlzd_mvgr1.
    ENDIF. " IF <lfs_enh136_status>-criteria = lc_serlzd_mvgr1
  ENDLOOP. " LOOP AT li_enh136_status ASSIGNING <lfs_enh136_status>

*Get the active status from EMI tool
  READ TABLE li_enh136_status ASSIGNING <lfs_enh136_status>
                           WITH KEY criteria = lc_actv_status.
  IF sy-subrc = 0.

* If order type (ZOR or ZSTD) is found in EMI tool for this object
    READ TABLE li_enh136_status ASSIGNING <lfs_enh136_status>
                             WITH KEY criteria = lc_auart
                                      sel_low  = vbak-auart.
    IF sy-subrc = 0.

* If the line item which is changed(rejection reason is applied or removed) is an instrumnet line item
      IF vbap-serail <> space AND vbap-mvgr1 IN lr_serlzd_mvgr1.

* Read the old VBAP data to get the old Rejection reason value
        READ TABLE yvbap ASSIGNING <lfs_vbap_old> WITH KEY vbeln = vbap-vbeln
                                                           posnr = vbap-posnr.
        IF sy-subrc = 0.

* If old Rejection reason and new Rejection reason are not equal for an instrument line item
          IF vbap-abgru <> <lfs_vbap_old>-abgru.

* Loop at VBAP data to check the service line which is referenced with that instrument number...
* ...whose rejection reason is changed
            LOOP AT xvbap ASSIGNING <lfs_vbap_new>.
              IF <lfs_vbap_new>-zzlnref = vbap-posnr.
* If rejection reason is changed to 10 from blank, apply the same rejection value to the service line also
* And also clear the billing block if any, after applying the rejection reason
                IF vbap-abgru IS NOT INITIAL.
                  <lfs_vbap_new>-abgru = vbap-abgru.
                  IF <lfs_vbap_new>-faksp = lc_bill_block.
                    <lfs_vbap_new>-faksp = space.
                  ENDIF. " IF <lfs_vbap_new>-faksp = lc_bill_block

* If the rejection reason is removed from instrumnet then, also remove the rejection reason from the service line...
* ...and re-apply the billing block 10 to the service line, if not present
                ELSEIF vbap-abgru IS INITIAL.
                  <lfs_vbap_new>-abgru = vbap-abgru.
                  IF <lfs_vbap_new>-faksp = space.
                    <lfs_vbap_new>-faksp = lc_bill_block.
                  ENDIF. " IF <lfs_vbap_new>-faksp = space
                ENDIF. " IF vbap-abgru IS NOT INITIAL
              ENDIF. " IF <lfs_vbap_new>-zzlnref = vbap-posnr
            ENDLOOP. " LOOP AT xvbap ASSIGNING <lfs_vbap_new>

          ENDIF. " IF vbap-abgru <> <lfs_vbap_old>-abgru
        ENDIF. " IF sy-subrc = 0

* If the line item which is changed(rejection reason is applied or removed) is not an instrument (a service line item).
      ELSE. " ELSE -> IF <lfs_vbap_new>-faksp = space
        READ TABLE li_enh136_status ASSIGNING <lfs_enh136_status>
                             WITH KEY criteria = lc_servc_mvgr1
                                      sel_low  = vbap-mvgr1.
* If the line item is a Service line...
        IF sy-subrc = 0.

* Read the old VBAP data to get the old Rejection reason value
          READ TABLE yvbap ASSIGNING <lfs_vbap_old> WITH KEY vbeln = vbap-vbeln
                                                             posnr = vbap-posnr.
          IF sy-subrc = 0.
* If old Rejection reason and new Rejection reason are not equal for an instrument line item
            IF vbap-abgru IS NOT INITIAL AND vbap-abgru <> <lfs_vbap_old>-abgru.
              IF vbap-zzlnref IS NOT INITIAL.
* If the reference line item does not have a rejection reason,
                READ TABLE xvbap ASSIGNING <lfs_vbap_new> WITH KEY vbeln = vbap-vbeln
                                                                   posnr = vbap-zzlnref.
                IF sy-subrc = 0.
                  IF <lfs_vbap_new>-abgru IS INITIAL.
                    vbap-zzlnref = space.
                    vbap-faksp   = space.
                  ENDIF. " IF <lfs_vbap_new>-abgru IS INITIAL
                ENDIF. " IF sy-subrc = 0
              ENDIF. " IF vbap-zzlnref IS NOT INITIAL
            ENDIF. " IF vbap-abgru IS NOT INITIAL AND vbap-abgru <> <lfs_vbap_old>-abgru
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF vbap-serail <> space AND vbap-mvgr1 IN lr_serlzd_mvgr1
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF sy-subrc = 0
ENDIF. " IF li_enh136_status IS NOT INITIAL
