*&---------------------------------------------------------------------*
*&  Include           ZOTCN0067B_ZXV05U07
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(I_VBDKR) LIKE  VBDKR STRUCTURE  VBDKR
*"             VALUE(I_VBDRE) LIKE  VBDRE STRUCTURE  VBDRE
*"       EXPORTING
*"             VALUE(O_REFERENZ) LIKE  VBDRE-ESRRE
*"----------------------------------------------------------------------
***********************************************************************
*Program    : ZOTCN0067B_ZXV05U07                                     *
*Title      : Down Payment Request Form                               *
*Developer  : Dhananjoy Moirangthem                                   *
*Object type: Forms                                                   *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_FDD_0067                                           *
*---------------------------------------------------------------------*
*Description: Put the invoice and customer number in ESR ref field.   *
*                                                                     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*12-OCT-2016  DMOIRAN       E1DK921459     Initial Development
*---------------------------------------------------------------------*
*10-NOV-2016  ASHARMA8      E1DK921459     Defect_6302
*---------------------------------------------------------------------*

*Concatenate the last 7 characters of Payer and invoice into ESR reference
  MOVE '00' TO o_referenz(2).

*---> Begin of Delete for Defect_6302 by ASHARMA8
*  MOVE i_vbdre(10) TO o_referenz+2(10).
*<--- End of Delete for Defect_6302 by ASHARMA8

*---> Begin of Insert for Defect_6302 by ASHARMA8
  MOVE i_vbdre-kunid(10) TO o_referenz+2(10).
*<--- End of Insert for Defect_6302 by ASHARMA8

  MOVE i_vbdkr-kunrg+3(7) TO o_referenz+12(7).
  MOVE i_vbdkr-vbeln+3(7) TO o_referenz+19(7).
