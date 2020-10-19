***********************************************************************
* Program     : ZOTC_PROFORMA_INVOICE_FORM                            *
* Title       : Proforma Invoice Form                                 *
* Developer   : Avanti Sharma                                         *
* Object type : Adobe Form                                            *
* SAP Release : SAP ECC 6.0                                           *
*---------------------------------------------------------------------*
* WRICEF ID   : D3_OTC_FDD_0088                                       *
*---------------------------------------------------------------------*
* Description : This function module fetches all data for displaying  *
*               on proforma invoice form                              *
*---------------------------------------------------------------------*
* MODIFICATION HISTORY:                                               *
*=====================================================================*
* Date           User        Transport       Description              *
*=========== ============== ============== ===========================*
*23-SEP-2016 ASHARMA8       E1DK921463     Initial development        *
*&--------------------------------------------------------------------*
*26-OCT-2016 ASHARMA8       E1DK921463     Defect_5595, Defect_5657,  *
*   Defect_5676, Defect_5741, Defect_5921                             *
* - Contact phone and email should be printed                         *
* - VAT% should appear in tax summary                                 *
* - Item number - remove leading zeros                                *
* - Address of Sales org should have 5 lines max                      *
* - Address of customers - bill to, sold to, ship to should have      *
*   6 lines max                                                       *
* - Freight, Handling, Insurance & Documentation charges should appear*
*   as 0 instead of blank                                             *
* - VAT Tax rate (field 107) should appear for BOM header material    *
*   and not for BOM components                                        *
* - Net amt, tax amt and total amt should be printed in decimal format*
*   of the country and should be printed as 0 instead of blank        *
* - Sales Org address should appear on all pages                      *
*&--------------------------------------------------------------------*
FUNCTION zotc_proforma_invoice_form.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_NAST) TYPE  NAST
*"     REFERENCE(IM_BIL_PRT_COM) TYPE  INVOICE_S_PRT_INTERFACE
*"  EXPORTING
*"     REFERENCE(EX_HEADER) TYPE  ZOTC_PROFORMA_HEADER
*"     REFERENCE(EX_ITEM) TYPE  ZOTC_T_PROFORMA_ITEM
*"----------------------------------------------------------------------
  DATA: li_ser02        TYPE ty_t_ser02,
        li_objk         TYPE ty_t_objk,
        li_knmt         TYPE ty_t_knmt,
        li_vbrp         TYPE ty_t_vbrp,
        li_eipo         TYPE ty_t_eipo,
        li_vbfa         TYPE ty_t_vbfa,
        li_konv         TYPE ty_t_konv,
        li_lips         TYPE ty_t_lips,
        li_enh_status   TYPE zdev_tt_enh_status,
        li_vbdpr        TYPE tbl_vbdpr,
        lx_vbdkr        TYPE vbdkr, " Document Header View for Billing
        lx_tvko         TYPE tvko,  " Organizational Unit: Sales Organizations
        lv_doc_currency TYPE waerk. " SD Document Currency

* Get invoice header and item details from print program data (BIL_PRT_COM)
  PERFORM f_get_inv_detail USING    im_bil_prt_com
                           CHANGING lv_doc_currency
                                    lx_vbdkr
                                    lx_tvko
                                    li_vbdpr.

* Read constants from EMI
  PERFORM f_get_enh_status_data CHANGING li_enh_status.


* Fetch invoice header related data from database
  PERFORM f_fetch_inv_head_rel_data USING     lx_vbdkr
                                    CHANGING  ex_header
                                              li_vbrp
                                              li_eipo
                                              li_konv.

* Fetch invoice item related data from database
  PERFORM f_fetch_inv_item_rel_data USING    lx_vbdkr
                                             li_vbdpr
                                    CHANGING li_ser02
                                             li_objk
                                             li_knmt
                                             li_vbfa
                                             li_lips.

* Populate form header data
  PERFORM f_populate_header USING     im_nast
                                      lx_vbdkr
                                      lx_tvko
                                      li_vbdpr
                                      li_vbfa
                                      li_enh_status
                            CHANGING  ex_header.

* decimal formatting as per bill to country
  SET COUNTRY ex_header-billto_ctry.

* Begin of Insert for Defect_5676 by ASHARMA8
  PERFORM f_update_header CHANGING ex_header.
* End of Insert for defect_5676 by ASHARMA8

* Ppulate form Item data
  PERFORM f_fill_form_item_data  USING    lx_vbdkr
                                          li_vbdpr
                                          li_eipo
                                          li_ser02
                                          li_objk
                                          li_knmt
                                          li_vbrp
                                          li_konv
                                          li_lips
                                 CHANGING ex_header
                                          ex_item.

* Fetch invoice condition records & populate form header
  PERFORM f_fill_conditions_data USING   lv_doc_currency
                                         li_konv
                                CHANGING ex_header.


ENDFUNCTION.
