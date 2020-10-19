class ZOTC_CL_SO_BATCH_TRANSFER definition
  public
  final
  create public .

public section.

  interfaces /SAPSLL/IF_EX_IFEX_SD0A_R3 .
protected section.
private section.
ENDCLASS.



CLASS ZOTC_CL_SO_BATCH_TRANSFER IMPLEMENTATION.


METHOD /sapsll/if_ex_ifex_sd0a_r3~if_extend_con_cdoc.
***********************************************************************
*Program    : /SAPSLL/IF_EX_IFEX_SD0A_R3~IF_EXTEND_CON_CDOC           *
*Title      : Transfer batch to GTS                                   *
*Developer  : Ayushi Jain                                             *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_EDD_0344                                           *
*---------------------------------------------------------------------*
*Description: BADI is implemented to perform transfer of batch value  *
*             from ECC to GTS for each line item of Sales order.      *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*17-JUN-2016  U033830       E1DK918373     Initial Development
*03-AUG-2016  SBEHERA       E1DK918373     Defect#2932:FUT Issue: Order*
*                           does not transfer batch at item level in  *
*                           create mode(VA01)                         *
*---------------------------------------------------------------------*

* Local type declaration
  TYPES:BEGIN OF lty_batch,
         matnr    TYPE matnr,   " Material Number
         charg    TYPE charg_d, " Batch Number
         land1    TYPE land1,   " Country Key
         kunnr    TYPE kunnr,   " Customer Number
        END OF lty_batch.

* Local variable declaration
  DATA: lv_sold_to    TYPE kunnr,   " Sold to party
        lv_ship_to    TYPE kunnr,   " Ship to party
        lv_ship_cntry TYPE land1,   " Country Key
        lv_batch_val  TYPE charg_d, " Batch value as KGB
        lv_batch      TYPE charg_d, " Batch Number
        lv_item_num   TYPE char10.  " GTS item number

* Local internal table Declaration
  DATA : li_status_table
             TYPE STANDARD TABLE OF zdev_enh_status, " Table for Enhancement status data
         li_rest_batch
             TYPE STANDARD TABLE OF lty_batch,       " Restricted Batch Table
         li_vbap
             TYPE /sapsll/vbapvb_r3_t,               " Sales Document Item
         li_vbpa
             TYPE vbpavb_tab,                        " Partner
         li_gen
             TYPE sllr3_api6800_itm_r3_t.            " SLL: API Comm. Structure: Customs Document: Item

* Local field symbol declaration
  FIELD-SYMBOLS: <lfs_status> TYPE zdev_enh_status,          " Enhancement Status
                 <lfs_vbap>   TYPE vbapvb,                   " Sales Document Item
                 <lfs_vbpa>   TYPE vbpavb,                   " Reference structure for XVBPA/YVBPA
                 <lfs_gen>    TYPE /sapsll/api6800_itm_r3_s. " SLL: API Comm. Structure: Customs Document: Item

* Constant declaration
  CONSTANTS: lc_ship_to   TYPE parvw         VALUE 'WE',           " Ship To
             lc_sold_to   TYPE parvw         VALUE 'AG',           " Sold TO
             lc_posnr_0   TYPE posnr         VALUE '000000',       " Header level item number
             lc_batch_val TYPE z_criteria    VALUE 'BATCH_VAL',    " Enh. Criteria
             lc_null      TYPE z_criteria    VALUE 'NULL',         " Null criteria
             lc_enh_name  TYPE z_enhancement VALUE 'OTC_EDD_0344'. " Enhancement No



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

*   Move sales partner data in local table and sort it
    li_vbpa[] = it_vbpa[].
    SORT li_vbpa BY vbeln
                    posnr
                    parvw.

*   Read VBPA table for partner Sold to party at header level
    UNASSIGN <lfs_vbpa>.
    READ TABLE li_vbpa ASSIGNING <lfs_vbpa>
                       WITH KEY vbeln = is_vbak-vbeln
                                posnr = lc_posnr_0
                                parvw = lc_sold_to
                                BINARY SEARCH.

    IF sy-subrc IS INITIAL.
*     Populate value for Sold to party
      lv_sold_to = <lfs_vbpa>-kunnr.
    ELSE. " ELSE -> IF sy-subrc IS INITIAL
      UNASSIGN <lfs_vbpa>.
      READ TABLE li_vbpa ASSIGNING <lfs_vbpa>
                         WITH KEY posnr = lc_posnr_0
                                  parvw = lc_sold_to
                                  BINARY SEARCH.
      IF sy-subrc IS INITIAL.
*     Populate value for Sold to party
        lv_sold_to = <lfs_vbpa>-kunnr.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL

    li_vbap[] = it_vbap[].
    SORT li_vbap BY matnr
                    charg.
    DELETE ADJACENT DUPLICATES FROM li_vbap COMPARING matnr
                                                      charg.

    IF NOT li_vbap IS INITIAL.
*     Fetch restricted batch data from custom table
      SELECT matnr           " Material Number
             charg           " Batch Number
             land1           " Country Key
             kunnr           " Customer Number
        FROM zotc_rest_batch " Restricted Batch Table
        INTO TABLE li_rest_batch
        FOR ALL ENTRIES IN li_vbap
        WHERE matnr = li_vbap-matnr
          AND charg = li_vbap-charg.
      IF sy-subrc IS INITIAL.
        SORT li_rest_batch BY matnr
                              charg
                              land1
                              kunnr.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF NOT li_vbap IS INITIAL

*   Move GTS item data in local table and sort it
    li_gen[] = cs_itm_cdoc-gen[].
    SORT li_gen BY item_number.

*   Loop at each line item
    UNASSIGN <lfs_vbap>.
    LOOP AT it_vbap ASSIGNING <lfs_vbap>.

*     Read VBPA table for partner Ship to party at item level
      UNASSIGN <lfs_vbpa>.
      READ TABLE li_vbpa ASSIGNING <lfs_vbpa>
                         WITH KEY vbeln = is_vbak-vbeln
                                  posnr = <lfs_vbap>-posnr
                                  parvw = lc_ship_to
                                  BINARY SEARCH.

      IF sy-subrc IS INITIAL.
*       Populate value for Ship to party
        lv_ship_to = <lfs_vbpa>-kunnr.
        lv_ship_cntry = <lfs_vbpa>-land1.
      ELSE. " ELSE -> IF sy-subrc IS INITIAL
*       Read VBPA table for partner Ship to party at header level
        READ TABLE li_vbpa ASSIGNING <lfs_vbpa>
                           WITH KEY vbeln = is_vbak-vbeln
                                    posnr = lc_posnr_0
                                    parvw = lc_ship_to
                                    BINARY SEARCH.

        IF sy-subrc IS INITIAL.
*         Populate value for Ship to party
          lv_ship_to = <lfs_vbpa>-kunnr.
          lv_ship_cntry = <lfs_vbpa>-land1.
* ---> Begin of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
        ELSE. " ELSE -> IF sy-subrc IS INITIAL
*       Read VBPA table for partner Ship to party at item level
          READ TABLE li_vbpa ASSIGNING <lfs_vbpa>
                           WITH KEY vbeln = <lfs_vbap>-vbeln
                                    posnr = lc_posnr_0
                                    parvw = lc_ship_to
                                    BINARY SEARCH.
          IF sy-subrc IS INITIAL.
*         Populate value for Ship to party
            lv_ship_to = <lfs_vbpa>-kunnr.
            lv_ship_cntry = <lfs_vbpa>-land1.
          ENDIF. " IF sy-subrc IS INITIAL
* <--- End of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF sy-subrc IS INITIAL

*     Read table for material,Batch,Country and Ship-to
      READ TABLE li_rest_batch TRANSPORTING NO FIELDS
                 WITH KEY matnr = <lfs_vbap>-matnr
                          charg = <lfs_vbap>-charg
                          land1 = lv_ship_cntry
                          kunnr = lv_ship_to
                          BINARY SEARCH.
      IF sy-subrc IS INITIAL.
*       Populate value of batch from vbap
        lv_batch = <lfs_vbap>-charg.
      ELSE. " ELSE -> IF sy-subrc IS INITIAL

*       Read table for material,Batch,Country and Sold-to
        READ TABLE li_rest_batch TRANSPORTING NO FIELDS
             WITH KEY matnr = <lfs_vbap>-matnr
                      charg = <lfs_vbap>-charg
                      land1 = lv_ship_cntry
                      kunnr = lv_sold_to
                      BINARY SEARCH.
        IF sy-subrc IS INITIAL.
*         Populate value of batch from vbap
          lv_batch = <lfs_vbap>-charg.
        ELSE. " ELSE -> IF sy-subrc IS INITIAL

*         Read table for material,Batch and Ship to
          READ TABLE li_rest_batch TRANSPORTING NO FIELDS
               WITH KEY matnr = <lfs_vbap>-matnr
                        charg = <lfs_vbap>-charg
                        land1 = space
                        kunnr = lv_ship_to
                        BINARY SEARCH.
          IF sy-subrc IS INITIAL.
*           Populate value of batch from vbap
            lv_batch = <lfs_vbap>-charg.
          ELSE. " ELSE -> IF sy-subrc IS INITIAL

*          Read table for material,Batch and Sold to
            READ TABLE li_rest_batch TRANSPORTING NO FIELDS
                 WITH KEY matnr = <lfs_vbap>-matnr
                          charg = <lfs_vbap>-charg
                          land1 = space
                          kunnr = lv_sold_to
                          BINARY SEARCH.
            IF sy-subrc IS INITIAL.
*           Populate value of batch from vbap
              lv_batch = <lfs_vbap>-charg.
            ELSE. " ELSE -> IF sy-subrc IS INITIAL

*           Read table for material,Batch and Country
              READ TABLE li_rest_batch TRANSPORTING NO FIELDS
                   WITH KEY matnr = <lfs_vbap>-matnr
                            charg = <lfs_vbap>-charg
                            land1 = lv_ship_cntry
                            kunnr = space
                            BINARY SEARCH.
              IF sy-subrc IS INITIAL.
*               Populate value of batch from vbap
                lv_batch = <lfs_vbap>-charg.
              ENDIF. " IF sy-subrc IS INITIAL
            ENDIF. " IF sy-subrc IS INITIAL
          ENDIF. " IF sy-subrc IS INITIAL
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF sy-subrc IS INITIAL

*     Item number moved to local variable to match
*     with GTS item number which is of type Char10
      lv_item_num = <lfs_vbap>-posnr.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lv_item_num
        IMPORTING
          output = lv_item_num.

*     Read item transfer table for GTS
      READ TABLE li_gen ASSIGNING <lfs_gen>
                        WITH KEY item_number = lv_item_num
                        BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        IF NOT lv_batch IS INITIAL.
*        Pass value of VBAP-CHARG to GTS Project_ID
          <lfs_gen>-project_id = lv_batch.
        ELSE. " ELSE -> IF NOT lv_batch IS INITIAL
*       Pass constant Value 'KGB' to GTS Project_ID
          <lfs_gen>-project_id = lv_batch_val.
        ENDIF. " IF NOT lv_batch IS INITIAL

      ENDIF. " IF sy-subrc IS INITIAL

      CLEAR:lv_item_num,
            lv_batch.

    ENDLOOP. " LOOP AT it_vbap ASSIGNING <lfs_vbap>

*   Move GTS item data to actual table for transfer.
    REFRESH cs_itm_cdoc-gen.
    cs_itm_cdoc-gen[] = li_gen[].

  ENDIF. " IF sy-subrc IS INITIAL



ENDMETHOD.
ENDCLASS.
