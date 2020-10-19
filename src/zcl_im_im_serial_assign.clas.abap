class ZCL_IM_IM_SERIAL_ASSIGN definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_LE_SHP_DELIVERY_PROC .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_IM_SERIAL_ASSIGN IMPLEMENTATION.


method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_DELIVERY_HEADER.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_DELIVERY_ITEM.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_FCODE_ATTRIBUTES.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_FIELD_ATTRIBUTES.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~CHECK_ITEM_DELETION.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_DELETION.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_FINAL_CHECK.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~DOCUMENT_NUMBER_PUBLISH.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~FILL_DELIVERY_HEADER.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~FILL_DELIVERY_ITEM.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~INITIALIZE_DELIVERY.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~ITEM_DELETION.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~PUBLISH_DELIVERY_ITEM.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~READ_DELIVERY.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~SAVE_AND_PUBLISH_BEFORE_OUTPUT.

endmethod.


METHOD if_ex_le_shp_delivery_proc~save_and_publish_document.

ENDMETHOD.


METHOD if_ex_le_shp_delivery_proc~save_document_prepare.
************************************************************************
* CLASS      :  ZCL_IM_IM_SERIAL_ASSIGN                                *
* TITLE      :  EHQ_LRD_Serial Batch Assignment                        *
* DEVELOPER  :  Salman Zahir                                           *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0340                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Copy Serial number and batch information from outbound *
*                replenishment delivery from EHQ plant to virtual      *
*                delivery created from LRD plant                       *
*                                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 18-JUL-2016 U033959  E1DK919123 INITIAL DEVELOPMENT                  *
* =========== ======== ========== =====================================*
* 16-AUG-2016 U033959  E1DK919123 Defect D3_3025                       *
*                                 If the delivery is getting           *
*                                 created through EDD_340              *
*                                 then delete the log for              *
*                                 incompleteness by clearing           *
*                                 table XVBUV                          *
* =========== ======== ========== =====================================*
* 07-SEP-2018 SMUKHER4 E1DK938696: Defect# 7029                        *
*                                  Batch numbers are not transferring  *
*                                  properly to the virtual delivery on *
*                                  ZKB orders                          *
* 06-AUG-2019 U101779  E2DK924833: Defect# 9883: Fix Serial issue      *
* =========== ======== ========== =====================================*



*--CONSTANTS---------------------------------------------------------*
  CONSTANTS : lc_otc_edd_0340 TYPE z_enhancement VALUE 'OTC_EDD_0340', " Enhancement No.
              lc_enh_id       TYPE z_criteria    VALUE 'NULL',         " Enh. Criteria
              lc_criteria     TYPE z_criteria    VALUE 'KZBEW',        " Enh. Criteria
              lc_pstyv        TYPE z_criteria    VALUE 'PSTYV',        " Delivery item category
              lc_posnr        TYPE z_criteria    VALUE 'BATCH_POSNR',  " Batch split line item number
              lc_delv_8       TYPE z_criteria    VALUE 'VGABE',        " Transaction/event type, purchase order history
              lc_delv_note_l  TYPE z_criteria    VALUE 'BEWTP',        " Purchase Order History Category
              lc_trtyp        TYPE trtyp         VALUE 'H',            " Transaction type
*--->> Begin of insert for Defect 9883 by U101779 on 06 Aug 2019 - E2DK924833
              lc_i            TYPE updkz_d       VALUE 'I',            "Update indicator
*<<--- End of insert for Defect 9883 by U101779 on on 06 Aug 2019 - E2DK924833
* ---> Begin of Insert for Defect D3_3025 by U033959 on 16-AUG-2016
              lc_sapmv50a     TYPE syrepid       VALUE 'SAPMV50A',          " Main program
              lc_xvbuv_stack  TYPE char17        VALUE '(SAPMV50A)XVBUV[]', " XVBUV from memory stack
              lc_fdnam        TYPE z_criteria    VALUE 'FDNAM',             " Document field name
              lc_tbnam        TYPE z_criteria    VALUE 'TBNAM',             " Table for documents in sales and distribution
              lc_fehgr        TYPE z_criteria    VALUE 'FEHGR',             " Incompletion procedure for sales document
              lc_statg        TYPE z_criteria    VALUE 'STATG'.             " Status group
* <--- End of Insert for Defect D3_3025 by U033959 on 16-AUG-2016

*--TYPES-------------------------------------------------------------*
  TYPES : BEGIN OF lty_pstyv,
            sign   TYPE tvarv_sign, " ABAP: ID: I/E (include/exclude values)
            option TYPE tvarv_opti, " ABAP: Selection option (EQ/BT/CP/...)
            low    TYPE pstyv_vl,   " Transaction Code
            high   TYPE pstyv_vl,   " Transaction Code
          END OF lty_pstyv,
          BEGIN OF lty_plant_mat,
            matnr TYPE matnr,       " Material Number
            werks TYPE werks_d,     " Plant
            sernp TYPE serail,      " Serial Number Profile
          END OF lty_plant_mat,
          BEGIN OF lty_material,
            matnr TYPE matnr,       " Material Number
            xchpf TYPE xchpf,       " Batch management requirement indicator
          END OF lty_material,
          BEGIN OF lty_vbep,
            vbeln TYPE vbeln_va,    " Sales Document
            posnr TYPE posnr_va,    " Sales Document Item
            etenr TYPE etenr,       " Delivery Schedule Line Number
            banfn TYPE banfn,       " Purchase Requisition Number
            bnfpo TYPE bnfpo,       " Item Number of Purchase Requisition
          END OF lty_vbep,
          BEGIN OF lty_eban,
            banfn TYPE banfn,       " Purchase Requisition Number
            bnfpo TYPE bnfpo,       " Item Number of Purchase Requisition
            ebeln TYPE bstnr,       " Purchase Order Number
            ebelp TYPE bstpo,       " Purchase Order Item Number
          END OF lty_eban,
          BEGIN OF lty_lips,
            vbeln TYPE vbeln_vl,    " Delivery
            posnr TYPE posnr_vl,    " Delivery Item
            matnr TYPE matnr,       " Material Number
            charg TYPE charg_d,     " Batch Number
            lfimg TYPE lfimg,       " Actual quantity delivered (in sales units)
            ntgew TYPE ntgew_15,    " Net weight
            brgew TYPE brgew_15,    " Gross weight
            volum TYPE volum_15,    " Volume
            lgmng TYPE lgmng,       " Actual quantity delivered in stockkeeping units
            vgbel TYPE vgbel,       " Document number of the reference document
            vgpos TYPE vgpos,       " Item number of the reference item
            kzbew TYPE kzbew,       " Movement Indicator
          END OF lty_lips,
          BEGIN OF lty_ser01,
            obknr   TYPE objknr,    " Object list number
            lief_nr TYPE vbeln_vl,  " Delivery
            posnr   TYPE posnr_vl,  " Delivery Item
          END OF lty_ser01,
          BEGIN OF lty_objk,
            obknr TYPE objknr,      " Object list number
            obzae TYPE objza,       " Object list counters
            sernr TYPE gernr,       " Serial Number
          END OF lty_objk,
          BEGIN OF lty_delv_sto,
            vbeln TYPE mblnr,       " Number of Material Document
          END OF lty_delv_sto,
* ---> Begin of Insert for Defect D3_3025 by U033959 on 16-AUG-2016
          lty_tt_vbuvvb TYPE STANDARD TABLE OF vbuvvb.  " Structure for Internal Table XVBUV
* <--- End of Insert for Defect D3_3025 by U033959 on 16-AUG-2016

*--TABLES------------------------------------------------------------*

  DATA : li_status         TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status table
         li_plant_mat      TYPE STANDARD TABLE OF lty_plant_mat,   " Plant data for material
         li_lips_temp      TYPE STANDARD TABLE OF lipsvb,          " Delivery items
         li_schdlline      TYPE STANDARD TABLE OF lty_vbep,        " Sales Document: Schedule Line Data
         li_schdlline_temp TYPE STANDARD TABLE OF lty_vbep,        " Sales Document: Schedule Line Data
         li_purch_req      TYPE STANDARD TABLE OF lty_eban,        " Purchase Requisition
         li_purch_req_temp TYPE STANDARD TABLE OF lty_eban,        " Purchase Requisition
         li_delv_item      TYPE STANDARD TABLE OF lty_lips,        " Delivery items
         li_delv_item1     TYPE STANDARD TABLE OF lty_lips,        " Delivery items
         li_delv_item_temp TYPE STANDARD TABLE OF lty_lips,        " Delivery items
         li_delv_slno      TYPE STANDARD TABLE OF lty_ser01,       " Serial number for delivery
         li_delv_slno_temp TYPE STANDARD TABLE OF lty_ser01,       " Serial number for delivery
         li_serial         TYPE STANDARD TABLE OF lty_objk,        " Serial numbers
         li_material       TYPE STANDARD TABLE OF lty_material,    " Material master
         li_xlips_temp     TYPE STANDARD TABLE OF lipsvb,          " Reference structure for XLIPS/YLIPS
         li_delv_sto       TYPE STANDARD TABLE OF lty_delv_sto,    " Purchase order history
         li_delv_sto_temp  TYPE STANDARD TABLE OF lty_delv_sto,    " Purchase order history
         li_sernos         TYPE sernr_t,                           " Serial number
* ---> Begin of Insert for Defect D3_3025 by U033959 on 16-AUG-2016
         li_callstack      TYPE abap_callstack,           " Abap memory stack
         li_xvbuv          TYPE STANDARD TABLE OF vbuvvb. " Sales Document Incompletion log
* <--- End of Insert for Defect D3_3025 by U033959 on 16-AUG-2016

*--VARIABLES---------------------------------------------------------*
  DATA : lv_mvt_indicator TYPE kzbew,     " Movement Indicator
         lv_index         TYPE sy-tabix,  " Index of Internal Tables
         lv_quantity      TYPE anzser,    " Number of Serial Numbers/Pieces of Equipment to be Created
         lv_anzsn         TYPE anzsn,     " Number of serial numbers
         lv_tabix         TYPE sy-tabix,  " Index of Internal Tables
         lv_vgabe         TYPE vgabe,     " Transaction/event type, purchase order history
         lv_bewtp         TYPE bewtp,     " Purchase Order History Category
         lv_lines         TYPE int4,      " Lines of type Integers
         lv_posnr         TYPE int4,      " POSNR for batch split line items
         lv_posnr1        TYPE int4,      " POSNR for batch split line items
* ---> Begin of Insert for Defect D3_3025 by U033959 on 16-AUG-2016
         lv_tbnam         TYPE tbnam_vb,  " Table for documents in sales and distribution
         lv_fdnam         TYPE fdnam_vb,  " Document field name
         lv_fehgr         TYPE fehgr,     " Incompletion procedure for sales document
         lv_statg         TYPE statg.     " Status group
* <--- End of Insert for Defect D3_3025 by U033959 on 16-AUG-2016

*--WORK AREA---------------------------------------------------------*
  DATA : lwa_ct_log    TYPE shp_badi_error_log. " Error Log


*--RANGES------------------------------------------------------------*
  DATA : lr_item_cat       TYPE RANGE OF pstyv_vl. " Delivery item category

*--FIELD SYMBOLS-----------------------------------------------------*
  FIELD-SYMBOLS : <lfs_plant_mat>  TYPE lty_plant_mat,   " Plant data for material
                  <lfs_pstyv>      TYPE lty_pstyv,       " Item category
                  <lfs_status>     TYPE zdev_enh_status, " Enhancement Status
                  <lfs_material>   TYPE lty_material,    " Material master
                  <lfs_xlikp>      TYPE likpvb,          " Reference structure for XLIKP/YLIKP
                  <lfs_xlips>      TYPE lipsvb,          " Reference structure for XLIPS/YLIPS
                  <lfs_lips_temp>  TYPE lipsvb,          " Reference structure for XLIPS/YLIPS
                  <lfs_schdlline>  TYPE lty_vbep,        " Sales Document: Schedule Line Data
                  <lfs_purch_req>  TYPE lty_eban,        " Purchase Requisition
                  <lfs_delv_item>  TYPE lty_lips,        " Delivery items
                  <lfs_delv_item1> TYPE lty_lips,        " Delivery items
                  <lfs_delv_item2> TYPE lty_lips,        " Delivery items
                  <lfs_delv_slno>  TYPE lty_ser01,       " Serial number for delivery
                  <lfs_serial>     TYPE lty_objk,        " Serial number
                  <lfs_sernos>     TYPE e1rmsno,         " Repetitive Manufacturing Serial Number
* ---> Begin of Insert for Defect D3_3025 by U033959 on 16-AUG-2016
                  <lfs_xvbuv>      TYPE lty_tt_vbuvvb. "TYPE ANY TABLE.      " Abap memory stack
* <--- End of Insert for Defect D3_3025 by U033959 on 16-AUG-2016


  IF if_trtyp = lc_trtyp.
* Checking whether enhancement is active or not from EMI Tool.
    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
      EXPORTING
        iv_enhancement_no = lc_otc_edd_0340
      TABLES
        tt_enh_status     = li_status.

    SORT li_status BY criteria active.

* Check if enhancement is active on EMI
    READ TABLE li_status WITH KEY criteria = lc_enh_id
                                    active = abap_true
                          BINARY SEARCH
                          TRANSPORTING NO FIELDS.
    IF sy-subrc IS INITIAL.

* Loop at EMI records to build range table for active item categories
      LOOP AT li_status ASSIGNING <lfs_status>.
        IF <lfs_status>-active = abap_true.
          CASE <lfs_status>-criteria.

            WHEN lc_pstyv.
              APPEND INITIAL LINE TO lr_item_cat ASSIGNING <lfs_pstyv>.
              <lfs_pstyv>-sign   = <lfs_status>-sel_sign.
              <lfs_pstyv>-option = <lfs_status>-sel_option.
              <lfs_pstyv>-low    = <lfs_status>-sel_low.
              UNASSIGN <lfs_pstyv>.
            WHEN lc_criteria.
              lv_mvt_indicator = <lfs_status>-sel_low.
            WHEN lc_posnr.
              lv_posnr = <lfs_status>-sel_low.
            WHEN lc_delv_8.
              lv_vgabe = <lfs_status>-sel_low.
            WHEN lc_delv_note_l.
              lv_bewtp = <lfs_status>-sel_low.
* ---> Begin of Insert for Defect D3_3025 by U033959 on 16-AUG-2016
            WHEN lc_tbnam.
              lv_tbnam = <lfs_status>-sel_low.
            WHEN lc_fdnam.
              lv_fdnam = <lfs_status>-sel_low.
            WHEN lc_fehgr.
              lv_fehgr = <lfs_status>-sel_low.
            WHEN lc_statg.
              lv_statg = <lfs_status>-sel_low.
* <--- End of Insert for Defect D3_3025 by U033959 on 16-AUG-2016
            WHEN OTHERS.
*          do nothing
          ENDCASE.
        ENDIF. " IF <lfs_status>-active = abap_true
      ENDLOOP. " LOOP AT li_status ASSIGNING <lfs_status>


* Fetch plant data for material
      li_lips_temp = ct_xlips.
      SORT li_lips_temp BY matnr werks.
      DELETE ADJACENT DUPLICATES FROM li_lips_temp COMPARING matnr werks.
      IF li_lips_temp IS NOT INITIAL.
        SELECT matnr " Material Number
               werks " Plant
               sernp " Serial Number Profile
          FROM marc  " Plant Data for Material
          INTO TABLE li_plant_mat
          FOR ALL ENTRIES IN li_lips_temp
          WHERE matnr = li_lips_temp-matnr
            AND werks = li_lips_temp-werks.
        IF sy-subrc IS INITIAL.
          SORT li_plant_mat BY matnr werks.
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF li_lips_temp IS NOT INITIAL

* Fetch material master
      li_lips_temp[] = ct_xlips[].
      SORT li_lips_temp BY matnr.
      DELETE ADJACENT DUPLICATES FROM li_lips_temp COMPARING matnr.
      IF li_lips_temp IS NOT INITIAL.
        SELECT matnr     " Material Number
               xchpf     " Batch management requirement indicator
               FROM mara " General Material Data
               INTO TABLE li_material
               FOR ALL ENTRIES IN li_lips_temp
               WHERE matnr = li_lips_temp-matnr.
        IF sy-subrc IS INITIAL .
          SORT li_material BY matnr.
          CLEAR li_lips_temp[].
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF li_lips_temp IS NOT INITIAL

* Fetch schedule lines SO lines
      li_lips_temp = ct_xlips.
      SORT li_lips_temp BY vgbel vgpos.
      DELETE ADJACENT DUPLICATES FROM li_lips_temp COMPARING vgbel vgpos.
      IF li_lips_temp IS NOT INITIAL.
        SELECT vbeln " Sales Document
               posnr " Sales Document Item
               etenr " Delivery Schedule Line Number
               banfn " Purchase Requisition Number
               bnfpo " Item Number of Purchase Requisition
         FROM vbep   " Sales Document: Schedule Line Data
         INTO TABLE li_schdlline
         FOR ALL ENTRIES IN li_lips_temp
         WHERE vbeln = li_lips_temp-vgbel
           AND posnr = li_lips_temp-vgpos.
        IF sy-subrc = 0.
          SORT li_schdlline BY vbeln posnr.
          li_schdlline_temp = li_schdlline.
          SORT li_schdlline_temp BY banfn bnfpo.
          DELETE ADJACENT DUPLICATES FROM li_schdlline_temp COMPARING banfn bnfpo.
          IF li_schdlline_temp IS NOT INITIAL.

            SELECT banfn " Purchase Requisition Number
                   bnfpo " Item Number of Purchase Requisition
                   ebeln " Purchase Order Number
                   ebelp " Purchase Order Item Number
              FROM eban  " Purchase Requisition
              INTO TABLE li_purch_req
              FOR ALL ENTRIES IN li_schdlline_temp
              WHERE banfn = li_schdlline_temp-banfn
                AND bnfpo = li_schdlline_temp-bnfpo.
            IF sy-subrc = 0.
              CLEAR li_schdlline_temp.
              SORT li_purch_req BY banfn bnfpo.
              li_purch_req_temp = li_purch_req.
              SORT li_purch_req_temp BY ebeln.
              DELETE ADJACENT DUPLICATES FROM li_purch_req_temp COMPARING ebeln.
              IF li_purch_req_temp IS NOT INITIAL.

* Find the delivery for the STO
                SELECT belnr     " Number of Material Document
                       FROM ekbe " History per Purchasing Document
                       INTO TABLE li_delv_sto
                       FOR ALL ENTRIES IN li_purch_req_temp
                       WHERE ebeln = li_purch_req_temp-ebeln
                         AND vgabe = lv_vgabe
                         AND bewtp = lv_bewtp.
                IF sy-subrc = 0.
                  SORT li_delv_sto BY vbeln.
                  li_delv_sto_temp = li_delv_sto.
                  SORT li_delv_sto_temp BY vbeln.
                  DELETE ADJACENT DUPLICATES FROM li_delv_sto_temp COMPARING vbeln.
                  IF li_delv_sto_temp IS NOT INITIAL.
* Fetch the delivery line items
                    SELECT vbeln " Delivery
                           posnr " Delivery Item
                           matnr " Material Number
                           charg " Batch Number
                           lfimg " Actual quantity delivered (in sales units)
                           ntgew " Net weight
                           brgew " Gross weight
                           volum " Volume
                           lgmng " Actual quantity delivered in stockkeeping units
                           vgbel " Document number of the reference document
                           vgpos " Item number of the reference item
                           kzbew " Movement Indicator
                      FROM lips  " SD document: Delivery: Item data
                      INTO TABLE li_delv_item
                       FOR ALL ENTRIES IN li_delv_sto_temp
                       WHERE vbeln = li_delv_sto_temp-vbeln.
                    IF sy-subrc IS INITIAL.
                      CLEAR li_purch_req_temp.
                      DELETE li_delv_item WHERE kzbew <> lv_mvt_indicator.
                      DELETE li_delv_item WHERE lfimg IS INITIAL. " Defect 7029
                      SORT li_delv_item BY vgbel vgpos.
                      li_delv_item_temp = li_delv_item.
                      SORT li_delv_item_temp BY vbeln posnr.
                      DELETE ADJACENT DUPLICATES FROM li_delv_item_temp COMPARING vbeln posnr.
                      IF li_delv_item_temp IS NOT INITIAL.
*  Fetch the assigned serial numbers
                        SELECT obknr   " Object list number
                               lief_nr " Delivery
                               posnr   " Delivery Item
                           FROM ser01  " Document Header for Serial Numbers for Delivery
                           INTO TABLE li_delv_slno
                           FOR ALL ENTRIES IN li_delv_item_temp
                           WHERE lief_nr = li_delv_item_temp-vbeln
                             AND posnr   = li_delv_item_temp-posnr.
                        IF sy-subrc IS INITIAL .
                          SORT li_delv_slno BY lief_nr posnr.
                          CLEAR li_delv_item_temp.
                          li_delv_slno_temp = li_delv_slno.
                          SORT li_delv_slno_temp BY obknr.
                          DELETE ADJACENT DUPLICATES FROM li_delv_slno_temp COMPARING obknr.
                          IF li_delv_slno_temp IS NOT INITIAL.
                            SELECT obknr " Object list number
                                   obzae " Object list counters
                                   sernr " Serial Number
                              FROM objk  " Plant Maintenance Object List
                              INTO TABLE li_serial
                              FOR ALL ENTRIES IN li_delv_slno_temp
                              WHERE obknr = li_delv_slno_temp-obknr.
                            IF sy-subrc IS INITIAL.
                              SORT li_serial BY obknr.
                            ENDIF. " IF sy-subrc IS INITIAL
                          ENDIF. " IF li_delv_slno_temp IS NOT INITIAL
                        ENDIF. " IF sy-subrc IS INITIAL
                      ENDIF. " IF li_delv_item_temp IS NOT INITIAL
                    ENDIF. " IF sy-subrc IS INITIAL
                  ENDIF. " IF li_delv_sto_temp IS NOT INITIAL
                ENDIF. " IF sy-subrc = 0
              ENDIF. " IF li_purch_req_temp IS NOT INITIAL
            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF li_schdlline_temp IS NOT INITIAL
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF li_lips_temp IS NOT INITIAL

* Loop into the deivery lines to assing the batch and serial number
      LOOP AT ct_xlips ASSIGNING <lfs_xlips>.

        AT NEW vbeln.
          lv_posnr1 = lv_posnr.
        ENDAT.
* Check if the item category is maintained in EMI tool
        IF lr_item_cat IS NOT INITIAL AND
            <lfs_xlips>-pstyv IN lr_item_cat.
          READ TABLE li_schdlline ASSIGNING <lfs_schdlline> WITH KEY vbeln = <lfs_xlips>-vgbel
                                                                     posnr = <lfs_xlips>-vgpos
                                                                     BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            READ TABLE li_purch_req ASSIGNING <lfs_purch_req> WITH KEY banfn = <lfs_schdlline>-banfn
                                                                       bnfpo = <lfs_schdlline>-bnfpo
                                                                       BINARY SEARCH.
            IF sy-subrc IS INITIAL.
              READ TABLE li_delv_item ASSIGNING <lfs_delv_item> WITH KEY vgbel = <lfs_purch_req>-ebeln
                                                                         vgpos = <lfs_purch_req>-ebelp
                                                                         BINARY SEARCH.
              IF sy-subrc IS INITIAL.
                lv_tabix = sy-tabix.

* Serial number assignment logic
                READ TABLE li_plant_mat ASSIGNING <lfs_plant_mat> WITH KEY matnr = <lfs_xlips>-matnr
                                                                           werks = <lfs_xlips>-werks
                                                                           BINARY SEARCH.
* Check if material has a serial number profile
                IF sy-subrc IS INITIAL AND <lfs_plant_mat>-sernp IS NOT INITIAL.
                  READ TABLE li_delv_slno ASSIGNING <lfs_delv_slno> WITH KEY lief_nr = <lfs_delv_item>-vbeln
                                                                             posnr   = <lfs_delv_item>-posnr
                                                                             BINARY SEARCH.
                  IF sy-subrc IS INITIAL.
                    READ TABLE li_serial WITH KEY obknr = <lfs_delv_slno>-obknr
                                                    TRANSPORTING NO FIELDS
                                                    BINARY SEARCH.
                    IF sy-subrc IS INITIAL.
                      lv_index = sy-tabix.
                      LOOP AT li_serial ASSIGNING <lfs_serial> FROM lv_index.
                        IF <lfs_serial>-obknr <> <lfs_delv_slno>-obknr.
                          EXIT.
                        ELSE. " ELSE -> IF <lfs_serial>-obknr <> <lfs_delv_slno>-obknr
                          APPEND INITIAL LINE TO li_sernos ASSIGNING <lfs_sernos>.
                          <lfs_sernos>-sernr = <lfs_serial>-sernr.
                          UNASSIGN <lfs_sernos>.
                        ENDIF. " IF <lfs_serial>-obknr <> <lfs_delv_slno>-obknr
                      ENDLOOP. " LOOP AT li_serial ASSIGNING <lfs_serial> FROM lv_index
                      READ TABLE ct_xlikp ASSIGNING <lfs_xlikp> WITH KEY vbeln = <lfs_xlips>-vbeln.
                      IF sy-subrc IS INITIAL.
                        lv_quantity = <lfs_xlips>-lfimg.
* Call FM SERNR_ADD_TO_LS to add serial number to line item

*--->> Begin of insert for Defect 9883 by U101779 on 06 Aug 2019 - E2DK924833
                        IF <lfs_xlips>-updkz = lc_i.   "Update indicator
*<<--- End of insert for Defect 9883 by U101779 on on 06 Aug 2019 - E2DK924833
                          CALL FUNCTION 'SERNR_ADD_TO_LS'
                            EXPORTING
                              profile               = <lfs_xlips>-serail
                              material              = <lfs_xlips>-matnr
                              quantity              = lv_quantity
                              document              = <lfs_xlips>-vbeln
                              item                  = <lfs_xlips>-posnr
                              debitor               = <lfs_xlikp>-kunnr
                              vbtyp                 = <lfs_xlikp>-vbtyp
                            IMPORTING
                              anzsn                 = lv_anzsn
                            TABLES
                              sernos                = li_sernos
                            EXCEPTIONS
                              konfigurations_error  = 1
                              serialnumber_errors   = 2
                              serialnumber_warnings = 3
                              no_profile_operation  = 4
                              OTHERS                = 5.
*--->> Begin of insert for Defect 9883 by U101779 on 06 Aug 2019 - E2DK924833
                        ENDIF.
*<<--- End of insert for Defect 9883 by U101779   on 06 Aug 2019 - E2DK924833
                        IF sy-subrc = 0.
                          <lfs_xlips>-anzsn = lv_anzsn.
                          CLEAR li_sernos.
                        ELSE. " ELSE -> IF sy-subrc = 0
                          lwa_ct_log-vbeln = <lfs_xlips>-vbeln.
                          lwa_ct_log-posnr = <lfs_xlips>-posnr.
                          lwa_ct_log-msgty = sy-msgty.
                          lwa_ct_log-msgid = sy-msgid.
                          lwa_ct_log-msgno = sy-msgno.
                          lwa_ct_log-msgv1 = <lfs_serial>-sernr.
                          APPEND lwa_ct_log TO ct_log.
                          CLEAR lwa_ct_log.
                        ENDIF. " IF sy-subrc = 0
                      ENDIF. " IF sy-subrc IS INITIAL
                    ENDIF. " IF sy-subrc IS INITIAL
                  ENDIF. " IF sy-subrc IS INITIAL
                ENDIF. " IF sy-subrc IS INITIAL AND <lfs_plant_mat>-sernp IS NOT INITIAL

*  Batch number assignment logic
                READ TABLE li_material ASSIGNING <lfs_material> WITH KEY matnr = <lfs_xlips>-matnr
                                                                   BINARY SEARCH.
*  Check if material has batch number requirement indicaotr populated
                IF sy-subrc IS INITIAL AND <lfs_material>-xchpf IS NOT INITIAL.
                  IF lv_tabix IS NOT INITIAL.
                    LOOP AT li_delv_item ASSIGNING <lfs_delv_item1> FROM lv_tabix.
                      IF <lfs_delv_item1>-vgbel = <lfs_delv_item>-vgbel AND
                         <lfs_delv_item1>-vgpos = <lfs_delv_item>-vgpos.
                        APPEND INITIAL LINE TO li_delv_item1 ASSIGNING <lfs_delv_item2>.
                        <lfs_delv_item2>-vbeln = <lfs_delv_item1>-vbeln.
                        <lfs_delv_item2>-posnr = <lfs_delv_item1>-posnr.
                        <lfs_delv_item2>-matnr = <lfs_delv_item1>-matnr.
                        <lfs_delv_item2>-charg = <lfs_delv_item1>-charg.
                        <lfs_delv_item2>-lfimg = <lfs_delv_item1>-lfimg.
                        <lfs_delv_item2>-vgbel = <lfs_delv_item1>-vgbel.
                        <lfs_delv_item2>-vgpos = <lfs_delv_item1>-vgpos.
                        <lfs_delv_item2>-ntgew = <lfs_delv_item1>-ntgew.
                        <lfs_delv_item2>-brgew = <lfs_delv_item1>-brgew.
                        <lfs_delv_item2>-volum = <lfs_delv_item1>-volum.
                        <lfs_delv_item2>-lgmng = <lfs_delv_item1>-lgmng.
                        UNASSIGN <lfs_delv_item2>.
                      ELSE. " ELSE -> IF <lfs_delv_item1>-vgbel = <lfs_delv_item>-vgbel AND
                        EXIT.
                      ENDIF. " IF <lfs_delv_item1>-vgbel = <lfs_delv_item>-vgbel AND
                    ENDLOOP. " LOOP AT li_delv_item ASSIGNING <lfs_delv_item1> FROM lv_tabix
                    CLEAR lv_tabix.
                  ENDIF. " IF lv_tabix IS NOT INITIAL
                  lv_lines = lines( li_delv_item1 ).
                  IF lv_lines EQ 1.
                    APPEND INITIAL LINE TO li_xlips_temp ASSIGNING <lfs_lips_temp>.
                    <lfs_lips_temp> = <lfs_xlips>.
                    <lfs_lips_temp>-charg = <lfs_delv_item>-charg.
                  ELSEIF lv_lines GT 1.
* Implement batch split logic
                    APPEND INITIAL LINE TO li_xlips_temp ASSIGNING <lfs_lips_temp>.
                    <lfs_lips_temp> = <lfs_xlips>.
                    MOVE : <lfs_lips_temp>-lfimg TO <lfs_lips_temp>-kcmeng,
                           <lfs_lips_temp>-ntgew TO <lfs_lips_temp>-kcntgew,
                           <lfs_lips_temp>-brgew TO <lfs_lips_temp>-kcbrgew,
                           <lfs_lips_temp>-volum TO <lfs_lips_temp>-kcvolum.
                    CLEAR : <lfs_lips_temp>-lfimg,
                            <lfs_lips_temp>-ntgew,
                            <lfs_lips_temp>-brgew,
                            <lfs_lips_temp>-volum,
                            <lfs_lips_temp>-lgmng.

                    DELETE li_delv_item1 WHERE charg IS INITIAL.
                    LOOP AT li_delv_item1 ASSIGNING <lfs_delv_item>.
                      APPEND INITIAL LINE TO li_xlips_temp ASSIGNING <lfs_lips_temp>.
                      <lfs_lips_temp> = <lfs_xlips>.
                      <lfs_lips_temp>-posnr = lv_posnr1.
                      MOVE <lfs_delv_item>-charg TO <lfs_lips_temp>-charg.
                      MOVE <lfs_delv_item>-lfimg TO <lfs_lips_temp>-lfimg.
                      MOVE <lfs_xlips>-posnr TO <lfs_lips_temp>-uecha.

                      MOVE : <lfs_delv_item>-ntgew TO <lfs_lips_temp>-ntgew,
                             <lfs_delv_item>-brgew TO <lfs_lips_temp>-brgew,
                             <lfs_delv_item>-volum TO <lfs_lips_temp>-volum,
                             <lfs_delv_item>-lgmng TO <lfs_lips_temp>-lgmng.

                      UNASSIGN <lfs_lips_temp>.
                      lv_posnr1 = lv_posnr1 + 10.
                    ENDLOOP. " LOOP AT li_delv_item1 ASSIGNING <lfs_delv_item>
*&-->Begin of delete for D3_OTC_EDD_0340 Defect# 7029 by SMUKHER4 on 07-Sep-2018
*&--Batch numbers are not getting cleared properly
*                    CLEAR li_delv_item1.
*&<--End of delete for D3_OTC_EDD_0340 Defect# 7029 by SMUKHER4 on 07-Sep-2018
                  ENDIF. " IF lv_lines EQ 1
*&-->Begin of insert for D3_OTC_EDD_0340 Defect# 7029 by SMUKHER4 on 07-Sep-2018
                  CLEAR li_delv_item1.
*&<--End of insert for D3_OTC_EDD_0340 Defect# 7029 by SMUKHER4 on 07-Sep-2018
                ELSE. " ELSE -> IF sy-subrc IS INITIAL AND <lfs_material>-xchpf IS NOT INITIAL
                  APPEND INITIAL LINE TO li_xlips_temp ASSIGNING <lfs_lips_temp>.
                  <lfs_lips_temp> = <lfs_xlips>.
*&-->Begin of insert for D3_OTC_EDD_0340 Defect# 7029 by SMUKHER4 on 07-Sep-2018
                  CLEAR li_delv_item1.
*&<--End of insert for D3_OTC_EDD_0340 Defect# 7029 by SMUKHER4 on 07-Sep-2018
                ENDIF. " IF sy-subrc IS INITIAL AND <lfs_material>-xchpf IS NOT INITIAL

              ENDIF. " IF sy-subrc IS INITIAL
            ENDIF. " IF sy-subrc IS INITIAL
          ENDIF. " IF sy-subrc IS INITIAL
        ENDIF. " IF lr_item_cat IS NOT INITIAL AND
      ENDLOOP. " LOOP AT ct_xlips ASSIGNING <lfs_xlips>

*  overwrite the data from the updated batch logic
      IF li_xlips_temp IS NOT INITIAL.
        ct_xlips[] = li_xlips_temp.
* ---> Begin of Insert for Defect D3_3025 by U033959 on 16-AUG-2016
* Delete incompleteness log after batch assignment
* Call stack is used to clear the log as XVBUV is not available
* as BADI parameter

        CALL FUNCTION 'SYSTEM_CALLSTACK'
          EXPORTING
            max_level = 0
          IMPORTING
            callstack = li_callstack.


        READ TABLE li_callstack TRANSPORTING NO FIELDS
                    WITH KEY mainprogram = lc_sapmv50a.
        IF sy-subrc IS INITIAL.
* Assign stack values to dynamic table
          ASSIGN (lc_xvbuv_stack) TO <lfs_xvbuv>.
* Assign to local table to delete reocrds. Records are not deleted
* directly for dynamic table as it would require to delete inside loop
          IF <lfs_xvbuv> IS ASSIGNED.
            li_xvbuv = <lfs_xvbuv>.
            IF lv_tbnam IS NOT INITIAL AND
               lv_fdnam IS NOT INITIAL AND
               lv_fehgr IS NOT INITIAL AND
               lv_statg IS NOT INITIAL.
              DELETE li_xvbuv WHERE tbnam = lv_tbnam AND
                                    fdnam = lv_fdnam AND
                                    fehgr = lv_fehgr AND
                                    statg = lv_statg.
            ENDIF. " IF lv_tbnam IS NOT INITIAL AND
* Reassigning dynamic table
            <lfs_xvbuv> = li_xvbuv.
          ENDIF. " IF <lfs_xvbuv> IS ASSIGNED
        ENDIF. " IF sy-subrc IS INITIAL
* <--- End of Insert for Defect D3_3025 by U033959 on 16-AUG-2016

      ENDIF. " IF li_xlips_temp IS NOT INITIAL

    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF if_trtyp = lc_trtyp

ENDMETHOD.
ENDCLASS.
