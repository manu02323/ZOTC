class ZCL_IM_IM_ORDERS05_OTC_EDI definition
  public
  final
  create public .

public section.
*"* public components of class ZCL_IM_IM_ORDERS05_OTC_EDI
*"* do not include other source files here!!!

  interfaces IF_EX_IDOC_DATA_MAPPER .
protected section.
*"* protected components of class ZCL_IM_IM_ORDERS05_OTC_EDI
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_IM_ORDERS05_OTC_EDI
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_IM_ORDERS05_OTC_EDI IMPLEMENTATION.


METHOD if_ex_idoc_data_mapper~process.
************************************************************************
* PROGRAM    :  OTC_IDD_0009_SAP_Inbound sales order EDI 850           *
* TITLE      :  SAP_Inbound sales order EDI 850                        *
* DEVELOPER  :  SHAMMI PURI                                            *
* OBJECT TYPE:  BADI METHOD                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_0009                                             *
*----------------------------------------------------------------------*
* DESCRIPTION:
* FOLLOWING FUNCTIONALITIES ARE ACHIEVED BY IMPLEMETING BELOW BADI IMP:
* For Inbound Message type ORDERS05. Get Internal Number for Partner and
* Update in E1EDKA1 segment
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER      TRANSPORT      DESCRIPTION                   *
* ===========  ========   =========  ==================================*
* 06-June-2012   SPURI     E1DK903577    Initial Development
*&---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*22-May-2014  PMISHRA       E2DK900747      D2_OTC_IDD_0009 - D2 changes
*                                           for determining Bill To and
*                                           Payer partner Function
*---------------------------------------------------------------------*
*29-July-2016 Jahan         E1DK917543      Changes against Defect #2938
*                                           D3_OTC_IDD_0009 logic to
*                                           populate sales office data
*---------------------------------------------------------------------*
* 10/27/2016  Srini G  E1DK917543 CR-D3-84 --Comenting Sold to Ship to Logic
* From User Exit and moving this logic to Proxy Class                        *
*-----------------------------------------------------------------------------*

* Begin of CR-D3-84
*  CONSTANTS      :  c_orders05(20)                TYPE c VALUE 'ORDERS05',  " IDOC TYPE
*                    c_inbound(1)                  TYPE c VALUE '2',         " IDoc Direction
*                    c_e1edka1(20)                 TYPE c VALUE 'E1EDKA1',   " SEGMENT NAME
*                    c_e1edk02(20)                 TYPE c VALUE 'E1EDK02',   " SEGMENT NAME
*                    c_yes(1)                      TYPE c VALUE 'X',         " SELECTED
*                    c_zotc_msg(20)                TYPE c VALUE 'ZOTC_MSG',  " MESSAGE CLASS
*                    c_022(3)                      TYPE c VALUE '022',
*                    c_si                          TYPE edidc-sndlad VALUE 'SI',
*                    c_clf                         TYPE edidc-stdmes VALUE 'CLF',
**--> Begin of Change against Defect #2938 by JAHAN
*                    lc_parvw_soldto               TYPE parvw        VALUE 'AG',   "Added by JAHANM
*                    lc_parvw_shipto               TYPE parvw        VALUE 'WE',   "Added by JAHANM
**<-- End of Change against Defect #2938 by JAHAN
*
** ---> Begin of Insert for D2_OTC_IDD_0009 by PMISHRA
*                    lc_parvw_payer                TYPE parvw        VALUE 'RG',   " Partner Function - RG
*                    lc_parvw_bilto                TYPE parvw        VALUE 'RE'.   " Partner Function - RE
** ---> End of Insert for D2_OTC_IDD_0009 by PMISHRA
*  FIELD-SYMBOLS  :  <lfs_data>                  TYPE edid4.     " IDOC DATA
*
*  DATA:      lv_parvw             TYPE parvw, " Partner Function
*             lv_expnr             TYPE edi_expnr,
*             lv_kunnr             TYPE kunnr, " Customer Number
*             lv_inpnr             TYPE edi_inpnr,
*             lwa_mapping_rec      TYPE idoc_chang,
*             lv_belnr_char        TYPE char35,
*             lv_vbeln             TYPE vbfa-vbeln ,
*             lv_vbelv             TYPE vbfa-vbelv ,
*             lv_type              TYPE zotc_prc_control-mvalue1.
*
*  CASE control-idoctp.
*    WHEN c_orders05.
*      IF   control-direct = c_inbound AND
*           control-sndlad = c_si  .
** Triggered for 850 , EDI , CLARIFY
*        LOOP AT data ASSIGNING <lfs_data> WHERE  segnam = c_e1edka1 AND
**--> Begin of Change against Defect #2938 by JAHAN
*                          ( sdata+0(2) = lc_parvw_soldto OR sdata+0(2) = lc_parvw_shipto  "Added by JAHANM
**<-- End of Change against Defect #2938 by JAHAN
*
** ---> Begin of Insert for D2_OTC_IDD_0009 by PMISHRA
*                           OR sdata+0(2) = lc_parvw_payer
*                           OR sdata+0(2) = lc_parvw_bilto ).
** ---> End of Insert for D2_OTC_IDD_0009 by PMISHRA
*          CLEAR : lv_parvw,
*                  lv_expnr.
*
*          lv_parvw              = <lfs_data>-sdata+0(3).
*          lv_expnr              = <lfs_data>-sdata+20(17).
*
**Get internal number
*          CLEAR : lv_kunnr , lv_inpnr.
*          SELECT SINGLE kunnr  " Customer Number
*                        inpnr  " Internal partner number (in SAP System)
*           FROM  edpar  " Convert External <  > Internal Partner Number
*           INTO (lv_kunnr,
*                 lv_inpnr)
*           WHERE parvw = lv_parvw AND
*                 expnr = lv_expnr.
*          IF sy-subrc = 0.
*            CLEAR : lwa_mapping_rec.
*            lwa_mapping_rec-segnum      = <lfs_data>-segnum.
*            lwa_mapping_rec-feldname    = 'PARTN'.
*            lwa_mapping_rec-save_type   = c_yes.
*            lwa_mapping_rec-value       = lv_inpnr.
*            CONDENSE lwa_mapping_rec-value NO-GAPS.
*            APPEND lwa_mapping_rec TO mapping_tab.
*            have_to_change  = c_yes.
*            protocol-stamid = c_zotc_msg.
*            protocol-stamno = c_022.
*            protocol-repid  = sy-cprog .
*          ENDIF. " IF sy-subrc = 0
*        ENDLOOP.
*      ENDIF. " IF control-direct = c_inbound AND
*    WHEN OTHERS.
*  ENDCASE.
* End of CR-D3-84
ENDMETHOD.
ENDCLASS.
