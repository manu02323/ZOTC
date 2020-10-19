**********************************************************************
*Program    : ZOTCN00190_ORDRSP                                       *
*Title      : Include for stopping incomplete orders                  *
*Developer  : Debarun Paul                                            *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_EDD_0019                                           *
*---------------------------------------------------------------------*
*Description: Incomplete orders will not trigger idoc                 *
*                                                                     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*26-AUG-2016  PDEBARU       E2DK918598     Defect # 1816 : Order      *
*                                          Acknowledgement Output     *
*                                          control for ServiceMax     *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZOTCN00190_ORDRSP
*&---------------------------------------------------------------------*

TYPES : BEGIN OF lty_vbup,
          vbeln TYPE vbeln,    " Sales and Distribution Document Number
          posnr TYPE posnr,    " Item number of the SD document
          uvall TYPE uvall_up, " General Incompletion Status of Item
       END OF lty_vbup.

CONSTANTS : lc_uvall TYPE char1 VALUE 'C',                 " Uvall of type CHAR1
            lc_rcvprn TYPE edi_rcvprn  VALUE 'SERVICEMAX'. " Partner Number of Receiver

DATA : li_vbap TYPE STANDARD TABLE OF vbap INITIAL SIZE 0,     " Sales Document: Item Data
       li_vbap1 TYPE STANDARD TABLE OF vbap INITIAL SIZE 0,    " Sales Document: Item Data
       li_vbup TYPE STANDARD TABLE OF lty_vbup INITIAL SIZE 0, " Sales Document: Item Status
       lwa_vbap TYPE vbap,                                     " Sales Document: Item Data
       lwa_vbup TYPE lty_vbup.

* This should be clled only when SMAX output is triggered.
IF control_record_out-rcvprn = lc_rcvprn.

  li_vbap[] = dxvbap[].

  IF li_vbap[] IS NOT INITIAL.

    SELECT vbeln " Sales and Distribution Document Number
           posnr " Item number of the SD document
           uvall " General Incompletion Status of Item
      INTO TABLE li_vbup
      FROM vbup  " Sales Document: Item Status
      FOR ALL ENTRIES IN li_vbap
      WHERE vbeln = li_vbap-vbeln
      AND posnr = li_vbap-posnr.
    IF sy-subrc = 0.
      SORT li_vbup BY vbeln posnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_vbap[] IS NOT INITIAL

* Figure out the item which are incomplete
  LOOP AT li_vbap INTO lwa_vbap.
    READ TABLE li_vbup INTO lwa_vbup
                WITH KEY vbeln = lwa_vbap-vbeln
                         posnr = lwa_vbap-posnr
                  BINARY SEARCH.
    IF sy-subrc = 0.
* EMI entry not maintained as this value will be constant
      IF lwa_vbup-uvall = lc_uvall.
        APPEND lwa_vbap TO li_vbap1.
      ENDIF. " IF lwa_vbup-uvall = lc_uvall
    ENDIF. " IF sy-subrc = 0
    CLEAR : lwa_vbap , lwa_vbup.
  ENDLOOP. " LOOP AT li_vbap INTO lwa_vbap

* Ignore all Incomplete lines

  dxvbap[] = li_vbap1[].
ENDIF. " IF control_record_out-rcvprn = lc_rcvprn
