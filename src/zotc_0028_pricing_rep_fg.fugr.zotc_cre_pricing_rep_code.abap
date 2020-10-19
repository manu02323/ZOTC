*&---------------------------------------------------------------------*
*& Function Module  ZOTC_CRE_PRICING_REP_CODE
*&---------------------------------------------------------------------*
************************************************************************
* FM         :  ZOTC_CRE_PRICING_REP_CODE                              *
* FG         :  ZOTC_0028_PRICING_REP_FG                               *
* TITLE      :  FM to generate/maintain report for pricing access seq  *
*               report                                                 *
* DEVELOPER  :  ROHIT VERMA                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_RDD_0028_Pricing Report for Mass Price Upload      *
*----------------------------------------------------------------------*
* DESCRIPTION:  FM to generate/maintain report for pricing access seq  *
*               report                                                 *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 22-Jul-2013 RVERMA   E1DK910844 INITIAL DEVELOPMENT - CR#410         *
*&---------------------------------------------------------------------*

FUNCTION zotc_cre_pricing_rep_code.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_KVEWE) TYPE  KVEWE
*"     REFERENCE(IM_KAPPL) TYPE  KAPPL
*"     REFERENCE(IM_KSCHL) TYPE  KSCHA
*"     REFERENCE(IM_T681) TYPE  T681
*"     REFERENCE(IM_TMC1T) TYPE  TMC1T OPTIONAL
*"  EXPORTING
*"     REFERENCE(EX_PROGRAM) TYPE  SYREPID
*"     REFERENCE(EX_CODE) TYPE  ZRCG_BAG_RSSOURCE
*"     REFERENCE(EX_TEXTPOOL) TYPE  TEXTPOOL_TABLE
*"  EXCEPTIONS
*"      NO_REPORT
*"      SYNTAX_FAIL
*"----------------------------------------------------------------------

  DATA:
    li_code       TYPE zrcg_bag_rssource, "Internal Table of Source Code
    li_textpool   TYPE textpool_table,    "Internal Table of Text-Pool

    lwa_tpool     TYPE textpool,          "Workarea of Text-Pool

    lv_comp_start TYPE numc4.             "Counter of Comparison

*&--Assigning program name
  CONCATENATE c_program_x
              im_t681-kotab
    INTO ex_program.
  CONDENSE ex_program NO-GAPS.

*&--Populating report name
  lwa_tpool-id = c_tpool_id_r.
  lwa_tpool-entry = 'Pricing Report for Mass Price Upload'(054). " Mass exponent
  APPEND lwa_tpool TO li_textpool.
  CLEAR lwa_tpool.

*&--Code: Initial lines (Flower Box).
  PERFORM f_get_initial_code USING ex_program
                          CHANGING li_code
                                   lv_comp_start.

*&--Code: Report Code
  PERFORM f_get_report_code USING im_t681
                         CHANGING li_code
                                  li_textpool.

*&--Call FM ZOTC_MAINTAIN_PRICING_REP to maintain/generate report
  CALL FUNCTION 'ZOTC_MAINTAIN_PRICING_REP'
    EXPORTING
      im_program    = ex_program
      im_code       = li_code
      im_textpool   = li_textpool
      im_comp_start = lv_comp_start
    EXCEPTIONS
      no_report     = 1
      syntax_fail   = 2
      OTHERS        = 3.

  IF sy-subrc NE 0.
    CASE sy-subrc.
      WHEN 1.
        RAISE no_report.
      WHEN 2.
        RAISE syntax_fail.
    ENDCASE.
  ENDIF. " IF sy-subrc NE 0

ENDFUNCTION.
