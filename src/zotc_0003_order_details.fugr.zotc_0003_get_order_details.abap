FUNCTION zotc_0003_get_order_details.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_SALES_ORDER) TYPE  VBELN OPTIONAL
*"     VALUE(IM_PO_NO) TYPE  BSTKD OPTIONAL
*"  EXPORTING
*"     VALUE(EX_HEADER_DATA) TYPE  ZOTC_ORDER_HEADER
*"     VALUE(ET_ITEM_DATA) TYPE  ZOTC_ORDER_ITEM_T
*"     VALUE(ET_ITEM_DETAILS) TYPE  ZOTC_ORDER_ITEM_DETAILS_T
*"     VALUE(EX_ORDERS_LIST) TYPE  ZOTC_ORDER_LIST_T
*"----------------------------------------------------------------------

***********************************************************************
*Program    : ZOTC_0003_GET_ORDER_DETAILS                             *
*Title      : Get Order Details                                       *
*Developer  : ABdus Salam SK                                          *
*Object type: Funtion Module                                          *
*SAP Release: SAP ECC 8.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_MDD_0003                                           *
*---------------------------------------------------------------------*
*Description: Get Order related data foe SAP CSR overview screen      *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*======================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ============================*
*10-Sept-2019   ASK         E2DK927306    Initial Developmentr
*10-Oct-2019    ASK         E2DK927696    Tracking no. Issue
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* 27-FEB-2020 U106341                HANAtization Changes              *
*----------------------------------------------------------------------*
  TYPES :
    BEGIN OF ty_vpobjkey,
      vpobjkey TYPE vpobjkey,
    END OF ty_vpobjkey,

    BEGIN OF ty_status,
      vbeln TYPE vbeln,
      posnr TYPE posnr,
    END OF ty_status,

    BEGIN OF ty_ewm_track,
      vbeln   TYPE vbeln_vl,
      huidart TYPE /spe/de_huidart,
      huident TYPE /spe/de_ident,
    END OF   ty_ewm_track.


  DATA :
    lv_vbeln        TYPE vbeln,
    lv_netval       TYPE netwr,    " For INC0525504
    lv_logsys       TYPE logsys,
    lv_inco1        TYPE inco1,
    lv_zterm        TYPE dzterm,
    lv_stsma        TYPE jsto-stsma,
    lv_po_no        TYPE bstkd_m,
    lx_ewm_track    TYPE ty_ewm_track,
    li_vpobjkey     TYPE STANDARD TABLE OF ty_vpobjkey,
    lwa_vpobjkey    TYPE ty_vpobjkey,
    lwa_item        TYPE zotc_order_item,
    lwa_item_det    TYPE zotc_order_item_details,
    li_status       TYPE STANDARD TABLE OF ty_status,
    li_ewm_route    TYPE zotc_route_data_t,
    lwa_ewm_route   TYPE zotc_route_data,
    lwa_status      TYPE ty_status,
    li_lines        TYPE STANDARD TABLE OF tline,
    lref_utility    TYPE REF TO /bofu/cl_fdt_util, " BRFplus Utilities
    lref_admin_data TYPE REF TO if_fdt_admin_data, " FDT: Administrative Data
    lref_function   TYPE REF TO if_fdt_function,   " FDT: Function
    lref_context    TYPE REF TO if_fdt_context,    " FDT: Context
    lref_result     TYPE REF TO if_fdt_result,     " FDT: Result
    lref_fdt        TYPE REF TO cx_fdt,            " FDT: Abstract Exception Class   ##NEEDED
    lv_query_in     TYPE        string,
    lv_query_out    TYPE        if_fdt_types=>id.

  FIELD-SYMBOLS:
    <lfs_lines>      TYPE tline,
    <lfs_order_list> TYPE zotc_order_list.

  CONSTANTS:
    lc_separator TYPE xfeld     VALUE   '.'              , " Checkbox
    lc_name_appl TYPE string    VALUE   'ZOTC_MDD_0003_ORDER_DETAILS',
    lc_name_func TYPE string    VALUE   'ZOTC_F_CARRIER_URL'.

  IF  im_po_no IS NOT INITIAL.
* First Select Sales order no from the PO no
    TRANSLATE im_po_no TO UPPER CASE.
    REPLACE '*' WITH '%' INTO im_po_no.

    SELECT vbeln,
           bstkd
           FROM vbkd
           INTO TABLE @DATA(li_order)
           WHERE bstkd_m LIKE @im_po_no
             AND posnr = '000000'.

    IF sy-subrc = 0.
      SORT li_order BY vbeln.
      SELECT  vkorg
              audat
              auart
              vbeln
              kunnr
              ernam
        FROM vbak
        INTO TABLE ex_orders_list
        FOR ALL ENTRIES IN li_order
        WHERE vbeln = li_order-vbeln.

* Select Ship To Party.
      SELECT vbeln,
             kunnr
             FROM vbpa
             INTO TABLE @DATA(li_shipto)
             FOR ALL ENTRIES IN @li_order
             WHERE vbeln = @li_order-vbeln
               AND posnr = '000000'
               AND parvw = 'WE'.
      IF sy-subrc = 0.
        SORT li_shipto BY vbeln.

        LOOP AT ex_orders_list ASSIGNING <lfs_order_list>.
          READ TABLE li_order ASSIGNING FIELD-SYMBOL(<lfs_order>)
                               WITH KEY vbeln = <lfs_order_list>-vbeln
                               BINARY SEARCH.
          IF sy-subrc = 0.
            <lfs_order_list>-bstkd = <lfs_order>-bstkd.
          ENDIF.

          READ TABLE li_shipto ASSIGNING FIELD-SYMBOL(<lfs_shipto>)
                               WITH KEY vbeln = <lfs_order_list>-vbeln
                               BINARY SEARCH.
          IF sy-subrc = 0.
            <lfs_order_list>-kunwe = <lfs_shipto>-kunnr.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
    EXIT.
  ELSEIF im_sales_order IS NOT INITIAL.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = im_sales_order
      IMPORTING
        output = lv_vbeln.


    SELECT SINGLE bstkd_m
                  inco1
                  zterm
           FROM vbkd
      INTO (lv_po_no,lv_inco1,lv_zterm)
         WHERE vbeln =  lv_vbeln
           AND posnr = '000000'.
  ENDIF.

* Select Header data
  IF lv_vbeln IS NOT INITIAL.
    SELECT SINGLE
            vbeln,
            auart,
            erdat,
            ernam,
            kunnr,
            vsbed,
            netwr,
            waerk,
            bstdk,
            audat,
            augru,
            lifsk,
            faksk,
            objnr
        FROM vbak
        INTO @DATA(lx_vbak)
        WHERE vbeln = @lv_vbeln.
    IF sy-subrc NE 0.
      RETURN.
    ELSE.
* Get Biling block text.
      SELECT SINGLE
             vtext
         FROM tvfst
         INTO ex_header_data-bill_blk
         WHERE faksp = lx_vbak-faksk
           AND spras = sy-langu.

* Get Delivery block text.
      SELECT SINGLE
             vtext
         FROM tvlst
         INTO ex_header_data-deliv_blk
         WHERE lifsp = lx_vbak-lifsk
           AND spras = sy-langu.
    ENDIF.

* Select Item data

    SELECT  vbeln,
            posnr,
            matnr,
            arktx,
            pstyv,
            uepos,
            kwmeng,
            zmeng,
            charg,
            netwr,
            waerk,
            route,
            werks,
            faksp,
            abgru,
            kbmeng,
            kzwi1,
            kzwi2
        FROM vbap
        INTO TABLE @DATA(li_vbap)
        WHERE vbeln = @lv_vbeln.
    IF sy-subrc = 0.
* BOC  For INC0525504
* Select Rejection text
      SELECT   abgru,
               bezei
             FROM tvagt
         INTO TABLE @DATA(li_tvagt)
         FOR ALL ENTRIES IN @li_vbap
         WHERE abgru = @li_vbap-abgru
           AND spras = @sy-langu.
      IF sy-subrc = 0.
        SORT li_tvagt BY abgru.
      ENDIF.
* EOC  For INC0525504
* Get Biling block text.
      SELECT faksp,
         vtext
         FROM tvfst
         INTO TABLE @DATA(li_tvfst)
         FOR ALL ENTRIES IN @li_vbap
         WHERE faksp = @li_vbap-faksp
           AND spras = @sy-langu.
      IF sy-subrc = 0.
        SORT li_tvfst BY faksp.
      ENDIF.
* Get Schedule line data
      SELECT posnr,
             edatu,
             lifsp
        FROM vbep
        INTO TABLE @DATA(li_vbep)
        WHERE vbeln = @lv_vbeln
          AND etenr = '0001'
*&-- Begin of change for HANAtization on OTC_MDD_0003 by U106341 on 27-FEB-2020 in E1SK901678
          ORDER BY posnr.
*&-- End of change for HANAtization on OTC_MDD_0003 by U106341 on 27-FEB-2020 in E1SK901678

* Get Delivery block text.
      IF sy-subrc = 0.
        SELECT lifsp,
               vtext
               FROM tvlst
               INTO TABLE @DATA(li_tvlst)
               FOR ALL ENTRIES IN @li_vbep
               WHERE lifsp = @li_vbep-lifsp
                 AND spras = @sy-langu.
        IF sy-subrc = 0.
          SORT li_tvlst BY lifsp.
        ENDIF.
      ENDIF.

* Get Material type

      SELECT matnr,
             mtart
        FROM mara
        INTO TABLE @DATA(li_mara)
        FOR ALL ENTRIES IN @li_vbap
        WHERE matnr = @li_vbap-matnr.
      IF sy-subrc = 0.
        SORT li_mara BY matnr.
      ENDIF.

* Get Delivery data
      SELECT vbeln,
             posnr,
             charg,
             lfimg,
             vgbel,
             vgpos
        FROM lips
        INTO TABLE @DATA(li_lips)
        WHERE vgbel = @lv_vbeln.

      IF sy-subrc = 0.
        SORT li_lips BY vgbel vgpos.
        LOOP AT li_vbap ASSIGNING FIELD-SYMBOL(<lfs_vbap1>).
          lwa_status-vbeln = lv_vbeln.
          lwa_status-posnr = <lfs_vbap1>-posnr.
          APPEND lwa_status TO li_status.
          CLEAR lwa_status.
        ENDLOOP.

        LOOP AT li_lips ASSIGNING FIELD-SYMBOL(<lfs_lips1>).
          lwa_status-vbeln = <lfs_lips1>-vbeln.
          lwa_status-posnr = <lfs_lips1>-posnr.
          APPEND lwa_status TO li_status.
          CLEAR lwa_status.
        ENDLOOP.
* Select Status
        SELECT vbeln,
               posnr,
               wbsta,
               gbsta,
               lfsta,
               pdsta,
               fksta,
               fksaa
               FROM vbup
               INTO TABLE @DATA(li_vbup)
               FOR ALL ENTRIES IN @li_status
               WHERE vbeln = @li_status-vbeln
                 AND posnr = @li_status-posnr.

        IF sy-subrc = 0.
          SORT li_vbup BY vbeln posnr.
        ENDIF.
      ENDIF.

* Get Delivery Header data
      IF li_lips[] IS NOT INITIAL.
        SELECT vbeln,
               route,
               wadat_ist,
               podat
               FROM likp
               INTO TABLE @DATA(li_likp)
               FOR ALL ENTRIES IN @li_lips
               WHERE vbeln = @li_lips-vbeln.

        IF sy-subrc = 0.
          SORT li_likp BY vbeln.
* Get Carrier data
          SELECT route_code,
                 flagship_carrier
            FROM zlex_routemap
            INTO TABLE @DATA(li_route)
            FOR ALL ENTRIES IN @li_likp
                 WHERE route_code = @li_likp-route.
          IF sy-subrc = 0.
            SORT li_route BY route_code.
          ENDIF.
        ENDIF.
      ENDIF.
* Get Invoice data
      SELECT vbeln,
             posnr,
             vgbel,
             vgpos,
             aupos
        FROM vbrp
        INTO TABLE @DATA(li_vbrp)
        WHERE aubel = @lv_vbeln.
      IF sy-subrc = 0.
        SORT li_vbrp BY vgbel vgpos.
      ENDIF.

      DATA : lwa_likp LIKE LINE OF li_likp.

* Select Tracking data.
      LOOP AT li_likp INTO lwa_likp.

        lwa_vpobjkey-vpobjkey = lwa_likp-vbeln.
        APPEND lwa_vpobjkey TO li_vpobjkey.
* Populate Route Data
        lwa_ewm_route =  lwa_likp-route.
        APPEND lwa_ewm_route TO li_ewm_route.
        CLEAR lwa_ewm_route.
      ENDLOOP.

      IF li_vpobjkey[] IS NOT INITIAL.
*   Get the details of HU & Freight
        SELECT venum,        " Internal Handling Unit Number
               exidv,        " External Handling Unit Identification
               vpobj,        " Packing Object
               vpobjkey,     " Key for Object to Which the Handling Unit is Assigned
               spe_idart_01, " Handling Unit Identification Type
               spe_ident_01, " Alternative HU Identification
               spe_idart_02, " Handling Unit Identification Type
               spe_ident_02, " Alternative HU Identification
               spe_idart_03, " Handling Unit Identification Type
               spe_ident_03 " Alternative HU Identification
          INTO TABLE @DATA(li_vekp)
          FROM vekp         " Handling Unit - Header Table
          FOR ALL ENTRIES IN @li_vpobjkey
          WHERE  vpobj = '01'
          AND    vpobjkey = @li_vpobjkey-vpobjkey.

        IF sy-subrc = 0.
          SORT li_vekp BY venum.

* Select Item data of HU
          SELECT venum,
                 vepos,
                 vbeln,
                 posnr,
                 vemng
            INTO TABLE @DATA(li_vepo)
          FROM vepo        " Handling Unit - Header Table
          FOR ALL ENTRIES IN @li_vekp
          WHERE  venum = @li_vekp-venum.
          IF sy-subrc = 0.
            SORT li_vepo BY vbeln posnr.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
* Select Partner Data
    SELECT parvw,
           kunnr,
           adrnr
           FROM vbpa
           INTO TABLE @DATA(li_vbpa)
           WHERE vbeln = @lv_vbeln
             AND posnr = '000000'
             AND parvw IN ( 'AG','WE', 'AP', 'RE', 'RG' ).


* Get Contact Person Name.

    READ TABLE li_vbpa INTO DATA(lwa_vbpa)
                       WITH KEY  parvw = 'AP'.
    IF sy-subrc = 0.

      SELECT name1
             UP TO 1 ROWS
             FROM adrc
             INTO ex_header_data-contact_name
             WHERE addrnumber = lwa_vbpa-adrnr.
      ENDSELECT.
    ENDIF.
***********************************************************************
* Get BRF+ Data for Carrier

*-- Create an instance of BRFPlus Utility class
    lref_utility ?= /bofu/cl_fdt_util=>get_instance( ).

*-- Make BRF query by concatenation of BRF application name and BRF Function name
    CONCATENATE lc_name_appl lc_name_func
           INTO lv_query_in
           SEPARATED BY lc_separator.
*-- To get GUID of query string
    IF lref_utility IS BOUND.
      CALL METHOD lref_utility->convert_function_input
        EXPORTING
          iv_input  = lv_query_in
        IMPORTING
          ev_output = lv_query_out
        EXCEPTIONS
          failed    = 1
          OTHERS    = 2.
      IF sy-subrc IS INITIAL.
*-- Set the variable value(s)
        cl_fdt_factory=>get_instance_generic( EXPORTING iv_id = lv_query_out
                                              IMPORTING eo_instance = lref_admin_data ).
        lref_function ?= lref_admin_data.
        lref_context  ?= lref_function->get_process_context( ).
      ENDIF.
    ENDIF.
***********************************************************************

*---------------- Now Populate the Header  Data -------------------------
    ex_header_data-vbeln    = lx_vbak-vbeln.
    ex_header_data-auart    = lx_vbak-auart.
    ex_header_data-ernam    = lx_vbak-ernam.
    ex_header_data-erdat    = lx_vbak-erdat.
    ex_header_data-sold_to  = lx_vbak-kunnr.
    ex_header_data-vsbed    = lx_vbak-vsbed.
*    ex_header_data-netwr    = lx_vbak-netwr.  " For INC0525504
    ex_header_data-waerk    = lx_vbak-waerk.
    ex_header_data-bstkd    = lv_po_no.
    ex_header_data-inco1    = lv_inco1.
    ex_header_data-zterm    = lv_zterm.
    ex_header_data-bstdk    = lx_vbak-bstdk.
    ex_header_data-audat    = lx_vbak-audat.
    ex_header_data-augru    = lx_vbak-augru.
    ex_header_data-lifsk    = lx_vbak-lifsk.
    ex_header_data-faksk    = lx_vbak-faksk.

    IF ex_header_data-auart EQ 'ZCMR' OR ex_header_data-auart EQ 'ZDMR'.
* Get Status text
      CALL FUNCTION 'STATUS_TEXT_EDIT'
        EXPORTING
          objnr            = lx_vbak-objnr
          flg_user_stat    = 'X'
          only_active      = 'X'
          spras            = sy-langu
        IMPORTING
          e_stsma          = lv_stsma
          user_line        = ex_header_data-wf_status
        EXCEPTIONS
          object_not_found = 1
          OTHERS           = 2.

      SELECT  txt30
                    FROM tj30t
                    UP TO 1 ROWS
                    INTO ex_header_data-wf_status
                    WHERE stsma = lv_stsma AND
                          txt04 = ex_header_data-wf_status.
      ENDSELECT.
    ENDIF.
* Populate Sold to Party address
    READ TABLE li_vbpa INTO lwa_vbpa
                     WITH KEY  parvw = 'AG'.
    IF sy-subrc = 0.
* Get Ship to Party Address data
      PERFORM f_get_address  USING    lwa_vbpa-adrnr
                             CHANGING ex_header_data-sold_to_addr.
    ENDIF.

* Populate Ship to Party and address
    READ TABLE li_vbpa INTO lwa_vbpa
                     WITH KEY  parvw = 'WE'.
    IF sy-subrc = 0.
      ex_header_data-ship_to = lwa_vbpa-kunnr.

* Get Ship to Party Address data
      PERFORM f_get_address  USING    lwa_vbpa-adrnr
                             CHANGING ex_header_data-ship_to_addr.
    ENDIF.

* Populate Bill to Party
    READ TABLE li_vbpa INTO lwa_vbpa
                     WITH KEY  parvw = 'RE'.
    IF sy-subrc = 0.
      ex_header_data-bill_to = lwa_vbpa-kunnr.
    ENDIF.

* Populate Payer
    READ TABLE li_vbpa INTO lwa_vbpa
                     WITH KEY  parvw = 'RG'.
    IF sy-subrc = 0.
      ex_header_data-payer = lwa_vbpa-kunnr.
    ENDIF.

* Get all kind of texts.
* First get collector Acc#
    PERFORM f_read_text USING    '0003'
                                 lv_vbeln
                        CHANGING li_lines.
* Populate in Header output
    READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 1.
    IF sy-subrc = 0.
      ex_header_data-col_acct = <lfs_lines>-tdline.
    ENDIF.


* Second get Attn to#
    PERFORM f_read_text USING    '0002'
                                 lv_vbeln
                        CHANGING li_lines.
* Populate in Header output
    READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 1.
    IF sy-subrc = 0.
      ex_header_data-attn_to = <lfs_lines>-tdline.
    ENDIF.

* Finally get Internal Notes.
    PERFORM f_read_text USING    'Z001'
                               lv_vbeln
                      CHANGING li_lines.
* Populate in Header output
    ex_header_data-internal_notes = li_lines[].


  ENDIF.
*---------------- Now Populate the Item  Data -------------------------


* Get EWm Route Data.
* Get OWN logical system
  CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
    IMPORTING
      own_logical_system             = lv_logsys
    EXCEPTIONS
      own_logical_system_not_defined = 1
      OTHERS                         = 2.
  IF lv_logsys IS NOT INITIAL.
* Get EWM logical system
    lv_logsys+0(1) = 'W'.
    SORT li_ewm_route BY route_code.
    DELETE ADJACENT DUPLICATES FROM li_ewm_route COMPARING route_code.

* Go to EWM to fetch tracking no.
    CALL FUNCTION 'ZRFC_GET_DELIV_DET'
      DESTINATION lv_logsys
      CHANGING
        ct_route = li_ewm_route.

    SORT li_ewm_route BY route_code.
  ENDIF.

  LOOP AT li_vbap ASSIGNING FIELD-SYMBOL(<lfs_vbap>).
    lwa_item-posnr = <lfs_vbap>-posnr.
    lwa_item-matnr = <lfs_vbap>-matnr.
    lwa_item-arktx = <lfs_vbap>-arktx.
    IF ex_header_data-auart EQ 'ZCMR' OR ex_header_data-auart EQ 'ZDMR'.
      lwa_item-zmeng = <lfs_vbap>-zmeng.
    ELSE.
      lwa_item-zmeng = <lfs_vbap>-kwmeng.
    ENDIF.
    IF lwa_item-zmeng IS NOT INITIAL.                       " For INC0525504
      lwa_item-netwr = <lfs_vbap>-kzwi1 / lwa_item-zmeng.   " For INC0525504
    ENDIF.                                                  " For INC0525504

    " Begin of changes For INC0525504
* Populate Rejection text.
    READ TABLE li_tvagt ASSIGNING FIELD-SYMBOL(<lfs_tvagt>)
                                  WITH KEY abgru = <lfs_vbap>-abgru
                                  BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_item-reject_text = <lfs_tvagt>-bezei.
    ENDIF.
* Get header level netvalue
    IF <lfs_vbap>-abgru IS INITIAL AND
       <lfs_vbap>-uepos IS INITIAL.
      lv_netval = lv_netval + <lfs_vbap>-kzwi1.
    ENDIF.
    " End  of changes For INC0525504

    lwa_item-charg = <lfs_vbap>-charg.
    lwa_item-werks = <lfs_vbap>-werks.
    lwa_item-faksp = <lfs_vbap>-faksp.
    lwa_item-pstyv = <lfs_vbap>-pstyv.
    lwa_item-waerk = <lfs_vbap>-waerk.
    lwa_item-abgru = <lfs_vbap>-abgru.
    IF <lfs_vbap>-kbmeng IS ASSIGNED.
      lwa_item-confirmqty = <lfs_vbap>-kbmeng.
    ENDIF.
    IF <lfs_vbap>-kbmeng IS INITIAL.
      lwa_item-confirmed = 'No'.
    ELSEIF <lfs_vbap>-kbmeng = <lfs_vbap>-kwmeng .
      lwa_item-confirmed = 'Fully Confirmed'.
    ELSEIF  <lfs_vbap>-kbmeng < <lfs_vbap>-kwmeng.
      lwa_item-confirmed = 'Partially Confirmed'.
    ENDIF.


* Get Billing block text
    READ TABLE li_tvfst ASSIGNING FIELD-SYMBOL(<lfs_tvfst>)
                   WITH KEY faksp = <lfs_vbap>-faksp
                   BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_item-faksp_text = <lfs_tvfst>-vtext.
    ENDIF.

* Get Material Type

    READ TABLE li_mara ASSIGNING FIELD-SYMBOL(<lfs_mara>)
                       WITH KEY matnr = <lfs_vbap>-matnr
                       BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_item-mtart = <lfs_mara>-mtart.
    ENDIF.

* Get status.
    READ  TABLE li_vbup ASSIGNING FIELD-SYMBOL(<lfs_vbup>)
                             WITH KEY vbeln = lv_vbeln
                                      posnr = <lfs_vbap>-posnr
                             BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_item-item_status = <lfs_vbup>-gbsta.
      lwa_item-lfsta = <lfs_vbup>-lfsta.
      lwa_item-wbsta = <lfs_vbup>-wbsta.
      lwa_item-pdsta = <lfs_vbup>-pdsta.
      lwa_item-fksta = <lfs_vbup>-fksta.
      lwa_item-fksaa = <lfs_vbup>-fksaa.
    ENDIF.

* Get Requested Delivery date

    READ  TABLE li_vbep ASSIGNING FIELD-SYMBOL(<lfs_vbep>)
                     WITH KEY posnr = <lfs_vbap>-posnr
                     BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_item-edatu = <lfs_vbep>-edatu.
      lwa_item-lifsp = <lfs_vbep>-lifsp.
* Get Delivery block text
      READ TABLE li_tvlst ASSIGNING FIELD-SYMBOL(<lfs_tvlst>)
                     WITH KEY lifsp = <lfs_vbep>-lifsp
                     BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_item-lifsp_text = <lfs_tvlst>-vtext.
      ENDIF.
    ENDIF.

    APPEND lwa_item TO et_item_data.
    CLEAR lwa_item.

* Now populate Item details
    LOOP AT li_lips ASSIGNING FIELD-SYMBOL(<lfs_lips>)
                    WHERE vgpos = <lfs_vbap>-posnr.
      lwa_item_det-posnr = <lfs_vbap>-posnr.
      lwa_item_det-lfimg = <lfs_lips>-lfimg.
      lwa_item_det-delivery_no = <lfs_lips>-vbeln.
      lwa_item_det-delv_item = <lfs_lips>-posnr.
      lwa_item_det-charg     = <lfs_lips>-charg.
* Get Delivery Header data
      READ  TABLE li_likp ASSIGNING FIELD-SYMBOL(<lfs_likp>)
                          WITH KEY vbeln = <lfs_lips>-vbeln
                          BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_item_det-pgi_date = <lfs_likp>-wadat_ist.
        lwa_item_det-pod_date = <lfs_likp>-podat.
* Get Carrier
        READ TABLE li_route ASSIGNING FIELD-SYMBOL(<lfs_route>)
                                WITH KEY route_code = <lfs_likp>-route
                                BINARY SEARCH.
        IF sy-subrc = 0.
          lwa_item_det-carrier = <lfs_route>-flagship_carrier.
        ELSE.
          READ TABLE li_ewm_route ASSIGNING FIELD-SYMBOL(<lfs_ewm_route>)
                              WITH KEY route_code = <lfs_likp>-route
                              BINARY SEARCH.
          IF sy-subrc = 0.
            lwa_item_det-carrier = <lfs_ewm_route>-flagship_carrier.
          ENDIF.
        ENDIF.

* Get Carrier URL
        IF lwa_item_det-carrier IS NOT INITIAL.
          lref_context->set_value( iv_name = 'CARRIER'  ia_value = lwa_item_det-carrier ).
          TRY.
              lref_function->process( EXPORTING io_context = lref_context
                                      IMPORTING eo_result = lref_result ).
              lref_result->get_value( IMPORTING ea_value = lwa_item_det-carrier_url ).

            CATCH cx_fdt INTO lref_fdt.                      ##no_handler
              CLEAR lwa_item_det-carrier_url.
          ENDTRY.
        ENDIF.

      ENDIF.

* Get status.
      READ  TABLE li_vbup ASSIGNING <lfs_vbup>
                               WITH KEY vbeln = <lfs_lips>-vbeln
                                        posnr = <lfs_lips>-posnr
                               BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_item_det-status = <lfs_vbup>-wbsta.
      ENDIF.
* Get Invoice data.
      READ TABLE li_vbrp ASSIGNING FIELD-SYMBOL(<lfs_vbrp>)
                         WITH KEY vgbel = <lfs_lips>-vbeln
                                  vgpos = <lfs_lips>-posnr
                         BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_item_det-invoice_no = <lfs_vbrp>-vbeln.
        lwa_item_det-inv_item = <lfs_vbrp>-posnr.
      ELSE.
* If its order related Invoice  then get it using Sales order
        READ TABLE li_vbrp ASSIGNING <lfs_vbrp>
                      WITH KEY aupos =  <lfs_vbap>-posnr.
        IF sy-subrc = 0.
          lwa_item_det-invoice_no = <lfs_vbrp>-vbeln.
          lwa_item_det-inv_item = <lfs_vbrp>-posnr.
        ENDIF.

      ENDIF.

* Now get the tracking no.

* First check from ECC then go to EWM.


* First check the Item Level HU.

* Begin of Change for INC0525504
* There can be multiple HU for  asingle Delivery Item
*      READ TABLE li_vepo ASSIGNING FIELD-SYMBOL(<lfs_vepo>)
*                      WITH KEY vbeln = <lfs_lips>-vbeln
*                               posnr = <lfs_lips>-posnr
*                      BINARY SEARCH.
*      IF sy-subrc = 0.
      LOOP AT li_vepo ASSIGNING FIELD-SYMBOL(<lfs_vepo>)
                       WHERE    vbeln = <lfs_lips>-vbeln
                         AND    posnr = <lfs_lips>-posnr.
*

        lwa_item_det-lfimg = <lfs_vepo>-vemng.
* End of Change for INC0525504

        READ TABLE li_vekp ASSIGNING FIELD-SYMBOL(<lfs_vekp>)
                  WITH KEY venum = <lfs_vepo>-venum
                  BINARY SEARCH.
        IF sy-subrc = 0.
          IF <lfs_vekp>-spe_idart_01 = 'T'.
            lwa_item_det-tracking_no = <lfs_vekp>-spe_ident_01.
          ELSEIF <lfs_vekp>-spe_idart_02 = 'T'.
            lwa_item_det-tracking_no = <lfs_vekp>-spe_ident_02.
          ELSEIF <lfs_vekp>-spe_idart_03 = 'T'.
            lwa_item_det-tracking_no = <lfs_vekp>-spe_ident_03.
          ENDIF.
        ENDIF. " IF sy-subrc = 0

        IF lwa_item_det-tracking_no IS INITIAL.
* End of Change for INC0525504
          IF lv_logsys IS NOT INITIAL.
* Go to EWM to fetch tracking no.
            CALL FUNCTION 'ZRFC_GET_DELIV_DET'
              DESTINATION lv_logsys
              EXPORTING
                iv_refdocno  = <lfs_lips>-vbeln
                iv_doccat    = 'ERP'
              IMPORTING
                es_ewm_track = lx_ewm_track.


            lwa_item_det-tracking_no =  lx_ewm_track-huident.

          ENDIF.
        ENDIF.

        APPEND lwa_item_det TO et_item_details. " for INC0525504
      ENDLOOP.   " for INC0525504
      IF sy-subrc NE 0. " for INC0525504
        APPEND lwa_item_det TO et_item_details. " for INC0525504
      ENDIF. " for INC0525504
      CLEAR lwa_item_det.
    ENDLOOP.
  ENDLOOP.

  ex_header_data-netwr    = lv_netval.  " For INC0525504
* Delete 0 delivery  Qunatitities
  DELETE et_item_details WHERE lfimg IS INITIAL.

* Get Invoice data.
* If its order related Invoice  then get it using Sales order
* Now populate Item details
  LOOP AT li_vbrp ASSIGNING <lfs_vbrp>.
    READ TABLE et_item_details WITH KEY posnr = <lfs_vbrp>-posnr TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
      lwa_item_det-posnr      = <lfs_vbrp>-posnr.
      lwa_item_det-invoice_no = <lfs_vbrp>-vbeln.
      lwa_item_det-inv_item   = <lfs_vbrp>-posnr.
      APPEND lwa_item_det TO et_item_details.
      CLEAR lwa_item_det.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
