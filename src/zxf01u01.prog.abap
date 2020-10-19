***********************************************************************
*Program    : ZXF01U01                                                *
*Title      : D2_OTC_IDD_0176_Banamex SAP MT 940                      *
*Developer  : Moushumi Bhattacharya                                   *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0176                                           *
*---------------------------------------------------------------------*
*Description: Purpose of this enhancement is to substitute COBRANZA   *
*             Virtual accounts with SAP Customer number. This mapping *
*             is maintained using BRF Application.                    *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*17-Feb-2015  MBHATTA1      E2DK908899      Initial Development
*13-Mar-2015  MBHATTA1      E2DK908899     Defect # 4698
*                                          Rework on field population
*                                          in replacing virtual account
*                                          by SAP customer number
*17-Apr-2015  MBAGDA        E2DK908899     Defect # 6017
*                                          1. Search string "CV_"
*                                          2. Restrict the code run for
*                                             Algorithm 901-Mexico
*---------------------------------------------------------------------*
*19-Jun-2019  U033814      E2DK924281      Initial Development - SCTASK0791864
*                                          Feban_Iban_Customer Number
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*21-Aug-2019  U033814      E2DK924281      Defect No 10269
*---------------------------------------------------------------------*

CONSTANTS:
   lc_name_appl     TYPE string        VALUE   'ZA_OTC_IDD_0176_MT940_BANAMEX',
   lc_name_func     TYPE string        VALUE   'ZF_OTC_IDD_0176_MT940_BANAMEX',
   lc_separator     TYPE xfeld         VALUE   '.'              , " Checkbox
*  lc_splitter      TYPE xfeld         VALUE   '/'              , " Checkbox        "Def-6017
   lc_splitter      TYPE char3         VALUE   'CV_'            , " Search String   "Def-6017
   lc_enh_id        TYPE z_enhancement VALUE   'D2_OTC_IDD_0176', " Enhancement No.
   lc_null          TYPE z_criteria    VALUE   'NULL'           , " Enh. Criteria-NULL
*>>> Begin of Insert for D2_OTC_IDD_0176 Def 6017 by MBAGDA
   lc_algorithm_intag
                    TYPE z_criteria    VALUE   'ALGORITHM_INTAG', " Enh. Criteria-ALGORITHM_INTAG
*<<< End of Insert for D2_OTC_IDD_0176 Def 6017 by MBAGDA
*>>> Begin of Insert for D2_OTC_IDD_0176 Def 4698 by MBHATTA1
   lc_fldname_sel   TYPE fieldname     VALUE   'WRBTR'          , " Field Name for Selection
   lc_csnum         TYPE csnum_eb      VALUE   '1'              , " Clearing record number
   lc_koart         TYPE koart         VALUE   'D'              , " Account Type
   lc_selvon        TYPE sel01_f05a    VALUE   '*'              . " Input Field for Search Criterion for Selecting Open Items
*<<< End of Insert for D2_OTC_IDD_0176 Def 4698 by MBHATTA1

DATA:
   lv_accno     TYPE char16,                                           " Accno of type CHAR16
   lv_kunnr     TYPE kunnr,                                            " Customer Number
   lv_query_in  TYPE string,
   li_result    TYPE match_result_tab,
   li_enh_stat  TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Enhancement Status
   lv_lines     TYPE sytfill,                                          " Row Number of Internal Tables
   lv_lines1    TYPE sytfill,                                          " Row Number of Internal Tables
   lv_offset    TYPE syfdpos,                                          " Row Number of Internal Tables
   lv_query_out TYPE if_fdt_types=>id,
   lv_totaleln  TYPE i.                                                " Total Lengh of Virtual Number String

DATA:
   lref_utility       TYPE REF TO /bofu/cl_fdt_util, " BRFplus Utilities
   lref_admin_data    TYPE REF TO if_fdt_admin_data, " FDT: Administrative Data
   lref_function      TYPE REF TO if_fdt_function,   " FDT: Function
   lref_context       TYPE REF TO if_fdt_context,    " FDT: Context
   lref_result        TYPE REF TO if_fdt_result,     " FDT: Result
   lref_fdt           TYPE REF TO cx_fdt,            " FDT: Abstract Exception Class   ##NEEDED
   lwa_febcl          TYPE febcl.                    " Clearing data for an electronic bank statement line item

FIELD-SYMBOLS:
   <lfs_s_febcl>      TYPE febcl,        " Reference record for electronic bank statement line item
   <lfs_s_febre>      TYPE febre,        " Reference record for electronic bank statement line item
   <lfs_s_result>     TYPE match_result. " Match with Regular Expression

* Begin of SCTASK0791864
TYPES : BEGIN OF lty_knbk,
        kunnr	TYPE kunnr,
        banks	TYPE banks,
        bankl	TYPE bankk,
        bankn	TYPE bankn,
        END OF lty_knbk,
        BEGIN OF lty_knb1,
        kunnr TYPE kunnr,
        bukrs TYPE bukrs,
        END OF lty_knb1,
        BEGIN OF lty_ztext,
          ztext TYPE char120,
          kunnr TYPE kunnr,
        END OF lty_ztext.
DATA : li_zotc_ebs_search TYPE STANDARD TABLE OF zotc_ebs_search,
       li_ztext           TYPE STANDARD TABLE OF lty_ztext,
       li_knbk TYPE STANDARD TABLE OF lty_knbk,
       li_knb1 TYPE STANDARD TABLE OF lty_knb1,
       lwa_knbk TYPE lty_knbk,
       lwa_ztext TYPE lty_ztext,
       lwa_knb1 TYPE lty_knb1,
       lv_tag       TYPE ztag,
       lv_length    TYPE i,     " Length of type Integers
       lv_iban1     TYPE iban,  " IBAN (International Bank Account Number)
       lv_iban2     TYPE iban ##NEEDED ,  " IBAN (International Bank Account Number)
       lv_string    TYPE string,
       lv_customer  TYPE kunnr, " Customer Number
       lv_bankk     TYPE bankk, " Bank Keys
       lv_bankn     TYPE bankn, " Bank account number
       lv_rule      TYPE zrule.
FIELD-SYMBOLS : <lfs_zotc_ebs_search> TYPE zotc_ebs_search,
                <lfs_febre>           TYPE febre.
* End of SCTASK0791864

*&-- Populate the exporting parameters
e_febep = i_febep.
e_febko = i_febko.


*&-- Check Enhancement Status
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_enh_id
  TABLES
    tt_enh_status     = li_enh_stat.

DELETE li_enh_stat WHERE active IS INITIAL.

READ TABLE li_enh_stat WITH KEY criteria = lc_null
                       TRANSPORTING NO FIELDS.
IF sy-subrc EQ 0.
  CLEAR: lref_utility, lv_query_in, lv_query_out.

  READ TABLE li_enh_stat WITH KEY criteria = lc_algorithm_intag "Def 6017 by MBAGDA
                                  sel_low  = i_febep-intag
                         TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.

*-- Get GUID value of Function
    lref_utility ?= /bofu/cl_fdt_util=>get_instance( ).

    CONCATENATE lc_name_appl lc_name_func
           INTO lv_query_in
           SEPARATED BY lc_separator.

    IF lref_utility IS BOUND.
      CALL METHOD lref_utility->convert_function_input
        EXPORTING
          iv_input  = lv_query_in
        IMPORTING
          ev_output = lv_query_out
        EXCEPTIONS
          failed    = 1
          OTHERS    = 2.

      IF sy-subrc EQ 0.
*-- Set the variable value(s)
        cl_fdt_factory=>get_instance_generic( EXPORTING iv_id = lv_query_out
                                              IMPORTING eo_instance = lref_admin_data ).
        lref_function ?= lref_admin_data.
        lref_context  ?= lref_function->get_process_context( ).


        LOOP AT t_febre ASSIGNING <lfs_s_febre>.
          CLEAR: lv_kunnr, lv_totaleln.
          FIND ALL OCCURRENCES OF lc_splitter IN <lfs_s_febre>-vwezw RESULTS li_result.
          IF sy-subrc EQ 0.
            DESCRIBE TABLE li_result LINES lv_lines.
            READ TABLE li_result ASSIGNING <lfs_s_result> INDEX lv_lines.
            IF sy-subrc EQ 0.
*&-- Find out last position of 'CV_' and there after take 16 chars for virtual acc no
*&-- Virtual Acc no will always be at the last position prefixed by 'CV_'
              lv_offset = <lfs_s_result>-offset + <lfs_s_result>-length.
              lv_accno = <lfs_s_febre>-vwezw+lv_offset(16).

              IF NOT lv_accno IS INITIAL.
*&-- Process virtual acc no to get SAP Customer number
                lref_context->set_value( iv_name = 'COMPANY_CODE'  ia_value = i_febko-bukrs ).
                lref_context->set_value( iv_name = 'VIRTUAL_NBR'   ia_value = lv_accno ).

                TRY.
                    lref_function->process( EXPORTING io_context = lref_context
                                            IMPORTING eo_result = lref_result ).
                    lref_result->get_value( IMPORTING ea_value = lv_kunnr ).
                    IF NOT lv_kunnr IS INITIAL.
                      lv_totaleln = <lfs_s_result>-length + 16.
                      <lfs_s_febre>-vwezw+<lfs_s_result>-offset(lv_totaleln) = lv_kunnr.
                    ENDIF. " IF NOT lv_kunnr IS INITIAL
                  CATCH cx_fdt INTO lref_fdt.                      ##no_handler
                ENDTRY.
              ENDIF. " IF NOT lv_accno IS INITIAL
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF sy-subrc EQ 0
*&-- Replace Virtual Number with SAP Customer Number
          IF lv_kunnr IS NOT INITIAL.
            LOOP AT t_febcl ASSIGNING <lfs_s_febcl>
                                WHERE kukey = <lfs_s_febre>-kukey.
              <lfs_s_febcl>-kukey  = i_febep-kukey.
              <lfs_s_febcl>-esnum  = i_febep-esnum.
*>>> Begin of Change for D2_OTC_IDD_0176 Def 4698 by MBHATTA1
              <lfs_s_febcl>-csnum  = lc_csnum.
              <lfs_s_febcl>-koart  = lc_koart.
*<<< End of Change for D2_OTC_IDD_0176 Def 4698 by MBHATTA1
              <lfs_s_febcl>-agkon  = lv_kunnr.
*>>> Begin of Change for D2_OTC_IDD_0176 Def 4698 by MBHATTA1
              <lfs_s_febcl>-selfd  = lc_fldname_sel.
              <lfs_s_febcl>-selvon = lc_selvon.
*<<< End of Change for D2_OTC_IDD_0176 Def 4698 by MBHATTA1
            ENDLOOP. " LOOP AT t_febcl ASSIGNING <lfs_s_febcl>

            IF sy-subrc <> 0.
              lwa_febcl-kukey  = i_febep-kukey.
              lwa_febcl-esnum  = i_febep-esnum.
*>>> Begin of Change for D2_OTC_IDD_0176 Def 4698 by MBHATTA1
              lwa_febcl-csnum  = lc_csnum.
              lwa_febcl-koart  = lc_koart.
*<<< End of Change for D2_OTC_IDD_0176 Def 4698 by MBHATTA1
              lwa_febcl-agkon  = lv_kunnr.
*>>> Begin of Change for D2_OTC_IDD_0176 Def 4698 by MBHATTA1
              lwa_febcl-selfd  = lc_fldname_sel.
              lwa_febcl-selvon = lc_selvon.
*<<< End of Change  for D2_OTC_IDD_0176 Def 4698 by MBHATTA1
              APPEND lwa_febcl TO t_febcl.
            ENDIF. " IF sy-subrc <> 0
          ENDIF. " IF lv_kunnr IS NOT INITIAL
        ENDLOOP. " LOOP AT t_febre ASSIGNING <lfs_s_febre>
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF lref_utility IS BOUND
*&-- Clearing class references
    CLEAR: lref_utility, lref_context,
           lref_function, lref_result,
           lref_admin_data, lref_fdt.

  ENDIF. " IF sy-subrc EQ 0
ENDIF. " IF sy-subrc EQ 0

* ---> Begin of Insert for D3 COE Defect 2178 by DMOIRAN/SMUKHER4
* Below code are part of OSS note 334865. But it has been restricted by
* house bank id.

* Begin of custom code.
IF i_febko-hbkid = 'I1000'
 OR i_febko-hbkid = 'I2064'.
* End of custom code.

  e_febko = i_febko.
  e_febep = i_febep.


  e_febko = i_febko.
  e_febep = i_febep.

  DATA: l_csnum TYPE febcl-csnum. " Clearing record number

* get lines
  LOOP AT t_febcl
       WHERE kukey = i_febep-kukey
       AND   esnum = i_febep-esnum.
  ENDLOOP. " loop at t_febcl
  l_csnum = sy-tabix.

  CLEAR t_febcl.
  t_febcl-kukey  = i_febko-kukey.
  t_febcl-esnum  = i_febep-esnum.
  t_febcl-csnum  = l_csnum.
  t_febcl-csnum  = t_febcl-csnum + 1.
  t_febcl-selfd  = 'FB'.
  IF i_febep-epvoz = 'S'.
    t_febcl-selvon = 'Z_FEB_1_VBUND_OUT'.
  ELSE. " ELSE -> if i_febep-epvoz = 'S'
    t_febcl-selvon = 'Z_FEB_1_VBUND_IN'.
  ENDIF. " if i_febep-epvoz = 'S'
  APPEND t_febcl.
  t_febcl-csnum  = t_febcl-csnum + 1.
  t_febcl-selvon = 'Z_FEB_2_VBUND'.
  APPEND t_febcl.

* Begin of custom code.
ENDIF. " if i_febko-HBKID = 'I1000'
* End of custom code.
* <--- End    of Insert for D3 COE Defect 2178 by DMOIRAN/SMUKHER4

****************************************************************************************
*********----> Begin of R7  SCTASK0791864
SELECT * FROM  zotc_ebs_search INTO TABLE li_zotc_ebs_search WHERE bukrs = i_febko-bukrs
                                                               AND hbkid = i_febko-hbkid
                                                               AND hktid = i_febko-hktid.

IF sy-subrc EQ 0.
  CLEAR lv_lines.
  DESCRIBE TABLE li_zotc_ebs_search LINES lv_lines1.
  IF lv_lines1 EQ 1.
    READ TABLE li_zotc_ebs_search ASSIGNING <lfs_zotc_ebs_search> INDEX 1.
    IF sy-subrc EQ 0.
      lv_rule = <lfs_zotc_ebs_search>-zrule.
    ENDIF. " IF sy-subrc EQ 0
  ELSE. " ELSE -> IF lv_lines EQ 1
    READ TABLE li_zotc_ebs_search ASSIGNING <lfs_zotc_ebs_search>  WITH KEY zprio = 1.
    IF sy-subrc EQ 0.
      lv_rule = <lfs_zotc_ebs_search>-zrule.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF lv_lines EQ 1


  lv_tag = <lfs_zotc_ebs_search>-ztag.
  lv_length = strlen( <lfs_zotc_ebs_search>-ztag ).
DO lv_lines1 TIMES.
 IF e_febep-avkon IS INITIAL.
IF sy-index EQ 2.
    READ TABLE li_zotc_ebs_search ASSIGNING <lfs_zotc_ebs_search>  WITH KEY zprio = 2.
    IF sy-subrc EQ 0.
      lv_rule = <lfs_zotc_ebs_search>-zrule.
    ENDIF. " IF sy-subrc EQ 0
ENDIF.
IF lv_rule EQ 'TEXT'.
  lv_lines1 = 1.
ENDIF.
  CASE lv_rule.
    WHEN 'ACCOUNT NUMBER'.
      READ TABLE t_febre ASSIGNING <lfs_febre> WITH KEY kukey = i_febep-kukey
                                                 esnum = i_febep-esnum
                                                     vwezw+0(5) =  lv_tag.
      IF sy-subrc EQ 0.
        lv_length = strlen( <lfs_febre>-vwezw ).
        lv_string = <lfs_febre>-vwezw+5(lv_length).
        SPLIT lv_string AT ' ' INTO lv_bankk lv_bankn.

        IF lv_bankk IS NOT INITIAL AND lv_bankn IS NOT INITIAL .
          SELECT kunnr banks bankl bankn FROM knbk INTO TABLE li_knbk
                     WHERE bankl = lv_bankk AND bankn = lv_bankn.
          IF sy-subrc EQ 0 AND li_knbk IS NOT INITIAL.
            SELECT  kunnr bukrs FROM knb1 INTO TABLE li_knb1 FOR ALL ENTRIES IN li_knbk
                                                             WHERE kunnr EQ li_knbk-kunnr
                                                             AND bukrs EQ i_febko-bukrs.
            IF sy-subrc EQ 0.
              DESCRIBE TABLE li_knb1 LINES lv_lines.
              IF lv_lines EQ 1 .
                READ TABLE li_knb1 INTO lwa_knb1 INDEX 1.
                IF sy-subrc EQ 0.
                   e_febep-avkon = lwa_knb1-kunnr.
                ENDIF.
              ENDIF.
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF sy-subrc EQ 0 AND lv_customer IS NOT INITIAL
        ENDIF. " IF lv_bankk IS NOT INITIAL AND lv_bankn IS NOT INITIAL
      ENDIF. " IF sy-subrc EQ 0
    WHEN 'IBAN'.
      READ TABLE t_febre ASSIGNING <lfs_febre> WITH KEY kukey = i_febep-kukey
                                                 esnum = i_febep-esnum
* Begin of Defect 10269
*                                                 vwezw+0(2) =  lv_tag.
                                                 vwezw+0(3) =  lv_tag.
* End of Defect 10269
      IF sy-subrc EQ 0.
        lv_length = strlen( <lfs_febre>-vwezw ).
        lv_string = <lfs_febre>-vwezw."+3(lv_length).
        SPLIT lv_string AT ':' INTO lv_iban1 lv_iban2.
*        clear : lv_iban1.
        SPLIT lv_iban2 AT ' ' INTO lv_iban2 lv_iban1.

        SELECT bankl bankn FROM tiban INTO (lv_bankk,lv_bankn)
                            UP TO 1 ROWS WHERE banks EQ lv_iban2+0(2)
                                           AND iban  EQ lv_iban2.
        ENDSELECT.
        IF sy-subrc EQ 0.
          IF lv_bankk IS NOT INITIAL AND lv_bankn IS NOT INITIAL .
          SELECT kunnr banks bankl bankn FROM knbk INTO TABLE li_knbk
                     WHERE bankl = lv_bankk AND bankn = lv_bankn.
          IF sy-subrc EQ 0 AND li_knbk IS NOT INITIAL.
            SELECT  kunnr bukrs FROM knb1 INTO TABLE li_knb1 FOR ALL ENTRIES IN li_knbk
                                                             WHERE kunnr EQ li_knbk-kunnr
                                                             AND bukrs EQ i_febko-bukrs.
            IF sy-subrc EQ 0.
              DESCRIBE TABLE li_knb1 LINES lv_lines.
              IF lv_lines EQ 1 .
                READ TABLE li_knb1 INTO lwa_knb1 INDEX 1.
                IF sy-subrc EQ 0.
                   e_febep-avkon = lwa_knb1-kunnr.
                ENDIF.
              ENDIF.
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF sy-subrc EQ 0 AND lv_customer IS NOT INITIAL
          ENDIF. " IF lv_bankk IS NOT INITIAL AND lv_bankn IS NOT INITIAL
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc EQ 0
    WHEN 'TEXT'.
      DELETE li_zotc_ebs_search WHERE zrule NE lv_rule.
      LOOP AT li_zotc_ebs_search ASSIGNING <lfs_zotc_ebs_search>.
        IF <lfs_zotc_ebs_search>-ztext IS ASSIGNED.
          lwa_ztext-ztext = <lfs_zotc_ebs_search>-ztext.
          lwa_ztext-kunnr = <lfs_zotc_ebs_search>-kunnr.
          APPEND lwa_ztext TO li_ztext.
          CLEAR lwa_ztext.
        ENDIF.
      ENDLOOP.
      READ TABLE t_febre ASSIGNING <lfs_febre> WITH KEY kukey = i_febep-kukey
                                                 esnum = i_febep-esnum
* Begin of Defect 10269
*                                                 vwezw+0(2) =  lv_tag.
                                                 vwezw+0(3) =  lv_tag.
* End of Defect 10269

      IF sy-subrc EQ 0.
        SORT li_ztext BY ztext DESCENDING.
        LOOP AT li_ztext INTO lwa_ztext.
          IF <lfs_febre>-vwezw CS lwa_ztext-ztext.
             e_febep-avkon = lwa_ztext-kunnr.
             EXIT.
          ENDIF.
        ENDLOOP.
        ENDIF.
  ENDCASE.
  ENDIF.
  ENDDO.
ENDIF. " IF sy-subrc EQ 0
*********----> End of R7 SCTASK0791864
