***********************************************************************
*Program    : ZOTCN0093B_SEND_PRICE_LIST_SUB                          *
*Title      : Send Price List                                         *
*Developer  : Salman Zahir                                            *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_EDD_0093                                           *
*---------------------------------------------------------------------*
*Description: This interface program send  price list to application  *
*             server in a text file format                            *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:                                                *
*=====================================================================*
*Date           User        Transport       Description               *
*=========== ============== ============== ===========================*
*22-NOV-2016    U033959     E1DK918891      Initial development for   *
*                                           CR#249 and CR#255         *
*25-Jan-2016    JAHANM      E1DK925112      Defect#8361 change app.   *
*                                           server inactive file name *
*10-Jun-2019    SMUKHER     E2DK924514      SCTASK0834302 Defect# 8512*
*                                           Price Interface from SAP to
*                                           DiagDirect requires the   *
*                                           Bill-To partner code to be*
*                                           sent as well.             *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_path_pserv
*&---------------------------------------------------------------------*
*       Modify Screen
*----------------------------------------------------------------------*
FORM f_modify_screen .

  LOOP AT SCREEN .
    IF rb_pres NE c_true.
      IF screen-group1    = c_groupmi3.
        CLEAR: p_phdr.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
    ELSE. " ELSE -> IF rb_pres NE c_true
      IF screen-group1 = c_groupmi3.
        screen-active = c_one.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
    ENDIF. " IF rb_pres NE c_true
    IF rb_app NE c_true.
      IF screen-group1 = c_groupmi2 OR
         screen-group1 = c_groupmi5 OR
         screen-group1 = c_groupmi7.
        CLEAR: p_ahdr,
               p_alog.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi2 OR
    ELSE. " ELSE -> IF rb_app NE c_true
      IF rb_aphy EQ abap_true. "appliction server physical path selected
*   clear presentation server and application server logical file path.
        CLEAR: p_alog,
               p_phdr.
      ELSEIF rb_alog EQ abap_true. "IF rb_aphy eq abap_true.
*   clear presentation server and application server physical file path.
        CLEAR: p_ahdr,
               p_phdr.
      ENDIF. " IF rb_aphy EQ abap_true
    ENDIF. " IF rb_app NE c_true
  ENDLOOP. " LOOP AT SCREEN

ENDFORM. " F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  f_path_pserv
*&---------------------------------------------------------------------*
*       Determine file path
*----------------------------------------------------------------------*
*      <--FP_V_FILENAME  file path
*----------------------------------------------------------------------*
FORM f_path_pserv  CHANGING fp_v_filename TYPE localfile. " Local file for upload/download.

  CONSTANTS : lc_file_ext   TYPE string  VALUE 'txt',          " File extension
              lc_otc_0093   TYPE char12  VALUE 'OTC_IDD_0093', " Otc_0093 of type CHAR12
              lc_underscore TYPE char1   VALUE '_'.            " Underscore of type CHAR1

  DATA: lv_file_name    TYPE string,    " File name
        lv_file_path    TYPE string,    " File path
        lv_full_path    TYPE string,    " File name + pat
        lv_default_file TYPE string,    " Default file
        lv_time         TYPE string,    " Timestamp
        lv_timestamp    TYPE timestamp. " UTC Time Stamp in Short Form (YYYYMMDDhhmmss)


* Get time stamp
  GET TIME STAMP FIELD lv_timestamp.
  IF sy-subrc IS INITIAL.
    lv_time = lv_timestamp.
  ENDIF. " IF sy-subrc IS INITIAL

* Presentation server file name
  IF rb_act IS NOT INITIAL.
    CONCATENATE lc_otc_0093
                p_cond
                p_tab
                lv_time
           INTO lv_default_file
           SEPARATED BY lc_underscore.
  ELSEIF rb_inact IS NOT INITIAL.
*&->Start of Defect#8361 by Jahan.
*    CONCATENATE lc_otc_0093
*                p_cond
*                p_tab
*                'Inactive'(023)
*                lv_time
*           INTO lv_default_file
*           SEPARATED BY lc_underscore.

    CONCATENATE 'CustomerPriceInactive'(029)
                lv_time
           INTO lv_default_file
           SEPARATED BY lc_underscore.
*&->End of Defect#8361 by Jahan.

  ENDIF. " IF rb_act IS NOT INITIAL

* Call metod for opening file saving dialog box
  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      default_extension         = lc_file_ext
      default_file_name         = lv_default_file
    CHANGING
      filename                  = lv_file_name
      path                      = lv_file_path
      fullpath                  = lv_full_path
    EXCEPTIONS
      cntl_error                = 1
      error_no_gui              = 2
      not_supported_by_gui      = 3
      invalid_default_file_name = 4.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE. " ELSE -> IF sy-subrc NE 0
* Return full file path on presentation server
    fp_v_filename = lv_full_path.

  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_PATH_PSERV
*&---------------------------------------------------------------------*
*&      Form  f_validate_input
*&---------------------------------------------------------------------*
*       Validate Input
*----------------------------------------------------------------------*
FORM f_validate_input .
* Local Data Declaration
  DATA : lv_kschl TYPE kschl. " Condition Type
  IF p_cond IS NOT INITIAL.
* Validating the Condition Record
    SELECT SINGLE kschl " Condition Type
           FROM t685    " Conditions: Types
           INTO lv_kschl
           WHERE kvewe = c_cond_use
           AND   kappl = c_app
           AND   kschl = p_cond.
    IF sy-subrc <> 0.
      MESSAGE e040(zotc_msg). " Invalid Condition Type
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF p_cond IS NOT INITIAL
ENDFORM. " F_VALIDATE_INPUT
*&---------------------------------------------------------------------*
*&      Form  f_validate_input2
*&---------------------------------------------------------------------*
*       Validate Input
*----------------------------------------------------------------------*
FORM f_validate_input2 .

  DATA : lv_kotabnr TYPE kotabnr. " Condition table
  IF  p_tab  IS NOT INITIAL.
* Validating the Condition Record Table
    SELECT SINGLE kotabnr " Condition table
     FROM t681            " Conditions: Structures
     INTO lv_kotabnr
      WHERE kvewe   = c_cond_use
      AND   kotabnr = p_tab
      AND   kappl   = c_app.
    IF sy-subrc <> 0.
      MESSAGE e041(zotc_msg). " Invalid Access Sequence
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF p_tab IS NOT INITIAL
ENDFORM. " F_VALIDATE_INPUT2
*&---------------------------------------------------------------------*
*&      Form  f_fetch_records
*&---------------------------------------------------------------------*
*       Fetch pricing records
*----------------------------------------------------------------------*
*      -->FP_ACT     Active  flag
*      -->FP_INACT   Inactive flag
*      <--FP_I_FINAL Final table for pricing reocrds
*----------------------------------------------------------------------*
FORM f_fetch_records  USING      fp_act       TYPE char1      " Fetch_records using fp_ of type CHAR1
                                 fp_inact     TYPE char1      " Inact of type CHAR1
                      CHANGING   fp_i_final   TYPE ty_t_final " Final table
                                 fp_key_date  TYPE sy-datum.  " Current Date of Application Server

  CONSTANTS : lc_kschl TYPE name_feld VALUE 'KSCHL', " Field name
              lc_knumh TYPE name_feld VALUE 'KNUMH', " Field name
              lc_vkorg TYPE name_feld VALUE 'VKORG', " Field name
              lc_datbi TYPE name_feld VALUE 'DATBI', " Field name
              lc_datab TYPE name_feld VALUE 'DATAB', " Field name
              lc_kunag TYPE name_feld VALUE 'KUNAG', " Field name
              lc_kunnr TYPE name_feld VALUE 'KUNNR', " Field name
              lc_kunwe TYPE name_feld VALUE 'KUNWE', " Field name
              lc_matnr TYPE name_feld VALUE 'MATNR', " Field name
              lc_pipe  TYPE char1 VALUE '|'.         " Pipe of type CHAR1

  TYPES : BEGIN OF lty_konp,
            knumh    TYPE knumh,       " Condition record number
            kopos    TYPE kopos,       " Sequential number of the condition
            kschl    TYPE kschl,       " Condition Type
            kbetr    TYPE kbetr_kond,  " Rate (condition amount or percentage) where no scale exists
            konwa    TYPE konwa,       " Rate unit (currency or percentage)
            loevm_ko TYPE loevm_ko,    " Deletion Indicator for Condition Item
          END OF lty_konp,
          BEGIN OF lty_knumh,
            knumh TYPE knumh,           " Condition record number
          END OF lty_knumh,
          BEGIN OF lty_vkorg,
            vkorg TYPE vkorg,           " Sales Organization
          END OF lty_vkorg,
          BEGIN OF lty_tvko,
            vkorg TYPE vkorg,           " Sales Organization
            adrnr TYPE adrnr,           " Address
          END OF lty_tvko,
          BEGIN OF lty_adrc ,
            addrnumber TYPE ad_addrnum, " Address number
            date_from  TYPE ad_date_fr, " Valid-from date - in current Release only 00010101 possible
            nation     TYPE ad_nation,  " Version ID for International Addresses
            country    TYPE land1,      " Country Key
          END OF lty_adrc,
          BEGIN OF lty_kschl,
            sign   TYPE char1,           " Sign of type CHAR1
            option TYPE char2,           " Option of type CHAR2
            low    TYPE kschl,           " Condition Type
            high   TYPE kschl,           " Condition Type
          END OF lty_kschl,

*--> BOC by JAHANM
          BEGIN OF lty_kna1,
            kunnr TYPE kunnr, " Customer Number
            katr1 TYPE katr1, " Attribute 1
          END OF lty_kna1,
*--> EC by JAHANM
*&-- Begin of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019
          BEGIN OF lty_knvp,
            kunnr TYPE kunnr,            " Customer Number
            vkorg TYPE vkorg,            " Sales Organization
            vtweg TYPE vtweg,            " Distribution Channel
            spart TYPE spart,            " Division
            parza TYPE parza,            " Partner counter
            kunn2 TYPE kunn2 ,           " Customer number of business partner
          END OF lty_knvp.
*&-- End of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019

  DATA : li_status         TYPE STANDARD TABLE OF  zdev_enh_status, " Enhancement Status
         li_vkorg          TYPE STANDARD TABLE OF  lty_vkorg,       " Sales org
         li_tvko           TYPE STANDARD TABLE OF  lty_tvko,        " Sales org detail
         li_adrc           TYPE STANDARD TABLE OF  lty_adrc,        " Address number
         li_konp           TYPE STANDARD  TABLE OF lty_konp,        " Condition Record Number Table
         li_itab           TYPE REF TO             data,            " Class
         li_knumh_t        TYPE TABLE OF           lty_knumh,       " Condition record
         li_kna1_t         TYPE STANDARD  TABLE OF lty_kna1,        " By JAHANM
*&-- Begin of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019
         li_kunnr          TYPE STANDARD TABLE OF  fkk_ranges INITIAL SIZE 0,      " Range table workarea
         li_vtweg          TYPE STANDARD TABLE OF  fkk_ranges INITIAL SIZE 0,      " Range table workarea
         li_spart          TYPE STANDARD TABLE OF  fkk_ranges INITIAL SIZE 0,      " Range table workarea
         li_sales_area_dia TYPE STANDARD TABLE OF fkk_ranges INITIAL SIZE 0,     " Range table workarea
         li_knvp           TYPE STANDARD TABLE OF  lty_knvp INITIAL SIZE 0,        " Range table workarea
*&-- End of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019
         li_kna1           TYPE STANDARD  TABLE OF lty_kna1.        " By JAHANM

  DATA : lv_kbetr         TYPE        char10,              " Kbetr of type CHAR10
         lv_ref_tabletype TYPE REF TO cl_abap_tabledescr,  " Runtime Type Services
         lv_ref_rowtype   TYPE REF TO cl_abap_structdescr, " Runtime Type Services
         lv_vkorg         TYPE        vkorg,               " Sales Organization
         lv_vtweg         TYPE        vtweg,               " Distribution Channel
*&-- Begin of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019
         lv_sales_area    TYPE        char10,              " Char 10
         lv_index         TYPE        i,
*&-- End of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019
         lv_kotab         TYPE        kotab.               " Condition table

  DATA : lr_kschl   TYPE RANGE OF   kschl. " Condition Type

  DATA : lwa_kschl      TYPE              lty_kschl,     " Condition type
         lwa_itab       TYPE REF TO       data,          " Class
         lwa_knumh_s    TYPE              lty_knumh,     " Condition record number
         lwa_vkorg      TYPE              lty_vkorg,     " Sales org
         lwa_price_list TYPE              ty_price_list, " Price list
         lwa_kna1       TYPE              lty_kna1,      " By JAHANM
         lwa_final      TYPE              ty_final,      " Final table wa
*&-- Begin of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019
         lwa_kunnr      TYPE              fkk_ranges.    " Range table workarea
*&-- End of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019

*SOC by ddwivedi on 06-Dec-16 Mapping and CP CR#255
  DATA : lv_active   TYPE char1,   " Active of type CHAR1
         lv_inactive TYPE char1. " Inactive of type CHAR1
  CONSTANTS : lca004            TYPE kotab VALUE 'A004',  " Condition table
              lca005            TYPE kotab VALUE 'A005',  " Condition table
              lca911            TYPE kotab VALUE 'A911',  " Condition table
              lca935            TYPE kotab VALUE 'A935',  " Condition table
              lc_one            TYPE char1 VALUE '1',       " One of type CHAR1
              lc_zero           TYPE char1 VALUE '0',      " Zero of type CHAR1
              lc_vtweg          TYPE char5 VALUE 'VTWEG', " Field name
              lc_katr2          TYPE char2 VALUE '02',    " Katr2 of type CHAR2
*&-- Begin of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019
              lc_i              TYPE char1 VALUE 'I',     " Integer
              lc_eq             TYPE char2 VALUE 'EQ',    " Equal
              lc_spart          TYPE name_feld VALUE 'SPART', " Division
              lc_re             TYPE parvw VALUE 'RE',    " Bill to Party
              lc_slash          TYPE char1 VALUE '/',     " Slash
              lc_sales_area_dia TYPE z_criteria VALUE 'SALES_AREA_DIA', " Crit
*&-- End of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019
              lc_katr3          TYPE char2 VALUE '03'.    " Katr3 of type CHAR2

*EOC by ddwivedi on 06-Dec-16 Mapping and CP CR#255

  FIELD-SYMBOLS : <lfs_status> TYPE zdev_enh_status, " Enhancement Status
                  <lfs_itab>   TYPE ANY TABLE,       " Dynamic Internal Table
                  <lfs_work>   TYPE any,             " Dynamic Workarea
                  <lfs_field>  TYPE any,             " dynamic variable for field value
                  <lfs_tvko>   TYPE lty_tvko,        " Sales order detail
                  <lfs_adrc>   TYPE lty_adrc,        " Address number
                  <lfs_konp>   TYPE lty_konp,        " Condition Record
*&-- Begin of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019
                  <lfs_knvp>   TYPE lty_knvp,        " KNVP table
*&-- End of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019
                  <lfs_kna1>   TYPE lty_kna1.        " By JAHANM


  CLEAR: li_status[].
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = c_enh_idd_0093
    TABLES
      tt_enh_status     = li_status.

*  Binary search not used as number of reocrds will be < 10
  READ TABLE li_status WITH KEY criteria = lc_kschl
                                active   = abap_true
                             TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
*-- Collecting the condition types from EMI Tool
    LOOP AT li_status ASSIGNING <lfs_status>.
      IF <lfs_status>-criteria = lc_kschl.
        lwa_kschl-sign   = <lfs_status>-sel_sign.
        lwa_kschl-option = <lfs_status>-sel_option.
        lwa_kschl-low    = <lfs_status>-sel_low.
        APPEND lwa_kschl TO lr_kschl.
        CLEAR lwa_kschl.
      ENDIF. " IF <lfs_status>-criteria = lc_kschl
    ENDLOOP. " LOOP AT li_status ASSIGNING <lfs_status>
  ENDIF. " IF sy-subrc = 0

*&-- Begin of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019
  IF <lfs_status> IS ASSIGNED.
    UNASSIGN : <lfs_status>.
  ENDIF.

  LOOP AT li_status ASSIGNING <lfs_status>.
    CASE <lfs_status>-criteria.
      WHEN lc_sales_area_dia.
        lwa_kunnr-sign = lc_i.
        lwa_kunnr-option = lc_eq.
        lwa_kunnr-low = <lfs_status>-sel_low.
        APPEND lwa_kunnr TO li_sales_area_dia.
        CLEAR: lwa_kunnr.
    ENDCASE.
  ENDLOOP.
*&-- End of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019
*  FREE li_status.

* If condition type entered in selection screen mathes EMI entries the proceed
  IF p_cond IN lr_kschl.
*  Condition table
    CONCATENATE c_cond_use p_tab INTO lv_kotab.
*  Create dynamic table
    lv_ref_rowtype ?= cl_abap_typedescr=>describe_by_name( p_name = lv_kotab ).
    lv_ref_tabletype = cl_abap_tabledescr=>create( p_line_type = lv_ref_rowtype ).
    CREATE DATA li_itab TYPE HANDLE lv_ref_tabletype. " Internal ID of an object
    CREATE DATA lwa_itab TYPE HANDLE lv_ref_rowtype. " Internal ID of an object
    ASSIGN li_itab->* TO <lfs_itab>.
    ASSIGN lwa_itab->* TO <lfs_work>.

*  If active radion button is selected
    IF fp_act IS NOT INITIAL.
      IF <lfs_itab> IS ASSIGNED.
        PERFORM f_fetch_active_records USING    lv_kotab
                                       CHANGING <lfs_itab>.
      ENDIF. " IF <lfs_itab> IS ASSIGNED
    ELSEIF fp_inact IS NOT INITIAL.
      IF <lfs_itab> IS ASSIGNED.
        PERFORM f_fetch_inactive_records1 USING     lv_kotab
                                         CHANGING <lfs_itab>
                                                  fp_key_date.
      ENDIF. " IF <lfs_itab> IS ASSIGNED
    ENDIF. " IF fp_act IS NOT INITIAL
*  If records are fetched successfully

    IF sy-subrc IS INITIAL AND <lfs_itab> IS NOT INITIAL.

*--BOC by JAHANM
      IF lv_kotab = lca005.
        IF <lfs_work> IS ASSIGNED.
          LOOP AT <lfs_itab> INTO <lfs_work>.
*  Get all the sold-to customer numbers
            ASSIGN COMPONENT lc_kunnr OF STRUCTURE <lfs_work> TO <lfs_field>.
            IF sy-subrc = 0.
              lwa_kna1-kunnr = <lfs_field>.
              APPEND lwa_kna1 TO li_kna1.
              CLEAR lwa_kna1.
            ENDIF. " IF sy-subrc = 0
          ENDLOOP. " LOOP AT <lfs_itab> INTO <lfs_work>
        ENDIF. " IF <lfs_work> IS ASSIGNED

        SORT li_kna1 BY kunnr.
        DELETE ADJACENT DUPLICATES FROM li_kna1 COMPARING kunnr.
*&-- Begin of Delete for HANAtization on OTC_EDD_0093 by U106341 on 26-Feb-2020
        IF LI_KNA1[] IS NOT INITIAL.
*&-- End of Delete for HANAtization on OTC_EDD_0093 by U106341 on 26-Feb-2020

        SELECT  kunnr " Condition record number
                katr1 " Sequential number of the condition
          FROM kna1   " Conditions (Item)
          INTO TABLE li_kna1_t
          FOR ALL ENTRIES IN li_kna1
          WHERE kunnr = li_kna1-kunnr
            AND katr1 IN (lc_katr2,lc_katr3).

        IF sy-subrc = 0.
          LOOP AT li_status ASSIGNING <lfs_status>.
            IF <lfs_status>-criteria = lc_vkorg.
              lv_vkorg = <lfs_status>-sel_low.
            ENDIF. " IF <lfs_status>-criteria = lc_vkorg
            IF <lfs_status>-criteria = lc_vtweg.
              lv_vtweg = <lfs_status>-sel_low.
            ENDIF. " IF <lfs_status>-criteria = lc_vtweg
          ENDLOOP. " LOOP AT li_status ASSIGNING <lfs_status>

          LOOP AT <lfs_itab> INTO <lfs_work>.
*            lv_tabix = sy-tabix.
            ASSIGN COMPONENT lc_vkorg OF STRUCTURE <lfs_work> TO <lfs_field>.
            IF sy-subrc = 0 AND <lfs_field> = lv_vkorg.
              ASSIGN COMPONENT lc_vtweg OF STRUCTURE <lfs_work> TO <lfs_field>.
              IF sy-subrc = 0 AND <lfs_field> = lv_vtweg.
                ASSIGN COMPONENT lc_kunnr OF STRUCTURE <lfs_work> TO <lfs_field>.
                READ TABLE li_kna1_t WITH KEY kunnr = <lfs_field> TRANSPORTING NO FIELDS.
                IF sy-subrc <> 0.
                  DELETE TABLE <lfs_itab> FROM <lfs_work>.
                ENDIF. " IF sy-subrc <> 0

              ENDIF. " IF sy-subrc = 0 AND <lfs_field> = lv_vtweg
            ENDIF. " IF sy-subrc = 0 AND <lfs_field> = lv_vkorg
          ENDLOOP. " LOOP AT <lfs_itab> INTO <lfs_work>

        ENDIF. " IF sy-subrc = 0
*&-- Begin of Delete for HANAtization on OTC_EDD_0093 by U106341 on 26-Feb-2020
         ENDIF.
*&-- End of Delete for HANAtization on OTC_EDD_0093 by U106341 on 26-Feb-2020

      ENDIF. " IF lv_kotab = lca005

      FREE li_status.

*--EOC by JAHANM

      LOOP AT <lfs_itab> INTO <lfs_work>.
*  Get all the condition record numbers
        ASSIGN COMPONENT lc_knumh OF STRUCTURE <lfs_work> TO <lfs_field>.
        IF sy-subrc = 0.
          lwa_knumh_s = <lfs_field>.
          APPEND lwa_knumh_s TO li_knumh_t.
          CLEAR lwa_knumh_s.
        ENDIF. " IF sy-subrc = 0
*  Get the sales organizaiotns
        ASSIGN COMPONENT lc_vkorg OF STRUCTURE <lfs_work> TO <lfs_field>.
        IF sy-subrc IS INITIAL.
          lwa_vkorg = <lfs_field>.
          APPEND lwa_vkorg TO li_vkorg.
          CLEAR lwa_vkorg.
        ENDIF. " IF sy-subrc IS INITIAL

*&-- Begin of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019
        ASSIGN COMPONENT lc_kunnr OF STRUCTURE <lfs_work> TO <lfs_field>.
        IF sy-subrc IS INITIAL AND <lfs_field> IS ASSIGNED.
          lwa_kunnr-sign = lc_i.
          lwa_kunnr-option = lc_eq.
          lwa_kunnr-low = <lfs_field>.
          APPEND lwa_kunnr TO li_kunnr.
          CLEAR: lwa_kunnr.
        ENDIF.

        ASSIGN COMPONENT lc_vtweg OF STRUCTURE <lfs_work> TO <lfs_field>.
        IF sy-subrc IS INITIAL AND <lfs_field> IS ASSIGNED.
          lwa_kunnr-sign = lc_i.
          lwa_kunnr-option = lc_eq.
          lwa_kunnr-low = <lfs_field>.
          APPEND lwa_kunnr TO li_vtweg.
          CLEAR: lwa_kunnr.
        ENDIF.

        ASSIGN COMPONENT lc_spart OF STRUCTURE <lfs_work> TO <lfs_field>.
        IF sy-subrc IS INITIAL AND <lfs_field> IS ASSIGNED.
          lwa_kunnr-sign = lc_i.
          lwa_kunnr-option = lc_eq.
          lwa_kunnr-low = <lfs_field>.
          APPEND lwa_kunnr TO li_spart.
          CLEAR: lwa_kunnr.
        ENDIF.
*&-- End of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019
      ENDLOOP. " LOOP AT <lfs_itab> INTO <lfs_work>
    ELSE. " ELSE -> IF sy-subrc IS INITIAL AND <lfs_itab> IS NOT INITIAL
      MESSAGE i280. " Message "Data Not Found"
    ENDIF. " IF sy-subrc IS INITIAL AND <lfs_itab> IS NOT INITIAL

*  Get condition record detail
    SORT li_knumh_t BY knumh.
    DELETE ADJACENT DUPLICATES FROM li_knumh_t COMPARING knumh.
    IF li_knumh_t IS NOT INITIAL.
      SELECT  knumh               " Condition record number
              kopos               " Sequential number of the condition
              kschl               " Condition type
              kbetr               " Rate (condition amount or percentage) where no scale exists
              konwa               " Rate unit (currency or percentage)
              loevm_ko            " Deletion Indicator for Condition Item
        FROM konp                 " Conditions (Item)
        INTO TABLE li_konp
        FOR ALL ENTRIES IN li_knumh_t
        WHERE knumh = li_knumh_t-knumh
          AND loevm_ko NE c_true. "By JAHANM " Records with del. ind. are not required in the selection
      IF sy-subrc IS INITIAL.
        SORT li_konp BY knumh.
      ELSE. " ELSE -> IF sy-subrc IS INITIAL
        MESSAGE i280. "Data Not Found
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF li_knumh_t IS NOT INITIAL

*  Get country code for all the sales organizations
    SORT li_vkorg BY vkorg.
    DELETE ADJACENT DUPLICATES FROM li_vkorg COMPARING vkorg.
    IF li_vkorg IS NOT INITIAL.
      SELECT vkorg " Sales Organization
             adrnr " Address
       FROM  tvko  " Organizational Unit: Sales Organizations
       INTO TABLE li_tvko
       FOR ALL ENTRIES IN li_vkorg
        WHERE vkorg = li_vkorg-vkorg.
      IF sy-subrc IS INITIAL.
        SORT li_tvko BY vkorg adrnr.
        DELETE ADJACENT DUPLICATES FROM li_tvko COMPARING vkorg adrnr.
        IF li_tvko IS NOT INITIAL.
          SELECT addrnumber " Address number
                 date_from  " Valid-from date - in current Release only 00010101 possible
                 nation     " Version ID for International Addresses
                 country    " Country Key
           FROM  adrc       " Addresses (Business Address Services)
           INTO TABLE li_adrc
           FOR ALL ENTRIES IN li_tvko
           WHERE addrnumber = li_tvko-adrnr.
          IF sy-subrc IS INITIAL.
            SORT li_adrc BY addrnumber.
          ENDIF. " IF sy-subrc IS INITIAL
        ENDIF. " IF li_tvko IS NOT INITIAL
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF li_vkorg IS NOT INITIAL

*&-- Begin of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019
*&-- Fetch Bill-To-Party records from KNVP based on Sold-To-Party

    SORT li_vtweg BY low.
    DELETE ADJACENT DUPLICATES FROM li_vtweg COMPARING low.

    SORT li_spart BY low.
    DELETE ADJACENT DUPLICATES FROM li_spart COMPARING low.

    IF li_vkorg IS NOT INITIAL.
      SELECT kunnr
             vkorg
             vtweg
             spart
             parza
             kunn2
      FROM knvp
      INTO TABLE li_knvp
      FOR ALL ENTRIES IN li_vkorg
      WHERE kunnr IN li_kunnr
      AND vkorg = li_vkorg-vkorg
      AND vtweg IN li_vtweg
      AND spart IN li_spart
      AND parvw = lc_re.

      IF sy-subrc IS INITIAL.

*&-- Filter out KNVP entries not belonging to France Sales Area
        LOOP AT li_knvp ASSIGNING <lfs_knvp>.
          CONCATENATE <lfs_knvp>-vkorg lc_slash <lfs_knvp>-vtweg lc_slash <lfs_knvp>-spart INTO lv_sales_area.
          IF lv_sales_area NOT IN li_sales_area_dia.
            <lfs_knvp>-vkorg = space.
          ENDIF.

        ENDLOOP.
        DELETE li_knvp WHERE vkorg = space.
        SORT li_knvp BY kunnr parza.
      ENDIF.
    ENDIF.

*&-- End of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019

*   Begin of collecting all the required fields and populating into the condition record table

    LOOP AT <lfs_itab> INTO <lfs_work>.
*    Sold to party
      ASSIGN COMPONENT lc_kunnr OF STRUCTURE <lfs_work> TO <lfs_field>.
      IF sy-subrc IS INITIAL.
        lwa_price_list-kunag = <lfs_field>.
      ELSE. " ELSE -> IF sy-subrc IS INITIAL
        ASSIGN COMPONENT lc_kunag OF STRUCTURE <lfs_work> TO <lfs_field>.
        IF sy-subrc IS INITIAL.
          lwa_price_list-kunag = <lfs_field>.
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF sy-subrc IS INITIAL

*    Ship to party
      ASSIGN COMPONENT lc_kunwe OF STRUCTURE <lfs_work> TO <lfs_field>.
      IF sy-subrc IS INITIAL.
        lwa_price_list-kunwe = <lfs_field>.
      ENDIF. " IF sy-subrc IS INITIAL

*    Country
      ASSIGN COMPONENT lc_vkorg OF STRUCTURE <lfs_work> TO <lfs_field>.
      IF sy-subrc IS INITIAL.
        READ TABLE li_tvko ASSIGNING <lfs_tvko> WITH KEY vkorg = <lfs_field>.
        IF sy-subrc IS INITIAL.
          READ TABLE li_adrc ASSIGNING <lfs_adrc> WITH KEY addrnumber = <lfs_tvko>-adrnr.
          IF sy-subrc IS INITIAL.
            lwa_price_list-country = <lfs_adrc>-country.
          ENDIF. " IF sy-subrc IS INITIAL
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF sy-subrc IS INITIAL

*    Material number
      ASSIGN COMPONENT lc_matnr OF STRUCTURE <lfs_work> TO <lfs_field>.
      IF sy-subrc IS INITIAL.
        lwa_price_list-matnr = <lfs_field>.
      ENDIF. " IF sy-subrc IS INITIAL

*    Valid from date
      ASSIGN COMPONENT lc_datab OF STRUCTURE <lfs_work> TO <lfs_field>.
      IF sy-subrc IS INITIAL.
        lwa_price_list-datab = <lfs_field>.
      ENDIF. " IF sy-subrc IS INITIAL

*    Valid to date
      ASSIGN COMPONENT lc_datbi OF STRUCTURE <lfs_work> TO <lfs_field>.
      IF sy-subrc IS INITIAL.
        lwa_price_list-datbi = <lfs_field>.
      ENDIF. " IF sy-subrc IS INITIAL

*    Price per unit & Currency
      ASSIGN COMPONENT lc_knumh OF STRUCTURE <lfs_work> TO <lfs_field>.
      IF sy-subrc IS INITIAL.
        READ TABLE li_konp ASSIGNING <lfs_konp> WITH KEY
                                     knumh    = <lfs_field>
                                     BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          lwa_price_list-kbetr = <lfs_konp>-kbetr.
          lwa_price_list-konwa = <lfs_konp>-konwa.
        ELSE. " ELSE -> IF sy-subrc IS INITIAL
          "Records for which del. ind. is set should be excluded from the file.
          DELETE TABLE <lfs_itab> FROM <lfs_work>.
          CONTINUE.
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF sy-subrc IS INITIAL

      lv_kbetr = lwa_price_list-kbetr.
      SHIFT lv_kbetr LEFT DELETING LEADING space.

      IF fp_inact IS NOT INITIAL.
        lwa_price_list-inactive = abap_true.
      ENDIF. " IF fp_inact IS NOT INITIAL


**  SOC by ddwivedi on 06-Dec-2016 CR#255-2
* special logic for col no 7 and 8 based on active and inactive flag
      IF rb_act IS NOT INITIAL .
        lv_active = lc_one .
        lv_inactive = lc_zero.
      ELSEIF rb_inact IS NOT INITIAL .
        lv_active = lc_zero .
        lv_inactive = lc_one.
      ENDIF. " IF rb_act IS NOT INITIAL

* Special processing
      CASE lv_kotab.
        WHEN lca005.
*  if table is A005 then ship to party should be as Sold to Party
          lwa_price_list-kunwe = lwa_price_list-kunag .
        WHEN lca004.
*       do nothing .
        WHEN lca911.
*       do nothing .
        WHEN lca935.
*       do nothing .
        WHEN OTHERS .
*       do nothing .
      ENDCASE.
**  EOC by ddwivedi on 06-Dec-2016 CR#255-2

*&-- Begin of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019
*&-- Check Bill-To-Party customers for each Customer

      CLEAR: lv_index.
      IF <lfs_knvp> IS ASSIGNED.
        UNASSIGN : <lfs_knvp>.
      ENDIF.
      READ TABLE li_knvp TRANSPORTING NO FIELDS
                                      WITH KEY kunnr = lwa_price_list-kunag.

      IF sy-subrc IS INITIAL.
        lv_index = sy-tabix.

                CONCATENATE lwa_price_list-kunag   "Col-01
                lwa_price_list-kunwe   "Col-02
                lwa_price_list-country "Col-03
                lwa_price_list-matnr   "Col-04
                lv_kbetr               "Col-05
                space                  "Col-06
                lv_active              "Col-08   (-) ddwivedi on 06-Dec-16  CR#255-2      "space
                lv_inactive            "Col-07   (-) ddwivedi on 06-Dec-16  CR#255-2     "space
                lwa_price_list-datab   "Col-09
                lwa_price_list-datbi   "Col-10
                lv_kbetr               "Col-11
                space                  "Col-12
                space                  "Col-13    (-) ddwivedi on 06-Dec-16 CR#255-2 lwa_price_list-konwa
                space                  "Col-14    (-) ddwivedi on 06-Dec-16 CR#255-2  lwa_price_list-inactive
                space                  "Col-15
                space                  "Col-16
                space                  "Col-17
                space                  "Col-18
           INTO lwa_final-line
           SEPARATED BY lc_pipe.

           APPEND lwa_final TO fp_i_final.


        LOOP AT li_knvp ASSIGNING <lfs_knvp> FROM lv_index.
          IF <lfs_knvp>-kunnr = lwa_price_list-kunag .

            IF <lfs_knvp>-kunnr <> <lfs_knvp>-kunn2.

              CONCATENATE lwa_price_list-kunag  "Col-01
                      <lfs_knvp>-kunn2       " Col-02
                      lwa_price_list-country "Col-03
                      lwa_price_list-matnr   "Col-04
                      lv_kbetr               "Col-05
                      space                  "Col-06
                      lv_active              "Col-08
                      lv_inactive            "Col-07
                      lwa_price_list-datab   "Col-09
                      lwa_price_list-datbi   "Col-10
                      lv_kbetr               "Col-11
                      space                  "Col-12
                      space                  "Col-13
                      space                  "Col-14
                      space                  "Col-15
                      space                  "Col-16
                      space                  "Col-17
                      space                  "Col-18
                 INTO lwa_final-line
                 SEPARATED BY lc_pipe.

              APPEND lwa_final TO fp_i_final.
            ENDIF.
          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.

      ELSE.
*&-- End of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019

*    Concatenate all the field values for uploading in pres/app server as text file
        CONCATENATE lwa_price_list-kunag   "Col-01
                    lwa_price_list-kunwe   "Col-02
                    lwa_price_list-country "Col-03
                    lwa_price_list-matnr   "Col-04
                    lv_kbetr               "Col-05
                    space                  "Col-06
                    lv_active              "Col-08   (-) ddwivedi on 06-Dec-16  CR#255-2      "space
                    lv_inactive            "Col-07   (-) ddwivedi on 06-Dec-16  CR#255-2     "space
                    lwa_price_list-datab   "Col-09
                    lwa_price_list-datbi   "Col-10
                    lv_kbetr               "Col-11
                    space                  "Col-12
                    space                  "Col-13    (-) ddwivedi on 06-Dec-16 CR#255-2 lwa_price_list-konwa
                    space                  "Col-14    (-) ddwivedi on 06-Dec-16 CR#255-2  lwa_price_list-inactive
                    space                  "Col-15
                    space                  "Col-16
                    space                  "Col-17
                    space                  "Col-18
               INTO lwa_final-line
               SEPARATED BY lc_pipe.

        APPEND lwa_final TO fp_i_final.
        CLEAR : lwa_final,
                lv_kbetr,
                lwa_price_list.
*&-- Begin of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019
      ENDIF.
      CLEAR: lwa_final.
*&-- End of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019
    ENDLOOP. " LOOP AT <lfs_itab> INTO <lfs_work>

  ENDIF. " IF p_cond IN lr_kschl
  FREE : li_vkorg,
         li_tvko,
         li_adrc,
         li_konp.

*&-- Begin of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019
  REFRESH : li_sales_area_dia,
            li_knvp.
  CLEAR: lv_index.
  IF <lfs_field> IS ASSIGNED.
    UNASSIGN : <lfs_field>.
  ENDIF.
*&-- End of changes for D3_OTC_IDD_0093 SCTASK0834302 Defect# 8512 by SMUKHER on 10-Jun-2019
ENDFORM. " F_FETCH_RECORDS
*&---------------------------------------------------------------------*
*&      Form  f_write_presentation_server
*&---------------------------------------------------------------------*
*       Download file to presentation server
*----------------------------------------------------------------------*
*      -->FP_GV_FILE File path
*      -->FP_I_FINAL pricing records
*----------------------------------------------------------------------*
FORM f_write_presentation_server  USING   fp_gv_file TYPE localfile   " Local file for upload/download
                                          fp_i_final TYPE ty_t_final. " Final records for uploading.
  CONSTANTS : lc_file_type TYPE char10 VALUE 'ASC',
              lc_11        TYPE int4   VALUE 11, " Natural Number
              lc_12        TYPE int4   VALUE 12, " Natural Number
              lc_13        TYPE int4   VALUE 13, " Natural Number
              lc_14        TYPE int4   VALUE 14, " Natural Number
              lc_15        TYPE int4   VALUE 15, " Natural Number
              lc_16        TYPE int4   VALUE 16, " Natural Number
              lc_17        TYPE int4   VALUE 17, " Natural Number
              lc_18        TYPE int4   VALUE 18, " Natural Number
              lc_19        TYPE int4   VALUE 19, " Natural Number
              lc_20        TYPE int4   VALUE 20, " Natural Number
              lc_21        TYPE int4   VALUE 21, " Natural Number
              lc_22        TYPE int4   VALUE 22. " Natural Number
  DATA : lv_filepath TYPE string.

*  complete file path
  lv_filepath = fp_gv_file.
*  call method to download in presentation server
  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename                = lv_filepath
      filetype                = lc_file_type
    CHANGING
      data_tab                = fp_i_final
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = lc_11
      dp_error_send           = lc_12
      dp_error_write          = lc_13
      unknown_dp_error        = lc_14
      access_denied           = lc_15
      dp_out_of_memory        = lc_16
      disk_full               = lc_17
      dp_timeout              = lc_18
      file_not_found          = lc_19
      dataprovider_exception  = lc_20
      control_flush_error     = lc_21
      OTHERS                  = lc_22.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS NOT INITIAL

ENDFORM. " F_WRITE_PRESENTATION_SERVER
*&---------------------------------------------------------------------*
*&      Form  f_check_input
*&---------------------------------------------------------------------*
*       Chech input
*----------------------------------------------------------------------*
FORM f_check_input .
* If No presentation Server file name is entered and Presentation
* Server Option has been chosen, then issuing the error message.
  IF rb_pres IS NOT INITIAL AND
     p_phdr IS INITIAL.
*Presentation server file has not been entered.
    MESSAGE i032.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF rb_pres IS NOT INITIAL AND

* For Application Server
  IF rb_app IS NOT INITIAL.
*   If No Application Server file name is entered and Application
*   Server Option has been chosen, then issueing error message.
    IF rb_aphy IS NOT INITIAL AND
       p_ahdr IS INITIAL.
      MESSAGE i033. "Application server file has not been entered'
      LEAVE LIST-PROCESSING.
    ENDIF. " IF rb_aphy IS NOT INITIAL AND

* If No Logical File Path is entered and Logical File Path Option
* has been chosen, then issueing error message.
    IF rb_alog IS NOT INITIAL AND
       p_alog IS INITIAL.
      MESSAGE i034. "Logical File Path has not been entered'
      LEAVE LIST-PROCESSING.
    ENDIF. " IF rb_alog IS NOT INITIAL AND
  ENDIF. " IF rb_app IS NOT INITIAL

ENDFORM. " F_CHECK_INPUT
*&---------------------------------------------------------------------*
*&      Form  f_write_app_server
*&---------------------------------------------------------------------*
*       Upload file to application server
*----------------------------------------------------------------------*
*      -->FP_GV_FILEPATH  File path
*      -->FP_I_FINAL      pricing records
*----------------------------------------------------------------------*
FORM f_write_app_server  USING     fp_i_final      TYPE ty_t_final " Final table to be updloaded to app server
                         CHANGING  fp_gv_filepath  TYPE localfile. " Local file for upload/download


  CONSTANTS : lc_file_ext   TYPE char4   VALUE '.txt', " File_ext of type CHAR4
              lc_otc_0093   TYPE char12  VALUE 'OTC_IDD_0093', " Otc_0093 of type CHAR12
              lc_underscore TYPE char1   VALUE '_',            " Underscore of type CHAR1
              lc_slash      TYPE char1   VALUE '/'.            " Slash of type CHAR1

  DATA : lv_file      TYPE rlgrap-filename, " Local file for upload/download
         lwa_final    TYPE ty_final,
         lv_filename  TYPE string,
         lv_time      TYPE string,
         lv_timestamp TYPE timestamp.       " UTC Time Stamp in Short Form (YYYYMMDDhhmmss)


* Get time stamp
  GET TIME STAMP FIELD lv_timestamp.
  IF sy-subrc IS INITIAL.
    lv_time = lv_timestamp.
  ENDIF. " IF sy-subrc IS INITIAL
* concatenate file path, file name and extension
  IF rb_act IS NOT INITIAL.
    CONCATENATE  lc_otc_0093
                 p_cond
                 p_tab
                 lv_time
           INTO  lv_filename
    SEPARATED BY lc_underscore.
  ELSEIF rb_inact IS NOT INITIAL.
*&->Start of Defect#8361 by Jahan.
*    CONCATENATE  lc_otc_0093
*                 p_cond
*                 p_tab
*                 'Inactive'(023)
*                 lv_time
*           INTO  lv_filename
*    SEPARATED BY lc_underscore.
    CONCATENATE  'CustomerPriceInactive'(029)
                 lv_time
           INTO  lv_filename
    SEPARATED BY lc_underscore.
*&->End of Defect#8361 by Jahan.
  ENDIF. " IF rb_act IS NOT INITIAL

  CONCATENATE  lv_filename
               lc_file_ext
         INTO  lv_filename.

  IF rb_alog IS NOT INITIAL.
    CONCATENATE  fp_gv_filepath
                 lv_filename
           INTO  lv_file.
  ELSEIF rb_aphy IS NOT INITIAL.
    CONCATENATE  fp_gv_filepath
                 lv_filename
           INTO  lv_file
    SEPARATED BY lc_slash.
  ENDIF. " IF rb_alog IS NOT INITIAL

  CONDENSE lv_file NO-GAPS.

* Open file in application server
  OPEN DATASET lv_file FOR OUTPUT IN TEXT MODE ENCODING UTF-8. " Output type
  IF sy-subrc IS INITIAL.
*  Transfer file records to app server file
    LOOP AT fp_i_final INTO lwa_final.
      TRANSFER lwa_final TO lv_file.
    ENDLOOP. " LOOP AT fp_i_final INTO lwa_final
*  close app server file
    CLOSE DATASET lv_file.
    fp_gv_filepath = lv_file.
  ELSE. " ELSE -> IF sy-subrc IS INITIAL
    MESSAGE i000 WITH 'File cound not be uploaded'(012).
  ENDIF. " IF sy-subrc IS INITIAL

ENDFORM. " F_WRITE_APP_SERVER
*&---------------------------------------------------------------------*
*&      Form  f_logical_to_physical
*&---------------------------------------------------------------------*
*       Get physical path from logical path
*----------------------------------------------------------------------*
*      -->FP_P_ALOG  logical file path
*      <--FP_GV_FILE physical file path
*----------------------------------------------------------------------*
FORM f_logical_to_physical  USING    fp_p_alog  TYPE pathintern " Logical path name
                            CHANGING fp_gv_file TYPE localfile. " Local file for upload/download.

* Local Constants
  CONSTANTS : lc_dummy   TYPE char4 VALUE 'DUMY'. " Dummy of type CHAR4


  DATA: lv_filename TYPE fileintern, " Logical file name
        lv_path     TYPE epsdirnam,  " Directory name
        lv_length   TYPE syindex.    " Loop Index

  lv_filename = fp_p_alog.

*  Convert logical filepath to physical file path
  CALL FUNCTION 'FILE_GET_NAME_USING_PATH'
    EXPORTING
      client                     = sy-mandt
      logical_path               = lv_filename
      operating_system           = sy-opsys
      file_name                  = lc_dummy
    IMPORTING
      file_name_with_path        = lv_path
    EXCEPTIONS
      path_not_found             = 1
      missing_parameter          = 2
      operating_system_not_found = 3
      file_system_not_found      = 4
      OTHERS                     = 5.
  IF sy-subrc IS NOT INITIAL.
    CLEAR lv_path.
*        show error message
  ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL
*   Truncating last 4 characters for DUMMY file to get physical directory.
    lv_length  = strlen( lv_path ).
*   Last 4 characters are Dummy, hence reducing the length
    lv_length = lv_length - 4.
    IF lv_length GT 0.
      fp_gv_file = lv_path+0(lv_length).
    ELSE. " ELSE -> IF lv_length GT 0
      MESSAGE e000 WITH 'Physical paht could be retrieved'(013).
    ENDIF. " IF lv_length GT 0
  ENDIF. " IF sy-subrc IS NOT INITIAL


ENDFORM. " F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*&      Form  f_fetch_active_records
*&---------------------------------------------------------------------*
*       Fetch active pricing records
*----------------------------------------------------------------------*
*      -->FP_KOTAB   condition table
*      <--FP_ITAB    pricing records
*----------------------------------------------------------------------*
FORM f_fetch_active_records  USING    fp_kotab    TYPE kotab      " Condition table
                             CHANGING fp_itab     TYPE ANY TABLE. " Table of type ANY

  CONSTANTS : lc_kappl TYPE kappl VALUE 'V',     " Application
              lc_kschl TYPE char5 VALUE 'KSCHL', " Condition type
              lc_a004  TYPE kotab VALUE 'A004',  " Condition table
              lc_a005  TYPE kotab VALUE 'A005',  " Condition table
              lc_a911  TYPE kotab VALUE 'A911',  " Condition table
              lc_a935  TYPE kotab VALUE 'A935'.  " Condition table


* Select * has been used as the tables have no more that 12 fields and
* more that 90% of the fields are used in processing the records
  CASE fp_kotab.
    WHEN lc_a004.
      SELECT mandt
             kappl
             kschl
             vkorg
             vtweg
             matnr
             datbi
             datab
             knumh
        FROM (fp_kotab)
        INTO TABLE fp_itab
        WHERE kappl = lc_kappl
          AND kschl = p_cond
          AND vkorg IN s_vkorg
          AND vtweg IN s_vtweg
          AND matnr IN s_matnr
          AND datbi >= p_ersda
          AND datab <= p_ersda.
      IF sy-subrc IS INITIAL.
        SORT fp_itab BY (lc_kschl).
      ENDIF. " IF sy-subrc IS INITIAL
    WHEN lc_a005.
      SELECT mandt
             kappl
             kschl
             vkorg
             vtweg
             kunnr
             matnr
             datbi
             datab
             knumh
        FROM (fp_kotab)
        INTO TABLE fp_itab
        WHERE kappl = lc_kappl
          AND kschl = p_cond
          AND vkorg IN s_vkorg
          AND vtweg IN s_vtweg
          AND kunnr IN s_kunag
          AND matnr IN s_matnr
          AND datbi >= p_ersda
          AND datab <= p_ersda.
      IF sy-subrc IS INITIAL.
        SORT fp_itab BY (lc_kschl).
      ENDIF. " IF sy-subrc IS INITIAL
    WHEN lc_a911.
      SELECT mandt
             kappl
             kschl
             vkorg
             vtweg
             kunwe
             matnr
             kfrst
             datbi
             datab
             kbstat
             knumh
        FROM (fp_kotab)
        INTO TABLE fp_itab
        WHERE kappl = lc_kappl
          AND kschl = p_cond
          AND vkorg IN s_vkorg
          AND vtweg IN s_vtweg
          AND kunwe IN s_kunwe
          AND matnr IN s_matnr
          AND datbi >= p_ersda
          AND datab <= p_ersda.
      IF sy-subrc IS INITIAL.
        SORT fp_itab BY (lc_kschl).
      ENDIF. " IF sy-subrc IS INITIAL
    WHEN lc_a935.
      SELECT mandt
             kappl
             kschl
             vkorg
             vtweg
             kunag
             kunwe
             matnr
             kfrst
             datbi
             datab
             kbstat
             knumh
        FROM (fp_kotab)
        INTO TABLE fp_itab
        WHERE kappl = lc_kappl
          AND kschl = p_cond
          AND vkorg IN s_vkorg
          AND vtweg IN s_vtweg
          AND kunag IN s_kunag
          AND kunwe IN s_kunwe
          AND matnr IN s_matnr
          AND datbi >= p_ersda
          AND datab <= p_ersda.
      IF sy-subrc IS INITIAL.
        SORT fp_itab BY (lc_kschl).
      ENDIF. " IF sy-subrc IS INITIAL
    WHEN OTHERS.
*     do nothing
  ENDCASE.

ENDFORM. " F_FETCH_ACTIVE_RECORDS
*&---------------------------------------------------------------------*
*&      Form  f_write_selection_screen
*&---------------------------------------------------------------------*
*       Write selection screen input values at the end
*----------------------------------------------------------------------*
*      -->FP_FILE    file path
*      -->FP_LINES   number of records
*----------------------------------------------------------------------*
FORM f_write_selection_screen USING fp_file  TYPE localfile " Local file for upload/download
                                    fp_lines TYPE int4.     " Natural Number

  DATA : li_sel_tab  TYPE TABLE OF rsparams, " ABAP: General Structure for PARAMETERS and SELECT-OPTIONS
         li_textpool TYPE TABLE OF textpool, " ABAP Text Pool Definition
         lv_param    TYPE string.

  FIELD-SYMBOLS : <lfs_sel_tab>  TYPE rsparams, " ABAP: General Structure for PARAMETERS and SELECT-OPTIONS
                  <lfs_textpool> TYPE textpool. " ABAP Text Pool Definition

  IF gv_lines GT 0.
* Number of records
    WRITE : / 'Number of Records :'(014) ,
              fp_lines.
    SKIP 1.
* Complete file path
    WRITE : / 'File Path :'(015),
              fp_file.
    SKIP 1.
  ELSE. " ELSE -> IF gv_lines GT 0
    WRITE : / 'No Records fetched for below selection criteria'(022).
    SKIP 1.
  ENDIF. " IF gv_lines GT 0

* Get the selection screen values entered
  CALL FUNCTION 'RS_REFRESH_FROM_SELECTOPTIONS'
    EXPORTING
      curr_report     = sy-repid
    TABLES
      selection_table = li_sel_tab
    EXCEPTIONS
      not_found       = 1
      no_report       = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE. " ELSE -> IF sy-subrc <> 0

* Read all the texts for the program
    READ TEXTPOOL sy-repid INTO li_textpool LANGUAGE sy-langu.
    IF sy-subrc IS INITIAL.
      SORT li_textpool BY key.
    ENDIF. " IF sy-subrc IS INITIAL
* Write the selection fields and their entered values
    WRITE : / 'Parameter Name'(016),
              25'Parameter Type'(017),
              45'Sign'(018),
              60'Option'(019),
              70'Low'(020),
              115'High'(021).

    WRITE : / sy-uline(200).
    LOOP AT li_sel_tab ASSIGNING <lfs_sel_tab>.
      READ TABLE li_textpool ASSIGNING <lfs_textpool> WITH KEY
                                    key = <lfs_sel_tab>-selname
                                    BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        lv_param = <lfs_textpool>-entry.
        CONDENSE lv_param NO-GAPS.
        WRITE : / lv_param             UNDER 'Parameter Name'(016),
                  <lfs_sel_tab>-kind   UNDER 'Parameter Type'(017),
                  <lfs_sel_tab>-sign   UNDER 'Sign'(018),
                  <lfs_sel_tab>-option UNDER 'Option'(019),
                  <lfs_sel_tab>-low    UNDER 'Low'(020),
                  <lfs_sel_tab>-high   UNDER 'High'(021).
        CLEAR lv_param.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDLOOP. " LOOP AT li_sel_tab ASSIGNING <lfs_sel_tab>

  ENDIF. " IF sy-subrc <> 0

ENDFORM. " F_WRITE_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*&      Form  f_help_as_path
*&---------------------------------------------------------------------*
*       F4 help for application server file
*----------------------------------------------------------------------*
*      <--FP_V_FILENAME  file path
*----------------------------------------------------------------------*
FORM f_help_as_path CHANGING fp_v_filename TYPE localfile. " Local file for upload/download
* Function  module for F4 help from Application  server
  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    IMPORTING
      serverfile       = fp_v_filename
    EXCEPTIONS
      canceled_by_user = 1
      OTHERS           = 2.
  IF sy-subrc IS NOT INITIAL.
    CLEAR fp_v_filename.
  ENDIF. " IF sy-subrc IS NOT INITIAL
ENDFORM. "F_HELP_AS_PATH
*&---------------------------------------------------------------------*
*&      Form  F_FETCH_INACTIVE_RECORDS1
*&---------------------------------------------------------------------*
*       Fetch inactive pricing records
*----------------------------------------------------------------------*
*      -->P_LV_KOTAB  condition table
*      <--P_<LFS_ITAB>  pricing records
*----------------------------------------------------------------------*
FORM f_fetch_inactive_records1  USING    fp_kotab    TYPE kotab     " Condition table
                                CHANGING fp_itab     TYPE ANY TABLE
                                         fp_key_date TYPE sy-datum. " Current Date of Application Server

  CONSTANTS : lc_kappl TYPE kappl     VALUE 'V',    " Field name
              lc_a004  TYPE kotab     VALUE 'A004', " Condition table
              lc_a005  TYPE kotab     VALUE 'A005', " Condition table
              lc_a911  TYPE kotab     VALUE 'A911', " Condition table
              lc_a935  TYPE kotab     VALUE 'A935'. " Condition table


  DATA : li_a004   TYPE STANDARD TABLE OF a004, " Material
         li_a005   TYPE STANDARD TABLE OF a005, " Customer/Material
         li_a911   TYPE STANDARD TABLE OF a911, " Sales org./Distr. Chl/Ship-to/Material
         li_a935   TYPE STANDARD TABLE OF a935, " Sales org./Distr. Chl/Sold-to pt/Ship-to/Material
         li_a004_1 TYPE STANDARD TABLE OF a004, " Material
         li_a005_1 TYPE STANDARD TABLE OF a005, " Customer/Material
         li_a911_1 TYPE STANDARD TABLE OF a911, " Sales org./Distr. Chl/Ship-to/Material
         li_a935_1 TYPE STANDARD TABLE OF a935. " Sales org./Distr. Chl/Sold-to pt/Ship-to/Material

  DATA : lv_index    TYPE sy-tabix, " Index of Internal Tables
         lv_key_date TYPE ersda.    " Created On

  FIELD-SYMBOLS : <lfs_a004>   TYPE  a004, " Material
                  <lfs_a005>   TYPE  a005, " Customer/Material
                  <lfs_a911>   TYPE  a911, " Sales org./Distr. Chl/Ship-to/Material
                  <lfs_a935>   TYPE  a935, " Sales org./Distr. Chl/Sold-to pt/Ship-to/Material
                  <lfs_a004_1> TYPE  a004, " Material
                  <lfs_a005_1> TYPE  a005, " Customer/Material
                  <lfs_a911_1> TYPE  a911, " Sales org./Distr. Chl/Ship-to/Material
                  <lfs_a935_1> TYPE  a935, " Sales org./Distr. Chl/Sold-to pt/Ship-to/Material
                  <lfs_a004_t> TYPE  a004, " Material
                  <lfs_a005_t> TYPE  a005, " Customer/Material
                  <lfs_a911_t> TYPE  a911, " Sales org./Distr. Chl/Ship-to/Material
                  <lfs_a935_t> TYPE  a935. " Sales org./Distr. Chl/Sold-to pt/Ship-to/Material

* Adding one day to the select date entered in selection screen
*  lv_key_date = p_ersda + 1. "(-) DDWIVEDI on 7-Dec-16 CR#255-2  as requested by Rajiv D
  lv_key_date = p_ersda. " - 1 . "(+) DDWIVEDI on 7-Dec-16 CR#255-2  as requested by Rajiv D
  fp_key_date = lv_key_date.

  CASE fp_kotab.
    WHEN lc_a004.

      SELECT mandt " Client
             kappl " Application
             kschl " Condition type
             vkorg " Sales Organization
             vtweg " Distribution Channel
             matnr " Material Number
             datbi " Validity end date of the condition record
             datab " Validity start date of the condition record
             knumh " Condition record number
       FROM a004   " Material
       INTO TABLE li_a004
        WHERE kappl = lc_kappl
          AND kschl = p_cond
          AND vkorg IN s_vkorg
          AND vtweg IN s_vtweg
          AND matnr IN s_matnr
          AND datbi >= lv_key_date.
      IF sy-subrc IS INITIAL.
        SORT li_a004 BY kappl kschl vkorg vtweg matnr datbi.
        LOOP AT li_a004 ASSIGNING <lfs_a004>.
          IF <lfs_a004>-datbi = lv_key_date.
*          If an inactive record is found, then check if there is any other future record for the same key
*          If there is another records then do nothing, else send the currect inactive records to another table
            CLEAR lv_index.
            lv_index = sy-tabix + 1.
            READ TABLE li_a004 ASSIGNING <lfs_a004_t> INDEX lv_index.
            IF sy-subrc IS INITIAL.
              IF <lfs_a004>-kappl = <lfs_a004_t>-kappl AND
                 <lfs_a004>-kschl = <lfs_a004_t>-kschl AND
                 <lfs_a004>-vkorg = <lfs_a004_t>-vkorg AND
                 <lfs_a004>-vtweg = <lfs_a004_t>-vtweg AND
                 <lfs_a004>-matnr = <lfs_a004_t>-matnr.
*               Do nothing
              ELSE. " ELSE -> IF <lfs_a004>-kappl = <lfs_a004_t>-kappl AND
                APPEND INITIAL LINE TO li_a004_1 ASSIGNING <lfs_a004_1>.
                <lfs_a004_1> = <lfs_a004>.
                UNASSIGN <lfs_a004_1>.
              ENDIF. " IF <lfs_a004>-kappl = <lfs_a004_t>-kappl AND
            ELSE. " ELSE -> IF sy-subrc IS INITIAL
              APPEND INITIAL LINE TO li_a004_1 ASSIGNING <lfs_a004_1>.
              <lfs_a004_1> = <lfs_a004>.
              UNASSIGN <lfs_a004_1>.
            ENDIF. " IF sy-subrc IS INITIAL
          ENDIF. " IF <lfs_a004>-datbi = lv_key_date
        ENDLOOP. " LOOP AT li_a004 ASSIGNING <lfs_a004>
        fp_itab = li_a004_1.
      ENDIF. " IF sy-subrc IS INITIAL
    WHEN lc_a005.

      SELECT mandt " Client
             kappl " Application
             kschl " Condition type
             vkorg " Sales Organization
             vtweg " Distribution Channel
             kunnr " Customer number
             matnr " Material Number
             datbi " Validity end date of the condition record
             datab " Validity start date of the condition record
             knumh " Condition record number
      FROM a005    " Customer/Material
      INTO TABLE li_a005
      WHERE kappl = lc_kappl
        AND kschl = p_cond
        AND vkorg IN s_vkorg
        AND vtweg IN s_vtweg
        AND kunnr IN s_kunag
        AND matnr IN s_matnr
        AND datbi >= lv_key_date.
      IF sy-subrc IS INITIAL.
        SORT li_a005 BY kappl kschl vkorg vtweg kunnr matnr datbi.
        LOOP AT li_a005 ASSIGNING <lfs_a005>.
          IF <lfs_a005>-datbi = lv_key_date.
*          If an inactive record is found, then check if there is any other future record for the same key
*          If there is another records then do nothing, else send the currect inactive records to another table
            CLEAR lv_index.
            lv_index = sy-tabix + 1.
            READ TABLE li_a005 ASSIGNING <lfs_a005_t> INDEX lv_index.
            IF sy-subrc IS INITIAL.
              IF <lfs_a005>-kappl = <lfs_a005_t>-kappl AND
                 <lfs_a005>-kschl = <lfs_a005_t>-kschl AND
                 <lfs_a005>-vkorg = <lfs_a005_t>-vkorg AND
                 <lfs_a005>-vtweg = <lfs_a005_t>-vtweg AND
                 <lfs_a005>-kunnr = <lfs_a005_t>-kunnr AND
                 <lfs_a005>-matnr = <lfs_a005_t>-matnr.
*                do nothing
              ELSE. " ELSE -> IF <lfs_a005>-kappl = <lfs_a005_t>-kappl AND
                APPEND INITIAL LINE TO li_a005_1 ASSIGNING <lfs_a005_1>.
                <lfs_a005_1> = <lfs_a005>.
                UNASSIGN <lfs_a005_1>.
              ENDIF. " IF <lfs_a005>-kappl = <lfs_a005_t>-kappl AND
            ELSE. " ELSE -> IF sy-subrc IS INITIAL
              APPEND INITIAL LINE TO li_a005_1 ASSIGNING <lfs_a005_1>.
              <lfs_a005_1> = <lfs_a005>.
              UNASSIGN <lfs_a005_1>.
            ENDIF. " IF sy-subrc IS INITIAL
          ENDIF. " IF <lfs_a005>-datbi = lv_key_date
        ENDLOOP. " LOOP AT li_a005 ASSIGNING <lfs_a005>
        fp_itab = li_a005_1.
      ENDIF. " IF sy-subrc IS INITIAL
    WHEN lc_a911.

      SELECT mandt  " Client
             kappl  " Application
             kschl  " Condition type
             vkorg  " Sales Organization
             vtweg  " Distribution Channel
             kunwe  " Ship-to party
             matnr  " Material Number
             kfrst  " Release status
             datbi  " Validity end date of the condition record
             datab  " Validity start date of the condition record
             kbstat " Processing status for conditions
             knumh  " Condition record number
       FROM a911    " Sales org./Distr. Chl/Ship-to/Material
       INTO TABLE li_a911
       WHERE kappl = lc_kappl
         AND kschl = p_cond
         AND vkorg IN s_vkorg
         AND vtweg IN s_vtweg
         AND kunwe IN s_kunwe
         AND matnr IN s_matnr
         AND datbi >= lv_key_date.
      IF sy-subrc IS INITIAL.
        SORT li_a911 BY kappl kschl vkorg vtweg kunwe matnr kfrst datbi.
        LOOP AT li_a911 ASSIGNING <lfs_a911>.
          IF <lfs_a911>-datbi = lv_key_date.
*          If an inactive record is found, then check if there is any other future record for the same key
*          If there is another records then do nothing, else send the currect inactive records to another table
            CLEAR : lv_index.
            lv_index = sy-tabix + 1.
            READ TABLE li_a911 ASSIGNING <lfs_a911_t> INDEX lv_index.
            IF sy-subrc IS INITIAL.
              IF <lfs_a911>-kappl = <lfs_a911_t>-kappl AND
                 <lfs_a911>-kschl = <lfs_a911_t>-kschl AND
                 <lfs_a911>-vkorg = <lfs_a911_t>-vkorg AND
                 <lfs_a911>-vtweg = <lfs_a911_t>-vtweg AND
                 <lfs_a911>-kunwe = <lfs_a911_t>-kunwe AND
                 <lfs_a911>-matnr = <lfs_a911_t>-matnr AND
                 <lfs_a911>-kfrst = <lfs_a911_t>-kfrst.
*              do nothing
              ELSE. " ELSE -> IF <lfs_a911>-kappl = <lfs_a911_t>-kappl AND
                APPEND INITIAL LINE TO li_a911_1 ASSIGNING <lfs_a911_1>.
                <lfs_a911_1> = <lfs_a911>.
                UNASSIGN <lfs_a911_1>.
              ENDIF. " IF <lfs_a911>-kappl = <lfs_a911_t>-kappl AND
            ELSE. " ELSE -> IF sy-subrc IS INITIAL
              APPEND INITIAL LINE TO li_a911_1 ASSIGNING <lfs_a911_1>.
              <lfs_a911_1> = <lfs_a911>.
              UNASSIGN <lfs_a911_1>.
            ENDIF. " IF sy-subrc IS INITIAL
          ENDIF. " IF <lfs_a911>-datbi = lv_key_date
        ENDLOOP. " LOOP AT li_a911 ASSIGNING <lfs_a911>
        fp_itab = li_a911_1.
      ENDIF. " IF sy-subrc IS INITIAL

    WHEN lc_a935.

      SELECT mandt  " Client
             kappl  " Application
             kschl  " Condition type
             vkorg  " Sales Organization
             vtweg  " Distribution Channel
             kunag  " Sold-to party
             kunwe  " Ship-to party
             matnr  " Material Number
             kfrst  " Release status
             datbi  " Validity end date of the condition record
             datab  " Validity start date of the condition record
             kbstat " Processing status for conditions
             knumh  " Condition record number
       FROM a935    " Sales org./Distr. Chl/Sold-to pt/Ship-to/Material
       INTO TABLE li_a935
       WHERE kappl = lc_kappl
         AND kschl = p_cond
         AND vkorg IN s_vkorg
         AND vtweg IN s_vtweg
         AND kunag IN s_kunag
         AND kunwe IN s_kunwe
         AND matnr IN s_matnr
         AND datbi >= lv_key_date.
      IF sy-subrc IS INITIAL.
        SORT li_a935 BY kappl kschl vkorg vtweg kunag kunwe matnr kfrst datbi.
        LOOP AT li_a935 ASSIGNING <lfs_a935>.
          IF <lfs_a935>-datbi = lv_key_date.
*          If an inactive record is found, then check if there is any other future record for the same key
*          If there is another records then do nothing, else send the currect inactive records to another table
            CLEAR : lv_index.
            lv_index = sy-tabix + 1.
            READ TABLE li_a935 ASSIGNING <lfs_a935_t> INDEX lv_index.
            IF sy-subrc IS INITIAL.
              IF <lfs_a935>-kappl = <lfs_a935_t>-kappl AND
                 <lfs_a935>-kschl = <lfs_a935_t>-kschl AND
                 <lfs_a935>-vkorg = <lfs_a935_t>-vkorg AND
                 <lfs_a935>-vtweg = <lfs_a935_t>-vtweg AND
                 <lfs_a935>-kunag = <lfs_a935_t>-kunag AND
                 <lfs_a935>-kunwe = <lfs_a935_t>-kunwe AND
                 <lfs_a935>-matnr = <lfs_a935_t>-matnr AND
                 <lfs_a935>-kfrst = <lfs_a935_t>-kfrst.
*                do nothing
              ELSE. " ELSE -> IF <lfs_a935>-kappl = <lfs_a935_t>-kappl AND
                APPEND INITIAL LINE TO li_a935_1 ASSIGNING <lfs_a935_1>.
                <lfs_a935_1> = <lfs_a935>.
                UNASSIGN <lfs_a935_1>.
              ENDIF. " IF <lfs_a935>-kappl = <lfs_a935_t>-kappl AND
            ELSE. " ELSE -> IF sy-subrc IS INITIAL
              APPEND INITIAL LINE TO li_a935_1 ASSIGNING <lfs_a935_1>.
              <lfs_a935_1> = <lfs_a935>.
              UNASSIGN <lfs_a935_1>.
            ENDIF. " IF sy-subrc IS INITIAL
          ENDIF. " IF <lfs_a935>-datbi = lv_key_date
        ENDLOOP. " LOOP AT li_a935 ASSIGNING <lfs_a935>
        fp_itab = li_a935_1.
      ENDIF. " IF sy-subrc IS INITIAL

    WHEN OTHERS.
*   do nothing
  ENDCASE.

  FREE : li_a004,
         li_a005,
         li_a911,
         li_a935,
         li_a004_1,
         li_a005_1,
         li_a911_1,
         li_a935_1.

ENDFORM. " F_FETCH_INACTIVE_RECORDS1
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SALESORG
*&---------------------------------------------------------------------*
*       Validate sales organization
*----------------------------------------------------------------------*
FORM f_validate_salesorg .

  TYPES : BEGIN OF lty_vkorg,
            vkorg TYPE vkorg, " Sales Organization
          END OF lty_vkorg.
  DATA : li_vkorg TYPE TABLE OF lty_vkorg.
  IF  s_vkorg  IS NOT INITIAL.
    SELECT vkorg " Sales Organization
      FROM tvko  " Organizational Unit: Sales Organizations
      INTO TABLE li_vkorg
      WHERE vkorg IN s_vkorg.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE e000 WITH 'Invalid Sales org'(024).
    ENDIF. " IF sy-subrc IS NOT INITIAL
  ENDIF. " IF s_vkorg IS NOT INITIAL

ENDFORM. " F_VALIDATE_SALESORG
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DISTCHANNEL
*&---------------------------------------------------------------------*
*       Validate dist channel
*----------------------------------------------------------------------*
FORM f_validate_distchannel .

  TYPES : BEGIN OF lty_vtweg,
            vtweg TYPE vtweg, " Distribution Channel
          END OF lty_vtweg.
  DATA : li_vtweg TYPE TABLE OF lty_vtweg.
  IF s_vtweg IS NOT INITIAL.
    SELECT vtweg " Distribution Channel
      FROM tvtw  " Organizational Unit: Distribution Channels
      INTO TABLE li_vtweg
      WHERE vtweg IN s_vtweg.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE e000 WITH 'Dist. channel not valid'(025).
    ENDIF. " IF sy-subrc IS NOT INITIAL
  ENDIF. " IF s_vtweg IS NOT INITIAL
ENDFORM. " F_VALIDATE_DISTCHANNEL
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_MATNR
*&---------------------------------------------------------------------*
*       Validate material
*----------------------------------------------------------------------*
FORM f_validate_matnr .

  TYPES : BEGIN OF lty_matnr,
            matnr TYPE matnr, " Material Number
          END OF lty_matnr.
  DATA : li_matnr TYPE TABLE OF lty_matnr.
  IF s_matnr IS NOT INITIAL.
    SELECT matnr " Material Number
      FROM mara  " General Material Data
      INTO TABLE li_matnr
      WHERE matnr IN s_matnr.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE e000 WITH 'Material not valid'(026).
    ENDIF. " IF sy-subrc IS NOT INITIAL
  ENDIF. " IF s_matnr IS NOT INITIAL
ENDFORM. " F_VALIDATE_MATNR
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SOLDTOPARTY
*&---------------------------------------------------------------------*
*       Validate sold to party
*----------------------------------------------------------------------*
FORM f_validate_soldtoparty .
  TYPES : BEGIN OF lty_kunnr,
            kunnr TYPE kunnr, " Customer Number
          END OF lty_kunnr.
  DATA : li_kunnr TYPE TABLE OF lty_kunnr.
  IF s_kunag IS NOT INITIAL.
    SELECT kunnr " Customer Number
      FROM kna1  " General Data in Customer Master
      INTO TABLE li_kunnr
      WHERE kunnr IN s_kunag.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE e000 WITH 'Sold to party not valid'(027).
    ENDIF. " IF sy-subrc IS NOT INITIAL
  ENDIF. " IF s_kunag IS NOT INITIAL
ENDFORM. " F_VALIDATE_SOLDTOPARTY
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SHIPTOPARTY
*&---------------------------------------------------------------------*
*       Validate ship to party
*----------------------------------------------------------------------*
FORM f_validate_shiptoparty .
  TYPES : BEGIN OF lty_kunnr,
            kunnr TYPE kunnr, " Customer Number
          END OF lty_kunnr.
  DATA : li_kunnr TYPE TABLE OF lty_kunnr.
  IF s_kunwe IS NOT INITIAL.
    SELECT kunnr " Customer Number
      FROM kna1  " General Data in Customer Master
      INTO TABLE li_kunnr
      WHERE kunnr IN s_kunwe.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE e000 WITH 'Ship to party not valid'(028).
    ENDIF. " IF sy-subrc IS NOT INITIAL
  ENDIF. " IF s_kunwe IS NOT INITIAL
ENDFORM. " F_VALIDATE_SHIPTOPARTY
