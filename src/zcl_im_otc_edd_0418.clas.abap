class ZCL_IM_OTC_EDD_0418 definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_LE_SHP_DELIVERY_PROC .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_OTC_EDD_0418 IMPLEMENTATION.


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


METHOD if_ex_le_shp_delivery_proc~delivery_final_check.
*&---------------------------------------------------------------------*
*& Method  IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_FINAL_CHECK
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_FINAL_CHECK        *
* TITLE      :  Multiple Deliveries created for STO exceed committed qty*
* DEVELOPER  :  Khushboo Mishra                                       *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D3_OTC_EDD_0418                                          *
*----------------------------------------------------------------------*
* DESCRIPTION: The enhancement should check the STO quantity and       *
* prevent delivery change if the cumulative delivery quantity exceeds  *
* STO quantity.                                                        *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 10-Aug-2018 U033632  E1DK938159 Initial Development STO quantity     *
*                                 check                                *
*&---------------------------------------------------------------------*
* 30-Aug-2018 ASK     E1DK938159 Defect 6989 , we have to take VTWEG,  *
*                                spart from LIPS not LIKP              *
*&---------------------------------------------------------------------*
* 02-Oct-2018 ASK     E1DK938939 Defect 7295 , Handle Multiple Delivery*
*                                case and also use UNIT conversion     *
*                                before comparing PO/Delivery Qty      *
*&---------------------------------------------------------------------*
  TYPES:
       BEGIN OF ty_ekbe,     " Structure for History per Purchasing Document
         ebeln TYPE ebeln,   " Purchasing Document Number
         ebelp TYPE ebelp,   " Item Number of Purchasing Document
         zekkn TYPE dzekkn,  " Sequential Number of Account Assignment
         vgabe TYPE vgabe,   " Transaction/event type, purchase order history
         gjahr TYPE mjahr,   " Material Document Year
         belnr TYPE mblnr,   " Number of Material Document
         buzei TYPE mblpo,   " Item in Material Document
         menge TYPE menge_d, " Quantity
         END OF ty_ekbe,

         BEGIN OF ty_ekpo,   " Structure for Purchasing Document Item
         ebeln TYPE ebeln,   " Purchasing Document Number
         ebelp TYPE ebelp,   " Item Number of Purchasing Document
         menge TYPE bstmg,   " Purchase Order Quantity
*--> Begin of insert for D3_OTC_EDD_0418_Defect# 7295 by ASK on 02-Oct-2018
         meins TYPE bstme, " UOm
*<-- End of insert for D3_OTC_EDD_0418_Defect# 7295 by ASK on 02-Oct-2018
         uebto TYPE  uebto, " Overdelivery Tolerance Limit
         END OF ty_ekpo,
* Begin of Defect 6989
         BEGIN OF ty_knvv,
           vtweg TYPE vtweg, " Distribution Channel
           spart TYPE spart, " Division
           uebto TYPE uebto, " Overdelivery Tolerance Limit
         END   OF ty_knvv,
* En of Defcet 6989
         ty_t_ekbe    TYPE STANDARD TABLE OF ty_ekbe, "History per Purchasing Document
         ty_t_ekpo    TYPE STANDARD TABLE OF ty_ekpo. "Purchasing Document Item
  DATA:
         li_enh_status     TYPE STANDARD TABLE OF  zdev_enh_status, " Internal table for Enhancement Status
         li_knvv           TYPE STANDARD TABLE OF ty_knvv,          " Defect 6989
         lwa_knvv          TYPE ty_knvv,                            " Defect 6989
         li_ekbe           TYPE ty_t_ekbe,                          " Internal table for History per Purchasing Document
         lwa_ekbe          TYPE ty_ekbe,                            " Workarea for History per Purchasing Document
         li_ekpo           TYPE ty_t_ekpo,                          " Internal table for Purchasing Document Item
         lwa_ekpo          TYPE ty_ekpo,                            " Workarea for Purchasing Document Item
         lv_ekbe_qty       TYPE menge_d,                            " Quantity
         lv_total_del_qty  TYPE menge_d,                            " Quantity
         lv_ekpo_qty       TYPE bstmg,                              " Purchase Order Quantity
         lwa_ylips         TYPE lipsvb,                             " Reference structure for XLIPS/YLIPS
         lwa_likp          TYPE likpvb,                             " Reference structure for XLIKP/YLIKP
         lwa_vbpa          TYPE vbpavb,                             " Reference structure for XLIKP/YLIKP
         lwa_xlips         TYPE lipsvb,                             " Reference structure for XLIPS/YLIPS
         lv_text1          TYPE char100,                            " text for error message
*--> Begin of insert for D3_OTC_EDD_0418_Defect# 7295 by ASK on 02-Oct-2018
         lv_lfimg          TYPE lfimg, " Actual quantity delivered (in sales units)
*<-- End of insert for D3_OTC_EDD_0418_Defect# 7295 by ASK on 02-Oct-2018
*         lv_uebto          TYPE uebto,                              " Overdelivery Tolerance Limit  " Defect 6989
         lv_aufer          TYPE aufer,      " A sales order is required as basis for delivery
         lv_shipto         TYPE kunnr,      " Customer Number
         lv_flag           TYPE char1,      " Flag of type CHAR1
         li_tmp_xlips      TYPE shp_lips_t. "Delivery Item Upwardly Compatible

*Local constant Declaration
  CONSTANTS :
            lc_enhancement_no TYPE z_enhancement VALUE 'OTC_EDD_0418', " Enhancement No.
            lc_eight          TYPE char1         VALUE '8',            " Eight of type CHAR1
            lc_comma          TYPE char1         VALUE ',',            " Comma of type CHAR1
            lc_null_418       TYPE z_criteria    VALUE 'NULL',         " Enh. Criteria
            lc_zero           TYPE char1         VALUE '0',            " Zero of type CHAR1
            lc_u              TYPE updkz_d       VALUE 'U',            " Update indicator
            lc_i              TYPE updkz_d       VALUE 'I',            " Update indicator
            lc_ship_to        TYPE parvw         VALUE 'WE'.           " Partner Function

  FIELD-SYMBOLS:
            <lfs_xlips>       TYPE lipsvb. " Reference structure for XLIPS/YLIPS
  REFRESH: li_enh_status,
           li_ekpo,
           li_ekbe.
*Clear local work area and variables
  CLEAR: lwa_likp,
         lwa_vbpa,
         lwa_xlips,
*         lv_uebto,   " Defect 6989
         lv_text1.


*Get constant values from the EMI table
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enhancement_no
    TABLES
      tt_enh_status     = li_enh_status.
  DELETE li_enh_status WHERE active = abap_false.
  READ TABLE li_enh_status WITH KEY criteria = lc_null_418
                                   TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
** * Read Sales Area
    READ TABLE it_xlikp INTO lwa_likp INDEX 1.

    IF sy-subrc = 0.
* Read Ship to Party
      READ TABLE it_xvbpa INTO lwa_vbpa WITH KEY parvw = lc_ship_to.
      IF sy-subrc = 0.
* Get tolerence label
        SELECT vtweg spart uebto " Overdelivery Tolerance Limit
        FROM knvv                " Customer Master Sales Data
        INTO TABLE li_knvv       " Defect 6989
        WHERE kunnr = lwa_vbpa-kunnr
        AND   vkorg = lwa_likp-vkorg.

        IF sy-subrc EQ 0.
          SORT li_knvv BY vtweg spart. " Defect 6989
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc = 0


* Trigger only for Outbound Delivery
      CHECK lwa_likp-vbtyp = 'J'.
* Check the Delivery type
      SELECT SINGLE aufer " A sales order is required as basis for delivery
             FROM tvlk    " Delivery Types
             INTO lv_aufer
             WHERE lfart = lwa_likp-lfart.
      IF sy-subrc = 0.
        CHECK lv_aufer NE 'L'.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0
*Get SD document: Delivery: Item data
    READ TABLE it_xlips ASSIGNING <lfs_xlips> INDEX 1.
    IF <lfs_xlips> IS ASSIGNED.
*Get Purchasing Document Item
      SELECT       ebeln " Purchasing Document Number
                   ebelp " Item Number of Purchasing Document
                   menge " Purchase Order Quantity
*--> Begin of insert for D3_OTC_EDD_0418_Defect# 7295 by ASK on 02-Oct-2018
                   meins " Purchase Order Unit of Measure
*<-- End of insert for D3_OTC_EDD_0418_Defect# 7295 by ASK on 02-Oct-2018
                   uebto " Overdelivery Tolerance Limit
      FROM ekpo          " Purchasing Document Item
      INTO TABLE li_ekpo
      WHERE ebeln = <lfs_xlips>-vgbel.
      IF sy-subrc = 0.
        SORT li_ekpo BY ebeln ebelp.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF <lfs_xlips> IS ASSIGNED

    li_tmp_xlips = it_xlips.
    IF li_tmp_xlips IS NOT INITIAL.
      SORT li_tmp_xlips BY vgbel. .
      DELETE ADJACENT DUPLICATES FROM li_tmp_xlips COMPARING vgbel.
*Get History per Purchasing Document
      SELECT      ebeln " Purchasing Document Number
                  ebelp " Item Number of Purchasing Document
                  zekkn " Sequential Number of Account Assignment
                  vgabe " Transaction/event type, purchase order history
                  gjahr " Material Document Year
                  belnr " Number of Material Document
                  buzei " Item in Material Document
                  menge " Quantity
      FROM ekbe         " History per Purchasing Document
      INTO TABLE li_ekbe
      FOR ALL ENTRIES IN li_tmp_xlips
      WHERE ebeln = li_tmp_xlips-vgbel
      AND   vgabe = lc_eight.
      IF sy-subrc EQ 0.
        SORT li_ekbe BY ebeln ebelp.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF li_tmp_xlips IS NOT INITIAL


*--> Begin of insert for D3_OTC_EDD_0418_Defect# 7295 by ASK on 02-Oct-2018
    LOOP AT it_xlikp INTO lwa_likp.
      CLEAR lv_text1.
* Consolidate batch spli items.
      li_tmp_xlips = it_xlips.
      DELETE li_tmp_xlips WHERE vbeln NE lwa_likp-vbeln.
*<-- End of insert for D3_OTC_EDD_0418_Defect# 7295 by ASK on 02-Oct-2018
      LOOP AT li_tmp_xlips ASSIGNING <lfs_xlips>.
*


        IF <lfs_xlips>-uecha IS NOT INITIAL.
          CLEAR <lfs_xlips>-posnr.
        ELSE. " ELSE -> IF <lfs_xlips>-uecha IS NOT INITIAL
* Search for Batch split items

          LOOP AT it_xlips INTO lwa_xlips
*--> Begin of insert for D3_OTC_EDD_0418_Defect# 7295 by ASK on 02-Oct-2018
            WHERE   vbeln = lwa_likp-vbeln
*<-- End of insert for D3_OTC_EDD_0418_Defect# 7295 by ASK on 02-Oct-2018
              AND   uecha =  <lfs_xlips>-posnr.

            <lfs_xlips>-lfimg = <lfs_xlips>-lfimg + lwa_xlips-lfimg.
          ENDLOOP. " LOOP AT it_xlips INTO lwa_xlips
        ENDIF. " IF <lfs_xlips>-uecha IS NOT INITIAL
      ENDLOOP. " LOOP AT li_tmp_xlips ASSIGNING <lfs_xlips>


* Delete Batch spli items.

      DELETE li_tmp_xlips WHERE posnr IS INITIAL.

      LOOP AT li_tmp_xlips INTO lwa_xlips. "New data/Current data
        IF lwa_xlips-updkz = lc_u OR lwa_xlips-updkz = lc_i.
*Reading old data for delivery item
          CLEAR lwa_ylips.
          READ TABLE it_ylips  INTO lwa_ylips WITH KEY vbeln = lwa_xlips-vbeln "Old data
                                                       posnr = lwa_xlips-posnr.
*Checking if quantity value changed for item or not by comparing new data with old one
          IF ( sy-subrc = 0 AND
            lwa_xlips-lfimg NE lwa_ylips-lfimg )
            OR sy-subrc NE 0.

* Calculate the PO qty
            CLEAR :lv_ekbe_qty,
                   lv_ekpo_qty.
            LOOP AT li_ekbe INTO lwa_ekbe WHERE ebeln = lwa_xlips-vgbel
                                            AND ebelp = lwa_xlips-vgpos.
              IF lwa_xlips-updkz = lc_u.
                IF  lwa_xlips-vbeln NE lwa_ekbe-belnr.
                  lv_ekbe_qty = lv_ekbe_qty + lwa_ekbe-menge.
                ENDIF. " IF lwa_xlips-vbeln NE lwa_ekbe-belnr
              ELSE. " ELSE -> IF lwa_xlips-updkz = lc_u
                lv_ekbe_qty = lv_ekbe_qty + lwa_ekbe-menge.
              ENDIF. " IF lwa_xlips-updkz = lc_u
            ENDLOOP. " LOOP AT li_ekbe INTO lwa_ekbe WHERE ebeln = lwa_xlips-vgbel
            CLEAR lwa_ekpo.
            READ TABLE li_ekpo INTO lwa_ekpo WITH KEY ebeln = lwa_xlips-vgbel
                                                      ebelp = lwa_xlips-vgpos
                                             BINARY SEARCH.
            IF sy-subrc EQ 0.
              IF lwa_ekpo-uebto IS INITIAL.
*   Begin of Defect 6989
* Now read tolerence level from KNVV data based on VTWEG SPART
                READ TABLE li_knvv INTO lwa_knvv WITH KEY vtweg = lwa_xlips-vtweg
                                                          spart = lwa_xlips-spart
                                                          BINARY SEARCH.
                IF sy-subrc = 0.
                  lwa_ekpo-uebto = lwa_knvv-uebto.
                ENDIF. " IF sy-subrc = 0

*              lwa_ekpo-uebto = lv_uebto.
**   End of Defect 6989
              ENDIF. " IF lwa_ekpo-uebto IS INITIAL

*Calculating STO quantity with over delivery tolerance
              lv_ekpo_qty = lwa_ekpo-menge * ( ( 100 + lwa_ekpo-uebto ) / 100 ).

*--> Begin of insert for D3_OTC_EDD_0418_Defect# 7295 by ASK on 02-Oct-2018
* Convert the qty first
              CLEAR lv_lfimg.
              IF lwa_xlips-vrkme NE  lwa_ekpo-meins.
                CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
                  EXPORTING
                    i_matnr              = lwa_xlips-matnr
                    i_in_me              = lwa_xlips-vrkme
                    i_out_me             = lwa_ekpo-meins
                    i_menge              = lwa_xlips-lfimg
                  IMPORTING
                    e_menge              = lv_lfimg
                  EXCEPTIONS
                    error_in_application = 1
                    error                = 2
                    OTHERS               = 3.
              ELSE. " ELSE -> IF lwa_xlips-meins NE lwa_ekpo-meins
                lv_lfimg = lwa_xlips-lfimg.
              ENDIF. " IF lwa_xlips-meins NE lwa_ekpo-meins
*<-- End of insert for D3_OTC_EDD_0418_Defect# 7295 by ASK on 02-Oct-2018

*--> Begin of delete for D3_OTC_EDD_0418_Defect# 7295 by ASK on 02-Oct-2018
*            IF lwa_xlips-lfimg GT ( lv_ekpo_qty - lv_ekbe_qty ) .
*<-- End of delete for D3_OTC_EDD_0418_Defect# 7295 by ASK on 02-Oct-2018

*Checking Total Delivery Quantity exceeds PO quantity
*--> Begin of insert for D3_OTC_EDD_0418_Defect# 7295 by ASK on 02-Oct-2018
              IF lv_lfimg GT ( lv_ekpo_qty - lv_ekbe_qty ) .
*<-- End of insert for D3_OTC_EDD_0418_Defect# 7295 by ASK on 02-Oct-2018
                lv_flag = abap_true.

*Removing leading zeros
                SHIFT lwa_xlips-vgpos LEFT DELETING LEADING lc_zero.
                IF lv_text1 IS INITIAL.
                  lv_text1 = lwa_xlips-vgpos.
                ELSE. " ELSE -> IF lv_text1 IS INITIAL
                  CONCATENATE lv_text1 lc_comma lwa_xlips-vgpos INTO lv_text1.
                ENDIF. " IF lv_text1 IS INITIAL
              ENDIF. " IF lv_lfimg GT ( lv_ekpo_qty - lv_ekbe_qty )
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF ( sy-subrc = 0 AND
        ENDIF. " IF lwa_xlips-updkz = lc_u OR lwa_xlips-updkz = lc_i

      ENDLOOP. " LOOP AT li_tmp_xlips INTO lwa_xlips

*If total Delivery Quantity exceeds PO quantity display error message
      IF lv_flag = abap_true.
        MESSAGE e891(zotc_msg) WITH  lv_text1 . " Total Delivery Quantity exceeds PO quantity for item & &
      ENDIF. " IF lv_flag = abap_true
    ENDLOOP. " LOOP AT it_xlikp INTO lwa_likp
  ENDIF. " IF sy-subrc EQ 0
ENDMETHOD.


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


method IF_EX_LE_SHP_DELIVERY_PROC~SAVE_AND_PUBLISH_DOCUMENT.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~SAVE_DOCUMENT_PREPARE.
endmethod.
ENDCLASS.
