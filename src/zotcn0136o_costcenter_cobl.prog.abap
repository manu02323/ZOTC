*&---------------------------------------------------------------------*
*&  Include           ZOTCN0136O_COSTCENTER_COBL
*&---------------------------------------------------------------------*
***********************************************************************
*Program    : ZOTCN0136O_COSTCENTER_COBL                               *
*Title      : Populate Receiver and sender Cost center                *
*Developer  : Anjan Paul                                              *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_EDD_0136_D3_CR_246                                           *
*---------------------------------------------------------------------*
*Description: Sales Order screen Enhancements  for Receiving and      *
*              sending cost center                                    *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date         User ID     Transport      Description
*===========  ==========  ============== =============================*
*18-OCT-2016  APAUL       E1DK919119     Initial Development          *
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*

*  Assign Cost center  at item
  VBAP-ZKOSTL = COBL-KOSTL .
