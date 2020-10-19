*&---------------------------------------------------------------------*
*&  Include           ZOTCN0221O_SALES_ORD_ENH
*&---------------------------------------------------------------------*
*Local Data declaration
DATA: li_enh_status     TYPE STANDARD TABLE OF  zdev_enh_status, " Internal table for Enhancement Status
      lwa_xvbap         TYPE VBAPVB.
*Local constant declaration
CONSTANTS:
           lc_auth TYPE char10 VALUE 'ZOTC_0221',                     " Auth of type CHAR10
           lc_error TYPE char1 VALUE 'E',                             " Error of type CHAR1
           lc_enhancement_no TYPE z_enhancement VALUE 'OTC_EDD_0221', " Enhancement No.
           lc_null_221      TYPE z_criteria    VALUE 'NULL',          " Enh. Criteria
           lc_polo TYPE fcode VALUE 'POLO',                           " Function Code
           lc_loes TYPE fcode VALUE 'LOES'.                           " Function Code

*Get constant values from the EMI table
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_enhancement_no
  TABLES
    tt_enh_status     = li_enh_status.
DELETE li_enh_status WHERE active = abap_false.
READ TABLE li_enh_status WITH KEY criteria = lc_null_221
                                 TRANSPORTING NO FIELDS.
IF sy-subrc EQ 0.
  IF VBAK-VBTYP EQ 'C'.
    read table xvbap into lwa_xvbap with key posnr = vbap-posnr binary search.
    if sy-subrc eq 0.
   if lwa_xvbap-updkz ne 'I'.
    IF fcode = lc_polo OR fcode = lc_loes.
* Authorization check for delete
      AUTHORITY-CHECK OBJECT lc_auth
      ID 'ACTVT' FIELD '06'.
*If not authorized to delete then display error message
      IF sy-subrc NE 0.
        MESSAGE s805(zotc_msg) DISPLAY LIKE lc_error. " Sales order and existing line item numbers cannot be deleted
        IF us_error = abap_true.
*This flag will not allow item to delete
          us_exit = abap_true.
           ENDIF. " IF us_error = abap_true
         ENDIF. " IF sy-subrc NE 0
       ENDIF. " IF fcode = lc_polo OR fcode = lc_loes
     ENDIF. "
   ENDIF.
  ENDIF.
ENDIF. " IF sy-subrc EQ 0
