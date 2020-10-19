*&---------------------------------------------------------------------*
*&  Include           ZOTCN0116O_REVENUE_REPORT_FORM
*&---------------------------------------------------------------------*
************************************************************************
* Include    :  ZOTCN0116O_REVENUE_REPORT_FORM                         *
* TITLE      :  End to End Revenue Report                              *
* DEVELOPER  :  RAGHAV SUREDDI                                         *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0116_REVENUE_REPORT                              *
*----------------------------------------------------------------------*
* DESCRIPTION: This Report can be utilized by users to track Revenue   *
*               Documents created on a specific date or within a date  *
*               range. The report will provide all key information     *
*               about the Revenue.                                     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 30-Nov-2017 U033876   E1DK934630 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 11-Apr-2018 MGARG/    E1DK934630 Defect#4360                         *
*             U024694              Fix performance Issue, Add Search   *
*                                  help and change the description of  *
*                                  column headings                     *
*&---------------------------------------------------------------------*
* 10-May-2018 U100018   E1DK934630 Defect# 6027: Fix performance issue *
* 31-Oct-2018 U033876   E1DK939333 SCTASK0745122 Changes for POd project*
* 14-Jan-2019 U033876   E1DK939333 Sctask: SCTASK0745122 Intercompany  *
*                       Billing Accrual fields                         *
*&---------------------------------------------------------------------*
* 12-Apr-2019 PDEBARU   E1DK941048 Defect# 9070 : 1. VF01 authorization*
*                                  for all users allowed               *
*                                  2. Display of Payer Block & Sold to *
*                                  party block even if customer is     *
*                                  marked for deletion                 *
*&---------------------------------------------------------------------*

*&      Form  F_GET_DELIV_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SSTAB_DYNNR  text
*      -->P_SSTAB_ACTIVETAB  text
*      <--fP_I_LIKP[]  Delivery header
*      <--fP_I_LIPS[]  Delivery Item
*----------------------------------------------------------------------*
FORM f_get_deliv_data
*                       USING    fp_dynnr TYPE sy-dynnr " Current Screen Number
*                                fp_activetab TYPE sy-ucomm
                       CHANGING fp_i_likp TYPE ty_likp_t
                                fp_i_lips TYPE ty_lips_t
*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
                                fp_i_payr  TYPE ty_payr_t
                                fp_i_paybl TYPE ty_paybl_t
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
*--> Begin of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
                                fp_i_knvv  TYPE ty_knvv_t.
*<-- End of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU

*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
  CONSTANTS: lc_py TYPE char2 VALUE 'PY'. " Partner Function
  DATA: lv_payr TYPE parvw, " Partner Function
        li_temp TYPE STANDARD TABLE OF ty_lips.
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018


* ---> Begin of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018

*  DATA: li_lips TYPE STANDARD TABLE OF lips, " SD document: Delivery: Item data
*        lwa_fp_lips TYPE ty_lips.

**To improve performance,Join is removed.
***  FIELD-SYMBOLS: <lfs_lips> TYPE lips,    " SD document: Delivery: Item data
***                 <lfs_likp> TYPE ty_likp. " SD document: Delivery: Item data
***
***  SELECT a~vbeln                " Delivery
***         a~vstel                " Shipping Point/Receiving Point
***         a~vkorg                " Sales Organization
***         a~lfart                " Delivery Type
***         a~route                " Route
***         a~kunnr                " Ship-to party
***         a~kunag                " Sold-to party
***         a~wadat_ist            " Actual Goods Movement Date
***         a~podat                " Date (proof of delivery)
***         b~posnr                " Delivery Item
***         b~pstyv                " Delivery item category
***         b~erdat                " Date on Which Record Was Created
***         b~matnr                " Material Number
***         b~werks                " Receiving plant for deliveries
***         b~lgort                " Storage Location
***         b~lfimg                " Actual quantity delivered (in sales units)
***         b~meins                " Base Unit of Measure
***         b~arktx                " Short text for sales order item
***         b~vgbel                " Document number of the reference document
***         b~vgpos                " Item number of the reference item
***         b~uepos                " Higher-level item in bill of material structures
***         b~uecha                " Higher-Level Item of Batch Split Item
***         b~vkbur                " Sales Office
***         b~vtweg                " Distribution Channel
***         b~mvgr1                " Material group 1
***         b~mvgr4                " Material group 4
***         b~prctr                " Profit Center
***         b~kzpod                " POD indicator (relevance, verification, confirmation)
***    FROM likp AS a INNER JOIN lips AS b
***        ON a~vbeln = b~vbeln
***    INTO TABLE fp_i_lips
***   WHERE a~vkorg IN s_vkorg     " Sales Org
***     AND a~wadat_ist IN s_wadat "Actual Goodsmov date
***     AND a~vbeln IN s_vbelvl    "Delivery
***     AND a~lfart IN s_lfart     " Delivery Type
***     AND a~podat IN s_podat     " POD Date
***     AND a~kunag IN s_kunag
***     AND a~kunnr IN s_kunnr
***     AND b~werks IN s_werks     " Shipping Point
***     AND b~vtweg IN s_vtweg
***     AND b~kzpod IN s_kzpod
***     AND b~vgbel IN s_vbeln.
* <--- End of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018

* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
* Get Header Data
  SELECT vbeln " Delivery
         vstel " Shipping Point/Receiving Point
         vkorg " Sales Organization
         lfart " Delivery Type
         route " Route
         kunnr " Ship-to party
         kunag " Sold-to party
* Begin of Change for SCTASK0745122 by u033876
         vkoiv " Sales organization for intercompany billing
         vtwiv " Distribution channel for intercompany billing
         kuniv " Customer number for intercompany billing
* End of change for SCTASK0745122 by U033876
         wadat_ist " Actual Goods Movement Date
         podat     " Date (proof of delivery)
    FROM likp      " SD Document: Delivery Header Data
    INTO TABLE fp_i_likp
    WHERE
*--> Begin of delete for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
* Use Index Y03 *
*       vbeln IN s_vbelvl       " Delivery
*      AND vkorg IN s_vkorg     " Sales Org
*      AND lfart IN s_lfart     " Delivery Type
*      AND wadat_ist IN s_wadat " Actual Goodsmov date
*      AND podat IN s_podat     " POD Date
*      AND kunag IN s_kunag
*      AND kunnr IN s_kunnr.
*<-- End of delete for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
           vkorg IN s_vkorg
       AND wadat_ist IN s_wadat
       AND vbeln IN s_vbelvl.
  IF sy-subrc EQ 0.
* Now delete the records based on Selection screen input.
    DELETE fp_i_likp WHERE lfart NOT IN s_lfart
                       OR  podat NOT IN s_podat
                       OR  kunag NOT IN s_kunag
                       OR  kunnr NOT IN s_kunnr.
    IF fp_i_likp IS INITIAL.
      MESSAGE i115.
      LEAVE LIST-PROCESSING.
    ELSE. " ELSE -> IF fp_i_likp IS INITIAL

      SORT fp_i_likp BY vbeln.

* Begin of Change for SCTASK0745122 by U033876
* RFC call to EWM with all deliveries to fetch TUs
      PERFORM f_rfc_call CHANGING fp_i_likp.

*End of Change for SCTASK0745122 by U033876


** Get Item data
      SELECT  vbeln " Delivery
              posnr " Delivery Item
              pstyv " Delivery item category
              erdat " Date on Which Record Was Created
              matnr " Material Number
              werks " Receiving plant for deliveries
              lgort " Storage Location
              lfimg " Actual quantity delivered (in sales units)
              meins " Base Unit of Measure
              arktx " Short text for sales order item
              vgbel " Document number of the reference document
              vgpos " Item number of the reference item
              uepos " Higher-level item in bill of material structures
              uecha " Higher-Level Item of Batch Split Item
              vkbur " Sales Office
              vtweg " Distribution Channel
*--> Begin of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
              spart " Division
*<-- End of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
              mvgr1 " Material group 1
              mvgr4 " Material group 4
              prctr " Profit Center
              kzpod " POD indicator (relevance, verification, confirmation)
         FROM lips  " SD document: Delivery: Item data
         INTO TABLE fp_i_lips
         FOR ALL ENTRIES IN fp_i_likp
         WHERE vbeln = fp_i_likp-vbeln.

* Due to performance issue we are doing this SELECT based on VBELN only

* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
      IF sy-subrc EQ 0.

        DELETE fp_i_lips WHERE werks NOT IN s_werks.
        DELETE fp_i_lips WHERE vtweg NOT IN s_vtweg.
*--> Begin of delete for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
*        DELETE fp_i_lips WHERE kzpod NOT IN s_kzpod.
*<-- End of delete for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
        DELETE fp_i_lips WHERE vgbel NOT IN s_vbeln.
        IF fp_i_lips IS INITIAL.
          MESSAGE i115.
          LEAVE LIST-PROCESSING.
        ENDIF. " IF fp_i_lips IS INITIAL
        SORT fp_i_lips BY vbeln posnr.
*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
        lv_payr = lc_py.
        CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
          EXPORTING
            input  = lv_payr
          IMPORTING
            output = lv_payr.

        li_temp[] = fp_i_lips[].
        SORT li_temp BY vgbel.
        DELETE ADJACENT DUPLICATES FROM li_temp COMPARING vgbel.
        IF li_temp IS NOT INITIAL.
* Fetching payer number
          SELECT vbeln     " Sales and Distribution Document Number
                 parvw     " Partner Function
                 kunnr     " Customer Number
                 FROM vbpa " Sales Document: Partner
                 INTO TABLE fp_i_payr
                 FOR ALL ENTRIES IN li_temp
                 WHERE vbeln = li_temp-vgbel
                   AND parvw = lv_payr.
          IF sy-subrc IS INITIAL.
            SORT fp_i_payr BY vbeln.
* Fetching payer billing block status
            SELECT kunnr     " Customer Number
                   faksd     " Central billing block for customer
                   FROM kna1 " General Data in Customer Master
                   INTO TABLE fp_i_paybl
                   FOR ALL ENTRIES IN fp_i_payr
                   WHERE kunnr = fp_i_payr-kunnr.
*--> Begin of delete for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
*                     AND loevm = abap_false.
*<-- End of delete for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
            IF sy-subrc IS INITIAL.
              SORT fp_i_paybl BY kunnr.
*--> Begin of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
              SELECT kunnr " Customer Number
                     vkorg " Sales Organization
                     vtweg " Distribution Channel
                     spart " Division
                     faksd " Billing block for customer (sales and distribution)
                FROM knvv  " Customer Master Sales Data
                INTO TABLE fp_i_knvv
                FOR ALL ENTRIES IN fp_i_paybl
                WHERE kunnr = fp_i_paybl-kunnr.
              IF sy-subrc = 0.
                SORT fp_i_knvv BY kunnr vkorg vtweg spart.
              ENDIF. " IF sy-subrc = 0
*<-- End of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
            ENDIF. " IF sy-subrc IS INITIAL
          ENDIF. " IF sy-subrc IS INITIAL
        ENDIF. " IF li_temp IS NOT INITIAL
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
      ELSE. " ELSE -> IF sy-subrc EQ 0
        "infomation mesaage.
        MESSAGE i115.
        LEAVE LIST-PROCESSING.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF fp_i_likp IS INITIAL
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
  ELSE. " ELSE -> IF sy-subrc EQ 0
    "infomation mesaage.
    MESSAGE i115.
    LEAVE LIST-PROCESSING.

  ENDIF. " IF sy-subrc EQ 0
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018

*  ENDIF. " IF s_wadat[] IS NOT INITIAL
ENDFORM. " F_GET_DELIV_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DOCFLOW
*&---------------------------------------------------------------------*
*       Get Doc flow information
*----------------------------------------------------------------------*
*      -->fP_LIPS  Delivery info
*      <--fP_VBFA  do flow
*----------------------------------------------------------------------*
FORM f_get_docflow  USING    fp_i_lips TYPE ty_lips_t
                    CHANGING fp_i_vbfa TYPE ty_vbfa_t.
  CONSTANTS:lc_0 TYPE plmin VALUE '0'. " Quantity is calculated positively, negatively or not at all
* Get the Doc flow information
  IF fp_i_lips[] IS NOT INITIAL.
    SELECT  vbelv   " Preceding sales and distribution document
            posnv   " Preceding item of an SD document
            vbeln   " Subsequent sales and distribution document
            posnn   " Subsequent item of an SD document
            vbtyp_n " Document category of subsequent document
            rfmng   " Referenced quantity in base unit of measure
            meins   " Base Unit of Measure
*            vbtyp_v " Document category of preceding SD document
            plmin " Quantity is calculated positively, negatively or not at all
            erdat " Date on Which Record Was Created
            erzet " Entry time
      FROM  vbfa  " Sales Document Flow
      INTO TABLE fp_i_vbfa
      FOR ALL ENTRIES IN fp_i_lips
     WHERE vbelv = fp_i_lips-vbeln
       AND posnv = fp_i_lips-posnr
       AND vbtyp_n = c_m
       AND plmin NE lc_0.
    IF sy-subrc EQ 0.
      SORT fp_i_vbfa BY vbelv posnv ASCENDING erdat DESCENDING erzet DESCENDING.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF fp_i_lips[] IS NOT INITIAL
ENDFORM. " F_GET_DOCFLOW
*&---------------------------------------------------------------------*
*&      Form  F_GET_REVENUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->fP_LIPS  text
*      <--fP_I_VBREVE  text
*----------------------------------------------------------------------*
FORM f_get_rev_det  USING    fp_i_lips TYPE ty_lips_t
                    CHANGING fp_i_vbreve TYPE ty_vbreve_t.
  IF fp_i_lips[] IS NOT INITIAL.
    SELECT vbeln    " Sales Document
           posnr    " Sales Document Item
           sakrv    " G/L Account Number
           bdjpoper " Posting year and posting period (YYYYMMM format)
           popupo   " Period sub-item
           vbeln_n  " Subsequent sales and distribution document
           posnr_n  " Subsequent item of an SD document
           wrbtr    " Amount in Document Currency
           waerk    " Currency Key
           sammg    " Group
           reffld   " FI document reference number
           rrsta    " Revenue determination status
           budat    " Posting Date in the Document
           revevdat " Revenue Event Date
      FROM vbreve   " Revenue Recognition: Revenue Recognition Lines
      INTO TABLE fp_i_vbreve
      FOR ALL ENTRIES IN fp_i_lips
     WHERE vbeln = fp_i_lips-vgbel
       AND posnr = fp_i_lips-vgpos
       AND sakrv NE c_vprs
       AND vbeln_n = fp_i_lips-vbeln .
    IF sy-subrc EQ 0.
      SORT fp_i_vbreve BY vbeln posnr vbeln_n posnr_n rrsta.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF fp_i_lips[] IS NOT INITIAL
ENDFORM. " F_GET_REVENUE
*&---------------------------------------------------------------------*
*&      Form  F_GET_BILL_DET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->fP_VBFA  text
*      <--fP_VBRK  text
*----------------------------------------------------------------------*
FORM f_get_bill_det  USING    fp_i_vbfa TYPE ty_vbfa_t
                     CHANGING fp_i_vbrk TYPE ty_vbrk_t
                              fp_i_vbrp TYPE ty_vbrp_t.
  IF fp_i_vbfa[] IS NOT INITIAL.
*     Select data from billing document header table
    SELECT vbeln " Billing Document
           fkart " Billing Type
           waerk " SD Document Currency
           fkdat " Billing date for billing index and printout
           rfbsk " Status for transfer to accounting
           netwr " Net Value in Document Currency
           fksto " Billing document is cancelled
      FROM vbrk  " Billing Document: Header Data
      INTO TABLE fp_i_vbrk
      FOR ALL ENTRIES IN fp_i_vbfa
     WHERE vbeln = fp_i_vbfa-vbeln.

    IF sy-subrc EQ 0.
      DELETE fp_i_vbrk WHERE fksto NE abap_false.
      SORT fp_i_vbrk BY vbeln.

*     Select data from billing document item table
      SELECT vbeln " Billing Document
             posnr " Billing Type
             netwr " Net Value in Document Currency
* Begin of Change for SCTASK0745122 by U033876
             vgbel
             vgpos
* end of Change for SCTASK0745122 by U033876
        FROM vbrp " Billing Document: Header Data
        INTO TABLE fp_i_vbrp
        FOR ALL ENTRIES IN fp_i_vbfa
       WHERE vbeln = fp_i_vbfa-vbeln
       AND   posnr = fp_i_vbfa-posnn.
      IF sy-subrc EQ 0.
        SORT fp_i_vbrp BY vbeln posnr.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF fp_i_vbfa[] IS NOT INITIAL
ENDFORM. " F_GET_BILL_DET
*&---------------------------------------------------------------------*
*&      Form  F_GET_ACCNT_DET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->fP_VBREVE  text
*      <--fP_BKPF  text
*----------------------------------------------------------------------*
FORM f_get_accnt_det  USING    fp_i_vbreve TYPE ty_vbreve_t
                      CHANGING fp_i_bkpf TYPE ty_bkpf_t.

  TYPES: BEGIN OF lty_awkey,
           awkey TYPE awkey, " Reference Key
         END   OF lty_awkey.

  DATA: lwa_awkey TYPE lty_awkey,                   " Include: Ranges in selection conditions
        li_awkey  TYPE STANDARD TABLE OF lty_awkey. " Include: Ranges in selection conditions
  FIELD-SYMBOLS: <lfs_vbreve>   TYPE  ty_vbreve.

  LOOP AT fp_i_vbreve ASSIGNING  <lfs_vbreve>.
    CONCATENATE <lfs_vbreve>-sammg <lfs_vbreve>-reffld INTO lwa_awkey-awkey.
    APPEND lwa_awkey TO li_awkey.
    CLEAR lwa_awkey.
  ENDLOOP. " LOOP AT fp_i_vbreve ASSIGNING <lfs_vbreve>

  IF li_awkey[] IS NOT INITIAL.
*     Select Acct. Doc. No. based on reference number
    SELECT bukrs " Company Code
           belnr " Accounting Document Number
           gjahr " Fiscal Year
           awtyp " Reference Transaction
           awkey " Reference Key
      FROM bkpf  " Accounting Document Header
      INTO TABLE fp_i_bkpf
      FOR ALL ENTRIES IN li_awkey
      WHERE awtyp = c_vbrr
      AND   awkey = li_awkey-awkey.
    IF sy-subrc = 0 .
      SORT fp_i_bkpf BY awtyp awkey.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_awkey[] IS NOT INITIAL
ENDFORM. " F_GET_ACCNT_DET
*&---------------------------------------------------------------------*
*&      Form  F_GET_ORDER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->fP_LIPS[]  text
*      <--fP_VBAK[]  text
*      <--fP_VBAP[]  text
*----------------------------------------------------------------------*
FORM f_get_order_data  USING    fp_i_lips   TYPE ty_lips_t
                       CHANGING fp_i_vbak  TYPE ty_vbak_t
                                fp_i_vbap  TYPE ty_vbap_t.
  IF fp_i_lips[] IS NOT INITIAL.
    SELECT vbeln  " Sales Document
           posnr  " Sales Document Item
           faksp  " Billing block for item
           netwr  " Net value of the order item in document currency
           waerk  " SD Document Currency
           kwmeng " Cumulative Order Quantity in Sales Units
           ktgrm  " Account assignment group for this material
       FROM vbap  " Sales Document: Item Data
       INTO TABLE fp_i_vbap
       FOR ALL ENTRIES IN fp_i_lips
       WHERE vbeln = fp_i_lips-vgbel
       AND   posnr = fp_i_lips-vgpos.
    IF sy-subrc = 0.
      SORT fp_i_vbap BY vbeln posnr.

      SELECT vbeln " Sales Document
             erdat " Date on Which Record Was Created
             ernam " Name of Person who Created the Object
             auart " Sales Document Type
             faksk " Billing block for item
             waerk " SD Document Currency Change for SCTASK0745122 by U033876
             knumv " Number of the document condition
         FROM vbak " Sales Document: Item Data
         INTO TABLE fp_i_vbak
         FOR ALL ENTRIES IN fp_i_vbap
         WHERE vbeln = fp_i_vbap-vbeln.
      IF sy-subrc = 0.
        SORT fp_i_vbak BY vbeln.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0

  ENDIF. " IF fp_i_lips[] IS NOT INITIAL
ENDFORM. " F_GET_ORDER_DATA
*&---------------------------------------------------------------------*
*&      Form  F_GET_CUST_DATA
*&---------------------------------------------------------------------*
*       Get Customer data(Sold-to  and Payer)
*----------------------------------------------------------------------*
*      -->fP_I_LIKP  Header data.
*      <--fP_KNA1  text
*----------------------------------------------------------------------*
FORM f_get_cust_data  USING
* ---> Begin of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
*                               fp_i_lips   TYPE ty_lips_t
* <--- End of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
                               fp_i_likp   TYPE ty_likp_t
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
                      CHANGING fp_i_kna1   TYPE ty_kna1_t.

* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
  DATA: li_likp_tmp  TYPE ty_likp_t,
        lwa_likp_tmp TYPE ty_likp.
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018

* Do logic for payer and Sold-to

* ---> Begin of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
*  IF fp_i_lips[] IS NOT INITIAL.
* <--- End of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
* Get Sold-to and payer data based on Header data
  IF fp_i_likp[] IS NOT INITIAL.
    li_likp_tmp[] = fp_i_likp[].
* Now take the KUNAG
    LOOP AT fp_i_likp INTO lwa_likp_tmp.
      lwa_likp_tmp-kunnr = lwa_likp_tmp-kunag.
      APPEND lwa_likp_tmp TO li_likp_tmp.
    ENDLOOP. " LOOP AT fp_i_likp INTO lwa_likp_tmp
    SORT li_likp_tmp BY kunnr.
    DELETE ADJACENT DUPLICATES FROM li_likp_tmp COMPARING kunnr.
    IF li_likp_tmp IS NOT INITIAL.

* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
      SELECT kunnr " Sales Document
             name1 " Name 1
             aufsd " Sales Document Item
             faksd " Billing block for item
             lifsd " Central delivery block for the customer
         FROM kna1 " Sales Document: Item Data
         INTO TABLE fp_i_kna1
* ---> Begin of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
*       FOR ALL ENTRIES IN fp_i_lips
*       WHERE kunnr = fp_i_lips-kunnr.
* <--- End of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
         FOR ALL ENTRIES IN li_likp_tmp
         WHERE kunnr = li_likp_tmp-kunnr.
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
      IF sy-subrc = 0.
        SORT fp_i_kna1 BY kunnr.

*--> Begin of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
        SELECT kunnr " Customer Number
               vkorg " Sales Organization
               vtweg " Distribution Channel
               spart " Division
               faksd " Billing block for customer (sales and distribution)
          FROM knvv  " Customer Master Sales Data
          INTO TABLE i_knvv_soldto
          FOR ALL ENTRIES IN fp_i_kna1
          WHERE kunnr = fp_i_kna1-kunnr.
        IF sy-subrc = 0.
          SORT i_knvv_soldto BY kunnr vkorg vtweg spart.
        ENDIF. " IF sy-subrc = 0
*<-- End of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF li_likp_tmp IS NOT INITIAL
** ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
*** Intentionally,second select has been put there to get the data. Other way around was
**to make an a table by looping the value of kunnr as well as Kunag, this will also take
** some effort. So performance would not impact by using second select.
*
*    CLEAR li_likp_tmp[].
*    li_likp_tmp[] = fp_i_likp[].
*    SORT li_likp_tmp BY kunag.
*    DELETE ADJACENT DUPLICATES FROM li_likp_tmp COMPARING kunag.
*    IF li_likp_tmp IS NOT INITIAL.
** Get Sold to Party Customers
*      SELECT kunnr " Sales Document
*             name1 " Name 1
*             aufsd " Sales Document Item
*             faksd " Billing block for item
*             lifsd " Central delivery block for the customer
*         FROM kna1 " Sales Document: Item Data
*         APPENDING TABLE fp_i_kna1
*         FOR ALL ENTRIES IN li_likp_tmp
*         WHERE kunnr = li_likp_tmp-kunag.
*      IF sy-subrc EQ 0.
*        SORT fp_i_kna1 BY kunnr.
*      ENDIF. " IF sy-subrc EQ 0
*    ENDIF. " IF li_likp_tmp IS NOT INITIAL
** <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
  ENDIF. " IF fp_i_likp[] IS NOT INITIAL

ENDFORM. " F_GET_CUST_DATA
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_FINAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->fP_LIPS  text
*      -->FP_I_LIKP Header data
*      -->fp_VBAP  text
*      -->fP_VBAK  text
*      -->fP_KNA1  text
*      -->fP_VBFA  text
*      -->fP_VBRK  text
*      -->fP_VBREVE  text
*      -->fP_BKPF  text
*      <--fP_FINAL  text
*----------------------------------------------------------------------*
FORM f_prepare_final  USING    fp_i_lips    TYPE ty_lips_t
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
                               fp_i_likp    TYPE ty_likp_t
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
                               fp_i_vbup    TYPE ty_vbup_t
                               fp_i_vbap    TYPE ty_vbap_t
                               fp_vpobj     TYPE vpobj " Packing Object
                               fp_i_vekp    TYPE ty_vekp_t
                               fp_i_vbak    TYPE ty_vbak_t
                               fp_i_konv    TYPE ty_konv_t
                               fp_i_kna1    TYPE ty_kna1_t
*--> Begin of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
                               fp_i_knvv    TYPE ty_knvv_t
*<-- End of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
                               fp_i_vbfa    TYPE ty_vbfa_t
                               fp_i_vbrk    TYPE ty_vbrk_t
                               fp_i_vbrp    TYPE ty_vbrp_t
                               fp_i_vbreve  TYPE ty_vbreve_t
                               fp_i_bkpf    TYPE ty_bkpf_t
                               fp_i_tvkot   TYPE ty_tvkot_t
                               fp_i_tvm1t   TYPE ty_tvm1t_t
*                               fp_tvm4t   TYPE ty_tvm4t_t
                               fp_i_tvrot   TYPE ty_tvrot_t
                               fp_i_tvkmt   TYPE ty_tvkmt_t
*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
                               fp_i_payr    TYPE ty_payr_t
                               fp_i_paybl   TYPE ty_paybl_t
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
*---> Begin of Change for SCTASK0745122 by U033876
*                               fp_a005_komp TYPE ty_ic_a005_konp_t
                               fp_ic_ar_bill  TYPE ty_ic_ar_bill_t
                               fp_i_bkpf_ap   TYPE ty_bkpf_ap_t
                               fp_ic_bill_acc  TYPE ty_ic_bill_acc_t
*<--End of Change for SCTASK0745122 by U033876
                      CHANGING fp_i_final   TYPE ty_final_t.
  TYPES : BEGIN OF lty_vbreve_tmp,
            vbeln   TYPE  vbeln_va,   " Sales Document
            posnr   TYPE  posnr_va,   " Sales Document Item
            vbeln_n TYPE  vbeln_nach, " Subsequent sales and distribution document
            posnr_n TYPE  posnr_nach, " Subsequent item of an SD document
            sammg   TYPE  sammg,      " Group
            reffld  TYPE  rr_reffld,  " FI document reference number
            rrsta   TYPE  rr_status,  " Revenue determination status
            wrbtr   TYPE  wrbtr,      " Amount in Document Currency
            waerk   TYPE  waers,      " Currency Key
          END OF lty_vbreve_tmp.

* Begin of SCTASK
  TYPES : BEGIN OF lty_mkpf,
            usnam TYPE usnam,   " User name
            xblnr TYPE xblnr1,  " Reference Document Number
          END OF lty_mkpf,
          BEGIN OF lty_lips,
            xblnr TYPE xblnr1, " Reference Document Number
          END OF lty_lips,
          BEGIN OF lty_vbfa,
            vbelv	TYPE vbeln_von,
            posnv	TYPE posnr_von,
            vbeln	TYPE vbeln_nach,
            posnn	TYPE posnr_nach,
            rfwrt	TYPE rfwrt,
            waers	TYPE waers_v,
          END OF lty_vbfa.
* End of SCTASK

  DATA: lwa_final       TYPE ty_final,
        lv_awkey        TYPE awkey,      " Reference Key
        lv_cnt          TYPE i,          " Cnt of type Integers
        lv_track_cnt    TYPE i,       " Track_cnt of type Integers
        lv_vpobjkey     TYPE vpobjkey, " Key for Object to Which the Handling Unit is Assigned
        li_vbreve_tmp   TYPE ty_vbreve_t,
        lv_tabix        TYPE sy-tabix,   " Index of Internal Tables
        lwa_vbreve      TYPE ty_vbreve,
        lwa_vbreve_tmp  TYPE lty_vbreve_tmp,
        li_vbreve_tmp1  TYPE STANDARD TABLE OF lty_vbreve_tmp,
        lv_status_a     TYPE flag,   " General Flag
        lv_status_c     TYPE flag,   " General Flag
* Begin of change for Sctask: SCTASK0745122 Intercompany Billing Accural fields by U033876
        lwa_ic_bill_acc TYPE ty_ic_bill_acc,
* End of change for Sctask: SCTASK0745122 Intercompany Billing Accural fields by U033876
*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
        lwa_payr        TYPE ty_payr,  " local work-area
        lwa_paybl       TYPE ty_paybl, " local work-area
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
*--> Begin of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
        lwa_knvv        TYPE ty_knvv, " Local work area for KNVV table selection
*<-- End of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
* Begin of SCTASK
        lwa_mkpf        TYPE lty_mkpf,
        li_mkpf         TYPE STANDARD TABLE OF lty_mkpf,
        lwa_lips        TYPE lty_lips,
        li_lips         TYPE STANDARD TABLE OF lty_lips,
        lwa_vbfa        TYPE lty_vbfa,
        li_vbfa         TYPE STANDARD TABLE OF lty_vbfa.
* End of SCTASK

  DATA: lwa_ic_ar_bill TYPE ty_ic_ar_bill,
*          lwa_ic_a005_konp TYPE ty_ic_a005_konp,
        lwa_bkpf_ap    TYPE ty_bkpf_ap.

  FIELD-SYMBOLS: <lfs_lips>        TYPE ty_lips,
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
                 <lfs_likp>        TYPE ty_likp,
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
                 <lfs_vbap>        TYPE ty_vbap,
                 <lfs_vbak>        TYPE ty_vbak,
                 <lfs_vbup>        TYPE ty_vbup,
                 <lfs_vekp>        TYPE ty_vekp,
                 <lfs_vekp_tmp>    TYPE ty_vekp,
                 <lfs_konv>        TYPE ty_konv,
                 <lfs_kna1>        TYPE ty_kna1,
                 <lfs_vbfa>        TYPE ty_vbfa,
                 <lfs_vbrk>        TYPE ty_vbrk,
                 <lfs_vbrp>        TYPE ty_vbrp,
                 <lfs_vbreve>      TYPE ty_vbreve,
                 <lfs_vbreve_temp> TYPE ty_vbreve,
                 <lfs_vbreve_tmp>  TYPE lty_vbreve_tmp,
                 <lfs_bkpf>        TYPE ty_bkpf,
                 <lfs_tvkot>       TYPE ty_tvkot,
                 <lfs_tvm1t>       TYPE ty_tvm1t,
                 <lfs_tvrot>       TYPE ty_tvrot,
                 <lfs_tvkmt>       TYPE ty_tvkmt.

  CONSTANTS: lc_status_ca TYPE char2 VALUE  'CA',  " Status_ca of type CHAR2
             lc_status_a  TYPE rr_status VALUE  'A', " Revenue determination status
             lc_status_c  TYPE rr_status VALUE  'C'. " Revenue determination status

* Begin of SCTASK
  LOOP AT fp_i_lips ASSIGNING  <lfs_lips>.
    lwa_lips-xblnr = <lfs_lips>-vbeln.
    APPEND lwa_lips TO li_lips.
  ENDLOOP. " LOOP AT fp_i_lips ASSIGNING <lfs_lips>
  IF li_lips IS NOT INITIAL.
    SORT li_lips BY xblnr.
    DELETE ADJACENT DUPLICATES FROM li_lips COMPARING xblnr.
    SELECT usnam xblnr FROM mkpf INTO TABLE li_mkpf
                         FOR ALL ENTRIES IN li_lips
                         WHERE xblnr EQ li_lips-xblnr
                           AND tcode2 EQ 'VLPOD'.
    IF sy-subrc EQ 0.
      SORT li_mkpf BY xblnr.
      DELETE ADJACENT DUPLICATES FROM li_mkpf COMPARING xblnr.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_lips IS NOT INITIAL
  IF fp_i_lips IS NOT INITIAL.
    SELECT vbelv posnv vbeln posnn rfwrt waers FROM vbfa INTO TABLE li_vbfa
                                          FOR ALL ENTRIES IN fp_i_lips
                                          WHERE vbelv EQ fp_i_lips-vbeln
                                            AND posnv EQ fp_i_lips-posnr
                                            AND vbtyp_n EQ 'R'.
    IF sy-subrc EQ 0.
      SORT li_vbfa BY vbelv  posnv.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF fp_i_lips IS NOT INITIAL
* End of SCTASK

  LOOP AT fp_i_lips ASSIGNING  <lfs_lips>.

    lwa_final-vbeln = <lfs_lips>-vbeln.
* ---> Begin of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
** These fields are coming from LIKP table now, so commented here and populated below.
*    lwa_final-route = <lfs_lips>-route.
*    lwa_final-kunnr = <lfs_lips>-kunnr.
*    lwa_final-kunag = <lfs_lips>-kunag.
*    lwa_final-vstel = <lfs_lips>-vstel.
*    lwa_final-vkorg = <lfs_lips>-vkorg.
*    lwa_final-lfart = <lfs_lips>-lfart.
*    lwa_final-wadat_ist = <lfs_lips>-wadat_ist.
*    lwa_final-podat = <lfs_lips>-podat .
* <--- End of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018

    lwa_final-posnr = <lfs_lips>-posnr.
    lwa_final-pstyv = <lfs_lips>-pstyv.
    lwa_final-erdat = <lfs_lips>-erdat.
* ---> Begin of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
*    lwa_final-matnr = <lfs_lips>-matnr.
* <--- End of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
* Begin of SCTASK
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*      EXPORTING
*        input  = <lfs_lips>-matnr
*      IMPORTING
*        output = lwa_final-matnr.
    lwa_final-matnr = <lfs_lips>-matnr.
* End of SCTASK
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018

    lwa_final-werks = <lfs_lips>-werks.
    lwa_final-lgort = <lfs_lips>-lgort.
    lwa_final-lfimg = <lfs_lips>-lfimg.
    lwa_final-meins = <lfs_lips>-meins.
    lwa_final-arktx = <lfs_lips>-arktx.
    lwa_final-vgbel = <lfs_lips>-vgbel.
    lwa_final-vgpos = <lfs_lips>-vgpos.
    lwa_final-uepos = <lfs_lips>-uepos.
    lwa_final-vkbur = <lfs_lips>-vkbur.
    lwa_final-vtweg = <lfs_lips>-vtweg.
    lwa_final-mvgr1 = <lfs_lips>-mvgr1.
*    lwa_final-mvgr4 = <lfs_lips>-mvgr4.
    lwa_final-prctr = <lfs_lips>-prctr.
    lwa_final-kzpod = <lfs_lips>-kzpod.


* Get the details for Tracking no.
    CLEAR: lv_track_cnt,  lv_vpobjkey.

    lv_vpobjkey = <lfs_lips>-vbeln.

* Parallel cursor for vekp
* New logic "T" can be either in SPE_IDART_01 or SPE_IDART_03
* Also if SPE_IDART_01 has "T" then take SPE_IDENT_01 as tracking no
* and if SPE_IDART_03 has "T" then Take SPE_IDART_03 as tracking no
    READ TABLE fp_i_vekp ASSIGNING <lfs_vekp_tmp>
                                        WITH KEY vpobj = fp_vpobj
                                                 vpobjkey = lv_vpobjkey
                                                 spe_idart_01 = c_t.
*                                                 BINARY SEARCH.
    IF sy-subrc NE 0.
      READ TABLE fp_i_vekp ASSIGNING <lfs_vekp_tmp>
                                     WITH KEY vpobj = fp_vpobj
                                              vpobjkey = lv_vpobjkey
                                              spe_idart_03 = c_t.
*                                                 BINARY SEARCH.
    ENDIF. " IF sy-subrc NE 0
    IF sy-subrc = 0.

      CLEAR: lv_tabix.
      lv_tabix = sy-tabix.
      LOOP AT fp_i_vekp ASSIGNING <lfs_vekp> FROM lv_tabix.
        IF <lfs_vekp>-vpobj <> <lfs_vekp_tmp>-vpobj
        OR <lfs_vekp>-vpobjkey <> <lfs_vekp_tmp>-vpobjkey
        OR  <lfs_vekp>-spe_idart_01 <> <lfs_vekp_tmp>-spe_idart_01.
          EXIT.
        ENDIF. " IF <lfs_vekp>-vpobj <> <lfs_vekp_tmp>-vpobj
        IF <lfs_vekp>-spe_idart_01 = c_t.
          lwa_final-spe_ident_01 = <lfs_vekp>-spe_ident_01.
        ELSEIF <lfs_vekp>-spe_idart_03 = c_t.
          lwa_final-spe_ident_01 = <lfs_vekp>-spe_ident_03.
        ENDIF. " IF <lfs_vekp>-spe_idart_01 = c_t
        lv_track_cnt = lv_track_cnt + 1.
      ENDLOOP. " LOOP AT fp_i_vekp ASSIGNING <lfs_vekp> FROM lv_tabix
      lwa_final-track_num = lv_track_cnt.

    ENDIF. " IF sy-subrc = 0

* ---> Begin of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
*Sales org is populated below after reading the data from FP_I_LIKP table
**Sales org Description
*    READ TABLE fp_i_tvkot ASSIGNING <lfs_tvkot>
*                        WITH KEY spras  = sy-langu
*                                 vkorg = <lfs_lips>-vkorg BINARY SEARCH.
*    IF sy-subrc = 0.
*      lwa_final-vkorgt = <lfs_tvkot>-vtext.
*    ENDIF. " IF sy-subrc = 0
* <--- End of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018

* Material Group1 Description
    READ TABLE fp_i_tvm1t ASSIGNING <lfs_tvm1t>
                        WITH KEY spras  = sy-langu
                                  mvgr1 = <lfs_lips>-mvgr1 BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_final-bezei1 = <lfs_tvm1t>-bezei.
    ENDIF. " IF sy-subrc = 0

** Material Group4 Description
* ---> Begin of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
*Material Group4 Description is populated below after reading the data from FP_I_LIKP table
*    READ TABLE fp_i_tvrot ASSIGNING <lfs_tvrot> WITH KEY route = <lfs_lips>-route
*                                                                    BINARY SEARCH.
*    IF sy-subrc IS INITIAL.
*      lwa_final-bezei_r =    <lfs_tvrot>-bezei. "route.
*    ENDIF. " IF sy-subrc IS INITIAL
* <--- End of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018

*Move order info
* first check if we have a billing block on item, if yes then set
* else check at header and set the billing block flag.
    READ TABLE fp_i_vbap ASSIGNING <lfs_vbap>
                      WITH KEY vbeln = <lfs_lips>-vgbel
                               posnr = <lfs_lips>-vgpos BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_final-ktgrm = <lfs_vbap>-ktgrm.
      lwa_final-faksp = <lfs_vbap>-faksp.
* Code for Net value
**&& -- Populating the value of Net Value
      IF <lfs_vbap>-kwmeng IS NOT INITIAL.
        lwa_final-netwr = ( ( ( <lfs_vbap>-netwr ) * ( <lfs_lips>-lfimg ) ) / ( <lfs_vbap>-kwmeng ) ).
      ELSE. " ELSE -> IF <lfs_vbap>-kwmeng IS NOT INITIAL
        lwa_final-netwr = 0.
      ENDIF. " IF <lfs_vbap>-kwmeng IS NOT INITIAL
* code for Billing Block
      IF <lfs_vbap>-faksp = abap_true.
        lwa_final-faksk = abap_true.
      ELSE. " ELSE -> IF <lfs_vbap>-faksp = abap_true
        READ TABLE fp_i_vbak ASSIGNING <lfs_vbak>
                      WITH KEY vbeln = <lfs_lips>-vgbel
                               BINARY SEARCH.
        IF sy-subrc = 0 AND <lfs_vbak>-faksk IS NOT INITIAL.
          lwa_final-faksk = <lfs_vbak>-faksk.
        ENDIF. " IF sy-subrc = 0 AND <lfs_vbak>-faksk IS NOT INITIAL
      ENDIF. " IF <lfs_vbap>-faksp = abap_true

* get Account Assignment group description

* Material Group4 Description
      READ TABLE fp_i_tvkmt ASSIGNING <lfs_tvkmt>
                          WITH KEY spras  = sy-langu
                                   ktgrm = <lfs_vbap>-ktgrm BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_final-ktgrmt = <lfs_tvkmt>-vtext.
      ENDIF. " IF sy-subrc = 0


* get the Conition value
      READ TABLE fp_i_vbak ASSIGNING <lfs_vbak>
                    WITH KEY vbeln = <lfs_lips>-vgbel
                             BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_final-erdat_s = <lfs_vbak>-erdat.
        lwa_final-ernam_s = <lfs_vbak>-ernam.
        lwa_final-auart   = <lfs_vbak>-auart.
* Begin of Change for SCTASK0745122 by U033876
* for IC currency
*        lwa_final-ic_waerk = <lfs_vbak>-waerk.
* End of change for SCTASK0745122 by U033876
        READ TABLE fp_i_konv ASSIGNING <lfs_konv> WITH KEY knumv = <lfs_vbak>-knumv
                                                         kposn = <lfs_lips>-vgpos
                                                                      BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          lwa_final-kwert_k = <lfs_konv>-kwert_k.
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF sy-subrc = 0

    ENDIF. " IF sy-subrc = 0

    READ TABLE fp_i_vbup ASSIGNING <lfs_vbup> WITH KEY vbeln = <lfs_lips>-vbeln
                                                     posnr = <lfs_lips>-posnr
                                                                   BINARY SEARCH.
    IF sy-subrc IS INITIAL.
**&& -- Populating the value for POD Status Description
      lwa_final-pdsta_value = <lfs_vbup>-pdsta.
      IF <lfs_vbup>-pdsta = c_pdsta_a.
        lwa_final-pdsta = icon_red_light.
      ELSEIF <lfs_vbup>-pdsta = c_pdsta_b.
        lwa_final-pdsta = icon_yellow_light.
      ELSEIF <lfs_vbup>-pdsta = c_pdsta_c.
        lwa_final-pdsta = icon_green_light.
      ENDIF. " IF <lfs_vbup>-pdsta = c_pdsta_a
*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
    ELSE. " ELSE -> IF sy-subrc IS INITIAL
      CLEAR lwa_final.
      CONTINUE.
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
    ENDIF. " IF sy-subrc IS INITIAL

* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
    READ TABLE fp_i_likp ASSIGNING <lfs_likp> WITH KEY vbeln = <lfs_lips>-vbeln BINARY SEARCH.
    IF sy-subrc EQ 0.
      lwa_final-route = <lfs_likp>-route.
      lwa_final-kunnr = <lfs_likp>-kunnr.
      lwa_final-kunag = <lfs_likp>-kunag.
      lwa_final-vstel = <lfs_likp>-vstel.
      lwa_final-vkorg = <lfs_likp>-vkorg.
      lwa_final-lfart = <lfs_likp>-lfart.
      lwa_final-wadat_ist = <lfs_likp>-wadat_ist.
      lwa_final-podat = <lfs_likp>-podat .
* Begin of Change for SCTASK0745122 by u033876
      lwa_final-vkoiv = <lfs_likp>-vkoiv.
      lwa_final-vtwiv = <lfs_likp>-vtwiv.
      lwa_final-kuniv = <lfs_likp>-kuniv.

**IC AR Revenue
*      LOOP AT fp_a005_komp INTO lwa_ic_a005_konp
*                              WHERE kappl  = c_v
*                              AND   kschl  = c_zppm
*                              AND   vkorg  = lwa_final-vkoiv
*                              AND   vtweg  = lwa_final-vtwiv
*                              AND   kunnr  = lwa_final-kuniv
*                              AND   matnr  = lwa_final-matnr " already moved from lips
*                              AND   datbi  GE <lfs_likp>-wadat_ist
*                              AND   datab  LE <lfs_likp>-wadat_ist.
*        lwa_final-ic_kbetr = lwa_ic_a005_konp-kbetr.
*      ENDLOOP. " LOOP AT fp_a005_komp INTO lwa_ic_a005_konp

* End of change for SCTASK0745122 by U033876
*Sales org Description
      READ TABLE fp_i_tvkot ASSIGNING <lfs_tvkot>
                          WITH KEY spras  = sy-langu
                                   vkorg = <lfs_likp>-vkorg
                                   BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_final-vkorgt = <lfs_tvkot>-vtext.
      ENDIF. " IF sy-subrc = 0

** Material Group4 Description
      READ TABLE fp_i_tvrot ASSIGNING <lfs_tvrot>
                            WITH KEY route = <lfs_likp>-route
                            BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        lwa_final-bezei_r =    <lfs_tvrot>-bezei. "route.
      ENDIF. " IF sy-subrc IS INITIAL
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018

* Move customer info (blocked)

*--> Begin of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
      CLEAR lwa_knvv.
      READ TABLE fp_i_knvv INTO lwa_knvv WITH KEY kunnr = <lfs_likp>-kunag
                                                  vkorg = lwa_final-vkorg
                                                  vtweg = lwa_final-vtweg
                                                  spart = <lfs_lips>-spart
                                                  BINARY SEARCH.
      IF sy-subrc = 0.

        lwa_final-cust_block = lwa_knvv-faksd.
      ENDIF. " IF sy-subrc = 0
*<-- End of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
* if the customer is blocked then set the blocked flag
      READ TABLE fp_i_kna1 ASSIGNING <lfs_kna1>
* ---> Begin of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
*                      WITH KEY kunnr = <lfs_lips>-kunnr
* <--- End of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
                        WITH KEY kunnr = <lfs_likp>-kunag
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
                                 BINARY SEARCH.
      IF sy-subrc = 0.
*--> Begin of delete for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
*        IF ( <lfs_kna1>-aufsd = abap_true ) OR
*           ( <lfs_kna1>-faksd = abap_true ) OR
*           ( <lfs_kna1>-lifsd = abap_true ) .
*          lwa_final-cust_block = abap_true.
*        ENDIF. " IF ( <lfs_kna1>-aufsd = abap_true ) OR
*        IF <lfs_kna1>-aufsd IS NOT INITIAL.
*          lwa_final-cust_block = <lfs_kna1>-aufsd.
*        ELSEIF <lfs_kna1>-faksd IS NOT INITIAL.
*          lwa_final-cust_block = <lfs_kna1>-faksd.
*        ELSEIF <lfs_kna1>-lifsd IS NOT INITIAL.
*          lwa_final-cust_block = <lfs_kna1>-lifsd.
*        ENDIF. " IF <lfs_kna1>-aufsd IS NOT INITIAL
*<-- End of delete for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU

*--> Begin of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
        IF lwa_final-cust_block IS INITIAL.
          lwa_final-cust_block = <lfs_kna1>-faksd.
        ENDIF. " IF lwa_final-cust_block IS INITIAL
*<-- End of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
        lwa_final-kwename = <lfs_kna1>-name1.
      ENDIF. " IF sy-subrc = 0

      READ TABLE fp_i_kna1 ASSIGNING <lfs_kna1>
* ---> Begin of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
*                      WITH KEY kunnr = <lfs_lips>-kunag
* <--- End of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
                        WITH KEY kunnr = <lfs_likp>-kunag
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
                                 BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_final-kagname = <lfs_kna1>-name1.
      ENDIF. " IF sy-subrc = 0

* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
    ENDIF. " IF sy-subrc EQ 0
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018

* Move VBFA data

    READ TABLE fp_i_vbfa ASSIGNING <lfs_vbfa>
                                 WITH KEY vbelv = <lfs_lips>-vbeln
                                          posnv = <lfs_lips>-posnr
                                          BINARY SEARCH.
    IF sy-subrc EQ 0.


      READ TABLE fp_i_vbrk ASSIGNING <lfs_vbrk>
                                     WITH KEY vbeln = <lfs_vbfa>-vbeln
                                     BINARY SEARCH.
      IF sy-subrc EQ 0.
        lwa_final-vbeln_bill = <lfs_vbrk>-vbeln.
        lwa_final-rfmng      = <lfs_vbfa>-rfmng.
        lwa_final-meins_bill = <lfs_vbfa>-meins.
        lwa_final-fkart   = <lfs_vbrk>-fkart.
        lwa_final-fkdat   = <lfs_vbrk>-fkdat.
        lwa_final-rfbsk   = <lfs_vbrk>-rfbsk.
*        lwa_final-netwr_vf = <lfs_vbrk>-netwr.
        lwa_final-waerk_vf = <lfs_vbrk>-waerk.


        READ TABLE fp_i_vbrp ASSIGNING <lfs_vbrp>
                                       WITH KEY vbeln = <lfs_vbfa>-vbeln
                                                posnr = <lfs_vbfa>-posnn
                                                BINARY SEARCH.
        IF sy-subrc EQ 0.
          lwa_final-vbeln_bill = <lfs_vbrp>-vbeln.
          lwa_final-posnn_bill = <lfs_vbrp>-posnr.
          lwa_final-netwr_vf   = <lfs_vbrp>-netwr.
        ENDIF. " IF sy-subrc EQ 0

      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
* Begin of change for SCTASK0745122 by U033876
*IC AR Billing Invoice & IC AR Invoice line item
*          READ TABLE fp_ic_ar_bill INTO lwa_ic_ar_bill
*                                  WITH KEY ic_vgbel = <lfs_vbrp>-vgbel
*                                           ic_vgpos = <lfs_vbrp>-vgpos.
    READ TABLE fp_ic_ar_bill INTO lwa_ic_ar_bill
                            WITH KEY ic_vgbel = <lfs_lips>-vbeln
                                     ic_vgpos = <lfs_lips>-posnr.
    IF sy-subrc = 0.
      lwa_final-ic_vbeln = lwa_ic_ar_bill-ic_vbeln.
      lwa_final-ic_posnr = lwa_ic_ar_bill-ic_posnr.
      lwa_final-ic_netwr = lwa_ic_ar_bill-ic_netwr.
      lwa_final-ic_waerk = lwa_ic_ar_bill-ic_waerk.
      lwa_final-ic_fkdat = lwa_ic_ar_bill-ic_fkdat.
      lwa_final-ic_rfbsk = lwa_ic_ar_bill-ic_rfbsk.
* IC AP Invoice
      READ TABLE fp_i_bkpf_ap INTO lwa_bkpf_ap
                              WITH KEY xblnr = lwa_final-ic_vbeln
                              BINARY SEARCH.
      IF sy-subrc = 0 AND lwa_bkpf_ap-belnr IS NOT INITIAL.
        lwa_final-ap_belnr = lwa_bkpf_ap-belnr.
        lwa_final-ap_bstat = lc_status_c.
      ENDIF. " IF sy-subrc = 0 AND lwa_bkpf_ap-belnr IS NOT INITIAL

    ENDIF. " IF sy-subrc = 0
* End of change for SCTASK0745122 by U033876
* Move Rev Recog Data
    CLEAR: lv_tabix , lwa_vbreve.

    CLEAR:li_vbreve_tmp[], lv_status_a,lv_status_c.
    li_vbreve_tmp[] = fp_i_vbreve[].
    DELETE li_vbreve_tmp WHERE sakrv = c_vprs.
    SORT li_vbreve_tmp BY vbeln posnr vbeln_n posnr_n rrsta.

* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
** This change was done at onsite.We just put the tag at offshore
    IF <lfs_lips>-lfimg IS NOT INITIAL.
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
* Overall Revenue Recog status
      READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve>
                                            WITH KEY vbeln   = <lfs_lips>-vgbel
                                                     posnr   = <lfs_lips>-vgpos
                                                     vbeln_n = <lfs_lips>-vbeln
                                                     posnr_n = <lfs_lips>-posnr
                                                     rrsta   = lc_status_a
                                                     BINARY SEARCH.
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
** This change was done at onsite.We just put the tag at offshore
      IF sy-subrc NE 0.
        READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve>
                                           WITH KEY vbeln   = <lfs_lips>-vgbel
                                                    posnr   = <lfs_lips>-vgpos
                                                    vbeln_n = <lfs_lips>-vbeln
                                                    posnr_n = <lfs_lips>-uecha
                                                    rrsta   = lc_status_a
                                                    BINARY SEARCH.
      ENDIF. " IF sy-subrc NE 0
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
      IF sy-subrc = 0.
        lv_status_a = abap_true.
      ENDIF. " IF sy-subrc = 0

      READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve>
                                          WITH KEY vbeln   = <lfs_lips>-vgbel
                                                   posnr   = <lfs_lips>-vgpos
                                                   vbeln_n = <lfs_lips>-vbeln
                                                   posnr_n = <lfs_lips>-posnr
                                                   rrsta   = lc_status_c
                                                   BINARY SEARCH.

* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
** This change was done at onsite.We just put the tag at offshore
      IF sy-subrc NE 0.
        READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve>
                                      WITH KEY vbeln   = <lfs_lips>-vgbel
                                               posnr   = <lfs_lips>-vgpos
                                               vbeln_n = <lfs_lips>-vbeln
                                               posnr_n = <lfs_lips>-uecha
                                               rrsta   = lc_status_c
                                               BINARY SEARCH.
      ENDIF. " IF sy-subrc NE 0
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
      IF sy-subrc = 0.
        lv_status_c = abap_true.
      ENDIF. " IF sy-subrc = 0

      CASE abap_true.
        WHEN lv_status_a.
          lwa_final-ov_rrsta = lc_status_a.
        WHEN lv_status_c.
          lwa_final-ov_rrsta = lc_status_c.
        WHEN OTHERS.
      ENDCASE.
      IF lv_status_a = abap_true AND lv_status_c = abap_true.
        lwa_final-ov_rrsta = lc_status_ca.
      ENDIF. " IF lv_status_a = abap_true AND lv_status_c = abap_true
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
** This change was done at onsite.We just put the tag at offshore
    ENDIF. " IF <lfs_lips>-lfimg IS NOT INITIAL
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018

    DELETE li_vbreve_tmp WHERE rrsta = c_pdsta_a.

    SORT li_vbreve_tmp BY vbeln posnr vbeln_n posnr_n.

* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
** This change was done at onsite.We just put the tag at offshore
    IF <lfs_lips>-lfimg IS NOT INITIAL.
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
* Parallel cursor for vbreve
      READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve>
                                          WITH KEY vbeln   = <lfs_lips>-vgbel
                                                   posnr   = <lfs_lips>-vgpos
                                                   vbeln_n = <lfs_lips>-vbeln
                                                   posnr_n = <lfs_lips>-posnr
                                                   BINARY SEARCH.

* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
** This change was done at onsite.We just put the tag at offshore
      IF sy-subrc NE 0.
        READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve>
                                    WITH KEY vbeln   = <lfs_lips>-vgbel
                                             posnr   = <lfs_lips>-vgpos
                                             vbeln_n = <lfs_lips>-vbeln
                                             posnr_n = <lfs_lips>-uecha
                                             BINARY SEARCH.
      ENDIF. " IF sy-subrc NE 0
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
      IF sy-subrc = 0.
        CLEAR: lv_tabix.
        lv_tabix = sy-tabix.

        LOOP AT li_vbreve_tmp ASSIGNING <lfs_vbreve_temp>  FROM lv_tabix.
          IF <lfs_vbreve>-vbeln <> <lfs_vbreve_temp>-vbeln
          OR <lfs_vbreve>-posnr <> <lfs_vbreve_temp>-posnr
          OR  <lfs_vbreve>-vbeln_n <> <lfs_vbreve_temp>-vbeln_n
          OR <lfs_vbreve>-posnr_n <> <lfs_vbreve_temp>-posnr_n.
            EXIT.
          ENDIF. " IF <lfs_vbreve>-vbeln <> <lfs_vbreve_temp>-vbeln

          lwa_vbreve_tmp-vbeln  =   <lfs_vbreve_temp>-vbeln.
          lwa_vbreve_tmp-posnr =   <lfs_vbreve_temp>-posnr.
          lwa_vbreve_tmp-vbeln_n  =   <lfs_vbreve_temp>-vbeln_n.
          lwa_vbreve_tmp-posnr_n  =   <lfs_vbreve_temp>-posnr_n.

          lwa_vbreve_tmp-sammg  =   <lfs_vbreve_temp>-sammg.
          lwa_vbreve_tmp-reffld =   <lfs_vbreve_temp>-reffld.
          lwa_vbreve_tmp-rrsta  =   <lfs_vbreve_temp>-rrsta.
          lwa_vbreve_tmp-wrbtr  =   <lfs_vbreve_temp>-wrbtr.
          lwa_vbreve_tmp-waerk  =   <lfs_vbreve_temp>-waerk.
          COLLECT lwa_vbreve_tmp INTO li_vbreve_tmp1.
          CLEAR: lwa_vbreve_tmp.
        ENDLOOP. " LOOP AT li_vbreve_tmp ASSIGNING <lfs_vbreve_temp> FROM lv_tabix
        CLEAR: lv_cnt, lwa_vbreve_tmp.
        SORT li_vbreve_tmp BY vbeln posnr vbeln_n posnr_n sammg reffld.
        LOOP AT li_vbreve_tmp1 ASSIGNING <lfs_vbreve_tmp>.
          lv_cnt = lv_cnt + 1.

          CASE lv_cnt.
            WHEN '1'.
              lwa_final-wrbtr_rev1 = <lfs_vbreve_tmp>-wrbtr.
              lwa_final-waerk_rev1 = <lfs_vbreve_tmp>-waerk.

              lwa_final-sammg1    = <lfs_vbreve_tmp>-sammg.
              lwa_final-reffld1   = <lfs_vbreve_tmp>-reffld.
              lwa_final-rrsta1    = <lfs_vbreve_tmp>-rrsta.
              READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve_temp>
                                           WITH KEY vbeln   = <lfs_lips>-vgbel
                                                    posnr   = <lfs_lips>-vgpos
                                                    vbeln_n = <lfs_lips>-vbeln
                                                    posnr_n = <lfs_lips>-posnr
                                                    sammg   = <lfs_vbreve_tmp>-sammg
                                                    reffld  = <lfs_vbreve_tmp>-reffld BINARY SEARCH.
              IF sy-subrc NE 0.
                READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve_temp>
                             WITH KEY vbeln   = <lfs_lips>-vgbel
                                      posnr   = <lfs_lips>-vgpos
                                      vbeln_n = <lfs_lips>-vbeln
                                      posnr_n = <lfs_lips>-uecha
                                      sammg   = <lfs_vbreve_tmp>-sammg
                                      reffld  = <lfs_vbreve_tmp>-reffld BINARY SEARCH.
              ENDIF. " IF sy-subrc NE 0
              IF sy-subrc = 0.
                lwa_final-budat1    = <lfs_vbreve_temp>-budat.
                lwa_final-revevdat1 = <lfs_vbreve_temp>-revevdat.
              ENDIF. " IF sy-subrc = 0
              CLEAR: lv_awkey.
              CONCATENATE <lfs_vbreve_tmp>-sammg <lfs_vbreve_tmp>-reffld INTO lv_awkey.
* Move Accounting data details
              READ TABLE fp_i_bkpf ASSIGNING <lfs_bkpf>  WITH KEY awtyp = c_vbrr
                                                          awkey = lv_awkey
                                                          BINARY SEARCH.
              IF sy-subrc EQ 0.
                lwa_final-belnr1 = <lfs_bkpf>-belnr.
              ENDIF. " IF sy-subrc EQ 0

            WHEN '2'.
              lwa_final-wrbtr_rev2 = <lfs_vbreve_tmp>-wrbtr.
              lwa_final-waerk_rev2 = <lfs_vbreve_tmp>-waerk.

              lwa_final-sammg2    = <lfs_vbreve_tmp>-sammg.
              lwa_final-reffld2   = <lfs_vbreve_tmp>-reffld.
              lwa_final-rrsta2    = <lfs_vbreve_tmp>-rrsta.
              READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve_temp>
                                           WITH KEY vbeln   = <lfs_lips>-vgbel
                                                    posnr   = <lfs_lips>-vgpos
                                                    vbeln_n = <lfs_lips>-vbeln
                                                    posnr_n = <lfs_lips>-posnr
                                                    sammg   = <lfs_vbreve_tmp>-sammg
                                                    reffld  = <lfs_vbreve_tmp>-reffld BINARY SEARCH.
              IF sy-subrc NE 0.
                READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve_temp>
                             WITH KEY vbeln   = <lfs_lips>-vgbel
                                      posnr   = <lfs_lips>-vgpos
                                      vbeln_n = <lfs_lips>-vbeln
                                      posnr_n = <lfs_lips>-uecha
                                      sammg   = <lfs_vbreve_tmp>-sammg
                                      reffld  = <lfs_vbreve_tmp>-reffld BINARY SEARCH.
              ENDIF. " IF sy-subrc NE 0
              IF sy-subrc = 0.
                lwa_final-budat2    = <lfs_vbreve_temp>-budat.
                lwa_final-revevdat2 = <lfs_vbreve_temp>-revevdat.
              ENDIF. " IF sy-subrc = 0
              CLEAR: lv_awkey.
              CONCATENATE <lfs_vbreve_tmp>-sammg <lfs_vbreve_tmp>-reffld INTO lv_awkey.
* Move Accounting data details
              READ TABLE fp_i_bkpf ASSIGNING <lfs_bkpf>  WITH KEY awtyp = c_vbrr
                                                          awkey = lv_awkey
                                                          BINARY SEARCH.
              IF sy-subrc EQ 0.
                lwa_final-belnr2 = <lfs_bkpf>-belnr.
              ENDIF. " IF sy-subrc EQ 0
            WHEN '3'.
              lwa_final-wrbtr_rev3 = <lfs_vbreve_tmp>-wrbtr.
              lwa_final-waerk_rev3 = <lfs_vbreve_tmp>-waerk.

              lwa_final-sammg3    = <lfs_vbreve_tmp>-sammg.
              lwa_final-reffld3   = <lfs_vbreve_tmp>-reffld.
              lwa_final-rrsta3    = <lfs_vbreve_tmp>-rrsta.
              READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve_temp>
                                           WITH KEY vbeln   = <lfs_lips>-vgbel
                                                    posnr   = <lfs_lips>-vgpos
                                                    vbeln_n = <lfs_lips>-vbeln
                                                    posnr_n = <lfs_lips>-posnr
                                                    sammg   = <lfs_vbreve_tmp>-sammg
                                                    reffld  = <lfs_vbreve_tmp>-reffld BINARY SEARCH.
              IF sy-subrc NE 0.
                READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve_temp>
                             WITH KEY vbeln   = <lfs_lips>-vgbel
                                      posnr   = <lfs_lips>-vgpos
                                      vbeln_n = <lfs_lips>-vbeln
                                      posnr_n = <lfs_lips>-uecha
                                      sammg   = <lfs_vbreve_tmp>-sammg
                                      reffld  = <lfs_vbreve_tmp>-reffld BINARY SEARCH.
              ENDIF. " IF sy-subrc NE 0
              IF sy-subrc = 0.
                lwa_final-budat3    = <lfs_vbreve_temp>-budat.
                lwa_final-revevdat3 = <lfs_vbreve_temp>-revevdat.
              ENDIF. " IF sy-subrc = 0
              CLEAR: lv_awkey.
              CONCATENATE <lfs_vbreve_tmp>-sammg <lfs_vbreve_tmp>-reffld INTO lv_awkey.
* Move Accounting data details
              READ TABLE fp_i_bkpf ASSIGNING <lfs_bkpf>  WITH KEY awtyp = c_vbrr
                                                          awkey = lv_awkey
                                                          BINARY SEARCH.
              IF sy-subrc EQ 0.
                lwa_final-belnr3 = <lfs_bkpf>-belnr.
              ENDIF. " IF sy-subrc EQ 0
            WHEN '4'.
              lwa_final-wrbtr_rev4 = <lfs_vbreve_tmp>-wrbtr.
              lwa_final-waerk_rev4 = <lfs_vbreve_tmp>-waerk.

              lwa_final-sammg4    = <lfs_vbreve_tmp>-sammg.
              lwa_final-reffld4   = <lfs_vbreve_tmp>-reffld.
              lwa_final-rrsta4    = <lfs_vbreve_tmp>-rrsta.
              READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve_temp>
                                           WITH KEY vbeln   = <lfs_lips>-vgbel
                                                    posnr   = <lfs_lips>-vgpos
                                                    vbeln_n = <lfs_lips>-vbeln
                                                    posnr_n = <lfs_lips>-posnr
                                                    sammg   = <lfs_vbreve_tmp>-sammg
                                                    reffld  = <lfs_vbreve_tmp>-reffld BINARY SEARCH.
              IF sy-subrc NE 0.
                READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve_temp>
                             WITH KEY vbeln   = <lfs_lips>-vgbel
                                      posnr   = <lfs_lips>-vgpos
                                      vbeln_n = <lfs_lips>-vbeln
                                      posnr_n = <lfs_lips>-uecha
                                      sammg   = <lfs_vbreve_tmp>-sammg
                                      reffld  = <lfs_vbreve_tmp>-reffld BINARY SEARCH.
              ENDIF. " IF sy-subrc NE 0
              IF sy-subrc = 0.
                lwa_final-budat4    = <lfs_vbreve_temp>-budat.
                lwa_final-revevdat4 = <lfs_vbreve_temp>-revevdat.
              ENDIF. " IF sy-subrc = 0
              CLEAR: lv_awkey.
              CONCATENATE <lfs_vbreve_tmp>-sammg <lfs_vbreve_tmp>-reffld INTO lv_awkey.
* Move Accounting data details
              READ TABLE fp_i_bkpf ASSIGNING <lfs_bkpf>  WITH KEY awtyp = c_vbrr
                                                          awkey = lv_awkey
                                                          BINARY SEARCH.
              IF sy-subrc EQ 0.
                lwa_final-belnr4 = <lfs_bkpf>-belnr.
              ENDIF. " IF sy-subrc EQ 0
            WHEN '5'.
              lwa_final-wrbtr_rev5 = <lfs_vbreve_tmp>-wrbtr.
              lwa_final-waerk_rev5 = <lfs_vbreve_tmp>-waerk.

              lwa_final-sammg5    = <lfs_vbreve_tmp>-sammg.
              lwa_final-reffld5   = <lfs_vbreve_tmp>-reffld.
              lwa_final-rrsta5    = <lfs_vbreve_tmp>-rrsta.
              READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve_temp>
                                           WITH KEY vbeln   = <lfs_lips>-vgbel
                                                    posnr   = <lfs_lips>-vgpos
                                                    vbeln_n = <lfs_lips>-vbeln
                                                    posnr_n = <lfs_lips>-posnr
                                                    sammg   = <lfs_vbreve_tmp>-sammg
                                                    reffld  = <lfs_vbreve_tmp>-reffld BINARY SEARCH.
              IF sy-subrc NE 0.
                READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve_temp>
                             WITH KEY vbeln   = <lfs_lips>-vgbel
                                      posnr   = <lfs_lips>-vgpos
                                      vbeln_n = <lfs_lips>-vbeln
                                      posnr_n = <lfs_lips>-uecha
                                      sammg   = <lfs_vbreve_tmp>-sammg
                                      reffld  = <lfs_vbreve_tmp>-reffld BINARY SEARCH.
              ENDIF. " IF sy-subrc NE 0
              IF sy-subrc = 0.
                lwa_final-budat5    = <lfs_vbreve_temp>-budat.
                lwa_final-revevdat5 = <lfs_vbreve_temp>-revevdat.
              ENDIF. " IF sy-subrc = 0
              CLEAR: lv_awkey.
              CONCATENATE <lfs_vbreve_tmp>-sammg <lfs_vbreve_tmp>-reffld INTO lv_awkey.
* Move Accounting data details
              READ TABLE fp_i_bkpf ASSIGNING <lfs_bkpf>  WITH KEY awtyp = c_vbrr
                                                          awkey = lv_awkey
                                                          BINARY SEARCH.
              IF sy-subrc EQ 0.
                lwa_final-belnr5 = <lfs_bkpf>-belnr.
              ENDIF. " IF sy-subrc EQ 0
            WHEN '6'.
              lwa_final-wrbtr_rev6 = <lfs_vbreve_tmp>-wrbtr.
              lwa_final-waerk_rev6 = <lfs_vbreve_tmp>-waerk.

              lwa_final-sammg6    = <lfs_vbreve_tmp>-sammg.
              lwa_final-reffld6   = <lfs_vbreve_tmp>-reffld.
              lwa_final-rrsta6    = <lfs_vbreve_tmp>-rrsta.
              READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve_temp>
                                           WITH KEY vbeln   = <lfs_lips>-vgbel
                                                    posnr   = <lfs_lips>-vgpos
                                                    vbeln_n = <lfs_lips>-vbeln
                                                    posnr_n = <lfs_lips>-posnr
                                                    sammg   = <lfs_vbreve_tmp>-sammg
                                                    reffld  = <lfs_vbreve_tmp>-reffld BINARY SEARCH.
              IF sy-subrc NE 0.
                READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve_temp>
                             WITH KEY vbeln   = <lfs_lips>-vgbel
                                      posnr   = <lfs_lips>-vgpos
                                      vbeln_n = <lfs_lips>-vbeln
                                      posnr_n = <lfs_lips>-uecha
                                      sammg   = <lfs_vbreve_tmp>-sammg
                                      reffld  = <lfs_vbreve_tmp>-reffld BINARY SEARCH.
              ENDIF. " IF sy-subrc NE 0
              IF sy-subrc = 0.
                lwa_final-budat6    = <lfs_vbreve_temp>-budat.
                lwa_final-revevdat6 = <lfs_vbreve_temp>-revevdat.
              ENDIF. " IF sy-subrc = 0
              CLEAR: lv_awkey.
              CONCATENATE <lfs_vbreve_tmp>-sammg <lfs_vbreve_tmp>-reffld INTO lv_awkey.
* Move Accounting data details
              READ TABLE fp_i_bkpf ASSIGNING <lfs_bkpf>  WITH KEY awtyp = c_vbrr
                                                          awkey = lv_awkey
                                                          BINARY SEARCH.
              IF sy-subrc EQ 0.
                lwa_final-belnr6 = <lfs_bkpf>-belnr.
              ENDIF. " IF sy-subrc EQ 0
            WHEN '7'.
              lwa_final-wrbtr_rev7 = <lfs_vbreve_tmp>-wrbtr.
              lwa_final-waerk_rev7 = <lfs_vbreve_tmp>-waerk.

              lwa_final-sammg7    = <lfs_vbreve_tmp>-sammg.
              lwa_final-reffld7   = <lfs_vbreve_tmp>-reffld.
              lwa_final-rrsta7    = <lfs_vbreve_tmp>-rrsta.
              READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve_temp>
                                           WITH KEY vbeln   = <lfs_lips>-vgbel
                                                    posnr   = <lfs_lips>-vgpos
                                                    vbeln_n = <lfs_lips>-vbeln
                                                    posnr_n = <lfs_lips>-posnr
                                                    sammg   = <lfs_vbreve_tmp>-sammg
                                                    reffld  = <lfs_vbreve_tmp>-reffld BINARY SEARCH.
              IF sy-subrc NE 0.
                READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve_temp>
                             WITH KEY vbeln   = <lfs_lips>-vgbel
                                      posnr   = <lfs_lips>-vgpos
                                      vbeln_n = <lfs_lips>-vbeln
                                      posnr_n = <lfs_lips>-uecha
                                      sammg   = <lfs_vbreve_tmp>-sammg
                                      reffld  = <lfs_vbreve_tmp>-reffld BINARY SEARCH.
              ENDIF. " IF sy-subrc NE 0
              IF sy-subrc = 0.
                lwa_final-budat7    = <lfs_vbreve_temp>-budat.
                lwa_final-revevdat7 = <lfs_vbreve_temp>-revevdat.
              ENDIF. " IF sy-subrc = 0
              CLEAR: lv_awkey.
              CONCATENATE <lfs_vbreve_tmp>-sammg <lfs_vbreve_tmp>-reffld INTO lv_awkey.
* Move Accounting data details
              READ TABLE fp_i_bkpf ASSIGNING <lfs_bkpf>  WITH KEY awtyp = c_vbrr
                                                          awkey = lv_awkey
                                                          BINARY SEARCH.
              IF sy-subrc EQ 0.
                lwa_final-belnr7 = <lfs_bkpf>-belnr.
              ENDIF. " IF sy-subrc EQ 0
            WHEN '8'.
              lwa_final-wrbtr_rev8 = <lfs_vbreve_tmp>-wrbtr.
              lwa_final-waerk_rev8 = <lfs_vbreve_tmp>-waerk.

              lwa_final-sammg8    = <lfs_vbreve_tmp>-sammg.
              lwa_final-reffld8   = <lfs_vbreve_tmp>-reffld.
              lwa_final-rrsta8    = <lfs_vbreve_tmp>-rrsta.
              READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve_temp>
                                           WITH KEY vbeln   = <lfs_lips>-vgbel
                                                    posnr   = <lfs_lips>-vgpos
                                                    vbeln_n = <lfs_lips>-vbeln
                                                    posnr_n = <lfs_lips>-posnr
                                                    sammg   = <lfs_vbreve_tmp>-sammg
                                                    reffld  = <lfs_vbreve_tmp>-reffld BINARY SEARCH.
              IF sy-subrc NE 0.
                READ TABLE li_vbreve_tmp ASSIGNING <lfs_vbreve_temp>
                             WITH KEY vbeln   = <lfs_lips>-vgbel
                                      posnr   = <lfs_lips>-vgpos
                                      vbeln_n = <lfs_lips>-vbeln
                                      posnr_n = <lfs_lips>-uecha
                                      sammg   = <lfs_vbreve_tmp>-sammg
                                      reffld  = <lfs_vbreve_tmp>-reffld BINARY SEARCH.
              ENDIF. " IF sy-subrc NE 0
              IF sy-subrc = 0.
                lwa_final-budat8    = <lfs_vbreve_temp>-budat.
                lwa_final-revevdat8 = <lfs_vbreve_temp>-revevdat.
              ENDIF. " IF sy-subrc = 0
              CLEAR: lv_awkey.
              CONCATENATE <lfs_vbreve_tmp>-sammg <lfs_vbreve_tmp>-reffld INTO lv_awkey.
* Move Accounting data details
              READ TABLE fp_i_bkpf ASSIGNING <lfs_bkpf>  WITH KEY awtyp = c_vbrr
                                                          awkey = lv_awkey
                                                          BINARY SEARCH.
              IF sy-subrc EQ 0.
                lwa_final-belnr8 = <lfs_bkpf>-belnr.
              ENDIF. " IF sy-subrc EQ 0
            WHEN OTHERS.
          ENDCASE.
        ENDLOOP. " LOOP AT li_vbreve_tmp1 ASSIGNING <lfs_vbreve_tmp>
      ENDIF. " IF sy-subrc = 0
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
** This change was done at onsite.We just put the tag at offshore
    ENDIF. " IF <lfs_lips>-lfimg IS NOT INITIAL
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018

* Begin of change for Sctask: SCTASK0745122 Intercompany Billing Accural fields by U033876
    READ TABLE fp_ic_bill_acc INTO lwa_ic_bill_acc
                              WITH KEY ic_bill_acc_vgbel = <lfs_lips>-vbeln
                                       ic_bill_acc_vgpos = <lfs_lips>-posnr
                                       BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_final-ic_bil_accu = lwa_ic_bill_acc-ic_bil_accu.
      lwa_final-ic_bil_waerk = lwa_ic_bill_acc-ic_bil_waerk.
    ENDIF. " IF sy-subrc = 0
* End of change for Sctask: SCTASK0745122 Intercompany Billing Accural fields by U033876

*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
* Populate final internal table with Payer & Payer billing block
    READ TABLE fp_i_payr INTO lwa_payr WITH KEY vbeln = <lfs_lips>-vgbel
                                                BINARY SEARCH.
    IF sy-subrc IS INITIAL.
*--> Begin of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
      CLEAR lwa_knvv.
      READ TABLE fp_i_knvv INTO lwa_knvv WITH KEY kunnr = lwa_payr-kunnr
                                                  vkorg = lwa_final-vkorg
                                                  vtweg = lwa_final-vtweg
                                                  spart = <lfs_lips>-spart
                                                  BINARY SEARCH.
      IF sy-subrc = 0.

        lwa_final-pay_bb = lwa_knvv-faksd.
      ENDIF. " IF sy-subrc = 0
*<-- End of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
      lwa_final-payer = lwa_payr-kunnr.
      IF lwa_final-pay_bb IS INITIAL.
        READ TABLE fp_i_paybl INTO lwa_paybl WITH KEY kunnr = lwa_payr-kunnr
                                                      BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          lwa_final-pay_bb = lwa_paybl-faksd.
        ENDIF. " IF sy-subrc IS INITIAL
*--> Begin of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
      ENDIF. " IF lwa_final-pay_bb IS INITIAL
*<-- End of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
    ENDIF. " IF sy-subrc IS INITIAL
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
* Begin of SCATSK
    CLEAR : lwa_mkpf , lwa_vbfa.
    READ TABLE li_mkpf INTO lwa_mkpf WITH KEY xblnr = lwa_final-vbeln BINARY SEARCH.
    IF sy-subrc EQ 0.
      MOVE lwa_mkpf-usnam TO lwa_final-usnam.
    ENDIF. " IF sy-subrc EQ 0
    READ TABLE li_vbfa INTO lwa_vbfa WITH KEY vbelv = lwa_final-vbeln
                                              posnv = lwa_final-posnr BINARY SEARCH.
    IF sy-subrc EQ 0 AND lwa_vbfa-vbeln+0(2) EQ '49'.
      MOVE lwa_vbfa-rfwrt TO lwa_final-rfwrt.
      MOVE lwa_vbfa-waers TO lwa_final-waers.
    ENDIF. " IF sy-subrc EQ 0 AND lwa_vbfa-vbeln+0(2) EQ '49'
* End of SCTASK
    APPEND lwa_final TO fp_i_final.
    CLEAR: lwa_final, li_vbreve_tmp1[].
*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
    CLEAR: lwa_payr,
           lwa_paybl.
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
  ENDLOOP. " LOOP AT fp_i_lips ASSIGNING <lfs_lips>

ENDFORM. " F_PREPARE_FINAL
*&---------------------------------------------------------------------*
*&      Form  F_FIELDCAT_FILL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->fP_FINAL  text
*      <--fP_FIELDCAT  text
*----------------------------------------------------------------------*
FORM f_fieldcat_fill  USING    fp_i_final TYPE ty_final_t
                      CHANGING fp_i_fieldcat TYPE lvc_t_fcat.
  DATA: lwa_fieldcat   TYPE lvc_s_fcat,                 " ALV control: Field catalog
        lwa_message    TYPE string,
        li_fields      TYPE ddfields,
        lwa_fields     TYPE dfies,                      " DD Interface: Table Fields for DDIF_FIELDINFO_GET
        lwa_tabname    TYPE fieldname,                  " Field Name
        lo_descr       TYPE REF TO cl_abap_typedescr,   " Runtime Type Services
        lo_structdescr TYPE REF TO cl_abap_structdescr, " Runtime Type Services
        lo_tabdescr    TYPE REF TO cl_abap_structdescr, " Runtime Type Services
        lo_data        TYPE REF TO data,                "  class
        lo_error       TYPE REF TO cx_root.             " Abstract Superclass for All Global Exceptions
  CONSTANTS:lc_pdsta        TYPE fieldname VALUE 'PDSTA',             " Field Name
            lc_vkorgt       TYPE fieldname VALUE 'VKORGT',            " Field Name
            lc_bezei1       TYPE fieldname VALUE 'BEZEI1',            " Field Name
            lc_bezei4       TYPE fieldname VALUE 'BEZEI4',            " Field Name
            lc_ktgrmt       TYPE fieldname VALUE 'KTGRMT',            " Field Name
            lc_vgbel        TYPE fieldname VALUE 'VGBEL',             " Field Name
            lc_vgpos        TYPE fieldname VALUE 'VGPOS',             " Field Name
            lc_netwr        TYPE fieldname VALUE 'NETWR',             " Field Name
            lc_kwert_k      TYPE fieldname VALUE 'KWERT_K',          " Field Name
            lc_faksk        TYPE fieldname VALUE 'FAKSK',             " Field Name
            lc_spe_ident_01 TYPE fieldname VALUE 'SPE_IDENT_01', " Field Name
            lc_track_num    TYPE fieldname VALUE 'TRACK_NUM',    " Field Name
            lc_ov_rrsta     TYPE fieldname VALUE 'OV_RRSTA',        " Field Name
            lc_netwr_vf     TYPE fieldname VALUE 'NETWR_VF',        " Field Name
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
            lc_matnr        TYPE fieldname VALUE 'MATNR',      " Field Name
            lc_arktx        TYPE fieldname VALUE 'ARKTX',      " Field Name
            lc_erdat        TYPE fieldname VALUE 'ERDAT',      " Field Name
            lc_posnn        TYPE fieldname VALUE 'POSNN_BILL', " Field Name
            lc_ernam        TYPE fieldname VALUE 'ERNAM_S',    " Field Name
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
            lc_sammg1       TYPE fieldname VALUE 'SAMMG1',         " Group
            lc_reffld1      TYPE  fieldname VALUE 'REFFLD1',       " FI document reference number
            lc_rrsta1       TYPE  fieldname VALUE 'RRSTA1',        " Revenue determination status
            lc_budat1       TYPE  fieldname VALUE 'BUDAT1',        " Posting Date in the Document
            lc_revevdat1    TYPE  fieldname VALUE 'REVEVDAT1', " Revenue Event Date
            lc_belnr1       TYPE fieldname VALUE 'BELNR1',         " Field Name
            lc_wrbtr_rev1   TYPE fieldname VALUE 'WRBTR_REV1',  " Field Name
            lc_waerk_rev1   TYPE fieldname VALUE 'WAERK_REV1',  " Field Name

            lc_ap_belnr     TYPE fieldname VALUE 'AP_BELNR',      " Field Name
            lc_ap_bstat     TYPE fieldname VALUE 'AP_BSTAT',      " Field Name


            lc_sammg2       TYPE fieldname VALUE 'SAMMG2',         " Group
            lc_reffld2      TYPE  fieldname VALUE 'REFFLD2',       " FI document reference number
            lc_rrsta2       TYPE  fieldname VALUE 'RRSTA2',        " Revenue determination status
            lc_budat2       TYPE  fieldname VALUE 'BUDAT2',        " Posting Date in the Document
            lc_revevdat2    TYPE  fieldname VALUE 'REVEVDAT2', " Revenue Event Date
            lc_belnr2       TYPE fieldname VALUE 'BELNR2',         " Field Name
            lc_wrbtr_rev2   TYPE fieldname VALUE 'WRBTR_REV2',  " Field Name
            lc_waerk_rev2   TYPE fieldname VALUE 'WAERK_REV2',  " Field Name

            lc_sammg3       TYPE fieldname VALUE 'SAMMG3',         " Group
            lc_reffld3      TYPE  fieldname VALUE 'REFFLD3',       " FI document reference number
            lc_rrsta3       TYPE  fieldname VALUE 'RRSTA3',        " Revenue determination status
            lc_budat3       TYPE  fieldname VALUE 'BUDAT3',        " Posting Date in the Document
            lc_revevdat3    TYPE  fieldname VALUE 'REVEVDAT3', " Revenue Event Date
            lc_belnr3       TYPE fieldname VALUE 'BELNR3',          " Field Name
            lc_wrbtr_rev3   TYPE fieldname VALUE 'WRBTR_REV3',  " Field Name
            lc_waerk_rev3   TYPE fieldname VALUE 'WAERK_REV3',  " Field Name

            lc_sammg4       TYPE fieldname VALUE 'SAMMG4',         " Group
            lc_reffld4      TYPE  fieldname VALUE 'REFFLD4',       " FI document reference number
            lc_rrsta4       TYPE  fieldname VALUE 'RRSTA4',        " Revenue determination status
            lc_budat4       TYPE  fieldname VALUE 'BUDAT4',        " Posting Date in the Document
            lc_revevdat4    TYPE  fieldname VALUE 'REVEVDAT4', " Revenue Event Date
            lc_belnr4       TYPE fieldname VALUE 'BELNR4',          " Field Name
            lc_wrbtr_rev4   TYPE fieldname VALUE 'WRBTR_REV4',  " Field Name
            lc_waerk_rev4   TYPE fieldname VALUE 'WAERK_REV4',  " Field Name

            lc_kagname      TYPE fieldname VALUE 'KAGNAME',        " Field Name
            lc_kwename      TYPE fieldname VALUE 'KWENAME',        " Field Name

            lc_sammg5       TYPE fieldname VALUE 'SAMMG5',         " Group
            lc_reffld5      TYPE  fieldname VALUE 'REFFLD5',       " FI document reference number
            lc_rrsta5       TYPE  fieldname VALUE 'RRSTA5',        " Revenue determination status
            lc_budat5       TYPE  fieldname VALUE 'BUDAT5',        " Posting Date in the Document
            lc_revevdat5    TYPE  fieldname VALUE 'REVEVDAT5', " Revenue Event Date
            lc_belnr5       TYPE fieldname VALUE 'BELNR5',          " Field Name
            lc_wrbtr_rev5   TYPE fieldname VALUE 'WRBTR_REV5',  " Field Name
            lc_waerk_rev5   TYPE fieldname VALUE 'WAERK_REV5',  " Field Name

            lc_sammg6       TYPE fieldname VALUE 'SAMMG6',         " Group
            lc_reffld6      TYPE  fieldname VALUE 'REFFLD6',       " FI document reference number
            lc_rrsta6       TYPE  fieldname VALUE 'RRSTA6',        " Revenue determination status
            lc_budat6       TYPE  fieldname VALUE 'BUDAT6',        " Posting Date in the Document
            lc_revevdat6    TYPE  fieldname VALUE 'REVEVDAT6', " Revenue Event Date
            lc_belnr6       TYPE fieldname VALUE 'BELNR6',          " Field Name
            lc_wrbtr_rev6   TYPE fieldname VALUE 'WRBTR_REV6',  " Field Name
            lc_waerk_rev6   TYPE fieldname VALUE 'WAERK_REV6',  " Field Name

            lc_sammg7       TYPE fieldname VALUE 'SAMMG7',         " Group
            lc_reffld7      TYPE  fieldname VALUE 'REFFLD7',       " FI document reference number
            lc_rrsta7       TYPE  fieldname VALUE 'RRSTA7',        " Revenue determination status
            lc_budat7       TYPE  fieldname VALUE 'BUDAT7',        " Posting Date in the Document
            lc_revevdat7    TYPE  fieldname VALUE 'REVEVDAT7', " Revenue Event Date
            lc_belnr7       TYPE fieldname VALUE 'BELNR7',          " Field Name
            lc_wrbtr_rev7   TYPE fieldname VALUE 'WRBTR_REV7',  " Field Name
            lc_waerk_rev7   TYPE fieldname VALUE 'WAERK_REV7',  " Field Name

            lc_sammg8       TYPE fieldname VALUE 'SAMMG8',         " Group
            lc_reffld8      TYPE  fieldname VALUE 'REFFLD8',       " FI document reference number
            lc_rrsta8       TYPE  fieldname VALUE 'RRSTA8',        " Revenue determination status
            lc_budat8       TYPE  fieldname VALUE 'BUDAT8',        " Posting Date in the Document
            lc_revevdat8    TYPE  fieldname VALUE 'REVEVDAT8', " Revenue Event Date
            lc_belnr8       TYPE fieldname VALUE 'BELNR8',          " Field Name
            lc_wrbtr_rev8   TYPE fieldname VALUE 'WRBTR_REV8',  " Field Name
            lc_waerk_rev8   TYPE fieldname VALUE 'WAERK_REV8',  " Field Name
*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
            lc_payer        TYPE fieldname VALUE 'PAYER',  " Field Name
            lc_pay_bb       TYPE fieldname VALUE 'PAY_BB'. " Field Name
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018

  CLEAR: fp_i_fieldcat[].
  CREATE DATA lo_data LIKE LINE OF fp_i_final.
  lo_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lo_data ).
  li_fields = cl_salv_data_descr=>read_structdescr( lo_tabdescr ).


  LOOP AT li_fields INTO lwa_fields.
    MOVE-CORRESPONDING lwa_fields TO lwa_fieldcat.
    IF lwa_fieldcat-f4availabl = abap_true.
      CASE lwa_fieldcat-fieldname.
        WHEN 'VKORG'.
          lwa_fieldcat-ref_table = 'LIKP'.
* ---> Begin of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
*        WHEN 'MATNR'.
** Reference table is not needed.
*          lwa_fieldcat-ref_table = 'MARA'.
* <--- End of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
        WHEN 'WERKS'.
          lwa_fieldcat-ref_table = 'MARC'.
        WHEN 'VTWEG'.
          lwa_fieldcat-ref_table = 'LIKP'.
        WHEN 'PRCTR'.
          lwa_fieldcat-ref_table = 'LIPS'.
        WHEN 'KZPOD'.
          lwa_fieldcat-ref_table = 'LIPS'.
        WHEN 'RFBSK'.
          lwa_fieldcat-ref_table = 'VBRK'.
        WHEN 'RRSTA'.
          lwa_fieldcat-ref_table = 'VBREVE'.
*          lwa_fieldcat-f4availabl = abap_false.
        WHEN 'IC_RFBSK'.
          lwa_fieldcat-ref_table = 'VBRK'.
          lwa_fieldcat-ref_field = 'RFBSK'.
*      WHEN 'AP_BSTAT'.
*        lwa_fieldcat-coltext   = 'IC AP Posting status (LRD COGS)'(141).
*        lwa_fieldcat-scrtext_l = 'IC AP Posting status (LRD COGS)'(141).
        WHEN OTHERS.
      ENDCASE.
    ENDIF. " IF lwa_fieldcat-f4availabl = abap_true
    CASE lwa_fieldcat-fieldname.
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
** Change the description of output column headings
      WHEN lc_matnr.
        lwa_fieldcat-coltext   = 'Material'(004).
        lwa_fieldcat-scrtext_l = 'Material'(004).
      WHEN lc_arktx.
        lwa_fieldcat-coltext   = 'Material Description'(088).
        lwa_fieldcat-scrtext_l = 'Material Description'(088).
      WHEN lc_erdat.
        lwa_fieldcat-coltext   = 'Delivery Creation'(090).
        lwa_fieldcat-scrtext_l = 'Delivery Creation'(090).
      WHEN lc_posnn.
        lwa_fieldcat-coltext   = 'Billing Item'(091).
        lwa_fieldcat-scrtext_l = 'Billing Item'(091).
      WHEN lc_ernam.
        lwa_fieldcat-coltext   = 'Sales Order Created By'(089).
        lwa_fieldcat-scrtext_l = 'Sales Order Created By'(089).
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018

      WHEN 'CUST_BLOCK'.
        lwa_fieldcat-coltext   = 'Sold-To-Cust Bill Block'(006).
        lwa_fieldcat-scrtext_l = 'Sold-To-Cust Bill Block'(006).
      WHEN lc_pdsta.
        lwa_fieldcat-icon = abap_true.
        lwa_fieldcat-coltext   = 'POD Status Icon'(011).
        lwa_fieldcat-scrtext_l = 'POD Status Icon'(011).
*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
      WHEN lc_payer.
        lwa_fieldcat-coltext   = 'Payer'(092).
        lwa_fieldcat-scrtext_l = 'Payer'(092).
      WHEN lc_pay_bb.
        lwa_fieldcat-coltext   = 'Payer Billing Block'(093).
        lwa_fieldcat-scrtext_l = 'Payer Billing Block'(093).
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
      WHEN lc_vkorgt.
        lwa_fieldcat-coltext   = 'Sales Org. Name'(007).
        lwa_fieldcat-scrtext_l = 'Sales Org. Name'(007).
      WHEN lc_bezei1.
        lwa_fieldcat-coltext   = 'Material Grp1 Description'(008).
        lwa_fieldcat-scrtext_l = 'Material Grp1 Description'(008).
      WHEN lc_bezei4.
        lwa_fieldcat-coltext   = 'Material Grp4 Description'(009).
        lwa_fieldcat-scrtext_l = 'Material Grp4 Description'(009).
      WHEN lc_ktgrmt.
        lwa_fieldcat-coltext   = 'Acct. Assignment Grp Description'(010).
        lwa_fieldcat-scrtext_l = 'Acct. Assignment Grp Description'(010).
      WHEN lc_vgbel.
        lwa_fieldcat-coltext   = 'Sales Order Number'(012).
        lwa_fieldcat-scrtext_l = 'Sales Order Number'(012).
      WHEN lc_vgpos.
        lwa_fieldcat-coltext   = 'Sales Order Item'(013).
        lwa_fieldcat-scrtext_l = 'Sales Order Item'(013).
      WHEN lc_netwr.
        lwa_fieldcat-coltext   = 'Delivery Net value'(014).
        lwa_fieldcat-scrtext_l = 'Delivery Net value'(014).
      WHEN lc_kwert_k.
        lwa_fieldcat-coltext   = 'VPRS value'(015).
        lwa_fieldcat-scrtext_l = 'VPRS value'(015).
      WHEN lc_faksk.
        lwa_fieldcat-coltext   = 'Sales Order Bill Block'(016).
        lwa_fieldcat-scrtext_l = 'Sales Order Bill Block'(016).
      WHEN lc_wrbtr_rev1.
        lwa_fieldcat-coltext   = 'Revenue Net Amount1'(059).
        lwa_fieldcat-scrtext_l = 'Revenue Net Amount1'(059).

      WHEN lc_waerk_rev1.
        lwa_fieldcat-coltext   = 'Revenue Currency1'(060).
        lwa_fieldcat-scrtext_l = 'Revenue Currency1'(060).

      WHEN lc_spe_ident_01.
        lwa_fieldcat-coltext   = 'Tracking Num'(061).
        lwa_fieldcat-scrtext_l = 'Tracking Num'(061).

      WHEN lc_track_num.
        lwa_fieldcat-coltext   = 'Number of Tracking numbers'(062).
        lwa_fieldcat-scrtext_l = 'Number of Tracking numbers'(062).
      WHEN lc_ov_rrsta.
        lwa_fieldcat-coltext   = 'Overall Rev Status'(063).
        lwa_fieldcat-scrtext_l = 'Overall Rev Status'(063).

      WHEN lc_netwr_vf.
        lwa_fieldcat-coltext   = 'Billing Net Value'(084).
        lwa_fieldcat-scrtext_l = 'Billing Net Value'(084).

      WHEN lc_sammg1.
        lwa_fieldcat-coltext   = 'Group1'(064).
        lwa_fieldcat-scrtext_l = 'Group1'(064).
      WHEN lc_reffld1.
        lwa_fieldcat-coltext   = 'FIDocRefNo1'(065).
        lwa_fieldcat-scrtext_l = 'FIDocRefNo1'(065).
      WHEN lc_rrsta1.
        lwa_fieldcat-coltext   = 'RD status1'(066).
        lwa_fieldcat-scrtext_l = 'RD status1'(066).
      WHEN lc_budat1.
        lwa_fieldcat-coltext   = 'Revenue Posting date1'(067).
        lwa_fieldcat-scrtext_l = 'Revenue Posting date1'(067).
      WHEN lc_revevdat1.
        lwa_fieldcat-coltext   = 'Revenue Event date1'(068).
        lwa_fieldcat-scrtext_l = 'Revenue Event date1'(068).
      WHEN lc_belnr1.
        lwa_fieldcat-coltext   = 'Revenue Doc1'(069).
        lwa_fieldcat-scrtext_l = 'Revenue Doc1'(069).


      WHEN lc_sammg2.
        lwa_fieldcat-coltext   = 'Group2'(017).
        lwa_fieldcat-scrtext_l = 'Group2'(017).
      WHEN lc_reffld2.
        lwa_fieldcat-coltext   = 'FIDocRefNo2'(018).
        lwa_fieldcat-scrtext_l = 'FIDocRefNo2'(018).
      WHEN lc_rrsta2.
        lwa_fieldcat-coltext   = 'RD status2'(019).
        lwa_fieldcat-scrtext_l = 'RD status2'(019).
      WHEN lc_budat2.
        lwa_fieldcat-coltext   = 'Revenue Posting date2'(020).
        lwa_fieldcat-scrtext_l = 'Revenue Posting date2'(020).
      WHEN lc_revevdat2.
        lwa_fieldcat-coltext   = 'Revenue Event date2'(021).
        lwa_fieldcat-scrtext_l = 'Revenue Event date2'(021).
      WHEN lc_belnr2.
        lwa_fieldcat-coltext   = 'Revenue Doc2'(022).
        lwa_fieldcat-scrtext_l = 'Revenue Doc2'(022).

      WHEN lc_wrbtr_rev2.
        lwa_fieldcat-coltext   = 'Revenue Net Amount2'(070).
        lwa_fieldcat-scrtext_l = 'Revenue Net Amount2'(070).

      WHEN lc_waerk_rev2.
        lwa_fieldcat-coltext   = 'Revenue Currency2'(071).
        lwa_fieldcat-scrtext_l = 'Revenue Currency2'(071).


      WHEN lc_sammg3.
        lwa_fieldcat-coltext   = 'Group3'(023).
        lwa_fieldcat-scrtext_l = 'Group3'(023).
      WHEN lc_reffld3.
        lwa_fieldcat-coltext   = 'FIDocRefNo3'(024).
        lwa_fieldcat-scrtext_l = 'FIDocRefNo3'(024).
      WHEN lc_rrsta3.
        lwa_fieldcat-coltext   = 'RD status3'(025).
        lwa_fieldcat-scrtext_l = 'RD status3'(025).
      WHEN lc_budat3.
        lwa_fieldcat-coltext   = 'Revenue Posting date3'(026).
        lwa_fieldcat-scrtext_l = 'Revenue Posting date3'(026).
      WHEN lc_revevdat3.
        lwa_fieldcat-coltext   = 'Revenue Event date3'(027).
        lwa_fieldcat-scrtext_l = 'Revenue Event date3'(027).
      WHEN lc_belnr3.
        lwa_fieldcat-coltext   = 'Revenue Doc3'(028).
        lwa_fieldcat-scrtext_l = 'Revenue Doc3'(028).
      WHEN lc_wrbtr_rev3.
        lwa_fieldcat-coltext   = 'Revenue Net Amount3'(072).
        lwa_fieldcat-scrtext_l = 'Revenue Net Amount3'(072).

      WHEN lc_waerk_rev3.
        lwa_fieldcat-coltext   = 'Revenue Currency3'(073).
        lwa_fieldcat-scrtext_l = 'Revenue Currency3'(073).



      WHEN lc_sammg4.
        lwa_fieldcat-coltext   = 'Group4'(029).
        lwa_fieldcat-scrtext_l = 'Group4'(029).
      WHEN lc_reffld4.
        lwa_fieldcat-coltext   = 'FIDocRefNo4'(030).
        lwa_fieldcat-scrtext_l = 'FIDocRefNo4'(030).
      WHEN lc_rrsta4.
        lwa_fieldcat-coltext   = 'RD status4'(031).
        lwa_fieldcat-scrtext_l = 'RD status4'(031).
      WHEN lc_budat4.
        lwa_fieldcat-coltext   = 'Revenue Posting date4'(032).
        lwa_fieldcat-scrtext_l = 'Revenue Posting date4'(032).
      WHEN lc_revevdat4.
        lwa_fieldcat-coltext   = 'Revenue Event date4'(033).
        lwa_fieldcat-scrtext_l = 'Revenue Event date4'(033).
      WHEN lc_belnr4.
        lwa_fieldcat-coltext   = 'Revenue Doc4'(034).
        lwa_fieldcat-scrtext_l = 'Revenue Doc4'(034).


      WHEN lc_wrbtr_rev4.
        lwa_fieldcat-coltext   = 'Revenue Net Amount4'(074).
        lwa_fieldcat-scrtext_l = 'Revenue Net Amount4'(074).

      WHEN lc_waerk_rev4.
        lwa_fieldcat-coltext   = 'Revenue Currency4'(075).
        lwa_fieldcat-scrtext_l = 'Revenue Currency4'(075).

      WHEN lc_kagname.
        lwa_fieldcat-coltext   = 'Sold-To Name'(085).
        lwa_fieldcat-scrtext_l = 'Sold-To Name'(085).
      WHEN lc_kwename.
        lwa_fieldcat-coltext   = 'Ship-To Name'(086).
        lwa_fieldcat-scrtext_l = 'Ship-To Name'(086).
      WHEN lc_sammg5.
        lwa_fieldcat-coltext   = 'Group5'(035).
        lwa_fieldcat-scrtext_l = 'Group5'(035).
      WHEN lc_reffld5.
        lwa_fieldcat-coltext   = 'FIDocRefNo5'(036).
        lwa_fieldcat-scrtext_l = 'FIDocRefNo5'(036).
      WHEN lc_rrsta5.
        lwa_fieldcat-coltext   = 'RD status5'(037).
        lwa_fieldcat-scrtext_l = 'RD status5'(037).
      WHEN lc_budat5.
        lwa_fieldcat-coltext   = 'Revenue Posting date5'(038).
        lwa_fieldcat-scrtext_l = 'Revenue Posting date5'(038).
      WHEN lc_revevdat5.
        lwa_fieldcat-coltext   = 'Revenue Event date5'(039).
        lwa_fieldcat-scrtext_l = 'Revenue Event date5'(039).
      WHEN lc_belnr5.
        lwa_fieldcat-coltext   = 'Revenue Doc5'(040).
        lwa_fieldcat-scrtext_l = 'Revenue Doc5'(040).
      WHEN lc_wrbtr_rev5.
        lwa_fieldcat-coltext   = 'Revenue Net Amount5'(076).
        lwa_fieldcat-scrtext_l = 'Revenue Net Amount5'(076).

      WHEN lc_waerk_rev5.
        lwa_fieldcat-coltext   = 'Revenue Currency5'(077).
        lwa_fieldcat-scrtext_l = 'Revenue Currency5'(077).


      WHEN lc_sammg6.
        lwa_fieldcat-coltext   = 'Group6'(041).
        lwa_fieldcat-scrtext_l = 'Group6'(041).
      WHEN lc_reffld6.
        lwa_fieldcat-coltext   = 'FIDocRefNo6'(042).
        lwa_fieldcat-scrtext_l = 'FIDocRefNo6'(042).
      WHEN lc_rrsta6.
        lwa_fieldcat-coltext   = 'RD status6'(043).
        lwa_fieldcat-scrtext_l = 'RD status6'(043).
      WHEN lc_budat6.
        lwa_fieldcat-coltext   = 'Revenue Posting date6'(044).
        lwa_fieldcat-scrtext_l = 'Revenue Posting date6'(044).
      WHEN lc_revevdat6.
        lwa_fieldcat-coltext   = 'Revenue Event date6'(045).
        lwa_fieldcat-scrtext_l = 'Revenue Event date6'(045).
      WHEN lc_belnr6.
        lwa_fieldcat-coltext   = 'Revenue Doc6'(046).
        lwa_fieldcat-scrtext_l = 'Revenue Doc6'(046).
      WHEN lc_wrbtr_rev6.
        lwa_fieldcat-coltext   = 'Revenue Net Amount6'(078).
        lwa_fieldcat-scrtext_l = 'Revenue Net Amount6'(078).

      WHEN lc_waerk_rev6.
        lwa_fieldcat-coltext   = 'Revenue Currency6'(079).
        lwa_fieldcat-scrtext_l = 'Revenue Currency6'(079).

      WHEN lc_sammg7.
        lwa_fieldcat-coltext   = 'Group7'(047).
        lwa_fieldcat-scrtext_l = 'Group7'(047).
      WHEN lc_reffld7.
        lwa_fieldcat-coltext   = 'FIDocRefNo7'(048).
        lwa_fieldcat-scrtext_l = 'FIDocRefNo7'(048).
      WHEN lc_rrsta7.
        lwa_fieldcat-coltext   = 'RD status7'(049).
        lwa_fieldcat-scrtext_l = 'RD status7'(049).
      WHEN lc_budat7.
        lwa_fieldcat-coltext   = 'Revenue Posting date7'(050).
        lwa_fieldcat-scrtext_l = 'Revenue Posting date7'(050).
      WHEN lc_revevdat7.
        lwa_fieldcat-coltext   = 'Revenue Event date7'(051).
        lwa_fieldcat-scrtext_l = 'Revenue Event date7'(051).
      WHEN lc_belnr7.
        lwa_fieldcat-coltext   = 'Revenue Doc7'(052).
        lwa_fieldcat-scrtext_l = 'Revenue Doc7'(052).

      WHEN lc_wrbtr_rev7.
        lwa_fieldcat-coltext   = 'Revenue Net Amount7'(080).
        lwa_fieldcat-scrtext_l = 'Revenue Net Amount7'(080).

      WHEN lc_waerk_rev7.
        lwa_fieldcat-coltext   = 'Revenue Currency7'(081).
        lwa_fieldcat-scrtext_l = 'Revenue Currency7'(081).

      WHEN lc_sammg8.
        lwa_fieldcat-coltext   = 'Group8'(053).
        lwa_fieldcat-scrtext_l = 'Group8'(053).
      WHEN lc_reffld8.
        lwa_fieldcat-coltext   = 'FIDocRefNo8'(054).
        lwa_fieldcat-scrtext_l = 'FIDocRefNo8'(054).
      WHEN lc_rrsta8.
        lwa_fieldcat-coltext   = 'RD status8'(055).
        lwa_fieldcat-scrtext_l = 'RD status8'(055).
      WHEN lc_budat8.
        lwa_fieldcat-coltext   = 'Revenue Posting date8'(056).
        lwa_fieldcat-scrtext_l = 'Revenue Posting date8'(056).
      WHEN lc_revevdat8.
        lwa_fieldcat-coltext   = 'Revenue Event date8'(057).
        lwa_fieldcat-scrtext_l = 'Revenue Event date8'(057).
      WHEN lc_belnr8.
        lwa_fieldcat-coltext   = 'Revenue Doc8'(058).
        lwa_fieldcat-scrtext_l = 'Revenue Doc8'(058).
      WHEN lc_wrbtr_rev8.
        lwa_fieldcat-coltext   = 'Revenue Net Amount8'(082).
        lwa_fieldcat-scrtext_l = 'Revenue Net Amount8'(082).

      WHEN lc_waerk_rev8.
        lwa_fieldcat-coltext   = 'Revenue Currency8'(083).
        lwa_fieldcat-scrtext_l = 'Revenue Currency8'(083).
      WHEN 'RFWRT'.
        lwa_fieldcat-coltext   = 'COGS'(127).
        lwa_fieldcat-scrtext_l = 'COGS'(127).
      WHEN 'WAERS'.
        lwa_fieldcat-coltext   = 'COGS curr'(128).
        lwa_fieldcat-scrtext_l = 'COGS curr'(128).
      WHEN 'USNAM'.
        lwa_fieldcat-coltext   = 'POD Created by'(129).
        lwa_fieldcat-scrtext_l = 'POD Created by'(129).

      WHEN 'FAKSP'.
        lwa_fieldcat-coltext   = 'SalesOrder Line Item Block'(130).
        lwa_fieldcat-scrtext_l = 'SalesOrder Line Item Block'(130).

* Begin of Change for SCTASK0745122 by u033876
      WHEN 'VKOIV' .
        lwa_fieldcat-coltext   = 'IC Sale Org'(131).
        lwa_fieldcat-scrtext_l = 'IC Sale Org'(131).
      WHEN 'VTWIV'.
        lwa_fieldcat-coltext   = 'IC Dist Channel'(132).
        lwa_fieldcat-scrtext_l = 'IC Dist Channel'(132).
      WHEN 'KUNIV'.
        lwa_fieldcat-coltext   = 'IC Partner'(133).
        lwa_fieldcat-scrtext_l = 'IC Partner'(133).

      WHEN 'IC_VBELN'.
        lwa_fieldcat-coltext   = 'IC AR Billing Invoice'(134).
        lwa_fieldcat-scrtext_l = 'IC AR Billing Invoice'(134).
      WHEN 'IC_POSNR'.
        lwa_fieldcat-coltext   = 'IC AR Invoice line item'(135).
        lwa_fieldcat-scrtext_l = 'IC AR Invoice line item'(135).
      WHEN 'IC_NETWR'.
        lwa_fieldcat-coltext   = 'IC AR Revenue'(136).
        lwa_fieldcat-scrtext_l = 'IC AR Revenue'(136).
      WHEN 'IC_WAERK'.
        lwa_fieldcat-coltext   = 'IC Currency'(137).
        lwa_fieldcat-scrtext_l = 'IC Currency'(137).
      WHEN 'IC_FKDAT'.
        lwa_fieldcat-coltext   = 'IC Billing date'(138).
        lwa_fieldcat-scrtext_l = 'IC Billing date'(138).
      WHEN 'IC_RFBSK'.
        lwa_fieldcat-coltext   = 'IC AR Posting status'(139).
        lwa_fieldcat-scrtext_l = 'IC AR Posting status'(139).
      WHEN lc_ap_belnr.
        lwa_fieldcat-coltext   = 'IC AP Invoice'(140).
        lwa_fieldcat-scrtext_l = 'IC AP Invoice'(140).
      WHEN lc_ap_bstat.
        lwa_fieldcat-coltext   = 'IC AP Posting status (LRD COGS)'(141).
        lwa_fieldcat-scrtext_l = 'IC AP Posting status (LRD COGS)'(141).
      WHEN 'TU_NUM'.
        lwa_fieldcat-coltext   = 'TU Number'(142).
        lwa_fieldcat-scrtext_l = 'TU Number'(142).

      WHEN 'IC_BIL_ACCU'.
        lwa_fieldcat-coltext   = 'IC billing value to be accrued'(143).
        lwa_fieldcat-scrtext_l = 'IC billing value to be accrued'(143).
      WHEN 'IC_BIL_WAERK'.
        lwa_fieldcat-coltext   = 'Currency of IC billing accured'(144).
        lwa_fieldcat-scrtext_l = 'Currency of IC billing accured'(144).
* End of change for SCTASK0745122 by U033876

      WHEN OTHERS.
    ENDCASE.

    APPEND lwa_fieldcat TO fp_i_fieldcat.
    CLEAR: lwa_fieldcat.
  ENDLOOP. " LOOP AT li_fields INTO lwa_fields
ENDFORM. " F_FIELDCAT_FILL
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_FIELDCAT  text
*----------------------------------------------------------------------*
FORM f_display_alv  USING    fp_i_fieldcat TYPE lvc_t_fcat
                             fp_i_final    TYPE ty_final_t.
  DATA:
    lo_dyndoc_id TYPE REF TO cl_dd_document,   " Dynamic Documents: Document
    lwa_layout   TYPE lvc_s_layo,              " ALV control: Layout structure
    lo_handler   TYPE REF TO go_event_handler. " Event_handler class


  CONSTANTS:lc_event_top TYPE char30     VALUE 'TOP_OF_PAGE', " Event_top of type CHAR30
            lc_a         TYPE char01     VALUE 'A',           " Save_a of type CHAR01
            lc_alvgrid   TYPE sdydo_attribute VALUE 'ALV_GRID'.

  IF go_custom_container IS INITIAL.

*&--Create Custom Container
    CREATE OBJECT go_custom_container
      EXPORTING
        container_name              = c_container
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF. " IF sy-subrc <> 0

    PERFORM f_screen_splitter USING go_custom_container
                              CHANGING go_gui_cont_top
                                       go_gui_cont_alv .


    CREATE OBJECT go_alv_grid
      EXPORTING
        i_appl_events     = abap_true
        i_parent          = go_gui_cont_alv
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        OTHERS            = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF. " IF sy-subrc <> 0
*&--Create document
    CREATE OBJECT lo_dyndoc_id
      EXPORTING
        style = lc_alvgrid.

*&--Buliding layout structure for display of final table
    lwa_layout-stylefname  = c_style.
    lwa_layout-sel_mode     = lc_a.
    lwa_layout-zebra       = abap_true.
    lwa_layout-cwidth_opt  = abap_true.

*&--Create and Set Handler object for Header Data
    CREATE OBJECT lo_handler.
    SET HANDLER lo_handler->meth_i_pub_handle_topofpage
      FOR go_alv_grid.
    SET HANDLER lo_handler->meth_on_toolbar FOR go_alv_grid.
    SET HANDLER lo_handler->meth_handle_user_comm FOR go_alv_grid.

*&--Display data of i_final
    CALL METHOD go_alv_grid->set_table_for_first_display
      EXPORTING
        is_layout                     = lwa_layout
        i_save                        = lc_a
        i_default                     = abap_true
      CHANGING
        it_outtab                     = fp_i_final
        it_fieldcatalog               = fp_i_fieldcat
*       it_sort                       = li_sort
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF. " IF sy-subrc <> 0
*&--Initialize document
    CALL METHOD lo_dyndoc_id->initialize_document.

*&--Assign Top of page event to document
    CALL METHOD go_alv_grid->list_processing_events
      EXPORTING
        i_event_name = lc_event_top
        i_dyndoc_id  = lo_dyndoc_id.

  ENDIF. " IF go_custom_container IS INITIAL
ENDFORM. " F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*&      Form  F_FREE_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_container .
  IF go_custom_container IS BOUND.
    CALL METHOD go_custom_container->free
      EXCEPTIONS
        cntl_system_error = 1
        cntl_error        = 2.
  ENDIF. " IF go_custom_container IS BOUND

  CALL METHOD cl_gui_cfw=>flush.
ENDFORM. " F_FREE_CONTAINER
*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_TOPOFPAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_DYNDOC_ID  text
*      -->P_GO_CUSTOM_CONTAINER  text
*----------------------------------------------------------------------*
FORM f_handle_topofpage  USING    fp_dyndoc_id TYPE REF TO cl_dd_document           " Dynamic Documents: Document
                                  fp_custom_container TYPE REF TO cl_gui_container. " Container for Custom Controls in the Screen Area
  DATA:lwa_address  TYPE bapiaddr3,                  " BAPI reference structure for addresses (contact person)
       lv_uname     TYPE sdydo_text_element,         " Full Name of Person
       lv_date      TYPE char10,                     "date variable
       lv_time      TYPE char10,                     " Time of type CHAR10
       lv_date_time TYPE sdydo_text_element,         " Date_time of type CHAR25
       lv_lines     TYPE int4,                       " Natural Number
       lv_lines_txt TYPE sdydo_text_element,
       li_return    TYPE STANDARD TABLE OF bapiret2. " Return Parameter

  CONSTANTS: lc_strong TYPE sdydo_attribute VALUE 'STRONG',
             lc_normal TYPE sdydo_attribute VALUE 'NORMAL',
             lc_colon  TYPE char1 VALUE ':', "Colon
             lc_slash  TYPE char1 VALUE '/'. " Slash


**&--Add text for header

  CALL METHOD fp_dyndoc_id->add_text
    EXPORTING
      text         = 'END-TO-END REVENUE REPORT'(005)
      sap_emphasis = lc_strong.
  CALL METHOD fp_dyndoc_id->new_line.
  CALL METHOD fp_dyndoc_id->new_line.

* User Name text
  CALL METHOD fp_dyndoc_id->add_text
    EXPORTING
      text         = 'User Name:'(003)
      sap_emphasis = lc_strong.

* Get user details
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    IMPORTING
      address  = lwa_address
    TABLES
      return   = li_return.


  IF lwa_address-fullname IS NOT INITIAL.
    MOVE lwa_address-fullname TO lv_uname.
  ELSE. " ELSE -> IF lwa_address-fullname IS NOT INITIAL
    MOVE sy-uname TO lv_uname.
  ENDIF. " IF lwa_address-fullname IS NOT INITIAL
* populate user name value
  CALL METHOD fp_dyndoc_id->add_text
    EXPORTING
      text         = lv_uname
      sap_emphasis = lc_normal.

  CALL METHOD fp_dyndoc_id->new_line.

* Date and Time text
  CALL METHOD fp_dyndoc_id->add_text
    EXPORTING
      text         = 'Date and Time:'(002)
      sap_emphasis = lc_strong.


* populate Date and Time value
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
         INTO lv_date_time
         SEPARATED BY space.

  CALL METHOD fp_dyndoc_id->add_text
    EXPORTING
      text         = lv_date_time
      sap_emphasis = lc_normal.

  CALL METHOD fp_dyndoc_id->new_line.


* Total Records text
  CALL METHOD fp_dyndoc_id->add_text
    EXPORTING
      text         = 'Total Records:'(001)
      sap_emphasis = lc_strong.

  DESCRIBE TABLE i_final[] LINES lv_lines.
  WRITE lv_lines TO lv_lines_txt.
  CALL METHOD fp_dyndoc_id->add_text
    EXPORTING
      text         = lv_lines_txt
      sap_emphasis = lc_normal.

  CALL METHOD fp_dyndoc_id->new_line.
  CALL METHOD fp_dyndoc_id->new_line.

*&--Merge document
  CALL METHOD fp_dyndoc_id->merge_document.

*&--Display Top of page
  CALL METHOD fp_dyndoc_id->display_document
    EXPORTING
      reuse_control      = abap_true
      parent             = fp_custom_container
    EXCEPTIONS
      html_display_error = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF. " IF sy-subrc <> 0

ENDFORM. " F_HANDLE_TOPOFPAGE
*&---------------------------------------------------------------------*
*&      Form  F_SCREEN_SPLITTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GO_CUSTOM_CONTAINER  text
*----------------------------------------------------------------------*
FORM f_screen_splitter  USING    fp_custom_container TYPE REF TO cl_gui_custom_container " Container for Custom Controls in the Screen Area
                        CHANGING fp_gui_cont_top TYPE REF TO cl_gui_container            " Abstract Container for GUI Controls
                                 fp_gui_cont_alv TYPE REF TO cl_gui_container.           " Abstract Container for GUI Controls
  DATA:
    lo_split_cont       TYPE REF TO cl_gui_splitter_container. " Splitter Control

*&--Create splitter container in which to place graphics
  CREATE OBJECT lo_split_cont
    EXPORTING
      parent            = fp_custom_container
      rows              = 2
      columns           = 1
    EXCEPTIONS
      cntl_error        = 1
      cntl_system_error = 2
      OTHERS            = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF. " IF sy-subrc <> 0

*&--Set height of top-of-page section
  CALL METHOD lo_split_cont->set_row_height
    EXPORTING
      id     = 1
      height = 15.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF. " IF sy-subrc <> 0

*&--Fetch the container for Top split section
  CALL METHOD lo_split_cont->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = fp_gui_cont_top.

  CALL METHOD lo_split_cont->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = fp_gui_cont_alv.


ENDFORM. " F_SCREEN_SPLITTER
*&---------------------------------------------------------------------*
*&      Form  F_GET_EMI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_emi .
  DATA:
    lwa_enh_status TYPE zdev_enh_status . " Enhancement Status
  CONSTANTS: lc_enhancement_no TYPE z_enhancement VALUE 'OTC_RDD_0116'. " Enhancement No.
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enhancement_no
    TABLES
      tt_enh_status     = i_enh_status.


ENDFORM. " F_GET_EMI
*&---------------------------------------------------------------------*
*&      Form  F_GET_FROM_KONV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_VBAK  text
*      <--P_I_KONV  text
*----------------------------------------------------------------------*
FORM f_get_from_konv  USING    fp_i_vbak TYPE ty_vbak_t
                      CHANGING fp_i_konv TYPE ty_konv_t.
  DATA: li_vbak TYPE STANDARD TABLE OF ty_vbak.

  li_vbak[] = fp_i_vbak[].
  SORT li_vbak BY knumv.
  DELETE ADJACENT DUPLICATES FROM li_vbak COMPARING knumv.

  IF NOT li_vbak[] IS INITIAL.
    SELECT knumv   " Number of the document condition
           kposn   " Condition item number
           stunr   " Step number
           zaehk   "  Condition counter
           kschl   " Condition type
           kwert_k " Condition value
    FROM konv      " Conditions (Transaction Data)
    INTO TABLE fp_i_konv
    FOR ALL ENTRIES IN li_vbak
    WHERE knumv = li_vbak-knumv.

    IF sy-subrc EQ 0.
      DELETE fp_i_konv WHERE kschl NE gv_kschl.
      SORT fp_i_konv BY knumv kposn.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF NOT li_vbak[] IS INITIAL

ENDFORM. " F_GET_FROM_KONV
*&---------------------------------------------------------------------*
*&      Form  F_ON_TOOLBAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->fP_E_OBJECT  text
*----------------------------------------------------------------------*
FORM f_on_toolbar  USING    fp_e_object TYPE REF TO cl_alv_event_toolbar_set. " ALV Context Menu
  DATA:lwa_toolbar TYPE stb_button. " Toolbar Button

  lwa_toolbar-icon      =  icon_overview.
  lwa_toolbar-butn_type =  0.
  lwa_toolbar-quickinfo =  c_acc.
  lwa_toolbar-function  =  c_accnt.
  APPEND lwa_toolbar TO fp_e_object->mt_toolbar.
  CLEAR:lwa_toolbar.

  lwa_toolbar-icon      =  icon_system_modus_delete.
  lwa_toolbar-butn_type =  0.
  lwa_toolbar-quickinfo =  c_act_can.
  lwa_toolbar-function  =  c_acnt_canc.
  APPEND lwa_toolbar TO fp_e_object->mt_toolbar.
  CLEAR:lwa_toolbar.

ENDFORM. " F_ON_TOOLBAR
*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_USER_COMM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->fP_E_UCOMM  text
*----------------------------------------------------------------------*
FORM f_handle_user_comm  USING    fp_e_ucomm TYPE syucomm. " Function code that PAI triggered
  DATA: li_rows    TYPE lvc_t_roid,
        lwa_row_no TYPE lvc_s_roid, " Assignment of line number to line ID
        li_vbeln   TYPE ty_rsrange_t,
        li_posnr   TYPE ty_rsrange_t,
        li_sammg   TYPE ty_rsrange_t,
        li_reffld  TYPE ty_rsrange_t.

  FIELD-SYMBOLS:<lfs_final> TYPE ty_final.
  CASE fp_e_ucomm.
    WHEN c_accnt.
      CLEAR: li_rows[], lwa_row_no.
      CALL METHOD go_alv_grid->get_selected_rows
        IMPORTING
          et_row_no = li_rows.
      IF lines( li_rows ) IS INITIAL.
* Raise an error message
        MESSAGE e301.
      ENDIF. " IF lines( li_rows ) IS INITIAL
      LOOP AT li_rows INTO lwa_row_no.
        READ TABLE i_final ASSIGNING <lfs_final> INDEX lwa_row_no-row_id.
        IF sy-subrc = 0 . "AND ( <lfs_final>-belnr IS NOT INITIAL ).

          PERFORM f_fill_ranges_for_rev USING <lfs_final>
                                        CHANGING li_vbeln
                                                 li_posnr
                                                 li_sammg
                                                 li_reffld.
        ENDIF. " IF sy-subrc = 0
      ENDLOOP. " LOOP AT li_rows INTO lwa_row_no
      CLEAR:i_accnt_det[].
      PERFORM f_get_acct_details USING li_vbeln
                                       li_posnr
                                       li_sammg
                                       li_reffld
                           CHANGING i_accnt_det.

      IF  i_accnt_det[] IS NOT INITIAL.
        PERFORM f_fil_alv_grid2 USING go_dock_cont
                                      go_alv_grid_accnt
                                      i_accnt_det.
      ENDIF. " IF i_accnt_det[] IS NOT INITIAL
    WHEN c_acnt_canc.
      IF go_dock_cont IS BOUND.
        CALL METHOD go_alv_grid_accnt->free.
        CALL METHOD go_dock_cont->free.
        CLEAR: i_accnt_det[].
        CLEAR: go_dock_cont, go_alv_grid_accnt.
      ENDIF. " IF go_dock_cont IS BOUND
    WHEN OTHERS.
  ENDCASE.
ENDFORM. " F_HANDLE_USER_COMM
*&---------------------------------------------------------------------*
*&      Form  F_GET_ACCT_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<LFS_FINAL>  text
*      <--P_LI_ACCNT_DET  text
*----------------------------------------------------------------------*
FORM f_get_acct_details  USING    fp_i_vbeln  TYPE ty_rsrange_t
                                  fp_i_posnr  TYPE ty_rsrange_t
                                  fp_i_sammg  TYPE ty_rsrange_t
                                  fp_i_reffld TYPE ty_rsrange_t
                         CHANGING fp_i_accnt_det TYPE ty_rrdocview_t.
  DATA: lwa_acct_det TYPE rrdocview, " Revenue Recognition: Revenue Line View
        li_vbreve    TYPE rrpol_vbreve,
        li_vbrevk    TYPE rrpol_vbrevk.

* Fetch relevant revenue lines and to use AWK  index we use below where clause
  SELECT * FROM vbreve INTO TABLE li_vbreve
                            WHERE sammg    IN fp_i_sammg    AND
                                  reffld   IN fp_i_reffld   AND
                                  vbeln    IN fp_i_vbeln    AND
                                  posnr    IN fp_i_posnr
                            ORDER BY PRIMARY KEY.
  IF sy-subrc = 0.
*   Read control lines
    CALL FUNCTION 'SD_REV_REC_GET_CONTROL_LINES'
      EXPORTING
        fit_vbreve       = li_vbreve
      TABLES
        fit_vbrevk       = li_vbrevk
      EXCEPTIONS
        no_control_lines = 2.
    IF sy-subrc = 0.
      PERFORM f_fill_acct_view CHANGING li_vbreve li_vbrevk
                                        i_bkpf
                                        fp_i_accnt_det.

    ENDIF. " IF sy-subrc = 0
  ELSE. " ELSE -> IF sy-subrc = 0
    MESSAGE e304.
  ENDIF. " IF sy-subrc = 0

ENDFORM. " F_GET_ACCT_DETAILS
*&---------------------------------------------------------------------*
*&      Form  F_FILL_RANGES_FOR_REV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<LFS_FINAL>  text
*      <--P_LI_VBELN  text
*      <--P_LI_POSNR  text
*      <--P_LI_SAMMG  text
*      <--P_LI_REFFLD  text
*----------------------------------------------------------------------*
FORM f_fill_ranges_for_rev  USING    fp_final TYPE ty_final
                            CHANGING fp_i_vbeln  TYPE ty_rsrange_t
                                     fp_i_posnr  TYPE ty_rsrange_t
                                     fp_i_sammg  TYPE ty_rsrange_t
                                     fp_i_reffld TYPE ty_rsrange_t.
  DATA: lwa_vbeln  TYPE rsrange, " Include: Ranges in selection conditions
        lwa_posnr  TYPE rsrange, " Include: Ranges in selection conditions
        lwa_sammg  TYPE rsrange, " Include: Ranges in selection conditions
        lwa_reffld TYPE rsrange. " Include: Ranges in selection conditions
* Originally only one rev document we are showing.
* later all the rev billings are added..
  IF fp_final-vgbel IS NOT INITIAL.
    lwa_vbeln-sign   = c_i.
    lwa_vbeln-option = c_eq.
    lwa_vbeln-low   = fp_final-vgbel.
    APPEND lwa_vbeln TO fp_i_vbeln.
    CLEAR:lwa_vbeln.
  ENDIF. " IF fp_final-vgbel IS NOT INITIAL
  IF fp_final-vgpos IS NOT INITIAL.
    lwa_posnr-sign   = c_i.
    lwa_posnr-option = c_eq.
    lwa_posnr-low    = fp_final-vgpos.
    APPEND lwa_posnr TO fp_i_posnr.
    CLEAR:lwa_posnr.
  ENDIF. " IF fp_final-vgpos IS NOT INITIAL
  IF fp_final-sammg1 IS NOT INITIAL.
    lwa_sammg-sign   = c_i.
    lwa_sammg-option = c_eq.
    lwa_sammg-low    = fp_final-sammg1.
    APPEND lwa_sammg TO fp_i_sammg.
    CLEAR:lwa_sammg.
  ENDIF. " IF fp_final-sammg1 IS NOT INITIAL
  IF fp_final-reffld1 IS NOT INITIAL.
    lwa_reffld-sign   = c_i.
    lwa_reffld-option = c_eq.
    lwa_reffld-low    = fp_final-reffld1.
    APPEND lwa_reffld TO fp_i_reffld.
    CLEAR:lwa_reffld.
  ENDIF. " IF fp_final-reffld1 IS NOT INITIAL

* For Group 2
  IF fp_final-sammg2 IS NOT INITIAL.
    lwa_sammg-sign   = c_i.
    lwa_sammg-option = c_eq.
    lwa_sammg-low    = fp_final-sammg2.
    APPEND lwa_sammg TO fp_i_sammg.
    CLEAR:lwa_sammg.
  ENDIF. " IF fp_final-sammg2 IS NOT INITIAL
  IF fp_final-reffld2 IS NOT INITIAL.
    lwa_reffld-sign   = c_i.
    lwa_reffld-option = c_eq.
    lwa_reffld-low    = fp_final-reffld2.
    APPEND lwa_reffld TO fp_i_reffld.
    CLEAR:lwa_reffld.
  ENDIF. " IF fp_final-reffld2 IS NOT INITIAL

* for Group 3
  IF fp_final-sammg3 IS NOT INITIAL.
    lwa_sammg-sign   = c_i.
    lwa_sammg-option = c_eq.
    lwa_sammg-low    = fp_final-sammg3.
    APPEND lwa_sammg TO fp_i_sammg.
    CLEAR:lwa_sammg.
  ENDIF. " IF fp_final-sammg3 IS NOT INITIAL
  IF fp_final-reffld3 IS NOT INITIAL.
    lwa_reffld-sign   = c_i.
    lwa_reffld-option = c_eq.
    lwa_reffld-low    = fp_final-reffld3.
    APPEND lwa_reffld TO fp_i_reffld.
    CLEAR:lwa_reffld.
  ENDIF. " IF fp_final-reffld3 IS NOT INITIAL

*for group4

  IF fp_final-sammg4 IS NOT INITIAL.
    lwa_sammg-sign   = c_i.
    lwa_sammg-option = c_eq.
    lwa_sammg-low    = fp_final-sammg4.
    APPEND lwa_sammg TO fp_i_sammg.
    CLEAR:lwa_sammg.
  ENDIF. " IF fp_final-sammg4 IS NOT INITIAL
  IF fp_final-reffld4 IS NOT INITIAL.
    lwa_reffld-sign   = c_i.
    lwa_reffld-option = c_eq.
    lwa_reffld-low    = fp_final-reffld4.
    APPEND lwa_reffld TO fp_i_reffld.
    CLEAR:lwa_reffld.
  ENDIF. " IF fp_final-reffld4 IS NOT INITIAL

* for group5
  IF fp_final-sammg5 IS NOT INITIAL.
    lwa_sammg-sign   = c_i.
    lwa_sammg-option = c_eq.
    lwa_sammg-low    = fp_final-sammg5.
    APPEND lwa_sammg TO fp_i_sammg.
    CLEAR:lwa_sammg.
  ENDIF. " IF fp_final-sammg5 IS NOT INITIAL
  IF fp_final-reffld5 IS NOT INITIAL.
    lwa_reffld-sign   = c_i.
    lwa_reffld-option = c_eq.
    lwa_reffld-low    = fp_final-reffld5.
    APPEND lwa_reffld TO fp_i_reffld.
    CLEAR:lwa_reffld.
  ENDIF. " IF fp_final-reffld5 IS NOT INITIAL

*  for group6
  IF fp_final-sammg6 IS NOT INITIAL.
    lwa_sammg-sign   = c_i.
    lwa_sammg-option = c_eq.
    lwa_sammg-low    = fp_final-sammg6.
    APPEND lwa_sammg TO fp_i_sammg.
    CLEAR:lwa_sammg.
  ENDIF. " IF fp_final-sammg6 IS NOT INITIAL
  IF fp_final-reffld6 IS NOT INITIAL.
    lwa_reffld-sign   = c_i.
    lwa_reffld-option = c_eq.
    lwa_reffld-low    = fp_final-reffld6.
    APPEND lwa_reffld TO fp_i_reffld.
    CLEAR:lwa_reffld.
  ENDIF. " IF fp_final-reffld6 IS NOT INITIAL

*for group7
  IF fp_final-sammg7 IS NOT INITIAL.
    lwa_sammg-sign   = c_i.
    lwa_sammg-option = c_eq.
    lwa_sammg-low    = fp_final-sammg7.
    APPEND lwa_sammg TO fp_i_sammg.
    CLEAR:lwa_sammg.
  ENDIF. " IF fp_final-sammg7 IS NOT INITIAL
  IF fp_final-reffld7 IS NOT INITIAL.
    lwa_reffld-sign   = c_i.
    lwa_reffld-option = c_eq.
    lwa_reffld-low    = fp_final-reffld7.
    APPEND lwa_reffld TO fp_i_reffld.
    CLEAR:lwa_reffld.
  ENDIF. " IF fp_final-reffld7 IS NOT INITIAL

*for group 8
  IF fp_final-sammg8 IS NOT INITIAL.
    lwa_sammg-sign   = c_i.
    lwa_sammg-option = c_eq.
    lwa_sammg-low    = fp_final-sammg8.
    APPEND lwa_sammg TO fp_i_sammg.
    CLEAR:lwa_sammg.
  ENDIF. " IF fp_final-sammg8 IS NOT INITIAL
  IF fp_final-reffld8 IS NOT INITIAL.
    lwa_reffld-sign   = c_i.
    lwa_reffld-option = c_eq.
    lwa_reffld-low    = fp_final-reffld8.
    APPEND lwa_reffld TO fp_i_reffld.
    CLEAR:lwa_reffld.
  ENDIF. " IF fp_final-reffld8 IS NOT INITIAL

ENDFORM. " F_FILL_RANGES_FOR_REV
*&---------------------------------------------------------------------*
*&      Form  F_FILL_ACCT_VIEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_VBREVE  text
*      -->P_LI_VBREVK  text
*      -->P_I_BKPF  text
*      <--P_FP_ACCNT_DET  text
*----------------------------------------------------------------------*
FORM f_fill_acct_view  CHANGING    fp_i_vbreve    TYPE rrpol_vbreve
                                   fp_i_vbrevk    TYPE rrpol_vbrevk
                                   fp_i_bkpf      TYPE ty_bkpf_t
                                   fp_i_accnt_det TYPE ty_rrdocview_t.
  DATA: lwa_vbreve  TYPE vbrevevb,  " Revenue Recognition: XVBREVE/YVBREVE Reference Structure
        lwa_vbrevk  TYPE vbrevkvb,  " Revenue Recognition: XVBREVK/YVBREVK Reference Structure
        lwa_docview TYPE rrdocview, " Revenue Recognition: Revenue Line View
        lwa_bkpf    TYPE ty_bkpf,
        lv_awkey    TYPE  awkey,    " Reference Key
        lv_seqnum   TYPE num10.     " 10 digit number
  CONSTANTS:lc_bschl_40 TYPE bschl VALUE '40', " Posting Key
            lc_bschl_50 TYPE bschl VALUE '50', " Posting Key
            lc_revenues TYPE char1 VALUE ' ',  " Revenues of type CHAR1
            lc_costs    TYPE char1 VALUE 'X',  " Costs of type CHAR1
            lc_charx    TYPE char1 VALUE 'X'.  " Charx of type CHAR1

  SORT fp_i_vbreve BY vbeln posnr.
  SORT fp_i_vbrevk BY mandt vbeln posnr.
  SORT fp_i_bkpf BY awtyp awkey.
  LOOP AT fp_i_vbreve INTO lwa_vbreve.
    AT NEW vbeln.
      CLEAR:lv_seqnum.
    ENDAT.
*   Set sign for costs
    IF lwa_vbreve-kstat EQ abap_true.
      lwa_vbreve-wrbtr = - lwa_vbreve-wrbtr.
      lwa_vbreve-rvamt = - lwa_vbreve-rvamt.
    ENDIF. " IF lwa_vbreve-kstat EQ abap_true
* Fill view work area
    MOVE-CORRESPONDING lwa_vbreve TO lwa_docview.
* Read relevant control line
    READ TABLE fp_i_vbrevk INTO lwa_vbrevk
                          WITH KEY mandt = lwa_vbreve-mandt
                                   vbeln = lwa_vbreve-vbeln
                                   posnr = lwa_vbreve-posnr
                          BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_docview-rrrel = lwa_vbrevk-rrrel.
    ENDIF. " IF sy-subrc = 0
* REad the BKPF to get accounting details

    CLEAR: lv_awkey.
    CONCATENATE lwa_vbreve-sammg lwa_vbreve-reffld INTO lv_awkey.
*   Positioning to link keys
    READ TABLE fp_i_bkpf INTO lwa_bkpf
               WITH KEY awtyp = c_vbrr
                        awkey = lv_awkey.
    IF sy-subrc = 0.
      lwa_docview-bukrs  = lwa_bkpf-bukrs.
      lwa_docview-belnr  = lwa_bkpf-belnr.
      lwa_docview-gjahr  = lwa_bkpf-gjahr.
    ENDIF. " IF sy-subrc = 0


**************************************************************************
* Code from Standard code
    DO 3 TIMES.

*   Statistically line?
      IF sy-index         LE 2         AND
         lwa_vbreve-kstat EQ abap_true AND
         lwa_vbreve-kruek IS INITIAL.
        CONTINUE.
      ENDIF. " IF sy-index LE 2 AND

*   Initialize fields
      CLEAR: lwa_docview-wrbtr,
             lwa_docview-wrbtr_c,
             lwa_docview-wrbtr_d,
             lwa_docview-sakrr,
             lwa_docview-bschl.

      CASE sy-index.

        WHEN 1.
*       Unbilled receivables (SAKUR) case
          lwa_docview-wrbtr = lwa_vbreve-wrbtr - lwa_vbreve-rvamt.

          IF lwa_docview-wrbtr EQ 0.
            CONTINUE.
          ELSE. " ELSE -> IF lwa_docview-wrbtr EQ 0
*         Set local sequence number
            lv_seqnum = lv_seqnum + 1.
*         Set account
            lwa_docview-sakrr = lwa_vbreve-sakur.
*         Set amount/posting key
            IF lwa_docview-wrbtr GE 0.
              lwa_docview-bschl   = lc_bschl_50.
              lwa_docview-wrbtr_c = abs( lwa_docview-wrbtr ).
            ELSE. " ELSE -> IF lwa_docview-wrbtr GE 0
              lwa_docview-bschl   = lc_bschl_40.
              lwa_docview-wrbtr_d = abs( lwa_docview-wrbtr ).
            ENDIF. " IF lwa_docview-wrbtr GE 0
            lwa_docview-wrbtr = - lwa_docview-wrbtr.
          ENDIF. " IF lwa_docview-wrbtr EQ 0

        WHEN 2.
*       Deferred revenues (SAKDR) case
          IF lwa_vbreve-rvamt EQ 0.
            CONTINUE.
          ELSE. " ELSE -> IF lwa_vbreve-rvamt EQ 0
*         Set local sequence number
            lv_seqnum = lv_seqnum + 1.
*         Set account
            lwa_docview-sakrr = lwa_vbreve-sakdr.
*         Set amount/posting key
            IF lwa_vbreve-rvamt GE 0.
              lwa_docview-bschl   = lc_bschl_50.
              lwa_docview-wrbtr_c = abs( lwa_vbreve-rvamt ).
            ELSE. " ELSE -> IF lwa_vbreve-rvamt GE 0
              lwa_docview-bschl   = lc_bschl_40.
              lwa_docview-wrbtr_d = abs( lwa_vbreve-rvamt ).
            ENDIF. " IF lwa_vbreve-rvamt GE 0
            lwa_docview-wrbtr = - lwa_vbreve-rvamt.
          ENDIF. " IF lwa_vbreve-rvamt EQ 0

        WHEN 3.
*       Revenues (SAKRV) case
*       Set local sequence number
          lv_seqnum = lv_seqnum + 1.
*       Set account
          lwa_docview-sakrr = lwa_vbreve-sakrv.
*       Set amount/posting key
          IF lwa_vbreve-wrbtr GE 0.
            IF ( lwa_vbreve-kstat EQ lc_revenues OR
                 ( lwa_vbreve-kstat EQ lc_costs AND
                   lwa_vbreve-kruek EQ lc_charx ) ).
              lwa_docview-bschl = lc_bschl_40.
            ENDIF. " IF ( lwa_vbreve-kstat EQ lc_revenues OR
            lwa_docview-wrbtr_d = abs( lwa_vbreve-wrbtr ).
          ELSE. " ELSE -> IF lwa_vbreve-wrbtr GE 0
            IF ( lwa_vbreve-kstat EQ lc_revenues OR
                 ( lwa_vbreve-kstat EQ lc_costs AND
                   lwa_vbreve-kruek EQ lc_charx ) ).
              lwa_docview-bschl = lc_bschl_50.
            ENDIF. " IF ( lwa_vbreve-kstat EQ lc_revenues OR
            lwa_docview-wrbtr_c = abs( lwa_vbreve-wrbtr ).
          ENDIF. " IF lwa_vbreve-wrbtr GE 0
          lwa_docview-wrbtr = lwa_vbreve-wrbtr.

      ENDCASE.

*   Set sequence number
      lwa_docview-seqnum = lv_seqnum.

*   Append view work area
      APPEND lwa_docview TO fp_i_accnt_det.

    ENDDO.
*************************************************************************

    CLEAR:lwa_docview , lv_awkey.
  ENDLOOP. " LOOP AT fp_i_vbreve INTO lwa_vbreve


ENDFORM. " F_FILL_ACCT_VIEW

*&---------------------------------------------------------------------*
*&      Form  F_FIL_ALV_GRID2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GO_CUSTOM_CONTAINER  text
*      -->P_LI_ACCNT_DET  text
*----------------------------------------------------------------------*
FORM f_fil_alv_grid2  USING    fp_dock_cont TYPE REF TO cl_gui_docking_container " Container for Custom Controls in the Screen Area
                               fp_alv_grid_accnt TYPE REF TO cl_gui_alv_grid     " ALV List Viewer
                               fp_i_accnt_det TYPE ty_rrdocview_t .
  DATA: li_accnt_fcat TYPE lvc_t_fcat,
        lwa_layout    TYPE lvc_s_layo. " ALV control: Layout structure

  CONSTANTS: lc_a TYPE char1 VALUE 'A'. " A of type CHAR1
  IF fp_dock_cont IS NOT BOUND.
*&--Create splitter container in which to place graphics
    CREATE OBJECT fp_dock_cont
      EXPORTING
        repid     = sy-repid
        dynnr     = sy-dynnr
        extension = 100
        side      = cl_gui_docking_container=>dock_at_bottom.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF. " IF sy-subrc <> 0

    CREATE OBJECT fp_alv_grid_accnt
      EXPORTING
        i_appl_events     = abap_true
        i_parent          = fp_dock_cont
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        OTHERS            = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF. " IF sy-subrc <> 0

    lwa_layout-stylefname  = c_style.
    lwa_layout-sel_mode    = lc_a.
    lwa_layout-zebra       = abap_true.
    lwa_layout-cwidth_opt  = abap_true.

* Populate Field cat

    PERFORM f_fill_accnt_fcat CHANGING li_accnt_fcat.

*&--Display data of accnt details
    CALL METHOD fp_alv_grid_accnt->set_table_for_first_display
      EXPORTING
        is_layout                     = lwa_layout
        i_save                        = lc_a
        i_default                     = abap_true
      CHANGING
        it_outtab                     = fp_i_accnt_det
        it_fieldcatalog               = li_accnt_fcat
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF. " IF sy-subrc <> 0
    cl_gui_cfw=>flush( ).
  ELSE. " ELSE -> IF fp_dock_cont IS NOT BOUND
    IF fp_alv_grid_accnt IS BOUND.
      CALL METHOD fp_alv_grid_accnt->refresh_table_display
        EXCEPTIONS
          finished = 1
          OTHERS   = 2.

      cl_gui_cfw=>flush( ).
    ENDIF. " IF fp_alv_grid_accnt IS BOUND
  ENDIF. " IF fp_dock_cont IS NOT BOUND

ENDFORM. " F_FIL_ALV_GRID2
*&---------------------------------------------------------------------*
*&      Form  F_FILL_ACCNT_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LI_ACCNT_FCAT  text
*----------------------------------------------------------------------*
FORM f_fill_accnt_fcat  CHANGING fp_i_accnt_fcat TYPE lvc_t_fcat.
  CONSTANTS: lc_rrdocview  TYPE char30 VALUE 'RRDOCVIEW'. " Rrdocview of type CHAR30
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = lc_rrdocview
    CHANGING
      ct_fieldcat            = fp_i_accnt_fcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    CLEAR fp_i_accnt_fcat[].
  ENDIF. " IF sy-subrc <> 0

ENDFORM. " F_FILL_ACCNT_FCAT
*&---------------------------------------------------------------------*
*&      Form  F_GLOBAL_CLEAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_global_clear .
  CLEAR:i_likp[],
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
          gv_vpobj,
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
          i_lips[],
          i_vbak[],
          i_vbap[],
          i_konv[],
          i_kna1[],
          i_vbfa[],
          i_vbrk[],
          i_vbreve[],
          i_bkpf[],
          i_final[],
          i_fieldcat[],
          i_accnt_det[].


ENDFORM. " F_GLOBAL_CLEAR
*&---------------------------------------------------------------------*
*&      Form  F_GET_STATUS_VBUP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_LIPS  text
*      <--P_I_VBUP  text
*----------------------------------------------------------------------*
FORM f_get_status_vbup    USING fp_i_lips    TYPE ty_lips_t
                          CHANGING fp_i_vbup TYPE ty_vbup_t.

*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
  FIELD-SYMBOLS: <lfs_lips>  TYPE ty_lips.
  CONSTANTS: lc_i  TYPE char1 VALUE 'I',  " I of type CHAR1
             lc_eq TYPE char2 VALUE 'EQ'. " Eq of type CHAR2
  DATA: li_pdsta     TYPE STANDARD TABLE OF fkk_ranges, " Structure: Select Options
        li_pdsta_tmp TYPE STANDARD TABLE OF fkk_ranges, " Structure: Select Options
        lwa_pdsta    TYPE fkk_ranges.                   " Structure: Select Options
  " Using range table to store values of POD status
  lwa_pdsta-sign   = lc_i.
  lwa_pdsta-option = lc_eq.
  lwa_pdsta-low    = c_pdsta_a.
  APPEND lwa_pdsta TO li_pdsta.
  CLEAR lwa_pdsta-low.

  lwa_pdsta-low = c_pdsta_b.
  APPEND lwa_pdsta TO li_pdsta.
  CLEAR lwa_pdsta-low.

  lwa_pdsta-low = c_pdsta_c.
  APPEND lwa_pdsta TO li_pdsta.
  CLEAR lwa_pdsta.

*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
  IF fp_i_lips[] IS NOT INITIAL.
    SELECT vbeln " Sales and Distribution Document Number
           posnr " Item number of the SD document
           fkivp " Intercompany Billing Status
           pdsta " POD status on item level
    FROM vbup    " Sales Document: Item Status
    INTO TABLE fp_i_vbup
    FOR ALL ENTRIES IN fp_i_lips
    WHERE vbeln = fp_i_lips-vbeln
    AND   posnr = fp_i_lips-posnr.


    IF sy-subrc EQ 0.
*--> Begin of delete for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
*      DELETE fp_i_vbup WHERE ( pdsta NE c_pdsta_a  OR
*                               pdsta NE  c_pdsta_b OR
*                               pdsta NE c_pdsta_c ).
*<-- End of delete for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018

*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
      DELETE fp_i_vbup WHERE pdsta NOT IN li_pdsta.
      " Filter data according to the POD Relevant/Confirmed radio-button selection
      IF p_rel IS NOT INITIAL
        AND p_conf IS NOT INITIAL.
        "Nothing to do
      ELSE. " ELSE -> IF p_rel IS NOT INITIAL
        IF p_rel IS NOT INITIAL.
          DELETE fp_i_vbup WHERE pdsta NE c_pdsta_a.
        ENDIF. " IF p_rel IS NOT INITIAL
        IF p_conf IS NOT INITIAL.
          li_pdsta_tmp[] = li_pdsta[].
          DELETE li_pdsta_tmp WHERE low EQ c_pdsta_a.
          DELETE fp_i_vbup WHERE pdsta NOT IN li_pdsta_tmp.
        ENDIF. " IF p_conf IS NOT INITIAL
      ENDIF. " IF p_rel IS NOT INITIAL
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
      SORT fp_i_vbup BY vbeln
                        posnr.
*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
* Now Delete the entries from LIPS which not in VBUP
      LOOP AT fp_i_lips ASSIGNING <lfs_lips>.
        READ TABLE fp_i_vbup WITH KEY vbeln = <lfs_lips>-vbeln
                                      posnr = <lfs_lips>-posnr
                                      BINARY SEARCH
                                      TRANSPORTING NO FIELDS.
        IF sy-subrc NE 0.
          CLEAR <lfs_lips>-vbeln.
        ENDIF. " IF sy-subrc NE 0
      ENDLOOP. " LOOP AT fp_i_lips ASSIGNING <lfs_lips>
      DELETE fp_i_lips WHERE vbeln IS INITIAL.

*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF fp_i_lips[] IS NOT INITIAL
ENDFORM. " F_GET_STATUS_VBUP
*&---------------------------------------------------------------------*
*&      Form  F_GET_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_LIPS  text
*      -->FP_I_LIKP  header data
*      -->P_I_VBAP  text
*      <--P_I_TVKO  text
*      <--P_I_TVM1  text
*      <--P_I_TVM4  text
*----------------------------------------------------------------------*
FORM f_get_desc  USING    fp_i_lips  TYPE ty_lips_t
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
                          fp_i_likp  TYPE ty_likp_t
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
                          fp_i_vbap  TYPE ty_vbap_t
                 CHANGING fp_i_tvkot TYPE ty_tvkot_t
                          fp_i_tvm1t TYPE ty_tvm1t_t
*                          fp_tvm4t TYPE ty_tvm4t_t
                          fp_i_tvrot TYPE ty_tvrot_t
                          fp_i_tvkmt TYPE ty_tvkmt_t.

  DATA: li_lips_tmp TYPE ty_lips_t,
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
        li_likp_tmp TYPE ty_likp_t,
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
        li_vbap_tmp TYPE ty_vbap_t.

* ---> Begin of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
*  CLEAR: li_lips_tmp[].
*  li_lips_tmp[] = fp_i_lips[].
*  SORT li_lips_tmp BY vkorg.
*  DELETE ADJACENT DUPLICATES FROM li_lips_tmp COMPARING vkorg.
* Get VKORG descriptions
*  IF li_lips_tmp[] IS NOT INITIAL.
* <--- End of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018

* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
  CLEAR: li_likp_tmp[].
  li_likp_tmp[] = fp_i_likp[].
  SORT li_likp_tmp BY vkorg.
  DELETE ADJACENT DUPLICATES FROM li_likp_tmp COMPARING vkorg.

  IF li_likp_tmp[] IS NOT INITIAL.
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
    SELECT spras vkorg vtext FROM tvkot " Organizational Unit: Sales Organizations
                INTO TABLE fp_i_tvkot
* ---> Begin of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
*           FOR ALL ENTRIES IN li_lips_tmp
*           WHERE  spras = sy-langu
*            AND   vkorg = li_lips_tmp-vkorg.
* <--- End of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
      FOR ALL ENTRIES IN li_likp_tmp
           WHERE  spras = sy-langu
            AND   vkorg = li_likp_tmp-vkorg.
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
    IF sy-subrc = 0.
      SORT fp_i_tvkot BY spras vkorg.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_likp_tmp[] IS NOT INITIAL

  CLEAR: li_lips_tmp[].
  li_lips_tmp[] = fp_i_lips[].

  SORT li_lips_tmp BY mvgr1.
  DELETE ADJACENT DUPLICATES FROM li_lips_tmp COMPARING mvgr1.
* Get VKORG descriptions
  IF li_lips_tmp[] IS NOT INITIAL.
    SELECT spras mvgr1 bezei FROM tvm1t " Organizational Unit: Sales Organizations
                INTO TABLE fp_i_tvm1t
           FOR ALL ENTRIES IN li_lips_tmp
           WHERE  spras = sy-langu
            AND   mvgr1 = li_lips_tmp-mvgr1.
    IF sy-subrc = 0.
      SORT fp_i_tvm1t BY spras mvgr1.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_lips_tmp[] IS NOT INITIAL

* ---> Begin of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
*  CLEAR: li_lips_tmp[].
*  li_lips_tmp[] = fp_i_lips[].
*  SORT li_lips_tmp BY route.
*  DELETE ADJACENT DUPLICATES FROM li_lips_tmp COMPARING route.
*
*  IF NOT li_lips_tmp[] IS INITIAL.
* <--- End of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
  CLEAR: li_likp_tmp[].
  li_likp_tmp[] = fp_i_likp[].
  SORT li_likp_tmp BY route.
  DELETE ADJACENT DUPLICATES FROM li_likp_tmp COMPARING route.

  IF NOT li_likp_tmp[] IS INITIAL.
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
    SELECT spras " Language Key
           route "  Route
           bezei "  Description of Route
    FROM tvrot   " Routes: Texts
    INTO TABLE fp_i_tvrot
* ---> Begin of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
*    FOR ALL ENTRIES IN li_lips_tmp
*      WHERE spras = sy-langu "lc_lang
*      AND   route = li_lips_tmp-route.
* <--- End of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
    FOR ALL ENTRIES IN li_likp_tmp
      WHERE spras = sy-langu
      AND   route = li_likp_tmp-route.
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
    IF sy-subrc EQ 0.
      SORT fp_i_tvrot BY route.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF NOT li_likp_tmp[] IS INITIAL


  CLEAR: li_vbap_tmp[].
  li_vbap_tmp[] = fp_i_vbap[].

  SORT li_vbap_tmp BY ktgrm.
  DELETE ADJACENT DUPLICATES FROM li_vbap_tmp COMPARING ktgrm.
* Get accnt. assignment group descriptions
  IF li_vbap_tmp[] IS NOT INITIAL.
    SELECT spras ktgrm vtext FROM tvkmt " Organizational Unit: Sales Organizations
                INTO TABLE fp_i_tvkmt
           FOR ALL ENTRIES IN li_vbap_tmp
           WHERE  spras = sy-langu
            AND   ktgrm = li_vbap_tmp-ktgrm.
    IF sy-subrc = 0.
      SORT fp_i_tvkmt BY spras ktgrm.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_vbap_tmp[] IS NOT INITIAL

  CLEAR: li_lips_tmp[],
         li_vbap_tmp[].

ENDFORM. " F_GET_DESC
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_VKORG
*&---------------------------------------------------------------------*
*       Validating the Sales Org
*----------------------------------------------------------------------*
FORM f_validate_vkorg .
  DATA: lv_vkorg TYPE vkorg. "Sales Organization
* Perform Validation for Sales Organization.
  SELECT vkorg UP TO 1 ROWS " Sales Organization
    FROM tvko               " Organizational Unit: Sales Organizations
    BYPASSING BUFFER
    INTO lv_vkorg
    WHERE vkorg IN s_vkorg.
  ENDSELECT.
  IF sy-subrc NE 0.
    CLEAR lv_vkorg.
* Sales Organization is not valid.
    MESSAGE e984. "Sales Organization is invalid
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_VKORG
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_VTWEG
*&---------------------------------------------------------------------*
*       Validating the Distribution Channel
*----------------------------------------------------------------------*
FORM f_validate_vtweg .
  DATA: lv_vtweg TYPE vtweg. "Distribution Channel

  SELECT vtweg UP TO 1 ROWS " Distribution Channel
  FROM tvtw                 " Organizational Unit: Distribution Channels
  BYPASSING BUFFER
  INTO lv_vtweg
   WHERE vtweg IN s_vtweg.
  ENDSELECT.
  IF sy-subrc NE 0.
    CLEAR lv_vtweg.
* Distribution Channel is not valid.
    MESSAGE e985. "Distribution Channel is invalid
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_VTWEG
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DELIV
*&---------------------------------------------------------------------*
*       Validating the Delivery
*----------------------------------------------------------------------*
FORM f_validate_deliv .
  DATA: lv_vbeln TYPE vbeln_vl. " Delivery
  SELECT vbeln " Delivery
    FROM likp  " SD Document: Delivery Header Data
    UP TO 1 ROWS
    BYPASSING BUFFER
    INTO lv_vbeln
    WHERE vbeln IN s_vbelvl.
  ENDSELECT.
  IF sy-subrc NE 0.
    CLEAR:lv_vbeln.
* Delivery Number is not valid.
    MESSAGE e988. "Delivery Number is invalid
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_DELIV
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_LFART
*&---------------------------------------------------------------------*
*       Validating the Delivery Type
*----------------------------------------------------------------------*
FORM f_validate_lfart .
  DATA: lv_lfart TYPE lfart. "Delivery Type

  SELECT lfart UP TO 1 ROWS " Delivery Type
  FROM tvlk                 " Delivery Types
  BYPASSING BUFFER
  INTO lv_lfart
  WHERE lfart IN s_lfart.
  ENDSELECT.
  IF sy-subrc NE 0.
    CLEAR lv_lfart.
* Delivery Type is not valid.
    MESSAGE e989. "Delivery Type is invalid
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_LFART
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_WERKS
*&---------------------------------------------------------------------*
*       Validating the plant
*----------------------------------------------------------------------*
FORM f_validate_werks .
  DATA: lv_werks TYPE werks_d. " Plant
  SELECT werks " Plant
    FROM t001w " Plants/Branches
    UP TO 1 ROWS
    BYPASSING BUFFER
    INTO lv_werks
    WHERE werks IN s_werks.
  ENDSELECT.
  IF sy-subrc NE 0.
    CLEAR:lv_werks.
* Plant is not valid.
    MESSAGE e987. "Plant is invalid
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_WERKS
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_KUNNR
*&---------------------------------------------------------------------*
*       Validating Ship-to Partner
*----------------------------------------------------------------------*
FORM f_validate_kunnr .
  DATA: lv_kunnr TYPE kunwe. " Ship-to party
  SELECT kunnr " Customer Number
    FROM kna1  " General Data in Customer Master
    UP TO 1 ROWS
    BYPASSING BUFFER
    INTO lv_kunnr
    WHERE kunnr IN s_kunnr.
  ENDSELECT.
  IF sy-subrc NE 0.
    CLEAR:lv_kunnr.
* Ship-to-Party is not valid
    MESSAGE e992. "Ship-to-Party is invalid
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_KUNNR
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_KUNAG
*&---------------------------------------------------------------------*
*       Validating Sold-to Partner
*----------------------------------------------------------------------*
FORM f_validate_kunag .
  DATA: lv_kunag TYPE kunag. " Sold-to party
  SELECT kunnr " Customer Number
    FROM kna1  " General Data in Customer Master
    UP TO 1 ROWS
    BYPASSING BUFFER
    INTO lv_kunag
    WHERE kunnr IN s_kunag.
  ENDSELECT.
  IF sy-subrc NE 0.
    CLEAR: lv_kunag.
* Ship-to-Party is not valid
    MESSAGE e992. "Ship-to-Party is invalid
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_KUNAG
*&---------------------------------------------------------------------*
*&      Form  F_GET_HU_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_LIPS  text
*      <--P_I_VEKP  text
*----------------------------------------------------------------------*
FORM f_get_hu_details  USING    fp_i_lips TYPE ty_lips_t
                                fp_i_enh_status TYPE ty_emi_t
                       CHANGING fp_vpobj TYPE vpobj " Packing Object
                                fp_i_vekp TYPE ty_vekp_t.
  TYPES: BEGIN OF lty_likp1,
           vbeln TYPE vpobjkey, "Object Key (delivery)
         END OF lty_likp1.

  DATA: li_lips_tmp TYPE ty_lips_t.
  DATA: lwa_likp TYPE lty_likp1,
        li_likp  TYPE STANDARD TABLE OF lty_likp1 INITIAL SIZE 0.

  FIELD-SYMBOLS: <lfs_emi>  TYPE zdev_enh_status, " Enhancement Status
                 <lfs_lips> TYPE ty_lips.
* ---> Begin of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
** No need to clear this variables, as this variable is not yet populated
*  CLEAR: gv_vpobj.
* <--- End of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
  READ TABLE fp_i_enh_status ASSIGNING <lfs_emi> WITH KEY criteria = c_vpobj
                               BINARY SEARCH.
  IF sy-subrc IS INITIAL.
    fp_vpobj = <lfs_emi>-sel_low.
  ENDIF. " IF sy-subrc IS INITIAL
  UNASSIGN <lfs_emi>.

  CLEAR:  li_lips_tmp.
  li_lips_tmp[] = fp_i_lips.

  SORT  li_lips_tmp BY vbeln.
  DELETE ADJACENT DUPLICATES FROM  li_lips_tmp COMPARING vbeln.

* Form an internal table with Delivery in required format
  LOOP AT li_lips_tmp ASSIGNING <lfs_lips>.
    CLEAR lwa_likp.
    lwa_likp-vbeln = <lfs_lips>-vbeln.
    APPEND lwa_likp TO li_likp.
  ENDLOOP. " LOOP AT li_lips_tmp ASSIGNING <lfs_lips>

  IF   li_likp[] IS NOT INITIAL.
*   Get the details of HU & Freight
    SELECT venum        " Internal Handling Unit Number
           exidv        " External Handling Unit Identification
           vpobj        " Packing Object
           vpobjkey     " Key for Object to Which the Handling Unit is Assigned
           spe_idart_01 " Handling Unit Identification Type
           spe_ident_01 " Alternative HU Identification
           spe_idart_02 " Handling Unit Identification Type
           spe_ident_02 " Alternative HU Identification
           spe_idart_03 " Handling Unit Identification Type
           spe_ident_03 " Alternative HU Identification
  INTO TABLE fp_i_vekp
      FROM vekp         " Handling Unit - Header Table
      FOR ALL ENTRIES IN li_likp
      WHERE  vpobj = fp_vpobj
      AND    vpobjkey = li_likp-vbeln.
    IF sy-subrc = 0.
      SORT fp_i_vekp BY venum.
    ENDIF. " IF sy-subrc = 0

  ENDIF. " IF li_likp[] IS NOT INITIAL

ENDFORM. " F_GET_HU_DETAILS
*&---------------------------------------------------------------------*
*&      Form  F_AUTHORIZATION_CHECK
*&---------------------------------------------------------------------*
*       Authorization check for sales org
*----------------------------------------------------------------------*
FORM f_authorization_check .
  TYPES : BEGIN OF lty_vkorg,
            vkorg TYPE vkorg, " Sales Organization
          END OF lty_vkorg.
  DATA:li_vkorg   TYPE STANDARD TABLE OF lty_vkorg INITIAL SIZE 0.
  FIELD-SYMBOLS :  <lfs_vkorg>  TYPE lty_vkorg. " Sales Organization
  CONSTANTS: lc_vkorg   TYPE fieldname VALUE 'VKORG',    " Field Name
             lc_actvt   TYPE char5     VALUE 'ACTVT',    " Actvt of type CHAR5
             lc_zotc116 TYPE xuobject  VALUE 'ZOTC_116', " Authorization Object
             lc_disp    TYPE char2     VALUE '03'.       " Disp of type CHAR2

**      Get all the sales organizations from TVKO table which are requested from user.
  SELECT vkorg " Sales Organization
    INTO TABLE li_vkorg
    FROM tvko  " Organizational Unit: Sales Organizations
    WHERE vkorg IN s_vkorg.
  IF sy-subrc = 0.
    SORT li_vkorg BY vkorg.
  ENDIF. " IF sy-subrc = 0

  LOOP AT li_vkorg ASSIGNING <lfs_vkorg>.
** Check the authorization object ZOTC0028
    AUTHORITY-CHECK OBJECT lc_zotc116
    ID lc_vkorg FIELD <lfs_vkorg>-vkorg
    ID lc_actvt FIELD lc_disp.
**//--> Commented for testing
*    IF sy-subrc NE 0.
*      MESSAGE i924 WITH <lfs_vkorg>-vkorg.
*      LEAVE LIST-PROCESSING.
*    ENDIF. " IF sy-subrc NE 0
**//--> Commented for testing
  ENDLOOP. " LOOP AT li_vkorg ASSIGNING <lfs_vkorg>
ENDFORM. " F_AUTHORIZATION_CHECK

*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
*&---------------------------------------------------------------------*
*&      Form  F_APPL_SERVER_UPLOAD
*&---------------------------------------------------------------------*
*       Transporting file to AL11
*----------------------------------------------------------------------*
*      -->FP_I_FINAL  Final Internal table
*----------------------------------------------------------------------*
FORM f_appl_server_upload  USING    fp_i_final TYPE ty_final_t.
**//Local Data Declaration
  DATA: lv_filename   TYPE localfile, " Local file for upload/download
        lv_flag       TYPE flag,      " General Flag
        lwa_final     TYPE ty_final,  " local work-area
        lv_string     TYPE string,
        lv_lfimg      TYPE string,
        lv_track_num  TYPE string,
        lv_netwr      TYPE string,
        lv_rfmng      TYPE string,
        lv_netwr_vf   TYPE string,
        lv_wrbtr_rev1 TYPE string,
        lv_wrbtr_rev2 TYPE string,
        lv_wrbtr_rev3 TYPE string,
        lv_wrbtr      TYPE char16,    " Wrbtr of type CHAR16
        lv_ic_netwr   TYPE char16,    "Change for SCTASK0745122 by U033876
        lv_ic_bil_acc TYPE char16.    "Change for SCTASK0745122 by U033876

  CONSTANTS: lc_tab    TYPE char1  VALUE cl_abap_char_utilities=>horizontal_tab, " Tab
             lc_format TYPE string VALUE '.csv',
             lc_name   TYPE string VALUE 'END_TO_END_REVENUE_REPORT_',
             lc_score  TYPE c      VALUE '_'. " Score of type Character

  CONCATENATE p_path lc_name sy-datum sy-uzeit lc_score sy-uname lc_format INTO lv_filename.

  IF NOT lv_filename IS INITIAL.
**//Check file for authorization
    PERFORM f_check_file USING lv_filename
                      CHANGING lv_flag.
    IF lv_flag IS INITIAL.
**//Transferring the Final table to Application Server.
      OPEN DATASET lv_filename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " Output type
      IF sy-subrc IS INITIAL.

**//Concatenating For Header in Application Server
        CONCATENATE 'Delivery'(094)
                    'Item'(095)
                    'ItmCat'(096)
                    'DelCrDate'(090)
                    'Material'(004)
                    'Plnt'(097)
                    'StLoc'(098)
                    'DelQty'(099)
                    'UoM'(100)
                    'COGS'(127)
                    'COGS curr'(128)
                    'SO No.'(012)
                    'SO Itm'(013)
*                    'SalesOrder Line Item Block'(130)
                    'HdrLvl Item'(101)
                    'SalesOfc'(102)
                    'DistCh'(103)
                    'MatGrp1'(104)
                    'ProfitCtr'(105)
                    'POD Ind.'(106)
                    'Tracking No'(061)
                    'No_Tracknum'(062)
                    'MatGrp1Desc'(008)
                    'AccAssGrp'(107)
                    'NetVal'(014)
                    'SO BillBlk'(016)
                    'PayrBlk'(093)
                    'SolToCus Blk'(006)
                    'SalesOrder Line Item Block'(130)
                    'SO Date'(108)
                    'SO Created By'(089)
                    'SalDocTyp'(109)
                    'PODStatus'(110)
*                    'PODIcon'(011)
                    'Route'(111)
                    'Shp-toPty'(112)
                    'Sol-toPty'(113)
                    'ShpPt'(114)
                    'SalesOrg'(115)
                    'DelTyp'(116)
                    'AGI Date'(117)
                    'PODDate'(118)
                    'POD Created by'(129)
*                    'SolToCus Blk'(006)
                    'InvQty'(120)
                    'UoM'(100)
                    'BillTyp'(122)
                    'InvDate'(123)
                    'PostStat'(124)
                    'DocCurr'(125)
                    'InvNumber'(126)
                    'InvLnItm'(091)
                    'InvAmount'(084)
                    'RevRecStatus'(063)
                    'Payr'(092)
*                    'PayrBlk'(093)
                    'RevNetAmt1'(059)
                    'RevCurr1'(060)
                    'RevPostDat1'(067)
                    'RevDoc1'(069)
                    'RevNetAmt2'(070)
                    'RevCurr2'(071)
                    'RevPostDat2'(020)
                    'RevDoc2'(022)
                    'RevNetAmt3'(072)
                    'RevCurr3'(073)
                    'RevPostDat3'(026)
                    'RevDoc3'(028)
* Begin of Change for SCTASK0745122 by U033876
                    'IC Sale Org'(131)
                    'IC Dist Channel'(132)
                    'IC Partner'(133)
                    'IC AR Billing Invoice'(134)
                    'IC AR Invoice line item'(135)
                    'IC AR Revenue'(136)
                    'IC Currency'(137)
                    'IC Billing date'(138)
                    'IC AR Posting status'(139)
                    'IC AP Invoice'(140)
                    'IC AP Posting status (LRD COGS)'(141)
                    'TU Number'(142)
                    'IC billing value to be accrued'(143)
                    'Currency of IC billing accured'(144)
* End of change for SCTASK0745122 by U033876
                    INTO lv_string SEPARATED BY lc_tab.
      ENDIF. " IF sy-subrc IS INITIAL
      TRANSFER lv_string TO lv_filename.
      CLEAR lv_string.
    ENDIF. " IF lv_flag IS INITIAL
    " Populate data to the application server
    LOOP AT fp_i_final INTO lwa_final.
      lv_lfimg     = lwa_final-lfimg.
      lv_track_num = lwa_final-track_num.
      lv_netwr     = lwa_final-netwr.
      lv_rfmng     = lwa_final-rfmng.
      lv_netwr_vf  = lwa_final-netwr_vf.
      lv_wrbtr_rev1 = lwa_final-wrbtr_rev1.
      lv_wrbtr_rev2 = lwa_final-wrbtr_rev2.
      lv_wrbtr_rev3 = lwa_final-wrbtr_rev3.
      lv_wrbtr      = lwa_final-rfwrt.
*Begin of Change for SCTASK0745122 by U033876
      lv_ic_netwr   = lwa_final-ic_netwr.
      lv_ic_bil_acc = lwa_final-ic_bil_accu.
*End of Change for SCTASK0745122 by U033876
      CONCATENATE lwa_final-vbeln
                  lwa_final-posnr
                  lwa_final-pstyv
                  lwa_final-erdat
                  lwa_final-matnr
                  lwa_final-werks
                  lwa_final-lgort
                  lv_lfimg
                  lwa_final-meins
* Begin of SCTASK
                  lv_wrbtr
                  lwa_final-waers
* End of SCTASK
                  lwa_final-vgbel
                  lwa_final-vgpos
*                  lwa_final-faksp
                  lwa_final-uepos
                  lwa_final-vkbur
                  lwa_final-vtweg
                  lwa_final-mvgr1
                  lwa_final-prctr
                  lwa_final-kzpod
                  lwa_final-spe_ident_01
                  lv_track_num
                  lwa_final-bezei1
                  lwa_final-ktgrm
                  lv_netwr
                  lwa_final-faksk
                  lwa_final-pay_bb
                  lwa_final-cust_block
                  lwa_final-faksp
                  lwa_final-erdat_s
                  lwa_final-ernam_s
                  lwa_final-auart
                  lwa_final-pdsta_value
*                  lwa_final-pdsta
                  lwa_final-route
                  lwa_final-kunnr
                  lwa_final-kunag
                  lwa_final-vstel
                  lwa_final-vkorg
                  lwa_final-lfart
                  lwa_final-wadat_ist
                  lwa_final-podat
* Begin of SCTASK
                  lwa_final-usnam
* End of SCTASK
*                  lwa_final-cust_block
                  lv_rfmng
                  lwa_final-meins_bill
                  lwa_final-fkart
                  lwa_final-fkdat
                  lwa_final-rfbsk
                  lwa_final-waerk_vf
                  lwa_final-vbeln_bill
                  lwa_final-posnn_bill
                  lv_netwr_vf
                  lwa_final-ov_rrsta
                  lwa_final-payer
*                  lwa_final-pay_bb
                  lv_wrbtr_rev1
                  lwa_final-waerk_rev1
                  lwa_final-budat1
                  lwa_final-belnr1
                  lv_wrbtr_rev2
                  lwa_final-waerk_rev2
                  lwa_final-budat2
                  lwa_final-belnr2
                  lv_wrbtr_rev3
                  lwa_final-waerk_rev3
                  lwa_final-budat3
                  lwa_final-belnr3
*Begin of Change for SCTASK0745122 by U033876
                  lwa_final-vkoiv
                  lwa_final-vtwiv
                  lwa_final-kuniv
                  lwa_final-ic_vbeln
                  lwa_final-ic_posnr
                  lv_ic_netwr
                  lwa_final-ic_waerk
                  lwa_final-ic_fkdat
                  lwa_final-ic_rfbsk
                  lwa_final-ap_belnr
                  lwa_final-ap_bstat
                  lwa_final-tu_num
                  lv_ic_bil_acc
                  lwa_final-ic_bil_waerk
*End of Change for SCTASK0745122 by U033876
                  INTO lv_string
                  SEPARATED BY lc_tab.

      TRANSFER lv_string TO lv_filename.
      CLEAR: lwa_final,
             lv_string,
             lv_lfimg,
             lv_track_num,
             lv_netwr,
             lv_rfmng,
             lv_netwr_vf,
             lv_wrbtr_rev1,
             lv_wrbtr_rev2,
             lv_wrbtr_rev3,
             lv_wrbtr,
             lv_ic_netwr, lv_ic_bil_acc. "Change for SCTASK0745122 by U033876
    ENDLOOP. " LOOP AT fp_i_final INTO lwa_final
  ENDIF. " IF NOT lv_filename IS INITIAL

  CLOSE DATASET lv_filename.
*&-- File uploaded
  IF sy-subrc = 0.
    MESSAGE i910 WITH lv_filename. " File uploaded to &
    LEAVE LIST-PROCESSING.
  ELSE. " ELSE -> IF sy-subrc = 0
*&-- File not uploaded
    MESSAGE i959 WITH lv_filename. " Error while uploading file to &
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc = 0

ENDFORM. " F_APPL_SERVER_UPLOAD
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_FILE
*&---------------------------------------------------------------------*
*       Authorization check based on filename for AL11 action
*----------------------------------------------------------------------*
*      -->FP_LV_FILENAME  File name
*      <--FP_LV_FLAG      Flag
*----------------------------------------------------------------------*
FORM f_check_file  USING    fp_lv_filename TYPE localfile " Local file for upload
                   CHANGING fp_lv_flag     TYPE flag.     " General Flag

  CONSTANTS: lc_act  TYPE char5 VALUE 'WRITE'. " Act of type Character
  DATA:      lv_file TYPE fileextern. " Physical file name

  lv_file = fp_lv_filename.
*  Authorization for writing to dataset
  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
    EXPORTING
      activity         = lc_act
      filename         = lv_file
    EXCEPTIONS
      no_authority     = 1
      activity_unknown = 2
      OTHERS           = 3.

  IF sy-subrc <> 0.
    fp_lv_flag = abap_true.
  ELSE. " ELSE -> IF sy-subrc <> 0
    fp_lv_flag = abap_false.
  ENDIF. " IF sy-subrc <> 0

ENDFORM. " F_CHECK_FILE
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
*&---------------------------------------------------------------------*
*&      Form  F_GET_FPATH
*&---------------------------------------------------------------------*
*       Get file path
*----------------------------------------------------------------------*
*      <-- P_PATH  File path Parameter
*----------------------------------------------------------------------*
FORM f_get_fpath  CHANGING p_path.

  CONSTANTS: lc_ap   TYPE string VALUE '/appl/',
             lc_file TYPE string VALUE '/REP/OTC/OTC_RDD_0116/DONE/'.
  DATA: lv_syst  TYPE tbdls-logsys, " Logical system
        lv_spath TYPE char3.       " Spath(3) of type Character
* Function to get system name
  CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
    IMPORTING
      own_logical_system             = lv_syst
    EXCEPTIONS
      own_logical_system_not_defined = 1
      OTHERS                         = 2.
  IF sy-subrc IS INITIAL.
    lv_spath = lv_syst.
  ENDIF. " IF sy-subrc IS INITIAL
* Populate file path
  CONCATENATE lc_ap lv_spath lc_file INTO p_path.

ENDFORM. " F_GET_FPATH
*&---------------------------------------------------------------------*
*&      Form  F_GET_INTERCOMP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_LIKP  text
*      -->P_I_VBRK  text
*      -->P_I_VBRP  text
*      -->P_I_VBFA  text
*      -->P_I_BFPK  text
*----------------------------------------------------------------------*
FORM f_get_intercomp  USING    fp_i_likp TYPE ty_likp_t
                               fp_i_lips TYPE ty_lips_t
                               fp_i_vbrk TYPE ty_vbrk_t
                               fp_i_vbrp TYPE ty_vbrp_t
                               fp_i_vbfa TYPE ty_vbfa_t
                               fp_i_bkpf TYPE ty_bkpf_t
                      CHANGING
                               fp_ic_ar_bill  TYPE ty_ic_ar_bill_t
                               fp_i_bkpf_ap   TYPE ty_bkpf_ap_t.
  TYPES:BEGIN OF lty_ic_bill,
          vbelv        TYPE  vbeln_von,  " Preceding sales and distribution document
          posnv        TYPE  posnr_von,  " Preceding item of an SD document
          vbeln        TYPE  vbeln_nach, " Subsequent sales and distribution document
          posnn        TYPE  posnr_nach, " Subsequent item of an SD document
          vbtyp_n      TYPE  vbtyp_n,    " Document category of subsequent document
          rfmng        TYPE  rfmng,      " Referenced quantity in base unit of measure
          meins        TYPE  meins,      " Base Unit of Measure
          plmin        TYPE  plmin,      " Quantity is calculated positively, negatively or not at all
          erdat        TYPE  erdat,      " Date on Which Record Was Created
          erzet        TYPE  erzet,      " Entry time
          waerk        TYPE  waerk,      " SD Document Currency
          fkdat        TYPE  fkdat,      " Billing date for billing index and printout
          rfbsk        TYPE  rfbsk,      " Status for transfer to accounting
          vkorg_auft_i TYPE  vkorg,    " Sales Organization
          netwr_i      TYPE netwr_fp,  " Net value of the billing item in document currency
        END   OF lty_ic_bill,
        lty_ic_bill_t TYPE STANDARD TABLE OF lty_ic_bill,
        BEGIN OF lty_ic_ar_rev,
          vbeln     TYPE vbeln_vl,        " Delivery
          posnr     TYPE posnr_vl,        " Delivery Item
          matnr     TYPE matnr,           " Material Number
          vkoiv     TYPE vkoiv,           " Sales organization for intercompany billing
          vtwiv     TYPE vtwiv,           " Distribution channel for intercompany billing
          kuniv     TYPE kuniv,           " Customer number for intercompany billing
          wadat_ist TYPE wadat_ist,   " Actual Goods Movement Date
        END OF lty_ic_ar_rev,
        lty_ic_ar_rev_t TYPE STANDARD TABLE OF lty_ic_ar_rev,
        BEGIN OF lty_ic_rec,
          bukrs TYPE bukrs,           " Company Code
          xblnr TYPE xblnr1,          " Reference Document Number
        END OF lty_ic_rec,
        lty_ic_rec_t TYPE STANDARD TABLE OF lty_ic_rec.


  DATA: li_ic_rec      TYPE lty_ic_rec_t,
        li_ic_bill     TYPE lty_ic_bill_t,
        li_ic_bill_tmp TYPE lty_ic_bill_t,
        li_vbrp_tmp    TYPE ty_vbrp_t,
        lwa_ic_bill    TYPE lty_ic_bill,
        lwa_ic_ar_bill TYPE ty_ic_ar_bill,
        lwa_vbrp_tmp   TYPE ty_vbrp,
        lwa_ic_rec     TYPE lty_ic_rec,
        li_likp_tmp    TYPE ty_likp_t,
        li_lips_tmp    TYPE ty_lips_t,
        lwa_likp_tmp   TYPE ty_likp,
        lwa_lips_tmp   TYPE ty_lips,
        li_ic_ar_rev   TYPE lty_ic_ar_rev_t,
        lwa_ic_ar_rev  TYPE lty_ic_ar_rev.


  CONSTANTS:lc_plus TYPE plmin    VALUE '+', " Quantity is calculated positively, negatively or not at all
            lc_j    TYPE vbtyp_v  VALUE 'J', " Document category of preceding SD document
            lc_5    TYPE vbtyp_n  VALUE '5', " Document category of subsequent document
            lc_e    TYPE rfbsk    VALUE 'E'. " Status for transfer to accounting

* Begin of change for Sctask: SCTASK0745122 Intercompany Billing Accural fields by U033876
  DATA: li_likp      TYPE ty_likp_t,
        li_likp_tmp1 TYPE ty_likp_t,
        li_lips      TYPE ty_lips_t,
        lwa_likp     TYPE ty_likp,
        lwa_lips     TYPE ty_lips.

  CLEAR: li_likp[],
         li_likp_tmp1[],
         li_lips[],
         lwa_likp,
         lwa_lips.
  li_likp[] = fp_i_likp[].

  LOOP AT fp_i_likp INTO lwa_likp
                    WHERE vkoiv IS NOT INITIAL
                    AND   vtwiv IS NOT INITIAL
                    AND   kuniv IS NOT INITIAL.
    LOOP AT  fp_i_lips INTO lwa_lips
              WHERE vbeln = lwa_likp-vbeln.
      APPEND lwa_lips TO li_lips.
    ENDLOOP. " LOOP AT fp_i_lips INTO lwa_lips
    APPEND lwa_likp TO li_likp_tmp1.
    CLEAR: lwa_likp, lwa_lips.
  ENDLOOP. " LOOP AT fp_i_likp INTO lwa_likp



* Commented below code
*  li_vbrp_tmp[] = fp_i_vbrp[].*
*  SORT li_vbrp_tmp BY vgbel vgpos.
*  DELETE ADJACENT DUPLICATES FROM li_vbrp_tmp COMPARING vgbel vgpos.
*  IF li_vbrp_tmp[] IS NOT INITIAL.
  IF li_likp_tmp1[] IS NOT INITIAL.
* End of change for Sctask: SCTASK0745122 Intercompany Billing Accural fields by U033876


    SELECT  a~vbelv        " Preceding sales and distribution document
            a~posnv        " Preceding item of an SD document
            a~vbeln        " Subsequent sales and distribution document
            a~posnn        " Subsequent item of an SD document
            a~vbtyp_n      " Document category of subsequent document
            a~rfmng        " Referenced quantity in base unit of measure
            a~meins        " Base Unit of Measure
            a~plmin        " Quantity is calculated positively, negatively or not at all
            a~erdat        " Date on Which Record Was Created
            a~erzet        " Entry time
            b~waerk        " SD Document Currency
            b~fkdat        " Billing date for billing index and printout
            b~rfbsk        " Status for transfer to accounting
            b~vkorg_auft_i " Sales organization of sales order
            b~netwr_i      " Net value of the billing item in document currency
      FROM  vbfa AS a INNER JOIN wb2_v_vbrk_vbrp2 AS b
            ON a~vbeln = b~vbeln
            AND a~posnn = b~posnr_i
      INTO TABLE li_ic_bill
* Begin of change for Sctask: SCTASK0745122 Intercompany Billing Accural fields by U033876
*      FOR ALL ENTRIES IN li_vbrp_tmp
*     WHERE a~vbelv = li_vbrp_tmp-vgbel
       FOR ALL ENTRIES IN li_likp_tmp1
       WHERE a~vbelv = li_likp_tmp1-vbeln
* End of change for Sctask: SCTASK0745122 Intercompany Billing Accural fields by U033876
       AND a~vbtyp_n = lc_5
       AND a~vbtyp_v = lc_j
       AND a~plmin EQ lc_plus
       AND b~rfbsk NE lc_e
       AND b~fksto = abap_false.
    IF sy-subrc EQ 0.
*      DELETE li_ic_bill WHERE rfbsk = lc_e.
      SORT li_ic_bill BY vbeln posnn DESCENDING erdat DESCENDING erzet DESCENDING.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_likp_tmp1[] IS NOT INITIAL


  CLEAR: li_likp_tmp[],
         li_lips_tmp[].
  li_likp_tmp[] = fp_i_likp[].
  SORT li_likp_tmp BY vbeln.
  li_lips_tmp[] = fp_i_lips[].
  SORT li_lips_tmp BY vbeln.
  LOOP AT li_lips_tmp INTO lwa_lips_tmp .
    READ TABLE li_likp_tmp INTO lwa_likp_tmp
                    WITH KEY vbeln = lwa_lips_tmp-vbeln BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_ic_ar_rev-vbeln = lwa_lips_tmp-vbeln.
      lwa_ic_ar_rev-posnr = lwa_lips_tmp-posnr.
      lwa_ic_ar_rev-matnr = lwa_lips_tmp-matnr.
      lwa_ic_ar_rev-vkoiv = lwa_likp_tmp-vkoiv.
      lwa_ic_ar_rev-vtwiv = lwa_likp_tmp-vtwiv.
      lwa_ic_ar_rev-kuniv = lwa_likp_tmp-kuniv.
      lwa_ic_ar_rev-wadat_ist = lwa_likp_tmp-wadat_ist.
      APPEND  lwa_ic_ar_rev TO li_ic_ar_rev.
      CLEAR:lwa_ic_ar_rev.
    ENDIF. " IF sy-subrc = 0
  ENDLOOP. " LOOP AT li_lips_tmp INTO lwa_lips_tmp


  CLEAR: li_ic_bill_tmp[].
  li_ic_bill_tmp[] = li_ic_bill[].
*  SORT li_ic_bill_tmp BY vbelv posnv DESCENDING erdat DESCENDING erzet DESCENDING.
  SORT  li_ic_bill_tmp  BY vbeln posnn DESCENDING erdat DESCENDING erzet DESCENDING.

*  LOOP AT li_vbrp_tmp INTO lwa_vbrp_tmp.
  LOOP AT li_lips INTO lwa_lips.
    READ TABLE li_ic_bill_tmp INTO lwa_ic_bill
*                           WITH KEY vbelv = lwa_vbrp_tmp-vgbel
*                                    posnv = lwa_vbrp_tmp-vgpos.
                            WITH KEY vbelv = lwa_lips-vbeln
                                     posnv = lwa_lips-posnr.
    IF sy-subrc = 0.
      lwa_ic_ar_bill-ic_vbeln = lwa_ic_bill-vbeln .
      lwa_ic_ar_bill-ic_posnr = lwa_ic_bill-posnn.
      lwa_ic_ar_bill-ic_netwr = lwa_ic_bill-netwr_i.
      lwa_ic_ar_bill-ic_waerk = lwa_ic_bill-waerk.
      lwa_ic_ar_bill-ic_fkdat = lwa_ic_bill-fkdat.
      lwa_ic_ar_bill-ic_vgbel = lwa_lips-vbeln. "lwa_vbrp_tmp-vgbel.
      lwa_ic_ar_bill-ic_vgpos = lwa_lips-posnr. "lwa_vbrp_tmp-vgpos.
      lwa_ic_ar_bill-ic_rfbsk = lwa_ic_bill-rfbsk.
      APPEND lwa_ic_ar_bill TO fp_ic_ar_bill.
      CLEAR: lwa_ic_ar_bill.
    ENDIF. " IF sy-subrc = 0
  ENDLOOP. " LOOP AT li_lips INTO lwa_lips

  CLEAR:li_ic_bill_tmp[].
  li_ic_bill_tmp[] = li_ic_bill[].

* Get the IC AP Invoice & IC AP Posting status (LRD COGS) from BKPF
  CLEAR: li_ic_bill_tmp[].
  li_ic_bill_tmp[] = li_ic_bill[].
  SORT li_ic_bill_tmp BY vbeln.
  DELETE ADJACENT DUPLICATES FROM li_ic_bill_tmp COMPARING vbeln.
* convert vbeln to Xblnr
  LOOP AT li_ic_bill_tmp INTO lwa_ic_bill.
    lwa_ic_rec-bukrs = lwa_ic_bill-vkorg_auft_i.
    lwa_ic_rec-xblnr = lwa_ic_bill-vbeln.
    APPEND lwa_ic_rec TO li_ic_rec.
    CLEAR: lwa_ic_rec.
  ENDLOOP. " LOOP AT li_ic_bill_tmp INTO lwa_ic_bill

  IF li_ic_rec[] IS NOT INITIAL.
    SELECT bukrs     " Company Code
           belnr     " Accounting Document Number
           gjahr     " Fiscal Year
           xblnr     " Reference Document Number
           FROM bkpf " Accounting Document Header
           INTO TABLE fp_i_bkpf_ap
           FOR ALL ENTRIES IN li_ic_rec
           WHERE bukrs = li_ic_rec-bukrs
           AND   xblnr = li_ic_rec-xblnr.
    IF sy-subrc = 0.
      SORT fp_i_bkpf_ap BY xblnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_ic_rec[] IS NOT INITIAL

ENDFORM. " F_GET_INTERCOMP
*&---------------------------------------------------------------------*
*&      Form  F_RFC_CALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_FP_I_LIKP  text
*----------------------------------------------------------------------*
FORM f_rfc_call  CHANGING fp_i_likp TYPE ty_likp_t.

  CONSTANTS lc_rfcdes    TYPE z_criteria VALUE 'RFC_DEST'. " RFC Destination
  DATA : lwa_enh_status TYPE zdev_enh_status, " Enhancement Status
         lv_rfcdest     TYPE rfcdest,         " RFC Logical Destination
         lv_rfc_dest    TYPE recvsystem,      " Receiving logical system
         lv_source      TYPE logsys.          " Calling System

* i) Get the logical name of calling system
  CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
    IMPORTING
      own_logical_system             = lv_source
    EXCEPTIONS
      own_logical_system_not_defined = 1
      OTHERS                         = 2.

  IF sy-subrc = 0.
* ii) Get the target system from EMI
    READ TABLE i_enh_status INTO lwa_enh_status
      WITH KEY criteria = lc_rfcdes " 'RFC_DEST'
               sel_low  = lv_source.
    IF sy-subrc = 0.
      lv_rfcdest = lwa_enh_status-sel_high.
      CLEAR lwa_enh_status.

* iii) Check the RFC connection
      SELECT SINGLE logsys     " Receiving logical system
               FROM tblsysdest " RFC Destination of Logical System
               INTO lv_rfc_dest
              WHERE logsys = lv_rfcdest.
      IF sy-subrc = 0.

* iv) Call RFC FM and retrieve TUs
        CALL FUNCTION 'ZOTC_TU_FROM_DELIVERY'
          DESTINATION lv_rfc_dest
          TABLES
            tbl_dlv_tu            = fp_i_likp
          EXCEPTIONS
            system_failure        = 1
            communication_failure = 2
            OTHERS                = 3.
* Sy-Subrc not checked, because no error handling is required
      ELSE. " ELSE -> IF sy-subrc = 0
        MESSAGE i808. " RFC Connection to EWM Failed
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF sy-subrc = 0

  CLEAR : lv_source,
          lv_rfc_dest,
          lv_rfc_dest.


ENDFORM. " F_RFC_CALL
*&---------------------------------------------------------------------*
*&      Form  F_GET_IC_BILL_ACCURAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_LIPS  text
*      <--P_I_IC_AR_BILL  text
*----------------------------------------------------------------------*
FORM f_get_ic_bill_accural  USING    fp_i_vbak      TYPE ty_vbak_t
                                     fp_i_likp      TYPE ty_likp_t
                                     fp_i_lips      TYPE ty_lips_t
                                     fp_i_vbup      TYPE ty_vbup_t
                            CHANGING fp_ic_bill_acc  TYPE ty_ic_bill_acc_t.


*--> Begin of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
  CONSTANTS : lc_h TYPE char1 VALUE 'H'. " H of type CHAR1

  DATA      : lv_dest     TYPE logsys, " Calling System
              lv_rfc_dest TYPE char20.
*<-- End of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
  DATA: lwa_likp        TYPE ty_likp,
        lwa_lips        TYPE ty_lips,
        lwa_vbup        TYPE ty_vbup,
        lwa_ic_bill_acc TYPE ty_ic_bill_acc.
  DATA:
    lv_netwr     TYPE netwr_fp, " Net value of the billing item in document currency
    lv_curr      TYPE waerk,    " SD Document Currency
    lwa_vbsk     TYPE vbsk,     " Collective Processing for a Sales Document Header
    lwa_xkomfk   TYPE komfk,    " Billing Communications Table
* begin of change for defect 9070
    lwa_xkomfkgn TYPE komfkgn,         " Billing Interface: Communication Table
    li_xkomfkgn  TYPE TABLE OF komfkgn, " Billing Interface: Communication Table
    lv_vgpos     TYPE vgpos,            " Item number of the reference item
* end of change for defect 9070
    lwa_vbrk     TYPE vbrkvb,                           " Reference Structure for XVBRK/YVBRP
    lwa_vbrp     TYPE vbrpvb,                           " Reference Structure for XVBRP/YVBRP
    li_xkomfk    TYPE TABLE OF komfk   ,                 " Billing Communications Table
    li_xvbfs     TYPE TABLE OF vbfs    WITH HEADER LINE, " Error Log for Collective Processing
    li_xkomv     TYPE TABLE OF komv    WITH HEADER LINE, " Pricing Communications-Condition Record
    li_xthead    TYPE TABLE OF theadvb WITH HEADER LINE, " Reference Structure for XTHEAD
    li_xvbpa     TYPE TABLE OF vbpavb  WITH HEADER LINE, " Reference structure for XVBPA/YVBPA
    li_xvbrk     TYPE TABLE OF vbrkvb  WITH HEADER LINE, " Reference Structure for XVBRK/YVBRP
    li_xvbss     TYPE TABLE OF vbss    WITH HEADER LINE, " Collective Processing: Sales Documents
    li_tkomk     TYPE TABLE OF komk    WITH HEADER LINE, " Communication Header for Pricing
    li_tkomp     TYPE TABLE OF komp    WITH HEADER LINE, " Communication Item for Pricing
    li_xvbrp     TYPE TABLE OF vbrpvb  WITH HEADER LINE. " Reference Structure for XVBRP/YVBRP

  FIELD-SYMBOLS: <lfs_vbak> TYPE ty_vbak.

  CLEAR:li_xkomfk[],
        li_xvbfs,
        li_xkomv,
        li_xthead,
        li_xvbpa,
        li_xvbrk,
        lwa_vbrk,
        li_xvbrp,
        lwa_vbrp,
        li_xvbss,
        li_tkomk,
        li_tkomp,
        lv_netwr,
        lv_curr,
        lv_vgpos,
        lwa_ic_bill_acc.

  SORT fp_i_vbup BY vbeln posnr fkivp pdsta.
  SORT fp_i_likp BY vbeln.
  SORT fp_i_lips BY vbeln posnr.
  LOOP AT fp_i_lips INTO lwa_lips.
*    lv_vgpos = sy-tabix.
*    lv_vgpos = lv_vgpos + 1.
    READ TABLE fp_i_vbup INTO lwa_vbup
                         WITH KEY vbeln = lwa_lips-vbeln
                                  posnr = lwa_lips-posnr
                                  fkivp = 'A'
                                  pdsta = 'C' BINARY SEARCH.
    IF sy-subrc = 0.
* -	Check if the POD is completed for the delivery (VBUK- PDSTK = C)
*      and status of Intercompany billing is Not yet processed (VBUK–FKIVK = A).
      READ TABLE fp_i_likp INTO lwa_likp
                           WITH KEY vbeln = lwa_lips-vbeln BINARY SEARCH.
      IF sy-subrc = 0.
        CLEAR: lwa_xkomfk,lwa_vbsk .
        MOVE-CORRESPONDING lwa_likp TO lwa_xkomfk.
        MOVE-CORRESPONDING lwa_lips TO lwa_xkomfk.


* Begin of change for defect 9070
        lwa_xkomfk-fkart = 'ZRF8'.
        APPEND lwa_xkomfk TO li_xkomfk.
*        READ TABLE fp_i_vbak ASSIGNING <lfs_vbak>
*                      WITH KEY vbeln = lwa_lips-vgbel
*                               BINARY SEARCH.
*        IF sy-subrc = 0.
*          lwa_xkomfkgn-auart  = <lfs_vbak>-auart.
*        ENDIF. " IF sy-subrc = 0
*        lwa_xkomfkgn-auart  = 'TA'.
*        lwa_xkomfkgn-mandt     = sy-mandt.
*        lwa_xkomfkgn-vkorg     = lwa_likp-vkorg.
*        lwa_xkomfkgn-vtweg     = lwa_lips-vtweg.
*        lwa_xkomfkgn-spart     = lwa_lips-spart.
*        lwa_xkomfkgn-fkdat     = sy-datum.
*        lwa_xkomfkgn-kunag     = lwa_likp-kunag.
*        lwa_xkomfkgn-pstyv     = 'TAN'. "lwa_lips-pstyv.
*        lwa_xkomfkgn-werks     = lwa_lips-werks.
*        lwa_xkomfkgn-matnr     = lwa_lips-matnr.
*        lwa_xkomfkgn-fkara     = 'FX'.
*        lwa_xkomfkgn-kwmeng    =  lwa_lips-lfimg.
*        lwa_xkomfkgn-vgbel     =  lwa_lips-vbeln ."sy-uzeit.
*        lwa_xkomfkgn-vgbel+6(4) = '9999'.
*        lwa_xkomfkgn-vgpos      = lwa_lips-posnr."lv_vgpos.
*        lwa_xkomfkgn-taxm1      =  '1'.
*        lwa_xkomfkgn-taxk1      =  '1'.
*
*        APPEND lwa_xkomfkgn TO  li_xkomfkgn.
*        CLEAR: lwa_xkomfkgn.
* End of Change for Defect 9070
        CLEAR:lwa_xkomfk.
      ENDIF. " IF sy-subrc = 0

    ENDIF. " IF sy-subrc = 0
  ENDLOOP. " LOOP AT fp_i_lips INTO lwa_lips

  MOVE sy-datum TO lwa_vbsk-erdat.
  MOVE sy-uzeit TO lwa_vbsk-uzeit.
  MOVE sy-uname TO lwa_vbsk-ernam.

* For performance we call the below simulate FM once per delivery no instead of delivery item
*--> Begin of delete for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU


* Begin of Change for POC for RFC call to RV_INV_CREATE
*  CALL FUNCTION 'RV_INVOICE_CREATE'
*    EXPORTING
*      vbsk_i        = lwa_vbsk
*      with_posting  = 'H'
*      id_no_enqueue = 'X'
*    IMPORTING
*      vbsk_e        = lwa_vbsk
*    TABLES
*      xkomfk        = li_xkomfk
*      xkomv         = li_xkomv
*      xthead        = li_xthead
*      xvbfs         = li_xvbfs
*      xvbpa         = li_xvbpa
*      xvbrk         = li_xvbrk
*      xvbrp         = li_xvbrp
*      xvbss         = li_xvbss.

*<-- End of delete for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
*--> Begin of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU

* Get the logical name of calling system for RFC destination
  CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
    IMPORTING
      own_logical_system             = lv_dest
    EXCEPTIONS
      own_logical_system_not_defined = 1
      OTHERS                         = 2.
  IF sy-subrc = 0.
* Do nothing
  ENDIF. " IF sy-subrc = 0

  CONCATENATE lv_dest '_OTC' INTO lv_rfc_dest. " Defect 9385

  CALL FUNCTION 'ZOTC_RV_INV_CREATE'
    DESTINATION lv_rfc_dest      " Defect 9385
    EXPORTING
      vbsk_i                = lwa_vbsk
      with_posting          = lc_h
      id_no_enqueue         = abap_true
    IMPORTING
      vbsk_e                = lwa_vbsk
    TABLES
      xkomfk                = li_xkomfk
      xkomv                 = li_xkomv
      xthead                = li_xthead
      xvbfs                 = li_xvbfs
      xvbpa                 = li_xvbpa
      xvbrk                 = li_xvbrk
      xvbrp                 = li_xvbrp
      xvbss                 = li_xvbss
      xkomfkgn              = li_xkomfkgn " for defect 9070
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2.
* End of Change for POC for RFC call to RV_INV_CREATE
*<-- End of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
  IF li_xvbrp[] IS NOT INITIAL.
    SORT li_xvbrp BY vgbel vgpos.
    LOOP AT fp_i_lips INTO lwa_lips.
      READ TABLE li_xvbrp INTO lwa_vbrp
                          WITH KEY vgbel = lwa_lips-vbeln
                                   vgpos = lwa_lips-posnr BINARY SEARCH.
      IF sy-subrc = 0.
        lv_netwr = lwa_vbrp-netwr.
        READ TABLE li_xvbrk INTO lwa_vbrk
                   WITH KEY vbeln = lwa_vbrp-vbeln.
        IF sy-subrc = 0.
          lv_curr = lwa_vbrk-waerk.
        ENDIF. " IF sy-subrc = 0
        lwa_ic_bill_acc-ic_bill_acc_vgbel = lwa_lips-vbeln.
        lwa_ic_bill_acc-ic_bill_acc_vgpos = lwa_lips-posnr.
        lwa_ic_bill_acc-ic_bill_acc_vbeln = lwa_vbrk-vbeln.
        lwa_ic_bill_acc-ic_bill_acc_posnr = lwa_vbrp-posnr.
        lwa_ic_bill_acc-ic_bil_accu       = lv_netwr.
        lwa_ic_bill_acc-ic_bil_waerk      = lv_curr.
        APPEND lwa_ic_bill_acc TO fp_ic_bill_acc.
        CLEAR: lwa_ic_bill_acc.
      ENDIF. " IF sy-subrc = 0
    ENDLOOP. " LOOP AT fp_i_lips INTO lwa_lips
  ENDIF. " IF li_xvbrp[] IS NOT INITIAL

ENDFORM. " F_GET_IC_BILL_ACCURAL
