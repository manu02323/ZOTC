************************************************************************
* PROGRAM    :  ZOTCR0347O_STANDING_ORDERS                             *
* TITLE      :  D3_OTC_EDD_0347_Upload Standing Orders                 *
* DEVELOPER  :  Debasish Maiti / Bijayeeta Banerjee                    *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_EDD_0347                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: Upload Standing Orders                                  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 15.06.2016  BBANERJ   E1DK919242  Initial Development                *
*&---------------------------------------------------------------------*
* 27.07.2016  U034088   E1DK919242  Defect# 2741: Change output Layout *
*&---------------------------------------------------------------------*
* 30.08.2016  U029382/  E1DK919242  CR# 3502:  Add distribution channel*
*             U034088               from CSV sheet and Wrong sorting of*
*                                   of line items                      *
*&---------------------------------------------------------------------*
* 19.09.2016  U034088  E1DK919242  CR# 3502_PART2, The file separator  *
*                                  May be Comma or Colon. Need to      *
*                                  both.                               *
*&---------------------------------------------------------------------*
* 03.11.2016 APAUL    E1DK919242  CR#227, This change is dependendant  *
*                                 on the class zotc_cl_inb_so_edi_850  *
*                                 and corresponding EMI.  Implement the*
*                                 logic for split of LRD and Non-LRD as*
*                                 developed in D3_OTC_EDD-0362 to      *
*                                 populate Sales Organisation data.    *
*                                 Field Sales Organsiation  is not     *
*                                 needed  from  input file.            *
*&---------------------------------------------------------------------*
* 02.01.2017 APAUL    E1DK919242  Defect#7913, Implement the logic of  *
*                                  populating Contract as reference    *
*                                  document and link it to Sales order *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* 02.18.2017 U033876  E1DK919242  Defect#9812, issue with not calling  *
*                                 exceptions when using raising option *
*                                 in a clas  *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* 03.01.2017 U033867  E1DK926115  CR# 378:Add sales office in selection
*                                 screen
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* 04.07.2017 U033814  E1DK926790  Def# 2455: Batch Validation
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           ZOTCN0347O_STANDING_ORDERS_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_FILE
*&---------------------------------------------------------------------*
*       Upload the file from Presentation Server
*----------------------------------------------------------------------*
*      --> fp_p_file filename
*----------------------------------------------------------------------*

FORM f_upload_pres  USING   fp_p_file TYPE localfile. " Local file for upload/download
*Local type Declaration
  TYPES : BEGIN OF lty_string ,
          string TYPE string,
          END OF lty_string.
* Local Data Declaration
  DATA:   lv_msg          TYPE string,    "  local variable declaration for message
          lv_filename     TYPE string,    "  local variale declaration for file name
          lv_codepage TYPE abap_encoding, "code page
          lv_lineno TYPE index,           " Index of the record
          lv_index TYPE index,            " Index of the invalid recorde Translate
          li_string       TYPE STANDARD TABLE OF lty_string,
          lwa_string      TYPE lty_string,
          lwa_leg_tab_c   TYPE ty_leg_tab_c,
          lwa_kunnr_leg TYPE ty_kunnr_leg.
* Local Constant Declaration
  CONSTANTS: lc_file_type  TYPE char10 VALUE 'ASC', " ASC
             lc_ele       TYPE num2 VALUE '11',     " Number 11
             lc_twe       TYPE num2 VALUE '12',     " Number 12
             lc_thi       TYPE num2 VALUE '13',     " Number 13
             lc_for       TYPE num2 VALUE '14',     " Number 14
             lc_fif       TYPE num2 VALUE '15',     " Number 15
             lc_six       TYPE num2 VALUE '16',     " Number 16
             lc_sev       TYPE num2 VALUE '17',     " Number 17
             lc_eig       TYPE num2 VALUE '18',     " Number 18
             lc_nin       TYPE num2 VALUE '19'.     " Number 19


  CLEAR: lv_lineno,
         gv_header.

* presentation server
  IF rb_pres = c_selected .
    lv_filename = fp_p_file.
    IF gv_codepage IS NOT INITIAL.
      lv_codepage = gv_codepage.
    ELSE. " ELSE -> IF gv_codepage IS NOT INITIAL
      lv_codepage = space.
    ENDIF. " IF gv_codepage IS NOT INITIAL

    CALL METHOD cl_gui_frontend_services=>gui_upload
      EXPORTING
        filename                = lv_filename
        filetype                = lc_file_type
        codepage                = lv_codepage
      CHANGING
        data_tab                = li_string
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = lc_ele
        unknown_dp_error        = lc_twe
        access_denied           = lc_thi
        dp_out_of_memory        = lc_for
        disk_full               = lc_fif
        dp_timeout              = lc_six
        not_supported_by_gui    = lc_sev
        error_no_gui            = lc_eig
        OTHERS                  = lc_nin.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid
      TYPE sy-msgty
      NUMBER sy-msgno INTO lv_msg
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      WRITE: / lv_msg,
              ':',
              lv_filename.
    ELSE. " ELSE -> IF sy-subrc <> 0

      LOOP AT li_string
        INTO lwa_string.
        lv_index = sy-tabix .
*---> Begin of Insert for CR# 3502 by U034088 on 19.09.2016
* Dynamically determine whether the file is comma or colon separator
* In case of it is colon Separator the first line itself contains the Colon

        IF lv_index = 1.
          CLEAR : gv_sep.
          IF lwa_string-string CS c_colon.
            gv_sep = c_colon. " Colon for German and Spain
          ELSE. " ELSE -> IF lwa_string-string CS c_colon
            gv_sep = c_sep. " Comma as default separator
          ENDIF. " IF lwa_string-string CS c_colon
        ENDIF. " IF lv_index = 1
*<--- End of Insert for CR# 3502 by U034088 on 19.09.2016

        CLEAR lwa_leg_tab_c.
        SPLIT lwa_string-string
*---> Begin of Insert for CR# 3502 by U034088 on 19.09.2016
        AT gv_sep " Gv_sep may be comma or colon , as determined dynamically
*<--- End of Insert for CR# 3502 by U034088 on 19.09.2016
*---> Begin of delete for CR# 3502 by U034088 on 19.09.2016
*        AT c_sep
*<--- End of delete for CR# 3502 by U034088 on 19.09.2016
        INTO
               lwa_leg_tab_c-auart
* <--- Begin of  Delete for CR#D3_227 by  APAUL
* Sales organisation not needed in input file
*               lwa_leg_tab_c-vkorg
* <--- End of   Delete for CR#D3_227 by  APAUL
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
                lwa_leg_tab_c-vtweg
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016
               lwa_leg_tab_c-parvw_sp
               lwa_leg_tab_c-kunnr_sp
               lwa_leg_tab_c-parvw_sh
               lwa_leg_tab_c-kunnr_sh
               lwa_leg_tab_c-bstnk
               lwa_leg_tab_c-bstdk_c
               lwa_leg_tab_c-bsark
               lwa_leg_tab_c-parvw_cp
               lwa_leg_tab_c-kunnr_cp
               lwa_leg_tab_c-name1
               lwa_leg_tab_c-email
               lwa_leg_tab_c-tele1
               lwa_leg_tab_c-textid
               lwa_leg_tab_c-text
               lwa_leg_tab_c-textid_2
               lwa_leg_tab_c-text_2
               lwa_leg_tab_c-lifsk
               lwa_leg_tab_c-matnr
               lwa_leg_tab_c-kwmeng
               lwa_leg_tab_c-charg
               lwa_leg_tab_c-etdat_c.

* Append the Header Line
        IF lv_index = 1.
          CONTINUE.
        ENDIF. " IF lv_index = 1

*Performing the Field converssion
        PERFORM f_field_converssion CHANGING lwa_leg_tab_c.

        lv_lineno = lv_lineno + 1.
        lwa_leg_tab_c-lineno = lv_lineno.

* <--- Begin of  Insert for CR#D3_227 by  APAUL
* Determine the  Sales organsition  based on material  and customer
        PERFORM f_split_lord USING  lwa_leg_tab_c-matnr
                                    lwa_leg_tab_c-kunnr_sp
                                    lwa_leg_tab_c-vkorg
* Begin of Defect - 10523
                                    lwa_leg_tab_c-msgtyp
                                    lwa_leg_tab_c-error.
* End of Defect - 10523
* <--- End  of  Insert for CR#D3_227 by  APAUL

        APPEND lwa_leg_tab_c TO i_leg_tab_c.
        CLEAR : lwa_kunnr_leg.


*        Populating another table for checking Kunnr
        lwa_kunnr_leg-vkorg = lwa_leg_tab_c-vkorg. " sales org

        lwa_kunnr_leg-kunnr = lwa_leg_tab_c-kunnr_sp.
        APPEND lwa_kunnr_leg TO i_kunnr_leg.
        lwa_kunnr_leg-kunnr = lwa_leg_tab_c-kunnr_sh.
        APPEND lwa_kunnr_leg TO i_kunnr_leg.

      ENDLOOP. " LOOP AT li_string

    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF rb_pres = c_selected
  CLEAR :   lv_msg,
            lv_filename,
            lv_codepage,
            lv_lineno ,
            lv_index ,
            li_string,
            lwa_string,
            lwa_leg_tab_c.
ENDFORM. " F_UPLOAD_FILE


*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_APPS
*&---------------------------------------------------------------------*
*       Upload file from Application server
*----------------------------------------------------------------------*
*      -->P_GV_FILE  text
*----------------------------------------------------------------------*
FORM f_upload_apps  USING  fp_p_file TYPE localfile. " Local file for upload/download

* Local constants
  CONSTANTS: lc_activity  TYPE char5  VALUE 'READ'. "File activity read/write
* Local Data Declaration
  DATA:   lv_msg          TYPE string,  "#EC NEEDED   " Message
          lv_flag         TYPE flag,    "General Flag
          lv_subrc        TYPE sysubrc, " Return Value of ABAP Statements
          lv_lineno       TYPE index,   " Index of the record
          lv_input_line   TYPE string,  "Input Raw lines
          lv_index TYPE index,          " Index of the invalid record
          lwa_leg_tab_c   TYPE ty_leg_tab_c,
          lwa_kunnr_leg TYPE ty_kunnr_leg.


  PERFORM f_authorization_check USING fp_p_file
                                      lc_activity
                             CHANGING lv_flag.
  IF lv_flag IS INITIAL.
 "---Authorized
    CLEAR: lv_msg,
           lv_lineno.
    CALL METHOD zdev_cl_abap_file_utilities=>meth_stat_pub_open_dataset
      EXPORTING
        im_file     = fp_p_file
        im_codepage = gv_codepage
      IMPORTING
        ex_subrc    = lv_subrc
        ex_message  = lv_msg.

    IF lv_subrc IS NOT INITIAL OR lv_msg IS NOT INITIAL.
      MESSAGE i967 WITH fp_p_file. "Error in opening the file.'
      LEAVE LIST-PROCESSING.
    ELSE. " ELSE -> IF lv_subrc IS NOT INITIAL OR lv_msg IS NOT INITIAL
      WHILE ( lv_subrc EQ 0 ).

        lv_index = sy-index.

        READ DATASET fp_p_file INTO lv_input_line.
        lv_subrc = sy-subrc.
        IF lv_subrc = 0.
*---> Begin of Insert for CR# 3502 by U034088 on 19.09.2016
* Dynamically determine whether the file is comma or colon separator
* In case of it is colon Separator the first line itself contains the Colon

          IF lv_index = 1.
            CLEAR : gv_sep.
            IF lv_input_line CS c_colon.
              gv_sep = c_colon. " Colon for German and Spain
            ELSE. " ELSE -> IF lv_input_line CS c_colon
              gv_sep = c_sep. " Comma as default separator
            ENDIF. " IF lv_input_line CS c_colon
          ENDIF. " IF lv_index = 1
*<--- End of Insert for CR# 3502 by U034088 on 19.09.2016

          SPLIT lv_input_line
*---> Begin of Insert for CR# 3502 by U034088 on 19.09.2016
          AT gv_sep " Gv_sep may be comma or colon , as determined dynamically
*<--- End of Insert for CR# 3502 by U034088 on 19.09.2016
*---> Begin of delete for CR# 3502 by U034088 on 19.09.2016
*        AT c_sep
*<--- End of delete for CR# 3502 by U034088 on 19.09.2016
          INTO
               lwa_leg_tab_c-auart
* <--- Begin of  Delete for CR#D3_227 by  APAUL
* Sales organisation not needed in input file
*               lwa_leg_tab_c-vkorg
* <--- End of  Delete for CR#D3_227 by  APAUL

*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
                lwa_leg_tab_c-vtweg
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016
               lwa_leg_tab_c-parvw_sp
               lwa_leg_tab_c-kunnr_sp
               lwa_leg_tab_c-parvw_sh
               lwa_leg_tab_c-kunnr_sh
               lwa_leg_tab_c-bstnk
               lwa_leg_tab_c-bstdk_c
               lwa_leg_tab_c-bsark
               lwa_leg_tab_c-parvw_cp
               lwa_leg_tab_c-kunnr_cp
               lwa_leg_tab_c-name1
               lwa_leg_tab_c-email
               lwa_leg_tab_c-tele1
               lwa_leg_tab_c-textid
               lwa_leg_tab_c-text
               lwa_leg_tab_c-textid_2
               lwa_leg_tab_c-text_2
               lwa_leg_tab_c-lifsk
               lwa_leg_tab_c-matnr
               lwa_leg_tab_c-kwmeng
               lwa_leg_tab_c-charg
               lwa_leg_tab_c-etdat_c.

* Append the Header
          IF lv_index = 1.
** Header String for Error fileheader
            gv_header = lv_input_line.
            CONTINUE.
          ENDIF. " IF lv_index = 1

*Performing the Field converssion
          PERFORM f_field_converssion CHANGING lwa_leg_tab_c.

          lv_lineno = lv_lineno + 1.
          lwa_leg_tab_c-lineno = lv_lineno.


* <--- Begin of  Insert for CR#D3_227 by  APAUL
* Determine the  Sales organsition  based on material  and customer
          PERFORM f_split_lord USING  lwa_leg_tab_c-matnr
                                      lwa_leg_tab_c-kunnr_sp
                                      lwa_leg_tab_c-vkorg
* Begin of Defect - 10523
                                    lwa_leg_tab_c-msgtyp
                                    lwa_leg_tab_c-error.
* End of Defect - 10523

* <--- End  of  Insert for CR#D3_227 by  APAUL


          APPEND lwa_leg_tab_c TO i_leg_tab_c.

          CLEAR : lwa_kunnr_leg.
*        Populating another table for checking Kunnr
          lwa_kunnr_leg-vkorg = lwa_leg_tab_c-vkorg. " sales org

          lwa_kunnr_leg-kunnr = lwa_leg_tab_c-kunnr_sp.
          APPEND lwa_kunnr_leg TO i_kunnr_leg.
          lwa_kunnr_leg-kunnr = lwa_leg_tab_c-kunnr_sh.
          APPEND lwa_kunnr_leg TO i_kunnr_leg.

          CLEAR: lv_input_line.
        ENDIF. " IF lv_subrc = 0
      ENDWHILE.
    ENDIF. " IF lv_subrc IS NOT INITIAL OR lv_msg IS NOT INITIAL
    CLOSE DATASET fp_p_file.

  ELSE. " ELSE -> IF lv_flag IS INITIAL
                                 "Not Authorized
    MESSAGE i950 WITH fp_p_file. "No authorization for access to file &.
    LEAVE LIST-PROCESSING.

  ENDIF. " IF lv_flag IS INITIAL

  CLEAR:
          lv_msg ,
          lv_flag ,
          lv_subrc ,
          lv_lineno ,
          lv_input_line,
          lv_index ,
          lwa_leg_tab_c.
ENDFORM. " F_UPLOAD_APPS


*&---------------------------------------------------------------------*
*&      Form  F_BAPI_POSTING
*&---------------------------------------------------------------------*
*   Calling BAPI to create the consignment fill up order
*----------------------------------------------------------------------*
*      -->FP_I_FINAL              Final table consisting of partner combinations
*      -->FP_I_MATERIAL           Collected material table
*      -->FP_WA_ORDER_HEADER_IN   Header order data
*      <--FP_I_SPOOL              Spool for the LOG
*----------------------------------------------------------------------*
FORM f_bapi_posting  USING fp_i_final            TYPE ty_t_leg_tab_c.

  DATA: li_return         TYPE TABLE OF bapiret2,    " Return Parameter
        li_order_items_in TYPE TABLE OF bapisditm,   " Communication Fields: Sales and Distribution Document Item
        li_order_partner  TYPE TABLE OF bapiparnr,   " Communications Fields: SD Document Partner: WWW
        li_order_schedule TYPE TABLE OF bapischdl,   " Communication Fields for Maintaining SD Doc. Schedule Lines
        li_order_text     TYPE TABLE OF bapisdtext,  " Communication fields: SD texts
        li_temp_item      TYPE   ty_t_leg_tab_c,
        li_order_unic     TYPE   ty_t_leg_tab_c,
        li_leg_temp     TYPE   ty_t_leg_tab_c,
        li_partneraddresses TYPE TABLE OF bapiaddr1, " BAPI Reference Structure for Addresses (Org./Company)
        li_land TYPE STANDARD TABLE OF ty_land,      "Land for sold to party
        lwa_order_items_in  TYPE bapisditm,          " Communication Fields: Sales and Distribution Document Item
        lwa_order_partner   TYPE bapiparnr,          " Communications Fields: SD Document Partner: WWW
        lwa_order_schedule  TYPE bapischdl,          " Communication Fields for Maintaining SD Doc. Schedule Lines
        lwa_order_text      TYPE bapisdtext,         " Communication fields: SD texts
        lwa_final           TYPE ty_leg_tab_c,       " final table
        lwa_temp_item       TYPE ty_leg_tab_c,       " final table
        lwa_order_header_in  TYPE bapisdhd1,         " Communication Fields: Sales and Distribution Document Header
        lwa_partneraddresses TYPE bapiaddr1,         " BAPI Reference Structure for Addresses (Org./Company)
        lwa_return           TYPE bapiret2,          " Return Parameter
        lwa_land             TYPE ty_land,           " Land for sold to party
        lv_index             TYPE index,             " Index of the valid record
        lv_vbeln             TYPE bapivbeln-vbeln,   " Sales Document
        lv_posnr             TYPE posnr_va,          " Sales Document Item
        lv_test              TYPE flag,              " General Flag
        lv_flag              TYPE flag,              " Error or Success flag
        lv_type              TYPE char1,             " type
        lv_bapi_msg          TYPE string.            " Error capture in BAPI
*Field Symbols
  FIELD-SYMBOLS : <lfs_temp_item>           TYPE ty_leg_tab_c. " final table

* Local constants
  CONSTANTS: lc_smsg TYPE char1        VALUE   'S',   " constant declaration for 'S' success message type
             lc_emsg TYPE char1        VALUE   'E',   " constant declaration for 'E' Error message type
             lc_amsg TYPE char1        VALUE   'A',   " constant declaration for 'A' Error message type
             lc_sep  TYPE char1         VALUE    '/'. " Sep of type CHAR1


*---> Begin of Insert for Defect# 7913 by APAUL on 02.01.2017

* Local types
  TYPES: BEGIN OF lty_vbap,
           vbeln TYPE vbeln_va, "Contract no
           posnr TYPE posnr_va, "Contract Item
           abgru TYPE abgru_va, "Reason for Rejection
          END OF lty_vbap.

  TYPES: BEGIN OF lty_trg_typ,
          vkorg TYPE vkorg,         " Sales Organization
          vtweg TYPE vtweg,         " Distribution Channel
          auart TYPE z_mvalue_high, " Select Options: Value High
         END OF  lty_trg_typ .

  TYPES: BEGIN OF lty_item,
           matnr TYPE matnr,                         " Material Number
           vkorg TYPE vkorg,                         " Sales Organization
           vtweg TYPE  vtweg ,                       " Distribution Channel
           auart TYPE auart,                         " Sales Document Type
           kunnr_sp TYPE kunnr,                      " Customer Number
           vbeln TYPE vbeln,                         "Contract no
           posnr TYPE posnr,                         "Contract Item
           datab TYPE datab_vi,                      "Contract valid from
           datbi TYPE datbi_vi,                      "Contract valid to
           kunnr_sh TYPE kunnr,                      " Customer Number
         END OF lty_item,

         lty_t_item TYPE STANDARD TABLE OF lty_item. " local internal table

* Local constants
  CONSTANTS: lc_vbtyp TYPE vbtyp VALUE 'C',                              "Order
             lc_mprogram   TYPE char30  VALUE 'ZIM_OTC_RR_CONTRACT_REF', "Program name
             lc_mparameter TYPE char05  VALUE 'AUART',                   "Parameter KSCHL
             lc_on         TYPE char1   VALUE 'X',                       "Flag ON
             lc_option_eq  TYPE char2  VALUE 'EQ',                       "Option - EQ.
             lc_parvw_we   TYPE parvw  VALUE 'WE',                       "Partner Function Sold-To"CR#1183++
             lc_doc_cat    TYPE vbtyp_v VALUE 'G'.                       " Document category of preceding SD document

* Local internal table / work area
  DATA: li_item                TYPE lty_t_item,
        lwa_item               TYPE listvbap,     " Referenced headers/items
        li_temp_item_1         TYPE ty_t_leg_tab_c    ,
        lwa_trg_typ            TYPE lty_trg_typ , " Document type
        li_trg_typ             TYPE TABLE OF lty_trg_typ  ,
        li_trg_sel             TYPE TABLE OF lty_trg_typ  .



  FIELD-SYMBOLS: <lfs_vbap>    TYPE lty_vbap, " Field symbols
                 <lfs_item>    TYPE lty_item ,
                 <lfs_trg_typ> TYPE lty_trg_typ.

* Local field symbol
  FIELD-SYMBOLS: <lfs_ship_to> TYPE kunwe. " Ship-to party
*---> End of Insert for Defect# 7913 by APAUL on 02.01.2017

  li_leg_temp = fp_i_final.
  SORT li_leg_temp BY kunnr_sp.
  DELETE ADJACENT DUPLICATES FROM li_leg_temp
  COMPARING kunnr_sp.
  IF  li_leg_temp IS NOT INITIAL.

    SELECT kunnr land1
      FROM kna1 " General Data in Customer Master
      INTO TABLE li_land
      FOR ALL ENTRIES IN li_leg_temp
      WHERE kunnr = li_leg_temp-kunnr_sp.
    IF sy-subrc IS INITIAL.
      SORT li_land BY kunnr.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_leg_temp IS NOT INITIAL

  li_order_unic = fp_i_final.
  SORT li_order_unic BY
            auart
            vkorg
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
            vtweg
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016
            parvw_sp
            kunnr_sp
            parvw_sh
            kunnr_sh
            bstnk.
*&--populating the unic sales order header
  DELETE ADJACENT DUPLICATES FROM  li_order_unic
  COMPARING
             auart
             vkorg
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
             vtweg
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016
             parvw_sp
             kunnr_sp
             parvw_sh
             kunnr_sh
             bstnk.

**  In run in test mode
**  BAPI will be run in test Mode
  IF rb_verif EQ abap_true.
    lv_test = abap_true.
  ENDIF. " IF rb_verif EQ abap_true

*&--populating all the data to temp table
  li_temp_item = fp_i_final.
  SORT li_temp_item BY
           auart
           vkorg
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
           vtweg
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016
           parvw_sp
           kunnr_sp
           parvw_sh
           kunnr_sh
           bstnk
*---> Begin of Insert for Def 3502 by U029382 on 30.08.2016
           matnr " Change by RAJENDRA to add Material Sorting for Def 3502
*           etdat_c. " Change by RAJENDRA to add delivery date sorting 3502
*<--- End of Insert for Def 3502 by U029382 on 30.08.2016
           etdat. " Change for Def 3502 by U029382 on 10.13.2016

*---> Begin of Insert for Defect# 7913 by APAUL on 02.01.2017

  CLEAR li_leg_temp .
  li_leg_temp = fp_i_final.

* Populating the driver control table
  LOOP AT  li_leg_temp ASSIGNING <lfs_temp_item> .
    lwa_trg_typ-auart = <lfs_temp_item>-auart .
    lwa_trg_typ-vkorg = <lfs_temp_item>-vkorg .
    lwa_trg_typ-vtweg = <lfs_temp_item>-vtweg .

    APPEND  lwa_trg_typ TO li_trg_sel .
    CLEAR  lwa_trg_typ .
  ENDLOOP. " LOOP AT li_leg_temp ASSIGNING <lfs_temp_item>

  SORT li_trg_sel  BY  auart vkorg vtweg.

  DELETE ADJACENT DUPLICATES FROM li_trg_sel
  COMPARING auart vkorg vtweg .

  IF  li_trg_sel IS NOT INITIAL.

* ====================================================================== *
* search for existing reference documents on database
* ====================================================================== *

    SELECT   vkorg            " Sales Organization
             vtweg            " Distribution Channel
             mvalue2          " Select Options: Value High
      FROM   zotc_prc_control " OTC Process Team Control Table
      INTO   TABLE        li_trg_typ
      FOR ALL ENTRIES IN  li_trg_sel
      WHERE  vkorg      = li_trg_sel-vkorg  AND
             vtweg      = li_trg_sel-vtweg  AND
             mprogram   = lc_mprogram    AND
             mparameter = lc_mparameter  AND
             mactive    = lc_on          AND
             soption    = lc_option_eq   AND
             mvalue1    = li_trg_sel-auart     .

    IF sy-subrc IS INITIAL.
      SORT li_trg_typ BY vkorg vtweg auart  .

      CLEAR li_leg_temp .
      li_leg_temp = fp_i_final.
      SORT li_leg_temp BY  matnr vkorg vtweg kunnr_sp kunnr_sh   .
      DELETE ADJACENT DUPLICATES FROM li_leg_temp
      COMPARING matnr vkorg vtweg kunnr_sp kunnr_sh     .
      IF  li_leg_temp IS NOT INITIAL.

* select respective contract document from database
        SELECT vapma~matnr " Material Number
               vapma~vkorg " Sales Organization
               vapma~vtweg " Distribution Channel
               vapma~auart " Sales Document Type
               vapma~kunnr " Sold-to party
               vapma~vbeln " Sales and Distribution Document Number
               vapma~posnr " Item number of the SD document
               vapma~datab " Quotation or contract valid from
               vapma~datbi " Quotation or contract valid to
               vbpa~kunnr  " Sold-to party
               INTO TABLE li_item
               FROM vapma  " Sales Index: Order Items by Material
               INNER JOIN vbpa ON
               vapma~vbeln = vbpa~vbeln
             FOR ALL ENTRIES IN li_leg_temp
                            WHERE vapma~matnr =  li_leg_temp-matnr AND
                                  vapma~vkorg =  li_leg_temp-vkorg  AND
                                  vapma~vtweg =  li_leg_temp-vtweg AND
                                  vapma~kunnr =  li_leg_temp-kunnr_sp AND
                                  vbpa~kunnr  =  li_leg_temp-kunnr_sh  AND
                                  vbpa~parvw  = lc_parvw_we.

        IF sy-subrc EQ 0.
* Don't consider the contract which type is not in OTC  process table
          LOOP AT li_item  ASSIGNING <lfs_item> .
            READ TABLE li_trg_typ WITH  KEY vkorg = <lfs_item>-vkorg
                                            vtweg = <lfs_item>-vtweg
                                            auart = <lfs_item>-auart TRANSPORTING NO FIELDS  BINARY SEARCH .
            IF sy-subrc NE  0.
              CLEAR      <lfs_item>-auart .
            ENDIF . " IF sy-subrc NE 0
          ENDLOOP . " LOOP AT li_item ASSIGNING <lfs_item>

          DELETE li_item WHERE auart IS INITIAL .

*       Don't consider those contract for which 'Contract start date'
*       is in future. Means delete those contracts for which DATAB (Contract
*       start date) is greater than current date
*       Similarly, Don't consider those contract for which 'Contract End date'
*       is in Past. Means delete those contracts for which DATBI (Contract
*       end date) is less than current date
          DELETE li_item WHERE ( datab GT sy-datum )
                            OR ( datbi LT sy-datum ).


          SORT li_item BY  matnr  vkorg vtweg kunnr_sp kunnr_sh vbeln.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF    . " IF li_leg_temp IS NOT INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_trg_sel IS NOT INITIAL
*---> End of Insert for Defect# 7913 by APAUL on 02.01.2017

  LOOP AT li_order_unic INTO lwa_final.
*&--populating the partner table and Header
    lwa_order_header_in-doc_type = lwa_final-auart. " Order Type
    lwa_order_header_in-sales_org = lwa_final-vkorg. " Sales org
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
    lwa_order_header_in-distr_chan = lwa_final-vtweg.
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016
*---> Begin of Delete for CR# 3502 by U034088 on 30.08.2016
*    lwa_order_header_in-distr_chan = gv_vtweg. " Distribution channel
*<--- End of Delete for CR# 3502 by U034088 on 30.08.2016

    lwa_order_header_in-purch_no_c = lwa_final-bstnk. " Po No
    lwa_order_header_in-purch_date = lwa_final-bstdk. " PO Date
    lwa_order_header_in-po_method = lwa_final-bsark. " PO method
    lwa_order_header_in-dlv_block = lwa_final-lifsk. " Delivery block (document header)

*&--populating the partner table and sold to party
    lwa_order_partner-partn_role = lwa_final-parvw_sp.
    lwa_order_partner-partn_numb = lwa_final-kunnr_sp.
    APPEND lwa_order_partner TO li_order_partner.
    CLEAR lwa_order_partner.

*&--populating the partner table with ship to party
    lwa_order_partner-partn_role = lwa_final-parvw_sh . "'SH'."c_shipto.
    lwa_order_partner-partn_numb = lwa_final-kunnr_sh.
    APPEND lwa_order_partner TO li_order_partner.
    CLEAR lwa_order_partner.

*&--populating the partner table with contact person
    lwa_order_partner-partn_role = lwa_final-parvw_cp . "'CP Contact Person
    lwa_order_partner-partn_numb = lwa_final-kunnr_cp.
    lwa_order_partner-addr_link = lwa_final-kunnr_cp.

    CLEAR : lwa_land.
    READ TABLE li_land INTO lwa_land
    WITH KEY kunnr = lwa_final-kunnr_sp
    BINARY SEARCH.

    IF sy-subrc IS INITIAL.
      lwa_order_partner-country = lwa_land-land1.
    ENDIF. " IF sy-subrc IS INITIAL
    APPEND lwa_order_partner TO li_order_partner.
    CLEAR lwa_order_partner.

*&--populating the partner table with contact person Email and Address
    lwa_partneraddresses-addr_no = lwa_final-kunnr_cp.
    lwa_partneraddresses-name = lwa_final-name1.
    lwa_partneraddresses-tel1_numbr = lwa_final-tele1.
    lwa_partneraddresses-e_mail = lwa_final-email.
    lwa_partneraddresses-county = lwa_land-land1.

    APPEND lwa_partneraddresses TO li_partneraddresses.
    CLEAR : lwa_partneraddresses.

*Populate Header text for ID 0002
    CLEAR : lwa_order_text.
    lwa_order_text-text_id    = lwa_final-textid.
    lwa_order_text-langu      = sy-langu.
    lwa_order_text-text_line  = lwa_final-text.

    APPEND lwa_order_text TO li_order_text.

*Populate Header text for ID Z002
    CLEAR : lwa_order_text.
    lwa_order_text-text_id    = lwa_final-textid_2.
    lwa_order_text-langu      = sy-langu.
    lwa_order_text-text_line  = lwa_final-text_2.

    APPEND lwa_order_text TO li_order_text.
    CLEAR : lwa_order_text.


*$ Fetching the Index for populatinf item
*Binary search not possible as need to fetch the 1st line of Item Set
    CLEAR : lv_index.
    READ TABLE li_temp_item
    INTO lwa_temp_item
    WITH KEY
           auart  =  lwa_final-auart
           vkorg  = lwa_final-vkorg
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
           vtweg  = lwa_final-vtweg
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016
           parvw_sp = lwa_final-parvw_sp
           kunnr_sp = lwa_final-kunnr_sp
           parvw_sh = lwa_final-parvw_sh
           kunnr_sh = lwa_final-kunnr_sh
           bstnk = lwa_final-bstnk.

    IF sy-subrc IS INITIAL.
      lv_index = sy-tabix.
    ENDIF. " IF sy-subrc IS INITIAL
    CLEAR : lv_posnr,
            lwa_order_items_in,
            lwa_order_schedule.
*---> Begin of Delete for Defect# 2741 by U034088 on 27.07.2016
*    LOOP AT li_temp_item INTO lwa_temp_item FROM lv_index.
*
*      IF      lwa_temp_item-auart  =  lwa_final-auart
*        AND   lwa_temp_item-vkorg  = lwa_final-vkorg
*        AND   lwa_temp_item-parvw_sp = lwa_final-parvw_sp
*        AND   lwa_temp_item-kunnr_sp = lwa_final-kunnr_sp
*        AND   lwa_temp_item-parvw_sh = lwa_final-parvw_sh
*        AND   lwa_temp_item-kunnr_sh = lwa_final-kunnr_sh
*        AND   lwa_temp_item-bstnk = lwa_final-bstnk.
*
*
*        lv_posnr = lv_posnr + 10.
*        lwa_order_items_in-itm_number = lv_posnr.
*        lwa_order_items_in-material = lwa_temp_item-matnr.
*        lwa_order_items_in-target_qty = lwa_temp_item-kwmeng.
*        lwa_order_items_in-batch = lwa_temp_item-charg.
*        APPEND lwa_order_items_in TO li_order_items_in.
*
**Only one Schedule line will be there for one Line Item
*        lwa_order_schedule-itm_number = lv_posnr.
*        lwa_order_schedule-req_date = lwa_temp_item-etdat.
*        lwa_order_schedule-req_qty = lwa_temp_item-kwmeng.
*
*        APPEND lwa_order_schedule TO li_order_schedule.
*      ELSE. " ELSE -> IF lwa_temp_item-auart = lwa_final-auart
*        EXIT. " Exit from the current Loop.
*      ENDIF. " IF lwa_temp_item-auart = lwa_final-auart
*    ENDLOOP. " LOOP AT li_temp_item INTO lwa_temp_item FROM lv_index

*<--- End of Delete for Defect# 2741 by U034088 on 27.07.2016




*---> Begin of Insert for Defect# 2741 by U034088 on 27.07.2016
*    Modify the work area and replacing with Field Symbols
*    Work Area lwa_temp_item replaced by <lfs_temp_item>
    LOOP AT li_temp_item ASSIGNING <lfs_temp_item> FROM lv_index.

      IF      <lfs_temp_item>-auart  =  lwa_final-auart
        AND   <lfs_temp_item>-vkorg  = lwa_final-vkorg
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
        AND <lfs_temp_item>-vtweg  = lwa_final-vtweg
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016
        AND   <lfs_temp_item>-parvw_sp = lwa_final-parvw_sp
        AND   <lfs_temp_item>-kunnr_sp = lwa_final-kunnr_sp
        AND   <lfs_temp_item>-parvw_sh = lwa_final-parvw_sh
        AND   <lfs_temp_item>-kunnr_sh = lwa_final-kunnr_sh
        AND   <lfs_temp_item>-bstnk = lwa_final-bstnk.

*---> Begin of Insert for Defect# 7913 by APAUL on 02.01.2017

* In case mutiple contracts are found for a given Sold to, Ship to
* and Material.  It will default the very first contract. Pick
* the contract with the least number.

        CLEAR lwa_order_items_in.
        READ TABLE li_item  ASSIGNING  <lfs_item>  WITH  KEY
          matnr = <lfs_temp_item>-matnr
          vkorg = <lfs_temp_item>-vkorg
          vtweg  = <lfs_temp_item>-vtweg
          kunnr_sp = <lfs_temp_item>-kunnr_sp
          kunnr_sh = <lfs_temp_item>-kunnr_sh  BINARY SEARCH .

        IF sy-subrc IS INITIAL.
* Assign the reference  document
          lwa_order_items_in-ref_doc = <lfs_item>-vbeln .
*Reference document for this scenario will be always contract,so
*document category is considered as "G" as per business requirement
          lwa_order_items_in-ref_doc_ca = lc_doc_cat .
          lwa_order_items_in-ref_doc_it = <lfs_item>-posnr .

        ENDIF. " IF sy-subrc IS INITIAL
*---> End of Insert for Defect# 7913 by APAUL on 02.01.2017

        lv_posnr = lv_posnr + 10.
        lwa_order_items_in-itm_number = lv_posnr.
        lwa_order_items_in-material = <lfs_temp_item>-matnr.
        lwa_order_items_in-target_qty = <lfs_temp_item>-kwmeng.
        lwa_order_items_in-batch = <lfs_temp_item>-charg.
*---> Begin of Insert for Defect# 2741 by U034088 on 27.07.2016
        IF rb_post = abap_true.
*       Item in output will be polulated during Post only
          <lfs_temp_item>-posnr = lv_posnr. " Item number populated
        ENDIF. " IF rb_post = abap_true
*<--- End of Insert for Defect# 2741 by U034088 on 27.07.2016
        APPEND lwa_order_items_in TO li_order_items_in.
*Only one Schedule line will be there for one Line Item
        lwa_order_schedule-itm_number = lv_posnr.
        lwa_order_schedule-req_date = <lfs_temp_item>-etdat.
        lwa_order_schedule-req_qty = <lfs_temp_item>-kwmeng.

        APPEND lwa_order_schedule TO li_order_schedule.
      ELSE. " ELSE -> IF <lfs_temp_item>-auart = lwa_final-auart
        EXIT. " Exit from the current Loop.
      ENDIF. " IF <lfs_temp_item>-auart = lwa_final-auart
    ENDLOOP. " LOOP AT li_temp_item ASSIGNING <lfs_temp_item> FROM lv_index
*<--- End of Insert for Defect# 2741 by U034088 on 27.07.2016

*<--Begin of change for CR# 378 by U033867
    IF NOT p_vkbur IS INITIAL.
      lwa_order_header_in-sales_off = p_vkbur .
    ENDIF. " IF NOT p_vkbur IS INITIAL
*-->End of change for CR# 378 by U033867
*&--passing the tables and stuctures to BAPI to create sales order

    CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
      EXPORTING
        order_header_in    = lwa_order_header_in
        testrun            = lv_test
      IMPORTING
        salesdocument      = lv_vbeln
      TABLES
        return             = li_return
        order_items_in     = li_order_items_in
        order_partners     = li_order_partner
        order_schedules_in = li_order_schedule
        order_text         = li_order_text
        partneraddresses   = li_partneraddresses
      EXCEPTIONS
        OTHERS             = 0.

* $ Populating Error for all line items and so loop is required
    CLEAR : lv_bapi_msg.
    LOOP AT li_return INTO lwa_return.
 " Capture Bapi Error Meassage
      IF lwa_return-type = lc_emsg OR lwa_return-type = lc_amsg.
        CONCATENATE lv_bapi_msg lwa_return-message
        INTO lv_bapi_msg
        SEPARATED BY lc_sep.
      ENDIF. " IF lwa_return-type = lc_emsg OR lwa_return-type = lc_amsg
    ENDLOOP. " LOOP AT li_return INTO lwa_return

    IF lv_bapi_msg IS NOT INITIAL.
      IF lv_bapi_msg+0(1) = lc_sep.
        lv_bapi_msg = lv_bapi_msg+1.
      ENDIF. " IF lv_bapi_msg+0(1) = lc_sep
    ENDIF. " IF lv_bapi_msg IS NOT INITIAL

    CLEAR : lv_flag.

    IF lv_bapi_msg IS INITIAL.
* Success in production or Test Mode.
      IF lv_vbeln IS NOT INITIAL. "  Success in Prod Mod
        lv_bapi_msg = lv_vbeln. " Polulate the Order Number
*&--BAPI commit
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
      ELSE. " ELSE -> IF lv_vbeln IS NOT INITIAL
        lv_bapi_msg = 'Sales Order Can be Posted Successfully'(006).
      ENDIF. " IF lv_vbeln IS NOT INITIAL
    ELSE. " ELSE -> IF lv_bapi_msg IS INITIAL
      lv_flag = abap_true.
*&--BAPI rollback
      IF lv_test IS INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ENDIF. " IF lv_test IS INITIAL
    ENDIF. " IF lv_bapi_msg IS INITIAL

    CONDENSE : lv_bapi_msg.

    READ TABLE li_temp_item ASSIGNING <lfs_temp_item>
                            WITH KEY  auart  =  lwa_final-auart
                                      vkorg  = lwa_final-vkorg
                                      vtweg  = lwa_final-vtweg
                                      parvw_sp = lwa_final-parvw_sp
                                      kunnr_sp = lwa_final-kunnr_sp
                                      parvw_sh = lwa_final-parvw_sh
                                      kunnr_sh = lwa_final-kunnr_sh
                                      bstnk = lwa_final-bstnk
                                      BINARY SEARCH.
    IF sy-subrc = 0 .
      IF lv_flag = abap_true.
        <lfs_temp_item>-msgtyp = lc_emsg. " Error Message type
      ELSE. " ELSE -> IF lv_flag = abap_true
        <lfs_temp_item>-msgtyp = lc_smsg. " Success Message type
      ENDIF. " IF lv_flag = abap_true
      <lfs_temp_item>-error = lv_bapi_msg. " Message Text
*      APPEND <lfs_temp_item> TO i_leg_tab_msg.
    ENDIF. " IF sy-subrc = 0

*&--Populating the message log detail during test run or data in error
    CLEAR lv_type.
    lv_type = <lfs_temp_item>-msgtyp.
    LOOP AT li_temp_item ASSIGNING <lfs_temp_item> FROM lv_index.

      IF      <lfs_temp_item>-auart  =  lwa_final-auart
        AND   <lfs_temp_item>-vkorg  = lwa_final-vkorg
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
        AND   <lfs_temp_item>-vtweg  = lwa_final-vtweg
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016
        AND   <lfs_temp_item>-parvw_sp = lwa_final-parvw_sp
        AND   <lfs_temp_item>-kunnr_sp = lwa_final-kunnr_sp
        AND   <lfs_temp_item>-parvw_sh = lwa_final-parvw_sh
        AND   <lfs_temp_item>-kunnr_sh = lwa_final-kunnr_sh
        AND   <lfs_temp_item>-bstnk = lwa_final-bstnk.

        <lfs_temp_item>-error = lv_bapi_msg.
        <lfs_temp_item>-msgtyp = lv_type.
        MODIFY li_temp_item FROM <lfs_temp_item> INDEX lv_index TRANSPORTING error msgtyp.
        APPEND <lfs_temp_item> TO i_leg_tab_msg.
        IF lv_flag = abap_true.
*          <lfs_temp_item>-msgtyp = lc_emsg. " Error Message type
          gv_ecount = gv_ecount + 1. " Error Message Count
*---> Begin of Insert for Defect# 2741 by U034088 on 27.07.2016
**    In case of Error posting remove the Line Item Number
*          CLEAR:  <lfs_temp_item>-posnr.
*<--- End of Insert for Defect# 2741 by U034088 on 27.07.2016
        ELSE. " ELSE -> IF lv_flag = abap_true
*          <lfs_temp_item>-msgtyp = lc_smsg. " Success Message type
          gv_scount = gv_scount + 1. " Error Message Count
        ENDIF. " IF lv_flag = abap_true
*        <lfs_temp_item>-error = lv_bapi_msg. " Message Text
*        APPEND <lfs_temp_item> TO i_leg_tab_msg.
      ELSE. " ELSE -> IF <lfs_temp_item>-auart = lwa_final-auart
        EXIT.
      ENDIF. " IF <lfs_temp_item>-auart = lwa_final-auart
    ENDLOOP. " LOOP AT li_temp_item ASSIGNING <lfs_temp_item> FROM lv_index

    CLEAR:
            li_return,
            li_order_items_in,
            li_order_partner,
            li_order_schedule,
            li_order_text,
            li_partneraddresses,
            lwa_order_header_in.

  ENDLOOP. " LOOP AT li_order_unic INTO lwa_final


  CLEAR:
        li_return,
        li_order_items_in,
        li_order_partner,
        li_order_schedule,
        li_order_text,
        li_temp_item,
        li_order_unic,
        li_leg_temp,
        li_partneraddresses,
        li_land,
        lwa_order_items_in,
        lwa_order_partner,
        lwa_order_schedule,
        lwa_order_text,
        lwa_final,
        lwa_temp_item,
        lwa_order_header_in,
        lwa_partneraddresses,
        lwa_return,
        lwa_land,
        lv_index ,
        lv_vbeln,
        lv_posnr,
        lv_test,
        lv_flag,
        lv_bapi_msg.
ENDFORM. " F_BAPI_POSTING
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
* This perform hide/ unhide selection screen parameters based on user
* selection
*----------------------------------------------------------------------*
FORM f_modify_screen .
  LOOP AT SCREEN .
*-- Presentation Server Option is NOT chosen
    IF rb_pres NE c_true.
*-- Hiding Presentation Server file paths with modifidd MI3.
      IF screen-group1 = c_groupmi3.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
*-- Presentation Server Option IS chosen
    ELSE. " ELSE -> IF rb_pres NE c_true
*-- Disaplying Presentation Server file paths with modifidd MI3.
      IF screen-group1 = c_groupmi3.
        screen-active = c_one.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
    ENDIF. " IF rb_pres NE c_true
*-- Application Server Option is NOT chosen
    IF rb_app NE c_true.
*-- Hiding 1) Application Server file Physical paths with modifid MI2
*     2) Logical Filename Radio Button with with modifid MI5
*     3) Logical Filename input with modifid MI7
      IF screen-group1 = c_groupmi2
         OR screen-group1 = c_groupmi5
         OR screen-group1 = c_groupmi7.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi2
*--  Application Server Option IS chosen
    ELSE. " ELSE -> IF rb_app NE c_true
*-- If Application Server Physical File Radio Button is chosen
      IF rb_aphy EQ c_true.
*       Dispalying Application Server Physical paths with modifid MI2
        IF screen-group1 = c_groupmi2.
          screen-active = c_one.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi2
*       Hiding Logical Filaename input with modifid MI7
        IF screen-group1 = c_groupmi7.
          screen-active = c_zero.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi7
*     If Application Server Logical File Radio Button is chosen
      ELSE. " ELSE -> IF rb_aphy EQ c_true
*       Hiding Application Server - Physical paths with modifidd MI2
        IF screen-group1 = c_groupmi2.
          screen-active = c_zero.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi2
*       Displaying Logical Filaename input with modifid MI7
        IF screen-group1 = c_groupmi7.
          screen-active = c_one.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi7
      ENDIF. " IF rb_aphy EQ c_true
    ENDIF. " IF rb_app NE c_true

  ENDLOOP. " LOOP AT SCREEN
ENDFORM. " F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  F_INITIALIZATION
*&---------------------------------------------------------------------*
*  Initialize all global variable and internal tables
*----------------------------------------------------------------------*

FORM f_initialization .
*<--Begin of change for CR# 378 by U033867
  CONSTANTS: lc_parid TYPE memoryid VALUE 'VKB'. " Set/Get parameter ID
  DATA: li_parameter TYPE STANDARD TABLE OF bapiparam, " User: Parameter Transfer Structure
        li_return    TYPE STANDARD TABLE OF bapiret2.  " Return Parameter
  FIELD-SYMBOLS: <lfs_bapiparam> TYPE bapiparam . " User: Parameter Transfer Structure
*-->End of change for CR# 378 by U033867
  CLEAR : i_leg_tab_msg,
          i_leg_tab_c,
          i_kunnr_leg,
          gv_scount,
          gv_ecount,
          gv_vtweg.
*<--Begin of change for CR# 378 by U033867
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username  = sy-uname
    TABLES
      parameter = li_parameter
      return    = li_return.
*  Binary search not used as table will have few entries
  READ TABLE li_parameter ASSIGNING <lfs_bapiparam> WITH KEY
                                             parid = lc_parid.
  IF sy-subrc = 0.
    p_vkbur = <lfs_bapiparam>-parva.
  ENDIF. " IF sy-subrc = 0

*-->End of change for CR# 378 by U033867
ENDFORM. " F_INITIALIZATION
*&---------------------------------------------------------------------*
*&      Form  F_GET_CONSTANTS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*       Get Constants From EMI Tool
*----------------------------------------------------------------------*
FORM f_get_constants .

*data declaration
  DATA: li_constants TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0. " Enhancement Status
*field symbol dclaration
  FIELD-SYMBOLS: <lfs_constant> TYPE zdev_enh_status. " Enhancement Status
*constant declaration
  CONSTANTS:
             lc_codepage      TYPE z_criteria    VALUE 'CODEPAGE',     " Enh. Criteria
             lc_discha      TYPE z_criteria    VALUE 'VTWEG',          " Enh. Criteria
             lc_enh_name      TYPE z_enhancement VALUE 'OTC_EDD_0347'. "Enhancement No.

*get the constants
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_name
    TABLES
      tt_enh_status     = li_constants.
*If EMI table is not initial
  IF li_constants[] IS NOT INITIAL. "sy-subrc IS INITIAL AND
    SORT li_constants BY  criteria  active .
    READ TABLE li_constants ASSIGNING <lfs_constant> WITH KEY criteria = lc_codepage
                                                              active = abap_true
                                                              BINARY SEARCH.
    IF sy-subrc = 0.
      gv_codepage = <lfs_constant>-sel_low.

      IF gv_codepage IS NOT INITIAL.
        CALL METHOD zdev_cl_abap_file_utilities=>meth_stat_pub_check_codepage
          CHANGING
            ch_codepage = gv_codepage.
      ENDIF. " IF gv_codepage IS NOT INITIAL

    ENDIF. " IF sy-subrc = 0
*---> Begin of Delete for CR# 3502 by U034088 on 30.08.2016
*    READ TABLE li_constants ASSIGNING <lfs_constant> WITH KEY criteria = lc_discha
*                                                              active = abap_true
*                                                              BINARY SEARCH.
*    IF sy-subrc = 0.
*      gv_vtweg = <lfs_constant>-sel_low.
*    ENDIF. " IF sy-subrc = 0
*<--- End of Delete for CR# 3502 by U034088 on 30.08.2016
  ENDIF. " IF li_constants[] IS NOT INITIAL

  FREE : li_constants .

ENDFORM. " F_GET_CONSTANTS


*&---------------------------------------------------------------------*
*&      Form  F_CHECK_INPUT                                            *
*&---------------------------------------------------------------------*
*      Checking whether the file name has been entered or not          *
*----------------------------------------------------------------------*
FORM f_check_input .
* If No presentation Server file name is entered and Presentation
* Server Option has been chosen, then issuing the error message.
  IF rb_pres IS NOT INITIAL AND
     p_phdr IS INITIAL.
    MESSAGE i009.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF rb_pres IS NOT INITIAL AND

* For Application Server
  IF rb_app IS NOT INITIAL.
*   If No Application Server file name is entered and Application
*   Server Optin has been chosen, then issueing error message.
    IF rb_aphy IS NOT INITIAL AND
      p_ahdr IS INITIAL.
      MESSAGE i010.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF rb_aphy IS NOT INITIAL AND
* Commented Logical path section by RAJENDRA
* If No Logical File Path is entered and Logical File Path Option
* has been chosen, then issueing error message.
*    IF rb_alog IS NOT INITIAL AND
*       p_alog IS INITIAL.
*      MESSAGE i011.
*      LEAVE LIST-PROCESSING.
*    ENDIF. " IF rb_alog IS NOT INITIAL AND
  ENDIF. " IF rb_app IS NOT INITIAL
ENDFORM. " F_CHECK_INPUT
*&---------------------------------------------------------------------*
*&      Form  F_SET_MODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_SAVE  text
*      <--P_GV_MODE  text
*----------------------------------------------------------------------*
FORM f_set_mode  CHANGING  fp_gv_mode TYPE char10. " mode to decide post run or test run

* Choosing the Mode
  IF rb_post = c_true.
    fp_gv_mode = 'Post Run'(009).
  ELSE. " ELSE -> IF rb_post = c_true
    fp_gv_mode = 'Test Run'(010).
  ENDIF. " IF rb_post = c_true


ENDFORM. " F_SET_MODE

*&---------------------------------------------------------------------*
*&      Form  F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_ALOG  text
*      <--P_GV_FILE  text
*----------------------------------------------------------------------*
FORM f_logical_to_physical  USING    fp_p_alog  TYPE pathintern " Logical path name
                            CHANGING fp_gv_file TYPE localfile. " Local file for upload/download
* Local Constants
  CONSTANTS : lc_lp_ind TYPE char1 VALUE 'X'. "Value: X
* Local Data Declaration
  DATA: li_input   TYPE zdev_t_file_list_in,    "Local Input table
        lwa_input  TYPE zdev_file_list_in,      "Local work area
        li_output  TYPE zdev_t_file_list_out,   "Local Output Table
        lwa_output TYPE zdev_file_list_out,     "Local work area
        li_error   TYPE zdev_t_file_list_error. "Local error table

* Passing the logical file path to get the physical file path
  lwa_input-path = fp_p_alog.
  APPEND lwa_input TO li_input.
  CLEAR lwa_input.

* Retriving all files within the directory
  CALL FUNCTION 'ZDEV_DIRECTORY_FILE_LIST'
    EXPORTING
      im_identifier      = lc_lp_ind "Value: X
      im_input           = li_input
    IMPORTING
      ex_output          = li_output
      ex_error           = li_error
    EXCEPTIONS
      no_input           = 1
      invalid_identifier = 2
      no_data_found      = 3
      OTHERS             = 4.

  IF sy-subrc <> 0.
    MESSAGE i020. "No proper file exist for the logical file'.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc <> 0
  IF sy-subrc IS INITIAL AND
     li_error IS INITIAL.
*   Getting the file path
    READ TABLE li_output INTO lwa_output INDEX 1.
    IF sy-subrc IS INITIAL.
      CONCATENATE lwa_output-physical_path
                  lwa_output-filename
     INTO  fp_gv_file.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL AND

  FREE: li_input ,  "Local Input table
        li_output , "Local Output Table
        li_error  . "Local error table
  CLEAR : lwa_input,
          lwa_output.

ENDFORM. " F_LOGICAL_TO_PHYSICAL

*&---------------------------------------------------------------------*
*&      Form  F_AUTHORIZATION_CHECK
*&---------------------------------------------------------------------*

FORM f_authorization_check  USING    fp_filename TYPE localfile " Local file for upload/download
                                     fp_activity TYPE char5     " Activity of type CHAR5
                            CHANGING fp_flag     TYPE flag.     " General Flag

* Local Data Declaration
  DATA: lv_file TYPE fileextern. " Physical file name

  lv_file = fp_filename.
*  Authorization for writing to dataset
  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
    EXPORTING
      activity         = fp_activity
      filename         = lv_file
    EXCEPTIONS
      no_authority     = 1
      activity_unknown = 2
      OTHERS           = 3.

  IF sy-subrc <> 0.
    fp_flag = abap_true.
  ELSE. " ELSE -> IF sy-subrc <> 0
    fp_flag = abap_false.
  ENDIF. " IF sy-subrc <> 0
  CLEAR : lv_file.
ENDFORM. " F_AUTHORIZATION_CHECK
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION
*&---------------------------------------------------------------------*
*       Input File Validation
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validation .
  TYPES :
  BEGIN OF lty_mvke,
    matnr TYPE  matnr,         " Material Number
    vkorg	TYPE vkorg,          "Sales Organization
    vtweg	TYPE vtweg,          "Distribution Channel
    dwerk TYPE dwerk_ext,      " Plant
  END OF lty_mvke,

  BEGIN OF lty_knvv,
    kunnr	TYPE kunnr,          "Customer Number
    vkorg	TYPE vkorg,          "Sales Organization
    vtweg	TYPE vtweg,          "Distribution Channel
    spart	TYPE spart,          "Division
  END OF lty_knvv,

  BEGIN OF lty_tvak,
    auart TYPE auart,          " Sales Document Type
  END OF lty_tvak ,
  BEGIN OF lty_t176,
    bsark TYPE bsark,          " Customer purchase order type
  END OF lty_t176,

          BEGIN OF ty_mcha,
           matnr TYPE matnr,   " Material Number
           werks TYPE werks_d, " Plant
           charg TYPE charg_d, " Batch Number
           vfdat TYPE vfdat,   " Shelf Life Expiration or Best-Before Date
          END OF ty_mcha,

          BEGIN OF ty_temp,
           matnr TYPE matnr,   " Material Number
           werks TYPE werks_d, " Plant
           charg TYPE charg_d, " Batch Number
          END OF ty_temp,


  BEGIN OF lty_mch1,
    matnr TYPE matnr,          " Material Number
    charg TYPE charg_d,        " Batch Number
    vfdat TYPE vfdat,          " Shelf Life Expiration or Best-Before Date
  END OF lty_mch1.


  DATA : li_mvke TYPE STANDARD TABLE OF lty_mvke,
         li_knvv TYPE STANDARD TABLE OF lty_knvv,
         li_tvak TYPE STANDARD TABLE OF lty_tvak,
         li_t176 TYPE STANDARD TABLE OF lty_t176,
         li_leg_err  TYPE ty_t_leg_tab_c,
         li_leg_suc  TYPE ty_t_leg_tab_c,
         li_leg_temp  TYPE ty_t_leg_tab_c,
         li_temp TYPE STANDARD TABLE OF ty_temp INITIAL SIZE 0,
         ls_temp TYPE ty_temp,
        li_mch1  TYPE STANDARD TABLE OF lty_mch1,
         li_mcha TYPE STANDARD TABLE OF ty_mcha,
         lwa_mcha TYPE ty_mcha,
        lwa_mch1  TYPE lty_mch1,
         lwa_mvke TYPE lty_mvke,
         lwa_knvv TYPE lty_knvv,
         lwa_tvak TYPE lty_tvak,
         lwa_t176 TYPE lty_t176,
         lv_msg TYPE string. " Msg  fo rcapturing all messages

  FIELD-SYMBOLS: <lfs_leg_tab_c> TYPE ty_leg_tab_c.

* Local constants
  CONSTANTS :
              lc_sep  TYPE char1 VALUE '/' ,  " Sep of type Character
              lc_emsg TYPE char1 VALUE   'E'. " constant declaration for 'E' success message type



  IF i_leg_tab_c IS NOT INITIAL.
    SORT    i_leg_tab_c BY
            auart
            vkorg
            parvw_sp
            kunnr_sp
            parvw_sh
            kunnr_sh
            bstnk
            matnr. " Change by RAJENDRA to add Material Sorting
*            etdat_c. " Change by RAJENDRA to add delivery date sorting
*            etdat. " Change by RAJENDRA on 10/13/2016 to add delivery date sorting
*& Select material Sales ORG Date
    li_leg_temp = i_leg_tab_c.
    SORT li_leg_temp BY matnr vkorg.
    DELETE ADJACENT DUPLICATES FROM li_leg_temp
    COMPARING matnr vkorg.

    IF li_leg_temp IS NOT INITIAL.
      SELECT
        matnr     " Material Number
        vkorg     " Sales Organization
        vtweg     " Distribution Channel
        dwerk     " Delivering Plant (Own or External)
        FROM mvke " Sales Data for Material
        INTO TABLE li_mvke
        FOR ALL ENTRIES IN li_leg_temp
        WHERE matnr = li_leg_temp-matnr
        AND vkorg = li_leg_temp-vkorg
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
        AND vtweg = li_leg_temp-vtweg.
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016
*---> Begin of Delete for CR# 3502 by U034088 on 30.08.2016
*        AND vtweg = gv_vtweg.
*<--- End of Delete for CR# 3502 by U034088 on 30.08.2016
      IF sy-subrc IS INITIAL.
        SORT li_mvke BY matnr vkorg vtweg.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF li_leg_temp IS NOT INITIAL

*& Select customer sales ORG Date

    SORT i_kunnr_leg BY kunnr vkorg.
* Global table i_kunnr_leg  is required only for below selection.
    DELETE ADJACENT DUPLICATES FROM i_kunnr_leg
    COMPARING kunnr vkorg.

    IF i_kunnr_leg IS NOT INITIAL.
      SELECT
        kunnr     " Customer Number
        vkorg     " Sales Organization
        vtweg     " Distribution Channel
        spart     " Division
        FROM knvv " Customer Master Sales Data
        INTO TABLE li_knvv
        FOR ALL ENTRIES IN i_kunnr_leg
        WHERE kunnr = i_kunnr_leg-kunnr
        AND vkorg = i_kunnr_leg-vkorg.
*---> Begin of Delete for CR# 3502 by U034088 on 30.08.2016
*        AND vtweg = gv_vtweg.
*<--- End of Delete for CR# 3502 by U034088 on 30.08.2016


      IF sy-subrc IS INITIAL.
        SORT li_knvv BY kunnr vkorg vtweg spart.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF i_kunnr_leg IS NOT INITIAL

*& Select order type
    CLEAR : li_leg_temp.
    li_leg_temp = i_leg_tab_c.
    SORT li_leg_temp BY auart.
    DELETE ADJACENT DUPLICATES FROM li_leg_temp
    COMPARING auart.

    IF li_leg_temp IS NOT INITIAL.
      SELECT
        auart     " Sales Document Type
        FROM tvak " Sales Document Types
        INTO TABLE li_tvak
        FOR ALL ENTRIES IN li_leg_temp
        WHERE auart = li_leg_temp-auart.

      IF sy-subrc IS INITIAL.
        SORT li_tvak BY auart.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF li_leg_temp IS NOT INITIAL

*& Select Sales order PO type
    CLEAR : li_leg_temp.
    li_leg_temp = i_leg_tab_c.
    SORT li_leg_temp BY bsark.
    DELETE ADJACENT DUPLICATES FROM li_leg_temp
    COMPARING bsark.

    IF li_leg_temp IS NOT INITIAL.
      SELECT
        bsark     " Customer purchase order type
        FROM t176 " Sales Documents: Customer Order Types
        INTO TABLE li_t176
        FOR ALL ENTRIES IN li_leg_temp
        WHERE bsark = li_leg_temp-bsark.

      IF sy-subrc IS INITIAL.
        SORT li_t176 BY bsark.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF li_leg_temp IS NOT INITIAL
  ENDIF. " IF i_leg_tab_c IS NOT INITIAL



*& Select Batch details
  CLEAR : li_leg_temp.
  li_leg_temp = i_leg_tab_c.
  SORT li_leg_temp BY matnr charg.
  DELETE ADJACENT DUPLICATES FROM li_leg_temp
  COMPARING matnr charg.

  IF li_leg_temp IS NOT INITIAL.
    SELECT
      matnr     " Material Number
      charg     " Batch Number
      vfdat     " Shelf Life Expiration or Best-Before Date
      FROM mch1 " Batches (if Batch Management Cross-Plant)
      INTO TABLE li_mch1
      FOR ALL ENTRIES IN li_leg_temp
      WHERE matnr = li_leg_temp-matnr
          AND charg = li_leg_temp-charg.
* Begin of Defect - 2455
    DELETE li_mch1 WHERE vfdat LT sy-datum.
* End of Defect - 2455
    IF li_mch1 IS NOT INITIAL.
      SORT li_mch1 BY matnr charg.
    ENDIF. " IF li_mch1 IS not INITIAL
  ENDIF. " IF li_leg_temp IS NOT INITIAL



  LOOP AT  i_leg_tab_c ASSIGNING <lfs_leg_tab_c>.

    CLEAR : lv_msg.
    lv_msg = <lfs_leg_tab_c>-error.


    IF lv_msg IS INITIAL.
*      IF <lfs_leg_tab_c>-charg IS NOT INITIAL.
*        READ TABLE li_mch1
*         INTO lwa_mch1
*         WITH KEY
*         matnr = <lfs_leg_tab_c>-matnr
*         charg = <lfs_leg_tab_c>-charg
*         BINARY SEARCH.
*        IF sy-subrc IS NOT INITIAL.
*          IF lv_msg IS INITIAL.
*            lv_msg = 'Batch does not exist for material'(016). " Order Type not Found
*          ELSE. " ELSE -> IF lv_msg IS INITIAL
*            CONCATENATE lv_msg 'Batch does not exist for material'(016) INTO lv_msg SEPARATED BY lc_sep.
*          ENDIF. " IF lv_msg IS INITIAL
*        ENDIF. " IF sy-subrc IS NOT INITIAL
*      ENDIF. " IF <lfs_leg_tab_c>-charg IS NOT INITIAL

*$ Checking Sales order Document type
      READ TABLE li_tvak
      INTO lwa_tvak
      WITH KEY
      auart = <lfs_leg_tab_c>-auart
      BINARY SEARCH.

      IF sy-subrc IS NOT INITIAL.
        IF lv_msg IS INITIAL.
          lv_msg = 'Order Type not found'(004). " Order Type not Found
        ELSE. " ELSE -> IF lv_msg IS INITIAL
          CONCATENATE lv_msg 'Order Type not found'(004) INTO lv_msg SEPARATED BY lc_sep.
        ENDIF. " IF lv_msg IS INITIAL
      ENDIF. " IF sy-subrc IS NOT INITIAL

*$ Checking Sales order PO Document type
      READ TABLE li_t176
      INTO lwa_t176
      WITH KEY
      bsark = <lfs_leg_tab_c>-bsark
      BINARY SEARCH.

      IF sy-subrc IS NOT INITIAL.
        IF lv_msg IS INITIAL.
          lv_msg = 'PO Type not valid'(007). " Order Type not Found
        ELSE. " ELSE -> IF lv_msg IS INITIAL
          CONCATENATE lv_msg 'PO Type not valid'(007) INTO lv_msg SEPARATED BY lc_sep.
        ENDIF. " IF lv_msg IS INITIAL
      ENDIF. " IF sy-subrc IS NOT INITIAL

*$ checking Material against Sales Org
      READ TABLE li_mvke
      INTO lwa_mvke
      WITH KEY
      matnr = <lfs_leg_tab_c>-matnr
      vkorg = <lfs_leg_tab_c>-vkorg
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
      vtweg = <lfs_leg_tab_c>-vtweg
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016
*---> Begin of Delete for CR# 3502 by U034088 on 30.08.2016
*    vtweg = gv_vtweg
*<--- End of Delete for CR# 3502 by U034088 on 30.08.2016
      BINARY SEARCH.

      IF sy-subrc IS NOT INITIAL.
        IF lv_msg IS INITIAL.
          lv_msg = 'Material Not in Sales Org'(001). "'Material Not in Slaes Org'
        ELSE. " ELSE -> IF lv_msg IS INITIAL
          CONCATENATE lv_msg 'Material Not in Sales Org'(001) INTO lv_msg SEPARATED BY lc_sep.
        ENDIF. " IF lv_msg IS INITIAL
      ENDIF. " IF sy-subrc IS NOT INITIAL

      IF <lfs_leg_tab_c>-charg IS NOT INITIAL.
        READ TABLE li_mch1
         INTO lwa_mch1
         WITH KEY
         matnr = <lfs_leg_tab_c>-matnr
         charg = <lfs_leg_tab_c>-charg
         BINARY SEARCH.
        SELECT SINGLE matnr  werks charg vfdat
                     FROM mcha INTO lwa_mcha WHERE
                         matnr EQ lwa_mvke-matnr
                    AND  werks EQ lwa_mvke-dwerk
                    AND  charg EQ <lfs_leg_tab_c>-charg.
* Begin of Defect - 2455
*                    AND  vfdat GT sy-datum.
* End of Defect - 2455
        IF sy-subrc IS NOT INITIAL.
          IF lv_msg IS INITIAL.
            lv_msg = 'Batch does not exist for material'(016). " Order Type not Found
          ELSE. " ELSE -> IF lv_msg IS INITIAL
            CONCATENATE lv_msg 'Batch does not exist for material'(016) INTO lv_msg SEPARATED BY lc_sep.
          ENDIF. " IF lv_msg IS INITIAL
        ENDIF. " IF sy-subrc IS NOT INITIAL
      ENDIF. " IF <lfs_leg_tab_c>-charg IS NOT INITIAL



*$ checking Shold to and Ship to Party against Sales Org
      READ TABLE li_knvv
      INTO lwa_knvv
      WITH KEY
      kunnr = <lfs_leg_tab_c>-kunnr_sp
      vkorg = <lfs_leg_tab_c>-vkorg
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
      vtweg = <lfs_leg_tab_c>-vtweg
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016

*---> Begin of Delete for CR# 3502 by U034088 on 30.08.2016
*    vtweg = gv_vtweg
*<--- End of Delete for CR# 3502 by U034088 on 30.08.2016

      BINARY SEARCH.

      IF sy-subrc IS NOT INITIAL.
*      Sold to Party is there in Sales org continue processing
        IF lv_msg IS INITIAL.
          lv_msg = 'Sold to Party Not in Sales Org'(002). "Sold to Party Not in Sales Org
        ELSE. " ELSE -> IF lv_msg IS INITIAL
          CONCATENATE lv_msg 'Sold to Party Not in Sales Org'(002) INTO lv_msg SEPARATED BY lc_sep.
        ENDIF. " IF lv_msg IS INITIAL

      ENDIF. " IF sy-subrc IS NOT INITIAL

      CLEAR : lwa_knvv.
      READ TABLE li_knvv
      INTO lwa_knvv
      WITH KEY
      kunnr = <lfs_leg_tab_c>-kunnr_sh
      vkorg = <lfs_leg_tab_c>-vkorg
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
      vtweg = <lfs_leg_tab_c>-vtweg
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016


*---> Begin of Delete for CR# 3502 by U034088 on 30.08.2016
*    vtweg = gv_vtweg
*<--- End of Delete for CR# 3502 by U034088 on 30.08.2016


      BINARY SEARCH.

      IF sy-subrc IS NOT INITIAL.
*      Ship to Party is there in Sales org continue processing
        IF lv_msg IS INITIAL.
          lv_msg = 'Ship to Party Not in Sales Org'(003). "Ship to Party Not in Sales Org
        ELSE. " ELSE -> IF lv_msg IS INITIAL
          CONCATENATE lv_msg 'Ship to Party Not in Sales Org'(003) INTO lv_msg SEPARATED BY lc_sep.
        ENDIF. " IF lv_msg IS INITIAL

      ENDIF. " IF sy-subrc IS NOT INITIAL
    ENDIF. " IF lv_msg IS INITIAL
    IF lv_msg IS INITIAL.
      APPEND <lfs_leg_tab_c> TO li_leg_suc.
    ELSE. " ELSE -> IF lv_msg IS INITIAL
      <lfs_leg_tab_c>-msgtyp = lc_emsg.
      <lfs_leg_tab_c>-error = lv_msg.
      gv_ecount = gv_ecount + 1.
      APPEND <lfs_leg_tab_c> TO li_leg_err.
      CLEAR : lv_msg.
    ENDIF. " IF lv_msg IS INITIAL

  ENDLOOP. " LOOP AT i_leg_tab_c ASSIGNING <lfs_leg_tab_c>

*$ Error in the file set the error flag
  IF li_leg_err IS NOT INITIAL.
    i_leg_tab_msg = li_leg_err. " All error data collected
    i_leg_tab_c = li_leg_suc. " Replace with success message
  ENDIF. " IF li_leg_err IS NOT INITIAL

  CLEAR :
         i_kunnr_leg, " Not required further
         li_mvke,
         li_knvv,
         li_tvak,
         li_t176,
         li_leg_err,
         li_leg_suc,
         li_leg_temp,
         lwa_mvke,
         lwa_knvv,
         lwa_tvak,
         lwa_t176,
         lv_msg .

ENDFORM. " F_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_MOVE
*&---------------------------------------------------------------------*
FORM f_move CHANGING fp_sourcefile TYPE localfile. " Local file for upload/download

* Local constants
  CONSTANTS: lc_tbp_fld    TYPE char5        VALUE   'TBP',  " constant declaration for TBP folder
             lc_done_fld   TYPE char5        VALUE   'DONE'. " constant declaration for DONE folder.

* Local Data Declaration
  DATA: lv_file TYPE localfile, " Local file for upload/download
                                " local variable declaration of type localfile
        lv_name TYPE localfile. " Local file for upload/download

  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_sourcefile
    IMPORTING
      pathname = lv_file
      filename = lv_name.

* First move the file to the Done folder
  REPLACE lc_tbp_fld  IN lv_file WITH lc_done_fld .
  CONCATENATE   lv_file  lv_name INTO lv_file.
*  Move the file
  PERFORM f_file_move  USING    fp_sourcefile
                                lv_file
                       CHANGING gv_return.
  IF gv_return IS INITIAL.
*   Exporting the archived file name in memory id 'ARCH_1'.
    gv_archive_gl_1 = lv_file.
  ENDIF. " IF gv_return IS INITIAL
  CLEAR : lv_file,
          lv_name.
ENDFORM. " F_MOVE

*&---------------------------------------------------------------------*
*&      Form  f_write_error_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FP_P_AFILE text
*      -->FP_I_ERROR text
*----------------------------------------------------------------------*
FORM f_write_error_file  USING   fp_p_afile TYPE localfile " Local file for upload/download
                                 fp_i_error TYPE ty_t_leg_tab_c.

* Local constants
  CONSTANTS: lc_tbp_fld    TYPE char5        VALUE   'TBP',   " constant declaration for TBP folder
             lc_error_fld  TYPE char5        VALUE   'ERROR', " constant declaration ERROR folder
             lc_emsg       TYPE char1        VALUE   'E'.     " Error message type of type CHAR1

* Local data
  DATA: lv_file     TYPE localfile, "File Name
        lv_name     TYPE localfile, "File Name
        lv_data     TYPE string.    "Output data string

*  Local field symbols
  FIELD-SYMBOLS : <lfs_error> TYPE ty_leg_tab_c.

* Spitting Filae Path & File Name
  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_p_afile
    IMPORTING
      pathname = lv_file
      filename = lv_name.

* Changing the file path to ERROR folder
  REPLACE lc_tbp_fld  IN lv_file WITH lc_error_fld .
  CONCATENATE lv_file lv_name INTO lv_file.

* Write the records
  OPEN DATASET lv_file FOR OUTPUT IN TEXT MODE ENCODING UTF-8. " Output type
  IF sy-subrc NE 0.
    MESSAGE i019.
  ELSE. " ELSE -> IF sy-subrc NE 0

*   Passing the Error data
    SORT fp_i_error BY lineno.

*   Transferring the Header data into application server.
    TRANSFER gv_header TO lv_file.

    LOOP AT fp_i_error ASSIGNING <lfs_error>.
      IF <lfs_error>-msgtyp = lc_emsg.
        PERFORM f_err_data_pop USING <lfs_error>
                              CHANGING lv_data.
*     Transferring the data into application server.
        TRANSFER lv_data TO lv_file.
        CLEAR lv_data.
      ENDIF. " IF <lfs_error>-msgtyp = lc_emsg
    ENDLOOP. " LOOP AT fp_i_error ASSIGNING <lfs_error>
  ENDIF. " IF sy-subrc NE 0
  CLOSE DATASET lv_file.

  CLEAR : lv_file,
          lv_name,
          lv_data.

ENDFORM. " F_WRITE_ERROR_FILE
*&---------------------------------------------------------------------*
*&      Form  F_ERR_DATA_POP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<LFS_ERROR>  text
*      <--P_LV_DATA  text
*----------------------------------------------------------------------*
FORM f_err_data_pop  USING    fp_p_error TYPE ty_leg_tab_c
                     CHANGING fp_data    TYPE string.
* Pass the error data to application server
  CONCATENATE
               fp_p_error-auart
               fp_p_error-vkorg
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
               fp_p_error-vtweg
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016
               fp_p_error-parvw_sp
               fp_p_error-kunnr_sp
               fp_p_error-parvw_sh
               fp_p_error-kunnr_sh
               fp_p_error-bstnk
               fp_p_error-bstdk_c
               fp_p_error-bsark
               fp_p_error-parvw_cp
               fp_p_error-kunnr_cp
               fp_p_error-name1
               fp_p_error-email
               fp_p_error-tele1
               fp_p_error-textid
               fp_p_error-text
               fp_p_error-textid_2
               fp_p_error-text_2
               fp_p_error-lifsk
               fp_p_error-matnr
               fp_p_error-kwmeng
               fp_p_error-charg
               fp_p_error-etdat_c
INTO fp_data
SEPARATED BY
*---> Begin of Insert for CR# 3502 by U034088 on 19.09.2016
  gv_sep.
*<--- End of Insert for CR# 3502 by U034088 on 19.09.2016

*---> Begin of delete for CR# 3502 by U034088 on 19.09.2016
* c_sep.
*<--- End of delete for CR# 3502 by U034088 on 19.09.2016


ENDFORM. " F_ERR_DATA_POP
*&---------------------------------------------------------------------*
*&      Form  F_ALL_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_all_message .
*&  Local Data Declaration
  DATA: lwa_report TYPE ty_report,
        lwa_leg_tab_c TYPE ty_leg_tab_c,
        lv_len TYPE index. " Index of the invalid record

* Local Constant
  CONSTANTS : lc_sep TYPE char1 VALUE '/',   " Sep of type CHAR1
              lc_100 TYPE char3 VALUE '100'. " 100 of type CHAR3
  SORT i_leg_tab_msg BY lineno.

  LOOP AT i_leg_tab_msg INTO lwa_leg_tab_c.

    CLEAR: lwa_report,
           lv_len.

    lwa_report-msgtyp = lwa_leg_tab_c-msgtyp.

    CONCATENATE
    lwa_leg_tab_c-auart
    lwa_leg_tab_c-vkorg
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
    lwa_leg_tab_c-vtweg
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016
    lwa_leg_tab_c-parvw_sp
    lwa_leg_tab_c-kunnr_sp
    lwa_leg_tab_c-parvw_sh
    lwa_leg_tab_c-kunnr_sh
    lwa_leg_tab_c-bstnk
    INTO
    lwa_report-key
    SEPARATED BY lc_sep.

*---> Begin of Insert for Defect# 2741 by U034088 on 27.07.2016
    lwa_report-auart    =       lwa_leg_tab_c-auart .
    lwa_report-vkorg    =       lwa_leg_tab_c-vkorg .
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
    lwa_report-vtweg    =       lwa_leg_tab_c-vtweg .
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016
    lwa_report-parvw_sp =       lwa_leg_tab_c-parvw_sp  .
    lwa_report-kunnr_sp =       lwa_leg_tab_c-kunnr_sp  .
    lwa_report-parvw_sh =       lwa_leg_tab_c-parvw_sh  .
    lwa_report-kunnr_sh =       lwa_leg_tab_c-kunnr_sh  .
    lwa_report-bstnk    =       lwa_leg_tab_c-bstnk .
    lwa_report-posnr    =       lwa_leg_tab_c-posnr .
*<--- End of Insert for Defect# 2741 by U034088 on 27.07.2016
    lwa_report-msgtxt = lwa_leg_tab_c-error.
    APPEND lwa_report TO i_report.
** In case the Multiple Messages which resulted more than 100 char
** Display Multiple line with same key
*    DO.
*      CLEAR : lwa_report-msgtxt.
*      lwa_report-msgtxt = lwa_leg_tab_c-error+lv_len(lc_100).
*      CONDENSE : lwa_report-msgtxt.
*      IF lwa_report-msgtxt IS NOT INITIAL.
*        lv_len = lv_len + lc_100.
*        APPEND lwa_report TO i_report.
*      ELSE. " ELSE -> IF lwa_report-msgtxt IS NOT INITIAL
*        EXIT.
*      ENDIF. " IF lwa_report-msgtxt IS NOT INITIAL
*    ENDDO.

  ENDLOOP. " LOOP AT i_leg_tab_msg INTO lwa_leg_tab_c
  CLEAR : lwa_leg_tab_c,
          lwa_report,
          lv_len.
ENDFORM. " F_ALL_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CONVERSSION
*&---------------------------------------------------------------------*
*       Convertinf the Input Fields
*----------------------------------------------------------------------*
*      <--P_LWA_LEG_TAB_C  text
*----------------------------------------------------------------------*
FORM f_field_converssion  CHANGING
                          fp_lwa_leg_tab_c TYPE ty_leg_tab_c.
  DATA : lv_langu TYPE langu. " Language Key
  CONSTANTS : lc_langu TYPE langu VALUE 'E'. " Language Key
*&--Converting the PO Date to internal Format
  CONCATENATE   fp_lwa_leg_tab_c-bstdk_c+6(4)
                fp_lwa_leg_tab_c-bstdk_c+0(2)
                fp_lwa_leg_tab_c-bstdk_c+3(2)
    INTO        fp_lwa_leg_tab_c-bstdk.

*&--Converting the Delivery Date to internal Format
  CONCATENATE   fp_lwa_leg_tab_c-etdat_c+6(4)
                fp_lwa_leg_tab_c-etdat_c+0(2)
                fp_lwa_leg_tab_c-etdat_c+3(2)
    INTO        fp_lwa_leg_tab_c-etdat.

* Reseting syatem Language for Converssion as it will only execuated for English
* Set Language not working so cahneg the sy-langu directly, This Language functionality
* only effected withing this form.
  lv_langu = sy-langu.
  sy-langu = lc_langu. " Reset the Language in English
*&--Converting Sold to party function to Internal format
  CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
    EXPORTING
      input  = fp_lwa_leg_tab_c-parvw_sp
    IMPORTING
      output = fp_lwa_leg_tab_c-parvw_sp.

*&--Converting Ship to party function to Internal format
  CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
    EXPORTING
      input  = fp_lwa_leg_tab_c-parvw_sh
    IMPORTING
      output = fp_lwa_leg_tab_c-parvw_sh.

*&--Converting Contact Person function to Internal format
  CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
    EXPORTING
      input  = fp_lwa_leg_tab_c-parvw_cp
    IMPORTING
      output = fp_lwa_leg_tab_c-parvw_cp.

*&--Converting sold to Customer to Internal format
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fp_lwa_leg_tab_c-kunnr_sp
    IMPORTING
      output = fp_lwa_leg_tab_c-kunnr_sp.

*&--Converting Ship to Customer to Internal format
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fp_lwa_leg_tab_c-kunnr_sh
    IMPORTING
      output = fp_lwa_leg_tab_c-kunnr_sh.

*&--Converting Contact Person to Internal format
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fp_lwa_leg_tab_c-kunnr_cp
    IMPORTING
      output = fp_lwa_leg_tab_c-kunnr_cp.

*&--Converting Text id to Internal format
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fp_lwa_leg_tab_c-textid
    IMPORTING
      output = fp_lwa_leg_tab_c-textid.

*&--Converting Text id to Internal format for second ID
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fp_lwa_leg_tab_c-textid_2
    IMPORTING
      output = fp_lwa_leg_tab_c-textid_2.
  sy-langu = lv_langu. " Reset the logon language
  CLEAR : lv_langu.
ENDFORM. " F_FIELD_CONVERSSION


*---> Begin of Insert for Defect# 2741 by U034088 on 27.07.2016
*       This form copied from common Inclue f_display_summary_report2  *
*       and change the type of final internal table for display        *

*&---------------------------------------------------------------------*
*&      Form  f_display_summary_report3
*&---------------------------------------------------------------------*
*       Dispalying Summary Report for ONE INPUT FILE.
*&---------------------------------------------------------------------*
*      -->FP_P_REPORT     Report Table
*      -->FP_gv_filename_d  Input File Name
*      -->FP_GV_MODE      Mode of execution of program
*      -->FP_NO_SUCCESS   Number of successfully processed record.
*      -->FP_NO_FAILED    Number of record failed.
*----------------------------------------------------------------------*
FORM f_display_summary_report3 USING fp_i_report      TYPE ty_t_report
                                    fp_gv_filename_d TYPE localfile " Local file for upload/download
                                    fp_gv_mode       TYPE char10    " Gv_mode of type CHAR10
                                    fp_no_success  TYPE int4        " 2 byte integer (signed)
                                    fp_no_failed   TYPE int4.       " 2 byte integer (signed)
* Local Data declaration

*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
  TYPES: BEGIN OF lty_report_b,
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016

*---> Begin of Delete for CR# 3502 by U034088 on 30.08.2016
*   TYPES: BEGIN OF ty_report_b,
*<--- End of Delete for CR# 3502 by U034088 on 30.08.2016


       msgtyp TYPE char1,   "Error Type
       msgtxt TYPE char256, "Error Text
       key    TYPE char256, "Error Key
*---> Begin of Insert for Defect# 2741 by U034088  on 27.07.2016
** Fields are added for displaying the final table  as per
** business requirement
         posnr TYPE posnr_va,      " Sales Document Item
         auart       TYPE  auart,  " Sales Document Type
         vkorg       TYPE  vkorg , " Sales Organization
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
         vtweg       TYPE vtweg, " Distribution Channel
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016
         parvw_sp    TYPE  parvw , " Partner Function
         kunnr_sp    TYPE  kunnr , " Customer Number
         parvw_sh    TYPE  parvw , " Partner Function
         kunnr_sh    TYPE  kunnr , " Customer Number
         bstnk       TYPE  bstnk,  " Customer purchase order number
*<---- End of Insert for Defect# 2741 by U034088 on 27.07.2016

*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
      END OF lty_report_b.
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016

*---> Begin of Delete for CR# 3502 by U034088 on 30.08.2016
*         END OF ty_report_b.
*<--- End of Delete for CR# 3502 by U034088 on 30.08.2016

  CONSTANTS: c_hline TYPE char100                                         " Dotted Line
             VALUE
'-----------------------------------------------------------',
              c_slash TYPE char1 VALUE '/',                               " Slash of type CHAR1
              lc_150 TYPE char3 VALUE '150',                              " 150 of type CHAR3
              lc_int_table_name TYPE  slis_tabname  VALUE 'LI_REPORT_B' , " internal table anme
              lc_msg_typ  TYPE  slis_fieldname  VALUE 'MSGTYP'  ,         " Field name
              lc_msg_text TYPE  lvc_fname  VALUE 'MSGTXT'  ,              "Field name
              lc_key  TYPE  lvc_fname  VALUE 'KEY' ,                      " Field name
              lc_event_top  TYPE  char11  VALUE 'TOP_OF_PAGE' ,           " Event name
              lc_event_top_form TYPE  char15  VALUE 'F_TOP_OF_PAGE10' ,   " Event Name
              lc_posnr  TYPE  lvc_fname  VALUE 'POSNR' ,                  " Field name
              lc_error  TYPE  char01  VALUE  'E'  ,                       " Error Message type
              lc_success  TYPE  char01  VALUE  'S'  ,                     " Success message type
              lc_collon TYPE  char01  VALUE  ':'  .                       " Collon


  DATA:
*---> Begin of Delete for CR# 3502 by U034088 on 30.08.2016
*        li_report      TYPE STANDARD TABLE OF ty_report_b
*                                                     INITIAL SIZE 0,
*<--- End of Delete for CR# 3502 by U034088 on 30.08.2016
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
        li_report      TYPE STANDARD TABLE OF lty_report_b
                                                     INITIAL SIZE 0,
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016
        lv_uzeit       TYPE char20,                          "Time
        lv_datum       TYPE char20,                          "Date
        lv_total       TYPE int4,                            "Total
        lv_rate        TYPE int4,                            "Rate
        lv_rate_c      TYPE char5,                           "Rate text
        lv_alv         TYPE REF TO cl_salv_table,            "ALV Inst.
        lv_ex_msg      TYPE REF TO cx_salv_msg,              "Message
        lv_ex_notfound TYPE REF TO cx_salv_not_found,        "Exception
        lv_grid        TYPE REF TO cl_salv_form_layout_grid, "Grid
        lv_gridx       TYPE REF TO cl_salv_form_layout_grid, "Grid X
        lv_column      TYPE REF TO cl_salv_column_table,     "Column
        lv_columns     TYPE REF TO cl_salv_columns_table,    "Column X
        lv_func        TYPE REF TO cl_salv_functions_list,   "Toolbar
        lv_archive_1   TYPE localfile,                       "Archieve File Path
        lv_session_1   TYPE apq_grpn,                        "BDC Session Name
        lv_session_2   TYPE apq_grpn,                        "BDC Session Name
        lv_session_3   TYPE apq_grpn,                        "BDC Session Name
        lv_session     TYPE char90,                          "All session names
        lv_row         TYPE int4,                            "Row number
        lv_width_msg   TYPE outputlen,                       "Column Width
        lv_width_key   TYPE outputlen,                       "Column Width
        li_fieldcat    TYPE slis_t_fieldcat_alv,             "Field Catalog
        li_events      TYPE slis_t_event,
        lwa_events     TYPE slis_alv_event,

*---> Begin of Delete for CR# 3502 by U034088 on 30.08.2016
*       li_report_b    TYPE STANDARD TABLE OF ty_report_b INITIAL SIZE 0,
*      lwa_report_b   TYPE ty_report_b,
*<--- End of Delete for CR# 3502 by U034088 on 30.08.2016
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
      li_report_b    TYPE STANDARD TABLE OF lty_report_b INITIAL SIZE 0,
      lwa_report_b   TYPE lty_report_b,
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016

        lv_text        TYPE scrtext_l. " Long Field Label

  FIELD-SYMBOLS: <lfs_report> TYPE ty_report.
* Getting the archieve file path from Global Variables
  lv_archive_1 = gv_archive_gl_1.

* Importing the First Session Names
  lv_session_1 = gv_session_gl_1.

* Importing the Second Session Names
  lv_session_2 = gv_session_gl_2.

* Importing the Third Session Names
  lv_session_3 = gv_session_gl_3.

* Forming the BDC session name
  IF lv_session_1 IS NOT INITIAL.
    lv_session = lv_session_1.
  ENDIF. " IF lv_session_1 IS NOT INITIAL

  IF lv_session_2 IS NOT INITIAL.
    IF lv_session IS NOT INITIAL.
      CONCATENATE lv_session c_slash lv_session_2
      INTO lv_session SEPARATED BY space.
    ELSE. " ELSE -> IF lv_session IS NOT INITIAL
      lv_session = lv_session_2.
    ENDIF. " IF lv_session IS NOT INITIAL
  ENDIF. " IF lv_session_2 IS NOT INITIAL

  IF lv_session_3 IS NOT INITIAL.
    IF lv_session IS NOT INITIAL.
      CONCATENATE lv_session c_slash lv_session_3
      INTO lv_session SEPARATED BY space.
    ELSE. " ELSE -> IF lv_session IS NOT INITIAL
      lv_session = lv_session_3.
    ENDIF. " IF lv_session IS NOT INITIAL
  ENDIF. " IF lv_session_3 IS NOT INITIAL

  IF lv_session IS NOT INITIAL.
    CONCATENATE lv_session '(Please run SM35 to process the BDC Sessions)'(x32)
    INTO lv_session
    SEPARATED BY space.
  ENDIF. " IF lv_session IS NOT INITIAL


  LOOP AT fp_i_report ASSIGNING <lfs_report>.
    lwa_report_b-msgtyp = <lfs_report>-msgtyp.
    lwa_report_b-msgtxt = <lfs_report>-msgtxt.
    lwa_report_b-key = <lfs_report>-key.
*---> Begin of Insert for Defect# 2741 by U034088 on 27.07.2016
    lwa_report_b-auart    =       <lfs_report>-auart  .
    lwa_report_b-vkorg    =       <lfs_report>-vkorg  .
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
    lwa_report_b-vtweg    =       <lfs_report>-vtweg.
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016
    lwa_report_b-parvw_sp =       <lfs_report>-parvw_sp .
    lwa_report_b-kunnr_sp =       <lfs_report>-kunnr_sp .
    lwa_report_b-parvw_sh =       <lfs_report>-parvw_sh .
    lwa_report_b-kunnr_sh =       <lfs_report>-kunnr_sh .
    lwa_report_b-bstnk    =       <lfs_report>-bstnk  .
    lwa_report_b-posnr    =       <lfs_report>-posnr  .
*<--- End of Insert for Defect# 2741 by U034088  on 27.07.2016
    APPEND lwa_report_b TO li_report.
    CLEAR lwa_report_b.
  ENDLOOP. " LOOP AT fp_i_report ASSIGNING <lfs_report>

  WRITE sy-uzeit TO lv_uzeit.
  WRITE sy-datum TO lv_datum.
  CONCATENATE lv_datum lv_uzeit INTO lv_datum SEPARATED BY space.

  lv_total = fp_no_success + fp_no_failed.
  IF lv_total <> 0.
    lv_rate = 100 * fp_no_success / lv_total.
  ENDIF. " IF lv_total <> 0

  WRITE lv_rate TO lv_rate_c.
  CONDENSE lv_rate_c.
  CONCATENATE lv_rate_c c_percentage INTO lv_rate_c SEPARATED BY space.

* For ONLINE run, ALV Grid Display
  IF sy-batch IS INITIAL.

    TRY.
        CALL METHOD cl_salv_table=>factory
          IMPORTING
            r_salv_table = lv_alv
          CHANGING
            t_table      = li_report.
      CATCH cx_salv_msg INTO lv_ex_msg.
        MESSAGE lv_ex_msg TYPE lc_error.
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE lc_error.
    ENDTRY.

    CREATE OBJECT lv_grid.
    lv_row = 1.
    lv_grid->create_header_information( row     = lv_row
                                        column  = lv_row
                                        text    = 'Run Information'(x01)
                                        tooltip = 'File Read'(x02) ).

    lv_row = lv_row + 1.
    lv_gridx = lv_grid->create_grid( row = lv_row  column = 1  ).

    lv_gridx->create_label( row = lv_row column = 1
                           text = c_hline ).
    lv_row = lv_row + 1.
* File Read
    lv_gridx->create_label( row = lv_row column = 1
                            text = 'File Read'(x02) tooltip = 'File Read'(x02) ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_collon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = fp_gv_filename_d ).

    lv_row = lv_row + 1.
* File Archived.
    IF lv_archive_1 IS NOT INITIAL.
      lv_gridx->create_label( row = lv_row column = 1
                              text = 'File Archived:'(x28) tooltip = 'File Archived:'(x28) ).
      lv_gridx->create_label( row = lv_row column = 2
                              text = lc_collon ).
      lv_gridx->create_label( row = lv_row column = 3
                              text = lv_archive_1 ).
      lv_row = lv_row + 1.
    ENDIF. " IF lv_archive_1 IS NOT INITIAL

    lv_gridx->create_label( row = lv_row column = 1
                            text = 'Client'(x03) tooltip = 'Client'(x03) ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_collon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = sy-mandt ).
    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                           text = 'Run By / User ID'(x04) tooltip = 'Run By / User ID'(x04) ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_collon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = sy-uname ).
    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                           text = 'Date / Time'(x05) tooltip = 'Date / Time'(x05) ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_collon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = lv_datum ).
    lv_row = lv_row + 1.

    lv_gridx->create_label( row = lv_row column = 1
                           text = 'Execution Mode'(x06) tooltip = 'Execution Mode'(x06) ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_collon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = fp_gv_mode ).
    lv_row = lv_row + 1.

    IF lv_session IS NOT INITIAL.
      lv_gridx->create_label( row = lv_row column = 1
                             text = 'BDC Session Name:'(x29)
                             tooltip = 'BDC Session Name:'(x29) ).
      lv_gridx->create_label( row = lv_row column = 2
                              text = lc_collon ).
      lv_gridx->create_label( row = lv_row column = 3
                              text = lv_session ).
      lv_row = lv_row + 1.
    ENDIF. " IF lv_session IS NOT INITIAL

    lv_gridx->add_row( ).

    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                           text = c_hline ).
    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                         text = 'Total no of records in given file'(x08) ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_collon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = lv_total ).
    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                         text = 'No of success records'(x09) ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_collon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = fp_no_success ).
    lv_row = lv_row + 1.

    lv_gridx->create_label( row = lv_row column = 1
                         text = 'No of error records'(x10) ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_collon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = fp_no_failed ).
    lv_row = lv_row + 1.

    lv_gridx->create_label( row = lv_row column = 1
                         text = 'Success Rate'(x11) ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_collon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = lv_rate_c ).

    lv_row = lv_row + 1.

    lv_gridx->create_label( row = lv_row column = 1
                           text = c_hline ).

    CALL METHOD lv_alv->set_top_of_list( lv_grid ).

    CALL METHOD lv_alv->get_columns
      RECEIVING
        value = lv_columns.

    TRY.
        lv_column ?= lv_columns->get_column( lc_msg_typ ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE lc_error.
    ENDTRY.
    lv_column->set_short_text( 'Status'(x12) ).
    lv_column->set_medium_text( 'Status'(x12) ).
    lv_column->set_long_text( 'Status'(x12) ).
*   lv_column->set_output_length( 20 ).
    lv_columns->set_optimize( 'X' ).

    TRY.
        lv_column ?= lv_columns->get_column( lc_msg_text ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE lc_error.
    ENDTRY.

    IF rb_verif = abap_true.
      lv_column->set_short_text( 'Message'(x13) ).
      lv_column->set_medium_text( 'Message'(x13) ).
      lv_column->set_long_text( 'Message'(x13) ).
      lv_columns->set_optimize( 'X' ).
    ELSE. " ELSE -> IF rb_verif = abap_true
      lv_column->set_short_text( 'Sale Order'(x33) ).
      lv_column->set_medium_text( 'Sale Order'(x33) ).
      lv_column->set_long_text( 'Sale Order'(x33) ).
      lv_columns->set_optimize( 'X' ).
    ENDIF. " IF rb_verif = abap_true

    TRY.
        lv_column ?= lv_columns->get_column( lc_key ).
*---> Begin of Insert for Defect# 2741 by U034088 on 27.07.2016
        lv_column->set_technical( if_salv_c_bool_sap=>true ). " Hide Column Key
*<--- End of Insert for Defect# 2741 by U034088 on 27.07.2016
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE lc_error.
    ENDTRY.
    lv_column->set_short_text( 'Key'(x14) ).
    lv_column->set_medium_text( 'Key'(x14) ).
    lv_column->set_long_text( 'Key'(x14) ).
    lv_columns->set_optimize( 'X' ).

*---> Begin of Insert for Defect# 2741 by U034088 on 27.07.2016
*Hide the fieldSlaes Document Item if the Value is Blank
* In production run and with success Sales order line willl be populated
    IF rb_verif = abap_true OR gv_scount IS INITIAL.
      TRY.
          lv_column ?= lv_columns->get_column( lc_posnr ).
          lv_column->set_technical( if_salv_c_bool_sap=>true ). " Hide Column Key
        CATCH  cx_salv_not_found INTO lv_ex_notfound.
          MESSAGE lv_ex_notfound TYPE lc_error.
      ENDTRY.
    ENDIF. " IF rb_verif = abap_true OR gv_scount IS INITIAL
*<--- End of Insert for Defect# 2741 by U034088 on 27.07.2016
* Function Tool bars
    lv_func = lv_alv->get_functions( ).
    lv_func->set_all( ).

* Displaying the report
    CALL METHOD lv_alv->display( ).

* For Background Run - ALV List
  ELSE. " ELSE -> IF sy-batch IS INITIAL
*   Passing local variable values to global variable to make it
*   avilable in top of page subroutine.
    gv_filename_d = fp_gv_filename_d.
    gv_filename_d_arch = lv_archive_1.
    gv_mode_b = fp_gv_mode.
    gv_session = lv_session.
    gv_total = lv_total.
    gv_no_success4 = fp_no_success.
    gv_no_failed4 = fp_no_failed.
    gv_rate_c = lv_rate_c.

    LOOP AT fp_i_report ASSIGNING <lfs_report>.
      lwa_report_b-msgtyp = <lfs_report>-msgtyp.
      lwa_report_b-msgtxt = <lfs_report>-msgtxt.
      lwa_report_b-key = <lfs_report>-key.
*     Getting the maximum length of columns MSGTXT.
      IF lv_width_msg   LT strlen( <lfs_report>-msgtxt ).
        lv_width_msg = strlen( <lfs_report>-msgtxt ).
      ENDIF. " IF lv_width_msg LT strlen( <lfs_report>-msgtxt )
*     Getting the maximum length of column KEY.
      IF lv_width_key   LT strlen( <lfs_report>-key ).
        lv_width_key = strlen( <lfs_report>-key ).
      ENDIF. " IF lv_width_key LT strlen( <lfs_report>-key )
      APPEND lwa_report_b TO li_report_b.
      CLEAR lwa_report_b.
    ENDLOOP. " LOOP AT fp_i_report ASSIGNING <lfs_report>

    IF lv_width_key LT lc_150.
      lv_width_key = lc_150.
    ENDIF. " IF lv_width_key LT lc_150

*   Preparing Field Catalog.
*   Message Type
    PERFORM f_fill_fieldcat USING lc_msg_typ
                                  lc_int_table_name
                                  'Status'(x12)
                                  7
                          CHANGING li_fieldcat[].

    IF rb_verif = abap_true.
      lv_text = 'Message'(x13).
    ELSE. " ELSE -> IF rb_verif = abap_true
      lv_text = 'Sales Order'(x33).
    ENDIF. " IF rb_verif = abap_true

    PERFORM f_fill_fieldcat USING lc_msg_text
                                  lc_int_table_name
                                  lv_text "'Message'(x13)
                                  lv_width_msg
                          CHANGING li_fieldcat[].
*   Message Key
    PERFORM f_fill_fieldcat USING lc_key
                                  lc_int_table_name
                                  'Key'(x14)
                                  lv_width_key
                          CHANGING li_fieldcat[].
*   Top of page subroutine
    lwa_events-name = lc_event_top.
    lwa_events-form = lc_event_top_form.
    APPEND lwa_events TO li_events.
    CLEAR lwa_events.

*   ALV List Display for Background Run
    CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
      EXPORTING
        i_callback_program = sy-repid
        it_fieldcat        = li_fieldcat
        it_events          = li_events
      TABLES
        t_outtab           = li_report_b
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
      MESSAGE e002(zca_msg). " Invalid file name. Please check your entry.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF sy-batch IS INITIAL

ENDFORM. "display_summary_report3
*<--- End of Insert for Defect# 2741 by U034088 on 27.07.2016


* <--- Begin of  Insert for CR#D3_227 by  APAUL
*&---------------------------------------------------------------------*
*&      Form  f_split_lord
*&---------------------------------------------------------------------*
*       Determine the sales organisation based on customer and  material
*&---------------------------------------------------------------------*
*      -->fp_matnr        Material Number
*      -->fp_kunnr_sp     Customer Number
*      -->fp_vkorg        Sales Organization
*----------------------------------------------------------------------*

FORM f_split_lord USING  fp_matnr     TYPE matnr    " Material Number
                         fp_kunnr_sp  TYPE    kunnr " Customer Number
                         fp_vkorg     TYPE vkorg    " Sales Organization
* Begin of Defect 10523
                         fp_msgtyp    TYPE char1     " Msgtyp of type CHAR1
                         fp_error     TYPE char1024. " Error of type CHAR1024
* End of Defect 10523
* Data declaration
  DATA :
        lwa_item         TYPE  zotc_850_so_item,             " Sales Order Item for IDD 0009 - 850
        li_item          TYPE   zotc_tt_850_so_item,
        lref_object      TYPE REF TO zotc_cl_inb_so_edi_850, " Inbound Sales Order EDI 850
        lv_land1         TYPE land1,                         " Country Key
        lv_lrd           TYPE char1,                         " Lrd of type CHAR1
        lv_skip          TYPE char1 .                        " Skip of type CHAR1

* Field symbol declaration
  FIELD-SYMBOLS:  <lfs_item>        TYPE  zotc_850_so_item . " Sales Order Item for IDD 0009 - 850

  CREATE OBJECT lref_object.

* Populate item  with matnr
  lwa_item-matnr =  fp_matnr.
  APPEND lwa_item TO    li_item      .


* Determine LRD or Non Lrd  based on customer
  CALL METHOD lref_object->determine_sold_to_country
    EXPORTING
      im_kunnr_sp = fp_kunnr_sp
    IMPORTING
      ex_land1    = lv_land1
      ex_lrd      = lv_lrd
      ex_skip     = lv_skip.
* Begin of Defect 10523
  DATA : li_bapi_msg TYPE  bapirettab,
         ls_ret  TYPE bapiret2. " Return Parameter
  CALL METHOD lref_object->vaidate_material
    EXPORTING
      im_item            = li_item
    IMPORTING
      ex_bapi_msg        = li_bapi_msg
    EXCEPTIONS
      material_not_found = 1
      OTHERS             = 2.
  IF sy-subrc EQ 0.

* End of Defect 10523
*** Check to see if the split logic needs to skipped
    IF lv_skip EQ abap_false.
* LRD Orders
      IF lv_lrd EQ abap_true.
        CALL METHOD lref_object->process_lrd
          EXPORTING
            im_land1 = lv_land1
          CHANGING
            ch_item  = li_item
* Begin of change for Defect 9812-U033876
                EXCEPTIONS
                  material_class_not_found = 1
                  OTHERS                   = 2.
* End of change for defect 9812
      ELSE. " ELSE -> IF lv_lrd EQ abap_true
* Non LRD Orders
        CALL METHOD lref_object->process_nlrd
          CHANGING
            ch_item = li_item
* Begin of change for Defect 9812-U033876
                EXCEPTIONS
                  lab_office_not_maintained = 1
                  OTHERS                   = 2.
* End of change for defect 9812
      ENDIF. " IF lv_lrd EQ abap_true
*    ls_head = im_head.
    ENDIF    . " IF lv_skip EQ abap_false
  ELSE. " ELSE -> IF sy-subrc EQ 0
    READ TABLE li_bapi_msg INTO ls_ret INDEX 1.
    IF sy-subrc EQ 0.
      READ TABLE li_item    ASSIGNING <lfs_item> INDEX 1.
      IF sy-subrc EQ 0.
        <lfs_item>-type = ls_ret-type.
        <lfs_item>-message = ls_ret-message.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
*   Populate Sales organisation
  READ TABLE li_item    ASSIGNING <lfs_item> INDEX 1.
  IF sy-subrc  EQ 0.
    fp_vkorg =  <lfs_item>-vkorg  .
    fp_msgtyp = <lfs_item>-type.
    fp_error = <lfs_item>-message.
  ENDIF. " IF sy-subrc EQ 0


  CLEAR :  lv_land1,
           lv_lrd  ,
           lv_skip,
           lwa_item,
           li_item.


ENDFORM. "f_split_lord
* <--- End  of  Insert for CR#D3_227 by  APAUL

* ---> Begin of Change for D3_OTC_EDD_0347_CR#378 by NALI
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_P_VKBUR
*&---------------------------------------------------------------------*
*       Validate Sales Office
*----------------------------------------------------------------------*
*      -->FP_VKBUR  Sales Office
*----------------------------------------------------------------------*
FORM f_validate_p_vkbur  USING    fp_vkbur  TYPE vkbur. " Sales Office
  DATA: lv_vkbur  TYPE vkbur. " Sales Office
  SELECT SINGLE vkbur " Sales Office
    FROM tvbur        " Organizational Unit: Sales Offices
    INTO lv_vkbur
    WHERE vkbur = fp_vkbur.
  IF sy-subrc NE 0.
    MESSAGE e297.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_P_VKBUR
* <--- End of Change for D3_OTC_EDD_0347_CR#378 by NALI
