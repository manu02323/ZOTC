*&---------------------------------------------------------------------*
*& Function Module  ZOTC_GET_CUSTOMER_SALES_REP
*&---------------------------------------------------------------------*
************************************************************************
* FM         :  ZOTC_GET_CUSTOMER_SALES_REP                            *
* FG         :  ZOTC_0028_PRICING_REP_FG                               *
* TITLE      :  Get Ship-to/Sold-to for Sales Representative           *
* DEVELOPER  :  ROHIT VERMA                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_RDD_0028_Pricing Report for Mass Price Upload      *
*----------------------------------------------------------------------*
* DESCRIPTION:  FM to get Ship-to/Sold-to for Sales Representative     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 22-Jul-2013 RVERMA   E1DK910844 INITIAL DEVELOPMENT - CR#410         *
*----------------------------------------------------------------------*
* 06-Sep-2013 RVERMA   E1DK910844 Defect#2056: When putting Sales      *
*                                 Representative in selection parameter*
*                                 is considering all the customers     *
*                                 irrespective of Distribution Channel *
*&---------------------------------------------------------------------*
* 25-Mar-2014 SNIGAM   E1DK912987 Defect#1302: Pricing Report not      *
*                                 fetching correct Sold-to Ship-to list*
*                                 based on territory. To rectify this, *
*                                 remove the condition of PARZA as'0000'
*&---------------------------------------------------------------------*
* 19-Aug-2014 RVERMA   E1DK914681 Defect#1531: If there is Ship-to     *
*                                 field at selection screen than on    *
*                                 entering Sales Rep, Ship-to field    *
*                                 should be populated with all values  *
*                                 of Sold-to and Ship-to both.         *
*&---------------------------------------------------------------------*

FUNCTION zotc_get_customer_sales_rep.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_SALES_REP) TYPE  KUNN2
*"     REFERENCE(IM_SALES_IDN) TYPE  CHAR02
*"     REFERENCE(IM_SALES_ORG) TYPE  PIQ_SELOPT_T OPTIONAL
*"     REFERENCE(IM_SALES_DIS) TYPE  PIQ_SELOPT_T OPTIONAL
*"  EXPORTING
*"     REFERENCE(EX_CUSTOMER) TYPE  PIQ_SELOPT_T
*"  EXCEPTIONS
*"      INVALID_SALES_IDN
*"      INVALID_SALES_REP
*"      DATA_NOT_FOUND
*"----------------------------------------------------------------------

  DATA:
    li_knvp      TYPE ty_t_knvp,   "Internal Table of KNVP
    li_kna1      TYPE ty_t_kna1,   "Internal Table of KNA1
    li_tvarvc    TYPE ty_t_tvarvc, "TVARVC table
    lv_kunn2     TYPE kunn2,       "Sales Representative
    lv_ktokd     TYPE ktokd,       "Customer Account Group
    lv_parvw_sr  TYPE parvw,       "Sales Rep Partner Function
    lv_spart     TYPE spart,       "Division
*    lv_parza     TYPE parza,       "Partner counter  "Commented by SNIGAM: CR1302 : 3/26/2014
    lwa_customer TYPE selopt,      "Select Option Structure

*&--BOC for Defect#2056 on 06-Sep-2013
    li_sales_org TYPE RANGE OF vkorg, "Sales Org Range Table
    li_sales_dis TYPE RANGE OF vtweg. "Sales Distr Chn Range Table
*&--EOC for Defect#2056 on 06-Sep-2013

  FIELD-SYMBOLS:
    <lfs_kna1>   TYPE ty_kna1,    "Field Symbol for KNA1
    <lfs_tvarvc> TYPE ty_tvarvc,  "TVARVC workarea

*&--BOC: Defect#1531 : RVERMA : 19-Aug-2014
    <lfs_knvp>   TYPE ty_knvp.     "Field Symbol for KNVP
*&--EOC: Defect#1531 : RVERMA : 19-Aug-2014


*&--Check if sales identification has value other than 01 or 02 then
*&--raise an excpetion
  IF im_sales_idn NE c_sales_idn_01 AND
     im_sales_idn NE c_sales_idn_02.
    RAISE invalid_sales_idn.
  ENDIF.

  CLEAR ex_customer.

*&--Check Sales representative value is valid or not, if invalid then
*&--raise an exception
  IF im_sales_rep IS NOT INITIAL.
    SELECT SINGLE kunnr
      FROM kna1
      INTO lv_kunn2
      WHERE kunnr EQ im_sales_rep.
    IF sy-subrc NE 0.
      RAISE invalid_sales_rep.
    ENDIF.
  ENDIF.

*&--Get Values from TVARVC tables
  SELECT name type numb
         sign opti low
    FROM tvarvc
    INTO TABLE li_tvarvc
    WHERE name IN (c_name_ktokd_ag,
*                   c_name_ktokd_we,  "Commented by RVERMA : Defect#1531 : 19-Aug-2014
                   c_name_parvw_sr,
*                   c_name_parza, " Commented by SNIGAM : CR1302 : 3/25/2014
                   c_name_spart)
      AND type EQ c_type_p
      AND numb EQ c_numb_00.

  IF sy-subrc EQ 0.
    SORT li_tvarvc BY name.
*&--Check if Sales identification is 01 (i.e. Sold-to) then KTOKD will be Z001;
*&--and if sales identification is 02 (i.e. Ship-to) then KTOKD will be Z002.
    IF im_sales_idn EQ c_sales_idn_01.
      READ TABLE li_tvarvc ASSIGNING <lfs_tvarvc>
                           WITH KEY name = c_name_ktokd_ag
                           BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_ktokd = <lfs_tvarvc>-low+0(4).
      ENDIF.

    ELSEIF im_sales_idn EQ c_sales_idn_02.
*&--BOC: Defect#1531 : RVERMA : 19-Aug-2014
*&--Defect#1531: If sales identification is 02 (i.e. Ship-to) then all the
*&--Ship-to and Sold-to needs to passed because Sold-to can be
*&--Ship-to Party.
*      READ TABLE li_tvarvc ASSIGNING <lfs_tvarvc>
*                           WITH KEY name = c_name_ktokd_we
*                           BINARY SEARCH.
*      IF sy-subrc EQ 0.
*        lv_ktokd = <lfs_tvarvc>-low+0(4).
*      ENDIF.

      CLEAR lv_ktokd.
*&--EOC: Defect#1531 : RVERMA : 19-Aug-2014
    ENDIF.

*&--Get Partner Function value for Sales Representative
    READ TABLE li_tvarvc ASSIGNING <lfs_tvarvc>
                         WITH KEY name = c_name_parvw_sr
                         BINARY SEARCH.
    IF sy-subrc EQ 0.
      lv_parvw_sr = <lfs_tvarvc>-low+0(2).
    ENDIF.

* BOC : SNIGAM : CR1302 : 3/25/2014
**&--Get Partner Counter value
*    READ TABLE li_tvarvc ASSIGNING <lfs_tvarvc>
*                         WITH KEY name = c_name_parza
*                         BINARY SEARCH.
*    IF sy-subrc EQ 0.
*      lv_parza = <lfs_tvarvc>-low+0(3).
*    ENDIF.
* EOC : SNIGAM : CR1302 : 3/25/2014

*&--Get Division value
    READ TABLE li_tvarvc ASSIGNING <lfs_tvarvc>
                         WITH KEY name = c_name_spart
                         BINARY SEARCH.
    IF sy-subrc EQ 0.
      lv_spart = <lfs_tvarvc>-low+0(2).
    ENDIF.
  ENDIF.

  IF lv_parvw_sr IS NOT INITIAL. "AND
*     lv_ktokd    IS NOT INITIAL.  "Commented by RVERMA : Defect#1531 : 19-Aug-2014

*&--BOC for Defect#2056 on 06-Sep-2013

*&--Populate Sales Organization range table
    APPEND LINES OF im_sales_org TO li_sales_org.

*&--Populate Sales Distribution Channel range table
    APPEND LINES OF im_sales_dis TO li_sales_dis.

*&--EOC for Defect#2056 on 06-Sep-2013

*&--Fetch Customer data from KNVP
    SELECT kunnr vkorg
           vtweg spart
           parvw parza
           kunn2
      FROM knvp
      INTO TABLE li_knvp
      WHERE vkorg IN li_sales_org  "Added for Defect#2056
        AND vtweg IN li_sales_dis  "Added for Defect#2056
        AND spart EQ lv_spart
        AND parvw EQ lv_parvw_sr
*        AND parza EQ lv_parza   "Commented by SNIGAM : CR1302 : 3/25/2014
        AND kunn2 EQ im_sales_rep.

    IF sy-subrc EQ 0.

*&--Sort and Delete Adjacent based on Customer (KUNNR)
      SORT li_knvp BY kunnr.
      DELETE ADJACENT DUPLICATES FROM li_knvp
                            COMPARING kunnr.

      IF li_knvp[] IS NOT INITIAL.

*&--BOC: Defect#1531 : RVERMA : 19-Aug-2014
        IF lv_ktokd  IS NOT INITIAL.
*&--EOC: Defect#1531 : RVERMA : 19-Aug-2014

*&--Filter out values from KNA1 based on KTOKD (or Sales Identification)
          SELECT kunnr
            FROM kna1
            INTO TABLE li_kna1
            FOR ALL ENTRIES IN li_knvp
            WHERE kunnr EQ li_knvp-kunnr
              AND ktokd EQ lv_ktokd.

          IF sy-subrc EQ 0.

*&--Populate all the customers to exporting range table of customer
            LOOP AT li_kna1 ASSIGNING <lfs_kna1>.

              lwa_customer-sign = c_sign_i.
              lwa_customer-option = c_option_eq.
              lwa_customer-low = <lfs_kna1>-kunnr.

              APPEND lwa_customer TO ex_customer.
              CLEAR lwa_customer.

            ENDLOOP.  "LI_KNA1

          ENDIF.  "SY-SUBRC check for SELECT on KNA1

*&--BOC: Defect#1531 : RVERMA : 19-Aug-2014
        ELSE.
*&--When KTOKD is initial than populate all the ship-to and sold-to
*&--Populate all the customers to exporting range table of customer
          LOOP AT li_knvp ASSIGNING <lfs_knvp>.

            lwa_customer-sign = c_sign_i.
            lwa_customer-option = c_option_eq.
            lwa_customer-low = <lfs_knvp>-kunnr.

            APPEND lwa_customer TO ex_customer.
            CLEAR lwa_customer.

          ENDLOOP.  "LI_KNA1

        ENDIF.  "LV_KTOKD IS NOT INITIAL.
*&--EOC: Defect#1531 : RVERMA : 19-Aug-2014

      ENDIF.  "LI_KNVP[] IS NOT INITIAL

    ENDIF.  "SY-SUBRC check for SELECT on KNVP

  ENDIF.  "LV_PARVW_SR and LV_KTOKD IS NOT INITIAL

*&--If there is no data in EX_CUSTOMER then raise an exception
  IF ex_customer[] IS INITIAL.
    RAISE data_not_found.
  ENDIF.

ENDFUNCTION.
