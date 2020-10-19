*&---------------------------------------------------------------------*
*& Include  ZOTC_CUS_INV_CREATE_FOR
*&
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTC_CUS_INV_CREATE_PAR                                *
* TITLE      :  OTC_EDD_0414_Proforma Shipment                         *
* DEVELOPER  :  Manoj thatha                                           *
* OBJECT TYPE:  Include Program                                        *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_EDD_0414                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: Proforma Shipment                                       *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER     TRANSPORT  DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 16-Aug-2018  MTHATHA  E1DK937760 INITIAL DEVELOPMENT                 *
* 19-Nov-2018  U033632  E1DK939349 SCTASK0753994:1.Code added to create*
*                                  proforma invoice for ZDF8 billing   *
*                                  type                                *
*                                  2. Added Creation date and Proforma *
*                                  CI for Sales BOM on selection screen*
*17-Dec-2018 U033632    E1DK939349 Defect#7847/SCTASK0753994:1. Removed*
*                                  EXPKZ check from selection of LIKP  *
*                                  table.                              *
*                                  2.Fixed issue of duplicate invoices *
*                                  3.Changed the text Proforma CI for  *
*                                  Sales BOM"  to "Customer Proforma   *
*                                  for HU Level CI" on sel screen      *
*                                  4.Changed delivery type to multiple *
*                                   selection                          *
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK fkart WITH FRAME TITLE text-t01.
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*PARAMETERS: p_fkart TYPE fkart OBLIGATORY AS LISTBOX VISIBLE LENGTH 35 . " Billing Type
*End of delete for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
PARAMETERS: p_fkart TYPE fkart AS LISTBOX VISIBLE LENGTH 35 . " Billing Type
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
PARAMETERS: p_fkdat TYPE fkdat. " Billing date for billing index and printout
SELECTION-SCREEN END OF BLOCK fkart.

SELECTION-SCREEN BEGIN OF BLOCK ftrade WITH FRAME TITLE text-t02.
PARAMETERS: p_kzabe  TYPE kzabe. " Indicator for the means of transport at departure
PARAMETERS: p_kzgbe  TYPE kzgbe. " Indicator for means of transport crossing the border
SELECTION-SCREEN END OF BLOCK ftrade.

SELECTION-SCREEN BEGIN OF BLOCK dlv WITH FRAME TITLE text-t03.
SELECT-OPTIONS: s_vbeln FOR likp-vbeln MATCHCODE OBJECT vmvl. " Delivery
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect#7847 by U033632
*PARAMETERS    : p_dtype TYPE likp-lfart.
*End of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect#7847 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect#7847 by U033632
*Changed delivery type from single to multiple selection
SELECT-OPTIONS: s_lfart FOR likp-lfart. " Delivery Type
*End of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect#7847 by U033632
SELECT-OPTIONS: s_vkorg FOR likp-vkorg. " Sales Organization
SELECT-OPTIONS: s_vstel FOR likp-vstel. " Shipping Point/Receiving Point
SELECT-OPTIONS: s_vsbed FOR likp-vsbed. " Shipping Conditions
PARAMETERS: p_inco1 TYPE inco1. " Incoterms (Part 1)
SELECT-OPTIONS: s_grkor FOR lips-grkor. " Delivery group (items are delivered together)
SELECT-OPTIONS: s_wadat FOR likp-wadat. " Planned goods movement date
SELECT-OPTIONS: s_agmdat FOR likp-wadat_ist. " Actual Goods Movement Date
SELECT-OPTIONS: s_kunnr FOR likp-kunnr. " Ship-to party
SELECT-OPTIONS: s_land  FOR vbpa-land1. " Country Key
SELECT-OPTIONS: s_spedl FOR vbpa-lifnr. " Account Number of Vendor or Creditor
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
SELECT-OPTIONS: s_erdat FOR likp-erdat. " Date on Which Record Was Created
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
SELECTION-SCREEN END OF BLOCK dlv.

SELECTION-SCREEN BEGIN OF BLOCK trans WITH FRAME TITLE text-t04.
SELECT-OPTIONS: s_tknum FOR vttk-tknum. " Shipment Number
SELECT-OPTIONS: s_route FOR likp-route. " Route
SELECT-OPTIONS: s_vsart FOR vttk-vsart. " Shipping type
SELECT-OPTIONS: s_spedt FOR vttk-tdlnr. " Number of forwarding agent
SELECTION-SCREEN END OF BLOCK trans.

SELECTION-SCREEN BEGIN OF BLOCK load WITH FRAME TITLE text-t05.
SELECT-OPTIONS: s_lstel FOR likp-lstel. " Loading Point
SELECT-OPTIONS: s_lgtor FOR likp-lgtor. " Door for Warehouse Number
SELECTION-SCREEN END OF BLOCK load.

SELECTION-SCREEN BEGIN OF BLOCK vari WITH FRAME TITLE text-t06.
PARAMETERS: p_dvari LIKE disvariant-variant. " Layout
SELECTION-SCREEN END OF BLOCK vari.

SELECTION-SCREEN BEGIN OF BLOCK bg WITH FRAME TITLE text-t07.
PARAMETERS: p_noblk TYPE xfeld AS CHECKBOX. " Checkbox
SELECTION-SCREEN END OF BLOCK bg.

*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Proforma CI for Sales BOM
SELECTION-SCREEN BEGIN OF BLOCK bom WITH FRAME TITLE text-t08.
PARAMETERS: p_slsbom TYPE xfeld AS CHECKBOX DEFAULT space USER-COMMAND sls1. " Checkbox
SELECTION-SCREEN END OF BLOCK bom.
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
