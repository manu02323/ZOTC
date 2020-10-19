*&--------------------------------------------------------------------------------*
*& Report zotcr0127_billingplan_exreport
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
REPORT zotcr0127_billingplan_exreport NO STANDARD PAGE HEADING
                                      LINE-SIZE 132
                                      LINE-COUNT 145
                                      MESSAGE-ID zotc_msg.

************************************************************************
*          DATA DECLARATION INCLUDE                                    *
************************************************************************

INCLUDE zotcn0127_billingplan_top. " Include zotcn0127_billingplan_TOP

************************************************************************
*          SELECTION SCREEN DECLARATION INCLUDE                        *
************************************************************************

INCLUDE zotcn0127_billingplan_sel. " Include zotcn0127_billingplan_SEL

************************************************************************
*          SUBROUTINE INCLUDE                                          *
************************************************************************

INCLUDE zotcn0127_billingplan_sub. " Include zotcn0127_billingplan_SUB

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_fpart-low.

  PERFORM f_f4_fpart.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_fpart-high.

  PERFORM f_f4_fpart.

AT SELECTION-SCREEN ON s_fpart.

  PERFORM f_validate_billing_plan_type.

AT SELECTION-SCREEN ON s_fplnr.
  IF s_fplnr IS NOT INITIAL.
    PERFORM f_validate_billing_plan_number.
  ENDIF. " IF s_fplnr IS NOT INITIAL

AT SELECTION-SCREEN ON s_vbeln.
  IF s_vbeln IS NOT INITIAL.
    PERFORM f_validate_sales_doc.
  ENDIF. " IF s_vbeln IS NOT INITIAL


AT SELECTION-SCREEN ON p_email.

  IF p_email IS NOT INITIAL.
    PERFORM f_validate_email.
  ENDIF. " IF p_email IS NOT INITIAL

START-OF-SELECTION.
* ---> Begin of Delete for OTC_RDD_0127 for version 2.1 changes by U101734 on 20-Dec-2018 SCTASK0754502
*  PERFORM f_retrive_results.
* ---> End of Delete for OTC_RDD_0127 for version 2.1 changes by U101734 on 20-Dec-2018 SCTASK0754502
* ---> Begin of Insert for OTC_RDD_0127 for version 2.1 changes by U101734 on 20-Dec-2018 SCTASK0754502
  PERFORM f_retrive_records.
* ---> End of Insert for OTC_RDD_0127 for version 2.1 changes by U101734 on 20-Dec-2018 SCTASK0754502

  IF i_tab[] IS NOT INITIAL.
* "sending mail from the program
    IF p_log EQ abap_true.
      PERFORM f_build_xls_data_table.

      PERFORM f_populate_email_msg_body.

* Send file by email as .xls speadsheet
      PERFORM f_send_file_as_email_attachmt
                                    USING p_email
                                          'Evergreen billing plan exception report'(021)
                                          'XLS'(022)
                                          'Exceptions'(023)
                                          'Exceptions'(023)
                                          ' '
                                          ' '
                                 CHANGING gv_error
                                          gv_reciever.

*   Instructs mail send program for SAPCONNECT to send email(rsconn01)
      PERFORM f_initiate_mail_execute_prog.

    ENDIF. " IF p_log EQ abap_true
* display BOM materials
    CALL  SCREEN 9002.

  ELSE. " ELSE -> IF i_tab[] IS NOT INITIAL
 "If no records found to populate the final internal table
    MESSAGE i000 WITH 'No exception found'(027).
*    LEAVE TO TRANSACTION c_tx.   " Defect 8147
    LEAVE LIST-PROCESSING.   " Defect 8147
  ENDIF. " IF i_tab[] IS NOT INITIAL

END-OF-SELECTION.
  FREE: i_tab,
        i_fieldcat,
        i_t_message,
        i_t_attach.
