*&---------------------------------------------------------------------*
*&  Include           ZXEDFU02
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZXEDFU02                                               *
* TITLE      :  OTC_IDD_0011_/ose
* DEVELOPER  :  Shammi Puri                                            *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_IDD_0011_Outbound Customer Invoices EDI 810        *
*----------------------------------------------------------------------*
* DESCRIPTION: Sending Remit-to address
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 05-SEP-2012 SPURI    E1DK902309 INITIAL DEVELOPMENT                  *
* 24-NOV-2015 VGAUR    E2DK916190 Defect# 1202: Update EDI Invoice     *
*                                 "Remit to address" to show PO Box    *
*                                 instead of Street address.           *
*&---------------------------------------------------------------------*
* 24-Nov-2016 U033867  E1DK922746 CR-246 Do not override E1EDKA1-BK for*
*                                                          D3 customers*
*&---------------------------------------------------------------------*
* 24-Aug-207  amangal  E1DK930202 French E-Invoicing change:           *
*                                 SCTASK0555123                        *
*&---------------------------------------------------------------------*
* 18-Mar-2019 U105235  E2DK922857 SCTASK0807788-Populatiing the profit *
*                                 center in the vbdpr structure to     *
*                                 avoid the idoc failing error         *
*&---------------------------------------------------------------------*
* 26-Apr-2019 U105235  E2DK923636 Defect 9289 Removing the error caused*
*                                 due to the loop statement written for*
*                                 SCTASK0807788                        *
*&---------------------------------------------------------------------*

TYPES         : BEGIN OF lty_address,
                  name1      TYPE adrc-name1,      " Name 1
                  name2      TYPE adrc-name2,      " Name 2
                  name3      TYPE adrc-name3,      " Name 3
                  city1      TYPE adrc-city1,      " City
                  post_code1 TYPE adrc-post_code1, " City postal code
*& --> Begin of Insert for D2_OTC_IDD_0011 Defect# 1202 by VGAUR
                  po_box     TYPE ad_pobx, " PO Box
*& <-- End of Insert for D2_OTC_IDD_0011 Defect# 1202 by VGAUR
                END OF lty_address.


DATA          : lv_belnr  TYPE vbeln_vf, " Billing Document
                lv_bukrs  TYPE bukrs,    " Company Code
                lwa_edidd TYPE edidd,    " Data record (IDoc)
                lv_adrnr  TYPE adrnr,    " Address
                lwa_add   TYPE lty_address.

*& --> Begin of Insert for D2_OTC_IDD_0011 Defect# 1202 by VGAUR
DATA:
  lx_e1edka1_s TYPE e1edka1. " IDoc: Document Header Partner Information
*& <-- End of Insert for D2_OTC_IDD_0011 Defect# 1202 by VGAUR
*Begin of change for CR-246 by U033867
DATA: lv_flag_zk TYPE char1. " Flag_zk of type CHAR1
*End of change for CR-246 by U033867
FIELD-SYMBOLS : <lfs_edidd> TYPE edidd. " Data record (IDoc)
*Begin of change for CR-246 by U033867
CLEAR: lv_flag_zk .
*End of change for CR-246 by U033867
*U033632
CONSTANTS:lc_kschl     TYPE z_criteria    VALUE 'KSCHL'. " Enh. Criteria
*U033632

READ TABLE int_edidd INTO lwa_edidd WITH KEY segnam = 'E1EDKA1' sdata+0(3) = 'BK'.
IF sy-subrc = 0.
*Get billing document number
  CLEAR : lwa_edidd ,
          lv_belnr,
          lv_bukrs,
          lv_adrnr,
          lwa_add.

  READ TABLE int_edidd INTO lwa_edidd WITH KEY segnam = 'E1EDK01'.
  IF sy-subrc = 0.
    lv_belnr = lwa_edidd-sdata+83(35).
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_belnr
      IMPORTING
        output = lv_belnr.
  ENDIF. " IF sy-subrc = 0

*Get company code from VBRK
  SELECT SINGLE bukrs " Company Code
         FROM   vbrk  " Billing Document: Header Data
         INTO   lv_bukrs
         WHERE  vbeln = lv_belnr.
  IF sy-subrc = 0.
*Get Address number from T049L
    SELECT SINGLE adrnr " Address
           FROM   t049l " Lockboxes at our House Banks
           INTO   lv_adrnr
           WHERE  bukrs = lv_bukrs.
    IF sy-subrc = 0.
*Begin of change for CR-246 by U033867
      lv_flag_zk = abap_true.
*End of change for CR-246 by U033867
*Get address from ADRC
      SELECT SINGLE name1      " Name 1
                    name2      " Name 2
                    name3      " Name 3
                    city1      " City
                    post_code1 " City postal code
*& --> Begin of Insert for D2_OTC_IDD_0011 Defect# 1202 by VGAUR
                    po_box " PO Box
*& <-- End of Insert for D2_OTC_IDD_0011 Defect# 1202 by VGAUR
               FROM adrc " Addresses (Business Address Services)
               INTO lwa_add
               WHERE addrnumber = lv_adrnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF sy-subrc = 0


  IF lv_flag_zk = abap_true.
*Update Address for Partner BK
    READ TABLE int_edidd ASSIGNING <lfs_edidd> WITH KEY segnam = 'E1EDKA1' sdata+0(3) = 'BK'.
    IF sy-subrc = 0.
      <lfs_edidd>-sdata+0(3)    = 'ZK'.
      <lfs_edidd>-sdata+20(17)  = lv_bukrs.
      <lfs_edidd>-sdata+37(35)  = lwa_add-name1.
      <lfs_edidd>-sdata+72(35)  = lwa_add-name2.
      <lfs_edidd>-sdata+107(35) = lwa_add-name3.
      <lfs_edidd>-sdata+282(35) = lwa_add-city1.
*& --> Begin of Insert for D2_OTC_IDD_0011 Defect# 1202 by VGAUR

*&--Idoc segment will be already populated with street address(STRAS), replace it with ADRC-PO_BOX
      IF lwa_add-po_box IS NOT INITIAL.
        lx_e1edka1_s       = <lfs_edidd>-sdata.
        lx_e1edka1_s-stras = lwa_add-po_box.
        <lfs_edidd>-sdata  = lx_e1edka1_s.
        CLEAR: lx_e1edka1_s.
      ENDIF. " IF lwa_add-po_box IS NOT INITIAL
*& <-- End of Insert for D2_OTC_IDD_0011 Defect# 1202 by VGAUR

      REPLACE ALL OCCURRENCES OF '-' IN lwa_add-post_code1 WITH space.
      CONDENSE lwa_add-post_code1 NO-GAPS.
      <lfs_edidd>-sdata+326(9)  = lwa_add-post_code1.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " if lv_flag_zk = abap_true
ENDIF. " IF sy-subrc = 0

*Begin of change for SCTASK0807788 by U105235
*if the profit center field value is blank for the billing document line items, then only
*the below logic has to be triggered
DATA : lv_flag1     TYPE c,
       xtvbdpr_temp TYPE STANDARD TABLE OF vbdpr,
       lwa_temp     TYPE vbdpr.
CLEAR lv_flag1.

*Begin of change for 8000020011: R6:DEV:D3_PTP_EDD_0341 Defect 9289
*the below code is commented becoz of the loop on xtvbdpr the posnr field is being
*stored with the last line item
*LOOP AT xtvbdpr WHERE prctr IS INITIAL.
*lv_flag1 = abap_true.
*ENDLOOP.

REFRESH xtvbdpr_temp[].
CLEAR lwa_temp.
xtvbdpr_temp[] = xtvbdpr[].

LOOP AT xtvbdpr_temp INTO lwa_temp WHERE prctr IS INITIAL.
lv_flag1 = abap_true.
ENDLOOP.
REFRESH xtvbdpr_temp[].
CLEAR lwa_temp.
*End of change for 8000020011: R6:DEV:D3_PTP_EDD_0341 Defect 9289
*Passing the Profit center field value in XTVBDPR table for the billing types
* ZL2/ZG2 to avoid the Idoc failing error-Profit center is missing
IF lv_flag1 = abap_true.
INCLUDE zptpn0341o_billing_idoc.
ENDIF.
*End of change for SCTASK0807788 by U105235

IF control_record_out-cimtyp NE 'ZRTRE_INVOIC02_01'.
*&---------------------------------------------------------------------*
*&  Include           ZXEDFU02
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
  INCLUDE zotcn0011b_out_cust_inv. " Include ZOTCN0011B_OUT_CUST_INV

*&---------------------------------------------------------------------*
*&  Include           ZXEDFU02
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZXEDFU02                                               *
* TITLE      :  D2_OTC_IDD_0099
* DEVELOPER  :  Avik Poddar                                            *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_IDD_0099_SAP Invoice to ServiceMax              *
*----------------------------------------------------------------------*
* DESCRIPTION: SAP Invoice to ServiceMax
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 20-JUN-2014 APODDAR  E2DK900763 INITIAL DEVELOPMENT
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

  INCLUDE zotcn0099b_sap_inv_servicemax. " Include ZOTCN0099B_SAP_INV_SERVICEMAX
ELSE. " ELSE -> IF control_record_out-cimtyp NE 'ZRTRE_INVOIC02_01'
*---> Commenting this code for temporary move for IDD_0011
*************************************************************************
** PROGRAM    :  ZXEDFU02                                               *
** TITLE      :  D2_OTC_IDD_0111                                        *
** DEVELOPER  :  Vivek Gaur                                             *
** OBJECT TYPE:  Interface                                              *
** SAP RELEASE:  SAP ECC 6.0                                            *
**----------------------------------------------------------------------*
** WRICEF ID  :  D2_OTC_IDD_0111                                        *
**----------------------------------------------------------------------*
** DESCRIPTION: Outbound Customer Invoices EDI 810                      *
**----------------------------------------------------------------------*
** MODIFICATION HISTORY:                                                *
**======================================================================*
** DATE         USER      TRANSPORT   DESCRIPTION                       *
** ===========  ========  ==========  ==================================*
** 31-JAN-2015  VGAUR     E2DK904551  INITIAL DEVELOPMENT               *
*************************************************************************
  INCLUDE zotcn0111b_out_cust_invoice. " Outbound Customer Invoices EDI 810
*<--- Commenting this code for temporary move for IDD_0011
ENDIF. " IF control_record_out-cimtyp NE 'ZRTRE_INVOIC02_01'

*************************************************************************
** PROGRAM    :  ZXEDFU02                                               *
** TITLE      :  D3_OTC_IDD_0011                                        *
** DEVELOPER  :  Abdulla Mangalore                                      *
** OBJECT TYPE:  Interface                                              *
** SAP RELEASE:  SAP ECC 6.0                                            *
**----------------------------------------------------------------------*
** WRICEF ID  :  D3_OTC_IDD_0011                                        *
**----------------------------------------------------------------------*
** DESCRIPTION: Outbound Customer Invoices EDI 810                      *
**----------------------------------------------------------------------*
** MODIFICATION HISTORY:                                                *
**======================================================================*
** DATE         USER      TRANSPORT   DESCRIPTION                       *
** ===========  ========  ==========  ==================================*
** 24-Aug-207  amangal  E1DK930202 French E-Invoicing change:           *
*                                 SCTASK0555123                         *
* 07-JAN-2019 U033632  E1DK939647 Defect#7538/SCTASK0768470 :Add Bill-to*
*                                 VAT Reg. No for ZEIT and ZEIP output  *
*                                  type                                 *
*************************************************************************
IF control_record_out-cimtyp EQ 'ZOTCE_INVOIC02'.

  INCLUDE zotcn0011b_french_e_invoicing.
*& --> Begin of Insert for D3_OTC_IDD_0011 Defect#7538/SCTASK0768470 by U033632
  CLEAR: lwa_status.
*Get output type from EMI entry
*Binary search is not used as table has very less records
  READ TABLE fp_i_status INTO lwa_status WITH KEY criteria = lc_kschl
                                                  sel_low  = dobject-kschl.
  IF sy-subrc EQ 0.
    INCLUDE zotcn0011_italy_e_invoicing. " Include ZOTCN0011_ITALY_E_INVOICING
  ENDIF. " IF sy-subrc EQ 0
*& --> End of Insert for D3_OTC_IDD_0011 Defect#7538/SCTASK0768470 by U033632
ENDIF.
