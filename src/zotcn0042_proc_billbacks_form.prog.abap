************************************************************************
* PROGRAM    :  ZOTCN0042_PROC_BILLBACKS_FORM(Include)                 *
* TITLE      :  Process Billback data                                  *
* DEVELOPER  :  Santosh Vinapamula                                     *
* OBJECT TYPE:  Executable program                                     *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0042                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Process Billback data from EDI 867                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 15-JUN-2012  SVINAPA  E1DK901251 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 18-JAN-2013  ADAS1   E1DK909015  D#2490: Display Error message from  *
*                                  BAPI while Processing 'CR/DR' docs  *
* 11-May-2016  SBEHERA  E2DK917823 Defect#1573 : Output Layouts gets   *
*                                  changed before updating documents   *
* 08-Aug-2016  AMOHAPA  E2DK917823 Defect# 1910:Match up logic should  *
*                                  pick the oldest invoice and quantity*
*                                  should count in the duration of 10  *
*                                  from the billing date and this is   *
*                                  applicable for all order type       *
* 01-Nov-2016  AMOHAPA  E2DK917823 Defect#1910_FUT Issue:              *
*                                  The cockpit screen should show the  *
*                                  updated billing document number and *
*                                  item if the user wants match up in  *
*                                  same screen with different document *
*&---------------------------------------------------------------------*
* 20-Sep-2019  APODDAR  E1SK901562 Hanatization                        *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_AND_PROCESSING
*&---------------------------------------------------------------------*
*       Selection and processing logic
*----------------------------------------------------------------------*
FORM f_selection_and_processing .

  REFRESH: i_billbk_stg.

  SELECT *
    INTO TABLE i_billbk_stg
    FROM zotc_billbk_stg "  Billback Processing Staging Table
    WHERE vkorg   IN s_vkorg
      AND vtweg   IN s_vtweg
      AND vbeln_s IN s_vbeln
      AND posnr_s IN s_posnr
      AND auart   IN s_auart
      AND erdat   IN s_erdat
      AND ernam   IN s_ernam

      AND bstkd   IN s_bstkag
      AND bstdk   IN s_bstdag
      AND bstkd_e IN s_bstkwe
      AND bstdk_e IN s_bstdwe
      AND kunag   IN s_kunag
      AND kunwe   IN s_kunwe
      AND fkdat   IN s_fkdat

      AND zzdistr_code IN s_distr
      AND matnr   IN s_matnr
      AND zzclaim_mtch IN s_clmtch
      AND zzdup_clm_ind IN s_dupclm
      AND zzfully_proc IN s_flproc.

  IF sy-subrc <> 0.
    MESSAGE ID 'ZOTC_MSG' TYPE 'I' NUMBER '000' " & & & &
      WITH 'No data found for the entered selection'(001).
    LEAVE LIST-PROCESSING.
  ELSE. " ELSE -> IF sy-subrc <> 0
*--->Begin of Delete D2_OTC_EDD_0042 for Defect#1910 by AMOHAPA on 08-Aug-2016
*    SORT i_billbk_stg BY vbeln_s posnr_s.
*<---End of Delete D2_OTC_EDD_0042 for Defect#1910 by AMOHAPA on 08-Aug-2016

*--->Begin of insert D2_OTC_EDD_0042 for Defect#1910 by AMOHAPA on 08-Aug-2016
*Sort with invoice creation date and time so that the logic will pick always
*the oldest invoice while match up.
    SORT i_billbk_stg BY erdat erzet ASCENDING.
*<---End of insert D2_OTC_EDD_0042 for Defect#1910 by AMOHAPA on 08-Aug-2016

  ENDIF. " IF sy-subrc <> 0

ENDFORM. " f_SELECTION_AND_PROCESSING
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_BILLBK_DATA
*&---------------------------------------------------------------------*
*       Display Billback data
*----------------------------------------------------------------------*
FORM f_display_billbk_data .
  DATA:
    lwa_color TYPE lvc_s_colo. " ALV control: Color coding
  IF NOT i_billbk_stg[] IS INITIAL.
* ---> Begin of Insert for D2_OTC_EDD_0042_Defect#1573 by SBEHERA
    IF gv_alv_obj-gr_alv IS INITIAL.
* <--- End of Insert for D2_OTC_EDD_0042_Defect#1573 by SBEHERA
*   ALV Initialize and ALV display
      PERFORM f_alv_init_by_data TABLES i_billbk_stg
                                 USING  gv_alv_obj
                                        'ZBB_0042'
                                        'F_GRID_DBLCLICK'
                                        'F_GRID_UCOMM'
                                        abap_true
                                        space.

*   Set column settings to technical (no display)
      PERFORM f_alv_table_set_technical USING gv_alv_obj:
                                            'MANDT',
                                            'FKDAT',
                                            'ZZDISTR_CODE',
                                            'ZZSET_QTY',
                                            'ZZBAL_QTY',
                                            'VRKME',
                                            'NETWR',
                                            'ERZET',
                                            'ERNAM',
                                            'ZZFULLY_PROC'.

*   Set column settings to checkbox
      PERFORM f_alv_tablex_property_set USING gv_alv_obj:
                      'CELL_TYPE' 'ZZCLAIM_MTCH'
  cl_salv_column_table=>checkbox,
                      'CELL_TYPE' 'ZZDUP_CLM_IND'
  cl_salv_column_table=>checkbox.
*                    'CELL_TYPE' 'ZZFULLY_PROC'
*cl_salv_column_table=>checkbox.

*   Set color to price difference columns
      lwa_color-col = '6'.
      lwa_color-int = '1'.
      PERFORM f_alv_tablex_property_set USING gv_alv_obj:
                      'COLOR'     'ZZPRC_DIFF1'   lwa_color,
                      'COLOR'     'ZZPRC_DIFF2'   lwa_color.

      PERFORM f_alv_tablex_property_set USING gv_alv_obj:
                      'SHORT_TEXT'  'VBELN_S'     'Claim Doc'(002),
                      'MEDIUM_TEXT' 'VBELN_S'     'Claim Document'(003),
                      'LONG_TEXT'   'VBELN_S'     'Claim Document'(003),
                      'SHORT_TEXT'  'POSNR_S'     'Pos.'(004),
                      'MEDIUM_TEXT' 'POSNR_S'     'Position No'(005),
                      'LONG_TEXT'   'POSNR_S'     'Position No'(005),
                      'SHORT_TEXT'  'BSTKD'
                      'Dist. Sales Order'(006),
                      'MEDIUM_TEXT' 'BSTKD'
                      'Dist. Sales Order'(006),
                      'LONG_TEXT'   'BSTKD'
                      'Dist. Sales Order'(006),
                      'SHORT_TEXT'  'BSTKD_E'     'Dist. PO Number'(007),
                      'MEDIUM_TEXT' 'BSTKD_E'     'Dist. PO Number'(007),
                      'LONG_TEXT'   'BSTKD_E'     'Dist. PO Number'(007),
                      'SHORT_TEXT'  'BSTDK_E'
                      'Dist. Invoice Date'(008),
                      'MEDIUM_TEXT' 'BSTDK_E'
                      'Dist. Invoice Date'(008),
                      'LONG_TEXT'   'BSTDK_E'
                      'Dist. Invoice Date'(008),
                      'SHORT_TEXT'  'AUART'       'Doc. Type'(009),
                      'MEDIUM_TEXT' 'AUART'       'Document Type'(010),
                      'LONG_TEXT'   'AUART'       'Document Type'(010),
                      'SHORT_TEXT'  'ZMENG'       'Quantity'(011),
                      'MEDIUM_TEXT' 'ZMENG'       'Quantity'(011),
                      'LONG_TEXT'   'ZMENG'       'Quantity'(011),
                      'SHORT_TEXT'  'ZIEME'       'Qty. UOM'(012),
                      'MEDIUM_TEXT' 'ZIEME'       'Qty. UOM'(012),
                      'LONG_TEXT'   'ZIEME'       'Qty. UOM'(012),
                      'SHORT_TEXT'  'ZZCOM_VAL'   'Adjusted BR Cost'(019),
                      'MEDIUM_TEXT' 'ZZCOM_VAL'   'Adjusted BR Cost'(019),
                      'LONG_TEXT'   'ZZCOM_VAL'   'Adjusted BR Cost'(019).


*   Display ALV
      PERFORM f_alv_table_show USING gv_alv_obj.
* ---> Begin of Insert for D2_OTC_EDD_0042_Defect#1573 by SBEHERA
    ENDIF. " IF gv_alv_obj-gr_alv IS INITIAL
* <--- End of Insert for D2_OTC_EDD_0042_Defect#1573 by SBEHERA
  ENDIF. " IF NOT i_billbk_stg[] IS INITIAL

ENDFORM. " F_DISPLAY_BILLBK_DATA
*&---------------------------------------------------------------------*
*&      Module  STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0101 OUTPUT.

* Exclude SAVE button from PF Status
  APPEND 'SAVE' TO i_fcode.

* Set PF Status
  SET PF-STATUS 'ZBB_0042' EXCLUDING i_fcode.

* Set Title bar
  SET TITLEBAR 'B42'.

ENDMODULE. " STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  F_ALV_INIT_BY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_alv_init_by_data  TABLES   i_final
                                                                "Insert correct name for <...>
                         USING    p_alv_obj             TYPE
ty_alv_tablex
                                  p_pfstatus            TYPE c  " Pfstatus of type Character
                                  f_form_dblclick       TYPE c  " Form_dblclick of type Character
                                  f_form_ucomm          TYPE c  " Form_ucomm of type Character
                                  p_zebra               TYPE c  " Zebra of type Character
                                  p_col_color           TYPE c. " Col_color of type Character

* Initialize ALV_TABLE objects using data table
  DATA: lr_funct            TYPE REF TO cl_salv_functions. " Generic and Application-Specific Functions
  DATA: lr_display          TYPE REF TO cl_salv_display_settings. " Appearance of the ALV Output
  DATA: lr_event_receiver   TYPE REF TO lcl_event_receiver. " Event_receiver class
  DATA: lr_events           TYPE REF TO cl_salv_events_table. " Events in Simple, Two-Dimensional Tables
  DATA: lr_layout           TYPE REF TO cl_salv_layout. " Settings for Layout
  DATA: lr_key              TYPE salv_s_layout_key. " Layout Key
  DATA: lr_selections       TYPE REF TO cl_salv_selections. " Selections in List-Type Output Tables

  DATA:
    gv_formname_dblclick    TYPE formname,
    gv_formname_ucomm       TYPE formname,
    lv_colname_color_col    TYPE lvc_fname, " ALV control: Field name of internal table field
    lv_pfstatus             TYPE sypfkey.   " Current GUI Status

  CLEAR p_alv_obj.

  TRY.
      cl_salv_table=>factory(
            IMPORTING r_salv_table = p_alv_obj-gr_alv
            CHANGING t_table = i_final[] ).

    CATCH cx_salv_msg.
      CLEAR p_alv_obj-b_initialized.
      EXIT.
  ENDTRY.

  p_alv_obj-b_initialized = abap_true.

* Activate standard ALV buttons
  lr_funct = p_alv_obj-gr_alv->get_functions( ).
  lr_funct->set_all( abap_true ).


* Set display settings
  lr_display = p_alv_obj-gr_alv->get_display_settings( ).
  IF NOT p_zebra IS INITIAL.
    lr_display->set_striped_pattern( abap_true ).
  ENDIF. " IF NOT p_zebra IS INITIAL
  lr_display->set_fit_column_to_table_size( abap_true ).

* Cell formatting information
  TRY.
      p_alv_obj-gr_columns = p_alv_obj-gr_alv->get_columns( ).
      p_alv_obj-gr_columns->set_optimize( abap_true ).
 "Adjust length
      p_alv_obj-gr_columns->set_key_fixation( abap_false ).
      "UnFix Key columns

*     If color column is specified, set ALV color dependency (column
*     must be of of type LVC_T_SCOL)
      IF NOT p_col_color IS INITIAL.
        lv_colname_color_col = p_col_color.
        TRANSLATE lv_colname_color_col TO UPPER CASE.
        p_alv_obj-gr_columns->set_color_column( lv_colname_color_col ).
      ENDIF. " IF NOT p_col_color IS INITIAL
    CATCH cx_salv_data_error.
  ENDTRY.

* Set user menu if specified (must be copied from function group
* SALV_METADATA_STATUS, status SALV_TABLE_STANDARD )
  IF NOT p_pfstatus IS INITIAL.
    lv_pfstatus = p_pfstatus.
    TRANSLATE lv_pfstatus TO UPPER CASE.
    p_alv_obj-gr_alv->set_screen_status(
          pfstatus = lv_pfstatus
          report = sy-repid
          set_functions = cl_salv_table=>c_functions_all ).
  ENDIF. " IF NOT p_pfstatus IS INITIAL

* Set selection mode
  lr_selections = p_alv_obj-gr_alv->get_selections( ).
  lr_selections->set_selection_mode( 4 ). " 4=Boxed multiple selection

* Specify event processing
  lr_events = p_alv_obj-gr_alv->get_event( ).

  CREATE OBJECT lr_event_receiver.
  gv_formname_dblclick = f_form_dblclick.
  TRANSLATE gv_formname_dblclick TO UPPER CASE.

  gv_formname_ucomm = f_form_ucomm.
  TRANSLATE gv_formname_ucomm TO UPPER CASE.

  lr_event_receiver->gv_formname_dblclick = gv_formname_dblclick.
  lr_event_receiver->gv_formname_ucomm = gv_formname_ucomm.

  SET HANDLER lr_event_receiver->meth_p_p_handle_double_click FOR
lr_events.
  SET HANDLER lr_event_receiver->meth_p_p_handle_link_click FOR
lr_events.
  SET HANDLER lr_event_receiver->meth_p_p_handle_ucomm FOR lr_events.

* Allow layout save
  lr_layout = p_alv_obj-gr_alv->get_layout( ).
  lr_key-report = sy-repid.
  lr_layout->set_key( lr_key ).

* User with maintain rights for std layouts can save global layouts
  AUTHORITY-CHECK OBJECT 'S_ALV_LAYO'
        ID 'ACTVT' FIELD '23'.

  IF sy-subrc = 0.
    lr_layout->set_save_restriction(
          cl_salv_layout=>restrict_none ).
  ELSE. " ELSE -> IF sy-subrc = 0
    lr_layout->set_save_restriction(
          cl_salv_layout=>restrict_user_dependant ).
  ENDIF. " IF sy-subrc = 0
* ---> Begin of Insert for D2_OTC_EDD_0042_Defect#1573 by SBEHERA
  p_alv_obj-gr_alv->display( ).
* <--- End of Insert for D2_OTC_EDD_0042_Defect#1573 by SBEHERA

ENDFORM. " F_ALV_INIT_BY_DATA
*&---------------------------------------------------------------------*
*&      Form  F_ALV_TABLE_SHOW
*&---------------------------------------------------------------------*
*       Display ALV
*----------------------------------------------------------------------*
FORM f_alv_table_show  USING    p_alv_obj TYPE ty_alv_tablex.

* Local varaibles
  DATA: lv_stabilize_rows_cols TYPE lvc_s_stbl. " ALV control: Refresh stability
* ---> Begin of Insert for D2_OTC_EDD_0042_Defect#1573 by SBEHERA
  CONSTANTS:
    lc_claim_match   TYPE char4 VALUE 'CLMM', " Claim Match Look-up
    lc_process_crdr  TYPE char4 VALUE 'PRCD', " Process CR/DB
    lc_bill_claim    TYPE char4 VALUE 'CHOR'. " Change Bill Claim
* <--- End of Insert for D2_OTC_EDD_0042_Defect#1573 by SBEHERA

  IF NOT p_alv_obj-b_initialized IS INITIAL.
    IF p_alv_obj-b_displayed IS INITIAL.
      IF sy-ucomm NE'&F03' AND
        sy-ucomm NE '&F15' AND
        sy-ucomm NE '&F12'.

        p_alv_obj-b_displayed = abap_true.

        p_alv_obj-gr_alv->display( ).
*--->Begin of Insert for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016
        p_alv_obj-gr_alv->refresh( ).
*<---End of Insert for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016
      ENDIF. " IF sy-ucomm NE'&F03' AND
    ELSE. " ELSE -> IF sy-ucomm NE'&F03' AND
* ---> Begin of Insert for D2_OTC_EDD_0042_Defect#1573 by SBEHERA
*  ALV Layout refreshed
      IF sy-ucomm  NE lc_claim_match AND
        sy-ucomm NE lc_process_crdr AND
        sy-ucomm NE '&F03'      AND
        sy-ucomm NE '&F15' AND
         sy-ucomm NE '&F12' AND
        sy-ucomm NE lc_bill_claim.
* <--- End of Insert for D2_OTC_EDD_0042_Defect#1573 by SBEHERA
*     Refresh ALV after table data update
        lv_stabilize_rows_cols-row = abap_true.
        lv_stabilize_rows_cols-col = abap_true.

        TRY .
            p_alv_obj-gr_columns = p_alv_obj-gr_alv->get_columns( ).
            p_alv_obj-gr_columns->set_optimize( abap_true ).
 " Adjust length

          CATCH cx_salv_data_error.
        ENDTRY.

        p_alv_obj-gr_alv->refresh( s_stable = lv_stabilize_rows_cols
             refresh_mode = 2 ).
* ---> Begin of Insert for D2_OTC_EDD_0042_Defect#1573 by SBEHERA
      ENDIF. " IF sy-ucomm NE lc_claim_match AND
* <--- End of Insert for D2_OTC_EDD_0042_Defect#1573 by SBEHERA
    ENDIF. " IF p_alv_obj-b_displayed IS INITIAL

*--->Begin of Insert for D2_OTC_EDD_0042 Defect# 1910_FUT Issue by AMOHAPA on 01-Nov-2016
*Clear the p_alv_obj-b_displayed so that if the user selects one document for match up and again
*want to repeat the same for a different document the updation should show on the cockpit screen

    CLEAR p_alv_obj-b_displayed.
*<---End of Insert for D2_OTC_EDD_0042 Defect# 1910_FUT Issue by AMOHAPA on 01-Nov-2016
  ENDIF. " IF NOT p_alv_obj-b_initialized IS INITIAL

ENDFORM. " F_ALV_TABLE_SHOW
*&---------------------------------------------------------------------*
*&      Form  F_ALV_TABLE_SET_TECHNICAL
*&---------------------------------------------------------------------*
*       Set column settings to technical (no display)
*----------------------------------------------------------------------*
FORM f_alv_table_set_technical  USING    p_alv_obj TYPE ty_alv_tablex
                                         p_colname TYPE c. " Colname of type Character

* Set to no display
  PERFORM f_alv_tablex_property_set USING p_alv_obj 'TECHNICAL'
                                          p_colname abap_true.

ENDFORM. " F_ALV_TABLE_SET_TECHNICAL
*&---------------------------------------------------------------------*
*&      Form  F_ALV_TABLEX_PROPERTY_SET
*&---------------------------------------------------------------------*
*       Set column property for display
*----------------------------------------------------------------------*
*# List of available properties (SET methods of CL_SALV_COLUMN_TABLE)
*#   (set_)ALIGNMENT
*#   (set_)CURRENCY
*#   (set_)CURRENCY_COLUMN
*#   (set_)DDIC_REFERENCE
*#   (set_)DECIMALS_COLUMN
*#   (set_)DECIMALS
*#   (set_)EDIT_MASK
*#   (set_)F1_ROLLNAME
*#   (set_)LEADING_ZERO
*#   (set_)LONG_TEXT
*#   (set_)LOWERCASE
*#   (set_)MEDIUM_TEXT
*#   (set_)OPTIMIZED
*#   (set_)OUTPUT_LENGTH
*#   (set_)QUANTITY
*#   (set_)QUANTITY_COLUMN
*#   (set_)ROUND
*#   (set_)ROUND_COLUMN
*#   (set_)ROW
*#   (set_)SHORT_TEXT
*#   (set_)SIGN
*#   (set_)TECHNICAL
*#   (set_)TOOLTIP
*#   (set_)VISIBLE
*#   (set_)ZERO
*#   (set_)ACTIVE_FOR_REP_INTERFACE
*#   (set_)CELL_TYPE
*#   (set_)COLOR
*#   (set_)DROPDOWN_ENTRY
*#   (set_)HYPERLINK_ENTRY
*#   (set_)F4
*#   (set_)F4_CHECKTABLE
*#   (set_)ICON
*#   (set_)KEY
*#   (set_)KEY_PRESENCE_REQUIRED
*#   (set_)SYMBOL
*#   (set_)TEXT_COLUMN
*----------------------------------------------------------------------*
FORM f_alv_tablex_property_set  USING    p_alv_obj TYPE ty_alv_tablex
                                         p_property TYPE c " Property of type Character
                                         p_colname  TYPE c " Colname of type Character
                                         p_value    TYPE any.

  DATA: lr_column   TYPE REF TO cl_salv_column_table, " Column Description of Simple, Two-Dimensional Tables
        lv_colname  TYPE lvc_fname,                   " ALV control: Field name of internal table field
        lv_method   TYPE formname.

  IF NOT p_property IS INITIAL.
    CONCATENATE 'SET_' p_property INTO lv_method.
    TRANSLATE lv_method TO UPPER CASE.
    CONDENSE  lv_method NO-GAPS.
  ENDIF. " IF NOT p_property IS INITIAL

  IF NOT p_colname IS INITIAL.
    lv_colname = p_colname.
    TRANSLATE lv_colname TO UPPER CASE.
  ENDIF. " IF NOT p_colname IS INITIAL

  TRY.
      lr_column ?= p_alv_obj-gr_columns->get_column( lv_colname ).
      CALL METHOD lr_column->(lv_method) EXPORTING value = p_value.
    CATCH cx_sy_dyn_call_error cx_salv_not_found.
  ENDTRY.

ENDFORM. " F_ALV_TABLEX_PROPERTY_SET
*&---------------------------------------------------------------------*
*&      Form  F_GRID_DBLCLICK
*&---------------------------------------------------------------------*
*       Handle double click
*----------------------------------------------------------------------*
FORM f_grid_dblclick USING p_row    TYPE i  " Grid_dblclick using p_r of type Integers
                           p_column TYPE c. " Column of type Character

* Double-click handling
  DATA:
    lv_ok           TYPE boolean, " Boolean Variable (X=True, -=False, Space=Unknown)
    lv_modified     TYPE boolean, " Boolean Variable (X=True, -=False, Space=Unknown)
    lv_message      TYPE string.

  DATA:
    lt_rows TYPE salv_t_row.

  FIELD-SYMBOLS:
    <lfs_bb_stg>    TYPE ty_billbk_stg.

  IF p_row > 0.
    READ TABLE i_billbk_stg ASSIGNING <lfs_bb_stg> INDEX p_row.
*   Drilldown: show documents if dbl-click on document number
    IF p_column = 'VBELN_S'.
*     Display sales document
*      PERFORM f_show_document USING <lfs_bb_stg>-vbeln_s.
      SET PARAMETER ID 'AUN' FIELD <lfs_bb_stg>-vbeln_s.
      CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
    ELSEIF p_column = 'VBELN_B'.
*     Display Billing document
*      PERFORM f_show_document USING <lfs_bb_stg>-vbeln_b.
      SET PARAMETER ID 'VF' FIELD <lfs_bb_stg>-vbeln_b.
      CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
    ENDIF. " IF p_column = 'VBELN_S'
  ENDIF. " IF p_row > 0

ENDFORM. " F_GRID_DBLCLICK
*&---------------------------------------------------------------------*
*&      Form  F_SHOW_DOCUMENT
*&---------------------------------------------------------------------*
*       Show Document
*----------------------------------------------------------------------*
FORM f_show_document USING p_vbeln TYPE vbeln_va. " Sales Document

* Display document
  IF NOT p_vbeln IS INITIAL.
*    SET PARAMETER ID 'AUN' FIELD p_vbeln.
*    CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
  ENDIF. " IF NOT p_vbeln IS INITIAL

ENDFORM. " F_SHOW_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  F_ALV_DEFAULT_DBLCLICK
*&---------------------------------------------------------------------*
*       Handle default double click
*----------------------------------------------------------------------*
FORM f_alv_default_dblclick USING p_row TYPE i p_column TYPE c. " Alv_default_dblclick us of type Integers

* Default double-click handling

ENDFORM. " f_alv_default_dblclick
*&---------------------------------------------------------------------*
*&      Form  F_GRID_UCOMM
*&---------------------------------------------------------------------*
*       Handle user command
*----------------------------------------------------------------------*
FORM f_grid_ucomm USING p_ucomm TYPE c. " Grid_ucomm using p_ucom of type Character

* User command processing
  DATA: lr_selections TYPE REF TO cl_salv_selections. " Selections in List-Type Output Tables
  DATA: li_rows       TYPE salv_t_row.
  DATA: lw_rows       TYPE i. " Rows of type Integers
  DATA: lv_num_rows   TYPE i. " Num_rows of type Integers

  FIELD-SYMBOLS:
     <lfs_rows>       TYPE i, " Rows> of type Integers
     <lfs_bb_stg>     TYPE ty_billbk_stg.

  lr_selections = gv_alv_obj-gr_alv->get_selections( ).
  li_rows       = lr_selections->get_selected_rows( ).

* Check if any rows are selected. Otherwise, claim look-up for all
* records will be performed
* Move all records displayed to the temporary billback staging table
  REFRESH i_tmp_bb_stg.
  IF li_rows[] IS INITIAL.
*    DESCRIBE TABLE i_billbk_stg LINES lv_num_rows.
*    DO lv_num_rows TIMES.
*      lw_rows = sy-index .
*      APPEND lw_rows TO li_rows.
*    ENDDO.
    i_tmp_bb_stg[] = i_billbk_stg[].
  ELSE. " ELSE -> IF li_rows[] IS INITIAL
    LOOP AT li_rows ASSIGNING <lfs_rows>.
*     When any rows are selected, move those records to temp billback
*     staging table
      READ TABLE i_billbk_stg ASSIGNING <lfs_bb_stg> INDEX <lfs_rows>.
      IF sy-subrc = 0.
*       Move all selected rows into i_tmp_bb_stg
        APPEND <lfs_bb_stg> TO i_tmp_bb_stg.
      ENDIF. " IF sy-subrc = 0
    ENDLOOP. " LOOP AT li_rows ASSIGNING <lfs_rows>
  ENDIF. " IF li_rows[] IS INITIAL

*Get all possible orders invoiced for the combination of sold-to,
*ship-to, material.It may be better to check for date and quantity as
*well. Will know during testing and will depend on edi867 data
*Full key is not used to select as Billback table has details for
*Invoice documents.All the records for where condition should be
*selected. There can be duplicates

  REFRESH i_ord_data.
  PERFORM f_get_billback_data.

  IF p_ucomm = 'CLMM'. " Claim Match Look-up
    IF NOT i_tmp_bb_stg[] IS INITIAL.
*     Claim look-up from ZOTC_BILLBACK
      PERFORM f_claim_lookup.
    ENDIF. " IF NOT i_tmp_bb_stg[] IS INITIAL
  ELSEIF p_ucomm = 'PRCD'. " Process CR/DB
    IF NOT i_tmp_bb_stg[] IS INITIAL.
*     Removes block from sales order
      PERFORM f_process_crdb.
    ENDIF. " IF NOT i_tmp_bb_stg[] IS INITIAL
  ELSEIF p_ucomm = 'CHOR'.
*   Change sales document
*   Check only one row is selected
    DESCRIBE TABLE li_rows LINES lv_num_rows.
    IF lv_num_rows <> 1.
      MESSAGE ID 'ZOTC_MSG' TYPE 'I' NUMBER '000' WITH " & & & &
                                  'Please select one row'(m01).
      EXIT.
    ENDIF. " IF lv_num_rows <> 1

    READ TABLE li_rows ASSIGNING <lfs_rows> INDEX 1.
    IF sy-subrc = 0.
      READ TABLE i_billbk_stg ASSIGNING <lfs_bb_stg> INDEX <lfs_rows>.
      IF sy-subrc = 0.
        SET PARAMETER ID 'AUN' FIELD <lfs_bb_stg>-vbeln_s.
        CALL TRANSACTION 'VA02' AND SKIP FIRST SCREEN.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0
  ENDIF.

ENDFORM. " f_grid_ucomm
*&---------------------------------------------------------------------*
*&      Form  F_ALV_DEFAULT_UCOMM
*&---------------------------------------------------------------------*
*       Handle default User command
*----------------------------------------------------------------------*
FORM f_alv_default_ucomm  USING    p_ucomm TYPE c. " Alv_default_ucomm using of type Character

* Default user-command handling

ENDFORM. " F_ALV_DEFAULT_UCOMM
*&---------------------------------------------------------------------*
*&      Form  F_CLAIM_LOOKUP
*&---------------------------------------------------------------------*
*       Claim look-up
*----------------------------------------------------------------------*
FORM f_claim_lookup.

  CONSTANTS:  lc_standing_ord TYPE auart VALUE 'ZSTD', " Sales Document Type
              lc_sign         TYPE sign  VALUE 'I',    " Debit/Credit Sign (+/-)
              lc_option       TYPE option VALUE 'BT',  " Option for ranges tables
*--->Begin of Insert for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016
              lc_months       TYPE dlymo VALUE '00',  "local constant for months duration
              lc_year         TYPE dlyyr VALUE '00',  "Local constants for year duration
              lc_signum         TYPE spli1 VALUE '+'. "Local constants for sign
*<---End of Insert for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016

  FIELD-SYMBOLS:
    <lfs_bb_stg>     TYPE ty_billbk_stg,
    <lfs_ord_data>   TYPE zotc_billback. " BillBack Process Control Table

  DATA:
    lv_ord_cnt       TYPE i,              " Order count
    lv_single        TYPE char1,          " Flag for single match
    lv_match_found   TYPE xfeld,          " Flag if Match found
    lr_fkdat         TYPE RANGE OF fkdat, " Billing date for billing index and printout
    lw_r_fkdat       LIKE LINE OF lr_fkdat,
    lv_ord_qty       TYPE z_bal_qty,      " Balanced Quantity
*--->Begin of Insert for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016
    lv_calc_day      TYPE begda. " Start Date
*<---End of Insert for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016

*** Rules for claim lookup. Original orders from Cardinal are created
*through EDI850
*** There can be duplicates
*
*  BOC +++ADAS1
  REFRESH i_vbuv.
  SELECT *
    INTO TABLE i_vbuv
    FROM vbuv " Sales Document: Incompletion Log
    FOR ALL ENTRIES IN i_tmp_bb_stg
    WHERE vbeln = i_tmp_bb_stg-vbeln_s
      AND posnr = i_tmp_bb_stg-posnr_s.
  IF sy-subrc = 0.
    SORT i_vbuv BY vbeln posnr.
  ENDIF. " IF sy-subrc = 0
*  EOC +++ADAS1

  IF NOT i_ord_data[] IS INITIAL.
    LOOP AT i_tmp_bb_stg ASSIGNING <lfs_bb_stg>.
      CLEAR: lv_ord_cnt.
      LOOP AT i_ord_data ASSIGNING <lfs_ord_data>
                                WHERE matnr = <lfs_bb_stg>-matnr
                                  AND vkorg = <lfs_bb_stg>-vkorg
                                  AND vtweg = <lfs_bb_stg>-vtweg
                                  AND kunag = <lfs_bb_stg>-kunag
                                  AND kunnr = <lfs_bb_stg>-kunwe
                                  AND bstdk = <lfs_bb_stg>-bstdk
                                  AND zzset_flag <> 'S'.
*                                  AND fkimg = <lfs_bb_stg>-zmeng.
*                                  and bstdk_e ??
*** Logic for ZSTD orders here
* check for order type ZSTD. For ZSTD, ship to po date from 867 should
* be close (+/- 3 days) to the invoice date
* from zotc_billback and then find for all matches
*       Get the total count of orders that matched

*       BOC +++ADAS1 08/07/2012
        REFRESH: lr_fkdat.
        CLEAR:   lw_r_fkdat.
*--->Begin of Delete for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016
*This logic is no more specific to any particular order type.
*Also it is considering +10 days to the billing date in matched zotc_billback record
*       Check the standing Order
*        IF <lfs_ord_data>-auart = lc_standing_ord. " ZSTD
*<---End of Delete for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016
*         Populate the range table with invoice date and +3 date range
        lw_r_fkdat-sign   = lc_sign. " I
        lw_r_fkdat-option = lc_option. " BT
        lw_r_fkdat-low    = <lfs_ord_data>-fkdat.
*--->Begin of Delete for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016
*          lw_r_fkdat-high   = <lfs_ord_data>-fkdat + 3.
*<---End of Delete for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016

*--->Begin of Insert for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016
*As there is no exception handling in the FM so check is required for the field symbol.
        IF <lfs_ord_data> IS ASSIGNED.
          CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
            EXPORTING
              date      = <lfs_ord_data>-fkdat
              days      = gv_duration
              months    = lc_months
              signum    = lc_signum
              years     = lc_year
            IMPORTING
              calc_date = lv_calc_day.


          lw_r_fkdat-high   = lv_calc_day.
        ENDIF. " IF <lfs_ord_data> IS ASSIGNED
*<---End of Insert for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016

        APPEND lw_r_fkdat TO lr_fkdat.
*--->Begin of Insert for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016
        CLEAR: lv_calc_day.

*<---End of Insert for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016

*         If Ship-to-party's PO date of the SO falls in this 3 days
*         date range,
*         Add up the banaced quantity
        IF <lfs_bb_stg>-bstdk_e IN lr_fkdat.
          lv_ord_qty = lv_ord_qty + <lfs_ord_data>-zzbal_qty.
        ENDIF. " IF <lfs_bb_stg>-bstdk_e IN lr_fkdat
*--->Begin of Delete for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016
*        ELSE. " ELSE -> IF <lfs_bb_stg>-bstdk_e IN lr_fkdat
*          lv_ord_qty = <lfs_ord_data>-zzbal_qty.
*        ENDIF. " LOOP AT i_ord_data ASSIGNING <lfs_ord_data>
*<---End of Delete for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016
*       EOC +++ADAS1 08/07/2012

      ENDLOOP. " LOOP AT i_ord_data ASSIGNING <lfs_ord_data>

      IF lv_ord_qty > 0.
        lv_ord_cnt = lv_ord_cnt + 1.
      ENDIF. " IF lv_ord_qty > 0

      IF lv_ord_cnt <> 1.
*       No match found or multiple matches found. Do not check for
*       further processing
      ELSE. " ELSE -> IF lv_ord_cnt <> 1
*       Single record matched. Update Claim match and invoice details
*       in the report
*       <lfs_ord_data> is already assigned with correct record. No
*       need to read
        lv_single = abap_true.
        PERFORM f_upd_billbk_stg USING <lfs_bb_stg>
                                       <lfs_ord_data>
                               CHANGING lv_match_found.
      ENDIF. " IF lv_ord_cnt <> 1

      CLEAR: lv_ord_qty.
    ENDLOOP. " LOOP AT i_tmp_bb_stg ASSIGNING <lfs_bb_stg>

*   Display ALV
    PERFORM f_alv_table_show USING gv_alv_obj.

*   Information pop-up
    IF lv_single = abap_true.
      PERFORM popup_inform USING
            'Claim Match Look-up'(i11)
            'Claim Matched, Invoice Document and Item Nr. will be updated for direct matches.'(016) " Fastpath
            'Process CR/DR button can be used to remove Block for Claim Matched records.'(017) " Claim Management Data (Additional to Data in QMEL)
            ' '
            ' '.
    ELSE. " ELSE -> IF lv_single = abap_true
      PERFORM popup_inform USING
            'Claim Match Look-up'(i11)
            'Claim Matched, Invoice Document and Item Nr. will be updated for direct matches.'(016) " Fastpath
            'No match or Multiple matches found for other documents.'(i13) " Further information on use and/or destination
            'Process CR/DR button can be used to remove Block for Claim Matched records.'(i14) " Claim Management Data (Additional to Data in QMEL)
            ' '.

    ENDIF. " IF lv_single = abap_true
  ENDIF. " IF NOT i_ord_data[] IS INITIAL

ENDFORM. " F_CLAIM_LOOKUP
*&---------------------------------------------------------------------*
*&      Form  F_UPD_BILLBK_STG
*&---------------------------------------------------------------------*
*       Update Billback staging table with claim lookup details
*----------------------------------------------------------------------*
FORM f_upd_billbk_stg  USING    p_lfs_bb_stg    TYPE ty_billbk_stg
                                p_lfs_ord_data  TYPE zotc_billback " BillBack Process Control Table
                       CHANGING p_match_found   TYPE c.            " Match_found of type Character

  FIELD-SYMBOLS:
    <lfs_billbk_stg>    TYPE ty_billbk_stg,
    <lfs_gpo_ident>     TYPE tvv1t. " Customer group 1: Description

  DATA:
    lv_bezei            TYPE bezei20, " Description
    lw_vbuv             TYPE vbuv.    " Sales Document: Incompletion Log

  READ TABLE i_billbk_stg ASSIGNING <lfs_billbk_stg>
                            WITH KEY p_lfs_bb_stg.
  IF sy-subrc = 0.
    p_match_found                  = abap_true. " Flag
    <lfs_billbk_stg>-zzclaim_mtch  = abap_true.
 " Claim match indicator
    <lfs_billbk_stg>-vbeln_b       = p_lfs_ord_data-vbeln.
 " Billing document
    <lfs_billbk_stg>-posnr_b       = p_lfs_ord_data-posnr.
 " Billing doc item

    READ TABLE i_gpo_ident ASSIGNING <lfs_gpo_ident>
 " Customer group 1
                            WITH KEY spras = sy-langu
                                     kvgr1 = p_lfs_ord_data-kvgr1
                                     BINARY SEARCH.
    IF sy-subrc = 0.
      CONCATENATE p_lfs_ord_data-kvgr1 <lfs_gpo_ident>-bezei
            INTO <lfs_billbk_stg>-zzgpo_ident
                 SEPARATED BY ' - '.
    ENDIF. " IF sy-subrc = 0

*   If the balance quantity in the matched record is 0,
*   this is a duplicate claim
    IF p_lfs_ord_data-zzbal_qty = 0.
      <lfs_billbk_stg>-zzdup_clm_ind       = abap_true.
           " Duplicate claim
    ENDIF. " IF p_lfs_ord_data-zzbal_qty = 0

*   Check Incomplete flag
    CLEAR: lw_vbuv.
    READ TABLE i_vbuv INTO lw_vbuv
         WITH KEY vbeln = <lfs_billbk_stg>-vbeln_s
                  posnr = <lfs_billbk_stg>-posnr_s
                  BINARY SEARCH.
    IF sy-subrc = 0.
      <lfs_billbk_stg>-zzincomplete_flg = abap_true.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF sy-subrc = 0

ENDFORM. " F_UPD_BILLBK_STG
*&---------------------------------------------------------------------*
*&      Form  POPUP_INFORM
*&---------------------------------------------------------------------*
*       Information pop-up
*----------------------------------------------------------------------*
FORM popup_inform  USING    p_str_titel     TYPE c  " Inform using p_str_ of type Character
                            p_str_txt1      TYPE c  " Str_txt1 of type Character
                            p_str_txt2      TYPE c  " Str_txt2 of type Character
                            p_str_txt3      TYPE c  " Str_txt3 of type Character
                            p_str_txt4      TYPE c. " Str_txt4 of type Character

* Information pop-up
  CALL FUNCTION 'POPUP_TO_INFORM'
    EXPORTING
      titel = p_str_titel
      txt1  = p_str_txt1
      txt2  = p_str_txt2
      txt3  = p_str_txt3
      txt4  = p_str_txt4.

ENDFORM. " POPUP_INFORM
*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_CRDB
*&---------------------------------------------------------------------*
*       Remove Billing block in sales order
*----------------------------------------------------------------------*
FORM f_process_crdb .

  FIELD-SYMBOLS:
   <lfs_bb_stg>     TYPE ty_billbk_stg,
   <lfs_bb_stg_tmp> TYPE ty_billbk_stg,
   <lfs_return>     TYPE bapiret2,   " Return Parameter
   <lfs_orditmin>   TYPE bapisditm,  " Communication Fields: Sales and Distribution Document Item
   <lfs_orditminx>  TYPE bapisditmx, " Communication Fields: Sales and Distribution Document Item
   <lfs_salesitm>   TYPE vbap,       " Sales Document: Item Data
   <lfs_billbk_stg> TYPE ty_billbk_stg.

  DATA:
    lv_clm_match     TYPE c,                 " Flag for Claim match
    lv_dup_claim     TYPE c,                 " Flag for duplicate claim
    lv_confirmed     TYPE boolean,           " Pop-up answer
    lv_slsorder      TYPE bapivbeln-vbeln,   " Sales Document
    lw_ordhdrin      TYPE bapisdh1,          " Communication Fields: SD Order Header
    lw_ordhdrinx     TYPE bapisdh1x,         " Checkbox List: SD Order Header
    lw_orditmin      TYPE bapisditm,         " Communication Fields: Sales and Distribution Document Item
    lw_orditminx     TYPE bapisditmx,        " Communication Fields: Sales and Distribution Document Item
    lv_simulate      TYPE bapiflag-bapiflag, " Single-Character Indicator
    lw_vbuv          TYPE vbuv.              " Sales Document: Incompletion Log

* BAPI tables
  DATA:
    lt_orditmin      TYPE STANDARD TABLE OF bapisditm,  " Communication Fields: Sales and Distribution Document Item
    lt_orditminx     TYPE STANDARD TABLE OF bapisditmx, " Communication Fields: Sales and Distribution Document Item
    lt_return        TYPE STANDARD TABLE OF bapiret2,   " Return Parameter
    lt_salesitm      TYPE STANDARD TABLE OF vbap,       " Sales Document: Item Data
    lt_vbuv          TYPE STANDARD TABLE OF vbuv.       " Sales Document: Incompletion Log

* Internal table to hold records to update database tables
  DATA:
    lt_bb_stg_upd    TYPE STANDARD TABLE OF zotc_billbk_stg, "  Billback Processing Staging Table
    lt_billbk_upd    TYPE STANDARD TABLE OF zotc_billback.   " BillBack Process Control Table


  REFRESH: lt_bb_stg_upd,lt_billbk_upd.

* Some of the records selected doesn't have a direct claim match.
*  Check a flag
* to give a confirmation pop-up later
  LOOP AT i_tmp_bb_stg ASSIGNING <lfs_bb_stg>.
    IF <lfs_bb_stg>-zzclaim_mtch <> abap_true.
      lv_clm_match  = abap_true.
      EXIT.
    ENDIF. " IF <lfs_bb_stg>-zzclaim_mtch <> abap_true
  ENDLOOP. " LOOP AT i_tmp_bb_stg ASSIGNING <lfs_bb_stg>

  IF lv_clm_match = abap_true.
    PERFORM popup_confirm USING
          'CR/DB for Unmatched Claim'(c11)
     'Some Claim records did not have a matched Billing document.Remove Block?'(018)
          CHANGING lv_confirmed.
  ENDIF. " IF lv_clm_match = abap_true

* If any of the records have duplicate claim indicator checked, check
* a flag
  LOOP AT i_tmp_bb_stg ASSIGNING <lfs_bb_stg>.
    IF <lfs_bb_stg>-zzdup_clm_ind = abap_true.
      lv_dup_claim  = abap_true.
      EXIT.
    ENDIF. " IF <lfs_bb_stg>-zzdup_clm_ind = abap_true
  ENDLOOP. " LOOP AT i_tmp_bb_stg ASSIGNING <lfs_bb_stg>

  IF lv_dup_claim = abap_true.
    PERFORM popup_confirm USING
          'Duplicate Claim'(c13)
          'Some Claim records are duplicate claims. Remove Block?'(c14)
          CHANGING lv_confirmed.
  ENDIF. " IF lv_dup_claim = abap_true

  IF lv_confirmed = abap_true OR
     ( lv_clm_match = abap_false OR lv_dup_claim = abap_false ).

*   Read all order items for all sales orders selected
    REFRESH lt_salesitm.
    SELECT *
      INTO TABLE lt_salesitm
      FROM  vbap " Sales Document: Item Data
      FOR ALL ENTRIES IN i_tmp_bb_stg
      WHERE vbeln = i_tmp_bb_stg-vbeln_s
        AND posnr = i_tmp_bb_stg-posnr_s.
    IF sy-subrc = 0.
      SORT lt_salesitm BY vbeln posnr.
    ENDIF. " IF sy-subrc = 0


*     BAPI call for sales order change to remove the block
    LOOP AT i_tmp_bb_stg ASSIGNING <lfs_bb_stg>.
      REFRESH: lt_return,lt_orditmin,lt_orditminx.
      CLEAR: lv_slsorder,lw_ordhdrin-bill_block,lw_ordhdrinx-bill_block.

*      ASSIGN <lfs_bb_stg_tmp> TO <lfs_bb_stg>.
*      AT END OF posnr_s.
      lv_slsorder             =  <lfs_bb_stg>-vbeln_s.
*     Billing block will be set at item level
      lw_ordhdrinx-updateflag = 'U'.
*      lw_ordhdrinx-bill_block = 'X'.

*     Read selected line items from VBAP and update block at item level
      READ TABLE lt_salesitm ASSIGNING <lfs_salesitm> WITH KEY
                                      vbeln = <lfs_bb_stg>-vbeln_s
                                      posnr = <lfs_bb_stg>-posnr_s
                                      BINARY SEARCH.
      IF sy-subrc = 0.
*       Remove billing block for selected items
        lw_orditmin-itm_number   = <lfs_salesitm>-posnr.
        CLEAR lw_orditmin-bill_block.

        APPEND lw_orditmin TO lt_orditmin.

*       Check the checkboxes for fields to be updated
        lw_orditminx-itm_number  = <lfs_salesitm>-posnr.
        lw_orditminx-updateflag  = 'U'.
        lw_orditminx-bill_block  = 'X'.

        APPEND lw_orditminx TO lt_orditminx.
      ENDIF. " IF sy-subrc = 0



      CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
        EXPORTING
          salesdocument         = lv_slsorder
*         order_header_in       = lw_ordhdrin
          order_header_inx      = lw_ordhdrinx
          simulation            = lv_simulate
*         BEHAVE_WHEN_ERROR     = ' '
*         INT_NUMBER_ASSIGNMENT = ' '
*         LOGIC_SWITCH          =
*         NO_STATUS_BUF_INIT    = ' '
        TABLES
          return                = lt_return
          order_item_in         = lt_orditmin
          order_item_inx        = lt_orditminx
*         PARTNERS              =
*         PARTNERCHANGES        =
*         PARTNERADDRESSES      =
*         ORDER_CFGS_REF        =
*         ORDER_CFGS_INST       =
*         ORDER_CFGS_PART_OF    =
*         ORDER_CFGS_VALUE      =
*         ORDER_CFGS_BLOB       =
*         ORDER_CFGS_VK         =
*         ORDER_CFGS_REFINST    =
*         SCHEDULE_LINES        =
*         SCHEDULE_LINESX       =
*         ORDER_TEXT            =
*         ORDER_KEYS            =
*         CONDITIONS_IN         =
*         CONDITIONS_INX        =
*         EXTENSIONIN           =
        .
*     Update ZOTC_BILLBACK table with open qty and settled qty if sales order block is removed
      READ TABLE lt_return ASSIGNING <lfs_return> WITH KEY type = 'E'. " Return assigning of type
      IF sy-subrc = 0.

*      Provide Error message to users
*      BOC ADD ADAS1 D#2490
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        MESSAGE i000(zotc_msg) WITH <lfs_return>-message(50) " & & & &
                                    <lfs_return>-message+50(50)
                                    <lfs_return>-message+100(50)
                                    <lfs_return>-message+150(50)
                DISPLAY LIKE 'E'.
*      EOC ADD ADAS1 D#2490

      ELSE. " ELSE -> IF sy-subrc = 0
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
     EXPORTING
       wait          = 'X'
*         IMPORTING
*           RETURN        =
                  .

        WAIT UP TO 2 SECONDS.
*         Move all successful records into a temp internal table.. only single match records
*         for multiple match records, it may be difficult to track the record that needs to
*         be updated with the invoice document and indicators
        READ TABLE i_billbk_stg ASSIGNING <lfs_billbk_stg>
                                                  WITH KEY <lfs_bb_stg>.
        IF sy-subrc = 0.
          <lfs_billbk_stg>-zzfully_proc = abap_true.
          APPEND <lfs_billbk_stg> TO lt_bb_stg_upd.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc = 0
    ENDLOOP. " LOOP AT i_tmp_bb_stg ASSIGNING <lfs_bb_stg>

*   Update Billback staging table
    IF NOT lt_bb_stg_upd[] IS INITIAL.
      LOOP AT lt_bb_stg_upd ASSIGNING <lfs_billbk_stg>.
        MODIFY zotc_billbk_stg FROM <lfs_billbk_stg>.
      ENDLOOP. " LOOP AT lt_bb_stg_upd ASSIGNING <lfs_billbk_stg>

      FREE lt_bb_stg_upd.
    ENDIF. " IF NOT lt_bb_stg_upd[] IS INITIAL
  ENDIF. " IF lv_confirmed = abap_true OR

* Display ALV
  PERFORM f_alv_table_show USING gv_alv_obj.

ENDFORM. " F_PROCESS_CRDB
*&---------------------------------------------------------------------*
*&      Form  POPUP_CONFIRM
*&---------------------------------------------------------------------*
*       Popup to confirm
*----------------------------------------------------------------------*
FORM popup_confirm   USING  p_str_titel         TYPE c        " Confirm using p_str of type Character
                            p_str_question      TYPE c        " Str_question of type Character
                  CHANGING  p_confirmed         TYPE boolean. " Boolean Variable (X=True, -=False, Space=Unknown)

  DATA: lv_ans(1) TYPE c. " Ans(1) of type Character

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar      = p_str_titel
      text_question = p_str_question
    IMPORTING
      answer        = lv_ans.
  IF lv_ans = '1'.
    p_confirmed = abap_true.
  ELSE. " ELSE -> IF lv_ans = '1'
    p_confirmed = abap_false.
  ENDIF. " IF lv_ans = '1'

ENDFORM. " POPUP_CONFIRM
*&---------------------------------------------------------------------*
*&      Form  F_GET_BILLBACK_DATA
*&---------------------------------------------------------------------*
*       Get Billback data
*----------------------------------------------------------------------*
FORM f_get_billback_data .

*--->Begin of Insert for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016
  TYPES: BEGIN OF lty_fkart,
         sign TYPE char1,   " Sign of type CHAR1
         option TYPE char2, " Option of type CHAR2
         low TYPE fkart,    " Billing Type
         high TYPE fkart,   " Billing Type
         END OF lty_fkart.

  CONSTANTS:    lc_enhancement  TYPE z_enhancement VALUE 'D2_OTC_EDD_0042', " Enhancement Project Definition
                lc_criteria     TYPE z_criteria VALUE 'FKART',              " Enhancement Criteria Definition
                lc_null         TYPE z_criteria VALUE 'NULL',               " Enhancement Criteria Definition
                lc_duration     TYPE z_criteria VALUE 'DURATION'.           " Enh. Criteria
  FIELD-SYMBOLS : <lfs_zdev_emi> TYPE zdev_enh_status,  " Field-symbol for ZDEV_ENH_STATUS
                  <lfs_zdev_emi2> TYPE zdev_enh_status. " Enhancement Status
  DATA :         li_zdev_emi TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0,  " Local internal Table
                 li_zdev_emi2 TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Local internal Table
                 li_fkart TYPE STANDARD TABLE OF lty_fkart INITIAL SIZE 0,           "Local internal table for Billing type
                 lwa_fkart   TYPE lty_fkart.                                         "Local work area for fkart

  CLEAR gv_duration.

  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enhancement
    TABLES
      tt_enh_status     = li_zdev_emi.

  IF sy-subrc IS INITIAL.
    DELETE li_zdev_emi WHERE active <> abap_true.
    SORT li_zdev_emi BY criteria.
    li_zdev_emi2[] = li_zdev_emi[].
**To fetch billing type from EMI table
    READ TABLE li_zdev_emi ASSIGNING <lfs_zdev_emi>
                           WITH KEY criteria = lc_null
                           BINARY SEARCH.
    IF sy-subrc IS INITIAL.

      UNASSIGN: <lfs_zdev_emi>.
      DELETE li_zdev_emi WHERE criteria <> lc_criteria.
      IF li_zdev_emi IS NOT INITIAL.
        LOOP AT li_zdev_emi ASSIGNING <lfs_zdev_emi>.
          lwa_fkart-sign =   <lfs_zdev_emi>-sel_sign.
          lwa_fkart-option = <lfs_zdev_emi>-sel_option.
          lwa_fkart-low =    <lfs_zdev_emi>-sel_low.
          lwa_fkart-high =   <lfs_zdev_emi>-sel_high.
          APPEND lwa_fkart TO li_fkart.
          CLEAR lwa_fkart.

        ENDLOOP. " LOOP AT li_zdev_emi ASSIGNING <lfs_zdev_emi>
      ENDIF. " IF li_zdev_emi IS NOT INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
**To fetch duration from EMI for Billing Date
    SORT li_zdev_emi2 BY criteria.
    READ TABLE li_zdev_emi2 ASSIGNING <lfs_zdev_emi2>
                            WITH KEY criteria = lc_null
                            BINARY SEARCH.
    IF sy-subrc IS INITIAL.

      UNASSIGN: <lfs_zdev_emi2>.
      DELETE li_zdev_emi2 WHERE criteria <> lc_duration.
      IF li_zdev_emi2 IS NOT INITIAL.
        READ TABLE li_zdev_emi2 ASSIGNING <lfs_zdev_emi2> INDEX 1.

        IF sy-subrc IS INITIAL.
          gv_duration = <lfs_zdev_emi2>-sel_low.
        ENDIF. " IF sy-subrc IS INITIAL

      ENDIF. " IF li_zdev_emi2 IS NOT INITIAL
    ENDIF. " IF sy-subrc IS INITIAL

  ENDIF. " IF sy-subrc IS INITIAL

*<---End of Insert for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016

  IF NOT i_tmp_bb_stg[] IS INITIAL.
    SELECT *
      INTO TABLE i_ord_data
      FROM zotc_billback " BillBack Process Control Table
      FOR ALL ENTRIES IN i_tmp_bb_stg
      WHERE matnr = i_tmp_bb_stg-matnr
        AND vkorg = i_tmp_bb_stg-vkorg
        AND vtweg = i_tmp_bb_stg-vtweg
        AND kunag = i_tmp_bb_stg-kunag
        AND kunnr = i_tmp_bb_stg-kunwe
                         " check if ZOTC_BILLBACK stores ship-to in this field??
        AND bstdk = i_tmp_bb_stg-bstdk
*--->Begin of Insert for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016
*It will fetch records only if the billing type is 'ZF2' maintained in EMI entry
        AND fkart IN li_fkart. "Billing type from EMI entry

    SORT i_ord_data BY fkdat DESCENDING.
*<---End of Insert for D2_OTC_EDD_0042 Defect# 1910 by AMOHAPA on 08-Aug-2016
    " check if this field can be used for lookup.. will know during
    " testing. depends on edi867 data
*      and bstdk_e ??  check if this field can be used for lookup..
 "will know during testing. depends on edi 867 data
    IF sy-subrc = 0.
***--> Begin of Insert for OTC_EDD_0042 Hanatization by APODDAR
      IF i_ord_data IS NOT INITIAL.
***<-- End of Insert for OTC_EDD_0042 Hanatization by APODDAR
      SELECT *
        INTO TABLE i_gpo_ident
        FROM tvv1t " Customer group 1: Description
        FOR ALL ENTRIES IN i_ord_data
        WHERE spras = sy-langu
          AND kvgr1 = i_ord_data-kvgr1.
      IF sy-subrc = 0.
        SORT i_gpo_ident BY spras kvgr1.
      ENDIF. " IF sy-subrc = 0
***--> Begin of Insert for OTC_EDD_0042 Hanatization by APODDAR
      ENDIF.
***<-- End of Insert for OTC_EDD_0042 Hanatization by APODDAR
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF NOT i_tmp_bb_stg[] IS INITIAL

ENDFORM. " F_GET_BILLBACK_DATA
