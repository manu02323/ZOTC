*&---------------------------------------------------------------------*
* PROGRAM    : ZOTCR0141O_CONVERT_SALES_FORM                           *
* TITLE       :  Reconciliation Report                                 *
*                                                                      *
* DEVELOPER  :  Khushboo Mishra                                        *
* OBJECT TYPE:  ALV report                                             *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_CDD_0141                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Subroutines for for ZOTCN0007O_CONVERT_SALES_ORDER                           *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT  DESCRIPTION                        *
* ===========  ========  ========== ===================================*
* 05/16/2016   KMISHRA   E1DK917543 Initial Development
* ===========  ========  ========== ===================================*
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_SET_DEFAULT_VAL
*&---------------------------------------------------------------------*
*   Subroutine to set defalut value of selection parameter
*----------------------------------------------------------------------*
FORM f_set_default_val .

  CONSTANTS:
     lc_sign_i     TYPE char1 VALUE 'I',    "I=Include
     lc_option_eq  TYPE char2 VALUE 'EQ',   "EQ=Equal
     lc_zstd       TYPE auart VALUE 'ZSTD', " Sales Document Type
     lc_zor        TYPE auart VALUE 'ZOR'.  " Sales Document Type

  TYPES:
    BEGIN OF lty_auart,
     sign   TYPE char1, "Sign
     option TYPE char2, "Option
     low    TYPE auart, "Low Value
     high   TYPE auart, "High Value
    END OF lty_auart.

  DATA : lwa_auart TYPE lty_auart.

  lwa_auart-option = lc_option_eq.
  lwa_auart-sign   = lc_sign_i .
  lwa_auart-low    = lc_zstd.
  APPEND lwa_auart TO s_auart.
  CLEAR lwa_auart.
  lwa_auart-option = lc_option_eq.
  lwa_auart-sign   = lc_sign_i .
  lwa_auart-low    = lc_zor.
  APPEND lwa_auart TO s_auart.
  CLEAR lwa_auart.

ENDFORM. " F_SET_DEFAULT_VAL
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       Subroutine for data selection based on parameters entered
*         at selection.
*----------------------------------------------------------------------*
FORM f_get_data.

*&--Local Declaration
  DATA: li_vbak TYPE STANDARD TABLE OF ty_vbak,
        li_vbap TYPE STANDARD TABLE OF ty_vbap,
        li_ser02 TYPE STANDARD TABLE OF ty_ser02.


  REFRESH: i_vbak,
           i_vbap,
           i_vbpa,
           i_veda,
           li_ser02,
           li_vbak,
           li_vbap.

*--Fetching Sales Document Header data
  SELECT  vbeln    " Sales Document
          erdat    " Date on Which Record Was Created
          auart    " Sales Document Type
          vkorg    " Sales Organization
          vtweg    " Distribution Channel
          spart    " Division
          vkbur    " Sales Office
          zzdocref " Legacy Doc Ref
          zzdoctyp " Ref Doc type
    FROM vbak      " Sales Document: Header Data
    INTO TABLE i_vbak
    WHERE erdat IN s_erdat
      AND auart IN s_auart
      AND vkorg IN s_vkorg
      AND vtweg IN s_vtweg
      AND spart EQ p_spart
      AND zzdocref IN s_docref.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE i115 DISPLAY LIKE c_msgty.
    LEAVE LIST-PROCESSING.
  ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL
** Vbeln is primary key of table VBAK so only unique entry will be there.
    li_vbak[] = i_vbak[].
    IF li_vbak IS NOT INITIAL.
*--Fetch Item data from VBAP
      SELECT
           vbeln       " Sales Document
           posnr       " Sales Document Item
           matnr       " Material Number
           pstyv       " Sales document item category
           zmeng       " Target quantity in sales units
           zieme       " Target quantity UoM
           netwr       " Net value of the order item in document currency
           waerk       " SD Document Currency
           kwmeng      " Cumulative Order Quantity in Sales Units
           vrkme       " Sales unit
           werks       " Plant (Own or External)
           zzagmnt     " Warr / Serv Plan ID
           zzagmnt_typ " ID Type
           zzitemref   " ServMax Obj ID
           zzquoteref  " Legacy Qtn Ref
           zz_bilmet   " Billing Method
           zz_bilfr    " Billing Frequency
        FROM vbap      " Sales Document: Item Data
        INTO TABLE i_vbap
        FOR ALL ENTRIES IN li_vbak
        WHERE vbeln = li_vbak-vbeln.

      IF sy-subrc IS INITIAL.
        li_vbap[] = i_vbap[].
        IF li_vbap IS NOT INITIAL.
* Fetching Sales Document Partner Data
          SELECT vbeln "Sales and Distribution Document Number
                 posnr "Item number of the SD document
                 parvw "Partner Function
                 kunnr "Customer Number
          FROM vbpa    " Sales Document: Partner
          INTO TABLE i_vbpa
          FOR ALL ENTRIES IN li_vbap
          WHERE vbeln = li_vbap-vbeln.
          IF sy-subrc EQ 0.
            SORT i_vbpa BY vbeln posnr.
          ENDIF. " IF sy-subrc EQ 0

*Fetching Contract Data

          SELECT vbeln   " Sales Document
                 vposn   " Sales Document Item
                 vbegdat " Contract start date
                 venddat " Contract end date
            FROM veda    " Contract Data
            INTO TABLE i_veda
            FOR ALL ENTRIES IN li_vbap
            WHERE vbeln = li_vbap-vbeln.
          IF sy-subrc EQ 0.
            SORT i_veda BY vbeln.
          ENDIF. " IF sy-subrc EQ 0


*Fetching  object list no from SER02 table
          SELECT obknr   " Object list number
                 sdaufnr " Sales Document
                 posnr   " Sales Document Item
          FROM ser02     " Document Header for Serial Nos for Maint.Contract (SD Order)
            INTO TABLE i_ser02
            FOR ALL ENTRIES IN li_vbap
            WHERE sdaufnr = li_vbap-vbeln
          AND   posnr = li_vbap-posnr.
          IF sy-subrc EQ 0.
            li_ser02[] = i_ser02[].
            SORT li_ser02 BY obknr.
            DELETE ADJACENT DUPLICATES FROM li_ser02 COMPARING obknr.
            DELETE li_ser02 WHERE obknr IS INITIAL.
            IF li_ser02 IS NOT INITIAL.

              SELECT obknr " Object list number
                     sernr " Serial Number
              FROM   objk  " Plant Maintenance Object List
              INTO TABLE i_objk
              FOR ALL ENTRIES IN li_ser02
              WHERE obknr = li_ser02-obknr.
              IF sy-subrc EQ 0.
                SORT i_objk BY obknr.
              ENDIF. " IF sy-subrc EQ 0
            ENDIF. " IF li_ser02 IS NOT INITIAL
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF li_vbap IS NOT INITIAL
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF li_vbak IS NOT INITIAL

  ENDIF. " IF sy-subrc IS NOT INITIAL




ENDFORM. " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DATA_PROCESSING
*&---------------------------------------------------------------------*
*       Subroutine to process data and build final table to display at
*         report output
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  FP_FINAL  Final Table
*----------------------------------------------------------------------*
FORM f_data_processing CHANGING fp_final TYPE ty_t_final.
  FIELD-SYMBOLS: <lfs_vbak> TYPE ty_vbak,
                 <lfs_vbap> TYPE ty_vbap,
                 <lfs_vbpa> TYPE ty_vbpa,
                 <lfs_ser02> TYPE ty_ser02,
                 <lfs_objk> TYPE ty_objk,
                 <lfs_veda> TYPE ty_veda.

  CONSTANTS: lc_shipto TYPE parvw VALUE 'WE',         " Partner Function
             lc_soldto TYPE parvw VALUE 'AG',         " Partner Function
             lc_billto TYPE parvw VALUE 'RE',         " Partner Function
             lc_payer TYPE parvw VALUE 'RG',          " Partner Function
             lc_posnr_h TYPE posnr_va VALUE '000000'. " Sales Document Item

  DATA: lwa_final TYPE ty_final.

  SORT i_vbak BY vbeln.
  SORT i_vbpa BY vbeln parvw.
  SORT i_ser02 BY sdaufnr posnr.
  SORT i_veda BY vbeln vposn.



  LOOP AT i_vbap ASSIGNING <lfs_vbap>.

    lwa_final-vbeln = <lfs_vbap>-vbeln. "Sales Document
    lwa_final-posnr  = <lfs_vbap>-posnr. "Sales Document Item
    lwa_final-matnr  = <lfs_vbap>-matnr. "Material Number
    lwa_final-werks  = <lfs_vbap>-werks. "Plant
    lwa_final-pstyv  = <lfs_vbap>-pstyv. "Sales document item category
    lwa_final-zmeng  = <lfs_vbap>-zmeng. "Target quantity in sales units
    lwa_final-zieme = <lfs_vbap>-zieme. "Target quantity UoM
    lwa_final-kwmeng = <lfs_vbap>-kwmeng. "Cumulative Order Quantity in Sales Units
    lwa_final-vrkme = <lfs_vbap>-vrkme. "Sales unit
    lwa_final-netwr = <lfs_vbap>-netwr. "Net value of the order item in document currency
    lwa_final-waerk = <lfs_vbap>-waerk. "SD Document Currency
    lwa_final-zzagmnt = <lfs_vbap>-zzagmnt. "Warr / Serv Plan ID
    lwa_final-zzagmnt_typ = <lfs_vbap>-zzagmnt_typ. "ID Type
    lwa_final-zzitemref = <lfs_vbap>-zzitemref. "ServMax Obj ID
    lwa_final-zzquoteref = <lfs_vbap>-zzquoteref. "Legacy Qtn Ref
    lwa_final-zz_bilmet = <lfs_vbap>-zz_bilmet. "Billing Method
    lwa_final-zz_bilfr = <lfs_vbap>-zz_bilfr. "Billing Frequency

    READ TABLE i_vbak ASSIGNING <lfs_vbak>
    WITH KEY vbeln = <lfs_vbap>-vbeln
    BINARY SEARCH.
    IF sy-subrc EQ 0.

      lwa_final-zzdocref     = <lfs_vbak>-zzdocref. "Legacy Doc Ref
      lwa_final-zzdoctyp     = <lfs_vbak>-zzdoctyp. "Ref Doc type
      lwa_final-auart        = <lfs_vbak>-auart. "Sales Document Type
      lwa_final-vkorg        = <lfs_vbak>-vkorg. "Sales Organization
      lwa_final-vtweg        = <lfs_vbak>-vtweg. "Distribution Channel
      lwa_final-spart        = <lfs_vbak>-spart. "Division
      lwa_final-vkbur        = <lfs_vbak>-vkbur. "Sales Office

    ENDIF. " IF sy-subrc EQ 0

* Populating Sold to party
    IF <lfs_vbpa> IS ASSIGNED.
      UNASSIGN: <lfs_vbpa>.
    ENDIF. " IF <lfs_vbpa> IS ASSIGNED
    READ TABLE i_vbpa ASSIGNING <lfs_vbpa>
    WITH KEY vbeln = <lfs_vbap>-vbeln
    parvw = lc_soldto
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      lwa_final-zsoldto = <lfs_vbpa>-kunnr.
    ENDIF. " IF sy-subrc EQ 0

*    Populating ship to party
    IF <lfs_vbpa> IS ASSIGNED.
      UNASSIGN: <lfs_vbpa>.
    ENDIF. " IF <lfs_vbpa> IS ASSIGNED
    READ TABLE i_vbpa ASSIGNING <lfs_vbpa>
    WITH KEY vbeln = <lfs_vbap>-vbeln
          parvw = lc_shipto
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      lwa_final-zshipto = <lfs_vbpa>-kunnr.
    ENDIF. " IF sy-subrc EQ 0

*Populating Bill to party
    IF <lfs_vbpa> IS ASSIGNED.
      UNASSIGN: <lfs_vbpa>.
    ENDIF. " IF <lfs_vbpa> IS ASSIGNED
    READ TABLE i_vbpa ASSIGNING <lfs_vbpa>
    WITH KEY vbeln = <lfs_vbap>-vbeln
    parvw = lc_billto
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      lwa_final-zbillto = <lfs_vbpa>-kunnr.
    ENDIF. " IF sy-subrc EQ 0

*Populating Payer
    IF <lfs_vbpa> IS ASSIGNED.
      UNASSIGN: <lfs_vbpa>.
    ENDIF. " IF <lfs_vbpa> IS ASSIGNED

    READ TABLE i_vbpa ASSIGNING <lfs_vbpa>
    WITH KEY vbeln = <lfs_vbap>-vbeln
    parvw = lc_payer
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      lwa_final-zpayer = <lfs_vbpa>-kunnr.
    ENDIF. " IF sy-subrc EQ 0

*For SAP Contract Start date and end date at header level
    IF <lfs_veda> IS ASSIGNED.
      UNASSIGN: <lfs_veda>.
    ENDIF. " IF <lfs_veda> IS ASSIGNED
    READ TABLE i_veda ASSIGNING <lfs_veda>
    WITH KEY vbeln = <lfs_vbap>-vbeln
             vposn = lc_posnr_h
             BINARY SEARCH.
    IF sy-subrc EQ 0.
      lwa_final-vbegdat_h = <lfs_veda>-vbegdat.
      lwa_final-venddat_h = <lfs_veda>-venddat.
    ENDIF. " IF sy-subrc EQ 0

* For SAP Contract Start date and end date at item level
    IF <lfs_veda> IS ASSIGNED.
      UNASSIGN: <lfs_veda>.
    ENDIF. " IF <lfs_veda> IS ASSIGNED
    READ TABLE i_veda ASSIGNING <lfs_veda>
    WITH KEY vbeln = <lfs_vbap>-vbeln
             vposn = <lfs_vbap>-posnr
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      lwa_final-vbegdat_i = <lfs_veda>-vbegdat.
      lwa_final-venddat_i = <lfs_veda>-venddat.
    ENDIF. " IF sy-subrc EQ 0

    READ TABLE i_ser02 ASSIGNING <lfs_ser02>
    WITH KEY   sdaufnr = <lfs_vbap>-vbeln " Sales Document
               posnr = <lfs_vbap>-posnr   " Sales Document Item
               BINARY SEARCH.
    IF sy-subrc EQ 0.
      READ TABLE i_objk ASSIGNING <lfs_objk>
      WITH KEY obknr = <lfs_ser02>-obknr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        lwa_final-sernr = <lfs_objk>-sernr.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
    APPEND lwa_final TO fp_final.
    CLEAR lwa_final.


  ENDLOOP. " LOOP AT i_vbap ASSIGNING <lfs_vbap>
ENDFORM. " F_DATA_PROCESSING

*&---------------------------------------------------------------------*
*&      Form  F_OUTPUT_DISPLAY
*&---------------------------------------------------------------------*
*       Subroutine to display the output in ALV
*----------------------------------------------------------------------*
*  -->  FP_FINAL      Final table
*----------------------------------------------------------------------*
FORM f_output_display USING fp_final TYPE ty_t_final.

*&--Local constant declaration
  CONSTANTS:
   lc_top_page TYPE slis_formname VALUE 'F_TOP_OF_PAGE',
   lc_11 TYPE int4 VALUE '11' ##str_num, " Natural Number
   lc_12 TYPE int4 VALUE '12' ##str_num, " Natural Number
   lc_13 TYPE int4 VALUE '13' ##str_num, " Natural Number
   lc_14 TYPE int4 VALUE '14' ##str_num, " Natural Number
   lc_15 TYPE int4 VALUE '15' ##str_num, " Natural Number
   lc_16 TYPE int4 VALUE '16' ##str_num, " Natural Number
   lc_17 TYPE int4 VALUE '17' ##str_num, " Natural Number
   lc_18 TYPE int4 VALUE '18' ##str_num, " Natural Number
   lc_19 TYPE int4 VALUE '19' ##str_num, " Natural Number
   lc_20 TYPE int4 VALUE '20' ##str_num, " Natural Number
   lc_21 TYPE int4 VALUE '21' ##str_num, " Natural Number
   lc_22 TYPE int4 VALUE '22' ##str_num, " Natural Number
   lc_23 TYPE int4 VALUE '23' ##str_num, " Natural Number
   lc_24 TYPE int4 VALUE '24' ##str_num, " Natural Number
   lc_25 TYPE int4 VALUE '25' ##str_num, " Natural Number
   lc_26 TYPE int4 VALUE '26' ##str_num, " Natural Number
   lc_27 TYPE int4 VALUE '27' ##str_num, " Natural Number
   lc_28 TYPE int4 VALUE '28' ##str_num, "  Natural Number
   lc_29 TYPE int4 VALUE '29' ##str_num, " Natural Number
   lc_30 TYPE int4 VALUE '30' ##str_num, " Natural Number
   lc_31 TYPE int4 VALUE '31' ##str_num, " Natural Number
   lc_32 TYPE int4 VALUE '32' ##str_num. " Natural Number
*&--Local declaration
  DATA lwa_layout  TYPE slis_layout_alv. " Layout


*&--Building Header
  PERFORM f_fill_header USING fp_final.

*&--Building Fieldcatalog table
  PERFORM f_fill_fieldcat USING :
  'ZZDOCREF'(006) ''  '' 'Legacy document#'(007)
  0 '' '',

  'ZZDOCTYP'(008) ''  '' 'Legacy document type'(009)
  1 '' '',

  'AUART'(010) ''  '' 'SAP document type'(011)
  2 '' '',

  'VBELN'(012) ''  '' 'SAP document #'(013)
  3 '' '',

  'VKORG'(014) ''  '' 'SAP Sales Org'(015)
  4 '' '',

  'VTWEG'(016) ''  '' 'SAP Distribution Channel'(017)
  5 '' '',

  'SPART'(018) ''  '' 'SAP Division'(019)
  6 '' '',

  'VKBUR'(020) ''  '' 'SAP Sales Office'(021)
  7 '' '',

 'ZSOLDTO'(022) ''  '' 'SAP Sold-to party#'(023)
  8 '' '',

 'ZSHIPTO'(024) ''  '' 'SAP Ship-to party#'(025)
  9 '' '',

  'ZBILLTO'(026) ''  '' 'SAP Bill-to party#'(027)
  10 '' '',

  'ZPAYER'(028) ''  '' 'SAP Payer#'(029)
  lc_11 '' '',

  'VBEGDAT_H'(030) ''  '' 'SAP Contract Start date'(031)
  lc_12 '' '',

  'VENDDAT_H'(032) ''  '' 'SAP Contract End Date'(033)
  lc_13 '' '',

  'POSNR'(034) ''  '' 'SAP document Item#'(035)
  lc_14 '' '',

  'MATNR'(036) ''  '' 'SAP Material#'(037)
  lc_15 '' '',

  'WERKS'(038) ''  '' 'SAP Plant#'(039)
  lc_16 '' '',

  'PSTYV'(040) ''  '' 'SAP Item category'(041)
  lc_17 '' '',

  'ZMENG'(042) ''  'ZIEME' 'SAP Item target Quantity'(043)
  lc_18 '' '',

  'ZIEME'(044) ''  '' 'SAP Item target UoM'(045)
  lc_19 '' '',

  'KWMENG'(046) ''  'VRKME' 'SAP Cumulative Order Quantity'(047)
  lc_20 '' '',

  'VRKME'(048) ''  '' 'SAP Sales UoM'(049)
  lc_21 '' '',

  'NETWR'(050) 'WAERK'  '' 'SAP Item Net Value'(051)
  lc_22 '' '',

  'WAERK'(076) ''  '' 'SD Document Currency'(077)
  lc_23 '' '',

  'VBEGDAT_I'(068) ''  '' 'SAP Contract Start date(Item)'(053)
  lc_24 '' '',

  'VENDDAT_I'(069) ''  '' 'SAP Contract End Date(Item)'(055)
  lc_25 '' '',

  'ZZAGMNT'(056) ''  '' 'SAP Warr / Serv Plan ID'(057)
  lc_26 '' '',

  'ZZAGMNT_TYP'(058) ''  '' 'SAP Warr / Serv Plan ID Type'(059)
  lc_27 '' '',

  'ZZITEMREF'(060) ''  '' 'ServMax Obj ID'(061)
  lc_28 '' '',

  'ZZQUOTREF'(062) ''  '' 'Legacy Qtn Ref'(063)
  lc_29 '' '',

  'ZZ_BILMET'(064) ''  '' 'Billing Method'(065)
  lc_30 '' '',

  'ZZ_BILFR'(066) ''  '' 'Billing Frequency'(067)
  lc_31 '' '',

  'SERNR'(052) ''  '' 'Serial#'(054)
  lc_32 '' ''.

*&--End of building fieldcatalog table

*Prepare layout
  lwa_layout-colwidth_optimize = abap_true.
  lwa_layout-zebra             = abap_true.

*Sort ALV Grid
  PERFORM f_sort CHANGING i_sort.

*&--FM Call to display output in ALV
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = gv_prog_name
      i_callback_top_of_page = lc_top_page
      is_layout              = lwa_layout
      it_fieldcat            = i_fieldcat
      i_save                 = c_save
      it_sort                = i_sort
    TABLES
      t_outtab               = fp_final
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.
  IF sy-subrc <> 0.
    MESSAGE i000 WITH 'Output could not be displayed'(074).
  ENDIF. " IF sy-subrc <> 0

ENDFORM. " F_OUTPUT_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  F_FILL_HEADER
*&---------------------------------------------------------------------*
*       subroutine to fill header Internal table
*----------------------------------------------------------------------*
*  -->  FP_FINAL       Final table
*----------------------------------------------------------------------*
FORM f_fill_header USING fp_final TYPE ty_t_final.

*&--Local Constants declaration
  CONSTANTS:
         lc_h           TYPE char1 VALUE 'H', " H of type CHAR1
         lc_s           TYPE char1 VALUE 'S', " S of type CHAR1
         lc_coln        TYPE char1 VALUE ':', " Coln of type CHAR1
         lc_slash       TYPE char1 VALUE '/'. " Slash of type CHAR1

*&--Local declaration
  DATA: lv_date        TYPE char10,                     "date variable
        lv_time        TYPE char10,                     "time variable
        lv_lines       TYPE int4,                       "records count of final table
        lwa_address    TYPE bapiaddr3,                  "User Address Data
        lwa_listheader TYPE slis_listheader,            "List header Workarea
        li_return      TYPE STANDARD TABLE OF bapiret2. "return table

  lwa_listheader-typ  = lc_h.
  lwa_listheader-key  = 'Report'(001).
  lwa_listheader-info = 'Reconciliation Report'(002).
  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.

  lwa_listheader-typ  = lc_s.
  lwa_listheader-key  = 'User Name'(003).

*&--Get user details
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    IMPORTING
      address  = lwa_address
    TABLES
      return   = li_return.

  IF lwa_address-fullname IS NOT INITIAL.
    lwa_listheader-info = lwa_address-fullname.
  ELSE. " ELSE -> IF lwa_address-fullname IS NOT INITIAL
    lwa_listheader-info = sy-uname.
  ENDIF. " IF lwa_address-fullname IS NOT INITIAL

  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.

  lwa_listheader-typ = lc_s.
  lwa_listheader-key = 'Date and Time'(004).

  CONCATENATE sy-uzeit+0(2)
              sy-uzeit+2(2)
              sy-uzeit+4(2)
         INTO lv_time
         SEPARATED BY lc_coln.

  CONCATENATE sy-datum+4(2)
              sy-datum+6(2)
              sy-datum+0(4)
         INTO lv_date
         SEPARATED BY lc_slash.

  CONCATENATE lv_date
              lv_time
         INTO lwa_listheader-info
         SEPARATED BY space.
  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.

  DESCRIBE TABLE fp_final[] LINES lv_lines.

  lwa_listheader-typ  = lc_s.
  lwa_listheader-key  = 'Total Records'(005).

  lwa_listheader-info = lv_lines . "slis_entry
  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.
  CLEAR lv_lines.

ENDFORM. " F_FILL_LISTHEADER
*&---------------------------------------------------------------------*
*&      Form  F_FILL_FIELDCAT
*&---------------------------------------------------------------------*
*       Subroutine to fill fieldcatalog table
*----------------------------------------------------------------------*
*      -->FP_FIELDNAME    Fieldname
*      -->FP_CFIELDNAME   Field with currency unit
*      -->FP_QFIELDNAME   Field with quantity unit
*      -->FP_SELTEXT_L    Long key word
*      -->FP_COL_POS      Position of the column
*      -->FP_NO_OUT       (O)blig.(X)no out
*      -->FP_DATATYPE     Datatype
*----------------------------------------------------------------------*
FORM f_fill_fieldcat USING fp_fieldname  TYPE slis_fieldname
                           fp_cfieldname TYPE slis_fieldname
                           fp_qfieldname TYPE slis_fieldname
                           fp_seltext_l  TYPE scrtext_l " Long Field Label
                           fp_col_pos    TYPE sycucol   " Horizontal Cursor Position at PAI
                           fp_no_out     TYPE char1     " No_out of type CHAR1
                           fp_datatype   TYPE datatype_d.

  DATA : lwa_fieldcat   TYPE slis_fieldcat_alv. "Fieldcatalog Workarea

  CLEAR lwa_fieldcat.
  lwa_fieldcat-fieldname  = fp_fieldname.
  lwa_fieldcat-cfieldname = fp_cfieldname.
  lwa_fieldcat-qfieldname = fp_qfieldname.
  lwa_fieldcat-seltext_l  = fp_seltext_l.
  lwa_fieldcat-col_pos    = fp_col_pos.
  lwa_fieldcat-no_out     = fp_no_out.
  lwa_fieldcat-datatype   = fp_datatype.

  APPEND lwa_fieldcat TO i_fieldcat.

ENDFORM. " F_FILL_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       Subroutine f_top_of_page
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
##called
*&---------------------------------------------------------------------*
*&      Form  f_top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_top_of_page .

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = i_listheader.

ENDFORM. "f_top_of_page
*&---------------------------------------------------------------------*
*&      Form  F_SORT
*&---------------------------------------------------------------------*
*       Subroutine to sort ALV
*----------------------------------------------------------------------*
*      <--P_LI_SORT  text
*----------------------------------------------------------------------*
FORM f_sort  CHANGING fp_i_sort TYPE slis_t_sortinfo_alv.
  DATA : lwa_sort TYPE slis_sortinfo_alv.
  CONSTANTS: lc_sort TYPE char6 VALUE'i_sort' ##no_text. " Sort of type CHAR5
  lwa_sort-spos = 1.
  lwa_sort-fieldname = 'VBELN'.
  lwa_sort-tabname = lc_sort.
  lwa_sort-up = 'X'.
  APPEND lwa_sort TO fp_i_sort.
  CLEAR lwa_sort.

ENDFORM. " F_SORT
*&---------------------------------------------------------------------*
*&      Form  F_VKORG_VALIDATION
*&---------------------------------------------------------------------*
*       Sales Organization Validation
*----------------------------------------------------------------------*

FORM f_vkorg_validation  USING    fp_s_vkorg TYPE ty_t_s_vkorg.
  DATA: lv_vkorg TYPE vkorg. "Sales Organization

  SELECT SINGLE vkorg            "Sales Organization
     FROM tvko                   "Sales Organization
     INTO lv_vkorg
     WHERE vkorg IN fp_s_vkorg . "#EC WARNOK "fp_s_vkorg.
  IF sy-subrc NE 0.
    MESSAGE e000 WITH 'Invalid Sales Organization'(070) .
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_VKORG_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_VTWEG_VALIDATION
*&---------------------------------------------------------------------*
*       Distribution Channel Validation
*----------------------------------------------------------------------*

FORM f_vtweg_validation  USING    fp_s_vtweg TYPE ty_t_s_vtweg.
  DATA: lv_vtweg TYPE vtweg. "Distribution Channel

  SELECT SINGLE vtweg            "Distribution Channel
     FROM tvtw                   "Distribution Channel
     INTO lv_vtweg
     WHERE vtweg IN fp_s_vtweg . "#EC WARNOK    "fp_s_vtweg.
  IF sy-subrc NE 0.
    MESSAGE e000 WITH 'Invalid Distribution Channel'(071) .
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VTWEG_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_AUART_VALIDATION
*&---------------------------------------------------------------------*
*       Sales Document Type Validation
*----------------------------------------------------------------------*

FORM f_auart_validation  USING    fp_s_auart TYPE ty_t_s_auart.
  DATA: lv_auart TYPE auart. "Sales Document Type

  SELECT SINGLE auart            "Sales Document Type
     FROM tvak                   "Sales Document Types
     INTO lv_auart
     WHERE auart IN fp_s_auart . "#EC WARNOK "fp_s_auart.
  IF sy-subrc NE 0.
    MESSAGE e000 WITH 'Invalid Sales Document Type'(072) .
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_AUART_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_SPART_VALIDATION
*&---------------------------------------------------------------------*
*       Division Validation
*----------------------------------------------------------------------*

FORM f_spart_validation  USING    fp_p_spart TYPE spart. " Division
  DATA: lv_spart TYPE spart. "Division

  SELECT SINGLE spart            "Division
     FROM tspa                   "Division
     INTO lv_spart
     WHERE spart EQ fp_p_spart . "fp_p_spart.
  IF sy-subrc NE 0.
    MESSAGE e000 WITH 'Invalid Division'(073) .
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_SPART_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_VKORG_VTWEG_SPART_VALIDATION
*&---------------------------------------------------------------------*
*Combination Validation on Sales organisation, Dist. channel and Division
*----------------------------------------------------------------------*
*      -->P_S_VKORG[]  text
*      -->P_S_VTWEG[]  text
*      -->P_P_SPART  text
*----------------------------------------------------------------------*
FORM f_vkorg_vtweg_spart_validation  USING    fp_s_vkorg TYPE ty_t_s_vkorg
                                              fp_s_vtweg TYPE ty_t_s_vtweg
                                              fp_p_spart TYPE spart. " Division
  DATA: lv_sales_org TYPE vkorg. "Division

  SELECT SINGLE vkorg           "Sales Organisation
     FROM tvta                  "Sales Document: Header Data
     INTO lv_sales_org
     WHERE vkorg IN fp_s_vkorg
     AND   vtweg IN fp_s_vtweg
     AND   spart EQ fp_p_spart. "#EC WARNOK    "fp_p_spart
  IF sy-subrc NE 0.
    MESSAGE e000 WITH 'Invalid Sales Area'(075) .
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_VKORG_VTWEG_SPART_VALIDATION
