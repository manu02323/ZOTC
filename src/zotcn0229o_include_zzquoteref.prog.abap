*************************************************************************
* PROGRAM    :  ZOTCN0229O_INCLUDE_ZZQUOTEREF    (include)             *
* TITLE      :  User Exit for change order status for cpq validation   *
* DEVELOPER  :  Raghav Sureddi                                         *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_0229                                             *
*----------------------------------------------------------------------*
* DESCRIPTION:  based on  zzquoteref set Order user status             *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 01-Jul-2019 U033876  E2DK924884 Initial dev - OTC_IDD_0229           *
*                                based on zzquoteref set Order user    *
*                                status
*&---------------------------------------------------------------------*
* 21-Aug-2019 U033876  E2DK924884 Defect10289 - OTC_IDD_0229           *
*                                check zzquoteref is not initial as    *
*                                "Contains Any" does not work          *
* 29-Oct-2019 RNATHAK E2DK927780 Defect 10901 - OTC_IDD_0229
*                                 changing from CA (Contains Any) to
*                                   CS (Contains string)
*----------------------------------------------------------------------*




  CONSTANTS: lc_emi    TYPE z_enhancement VALUE 'OTC_IDD_0229',   " Enhancement No.
             lc_null   TYPE z_criteria VALUE 'NULL',                 " Enh. Criteria
             lc_system TYPE z_criteria VALUE 'SYSTEM',               " System of type CHAR7
             lc_quote  TYPE z_criteria VALUE 'QUOTE_TYPE'.           " Quote of type CHAR10

  TYPES: BEGIN OF lty_temp,
           zzquoteref TYPE z_quoteref,              " Legacy Qtn Ref
         END OF lty_temp,

         BEGIN OF lty_trtyp,
           trtyp TYPE trtyp,                        " Transaction type
         END OF lty_trtyp.


  DATA: li_status        TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
        li_quote         TYPE STANDARD TABLE OF fkk_ranges,      " Structure: Select Options
        lwa_quote        TYPE fkk_ranges,                        " Structure: Select Options
        li_temp          TYPE STANDARD TABLE OF lty_temp,
        lwa_vbap         TYPE vbapvb,
        lwa_temp         TYPE lty_temp,
        lv_system        TYPE char7,                             " System of type CHAR7
        lv_flag          TYPE flag,                              " General Flag
        lv_trtyp         TYPE trtyp,                             " Transaction type
        lv_user_stat     TYPE j_stext,
        lv_existing_stat TYPE j_stext,
        lv_objnr         TYPE j_objnr, " Object number
        lv_stonr         TYPE j_stonr,
        lv_doctype       TYPE z_doctyp.

  FIELD-SYMBOLS: <lfs_status> TYPE zdev_enh_status, " Enhancement Status
                 <lfs_temp1>  TYPE lty_temp.
  CONSTANTS: lc_status      TYPE z_criteria VALUE 'STATUS',
             lc_doctype     TYPE z_criteria VALUE 'DOCTYPE', " Order from CPQ
             lc_user_status TYPE j_status   VALUE   'E0002',
             lc_u           TYPE updkz      VALUE   'U',
             lc_en          TYPE spras      VALUE   'E',
             lc_i           TYPE updkz      VALUE   'I'.

  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_emi
    TABLES
      tt_enh_status     = li_status.

  DELETE li_status WHERE active IS INITIAL.

  IF li_status IS NOT INITIAL.
    READ TABLE li_status WITH KEY criteria = lc_null
                                  active = abap_true
                         TRANSPORTING NO FIELDS
                         BINARY SEARCH.
    IF sy-subrc = 0.

*  IF xvbak-zzdoctyp NE lc_9 .
      READ TABLE li_status ASSIGNING <lfs_status>
                          WITH KEY criteria = lc_doctype
                                   active = abap_true.
      IF sy-subrc = 0.
        lv_doctype = <lfs_status>-sel_low.
      ENDIF.
*Only trigger below logic if the order is not from CPQ directly
      IF xvbak-zzdoctyp NE  lv_doctype .
        READ TABLE li_status ASSIGNING <lfs_status>
                            WITH KEY criteria = lc_status
                                     active = abap_true.
        IF sy-subrc = 0.
          lv_user_stat = <lfs_status>-sel_low.

* Before updating the status check existing order status
* if its already ZCp2 then do not change it back to ZCP1.
          CALL FUNCTION 'STATUS_TEXT_EDIT'
            EXPORTING
              client           = sy-mandt
              flg_user_stat    = abap_true
              objnr            = xvbak-objnr
              only_active      = abap_true
              spras            = lc_en
              bypass_buffer    = ' '
            IMPORTING
              user_line        = lv_existing_stat
            EXCEPTIONS
              object_not_found = 1
              OTHERS           = 2.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.
* If existing status is ZCP2, then do not change it to ZCP1 back as this will cause
* CPQ trigger again.
          IF lv_existing_stat NE  <lfs_status>-sel_high.
            DELETE li_status WHERE criteria NE lc_system
                             AND criteria NE lc_quote.
            IF li_status IS NOT INITIAL.
* Loop through emi entries and group Quote types and system
              LOOP AT li_status ASSIGNING <lfs_status>.
                CASE <lfs_status>-criteria.
                  WHEN lc_system.
                    lv_system = <lfs_status>-sel_low.
                  WHEN lc_quote.
                    lwa_quote-sign   = <lfs_status>-sel_sign.
                    lwa_quote-option = <lfs_status>-sel_option.
                    lwa_quote-low    = <lfs_status>-sel_low.
                    APPEND lwa_quote TO li_quote.
                    CLEAR: lwa_quote.
                  WHEN OTHERS.
                ENDCASE.
              ENDLOOP. " LOOP AT li_status ASSIGNING <lfs_status>

* loop through items and check the zzquoteref
*  Begin of change for Defect 10289
*              LOOP AT xvbap INTO lwa_vbap  .
              LOOP AT xvbap INTO lwa_vbap WHERE zzquoteref IS NOT INITIAL .
* End of change for Defect   10289
*  Begin of change for Defect 10901
*                IF  lwa_vbap-zzquoteref CA lv_system.
                IF  lwa_vbap-zzquoteref CS lv_system.
*  End of change for Defect 10901

                  IF lwa_vbap-zzquoteref+0(2) IN li_quote[].
                    lv_flag = abap_true.
                    EXIT.
                  ENDIF. " IF lwa_temp-zzquoteref+0(2) IN li_quote[]
                ENDIF. " IF lv_system = lwa_temp-zzquoteref+6(3)
              ENDLOOP.
* If any one of the quote reference number meets the EMI criteria,
* then Change the status.
              IF lv_flag = abap_true AND lv_user_stat IS NOT INITIAL .

                lv_objnr       = xvbak-objnr.
**** Updating the required status .
                CALL FUNCTION 'STATUS_CHANGE_EXTERN'
                  EXPORTING
                    objnr               = lv_objnr
                    user_status         = lc_user_status
                  IMPORTING
                    stonr               = lv_stonr
                  EXCEPTIONS
                    object_not_found    = 1
                    status_inconsistent = 2
                    status_not_allowed  = 3
                    OTHERS              = 4.
                IF sy-subrc NE 0.
**** Updating the required status based on vbak-objnr
* as during create xvbak-objnr will have temp value so
* use vbak-objnr
                  lv_objnr       = vbak-objnr.
                  CALL FUNCTION 'STATUS_CHANGE_EXTERN'
                    EXPORTING
                      objnr               = lv_objnr
                      user_status         = lc_user_status
                    IMPORTING
                      stonr               = lv_stonr
                    EXCEPTIONS
                      object_not_found    = 1
                      status_inconsistent = 2
                      status_not_allowed  = 3
                      OTHERS              = 4.
                  IF sy-subrc NE 0.
* do nothing.
                  ENDIF.
                ENDIF.
              ENDIF. " IF lv_flag = abap_true
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
