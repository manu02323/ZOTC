*&---------------------------------------------------------------------*
*& Report  ZOTCR0028O_PRICING_REPORT
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCR0028O_PRICING_REPORT_NEW                          *
* TITLE      :  Pricing Report for Mass Price Upload                   *
* DEVELOPER  :  Vinita Choudhary                                       *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_RDD_0028_Pricing Report for Mass Price Upload   *
*----------------------------------------------------------------------*
* DESCRIPTION: This Report provide a interactive pricing report, which *
*              will be having downloadable feature. User can modify the*
*              values and use the same file for price mass upload.     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 22-Jul-2015 VCHOUDH  E2DK914250  INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
*01-Dec-2015  VCHOUDH  E2DK916259  Defect 1264 - Short Dump for        *
*                                  multiple customers in selection
*&---------------------------------------------------------------------*
*03-May-2016  SAGARWA1  E2DK917740 Defect 1519 - Multiple Changes      *
*                                  Req 1:Check for authorization object*
*                                  V_KONH_VKO & V_KONH_VKS.            *
*                                  Req 2:System should pick the record *
*                                  for territory based on the effective*
*                                  date of territory assignment.       *
*                                  Req 3:System should ignore territory*
*                                  assignment table entries if there is*
*                                  no value maintained and user should *
*                                  be able to fetch the record with    *
*                                  blank Territory field in the report.*
*&---------------------------------------------------------------------*

REPORT zotcr0028o_pricing_report_new   MESSAGE-ID zotc_msg.

*---------------------------------------------------------------------*
*            DATA DECLARATION
*---------------------------------------------------------------------*
INCLUDE zotcn0028o_pricing_rep_top. " Include FOR DATA DECLARATION
*---------------------------------------------------------------------*
*             SELECTION SCREEN
*---------------------------------------------------------------------*
INCLUDE zotcn0028o_pricing_rep_ss. " Include FOR SELECTION SCREEN
*---------------------------------------------------------------------*
*             SUBROUTINES
*---------------------------------------------------------------------*
INCLUDE zotcn0028o_pricing_rep_sub. " Include FOR SUBROUTINES

*--------------------------------------------------------------------*
*    At Selection-Screen.
*--------------------------------------------------------------------*
AT SELECTION-SCREEN.
* This subroutine performs the required validation on the selection screen fields.
  PERFORM f_validation.

*& --> Begin of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1

AT SELECTION-SCREEN ON p_kschl.
* This subroutine performs the required authorization checks for the transaction
* based on the condition type
  PERFORM f_authorization_check_kschl.

*& <-- End   of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1

AT SELECTION-SCREEN OUTPUT.
* Check for Sales rep to display or not .
*  if p_kschl is not INITIAL and p_tab is not INITIAL.
  PERFORM get_sales_rep_info.
*endif.

* This subroutine modify the input screen based on the radio button selected.
  PERFORM f_modify_screen.

  IF p_afpath IS NOT INITIAL AND p_afile IS NOT INITIAL.

    PERFORM f_get_full_file_path USING p_afpath
                                 CHANGING   p_afile
                                  p_affile.


  ENDIF. " IF p_afpath IS NOT INITIAL AND p_afile IS NOT INITIAL
* F4 help for condition table
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_tab.
* get the condition tables, based on the condition type selected.
  PERFORM f_get_condition_tab.

* F4 help for Presentation server file path
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM f_get_pres_file.

* F4 help for Application server file path.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_afpath.
  PERFORM f_get_app_file CHANGING p_afpath.


*--------------------------------------------------------------------*
*     Start-Of-Selection.
*--------------------------------------------------------------------*
START-OF-SELECTION.
* Get the condition table information.
  PERFORM f_get_details.

* Create the dynamic structures, based on the condition table.
  PERFORM f_create_structures.

* Creates a free selection input screen, where the user can enter
* inputs based on the selected condition table.
  PERFORM f_free_selection.

*& --> Begin of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1

* This subroutine performs the required authorization checks for the transaction
* based on the sales organization, distribution channet and division
  PERFORM f_authorization_check USING wa_dyns-trange.

*& <-- End   of Insert for D2_OTC_RDD_0028_Defect#1519 by SAGARWA1


* Fetch the relevant data based on the condition table and additional input given.
  PERFORM f_fetch_data.

* Display the data in ALV format
  IF p_chk1 = abap_true.
    PERFORM f_display_data.
  ENDIF. " IF p_chk1 = abap_true
