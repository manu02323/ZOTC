*&---------------------------------------------------------------------*
*&  Include           ZOTCN0116O_REVENUE_REPORT_SCR
*&---------------------------------------------------------------------*
************************************************************************
* Include    :  ZOTCN0116O_REVENUE_REPO                                *
* TITLE      :  End to End Revenue Report                              *
* DEVELOPER  :  RAGHAV SUREDDI                                         *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0116_REVENUE_REPORT                              *
*----------------------------------------------------------------------*
* DESCRIPTION: This Report can be utilized by users to track Revenue   *
*               Documents created on a specific date or within a date  *
*               range. The report will provide all key information     *
*               about the Revenue.                                     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 30-Nov-2017 U033876   E1DK934630 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 10-May-2018 U100018   E1DK934630 Defect# 6027: Fix performance issue *
* 14-Jan-2019 U033876   E1DK939333 Sctask: SCTASK0745122 Intercompany  *
*                       Billing Accrual fields                         *
*&---------------------------------------------------------------------*

*SELECTION-SCREEN BEGIN OF: SCREEN 100 AS SUBSCREEN,
*                           BLOCK podcsum WITH FRAME TITLE text-s01.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-s01.
SELECT-OPTIONS: s_vkorg   FOR gv_vkorg OBLIGATORY,
                s_vtweg   FOR gv_vtweg,
                s_vbelvl  FOR gv_vbeln_vl, "Delivery
                s_lfart   FOR gv_lfart,
                s_werks   FOR gv_werks,
*--> Begin of delete for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
*                s_kzpod   FOR gv_kzpod DEFAULT 'A',
*<-- End of delete for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
                s_wadat   FOR gv_wadat_ist OBLIGATORY ,
                s_podat   FOR gv_podat,
                s_vbeln   FOR gv_vbeln, "Sales Order
                s_kunag   FOR gv_kunag,
                s_kunnr   FOR gv_kunnr.
SELECTION-SCREEN END OF BLOCK b1.
*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-s02.
PARAMETERS: p_rel AS CHECKBOX,  " POD Relevant
            p_conf AS CHECKBOX. " POD Confirmed
SELECTION-SCREEN END OF BLOCK b2.
* Begin of change for sctask:SCTASK0745122-> Intercompany Billing Accrual by U033876 E1DK939333
SELECTION-SCREEN BEGIN OF BLOCK b2_a WITH FRAME TITLE text-s04.
PARAMETERS: p_inter AS CHECKBOX.  " Intercompany Billing Accrual
SELECTION-SCREEN END OF BLOCK b2_a.
* End of change for sctask:SCTASK0745122-> Intercompany Billing Accrual by U033876
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-s03.
PARAMETERS: p_mode AS CHECKBOX, " Background mode execution
            p_path TYPE string. " AL11 file path
SELECTION-SCREEN END OF BLOCK b3.
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
