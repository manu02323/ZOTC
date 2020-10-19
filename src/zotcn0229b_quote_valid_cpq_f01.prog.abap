***********************************************************************
*Program    : ZOTCN0229B_QUOTE_VALID_CPQ_F01                          *
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
*&---------------------------------------------------------------------*
* 21-Aug-2019 U033876  E2DK924884 Defect10289 - OTC_IDD_0229           *
*                                check zzquoteref is not initial as to *
*                                remove vbak records based on vbap     *
*&---------------------------------------------------------------------*
*&      Form  F_GET_EMI_DATA
*&---------------------------------------------------------------------*
*       Fetch EMI Entries
*----------------------------------------------------------------------*
*      <--fp_i_status  emi entries
*----------------------------------------------------------------------*
FORM f_get_emi_data  CHANGING fp_i_status TYPE ty_t_status.

  CONSTANTS: lc_idd_0229 TYPE z_enhancement VALUE 'OTC_IDD_0229'. " Enhancement No.

* Get EMI DATA
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_idd_0229
    TABLES
      tt_enh_status     = fp_i_status.

  IF fp_i_status[] IS NOT INITIAL.
    DELETE fp_i_status[] WHERE active = abap_false.
  ENDIF. " IF fp_i_status[] IS NOT INITIAL

  IF fp_i_status[] IS NOT INITIAL.
    SORT fp_i_status BY criteria sel_low sel_high.
  ENDIF. " IF fp_i_status[] IS NOT INITIAL
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       Get data from Database
*----------------------------------------------------------------------*

FORM f_get_data  USING    fp_status TYPE ty_t_status
                 CHANGING fp_vbak   TYPE ty_t_vbak
                          fp_vbap   TYPE ty_t_vbap
                          fp_vbpa   TYPE ty_t_vbpa.
* Begin of change for Defect 10289
  DATA: lwa_vbap     TYPE ty_vbap,
        lwa_vbak     TYPE ty_vbak,
        li_no_vbeln  TYPE ty_t_fkk,
        lwa_no_vbeln TYPE fkk_ranges.
* End of change for Defect   10289


* Fetch sales orders from VBAK based on selection criterion
  SELECT vbeln     "Sales Document
         erdat
         erzet
         waerk
         vkorg
         vtweg
         kunnr
         objnr
    FROM vbak
    INTO TABLE fp_vbak
    WHERE vbeln IN s_vbeln AND
          erdat IN s_erdat AND
* Begin of change for Defect 10289
          vkorg IN s_vkorg.
* End of change for Defect   10289
  IF sy-subrc IS INITIAL.
    SORT fp_vbak BY vbeln.
* Fetch sales orders items  from VBAP based above select
    SELECT vbeln     "Sales Document
           posnr
           matnr
           uepos
           kwmeng
           zzquoteref
      FROM vbap
      INTO TABLE fp_vbap
      FOR ALL ENTRIES IN fp_vbak
      WHERE vbeln = fp_vbak-vbeln.
    IF sy-subrc = 0.
* Begin of change for Defect 10289
      DELETE fp_vbap WHERE zzquoteref IS INITIAL.
* End of change for Defect   10289
      SORT fp_vbap BY vbeln posnr.

      SELECT vbeln
             posnr
             parvw
             kunnr
          FROM vbpa INTO TABLE fp_vbpa
          FOR ALL ENTRIES IN fp_vbak
          WHERE vbeln = fp_vbak-vbeln
          AND   posnr  = c_posnr
          AND   parvw = 'WE'.   " get the ship-to
      IF sy-subrc = 0.
        SORT fp_vbpa BY vbeln  .
      ENDIF.
    ENDIF.
* Begin of change for Defect 10289
    LOOP AT fp_vbak INTO lwa_vbak .
      READ TABLE fp_vbap INTO lwa_vbap
                         WITH KEY vbeln = lwa_vbak-vbeln BINARY SEARCH.
      IF sy-subrc NE 0.
        lwa_no_vbeln-sign   = c_sign.
        lwa_no_vbeln-option = c_option.
        lwa_no_vbeln-low    = lwa_vbak-vbeln.
        APPEND lwa_no_vbeln TO li_no_vbeln.
        CLEAR  lwa_no_vbeln.
      ENDIF.
    ENDLOOP.
    IF li_no_vbeln[] IS NOT INITIAL.
      DELETE fp_vbak WHERE vbeln IN li_no_vbeln.
      DELETE fp_vbpa WHERE vbeln IN li_no_vbeln.
    ENDIF.
    IF fp_vbak[] IS INITIAL.
      MESSAGE i095. " No Data Found For The Given Selection Criteria .
      LEAVE LIST-PROCESSING.
    ENDIF.
* End of change for Defect  10289

  ELSE.
    MESSAGE i095. " No Data Found For The Given Selection Criteria .
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PROC_DATA
*&---------------------------------------------------------------------*
*  Process orders with ZCP1 user status into final internal table
*----------------------------------------------------------------------*
FORM f_proc_data  USING    fp_status TYPE ty_t_status
                           fp_vbak   TYPE ty_t_vbak
                           fp_vbap   TYPE ty_t_vbap
                           fp_vbpa   TYPE ty_t_vbpa
                  CHANGING fp_final  TYPE ty_t_final.
  DATA: lv_user_stat TYPE j_stext,
        lwa_final    TYPE ty_final.
  FIELD-SYMBOLS: <lfs_vbak>   TYPE ty_vbak,
                 <lfs_vbap>   TYPE ty_vbap,
                 <lfs_vbpa>   TYPE ty_vbpa,
                 <lfs_status> TYPE zdev_enh_status.
  CONSTANTS:lc_en     TYPE spras      VALUE 'E',
            lc_status TYPE z_criteria VALUE 'STATUS'.
  LOOP AT fp_vbak ASSIGNING <lfs_vbak>.
    CALL FUNCTION 'STATUS_TEXT_EDIT'
      EXPORTING
        client           = sy-mandt
        flg_user_stat    = abap_true
        objnr            = <lfs_vbak>-objnr
        only_active      = abap_true
        spras            = lc_en
        bypass_buffer    = ' '
      IMPORTING
        user_line        = lv_user_stat
      EXCEPTIONS
        object_not_found = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE i_status ASSIGNING <lfs_status>
                        WITH KEY criteria = lc_status
                                 sel_low  = lv_user_stat BINARY SEARCH.

    IF sy-subrc = 0.
      lwa_final-vbeln = <lfs_vbak>-vbeln.
      lwa_final-erdat = <lfs_vbak>-erdat.
      lwa_final-erzet = <lfs_vbak>-erzet.
      lwa_final-waerk = <lfs_vbak>-waerk.
      lwa_final-vkorg = <lfs_vbak>-vkorg.
      lwa_final-vtweg = <lfs_vbak>-vtweg.
      lwa_final-kunag = <lfs_vbak>-kunnr.
      lwa_final-erdat = <lfs_vbak>-erdat.
      READ TABLE fp_vbpa ASSIGNING <lfs_vbpa>
                                   WITH KEY vbeln = <lfs_vbak>-vbeln
                                            BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_final-kunnr = <lfs_vbpa>-kunnr.     "Ship-to
      ENDIF.
      LOOP AT fp_vbap ASSIGNING <lfs_vbap> WHERE vbeln = <lfs_vbak>-vbeln
                                           AND   uepos IS INITIAL.    "Only conider BOM header Item
        lwa_final-posnr      = <lfs_vbap>-posnr.
        lwa_final-matnr      = <lfs_vbap>-matnr.
        lwa_final-kwmeng     = <lfs_vbap>-kwmeng.
        lwa_final-zzquoteref = <lfs_vbap>-zzquoteref.
        APPEND lwa_final TO fp_final.

      ENDLOOP.
      CLEAR: lwa_final.
    ENDIF.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_INITIALIZATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_initialization .
  CLEAR: gv_modify,gv_scount,  gv_ecount , gv_line, gv_err_flg.
  PERFORM f_get_emi_data CHANGING i_status.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CALL_PROXY
*&---------------------------------------------------------------------*
*       call SOA to get CPQ quote validation
*----------------------------------------------------------------------*
FORM f_call_proxy  USING   fp_status    TYPE ty_t_status
                           fp_final     TYPE ty_t_final
                           fp_vbak      TYPE ty_t_vbak
                           fp_vbap      TYPE ty_t_vbap
                  CHANGING fp_error     TYPE ty_t_error.
  DATA: lref_cpq             TYPE REF TO z01otc_co_si_cpqquoteval_out, " CPQ quote class
        lv_error             TYPE string,
        lv_text              TYPE char50,           "message
        lref_cx_system_fault TYPE REF TO cx_ai_system_fault,      " Fehler Certify
        lref_cx_appl_fault   TYPE REF TO cx_ai_application_fault, " Application Integration: Application Error
*       data decleration for REQUEST details
        lwa_request_input    TYPE z01otc_cpqquote_req, " Proxy Structure (generated)
*       data decleration for line type
        lwa_req_inp_line     TYPE z01otc_cpqquote_type,
        lwa_cpq_req_line     TYPE z01otc_cpqquote_line_type,  "line items structure
* table type declaration
        li_req_inp_line      TYPE z01otc_cpqquote_type_tab,
        li_cpq_req_line      TYPE z01otc_cpqquote_line_type_tab,
*       data decleration for response details
        lwa_response         TYPE z01otc_cpqquote_resp, " Proxy Structure (generated)
        lwa_head_cond        TYPE z01otc_header_condition_type,
        lwa_cpq_quote        TYPE z01otc_cpqquote_type,
* table type declaration
        li_response_fail     TYPE z01otc_string_tab1,
        li_cpq_quote         TYPE z01otc_cpqquote_type_tab,
        li_head_cond         TYPE z01otc_header_condition_ty_tab.
* Begin of change for Defect 10289
  DATA: li_no_vbeln  TYPE ty_t_fkk,
        lwa_no_vbeln TYPE fkk_ranges.
* End of change for Defect   10289
  DATA: lwa_error TYPE ty_error,
        lwa_vbak  TYPE ty_vbak,
        lwa_final TYPE ty_final.

  SORT fp_vbak  BY vbeln.
  SORT fp_final BY vbeln posnr zzquoteref.

* Begin of change for Defect 10289
  LOOP AT fp_final  INTO lwa_final.
    READ TABLE fp_vbak INTO lwa_vbak
                       WITH KEY vbeln = lwa_final-vbeln BINARY SEARCH.
    IF sy-subrc NE 0.
      lwa_no_vbeln-sign   = c_sign.
      lwa_no_vbeln-option = c_option.
      lwa_no_vbeln-low    = lwa_final-vbeln.
      APPEND lwa_no_vbeln TO li_no_vbeln.
      CLEAR  lwa_no_vbeln.
    ENDIF.
  ENDLOOP.
  IF li_no_vbeln[] IS NOT INITIAL.
    DELETE fp_vbak WHERE vbeln IN li_no_vbeln.
  ENDIF.
* End of change for Defect   10289

  LOOP AT fp_vbak INTO lwa_vbak .
    LOOP AT fp_final  INTO lwa_final  WHERE vbeln = lwa_vbak-vbeln.
      lwa_cpq_req_line-sales_document_item      = lwa_final-posnr.
      lwa_cpq_req_line-material_number          = lwa_final-matnr.
      lwa_cpq_req_line-quantity_sales_units     = lwa_final-kwmeng.
      lwa_req_inp_line-legacy_qtn_ref           = lwa_final-zzquoteref.
      APPEND lwa_cpq_req_line TO li_cpq_req_line.
      AT END OF zzquoteref.
        lwa_req_inp_line-cpqquote_line            = li_cpq_req_line[].
        APPEND  lwa_req_inp_line TO li_req_inp_line.
        CLEAR: lwa_cpq_req_line, li_cpq_req_line[].
      ENDAT.
    ENDLOOP.
    lwa_request_input-cpqquote                = li_req_inp_line[].
    lwa_request_input-sales_document_number   = lwa_vbak-vbeln.

    CONVERT DATE lwa_vbak-erdat  TIME lwa_vbak-erzet
        INTO TIME STAMP lwa_request_input-creation_date TIME ZONE 'UTC'.

    lwa_request_input-sales_org               = lwa_vbak-vkorg.
    lwa_request_input-distribution_channel    = lwa_vbak-vtweg.
    lwa_request_input-sold_to_party           = lwa_final-kunag.
    lwa_request_input-ship_to_party           = lwa_vbak-kunnr.
    lwa_request_input-currency                = lwa_vbak-waerk.


****************************************************************
******************** Create Instance ***************************
****************************************************************

    TRY.

*     Create instance for class z01otc_co_si_cpqquoteval_out
        CREATE OBJECT lref_cpq.

      CATCH cx_ai_system_fault INTO lref_cx_system_fault.
        lv_error  = lref_cx_system_fault->get_text( ).
        CONCATENATE 'Error in Order:'(004) lwa_final-vbeln
                    'Exception during proxy call'(006)
                    INTO lv_text
                    SEPARATED BY space.
        lwa_error-msgtyp  = c_error.
        lwa_error-msgtxt  = lv_error.
        lwa_error-key     = lv_text.
        APPEND lwa_error TO fp_error.
        CLEAR: lwa_error.
    ENDTRY.
*  Instance created successfuly now code to call the proxy
    IF NOT lref_cpq IS INITIAL.
      TRY.
          CALL METHOD lref_cpq->si_cpqquoteval_out
            EXPORTING
              output = lwa_request_input
            IMPORTING
              input  = lwa_response.

        CATCH cx_ai_system_fault INTO lref_cx_system_fault.
          lv_error  = lref_cx_system_fault->get_text( ).
          CONCATENATE 'Error in Order:'(004) lwa_final-vbeln
                    'Exception during proxy call'(006)
                    INTO lv_text
                    SEPARATED BY space.
          lwa_error-msgtyp  = c_error.
          lwa_error-msgtxt  = lv_error.
          lwa_error-key     = lv_text.
          APPEND lwa_error TO fp_error.
          CLEAR: lwa_error.
        CATCH cx_ai_application_fault INTO lref_cx_appl_fault.
          lv_error  = lref_cx_appl_fault->get_text( ).
          CONCATENATE 'Error in Order:'(004) lwa_final-vbeln
                      'Exception during proxy call'(006)
                    INTO lv_text
                    SEPARATED BY space.
          lwa_error-msgtyp  = c_error.
          lwa_error-msgtxt  = lv_error.
          lwa_error-key     = lv_text.
          APPEND lwa_error TO fp_error.
          CLEAR: lwa_error.
      ENDTRY.
    ENDIF.

    IF lwa_response-result_validate IS NOT INITIAL.
      CASE lwa_response-result_validate .
        WHEN 'PASS'.
* IF pass  then we need to update the pricing for each line item.
          PERFORM f_update_pricing  USING lwa_response-result_validate
                                          lwa_response-sales_document_number
                                          lwa_response-header_condition
                                          lwa_response-cpqquote
                                          fp_vbak
                                          fp_status
                                    CHANGING fp_error.


        WHEN 'FAIL'.
* IF fail then  failed we also need to update reasons for fail in header text
* "Internal note" with text type "Z001". Then we need to update user status with ZCP2.
          PERFORM f_update_text_status  USING lwa_response-result_validate
                                          lwa_response-sales_document_number
                                          lwa_response-header_condition
                                          lwa_response-reason_fail
                                          lwa_response-cpqquote
                                          fp_vbak
                                          fp_status
                                        CHANGING fp_error.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.
  ENDLOOP.




ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_PRICING
*&---------------------------------------------------------------------*
*     In this form we update pricing and status of header
*----------------------------------------------------------------------*
FORM f_update_pricing  USING    fp_result_validate  TYPE string
                                fp_sales_doc_number TYPE string
                                fp_header_condition TYPE z01otc_header_condition_ty_tab
                                fp_cpq_quote        TYPE z01otc_cpqquote_type_tab
                                fp_vbak             TYPE ty_t_vbak
                                fp_status           TYPE ty_t_status
                       CHANGING fp_error            TYPE ty_t_error.


  DATA : lv_user_status TYPE j_status. " Object status
  DATA : lv_objnr       TYPE j_objnr. " Object number
  DATA : lv_stonr    TYPE j_stonr, " Status Order Number
         lv_vbeln_va TYPE vbeln_va,
         lv_text     TYPE char50,
         lwa_error   TYPE ty_error,
         li_return   TYPE bapiret2_tab.
  FIELD-SYMBOLS: <lfs_return> TYPE bapiret2,  " Return Parameter
                 <lfs_vbak>   TYPE ty_vbak.

* Update Pricing
  lv_vbeln_va = fp_sales_doc_number.
  PERFORM f_upd_pricing  USING fp_result_validate
                               fp_sales_doc_number
                               fp_header_condition
                               fp_cpq_quote
                               fp_vbak
                               fp_status
                         CHANGING li_return .

  READ TABLE li_return ASSIGNING <lfs_return> WITH KEY type = c_error. " Return assigning of type
  IF sy-subrc <> 0.
    READ TABLE fp_vbak ASSIGNING <lfs_vbak>
                                WITH KEY vbeln = lv_vbeln_va BINARY SEARCH.
    IF sy-subrc = 0.
      lv_objnr = <lfs_vbak>-objnr.
      lv_user_status = 'E0003'.

      PERFORM f_update_status USING   lv_objnr
                                      lv_user_status
                              CHANGING fp_error.
      READ TABLE fp_error TRANSPORTING NO FIELDS
                            WITH KEY msgtyp  = c_error.
      IF sy-subrc NE 0.
        CONCATENATE 'Order:'(007) lv_vbeln_va
                    'Successfully processed'(008)
                    INTO lv_text
                    SEPARATED BY space.
        lwa_error-msgtyp  = c_success.
        lwa_error-key     = lv_text.
        APPEND lwa_error TO fp_error.
        CLEAR: lwa_error.
        gv_scount = gv_scount + 1.
      ENDIF.
    ENDIF.

  ELSE. " ELSE -> IF sy-subrc <> 0
* roll back bapi
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CONCATENATE 'Error in Order:'(004) lv_vbeln_va
                'please check the application log'(005)
                INTO lv_text
                SEPARATED BY space.
    lwa_error-msgtyp  = c_error.
    lwa_error-key     = lv_text.
    APPEND lwa_error TO fp_error.
    CLEAR: lwa_error.
**   implement error logging logic
    PERFORM f_create_application_log USING li_return    " BAPI return table
                                           lv_vbeln_va. " Delivery number
    gv_ecount = gv_ecount + 1.
  ENDIF. " IF sy-subrc <> 0


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_TEXT_STATUS
*&---------------------------------------------------------------------*
*       update pricing, header text(with error log) and status
*----------------------------------------------------------------------*
FORM f_update_text_status  USING    fp_result_validate      TYPE string
                                    fp_sales_doc_number     TYPE string
                                    fp_header_condition     TYPE z01otc_header_condition_ty_tab
                                    fp_response_reason_fail TYPE z01otc_string_tab1
                                    fp_cpq_quote            TYPE z01otc_cpqquote_type_tab
                                    fp_vbak                 TYPE ty_t_vbak
                                    fp_status               TYPE ty_t_status
                           CHANGING fp_error                TYPE ty_t_error.

  DATA: lv_vbeln_va     TYPE vbeln_va,                    " Sales Document
        lwa_reason_fail TYPE string,
        lwa_header      TYPE thead, " Header workarea
        lwa_tline       TYPE tline, " Long Text
        lwa_error       TYPE ty_error,
        lv_text         TYPE char50,
        li_tline        TYPE STANDARD TABLE OF tline,
        li_return       TYPE bapiret2_tab.

  DATA : lv_objnr       TYPE j_objnr, " Object number
         lv_user_status TYPE j_status. " Object status
  FIELD-SYMBOLS: <lfs_return> TYPE bapiret2,  " Return Parameter
                 <lfs_vbak>   TYPE ty_vbak.
*&&-- Declaration of Local Constants
  CONSTANTS: lc_condition TYPE tdobject VALUE 'VBBK',
             "Texts: Sales     Header texts
             lc_id        TYPE tdid VALUE 'Z001'. " Internal Note

  lv_vbeln_va = fp_sales_doc_number.

* Update Pricing

  PERFORM f_upd_pricing  USING fp_result_validate
                               fp_sales_doc_number
                               fp_header_condition
                               fp_cpq_quote
                               fp_vbak
                               fp_status
                        CHANGING li_return .
  READ TABLE li_return ASSIGNING <lfs_return> WITH KEY type = c_error. " Return assigning of type
  IF sy-subrc <> 0.   "no error
*&&-- Populate Header Data for SAVE_TEXT
**Populate text object
    CLEAR lwa_header.
    lwa_header-tdobject = lc_condition.
**Populate Text ID
    lwa_header-tdid = lc_id.
**populate text language
    lwa_header-tdspras = sy-langu.
    lwa_header-tdname = lv_vbeln_va .
* Populate Date and Time before updating th einternal note header text
    lwa_tline-tdformat = '*'.
    CONCATENATE 'Date Added:'(015) sy-datum 'and Time:'(016)
                                   sy-uzeit INTO lwa_tline-tdline
                                   SEPARATED BY  space.
    APPEND lwa_tline TO li_tline.
    CLEAR: lwa_tline.

    LOOP AT fp_response_reason_fail INTO lwa_reason_fail.
      lwa_tline-tdformat = '*'.
      lwa_tline-tdline   =  lwa_reason_fail.
      APPEND lwa_tline TO li_tline.
      CLEAR lwa_tline.
    ENDLOOP.
    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        client          = sy-mandt
        header          = lwa_header
        insert          = abap_true
        savemode_direct = abap_true
      TABLES
        lines           = li_tline
      EXCEPTIONS
        id              = 1
        language        = 2
        name            = 3
        object          = 4
        OTHERS          = 5.
    IF sy-subrc IS NOT INITIAL.
      CONCATENATE 'Error in Order:'(004) lv_vbeln_va
                  'While header text save'(009)
                  INTO lv_text
                  SEPARATED BY space.
      lwa_error-msgtyp  = c_error.
      lwa_error-key     = lv_text.
      APPEND lwa_error TO fp_error.
      CLEAR: lwa_error.
    ELSE.

      CALL FUNCTION 'COMMIT_TEXT' .
      CONCATENATE 'Order:'(007) lv_vbeln_va
                  'header text->internal note updated '(014)
                  INTO lv_text
                  SEPARATED BY space.
      lwa_error-msgtyp  = c_success.
      lwa_error-key     = lv_text.
      APPEND lwa_error TO fp_error.
      CLEAR: lwa_error.
    ENDIF.
    CLEAR lwa_header-tdname.
    REFRESH li_tline.


    READ TABLE fp_vbak ASSIGNING <lfs_vbak>
                                WITH KEY vbeln = lv_vbeln_va BINARY SEARCH.
    IF sy-subrc = 0.
      lv_objnr = <lfs_vbak>-objnr.
      lv_user_status = 'E0003'.

      PERFORM f_update_status USING   lv_objnr
                                      lv_user_status
                              CHANGING fp_error.

    ENDIF.
    gv_scount = gv_scount + 1.
  ELSE.
* roll back bapi
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CONCATENATE 'Error in Order:'(004) lv_vbeln_va
                'please check the application log'(005)
                INTO lv_text
                SEPARATED BY space.
    lwa_error-msgtyp  = c_error.
    lwa_error-key     = lv_text.
    APPEND lwa_error TO fp_error.
    CLEAR: lwa_error.

**   implement error logging logic
    PERFORM f_create_application_log USING li_return    " BAPI return table
                                           lv_vbeln_va. " Delivery number
    gv_ecount = gv_ecount + 1.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_VBELN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_vbeln .
  DATA: lv_vbeln TYPE vbeln_va. " Local Variable for Sales Document
  SELECT vbeln        " Sales Document
         UP TO 1 ROWS
         FROM  vbak " Revenue Recognition: Revenue Recognition Lines
         INTO  lv_vbeln
         WHERE vbeln IN s_vbeln.
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE e000  WITH 'Sales Document Does Not Exist'(002). "Invalid Sales Document
  ENDIF. " IF sy-subrc NE 0
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_STATUS
*&---------------------------------------------------------------------*
*       Update user status on order
*----------------------------------------------------------------------*
FORM f_update_status  USING    fp_objnr TYPE j_objnr
                               fp_user_status TYPE j_status
                      CHANGING fp_error TYPE ty_t_error .

  DATA : lv_stonr  TYPE j_stonr, " Status Order Number
         lv_text   TYPE char50,
         lwa_error TYPE ty_error.
**** Updating the required status .
  CALL FUNCTION 'STATUS_CHANGE_EXTERN'
    EXPORTING
      objnr               = fp_objnr
      user_status         = fp_user_status
    IMPORTING
      stonr               = lv_stonr
    EXCEPTIONS
      object_not_found    = 1
      status_inconsistent = 2
      status_not_allowed  = 3
      OTHERS              = 4.
  IF sy-subrc IS INITIAL AND lv_stonr IS NOT INITIAL.

*                   Commit BAPI
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    CONCATENATE 'Status:'(010) fp_user_status
            'Updated'(012)
            INTO lv_text
            SEPARATED BY space.
    lwa_error-msgtyp  = c_success.
    lwa_error-key     = lv_text.
    APPEND lwa_error TO fp_error.
    CLEAR: lwa_error.
  ELSE.
* roll back bapi
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    CONCATENATE 'Status:'(010) fp_user_status
            'Could not be updated'(011)
            INTO lv_text
            SEPARATED BY space.
    lwa_error-msgtyp  = c_error.
    lwa_error-key     = lv_text.
    APPEND lwa_error TO fp_error.
    CLEAR: lwa_error.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_UPD_PRICING
*&---------------------------------------------------------------------*
*       Update header and Item pricing
*----------------------------------------------------------------------*
FORM f_upd_pricing  USING     fp_result_validate  TYPE string
                              fp_sales_doc_number TYPE string
                              fp_header_condition TYPE z01otc_header_condition_ty_tab
                              fp_cpq_quote        TYPE z01otc_cpqquote_type_tab
                              fp_vbak             TYPE ty_t_vbak
                              fp_status           TYPE ty_t_status
                    CHANGING  fp_li_return        TYPE bapiret2_tab.

  DATA: lv_vbeln_va       TYPE vbeln_va,                    " Sales Document
        lx_ordhdrx        TYPE bapisdh1x,                   " Checkbox List: SD Order Header
        lx_conda          TYPE bapicond,                    " Communication Fields for Maintaining Conditions in the Order
        lx_condx          TYPE bapicondx,                   " Communication Fields for Maintaining Conditions in the Order
        lt_conda          TYPE STANDARD TABLE OF bapicond,  " Communication Fields for Maintaining Conditions in the Order
        lt_condx          TYPE STANDARD TABLE OF bapicondx, " Communication Fields for Maintaining Conditions in the Order
        lwa_head_cond     TYPE z01otc_header_condition_type,
        lwa_cpqquote_line TYPE z01otc_cpqquote_line_type,
        lwa_header_in     TYPE bapisdh1,
        lwa_status        TYPE zdev_enh_status,
        lwa_cpq_quote     TYPE z01otc_cpqquote_type,

        li_return         TYPE bapiret2_tab  . "Return Table from BAPI

  FIELD-SYMBOLS: <lfs_return> TYPE bapiret2,  " Return Parameter
                 <lfs_vbak>   TYPE ty_vbak.

  CONSTANTS: lc_lifsk TYPE z_criteria VALUE 'LIFSK',
             lc_u     TYPE char1      VALUE 'U'. "Update

  IF fp_sales_doc_number IS NOT INITIAL.

    lv_vbeln_va = fp_sales_doc_number.
    READ TABLE fp_vbak ASSIGNING <lfs_vbak>
                                WITH KEY vbeln = lv_vbeln_va BINARY SEARCH.
    IF sy-subrc = 0.


      lx_ordhdrx-updateflag = lc_u.

* set the delivery block if fp_result_validate = fail.
      IF fp_result_validate = 'FAIL'.
        READ TABLE fp_status INTO lwa_status
                             WITH KEY criteria = lc_lifsk
                                      active   = abap_true.
        IF sy-subrc = 0.
          lwa_header_in-dlv_block = lwa_status-sel_low.
          lx_ordhdrx-dlv_block    = abap_true.
        ENDIF.
      ENDIF.
      LOOP AT fp_header_condition INTO lwa_head_cond.
        lx_conda-cond_type = lwa_head_cond-header_condition_type.
        lx_condx-cond_type = abap_true.
        lx_conda-cond_value = lwa_head_cond-header_condition_value.
* Divide by 10 as inside the BAPI value is getting multiplied by 10.
        lx_conda-cond_value = ( lx_conda-cond_value / 10 ).
        lx_condx-cond_value = abap_true.
        APPEND lx_conda  TO lt_conda.
        APPEND lx_condx  TO lt_condx.
      ENDLOOP.
* Item conditions
      READ TABLE  fp_cpq_quote INTO lwa_cpq_quote INDEX 1.
      IF sy-subrc = 0.
        LOOP AT lwa_cpq_quote-cpqquote_line INTO lwa_cpqquote_line .
          lx_conda-itm_number = lwa_cpqquote_line-sales_document_item.
          lx_condx-itm_number = abap_true.
          lx_conda-cond_type = lwa_cpqquote_line-item_condition_type.
          lx_condx-cond_type = abap_true.
          lx_conda-cond_value = lwa_cpqquote_line-item_discount_value.
* Divide by 10 as inside the BAPI value is getting multiplied by 10.
          lx_conda-cond_value = ( lx_conda-cond_value / 10 ).
          lx_condx-cond_value = abap_true.
          APPEND lx_conda  TO lt_conda.
          APPEND lx_condx  TO lt_condx.
        ENDLOOP.
      ENDIF.

      IF lt_conda[] IS NOT INITIAL.

        CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
          EXPORTING
            salesdocument    = lv_vbeln_va
            order_header_in  = lwa_header_in
            order_header_inx = lx_ordhdrx
          TABLES
            return           = li_return
            conditions_in    = lt_conda
            conditions_inx   = lt_condx.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_APPLICATION_LOG
*&---------------------------------------------------------------------*
*       Create custom application log
*----------------------------------------------------------------------*
*      -->FP_LI_RETURN  Return parameter
*----------------------------------------------------------------------*
FORM f_create_application_log  USING    fp_li_return TYPE bapiret2_tab
                                        fp_lv_vbeln  TYPE vbeln.
*--INTERNAL TABLE------------------------------------------------------*

  DATA : li_log_handle  TYPE bal_t_logh. " Application Log: Log Handle

*--WORK AREA-----------------------------------------------------------*
  DATA : lwa_log        TYPE bal_s_log,  " Application Log: Log header data
         lwa_log_handle TYPE balloghndl, " Application Log: Log Handle
         lwa_balmsg     TYPE bal_s_msg.  " Application Log: Message Data

*--FIELD SYMBOLS-------------------------------------------------------*
  FIELD-SYMBOLS : <lfs_bapiret> TYPE bapiret2. " Return Parameter

  CONSTANTS: lc_object     TYPE balobj_d    VALUE 'ZOTCLOG',     " Application Log: Object Name (Application Code)
             lc_sub_object TYPE balsubobj   VALUE 'ZOTCIDD0229'. " Application Log: Subobject

  lwa_log-extnumber = fp_lv_vbeln.
  lwa_log-object    = lc_object.
  lwa_log-subobject = lc_sub_object.

  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log                 = lwa_log
    IMPORTING
      e_log_handle            = lwa_log_handle
    EXCEPTIONS
      log_header_inconsistent = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF. " IF sy-subrc <> 0

  APPEND lwa_log_handle TO li_log_handle.

  LOOP AT fp_li_return ASSIGNING <lfs_bapiret> .
    CLEAR lwa_balmsg.
    lwa_balmsg-msgty = <lfs_bapiret>-type.
    lwa_balmsg-msgid = <lfs_bapiret>-id.
    lwa_balmsg-msgno = <lfs_bapiret>-number.
    lwa_balmsg-msgv1 = <lfs_bapiret>-message_v1.
    lwa_balmsg-msgv2 = <lfs_bapiret>-message_v2.
    lwa_balmsg-msgv3 = <lfs_bapiret>-message_v3.
    lwa_balmsg-msgv4 = <lfs_bapiret>-message_v4.

    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = lwa_log_handle
        i_s_msg          = lwa_balmsg
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF. " IF sy-subrc <> 0
  ENDLOOP. " LOOP AT fp_li_return ASSIGNING <lfs_bapiret1>


  CALL FUNCTION 'BAL_DB_SAVE'
    EXPORTING
      i_save_all       = abap_true
      i_t_log_handle   = li_log_handle
    EXCEPTIONS
      log_not_found    = 1
      save_not_allowed = 2
      numbering_error  = 3
      OTHERS           = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF. " IF sy-subrc <> 0
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_SUMMARY_REPORT
*&---------------------------------------------------------------------*
*       summary report                                                 *
*----------------------------------------------------------------------*
FORM f_display_summary_report  USING    fp_error TYPE ty_t_error.



  DATA: lr_alv         TYPE REF TO cl_salv_table,

        lr_alv_cols    TYPE REF TO cl_salv_columns,

        lr_alv_func    TYPE REF TO cl_salv_functions,

        lrx_salv_error TYPE REF TO cx_salv_error.

  TRY.

      cl_salv_table=>factory( IMPORTING r_salv_table = lr_alv

      CHANGING t_table = fp_error ).

* configure columns

      lr_alv_cols = lr_alv->get_columns( ).

      lr_alv_cols->set_optimize( ).

* active all alv functions

      lr_alv_func = lr_alv->get_functions_base( ).

      lr_alv_func->set_all( ).

      lr_alv->display( ).

    CATCH cx_salv_error INTO lrx_salv_error.

  ENDTRY.



*  CREATE OBJECT lr_alv
*    EXPORTING
*      i_parent = cl_gui_container=>screen0.
*
*  CALL METHOD lr_alv->set_table_for_first_display
*    CHANGING
*      it_fieldcatalog = li_fieldcat
*      it_outtab       = fp_error.


ENDFORM.
