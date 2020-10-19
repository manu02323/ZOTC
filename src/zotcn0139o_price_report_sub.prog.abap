***********************************************************************
*Program    : ZOTCN0139O_PRICE_REPORT_SUB                             *
*Title      : PRICE OVERRIDE REPORT_SUB                               *
*Developer  : Devendra Battala                                        *
*Object type: Report                                                  *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_RDD_0139                                           *
*---------------------------------------------------------------------*
*Description:  Business requires a report monthly, for Invoices, whose*
* prices, have been manually overridden. They need a report at an Item*
* level, which contains the details of the prices of such Invoices    *
* along with their Order details.                                     *
* As this is a huge extract, this is to be scheduled as a background  *
* job, and user can get the output in the system spool.               *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport                     Description *
*=========== ============== ============== ===========================*
*14-Jun-2019  U105652       E2DK924628     SCTASK0840194: Initial     *
*                                          Development                *
*&--------------------------------------------------------------------*
*=========== ============== ============== ===========================*
*06-Aug-2019  U105652       E2DK924628    1.SCTASK0840194: Additional *
*                                          Changes of SCTASK0840194   *
*                                         the Condition Control column*
*                                         for each of the Condition   *
*                                         types maintained in the EMI *
*                                         table.                      *
*                                         2. Changed  information     *
*                                          Messages to Error messages *
*&--------------------------------------------------------------------*
* 24-Sep-2019 U033959       E2DK924628    SCTASK0873868               *
*                                         Performance tuning done     *
*---------------------------------------------------------------------*




*&--------------------------------------------------------------------*
*&      Form  F_USER_DROP_DOWN_LIST_FORDT                             *
*&--------------------------------------------------------------------*
*       TO GET THE DROPDOWN LIST FOR MONTH                            *
*---------------------------------------------------------------------*
FORM f_user_drop_down_list_fordt .

  TYPES: BEGIN OF lty_month,
           spras TYPE spras, " langauge
           mnr   TYPE fcmnr, " Number
           ktx   TYPE fcktx, " Short Text
           ltx   TYPE fcltx, " Long Text
         END OF lty_month.

  DATA: lv_name   TYPE vrm_id,   " Vrm id for name
        li_list   TYPE vrm_values, " vrm values for list of month
        lwa_list  TYPE vrm_value, " Operation LIST
        li_months TYPE STANDARD TABLE OF lty_month INITIAL SIZE 0, " Month name and short text
        lwa_month TYPE lty_month. " local work area

  CONSTANTS:lc_spras TYPE spras VALUE 'E',       " Local Constant for Language
            lc_name  TYPE vrm_id VALUE 'P_MONTH'. " Local constant for month names

  REFRESH li_list.

  lv_name = lc_name.

  SELECT *
  INTO TABLE li_months
  FROM t247
  WHERE spras EQ lc_spras.

  IF sy-subrc = 0.
    SORT li_months BY mnr.

    LOOP AT li_months INTO lwa_month.
      lwa_list-key = lwa_month-mnr.
      lwa_list-text = lwa_month-ltx.
      APPEND lwa_list TO li_list.
      CLEAR:lwa_list.
    ENDLOOP. " LOOP AT t_months

    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id              = lv_name
        values          = li_list
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.

    IF sy-subrc = 0 ##NEEDED.
* for vrm set values.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_FETCH_DATA_KBETR
*&---------------------------------------------------------------------*
*     Fetching data from kbetr table
*----------------------------------------------------------------------*
*  -->   FETCH DATA FROM KBTER TABLE
*
*----------------------------------------------------------------------*
FORM f_fetch_data_kbetr CHANGING fp_i_emikschl TYPE ty_t_emikschl       " Internal Table for EMI entries
                                 fp_records    TYPE syst_dbcnt.

  DATA: li_emi    TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Enhancement Status
        lwa_kschl TYPE fkk_ranges,                                       " Structure: Select Options
        lwa_emi   TYPE zdev_enh_status .                                 " Enhancement Status
  CONSTANTS:
    lc_kschl   TYPE z_criteria VALUE 'KSCHL',                             " Local work area for kschl
    lc_records TYPE z_criteria VALUE 'RECORDS'.                           " Local work area for records

  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = c_enh_num
    TABLES
      tt_enh_status     = li_emi.

  DELETE li_emi WHERE active NE abap_true.

  IF li_emi IS NOT INITIAL.
    SORT li_emi BY criteria.

    LOOP AT li_emi INTO lwa_emi.
      CASE lwa_emi-criteria.
        WHEN lc_kschl.
          lwa_kschl-sign   = c_i.
          lwa_kschl-option = c_eq.
          lwa_kschl-low    = lwa_emi-sel_low.
          lwa_kschl-high   = lwa_emi-sel_high.
          APPEND  lwa_kschl TO fp_i_emikschl.
          CLEAR : lwa_kschl.
        WHEN lc_records.
          fp_records = lwa_emi-sel_low.
        WHEN OTHERS.
          " Do nothing
      ENDCASE." IF lwa_emi-criteria EQ 'KSCHL'
      CLEAR lwa_emi.
    ENDLOOP. " LOOP AT li_emi INTO lwa_emi
  ENDIF. " IF li_emi IS NOT INITIAL
ENDFORM."fetch_data_kbetr
*&---------------------------------------------------------------------*
*&  Include    ZOTC_PRICE_REPORT_SUB
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_BITY
*&---------------------------------------------------------------------*
*     Form to validate Billing Type
*----------------------------------------------------------------------*
FORM f_validate_bity .

  DATA:lv_fkart TYPE fkart ##NEEDED. " Billing type. ##NEEDED.

  SELECT fkart " Select Billing Type
    INTO lv_fkart UP TO 1 ROWS
    FROM tvfk    " Value Tbale
    WHERE fkart IN s_bity.
  ENDSELECT.

  IF sy-subrc IS NOT INITIAL.
*->Begin of delete for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
*   MESSAGE i096 DISPLAY LIKE c_e. " The Billing Type is Not Valid.Please check and re-enter
*   LEAVE LIST PROCESSING.
*<-End of delete for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019

*->Begin of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
    MESSAGE e096 . " The Billing Type is Not Valid.Please check and re-enter
*<-End of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019

  ENDIF. " IF sy-subrc IS NOT INITIAL AND lv_fkart IS INITIAL
ENDFORM."f_validate_bity
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SORG
*&---------------------------------------------------------------------*
*  Form to validate sales organization
*----------------------------------------------------------------------*
FORM f_validate_sorg .

  DATA:lv_vkorg TYPE vkorg ##NEEDED. " Sales Organization.

  SELECT vkorg " select sales organization
  INTO lv_vkorg UP TO 1 ROWS
  FROM tvko    " Value Table
  WHERE vkorg IN s_sorg.
  ENDSELECT.

  IF sy-subrc IS NOT INITIAL.
*->Begin of delete for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
*   MESSAGE i984 DISPLAY LIKE c_e.   "Sales Organization is not valid.
*   LEAVE LIST PROCESSING.
*<-End of delete for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019

*->Begin of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
    MESSAGE e984.   "Sales Organization is not valid.
*<-End of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019

  ENDIF. " IF sy-subrc IS NOT INITIAL AND lv_vkorg IS INITIAL
ENDFORM. "f_validate_sorg
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DISCH
*&---------------------------------------------------------------------*
*   Form to validate Distribution Channel
*----------------------------------------------------------------------*
FORM f_validate_disch .

  DATA:lv_vtweg TYPE vtweg ##NEEDED. " Distribution Channel ##NEEDED.

  SELECT vtweg " Select Distribution Channel field
  INTO lv_vtweg UP TO 1 ROWS
  FROM tvtw    " Value table
  WHERE vtweg IN s_disch.
  ENDSELECT.

  IF sy-subrc IS NOT INITIAL.
*->Begin of delete for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
*   MESSAGE i985 DISPLAY LIKE c_e.  "Distribution Channel is not valid.
*   LEAVE LIST PROCESSING.
*<-End of delete for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019

*->Begin of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
    MESSAGE e985. "Distribution Channel is not valid.
*<-End of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
  ENDIF. " IF sy-subrc IS NOT INITIAL AND lv_vtweg IS INITIAL

ENDFORM. "f_validate_disch
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_YEAR
*&---------------------------------------------------------------------*
*   Validation for year and it should be below current year
*----------------------------------------------------------------------*
FORM f_validate_year .

  DATA: lv_year  TYPE gjahr. " Fiscal Year

  lv_year = sy-datum+0(4).
  IF p_year > lv_year.
*->Begin of delete for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
*   MESSAGE i799 DISPLAY LIKE c_e. " Enter valid year
*   LEAVE LIST PROCESSING.
*<-End of delete for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019

*->Begin of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
    MESSAGE e799. " Enter valid year
*<-End of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019

  ENDIF. " IF p_year > lv_year

ENDFORM. "f_validate_year
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_VBRK
*&---------------------------------------------------------------------*
*  Fetching data from VBRK table
*----------------------------------------------------------------------*
*      <--FP_I_VBRK[]  Internal table of vbrk
*----------------------------------------------------------------------*
FORM f_get_data_vbrk  CHANGING fp_i_vbrk TYPE ty_t_vbrk.
  CONSTANTS : lc_i  TYPE char1 VALUE 'I',
              lc_bt TYPE char2 VALUE 'BT'.

  DATA : li_date_range  TYPE STANDARD TABLE OF fkk_ranges,
         lwa_date_range TYPE fkk_ranges.

  DATA:lv_date  TYPE datum, " Date
       lv_ldate TYPE datum. " ending date of month


  CONSTANTS:lc_num TYPE char2 VALUE '01'.  " Number

  CONCATENATE p_year
              p_month
              lc_num
         INTO lv_date.
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_date
    IMPORTING
      last_day_of_month = lv_ldate.

  lwa_date_range-sign   = lc_i.
  lwa_date_range-option = lc_bt.
  lwa_date_range-low    = lv_date.
  lwa_date_range-high   = lv_ldate.
  APPEND lwa_date_range TO li_date_range.
  CLEAR lwa_date_range.

  SELECT  vbeln              " Billing Document
          fkart              " Billing Type
          waerk              " SD Document Currency
          vkorg              " Sales Organization
          knumv              " Number of the document condition
          fkdat              " Billing date for billing index and printout
          netwr              " Net Value in Document Currency
          erdat              " Date on Which Record Was Created
          kunag              " Sold-to party
          knuma              " Agreement (various conditions grouped together)
          bstnk_vf FROM vbrk " Billing Document: Header Data
         INTO TABLE  fp_i_vbrk
*--->Begin of Delete for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-SEP-2019
*    Deleted because fields are not in sequence
*          WHERE erdat IN li_date_range
*            AND vkorg IN s_sorg
*            AND vtweg IN s_disch
*            AND fkart IN s_bity.
*<---End of Delete for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-SEP-2019
*--->Begin of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-SEP-2019
*     Where clause has been written again to keep the field in sequence
          WHERE fkart IN s_bity
            AND vkorg IN s_sorg
            AND vtweg IN s_disch
            AND erdat IN li_date_range.
*<---End of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-SEP-2019
  IF sy-subrc IS INITIAL.
    SORT fp_i_vbrk BY vbeln.
*->Begin of delete for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
*ELSE.
* MESSAGE e927. "DISPLAY LIKE c_e.   " No data found
* LEAVE LIST PROCESING.
*<-End of delete for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
  ENDIF. " IF sy-subrc IS NOT INITIAL
  CLEAR: lv_date,
          lv_ldate.
ENDFORM. "f_get_data_vbrk
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_VBRP
*&---------------------------------------------------------------------*
*       fetching data from vbrp table
*----------------------------------------------------------------------*
*     -->fP_I_VBRK[]  Internal table for vbrk
*      <--fP_I_VBRP[]  Internal table for vbrp
*----------------------------------------------------------------------*
FORM f_get_data_vbrp  USING    fp_i_vbrk TYPE ty_t_vbrk  "Internal Table of vbrk
                      CHANGING fp_i_vbrp TYPE ty_t_vbrp. "Internal Table of vbrp

  IF fp_i_vbrk IS NOT INITIAL.
    SELECT vbeln      " Billing Document
           posnr      " Billing item
           fkimg      " Actual Invoiced Quantity
           netwr      " Net value of the billing item in document currency
           aubel      " Sales Document
           aupos      " Sales Document Item
           matnr      " Material Number
           zzquoteref " Legacy Qtn Ref
      FROM vbrp       " Billing Document: Item Data
      INTO TABLE fp_i_vbrp
      FOR ALL ENTRIES IN fp_i_vbrk
      WHERE vbeln = fp_i_vbrk-vbeln.

    IF sy-subrc = 0.
      SORT fp_i_vbrp BY vbeln posnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF fp_i_vbrk IS NOT INITIAL
ENDFORM. "f_get_data_vbrp
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_VBAK
*&---------------------------------------------------------------------*
*        fetching data from vbrp table
*----------------------------------------------------------------------*
*      -->fP_I_VBRP[]  Internal table for vbrp
*      <--fP_I_VBAK[]   Internal table for vbak
*----------------------------------------------------------------------*
FORM f_get_data_vbak  USING    fp_i_vbrp TYPE ty_t_vbrp  "Internal table for vbrp
                      CHANGING fp_i_vbak TYPE ty_t_vbak. "Internal table for vbak

  DATA: li_vbrp TYPE STANDARD TABLE OF ty_vbrp INITIAL SIZE 0. " local internal table

  IF fp_i_vbrp IS NOT INITIAL.
    li_vbrp[] = fp_i_vbrp[].
    SORT li_vbrp BY aubel.
    DELETE ADJACENT DUPLICATES FROM li_vbrp COMPARING aubel.

    SELECT  vbeln   " Sales Document
            erdat   " Date on Which Record Was Created
            ernam   " Name of Person who Created the Object
            auart   " Sales Document Type
            vkbur   " Sales Office
           zzdocref " Legacy Doc Ref
           zzdoctyp " Ref Doc type
      FROM vbak     " Sales Document: Header Data
      INTO TABLE fp_i_vbak
      FOR ALL ENTRIES IN li_vbrp
      WHERE vbeln = li_vbrp-aubel.

    IF sy-subrc = 0.
      SORT fp_i_vbak BY vbeln.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF fp_i_vbrp IS NOT INITIAL

ENDFORM. "f_get_data_vbak
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_VBAP
*&---------------------------------------------------------------------*
*     fetching data from vbap table
*----------------------------------------------------------------------*
*      -->FP_I_VBRP[]  Internal table for vbrp
*      <--FP_I_VBAP[]  Internal table for vbap
*----------------------------------------------------------------------*
FORM f_get_data_vbap  USING   fp_i_vbrp TYPE ty_t_vbrp  "Internal table for vbrp
                      CHANGING fp_i_vbap TYPE ty_t_vbap. "Internal table for vbak

  DATA: li_vbrp TYPE STANDARD TABLE OF ty_vbrp INITIAL SIZE 0. " local internal table

  IF fp_i_vbrp IS NOT INITIAL.
    li_vbrp[] = fp_i_vbrp[].
    SORT li_vbrp BY aubel aupos.
    DELETE ADJACENT DUPLICATES FROM li_vbrp COMPARING aubel aupos.

    SELECT vbeln " Sales Document
           posnr " Sales Document Item
           matkl " Material Group
           werks " Plant (Own or External)
           prctr " Profit Center
    FROM vbap    " Sales Document: Item Data
    INTO TABLE fp_i_vbap
    FOR ALL ENTRIES IN li_vbrp
    WHERE vbeln =  li_vbrp-aubel AND
          posnr =  li_vbrp-aupos.

    IF sy-subrc = 0.
      SORT fp_i_vbap BY vbeln posnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF fp_i_vbrp IS NOT INITIAL
ENDFORM. "f_get_data_vbap
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_KONV
*&---------------------------------------------------------------------*
* fetching data from konv table
*----------------------------------------------------------------------*
*      -->FP_I_VBRK[] Internal table for vbrp
*      <--FP_I_KONV[] Internal table for vbap
*----------------------------------------------------------------------*
FORM f_get_data_konv  USING    fp_i_vbrk TYPE ty_t_vbrk  "Internal table for vbrk
                      CHANGING fp_i_konv TYPE ty_t_konv. "Internal table for konv

  DATA: li_vbrk TYPE STANDARD TABLE OF ty_vbrk INITIAL SIZE 0. " local internal table

  IF fp_i_vbrk IS NOT INITIAL.

    li_vbrk[] = fp_i_vbrk[].
    SORT li_vbrk BY knumv.
    DELETE ADJACENT DUPLICATES FROM li_vbrk COMPARING knumv.

    SELECT knumv                        " Number of the document condition
           kposn                        " Condition item number
           kschl                        " Condition type
           kbetr                        " Rate (condition amount or percentage)
           waers                        " Currency Key
           ksteu                        " Condition control
      FROM konv                         " Conditions (Transaction Data)
      INTO TABLE fp_i_konv
      FOR ALL ENTRIES IN li_vbrk
      WHERE knumv = li_vbrk-knumv.

    IF sy-subrc = 0.
*--->Begin of Delete for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
*      SORT fp_i_konv BY knumv kschl.
*<---End of Delete for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
*--->Begin of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
      SORT fp_i_konv BY knumv kposn kschl.
*<---End of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF fp_i_vbrk IS NOT INITIAL
ENDFORM. "f_get_data_konv
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_VBPA
*&---------------------------------------------------------------------*
*       Fetching data from vbpa table
*----------------------------------------------------------------------*
*      -->FP_I_VBRP[]  Internal table for vbrp
*      <--FP_I_VBPA[]  Internal table for vbpa
*----------------------------------------------------------------------*
FORM f_get_data_vbpa  USING   fp_i_vbrp TYPE ty_t_vbrp  "Internal table for vbrp
                      CHANGING fp_i_vbpa TYPE ty_t_vbpa. "Internal table for vbpa

  DATA: li_vbrp TYPE STANDARD TABLE OF ty_vbrp INITIAL SIZE 0. " local internal table

  CONSTANTS:lc_parvw TYPE char2  VALUE 'WE', " Parvw of type CHAR2
            lc_posnr TYPE posnr VALUE '000000'. " Item number in VBPA

  IF fp_i_vbrp IS NOT INITIAL.
    li_vbrp[] = fp_i_vbrp[].
*--->Begin of Delete for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
*    SORT li_vbrp BY aubel aupos.
*    DELETE ADJACENT DUPLICATES FROM li_vbrp COMPARING aubel aupos.
*<---End of Delete for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
*--->Begin of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
*    Sort and delete comparing AUBEL to avoid duplicacy
    SORT li_vbrp BY aubel.
    DELETE ADJACENT DUPLICATES FROM li_vbrp COMPARING aubel.
*<---End of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
    SELECT  vbeln " Sales and Distribution Document Number
            posnr " Sales Item Number
            parvw " Partner Function
            kunnr " Customer Number
      FROM vbpa   " Sales Document: Partner
      INTO TABLE fp_i_vbpa
      FOR ALL ENTRIES IN li_vbrp
      WHERE vbeln =  li_vbrp-aubel
       AND  posnr = lc_posnr                                "000000
       AND  parvw = lc_parvw.

    IF sy-subrc = 0.
      SORT  fp_i_vbpa BY vbeln.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF fp_i_vbrp IS NOT INITIAL
ENDFORM. "f_get_data_vbpa
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_KNA1
*&---------------------------------------------------------------------*
*  fetching data from kna1 table
*----------------------------------------------------------------------*
*      -->FP_I_VBPA[]  Internal table for vbpa
*      <--FP_I_KNA1[]  Internal table for kna1
*----------------------------------------------------------------------*
FORM f_get_data_kna1  USING    fp_i_vbpa TYPE ty_t_vbpa  "Internal table for vbpa
                               fp_i_vbrk TYPE ty_t_vbrk  "Internal table for VBRK
                      CHANGING fp_i_kna1 TYPE ty_t_kna1. "Internal table for kna1

  DATA:li_vbpa  TYPE STANDARD TABLE OF ty_vbpa INITIAL SIZE 0, " local internal table
       li_vbrk  TYPE STANDARD TABLE OF ty_vbrk INITIAL SIZE 0, " local internal table
       lwa_vbrk TYPE ty_vbrk,                                 " local work area
       lwa_vbpa TYPE ty_vbpa.                                 " local work area

  IF  fp_i_vbpa IS NOT INITIAL.
    li_vbpa[] = fp_i_vbpa[].
    SORT li_vbpa BY kunnr.
    DELETE ADJACENT DUPLICATES FROM li_vbpa COMPARING kunnr.
  ENDIF. " IF fp_i_vbpa IS NOT INITIAL
*&-- No need to check the details on FP_i_VBRK because if it was
* initial , we would have got an error message at the beginning.
  li_vbrk[] = fp_i_vbrk[].
  SORT li_vbrk BY kunag.
  DELETE ADJACENT DUPLICATES FROM li_vbrk COMPARING kunag.

*&-- Pass the Sold to Party to the li_vbpa
  LOOP AT li_vbrk INTO lwa_vbrk.
    lwa_vbpa-kunnr = lwa_vbrk-kunag.
    APPEND lwa_vbpa TO li_vbpa.
    CLEAR: lwa_vbpa,
           lwa_vbrk.
  ENDLOOP.

  IF li_vbpa IS NOT INITIAL.
    SELECT kunnr " Customer Number
           name1 " Name 1
      FROM kna1  " General Data in Customer Master
      INTO TABLE fp_i_kna1
      FOR ALL ENTRIES IN li_vbpa
      WHERE kunnr = li_vbpa-kunnr.

    IF sy-subrc = 0.
      SORT fp_i_kna1 BY kunnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF.
ENDFORM. "f_get_data_kna1
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_CEPCT
*&---------------------------------------------------------------------*
*      fetching data from cepct table
*----------------------------------------------------------------------*
*      -->FP_I_VBAP[]  Internal table for vbap
*      <--FP_I_CEPCT[] Internal table for cepct
*----------------------------------------------------------------------*
FORM f_get_data_cepct  USING    fp_i_vbap TYPE ty_t_vbap    "Internal table for vbap
                       CHANGING fp_i_cepct TYPE ty_t_cepct. "Internal table for cepct

  DATA: li_vbap TYPE STANDARD TABLE OF ty_vbap INITIAL SIZE 0. " local internal table


  IF fp_i_vbap IS NOT INITIAL.

    li_vbap[] = fp_i_vbap[].
    SORT li_vbap BY prctr.
    DELETE ADJACENT DUPLICATES FROM li_vbap COMPARING prctr.

    SELECT spras " Language Key
           prctr " Profit Center
           ktext " General Name
      FROM cepct " Texts for Profit Center Master Data
      INTO TABLE fp_i_cepct
      FOR ALL ENTRIES IN li_vbap
      WHERE spras = sy-langu
      AND prctr = li_vbap-prctr.

    IF sy-subrc = 0.
      SORT fp_i_cepct BY prctr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF fp_i_vbap IS NOT INITIAL
ENDFORM. "f_get_data_cepct
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_T023
*&---------------------------------------------------------------------*
*      Fetching data from t023 table
*----------------------------------------------------------------------*
*      -->FP_I_VBAP[] Internal table of vbap
*      <--FP_I_T023[] Internal table of t023
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_get_data_t023  USING    fp_i_vbap TYPE ty_t_vbap   " Internal Table For VBAP Table
                      CHANGING fp_i_t023 TYPE ty_t_t023.  " Internal Table For t023 Table

  DATA: li_vbap TYPE STANDARD TABLE OF ty_vbap INITIAL SIZE 0. " local internal table

  IF fp_i_vbap IS NOT INITIAL.
    li_vbap[] = fp_i_vbap[].
    SORT li_vbap BY matkl.
    DELETE ADJACENT DUPLICATES FROM li_vbap COMPARING matkl.

    SELECT spras " Language
           matkl " Material Group
           wgbez " Material Description
      FROM t023t  " Material Groups
      INTO TABLE fp_i_t023
      FOR ALL ENTRIES IN li_vbap
      WHERE spras = sy-langu
      AND   matkl = li_vbap-matkl.

    IF sy-subrc = 0.
      SORT fp_i_t023 BY matkl.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF fp_i_vbap IS NOT INITIAL
ENDFORM. "f_get_data_t023
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_MAKT
*&---------------------------------------------------------------------*
*      Fetching data from makt table
*----------------------------------------------------------------------*
*      -->FP_I_VBRK[] Internal table for vbrk
*      <--FP_I_MAKT[] Internal table for makt
*----------------------------------------------------------------------*
FORM f_get_data_makt  USING    fp_i_vbrp TYPE ty_t_vbrp  "Internal table for vbrk
                      CHANGING fp_i_makt TYPE ty_t_makt. "Internal table for makt

  DATA: li_vbrp TYPE STANDARD TABLE OF ty_vbrp INITIAL SIZE 0. " local internal table

  IF fp_i_vbrp IS NOT INITIAL.

    li_vbrp[] = fp_i_vbrp[].
    SORT li_vbrp BY matnr.
    DELETE ADJACENT DUPLICATES FROM li_vbrp COMPARING matnr.

    SELECT matnr " Material Number
           spras " Language Key
           maktx " Material Description (Short Text)
      FROM makt  " Material Descriptions
      INTO TABLE  fp_i_makt
      FOR ALL ENTRIES IN  li_vbrp
      WHERE matnr =  li_vbrp-matnr AND
            spras = sy-langu.
    IF sy-subrc = 0.
      SORT fp_i_makt BY matnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF fp_i_vbrp IS NOT INITIAL
ENDFORM. "f_get_data_makt
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_FINAL_TABLE
*&---------------------------------------------------------------------*
*      populating final table
*----------------------------------------------------------------------*
*      -->FP_I_VBRK[]  Internal table for vbrk
*      -->FP_I_VBRP[]  Internal table for vbrp
*      -->FP_I_VBAK[]  Internal table for vbak
*      -->FP_I_VBAP[]  Internal table for vbap
*      -->FP_I_KONV[]  Internal table for konv
*      -->FP_I_KNA1[]  Internal table for kna1
*      -->FP_I_CEPCT[] Internal table for cepct
*      -->FP_I_MAKT[]  Internal table for makt
*      -->FP_I_VBPA[]  Internal table for vbpa
*      <--FP_I_FINAL[] Internal table for final
*----------------------------------------------------------------------*
FORM f_populate_final_table  USING    fp_i_vbrk TYPE ty_t_vbrk    "Internal table for vbrk
                                      fp_i_vbrp TYPE ty_t_vbrp    "Internal table for vbrp
                                      fp_i_vbak TYPE ty_t_vbak    "Internal table for vbak
                                      fp_i_vbap TYPE ty_t_vbap    "Internal table for vbap
                                      fp_i_t023 TYPE ty_t_t023    "Internal table for t023
                                      fp_i_konv TYPE ty_t_konv    "Internal table for konv
                                      fp_i_kna1 TYPE ty_t_kna1    "Internal table for kna1
                                      fp_i_cepct TYPE ty_t_cepct  "Internal table for cepct
                                      fp_i_makt TYPE ty_t_makt    "Internal table for makt
                                      fp_i_vbpa TYPE ty_t_vbpa    "Internal table for vbpa
                             CHANGING fp_i_final TYPE ty_t_final. "Internal table for final

  CONSTANTS : lc_zm01 TYPE kscha VALUE 'ZM01'. " Condition type ZM01

  FIELD-SYMBOLS: <lfs_vbrk>  TYPE ty_vbrk,  "filed symbol for vbrk
                 <lfs_vbrp>  TYPE ty_vbrp,  "field symbol for vbrp
                 <lfs_vbak>  TYPE ty_vbak,  "field symbol for vbak
                 <lfs_vbap>  TYPE ty_vbap,  "filed symbol for vbap
                 <lfs_t023>  TYPE ty_t023,  "field symbol for t023
                 <lfs_konv>  TYPE ty_konv,  "field symbol for konv
                 <lfs_kna1>  TYPE ty_kna1,  "field symbol for kna1
                 <lfs_cepct> TYPE ty_cepct, "filed symbol for cepct
                 <lfs_makt>  TYPE ty_makt,  "field symbol for makt
                 <lfs_vbpa>  TYPE ty_vbpa.  "field symbol for vbpa

  DATA:lwa_final TYPE ty_final.             " Local work area for final table
  DATA:lv_date TYPE string.
*--->Begin of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
  CONSTANTS : lv_xudatfm TYPE ddobjname VALUE 'XUDATFM'. " Domain for date format
  DATA : li_dd07v  TYPE STANDARD TABLE OF dd07v. " Table for domain values
  DATA : lv_datin  TYPE i_bdt_ls,                " Date in
         lv_datex  TYPE char10,                  " Date out
         lv_format TYPE char10.                  " Date format

* Date format for the user is fetched from database
  SELECT SINGLE datfm INTO @DATA(lv_datfm)
    FROM usr01
    WHERE bname = @sy-uname.
  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'DDIF_DOMA_GET'
      EXPORTING
        name          = lv_xudatfm
        langu         = sy-langu
      TABLES
        dd07v_tab     = li_dd07v
      EXCEPTIONS
        illegal_input = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      MESSAGE  e886.
    ELSE.
      READ TABLE li_dd07v INTO DATA(lwa_dd07v) WITH KEY domvalue_l = lv_datfm. " Binary search not needed as number of records will be very few
      IF sy-subrc IS INITIAL.
        lv_format =  lwa_dd07v-ddtext.
      ENDIF.
    ENDIF.

  ENDIF.
*<---End of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
  LOOP AT  fp_i_vbrp ASSIGNING <lfs_vbrp> .
    lwa_final-vbeln       = <lfs_vbrp>-vbeln.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = <lfs_vbrp>-vbeln
      IMPORTING
        output = lwa_final-vbeln.

    lwa_final-posnr       = <lfs_vbrp>-posnr.
    lwa_final-fkimg       = <lfs_vbrp>-fkimg.
    lwa_final-netwr       = <lfs_vbrp>-netwr.
    lwa_final-aubel       = <lfs_vbrp>-aubel.
    lwa_final-aupos       = <lfs_vbrp>-aupos.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = <lfs_vbrp>-aupos
      IMPORTING
        output = lwa_final-aupos.

    lwa_final-matnr       = <lfs_vbrp>-matnr.
    lwa_final-zzquoteref  = <lfs_vbrp>-zzquoteref.

    READ TABLE fp_i_vbak ASSIGNING <lfs_vbak>
                             WITH KEY vbeln = <lfs_vbrp>-aubel
                             BINARY SEARCH.
    IF sy-subrc IS INITIAL.

*->Begin of delete for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
*&-- Date to be maintained in user format.
*      CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
*        EXPORTING
*          input  = <lfs_vbak>-erdat
*        IMPORTING
*          output = lwa_final-erdat1.
*<-End of delete for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019

*--->Begin of Delete for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
*   This FM is commneted out to improve the performace of the report
**->Begin of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
*      lv_date = <lfs_vbak>-erdat.
*      CALL FUNCTION '/SAPDII/SPP05_CONVERT_DATE'
*        EXPORTING
*          if_date = lv_date
*        IMPORTING
*          ef_date = lv_date.
*
*      lwa_final-erdat1 = lv_date.
**<-End of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
*<---End of Delete for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
*--->Begin of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
*  Date is converted to the user format
      PERFORM f_convert_date_to_user_format USING    <lfs_vbak>-erdat
                                                     lv_format
                                            CHANGING lwa_final-erdat1.
*<---End of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019

      lwa_final-ernam   = <lfs_vbak>-ernam.
      lwa_final-auart   = <lfs_vbak>-auart.
      lwa_final-vkbur   = <lfs_vbak>-vkbur .
      lwa_final-zzdocref = <lfs_vbak>-zzdocref.
      lwa_final-zzdoctyp = <lfs_vbak>-zzdoctyp.
    ENDIF. " IF sy-subrc IS INITIAL

    READ TABLE fp_i_vbap ASSIGNING <lfs_vbap>
                           WITH KEY vbeln = <lfs_vbrp>-aubel
                                    posnr = <lfs_vbrp>-aupos
                                    BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lwa_final-matkl = <lfs_vbap>-matkl.
      lwa_final-werks = <lfs_vbap>-werks.
      lwa_final-prctr = <lfs_vbap>-prctr.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = <lfs_vbap>-prctr
        IMPORTING
          output = lwa_final-prctr.

      READ TABLE fp_i_t023 ASSIGNING <lfs_t023>
                               WITH KEY matkl = <lfs_vbap>-matkl
                                        BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        lwa_final-wgbez = <lfs_t023>-wgbez.
      ENDIF. " IF sy-subrc IS INITIAL

      READ TABLE fp_i_cepct ASSIGNING <lfs_cepct>
                                WITH KEY prctr = <lfs_vbap>-prctr
                                         BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        lwa_final-ktext = <lfs_cepct>-ktext.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF.

    READ TABLE fp_i_vbpa ASSIGNING <lfs_vbpa>
                              WITH KEY vbeln = <lfs_vbrp>-aubel
                                       BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lwa_final-kunnr = <lfs_vbpa>-kunnr.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = <lfs_vbpa>-kunnr
        IMPORTING
          output = lwa_final-kunnr.

      READ TABLE fp_i_kna1 ASSIGNING <lfs_kna1>
                              WITH KEY kunnr = <lfs_vbpa>-kunnr
                                       BINARY SEARCH .
      IF sy-subrc IS INITIAL.
        lwa_final-name12 =  <lfs_kna1>-name1.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF.

    READ TABLE fp_i_makt ASSIGNING <lfs_makt>
                               WITH KEY matnr = <lfs_vbrp>-matnr
                                        BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lwa_final-maktx =  <lfs_makt>-maktx.
    ENDIF. " IF sy-subrc IS INITIAL

    READ TABLE fp_i_vbrk ASSIGNING <lfs_vbrk>
                          WITH KEY vbeln = <lfs_vbrp>-vbeln
                                   BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lwa_final-fkart = <lfs_vbrk>-fkart.
      lwa_final-waerk = <lfs_vbrk>-waerk.
      lwa_final-vkorg = <lfs_vbrk>-vkorg.
      lwa_final-knumv = <lfs_vbrk>-knumv.

*->Begin of delete for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
*      CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
*        EXPORTING
*          input  = <lfs_vbrk>-fkdat
*        IMPORTING
*          output = lwa_final-fkdat.
*
*      CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
*        EXPORTING
*          input  = <lfs_vbrk>-erdat
*        IMPORTING
*          output = lwa_final-erdat.
*<-Begin of delete for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
*--->Begin of Delete for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
*   This FM is commneted out to improve the performace of the report
**->Begin of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
*      lv_date = <lfs_vbrk>-erdat.
*      CALL FUNCTION '/SAPDII/SPP05_CONVERT_DATE'
*        EXPORTING
*          if_date = lv_date
*        IMPORTING
*          ef_date = lv_date.
*
*      lwa_final-erdat = lv_date.
*
*      lv_date = <lfs_vbrk>-fkdat.
*
*      CALL FUNCTION '/SAPDII/SPP05_CONVERT_DATE'
*        EXPORTING
*          if_date = lv_date
*        IMPORTING
*          ef_date = lv_date.
*      lwa_final-fkdat = lv_date.
**<-Begin of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
*<---End of Delete for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
*--->Begin of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
*  Date is converted to the user format
      PERFORM f_convert_date_to_user_format USING    <lfs_vbrk>-erdat
                                                     lv_format
                                            CHANGING lwa_final-erdat.


      PERFORM f_convert_date_to_user_format USING    <lfs_vbrk>-fkdat
                                                     lv_format
                                            CHANGING lwa_final-fkdat.
*<---End of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
      lwa_final-netwr1 = <lfs_vbrk>-netwr.
      lwa_final-kunag = <lfs_vbrk>-kunag.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = <lfs_vbrk>-kunag
        IMPORTING
          output = lwa_final-kunag.

      lwa_final-bstnk_vf = <lfs_vbrk>-bstnk_vf.

*--->Begin of Delete for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
*      READ TABLE fp_i_konv ASSIGNING <lfs_konv>
*                              WITH KEY knumv = <lfs_vbrk>-knumv
*                                       kschl = lc_zm01
**->Begin of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
*                                       kposn = <lfs_vbrp>-posnr
**->End of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
*                                       BINARY SEARCH.
*<---End of Delete for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
*--->Begin of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
*    The key fields have been re-arranged to match the sort statement on I_KONV
      READ TABLE fp_i_konv ASSIGNING <lfs_konv> WITH KEY
                                       knumv = <lfs_vbrk>-knumv
                                       kposn = <lfs_vbrp>-posnr
                                       kschl = lc_zm01
                                       BINARY SEARCH.
*<---End of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
      IF sy-subrc IS INITIAL.
        lwa_final-ksteu = <lfs_konv>-ksteu.
        IF <lfs_konv>-waers IS INITIAL.
          lwa_final-kbetr = <lfs_konv>-kbetr / 10.
        ELSE.
          lwa_final-kbetr = <lfs_konv>-kbetr.
        ENDIF.
      ENDIF. " IF sy-subrc IS INITIAL

      IF <lfs_kna1> IS ASSIGNED.
        UNASSIGN : <lfs_kna1>.
      ENDIF.
      READ TABLE fp_i_kna1 ASSIGNING <lfs_kna1>
                           WITH KEY kunnr = <lfs_vbrk>-kunag.
      IF sy-subrc IS INITIAL.
        lwa_final-name1 = <lfs_kna1>-name1.
      ENDIF.

    ENDIF.

    APPEND lwa_final TO fp_i_final.
    CLEAR lwa_final.
  ENDLOOP. " LOOP AT fp_i_vbrp ASSIGNING <lfs_vbrp>
ENDFORM. "f_populate_final_table

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_FIELDCAT
*&---------------------------------------------------------------------*
*       PREPARE FIELDCATALOG FOR ALV
*----------------------------------------------------------------------*
*      <--FP_I_FIELDCAT[]  PREPARE FIELDCATALOG FOR ALV
*-----------------------------------------------------------------*
FORM f_prepare_fieldcat USING fp_i_emikschl TYPE ty_t_emikschl.

  TYPE-POOLS slis.
  DATA:
    lt_fcat    TYPE lvc_t_fcat,                   " slis_fieldcat_alv,
    ls_fcat    TYPE lvc_s_fcat,                   " slis_fieldcat_alv
    lwa_final  TYPE ty_final,                     " Local work area for final table
    lwa_emi    TYPE fkk_ranges,                   " Local Work area For Emi Tables
    li_output  TYPE REF TO data,                  " Local Internal Table for Output
    lwa_output TYPE REF TO data,                  " Local Work area for Output Data
    li_fcat    TYPE slis_t_fieldcat_alv,          " Local Internal Table For Field Catalog
    lwa_fcat   TYPE slis_fieldcat_alv,            " Local work area For Field Catalog
    lwa_layout TYPE slis_layout_alv.

  FIELD-SYMBOLS: <lfs_output_t> TYPE STANDARD TABLE ,    " Local Field Symbol For Output
                 <lfs_konv>     TYPE ty_konv,             "field symbol for konv.
                 <lfs_output>   TYPE any,                 " Local field Symbol for output
                 <lfs_field>    TYPE any.                 " Local Field Symbol For Field

  CONSTANTS: lc_final      TYPE  lvc_tname  VALUE  'I_FINAL', " Local Constant for Final Table
             lc_vbeln      TYPE  lvc_fname  VALUE  'VBELN',   " Local Constant for Billing Doucment
             lc_posnr      TYPE  lvc_fname  VALUE  'POSNR',   " Local Constant for Billing item
             lc_knumv      TYPE  lvc_fname  VALUE  'KNUMV',   " Local Constant for Agreement Information
             lc_fkimg      TYPE  lvc_fname  VALUE  'FKIMG ',  " Local Constant for Actual billed quantity
             lc_netwr      TYPE  lvc_fname  VALUE  'NETWR',   " Local Constant for  Net value of the billing item in document currency
             lc_erdat      TYPE  lvc_fname  VALUE  'ERDAT',   " Local Constant for  Date on Which Record Was Created
             lc_aubel      TYPE  lvc_fname  VALUE  'AUBEL',   " Local Constant for   Sales Document
             lc_aupos      TYPE  lvc_fname  VALUE  'AUPOS',   " Local Constant for  Sales Document Item
             lc_zzquoteref TYPE  lvc_fname  VALUE  'ZZQUOTEREF', "Local Constant for quntity ref number
             lc_zzdocref   TYPE  lvc_fname  VALUE  'ZZDOCREF', " Local Constant for  Legacy Doc Ref
             lc_zzdoctyp   TYPE  lvc_fname  VALUE  'ZZDOCTYP', " Local Constant for  Ref Doc type
             lc_werks      TYPE  lvc_fname  VALUE  'WERKS',   " Local Constant for  plant
             lc_prctr      TYPE lvc_fname   VALUE  'PRCTR',   " Local Constant for  Profit Center
             lc_ktext      TYPE lvc_fname   VALUE  'KTEXT',   " Local Constant for  General text
             lc_matnr      TYPE lvc_fname   VALUE  'MATNR',   " Local Constant for  Material Number
             lc_maktx      TYPE lvc_fname   VALUE  'MAKTX',   " Local Constant for  Material Description
             lc_matkl      TYPE lvc_fname   VALUE  'MATKL',   " Local Constant for  Material Group
             lc_wgbez      TYPE lvc_fname   VALUE  'WGBEZ',   " Local Constant for  Material Group description
             lc_erdat1     TYPE lvc_fname   VALUE  'ERDAT1',  " Local Constant for  Creation Date
             lc_kbetr      TYPE lvc_fname   VALUE  'KBETR',   " Local Constant for  Rate (condition amount or percentage)
             lc_ksteu      TYPE lvc_fname   VALUE  'KSTEU',   " Local Constant for  Condition control
             lc_vkorg      TYPE lvc_fname   VALUE  'VKORG',   " Local Constant for  Sales Org
             lc_fkart      TYPE lvc_fname   VALUE  'FKART',   " Local Constant for  Billing Type
             lc_waerk      TYPE lvc_fname   VALUE  'WAERK',   " Local Constant for  currency
             lc_fkdat      TYPE lvc_fname   VALUE  'FKDAT',   " Local Constant for  Invoice Creation Date
             lc_netwr1     TYPE lvc_fname   VALUE  'NETWR1',  " Local Constant for  Net value
             lc_kunag      TYPE lvc_fname   VALUE  'KUNAG',   " Local Constant for  Sold To Party
             lc_name1      TYPE lvc_fname   VALUE  'NAME1',   " Local Constant for  Name1
             lc_ernam      TYPE lvc_fname   VALUE  'ERNAM',   " Local Constant for  Name of Person Who Created the Object
             lc_auart      TYPE lvc_fname   VALUE  'AUART',   " Local Constant for  Sales Document Type
             lc_bstnk_vf   TYPE lvc_fname  VALUE   'BSTNK_VF', " Local Constant for  PO#
             lc_vkbur      TYPE lvc_fname  VALUE   'VKBUR',   " Local Constant for  Sales Office
             lc_kunnr      TYPE lvc_fname  VALUE   'KUNNR',   " Local Constant for  Customer number
             lc_name12     TYPE lvc_fname  VALUE   'NAME12',  " Local Constant for  Name
             lc_save       TYPE char1      VALUE    'A',     " used in alv for user save
             lc_x          TYPE char1      VALUE    'X',     " used in function module

*->Begin of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
             lc_ksteu_cc   TYPE char6 VALUE 'KSTEU_'.
*<-End of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019

  ls_fcat-fieldname = lc_vbeln . "sales document
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 10.
  ls_fcat-scrtext_l = 'Billing Document'(001).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname = lc_posnr . "sales document item"
  ls_fcat-tabname   =  lc_final.
  ls_fcat-outputlen = 6.
  ls_fcat-scrtext_l = 'Item'(002).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname = lc_knumv ."Doc condition No
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 10.
  ls_fcat-scrtext_l ='Doc condition No'(003).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname = lc_fkimg. "Billed Quantity
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 17.
  ls_fcat-scrtext_l = 'Billed Quantity'(004).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname =  lc_netwr. "netvalue
  ls_fcat-tabname   =  lc_final.
  ls_fcat-outputlen = 18.
  ls_fcat-scrtext_l = 'Net value (item level)'(005).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname = lc_erdat. "Invoice Creation Date
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 10.
  ls_fcat-scrtext_l = 'Invoice Creation Date'(006).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname =  lc_aubel. "Sales Document
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 10.
  ls_fcat-scrtext_l = 'Sales Document'(007).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname = lc_aupos. "Sales Document Item
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 6.
  ls_fcat-scrtext_l = 'Sales Document Item'(008).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname =  lc_zzquoteref. "Qtn Ref No
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 18.
  ls_fcat-scrtext_l = 'Qtn Ref No'(009).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname = lc_zzdocref. "Legacy Doc Ref
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 18.
  ls_fcat-scrtext_l = 'Legacy Doc Ref'(010).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname = lc_zzdoctyp. "Ref Doc type
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 2.
  ls_fcat-scrtext_l = 'Ref Doc type'(011).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname =  lc_werks. "Plant
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 10.
  ls_fcat-scrtext_l = 'Plant'(012).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname = lc_prctr. "profit center
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 10.
  ls_fcat-scrtext_l = 'Profit Center'(013).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname =  lc_ktext. "Profit Center description
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 20.
  ls_fcat-scrtext_l = 'Profit Center Description'(014).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname =  lc_matnr . "material
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 18.
  ls_fcat-scrtext_l = 'Material'(015).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname =  lc_maktx . "Material Description
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 40.
  ls_fcat-scrtext_l = 'Material Description'(016).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname =  lc_matkl. "Material Group
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 9.
  ls_fcat-scrtext_l = 'Material Group'(017).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname =  lc_wgbez. "Material Group Description
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 20.
  ls_fcat-scrtext_l = 'Material Group Description'(018).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname =  lc_erdat1 . "SO Creation Date
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 10.
  ls_fcat-scrtext_l = 'SO Creation Date'(019).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname =  lc_kbetr . "ZM01 in Rate %
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 11.
  ls_fcat-scrtext_l = 'ZM01 in Rate %'(020).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.
  ls_fcat-fieldname =  lc_ksteu . "condition control for ZM01
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 1.
  ls_fcat-scrtext_l = 'Condition Control For ZM01'(021).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname =  lc_vkorg . "Sales organization
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 4.
  ls_fcat-scrtext_l = 'Sales Org'(022).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname = lc_fkart . "Billing type
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 4.
  ls_fcat-scrtext_l = 'Billing Type'(023).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.
  ls_fcat-fieldname = lc_waerk . "Currency
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 5.
  ls_fcat-scrtext_l = 'Currency'(024).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.
  ls_fcat-fieldname = lc_fkdat . "Billing date
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 10.
  ls_fcat-scrtext_l = 'Billing Date'(025).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname = lc_netwr1 . "Net Value of Invoice
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 105.
  ls_fcat-scrtext_l = 'Net Value of Invoice(Header)'(026).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname = lc_kunag . "Sold To Party
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 10.
  ls_fcat-scrtext_l = 'Sold To Party'(027).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname = lc_name1 . "Sold To Name
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 35.
  ls_fcat-scrtext_l = 'Sold To Name'(028).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname = lc_ernam . "SO Created by
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 12.
  ls_fcat-scrtext_l = 'So Created By'(029).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname = lc_auart. "Sales Order type
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 4.
  ls_fcat-scrtext_l = 'Sales Order Type'(030).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname = lc_bstnk_vf . "PO#
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 35.
  ls_fcat-scrtext_l = 'PO#'(031).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname = lc_vkbur . "Sales Office
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 4.
  ls_fcat-scrtext_l = 'Sales Office'(032).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname = lc_kunnr. "Ship to Party
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 10.
  ls_fcat-scrtext_l = 'Ship to Party'(033).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname = lc_name12  . "Ship to party Name
  ls_fcat-tabname   = lc_final.
  ls_fcat-outputlen = 35.
  ls_fcat-scrtext_l = 'Ship to party Name'(034).
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  READ TABLE lt_fcat WITH KEY fieldname = lc_ksteu TRANSPORTING NO FIELDS.
  IF sy-subrc IS INITIAL.
    DATA(lv_position) = sy-tabix + 1.
    LOOP AT fp_i_emikschl INTO lwa_emi.
      ls_fcat-fieldname = lwa_emi-low.
      ls_fcat-tabname   = lc_final.
      ls_fcat-outputlen = 11.
      CONCATENATE lwa_emi-low
                  lwa_emi-high
             INTO ls_fcat-scrtext_l
             SEPARATED BY space.
      INSERT ls_fcat INTO lt_fcat INDEX lv_position.
      lv_position = lv_position + 1.
      CLEAR: ls_fcat.

*->Begin of delete for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
*            lwa_emi.
*<-End of delete for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019

*->Begin of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
* Adding new column for condition control
      CONCATENATE lc_ksteu_cc
                  lwa_emi-low
                 INTO ls_fcat-fieldname.
      ls_fcat-tabname   = lc_final.
      ls_fcat-outputlen = 28.
      CONCATENATE TEXT-035
                  lwa_emi-low
                 INTO ls_fcat-scrtext_l
                 SEPARATED BY space.
      INSERT ls_fcat INTO lt_fcat INDEX lv_position.
      lv_position = lv_position + 1.
      CLEAR: ls_fcat,
             lwa_emi.
*<-End of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
    ENDLOOP. " LOOP AT i_emikschl INTO lwa_emi

  ENDIF.

  CALL METHOD cl_alv_table_create=>create_dynamic_table "Here creates the internal table dynamcally
    EXPORTING
      it_fieldcatalog  = lt_fcat
      i_length_in_byte = lc_x
    IMPORTING
      ep_table         = li_output.

* Assign the field symbol with dynmica internal table
  ASSIGN li_output->* TO <lfs_output_t>.

*Create dynamic work area and assign to FS

  CREATE DATA lwa_output LIKE LINE OF <lfs_output_t>.
  ASSIGN lwa_output->* TO <lfs_output>.

  LOOP AT lt_fcat INTO ls_fcat .
    lwa_fcat-fieldname = ls_fcat-fieldname . "Ship to Party
    lwa_fcat-tabname   = ls_fcat-tabname.
    lwa_fcat-seltext_l = ls_fcat-scrtext_l.
    APPEND lwa_fcat TO li_fcat.
    CLEAR lwa_fcat.
  ENDLOOP. " LOOP AT lt_fcat INTO ls_fcat

*
  LOOP AT i_final INTO lwa_final.
    LOOP AT fp_i_emikschl INTO DATA(lwa_emikschl).
      ASSIGN COMPONENT lwa_emikschl-low OF STRUCTURE <lfs_output> TO <lfs_field>.
      IF <lfs_field> IS ASSIGNED.
        READ TABLE i_konv ASSIGNING <lfs_konv> ##WARN_OK
                       WITH KEY knumv = lwa_final-knumv
                                kposn = lwa_final-posnr
                                kschl = lwa_emikschl-low
*--->Begin of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
                                BINARY SEARCH.
*    Populate condition value
*<---End of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
        IF sy-subrc IS INITIAL.
          IF <lfs_konv>-waers IS INITIAL.
            <lfs_field> = <lfs_konv>-kbetr / 10.
            UNASSIGN: <lfs_field>.
          ELSE.
            <lfs_field> = <lfs_konv>-kbetr.
            UNASSIGN: <lfs_field>.
          ENDIF.
*--->Begin of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
*     Populate condition control
          CONCATENATE lc_ksteu_cc
                      lwa_emikschl-low
                      INTO DATA(lv_fldname1).
          ASSIGN COMPONENT lv_fldname1 OF STRUCTURE <lfs_output> TO <lfs_field>.
          IF <lfs_field> IS ASSIGNED.
            IF <lfs_konv>-ksteu IS NOT INITIAL.
              <lfs_field> = <lfs_konv>-ksteu.
              UNASSIGN: <lfs_field>.
              CLEAR : lv_fldname1.
            ENDIF.
          ENDIF.
*<---End of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF.
*--->Begin of Delete for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
**->Begin of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
** Populating condition control values
*      CONCATENATE lc_ksteu_cc
*                  lwa_emikschl-low
*                  INTO DATA(lv_fldname).
*      ASSIGN COMPONENT lv_fldname OF STRUCTURE <lfs_output> TO <lfs_field>.
*      IF <lfs_field> IS ASSIGNED.
*        READ TABLE i_konv ASSIGNING <lfs_konv> ##WARN_OK
*                           WITH KEY knumv = lwa_final-knumv
*                                    kposn = lwa_final-posnr
*                                    kschl = lwa_emikschl-low.
*        IF sy-subrc IS INITIAL.
*          IF <lfs_konv>-ksteu IS NOT INITIAL.
*            <lfs_field> = <lfs_konv>-ksteu.
*            UNASSIGN: <lfs_field>.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*      CLEAR:lwa_emikschl.
**<-End of insert for D3_OTC_RDD_0139 by u105652 on 06-Aug-2019
*<---End of Delete for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
    ENDLOOP.

    IF <lfs_output> IS ASSIGNED.
*&-- We cannot use MOVE since <lfs_output> created by dynamic assignment .
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = lwa_final-knumv
        IMPORTING
          output = lwa_final-knumv.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = lwa_final-posnr
        IMPORTING
          output = lwa_final-posnr.
      MOVE-CORRESPONDING lwa_final TO <lfs_output>.
    ENDIF.

    APPEND <lfs_output> TO <lfs_output_t>.
    CLEAR: <lfs_output>.
  ENDLOOP. " LOOP AT i_final INTO lwa_final

  lwa_layout-zebra = abap_on.
  lwa_layout-colwidth_optimize = abap_on.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      it_fieldcat        = li_fcat
      i_save             = lc_save
      is_layout          = lwa_layout
    TABLES
      t_outtab           = <lfs_output_t>.

ENDFORM. "f_prepare_fieldcat
*--->Begin of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_DATE_TO_USER_FORMAT
*&---------------------------------------------------------------------*
*       Convert date to user format
*----------------------------------------------------------------------*
*      -->FP_DATIN    Date in
*      -->FP_FORMAT    Date format
*      <--FP_DATEX   Date out
*----------------------------------------------------------------------*
FORM f_convert_date_to_user_format  USING    fp_datin  TYPE i_bdt_ls
                                             fp_format TYPE char10
                                    CHANGING fp_datex  TYPE char10.
  DATA: lv_i       TYPE i,
        lv_fmt(10) TYPE c.

  CLEAR fp_datex.
  lv_fmt = fp_format.
  IF lv_fmt CS 'YYYY'.
    WRITE fp_datin(4)   TO fp_datex+sy-fdpos(4).
  ELSEIF lv_fmt CS 'YY'.
    WRITE fp_datin+2(2) TO fp_datex+sy-fdpos(2).
  ENDIF.
  IF lv_fmt CS 'MM'.
    WRITE fp_datin+4(2) TO fp_datex+sy-fdpos(2).
  ENDIF.
  IF lv_fmt CS 'DD'.
    WRITE fp_datin+6(2) TO fp_datex+sy-fdpos(2).
  ENDIF.
* Trennzeichen in Datex einbauen
  lv_i = 0.
  WHILE NOT lv_fmt IS INITIAL.
    IF lv_fmt(1) NA 'YMD'.
      WRITE lv_fmt(1) TO fp_datex+lv_i(1).
    ENDIF.
    SHIFT lv_fmt LEFT.
    lv_i = lv_i + 1.
  ENDWHILE.
ENDFORM.
*<---End of Insert for SCTASK0873868 D3_OTC_RDD_0139 by U033959 on 24-Sep-2019
