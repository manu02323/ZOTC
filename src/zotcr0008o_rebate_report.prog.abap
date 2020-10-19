*&---------------------------------------------------------------------*
*& Report  ZOTCR0008O_REBATE_REPORT
*&
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCR0008O_REBATE_REPORT                               *
* TITLE      :  REBATE REPORT (PRICING)                                *
* DEVELOPER  :  ROHIT VERMA                                            *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0008_REBATE_REPORT                               *
*----------------------------------------------------------------------*
* DESCRIPTION: This Report can be utilized by users to track Billing   *
*               Documents created on a specific date or within a date  *
*               range. The report will provide all key information     *
*               about the rebates.                                     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 09-MAR-2012 RVERMA   E1DK901226 INITIAL DEVELOPMENT                  *
*&---------------------CR#6--------------------------------------------*
* 17-APR-2012 RVERMA   E1DK901226 Addition of fields Payer Desc,       *
*                                 Ship-to-Party Desc, Material Desc,   *
*                                 Rebate Basis, Currency Key in ALV    *
*                                 output. Changes in the fetching      *
*                                 logic of Ship-to-Party Value         *
* 21-MAY-2012 RVERMA   E1DK901226 Fetching field for condition currency*
*                                 changed from WAERS to KWAEH          *
*&---------------------CR#34-------------------------------------------*
* 12-JUN-2012 RVERMA   E1DK901226 Adding fields KVGR1(GPO Code) & KVGR2*
*                                 (IDN Code) and their description     *
*                                 fields in the report and removing    *
*                                 leading zeroes from customer material*
*                                 field and dividing dividing          *
*                                 KONV-KBETR by 10.                    *
*&---------------------CR#67-------------------------------------------*
* 26-JUL-2012 RVERMA   E1DK901226 Adding fields Sold-to-Party,         *
*                                 Sold-to-Party Description,           *
*                                 Product Division, Sales Amount fields*
*                                 in the report.                       *
*&---------------------------------------------------------------------*

REPORT  zotcr0008o_rebate_report NO STANDARD PAGE HEADING
                                 LINE-SIZE 132
                                 MESSAGE-ID zotc_msg.

************************************************************************
*          DATA DECLARATION INCLUDE                                    *
************************************************************************
INCLUDE zotcn0008o_rebate_report_top.

************************************************************************
*          SELECTION SCREEN DECLARATION INCLUDE                        *
************************************************************************
INCLUDE zotcn0008o_rebate_report_scr.

************************************************************************
*          SUBROUTINE INCLUDE                                          *
************************************************************************
INCLUDE zotcn0008o_rebate_report_form.

*----------------------------------------------------------------------*
*     A T  S E L E C T I O N - S C R E E N
*----------------------------------------------------------------------*

AT SELECTION-SCREEN ON s_bukrs.
  IF s_bukrs IS NOT INITIAL.
    PERFORM f_companycode_validation.
  ENDIF.

AT SELECTION-SCREEN ON s_vkorg.
  IF s_vkorg IS NOT INITIAL.
    PERFORM f_salesorg_validation.
  ENDIF.

AT SELECTION-SCREEN ON s_fkart.
  IF s_fkart IS NOT INITIAL.
    PERFORM f_billdoctype_validation.
  ENDIF.

AT SELECTION-SCREEN ON s_vbeln.
  IF s_vbeln IS NOT INITIAL.
    PERFORM f_billdocno_validation.
  ENDIF.

AT SELECTION-SCREEN ON s_kunrg.
  IF s_kunrg IS NOT INITIAL.
    PERFORM f_payer_validation.
  ENDIF.

AT SELECTION-SCREEN ON s_kschl.
  IF s_kschl IS NOT INITIAL.
    PERFORM f_condtype_validation.
  ENDIF.

*----------------------------------------------------------------------*
*     I N I T I A L I Z A T I O N
*----------------------------------------------------------------------*
INITIALIZATION.

*&--Program Name
  gv_repid = sy-repid.

*----------------------------------------------------------------------*
*     S T A R T - O F - S E L E C T I O N
*----------------------------------------------------------------------*
START-OF-SELECTION.

*&--Data selection
  PERFORM f_data_selection.

*&--Data processing
  PERFORM f_data_processing.

*----------------------------------------------------------------------*
*     E N D - O F - S E L E C T I O N
*----------------------------------------------------------------------*
END-OF-SELECTION.

*&--Report display
  PERFORM f_output_display.
