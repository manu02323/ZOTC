*&---------------------------------------------------------------------*
** PROGRAM    : ZOTCR0141O_CONVERT_SALES_ORDER                         *
* TITLE       :  Reconciliation Report                                 *
*                                                                      *
* DEVELOPER  :  Khushboo Mishra                                        *
* OBJECT TYPE:  ALV report                                             *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_CDD_0141                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  This report will be used to display data after loading *
*               the sales orders through idocs                         *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT  DESCRIPTION                        *
* ===========  ========  ========== ===================================*
* 05/16/2016   KMISHRA   E1DK917543 Initial Development
* ===========  ========  ========== ===================================*
*&---------------------------------------------------------------------*

REPORT zotcr0141o_convert_sales_order NO STANDARD PAGE HEADING
                                  LINE-SIZE 132
                                  LINE-COUNT 70
                                  MESSAGE-ID zotc_msg.

************************************************************************
*               INCLUDE DECLARATION
************************************************************************
* TOP INCLUDE
INCLUDE zotcn0141o_convert_sales_top. " Include ZOTCN0007O_CONVERT_SALES_TOP
*INCLUDE zotcn0141o_convert_sales_top.
* Selection Screen Include
INCLUDE zotcn0141o_convert_sales_sel. " Include ZOTCN0007O_CONVERT_SALES_SEL
*INCLUDE zotcn0141o_convert_sales_sel.
* Include for all subroutines
INCLUDE zotcn0141o_convert_sales_form. " Include ZOTCN0007O_CONVERT_SALES_FORM
*INCLUDE zotcn0141o_convert_sales_form.

*----------------------------------------------------------------------*
*     I N I T I A L I Z A T I O N
*----------------------------------------------------------------------*
INITIALIZATION.

*&--Set Default values
  PERFORM f_set_default_val.

*&--Program Name
  gv_prog_name = sy-repid.

*----------------------------------------------------------------------*
*---------AT  SELECTIOM - SCREEN---------------------------------------*
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
*  Combination validation on Sales organisation,Distt channel and Division
  IF s_vkorg[] IS NOT INITIAL.
    IF s_vtweg[] IS NOT INITIAL.
      IF p_spart IS NOT INITIAL.
        PERFORM f_vkorg_vtweg_spart_validation USING s_vkorg[]
                                                     s_vtweg[]
                                                     p_spart.
      ENDIF. " IF p_spart IS NOT INITIAL
    ENDIF. " IF s_vtweg[] IS NOT INITIAL
  ENDIF. " IF s_vkorg[] IS NOT INITIAL

AT SELECTION-SCREEN ON s_vkorg.
*  Sales Organization validation
  IF s_vkorg[] IS NOT INITIAL.
    PERFORM f_vkorg_validation USING s_vkorg[].
  ENDIF. " IF s_vkorg[] IS NOT INITIAL

AT SELECTION-SCREEN ON s_vtweg.
* Distribution Channel validation
  IF s_vtweg[] IS NOT INITIAL.
    PERFORM f_vtweg_validation USING s_vtweg[].
  ENDIF. " IF s_vtweg[] IS NOT INITIAL

AT SELECTION-SCREEN ON s_auart.
*  Sales Document Type validation
  IF s_auart[] IS NOT INITIAL.
    PERFORM f_auart_validation USING s_auart[].
  ENDIF. " IF s_auart[] IS NOT INITIAL

AT SELECTION-SCREEN ON p_spart.
*  Division validation
  PERFORM f_spart_validation USING p_spart.

*----------------------------------------------------------------------*
*     S T A R T - O F - S E L E C T I O N
*----------------------------------------------------------------------*
START-OF-SELECTION.

*&--Data selection
  PERFORM f_get_data.

*&--Data processing
  PERFORM f_data_processing CHANGING i_final.

*----------------------------------------------------------------------*
*     E N D - O F - S E L E C T I O N
*----------------------------------------------------------------------*
END-OF-SELECTION.


*--Report display
  IF i_final[] IS NOT INITIAL.
    PERFORM f_output_display USING i_final.
  ELSE. " ELSE -> IF i_final[] IS NOT INITIAL
    MESSAGE i115. " No data found for the input given in selection screen
    LEAVE LIST-PROCESSING.
  ENDIF. " IF i_final[] IS NOT INITIAL
