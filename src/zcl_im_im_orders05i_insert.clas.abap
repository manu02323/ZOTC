class ZCL_IM_IM_ORDERS05I_INSERT definition
  public
  final
  create public .

public section.
*"* public components of class ZCL_IM_IM_ORDERS05I_INSERT
*"* do not include other source files here!!!

  interfaces IF_EX_IDOC_DATA_INSERT .
protected section.
*"* protected components of class ZCL_IM_IM_ORDERS05I_INSERT
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_IM_ORDERS05I_INSERT
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_IM_ORDERS05I_INSERT IMPLEMENTATION.


METHOD if_ex_idoc_data_insert~fill.
*************************************************************************
** PROGRAM    :  OTC_IDD_0009_SAP_Inbound sales order EDI 850           *
** TITLE      :  SAP_Inbound sales order EDI 850                        *
** DEVELOPER  :  SHAMMI PURI                                            *
** OBJECT TYPE:  BADI METHOD                                            *
** SAP RELEASE:  SAP ECC 6.0                                            *
**----------------------------------------------------------------------*
** WRICEF ID:  OTC_IDD_0009                                             *
**----------------------------------------------------------------------*
** DESCRIPTION:
** FOLLOWING FUNCTIONALITIES ARE ACHIEVED BY IMPLEMETING BELOW BADI IMP:
** For Inbound Message type ORDERS05. Get Sales organization ,
** Distribution Channel And division. If partner function is AG use the
** External LIFNR to get internal number and retrieve date. If partner
** is WE get AG first then retrieve data.
**----------------------------------------------------------------------*
** MODIFICATION HISTORY:                                                *
**======================================================================*
** DATE          USER      TRANSPORT      DESCRIPTION                   *
** ===========  ========   =========  ==================================*
** 06-June-2012   SPURI     E1DK903577    Initial Development
** 07-Dec- 2012   SPURI     E1DK907538    CR232:populate Reagent rental
**                                        ref (QUAL 043 segment E1EDP02)
** 01-Jan- 2013   SPURI     E1DK908881    Defect 1948:1)Commented Logic for
**                                        CR-232 as Internal SAP Number is
**                                        prepopulated in IDOC Data table.
**                                        2)Modified logic to retrieve sales
**                                        Info based on KUNNR not INPNR as
**                                        per FSTS.
** 13-Mar-2013  DRAJPUT    E1DK909436     CR#298 Remove Filter to check if
**                                        Sales Organization, distribution
**                                        channel and division are blank
**                                        if EDPAR entry is missing.
** 27-Jan-2014  SGHOSH     E1DK912631     CR#1110: LV_FLAG added & Exported
**                                        to prevent unnecessary triggering
**                                        of User-Exit.(Retrofit done from
**                                        D1 to D2 for CR#2865)
** 20-JAN-2015 NLIRA       E2DK909029     Defect 2727. AG segment not created.
** If the AG segment is missing but there is a WE segment, the AG segment
** should be created. The AG segment was indeed being created in an internal
** table of new segments, however the segnum used was incorrect and caused
** the AG segment to be inserted in a wrong location. Standard SAP recognized
** this and did not created the segment.
**&--------------------------------------------------------------------------*
** 04-Nov-2015  SGHOSH     E2DK915266    Defect#856 Part II: When the Idoc
**                                       comes from SI the logic in ZXVEDU03
**                                       will not trigger so logic for regent
**                                       rental contract is written in this
**                                       method also.
**---------------------------------------------------------------------*
**05-May-2016  U033870  E1DK917543   Changes against D3_OTC_CDD_0005_  *
**                                   0007_0140 Extending  logic for *
**                                    Partner type BOBJFTR and EMI entries*
**---------------------------------------------------------------------*
**14-June-2016 KMISHRA E1DK917543    Changes against D3_OTC_IDD_0009
**                                   New logic to populate sales office data
**---------------------------------------------------------------------*
**29-July-2016 U033870 E1DK917543  Changes against Defect #2938 D3_OTC_IDD_0009
**             / Jahan                logic to populate sales office data
**05-SEP-2016 U024571  E1DK921347  D3_OTC_IDD_0010 (CR D3_0163) :
**                                 Update segment E1EDP03.DATUM
**09/28/2016  JahanM   E1DK917543 Defect#3891 Corrected segmnt nos for e1edka3*
**---------------------------------------------------------------------------*
* 10/27/2016  Srini G  E1DK917543 CR-D3-84 --Comenting Sold to Ship to Logic
* From User Exit and moving this logic to Proxy Class                        *
*-----------------------------------------------------------------------------*
**---------------------------------------------------------------------------*
* 12/07/2016  Srini G  E1DK917543 Defect 7198 --Memory ID Sold to Ship to are*
* Not Instantiated.                                                          *
*---------------------------------------------------------------------------*
**12/19/2016  JahanM   E1DK917543 Defect 7828: Corrected logic to populate  *
**                                ref. contract for Quantity Contract(ZQC)  *
**--------------------------------------------------------------------------*
**01/09/2017  JahanM   E1DK917543 Defec 7828: Commening code for sales area *
**                                detrmination and internal & partner logic *
**                                as they will be prepoulated from source   *
**                                (by DSMA) during conversion load.         *
**--------------------------------------------------------------------------*

*Types Decleration
  TYPES :  BEGIN OF ty_edsdc,
               vkorg TYPE knvv-vkorg, " Sales Organization
               vtweg TYPE knvv-vtweg, " Distribution Channel
               spart TYPE knvv-spart, " Division
           END OF ty_edsdc,

* ---> Begin of Change for Defect#856 Part II:D2_OTC_IDD_0009 by SGHOSH

  BEGIN OF lty_item,
    vbeln TYPE vbeln,    "Contract no
    posnr TYPE posnr,    "Contract Item
    datab TYPE datab_vi, "Contract valid from
    datbi TYPE datbi_vi, "Contract valid to
  END OF lty_item,

  BEGIN OF lty_vbap,
    vbeln TYPE vbeln_va, "Contract no
    posnr TYPE posnr_va, "Contract Item
    abgru TYPE abgru_va, "Reason for Rejection
  END OF lty_vbap,

*-->Start of changes By Jahan defect#7828
  BEGIN OF lty_prc_control,
    mactive TYPE ain_epc_active_ind, "Contract no
    mvalue1 TYPE z_mvalue_low,       "Contract Item
    mvalue2 TYPE z_mvalue_high,      "Contract Item
  END OF lty_prc_control,
*-->End of By Jahan defect#7828


  lty_t_item TYPE STANDARD TABLE OF lty_item, " local internal table
* <--- End of Change for Defect#856 Part II:D2_OTC_IDD_0009 by SGHOSH

  lty_t_prc_control TYPE STANDARD TABLE OF lty_prc_control, " local internal table "By Jahan

*---> Begin of change for D3_OTC_IDD_0009 by KMISHRA
  BEGIN OF lty_knvv,
               vkorg TYPE vkorg, " Sales Organization
               vtweg TYPE vtweg, " Distribution Channel
               spart TYPE spart, " Division
  END OF lty_knvv,
*---> End of change for D3_OTC_IDD_0009 by KMISHRA

BEGIN OF lty_vbep,
  vbeln TYPE vbeln_va, " Sales Document
  posnr TYPE posnr_va, " Sales Document Item
  etenr TYPE etenr,    " Delivery Schedule Line Number
  edatu TYPE edatu,    " Schedule line date
END OF lty_vbep.

*Data Declerations
  DATA: lv_counter(3)       TYPE c,           " Counter(3) of type Character
        lwa_data            TYPE edid4,       " IDoc Data Records from 4.0 onwards
        lwa_data1           TYPE edid4,       " IDoc Data Records from 4.0 onwards
        lwa_insert_rec      TYPE idoc_insert, " Transfer Structure for Inserting Segments
        lv_parvw            TYPE parvw,       " Partner Function
        lv_expnr            TYPE edi_expnr,   " External partner number (in customer system)
        lv_kunnr            TYPE kunnr,       " Customer Number
        lv_inpnr            TYPE edi_inpnr,   " Internal partner number (in SAP System)
        lv_parvw_we         TYPE parvw,       " Partner Function
        lv_expnr_we         TYPE edi_expnr,   " External partner number (in customer system)
        lv_kunnr_we         TYPE kunnr,       " Customer Number
        lv_inpnr_we         TYPE edi_inpnr,   " Internal partner number (in SAP System)
        lv_kunnr_ag         TYPE kunnr,       " Customer Number
        lv_inpnr_ag         TYPE edi_inpnr,   " Internal partner number (in SAP System)
        lv_vbeln            TYPE char35,      " Vbeln of type CHAR35
        i_edsdc             TYPE STANDARD TABLE OF ty_edsdc INITIAL SIZE 0,
        lwa_edsdc           TYPE ty_edsdc,
        lv_lines            TYPE i,           " Lines of type Integers
        lv_vkorg            TYPE knvv-vkorg,  " Sales Organization
        lv_vtweg            TYPE knvv-vtweg,  " Distribution Channel
        lv_spart            TYPE knvv-spart,  " Division
        lv_sold_to_customer TYPE knvp-kunnr,  " Customer Number
        lv_added            TYPE c,           " Added of type Character
        lv_add              TYPE c,           " Add of type Character
        lv_ag               TYPE edi_inpnr,   " Internal partner number (in SAP System)
        lv_we               TYPE edi_inpnr,   " Internal partner number (in SAP System)
        lv_err              TYPE c,           " Err of type Character
*---> Begin of change for D3_OTC_CDD_0005_0007_0140 by U033870
        li_constants        TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Enhancement Status
        lv_partner          TYPE edi_sndprn,                                       " Partner Number of Sender
*<--- End of change for D3_OTC_CDD_0005_0007_0140 by U033870
* ---> Begin of Change for Defect#856 Part II:D2_OTC_IDD_0009 by SGHOSH
        lv_reject_flag  TYPE char1,                              " Reject_flag of type CHAR1
        li_item         TYPE lty_t_item,
        li_item1        TYPE lty_t_item,
        lwa_item        TYPE listvbap,                           " Referenced headers/items
        lwa_item1       TYPE lty_item,
        li_vbap1  TYPE STANDARD TABLE OF lty_vbap INITIAL SIZE 0,
        li_vbap  TYPE STANDARD TABLE OF lty_vbap INITIAL SIZE 0, " Local work area
* ---> End of Change for Defect#856 Part II:D2_OTC_IDD_0009 by SGHOSH

*-->Start of changes By JahanM defect#7828
        li_prc_control  TYPE lty_t_prc_control,
        lwa_prc_control TYPE lty_prc_control,
        lr_prc_cont     TYPE RANGE OF auart,   ##needed " Sales Document Type
        lwa_prc_cont    LIKE LINE OF lr_prc_cont,  ##needed
*-->End of changes By JahanM defect#7828


*<--- Begin of change for D3_OTC_IDD_0009 by KMISHRA
       li_knvv  TYPE STANDARD TABLE OF lty_knvv INITIAL SIZE 0,
       lwa_knvv TYPE lty_knvv,
       lv_sales TYPE char1, " Sales of type CHAR1
*<--- End of change for D3_OTC_IDD_0009 by KMISHRA
*Begin of Insert for D3_OTC_IDD_0010 (CR D3_0163) by U024571.
       lv_tabix      TYPE sytabix,  " Index of Internal Tables
       lv_tabix_main TYPE sytabix,  " Index of Internal Tables
       lv_local      TYPE sytabix,  " Index of Internal Tables
       lv_posnr      TYPE posnr_va, " Sales Document Item
       lv_tabix_plus TYPE sytabix,  " Index of Internal Tables
       lx_e1edp03    TYPE e1edp03,  " IDoc: Document Item Date Segment
       lx_e1edp01    TYPE e1edp01,  " IDoc: Document Item Date Segment
       li_vbep       TYPE STANDARD TABLE OF lty_vbep,
       lv_found      TYPE flag.     " General Flag
*End of Insert for D3_OTC_IDD_0010 (CR D3_0163) by U024571.

*Constants Declerations
  CONSTANTS: c_inbound(1)                  TYPE c VALUE '2',      " IDoc Direction
             c_orders(20)                  TYPE c VALUE 'ORDERS', " Message TYPE
*Begin of Insert for D3_OTC_IDD_0010 (CR D3_0163) by U024571
             c_ordrsp                      TYPE edi_mestyp VALUE 'ORDRSP', " Message TYPE
*End of Insert for D3_OTC_IDD_0010 (CR D3_0163) by U024571
             c_e1edka1(20)                 TYPE c VALUE 'E1EDKA1',  " SEGMENT NAME
             c_ag(2)                       TYPE c VALUE 'AG',       " Ag(2) of type Character
             c_we(2)                       TYPE c VALUE 'WE',       " We(2) of type Character
             c_006(3)                      TYPE c VALUE '006',      " 006(3) of type Character
             c_007(3)                      TYPE c VALUE '007',      " 007(3) of type Character
             c_008(3)                      TYPE c VALUE '008',      " 008(3) of type Character
             c_x(1)                        TYPE c VALUE 'X',        " X(1) of type Character
             c_e1edk14(20)                 TYPE c VALUE 'E1EDK14',  " SEGMENT NAME
             c_e1edk01(20)                 TYPE c VALUE 'E1EDK01',  " SEGMENT NAME
             c_zotc_msg(20)                TYPE c VALUE 'ZOTC_MSG', " MESSAGE CLASS
             c_021(3)                      TYPE c VALUE '021',      " MESSAGE NUMBER
             c_031(3)                      TYPE c VALUE '031',      " MESSAGE NUMBER
*---> Begin of change for D3_OTC_CDD_0005_0007_0140 by U033870
             c_bobjftr_prt TYPE edi_sndprn   VALUE   'BOBJFTR',          " Partner Number of Sender
             c_partner      TYPE z_criteria    VALUE 'PARTNER',          " Enh. Criteria
             c_enh_name      TYPE z_enhancement VALUE 'D3_OTC_CDD_0007', "Enhancement No.
*<--- End of change for D3_OTC_CDD_0005_0007_0140 by U033870
             c_si                          TYPE edidc-sndlad VALUE 'SI', " Logical address of sender
*<--- Begin of change for D3_OTC_IDD_0009 by KMISHRA
             c_error TYPE char5 VALUE '51', "Local variable for status of idoc
*<--- End of change for D3_OTC_IDD_0009 by KMISHRA
*Begin of Insert for D3_OTC_IDD_0010 (CR D3_0163) by U024571.
           lc_partner_seg_e1edp03     TYPE edi_segnam       VALUE 'E1EDP03',             " Name of SAP segment
           lc_e1cucfg                 TYPE edi_segnam       VALUE 'E1CUCFG',             " Name of SAP segment
           lc_e1edl37                 TYPE edi_segnam       VALUE 'E1EDL37',             " Name of SAP segment
           lc_e1eds01                 TYPE edi_segnam       VALUE 'E1EDS01',             " Name of SAP segment
           lc_idd_0010_001            TYPE z_enhancement    VALUE 'D2_OTC_IDD_0010_001', " Enhancement No.
           lc_null                    TYPE z_criteria       VALUE 'NULL',                " Enh. Criteria
           lc_0001                    TYPE etenr            VALUE '0001',                " Delivery Schedule Line Number
           lc_iddat                   TYPE z_criteria       VALUE 'IDDAT',               " Enh. Criteria
           lc_002                     TYPE edi_iddat        VALUE '002'.                 " From Value
*End of Insert for D3_OTC_IDD_0010 (CR D3_0163) by U024571.


*Field Symbols
  FIELD-SYMBOLS  :   <lfs_data>     TYPE edid4. " IDoc Data Records from 4.0 onwards
  FIELD-SYMBOLS  :   <lfs_data_we>  TYPE edid4. " IDoc Data Records from 4.0 onwards
  FIELD-SYMBOLS  :   <lfs_data_mat> TYPE edid4. " IDoc Data Records from 4.0 onwards

  FIELD-SYMBOLS:
*-->> BEGIN OF CHANGE FOR Defect # 856 Part II BY SGHOSH
  <lfs_vbap> TYPE lty_vbap, " Field symbols
*<<-- End of change for Defect # 856 Part II by SGHOSH
*---> Begin of change for D3_OTC_CDD_0005_0007_0140 by U033870
  <lfs_constant> TYPE zdev_enh_status, " Enhancement Status
*<--- End of change for D3_OTC_CDD_0005_0007_0140 by U033870
*Begin of Insert for D3_OTC_IDD_0010 (CR D3_0163) by U024571.
<lfs_vbep>   TYPE lty_vbep.
*End of Insert for D3_OTC_IDD_0010 (CR D3_0163) by U024571.


*CR232 Start
*Types Decleration
  TYPES    :        BEGIN OF ty_vbeln,
                    vbeln TYPE vbak-vbeln, " Sales Document
                    END OF ty_vbeln.

*Constants Declerations
  CONSTANTS:        c_e1edp01(20)       TYPE c VALUE 'E1EDP01',         " SEGMENT NAME
                    c_e1edp02(20)       TYPE c VALUE 'E1EDP02',         " SEGMENT NAME
                    c_e1edp19(20)       TYPE c VALUE 'E1EDP19',         " SEGMENT NAME
                    lc_mem(20)          TYPE c VALUE 'CR1110_IDD_0009'. "MEMORY ID      CR#1110++

*Data Declerations
  DATA:             lv_src_typ          TYPE edi_bsart,          " Document type
                    lv_trg_typ          TYPE edi_bsart,          " Document type
                    lv_active           TYPE ain_epc_active_ind, " Active or Inactive Indicator
                    li_vbeln            TYPE STANDARD TABLE OF ty_vbeln,
                    lwa_vbeln           TYPE ty_vbeln,
                    lv_kunnr1           TYPE kunnr,              " Customer Number
                    lv_inpnr1           TYPE edi_inpnr,          " Internal partner number (in SAP System)
                    lv_matnr            TYPE vbap-matnr,         " Material Number
                    lv_lines1           TYPE i,                  " Lines1 of type Integers
                    lv_flag             TYPE c,                  "CR#1110++
                    lv_segnum           TYPE idocdsgnum.         "INS-Def# 1437
*CR232 End

**---> Begin of change for D3_OTC_CDD_0005_0007_0140 by U033870
* EMI entry for Partner
*get the constants
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = c_enh_name
    TABLES
      tt_enh_status     = li_constants.
*If EMI table is not initial
  IF li_constants[] IS NOT INITIAL.
    DELETE li_constants WHERE active = abap_false.
    READ TABLE li_constants ASSIGNING <lfs_constant> WITH KEY criteria = c_partner.
    IF sy-subrc = 0.
      lv_partner = <lfs_constant>-sel_low.
    ENDIF. " IF sy-subrc = 0
  ELSE. " ELSE -> IF li_constants[] IS NOT INITIAL
    lv_partner = c_bobjftr_prt.
  ENDIF. " IF li_constants[] IS NOT INITIAL
*
*<--- End of change for D3_OTC_CDD_0005_0007_0140 by U033870
  CASE control-mestyp.
    WHEN c_orders.
* Begin of CR-D3-84

      IF   control-direct  = c_inbound AND
           control-sndprn  = lv_partner .
**>>> Start of Changes-MBAGDA
**-->DELETE
**      IF   control-direct  = c_inbound and
**           control-sndlad  = c_si .
**-->INSERT
*      IF   control-direct  = c_inbound AND
*           ( control-sndlad  = c_si OR
*             control-sndprn  = lv_partner ).
**<<< End of Changes-MBAGDA
*End of CR-D3-84

*Begin of CR#1110
        lv_flag = c_x.
        EXPORT lv_chk FROM lv_flag TO MEMORY ID lc_mem.
*End of CR#1110

*-->Start of change by JahanM defect#7828
*-->Removed code for sales area determination and internal & partner determination, as
*-->they will be prepoulated from source (by DSMA) during conversion load.

        READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam = c_e1edka1  sdata+0(2) = c_ag.
        IF sy-subrc = 0.
          lv_ag           = <lfs_data>-sdata+3(10).
        ENDIF. " IF sy-subrc = 0

        READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam = c_e1edka1  sdata+0(2) = c_we.
        IF sy-subrc = 0.
          lv_we           = <lfs_data>-sdata+3(10).
        ENDIF. " IF sy-subrc = 0

        READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam = c_e1edk14  sdata+0(3) = c_008.
        IF sy-subrc = 0.
          lv_vkorg           = <lfs_data>-sdata+3(35).
        ENDIF. " IF sy-subrc = 0

        READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam = c_e1edk14  sdata+0(3) = c_007.
        IF sy-subrc = 0.
          lv_vtweg           = <lfs_data>-sdata+3(35).
        ENDIF. " IF sy-subrc = 0


*-->End of change by JahanM defect#7828

*CR232 Start
*Get source document type
        READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam = c_e1edk01.
        IF sy-subrc = 0.
          lv_src_typ = <lfs_data>-sdata+79(4).
        ENDIF. " IF sy-subrc = 0
*Check Active flag
        CLEAR lv_active.
*       SELECT SINGLE mactive   " Active or Inactive Indicator  "By JahanM defect#7828.
        SELECT mactive          " Active or Inactive Indicator  "By JahanM defect#7828.
               mvalue1          " Select Options: Value Low
               mvalue2          " Select Options: Value High
          FROM zotc_prc_control " OTC Process Team Control Table
*-->Start of change by JahanM
          INTO TABLE li_prc_control
*               INTO   (lv_active ,
*                       lv_trg_typ)
*-->End of change by JahanM
        WHERE  vkorg      = lv_vkorg           AND
               vtweg      = lv_vtweg           AND
               mprogram   = 'IDOC_DATA_INSERT' AND
               mparameter = 'E1EDK01-BSART'    AND
               soption    = 'EQ'               AND
               mvalue1    =  lv_src_typ.
        IF sy-subrc = 0.
*-->Start of change by JahanM defect#7828
*--Create a range table for using in VAPMA select
          LOOP AT li_prc_control INTO lwa_prc_control.
            lwa_prc_cont-sign = 'I'.
            lwa_prc_cont-option = 'EQ'.
            lwa_prc_cont-low = lwa_prc_control-mvalue2 .
            APPEND lwa_prc_cont TO lr_prc_cont.
          ENDLOOP. " LOOP AT li_prc_control INTO lwa_prc_control
        ENDIF. " IF sy-subrc = 0
        READ TABLE li_prc_control WITH KEY   mvalue1 = lv_src_typ
                                             mactive = c_x
                                  TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
*       IF lv_active = c_x.
*-->End of change by JahanM defect#7828

*Get SAP Sold to/Ship to
          CLEAR lv_counter.
          LOOP AT data INTO lwa_data WHERE segnam =  c_e1edp01.
            CLEAR lv_vbeln.
            READ TABLE data ASSIGNING <lfs_data> WITH KEY psgnum     = lwa_data-segnum
                                                          segnam     = c_e1edp02
                                                          sdata+0(3) = '043'.

            IF sy-subrc = 0.
              lv_vbeln = <lfs_data>-sdata+3(35).
            ENDIF. " IF sy-subrc = 0
            IF sy-subrc <> 0 OR lv_vbeln IS INITIAL.
              READ TABLE data ASSIGNING <lfs_data_mat> WITH KEY psgnum = lwa_data-segnum segnam = c_e1edp19.
              IF sy-subrc = 0.
                CLEAR lv_matnr.
                lv_matnr = <lfs_data_mat>-sdata+3(35).

* ---> Begin of Change for Defect#856 Part II:D2_OTC_IDD_0009 by SGHOSH

                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = lv_we
                  IMPORTING
                    output = lv_we.

                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = lv_ag
                  IMPORTING
                    output = lv_ag.

* select respective contract document from database
                SELECT vapma~vbeln " Sales and Distribution Document Number
                       vapma~posnr " Item number of the SD document
                       vapma~datab " Quotation or contract valid from
                       vapma~datbi " Quotation or contract valid to
                  INTO TABLE li_item
                  FROM vapma       " Sales Index: Order Items by Material
                  INNER JOIN vbpa ON
                  vapma~vbeln = vbpa~vbeln
                  WHERE vapma~matnr =  lv_matnr   AND
                        vapma~vkorg =  lv_vkorg   AND
                        vapma~vtweg =  lv_vtweg   AND
*                       vapma~auart =  lv_trg_typ AND "By JahanM defect#7828
                        vapma~auart IN lr_prc_cont AND "By JahanM defect#7828.
                        vapma~kunnr =  lv_ag      AND
                        vbpa~kunnr  =  lv_we     AND
                        vbpa~parvw  = c_we .
                IF sy-subrc = 0.
*       Don't consider those contract for which 'Contract start date'
*       is in future. Means delete those contracts for which DATAB (Contract
*       start date) is greater than current date
*       Similarly, Don't consider those contract for which 'Contract End date'
*       is in Past. Means delete those contracts for which DATBI (Contract
*       end date) is less than current date
                  DELETE li_item WHERE ( datab GT sy-datum ) OR ( datbi LT sy-datum ).
                ENDIF. " IF sy-subrc = 0
                IF li_item IS NOT INITIAL.
* The sort statement has to be introduced as we will consider
* only the first item based on creation of contracts
                  SORT li_item BY vbeln ASCENDING.

                  CLEAR lwa_item1.
                  READ TABLE li_item INTO lwa_item1 INDEX 1.
                  IF sy-subrc IS INITIAL.
*&&-- Contract #
                    lv_vbeln = lwa_item1-vbeln.

* We will now check if the Material which the user has entered on
* the new Sales Order is already marked for Rejection or not.
                    SELECT vbeln " Contract Number (in this case)
                           posnr " Item Number
                           abgru " Reason for Rejection
                    INTO TABLE li_vbap
                    FROM vbap    " Sales Document: Item Data
                    WHERE vbeln = lv_vbeln
                    AND matnr = lv_matnr.
                    IF sy-subrc IS INITIAL.
* It may happen that a Material has one line item
* marked for Rejection, and another line item not.
* In such cases, the Material will not be referenced
* from Contract.
                      REFRESH: li_item1.
                      li_item1[] = li_item[].
* Sort is done as we will consider the line items
                      SORT li_item1 BY posnr.
                      REFRESH li_item[].

                      li_vbap1 = li_vbap.
                      DELETE li_vbap1 WHERE abgru IS NOT INITIAL.
                      IF li_vbap1 NE li_vbap.
                        lv_reject_flag = abap_true.
                      ENDIF. " IF li_vbap1 NE li_vbap

                    ENDIF. " IF sy-subrc IS INITIAL
*&&-- After filtering out multiple contracts, it will retain ONLY 1 contract#
*     with multiple items (we need these for Valid From & Valid To Dates)

                    DESCRIBE TABLE li_item1 LINES lv_lines1.
                    IF lv_lines1 = 1.

                      LOOP AT li_vbap ASSIGNING <lfs_vbap>.
                        IF <lfs_vbap>-abgru IS INITIAL.
                          READ TABLE li_item1 INTO lwa_item1 WITH KEY posnr = <lfs_vbap>-posnr
                                                             BINARY SEARCH.
                          IF sy-subrc IS INITIAL.
                            lwa_insert_rec-counter   =   lv_counter.
                            lwa_insert_rec-segnam    =   c_e1edp02.
                            lwa_insert_rec-segnum    =   lwa_data-segnum.
                            lwa_data1-sdata+0(3)     =   '043'.
                            lwa_data1-sdata+3(35)    =   lwa_item1-vbeln.
                            lwa_data1-sdata+38(6)    =   lwa_item1-posnr.
                            lwa_insert_rec-sdata     =   lwa_data1-sdata.
                            APPEND  lwa_insert_rec TO new_entries.
                            CLEAR : lwa_data1,lwa_insert_rec.
                            lv_added = c_x.
                            lv_counter = lv_counter + 1.
                          ENDIF. " IF sy-subrc IS INITIAL
                        ENDIF. " IF <lfs_vbap>-abgru IS INITIAL
                      ENDLOOP. " LOOP AT li_vbap ASSIGNING <lfs_vbap>
                    ELSEIF lv_lines1 > 1.
                      IF lv_reject_flag IS INITIAL.
                        READ TABLE li_item1 INTO lwa_item1 INDEX 1.
                        lwa_insert_rec-counter   =   lv_counter.
                        lwa_insert_rec-segnam    =   c_e1edp02.
                        lwa_insert_rec-segnum    =   lwa_data-segnum.
                        lwa_data1-sdata+0(3)     =   '043'.
                        lwa_data1-sdata+3(35)    =   lwa_item1-vbeln.
                        lwa_data1-sdata+38(6)    =   lwa_item1-posnr.
*                        lwa_data1-sdata+3(50)    =   'Cont ref not established mul cont'.
                        lwa_insert_rec-sdata     =   lwa_data1-sdata.
                        APPEND  lwa_insert_rec TO new_entries.
                        CLEAR : lwa_data1,lwa_insert_rec.
                        lv_added = c_x.
                        lv_counter = lv_counter + 1.
                      ENDIF. " IF lv_reject_flag IS INITIAL
                    ENDIF. " IF lv_lines1 = 1
                  ENDIF. " IF sy-subrc IS INITIAL
                ENDIF. " IF li_item IS NOT INITIAL
              ENDIF. " IF sy-subrc = 0
            ENDIF. " IF sy-subrc <> 0 OR lv_vbeln IS INITIAL
          ENDLOOP. " LOOP AT data INTO lwa_data WHERE segnam = c_e1edp01
        ENDIF. " IF sy-subrc = 0
*CR232 End
        IF lv_parvw = c_we.
          CLEAR lv_added.
*         loop at data into lwa_data where segnam =  c_e1edka1.    "DEL-Def# 1437
          LOOP AT data INTO lwa_data WHERE segnam     =  c_e1edka1 "INS-Def# 1437
                                       AND sdata+0(3) =  c_we.
            CLEAR: lv_counter, lv_segnum.
            lv_segnum                = lwa_data-segnum + 1. "INS-Def# 1437
            lwa_insert_rec-counter   = lv_counter.
            lwa_insert_rec-segnam    = c_e1edka1.
*           lwa_insert_rec-segnum    = lwa_data-segnum.            "DEL-Def# 1437
            lwa_insert_rec-segnum    = lv_segnum. "INS-Def# 1437
* Defect 2727 -- Overriding the above statement as this causes the new AG segment to be inserted not
* after the E1EDKA1 WE segment but after the next segment which happens to be E1EDK02 in this case.
* This causes the IDoc to fail.

**<<Start of Defect 3891 by Jahan
**<<This overriding is incorrect, as new segment pushes exiting WE subsegment into AG. So commenting this line.
*          lwa_insert_rec-segnum    = lwa_data-segnum. "INS-Def# 2727
**<<End of Defect 3891 by Jahan

* End defect 2727
            lwa_data1-sdata+0(3)     = c_ag.
            lwa_data1-sdata+3(20)    = lv_kunnr.
            lwa_data1-sdata+20(17)   = lv_expnr.
            lwa_insert_rec-sdata     = lwa_data1-sdata.
            APPEND  lwa_insert_rec TO new_entries.
            CLEAR : lwa_data1,lwa_insert_rec.
            lv_added = c_x.
          ENDLOOP. " LOOP AT data INTO lwa_data WHERE segnam = c_e1edka1
*         delete adjacent duplicates from new_entries comparing SEGNAM SDATA.  "**  "DEL-Def# 1437
        ENDIF. " IF lv_parvw = c_we

        IF lv_added = c_x.
          have_to_change  = c_x.
          protocol-stamid = c_zotc_msg. "Status message ID
          protocol-stamno = c_021. "Status message number
          protocol-stapa1 = text-001. "Parameter 1
          protocol-stapa2 = text-002. "Parameter 2
          protocol-stapa3 = text-003. "Parameter 3
          IF lv_parvw = c_we.
            protocol-stapa4 = text-004. "Parameter 4
          ENDIF. " IF lv_parvw = c_we
          protocol-repid  = sy-cprog . "Program Name
        ENDIF. " IF lv_added = c_x
* Begin of CR-D3-84
* The below code runs for IDD - 0009
      ELSE. " ELSE -> IF control-direct = c_inbound AND
*Get source document type
* Begin of Defect 7198 - Srini - U033814
        lv_flag = c_x.
        EXPORT lv_chk FROM lv_flag TO MEMORY ID lc_mem.

        READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam = c_e1edka1  sdata+0(2) = c_ag.
        IF sy-subrc = 0.
          lv_ag           = <lfs_data>-sdata+3(10).
        ENDIF. " IF sy-subrc = 0

        READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam = c_e1edka1  sdata+0(2) = c_we.
        IF sy-subrc = 0.
          lv_we           = <lfs_data>-sdata+3(10).
        ENDIF. " IF sy-subrc = 0

        READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam = c_e1edk14  sdata+0(3) = c_008.
        IF sy-subrc = 0.
          lv_vkorg           = <lfs_data>-sdata+3(35).
        ENDIF. " IF sy-subrc = 0

        READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam = c_e1edk14  sdata+0(3) = c_007.
        IF sy-subrc = 0.
          lv_vtweg           = <lfs_data>-sdata+3(35).
        ENDIF. " IF sy-subrc = 0
* End of Defect 7198 - Srini - U033814

        READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam = c_e1edk01.
        IF sy-subrc = 0.
          lv_src_typ = <lfs_data>-sdata+79(4).
        ENDIF. " IF sy-subrc = 0
*Check Active flag
        CLEAR lv_active.
*        SELECT SINGLE mactive          " Active or Inactive Indicator  "By JahanM defect#7828.
        SELECT mactive          " Active or Inactive Indicator    "By JahanM defect#7828.
               mvalue1          " Select Options: Value Low
               mvalue2          " Select Options: Value High
          FROM zotc_prc_control " OTC Process Team Control Table
*-->Start of change By JahanM defect#7828.
          INTO TABLE li_prc_control
*               INTO   (lv_active ,
*                       lv_trg_typ)
*-->End of change By JahanM defect#7828.
         WHERE vkorg      = lv_vkorg           AND
               vtweg      = lv_vtweg           AND
               mprogram   = 'IDOC_DATA_INSERT' AND
               mparameter = 'E1EDK01-BSART'    AND
               soption    = 'EQ'               AND
               mvalue1    =  lv_src_typ.
        IF sy-subrc = 0.
*-->Start of change by JahanM defect#7828
*--Create a range table for using in VAPMA select
          LOOP AT li_prc_control INTO lwa_prc_control.
            lwa_prc_cont-sign = 'I'.
            lwa_prc_cont-option = 'EQ'.
            lwa_prc_cont-low = lwa_prc_control-mvalue2 .
            APPEND lwa_prc_cont TO lr_prc_cont.
          ENDLOOP. " LOOP AT li_prc_control INTO lwa_prc_control
        ENDIF. " IF sy-subrc = 0

        READ TABLE li_prc_control WITH KEY   mvalue1 = lv_src_typ
                                             mactive = c_x
                                  TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
*       IF lv_active = c_x.
*-->End of change by JahanM defect#7828

*Get SAP Sold to/Ship to
          CLEAR lv_counter.
          LOOP AT data INTO lwa_data WHERE segnam =  c_e1edp01.
            CLEAR lv_vbeln.
            READ TABLE data ASSIGNING <lfs_data> WITH KEY psgnum     = lwa_data-segnum
                                                          segnam     = c_e1edp02
                                                          sdata+0(3) = '043'.

            IF sy-subrc = 0.
              lv_vbeln = <lfs_data>-sdata+3(35).
            ENDIF. " IF sy-subrc = 0
            IF sy-subrc <> 0 OR lv_vbeln IS INITIAL.
              READ TABLE data ASSIGNING <lfs_data_mat> WITH KEY psgnum = lwa_data-segnum segnam = c_e1edp19.
              IF sy-subrc = 0.
                CLEAR lv_matnr.
                lv_matnr = <lfs_data_mat>-sdata+3(35).

* ---> Begin of Change for Defect#856 Part II:D2_OTC_IDD_0009 by SGHOSH

                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = lv_we
                  IMPORTING
                    output = lv_we.

                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = lv_ag
                  IMPORTING
                    output = lv_ag.

* select respective contract document from database
                SELECT vapma~vbeln " Sales and Distribution Document Number
                       vapma~posnr " Item number of the SD document
                       vapma~datab " Quotation or contract valid from
                       vapma~datbi " Quotation or contract valid to
                  INTO TABLE li_item
                  FROM vapma       " Sales Index: Order Items by Material
                  INNER JOIN vbpa ON
                  vapma~vbeln = vbpa~vbeln
                  WHERE vapma~matnr =  lv_matnr   AND
                        vapma~vkorg =  lv_vkorg   AND
                        vapma~vtweg =  lv_vtweg   AND
*                        vapma~auart =  lv_trg_typ AND "By JahanM defect#7828.
                        vapma~auart IN lr_prc_cont AND "By JahanM defect#7828.
                        vapma~kunnr =  lv_ag      AND
                        vbpa~kunnr   =  lv_we     AND
                        vbpa~parvw  = c_we .
                IF sy-subrc = 0.
*       Don't consider those contract for which 'Contract start date'
*       is in future. Means delete those contracts for which DATAB (Contract
*       start date) is greater than current date
*       Similarly, Don't consider those contract for which 'Contract End date'
*       is in Past. Means delete those contracts for which DATBI (Contract
*       end date) is less than current date
                  DELETE li_item WHERE ( datab GT sy-datum ) OR ( datbi LT sy-datum ).
                ENDIF. " IF sy-subrc = 0
                IF li_item IS NOT INITIAL.
* The sort statement has to be introduced as we will consider
* only the first item based on creation of contracts
                  SORT li_item BY vbeln ASCENDING.

                  CLEAR lwa_item1.
                  READ TABLE li_item INTO lwa_item1 INDEX 1.
                  IF sy-subrc IS INITIAL.
*&&-- Contract #
                    lv_vbeln = lwa_item1-vbeln.

* We will now check if the Material which the user has entered on
* the new Sales Order is already marked for Rejection or not.
                    SELECT vbeln " Contract Number (in this case)
                           posnr " Item Number
                           abgru " Reason for Rejection
                    INTO TABLE li_vbap
                    FROM vbap    " Sales Document: Item Data
                    WHERE vbeln = lv_vbeln
                    AND matnr = lv_matnr.
                    IF sy-subrc IS INITIAL.
* It may happen that a Material has one line item
* marked for Rejection, and another line item not.
* In such cases, the Material will not be referenced
* from Contract.
                      REFRESH: li_item1.
                      li_item1[] = li_item[].
* Sort is done as we will consider the line items
                      SORT li_item1 BY posnr.
                      REFRESH li_item[].

                      li_vbap1 = li_vbap.
                      DELETE li_vbap1 WHERE abgru IS NOT INITIAL.
                      IF li_vbap1 NE li_vbap.
                        lv_reject_flag = abap_true.
                      ENDIF. " IF li_vbap1 NE li_vbap
                    ENDIF. " IF sy-subrc IS INITIAL
*&&-- After filtering out multiple contracts, it will retain ONLY 1 contract#
*     with multiple items (we need these for Valid From & Valid To Dates)

                    DESCRIBE TABLE li_item1 LINES lv_lines1.
                    IF lv_lines1 = 1.
                      LOOP AT li_vbap ASSIGNING <lfs_vbap>.
                        IF <lfs_vbap>-abgru IS INITIAL.
                          READ TABLE li_item1 INTO lwa_item1 WITH KEY posnr = <lfs_vbap>-posnr
                                                             BINARY SEARCH.
                          IF sy-subrc IS INITIAL.
                            lwa_insert_rec-counter   =   lv_counter.
                            lwa_insert_rec-segnam    =   c_e1edp02.
                            lwa_insert_rec-segnum    =   lwa_data-segnum.
                            lwa_data1-sdata+0(3)     =   '043'.
                            lwa_data1-sdata+3(35)    =   lwa_item1-vbeln.
                            lwa_data1-sdata+38(6)    =   lwa_item1-posnr.
                            lwa_insert_rec-sdata     =   lwa_data1-sdata.
                            APPEND  lwa_insert_rec TO new_entries.
                            CLEAR : lwa_data1,lwa_insert_rec.
                            lv_added = c_x.
                            lv_counter = lv_counter + 1.
                          ENDIF. " IF sy-subrc IS INITIAL
                        ENDIF. " IF <lfs_vbap>-abgru IS INITIAL
                      ENDLOOP. " LOOP AT li_vbap ASSIGNING <lfs_vbap>
                    ELSEIF lv_lines1 > 1.
                      IF lv_reject_flag IS INITIAL.
                        READ TABLE li_item1 INTO lwa_item1 INDEX 1.
                        lwa_insert_rec-counter   =   lv_counter.
                        lwa_insert_rec-segnam    =   c_e1edp02.
                        lwa_insert_rec-segnum    =   lwa_data-segnum.
                        lwa_data1-sdata+0(3)     =   '043'.
                        lwa_data1-sdata+3(35)    =   lwa_item1-vbeln.
                        lwa_data1-sdata+38(6)    =   lwa_item1-posnr.
*                        lwa_data1-sdata+3(50)    =   'Cont ref not established mul cont'.
                        lwa_insert_rec-sdata     =   lwa_data1-sdata.
                        APPEND  lwa_insert_rec TO new_entries.
                        CLEAR : lwa_data1,lwa_insert_rec.
                        lv_added = c_x.
                        lv_counter = lv_counter + 1.
                      ENDIF. " IF lv_reject_flag IS INITIAL
                    ENDIF. " IF lv_lines1 = 1
                  ENDIF. " IF sy-subrc IS INITIAL
                ENDIF. " IF li_item IS NOT INITIAL
              ENDIF. " IF sy-subrc = 0
            ENDIF. " IF sy-subrc <> 0 OR lv_vbeln IS INITIAL
          ENDLOOP. " LOOP AT data INTO lwa_data WHERE segnam = c_e1edp01
        ENDIF. " IF sy-subrc = 0
* Begin of Defect - 7198 - U033814
        IF lv_added = c_x.
          have_to_change  = c_x.
          protocol-stamid = c_zotc_msg. "Status message ID
          protocol-stamno = c_021. "Status message number
          protocol-stapa1 = text-001. "Parameter 1
          protocol-stapa2 = text-002. "Parameter 2
          protocol-stapa3 = text-003. "Parameter 3
          protocol-repid  = sy-cprog . "Program Name
        ENDIF. " IF lv_added = c_x
* End of Defect - 7198 - U033814
      ENDIF. " IF control-direct = c_inbound AND
*End of CR-D3-84
*End of CR-D3-84

**Begin of Insert for D3_OTC_IDD_0010 (CR D3_0163) by U024571.
    WHEN c_ordrsp.

* Call to EMI Function Module To Get List Of EMI Statuses
      CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
        EXPORTING
          iv_enhancement_no = lc_idd_0010_001 "D2_OTC_IDD_0010_001
        TABLES
          tt_enh_status     = li_constants.   "Enhancement status table


*first thing is to check for field criterion,for value “NULL” and field Active value:
*i.If the value is: “X”, the overall Enhancement is active and can proceed further for checks
*ii.If the  value is:space, then do not proceed further for this enhancement

      READ TABLE li_constants WITH KEY criteria = lc_null "NULL
                                       active = abap_true "X"
                           TRANSPORTING NO FIELDS.
      IF sy-subrc EQ  0.

*Get the data where segment is E1EDK01 to get the vbeln
        READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam = c_e1edk01.
        IF sy-subrc = 0.
          CLEAR : lv_vbeln,
                  lv_tabix,
                  lv_tabix_plus.
*Populate Vbeln
          lv_vbeln = <lfs_data>-sdata+83(35).

*Get the data where segment is E1EDP01
          READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam = c_e1edp01.
          IF sy-subrc = 0.
            lv_tabix_main = sy-tabix.
            lv_tabix_plus = lv_tabix_main + 1.

*Fetch the data from VBEP table based on VBAP data fetched above
            SELECT vbeln " Sales Document
                   posnr " Sales Document Item
                   etenr " Delivery Schedule Line Number
                   edatu " Schedule line date
              FROM vbep  " Sales Document: Schedule Line Data
              INTO TABLE li_vbep
              WHERE vbeln = lv_vbeln
                AND etenr = lc_0001.
            IF sy-subrc = 0.
              SORT li_vbep BY vbeln posnr etenr.
            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF sy-subrc = 0

*Loop at the data table from next record after segment E1EDP01 occurs
          LOOP AT data ASSIGNING <lfs_data> FROM lv_tabix_plus.
*If segment E1EDP03 is found
            IF <lfs_data>-segnam = lc_partner_seg_e1edp03.
              lv_tabix = sy-tabix - 1.
              lx_e1edp03 = <lfs_data>-sdata.
*If IDDAT = 002 the update the value of DATUM
              IF lx_e1edp03-iddat = lc_002. "Check for 002

                READ TABLE data ASSIGNING <lfs_data_mat> INDEX lv_tabix_main.
                IF sy-subrc = 0.
                  CLEAR lv_posnr.
                  lx_e1edp01 = <lfs_data_mat>-sdata.
                  lv_posnr = lx_e1edp01-posex.

                  READ TABLE li_vbep ASSIGNING <lfs_vbep> WITH KEY vbeln = lv_vbeln
                                                                   posnr = lv_posnr
                                                                   etenr = lc_0001
                                                                   BINARY SEARCH.
                  IF sy-subrc = 0.
                    lx_e1edp03-datum = <lfs_vbep>-edatu.
                    SHIFT lx_e1edp03-datum LEFT DELETING LEADING space.
                    <lfs_data>-sdata = lx_e1edp03. "Application data
                    lv_found = abap_true.
                  ENDIF. " IF sy-subrc = 0
                ENDIF. " IF sy-subrc = 0
              ENDIF. " IF lx_e1edp03-iddat = lc_002
            ENDIF. " IF <lfs_data>-segnam = lc_partner_seg_e1edp03

*The loop will continue to check the value of IDDAT = 002 till the next E1EDP01 is found.
*As soon as next E1EDP01 is found check if DATUM is updated or not , if not then add a new segment
*E1EPD03 with the updated value of DATUM.
            IF <lfs_data>-segnam = c_e1edp01 AND lv_found = space.
              lv_local = sy-tabix.
              READ TABLE data ASSIGNING <lfs_data_mat> INDEX lv_tabix_main.
              IF sy-subrc = 0.
                CLEAR lv_posnr.
                lx_e1edp01 = <lfs_data_mat>-sdata.
                lv_posnr = lx_e1edp01-posex.
                lv_tabix_main = lv_local.
                READ TABLE li_vbep ASSIGNING <lfs_vbep> WITH KEY vbeln = lv_vbeln
                                                                 posnr = lv_posnr
                                                                 etenr = lc_0001
                                                                 BINARY SEARCH.
                IF sy-subrc = 0.
                  lx_e1edp03-datum = <lfs_vbep>-edatu.
                  lx_e1edp03-iddat = lc_002 . "<lfs_constant>-sel_low.
                  SHIFT lx_e1edp03-datum LEFT DELETING LEADING space.
*Insert the segment to the idoc
                  lwa_insert_rec-counter   =   lv_counter.
                  lwa_insert_rec-segnam    =   lc_partner_seg_e1edp03.
                  lwa_insert_rec-segnum    =   lv_tabix.
                  lwa_data1-sdata          =   lx_e1edp03.
                  lwa_insert_rec-sdata     =   lwa_data1-sdata.
                  APPEND  lwa_insert_rec TO new_entries.
                  CLEAR : lwa_data1,lwa_insert_rec.

                  lv_added = abap_true.
                ENDIF. " IF sy-subrc = 0
              ENDIF. " IF sy-subrc = 0
            ENDIF. " IF <lfs_data>-segnam = c_e1edp01 AND lv_found = space
*If any of these 3 segments are found then check if segment E1EDP03 with IDDAT = 002 is updated
*or not, If not then insert the segment
            IF ( <lfs_data>-segnam = lc_e1cucfg OR
               <lfs_data>-segnam = lc_e1edl37 OR
               <lfs_data>-segnam = lc_e1eds01 ) AND
               lv_found = space.
              READ TABLE data ASSIGNING <lfs_data_mat> INDEX lv_tabix_main.
              IF sy-subrc = 0.
                CLEAR lv_posnr.
                lx_e1edp01 = <lfs_data_mat>-sdata.
                lv_posnr = lx_e1edp01-posex.
                READ TABLE li_vbep ASSIGNING <lfs_vbep> WITH KEY vbeln = lv_vbeln
                                                                 posnr = lv_posnr
                                                                 etenr = lc_0001
                                                                 BINARY SEARCH.
                IF sy-subrc = 0.
                  lx_e1edp03-datum = <lfs_vbep>-edatu.
                  lx_e1edp03-iddat = lc_002. "<lfs_constant>-sel_low.
                  SHIFT lx_e1edp03-datum LEFT DELETING LEADING space.

*Insert the segemnt to the idoc
                  lwa_insert_rec-counter   =   lv_counter.
                  lwa_insert_rec-segnam    =   lc_partner_seg_e1edp03.
                  lwa_insert_rec-segnum    =   lv_tabix.
                  lwa_data1-sdata          =   lx_e1edp03.
                  lwa_insert_rec-sdata     =   lwa_data1-sdata.
                  APPEND  lwa_insert_rec TO new_entries.
                  CLEAR : lwa_data1,lwa_insert_rec.
                  lv_added = abap_true.
                ENDIF. " IF sy-subrc = 0
                EXIT.
              ENDIF. " IF sy-subrc = 0
            ENDIF. " IF ( <lfs_data>-segnam = lc_e1cucfg OR
          ENDLOOP. " LOOP AT data ASSIGNING <lfs_data> FROM lv_tabix_plus
        ENDIF. " IF sy-subrc = 0

*If the segment is added then populate the structure for Log Information
        IF lv_added = abap_true.
          have_to_change  = abap_true.
          protocol-stamid = c_zotc_msg. "Status message ID
          protocol-stamno = c_021. "Status message number
          protocol-stapa1 = text-005. "Parameter 1
          protocol-repid  = sy-cprog . "Program Name
        ENDIF. " IF lv_added = abap_true
      ENDIF. " IF sy-subrc EQ 0
*End of Insert for D3_OTC_IDD_0010 (CR D3_0163) by U024571.
    WHEN  OTHERS.
  ENDCASE.
*
**<--- Begin of change for D3_OTC_IDD_0009 by KMISHRA
**Setting the status of IDOc to 51 (error) as sales office data not found in KNVV/EDSDC
*  IF lv_sales = c_x.
*    control-status = c_error.
*  ENDIF. " IF lv_sales = c_x
**<--- End of change for D3_OTC_IDD_0009 by KMISHRA
*

ENDMETHOD.
ENDCLASS.
