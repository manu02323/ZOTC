class ZCL_IM_IM_OTC_CDD_0007 definition
  public
  final
  create public .

public section.
*"* public components of class ZCL_IM_IM_OTC_CDD_0007
*"* do not include other source files here!!!

  interfaces IF_EX_IDOC_DATA_INSERT .
protected section.
*"* protected components of class ZCL_IM_IM_OTC_CDD_0007
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_IM_OTC_CDD_0007
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_IM_OTC_CDD_0007 IMPLEMENTATION.


METHOD if_ex_idoc_data_insert~fill.

************************************************************************
* PROGRAM    :  ZIM_OTC_CDD_0007 (Badi Implementation)                 *
* TITLE      :  Convert Open Sales Orders_VA01                         *
* DEVELOPER  :  Shammi Puri                                            *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_CDD_0007/CR232                                       *
*----------------------------------------------------------------------*
* DESCRIPTION:  Convert Open Sales Orders_VA01                         *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 12-12-2012  SPURI    E1DK901610 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*

* Local Types
  TYPES    :        BEGIN OF lty_vbeln,
                      matnr TYPE matnr,   "Material No
                      vbeln TYPE vbeln,   "Document no
                    END OF lty_vbeln,

                    BEGIN OF lty_matnr,
                      matnr TYPE matnr,   "Material No
                    END OF lty_matnr.

* Local constants
  CONSTANTS: lc_segnam_e1bpparnr  TYPE edi_segnam VALUE 'E1BPPARNR',
             lc_segnam_e1bpsdhd1  TYPE edi_segnam VALUE 'E1BPSDHD1',
             lc_segnam_e1bpsditm  TYPE edi_segnam VALUE 'E1BPSDITM',
             lc_segnam_e1bpsditm1 TYPE edi_segnam VALUE 'E1BPSDITM1',
             lc_idoctp            TYPE edi_idoctp VALUE 'SALESORDER_CREATEFROMDAT202',
             lc_direct_2          TYPE edi_direct VALUE '2',
             lc_stamid_otc        TYPE edi_stamid VALUE 'ZOTC_MSG',
             lc_stamno_21         TYPE edi_stamno VALUE '021',
             lc_parvw_we          TYPE char2      VALUE 'WE',
             lc_parvw_ag          TYPE char2      VALUE 'AG',
             lc_mprogram          TYPE programm   VALUE 'IDOC_DATA_INSERT', "Program name
             lc_mparameter        TYPE enhee_parameter VALUE 'E1BPSDHD1-DOC_TYPE', "Parameter KSCHL
             lc_on                TYPE char1      VALUE 'X',  "Flag ON
             lc_option_eq         TYPE char2      VALUE 'EQ'.     "Option - EQ.

* Local data declaration
  DATA           :   lv_we               TYPE char10,
                     lv_ag               TYPE char10,
                     lv_trg_typ          TYPE edi_bsart,
                     lv_sale_org         TYPE vkorg,
                     lv_dist_ch          TYPE vtweg,
                     lv_div              TYPE spart,
                     lv_doc_type         TYPE auart,
                     lwa_data            TYPE edid4,
                     lv_vgbel            TYPE vgbel,
                     lv_matnr            TYPE vbap-matnr,
                     lx_e1bpparnr        TYPE e1bpparnr,
                     lx_e1bpsdhd1        TYPE e1bpsdhd1,
                     lx_e1bpsditm        TYPE e1bpsditm,
                     lx_e1bpsditm1       TYPE e1bpsditm1,
                     li_vbeln            TYPE STANDARD TABLE OF lty_vbeln,
                     li_vbeln_temp       TYPE STANDARD TABLE OF lty_vbeln,
                     li_matnr            TYPE STANDARD TABLE OF lty_matnr,
                     lwa_vbeln           TYPE lty_vbeln,
                     lwa_matnr           TYPE lty_matnr,
                     lv_lines1           TYPE sytabix,
                     lv_counter          TYPE char3,
                     lwa_insert_rec      TYPE idoc_insert,
                     lv_added            TYPE char1,
                     lwa_data1           TYPE edid4.

* Local field symbols
  FIELD-SYMBOLS  :   <lfs_data>     TYPE edid4.


  CASE control-idoctp.
    WHEN lc_idoctp.
      IF control-direct  = lc_direct_2.
*Get Ship to
        READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam = lc_segnam_e1bpparnr  sdata+0(2) = lc_parvw_we.
        IF sy-subrc = 0.
          lx_e1bpparnr = <lfs_data>-sdata.
          lv_we = lx_e1bpparnr-partn_numb.
          CLEAR: lx_e1bpparnr.
        ENDIF.
*Get Sold to
        READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam = lc_segnam_e1bpparnr  sdata+0(2) = lc_parvw_ag.
        IF sy-subrc = 0.
          lx_e1bpparnr = <lfs_data>-sdata.
          lv_ag = lx_e1bpparnr-partn_numb.
          CLEAR: lx_e1bpparnr.
        ENDIF.
*Get Sales Org , Distribution and Division.
        READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam = lc_segnam_e1bpsdhd1.
        IF sy-subrc = 0.
          lx_e1bpsdhd1 = <lfs_data>-sdata.
          lv_doc_type = lx_e1bpsdhd1-doc_type.
          lv_sale_org = lx_e1bpsdhd1-sales_org.
          lv_dist_ch  = lx_e1bpsdhd1-distr_chan.
          lv_div      = lx_e1bpsdhd1-division.
          CLEAR lx_e1bpsdhd1.
        ENDIF.

* Fetch respective Contract Type based Sales order type
* from Sales Control table
        SELECT SINGLE mvalue2
               FROM   zotc_prc_control
               INTO   lv_trg_typ
               WHERE  vkorg      = lv_sale_org    AND
                      vtweg      = lv_dist_ch     AND
                      mprogram   = lc_mprogram    AND
                      mparameter = lc_mparameter  AND
                      mactive    = lc_on          AND
                      soption    = lc_option_eq   AND
                      mvalue1    = lv_doc_type
                      .
        IF sy-subrc = 0.

          LOOP AT data INTO lwa_data WHERE segnam =  lc_segnam_e1bpsditm.

*           Get the Reference no
            CLEAR lv_vgbel.
            READ TABLE data ASSIGNING <lfs_data> WITH KEY psgnum     = lwa_data-segnum
                                                          segnam     = lc_segnam_e1bpsditm1.

            IF sy-subrc = 0.
              lx_e1bpsditm1 = <lfs_data>-sdata.
              lv_vgbel   = lx_e1bpsditm1-ref_doc.
            ENDIF.

*           if reference number not found collect respective material
*           to an inetrnal table
            IF lv_vgbel IS INITIAL.

              lx_e1bpsditm = lwa_data-sdata.
              lv_matnr = lx_e1bpsditm-material.
              CLEAR: lx_e1bpsditm.

              lwa_matnr-matnr = lv_matnr.
              APPEND lwa_matnr TO li_matnr.
              CLEAR: lwa_matnr.

            ENDIF.
          ENDLOOP.


          IF li_matnr IS NOT INITIAL.

            SORT li_matnr BY matnr.
            DELETE ADJACENT DUPLICATES FROM li_matnr
              COMPARING matnr.

* select respective contract document from database
            SELECT vapma~matnr  "Material
                   vapma~vbeln  "Doc no
                   INTO TABLE li_vbeln
                   FROM vapma INNER JOIN vbpa ON
                   vapma~vbeln = vbpa~vbeln
                   FOR ALL ENTRIES IN li_matnr
                                WHERE vapma~matnr =  li_matnr-matnr     AND
                                      vapma~vkorg =  lv_sale_org        AND
                                      vapma~vtweg =  lv_dist_ch         AND
                                      vapma~spart =  lv_div             AND
                                      vapma~auart =  lv_trg_typ         AND
                                      vapma~kunnr =  lv_ag              AND
                                      vapma~datab <=  sy-datum          AND
                                      vapma~datbi >=  sy-datum          AND
                                      vbpa~kunnr   =  lv_we.
            IF sy-subrc IS INITIAL.
              SORT li_vbeln BY vbeln matnr.
              DELETE ADJACENT DUPLICATES FROM li_vbeln COMPARING vbeln matnr.
            ENDIF.
          ENDIF.

*         Populate contract reference if not populated
          LOOP AT data INTO lwa_data WHERE segnam =  lc_segnam_e1bpsditm.
            CLEAR: lv_vgbel,lx_e1bpsditm.

*           Get the reference number
            READ TABLE data ASSIGNING <lfs_data> WITH KEY psgnum     = lwa_data-segnum
                                                          segnam     = lc_segnam_e1bpsditm1.

            IF sy-subrc = 0.
              lx_e1bpsditm1 = <lfs_data>-sdata.
              lv_vgbel   = lx_e1bpsditm1-ref_doc.
              CLEAR: lx_e1bpsditm1.
            ENDIF.

*           If reference number not found
            IF lv_vgbel IS INITIAL.

              lx_e1bpsditm = lwa_data-sdata.
              lv_matnr = lx_e1bpsditm-material.

*             Check how many contract ref exists against the item
              li_vbeln_temp = li_vbeln.
              DELETE li_vbeln_temp WHERE matnr NE lv_matnr.

              DESCRIBE TABLE li_vbeln_temp LINES lv_lines1.
*              Single ref found
              IF lv_lines1 = 1 .
                READ TABLE li_vbeln_temp INTO lwa_vbeln INDEX 1.
                IF sy-subrc = 0.
                  lwa_insert_rec-counter   =   lv_counter.
                  lwa_insert_rec-segnam    =   lc_segnam_e1bpsditm1.
                  lwa_insert_rec-segnum    =   lwa_data-segnum.
                  lx_e1bpsditm1-ref_doc = lwa_vbeln-vbeln.
                  lwa_data1-sdata    =   lx_e1bpsditm1.
                  lwa_insert_rec-sdata     =   lwa_data1-sdata.
                  APPEND  lwa_insert_rec TO new_entries.
                  CLEAR : lwa_data1,lwa_insert_rec,lx_e1bpsditm1.
                  lv_added = lc_on.
                  lv_counter = lv_counter + 1.
                ENDIF.
*               No ref found
              ELSEIF  lv_lines1 = 0.
                lwa_insert_rec-counter   =   lv_counter.
                lwa_insert_rec-segnam    =   lc_segnam_e1bpsditm1.
                lwa_insert_rec-segnum    =   lwa_data-segnum.
                lx_e1bpsditm1-ref_doc_it    =   lx_e1bpsditm-itm_number.
                lwa_data1-sdata    =   lx_e1bpsditm1.
                lwa_insert_rec-sdata     =   lwa_data1-sdata.
                APPEND  lwa_insert_rec TO new_entries.
                CLEAR : lwa_data1,lwa_insert_rec,lx_e1bpsditm1.
                lv_added = lc_on.
                lv_counter = lv_counter + 1.
*             multiple ref found
              ELSEIF lv_lines1 > 1.
                lwa_insert_rec-counter   =   lv_counter.
                lwa_insert_rec-segnam    =   lc_segnam_e1bpsditm1.
                lwa_insert_rec-segnum    =   lwa_data-segnum.
                lx_e1bpsditm1-WBS_ELEM   =   text-002.
                lwa_data1-sdata          =   lx_e1bpsditm1.
                lwa_insert_rec-sdata     =   lwa_data1-sdata.
                APPEND  lwa_insert_rec TO new_entries.
                CLEAR : lwa_data1,lwa_insert_rec.
                lv_added = lc_on.
                lv_counter = lv_counter + 1.
              ENDIF.

            ENDIF.
          ENDLOOP.

        ENDIF.
        IF lv_added = lc_on.
          have_to_change  = lc_on.
          protocol-stamid = lc_stamid_otc.            "Status message ID
          protocol-stamno = lc_stamno_21.                 "Status message number
          protocol-stapa1 = text-001.              "Parameter 1
          protocol-repid  = sy-cprog .             "Program Name
        ENDIF.
      ENDIF.
  ENDCASE.
ENDMETHOD.
ENDCLASS.
