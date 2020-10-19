************************************************************************
* PROGRAM    :  ZOTCR0043O_POD_REPORT                                  *
* TITLE      :  OTC_RDD_0043_Comprehensive POD Report                  *
* DEVELOPER  :  Sneha Mukherjee                                        *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0043_Comprehensive POD Report                    *
*----------------------------------------------------------------------*
* DESCRIPTION: This report contains the POD relevant information which *
*              will improve the Business operations and will address to*
*              the issue of not automatically generated PODs.          *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 26-FEB-14  SMUKHER   E1DK912803  INITIAL DEVELOPMENT(Defect#1149)    *
* 09-APR-14  SMUKHER   E1DK912803  ADDITIONAL CHANGES ON CR#1149       *
* 13-MAY-14  SMUKHER   E1DK913409  ADDITION OF NEW FIELD 'SALES OFFICE'*
* 29-MAY-17  U034229   E1DK928313  Defect# 2933: 1)Actual PGI date and *
*                                  Sales organization as mandatory     *
*                                  field.                              *
*                                  2) Profit Center, Serial Number     *
*                                  Profile & POD Date are added in the *
*                                  output.                             *
*                                  3) Sales Org, Dist.Channel, Div,    *
*                                  Del.Type are made as range.         *
*                                  4) Performance Tuning.              *
* 10-Jul-18 U103565 E1DK937670  Defect #6638 1) Addition of new fields *
*                                       Higher Level HU,Tracking Number*
*                                       ESS carrier delivery date      *
*                                       Planned Carrier delivery date  *
*                                       Transit time from route        *
*                                       Installable delivery flag      *
*                                       Customer Acceptance date       *
*                                       Error Message                  *
*                                    2) "POD Relevant" is changed to   *
*                                     "Pending POD" on selection screen*
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE text-001.
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*select-options s_pgi_ac for gv_wadat_ist.  "Actual PGI Date
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
SELECT-OPTIONS s_pgi_ac FOR gv_wadat_ist OBLIGATORY. "Actual PGI Date
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

SELECT-OPTIONS s_pgi_pn FOR gv_wadat_ist. "Planned PGI Date
SELECTION-SCREEN END OF BLOCK a1.

SELECTION-SCREEN BEGIN OF BLOCK a2 WITH FRAME TITLE text-002.
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*parameters p_vkorg type vkorg.             "Sales Organization   "09-APR-14 removed mandatory check.
*parameters p_vtweg type vtweg.             "Distribution Channel "09-APR-14 removed mandatory check.
*parameters p_spart type spart .            "Division             "09-APR-14 removed mandatory check.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*&--Making Sales Org, Dist.Channel & Division as range
SELECT-OPTIONS: s_vkorg FOR gv_vkorg OBLIGATORY, "Sales Organization
                s_vtweg FOR gv_vtweg,            "Distribution Channel
                s_spart FOR gv_spart.            "Division
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
SELECT-OPTIONS s_werks FOR gv_werks . "Plant
**&& -- BOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
SELECT-OPTIONS s_vkbur FOR gv_vkbur. "Sales Office
**&& -- EOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
SELECTION-SCREEN END OF BLOCK a2.

SELECTION-SCREEN BEGIN OF BLOCK a3 WITH FRAME TITLE text-003.
SELECT-OPTIONS s_vbeln FOR gv_vbeln. "Delivery Number
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 08-Jun-2017
*PARAMETERS p_lfart TYPE likp-lfart DEFAULT 'ZLF'. "Delivery Type  "09-APR-14 removed mandatory check.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 08-Jun-2017
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 08-Jun-2017
SELECT-OPTIONS s_lfart FOR gv_lfart.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 08-Jun-2017
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
SELECT-OPTIONS s_route FOR gv_route. "Route
SELECT-OPTIONS s_vsbed FOR gv_vsbed. "Shipping Conditions
SELECT-OPTIONS s_kunag FOR gv_kunag. "Sold-to-party
SELECT-OPTIONS s_kunnr FOR gv_kunnr. "Ship-to-party
SELECTION-SCREEN END OF BLOCK a3.

SELECTION-SCREEN BEGIN OF BLOCK a4 WITH FRAME TITLE text-004.
SELECT-OPTIONS s_venum FOR gv_venum. "Handling Unit Number
SELECT-OPTIONS s_vbelnp FOR gv_vbelnp. "Purchase Order Number
SELECT-OPTIONS s_vbelns FOR gv_vbelns. "Sales Order Number
SELECTION-SCREEN END OF BLOCK a4.

SELECTION-SCREEN BEGIN OF BLOCK a5 WITH FRAME TITLE text-005.
PARAMETERS : rb_rel RADIOBUTTON GROUP rad   " POD Relevant radio button
             DEFAULT 'X',
             rb_conf RADIOBUTTON GROUP rad. " POD Confirmed radio button
SELECTION-SCREEN END OF BLOCK a5.
