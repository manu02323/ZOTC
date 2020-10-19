*&---------------------------------------------------------------------*
*&  Include           /SAPSLL/CUS_INV_CREATE_PRO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include  ZOTC_CUS_INV_CREATE_PRO
*&
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTC_CUS_INV_CREATE_PRO                                *
* TITLE      :  OTC_EDD_0414_Proforma Shipment                         *
* DEVELOPER  :  Manoj thatha                                           *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_EDD_0414                                           *
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
*&---------------------------------------------------------------------*
INITIALIZATION.

  PERFORM fkart_restrict CHANGING gt_values.

  DESCRIBE TABLE gt_values LINES gv_lines.
  IF gv_lines = 1.
    READ TABLE gt_values INTO gs_values INDEX 1.
    MOVE gs_values-key TO p_fkart.
  ENDIF. " IF gv_lines = 1

*-- Default Anzeigevariante ermitteln
  PERFORM alv_variant_default_get USING    sy-repid
                                           gc_variant_handle-h01
                                  CHANGING p_dvari
                                           gs_variant.

*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
*Get EMI entries
  PERFORM f_get_emi_entries CHANGING i_enh_status.
* AT-SELECTION-SCREEN OUTPUT
AT SELECTION-SCREEN OUTPUT.
*Modify the screen based on User action.
  PERFORM f_modify_screen.
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632

*-- Anzeigevariante - gueltiger Wert
AT SELECTION-SCREEN ON p_dvari.

  IF NOT p_dvari IS INITIAL.
    PERFORM alv_variant_existence_check USING sy-repid
                                              gc_variant_handle-h01
                                              p_dvari.
  ENDIF. " IF NOT p_dvari IS INITIAL


*-- Anzeigevariante - Wertehilfe
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_dvari.
  PERFORM alv_variant_f4 CHANGING p_dvari
                                  gs_variant.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_tknum-low.
  CALL FUNCTION 'SD_F4_EXTENDED'
    EXPORTING
      mode   = 'HELP'
    EXCEPTIONS
      OTHERS = 0.

  GET PARAMETER ID 'TNR' FIELD s_tknum-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_tknum-high.
  CALL FUNCTION 'SD_F4_EXTENDED'
    EXPORTING
      mode   = 'HELP'
    EXCEPTIONS
      OTHERS = 0.

  GET PARAMETER ID 'TNR' FIELD s_tknum-high.

START-OF-SELECTION.

*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
  IF p_slsbom IS INITIAL.
* If the Billing type is not entered then display message
    IF p_fkart IS INITIAL.
      MESSAGE i000(zotc_msg) WITH text-001. "Fill out all required entry fields
      LEAVE LIST-PROCESSING.
    ENDIF. " IF p_fkart IS INITIAL
  ENDIF. " IF p_slsbom IS INITIAL
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632



  PERFORM select_data USING    p_fkart
                               p_kzabe
                               p_kzgbe
                               s_vbeln[]
*Begin of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect#7847 by U033632
*                              p_dtype
*End of delete for D3_OTC_EDD_0414 SCTASK0753994/Defect#7847 by U033632
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect#7847 by U033632
                               s_lfart[] "Delivery type
*End of insert for D3_OTC_EDD_0414 SCTASK0753994/Defect#7847 by U033632
                               s_vkorg[]
                               s_vstel[]
                               s_vsbed[]
                               p_inco1
                               s_grkor[]
                               s_wadat[]
                               s_agmdat[]
                               s_kunnr[]
                               s_land[]
                               s_spedl[]
                               s_tknum[]
                               s_route[]
                               s_vsart[]
                               s_spedt[]
                               s_lstel[]
                               s_lgtor[]
*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
                               s_erdat[] " Creation date
                               p_slsbom  " Proforma CI for Sales BOM
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
                      CHANGING gt_cus_inv
                               gv_rcode.

  IF gv_rcode = 4 AND sy-batch IS INITIAL.
    gv_repid = sy-repid.
    CALL FUNCTION 'RS_REFRESH_FROM_SELECTOPTIONS'
      EXPORTING
        curr_report     = gv_repid
      TABLES
        selection_table = gt_selection_table
      EXCEPTIONS
        not_found       = 01
        no_report       = 02.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF. " IF sy-subrc <> 0

    SUBMIT (gv_repid)
            WITH SELECTION-TABLE gt_selection_table
            VIA SELECTION-SCREEN.
  ENDIF. " IF gv_rcode = 4 AND sy-batch IS INITIAL


  IF sy-batch IS INITIAL.
*-- Aufbereitung der Struktur zur Anzeige
    PERFORM cus_inv_iface_build USING    gt_cus_inv
                                CHANGING gt_cus_inv_disp
                                         gt_cus_inv_all.

*-- Anzeige des Ergebnis im ALV
    MOVE sy-repid TO gv_repid.
    PERFORM cus_inv_display USING    gt_cus_inv_disp
                                     gt_cus_inv_all
                                     p_fkart
                                     p_fkdat
                                     gv_repid
                                     gc_variant_handle-h01
                                     p_dvari.
  ELSE. " ELSE -> IF sy-batch IS INITIAL
*-- Hintergrundverarbeitung
    IF p_noblk EQ gc_true.
*-- Bei einer gesperrten Position wird der komplette Beleg
*-- nicht fakturiert
      gt_cus_inv_del = gt_cus_inv.
      LOOP AT gt_cus_inv_del INTO gs_cus_inv
          WHERE flblk EQ gc_true.
        DELETE gt_cus_inv WHERE vbeln = gs_cus_inv-vbeln.
      ENDLOOP. " LOOP AT gt_cus_inv_del INTO gs_cus_inv
    ENDIF. " IF p_noblk EQ gc_true

    PERFORM cus_inv_background_proc USING gt_cus_inv
                                          p_fkart
                                          p_fkdat.

  ENDIF. " IF sy-batch IS INITIAL
