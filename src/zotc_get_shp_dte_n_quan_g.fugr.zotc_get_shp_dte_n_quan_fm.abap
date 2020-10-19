************************************************************************
* PROGRAM    :  ZOTC_GET_SHP_DTE_N_QUAN_FM (Function Module)           *
* TITLE      :  Get Order Status                                       *
* DEVELOPER  :  Abhishek Gupta3                                        *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D2_OTC_IDD_0092_SAP                                      *
*----------------------------------------------------------------------*
* DESCRIPTION: Population of shipped date and shipped quantity         *
*              also planned date and confirmed quantity along with     *
*              tracking number and Invoices.                           *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT  DESCRIPTION                        *
* ===========  ========  ========== ===================================*
* 02-June-2014  AGUPTA3  E2DK900484 Initial Development                *
* 24-Sep-2014   AGUPTA3  E2DK900484 CR_167 (Tracking number will be    *
*                                    populated from VEKP-SPE_IDENT_01  *
*                                    instead of VEKP-EXIDV. )          *
*&---------------------------------------------------------------------*
* 13-Jan-2014  DMOIRAN  E2DK900484  Defect 2500. For Sample order ZITEM*
* tag is not coming. Include doc category 'I' (Order w/o charge) also  *
* while selecting delivery from VBFA.                                  *
* 22-Jan-2015   NBAIS    E2DK900484 Defect 3084/3086 – CR 447 (As per  *
*                                    defect 3084: For Tracking no      *
*                                    instead of SPE IDENT 01           *
*                                    now we will check SPE IDENT 01,   *
*                                    SPE IDENT 02,SPE IDENT 03,        *
*                                    SPE IDENT 04.                     *
*                                    defect:3086:For 3rd Party delivery*
*                                    "Tracking number" will be populate*
*                                    by LIKP-LIFEX instead of BOLNR.   *
* 15-Apr-2015  DMOIRAN  E2DK900484  Defect-5842 For sample order (ZSAM)
*                                   order type is I.
* 28-Apr-2015   MBAGDA  E2DK900484  Defect 6248                        *
*                                   Change field LIKP-WADAT to field   *
*                                   LIKP-LFDAT for Delivery Cases      *
*&---------------------------------------------------------------------*


FUNCTION zotc_get_shp_dte_n_quan_fm.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_SALS_ORDER) TYPE  VBELN
*"  EXPORTING
*"     VALUE(EX_DELV_DATA) TYPE  ZOTC_DELV_DATA
*"     REFERENCE(EX_FLAG) TYPE  CHAR1
*"----------------------------------------------------------------------

*  include LZOTC_GET_SHP_DTE_N_QUAN_GTOP.
**Local data declaration
  DATA: li_docflow_tmp1 TYPE STANDARD TABLE OF vbfa,  " Sales Document Flow
        li_ib_delv_tmp  TYPE STANDARD TABLE OF ty_ekes,
        li_text         TYPE STANDARD TABLE OF tline, " SAPscript: Text Lines
        li_sdlitm_tmp   TYPE STANDARD TABLE OF ty_lips,
        li_huitem_tmp   TYPE STANDARD TABLE OF ty_vepo,
        li_track_num TYPE zotc_track_num,             " External Handling Unit Identification
        lv_count     TYPE i,                          " Count of type Integers
        lv_date_sch  TYPE bbein,                      " Delivery Date of Vendor Confirmation
        lv_delv_quan TYPE lfimg,                      " Actual quantity delivered (in sales units)
        lv_quan_tmp  TYPE lfimg,                      " Actual quantity delivered (in sales units)
        lv_quan_1    TYPE lfimg,                      " Actual quantity delivered (in sales units)
        lv_text_name TYPE tdobname,                   " Name
        lv_track_num TYPE exidv,                      " External Handling Unit Identification
        lv_quan_2    TYPE lfimg.                      " Actual quantity delivered (in sales units)

  CONSTANTS: lc_vbtyp_n_j TYPE vbtyp_n VALUE 'J', " Document category of subsequent document
             lc_vbtyp_n_v TYPE vbtyp_n VALUE 'V', " Document category of subsequent document
             lc_vbtyp_v_c TYPE vbtyp_v VALUE 'C', " Document category of preceding SD document
* ---> Begin of Insert for D2_OTC_IDD_0092 Defect 2500 by DMOIRAN
             lc_vbtyp_v_i TYPE vbtyp_v VALUE 'I', " Document category of preceding SD document
* <--- End    of Insert for D2_OTC_IDD_0092 Defect 2500 by DMOIRAN

             lc_gbsta_a TYPE gbsta VALUE 'A',      " Overall processing status of the SD document item
             lc_gbsta_b TYPE gbsta VALUE 'B',      " Overall processing status of the SD document item
             lc_gbsta_c TYPE gbsta VALUE 'C',      " Overall processing status of the SD document item
             lc_wbstk_c TYPE wbstk VALUE 'C',      " Total goods movement status
             lc_wbstk_a TYPE wbstk VALUE 'A',      " Total goods movement status
             lc_wbstk_b TYPE wbstk VALUE 'B',      " Total goods movement status
             lc_id      TYPE tdid  VALUE '0102',   " Text ID
             lc_object TYPE tdobject VALUE 'VBBK'. " Texts: Application Object

** Field Symbols
  FIELD-SYMBOLS: <lfs_itm_stat> TYPE ty_vbup,
                 <lfs_delv_doc> TYPE ty_vbep1,
                 <lfs_item>     TYPE ty_vbap,
                 <lfs_text>     TYPE tline, " SAPscript: Text Lines
                 <lfs_doc_flow> TYPE vbfa,  " Sales Document Flow
                 <lfs_bol>      TYPE ty_likp1,
                 <lfs_lips>     TYPE  ty_lips,
                 <lfs_ib_delv>  TYPE ty_ekes,
                 <lfs_sch_lin>  TYPE ty_vbep.

  PERFORM f_clear_data.

  PERFORM f_get_constants.
*** Get all item data
  SELECT vbeln " Sales Document
         posnr " Sales Document Item
         fkrel " Relevant for Billing
    FROM vbap  " Sales Document: Item Data
    INTO TABLE i_item
    WHERE vbeln = im_sals_order.

  IF sy-subrc = 0.
    SORT i_item BY posnr.

** Sy-subrc is checked so no need of Initial check
**Get all schedule line data
    SELECT  vbeln " Sales Document
            posnr " Sales Document Item
            etenr " Delivery Schedule Line Number
            edatu " Schedule line date
            wmeng " Order quantity in sales units
            bmeng " Confirmed Quantity
            vrkme " Sales unit
       FROM vbep  " Sales Document: Schedule Line Data
       INTO TABLE i_sch_line
       FOR ALL ENTRIES IN i_item
       WHERE vbeln = i_item-vbeln AND
             posnr = i_item-posnr.

    IF sy-subrc = 0.
      SORT i_sch_line BY posnr ASCENDING
                          etenr ASCENDING.

    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF sy-subrc = 0

** Get the document flow
  wa_salesorder-vbeln = im_sals_order.

  CALL FUNCTION 'RV_ORDER_FLOW_INFORMATION'
    EXPORTING
      comwa         = wa_salesorder
    TABLES
      vbfa_tab      = i_docflow
    EXCEPTIONS
      no_vbfa       = 1
      no_vbuk_found = 2
      OTHERS        = 3.
  IF sy-subrc = 0.
    SORT i_docflow BY vbelv ASCENDING
                      posnv ASCENDING.
  ENDIF. " IF sy-subrc = 0

******************************************************************
** Check whether delivery related or not
  i_item_tmp[] = i_item[].
  DELETE i_item_tmp[] WHERE NOT ( fkrel IN i_del_stat ).

** get item status
  IF i_item_tmp[] IS NOT INITIAL.
    SELECT vbeln " Sales and Distribution Document Number
          posnr  " Item number of the SD document
          gbsta  " Overall processing status of the SD document item
     FROM vbup   " Sales Document: Item Status
     INTO TABLE i_item_stat
     FOR ALL ENTRIES IN i_item_tmp
     WHERE vbeln = i_item_tmp-vbeln AND
           posnr = i_item_tmp-posnr.
    IF sy-subrc = 0.
      SORT i_item_stat BY posnr.
    ENDIF. " IF sy-subrc = 0

**get the delivery docs
    i_docflow_tmp[] = i_docflow[].
    DELETE i_docflow_tmp WHERE NOT ( ( vbelv EQ im_sals_order )
                     AND ( vbtyp_n EQ lc_vbtyp_n_j )
                     AND ( vbtyp_v EQ lc_vbtyp_v_c
* ---> Begin of Insert for D2_OTC_IDD_0092 Defect 2500 by DMOIRAN
* add order w/o charge category also
                           OR vbtyp_v EQ lc_vbtyp_v_i ) ).
* <--- End    of Insert for D2_OTC_IDD_0092 Defect 2500 by DMOIRAN

    DELETE i_docflow_tmp WHERE rfmng EQ 0.

    IF i_docflow_tmp[] IS NOT INITIAL.
      SELECT vbeln " Sales and Distribution Document Number
             wbstk " Total goods movement status
        FROM vbuk  " Sales Document: Header Status and Administrative Data
        INTO TABLE i_slsdoc_stat
        FOR ALL ENTRIES IN i_docflow_tmp
        WHERE vbeln = i_docflow_tmp-vbeln.

      IF sy-subrc = 0.
        SORT i_slsdoc_stat BY vbeln.
      ENDIF. " IF sy-subrc = 0

** get SD delivery header data.
      IF i_slsdoc_stat[] IS NOT INITIAL.
        SELECT vbeln     " Delivery
* ---> Begin of Change for D2_OTC_IDD_0092_Defect 6248 – by MBAGDA
*              wadat     " Planned goods movement date
               lfdat     " Delivery Date
* <--- End of Change for D2_OTC_IDD_0092_Defect 6248 by MBAGDA
               wadat_ist " Actual Goods Movement Date
          FROM likp      " SD Document: Delivery Header Data
          INTO TABLE i_sddelivhead_data
          FOR ALL ENTRIES IN i_slsdoc_stat
          WHERE vbeln = i_slsdoc_stat-vbeln.

        IF sy-subrc = 0.
          SORT i_sddelivhead_data BY vbeln ASCENDING.
        ENDIF. " IF sy-subrc = 0

** Get SD Delivery Item data
        SELECT vbeln " Delivery
               posnr " Delivery Item
               lfimg " Actual quantity delivered (in sales units)
               vrkme " Sales unit
          FROM lips  " SD document: Delivery: Item data
          INTO TABLE i_sddelivitm_data
         FOR ALL ENTRIES IN i_slsdoc_stat
         WHERE vbeln = i_slsdoc_stat-vbeln.

        IF sy-subrc = 0.
          SORT i_sddelivitm_data BY vbeln ASCENDING
                                    posnr ASCENDING.
**get Handling Unit number
          SELECT venum " Internal Handling Unit Number
                 vepos " Handling Unit Item
                 vbeln " Delivery
                 posnr " Delivery Item
            FROM vepo  " Packing: Handling Unit Item (Contents)
            INTO TABLE i_huitem
            FOR ALL ENTRIES IN i_sddelivitm_data
            WHERE vbeln = i_sddelivitm_data-vbeln
            AND   posnr = i_sddelivitm_data-posnr.

          IF sy-subrc = 0.
            SORT i_huitem BY vbeln ASCENDING
                             posnr ASCENDING.
            li_huitem_tmp[] = i_huitem[].
            SORT li_huitem_tmp BY venum ASCENDING.
            DELETE ADJACENT DUPLICATES FROM li_huitem_tmp COMPARING venum.

** Get Tracking Number
            IF li_huitem_tmp[] IS NOT INITIAL.
              SELECT venum " Internal Handling Unit Number
* ---> Begin of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS
                     spe_idart_01
* ---> Begin of Change for D2_OTC_IDD_0092_CR_167 by AGUPTA3
** Retrieve Tracking number from field SPE_IDENT_01 instead of EXIDV.
*                     EXIDV
                     spe_ident_01 " Alternative Handling Unit Identification
* <--- End of Change for D2_OTC_IDD_0092_CR_167 by AGUPTA3
                     spe_idart_02
                     spe_ident_02
                     spe_idart_03
                     spe_ident_03
                     spe_idart_04
                     spe_ident_04
* <--- End of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447 by NBAIS
                FROM vekp " Handling Unit - Header Table
                INTO TABLE i_track_num
                FOR ALL ENTRIES IN li_huitem_tmp
                WHERE venum = li_huitem_tmp-venum.
              IF sy-subrc = 0.
                SORT i_track_num BY venum.
              ENDIF. " IF sy-subrc = 0
            ENDIF. " IF li_huitem_tmp[] IS NOT INITIAL

          ENDIF. " IF sy-subrc = 0

        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF i_slsdoc_stat[] IS NOT INITIAL

    ENDIF. " IF i_docflow_tmp[] IS NOT INITIAL

  ENDIF. " IF i_item_tmp[] IS NOT INITIAL

****************************************************************************

  LOOP AT i_item_stat ASSIGNING <lfs_itm_stat>.
    CLEAR: gv_flag.

    wa_output-vbeln = <lfs_itm_stat>-vbeln.
    wa_output-posnr = <lfs_itm_stat>-posnr.

    REFRESH: i_sch_line_a[],
             i_sch_line_b[],
             i_delv_doc_b[],
             i_delv_doc_c[].

    CASE <lfs_itm_stat>-gbsta.

** for the item for which no quantity delivered
      WHEN lc_gbsta_a.
        PERFORM f_get_planned_item USING <lfs_itm_stat>-posnr
                                      CHANGING i_sch_line_a.

**Schedule line data, expected date and quantity
        LOOP AT i_sch_line_a ASSIGNING <lfs_sch_lin>.
          wa_schline_out-etenr = <lfs_sch_lin>-etenr.
          wa_schline_out-zex_delv_dte = <lfs_sch_lin>-edatu.
          wa_schline_out-zconf_quan = <lfs_sch_lin>-bmeng.
          wa_schline_out-zunit = <lfs_sch_lin>-vrkme.
          APPEND wa_schline_out TO i_schline_out.
          CLEAR: wa_schline_out.
        ENDLOOP. " LOOP AT i_sch_line_a ASSIGNING <lfs_sch_lin>

** For partially delivered item
      WHEN lc_gbsta_b.
        PERFORM  f_get_planned_item USING <lfs_itm_stat>-posnr
                                       CHANGING i_sch_line_b.

        PERFORM f_get_delivered_item USING <lfs_itm_stat>-posnr
                                             CHANGING i_delv_doc_b.


        CLEAR: lv_quan_tmp,
                 lv_quan_2,
                 lv_date_sch.
        LOOP AT i_delv_doc_b ASSIGNING <lfs_delv_doc>.
**expected date and quantity
          IF ( <lfs_delv_doc>-wbstk = lc_wbstk_a OR <lfs_delv_doc>-wbstk = lc_wbstk_b ).
            wa_schline_out-zex_delv_dte = <lfs_delv_doc>-edatu.
            wa_schline_out-zconf_quan = <lfs_delv_doc>-bmeng.
** get total refrenced or delivered quantity
            lv_quan_tmp  = wa_schline_out-zconf_quan + lv_quan_tmp.

** Delivered date and quantity
          ELSEIF <lfs_delv_doc>-wbstk = lc_wbstk_c.
            wa_schline_out-zdelv_dte = <lfs_delv_doc>-edatu.
            wa_schline_out-zdelv_quan = <lfs_delv_doc>-bmeng.
** get total refrenced or delivered quantity
            lv_quan_tmp  = wa_schline_out-zdelv_quan + lv_quan_tmp.

          ENDIF. " IF ( <lfs_delv_doc>-wbstk = lc_wbstk_a OR <lfs_delv_doc>-wbstk = lc_wbstk_b )
          wa_schline_out-zunit = <lfs_delv_doc>-vrkme.

**tracking number
* ---> Begin of Change for D2_OTC_IDD_0092_CR_167 by AGUPTA3
*          REFRESH : li_track_num.
*          APPEND <lfs_delv_doc>-ztrack TO li_track_num.
*          wa_schline_out-ztrack_number[] = li_track_num[].
          wa_schline_out-ztrack_number[] = <lfs_delv_doc>-ztrack[].
* ---> End of Change for D2_OTC_IDD_0092_CR_167 by AGUPTA3
          APPEND wa_schline_out TO i_schline_out.

**Get the last delivery date
          IF <lfs_delv_doc>-edatu GT lv_date_sch.

            lv_date_sch = <lfs_delv_doc>-edatu.
          ENDIF. " IF <lfs_delv_doc>-edatu GT lv_date_sch
          CLEAR: wa_schline_out.
        ENDLOOP. " LOOP AT i_delv_doc_b ASSIGNING <lfs_delv_doc>
**populate remaining schedule line item
        CLEAR: lv_quan_1,
                lv_count.
        LOOP AT i_sch_line_b ASSIGNING <lfs_sch_lin>.
          lv_quan_1 = lv_quan_1 + <lfs_sch_lin>-bmeng.
** Get whether any not delivered or not referenced quantity remaining
          IF lv_quan_tmp GE lv_quan_1.
            CONTINUE.
**Get whether any planned delivery in back date or not
          ELSEIF lv_date_sch GT <lfs_sch_lin>-edatu.
            lv_quan_1 = lv_quan_1 + <lfs_sch_lin>-bmeng.
            CONTINUE.
          ELSE. " ELSE -> IF lv_quan_tmp GE lv_quan_1
            lv_quan_1 = lv_quan_1 - lv_quan_tmp.
** populate Schedule line for remaining quantity
            wa_schline_out-etenr = <lfs_sch_lin>-etenr.
            wa_schline_out-zex_delv_dte = <lfs_sch_lin>-edatu.
            wa_schline_out-zconf_quan = <lfs_sch_lin>-bmeng.
            wa_schline_out-zunit = <lfs_sch_lin>-vrkme.

            lv_count = lv_count + 1.
          ENDIF. " IF lv_quan_tmp GE lv_quan_1

          AT LAST.
** Remaining confirmed quantity will be added to the last Schedule line.
            IF lv_count = 1.
              wa_schline_out-zconf_quan = lv_quan_1.
            ELSE. " ELSE -> IF lv_count = 1
              wa_schline_out-zconf_quan = wa_schline_out-zconf_quan + lv_quan_1.

            ENDIF. " IF lv_count = 1
          ENDAT.
          APPEND wa_schline_out TO i_schline_out.
          CLEAR: wa_schline_out.
        ENDLOOP. " LOOP AT i_sch_line_b ASSIGNING <lfs_sch_lin>

** For fully delivered item
      WHEN lc_gbsta_c.

        PERFORM f_get_delivered_item USING <lfs_itm_stat>-posnr
                                            CHANGING i_delv_doc_c.


        LOOP AT i_delv_doc_c ASSIGNING <lfs_delv_doc>.
**expected date and quantity
          IF ( <lfs_delv_doc>-wbstk = lc_wbstk_a OR <lfs_delv_doc>-wbstk = lc_wbstk_b ).
            wa_schline_out-zex_delv_dte = <lfs_delv_doc>-edatu.
            wa_schline_out-zconf_quan = <lfs_delv_doc>-bmeng.

** Delivered date and quantity
          ELSEIF <lfs_delv_doc>-wbstk = lc_wbstk_c.
            wa_schline_out-zdelv_dte = <lfs_delv_doc>-edatu.
            wa_schline_out-zdelv_quan = <lfs_delv_doc>-bmeng.
          ENDIF. " IF ( <lfs_delv_doc>-wbstk = lc_wbstk_a OR <lfs_delv_doc>-wbstk = lc_wbstk_b )

          wa_schline_out-zunit = <lfs_delv_doc>-vrkme.
**tracking number
* ---> Begin of Change for D2_OTC_IDD_0092_CR_167 by AGUPTA3
*          REFRESH : li_track_num.
*          APPEND <lfs_delv_doc>-ztrack TO li_track_num.
*          wa_schline_out-ztrack_number[] = li_track_num[].
          wa_schline_out-ztrack_number[] = <lfs_delv_doc>-ztrack[].
* ---> End of Change for D2_OTC_IDD_0092_CR_167 by AGUPTA3
          APPEND wa_schline_out TO i_schline_out.
          CLEAR: wa_schline_out.
        ENDLOOP. " LOOP AT i_delv_doc_c ASSIGNING <lfs_delv_doc>
      WHEN OTHERS.
    ENDCASE.

** final output
    IF i_schline_out[] IS NOT INITIAL.
* ---> Begin of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS
      ex_flag = abap_true.
* <--- End of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS
      wa_output-zdelv_data = i_schline_out[].
      APPEND wa_output TO i_output.
      CLEAR: wa_output.
      REFRESH: i_schline_out[].
    ENDIF. " IF i_schline_out[] IS NOT INITIAL

  ENDLOOP. " LOOP AT i_item_stat ASSIGNING <lfs_itm_stat>
************************************************************************


** Check whether Order related or not
  i_item_tmp[] = i_item[].

  DELETE i_item_tmp[] WHERE NOT ( fkrel IN i_ord_stat ).

  IF i_item_tmp[] IS NOT INITIAL.

**get the delivery docs
    i_docflow_tmp[] = i_docflow[].
    DELETE i_docflow_tmp WHERE NOT ( ( vbelv EQ im_sals_order
                     AND vbtyp_n EQ lc_vbtyp_n_v )
                     AND ( vbtyp_v EQ lc_vbtyp_v_c
* ---> Begin of Change for D2_OTC_IDD_0092_Defect 5842 by DMOIRAN
* for ZSAM (Sample) order, order type is I
                          or vbtyp_v EQ lc_vbtyp_v_i )
* <--- End of Change for D2_OTC_IDD_0092_Defect 58426 by DMOIRAN
                     AND ( rfmng NE 0 ) ).
    SORT i_docflow_tmp BY vbelv.
    DELETE ADJACENT DUPLICATES FROM i_docflow_tmp COMPARING ALL FIELDS.
    IF i_docflow_tmp[] IS NOT INITIAL.

** Get Inbound delivery
      SELECT ebeln   " Purchasing Document Number
             ebelp   " Item Number of Purchasing Document
             eindt   " Delivery Date of Vendor Confirmation
             vbeln   " Delivery
             vbelp   " Delivery Item
           FROM ekes " Vendor Confirmations
        INTO TABLE i_ib_delv
        FOR ALL ENTRIES IN i_docflow_tmp
        WHERE ebeln = i_docflow_tmp-vbeln.
      IF sy-subrc = 0.
** get SD delivery item
        REFRESH : i_sddelivitm_data.
        SELECT vbeln " Delivery
               posnr " Delivery Item
               lfimg " Actual quantity delivered (in sales units)
               vrkme " Sales unit
        FROM lips    " SD document: Delivery: Item data
        INTO TABLE i_sddelivitm_data
        FOR ALL ENTRIES IN i_ib_delv
        WHERE vbeln = i_ib_delv-vbeln
        AND posnr = i_ib_delv-vbelp.

        IF sy-subrc = 0.
          SORT i_sddelivitm_data BY vbeln ASCENDING
                                     posnr ASCENDING.
        ENDIF. " IF sy-subrc = 0

**  Get Bill of Lading

        SELECT vbeln " Delivery
* ---> Begin of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS
*               bolnr " Bill of lading
                lifex
* <--- End of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS
          FROM likp  " SD Document: Delivery Header Data
          INTO TABLE i_bol
          FOR ALL ENTRIES IN i_ib_delv
          WHERE vbeln = i_ib_delv-vbeln.

        IF sy-subrc = 0.
          SORT i_bol BY vbeln.
        ENDIF. " IF sy-subrc = 0

      ENDIF. " IF sy-subrc = 0

    ENDIF. " IF i_docflow_tmp[] IS NOT INITIAL

**loop is used on multiple tables with restricted entries so,
** delete statement is used instead of parallel cursor.
    LOOP AT i_item_tmp ASSIGNING <lfs_item>.
      CLEAR: wa_schline_out.
      wa_output-vbeln = <lfs_item>-vbeln.
      wa_output-posnr = <lfs_item>-posnr.
      REFRESH: li_docflow_tmp1.

      li_docflow_tmp1[] = i_docflow_tmp[].
      DELETE  li_docflow_tmp1 WHERE NOT ( ( vbelv EQ <lfs_item>-vbeln )
                                       AND ( posnv EQ <lfs_item>-posnr ) ).
** check if PO generated
      IF li_docflow_tmp1[] IS NOT INITIAL.
        CLEAR: lv_quan_2,
               gv_flag.
        LOOP AT li_docflow_tmp1 ASSIGNING <lfs_doc_flow>.
** check Inbound delivery generated
          REFRESH : li_ib_delv_tmp[].
          li_ib_delv_tmp = i_ib_delv[].
          DELETE li_ib_delv_tmp WHERE NOT ( ( ebeln EQ <lfs_doc_flow>-vbeln )
                                 AND ( ebelp EQ <lfs_doc_flow>-posnn ) ).
          IF li_ib_delv_tmp[] IS NOT INITIAL.
            LOOP AT li_ib_delv_tmp ASSIGNING <lfs_ib_delv>.

**get delivered quantity.
              CLEAR: lv_delv_quan.
              CLEAR: li_sdlitm_tmp[].
              li_sdlitm_tmp[] = i_sddelivitm_data[].
              DELETE li_sdlitm_tmp[] WHERE NOT ( vbeln = <lfs_ib_delv>-vbeln
                                               AND posnr = <lfs_ib_delv>-vbelp ).
**only entries related to particuler item will exist is table
              LOOP AT li_sdlitm_tmp ASSIGNING <lfs_lips>.

                lv_delv_quan = <lfs_lips>-lfimg + lv_delv_quan.
                wa_schline_out-zunit = <lfs_lips>-vrkme.
              ENDLOOP. " LOOP AT li_sdlitm_tmp ASSIGNING <lfs_lips>
              lv_quan_2 = lv_delv_quan + lv_quan_2.
              IF  lv_delv_quan IS NOT INITIAL.
** Get Bill of Lading
                READ TABLE i_bol ASSIGNING <lfs_bol>
                                  WITH KEY vbeln = <lfs_ib_delv>-vbeln
                                  BINARY SEARCH.
                IF sy-subrc = 0.
                  REFRESH : li_track_num.
* ---> Begin of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS
*                   lv_track_num = <lfs_bol>-bolnr.
                  lv_track_num = <lfs_bol>-lifex.
* <--- End of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS
                  APPEND lv_track_num TO li_track_num.
                  wa_schline_out-ztrack_number[] = li_track_num[].

** Get SCAC code/ Route ID name
                  REFRESH : li_text.
                  lv_text_name = <lfs_ib_delv>-vbeln.
                  CALL FUNCTION 'READ_TEXT'
                    EXPORTING
                      client                  = sy-mandt
                      id                      = lc_id
                      language                = sy-langu
                      name                    = lv_text_name
                      object                  = lc_object
                    TABLES
                      lines                   = li_text
                    EXCEPTIONS
                      id                      = 1
                      language                = 2
                      name                    = 3
                      not_found               = 4
                      object                  = 5
                      reference_check         = 6
                      wrong_access_to_archive = 7
                      OTHERS                  = 8.
                  IF sy-subrc = 0.
                    READ TABLE li_text ASSIGNING <lfs_text> INDEX 1.
                    IF sy-subrc = 0.
                      wa_schline_out-zscac_code = <lfs_text>-tdline.
                    ENDIF. " IF sy-subrc = 0
                  ENDIF. " IF sy-subrc = 0
                ENDIF. " IF sy-subrc = 0

** Deliver date and quantity
                wa_schline_out-zdelv_dte = <lfs_ib_delv>-eindt.
                wa_schline_out-zdelv_quan = lv_delv_quan.
                APPEND wa_schline_out TO i_schline_out.
              ENDIF. " IF lv_delv_quan IS NOT INITIAL
              CLEAR: wa_schline_out.
            ENDLOOP. " LOOP AT li_ib_delv_tmp ASSIGNING <lfs_ib_delv>
          ENDIF. " IF li_ib_delv_tmp[] IS NOT INITIAL
        ENDLOOP. " LOOP AT li_docflow_tmp1 ASSIGNING <lfs_doc_flow>

**Get Schedule line data.
        REFRESH : i_sch_line_1[].
        gv_flag = abap_true.
        PERFORM f_get_planned_item USING <lfs_item>-posnr
                                      CHANGING i_sch_line_1.

**Assuming ther will be only 1 schedule line per item.
        READ TABLE i_sch_line_1 ASSIGNING <lfs_sch_lin>
                                          INDEX 1.
        IF sy-subrc = 0.
          lv_quan_2 = <lfs_sch_lin>-wmeng - lv_quan_2.
**Check delivered quantity less than confirmed quantity or not
          IF lv_quan_2 GT 0.
            wa_schline_out-etenr = <lfs_sch_lin>-etenr.
            wa_schline_out-zex_delv_dte = <lfs_sch_lin>-edatu.
            wa_schline_out-zconf_quan   = lv_quan_2.
            wa_schline_out-zunit   = <lfs_sch_lin>-vrkme.
            APPEND wa_schline_out TO i_schline_out.
          ENDIF. " IF lv_quan_2 GT 0
        ENDIF. " IF sy-subrc = 0

      ELSE. " ELSE -> IF lv_quan_2 GT 0
** if no PO generated
        REFRESH: i_sch_line_1.

        PERFORM f_get_planned_item USING <lfs_item>-posnr
                                       CHANGING i_sch_line_1.

        LOOP AT i_sch_line_1 ASSIGNING <lfs_sch_lin>.
          wa_schline_out-etenr = <lfs_sch_lin>-etenr.
          wa_schline_out-zex_delv_dte = <lfs_sch_lin>-edatu.
          wa_schline_out-zconf_quan = <lfs_sch_lin>-bmeng.
          APPEND wa_schline_out TO i_schline_out.
          CLEAR: wa_schline_out.
        ENDLOOP. " LOOP AT i_sch_line_1 ASSIGNING <lfs_sch_lin>
      ENDIF. " IF li_docflow_tmp1[] IS NOT INITIAL
**Final Output
      IF i_schline_out[] IS NOT INITIAL.
        wa_output-zdelv_data = i_schline_out[].
        APPEND wa_output TO i_output.
        CLEAR: wa_output.
        REFRESH: i_schline_out[].
      ENDIF. " IF i_schline_out[] IS NOT INITIAL

    ENDLOOP. " LOOP AT i_item_tmp ASSIGNING <lfs_item>

  ENDIF. " IF i_item_tmp[] IS NOT INITIAL

  ex_delv_data[] = i_output[].

ENDFUNCTION.
