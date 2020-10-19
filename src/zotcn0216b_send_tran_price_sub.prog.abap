*&---------------------------------------------------------------------*
*&  Include           ZOTCN0216B_SEND_TRAN_PRICE_SUB
***********************************************************************
*Program    : ZOTCI0216B_SEND_TRANSFER_PRICE                          *
*Title      : D3_OTC_IDD_0216_SEND TRANSFER PRICE TO EXTERNAL SYSTEM  *
*Developer  : Amlan mohapatra                                         *
*Object type: Report                                                  *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID:  D3_OTC_IDD_0216                                          *
*---------------------------------------------------------------------*
*Description: SEND TRANSEFER PRICE TO EXTERNAL  SYSTEM                *
*                                                                     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport         Description
*=========== ============== ============== ===========================*
*02-NOV-2017   AMOHAPA      E1DK931691        Initial development      *
*22-DEC-2017   AMOHAPA      E1DK931691       FUT_ISSUE: MVKE needs to  *
*                                            be filtered from EMI entry*
*                                            Distribution-chain-specif-*
*                                            ic material status        *
*17-Jan-2018   AMOHAPA      E1DK931691       FUT_ISSUE: File should be *
*                                            uploaded in Pipe delimete-*
*                                            red                       *
*12-FEB-2018   AMOHAPA      E1DK931691       FUT_ISSUE: File Name      *
*                                            should be populated as    *
*                                            IDD_0216_YYYYMMDD_Running *
*                                            number in AL11            *
*21-MAR-2018   AMOHAPA      E1DK931691       FUT_ISSUE:1) Instead of   *
*                                            Net Price, bussiness wants*
*                                            to see Net Value          *
*                                            2)Instead of Pricing unit *
*                                            bussiness wants to see    *
*                                            Bill Quantity             *
*                                            3)Instead of sales unit   *
*                                            Base unit of measurement  *
*                                            should be considered      *
*23-MAR-2018   AMOHAPA      E1DK931691       FUT_ISSUE: Material type  *
*                                            has been added in the     *
*                                            selection screen and      *
*                                            material are filltered    *
*                                            from entries of MARA      *
*18-Apr-2018   AMOHAPA      E1DK931691       Defect#5759: CDPOS-TABKEY *
*                                            entries are different for *
*                                            MBEW and MVKE             *
*                                            So to avoid the difference*
*                                            we have removed TAKEY from*
*                                            selection from CDPOS      *
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_GLOBAL_DATA
*&---------------------------------------------------------------------*
*       Clearing Global Varibales
*----------------------------------------------------------------------*

FORM f_clear_global_data .

 "Before using the global variable clear them

  CLEAR: gv_matnr,
         gv_cdate,
         gv_kondm.
 "Before assigning memory free the Global internal table
  FREE: i_mvke[],
        i_mbew[],
        i_mvke_pt[],
        i_cdpos[],
        i_cdhdr[],
        i_final[],
        i_error[],
        i_listheader[],
        i_status[],
        i_fieldcat[].



ENDFORM. " F_CLEAR_GLOBAL_DATA
*&---------------------------------------------------------------------*
*&      Form  F_SEL_MODIFY
*&---------------------------------------------------------------------*
*       Modify the selection screen
*----------------------------------------------------------------------*

FORM f_sel_modify .

  CONSTANTS:  lc_m1 TYPE group1  VALUE  'M1', " M1 of type CHAR2
              lc_m2 TYPE group1  VALUE  'M2', " M2 of type char2
              lc_0  TYPE char1   VALUE  '0',  " 0 of type CHAR1
              lc_1  TYPE char1   VALUE  '1'.  " 1 of type CHAR1

  LOOP AT SCREEN.

    IF rb_dl IS NOT INITIAL.
      IF screen-group1 = lc_m1.
        screen-input = lc_1.
        screen-invisible = lc_0.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = lc_m1

    ELSEIF rb_fl IS NOT INITIAL.
      IF screen-group1 = lc_m1.
        screen-input = lc_0.
        screen-invisible = lc_1.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = lc_m1

    ENDIF. " IF rb_dl IS NOT INITIAL

    IF rb_alv IS NOT INITIAL.

      IF screen-group1 = lc_m2.
        screen-input = lc_0.
        screen-invisible = lc_1.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = lc_m2

    ELSEIF rb_file IS NOT INITIAL.

      IF screen-group1 = lc_m2.
        screen-input = lc_0.
        screen-invisible = lc_0.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = lc_m2

    ENDIF. " IF rb_alv IS NOT INITIAL

  ENDLOOP. " LOOP AT SCREEN

ENDFORM. " F_SEL_MODIFY
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION_SALES_ORG
*&---------------------------------------------------------------------*
*       Validating Sales Organization
*----------------------------------------------------------------------*

FORM f_validation_sales_org .

  DATA lv_vkorg TYPE vkorg. " Sales Organization

  SELECT  vkorg     " Sales Organization
          FROM tvko " Organizational Unit: Sales Organizations
          INTO lv_vkorg
          UP TO 1 ROWS
          WHERE vkorg = p_vkorg.
  ENDSELECT.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE e047. "Sales Org is not Valid.
  ENDIF. " IF sy-subrc IS NOT INITIAL

  CLEAR lv_vkorg.

ENDFORM. " F_VALIDATION_SALES_ORG
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION_DIST_CHANNEL
*&---------------------------------------------------------------------*
*       Validating Distribution Channel
*----------------------------------------------------------------------*

FORM f_validation_dist_channel.

  DATA lv_vtweg TYPE vtweg. " Distribution Channel

  SELECT  vtweg     " Distribution Channel
          FROM tvtw " Organizational Unit: Distribution Channels
          INTO lv_vtweg
          UP TO 1 ROWS
          WHERE vtweg = p_vtweg.
  ENDSELECT.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE e048. "distribution Channel is not Valid.
  ENDIF. " IF sy-subrc IS NOT INITIAL

  CLEAR lv_vtweg.



ENDFORM. " F_VALIDATION_DIST_CHANNEL
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION_SALES_DIVISION
*&---------------------------------------------------------------------*
*      Validating Division
*----------------------------------------------------------------------*

FORM f_validation_sales_division .

  DATA lv_spart TYPE spart. " Division

  SELECT  spart     " Division
          FROM tspa " Organizational Unit: Sales Divisions
          INTO lv_spart
          UP TO 1 ROWS
          WHERE spart = p_spart.
  ENDSELECT.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE e049.
  ENDIF. " IF sy-subrc IS NOT INITIAL

  CLEAR lv_spart.


ENDFORM. " F_VALIDATION_SALES_DIVISION
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION_CUSTOMER
*&---------------------------------------------------------------------*
*       Validating the Customer
*----------------------------------------------------------------------*

FORM f_validation_customer .

  DATA lv_kunnr TYPE kunag. " Sold-to party

  SELECT  kunnr     " Customer Number
          FROM kna1 " General Data in Customer Master
          INTO lv_kunnr
          UP TO 1 ROWS
          WHERE kunnr = p_kunnr.
  ENDSELECT.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE e930.
  ENDIF. " IF sy-subrc IS NOT INITIAL

  CLEAR lv_kunnr.

ENDFORM. " F_VALIDATION_CUSTOMER
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION_MAT_GROUP
*&---------------------------------------------------------------------*
*       Validating the Material Group
*----------------------------------------------------------------------*

FORM f_validation_mat_group .

  DATA lv_kondm TYPE kondm. " Material Pricing Group

  SELECT  kondm     " Material Pricing Group
          FROM t178 " Conditions: Groups for Materials
          INTO lv_kondm
          UP TO 1 ROWS
          WHERE kondm IN s_kondm[].
  ENDSELECT.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE e897.
  ENDIF. " IF sy-subrc IS NOT INITIAL

  CLEAR lv_kondm.

ENDFORM. " F_VALIDATION_MAT_GROUP
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION_MATERIAL
*&---------------------------------------------------------------------*
*       Validating Material
*----------------------------------------------------------------------*

FORM f_validation_material .

  DATA lv_matnr TYPE matnr. " Material Number

  SELECT  matnr     " Material Number
          FROM mara " General Material Data
          INTO lv_matnr
          UP TO 1 ROWS
          WHERE matnr IN s_matnr[].
  ENDSELECT.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE e272.
  ENDIF. " IF sy-subrc IS NOT INITIAL

  CLEAR lv_matnr.


ENDFORM. " F_VALIDATION_MATERIAL
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_COMBINATION_CUST
*&---------------------------------------------------------------------*
*       Validating Combination For Customer,Sales Organization,
*       Distribution Channel and Division
*----------------------------------------------------------------------*

FORM f_validate_combination_cust.

  TYPES: BEGIN OF lty_knvv,
         kunnr  TYPE kunnr, "Customer Number
         vkorg  TYPE vkorg, "Sales Organization
         vtweg  TYPE vtweg, "Distribution Channel
         spart  TYPE spart, "Division
         END OF lty_knvv.

  DATA li_knvv TYPE STANDARD TABLE OF lty_knvv INITIAL SIZE 0.

  SELECT  kunnr     " Customer Number
          vkorg     " Sales Organization
          vtweg     " Distribution Channel
          spart     " Division
          FROM knvv " Customer Master Sales Data
          INTO TABLE li_knvv
          WHERE kunnr = p_kunnr
          AND   vkorg = p_vkorg
          AND   vtweg = p_vtweg
          AND   spart = p_spart.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE i896. "Invalid Customer,Sales.Org ,Dist.Channel and Division
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS NOT INITIAL

  FREE li_knvv[].

ENDFORM. " F_VALIDATE_COMBINATION_CUST
*&---------------------------------------------------------------------*
*&      Form  F_GET_RECORDS_MVKE
*&---------------------------------------------------------------------*
*       Fetching Records from MVKE
*----------------------------------------------------------------------*
*  -->  FP_I_VMSTA       Internal table for VMSTA
*  <--  FP_I_MVKE        Internal table for MVKE
*  <--  FP_I_MBEW        Internal table for MBEW
*  <--  FP_I_MVKE_PT     Internal table for MVKE
*----------------------------------------------------------------------*
FORM f_get_records_mvke
*-->Begin of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
                          USING   fp_i_vmsta       TYPE ty_t_vmsta " Distribution-chain-specific material status
*<--End of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
                         CHANGING fp_i_mvke        TYPE ty_t_mvke
                                  fp_i_mbew        TYPE ty_t_mbew
                                  fp_i_mvke_pt     TYPE ty_t_mvke_pt.



  DATA: li_mvke_temp TYPE STANDARD TABLE OF ty_mvke INITIAL SIZE 0, "Local internal table for MVKE
        lwa_mvke     TYPE ty_mvke_pt.

  FIELD-SYMBOLS: <lfs_mvke> TYPE ty_mvke.
*-->Begin of Insert for D3_OTC_IDD_0216_R2_FUT_Issue by AMOHAPA on 23-Mar-2018

  TYPES: BEGIN OF lty_mara,
         matnr  TYPE matnr, " Material Number
         mtart  TYPE mtart, " Material Type
         END OF lty_mara.

  DATA: li_mara TYPE STANDARD TABLE OF lty_mara INITIAL SIZE 0,
        li_mvke TYPE STANDARD TABLE OF ty_mvke  INITIAL SIZE 0.

*<--End of Insert for D3_OTC_IDD_0216_R2_FUT_Issue by AMOHAPA on 23-Mar-2018


  SELECT matnr " Material Number
         vkorg " Sales Organization
         vtweg " Distribution Channel
*-->Begin of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
         vmsta " Distribution-chain-specific material status
*<--End of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
         dwerk     " Delivering Plant (Own or External)
         kondm     " Material Pricing Group
         FROM mvke " Sales Data for Material
         INTO TABLE fp_i_mvke
         WHERE matnr IN s_matnr[]
         AND   vkorg = p_vkorg
         AND   vtweg = p_vtweg.

  IF sy-subrc IS INITIAL.

 "Filttering MVKE if material group is entered in the selection screen
    IF s_kondm[] IS NOT INITIAL.
      DELETE fp_i_mvke WHERE kondm NOT IN s_kondm[].
    ENDIF. " IF s_kondm[] IS NOT INITIAL

*-->Begin of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
    IF fp_i_vmsta[] IS NOT INITIAL.
      DELETE fp_i_mvke WHERE vmsta NOT IN fp_i_vmsta[].
    ENDIF. " IF fp_i_vmsta[] IS NOT INITIAL
*<--End of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017

*-->Begin of Insert for D3_OTC_IDD_0216_R2_FUT_Issue by AMOHAPA on 23-Mar-2018
 "If material type is given in the selection screen then we have to filter it from MARA
    IF s_mtart[] IS NOT INITIAL.

      li_mvke[] = fp_i_mvke[].
      SORT li_mvke BY matnr.
      DELETE ADJACENT DUPLICATES FROM li_mvke COMPARING matnr.

      SELECT matnr     " Material Number
             mtart     " Material Type
             FROM mara " General Material Data
             INTO TABLE li_mara
             FOR ALL ENTRIES IN li_mvke
             WHERE matnr = li_mvke-matnr
             AND   mtart IN s_mtart[].
      IF sy-subrc IS INITIAL.
        LOOP AT fp_i_mvke ASSIGNING <lfs_mvke>.
          READ TABLE li_mara TRANSPORTING NO FIELDS
                             WITH KEY matnr = <lfs_mvke>-matnr.
          IF sy-subrc IS NOT INITIAL.
            DELETE TABLE fp_i_mvke FROM <lfs_mvke>.
          ENDIF. " IF sy-subrc IS NOT INITIAL

        ENDLOOP. " LOOP AT fp_i_mvke ASSIGNING <lfs_mvke>
      ELSE. " ELSE -> IF sy-subrc IS INITIAL
        MESSAGE i892.
        LEAVE LIST-PROCESSING.
      ENDIF. " IF sy-subrc IS INITIAL

      IF <lfs_mvke> IS ASSIGNED.
        UNASSIGN <lfs_mvke>.
      ENDIF. " IF <lfs_mvke> IS ASSIGNED
      FREE: li_mvke,
            li_mara.

    ENDIF. " IF s_mtart[] IS NOT INITIAL

*<--End of Insert for D3_OTC_IDD_0216_R2_FUT_Issue by AMOHAPA on 23-Mar-2018



 "Filtering the records which don't have entry in MBEW ,
 "it means for them costing has not been done

    IF fp_i_mvke[] IS NOT INITIAL.

      li_mvke_temp[] = fp_i_mvke[].

 "We are deleteing the records where Plant is initial
 "also we are taking all the records from MVKE into one
 "internal table where Plant is taken as first field

      LOOP AT li_mvke_temp ASSIGNING <lfs_mvke>.

        lwa_mvke-matnr = <lfs_mvke>-matnr.
        lwa_mvke-vkorg = <lfs_mvke>-vkorg.
        lwa_mvke-vtweg = <lfs_mvke>-vtweg.
        lwa_mvke-dwerk = <lfs_mvke>-dwerk.
        lwa_mvke-kondm = <lfs_mvke>-kondm.

        APPEND lwa_mvke TO fp_i_mvke_pt.
        CLEAR  lwa_mvke.


        IF <lfs_mvke>-dwerk IS INITIAL.
          DELETE TABLE li_mvke_temp FROM <lfs_mvke>.
        ENDIF. " IF <lfs_mvke>-dwerk IS INITIAL

      ENDLOOP. " LOOP AT li_mvke_temp ASSIGNING <lfs_mvke>
 "Sort the table FP_I_MVKE_PT with Plant to use in AT END OF statement

      IF fp_i_mvke_pt IS NOT INITIAL.
        SORT fp_i_mvke_pt BY dwerk.
      ENDIF. " IF fp_i_mvke_pt IS NOT INITIAL

      IF <lfs_mvke> IS ASSIGNED.
        UNASSIGN <lfs_mvke>.
      ENDIF. " IF <lfs_mvke> IS ASSIGNED

      IF li_mvke_temp IS NOT INITIAL.

        SORT li_mvke_temp BY matnr dwerk.
        DELETE ADJACENT DUPLICATES FROM li_mvke_temp COMPARING matnr dwerk.

        SELECT matnr     " Material Number
               bwkey     " Valuation Area
               FROM mbew " Material Valuation
               INTO TABLE fp_i_mbew
               FOR ALL ENTRIES IN li_mvke_temp
               WHERE matnr = li_mvke_temp-matnr
               AND   bwkey = li_mvke_temp-dwerk.

        IF sy-subrc IS INITIAL.
          SORT fp_i_mbew BY matnr bwkey.
        ENDIF. " IF sy-subrc IS INITIAL

        FREE li_mvke_temp[].

      ENDIF. " IF li_mvke_temp IS NOT INITIAL

    ENDIF. " IF fp_i_mvke[] IS NOT INITIAL

  ELSE. " ELSE -> IF sy-subrc IS INITIAL
 "If there is no records found in MVKE then the program
 "should not execute more steps
    MESSAGE i138.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS INITIAL

ENDFORM. " F_GET_RECORDS_MVKE
*&---------------------------------------------------------------------*
*&      Form  F_SEND_TO_SDNETPRO
*&---------------------------------------------------------------------*
*      Populating the Final Output Table
*----------------------------------------------------------------------*
*  -->  FP_I_MVKE_PT    Internal table for MVKE
*  -->  FP_I_STATUS     Internal table for EMI entry
*  -->  FP_I_MBEW       Internal table for MBEW
*  <--  FP_I_FINAL      Internal table for Final Output
*----------------------------------------------------------------------*
FORM f_send_to_sdnetpro USING    fp_i_mvke_pt    TYPE ty_t_mvke_pt
                                 fp_i_status     TYPE ty_t_status
                                 fp_i_mbew       TYPE ty_t_mbew
                        CHANGING fp_i_final      TYPE ty_t_final.

  DATA: lwa_mvke       TYPE ty_mvke_pt,                 "Local workarea for MVKE
        lwa_mbew       TYPE ty_mbew,                    "Local workarea for MBEW
        lwa_mvke_temp  TYPE ty_mvke_pt,                 "Local workarea for MVKE
        li_seltab      TYPE STANDARD TABLE OF rsparams, " ABAP: General Structure for PARAMETERS and SELECT-OPTIONS
        lwa_seltab     TYPE rsparams,                   " ABAP: General Structure for PARAMETERS and SELECT-OPTIONS
        lv_kunnr       TYPE kunag,                      " Sold-to party
        lv_date        TYPE sydatum,                    " Current Date of Application Server
        lwa_final      TYPE ty_final,                   " Local workarea for Final tabel
        lwa_status     TYPE zdev_enh_status,            " Enhancement Status
        lv_zppm        TYPE kschl,                      " Condition Type
"Loop counter BOC
        lv_counter     TYPE i,                          " Counter of type Integers
        lv_remainder   TYPE i,                          " Remainder of type Integers
        lv_records     TYPE i.                          " Number of Records process at a time


  CONSTANTS: lc_bill_type TYPE fkara VALUE 'FX',
             lc_ord_type  TYPE auart VALUE 'OR',
             lc_itm_cat   TYPE pstyv VALUE 'TAN',                  " Sales document item category
"Constant to populate traffic light
             lc_red       TYPE char4 VALUE '@0A@',                 " Red of type CHAR4
"Constant for EMI criteria
             lc_condition  TYPE z_criteria VALUE 'CONDITION_TYPE', " Enh. Criteria
             lc_records    TYPE z_criteria VALUE 'RECORDS',        " Enh. Criteria

"Local constant declaration for Selection Table population
             lc_kind_p    TYPE rsscr_kind VALUE 'P',               " ABAP: Type of selection
             lc_kind_s    TYPE rsscr_kind VALUE 'S',               " ABAP: Type of selection
             lc_sign      TYPE tvarv_sign VALUE 'I',               " ABAP: ID: I/E (include/exclude values)
             lc_option    TYPE tvarv_opti VALUE 'EQ',              " ABAP: Selection option (EQ/BT/CP/...)
             lc_vkorg     TYPE rsscr_name VALUE 'P_VKORG',         " ABAP/4: Name of SELECT-OPTION / PARAMETER
             lc_vtweg     TYPE rsscr_name VALUE 'P_VTWEG',         " ABAP/4: Name of SELECT-OPTION / PARAMETER
             lc_spart     TYPE rsscr_name VALUE 'P_SPART',         " ABAP/4: Name of SELECT-OPTION / PARAMETER
             lc_kunnr     TYPE rsscr_name VALUE 'P_KUNNR',         " ABAP/4: Name of SELECT-OPTION / PARAMETER
             lc_werks     TYPE rsscr_name VALUE 'P_WERKS',         " ABAP/4: Name of SELECT-OPTION / PARAMETER
             lc_matnr     TYPE rsscr_name VALUE 'S_MATNR',         " ABAP/4: Name of SELECT-OPTION / PARAMETER
             lc_fkdat     TYPE rsscr_name VALUE 'P_FKDAT',         " ABAP/4: Name of SELECT-OPTION / PARAMETER
             lc_fkara     TYPE rsscr_name VALUE 'P_FKARA',         " ABAP/4: Name of SELECT-OPTION / PARAMETER
             lc_auart     TYPE rsscr_name VALUE 'P_AUART',         " ABAP/4: Name of SELECT-OPTION / PARAMETER
             lc_pstyv     TYPE rsscr_name VALUE 'P_PSTYV',         " ABAP/4: Name of SELECT-OPTION / PARAMETER
             lc_division  TYPE tvarv_val  VALUE '00'.              " ABAP/4: Selection value (LOW or HIGH value, external format)

 "Taking value for condition type from EMI entry

  READ TABLE fp_i_status INTO lwa_status WITH KEY criteria = lc_condition
                                                  BINARY SEARCH.
  IF sy-subrc IS INITIAL.

    lv_zppm = lwa_status-sel_low.

  ENDIF. " IF sy-subrc IS INITIAL

  CLEAR lwa_status.

 "Taking value for Number of Records to be processed at a time

  READ TABLE fp_i_status INTO lwa_status WITH KEY criteria = lc_records
                                                 BINARY SEARCH.
  IF sy-subrc IS INITIAL.

    lv_records = lwa_status-sel_low.

  ENDIF. " IF sy-subrc IS INITIAL

  CLEAR lwa_status.


  lv_kunnr = p_kunnr.

  lv_date = sy-datum.

  LOOP AT fp_i_mvke_pt INTO lwa_mvke_temp.

    lwa_mvke = lwa_mvke_temp.
 "If plant is maintained
    IF lwa_mvke-dwerk IS NOT INITIAL.
 "If delta load is clicked
      IF rb_dl IS NOT INITIAL.

        lv_counter = lv_counter + 1.


        IF lwa_mvke-matnr IS NOT INITIAL.

          CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
            EXPORTING
              input  = lwa_mvke-matnr
            IMPORTING
              output = lwa_mvke-matnr.

        ENDIF. " IF lwa_mvke-matnr IS NOT INITIAL


        lwa_seltab-selname = lc_matnr.
        lwa_seltab-kind    = lc_kind_s.
        lwa_seltab-sign    = lc_sign.
        lwa_seltab-option  = lc_option.
        lwa_seltab-low     = lwa_mvke-matnr.

        APPEND lwa_seltab TO li_seltab.
        CLEAR lwa_seltab.


 "When it reaches multiple of 5000 records submit program will be done

        lv_remainder = lv_counter MOD lv_records.

        IF  lv_remainder  IS INITIAL.

          IF li_seltab[] IS NOT INITIAL.

            lwa_seltab-selname = lc_vkorg.
            lwa_seltab-kind    = lc_kind_p.
            lwa_seltab-sign    = lc_sign.
            lwa_seltab-option  = lc_option.
            lwa_seltab-low     = lwa_mvke-vkorg.

            APPEND lwa_seltab TO li_seltab.
            CLEAR: lwa_seltab-selname,
                   lwa_seltab-low.


            lwa_seltab-selname = lc_vtweg.
            lwa_seltab-low     = lwa_mvke-vtweg.

            APPEND lwa_seltab TO li_seltab.
            CLEAR: lwa_seltab-selname,
                  lwa_seltab-low.

            lwa_seltab-selname = lc_spart.
            lwa_seltab-low     = lc_division.

            APPEND lwa_seltab TO li_seltab.
            CLEAR: lwa_seltab-selname,
                   lwa_seltab-low.

            lwa_seltab-selname = lc_kunnr.
            lwa_seltab-low     = lv_kunnr.

            APPEND lwa_seltab TO li_seltab.
            CLEAR: lwa_seltab-selname,
                  lwa_seltab-low.

            lwa_seltab-selname = lc_werks.
            lwa_seltab-low     = lwa_mvke-dwerk.

            APPEND lwa_seltab TO li_seltab.
            CLEAR: lwa_seltab-selname,
                  lwa_seltab-low.

            lwa_seltab-selname = lc_fkdat.
            lwa_seltab-low     = lv_date.

            APPEND lwa_seltab TO li_seltab.
            CLEAR: lwa_seltab-selname,
                  lwa_seltab-low.

            lwa_seltab-selname = lc_fkara.
            lwa_seltab-low     = lc_bill_type.

            APPEND lwa_seltab TO li_seltab.
            CLEAR: lwa_seltab-selname,
                  lwa_seltab-low.

            lwa_seltab-selname = lc_auart.
            lwa_seltab-low     = lc_ord_type.

            APPEND lwa_seltab TO li_seltab.
            CLEAR: lwa_seltab-selname,
                  lwa_seltab-low.

            lwa_seltab-selname = lc_pstyv.
            lwa_seltab-low     = lc_itm_cat.

            APPEND lwa_seltab TO li_seltab.
            CLEAR lwa_seltab.


 "Submitting the program and taking the output into final internal table

            PERFORM f_get_final_from_submit USING    lv_zppm
                                            CHANGING li_seltab
                                                     fp_i_final.

          ENDIF. " IF li_seltab[] IS NOT INITIAL

          FREE li_seltab[].

          CLEAR lv_counter.

        ENDIF. " IF lv_remainder IS INITIAL

        CLEAR lv_remainder.

* "At New plant also we have to submit the program with the selection field entries

        AT END OF dwerk.

          IF li_seltab[] IS NOT INITIAL.

            lwa_seltab-selname = lc_vkorg.
            lwa_seltab-kind    = lc_kind_p.
            lwa_seltab-sign    = lc_sign.
            lwa_seltab-option  = lc_option.
            lwa_seltab-low     = lwa_mvke-vkorg.

            APPEND lwa_seltab TO li_seltab.
            CLEAR: lwa_seltab-selname,
                   lwa_seltab-low.


            lwa_seltab-selname = lc_vtweg.
            lwa_seltab-low     = lwa_mvke-vtweg.

            APPEND lwa_seltab TO li_seltab.
            CLEAR: lwa_seltab-selname,
                  lwa_seltab-low.

            lwa_seltab-selname = lc_spart.
            lwa_seltab-low     = lc_division.

            APPEND lwa_seltab TO li_seltab.
            CLEAR: lwa_seltab-selname,
                   lwa_seltab-low.

            lwa_seltab-selname = lc_kunnr.
            lwa_seltab-low     = lv_kunnr.

            APPEND lwa_seltab TO li_seltab.
            CLEAR: lwa_seltab-selname,
                  lwa_seltab-low.

            lwa_seltab-selname = lc_werks.
            lwa_seltab-low     = lwa_mvke-dwerk.

            APPEND lwa_seltab TO li_seltab.
            CLEAR: lwa_seltab-selname,
                  lwa_seltab-low.

            lwa_seltab-selname = lc_fkdat.
            lwa_seltab-low     = lv_date.

            APPEND lwa_seltab TO li_seltab.
            CLEAR: lwa_seltab-selname,
                  lwa_seltab-low.

            lwa_seltab-selname = lc_fkara.
            lwa_seltab-low     = lc_bill_type.

            APPEND lwa_seltab TO li_seltab.
            CLEAR: lwa_seltab-selname,
                  lwa_seltab-low.

            lwa_seltab-selname = lc_auart.
            lwa_seltab-low     = lc_ord_type.

            APPEND lwa_seltab TO li_seltab.
            CLEAR: lwa_seltab-selname,
                  lwa_seltab-low.

            lwa_seltab-selname = lc_pstyv.
            lwa_seltab-low     = lc_itm_cat.

            APPEND lwa_seltab TO li_seltab.
            CLEAR lwa_seltab.


 "Submitting the program and taking the output into final internal table

            PERFORM f_get_final_from_submit USING    lv_zppm
                                            CHANGING li_seltab
                                                     fp_i_final.

            FREE li_seltab[].

            CLEAR lv_counter.

          ENDIF. " IF li_seltab[] IS NOT INITIAL

        ENDAT.

      ELSEIF rb_fl IS NOT INITIAL.

        READ TABLE fp_i_mbew INTO lwa_mbew WITH KEY matnr = lwa_mvke-matnr
                                                    bwkey = lwa_mvke-dwerk
                                                    BINARY SEARCH.

        IF sy-subrc IS INITIAL.

          lv_counter = lv_counter + 1.


          IF lwa_mvke-matnr IS NOT INITIAL.

            CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
              EXPORTING
                input  = lwa_mvke-matnr
              IMPORTING
                output = lwa_mvke-matnr.

          ENDIF. " IF lwa_mvke-matnr IS NOT INITIAL



          lwa_seltab-selname = lc_matnr.
          lwa_seltab-kind    = lc_kind_s.
          lwa_seltab-sign    = lc_sign.
          lwa_seltab-option  = lc_option.
          lwa_seltab-low     = lwa_mvke-matnr.

          APPEND lwa_seltab TO li_seltab.
          CLEAR lwa_seltab.

 "When it reaches multiple of 5000 records submit program will be done

          lv_remainder = lv_counter MOD lv_records.

          IF  lv_remainder  IS INITIAL.

            IF li_seltab[] IS NOT INITIAL.

              lwa_seltab-selname = lc_vkorg.
              lwa_seltab-kind    = lc_kind_p.
              lwa_seltab-sign    = lc_sign.
              lwa_seltab-option  = lc_option.
              lwa_seltab-low     = lwa_mvke-vkorg.

              APPEND lwa_seltab TO li_seltab.
              CLEAR: lwa_seltab-selname,
                     lwa_seltab-low.


              lwa_seltab-selname = lc_vtweg.
              lwa_seltab-low     = lwa_mvke-vtweg.

              APPEND lwa_seltab TO li_seltab.
              CLEAR: lwa_seltab-selname,
                    lwa_seltab-low.

              lwa_seltab-selname = lc_spart.
              lwa_seltab-low     = lc_division.

              APPEND lwa_seltab TO li_seltab.
              CLEAR: lwa_seltab-selname,
                     lwa_seltab-low.

              lwa_seltab-selname = lc_kunnr.
              lwa_seltab-low     = lv_kunnr.

              APPEND lwa_seltab TO li_seltab.
              CLEAR: lwa_seltab-selname,
                    lwa_seltab-low.

              lwa_seltab-selname = lc_werks.
              lwa_seltab-low     = lwa_mvke-dwerk.

              APPEND lwa_seltab TO li_seltab.
              CLEAR: lwa_seltab-selname,
                    lwa_seltab-low.

              lwa_seltab-selname = lc_fkdat.
              lwa_seltab-low     = lv_date.

              APPEND lwa_seltab TO li_seltab.
              CLEAR: lwa_seltab-selname,
                    lwa_seltab-low.

              lwa_seltab-selname = lc_fkara.
              lwa_seltab-low     = lc_bill_type.

              APPEND lwa_seltab TO li_seltab.
              CLEAR: lwa_seltab-selname,
                    lwa_seltab-low.

              lwa_seltab-selname = lc_auart.
              lwa_seltab-low     = lc_ord_type.

              APPEND lwa_seltab TO li_seltab.
              CLEAR: lwa_seltab-selname,
                    lwa_seltab-low.

              lwa_seltab-selname = lc_pstyv.
              lwa_seltab-low     = lc_itm_cat.

              APPEND lwa_seltab TO li_seltab.
              CLEAR lwa_seltab.
 "Submitting the program and taking the output into final internal table

              PERFORM f_get_final_from_submit USING    lv_zppm
                                              CHANGING li_seltab
                                                       fp_i_final.

            ENDIF. " IF li_seltab[] IS NOT INITIAL

            FREE li_seltab[].

            CLEAR lv_counter.

          ENDIF. " IF lv_remainder IS INITIAL

          CLEAR lv_remainder.

* "At New plant also we have to submit the program with the selection field entries

          AT END OF dwerk.

            IF li_seltab[] IS NOT INITIAL.

              lwa_seltab-selname = lc_vkorg.
              lwa_seltab-kind    = lc_kind_p.
              lwa_seltab-sign    = lc_sign.
              lwa_seltab-option  = lc_option.
              lwa_seltab-low     = lwa_mvke-vkorg.

              APPEND lwa_seltab TO li_seltab.
              CLEAR: lwa_seltab-selname,
                     lwa_seltab-low.


              lwa_seltab-selname = lc_vtweg.
              lwa_seltab-low     = lwa_mvke-vtweg.

              APPEND lwa_seltab TO li_seltab.
              CLEAR: lwa_seltab-selname,
                    lwa_seltab-low.

              lwa_seltab-selname = lc_spart.
              lwa_seltab-low     = lc_division.

              APPEND lwa_seltab TO li_seltab.
              CLEAR: lwa_seltab-selname,
                     lwa_seltab-low.

              lwa_seltab-selname = lc_kunnr.
              lwa_seltab-low     = lv_kunnr.

              APPEND lwa_seltab TO li_seltab.
              CLEAR: lwa_seltab-selname,
                    lwa_seltab-low.

              lwa_seltab-selname = lc_werks.
              lwa_seltab-low     = lwa_mvke-dwerk.

              APPEND lwa_seltab TO li_seltab.
              CLEAR: lwa_seltab-selname,
                    lwa_seltab-low.

              lwa_seltab-selname = lc_fkdat.
              lwa_seltab-low     = lv_date.

              APPEND lwa_seltab TO li_seltab.
              CLEAR: lwa_seltab-selname,
                    lwa_seltab-low.

              lwa_seltab-selname = lc_fkara.
              lwa_seltab-low     = lc_bill_type.

              APPEND lwa_seltab TO li_seltab.
              CLEAR: lwa_seltab-selname,
                    lwa_seltab-low.

              lwa_seltab-selname = lc_auart.
              lwa_seltab-low     = lc_ord_type.

              APPEND lwa_seltab TO li_seltab.
              CLEAR: lwa_seltab-selname,
                    lwa_seltab-low.

              lwa_seltab-selname = lc_pstyv.
              lwa_seltab-low     = lc_itm_cat.

              APPEND lwa_seltab TO li_seltab.
              CLEAR lwa_seltab.
 "Submitting the program and taking the output into final internal table

              PERFORM f_get_final_from_submit USING    lv_zppm
                                              CHANGING li_seltab
                                                       fp_i_final.

              FREE li_seltab[].

              CLEAR lv_counter.

            ENDIF. " IF li_seltab[] IS NOT INITIAL

          ENDAT.

        ELSE. " ELSE -> IF sy-subrc IS INITIAL

          lwa_final-icon  =  lc_red.
          lwa_final-matnr =  lwa_mvke-matnr.
          lwa_final-vkorg =  lwa_mvke-vkorg.
          lwa_final-vtweg =  lwa_mvke-vtweg.
          lwa_final-error = 'Record does not have entry in MBEW'(023).

          APPEND lwa_final TO fp_i_final.
          CLEAR lwa_final.



        ENDIF. " IF sy-subrc IS INITIAL


      ENDIF. " IF rb_dl IS NOT INITIAL


    ELSE. " ELSE -> IF lwa_mvke-dwerk IS NOT INITIAL

 "Taking the record to final table to display in Foreground mode
      lwa_final-icon  = lc_red.
      lwa_final-matnr = lwa_mvke-matnr.
      lwa_final-vkorg = lwa_mvke-vkorg.
      lwa_final-vtweg = lwa_mvke-vtweg.
      lwa_final-error = 'Plant is not maintained in MVKE Table'(022).

      APPEND lwa_final TO fp_i_final.
      CLEAR: lwa_final.

    ENDIF. " IF lwa_mvke-dwerk IS NOT INITIAL

    CLEAR: lwa_mvke,
           lwa_mvke_temp.

  ENDLOOP. " LOOP AT fp_i_mvke_pt INTO lwa_mvke_temp

  CLEAR: lv_date,
         lv_kunnr,
         lv_records,
         lv_zppm.

ENDFORM. " F_SEND_TO_SDNETPRO
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_FIELDCAT
*&---------------------------------------------------------------------*
*       Preparing the Field Catalog
*----------------------------------------------------------------------*
*      <--FP_I_FIELDCAT[]  Internal table for Field Catalog
*----------------------------------------------------------------------*
FORM f_prepare_fieldcat  CHANGING fp_i_fieldcat TYPE slis_t_fieldcat_alv.

  PERFORM f_populate_fieldcat USING:
        'ICON'  'I_FINAL' 'Status'(021)               space space  space  space  c_10  CHANGING fp_i_fieldcat,
        'KSCHL' 'I_FINAL' 'Condition Type'(004)       space space  space  space  c_16  CHANGING fp_i_fieldcat,
        'VKORG' 'I_FINAL' 'Sales Organization'(005)   space space  space  space  c_16  CHANGING fp_i_fieldcat,
        'VTWEG' 'I_FINAL' 'Distribution Channel'(006) space space  space  space  c_16  CHANGING fp_i_fieldcat,
        'KUNNR' 'I_FINAL' 'Sold To Party'(007)        space space  space  space  c_16  CHANGING fp_i_fieldcat,
*--> Begin of Delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by SMUKHER4 on 03-Jul-2018
*&--Below code is commented as it was giving dump
*        'WAERK' 'I_FINAL' 'Currency'(008)             space space 'WAERS' 'MSEG'  c_16  CHANGING fp_i_fieldcat,
*<-- End of Delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by SMUKHER4 on 03-Jul-2018

*--> Begin of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by SMUKHER4 on 03-Jul-2018
        'WAERK' 'I_FINAL' 'Currency'(008)             'WAERS' 'MSEG' space space  c_16  CHANGING fp_i_fieldcat,
*<-- End of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by SMUKHER4 on 03-Jul-2018

        'MATNR' 'I_FINAL' 'Material'(009)             space space  space  space  c_16  CHANGING fp_i_fieldcat,
*--> Begin of delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
"Instead of Net Price bussiness want to see Net Value
*        'NETPR' 'I_FINAL' 'Net Price'(010)            space space 'MEINS' 'MSEG' c_16  CHANGING fp_i_fieldcat,
*        'KPEIN' 'I_FINAL' 'Pricing Unit'(011)         space space  space  space  c_16  CHANGING fp_i_fieldcat,
*<-- End of delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
*--> Begin of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
         'NETWR' 'I_FINAL' 'Net Value'(026)           space space  'MEINS' 'MSEG' c_16  CHANGING fp_i_fieldcat,
         'FKIMG' 'I_FINAL' 'Bill.qty'(027)            space space   space   space c_16  CHANGING fp_i_fieldcat,
*<-- End of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
        'KMEIN' 'I_FINAL' 'Unit Of Measure'(012)      space space  space  space  c_16  CHANGING fp_i_fieldcat,
        'DATAB' 'I_FINAL' 'Effective From Date'(013)  space space  space  space  c_16  CHANGING fp_i_fieldcat,
        'DATBI' 'I_FINAL' 'Effective To Date'(014)    space space  space  space  c_16  CHANGING fp_i_fieldcat,
        'ERROR' 'I_FINAL' 'Error Condition'(025)      space space  space  space  c_30  CHANGING fp_i_fieldcat.

ENDFORM. " F_PREPARE_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_FIELDCAT
*&---------------------------------------------------------------------*
*       Populating the Field Catalog
*----------------------------------------------------------------------*
*      -->FP_FNAM     Fieldname
*      -->FP_ITAB     Table name
*      -->FP_DESCR    Description of the field
*      -->FP_QFIELDNAME  Quantity Field Name
*      -->FP_QTABNAME    Quantity Table Name
*      -->FP_CFIELDNAME  Currency Field Name
*      -->FP_CTABNAME    Currency Table Name
*      <--FP_I_FIELDCAT  Final Field catalog
*----------------------------------------------------------------------*
FORM f_populate_fieldcat  USING    fp_fnam       TYPE slis_fieldname       "fieldname
                                   fp_itab       TYPE slis_tabname         "table name
                                   fp_descr      TYPE scrtext_l            "field description
                                   fp_qfieldname TYPE slis_fieldname       "Reference field name
                                   fp_qtabname   TYPE slis_fieldname       "Reference table name
                                   fp_cfieldname TYPE slis_fieldname       " field with currency unit
                                   fp_ctabname   TYPE slis_tabname         " and table
                                   fp_outputlen  TYPE outputlen            " Output Length
                          CHANGING fp_i_fieldcat TYPE slis_t_fieldcat_alv. "Internal Table for Field Catalog

  DATA  lwa_fcat TYPE slis_fieldcat_alv. "work area for fieldcatalog

  STATICS lv_fpos TYPE sycucol. " Horizontal Cursor Position at PAI

  CLEAR lwa_fcat.
  lv_fpos = lv_fpos + 1.

  lwa_fcat-col_pos       = lv_fpos.
  lwa_fcat-fieldname     = fp_fnam.
  lwa_fcat-tabname       = fp_itab.
  lwa_fcat-seltext_l     = fp_descr.
  lwa_fcat-qfieldname    = fp_qfieldname.
  lwa_fcat-qtabname      = fp_qtabname.
  lwa_fcat-cfieldname    = fp_cfieldname.
  lwa_fcat-ctabname      = fp_ctabname.
  lwa_fcat-outputlen     = fp_outputlen.


  APPEND lwa_fcat TO fp_i_fieldcat. "fp_i_fieldcat.
  CLEAR lwa_fcat.

ENDFORM. " F_POPULATE_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*       Displaying Final Internal Table
*----------------------------------------------------------------------*
*      -->FP_I_FIELDCAT[]   Internal table for Field Catalog
*      -->FP_I_FINAL[]      Internal table for Final Table
*----------------------------------------------------------------------*
FORM f_display_alv  USING    fp_i_fieldcat TYPE slis_t_fieldcat_alv "Internal Table for Field Catalog
                             fp_i_final    TYPE ty_t_final.

  PERFORM f_top_header.

  DATA: lwa_layo   TYPE slis_layout_alv. "work area


  CONSTANTS:  lc_a TYPE char1 VALUE 'A',                               " A
              lc_top_page    TYPE slis_formname VALUE 'F_TOP_OF_PAGE'. "top of page



  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = sy-repid
      i_callback_top_of_page = lc_top_page " TOP-OF-PAGE
      is_layout              = lwa_layo
      it_fieldcat            = fp_i_fieldcat
      i_save                 = lc_a
    TABLES
      t_outtab               = fp_i_final
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.
  IF sy-subrc <> 0.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc <> 0

ENDFORM. " F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*&      Form  F_TOP_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_top_header .

  CONSTANTS: lc_typ_h       TYPE char1 VALUE 'H', "H
             lc_typ_s       TYPE char1 VALUE 'S'. "S

  TYPES: ty_t_bapiret TYPE STANDARD TABLE OF bapiret2. "Bapi Returb Tab Type

* Local data declaration
  DATA: lv_date    TYPE char10,              "date variable
        lv_time    TYPE char10,              "time variable
        lv_lines   TYPE i,                   "records count of final table
        lx_address TYPE bapiaddr3,           "User Address Data
        lwa_listheader TYPE slis_listheader, "list header
        li_return  TYPE ty_t_bapiret.        "return table

  CONSTANTS: lc_colon TYPE char1 VALUE ':', "Colon
             lc_slash TYPE char1 VALUE '/'. "Slash

  lwa_listheader-typ  = lc_typ_h.
  lwa_listheader-key  = 'Report'(015).
  lwa_listheader-info =
  'Send Transfer Price to External Systems'(016).
  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.

  lwa_listheader-typ  = lc_typ_s.
  lwa_listheader-key  = 'User Name'(017).

* Get user details
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    IMPORTING
      address  = lx_address
    TABLES
      return   = li_return.

  IF lx_address-fullname IS NOT INITIAL.
    MOVE lx_address-fullname TO lwa_listheader-info.
  ELSE. " ELSE -> IF lx_address-fullname IS NOT INITIAL
    MOVE sy-uname TO lwa_listheader-info.
  ENDIF. " IF lx_address-fullname IS NOT INITIAL

  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.

  lwa_listheader-typ = lc_typ_s.
  lwa_listheader-key = 'Date and Time'(018).

  CONCATENATE sy-uzeit+0(2)
              sy-uzeit+2(2)
              sy-uzeit+4(2)
         INTO lv_time
         SEPARATED BY lc_colon. "':'.

  CONCATENATE sy-datum+4(2)
              sy-datum+6(2)
              sy-datum+0(4)
         INTO lv_date
         SEPARATED BY lc_slash. "'/'.

  CONCATENATE lv_date
              lv_time
         INTO lwa_listheader-info
         SEPARATED BY space.
  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.

  DESCRIBE TABLE i_final[] LINES lv_lines.

  lwa_listheader-typ  = lc_typ_s.
  lwa_listheader-key  = 'Total Records'(019).
  MOVE lv_lines TO lwa_listheader-info.
  APPEND lwa_listheader TO i_listheader.

ENDFORM. " F_TOP_HEADER


*&---------------------------------------------------------------------*
*&      Form  sub_top_of_page
*&---------------------------------------------------------------------*
*      Subroutine is used to call TOP OF PAGE event dynamically
*----------------------------------------------------------------------*
*      <-- i_top using internal table for the TOP_OF_PAGE
*----------------------------------------------------------------------*
FORM f_top_of_page. "#EC CALLED
* Subroutine for top of page
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = i_listheader.

ENDFORM. "f_top_of_page
*&---------------------------------------------------------------------*
*&      Form  F_GET_RECODS_DELTA_LOAD
*&---------------------------------------------------------------------*
*       Getting Records from CDHDR,CDPOS and MVKE
*----------------------------------------------------------------------*
*      -->FP_I_STATUS   Internal Table for EMI entry
*      -->FP_I_VMSTA    Internal table for VMSTA
*      <--FP_I_CDHDR[]  Internal Table for CDHDR
*      <--FP_I_CDPOS[]  Internal table for CDPOS
*      <--FP_I_MVKE[]   Internal table for MVKE
*----------------------------------------------------------------------*
FORM f_get_recods_delta_load  USING    fp_i_status       TYPE ty_t_status
*-->Begin of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
                                       fp_i_vmsta        TYPE ty_t_vmsta " Distribution-chain-specific material status
*<--End of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
                              CHANGING fp_i_cdhdr        TYPE ty_t_cdhdr
                                       fp_i_cdpos        TYPE ty_t_cdpos
                                       fp_i_mvke         TYPE ty_t_mvke.




  FIELD-SYMBOLS: <lfs_cdhdr> TYPE ty_cdhdr,
                 <lfs_cdpos> TYPE ty_cdpos.

  DATA: lv_matnr    TYPE matnr,                                     " Material Number
        lwa_chngind TYPE fkk_ranges,                                " Structure: Select Options
        li_chngind  TYPE STANDARD TABLE OF fkk_ranges,              " Structure: Select Options
        li_cdhdr    TYPE STANDARD TABLE OF ty_cdhdr INITIAL SIZE 0, "Local internal table for CDHDR
        li_cdpos    TYPE STANDARD TABLE OF ty_cdpos INITIAL SIZE 0, "Local internal table for CDPOS
        li_fname    TYPE STANDARD TABLE OF fkk_ranges,              " Structure: Select Options
        lwa_fname   TYPE fkk_ranges,                                " Structure: Select Options
        lwa_status  TYPE zdev_enh_status,                           " Enhancement Status
        li_tabname  TYPE STANDARD TABLE OF fkk_ranges,              " Structure: Select Options
        lwa_tabname TYPE fkk_ranges.                                " Structure: Select Options



  CONSTANTS: lc_fname    TYPE z_criteria VALUE 'NAME_FELD', " Enh. Criteria
             lc_i        TYPE char1      VALUE 'I',         " I of type CHAR1
             lc_eq       TYPE char2      VALUE 'EQ',        " Eq of type CHAR2
             lc_material TYPE cdobjectcl VALUE 'MATERIAL',  " Object class
             lc_insert   TYPE tvarv_val  VALUE 'I',         " ABAP/4: Selection value (LOW or HIGH value, external format)
             lc_update   TYPE tvarv_val  VALUE 'U',         " ABAP/4: Selection value (LOW or HIGH value, external format)
             lc_mbew     TYPE tvarv_val  VALUE 'MBEW',      " ABAP/4: Selection value (LOW or HIGH value, external format)
             lc_mvke     TYPE tvarv_val  VALUE 'MVKE'.      " ABAP/4: Selection value (LOW or HIGH value, external format)

*-->Begin of Insert for D3_OTC_IDD_0216_R2_FUT_Issue by AMOHAPA on 23-Mar-2018

  TYPES: BEGIN OF lty_mara,
         matnr  TYPE matnr, " Material Number
         mtart  TYPE mtart, " Material Type
         END OF lty_mara.

  DATA: li_mara TYPE STANDARD TABLE OF lty_mara INITIAL SIZE 0,
        li_mvke TYPE STANDARD TABLE OF ty_mvke  INITIAL SIZE 0.

  FIELD-SYMBOLS:<lfs_mvke> TYPE ty_mvke.

*<--End of Insert for D3_OTC_IDD_0216_R2_FUT_Issue by AMOHAPA on 23-Mar-2018


  SELECT  objectclas " Object class
          objectid   " Object value
          changenr   " Document change number
          udate      " Creation date of the change document
          FROM cdhdr " Change document header
          INTO TABLE fp_i_cdhdr[]
          WHERE objectclas = lc_material
          AND   udate IN s_cdate[].

  IF sy-subrc IS INITIAL.

    li_cdhdr[] = fp_i_cdhdr[].

*--> Begin of delete for D3_OTC_IDD_0216_Defect#5759 by AMOHAPA on 18-Apr-2018
    "As we have different format of tabkey for MBEW and MVKE so removing this logic
*    LOOP AT li_cdhdr ASSIGNING <lfs_cdhdr>.
*
*
*      WRITE <lfs_cdhdr>-objectid TO lv_matnr.
*
*      CONCATENATE sy-mandt lv_matnr p_vkorg p_vtweg
*      INTO <lfs_cdhdr>-tabkey RESPECTING BLANKS .
*
*      CLEAR lv_matnr.
*
*    ENDLOOP. " LOOP AT li_cdhdr ASSIGNING <lfs_cdhdr>
*<-- End of delete for D3_OTC_IDD_0216_Defect#5759 by AMOHAPA on 18-Apr-2018

    SORT li_cdhdr BY objectclas objectid changenr.
*--> Begin of delete for D3_OTC_IDD_0216_Defect#5759 by AMOHAPA on 18-Apr-2018
*     tabkey.
*<-- End of delete for D3_OTC_IDD_0216_Defect#5759 by AMOHAPA on 18-Apr-2018

    DELETE ADJACENT DUPLICATES FROM li_cdhdr
                    COMPARING objectclas objectid changenr.
*--> Begin of delete for D3_OTC_IDD_0216_Defect#5759 by AMOHAPA on 18-Apr-2018
* tabkey.
*<-- End of delete for D3_OTC_IDD_0216_Defect#5759 by AMOHAPA on 18-Apr-2018

    IF <lfs_cdhdr> IS ASSIGNED.
      UNASSIGN <lfs_cdhdr>.
    ENDIF. " IF <lfs_cdhdr> IS ASSIGNED

    lwa_chngind-sign   = lc_i.
    lwa_chngind-option = lc_eq.
    lwa_chngind-low    = lc_insert.
    lwa_chngind-high   = abap_false.
    APPEND lwa_chngind TO li_chngind.
    CLEAR lwa_chngind-low.

    lwa_chngind-low    = lc_update.
    APPEND lwa_chngind TO li_chngind.
    CLEAR lwa_chngind.

    lwa_tabname-sign = lc_i.
    lwa_tabname-option = lc_eq.
    lwa_tabname-low = lc_mbew.
    lwa_tabname-high = abap_false.
    APPEND lwa_tabname TO li_tabname.
    CLEAR lwa_tabname-low.


    lwa_tabname-low = lc_mvke.
    APPEND lwa_tabname TO li_tabname.
    CLEAR lwa_tabname.

    LOOP AT fp_i_status INTO lwa_status.
      IF lwa_status-criteria = lc_fname.

        lwa_fname-sign   = lwa_status-sel_sign.
        lwa_fname-option = lwa_status-sel_option.
        lwa_fname-low    = lwa_status-sel_low.
        lwa_fname-high   = lwa_status-sel_high.
        APPEND lwa_fname TO li_fname.
        CLEAR lwa_fname.

      ENDIF. " IF lwa_status-criteria = lc_fname
      CLEAR lwa_status.
    ENDLOOP. " LOOP AT fp_i_status INTO lwa_status


    SELECT objectclas " Object class
           objectid   " Object value
*--> Begin of insert for D3_OTC_IDD_0216_Defect#5759 by AMOHAPA on 18-Apr-2018
"As we can't pass full key in where clause , so we are passing key fields in select statement
"to avoid performance related issue
           changenr "Document change number
           tabname  " Table Name
           tabkey   " Changed table record key
*<-- End of insert for D3_OTC_IDD_0216_Defect#5759 by AMOHAPA on 18-Apr-2018
           fname      " Field Name
           chngind    " Change Type (U, I, S, D)
           FROM cdpos " Change document items
           INTO TABLE fp_i_cdpos
           FOR ALL ENTRIES IN li_cdhdr
           WHERE objectclas = li_cdhdr-objectclas
           AND   objectid   = li_cdhdr-objectid
           AND   changenr   = li_cdhdr-changenr
           AND   tabname    IN li_tabname
*--> Begin of delete for D3_OTC_IDD_0216_Defect#5759 by AMOHAPA on 18-Apr-2018
"As we have different format of tabkey for MBEW and MVKE so removing from select statement
*           AND   tabkey     = li_cdhdr-tabkey
*<-- End of delete for D3_OTC_IDD_0216_Defect#5759 by AMOHAPA on 18-Apr-2018
           AND   fname      IN li_fname
           AND   chngind    IN li_chngind.

    IF sy-subrc IS INITIAL.

      LOOP AT fp_i_cdpos ASSIGNING <lfs_cdpos>.

        WRITE <lfs_cdpos>-objectid TO lv_matnr.

        <lfs_cdpos>-matnr = lv_matnr.

        CLEAR lv_matnr.

      ENDLOOP. " LOOP AT fp_i_cdpos ASSIGNING <lfs_cdpos>

      IF <lfs_cdpos> IS ASSIGNED.
        UNASSIGN <lfs_cdpos>.
      ENDIF. " IF <lfs_cdpos> IS ASSIGNED

      li_cdpos[] = fp_i_cdpos[].

      SORT li_cdpos BY matnr.
      DELETE ADJACENT DUPLICATES FROM li_cdpos COMPARING matnr.

      SELECT  matnr " Material Number
              vkorg " Sales Organization
              vtweg " Distribution Channel
*-->Begin of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
              vmsta " Distribution-chain-specific material status
*<--End of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
              dwerk     " Delivering Plant (Own or External)
              kondm     " Material Pricing Group
              FROM mvke " Sales Data for Material
              INTO TABLE fp_i_mvke
              FOR ALL ENTRIES IN li_cdpos
              WHERE matnr = li_cdpos-matnr
              AND   vkorg = p_vkorg
              AND   vtweg = p_vtweg.

      IF sy-subrc IS INITIAL.

        IF s_kondm[] IS NOT INITIAL.
          DELETE fp_i_mvke WHERE kondm NOT IN s_kondm[].
        ENDIF. " IF s_kondm[] IS NOT INITIAL
*-->Begin of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
        IF s_matnr[] IS NOT INITIAL.
          DELETE fp_i_mvke WHERE matnr NOT IN s_matnr[].
        ENDIF. " IF s_matnr[] IS NOT INITIAL
        IF fp_i_vmsta[] IS NOT INITIAL.
          DELETE fp_i_mvke WHERE vmsta NOT IN fp_i_vmsta[].
        ENDIF. " IF fp_i_vmsta[] IS NOT INITIAL
*<--End of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017

*-->Begin of Insert for D3_OTC_IDD_0216_R2_FUT_Issue by AMOHAPA on 23-Mar-2018
 "If material type is given in the selection screen then we have to filter it from MARA
        IF s_mtart[] IS NOT INITIAL.

          li_mvke[] = fp_i_mvke[].
          SORT li_mvke BY matnr.
          DELETE ADJACENT DUPLICATES FROM li_mvke COMPARING matnr.

          SELECT matnr     " Material Number
                 mtart     " Material Type
                 FROM mara " General Material Data
                 INTO TABLE li_mara
                 FOR ALL ENTRIES IN li_mvke
                 WHERE matnr = li_mvke-matnr
                 AND   mtart IN s_mtart[].
          IF sy-subrc IS INITIAL.
            LOOP AT fp_i_mvke ASSIGNING <lfs_mvke>.
              READ TABLE li_mara TRANSPORTING NO FIELDS
                                 WITH KEY matnr = <lfs_mvke>-matnr.
              IF sy-subrc IS NOT INITIAL.
                DELETE TABLE fp_i_mvke FROM <lfs_mvke>.
              ENDIF. " IF sy-subrc IS NOT INITIAL

            ENDLOOP. " LOOP AT fp_i_mvke ASSIGNING <lfs_mvke>
          ELSE. " ELSE -> IF sy-subrc IS INITIAL
            MESSAGE i892.
            LEAVE LIST-PROCESSING.
          ENDIF. " IF sy-subrc IS INITIAL

          IF <lfs_mvke> IS ASSIGNED.
            UNASSIGN <lfs_mvke>.
          ENDIF. " IF <lfs_mvke> IS ASSIGNED
          FREE: li_mvke,
                li_mara.

        ENDIF. " IF s_mtart[] IS NOT INITIAL

*<--End of Insert for D3_OTC_IDD_0216_R2_FUT_Issue by AMOHAPA on 23-Mar-2018

        SORT fp_i_mvke BY dwerk.


      ENDIF. " IF sy-subrc IS INITIAL

    ENDIF. " IF sy-subrc IS INITIAL

  ENDIF. " IF sy-subrc IS INITIAL

  IF fp_i_mvke[] IS INITIAL.
 "If there is no records found in MVKE then the program
 "should not execute more steps
    MESSAGE i138.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF fp_i_mvke[] IS INITIAL

  FREE: li_cdhdr[],
        li_cdpos[].

ENDFORM. " F_GET_RECODS_DELTA_LOAD
*&---------------------------------------------------------------------*
*&      Form  F_APPL_SERVER_UPLOAD
*&---------------------------------------------------------------------*
*       Uploading the output in the Application Server
*----------------------------------------------------------------------*
*      -->FP_I_FINAL[]  Final Internal Table
*      -->FP_I_ERROR[]  Error list
*----------------------------------------------------------------------*
FORM f_appl_server_upload  USING    fp_i_final TYPE ty_t_final
                                    fp_i_error TYPE ty_t_final.


**//Local Data Declaration
  DATA:lv_filename  TYPE localfile, " Local file for upload/download
       lv_flag      TYPE flag,      " General Flag
       lv_string    TYPE char1792,  " String of type CHAR1792
       lv_path      TYPE string,
       lwa_final    TYPE ty_final,
       lv_netpr     TYPE char15,    " Netpr of type CHAR15
       lv_kpein     TYPE char8,     " Kpein of type CHAR8
       lv_lines     TYPE i,         "Local varibale to keep error records
*--> Begin of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 09-Feb-2018
       lv_counter     TYPE char4,                      "Local constant for Counter of File
       lv_dirname     TYPE eps2filnam,                 " Directory name
       li_dirlist     TYPE STANDARD TABLE OF eps2fili, " Directory table
       lwa_dirlist    TYPE eps2fili,                   " List of Files
       lv_date        TYPE char10,                     " Date of type CHAR10
       lv_line_ct     TYPE sytabix.                    "Line count for list
*<-- End of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 09-Feb-2018


  CONSTANTS: lc_format TYPE string VALUE '.txt', " File Format
             lc_slash  TYPE char1  VALUE '/',    " Slash of type CHAR1
             lc_score  TYPE char1  VALUE '_',    " Score of type CHAR1
             lc_red    TYPE char4  VALUE '@0A@', " Red of type CHAR4
             lc_tbp    TYPE char4  VALUE '/TBP', "Folder path for TBP
*--> Begin of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 17-Jan-2018
             lc_pipe   TYPE char1  VALUE '|', "Pipe delimeter
*<-- End of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 17-Jan-2018


*--> Begin of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 09-Feb-2018

"File should be uploaded in AL11 folder with Running Number
"For Example if the report ran 10times in a particular day then 10files should
"be uploaded and the last file name should be OTC_IDD_0216_YYYYMMDD_10

             lc_object_name TYPE string     VALUE 'OTC_IDD_0216'. "Local Constant for Object

*<-- End of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 09-Feb-2018



  lv_path = p_path.

  CONCATENATE lv_path lc_tbp INTO lv_path.

*--> Begin of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 09-Feb-2018


  lv_dirname = lv_path.

  lv_counter = 1.

* Get all files from directory
  CALL FUNCTION 'EPS2_GET_DIRECTORY_LISTING'
    EXPORTING
      iv_dir_name            = lv_dirname
      file_mask              = space
    TABLES
      dir_list               = li_dirlist
    EXCEPTIONS
      invalid_eps_subdir     = 1
      sapgparam_failed       = 2
      build_directory_failed = 3
      no_authorization       = 4
      read_directory_failed  = 5
      too_many_read_errors   = 6
      empty_directory_list   = 7
      OTHERS                 = 8.


  IF sy-subrc IS INITIAL.

    lv_date = sy-datum.

    CLEAR lv_line_ct.
 "Reading from the last line to count the number entries on the same day

    DESCRIBE TABLE li_dirlist LINES lv_line_ct.

    DO.

      READ TABLE li_dirlist INTO lwa_dirlist INDEX lv_line_ct.

      IF sy-subrc IS INITIAL.

        IF lwa_dirlist-name CS lv_date.
          lv_counter = lv_counter + 1.
        ELSE. " ELSE -> IF lwa_dirlist-name CS lv_date
          EXIT.
        ENDIF. " IF lwa_dirlist-name CS lv_date
        lv_line_ct = lv_line_ct - 1.
        IF lv_line_ct < 1.
          EXIT.
        ENDIF. " IF lv_line_ct < 1
      ENDIF. " IF sy-subrc IS INITIAL
    ENDDO.
    CLEAR lwa_dirlist.

  ENDIF. " IF sy-subrc IS INITIAL


*<-- End of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 09-Feb-2018

*--> Begin of delete for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 09-Feb-2018

*  CONCATENATE lv_path lc_slash sy-datum lc_score sy-uzeit lc_format INTO lv_filename.

*<-- End of delete for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 09-Feb-2018

*--> Begin of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 09-Feb-2018
  SHIFT lv_counter LEFT DELETING LEADING space.
*--> Begin of delete for D3_OTC_IDD_0216_FUT_Issue by SMUKHER4 on 19-Jul-2018
*&--Below part of the code is commented as the numbering against the file is creating issue
*&--when it is not moved to the done folder on a same day
*  CONCATENATE lv_path lc_slash lc_object_name lc_score sy-datum lc_score lv_counter lc_format INTO lv_filename.
*<-- End of delete for D3_OTC_IDD_0216_FUT_Issue by SMUKHER4 on 19-Jul-2018

*--> Begin of insert for D3_OTC_IDD_0216_FUT_Issue by SMUKHER4 on 19-Jul-2018
*&--Instead of the numbering issue, we have kept the time stamp which will denote the unique file
*--genearted on a particular day.
  CONCATENATE lv_path lc_slash lc_object_name lc_score sy-datum sy-uzeit lc_format INTO lv_filename.
*<-- End of insert for D3_OTC_IDD_0216_FUT_Issue by SMUKHER4 on 19-Jul-2018

*<-- End of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 09-Feb-2018

 "Keeping the count for error records in a variable

  DESCRIBE TABLE fp_i_error LINES lv_lines.


  IF NOT lv_filename IS INITIAL.


**//Check file for authorization
    PERFORM f_check_file USING lv_filename
                      CHANGING lv_flag.
    IF lv_flag IS NOT INITIAL.
**//Transferring the Final table to Application Server.
      OPEN DATASET lv_filename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " Output type

      IF sy-subrc = 0.
**//Concatenating For Header in Application Server

        CONCATENATE 'Condition Type'(004) 'Sales Organization'(005) 'Distribution Channel'(006) 'Sold To Party'(007)
                    'Currency'(008) 'Material'(009)
*--> Begin of delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
*                     'Net Price'(010)
*                    'Pricing Unit'(011)
*<-- End of delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
*--> Begin of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
                     'Net Value'(026)
                     'Bill.qty'(027)
*<-- End of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018

                    'Unit Of Measure'(012) 'Effective From Date'(013) 'Effective To Date'(014)
                    INTO lv_string SEPARATED BY
*--> Begin of delete for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 17-Jan-2018
*                    cl_abap_char_utilities=>horizontal_tab.
*<-- End of delete for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 17-Jan-2018
*--> Begin of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 17-Jan-2018
                     lc_pipe.
*<-- End of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 17-Jan-2018
        TRANSFER lv_string TO lv_filename.
        CLEAR lv_string.

        LOOP AT fp_i_final INTO  lwa_final.

 "Only sending the valid records to Application file

          IF lwa_final-icon NE lc_red.


*--> Begin of delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
*             lv_netpr = lwa_final-netpr.
*            lv_kpein = lwa_final-kpein.
*<-- End of delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018

*--> Begin of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
            lv_kpein = lwa_final-fkimg. "Billed qunatity
            lv_netpr = lwa_final-netwr. "Net value
*<-- End of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
*& Feeding Records to the File
            CONCATENATE lwa_final-kschl lwa_final-vkorg lwa_final-vtweg lwa_final-kunnr lwa_final-waerk
                        lwa_final-matnr lv_netpr
                        lv_kpein
                        lwa_final-kmein lwa_final-datab
                        lwa_final-datbi
                        INTO lv_string SEPARATED BY
*--> Begin of delete for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 17-Jan-2018
*                       cl_abap_char_utilities=>horizontal_tab.
*<-- End of delete for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 17-Jan-2018
*--> Begin of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 17-Jan-2018
                        lc_pipe.
*<-- End of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 17-Jan-2018

            TRANSFER lv_string TO lv_filename.

            CLEAR : lv_string,
                    lv_netpr,
                    lwa_final.

          ENDIF. " IF lwa_final-icon NE lc_red

        ENDLOOP. " LOOP AT fp_i_final INTO lwa_final


        CLOSE DATASET lv_filename.

 "If Error table is filled then It will write in ERROR folder
        IF fp_i_error[] IS NOT INITIAL.

          PERFORM f_appl_server_error_upload USING fp_i_error[].

        ENDIF. " IF fp_i_error[] IS NOT INITIAL
**&-- File uploaded

        MESSAGE i894 WITH lv_lines.
        LEAVE LIST-PROCESSING.


      ELSE. " ELSE -> IF sy-subrc = 0


        MESSAGE i972 WITH p_path.
        LEAVE LIST-PROCESSING.


      ENDIF. " IF sy-subrc = 0

    ELSE. " ELSE -> IF lv_flag IS NOT INITIAL
*&-- File not uploaded
      MESSAGE i918 WITH p_path. "No authorization to write file &
      LEAVE LIST-PROCESSING.

    ENDIF. " IF lv_flag IS NOT INITIAL

  ENDIF. " IF NOT lv_filename IS INITIAL


  CLEAR lv_lines.


ENDFORM. " F_APPL_SERVER_UPLOAD


*&---------------------------------------------------------------------*
*&      Form  F_CHECK_FILE
*&---------------------------------------------------------------------*
*         Authorization check based on filename for AL11 action        *
*----------------------------------------------------------------------*
*      -->FP_LV_FILENAME  Local file for upload/download
*      <--FP_LV_FLAG      General Flag
*----------------------------------------------------------------------*
FORM f_check_file  USING    fp_filename TYPE localfile " Local file for upload/download
                   CHANGING fp_flag     TYPE flag.     " General Flag

  CONSTANTS: lc_act  TYPE char5 VALUE 'WRITE'. " Act of type Character
  DATA:      lv_file TYPE fileextern. " Physical file name

  CLEAR lv_file.

  lv_file = fp_filename.
*  Authorization for writing to dataset
  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
    EXPORTING
      activity         = lc_act
      filename         = lv_file
    EXCEPTIONS
      no_authority     = 1
      activity_unknown = 2
      OTHERS           = 3.

  IF sy-subrc IS INITIAL.
    fp_flag = abap_true.
  ELSE. " ELSE -> IF sy-subrc IS INITIAL
    fp_flag = abap_false.
  ENDIF. " IF sy-subrc IS INITIAL

ENDFORM. " F_CHECK_FILE
*&---------------------------------------------------------------------*
*&      Form  F_GET_EMI_ENTRY
*&---------------------------------------------------------------------*
*       Fetching Records From EMI entry
*----------------------------------------------------------------------*
*      <--FP_I_STATUS[]  Internal Table for EMI entries
*      <--FP_I_VMSTA[]   Internal Table for VMSTA Entries
*----------------------------------------------------------------------*
FORM f_get_emi_entry  CHANGING fp_i_status TYPE ty_t_status "Enhancement status table.
*-->Begin of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
                               fp_i_vmsta  TYPE ty_t_vmsta. "EMI table for VMSTA

  DATA: lwa_vmsta  TYPE ty_vmsta,
        lwa_status TYPE zdev_enh_status. " Enhancement Status

  CONSTANTS: lc_vmsta  TYPE z_criteria VALUE 'STATUS', " Enh. Criteria
             lc_sign   TYPE char1      VALUE 'I',      " Sign of type CHAR1
             lc_equal  TYPE char2      VALUE 'EQ'.     " Equal of type CHAR2
*<--End of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017

  CONSTANTS:  lc_enh_no TYPE z_enhancement VALUE 'OTC_IDD_0216'. " Enh. name

  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_no
    TABLES
      tt_enh_status     = fp_i_status. " Enhancement status table

* Delete the entries which are not active and pick all the active entries.
  DELETE fp_i_status WHERE active = space.

  SORT   fp_i_status BY criteria.

*-->Begin of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017

  LOOP AT fp_i_status INTO lwa_status.

    IF lwa_status-criteria = lc_vmsta.

      lwa_vmsta-sign   = lc_sign.
      lwa_vmsta-option = lc_equal.
      lwa_vmsta-low    = lwa_status-sel_low.
      lwa_vmsta-high   = lwa_status-sel_high.

      APPEND lwa_vmsta TO fp_i_vmsta.
      CLEAR lwa_vmsta.

    ENDIF. " IF lwa_status-criteria = lc_vmsta
    CLEAR lwa_status.
  ENDLOOP. " LOOP AT fp_i_status INTO lwa_status

*<--End of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017

ENDFORM. " F_GET_EMI_ENTRY
*&---------------------------------------------------------------------*
*&      Form  F_FOLDER_PATH_NAME
*&---------------------------------------------------------------------*
*       Populating the folder path in selection screen
*----------------------------------------------------------------------*

FORM f_folder_path_name .

*&-- Create default path
  CONSTANTS: lc_appl TYPE string VALUE '/appl/',
             lc_rep  TYPE string VALUE '/INT/Outbound/OTC/OTC_IDD_0216_SAP'.

  CONCATENATE lc_appl sy-sysid lc_rep INTO p_path.


ENDFORM. " F_FOLDER_PATH_NAME
*&---------------------------------------------------------------------*
*&      Form  F_GET_ERROR_ENTRY
*&---------------------------------------------------------------------*
*       Getting the Error Records
*----------------------------------------------------------------------*
*     -->FP_I_FINAL          Final Internal Table
*     <--FP_I_ERROR[]        Error list
*----------------------------------------------------------------------*
FORM f_get_error_entry  USING    fp_i_final       TYPE ty_t_final
                        CHANGING fp_i_error TYPE ty_t_final.


  DATA: li_final TYPE STANDARD TABLE OF ty_final INITIAL SIZE 0.

  CONSTANTS:  lc_red       TYPE char4 VALUE '@0A@'. " Red of type CHAR4


  IF fp_i_final[] IS NOT INITIAL.

    li_final[] = fp_i_final[].

    SORT li_final BY icon.

    DELETE li_final WHERE icon NE lc_red.

    fp_i_error[] = li_final[].

  ENDIF. " IF fp_i_final[] IS NOT INITIAL

  FREE li_final.

ENDFORM. " F_GET_ERROR_ENTRY
*&---------------------------------------------------------------------*
*&      Form  F_GET_FINAL_FROM_SUBMIT
*&---------------------------------------------------------------------*
*       Getting Records from the standard program
*----------------------------------------------------------------------*
*      --> FP_LV_ZPPM      Varibale for ZPPM
*      <-- FP_LI_SELTAB    Internal table for Selection Table
*      <-- FP_I_FINAL      Final table for Success case
*----------------------------------------------------------------------*
FORM f_get_final_from_submit  USING    fp_lv_zppm      TYPE kschl " Condition Type
                              CHANGING fp_li_seltab    TYPE ty_t_submit
                                       fp_i_final      TYPE ty_t_final.

  DATA: lwa_final      TYPE ty_final,    "Local workarea for Final tabel
        lwa_pay_data   TYPE REF TO data, "class
        lwa_output     TYPE ty_output,
        lv_date        TYPE sydatum,     " Current Date of Application Server
        lv_kunnr       TYPE kunag.       " Sold-to party


  FIELD-SYMBOLS: <lfs_t_pay_data> TYPE ANY TABLE.

  CONSTANTS:
                                                     "Constant to populate traffic light
               lc_red       TYPE char4 VALUE '@0A@', " Red of type CHAR4
               lc_green     TYPE char4 VALUE '@08@'. " Green of type CHAR4

  lv_date = sy-datum.
  lv_kunnr = p_kunnr.

  DELETE ADJACENT DUPLICATES FROM fp_li_seltab[] COMPARING ALL FIELDS.

  cl_salv_bs_runtime_info=>set(
                   EXPORTING display  = abap_false
                             metadata = abap_false
                             data     = abap_true ).

  SUBMIT sdnetpr0 WITH SELECTION-TABLE fp_li_seltab
                  AND RETURN.

  TRY.
      cl_salv_bs_runtime_info=>get_data_ref(
      IMPORTING r_data = lwa_pay_data ).
      ASSIGN lwa_pay_data->* TO <lfs_t_pay_data>.


    CATCH cx_salv_bs_sc_runtime_info.
      MESSAGE e132. "Issue in ALV display
  ENDTRY.

  cl_salv_bs_runtime_info=>clear_all( ).

  IF <lfs_t_pay_data> IS ASSIGNED.

    LOOP AT <lfs_t_pay_data> INTO lwa_output.

      lwa_final-kschl = fp_lv_zppm.
      lwa_final-vkorg = p_vkorg.
      lwa_final-vtweg = p_vtweg.
      lwa_final-kunnr = lv_kunnr.
      lwa_final-waerk = lwa_output-waerk.
      lwa_final-matnr = lwa_output-matnr.
*--> Begin of delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
      "Bussiness want to see the Net Value not the Net Price
*      lwa_final-netpr = lwa_output-netpr.
*<-- End of delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
*--> Begin of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
      "Net value should be populated from Net Value / Billing Quantity

*--> Begin of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by SMUKHER4 on 19-Jun-2018
*&--Check is done to avoid dump if FKLMG does not have any value.
      IF lwa_output-fklmg IS NOT INITIAL.
*<-- End of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by SMUKHER4 on 19-Jun-2018

            lwa_final-netwr = lwa_output-netwr / lwa_output-fklmg.

*--> Begin of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by SMUKHER4 on 19-Jun-2018
      ENDIF. " IF lwa_output-fklmg IS NOT INITIAL
*<-- End of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by SMUKHER4 on 19-Jun-2018

 "Billed Quantity should populate
      lwa_final-fkimg = lwa_output-fkimg.
*<-- End of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018

*--> Begin of delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
      "Bussiness don't want Pricing unit to be displayed in the output
*      lwa_final-kpein = lwa_output-kpein.
*<-- End of delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
*--> Begin of delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
      "Bussiness want to see the base unit of measurement in the output from MEINS
*      lwa_final-kmein = lwa_output-kmein.
*<-- End of delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
*<-- Begin of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
      lwa_final-kmein = lwa_output-meins.
*<-- End of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
      lwa_final-datab = lv_date.
      lwa_final-datbi = '99991231'.
*--> Begin of delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
*      IF lwa_final-netpr IS INITIAL.
*<-- End of delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
*--> Begin of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
      IF lwa_output-netpr IS INITIAL.
*--> End of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
        lwa_final-icon = lc_red.
        lwa_final-error = 'Record having zero Netprice'(024).

      ELSE. " ELSE -> IF lwa_output-netpr IS INITIAL
        lwa_final-icon = lc_green.

      ENDIF. " IF lwa_output-netpr IS INITIAL


      APPEND lwa_final TO fp_i_final[].
      CLEAR lwa_final.

    ENDLOOP. " LOOP AT <lfs_t_pay_data> INTO lwa_output

  ENDIF. " IF <lfs_t_pay_data> IS ASSIGNED

  UNASSIGN <lfs_t_pay_data>.

ENDFORM. " F_GET_FINAL_FROM_SUBMIT
*&---------------------------------------------------------------------*
*&      Form  F_APPL_SERVER_ERROR_UPLOAD
*&---------------------------------------------------------------------*
*       Write File in ERROR Folder
*----------------------------------------------------------------------*
*      -->FP_I_ERROR[]   Internal table with Error List
*----------------------------------------------------------------------*
FORM f_appl_server_error_upload  USING    fp_i_error    TYPE ty_t_final.



  DATA:lv_filename  TYPE localfile, " Local file for upload/download
        lv_flag      TYPE flag,     " General Flag
        lv_string    TYPE char1792, " String of type CHAR1792
        lv_path      TYPE string,
        lwa_final    TYPE ty_final,
        lv_netpr     TYPE char15,   " Netpr of type CHAR15
        lv_kpein     TYPE char8,    " Kpein of type CHAR8
        lv_lines     TYPE i,        "Local varibale to keep error records
*--> Begin of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 09-Feb-2018
       lv_counter    TYPE char4,                      "Local constant for Counter of File
       lv_dirname    TYPE eps2filnam,                 " Directory name
       li_dirlist    TYPE STANDARD TABLE OF eps2fili, " Directory table
       lwa_dirlist   TYPE eps2fili,                   " List of Files
       lv_date       TYPE char10,                     " Date of type CHAR10
       lv_line_ct    TYPE sytabix.                    "Line count for list
*<-- End of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 09-Feb-2018


  CONSTANTS: lc_format TYPE string VALUE '.txt', " File Format
             lc_slash  TYPE char1  VALUE '/',    " Slash of type CHAR1
             lc_score  TYPE char1 VALUE '_',     " Score of type CHAR1
             lc_error TYPE char6 VALUE '/ERROR', "Folder path for Error
*--> Begin of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 17-Jan-2018
             lc_pipe   TYPE char1  VALUE '|', "Pipe delimeter
*<-- End of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 17-Jan-2018

*--> Begin of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 09-Feb-2018
             lc_object_name TYPE string     VALUE 'OTC_IDD_0216'. "Local Constant for Object
*<-- End of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 09-Feb-2018


  lv_path = p_path.



  DESCRIBE TABLE fp_i_error LINES lv_lines.

  CONCATENATE lv_path lc_error INTO lv_path.

*--> Begin of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 09-Feb-2018


  lv_dirname = lv_path.

  lv_counter = 1.

* Get all files from directory
  CALL FUNCTION 'EPS2_GET_DIRECTORY_LISTING'
    EXPORTING
      iv_dir_name            = lv_dirname
      file_mask              = space
    TABLES
      dir_list               = li_dirlist
    EXCEPTIONS
      invalid_eps_subdir     = 1
      sapgparam_failed       = 2
      build_directory_failed = 3
      no_authorization       = 4
      read_directory_failed  = 5
      too_many_read_errors   = 6
      empty_directory_list   = 7
      OTHERS                 = 8.


  IF sy-subrc IS INITIAL.

    lv_date = sy-datum.

    CLEAR lv_line_ct.
 "Reading from the last line to count the number entries on the same day
    DESCRIBE TABLE li_dirlist LINES lv_line_ct.

    DO.

      READ TABLE li_dirlist INTO lwa_dirlist INDEX lv_line_ct.

      IF sy-subrc IS INITIAL.

        IF lwa_dirlist-name CS lv_date.
          lv_counter = lv_counter + 1.
        ELSE. " ELSE -> IF lwa_dirlist-name CS lv_date
          EXIT.
        ENDIF. " IF lwa_dirlist-name CS lv_date
        lv_line_ct = lv_line_ct - 1.
        IF lv_line_ct < 1.
          EXIT.
        ENDIF. " IF lv_line_ct < 1
      ENDIF. " IF sy-subrc IS INITIAL
    ENDDO.
    CLEAR lwa_dirlist.

  ENDIF. " IF sy-subrc IS INITIAL

*<-- End of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 09-Feb-2018

*--> Begin of delete for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 09-Feb-2018
*  CONCATENATE lv_path lc_slash sy-datum lc_score sy-uzeit lc_format INTO lv_filename.
*<-- End of delete for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 09-Feb-2018

*--> Begin of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 09-Feb-2018

  SHIFT lv_counter LEFT DELETING LEADING space.

*--> Begin of delete for D3_OTC_IDD_0216_FUT_Issue by SMUKHER4 on 19-Jul-2018
*&--Below part of the code is commented as the numbering against the file is creating issue
*&--when it is not moved to the done folder on a same day

*  CONCATENATE lv_path lc_slash lc_object_name lc_score sy-datum lc_score lv_counter lc_format INTO lv_filename.

*<-- End of delete for D3_OTC_IDD_0216_FUT_Issue by SMUKHER4 on 19-Jul-2018

*--> Begin of insert for D3_OTC_IDD_0216_FUT_Issue by SMUKHER4 on 19-Jul-2018
*&--Instead of the numbering issue, we have kept the time stamp which will denote the unique file
*--genearted on a particular day.
  CONCATENATE lv_path lc_slash lc_object_name lc_score sy-datum sy-uzeit lc_format INTO lv_filename.
*<-- End of insert for D3_OTC_IDD_0216_FUT_Issue by SMUKHER4 on 19-Jul-2018

*<-- End of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 09-Feb-2018

  IF NOT lv_filename IS INITIAL.

**//Check file for authorization
    PERFORM f_check_file USING lv_filename
                      CHANGING lv_flag.
    IF lv_flag IS NOT INITIAL.
**//Transferring the Final table to Application Server.
      OPEN DATASET lv_filename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " Output type

      IF sy-subrc = 0.
**//Concatenating For Header in Application Server

        CONCATENATE 'Condition Type'(004) 'Sales Organization'(005) 'Distribution Channel'(006) 'Sold To Party'(007)
                    'Currency'(008) 'Material'(009)
*--> Begin of delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
*                     'Net Price'(010)
*                    'Pricing Unit'(011)
*<-- End of delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
*--> Begin of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
                     'Net Value'(026)
                     'Bill.qty'(027)
*<-- End of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
                    'Unit Of Measure'(012) 'Effective From Date'(013) 'Effective To Date'(014)
                    'Error Condition'(025)
                    INTO lv_string SEPARATED BY
*--> Begin of delete for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 17-Jan-2018
*                    cl_abap_char_utilities=>horizontal_tab.
*<-- End of delete for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 17-Jan-2018
*--> Begin of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 17-Jan-2018
                     lc_pipe.
*<-- End of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 17-Jan-2018
        TRANSFER lv_string TO lv_filename.
        CLEAR lv_string.


        LOOP AT fp_i_error INTO  lwa_final.

          "Only sending the valid records to Application file


*--> Begin of delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
*           lv_netpr = lwa_final-netpr.
*          lv_kpein = lwa_final-kpein.
*<-- End of delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
*--> Begin of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
          lv_kpein = lwa_final-fkimg. "Billed qunatity
          lv_netpr = lwa_final-netwr. "Net value
*<-- End of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
*& Feeding Records to the File
          CONCATENATE lwa_final-kschl lwa_final-vkorg lwa_final-vtweg lwa_final-kunnr lwa_final-waerk
                      lwa_final-matnr lv_netpr
                      lv_kpein
                      lwa_final-kmein lwa_final-datab
                      lwa_final-datbi lwa_final-error
                      INTO lv_string SEPARATED BY
*--> Begin of delete for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 17-Jan-2018
*                    cl_abap_char_utilities=>horizontal_tab.
*<-- End of delete for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 17-Jan-2018
*--> Begin of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 17-Jan-2018
                     lc_pipe.
*<-- End of insert for D3_OTC_IDD_0216_FUT_Issue by AMOHAPA on 17-Jan-2018

          TRANSFER lv_string TO lv_filename.

          CLEAR : lv_string,
                  lv_netpr,
                  lwa_final.


        ENDLOOP. " LOOP AT fp_i_error INTO lwa_final


        CLOSE DATASET lv_filename.
*&-- File uploaded
        MESSAGE i894 WITH lv_lines.
        LEAVE LIST-PROCESSING.

      ELSE. " ELSE -> IF sy-subrc = 0

        MESSAGE i972 WITH p_path.
        LEAVE LIST-PROCESSING.

      ENDIF. " IF sy-subrc = 0

    ELSE. " ELSE -> IF lv_flag IS NOT INITIAL
*&-- File not uploaded
      MESSAGE i918 WITH p_path. "No authorization to write file &
      LEAVE LIST-PROCESSING.

    ENDIF. " IF lv_flag IS NOT INITIAL

  ENDIF. " IF NOT lv_filename IS INITIAL

  CLEAR lv_lines.

ENDFORM. " F_APPL_SERVER_ERROR_UPLOAD
*&---------------------------------------------------------------------*
*&      Form  F_MAKE_MVKE_PLANT
*&---------------------------------------------------------------------*
*       Populating the internal table for MVKE
*----------------------------------------------------------------------*
*      -->FP_I_MVKE     Internal table for MVKE
*      <--FP_I_MVKE_PT  Internal table for MVKE
*----------------------------------------------------------------------*
FORM f_make_mvke_plant  USING    fp_i_mvke    TYPE ty_t_mvke
                        CHANGING fp_i_mvke_pt TYPE ty_t_mvke_pt.

  DATA: lwa_mvke TYPE ty_mvke,
        lwa_mvke_pt TYPE ty_mvke_pt.

  LOOP AT fp_i_mvke INTO lwa_mvke.

    lwa_mvke_pt-vkorg = lwa_mvke-vkorg.
    lwa_mvke_pt-vtweg = lwa_mvke-vtweg.
    lwa_mvke_pt-matnr = lwa_mvke-matnr.
    lwa_mvke_pt-dwerk = lwa_mvke-dwerk.
    lwa_mvke_pt-kondm = lwa_mvke-kondm.

    APPEND lwa_mvke_pt TO fp_i_mvke_pt.
    CLEAR: lwa_mvke_pt,
           lwa_mvke.

  ENDLOOP. " LOOP AT fp_i_mvke INTO lwa_mvke


  SORT fp_i_mvke_pt BY dwerk.

ENDFORM. " F_MAKE_MVKE_PLANT
*-->Begin of Insert for D3_OTC_IDD_0216_R2_FUT_Issue by AMOHAPA on 23-Mar-2018

*&---------------------------------------------------------------------*
*&      Form  F_VAILDATION_MAT_TYPE
*&---------------------------------------------------------------------*
*       Material Type validation
*----------------------------------------------------------------------*
FORM f_vaildation_mat_type .

  DATA lv_mtart TYPE mtart. " Material Pricing Group

  SELECT  mtart     " Material Pricing Group
          FROM t134 " Conditions: Groups for Materials
          INTO lv_mtart
          UP TO 1 ROWS
          WHERE mtart IN s_mtart[].
  ENDSELECT.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE e893.
  ENDIF. " IF sy-subrc IS NOT INITIAL

  CLEAR lv_mtart.


ENDFORM. " F_VAILDATION_MAT_TYPE
*<--End of Insert for D3_OTC_IDD_0216_R2_FUT_Issue by AMOHAPA on 23-Mar-2018
