*&---------------------------------------------------------------------*
*& Report  ZOTCR0028O_PRICING_REPORT
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCR0028O_PRICING_REPORT                              *
* TITLE      :  Pricing Report for Mass Price Upload                   *
* DEVELOPER  :  ROHIT VERMA                                            *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_RDD_0028_Pricing Report for Mass Price Upload      *
*----------------------------------------------------------------------*
* DESCRIPTION: This Report provide a interactive pricing report, which *
*              will be having downloadable feature. User can modify the*
*              values and use the same file for price mass upload.     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 22-Jul-2013 RVERMA   E1DK910844 INITIAL DEVELOPMENT - CR#410         *
*&---------------------------------------------------------------------*

REPORT  zotcr0028o_pricing_report NO STANDARD PAGE HEADING
                                  MESSAGE-ID zotc_msg.

************************************************************************
*          DATA DECLARATION INCLUDE                                    *
************************************************************************
INCLUDE zotcn0028o_pricing_report_top.

************************************************************************
*          SELECTION SCREEN DECLARATION INCLUDE                        *
************************************************************************
INCLUDE zotcn0028o_pricing_report_scr.

************************************************************************
*          SUBROUTINE INCLUDE                                          *
************************************************************************
INCLUDE zotcn0028o_pricing_report_sub.

*----------------------------------------------------------------------*
*     A T  S E L E C T I O N - S C R E E N
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_kschl.
*&--Get search help for condition type
  PERFORM f_get_f4_cond_type.

*----------------------------------------------------------------------*
*     I N I T I A L I Z A T I O N
*----------------------------------------------------------------------*
INITIALIZATION.
*&--Get initial values from TVARVC table
  PERFORM f_get_initial CHANGING gv_usage
                                 gv_appl.

*----------------------------------------------------------------------*
*     S T A R T - O F - S E L E C T I O N
*----------------------------------------------------------------------*
START-OF-SELECTION.
*&--Get access sequence data
  PERFORM f_get_acess_seq USING gv_usage
                                gv_appl
                                p_kschl
                       CHANGING x_t681
                                x_tmc1t.

*----------------------------------------------------------------------*
*     E N D - O F - S E L E C T I O N
*----------------------------------------------------------------------*
END-OF-SELECTION.

  IF x_t681 IS NOT INITIAL.
*&--If condition data structre is filled then call
*&--FM ZOTC_CRE_PRICING_REP_CODE to generate/maintain
*&--access sequece report or pricing report
    CALL FUNCTION 'ZOTC_CRE_PRICING_REP_CODE'
      EXPORTING
        im_kvewe    = gv_usage
        im_kappl    = gv_appl
        im_kschl    = p_kschl
        im_t681     = x_t681
      IMPORTING
        ex_program  = gv_program
      EXCEPTIONS
        no_report   = 1
        syntax_fail = 2
        OTHERS      = 3.

    IF sy-subrc EQ 0.
      SUBMIT (gv_program) VIA SELECTION-SCREEN
                          WITH p_kappl EQ gv_appl
                          WITH p_kschl EQ p_kschl
                          WITH p_kotab EQ x_t681-kotab
                          AND RETURN.
    ELSE.
      CASE sy-subrc.
        WHEN 1.
          MESSAGE e000
             WITH 'Dynamic Report Not Generated'(002).
        WHEN 2.
          MESSAGE e000
             WITH 'Syntax Error in Generated Report'(003).
      ENDCASE.
    ENDIF.

  ENDIF.
