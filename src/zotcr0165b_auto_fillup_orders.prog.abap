*&---------------------------------------------------------------------*
*& Report  ZOTCR0165B_AUTO_FILLUP_ORDERS
*&---------------------------------------------------------------------*
***********************************************************************
*Program    : ZOTCR0165B_AUTO_FILLUP_ORDERS                           *
*Title      : Auto Fill-up Orders                                     *
*Developer  : Moushumi Bhattacharya                                   *
*Object type: Report                                                  *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_EDD_0165                                           *
*---------------------------------------------------------------------*
*Description: This report will run in the background to generate      *
*Consigment Fill-up Orders by cummulating all the Consignment Issue   *
*Orders based on a material being shipped to a single combination of  *
*Sold-to customer and Ship-to Customers. All the issue orders created *
*during this program run inthe background will be handled manually.   *
*Seperate orders will be generated for a specific combination of      *
*Sold-to and Ship-to partners. For generating the order the BAPI:-    *
*BAPI_SALESORDER_CREATEFROMDAT2. The error scenario will be handled by*
*posting IDOC of type ORDERS05 for data or technical errors.          *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*08-Aug-2014  MBHATTA1      E2DK901527     R2:DEV:D2_OTC_EDD_0165_Auto
*                                                       fill up orders*
*---------------------------------------------------------------------*
*25-MAR-2014  ASK          E2DK901527    Defect 5267 : Making TVARVC  *
*                                        parameter Based On Sales Area*
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*25-MAR-2014  MBHATTA1     E2DK901527    Defect 5267 : Changed BDC for*
*                                        updating STVARV for new      *
*                                        variables                    *
*---------------------------------------------------------------------*
*04-Nov-2015  SAGARWA1     E2DK915951    Defect#1058 :Add Sales Office*
*                                        on Selection screen          *
*---------------------------------------------------------------------*
*12-Aug-2016  SAGARWA1      E2DK918614   Defect#1882 :                *
*                                        1. Add Order Combination on  *
*                                        Selection screen and update  *
*                                        VBKD accordingly.            *
*                                        2. Create Consignment Fill up*
*                                        irrespective of consignment  *
*                                        issue status.                *
*                                        3. Populate PO number in fill*
*                                        up to maintain one to one rel*
*                                        -ationship.                  *
*21-Nov-2017  AMOHAPA     E1DK931603    Defect# 4255: Unconfirmed     *
*                                       lines should transfer from ZKE*
*                                       to ZKB as per the design      *
*---------------------------------------------------------------------*

REPORT zotcr0165b_auto_fillup_orders MESSAGE-ID zotc_msg NO STANDARD PAGE
                                                         HEADING
                                                         LINE-COUNT 65(8)
                                                         LINE-SIZE 132.
************************************************************************
************************************************************************
*          DATA DECLARATION INCLUDE                                    *
************************************************************************
* Include for data declaration
INCLUDE zotcn0165b_auto_fillup_top. " Include ZOTCN0165B_AUTO_FILLUP_TOP


************************************************************************
*          SELECTION SCREEN DECLARATION INCLUDE                        *
************************************************************************
* Include for Selection Screen
INCLUDE zotcn0165b_auto_fillup_sel. " Include ZOTCN0165B_AUTO_FILLUP_SEL


************************************************************************
*          SUBROUTINE INCLUDE                                          *
************************************************************************
* Include for sub-routines
INCLUDE zotcn0165b_auto_fillup_sub. " Include ZOTCN0165B_AUTO_FILLUP_SUB


INITIALIZATION.
* Authorisation check for updating the last
* processed order number in TVARVC
  PERFORM f_auth_check.
* Fetching the last processed order number from TVARVC
*  PERFORM f_dynamic_var.     " Defect 5267


AT SELECTION-SCREEN OUTPUT.

* Begin of Change For Defect 5267
*  PERFORM f_dynamic_var.
* End   of Change for Defect 5267
*---> Begin of insert for Defect # 6345 D3_OTC_EDD_0165 by PDEBARU
  PERFORM f_dynamic_var.
*<--- End of insert for Defect # 6345 D3_OTC_EDD_0165 by PDEBARU


*----------------------------------------------------------------------*
*     A T  S E L E C T I O N - S C R E E N  O N
*----------------------------------------------------------------------*
*validation for VKORG
AT SELECTION-SCREEN ON p_vkorg.
  PERFORM f_salesorg_validation.


*validation for VTWEG
AT SELECTION-SCREEN ON p_vtweg.
  PERFORM f_distchan_validation.

*validation for SPART
AT SELECTION-SCREEN ON p_spart.
  PERFORM f_division_validation.

*& -->Begin of Insert for Defect#1058 by SAGARWA1
* Validation for Sales Office VKBUR
AT SELECTION-SCREEN ON p_vkbur.
  PERFORM f_salesofc_validation.
*& -->End   of Insert for Defect#1058 by SAGARWA1

*validation for ATTRI
AT SELECTION-SCREEN ON p_attri.
  PERFORM f_custattri_validation.

*validation for PARVW
AT SELECTION-SCREEN ON p_parvw.
  PERFORM f_partfunc_validation.

*validation for PARVW
AT SELECTION-SCREEN ON s_vbeln.
  IF s_vbeln IS NOT INITIAL.
    PERFORM f_salesorder_validation.
  ENDIF. " IF s_vbeln IS NOT INITIAL

*validation for KUNNR
AT SELECTION-SCREEN ON s_kunnr.
  IF s_kunnr IS NOT INITIAL.
    PERFORM f_partner_validation.
  ENDIF. " IF s_kunnr IS NOT INITIAL

*validation for source AUART
AT SELECTION-SCREEN ON p_source.
  PERFORM f_doctyp_validation USING p_source.

*validation for target AUART
AT SELECTION-SCREEN ON p_target.
  PERFORM f_doctyp_validation USING p_target.

*validation for LIFSK
AT SELECTION-SCREEN ON p_lifsk.
  IF p_lifsk IS NOT INITIAL.
    PERFORM f_delblock_validation.
  ENDIF. " IF p_lifsk IS NOT INITIAL

************************************************************************
*        S T A R T - O F - S E L E C T I O N                           *
************************************************************************
START-OF-SELECTION.
************************************************************************
*Selecting the data required to create consignment
*issue order of type ZKB in this sub-routine

  PERFORM f_get_data CHANGING i_vbak
                              i_vbap
                              i_vbup
                              i_vbpa
*--> Begin of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
"We no more required to delivery records from LIPS, we will consider VBAP entry
"while copying the records
*                              i_lips
*<-- End of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
                              i_vbkd.
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016

************************************************************************
*             E N D- O F - S E L E C T I O N                           *
************************************************************************
END-OF-SELECTION.
************************************************************************
*Passing the selected and filtered data to the final
*structures and tables to be posted to the BAPI
  PERFORM f_update_data USING i_vbpa
*--> Begin of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
"We no more required to delivery records from LIPS, we will consider VBAP entry
"while copying the records
*                              i_lips
*<-- End of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
                              i_vbkd
                              i_vbap.
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
************************************************************************
