FUNCTION zotc_shipment_data_select.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_CRIT) TYPE  /SAPSLL/CUS_INV_CRIT_R3_S
*"     REFERENCE(IM_LFART) TYPE  /ISDFPS/RG_T_LFART
*"     REFERENCE(IM_AGMDAT) TYPE  /SAPSLL/WADAT_R_T
*"     REFERENCE(IM_ERDAT) TYPE  /SAPSLL/ERDAT_R3_R_T OPTIONAL
*"     REFERENCE(IM_ZDF8) TYPE  FLAG OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_CUS_INV) TYPE  /SAPSLL/CUS_INV_R3_T
*"  EXCEPTIONS
*"      NO_DATA
*"----------------------------------------------------------------------
************************************************************************
* Function Module  : zotc_shipment_data_select                         *
* Title      : Sendungsbildung: Daten selektieren                      *
* Developer  : Manoj Thatha                                            *
* Object Type: Function Module                                         *
* SAP Release: SAP ECC 6.0                                             *
*----------------------------------------------------------------------*
* WRICEF ID  : OTC_EDD_0414_Subcontracting Proforma                    *
*----------------------------------------------------------------------*
* Description: This function module is copied from standarad           *
*               /SAPSLL/SHIPMENT_DATA_SELECT                           *
*----------------------------------------------------------------------*
* Modification History:                                                *
*======================================================================*
* Date        User      Transport  Description                         *
* =========== ========  ========== ====================================*
* 16-Aug-2018  MTHATHA  E1DK937760 INITIAL DEVELOPMENT                 *
* 19-Nov-2018  U033632  E1DK939349 SCTASK0753994:1.Code added to create*
*                                  proforma invoice for ZDF8 billing   *
*                                  type                                *
*                                  2. Added Creation date and Proforma *
*                                  CI for Sales BOM flag as import     *
*                                  parameter                           *
*17-Dec-2018 U033632    E1DK939349 Defect#7847/SCTASK0753994:1. Removed*
*                                  EXPKZ check from selection of LIKP  *
*                                  table.                              *
*                                  2.Fixed issue of duplicate invoices *
*                                  3.Changed import parameter type of  *
*                                  im_lfart from LFART to              *
*                                  /ISDFPS/RG_T_LFART for multi sel    *
*                                  4.Changed delivery type to multiple *
*                                   selection                          *
*======================================================================*
  DATA: lt_likp       TYPE /sapsll/likp_r3_t.
  DATA: lt_lips       TYPE /sapsll/lips_r3_t.
  DATA: lt_vttp       TYPE vttp_tab.
  DATA: lt_vttk       TYPE vttk_tab.
  DATA: lt_eikp       TYPE /sapsll/eikp_r3_t.
  DATA: lt_vbpa       TYPE tab_vbpa.
*-- Selektion der Daten
  PERFORM shipment_tables_select USING    is_crit
                                          im_lfart
                                          im_agmdat
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
                                          im_erdat "Creation date
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
                                 CHANGING lt_likp
                                          lt_lips
                                          lt_vttk
                                          lt_vttp
                                          lt_vbpa
                                          lt_eikp.
*-- Aufbau des Selektionsergebnis
  PERFORM result_table_fill USING    lt_likp
                                     lt_lips
                                     lt_vttk
                                     lt_vttp
                                     lt_vbpa
                                     lt_eikp
                            CHANGING et_cus_inv.
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*If Proforma CI for Sales BOM is checked then modify result table based on ZDF8 billing type.
  IF im_zdf8 = abap_true.
    PERFORM result_table_modify USING  lt_likp
                                 CHANGING et_cus_inv.
  ENDIF. " If im_zdf8 = abap_true
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
ENDFUNCTION.
