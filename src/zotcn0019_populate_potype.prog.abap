*&---------------------------------------------------------------------*
*&  Include           ZOTCN0019_POPULATE_POTYPE
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0019_POPULATE_POTYPE  (Enhancement)               *
* TITLE      :  OTC_EDD_0019_Output Control Routines                   *
* DEVELOPER  :  Shubasis Basu                                          *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0019                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Populate the field PO type for triggering o/p types     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 04-DEC-2012  SBASU   E1DK908843 PO Date is populated in Sales & Invoice
*                                 Output type                          *
*&---------------------------------------------------------------------*
* 26-APR-2013  GNAG    E1DK910146 Def#3614 - INC0086963-03
*                                 PO type is updated in Invoice Output
*&---------------------------------------------------------------------*
* 24-SEP-2013  RRANA   E1DK911712 Def#819 In Sales Order PO Type should*
*                                 be taken from Header.And for more    *
*                                 than one invoice processing from VF04*
*                                 respective Sales Order should be     *
*                                 considered for populating PO Type    *
*&---------------------------------------------------------------------*

*Field symbol declaration for PO Type
FIELD-SYMBOLS :
*                <lfs_vbkd> TYPE vbkd.   " Defect 819
                 <li_vbkd>  TYPE va_vbkdvb_t,   " Defect 819
                 <lfs_vbkd> TYPE vbkdvb.  " Defect 819

* BEGIN OF Def#3614 - INC0086963-03
DATA: lv_bsark TYPE bsark,
      lwa_com_vbrp_tab TYPE vbrpvb.
CONSTANTS: lc_posnr_header TYPE posnr  VALUE '000000',
           lc_vbkd_tab     TYPE char30 VALUE '(SAPMV45A)XVBKD[]'. " Defect 819
* END OF Def#3614 - INC0086963-03

* Populate PO date for Sales Order (Application V1)
*ASSIGN ('(SAPMV45A)VBKD') TO  <lfs_vbkd>.   " Defect 819
ASSIGN (lc_vbkd_tab) TO  <li_vbkd>.  " Defect 819

*IF <lfs_vbkd> IS ASSIGNED.  " Defect 819

* Begin of Defect # 819
IF <li_vbkd> IS ASSIGNED.
*  Read the Header PO Type
  READ TABLE <li_vbkd> ASSIGNING <lfs_vbkd>
                                WITH KEY posnr =  lc_posnr_header.
  IF sy-subrc = 0.
* End of Defect # 819

    com_kbv1-zzbsark = <lfs_vbkd>-bsark.
  ENDIF." Defect 819
ENDIF.

* BEGIN OF Def#3614 - INC0086963-03
** Populate PO date for Invoice (Application V3)
* IF com_kbv3-zzbsark IS INITIAL.
*   ASSIGN ('(SAPLV60A)VBKD') TO  <lfs_vbkd>.
*
*   IF <lfs_vbkd> IS ASSIGNED.
*     com_kbv3-zzbsark = <lfs_vbkd>-bsark.
*   ENDIF.
* ENDIF.
*
** Populate PO date for Invoice (Application V3)
* IF com_kbv3-zzbsark IS INITIAL.
*   ASSIGN ('(SAPLVCOM)VBKD') TO  <lfs_vbkd>.
*
*   IF <lfs_vbkd> IS ASSIGNED.
*     com_kbv3-zzbsark = <lfs_vbkd>-bsark.
*   ENDIF.
* ENDIF.

* If the PO type is initial (for VF02 case), then populate it from the
* db table VBKD. The SO number is read from COM_VBRP_TAB-AUBEL
IF com_kbv3-zzbsark IS INITIAL AND com_kbv3-vkorg IS NOT INITIAL.
*  READ TABLE com_vbrp_tab INTO lwa_com_vbrp_tab INDEX 1 TRANSPORTING aubel.  " Defect 819
  READ TABLE com_vbrp_tab INTO lwa_com_vbrp_tab WITH KEY vbeln = com_vbrk-vbeln." Defect 819
  IF sy-subrc IS INITIAL.
*     Get the PO type (bsark) from VBKD header entry (POSNR = 000000)
    SELECT SINGLE bsark
      FROM vbkd
      INTO lv_bsark
     WHERE vbeln = lwa_com_vbrp_tab-aubel
       AND posnr = lc_posnr_header.
    IF sy-subrc IS INITIAL.
*       Set the value of the PO type
      com_kbv3-zzbsark = lv_bsark.
    ENDIF.
  ENDIF.
ENDIF.
* END OF Def#3614 - INC0086963-03
