*&---------------------------------------------------------------------*
*&  Include           ZOTCN0121O_FOC_VAT_REPORT_SEL
*&---------------------------------------------------------------------*
* PROGRAM    :  ZOTCR0121O_FOC_VAT_REPORT                              *
* TITLE      :  FOC VAT Report                                         *
* DEVELOPER  :  Sumanpreet Kaur                                        *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  : D3_OTC_RDD_0121                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: FOC Report for VAT                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER    TRANSPORT     DESCRIPTION                      *
* =========== ======== ========== =====================================*
* 20-APR-2018 U034334  E1DK936059 Initial Development                  *
* 16-MAY-2018 U034334  E1DK936059 Defect_6082: Include Drop-Ship Sales *
*                                 Orders in the ALV, add Inv Unit Price*
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS s_date  FOR  gv_date OBLIGATORY. " Goods Issue Date
PARAMETERS :   p_vkorg TYPE vkorg   OBLIGATORY, " Sales Organization
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
               p_waerk TYPE waerk   OBLIGATORY DEFAULT c_eur.
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
SELECTION-SCREEN END OF BLOCK b1.

* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE text-042.
SELECT-OPTIONS : s_focdlv  FOR  gv_lfart OBLIGATORY, " Delivery Type
                 s_werks   FOR  gv_werks OBLIGATORY. " Plant
SELECTION-SCREEN END OF BLOCK a1.
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
SELECT-OPTIONS: s_vtweg FOR gv_vtweg,                              " Distribution Channel
                s_lfart FOR gv_lfart OBLIGATORY NO INTERVALS,      " Delivery Type
                s_auart FOR gv_auart,                              " Sales Order Type
                s_pstyv FOR gv_pstyv,                              " Item category
                s_prsfd FOR gv_prsfd NO INTERVALS DEFAULT c_prsfd, " Pricing Type
                s_kunag FOR gv_kunag,                              " Sold-to party
                s_kunwe FOR gv_kunwe.                              " Ship-to party

PARAMETERS : cb_noqty AS CHECKBOX DEFAULT 'X'. " Exclude 0 qty
SELECTION-SCREEN END OF BLOCK b2.
