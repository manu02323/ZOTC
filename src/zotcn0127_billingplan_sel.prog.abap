*&--------------------------------------------------------------------------------*
*& Report zotcn0127_billingplan_exreport
*&--------------------------------------------------------------------------------*
***********************************************************************************
* PROGRAM    :  zotcr0127_billingplan_exreport                                    *
* TITLE      :  Billing plan exception report                                     *
* DEVELOPER  :  Trupti Raikar                                                     *
* OBJECT TYPE:  REPORT                                                            *
* SAP RELEASE:  SAP ECC 6.0                                                       *
*---------------------------------------------------------------------------------*
* WRICEF ID:    OTC_RDD_0127_BILLING_PLAN_EXCEPTION_REPORT                        *
*---------------------------------------------------------------------------------*
* DESCRIPTION: Billing plan exception report                                      *
*---------------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                           *
*=================================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                                     *
* =========== =======  ========== ================================================*
* 20-Nov-2018 U101734  E1DK939517 SCTASK0754502:INITIAL DEVELOPMENT FOR R5 RELEASE*
*&--------------------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

SELECT-OPTIONS: s_fpart FOR gv_fpart OBLIGATORY, "Billing Plan Type
                s_fplnr FOR gv_fplnr,            "Billing Plan Number
                s_vbeln FOR gv_vbeln.            "Sales Order
PARAMETERS: p_endat TYPE endat OBLIGATORY DEFAULT sy-datum, " Expiration date for vacancy advertisement
            p_email TYPE ad_smtpadr OBLIGATORY,             " E-Mail Address
            p_log  AS CHECKBOX DEFAULT 'X'.                "Check box for ALV
SELECTION-SCREEN END OF BLOCK b1.
