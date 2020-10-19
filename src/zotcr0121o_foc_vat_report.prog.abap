*&---------------------------------------------------------------------*
*& Report  ZOTCR0121O_FOC_VAT_REPORT
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

REPORT zotcr0121o_foc_vat_report NO STANDARD PAGE HEADING
                                 MESSAGE-ID zotc_msg
                                 LINE-SIZE 132.

*----------------------------------------------------------------------*
*                     INCLUDES                                         *
*----------------------------------------------------------------------*
*&--Global Data Include
INCLUDE zotcn0121o_foc_vat_report_top. " Include ZOTCN0121O_FOC_VAT_REPORT_TOP
*&--Selection Screen Include
INCLUDE zotcn0121o_foc_vat_report_sel. " Include ZOTCN0121O_FOC_VAT_REPORT_SEL
*&--Subroutine Include
INCLUDE zotcn0121o_foc_vat_report_sub. " Include ZOTCN0121O_FOC_VAT_REPORT_SUB

*----------------------------------------------------------------------*
*                     INITIALIZATION                                   *
*----------------------------------------------------------------------*
INITIALIZATION.

* Default values to the Selection screen
  PERFORM f_initialization.

* Get the EMI entries
  PERFORM f_get_emi_entries CHANGING i_enh_status.

*----------------------------------------------------------------------*
*                 AT SELECTION SCREEN ON                               *
*----------------------------------------------------------------------*
* Validation for Sales Org
AT SELECTION-SCREEN ON p_vkorg.
  PERFORM f_validate_vkorg USING i_enh_status.

* Validation for Distribution Channel
AT SELECTION-SCREEN ON s_vtweg.
  IF s_vtweg IS NOT INITIAL.
    PERFORM f_validate_vtweg.
  ENDIF. " IF s_vtweg IS NOT INITIAL

* Validation for Delivery Type
AT SELECTION-SCREEN ON s_lfart.
  PERFORM f_validate_lfart USING s_lfart[].

* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
* Validation for FOC Delivery Type
AT SELECTION-SCREEN ON s_focdlv.
  PERFORM f_validate_lfart USING s_focdlv[].

* Validation for Plant with Sales Org
AT SELECTION-SCREEN ON s_werks.
  PERFORM f_validate_werks.
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

* Validation for Sales Order Type
AT SELECTION-SCREEN ON s_auart.
  IF s_auart IS NOT INITIAL.
    PERFORM f_validate_auart.
  ENDIF. " IF s_auart IS NOT INITIAL

* Validation for Item Category
AT SELECTION-SCREEN ON s_pstyv.
  IF s_pstyv IS NOT INITIAL.
    PERFORM f_validate_pstyv.
  ENDIF. " IF s_pstyv IS NOT INITIAL

* Validation for Pricing Type
AT SELECTION-SCREEN ON s_prsfd.
  IF s_prsfd IS NOT INITIAL.
    PERFORM f_validate_prsfd.
  ENDIF. " IF s_prsfd IS NOT INITIAL

* Validation for Sold-To Partner
AT SELECTION-SCREEN ON s_kunag.
  IF s_kunag IS NOT INITIAL.
    PERFORM f_validate_kunag.
  ENDIF. " IF s_kunag IS NOT INITIAL

* Validation for Ship-To Partner
AT SELECTION-SCREEN ON s_kunwe.
  IF s_kunwe IS NOT INITIAL.
    PERFORM f_validate_kunwe.
  ENDIF. " IF s_kunwe IS NOT INITIAL

*----------------------------------------------------------------------*
*                     START OF SELECTION                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.

* Fetch the data and build final table for display
  PERFORM f_get_data_for_display CHANGING i_final.

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
