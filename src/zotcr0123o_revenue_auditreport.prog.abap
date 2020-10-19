*&---------------------------------------------------------------------*
*& Report  ZOTCR0123O_REVENUE_AUDITREPORT
*&---------------------------------------------------------------------*
* PROGRAM    :  ZOTCR0121O_REVENUE_AUDITREPORT                         *
* TITLE      :  Revenue Report for Audit                               *
* DEVELOPER  :  Sumanpreet Kaur                                        *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  : D3_OTC_RDD_0123                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: Revenue Report for Audit                                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER    TRANSPORT     DESCRIPTION                      *
* =========== ======== ========== =====================================*
* 07-MAY-2018 U034334  E1DK936497 Initial Development                  *
*&---------------------------------------------------------------------*

REPORT zotcr0123o_revenue_auditreport NO STANDARD PAGE HEADING
                                      MESSAGE-ID zotc_msg
                                      LINE-SIZE 132.

*----------------------------------------------------------------------*
*                     INCLUDES                                         *
*----------------------------------------------------------------------*
*&--Global Data Include
INCLUDE zotcr0123o_revenue_audit_top. " Include ZOTCR0123O_REVENUE_AUDIT_TOP
*&--Selection Screen Include
INCLUDE zotcr0123o_revenue_audit_sel. " Include ZOTCR0123O_REVENUE_AUDIT_SEL
*&--Subroutine Include
INCLUDE zotcr0123o_revenue_audit_sub. " Include ZOTCR0123O_REVENUE_AUDIT_SUB

*----------------------------------------------------------------------*
*                     INITIALIZATION                                   *
*----------------------------------------------------------------------*
INITIALIZATION.

* Default values to the Selection screen
  PERFORM f_initialization.

* Get the EMI entries
  PERFORM f_get_emi_entries CHANGING i_enh_status.

*----------------------------------------------------------------------*
*                 AT SELECTION SCREEN OUTPUT                           *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
* Modify the screen based on User action
  PERFORM f_modify_screen.

*----------------------------------------------------------------------*
*                 AT SELECTION SCREEN ON VALUE REQUEST                 *
*----------------------------------------------------------------------*
* For Output File on Application Server
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_afile.
  PERFORM f_help_as_path CHANGING p_afile.

*----------------------------------------------------------------------*
*                 AT SELECTION SCREEN ON                               *
*----------------------------------------------------------------------*
* Validation for Company Code
AT SELECTION-SCREEN ON s_bukrs.
  PERFORM f_validate_bukrs.

* Validation for Sales Document
AT SELECTION-SCREEN ON s_vbeln.
  IF s_vbeln IS NOT INITIAL.
    PERFORM f_validate_vbeln.
  ENDIF. " IF s_vbeln IS NOT INITIAL

* Validation for G/L Account
AT SELECTION-SCREEN ON s_sakrv.
  IF s_sakrv IS NOT INITIAL.
    PERFORM f_validate_sakrv.
  ENDIF. " IF s_sakrv IS NOT INITIAL

* Validate Document Type
AT SELECTION-SCREEN ON s_blart.
  IF s_blart IS NOT INITIAL.
    PERFORM f_validate_blart.
  ENDIF. " IF s_blart IS NOT INITIAL

*----------------------------------------------------------------------*
*                     START OF SELECTION                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.

* Check application server file provided for background mode
  IF rb_backg = abap_true AND
     p_afile IS INITIAL.
    MESSAGE i010 DISPLAY LIKE c_err. " Application server file has not been entered
    LEAVE LIST-PROCESSING.
  ELSEIF rb_backg = abap_true AND
    p_afile IS INITIAL.
* Check the file should be '.TXT'
    PERFORM f_check_extension.
  ENDIF. " IF rb_backg = abap_true AND

* Fetch the data and build final table for display
  PERFORM f_get_data_for_display  CHANGING i_final.

*----------------------------------------------------------------------*
*                     END OF SELECTION                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.

* Populate the field catalogue
  PERFORM f_prepare_fieldcat.

* Display the output
  PERFORM f_display_output USING i_fieldcat
                                 i_final.

* Free global tables
  FREE: i_final,
        i_fieldcat.
