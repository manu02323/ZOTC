*&---------------------------------------------------------------------*
*&  Include           ZOTCN0008O_REBATE_REPORT_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCR0008O_REBATE_REPORT_FORM                          *
* TITLE      :  REBATE REPORT (PRICING)                                *
* DEVELOPER  :  ROHIT VERMA                                            *
* OBJECT TYPE:  INCLUDE                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0008_REBATE_REPORT                               *
*----------------------------------------------------------------------*
* DESCRIPTION: This Include is for Subroutine of Report                *
*               ZOTCR0008O_REBATE_REPORT_TOP (Rebate Report).          *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 09-MAR-2012 RVERMA   E1DK901226 INITIAL DEVELOPMENT                  *
*&---------------------CR#6--------------------------------------------*
* 17-APR-2012 RVERMA   E1DK901226 Addition of fields Payer Desc,       *
*                                 Ship-to-Party Desc, Material Desc,   *
*                                 Rebate Basis, Currency Key in ALV    *
*                                 output. Changes in the fetching      *
*                                 logic of Ship-to-Party Value         *
* 21-MAY-2012 RVERMA   E1DK901226 Fetching field for condition currency*
*                                 changed from WAERS to KWAEH          *
*&---------------------CR#34-------------------------------------------*
* 12-JUN-2012 RVERMA   E1DK901226 Adding fields KVGR1(GPO Code) & KVGR2*
*                                 (IDN Code) and their description     *
*                                 fields in the report and removing    *
*                                 leading zeroes from customer material*
*                                 field and dividing dividing          *
*                                 KONV-KBETR by 10.                    *
*&---------------------CR#67-------------------------------------------*
* 26-JUL-2012 RVERMA   E1DK901226 Adding fields Sold-to-Party,         *
*                                 Sold-to-Party Description,           *
*                                 Product Division, Sales Amount fields*
*                                 in the report.                       *
*&---------------------------------------------------------------------*
* 09-May-2013 RVERMA   E1DK910294 INC0092335/Defect#3746: Performance  *
*                                 issue with select query on table KNVV*
*&---------------------------------------------------------------------*
*19-Aug-2019  SMUKHER  E1SK901425 HANAtization changes                 *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_COMPANYCODE_VALIDATION
*&---------------------------------------------------------------------*
*       Subroutine for validation of Company Code entered
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_companycode_validation .

*&--Local Variable declaration
  DATA: lv_bukrs TYPE bukrs.    "Company code

*&--Validation for Company Code
  IF s_bukrs IS NOT INITIAL.
    SELECT bukrs UP TO 1 ROWS
      INTO lv_bukrs
      FROM t001
      WHERE bukrs IN s_bukrs.
    ENDSELECT.

    IF sy-subrc NE 0 OR
       lv_bukrs IS INITIAL.
      MESSAGE e001
      WITH 'Company Code'(002).
    ENDIF.
  ENDIF.

ENDFORM.                    " F_COMPANYCODE_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_SALESORG_VALIDATION
*&---------------------------------------------------------------------*
*       Subroutine for validation of Sales Organization entered
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_salesorg_validation .

*&--Local Variable declaration
  DATA: lv_vkorg TYPE vkorg.    "Sales Organzation

*&--Validation for Sales Organization
  IF s_vkorg IS NOT INITIAL.
    SELECT vkorg UP TO 1 ROWS
      INTO lv_vkorg
      FROM tvko
      WHERE vkorg IN s_vkorg.
    ENDSELECT.

    IF sy-subrc NE 0 OR
       lv_vkorg IS INITIAL.
      MESSAGE e001
      WITH 'Sales Organization'(003).
    ENDIF.
  ENDIF.

ENDFORM.                    " F_SALESORG_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_BILLDOCTYPE_VALIDATION
*&---------------------------------------------------------------------*
*       Subroutine for validation of Billing Doc Type entered
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_billdoctype_validation .

*&--Local Variable declaration
  DATA: lv_fkart TYPE fkart.    "Billing Type

*&--Validation for Billing Document Type
  IF s_fkart IS NOT INITIAL.
    SELECT fkart UP TO 1 ROWS
      INTO lv_fkart
      FROM tvfk
      WHERE fkart IN s_fkart.
    ENDSELECT.

    IF sy-subrc NE 0 OR
       lv_fkart IS INITIAL.
      MESSAGE e001
      WITH 'Billing Document Type'(004).
    ENDIF.
  ENDIF.

ENDFORM.                    " F_BILLDOCTYPE_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_BILLDOCNO_VALIDATION
*&---------------------------------------------------------------------*
*       Subroutine for validation of Billing Doc Number entered
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_billdocno_validation .

*&--Local Variable declaration
  DATA: lv_vbeln TYPE vbeln_vf.  "Billing Document Number

*&--Validation for Billing Document Number
  IF s_vbeln IS NOT INITIAL.
    SELECT vbeln UP TO 1 ROWS
      INTO lv_vbeln
      FROM vbuk
      WHERE vbeln IN s_vbeln.
    ENDSELECT.

    IF sy-subrc NE 0 OR
       lv_vbeln IS INITIAL.
      MESSAGE e001
      WITH 'Billing Document Number'(005).
    ENDIF.
  ENDIF.

ENDFORM.                    " F_BILLDOCNO_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_PAYER_VALIDATION
*&---------------------------------------------------------------------*
*       Subroutine for validation of Payer entered
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_payer_validation .

*&--Local Variable declaration
  DATA:  lv_kunrg TYPE kunrg.     "Payer

*&--Validation for Payer
  IF s_kunrg IS NOT INITIAL.
    SELECT kunnr UP TO 1 ROWS
      INTO lv_kunrg
      FROM kna1
      WHERE kunnr IN s_kunrg.
    ENDSELECT.

    IF sy-subrc NE 0 OR
       lv_kunrg IS INITIAL.
      MESSAGE e001
        WITH 'Payer'(006).
    ENDIF.
  ENDIF.

ENDFORM.                    " F_PAYER_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_CONDTYPE_VALIDATION
*&---------------------------------------------------------------------*
*       Subroutine for validation of Condition Type entered
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_condtype_validation .

*&--Local Variable declaration
  DATA: lv_kschl TYPE kschl.     "Condition Type

*&--Validation for Condition Type
  IF s_kschl IS NOT INITIAL.
    SELECT kschl UP TO 1 ROWS
      INTO lv_kschl
      FROM t685
      WHERE kschl IN s_kschl.
    ENDSELECT.

    IF sy-subrc NE 0 OR
       lv_kschl IS INITIAL.
      MESSAGE e001
        WITH 'Condition Type'(007).
    ENDIF.
  ENDIF.

ENDFORM.                    " F_CONDTYPE_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_DATA_SELECTION
*&---------------------------------------------------------------------*
*       Subroutine for data selection based on parameters entered
*         at selection.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_data_selection .

*&--Begin of changes for CR#34 on 12-Jun-2012
  TYPES:

*&--Begin of Changes for INC0092335/Defect#3746 on 09-May-2013

**&--Types declaration for customer range
*    BEGIN OF lty_kunnr,
*     sign   TYPE char1,   "Sign
*     option TYPE char2,   "Option
*     low    TYPE kunnr,   "Low Value
*     high   TYPE kunnr,   "High Value
*    END OF lty_kunnr,

*&--Types declaration for Sales Org Range
    BEGIN OF lty_vkorg,
     sign   TYPE char1,   "Sign
     option TYPE char2,   "Option
     low    TYPE vkorg,   "Low Value
     high   TYPE vkorg,   "High Value
    END OF lty_vkorg,

*&--Types declaration for Distribution Channel Range
    BEGIN OF lty_vtweg,
     sign   TYPE char1,   "Sign
     option TYPE char2,   "Option
     low    TYPE vtweg,   "Low Value
     high   TYPE vtweg,   "High Value
    END OF lty_vtweg,

*&--End of Changes for INC0092335/Defect#3746 on 09-May-2013

    BEGIN OF lty_tvvnt,
     spras TYPE spras,    "Language
     kvgrn TYPE kvgr1,    "Customer Grp1
     bezei TYPE bezei20,  "Customer Grp1 Desc
    END OF lty_tvvnt,

*&--Table type for Customer Group Description Structure
    lty_t_tvvnt TYPE STANDARD TABLE OF lty_tvvnt. "Table Type

  CONSTANTS:
    lc_sign_i    TYPE char1 VALUE 'I',  "I=Include
    lc_option_eq TYPE char2 VALUE 'EQ', "EQ=Equal
    lc_lang      TYPE spras VALUE 'E'.  "Language
*&--End of changes for CR#34 on 12-Jun-2012

*&--Local Declaration
  DATA:
    lv_knumv          TYPE knumv, "Number of document condition
    li_bill_doc_item  TYPE ty_t_vbrp, "internal tab for bill items

*&--Begin of changes for CR#6 on 17-APR-2012
    li_customer       TYPE ty_t_kna1, "internal tab for customer data
    lwa_customer      TYPE ty_kna1,   "workarea for customer data
*&--End of changes for CR#6 on 17-APR-2012

*&--Begin of changes for CR#34 on 12-Jun-2012
    li_cust_master    TYPE ty_t_knvv,

*&--Begin of Comment for INC0092335/Defect#3746 on 09-May-2013
*    lr_kunnr          TYPE RANGE OF kunnr,
*    lwa_kunnr         TYPE lty_kunnr,
*&--End of Comment for INC0092335/Defect#3746 on 09-May-2013

    li_tvv1t          TYPE lty_t_tvvnt,
    li_tvv2t          TYPE lty_t_tvvnt,

*&--Begin of Changes for INC0092335/Defect#3746 on 09-May-2013
    li_sales_partner  TYPE ty_t_vbpa,      "Sales Partner data
    lr_vkorg          TYPE RANGE OF vkorg, "Sales Organization data
    lwa_vkorg         TYPE lty_vkorg,      "Sales Organization WA
    lr_vtweg          TYPE RANGE OF vtweg, "Distribution Channel data
    lwa_vtweg         TYPE lty_vtweg.      "Distribution Channel WA
*&--End of Changes for INC0092335/Defect#3746 on 09-May-2013

  FIELD-SYMBOLS:
    <lfs_tvv1t>       TYPE lty_tvvnt,
    <lfs_tvv2t>       TYPE lty_tvvnt.
*&--End of changes for CR#34 on 12-Jun-2012

*&--Fetching data from Accounting Document Header Table
  SELECT bukrs
         belnr
         gjahr
         awkey
    FROM bkpf
    INTO TABLE i_accnt_doc_head
    WHERE awtyp EQ c_awtyp
    AND   awkey IN s_vbeln
    AND   bukrs IN s_bukrs
    AND   gjahr EQ p_gjahr.

  IF sy-subrc EQ 0.
    SORT i_accnt_doc_head BY bukrs belnr gjahr awkey.
  ELSE.
    MESSAGE i002
      WITH 'Accounting Document Header'(008).
    LEAVE LIST-PROCESSING.
  ENDIF.

*&--Updating field AWKEY of internal table I_ACCNT_DOC_HEAD
  LOOP AT i_accnt_doc_head ASSIGNING <fs_bkpf>.
    <fs_bkpf>-awkey  = <fs_bkpf>-awkey+0(10).
  ENDLOOP.

*&--Delete duplicacy from table I_ACCNT_DOC_HEAD comparing AWKEY field
  SORT i_accnt_doc_head BY awkey.
  DELETE ADJACENT DUPLICATES FROM i_accnt_doc_head
                        COMPARING awkey.

*&--Fetching data from Billing Document Header table
  IF i_accnt_doc_head[] IS NOT INITIAL.
    SELECT vbeln
           fkart
           vkorg
           vtweg     "Added for CR#34 on 12-JUN-2012
           knumv
           fkdat
           kunrg
           kunag     "Added for CR#67 on 26-JUL-2012
      FROM vbrk
      INTO TABLE i_bill_doc_head
      FOR ALL ENTRIES IN i_accnt_doc_head
      WHERE vbeln EQ i_accnt_doc_head-awkey+0(10)
      AND   fkart IN s_fkart
      AND   vkorg IN s_vkorg
      AND   fkdat IN s_fkdat
      AND   kunrg IN s_kunrg.

    IF sy-subrc EQ 0.
      SORT i_bill_doc_head BY vbeln.
    ELSE.
      MESSAGE i002
      WITH 'Billing Document Header'(009).
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

*&--Fetching data from Billing Document Item table
  IF i_bill_doc_head[] IS NOT INITIAL.
    SELECT vbeln
           posnr
           meins
           fklmg
           netwr    "Added for CR#67 on 26-Jul-2012
           aubel    "Added for CR#6 on 17-Apr-2012
           matnr
           arktx    "Added for CR#6 on 17-Apr-2012
           werks    "Added for CR#67 on 26-Jul-2012
           kvgr1    "Added for CR#34 on 12-Jun-2012
           kvgr2    "Added for CR#34 on 12-Jun-2012
           bonba    "Added for CR#6 on 17-Apr-2012
           kokrs    "Added for CR#67 on 26-Jul-2012
      FROM vbrp
      INTO TABLE i_bill_doc_item
      FOR ALL ENTRIES IN i_bill_doc_head
      WHERE vbeln EQ i_bill_doc_head-vbeln.

    IF sy-subrc EQ 0.
      SORT i_bill_doc_item BY vbeln posnr.
    ELSE.
      MESSAGE i002
      WITH 'Billing Document Item'(010).
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

*&--Updating KNUMV field in Billing doc item internal table from
*&--Billing doc header internal table
  LOOP AT i_bill_doc_item ASSIGNING <fs_vbrp>.
    AT NEW vbeln.
      CLEAR: wa_bill_doc_head,
             lv_knumv.
      READ TABLE i_bill_doc_head INTO wa_bill_doc_head
                                 WITH KEY vbeln = <fs_vbrp>-vbeln
                                 BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_knumv = wa_bill_doc_head-knumv.
      ENDIF.
    ENDAT.

    <fs_vbrp>-knumv = lv_knumv.

  ENDLOOP.

*&--Begin of changes for CR#67 on 26-Jul-2012
  PERFORM f_get_profit_center_data USING i_bill_doc_item
                                CHANGING i_plant_mat.
*&--End of changes for CR#67 on 26-Jul-2012

*&--Copying I_BILL_DOC_ITEM table into temporary table and deleting
*&--duplicay from it comparing fields KNUMV POSNR
  li_bill_doc_item[] = i_bill_doc_item[].
  SORT li_bill_doc_item BY knumv posnr.
  DELETE ADJACENT DUPLICATES FROM li_bill_doc_item
                        COMPARING knumv
                                  posnr.

*&--Fetching data from Conditions Table
  IF li_bill_doc_item[] IS NOT INITIAL.
    SELECT knumv
           kposn
           stunr
           zaehk
           kschl
           kbetr
           kwaeh     "Added for CR#6 on 21-May-2012
           kwert
           kwaeh
      FROM konv
      INTO TABLE i_conditions
      FOR ALL ENTRIES IN li_bill_doc_item
      WHERE knumv EQ li_bill_doc_item-knumv
      AND   kposn EQ li_bill_doc_item-posnr
      AND   kschl IN s_kschl.

    IF sy-subrc EQ 0.
      SORT i_conditions BY knumv kposn.
    ELSE.
      MESSAGE i002
      WITH 'Conditions (Transaction Data)'(038).
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

************************************************************************
*  Begin of changes for CR# 6
*----------------------------------------------------------------------*
*  User      Transport      Date
*----------------------------------------------------------------------*
*  RVERMA    E1DK901226     17-Apr-2012
************************************************************************

  CLEAR li_bill_doc_item.

  li_bill_doc_item[] = i_bill_doc_item[].

  SORT li_bill_doc_item BY aubel.
  DELETE ADJACENT DUPLICATES FROM li_bill_doc_item
                        COMPARING aubel.

*&--Fetching data from Sales Partner table
  IF li_bill_doc_item[] IS NOT INITIAL.
    SELECT vbeln
           posnr
           parvw
           kunnr
      FROM vbpa
      INTO TABLE i_sales_partner
      FOR ALL ENTRIES IN li_bill_doc_item
      WHERE vbeln EQ li_bill_doc_item-aubel
      AND   parvw EQ c_parvw_we.

    IF sy-subrc EQ 0.
      SORT i_sales_partner BY vbeln posnr.
    ENDIF.
  ENDIF.

*&--Populating Payer value to customer table
  LOOP AT i_bill_doc_head ASSIGNING <fs_vbrk>.
    lwa_customer-kunnr = <fs_vbrk>-kunrg.
    APPEND lwa_customer TO li_customer.
    CLEAR lwa_customer.

*&--Begin of changes for CR#67 on 26-Jul-2012
    lwa_customer-kunnr = <fs_vbrk>-kunag.
    APPEND lwa_customer TO li_customer.
    CLEAR lwa_customer.
*&--End of changes for CR#67 on 26-Jul-2012

*&--Begin of Changes for INC0092335/Defect#3746 on 09-May-2013

*&--Populating range of Sales Org
    lwa_vkorg-sign   = lc_sign_i.
    lwa_vkorg-option = lc_option_eq.
    lwa_vkorg-low    = <fs_vbrk>-vkorg.
    APPEND lwa_vkorg TO lr_vkorg.
    CLEAR lwa_vkorg.

*&--Populating range of Distribution Channel
    lwa_vtweg-sign   = lc_sign_i.
    lwa_vtweg-option = lc_option_eq.
    lwa_vtweg-low    = <fs_vbrk>-vtweg.
    APPEND lwa_vtweg TO lr_vtweg.
    CLEAR lwa_vtweg.

  ENDLOOP.

  SORT lr_vkorg BY low.
  DELETE ADJACENT DUPLICATES FROM lr_vkorg
                        COMPARING low.

  SORT lr_vtweg BY low.
  DELETE ADJACENT DUPLICATES FROM lr_vtweg
                        COMPARING low.

*&--End of Changes for INC0092335/Defect#3746 on 09-May-2013

*&--Populating Customer value to customer table
  LOOP AT i_sales_partner ASSIGNING <fs_vbpa>.
    lwa_customer-kunnr = <fs_vbpa>-kunnr.
    APPEND lwa_customer TO li_customer.
    CLEAR lwa_customer.

*&--Begin of Cooment for INC0092335/Defect#3746 on 09-May-2013

**&--Begin of changes for CR#34 on 12-Jun-2012
**&--Populating range of customer
*    lwa_kunnr-sign   = lc_sign_i.
*    lwa_kunnr-option = lc_option_eq.
*    lwa_kunnr-low    = <fs_vbpa>-kunnr.
*    APPEND lwa_kunnr TO lr_kunnr.
*    CLEAR lwa_kunnr.
**&--End of changes for CR#34 on 12-Jun-2012

*&--End of Comment for INC0092335/Defect#3746 on 09-May-2013
  ENDLOOP.

*&--Sort and delete duplicate records based on kunnr
  SORT li_customer BY kunnr.
  DELETE ADJACENT DUPLICATES FROM li_customer
                        COMPARING kunnr.

  IF li_customer[] IS NOT INITIAL.
    SELECT kunnr
           name1
      FROM kna1
      INTO TABLE i_customer
      FOR ALL ENTRIES IN li_customer
      WHERE kunnr EQ li_customer-kunnr.

    IF sy-subrc EQ 0.
      SORT i_customer BY kunnr.
    ENDIF.
  ENDIF.

************************************************************************
*  End of changes for CR# 6
*----------------------------------------------------------------------*
*  User      Transport      Date
*----------------------------------------------------------------------*
*  RVERMA    E1DK901226     17-Apr-2012
************************************************************************

************************************************************************
*  Start of changes for CR# 34
*----------------------------------------------------------------------*
*  User      Transport      Date
*----------------------------------------------------------------------*
*  RVERMA    E1DK901226     12-Jun-2012
************************************************************************

*&--Begin of Comment for INC0092335/Defect#3746 on 09-May-2013

**&--Sort and delete duplicates based on customer code
*  SORT lr_kunnr BY low.
*  DELETE ADJACENT DUPLICATES FROM lr_kunnr
*                        COMPARING low.
*
*  IF i_bill_doc_head[] IS NOT INITIAL.
*
**&--Fetch data from customer master data table KNVV
*    SELECT kunnr  "Customer No.
*           vkorg  "Sales Org.
*           vtweg  "Distribution Channel
*           spart  "Division
*           kvgr1  "Customer Grp 1
*           kvgr2  "Customer Grp 2
*      FROM knvv
*      INTO TABLE i_cust_master
*      FOR ALL ENTRIES IN i_bill_doc_head
*      WHERE kunnr IN lr_kunnr
*        AND vkorg EQ i_bill_doc_head-vkorg
*        AND vtweg EQ i_bill_doc_head-vtweg
*        AND spart EQ c_spart_00.

*&--End of Comment for INC0092335/Defect#3746 on 09-May-2013

*&--Begin of Changes for INC0092335/Defect#3746 on 09-May-2013
  li_sales_partner[] = i_sales_partner[].

  SORT li_sales_partner BY kunnr.
  DELETE ADJACENT DUPLICATES FROM li_sales_partner
                        COMPARING kunnr.

  IF li_sales_partner[] IS NOT INITIAL.

*&--Fetch data from customer master data table KNVV
    SELECT kunnr  "Customer No.
           vkorg  "Sales Org.
           vtweg  "Distribution Channel
           spart  "Division
           kvgr1  "Customer Grp 1
           kvgr2  "Customer Grp 2
      FROM knvv
      INTO TABLE i_cust_master
      FOR ALL ENTRIES IN li_sales_partner
      WHERE kunnr EQ li_sales_partner-kunnr
        AND vkorg IN lr_vkorg
        AND vtweg IN lr_vtweg
        AND spart EQ c_spart_00
        AND loevm EQ space.

*&--End of Changes for INC0092335/Defect#3746 on 09-May-2013

    IF sy-subrc EQ 0.
      SORT i_cust_master BY kunnr vkorg vtweg.

      li_cust_master[] = i_cust_master[].

*&--Sort & delete duplicates based on customer grp1 KVGR1
      SORT li_cust_master BY kvgr1.
      DELETE ADJACENT DUPLICATES FROM li_cust_master
                            COMPARING kvgr1.

      IF li_cust_master[] IS NOT INITIAL.

*&--Fetch data from Customer Grp1 Description table TVV1T
        SELECT spras  "Language
               kvgr1  "Customer Grp1
               bezei  "Description
          FROM tvv1t
          INTO TABLE li_tvv1t
          FOR ALL ENTRIES IN li_cust_master
          WHERE spras EQ lc_lang
            AND kvgr1 EQ li_cust_master-kvgr1.
        IF sy-subrc EQ 0.
          SORT li_tvv1t BY kvgrn.
        ENDIF.
      ENDIF.


      li_cust_master[] = i_cust_master[].

*&--Sort & delete duplicates based on Customer Grp2 KVGR2
      SORT li_cust_master BY kvgr2.
      DELETE ADJACENT DUPLICATES FROM li_cust_master
                            COMPARING kvgr2.

      IF li_cust_master[] IS NOT INITIAL.

*&--Fetch data from Customer Grp2 Description table TVV2T
        SELECT spras  "Language
               kvgr2  "Customer Grp2
               bezei  "Description
          FROM tvv2t
          INTO TABLE li_tvv2t
          FOR ALL ENTRIES IN li_cust_master
          WHERE spras EQ lc_lang
            AND kvgr2 EQ li_cust_master-kvgr2.
        IF sy-subrc EQ 0.
*&-- Begin of changes for HANAtization on OTC_RDD_0008 by SMUKHER on 19-Aug-2019 in E1SK901425
          SORT li_tvv2t BY kvgrn.
*&-- End of changes for HANAtization on OTC_RDD_0008 by SMUKHER on 19-Aug-2019 in E1SK901425
          SORT li_tvv1t BY kvgrn.
        ENDIF.
      ENDIF.

*&--Process on each record of table I_CUST_MASTER and updates customer
*&--group description field value KVGR1T and KVGR2T
      LOOP AT i_cust_master ASSIGNING <fs_knvv>.

*&--Read Customer Grp1 description table
        READ TABLE li_tvv1t ASSIGNING <lfs_tvv1t>
                            WITH KEY kvgrn = <fs_knvv>-kvgr1
                            BINARY SEARCH.
        IF sy-subrc EQ 0.
          <fs_knvv>-kvgr1t = <lfs_tvv1t>-bezei.
        ENDIF.

*&--Read Customer Grp2 description table
        READ TABLE li_tvv2t ASSIGNING <lfs_tvv2t>
                            WITH KEY kvgrn = <fs_knvv>-kvgr2
                            BINARY SEARCH.
        IF sy-subrc EQ 0.
          <fs_knvv>-kvgr2t = <lfs_tvv2t>-bezei.
        ENDIF.
      ENDLOOP.

    ENDIF.
  ENDIF.


************************************************************************
*  End of changes for CR# 34
*----------------------------------------------------------------------*
*  User      Transport      Date
*----------------------------------------------------------------------*
*  RVERMA    E1DK901226     12-Jun-2012
************************************************************************


ENDFORM.                    " F_DATA_SELECTION
*&---------------------------------------------------------------------*
*&      Form  F_DATA_PROCESSING
*&---------------------------------------------------------------------*
*       Subroutine to process data and build final table to display at
*         report output
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_data_processing.

*&--Local declaration
  DATA:
*&--Local variable declaration
    lv_cond_index TYPE sytabix, "Index Variable for cond table
    lv_fkdat      TYPE char10, "Billing date in user format
    lv_kunrg      TYPE char10,  "Payer
    lv_kunrg_name TYPE name1_gp,"payer name

*&--Begin of changes for CR#67 on 26-Jul-2012
    lv_kunag      TYPE char10,  "Sold-to Number
    lv_kunag_name TYPE name1_gp,"Sold-to Name
*&--End of changes for CR#67 on 26-Jul-2012

*&--Begin of changes for CR#34 on 12-Jun-2012
    lv_vkorg      TYPE vkorg,   "Sales Organization
    lv_vtweg      TYPE vtweg,   "Distribution Channel
*&--End of changes for CR#34 on 12-Jun-2012

*&--Local workarea declaration
    lwa_bill_doc_item  TYPE ty_vbrp, "Billing doc item Workarea

*&--Begin of changes for CR#6 on 17-APR-2012
    lwa_conditions     TYPE ty_konv, "Conditions Workarea
*&--End of changes for CR#6 on 17-APR-2012

    lwa_sales_partner  TYPE ty_vbpa, "Sales Partner Workarea
    lwa_customer       TYPE ty_kna1, "Customer data workarea
    lwa_final          TYPE ty_final."Final Workarea

*&--Begin of change for CR#67
  FIELD-SYMBOLS:
    <lfs_customer> TYPE ty_kna1, "Customer data
    <lfs_plant_mat> TYPE ty_marc. "Material Plant data
*&--End of change for CR#67

  CLEAR: wa_bill_doc_head.

* &--Populating data into Final Internal table
  LOOP AT i_bill_doc_item INTO lwa_bill_doc_item.
    lwa_final-vbeln = lwa_bill_doc_item-vbeln.
    lwa_final-posnr = lwa_bill_doc_item-posnr.
    lwa_final-meins = lwa_bill_doc_item-meins.


*&--Begin of changes for CR#34 on 12-Jun-2012

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = lwa_bill_doc_item-matnr
      IMPORTING
        OUTPUT = lwa_final-matnr.

*&--End of changes for CR#34 on 12-Jun-2012


*&--Begin of changes for CR#6 on 17-Apr-2012
    lwa_final-arktx = lwa_bill_doc_item-arktx.
    lwa_final-fklmg = lwa_bill_doc_item-fklmg.
    lwa_final-bonba = lwa_bill_doc_item-bonba.
*&--End of changes for CR#6 on 17-Apr-2012

*&--Begin of changes for CR#67 on 26-Jul-2012
    lwa_final-netwr = lwa_bill_doc_item-netwr.
*&--End of changes for CR#67 on 26-Jul-2012

    AT NEW vbeln.
      CLEAR: lv_fkdat,
             lv_kunrg,
             lv_kunrg_name,
             lv_kunag,  "Added for CR#67 on 26-Jul-2012
             lv_kunag_name,  "Added for CR#67 on 26-Jul-2012
             lv_vkorg,  "Added for CR#34 on 12-Jun-2012
             lv_vtweg.  "Added for CR#34 on 12-Jun-2012

*&--Reading billing document header data & populating in final table
      READ TABLE i_bill_doc_head
            INTO wa_bill_doc_head
            WITH KEY vbeln = lwa_bill_doc_item-vbeln
            BINARY SEARCH.
      IF sy-subrc EQ 0.
        CONCATENATE wa_bill_doc_head-fkdat+4(2)
                    wa_bill_doc_head-fkdat+6(2)
                    wa_bill_doc_head-fkdat+0(4)
               INTO lv_fkdat
               SEPARATED BY '/'.


*&--Begin of changes for CR#34 on 12-Jun-2012
        lv_vkorg = wa_bill_doc_head-vkorg.
        lv_vtweg = wa_bill_doc_head-vtweg.

*&--Removing leading zeroes from Payer
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = wa_bill_doc_head-kunrg
          IMPORTING
            output = lv_kunrg.

*&--End of changes for CR#34 on 12-Jun-2012


*&--Begin of changes for CR#67 on 26-Jul-2012
*&--Removing leading zeroes from Sold-To number
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = wa_bill_doc_head-kunag
          IMPORTING
            output = lv_kunag.

        READ TABLE i_customer
              ASSIGNING <lfs_customer>
              WITH KEY kunnr = wa_bill_doc_head-kunag
              BINARY SEARCH.
        IF sy-subrc EQ 0.
          lv_kunag_name = <lfs_customer>-name1.
        ENDIF.
*&--End of changes for CR#67 on 26-Jul-2012


*&--Begin of changes for CR#6 on 17-Apr-2012
*&--Reading payer data & populating in final table
        CLEAR lwa_customer.

        READ TABLE i_customer
              INTO lwa_customer
              WITH KEY kunnr = wa_bill_doc_head-kunrg
              BINARY SEARCH.
        IF sy-subrc EQ 0.
          lv_kunrg_name = lwa_customer-name1.
        ENDIF.

*&--End of changes for CR#6 on 17-Apr-2012

      ENDIF.
    ENDAT.

    lwa_final-fkdat = lv_fkdat.
    lwa_final-kunrg = lv_kunrg.

*&--Begin of changes for CR#67 on 26-Jul-2012
    lwa_final-kunag = lv_kunag.
    lwa_final-kunag_name = lv_kunag_name.

*&--Read plant material data table to get profit center
    READ TABLE i_plant_mat
          ASSIGNING <lfs_plant_mat>
          WITH KEY matnr = lwa_bill_doc_item-matnr
                   werks = lwa_bill_doc_item-werks
                   kokrs = lwa_bill_doc_item-kokrs
          BINARY SEARCH.
    IF sy-subrc EQ 0.
      lwa_final-prctr_name = <lfs_plant_mat>-prctr_nam.
    ELSE.
      READ TABLE i_plant_mat
            ASSIGNING <lfs_plant_mat>
            WITH KEY matnr = lwa_bill_doc_item-matnr
                     werks = lwa_bill_doc_item-werks
                     kokrs = space
            BINARY SEARCH.
      IF sy-subrc EQ 0.
        lwa_final-prctr_name = <lfs_plant_mat>-prctr_nam.
      ENDIF.
    ENDIF.
*&--End of changes for CR#67 on 26-Jul-2012


*&-Begin of changes for CR#6 on 17-Apr-2012
    lwa_final-kunrg_name = lv_kunrg_name.

*&--Reading sales partner data & populating in final table
    READ TABLE i_sales_partner
          INTO lwa_sales_partner
          WITH KEY vbeln = lwa_bill_doc_item-aubel
                   posnr = lwa_bill_doc_item-posnr
          BINARY SEARCH.
    IF sy-subrc EQ 0.
      lwa_final-kunnr = lwa_sales_partner-kunnr.
    ELSE.
      CLEAR lwa_sales_partner.
*&--If sales partner data not found for corresponding item then
*&--Reading sales partner data for item equals to initial
      READ TABLE i_sales_partner
            INTO lwa_sales_partner
            WITH KEY vbeln = lwa_bill_doc_item-aubel
                     posnr = c_posnr_init
            BINARY SEARCH.
      IF sy-subrc EQ 0.
        lwa_final-kunnr = lwa_sales_partner-kunnr.
      ENDIF.
    ENDIF.


*&--Begin of changes for CR#34 on 12-Jun-2012

    IF lwa_final-kunnr IS NOT INITIAL.

*&--Read customer master data table
      READ TABLE i_cust_master ASSIGNING <fs_knvv>
                               WITH KEY kunnr = lwa_final-kunnr
                                        vkorg = lv_vkorg
                                        vtweg = lv_vtweg
                               BINARY SEARCH.
      IF sy-subrc EQ 0.
        lwa_final-kvgr1  = <fs_knvv>-kvgr1.
        lwa_final-kvgr1t = <fs_knvv>-kvgr1t.
        lwa_final-kvgr2  = <fs_knvv>-kvgr2.
        lwa_final-kvgr2t = <fs_knvv>-kvgr2t.
      ENDIF.

*&--Removing leading zeroes
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = lwa_final-kunnr
        IMPORTING
          output = lwa_final-kunnr.
    ENDIF.

*&--End of changes for CR#34 on 12-Jun-2012


    CLEAR lwa_customer.

*&--Reading customer data & populating in final table
    READ TABLE i_customer
          INTO lwa_customer
          WITH KEY kunnr = lwa_sales_partner-kunnr
          BINARY SEARCH.

    IF sy-subrc EQ 0.
      lwa_final-kunnr_name = lwa_customer-name1.
    ENDIF.

*&--End of changes for CR#6 on 17-Apr-2012


*&--Using parallel cursor to read and populate data from condition
*&--table as there can be multiple records based on KNUMV & KPOSN
    READ TABLE i_conditions
          INTO lwa_conditions
          WITH KEY knumv = lwa_bill_doc_item-knumv
                   kposn = lwa_bill_doc_item-posnr
          BINARY SEARCH.
    IF sy-subrc EQ 0.
      lv_cond_index = sy-tabix.
      CLEAR: lwa_conditions.
      LOOP AT i_conditions INTO lwa_conditions FROM lv_cond_index.
        IF lwa_conditions-knumv NE lwa_bill_doc_item-knumv OR
           lwa_conditions-kposn NE lwa_bill_doc_item-posnr.
          EXIT.
        ENDIF.
        lwa_final-kschl = lwa_conditions-kschl.

************************************************************************
*  Start of changes for CR# 34
*----------------------------------------------------------------------*
*  User      Transport      Date
*----------------------------------------------------------------------*
*  RVERMA    E1DK901226     12-Jun-2012
************************************************************************

        lwa_final-kbetr = lwa_conditions-kbetr / 10.

************************************************************************
*  End of changes for CR# 34
*----------------------------------------------------------------------*
*  User      Transport      Date
*----------------------------------------------------------------------*
*  RVERMA    E1DK901226     12-Jun-2012
************************************************************************

************************************************************************
*  Begin of changes for CR# 6
*----------------------------------------------------------------------*
*  User      Transport      Date
*----------------------------------------------------------------------*
*  RVERMA    E1DK901226     17-Apr-2012
************************************************************************

        lwa_final-waers = lwa_conditions-waers.

************************************************************************
*  End of changes for CR# 6
*----------------------------------------------------------------------*
*  User      Transport      Date
*----------------------------------------------------------------------*
*  RVERMA    E1DK901226     17-Apr-2012
************************************************************************

        lwa_final-kwert = lwa_conditions-kwert.
        lwa_final-kwaeh = lwa_conditions-kwaeh.

        APPEND lwa_final TO i_final.

        CLEAR: lwa_conditions.
      ENDLOOP.  "I_CONDITIONS
    ENDIF.
    CLEAR: lwa_bill_doc_item,
           wa_bill_doc_head,
           lwa_sales_partner,
           lwa_conditions,
           lwa_final,
           lv_cond_index.
  ENDLOOP.  "I_BILL_DOC_ITEM

  SORT i_final BY vbeln posnr.

ENDFORM.                    " F_DATA_PROCESSING
*&---------------------------------------------------------------------*
*&      Form  F_FILL_LISTHEADER
*&---------------------------------------------------------------------*
*       subroutine to fill list header inetrnal table
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_fill_listheader .
*&--Local declaration
  DATA: lv_date    TYPE char10,  "date variable
        lv_time    TYPE char10,  "time variable
        lv_lines   TYPE i,       "records count of final table
        lx_address TYPE bapiaddr3, "User Address Data
        li_return  TYPE ty_t_bapiret. "return table

  wa_listheader-typ  = 'H'.
  wa_listheader-key  = 'Report'(033).
  wa_listheader-info = 'Pricing Rebate Report'(034).
  APPEND wa_listheader TO i_listheader.
  CLEAR wa_listheader.

  wa_listheader-typ  = 'S'.
  wa_listheader-key  = 'User Name'(036).

*&--Get user details
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    IMPORTING
      address  = lx_address
    TABLES
      return   = li_return.

  IF lx_address-fullname IS NOT INITIAL.
    MOVE lx_address-fullname TO wa_listheader-info.
  ELSE.
    MOVE sy-uname TO wa_listheader-info.
  ENDIF.

  APPEND wa_listheader TO i_listheader.
  CLEAR wa_listheader.

  wa_listheader-typ = 'S'.
  wa_listheader-key = 'Date and Time'(035).

  CONCATENATE sy-uzeit+0(2)
              sy-uzeit+2(2)
              sy-uzeit+4(2)
         INTO lv_time
         SEPARATED BY ':'.

  CONCATENATE sy-datum+4(2)
              sy-datum+6(2)
              sy-datum+0(4)
         INTO lv_date
         SEPARATED BY '/'.

  CONCATENATE lv_date
              lv_time
         INTO wa_listheader-info
         SEPARATED BY space.
  APPEND wa_listheader TO i_listheader.
  CLEAR wa_listheader.

  DESCRIBE TABLE i_final[] LINES lv_lines.

  wa_listheader-typ  = 'S'.
  wa_listheader-key  = 'Total Records'(037).
  MOVE lv_lines TO wa_listheader-info.
  APPEND wa_listheader TO i_listheader.
  CLEAR wa_listheader.



ENDFORM.                    " F_FILL_LISTHEADER
*&---------------------------------------------------------------------*
*&      Form  F_FILL_FIELDCAT
*&---------------------------------------------------------------------*
*       Subroutine to fill fieldcatalog table
*----------------------------------------------------------------------*
*  -->  FP_FIELDNAME
*  -->  FP_SELTEXT
*  -->  FP_COL_POS
*  -->  FP_NO_OUT
*----------------------------------------------------------------------*
FORM f_fill_fieldcat USING fp_fieldname  TYPE slis_fieldname
                           fp_cfieldname TYPE slis_fieldname
                           fp_qfieldname TYPE slis_fieldname
                           fp_seltext    TYPE scrtext_l
                           fp_col_pos    TYPE sycucol
                           fp_no_out     TYPE char1
                           fp_datatype   TYPE datatype_d.
  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname  = fp_fieldname.
  wa_fieldcat-cfieldname = fp_cfieldname.
  wa_fieldcat-qfieldname = fp_qfieldname.
  wa_fieldcat-seltext_l  = fp_seltext.
  wa_fieldcat-col_pos    = fp_col_pos.
  wa_fieldcat-no_out     = fp_no_out.
  wa_fieldcat-datatype   = fp_datatype.

  APPEND wa_fieldcat TO i_fieldcat.
  CLEAR: wa_fieldcat.
ENDFORM.                    " F_FILL_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       Subroutine for header display
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_top_of_page .

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = i_listheader.

ENDFORM.                    " F_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  F_OUTPUT_DISPLAY
*&---------------------------------------------------------------------*
*       Subroutine to display the output in ALV
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_output_display .

*&--Building Fieldcatalog table
  CLEAR: wa_fieldcat.

  PERFORM f_fill_listheader.

  PERFORM f_fill_fieldcat USING 'VBELN'(011)
                                ''
                                ''
                                'Billing Doc No'(012)
                                0
                                ''
                                ''.

  PERFORM f_fill_fieldcat USING 'POSNR'(014)
                                ''
                                ''
                                'Billing Item No'(015)
                                1
                                'X'(016)
                                ''.

  PERFORM f_fill_fieldcat USING 'FKDAT'(017)
                                ''
                                ''
                                'Billing Date(MM/DD/YYYY)'(018)
                                2
                                ''
                                ''.

*&--Begin of changes for CR#67 on 26-Jul-2012
  PERFORM f_fill_fieldcat USING 'KUNAG'(067)
                                ''
                                ''
                                'Sold-to-Party'(068)
                                3
                                ''
                                ''.

  PERFORM f_fill_fieldcat USING 'KUNAG_NAME'(069)
                                ''
                                ''
                                'Sold-to-Party Description'(070)
                                4
                                ''
                                ''.
*&--End of changes for CR#67 on 26-Jul-2012

  PERFORM f_fill_fieldcat USING 'KUNRG'(019)
                                ''
                                ''
                                'Payer'(006)
                                5
                                ''
                                ''.

*&--Begin of changes for CR#6 on 17-APR-2012
  PERFORM f_fill_fieldcat USING 'KUNRG_NAME'(051)
                                ''
                                ''
                                'Payer Description'(052)
                                6
                                ''
                                ''.
*&--End of changes for CR#6 on 17-APR-2012

  PERFORM f_fill_fieldcat USING 'KUNNR'(021)
                                ''
                                ''
                                'Ship-to-Party'(022)
                                7
                                ''
                                ''.

*&--Begin of changes for CR#6 on 17-APR-2012
  PERFORM f_fill_fieldcat USING 'KUNNR_NAME'(053)
                                ''
                                ''
                                'Ship-to-Party Description'(054)
                                8
                                ''
                                ''.
*&--End of changes for CR#6 on 17-APR-2012

  PERFORM f_fill_fieldcat USING 'MATNR'(023)
                                ''
                                ''
                                'Material'(024)
                                9
                                ''
                                ''.

*&--Begin of changes for CR#6 on 17-APR-2012
  PERFORM f_fill_fieldcat USING 'ARKTX'(055)
                                ''
                                ''
                                'Material Description'(056)
                                10
                                ''
                                ''.
*&--End of changes for CR#6 on 17-APR-2012

*&--Begin of changes for CR#67 on 26-Jul-2012
  PERFORM f_fill_fieldcat USING 'PRCTR_NAME'(071)
                                ''
                                ''
                                'Product Division'(072)
                                11
                                ''
                                ''.
*&--End of changes for CR#67 on 26-Jul-2012

  PERFORM f_fill_fieldcat USING 'FKLMG'(025)
                                ''
                                'MEINS'(040)
                                'Quantity'(026)
                                12
                                ''
                                'QUAN'(050).

  PERFORM f_fill_fieldcat USING 'MEINS'(040)
                                ''
                                ''
                                'UoM'(041)
                                13
                                'X'
                                ''.

  PERFORM f_fill_fieldcat USING 'KSCHL'(027)
                                ''
                                ''
                                'Condition Type'(007)
                                14
                                ''
                                ''.

*&--Begin of changes for CR#34 on 12-Jun-2012
  PERFORM f_fill_fieldcat USING 'KVGR1'(059)
                                ''
                                ''
                                'Buying Group'(060)
                                15
                                ''
                                ''.

  PERFORM f_fill_fieldcat USING 'KVGR1T'(061)
                                ''
                                ''
                                'Buying Grp Description'(062)
                                16
                                ''
                                ''.

  PERFORM f_fill_fieldcat USING 'KVGR2'(063)
                                ''
                                ''
                                'IDN'(064)
                                17
                                ''
                                ''.

  PERFORM f_fill_fieldcat USING 'KVGR2T'(065)
                                ''
                                ''
                                'IDN Description'(066)
                                18
                                ''
                                ''.
*&--End of changes for CR#34 on 12-Jun-2012

*&--Begin of changes for CR#67 on 26-Jul-2012
  PERFORM f_fill_fieldcat USING 'NETWR'(073)
                                'WAERS'(042)
                                ''
                                'Sales Amount'(074)
                                19
                                ''
                                'CURR'(049).
*&--End of changes for CR#67 on 26-Jul-2012

*&--Begin of changes for CR#6 on 17-APR-2012
  PERFORM f_fill_fieldcat USING 'BONBA'(057)
                                'WAERS'(042)
                                ''
                                'Rebate Basis'(058)
                                20
                                ''
                                'CURR'(049).
*&--End of changes for CR#6 on 17-APR-2012

  PERFORM f_fill_fieldcat USING 'KBETR'(029)
                                'WAERS'(042)
                                ''
                                'Rate'(030)
                                21
                                ''
                                'CURR'(049).

*&--Begin of changes for CR#6 on 17-APR-2012
  PERFORM f_fill_fieldcat USING 'WAERS'(042)
                                ''
                                ''
                                'Currency Key'(043)
                                22
                                ''
                                ''.
*&--End of changes for CR#6 on 17-APR-2012

  PERFORM f_fill_fieldcat USING 'KWERT'(031)
                                'KWAEH'(044)
                                ''
                                'Amount'(032)
                                23
                                ''
                                'CURR'(049).

  PERFORM f_fill_fieldcat USING 'KWAEH'(044)
                                ''
                                ''
                                'Condition Currency'(045)
                                24
                                'X'
                                ''.
*&--end of building fieldcatalog table


*&--FM Call to display output in ALV
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = gv_repid
      i_callback_top_of_page = 'F_TOP_OF_PAGE'
      it_fieldcat            = i_fieldcat
      i_save                 = c_save
    TABLES
      t_outtab               = i_final
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE c_msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " F_OUTPUT_DISPLAY

************************************************************************
*  Begin of changes for CR#67
*----------------------------------------------------------------------*
*  User      Transport      Date
*----------------------------------------------------------------------*
*  RVERMA    E1DK901226     26-Jul-2012
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  F_GET_PROFIT_CENTER_DATA
*&---------------------------------------------------------------------*
*       Get Profit Centre data
*----------------------------------------------------------------------*
*      -->FP_I_VBRP  Billing Document Item Table
*      <--FP_I_MARC  Material Plant Table with Profit Centre
*----------------------------------------------------------------------*
FORM f_get_profit_center_data USING fp_i_vbrp TYPE ty_t_vbrp
                           CHANGING fp_i_marc TYPE ty_t_marc.

*&--Local Constants
  CONSTANTS:
    lc_incl  TYPE char1 VALUE 'I',        "Include
    lc_equal TYPE char2 VALUE 'EQ',       "Equal
    lc_underscore TYPE char1 VALUE '_'.   "Underscore

*&--Local Declaration
  DATA:
    lv_index TYPE sytabix,    "Index
    lv_prctr TYPE char10,     "Profit Cneter

*&--Local Internal Table Declaration
    li_vbrp TYPE ty_t_vbrp,   "Billing Doc Item table
    li_marc TYPE ty_t_marc,   "Material Plant table
    li_cepc TYPE ty_t_cepc,   "Profit Center Master data table
    li_marc_tmp TYPE ty_t_marc, "Material Plant table

    lr_kokrs  TYPE RANGE OF kokrs,   "Range of Controlling area
    lwa_kokrs LIKE LINE OF lr_kokrs,"Workarea of Controlling area
    lwa_marc  TYPE ty_marc. "Material Plant

*&--Field Symbol declaration
  FIELD-SYMBOLS:
    <lfs_vbrp> TYPE ty_vbrp,  "Bill Doc Item
    <lfs_marc> TYPE ty_marc,  "Material Plant
    <lfs_cepc> TYPE ty_cepc,  "Profit Center Master data structure
    <lfs_cepc_tmp> TYPE ty_cepc.  "Profit Center Master data structure


*&--Copy FP_I_VBRP into LI_VBRP
  li_vbrp[] = fp_i_vbrp[].

*&--Sort and delete duplicates based on Material & Plant
  SORT li_vbrp BY matnr werks.
  DELETE ADJACENT DUPLICATES FROM li_vbrp
                        COMPARING matnr werks.

*&--Check LI_VBRP table has records then process further
  IF li_vbrp[] IS NOT INITIAL.

*&--Fetch data from table MARC (Material Plant table)
    SELECT matnr  "Material
           werks  "Plant
           prctr  "Profit Center
      FROM marc
      INTO TABLE li_marc
      FOR ALL ENTRIES IN li_vbrp
      WHERE matnr EQ li_vbrp-matnr
        AND werks EQ li_vbrp-werks.

*&--If data is fetched from table MARC then process further
    IF sy-subrc EQ 0.

      CLEAR li_vbrp.
      li_vbrp[] = fp_i_vbrp[].

*&--Sort and delete based on Controlling area KOKRS
      SORT li_vbrp BY kokrs.
      DELETE ADJACENT DUPLICATES FROM li_vbrp
                            COMPARING kokrs.

*&--Populating range table of Controlling area
      LOOP AT li_vbrp ASSIGNING <lfs_vbrp>.
        lwa_kokrs-sign = lc_incl.
        lwa_kokrs-option = lc_equal.
        lwa_kokrs-low = <lfs_vbrp>-kokrs.

        APPEND lwa_kokrs TO lr_kokrs.
        CLEAR lwa_kokrs.
      ENDLOOP.

*&--Sort LI_MARC based on Material & Plant
      SORT li_marc BY matnr werks.

*&--Copying internal table from LI_MARC to LI_MARC_TMP
      li_marc_tmp[] = li_marc[].

*&--Sort & Delete duplicates from LI_MARC_TMP based on Profit Center
      SORT li_marc_tmp BY prctr.
      DELETE ADJACENT DUPLICATES FROM li_marc_tmp
                            COMPARING prctr.

*&--Check LI_MARC_TMP has records then process further
      IF li_marc_tmp[] IS NOT INITIAL.

*&--Fetch data from table CEPC (Profit Center Master data table)
        SELECT prctr  "Profit Center
               datbi  "Valid-to Date
               kokrs  "controlling Area
               name1  "Name
          FROM cepc
          INTO TABLE li_cepc
          FOR ALL ENTRIES IN li_marc_tmp
          WHERE prctr EQ li_marc_tmp-prctr
            AND datbi GE sy-datum
            AND kokrs IN lr_kokrs.

*&--If data is fetched from CEPC table then process further
        IF sy-subrc EQ 0.
          SORT li_cepc BY prctr.
        ENDIF.

      ENDIF.  "li_marc_tmp[] IS NOT INITIAL

*&--Process on LI_MARC and populate PRCTR_NAM field data
      LOOP AT li_marc ASSIGNING <lfs_marc>.

        lwa_marc = <lfs_marc>.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = <lfs_marc>-prctr
          IMPORTING
            output = lv_prctr.


*&--Read table LI_CEPC to get NAME1
        READ TABLE li_cepc ASSIGNING <lfs_cepc_tmp>
                           WITH KEY prctr = <lfs_marc>-prctr
                           BINARY SEARCH.

        IF sy-subrc EQ 0.
          lv_index = sy-tabix.

*&--Process on Li_CEPC and populate Name in FP_I_MARC table
          LOOP AT li_cepc ASSIGNING <lfs_cepc> FROM lv_index.
            IF <lfs_marc>-prctr NE <lfs_cepc>-prctr.
              EXIT.
            ENDIF.

*&--Populate PRCTR+NAME1 to PRCTR_NAM
            IF <lfs_cepc>-name1 IS NOT INITIAL.
              CONCATENATE lv_prctr
                          <lfs_cepc>-name1
                     INTO lwa_marc-prctr_nam
                     SEPARATED BY lc_underscore.
            ELSE.
              lwa_marc-prctr_nam = lv_prctr.
            ENDIF.

*&--Controlling Area
            lwa_marc-kokrs = <lfs_cepc>-kokrs.

            APPEND lwa_marc TO fp_i_marc.
          ENDLOOP.  "LI_CEPC

        ELSE.
*&--If no record found in LI_CEPC then append with PRCTR_NAM = LV_PRCTR
          lwa_marc-prctr_nam = lv_prctr.
          lwa_marc-kokrs     = space.
          APPEND lwa_marc TO fp_i_marc.

        ENDIF.  "SY-SUBRC check of read on LI_CEPC

        CLEAR: lv_prctr,
               lwa_marc,
               lv_index.

      ENDLOOP.    "LI_MARC

      SORT fp_i_marc BY matnr werks kokrs.

    ENDIF.  "Check on SY-SUBRC of Select on MARC

  ENDIF.  "li_vbrp[] IS NOT INITIAL

ENDFORM.                    " F_GET_PROFIT_CENTER_DATA
************************************************************************
*  End of changes for CR#67
*----------------------------------------------------------------------*
*  User      Transport      Date
*----------------------------------------------------------------------*
*  RVERMA    E1DK901226     26-Jul-2012
************************************************************************
