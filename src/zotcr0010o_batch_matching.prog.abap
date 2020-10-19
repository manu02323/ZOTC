*&---------------------------------------------------------------------*
*& Report  ZOTCR0010O_BATCH_MATCHING
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCR0010O_BATCH_MATCHING                              *
* TITLE      :  Batch Matching Report                                  *
* DEVELOPER  :  Pallavi Gupta                                          *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0010_BATCH_MATCHING Report                       *
*----------------------------------------------------------------------*
* DESCRIPTION:  This Report will display a prior Customer order history*
*               in details and proposes a list of products including   *
*               inventory and compatibility code based on query of     *
*               product group.                                         *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 16-Jul-2012 PGUPTA2  E1DK901335 INITIAL DEVELOPMENT                  *
* 06-AUG-2014 PROUT    E1DK913381 INC0140560 / CR1286:                 *
*                                 Updated selection screen with extra  *
*                                 checkbox 'Without Order History'. If *
*                                 the indicator got checked sales ord. *
*                                 details for the customer will not be *
*                                 displayed in the report output. Also *
*                                 Material Number and Batch Number will*
*                                 have multiple selections. If the     *
*                                 indicator is not checked then        *
*                                 Material No and Batch No will have   *
*                                 single entry and sales order history *
*                                 for the customer needs to be fetched *
*                                 for the customer in the report o/p.  *
* 16-SEP-2014 SPAUL2   E1DK913381 INC0140560 / CR1286:                 *
*                                 Added some additional requirements   *
*                                 as per business user demand.         *
*                                 1.New selection parameter of Ship-to *
*                                 2.New rept output column of Ship-to  *
*                                 3.Ship-to value fetching logic       *
*                                 4.Shift of column Unrest. Stock to   *
*                                   the end of the output              *
* 08-Oct-2014 SPAUL2   E1DK913381 INC0140560 / CR1286:                 *
*                                 Field description changes recommended*
*                                 by business in the selection screen  *
*                                 and report output.                   *
*                                 Customer desc not getting populated. *
* 19-JAN-2015 SPAUL2   E1DK913381 INC0140560 / CR1286:                 *
*                                 Remove ‘Zero Inventory’ selection    *
*                                 button from the selection screen of  *
*                                 the report.                          *
*&---------------------------------------------------------------------*


REPORT  zotcr0010o_batch_matching   NO STANDARD PAGE HEADING
                                    LINE-SIZE 132
                                    MESSAGE-ID zotc_msg.


************************************************************************
*          DATA DECLARATION INCLUDE                                    *
************************************************************************
INCLUDE zotcn0010o_batch_matching_top.


************************************************************************
*          SELECTION SCREEN DECLARATION INCLUDE                        *
************************************************************************
INCLUDE zotcn0010o_batch_matching_scr.

************************************************************************
*          SUBROUTINE INCLUDE                                          *
************************************************************************
INCLUDE zotcn0010o_batch_matching_form.


*----------------------------------------------------------------------*
*     INITIALIZATION
*----------------------------------------------------------------------*

INITIALIZATION.

  PERFORM f_screen_defaults.

*----------------------------------------------------------------------*
*     A T  S E L E C T I O N - S C R E E N
*----------------------------------------------------------------------*

AT SELECTION-SCREEN ON s_kunnr.
  IF s_kunnr IS NOT INITIAL.
    PERFORM f_kunnr_validation.
  ENDIF.

**&& -- BOC : CR #1286 : PROUT : 06-AUG-2014
AT SELECTION-SCREEN ON s_matnr.
**&& -- EOC : CR #1286 : PROUT : 06-AUG-2014
  PERFORM f_mat_validation.

AT SELECTION-SCREEN ON s_charg.
  IF s_charg IS NOT INITIAL.
    PERFORM f_charg_validation.
  ENDIF.
*----------------------------------------------------------------------*
*  AT SELECTION-SCREEN ON VALUE-REQUEST
*----------------------------------------------------------------------*
* BOC ADD ADAS1 Defect 1165
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_atwrt.
  PERFORM f_f4_prod_categgory.
* BOC ADD ADAS1 Defect 1165
*----------------------------------------------------------------------*
*     S T A R T - O F - S E L E C T I O N
*----------------------------------------------------------------------*

START-OF-SELECTION.
**&& -- BOC : CR #1286 : PROUT : 06-AUG-2014
IF cb_hist = abap_true.
      PERFORM f_hist_validation.
    ENDIF.
**&& -- EOC : CR #1286 : PROUT : 06-AUG-2014
*  Data selection
  PERFORM f_data_selection.

* Populating final table
  PERFORM f_fill_final_tab.

*----------------------------------------------------------------------*
*     E N D - O F - S E L E C T I O N
*----------------------------------------------------------------------*
END-OF-SELECTION.

* Report Display
  IF i_final[] IS NOT INITIAL.
    PERFORM f_output_display .
  ELSE.
    MESSAGE i115.
    LEAVE LIST-PROCESSING.
  ENDIF.
