*&---------------------------------------------------------------------*
*& INCLUDE  ZOTCN0019O_ZZKMOKBV2_FILL
*&
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0019O_ZZKMOKBV2_FILL (Enhancement)                *
* TITLE      :  D3_OTC_EDD_0019 Output Control Routines                *
* DEVELOPER  :  Srinivasa Gurijala                                     *
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
* 12-SEP-2016  U033814   E1DK921665 OTC Output Control Routines        *
*&---------------------------------------------------------------------*
* 13-SEP-2017  ASK      E1DK930674 Defect#3430 When this exit is called*
*                                  from  LEX_EDD_0044 then dynamic VBKD*
*                                  internal table access should be     *
*                                  avoided as its causing issues       *
*&---------------------------------------------------------------------*
*Field symbol declaration for PO Type
FIELD-SYMBOLS :
                 <li_vbkd>  TYPE va_vbkdvb_t,
                 <lfs_vbkd> TYPE vbkdvb. " Reference structure for XVBKD/YVBKD
CONSTANTS:       lc_posnr_header TYPE posnr  VALUE '000000',            " Item number of the SD document
                 lc_vbkd_tab     TYPE char30 VALUE '(SAPMV45A)XVBKD[]'. " Vbkd_tab of type CHAR30

DATA: lv_bsark TYPE bsark,      " Customer purchase order type
      lwa_lips_tab TYPE lipsvb. " Reference structure for XLIPS/YLIPS

 IF sy-cprog NE 'ZLEXE0044B_FREIGHT_COST_UPD'.  " Defect 3430
* Assign BSARK from VBKD if VBKD is assigned.

ASSIGN (lc_vbkd_tab) TO  <li_vbkd>.

IF <li_vbkd> IS ASSIGNED.
*  Read the Header PO Type
  READ TABLE <li_vbkd> ASSIGNING <lfs_vbkd>
                                WITH KEY posnr =  lc_posnr_header.
  IF sy-subrc = 0.
    com_kbv2-zzbsark = <lfs_vbkd>-bsark.
  ENDIF. " IF sy-subrc = 0
ENDIF. " IF <li_vbkd> IS ASSIGNED

ENDIF.                          " Defect 3430

* If the VBKD is not assgned get the PO Type from preceeding doc and assign
IF com_kbv2-zzbsark IS INITIAL AND com_likp-vbeln IS NOT INITIAL.
  READ TABLE com_lips_tab INTO lwa_lips_tab WITH KEY vbeln = com_likp-vbeln.
  IF sy-subrc IS INITIAL.
*     Get the PO type (bsark) from VBKD header entry (POSNR = 000000)
    SELECT SINGLE bsark " Customer purchase order type
      FROM vbkd         " Sales Document: Business Data
      INTO lv_bsark
     WHERE vbeln = lwa_lips_tab-vgbel
       AND posnr = lc_posnr_header.
    IF sy-subrc IS INITIAL.
*       Set the value of the PO type
      com_kbv2-zzbsark = lv_bsark.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL
ENDIF. " IF com_kbv2-zzbsark IS INITIAL AND com_likp-vbeln IS NOT INITIAL
