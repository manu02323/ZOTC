*&---------------------------------------------------------------------*
*&  Include           ZOTCN0093B_AUTO_POD_CONF_F01
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCR0093B_AUTO_POD_CONF_F01                          *
* TITLE      :  OTC_EDD_0093_AUTOMATE POD CONFIRMATION                 *
* DEVELOPER  :  Sneha Mukherjee                                        *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_EDD_0093_AUTOMATE POD CONFIRMATION                 *
*----------------------------------------------------------------------*
* DESCRIPTION: A program which will run in background through batch job*
*              to identify POD relevant deliveries with zero quality and
*              run VLPOD transaction for those deliveries.             *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 02-Dec-13  SMUKHER   E1DK912327  INITIAL DEVELOPMENT                 *
* 08-Jan-14  SMUKHER   E1DK912327  Filtering logic added and 'Confirm' *
*                                  button on Output display            *
* 24-Feb-14  SMUKHER   E1DK912327  CR#1229:Included logic to fetch All *
*                                  Delivery documents in the report,New*
*                                  output parameters included as well,
*                                  and Updated functionality to update *
*                                  all deliveries as a radio button    *
* 07-Mar-14  SMUKHER  E1DK912327   HPQC Defect 1229 - Addition of 'Ship*
*                                  -ping point description' to the     *
*                                  ALV output display.                 *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_LIKP
*&---------------------------------------------------------------------*
*       Retrieve data from likp
*----------------------------------------------------------------------*
*      <--FP_I_LIKP changing  internal table i_likp                    *
*----------------------------------------------------------------------*
FORM f_retrieve_from_likp  CHANGING fp_i_likp TYPE ty_t_likp.

  SELECT vbeln                "Delivery
         ernam                "Name of Person who Created the Object
         erzet                "Entry time
         erdat                "Date on Which Record Was Created
         vstel                "Shipping Point/Receiving Point
         vkorg                "Sales Organization
         lfart                "Delivery Type
         inco1                "Incoterms (Part 1)
         vsbed                "Shipping Conditions
         kunnr                "Ship-to party
         kunag                "Sold-to party
         wadat_ist            "Actual Movement Date
         vlstk    "Distribution Status (Decentralized Warehouse Processing)
         podat                "Date(Proof Of Delivery)
         potim                "Confirmation Time
  FROM likp INTO TABLE fp_i_likp
  WHERE inco1 IN s_inco1
  AND   vsbed IN s_vsbed
  AND   erdat IN s_erdat  .

  IF sy-subrc IS INITIAL.

    SORT fp_i_likp BY vbeln.
  ELSE.
    "Data not found.
    MESSAGE i134.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.                    " F_RETRIEVE_FROM_LIKP
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_LIPS
*&---------------------------------------------------------------------*
*        Retrieve data from lips
*----------------------------------------------------------------------*
*      -->fp_i_likp using internal table i_likp
*      <--fp_i_lips changing  internal table i_lips
*----------------------------------------------------------------------*
FORM f_retrieve_from_lips  USING    fp_i_likp TYPE ty_t_likp
                           CHANGING fp_i_lips TYPE ty_t_lips.

  DATA :  li_lips   TYPE ty_t_lips,       " Local internal table type LIPS
          li_r_vbeln  TYPE RANGE OF vbeln INITIAL SIZE 0,  " Range table
          lwa_vbeln LIKE LINE OF li_r_vbeln." work area

  CONSTANTS: lc_sign TYPE char1 VALUE 'I', " Integer
             lc_option TYPE char2 VALUE 'EQ'. " Equal to

  FIELD-SYMBOLS: <lfs_lips> TYPE ty_lips.

  IF fp_i_likp IS NOT INITIAL.

    SELECT vbeln              "Delivery
           posnr              "Delivery Item
           lfimg              "Actual quantity delivered (in sales units)
           kzpod              "POD indicator (relevance, verification, confirmation)
           FROM lips INTO TABLE fp_i_lips
           FOR ALL ENTRIES IN fp_i_likp
           WHERE vbeln = fp_i_likp-vbeln.

    IF sy-subrc IS INITIAL.
      SORT fp_i_lips BY vbeln.

      li_lips = fp_i_lips.             " 8-Jan-2014
* Here we are keeping only those items which have non-zero delivered quantity
      DELETE li_lips WHERE lfimg IS INITIAL.
      DELETE ADJACENT DUPLICATES FROM li_lips COMPARING vbeln.
* We assign all the delivery numbers having non-zero delivered quantity to range table.
      LOOP AT li_lips  ASSIGNING <lfs_lips>.
        lwa_vbeln-sign = lc_sign.
        lwa_vbeln-option = lc_option.
        lwa_vbeln-low = <lfs_lips>-vbeln.
        APPEND lwa_vbeln TO li_r_vbeln.
      ENDLOOP.

**&& BOC for CR#1229
* We delete those delivery numbers after comparing to the range table
* only if zero deliveries radiobutton is selected.      .
      IF rb_dev = abap_true.
        DELETE fp_i_lips WHERE vbeln IN li_r_vbeln.
      ENDIF.
**&& EOC for CR#1229
    ENDIF.
  ENDIF.
ENDFORM.                    " F_RETRIEVE_FROM_LIPS
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_VBUP
*&---------------------------------------------------------------------*
*    retrieve from VBUP table
*----------------------------------------------------------------------*
*      -->FP_I_LIPS  internal table for LIPS
*      <--FP_I_VBUP  internal table for VBUP
*----------------------------------------------------------------------*
FORM f_retrieve_from_vbup  USING    fp_i_vbuk TYPE ty_t_vbuk
                           CHANGING fp_i_vbup TYPE ty_t_vbup.

  IF fp_i_vbuk IS NOT INITIAL.

    SELECT vbeln              "Delivery
           posnr              "Delivery Item
           wbsta              "Goods movement status
           gbsta              "Overall processing status of the SD document item
           pdsta              "POD status on item level
           FROM vbup INTO TABLE fp_i_vbup
           FOR ALL ENTRIES IN fp_i_vbuk
           WHERE vbeln = fp_i_vbuk-vbeln.

    IF sy-subrc IS INITIAL.
      SORT fp_i_vbup BY vbeln.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_RETRIEVE_FROM_VBUP

*&---------------------------------------------------------------------*
*&      Form  F_FINAL_TABLE_POPULATION
*&---------------------------------------------------------------------*
*       Final table population
*----------------------------------------------------------------------*
*      -->FP_I_LIKP   internal table for LIKP
*      -->FP_I_LIPS   internal table for LIPS
*      -->FP_I_VBUP   internal table for VBUP
*      <--FP_I_FINAL  internal table for FINAL
*----------------------------------------------------------------------*
FORM f_final_table_population  USING    fp_i_likp TYPE ty_t_likp
                                        fp_i_lips TYPE ty_t_lips
                                        fp_i_vbup TYPE ty_t_vbup
**&& --  BOC for CR#1229
                                        fp_i_tinct TYPE ty_t_tinct
                                        fp_i_tvsbt TYPE ty_t_tvsbt
**&& --  EOC for CR#1229
**&& -- BOC : HPQC Defect 1229: SMUKHER :07-MAR-14
                                        fp_i_tvstt TYPE ty_t_tvstt
**&& -- EOC : HPQC Defect 1229: SMUKHER :07-MAR-14
                               CHANGING fp_i_final TYPE ty_t_final.

* Field symbol declaration
  FIELD-SYMBOLS : <lfs_likp> TYPE ty_likp, "Field symbol for LIKP
                  <lfs_lips> TYPE ty_lips, "Field symbol for LIPS
                  <lfs_vbup> TYPE ty_vbup. "Field symbol for VBUP

  CONSTANTS: lc_pdsta TYPE pdsta VALUE 'C', " POD staus as'C'
             lc_wbsta TYPE wbsta VALUE 'C'. " Goods Movement Status as 'C'


  DATA: lwa_final TYPE ty_final.            " work area for final

  LOOP AT fp_i_likp ASSIGNING <lfs_likp>.

    READ TABLE fp_i_lips ASSIGNING <lfs_lips>
                         WITH KEY vbeln = <lfs_likp>-vbeln
                         BINARY SEARCH.
*&&-- Check if LIPS-KZPOD <> SPACE
    IF sy-subrc IS INITIAL AND <lfs_lips>-kzpod NE space.
      READ TABLE fp_i_vbup ASSIGNING <lfs_vbup>
                           WITH KEY vbeln = <lfs_lips>-vbeln
                           BINARY SEARCH.
*&&-- Check if VBUP-PDSTA <> C
      IF sy-subrc IS INITIAL AND <lfs_vbup>-pdsta <> lc_pdsta  .
*&&-- Check if VBUP_WBSTA = C.
        IF <lfs_vbup>-wbsta = lc_wbsta.
*&&-- Build ALV final table for display
          PERFORM f_data_population USING <lfs_likp>
                                          fp_i_tinct
                                          fp_i_tvsbt
**&& -- BOC : HPQC Defect 1229 : SMUKHER : 07-MAR-14
                                          fp_i_tvstt
**&& -- EOC : HPQC Defect 1229 : SMUKHER : 07-MAR-14
                                   CHANGING lwa_final.
          APPEND lwa_final TO fp_i_final.
          CLEAR: lwa_final.
        ELSE.
*&&-- IGNORE the delivery
          CONTINUE.
        ENDIF.  "VBUP-WBSTA = C
      ENDIF.  "READ VBUP
    ENDIF.  "READ LIPS
  ENDLOOP.  "LOOP at LIKP

ENDFORM.                    " F_FINAL_TABLE_POPULATION
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_FIELDCAT
*&---------------------------------------------------------------------*
*     prepare fieldcatlog
*----------------------------------------------------------------------*
*    <--FP_I_FIELDCAT  changing internal table i_fieldcat
*----------------------------------------------------------------------*
FORM f_prepare_fieldcat  CHANGING fp_i_fieldcat TYPE slis_t_fieldcat_alv.
* Local data decleration.
  DATA :  lwa_fieldcat TYPE slis_fieldcat_alv,  "Fieldcatalog Workarea
          lv_pos TYPE i.                        "position of field

*Constants Declaration
  CONSTANTS: lc_left_adjst  TYPE char1 VALUE 'L',          "(L)eft.
             lc_cb_sel TYPE slis_fieldname VALUE 'CB_SEL', "Checkbox
             lc_vbeln TYPE slis_fieldname VALUE 'VBELN',   "Delivery Number
             lc_ernam TYPE slis_fieldname VALUE 'ERNAM',   "Created By
             lc_erdat TYPE slis_fieldname VALUE 'ERDAT',   "Created On
             lc_erzet TYPE slis_fieldname VALUE 'ERZET',   "Created At(Time)
             lc_lfart TYPE slis_fieldname VALUE 'LFART',   "Delivery Type
             lc_vkorg TYPE slis_fieldname VALUE 'VKORG',   "Sales Organization
             lc_vstel TYPE slis_fieldname VALUE 'VSTEL',   "Shipping Point
**&& -- BOC : HPQC Defect 1229 : SMUKHER : 07-MAR-14
             lc_vtext1 TYPE slis_fieldname VALUE 'VTEXT1', "Shipping Point Description
**&& -- EOC : HPQC Defect 1229 : SMUKHER : 07-MAR-14
             lc_kunnr TYPE slis_fieldname VALUE 'KUNNR',   "Ship-to-party
             lc_kunag TYPE slis_fieldname VALUE 'KUNAG',   "Sold-to-party
**&& -- BOC for CR#1229
             lc_vsbed TYPE slis_fieldname VALUE 'VSBED',   "Shipping Conditions
             lc_vtext TYPE slis_fieldname VALUE 'VTEXT',   "Shipping Condition Description
             lc_inco1 TYPE slis_fieldname VALUE 'INCO1',   "Incoterms
             lc_bezei TYPE slis_fieldname VALUE 'BEZEI',   "Incoterms Description
             lc_wadat_ist TYPE slis_fieldname VALUE 'WADAT_IST'.   "Actual Movement Date
**&& -- EOC for CR#1229



  lwa_fieldcat-col_pos = lv_pos.
  lwa_fieldcat-fieldname = lc_cb_sel.
  lwa_fieldcat-seltext_l = 'Checkbox'(006).
  lwa_fieldcat-checkbox = abap_true.
  lwa_fieldcat-edit = abap_true.
  lwa_fieldcat-just = lc_left_adjst.
  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.

  lv_pos = lv_pos + 1.
  lwa_fieldcat-col_pos = lv_pos.
  lwa_fieldcat-fieldname = lc_vbeln.
  lwa_fieldcat-seltext_l = 'Delivery Number'(007).
  lwa_fieldcat-just = lc_left_adjst.
  lwa_fieldcat-hotspot = abap_true.
  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.

  lv_pos = lv_pos + 1.
  lwa_fieldcat-col_pos = lv_pos.
  lwa_fieldcat-fieldname = lc_ernam.
  lwa_fieldcat-seltext_l = 'Created By'(008).
  lwa_fieldcat-just = lc_left_adjst.
  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.

  lv_pos = lv_pos + 1.
  lwa_fieldcat-col_pos = lv_pos.
  lwa_fieldcat-fieldname = lc_erdat.
  lwa_fieldcat-seltext_l = 'Created On'(009).
  lwa_fieldcat-just = lc_left_adjst.
  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.

  lv_pos = lv_pos + 1.
  lwa_fieldcat-col_pos = lv_pos.
  lwa_fieldcat-fieldname = lc_erzet.
  lwa_fieldcat-seltext_l = 'Created On Time'(010).
  lwa_fieldcat-just = lc_left_adjst.
  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.

  lv_pos = lv_pos + 1.
  lwa_fieldcat-col_pos = lv_pos.
  lwa_fieldcat-fieldname = lc_lfart.
  lwa_fieldcat-seltext_l = 'Delivery Type'(011).
  lwa_fieldcat-just = lc_left_adjst.
  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.

  lv_pos = lv_pos + 1.
  lwa_fieldcat-col_pos = lv_pos.
  lwa_fieldcat-fieldname = lc_vkorg.
  lwa_fieldcat-seltext_l = 'Sales Organization'(012).
  lwa_fieldcat-just = lc_left_adjst.
  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.

  lv_pos = lv_pos + 1.
  lwa_fieldcat-col_pos = lv_pos.
  lwa_fieldcat-fieldname = lc_vstel.
  lwa_fieldcat-seltext_l = 'Shipping Point'(013).
  lwa_fieldcat-just = lc_left_adjst.
  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.

**&& -- BOC : HPQC Defect 1229: SMUKHER : 07-MAR-14
  lv_pos = lv_pos + 1.
  lwa_fieldcat-col_pos = lv_pos.
  lwa_fieldcat-fieldname = lc_vtext1.
  lwa_fieldcat-seltext_l = 'Shipping Point Description'(038).
  lwa_fieldcat-just = lc_left_adjst.
  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.
**&& -- EOC : HPQC Defect 1229: SMUKHER : 07-MAR-14

  lv_pos = lv_pos + 1.
  lwa_fieldcat-col_pos = lv_pos.
  lwa_fieldcat-fieldname = lc_kunnr.
  lwa_fieldcat-seltext_l = 'Ship-to-party'(014).
  lwa_fieldcat-just = lc_left_adjst.
  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.

  lv_pos = lv_pos + 1.
  lwa_fieldcat-col_pos = lv_pos.
  lwa_fieldcat-fieldname = lc_kunag.
  lwa_fieldcat-seltext_l = 'Sold-to-party'(015).
  lwa_fieldcat-just = lc_left_adjst.
**&& -- BOC for CR#1229
  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.

  lv_pos = lv_pos + 1.
  lwa_fieldcat-col_pos = lv_pos.
  lwa_fieldcat-fieldname = lc_vsbed.
  lwa_fieldcat-seltext_l = 'Shipping Conditions'(027).
  lwa_fieldcat-just = lc_left_adjst.
  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.

  lv_pos = lv_pos + 1.
  lwa_fieldcat-col_pos = lv_pos.
  lwa_fieldcat-fieldname = lc_vtext.
  lwa_fieldcat-seltext_l = 'Shipping Condition Description'(030).
  lwa_fieldcat-just = lc_left_adjst.
  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.

  lv_pos = lv_pos + 1.
  lwa_fieldcat-col_pos = lv_pos.
  lwa_fieldcat-fieldname = lc_inco1.
  lwa_fieldcat-seltext_l = 'Incoterms'(028).
  lwa_fieldcat-just = lc_left_adjst.
  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.

  lv_pos = lv_pos + 1.
  lwa_fieldcat-col_pos = lv_pos.
  lwa_fieldcat-fieldname = lc_bezei.
  lwa_fieldcat-seltext_l = 'Incoterms Description'(031).
  lwa_fieldcat-just = lc_left_adjst.
  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.


  lv_pos = lv_pos + 1.
  lwa_fieldcat-col_pos = lv_pos.
  lwa_fieldcat-fieldname = lc_wadat_ist.
  lwa_fieldcat-seltext_l = 'Actual Movement Date'(029).
  lwa_fieldcat-just = lc_left_adjst.

  APPEND lwa_fieldcat TO fp_i_fieldcat.
  CLEAR lwa_fieldcat.

**&& -- EOC for CR#1299

ENDFORM.                    " F_PREPARE_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_OUTPUT_DISPLAY
*&---------------------------------------------------------------------*
*       Display Alv output
*----------------------------------------------------------------------*
*      -->FP_I_FINAL    using  internal table i_final
*      -->fp_i_fieldcat usnig  internal table i_fieldcat
*----------------------------------------------------------------------*
FORM f_output_display  USING    fp_i_fieldcat TYPE slis_t_fieldcat_alv
                                fp_i_final TYPE ty_t_final.
* local data declaration.
  DATA : lwa_layo TYPE slis_layout_alv.                           " Layout for alv

* Constants declaration
  CONSTANTS:lc_callback_subroutine TYPE slis_formname
                               VALUE 'F_USER_COMMAND',               "F_USER_COMMAND
            lc_pf_status TYPE slis_formname VALUE 'F_SET_PF_STATUS'." PF-STATUS

  lwa_layo-zebra = abap_true.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid       " report id
      i_callback_pf_status_set = lc_pf_status   " for PF-STATUS
      i_callback_user_command  = lc_callback_subroutine " for User-Command
      is_layout                = lwa_layo       " for layout
      it_fieldcat              = fp_i_fieldcat  " field catalog
      i_save                   = gc_save        " save
    TABLES
      t_outtab                 = fp_i_final    " internal table
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
    MESSAGE e140.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.                    " F_OUTPUT_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  F_DATA_POPULATION
*&---------------------------------------------------------------------*
*       data population
*----------------------------------------------------------------------*
*      -->fP_<LFS_LIKP>  using field symbol <lfs_likp>
*      <--fP_LWA_FINAL   using work area lwa_final.
*----------------------------------------------------------------------*
FORM f_data_population  USING    fp_lfs_likp TYPE ty_likp
                                 fp_i_tinct TYPE ty_t_tinct
                                 fp_i_tvsbt TYPE ty_t_tvsbt
**&& -- BOC : HPQC Defect 1229: SMUKHER : 07-MAR-14
                                 fp_i_tvstt TYPE ty_t_tvstt
**&& -- EOC : HPQC Defect 1229: SMUKHER : 07-MAR-14
                      CHANGING fp_lwa_final TYPE ty_final.

  FIELD-SYMBOLS : <fp_lfs_tinct> TYPE ty_tinct,
                  <fp_lfs_tvsbt> TYPE ty_tvsbt,
**&& -- BOC : HPQC Defect 1229: SMUKHER : 07-MAR-14
                  <fp_lfs_tvstt> TYPE ty_tvstt.
**&& -- EOC : HPQC Defect 1229: SMUKHER : 07-MAR-14

  fp_lwa_final-vbeln =   fp_lfs_likp-vbeln.   "Delivery Number
  fp_lwa_final-ernam =   fp_lfs_likp-ernam.   "Created By
  fp_lwa_final-erdat =   fp_lfs_likp-erdat.   "Created On
  fp_lwa_final-erzet =   fp_lfs_likp-erzet.   "Created On time
  fp_lwa_final-lfart =   fp_lfs_likp-lfart.   "Delivery Type
  fp_lwa_final-vkorg =   fp_lfs_likp-vkorg.   "Sales Organization
  fp_lwa_final-vstel =   fp_lfs_likp-vstel.   "Shipping Point
  fp_lwa_final-kunnr =   fp_lfs_likp-kunnr.   "Ship-to-Party
  fp_lwa_final-kunag =   fp_lfs_likp-kunag.   "Sold-to-Party

**&& -- BOC for CR#1229
  fp_lwa_final-vsbed =   fp_lfs_likp-vsbed.   "Shipping Condition
  fp_lwa_final-inco1 =   fp_lfs_likp-inco1.   "Incoterms
  fp_lwa_final-wadat_ist =   fp_lfs_likp-wadat_ist.   "Actual Movement Date

  READ TABLE fp_i_tinct ASSIGNING <fp_lfs_tinct>
                        WITH KEY inco1 = fp_lfs_likp-inco1
                        BINARY SEARCH.
  IF sy-subrc IS INITIAL.
    fp_lwa_final-bezei =   <fp_lfs_tinct>-bezei.   "Incoterms Description
  ENDIF.

  READ TABLE fp_i_tvsbt ASSIGNING <fp_lfs_tvsbt>
                        WITH KEY vsbed = fp_lfs_likp-vsbed
                        BINARY SEARCH.
  IF sy-subrc IS INITIAL.
    fp_lwa_final-vtext =   <fp_lfs_tvsbt>-vtext.   "Shipping Condition Description
  ENDIF.
**&& -- EOC for CR#1229
**&& -- BOC : HPQC Defect 1229: SMUKHER : 07-MAR-14
  READ TABLE fp_i_tvstt ASSIGNING <fp_lfs_tvstt>
                        WITH KEY vstel = fp_lfs_likp-vstel
                        BINARY SEARCH.

  IF sy-subrc IS INITIAL.
    fp_lwa_final-vtext1 =   <fp_lfs_tvstt>-vtext.   "Shipping Point Description
  ENDIF.
**&& -- EOC : HPQC Defect 1229: SMUKHER : 07-MAR-14
ENDFORM.                    " DATA_POPULATION
*&---------------------------------------------------------------------*
*&      Form  f_set_pf_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.      "#EC CALLED

  SET PF-STATUS 'Z_PF_1000' EXCLUDING rt_extab.             "8-Jan-2014

ENDFORM.                    "f_set_pf_status
*&---------------------------------------------------------------------*
*&      Form  USER COMMAND
*&---------------------------------------------------------------------*
*      for user command interaction
*----------------------------------------------------------------------*
FORM f_user_command USING fp_ucomm LIKE sy-ucomm            "#EC CALLED
                        fp_selfield TYPE slis_selfield.

*Data declaration
  DATA: ref_grid TYPE REF TO cl_gui_alv_grid.

*Constants Declaration
  CONSTANTS: lc_save TYPE sy-ucomm VALUE '&SAVE&',             "save
             lc_back TYPE sy-ucomm VALUE '&BACK&',             "back
             lc_end TYPE sy-ucomm VALUE '&EXIT&',              "exit
             lc_cancel TYPE sy-ucomm VALUE '&CANCEL&',         "cancel
             lc_sel_all TYPE sy-ucomm VALUE '&SEL_ALL&',       "select all
             lc_de_sel TYPE sy-ucomm VALUE '&DE_SEL&',         "deselect all
             lc_sort_asc TYPE sy-ucomm VALUE '&SORT_ASC&',     "sort in ascending order
             lc_sort_des TYPE sy-ucomm VALUE '&SORT_DES&',     "sort in descending order
             lc_hotspot TYPE sy-ucomm VALUE '&IC1',            "hotspot
             lc_fieldname TYPE slis_fieldname VALUE 'VBELN',   "field value
             lc_field1 TYPE char10 VALUE 'VL'.                "parameter value

*Field-symbols declaration
  FIELD-SYMBOLS: <lfs_final> TYPE ty_final.

  CASE fp_ucomm.
*to save the selected records
    WHEN lc_save.
      PERFORM f_save_data USING i_final
                                fp_selfield.

      LOOP AT i_final ASSIGNING <lfs_final>.
        <lfs_final>-cb_sel = ' '.
      ENDLOOP.
      fp_selfield-refresh = abap_true.

* to go back to previous screen
    WHEN lc_back.
      LEAVE TO SCREEN 0.
* refresh the ALV Grid output
      fp_selfield-refresh = abap_true.
* to end the current process
    WHEN lc_end.
      LEAVE PROGRAM.
* to cancel the present process
    WHEN lc_cancel.
      LEAVE PROGRAM.
    WHEN lc_sel_all.
* to select all the records displayed in ALV Grid
      LOOP AT i_final ASSIGNING <lfs_final>.
        <lfs_final>-cb_sel = abap_true.
      ENDLOOP.
* refresh the ALV Grid output from internal table
      fp_selfield-refresh = abap_true.

    WHEN lc_de_sel.
* to de-select all the records displayed in ALV Grid
      LOOP AT i_final ASSIGNING <lfs_final>.
        <lfs_final>-cb_sel = ' '.
      ENDLOOP.
* refresh the ALV Grid output from internal table
      fp_selfield-refresh = abap_true.

* To sort the records in ascending order of the delivery number
    WHEN lc_sort_asc.
      SORT i_final BY vbeln.
      fp_selfield-refresh = abap_true.

* To sort the records in descending order of the delivery number
    WHEN lc_sort_des.
      SORT i_final BY vbeln DESCENDING.
      fp_selfield-refresh = abap_true.

      IF ref_grid IS INITIAL.
        CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
          IMPORTING
            e_grid = ref_grid.
      ENDIF.
      CALL METHOD ref_grid->refresh_table_display.

* to create hot spot for VBELN
    WHEN lc_hotspot.
* Check field clicked on within ALVgrid report
      IF fp_selfield-fieldname = lc_fieldname.

* Read data table, using index of row user clicked on
        READ TABLE i_final ASSIGNING <lfs_final> INDEX fp_selfield-tabindex.
        IF sy-subrc EQ 0.
* Set parameter ID for transaction screen field
          SET PARAMETER ID lc_field1 FIELD <lfs_final>-vbeln.
* Execute transaction VLPOD, and skip initial data entry screen
          CALL TRANSACTION 'VLPOD' AND SKIP FIRST SCREEN. "#EC CI_CALLTA
        ENDIF.
      ENDIF.
    WHEN OTHERS.
      MESSAGE e038.
  ENDCASE.
ENDFORM. "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
*    subroutine for POD execution
*----------------------------------------------------------------------*
*      -->FP_I_FINAL   final internal table
*      <--FP_SELFIELD  cursor position in ALV
*----------------------------------------------------------------------*
FORM f_save_data USING fp_i_final  TYPE ty_t_final
                       fp_selfield TYPE slis_selfield.

* local data declaration
  DATA: li_final_sel TYPE ty_t_final,    "Internal table for ALV final
        li_bdcdata TYPE STANDARD TABLE OF bdcdata,
                   "INITIAL SIZE 0,"internal table for BDC data
        li_bdcmsg TYPE ty_t_bdcmsgcoll, " internal table for BDC messages
        lv_answer TYPE char1,            "answer from the pop-up box
        lv_final_lines TYPE int4,        "variable
        lv_lines_char TYPE string,       "variable
        lv_text TYPE string,             "variable
        lv_count_ok  TYPE int4, "Records updated
        lv_count_not TYPE int4, "Records not updated
        lv_text1    TYPE string,"Text
        lv_text2    TYPE string,"Text
        lv_count    TYPE string."Char value of count

  DATA : ref_grid TYPE REF TO cl_gui_alv_grid.

* Field-symbol declaration
  FIELD-SYMBOLS: <lfs_final> TYPE ty_final,   "ALV final
                 <lfs_final1> TYPE ty_final.   "ALV final

* Constants declaration
  CONSTANTS: lc_j TYPE char1 VALUE '1',
             lc_error   TYPE sy-ucomm   VALUE 'E',   "Message: Error.
             lc_msgtyp TYPE char1 VALUE 'E'. " error


*&&-- To reflect the data changed into internal table
  IF ref_grid IS INITIAL.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = ref_grid.
  ENDIF.
  IF NOT ref_grid IS INITIAL.
    CALL METHOD ref_grid->check_changed_data.
  ENDIF.


*&&-- Get ONLY the selected entries
  li_final_sel[] = fp_i_final[].
  SORT li_final_sel BY cb_sel.
  DELETE li_final_sel WHERE cb_sel = space.
  DESCRIBE TABLE li_final_sel LINES lv_final_lines.

  IF li_final_sel[] IS NOT INITIAL.

    lv_lines_char = lv_final_lines.
    CONCATENATE text-016
                lv_lines_char
                text-017
                INTO lv_text SEPARATED BY space.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar       = text-018
        text_question  = lv_text
        text_button_1  = text-019
        text_button_2  = text-020
      IMPORTING
        answer         = lv_answer
      EXCEPTIONS
        text_not_found = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE lc_error NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    IF lv_answer = lc_j.

*&&-- CALL Transaction VLPOD by BDC with li_final_sel[]
      LOOP AT li_final_sel ASSIGNING <lfs_final>.
        PERFORM f_bdc_create USING <lfs_final>
                             CHANGING li_bdcdata.
        PERFORM f_call_transaction USING 'VLPOD'
                                         li_bdcdata
                                   CHANGING li_bdcmsg.
*       Insert a wait statement as sometime it fails to do the POD (in case of Multiple delivery)
        WAIT UP TO 1 SECONDS.

        IF sy-subrc EQ 0.

* POD successful.
*&&-- Count the Record updated successfully
          lv_count_ok = lv_count_ok + 1.
          READ TABLE fp_i_final ASSIGNING <lfs_final1>
                                WITH KEY vbeln = <lfs_final>-vbeln
                                BINARY SEARCH.
          IF sy-subrc EQ 0.
            <lfs_final1>-vbeln = space.
          ENDIF.
        ELSE.

          READ TABLE li_bdcmsg TRANSPORTING NO FIELDS WITH KEY msgtyp = lc_msgtyp.
          IF sy-subrc IS INITIAL.

*&&-- Count the Record NOT updated successfully
            lv_count_not = lv_count_not + 1.
          ENDIF.
        ENDIF.
        REFRESH: li_bdcmsg[],
                 li_bdcdata[].
      ENDLOOP.
      DELETE fp_i_final WHERE vbeln = space.
      fp_selfield-refresh = abap_true.
    ELSE.
      EXIT.
    ENDIF. " yes
  ELSE.
*&&-- Message when no checkbox is CHECKED
    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        titel = text-021
        txt1  = text-022
        txt2  = ' '.
  ENDIF." li_final_sel not initial

*&&-- POP UP message for Updation
  CLEAR: lv_text1,
         lv_text2.
  IF lv_count_ok <> 0.
    CLEAR lv_count.
    lv_count = lv_count_ok.
    CONCATENATE lv_count
                'record(s) POD executed sucessfully !!'(023)
                INTO lv_text1
                SEPARATED BY space.
  ENDIF.
  IF lv_count_not <> 0.
    CLEAR lv_count.
    lv_count = lv_count_not.
    CONCATENATE lv_count
                'record(s) POD failed!!'(024)
                INTO lv_text2
                SEPARATED BY space.
  ENDIF.
  IF lv_count_ok <> 0 OR lv_count_not <> 0.
    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        titel = 'Update Information'(025)
        txt1  = lv_text1
        txt2  = lv_text2.
  ENDIF.
ENDFORM.                    "f_save_data
*&---------------------------------------------------------------------*
*&      form F_BDC_DYNPRO
*&---------------------------------------------------------------------*
*       This is used for populating program name and screen number
*----------------------------------------------------------------------*
*      -->FP_V_PROGRAM        BDC Program Name
*      -->FP_V_DYNPRO         BDC Screen Dynpro No.
*      <--FP_I_BDCDATA        Filled up BDC Data
*----------------------------------------------------------------------*
FORM f_bdc_dynpro  USING fp_v_program  TYPE bdc_prog
                         fp_v_dynpro   TYPE bdc_dynr
                CHANGING fp_i_bdcdata  TYPE ty_t_bdcdata.
* Local data declaration
  DATA: lwa_bdcdata TYPE bdcdata.
* Filling the BDC Data table for Program name, screen no and dyn begin
  CLEAR lwa_bdcdata.
  lwa_bdcdata-program  = fp_v_program.
  lwa_bdcdata-dynpro   = fp_v_dynpro.
  lwa_bdcdata-dynbegin = abap_true.
  APPEND lwa_bdcdata TO fp_i_bdcdata.
ENDFORM.                    " F_BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      form F_BDC_FIELD
*&---------------------------------------------------------------------*
*       This subroutine is used to populate field name and values
*----------------------------------------------------------------------*
*      -->FP_V_FNAM      Field Name
*      -->FP_V_FVAL      Field Value
*      <--FP_I_BDCDATA   Populated BDC Data
*----------------------------------------------------------------------*
FORM f_bdc_field  USING fp_v_fnam    TYPE any
                        fp_v_fval    TYPE any
               CHANGING fp_i_bdcdata TYPE bdcdata_tab.

* Local data declaration
  DATA: lwa_bdcdata TYPE ty_bdcdata.

* Filling the BDC Data table for Field value and Field name
  IF NOT fp_v_fval IS INITIAL.
    CLEAR lwa_bdcdata.
    lwa_bdcdata-fnam = fp_v_fnam.
    lwa_bdcdata-fval = fp_v_fval.
    APPEND lwa_bdcdata TO fp_i_bdcdata.
  ENDIF.

ENDFORM.                    " F_BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  F_CALL_TRANSACTION
*&---------------------------------------------------------------------*
*       subroutine for BDC CALL TRANSACTION
*----------------------------------------------------------------------*
*      -->FP_TCODE         sytcode                                     *
*      -->FP_I_BDCDATA     internal table for BDC data                 *
*      -->FP_BDCMSG        internal table for BDC messages             *
*----------------------------------------------------------------------*
FORM f_call_transaction  USING fp_tcode TYPE sytcode
                               fp_i_bdcdata TYPE bdcdata_tab
                         CHANGING fp_bdcmsg TYPE ty_t_bdcmsgcoll.

  DATA: lv_bdc_mode TYPE char1. " BDC mode

  CONSTANTS: lc_bdc_mode TYPE char1 VALUE 'N'.   " BDC Mode

  lv_bdc_mode = lc_bdc_mode.
  CALL TRANSACTION fp_tcode USING fp_i_bdcdata
                            MODE lv_bdc_mode
                            MESSAGES INTO fp_bdcmsg.

ENDFORM.                    " F_CALL_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_S_INCO1
*&---------------------------------------------------------------------*
*       subroutine to validate the incoterms
*----------------------------------------------------------------------*
FORM f_validate_s_inco1.

  SELECT inco1
    FROM tinc
    UP TO 1 ROWS
    BYPASSING BUFFER
    INTO gv_inco1
    WHERE inco1 IN s_inco1.
  ENDSELECT.
  IF sy-subrc NE 0.
* Incoterms is not valid.
    MESSAGE e035. "Incoterms is invalid
  ENDIF.
ENDFORM.                    " F_VALIDATE_S_INCO1
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_S_VSBED
*&---------------------------------------------------------------------*
*       subroutine to validate the Shipping Conditions
*----------------------------------------------------------------------*
FORM f_validate_s_vsbed.

  SELECT vsbed
    FROM tvsb
    UP TO 1 ROWS
    BYPASSING BUFFER
    INTO gv_vsbed
    WHERE vsbed IN s_vsbed.
  ENDSELECT.
  IF sy-subrc NE 0.
* Shipping Conditions is not valid.
    MESSAGE e036. "Shipping Conditions is invalid
  ENDIF.
ENDFORM.                    " F_VALIDATE_S_VSBED
*&---------------------------------------------------------------------*
*&      Form  F_EXECUTE_BACKGROUND
*&---------------------------------------------------------------------*
*     subroutine for background execution                              *
*----------------------------------------------------------------------*
*      -->FP_I_FINAL                   internal table Final
*----------------------------------------------------------------------*
FORM f_execute_background  USING fp_i_final TYPE ty_t_final.

  DATA: li_bdcmsg TYPE ty_t_bdcmsgcoll, "internal table for BDC messages
        li_bdcdata TYPE STANDARD TABLE OF bdcdata
                   INITIAL SIZE 0,      "internal table for BDC data
        lv_text TYPE char50.            "message

  CONSTANTS: lc_msgtyp TYPE char1 VALUE 'E',  " error
             lc_msgtyp1 TYPE char1 VALUE 'I', "information
             lc_msgtyp2 TYPE char2 VALUE 'S'. "success

  FIELD-SYMBOLS: <lfs_final> TYPE ty_final,
                 <lfs_final1> TYPE ty_final.

  LOOP AT fp_i_final ASSIGNING <lfs_final>.

    PERFORM f_bdc_create USING <lfs_final>
                         CHANGING li_bdcdata.
    PERFORM f_call_transaction USING 'VLPOD'
                                      li_bdcdata
                                     CHANGING li_bdcmsg.

    IF sy-subrc EQ 0.

* BOC : SNIGAM : CR-1229 : 24-Apr-2014
*     Additional wait of 1 Second is requierd
      WAIT UP TO 1 SECONDS.
* EOC : SNIGAM : CR-1229 : 24-Apr-2014
*&&-- Populate the Successfull message
      CONCATENATE <lfs_final>-vbeln
                  'has successfully executed POD'(004)
                  INTO lv_text
                  SEPARATED BY space.
      MESSAGE lv_text TYPE lc_msgtyp2.   " S

      READ TABLE fp_i_final ASSIGNING <lfs_final1>
                            WITH KEY vbeln = <lfs_final>-vbeln
                            BINARY SEARCH.
      IF sy-subrc EQ 0.
        <lfs_final1>-vbeln = space.
      ENDIF.
    ELSE.
      READ TABLE li_bdcmsg TRANSPORTING NO FIELDS WITH KEY msgtyp = lc_msgtyp BINARY SEARCH. " E
      IF sy-subrc IS NOT INITIAL.
*&&-- Populate the Unsuccessfull message
        CONCATENATE <lfs_final>-vbeln
                    'has not successfully executed POD'(005)
                    INTO lv_text
                    SEPARATED BY space.
        MESSAGE lv_text TYPE lc_msgtyp1.   " I

      ENDIF.
    ENDIF.
    REFRESH: li_bdcdata[],
             li_bdcmsg[].
  ENDLOOP.
ENDFORM.                    " F_EXECUTE_BACKGROUND
*&---------------------------------------------------------------------*
*&      Form  F_BDC_CREATE
*&---------------------------------------------------------------------*
*       subroutine for BDC data
*----------------------------------------------------------------------*
*      -->FP_LI_FINAL_SEL   internal table Final
*----------------------------------------------------------------------*
FORM f_bdc_create  USING fp_lfs_final TYPE ty_final
                   CHANGING fp_i_bdcdata TYPE bdcdata_tab.

  DATA:   lv_date TYPE char10,"Date
          lv_time TYPE char8."Time

*&&-- Convert Date & time to user format for BDC
  WRITE sy-datum TO lv_date.
  WRITE sy-uzeit TO lv_time.

  PERFORM f_bdc_dynpro USING 'SAPMV50A' '4006'
                                  CHANGING fp_i_bdcdata.
  PERFORM f_bdc_field USING 'BDC_CURSOR'  'LIKP-VBELN'
                        CHANGING fp_i_bdcdata.
  PERFORM f_bdc_field USING 'BDC_OKCODE'  '/00'
                        CHANGING fp_i_bdcdata.
  PERFORM f_bdc_field USING 'LIKP-VBELN'  fp_lfs_final-vbeln
                        CHANGING fp_i_bdcdata.

  PERFORM f_bdc_dynpro USING 'SAPMV50A' '1000'
                        CHANGING fp_i_bdcdata.
  PERFORM f_bdc_field USING 'BDC_OKCODE'  '=PODQ'
                        CHANGING fp_i_bdcdata.
  PERFORM f_bdc_field USING 'BDC_SUBSCR'  'SAPMV50A                                1502SUBSCREEN_HEADER'
                        CHANGING fp_i_bdcdata.
  PERFORM f_bdc_field USING 'BDC_SUBSCR'  'SAPMV50A                                1110SUBSCREEN_BODY'
                        CHANGING fp_i_bdcdata.
  PERFORM f_bdc_field USING 'BDC_CURSOR'  'TVPODVB-GRUND(01)'
                        CHANGING fp_i_bdcdata.
  PERFORM f_bdc_field USING 'LIKP-PODAT'  lv_date
                        CHANGING fp_i_bdcdata.
  PERFORM f_bdc_field USING 'LIKP-POTIM'  lv_time
                        CHANGING fp_i_bdcdata.
  PERFORM f_bdc_field USING 'BDC_SUBSCR'  'SAPMV50A                                1704SUBSCREEN_ICONBAR'
                        CHANGING fp_i_bdcdata.

  PERFORM f_bdc_dynpro USING 'SAPMV50A' '1000'
                        CHANGING fp_i_bdcdata.
  PERFORM f_bdc_field USING 'BDC_OKCODE'  '=SICH_T'
                        CHANGING fp_i_bdcdata.
  PERFORM f_bdc_field USING 'BDC_SUBSCR'  'SAPMV50A                                1502SUBSCREEN_HEADER'
                        CHANGING fp_i_bdcdata.
  PERFORM f_bdc_field USING 'BDC_SUBSCR'  'SAPMV50A                                1110SUBSCREEN_BODY'
                        CHANGING fp_i_bdcdata.
  PERFORM f_bdc_field USING 'BDC_CURSOR'  'TVPODVB-GRUND(02)'
                        CHANGING fp_i_bdcdata.
  PERFORM f_bdc_field USING 'BDC_SUBSCR'  'SAPMV50A                                1704SUBSCREEN_ICONBAR'
                        CHANGING fp_i_bdcdata.

ENDFORM.                    " F_BDC_CREATE.
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_VBUK
*&---------------------------------------------------------------------*
*      data retreival from VBUK
*----------------------------------------------------------------------*
*      -->FP_I_LIKP  internal table of LIKP
*      <--FP_I_VBUK  internal table of VBUK
*----------------------------------------------------------------------*
FORM f_retrieve_from_vbuk  USING    fp_i_likp TYPE ty_t_likp
                           CHANGING fp_i_vbuk TYPE ty_t_vbuk.

  IF NOT fp_i_likp IS INITIAL.
    SELECT vbeln           " Sales and Distribution Document Number
           wbstk           " Total goods movement status
    FROM vbuk
    INTO TABLE fp_i_vbuk
    FOR ALL ENTRIES IN fp_i_likp
      WHERE vbeln = fp_i_likp-vbeln.
    IF sy-subrc EQ 0.
      SORT fp_i_vbuk BY vbeln
                        .
    ENDIF.
  ENDIF.

ENDFORM.                    " F_RETRIEVE_FROM_VBUK
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_TINC
*&---------------------------------------------------------------------*
*       retrieve from TINCT table
*----------------------------------------------------------------------*
*      -->FP_I_LIKP    internal table type LIKP
*      <--FP_I_TINCT   internal table type TINCT
*----------------------------------------------------------------------*
FORM f_retrieve_from_tinc  USING    fp_i_likp TYPE ty_t_likp
                           CHANGING fp_i_tinct TYPE ty_t_tinct.

  DATA: li_likp TYPE ty_t_likp.

  IF fp_i_likp IS NOT INITIAL.
*&&-- Remove the duplicate INCO1
    li_likp[] = fp_i_likp[].
    SORT li_likp BY inco1.
    DELETE ADJACENT DUPLICATES FROM li_likp COMPARING inco1.

    SELECT spras   " Language Key
           inco1   " Incoterms
           bezei   " Incoterms Description
    FROM tinct
    INTO TABLE fp_i_tinct
    FOR ALL ENTRIES IN li_likp
    WHERE spras = sy-langu
    AND   inco1 = li_likp-inco1.

    IF sy-subrc IS INITIAL.
      SORT fp_i_tinct BY inco1.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_RETRIEVE_FROM_TINC
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_TVSB
*&---------------------------------------------------------------------*
*       retrieve from TVSBT table
*----------------------------------------------------------------------*
*      -->FP_I_LIKP   internal table from LIKP
*      <--FP_I_TVSBT  internal table From TVSBT
*----------------------------------------------------------------------*
FORM f_retrieve_from_tvsb  USING    fp_i_likp TYPE ty_t_likp
                           CHANGING fp_i_tvsbt TYPE ty_t_tvsbt.

  DATA: li_likp TYPE ty_t_likp.

  IF fp_i_likp IS NOT INITIAL.
*&&-- Remove the duplicate VSBED
    li_likp[] = fp_i_likp[].
    SORT li_likp BY vsbed.
    DELETE ADJACENT DUPLICATES FROM li_likp COMPARING vsbed.

    SELECT spras   " Language Key
           vsbed   " Shipping Conditions
           vtext   " Shipping Conditions Descriptions
    FROM tvsbt
    INTO TABLE fp_i_tvsbt
    FOR ALL ENTRIES IN li_likp
    WHERE spras = sy-langu
    AND   vsbed = li_likp-vsbed.

    IF sy-subrc IS INITIAL.
      SORT fp_i_tvsbt BY vsbed.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_RETRIEVE_FROM_TVSB
*&------------------------------------------------------------------------*
*&      Form  F_CHECK_INITIAL
*&-------------------------------------------------------------------------*
*&  to check if Shipping Conditions, Incoterms and Date Creation are filed *
*&  if all deliveries radiobutton selected                                 *
*&-------------------------------------------------------------------------*
FORM f_check_initial .

*&&-- CHeck if the ALL Deliveries radio button is selected
  IF rb_aldev = abap_true.
*&&-- All selection screen fields are then mandatory
*&&-- Creation Date is already a mandatory field
*&&-- Check for Incoterms & Shipping Condition
    IF s_inco1 IS INITIAL OR s_vsbed IS INITIAL.
      MESSAGE i120.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_CHECK_INITIAL
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_TVSTT
*&---------------------------------------------------------------------*
*       retrieve data from TVSTT table
*----------------------------------------------------------------------*
*      -->FP_I_LIKP  text
*      <--FP_I_TVSTT  text
*----------------------------------------------------------------------*
FORM f_retrieve_from_tvstt  USING    fp_i_likp TYPE ty_t_likp
                            CHANGING fp_i_tvstt TYPE ty_t_tvstt.

  DATA: li_likp TYPE STANDARD TABLE OF ty_likp INITIAL SIZE 0. "internal table

  li_likp[] = fp_i_likp[].
  SORT li_likp BY vstel.
  DELETE ADJACENT DUPLICATES FROM li_likp COMPARING vstel.

  IF NOT li_likp IS INITIAL.

    SELECT spras  " Language Key
           vstel  " Shipping Point/Receiving Point
           vtext  " Description
    FROM tvstt
    INTO TABLE fp_i_tvstt
    FOR ALL ENTRIES IN li_likp
    WHERE spras = sy-langu
      AND vstel = li_likp-vstel.

    IF sy-subrc IS INITIAL .
      SORT fp_i_tvstt BY vstel.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_RETRIEVE_FROM_TVSTT
