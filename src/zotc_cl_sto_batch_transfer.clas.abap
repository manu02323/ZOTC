class ZOTC_CL_STO_BATCH_TRANSFER definition
  public
  final
  create public .

public section.

  interfaces /SAPSLL/IF_EX_IFEX_MM0A_R3 .
protected section.
private section.
ENDCLASS.



CLASS ZOTC_CL_STO_BATCH_TRANSFER IMPLEMENTATION.


METHOD /sapsll/if_ex_ifex_mm0a_r3~if_extend_con_cdoc.
***********************************************************************
*Program    : /SAPSLL/IF_EX_IFEX_MM0A_R3~IF_EXTEND_CON_CDOC           *
*Title      : Transfer batch to GTS                                   *
*Developer  : Ayushi Jain                                             *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_EDD_0344                                           *
*---------------------------------------------------------------------*
*Description: BADI is implemented to perform transfer of batch value  *
*             from ECC to GTS for each line item of STO.              *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*17-JUN-2016  U033830       E1DK918373     Initial Development
*---------------------------------------------------------------------*

* Local type declaration
  TYPES:BEGIN OF lty_po_type,
        sign   TYPE bapisign,   " Inclusion/exclusion criterion SIGN for range tables
        option TYPE bapioption, " Selection operator OPTION for range tables
        low    TYPE fpb_low,    " From Value
        high   TYPE fpb_high,   " To Value
        END OF lty_po_type,

        BEGIN OF lty_batch,
         matnr TYPE matnr,      " Material Number
         charg TYPE charg_d,    " Batch Number
         land1 TYPE land1,      " Country Key
         kunnr TYPE kunnr,      " Customer Number
        END OF lty_batch.

* Local variable declaration
  DATA: lv_cust      TYPE kunnr,    " Customer Number
        lv_cntry     TYPE land1,    " Country Key
        lv_batch_val TYPE charg_d,  " Batch value as KGB
        lv_batch     TYPE charg_d,  " Batch Number
        lv_enh_active TYPE boolean, " Enh. active flag
        lv_item_num  TYPE char10,   " GTS Item number
        lv_po_type   type fpb_low,
* Local workarea declaration
        lwa_po_type  TYPE lty_po_type. " PO type

* Local internal table Declaration
  DATA : li_status_table
             TYPE STANDARD TABLE OF zdev_enh_status, " Table for Enhancement status data
         li_po_type
             TYPE STANDARD TABLE OF lty_po_type,     " range table for PO type
         li_rest_batch
             TYPE STANDARD TABLE OF lty_batch,       " Restricted Batch Table
         li_ekpo
             TYPE STANDARD TABLE OF bekpo,           " Transfer Structure Items for Purchasing Documents
         li_gen
             TYPE sllr3_api6800_itm_r3_t.            " SLL: API Comm. Structure: Customs Document: Item

* Local field symbol declaration
  FIELD-SYMBOLS: <lfs_status> TYPE zdev_enh_status,          " Enhancement Status
                 <lfs_ekpo>   TYPE bekpo,                    " Transfer Structure Items for Purchasing Documents
                 <lfs_gen>    TYPE /sapsll/api6800_itm_r3_s. " SLL: API Comm. Structure: Customs Document: Item

* Constant declaration
  CONSTANTS: lc_po_type   TYPE z_criteria    VALUE 'STO2EXPORT',   " Enh. Criteria
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
    SORT li_status_table BY criteria.
  ENDIF. " IF sy-subrc IS INITIAL

  LOOP AT li_status_table ASSIGNING <lfs_status>.

    IF <lfs_status>-active   = abap_true.

      CASE <lfs_status>-criteria.

*      Check for null criteria
        WHEN lc_null.
          lv_enh_active = abap_true.

        WHEN lc_batch_val.
*         Populate value for batch as 'KGB'
          lv_batch_val = <lfs_status>-sel_low. " 'KGB'

        WHEN lc_po_type.

*         Populate values for PO Document type
          lwa_po_type-sign = <lfs_status>-sel_sign.
          lwa_po_type-option = <lfs_status>-sel_option.
          lwa_po_type-low = <lfs_status>-sel_low.
          lwa_po_type-high = <lfs_status>-sel_high.
          APPEND lwa_po_type TO li_po_type.
          CLEAR lwa_po_type.

      ENDCASE.

    ENDIF. " IF <lfs_status>-active = abap_true
  ENDLOOP. " LOOP AT li_status_table ASSIGNING <lfs_status>

* If PO type is maintained in ZDEV_EMI and null citeria is passed,
* then only logic for batch transfer to be triggered
  CLEAR lv_po_type.
  CONCATENATE is_ekko-bstyp is_ekko-bsart INTO lv_po_type.
  IF lv_po_type IN li_po_type      "is_ekko-bsart IN li_po_type
    AND lv_enh_active = abap_true.

    li_ekpo[] = it_ekpo[].
    SORT li_ekpo BY matnr
                    charg.
    DELETE ADJACENT DUPLICATES FROM li_ekpo COMPARING matnr
                                                      charg.

    IF NOT li_ekpo IS INITIAL.

*   Fetch restricted batch data from custom table
      SELECT matnr           " Material Number
             charg           " Batch Number
             land1           " Country Key
             kunnr           " Customer Number
        FROM zotc_rest_batch " Restricted Batch Table
        INTO TABLE li_rest_batch
        FOR ALL ENTRIES IN li_ekpo
        WHERE matnr = li_ekpo-matnr
          AND charg = li_ekpo-charg.
      IF sy-subrc IS INITIAL.
        SORT li_rest_batch BY matnr
                              charg
                              land1
                              kunnr.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF NOT li_ekpo IS INITIAL

*   Fetch Ship-to country and customer based on plant
    READ TABLE it_ekpo ASSIGNING <lfs_ekpo> INDEX 1.
    IF sy-subrc IS INITIAL.
      SELECT SINGLE kunnr " Customer number of plant
                    land1 " Country Key
        FROM t001w        " Plants/Branches
        INTO (lv_cust,lv_cntry)
        WHERE werks = <lfs_ekpo>-werks.
      IF sy-subrc IS INITIAL.

      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL

*   Move GTS item data in local table and sort it
    li_gen[] = cs_itm_cdoc-gen[].
    SORT li_gen BY item_number.

*   Loop at each line item
    UNASSIGN <lfs_ekpo>.
    LOOP AT it_ekpo ASSIGNING <lfs_ekpo>.
*     Read table for material,Batch,Country and Customer
      READ TABLE li_rest_batch TRANSPORTING NO FIELDS
                 WITH KEY matnr = <lfs_ekpo>-matnr
                          charg = <lfs_ekpo>-charg
                          land1 = lv_cntry
                          kunnr = lv_cust
                          BINARY SEARCH.
      IF sy-subrc IS INITIAL.
*       Populate value of batch from EKPO
        lv_batch = <lfs_ekpo>-charg.
      ELSE. " ELSE -> IF sy-subrc IS INITIAL

*       Read table for material,Batch and Customer
        READ TABLE li_rest_batch TRANSPORTING NO FIELDS
             WITH KEY matnr = <lfs_ekpo>-matnr
                      charg = <lfs_ekpo>-charg
                      land1 = space
                      kunnr = lv_cust
                      BINARY SEARCH.
        IF sy-subrc IS INITIAL.
*         Populate value of batch from EKPO
          lv_batch = <lfs_ekpo>-charg.
        ELSE. " ELSE -> IF sy-subrc IS INITIAL

*         Read table for material,Batch and Country
          READ TABLE li_rest_batch TRANSPORTING NO FIELDS
               WITH KEY matnr = <lfs_ekpo>-matnr
                        charg = <lfs_ekpo>-charg
                        land1 = lv_cntry
                        kunnr = space
                        BINARY SEARCH.
          IF sy-subrc IS INITIAL.
*         Populate value of batch from EKPO
            lv_batch = <lfs_ekpo>-charg.
          ENDIF. " IF sy-subrc IS INITIAL
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF sy-subrc IS INITIAL

*       Item number moved to local variable to match
*       with GTS item number which is of type Char10
      lv_item_num = <lfs_ekpo>-ebelp.
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
*          Pass value of EKPO-CHARG to GTS
          <lfs_gen>-project_id = lv_batch.
        ELSE. " ELSE -> IF NOT lv_batch IS INITIAL
          <lfs_gen>-project_id = lv_batch_val.
        ENDIF. " IF NOT lv_batch IS INITIAL

      ENDIF. " IF sy-subrc IS INITIAL

      CLEAR: lv_batch,
             lv_item_num.

    ENDLOOP. " LOOP AT it_ekpo ASSIGNING <lfs_ekpo>

*   Modify GTS item data table with batch value.
    REFRESH cs_itm_cdoc-gen.
    cs_itm_cdoc-gen[] = li_gen[].

  ENDIF. " IF is_ekko-bsart IN li_po_type

ENDMETHOD.


method /SAPSLL/IF_EX_IFEX_MM0A_R3~IF_EXTEND_PRE_VDWLI.
endmethod.
ENDCLASS.
