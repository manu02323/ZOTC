*&---------------------------------------------------------------------*
*&  Include           ZXVEDU15
*&---------------------------------------------------------------------*
***********************************************************************
*Program    : ZXVEDU15(User exit include)                             *
*Title      : Customer Order acknowledgement - EDI                    *
*Developer  : Mini Duggal/Dhananjoy                                   *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0010                                           *
*---------------------------------------------------------------------*
*Description: This user exit include is called from customer FM       *
*EXIT_SAPLVEDC_003. The IDoc triggerred in Order confirmation using   *
* Z855 output type has incorrect Vendor. This vendor has to be        *
*populated from the IDoc which was send by EDI partner in sales order *
*creation inbound IDoc.                                               *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*26-May-2014  MDUGGAL       E2DK900755     Initial Development
*---------------------------------------------------------------------*



DATA: lv_vbeln          TYPE vbeln_va,                          " Sales Document
      lwa_e1edka1       TYPE e1edka1,                           " IDoc: Document Header Partner Information
      lv_lifnr          TYPE lifnr_ed1,                         " Vendor Account Number
      lv_proceed        TYPE flag,                              " Flag to check to proceed further or not
      lv_index          TYPE sytabix,                           " Index of Internal Tables
      li_status         TYPE STANDARD TABLE OF zdev_enh_status. "Enhancement Status table


CONSTANTS: lc_ship_to_we              TYPE edi3035_a        VALUE 'WE',                  " Partner function (e.g. sold-to party, ship-to party, ...)
           lc_partner_seg_e1edka1     TYPE edi_segnam       VALUE 'E1EDKA1',             " Name of SAP segment
           lc_idd_0010_001            TYPE z_enhancement    VALUE 'D2_OTC_IDD_0010_001', " Enhancement No.
           lc_null                    TYPE z_criteria       VALUE 'NULL'.                " Enh. Criteria


FIELD-SYMBOLS: <lfs_edidd>    TYPE edidd. " Data record (IDoc)

* Call to EMI Function Module To Get List Of EMI Statuses
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_idd_0010_001 "D2_OTC_IDD_0010_001
  TABLES
    tt_enh_status     = li_status.      "Enhancement status table


*first thing is to check for field criterion,for value “NULL” and field Active value:
*i.If the value is: “X”, the overall Enhancement is active and can proceed further for checks
*ii.If the  value is:space, then do not proceed further for this enhancement

READ TABLE li_status WITH KEY criteria = lc_null "NULL
                              active = abap_true "X"
                     TRANSPORTING NO FIELDS.
IF sy-subrc EQ  0.

* below logic is to be tiggerred only when outbound IDoc has segment E1EDKA1 with
* Ship-to Party (WE).

* Binary search can't be used as input IT dint_edidd can't be sorted.

  READ TABLE dint_edidd  ASSIGNING <lfs_edidd> WITH KEY segnam = lc_partner_seg_e1edka1.


  IF sy-subrc = 0.
    lv_index = sy-tabix.

    IF <lfs_edidd> IS ASSIGNED.
      UNASSIGN <lfs_edidd>.
    ENDIF. " IF <lfs_edidd> IS ASSIGNED


    LOOP AT dint_edidd ASSIGNING <lfs_edidd> FROM lv_index.
      IF <lfs_edidd>-segnam NE lc_partner_seg_e1edka1.
        EXIT.
      ENDIF. " IF <lfs_edidd>-segnam NE lc_partner_seg_e1edka1

      CLEAR lwa_e1edka1.
      lwa_e1edka1 = <lfs_edidd>-sdata.
* once E1EDKA1 with WE partner type is found set the flag and exit from loop
      IF lwa_e1edka1-parvw EQ lc_ship_to_we.
        lv_proceed = abap_true.
        EXIT.
      ELSE. " ELSE -> IF lwa_e1edka1-parvw EQ lc_ship_to_we

        CONTINUE.
      ENDIF. " IF lwa_e1edka1-parvw EQ lc_ship_to_we

    ENDLOOP. " LOOP AT dint_edidd ASSIGNING <lfs_edidd> FROM lv_index

    IF lv_proceed = abap_true.
      lv_vbeln = dorder_number.
* Fetch the Vendor number which was passed by EDI partner in Inbound IDoc

      CALL FUNCTION 'ZOTC_0011_SD_GET_LIFNR'
        EXPORTING
          im_belnr = lv_vbeln
        IMPORTING
          ex_lifnr = lv_lifnr.

      IF lv_lifnr IS NOT INITIAL.

* use the field symbol which was found in segment search of E1EDKA1 WE partner type search
        IF <lfs_edidd> IS ASSIGNED.
          lwa_e1edka1-lifnr = lv_lifnr.
          <lfs_edidd>-sdata = lwa_e1edka1.
        ENDIF. " IF <lfs_edidd> IS ASSIGNED
* Begin Defect 2794
*Clear E1EDKA1-LIFNR if LV_LIFNR is blank
      ELSE. " ELSE -> IF <lfs_edidd> IS ASSIGNED
        IF <lfs_edidd> IS ASSIGNED.
          CLEAR lwa_e1edka1-lifnr.
          <lfs_edidd>-sdata = lwa_e1edka1.
        ENDIF. " IF <lfs_edidd> IS ASSIGNED
* End Defect 2794
      ENDIF. " IF lv_lifnr IS NOT INITIAL
    ENDIF. " IF lv_proceed = abap_true
  ENDIF. " IF sy-subrc = 0
ENDIF. " IF sy-subrc EQ 0

***********************************************************************
*Program    : ZXVEDU15(User exit include)                             *
*Title      : SAP Order Acknowledgement To ServiceMax                 *
*Developer  : Geetanjali Bajpai                                       *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0094                                           *
*---------------------------------------------------------------------*
*Description: For ZSMX Output type,items that have MVGR1 values of    *
*002/003 are only passed,others are deleted. For relevant items an    *
*additional E1EDP02 segment is added below E1EDP01 segment.           *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*26-May-2014  GBAJPAI       E2DK900755     Initial Development
*---------------------------------------------------------------------*

INCLUDE zotcn0094b_ordack_to_servmax. " Include for 0094 code lines
