*&---------------------------------------------------------------------*
*& Report  ZOTCR0092O_AR_AGING_REPORT
************************************************************************
* PROGRAM    :  ZOTCR0092O_AR_AGING_REPORT                             *
* TITLE      :  AR Aging Report                                        *
* DEVELOPER  :  Sneha/Moushumi/Sayantan/Lekhashri                      *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID: D2_OTC_RDD_0092
*----------------------------------------------------------------------*
* DESCRIPTION: AR Aging Report
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER      TRANSPORT      DESCRIPTION                   *
* ===========  ========   =========  ==================================*
* 18-Mar-2016  SMUKHER    E2DK917181  AR Aging Report                  *
* 18-Jul-2016  U034192   E2DK918412  Defect #1804(SCTASK0357514).     *
*                                   1.Add Customer Group( KNKK- KDGRP) *
*                                    Assignment(BSAD-ZUONR/BSID -ZUONR)*
*                                    Fields to ALV output              *
*                                   2.Copy authorization Object from   *
*                                    F_KNA1_BUK to ZOTC_AGAING         *
* 18-Jul-2016 SMUKHER    E2DK918411 Defect# 1804 1.Amount in Doc curre *
*                                    -ncy should also consider (-) valu*
*                                    -es.                              *
*                                     2.Also, there might be cases where
*                                     the same document is available in*
*                                     both BSAD and BSID table.This nee*
*                                     -ds to be taken care of.         *
*                                     3.Also Credit Rep Group is not   *
*                                     mandatory.                       *
* 13-Oct-2016 LMAHEND  E2DK919334    Defect# 2091:Delimiter is changed *
*                                    from Comma to tab to download     *
*                                    the data into excel sheet         *
*                                    Also output length specified in   *
*                                    fieldcatalog because large numbers*
*                                    were getting truncated when report*
*                                    ran in background.                *
*&---------------------------------------------------------------------*

REPORT zotcr0092o_ar_aging_report NO STANDARD PAGE HEADING
                                  MESSAGE-ID zotc_msg
                                  LINE-COUNT 65(8).
* ---> Begin of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-OCT-2016
* We are commenting the Line Size since this was leading to garbage values in
* case of large numbers when report ran in background.
*                                  LINE-SIZE 132.
* <--- End of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-OCT-2016
************************************************************************
************************************************************************
*          DATA DECLARATION INCLUDE                                    *
************************************************************************
* Include for data declaration
INCLUDE zotcn0092o_ar_aging_report_top. " Include ZOTCN0092O_AR_AGING_REPORT_TOP
************************************************************************
*          SELECTION SCREEN DECLARATION INCLUDE                        *
************************************************************************
* Include for Selection Screen
INCLUDE zotcn0092o_ar_aging_report_sel. " Include ZOTCN0092O_AR_AGING_REPORT_SEL
************************************************************************
*          SUBROUTINE INCLUDE                                          *
************************************************************************
* Include for sub-routines
INCLUDE zotcn0092o_ar_aging_report_sub. " Include ZOTCN0092O_AR_AGING_REPORT_SUB
************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.
*&-- Default values to file path
  PERFORM f_initialization.

************************************************************************
* AT SELECTION-SCREEN VALIDATION
************************************************************************
*Validating Customer Number
AT SELECTION-SCREEN ON s_kunnr.
*&-- Assign sy-ucomm to a global varible
  CLEAR gv_ucomm.
  gv_ucomm = sy-ucomm.
  IF s_kunnr IS NOT INITIAL.
    PERFORM f_validate_s_kunnr USING s_kunnr[].
  ENDIF. " IF s_kunnr IS NOT INITIAL

*Validating Company Code
AT SELECTION-SCREEN ON s_comp.
  IF  s_comp IS NOT INITIAL.
    PERFORM f_validate_s_comp USING s_comp[].
  ENDIF. " IF s_comp IS NOT INITIAL

*Validating Credit Control Area
AT SELECTION-SCREEN ON p_kkber.
  IF p_kkber IS NOT INITIAL.
    PERFORM f_validate_p_kkber.
  ENDIF. " IF p_kkber IS NOT INITIAL

*Validating Reconciliation Acc
AT SELECTION-SCREEN ON s_reccon.
  IF s_reccon IS NOT INITIAL.
    PERFORM f_validate_s_reccon USING s_reccon[].
  ENDIF. " IF s_reccon IS NOT INITIAL

*Validating Credit Account
AT SELECTION-SCREEN ON s_knkli.
  IF s_knkli IS NOT INITIAL.
    PERFORM f_validate_s_knkli USING s_knkli[].
  ENDIF. " IF s_knkli IS NOT INITIAL

*Validating A/R Credit Rep Grp
AT SELECTION-SCREEN ON s_sbgrp.
  IF s_sbgrp IS NOT INITIAL.
    PERFORM f_validate_s_sbgrp USING s_sbgrp[].
  ENDIF. " IF s_sbgrp IS NOT INITIAL

AT SELECTION-SCREEN OUTPUT.
*&--Modifying Screen.
  PERFORM f_modify_screen USING gv_ucomm.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.
  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    IMPORTING
      serverfile       = p_path
    EXCEPTIONS
      canceled_by_user = 1
      OTHERS           = 2.

  IF sy-subrc <> 0.
         "do nothing use the default path
  ENDIF. " IF sy-subrc <> 0

************************************************************************
*     A T  S E L E C T I O N - S C R E E N                             *
************************************************************************
AT SELECTION-SCREEN.

*&-- Validating company code and customer combination
  IF s_kunnr[] IS NOT INITIAL
  AND s_comp[] IS NOT INITIAL.
    PERFORM f_validate_kunnr_comp USING s_kunnr[]
                                        s_comp[].
  ENDIF. " IF s_kunnr[] IS NOT INITIAL

*&-- Validating Customer and credit cont. area
  IF s_kunnr[] IS NOT INITIAL
  AND p_kkber IS NOT INITIAL.
    PERFORM f_validate_kunnr_kkber USING s_kunnr[]
                                         p_kkber.
  ENDIF. " IF s_kunnr[] IS NOT INITIAL

*&-- Validating company code and credit cont area
  IF s_comp[] IS NOT INITIAL
  AND p_kkber IS NOT INITIAL.
    PERFORM f_validate_comp_kkber USING s_comp[]
                                        p_kkber.

  ENDIF. " IF s_comp[] IS NOT INITIAL

*&-- Validating credit rep grp and credit cont area
  IF s_sbgrp IS NOT INITIAL
    AND p_kkber IS NOT INITIAL.
    PERFORM f_validate_s_sbgrp_kkber USING s_sbgrp[].
  ENDIF. " IF s_sbgrp IS NOT INITIAL

************************************************************************
*        S T A R T - O F - S E L E C T I O N                           *
************************************************************************
START-OF-SELECTION.
*&&-- Check for mandatory fields

*&-- Customer Number
  IF s_kunnr IS INITIAL.
    MESSAGE i911. " Customer Number is required
    LEAVE LIST-PROCESSING.
  ENDIF. " IF s_kunnr IS INITIAL

*&-- Company Code
  IF s_comp IS INITIAL.
    MESSAGE i912. " Company Code is required
    LEAVE LIST-PROCESSING.
  ENDIF. " IF s_comp IS INITIAL

*-->Begin of delete for D2_OTC_RDD_0092 Def#1804 by SMUKHER on 18-July-2016
* Credit Rep Group is no longer mandatory.
*&-- Credit Rep Grp
*  IF s_sbgrp IS INITIAL.
*    MESSAGE i913. " Credit Rep Group is required
*    LEAVE LIST-PROCESSING.
*  ENDIF. " IF s_sbgrp IS INITIAL
*<-- End of delete for D2_OTC_RDD_0092 Def#1804 by SMUKHER on 18-July-2016

*&-- Credit Control area
  IF p_kkber IS INITIAL.
    MESSAGE i914. " Credit Control Area is required
    LEAVE LIST-PROCESSING.
  ENDIF. " IF p_kkber IS INITIAL

*&-- Populate the global dates
  IF rb_creif IS INITIAL.
    PERFORM f_populate_dates.
  ENDIF. " IF rb_creif IS INITIAL

*&-- Authorization check
*  PERFORM f_authorization_check.

*&-- Populate all the data in the global tables
 "fetching data from t001 table
  PERFORM f_get_data_t001 CHANGING i_t001[].

 "fetching data from knb1 table
  PERFORM f_get_data_knb1 USING s_kunnr[]
                                s_reccon[]
                       CHANGING i_knb1[]
                                i_t001[].

 "fetching data from knkk table
  PERFORM f_get_data_knkk USING i_knb1[]
                                i_t001[]
                       CHANGING i_knkk[].

 "fetching data from kna1 table
  PERFORM f_get_data_kna1 USING i_knkk[]
                       CHANGING i_kna1[].

 "fetching data from bsid table
  PERFORM f_get_data_bsid USING i_knb1[]
                       CHANGING i_bsid[].

 "fetching data from bsad table
  PERFORM f_get_data_bsad USING i_knb1[]
                       CHANGING i_bsad[].

 "fetching data from vbrp table
  PERFORM f_get_data_vbrp USING i_bsid[]
                       CHANGING i_vbrp[].

 "fetching data from vbak table
  PERFORM f_get_data_vbak  CHANGING i_vbak[]
                                    i_vbrp[].

 "fetching data from t024b table
  PERFORM f_get_data_t024b USING i_knkk[]
                        CHANGING i_t024b[].

************************************************************************
*             E N D- O F - S E L E C T I O N                           *
************************************************************************
END-OF-SELECTION.
*&-- Based on radio buttons populate the final table
*&-- I_FINAL_DET with summary/detail/credit report
  IF NOT rb_detdc IS INITIAL
    OR NOT rb_sumdc IS INITIAL.
*&-- Document Date
    PERFORM f_populate_final_table_dd USING i_kna1
                                            i_knkk
                                            i_bsid
                                            i_bsad
                                            i_vbrp
                                            i_vbak
                                            i_t024b
                                   CHANGING i_final_det.

  ELSEIF NOT rb_detnt IS INITIAL
    OR NOT rb_sumnt IS INITIAL.
*&-- Net Due Date
    PERFORM f_populate_final_table_nd USING i_kna1
                                            i_knkk
                                            i_bsid
                                            i_bsad
                                            i_vbrp
                                            i_vbak
                                            i_t024b
                                   CHANGING i_final_det.
  ELSE. " ELSE -> IF NOT rb_detdc IS INITIAL
*&-- Credit report
    PERFORM f_populate_final_table_cr USING i_knkk[]
                                   CHANGING i_final_det.
  ENDIF. " IF NOT rb_detdc IS INITIAL

*&--ALV DISPLAY
  IF i_final_det[] IS NOT INITIAL.
    SORT i_final_det BY bukrs kunnr.  " Defect 2646
    IF rb_alv IS NOT INITIAL.
      PERFORM f_prepare_fieldcat CHANGING i_fieldcat[].

*&-- Based on the background/foreground processing
*&-- the ALV will e generated as LIST/GRID respectively
      PERFORM f_display_alv USING i_fieldcat[]
                                  i_final_det[].

    ELSEIF rb_afile IS NOT INITIAL.
      PERFORM f_appl_server_upload USING i_final_det.
    ENDIF. " IF rb_alv IS NOT INITIAL
  ELSE. " ELSE -> IF i_final_det[] IS NOT INITIAL
*&-- If final table is initial throw error message
    MESSAGE i138. " No Records Found
    LEAVE LIST-PROCESSING.
  ENDIF. " IF i_final_det[] IS NOT INITIAL
