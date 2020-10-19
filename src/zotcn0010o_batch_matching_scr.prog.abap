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
* 06-AUG-2014 PROUT    E1DK913381 INC0140560 / CR1286:                 *
*                                 Updated selection screen with extra  *
*                                 checkbox 'Without Order History'. If *
*                                 the indicator got checked sales ord. *
*                                 details for the customer will not be *
*                                 displayed in the report output. Also *
*                                 Material Number and Batch Number will*
*                                 have multiple selections. If the     *
*                                 indicator is not checked then        *
*                                 Material No and Batch No will have   *
*                                 single entry and sales order history *
*                                 for the customer needs to be fetched *
*                                 for the customer in the report o/p.  *
*&---------------------------------------------------------------------*
* 16-SEP-2014 SPAUL2   E1DK913381 INC0140560 / CR1286:                 *
*                                 Added some additional requirements   *
*                                 as per business user demand.         *
*                                 1.New selection parameter of Ship-to *
*                                 2.New rept output column of Ship-to  *
*                                 3.Ship-to value fetching logic       *
*                                 4.Shift of column Unrest. Stock to   *
*                                   the end of the output              *
*&---------------------------------------------------------------------*
* 19-JAN-2015 SPAUL2   E1DK913381 INC0140560 / CR1286:                 *
*                                 Remove ‘Zero Inventory’ selection    *
*                                 button from the selection screen of  *
*                                 the report.                          *
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_kunnr FOR  gv_kunnr MATCHCODE OBJECT debi,              " Customer no
**&& -- Begin of insert: CR #1286 : SPAUL2 : 16-SEP-2014
                s_shipto FOR gv_kunnr MATCHCODE OBJECT debi.              " Ship-to No.
**&& -- End of insert: CR #1286 : SPAUL2 : 16-SEP-2014

**&& -- BOC : CR #1286 : PROUT : 06-AUG-2014
SELECT-OPTIONS:  s_matnr FOR gv_matnr OBLIGATORY,                         " Material no
**&& -- EOC : CR #1286 : PROUT : 06-AUG-2014
                 s_charg FOR  gv_charg .                                 " Batch Number

PARAMETER:      p_atwrt TYPE atwrt.                                      " Product Group
SELECT-OPTIONS  s_date  FOR  gv_date OBLIGATORY.                          " Date Range
PARAMETERS :
**&& --  BOC : CR# 1286 : SPAUL2 : 19-JAN-2015
*             cb_invt AS CHECKBOX DEFAULT 'X',    "Zero Inventory
**&& --  EOC : CR# 1286 : SPAUL2 : 19-JAN-2015
             cb_det  AS CHECKBOX DEFAULT 'X',    "Details
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
             cb_hist  AS CHECKBOX .              " History
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014
SELECTION-SCREEN END OF BLOCK b1.
