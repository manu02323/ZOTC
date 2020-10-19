*&---------------------------------------------------------------------*
*&  Include           ZOTCN0101B_PRICE_DATE_UPD_SUB
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0101O_PRICE_DATE_UPD_SUB                          *
* TITLE      :  Pricing Date Update Report                             *
* DEVELOPER  :  ROHIT VERMA                                            *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_EDD_0101_Pricing Date Update                       *
*----------------------------------------------------------------------*
* DESCRIPTION: This is an include program of Report                    *
*              ZOTCR0101O_PRICE_DATE_UPD. All subroutines for this     *
*              report is written in this include program.              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 03-Oct-2013 RVERMA   E1DK913507 INITIAL DEVELOPMENT - CR#649         *
*09-Aug-2018  AMOHAPA E1DK930340  Defect#3400(Part 2):                 *
*                                 Later taged with Defect#7955         *
*                                 1)Program to be *
*                                 made to process D3 sales organization*
*                                 records with different logic from    *
*                                 existing program                     *
*                                 2) Output of Batchjob to be import   *
*                                    in an excel sheet                 *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_DATA
*&---------------------------------------------------------------------*
*       Subroutine to split data S_DATA into table I_VBKD
*----------------------------------------------------------------------*
*      <--FP_I_VBKD  SO Business data table
*----------------------------------------------------------------------*
FORM f_split_data CHANGING fp_i_vbkd TYPE ty_t_vbkd.

  DATA:
    lwa_data LIKE LINE OF s_data, "Data workarea
    lwa_vbkd TYPE ty_vbkd.        "SO Business data workarea

*&--Process on each record of S_DATA and populate SO business data tab
  LOOP AT s_data INTO lwa_data.

*&--Split data string to VBELN POSNR PRSDT EDATU
    SPLIT lwa_data-low AT c_hash INTO lwa_vbkd-vbeln
                                      lwa_vbkd-posnr
                                      lwa_vbkd-prsdt
                                      lwa_vbkd-edatu.

*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
 "To distinguish the Radio button selected in the driver program
 "populating the flag for that
    IF lwa_data-high IS NOT INITIAL.
      gv_flag = abap_true.
    ENDIF. " IF lwa_data-high IS NOT INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018

    APPEND lwa_vbkd TO fp_i_vbkd.
    CLEAR: lwa_vbkd,
           lwa_data.
  ENDLOOP. " LOOP AT s_data INTO lwa_data

  SORT fp_i_vbkd BY vbeln posnr.

ENDFORM. " F_SPLIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_PRICE_DATE
*&---------------------------------------------------------------------*
*       Subroutine to update Pricing Date of Sales Order Items
*----------------------------------------------------------------------*
*      -->FP_I_VBKD  SO Business Data Table
*      <--FP_I_LOG   Log Table
*----------------------------------------------------------------------*

FORM f_update_price_date USING fp_i_vbkd  TYPE ty_t_vbkd
                      CHANGING fp_i_log   TYPE ty_t_log
                               fp_count_e TYPE int4  " Natural Number
                               fp_count_s TYPE int4. " Natural Number

  DATA:
    li_vbeln    TYPE ty_t_vbkd, "Order Number Table
    li_log      TYPE ty_t_log,  "Log Table
    lwa_log     TYPE ty_log,    "Log Workarea
    lv_index    TYPE sytabix,   "Index
    lv_date_old TYPE char10,    "Old Date / Current Pricing Date
    lv_date_new TYPE char10,    "New Date / Current First Delivery Date

*&--BAPI Declaration
    lx_headerx  TYPE bapisdh1x,                    "Order Header Checklist
    li_item     TYPE STANDARD TABLE OF bapisditm,  "Sales Order Items
    lwa_item    TYPE bapisditm,                    "Sales Order Items
    li_itemx    TYPE STANDARD TABLE OF bapisditmx, "Sales Order Items Checklist
    lwa_itemx   TYPE bapisditmx,                   "Sales Order Items Checklist
    li_return   TYPE bapiret2_tt.                  "Retrun Table

  FIELD-SYMBOLS:
    <lfs_vbkd>   TYPE ty_vbkd, "SO Business Data
    <lfs_vbeln>  TYPE ty_vbkd. "Order Data

*&--Copy SO data
  li_vbeln[] = fp_i_vbkd[].
*&--Sort & Delete duplicates based on Order Number
  SORT li_vbeln BY vbeln.
  DELETE ADJACENT DUPLICATES FROM li_vbeln
                        COMPARING vbeln.

*&--Process on each Order Number
  LOOP AT li_vbeln ASSIGNING <lfs_vbeln>.

*&--Assign Order header List Update Flag with 'U'
    lx_headerx-updateflag = c_updt.

*&--Read So Business data to get current and new Pricing date
    READ TABLE fp_i_vbkd TRANSPORTING NO FIELDS
                         WITH KEY vbeln = <lfs_vbeln>-vbeln
                         BINARY SEARCH.
    IF sy-subrc EQ 0.
      lv_index = sy-tabix.

*&--Process on each line item and populate Items Details in
*&--BAPI Item Table
      LOOP AT fp_i_vbkd ASSIGNING <lfs_vbkd> FROM lv_index.
        IF <lfs_vbeln>-vbeln NE <lfs_vbkd>-vbeln.
          EXIT.
        ENDIF. " IF <lfs_vbeln>-vbeln NE <lfs_vbkd>-vbeln

        lwa_log-vbeln = <lfs_vbkd>-vbeln.
        lwa_log-posnr = <lfs_vbkd>-posnr.

        WRITE <lfs_vbkd>-prsdt TO lv_date_old.
        WRITE <lfs_vbkd>-edatu TO lv_date_new.
        MESSAGE i905 WITH lv_date_old lv_date_new
                     INTO lwa_log-msg.

        APPEND lwa_log TO li_log.
        CLEAR: lwa_log,
               lv_date_old,
               lv_date_new.

        lwa_item-itm_number = <lfs_vbkd>-posnr.
        lwa_item-price_date = <lfs_vbkd>-edatu.
        APPEND lwa_item TO li_item.
        CLEAR lwa_item.

        lwa_itemx-itm_number = <lfs_vbkd>-posnr.
        lwa_itemx-updateflag = c_updt.
        lwa_itemx-price_date = abap_true.
        APPEND lwa_itemx TO li_itemx.
        CLEAR lwa_itemx.
      ENDLOOP. " LOOP AT fp_i_vbkd ASSIGNING <lfs_vbkd> FROM lv_index
    ENDIF. " IF sy-subrc EQ 0

*&--Call BAPI to Update Sales Order
    CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
      EXPORTING
        salesdocument    = <lfs_vbeln>-vbeln
        order_header_inx = lx_headerx
      TABLES
        return           = li_return
        order_item_in    = li_item
        order_item_inx   = li_itemx.

    SORT li_return BY type.

    READ TABLE li_return TRANSPORTING NO FIELDS
                         WITH KEY type = c_msg_e " With key of type
                         BINARY SEARCH.
    IF sy-subrc EQ 0.
*&--Call BAPI to Rollback
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*&--Create Log Table for Error Records
      PERFORM f_create_log_table USING c_msg_e
                                       li_return
                              CHANGING li_log
                                       fp_count_e
                                       fp_count_s.

      APPEND LINES OF li_log TO fp_i_log.
    ELSE. " ELSE -> IF sy-subrc EQ 0
*&--Call BAPI to Commit
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
*&--Create Log Table for Success Records
      PERFORM f_create_log_table USING ''
                                       li_return
                              CHANGING li_log
                                       fp_count_e
                                       fp_count_s.

      APPEND LINES OF li_log TO fp_i_log.
    ENDIF. " IF sy-subrc EQ 0

    REFRESH: li_item,
             li_itemx,
             li_log,
             li_return.
  ENDLOOP. " LOOP AT li_vbeln ASSIGNING <lfs_vbeln>

  SORT fp_i_log BY type
                   vbeln
                   posnr.

ENDFORM. " F_UPDATE_PRICE_DATE

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_LOG_TABLE
*&---------------------------------------------------------------------*
*       Build Log Table
*----------------------------------------------------------------------*
*      -->FP_MSG_TYPE  Message Type
*      -->FP_I_RETURN  Return Table
*      -->FP_I_LOG     Log Table
*----------------------------------------------------------------------*
FORM f_create_log_table USING fp_msg_type TYPE char1
                              fp_i_return TYPE bapiret2_tt
                     CHANGING fp_i_log    TYPE ty_t_log
                              fp_count_e  TYPE int4  " Natural Number
                              fp_count_s  TYPE int4. " Natural Number

  FIELD-SYMBOLS:
    <lfs_return> TYPE bapiret2, "Return Data
    <lfs_log>    TYPE ty_log.   "Log Data

*&--Process on records of log table to modify with message type, icon, text
  LOOP AT fp_i_log ASSIGNING <lfs_log>.
    IF fp_msg_type EQ c_msg_e.
*&--Populating Message Type = 'E' Error
      <lfs_log>-type = c_msg_e.

      READ TABLE fp_i_return ASSIGNING <lfs_return>
                             WITH KEY type = c_msg_e " With key of type
                             BINARY SEARCH.
      IF sy-subrc EQ 0 AND <lfs_return> IS ASSIGNED.
        <lfs_log>-msg = <lfs_return>-message.
      ELSE. " ELSE -> IF sy-subrc EQ 0 AND <lfs_return> IS ASSIGNED
        MESSAGE i904 INTO <lfs_log>-msg.
      ENDIF. " IF sy-subrc EQ 0 AND <lfs_return> IS ASSIGNED
*&--Populating Red Light of Message
      WRITE icon_red_light AS ICON TO <lfs_log>-icon.
*&--Increamenting Error Count
      fp_count_e = fp_count_e + 1.
    ELSE. " ELSE -> IF fp_msg_type EQ c_msg_e
*&--Populating Message Type = 'S' Success
      <lfs_log>-type = c_msg_s.
*&--Populating Green Light of Message
      WRITE icon_green_light AS ICON TO <lfs_log>-icon.
*&--Incrementing Success Count
      fp_count_s = fp_count_s + 1.
    ENDIF. " IF fp_msg_type EQ c_msg_e
  ENDLOOP. " LOOP AT fp_i_log ASSIGNING <lfs_log>

ENDFORM. " F_CREATE_LOG_TABLE
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_LOG
*&---------------------------------------------------------------------*
*       Display Log Report
*----------------------------------------------------------------------*
*      -->FP_I_LOG  Log Table
*----------------------------------------------------------------------*
FORM f_display_log USING fp_i_log   TYPE ty_t_log
                         fp_count_e TYPE int4  " Natural Number
                         fp_count_s TYPE int4. " Natural Number

  FIELD-SYMBOLS:
    <lfs_log> TYPE ty_log. "Log Data

  FORMAT INTENSIFIED OFF.

  WRITE:/2(262) sy-uline.

*&--Printing Top-Of-Page Data
  WRITE:/2(30) 'Pricing Date Update Report Log'(002) COLOR 1.

  SKIP.

  WRITE:/2(25) 'Printed On'(003),
         27(12) sy-datum,
         39(12) sy-uzeit.

  WRITE:/2(25) 'Requestor'(004),
        27(25) sy-uname.

  WRITE:/2(25) 'No of Error Records'(005),
        27(25) fp_count_e LEFT-JUSTIFIED.

  WRITE:/2(25) 'No of Success Records'(006),
        27(25) fp_count_s LEFT-JUSTIFIED.

  WRITE:/2(262) sy-uline.

*&--Printing Table Headings
  WRITE:/2(5)    'Type'(007)             COLOR 1,
         8(16)   'Sales Doc Number'(008) COLOR 1,
         25(16)  'Line Item Number'(009) COLOR 1,
         42(220) 'Message Text'(010)     COLOR 1.

  WRITE:/2(262) sy-uline.

*&--Printing Log Data
  LOOP AT fp_i_log ASSIGNING <lfs_log>.
    WRITE:/2(5)    <lfs_log>-icon AS ICON,
           8(16)   <lfs_log>-vbeln    ,
           25(16)  <lfs_log>-posnr    ,
           42(220) <lfs_log>-msg      .
  ENDLOOP. " LOOP AT fp_i_log ASSIGNING <lfs_log>

  WRITE:/2(262) sy-uline.

ENDFORM. " F_DISPLAY_LOG

*-->Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_FIELDCATALOG
*&---------------------------------------------------------------------*
*       Prepare the Fieldcatalog
*----------------------------------------------------------------------*
*      <--FP_I_FIELDCAT  internal table for Fieldcatalog
*----------------------------------------------------------------------*
FORM f_populate_fieldcatalog  CHANGING fp_i_fieldcat TYPE slis_t_fieldcat_alv.

  PERFORM f_populate_fieldcat USING:
          'VBELN' 'I_LOG_D3' 'Order No'(117)              CHANGING fp_i_fieldcat,
          'POSNR' 'I_LOG_D3' 'Item Position Number'(118)  CHANGING fp_i_fieldcat,
          'MSG'   'I_LOG_D3' 'Pricing Date Info'(119)     CHANGING fp_i_fieldcat.

ENDFORM. " F_POPULATE_FIELDCATALOG

*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_FIELDCAT
*&---------------------------------------------------------------------*
*       Form to populate field Catalog
*----------------------------------------------------------------------*
*  -->  fp_fnam          Field Name                                    *
*  -->  fp_itab          Table Name                                    *
*  -->  fp_descr         Field Description                             *
*  <--  fp_i_fieldcat    Internal Table for Field Catalog              *
*----------------------------------------------------------------------*
FORM f_populate_fieldcat  USING   fp_fnam       TYPE slis_fieldname       "fieldname
                                  fp_itab       TYPE slis_tabname         "table name
                                  fp_descr      TYPE scrtext_l            "field description
                        CHANGING  fp_i_fieldcat TYPE slis_t_fieldcat_alv. "Internal Table for Field Catalog

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
*&      Form  F_POPULATE_AL_DISPLAY
*&---------------------------------------------------------------------*
*       Populating the final log table in ALV
*----------------------------------------------------------------------*
*      -->FP_I_LOG_D3  text
*      -->P_I_FIELDCAT  text
*----------------------------------------------------------------------*
FORM f_populate_alv_display  USING    fp_i_fieldcat TYPE slis_t_fieldcat_alv
                                      fp_i_log      TYPE ty_t_log
                                      fp_i_log_d3   TYPE ty_t_logd3.

  DATA: lwa_log    TYPE ty_log,
        lwa_log_d3 TYPE ty_log_d3,
        lwa_layo   TYPE slis_layout_alv. "work area

  CONSTANTS:  lc_a TYPE char1 VALUE 'A'. " A of type CHAR1

  LOOP AT fp_i_log INTO lwa_log.

    lwa_log_d3-vbeln = lwa_log-vbeln.
    lwa_log_d3-posnr = lwa_log-posnr.
    lwa_log_d3-msg   = lwa_log-msg.

    APPEND lwa_log_d3 TO fp_i_log_d3.
    CLEAR: lwa_log_d3,
            lwa_log.

  ENDLOOP. " LOOP AT fp_i_log INTO lwa_log

  IF fp_i_log_d3 IS NOT INITIAL.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program = sy-repid
        is_layout          = lwa_layo
        it_fieldcat        = fp_i_fieldcat
        i_save             = lc_a
      TABLES
        t_outtab           = fp_i_log_d3
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF sy-subrc <> 0

  ENDIF. " IF fp_i_log_d3 IS NOT INITIAL


ENDFORM. " F_POPULATE_AL_DISPLAY
*<--End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
