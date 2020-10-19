*&---------------------------------------------------------------------*
*&  Include           ZOTCN0087O_PAYMENTCARD_CHECK
*&---------------------------------------------------------------------*
***********************************************************************
* PROGRAM    :  ZXUSRU01 (Include)                                     *
* TITLE      :  Custom Payment Card User Exit                          *
* DEVELOPER  :  Bhargav Gundabolu                                      *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0087                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Custom exit to disable history for payment card. User   *
* will not be able to view previous credit card entry in history       *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 01-Feb-2013 BGUNDAB  E1DK909101 OTC_EDD_0087 Custom_Paymentcard_Check*
*&---------------------------------------------------------------------*

  DATA: lv_disabled TYPE abap_bool VALUE 'X',
        lv_rc       TYPE i,
        li_fields   TYPE STANDARD TABLE OF zotc_fld_history,
        lwa_fields  TYPE                   zotc_fld_history,
        lv_field    TYPE                   string.

  SELECT * FROM zotc_fld_history
  INTO TABLE li_fields.

  IF sy-subrc IS INITIAL.
    LOOP AT li_fields INTO lwa_fields.
      lv_field    = lwa_fields-fld_name.
      CLEAR lv_rc.
      CALL METHOD cl_gui_frontend_services=>disablehistoryforfield
        EXPORTING
          fieldname                     = lv_field
          bdisabled                     = lwa_fields-hist_disable
        CHANGING
          rc                            = lv_rc
        EXCEPTIONS
          field_not_found               = 1
          disablehistoryforfield_failed = 2
          cntl_error                    = 3
          unable_to_disable_field       = 4
          OTHERS                        = 5.
      IF sy-subrc IS INITIAL.
      ENDIF.
      CLEAR lv_field.
    ENDLOOP.
  ENDIF.
