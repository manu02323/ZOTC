*&--------------------------------------------------------------------------------*
*& Report ZOTCE0422B_BILLINGPLAN_HORIZON
*&--------------------------------------------------------------------------------*
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
REPORT zotce0422b_billingplan_horizon NO STANDARD PAGE HEADING
                                      LINE-SIZE 132
                                      LINE-COUNT 145
                                      MESSAGE-ID zotc_msg.

************************************************************************
*          DATA DECLARATION INCLUDE                                    *
************************************************************************

INCLUDE zotce0422b_bplan_horizon_top. " Include ZOTCE0422B_BPLAN_HORIZON_TOP

************************************************************************
*          SELECTION SCREEN DECLARATION INCLUDE                        *
************************************************************************

INCLUDE zotce0422b_bplan_horizon_sel. " Include ZOTCE0422B_BPLAN_HORIZON_SEL

************************************************************************
*          SUBROUTINE INCLUDE                                          *
************************************************************************

INCLUDE zotce0422b_bplan_horizon_sub. " Include ZOTCE0422B_BPLAN_HORIZON_SUB

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_fpart-low.

  PERFORM f_f4_fpart.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_fpart-high.

  PERFORM f_f4_fpart.


AT SELECTION-SCREEN ON s_fpart.

  PERFORM f_validate_billing_plan_type.

AT SELECTION-SCREEN ON s_vbeln.
  IF s_vbeln IS NOT INITIAL.
    PERFORM f_validate_sales_doc.
  ENDIF. " IF s_vbeln IS NOT INITIAL


AT SELECTION-SCREEN ON p_email.

  IF p_email IS NOT INITIAL.
    PERFORM f_validate_email.
  ENDIF. " IF p_email IS NOT INITIAL

START-OF-SELECTION.
 "Getting records from the FPLA table using the selection screen parameter
  PERFORM f_get_data_fpla CHANGING i_fpla.

 "Getting FPLT entries before Update the order
  PERFORM f_get_bplan_before USING    i_fpla
                             CHANGING i_fplt_before.
 "Getting the logs from the standard transaction V.07
  PERFORM f_get_final USING    i_fpla
                      CHANGING i_log.
 "Getting FPLT entries after update the order
  PERFORM f_get_bplan_after  USING    i_fplt_before
                             CHANGING i_fplt_after.

 "Getting the correct log for sales order

  PERFORM f_get_change_log  USING    i_fplt_after
                            CHANGING i_log
                                     i_fpla.
 "If we have some recrods in Log table then we are going to populate it
 "and send the mail if it is mentioned in the selection screen
  IF i_log IS NOT INITIAL.
 "Getting sales Organization and Sale document type from VBAK

    PERFORM f_get_vbak CHANGING i_log.
 "sending mail from the program
    PERFORM f_send_log_to_email USING i_log.

    IF p_log IS NOT INITIAL.
 "Pereparing for Fieldcatalog
      PERFORM f_prepare_fieldcat CHANGING i_fieldcat[].
 "Populating Final Table
      PERFORM f_display_alv USING i_fieldcat[]
                                   i_log[].
    ENDIF. " IF p_log IS NOT INITIAL
  ELSE. " ELSE -> IF i_log IS NOT INITIAL
 "If no records found to populate the final internal table
    MESSAGE i138.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF i_log IS NOT INITIAL
