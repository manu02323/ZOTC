***********************************************************************
*Program    : ZOTCO0229B_QUOTE_VALID_CPQ                              *
*Title      : Quote Validation to CPQ                                 *
*Developer  : Raghav Sureddi (u033876)                                *
*Object type: Interface                                               *
*SAP Release: SAP ECC 8.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_IDD_0229                                              *
*---------------------------------------------------------------------*
*Description: Send Order info for Quote validation  to SOA  and SOA   *
* will send it CPQ for Quote validations and response back.           *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*20-June-2019  U033876      E2DK924884     Initial Development.       *
*=========== ============== ============== ===========================*
REPORT zotco0229b_quote_valid_cpq NO STANDARD PAGE HEADING
                                  LINE-SIZE 132
                                  LINE-COUNT 100
                                  MESSAGE-ID zotc_msg.
INCLUDE zotcn0229b_quote_valid_cpq_top.
INCLUDE zotcn0229b_quote_valid_cpq_sel.
INCLUDE zotcn0229b_quote_valid_cpq_f01.

INITIALIZATION.
* Initialize
  PERFORM f_initialization.

** Performing Validation on Sales Document
AT SELECTION-SCREEN ON s_vbeln.
  IF s_vbeln IS NOT INITIAL.
    PERFORM f_validate_vbeln.
  ENDIF. " IF s_vbeln IS NOT INITIAL
*
AT SELECTION-SCREEN .
  IF s_erdat[] IS INITIAL AND s_vbeln[] IS INITIAL.
    MESSAGE e000  WITH 'Please enter Date or Sales Order'(003).
  ENDIF. " IF p_reg IS NOT INITIAL AND s_belnr IS INITIAL

START-OF-SELECTION.
* Fetch data from database based on user input
  PERFORM f_get_data USING i_status
                    CHANGING  i_vbak
                              i_vbap
                              i_vbpa.

END-OF-SELECTION.
* Process orders with ZCP1 user status into final internal table
  PERFORM f_proc_data USING i_status
                            i_vbak
                            i_vbap
                            i_vbpa
                      CHANGING
                            i_final.

* If no data is found for given criteria show user error message
  IF i_final[] IS INITIAL.
    MESSAGE i095. " No Data Found For The Given Selection Criteria .
    LEAVE LIST-PROCESSING.
  ELSE. " ELSE -> IF i_data[] IS INITIAL

*   Send data to CPQ system using proxies
    PERFORM f_call_proxy USING i_status
                               i_final
                               i_vbak
                               i_vbap
                         CHANGING i_error.

    IF i_error[] IS NOT INITIAL.
      PERFORM f_display_summary_report USING i_error.
    ENDIF.
  ENDIF. " IF i_data[] IS INITIAL
