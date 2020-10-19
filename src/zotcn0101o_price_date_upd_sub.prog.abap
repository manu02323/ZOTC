*&---------------------------------------------------------------------*
*&  Include           ZOTCN0101O_PRICE_DATE_UPD_SUB
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0101O_PRICE_DATE_UPD_SUB                          *
* TITLE      :  Pricing Date Update Report                             *
* DEVELOPER  :  ROHIT VERMA                                            *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_EDD_0101_Pricing Date Update                       *
*----------------------------------------------------------------------*
* DESCRIPTION: This is an include program of Report                    *
*              ZOTCR0101O_PRICE_DATE_UPD. All subroutines for this     *
*              report is written in this include program.              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 03-Oct-2013 RVERMA   E1DK913507 INITIAL DEVELOPMENT - CR#649         *
*&---------------------------------------------------------------------*
* 07-Feb-2014 RVERMA   E1DK913507 MOD-001: Def#649 - Additional changes*
*                                 related to data fetching from VBUK   *
*                                 (Order Status data), VBKD (Business  *
*                                 data) and VBAP (Order Item) table.   *
*&---------------------------------------------------------------------*
* 27-Mar-2014 RVERMA   E1DK913507 MOD-002: Def#649 - Addition of Screen*
*                                 fields Customer Grp1 and Customer    *
*                                 Grp2. Also make the screen field     *
*                                 Sold-to single entry field.          *
*&---------------------------------------------------------------------*
* 09-Apr-2014 RVERMA   E1DK913507 Def#649 - Update in logic of KNVV    *
*                                 (Customer Sales Data) & VBAK (Order  *
*                                 Header Data) table.                  *
*&---------------------------------------------------------------------*
* 05-Aug-2014 RVERMA   E1DK913507 Def#649 - Display successfull message*
*                                 after scheduling background job for  *
*                                 updating pricing date and than move  *
*                                 to selection screen instead of       *
*                                 leaving program.                     *
*&---------------------------------------------------------------------*
* 31-AUG-2017 SMUKHER4 E1DK930340/ Defect#3400 -Following changes are done
*                      E1DK930342  in the program:                     *
*                                 1)The selection will have a field    *
*                                 (Range) for Requested Delivery Date  *
*                                  (non-Mandatory).                    *
*                                 2)The mandatory fields should only be*
*                                   removed for background mode, when  *
*                                   the user executes a transaction in *
*                                   the foreground, the mandatory fields*
*                                   should be activated.               *
*                                 3)The system will consider all the   *
*                                  orders line items with requested    *
*                                   delivery date + 1 Day.             *
*                                 4)Once the job is completed          *
*                                  successfully, the date (req del date+1)
*                                 is added to EMI table, this date     *
*                                 will be populated in the requested   *
*                                  delivery date field in the next run.*
*                                5)Currently when the report is executed*
*                                  in the foreground, the user is      *
*                                  expected to select all the lines and*
*                                  click on update button, however, in *
*                                  the background, this should be done *
*                                  automatically.                      *
*                                6)All efforts needs to be made to     *
*                                 increase the performance of program  *
*                                 while executing during background.   *
*08-Aug-2018  AMOHAPA E1DK930340  Defect#3400(Part 2):                 *
*                                 Later taged with Defect#7955         *
*                                 1)Program to be                      *
*                                 made to process D3 sales organization*
*                                 records with different logic from    *
*                                 existing program                     *
*                                 2) Output of Batchjob to be import   *
*                                    in an excel sheet                 *
*25-Oct-2018  AMOHAPA E1DK930340  Defect#3400(Part 2)_FUT Issues:      *
*                                 Later taged with Defect#7955         *
*                                 1)Actual good movement date (LIKP-   *
*                                 WADAT_IST) is added in the selection *
*                                 screen                               *
*                                 2) Now pricing date is updated with  *
*                                 Actual good movement date            *
*                                 3)Instead of VBUK,now we are checking*
*                                 VBUP for Billing,POD and PGI status  *
*                                 4) We will update the pricing date   *
*                                 where pricing date is not same as    *
*                                 Actual goods movement date           *
*29-Nov-2018  AMOHAPA E1DK930340  Defect#3400(Part 2)_FUT Issues:      *
*                                 Later taged with Defect#7955         *
*                                 VBAP table entries are filtered from *
*                                  VBAK                                *
*13-Dec-2018  AMOHAPA E1DK930340  Defect#3400(Part 2)_FUT Issues:      *
*                                 Later taged with Defect#7955         *
*                                 1) D2 radiobutton is renamed as      *
*                                 online and D3 radiobutton as Batch   *
*                                 2) We will consider VBUP-PDSTA(POD   *
*                                 status while updating pricing date   *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION_SALESORG
*&---------------------------------------------------------------------*
*       Subroutine to validate Sales Organization
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_validation_salesorg .

  DATA:
    lv_vkorg TYPE vkorg. "Sales Org

*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
 "If we are executing the report with D3 organization then replacing the
 "selection parameter
  IF rb_d3 IS NOT INITIAL.
    s_vkorg[] = s_vkorg1[].
  ENDIF. " IF rb_d3 IS NOT INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018

  SELECT vkorg " Sales Organization
    UP TO 1 ROWS
    FROM tvko  " Organizational Unit: Sales Organizations
    INTO lv_vkorg
    WHERE vkorg IN s_vkorg.
  ENDSELECT.

  IF sy-subrc NE 0.
    MESSAGE e128
      WITH 'Sales Organization'(002).
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_VALIDATION_SALESORG
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION_DISTRCHNL
*&---------------------------------------------------------------------*
*       Subroutine to validate Distribution Channel
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_validation_distrchnl .

  DATA:
    lv_vtweg TYPE vtweg. "Distribution Channel
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
 "If we are executing the report with D3 organization then replacing the
 "selection parameter
  IF rb_d3 IS NOT INITIAL.
    s_vtweg[] = s_vtweg1[].
  ENDIF. " IF rb_d3 IS NOT INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018

  SELECT vtweg " Distribution Channel
    UP TO 1 ROWS
    FROM tvtw  " Organizational Unit: Distribution Channels
    INTO lv_vtweg
    WHERE vtweg IN s_vtweg.
  ENDSELECT.

  IF sy-subrc NE 0.
    MESSAGE e128
      WITH 'Distribution Channel'(003).
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_VALIDATION_DISTRCHNL
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION_DIVISION
*&---------------------------------------------------------------------*
*       Subroutine to validate Division
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_validation_division .

  DATA:
    lv_spart TYPE spart. "Division
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
 "If we are executing the report with D3 organization then replacing the
 "selection parameter
  IF rb_d3 IS NOT INITIAL.
    s_spart[] = s_spart1[].
  ENDIF. " IF rb_d3 IS NOT INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018

  SELECT spart " Division
    UP TO 1 ROWS
    FROM tspa  " Organizational Unit: Sales Divisions
    INTO lv_spart
    WHERE spart IN s_spart.
  ENDSELECT.

  IF sy-subrc NE 0.
    MESSAGE e128
      WITH 'Division'(019).
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_VALIDATION_DIVISION
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION_SDTYPE
*&---------------------------------------------------------------------*
*       Subroutine to validate Sales Doc Type
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_validation_sdtype .

  DATA:
    lv_auart TYPE auart. "Sales Doc Type
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
 "If we are executing the report with D3 organization then replacing the
 "selection parameter
  IF rb_d3 IS NOT INITIAL.
    s_auart[] = s_auart1[].
  ENDIF. " IF rb_d3 IS NOT INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018

  SELECT auart " Sales Document Type
    UP TO 1 ROWS
    FROM tvak  " Sales Document Types
    INTO lv_auart
    WHERE auart IN s_auart.
  ENDSELECT.

  IF sy-subrc NE 0.
    MESSAGE e128
      WITH 'Sales Doc Type'(021).
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_VALIDATION_SDTYPE
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION_SORDER
*&---------------------------------------------------------------------*
*       Subroutine to validate Sales Order Number
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_validation_sorder .

  DATA:
    lv_vbeln TYPE vbeln_va. "Sales Order Number
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
 "If we are executing the report with D3 organization then replacing the
 "selection parameter
  IF rb_d3 IS NOT INITIAL.
    s_vbeln[] = s_vbeln1[].
  ENDIF. " IF rb_d3 IS NOT INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018

  SELECT vbeln " Sales Document
    UP TO 1 ROWS
    FROM vbak  " Sales Document: Header Data
    INTO lv_vbeln
    WHERE vbeln IN s_vbeln.
  ENDSELECT.

  IF sy-subrc NE 0.
    MESSAGE e128
      WITH 'Sales Order Number'(006).
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_VALIDATION_SORDER
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION_SOLDPARTY
*&---------------------------------------------------------------------*
*       Subroutine to validate Sold-to Party
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_validation_soldparty .

  DATA:
    lv_kunag TYPE kunag. "Sold-to Party

  SELECT kunnr " Customer Number
    UP TO 1 ROWS
    FROM kna1  " General Data in Customer Master
    INTO lv_kunag
    WHERE kunnr IN s_kunag
      AND loevm EQ space.
  ENDSELECT.

  IF sy-subrc NE 0.
    MESSAGE e128
      WITH 'Sold-to Party'(007).
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_VALIDATION_SOLDPARTY
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION_SHIPPARTY
*&---------------------------------------------------------------------*
*       Subroutine to validate Ship-to Party
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_validation_shipparty .

  DATA:
    lv_kunnr TYPE kunnr. "Ship-to Party

  SELECT kunnr " Customer Number
    UP TO 1 ROWS
    FROM kna1  " General Data in Customer Master
    INTO lv_kunnr
    WHERE kunnr IN s_kunnr
      AND loevm EQ space.
  ENDSELECT.

  IF sy-subrc NE 0.
    MESSAGE e128
      WITH 'Ship-to Party'(008).
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_VALIDATION_SHIPPARTY
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION_MATERIAL
*&---------------------------------------------------------------------*
*       Subroutine to validate Material Number
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_validation_material .

  DATA:
    lv_matnr TYPE matnr. "Material Number

  SELECT matnr " Material Number
    UP TO 1 ROWS
    FROM mara  " General Material Data
    INTO lv_matnr
    WHERE matnr IN s_matnr.
  ENDSELECT.

  IF sy-subrc NE 0.
    MESSAGE e128
      WITH 'Material Number'(079).
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_VALIDATION_MATERIAL
*&---------------------------------------------------------------------*
*&      Form  F_GET_SO_DATA
*&---------------------------------------------------------------------*
*       Subroutine to get Sales Order Data
*----------------------------------------------------------------------*
*      -->FP_I_KNVV  Customer Master Sales Data
*      <--FP_I_VBAK  SO Header data table
*      <--FP_I_VBAP  SO Item data table
*      <--FP_I_VBPA  SO Partner data table
*      <--FP_I_VBUP  SO Item Status data table
*      <--FP_I_VBEP  SO Delivery data table
*      <--FP_I_VBKD  SO Business data table
*----------------------------------------------------------------------*
FORM f_get_so_data USING fp_i_knvv TYPE ty_t_knvv "HPQC Defect#649 : RVERMA : 09-Apr-2014
                CHANGING fp_i_vbak TYPE ty_t_vbak
                         fp_i_vbap TYPE ty_t_vbap
                         fp_i_vbpa TYPE ty_t_vbpa
                         fp_i_vbup TYPE ty_t_vbup
                         fp_i_vbep TYPE ty_t_vbep
                         fp_i_vbkd TYPE ty_t_vbkd.

*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
  PERFORM f_get_cust_so_data CHANGING fp_i_vbak
                                      fp_i_knvv.
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

*&-->Begin of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*&--Get Sales Order Header data
*  PERFORM f_get_so_header USING fp_i_knvv "HPQC Defect#649 : RVERMA : 09-Apr-2014
*                       CHANGING fp_i_vbak.
*&<--End of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

*&--Get Sales Order Item data
  PERFORM f_get_so_item USING fp_i_vbak
                     CHANGING fp_i_vbap.

*&--Get Sales Order Partner data
  PERFORM f_get_so_partner USING fp_i_vbak
                        CHANGING fp_i_vbpa.

*&--Check for Ship-to Party is entered at Selection Screen or not
  IF s_kunnr[] IS NOT INITIAL AND
     fp_i_vbpa[]  IS NOT INITIAL.
*&--Filter Sales Order Header & Item data based on Partner data
*&--entered at Selection Screen
    PERFORM f_filter_so_data USING fp_i_vbpa
                          CHANGING fp_i_vbak
                                   fp_i_vbap.
  ENDIF. " IF s_kunnr[] IS NOT INITIAL AND

*&--Get Sales Order Item Status data and filter Item data based
*&--SO Item Status data
  PERFORM f_get_so_item_stat CHANGING fp_i_vbap
                                      fp_i_vbup.

  IF sy-batch IS INITIAL.
*&--Get Sales Order Schedule Line Data
    PERFORM f_get_so_schdline USING fp_i_vbap
                           CHANGING fp_i_vbep.
  ENDIF. " IF sy-batch IS INITIAL
*&--Get Sales Order Business Data
  PERFORM f_get_so_busidata USING fp_i_vbap
                         CHANGING fp_i_vbkd.

ENDFORM. " F_GET_SO_DATA
*&---------------------------------------------------------------------*
*&      Form  F_GET_CUST_DATA
*&---------------------------------------------------------------------*
*       Subroutine to get Customer data
*----------------------------------------------------------------------*
*      -->FP_I_VBAK   SO Header data
*      -->FP_I_VBPA   SO Partner data
*      <--FP_I_KNVV   Customer Sales data
*      <--FP_I_KNA1   Customer General data
*      <--FP_I_TVV1T  Customer Group1 Text data
*      <--FP_I_TVV2T  Customer Group1 Text data
*----------------------------------------------------------------------*
FORM f_get_cust_data USING fp_i_vbak  TYPE ty_t_vbak
                           fp_i_vbpa  TYPE ty_t_vbpa
                           fp_i_knvv  TYPE ty_t_knvv
                  CHANGING fp_i_kna1  TYPE ty_t_kna1
                           fp_i_tvv1t TYPE ty_t_tvv1t
                           fp_i_tvv2t TYPE ty_t_tvv2t.

*&--Get Customer General Data
  PERFORM f_get_cust_name USING fp_i_vbak
                                fp_i_vbpa
                       CHANGING fp_i_kna1.

*&--BOC : HPQC Defect#649 : RVERMA : 09-Apr-2014
*&--Get Customer Sales Data
*  PERFORM f_get_cust_group USING fp_i_vbak
*                        CHANGING fp_i_knvv.
*&--EOC : HPQC Defect#649 : RVERMA : 09-Apr-2014

*&--Get Customer Group1 & Customer Group2 Text data
  PERFORM f_get_cust_grp_txt USING fp_i_knvv
                          CHANGING fp_i_tvv1t
                                   fp_i_tvv2t.

ENDFORM. " F_GET_CUST_DATA
*&---------------------------------------------------------------------*
*&      Form  F_GET_SO_HEADER
*&---------------------------------------------------------------------*
*       Subroutine to get Sales Order Header Data
*----------------------------------------------------------------------*
*      -->FP_I_KNVV  Customer Sales Data
*      <--FP_I_VBAK  SO Header Internal Table
*----------------------------------------------------------------------*
FORM f_get_so_header "USING fp_i_knvv TYPE ty_t_knvv "HPQC Defect#649 : RVERMA : 09-Apr-2014
                  CHANGING fp_i_vbak TYPE ty_t_vbak.

*&-->Begin of insert for FUT changes D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 23-OCT-2017
  TYPES: BEGIN OF lty_deldat,
         sign TYPE char1,   " Sign of type CHAR1
         option TYPE char2, " Option of type CHAR2
         low TYPE edatu,    " Schedule line date
         high TYPE edatu,   " Schedule line date
        END OF lty_deldat.

  DATA: lv_date  TYPE datum,         " Schedule line date
        lwa_days TYPE psen_duration. " Duration in Years, Months, and Days
                                              " Duration in Years, Months, and Days
  CONSTANTS lc_operator TYPE adsub VALUE '+'. " Processing indicator
  FIELD-SYMBOLS <lfs_deldat> TYPE lty_deldat. " Field Symbol for Req.Delv.Date

*&<--End of insert for FUT changes D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 23-OCT-2017

*&--BOC : HPQC Defect#649 : RVERMA : 09-Apr-2014
*  SELECT vbeln
*         erdat
*         auart
*         vkorg
*         vtweg
*         spart
*         kunnr
*    FROM vbak
*    INTO TABLE fp_i_vbak
*    WHERE vbeln IN s_vbeln
*      AND erdat IN s_erdat
*      AND auart IN s_auart
*      AND vkorg IN s_vkorg
*      AND vtweg IN s_vtweg
*      AND spart IN s_spart
*      AND kunnr IN s_kunag
*      AND kvgr1 IN s_kvgr1    "MOD-002 ++
*      AND kvgr2 IN s_kvgr2.   "MOD-002 ++

*&-->Begin of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*&--Since this is the first table to be hit, FAE is not required.
*  IF fp_i_knvv[] IS NOT INITIAL.
*&<--End of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

*&-->Begin of insert for FUT changes D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 23-OCT-2017
  CLEAR: lwa_days,
         lv_date.

  lwa_days-duryy = 0.
  lwa_days-durmm = 0.
  lwa_days-durdd = gv_days.

  READ TABLE s_deldat ASSIGNING <lfs_deldat> INDEX 1.
  IF sy-subrc IS INITIAL.

*&-- ADD/SUB days from date
    CALL FUNCTION 'HR_99S_DATE_ADD_SUB_DURATION'
      EXPORTING
        im_date     = <lfs_deldat>-low
        im_operator = lc_operator
        im_duration = lwa_days
      IMPORTING
        ex_date     = lv_date.

    <lfs_deldat>-option = 'BT'.
    <lfs_deldat>-high = lv_date.
  ENDIF. " IF sy-subrc IS INITIAL
*&<--End of insert for FUT changes D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 23-OCT-2017

*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*&--Since in background , mandatory fields are differnt, so we have used two SELECT statements based on the mandatory fields.
  IF sy-batch IS INITIAL.
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

*&--Fetch Sales Doc Header Data from VBAK table
    SELECT vbeln " Sales Document
           erdat " Date on Which Record Was Created
           auart " Sales Document Type
           vkorg " Sales Organization
           vtweg " Distribution Channel
           spart " Division
           kunnr " Sold-to party
      FROM vbak  " Sales Document: Header Data
      INTO TABLE fp_i_vbak
*&-->Begin of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*        FOR ALL ENTRIES IN fp_i_knvv
*&<--End of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

      WHERE vbeln IN s_vbeln
        AND erdat IN s_erdat
        AND auart IN s_auart
*&-->Begin of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*          AND vkorg EQ fp_i_knvv-vkorg
*          AND vtweg EQ fp_i_knvv-vtweg
*          AND spart EQ fp_i_knvv-spart
*          AND kunnr EQ fp_i_knvv-kunnr.
*&<--End of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*&--We are passing all the selection screen values.
        AND vkorg IN s_vkorg
        AND vtweg IN s_vtweg
        AND spart IN s_spart
        AND kunnr IN s_kunnr.
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

*&--EOC : HPQC Defect#649 : RVERMA : 09-Apr-2014

    IF sy-subrc EQ 0.
      SORT fp_i_vbak BY vbeln.
    ELSE. " ELSE -> IF sy-subrc EQ 0
      MESSAGE i906.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF sy-subrc EQ 0

*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
  ELSE. " ELSE -> IF sy-batch IS INITIAL

* For batch mode we should select data  from VBEP and then we should
* Take those Sales order to go to VBAK.
    SELECT vbeln " Sales Document
           posnr " Sales Document Item
           etenr " Delivery Schedule Line Number
           edatu " Schedule line date
           bmeng " Confirmed Quantity
      FROM vbep  " Sales Document: Schedule Line Data
      INTO TABLE i_vbep
      WHERE edatu IN s_deldat[].

    IF sy-subrc = 0.
* Filter the non confirmed items

      DELETE i_vbep WHERE bmeng IS INITIAL.

      SORT i_vbep BY vbeln posnr.
    ENDIF. " IF sy-subrc = 0

    IF i_vbep IS NOT INITIAL.
*&--Fetch Sales Doc Header Data from VBAK table
      SELECT vbeln " Sales Document
             erdat " Date on Which Record Was Created
             auart " Sales Document Type
             vkorg " Sales Organization
             vtweg " Distribution Channel
             spart " Division
             kunnr " Sold-to party
        FROM vbak  " Sales Document: Header Data
        INTO TABLE fp_i_vbak
        FOR ALL ENTRIES IN i_vbep
        WHERE vbeln = i_vbep-vbeln.


*      WHERE auart IN s_auart[]
*      AND   vkorg IN s_vkorg
*      AND   vtweg IN s_vtweg
*      AND   spart IN s_spart
*      AND   kunnr IN s_kunnr.

      IF sy-subrc IS INITIAL.
        IF s_vbeln[] IS NOT INITIAL.
          DELETE fp_i_vbak WHERE vbeln NOT IN s_vbeln[].
        ENDIF. " IF s_vbeln[] IS NOT INITIAL
        IF s_erdat[] IS NOT INITIAL.
          DELETE fp_i_vbak WHERE erdat NOT IN s_erdat[].
        ENDIF. " IF s_erdat[] IS NOT INITIAL

        IF  s_auart[] IS NOT INITIAL.
          DELETE fp_i_vbak WHERE auart NOT IN  s_auart[].
        ENDIF. " IF s_auart[] IS NOT INITIAL

        IF  s_vkorg[] IS NOT INITIAL.
          DELETE fp_i_vbak WHERE vkorg NOT IN  s_vkorg[].
        ENDIF. " IF s_vkorg[] IS NOT INITIAL
        IF  s_vtweg[] IS NOT INITIAL.
          DELETE fp_i_vbak WHERE vtweg NOT IN  s_vtweg[].
        ENDIF. " IF s_vtweg[] IS NOT INITIAL
        IF  s_spart[] IS NOT INITIAL.
          DELETE fp_i_vbak WHERE spart NOT IN  s_spart[].
        ENDIF. " IF s_spart[] IS NOT INITIAL
        IF  s_kunnr[] IS NOT INITIAL.
          DELETE fp_i_vbak WHERE kunag NOT IN  s_kunnr[].
        ENDIF. " IF s_kunnr[] IS NOT INITIAL
        IF fp_i_vbak IS NOT INITIAL.
          SORT fp_i_vbak BY vbeln.
        ELSE. " ELSE -> IF fp_i_vbak IS NOT INITIAL
          MESSAGE i906.
          LEAVE LIST-PROCESSING.

        ENDIF. " IF fp_i_vbak IS NOT INITIAL

      ENDIF. " IF sy-subrc IS INITIAL
    ELSE. " ELSE -> IF i_vbep IS NOT INITIAL
      MESSAGE i906.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF i_vbep IS NOT INITIAL

  ENDIF. " IF sy-batch IS INITIAL
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

*  ENDIF. " IF fp_i_knvv[] IS NOT INITIAL
ENDFORM. " F_GET_SO_HEADER
*&---------------------------------------------------------------------*
*&      Form  F_GET_SO_ITEM
*&---------------------------------------------------------------------*
*       Subroutine to get Sales Order Item data
*----------------------------------------------------------------------*
*      -->FP_I_VBAK  SO Header Internal Table
*      <--FP_I_VBAP  SO Item Internal Table
*----------------------------------------------------------------------*
FORM f_get_so_item USING fp_i_vbak TYPE ty_t_vbak
                CHANGING fp_i_vbap TYPE ty_t_vbap.

  IF fp_i_vbak[] IS NOT INITIAL.
*&--Fetch Sales Document Item Data from VBAP table
    SELECT vbeln " Sales Document
           posnr " Sales Document Item
           matnr " Material Number
*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
           abgru "Reason for rejection of quotations and sales orders
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
           meins  " Base Unit of Measure
           kwmeng " Cumulative Order Quantity in Sales Units
           werks  " Plant (Own or External)
      FROM vbap   " Sales Document: Item Data
      INTO TABLE fp_i_vbap
      FOR ALL ENTRIES IN fp_i_vbak
      WHERE vbeln EQ fp_i_vbak-vbeln.
*&-->Begin of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*&--Performance Tuning
*        AND matnr IN s_matnr
*        AND abgru EQ space. "Mod-001 ++
*&<--End of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

    IF sy-subrc EQ 0.
*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
      IF s_matnr[] IS NOT INITIAL.
        DELETE fp_i_vbap WHERE matnr NOT IN s_matnr.
      ENDIF. " IF s_matnr[] IS NOT INITIAL
      DELETE fp_i_vbap WHERE abgru NE space.

      IF fp_i_vbap IS NOT INITIAL.
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

        SORT fp_i_vbap BY vbeln posnr.
*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
      ENDIF. " IF fp_i_vbap IS NOT INITIAL
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
    ELSE. " ELSE -> IF sy-subrc EQ 0
      MESSAGE i906.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF fp_i_vbak[] IS NOT INITIAL

ENDFORM. " F_GET_SO_ITEM
*&---------------------------------------------------------------------*
*&      Form  F_GET_SO_PARTNER
*&---------------------------------------------------------------------*
*       Subroutine to get Sales Order Partner Data
*----------------------------------------------------------------------*
*      -->FP_I_VBAK  SO Header Internal Table
*      <--FP_I_VBPA  SO Partner Internal Table
*----------------------------------------------------------------------*
FORM f_get_so_partner USING fp_i_vbak TYPE ty_t_vbak
                   CHANGING fp_i_vbpa TYPE ty_t_vbpa.

  IF fp_i_vbak IS NOT INITIAL.

*&--Fetch Sales Document Partner Data from VBPA table
    SELECT vbeln " Sales and Distribution Document Number
           posnr " Item number of the SD document
           parvw " Partner Function
           kunnr " Customer Number
      FROM vbpa  " Sales Document: Partner
      INTO TABLE fp_i_vbpa
      FOR ALL ENTRIES IN fp_i_vbak
      WHERE vbeln EQ fp_i_vbak-vbeln
*        AND posnr EQ c_posnr_00        "MOD-001 --
        AND parvw EQ c_parvw_we.
*&-->Begin of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*&--Performance tuning
*       AND kunnr IN s_kunnr.
*&<--End of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

    IF sy-subrc EQ 0.
*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
      IF s_kunnr[] IS NOT INITIAL.
        DELETE fp_i_vbpa WHERE kunnr NOT IN s_kunnr[].
      ENDIF. " IF s_kunnr[] IS NOT INITIAL
      IF fp_i_vbpa IS NOT INITIAL.
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

        SORT fp_i_vbpa BY vbeln posnr.
*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
      ENDIF. " IF fp_i_vbpa IS NOT INITIAL
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

    ELSE. " ELSE -> IF sy-subrc EQ 0
      IF s_kunnr[] IS NOT INITIAL.
        MESSAGE i906.
        LEAVE LIST-PROCESSING.
      ENDIF. " IF s_kunnr[] IS NOT INITIAL
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF fp_i_vbak IS NOT INITIAL

ENDFORM. " F_GET_SO_PARTNER
*&---------------------------------------------------------------------*
*&      Form  F_FILTER_SO_DATA
*&---------------------------------------------------------------------*
*       Subroutine to filter out Sales Order Header and Item data based
*       Sales Order Partner data
*----------------------------------------------------------------------*
*      -->FP_I_VBPA  SO Partner Internal Table
*      <--FP_I_VBAK  SO Header Internal Table
*      <--FP_I_VBAP  SO Item Internal Table
*----------------------------------------------------------------------*
FORM f_filter_so_data USING fp_i_vbpa TYPE ty_t_vbpa
                   CHANGING fp_i_vbak TYPE ty_t_vbak
                            fp_i_vbap TYPE ty_t_vbap.

  DATA:
    lv_index   TYPE sytabix. "Index

  FIELD-SYMBOLS:
    <lfs_vbak> TYPE ty_vbak, "Field Symbol for SO Item data
    <lfs_vbap> TYPE ty_vbap. "Field Symbol for SO Partner data

*&--Process on SO Header data data
  LOOP AT fp_i_vbak ASSIGNING <lfs_vbak>.
*&--Read SO Partner data
    READ TABLE fp_i_vbpa TRANSPORTING NO FIELDS
                         WITH KEY vbeln = <lfs_vbak>-vbeln
                         BINARY SEARCH.
*&--If SO Partner data not found
    IF sy-subrc NE 0.
*&--Read SO Item data using parallel cursor technique
      READ TABLE fp_i_vbap TRANSPORTING NO FIELDS
                           WITH KEY vbeln = <lfs_vbak>-vbeln
                           BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_index = sy-tabix.
        LOOP AT fp_i_vbap ASSIGNING <lfs_vbap> FROM lv_index.
          IF <lfs_vbap>-vbeln NE <lfs_vbak>-vbeln.
            EXIT.
          ENDIF. " IF <lfs_vbap>-vbeln NE <lfs_vbak>-vbeln
*&--Assign Order Number with SPACE
          <lfs_vbap>-vbeln = space.
        ENDLOOP. " LOOP AT fp_i_vbap ASSIGNING <lfs_vbap> FROM lv_index
      ENDIF. " IF sy-subrc EQ 0
*&--Assign Order Number with SPACE
      <lfs_vbak>-vbeln = space.
    ENDIF. " IF sy-subrc NE 0
  ENDLOOP. " LOOP AT fp_i_vbak ASSIGNING <lfs_vbak>

*&--Delete SO Header data with Order Number = Space
  DELETE fp_i_vbak WHERE vbeln EQ space.
*&--Delete SO Item data with Order Number = Space
  DELETE fp_i_vbap WHERE vbeln EQ space.

ENDFORM. " F_FILTER_SO_DATA
*&---------------------------------------------------------------------*
*&      Form  F_GET_SO_ITEM_STAT
*&---------------------------------------------------------------------*
*       Subroutine to get SO Item Status Data and to filter SO Item data
*       based on Item Status data
*----------------------------------------------------------------------*
*      <--FP_I_VBAP  SO Item Internal Table
*      <--FP_I_VBUP  SO Item Status Table
*----------------------------------------------------------------------*
FORM f_get_so_item_stat CHANGING fp_i_vbap TYPE ty_t_vbap
                                 fp_i_vbup TYPE ty_t_vbup.

  FIELD-SYMBOLS:
    <lfs_vbap>  TYPE ty_vbap, "SO Item Data
    <lfs_vbup>  TYPE ty_vbup. "SO Item Status Data

*&--Check if there are entries in SO Item data table
  IF fp_i_vbap[] IS NOT INITIAL.
*&--Fetch SO Item Status data from VBUP table
    SELECT vbeln                 " Sales and Distribution Document Number
           posnr                 " Item number of the SD document
           lfsta                 " Delivery status
           fksta                 " Billing status of delivery-related billing documents
           fksaa                 " Billing Status for Order-Related Billing Documents
           absta                 " Rejection status for SD item
      FROM vbup                  " Sales Document: Item Status
      INTO TABLE fp_i_vbup
      FOR ALL ENTRIES IN fp_i_vbap
      WHERE vbeln EQ fp_i_vbap-vbeln
        AND posnr EQ fp_i_vbap-posnr
        AND lfsta EQ c_status_a. "MOD-001 ++

*&--IF Item Status data is fetched successfully
    IF sy-subrc EQ 0.

*&--Sort Item Status table based on VBELN & POSNR
      SORT fp_i_vbup BY vbeln posnr.

*&--Process on SO Item data table
      LOOP AT fp_i_vbap ASSIGNING <lfs_vbap>.

*&--Read SO Item Status data table based on Item data table
        READ TABLE fp_i_vbup ASSIGNING <lfs_vbup>
                             WITH KEY vbeln = <lfs_vbap>-vbeln
                                      posnr = <lfs_vbap>-posnr
                             BINARY SEARCH.
*&--BOC for MOD-001 ++
*&--SO Item Status data table has only those item records where
*&--no invoicing and no delivery has happened, so if record of VBAP
*&--not found in VBUP then that record shouldn't be displayed at o/p.
        IF sy-subrc NE 0.
          <lfs_vbap>-vbeln = space.
        ENDIF. " IF sy-subrc NE 0
*&--EOC for MOD-001 ++

*&--BOC for MOD-001 --
**        IF sy-subrc EQ 0 AND <lfs_vbup> IS ASSIGNED.
***&--Check for Item Status Data for No Delivery or No Invoicing
***&--or No Rejection
**          IF ( <lfs_vbup>-lfsta EQ c_status_b OR
**               <lfs_vbup>-lfsta EQ c_status_c ) OR
**             ( <lfs_vbup>-fksta EQ c_status_b OR
**               <lfs_vbup>-fksta EQ c_status_c ) OR
**             ( <lfs_vbup>-fksaa EQ c_status_b OR
**               <lfs_vbup>-fksaa EQ c_status_c ) OR
**             ( <lfs_vbup>-absta EQ c_status_b OR
**               <lfs_vbup>-absta EQ c_status_c ).
***&--Item data found for Delivery / Invoicing / Rejection and marking
***&--those item data for deletion from internal table SO Item data
***&--table.
**            <lfs_vbap>-vbeln = space.
**          ENDIF.
**        ENDIF.
*&--EOC for MOD-001 --

      ENDLOOP. " LOOP AT fp_i_vbap ASSIGNING <lfs_vbap>

*&--Delete SO Item data with Order Number = Space
      DELETE fp_i_vbap WHERE vbeln EQ space.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF fp_i_vbap[] IS NOT INITIAL

  IF fp_i_vbap[] IS INITIAL.
    MESSAGE i906.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF fp_i_vbap[] IS INITIAL

ENDFORM. " F_GET_SO_ITEM_STAT
*&---------------------------------------------------------------------*
*&      Form  F_GET_CUST_NAME
*&---------------------------------------------------------------------*
*       Subroutine to get Name of Sold-to and Ship-to Party
*----------------------------------------------------------------------*
*      -->FP_I_VBAK  SO Header Internal Table
*      -->FP_I_VBPA  SO Partner Internal Table
*      <--FP_I_KNA1  Customer Data Internal Table
*----------------------------------------------------------------------*
FORM f_get_cust_name USING fp_i_vbak TYPE ty_t_vbak
                           fp_i_vbpa TYPE ty_t_vbpa
                  CHANGING fp_i_kna1 TYPE ty_t_kna1.

  DATA:
    li_kna1  TYPE ty_t_kna1, "Customer Data Internal Table
    lwa_kna1 TYPE ty_kna1.   "Customer Data Workarea

  FIELD-SYMBOLS:
    <lfs_vbak> TYPE ty_vbak, "SO Header Data
    <lfs_vbpa> TYPE ty_vbpa. "SO Partner Data

*&--Collect all Sold-to Party Number from SO Header data table into
*&--Local internal table LI_KNA1
  LOOP AT fp_i_vbak ASSIGNING <lfs_vbak>.
    lwa_kna1-kunnr = <lfs_vbak>-kunag.
    APPEND lwa_kna1 TO li_kna1.
    CLEAR lwa_kna1.
  ENDLOOP. " LOOP AT fp_i_vbak ASSIGNING <lfs_vbak>

*&--Collect all Sold-to Party Number from SO Partner data table into
*&--Local internal table LI_KNA1
  LOOP AT fp_i_vbpa ASSIGNING <lfs_vbpa>.
    lwa_kna1-kunnr = <lfs_vbpa>-kunnr.
    APPEND lwa_kna1 TO li_kna1.
    CLEAR lwa_kna1.
  ENDLOOP. " LOOP AT fp_i_vbpa ASSIGNING <lfs_vbpa>

*&--Sort and Delete based on KUNNR
  SORT li_kna1 BY kunnr.
  DELETE ADJACENT DUPLICATES FROM li_kna1
                        COMPARING kunnr.

*&--Check if entry is there in LI_KNA1 Table
  IF li_kna1[] IS NOT INITIAL.
*&--Fetch data from KNA1 table
    SELECT kunnr " Customer Number
           name1 " Name 1
      FROM kna1  " General Data in Customer Master
      INTO TABLE fp_i_kna1
      FOR ALL ENTRIES IN li_kna1
      WHERE kunnr EQ li_kna1-kunnr
        AND loevm EQ space.
    IF sy-subrc EQ 0.
      SORT fp_i_kna1 BY kunnr.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_kna1[] IS NOT INITIAL

ENDFORM. " F_GET_CUST_NAME
*&--BOC : HPQC Defect#649 : RVERMA : 09-Apr-2014
*&---------------------------------------------------------------------*
*&      Form  F_GET_CUST_GROUP
*&---------------------------------------------------------------------*
*       Subroutine to get Customer Group Data
*----------------------------------------------------------------------*
*      -->FP_I_VBAK  SO Header Data Table
*      <--FP_I_KNVV  Customer Master Sales Data Table
*----------------------------------------------------------------------*
*FORM f_get_cust_group USING fp_i_vbak TYPE ty_t_vbak
*                   CHANGING fp_i_knvv TYPE ty_t_knvv.
*
*  DATA:
*    li_vbak TYPE ty_t_vbak. "Local table for SO Header Data
*
**&--Copy SO Header data into Local table
*  li_vbak[] = fp_i_vbak[].
*
**&--Sort and Delete duplicates in Local Header table
*  SORT li_vbak BY kunag vkorg vtweg spart.
*  DELETE ADJACENT DUPLICATES FROM li_vbak
*                        COMPARING kunag vkorg vtweg spart.
*
*  IF li_vbak[] IS NOT INITIAL.
**&--Fetch Customer Sales Data from KNVV table
*    SELECT kunnr
*           vkorg
*           vtweg
*           spart
*           kvgr1
*           kvgr2
*      FROM knvv
*      INTO TABLE fp_i_knvv
*      FOR ALL ENTRIES IN li_vbak
*      WHERE kunnr EQ li_vbak-kunag
*        AND vkorg EQ li_vbak-vkorg
*        AND vtweg EQ li_vbak-vtweg
*        AND spart EQ li_vbak-spart
*        AND loevm EQ space.
*    IF sy-subrc EQ 0.
*      SORT fp_i_knvv BY kunnr vkorg vtweg spart.
*    ENDIF.
*  ENDIF.
*
*ENDFORM.                    " F_GET_CUST_GROUP
*&--EOC : HPQC Defect#649 : RVERMA : 09-Apr-2014

*&---------------------------------------------------------------------*
*&      Form  F_GET_CUST_GRP_TXT
*&---------------------------------------------------------------------*
*       Subroutine to get Customer Group Text
*----------------------------------------------------------------------*
*      -->FP_I_KNVV   Customer Sales Master Data Table
*      <--FP_I_TVV1T  Customer group 1: Description Table
*      <--FP_I_TVV2T  Customer group 2: Description Table
*----------------------------------------------------------------------*
FORM f_get_cust_grp_txt USING fp_i_knvv  TYPE ty_t_knvv
                     CHANGING fp_i_tvv1t TYPE ty_t_tvv1t
                              fp_i_tvv2t TYPE ty_t_tvv2t.

  DATA:
    li_knvv   TYPE ty_t_knvv. "Customer Master Sales Data Table

*&--Copy Customer Sales Data into local internal table
  li_knvv[] = fp_i_knvv[].
*&--Sort & Delete LI_KNVV based on Customer Grp 2
  SORT li_knvv BY kvgr1.
  DELETE ADJACENT DUPLICATES FROM li_knvv
                        COMPARING kvgr1.

  IF li_knvv[] IS NOT INITIAL.
*&--Fetch Description of Customer Group1 from table TVV1T
    SELECT kvgr1 " Customer group 1
           bezei " Description
      FROM tvv1t " Customer group 1: Description
      INTO TABLE fp_i_tvv1t
      FOR ALL ENTRIES IN li_knvv
      WHERE spras EQ sy-langu
        AND kvgr1 EQ li_knvv-kvgr1.
    IF sy-subrc EQ 0.
      SORT fp_i_tvv1t BY kvgr1.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_knvv[] IS NOT INITIAL

  REFRESH li_knvv[].

*&--Copy Customer Sales Data into local internal table
  li_knvv[] = fp_i_knvv[].
*&--Sort & Delete LI_KNVV based on Customer Grp 2
  SORT li_knvv BY kvgr2.
  DELETE ADJACENT DUPLICATES FROM li_knvv
                        COMPARING kvgr2.

  IF li_knvv[] IS NOT INITIAL.
*&--Fetch Description of Customer Group2 from table TVV2T
    SELECT kvgr2 " Customer group 2
           bezei " Description
      FROM tvv2t " Customer group 2: Description
      INTO TABLE fp_i_tvv2t
      FOR ALL ENTRIES IN li_knvv
      WHERE spras EQ sy-langu
        AND kvgr2 EQ li_knvv-kvgr2.
    IF sy-subrc EQ 0.
      SORT fp_i_tvv2t BY kvgr2.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_knvv[] IS NOT INITIAL

ENDFORM. " F_GET_CUST_GRP_TXT
*&---------------------------------------------------------------------*
*&      Form  F_GET_MAT_DESC
*&---------------------------------------------------------------------*
*       Subroutine to get Material Description
*----------------------------------------------------------------------*
*      -->FP_I_VBAP  SO Item data table
*      <--FP_I_MAKT  Material Description Table
*----------------------------------------------------------------------*
FORM f_get_mat_desc USING fp_i_vbap TYPE ty_t_vbap
                 CHANGING fp_i_makt TYPE ty_t_makt.

  DATA:
    li_vbap  TYPE ty_t_vbap. "Local table for SO Item data

*&--Copy SO item data into local internal table
  li_vbap[] = fp_i_vbap[].

*&--Sort & Delete duplicates on local item table
  SORT li_vbap BY matnr.
  DELETE ADJACENT DUPLICATES FROM li_vbap
                        COMPARING matnr.

  IF li_vbap[] IS NOT INITIAL.
*&--Fetch Material Description from table MAKT
    SELECT matnr " Material Number
           maktx " Material Description (Short Text)
      FROM makt  " Material Descriptions
      INTO TABLE fp_i_makt
      FOR ALL ENTRIES IN li_vbap
      WHERE matnr EQ li_vbap-matnr
        AND spras EQ sy-langu.

    IF sy-subrc EQ 0.
      SORT fp_i_makt BY matnr.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_vbap[] IS NOT INITIAL

ENDFORM. " F_GET_MAT_DESC
*&---------------------------------------------------------------------*
*&      Form  F_GET_SO_SCHDLINE
*&---------------------------------------------------------------------*
*       Subroutine to get Sales Order First Schedule Line data
*----------------------------------------------------------------------*
*      -->FP_I_VBAP  SO Item data table
*      <--FP_I_VBEP  SO Schedule Line data table
*----------------------------------------------------------------------*
FORM f_get_so_schdline USING fp_i_vbap TYPE ty_t_vbap
                    CHANGING fp_i_vbep TYPE ty_t_vbep.

  IF fp_i_vbap[] IS NOT INITIAL.
*&--Fetch Schedule Line Item data from table VBEP
    SELECT vbeln " Sales Document
           posnr " Sales Document Item
           etenr " Delivery Schedule Line Number
           edatu " Schedule line date
           bmeng " Confirmed Quantity
      FROM vbep  " Sales Document: Schedule Line Data
      INTO TABLE fp_i_vbep
      FOR ALL ENTRIES IN fp_i_vbap
      WHERE vbeln EQ fp_i_vbap-vbeln
        AND posnr EQ fp_i_vbap-posnr.


    IF sy-subrc EQ 0.

*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
      DELETE fp_i_vbep WHERE bmeng IS INITIAL. " Filter out non confirmed line
*&--Filtering out the records based on the req del date.
      IF s_deldat[] IS NOT INITIAL.
        DELETE fp_i_vbep WHERE edatu NOT IN s_deldat[].
      ENDIF. " IF s_deldat[] IS NOT INITIAL
      IF fp_i_vbep[] IS NOT INITIAL.
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

        SORT fp_i_vbep BY vbeln posnr.
*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
      ENDIF. " IF fp_i_vbep[] IS NOT INITIAL
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF fp_i_vbap[] IS NOT INITIAL


ENDFORM. " F_GET_SO_SCHDLINE
*&---------------------------------------------------------------------*
*&      Form  F_GET_FINAL_TAB
*&---------------------------------------------------------------------*
*       Subroutine to populate final table
*----------------------------------------------------------------------*
*      -->FP_I_VBAK       SO Header data table
*      -->FP_I_VBAP       SO Item data table
*      -->FP_I_VBEP       SO Scedule Line data table
*      -->FP_I_VBPA       SO partner data table
*      -->FP_I_VBKD       SO business data table
*      -->FP_I_KNA1       Customer general data table
*      -->FP_I_KNVV       Customer sales data table
*      -->FP_I_TVV1T      Customer Grp1 desc table
*      -->FP_I_TVV2T      Customer Grp2 desc table
*      -->FP_I_MAKT       Material Desc table
*      <--FP_I_FINAL_HDR  Final Header table
*      <--FP_I_FINAL_ITM  Final Item table
*----------------------------------------------------------------------*
FORM f_get_final_tab USING fp_i_vbak  TYPE ty_t_vbak
                           fp_i_vbap  TYPE ty_t_vbap
                           fp_i_vbep  TYPE ty_t_vbep
                           fp_i_vbpa  TYPE ty_t_vbpa
                           fp_i_vbkd  TYPE ty_t_vbkd
                           fp_i_kna1  TYPE ty_t_kna1
                           fp_i_knvv  TYPE ty_t_knvv
                           fp_i_tvv1t TYPE ty_t_tvv1t
                           fp_i_tvv2t TYPE ty_t_tvv2t
                           fp_i_makt  TYPE ty_t_makt
                  CHANGING fp_i_final_hdr TYPE ty_t_final_hdr
                           fp_i_final_itm TYPE ty_t_final.

  DATA:
    lwa_final_hdr TYPE ty_final_hdr, "Final Header Workarea
    lwa_final_itm TYPE ty_final,     "Final Item Workarea
    lv_vbeln_old  TYPE vbeln_va,     "Order Number

*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-08-2017
*&--Local Work Area and variables.
    lwa_duration TYPE psen_duration_dec, " Duration in Years, Months, and Days with Decimals
    lv_date  TYPE datum,                 " Schedule line date

*&-->Begin of delete for FUT changes D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 23-OCT-2017
*    lwa_modify_emi TYPE zdev_enh_status, " Enhancement Status
*&<--End of delete for FUT changes D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 23-OCT-2017

    lwa_days TYPE psen_duration. " Duration in Years, Months, and Days
*&--Local Constants
  CONSTANTS: lc_operator TYPE adsub VALUE '+'. " Processing indicator

*&-->Begin of delete for FUT changes D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 23-OCT-2017
*             lc_0        TYPE sydatum VALUE '00000000'. " Current Date of Application Server
*&<--End of delete for FUT changes D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 23-OCT-2017

*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-08-2017

  FIELD-SYMBOLS:
    <lfs_vbak>  TYPE ty_vbak,  "SO Header data
    <lfs_vbap>  TYPE ty_vbap,  "SO Item data
    <lfs_vbep>  TYPE ty_vbep,  "SO Delivery data
    <lfs_vbpa>  TYPE ty_vbpa,  "SO Partner data
    <lfs_vbkd>  TYPE ty_vbkd,  "SO Business data
    <lfs_kna1>  TYPE ty_kna1,  "Customer General data
    <lfs_knvv>  TYPE ty_knvv,  "Customer Sales data
    <lfs_tvv1t> TYPE ty_tvv1t, "Customer Grp1 Desc data
    <lfs_tvv2t> TYPE ty_tvv2t, "Customer Grp2 Desc data
    <lfs_makt>  TYPE ty_makt.  "Material Desc data

*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
                               "Local data declaration
  DATA: lwa_likp TYPE ty_likp, "Local work area
        lwa_lips TYPE ty_lips. "Local work area
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018

*&--Process on each SO item data to populate Header & Item Final table
  LOOP AT fp_i_vbap ASSIGNING <lfs_vbap>.

    lwa_final_itm-vbeln  = <lfs_vbap>-vbeln.
    lwa_final_itm-posnr  = <lfs_vbap>-posnr.
    lwa_final_itm-matnr  = <lfs_vbap>-matnr.
    lwa_final_itm-werks  = <lfs_vbap>-werks.
    lwa_final_itm-meins  = <lfs_vbap>-meins.
    lwa_final_itm-kwmeng = <lfs_vbap>-kwmeng.

*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
 "If D2 radio button is preesed then Delivery date should populate from VBEP
    IF rb_d3 IS INITIAL.
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018

*&--Read SO Delivery data
      READ TABLE fp_i_vbep ASSIGNING <lfs_vbep>
                           WITH KEY vbeln = <lfs_vbap>-vbeln
                                    posnr = <lfs_vbap>-posnr
                           BINARY SEARCH.

      IF sy-subrc EQ 0 AND <lfs_vbep> IS ASSIGNED.
*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*&--In the output, we need to show Req.Del Date +1.
*&--Considering the orders with delivery date +1 Day
* Add days to dates
        CLEAR: lwa_days,
               lv_date.

        lwa_days-duryy = 0.
        lwa_days-durmm = 0.
        lwa_days-durdd = gv_days.
*&-- ADD/SUB days from date
        CALL FUNCTION 'HR_99S_DATE_ADD_SUB_DURATION'
          EXPORTING
            im_date     = <lfs_vbep>-edatu
            im_operator = lc_operator
            im_duration = lwa_days
          IMPORTING
            ex_date     = lv_date.

        lwa_final_itm-edatu = lv_date.
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

*&-->Begin of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*      lwa_final_itm-edatu = <lfs_vbep>-edatu.
*&<--End of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

      ENDIF. " IF sy-subrc EQ 0 AND <lfs_vbep> IS ASSIGNED

*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
    ELSE. " ELSE -> IF rb_d3 IS INITIAL
 "If D3 is pressed then we should populate it from LIKP
      READ TABLE i_lips INTO lwa_lips WITH KEY  vgbel = lwa_final_itm-vbeln
                                                vgpos = lwa_final_itm-posnr
                                                BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        READ TABLE i_likp INTO lwa_likp WITH KEY vbeln = lwa_lips-vbeln
                                                 BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          lwa_final_itm-edatu = lwa_likp-erdat.
        ENDIF. " IF sy-subrc IS INITIAL

      ENDIF. " IF sy-subrc IS INITIAL

    ENDIF. " IF rb_d3 IS INITIAL

    CLEAR: lwa_lips.
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018

*&--Read SO Business data
    READ TABLE fp_i_vbkd ASSIGNING <lfs_vbkd>
                         WITH KEY vbeln = <lfs_vbap>-vbeln
                                  posnr = <lfs_vbap>-posnr
                         BINARY SEARCH.

    IF sy-subrc EQ 0 AND <lfs_vbkd> IS ASSIGNED.
      lwa_final_itm-prsdt = <lfs_vbkd>-prsdt.

*&--BOC for MOD-001 ++
    ELSE. " ELSE -> IF sy-subrc EQ 0 AND <lfs_vbkd> IS ASSIGNED
*&--If data not found then get data when POSNR is initial
      READ TABLE fp_i_vbkd ASSIGNING <lfs_vbkd>
                           WITH KEY vbeln = <lfs_vbap>-vbeln
                                    posnr = c_posnr_00
                           BINARY SEARCH.
      IF sy-subrc EQ 0 AND <lfs_vbkd> IS ASSIGNED.
        lwa_final_itm-prsdt = <lfs_vbkd>-prsdt.
      ENDIF. " IF sy-subrc EQ 0 AND <lfs_vbkd> IS ASSIGNED
    ENDIF. " IF sy-subrc EQ 0 AND <lfs_vbkd> IS ASSIGNED
*&--EOC for MOD-001 ++
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
 "In D3 logic we will not update the Pricing date for those order where Pricing date is same
 "as Actual PGI date
    IF rb_d3 IS NOT INITIAL.
      lwa_final_itm-edatu = lwa_likp-wadat_ist.
      CLEAR lwa_likp.
    ENDIF. " IF rb_d3 IS NOT INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*&--Filtering out data if pricing date is same as first delivery date
    IF ( lwa_final_itm-prsdt IS NOT INITIAL AND
         lwa_final_itm-edatu IS NOT INITIAL ) AND
         lwa_final_itm-edatu NE lwa_final_itm-prsdt.
*&--Check of old order number with current order number to access and populate
*&--header data once for all item line of a order
      IF lv_vbeln_old NE <lfs_vbap>-vbeln.
        CLEAR lwa_final_hdr.

*&--Read SO Header data
        READ TABLE fp_i_vbak ASSIGNING <lfs_vbak>
                             WITH KEY vbeln = <lfs_vbap>-vbeln
                             BINARY SEARCH.

        IF sy-subrc EQ 0 AND <lfs_vbak> IS ASSIGNED.
          lwa_final_hdr-vbeln  = <lfs_vbak>-vbeln.
          lwa_final_hdr-auart  = <lfs_vbak>-auart.
          lwa_final_hdr-vkorg  = <lfs_vbak>-vkorg.
          lwa_final_hdr-vtweg  = <lfs_vbak>-vtweg.
          lwa_final_hdr-spart  = <lfs_vbak>-spart.
          lwa_final_hdr-kunag  = <lfs_vbak>-kunag.

*&--Read Customer General data to populate Sold-to Party Name
          READ TABLE fp_i_kna1 ASSIGNING <lfs_kna1>
                               WITH KEY kunnr = <lfs_vbak>-kunag
                               BINARY SEARCH.

          IF sy-subrc EQ 0 AND <lfs_kna1> IS ASSIGNED.
            lwa_final_hdr-name1_ag = <lfs_kna1>-name1.
          ENDIF. " IF sy-subrc EQ 0 AND <lfs_kna1> IS ASSIGNED

*&--Read Customer Business data
          READ TABLE fp_i_knvv ASSIGNING <lfs_knvv>
                               WITH KEY kunnr = <lfs_vbak>-kunag
                                        vkorg = <lfs_vbak>-vkorg
                                        vtweg = <lfs_vbak>-vtweg
                                        spart = <lfs_vbak>-spart
                               BINARY SEARCH.

          IF sy-subrc EQ 0 AND <lfs_knvv> IS ASSIGNED.
            lwa_final_hdr-kvgr1 = <lfs_knvv>-kvgr1.
            lwa_final_hdr-kvgr2 = <lfs_knvv>-kvgr2.

*&--Read Customer Group1 Description data
            READ TABLE fp_i_tvv1t ASSIGNING <lfs_tvv1t>
                                  WITH KEY kvgr1 = <lfs_knvv>-kvgr1
                                  BINARY SEARCH.
            IF sy-subrc EQ 0 AND <lfs_tvv1t> IS ASSIGNED.
              lwa_final_hdr-bezei_1 = <lfs_tvv1t>-bezei.
            ENDIF. " IF sy-subrc EQ 0 AND <lfs_tvv1t> IS ASSIGNED

*&--Read Customer Group2 Description data
            READ TABLE fp_i_tvv2t ASSIGNING <lfs_tvv2t>
                                  WITH KEY kvgr2 = <lfs_knvv>-kvgr2
                                  BINARY SEARCH.
            IF sy-subrc EQ 0 AND <lfs_tvv2t> IS ASSIGNED.
              lwa_final_hdr-bezei_2 = <lfs_tvv2t>-bezei.
            ENDIF. " IF sy-subrc EQ 0 AND <lfs_tvv2t> IS ASSIGNED
          ENDIF. " IF sy-subrc EQ 0 AND <lfs_knvv> IS ASSIGNED
        ENDIF. " IF sy-subrc EQ 0 AND <lfs_vbak> IS ASSIGNED

*&--Read SO Partner data
        READ TABLE fp_i_vbpa ASSIGNING <lfs_vbpa>
                             WITH KEY vbeln = <lfs_vbap>-vbeln
                                      posnr = c_posnr_00 "MOD-001 ++
                             BINARY SEARCH.

        IF sy-subrc EQ 0 AND <lfs_vbpa> IS ASSIGNED.
          lwa_final_hdr-kunnr = <lfs_vbpa>-kunnr.

*&--Read Customer General data to populate Ship-to Party Name
          READ TABLE fp_i_kna1 ASSIGNING <lfs_kna1>
                               WITH KEY kunnr = <lfs_vbpa>-kunnr
                               BINARY SEARCH.

          IF sy-subrc EQ 0 AND <lfs_kna1> IS ASSIGNED.
            lwa_final_hdr-name1_we = <lfs_kna1>-name1.
          ENDIF. " IF sy-subrc EQ 0 AND <lfs_kna1> IS ASSIGNED
        ENDIF. " IF sy-subrc EQ 0 AND <lfs_vbpa> IS ASSIGNED

*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
        IF sy-batch = abap_true.
          lwa_final_hdr-sel = abap_true.
        ENDIF. " IF sy-batch = abap_true
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*&--Append Final Header Data
        APPEND lwa_final_hdr TO fp_i_final_hdr.
      ENDIF. " IF lv_vbeln_old NE <lfs_vbap>-vbeln

      lwa_final_itm-auart    = lwa_final_hdr-auart.
      lwa_final_itm-vkorg    = lwa_final_hdr-vkorg.
      lwa_final_itm-vtweg    = lwa_final_hdr-vtweg.
      lwa_final_itm-spart    = lwa_final_hdr-spart.
      lwa_final_itm-kunag    = lwa_final_hdr-kunag.
      lwa_final_itm-name1_ag = lwa_final_hdr-name1_ag.
*      lwa_final_itm-kunnr    = lwa_final_hdr-kunnr.        "MOD-001 --
*      lwa_final_itm-name1_we = lwa_final_hdr-name1_we.     "MOD-001 --
      lwa_final_itm-kvgr1    = lwa_final_hdr-kvgr1.
      lwa_final_itm-kvgr2    = lwa_final_hdr-kvgr2.
      lwa_final_itm-bezei_1  = lwa_final_hdr-bezei_1.
      lwa_final_itm-bezei_2  = lwa_final_hdr-bezei_2.

*&--BOC for MOD-001 ++
      READ TABLE fp_i_vbpa ASSIGNING <lfs_vbpa>
                             WITH KEY vbeln = <lfs_vbap>-vbeln
                                      posnr = <lfs_vbap>-posnr
                             BINARY SEARCH.

      IF sy-subrc EQ 0 AND <lfs_vbpa> IS ASSIGNED.
        lwa_final_itm-kunnr = <lfs_vbpa>-kunnr.

*&--Read Customer General data to populate Ship-to Party Name
        READ TABLE fp_i_kna1 ASSIGNING <lfs_kna1>
                             WITH KEY kunnr = <lfs_vbpa>-kunnr
                             BINARY SEARCH.

        IF sy-subrc EQ 0 AND <lfs_kna1> IS ASSIGNED.
          lwa_final_itm-name1_we = <lfs_kna1>-name1.
        ENDIF. " IF sy-subrc EQ 0 AND <lfs_kna1> IS ASSIGNED
      ELSE. " ELSE -> IF sy-subrc EQ 0 AND <lfs_vbpa> IS ASSIGNED
        lwa_final_itm-kunnr    = lwa_final_hdr-kunnr.
        lwa_final_itm-name1_we = lwa_final_hdr-name1_we.
      ENDIF. " IF sy-subrc EQ 0 AND <lfs_vbpa> IS ASSIGNED
*&--EOC for MOD-001 ++

*&--Read Material Description data
      READ TABLE fp_i_makt ASSIGNING <lfs_makt>
                           WITH KEY matnr = <lfs_vbap>-matnr
                           BINARY SEARCH.

      IF sy-subrc EQ 0 AND <lfs_makt> IS ASSIGNED.
        lwa_final_itm-maktx = <lfs_makt>-maktx.
      ENDIF. " IF sy-subrc EQ 0 AND <lfs_makt> IS ASSIGNED

*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
      IF sy-batch = abap_true.
        lwa_final_itm-sel = abap_true.
      ENDIF. " IF sy-batch = abap_true
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*&--Append Final Item Data
      APPEND lwa_final_itm TO fp_i_final_itm.

*&--Assign current Order Number to Old Order Number
      lv_vbeln_old = <lfs_vbap>-vbeln.
    ENDIF. " IF ( lwa_final_itm-prsdt IS NOT INITIAL AND

    CLEAR lwa_final_itm.
  ENDLOOP. " LOOP AT fp_i_vbap ASSIGNING <lfs_vbap>

  SORT fp_i_final_hdr BY vkorg vtweg spart
                         auart vbeln.

  SORT fp_i_final_itm BY vkorg vtweg spart
                         auart vbeln posnr.

*&-->Begin of delete for FUT changes D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 23-OCT-2017

*&--System updating the EMI entry with the date is not a feasible solution,
*&-- so we are removing the logic for EMI entry updation.
*&--Instead the same thing will be controlled by creating the variant.

***&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
***&--Once the job is completed successfully, the date (req del date+1) is added to EMI table,
***this date will be populated in the requested delivery date field in the next run
*  IF sy-batch IS NOT INITIAL.
*    lwa_modify_emi-enhanc_no = c_enhancement.
*    lwa_modify_emi-sel_sign  = c_sign.
*    lwa_modify_emi-criteria  = c_date.
*    lwa_modify_emi-sel_low   = lc_0.
*    lwa_modify_emi-sel_option = c_eq.
*    lwa_modify_emi-sel_high   = lv_date.
*    lwa_modify_emi-active  = abap_true.
*
*    MODIFY zdev_enh_status FROM lwa_modify_emi.
*  ENDIF. " if sy-batch is not initial
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

*&<--End of delete for FUT changes D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 23-OCT-2017

  IF fp_i_final_hdr[] IS INITIAL.
    MESSAGE i906.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF fp_i_final_hdr[] IS INITIAL

ENDFORM. " F_GET_FINAL_TAB
*&---------------------------------------------------------------------*
*&      Form  F_GET_SO_BUSIDATA
*&---------------------------------------------------------------------*
*       Subroutine to get Sales Order Business Data
*----------------------------------------------------------------------*
*      -->FP_I_VBAP  SO Item data table
*      <--FP_I_VBKD  SO Business data table
*----------------------------------------------------------------------*
FORM f_get_so_busidata USING fp_i_vbap TYPE ty_t_vbap
                    CHANGING fp_i_vbkd TYPE ty_t_vbkd.

  IF fp_i_vbap[] IS NOT INITIAL.
*&--Fetch Sales Order Business data from table VBKD
    SELECT vbeln                      " Sales and Distribution Document Number
           posnr                      " Item number of the SD document
           prsdt                      " Date for pricing and exchange rate
      FROM vbkd                       " Sales Document: Business Data
      INTO TABLE fp_i_vbkd
      FOR ALL ENTRIES IN fp_i_vbap
      WHERE vbeln EQ fp_i_vbap-vbeln
        AND ( posnr EQ fp_i_vbap-posnr OR
              posnr EQ c_posnr_00 ) . "MOD-001 ++

    IF sy-subrc EQ 0.
      SORT fp_i_vbkd BY vbeln posnr.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF fp_i_vbap[] IS NOT INITIAL

ENDFORM. " F_GET_SO_BUSIDATA
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_HIER_ALV
*&---------------------------------------------------------------------*
*       Build Hierarchical ALV
*----------------------------------------------------------------------*
*      -->FP_I_FINAL_HDR  Final Header Table
*      -->FP_I_FINAL_ITM  Final Item Table
*----------------------------------------------------------------------*
FORM f_build_hier_alv USING fp_i_final_hdr TYPE ty_t_final_hdr
                            fp_i_final_itm TYPE ty_t_final.

  DATA:
    li_fieldcat         TYPE slis_t_fieldcat_alv, " Field catalog table
    lx_layout           TYPE slis_layout_alv,     " Layout structure
    lx_keyinfo          TYPE slis_keyinfo_alv,    " Keyinfo structure
    li_event            TYPE slis_t_event.        " Event table

*&--Build ALV Field Catalog
  PERFORM f_build_fieldcat: USING '1'(010) c_field_sel 'I_FINAL_HDR'(012) ' ' ''
                         CHANGING li_fieldcat,

                            USING '2'(013) 'VKORG'(014) 'I_FINAL_HDR'(012) 'Sales Org'(015) ''
                         CHANGING li_fieldcat,

                            USING '3'(039) 'VTWEG'(016) 'I_FINAL_HDR'(012) 'Distr. Channel'(017) ''
                         CHANGING li_fieldcat,

                            USING '4'(040) 'SPART'(018) 'I_FINAL_HDR'(012) 'Division'(019) ''
                         CHANGING li_fieldcat,

                            USING '5'(041) 'AUART'(020) 'I_FINAL_HDR'(012) 'Sales Doc Type'(021) ''
                         CHANGING li_fieldcat,

                            USING '6'(042) 'VBELN'(074) 'I_FINAL_HDR'(012) 'Sales Doc Number'(075) ''
                         CHANGING li_fieldcat,

                            USING '7'(043) 'KUNAG'(023) 'I_FINAL_HDR'(012) 'Sold-to Party Number'(024) ''
                         CHANGING li_fieldcat,

                            USING '8'(044) 'NAME1_AG'(025) 'I_FINAL_HDR'(012) 'Sold-to Party Name'(026) ''
                         CHANGING li_fieldcat,

                            USING '9'(045) 'KUNNR'(027) 'I_FINAL_HDR'(012) 'Ship-to Party Number'(028) c_check
                         CHANGING li_fieldcat,

                            USING '10'(046) 'NAME1_WE'(029) 'I_FINAL_HDR'(012) 'Ship-to Party Name'(030) c_check
                         CHANGING li_fieldcat,

                            USING '11'(047) 'KVGR1'(031) 'I_FINAL_HDR'(012) 'Buying Group Code'(032) ''
                         CHANGING li_fieldcat,

                            USING '12'(048) 'BEZEI_1'(033) 'I_FINAL_HDR'(012) 'Buying Group Desc'(034) ''
                         CHANGING li_fieldcat,

                            USING '13'(049) 'KVGR2'(035) 'I_FINAL_HDR'(012) 'IDN Code'(036) ''
                         CHANGING li_fieldcat,

                            USING '14'(050) 'BEZEI_2'(037) 'I_FINAL_HDR'(012) 'IDN Desc'(038) ''
                         CHANGING li_fieldcat,

                            USING '15'(051) c_field_sel 'I_FINAL_ITM'(073) ' ' ''
                         CHANGING li_fieldcat,

                            USING '16'(052) 'VKORG'(014) 'I_FINAL_ITM'(073) 'Sales Org'(015) c_check
                         CHANGING li_fieldcat,

                            USING '17'(053) 'VTWEG'(016) 'I_FINAL_ITM'(073) 'Distr. Channel'(017) c_check
                         CHANGING li_fieldcat,

                            USING '18'(054) 'SPART'(018) 'I_FINAL_ITM'(073) 'Division'(019) c_check
                         CHANGING li_fieldcat,

                            USING '19'(055) 'AUART'(020) 'I_FINAL_ITM'(073) 'Sales Doc Type'(021) c_check
                         CHANGING li_fieldcat,

                            USING '20'(056) 'VBELN'(074) 'I_FINAL_ITM'(073) 'Sales Doc Number'(075) c_check
                         CHANGING li_fieldcat,

                            USING '21'(057) 'KUNAG'(023) 'I_FINAL_ITM'(073) 'Sold-to Party Number'(024) c_check
                         CHANGING li_fieldcat,

                            USING '22'(058) 'NAME1_AG'(025) 'I_FINAL_ITM'(073) 'Sold-to Party Name'(026) c_check
                         CHANGING li_fieldcat,

                            USING '23'(061) 'POSNR'(076) 'I_FINAL_ITM'(073) 'Item Number'(077) ''
                         CHANGING li_fieldcat,

                            USING '24'(062) 'MATNR'(078) 'I_FINAL_ITM'(073) 'Material Number'(079) ''
                         CHANGING li_fieldcat,

                            USING '25'(063) 'MAKTX'(080) 'I_FINAL_ITM'(073) 'Material Description'(081) ''
                         CHANGING li_fieldcat,

                            USING '26'(064) 'WERKS'(082) 'I_FINAL_ITM'(073) 'Delivering Plant'(083) ''
                         CHANGING li_fieldcat,

                            USING '27'(059) 'KUNNR'(027) 'I_FINAL_ITM'(073) 'Ship-to Party Number'(028) ''
                         CHANGING li_fieldcat,

                            USING '28'(060) 'NAME1_WE'(029) 'I_FINAL_ITM'(073) 'Ship-to Party Name'(030) ''
                         CHANGING li_fieldcat,

                            USING '29'(065) 'PRSDT'(084) 'I_FINAL_ITM'(073) 'Pricing Date'(085) c_check
                         CHANGING li_fieldcat,

                            USING '30'(066) 'EDATU'(086) 'I_FINAL_ITM'(073) 'Req Del Date'(087) ''
                         CHANGING li_fieldcat,

                            USING '31'(067) 'MEINS'(088) 'I_FINAL_ITM'(073) 'UoM'(089) c_check
                         CHANGING li_fieldcat,

                            USING '32'(068) 'KWMENG'(090) 'I_FINAL_ITM'(073) 'Order Quantity'(091) ''
                         CHANGING li_fieldcat,

                            USING '33'(069) 'KVGR1'(031) 'I_FINAL_ITM'(073) 'Buying Group Code'(032) c_check
                         CHANGING li_fieldcat,

                            USING '34'(070) 'BEZEI_1'(033) 'I_FINAL_ITM'(073) 'Buying Group Desc'(034) c_check
                         CHANGING li_fieldcat,

                            USING '35'(071) 'KVGR2'(035) 'I_FINAL_ITM'(073) 'IDN Code'(036) c_check
                         CHANGING li_fieldcat,

                            USING '36'(072) 'BEZEI_2'(037) 'I_FINAL_ITM'(073) 'IDN Desc'(038) c_check
                         CHANGING li_fieldcat.

*&--Build ALV Layout
  PERFORM f_build_layout CHANGING lx_layout.

*&--Build the keyinfo structure for ALV Hierarchical ALV
  PERFORM f_build_keyinfo CHANGING lx_keyinfo.

*&--Build event table
  PERFORM f_build_event CHANGING li_event.

*&--Display ALV
  PERFORM f_display_alv USING li_fieldcat
                              fp_i_final_hdr
                              fp_i_final_itm
                              lx_layout
                              lx_keyinfo
                              li_event.



ENDFORM. " F_BUILD_HIER_ALV
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       Build the field catalog table
*----------------------------------------------------------------------*
*      -->fp_col            Column number
*      -->fp_fieldname      Field name
*      -->fp_tabname        Table name
*      -->fp_seltext        Header text
*      -->fp_no_out         No output display indicator
*      <--fp_i_fieldcat     Field catalog
*----------------------------------------------------------------------*
FORM f_build_fieldcat USING fp_col          TYPE char2     " Build_fieldcat using fp of type CHAR2
                            fp_fieldname    TYPE slis_fieldname
                            fp_tabname      TYPE slis_tabname
                            fp_seltext      TYPE scrtext_l " Long Field Label
                            fp_no_out       TYPE char1     " No_out of type CHAR1
                   CHANGING fp_i_fieldcat   TYPE slis_t_fieldcat_alv.

  DATA:
    lwa_fieldcat TYPE slis_fieldcat_alv. " Field catalog structure

*&--Fill the column position
  lwa_fieldcat-col_pos    = fp_col.
*&--Fill the internal table field name
  lwa_fieldcat-fieldname  = fp_fieldname.
*&--Fill the internal table name
  lwa_fieldcat-tabname    = fp_tabname.
*&--Fill the selection text
  lwa_fieldcat-seltext_l  = fp_seltext.
*&--Mark if not to be displayed
  lwa_fieldcat-no_out     = fp_no_out.

  IF fp_fieldname = c_field_sel.
    lwa_fieldcat-edit = c_check.
    lwa_fieldcat-checkbox = c_check.
    lwa_fieldcat-hotspot = c_check.
    lwa_fieldcat-icon = c_check.
  ENDIF. " IF fp_fieldname = c_field_sel

*&--Append Field Catalog Table
  APPEND lwa_fieldcat TO fp_i_fieldcat.

ENDFORM. "f_build_fieldcat
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
*       Build ALV Layout
*----------------------------------------------------------------------*
*      <--FP_X_LAYOUT  Layout Workarea
*----------------------------------------------------------------------*
FORM f_build_layout CHANGING fp_x_layout TYPE slis_layout_alv.

*&--Populate 'X' to Optimize Coloum Width
  fp_x_layout-colwidth_optimize = c_check.
*&--Populate the expand field name of the hierarchical structure
  fp_x_layout-expand_fieldname = 'EXPAND'(092).

ENDFORM. " F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_KEYINFO
*&---------------------------------------------------------------------*
*       Build key infor structure for Hierarchical ALV
*----------------------------------------------------------------------*
*      <--FP_X_KEYINFO  Key infor structure
*----------------------------------------------------------------------*
FORM f_build_keyinfo CHANGING fp_x_keyinfo TYPE slis_keyinfo_alv.

  fp_x_keyinfo-header01 = 'VKORG'(014).
  fp_x_keyinfo-item01   = 'VKORG'(014).
  fp_x_keyinfo-header02 = 'VTWEG'(016).
  fp_x_keyinfo-item02   = 'VTWEG'(016).
  fp_x_keyinfo-header03 = 'SPART'(018).
  fp_x_keyinfo-item03   = 'SPART'(018).
  fp_x_keyinfo-header04 = 'AUART'(020).
  fp_x_keyinfo-item04   = 'AUART'(020).
  fp_x_keyinfo-header05 = 'VBELN'(074).
  fp_x_keyinfo-item05   = 'VBELN'(074).

ENDFORM. " F_BUILD_KEYINFO
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EVENT
*&---------------------------------------------------------------------*
*       Build Event Table
*----------------------------------------------------------------------*
*      <--FP_I_EVENT  Event Table
*----------------------------------------------------------------------*
FORM f_build_event CHANGING fp_i_event TYPE slis_t_event.

  DATA:
    lwa_event TYPE slis_alv_event. "Event Workarea

*&--Populate TOP-OF-PAGE event details
  lwa_event-name = 'TOP_OF_PAGE'(093).
  lwa_event-form = 'F_TOP_OF_PAGE'(094).

  APPEND lwa_event TO fp_i_event.

ENDFORM. " F_BUILD_EVENT
*&---------------------------------------------------------------------*
*&      Form  f_user_command
*&---------------------------------------------------------------------*
*       Exit routines for command handling
*----------------------------------------------------------------------*
*      -->fp_comm      User command
*      -->fp_selfield  Row details
*----------------------------------------------------------------------*
FORM f_user_command USING fp_comm     TYPE syucomm " Function code that PAI triggered
                          fp_selfield TYPE slis_selfield.

  DATA:
    lv_index TYPE sytabix, "Index Variable
    lv_ans   TYPE char1.   "Ans variable

  FIELD-SYMBOLS:
    <lfs_final_hdr> TYPE ty_final_hdr, "Final Header Data
    <lfs_final_itm> TYPE ty_final.     "Final Item Data


*&--Check Function Key and correspondigly taking action
  CASE fp_comm.
    WHEN c_chkd. "Checkbox Checked/Unchecked

*&--Check if Header line Checkbox is checked
      IF fp_selfield-tabname = 'I_FINAL_HDR'(012).
*&--Read Final Header data
        READ TABLE i_final_hdr ASSIGNING <lfs_final_hdr>
                               INDEX fp_selfield-tabindex.
        IF sy-subrc EQ 0 AND <lfs_final_hdr> IS ASSIGNED.
*&--Mark/Unmark if Header line checkbox is Unmarked/Marked
          IF <lfs_final_hdr>-sel IS NOT INITIAL.
*&--Unmark Header line Checkbox
            <lfs_final_hdr>-sel = space.
          ELSE. " ELSE -> IF <lfs_final_hdr>-sel IS NOT INITIAL
*&--Mark Header line Checkbox
            <lfs_final_hdr>-sel = c_check.
          ENDIF. " IF <lfs_final_hdr>-sel IS NOT INITIAL

*&--Read Final Item data corresponding to Final Header data
          READ TABLE i_final_itm
            ASSIGNING <lfs_final_itm>
            WITH KEY vkorg = <lfs_final_hdr>-vkorg
                     vtweg = <lfs_final_hdr>-vtweg
                     spart = <lfs_final_hdr>-spart
                     auart = <lfs_final_hdr>-auart
                     vbeln = <lfs_final_hdr>-vbeln
            BINARY SEARCH.
          IF sy-subrc EQ 0 AND <lfs_final_itm> IS ASSIGNED.
            lv_index = sy-tabix.

*&--Process on each Item line records corresponding to Header line record
*&--and Mark/Unmark their checkboxes if Header line Checkbox is Marked/Umarked
            LOOP AT i_final_itm ASSIGNING <lfs_final_itm> FROM lv_index.
              IF <lfs_final_hdr>-vkorg NE <lfs_final_itm>-vkorg OR
                 <lfs_final_hdr>-vtweg NE <lfs_final_itm>-vtweg OR
                 <lfs_final_hdr>-spart NE <lfs_final_itm>-spart OR
                 <lfs_final_hdr>-auart NE <lfs_final_itm>-auart OR
                 <lfs_final_hdr>-vbeln NE <lfs_final_itm>-vbeln .
                EXIT.
              ENDIF. " IF <lfs_final_hdr>-vkorg NE <lfs_final_itm>-vkorg OR
*&--Mark Item line Checkbox
              <lfs_final_itm>-sel = <lfs_final_hdr>-sel.
            ENDLOOP. " LOOP AT i_final_itm ASSIGNING <lfs_final_itm> FROM lv_index
          ENDIF. " IF sy-subrc EQ 0 AND <lfs_final_itm> IS ASSIGNED
        ENDIF. " IF sy-subrc EQ 0 AND <lfs_final_hdr> IS ASSIGNED
      ENDIF. " IF fp_selfield-tabname = 'I_FINAL_HDR'(012)

*&--Check if Item line Checkbox is checked
      IF fp_selfield-tabname = 'I_FINAL_ITM'.
*&--Read Final Item Line data
        READ TABLE i_final_itm ASSIGNING <lfs_final_itm>
                               INDEX fp_selfield-tabindex.
        IF sy-subrc EQ 0 AND <lfs_final_itm> IS ASSIGNED.
*&--Mark/Unmark Item line if its Checkbox is Unmarked/Marked
          IF <lfs_final_itm>-sel IS NOT INITIAL.
*&--Unmark Item line Checkbox
            <lfs_final_itm>-sel = space.
*&--Read Final Header line corresponding to Item line and Unmark its Checkbox
            READ TABLE i_final_hdr ASSIGNING <lfs_final_hdr>
                                   WITH KEY vkorg = <lfs_final_itm>-vkorg
                                            vtweg = <lfs_final_itm>-vtweg
                                            spart = <lfs_final_itm>-spart
                                            auart = <lfs_final_itm>-auart
                                            vbeln = <lfs_final_itm>-vbeln
                                   BINARY SEARCH.
            IF sy-subrc EQ 0 AND <lfs_final_hdr> IS ASSIGNED.
*&--Unmarking Header Line Checkbox
              <lfs_final_hdr>-sel = space.
            ENDIF. " IF sy-subrc EQ 0 AND <lfs_final_hdr> IS ASSIGNED

          ELSE. " ELSE -> IF <lfs_final_itm>-sel IS NOT INITIAL
*&--Marking Header Line Checkbox
            <lfs_final_itm>-sel = c_check.
          ENDIF. " IF <lfs_final_itm>-sel IS NOT INITIAL
        ENDIF. " IF sy-subrc EQ 0 AND <lfs_final_itm> IS ASSIGNED
      ENDIF. " IF fp_selfield-tabname = 'I_FINAL_ITM'

    WHEN c_sall. "Select All Button Pressed

*&--Process on each Final Header line and mark their Checkboxes
      LOOP AT i_final_hdr ASSIGNING <lfs_final_hdr>.
        <lfs_final_hdr>-sel = c_check.
      ENDLOOP. " LOOP AT i_final_hdr ASSIGNING <lfs_final_hdr>

*&--Process on each Final Item line and mark their Checkboxes
      LOOP AT i_final_itm ASSIGNING <lfs_final_itm>.
        <lfs_final_itm>-sel = c_check.
      ENDLOOP. " LOOP AT i_final_itm ASSIGNING <lfs_final_itm>

    WHEN c_dall. "Deselect All Button Pressed

*&--Process on each Final Header line and unmark their Checkboxes
      LOOP AT i_final_hdr ASSIGNING <lfs_final_hdr>.
        <lfs_final_hdr>-sel = space.
      ENDLOOP. " LOOP AT i_final_hdr ASSIGNING <lfs_final_hdr>

*&--Process on each Final Item line and unmark their Checkboxes
      LOOP AT i_final_itm ASSIGNING <lfs_final_itm>.
        <lfs_final_itm>-sel = space.
      ENDLOOP. " LOOP AT i_final_itm ASSIGNING <lfs_final_itm>

    WHEN c_updt. "Update Button Pressed

*&--Check if any Item line is selected or not; if not selected
*&--then display an information message 'No Item Line Selected'
*&--and return to Hierarchical ALV output
      READ TABLE i_final_itm TRANSPORTING NO FIELDS
                             WITH KEY sel = c_check.
      IF sy-subrc NE 0.
        MESSAGE i901.
      ELSE. " ELSE -> IF sy-subrc NE 0
*&--If line items are selected then pop a message to confirm
*&--of Updating Pricing Date
        PERFORM f_pop_up_to_confirm CHANGING lv_ans.

*&--Check If Ans is Yes '1' or No '2'; If Ans is no then return to ALV
        IF lv_ans EQ c_ans_1.
*&--If Ans is Yes; Update Pricing Date for the selected line items and
*&--then leave program
          PERFORM f_update_item_price_date USING i_final_itm.

*&--BOC: DEF#649 : RVERMA : 05-Aug-14
*          LEAVE PROGRAM.
          LEAVE TO SCREEN 0.
*&--EOC: DEF#649 : RVERMA : 05-Aug-14
        ENDIF. " IF lv_ans EQ c_ans_1
      ENDIF. " IF sy-subrc NE 0

  ENDCASE.

*&--Assign Refresh = 'X'
  fp_selfield-refresh = c_check.

*&--Assign Row Stable = 'X'
  fp_selfield-row_stable = c_check.

ENDFORM. "f_user_command
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*       Display ALV
*----------------------------------------------------------------------*
*      -->FP_I_FIELDCAT   Field Catalog table
*      -->FP_I_FINAL_HDR  Final Header table
*      -->FP_I_FINAL_ITM  Final Item table
*      -->FP_X_LAYOUT     Layout Structre
*      -->FP_X_KEYINFO    Keyinfo Structre
*      -->FP_I_EVENT      Event table
*----------------------------------------------------------------------*
FORM f_display_alv USING fp_i_fieldcat  TYPE slis_t_fieldcat_alv
                         fp_i_final_hdr TYPE ty_t_final_hdr
                         fp_i_final_itm TYPE ty_t_final
                         fp_x_layout    TYPE slis_layout_alv
                         fp_x_keyinfo   TYPE slis_keyinfo_alv
                         fp_i_event     TYPE slis_t_event.

*&--Call the Hierarchical ALV function module
  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'(095)
      i_callback_user_command  = 'F_USER_COMMAND'(096)
      is_layout                = fp_x_layout
      it_fieldcat              = fp_i_fieldcat
      it_events                = fp_i_event
      i_tabname_header         = 'I_FINAL_HDR'(012)
      i_tabname_item           = 'I_FINAL_ITM'(073)
      is_keyinfo               = fp_x_keyinfo
    TABLES
      t_outtab_header          = fp_i_final_hdr
      t_outtab_item            = fp_i_final_itm
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE i161(25). " Error occurred in list processing (ALV)
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc <> 0

ENDFORM. " F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*&      Form  F_SET_PF_STATUS
*&---------------------------------------------------------------------*
*       Set the PF status
*----------------------------------------------------------------------*
*      -->fp_i_extab Internal table containing the Function code
*----------------------------------------------------------------------*
FORM f_set_pf_status USING fp_i_extab TYPE slis_t_extab.

*&--Set PF Status
  SET PF-STATUS c_gui_status.

ENDFORM. "F_SET_PF_STATUS
*&---------------------------------------------------------------------*
*&      Form  f_top_of_page
*&---------------------------------------------------------------------*
*       Top of Page
*----------------------------------------------------------------------*
FORM f_top_of_page.

  DATA: lwa_header   TYPE slis_listheader,   "List header
        li_header    TYPE slis_t_listheader, "Header table
        lv_date      TYPE char10,            "Date
        lv_time      TYPE char8,             "Time
        lv_lines     TYPE i.                 "Lines


  lwa_header-typ = c_type.
  lwa_header-key = 'Report Title'(097).
  lwa_header-info = sy-title.
  APPEND lwa_header TO li_header.
  CLEAR lwa_header.

  lwa_header-typ = c_type.
  lwa_header-key = 'Printed on'(098).
  WRITE sy-datum TO lv_date.
  WRITE sy-uzeit TO lv_time.
  CONCATENATE lv_date
              lv_time
    INTO lwa_header-info
    SEPARATED BY space.
  APPEND lwa_header TO li_header.
  CLEAR: lwa_header,
         lv_time,
         lv_date.

  lwa_header-typ = c_type.
  lwa_header-key = 'Requestor'(099).
  lwa_header-info = sy-uname.
  APPEND lwa_header TO li_header.
  CLEAR lwa_header.

  DESCRIBE TABLE i_final_hdr LINES lv_lines.
  lwa_header-typ = c_type.
  lwa_header-key = 'Records (Header)'(100).
  MOVE lv_lines TO lwa_header-info.
  CONDENSE lwa_header-info.
  APPEND lwa_header TO li_header.
  CLEAR lwa_header.
  CLEAR lv_lines.

  DESCRIBE TABLE i_final_itm LINES lv_lines.
  lwa_header-typ = c_type.
  lwa_header-key = 'Records (Item)'(101).
  MOVE lv_lines TO lwa_header-info.
  CONDENSE lwa_header-info.
  APPEND lwa_header TO li_header.
  CLEAR lwa_header.
  CLEAR lv_lines.

*&--Call the function module to write the header infomation
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = li_header.

ENDFORM. "f_top_of_page
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_ITEM_PRICE_DATE
*&---------------------------------------------------------------------*
*       Update Pricing date with First Delivery date in the selected
*       line items
*----------------------------------------------------------------------*
*      -->FP_I_FINAL_ITM  Final Item table
*----------------------------------------------------------------------*
FORM f_update_item_price_date USING fp_i_final_itm TYPE ty_t_final.


  DATA:
    li_data        TYPE rsparams_tt, "Selection Param Table
    lwa_data       TYPE rsparams,    "Selection Param Workarea
    lv_jobname     TYPE btcjob,      "Job Name
    lv_jobcount    TYPE btcjobcnt,   "Job Count
    lv_jobrel      TYPE btcchar1,    "Job Released
    lv_start_date  TYPE btcsdate,    "Start Date
    lv_start_time  TYPE btcstime,    "Start Time.

*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-08-2017
*&--Local Work Area and variables.
    lv_date_prc  TYPE datum,         " Schedule line date
    lwa_days     TYPE psen_duration, " Duration in Years, Months, and Days
*--> Begin of insert D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
    lwa_lips  TYPE ty_lips,
    lwa_likp  TYPE ty_likp.
*<-- End of insert D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018

*&--Local Constants
  CONSTANTS: lc_operator TYPE adsub VALUE '-',                     " Processing indicator
             lc_jobname  TYPE btcjob VALUE 'ZOTC_UPDT_PRICE_DATE', "Job Name
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-08-2017
*--> Begin of insert D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
             lc_rb_d3    TYPE char2  VALUE 'D3'. "Local constant for D3
*<-- End of insert D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
  FIELD-SYMBOLS:
    <lfs_final_itm> TYPE ty_final. "Final Table data

*&--Processing on Selected Line items
  LOOP AT fp_i_final_itm ASSIGNING <lfs_final_itm>.
    IF <lfs_final_itm>-sel IS NOT INITIAL.
*&--Building Selection Parameters Table
      lwa_data-selname = c_selname.
      lwa_data-kind    = c_kind_s.
      lwa_data-sign    = c_sign_i.
      lwa_data-option  = c_option_eq.
*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*&--When we are updating the pricing date, pricing date should be eq to req.delivery.date according to the requirement.
*&--So we are subtracting 1 day from the req.delivery.date.
* Subtract days to dates
      CLEAR: lwa_days,
             lv_date_prc.
*--> Begin of insert D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
      IF rb_d3 IS INITIAL.
*<-- End of insert D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018

        lwa_days-duryy = 0.
        lwa_days-durmm = 0.
        lwa_days-durdd = gv_days.
*&-- ADD/SUB days from date
        CALL FUNCTION 'HR_99S_DATE_ADD_SUB_DURATION'
          EXPORTING
            im_date     = <lfs_final_itm>-edatu
            im_operator = lc_operator
            im_duration = lwa_days
          IMPORTING
            ex_date     = lv_date_prc.
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

*--> Begin of insert D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
            "Taking the Delivery creation date from LIKP
      ELSE. " ELSE -> IF rb_d3 IS INITIAL
        READ TABLE i_lips INTO lwa_lips WITH KEY vgbel = <lfs_final_itm>-vbeln
                                                 vgpos = <lfs_final_itm>-posnr
                                                 BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          READ TABLE i_likp INTO lwa_likp WITH KEY vbeln = lwa_lips-vbeln
                                                   BINARY SEARCH.
          IF sy-subrc IS INITIAL.
*--> Begin of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*           lv_date_prc = lwa_likp-erdat.
*<-- End of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
 "Now we will replace Pricing date with Actual PGI date
            lv_date_prc = lwa_likp-wadat_ist.
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
          ENDIF. " IF sy-subrc IS INITIAL
        ENDIF. " IF sy-subrc IS INITIAL

      ENDIF. " IF rb_d3 IS INITIAL
*<-- End of insert D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018

      CONCATENATE <lfs_final_itm>-vbeln
                  <lfs_final_itm>-posnr
                  <lfs_final_itm>-prsdt
*&-->Begin of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*                  <lfs_final_itm>-edatu
*&<--End of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
                   lv_date_prc
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
        INTO lwa_data-low
        SEPARATED BY c_hash.
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
      IF rb_d3 IS NOT INITIAL.
        lwa_data-high = lc_rb_d3.
      ENDIF. " IF rb_d3 IS NOT INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018

      APPEND lwa_data TO li_data.
      CLEAR lwa_data.
    ENDIF. " IF <lfs_final_itm>-sel IS NOT INITIAL
  ENDLOOP. " LOOP AT fp_i_final_itm ASSIGNING <lfs_final_itm>

  MOVE sy-tcode TO lv_jobname.
*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*&--Since in background sy-tcode value is blank, so we are hardcoding the job name and passing it.
  IF lv_jobname IS INITIAL.
    lv_jobname = lc_jobname.
  ENDIF. " IF lv_jobname IS INITIAL
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
  lv_start_date = sy-datum.
  lv_start_time = sy-uzeit + 2.

*&--Call FM to Open Background Job
  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname          = lv_jobname
      sdlstrtdt        = lv_start_date
      sdlstrttm        = lv_start_time
    IMPORTING
      jobcount         = lv_jobcount
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 4.

  IF sy-subrc EQ 0.

*&--Submit Report to Update Selected Line Item's Pricing Date
    SUBMIT zotcr0101b_price_date_upd
      WITH SELECTION-TABLE li_data
      USER sy-uname
      VIA JOB lv_jobname NUMBER lv_jobcount
      AND RETURN.

*&--Call FM to Close Background Job
    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        jobcount             = lv_jobcount
        jobname              = lv_jobname
        sdlstrtdt            = lv_start_date
        sdlstrttm            = lv_start_time
      IMPORTING
        job_was_released     = lv_jobrel
      EXCEPTIONS
        cant_start_immediate = 1
        invalid_startdate    = 2
        jobname_missing      = 3
        job_close_failed     = 4
        job_nosteps          = 5
        job_notex            = 6
        lock_failed          = 7
        invalid_target       = 8
        OTHERS               = 9.
    IF sy-subrc <> 0.
      CLEAR lv_jobrel.
*&--BOC: DEF#649 : RVERMA : 05-Aug-14
    ELSE. " ELSE -> IF sy-subrc <> 0
      MESSAGE i903.
*&--EOC: DEF#649 : RVERMA : 05-Aug-14
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF sy-subrc EQ 0

ENDFORM. " F_UPDATE_ITEM_PRICE_DATE
*&---------------------------------------------------------------------*
*&      Form  F_POP_UP_TO_CONFIRM
*&---------------------------------------------------------------------*
*       Pop up to confirm
*----------------------------------------------------------------------*
*      <--FP_ANS    Answer Yes = '1', No = '2'
*----------------------------------------------------------------------*
FORM f_pop_up_to_confirm CHANGING fp_ans TYPE char1. " Pop_up_to_confirm chang of type CHAR1

  DATA:
    lv_ques TYPE string. "Question

  lv_ques = 'Do you want to update Pricing Date for the selected Line Items ?'(107).

*CAll function for POP up
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Confirm!!'(108)
      text_question         = lv_ques
      text_button_1         = 'Yes'(103)
      icon_button_1         = 'ICON_OKAY'(104)
      text_button_2         = 'No'(105)
      icon_button_2         = 'ICON_CANCEL'(106)
      display_cancel_button = ''
    IMPORTING
      answer                = fp_ans
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

  IF sy-subrc NE 0.
    fp_ans = c_ans_2.
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_POP_UP_TO_CONFIRM

*&--BOC for MOD-002

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_MANDATORY_FIELDS
*&---------------------------------------------------------------------*
*       Subroutine to validate mandatory fields
*----------------------------------------------------------------------*

FORM f_check_mandatory_fields.

*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
 "Checking the Mandatory fields for both D2 and D3 radio button
  PERFORM f_check_mandatory_fields_d3.

  IF rb_d2 IS NOT INITIAL.
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018

**&--Check of Sales Order or Sold-to Party Number or Customer Group1
**&--or Customer Group2 is not entered than display an error message
*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*&--In Background mode, this fields will be non-mandatory.
    IF sy-batch = abap_false.
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
      IF s_kunag[] IS INITIAL AND
         s_kvgr1[] IS INITIAL AND
         s_kvgr2[] IS INITIAL AND
         s_vbeln[] IS INITIAL. "MOD 3 (By SNIGAM on 22-Apr-2014)


        SET CURSOR FIELD 'S_KUNAG-LOW'.

        MESSAGE i000 DISPLAY LIKE 'E'
        WITH
               'Enter Sales Order or Sold-to Party Number or'(109)
               'Customer Group1 or Customer Group2.'(110) .

*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
        LEAVE LIST-PROCESSING.
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

      ENDIF. " IF s_kunag[] IS INITIAL AND

*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
    ELSE. " ELSE -> IF sy-batch = abap_false
      IF s_deldat[] IS INITIAL.

        MESSAGE e000 WITH 'Enter Requested Delivery date'(113).

      ENDIF. " IF s_deldat[] IS INITIAL
    ENDIF. " IF sy-batch = abap_false
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
  ENDIF. " IF rb_d2 IS NOT INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018

ENDFORM. " F_CHECK_MANDATORY_FIELDS

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION_KVGR1
*&---------------------------------------------------------------------*
*       Subroutine to validate Customer Group1
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_validation_kvgr1.

  DATA:
    lv_kvgr1 TYPE kvgr1. "Customer Group1

  SELECT kvgr1 " Customer group 1
    UP TO 1 ROWS
    FROM tvv1  " Customer Group 1
    INTO lv_kvgr1
    WHERE kvgr1 IN s_kvgr1.
  ENDSELECT.

  IF sy-subrc NE 0.
    MESSAGE e128
      WITH 'Customer Group1'(111).
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_VALIDATION_KVGR1
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION_KVGR2
*&---------------------------------------------------------------------*
*       Subroutine to validate Customer Group2
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_validation_kvgr2.

  DATA:
      lv_kvgr2 TYPE kvgr2. "Customer Group1

  SELECT kvgr2 " Customer group 2
    UP TO 1 ROWS
    FROM tvv2  " Customer Group 2
    INTO lv_kvgr2
    WHERE kvgr2 IN s_kvgr2.
  ENDSELECT.

  IF sy-subrc NE 0.
    MESSAGE e128
      WITH 'Customer Group2'(112).
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_VALIDATION_KVGR2
*&--EOC for MOD-002

*&--BOC : HPQC Defect # 649 : User ID - RVERMA : Date - 09-Apr-2014
*&---------------------------------------------------------------------*
*&      Form  F_GET_CUST_SO_DATA
*&---------------------------------------------------------------------*
*       Subroutine to get Customer Master Sales Data Table
*----------------------------------------------------------------------*
*      <--FP_I_KNVV  Customer Master Sales Data Table
*----------------------------------------------------------------------*
FORM f_get_cust_so_data CHANGING    fp_i_vbak TYPE ty_t_vbak
                                    fp_i_knvv TYPE ty_t_knvv.

*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
  DATA li_vbak TYPE STANDARD TABLE OF ty_vbak INITIAL SIZE 0.
*&--Taking the records in the local internal table
  li_vbak[] = fp_i_vbak[].
  SORT li_vbak BY kunag.
  DELETE ADJACENT DUPLICATES FROM li_vbak COMPARING kunag.
  IF li_vbak IS NOT INITIAL.
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

*&--Fetch Customer Sales Data from KNVV table
    SELECT kunnr " Customer Number
           vkorg " Sales Organization
           vtweg " Distribution Channel
           spart " Division
*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
           loevm "Deletion flag for customer (sales level)
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
           kvgr1 " Customer group 1
           kvgr2 " Customer group 2
      FROM knvv  " Customer Master Sales Data
      INTO TABLE fp_i_knvv
*&-->Begin of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*        WHERE kunnr IN s_kunag
*          AND vkorg IN s_vkorg
*          AND vtweg IN s_vtweg
*          AND spart IN s_spart.
*          AND loevm EQ space
*         AND kvgr1 IN s_kvgr1
*         AND kvgr2 IN s_kvgr2.
*&<--End of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
       FOR ALL ENTRIES IN li_vbak
       WHERE kunnr = li_vbak-kunag
        AND vkorg = li_vbak-vkorg
        AND vtweg = li_vbak-vtweg
        AND spart = li_vbak-spart.
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

    IF sy-subrc EQ 0.
*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
      DELETE fp_i_knvv WHERE loevm NE space.
      IF s_kvgr1[] IS NOT INITIAL.
        DELETE fp_i_knvv WHERE kvgr1 NOT IN s_kvgr1.
      ENDIF. " IF s_kvgr1[] IS NOT INITIAL
      IF s_kvgr2[] IS NOT INITIAL.
        DELETE fp_i_knvv WHERE kvgr2 NOT IN s_kvgr2.
      ENDIF. " IF s_kvgr2[] IS NOT INITIAL
      IF fp_i_knvv IS NOT INITIAL.
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

        SORT fp_i_knvv BY kunnr vkorg
                           vtweg spart.

*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
      ENDIF. " IF fp_i_knvv IS NOT INITIAL
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

    ELSE. " ELSE -> IF sy-subrc EQ 0
      MESSAGE i902.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF sy-subrc EQ 0
*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
  ENDIF. " IF li_vbak IS NOT INITIAL
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
ENDFORM. " F_GET_CUST_SO_DATA
*&--EOC : HPQC Defect # 649 : User ID - RVERMA : Date - 09-Apr-2014

*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*&---------------------------------------------------------------------*
*&      Form  F_FETCH_EMI_ENTRIES
*&---------------------------------------------------------------------*
*       To fetch EMI entries.
*----------------------------------------------------------------------*

FORM f_fetch_emi_entries .

  DATA: li_zdev_emi TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Local internal Table
        lwa_emi TYPE zdev_enh_status.                                      " Enhancement Status
*&-->Begin of delete for FUT changes D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 23-OCT-2017
*        lv_date  TYPE datum,                                               " Schedule line date
*        lv_emi_date TYPE datum,                                            " Date
*        lwa_days TYPE psen_duration.                                       " Duration in Years, Months, and Days
*&<--End of delete for FUT changes D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 23-OCT-2017

  CONSTANTS: lc_days        TYPE z_criteria    VALUE 'DAYS', " Enh. Criteria
             lc_operator    TYPE adsub VALUE '+'.            " Processing indicator
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 13-Dec-2018
                                                                         "Data declaration for POD status
  DATA: li_emi    TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Enhancement Status
        lwa_pdsta TYPE fkk_ranges.                                       " Structure: Select Options

  CONSTANTS: lc_pdsta TYPE z_criteria VALUE 'PDSTA'. " Enh. Criteria
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 13-Dec-2018


*&--Call to fetch EMI entries
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = c_enhancement
    TABLES
      tt_enh_status     = li_zdev_emi.

  DELETE li_zdev_emi WHERE active <> abap_true.
  IF li_zdev_emi IS NOT INITIAL.
*--> Begin of delete D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 25-Oct-2018
*--> Begin of insert D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
    "User don't want EMI entries to be maintained
*    i_zdev_emi[] = li_zdev_emi[].
*<-- End of insert D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 25-Oct-2018
*<-- End of delete D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
    SORT li_zdev_emi BY criteria.

    READ TABLE li_zdev_emi INTO lwa_emi WITH KEY criteria = lc_days
                                        BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      gv_days = lwa_emi-sel_low.
    ENDIF. " IF sy-subrc IS INITIAL

*&-->Begin of delete for FUT changes D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 23-OCT-2017
*&--System updating the EMI entry with the date is not a feasible solution as confirmed by the functional,
*&-- so we are removing the EMI logic for updating selection field date.
*    READ TABLE li_zdev_emi INTO lwa_emi WITH KEY criteria = c_date
*                                        BINARY SEARCH.
*    IF sy-subrc IS INITIAL.
*
*      s_deldat-low = lwa_emi-sel_high.
*&--The low value of the field will contain the date fetched from EMI
* and the high value will store +1 day extra according to the requirement.
* Add days to dates
*      CLEAR: lwa_days,
*             lv_date.
*
*      lwa_days-duryy = 0.
*      lwa_days-durmm = 0.
*      lwa_days-durdd = gv_days.
*
*
*     lv_emi_date = lwa_emi-sel_high.
**&-- ADD/SUB days from date
*      CALL FUNCTION 'HR_99S_DATE_ADD_SUB_DURATION'
*        EXPORTING
*          im_date     = lv_emi_date
*          im_operator = lc_operator
*          im_duration = lwa_days
*        IMPORTING
*          ex_date     = lv_date.
*
*      s_deldat-high = lv_date.
*
*      APPEND s_deldat.
*    ENDIF. " IF sy-subrc IS INITIAL
*&<--End of delete for FUT changes D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 23-OCT-2017

*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 13-Dec-2018
 "Populating the range table for POD status
      CLEAR lwa_emi.
      li_emi[] = li_zdev_emi[].
      DELETE li_emi WHERE criteria NE lc_pdsta.
      IF li_emi IS NOT INITIAL.
        LOOP AT li_emi INTO lwa_emi.
          lwa_pdsta-sign   = c_sign.
          lwa_pdsta-option = c_eq.
          lwa_pdsta-low    = lwa_emi-sel_low.
          lwa_pdsta-high   = lwa_emi-sel_high.
          APPEND lwa_pdsta TO i_pdsta.
          CLEAR: lwa_pdsta,
                 lwa_emi.
        ENDLOOP. " LOOP AT li_emi INTO lwa_emi
        FREE li_emi[].
      ENDIF. " IF li_emi IS NOT INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 13-Dec-2018

  ENDIF. " IF li_zdev_emi IS NOT INITIAL

ENDFORM. " F_FETCH_EMI_ENTRIES
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

*--> Begin of delete D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
"User don't want EMI entries for the sales organization, so no need of any validation from the selection
"screen input field
*--> Begin of insert D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
*&---------------------------------------------------------------------*
*&      Form  F_GET_ENTRIES_EMI
*&---------------------------------------------------------------------*
*       Getting EMI entries
*   -->FP_I_EMI    Internal table for EMI entry
*   <--FP_S_VKORG1 Select Option for sales Organization
*----------------------------------------------------------------------*
*FORM f_get_entries_emi USING    fp_i_emi       TYPE ty_t_status
*                       CHANGING fp_s_vkorg1    TYPE ty_t_vkorg.
*  DATA: lwa_vkorg    TYPE fkk_ranges,                                  " Structure: Select Options
*        lwa_emi      TYPE zdev_enh_status,                             " Enhancement Status
*        lwa_orga     TYPE fkk_ranges,                                  "Local work area
*        li_vkorg     TYPE STANDARD TABLE OF fkk_ranges INITIAL SIZE 0, "Range table for Slaes Organization
*        li_vkorg_emi TYPE STANDARD TABLE OF fkk_ranges INITIAL SIZE 0. "Range table for Slaes Organization from EMI
*  CONSTANTS:lc_orga        TYPE z_criteria    VALUE 'VKORG'. " Enh. Criteria
* "Taking the Sales organization maintained in the EMI entries into one range table
*  SORT fp_i_emi BY sel_low.
*
*  LOOP AT fp_s_vkorg1 INTO lwa_vkorg.
*    READ TABLE fp_i_emi INTO lwa_emi WITH KEY sel_low = lwa_vkorg-low
*                                                   BINARY SEARCH.
*    IF sy-subrc IS INITIAL.
*      lwa_orga-sign   = lwa_vkorg-sign.
*      lwa_orga-option = lwa_vkorg-option.
*      lwa_orga-low    = lwa_vkorg-low.
*      APPEND lwa_orga TO li_vkorg.
*      CLEAR lwa_orga.
*    ENDIF. " IF sy-subrc IS INITIAL
*    CLEAR: lwa_emi,
*           lwa_vkorg.
*  ENDLOOP. " LOOP AT fp_s_vkorg1 INTO lwa_vkorg
*
*  IF li_vkorg IS NOT INITIAL.
*    CLEAR s_vkorg1[].
*    s_vkorg1[] = li_vkorg[].
*  ELSE. " ELSE -> IF li_vkorg IS NOT INITIAL
*    MESSAGE i000 WITH 'Please enter D3 sales organization from EMI entries'(117).
*    LEAVE LIST-PROCESSING.
*  ENDIF. " IF li_vkorg IS NOT INITIAL
*ENDFORM. " F_GET_ENTRIES_EMI
*<-- End of delete D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018

*&---------------------------------------------------------------------*
*&      Form  F_SEL_MODIFY
*&---------------------------------------------------------------------*
*      Modifying the selection screen as per radio button selected
*----------------------------------------------------------------------*
FORM f_sel_modify .
                                             "Local constant declaration
  CONSTANTS: lc_m1 TYPE group1  VALUE  'M1', " M1 of type CHAR2
             lc_m2 TYPE group1  VALUE  'M2', " M2 of type CHAR2
             lc_0  TYPE char1   VALUE  '0',  " 0 of type CHAR1
             lc_1  TYPE char1   VALUE  '1'.  " 1 of type CHAR1
 "Looping the screen to modify according to the Radio Button selected
  LOOP AT SCREEN.
 "If D2 radio button is selected then Fields associated with
 "M1 group should be visible and M2 should be Invisible
    IF rb_d2 IS NOT INITIAL.
      IF screen-group1 = lc_m2.
        screen-input = lc_0.
        screen-invisible = lc_1.
 "Modifying the screen according to Radio button
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = lc_m2
    ELSE. " ELSE -> IF rb_d2 IS NOT INITIAL
      IF screen-group1 = lc_m1.
        screen-input = lc_0.
        screen-invisible = lc_1.
 "Modifying the screen according to Radio button
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = lc_m1
    ENDIF. " IF rb_d2 IS NOT INITIAL
  ENDLOOP. " LOOP AT SCREEN
ENDFORM. " F_SEL_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DEL_TYPE
*&---------------------------------------------------------------------*
*       Validating Delivery type in the selection screen
*----------------------------------------------------------------------*
FORM f_validate_del_type .

  DATA: lv_lfart TYPE lfart. "Sales Order Number

  SELECT lfart " Sales Document
    UP TO 1 ROWS
    FROM tvlk  " Sales Document: Header Data
    INTO lv_lfart
    WHERE lfart IN s_lfart.
  ENDSELECT.

  IF sy-subrc NE 0.
    MESSAGE e128
      WITH 'Delivery Type'(114).
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_VALIDATE_DEL_TYPE

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_MANDATORY_FIELDS_D3
*&---------------------------------------------------------------------*
*       Checking the mandatory fields
*----------------------------------------------------------------------*
FORM f_check_mandatory_fields_d3 .

  IF rb_d2 IS NOT INITIAL.

    IF s_vkorg IS INITIAL.
      MESSAGE i000 WITH 'Please Enter Sales Organization!'(118).
      LEAVE LIST-PROCESSING.
    ENDIF. " IF s_vkorg IS INITIAL
    IF s_vtweg IS INITIAL.
      MESSAGE i000 WITH 'Please Enter Distribution Channel !'(119).
      LEAVE LIST-PROCESSING.
    ENDIF. " IF s_vtweg IS INITIAL
    IF s_spart IS INITIAL.
      MESSAGE i000 WITH 'Please Enter Division!'(120).
      LEAVE LIST-PROCESSING.
    ENDIF. " IF s_spart IS INITIAL
    IF s_auart IS INITIAL.
      MESSAGE i000 WITH 'Please Enter Sales Document Type!'(121).
      LEAVE LIST-PROCESSING.
    ENDIF. " IF s_auart IS INITIAL
  ELSE. " ELSE -> IF rb_d2 IS NOT INITIAL

    IF s_vkorg1 IS INITIAL.
      MESSAGE i000 WITH 'Please Enter Sales Organization!'(118).
      LEAVE LIST-PROCESSING.
    ENDIF. " IF s_vkorg1 IS INITIAL
    IF s_vtweg1 IS INITIAL.
      MESSAGE i000 WITH 'Please Enter Distribution Channel !'(119).
      LEAVE LIST-PROCESSING.
    ENDIF. " IF s_vtweg1 IS INITIAL
    IF s_spart1 IS INITIAL.
      MESSAGE i000 WITH 'Please Enter Division!'(120).
      LEAVE LIST-PROCESSING.
    ENDIF. " IF s_spart1 IS INITIAL
    IF s_auart1 IS INITIAL.
      MESSAGE i000 WITH 'Please Enter Sales Document Type!'(121).
      LEAVE LIST-PROCESSING.
    ENDIF. " IF s_auart1 IS INITIAL
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
    IF s_wadat IS INITIAL.
      MESSAGE i000 WITH 'Please Enter Actual GI Date!'(122).
      LEAVE LIST-PROCESSING.
    ENDIF. " IF s_wadat IS INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018

  ENDIF. " IF rb_d2 IS NOT INITIAL

ENDFORM. " F_CHECK_MANDATORY_FIELDS_D3

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_D3
*&---------------------------------------------------------------------*
*       Getting data for D3 radio button
*    <--FP_I_LIKP Internal table for LIKP
*    <--FP_I_LIPS Internal table for LIPS
*    <--FP_I_VBUP Internal table for VBUK
*    <--FP_I_VBAK Internal table for VBAK
*    <--FP_I_VBAP Internal table for VBAP
*----------------------------------------------------------------------*
FORM f_get_data_d3 CHANGING fp_i_likp TYPE ty_t_likp
                            fp_i_lips TYPE ty_t_lips
*--> Begin of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*                            fp_i_vbuk TYPE ty_t_vbuk
*<-- End of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
                            fp_i_vbup_d3  TYPE ty_t_vbup_d3
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
                            fp_i_vbak TYPE ty_t_vbak
                            fp_i_vbap TYPE ty_t_vbap.

  CONSTANTS:
*--> Begin of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*             lc_fksta TYPE fkstk VALUE 'A', "Local constant for Billing Status in process
*<-- End of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
             lc_wbsta TYPE wbsta VALUE 'C', " Goods movement status
             lc_fksta TYPE fksta VALUE 'A', " Billing status of delivery-related billing documents
*--> Begin of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 13-Dec-2018
"We will use the range table from EMI
*             lc_pdsta TYPE pdsta VALUE 'A',  " POD status on item level
*<-- End of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 13-Dec-2018
             lc_i     TYPE char1 VALUE 'I',  " I of type CHAR1
             lc_eq    TYPE char2 VALUE 'EQ'. " Eq of type CHAR2
  TYPES: BEGIN OF lty_vbeln,
         sign   TYPE char1,    " Sign of type CHAR1
         option TYPE char2,    " Option of type CHAR2
         low    TYPE vbeln_va, " Sales Document
         high   TYPE vbeln_va, " Sales Document
         END OF lty_vbeln.
  DATA: li_vbeln TYPE STANDARD TABLE OF lty_vbeln INITIAL SIZE 0, "Local range table
        li_vbap  TYPE STANDARD TABLE OF ty_vbap   INITIAL SIZE 0, "Local internal table
        lwa_vbeln TYPE lty_vbeln,                                 "Local workarea
        lwa_vbak  TYPE ty_vbak.                                   "Local workarea
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
  SELECT   vbeln "Delivery
           erdat "Date on Which Record Was Created
           vkorg "Sales Organization
           lfart "Delivery Type
           vtwiv "Distribution channel for intercompany billing
           spaiv "Division for intercompany billin
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
           wadat_ist "Actual PGI date
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
           FROM likp " SD Document: Delivery Header Data
           INTO TABLE fp_i_likp
*--> Begin of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*           WHERE erdat = sy-datum
*           AND   vkorg IN s_vkorg1
*           AND   lfart IN s_lfart.
*<-- End of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
"Using LIKP-Y03 index partially
           WHERE vkorg IN s_vkorg1
           AND   lfart IN s_lfart
           AND   wadat_ist LE s_wadat.
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
  IF sy-subrc IS INITIAL.
    SORT fp_i_likp BY vbeln.
*--> Begin of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*      SELECT vbeln " Sales and Distribution Document Number
*             fkstk " Billing status
*             FROM vbuk " Sales Document: Header Status and Administrative Data
*             INTO TABLE fp_i_vbuk
*             FOR ALL ENTRIES IN fp_i_likp
*             WHERE vbeln = fp_i_likp-vbeln.
*      IF sy-subrc IS INITIAL.
*        SORT fp_i_vbuk BY fkstk.
*        DELETE fp_i_vbuk WHERE fkstk NE lc_fksta.
*        IF fp_i_vbuk IS NOT INITIAL.
*<-- End of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
    SELECT vbeln     " Sales and Distribution Document Number
           posnr     " Item number of the SD document
           wbsta     " Goods movement status
           fksta     " Billing status of delivery-related billing documents
           pdsta     " POD status on item level
           FROM vbup " Sales Document: Item Status
           INTO TABLE fp_i_vbup_d3
           FOR ALL ENTRIES IN fp_i_likp
           WHERE vbeln = fp_i_likp-vbeln.
    IF sy-subrc IS INITIAL.
 "Filtering the entries in VBUP respecting Item status of billing,POD and PGI at item level
      DELETE fp_i_vbup_d3 WHERE wbsta NE lc_wbsta.
      DELETE fp_i_vbup_d3 WHERE fksta NE lc_fksta.
*--> Begin of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 13-Dec-2018
*      DELETE fp_i_vbup_d3 WHERE pdsta NE lc_pdsta.
*<-- End of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 13-Dec-2018
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 13-Dec-2018
 "We will consider both A and B statuses
      IF i_pdsta IS NOT INITIAL.
        DELETE fp_i_vbup_d3 WHERE pdsta NOT IN i_pdsta.
      ENDIF. " IF i_pdsta IS NOT INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 13-Dec-2018

      IF fp_i_vbup_d3 IS NOT INITIAL.
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
        SELECT vbeln     " Delivery
               erdat     " Date on Which Record Was Created
               vgbel     " Document number of the reference document
               vgpos     " Item number of the reference item
               FROM lips " SD document: Delivery: Item data
               INTO TABLE fp_i_lips
*--> Begin of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*                 FOR ALL ENTRIES IN fp_i_vbuk
*                 WHERE vbeln = fp_i_vbuk-vbeln.
*<-- End of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
               FOR ALL ENTRIES IN fp_i_vbup_d3
               WHERE vbeln = fp_i_vbup_d3-vbeln
               AND   posnr = fp_i_vbup_d3-posnr.
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
        IF sy-subrc IS INITIAL.
          SORT fp_i_lips BY vgbel vgpos.
*--> Begin of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
          "As we have to consider only those item from the order where Delivery is created so first taking the VBAP
          "entry first then filtering from VBAK after that
*          SELECT vbeln " Sales Document
*                 erdat " Date on Which Record Was Created
*                 auart " Sales Document Type
*                 vkorg " Sales Organization
*                 vtweg " Distribution Channel
*                 spart " Division
*                 kunnr " Sold-to party
*            FROM vbak  " Sales Document: Header Data
*            INTO TABLE fp_i_vbak
*            FOR ALL ENTRIES IN fp_i_lips
*            WHERE vbeln = fp_i_lips-vgbel
*            AND   auart IN s_auart1[]
*            AND   vtweg IN s_vtweg1[]
*            AND   spart IN s_spart1[].
*          IF sy-subrc IS INITIAL.
*            IF s_vbeln1 IS NOT INITIAL.
*              DELETE fp_i_vbak WHERE vbeln NOT IN s_vbeln1.
*            ENDIF. " IF s_vbeln1 IS NOT INITIAL
*            IF fp_i_vbak IS NOT INITIAL.
*<-- End of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
          SELECT vbeln  " Sales Document
                 posnr  " Sales Document Item
                 matnr  " Material Number
                 abgru  "Reason for rejection of quotations and sales orders
                 meins  " Base Unit of Measure
                 kwmeng " Cumulative Order Quantity in Sales Units
                 werks  " Plant (Own or External)
            FROM vbap   " Sales Document: Item Data
            INTO TABLE fp_i_vbap
*--> Begin of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*                FOR ALL ENTRIES IN fp_i_vbak
*                WHERE vbeln EQ fp_i_vbak-vbeln.
*<-- End of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
            FOR ALL ENTRIES IN fp_i_lips
            WHERE vbeln = fp_i_lips-vgbel
            AND   posnr = fp_i_lips-vgpos
            AND   spart IN s_spart1[].
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
          IF sy-subrc IS INITIAL.
            SORT fp_i_vbap BY vbeln posnr.
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
 "Fetching records from VBAK table to filter from VBAP
            li_vbap[] = fp_i_vbap[].
            SORT li_vbap BY vbeln.
            DELETE ADJACENT DUPLICATES FROM li_vbap COMPARING vbeln.
            SELECT vbeln " Sales Document
                   erdat " Date on Which Record Was Created
                   auart " Sales Document Type
                   vkorg " Sales Organization
                   vtweg " Distribution Channel
                   spart " Division
                   kunnr " Sold-to party
              FROM vbak  " Sales Document: Header Data
              INTO TABLE fp_i_vbak
              FOR ALL ENTRIES IN li_vbap
              WHERE  vbeln = li_vbap-vbeln
               AND   auart IN s_auart1[]
               AND   vtweg IN s_vtweg1[].
*--> Begin of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*               AND   spart IN s_spart1[].
*<-- End of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
            IF sy-subrc IS INITIAL.
              IF s_vbeln1 IS NOT INITIAL.
                DELETE fp_i_vbak WHERE vbeln NOT IN s_vbeln1.
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 29-Nov-2018
              ENDIF. " IF s_vbeln1 IS NOT INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 29-Nov-2018
 "Taking the Sales order number from VBAK into a range table
              IF fp_i_vbak IS NOT INITIAL.
                LOOP AT fp_i_vbak INTO lwa_vbak.
                  lwa_vbeln-sign   = lc_i.
                  lwa_vbeln-option = lc_eq.
                  lwa_vbeln-low    = lwa_vbak-vbeln.
                  APPEND lwa_vbeln TO li_vbeln.
                  CLEAR:lwa_vbeln,
                        lwa_vbak.
                ENDLOOP. " LOOP AT fp_i_vbak INTO lwa_vbak
 "Deleting the records from VBAP where there is no entry in VBAK
                DELETE fp_i_vbap WHERE vbeln NOT IN li_vbeln.
*--> Begin of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 29-Nov-2018
*              ENDIF. " IF fp_i_vbak IS NOT INITIAL
*<-- End of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 29-Nov-2018
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 29-Nov-2018
              ELSE. " ELSE -> IF fp_i_vbak IS NOT INITIAL
 "If we don't have any records in VBAK then we should not proceed further
 "so clearing the VBAP entries
                FREE fp_i_vbap[].
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 29-Nov-2018
              ENDIF. " IF fp_i_vbak IS NOT INITIAL
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 29-Nov-2018
            ELSE. " ELSE -> IF sy-subrc IS INITIAL
 "If we don't have any records in VBAK then we should not proceed further
 "so clearing the VBAP entries
              FREE fp_i_vbap[].
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 29-Nov-2018
            ENDIF. " IF sy-subrc IS INITIAL
*<-- End of Insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
          ENDIF. " IF sy-subrc IS INITIAL
*--> Begin of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*            ENDIF. " IF fp_i_vbak IS NOT INITIAL
*          ENDIF. " IF sy-subrc IS INITIAL
*<-- End of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF fp_i_vbup_d3 IS NOT INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
  ENDIF. " IF sy-subrc IS INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
ENDFORM. " F_GET_DATA_D3

*&---------------------------------------------------------------------*
*&      Form  F_GET_FINAL_D3
*&---------------------------------------------------------------------*
*      Populating the final Item table
*    -->FP_I_VBAP      Internal table for VBAP
*    -->FP_I_VBKD      Internal table for VBKD
*    -->FP_I_LIKP      Internal table for LIKP
*    <--FP_I_FINAL_ITM Internal table for Item Final
*----------------------------------------------------------------------*
FORM f_get_final_d3  USING    fp_i_vbap      TYPE ty_t_vbap
                              fp_i_vbkd      TYPE ty_t_vbkd
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
                              fp_i_likp      TYPE ty_t_likp
                              fp_i_lips      TYPE ty_t_lips
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
                     CHANGING fp_i_final_itm TYPE ty_t_final.

  DATA: lwa_vbap      TYPE ty_vbap,
        lwa_vbkd      TYPE ty_vbkd,
        lwa_final_itm TYPE ty_final,
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
        lwa_likp      TYPE ty_likp,
        lwa_lips      TYPE ty_lips.
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
  LOOP AT fp_i_vbap INTO  lwa_vbap.
    lwa_final_itm-vbeln  = lwa_vbap-vbeln.
    lwa_final_itm-posnr  = lwa_vbap-posnr.
    lwa_final_itm-sel    = abap_true.
*&--Read SO Business data
    READ TABLE fp_i_vbkd INTO lwa_vbkd
                         WITH KEY vbeln = lwa_vbap-vbeln
                                  posnr = lwa_vbap-posnr
                         BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lwa_final_itm-prsdt = lwa_vbkd-prsdt.
    ELSE. " ELSE -> IF sy-subrc IS INITIAL
*&--If data not found then get data when POSNR is initial
      READ TABLE fp_i_vbkd INTO lwa_vbkd
                           WITH KEY vbeln = lwa_vbap-vbeln
                                    posnr = c_posnr_00
                           BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        lwa_final_itm-prsdt = lwa_vbkd-prsdt.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
 "We will take those orders where pricing date is not same as Actual PGI date
    READ TABLE fp_i_lips INTO lwa_lips WITH KEY vgbel = lwa_vbap-vbeln
                                                vgpos = lwa_vbap-posnr
                                                BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      READ TABLE fp_i_likp INTO lwa_likp WITH KEY vbeln = lwa_lips-vbeln
                                                  BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        IF lwa_likp-wadat_ist NE lwa_final_itm-prsdt.
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
          APPEND lwa_final_itm TO fp_i_final_itm.
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
        ENDIF. " IF lwa_likp-wadat_ist NE lwa_final_itm-prsdt
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
    CLEAR:  lwa_final_itm,
            lwa_vbap,
            lwa_vbkd,
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
            lwa_likp,
            lwa_lips.
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
  ENDLOOP. " LOOP AT fp_i_vbap INTO lwa_vbap
ENDFORM. " F_GET_FINAL_D3
*<-- End of insert D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
