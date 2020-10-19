*&---------------------------------------------------------------------*
*& Include  ZOTC_CUS_INV_CREATE_FOR
*&
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTC_CUS_INV_CREATE_PRO                                *
* TITLE      :  OTC_EDD_0414_Proforma Shipment                         *
* DEVELOPER  :  Manoj thatha                                           *
* OBJECT TYPE:  Include Program                                        *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_EDD_0414                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: Proforma Shipment                                       *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER     TRANSPORT  DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 16-Aug-2018  MTHATHA  E1DK937760 INITIAL DEVELOPMENT                 *
* 19-Nov-2018  U033632  E1DK939349 SCTASK0753994:1.Code added to create*
*                                  proforma invoice for ZDF8 billing   *
*                                  type                                *
*                                  2. Added Creation date and Proforma *
*                                  CI for Sales BOM on selection screen*
*17-Dec-2018 U033632    E1DK939349 Defect#7847/SCTASK0753994:1. Removed*
*                                  EXPKZ check from selection of LIKP  *
*                                  table.                              *
*                                  2.Fixed issue of duplicate invoices *
*                                  3.Changed the text Proforma CI for  *
*                                  Sales BOM"  to "Customer Proforma   *
*                                  for HU Level CI" on sel screen      *
*                                  4.Changed delivery type to multiple *
*                                   selection                          *
*24-Jul-2019 U033632    E2DK925497 Defect#9943/INC0487265-02-Deliveries*
*                                   with packing status EQUAL to "C"   *
*                                   should be record in job log with   *
*                                   proforma # -delivery processed     *
*                                    successfully                      *
*&---------------------------------------------------------------------*
*&      Form  fkart_restrict
*&---------------------------------------------------------------------*
*       Faktura-Arten eingrenzen
*----------------------------------------------------------------------*
FORM fkart_restrict  CHANGING ct_values  TYPE vrm_values.
  DATA: ls_value       TYPE vrm_value.
  DATA: lt_tvfk        TYPE /sapsll/tvfk_t.
  DATA: lt_tvfkt       TYPE /sapsll/tvfkt_t.
  DATA: ls_tvfk        TYPE tvfk. " Billing: Document Types
  DATA: ls_tvfkt       TYPE tvfkt. " Billing: Document Types: Texts
*-- Überleitungsrelevante Proforma-Faktura-Arten nachlesen
  CALL FUNCTION '/SAPSLL/PROFORMA_DTYPES_GET'
    IMPORTING
      et_tvfk          = lt_tvfk
      et_tvfkt         = lt_tvfkt
    EXCEPTIONS
      no_entries_found = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF. " IF sy-subrc <> 0
  LOOP AT lt_tvfk INTO ls_tvfk.
    ls_value-key  = ls_tvfk-fkart.
    READ TABLE lt_tvfkt
      INTO ls_tvfkt
      WITH KEY fkart = ls_tvfk-fkart.
    ls_value-text = ls_tvfkt-vtext.
    APPEND ls_value TO ct_values.
  ENDLOOP. " LOOP AT lt_tvfk INTO ls_tvfk
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'P_FKART'
      values          = ct_values
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.
ENDFORM. " fkart_restrict
*&---------------------------------------------------------------------*
*&      Form  select_data
*&---------------------------------------------------------------------*
*       Selektieren der Daten für die Sendungsbildung
*----------------------------------------------------------------------*
FORM select_data  USING    iv_fkart   TYPE fkart " Billing Type
                           iv_kzabe   TYPE kzabe " Indicator for the means of transport at departure
                           iv_kzgbe   TYPE kzgbe " Indicator for means of transport crossing the border
                           ir_vbeln   TYPE /sapsll/vbeln_r3_r_t
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect#7847 by U033632
*                          iv_dtype   TYPE lfart
*End of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect#7847 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect#7847 by U033632
                           fp_s_lfart TYPE /isdfps/rg_t_lfart " Delivery type
*End of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect#7847 by U033632
                           ir_vkorg   TYPE /sapsll/vkorg_r3_r_t
                           ir_vstel   TYPE /sapsll/vstel_r3_r_t
                           ir_vsbed   TYPE /sapsll/vsbed_r_t
                           iv_inco1   TYPE inco1 " Incoterms (Part 1)
                           ir_grkor   TYPE /sapsll/grkor_r_t
                           ir_wadat   TYPE /sapsll/wadat_r_t
                           ir_agmdat  TYPE /sapsll/wadat_r_t
                           ir_kunnr   TYPE /sapsll/kunnr_r_t
                           ir_land    TYPE /sapsll/land1_r3_r_t
                           ir_spedl   TYPE /sapsll/lifnr_r3_r_t
                           ir_tknum   TYPE /sapsll/tknum_r3_r_t
                           ir_route   TYPE /sapsll/route_r3_r_t
                           ir_vsart   TYPE /sapsll/vsarttr_r3_r_t
                           ir_spedt   TYPE /sapsll/lifnr_r3_r_t
                           ir_lstel   TYPE /sapsll/lstel_r3_r_t
                           ir_lgtor   TYPE /sapsll/lgtor_r3_r_t
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
                           fp_s_erdat   TYPE /sapsll/erdat_r3_r_t " Date on Which Record Was Created
                           fp_p_slsbom TYPE flag                  " General Flag
* End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
                  CHANGING ct_cus_inv TYPE /sapsll/cus_inv_r3_t
                           cv_rcode   TYPE sy-subrc. " Return Value of ABAP Statements
  DATA: ls_crit_cus_inv TYPE /sapsll/cus_inv_crit_r3_s. " GTS: Shipment Consolidation Selection Criteria
*---- Daten in Struktur der Selektionskriterien übertragen
  ls_crit_cus_inv-fkart = iv_fkart.
  ls_crit_cus_inv-kzabe = iv_kzabe.
  ls_crit_cus_inv-kzgbe = iv_kzgbe.
  ls_crit_cus_inv-vbeln = ir_vbeln.
  ls_crit_cus_inv-vkorg = ir_vkorg.
  ls_crit_cus_inv-vstel = ir_vstel.
  ls_crit_cus_inv-vsbed = ir_vsbed.
  ls_crit_cus_inv-inco1 = iv_inco1.
  ls_crit_cus_inv-grkor = ir_grkor.
  ls_crit_cus_inv-wadat = ir_wadat.
  ls_crit_cus_inv-kunnr = ir_kunnr.
  ls_crit_cus_inv-land  = ir_land.
  ls_crit_cus_inv-spedl = ir_spedl.
  ls_crit_cus_inv-tknum = ir_tknum.
  ls_crit_cus_inv-route = ir_route.
  ls_crit_cus_inv-vsart = ir_vsart.
  ls_crit_cus_inv-spedt = ir_spedt.
  ls_crit_cus_inv-lstel = ir_lstel.
  ls_crit_cus_inv-lgtor = ir_lgtor.
*---- Datenselektion
  CALL FUNCTION 'ZOTC_SHIPMENT_DATA_SELECT'
    EXPORTING
      is_crit    = ls_crit_cus_inv
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect#7847 by U033632
*     im_lfart   = iv_dtype
*End of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect#7847 by U033632
* *Begin of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect#7847 by U033632
      im_lfart   = fp_s_lfart " Delivery type
*End of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect#7847 by U033632
      im_agmdat  = ir_agmdat
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
      im_erdat   = fp_s_erdat
      im_zdf8    = fp_p_slsbom
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
    IMPORTING
      et_cus_inv = ct_cus_inv
    EXCEPTIONS
      no_data    = 1
      OTHERS     = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    cv_rcode = 4.
    RETURN.
  ENDIF. " IF sy-subrc <> 0
*---- Anreicherung um GTS-Informationen:
*----- genehmigungspflichtige Ware
*----- Position im GTS gesperrt
  CALL FUNCTION '/SAPSLL/SHIPMENT_CON_DATA_GET'
    CHANGING
      ct_cus_inv = ct_cus_inv.
ENDFORM. " select_data
*&---------------------------------------------------------------------*
*&      Form  cus_inv_iface_build
*&---------------------------------------------------------------------*
*       Aufbau der Anzeige-Struktur für Sendungsbildung
*----------------------------------------------------------------------*
FORM cus_inv_iface_build
      USING    it_cus_inv      TYPE /sapsll/cus_inv_r3_t
      CHANGING ct_cus_inv_disp TYPE /sapsll/cus_inv_disp_r3_t
               ct_cus_inv_all  TYPE /sapsll/cus_inv_disp_r3_t.
  CALL FUNCTION '/SAPSLL/CUS_INV_IFACE_BUILD'
    EXPORTING
      it_cus_inv      = it_cus_inv
    IMPORTING
      et_cus_inv_disp = ct_cus_inv_disp
      et_cus_inv_all  = ct_cus_inv_all.
ENDFORM. " cus_inv_iface_build
*&---------------------------------------------------------------------*
*&      Form  cus_inv_display
*&---------------------------------------------------------------------*
*       Anzeige des Ergebnis
*----------------------------------------------------------------------*
FORM cus_inv_display
      USING it_cus_inv_disp    TYPE /sapsll/cus_inv_disp_r3_t
            it_cus_inv_all     TYPE /sapsll/cus_inv_disp_r3_t
            iv_fkart           TYPE fkart      " Billing Type
            iv_fkdat           TYPE fkdat      " Billing date for billing index and printout
            iv_report          TYPE repid      " ABAP Program Name
            iv_dvariant_handle TYPE slis_handl " Mgt. ID for repeated calls from the same program
            iv_dvariant        TYPE slis_vari. " Layout
  CALL FUNCTION '/SAPSLL/CUS_INV_DISPLAY'
    EXPORTING
      it_cus_inv_disp    = it_cus_inv_disp
      it_cus_inv_all     = it_cus_inv_all
      iv_fkart           = iv_fkart
      iv_fkdat           = iv_fkdat
      iv_report          = iv_report
      iv_dvariant_handle = iv_dvariant_handle
      iv_dvariant        = iv_dvariant.
ENDFORM. " cus_inv_display
*&---------------------------------------------------------------------*
*&      Form  ALV_VARIANT_DEFAULT_GET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM alv_variant_default_get  USING    iv_repid   TYPE sy-repid
                                       iv_handle  TYPE slis_handl  " Mgt. ID for repeated calls from the same program
                              CHANGING cv_dvari   TYPE slis_vari   " Layout
                                       cs_variant TYPE disvariant. " Layout (External Use)
  CLEAR cs_variant.
  cs_variant-report = iv_repid.
  cs_variant-handle = iv_handle.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = 'A'
    CHANGING
      cs_variant = cs_variant
    EXCEPTIONS
      not_found  = 4.
  IF sy-subrc = 0.
    cv_dvari = cs_variant-variant.
  ENDIF. " IF sy-subrc = 0
ENDFORM. " ALV_VARIANT_DEFAULT_GET
*&---------------------------------------------------------------------*
*&      Form  alv_variant_f4
*&---------------------------------------------------------------------*
*       F4 Anzeigevariante
*----------------------------------------------------------------------*
FORM alv_variant_f4 CHANGING cv_variant
                             cs_variant TYPE disvariant. " Layout (External Use)
  DATA lv_exit TYPE c. " Exit of type Character
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = cs_variant
      i_save     = 'A'
    IMPORTING
      e_exit     = lv_exit
      es_variant = cs_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 2.
*    message s065(/sapsll/legal_prn).
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE. " ELSE -> IF sy-subrc = 2
    IF lv_exit IS INITIAL.
      cv_variant = cs_variant-variant.
    ENDIF. " IF lv_exit IS INITIAL
  ENDIF. " IF sy-subrc = 2
ENDFORM. " alv_variant_f4
*&---------------------------------------------------------------------*
*&      Form  alv_variant_existence_check
*&---------------------------------------------------------------------*
*       Anzeigevariante auf Existenz pruefen
*----------------------------------------------------------------------*
FORM alv_variant_existence_check  USING  iv_repid  TYPE sy-repid
                                         iv_handle TYPE slis_handl " Mgt. ID for repeated calls from the same program
                                         iv_dvari  TYPE slis_vari. " Layout
  DATA: ls_variant TYPE disvariant. " Layout (External Use)
  ls_variant-report  = iv_repid.
  ls_variant-handle  = iv_handle.
  ls_variant-variant = iv_dvari.
  CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
    EXPORTING
      i_save        = 'A'
    CHANGING
      cs_variant    = ls_variant
    EXCEPTIONS
      wrong_input   = 1
      not_found     = 2
      program_error = 3
      OTHERS        = 4.
  IF sy-subrc = 2.
    MESSAGE e222(/sapsll/pluginr3) WITH iv_dvari. " Layout &1 does not exist; check your entries
  ENDIF. " IF sy-subrc = 2
ENDFORM. " alv_variant_existence_check
*&---------------------------------------------------------------------*
*&      Form  cus_inv_background_proc
*&---------------------------------------------------------------------*
*       Hintergrundverarbeitung für Sendungsbildung
*----------------------------------------------------------------------*
FORM cus_inv_background_proc
      USING it_cus_inv  TYPE /sapsll/cus_inv_r3_t
            iv_fkart    TYPE fkart  " Billing Type
            iv_fkdat    TYPE fkdat. " Billing date for billing index and printout
  DATA: lt_vbfs        TYPE tab_vbfs.
  DATA: lt_vbss        TYPE tab_vbss.
  DATA: lt_cus_inv_log TYPE /sapsll/cus_inv_disp_bg_r3_t.
  DATA: lwa_msg      TYPE /sapsll/cus_inv_disp_bg_r3_s,
*Begin of insert for D3_OTC_EDD_0414 INC0487265-02/Defect#9943 by U033632
        lt_job_log   TYPE /sapsll/cus_inv_disp_bg_r3_t, "Internal table for proforma nad delivery no
        lwa_job_log  TYPE /sapsll/cus_inv_disp_bg_r3_s, " Work area for Proforma and delivery no
        lv_log_text1 TYPE string.                       "Text for message to be displayed
  CONSTANTS:lc_sym   TYPE char1 VALUE '-'.              "Special symbol
*End of insert for D3_OTC_EDD_0414 INC0487265-02/Defect#9943 by U033632
  IF it_cus_inv[] IS NOT INITIAL.

*---- Aus den selektierten Daten Fakturen erzeugen
    CALL FUNCTION '/SAPSLL/SHIPMENT_INV_CREATE'
      EXPORTING
        it_cus_inv = it_cus_inv
        iv_fkart   = iv_fkart
        iv_fkdat   = iv_fkdat
      IMPORTING
        et_vbfs    = lt_vbfs
        et_vbss    = lt_vbss.
*-- Aufbereitung der Nachrichten als Ausgabetabelle
    CALL FUNCTION '/SAPSLL/CUS_INV_LOG_TABL_BUILD'
      EXPORTING
        it_vbfs        = lt_vbfs
        it_vbss        = lt_vbss
        it_cus_inv     = it_cus_inv
      IMPORTING
        et_cus_inv_log = lt_cus_inv_log.
*-- Ausgabe des Protokolls als ALV im Spool
    CALL FUNCTION '/SAPSLL/CUS_INV_LOG_DISPLAY'
      EXPORTING
        it_cus_inv_log = lt_cus_inv_log
        iv_fkart       = iv_fkart.
*Begin of insert for D3_OTC_EDD_0414 INC0487265-02/Defect#9943 by U033632
    REFRESH:lt_job_log.
    lt_job_log[] = lt_cus_inv_log[].
*Keeping record of the Proforma Invoice no and respective delivery only
    DELETE lt_job_log WHERE vbeln_vf IS INITIAL OR vbeln_vl IS INITIAL.
    DELETE ADJACENT DUPLICATES FROM lt_job_log COMPARING vbeln_vf vbeln_vl.
*Populating  job log with message "proforma # - delivery processed successfully" for those deliveries with status EQUAL to "C"
    LOOP AT lt_job_log INTO lwa_job_log.
      CONCATENATE text-004 lwa_job_log-vbeln_vf lc_sym text-003 lwa_job_log-vbeln_vl INTO lv_log_text1 SEPARATED BY space.
      MESSAGE s102 WITH lv_log_text1 TEXT-002.
      CLEAR:lwa_job_log,
            lv_log_text1.
    ENDLOOP.
*End of insert for D3_OTC_EDD_0414 INC0487265-02/Defect#9943 by U033632
  ENDIF. " IF it_cus_inv[] IS NOT INITIAL
*-- Schlussmeldung senden
  MESSAGE s221.
ENDFORM. " cus_inv_background_proc
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       Modify Screen
*----------------------------------------------------------------------*

FORM f_modify_screen .

*Local Constants
  CONSTANTS: lc_ok    TYPE char1        VALUE 'X',     "For X
             lc_fkart TYPE z_criteria   VALUE 'FKART'. " Enh. Criteria
* Local Data
  DATA: lwa_enh_status TYPE zdev_enh_status, " Enhancement Status
        lv_fkart       TYPE fkart,                 " Billing Type
        lv_vtext       TYPE bezei20,               " Description
        lwa_bill_type  TYPE vrm_value.        "Work area for VRM set values

  IF i_enh_status[] IS NOT INITIAL.
    READ TABLE i_enh_status INTO lwa_enh_status
          WITH KEY criteria = lc_fkart.
    IF sy-subrc EQ 0.
      SELECT SINGLE fkart vtext
      FROM tvfkt INTO (lv_fkart, lv_vtext)
      WHERE spras = sy-langu AND
            fkart = lwa_enh_status-sel_low.
    ENDIF. " IF sy-subrc EQ 0
*If Proforma CI for Sales BOM is checked
    IF p_slsbom EQ lc_ok.
      lwa_bill_type-key = lv_fkart.
      lwa_bill_type-text = lv_vtext.
      APPEND lwa_bill_type TO gt_values.
      CLEAR: lwa_bill_type.
      CALL FUNCTION 'VRM_SET_VALUES'
        EXPORTING
          id              = 'P_FKART'
          values          = gt_values
        EXCEPTIONS
          id_illegal_name = 1
          OTHERS          = 2.
      MODIFY SCREEN.
    ELSE. " ELSE -> IF p_slsbom EQ lc_ok
      DELETE gt_values WHERE key = lv_fkart.
      IF p_fkart = lv_fkart.
        CLEAR: p_fkart.
      ENDIF. " IF p_fkart = lv_fkart
      CALL FUNCTION 'VRM_SET_VALUES'
        EXPORTING
          id              = 'P_FKART'
          values          = gt_values
        EXCEPTIONS
          id_illegal_name = 1
          OTHERS          = 2.
      MODIFY SCREEN.
    ENDIF. " IF p_slsbom EQ lc_ok
  ENDIF. " IF i_enh_status[] IS NOT INITIAL
ENDFORM. " F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  F_GET_EMI_ENTRIES
*&---------------------------------------------------------------------*
*       Get EMI Entries
*----------------------------------------------------------------------*
*      <--P_I_ENH_STATUS  EMI table
*----------------------------------------------------------------------*
FORM f_get_emi_entries  CHANGING fp_i_enh_status TYPE ty_t_emi.
  CONSTANTS lc_enhancement_no TYPE z_enhancement VALUE 'OTC_EDD_0414'. " Enhancement No.

  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enhancement_no
    TABLES
      tt_enh_status     = fp_i_enh_status.

  DELETE fp_i_enh_status WHERE active = abap_false.
ENDFORM. " F_GET_EMI_ENTRIES
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
