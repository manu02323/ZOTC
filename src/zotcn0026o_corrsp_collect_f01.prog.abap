*&---------------------------------------------------------------------*
*&  Include           ZOTCN0026O_CORRSP_COLLECT_F01
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0026O_CORRSP_COLLECT_F01                          *
* TITLE      :  ZOTCR0026O - Customer Master & Corresp Collect Account *
*               Report                                                 *
* DEVELOPER  :  Gautam NAG                                             *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0026                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: This report shows tte list of customer master data with
*              the collect number details. The collect numbers are
*              stored in the Sales Text and the same is read and
*              displayed against the customer master
*              This include contains all the subroutines for the report
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 22-JUL-2013 GNAG     E1DK911035 INITIAL DEVELOPMENT
* 06-AUG-2013 BMAJI    E1DK911035 DEFECT#53 : Add F4 for Language &
*                                 Text Object
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Macro  TOP_OF_PAGE_SEL
*&---------------------------------------------------------------------*
*       Macro to populate the top-of-page data fields
*----------------------------------------------------------------------*
DEFINE top_of_page_sel.

  lwa_top_of_page-typ = lc_typ_s.
  lwa_top_of_page-key = &1.
  lwa_top_of_page-info = &2.
  append lwa_top_of_page to &3.
  clear lwa_top_of_page.

END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_CUSTOMER
*&---------------------------------------------------------------------*
*       Validate the Customer number
*----------------------------------------------------------------------*
FORM f_validate_customer.

* Validate the Customer number and give proper error
  DATA: lv_kunnr TYPE kunnr.

  SELECT kunnr UP TO 1 ROWS
    FROM kna1
    INTO lv_kunnr
   WHERE kunnr IN s_kunnr.
  ENDSELECT.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE e000 WITH 'Invalid Customer number'(e01).
  ENDIF.

ENDFORM.                    " F_VALIDATE_CUSTOMER

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_KTOKD
*&---------------------------------------------------------------------*
*       Validate the Customer Account group
*----------------------------------------------------------------------*
FORM f_validate_ktokd.

* Validate the Customer Account group and give proper error
  DATA: lv_ktokd TYPE ktokd.

  SELECT SINGLE ktokd
    FROM t077d
    INTO lv_ktokd
   WHERE ktokd = p_ktokd.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE e000 WITH 'Invalid Customer Account group'(e02).
  ENDIF.

ENDFORM.                    " F_VALIDATE_KTOKD

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_VKORG
*&---------------------------------------------------------------------*
*       Validate the Sales Organization
*----------------------------------------------------------------------*
FORM f_validate_vkorg.

* Validate the Sales Organization and give proper error
  DATA: lv_vkorg TYPE vkorg.

  SELECT SINGLE vkorg
    FROM tvko
    INTO lv_vkorg
   WHERE vkorg = p_vkorg.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE e000 WITH 'Invalid Sales Organization'(e03).
  ENDIF.

ENDFORM.                    " F_VALIDATE_VKORG

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_VTWEG
*&---------------------------------------------------------------------*
*       Validate the Distribution channel
*----------------------------------------------------------------------*
FORM f_validate_vtweg.

* Validate the Distribution channel and give proper error
  DATA: lv_vtweg TYPE vtweg.

  SELECT SINGLE vtweg
    FROM tvtw
    INTO lv_vtweg
   WHERE vtweg = p_vtweg.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE e000 WITH 'Invalid Distribution channel'(e04).
  ENDIF.

ENDFORM.                    " F_VALIDATE_VTWEG

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SPART
*&---------------------------------------------------------------------*
*       Validate the Division
*----------------------------------------------------------------------*
FORM f_validate_spart.

* Validate the Division and give proper error
  DATA: lv_spart TYPE spart.

  SELECT SINGLE spart
    FROM tspa
    INTO lv_spart
   WHERE spart = p_spart.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE e000 WITH 'Invalid Division'(e05).
  ENDIF.

ENDFORM.                    " F_VALIDATE_SPART

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_TDID
*&---------------------------------------------------------------------*
*       Validate the Text ID
*----------------------------------------------------------------------*
FORM f_validate_tdid .

* Validate the Text ID and give proper error
  DATA: lv_tdid TYPE tdid.

  SELECT SINGLE tdid
    FROM ttxid
    INTO lv_tdid
   WHERE tdid = p_tdid.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE e000 WITH 'Invalid Text ID'(e06).
  ENDIF.

ENDFORM.                    " F_VALIDATE_TDID

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_TDOBJ
*&---------------------------------------------------------------------*
*       Validate the Text Object
*----------------------------------------------------------------------*
FORM f_validate_tdobj.

* Validate the Text ID and give proper error
  DATA: lv_tdobj TYPE tdobject.

  SELECT SINGLE tdobject
    FROM ttxob
    INTO lv_tdobj
   WHERE tdobject = p_tdobj.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE e000 WITH 'Invalid Text Object'(e07).
  ENDIF.

ENDFORM.                    " F_VALIDATE_TDOBJ

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_CUST
*&---------------------------------------------------------------------*
*       Get the customer numbers and NAME1 after applying all the
*       filtering conditions
*----------------------------------------------------------------------*
*      <-- FP_I_CUST_NAME  Customer Name1
*----------------------------------------------------------------------*
FORM f_get_data_cust CHANGING fp_i_cust_name TYPE ty_t_cust_name.

* Get the customer number and Name from KNA1 with KNVV joined to apply
* all the filtering conditions
  IF p_ktokd IS INITIAL.
    SELECT kunnr      " Customer Number
           name1      " Name 1
      FROM kna1vv
      INTO TABLE fp_i_cust_name
     WHERE kunnr IN s_kunnr
       AND vkorg = p_vkorg
       AND vtweg = p_vtweg
       AND spart = p_spart.
  ELSE.
    SELECT kunnr      " Customer Number
           name1      " Name 1
      FROM kna1vv
      INTO TABLE fp_i_cust_name
     WHERE kunnr IN s_kunnr
       AND ktokd = p_ktokd
       AND vkorg = p_vkorg
       AND vtweg = p_vtweg
       AND spart = p_spart.
  ENDIF.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE i000 WITH 'No data to display'(i01).
    LEAVE LIST-PROCESSING.
  ELSE.
    SORT fp_i_cust_name BY kunnr.
  ENDIF.

ENDFORM.                    " F_GET_DATA_CUST

*&---------------------------------------------------------------------*
*&      Form  F_GET_CUST_TEXT
*&---------------------------------------------------------------------*
*       Get the long texts for each customer and populate the final
*       internal table for display
*----------------------------------------------------------------------*
*      --> FP_I_CUST_NAME  Customer Name1
*      <-- FP_I_CUST_TEXT  Customer texts
*      <-- FP_I_FINAL      Table for the final display
*----------------------------------------------------------------------*
FORM f_get_cust_text USING    fp_i_cust_name TYPE ty_t_cust_name
                     CHANGING fp_i_cust_text TYPE ty_t_cust_text
                              fp_i_final     TYPE ty_t_final.

  DATA:
    li_xthead TYPE TABLE OF thead INITIAL SIZE 0, " Text header
    li_lines TYPE tline_t,            " Text lines
    lwa_final TYPE ty_final,          " WA for final display
    lwa_cust_text TYPE ty_cust_text.  " WA for Customer texts

  FIELD-SYMBOLS:
    <lfs_cust_name> TYPE ty_cust_name,  " Customer Name1
    <lfs_xthead> TYPE thead,            " Text header
    <lfs_lines> TYPE tline.             " Text lines

* For each customer, read the long text and put the first 35char of the
* first line in the final table. Also, keep the entire text in a
* separate int table p_i_cust_text for further use
  LOOP AT fp_i_cust_name ASSIGNING <lfs_cust_name>.

    CLEAR: li_xthead, li_lines.
*   Get the text name and other header details
    CALL FUNCTION 'KNVV_TEXT_HEADER_SELECT'
      EXPORTING
        kunnr  = <lfs_cust_name>-kunnr
        vkorg  = p_vkorg
        vtweg  = p_vtweg
        spart  = p_spart
      TABLES
        xthead = li_xthead.
    IF sy-subrc IS INITIAL.
*     Get the relevant text header details by matching the text ID, object,
*     language from the selection screen
*     ----------------------- *** ---------------------------
*  ** Here, while reading the int table li_xthead, BINARY SEARCH is used
*  ** and the table is not sorted as there will be very few (in the order
*  ** of ones) records in the table   ***
*     ----------------------- *** ---------------------------
      READ TABLE li_xthead ASSIGNING <lfs_xthead> WITH KEY tdobject = p_tdobj
                                                           tdid = p_tdid
                                                           tdspras = p_langu.
      IF sy-subrc IS INITIAL.
*       Read the entire text
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = p_tdid
            language                = p_langu
            name                    = <lfs_xthead>-tdname
            object                  = p_tdobj
          TABLES
            lines                   = li_lines
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.
        IF sy-subrc IS INITIAL.
*         If the text exists, then put the first 35char of the first line
*         in the int tab. Also populate the other fields for final table
          READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 1.
          IF sy-subrc IS INITIAL.
            lwa_final-kunnr = <lfs_cust_name>-kunnr.
            lwa_final-name1 = <lfs_cust_name>-name1.
            lwa_final-text = <lfs_lines>-tdline.
            lwa_final-icon = icon_display_text.
            APPEND lwa_final TO fp_i_final.
            CLEAR lwa_final.

*           Also, keep the entire text in a separate int tab p_i_cust_text
*           against each customer number
            lwa_cust_text-kunnr = <lfs_cust_name>-kunnr.
            lwa_cust_text-lines = li_lines.
            APPEND lwa_cust_text TO fp_i_cust_text.
            CLEAR lwa_cust_text.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF fp_i_final IS INITIAL.
    MESSAGE i000 WITH 'No data to display'(i01).
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.                    " F_GET_CUST_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_ALV_PARAM
*&---------------------------------------------------------------------*
*       Populate the ALV parameters
*----------------------------------------------------------------------*
*      <-- FP_I_FIELDCAT  Field catalogue
*      <-- FP_X_LAYOUT    Layout
*----------------------------------------------------------------------*
FORM f_prepare_alv_param CHANGING fp_i_fieldcat TYPE slis_t_fieldcat_alv
                                  fp_x_layout   TYPE slis_layout_alv.

  DATA:
    lwa_fieldcat TYPE slis_fieldcat_alv.    " Fieldcat work area

* Populate the field catalogue
  lwa_fieldcat-col_pos   = 1.
  lwa_fieldcat-fieldname = 'KUNNR'.
  lwa_fieldcat-tabname   = 'I_FINAL'.
  lwa_fieldcat-seltext_l = 'Customer Number'(c01).
  lwa_fieldcat-outputlen = 15.
  lwa_fieldcat-hotspot   = c_true.
  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.

  lwa_fieldcat-col_pos   = 2.
  lwa_fieldcat-fieldname = 'NAME1'.
  lwa_fieldcat-tabname   = 'I_FINAL'.
  lwa_fieldcat-seltext_l = 'Name of the Customer'(c02).
  lwa_fieldcat-outputlen = 35.
  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.

  lwa_fieldcat-col_pos   = 3.
  lwa_fieldcat-fieldname = 'TEXT'.
  lwa_fieldcat-tabname   = 'I_FINAL'.
  lwa_fieldcat-seltext_l = 'Text maintained'(c03).
  lwa_fieldcat-outputlen = 35.
  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.

  lwa_fieldcat-col_pos   = 4.
  lwa_fieldcat-fieldname = 'ICON'.
  lwa_fieldcat-tabname   = 'I_FINAL'.
  lwa_fieldcat-seltext_l = 'Long Text'(c04).
  lwa_fieldcat-outputlen = 10.
  lwa_fieldcat-icon      = c_true.
  lwa_fieldcat-hotspot   = c_true.
  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.

* Populate the layout
  fp_x_layout-zebra = c_true.

ENDFORM.                    " F_PREPARE_ALV_PARAM

*&---------------------------------------------------------------------*
*&      Form  F_OUTPUT_DISPLAY
*&---------------------------------------------------------------------*
*       Final output display
*----------------------------------------------------------------------*
*      --> FP_I_FINAL     Final int. table
*      --> FP_X_LAYOUT    Layout
*      --> FP_I_FIELDCAT  Field catalogue
*----------------------------------------------------------------------*
FORM f_output_display USING fp_i_final    TYPE ty_t_final
                            fp_x_layout   TYPE slis_layout_alv
                            fp_i_fieldcat TYPE slis_t_fieldcat_alv.

  CONSTANTS:
    lc_ucomm_formname TYPE slis_formname VALUE 'F_USER_COMMAND',  " User Command form
    lc_top_of_page_formname TYPE slis_formname VALUE 'F_TOP_OF_PAGE'.   " Top-of-page form

* Final display
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_user_command = lc_ucomm_formname
      i_callback_top_of_page  = lc_top_of_page_formname
      is_layout               = fp_x_layout
      it_fieldcat             = fp_i_fieldcat
    TABLES
      t_outtab                = fp_i_final
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
    MESSAGE i000 WITH 'Internal ALV error'(i02).
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.                    " F_OUTPUT_DISPLAY

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
*       User command subroutine
*----------------------------------------------------------------------*
*      --> FP_UCOMM     User Command
*      --> FP_SELFIELD  Selected line details
*----------------------------------------------------------------------*
FORM f_user_command USING fp_ucomm    TYPE sy-ucomm
                          fp_selfield TYPE slis_selfield.

  CONSTANTS:
    lc_fldname_kunnr TYPE slis_fieldname VALUE 'KUNNR', " ALV fieldname
    lc_fldname_icon  TYPE slis_fieldname VALUE 'ICON'. " ALV fieldname

  DATA: li_note  TYPE STANDARD TABLE OF txw_note, " Note with plain text
        lwa_note TYPE txw_note.                   " Note with plain text
  FIELD-SYMBOLS:
    <lfs_final> TYPE ty_final,            " Final int table
    <lfs_cust_text> TYPE ty_cust_text,    " Customer texts
    <lfs_lines> TYPE tline.               " Text lines

* When user clicks on a field value (either customer number or long text
* icon), drilldown to the required screen
  CASE fp_ucomm.
    WHEN '&IC1'.  " Double click/hotspot click
*     Read the row which is clicked
      READ TABLE i_final ASSIGNING <lfs_final> INDEX fp_selfield-tabindex.
      IF sy-subrc IS INITIAL.
*       Using the customer number of the selected row, get the long text
*       of the customer from the int table i_cust_text
        READ TABLE i_cust_text ASSIGNING <lfs_cust_text>
                               WITH KEY kunnr = <lfs_final>-kunnr.
        IF sy-subrc IS INITIAL.
*         Check which field user has clicked on. For Customer number,
*         navigate to the VD03 with that customer and Sales Area
          IF fp_selfield-fieldname = lc_fldname_kunnr.
            SET PARAMETER ID 'KUN' FIELD <lfs_final>-kunnr.
            SET PARAMETER ID 'VKO' FIELD p_vkorg.
            SET PARAMETER ID 'VTW' FIELD p_vtweg.
            SET PARAMETER ID 'SPA' FIELD p_spart.

            CALL TRANSACTION 'VD03' AND SKIP FIRST SCREEN.

          ELSEIF fp_selfield-fieldname = lc_fldname_icon.
*           If the user has clicked on the Long Text icon, then open a plain
*           text editor window with the long text in display mode. This is
*           done using the FM TXW_TEXTNOTE_EDIT which uses a 72char long
*           text editor. So, convert the 132char texts into 72char text lines
            CALL FUNCTION 'FORMAT_TEXTLINES'
              EXPORTING
                formatwidth = 72
                linewidth   = 132
                language    = p_langu
              TABLES
                lines       = <lfs_cust_text>-lines
              EXCEPTIONS
                bound_error = 1
                OTHERS      = 2.
            IF sy-subrc IS INITIAL.
*            Populate the int table for the text editor content
              LOOP AT <lfs_cust_text>-lines ASSIGNING <lfs_lines>.
                lwa_note-line = <lfs_lines>-tdline.
                APPEND lwa_note TO li_note.
              ENDLOOP.

*             Display the text editor with the long text content
              CALL FUNCTION 'TXW_TEXTNOTE_EDIT'
                EXPORTING
                  edit_mode = c_false
                TABLES
                  t_txwnote = li_note.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       Top-of-page for displaying the selection data
*----------------------------------------------------------------------*
FORM f_top_of_page.

  CONSTANTS:
    lc_typ_h TYPE char1 VALUE 'H',   " Top-of-page type - heading
    lc_typ_s TYPE char1 VALUE 'S',   " Top-of-page type - Selection
    lc_slash TYPE char1 VALUE '/'.   " Char value - slash

  DATA:
    li_top_of_page  TYPE slis_t_listheader, " Top-of-page content
    lwa_top_of_page TYPE slis_listheader,   " WA for Top-of-page content
    lv_date         TYPE char10,            " Date in user format
    lv_sysid        TYPE char12,            " System ID details
    lv_langu        TYPE char2.             " Language

* Populate the report heading
  lwa_top_of_page-typ = lc_typ_h.
  lwa_top_of_page-info = 'ZOTCR0026-Customer Sales Area Free Text Report'(hed).
  APPEND lwa_top_of_page TO li_top_of_page.
  CLEAR lwa_top_of_page.

* Populate the top-of-page selection data
  CONCATENATE sy-sysid lc_slash sy-mandt INTO lv_sysid. " System ID details
  WRITE sy-datum TO lv_date.                 " Date
  CALL FUNCTION 'CONVERSION_EXIT_ISOLA_OUTPUT'          " Language output value
    EXPORTING
      input         = p_langu
    IMPORTING
      output        = lv_langu.

  top_of_page_sel 'Date:'(s01)               lv_date  li_top_of_page.
  top_of_page_sel 'User:'(s02)               sy-uname li_top_of_page.
  top_of_page_sel 'System ID:'(s03)          lv_sysid li_top_of_page.
  top_of_page_sel 'Sales Organization:'(s04) p_vkorg  li_top_of_page.
  top_of_page_sel 'Dist. channel:'(s05)      p_vtweg  li_top_of_page.
  top_of_page_sel 'Division:'(s06)           p_spart  li_top_of_page.
  top_of_page_sel 'Text ID:'(s07)            p_tdid   li_top_of_page.
  top_of_page_sel 'Language:'(s08)           lv_langu li_top_of_page.

* Display the top-of-page
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = li_top_of_page.


ENDFORM.                    "F_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  F_GET_F4_TEXTID
*&---------------------------------------------------------------------*
*       Populate the internal table for text ID of KNVV
*----------------------------------------------------------------------*
*  <--  FP_I_TEXTID        Internal Table for Text ID F4
*----------------------------------------------------------------------*
FORM f_get_f4_textid CHANGING fp_i_textid TYPE ty_t_textid.

  DATA: lwa_dynpfields TYPE dynpread,
        li_dynpfields  TYPE STANDARD TABLE OF dynpread.

  CONSTANTS: lc_knvv TYPE tdobject VALUE 'KNVV',
             lc_p_tdobj TYPE dynfnam VALUE 'P_TDOBJ',
             lc_p_langu TYPE dynfnam VALUE 'P_LANGU'.

*&&-- Read Selection screen data
  IF p_tdobj NE 'KNVV'. "Initialization value
    REFRESH li_dynpfields.
    lwa_dynpfields-fieldname = lc_p_tdobj.
    APPEND lwa_dynpfields TO li_dynpfields.

*Get Text Object value on the selection screen
    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        dyname               = sy-repid
        dynumb               = sy-dynnr
      TABLES
        dynpfields           = li_dynpfields
      EXCEPTIONS
        invalid_abapworkarea = 1
        invalid_dynprofield  = 2
        invalid_dynproname   = 3
        invalid_dynpronummer = 4
        invalid_request      = 5
        no_fielddescription  = 6
        invalid_parameter    = 7
        undefind_error       = 8
        double_conversion    = 9
        stepl_not_found      = 10
        OTHERS               = 11.
    READ TABLE li_dynpfields INTO lwa_dynpfields
           WITH KEY fieldname = lc_p_tdobj.
    IF sy-subrc = 0.
      p_tdobj = lwa_dynpfields-fieldvalue.
    ENDIF.
  ENDIF.  "Check if TDOBJ NE KNVV

  REFRESH li_dynpfields.
  lwa_dynpfields-fieldname = lc_p_langu.
  APPEND lwa_dynpfields TO li_dynpfields.

*Get Language value on the selection screen
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = li_dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      OTHERS               = 11.
  READ TABLE li_dynpfields INTO lwa_dynpfields
         WITH KEY fieldname = lc_p_langu.
  IF sy-subrc = 0.
    p_langu = lwa_dynpfields-fieldvalue.
  ENDIF.

*&&-- Check if Language is blank
  IF p_langu IS INITIAL.
    SELECT tdid     "Text ID
           tdtext   "Short Text
      FROM ttxit    "Texts for Text IDs
      INTO TABLE fp_i_textid
      WHERE tdspras = sy-langu   "lc_en
        AND tdobject = p_tdobj.  "lc_knvv.
    IF sy-subrc IS INITIAL.
      SORT fp_i_textid BY tdid tdtext.
    ENDIF.
  ELSE.
    SELECT tdid     "Text ID
           tdtext   "Short Text
      FROM ttxit    "Texts for Text IDs
      INTO TABLE fp_i_textid
      WHERE tdspras = p_langu    "lc_en
        AND tdobject = p_tdobj.  "lc_knvv.
    IF sy-subrc IS INITIAL.
      SORT fp_i_textid BY tdid tdtext.
    ENDIF.
  ENDIF.  "Check Language Key is blank

ENDFORM.                    " F_GET_F4_TEXTID
*&---------------------------------------------------------------------*
*&      Form  F_HELP_TEXTID
*&---------------------------------------------------------------------*
*       Get the F4 help for Text ID
*----------------------------------------------------------------------*
*      -->FP_I_TEXTID[]    Internal table for TEXT ID
*      <--FP_P_TEXTID_LOW  Text ID Parameter
*----------------------------------------------------------------------*
FORM f_help_textid  USING    fp_i_textid TYPE ty_t_textid
                    CHANGING fp_p_tdid   TYPE tdid.

*&&-- Local Data
  DATA : li_return TYPE STANDARD TABLE OF ddshretval,  "Return internal table
         lwa_return TYPE ddshretval.                   "Return table work area

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'TDID'  "text-036
      dynpprog        = sy-repid
      value_org       = 'S' "c_s
    TABLES
      value_tab       = fp_i_textid
      return_tab      = li_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  READ TABLE li_return INTO lwa_return INDEX 1.
  IF sy-subrc = 0.
    fp_p_tdid = lwa_return-fieldval.
  ENDIF.

ENDFORM.                    " F_HELP_TEXTID
