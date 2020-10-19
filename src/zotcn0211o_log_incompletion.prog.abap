*&---------------------------------------------------------------------*
*&  Include           ZOTCN0211O_LOG_INCOMPLETION
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0211O_LOG_INCOMPLETION                            *
* TITLE      :  User Exit for Incompletion Log                         *
* DEVELOPER  :  Bhargav Gundabolu                                      *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 7.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D3_OTC_EDD_0211                                          *
*----------------------------------------------------------------------*
* DESCRIPTION:  User Exit for Incompletion Log                         *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 10-NOV-2017 BGUNDAB  E1DK932391 SCTASK0519256/DFT#4032 Prevent       *
*                                 delivery creation if batch not       *
*                                 determined in sales order            *
* 16-Nov-2017 BGUNDAB E1DK932562  SCTASK0519256/DFT#4032 Binary Search *
*                                 issue on xvbuvhas been fixed         *
* 06-Apr-2018 BGUNDAB E1DK932562  DFT#5632 Check o include whether     *
*                                 line item delivered                  *
* 01-May-2018 DARUMUG E1DK936351  Defect#5911 Sort the EMI Status table*
* 02-Aug-2018 DARUMUG E1DK938090  Defect#6756 Incompletion log for     *
*                                  batch not cleared if confirmed      *
*                                  quantities are removed              *
*23-SEP-2019 U105993  E2DK926716  INC0505510-02 Defect#10251:          *
*                                 Added Incompletion log for Batch     *
*&---------------------------------------------------------------------*
DATA:
  lwa_emi_status        TYPE zdev_enh_status,                   " Enhancement Status
  li_emi_status         TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
  lv_salesorg           TYPE vkorg,                             " Sales Organization
  lv_dc                 TYPE vtweg,                             " Distribution Channel
*Begin of change 5632 by mthatha
  li_xvbup              TYPE STANDARD TABLE OF vbupvb, " Reference Structure for XVBUP/YVBUP
*End of change 5632 by mthatha
*Begin of change 4032 by bgundab on Nov-16
  li_xvbuv              TYPE STANDARD TABLE OF vbuvvb, " Structure for Internal Table XVBUV
*End of change 4032 by bgundab on Nov-16
* Begin of changes for INC0505510-02 defect# 10251 by u105993 on 23-SEP-2019
  lv_mara               TYPE matnr.
* End of changes for INC0505510-02 defect# 10251 by u105993 on 23-SEP-2019
CONSTANTS:
  lc_emi_edd_0211       TYPE z_enhancement VALUE 'D3_OTC_EDD_0211', " Enhancement No.
  lc_null_enh           TYPE z_criteria    VALUE 'NULL',            " Enh. Criteria
  lc_salesorg           TYPE char10        VALUE 'VKORG_CH',        " VKORG
  lc_dc                 TYPE char10        VALUE 'VTWEG',           " VTWEG
  lc_matgrp2            TYPE char10        VALUE 'MVGR1_GRP2',      " Matgrp2 of type CHAR10
  lc_fehgr              TYPE char10        VALUE 'FEHGR',           " Fehgr of type CHAR10
  lc_statg              TYPE char10        VALUE 'STATG',           " Statg of type CHAR10
  lc_tbnam              TYPE char10        VALUE 'VBAP',            " Tbnam of type CHAR10
  lc_fdnam              TYPE char10        VALUE 'CHARG',           " Fdnam of type CHAR10
  lc_fcode              TYPE char10        VALUE 'PKAU',            " Fcode of type CHAR10
  lc_updkz              TYPE char1         VALUE 'I',               " Updkz of type CHAR1
  lc_doc_cat            TYPE z_criteria    VALUE 'VBTYP',           " Enh. Criteria
  lc_etenr              TYPE char10        VALUE '0000',            " Etenr of type CHAR10
  lc_doctyp             TYPE z_criteria    VALUE 'AUART'.           " Enh. Criteria of type AUART

* Get all EMI entries for this project
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_emi_edd_0211
  TABLES
    tt_enh_status     = li_emi_status.
SORT li_emi_status BY criteria sel_low sel_high active. "Defect# 5911

* Begin of changes for INC0505510-02 defect# 10251 by u105993 on 23-SEP-2019
*  Fetch Batch Mgmt Rqt from MARA
* SELECT SINGLE xchpf " Batch Mgmt Rqt
*        FROM mara    " General Material Data
*        INTO lv_mara
*        WHERE matnr = xvbap-matnr.
*   IF lv_mara = abap_true.
**     "Check if the material/line is non-batch managed if no then proceed further
*      IF xvbap-charg IS INITIAL.
**     " Update xvbuv strcuture with the incompletion log for batch
*          xvbuv-vbeln  = xvbap-vbeln.
*          xvbuv-posnr  = xvbap-posnr.
*          xvbuv-tbnam  = lc_tbnam." VBAP
*          xvbuv-fdnam  = lc_fdnam." CHARG
*          xvbuv-etenr  = lc_etenr." 0000
**
*          READ TABLE li_emi_status INTO lwa_emi_status
*                                   WITH KEY criteria = lc_fehgr
*                                   BINARY SEARCH.
*          IF sy-subrc EQ 0.
*            xvbuv-fehgr = lwa_emi_status-sel_high.
*          ENDIF. " IF sy-subrc EQ 0
*          READ TABLE li_emi_status INTO lwa_emi_status
*                                   WITH KEY criteria = lc_statg
*                                   BINARY SEARCH.
*          IF sy-subrc EQ 0.
*            xvbuv-statg = lwa_emi_status-sel_high.
*            xvbuv-fcode = lc_fcode. "PKAU
*            xvbuv-updkz = lc_updkz.
*          ENDIF. " IF sy-subrc EQ 0
**
** "Append the Batch and line info to the incompletion log
*           APPEND xvbuv.
*        ENDIF." IF lv_mara = abap_true.
*   ENDIF." IF lv_mara = abap_true.
** End of changes for INC0505510-02 defect# 10251 by u105993 on 23-SEP-2019

"Check whether the enhancement is Active
READ TABLE li_emi_status WITH KEY
                         criteria = lc_null_enh
                         active = abap_true
                         BINARY SEARCH
                         TRANSPORTING NO FIELDS.
IF sy-subrc EQ 0.
 "Read VBAK to check document category VBTYP is present in EMI.
  READ TABLE li_emi_status WITH KEY
                           criteria = lc_doc_cat
                           sel_low  = vbak-vbtyp
                           active   = abap_true
                           BINARY SEARCH
                           TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
    READ TABLE li_emi_status WITH KEY
                         criteria = lc_doctyp
                         sel_low  = vbak-auart
                         active   = abap_true
                         BINARY SEARCH
                         TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
 "Check if the material/line is batch managed if yes then proceed further
      IF xvbap-xchpf = abap_true.
 "Check if the material/line is delivery revelant if yes then proceed further
        SELECT SINGLE mandt INTO sy-mandt FROM tvlp WHERE pstyv = xvbap-pstyv.
        IF sy-subrc = 0.

 "Check if the line item/schedule line has confirmed quanity if yes then proceed further
          LOOP AT xvbep TRANSPORTING NO FIELDS WHERE posnr = vbap-posnr AND
                                                     bmeng NE '0'
*--> Begin of Change for Defect#6756 on 02-Aug-2018
                                                 AND updkz NE 'D'.
*<-- End of Change for Defect#6756 on 02-Aug-2018

*Begin of change 5632 by mthatha
            READ TABLE xvbup TRANSPORTING NO FIELDS WITH KEY  posnr = vbap-posnr
                                                          lfgsa = 'B'.
            IF sy-subrc NE 0.
              READ TABLE xvbup TRANSPORTING NO FIELDS WITH KEY  posnr = vbap-posnr
                                                lfgsa = 'C'.
              IF sy-subrc NE 0.
*End of change 5632 by mthatha
 "Check if the line item has Batch assigned to it if yes exit otherwise move forward.
                IF xvbap-charg IS INITIAL.
*            "Check Material Group 2
                  READ TABLE li_emi_status WITH KEY
                                     criteria = lc_matgrp2
                                     sel_high = xvbap-mvgr2
                                     BINARY SEARCH
                                     TRANSPORTING NO FIELDS.
                  IF sy-subrc EQ 0.
 " Update xvbuv strcuture with the incompletion log for batch
                    xvbuv-vbeln  = xvbap-vbeln.
                    xvbuv-posnr  = xvbap-posnr.
                    xvbuv-tbnam  = lc_tbnam.
                    xvbuv-fdnam  = lc_fdnam.
                    xvbuv-etenr  = lc_etenr.
                    READ TABLE li_emi_status INTO lwa_emi_status
                                             WITH KEY criteria = lc_fehgr
                                             BINARY SEARCH.
                    IF sy-subrc EQ 0.
                      xvbuv-fehgr = lwa_emi_status-sel_high.
                    ENDIF. " IF sy-subrc EQ 0
                    READ TABLE li_emi_status INTO lwa_emi_status
                                             WITH KEY criteria = lc_statg
                                             BINARY SEARCH.
                    IF sy-subrc EQ 0.
                      xvbuv-statg = lwa_emi_status-sel_high.
                      xvbuv-fcode = lc_fcode.
                      xvbuv-updkz = lc_updkz.
                    ENDIF. " IF sy-subrc EQ 0
*Begin of change 4032 by bgundab on Nov-16, read is now performed on the new sorted internal table
                    li_xvbuv[] = xvbuv[].
                    SORT li_xvbuv BY vbeln posnr tbnam fdnam.
 "Check if incompletion log exists already
                    READ TABLE li_xvbuv WITH KEY  vbeln  = xvbap-vbeln
                                                  posnr  = xvbap-posnr
                                                  tbnam  = lc_tbnam
                                                  fdnam  = lc_fdnam
                                                  BINARY SEARCH
                                                  TRANSPORTING NO FIELDS.
*End of change 4032 by bgundab on Nov-16
                    IF sy-subrc NE 0.
 "Append the Batch and line info to the incompletion log
                      APPEND xvbuv.
                    ENDIF. " IF sy-subrc NE 0
*Begin of change 4032 by bgundab on Nov-16, read is now performed on the new sorted internal table
                    CLEAR li_xvbuv.
*End of change 4032 by bgundab on Nov-16, read is now performed on the new sorted internal table
                  ENDIF. " IF sy-subrc EQ 0
                ENDIF. " IF xvbap-charg IS INITIAL
*Begin of change 5632 by mthatha
              ENDIF. " IF sy-subrc NE 0
            ENDIF. " IF sy-subrc NE 0
*End of change 5632 by mthatha
          ENDLOOP. " LOOP AT xvbep TRANSPORTING NO FIELDS WHERE posnr = vbap-posnr AND
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF xvbap-xchpf = abap_true
    ENDIF. " IF sy-subrc NE 0
  ENDIF. " IF sy-subrc EQ 0
ENDIF. " IF sy-subrc EQ 0
