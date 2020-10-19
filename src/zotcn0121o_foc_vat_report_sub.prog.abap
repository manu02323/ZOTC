*&---------------------------------------------------------------------*
*&  Include           ZOTCN0121O_FOC_VAT_REPORT_SUB
*&---------------------------------------------------------------------*
* PROGRAM    :  ZOTCR0121O_FOC_VAT_REPORT                              *
* TITLE      :  FOC VAT Report                                         *
* DEVELOPER  :  Sumanpreet Kaur                                        *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  : D3_OTC_RDD_0121                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: FOC Report for VAT                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER    TRANSPORT     DESCRIPTION                      *
* =========== ======== ========== =====================================*
* 20-APR-2018 U034334  E1DK936059 Initial Development                  *
* 16-MAY-2018 U034334  E1DK936059 Defect_6082: Include Drop-Ship Sales *
*                                 Orders in the ALV, add Inv Unit Price*
* 25-JUL-2018 U034334  E1DK937964 Defect_6735:Print SO item, Display IC*
*                                 Invoice for Batch Split, Display Cost*
*                                 centre from SO header if not at item *
* 11-Sep-2019 U033959  E1SK901545 HANAtization changes
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_INITIALIZATION
*&---------------------------------------------------------------------*
*       Defaulting selection screen values
*----------------------------------------------------------------------*
FORM f_initialization .

  CONSTANTS: lc_sign   TYPE char1   VALUE 'I',   " Sign
             lc_option TYPE char2   VALUE 'EQ',  " Option
             lc_zlf    TYPE lfart   VALUE 'ZLF', " Delivery Type ZLF
             lc_zle    TYPE lfart   VALUE 'ZLE'. " Delivery Type ZLE

  DATA: lv_date_lo TYPE sy-datum, " Current Date of Application Server
        lv_date_hi TYPE sy-datum, " Current Date of Application Server
        lwa_range  TYPE selopt.   " Transfer Structure for Select Options

  CONSTANTS : lc_01  TYPE char2  VALUE '01'. " 01 of type CHAR2

*&--For giving the default values to the date
  lv_date_lo = sy-datum.
  lv_date_lo+6 = lc_01.

  lv_date_hi = lv_date_lo + 33.
  lv_date_hi+6 = lc_01.
  lv_date_hi = lv_date_hi - 1.

* Append WA to S_date not used because it is not capturing the high value
  s_date-sign   = lc_sign. " I
  s_date-option = lc_option. " EQ
  s_date-low    = lv_date_lo.
  s_date-high   = lv_date_hi.
  APPEND s_date.

*&--For giving default values to the Delivery type
  lwa_range-sign = lc_sign. " I
  lwa_range-option = lc_option. " EQ
  lwa_range-low    = lc_zlf. " ZLF
  APPEND lwa_range TO s_lfart.
  CLEAR lwa_range.

  lwa_range-sign = lc_sign. " I
  lwa_range-option = lc_option. " EQ
  lwa_range-low  = lc_zle. " ZLE
  APPEND lwa_range TO s_lfart.
  CLEAR lwa_range.
ENDFORM. " F_INITIALIZATION

*&---------------------------------------------------------------------*
*&      Form  F_GET_EMI_ENTRIES
*&---------------------------------------------------------------------*
*       Get constant values from the EMI table
*----------------------------------------------------------------------*
FORM f_get_emi_entries CHANGING fp_i_enh_status TYPE ty_t_emi.

  CONSTANTS lc_enhancement_no TYPE z_enhancement VALUE 'OTC_RDD_0121'. " Enhancement No.

  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enhancement_no
    TABLES
      tt_enh_status     = fp_i_enh_status.

  DELETE fp_i_enh_status WHERE active = abap_false.

ENDFORM. " F_GET_EMI_ENTRIES

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_VKORG
*&---------------------------------------------------------------------*
*       Validate the Sales Organization
*----------------------------------------------------------------------*
FORM f_validate_vkorg USING fp_i_enh_status TYPE ty_t_emi.

  CONSTANTS lc_vkorg TYPE z_criteria VALUE 'VKORG'. " Enh. Criteria
  DATA lv_vkorg TYPE vkorg. " Sales Organization

  SELECT SINGLE vkorg " Sales Organization
    FROM tvko         " Organizational Unit: Sales Organizations
    INTO lv_vkorg
   WHERE vkorg = p_vkorg.

  IF sy-subrc = 0.
* Binary Search not used due to very few entries
    IF fp_i_enh_status IS NOT INITIAL.
      READ TABLE fp_i_enh_status TRANSPORTING NO FIELDS
        WITH KEY criteria = lc_vkorg
                 sel_low  = lv_vkorg.
      IF sy-subrc <> 0.
        MESSAGE i000 DISPLAY LIKE c_err WITH 'No access for Sales Organization'(036) lv_vkorg.
        LEAVE TO SCREEN 1000.
      ENDIF. " IF sy-subrc <> 0

    ELSE. " ELSE -> IF fp_i_enh_status IS NOT INITIAL
      MESSAGE i000 DISPLAY LIKE c_err WITH 'No EMI entry found for Sales Org'(034) lv_vkorg.
      LEAVE TO SCREEN 1000.
    ENDIF. " IF fp_i_enh_status IS NOT INITIAL

  ELSE. " ELSE -> IF sy-subrc = 0
    MESSAGE i047 DISPLAY LIKE c_err. "Sales Org is not valid
    LEAVE TO SCREEN 1000.
  ENDIF. " IF sy-subrc = 0
  CLEAR lv_vkorg.
ENDFORM. " F_VALIDATE_VKORG

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_VTWEG
*&---------------------------------------------------------------------*
*       Validate Distribution Channel
*----------------------------------------------------------------------*
FORM f_validate_vtweg .
  DATA lv_vtweg TYPE vtweg. " Distribution Channel

  SELECT vtweg " Distribution Channel
    FROM tvtw  " Organizational Unit: Distribution Channels
    UP TO 1 ROWS
    INTO lv_vtweg
   WHERE vtweg IN s_vtweg.
  ENDSELECT.

  IF sy-subrc <> 0.
    MESSAGE i048 DISPLAY LIKE c_err. "Distribution Channel is not valid
    LEAVE TO SCREEN 1000.
  ENDIF. " IF sy-subrc <> 0
  CLEAR lv_vtweg.
ENDFORM. " F_VALIDATE_VTWEG

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_LFART
*&---------------------------------------------------------------------*
*       Validate Delivery Type
*----------------------------------------------------------------------*
FORM f_validate_lfart USING fp_i_lfart TYPE ty_t_range.
  DATA lv_lfart TYPE lfart. " Delivery Type

  SELECT lfart " Delivery Type
    FROM tvlk  " Delivery Types
   UP TO 1 ROWS
    INTO lv_lfart
   WHERE lfart IN fp_i_lfart.
  ENDSELECT.

  IF sy-subrc <> 0.
    MESSAGE i989 DISPLAY LIKE c_err. " Delivery Type is invalid
    LEAVE TO SCREEN 1000.
  ENDIF. " IF sy-subrc <> 0
  CLEAR lv_lfart.
ENDFORM. " F_VALIDATE_LFART

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_KUNAG
*&---------------------------------------------------------------------*
*       Validate Sold-To Customer
*----------------------------------------------------------------------*
FORM f_validate_kunag.
  DATA lv_kunnr TYPE kunnr. " Customer Number

  SELECT kunnr " Customer Number
    FROM kna1  " General Data in Customer Master
   UP TO 1 ROWS
    INTO lv_kunnr
   WHERE kunnr IN s_kunag
     AND loevm = space.
  ENDSELECT.

  IF sy-subrc <> 0.
    MESSAGE i993 DISPLAY LIKE c_err. "Sold-to-Party is invalid
    LEAVE TO SCREEN 1000.
  ENDIF. " IF sy-subrc <> 0
  CLEAR lv_kunnr.
ENDFORM. " F_VALIDATE_KUNAG

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_KUNWE
*&---------------------------------------------------------------------*
*       Validate Ship-to Customer
*----------------------------------------------------------------------*
FORM f_validate_kunwe .
  DATA lv_kunnr TYPE kunnr. " Customer Number

  SELECT kunnr " Customer Number
    FROM kna1  " General Data in Customer Master
   UP TO 1 ROWS
    INTO lv_kunnr
   WHERE kunnr IN s_kunwe
     AND loevm = space.
  ENDSELECT.

  IF sy-subrc <> 0.
    MESSAGE i992 DISPLAY LIKE c_err. "Ship-to-Party is invalid
    LEAVE TO SCREEN 1000.
  ENDIF. " IF sy-subrc <> 0
  CLEAR lv_kunnr.
ENDFORM. " F_VALIDATE_KUNWE

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_AUART
*&---------------------------------------------------------------------*
*       Validate Sales Order Type
*----------------------------------------------------------------------*
FORM f_validate_auart .
  DATA lv_auart TYPE auart. " Sales Document Type

  SELECT auart " Sales Document Type
    FROM tvak  " Sales Document Types
   UP TO 1 ROWS
    INTO lv_auart
    WHERE auart IN s_auart.
  ENDSELECT.

  IF sy-subrc <> 0.
    MESSAGE i056 DISPLAY LIKE c_err. " Document Type is not valid
    LEAVE TO SCREEN 1000.
  ENDIF. " IF sy-subrc <> 0
  CLEAR lv_auart.
ENDFORM. " F_VALIDATE_AUART

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_PSTYV
*&---------------------------------------------------------------------*
*       Validate Sales Order Item Category
*----------------------------------------------------------------------*
FORM f_validate_pstyv .
  DATA lv_pstyv TYPE pstyv. " Sales document item category

  SELECT pstyv " Sales document item category
    FROM tvpt  " Sales documents: Item categories
   UP TO 1 ROWS
    INTO lv_pstyv
   WHERE pstyv IN s_pstyv.
  ENDSELECT.

  IF sy-subrc <> 0.
    MESSAGE i000 DISPLAY LIKE c_err WITH 'Invalid Item Category'(037).
    LEAVE TO SCREEN 1000.
  ENDIF. " IF sy-subrc <> 0
  CLEAR lv_pstyv.
ENDFORM. " F_VALIDATE_PSTYV

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_PRSFD
*&---------------------------------------------------------------------*
*       Validate Pricing Type
*----------------------------------------------------------------------*
FORM f_validate_prsfd .
  CONSTANTS lc_domain TYPE domname VALUE 'PRSFD'. " Domain name

  CALL FUNCTION 'CHECK_DOMAIN_VALUES'
    EXPORTING
      domname       = lc_domain
      value         = s_prsfd-low
    EXCEPTIONS
      no_domname    = 1
      wrong_value   = 2
      dom_not_found = 3
      OTHERS        = 4.
  IF sy-subrc NE 0.
    MESSAGE i000 DISPLAY LIKE c_err WITH 'Invalid Pricing Type'(038).
    LEAVE TO SCREEN 1000.
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_PRSFD

*&---------------------------------------------------------------------*
*&      Form  F_GET_SALES_DATA
*&---------------------------------------------------------------------*
*       Get all relevant sales documents
*----------------------------------------------------------------------*
*  <--  fp_i_likp        Delivery Header
*  <--  fp_i_lips        Delivery Items
*  <--  fp_i_vbak        Sales Order Header
*  <--  fp_i_vbrk        Invoice Header
*  <--  fp_i_vbrp        Invoice Items
*  <--  fp_i_inv         Invoices from Delivery
*----------------------------------------------------------------------*
FORM f_get_sales_data CHANGING fp_i_likp TYPE ty_t_likp
                               fp_i_lips TYPE ty_t_lips
                               fp_i_vbak TYPE ty_t_vbak
* ---> Begin of Delete for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
*                               fp_i_vbap TYPE ty_t_vbap
* <--- End   of Delete for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
                               fp_i_vbrk TYPE ty_t_vbrk
                               fp_i_vbrp TYPE ty_t_vbrp
                               fp_i_inv  TYPE ty_t_vbfa.

  DATA: li_inv   TYPE ty_t_vbfa, " Internal Table for Invoices
        li_lips  TYPE ty_t_lips.

  CONSTANTS: lc_delv TYPE char1  VALUE 'J', " Doc Type for Delivery
             lc_inv  TYPE char1  VALUE '5', " Intercompany Invoice
             lc_cred TYPE char1  VALUE '6'. " intercompany Credit

* Step I(a) - Get all relevant deliveries (Except Drop-Ship)
  SELECT vbeln     " Delivery
         vkorg     " Sales Organization
         wadat_ist " Actual Goods Movement Date
    FROM likp      " SD Document: Delivery Header Data
    INTO TABLE fp_i_likp
   WHERE vkorg = p_vkorg
     AND lfart IN s_lfart
     AND kunnr IN s_kunwe
     AND kunag IN s_kunag
     AND wadat_ist IN s_date
     AND spe_loekz = space.

  IF sy-subrc = 0.
    SORT fp_i_likp BY vbeln.
  ENDIF. " IF sy-subrc = 0

* Get delivery item details
  IF fp_i_likp IS NOT INITIAL.
    SELECT lips~vbeln " Delivery
           lips~posnr " Delivery Item
           lips~werks " Plant
           lips~meins " UOM
           lips~lgmng " Quantity
           lips~vgbel " Document number of the reference document
           lips~vgpos " Item number of the reference item
           lips~uecha " Higher Level Item
      INTO TABLE fp_i_lips
      FROM lips       " SD document: Delivery: Item data
     INNER JOIN tvap  " Sales Document: Item Categories
        ON lips~pstyv = tvap~pstyv
   FOR ALL ENTRIES IN fp_i_likp
     WHERE lips~vbeln = fp_i_likp-vbeln
       AND lips~pstyv IN s_pstyv
       AND tvap~prsfd IN s_prsfd.

    IF sy-subrc = 0.
      SORT fp_i_lips BY vbeln posnr.
    ENDIF. " IF sy-subrc = 0

* Step II - Get all Sales Orders for these Deliveries
    IF fp_i_lips IS NOT INITIAL.
      li_lips[] = fp_i_lips[].
      SORT li_lips BY vgbel.
      DELETE ADJACENT DUPLICATES FROM li_lips COMPARING vgbel.

      SELECT vbeln " Sales Document
             auart " Sales Document Type
             augru " Order reason (reason for the business transaction)
             waerk " SD Document Currency
             vtweg " Distribution Channel
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
             kostl " Cost Centre
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
        FROM vbak " Sales Document: Header Data
        INTO TABLE fp_i_vbak
     FOR ALL ENTRIES IN li_lips
       WHERE vbeln = li_lips-vgbel.

      IF sy-subrc = 0.
        DELETE fp_i_vbak WHERE auart NOT IN s_auart
                            OR vtweg NOT IN s_vtweg.

        IF fp_i_vbak IS NOT INITIAL.
          SORT fp_i_vbak BY vbeln.
* ---> Begin of Delete for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
*        ELSE. " ELSE -> IF fp_i_vbak IS NOT INITIAL
*          MESSAGE i115. " No data found for the input given in selection screen
*          LEAVE LIST-PROCESSING.
* <--- End   of Delete for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
        ENDIF. " IF fp_i_vbak IS NOT INITIAL
      ENDIF. " IF sy-subrc = 0

* Step III - Get all Invoices for deliveries from VBFA
      SELECT vbelv " Preceding sales and distribution document
             posnv " Preceding item of an SD document
             vbeln " Subsequent sales and distribution document
             posnn " Subsequent item of an SD document
* ---> Begin of Delete for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
*               rfmng " Referenced quantity in base unit of measure
*               rfwrt " Reference value
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
             plmin " Quantity is calculated positively, negatively or not at all
        FROM vbfa  " Sales Document Flow
        INTO TABLE fp_i_inv
     FOR ALL ENTRIES IN fp_i_lips
       WHERE vbelv = fp_i_lips-vbeln
         AND posnv = fp_i_lips-posnr
         AND vbtyp_n IN (lc_inv, lc_cred)
         AND vbtyp_v = lc_delv.

      IF sy-subrc = 0.
        SORT fp_i_inv BY vbelv posnv.

        li_inv[] = fp_i_inv.
        SORT li_inv BY vbeln.
        DELETE ADJACENT DUPLICATES FROM li_inv COMPARING vbeln.
        IF li_inv IS NOT INITIAL.

* Get the Invoice Header Details
          SELECT vbeln " Billing Document
                 waerk " SD Document Currency
                 fkdat " Billing date for billing index and printout
            FROM vbrk  " Billing Document: Header Data
            INTO TABLE fp_i_vbrk
         FOR ALL ENTRIES IN li_inv
           WHERE vbeln = li_inv-vbeln.

          IF sy-subrc = 0.
* Get Invoice Item details
            SELECT vbeln " Billing Document
                   posnr " Billing item
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
                   fklmg " Billing quantity in stockkeeping unit
                   fbuda " Date on which services rendered
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
                   netwr " Net value of the billing item in document currency
                   werks " Plant
              FROM vbrp  " Billing Document: Item Data
              INTO TABLE fp_i_vbrp
           FOR ALL ENTRIES IN fp_i_vbrk
             WHERE vbeln = fp_i_vbrk-vbeln.

            IF sy-subrc = 0.
              SORT fp_i_vbrp BY vbeln posnr.
            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF li_inv IS NOT INITIAL
      ENDIF. " IF sy-subrc = 0
* ---> Begin of Delete for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
*    ELSE. " ELSE -> IF fp_i_lips IS NOT INITIAL
*      MESSAGE i115. " No data found for the input given in selection screen
*      LEAVE LIST-PROCESSING.
* <--- End   of Delete for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
    ENDIF. " IF fp_i_lips IS NOT INITIAL
* ---> Begin of Delete for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
*  ELSE. " ELSE -> IF fp_i_likp IS NOT INITIAL
*    MESSAGE i115. " No data found for the input given in selection screen
*    LEAVE LIST-PROCESSING.
* <--- End   of Delete for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
  ENDIF. " IF fp_i_likp IS NOT INITIAL
  FREE: li_inv,
        li_lips.
ENDFORM. " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_FINAL
*&---------------------------------------------------------------------*
*       Populate Final Internal table
*----------------------------------------------------------------------*
*  -->  fp_i_t001w       Plants
*  -->  fp_i_cskt        Cost Centre texts
*  -->  fp_i_cepct       Profile Centre texts
*  -->  fp_i_vbpa        Partner data
*  -->  fp_i_kna1        Customer data
*  -->  fp_i_tvaut       Order Reason
*  -->  fp_i_likp        Delivery Header
*  -->  fp_i_vbak        Sales Order Header
*  -->  fp_i_vbap        Sales Order Items
*  -->  fp_i_vbrk        Invoice Header
*  -->  fp_i_vbrp        Invoice Items
*  -->  fp_i_inv         Invoices from Delivery
*  -->  fp_i_tvakt       Sales Order Type Texts
*  -->  fp_i_tvapt       Item Category Texts
*  <--  fp_i_lips        Delivery Items
*  <--  fp_i_final       Final Table
*----------------------------------------------------------------------*
FORM f_populate_final   USING fp_i_t001w TYPE ty_t_t001w
                              fp_i_cskt  TYPE ty_t_cskt
                              fp_i_cepct TYPE ty_t_cepct
                              fp_i_vbpa  TYPE ty_t_vbpa
                              fp_i_kna1  TYPE ty_t_kna1
                              fp_i_tvaut TYPE ty_t_tvaut
                              fp_i_likp  TYPE ty_t_likp
                              fp_i_vbak  TYPE ty_t_vbak
                              fp_i_vbap  TYPE ty_t_vbap
                              fp_i_vbrk  TYPE ty_t_vbrk
                              fp_i_vbrp  TYPE ty_t_vbrp
                              fp_i_inv   TYPE ty_t_vbfa
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
                              fp_i_tvakt TYPE ty_t_tvakt
                              fp_i_tvapt TYPE ty_t_tvapt
                              fp_i_so    TYPE ty_t_vbfa
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
                     CHANGING fp_i_lips  TYPE ty_t_lips
                              fp_i_final TYPE ty_t_final.

  DATA : li_lips_main  TYPE ty_t_lips, " Internal table for Delv Items
         lwa_lips_main TYPE ty_lips,   " WA for LI_LIPS_MAIN
         lwa_lips      TYPE ty_lips,   " WA for I_LIPS
         lwa_likp      TYPE ty_likp,   " WA for I_LIKP
         lwa_inv       TYPE ty_vbfa,   " WA for VBFA Invoices
         lwa_vbak      TYPE ty_vbak,   " WA for I_VBAK
         lwa_vbap      TYPE ty_vbap,   " WA for I_VBAP
         lwa_vbrk      TYPE ty_vbrk,   " WA for I_VBRK
         lwa_vbrp      TYPE ty_vbrp,   " WA for I_VBRP
         lwa_t001w     TYPE ty_t001w,  " WA for LI_T001W
         lwa_cskt      TYPE ty_cskt,   " WA for LI_CSKT
         lwa_cepct     TYPE ty_cepct,  " WA for LI_CEPCT
         lwa_vbpa      TYPE ty_vbpa,   " WA for LI_VBPA
         lwa_kna1      TYPE ty_kna1,   " WA for LI_KNA1
         lwa_tvaut     TYPE ty_tvaut,  " WA for LI_TVAUT
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
         lwa_tvakt     TYPE ty_tvakt, " WA for LI_TVAKT
         lwa_tvapt     TYPE ty_tvapt, " WA for LI_TVAPT
         lwa_so        TYPE ty_vbfa,  " WA for Sales Order
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
         lwa_final     TYPE ty_final, " WA for I_FINAL
         lv_inv        TYPE flag,     " Flag for invoice line append
         lv_dlv_qty    TYPE lgmng,    " Delivery Qty
         lv_index      TYPE sy-tabix, " Loop Index
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
         lv_delv       TYPE vbeln_vl, " Delivery
         lv_delv_item  TYPE posnr_vl. " Delivery Item
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018

  CONSTANTS : lc_soldto  TYPE parvw   VALUE 'AG',     " Partner Function
              lc_shipto  TYPE parvw   VALUE 'WE',     " Partner Function
              lc_posnr   TYPE posnr   VALUE '000000'. " Item number of the SD document
* ---> Begin of Delete for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
*              lc_euro    TYPE waerk   VALUE 'EUR'.    " SD Document Currency
* <--- End   of Delete for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

  li_lips_main[] = fp_i_lips[].
  DELETE fp_i_lips WHERE uecha IS NOT INITIAL.
  SORT li_lips_main BY vbeln uecha.

* Collect all batch split line items into one line item
  LOOP AT li_lips_main INTO lwa_lips_main
    WHERE uecha IS NOT INITIAL.
    lwa_lips-vbeln = lwa_lips_main-vbeln.
    lwa_lips-werks = lwa_lips_main-werks.
    lwa_lips-meins = lwa_lips_main-meins.
    lwa_lips-lgmng = lwa_lips_main-lgmng.
    lwa_lips-vgbel = lwa_lips_main-vgbel.
    lwa_lips-vgpos = lwa_lips_main-vgpos.
    lwa_lips-posnr = lwa_lips_main-uecha.
    COLLECT lwa_lips INTO fp_i_lips.
    CLEAR lwa_lips.
  ENDLOOP. " LOOP AT li_lips_main INTO lwa_lips_main

*------------------- MAIN LOOP -------------------------
* Loop at delivery table with main line items
  LOOP AT fp_i_lips INTO lwa_lips.

* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
* Sales Orders for Drop-Ship
    READ TABLE fp_i_so INTO lwa_so
      WITH KEY vbeln = lwa_lips-vgbel
               posnn = lwa_lips-vgpos
               BINARY SEARCH.
    IF sy-subrc = 0.

* Sales Order Items for Drop-Ship
      READ TABLE fp_i_vbap INTO lwa_vbap
        WITH KEY vbeln = lwa_so-vbelv
                 posnr = lwa_so-posnv
                 BINARY SEARCH.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF. " IF sy-subrc <> 0
      CLEAR lwa_so.

    ELSE. " ELSE -> IF sy-subrc = 0
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

* Sales Order Details
      READ TABLE fp_i_vbap INTO lwa_vbap
        WITH KEY vbeln = lwa_lips-vgbel
                 posnr = lwa_lips-vgpos
                 BINARY SEARCH.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF. " IF sy-subrc <> 0
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
    ENDIF. " IF sy-subrc = 0
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

* Sales Order Data
    lwa_final-so_vbeln    = lwa_vbap-vbeln.
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
    lwa_final-so_item     = lwa_vbap-posnr.
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
    lwa_final-so_matnr    = lwa_vbap-matnr.
    lwa_final-so_arktx    = lwa_vbap-arktx.
    lwa_final-so_item_cat = lwa_vbap-pstyv.
    lwa_final-cost_centre = lwa_vbap-kostl.
    lwa_final-profit_ctr  = lwa_vbap-prctr.
* ---> Begin of Delete for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
*    lwa_final-net_price   = lwa_vbap-wavwr.
* <--- End   of Delete for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

    IF lwa_vbap-kwmeng IS NOT INITIAL OR
       lwa_vbap-zmeng IS NOT INITIAL.
      lwa_final-unit_price  = lwa_vbap-wavwr / ( lwa_vbap-kwmeng + lwa_vbap-zmeng ).
    ENDIF. " IF lwa_vbap-kwmeng IS NOT INITIAL OR

* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
* Item Category Description
    READ TABLE fp_i_tvapt INTO lwa_tvapt
      WITH KEY pstyv = lwa_vbap-pstyv
               BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_final-item_cat_txt = lwa_tvapt-vtext.
      CLEAR lwa_tvapt.
    ENDIF. " IF sy-subrc = 0
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

* Delivery Data
    lwa_final-delv_vbeln = lwa_lips-vbeln.
    lwa_final-delv_item  = lwa_lips-posnr.
    lwa_final-delv_qty   = lwa_lips-lgmng.
    lwa_final-delv_uom   = lwa_lips-meins.
    lwa_final-delv_plant = lwa_lips-werks.
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
    lv_dlv_qty = lwa_lips-lgmng.
    lwa_final-delv_date  = lwa_lips-wadat_ist.
    lwa_final-net_price  = ( lwa_final-unit_price * lwa_lips-lgmng ).

* Goods Issue Date
    IF lwa_final-delv_date IS INITIAL.
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
      READ TABLE fp_i_likp INTO lwa_likp
        WITH KEY vbeln = lwa_lips-vbeln
                 BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_final-delv_date  = lwa_likp-wadat_ist.
        CLEAR lwa_likp.
      ENDIF. " IF sy-subrc = 0
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
    ENDIF. " IF lwa_final-delv_date IS INITIAL
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

* Distribution Channel
    READ TABLE fp_i_vbak INTO lwa_vbak
      WITH KEY vbeln = lwa_vbap-vbeln
               BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_final-so_vtweg     = lwa_vbak-vtweg.
      lwa_final-doc_curr     = lwa_vbak-waerk.
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
* If cost centre not found at SO item level, get it from SO header
      IF lwa_final-cost_centre IS INITIAL.
        lwa_final-cost_centre = lwa_vbak-kostl.
      ENDIF. " IF lwa_final-cost_centre IS INITIAL
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
      lwa_final-so_auart     = lwa_vbak-auart.

* Amounts conversion if currency is not EURO
      IF lwa_final-doc_curr NE p_waerk.
* Convert Unit Price to EURO
        IF lwa_final-unit_price IS NOT INITIAL.
          PERFORM f_convert_amt_to_eur USING lwa_final-delv_date
                                             lwa_final-doc_curr
                                    CHANGING lwa_final-unit_price.
        ENDIF. " IF lwa_final-unit_price IS NOT INITIAL

* Convert Net Price to EURO
        IF lwa_final-net_price IS NOT INITIAL.
          PERFORM f_convert_amt_to_eur USING lwa_final-delv_date
                                             lwa_final-doc_curr
                                    CHANGING lwa_final-net_price.
        ENDIF. " IF lwa_final-net_price IS NOT INITIAL
      ENDIF. " IF lwa_final-doc_curr NE p_waerk
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

* Order Reason text
      READ TABLE fp_i_tvaut INTO lwa_tvaut
        WITH KEY augru = lwa_vbak-augru
                 BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_final-order_reason = lwa_tvaut-bezei.
        CLEAR lwa_tvaut.
      ENDIF. " IF sy-subrc = 0

* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
* Sales Order Type Text
      READ TABLE fp_i_tvakt INTO lwa_tvakt
        WITH KEY auart = lwa_vbak-auart
                 BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_final-so_descr = lwa_tvakt-bezei.
        CLEAR lwa_tvakt.
      ENDIF. " IF sy-subrc = 0
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
      CLEAR lwa_vbak.
    ENDIF. " IF sy-subrc = 0

* Plant name
    READ TABLE fp_i_t001w INTO lwa_t001w
      WITH KEY werks = lwa_lips-werks
               BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_final-plant_txt = lwa_t001w-name1.
      CLEAR lwa_t001w.
    ENDIF. " IF sy-subrc = 0

* Cost Centre Text
* Can not use binary search as we need to sort by datbi descending
    READ TABLE fp_i_cskt INTO lwa_cskt
* ---> Begin of Change for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
*      WITH KEY kostl = lwa_vbap-kostl.
      WITH KEY kostl = lwa_final-cost_centre.
* <--- End   of Change for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
    IF sy-subrc = 0.
      lwa_final-cost_ctr_txt = lwa_cskt-ktext.
      CLEAR lwa_cskt.
    ENDIF. " IF sy-subrc = 0

* Profile Centre Text
* can not use binary search as we need to sort by datbi descending
    READ TABLE fp_i_cepct INTO lwa_cepct
      WITH KEY prctr = lwa_vbap-prctr.
    IF sy-subrc = 0.
      lwa_final-prft_ctr_txt = lwa_cepct-ktext.
      CLEAR lwa_cepct.
    ENDIF. " IF sy-subrc = 0

* Sold-To Party
    READ TABLE fp_i_vbpa INTO lwa_vbpa
      WITH KEY vbeln = lwa_vbap-vbeln
               posnr = lwa_vbap-posnr
               parvw = lc_soldto
               BINARY SEARCH.
    IF sy-subrc NE 0.
      READ TABLE fp_i_vbpa INTO lwa_vbpa
        WITH KEY vbeln = lwa_vbap-vbeln
                 posnr = lc_posnr
                 parvw = lc_soldto
                 BINARY SEARCH.
      IF sy-subrc <> 0.
* Do Nothing, sy-subrc check to suppress SCII Error
        CLEAR lwa_vbpa.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF sy-subrc NE 0

    IF lwa_vbpa IS NOT INITIAL.
* Sold-to Party Name
      READ TABLE fp_i_kna1 INTO lwa_kna1
        WITH KEY kunnr = lwa_vbpa-kunnr
                 BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_final-so_soldto  = lwa_kna1-kunnr.
        lwa_final-soldto_txt = lwa_kna1-name1.
        CLEAR lwa_kna1.
      ENDIF. " IF sy-subrc = 0
      CLEAR lwa_vbpa.
    ENDIF. " IF lwa_vbpa IS NOT INITIAL

* Ship-To Party
    READ TABLE fp_i_vbpa INTO lwa_vbpa
      WITH KEY vbeln = lwa_vbap-vbeln
               posnr = lwa_vbap-posnr
               parvw = lc_shipto
               BINARY SEARCH.
    IF  sy-subrc NE 0.
      READ TABLE fp_i_vbpa INTO lwa_vbpa
        WITH KEY vbeln = lwa_vbap-vbeln
                 posnr = lc_posnr
                 parvw = lc_shipto
                 BINARY SEARCH.
      IF sy-subrc <> 0.
* Do Nothing, sy-subrc check to suppress SCII Error
        CLEAR lwa_vbpa.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF sy-subrc NE 0

    IF lwa_vbpa IS NOT INITIAL.
* Ship To Party Name
      READ TABLE fp_i_kna1 INTO lwa_kna1
        WITH KEY kunnr = lwa_vbpa-kunnr
                 BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_final-so_shipto  = lwa_kna1-kunnr.
        lwa_final-shipto_txt = lwa_kna1-name1.
        CLEAR lwa_kna1.
      ENDIF. " IF sy-subrc = 0
      CLEAR lwa_vbpa.
    ENDIF. " IF lwa_vbpa IS NOT INITIAL

* Invoice Details
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
* Get the Delivery Number and Item number into a local variable for Split and Non- split scenario
    READ TABLE fp_i_inv INTO lwa_inv
      WITH KEY vbelv = lwa_lips-vbeln
               posnv = lwa_lips-posnr
               BINARY SEARCH.

    IF sy-subrc = 0.
      lv_delv      = lwa_lips-vbeln.
      lv_delv_item = lwa_lips-posnr.
    ELSE. " ELSE -> IF sy-subrc = 0
* For batch split line items the item number is different
      READ TABLE li_lips_main INTO lwa_lips_main
        WITH KEY vbeln = lwa_lips-vbeln
                 uecha = lwa_lips-posnr
                 BINARY SEARCH.
      IF sy-subrc = 0.
        lv_delv = lwa_lips_main-vbeln.
        lv_delv_item = lwa_lips_main-posnr.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018

* Parallel cursor used to avoid Nested Loops
    READ TABLE fp_i_inv INTO lwa_inv
      WITH KEY vbelv = lv_delv
               posnv = lv_delv_item.
*  BINARY SEARCH not used bcoz it gives wrong value for sy-tabix

    IF sy-subrc = 0.
      CLEAR lv_index.
      lv_index = sy-tabix.

      LOOP AT fp_i_inv INTO lwa_inv FROM lv_index.
* ---> Begin of Change for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
*        IF lwa_inv-vbelv NE lwa_lips-vbeln
*        OR lwa_inv-posnv NE lwa_lips-posnr.
        IF lwa_inv-vbelv NE lv_delv
        OR lwa_inv-posnv NE lv_delv_item.
* <--- End   of Change for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
          EXIT.
        ENDIF. " IF lwa_inv-vbelv NE lv_delv

        READ TABLE fp_i_vbrp INTO lwa_vbrp
          WITH KEY vbeln = lwa_inv-vbeln
                   posnr = lwa_inv-posnn
                   BINARY SEARCH.
        IF sy-subrc = 0.
          lwa_final-inv_vbeln = lwa_vbrp-vbeln.
          lwa_final-inv_item  = lwa_vbrp-posnr.
* ---> Begin of Delete for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
* This is only giving the amount for one item in case of batch split, not the total amount..
* ... for all split items, which is wrong.
*          lwa_final-inv_amt   = lwa_vbrp-netwr.
* <--- End   of Delete for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
          IF lwa_vbrp-fklmg IS NOT INITIAL.
            lwa_final-inv_unitprice = lwa_vbrp-netwr / lwa_vbrp-fklmg.
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
* To get total amount in case of batch split, multiply inv unit amount with number of items
          lwa_final-inv_amt   = ( lwa_vbrp-netwr * lwa_final-delv_qty ) / lwa_vbrp-fklmg.
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
          ENDIF. " IF lwa_vbrp-fklmg IS NOT INITIAL
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
        ENDIF. " IF sy-subrc = 0

        READ TABLE fp_i_vbrk INTO lwa_vbrk
          WITH KEY vbeln = lwa_vbrp-vbeln.
        IF sy-subrc = 0.
          IF lwa_final-doc_curr NE lwa_vbrk-waerk.
            lwa_final-doc_curr = lwa_vbrk-waerk.
          ENDIF. " IF lwa_final-doc_curr NE lwa_vbrk-waerk
          lwa_final-inv_date  = lwa_vbrk-fkdat.
        ENDIF. " IF sy-subrc = 0

* ---> Begin of Delete for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
* Unit Price and Net Price will always be derived from the Sales Order now
** Unit Price
*        IF lwa_inv-rfmng IS NOT INITIAL.
*          lwa_final-unit_price = lwa_inv-rfwrt / lwa_inv-rfmng.
*        ENDIF. " IF lwa_inv-rfmng IS NOT INITIAL
** Net Price
*        lwa_final-net_price  = lwa_inv-rfwrt.

** Amounts conversion if currency is not EURO
*        IF lwa_final-doc_curr NE lc_euro.

** Convert Unit Price to EURO
*          PERFORM f_convert_amt_to_eur USING lwa_final-inv_date
*                                             lwa_final-doc_curr
*                                    CHANGING lwa_final-unit_price.
** Convert Net Price to EURO
*          PERFORM f_convert_amt_to_eur USING lwa_final-inv_date
*                                             lwa_final-doc_curr
*                                    CHANGING lwa_final-net_price.
* <--- End   of Delete for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
* Amounts conversion if currency is not EURO
* ---> Begin of Change for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
*        IF lwa_final-doc_curr NE lc_euro.
        IF lwa_final-doc_curr NE p_waerk.
* <--- End   of Change for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

* Convert Invoice Unit Price to EUR
          IF lwa_final-inv_unitprice IS NOT INITIAL.
            PERFORM f_convert_amt_to_eur USING lwa_vbrp-fbuda
                                               lwa_final-doc_curr
                                      CHANGING lwa_final-inv_unitprice.
          ENDIF. " IF lwa_final-inv_unitprice IS NOT INITIAL

* Convert Invoice Amount to EUR
          IF lwa_final-inv_amt IS NOT INITIAL.
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
            PERFORM f_convert_amt_to_eur USING
* ---> Begin of Change for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
*                                            lwa_final-inv_date
                                               lwa_vbrp-fbuda
* <--- End   of Change for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
                                               lwa_final-doc_curr
                                      CHANGING lwa_final-inv_amt.
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
          ENDIF. " IF lwa_final-inv_amt IS NOT INITIAL
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
* ---> Begin of Change for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
*          lwa_final-doc_curr = lc_euro.
          lwa_final-doc_curr = p_waerk.
* <--- End   of Change for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
        ENDIF. " IF lwa_final-doc_curr NE p_waerk

* Print Quantity and Amounts with Sign
        PERFORM f_format_qty_amt     USING lwa_inv-plmin
                                           lv_dlv_qty
                                  CHANGING lwa_final-delv_qty
                                           lwa_final-unit_price
                                           lwa_final-net_price
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
                                           lwa_final-inv_unitprice
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
                                           lwa_final-inv_amt.

        lv_inv = abap_true.
        APPEND lwa_final TO fp_i_final.

        CLEAR : lwa_vbrk,
                lwa_vbrp,
                lwa_final-net_price,
                lwa_final-unit_price,
                lwa_final-inv_vbeln,
                lwa_final-inv_item,
                lwa_final-inv_amt,
                lwa_final-inv_date,
                lwa_final-doc_curr,
                lwa_final-delv_qty,
                lwa_inv.
      ENDLOOP. " LOOP AT fp_i_inv INTO lwa_inv FROM lv_index
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
      CLEAR : lv_delv,
              lv_delv_item.
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
    ENDIF. " IF sy-subrc = 0

    IF lv_inv IS INITIAL.
      APPEND lwa_final TO fp_i_final.
    ELSE. " ELSE -> IF lv_inv IS INITIAL
      CLEAR lv_inv.
    ENDIF. " IF lv_inv IS INITIAL

    CLEAR : lwa_lips,
            lwa_vbap,
            lwa_final,
            lv_dlv_qty.
  ENDLOOP. " LOOP AT fp_i_lips INTO lwa_lips

  IF fp_i_final IS NOT INITIAL.
* ---> Begin of Change for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
* The final report needs to be sorted by SO, SO item, invoice and invoice item
*    SORT fp_i_final BY delv_vbeln delv_item.
    SORT fp_i_final BY so_vbeln so_item inv_vbeln inv_item.
* <--- End   of Change for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
  ELSE. " ELSE -> IF fp_i_final IS NOT INITIAL
    MESSAGE i115. " No data found for input given on selection screen
    LEAVE LIST-PROCESSING.
  ENDIF. " IF fp_i_final IS NOT INITIAL
ENDFORM. " F_POPULATE_FINAL

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_FIELDCAT
*&---------------------------------------------------------------------*
*       Prepare ALV Field Catalogue
*----------------------------------------------------------------------*
*    <-- FP_I_FIELDCAT        Field Catalogue for ALV
*----------------------------------------------------------------------*
FORM f_prepare_fieldcat .

  PERFORM f_update_fieldcat USING :
        'DELV_VBELN'    'I_FINAL'   'Delivery Number'(003),
        'DELV_ITEM'     'I_FINAL'   'Delivery Item'(004),
* ---> Begin of Change for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
*        'DELV_DATE'     'I_FINAL'   'Goods Issue'(005),
        'DELV_DATE'     'I_FINAL'   'Actual Goods Issue Date'(005),
* <--- End   of Change for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
        'SO_VTWEG'      'I_FINAL'   'Distribution Channel'(006),
        'SO_VBELN'      'I_FINAL'   'Order Number'(007),
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
        'SO_ITEM'       'I_FINAL'   'Order Item'(044),
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
        'SO_AUART'      'I_FINAL'   'Order Type'(039),
        'SO_DESCR'      'I_FINAL'   'Order Type Description'(040),
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
* ---> Begin of Change for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
*        'SO_MATNR'      'I_FINAL'   'Product Number'(008),
        'SO_MATNR'      'I_FINAL'   'Material'(008),
* <--- End   of Change for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
        'SO_ARKTX'      'I_FINAL'   'Material Description'(009),
        'SO_ITEM_CAT'   'I_FINAL'   'Item Category'(010),
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
        'ITEM_CAT_TXT'  'I_FINAL'   'Item Category Description'(041),
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
        'DELV_QTY'      'I_FINAL'   'Quantity'(011),
        'DELV_UOM'      'I_FINAL'   'UOM'(012),
        'INV_VBELN'     'I_FINAL'   'Invoice No.'(013),
        'INV_ITEM'      'I_FINAL'   'Invoice Item'(015),
        'INV_DATE'      'I_FINAL'   'Invoice Date'(014),
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
        'INV_UNITPRICE' 'I_FINAL'   'Invoice Unit Price'(043),
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
        'INV_AMT'       'I_FINAL'   'Invoice Amount'(016),
        'DELV_PLANT'    'I_FINAL'   'Plant'(017),
        'PLANT_TXT'     'I_FINAL'   'Plant Name'(018),
        'DOC_CURR'      'I_FINAL'   'Currency'(019),
        'UNIT_PRICE'    'I_FINAL'   'Unit Cost'(020),
        'NET_PRICE'     'I_FINAL'   'Cost Price'(021),
        'COST_CENTRE'   'I_FINAL'   'Cost Centre'(022),
        'COST_CTR_TXT'  'I_FINAL'   'Cost Centre Name'(023),
        'PROFIT_CTR'    'I_FINAL'   'Profit Centre'(024),
        'PRFT_CTR_TXT'  'I_FINAL'   'Profit Centre Name'(025),
        'SO_SOLDTO'     'I_FINAL'   'Sold-To'(026),
        'SOLDTO_TXT'    'I_FINAL'   'Sold-To Name'(027),
        'SO_SHIPTO'     'I_FINAL'   'Ship-To'(028),
        'SHIPTO_TXT'    'I_FINAL'   'Ship-To Name'(029),
        'ORDER_REASON'  'I_FINAL'   'Order Reason'(030).
ENDFORM. " F_PREPARE_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_FIELDCAT
*&---------------------------------------------------------------------*
*       Populate the Field Catalogue
*----------------------------------------------------------------------*
*      -->FP_FIELDNAME     Field name
*      -->FP_TABNAME       Table name
*      -->FP_SELTEXT       Field Label
*----------------------------------------------------------------------*
FORM f_update_fieldcat    USING fp_fieldname  TYPE slis_fieldname " Field Name
                                fp_tabname    TYPE slis_tabname   " Table Name
                                fp_seltext    TYPE scrtext_l.     " Long Field Label

* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
  CONSTANTS : lc_cost_centre TYPE slis_fieldname VALUE 'COST_CENTRE',
              lc_profit_ctr  TYPE slis_fieldname VALUE 'PROFIT_CTR',
              lc_so_soldto   TYPE slis_fieldname VALUE 'SO_SOLDTO',
              lc_so_shipto   TYPE slis_fieldname VALUE 'SO_SHIPTO'.
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
  DATA : lwa_fieldcat   TYPE slis_fieldcat_alv. " WA for Field Catalogue

* The column position in the output
  gv_col_pos             = gv_col_pos + 1.
  lwa_fieldcat-col_pos   = gv_col_pos.
  lwa_fieldcat-fieldname = fp_fieldname.
  lwa_fieldcat-tabname   = fp_tabname.
  lwa_fieldcat-seltext_l = fp_seltext.

* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
* Suppress Leading Zeros
  IF fp_fieldname = lc_cost_centre OR
     fp_fieldname = lc_profit_ctr OR
     fp_fieldname = lc_so_soldto OR
     fp_fieldname = lc_so_shipto.
    lwa_fieldcat-edit_mask = '==ALPHA'.
  ENDIF. " IF fp_fieldname = lc_cost_centre OR
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.
ENDFORM. " F_UPDATE_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_OUTPUT
*&---------------------------------------------------------------------*
*       ALV Output Display
*----------------------------------------------------------------------*
*      -->FP_I_FIELDCAT     Field Catalogue table
*      -->FP_I_FINAL        Final table
*----------------------------------------------------------------------*
FORM f_display_output  USING fp_i_fieldcat TYPE slis_t_fieldcat_alv
                             fp_i_final    TYPE ty_t_final.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = sy-repid
      i_callback_top_of_page = 'F_TOP_OF_PAGE'
      it_fieldcat            = fp_i_fieldcat
    TABLES
      t_outtab               = fp_i_final
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.
  IF sy-subrc <> 0.
    MESSAGE i132. " Issue in ALV display
  ENDIF. " IF sy-subrc <> 0

ENDFORM. " F_DISPLAY_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       Subroutine for header display
*----------------------------------------------------------------------*
FORM f_top_of_page.
  DATA: li_header   TYPE slis_t_listheader, " Internal table for ALV Header
        lwa_header  TYPE slis_listheader,   " WA for ALV header
        lv_from     TYPE char10,            " From Date in CHAR
        lv_to       TYPE char10.            " To Date in CHAR

  CONSTANTS: lc_head  TYPE char1  VALUE 'H', " Header
             lc_sel   TYPE char1  VALUE 'S'. " Selection

* Report Title
  lwa_header-typ = lc_head.
  lwa_header-info = 'FOC Report for VAT'(035).
  APPEND lwa_header TO li_header.
  CLEAR lwa_header.

* Goods Issue Date
  lwa_header-typ = lc_sel.
  lwa_header-key = 'Goods Issue Date'(031).
  WRITE s_date-low TO lv_from.
  IF s_date-high IS NOT INITIAL.
    WRITE s_date-high TO lv_to.
    CONCATENATE lv_from 'To'(032) lv_to INTO lwa_header-info SEPARATED BY space.
  ELSE. " ELSE -> IF s_date-high IS NOT INITIAL
    lwa_header-info = lv_from.
  ENDIF. " IF s_date-high IS NOT INITIAL
  APPEND lwa_header TO li_header.
  CLEAR: lwa_header.

* Sales Org
  lwa_header-typ = lc_sel.
  lwa_header-key = 'Sales Org'(033).
  IF gv_vkorg_txt IS NOT INITIAL.
    CONCATENATE p_vkorg '(' gv_vkorg_txt ')' INTO lwa_header-info SEPARATED BY space.
  ELSE. " ELSE -> IF gv_vkorg_txt IS NOT INITIAL
    lwa_header-info = p_vkorg.
  ENDIF. " IF gv_vkorg_txt IS NOT INITIAL
  APPEND lwa_header TO li_header.
  CLEAR: lwa_header.

* Distribution Channel
  lwa_header-typ = lc_sel.
  lwa_header-key = 'Distribution Channel'(006).
  IF s_vtweg-high IS NOT INITIAL.
    CONCATENATE s_vtweg-low 'To'(032) s_vtweg-high INTO lwa_header-info SEPARATED BY space.
  ELSE. " ELSE -> IF s_vtweg-high IS NOT INITIAL
    lwa_header-info = s_vtweg-low.
  ENDIF. " IF s_vtweg-high IS NOT INITIAL
  APPEND lwa_header TO li_header.
  CLEAR: lwa_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = li_header.

ENDFORM. "f_top_of_page

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_FOR_DISPLAY
*&---------------------------------------------------------------------*
*       Fetch and Process Data for ALV Display
*----------------------------------------------------------------------*
*  <--  fp_i_final           Final Table for ALV
*----------------------------------------------------------------------*
FORM f_get_data_for_display CHANGING fp_i_final TYPE ty_t_final.
* Local Internal Tables
  DATA: li_t001w    TYPE ty_t_t001w, " Internal Table for Plant
        li_cskt     TYPE ty_t_cskt,  " Internal Table for Cost Centre
        li_cepct    TYPE ty_t_cepct, " Internal Table for Profit Centre
        li_vbpa     TYPE ty_t_vbpa,  " Internal Table for Partners
        li_kna1     TYPE ty_t_kna1,  " Internal Table for Customer
        li_tvaut    TYPE ty_t_tvaut, " Internal table for Order Reason
        li_lips     TYPE ty_t_lips,  " Internal table for LIPS
        li_likp     TYPE ty_t_likp,  " Internal table for LIKP
        li_vbak     TYPE ty_t_vbak,  " Internal table for VBAK
        li_vbap     TYPE ty_t_vbap,  " Internal Table for VBAP
        li_vbrk     TYPE ty_t_vbrk,  " Internal table for VBRK
        li_vbrp     TYPE ty_t_vbrp,  " Internal table for VBRP
        li_vbfa_inv TYPE ty_t_vbfa,  " Internal table for Invoices
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
        li_tvakt    TYPE ty_t_tvakt, " Internal table for Sales Order Type Texts
        li_tvapt    TYPE ty_t_tvapt, " Internal table for Item Category Texts
        li_vbfa_so  TYPE ty_t_vbfa.
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

* Get Sales Document details
  PERFORM f_get_sales_data CHANGING li_likp
                                    li_lips
                                    li_vbak
* ---> Begin of Delete for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
*                                    li_vbap
* <--- End   of Delete for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
                                    li_vbrk
                                    li_vbrp
                                    li_vbfa_inv.

* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
* Get Drop-Ship Data
  PERFORM f_get_dropship_data CHANGING li_lips
                                       li_vbfa_so
                                       li_vbak
                                       li_vbap.
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

* Get Other Details
  PERFORM f_get_other_data    USING li_lips
                                    li_vbak
                                    li_vbap
                           CHANGING li_t001w
                                    li_cskt
                                    li_cepct
                                    li_vbpa
                                    li_kna1
                                    li_tvaut
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
                                    li_tvakt
                                    li_tvapt.
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

* Populate Final Internal table for ALV
  PERFORM f_populate_final   USING li_t001w
                                   li_cskt
                                   li_cepct
                                   li_vbpa
                                   li_kna1
                                   li_tvaut
                                   li_likp
                                   li_vbak
                                   li_vbap
                                   li_vbrk
                                   li_vbrp
                                   li_vbfa_inv
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
                                   li_tvakt
                                   li_tvapt
                                   li_vbfa_so
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
                          CHANGING li_lips
                                   fp_i_final.

* Clear all local internal tables
  FREE:  li_t001w,
         li_cskt,
         li_cepct,
         li_vbpa,
         li_kna1,
         li_tvaut,
         li_lips,
         li_likp,
         li_vbak,
         li_vbap,
         li_vbrk,
         li_vbrp,
         li_vbfa_inv,
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
         li_tvakt,
         li_tvapt,
         li_vbfa_so.
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

ENDFORM. " F_GET_DATA_FOR_DISPLAY

*&---------------------------------------------------------------------*
*&      Form  F_GET_OTHER_DATA
*&---------------------------------------------------------------------*
*       Get Details for remaining ALV fields
*----------------------------------------------------------------------*
*  -->  fp_i_lips        Delivery Items
*  -->  fp_i_vbak        Sales Order Header
*  -->  fp_i_vbap        Sales Order Items
*  <--  fp_i_t001w       Plants
*  <--  fp_i_cskt        Cost Centre texts
*  <--  fp_i_cepct       Profile Centre texts
*  <--  fp_i_vbpa        Partner data
*  <--  fp_i_kna1        Customer data
*  <--  fp_i_tvaut       Order Reason
*  <--  fp_i_tvakt       Sales Order Type Texts
*  <--  fp_i_tvapt       Item Category texts
*----------------------------------------------------------------------*
FORM f_get_other_data    USING fp_i_lips  TYPE ty_t_lips
                               fp_i_vbak  TYPE ty_t_vbak
                               fp_i_vbap  TYPE ty_t_vbap
                      CHANGING fp_i_t001w TYPE ty_t_t001w
                               fp_i_cskt  TYPE ty_t_cskt
                               fp_i_cepct TYPE ty_t_cepct
                               fp_i_vbpa  TYPE ty_t_vbpa
                               fp_i_kna1  TYPE ty_t_kna1
                               fp_i_tvaut TYPE ty_t_tvaut
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
                               fp_i_tvakt TYPE ty_t_tvakt
                               fp_i_tvapt TYPE ty_t_tvapt.
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

  DATA: li_lips_tmp   TYPE ty_t_lips,
        li_vbak_tmp   TYPE ty_t_vbak,
        li_vbpa_tmp   TYPE ty_t_vbpa,
        li_vbap_tmp   TYPE ty_t_vbap,
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
        lwa_vbak      TYPE ty_vbak, " WA for VBAK
        lwa_vbap      TYPE ty_vbap. " WA for VBAP
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018

  CONSTANTS : lc_eng    TYPE spras  VALUE 'E',    " English
              lc_cntrol TYPE kokrs  VALUE 'BR00', " Controlling Area
              lc_soldto TYPE parvw  VALUE 'AG',   " Sold-To Partner function
              lc_shipto TYPE parvw  VALUE 'WE'.   " Ship-to Partner Function

* Get Sales Org Name
  SELECT SINGLE vtext " Name
           FROM tvkot " Organizational Unit: Sales Organizations: Texts
      BYPASSING BUFFER
           INTO gv_vkorg_txt
          WHERE spras = sy-langu
            AND vkorg = p_vkorg.
  IF sy-subrc <> 0.
* Do nothing
  ENDIF. " IF sy-subrc <> 0

* Get the plant name from T001W
  li_lips_tmp[] = fp_i_lips[].
  SORT li_lips_tmp BY werks.
  DELETE ADJACENT DUPLICATES FROM li_lips_tmp COMPARING werks.

  IF li_lips_tmp[] IS NOT INITIAL.
    SELECT werks " Plant
           name1 " Name
      FROM t001w " Plants/Branches
      INTO TABLE fp_i_t001w
   FOR ALL ENTRIES IN li_lips_tmp
     WHERE werks = li_lips_tmp-werks.
    IF sy-subrc = 0.
      SORT fp_i_t001w BY werks.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_lips_tmp[] IS NOT INITIAL

* Get Cost Centre details
  li_vbap_tmp[] = fp_i_vbap[].
  SORT li_vbap_tmp BY kostl.
  DELETE ADJACENT DUPLICATES FROM li_vbap_tmp COMPARING kostl.

* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
* We need to get the cost centre text for KOSTL in VBAK also
  li_vbak_tmp[] = fp_i_vbak[].
  SORT li_vbak_tmp BY kostl.
  DELETE ADJACENT DUPLICATES FROM li_vbak_tmp COMPARING kostl.

  LOOP AT li_vbak_tmp INTO lwa_vbak.
    lwa_vbap-kostl = lwa_vbak-kostl.
    APPEND lwa_vbap TO li_vbap_tmp.
    CLEAR : lwa_vbak,
            lwa_vbap.
  ENDLOOP. " LOOP AT li_vbak_tmp INTO lwa_vbak
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018

  IF li_vbap_tmp IS NOT INITIAL.
    SELECT kostl " Cost Center
           datbi " Valid To Date
           ktext " General Name
      FROM cskt  " Cost Center Texts
      INTO TABLE fp_i_cskt
     FOR ALL ENTRIES IN li_vbap_tmp
     WHERE spras = sy-langu
       AND kokrs = lc_cntrol
       AND kostl = li_vbap_tmp-kostl.

    IF sy-subrc = 0.
      SORT fp_i_cskt BY datbi DESCENDING.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_vbap_tmp IS NOT INITIAL
  FREE li_vbap_tmp.
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
  FREE li_vbak_tmp.
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018

* Get Profit Centre Details
  li_vbap_tmp[] = fp_i_vbap.
  SORT li_vbap_tmp BY prctr.
  DELETE ADJACENT DUPLICATES FROM li_vbap_tmp COMPARING prctr.

  IF li_vbap_tmp IS NOT INITIAL.
    SELECT prctr " Profit Center
           datbi " Valid To Date
           ktext " General Name
      FROM cepct " Texts for Profit Center Master Data
      INTO TABLE fp_i_cepct
   FOR ALL ENTRIES IN li_vbap_tmp
     WHERE spras = sy-langu
       AND prctr = li_vbap_tmp-prctr
       AND kokrs = lc_cntrol.

    IF sy-subrc = 0.
      SORT fp_i_cepct BY datbi DESCENDING.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_vbap_tmp IS NOT INITIAL
  FREE li_vbap_tmp.
*--->Begin of Changes for HANAtization on OTC_RDD_0121 by U033959 on 11-Sep-2019 in E1SK901545
  IF fp_i_vbak IS NOT INITIAL.
*<---End of Changes for HANAtization on OTC_RDD_0121 by U033959 on 11-Sep-2019 in E1SK901545
* Get Sold-To and Ship-to Customers
  SELECT vbeln " Sales and Distribution Document Number
         posnr " Item number of the SD document
         parvw " Partner Function
         kunnr " Customer Number
    FROM vbpa  " Sales Document: Partner
    INTO TABLE fp_i_vbpa
     FOR ALL ENTRIES IN fp_i_vbak
   WHERE vbeln = fp_i_vbak-vbeln
     AND parvw IN (lc_soldto, lc_shipto).

  IF sy-subrc = 0.
    SORT fp_i_vbpa BY vbeln posnr parvw.

    li_vbpa_tmp[] = fp_i_vbpa[].
    SORT li_vbpa_tmp BY kunnr.
    DELETE ADJACENT DUPLICATES FROM li_vbpa_tmp COMPARING kunnr.
    IF li_vbpa_tmp IS NOT INITIAL.
      SELECT kunnr " Customer Number
             name1 " Name 1
             loevm " Central Deletion Flag for Master Record
        FROM kna1  " General Data in Customer Master
        INTO TABLE fp_i_kna1
         FOR ALL ENTRIES IN li_vbpa_tmp
       WHERE kunnr = li_vbpa_tmp-kunnr.
      IF sy-subrc = 0.
        DELETE fp_i_kna1 WHERE loevm = abap_true.
        IF fp_i_kna1 IS NOT INITIAL.
          SORT fp_i_kna1 BY kunnr.
        ENDIF. " IF fp_i_kna1 IS NOT INITIAL
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF li_vbpa_tmp IS NOT INITIAL
  ENDIF. " IF sy-subrc = 0
*--->Begin of Changes for HANAtization on OTC_RDD_0121 by U033959 on 11-Sep-2019 in E1SK901545
  ENDIF.
*<---End of Changes for HANAtization on OTC_RDD_0121 by U033959 on 11-Sep-2019 in E1SK901545
* Get Order Reason Details
  li_vbak_tmp[] = fp_i_vbak[].
  SORT li_vbak_tmp BY augru.
  DELETE ADJACENT DUPLICATES FROM li_vbak_tmp COMPARING augru.

  IF li_vbak_tmp IS NOT INITIAL.
    SELECT augru " Order reason (reason for the business transaction)
           bezei " Description
      FROM tvaut " Sales Documents: Order Reasons: Texts
      INTO TABLE fp_i_tvaut
       FOR ALL ENTRIES IN li_vbak_tmp
     WHERE spras = sy-langu
       AND augru = li_vbak_tmp-augru.
    IF sy-subrc = 0.
      SORT fp_i_tvaut BY augru.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_vbak_tmp IS NOT INITIAL
  FREE li_vbak_tmp.

* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
* Get Order Type Text
  li_vbak_tmp[] = fp_i_vbak[].
  SORT li_vbak_tmp BY auart.
  DELETE ADJACENT DUPLICATES FROM li_vbak_tmp COMPARING auart.

  IF li_vbak_tmp IS NOT INITIAL.
    SELECT auart " Sales Document Type
           bezei " Description
      FROM tvakt " Sales Document Types: Texts
      INTO TABLE fp_i_tvakt
   FOR ALL ENTRIES IN li_vbak_tmp
     WHERE spras = lc_eng
       AND auart = li_vbak_tmp-auart.
    IF sy-subrc = 0.
      SORT fp_i_tvakt BY auart.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_vbak_tmp IS NOT INITIAL

* Get Item Category Text
  li_vbap_tmp[] = fp_i_vbap.
  SORT li_vbap_tmp BY pstyv.
  DELETE ADJACENT DUPLICATES FROM li_vbap_tmp COMPARING pstyv.

  IF li_vbap_tmp IS NOT INITIAL.
    SELECT pstyv " Sales document item category
           vtext " Description
      FROM tvapt " Sales document item categories: Texts
      INTO TABLE fp_i_tvapt
   FOR ALL ENTRIES IN li_vbap_tmp
     WHERE spras = lc_eng
       AND pstyv = li_vbap_tmp-pstyv.
    IF sy-subrc = 0.
      SORT fp_i_tvapt BY pstyv.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_vbap_tmp IS NOT INITIAL
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018

  FREE : li_lips_tmp,
         li_vbak_tmp,
         li_vbpa_tmp,
         li_vbap_tmp.
ENDFORM. " F_GET_OTHER_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FORMAT_QTY_AMT
*&---------------------------------------------------------------------*
*       Print Quantity and Amount with Sign
*----------------------------------------------------------------------*
*      -->FP_PLMIN               Sign (+ or -)
*      <--FP_DELV_QTY            Quantity
*      <--FP_UNIT_PRICE          Unit Price
*      <--FP_NET_PRICE           Net Price
*      <--FP_INV_UNITPR          Invoice Unit Price
*      <--FP_INV_AMT             Invoice Amount
*----------------------------------------------------------------------*
FORM f_format_qty_amt     USING fp_plmin      TYPE plmin " Quantity is calculated positively, negatively or not at all
                                fp_lips_qty   TYPE lgmng " Actual quantity delivered in stockkeeping units
                       CHANGING fp_delv_qty   TYPE lgmng " Actual quantity delivered in stockkeeping units
                                fp_unit_price TYPE kbetr " Rate (condition amount or percentage)
                                fp_net_price  TYPE kwert " Condition value
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
                                fp_inv_unitpr TYPE netwr_fp " Net value of the billing item in document currency
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
                                fp_inv_amt    TYPE netwr_fp. " Net value of the billing item in document currency

  CASE fp_plmin.
    WHEN '-'.
      fp_delv_qty   = fp_lips_qty   * ( -1 ).
      fp_unit_price = fp_unit_price * ( -1 ).
      fp_net_price  = fp_net_price  * ( -1 ).
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
      fp_inv_unitpr = fp_inv_unitpr * ( -1 ).
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
      fp_inv_amt    = fp_inv_amt    * ( -1 ).
    WHEN '+'.
      fp_delv_qty   = fp_lips_qty.
    WHEN OTHERS.
  ENDCASE.
ENDFORM. " F_FORMAT_QTY_AMT

*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_AMT_TO_EUR
*&---------------------------------------------------------------------*
*       Convert local currency amount to EUROs
*----------------------------------------------------------------------*
*  -->  FP_INV_DATE         Invoice Date
*  -->  FP_NET_PRICE        Invoice Currency
*  <--  FP_CONV_AMT         Converted Amount
*----------------------------------------------------------------------*
FORM f_convert_amt_to_eur    USING fp_inv_date TYPE sydatum " Current Date of Application Server
                                   fp_doc_curr TYPE waerk   " SD Document Currency
                          CHANGING fp_conv_amt TYPE any.    " Used for 3 different types

  CONSTANTS: lc_euro TYPE waerk VALUE 'EUR', " SD Document Currency
             lc_rate TYPE char1 VALUE 'M'.   " BSI: Tax class rate

  CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
    EXPORTING
      date             = fp_inv_date
      foreign_amount   = fp_conv_amt
      foreign_currency = fp_doc_curr
      local_currency   = lc_euro
      type_of_rate     = lc_rate
    IMPORTING
      local_amount     = fp_conv_amt
    EXCEPTIONS
      no_rate_found    = 1
      overflow         = 2
      no_factors_found = 3
      no_spread_found  = 4
      derived_2_times  = 5
      OTHERS           = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF. " IF sy-subrc <> 0
ENDFORM. " F_CONVERT_AMT_TO_EUR
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_WERKS
*&---------------------------------------------------------------------*
*       Validate Plant with Sales Org
*----------------------------------------------------------------------*
FORM f_validate_werks .

  DATA lv_werks TYPE werks_d. " Plant

  SELECT werks " Plant (Own or External)
    FROM tvkwz " Org.Unit: Allowed Plants per Sales Organization
   UP TO 1 ROWS
    INTO lv_werks
   WHERE vkorg = p_vkorg
     AND vtweg IN s_vtweg
     AND werks IN s_werks.
  ENDSELECT.

  IF sy-subrc NE 0.
    MESSAGE i809 WITH p_vkorg DISPLAY LIKE c_err. " Plant is not valid for Sales Org &
    LEAVE TO SCREEN 1000.
  ENDIF. " IF sy-subrc NE 0
  CLEAR lv_werks.
ENDFORM. " F_VALIDATE_WERKS
*&---------------------------------------------------------------------*
*&      Form  F_GET_DROPSHIP_DATA
*&---------------------------------------------------------------------*
*       Grt Dropship Data
*----------------------------------------------------------------------*
*      <--FP_I_LIPS          Delivery Items
*      <--FP_I_VBFA_SO       Sales Orders against PO
*      <--FP_I_VBAK          Sales Order Header
*      <--FP_I_VBAP          Sales Order Items
*----------------------------------------------------------------------*
FORM f_get_dropship_data  CHANGING fp_i_lips    TYPE ty_t_lips
                                   fp_i_vbfa_so TYPE ty_t_vbfa
                                   fp_i_vbak    TYPE ty_t_vbak
                                   fp_i_vbap    TYPE ty_t_vbap.

  DATA : li_foc_lips  TYPE ty_t_lips, " Internal Table for Drop-Ship Dlv
         li_lips_tmp  TYPE ty_t_lips, " Local Internal Table for Dlv
         li_foc_vbak  TYPE ty_t_vbak, " Internal Table for SO Header
         lwa_foc_vbak TYPE ty_vbak,   " WA for Drop-ship SO Header
         lwa_vbak     TYPE ty_vbak,   " WA for all SOs Header
         lwa_foc_lips TYPE ty_lips,   " WA for Drop-Ship Dlv
         lwa_lips     TYPE ty_lips.   " WA for all deliveries

  CONSTANTS lc_so TYPE char1 VALUE 'V'. " Doc Type for Sales Order

* Step I(b) - Get all Drop-Ship deliveries (header + item)
* Inner Join used bcoz VKORG is blank for these deliveries; so we need WERKS to limit the number of documents
  SELECT lips~vbeln     " Delivery
         lips~posnr     " Delivery Item
         lips~werks     " Plant
         lips~meins     " UOM
         lips~lgmng     " Quantity
         lips~vgbel     " Document number of the reference document
         lips~vgpos     " Item number of the reference item
         lips~uecha     " Higher Level Item
         likp~wadat_ist " Actual Goods Movement Date
  INTO TABLE li_foc_lips
    FROM lips           " SD document: Delivery: Item data
   INNER JOIN likp      " SD Document: Delivery Header Data
      ON lips~vbeln = likp~vbeln
   WHERE lips~werks IN s_werks
     AND likp~lfart IN s_focdlv
     AND likp~kunnr IN s_kunwe
     AND likp~kunag IN s_kunag
     AND likp~wadat_ist IN s_date
     AND likp~spe_loekz = space.

  IF sy-subrc = 0.
* Get the Sales Orders from these deliveries
    li_lips_tmp[] = li_foc_lips[].
    SORT li_lips_tmp BY vgbel vgpos.
    DELETE ADJACENT DUPLICATES FROM li_lips_tmp COMPARING vgbel vgpos.

    IF li_lips_tmp IS NOT INITIAL.
      SELECT vbelv " Preceding sales and distribution document
             posnv " Preceding item of an SD document
             vbeln " Subsequent sales and distribution document
             posnn " Subsequent item of an SD document
             plmin " Quantity is calculated positively, negatively or not at all
        FROM vbfa  " Sales Document Flow
        INTO TABLE fp_i_vbfa_so
     FOR ALL ENTRIES IN li_lips_tmp
       WHERE vbeln = li_lips_tmp-vgbel
         AND posnn = li_lips_tmp-vgpos
         AND vbtyp_n = lc_so.

      IF sy-subrc = 0.
        SORT fp_i_vbfa_so BY vbeln posnn.

* Get Sales Order Header details
        SELECT vbeln " Sales Document
               auart " Sales Document Type
               augru " Order reason (reason for the business transaction)
               waerk " SD Document Currency
               vtweg " Distribution Channel
* ---> Begin of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
               kostl " Cost Centre
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6735 by U034334 on 25-Jul-2018
          FROM vbak " Sales Document: Header Data
          INTO TABLE li_foc_vbak
       FOR ALL ENTRIES IN fp_i_vbfa_so
         WHERE vbeln = fp_i_vbfa_so-vbelv.

        IF sy-subrc = 0 .
          DELETE li_foc_vbak WHERE auart NOT IN s_auart
                                OR vtweg NOT IN s_vtweg.

          IF li_foc_vbak IS NOT INITIAL.
* Loop and collect all SO header data in one internal table
* Loop used on LI_FOC_VBAK bcoz the expected data volume is very less
            LOOP AT li_foc_vbak INTO lwa_foc_vbak.
              lwa_vbak = lwa_foc_vbak.
              APPEND lwa_vbak TO fp_i_vbak.
              CLEAR : lwa_foc_vbak,
                      lwa_vbak.
            ENDLOOP. " LOOP AT li_foc_vbak INTO lwa_foc_vbak
          ENDIF. " IF li_foc_vbak IS NOT INITIAL
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF li_lips_tmp IS NOT INITIAL
  ENDIF. " IF sy-subrc = 0

* Append Drop-Ship Deliveries to final table for Delivery
* Loop used on LI_FOC_LIPS bcoz the expected data volume is very less
  IF li_foc_lips IS NOT INITIAL.
    LOOP AT li_foc_lips INTO lwa_foc_lips.
      lwa_lips = lwa_foc_lips.
      APPEND lwa_lips TO fp_i_lips.
      CLEAR : lwa_foc_lips,
              lwa_lips.
    ENDLOOP. " LOOP AT li_foc_lips INTO lwa_foc_lips
  ENDIF. " IF li_foc_lips IS NOT INITIAL

* Delete the delivery line items where total qty is zero
  IF cb_noqty = abap_true.
    DELETE fp_i_lips WHERE lgmng IS INITIAL.
  ENDIF. " IF cb_noqty = abap_true

* Get line items for ALL sales orders
  IF fp_i_vbak IS NOT INITIAL.
    SORT fp_i_vbak BY vbeln.

    SELECT vbeln  " Sales Document
           posnr  " Sales Document Item
           matnr  " Material Number
           arktx  " Short text for sales order item
           pstyv  " Sales document item category
           zmeng  " Target quantity in sales units
           kwmeng " Cumulative Order Quantity in Sales Units
           wavwr  " Cost in document currency
           prctr  " Profit Center
           kostl  " Cost Center
      FROM vbap   " Sales Document: Item Data
      INTO TABLE fp_i_vbap
   FOR ALL ENTRIES IN fp_i_vbak
     WHERE vbeln = fp_i_vbak-vbeln
       AND pstyv IN s_pstyv.

    IF sy-subrc = 0.
      SORT fp_i_vbap BY vbeln posnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF fp_i_vbak IS NOT INITIAL

  IF fp_i_lips IS INITIAL OR
     fp_i_vbak IS INITIAL OR
     fp_i_vbap IS INITIAL.
    MESSAGE i115. " No data found for the input given in selection screen
    LEAVE LIST-PROCESSING.
  ENDIF. " IF fp_i_lips IS INITIAL OR

  FREE: li_foc_lips,
        li_lips_tmp,
        li_foc_vbak.
* <--- End   of Insert for D3_OTC_RDD_0121_Defect_6082 by U034334 on 16-May-2018
ENDFORM. " F_GET_DROPSHIP_DATA
