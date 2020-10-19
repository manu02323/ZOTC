************************************************************************
* PROGRAM    : ZOTCN136O_CSTM_FLDS_SO_ITEM(Include)                    *
* TITLE      : Custom Fields on Sales Document                         *
* DEVELOPER  : KRITI SRIVASTAVA                                        *
* OBJECT TYPE: ENHANCEMENT                                             *
* SAP RELEASE: SAP ECC 6.0                                             *
*----------------------------------------------------------------------*
* WRICEF ID :  D2_OTC_EDD_0136                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: Custom Fields on Sales Document
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER    TRANSPORT   DESCRIPTION                         *
* =========== ========  ========== ====================================*
* 22-JUL-2014  KSRIVAS  E2DK900492  DEVELOPMENT FOR CR41-              *
*                                   D2_OTC_EDD_0136
* Field on the item level to capture transportation group of material  *
*&---------------------------------------------------------------------*
* 10-Oct-2014  RPANIGR  E2DK900492  Development Changes For            *
*                                   D2_OTC_EDD_0136/CR-134
* For Instrument Reference at SO item level                            *
* Linking an instrumnet with a service item in a sales order           *
*&---------------------------------------------------------------------*
* 12-Nov-2014 RPANIGR   E2DK900492 Changes for D2_OTC_EDD_0136/Def#1529*
* D2_OTC_EDD_0136/Def#1529:                                            *
* For VBAP-STLNR(Item Bill of material) blank,serial number instruments*
* are to be linked with service line, else for VBAP-STLNR not blank,   *
* link instruments whose Higher-level item in BOM is blank.            *
* Material description is to be shown along with other details which   *
* can be linked to the service line item                               *
*&---------------------------------------------------------------------*
*22-Apr-2015   DMOIRAN E2DK900492  D2_OTC_EDD_0136/CR D2_626 Set       *
*                                  indicator of last component of BOM. *
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&  Include           ZOTCN136O_CSTM_FLDS_SO_ITEM
*&---------------------------------------------------------------------*

*-->> Begin of change for D2_OTC_EDD_136-CR134/10-Oct-2014 by RPANIGR
* Data Declaration for include Program for Instrument Reference at SO Item


************************************************************************
*============================Data Declaration==========================*
************************************************************************
* Types Declaration
TYPES: BEGIN OF lty_serlzd_mvgr1,
       sign TYPE tvarv_sign, " ABAP: ID: I/E (include/exclude values)
       opti TYPE tvarv_opti, " ABAP: Selection option (EQ/BT/CP/...)
       low  TYPE fpb_low,    " ABAP/4: Selection value (LOW or HIGH value, external format)
       high TYPE fpb_high,   " ABAP/4: Selection value (LOW or HIGH value, external format)
       END OF lty_serlzd_mvgr1.

* Constants Declaration
CONSTANTS: lc_enhancem_no  TYPE z_enhancement VALUE 'D2_OTC_EDD_0136', " Enhancement NUMBER
           lc_active_stat  TYPE z_criteria    VALUE 'NULL',            " Enh. Criteria
           lc_auart        TYPE z_criteria    VALUE 'AUART',           " Enh. Criteria
           lc_serlzd_mvgr1 TYPE z_criteria    VALUE 'SERLZED_MVGR1',   " Enh. Criteria
           lc_servc_mvgr1  TYPE z_criteria    VALUE 'SERVC_MVGR1',     " Enh. Criteria
           lc_first_line   TYPE posnr_va      VALUE '000010',          " Sales Document Item
           lc_bill_block   TYPE faksp_ap      VALUE '10',              " Billing block for item
           lc_i            TYPE tvarv_sign    VALUE 'I',               " ABAP: ID: I/E (include/exclude values)
           lc_eq           TYPE tvarv_opti    VALUE 'EQ',              " ABAP: Selection option (EQ/BT/CP/...)
           lc_delv_partial TYPE lfsta         VALUE 'B',               " Delivery status
           lc_delv_complet TYPE lfsta         VALUE 'C',               " Delivery status
           lc_cancel_list  TYPE char1         VALUE 'A',               " Cancel_list of type CHAR1
* ---> Begin of Insert for D2_OTC_EDD_0136 CR D2_626 by DMOIRAN
           lc_sales_bom_5  TYPE stlan         VALUE '5',     " BOM Usage
           lc_mtart        TYPE z_criteria    VALUE 'MTART'. " Enh. Criteria
* <--- End    of Insert for D2_OTC_EDD_0136 CR D2_626 by DMOIRAN

* Data Declaration
DATA: li_vbap_instref  TYPE STANDARD TABLE OF vbapvb INITIAL SIZE 0,           " Sales Document: Item Data
      li_spopli        TYPE STANDARD TABLE OF spopli INITIAL SIZE 0,           " Pop-up possible entry fields
      lr_serlzd_mvgr1  TYPE STANDARD TABLE OF lty_serlzd_mvgr1 INITIAL SIZE 0, " Range table for Serialized material
      li_enh_status    TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0,  " Internal table
      lwa_serlzd_mvgr1 TYPE lty_serlzd_mvgr1,                                  " Workarea for Serialized material
      lwa_spopli       TYPE spopli,                                            " Pop-up possible entry fields
      lwa_vbap_instref TYPE vbapvb,                                            " Sales Document: Item Data
* ---> Begin of Insert for D2_OTC_EDD_0136 CR D2_626 by DMOIRAN
      li_stb           TYPE STANDARD TABLE OF bom_item_api01, "stpox, " BOM Items (Extended for List Displays)
      lv_line_count    TYPE sytabix,                          " Index of Internal Tables
      lv_valid_from    TYPE datuv_bi.                         " Valid-From Date (BTCI)
* <--- End    of Insert for D2_OTC_EDD_0136 CR D2_626 by DMOIRAN

DATA: lv_popup_answer TYPE char1,  " Popup_answer of type CHAR1
      lv_item_select  TYPE char1,  " Item_select of type CHAR1
      lv_varoption    TYPE char65. " Varoption of type CHAR65

* Field-symbol Declaration
FIELD-SYMBOLS: <lfs_enh_status> TYPE zdev_enh_status, " Enhancement Status
               <lfs_vbap>       TYPE vbapvb,          " Sales Document: Item Data
               <lfs_vbup>       TYPE vbupvb,          " Sales Document: Item Status
               <lfs_spopli>     TYPE spopli,          " Pop-up possible entry fields
* ---> Begin of Insert for D2_OTC_EDD_0136 CR D2_626 by DMOIRAN
               <lfs_stb>           TYPE bom_item_api01,   " stpox,            " BOM Items (Extended for List Displays)
               <lfs_bom_last_comp> TYPE ty_bom_last_comp. "BOM last component
* <--- End    of Insert for D2_OTC_EDD_0136 CR D2_626 by DMOIRAN

*--<< End of change for D2_OTC_EDD_136-CR134/10-Oct-2014 by RPANIGR


*Moving material transportation group to item
MOVE maapv-tragr  TO vbap-zztragr.


*-->> Begin of change for D2_OTC_EDD_136-CR134/10-Oct-2014 by RPANIGR
* Include Program changed for Instrument Reference at SO Item

************************************************************************
*============================Processing Logic==========================*
************************************************************************
* Check Enh is active in EMI tool
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_enhancem_no
  TABLES
    tt_enh_status     = li_enh_status.

* We select only the active entries.
DELETE li_enh_status WHERE active = space.

* If enh is active in EMI Tool
IF li_enh_status IS NOT INITIAL.
* Prepare Range table for MVGR1 values of serialized materials
  LOOP AT li_enh_status ASSIGNING <lfs_enh_status>.
    lwa_serlzd_mvgr1-sign = lc_i.
    lwa_serlzd_mvgr1-opti = lc_eq.
    lwa_serlzd_mvgr1-low  = <lfs_enh_status>-sel_low.
    lwa_serlzd_mvgr1-high = space.
    APPEND lwa_serlzd_mvgr1 TO lr_serlzd_mvgr1.
    CLEAR lwa_serlzd_mvgr1.
  ENDLOOP. " LOOP AT li_enh_status ASSIGNING <lfs_enh_status>

* Get the active status from EMI tool
  READ TABLE li_enh_status ASSIGNING <lfs_enh_status>
                           WITH KEY criteria = lc_active_stat.
  IF sy-subrc = 0.

* If order type (ZOR or ZSTD) is found in EMI tool for this object
    READ TABLE li_enh_status ASSIGNING <lfs_enh_status>
                             WITH KEY criteria = lc_auart
                                      sel_low  = vbak-auart.
    IF sy-subrc = 0.

* If this is the first line item in the order, need not to do anything
      IF vbap-posnr NE lc_first_line.

* If not a first line item in the order
        READ TABLE xvbap ASSIGNING <lfs_vbap> WITH KEY vbeln = vbap-vbeln
                                                       posnr = vbap-posnr.
* If the entered line item is a new line item
        IF sy-subrc <> 0.
          READ TABLE li_enh_status ASSIGNING <lfs_enh_status>
                                   WITH KEY criteria = lc_servc_mvgr1
                                            sel_low  = vbap-mvgr1.
* If the line item is a Service line...
* Collect items which are serilaized (instruments) and are not delivered into a local table
          IF sy-subrc = 0.

* Get all the items which are serialized, Not applied with a Rejection reason and are not delivered
            LOOP AT xvbap ASSIGNING <lfs_vbap>.

*---> Begin of Change for D2_OTC_EDD_0136 Defect #1529/12-Nov-14 by RPANIGR
* For the instruments, if VBAP-STLNR(Bill of material) is blank ,consider this if it is with a serial profile
              IF <lfs_vbap>-stlnr = space.
*---< End of Change for D2_OTC_EDD_0136 Defect #1529/12-Nov-14 by RPANIGR

                IF ( <lfs_vbap>-serail <> space ) AND
                   ( <lfs_vbap>-mvgr1 IN lr_serlzd_mvgr1 ) AND
                   ( <lfs_vbap>-abgru = space ).

                  READ TABLE xvbup ASSIGNING <lfs_vbup> WITH KEY vbeln = <lfs_vbap>-vbeln
                                                                 posnr = <lfs_vbap>-posnr.
                  IF sy-subrc = 0.
                    IF  <lfs_vbup>-lfsta <> lc_delv_partial
                    AND <lfs_vbup>-lfsta <> lc_delv_complet.
* Collect items which are serilaized (instruments) and are not delivered...
* ...that can be assigned to a service line item
                      lwa_vbap_instref = <lfs_vbap>.
                      APPEND lwa_vbap_instref TO  li_vbap_instref.
                    ENDIF. " IF <lfs_vbup>-lfsta <> lc_delv_partial
                  ENDIF. " IF sy-subrc = 0
                ENDIF. " IF ( <lfs_vbap>-serail <> space ) AND

*---> Begin of Change for D2_OTC_EDD_0136 Defect #1529/12-Nov-14 by RPANIGR
* For the instruments, if VBAP-STLNR(Bill of material) is not blank ,consider this if it is...
* ...having Higher-level item in bill of material structures is blank , that is its a header one
              ELSE. " ELSE -> IF <lfs_vbup>-lfsta <> lc_delv_partial

                IF ( <lfs_vbap>-uepos = space ) AND
                   ( <lfs_vbap>-mvgr1 IN lr_serlzd_mvgr1 ) AND
                   ( <lfs_vbap>-abgru = space ).

                  READ TABLE xvbup ASSIGNING <lfs_vbup> WITH KEY vbeln = <lfs_vbap>-vbeln
                                                                 posnr = <lfs_vbap>-posnr.
                  IF sy-subrc = 0.
                    IF  <lfs_vbup>-lfsta <> lc_delv_partial
                    AND <lfs_vbup>-lfsta <> lc_delv_complet.
* Collect items (instruments) which are not delivered...
* ...that can be assigned to a service line item
                      lwa_vbap_instref = <lfs_vbap>.
                      APPEND lwa_vbap_instref TO  li_vbap_instref.
                    ENDIF. " IF <lfs_vbup>-lfsta <> lc_delv_partial
                  ENDIF. " IF sy-subrc = 0
                ENDIF. " IF ( <lfs_vbap>-uepos = space ) AND
              ENDIF. " IF <lfs_vbap>-stlnr = space
*---< End of Change for D2_OTC_EDD_0136 Defect #1529/12-Nov-14 by RPANIGR

            ENDLOOP. " LOOP AT xvbap ASSIGNING <lfs_vbap>

          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF vbap-posnr NE lc_first_line
    ENDIF. " IF sy-subrc = 0

* Sort all the instrument items by document and line number
* Delete duplicates, if any
    SORT li_vbap_instref BY vbeln posnr.
    DELETE ADJACENT DUPLICATES FROM li_vbap_instref COMPARING vbeln posnr.

* If there are instrumnets items in the Sales order
    IF li_vbap_instref IS NOT INITIAL.
* If there are items collected which are serialized and not delivered...
* ... prior to the service line item add
* Call FM for the Pop up to user for confirmation
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar              = 'PopUp to Confirm'(901)
          text_question         = 'Is Service Plan sold with instrument ?'(902)
          text_button_1         = 'Yes'(903)
          text_button_2         = 'No'(904)
          display_cancel_button = abap_false
          start_column          = 25
          start_row             = 6
        IMPORTING
          answer                = lv_popup_answer
        EXCEPTIONS
          text_not_found        = 1
          OTHERS                = 2.

* If Popup to confirmation is true and user ready to go with answer as Yes(1)
      IF sy-subrc = 0 AND lv_popup_answer = 1.

* Fill the table for list of possible values to user for selecting...
* the line item to be linked with the service line
        LOOP AT li_vbap_instref ASSIGNING <lfs_vbap>.
          lwa_spopli-selflag   = abap_true.
          CONCATENATE <lfs_vbap>-posnr
                      <lfs_vbap>-matnr
*---> Begin of Change for D2_OTC_EDD_0136 Defect #1529/12-Nov-14 by RPANIGR
* Include Sales item description of the materials in the order, that can be linked to the service line
                      <lfs_vbap>-arktx
*---< End of Change for D2_OTC_EDD_0136 Defect #1529/12-Nov-14 by RPANIGR
                      INTO lv_varoption SEPARATED BY space.

          lwa_spopli-varoption = lv_varoption.
          APPEND lwa_spopli TO li_spopli.
          CLEAR lwa_spopli.
        ENDLOOP. " LOOP AT li_vbap_instref ASSIGNING <lfs_vbap>

* Call Function with the list of items for user to decide one which is to be linked ...
* ...with the service line item

        CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
          EXPORTING
            mark_max           = 1
            textline1          = 'Select Instrument Line item'(905)
*---> Begin of Change for D2_OTC_EDD_0136 Defect #1529/12-Nov-14 by RPANIGR
*            textline2          = 'Sel Items Material'(906)
            textline2          = 'SEL LineNo Material Material Description'(906)
*---< End of Change for D2_OTC_EDD_0136 Defect #1529/12-Nov-14 by RPANIGR
            titel              = 'Instrument Line items'(907)
          IMPORTING
            answer             = lv_item_select
          TABLES
            t_spopli           = li_spopli
          EXCEPTIONS
            not_enough_answers = 1
            too_much_answers   = 2
            too_much_marks     = 3
            OTHERS             = 4.
* if user selected one item which the user wishes to link with the service line item
        IF sy-subrc = 0 AND
           lv_item_select IS NOT INITIAL AND
           lv_item_select <> lc_cancel_list.

* Get the line item number of that row which user has selected...
* and link with the service line item's ZZLNREF field
* Also set a billing block to the service line item as it is dependent upon the referenced line item
          READ TABLE li_vbap_instref ASSIGNING <lfs_vbap>
                                     INDEX lv_item_select.
          IF sy-subrc = 0.
            vbap-zzlnref = <lfs_vbap>-posnr.
            IF <lfs_vbap>-abgru IS NOT INITIAL.
              vbap-abgru = <lfs_vbap>-abgru.
              CLEAR: vbap-faksp.
            ELSE. " ELSE -> IF <lfs_vbap>-abgru IS NOT INITIAL
              vbap-faksp = lc_bill_block.
            ENDIF. " IF <lfs_vbap>-abgru IS NOT INITIAL
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF sy-subrc = 0 AND
      ENDIF. " IF sy-subrc = 0 AND lv_popup_answer = 1
    ENDIF. " IF li_vbap_instref IS NOT INITIAL

* Refresh variables
    REFRESH: li_vbap_instref[],
             li_spopli[].

    CLEAR: lv_popup_answer,
           lv_item_select.
  ENDIF. " IF sy-subrc = 0

* ---> Begin of Insert for D2_OTC_EDD_0136 CR D2_626 by DMOIRAN
* Check the BOM header material type from EMI. If found then find the last
* component of the BOM and stored it for later used.


        READ TABLE li_enh_status
                             WITH KEY criteria = lc_mtart
                                      sel_low = maapv-mtart
                             TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          WRITE sy-datum TO lv_valid_from.
* Get the BOM components
          CALL FUNCTION 'CSEP_MAT_BOM_READ'
            EXPORTING
              material   = vbap-matnr
              plant      = vbap-werks
              bom_usage  = lc_sales_bom_5
              valid_from = lv_valid_from
            TABLES
              t_stpo     = li_stb
            EXCEPTIONS
              error      = 1
              OTHERS     = 2.

          IF sy-subrc = 0.
            DESCRIBE TABLE li_stb LINES lv_line_count.
* get the last componenet of the BOM
            READ TABLE li_stb ASSIGNING <lfs_stb> INDEX lv_line_count.
            IF sy-subrc = 0.
* Check if the material has already been added. If not then store it for later use.
* Binary search not used as number of record will be low.
              READ TABLE i_bom_last_comp TRANSPORTING NO FIELDS
                                          WITH KEY uepos = vbap-posnr
                                                   matnr = <lfs_stb>-component.

              IF sy-subrc NE 0.
                APPEND INITIAL LINE TO i_bom_last_comp ASSIGNING <lfs_bom_last_comp>.
                IF <lfs_bom_last_comp> IS ASSIGNED.
* Current line item will be high level item for the BOM component
                  <lfs_bom_last_comp>-uepos = vbap-posnr.
                  <lfs_bom_last_comp>-matnr = <lfs_stb>-component.
*                  <lfs_bom_last_comp>-matnr = <lfs_stb>-idnrk.
                ENDIF. " IF <lfs_bom_last_comp> IS ASSIGNED

              ENDIF. " IF sy-subrc NE 0
            ENDIF. " IF sy-subrc = 0

          ENDIF. " IF sy-subrc = 0

        ENDIF. " IF sy-subrc = 0

* This part will be executed for the iteration of BOM's last component material.
* Binary search not done as number of record will be low.
        READ TABLE i_bom_last_comp TRANSPORTING NO FIELDS
                         WITH KEY uepos = vbap-uepos
                                  matnr = vbap-matnr.
        IF sy-subrc = 0.
* set the BOM last component indicator
          vbap-zzbom_last_comp = abap_true.
        ENDIF.
* <--- End    of Insert for D2_OTC_EDD_0136 CR D2_626 by DMOIRAN

ENDIF. " IF li_enh_status IS NOT INITIAL

*--<< End of change for D2_OTC_EDD_136-CR134/10-Oct-2014 by RPANIGR
