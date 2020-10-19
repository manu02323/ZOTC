***********************************************************************
*Program    : ZOTCR0139O_PRICE_REPORT                                 *
*Title      : PRICE OVERRIDE REPORT                                   *
*Developer  : Devendra Battala                                        *
*Object type: Report                                                  *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_RDD_0139                                           *
*---------------------------------------------------------------------*
*Description:  Business requires a report monthly, for Invoices, whose*
* prices, have been manually overridden. They need a report at an Item*
* level, which contains the details of the prices of such Invoices    *
* along with their Order details.                                     *
* As this is a huge extract, this is to be scheduled as a background  *
* job, and user can get the output in the system spool.               *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport                     Description *
*=========== ============== ============== ===========================*
*14-Jun-2019  U105652       E2DK924628     SCTASK0840194: Initial     *
*                                          Development                *
*&--------------------------------------------------------------------*
*=========== ============== ============== ===========================*
*06-Aug-2019  U105652       E2DK924628    SCTASK0840194: Additional   *
*                                         Changed Information         *
*                                         Messages to Error messages. *                                                                   *
*&--------------------------------------------------------------------*
* 24-Sep-2019 U033959       E2DK924628    SCTASK0873868               *
*                                         Performance tuning done     *
*---------------------------------------------------------------------*

REPORT zotcr0139o_price_report NO STANDARD PAGE HEADING
                                  MESSAGE-ID zotc_msg
                                   LINE-COUNT 100
                                    LINE-SIZE 255.
************************************************************************
*          DATA DECLARATION INCLUDE                                    *
************************************************************************
* Top Include
INCLUDE zotcn0139o_price_report_top. " zotcr0139n_price_report_top


************************************************************************
*          SELECTION SCREEN DECLARATION INCLUDE                        *
************************************************************************
* Selection Screen Include
INCLUDE  zotcn0139o_price_report_sel. " zotcr0139n_price_report_sel
************************************************************************
*          SUBROUTINE INCLUDE                                          *
************************************************************************
INCLUDE  zotcn0139o_price_report_sub. " zzotcr0139n_price_report_sub


************************************************************************
* INITIALIZATION                                                       *
************************************************************************
INITIALIZATION.
*subroutine to retrieve records from kbetr table
  PERFORM f_fetch_data_kbetr CHANGING i_emikschl[]
                                      gv_records.


************************************************************************
* AT SELECTION-SCREEN VALIDATION
************************************************************************

AT SELECTION-SCREEN ON s_bity.
*validate for Billing Type
  IF s_bity IS NOT INITIAL.
    PERFORM f_validate_bity.
  ENDIF. " IF s_bity IS NOT INITIAL

AT SELECTION-SCREEN ON s_sorg.
*validate for Sales Organiztion
  IF s_sorg IS NOT INITIAL.
    PERFORM f_validate_sorg.
  ENDIF. " IF s_sorg IS NOT INITIAL


AT SELECTION-SCREEN ON s_disch.
*validate for Distribution Channel
  IF s_disch IS NOT INITIAL.
    PERFORM f_validate_disch.
  ENDIF. " IF s_disch IS NOT INITIAL

AT SELECTION-SCREEN ON p_year.
*validate for year
  IF p_year IS NOT INITIAL.
    PERFORM f_validate_year.
  ENDIF. " IF p_year IS NOT INITIAL

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_month.

  PERFORM f_user_drop_down_list_fordt. " Drop down list for months


************************************************************************
*        S T A R T - O F - S E L E C T I O N                           *
************************************************************************
START-OF-SELECTION.

*subroutine to retrieve records from vbrk table
  PERFORM f_get_data_vbrk CHANGING i_vbrk[].

*subroutine to retrieve records from vbak table
  PERFORM f_get_data_vbrp USING i_vbrk[]
                         CHANGING i_vbrp[].
  IF sy-batch IS INITIAL.
    IF lines( i_vbrp ) GT gv_records.
*--->Begin of Delete for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-SEP-2019
*      MESSAGE  i889 WITH gv_records.
*<---End of Delete for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-SEP-2019
*--->Begin of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-SEP-2019
      MESSAGE  i887 WITH gv_records.
*<---End of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-SEP-2019
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.
*subroutine to retrieve records from vbak table
  PERFORM f_get_data_vbak USING i_vbrp[]
                          CHANGING i_vbak[].

*subroutine to retrieve records from vbap table
  PERFORM f_get_data_vbap USING i_vbrp[]
                        CHANGING i_vbap[].

*subroutine to retrieve records from konv table
  PERFORM f_get_data_konv USING i_vbrk[]
                         CHANGING i_konv.
*subroutine to retrieve records from vbpa table
  PERFORM f_get_data_vbpa USING i_vbrp[]
                          CHANGING i_vbpa[].
*subroutine to retrieve records from kna1 table
  PERFORM f_get_data_kna1 USING i_vbpa[]
                                i_vbrk[]
                          CHANGING i_kna1[].
*subroutine to retrieve records from cepct table
  PERFORM f_get_data_cepct USING i_vbap[]
                           CHANGING i_cepct[].
  PERFORM f_get_data_t023 USING i_vbap[]
                          CHANGING i_t023[].
*subroutine to retrieve records from makt table
  PERFORM f_get_data_makt USING i_vbrp[]
                          CHANGING i_makt[].

***********************************************************************
*        E N D- O F - S E L E C T I O N                                *
************************************************************************

END-OF-SELECTION.

*subroutine to retrieve records from final table
  PERFORM f_populate_final_table USING i_vbrk[]
                                       i_vbrp[]
                                       i_vbak[]
                                       i_vbap[]
                                       i_t023[]
                                       i_konv[]
                                       i_kna1[]
                                       i_cepct[]
                                       i_makt[]
                                       i_vbpa[]
                              CHANGING i_final[].
  IF i_final[] IS NOT INITIAL .
*&&-- Display ALV Report
    PERFORM f_prepare_fieldcat USING i_emikschl.
  ELSE.
    IF i_final[] IS INITIAL .
*->Begin of delete for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
*    MESSAGE i927 DISPLAY LIKE c_e.
*     LEAVE LIST-PROCESSING.
*<-End of delete for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019

*->Begin of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
      MESSAGE e927.
   LEAVE LIST-PROCESSING.
*<-End of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
    ENDIF.
  ENDIF. " IF i_final[] IS NOT INITIAL
