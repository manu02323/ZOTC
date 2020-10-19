class ZOTC_CL_DEL_BATCH_TRANSFER definition
  public
  final
  create public .

public section.

  interfaces /SAPSLL/IF_EX_IFEX_SD0B_R3 .
protected section.
private section.
ENDCLASS.



CLASS ZOTC_CL_DEL_BATCH_TRANSFER IMPLEMENTATION.


METHOD /sapsll/if_ex_ifex_sd0b_r3~if_extend_con_cdoc.
***********************************************************************
*Program    : /SAPSLL/IF_EX_IFEX_SD0B_R3~IF_EXTEND_CON_CDOC           *
*Title      : Transfer batch to GTS                                   *
*Developer  : Ayushi Jain                                             *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_EDD_0344                                           *
*---------------------------------------------------------------------*
*Description: BADI is implemented to perform transfer of batch value  *
*             from ECC to GTS for each line item of Delivery.         *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*17-JUN-2016  U033830       E1DK918373     Initial Development
*---------------------------------------------------------------------*
* Local type declaration
  TYPES:BEGIN OF lty_batch,
         matnr    TYPE matnr,       " Material Number
         charg    TYPE charg_d,     " Batch Number
         land1    TYPE land1,       " Country Key
         kunnr    TYPE kunnr,       " Customer Number
        END OF lty_batch.

* Local variable declaration
  DATA: lv_ship_to    TYPE land1,    " Ship to party country
        lv_del_batch  TYPE boolean,  " Del. batch active indicator
        lv_batch_val  TYPE charg_d,  " Batch value as KGB
        lv_batch      TYPE charg_d,  " Batch Number
        lv_tabix      TYPE sy-tabix, " table Index
        lv_item_num   TYPE char10.   " GTS Item number

* Local internal table Declaration
  DATA : li_status_table
             TYPE STANDARD TABLE OF zdev_enh_status, " Table for Enhancement status data
         li_rest_batch
             TYPE STANDARD TABLE OF lty_batch,       " Restricted Batch Table
         li_lips
             TYPE shp_vl10_lips_t,                   " Delivery Item
         li_vbpa
             TYPE vbpavb_tab,                        " Partner
         li_gen
             TYPE sllr3_api6800_itm_r3_t.            " SLL: API Comm. Structure: Customs Document: Item

* Local field symbol declaration
  FIELD-SYMBOLS: <lfs_status>  TYPE zdev_enh_status,          " Enhancement Status
                 <lfs_lips>    TYPE lipsvb,                   " Reference structure for XLIPS/YLIPS
                 <lfs_lips_bs> TYPE lipsvb,                   " Reference structure for XLIPS/YLIPS
                 <lfs_vbpa>    TYPE vbpavb,                   " Reference structure for XVBPA/YVBPA
                 <lfs_gen>     TYPE /sapsll/api6800_itm_r3_s. " SLL: API Comm. Structure: Customs Document: Item

* Constant declaration
  CONSTANTS: lc_ship_to    TYPE parvw         VALUE 'WE',            " Ship To
             lc_posnr_0    TYPE posnr         VALUE '000000',        " Item as 0 for header level
             lc_del_batch  TYPE z_criteria    VALUE 'DEL_BATCH_ACT', " Enh. Criteria
             lc_batch_val  TYPE z_criteria    VALUE 'BATCH_VAL',     " Enh. Criteria
             lc_null       TYPE z_criteria    VALUE 'NULL',          " Null criteria
             lc_enh_name   TYPE z_enhancement VALUE 'OTC_EDD_0344'.  " Enhancement No

* Call function to fetch EMI data
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_name
    TABLES
      tt_enh_status     = li_status_table
    EXCEPTIONS
      OTHERS            = 1.
  IF sy-subrc IS INITIAL.

    SORT li_status_table BY criteria
                            active.
  ENDIF. " IF sy-subrc IS INITIAL

* Read status table for NULL criteria
  READ TABLE li_status_table ASSIGNING <lfs_status>
                             WITH KEY criteria = lc_null
                                      active   = abap_true
                             BINARY SEARCH.
  IF sy-subrc IS INITIAL.
*   Read status table for criteria Batch val and active = X
    READ TABLE li_status_table ASSIGNING <lfs_status>
                               WITH KEY criteria = lc_batch_val
                                        active   = abap_true
                               BINARY SEARCH.
    IF sy-subrc IS INITIAL.
*     Populate value for batch as 'KGB'
      lv_batch_val = <lfs_status>-sel_low. " 'KGB'
    ENDIF. " IF sy-subrc IS INITIAL

*   Read status table for criteria DEl_BATCH_ACT and active = X
    READ TABLE li_status_table ASSIGNING <lfs_status>
                               WITH KEY criteria = lc_del_batch
                                        active   = abap_true
                               BINARY SEARCH.
    IF sy-subrc IS INITIAL.
*     Populate value
      lv_del_batch = <lfs_status>-sel_low.
    ENDIF. " IF sy-subrc IS INITIAL

* Logic for batch transfer to be triggered only if,
* Criteria “DEL_BATCH_ACT” is set to “X” in ZDEV_EMI
    IF lv_del_batch = abap_true.

      li_lips[] = it_lips[].
      SORT li_lips BY matnr
                      charg.
      DELETE ADJACENT DUPLICATES FROM li_lips COMPARING matnr
                                                        charg.

      IF NOT li_lips IS INITIAL.

*      Fetch restricted batch data from custom table
        SELECT matnr           " Material Number
               charg           " Batch Number
               land1           " Country Key
               kunnr           " Customer Number
          FROM zotc_rest_batch " Restricted Batch Table
          INTO TABLE li_rest_batch
          FOR ALL ENTRIES IN li_lips
          WHERE matnr = li_lips-matnr
            AND charg = li_lips-charg.
        IF sy-subrc IS INITIAL.
          SORT li_rest_batch BY matnr
                                charg
                                land1
                                kunnr.
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF NOT li_lips IS INITIAL

*   Move GTS item data in local table and sort it
      li_gen[] = cs_itm_cdoc-gen[].
      SORT li_gen BY item_number.

*     Move sales partner data in local table and sort it
      li_vbpa[] = it_vbpa[].
      SORT li_vbpa BY vbeln
                      posnr
                      parvw.

*     Read VBPA table for partner Ship to party
      READ TABLE li_vbpa ASSIGNING <lfs_vbpa>
                         WITH KEY vbeln = is_likp-vbeln
                                  posnr = lc_posnr_0 " Hedaer leavel parvw
                                  parvw = lc_ship_to
                                  BINARY SEARCH.

      IF sy-subrc IS INITIAL.
*     Populate value for Ship to party country
        lv_ship_to = <lfs_vbpa>-land1.
      ENDIF. " IF sy-subrc IS INITIAL

      REFRESH li_lips.
      li_lips[] = it_lips[].
      SORT li_lips BY uecha.

      UNASSIGN <lfs_lips>.
*     Loop at each main line item
      LOOP AT it_lips ASSIGNING <lfs_lips>.

        IF <lfs_lips>-uecha IS INITIAL.

          READ TABLE li_lips TRANSPORTING NO FIELDS
                             WITH KEY uecha = <lfs_lips>-posnr
                             BINARY SEARCH.
          IF sy-subrc IS INITIAL. " Batch split is there

            lv_tabix = sy-tabix.

*         Loop at each batch splitted line item
            LOOP AT li_lips ASSIGNING <lfs_lips_bs> FROM lv_tabix.

              IF <lfs_lips_bs>-uecha NE <lfs_lips>-posnr.
                EXIT.
              ENDIF. " IF <lfs_lips_bs>-uecha NE <lfs_lips>-posnr

****************Determine batch in case of batch split*************
**********Check entry using splitted batch in custom table********

*           Read table for material,Batch,Country and Ship-to
              READ TABLE li_rest_batch TRANSPORTING NO FIELDS
                                       WITH KEY matnr = <lfs_lips>-matnr
                                                charg = <lfs_lips_bs>-charg
                                                land1 = lv_ship_to
                                                kunnr = is_likp-kunnr
                                                BINARY SEARCH.
              IF sy-subrc IS INITIAL.
*             Batch from splitted line item
                lv_batch = <lfs_lips_bs>-charg.
                EXIT.
              ELSE. " ELSE -> IF sy-subrc IS INITIAL

*             Read table for material,Batch,Country and Sold-to
                READ TABLE li_rest_batch TRANSPORTING NO FIELDS
                     WITH KEY matnr = <lfs_lips>-matnr
                              charg = <lfs_lips_bs>-charg
                              land1 = lv_ship_to
                              kunnr = is_likp-kunag
                              BINARY SEARCH.
                IF sy-subrc IS INITIAL.
*               Batch from splitted line item
                  lv_batch = <lfs_lips_bs>-charg.
                  EXIT.
                ELSE. " ELSE -> IF sy-subrc IS INITIAL

*               Read table for material,Batch and Ship to
                  READ TABLE li_rest_batch TRANSPORTING NO FIELDS
                       WITH KEY matnr = <lfs_lips>-matnr
                                charg = <lfs_lips_bs>-charg
                                land1 = space
                                kunnr = is_likp-kunnr
                                BINARY SEARCH.
                  IF sy-subrc IS INITIAL.
*                 Batch from splitted line item
                    lv_batch = <lfs_lips_bs>-charg.
                    EXIT.
                  ELSE. " ELSE -> IF sy-subrc IS INITIAL

*                 Read table for material,Batch and Sold to
                    READ TABLE li_rest_batch TRANSPORTING NO FIELDS
                         WITH KEY matnr = <lfs_lips>-matnr
                                  charg = <lfs_lips_bs>-charg
                                  land1 = space
                                  kunnr = is_likp-kunag
                                  BINARY SEARCH.
                    IF sy-subrc IS INITIAL.
*                   Batch from splitted line item
                      lv_batch = <lfs_lips_bs>-charg.
                      EXIT.
                    ELSE. " ELSE -> IF sy-subrc IS INITIAL

*                   Read table for material,Batch and Country
                      READ TABLE li_rest_batch TRANSPORTING NO FIELDS
                           WITH KEY matnr = <lfs_lips>-matnr
                                    charg = <lfs_lips_bs>-charg
                                    land1 = lv_ship_to
                                    kunnr = space
                                    BINARY SEARCH.
                      IF sy-subrc IS INITIAL.
*                     Batch from splitted line item
                        lv_batch = <lfs_lips_bs>-charg.
                        EXIT.
                      ENDIF. " IF sy-subrc IS INITIAL
                    ENDIF. " IF sy-subrc IS INITIAL
                  ENDIF. " IF sy-subrc IS INITIAL
                ENDIF. " IF sy-subrc IS INITIAL
              ENDIF. " IF sy-subrc IS INITIAL

            ENDLOOP. " LOOP AT li_lips ASSIGNING <lfs_lips_bs> FROM lv_tabix

          ELSE. " ELSE -> IF sy-subrc IS INITIAL

*****************No Batch Split***************
*****************Check entry in custom table using batch from main line item*************

*         Read table for material,Batch,Country and Ship-to
            READ TABLE li_rest_batch TRANSPORTING NO FIELDS
                       WITH KEY matnr = <lfs_lips>-matnr
                                charg = <lfs_lips>-charg
                                land1 = lv_ship_to
                                kunnr = is_likp-kunnr
                                BINARY SEARCH.
            IF sy-subrc IS INITIAL.
*         Populate value of batch from lips
              lv_batch = <lfs_lips>-charg.
            ELSE. " ELSE -> IF sy-subrc IS INITIAL

*         Read table for material,Batch,Country and Sold-to
              READ TABLE li_rest_batch TRANSPORTING NO FIELDS
                   WITH KEY matnr = <lfs_lips>-matnr
                            charg = <lfs_lips>-charg
                            land1 = lv_ship_to
                            kunnr = is_likp-kunag
                            BINARY SEARCH.
              IF sy-subrc IS INITIAL.
*           Populate value of batch from lips
                lv_batch = <lfs_lips>-charg.
              ELSE. " ELSE -> IF sy-subrc IS INITIAL

*           Read table for material,Batch and Ship to
                READ TABLE li_rest_batch TRANSPORTING NO FIELDS
                     WITH KEY matnr = <lfs_lips>-matnr
                              charg = <lfs_lips>-charg
                              land1 = space
                              kunnr = is_likp-kunnr
                              BINARY SEARCH.
                IF sy-subrc IS INITIAL.
*             Populate value of batch from lips
                  lv_batch = <lfs_lips>-charg.
                ELSE. " ELSE -> IF sy-subrc IS INITIAL

*             Read table for material,Batch and Sold to
                  READ TABLE li_rest_batch TRANSPORTING NO FIELDS
                       WITH KEY matnr = <lfs_lips>-matnr
                                charg = <lfs_lips>-charg
                                land1 = space
                                kunnr = is_likp-kunag
                                BINARY SEARCH.
                  IF sy-subrc IS INITIAL.
*               Populate value of batch from lips
                    lv_batch = <lfs_lips>-charg.
                  ELSE. " ELSE -> IF sy-subrc IS INITIAL

*               Read table for material,Batch and Country
                    READ TABLE li_rest_batch TRANSPORTING NO FIELDS
                         WITH KEY matnr = <lfs_lips>-matnr
                                  charg = <lfs_lips>-charg
                                  land1 = lv_ship_to
                                  kunnr = space
                                  BINARY SEARCH.
                    IF sy-subrc IS INITIAL.
*                 Populate value of batch from lips
                      lv_batch = <lfs_lips>-charg.
                    ENDIF. " IF sy-subrc IS INITIAL
                  ENDIF. " IF sy-subrc IS INITIAL
                ENDIF. " IF sy-subrc IS INITIAL
              ENDIF. " IF sy-subrc IS INITIAL
            ENDIF. " IF sy-subrc IS INITIAL
          ENDIF. " IF sy-subrc IS INITIAL

*       Item number moved to local variable to match
*       with GTS item number which is of type Char10
          lv_item_num = <lfs_lips>-posnr.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lv_item_num
            IMPORTING
              output = lv_item_num.

*       Read item transfer table for GTS
          READ TABLE li_gen ASSIGNING <lfs_gen>
                            WITH KEY item_number = lv_item_num
                            BINARY SEARCH.
          IF sy-subrc IS INITIAL.

            IF NOT lv_batch IS INITIAL.
*           Pass value of lips-CHARG to GTS Project_ID
              <lfs_gen>-project_id = lv_batch.
            ELSE. " ELSE -> IF NOT lv_batch IS INITIAL
*           Pass constant Value 'KGB' to GTS Project_ID
              <lfs_gen>-project_id = lv_batch_val.
            ENDIF. " IF NOT lv_batch IS INITIAL

          ENDIF. " IF sy-subrc IS INITIAL

          CLEAR:lv_item_num,
                lv_batch.
        ENDIF. " IF <lfs_lips>-uecha IS INITIAL

      ENDLOOP. " LOOP AT it_lips ASSIGNING <lfs_lips>

*     Modify GTS item data table with batch value.
      REFRESH cs_itm_cdoc-gen.
      cs_itm_cdoc-gen[] = li_gen[].

    ENDIF. " IF lv_del_batch = abap_true

  ENDIF. " IF sy-subrc IS INITIAL

ENDMETHOD.
ENDCLASS.
