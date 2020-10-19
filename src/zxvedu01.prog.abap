***********************************************************************
*Program    : ZXVEDU01                                                *
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
*&  Include           ZXVEDU01
*&---------------------------------------------------------------------*

INCLUDE zotcn0019o_ordrsp. " Include ZOTCN00190_ORDRSP
