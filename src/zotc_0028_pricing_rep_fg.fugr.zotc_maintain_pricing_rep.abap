*&---------------------------------------------------------------------*
*& Function Module  ZOTC_MAINTAIN_PRICING_REP
*&---------------------------------------------------------------------*
************************************************************************
* FM         :  ZOTC_MAINTAIN_PRICING_REP                              *
* FG         :  ZOTC_0028_PRICING_REP_FG                               *
* TITLE      :  Maintain Pricing Report                                *
* DEVELOPER  :  ROHIT VERMA                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_RDD_0028_Pricing Report for Mass Price Upload      *
*----------------------------------------------------------------------*
* DESCRIPTION:  FM to maintain/generate pricing report                 *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 22-Jul-2013 RVERMA   E1DK910844 INITIAL DEVELOPMENT - CR#410         *
*&---------------------------------------------------------------------*

FUNCTION zotc_maintain_pricing_rep.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_PROGRAM) TYPE  SYREPID
*"     REFERENCE(IM_CODE) TYPE  ZRCG_BAG_RSSOURCE
*"     REFERENCE(IM_TEXTPOOL) TYPE  TEXTPOOL_TABLE
*"     REFERENCE(IM_COMP_START) TYPE  NUMC4 DEFAULT 1
*"  EXCEPTIONS
*"      NO_REPORT
*"      SYNTAX_FAIL
*"----------------------------------------------------------------------

  DATA:
    li_code_new TYPE zrcg_bag_rssource, "New table of source code
    li_code_old TYPE zrcg_bag_rssource, "Old table of source code
    li_code_tmp TYPE zrcg_bag_rssource, "Temp table of source code
    lv_code_flg TYPE char01,            "Flag to generate code or not
    lv_inctoo   TYPE char01 VALUE ' '.  "Include include programs


*&--Call FM for pretty printer of source code
  CALL FUNCTION 'PRETTY_PRINTER'
    EXPORTING
      inctoo             = lv_inctoo
    TABLES
      ntext              = li_code_new
      otext              = im_code
    EXCEPTIONS
      enqueue_table_full = 1
      include_enqueued   = 2
      include_readerror  = 3
      include_writeerror = 4
      OTHERS             = 5.
  IF sy-subrc NE 0.
*&--If FM fails then copy the source code in new table of source code
    li_code_new[] = im_code[].
  ENDIF. " IF sy-subrc NE 0

*&--Call FM to check whether program exists or not
  CALL FUNCTION 'RPY_EXISTENCE_CHECK_PROG'
    EXPORTING
      name      = im_program
    EXCEPTIONS
      not_exist = 1
      OTHERS    = 2.

  IF sy-subrc NE 0.
*&--If program does not exist then mark the flag to generate report
    lv_code_flg = c_yes.
  ELSE. " ELSE -> IF sy-subrc NE 0
*&--If program does exist then read the source code of program into
*&--old table of source code.
    READ REPORT im_program INTO li_code_old.
    IF sy-subrc EQ 0.
*&--If source code is read successfully then compare the old table
*&--source code and new table source code
      DELETE li_code_old FROM 1 TO im_comp_start.

      li_code_tmp[] = li_code_new[].

      DELETE li_code_tmp FROM 1 TO im_comp_start.

      IF li_code_tmp[] NE li_code_old[].
*&--IF old and new source code table is different then mark the flag
*&--to generate report
        lv_code_flg = c_yes.
      ENDIF. " IF li_code_tmp[] NE li_code_old[]

    ELSE. " ELSE -> IF li_code_tmp[] NE li_code_old[]
*&--If source code not read from program then mark the flag to
*&--generate report
      lv_code_flg = c_yes.
    ENDIF. " IF sy-subrc EQ 0

  ENDIF. " IF sy-subrc NE 0


  IF lv_code_flg IS NOT INITIAL.

*&--If code flag is checked then generate the report
    INSERT REPORT im_program FROM li_code_new UNICODE ENABLING c_yes.

    IF sy-subrc NE 0.
      RAISE syntax_fail.
    ELSE. " ELSE -> IF sy-subrc NE 0
      INSERT TEXTPOOL im_program FROM im_textpool.
    ENDIF. " IF sy-subrc NE 0

  ENDIF. " IF lv_code_flg IS NOT INITIAL

ENDFUNCTION.
