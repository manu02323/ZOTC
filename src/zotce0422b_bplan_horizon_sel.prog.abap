*&---------------------------------------------------------------------*
*&  Include           ZOTCE0422B_BPLAN_HORIZON_SEL
*&---------------------------------------------------------------------*
***********************************************************************************
* PROGRAM    :  ZOTCE0422B_BILLINGPLAN_HORIZON                                    *
* TITLE      :  Wrapper to feed sales orders/billing plans to standard SAP program*
* DEVELOPER  :  Amlan J Mohapatra                                                 *
* OBJECT TYPE:  REPORT                                                            *
* SAP RELEASE:  SAP ECC 6.0                                                       *
*---------------------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0422_BILLING_PLAN_HORIZON_WRAPPER_for_V.07             *
*---------------------------------------------------------------------------------*
* DESCRIPTION: This report is a wrapper program for Transaction V.07 for reducing *
*              the credit exposure up to the next 'billing due date'              *
*---------------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                           *
*=================================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                                     *
* =========== =======  ========== ================================================*
* 22-Oct-2018 AMOHAPA  E1DK939308 SCTASK0750474:INITIAL DEVELOPMENT FOR R5 RELEASE*
*&--------------------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

SELECT-OPTIONS: s_fpart FOR gv_fpart OBLIGATORY, "Billing Plan Type
                s_fplnr FOR gv_fplnr,            "Billing Plan Number
                s_vbeln FOR gv_vbeln.            "Sales Order
PARAMETERS: p_endat TYPE endat OBLIGATORY DEFAULT sy-datum, " Expiration date for vacancy advertisement
            p_email TYPE ad_smtpadr OBLIGATORY,             " E-Mail Address
            p_log  AS CHECKBOX DEFAULT 'X'.                "Check box for ALV
SELECTION-SCREEN END OF BLOCK b1.
