*----------------------------------------------------------------------*
***INCLUDE LZOTC_EDD_CONS_EXPOR_DECLF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FETCH_DELIVERY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_VBELN  text
*      <--P_LI_DELV_HEADER  text
*      <--P_LI_DELV_ITEMS  text
*----------------------------------------------------------------------*
FORM f_fetch_delivery_data  USING    fp_hu_det         TYPE zlex_tt_hu_details_from_ewm
                            CHANGING
                                     fp_li_delv_header TYPE ty_t_delv_header " Delivery header
                                     fp_li_delv_items  TYPE ty_t_delv_items. " Delivery item.
  IF fp_hu_det[] IS NOT INITIAL.

    SELECT vbeln " Delivery
           posnr " Delivery Item
           pstyv " Delivery item category
           matnr " Material Number
           werks " Plant
           lfimg " Actual quantity delivered (in sales units)
           vrkme " Sales unit
           vgbel " Document number of the reference document
           vgpos " Item number of the reference item
           uecha " Higher-Level Item of Batch Split Item
      FROM lips  " SD document: Delivery: Item data
      INTO TABLE fp_li_delv_items
      FOR ALL ENTRIES IN fp_hu_det
      WHERE vbeln = fp_hu_det-delivery
      AND   posnr = fp_hu_det-itmno.
    IF sy-subrc IS INITIAL.
      SORT fp_li_delv_items BY vbeln posnr.

      SELECT vbeln " Delivery
         vkorg     " Sales Organization
         lfart     " Delivery Type
         vbtyp     " SD document category
         kunag     " Sold-to party
         vkoiv     " Sales organization for intercompany billing
         vtwiv     " Distribution channel for intercompany billing
         waerk     " SD Document Currency
         spaiv     " Division for intercompany billing
         fkaiv     " Billing type for intercompany billing
         fkdiv     " Billing date for intercompany billing
         kuniv     " Customer number for intercompany billing
    FROM likp      " SD Document: Delivery Header Data
    INTO TABLE fp_li_delv_header
    FOR ALL ENTRIES IN fp_li_delv_items
    WHERE vbeln = fp_li_delv_items-vbeln.
      IF sy-subrc IS INITIAL.
        SORT  fp_li_delv_header BY  vbeln.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF fp_hu_det[] IS NOT INITIAL
ENDFORM. " F_FETCH_DELIVERY_DATA
*&---------------------------------------------------------------------*
*&      Form  F_FILL_BAPI_STRUCTURE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_DELV_HEADER  text
*      -->P_LI_DELV_ITEMS  text
*      <--P_LI_BILLINGDATAIN  text
*----------------------------------------------------------------------*
FORM f_fill_bapi_structure  USING
                            fp_li_delv_header    TYPE ty_t_delv_header            " Delivery header data
                            fp_li_delv_items     TYPE ty_t_delv_items             " Delivery item data
                            fp_hu_det            TYPE zlex_tt_hu_details_from_ewm " HU Details from ewm for Hu level CI
                            fp_status            TYPE ty_t_zdev_enh
                            CHANGING
                            fp_li_billingdatain  TYPE ty_t_billingdatain.

  CONSTANTS:        lc_fkart TYPE z_criteria    VALUE 'FKART', " Enh. Criteria
                    lc_land1 TYPE z_criteria    VALUE 'LAND1', " Enh. Criteria
                    lc_u     TYPE char1         VALUE '_'.     " _ of type CHAR1

*---FIELD SYMBOLS------------------------------------------------------*
  FIELD-SYMBOLS :
       <lfs_delv_header>      TYPE ty_delivery_header, " Delivery header data
       <lfs_delv_items>       TYPE ty_delivery_items,  " Delivery item data
       <lfs_billing>          TYPE bapivbrk.           " Communication Fields for Billing Header Fields


  DATA: lwa_hudet             TYPE zlex_s_hu_details_from_ewm, " HU Details from ewm for Hu level CI
        lwa_text              TYPE bapikomfktx,                " Communication Structure Texts for Billing Interface
        lv_emi_fkart          TYPE fpb_low,                    " From Value
        lwa_status            TYPE zdev_enh_status.            " Enhancement Status

  LOOP AT fp_li_delv_header ASSIGNING <lfs_delv_header> .

    LOOP AT fp_li_delv_items ASSIGNING <lfs_delv_items>
                                    WHERE vbeln = <lfs_delv_header>-vbeln .

      APPEND INITIAL LINE TO fp_li_billingdatain ASSIGNING <lfs_billing>.
*     Item number of the reference item
      <lfs_billing>-ref_item    = <lfs_delv_items>-posnr.
*     Material number
      <lfs_billing>-material    = <lfs_delv_items>-matnr. "fp_hu_det-material.
**     Cumulative Order Quantity in Sales Units
*      <lfs_billing>-req_qty     = <lfs_delv_items>-lfimg.
      <lfs_billing>-origindoc    = <lfs_delv_items>-vgbel.
      <lfs_billing>-item         = <lfs_delv_items>-vgpos.
      <lfs_billing>-itm_number   = <lfs_delv_items>-uecha.
*     Sales unit
      <lfs_billing>-sales_unit  = <lfs_delv_items>-vrkme.
*     Plant
      <lfs_billing>-plant       = <lfs_delv_items>-werks.
*     Sales document item category
      <lfs_billing>-item_categ  = <lfs_delv_items>-pstyv.
*       Sales Organization
      <lfs_billing>-salesorg   = <lfs_delv_header>-vkorg.
*       Distribution Channel
      <lfs_billing>-distr_chan = <lfs_delv_header>-vtwiv.
*       Division
      <lfs_billing>-division   = <lfs_delv_header>-spaiv.
*       Document number of the reference document(Delivery number)
      <lfs_billing>-ref_doc    = <lfs_delv_header>-vbeln.
*      IF  <lfs_delv_header>-fkdiv IS INITIAL.
*        <lfs_delv_header>-fkdiv = sy-datum.
*      ENDIF. " IF <lfs_delv_header>-fkdiv IS INITIAL
*       Date for pricing and exchange rate
      <lfs_billing>-price_date = <lfs_delv_header>-fkdiv.
*       Billing date for billing index and printout
      <lfs_billing>-bill_date  = <lfs_delv_header>-fkdiv.

* Low Entries so no binary Search
      READ TABLE fp_hu_det INTO lwa_hudet
                            WITH KEY delivery = <lfs_delv_header>-vbeln
                                     itmno    = <lfs_delv_items>-posnr.
      IF sy-subrc = 0.
* Use Partial qty from EWM if qty in ECC and EWM does not match
        IF <lfs_delv_items>-lfimg NE lwa_hudet-qty.
          <lfs_billing>-req_qty     = lwa_hudet-qty.
        ELSE. " ELSE -> IF <lfs_delv_items>-lfimg NE lwa_hudet-qty
*     Cumulative Order Quantity in Sales Units
          <lfs_billing>-req_qty     = <lfs_delv_items>-lfimg.
        ENDIF. " IF <lfs_delv_items>-lfimg NE lwa_hudet-qty

* Begin of change for Defect 7851 by U033876
* below special code for fr and Spain not required
* as we add delivery type also in emi
** Billing type Determination
** Low Entries so no binary Search
*        READ TABLE fp_status INTO lwa_status
*                             WITH KEY criteria = lc_land1
*                                      sel_low  = lwa_hudet-dest_cntry
*                                      active = abap_true.
*        IF sy-subrc = 0.
*          CLEAR: lv_emi_fkart.
** Only do sorg_Country_region if country is France or SPain
*          CONCATENATE <lfs_delv_header>-vkorg lc_u lwa_hudet-dest_cntry lc_u lwa_hudet-regio
*                               INTO lv_emi_fkart .
*
** Low Entries so no binary Search
*          READ TABLE fp_status INTO lwa_status
*                               WITH KEY criteria = lc_fkart
*                                        sel_low  = lv_emi_fkart
*                                        active = abap_true.
*          IF sy-subrc = 0.
*            <lfs_billing>-ordbilltyp = lwa_status-sel_high.
*          ELSE. " ELSE -> IF sy-subrc = 0
*            CLEAR:lv_emi_fkart.
** Chek with concatenate Sorg_DestCountry to check FKART
*            CONCATENATE <lfs_delv_header>-vkorg lc_u lwa_hudet-dest_cntry
*                                 INTO lv_emi_fkart .
*            READ TABLE fp_status INTO lwa_status
*                                 WITH KEY criteria = lc_fkart
*                                          sel_low  = lv_emi_fkart
*                                          active = abap_true.
*            IF sy-subrc = 0.
*              <lfs_billing>-ordbilltyp = lwa_status-sel_high.
*            ELSE. " ELSE -> IF sy-subrc = 0
**     Parallel Quantity just used as place holder for delivery qty in ZHU
** as we calculate Zu06 condition value based on delivery qty and Hu qty
*              <lfs_billing>-parallel_qty  = <lfs_delv_items>-lfimg.
*              <lfs_billing>-ordbilltyp = c_zhu.
*              gv_copy_cond  = abap_true.
*            ENDIF. " IF sy-subrc = 0
*          ENDIF. " IF sy-subrc = 0
*        ELSE. " ELSE -> IF sy-subrc = 0
* For non FR/ES destination countries Directly we concatenate sorg_destctry
* Low Entries so no binary Search

* Chek with concatenate sorg_destctry  to check FKART
*          CONCATENATE <lfs_delv_header>-vkorg lc_u lwa_hudet-dest_cntry
*                               INTO lv_emi_fkart .
* End  of change for Defect 7851 by U033876
        CLEAR:lv_emi_fkart.
* Added Delivery type also at end based on defect 7851
        CONCATENATE <lfs_delv_header>-vkorg lc_u lwa_hudet-dest_cntry lc_u <lfs_delv_header>-lfart
                            INTO lv_emi_fkart .
        READ TABLE fp_status INTO lwa_status
                             WITH KEY criteria = lc_fkart
                                      sel_low  = lv_emi_fkart
                                      active = abap_true.
        IF sy-subrc = 0.
          <lfs_billing>-ordbilltyp = lwa_status-sel_high.
* Begin of Change for Defect 7851 by U033876
          IF <lfs_billing>-ordbilltyp = c_zhu .
            <lfs_billing>-parallel_qty  = <lfs_delv_items>-lfimg.
            gv_copy_cond  = abap_true.
          ENDIF. " IF <lfs_billing>-ordbilltyp = c_zhu
* End of Change for Defect 7851 by U033876
        ELSE. " ELSE -> IF sy-subrc = 0
          <lfs_billing>-parallel_qty  = <lfs_delv_items>-lfimg.
          <lfs_billing>-ordbilltyp = c_zhu.
          gv_copy_cond  = abap_true.
        ENDIF. " IF sy-subrc = 0
* Begin of change for defect 7851 by U033876
*        ENDIF. " IF sy-subrc = 0
* End of change for Defect 7851 by u033876

      ENDIF. " IF sy-subrc = 0
*       Payer
      <lfs_billing>-payer      = <lfs_delv_header>-kuniv.
*       Document category of preceding SD document
      <lfs_billing>-ref_doc_ca = <lfs_delv_header>-vbtyp.
* sold-to from header
      <lfs_billing>-sold_to   =  <lfs_delv_header>-kunag.
* currency
      <lfs_billing>-currency = <lfs_delv_header>-waerk.
    ENDLOOP. " LOOP AT fp_li_delv_items ASSIGNING <lfs_delv_items>
  ENDLOOP. " LOOP AT fp_li_delv_header ASSIGNING <lfs_delv_header>
  UNASSIGN : <lfs_delv_items> , " delivery items
             <lfs_delv_header>. " delivery header
ENDFORM. " F_FILL_BAPI_STRUCTURE
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_BILLINGDOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_BILLINGDATAIN  text
*      -->P_LV_VBELN  text
*      <--P_FP_RETURN_CODE  text
*----------------------------------------------------------------------*
FORM f_create_billingdoc  USING
                             fp_li_billingdatain TYPE ty_t_billingdatain " Communication Fields for Billing Header Fields
                             fp_li_condition     TYPE ty_t_bapikomv
                             fp_hu_det           TYPE zlex_tt_hu_details_from_ewm
                          CHANGING
                             fp_return_code      TYPE sy-subrc           " Return Value of ABAP Statements
                             fp_return           TYPE bapiret2_t.

*--TABLES--------------------------------------------------------------*
  DATA : li_errors        TYPE STANDARD TABLE OF bapivbrkerrors,  " Information on Incorrect Processing of Preceding Items
         li_return        TYPE STANDARD TABLE OF bapiret1,        " Return Parameter
         li_success       TYPE STANDARD TABLE OF bapivbrksuccess, " Information for Successfully Processing Billing Doc. Items
         li_billingdatain TYPE ty_t_billingdatain,                " Communication Fields for Billing Header Fields
         lwa_success      TYPE bapivbrksuccess,                   " Communication Fields for Billing Header Fields
         lwa_return       TYPE bapiret2,                          " Return Parameter
         lv_par1          TYPE sy-msgv1.                          " Message Variable

  SET UPDATE TASK LOCAL.
* BAPI is called ---
* --- posting of data.
  PERFORM f_bapi_run USING    fp_li_billingdatain
                               fp_li_condition
                                   fp_hu_det
                          CHANGING li_success
                                   li_errors
                                   li_return.
* check for any errors and if sucessful then update the header text with Hu no
  IF li_success IS NOT INITIAL.
    CLEAR fp_return_code.
    READ TABLE li_success INTO lwa_success INDEX 1.
    IF sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
* Update the Header text with HU number if invoice created successfully
      PERFORM f_update_head_text  USING lwa_success-bill_doc
                                        fp_hu_det.
      CLEAR: lv_par1.
      lv_par1 = lwa_success-bill_doc.
      CALL FUNCTION 'BALW_BAPIRETURN_GET2'
        EXPORTING
          type   = c_succe_s "  of type
          cl     = 'ZOTC_MSG'
          number = '306'
          par1   = lv_par1
        IMPORTING
          return = lwa_return.

      APPEND lwa_return TO fp_return.
      CLEAR: lwa_return.
    ENDIF. " IF sy-subrc = 0
  ELSE. " ELSE -> IF li_success IS NOT INITIAL
* Else if the BAPI runs into any error populate custom appl. log
    READ TABLE li_return WITH KEY type = c_error_e TRANSPORTING NO FIELDS. " Return with key of type
*   Binary search not included in READ as li_return will have very few records
    IF sy-subrc IS INITIAL.
      fp_return_code = '4'.
*   implement error logging logic
      APPEND LINES OF li_return TO fp_return.
    ELSE. " ELSE -> IF sy-subrc IS INITIAL
*     Binary search not included in READ as li_return will have very few records
      READ TABLE li_return WITH KEY type = c_error_a TRANSPORTING NO FIELDS. " Return with key of type
      IF sy-subrc IS INITIAL.
*   implement error logging logic
        fp_return_code = '4'.
*   implement error logging logic
        APPEND LINES OF li_return TO fp_return.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_success IS NOT INITIAL


ENDFORM. " F_CREATE_BILLINGDOC
*&---------------------------------------------------------------------*
*&      Form  F_BAPI_TEST_RUN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FP_LI_BILLINGDATAIN  text
*      <--P_LI_SUCCESS  text
*      <--P_LI_ERRORS  text
*      <--P_LI_RETURN  text
*----------------------------------------------------------------------*
FORM f_bapi_run       USING  fp_li_billingdatain TYPE ty_t_billingdatain " Communication Fields for Billing Header Fields
                             fp_li_condition     TYPE ty_t_bapikomv
                             fp_hu_dat           TYPE zlex_tt_hu_details_from_ewm
                      CHANGING fp_li_success     TYPE ty_t_success       " Information for Successfully Processing Billing Doc. Items
                               fp_li_errors      TYPE ty_t_errors        " Information on Incorrect Processing of Preceding Items
                               fp_li_return      TYPE ty_t_return.       " Return Parameter

  DATA:  li_hu_det        TYPE zlex_tt_hu_details_from_ewm,
         lwa_creatordata  TYPE bapicreatordata,            " Information for Setting Up Data Records
         lwa_hu_det       TYPE zlex_s_hu_details_from_ewm. " HU Details from ewm for Hu level CI

**  Send the Data from HU_det to Global class memory
** this data will be used in prog: RV60B910
  zcl_otc_edd_0415_hu_lvl_ci=>set_hu_lvl_ci_data(
     EXPORTING
     im_hu_det = fp_hu_dat ).

  lwa_creatordata-created_by = sy-uname.
  lwa_creatordata-created_on = sy-datum.

  SET UPDATE TASK LOCAL.

  CALL FUNCTION 'BAPI_BILLINGDOC_CREATEMULTIPLE'
    EXPORTING
      creatordatain   = lwa_creatordata
      testrun         = abap_false
    TABLES
      billingdatain   = fp_li_billingdatain
      conditiondatain = fp_li_condition
      errors          = fp_li_errors
      return          = fp_li_return
      success         = fp_li_success.


ENDFORM. " F_BAPI_TEST_RUN

*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GROUP_BOM_ITEMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IM_HU_DET  text
*      <--P_LI_HU_DET  text
*----------------------------------------------------------------------*
FORM f_group_bom_items  USING    fp_im_hu_det  TYPE zlex_tt_hu_details_from_ewm
                        CHANGING fp_li_hu_det  TYPE zlex_tt_hu_details_from_ewm.
  DATA: lwa_hudet      TYPE zlex_s_hu_details_from_ewm, " HU Details from ewm for Hu level CI
        lwa_hudet_bomh TYPE zlex_s_hu_details_from_ewm. " HU Details from ewm for Hu level CI
  FIELD-SYMBOLS: <lfs_hudet_bomh> TYPE zlex_s_hu_details_from_ewm. " HU Details from ewm for Hu level CI
  DATA: lv_n_wieght TYPE ntgew_vekp, " Loading Weight of Handling Unit
        lv_g_wieght TYPE brgew_vekp, " Total Weight of Handling Unit
        lv_hu_volu  TYPE btvol_vekp, " Total Volume of Handling Unit
        li_hu_det_bom TYPE zlex_tt_hu_details_from_ewm.
  SORT: fp_im_hu_det BY huident delivery itmno.
  CLEAR: fp_li_hu_det[].
  fp_li_hu_det[] =  fp_im_hu_det[].
  LOOP AT fp_li_hu_det INTO lwa_hudet WHERE bomh_itmno IS NOT INITIAL.
    gv_bom  = abap_true.
    lwa_hudet-itmno = lwa_hudet-bomh_itmno.
    CLEAR: lwa_hudet-bomh_itmno.
    CLEAR: lwa_hudet-serid.
*    APPEND lwa_hudet TO fp_li_hu_det. "total Items
    APPEND lwa_hudet TO li_hu_det_bom. " only BOMH Items
    CLEAR:lwa_hudet.
  ENDLOOP. " LOOP AT fp_li_hu_det INTO lwa_hudet WHERE bomh_itmno IS NOT INITIAL
  IF sy-subrc NE 0.
    fp_li_hu_det[] =  fp_im_hu_det[].
  ENDIF. " IF sy-subrc NE 0

  IF gv_bom = abap_true.
    SORT li_hu_det_bom BY huident delivery itmno.
    DELETE ADJACENT DUPLICATES FROM li_hu_det_bom COMPARING huident delivery itmno.
    SORT fp_li_hu_det BY huident delivery itmno.
    SORT li_hu_det_bom BY huident delivery itmno.
* Loop through the BOM Header items and
* calculate the value of net weight,gross weight and volume
* based on Bom Items
    LOOP AT li_hu_det_bom  ASSIGNING <lfs_hudet_bomh>. "INTO lwa_hudet_bomh  . "WHERE bomh_itmno IS NOT INITIAL. "20->10
      CLEAR: <lfs_hudet_bomh>-n_wieght,
             <lfs_hudet_bomh>-hu_wieght,
             <lfs_hudet_bomh>-hu_volume,
             lv_n_wieght,
             lv_g_wieght,
             lv_hu_volu.
      LOOP AT fp_li_hu_det INTO lwa_hudet
                              WHERE bomh_itmno = <lfs_hudet_bomh>-itmno. "10

        lv_n_wieght = lwa_hudet-n_wieght  + lv_n_wieght.
        lv_g_wieght = lwa_hudet-hu_wieght + lv_g_wieght. "lwa_hudet_bomh-hu_wieght.
        lv_hu_volu  = lwa_hudet-hu_volume + lv_hu_volu . "lwa_hudet_bomh-hu_volume.

      ENDLOOP. " LOOP AT fp_li_hu_det INTO lwa_hudet
      <lfs_hudet_bomh>-n_wieght  = lv_n_wieght.
      <lfs_hudet_bomh>-hu_wieght = lv_g_wieght.
      <lfs_hudet_bomh>-hu_volume = lv_hu_volu.
    ENDLOOP. " LOOP AT li_hu_det_bom ASSIGNING <lfs_hudet_bomh>

    IF li_hu_det_bom[] IS NOT INITIAL.
      APPEND LINES OF li_hu_det_bom TO fp_li_hu_det[].
      SORT fp_li_hu_det BY huident delivery itmno.
    ENDIF. " IF li_hu_det_bom[] IS NOT INITIAL
  ENDIF. " IF gv_bom = abap_true
ENDFORM. " F_GROUP_BOM_ITEMS
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_HEAD_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LWA_BILLINGDATAIN_BILL_DOC  text
*      -->P_FP_HU_DET  text
*----------------------------------------------------------------------*
FORM f_update_head_text  USING    fp_bill_doc TYPE bill_doc " Sales and Distribution Document Number
                                  fp_hu_det TYPE zlex_tt_hu_details_from_ewm.

  CONSTANTS:        lc_object TYPE tdobject VALUE 'VBBK', " Texts: Application Object
                    lc_tdid  TYPE tdid     VALUE 'Z017'.  " Text ID
  DATA: lv_tdname TYPE tdobname,                          " Name
        lwa_header       TYPE thead,                      " Header workarea
        lwa_hudet        TYPE zlex_s_hu_details_from_ewm, " HU Details from ewm for Hu level CI
        lwa_lines        TYPE tline,                      " Short Text
        li_lines         TYPE STANDARD TABLE OF tline.    " Short text
  CLEAR:  lv_tdname,
          lwa_header,
          lwa_hudet,
          lwa_lines,
          li_lines[] .
  lv_tdname               = fp_bill_doc.
  lwa_header-tdobject     = lc_object.
  lwa_header-tdid         = lc_tdid .
  lwa_header-tdname       = lv_tdname.
  lwa_header-tdspras      = sy-langu .

  READ TABLE fp_hu_det INTO lwa_hudet INDEX 1.
  IF sy-subrc = 0.
    lwa_lines-tdline = lwa_hudet-huident.
    APPEND lwa_lines TO li_lines.
  ENDIF. " IF sy-subrc = 0


  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      header          = lwa_header
      savemode_direct = abap_true
    TABLES
      lines           = li_lines
    EXCEPTIONS
      id              = 1
      language        = 2
      name            = 3
      object          = 4
      OTHERS          = 5.


ENDFORM. " F_UPDATE_HEAD_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_FILL_COND_STRUCTURE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_DELV_HEADER  text
*      -->P_LI_DELV_ITEMS  text
*      -->P_IM_HU_DET  text
*      <--P_LI_CONDITION  text
*----------------------------------------------------------------------*
FORM f_fill_cond_structure  USING
                            fp_li_delv_header    TYPE ty_t_delv_header            " Delivery header data
                            fp_li_delv_items     TYPE ty_t_delv_items             " Delivery item data
                            fp_hu_det            TYPE zlex_tt_hu_details_from_ewm " HU Details from ewm for Hu level CI
                            fp_li_billingdatain  TYPE ty_t_billingdatain
                            fp_status            TYPE ty_t_zdev_enh
                            CHANGING
                            fp_price_error       TYPE boole_d                     " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
                            fp_li_condition      TYPE ty_t_bapikomv .

  TYPES: BEGIN OF lty_vbfa,
          vbelv TYPE vbeln_von,  " Preceding sales and distribution document
          posnv TYPE posnr_von,  " Preceding item of an SD document
          vbeln TYPE vbeln_nach, " Subsequent sales and distribution document
          posnn TYPE posnr_nach, " Subsequent item of an SD document
          vbtyp_n TYPE vbtyp_n,  " Document category of subsequent document
         END OF lty_vbfa,
         BEGIN OF lty_vbrk,
            vbeln TYPE vbeln_vf, " Billing Document
            waerk TYPE waerk,    " SD Document Currency
            knumv TYPE knumv,    " Number of the document condition
         END OF   lty_vbrk,
         BEGIN OF lty_vbrkp,
            vbeln TYPE vbeln_vf, " Billing Document
            waerk TYPE waerk,    " SD Document Currency
            knumv TYPE knumv,    " Number of the document condition
            posnr TYPE posnr_vf, " Billing item
            fkimg TYPE fkimg,    " Actual Invoiced Quantity
            vbelv TYPE vbeln_vl, " Delivery
            posnv TYPE posnr_vl, " Delivery Item
         END OF   lty_vbrkp,
         BEGIN OF lty_konv,
           knumv TYPE knumv,     " Number of the document condition
           kposn TYPE kposn,     " Condition item number
           kschl TYPE kschl,     " Condition Type
           kawrt TYPE kawrt,     " Condition base value
           kbetr TYPE kbetr,     " Rate (condition amount or percentage)
           waers TYPE waers,     " Currency Key
           kpein TYPE kpein,     " Condition pricing unit
           kmein TYPE kvmei,     " Condition unit in the document
           kwert TYPE kwert,     " Condition value
         END OF lty_konv.

  DATA: li_konv    TYPE STANDARD TABLE OF lty_konv,
        li_vbfa    TYPE STANDARD TABLE OF lty_vbfa,
        li_vbrk    TYPE STANDARD TABLE OF lty_vbrk,
        li_vbrk_tmp TYPE STANDARD TABLE OF lty_vbrk,
        lwa_vbrk   TYPE lty_vbrk,
        li_vbrkp   TYPE STANDARD TABLE OF lty_vbrkp,
        lwa_vbrkp  TYPE lty_vbrkp,
        li_vbrkp_tmp TYPE STANDARD TABLE OF lty_vbrkp,
        li_vbrkp_tmp1 TYPE STANDARD TABLE OF lty_vbrkp,
        li_kschl   TYPE STANDARD TABLE OF selopt,          " Transfer Structure for Select Options
        lv_fkart_cpy TYPE fkart,                           " Billing Type
        lwa_status TYPE selopt,                            " Transfer Structure for Select Options
        lwa_billingdatain TYPE bapivbrk,                   " Communication Fields for Billing Header Fields
        lwa_hu_det        TYPE zlex_s_hu_details_from_ewm, " HU Details from ewm for Hu level CI
        lwa_condition TYPE bapikomv,                       " Communication Fields for Conditions
        lv_cond_val TYPE kwert,                            " Condition value
        lv_hu_qty   TYPE vemng,                            " Base Quantity Packed in the Handling Unit Item
        lv_del_qty  TYPE kwmeng,                           " Cumulative Order Quantity in Sales Units
        lv_bill_index  TYPE sy-tabix.                      " Index of Internal Tables


  FIELD-SYMBOLS: <lfs_vbrkp>  TYPE lty_vbrkp,
                 <lfs_vbrk>   TYPE lty_vbrk,
                 <lfs_vbfa>   TYPE lty_vbfa,
                 <lfs_konv>   TYPE lty_konv,
                 <lfs_status> TYPE zdev_enh_status. " Enhancement Status

  CONSTANTS: lc_zdf8        TYPE fkart      VALUE 'ZDF8',       " Billing Type
             lc_kschl       TYPE z_criteria VALUE 'KSCHL',      " Enh. Criteria
             lc_kschl_zhu   TYPE z_criteria VALUE 'KSCHL_ZHU',  " Enh. Criteria
             lc_fkart_copy  TYPE z_criteria VALUE 'FKART_COPY', " Enh. Criteria
             lc_za06        TYPE kschl      VALUE 'ZA06',       " Condition Type
             lc_u           TYPE vbtyp_n    VALUE 'U',          " Document category of subsequent document
             lc_0           TYPE kawrt      VALUE '0'.          " Condition base value

* Get the condition records from ZDF8 billing document for that delivery and pass the
* to the li_condition so that we get condition record values from "ZDF8" billing doc
  CLEAR: li_kschl[],
         lv_fkart_cpy,
         fp_price_error,
         fp_li_condition[].
* Buld a range for condition types from emi
  LOOP AT fp_status ASSIGNING <lfs_status> WHERE criteria = lc_kschl
                                           AND   active   = abap_true .
    lwa_status-sign     = <lfs_status>-sel_sign.
    lwa_status-option   = <lfs_status>-sel_option.
    lwa_status-low      = <lfs_status>-sel_low.
    APPEND lwa_status TO li_kschl.
    CLEAR: lwa_status.
  ENDLOOP. " LOOP AT fp_status ASSIGNING <lfs_status> WHERE criteria = lc_kschl

  READ TABLE fp_status ASSIGNING <lfs_status>
                       WITH KEY criteria = lc_fkart_copy
                                active   = abap_true.
  IF sy-subrc = 0.
    lv_fkart_cpy = <lfs_status>-sel_low.
  ENDIF. " IF sy-subrc = 0


  IF fp_hu_det[] IS NOT INITIAL.

    SELECT vbelv posnv vbeln posnn vbtyp_n FROM vbfa INTO TABLE li_vbfa
                       FOR ALL ENTRIES IN fp_hu_det
                       WHERE vbelv = fp_hu_det-delivery
*                       AND   posnv = fp_hu_det-itmno
                       AND   vbtyp_n = lc_u.
    IF sy-subrc = 0.
      SELECT a~vbeln                         " Billing Document
             a~waerk                         " SD Document Currency
             a~knumv                         " Number of the document condition
             b~posnr                         " Billing item
             b~fkimg                         " Actual Invoiced Quantity
             INTO TABLE li_vbrkp
             FROM  vbrk AS a  INNER JOIN vbrp AS b
                    ON a~vbeln = b~vbeln
                    FOR ALL ENTRIES IN li_vbfa
                     WHERE a~vbeln  = li_vbfa-vbeln
                     AND   b~posnr  = li_vbfa-posnn
                     AND   fkart    = lv_fkart_cpy
                     AND   fksto    = space. " not cancelled

      IF sy-subrc = 0.
        SORT li_vbrkp BY vbeln posnr.
* Create a temp internal which holds delivery , item and
        LOOP AT li_vbfa ASSIGNING <lfs_vbfa>.
          READ TABLE li_vbrkp ASSIGNING <lfs_vbrkp>
                          WITH KEY vbeln = <lfs_vbfa>-vbeln
                                   posnr = <lfs_vbfa>-posnn BINARY SEARCH.
          IF sy-subrc = 0.
            <lfs_vbrkp>-vbelv = <lfs_vbfa>-vbelv.
            <lfs_vbrkp>-posnv = <lfs_vbfa>-posnv.
          ENDIF. " IF sy-subrc = 0
        ENDLOOP. " LOOP AT li_vbfa ASSIGNING <lfs_vbfa>
* We need latest ZDF8 which is not cancelled
*        CLEAR: li_vbrkp_tmp[], li_vbrkp_tmp1[].
*        li_vbrkp_tmp1[] = li_vbrkp[].
*        SORT li_vbrkp_tmp1 BY vbeln DESCENDING.
*        DELETE ADJACENT DUPLICATES FROM li_vbrkp_tmp1 COMPARING vbeln . "ZDF8 billing docs
* Read the latest ZDF8 and incase we have multiple items for that ZDFE pass them into seperate internal table
*        READ TABLE li_vbrkp_tmp1  INTO lwa_vbrkp INDEX 1.
*        IF sy-subrc = 0.
*          LOOP AT li_vbrkp ASSIGNING <lfs_vbrkp> WHERE vbeln = lwa_vbrkp-vbeln .
*            APPEND <lfs_vbrkp> TO li_vbrkp_tmp.
*          ENDLOOP. " LOOP AT li_vbrkp ASSIGNING <lfs_vbrkp> WHERE vbeln = lwa_vbrkp-vbeln
*
*
*
*          IF li_vbrkp_tmp[] IS NOT INITIAL.
*            CLEAR: li_vbrkp[].
*            li_vbrkp[] = li_vbrkp_tmp[].
*          ENDIF. " IF li_vbrkp_tmp[] IS NOT INITIAL
*        IF li_vbrkp_tmp1[] IS NOT INITIAL.
*          CLEAR li_vbrkp[] .
*          li_vbrkp[] = li_vbrkp_tmp1[].
*        ENDIF. " IF li_vbrkp_tmp1[] IS NOT INITIAL
        IF li_vbrkp[] IS NOT INITIAL.
          SELECT knumv           " Number of the document condition
                 kposn           " Condition item number
                 kschl           " Condition type
                 kawrt           " Condition base value
                 kbetr           " Rate (condition amount or percentage)
                 waers           " Currency Key
                 kpein           " Condition pricing unit
                 kmein           " Condition unit in the document
                 kwert FROM konv " Conditions (Transaction Data)
                        INTO TABLE li_konv
                        FOR ALL ENTRIES IN li_vbrkp
                        WHERE knumv = li_vbrkp-knumv
*                      AND   kposn = li_vbrkp-posnr
                        AND   kschl IN li_kschl.
          IF sy-subrc = 0.
            SORT  li_konv BY kschl.
            LOOP AT  li_konv ASSIGNING <lfs_konv>  WHERE kschl = lc_za06 "Za06 is main condition to see Qty NE 0
                                                   AND   kawrt GT lc_0 .
* if qty is > 0 then do nothing here
            ENDLOOP. " LOOP AT li_konv ASSIGNING <lfs_konv> WHERE kschl = lc_za06
            IF sy-subrc NE 0.
* If qty is 0, raise an error message
              fp_price_error = abap_true.
              EXIT.
            ENDIF. " IF sy-subrc NE 0
            IF li_kschl IS NOT INITIAL.
              CLEAR: lv_del_qty, lv_hu_qty, lv_bill_index.
              LOOP AT fp_li_billingdatain INTO lwa_billingdatain.
                lv_bill_index = lv_bill_index + 1.
                lv_del_qty = lwa_billingdatain-parallel_qty.
                READ TABLE li_vbrkp ASSIGNING <lfs_vbrkp>
                                                 WITH KEY vbelv = lwa_billingdatain-ref_doc
                                                         posnv = lwa_billingdatain-ref_item.
                IF sy-subrc NE 0.
* For BOm Items check for higher line line item
                  READ TABLE li_vbrkp ASSIGNING <lfs_vbrkp>
                                                  WITH KEY vbelv = lwa_billingdatain-ref_doc
                                                           posnv = lwa_billingdatain-itm_number. "uecha..
                  IF sy-subrc = 0.
                    lv_del_qty = <lfs_vbrkp>-fkimg. " this will get actual invoiced qty of ZDf8
                  ENDIF. " IF sy-subrc = 0
                ENDIF. " IF sy-subrc NE 0
                IF sy-subrc = 0 . "<lfs_vbrkp> IS ASSIGNED.
                  READ TABLE fp_hu_det INTO lwa_hu_det
                                           WITH KEY delivery = lwa_billingdatain-ref_doc
                                                    itmno    = lwa_billingdatain-ref_item.
                  IF sy-subrc = 0.
                    lv_hu_qty = lwa_hu_det-qty.
                  ENDIF. " IF sy-subrc = 0
                  LOOP AT li_konv ASSIGNING <lfs_konv>  WHERE knumv = <lfs_vbrkp>-knumv
                                                        AND   kposn = <lfs_vbrkp>-posnr. "Defect 7913-"lwa_billingdatain-item.
                    READ TABLE fp_status ASSIGNING <lfs_status>
                                              WITH KEY  criteria = lc_kschl_zhu
                                                        sel_low  = <lfs_konv>-kschl
                                                        active   = abap_true .
                    IF  sy-subrc = 0.
                      lwa_condition-data_index  = lv_bill_index .
* just add "ZU06" which will determine necessary condition records from pricing
                      lwa_condition-cond_type   =  <lfs_status>-sel_high. "'ZU06'.
                      CLEAR: lv_cond_val.
** formula to calculate cond value
*                 cond val = HU item Qty * Source Item Condition amount / Delivery Item Qty
                      IF   lv_del_qty IS NOT INITIAL.
*                    lv_cond_val = lv_hu_qty * ( <lfs_konv>-kwert / lv_del_qty ).
* Below Formula will get Unit value of condition which is passed
                        lv_cond_val =  <lfs_konv>-kwert / lv_del_qty .
                      ELSE. " ELSE -> IF lv_del_qty IS NOT INITIAL
                        lv_cond_val = 0.
                      ENDIF. " IF lv_del_qty IS NOT INITIAL
                      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
                        EXPORTING
                          currency        = lwa_billingdatain-currency
                          amount_internal = lv_cond_val
                        IMPORTING
                          amount_external = lwa_condition-cond_value.

                      lwa_condition-cond_curr   = lwa_billingdatain-currency. "<lfs_konv>-waers.
                      lwa_condition-cond_p_unt  = <lfs_konv>-kpein.
                      lwa_condition-cond_d_unt  = <lfs_konv>-kmein.
                      APPEND lwa_condition TO fp_li_condition.
                      CLEAR: lwa_condition.
                    ENDIF. " IF sy-subrc = 0
                  ENDLOOP. " LOOP AT li_konv ASSIGNING <lfs_konv> WHERE knumv = <lfs_vbrkp>-knumv

                ENDIF. " IF sy-subrc = 0
                CLEAR:lwa_billingdatain-parallel_qty.
              ENDLOOP. " LOOP AT fp_li_billingdatain INTO lwa_billingdatain
            ENDIF. " IF li_kschl IS NOT INITIAL
          ELSE. " ELSE -> IF sy-subrc = 0
* Set error and do not create ZHU billing document
            fp_price_error = abap_true.
          ENDIF. " IF sy-subrc = 0
        ELSE. " ELSE -> IF li_vbrkp[] IS NOT INITIAL
* Set error and do not create ZHU billing document
          fp_price_error = abap_true.
        ENDIF. " IF li_vbrkp[] IS NOT INITIAL
      ELSE. " ELSE -> IF sy-subrc = 0
* If no record found for "ZDF8 issue error
        fp_price_error = abap_true.
      ENDIF. " IF sy-subrc = 0
    ELSE. " ELSE -> IF sy-subrc = 0
* If no record found in VBFA , we raise an error message for "ZDF8 issue error
      fp_price_error = abap_true.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF fp_hu_det[] IS NOT INITIAL

ENDFORM. " F_FILL_COND_STRUCTURE
