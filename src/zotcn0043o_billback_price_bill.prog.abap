************************************************************************
* PROGRAM    :  ZOTCN0043O_BILLBACK_PRICE_ITEM (Include)               *
* TITLE      :  Billback Enhancement for Pricing structure update in
*               Item level                                             *
* DEVELOPER  :  ANANYA DAS                                             *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0043                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Population of custom fields in Pricing structure in item
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 11-FEB-2013  ADAS1   E1DK909221 D#2743:Populate pricing at Item level
*&---------------------------------------------------------------------*
*======================================================================*
* 20-June-2014 PMISHRA E2DK901708 D2_OTC_EDD_0134 - Pass the values of *
*                                 MAAPV and XVBRP to the FM            *
*&---------------------------------------------------------------------*
* 10-Mar-2016 ASK E2DK915355 D2_OTC_EDD_0134 Defect #1424 - Fill up    *
*                                          ZZKCMENG field from LIPS    *
*&---------------------------------------------------------------------*
* 24-Oct-2017  SMUKHER4 E1DK931954 D3_OTC_EDD_0134 Defect# 3696:       *
*                                  Issue with the invoice for debit/   *
*                                  credit notes.                       *
*&---------------------------------------------------------------------*

DATA: li_vbap TYPE va_vbapvb_t,
      wa_vbap LIKE LINE OF li_vbap.

DATA: li_sales_det TYPE STANDARD TABLE OF vbap, " Sales Document: Item Data
      wa_sales_det LIKE LINE OF li_sales_det.

DATA wa_avbap LIKE LINE OF avbap.

* Begin of Defect 1424
DATA: li_lips TYPE va_lipsvb_t,
      wa_lips TYPE lipsvb,                      " Reference structure for XLIPS/YLIPS

      li_deliv_det TYPE STANDARD TABLE OF lips, " SD document: Delivery: Item data
      wa_deliv_det TYPE lips,                   " SD document: Delivery: Item data

      wa_alips LIKE LINE OF alips  .
* End   of Defect 1424

REFRESH li_vbap.
LOOP AT avbap INTO wa_avbap.
  MOVE-CORRESPONDING wa_avbap TO wa_vbap.
  APPEND wa_vbap TO li_vbap.
ENDLOOP. " LOOP AT avbap INTO wa_avbap

READ TABLE li_vbap WITH KEY vbeln = xvbrp-aubel " Defect 1424
                   TRANSPORTING NO FIELDS.      " Defect 1424
IF sy-subrc NE 0. " Defect 1424
*  if li_vbap is initial.    " Defect 1424
  REFRESH : li_sales_det, li_vbap.
  SELECT *
    INTO TABLE li_sales_det
    FROM vbap " Sales Document: Item Data
    WHERE vbeln = xvbrp-aubel.
  IF sy-subrc = 0.
    LOOP AT li_sales_det INTO wa_sales_det.
      MOVE-CORRESPONDING wa_sales_det TO wa_vbap.
      APPEND wa_vbap TO li_vbap.
    ENDLOOP. " LOOP AT li_sales_det INTO wa_sales_det
  ENDIF. " IF sy-subrc = 0
ENDIF. " IF sy-subrc NE 0

* Begin of Defect 1424
REFRESH li_lips.
LOOP AT alips INTO wa_alips.
  MOVE-CORRESPONDING wa_alips TO wa_lips.
  APPEND wa_lips TO li_lips.
ENDLOOP. " LOOP AT alips INTO wa_alips

READ TABLE li_lips WITH KEY vbeln = xvbrp-vgbel
                   TRANSPORTING NO FIELDS.
IF sy-subrc NE 0.

  REFRESH: li_deliv_det, li_lips.
  SELECT *
    INTO TABLE li_deliv_det
    FROM lips " SD document: Delivery: Item data
    WHERE vbeln = xvbrp-vgbel.
  IF sy-subrc = 0.
    LOOP AT li_deliv_det INTO wa_deliv_det.
      MOVE-CORRESPONDING wa_deliv_det TO wa_lips.
      APPEND wa_lips TO li_lips.
    ENDLOOP. " LOOP AT li_deliv_det INTO wa_deliv_det
  ENDIF. " IF sy-subrc = 0
ENDIF. " IF sy-subrc NE 0
* End   of Defect 1424

CALL FUNCTION 'ZOTC_0043_BILLBACK_PRICE_BILL'
  EXPORTING
    im_xvbrp         = xvbrp
* ---> Begin of Change for D2_OTC_EDD_0134 by PMISHRA
    im_maapv         = maapv
    im_t_xvbrp       = xvbrp[]
    im_t_vbap        = li_vbap[]
* ---> End of Change for D2_OTC_EDD_0134 by PMISHRA
* --> Begin of Changes for Defect 1424
    im_t_lips        = li_lips[]
* <-- End   of Changes for Defect 1424
*&--Begin of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017
    im_vbrk          = vbrk
*&<--End of insert for D3_OTC_EDD_0043 Defect# 3696 by SMUKHER4 on 24-OCT-2017
  CHANGING
    chng_tkomp       = tkomp.
