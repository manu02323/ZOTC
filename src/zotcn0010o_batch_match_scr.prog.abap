*&---------------------------------------------------------------------*
*&  Include          ZOTCN0010O_BATCH_MATCHING_SCR                     *
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0010O_BATCH_MATCHING_SCR                          *
* TITLE      :  Batch Matching Report                                  *
* DEVELOPER  :  Pallavi Gupta                                          *
* OBJECT TYPE:  INCLUDE                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0010_BATCH_MATCHING Report                       *
*----------------------------------------------------------------------*
* DESCRIPTION:  Include for screen definition for report               *
*               ZOTCR0010O_BATCH_MATCHING                              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 16-Jul-2012 PGUPTA2  E1DK901335 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
select-options: s_kunnr for  gv_kunnr matchcode object debi.              " Customer no
PARAMETER:      p_matnr TYPE matnr MATCHCODE OBJECT mat1 OBLIGATORY.     " Material no
SELECT-OPTIONS: s_charg FOR  gv_charg NO INTERVALS NO-EXTENSION.        " Batch Number
parameter:      p_atwrt type atwrt.                                      " Product Group
select-options  s_date  for  gv_date obligatory.                          " Date Range

parameters : cb_invt as checkbox default 'X',    "Zero Inventory
             cb_det  as checkbox default 'X'.    "Details
SELECTION-SCREEN END OF BLOCK b1.
