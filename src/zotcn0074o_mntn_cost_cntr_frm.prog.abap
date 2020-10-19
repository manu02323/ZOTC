************************************************************************
* PROGRAM    :  ZOTCN0074O_MNTN_COST_CNTR_FRM                          *
* TITLE      :  OTC_EDD_0074_Sales Rep Cost Center Assignment          *
* DEVELOPER  :  Debraj Haldar                                          *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_EDD_0074                                           *
*----------------------------------------------------------------------*
* DESCRIPTION: Include for Subroutine Pool                             *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 30-JUN-2012 DHALDAR  E1DK903043 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_RANGETAB
*&---------------------------------------------------------------------*
*       Subroutine to populate the rangetable to be used to call the
*       view maintenance
*----------------------------------------------------------------------*
*  -->  i_namtab        Using parameter
*  <--  i_rangetab      Changing parameter
*----------------------------------------------------------------------*
FORM f_populate_rangetab USING fp_i_namtab TYPE ty_t_namtab
                         CHANGING fp_i_rangetab TYPE ty_t_rangetab.

*Local constant declaration
  CONSTANTS: lc_vkorg TYPE char5 VALUE 'VKORG', "Constant value VKORG
             lc_and   TYPE char3 VALUE 'AND',   "Constant value AND
             lc_eq    TYPE char2 VALUE 'EQ',    "Constant value EQ
             lc_or    TYPE char2 VALUE 'OR',    "Constant value OR
             lc_ge    TYPE char2 VALUE 'GE',    "Constant value GE
             lc_bt    TYPE char2 VALUE 'BT',    "Constant value BT
             lc_le    TYPE char2 VALUE 'LE',    "Constant value LE
             lc_auart TYPE char5 VALUE 'AUART', "Constant value AUART
             lc_kunnr TYPE char5 VALUE 'KUNNR'. "Constant value KUNNR

*Local data declaration
  DATA:   lwa_rangetab TYPE ty_rangetab , "Local workarea of type ty_rangetab
          lwa_namtab   TYPE ty_namtab,    "Local workarea of type ty_namtab
          lwa_s_vkorg LIKE LINE OF s_vkorg,"Local workarea of type s_vkorg
          lwa_s_auart LIKE LINE OF s_auart,"Local workarea of type s_auart
          lwa_s_kunnr LIKE LINE OF s_kunnr,"Local workarea of type s_kunnr
          lv_count TYPE sy-tabix. "Line count

  FIELD-SYMBOLS: <lfs_rangetab> TYPE ty_rangetab. "Field symbol of type ty_rangetab

  REFRESH: fp_i_rangetab[].

  LOOP AT fp_i_namtab INTO lwa_namtab.


    CASE lwa_namtab-viewfield.

      WHEN lc_vkorg.
*  Populate values for field Sales Org

*Check whether fp_i_rangetab is having records
        IF fp_i_rangetab[] IS NOT INITIAL.
*If records are present mark the and_or operator of last record as and

          DESCRIBE TABLE fp_i_rangetab LINES lv_count.
          READ TABLE fp_i_rangetab ASSIGNING <lfs_rangetab> INDEX lv_count.
          IF sy-subrc = 0.
            <lfs_rangetab>-and_or    = lc_and.
          ENDIF.


        ENDIF.

        CLEAR lwa_rangetab.
        lwa_rangetab-viewfield = lwa_namtab-viewfield.
        lwa_rangetab-tabix     = sy-tabix.
        lwa_rangetab-ddic      = lwa_namtab-readonly.

        LOOP AT s_vkorg INTO lwa_s_vkorg.
          CASE lwa_s_vkorg-option.
            WHEN lc_eq.
              lwa_rangetab-and_or    = lc_or.
              lwa_rangetab-operator  = lc_eq.
              lwa_rangetab-value     = lwa_s_vkorg-low.
              APPEND lwa_rangetab TO fp_i_rangetab.

            WHEN lc_bt.
              lwa_rangetab-and_or    = lc_and.
              lwa_rangetab-operator  = lc_ge.
              lwa_rangetab-value     = lwa_s_vkorg-low.
              APPEND lwa_rangetab TO fp_i_rangetab.

              lwa_rangetab-and_or    = lc_and.
              lwa_rangetab-operator  = lc_le.
              lwa_rangetab-value     = lwa_s_vkorg-high.
              APPEND lwa_rangetab TO fp_i_rangetab.

          ENDCASE.
        ENDLOOP.
*  Populate values for field Sales Doc type
      WHEN lc_auart.
        IF fp_i_rangetab[] IS NOT INITIAL.
*If records are present mark the and_or operator of last record as and

          DESCRIBE TABLE fp_i_rangetab LINES lv_count.
          READ TABLE fp_i_rangetab ASSIGNING <lfs_rangetab> INDEX lv_count.
          IF sy-subrc = 0.
            <lfs_rangetab>-and_or    = lc_and.
          ENDIF.

        ENDIF.

        CLEAR lwa_rangetab.
        lwa_rangetab-viewfield = lwa_namtab-viewfield.
        lwa_rangetab-tabix     = sy-tabix.
        lwa_rangetab-ddic      = lwa_namtab-readonly.

        LOOP AT s_auart INTO lwa_s_auart.
          CASE lwa_s_auart-option.
            WHEN lc_eq.
              lwa_rangetab-and_or    = lc_or.
              lwa_rangetab-operator  = lc_eq.
              lwa_rangetab-value     = lwa_s_auart-low.
              APPEND lwa_rangetab TO fp_i_rangetab.

            WHEN lc_bt.
              lwa_rangetab-and_or    = lc_and.
              lwa_rangetab-operator  = lc_ge.
              lwa_rangetab-value     = lwa_s_auart-low.
              APPEND lwa_rangetab TO fp_i_rangetab.

              lwa_rangetab-and_or    = lc_and.
              lwa_rangetab-operator  = lc_le.
              lwa_rangetab-value     = lwa_s_auart-high.
              APPEND lwa_rangetab TO fp_i_rangetab.

          ENDCASE.
        ENDLOOP.
*  Populate values for field customer
      WHEN lc_kunnr.

        IF fp_i_rangetab[] IS NOT INITIAL.
*If records are present mark the and_or operator of last record as and

          DESCRIBE TABLE fp_i_rangetab LINES lv_count.
          READ TABLE fp_i_rangetab ASSIGNING <lfs_rangetab> INDEX lv_count.
          IF sy-subrc = 0.
            <lfs_rangetab>-and_or    = lc_and.
          ENDIF.
        ENDIF.

        CLEAR lwa_rangetab.
        lwa_rangetab-viewfield = lwa_namtab-viewfield.
        lwa_rangetab-tabix     = sy-tabix.
        lwa_rangetab-ddic      = lwa_namtab-readonly.

        LOOP AT s_kunnr INTO lwa_s_kunnr.
          CASE lwa_s_kunnr-option.
            WHEN lc_eq.
              lwa_rangetab-and_or    = lc_or.
              lwa_rangetab-operator  = lc_eq.
              lwa_rangetab-value     = lwa_s_kunnr-low.
              APPEND lwa_rangetab TO fp_i_rangetab.

            WHEN lc_bt.
              lwa_rangetab-and_or    = lc_and.
              lwa_rangetab-operator  = lc_ge.
              lwa_rangetab-value     = lwa_s_kunnr-low.
              APPEND lwa_rangetab TO fp_i_rangetab.

              lwa_rangetab-and_or    = lc_and.
              lwa_rangetab-operator  = lc_le.
              lwa_rangetab-value     = lwa_s_kunnr-high.
              APPEND lwa_rangetab TO fp_i_rangetab.

          ENDCASE.
        ENDLOOP.
    ENDCASE.
    CLEAR lwa_namtab.
  ENDLOOP.

ENDFORM.                    " F_POPULATE_RANGETAB
*&---------------------------------------------------------------------*
*&      Form  F_GET_DDIC
*&---------------------------------------------------------------------*
*       Subroutine to get DDIC information for the table ZOTC_COSTCENTER
*----------------------------------------------------------------------*
*  -->  i_header
*  <--  i_namtab
*----------------------------------------------------------------------*
FORM f_get_ddic CHANGING fp_i_header TYPE ty_t_header
                         fp_i_namtab TYPE ty_t_namtab
                         fp_i_rangetab TYPE ty_t_rangetab.

  CONSTANTS: lc_tablename TYPE tabname VALUE 'ZOTC_COSTCENTER'. "Constant for table name 'ZOTC_COSTCENTER'

  CALL FUNCTION 'VIEW_GET_DDIC_INFO'
    EXPORTING
      viewname        = lc_tablename
    TABLES
      x_header        = fp_i_header
      x_namtab        = fp_i_namtab
      sellist         = fp_i_rangetab
    EXCEPTIONS
      no_tvdir_entry  = 1
      table_not_found = 2.
* Exceptions are not handled

ENDFORM.                    " F_GET_DDIC

*&---------------------------------------------------------------------*
*&      Form  F_VIEW_MAINTENANCE
*&---------------------------------------------------------------------*
*       Subroutine to call view maintenance
*----------------------------------------------------------------------*
*      -->FP_GV_ACTION display or change mode
*----------------------------------------------------------------------*
FORM f_view_maintenance  USING  fp_gv_action TYPE char1.

  CONSTANTS: lc_table_name TYPE tabname VALUE 'ZOTC_COSTCENTER'. "Constant for table name 'ZOTC_COSTCENTER'


  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      action                       = fp_gv_action
      view_name                    = lc_table_name
    TABLES
      dba_sellist                  = i_rangetab
    EXCEPTIONS
      client_reference             = 1
      foreign_lock                 = 2
      invalid_action               = 3
      no_clientindependent_auth    = 4
      no_database_function         = 5
      no_editor_function           = 6
      no_show_auth                 = 7
      no_tvdir_entry               = 8
      no_upd_auth                  = 9
      only_show_allowed            = 10
      system_failure               = 11
      unknown_field_in_dba_sellist = 12
      view_not_found               = 13
      maintenance_prohibited       = 14
      OTHERS                       = 15.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.



ENDFORM.                    " F_VIEW_MAINTENANCE
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DOC_TYP
*&---------------------------------------------------------------------*
*       Subroutine to validate doc type
*----------------------------------------------------------------------*
FORM f_validate_doc_typ .

* Local data declaration
  DATA: lv_auart TYPE auart.       "Sales Document Type.

  IF s_auart[] IS NOT INITIAL.
* Select and validate the value for field plant against selection
*screen
    SELECT auart UP TO 1 ROWS      "Sales Document Type
           FROM tvak
           INTO lv_auart
           WHERE auart IN s_auart[].
    ENDSELECT.

* Check sy-subrc after select
    IF sy-subrc NE 0.
* If sy-subrc is not equal to zero display error mesage
      MESSAGE e000 WITH 'Invalid document type'(002).
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDATE_DOC_TYP
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_CUST
*&---------------------------------------------------------------------*
*       Subroutine to validate customer
*----------------------------------------------------------------------*

FORM f_validate_cust .

* Local data declaration
  DATA: lv_kunnr TYPE kunnr.       "Customer

  IF s_kunnr[] IS NOT INITIAL.
* Select and validate the value for field customer against selection
*screen
    SELECT kunnr UP TO 1 ROWS      "Customer
           FROM kna1
           INTO lv_kunnr
           WHERE kunnr IN s_kunnr[].
    ENDSELECT.

* Check sy-subrc after select
    IF sy-subrc NE 0.
* If sy-subrc is not equal to zero display error mesage
      MESSAGE e000 WITH 'Invalid customer'(003).
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDATE_CUST
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SALES_ORG
*&---------------------------------------------------------------------*
*       Subroutine to validate sales org
*----------------------------------------------------------------------*
FORM f_validate_sales_org .

* Local data declaration
  DATA: lv_vkorg TYPE vkorg.       "Customer

  IF s_vkorg[] IS NOT INITIAL.
* Select and validate the value for field customer against selection
*screen
    SELECT vkorg UP TO 1 ROWS      "Customer
           FROM tvko
           INTO lv_vkorg
           WHERE vkorg IN s_vkorg[].
    ENDSELECT.

* Check sy-subrc after select
    IF sy-subrc NE 0.
* If sy-subrc is not equal to zero display error mesage
      MESSAGE e000 WITH 'Invalid sales organisation'(004).
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SALES_ORG
