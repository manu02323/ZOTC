FUNCTION zotc_chk_future_price_record.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_KONH) TYPE  KONH
*"     REFERENCE(IM_BDCPV) TYPE  BDCPV
*"  EXPORTING
*"     REFERENCE(EX_CRETIME) TYPE  CPCRETIME
*"----------------------------------------------------------------------
************************************************************************
* Progam     : ZOTC_CHK_FUTURE_PRICE_RECORD(Function module)           *
* Title      : Filter Message Type ZOTC_COND_A                         *
* Developer  : Manish Bagda                                            *
* Object type: Interface                                               *
* SAP Release: SAP ECC 6.0                                             *
*----------------------------------------------------------------------*
* WRICEF ID  : D2_OTC_IDD_0093                                         *
*----------------------------------------------------------------------*
* Description: This FM is used to check the future price record.       *
* This FM is copied from the SAP standard code in the subroutine       *
* A_TAB_READ in the include LVKOEF01.At the end a section of code is   *
* added to check the Validity start date of the condition record and   *
* if it is greater than current date concatenate the date and time and *
* pass it to the export parameter.                                     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:
*======================================================================*
* Date           User        Transport       Description
*=========== ============== ============== ============================*
* Oct-27-2015  MBAGDA     E2DK915852     Incident INC0249304 PGL B     *
* Check the future price record.
*----------------------------------------------------------------------*
* Nov-20-2015  MBAGDA     E2DK915852     Defect 1285                   *
* Additional fix for future dates
*----------------------------------------------------------------------*
  CONSTANTS:
     lc_000000(6)                             VALUE '000000',
     lc_kvewe            LIKE konh-kvewe      VALUE 'A', " Usage of the condition table
     lc_kvewe_e          LIKE konh-kvewe      VALUE 'E', " Usage of the condition table
     lc_tab_a(1)                              VALUE 'A',
     lc_tab_e(4)                              VALUE 'KOTE',
*--> Begin of insert for D2_OTC_IDD_0093/Defect 1285 by MBAGDA
     lc_kondat           TYPE cdtabname       VALUE 'KONDAT', " Change document creation: Table name
     lc_datab            TYPE fieldname       VALUE 'DATAB'.  " Field Name-Date From
*<-- End of insert for D2_OTC_IDD_0093/Defect 1285 by MBAGDA

  STATICS:
    lv_kvewe             TYPE kvewe,    " Usage of the condition table
    lv_kotabnr           TYPE kotabnr,  " Condition table
    lv_kotab             TYPE kotab,    " Condition table
    lv_ksdat             TYPE ksdat,    " ID: Condition structure has validity period
    lv_access_program    TYPE progname, " ABAP Program Name
*--> Begin of insert for D2_OTC_IDD_0093/Defect 1285 by MBAGDA
    lv_datab             TYPE datab,     " Valid-From Date
*<-- End of insert for D2_OTC_IDD_0093/Defect 1285 by MBAGDA
    li_tmc1k             TYPE TABLE OF tmc1k WITH HEADER LINE. " Key Elements in Generated DDIC Structures

  DATA:
    lwa_komg             TYPE komg,                   " Allowed Fields for Condition Structures
    lwa_t681             TYPE t681,                   " Conditions: Structures
    lwa_where_string     TYPE string,
    lv_string_in(132),
    li_a000              TYPE STANDARD TABLE OF a000. " Condition Table for Pricing $

  FIELD-SYMBOLS:
    <lfs_single_field>   TYPE any,
    <lfs_string_in>      TYPE any,
    <lfs_a000>           LIKE LINE OF li_a000.


*--> Begin of insert for D2_OTC_IDD_0093/Defect 1285 by MBAGDA
* Get Date from
  IF im_bdcpv-tabname = lc_kondat AND
     im_bdcpv-fldname = lc_datab.
    lv_datab = im_bdcpv-tabkey+10(8).

*Check the Valid from date is greater than system date
    IF lv_datab > sy-datum.
      ex_cretime = lv_datab. "DATAB-Validity start date of the condition record
*concatenate the Validity start date of the condition record and time
      CONCATENATE ex_cretime lc_000000 INTO ex_cretime.
      CONDENSE ex_cretime NO-GAPS.
    ENDIF. " IF lv_datab > sy-datum
    RETURN.
  ENDIF. " IF im_bdcpv-tabname = lc_kondat AND
*<-- End of insert for D2_OTC_IDD_0093/Defect 1285 by MBAGDA

  ASSIGN lv_string_in TO <lfs_string_in>.

  IF im_konh-kvewe <> lv_kvewe OR
     im_konh-kotabnr <> lv_kotabnr.
*--- determine access program and check re-generation
    CALL FUNCTION 'RV_T681_SELECT_AND_GENERATE'
      EXPORTING
        caa_kvewe          = im_konh-kvewe
        caa_kotabnr        = im_konh-kotabnr
        caa_select_text    = ' '
      IMPORTING
        caa_t681           = lwa_t681
        caa_access_program = lv_access_program
      EXCEPTIONS
        not_found          = 1
        OTHERS             = 2.

    CHECK sy-subrc IS INITIAL.

    lv_kvewe   = im_konh-kvewe.
    lv_kotabnr = im_konh-kotabnr.
    lv_ksdat   = lwa_t681-ksdat.

*--- merge KOTAB
    CASE im_konh-kvewe.
      WHEN lc_kvewe.
        CONCATENATE lc_tab_a im_konh-kotabnr INTO lv_kotab.
      WHEN lc_kvewe_e.
        CONCATENATE lc_tab_e im_konh-kotabnr INTO lv_kotab.
      WHEN OTHERS.
        CONCATENATE lc_tab_a im_konh-kotabnr INTO lv_kotab.
    ENDCASE.

*--- get the vakey fields of KOTAB
    SELECT * FROM tmc1k INTO TABLE li_tmc1k WHERE gstru = lv_kotab.
    CHECK sy-subrc IS INITIAL.
  ENDIF. " IF im_konh-kvewe <> lv_kvewe OR

*--- fill the KOMG structure
  PERFORM fill_komg_from_vakey IN PROGRAM (lv_access_program)
          USING lwa_komg im_konh-vakey.

*--- build up the WHERE string for dynamical selection
  CONCATENATE 'KAPPL = '''
              im_konh-kappl
              ''' AND  KSCHL = '''
              im_konh-kschl
              ''''
              INTO lwa_where_string.

*--- LOOP at the vakey fields
  LOOP AT li_tmc1k.

    ASSIGN COMPONENT li_tmc1k-stfna OF STRUCTURE lwa_komg
      TO <lfs_single_field>.
    MOVE <lfs_single_field> TO <lfs_string_in>.

    REPLACE ALL OCCURRENCES OF '''' IN <lfs_string_in> WITH ''''''.

    CONCATENATE lwa_where_string
                'AND'
                li_tmc1k-stfna
                INTO lwa_where_string SEPARATED BY space.

    CONCATENATE lwa_where_string
                ' = '''
                <lfs_string_in>
                ''''
                INTO lwa_where_string.
  ENDLOOP. " LOOP AT li_tmc1k


  CONCATENATE lwa_where_string
              ' AND KNUMH = '''
              im_konh-knumh
              ''''
              INTO lwa_where_string.

*--- read the specific condition record
  SELECT * FROM (lv_kotab) BYPASSING BUFFER
    INTO CORRESPONDING FIELDS OF TABLE li_a000 WHERE (lwa_where_string).
* begin of code added for the enhancement after copying the standard code
  IF sy-subrc = 0.
    READ TABLE li_a000 ASSIGNING <lfs_a000> INDEX 1.
    IF sy-subrc = 0.
* Condition start date will be change pointer creation date
*Check the Valid from date is greater than system date
      IF <lfs_a000>-datab > sy-datum.
        ex_cretime = <lfs_a000>-datab. "DATAB-Validity start date of the condition record
*concatenate the Validity start date of the condition record and time
        CONCATENATE ex_cretime lc_000000 INTO ex_cretime.
        CONDENSE ex_cretime NO-GAPS.
      ENDIF. " IF <lfs_a000>-datab > sy-datum
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF sy-subrc = 0
* end of code added for the enhancement after copying the standard code
ENDFUNCTION.
