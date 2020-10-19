*&---------------------------------------------------------------------*
*&Include           ZOTCN0165B_AUTO_FILLUP_SUB
*&---------------------------------------------------------------------*
***********************************************************************
*Program    : Include ZOTCN0165B_AUTO_FILLUP_SUB                      *
*Title      : ZOTCN0165B_AUTO_FILLUP_SUB                              *
*Developer  : Moushumi Bhattacharya                                   *
*Object type: Report                                                  *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_EDD_0165                                           *
*---------------------------------------------------------------------*
*Description: This include has been created to handle the main        *
*             functionality of this report                            *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*08-Aug-2014  MBHATTA1      E2DK901527     R2:DEV:D2_OTC_EDD_0165_Auto*
*                                          fill up orders             *
*---------------------------------------------------------------------*
*25-MAR-2014  ASK          E2DK901527    Defect 5267 : Making TVARVC  *
*                                        parameter Based On Sales Area*
*---------------------------------------------------------------------*
*25-MAR-2014  MBHATTA1     E2DK901527    Defect 5267 : Changed BDC for*
*                                        updating STVARV for new      *
*                                        variables                    *
*---------------------------------------------------------------------*
*04-Nov-2015  SAGARWA1     E2DK915951    Defect#1058 :Add Sales Office*
*                                        on Selection screen          *
*---------------------------------------------------------------------*
*12-Aug-2016  SAGARWA1      E2DK918614   Defect#1882 :                *
*                                        1. Add Order Combination on  *
*                                        Selection screen and update  *
*                                        VBKD accordingly.            *
*                                        2. Create Consignment Fill up*
*                                        irrespective of consignment  *
*                                        issue status.                *
*                                        3. Populate PO number in fill*
*                                        up to maintain one to one rel*
*                                        -ationship.                  *
*---------------------------------------------------------------------*
*13-Oct-2017  AMANGAL       E1DK931603  Defect 3009. Mark ZKE lines as*
*                                       invoice only, not to be       *
*                                       considered by Autofill program*
*                                       when customer does not want   *
*                                       the replenishment due to      *
*                                       material in end of life status*
*                                       and other reasons.  This is   *
*                                       by checking if there is any   *
*                                       text for the item with ID     *
*                                       maintained in EMI table with  *
*                                       criteria "INVOICE_ONLY_TEXT"  *
*21-Nov-2017  AMOHAPA     E1DK931603    Defect# 4255: Unconfirmed     *
*                                       lines should transfer from ZKE*
*                                       to ZKB as per the design      *
*06-Feb-2018  AMOHAPA     E1DK934326    Defect# 4759: Invoice only    *
*                                       should be considered          *
*                                       irrespective of the language  *
*06-Mar-2018  U033814     E1DK934326    R3 Changes Copy customer PO   *
*                                       from Sales order header to Item
*04-Jul-2018  PDEBARU     E1DK937536    Defect # 6345 : Sales BOM     *
*                                       components need to be ignored *
*                                      for copy from ZKE to ZKB as the*
*                                       Sales BOM header is exploding *
*                                       the BOM in ZKB                *
*04-Jul-2018  PDEBARU     E1DK937536    INC0424007-01 / Defect # 6720 *
*                                       Changes - PO header population*
*                                       corrected                     *
*17-Jul-2019  U024694     E2DK925303    INC0456570-03 / Def# 10112    *
*                                       Quantity Mismatch between ZKE *
*                                       & ZKB orders                  *
*&---------------------------------------------------------------------
*&      Form  F_DYNAMIC_VAR
*&---------------------------------------------------------------------*
*       This form will get the order number i.e the order number last  *
*       processed by this program, for variant ZOTC_AUTOFILL, from     *
*       table TVARVC. The last order numebr will always be updated to  *
*       the TVARVC table after every run                               *
*----------------------------------------------------------------------*
*      <--FP_S_VBELN       Sales Order Number                               *
*----------------------------------------------------------------------*
FORM f_dynamic_var. " Sales and Distribution Document Number

  CONSTANTS : lc_sign    TYPE ddsign   VALUE 'I',  " Type of SIGN component in row type of a Ranges type
              lc_option  TYPE ddoption VALUE 'GT'. " Type of OPTION component in row type of a Ranges type

* Begin of Change for Defect 5267
* First Prepare the TVARVC paramter name
  IF p_vkorg IS NOT INITIAL.
    CLEAR s_vbeln[].
    CONCATENATE c_var p_vkorg INTO gv_name
                     SEPARATED BY c_undrscr.

* End   of Change for Defect 5267
*fetching the last doc no if maintained in TVARVC
    SELECT low    " ABAP/4: Selection value (LOW or HIGH value, external format)
      FROM tvarvc " Table of Variant Variables (Client-Specific)
      INTO s_vbeln-low
      UP TO 1 ROWS
* Begin of Change for Defect 5267
*    WHERE name = c_var   " Defect 5267
      WHERE name = gv_name
* End   of Change for Defect 5267
      AND   type = c_type. " And of type
    ENDSELECT.
    IF sy-subrc IS NOT INITIAL.
      CLEAR s_vbeln.
    ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL
      s_vbeln-sign   = lc_sign.
      s_vbeln-option = lc_option.
      APPEND s_vbeln TO s_vbeln.
    ENDIF. " IF sy-subrc IS NOT INITIAL
  ENDIF. " IF p_vkorg IS NOT INITIAL
ENDFORM. " F_DYNAMIC_VAR
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*      Form to fetch the data required to create consignment issue order
*&---------------------------------------------------------------------*
*      <--FP_I_VBAK              Sales Order details
*      <--FP_I_VBAP              Sales Order Item Details
*      <--FP_I_VBUP              Order status details
*      <--FP_I_VBPA              Order partner details
*      <--FP_I_LIPS              Delivery details (Not in use Defect# 4255)
*      <--FP_I_VBKD              Business Data
************************************************************************
FORM f_get_data CHANGING fp_i_vbak      TYPE ty_t_vbak
                         fp_i_vbap      TYPE ty_t_vbap
                         fp_i_vbup      TYPE ty_t_vbup
                         fp_i_vbpa      TYPE ty_t_vbpa
*--> Begin of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
*                         fp_i_lips      TYPE ty_t_lips
*<-- End of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
                         fp_i_vbkd      TYPE ty_t_vbkd.
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016

**********************************************************************
****************************CONSTANTS*********************************
  CONSTANTS: lc_posnr   TYPE posnr VALUE '000000',     " Item number of the SD document
             lc_kunnr   TYPE kunnr VALUE '0000000000'. " Customer Number

**********************************************************************
****************************INTERNAL TABLES***************************
  DATA: li_kna1      TYPE ty_t_kna1, " for customer attributes
        li_vbpa      TYPE ty_t_vbpa, " for all the partner  functions
        li_vbpa_temp TYPE ty_t_vbpa. " for temporary use of unique partners

**********************************************************************
****************************VARIABLES*********************************
  DATA: lv_lines  TYPE sy-tfill. " Lines of type Character

**********************************************************************
*************************FIELD-SYMBOLS********************************
  FIELD-SYMBOLS: <lfs_vbpa> TYPE ty_vbpa, " for vbpa
                 <lfs_vbap> TYPE ty_vbap,
                 <lfs_vbak> TYPE ty_vbak. " for vbak
**********************************************************************
  DATA : lwa_vbak TYPE ty_vbak.
  SELECT vbeln " Sales Document
         erdat " Date on Which Record Was Created
         auart " Sales Document Type
         vkorg " Sales Organization
         vtweg " Distribution Channel
         spart " Division
         vkbur
* Begin of R3
         bstnk
* End of R3
         bsark " Customer purchase order type
* Begin of R3
         bstdk
* End of R3
    FROM vbak " Sales Document: Header Data
    INTO TABLE fp_i_vbak
    WHERE vbeln IN s_vbeln
    AND   erdat IN s_date
    AND   auart = p_source
    AND   vkorg = p_vkorg
    AND   vtweg = p_vtweg
    AND   spart = p_spart.

  IF fp_i_vbak IS NOT INITIAL.
*&-- Selecting partners for the selected orders from partner table
    SORT fp_i_vbak BY vbeln.
    SELECT vbeln " Sales and Distribution Document Number
           posnr " Item number of the SD document
           parvw " Partner Function
           kunnr " Customer Number
      FROM vbpa  " Sales Document: Partner
      INTO TABLE fp_i_vbpa
      FOR ALL ENTRIES IN fp_i_vbak
      WHERE vbeln = fp_i_vbak-vbeln
      AND   posnr = lc_posnr
      AND   parvw IN (p_parvw, c_soldto).

    IF sy-subrc IS NOT INITIAL.
      MESSAGE i044(zotc_msg). " No partners found for the selected orders.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF sy-subrc IS NOT INITIAL
  ELSE. " ELSE -> IF fp_i_vbak IS NOT INITIAL
    MESSAGE i045(zotc_msg). " No Order available.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF fp_i_vbak IS NOT INITIAL

*&-- Segregating partners based on special stock partners in a seperate table
*&-- before that taking all the partners into another table
  li_vbpa[] = fp_i_vbpa[].
  DELETE fp_i_vbpa WHERE parvw NE p_parvw.

*&-- Deleting partners where kunnr is initial.
  DELETE fp_i_vbpa WHERE kunnr EQ lc_kunnr.

*&-- Incase no special stock partner available
  IF fp_i_vbpa IS INITIAL.
    MESSAGE i058(zotc_msg). " No Special Stock Partner available.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF fp_i_vbpa IS INITIAL

*&-- Deleting partners not applicable based on selection screen entry
  IF s_kunnr IS NOT INITIAL.
    DELETE fp_i_vbpa WHERE kunnr NOT IN s_kunnr.
  ENDIF. " IF s_kunnr IS NOT INITIAL

*&-- Determine the last document number selected in the current process
*&-- so that it can be updated in TVARVC

  CLEAR lv_lines.
  DESCRIBE TABLE fp_i_vbak LINES lv_lines.
  READ TABLE fp_i_vbak ASSIGNING <lfs_vbak> INDEX lv_lines.
  IF sy-subrc = 0.
    gv_vbeln = <lfs_vbak>-vbeln.
  ENDIF. " IF sy-subrc = 0

*&-- Fetch the item data for the specific order numbers
  SELECT vbeln " Sales Document
         posnr " Sales Document Item
         matnr " Material Number
*---> Begin of insert for Defect # 6345 D3_OTC_EDD_0165 by PDEBARU
         uepos " Higher-level item in bill of material structures
*<--- End of insert for Defect # 6345 D3_OTC_EDD_0165 by PDEBARU
         abgru " Reason for rejection of quotations and sales orders
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
         kwmeng " Cumulative Order Quantity in Sales Units
         vrkme  " Sales unit
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
  FROM vbap " Sales Document: Item Data
  INTO TABLE fp_i_vbap
  FOR ALL ENTRIES IN fp_i_vbak
  WHERE vbeln = fp_i_vbak-vbeln.

  IF sy-subrc IS INITIAL.
*&-- remove entries which have any "Reason for rejection
*      of quotations and sales orders"
    DELETE fp_i_vbap WHERE abgru IS NOT INITIAL.
*---> Begin of insert for Defect # 6345 D3_OTC_EDD_0165 by PDEBARU

     DELETE fp_i_vbap WHERE uepos IS NOT INITIAL.
*<--- End of insert for Defect # 6345 D3_OTC_EDD_0165 by PDEBARU

*--> Begin of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
*    SORT fp_i_vbap BY vbeln posnr.

*    IF fp_i_vbap IS NOT INITIAL.
*      SELECT vbeln " Delivery
*             posnr " Delivery Item
*             matnr " Material Number
*             lfimg " Actual quantity delivered (in sales units)
*             meins " Base Unit of Measure
*             vgbel " Document number of the reference document
*             vgpos " Item number of the reference item
*        FROM lips  " SD document: Delivery: Item data
*        INTO TABLE fp_i_lips
*        FOR ALL ENTRIES IN fp_i_vbap
*        WHERE vgbel = fp_i_vbap-vbeln
*        AND   vgpos = fp_i_vbap-posnr.
*
*      IF sy-subrc IS INITIAL.
*        SORT fp_i_lips BY vgbel vgpos.
*      ENDIF. " IF sy-subrc IS INITIAL
*    ENDIF. " IF fp_i_vbap IS NOT INITIAL

*<-- End of delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017

*& --> Begin of Delete for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
** No need to select data from VBUP table as the output should be displayed
** irrespective of delivery status
**
***&--fetch the delivery status for each item in each order
**    SELECT vbeln " Sales and Distribution Document Number
**           posnr " Item number of the SD document
**           lfsta " Delivery status
**      FROM vbup  " Sales Document: Item Status
**      INTO TABLE fp_i_vbup
**      FOR ALL ENTRIES IN fp_i_vbap
**      WHERE vbeln = fp_i_vbap-vbeln
**      AND   posnr = fp_i_vbap-posnr.
**
**    IF sy-subrc IS INITIAL.
***&--removing deliveries which are neither partially delivered "delivery status 'B'"
*** nor completely delivered "delivery status 'C'"
**************************************************************************************
**      SORT fp_i_vbup BY vbeln posnr.
**      PERFORM f_delete_orderitems USING fp_i_vbup
**                               CHANGING fp_i_vbap.
**
**************************************************************************************
*& <-- End of Delete for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016


    SORT fp_i_vbap BY vbeln.
    SORT fp_i_vbak BY vbeln.

* Begin of R3
    LOOP AT fp_i_vbap ASSIGNING <lfs_vbap>.
      READ TABLE fp_i_vbak INTO lwa_vbak WITH KEY vbeln = <lfs_vbap>-vbeln. " BINARY SEARCH.
      IF sy-subrc EQ 0.
        <lfs_vbap>-bstnk = lwa_vbak-bstnk .
        <lfs_vbap>-bstdk = lwa_vbak-bstdk.
      ENDIF. " IF sy-subrc EQ 0
    ENDLOOP. " LOOP AT fp_i_vbap ASSIGNING <lfs_vbap>
* End of R3

*--> Begin of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
*&--map deliveries based on sales order items
*    PERFORM f_delete_delitems USING fp_i_vbap
*                        CHANGING fp_i_lips.
*<-- End of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017

*&--Deleting orders at the header level not required for further processing
    PERFORM f_delete_orderhdrs USING fp_i_vbap
                            CHANGING fp_i_vbak.

*& --> Begin of Delete for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
**    ENDIF. " IF sy-subrc IS INITIAL
*& <-- End of Delete for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016

  ENDIF. " IF sy-subrc IS INITIAL

*************************************************************************************
*&--deleting partners which dont have there corresponding
*  order numbers present in the header table
  SORT fp_i_vbak BY vbeln.
  PERFORM f_delete_partners USING fp_i_vbak
                         CHANGING fp_i_vbpa.


*&--check whether a customer is fit for auto replenishments
  SORT fp_i_vbpa BY vbeln kunnr.
  DELETE ADJACENT DUPLICATES FROM fp_i_vbpa COMPARING vbeln kunnr.

  IF fp_i_vbpa IS NOT INITIAL.
    li_vbpa_temp[] = fp_i_vbpa[].
    SORT li_vbpa_temp BY kunnr.
    DELETE ADJACENT DUPLICATES FROM li_vbpa_temp COMPARING kunnr.
    IF li_vbpa_temp IS NOT INITIAL.
      SELECT  kunnr           " Customer Number
              katr2           " Attribute 2
         FROM kna1            " General Data in Customer Master
         INTO TABLE li_kna1
         FOR ALL ENTRIES IN li_vbpa_temp
         WHERE kunnr = li_vbpa_temp-kunnr
         AND   loevm = space. "-deleting entries based on the deletion indicator

      IF sy-subrc IS INITIAL.
*&--deleting entries in the table li_kna1 based attribute
*value present in the selection screen
        DELETE li_kna1 WHERE katr2 NE p_attri.
*&--deleting entries in the partner table based on customer
*      auto-replenishment attribute
        SORT li_kna1 BY kunnr.
        PERFORM f_filter_customer USING li_kna1
                               CHANGING fp_i_vbpa.
        IF fp_i_vbpa IS INITIAL.
          MESSAGE i046(zotc_msg). " None of the partners applicable for Auto-Replenishment.
          LEAVE LIST-PROCESSING.
        ENDIF. " IF fp_i_vbpa IS INITIAL
      ELSE. " ELSE -> IF sy-subrc IS INITIAL
        MESSAGE i046(zotc_msg). " None of the partners applicable for Auto-Replenishment.
        LEAVE LIST-PROCESSING.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF li_vbpa_temp IS NOT INITIAL
    CLEAR li_vbpa_temp.
  ENDIF. " IF fp_i_vbpa IS NOT INITIAL

*************************************************************************************
*&-- Deleting deliveries at the item level not required for further processing
  SORT fp_i_vbpa BY vbeln.

*--> Begin of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
*  PERFORM f_delete_delivery USING fp_i_vbpa
*                         CHANGING fp_i_lips.
*<-- End of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017

*************************************************************************************

*&--with the help of fp_i_vbpa deleting all the partners not required from li_vbpa
*this table will consist of both soldto and special stock partners for cases specific
*to consignment fill-up order creation. As the table fp_i_vbpa is no more required
*clear it and pass the resultant li_vbpa to the table fp_i_vbpa.
  IF fp_i_vbpa IS NOT INITIAL.
    SORT fp_i_vbpa BY vbeln.
    LOOP AT li_vbpa ASSIGNING <lfs_vbpa>.
      READ TABLE fp_i_vbpa TRANSPORTING NO FIELDS WITH KEY vbeln = <lfs_vbpa>-vbeln
                                                           BINARY SEARCH.
      IF sy-subrc IS NOT INITIAL.
        CLEAR <lfs_vbpa>-vbeln.
      ENDIF. " IF sy-subrc IS NOT INITIAL
    ENDLOOP. " LOOP AT li_vbpa ASSIGNING <lfs_vbpa>

    DELETE li_vbpa WHERE vbeln IS INITIAL.
    CLEAR fp_i_vbpa.
    fp_i_vbpa[] = li_vbpa[].
  ENDIF. " IF fp_i_vbpa IS NOT INITIAL

*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
  IF fp_i_vbpa[] IS NOT INITIAL.
    REFRESH li_vbpa[].
    li_vbpa[] = fp_i_vbpa[].
    SORT li_vbpa BY vbeln.
    DELETE ADJACENT DUPLICATES FROM li_vbpa COMPARING vbeln.
    SELECT vbeln " Sales and Distribution Document Number
           bstkd " Customer purchase order number
      FROM vbkd  " Sales Document: Business Data
      INTO TABLE fp_i_vbkd
      FOR ALL ENTRIES IN li_vbpa
      WHERE vbeln = li_vbpa-vbeln
      AND   posnr = lc_posnr.
    IF sy-subrc = 0.
      SORT fp_i_vbkd BY vbeln.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF fp_i_vbpa[] IS NOT INITIAL
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016

ENDFORM. " F_GET_DATA
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_DATA
*&---------------------------------------------------------------------*
*       Form to pass the data to the final internal tables for BAPI
*----------------------------------------------------------------------*
*       <--FP_I_VBPA      Partner Details
*       <--FP_I_LIPS      Delivery Details (Not in Use Defect# 4255)
*       <--FP_I_VBKD      Business Data
*       <--FP_I_VBAP      Item details
************************************************************************
FORM f_update_data  USING fp_i_vbpa  TYPE ty_t_vbpa
*--> Begin of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
*                          fp_i_lips  TYPE ty_t_lips
*<-- End of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
                          fp_i_vbkd  TYPE ty_t_vbkd
                          fp_i_vbap  TYPE ty_t_vbap.
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016

**********************************************************************
****************************CONSTANTS*********************************
  CONSTANTS: lc_enhancem_no    TYPE z_enhancement VALUE 'D2_OTC_EDD_0165', " Enhancement NUMBER
             lc_potyp          TYPE z_criteria    VALUE 'BSARK',           " Criteria Plant
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
             lc_vkorg          TYPE z_criteria    VALUE 'VKORG'. " Criteria Sales Organization
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016

**********************************************************************
****************************INTERNAL TABLES***************************
  DATA: li_material       TYPE ty_t_matnr,                                       " Material table
        li_spool          TYPE STANDARD TABLE OF ty_spool,                       " spool for the recording log
        li_final          TYPE STANDARD TABLE OF ty_final,                       " final table holding partner combinations
        li_enh_status     TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Internal table
        li_enh_status_t   TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0. " Internal table
*--> Begin of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
*        li_material_temp  TYPE ty_t_matnr. " Temp meatrial table
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
*<-- End of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
**********************************************************************
****************************WORK AREA*********************************
  DATA: lwa_order_header_in TYPE bapisdhd1,       " Communication Fields: Sales and Distribution Document Header
        lwa_material        TYPE ty_matnr,        " Material data                                                   ##NEEDED
        lwa_final           TYPE ty_final,        " final table                                                     ##NEEDED
        lwa_enh_status      TYPE zdev_enh_status, " Enhancement Status                                              ##NEEDED
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
        lv_flag             TYPE flag. " General Flag
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016

**Begin of defect 3009, amangal 10/12/2017
  DATA:
*&--> Begin of delete for D3_OTC_EDD_0165_Defect#4759 by AMOHAPA on 06-Feb-2018
"As we are no more using READ_TEXT fm so commenting this Internal table
*        li_lines TYPE TABLE OF tline, " SAPscript: Text Lines
*&<-- End of delete for D3_OTC_EDD_0165_Defect#4759 by AMOHAPA on 06-Feb-2018
        lv_name TYPE thead-tdname,   " Name
        lv_posnr TYPE char6,         " Posnr of type CHAR6
        lv_vbbp TYPE thead-tdobject. " Texts: Application Object

  DATA: lv_textid TYPE thead-tdid,                          " Text ID
        lc_ionly_text(17) TYPE c VALUE 'INVOICE_ONLY_TEXT', " Ionly_text(17) of type Character
        lv_tabix TYPE sy-tabix.                             " Index of Internal Tables

  CONSTANTS: lc_vbbp(4) TYPE c VALUE 'VBBP'. " Vbbp(4) of type Character

**End of defect 3009, amangal 10/12/2017
**********************************************************************
*************************FIELD-SYMBOLS********************************
  FIELD-SYMBOLS: <lfs_vbpa>            TYPE ty_vbpa, " for vbpa

*--> Begin of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
*                 <lfs_lips>            TYPE ty_lips, " for lips
*<-- End of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017

*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
                 <lfs_vbkd>            TYPE ty_vbkd, " for VBKD
                 <lfs_vbap>            TYPE ty_vbap. " for VBAP
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016

*&--> Begin of insert for D3_OTC_EDD_0165_Defect#4759 by AMOHAPA on 06-Feb-2018
                                      "Structure for STXH table to read the Text
  TYPES:BEGIN OF lty_text,
        tdobject   TYPE	tdobject,     " Object
        tdname     TYPE tdobname,     " Name
        tdid       TYPE tdid,         " Text ID
        tdtxtlines TYPE   tdtxtlines, " Number of Text Lines in Line Table
        END OF lty_text.

  DATA: li_text  TYPE STANDARD TABLE OF lty_text INITIAL SIZE 0, "Local internam table STXH
        lwa_text TYPE lty_text.                                  "Local workarea

*&<-- End of insert for D3_OTC_EDD_0165_Defect#4759 by AMOHAPA on 06-Feb-2018

**********************************************************************
  SORT fp_i_vbpa BY vbeln parvw.
*--> Begin of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
*  SORT fp_i_lips BY vgbel matnr.
*<-- End of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017

*&--taking all the material with there respective qunatity, unit and partner
*into a material table for easy accumulation of data. For a given ship to and sold to
*for the same material cumulating all the quantities of the material in a material table
  REFRESH li_material.

*--> Begin of delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017

  "Commented the below piece of code as we will not consider delivery
  "records into account while copying from ZKE to ZKB
  "We will consider VBAP entry for this

*  LOOP AT fp_i_lips ASSIGNING <lfs_lips>.
*    READ TABLE fp_i_vbpa ASSIGNING <lfs_vbpa> WITH KEY vbeln = <lfs_lips>-vgbel
*                                                       parvw = c_soldto
*                                                       BINARY SEARCH.
*    IF sy-subrc IS INITIAL.
*      lwa_material-soldto     = <lfs_vbpa>-kunnr.
*      READ TABLE fp_i_vbpa ASSIGNING <lfs_vbpa> WITH KEY vbeln = <lfs_lips>-vgbel
*                                                         parvw = c_splstk
*                                                         BINARY SEARCH.
*      IF sy-subrc IS INITIAL.
*        lwa_material-shipto   = <lfs_vbpa>-kunnr.
*      ENDIF. " IF sy-subrc IS INITIAL
*      lwa_material-material   = <lfs_lips>-matnr.
*      lwa_material-target_qty = <lfs_lips>-lfimg.
*      lwa_material-target_qu  = <lfs_lips>-meins.
**& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
*      lwa_material-vbeln      = <lfs_lips>-vgbel.
**& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
*      COLLECT lwa_material INTO li_material.
*    ENDIF. " IF sy-subrc IS INITIAL
*  ENDLOOP. " LOOP AT fp_i_lips ASSIGNING <lfs_lips>

*<-- End of delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017


**Begin of defect 3009, amangal 10/12/2017
*fetching the customer purchase order number from the EMI Tool
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enhancem_no
    TABLES
      tt_enh_status     = li_enh_status.

*&--We select only the active entries.
  DELETE li_enh_status WHERE active = space.
*&--If enh is active in EMI Tool

  IF li_enh_status IS NOT INITIAL.

** Begin of defect 3009, amangal, 10/12/2017

    READ TABLE li_enh_status INTO lwa_enh_status
                             WITH KEY criteria = lc_ionly_text.

    IF sy-subrc = 0.
      lv_textid  = lwa_enh_status-sel_low.
    ENDIF. " IF sy-subrc = 0
** End of defect 3009, amangal, 10/12/2017

*&--> Begin of insert for D3_OTC_EDD_0165_Defect#4759 by AMOHAPA on 06-Feb-2018
                      "Previously text was coming with Language specific
                      "But in this defect we are Deleting the item if text is mainatined in Invoice Text only
                      "irrespective of the Language key

    SELECT tdobject   " Texts: Application Object
           tdname     " Name
           tdid       " Text ID
           tdtxtlines " Number of Text Lines in Line Table
           FROM stxh  " STXD SAPscript text file header
           INTO TABLE li_text
           WHERE tdobject = lc_vbbp
           AND   tdid     = lv_textid.

    IF sy-subrc IS INITIAL.
      SORT li_text BY tdobject tdname tdid.
    ENDIF. " IF sy-subrc IS INITIAL

*&<-- End of insert for D3_OTC_EDD_0165_Defect#4759 by AMOHAPA on 06-Feb-2018

*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016

*--> Begin of delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017

*    li_material_temp[] = li_material[].
*    SORT li_material_temp BY vbeln.

*<-- End of delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017

    LOOP AT fp_i_vbap ASSIGNING <lfs_vbap>.


**Begin of defect 3009, amangal 10/12/2017
      lv_tabix = sy-tabix.
      CLEAR lv_name.

      IF lv_textid IS NOT INITIAL.

        lv_vbbp = lc_vbbp.

        lv_posnr = <lfs_vbap>-posnr.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_posnr
          IMPORTING
            output = lv_posnr.

        CONCATENATE <lfs_vbap>-vbeln lv_posnr INTO lv_name.

*&--> Begin of delete for D3_OTC_EDD_0165_Defect#4759 by AMOHAPA on 06-Feb-2018
        "As we are getting record from STXH , so we are no longer using this FM

*        CALL FUNCTION 'READ_TEXT' ##fm_subrc_ok
*          EXPORTING
*            client                  = sy-mandt
*            id                      = lv_textid
*            language                = sy-langu
*            name                    = lv_name
*            object                  = lv_vbbp
*          TABLES
*            lines                   = li_lines
*          EXCEPTIONS
*            id                      = 1
*            language                = 2
*            name                    = 3
*            not_found               = 4
*            object                  = 5
*            reference_check         = 6
*            wrong_access_to_archive = 7
*            OTHERS                  = 8.
*
*        IF li_lines IS NOT INITIAL.
*&<-- End of delete for D3_OTC_EDD_0165_Defect#4759 by AMOHAPA on 06-Feb-2018

*&--> Begin of insert for D3_OTC_EDD_0165_Defect#4759 by AMOHAPA on 06-Feb-2018
        READ TABLE li_text INTO lwa_text WITH KEY tdobject = lv_vbbp
                                                  tdname   = lv_name
                                                  tdid     = lv_textid
                                                  BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          IF lwa_text-tdtxtlines IS NOT INITIAL.

            CLEAR lwa_text.
*&<-- End of insert for D3_OTC_EDD_0165_Defect#4759 by AMOHAPA on 06-Feb-2018

            DELETE fp_i_vbap INDEX lv_tabix.

*&--> Begin of delete for D3_OTC_EDD_0165_Defect#4759 by AMOHAPA on 06-Feb-2018
*          CLEAR li_lines[].
*&<-- End of delete for D3_OTC_EDD_0165_Defect#4759 by AMOHAPA on 06-Feb-2018

            CONTINUE.
          ENDIF. " IF lwa_text-tdtxtlines IS NOT INITIAL
*&--> Begin of insert for D3_OTC_EDD_0165_Defect#4759 by AMOHAPA on 06-Feb-2018
        ENDIF. " IF sy-subrc IS INITIAL
*&<-- End of insert for D3_OTC_EDD_0165_Defect#4759 by AMOHAPA on 06-Feb-2018

      ENDIF. " IF lv_textid IS NOT INITIAL
**End of defect 3009, amangal 10/12/2017

*--> Begin of delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
      "As we are not considering LIPS entry so we will populate LI_MATERIAL from
      "VBAP entry
*      READ TABLE li_material_temp TRANSPORTING NO FIELDS WITH KEY vbeln = <lfs_vbap>-vbeln
*                                                         BINARY SEARCH.
*      IF sy-subrc NE 0.
*<-- End of delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017

      READ TABLE fp_i_vbpa ASSIGNING <lfs_vbpa> WITH KEY vbeln = <lfs_vbap>-vbeln
                                                         parvw = c_soldto
                                                         BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        lwa_material-soldto     = <lfs_vbpa>-kunnr.
        READ TABLE fp_i_vbpa ASSIGNING <lfs_vbpa> WITH KEY vbeln = <lfs_vbap>-vbeln
                                                           parvw = c_splstk
                                                           BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          lwa_material-shipto   = <lfs_vbpa>-kunnr.
        ENDIF. " IF sy-subrc IS INITIAL
        lwa_material-material   = <lfs_vbap>-matnr.
        lwa_material-target_qty = <lfs_vbap>-kwmeng.
        lwa_material-target_qu  = <lfs_vbap>-vrkme.
* Begin of R3
        lwa_material-bstnk = <lfs_vbap>-bstnk.
        lwa_material-bstdk  = <lfs_vbap>-bstdk.

* End of R3
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
        lwa_material-vbeln      = <lfs_vbap>-vbeln.
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
        COLLECT lwa_material INTO li_material.
      ENDIF. " IF sy-subrc IS INITIAL

*--> Begin of delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
*      ENDIF. " IF sy-subrc NE 0
*<-- End of delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017

    ENDLOOP. " LOOP AT fp_i_vbap ASSIGNING <lfs_vbap>
    IF <lfs_vbap> IS ASSIGNED .
      UNASSIGN <lfs_vbap>.
    ENDIF. " IF <lfs_vbap> IS ASSIGNED

*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016



*&-- Populating the bapi structures and tables for posting

*fetching the customer purchase order number from the EMI Tool
*  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
*    EXPORTING
*      iv_enhancement_no = lc_enhancem_no
*    TABLES
*      tt_enh_status     = li_enh_status.
*
**&--We select only the active entries.
*  DELETE li_enh_status WHERE active = space.
**&--If enh is active in EMI Tool
*
*  IF li_enh_status IS NOT INITIAL.
*
*&--Get the Conntrolling area from EMI tool
    CLEAR lwa_enh_status.
    READ TABLE li_enh_status INTO lwa_enh_status
                             WITH KEY criteria = lc_potyp.
    IF sy-subrc = 0.
      lwa_order_header_in-po_method  = lwa_enh_status-sel_low.
    ENDIF. " IF sy-subrc = 0
    li_enh_status_t[] = li_enh_status[].
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
* Get the EMI entry for sales organization for which order combination should work
*    DELETE li_enh_status WHERE criteria NE lc_vkorg.
*    IF li_enh_status[] IS NOT INITIAL.
*      CLEAR : lv_flag.
**      break U033814.
*      LOOP AT li_enh_status INTO lwa_enh_status.
*        IF lwa_enh_status-sel_low = p_vkorg.
*          lv_flag = abap_true.
*          EXIT.
*        ENDIF. " IF lwa_enh_status-sel_low = p_vkorg
*      ENDLOOP. " LOOP AT li_enh_status INTO lwa_enh_status
*    ENDIF. " IF li_enh_status[] IS NOT INITIAL
**& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
*
  ENDIF. " IF li_enh_status IS NOT INITIAL

  IF cb_order IS NOT INITIAL.
    lv_flag = abap_true.
  ENDIF. " IF cb_order IS NOT INITIAL

*&--populating the structure order_header_in containing
*target doc type sales org,distrubution channel,
*division,reference doc and delivery block
  lwa_order_header_in-dlv_block  = p_lifsk.
  lwa_order_header_in-doc_type   = p_target.
  lwa_order_header_in-sales_org  = p_vkorg.
  lwa_order_header_in-distr_chan = p_vtweg.
  lwa_order_header_in-division   = p_spart.
*& -->Begin of Insert for Defect#1058 by SAGARWA1
*&--populating the structure order_header_in with Sales office
  lwa_order_header_in-sales_off  = p_vkbur.
*& -->End   of Insert for Defect#1058 by SAGARWA1
*******************************************************

  SORT fp_i_vbpa BY vbeln.
*&-- populating the li_final table with unique combination of soldto and shipto
  LOOP AT fp_i_vbpa ASSIGNING <lfs_vbpa>.
    IF <lfs_vbpa>-parvw     = c_soldto.
      lwa_final-soldto      = <lfs_vbpa>-kunnr.
    ELSEIF <lfs_vbpa>-parvw = c_splstk.
      lwa_final-shipto      = <lfs_vbpa>-kunnr.
    ENDIF. " IF <lfs_vbpa>-parvw = c_soldto
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
    READ TABLE  fp_i_vbkd ASSIGNING <lfs_vbkd> WITH KEY vbeln = <lfs_vbpa>-vbeln
                                               BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_final-bstkd  = <lfs_vbkd>-bstkd. " Purchase Order number
    ENDIF. " IF sy-subrc = 0
    lwa_final-vbeln    = <lfs_vbpa>-vbeln.

*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
    IF lwa_final-soldto IS NOT INITIAL
   AND lwa_final-shipto IS NOT INITIAL.
      APPEND lwa_final TO li_final.
      CLEAR lwa_final.
    ENDIF. " IF lwa_final-soldto IS NOT INITIAL
  ENDLOOP. " LOOP AT fp_i_vbpa ASSIGNING <lfs_vbpa>

*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
  IF <lfs_vbkd> IS ASSIGNED.
    UNASSIGN :<lfs_vbkd>.
  ENDIF. " IF <lfs_vbkd> IS ASSIGNED

  SORT li_final BY soldto shipto vbeln.
  SORT li_material BY soldto shipto vbeln.
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016

*& --> Begin of Delete for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
***    SORT li_final BY soldto shipto.
***    SORT li_material BY soldto shipto.
*& <-- End   of Delete for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016

  DELETE ADJACENT DUPLICATES FROM li_final COMPARING ALL FIELDS.

  IF lwa_order_header_in IS NOT INITIAL
 AND li_final IS NOT INITIAL
    AND li_material IS NOT INITIAL. " Defect # 4255

*&--for creating fill-up orders for single
*    combination of soldto and shipto partners
    PERFORM f_bapi_posting USING li_final
                                 li_material
*& --> Begin of Delete for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
*                                 lwa_order_header_in
*& <-- End   of Delete for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
                                 lv_flag
* Begin of R3
                                li_enh_status_t
* End of R3
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
                        CHANGING li_spool
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
                                 lwa_order_header_in.
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016

    IF li_spool IS NOT INITIAL.
*&--Passing the last order processed to the table TVARVC
*where variable is ZOTC_AUTOFILL
      PERFORM f_update USING gv_vbeln.

*&--generating alv display for error log
      PERFORM f_alv_display USING li_spool.

    ENDIF. " IF li_spool IS NOT INITIAL
  ENDIF. " IF lwa_order_header_in IS NOT INITIAL

ENDFORM. " F_UPDATE_DATA
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE
*&---------------------------------------------------------------------*
*  Updating the tbale TVARVC with the last processed Consignment Issue *
*  Order Number for variant ZOTC_AUTOFILL                              *
*----------------------------------------------------------------------*
*      -->FP_GV_VBELN   Sales Order Number
*----------------------------------------------------------------------*
FORM f_update  USING    fp_gv_vbeln TYPE vbeln. " Sales and Distribution Document Number
***********************************************************************
****************************INTERNAL TABLE*****************************
  DATA: li_bdccall   TYPE STANDARD TABLE OF  bdcmsgcoll. " Return Parameter
***********************************************************************
****************************CONSTANTS*****************************
  CONSTANTS: lc_error  TYPE bdc_mart   VALUE 'E', " SAP message type
             lc_info   TYPE msgtyp     VALUE 'I', " SAP message type
             lc_mode   TYPE ctu_mode   VALUE 'N', " BDC Mode
             lc_update TYPE ctu_update VALUE 'S'. " BDC Update

***********************************************************************
*****************************FIELD-SYMBOLS*****************************
  FIELD-SYMBOLS: <lfs_bdccall> TYPE bdcmsgcoll. " Collecting messages in the SAP System
***********************************************************************
****************************** VARIABLES*******************************
  DATA: lv_mode   TYPE ctu_mode,   " Mode of type Character
        lv_update TYPE ctu_update. " Update of type Character
***********************************************************************
*&--updating  tvarvc with variable name ZOTC_AUTOFILL and
* last consignment processed
  lv_mode   = lc_mode.
  lv_update = lc_update.

** Begin   of Change for Defect 5267
  CONCATENATE c_var p_vkorg INTO gv_name SEPARATED BY c_undrscr. " Defect 5267

  IF fp_gv_vbeln IS NOT INITIAL.
    REFRESH i_bdcdata[].
    PERFORM f_create_bdcdata USING fp_gv_vbeln
                          CHANGING i_bdcdata.
*    PERFORM f_bdc_dynpro      USING 'SAPMS38V' '1100'
*                              CHANGING i_bdcdata[].
*    PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                  '=TOGGLE'
*                              CHANGING i_bdcdata[].
*    PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                  'I_TVARVC_PARAMS-NAME(01)'
*                              CHANGING i_bdcdata[].
*    PERFORM f_bdc_dynpro      USING 'SAPMS38V' '1100'
*                              CHANGING i_bdcdata[].
*    PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                  '=SEARCH'
*                              CHANGING i_bdcdata[].
*    PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                  'I_TVARVC_PARAMS-NAME(01)'
*                              CHANGING i_bdcdata[].
*    PERFORM f_bdc_dynpro      USING 'SAPMS38V' '1200'
*                              CHANGING i_bdcdata[].
*    PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                  'SEARCH_NAME'
*                              CHANGING i_bdcdata[].
*    PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                  '=ENTER'
*                              CHANGING i_bdcdata[].
*    PERFORM f_bdc_field       USING 'SEARCH_NAME'
**                                    c_var    " Defect 5267
*                                    gv_name  " Defect 5267
*                              CHANGING i_bdcdata[].
*    PERFORM f_bdc_dynpro      USING 'SAPMS38V' '1100'
*                              CHANGING i_bdcdata[].
*    PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                  '=CHNG'
*                              CHANGING i_bdcdata[].
*    PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                  'I_TVARVC_PARAMS-NAME(01)'
*                              CHANGING i_bdcdata[].
*    PERFORM f_bdc_field       USING 'I_TVARVC_PARAMS-MARK(01)'
*                                  abap_true
*                              CHANGING i_bdcdata[].
*    PERFORM f_bdc_dynpro      USING 'SAPMS38V' '1100'
*                              CHANGING i_bdcdata[].
*    PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                  '=SAVE'
*                              CHANGING i_bdcdata[].
*    PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                  'I_TVARVC_PARAMS-LOW(01)'
*                              CHANGING i_bdcdata[].
*    PERFORM f_bdc_field       USING 'I_TVARVC_PARAMS-LOW(01)'
*                                    fp_gv_vbeln
*                              CHANGING i_bdcdata[].
*    PERFORM f_bdc_dynpro      USING 'SAPMS38V' '1100'
*                              CHANGING i_bdcdata[].
*    PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                  '=RETN'
*                              CHANGING i_bdcdata[].
*    PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                  'I_TVARVC_PARAMS-NAME(01)'
*                              CHANGING i_bdcdata[].
** End   of Change for Defect 5267
    CALL TRANSACTION 'STVARV' USING i_bdcdata MODE lv_mode UPDATE lv_update
                              MESSAGES INTO li_bdccall.
    IF sy-subrc IS NOT INITIAL.
      READ TABLE li_bdccall ASSIGNING <lfs_bdccall> WITH KEY msgtyp = lc_error.
      IF sy-subrc = 0.
        MESSAGE ID <lfs_bdccall>-msgid TYPE lc_info NUMBER <lfs_bdccall>-msgnr
         WITH <lfs_bdccall>-msgv1 <lfs_bdccall>-msgv2
              <lfs_bdccall>-msgv3 <lfs_bdccall>-msgv4.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc IS NOT INITIAL
  ENDIF. " IF fp_gv_vbeln IS NOT INITIAL

ENDFORM. " F_UPDATE
*&---------------------------------------------------------------------*
*&      Form  F_BDC_DYNPRO
*&---------------------------------------------------------------------*
*     Perform for populating the BDCDATA with Program name and Screen no
*----------------------------------------------------------------------*
*      -->fp_v_program    Program Name
*      -->fp_v_dynpro     Screen Number
*      <--fp_i_bdcdata    bdc table
*----------------------------------------------------------------------*
FORM f_bdc_dynpro  USING fp_v_program TYPE bdc_prog      " BDC module pool
                         fp_v_dynpro  TYPE bdc_dynr      " BDC Screen number
                CHANGING fp_i_bdcdata TYPE ty_t_bdcdata. " BDC Table
*&-- Local data declaration
  DATA: lwa_bdcdata TYPE bdcdata. " Batch input: New table field structure
  lwa_bdcdata-program  = fp_v_program.
  lwa_bdcdata-dynpro   = fp_v_dynpro.
  lwa_bdcdata-dynbegin = abap_true.
  APPEND lwa_bdcdata TO fp_i_bdcdata.

ENDFORM. " F_BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  F_BDC_FIELD
*&---------------------------------------------------------------------*
*     Perform for populating the BDCDATA using Field name and Field val
*----------------------------------------------------------------------*
*      -->fp_v_name    Field name
*      -->fp_v_value   Field value
*      <--fp_i_bdcdata bdc table
*----------------------------------------------------------------------*
FORM f_bdc_field  USING fp_v_name   TYPE any           " Field name
                        fp_v_value  TYPE any           " Field Value
              CHANGING fp_i_bdcdata TYPE ty_t_bdcdata. " BDC Table.
*&-- Local data declaration
  DATA: lwa_bdcdata TYPE bdcdata. " Batch input: New table field structure
  IF NOT fp_v_value IS INITIAL.
    lwa_bdcdata-fnam = fp_v_name.
    lwa_bdcdata-fval = fp_v_value.
    APPEND lwa_bdcdata TO fp_i_bdcdata.
  ENDIF. " IF NOT fp_v_value IS INITIAL
ENDFORM. " F_BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  F_SALESORG_VALIDATION
*&---------------------------------------------------------------------*
*   sales organisation validation on selection screen.
*----------------------------------------------------------------------*
FORM f_salesorg_validation .
  DATA: lv_vkorg TYPE vkorg. "sales organisation                      "#EC NEEDED

*&-- validation of the sales org value in the selection screen
  SELECT SINGLE
         vkorg     " Sales Organization
         FROM tvko " Organizational Unit: Sales Organizations
         INTO lv_vkorg
         WHERE vkorg = p_vkorg.

  IF sy-subrc NE 0.
    MESSAGE e047(zotc_msg). " Sales Org is not valid.
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_SALESORG_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_DISTCHAN_VALIDATION
*&---------------------------------------------------------------------*
*  distribution channel validation on selection screen.
*----------------------------------------------------------------------*
FORM f_distchan_validation .
  DATA: lv_vtweg TYPE vtweg. "distribution channel                    "#EC NEEDED

*&--validation for the distribution channel in the selection screen
  SELECT SINGLE
         vtweg     " Distribution Channel
         FROM tvtw " Organizational Unit: Distribution Channels
         INTO lv_vtweg
         WHERE vtweg = p_vtweg.

  IF sy-subrc NE 0.
    MESSAGE e048(zotc_msg). " Distribution Channel is not valid
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_DISTCHAN_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_DIVISION_VALIDATION
*&---------------------------------------------------------------------*
*  division validation on selection screen.
*----------------------------------------------------------------------*
FORM f_division_validation .
  DATA: lv_spart TYPE spart. "division                               "#EC NEEDED

*&--validation for division in the selection screen
  SELECT SINGLE
         spart     " Division
         FROM tspa " Organizational Unit: Sales Divisions
         INTO lv_spart
         WHERE spart = p_spart.

  IF sy-subrc NE 0.
    MESSAGE e049(zotc_msg). " Division is not valid.
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_DIVISION_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_CUSTATTRI_VALIDATION
*&---------------------------------------------------------------------*
*  customer attribute validation on selection screen.
*----------------------------------------------------------------------*
FORM f_custattri_validation .
  DATA: lv_attri TYPE katr2. "customer attribute                    "#EC NEEDED

*&--validate the customer attribute in the selection screen
  SELECT SINGLE
         katr2     " Attribute 2
         FROM tvk2 " Attribute 2 (customer master)
         INTO lv_attri
         WHERE katr2 = p_attri.

  IF sy-subrc NE 0.
    MESSAGE e050(zotc_msg). " Customer Attribute is not valid.
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_CUSTATTRI_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_PARTFUNC_VALIDATION
*&---------------------------------------------------------------------*
*   partner function validation on selection screen.
*----------------------------------------------------------------------*
FORM f_partfunc_validation .
  DATA: lv_parvw TYPE parvw. "partner function                   "#EC NEEDED

*&--validate the partner function entered in the selection screen
  SELECT SINGLE
         parvw     " Partner Function
         FROM tpar " Business Partner: Functions
         INTO lv_parvw
         WHERE parvw = p_parvw.

  IF sy-subrc NE 0.
    MESSAGE e054(zotc_msg). " Partner Function not valid.
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_PARTFUNC_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_PARTNER_VALIDATION
*&---------------------------------------------------------------------*
*   Subroutine for partner validation on selection screen.
*----------------------------------------------------------------------*
FORM f_partner_validation .
  DATA: lv_kunnr TYPE kunnr. "partner                          "#EC NEEDED

*&--validate the partner number in the selection screen
  SELECT kunnr     " Customer Number
         UP TO 1 ROWS
         FROM kna1 " General Data in Customer Master
         INTO lv_kunnr
         WHERE kunnr IN s_kunnr.
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE e055(zotc_msg). " Partner Number is not valid.
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_PARTNER_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_DOCTYP_VALIDATION
*&---------------------------------------------------------------------*
*   document type validation on selection screen.
*   as well as fetch the item increment number for the target doc type
*----------------------------------------------------------------------*
*   --> FP_AUART           SALES DOCUMENT TYPE
*----------------------------------------------------------------------*
FORM f_doctyp_validation USING fp_auart TYPE auart. " Sales Document Type
  DATA: lv_auart TYPE auart. "document type                          "#EC NEEDED

*&-- validate target and source document type as well as
* fetch the item increment number for the target document type
  SELECT SINGLE
         auart     " Sales Document Type
         incpo     " Increment of item number in the SD document
         FROM tvak " Sales Document Types
         INTO (lv_auart, gv_incpo)
         WHERE auart = fp_auart.
  IF sy-subrc NE 0.
    MESSAGE e056(zotc_msg). " Document Type is not valid.
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_DOCTYP_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_DELBLOCK_VALIDATION
*&---------------------------------------------------------------------*
*   delivery block validation on selection screen.
*----------------------------------------------------------------------*
FORM f_delblock_validation .
  DATA: lv_lifsp TYPE lifsp. "delivery block                         "#EC NEEDED

*&--validation of the delivery block value entered in the selection screen
  SELECT lifsp     " Default delivery block
         FROM tvls " Deliveries: Blocking Reasons/Criteria
         INTO lv_lifsp
         UP TO 1 ROWS
         WHERE lifsp = p_lifsk.
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE e057(zotc_msg). " Delivery Block is not valid.
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_DELBLOCK_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_FILL_FIELDCAT
*&---------------------------------------------------------------------*
*      Subroutine to fill fieldcatalog table
*----------------------------------------------------------------------*
*     -->  FP_FIELDNAME    Field Name
*     -->  FP_SELTEXT      Selection Text
*----------------------------------------------------------------------*
FORM f_fill_fieldcat  USING  fp_fieldname  TYPE slis_fieldname
                             fp_seltext    TYPE scrtext_l. " Long Field Label

  STATICS lv_count   TYPE sycucol. " Horizontal Cursor Position at PAI

  DATA: lwa_fieldcat TYPE slis_fieldcat_alv. "Fieldcatalog Workarea

  lv_count = lv_count + 1.

  lwa_fieldcat-fieldname  = fp_fieldname.
  lwa_fieldcat-seltext_l  = fp_seltext.
  lwa_fieldcat-col_pos    = lv_count.

  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.

ENDFORM. " F_FILL_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_IDOC_POSTING
*&---------------------------------------------------------------------*
*   For posting IDOCS in basic type ORDERS05 for error in order creation
*----------------------------------------------------------------------*
*      -->FP_LWA_ORDER_HEADER_IN  Order header data
*      -->FP_LI_ORDER_ITEMS_IN    Order item data
*      -->FP_LWA_FINAL            Final shipto soldto combination table
*      <--FP_LWA_SPOOL            Spool for the LOG created
*----------------------------------------------------------------------*
FORM f_idoc_posting  USING    fp_lwa_order_header_in TYPE bapisdhd1            " Communication Fields: Sales and Distribution Document Header
                              fp_li_order_items_in   TYPE /dsd/sv_bapisditm_tt " Communication Fields: Sales and Distribution Document Item
                              fp_lwa_final           TYPE ty_final
                   CHANGING   fp_lwa_spool           TYPE ty_spool.

  CONSTANTS: lc_e1edk01        TYPE edilsegtyp    VALUE 'E1EDK01',  " Segment type
             lc_e1edk14        TYPE edilsegtyp    VALUE 'E1EDK14',  " Segment type
             lc_e1edka1        TYPE edilsegtyp    VALUE 'E1EDKA1',  " Segment type
             lc_e1edp01        TYPE edilsegtyp    VALUE 'E1EDP01',  " Segment type
             lc_e1edp19        TYPE edilsegtyp    VALUE 'E1EDP19',  " Segment type
             lc_action         TYPE edi_qualfi    VALUE '001',      " IDOC object identification such as material no.,customer
             lc_qualf002       TYPE edi_qualfi    VALUE '002',      " IDOC object identification such as material no.,customer
             lc_qualf008       TYPE edi_qualfi    VALUE '008',      " IDOC object identification such as material no.,customer
             lc_qualf007       TYPE edi_qualfi    VALUE '007',      " IDOC object identification such as material no.,customer
             lc_qualf006       TYPE edi_qualfi    VALUE '006',      " IDOC object identification such as material no.,customer
             lc_qualf012       TYPE edi_qualfi    VALUE '012',      " IDOC object identification such as material no.,customer
             lc_qualf019       TYPE edi_qualfi    VALUE '019',      " IDOC object identification such as material no.,customer
             lc_mestyp         TYPE edi_mestyp    VALUE 'ORDERS',   " Message Type
             lc_idoctp         TYPE edi_idoctp    VALUE 'ORDERS05', " Idoc type
             lc_direct         TYPE edi_direct    VALUE '2',        " Direction
             lc_rcvpor         TYPE edi_rcvpor    VALUE 'SAP',      " Receiver Port
             lc_rcvprt         TYPE edi_rcvprt    VALUE 'LS',       " Partner Type
             lc_status         TYPE edi_status    VALUE '53'.       " Status of IDoc

  DATA: li_idoc_data      TYPE STANDARD TABLE OF edi_dd40. " IDoc Data Record for Interface to External System

  DATA: lwa_idoc_data       TYPE edi_dd40, " IDoc Data Record for Interface to External System
        lwa_e1edk01         TYPE e1edk01,  " IDoc: Document header general data
        lwa_e1edk14         TYPE e1edk14,  " IDoc: Document Header Organizational Data
        lwa_e1edka1         TYPE e1edka1,  " IDoc: Document Header Partner Information
        lwa_e1edp01         TYPE e1edp01,  " IDoc: Document Item General Data
        lwa_e1edp19         TYPE e1edp19,  " IDoc: Document Item Object Identification
        lwa_edidc           TYPE edi_dc40. " IDoc Control Record for Interface to External System

  DATA: lv_logsys TYPE logsys,       " Receiver Partner Number
        lv_docnum TYPE edidc-docnum. " IDoc number

  FIELD-SYMBOLS: <lfs_order_items_in>  TYPE bapisditm. " Communication Fields: Sales and Distribution Document Item.

*&--populating mandatory segment E1EDK01
* Document type
  lwa_e1edk01-bsart      = fp_lwa_order_header_in-doc_type.

  lwa_idoc_data-segnam   = lc_e1edk01.
  lwa_idoc_data-sdata    = lwa_e1edk01.
  APPEND lwa_idoc_data TO li_idoc_data.
  CLEAR: lwa_e1edk01,
         lwa_idoc_data.
*&--populating segment e1edk14
* Sales organisation
  lwa_e1edk14-qualf      = lc_qualf008.
  lwa_e1edk14-orgid      = fp_lwa_order_header_in-sales_org.

  lwa_idoc_data-segnam   = lc_e1edk14.
  lwa_idoc_data-sdata    = lwa_e1edk14.
  APPEND lwa_idoc_data TO li_idoc_data.
  CLEAR: lwa_e1edk14,
         lwa_idoc_data.
* Distribution channel
  lwa_e1edk14-qualf      = lc_qualf007.
  lwa_e1edk14-orgid      = fp_lwa_order_header_in-distr_chan.

  lwa_idoc_data-segnam   = lc_e1edk14.
  lwa_idoc_data-sdata    = lwa_e1edk14.
  APPEND lwa_idoc_data TO li_idoc_data.
  CLEAR: lwa_e1edk14,
         lwa_idoc_data.
* Division
  lwa_e1edk14-qualf      = lc_qualf006.
  lwa_e1edk14-orgid      = fp_lwa_order_header_in-division.

  lwa_idoc_data-segnam   = lc_e1edk14.
  lwa_idoc_data-sdata    = lwa_e1edk14.
  APPEND lwa_idoc_data TO li_idoc_data.
  CLEAR: lwa_e1edk14,
         lwa_idoc_data.
* Document type
  lwa_e1edk14-qualf      = lc_qualf012.
  lwa_e1edk14-orgid      = fp_lwa_order_header_in-doc_type.

  lwa_idoc_data-segnam   = lc_e1edk14.
  lwa_idoc_data-sdata    = lwa_e1edk14.
  APPEND lwa_idoc_data TO li_idoc_data.
  CLEAR: lwa_e1edk14,
         lwa_idoc_data.

* Customer purchase order type
  lwa_e1edk14-qualf      = lc_qualf019.
  lwa_e1edk14-orgid      = fp_lwa_order_header_in-po_method.

  lwa_idoc_data-segnam   = lc_e1edk14.
  lwa_idoc_data-sdata    = lwa_e1edk14.
  APPEND lwa_idoc_data TO li_idoc_data.
  CLEAR: lwa_e1edk14,
         lwa_idoc_data.

*&--populating segment e1edka1

* Partner type and partner number
  CLEAR: lwa_e1edka1,
         lwa_idoc_data.

  lwa_e1edka1-parvw      = c_soldto.
  lwa_e1edka1-partn      = fp_lwa_final-soldto.

  lwa_idoc_data-segnam   = lc_e1edka1.
  lwa_idoc_data-sdata    = lwa_e1edka1.
  APPEND lwa_idoc_data TO li_idoc_data.
  CLEAR: lwa_e1edka1,
         lwa_idoc_data.

  lwa_e1edka1-parvw      = c_shipto.
  lwa_e1edka1-partn      = fp_lwa_final-shipto.

  lwa_idoc_data-segnam   = lc_e1edka1.
  lwa_idoc_data-sdata    = lwa_e1edka1.
  APPEND lwa_idoc_data TO li_idoc_data.

*&-- populating the segment e1edkp01

  LOOP AT fp_li_order_items_in ASSIGNING <lfs_order_items_in>.
*     item number
    lwa_e1edp01-posex    = <lfs_order_items_in>-itm_number.
*     action
    lwa_e1edp01-action   = lc_action.
*     target quantity
    lwa_e1edp01-menge    = <lfs_order_items_in>-target_qty.
*     target quantity unit
    lwa_e1edp01-menee    = <lfs_order_items_in>-target_qu.

    lwa_idoc_data-segnam = lc_e1edp01.
    lwa_idoc_data-sdata  = lwa_e1edp01.
    APPEND lwa_idoc_data TO li_idoc_data.
    CLEAR: lwa_idoc_data,
           lwa_e1edp01.

*&-- populating material and qualifier
    lwa_e1edp19-qualf    = lc_qualf002.
    lwa_e1edp19-idtnr    = <lfs_order_items_in>-material.
    lwa_idoc_data-segnam = lc_e1edp19.
    lwa_idoc_data-sdata  = lwa_e1edp19.
    APPEND lwa_idoc_data TO li_idoc_data.
    CLEAR: lwa_idoc_data,
           lwa_e1edp19.
*********************************************************
  ENDLOOP. " LOOP AT fp_li_order_items_in ASSIGNING <lfs_order_items_in>

*&-- Initialize Receiver Partner Number
  CLEAR lv_logsys.

*&-- Retrieve the Receiver Partner Number (= own logical system)
  CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
    IMPORTING
      own_logical_system             = lv_logsys
    EXCEPTIONS
      own_logical_system_not_defined = 1
      OTHERS                         = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF. " IF sy-subrc <> 0

*&-- Populate Receiver Port
  CLEAR lwa_edidc.
  CONCATENATE lc_rcvpor sy-sysid INTO lwa_edidc-rcvpor.

*&--  populating control records
  lwa_edidc-mestyp = lc_mestyp. "Message Type
  lwa_edidc-idoctyp = lc_idoctp. "IDoc Type
  lwa_edidc-status = lc_status. "IDoc Status
  lwa_edidc-direct = lc_direct. "Direction for IDOC
  lwa_edidc-rcvprt = lc_rcvprt. "Receiver partner Type
  lwa_edidc-rcvprn = lv_logsys. "Receiver Partner No
  lwa_edidc-sndpor = lwa_edidc-rcvpor.
  lwa_edidc-sndprt = lc_rcvprt. "Sender Partner type
  lwa_edidc-sndprn = lv_logsys. "Sender Partner No

  CALL FUNCTION 'IDOC_INBOUND_SINGLE'
    EXPORTING
      pi_idoc_control_rec_40  = lwa_edidc
      pi_do_commit            = abap_true
    IMPORTING
      pe_idoc_number          = lv_docnum
    TABLES
      pt_idoc_data_records_40 = li_idoc_data
    EXCEPTIONS
      idoc_not_saved          = 1
      OTHERS                  = 2.
  IF sy-subrc = 0.
    fp_lwa_spool-idoc_num = lv_docnum.
  ENDIF. " IF sy-subrc = 0
  CLEAR: lv_docnum,
         lwa_edidc,
         li_idoc_data.
ENDFORM. " F_IDOC_POSTING
*& --> Begin of Delete for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
*** These subroutines can be deleted as they are not used anywhere.
****&---------------------------------------------------------------------*
****&      Form  F_DELETE_ORDERITEMS
****&---------------------------------------------------------------------*
****   Deleting order items based on delivery status from VBUP
****----------------------------------------------------------------------*
****      -->FP_I_VBUP     Order item status
****      <--FP_I_VBAP     Order items
****----------------------------------------------------------------------*
***FORM f_delete_orderitems  USING fp_i_vbup TYPE ty_t_vbup
***                       CHANGING fp_i_vbap TYPE ty_t_vbap.
***
***  CONSTANTS: lc_lfsta_c TYPE lfsta VALUE 'C', " Delivery status COMPLETE
***             lc_lfsta_b TYPE lfsta VALUE 'B'. " Delivery status PARTIAL
***
***************************************************************************
***  FIELD-SYMBOLS: <lfs_vbup> TYPE ty_vbup,
***                 <lfs_vbap> TYPE ty_vbap.
***************************************************************************
***  LOOP AT fp_i_vbap ASSIGNING <lfs_vbap>.
***    READ TABLE fp_i_vbup ASSIGNING <lfs_vbup> WITH KEY vbeln = <lfs_vbap>-vbeln
***                                                       posnr = <lfs_vbap>-posnr
***                                                       BINARY SEARCH.
***    IF sy-subrc = 0.
****&-- filtering fields only fit for complete an partial delivery
***      IF <lfs_vbup>-lfsta <> lc_lfsta_b
***     AND <lfs_vbup>-lfsta <> lc_lfsta_c.
***        CLEAR <lfs_vbap>-posnr.
***      ENDIF. " IF <lfs_vbup>-lfsta <> lc_lfsta_b
***    ENDIF. " IF sy-subrc = 0
***  ENDLOOP. " LOOP AT fp_i_vbap ASSIGNING <lfs_vbap>
***
****&-- delete the entries where delivery
**** status are not 'B' or 'C'.
***  DELETE fp_i_vbap WHERE posnr IS INITIAL.
***
***ENDFORM. " F_DELETE_ORDERITEMS
*& <-- End of Delete for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_ORDERHDRS
*&---------------------------------------------------------------------*
*   Deleting order headers based on entries in the item table
*----------------------------------------------------------------------*
*      -->FP_I_VBAP     Order Items
*      <--FP_I_VBAK     Order numbers
*----------------------------------------------------------------------*
FORM f_delete_orderhdrs  USING    fp_i_vbap TYPE ty_t_vbap
                         CHANGING fp_i_vbak TYPE ty_t_vbak.

  FIELD-SYMBOLS: <lfs_vbak> TYPE ty_vbak.

  LOOP AT fp_i_vbak ASSIGNING <lfs_vbak>.
    READ TABLE fp_i_vbap TRANSPORTING NO FIELDS WITH KEY vbeln = <lfs_vbak>-vbeln
                                                         BINARY SEARCH.
    IF sy-subrc <> 0.
      CLEAR <lfs_vbak>-vkorg.
    ENDIF. " IF sy-subrc <> 0
  ENDLOOP. " LOOP AT fp_i_vbak ASSIGNING <lfs_vbak>
  DELETE fp_i_vbak WHERE vkorg IS INITIAL.
ENDFORM. " F_DELETE_ORDERHDRS
*&---------------------------------------------------------------------*
*&      Form  F_DELETE_PARTNERS
*&---------------------------------------------------------------------*
*   Deleting partners based on the header table entries
*----------------------------------------------------------------------*
*      -->FP_I_VBAK      Order Numbers
*      <--FP_I_VBPA      Partners
*----------------------------------------------------------------------*
FORM f_delete_partners  USING fp_i_vbak TYPE ty_t_vbak
                     CHANGING fp_i_vbpa TYPE ty_t_vbpa.

  FIELD-SYMBOLS: <lfs_vbpa> TYPE ty_vbpa.

  LOOP AT fp_i_vbpa ASSIGNING <lfs_vbpa>.
    READ TABLE fp_i_vbak TRANSPORTING NO FIELDS WITH KEY vbeln = <lfs_vbpa>-vbeln
                                                         BINARY SEARCH.
    IF sy-subrc <> 0 .
      CLEAR <lfs_vbpa>-parvw.
    ENDIF. " IF sy-subrc <> 0
  ENDLOOP. " LOOP AT fp_i_vbpa ASSIGNING <lfs_vbpa>

*&-- Deleting orders with specific partners not required for further processing
  DELETE fp_i_vbpa WHERE parvw IS INITIAL.
ENDFORM. " F_DELETE_PARTNERS

*--> Begin of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
*&---------------------------------------------------------------------*
*&      Form  F_DELETE_DELIVERY
*&---------------------------------------------------------------------*
*    Delete deliveries based on partners available
*----------------------------------------------------------------------*
*      -->FP_I_VBPA  table for VBPA
*      <--FP_I_LIPS  table for LIPS
*----------------------------------------------------------------------*
*FORM f_delete_delivery  USING fp_i_vbpa TYPE ty_t_vbpa
*                     CHANGING fp_i_lips TYPE ty_t_lips.
*
*  FIELD-SYMBOLS: <lfs_lips> TYPE ty_lips.
*
*  LOOP AT fp_i_lips ASSIGNING <lfs_lips>.
*    READ TABLE fp_i_vbpa TRANSPORTING NO FIELDS WITH KEY vbeln = <lfs_lips>-vgbel
*                                                         BINARY SEARCH.
*    IF sy-subrc <> 0.
*      CLEAR <lfs_lips>-matnr.
*    ENDIF. " IF sy-subrc <> 0
*  ENDLOOP. " LOOP AT fp_i_lips ASSIGNING <lfs_lips>
*  DELETE fp_i_lips WHERE matnr IS INITIAL.
*ENDFORM. " F_DELETE_DELIVERY

*<-- End of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
*&---------------------------------------------------------------------*
*&      Form  F_FILTER_CUSTOMER
*&---------------------------------------------------------------------*
*  Delete partners based on auto-replenishment attribute for a customer
*----------------------------------------------------------------------*
*      -->FP_I_KNA1      Customer Master
*      <--FP_I_VBPA      Partners
*----------------------------------------------------------------------*
FORM f_filter_customer  USING fp_i_kna1   TYPE ty_t_kna1
                     CHANGING fp_i_vbpa   TYPE ty_t_vbpa.

  FIELD-SYMBOLS: <lfs_vbpa> TYPE ty_vbpa.

  LOOP AT fp_i_vbpa ASSIGNING <lfs_vbpa>.
    READ TABLE fp_i_kna1 TRANSPORTING NO FIELDS WITH KEY kunnr = <lfs_vbpa>-kunnr
                                                         BINARY SEARCH.
    IF sy-subrc NE 0.
*&-- the partner is not for auto-replenishments
      CLEAR <lfs_vbpa>-kunnr.
    ENDIF. " IF sy-subrc NE 0
  ENDLOOP. " LOOP AT fp_i_vbpa ASSIGNING <lfs_vbpa>

*&-- delete the not required entries
  DELETE fp_i_vbpa WHERE kunnr IS INITIAL.
ENDFORM. " F_FILTER_CUSTOMER
*&---------------------------------------------------------------------*
*&      Form  F_BAPI_POSTING
*&---------------------------------------------------------------------*
*   Calling BAPI to create the consignment fill up order
*----------------------------------------------------------------------*
*      -->FP_I_FINAL              Final table consisting of partner combinations
*      -->FP_I_MATERIAL           Collected material table
*      -->FP_WA_ORDER_HEADER_IN   Header order data
*      <--FP_I_SPOOL              Spool for the LOG
*----------------------------------------------------------------------*
FORM f_bapi_posting  USING fp_i_final            TYPE ty_t_final
                           fp_i_material         TYPE ty_t_matnr
*& --> Begin of Delete for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
*                           fp_wa_order_header_in TYPE bapisdhd1 " Communication Fields: Sales and Distribution Document Header
*& <-- End   of Delete for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
                           fp_v_flag            TYPE flag " General Flag
* Begin of R3
                           fp_i_enh_status      TYPE ty_t_zdev_enh_status
* End of R3
*& --> End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
                  CHANGING fp_i_spool            TYPE ty_t_spool
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
                           fp_wa_order_header_in TYPE bapisdhd1. " Communication Fields: Sales and Distribution Document Header
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016

  DATA: li_return         TYPE TABLE OF bapiret2,  " Return Parameter
        li_order_items_in TYPE TABLE OF bapisditm, " Communication Fields: Sales and Distribution Document Item
        li_order_partner  TYPE TABLE OF bapiparnr, " Communications Fields: SD Document Partner: WWW
        li_order_schedule TYPE TABLE OF bapischdl, " Communication Fields for Maintaining SD Doc. Schedule Lines
*---> Begin of insert by PDEBARU for INC0424007-01
        li_order_items_tmp TYPE TABLE OF bapisditm. " Communication Fields: Sales and Distribution Document Item

*<--- End of insert by PDEBARU for INC0424007-01

  DATA: lwa_order_items_in  TYPE bapisditm,       " Communication Fields: Sales and Distribution Document Item
        lwa_order_partner   TYPE bapiparnr,       " Communications Fields: SD Document Partner: WWW
        lwa_order_schedule  TYPE bapischdl,       " Communication Fields for Maintaining SD Doc. Schedule Lines
        lwa_spool           TYPE ty_spool,        " Structure for spool
        lwa_final           TYPE ty_final,        " final table
        lwa_status          TYPE zdev_enh_status, " Enhancement Status
        lv_spras            TYPE spras,           " Language Key
        lv_lang             TYPE char2,           " Lang of type CHAR2
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
        lwa_header_inx      TYPE bapisdhd1x. " Checkbox Fields for Sales and Distribution Document Header
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016

  CONSTANTS : lc_criteria TYPE z_criteria VALUE 'BSTNK_LANG'. " Enh. Criteria

  FIELD-SYMBOLS: <lfs_mat>  TYPE ty_matnr. " for material table

  DATA: lv_vbeln  TYPE bapivbeln-vbeln, " Sales Document
        lv_tabix  TYPE sy-tabix,        " Index of Internal Tables
        lv_lines  TYPE sy-tabix,        " Index of Internal Tables
        lv_posnr  TYPE posnr_va.        " Sales Document Item

  IF fp_v_flag IS NOT INITIAL.
    SORT fp_i_final BY  soldto shipto vbeln.
    DELETE ADJACENT DUPLICATES FROM fp_i_final COMPARING soldto shipto.
  ENDIF. " IF fp_v_flag IS NOT INITIAL

  LOOP AT fp_i_final INTO lwa_final.
    READ TABLE fp_i_material TRANSPORTING NO FIELDS WITH KEY soldto = lwa_final-soldto
                                                             shipto = lwa_final-shipto
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
*& --> Begin of Delete for Defect#10112 By U024694 on 17-Jul-2019
* Don't consider sales order while reading the above table because it is not required.
* Requirement was/is to club ZKE order (orders in FP_I_MATERIAL)based on Sold-to & Ship-to Only.
*                                                             vbeln  = lwa_final-vbeln
*& <-- End   of Delete for Defect#10112 By U024694 on 17-Jul-2019
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016

                                                             BINARY SEARCH.

    IF sy-subrc = 0.
      lv_tabix = sy-tabix.
*&--populating items in the table order_items_in containing
*item num, material, quantity and unit
      lv_lines = 1.
      LOOP AT fp_i_material ASSIGNING <lfs_mat> FROM lv_tabix.
        IF <lfs_mat>-soldto <> lwa_final-soldto
        OR <lfs_mat>-shipto <> lwa_final-shipto.
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
*        OR <lfs_mat>-vbeln  <> lwa_final-vbeln.
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
          EXIT.
        ENDIF. " IF <lfs_mat>-soldto <> lwa_final-soldto
*       DELETE FP_I_FINAL


        IF <lfs_mat>-vbeln  <> lwa_final-vbeln.
          lv_lines = lv_lines + 1.
        ENDIF. " IF <lfs_mat>-vbeln <> lwa_final-vbeln
        lv_posnr =  lv_posnr + gv_incpo.
        lwa_order_schedule-itm_number = lwa_order_items_in-itm_number = lv_posnr.
        lwa_order_items_in-material   = <lfs_mat>-material.
        lwa_order_schedule-req_qty    = lwa_order_items_in-target_qty = <lfs_mat>-target_qty.
        lwa_order_items_in-target_qu  = <lfs_mat>-target_qu.


* Begin of R3
        lwa_order_items_in-purch_no_c = <lfs_mat>-bstnk.
        lwa_order_items_in-purch_date = <lfs_mat>-bstdk.
* End of R3
        APPEND lwa_order_items_in TO li_order_items_in.
        APPEND lwa_order_schedule TO li_order_schedule.

        CLEAR: lwa_order_items_in,
               lwa_order_schedule.
      ENDLOOP. " LOOP AT fp_i_material ASSIGNING <lfs_mat> FROM lv_tabix
      CLEAR lv_posnr.
    ENDIF. " IF sy-subrc = 0
    CLEAR lv_tabix.

*&--populating the partner table and sold to party
    lwa_order_partner-partn_role = c_soldto.
    lwa_order_partner-partn_numb = lwa_final-soldto.
    lwa_spool-kunnr_sp           = lwa_final-soldto.

    APPEND lwa_order_partner TO li_order_partner.
    CLEAR lwa_order_partner.
*&--populating the partner table with ship to party
    lwa_order_partner-partn_role = c_shipto.
    lwa_order_partner-partn_numb = lwa_final-shipto.
    lwa_spool-kunnr_sh           = lwa_final-shipto.
    SELECT SINGLE spras INTO lv_spras FROM kna1 WHERE kunnr EQ lwa_final-shipto.
    APPEND lwa_order_partner TO li_order_partner.
    CLEAR lwa_order_partner.

*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
    fp_wa_order_header_in-purch_no_c = lwa_final-bstkd.
* If the sales order is created for CANADA
    IF fp_v_flag IS NOT INITIAL.
      fp_wa_order_header_in-ordcomb_in = cb_order.
      lwa_header_inx-ordcomb_in        = abap_true.
    ENDIF. " IF fp_v_flag IS NOT INITIAL
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016

* Begin of R3
    CALL FUNCTION 'CONVERSION_EXIT_ISOLA_OUTPUT'
      EXPORTING
        input  = lv_spras
      IMPORTING
        output = lv_lang.

*    DESCRIBE TABLE li_order_items_in LINES lv_lines.
    IF lv_lines GT 1.
      READ TABLE fp_i_enh_status INTO lwa_status WITH KEY criteria = lc_criteria
                                                      sel_low  = lv_lang.
      IF sy-subrc EQ 0.
        MOVE lwa_status-sel_high TO fp_wa_order_header_in-purch_no_c.
        lwa_header_inx-purch_no_c = 'X'.
        fp_wa_order_header_in-purch_date = sy-datum.
        lwa_header_inx-purch_date = 'X'.
      ELSE. " ELSE -> IF sy-subrc EQ 0
        READ TABLE fp_i_enh_status INTO lwa_status WITH KEY criteria = lc_criteria
                                                        sel_low  = 'EN'.
        IF sy-subrc EQ 0.
          MOVE lwa_status-sel_high TO fp_wa_order_header_in-purch_no_c.
          lwa_header_inx-purch_no_c = 'X'.
          fp_wa_order_header_in-purch_date = sy-datum.
          lwa_header_inx-purch_date = 'X'.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc EQ 0
    ELSE. " ELSE -> IF lv_lines GT 1
      IF <lfs_mat>-bstnk IS ASSIGNED.
        fp_wa_order_header_in-purch_no_c =   <lfs_mat>-bstnk.
        lwa_header_inx-purch_no_c = 'X'.
        fp_wa_order_header_in-purch_date = <lfs_mat>-bstdk.
        lwa_header_inx-purch_date = 'X'.
      ENDIF. " IF <lfs_mat>-bstnk IS ASSIGNED

    ENDIF. " IF lv_lines GT 1
* End of R3
    CLEAR : lv_lines ,lv_spras,lwa_status.
*&--passing the tables and stuctures to BAPI to create sales order
*    of target doc type ZKB
    IF  li_order_items_in[] IS NOT INITIAL. " Defect # 4255
*---> Begin of insert by PDEBARU for INC0424007-01
      li_order_items_tmp[] = li_order_items_in[].
      CLEAR lv_lines.
      DESCRIBE TABLE  li_order_items_tmp LINES lv_lines.
      IF lv_lines GT 1.
** Checking if the line items have same PO or different
        DELETE ADJACENT DUPLICATES FROM  li_order_items_tmp COMPARING purch_no_c.
        CLEAR lv_lines.
        DESCRIBE TABLE  li_order_items_tmp LINES lv_lines.
        IF lv_lines = 1.
          READ TABLE li_order_items_tmp INTO lwa_order_items_in INDEX 1.
          IF sy-subrc = 0.
** Passing the item PO number to the Header PO Number
            fp_wa_order_header_in-purch_no_c =   lwa_order_items_in-purch_no_c.
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF lv_lines = 1
      ELSEIF lv_lines = 1.
        READ TABLE li_order_items_tmp INTO lwa_order_items_in INDEX 1.
        IF sy-subrc = 0.
          fp_wa_order_header_in-purch_no_c =   lwa_order_items_in-purch_no_c.
          lwa_header_inx-purch_no_c        = abap_true.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF lv_lines GT 1
*<--- End of insert by PDEBARU for INC0424007-01

      CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
        EXPORTING
          order_header_in    = fp_wa_order_header_in
*& --> Begin of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
          order_header_inx   = lwa_header_inx
*& <-- End   of Insert for D2_OTC_EDD_0165_Defect#1882 By SAGARWA1 on 12-Aug-2016
        IMPORTING
          salesdocument      = lv_vbeln
        TABLES
          return             = li_return
          order_items_in     = li_order_items_in
          order_partners     = li_order_partner
          order_schedules_in = li_order_schedule.
    ENDIF. " IF li_order_items_in[] IS NOT INITIAL
*&--Populating the document creation number to the message log
    IF lv_vbeln IS NOT INITIAL.
*&--BAPI commit
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
      lwa_spool-vbeln = lv_vbeln.
    ENDIF. " IF lv_vbeln IS NOT INITIAL

*&--If BAPI posting and creation of consignment
*  issue order is not successful, posting IDOC for the same
    IF lv_vbeln IS INITIAL AND
       li_order_items_in IS NOT INITIAL. " Defect # 4255
*&--BAPI rollback
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*&--populating the structures for idoc posting
      PERFORM f_idoc_posting USING fp_wa_order_header_in
                                   li_order_items_in
                                   lwa_final
                          CHANGING lwa_spool.
    ENDIF. " IF lv_vbeln IS INITIAL AND

*&--APPENDING THE DETAILS TO THE LOG
    APPEND lwa_spool TO fp_i_spool.
    CLEAR: lwa_spool,
           lv_vbeln.

*&-- Clearing tables
    CLEAR: li_order_items_in,
           lv_vbeln,
           li_order_schedule,
           li_order_partner.
  ENDLOOP. " LOOP AT fp_i_final INTO lwa_final

ENDFORM. " F_BAPI_POSTING
*&---------------------------------------------------------------------*
*&      Form  F_ALV_DISPLAY
*&---------------------------------------------------------------------*
*    Spool will be displayed as ALV in the log
*----------------------------------------------------------------------*
*      -->FP_I_SPOOL   Spool for the LOG
*----------------------------------------------------------------------*
FORM f_alv_display  USING    fp_i_spool TYPE ty_t_spool.

  DATA: lwa_layout  TYPE slis_layout_alv. " Layout

  PERFORM f_fill_fieldcat USING:
          'KUNNR_SP'         'SOLD-TO',
          'KUNNR_SH'         'SHIP-TO',
          'VBELN'            'SALES DOC',
          'IDOC_NUM'         'IDOC DOC NUM'.

  lwa_layout-colwidth_optimize = abap_true.

  IF sy-batch = abap_true.
    CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
      EXPORTING
        i_callback_program = sy-repid
        is_layout          = lwa_layout
        it_fieldcat        = i_fieldcat[]
      TABLES
        t_outtab           = fp_i_spool[]
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
      MESSAGE i000 WITH 'Report Display Failed'(002).
      LEAVE LIST-PROCESSING.
    ENDIF. " IF sy-subrc <> 0
  ELSE. " ELSE -> IF sy-batch = abap_true
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program = sy-repid
        is_layout          = lwa_layout
        it_fieldcat        = i_fieldcat[]
      TABLES
        t_outtab           = fp_i_spool[]
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
    IF sy-subrc EQ 0.
      MESSAGE i000 WITH 'Report Display Failed'(002).
      LEAVE LIST-PROCESSING.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-batch = abap_true
ENDFORM. " F_ALV_DISPLAY

*--> Begin of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
*&---------------------------------------------------------------------*
*&      Form  F_DELETE_DELITEMS
*&---------------------------------------------------------------------*
*   Removing delivery items based on sales order items
*----------------------------------------------------------------------*
*      -->FP_I_VBAP     Sales order items
*      <--FP_I_LIPS     Delivery items
*----------------------------------------------------------------------*
*FORM f_delete_delitems  USING    fp_i_vbap TYPE ty_t_vbap
*                        CHANGING fp_i_lips TYPE ty_t_lips.
*  FIELD-SYMBOLS: <lfs_lips> TYPE ty_lips.
*
*  LOOP AT fp_i_lips ASSIGNING <lfs_lips>.
*    READ TABLE fp_i_vbap TRANSPORTING NO FIELDS WITH KEY vbeln = <lfs_lips>-vgbel
*                                                         posnr = <lfs_lips>-vgpos
*                                                         BINARY SEARCH.
*    IF sy-subrc <> 0.
*      CLEAR <lfs_lips>-posnr.
*    ENDIF. " IF sy-subrc <> 0
*  ENDLOOP. " LOOP AT fp_i_lips ASSIGNING <lfs_lips>
*
*  DELETE fp_i_lips WHERE posnr IS INITIAL.
*ENDFORM. " F_DELETE_DELITEMS

*<-- End of Delete for D3_OTC_EDD_0165_Defect#4255 by AMOHAPA on 21-Nov-2017
*&---------------------------------------------------------------------*
*&      Form  F_SALESORDER_VALIDATION
*&---------------------------------------------------------------------*
*     Sales order number validation
*----------------------------------------------------------------------*
FORM f_salesorder_validation .
*&--validate the sales order number in the selection screen
  SELECT SINGLE
         vbeln     " Sales Document
         FROM vbak " Sales Document: Header Data
         INTO gv_vbeln
         WHERE vbeln IN s_vbeln.

  IF sy-subrc NE 0.
    MESSAGE e059(zotc_msg). " Sales Order Number is not valid.
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_SALESORDER_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_AUTH_CHECK
*&---------------------------------------------------------------------*
*      Authorisation Check for the TCODE STVARV
*----------------------------------------------------------------------*
FORM f_auth_check .
*  Check User Authorisation for TCODE STVARV
  CONSTANTS: lc_tcode TYPE tcode VALUE 'STVARV'. " Transaction Code

  CALL FUNCTION 'AUTHORITY_CHECK_TCODE' " Perform Authority check
    EXPORTING
      tcode  = lc_tcode
    EXCEPTIONS
      ok     = 0
      not_ok = 2
      OTHERS = 3.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE e060(zotc_msg) WITH sy-uname lc_tcode. " User & not authorised to use transaction &
  ENDIF. " IF sy-subrc IS NOT INITIAL
ENDFORM. " F_AUTH_CHECK
** Begin   of Change for Defect 5267
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_BDCDATA
*&---------------------------------------------------------------------*
*       Subroutine to create BDC data
*----------------------------------------------------------------------*
*      -->FP_GV_VBELN  text
*      <--P_I_BDCDATA  text
*----------------------------------------------------------------------*
FORM f_create_bdcdata  USING fp_gv_vbeln TYPE vbeln " Sales and Distribution Document Number
                    CHANGING fp_bdcdata  TYPE tab_bdcdata.
  DATA:
     lv_fnam TYPE fnam_____4, " Field name
     lv_fval TYPE bdc_fval.   " BDC field value

  PERFORM f_populate_bdcdata USING:
        'SAPMS38V'    '1100'                     abap_true,
        'BDC_OKCODE'  '=TOGGLE'                  space,
        'SAPMS38V'    '1100'                     abap_true,
        'BDC_CURSOR'  'I_TVARVC_PARAMS-NAME(01)' space,
        'BDC_OKCODE'  '=SINGLE'                  space.

  CLEAR lv_fval. lv_fval = abap_true.
  PERFORM f_populate_bdcdata USING:
        'SAPMS38V'    '1001'             abap_true,
        'BDC_CURSOR'  'RB_TYPE_S'        space,
        'RB_TYPE_P'    space             space,
        'RB_TYPE_S'    lv_fval           space.

  CLEAR lv_fval. lv_fval = gv_name.
  PERFORM f_populate_bdcdata USING:
        'TVARVC-NAME'  lv_fval        space,
        'BDC_OKCODE'  '=CHNG'         space.

  CLEAR lv_fval. lv_fval = fp_gv_vbeln.
  PERFORM f_populate_bdcdata USING:
        'SAPMS38V'     '0600'           abap_true,
        'BDC_CURSOR'   'SEL_VAL-LOW'    space,
        'SEL_VAL-LOW'  lv_fval          space,
        'BDC_OKCODE'   '=USAV'          space,
        'SAPMS38V'     '1001'           abap_true,
        'BDC_CURSOR'   'TVARVC-NAME'    space,
        'BDC_OKCODE'   '=EXIT'          space,
        'SAPMS38V'     '1100'           abap_true,
        'BDC_CURSOR'   'I_TVARVC_PARAMS-NAME(01)'    space,
        'BDC_OKCODE'   '=EXIT'          space.

ENDFORM. " F_CREATE_BDCDATA
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_BDCDATA
*&---------------------------------------------------------------------*
*       Subroutine to populate BDC data
*----------------------------------------------------------------------*
*      -->P_2545   text
*      -->P_2546   text
*      -->P_ABAP_TRUE  text
*----------------------------------------------------------------------*
FORM f_populate_bdcdata  USING fp_name   TYPE bdc_prog   " BDC module pool
                               fp_val    TYPE any        " bdc_fval   " BDC Screen number
                               fp_dynp_s TYPE bdc_start. " BDC screen start
  DATA lwa_bdcdata TYPE bdcdata. " Batch input: New table field structure
  CLEAR lwa_bdcdata.

  IF NOT fp_dynp_s IS INITIAL.
    lwa_bdcdata-program = fp_name.
    lwa_bdcdata-dynpro = fp_val.
    lwa_bdcdata-dynbegin = fp_dynp_s.
  ELSE. " ELSE -> IF NOT fp_dynp_s IS INITIAL
    lwa_bdcdata-fnam = fp_name.
    lwa_bdcdata-fval = fp_val.
  ENDIF. " IF NOT fp_dynp_s IS INITIAL
  APPEND lwa_bdcdata TO i_bdcdata.

ENDFORM. " F_POPULATE_BDCDATA
** End   of Change for Defect 5267
*& -->Begin for Insert for Defect#1058 by SAGARWA1
*&---------------------------------------------------------------------*
*&      Form  F_SALESOFC_VALIDATION
*&---------------------------------------------------------------------*
*       Validate Sales Office on Selection screen
*----------------------------------------------------------------------*
FORM f_salesofc_validation .
  DATA: lv_vkbur TYPE vkbur. "Sales Office

*&--validation for Sales Office in the selection screen
  SELECT SINGLE
         vkbur      " Sales Office
         FROM tvbur " Organizational Unit: Sales Offices
         INTO lv_vkbur
         WHERE vkbur = p_vkbur.

  IF sy-subrc NE 0.
    CLEAR : lv_vkbur.
    MESSAGE e908(zotc_msg). " Sales Office is not Valid.
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_SALESOFC_VALIDATION
*& -->End   of Insert for Defect#1058 by SAGARWA1
