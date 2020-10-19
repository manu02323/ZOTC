*&---------------------------------------------------------------------*
*&  Include           ZOTCN0197O_REQUEST_CERT_SUB
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0197O_REQUEST_CERT_SUB                            *
* TITLE      :  Request Certificate of Origin                          *
* DEVELOPER  :  NEHA GARG                                              *
* OBJECT TYPE:  INTERFACE                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D3_OTC_IDD_0197_SAP                                      *
*----------------------------------------------------------------------*
* DESCRIPTION: Subroutines                                             *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 01-JUL-2016 NGARG    E1DK919089 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*
* 18-OCT-2016 MGARG   E1DK919089  D3_CR_0077&Defect_4188:              *
*                                 Build two BRFPLUS tables to store    *
*                                 commodity code desc& User logon      *
*                                 information. Added code to fetch EMI *
*                                 entries as country(sel_low)value     *
*&---------------------------------------------------------------------*
* 09-Dec-2016 NGARG  E1DK919089 Defect#7379 : Copy billing document to *
*                               OBSERVATION field , Convert currency to*
*                               USD and then to sold to  party         *
*                               country's curency , and add street to  *
*                               recipient address                      *
*&---------------------------------------------------------------------*
* 18-May-2017 U033876  E1DK928015 Defect#2798 : Incident INC0338515    *
*                                Populated Ship-To Address Instead of  *
*                               Sold-To in IDD_0197 Interface Program  *
*&---------------------------------------------------------------------*
* 21-June-2017 U033876 E1DK928015 Defect#3039 : Incident INC0338515    *
*                               Gross weight to be calulated based of  *
*                               billing document item gross weight and *
*                               Net weight of billing item to be groupe*
*                               based on country of origin of material *
*                               and commodity code
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  INITIALIZATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_initialization .

  CLEAR: gv_oc,
         gv_bills,
         gv_docs,
         i_status,
         i_vbrp,
         i_vbrk,
         i_likp,
         i_vbfa,
         i_eipo,
         i_eikp,
* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188&Defect_4188 by MGARG
         gv_country.
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188&Defect_4188 by MGARG

  PERFORM f_get_emi_data CHANGING i_status.

* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188&Defect_4188 by MGARG
** Get Country code
  gv_country =  p_countr.
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188&Defect_4188 by MGARG


ENDFORM. " INITIALIZATION

*&---------------------------------------------------------------------*
*&      Form  MODIFY_SEL_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_sel_screen .

  CONSTANTS: lc_1 TYPE char1 VALUE '1',     " 1 of type CHAR1
             lc_2 TYPE char1 VALUE '2',     " 2 of type CHAR1
             lc_3 TYPE char1 VALUE '3',     " 3 of type CHAR1
             lc_4 TYPE char1 VALUE '4',     " 4 of type CHAR1
             lc_md1 TYPE char3 VALUE 'MD1', " Md1 of type CHAR3
             lc_md0 TYPE char3 VALUE 'MD0', " Md0 of type CHAR3
             lc_md2 TYPE char3 VALUE 'MD2', " Md2 of type CHAR3
             lc_md3 TYPE char3 VALUE 'MD3'. " Md3 of type CHAR3


  LOOP AT SCREEN.


    IF p_gestyp = lc_1. "id MD0

      IF screen-group1 = lc_md1 OR screen-group1 =  lc_md2 OR screen-group1 = lc_md3.
        screen-invisible = 1.
        screen-active = 0.
      ENDIF. " IF screen-group1 = lc_md1 OR screen-group1 = lc_md2 OR screen-group1 = lc_md3

    ELSEIF p_gestyp = lc_2. "id MD1

      IF screen-group1 = lc_md0 OR screen-group1 = lc_md2 OR screen-group1 = lc_md3.
        screen-invisible = 1.
        screen-active = 0.
      ENDIF. " IF screen-group1 = lc_md0 OR screen-group1 = lc_md2 OR screen-group1 = lc_md3

    ELSEIF p_gestyp = lc_3. "id MD2

      IF screen-group1 = lc_md0 OR screen-group1 = lc_md1 OR screen-group1 = lc_md3.
        screen-invisible = 1.
        screen-active = 0.
      ENDIF. " IF screen-group1 = lc_md0 OR screen-group1 = lc_md1 OR screen-group1 = lc_md3

    ELSEIF p_gestyp = lc_4. "id MD3

      IF screen-group1 = lc_md0 OR screen-group1 = lc_md1 OR screen-group1 = lc_md2.
        screen-invisible = 1.
        screen-active = 0.
      ENDIF. " IF screen-group1 = lc_md0 OR screen-group1 = lc_md1 OR screen-group1 = lc_md2

    ENDIF. " IF p_gestyp = lc_1

    MODIFY SCREEN.
    CONTINUE.

  ENDLOOP. " LOOP AT SCREEN


ENDFORM. " MODIFY_SEL_SCREEN


*&---------------------------------------------------------------------*
*&      Form  fill_ss_listboxes
*&---------------------------------------------------------------------*
*       Fill Listboxes
*----------------------------------------------------------------------*
FORM f_fill_ss_listboxes
* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
                         USING fp_i_status TYPE ty_t_status.
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

  DATA: lv_id1    TYPE vrm_id.
  DATA: li_list1  TYPE vrm_values.

  DATA: lv_id2    TYPE vrm_id.
  DATA: li_list2  TYPE vrm_values.
  DATA: lwa_list2 TYPE vrm_value.

  CONSTANTS:
      lc_gestyp_p TYPE vrm_id VALUE 'P_GESTYP',
      lc_behand_p TYPE vrm_id VALUE 'P_BEHAND',
      lc_1        TYPE char1 VALUE '1', " 1 of type CHAR1
      lc_2        TYPE char1 VALUE '2', " 2 of type CHAR1
      lc_3        TYPE char1 VALUE '3', " 3 of type CHAR1
      lc_4        TYPE char1 VALUE '4', " 4 of type CHAR1
* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
      lc_country     TYPE char8       VALUE 'P_COUNTR',     " Country of type CHAR8
      lc_organ       TYPE z_criteria  VALUE 'ORGANIZATION', " Enh. Criteria
      lc_ch          TYPE char2       VALUE 'CH',           " Ch of type CHAR2
      lc_behand      TYPE z_criteria  VALUE 'BEHAND',       " Enh. Criteria
      lc_gesty_text  TYPE z_criteria  VALUE 'GESTYP_TEXT'.  " Enh. Criteria
  FIELD-SYMBOLS :
      <lfs_status> TYPE zdev_enh_status. " Enhancement Status
  DATA:
      lv_id3      TYPE vrm_id,
      li_list3    TYPE vrm_values,
      lv_text     TYPE fpb_low . " From Value
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

* Type Of Request
  lv_id1 = lc_gestyp_p.

* ---> Begin of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
**This code is commented as there is need to pick description from EMI table
** based on the orgarnization selection
*  lwa_list2-key = lc_1. "'1'.
*  lwa_list2-text = 'Origin certificate with invoice authentication'(017).
*  APPEND lwa_list2 TO li_list1.
*
*  lwa_list2-key = lc_2.
*  lwa_list2-text = 'Origin certificate'(018).
*  APPEND lwa_list2 TO li_list1.
*
*  lwa_list2-key = lc_3.
*  lwa_list2-text = 'Invoice authentication'(019).
*  APPEND lwa_list2 TO li_list1.
*
*  lwa_list2-key = lc_4.
*  lwa_list2-text = 'Document certification'(020).
*  APPEND lwa_list2 TO li_list1.
* ---> End of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
**** Code is implemented to pick EMI value w.r.t country

** List key 1
  lwa_list2-key = lc_1.

  CLEAR lv_text.
  CONCATENATE gv_country lc_1 INTO lv_text
              SEPARATED BY c_underscore.
  READ TABLE fp_i_status ASSIGNING <lfs_status>
   WITH KEY criteria = lc_gesty_text
             sel_low = lv_text
             BINARY SEARCH.
  IF sy-subrc = 0 .
    lwa_list2-text = <lfs_status>-sel_high.
  ENDIF. " IF sy-subrc = 0

  APPEND lwa_list2 TO li_list1.
  CLEAR lwa_list2.

** List key 2
  lwa_list2-key = lc_2.
  CLEAR lv_text.
  CONCATENATE gv_country lc_2 INTO lv_text
              SEPARATED BY c_underscore.
  READ TABLE fp_i_status ASSIGNING <lfs_status>
   WITH KEY criteria = lc_gesty_text
             sel_low = lv_text
             BINARY SEARCH.
  IF sy-subrc = 0 .
    lwa_list2-text = <lfs_status>-sel_high.
  ENDIF. " IF sy-subrc = 0

  APPEND lwa_list2 TO li_list1.
  CLEAR lwa_list2.

** List key 3
  lwa_list2-key = lc_3.
  CLEAR lv_text.
  CONCATENATE gv_country lc_3 INTO lv_text
              SEPARATED BY c_underscore.
  READ TABLE fp_i_status ASSIGNING <lfs_status>
   WITH KEY criteria = lc_gesty_text
             sel_low = lv_text
             BINARY SEARCH.
  IF sy-subrc = 0 .
    lwa_list2-text = <lfs_status>-sel_high.
  ENDIF. " IF sy-subrc = 0
  APPEND lwa_list2 TO li_list1.
  CLEAR lwa_list2.

** List key 4
  lwa_list2-key = lc_4.
  CLEAR lv_text.
  CONCATENATE gv_country lc_4 INTO lv_text
              SEPARATED BY c_underscore.
  READ TABLE fp_i_status ASSIGNING <lfs_status>
   WITH KEY criteria = lc_gesty_text
             sel_low = lv_text
             BINARY SEARCH.
  IF sy-subrc = 0 .
    lwa_list2-text = <lfs_status>-sel_high.
  ENDIF. " IF sy-subrc = 0
  APPEND lwa_list2 TO li_list1.
  CLEAR lwa_list2.
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = lv_id1
      values = li_list1.


*   Treatment dropdown
  lv_id2 = lc_behand_p.

* ---> Begin of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
*  lwa_list2-key = lc_1.
*  lwa_list2-text = 'NORM'(013).
*  APPEND lwa_list2 TO li_list2.
*  lwa_list2-key = lc_2.
*  lwa_list2-text = 'EXPR'(014).
*  APPEND lwa_list2 TO li_list2.
* ---> End of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
**Code is written to pick the value from EMI table w.r.t country
** List key 1
  lwa_list2-key = lc_1.

  CLEAR lv_text.
  CONCATENATE gv_country lc_1 INTO lv_text
              SEPARATED BY c_underscore.
  READ TABLE fp_i_status ASSIGNING <lfs_status>
   WITH KEY criteria = lc_behand
             sel_low = lv_text
             BINARY SEARCH.
  IF sy-subrc = 0 .
    lwa_list2-text = <lfs_status>-sel_high.
  ENDIF. " IF sy-subrc = 0
  APPEND lwa_list2 TO li_list2.
  CLEAR lwa_list2.

** List Key 2
  lwa_list2-key = lc_2.

  CLEAR lv_text.
  CONCATENATE gv_country lc_2 INTO lv_text
              SEPARATED BY c_underscore.
  READ TABLE fp_i_status ASSIGNING <lfs_status>
   WITH KEY criteria = lc_behand
             sel_low = lv_text
             BINARY SEARCH.
  IF sy-subrc = 0 .
    lwa_list2-text = <lfs_status>-sel_high.
  ENDIF. " IF sy-subrc = 0

  APPEND lwa_list2 TO li_list2.
  CLEAR lwa_list2.

* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = lv_id2
      values = li_list2.

* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
** To populate Organization, fetch value from EMI table
** Organization dropdown
  lv_id3 = lc_country.

** List key 1
  lwa_list2-key = lc_ch.

  READ TABLE fp_i_status ASSIGNING <lfs_status>
   WITH KEY criteria = lc_organ
             sel_low = p_countr
             BINARY SEARCH.
  IF sy-subrc = 0 .
    lwa_list2-text = <lfs_status>-sel_high.
  ENDIF. " IF sy-subrc = 0
  APPEND lwa_list2 TO li_list3.
  CLEAR lwa_list2.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = lv_id3
      values = li_list3.
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

ENDFORM. "f_fill_ss_listboxes
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*      Get Data from Database
*----------------------------------------------------------------------*
FORM f_get_data USING fp_i_status TYPE ty_t_status
                CHANGING fp_i_vbrk        TYPE ty_t_vbrk
                         fp_i_vbrp        TYPE ty_t_vbrp
                         fp_i_vbfa        TYPE ty_t_vbfa
* Begin of change for defect 2798- E1DK928015 by u033876.
                         fp_i_vbpa        TYPE ty_t_vbpa
                         fp_i_adrc        TYPE ty_t_adrc
* End of change for defect 2798-  E1DK928015 by u033876.
                         fp_i_likp        TYPE ty_t_likp
                         fp_i_kna1        TYPE ty_t_kna1
                         fp_i_eikp        TYPE ty_t_eikp
                         fp_i_eipo        TYPE ty_t_eipo
                         fp_i_vekp        TYPE ty_t_vekp.

* Billing Document data
  PERFORM f_get_billing_data CHANGING fp_i_vbrk
                                      fp_i_vbrp
                                      fp_i_vbpa. "change for defect 2798- E1DK928015 by u033876

* Delivery Related Data
  PERFORM f_get_delivery_data USING fp_i_status
                           CHANGING fp_i_vbfa
                                    fp_i_likp.
* Customer Data
  PERFORM f_get_customer_data USING fp_i_vbrk
                                    fp_i_vbpa  "change for defect 2798- E1DK928015 by u033876
                           CHANGING fp_i_kna1
                                    fp_i_adrc. "change for defect 2798- E1DK928015 by u033876

* Export/Import Data
  PERFORM f_get_export_import_data USING fp_i_vbrk
                                CHANGING fp_i_eikp
                                         fp_i_eipo.

  PERFORM f_get_hu_data USING fp_i_likp
                        CHANGING fp_i_vekp.
* Set data based on selected options on selection screen
  PERFORM f_get_bills_data.


ENDFORM. " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  f_call_proxy
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_call_proxy USING    fp_i_status    TYPE ty_t_status
                           fp_i_data_item TYPE ty_t_data_item
                           fp_i_data      TYPE ty_t_data.

  DATA: lref_certify                TYPE REF TO z01otc_co_si_certificate_of_o1, " Certify class
        lv_error                    TYPE string,
        lv_result_flag              TYPE flag,                                  " General Flag
        lv_request_id               TYPE z01otc_guid,                           " Proxy Data Element (generated)
        lv_string                   TYPE string,
        lv_doc_number               TYPE string,
        lv_print                    TYPE string,
        lv_username                 TYPE string,
        lv_password                 TYPE string,
        lv_lineinfo                 TYPE string,
* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
        lv_sellow                   TYPE fpb_low, " From Value
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
        lref_cx_system_fault        TYPE REF TO cx_ai_system_fault,      " Fehler Certify
        lref_cx_appl_fault          TYPE REF TO cx_ai_application_fault, " Application Integration: Application Error
        lwa_street                  TYPE string,
        lwa_output                  TYPE z01ca_mt_document_res,          " Proxy Structure (generated)
        li_file                     TYPE z01ca_dt_documentdetails_r_tab,
        li_lineinfo                 TYPE z01ca_base64binary_tab,

*       Login data decleration.
        lwa_login        TYPE z01otc_irequest_service_log_i1, " Proxy Structure (generated)
        lwa_login_result TYPE z01otc_irequest_service_log_i3, " Proxy Structure (generated)

*       data decleration for CREATE_REQUEST method
        lwa_request_input  TYPE z01otc_irequest_service_create, " Proxy Structure (generated)
        lwa_request_output TYPE z01otc_irequest_service_creat1, " Proxy Structure (generated)

*       data decleration for EXPORTER_DATA_REQUEST method
        lwa_export_input   TYPE z01otc_irequest_service_set_ex, " Proxy Structure (generated)
        lwa_export_output  TYPE z01otc_irequest_service_set_e1, " Proxy Structure (generated)

*       data decleration for SET_RECEIVER_DATA method
        lwa_receiver_input  TYPE z01otc_irequest_service_set_r1, " Proxy Structure (generated)
        lwa_receiver_output TYPE z01otc_irequest_service_set_re, " Proxy Structure (generated)

*       Data Declaration for ADD_DOCUMENT method
        lwa_add_doc_in TYPE z01otc_irequest_service_add_d1,   " Proxy Structure (generated)
         lwa_add_doc_out TYPE z01otc_irequest_service_add_do, " Proxy Structure (generated)

*        Data Declaration for GLOBAL_ORIGIN_COUNTRY method
         lwa_global_origin_country_out TYPE z01otc_irequest_service_set_g1, " Proxy Structure (generated)
         lwa_global_origin_country_in TYPE z01otc_irequest_service_set_gl,  " Proxy Structure (generated)

*        Data Declaration for TOTAL_GROSS_WEIGHT method
        lwa_total_gross_wt_out TYPE z01otc_irequest_service_set_t1, " Proxy Structure (generated)
        lwa_total_gross_wt_in TYPE z01otc_irequest_service_set_to,  " Proxy Structure (generated)

*        Data Declaration for ADD_ARTICLE method
        lwa_add_article_out TYPE z01otc_irequest_service_add_a1, " Proxy Structure (generated)
        lwa_add_article_in TYPE z01otc_irequest_service_add_ar,  " Proxy Structure (generated)

*       Data Declaration for SET_COPIES_NB method
        lwa_set_copies_out TYPE z01otc_irequest_service_set_c1, " Proxy Structure (generated)
        lwa_set_copies_in TYPE z01otc_irequest_service_set_co,  " Proxy Structure (generated)

        lwa_submit_req_in TYPE z01otc_irequest_service_submit.  " Proxy Structure (generated)

  FIELD-SYMBOLS : <lfs_data>          TYPE ty_data,
                  <lfs_data_item>     TYPE ty_data_item,
                  <lfs_lineinfo>      TYPE any,
                  <lfs_file>          TYPE z01ca_dt_documentdetails_res, " I0138
                  <lfs_status>        TYPE zdev_enh_status.              " Enhancement Status

  CONSTANTS : lc_success    TYPE   char7        VALUE 'SUCCESS', " Success of type CHAR7
              lc_behand     TYPE   z_criteria   VALUE 'BEHAND',  " Enh. Criteria
* ---> Begin of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
*              lc_coc_user   TYPE   z_criteria   VALUE 'COC_USER',                             " Enh. Criteria
*              lc_coc_pwd    TYPE   z_criteria   VALUE 'COC_PWD',                              " Enh. Criteria
*              lc_ch_coo     TYPE   z_criteria   VALUE 'CH_COO',                               " Enh. Criteria
* ---> End of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
              lc_gestyp     TYPE   z_criteria   VALUE 'GESTYP',                               " Enh. Criteria
              lc_nullid     TYPE   z01otc_guid  VALUE '00000000-0000-0000-0000-000000000000', " Proxy Data Element (generated)
              lc_info       TYPE   char1        VALUE 'I',                                    " Info of type CHAR1
              lc_colon      TYPE   char1        VALUE ':',                                    " Info of type CHAR1
              lc_pdf        TYPE   char4        VALUE '.PDF',                                 " Pdf of type CHAR4
              lc_error      TYPE   char1        VALUE 'E'. " Error of type CHAR1


* ---> Begin of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
*Below code is commented, as logon crendentials are no longer picked from
* EMI table.It is picked from BRF+ table(ZT_OTC_IDD_0197_CERTIFY_LOGON )
** Get Username
*  READ TABLE fp_i_status
*  ASSIGNING <lfs_status>
*  WITH KEY criteria = lc_coc_user
*  BINARY SEARCH.
*  IF sy-subrc EQ 0.
*    lv_username = <lfs_status>-sel_low.
*  ENDIF. " IF sy-subrc EQ 0
*
** Get password
*  READ TABLE fp_i_status
*  ASSIGNING <lfs_status>
*   WITH KEY criteria = lc_coc_pwd
*    BINARY SEARCH.
*  IF sy-subrc EQ 0.
*    lv_password  = <lfs_status>-sel_low.
*  ENDIF. " IF sy-subrc EQ 0
* ---> End of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
** Fetch User crendtials from BRP+ table(ZT_OTC_IDD_0197_CERTIFY_LOGON)
  PERFORM f_get_crendtials_brf CHANGING lv_username
                                        lv_password
                                        gv_usermail.
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

****************************************************************
******************** Create Instance ***************************
****************************************************************

  TRY.

*     Create instance for class Z01OTC_CO_SI_CERTIFICATE_OF_O1
      CREATE OBJECT lref_certify.

    CATCH cx_ai_system_fault INTO lref_cx_system_fault.
      lv_error  = lref_cx_system_fault->get_text( ).

      MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
      LEAVE LIST-PROCESSING.
  ENDTRY.


****************************************************************
******************** LOGIN *************************************
****************************************************************
*  Instance created successfuly now code to log in into system
  IF NOT lref_certify IS INITIAL.

* Details
    lwa_login-user_name = lv_username. " fp_certify_usr-userc. "
    lwa_login-password  = lv_password. "fp_certify_usr-pswdc.
    TRY.
        CALL METHOD lref_certify->so_login_request_s_out
          EXPORTING
            output = lwa_login
          IMPORTING
            input  = lwa_login_result.

      CATCH cx_ai_system_fault INTO lref_cx_system_fault.
        lv_error  = lref_cx_system_fault->get_text( ).
        MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
        LEAVE LIST-PROCESSING.
      CATCH cx_ai_application_fault INTO lref_cx_appl_fault.
        lv_error  = lref_cx_appl_fault->get_text( ).
        MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
        LEAVE LIST-PROCESSING.
    ENDTRY.
*    Translate result to upper case
    IF lwa_login_result-log_in_result IS NOT INITIAL.
      TRANSLATE lwa_login_result-log_in_result TO UPPER CASE.
    ENDIF. " IF lwa_login_result-log_in_result IS NOT INITIAL

****************************************************************
********************* Create Request ***************************
****************************************************************
*   If login method return success method then call method create_request
    IF lwa_login_result-log_in_result = lc_success.

      READ TABLE fp_i_data ASSIGNING <lfs_data> INDEX 1.
      IF sy-subrc EQ 0.

*       create input parameter for create request method
        lwa_request_input-user_name  = lv_username.
        lwa_request_input-password   = lv_password.
        lwa_request_input-reference  = <lfs_data>-vbeln.
        lwa_request_input-type       = p_gestyp.

*       Get value for TREATMENT from EMI data
* ---> Begin of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
*        READ TABLE fp_i_status
*        ASSIGNING <lfs_status>
*        WITH KEY criteria = lc_behand
*                 sel_low = p_behand
*        BINARY SEARCH.
* ---> End of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
**Code is implemented to pick EMI value w.r.t country
        CLEAR lv_sellow.
        CONCATENATE gv_country p_behand INTO lv_sellow
                             SEPARATED BY c_underscore.

        READ TABLE fp_i_status ASSIGNING <lfs_status>
        WITH KEY criteria = lc_behand
                 sel_low  = lv_sellow
        BINARY SEARCH.
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
        IF sy-subrc EQ 0.
          lwa_request_input-treatement = <lfs_status>-sel_high.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc EQ 0

*     Call Method to create Request
      TRY.
          CALL METHOD lref_certify->so_create_request_s_out
            EXPORTING
              output = lwa_request_input
            IMPORTING
              input  = lwa_request_output.

*       Catch Exceptions
        CATCH cx_ai_system_fault INTO lref_cx_system_fault.
          lv_error  = lref_cx_system_fault->get_text( ).
          PERFORM f_logout USING lv_username
                     lv_password
                     lref_certify.
          MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
          LEAVE LIST-PROCESSING.
        CATCH cx_ai_application_fault INTO lref_cx_appl_fault.
          lv_error  = lref_cx_appl_fault->get_text( ).
          PERFORM f_logout USING lv_username
                     lv_password
                     lref_certify.
          MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
          LEAVE LIST-PROCESSING.
      ENDTRY.

*    Translate result to upper case
      IF lwa_request_output-create_request_result = lc_nullid.
        MESSAGE e094.
      ELSE. " ELSE -> IF lwa_request_output-create_request_result = lc_nullid
        lv_request_id = lwa_request_output-create_request_result.
      ENDIF. " IF lwa_request_output-create_request_result = lc_nullid

****************************************************************
********************* Set Exporter Data ************************
****************************************************************
* If request id is obtained correclty then call method set_exporter_data
      IF lv_request_id IS NOT INITIAL.

*       Set Input Values
        lwa_export_input-user_name = lv_username.
        lwa_export_input-password  = lv_password.
        lwa_export_input-request_id = lv_request_id.

*       Get Address data
        PERFORM f_get_address_details USING fp_i_status
                                      CHANGING lwa_export_input.
*   Begin of change for Defect 7379 by NGARG
        lwa_export_input-observations = lwa_request_input-reference.
*   End  of change for Defect 7379 by NGARG


*       Call Method
        TRY.
            CALL METHOD lref_certify->so_exporter_data_request_s_out
              EXPORTING
                output = lwa_export_input
              IMPORTING
                input  = lwa_export_output.


          CATCH cx_ai_system_fault INTO lref_cx_system_fault.
            lv_error  = lref_cx_system_fault->get_text( ).
            PERFORM f_logout USING lv_username
                     lv_password
                     lref_certify.
            MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
            LEAVE LIST-PROCESSING.
          CATCH cx_ai_application_fault INTO lref_cx_appl_fault.
            lv_error  = lref_cx_appl_fault->get_text( ).
            PERFORM f_logout USING lv_username
                     lv_password
                     lref_certify.
            MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
            LEAVE LIST-PROCESSING.
        ENDTRY.

*    Translate result to upper case
        IF lwa_export_output-set_exporter_data_result IS NOT INITIAL.
          TRANSLATE lwa_export_output-set_exporter_data_result TO UPPER CASE.
        ENDIF. " IF lwa_export_output-set_exporter_data_result IS NOT INITIAL


****************************************************************
***************** Set Receiver Data ****************************
****************************************************************
        IF lwa_export_output-set_exporter_data_result = lc_success.
          TRY.

*             Passing vaues to receiver input parameter
              lwa_receiver_input-user_name  = lv_username.
              lwa_receiver_input-password   = lv_password.
              lwa_receiver_input-request_id = lv_request_id.
              lwa_receiver_input-society    = <lfs_data>-name1.
              lwa_receiver_input-zipcode    = <lfs_data>-pstlz.
              lwa_receiver_input-place      = <lfs_data>-ort01.
              lwa_receiver_input-country_iso_code = <lfs_data>-land1.
              lwa_receiver_input-transport  = <lfs_data>-transport.

*             Get Address data
              PERFORM f_build_address USING <lfs_data>
                                      CHANGING lwa_street.

              lwa_receiver_input-address = lwa_street.

*            Call method receiver_data
              CALL METHOD lref_certify->so_set_receiver_data_s_out
                EXPORTING
                  output = lwa_receiver_input
                IMPORTING
                  input  = lwa_receiver_output.

*           Catch Exceptions
            CATCH cx_ai_system_fault INTO lref_cx_system_fault.
              lv_error  = lref_cx_system_fault->get_text( ).
              PERFORM f_logout USING lv_username
                     lv_password
                     lref_certify.
              MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
              LEAVE LIST-PROCESSING.
            CATCH cx_ai_application_fault INTO lref_cx_appl_fault.
              lv_error  = lref_cx_appl_fault->get_text( ).
              PERFORM f_logout USING lv_username
                     lv_password
                     lref_certify.
              MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
              LEAVE LIST-PROCESSING.
          ENDTRY.

*         Translate result to upper case
          IF lwa_receiver_output-set_receiver_data_result IS NOT INITIAL.
            TRANSLATE lwa_receiver_output-set_receiver_data_result TO UPPER CASE.
          ENDIF. " IF lwa_receiver_output-set_receiver_data_result IS NOT INITIAL

        ENDIF. " IF lwa_export_output-set_exporter_data_result = lc_success
      ENDIF. " IF lv_request_id IS NOT INITIAL


****************************************************************
********************* PDF Creation and submission **************
****************************************************************

      IF lwa_receiver_output-set_receiver_data_result = lc_success.

        CLEAR lv_string.
*       Build data
        lwa_add_doc_in-user_name = lv_username.
        lwa_add_doc_in-password = lv_password.
        lwa_add_doc_in-request_id = lv_request_id.
        lwa_add_doc_in-authenticate = abap_true.
*       File name
        CONCATENATE <lfs_data>-vbeln lc_pdf INTO  lwa_add_doc_in-file_name.
        CONDENSE  lwa_add_doc_in-file_name.

* ---> Begin of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
*        READ TABLE fp_i_status ASSIGNING <lfs_status>
*        WITH KEY criteria = lc_gestyp
*                 sel_low  = p_gestyp
*        BINARY SEARCH.
* ---> End of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
**Code is implemented to pick EMI value w.r.t country
        CLEAR lv_sellow.
        CONCATENATE gv_country p_gestyp INTO lv_sellow
                             SEPARATED BY c_underscore.

        READ TABLE fp_i_status ASSIGNING <lfs_status>
        WITH KEY criteria = lc_gestyp
                 sel_low  = lv_sellow
        BINARY SEARCH.
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
        IF sy-subrc EQ 0.
*         Type
          lwa_add_doc_in-type_code = <lfs_status>-sel_high.
        ENDIF. " IF sy-subrc EQ 0

*       Get Attachment in PDF format
        lv_doc_number  =  <lfs_data>-vbeln.
        CALL FUNCTION 'ZOTC0197_GET_INVOICE_PDF_DATA'
          EXPORTING
            im_doc_number    = lv_doc_number
          IMPORTING
            ex_output        = lwa_output
          EXCEPTIONS
            wrong_doc_number = 1
            OTHERS           = 3.
        IF sy-subrc EQ 0.

          li_file[] = lwa_output-mt_document_res-document_details[].

*         Get details of first attachment only
          READ TABLE li_file ASSIGNING <lfs_file> INDEX 1.
          IF sy-subrc EQ 0.
            li_lineinfo[] = <lfs_file>-lineinfo[].
          ENDIF. " IF sy-subrc EQ 0

*         Put all data in string format
          LOOP AT li_lineinfo ASSIGNING <lfs_lineinfo>.
            MOVE  <lfs_lineinfo>  TO lv_lineinfo.
            CONCATENATE lv_string lv_lineinfo INTO lv_string.
          ENDLOOP. " LOOP AT li_lineinfo ASSIGNING <lfs_lineinfo>

*         If any attachment exists, send via method
          IF lv_string IS NOT INITIAL.
            lwa_add_doc_in-the_file = lv_string.

            TRY.
                CALL METHOD lref_certify->so_add_document_s_out
                  EXPORTING
                    output = lwa_add_doc_in
                  IMPORTING
                    input  = lwa_add_doc_out.

*             Catch Exceptions
              CATCH cx_ai_system_fault INTO lref_cx_system_fault.
                lv_error  = lref_cx_system_fault->get_text( ).
                PERFORM f_logout USING lv_username
                     lv_password
                     lref_certify.
                MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
                LEAVE LIST-PROCESSING.
              CATCH cx_ai_application_fault INTO lref_cx_appl_fault.
                lv_error  = lref_cx_appl_fault->get_text( ).
                PERFORM f_logout USING lv_username
                     lv_password
                     lref_certify.
                MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
                LEAVE LIST-PROCESSING.
            ENDTRY.

*           Translate result to upper case
            IF lwa_add_doc_out-add_document_result IS NOT INITIAL.
              TRANSLATE lwa_add_doc_out-add_document_result TO UPPER CASE.
            ENDIF. " IF lwa_add_doc_out-add_document_result IS NOT INITIAL

          ENDIF. " IF lv_string IS NOT INITIAL
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF lwa_receiver_output-set_receiver_data_result = lc_success

****************************************************************
********************* Set Global Origin Country ****************
****************************************************************
*     Check if last result was success
      IF (  lv_string IS NOT INITIAL
        AND lwa_add_doc_out-add_document_result EQ lc_success )
      OR ( lv_string IS INITIAL AND
            lwa_receiver_output-set_receiver_data_result EQ lc_success ).

*        Build data
        lwa_global_origin_country_out-user_name = lv_username.
        lwa_global_origin_country_out-password = lv_password.
        lwa_global_origin_country_out-request_id = lv_request_id.

* ---> Begin of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
*        READ TABLE fp_i_status
*        ASSIGNING <lfs_status>
*        WITH KEY criteria = lc_ch_coo
*        BINARY SEARCH.
*        IF sy-subrc EQ 0.
*          lwa_global_origin_country_out-origin_country = <lfs_status>-sel_low.
*        ENDIF. " IF sy-subrc EQ 0
* ---> End of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
        lwa_global_origin_country_out-origin_country = gv_country.
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

        TRY.
*           Call Method
            CALL METHOD lref_certify->so_global_origin_country_s_out
              EXPORTING
                output = lwa_global_origin_country_out
              IMPORTING
                input  = lwa_global_origin_country_in.

*         Catch Exceptions
          CATCH cx_ai_system_fault INTO lref_cx_system_fault.
            lv_error  = lref_cx_system_fault->get_text( ).
            PERFORM f_logout USING lv_username
                     lv_password
                     lref_certify.
            MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
            LEAVE LIST-PROCESSING.
          CATCH cx_ai_application_fault INTO lref_cx_appl_fault.
            lv_error  = lref_cx_appl_fault->get_text( ).
            PERFORM f_logout USING lv_username
                     lv_password
                     lref_certify.
            MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
            LEAVE LIST-PROCESSING.
        ENDTRY.

*       Translate result to upper case
        IF lwa_global_origin_country_in-set_global_origin_country_resu IS NOT INITIAL .
          TRANSLATE lwa_global_origin_country_in-set_global_origin_country_resu  TO UPPER CASE.
        ENDIF. " IF lwa_global_origin_country_in-set_global_origin_country_resu IS NOT INITIAL

      ENDIF. " IF ( lv_string IS NOT INITIAL

****************************************************************
*****************Set Total Gross Weight*************************
****************************************************************

      IF lwa_global_origin_country_in-set_global_origin_country_resu EQ lc_success.

*       Set Details
        lwa_total_gross_wt_out-user_name = lv_username.
        lwa_total_gross_wt_out-password = lv_password.
        lwa_total_gross_wt_out-request_id = lv_request_id.
        lwa_total_gross_wt_out-total_gross_weight = <lfs_data>-btgew.
        lwa_total_gross_wt_out-total_gross_weight_unit = <lfs_data>-gewei.

        TRY.
*           Call Method
            CALL METHOD lref_certify->so_total_gross_weight_s_out
              EXPORTING
                output = lwa_total_gross_wt_out
              IMPORTING
                input  = lwa_total_gross_wt_in.

*         catch Exceptions
          CATCH cx_ai_system_fault INTO lref_cx_system_fault.
            lv_error  = lref_cx_system_fault->get_text( ).
            PERFORM f_logout USING lv_username
                     lv_password
                     lref_certify.
            MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
            LEAVE LIST-PROCESSING.
          CATCH cx_ai_application_fault INTO lref_cx_appl_fault.
            lv_error  = lref_cx_appl_fault->get_text( ).
            PERFORM f_logout USING lv_username
                     lv_password
                     lref_certify.
            MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
            LEAVE LIST-PROCESSING.
        ENDTRY.

*       Translate result to upper case
        IF lwa_total_gross_wt_in-set_total_gross_weight_result IS NOT INITIAL.
          TRANSLATE lwa_total_gross_wt_in-set_total_gross_weight_result TO UPPER CASE.
        ENDIF. " IF lwa_total_gross_wt_in-set_total_gross_weight_result IS NOT INITIAL
*
      ENDIF. " IF lwa_global_origin_country_in-set_global_origin_country_resu EQ lc_success



****************************************************************
********************* AddArticle********************************
****************************************************************

      IF lwa_total_gross_wt_in-set_total_gross_weight_result EQ lc_success.

        CLEAR lv_result_flag.

* The method ADD ARTICLE will be called for each item for the billing doc
        LOOP AT fp_i_data_item ASSIGNING <lfs_data_item>.

          CLEAR lwa_add_article_out.

          lwa_add_article_out-user_name = lv_username.
          lwa_add_article_out-password = lv_password.
          lwa_add_article_out-request_id = lv_request_id.
          lwa_add_article_out-weight = <lfs_data_item>-ntgew.
          lwa_add_article_out-weight_unit = <lfs_data_item>-gewei.
          lwa_add_article_out-custom_tarif = <lfs_data_item>-stawn.
          lwa_add_article_out-value = <lfs_data_item>-netwr.
          lwa_add_article_out-origin_country = <lfs_data_item>-herkl.

* ---> Begin of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
*Below code is commented, as commodity code description are no longer picked from
* EMI table.It is picked from BRF+ table(ZT_OTC_IDD_0197_COMMODITY_CODE)

**         Fetch texts from EMI table
*          PERFORM f_get_texts USING fp_i_status
*                                   <lfs_data_item>-stawn
*                          CHANGING lwa_add_article_out.
* ---> End of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
* Fetch Commodity Code and Group from BRPPlus table
          PERFORM f_get_texts_brf USING fp_i_status
                                        <lfs_data_item>-stawn
                               CHANGING lwa_add_article_out.
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
          TRY.
*             Call Method
              CALL METHOD lref_certify->so_add_article_s_out
                EXPORTING
                  output = lwa_add_article_out
                IMPORTING
                  input  = lwa_add_article_in.

*           Catch Exceptions
            CATCH cx_ai_system_fault INTO lref_cx_system_fault.
              lv_error  = lref_cx_system_fault->get_text( ).
              PERFORM f_logout USING lv_username
                     lv_password
                     lref_certify.
              MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
              LEAVE LIST-PROCESSING.
            CATCH cx_ai_application_fault INTO lref_cx_appl_fault.
              lv_error  = lref_cx_appl_fault->get_text( ).
              PERFORM f_logout USING lv_username
                     lv_password
                     lref_certify.
              MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
              LEAVE LIST-PROCESSING.
          ENDTRY.

*         Translate result to upper case
          IF lwa_add_article_in-add_article_result IS NOT INITIAL.
            TRANSLATE lwa_add_article_in-add_article_result TO UPPER CASE.

*           If Article was not added  successfully , check flag,
*            if even one item failed
*            we will not go ahead with submission of request
            IF lwa_add_article_in-add_article_result NE lc_success.
              lv_result_flag = abap_true.
              CONCATENATE 'Error for Item no.'(023)
                         <lfs_data_item>-posnr
                         'Of Billing Doc :'(024)
                         <lfs_data>-vbeln
                         lc_colon
                         lwa_add_article_in-add_article_result
                   INTO lv_error
                   SEPARATED BY space.

              MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
            ENDIF. " IF lwa_add_article_in-add_article_result NE lc_success

          ENDIF. " IF lwa_add_article_in-add_article_result IS NOT INITIAL
        ENDLOOP. " LOOP AT fp_i_data_item ASSIGNING <lfs_data_item>
      ENDIF. " IF lwa_total_gross_wt_in-set_total_gross_weight_result EQ lc_success


****************************************************************
********************* Set Copies Nb ****************************
****************************************************************
      IF lv_result_flag  EQ abap_false.

*       Set data
        lwa_set_copies_out-user_name = lv_username.
        lwa_set_copies_out-password = lv_password.
        lwa_set_copies_out-request_id = lv_request_id.
        lwa_set_copies_out-oc = gv_oc.
        lwa_set_copies_out-bills = gv_bills.
        lwa_set_copies_out-docs = gv_docs.

        TRY.
*           Call Method
            CALL METHOD lref_certify->so_set_copies_nb_s_out
              EXPORTING
                output = lwa_set_copies_out
              IMPORTING
                input  = lwa_set_copies_in.

*         Catch Exceptions
          CATCH cx_ai_system_fault INTO lref_cx_system_fault.
            lv_error  = lref_cx_system_fault->get_text( ).
            MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
            LEAVE LIST-PROCESSING.
          CATCH cx_ai_application_fault INTO lref_cx_appl_fault.
            lv_error  = lref_cx_appl_fault->get_text( ).
            PERFORM f_logout USING lv_username
                            lv_password
                            lref_certify.
            MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
            LEAVE LIST-PROCESSING.
        ENDTRY.

*       Translate result to upper case
        IF lwa_set_copies_in-set_copies_nb_result IS NOT INITIAL.
          TRANSLATE lwa_set_copies_in-set_copies_nb_result TO UPPER CASE.
        ENDIF. " IF lwa_set_copies_in-set_copies_nb_result IS NOT INITIAL

      ENDIF. " IF lv_result_flag EQ abap_false

*
      IF lwa_set_copies_in-set_copies_nb_result EQ lc_success .

        lwa_submit_req_in-submit_request_result = lc_success.

      ENDIF. " IF lwa_set_copies_in-set_copies_nb_result EQ lc_success

      CLEAR lv_print .
*     When method for sumbit request is opened, delete this line

*     If submitted successfully show user message
      IF lwa_submit_req_in-submit_request_result EQ lc_success.

        PERFORM f_logout USING lv_username
                     lv_password
                     lref_certify.

        CONCATENATE 'Bill'(001)
                    p_vbeln
                    'successfully submitted to Certify'(016)
                    'with Request ID :'(022)
                    lv_request_id
               INTO lv_print
               SEPARATED BY space.
        MESSAGE lv_print TYPE  lc_info.
        LEAVE LIST-PROCESSING.
      ELSE. " ELSE -> IF lwa_submit_req_in-submit_request_result EQ lc_success

*       if submission failed show user message
        CONCATENATE lwa_submit_req_in-submit_request_result
                    '->Submit Request Failed'(015)
               INTO lv_print.
        PERFORM f_logout USING lv_username
                     lv_password
                     lref_certify.
        MESSAGE lv_print TYPE lc_error DISPLAY LIKE lc_info.

        LEAVE LIST-PROCESSING.
      ENDIF. " IF lwa_submit_req_in-submit_request_result EQ lc_success

    ENDIF. " IF lwa_login_result-log_in_result = lc_success
  ENDIF. " IF NOT lref_certify IS INITIAL

ENDFORM. "f_call_proxy
*&---------------------------------------------------------------------*
*&      Form  F_GET_BILLING_DATA
*&---------------------------------------------------------------------*
*       Billing Doc data
*----------------------------------------------------------------------*
FORM f_get_billing_data  CHANGING fp_i_vbrk TYPE ty_t_vbrk
                                  fp_i_vbrp TYPE ty_t_vbrp
*--> Begin of change for defect 2798- E1DK928015 by u033876.
                                  fp_i_vbpa TYPE ty_t_vbpa .

  DATA: lwa_emi_parvw TYPE zdev_enh_status. " for partner function.

  CONSTANTS : lc_parvw TYPE z_criteria VALUE 'PARVW'. "Partner function
*<--- End of change for defect 2798-  E1DK928015 by u033876.


* Get Billing Doc Header data
  DELETE fp_i_vbrk WHERE fkart NE p_fkart.

* Item Data
  SELECT vbeln " Billing Document
         posnr " Billing item
         ntgew " Net weight
         brgew " Gross weight
         gewei " Weight Unit
         netwr " Net value of the billing item in document currency
    FROM vbrp  " Billing Document: Item Data
    INTO TABLE fp_i_vbrp
    WHERE vbeln = p_vbeln.

  IF sy-subrc EQ 0.
    SORT fp_i_vbrp BY vbeln posnr.
  ENDIF. " IF sy-subrc EQ 0


*--> Begin of change for defect 2798- E1DK928015 by u033876.
  CLEAR: gv_parvw.
  READ TABLE i_status INTO lwa_emi_parvw
                              WITH KEY criteria = lc_parvw
                                       sel_low  = p_countr " based on country from selection screen
                                       active   = abap_true.
  IF sy-subrc = 0.
    gv_parvw =  lwa_emi_parvw-sel_high.

    IF fp_i_vbrp[] IS NOT INITIAL AND gv_parvw IS NOT INITIAL.

      SELECT
        vbeln     " Sales and Distribution Document Number
        posnr     " Item number of the SD document
        parvw     " Partner Function
        kunnr     " Customer Number
        adrnr     " Address
        FROM vbpa " Sales Document: Partner
        INTO TABLE fp_i_vbpa
        FOR ALL ENTRIES IN fp_i_vbrp
        WHERE vbeln = fp_i_vbrp-vbeln
        AND   parvw = gv_parvw.
      IF sy-subrc = 0.
        SORT fp_i_vbpa BY vbeln parvw .
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF fp_i_vbrp[] IS NOT INITIAL AND gv_parvw IS NOT INITIAL
  ENDIF. " IF sy-subrc = 0



*<--- End of change for defect 2798-  E1DK928015 by u033876.

ENDFORM. " F_GET_BILLING_DATA
*&---------------------------------------------------------------------*
*&      Form  F_GET_DELIVERY_DATA
*&---------------------------------------------------------------------*
*      Delivery data
*----------------------------------------------------------------------*
FORM f_get_delivery_data  USING fp_i_status TYPE ty_t_status
                          CHANGING fp_i_vbfa TYPE ty_t_vbfa
                                   fp_i_likp TYPE ty_t_likp.

  DATA : lv_vbtyp_v TYPE vbtyp_v, " Document category of preceding SD document
         li_vbfa    TYPE ty_t_vbfa.

  FIELD-SYMBOLS  : <lfs_status> TYPE zdev_enh_status, " Enhancement Status
                   <lfs_vbfa> TYPE ty_vbfa.

  CONSTANTS : lc_vbtyp_v TYPE z_criteria VALUE 'VBTYP_V', " Enh. Criteria
              lc_vbtyp_n TYPE z_criteria VALUE 'VBTYP_N'. " Enh. Criteria


  READ TABLE fp_i_status
  ASSIGNING <lfs_status>
  WITH KEY criteria = lc_vbtyp_v
  BINARY SEARCH.

  IF sy-subrc EQ 0 .
    lv_vbtyp_v = <lfs_status>-sel_low.
  ENDIF. " IF sy-subrc EQ 0

* Sales Doc flow data
  SELECT vbelv   " Preceding sales and distribution document
         posnv   " Preceding item of an SD document
         vbeln   " Subsequent sales and distribution document
         posnn   " Subsequent item of an SD document
         vbtyp_n " Document category of subsequent document
         vbtyp_v " Document category of preceding SD document
     FROM vbfa   " Sales Document Flow
     INTO TABLE fp_i_vbfa
     WHERE vbeln = p_vbeln
      AND vbtyp_v = lv_vbtyp_v.

  IF sy-subrc EQ 0.

*   Filter VBFA data only where VBTYP_N field matches maintained EMI entries
    LOOP AT fp_i_vbfa ASSIGNING <lfs_vbfa> .
      READ TABLE fp_i_status
        WITH KEY criteria = lc_vbtyp_n
                 sel_low  = <lfs_vbfa>-vbtyp_n
      BINARY SEARCH
      TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
        APPEND <lfs_vbfa> TO li_vbfa.
      ENDIF. " IF sy-subrc EQ 0
    ENDLOOP. " LOOP AT fp_i_vbfa ASSIGNING <lfs_vbfa>

    IF li_vbfa IS NOT INITIAL.
      fp_i_vbfa[] = li_vbfa[].
      SORT fp_i_vbfa BY vbeln.
      SORT li_vbfa BY vbelv.
      DELETE ADJACENT DUPLICATES FROM li_vbfa COMPARING vbelv.
    ENDIF. " IF li_vbfa IS NOT INITIAL
  ENDIF. " IF sy-subrc EQ 0

* Delivery Header data
  IF li_vbfa[] IS NOT INITIAL.
    SELECT
      vbeln     " Delivery
      kunnr     " Ship-to party
      btgew     " Total Weight
      gewei     " Weight Unit
      FROM likp " SD Document: Delivery Header Data
      INTO TABLE fp_i_likp
      FOR ALL ENTRIES IN li_vbfa
      WHERE vbeln = li_vbfa-vbelv.

    IF sy-subrc EQ 0.
      SORT fp_i_likp BY vbeln.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_vbfa[] IS NOT INITIAL

ENDFORM. " F_GET_DELIVERY_DATA
*&---------------------------------------------------------------------*
*&      Form  F_GET_CUSTOMER_DATA
*&---------------------------------------------------------------------*
*      GET CUSTOMER DATA
*----------------------------------------------------------------------*
FORM f_get_customer_data  USING    fp_i_vbrk  TYPE ty_t_vbrk  " Customer Number
                                   fp_i_vbpa  TYPE ty_t_vbpa  "change for defect 2798- E1DK928015 by u033876
                          CHANGING fp_i_kna1  TYPE ty_t_kna1
                                   fp_i_adrc  TYPE ty_t_adrc. "change for defect 2798- E1DK928015 by u033876
*----> Begin of change for defect 2798- E1DK928015 by u033876.
* instead of Sold-to we need to get the ship-to adress deatils from adrc.
  DATA : li_vbpa TYPE ty_t_vbpa.
* Comment  the below code as we dont need this kna1 data

*  DATA : li_vbrk TYPE ty_t_vbrk.
*
*  li_vbrk[] = fp_i_vbrk[].
*  SORT li_vbrk BY kunag.
*  DELETE ADJACENT DUPLICATES FROM li_vbrk COMPARING  kunag.
*
*  IF li_vbrk[] IS NOT INITIAL.
**   Customer Data
*    SELECT
*           kunnr " Customer Number
*           land1 " Country Key
*           name1 " Name 1
*           name2 " Name 2
*           ort01 " City
*           pstlz " Postal Code
*           stras " House number and street
*           name3 " Name 3
*           name4 " Name 4
*           pfach " PO Box
*      FROM kna1  " General Data in Customer Master
*      INTO TABLE fp_i_kna1
*      FOR ALL ENTRIES IN li_vbrk
*      WHERE kunnr = li_vbrk-kunag.
*    IF sy-subrc EQ 0.
*      SORT fp_i_kna1 BY kunnr.
*    ENDIF. " IF sy-subrc EQ 0
*  ENDIF. " IF li_vbrk[] IS NOT INITIAL



  li_vbpa[] = fp_i_vbpa[].
  SORT li_vbpa BY adrnr.
  DELETE ADJACENT DUPLICATES FROM li_vbpa COMPARING  adrnr.

  IF li_vbpa[] IS NOT INITIAL.
*   Customer Data
    SELECT
           addrnumber " Address number
           country    " Country Key
           name1      " Name 1
           name2      " Name 2
           city1      " City
           post_code1 " Postal Code
           street     " House number and street
           name3      " Name 3
           name4      " Name 4
           po_box     " PO Box
      FROM adrc       " General Data in Customer Master
      INTO TABLE fp_i_adrc
      FOR ALL ENTRIES IN li_vbpa
      WHERE addrnumber = li_vbpa-adrnr.
    IF sy-subrc EQ 0.
      SORT fp_i_adrc BY addrnumber.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_vbpa[] IS NOT INITIAL
*<---- End of change for defect 2798- E1DK928015 by u033876.
ENDFORM. " F_GET_CUSTOMER_DATA
*&---------------------------------------------------------------------*
*&      Form  F_GET_EXPORT_IMPORT_DATA
*&---------------------------------------------------------------------*
*       Fetch Export/Import Data
*----------------------------------------------------------------------*
FORM f_get_export_import_data  USING    fp_i_vbrk TYPE ty_t_vbrk
                               CHANGING fp_i_eikp TYPE ty_t_eikp
                                        fp_i_eipo TYPE ty_t_eipo.

  DATA : li_vbrk TYPE ty_t_vbrk.

  li_vbrk[] = fp_i_vbrk[].
  SORT li_vbrk BY exnum.
  DELETE ADJACENT DUPLICATES FROM li_vbrk COMPARING exnum.
  IF li_vbrk[] IS NOT INITIAL.

*   Get Export/Import Header data
    SELECT exnum " Number of foreign trade data in MM and SD documents
           expvz " Mode of Transport for Foreign Trade
      INTO TABLE fp_i_eikp
      FROM eikp  " Foreign Trade: Export/Import Header Data
      FOR ALL ENTRIES IN li_vbrk
      WHERE exnum = li_vbrk-exnum.
    IF sy-subrc EQ 0.
      SORT fp_i_eikp BY exnum.

*       Get Export/Import item data
      SELECT exnum " Number of foreign trade data in MM and SD documents
             expos " Internal item number for foreign trade data in MM and SD
             stawn " Commodity Code/Import Code Number for Foreign Trade
             herkl " Country of origin of the material
        INTO TABLE fp_i_eipo
        FROM eipo  " Foreign Trade: Export/Import: Item Data
        FOR ALL ENTRIES IN fp_i_eikp
        WHERE exnum = fp_i_eikp-exnum.
      IF sy-subrc EQ 0.
        SORT fp_i_eipo BY exnum expos.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_vbrk[] IS NOT INITIAL

ENDFORM. " F_GET_EXPORT_IMPORT_DATA
*&---------------------------------------------------------------------*
*&      Form  F_GET_EMI_DATA
*&---------------------------------------------------------------------*
*       Fetch EMI Entries
*----------------------------------------------------------------------*
FORM f_get_emi_data  CHANGING fp_i_status TYPE ty_t_status.

  CONSTANTS: lc_idd_0197 TYPE z_enhancement VALUE 'OTC_IDD_0197'. " Enhancement No.

* Get EMI DATA
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_idd_0197
    TABLES
      tt_enh_status     = fp_i_status.

  IF fp_i_status[] IS NOT INITIAL.
    DELETE fp_i_status[] WHERE active = abap_false.
  ENDIF. " IF fp_i_status[] IS NOT INITIAL

  IF fp_i_status[] IS NOT INITIAL.
*    Begin of delete for Defect#7379 by NGARG
*    SORT fp_i_status BY criteria sel_low .
*    End of Delete for Defect#7370 by NGARG
*    Begin of Insert for Defect#7379 by NGARG
    SORT fp_i_status BY criteria sel_low sel_high.
*    End  of Insert for Defect#7379 by NGARG

  ENDIF. " IF fp_i_status[] IS NOT INITIAL
ENDFORM. " F_GET_EMI_DATA
*&---------------------------------------------------------------------*
*&      Form  F_SET_DATA
*&---------------------------------------------------------------------*
*       Set data into 2 cnsolidated tables : Header and Item
*----------------------------------------------------------------------*
FORM f_set_data  USING   fp_i_vbrk        TYPE ty_t_vbrk
                         fp_i_vbrp        TYPE ty_t_vbrp
                         fp_i_vbfa        TYPE ty_t_vbfa
*----> Begin of change for defect 2798- E1DK928015 by u033876.
                         fp_i_vbpa        TYPE ty_t_vbpa
                         fp_i_adrc        TYPE ty_t_adrc
*<---- End of change for defect 2798- E1DK928015 by u033876.
                         fp_i_likp        TYPE ty_t_likp
                         fp_i_kna1        TYPE ty_t_kna1
                         fp_i_eikp        TYPE ty_t_eikp
                         fp_i_eipo        TYPE ty_t_eipo
                         fp_i_status      TYPE ty_t_status
                         fp_i_vekp        TYPE ty_t_vekp
                 CHANGING fp_i_data       TYPE ty_t_data
                          fp_i_data_item  TYPE ty_t_data_item.


* Begin of change for Defect 3039 by U033876.

  DATA: li_data_item TYPE ty_t_data_item,
        li_data_item_temp TYPE ty_t_data_item,
        lwa_data_item_temp TYPE ty_data_item.

  FIELD-SYMBOLS:<fs_data_item> TYPE ty_data_item.

* end of change for defect 3039 by u033876.


  FIELD-SYMBOLS : <lfs_vbrk> TYPE ty_vbrk,
                 <lfs_vbrp> TYPE ty_vbrp,
                 <lfs_vbfa> TYPE ty_vbfa,
                 <lfs_likp> TYPE ty_likp,
*----> Begin of change for defect 2798- E1DK928015 by u033876.
*                 <lfs_kna1> TYPE ty_kna1,
                  <lfs_vbpa> TYPE ty_vbpa,
                  <lfs_adrc> TYPE ty_adrc,
*<---- End of change for defect 2798- E1DK928015 by u033876.
                 <lfs_eikp> TYPE ty_eikp,
                 <lfs_status> TYPE zdev_enh_status, " Enhancement Status
                 <lfs_eipo> TYPE ty_eipo.

  DATA : lwa_data      TYPE ty_data,
         lwa_data_item TYPE ty_data_item,
         lv_unit       TYPE msehi, " Unit of Measurement
         lv_currency   TYPE waerk, " SD Document Currency
         lv_netwr      TYPE netwr, " Net Value in Document Currency
         lv_brgew      TYPE brgew, " Gross Weight
         lv_rate_type  TYPE kurst_curr,
*----> Begin of change for defect 2798- E1DK928015 by u033876.
         lv_adrnr      TYPE adrnr, " Address
*<---- End of change for defect 2798- E1DK928015 by u033876.
         lv_rate       TYPE ukursp, " Direct Quoted Exchange Rate
* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
         lv_expvz      TYPE fpb_low, " From Value
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
         lwa_return    TYPE bapiret1,        " Return Parameter
         lwa_exchange_rate TYPE  bapi1093_0, " BAPI exchange rate table
*              Begin of Insert for Defect#7379 by NGARG
          lv_amount TYPE  netwr. " Net Value in Document Currency
*          End of Insert for Defect#7379 by NGARG


  CONSTANTS:  lc_unit     TYPE z_criteria VALUE 'UNIT',     " Enh. Criteria
              lc_currency TYPE z_criteria VALUE 'CURRENCY', " Enh. Criteria
* ---> Begin of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
*              lc_rate     TYPE z_criteria VALUE 'COC_EXRT_TYPE'. " Enh. Criteria
* ---> End of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
            lc_rate     TYPE z_criteria VALUE 'EXRT_TYPE', " Enh. Criteria
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
*            Begin of Insert for Defect#7379 by NGARG
            lc_usd      TYPE fcurr_curr VALUE 'USD'. " From currency
*            End of Insert for Defect#7379 by NGARG

  CONSTANTS: lc_expvz TYPE z_criteria VALUE 'EXPVZ'. " Enh. Criteria


************************HEADER DATA*******************************
  LOOP AT fp_i_vbrk ASSIGNING <lfs_vbrk>.

*   Billing Header data
    lwa_data-vbeln = <lfs_vbrk>-vbeln.
    lwa_data-fkart = <lfs_vbrk>-fkart.
    lwa_data-waerk = <lfs_vbrk>-waerk.
    lwa_data-fkdat = <lfs_vbrk>-fkdat.
    lwa_data-kurrf = <lfs_vbrk>-kurrf.
    lwa_data-kunag = <lfs_vbrk>-kunag.
    lwa_data-exnum = <lfs_vbrk>-exnum.

*   Delivery data
    READ TABLE fp_i_vbfa
     ASSIGNING <lfs_vbfa>
     WITH KEY vbeln = <lfs_vbrk>-vbeln
     BINARY SEARCH.
    IF sy-subrc EQ 0.
      READ TABLE fp_i_likp
      ASSIGNING <lfs_likp>
      WITH KEY vbeln = <lfs_vbfa>-vbelv
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        lwa_data-kunnr = <lfs_likp>-kunnr.
        lwa_data-del_no = <lfs_likp>-vbeln.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0

*----> Begin of change for defect 3039- E1DK928015 by u033876.
*Commented below code to get the gross weight from vekp and
*instead get the value form vbrp
**   Get Qty and Unit
*    PERFORM f_get_packing_data USING   fp_i_vekp
*                                       fp_i_status
*                                      CHANGING lwa_data.

*   Get Qty and Unit
    PERFORM f_get_gross_weight USING   <lfs_vbrk>
                                       fp_i_vbrp
                                       fp_i_status
                                      CHANGING lwa_data.

*<---- END of change for defect 3039- E1DK928015 by u033876.


*----> Begin of change for defect 2798- E1DK928015 by u033876.
* instead of Sold-to we need to get the partner function from emi
* and based on partner function we need to get the address details
* from VBPa and ADRC.
* So commented the below code and added the logic to get from
* adrc in vbrp loop below.


**   Address data
*    READ TABLE fp_i_kna1
*     ASSIGNING <lfs_kna1>
*     WITH KEY kunnr = <lfs_vbrk>-kunag
*     BINARY SEARCH.
*    IF sy-subrc EQ 0.
*      lwa_data-land1 = <lfs_kna1>-land1.
*      lwa_data-name1 = <lfs_kna1>-name1.
*      lwa_data-name2 = <lfs_kna1>-name2.
*      lwa_data-ort01 = <lfs_kna1>-ort01.
*      lwa_data-pstlz = <lfs_kna1>-pstlz.
*      lwa_data-stras = <lfs_kna1>-stras.
*      lwa_data-name3 = <lfs_kna1>-name3.
*      lwa_data-name4 = <lfs_kna1>-name4.
*      lwa_data-pfach = <lfs_kna1>-pfach.
*    ENDIF. " IF sy-subrc EQ 0


*----> Begin of change for defect 2798- E1DK928015 by u033876.
    READ TABLE fp_i_vbpa
     ASSIGNING <lfs_vbpa>
     WITH KEY vbeln = <lfs_vbrk>-vbeln
              parvw = gv_parvw
              BINARY SEARCH.
    IF sy-subrc = 0.
      lv_adrnr = <lfs_vbpa>-adrnr.
    ENDIF. " IF sy-subrc = 0

    READ TABLE fp_i_adrc ASSIGNING <lfs_adrc>
               WITH KEY addrnumber =  lv_adrnr
               BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_data-land1 = <lfs_adrc>-country.
      lwa_data-name1 = <lfs_adrc>-name1.
      lwa_data-name2 = <lfs_adrc>-name2.
      lwa_data-ort01 = <lfs_adrc>-city1.
      lwa_data-pstlz = <lfs_adrc>-post_code1.
      lwa_data-stras = <lfs_adrc>-street.
      lwa_data-name3 = <lfs_adrc>-name3.
      lwa_data-name4 = <lfs_adrc>-name4.
      lwa_data-pfach = <lfs_adrc>-po_box .
    ENDIF. " IF sy-subrc = 0

*<---- End of change for defect 2798- E1DK928015 by u033876.

*   Import/Export Header data
    READ TABLE fp_i_eikp
    ASSIGNING <lfs_eikp>
    WITH KEY exnum = <lfs_vbrk>-exnum
    BINARY SEARCH.
    IF sy-subrc EQ 0.
*
      lwa_data-exnum = <lfs_eikp>-exnum.

* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
*SEL_LOW value is changed for fetching tranport value from EMI
      CLEAR lv_expvz.
      CONCATENATE gv_country <lfs_eikp>-expvz INTO lv_expvz
                             SEPARATED BY c_underscore.
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

      READ TABLE fp_i_status
      ASSIGNING <lfs_status>
      WITH KEY criteria = lc_expvz
* ---> Begin of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
*               sel_low = <lfs_eikp>-expvz
* ---> End of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
                sel_low = lv_expvz
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
               BINARY SEARCH.
      IF sy-subrc EQ 0.
        lwa_data-transport = <lfs_status>-sel_high.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
    APPEND lwa_data TO fp_i_data.
    CLEAR lwa_data.

  ENDLOOP. " LOOP AT fp_i_vbrk ASSIGNING <lfs_vbrk>

************************ITEM DATA*******************************

* ---> Begin of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
* UNIT
*  READ TABLE fp_i_status
* ASSIGNING <lfs_status>
* WITH KEY criteria = lc_unit
* BINARY SEARCH.
*  IF sy-subrc EQ 0.
*    lv_unit = <lfs_status>-sel_low.
*  ENDIF. " IF sy-subrc EQ 0


*  CURRENCY
*  READ TABLE fp_i_status
*  ASSIGNING <lfs_status>
*  WITH KEY criteria = lc_currency
*  BINARY SEARCH.
*  IF sy-subrc EQ 0.
*    lv_currency = <lfs_status>-sel_low.
*  ENDIF. " IF sy-subrc EQ 0
* ---> End of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
** Unit
* Get Unit as per crietria and sel_low value(country code)
  READ TABLE fp_i_status
  ASSIGNING <lfs_status>
  WITH KEY criteria = lc_unit
           sel_low  = gv_country
  BINARY SEARCH.
  IF sy-subrc EQ 0.
    lv_unit = <lfs_status>-sel_high.
  ENDIF. " IF sy-subrc EQ 0

** Currency
* Get currency value as per crietria(currency) and sel_low value(country code)
  READ TABLE fp_i_status
  ASSIGNING <lfs_status>
  WITH KEY criteria = lc_currency
           sel_low = gv_country
  BINARY SEARCH.
  IF sy-subrc EQ 0.
    lv_currency = <lfs_status>-sel_high.
  ENDIF. " IF sy-subrc EQ 0
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG


* loop on items
  LOOP AT fp_i_vbrp ASSIGNING <lfs_vbrp>.



    READ TABLE fp_i_vbrk
    ASSIGNING <lfs_vbrk>
    WITH KEY vbeln = <lfs_vbrp>-vbeln
    BINARY SEARCH.
    IF sy-subrc EQ 0.

*     Billing Item data
      lwa_data_item-posnr = <lfs_vbrp>-posnr.


*     Convert Quantity
      IF <lfs_vbrp>-gewei NE lv_unit.
        CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
          EXPORTING
            input                = <lfs_vbrp>-brgew
            unit_in              = <lfs_vbrp>-gewei
            unit_out             = lv_unit
          IMPORTING
            output               = lv_brgew
          EXCEPTIONS
            conversion_not_found = 1
            division_by_zero     = 2
            input_invalid        = 3
            output_invalid       = 4
            overflow             = 5
            type_invalid         = 6
            units_missing        = 7
            unit_in_not_found    = 8
            unit_out_not_found   = 9
            OTHERS               = 10.
        IF sy-subrc EQ 0.

          lwa_data_item-brgew = lv_brgew.
          lwa_data_item-gewei = lv_unit.
        ENDIF. " IF sy-subrc EQ 0
      ELSE. " ELSE -> IF <lfs_vbrp>-gewei NE lv_unit

        lwa_data_item-brgew = <lfs_vbrp>-brgew.
        lwa_data_item-gewei = <lfs_vbrp>-gewei.
      ENDIF. " IF <lfs_vbrp>-gewei NE lv_unit

      IF <lfs_vbrk>-waerk NE lv_currency.

* ---> Begin of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
* Get currency value as per crietria(currency) and sel_low value(country code)
* so deleted below code
*        READ TABLE fp_i_status
*        ASSIGNING <lfs_status>
*        WITH KEY criteria = lc_rate
*        BINARY SEARCH.
*        IF sy-subrc EQ 0.
*          lv_rate_type = <lfs_status>-sel_low.
*        ENDIF. " IF sy-subrc EQ 0
* ---> End of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG



* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
* Get rate as per crietria(lc_rate) and sel_low value(country code)
        READ TABLE fp_i_status
        ASSIGNING <lfs_status>
        WITH KEY criteria = lc_rate
                 sel_low = gv_country
        BINARY SEARCH.
        IF sy-subrc EQ 0.
          lv_rate_type = <lfs_status>-sel_high.
        ENDIF. " IF sy-subrc EQ 0
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG


*----> Begin of change for defect 2798- E1DK928015 by u033876.
* FM BAPI_EXCHANGERATE_GETDETAIL will just get the exchange rate based
* on entries in exchange rate table. In tha table we will maintain
* only EUR to USD and CHF to USD. As USD is our base currency
* for eg when we converting Currency EUR to CHF, we will not have an entry
* in the currency table directly, so we need to do  reverse conversion
* which is already done in Standard FM : READ_EXCHANGE_RATE (which is released)

*Begin of Change for Defect#7379 by Neha Garg

** As their is no direct conversion of European Curencies,
**we wil first convert every currency to USD and
**then again convert to desored currency
*        CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
*          EXPORTING
*            rate_type  = lv_rate_type
*            from_curr  = <lfs_vbrk>-waerk
*            to_currncy = lc_usd
*            date       = <lfs_vbrk>-fkdat
*          IMPORTING
*            exch_rate  = lwa_exchange_rate
*            return     = lwa_return.
*
*        IF lwa_exchange_rate IS NOT INITIAL
*          AND lwa_return IS INITIAL.
*          lv_rate = lwa_exchange_rate-exch_rate.
*        ENDIF. " IF lwa_exchange_rate IS NOT INITIAL

*        IF lv_rate IS NOT INITIAL.
**     Convert the Amount
*          CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
*            EXPORTING
*              client           = sy-mandt
*              date             = <lfs_vbrk>-fkdat
*              foreign_amount   = <lfs_vbrp>-netwr
*              foreign_currency = <lfs_vbrk>-waerk
*              local_currency   = lc_usd
*              rate             = lv_rate
*              type_of_rate     = lv_rate_type
*            IMPORTING
*              local_amount     = lv_netwr
*            EXCEPTIONS
*              no_rate_found    = 1
*              overflow         = 2
*              no_factors_found = 3
*              no_spread_found  = 4
*              derived_2_times  = 5
*              OTHERS           = 6.
*          IF sy-subrc EQ 0.
*            lv_amount  = lv_netwr.
*          ENDIF. " IF sy-subrc EQ 0
*        ENDIF. " IF lv_rate IS NOT INITIAL
*
*        CLEAR lv_rate.
**End of Change for Defect#7379 by Neha Garg
*
*
**
*        CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
*          EXPORTING
*            rate_type  = lv_rate_type
**              Begin of Delete for Defect#7379 by NGARG
**              from_curr  = <lfs_vbrk>-waerk
**              End of Delete for Defect#7379 by NGARG
**              Begin of Insert for Defect#7379 by NGARG
*            from_curr = lc_usd
**              End of Insert for Defect#7379 by NGARG
*            to_currncy = lv_currency
*            date       = <lfs_vbrk>-fkdat
*          IMPORTING
*            exch_rate  = lwa_exchange_rate
*            return     = lwa_return.
*
*        IF lwa_exchange_rate IS NOT INITIAL
*          AND lwa_return IS INITIAL.
*          lv_rate = lwa_exchange_rate-exch_rate.
*        ENDIF. " IF lwa_exchange_rate IS NOT INITIAL
*
*        CLEAR :lwa_exchange_rate,
*               lwa_return.



*        IF lv_rate IS NOT INITIAL.
**     Convert the Amount
*          CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
*            EXPORTING
*              client           = sy-mandt
*              date             = <lfs_vbrk>-fkdat
**              Begin of Delete for Defect#7379 by NGARG
**              foreign_amount   = <lfs_vbrp>-netwr
**                foreign_currency = <lfs_vbrk>-waerk
**              End  of Delete for Defect#7379 by NGARG
**              Begin of Insert for Defect#7379 by NGARG
*              foreign_amount = lv_amount
*              foreign_currency = lc_usd
**              End of Insert for Defect#7379 by NGARG
*              local_currency   = lv_currency
*              rate             = lv_rate
*              type_of_rate     = lv_rate_type
*            IMPORTING
*              local_amount     = lv_netwr
*            EXCEPTIONS
*              no_rate_found    = 1
*              overflow         = 2
*              no_factors_found = 3
*              no_spread_found  = 4
*              derived_2_times  = 5
*              OTHERS           = 6.
*          IF sy-subrc EQ 0.
*            lwa_data_item-netwr = lv_netwr.
*          ENDIF. " IF sy-subrc EQ 0
*        ENDIF. " IF lv_rate IS NOT INITIAL


        CALL FUNCTION 'READ_EXCHANGE_RATE'
          EXPORTING
            date             = <lfs_vbrk>-fkdat
            foreign_currency = <lfs_vbrk>-waerk "eg: EUR
            local_currency   = lv_currency      "eg:CHF
            type_of_rate     = lv_rate_type
          IMPORTING
            exchange_rate    = lv_rate
          EXCEPTIONS
            error_message    = 1.


        IF lv_rate IS NOT INITIAL.
*     Convert the Amount
          CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
            EXPORTING
              client           = sy-mandt
              date             = <lfs_vbrk>-fkdat
              foreign_amount   = <lfs_vbrp>-netwr
              foreign_currency = <lfs_vbrk>-waerk
              local_currency   = lv_currency
              rate             = lv_rate
              type_of_rate     = lv_rate_type
            IMPORTING
              local_amount     = lv_netwr
            EXCEPTIONS
              no_rate_found    = 1
              overflow         = 2
              no_factors_found = 3
              no_spread_found  = 4
              derived_2_times  = 5
              OTHERS           = 6.
          IF sy-subrc EQ 0.
            lwa_data_item-netwr = lv_netwr.
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF lv_rate IS NOT INITIAL

*<---- End of change for defect 2798- E1DK928015 by u033876.
      ELSE. " ELSE -> IF <lfs_vbrk>-waerk NE lv_currency
        lwa_data_item-netwr = <lfs_vbrp>-netwr.
      ENDIF. " IF <lfs_vbrk>-waerk NE lv_currency



      lwa_data_item-ntgew = <lfs_vbrp>-ntgew.


*   Import/Export Item data
      READ TABLE fp_i_eipo
      ASSIGNING <lfs_eipo>
      WITH KEY exnum = <lfs_vbrk>-exnum
               expos = <lfs_vbrp>-posnr
     BINARY SEARCH.
      IF sy-subrc EQ 0.
        lwa_data_item-exnum = <lfs_vbrk>-exnum. ""change for defect 3039
        lwa_data_item-stawn = <lfs_eipo>-stawn.
        lwa_data_item-herkl = <lfs_eipo>-herkl.
      ENDIF. " IF sy-subrc EQ 0

*     Append data to consolidated  table
      APPEND lwa_data_item TO fp_i_data_item.
      CLEAR lwa_data_item.
    ENDIF. " IF sy-subrc EQ 0
  ENDLOOP. " LOOP AT fp_i_vbrp ASSIGNING <lfs_vbrp>

*----> Begin of change for defect 3039- E1DK928015 by u033876.


  SORT fp_i_data_item BY stawn herkl posnr.
  LOOP AT fp_i_data_item ASSIGNING <fs_data_item> .

    AT NEW stawn.
      MOVE: <fs_data_item>-exnum TO lwa_data_item_temp-exnum,
            <fs_data_item>-ntgew TO lwa_data_item_temp-ntgew,
            <fs_data_item>-brgew TO lwa_data_item_temp-brgew,
            <fs_data_item>-gewei TO lwa_data_item_temp-gewei,
            <fs_data_item>-netwr TO lwa_data_item_temp-netwr,
            <fs_data_item>-expvz TO lwa_data_item_temp-expvz,
            <fs_data_item>-expos TO lwa_data_item_temp-expos,
            <fs_data_item>-stawn TO lwa_data_item_temp-stawn,
            <fs_data_item>-herkl TO lwa_data_item_temp-herkl.
*            <fs_data_item>-posnr TO lwa_data_item_temp-posnr.
      COLLECT lwa_data_item_temp INTO li_data_item_temp.
      CLEAR: lwa_data_item_temp.
    ENDAT.

    AT LAST.
      APPEND LINES OF li_data_item_temp TO li_data_item.
    ENDAT.

  ENDLOOP. " LOOP AT fp_i_data_item ASSIGNING <fs_data_item>

* After Collect move the content of li_data_item into fp_i_data_item
fp_i_data_item[] = li_data_item[].

  CLEAR: li_data_item[], li_data_item_temp[], lwa_data_item_temp.
*<---- End of change for defect 3039- E1DK928015 by u033876.


ENDFORM. " F_SET_DATA
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_ADDRESS
*&---------------------------------------------------------------------*
*       Set Address data
*----------------------------------------------------------------------*
FORM f_build_address  USING    fp_data TYPE ty_data
                      CHANGING fp_wa_street TYPE string.

  DATA : lv_pobox      TYPE char20. " Pobox of type CHAR20

* If PO bOX is not emoty
  IF fp_data-pfach IS NOT INITIAL .
*   Name2
    IF  fp_data-name2 IS NOT INITIAL.
      fp_wa_street = fp_data-name2.
    ENDIF. " IF fp_data-name2 IS NOT INITIAL
*   Name3
    IF fp_data-name3 IS NOT INITIAL.
      CONCATENATE fp_wa_street
        fp_data-name3
       INTO fp_wa_street
      SEPARATED BY cl_abap_char_utilities=>newline.
    ENDIF. " IF fp_data-name3 IS NOT INITIAL
*   Name4
    IF fp_data-name4 IS  NOT INITIAL.
      CONCATENATE fp_wa_street
       fp_data-name4
       INTO fp_wa_street
       SEPARATED BY cl_abap_char_utilities=>newline.
    ENDIF. " IF fp_data-name4 IS NOT INITIAL
*   PO Box
    CONCATENATE  'Po Box'(021)
                fp_data-pfach
           INTO lv_pobox
      SEPARATED BY space.
*   Street
    CONCATENATE fp_wa_street
                lv_pobox
    INTO fp_wa_street
    SEPARATED BY cl_abap_char_utilities=>newline.

* When PO box is empty but House number and street are not empty
  ELSEIF fp_data-stras IS NOT INITIAL.
*   Name2
    IF  fp_data-name2 IS NOT INITIAL.
      fp_wa_street = fp_data-name2.
    ENDIF. " IF fp_data-name2 IS NOT INITIAL

*   Name3
    IF fp_data-name3 IS NOT INITIAL.
      CONCATENATE fp_wa_street
        fp_data-name3
       INTO fp_wa_street
      SEPARATED BY cl_abap_char_utilities=>newline.
    ENDIF. " IF fp_data-name3 IS NOT INITIAL

*   Name4
    IF fp_data-name4 IS  NOT INITIAL.
      CONCATENATE fp_wa_street
       fp_data-name4
       INTO fp_wa_street
       SEPARATED BY cl_abap_char_utilities=>newline.
    ENDIF. " IF fp_data-name4 IS NOT INITIAL

*      Begin of Insert for Defect#7379 by Neha Garg
    CONCATENATE fp_wa_street fp_data-stras INTO fp_wa_street SEPARATED BY cl_abap_char_utilities=>newline.
*      End of Insert for Defect#7379 by Neha Garg


  ENDIF. " IF fp_data-pfach IS NOT INITIAL
ENDFORM. " F_BUILD_ADDRESS
**&---------------------------------------------------------------------*
**&      Form  F_GET_PACKING_DATA
**&---------------------------------------------------------------------*
**       Fetch HU Quantity
**----------------------------------------------------------------------*
*FORM f_get_packing_data  USING    fp_i_vekp   TYPE ty_t_vekp
*                                  fp_i_status TYPE ty_t_status
*                         CHANGING fp_wa_data  TYPE ty_data. " Total Weight
*  DATA : lv_output    TYPE f,          " Output of type Floating Point Numbers
*         lv_qty       TYPE brgew_vekp, " Total Weight of Handling Unit
*         lv_unit_out  TYPE msehi,      " Unit of Measurement
*         lv_unit      TYPE gewei.      " Weight Unit
*
*  FIELD-SYMBOLS : <lfs_status> TYPE zdev_enh_status, " Enhancement Status
*                  <lfs_vekp>   TYPE ty_vekp.         " Handling Unit Header-Data - Communication Structure
*
*  CONSTANTS:       lc_unit     TYPE z_criteria VALUE 'UNIT'. " Enh. Criteria
*
*
*
*
*  LOOP AT fp_i_vekp ASSIGNING <lfs_vekp>.
*    IF <lfs_vekp>-vpobjkey EQ fp_wa_data-del_no.
*      lv_qty = <lfs_vekp>-brgew + lv_qty.
*      lv_unit = <lfs_vekp>-gewei.
*    ENDIF. " IF <lfs_vekp>-vpobjkey EQ fp_wa_data-del_no
*  ENDLOOP. " LOOP AT fp_i_vekp ASSIGNING <lfs_vekp>
*
** ---> Begin of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
** Get currency value as per crietria(currency) and sel_low value(country code)
** so deleted below code
**  READ TABLE fp_i_status
**  ASSIGNING <lfs_status>
**  WITH KEY criteria = lc_unit
**  BINARY SEARCH.
**  IF sy-subrc EQ 0.
**    lv_unit_out = <lfs_status>-sel_low.
**  ENDIF. " IF sy-subrc EQ 0
** ---> End of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
*
** ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
***   Get Unit to be converted to
*  READ TABLE fp_i_status
*  ASSIGNING <lfs_status>
*  WITH KEY criteria = lc_unit
*           sel_low  = gv_country
*  BINARY SEARCH.
*  IF sy-subrc EQ 0.
*    lv_unit_out = <lfs_status>-sel_high.
*  ENDIF. " IF sy-subrc EQ 0
** ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
*
**   if HU unit is different then convert
*  IF lv_unit_out NE lv_unit.
*    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
*      EXPORTING
*        input                = lv_qty
*        unit_in              = lv_unit
*        unit_out             = lv_unit_out
*      IMPORTING
*        output               = lv_output
*      EXCEPTIONS
*        conversion_not_found = 1
*        division_by_zero     = 2
*        input_invalid        = 3
*        output_invalid       = 4
*        overflow             = 5
*        type_invalid         = 6
*        units_missing        = 7
*        unit_in_not_found    = 8
*        unit_out_not_found   = 9
*        OTHERS               = 10.
*
*    IF sy-subrc EQ 0.
*      fp_wa_data-btgew = lv_output.
*      fp_wa_data-gewei = lv_unit_out.
*    ENDIF. " IF sy-subrc EQ 0
*  ELSE. " ELSE -> IF lv_unit_out NE lv_unit
**       If unit are same no need of conversion
*    fp_wa_data-btgew = lv_qty.
*    fp_wa_data-gewei = lv_unit.
*  ENDIF. " IF lv_unit_out NE lv_unit
*ENDFORM. " F_GET_PACKING_DATA
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION_FKART
*&---------------------------------------------------------------------*
*      Validate Bill Type
*----------------------------------------------------------------------*
FORM f_validation_fkart USING fp_i_status TYPE ty_t_status.

  CONSTANTS : lc_fkart TYPE z_criteria VALUE 'FKART'. " Enh. Criteria
* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
  DATA: lv_sel_text    TYPE fpb_low. " From Value
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

  IF p_fkart IS INITIAL.
    MESSAGE e099.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF p_fkart IS INITIAL

* ---> Begin of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
* Get Billing type  as per crietria(currency) and sel_low value
* So deleted below code
*  READ TABLE fp_i_status WITH KEY criteria = lc_fkart
*  sel_low = p_fkart
*    BINARY SEARCH
*   TRANSPORTING NO FIELDS.
* ---> End of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
* Get Billing type as per crietria and sel_low value(country code)
  CLEAR lv_sel_text.
  CONCATENATE gv_country p_fkart INTO lv_sel_text
                                 SEPARATED BY c_underscore.
  READ TABLE fp_i_status WITH KEY criteria = lc_fkart
                                  sel_low  = lv_sel_text
                                  sel_high = p_fkart
                          BINARY SEARCH
                          TRANSPORTING NO FIELDS.
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
  IF sy-subrc NE 0.
    MESSAGE e096.
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_GET_BILLS_DATA
*&---------------------------------------------------------------------*
*       Get data from selected critera from selection screen
*----------------------------------------------------------------------*
FORM f_get_bills_data .

  CONSTANTS: lc_1     TYPE char1 VALUE '1', " 1 of type CHAR1
             lc_2     TYPE char1 VALUE '2', " 1 of type CHAR1
             lc_3     TYPE char1 VALUE '3', " 1 of type CHAR1
             lc_4     TYPE char1 VALUE '4', " 1 of type CHAR1
             lc_blank TYPE char1 VALUE ' '. " Blank of type CHAR1

  CASE p_gestyp.

    WHEN lc_1.

      gv_oc = p_anzkzu.
      gv_bills = p_anzkre.
      gv_docs = p_anzkdk.
*     Begin of Delete for Defect#7379 by NGARG
*      gv_nb = lc_1.    "Not used anywhere
*     End of Delete for Defect#7379 by NGARG

    WHEN lc_2.

      gv_oc = p_anzkz2.
      gv_bills = p_anzkr2.
      gv_docs = lc_blank.
*     Begin of Delete for Defect#7379 by NGARG
*      gv_nb = lc_1.
*     End of Delete for Defect#7379 by NGARG

    WHEN lc_3.

      gv_oc = lc_blank.
      gv_bills = p_anzkr3.
      gv_docs = lc_blank.
*     Begin of Delete for Defect#7379 by NGARG
*      gv_nb = lc_1.
*     End of Delete for Defect#7379 by NGARG

    WHEN lc_4.

      gv_oc = lc_blank.
      gv_bills = lc_blank.
      gv_docs = p_anzkd4.
*     Begin of Delete for Defect#7379 by NGARG
*      gv_nb = lc_blank.
*     End of Delete for Defect#7379 by NGARG
    WHEN OTHERS.
*  not needed
  ENDCASE.

ENDFORM. " F_GET_BILLS_DATA
*&---------------------------------------------------------------------*
*&      Form  F_GET_ADDRESS_DETAILS
*&---------------------------------------------------------------------*
*       Prepare Address data
*----------------------------------------------------------------------*
FORM f_get_address_details  USING    fp_i_status TYPE ty_t_status
                            CHANGING fp_export_input TYPE z01otc_irequest_service_set_ex. " Proxy Structure (generated)



  FIELD-SYMBOLS : <lfs_status> TYPE zdev_enh_status. " Enhancement Status

* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
  CONSTANTS :   lc_society    TYPE   z_criteria   VALUE 'ADRS_SOCIETY', " Enh. Criteria
                lc_address    TYPE   z_criteria   VALUE 'ADRS_ADDRESS', " Enh. Criteria
                lc_zipcode    TYPE   z_criteria   VALUE 'ADRS_ZIPCODE', " Enh. Criteria
                lc_place      TYPE   z_criteria   VALUE 'ADRS_PLACE'.   " Enh. Criteria
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

* ---> Begin of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
*  CONSTANTS :   lc_society    TYPE   z_criteria   VALUE 'SOCIETY', " Enh. Criteria
*                lc_address    TYPE   z_criteria   VALUE 'ADDRESS', " Enh. Criteria
*                lc_zipcode    TYPE   z_criteria   VALUE 'ZIPCODE', " Enh. Criteria
*                lc_place      TYPE   z_criteria   VALUE 'PLACE',   " Enh. Criteria
*                lc_email      TYPE   z_criteria   VALUE 'EMAIL'.   " Enh. Criteria


*Below code is commented as address are not only picked on the basis of
* Criteria. It should also based on the country code.
** Society
*  READ TABLE fp_i_status
*   ASSIGNING <lfs_status>
*   WITH KEY criteria = lc_society
*   BINARY SEARCH.
*  IF sy-subrc EQ 0.
*    fp_export_input-society = <lfs_status>-sel_low.
*  ENDIF. " IF sy-subrc EQ 0
*
** Address
*  READ TABLE fp_i_status
*  ASSIGNING <lfs_status>
*   WITH KEY criteria = lc_address
*    BINARY SEARCH.
*  IF sy-subrc EQ 0.
*    fp_export_input-address  = <lfs_status>-sel_low.
*  ENDIF. " IF sy-subrc EQ 0
*
** Zip code
*  READ TABLE fp_i_status
*   ASSIGNING <lfs_status>
*    WITH KEY criteria = lc_zipcode
*    BINARY SEARCH.
*  IF sy-subrc EQ 0.
*    fp_export_input-zipcode  = <lfs_status>-sel_low.
*  ENDIF. " IF sy-subrc EQ 0
*
** Place
*  READ TABLE fp_i_status
*  ASSIGNING <lfs_status>
*  WITH KEY criteria = lc_place
*   BINARY SEARCH.
*  IF sy-subrc EQ 0.
*    fp_export_input-place  = <lfs_status>-sel_low.
*  ENDIF. " IF sy-subrc EQ 0
*
* EMAIL
*  READ TABLE fp_i_status
*  ASSIGNING <lfs_status>
*  WITH KEY criteria = lc_email
*  BINARY SEARCH.
*  IF sy-subrc EQ 0.
*    fp_export_input-email  = <lfs_status>-sel_low.
*  ENDIF. " IF sy-subrc EQ 0
* ---> End of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
**Fetch address on the basis of criteria and sel_low value.
** Sel_low value should be country code.

* Society
  READ TABLE fp_i_status
   ASSIGNING <lfs_status>
   WITH KEY criteria = lc_society
            sel_low  = gv_country
   BINARY SEARCH.
  IF sy-subrc EQ 0.
    fp_export_input-society = <lfs_status>-sel_high.
  ENDIF. " IF sy-subrc EQ 0

* Address
  READ TABLE fp_i_status
  ASSIGNING <lfs_status>
   WITH KEY criteria = lc_address
           sel_low  = gv_country
    BINARY SEARCH.
  IF sy-subrc EQ 0.
    fp_export_input-address  = <lfs_status>-sel_high.
  ENDIF. " IF sy-subrc EQ 0

* Zip code
  READ TABLE fp_i_status
   ASSIGNING <lfs_status>
    WITH KEY criteria = lc_zipcode
             sel_low = gv_country
    BINARY SEARCH.
  IF sy-subrc EQ 0.
    fp_export_input-zipcode  = <lfs_status>-sel_high.
  ENDIF. " IF sy-subrc EQ 0

* Place
  READ TABLE fp_i_status
  ASSIGNING <lfs_status>
  WITH KEY criteria = lc_place
           sel_low = gv_country
   BINARY SEARCH.
  IF sy-subrc EQ 0.
    fp_export_input-place  = <lfs_status>-sel_high.
  ENDIF. " IF sy-subrc EQ 0

** EMAIL
  fp_export_input-email  = gv_usermail.
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG

ENDFORM. " F_GET_ADDRESS_DETAILS

* ---> Begin of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
** Commodity code is no longer picked from EMI table
*&---------------------------------------------------------------------*
*&      Form  F_GET_TEXTS
*&---------------------------------------------------------------------*
*       Get texts from EMI data
*----------------------------------------------------------------------*
*FORM f_get_texts  USING    fp_i_status TYPE ty_t_status
*                           fp_v_stawn  TYPE stawn                                  " Commodity Code/Import Code Number for Foreign Trade
*                  CHANGING fp_add_article_out TYPE z01otc_irequest_service_add_a1. " Proxy Structure (generated)
*
*  FIELD-SYMBOLS :<lfs_status> TYPE zdev_enh_status. " Enhancement Status
*
*  DATA  : lv_country TYPE char20, " Country of type CHAR60
*          lv_desc    TYPE char20. " Desc of type CHAR20
*
*
*  CONSTANTS: lc_country   TYPE z_criteria VALUE 'COUNTRY',   " Enh. Criteria
*             lc_ctry_lang TYPE z_criteria VALUE 'CTRY_LANG', " Enh. Criteria
*             lc_group     TYPE z_criteria VALUE 'GROUP',     " Enh. Criteria
*             lc_desc      TYPE char5      VALUE 'DESC_'.     " Desc of type CHAR5
*
** Fetch Country
*  READ TABLE fp_i_status
*  ASSIGNING <lfs_status>
*  WITH KEY criteria = lc_country
*  BINARY SEARCH.
*  IF sy-subrc EQ 0.
*    lv_country = <lfs_status>-sel_low.
*
**   Fetch langauge based on country
*    READ TABLE fp_i_status ASSIGNING <lfs_status>
*    WITH KEY criteria = lc_ctry_lang
*              sel_low = lv_country
*              BINARY SEARCH.
*    IF sy-subrc EQ 0.
**      Prepare EMI criteria value
*      CONCATENATE lc_desc
*                  <lfs_status>-sel_high
*             INTO lv_desc.
*
**     Get Description based on language
*      READ TABLE fp_i_status
*      ASSIGNING <lfs_status>
*      WITH KEY criteria = lv_desc
*               sel_low = fp_v_stawn
*               BINARY SEARCH.
*      IF sy-subrc EQ 0.
*        fp_add_article_out-description = <lfs_status>-sel_high.
*      ENDIF. " IF sy-subrc EQ 0
*    ENDIF. " IF sy-subrc EQ 0
*  ENDIF. " IF sy-subrc EQ 0
*
*
*
** Get Origin Criterion group
*  READ TABLE fp_i_status
*   ASSIGNING <lfs_status>
*  WITH KEY criteria = lc_group
*            sel_low = fp_v_stawn
*            BINARY SEARCH.
*  IF sy-subrc EQ 0.
*    fp_add_article_out-origin_criterion = <lfs_status>-sel_high.
*  ENDIF. " IF sy-subrc EQ 0
*ENDFORM. " F_GET_TEXTS

* ---> End of Delete for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION_VBELN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validation_vbeln CHANGING fp_i_vbrk TYPE ty_t_vbrk .
  IF p_vbeln IS INITIAL.
    MESSAGE e098.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF p_vbeln IS INITIAL
* Get Billing Doc Header data
  SELECT
    vbeln     " Billing Document
    fkart     " Billing Type
    waerk     " SD Document Currency
    fkdat     " Billing date for billing index and printout
    kurrf     " Exchange rate for FI postings
    kunag     " Sold-to party
    exnum     " Number of foreign trade data in MM and SD documents
    FROM vbrk " Billing Document: Header Data
    INTO TABLE fp_i_vbrk
    WHERE vbeln = p_vbeln.
  IF sy-subrc EQ 0.
    SORT fp_i_vbrk BY vbeln.
  ELSE. " ELSE -> IF sy-subrc EQ 0
    MESSAGE e097.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc EQ 0
ENDFORM. " F_VALIDATION_VBELN
*&---------------------------------------------------------------------*
*&      Form  F_GET_HU_DATA
*&---------------------------------------------------------------------*
*       Get HU related qty data
*----------------------------------------------------------------------*
FORM f_get_hu_data  USING    fp_i_likp TYPE ty_t_likp
                    CHANGING fp_i_vekp TYPE ty_t_vekp.


  TYPES :BEGIN OF lty_delivery,
          del_no TYPE vpobjkey, " Key for Object to Which the Handling Unit is Assigned
         END OF lty_delivery.

  DATA: lwa_delivery TYPE lty_delivery,
        li_likp TYPE ty_t_likp,
        li_delivery TYPE STANDARD TABLE OF lty_delivery.

  FIELD-SYMBOLS: <lfs_likp> TYPE ty_likp.

  CONSTANTS: lc_ob_del TYPE vpobj VALUE '01'. " Packing Object

* Delete duplicate delivery numbers
  li_likp[] = fp_i_likp[].
  DELETE ADJACENT DUPLICATES FROM li_likp COMPARING vbeln.
*  Prepare a delivery number table
  LOOP AT li_likp ASSIGNING <lfs_likp>.
    lwa_delivery-del_no = <lfs_likp>-vbeln.
    APPEND lwa_delivery TO li_delivery.
    CLEAR lwa_delivery.
  ENDLOOP. " LOOP AT li_likp ASSIGNING <lfs_likp>


  IF li_delivery[] IS NOT INITIAL.
    SELECT brgew    " Total Weight of Handling Unit
           gewei    " Weight Unit
           vpobj    " Packing Object
           vpobjkey " Key for Object to Which the Handling Unit is Assigned
      FROM vekp     " Handling Unit - Header Table
      INTO TABLE fp_i_vekp
      FOR ALL ENTRIES IN li_delivery
      WHERE vpobj EQ lc_ob_del
      AND vpobjkey EQ li_delivery-del_no.
    IF sy-subrc EQ 0.
      SORT fp_i_vekp BY vpobjkey.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_delivery[] IS NOT INITIAL
ENDFORM. " F_GET_HU_DATA
*&---------------------------------------------------------------------*
*&      Form  F_LOGOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_USERNAME  text
*      -->P_LV_PASSWORD  text
*----------------------------------------------------------------------*
FORM f_logout  USING    fp_v_username  TYPE string
                        fp_v_password  TYPE string
                        fp_ref_certify TYPE REF TO z01otc_co_si_certificate_of_o1. " Service Interface for Certificate of Origin for IDD0197.

*       Data Declaration for LOGOUT method
  DATA : lv_error                    TYPE string,
         lref_cx_system_fault        TYPE REF TO cx_ai_system_fault,      " Fehler Certify
         lref_cx_appl_fault          TYPE REF TO cx_ai_application_fault. " Application Integration: Application Error

  DATA : lwa_logout_input TYPE z01otc_irequest_service_log_o1,           " Proxy Structure (generated)
         lwa_logout_output TYPE z01otc_irequest_service_log_ou ##needed. " Proxy Structure (generated)

  CONSTANTS: lc_error      TYPE   char1        VALUE 'E', " Error of type CHAR1
             lc_info       TYPE   char1        VALUE 'I'. " Info of type CHAR1


*     Fill Logout details
  lwa_logout_input-user_name = fp_v_username.
  lwa_logout_input-password = fp_v_password.

*     LOGOUT
  TRY.
      CALL METHOD fp_ref_certify->so_logout_s_out
        EXPORTING
          output = lwa_logout_input
        IMPORTING
          input  = lwa_logout_output.

*       Catch Exceptions
    CATCH cx_ai_system_fault INTO lref_cx_system_fault.
      lv_error  = lref_cx_system_fault->get_text( ).
      MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
      LEAVE LIST-PROCESSING.
    CATCH cx_ai_application_fault INTO lref_cx_appl_fault.
      lv_error  = lref_cx_appl_fault->get_text( ).
      MESSAGE lv_error TYPE lc_error DISPLAY LIKE lc_info.
      LEAVE LIST-PROCESSING.
  ENDTRY.
ENDFORM. " F_LOGOUT

* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
*&---------------------------------------------------------------------*
*&      Form  F_GET_TEXTS_BRF
*&---------------------------------------------------------------------*
*       Get Commodity Desc & Commodity Group
*       T-Code (ZOTC_COMM_CODE)
*----------------------------------------------------------------------*
*      -->FP_I_STATUS         EMI table
*      -->FP_V_STAWN          Commodity Code
*      <--FP_ADD_ARTICLE_OUT  Proxy Structure
*----------------------------------------------------------------------*
FORM f_get_texts_brf  USING
                          fp_i_status TYPE ty_t_status
                          fp_v_stawn TYPE stawn                                   " Commodity Code/Import Code Number for Foreign Trade
                 CHANGING
                          fp_add_article_out TYPE z01otc_irequest_service_add_a1. " Proxy Structure (generated)


  TYPES:
   BEGIN OF lty_value,
    country_code   TYPE string,
    language       TYPE string,
    commodity_code TYPE string,
   END OF lty_value,

   BEGIN OF lty_comm,
    comm_code_desc TYPE string,
    comm_group     TYPE string,
   END OF lty_comm.

  CONSTANTS:
      lc_ctry_lang        TYPE z_criteria    VALUE 'SPRAS',           " Enh. Criteria
      lc_separator        TYPE xfeld         VALUE '.'              , " Checkbox
      lc_comm_code        TYPE string        VALUE 'IN_COMM_CODE',
      lc_name_appl        TYPE string        VALUE 'ZA_OTC_IDD_0197_CERT_OF_ORIGIN',
      lc_name_func        TYPE string        VALUE 'ZF_OTC_IDD_0197_COMMODITY_CODE'.

  DATA: lwa_value          TYPE lty_value,
        lwa_comm           TYPE lty_comm,
        lv_langu_iso       TYPE laiso,                    " 2-Character SAP Language Code
        lv_langu_int       TYPE spras,                    " Language Key
        lref_utility       TYPE REF TO /bofu/cl_fdt_util, " BRFplus Utilities
        lref_admin_data    TYPE REF TO if_fdt_admin_data, " FDT: Administrative Data
        lref_function      TYPE REF TO if_fdt_function,   " FDT: Function
        lref_context       TYPE REF TO if_fdt_context,    " FDT: Context
        lref_result        TYPE REF TO if_fdt_result,     " FDT: Result
        lref_fdt           TYPE REF TO cx_fdt,            " FDT: Abstract Exception Class
        lv_except_msg      TYPE string,
        lv_query_in        TYPE        string,
        lv_query_out       TYPE        if_fdt_types=>id.

  FIELD-SYMBOLS :<lfs_status> TYPE zdev_enh_status. " Enhancement Status

  CLEAR lwa_value.

***Pass Country code, Language and Commodity code
* A) Country Code
  lwa_value-country_code = gv_country.

* B)Language key
  READ TABLE fp_i_status ASSIGNING <lfs_status>
   WITH KEY criteria = lc_ctry_lang
             sel_low = gv_country
             BINARY SEARCH.
  IF sy-subrc EQ 0.
    lv_langu_iso    = <lfs_status>-sel_high.

*Convert two-digit ISO language -> one-digit SAP language key
    CALL FUNCTION 'CONVERSION_EXIT_ISOLA_INPUT'
      EXPORTING
        input            = lv_langu_iso
      IMPORTING
        output           = lv_langu_int
      EXCEPTIONS
        unknown_language = 1
        OTHERS           = 2.
    IF sy-subrc EQ 0.
      lwa_value-language = lv_langu_int.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0

* C) Commodity Code
  lwa_value-commodity_code = fp_v_stawn.

  CLEAR: lref_utility,
         lv_query_in,
         lv_query_out.
*-- Create an instance of BRFPlus Utility class
  lref_utility ?= /bofu/cl_fdt_util=>get_instance( ).

*-- Make BRF query by concatenation of BRF application name and BRF Function name
  CONCATENATE lc_name_appl lc_name_func
         INTO lv_query_in
         SEPARATED BY lc_separator.

*-- To get GUID of query string
  IF lref_utility IS BOUND.
    CALL METHOD lref_utility->convert_function_input
      EXPORTING
        iv_input  = lv_query_in
      IMPORTING
        ev_output = lv_query_out
      EXCEPTIONS
        failed    = 1
        OTHERS    = 2.

    IF sy-subrc IS INITIAL.
*-- Set the variable value(s)
      cl_fdt_factory=>get_instance_generic( EXPORTING iv_id = lv_query_out
                                            IMPORTING eo_instance = lref_admin_data ).
      lref_function ?= lref_admin_data.
      lref_context  ?= lref_function->get_process_context( ).

** Pass Country Code and SAP UserID
      lref_context->set_value( iv_name = lc_comm_code  ia_value = lwa_value ).
      TRY.
          lref_function->process( EXPORTING io_context = lref_context
                                  IMPORTING eo_result = lref_result ).

          lref_result->get_value( IMPORTING ea_value = lwa_comm ).

        CATCH cx_fdt INTO lref_fdt.
          CLEAR lwa_comm.
          lv_except_msg = lref_fdt->if_message~get_text( ).
          MESSAGE e000 WITH lv_except_msg.
      ENDTRY.
*Populate Comm Code Desc
      fp_add_article_out-description = lwa_comm-comm_code_desc.
* Populate Comm group
      fp_add_article_out-origin_criterion = lwa_comm-comm_group.

    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF lref_utility IS BOUND
ENDFORM. " F_GET_TEXTS_BRF

*&---------------------------------------------------------------------*
*&      Form  F_GET_TEXTS_BRF
*&---------------------------------------------------------------------*
*       Get Crendentails from BRFPLUS table
*       T-Code(ZOTC_CERITY_LOGON)
*----------------------------------------------------------------------*
*      <--FP_USERNAME  User name
*      <--FP_PASSWORD  Password
*      <--FP_MAIL      Mail
*----------------------------------------------------------------------*
FORM f_get_crendtials_brf  CHANGING fp_username TYPE string
                                    fp_password TYPE string
                                    fp_usermail TYPE string.


  TYPES:
   BEGIN OF lty_value,
    country_code     TYPE string,
    sap_user_id      TYPE string,
   END OF lty_value,

   BEGIN OF lty_crend,
    certify_user_id   TYPE string,
    certify_user_pwd  TYPE string,
    email             TYPE string,
   END OF lty_crend.

  CONSTANTS:
      lc_separator        TYPE xfeld         VALUE '.'              , " Checkbox
      lc_logon            TYPE string        VALUE 'IN_LOGON',
      lc_name_appl        TYPE string        VALUE 'ZA_OTC_IDD_0197_CERT_OF_ORIGIN',
      lc_name_func        TYPE string        VALUE 'ZF_OTC_IDD_0197_CERTIFY_LOGON'.

  DATA: lwa_value          TYPE lty_value,
        lwa_crend          TYPE lty_crend,
        lref_utility       TYPE REF TO /bofu/cl_fdt_util, " BRFplus Utilities
        lref_admin_data    TYPE REF TO if_fdt_admin_data, " FDT: Administrative Data
        lref_function      TYPE REF TO if_fdt_function,   " FDT: Function
        lref_context       TYPE REF TO if_fdt_context,    " FDT: Context
        lref_result        TYPE REF TO if_fdt_result,     " FDT: Result
        lref_fdt           TYPE REF TO cx_fdt,            " FDT: Abstract Exception Class
        lv_except_msg      TYPE string,
        lv_query_in        TYPE        string,
        lv_query_out       TYPE        if_fdt_types=>id.

  CLEAR lwa_value.
*** Pass Country code and User-ID
  lwa_value-country_code = gv_country.
  lwa_value-sap_user_id = sy-uname.

  CLEAR: lref_utility,
         lv_query_in,
         lv_query_out.
*-- Create an instance of BRFPlus Utility class
  lref_utility ?= /bofu/cl_fdt_util=>get_instance( ).

*-- Make BRF query by concatenation of BRF application name and BRF Function name
  CONCATENATE lc_name_appl lc_name_func
         INTO lv_query_in
         SEPARATED BY lc_separator.

*-- To get GUID of query string
  IF lref_utility IS BOUND.
    CALL METHOD lref_utility->convert_function_input
      EXPORTING
        iv_input  = lv_query_in
      IMPORTING
        ev_output = lv_query_out
      EXCEPTIONS
        failed    = 1
        OTHERS    = 2.

    IF sy-subrc IS INITIAL.
*-- Set the variable value(s)
      cl_fdt_factory=>get_instance_generic( EXPORTING iv_id = lv_query_out
                                            IMPORTING eo_instance = lref_admin_data ).
      lref_function ?= lref_admin_data.
      lref_context  ?= lref_function->get_process_context( ).

** Pass Country Code and SAP UserID
      lref_context->set_value( iv_name = lc_logon  ia_value = lwa_value ).
      TRY.
          lref_function->process( EXPORTING io_context = lref_context
                                  IMPORTING eo_result = lref_result ).

          lref_result->get_value( IMPORTING ea_value = lwa_crend ).

        CATCH cx_fdt INTO lref_fdt.
          CLEAR lwa_crend.
          lv_except_msg = lref_fdt->if_message~get_text( ).
          MESSAGE e000 WITH lv_except_msg.
      ENDTRY.

** Get Username, Password and Email-ID.
      fp_username = lwa_crend-certify_user_id.
      fp_password = lwa_crend-certify_user_pwd.
      fp_usermail     = lwa_crend-email.

    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF lref_utility IS BOUND
ENDFORM. " F_GET_TEXTS_BRF
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
*&---------------------------------------------------------------------*
*&      Form  F_GET_GROSS_WEIGHT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FP_I_VBRK  text
*      -->P_FP_I_VBRP  text
*      <--P_LWA_DATA  text
*----------------------------------------------------------------------*
FORM f_get_gross_weight  USING    fp_wa_vbrk       TYPE ty_vbrk
                                  fp_i_vbrp        TYPE ty_t_vbrp
                                  fp_i_status      TYPE ty_t_status
                         CHANGING fp_wa_data       TYPE ty_data.
  DATA : lv_output    TYPE f,          " Output of type Floating Point Numbers
         lv_qty       TYPE brgew_vekp, " Total Weight of Handling Unit
         lv_unit_out  TYPE msehi,      " Unit of Measurement
         lv_unit      TYPE gewei.      " Weight Unit

  FIELD-SYMBOLS : <lfs_status> TYPE zdev_enh_status, " Enhancement Status
                  <lfs_vbrp>   TYPE ty_vbrp.         " Handling Unit Header-Data - Communication Structure

  CONSTANTS:       lc_unit     TYPE z_criteria VALUE 'UNIT'. " Enh. Criteria




  LOOP AT fp_i_vbrp ASSIGNING <lfs_vbrp>.
    lv_qty  = <lfs_vbrp>-brgew + lv_qty.
    lv_unit = <lfs_vbrp>-gewei.
  ENDLOOP. " LOOP AT fp_i_vbrp ASSIGNING <lfs_vbrp>

**   Get Unit to be converted to
  READ TABLE fp_i_status
  ASSIGNING <lfs_status>
  WITH KEY criteria = lc_unit
           sel_low  = gv_country
  BINARY SEARCH.
  IF sy-subrc EQ 0.
    lv_unit_out = <lfs_status>-sel_high.
  ENDIF. " IF sy-subrc EQ 0


*   if HU unit is different then convert
  IF lv_unit_out NE lv_unit.
    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING
        input                = lv_qty
        unit_in              = lv_unit
        unit_out             = lv_unit_out
      IMPORTING
        output               = lv_output
      EXCEPTIONS
        conversion_not_found = 1
        division_by_zero     = 2
        input_invalid        = 3
        output_invalid       = 4
        overflow             = 5
        type_invalid         = 6
        units_missing        = 7
        unit_in_not_found    = 8
        unit_out_not_found   = 9
        OTHERS               = 10.

    IF sy-subrc EQ 0.
      fp_wa_data-btgew = lv_output.
      fp_wa_data-gewei = lv_unit_out.
    ENDIF. " IF sy-subrc EQ 0
  ELSE. " ELSE -> IF lv_unit_out NE lv_unit
*       If unit are same no need of conversion
    fp_wa_data-btgew = lv_qty.
    fp_wa_data-gewei = lv_unit.
  ENDIF. " IF lv_unit_out NE lv_unit

ENDFORM. " F_GET_GROSS_WEIGHT
