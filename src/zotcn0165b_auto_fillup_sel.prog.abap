*&---------------------------------------------------------------------*
*&Include           ZOTCN0165B_AUTO_FILLUP_SEL
*&---------------------------------------------------------------------*
***********************************************************************
*Program    : Include ZOTCN0165B_AUTO_FILLUP_SEL                      *
*Title      : ZOTCN0165B_AUTO_FILLUP_SEL                              *
*Developer  : Moushumi Bhattacharya                                   *
*Object type: Report Include                                          *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_EDD_0165                                           *
*---------------------------------------------------------------------*
*Description: This include has been created for the creation of       *
*             seletion screen for the report.                         *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*08-Aug-2014  MBHATTA1      E2DK901527     R2:DEV:D2_OTC_EDD_0165_Auto*
*                                          fill up orders             *
*---------------------------------------------------------------------*
*04-Nov-2015  SAGARWA1      E2DK915951   Defect#1058 :Add Sales Office*
*                                        on Selection screen          *
*---------------------------------------------------------------------*
*12-Aug-2016  SAGARWA1      E2DK918614   Defect#1882 :Add Order Combi-*
*                                        -nation on Selection screen. *
*---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

PARAMETERS: p_vkorg TYPE vkorg OBLIGATORY,                                      "Sales Organization
            p_vtweg TYPE vtweg OBLIGATORY DEFAULT '10',                         "Distribution Channel
            p_spart TYPE spart OBLIGATORY DEFAULT '00',                         "Division
*& -->Begin of Insert for Defect#1058 by SAGARWA1
            p_vkbur TYPE vkbur OBLIGATORY MATCHCODE OBJECT h_tvbur,             "Sales Office
*& -->End   of Insert for Defect#1058 by SAGARWA1
            p_attri TYPE katr2 OBLIGATORY DEFAULT '01' MATCHCODE OBJECT h_tvk2, "Attribute 2
            p_parvw TYPE parvw OBLIGATORY DEFAULT 'SB' MATCHCODE OBJECT h_tpar. "Partner Function



SELECT-OPTIONS: s_vbeln FOR gv_vbeln NO-EXTENSION NO INTERVALS,   "for dynamic entry
                s_kunnr FOR gv_kunnr,                             "Special Stock Partner
                s_date  FOR gv_date OBLIGATORY.                   "Document Creation date


PARAMETERS: p_source TYPE auart OBLIGATORY DEFAULT 'ZKE' MATCHCODE OBJECT h_tvak, "Source Sales Document Type
            p_target TYPE auart OBLIGATORY DEFAULT 'ZKB' MATCHCODE OBJECT h_tvak, "Target Sales Document Type
            p_lifsk  TYPE lifsk MATCHCODE OBJECT h_tvls.                          "Delivery block

*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
* Add Order Combination check box on selection screen
PARAMETERS : cb_order  AS CHECKBOX USER-COMMAND cb1.
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
SELECTION-SCREEN END OF BLOCK b1.
