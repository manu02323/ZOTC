*&---------------------------------------------------------------------*
*&  Include           ZOTCE0422B_BPLAN_HORIZON_SUB
*&---------------------------------------------------------------------*
***********************************************************************************
* PROGRAM    :  ZOTCE0422B_BILLINGPLAN_HORIZON                                    *
* TITLE      :  Wrapper to feed sales orders/billing plans to standard SAP program*
* DEVELOPER  :  Amlan J Mohapatra                                                 *
* OBJECT TYPE:  REPORT                                                            *
* SAP RELEASE:  SAP ECC 6.0                                                       *
*---------------------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0422_BILLING_PLAN_HORIZON_WRAPPER_for_V.07             *
*---------------------------------------------------------------------------------*
* DESCRIPTION: This report is a wrapper program for Transaction V.07 for reducing *
*              the credit exposure up to the next 'billing due date'              *
*---------------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                           *
*=================================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                                     *
* =========== =======  ========== ================================================*
* 22-Oct-2018 AMOHAPA  E1DK939308 SCTASK0750474:INITIAL DEVELOPMENT FOR R5 RELEASE*
*&--------------------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_FPLA
*&---------------------------------------------------------------------*
*       Selection from Billing Plan
*----------------------------------------------------------------------*
*      <--FP_I_FPLA  Billing Plan Table
*----------------------------------------------------------------------*
FORM f_get_data_fpla  CHANGING fp_i_fpla TYPE ty_t_fpla.


  SELECT   fplnr     " Billing plan number / invoicing plan number
           fpart     " Billing/Invoicing Plan Type
           endat     " End date billing plan/invoice plan
           vbeln     " Sales and Distribution Document Number
           FROM fpla " Billing Plan
           INTO TABLE fp_i_fpla
           WHERE fpart IN s_fpart
           AND   endat GE p_endat.
  IF sy-subrc IS INITIAL.
    IF s_fplnr[] IS NOT INITIAL.
      DELETE fp_i_fpla WHERE fplnr NOT IN s_fplnr.
    ENDIF. " IF s_fplnr IS NOT INITIAL
    IF s_vbeln[] IS NOT INITIAL.
      DELETE fp_i_fpla WHERE vbeln NOT IN s_vbeln.
    ENDIF. " IF s_vbeln IS NOT INITIAL
  ENDIF. " IF sy-subrc IS INITIAL
  IF fp_i_fpla IS INITIAL.
    MESSAGE i138.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF fp_i_fpla IS INITIAL
ENDFORM. "f_get_data_fpla
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_BILLING_PLAN_TYPE
*&---------------------------------------------------------------------*
*       Validating Billig Plan Type
*----------------------------------------------------------------------*

FORM f_validate_billing_plan_type .

  DATA: lv_fpart TYPE fpart. " Billing/Invoicing Plan Type

  SELECT fpart      " Billing/Invoicing Plan Type
         FROM tfpla " Billing Plan Type
         INTO lv_fpart
         UP TO 1 ROWS
         WHERE fpart IN s_fpart.
  ENDSELECT.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE e000 WITH 'Incorrect Billing Plan Type'(002).
  ENDIF. " IF sy-subrc IS NOT INITIAL

  CLEAR lv_fpart.

ENDFORM. "f_validate_billing_plan_type
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SALES_DOC
*&---------------------------------------------------------------------*
*       Validating sales document
*----------------------------------------------------------------------*
FORM f_validate_sales_doc .

  DATA: lv_vbeln TYPE vbeln. " Sales and Distribution Document Number

  SELECT vbeln     " Sales and Distribution Document Number
         FROM vbak " Sales Document: Header Status and Administrative Data
         INTO lv_vbeln
         UP TO 1 ROWS
         WHERE vbeln IN s_vbeln.
  ENDSELECT.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE e000 WITH 'Incorrect Sales Document Number'(003).
  ENDIF. " IF sy-subrc IS NOT INITIAL
  CLEAR lv_vbeln.
ENDFORM. "f_validate_sales_doc
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_FIELDCAT
*&---------------------------------------------------------------------*
*       Populating the fieldcatalog
*----------------------------------------------------------------------*
*      <--FP_I_FIELDCAT[]  internal table for field catalog
*----------------------------------------------------------------------*
FORM f_prepare_fieldcat  CHANGING fp_i_fieldcat TYPE slis_t_fieldcat_alv.

  PERFORM f_populate_fieldcat USING:
        'VBELN'  'I_LOG' 'Sales Document Number'(004) CHANGING fp_i_fieldcat,
        'TEXT'   'I_LOG' 'Status'(005)                CHANGING fp_i_fieldcat,
        'VKORG'  'I_LOG' 'Sales Organization'(016)    CHANGING fp_i_fieldcat,
        'AUART'  'I_LOG' 'Sales Document Type'(017)   CHANGING fp_i_fieldcat.
ENDFORM. "f_prepare_fieldcat
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_FIELDCAT
*&---------------------------------------------------------------------*
*       Populating the Field Catalog
*----------------------------------------------------------------------*
*      -->FP_FNAM     Fieldname
*      -->FP_ITAB     Table name
*      -->FP_DESCR    Description of the field
*      <--FP_I_FIELDCAT  Final Field catalog
*----------------------------------------------------------------------*
FORM f_populate_fieldcat  USING    fp_fnam       TYPE slis_fieldname       "fieldname
                                   fp_itab       TYPE slis_tabname         "table name
                                   fp_descr      TYPE scrtext_l            "field description
                          CHANGING fp_i_fieldcat TYPE slis_t_fieldcat_alv. "Internal Table for Field Catalog

  DATA  lwa_fcat TYPE slis_fieldcat_alv. "work area for fieldcatalog

  STATICS lv_fpos TYPE sycucol. " Horizontal Cursor Position at PAI

  CLEAR lwa_fcat.
  lv_fpos = lv_fpos + 1.

  lwa_fcat-col_pos       = lv_fpos.
  lwa_fcat-fieldname     = fp_fnam.
  lwa_fcat-tabname       = fp_itab.
  lwa_fcat-seltext_l     = fp_descr.

  APPEND lwa_fcat TO fp_i_fieldcat. "fp_i_fieldcat.
  CLEAR lwa_fcat.

ENDFORM. " F_POPULATE_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*       Populating the final output in ALV
*----------------------------------------------------------------------*
*      -->FP_I_FIELDCAT[]  text
*      -->FP_I_LOG[]  text
*----------------------------------------------------------------------*
FORM f_display_alv  USING    fp_i_fieldcat TYPE slis_t_fieldcat_alv
                             fp_i_log      TYPE ty_t_log.

  PERFORM f_top_header.

  DATA: lwa_layo   TYPE slis_layout_alv. "work area

  CONSTANTS: lc_a        TYPE char1 VALUE 'A',                     " local constant A
             lc_top_page TYPE slis_formname VALUE 'F_TOP_OF_PAGE'. " top of page

  lwa_layo-colwidth_optimize = abap_true.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = sy-repid
      i_callback_top_of_page = lc_top_page
      is_layout              = lwa_layo
      it_fieldcat            = fp_i_fieldcat
      i_save                 = lc_a
    TABLES
      t_outtab               = fp_i_log
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc <> 0
ENDFORM. "f_display_alv
*&---------------------------------------------------------------------*
*&      Form  F_TOP_HEADER
*&---------------------------------------------------------------------*
*       Populating the header of the ALV output
*----------------------------------------------------------------------*
FORM f_top_header .

  CONSTANTS: lc_typ_h TYPE char1 VALUE 'H', "H
             lc_typ_s TYPE char1 VALUE 'S'. "S

  TYPES: lty_t_bapiret TYPE STANDARD TABLE OF bapiret2. "Bapi Returb Tab Type

* Local data declaration
  DATA: lv_date        TYPE char10,          "date variable
        lv_time        TYPE char10,          "time variable
        lv_lines       TYPE i,               "records count of final table
        lwa_address     TYPE bapiaddr3,      "User Address Data
        lwa_listheader TYPE slis_listheader, "list header
        li_return      TYPE lty_t_bapiret.   "return table

  CONSTANTS: lc_colon TYPE char1 VALUE ':', "Colon
             lc_slash TYPE char1 VALUE '/'. "Slash

  lwa_listheader-typ  = lc_typ_h.
  lwa_listheader-key  = 'Report'(006).
  lwa_listheader-info =
  'Wrapper to feed Sales Orders in V.07'(007).
  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.

  lwa_listheader-typ  = lc_typ_s.
  lwa_listheader-key  = 'User Name'(008).

* Get user details
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    IMPORTING
      address  = lwa_address
    TABLES
      return   = li_return.

  IF lwa_address-fullname IS NOT INITIAL.
    MOVE lwa_address-fullname TO lwa_listheader-info.
  ELSE. " ELSE -> IF lwa_address-fullname IS NOT INITIAL
    MOVE sy-uname TO lwa_listheader-info.
  ENDIF. " IF lwa_address-fullname IS NOT INITIAL

  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.

  lwa_listheader-typ = lc_typ_s.
  lwa_listheader-key = 'Date and Time'(009).

  CONCATENATE sy-uzeit+0(2)
              sy-uzeit+2(2)
              sy-uzeit+4(2)
         INTO lv_time
         SEPARATED BY lc_colon. "':'.

  CONCATENATE sy-datum+4(2)
              sy-datum+6(2)
              sy-datum+0(4)
         INTO lv_date
         SEPARATED BY lc_slash. "'/'.

  CONCATENATE lv_date
              lv_time
         INTO lwa_listheader-info
         SEPARATED BY space.
  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.

  DESCRIBE TABLE i_log[] LINES lv_lines.

  lwa_listheader-typ  = lc_typ_s.
  lwa_listheader-key  = 'Total Records'(010).
  MOVE lv_lines TO lwa_listheader-info.
  APPEND lwa_listheader TO i_listheader.
ENDFORM. "f_top_header
*&---------------------------------------------------------------------*
*&      Form  sub_top_of_page
*&---------------------------------------------------------------------*
*      Subroutine is used to call TOP OF PAGE event dynamically
*----------------------------------------------------------------------*
FORM f_top_of_page. "#EC CALLED
* Subroutine for top of page
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = i_listheader.

ENDFORM. "f_top_of_page
*&---------------------------------------------------------------------*
*&      Form  F_SEND_LOG_TO_EMAIL
*&---------------------------------------------------------------------*
*       Sending log to given mail id
*----------------------------------------------------------------------*
*      -->FP_I_LOG  Final log table
*----------------------------------------------------------------------*
FORM f_send_log_to_email  USING    fp_i_log TYPE ty_t_log.

                                "Local Structure Declaration
  TYPES:   BEGIN OF lty_email,
             vbeln TYPE char10, " Vbeln of type CHAR10
             text  TYPE char73, " Text of type CHAR73
             vkorg TYPE char4,  " Vkorg of type CHAR4
             auart TYPE char4,  " Auart of type CHAR4
           END OF lty_email.
******//Local Constant Declaration.
  CONSTANTS: lc_tab    TYPE char1      VALUE cl_abap_char_utilities=>horizontal_tab, "Constant for Excel data
             lc_ret    TYPE char1      VALUE cl_abap_char_utilities=>cr_lf,          "Constant for Excel data
             lc_and    TYPE char1      VALUE '&',                                    " And of type CHAR1
             lc_dash   TYPE char1      VALUE '-',                                    " Dash of type CHAR1
             lc_sign   TYPE char3      VALUE 'RAW',                                  "RAW
             lc_exe    TYPE char5      VALUE 'EXCEL',                                "Excel
             lc_fmat   TYPE char3      VALUE 'XLS',                                  "Excel Format
             lc_xsx    TYPE char16     VALUE 'EXCEL ATTACHMENT',                     "Attachment
             lc_let    TYPE char3      VALUE '255',                                  "Constant for literal
             lc_you    TYPE char1      VALUE 'U',                                    "Constant for email address
             lc_s      TYPE char1      VALUE 'S'.                                    " I of type CHAR1
*****//Local Data Declaration.
  DATA : lv_lines_bin     TYPE sytabix,    "no of lines for excel data
         lv_message_lines TYPE sytabix,    "no of lines for body of mail
         lv_mailaddr      TYPE so_recname, "storing email id
*****//Local Internal Table Declaration.
         li_objpack       TYPE STANDARD TABLE OF  sopcklsti1    INITIAL SIZE 0, "Local ITAB
         li_message       TYPE STANDARD TABLE OF  solisti1      INITIAL SIZE 0, "Local ITAB
         li_reclist       TYPE STANDARD TABLE OF  somlreci1     INITIAL SIZE 0, "Local ITAB
         li_objbin        TYPE STANDARD TABLE OF  solisti1      INITIAL SIZE 0, "Local ITAB
*****//Local Workarea Declaration.
         lwa_objbin       TYPE  solisti1,    "work area for objbin
         lwa_it_reclist   TYPE  somlreci1,   "work area it_reclist
         lwa_doc_chng      TYPE  sodocchgi1, "Structure for Excel data
         lwa_it_objpack   TYPE  sopcklsti1,  "Structure for Excel data
         lwa_email        TYPE  lty_email.

*****//Local Field-Symbol Declaration.
  FIELD-SYMBOLS:
           <lfs_log>         TYPE ty_log. " Structure final table
*****//document information
  lwa_doc_chng-obj_name   = lc_exe. "Excel
  lwa_doc_chng-obj_descr  = 'Billing plan wrapper logs'(012).
  CONCATENATE lwa_doc_chng-obj_descr lc_dash sy-datum lc_and sy-uzeit INTO lwa_doc_chng-obj_descr.

*****//Displaying Header in the excel
  CONCATENATE 'Sales Document Number'(004)
              'Status'(005)
              'Sales Organization'(016)
              'Sales Document Type'(017)
              INTO lwa_objbin SEPARATED BY lc_tab.
  CONCATENATE lc_ret lwa_objbin INTO lwa_objbin.
  APPEND lwa_objbin TO li_objbin.

  LOOP AT fp_i_log ASSIGNING <lfs_log>.

    lwa_email-vbeln = <lfs_log>-vbeln.
    lwa_email-text  = <lfs_log>-text.
    lwa_email-vkorg = <lfs_log>-vkorg.
    lwa_email-auart = <lfs_log>-auart.

    CONCATENATE  lwa_email-vbeln
                 lwa_email-text
                 lwa_email-vkorg
                 lwa_email-auart
                 INTO lwa_objbin SEPARATED BY lc_tab.
    CONCATENATE lc_ret lwa_objbin INTO lwa_objbin.
    APPEND lwa_objbin TO li_objbin.
    CLEAR lwa_objbin.
  ENDLOOP. " LOOP AT fp_i_log ASSIGNING <lfs_log>

  IF <lfs_log> IS ASSIGNED.
    UNASSIGN <lfs_log>.
  ENDIF. " IF <lfs_log> IS ASSIGNED


  DESCRIBE TABLE li_objbin LINES lv_lines_bin. " no of lines for excel data

  CLEAR lwa_it_objpack. "Obj. to be transported not in binary form
  CLEAR li_objpack.
  REFRESH li_objpack.
  lwa_it_objpack-transf_bin = space.
  lwa_it_objpack-head_start = 1. "Start line of object header in transport packet
  lwa_it_objpack-head_num   = 0. "Number of lines of an object header in object packet
  lwa_it_objpack-body_start = 1. "Start line of object contents in an object packet
  lwa_it_objpack-body_num   = lv_message_lines. "Number of lines of the mail body
  lwa_it_objpack-doc_type   = lc_sign. "RAW
  APPEND lwa_it_objpack TO li_objpack.
  CLEAR lwa_it_objpack.
                                         " pack the data as excel
  lwa_it_objpack-transf_bin = abap_true. " Should be X
  lwa_it_objpack-head_start = 1.
  lwa_it_objpack-head_num = 0.
  lwa_it_objpack-body_start = 1.
  lwa_it_objpack-body_num = lv_lines_bin. "no of lines of mail body
  lwa_it_objpack-doc_type = lc_fmat. "XLS ->  excel fomat
  lwa_it_objpack-obj_name = lc_xsx. "EXCEL ATTACHMENT

*****//Attachment Name
  CONCATENATE 'Billing plan wrapper logs'(012)'.xls'(013) INTO lwa_it_objpack-obj_descr.
  lwa_it_objpack-doc_size = lv_lines_bin * lc_let.
  APPEND lwa_it_objpack TO li_objpack.

*****//Add the recipients email address.

  lv_mailaddr = p_email.

  CLEAR lwa_it_reclist.
  lwa_it_reclist-receiver   = lv_mailaddr.
  lwa_it_reclist-express    = abap_true. "X
  lwa_it_reclist-rec_type   = lc_you. "U ->  Internet address
  APPEND lwa_it_reclist TO li_reclist.

*****//Clearing
  CLEAR: lv_mailaddr,
         lwa_it_reclist.

  IF li_reclist IS NOT INITIAL.
    SORT li_reclist BY receiver.
    DELETE ADJACENT DUPLICATES FROM li_reclist COMPARING receiver.
  ENDIF. " IF li_reclist IS NOT INITIAL

*****//For Sending Mail
  IF lwa_doc_chng IS NOT INITIAL AND li_objpack IS NOT INITIAL.

    CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
      EXPORTING
        document_data              = lwa_doc_chng
        put_in_outbox              = abap_true
        commit_work                = abap_true
      TABLES
        packing_list               = li_objpack
        contents_txt               = li_message
        contents_bin               = li_objbin
        receivers                  = li_reclist
      EXCEPTIONS
        too_many_receivers         = 1
        document_not_sent          = 2
        document_type_not_exist    = 3
        operation_no_authorization = 4
        parameter_error            = 5
        x_error                    = 6
        enqueue_error              = 7
        OTHERS                     = 8.

    IF sy-subrc <> 0.
      MESSAGE 'Mail sending Failed'(014) TYPE lc_s.
    ELSE. " ELSE -> IF sy-subrc <> 0
      MESSAGE 'Mail Sent Successfully'(015) TYPE lc_s.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF lwa_doc_chng IS NOT INITIAL AND li_objpack IS NOT INITIAL
***//Clear work area.
  CLEAR: lwa_doc_chng,
         lv_message_lines,
         lv_lines_bin.
*         lwa_address.
***//Free Internal tables.
  FREE:  li_objpack[],
         li_message[],
         li_objbin[],
         li_reclist[].

ENDFORM. "f_send_log_to_email
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_EMAIL
*&---------------------------------------------------------------------*
*       Validating EMAIL id
*----------------------------------------------------------------------*
FORM f_validate_email.

  TRANSLATE p_email TO UPPER CASE.

  IF NOT p_email CS  '@BIO-RAD.COM'.
    MESSAGE 'Please enter the valid emailid'(011) TYPE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF NOT p_email CS '@BIO-RAD COM'


ENDFORM. "f_validate_email
*&---------------------------------------------------------------------*
*&      Form  F_GET_VBAK
*&---------------------------------------------------------------------*
*       Getting records from VBAK
*----------------------------------------------------------------------*
*      <--FP_I_LOG  Internal table for LOG
*----------------------------------------------------------------------*
FORM f_get_vbak  CHANGING fp_i_log TYPE ty_t_log.

                              "Data declaration

  TYPES: BEGIN OF lty_vbak,
         vbeln TYPE vbeln_va, " Sales Document
         auart TYPE auart,    " Sales Document Type
         vkorg TYPE vkorg,    " Sales Organization
         END OF lty_vbak.

  DATA: li_vbak TYPE STANDARD TABLE OF lty_vbak INITIAL SIZE 0, "local internal table
        lwa_vbak TYPE lty_vbak.                                 "local workarea

  FIELD-SYMBOLS: <lfs_log> TYPE ty_log. "local field symbol

  SELECT vbeln     " Sales Document
         auart     " Sales Document Type
         vkorg     " Sales Organization
         FROM vbak " Sales Document: Header Data
         INTO TABLE li_vbak
         FOR ALL ENTRIES IN fp_i_log
         WHERE vbeln = fp_i_log-vbeln.
  IF sy-subrc IS INITIAL.
    SORT li_vbak BY vbeln.
    LOOP AT fp_i_log ASSIGNING <lfs_log>.
      READ TABLE li_vbak INTO lwa_vbak WITH KEY vbeln = <lfs_log>-vbeln
                                       BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        <lfs_log>-vkorg = lwa_vbak-vkorg.
        <lfs_log>-auart = lwa_vbak-auart.
      ENDIF. " IF sy-subrc IS INITIAL
      CLEAR lwa_vbak.
    ENDLOOP. " LOOP AT fp_i_log ASSIGNING <lfs_log>
    IF <lfs_log> IS ASSIGNED.
      UNASSIGN <lfs_log>.
    ENDIF. " IF <lfs_log> IS ASSIGNED
  ENDIF. " IF sy-subrc IS INITIAL
ENDFORM. " F_GET_VBAK
*&---------------------------------------------------------------------*
*&      Form  F_GET_FINAL
*&---------------------------------------------------------------------*
*       Processing the sales document from V.07 logic
*----------------------------------------------------------------------*
*      -->FP_I_FPLA  Internal Table for FPLA
*      <--FP_I_LOG   Final Internal Table
*----------------------------------------------------------------------*
FORM f_get_final  USING    fp_i_fpla TYPE ty_t_fpla
                  CHANGING fp_i_log  TYPE ty_t_log.

  TYPES: BEGIN OF lty_news,
             vbeln TYPE vbeln,   "Sales and Distribution Document Number
             kunnr TYPE kunnr,   " Customer Number
             msgty TYPE symsgty, " Message Type
             text  TYPE char70,  " Text of type CHAR70
         END OF lty_news.
  DATA: lwa_fpla TYPE ty_fpla,                                   "Local workarea
        lwa_log  TYPE ty_log,                                    "Local workarea
        lwa_news TYPE lty_news,                                  "Local workarea
        li_news  TYPE STANDARD TABLE OF lty_news INITIAL SIZE 0. "Local internal table
  CONSTANTS:  lc_true    TYPE char1 VALUE 'X',   "Local constant
              lc_space   TYPE char1 VALUE ' ',   "Local constant
              lc_msgid   TYPE char2 VALUE 'V1',  "Local constant
              lc_msgnr   TYPE char3 VALUE '311'. "Local constant
  LOOP AT fp_i_fpla INTO lwa_fpla.
 "Copied from standard program RVFPLA01,
 "As we are facing problem while displaying our custom ALV output
    CALL FUNCTION 'SD_SALES_DOCUMENT_INIT'
      EXPORTING
        status_buffer_refresh = lc_true
        keep_lock_entries     = lc_space
        simulation_mode_bapi  = lc_space.

    CALL FUNCTION 'SD_ORDER_BILLING_SCHEDULE'
      EXPORTING
        i_vbeln                    = lwa_fpla-vbeln
        i_beleg_lesen              = lc_true
        i_commit                   = lc_space
        i_termine_bis_zum_horizont = lc_true
      EXCEPTIONS
        error_message              = 01.

    IF sy-subrc NE 0.
      lwa_news-msgty = sy-msgty.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = sy-msgid
          msgnr               = sy-msgno
          msgv1               = sy-msgv1
          msgv2               = sy-msgv2
        IMPORTING
          message_text_output = lwa_news-text.
      lwa_news-vbeln   = lwa_fpla-vbeln.
      APPEND lwa_news TO li_news.
      CLEAR lwa_news.
    ELSE. " ELSE -> IF sy-subrc NE 0
      COMMIT WORK AND WAIT.
      lwa_news-msgty = sy-msgty.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = lc_msgid
          msgnr               = lc_msgnr
          msgv1               = text-018
          msgv2               = lwa_fpla-vbeln
        IMPORTING
          message_text_output = lwa_news-text.
      lwa_news-vbeln   = lwa_fpla-vbeln.
      APPEND lwa_news TO li_news.
      CLEAR lwa_news.
    ENDIF. " IF sy-subrc NE 0
    CLEAR lwa_fpla.
  ENDLOOP. " LOOP AT fp_i_fpla INTO lwa_fpla

  IF li_news IS NOT INITIAL.
    LOOP AT li_news INTO lwa_news.
      lwa_log-vbeln = lwa_news-vbeln.
      lwa_log-text  = lwa_news-text.
      APPEND lwa_log TO fp_i_log.
      CLEAR:lwa_log,
            lwa_news.
    ENDLOOP. " LOOP AT li_news INTO lwa_news
  ENDIF. " IF li_news IS NOT INITIAL

  IF fp_i_log IS NOT INITIAL.
    SORT fp_i_log BY vbeln.
    DELETE ADJACENT DUPLICATES FROM fp_i_log COMPARING vbeln.
  ENDIF. " IF fp_i_log IS NOT INITIAL

ENDFORM. " F_GET_FINAL
*&---------------------------------------------------------------------*
*&      Form  F_GET_BPLAN_BEFORE
*&---------------------------------------------------------------------*
*       getting FPLT entries before updating
*----------------------------------------------------------------------*
*      <--FP_I_FPLT_BEFORE  internal table for FPLT
*----------------------------------------------------------------------*
FORM f_get_bplan_before   USING    fp_i_fpla        TYPE ty_t_fpla
                          CHANGING fp_i_fplt_before TYPE ty_t_fplt.


  FIELD-SYMBOLS: <lfs_fplt> TYPE ty_fplt. "Local field symbol

  DATA: lv_counter TYPE int4. " Count of type Integers
  IF fp_i_fpla IS NOT INITIAL.
    SELECT fplnr     " Billing plan number / invoicing plan number
           fpltr     " Item for billing plan/invoice plan/payment cards
           FROM fplt " Billing Plan: Dates
           INTO TABLE fp_i_fplt_before
           FOR ALL ENTRIES IN fp_i_fpla
           WHERE fplnr = fp_i_fpla-fplnr.
    IF sy-subrc IS INITIAL.
      SORT fp_i_fplt_before BY fplnr fpltr.
      LOOP AT fp_i_fplt_before ASSIGNING <lfs_fplt>.
        lv_counter = lv_counter + 1.
        AT END OF fplnr.
          <lfs_fplt>-count = lv_counter.
          CLEAR lv_counter.
        ENDAT.
      ENDLOOP. " LOOP AT fp_i_fplt_before ASSIGNING <lfs_fplt>
      IF <lfs_fplt> IS ASSIGNED.
        UNASSIGN <lfs_fplt>.
      ENDIF. " IF <lfs_fplt> IS ASSIGNED
      IF fp_i_fplt_before IS NOT INITIAL.
        DELETE fp_i_fplt_before WHERE count IS INITIAL.
        SORT fp_i_fplt_before BY fplnr.
      ENDIF. " IF fp_i_fplt_before IS NOT INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF fp_i_fpla IS NOT INITIAL
ENDFORM. " F_GET_BPLAN_BEFORE
*&---------------------------------------------------------------------*
*&      Form  F_GET_BPLAN_AFTER
*&---------------------------------------------------------------------*
*       Getting FPLT entries after updating
*----------------------------------------------------------------------*
*      -->FP_I_FPLT_BEFORE  internal table for FPLT
*      <--FP_I_FPLT_AFTER   internal table for FPLT
*----------------------------------------------------------------------*
FORM f_get_bplan_after  USING    fp_i_fplt_before TYPE ty_t_fplt
                        CHANGING fp_i_fplt_after  TYPE ty_t_fplt.

  FIELD-SYMBOLS: <lfs_fplt> TYPE ty_fplt. "local field symbol

  DATA: lv_counter TYPE i,       " Count of type Integers
        lwa_fplt   TYPE ty_fplt. "local workarea
  IF fp_i_fplt_before IS NOT INITIAL.
    SELECT fplnr     " Billing plan number / invoicing plan number
           fpltr     " Item for billing plan/invoice plan/payment cards
           FROM fplt " Billing Plan: Dates
           INTO TABLE fp_i_fplt_after
           FOR ALL ENTRIES IN fp_i_fplt_before
           WHERE fplnr = fp_i_fplt_before-fplnr.
    IF sy-subrc IS INITIAL.
      SORT fp_i_fplt_after BY fplnr fpltr.
      LOOP AT fp_i_fplt_after ASSIGNING <lfs_fplt>.
        lv_counter = lv_counter + 1.
        AT END OF fplnr.
          <lfs_fplt>-count = lv_counter.
 "Reading the Fplt_before table to check whether update is done in the billing plan or not
          READ TABLE fp_i_fplt_before INTO lwa_fplt WITH KEY fplnr = <lfs_fplt>-fplnr
                                                    BINARY SEARCH.
          IF sy-subrc IS  INITIAL.
            IF lwa_fplt-count LT lv_counter.
              <lfs_fplt>-update = abap_true.
            ENDIF. " IF lwa_fplt-count LT lv_counter
          ENDIF. " IF sy-subrc IS INITIAL
          CLEAR: lv_counter,
                 lwa_fplt.
        ENDAT.
      ENDLOOP. " LOOP AT fp_i_fplt_after ASSIGNING <lfs_fplt>
      IF <lfs_fplt> IS ASSIGNED.
        UNASSIGN <lfs_fplt>.
      ENDIF. " IF <lfs_fplt> IS ASSIGNED
      IF fp_i_fplt_after IS NOT INITIAL.
        DELETE fp_i_fplt_after WHERE count IS INITIAL.
      ENDIF. " IF fp_i_fplt_after IS NOT INITIAL
      IF fp_i_fplt_after IS NOT INITIAL.
        SORT fp_i_fplt_after BY fplnr.
      ENDIF. " IF fp_i_fplt_after IS NOT INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF fp_i_fplt_before IS NOT INITIAL
ENDFORM. " F_GET_BPLAN_AFTER
*&---------------------------------------------------------------------*
*&      Form  F_GET_CHANGE_LOG
*&---------------------------------------------------------------------*
*       chaning the logs by checking FPLT entries
*----------------------------------------------------------------------*
*      -->FP_I_FPLT_AFTER   internal table for FPLT
*      <--FP_I_FPLA         internal table for FPLA
*      <--FP_I_LOG          final internal table
*----------------------------------------------------------------------*
FORM f_get_change_log  USING    fp_i_fplt_after TYPE ty_t_fplt
                       CHANGING fp_i_log        TYPE ty_t_log
                                fp_i_fpla       TYPE ty_t_fpla.

  DATA: lv_index     TYPE sytabix,                              " Index of Internal Tables
        lwa_fplt     TYPE ty_fplt,                              "local workarea
        lwa_fpla     TYPE ty_fpla,                              "local workarea
        lwa_fpla_tmp TYPE ty_fpla,                              "local workarea
        li_fpla  TYPE STANDARD TABLE OF ty_fpla INITIAL SIZE 0. "local internal table

  FIELD-SYMBOLS: <lfs_log> TYPE ty_log. "local field symbol
  SORT fp_i_fpla BY vbeln.
  li_fpla[] = fp_i_fpla[].

  LOOP AT fp_i_log ASSIGNING <lfs_log>.
    READ TABLE fp_i_fpla INTO lwa_fpla WITH KEY vbeln = <lfs_log>-vbeln
                                       BINARY SEARCH.


 "As One sales order can have multiple Billing plan numbers
 "So to access all the Billing plan we are applying Parralel cursor logic on this
    IF sy-subrc IS INITIAL.
 "Taking the index in local variable
      lv_index = sy-tabix.

      LOOP AT li_fpla INTO lwa_fpla_tmp FROM lv_index.

        IF lwa_fpla-vbeln NE lwa_fpla_tmp-vbeln.
          EXIT.
        ENDIF. " IF lwa_fpla-vbeln NE lwa_fpla_tmp-vbeln

        READ TABLE fp_i_fplt_after INTO lwa_fplt WITH KEY fplnr = lwa_fpla_tmp-fplnr
                                                 BINARY SEARCH.

        IF sy-subrc IS INITIAL.
          IF lwa_fplt-update IS NOT INITIAL.
            <lfs_log>-text = 'Billing plan has been updated'(019).
            EXIT.
          ELSE. " ELSE -> IF lwa_fplt-update IS NOT INITIAL
            <lfs_log>-text = 'Billing plan has not been updated'(020).
          ENDIF. " IF lwa_fplt-update IS NOT INITIAL
        ENDIF. " IF sy-subrc IS INITIAL
      ENDLOOP. " LOOP AT li_fpla INTO lwa_fpla_tmp FROM lv_index
    ENDIF. " IF sy-subrc IS INITIAL
    CLEAR: lwa_fplt,
           lwa_fpla,
           lwa_fpla_tmp.
    CLEAR: lv_index.
  ENDLOOP. " LOOP AT fp_i_log ASSIGNING <lfs_log>

  IF <lfs_log> IS ASSIGNED.
    UNASSIGN <lfs_log>.
  ENDIF. " IF <lfs_log> IS ASSIGNED

ENDFORM. " F_GET_CHANGE_LOG
*&---------------------------------------------------------------------*
*&      Form  F_F4_FPART
*&---------------------------------------------------------------------*
*       F4 help for billing type
*----------------------------------------------------------------------*

FORM f_f4_fpart.
                           "local structure for Billing Type
  TYPES: BEGIN OF lty_fpart,
         fpart TYPE fpart, " Billing/Invoicing Plan Type
         fpbez TYPE fpbez, " Description of Billing/Invoicing Plan Type
         END OF lty_fpart.

  DATA: li_fpart TYPE STANDARD TABLE OF lty_fpart INITIAL SIZE 0. "Local internal table

  CONSTANTS: lc_fpart    TYPE fieldname VALUE 'FPART',   " Field Name
             lc_dynfield TYPE dynfnam   VALUE 'S_FPART', " Field name
             lc_pvalkey  TYPE ddshpvkey VALUE ' ',       " Key for personal help
             lc_org      TYPE ddbool_d  VALUE 'S'.       " DD: truth value

  SELECT a~fpart " Billing/Invoicing Plan Type
         b~fpbez " Description of Billing/Invoicing Plan Type
         INTO TABLE li_fpart
         FROM tfpla AS a INNER JOIN tfplb AS b ON a~fpart EQ b~fpart
                         WHERE spras EQ sy-langu.
  IF sy-subrc IS INITIAL.
 "Sort the internal table before displaying
    SORT li_fpart BY fpart.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = lc_fpart
        pvalkey         = lc_pvalkey
        dynpprog        = sy-repid
        dynpnr          = sy-dynnr
        dynprofield     = lc_dynfield
        value_org       = lc_org
      TABLES
        value_tab       = li_fpart
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.

  ENDIF. " IF sy-subrc IS INITIAL
ENDFORM. " F_F4_FPART
