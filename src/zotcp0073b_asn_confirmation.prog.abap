*&--------------------------------------------------------------------*
***********************************************************************
*Program    : ZOTCP0073B_ASN_CONFIRMATION                             *
*Title      : ASN CONFIRMATION                                        *
*Developer  : Himadri Rudra Sharma                                    *
*Object type: Driver Program                                          *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_FDD_0073_Output for ASN  form                      *
*---------------------------------------------------------------------*
* Description: ASN order is sent to the Contact person through email. *
*              This output & mail will be triggered at the time the   *
*              PGR done.The Enriched Email content shall be available *
*              in the body and not as attachment.                     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*08-Jan-2015  Hrudra       E2DK906777      INITIAL DEVELOPMENT
*---------------------------------------------------------------------*
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ========= ================================*
*26-Feb-2015  Hrudra       E2DK906777 Defect # 4207
*                                     Form Layout has been translated
*                                     in Spanish and French languages.
*                                     For the French Canadian Form,all
*                                     labels has been maintained as
*                                     French Canadian label first and
*                                     then followed by English labels.
*=========== ============== ========= ================================*
*20-Mar-2015  Hrudra      E2DK906777(WB) Defect # 4207_2
*                         E2DK906779(Customizing)
*                                     i)Tracking No. is Hyperlinked
*                                     based on VBAK-VSBED(shipping
*                                     condition) to the URL.
*                                     ii)Sends mails only to Bio-Rad ID
*                                     in Non-production system, else in
*                                     production system mail sends to any
*                                     mail Id.
*                                     iii)Language Selection based on
*                                     Sales Org(VKORG)& maintained in
*                                     EMI Tool.
*                                     iii)Kind Text label is modified
*                                     in Std. Text.
*=========== ============== ========= ================================*
*27-Mar-2015 APODDAR        E2DK906777(WB) Defect # 4207_3
*                           E2DK906779(Customizing)
*                                     i) Correction to SOLD to/Ship to
*                                     address.The sold/ship to City,
*                                     State,postal code and country
*                                      should be single line.
*                                     ii) Translation for Spanish  &
*                                     French has been changed.
*                                     iii)Date Format for French changed
*                                     to MM/DD/YY where Separator is the
*                                     hyphen. Leading zero must show if
*                                     less than 10.
*
*---------------------------------------------------------------------*
*14-Apr-2015 APODDAR        E2DK906777(WB) Defect # 5847
*                                          Shipment Status Logic
*---------------------------------------------------------------------*
*21-Apr-2015 ASK            E2DK906777(WB) Defect # 6146
*                                          Ship to Address formatting
*---------------------------------------------------------------------*
*26-Sep-2016 KMISHRA        E1DK921688(WB) D3_OTC_FDD_0073
*                                          Form language is set as ship to language.
*                                          Translation are maintained for
*                                          Spanish,Dutch German and French
*&--------------------------------------------------------------------*

REPORT zotcp0073b_asn_confirmation MESSAGE-ID zotc_msg.

*&---------------------------------------------------------------------*
*&      Form  ENTRY
*&---------------------------------------------------------------------*
*       Entry Routine for Form Processing
*----------------------------------------------------------------------*
*      -->RETURN_CODE  Return Code for errors
*----------------------------------------------------------------------*

FORM entry  USING return_code TYPE sy-subrc ##called " Return Value of
                  us_screen   TYPE c ##needed.       " Screen of type Character
*Global Constants
  CONSTANTS:c_nast TYPE tabname VALUE 'NAST'. " Nast Table Name
*Local Field Symbols
  FIELD-SYMBOLS:
    <lfs_x_nast>   TYPE nast. " NAST Structure
*Local Variables Declaration
  DATA lv_retcode     TYPE sy-subrc. "Returncode

*Assign NAST Structure
  ASSIGN (c_nast) TO <lfs_x_nast>.
*check if <lfs_x_nast> is assigned
  IF <lfs_x_nast>  IS ASSIGNED.
*Mail Processing
    PERFORM f_processing USING <lfs_x_nast>
                     CHANGING  lv_retcode.
    IF lv_retcode NE 0.
      return_code = 1.
    ELSE. " ELSE -> IF lv_retcode NE 0
      return_code = 0.
    ENDIF. " IF lv_retcode NE 0
  ELSE. " ELSE -> IF <lfs_x_nast> IS ASSIGNED
    return_code = 1.
  ENDIF. " IF <lfs_x_nast> IS ASSIGNED
ENDFORM. "ENTRY

*&---------------------------------------------------------------------*
*&      Form  F_PROCESSING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FP_<LFS_X_NAST>   FS for NAST Tables
*      <--FP_LV_RETCODE     Return Code for errors
*----------------------------------------------------------------------*
FORM f_processing
USING    fp_nast       TYPE nast               "Message Status
CHANGING fp_retcode    TYPE sy-subrc ##needed. "Return Value of ABAP Statements

* ---> Begin of Change for Defect #4207_2 by HRUDRA
  TYPES: BEGIN OF lty_tvarv,
           name  TYPE rvari_vnam,   " ABAP: Name of Variant Variable
           type  TYPE rsscr_kind,
           numb  TYPE tvarv_numb,   " ABAP: Current selection number
           sign  TYPE tvarv_sign,   " ABAP: ID: I/E (include/exclude values)
           opti  TYPE tvarv_opti,   " ABAP: Selection option (EQ/BT/CP/...)
           low   TYPE tvarv_val,    " ABAP/4: Selection value (LOW or HIGH value, external format)
         END OF lty_tvarv,

         BEGIN OF lty_range,
           sign  TYPE tvarv_sign,   " ABAP: ID: I/E (include/exclude values)
           option  TYPE tvarv_opti, " ABAP: Selection option (EQ/BT/CP/...)
           low   TYPE tvarv_val,    " ABAP/4: Selection value (LOW or HIGH value, external format)
           high  TYPE tvarv_val,    " ABAP/4: Selection value (LOW or HIGH value, external format)
         END OF lty_range.
* <--- End of Change for Defect #4207_2 by HRUDRA

*Constant Declaration
  CONSTANTS:
      lc_error      TYPE sy-msgty   VALUE 'E',        "Error
      lc_msgno      TYPE sy-msgno   VALUE '000',      "Message No.
      lc_msgid      TYPE sy-msgid   VALUE 'ZOTC_MSG', "OTC Message ID

* ---> Begin of Change for Defect #4207_2 by HRUDRA
*Production system
    lc_prod_name   TYPE rvari_vnam VALUE 'ZOTC_FDD_0073_SYSID',  " ABAP: Name of Variant Variable
    lc_prod_doma   TYPE rvari_vnam VALUE 'ZOTC_FDD_0073_DOMAIN', " ABAP: Name of Variant Variable
    lc_split       TYPE xfeld      VALUE '@',                    " Checkbox
    lc_type        TYPE rsscr_kind VALUE 'P'.

  DATA:
    li_tvarv  TYPE STANDARD TABLE OF lty_tvarv INITIAL SIZE 0,
    li_range  TYPE STANDARD TABLE OF lty_range INITIAL SIZE 0,
    lwa_range TYPE lty_range.

  FIELD-SYMBOLS: <lfs_s_tvarv> TYPE lty_tvarv.

* <--- End of Change for Defect #4207_2 by HRUDRA

  DATA:
*Variables declarations
   lv_vkorg         TYPE vkorg,    "Sales Org.
   lv_ship_no       TYPE char10,   "Ship-to-Party Number
   lv_sold_no       TYPE char10,   "Bill-tp-Party Number
   lv_con_person    TYPE char10,   "Contact Person No.
   lv_vbeln         TYPE char10,   " Order No
   lv_bstkd         TYPE char35,   " Bstkd of type CHAR35
   lv_total_open_qty TYPE bbmng,              "
   lv_msg1          TYPE sy-msgv1, " Msg string for Contact person
   lv_msg2          TYPE sy-msgv1, " Msg string for Contact person Email
   lv_msg3          TYPE sy-msgv1, " Msg string for Contact person Email
*Structure Declarations
   lx_sold_to_addr  TYPE zotc_order_address_info, "Sold To Address
   lx_ship_to_addr  TYPE zotc_order_address_info, "Ship-To Address
   lx_contact_addr  TYPE zotc_order_address_info, "Contact Person Address
   lx_std_text      TYPE zotc_std_text_info,      "Stadard Text Information
*Internal Table Declarations
   li_item          TYPE   zotc_t_order_asn_item, "Item Data
   li_objtxt        TYPE  zotc_t_solisti1,        "To hold data in single line format
*Work Area Declaration
   lx_doc_chng      TYPE sodocchgi1 ##needed, "To hold  email data
* ---> Begin of Change for Defect #4207_2 by HRUDRA
*Production system
   lv_prod TYPE sysysid, " Name of the SAP System
*Mail Id
   lv_mail_id   TYPE string,
* Mail Domain
   lv_mail_domain TYPE char12, " Mail_domain of type CHAR12
* <--- End of Change for Defect #4207_2 by HRUDRA
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  lv_shipto_lang    TYPE langu, " Language Key
  lv_shipto_country TYPE land1, " Country Key
  lv_d3_lang_flag   TYPE char1. " D3_lang_flag of type CHAR1
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
*------------------------------------------------------------------------------*
Break kmishra.
*Subroutine to Fetch Data form database table & fill final Tables
  PERFORM     f_get_data         USING  fp_nast
                              CHANGING  lx_sold_to_addr
                                        lx_ship_to_addr
                                        lx_contact_addr
                                        li_item
                                        lv_ship_no
                                        lv_sold_no
                                        lv_vkorg
                                        lv_con_person
                                        lv_vbeln
                                        lv_bstkd
                                        lv_total_open_qty
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
                                        lv_shipto_lang
                                        lv_shipto_country.
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
*Nast Protocol update if Contact person is missing
  IF lv_con_person IS INITIAL.
    lv_msg1 = 'Contact person is missing in Sales Order.'(170).
    PERFORM f_protocol_update USING lc_msgid
                                    lc_msgno
                                    lc_error
                                    lv_msg1.
    fp_retcode = 1.
    RETURN.
  ENDIF. " IF lv_con_person IS INITIAL
* -->Begin of Change for Defect #4207_2 by Hrudra
*Nast Protocol update if contact person email id is not Biorad ID in non-production clients
  IF NOT lx_contact_addr-smtp_addr IS INITIAL.
    REFRESH li_range. CLEAR lwa_range.

    lwa_range-sign = if_cwd_constants=>c_sign_inclusive.
    lwa_range-option = if_cwd_constants=>c_option_equals.
    lwa_range-low = lc_prod_name. " 'ZOTC_FDD_0073_SYSID'
    APPEND lwa_range TO li_range.

    CLEAR lwa_range.
    lwa_range-sign = if_cwd_constants=>c_sign_inclusive.
    lwa_range-option = if_cwd_constants=>c_option_equals.
    lwa_range-low = lc_prod_doma. " 'ZOTC_FDD_0073_DOMAIN'
    APPEND lwa_range TO li_range.
*Get TVARVC Values
    SELECT name " ABAP: Name of Variant Variable
           type " ABAP: Type of selection
           numb " ABAP: Current selection number
           sign " ABAP: ID: I/E (include/exclude values)
           opti " ABAP: Selection option (EQ/BT/CP/...)
           low  " ABAP/4: Selection value (LOW or HIGH value, external format)
    FROM tvarvc " Table of Variant Variables (Client-Specific)
    INTO TABLE li_tvarv
    WHERE name IN li_range
      AND type EQ lc_type.

    IF sy-subrc EQ 0.
      SORT li_tvarv BY name.
      READ TABLE li_tvarv ASSIGNING <lfs_s_tvarv> WITH KEY name = lc_prod_name " 'ZOTC_FDD_0073_SYSID'
                                                           BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF <lfs_s_tvarv>-low NE sy-sysid.
          UNASSIGN <lfs_s_tvarv>.
          READ TABLE li_tvarv ASSIGNING <lfs_s_tvarv> WITH KEY name = lc_prod_doma " 'ZOTC_FDD_0073_DOMAIN'
                                                               BINARY SEARCH.
          IF sy-subrc EQ 0.

            CLEAR: lv_mail_id, lv_mail_domain.
            SPLIT lx_contact_addr-smtp_addr AT lc_split INTO lv_mail_id
                                                             lv_mail_domain.
*Translate Mail ZDomain into Upper case
            TRANSLATE lv_mail_domain TO UPPER CASE.
            IF lv_mail_domain <> <lfs_s_tvarv>-low . "'bio-rad.com'.
              lv_msg3 = 'Send mails only to Biorad ID in non production.'(172).
              PERFORM f_protocol_update USING lc_msgid
                                              lc_msgno
                                              lc_error
                                              lv_msg3.
              fp_retcode = 1.
              RETURN.
            ENDIF. " IF lv_mail_domain <> <lfs_s_tvarv>-low
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF <lfs_s_tvarv>-low NE sy-sysid
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF NOT lx_contact_addr-smtp_addr IS INITIAL
* <--- End of Change for Defect #4207_2 by Hrudra
*Nast Protocol update if contact person email id is missing
  IF lx_contact_addr-smtp_addr IS INITIAL.
    lv_msg2 = 'Contact person email id is missing.'(171).
    PERFORM f_protocol_update USING lc_msgid
                                    lc_msgno
                                    lc_error
                                    lv_msg2.
    fp_retcode = 1.
    RETURN.
  ENDIF. " IF lx_contact_addr-smtp_addr IS INITIAL

* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  CLEAR: lv_d3_lang_flag.
* <--- End of Change for D3_OTC_FDD_0073 by kmishra

*Subroutine to Read Standard Texts for Layout Labels
  PERFORM f_get_read_std_text USING     fp_nast lv_vkorg
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
                                        lv_shipto_lang
                                        lv_shipto_country
* <--- End of Change  for D3_OTC_FDD_0073 by kmishra
                              CHANGING  lx_std_text
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
                                        lv_d3_lang_flag.
* <--- End of Change for D3_OTC_FDD_0073 by kmishra

*Subroutine to Build HtML Email Body
  PERFORM    f_build_html_body   USING  lx_sold_to_addr
                                        lx_ship_to_addr
                                        lx_contact_addr
                                        li_item
                                        lv_ship_no
                                        lv_sold_no
                                        lv_vbeln
                                        lv_bstkd
                                        lv_total_open_qty
                                        lx_std_text
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
                                        lv_shipto_lang
                                        lv_shipto_country
                                        lv_d3_lang_flag
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
                              CHANGING  li_objtxt
                                        lx_doc_chng.
*Subroutine to Sent HtML Mail to Contact person
  PERFORM f_html_mail_sent USING        li_objtxt
                                        lx_doc_chng
                                        lx_contact_addr
                                        lc_msgid
                                        lc_msgno
                                        lc_error
                             CHANGING   fp_retcode.
ENDFORM. " F_PROCESSING
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*Fetching Data from Databse Tables & filling Final item table
*----------------------------------------------------------------------*
*      -->FP_NAST                 Output Messages
*      <--fp_sold_to_addr         Sold to Address Information
*      <--fp_ship_to_addr         Ship to zotc_order_address_info
*      <--fp_contact_addr         Contact zotc_order_address_info
*      <--fp_line_item            ASN Order Item data
*      <--fp_ship_no              Ship_no
*      <--fp_sold_no              Sold_no of type CHAR10
*      <--fp_vbeln                Sales Order No
*      <--fp_bstkd                Customer Po
*----------------------------------------------------------------------*
FORM f_get_data  USING    fp_nast   TYPE nast                          " Message Status
               CHANGING   fp_sold_to_addr TYPE zotc_order_address_info " Order General Address Information
                          fp_ship_to_addr TYPE zotc_order_address_info " Order General Address Information
                          fp_contact_addr TYPE zotc_order_address_info " Order General Address Information
                          fp_i_item       TYPE zotc_t_order_asn_item   " ASN Order Item data
                          fp_ship_no      TYPE char10                  " Ship_no
                          fp_sold_no      TYPE char10                  " Sold_no
                          fp_vkorg        TYPE vkorg                   " Sales Org.
                          fp_con_person   TYPE char10                  " Contact Person
                          fp_vbeln        TYPE char10                  " Order No
                          fp_bstkd        TYPE char35                  " Bstkd of type CHAR35
                          fp_total_open_qty TYPE bbmng                 " Quantity as Per Vendor Confirmation
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
                          fp_lv_shipto_lang TYPE langu     " Language Key
                          fp_lv_shipto_country TYPE land1. " Country Key
* * <--- End of Change for D3_OTC_FDD_0073 by kmishra
*Constants Declations
  CONSTANTS: lc_posnr   TYPE posnr_va VALUE '000000', "Header Item count
             lc_contact_ap TYPE parvw VALUE 'AP',     "Contact person
             lc_ship_to TYPE parvw    VALUE 'WE',     "Ship-to party
             lc_sold_to TYPE parvw    VALUE 'AG',     "Sold-to party
             lc_la      TYPE ebtyp    VALUE 'LA'.     "EBTYPE LA

*Data Declations
  DATA :lwa_item        TYPE zotc_order_asn_item, "Work Area-Item Data
        lv_tabix1       TYPE sytabix,             "Index of Internal Tables
        lv_sum_menge_la TYPE bbmng,               " Quantity as Per Vendor Confirmation
        lv_tot_po_qty   TYPE bbmng,               " Quantity as Per Vendor Confirmation
        lv_tot_shp_la   TYPE bbmng.               " Quantity as Per Vendor Confirmation

*TYPES Delaration
  TYPES :BEGIN OF lty_lips,
         vbeln TYPE vbeln_vl, " Sales and Distribution Document Number
         posnr TYPE posnr,    " Item number of the SD document
         erdat TYPE erdat,    " Date on Which Record Was Created
         lfimg TYPE lfimg,    " Actual quantity delivered (in sales units)
         meins TYPE meins,    " Base Unit of Measure
         vgbel TYPE vgbel ,   " Document number of the reference document
         vgpos TYPE ebelp,    " Item number of the reference item
         END OF lty_lips,
*Types for EKPO
         BEGIN OF lty_ekpo,
         ebeln TYPE ebeln, "
         ebelp TYPE ebelp, " Item Number of Purchasing Document
         menge TYPE bstmg, " Purchase Order Quantity
         END OF lty_ekpo,
*Types for LIKP
        BEGIN OF lty_likp,
         vbeln TYPE vbeln_vl, " Delivery
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
          vkorg TYPE vkorg, " Sales Organization
* <--- End of Change D3_OTC_FDD_0073 by kmishra
         lifex TYPE lifex, " External Identification of Delivery Note
         END OF lty_likp,
*Types for EKKN
        BEGIN OF lty_ekkn,
         ebeln TYPE ebeln,    " Purchasing Document Number
         ebelp TYPE ebelp,    " Item Number of Purchasing Document
         zekkn TYPE dzekkn,   " Sequential Number of Account Assignment
         menge TYPE menge_d,  " Quantity
         vbeln TYPE vbeln_co, " Sales and Distribution Document Number
         vbelp TYPE posnr_co, " Sales document item
        END OF lty_ekkn,
*Types for VBPA
        BEGIN OF lty_vbpa,
          vbeln  TYPE vbeln,      " Sales and Distribution Document Number
          posnr  TYPE posnr,      " Item number of the SD document
          parvw  TYPE parvw,      " Partner Function
          kunnr  TYPE kunnr,      "Customer Number
          parnr  TYPE parnr,      "Contact Person number
          adrnr  TYPE adrnr,      "Address
          adrnp  TYPE ad_persnum, " Person number
         END OF lty_vbpa,
*Types for ADR6
         BEGIN OF lty_adr6,
          addrnumber TYPE	ad_addrnum,
          persnumber TYPE ad_persnum, " Person number
          date_from	 TYPE ad_date_fr, " Valid-from date - in current Release only 00010101 possible
          consnumber TYPE	ad_consnum,
          smtp_addr	TYPE ad_smtpadr,
           END OF lty_adr6,
*Types for ADRC
       BEGIN OF lty_adrc,
         addrnumber TYPE ad_addrnum, " Address number
         date_from  TYPE ad_date_fr, " Valid-from date - in current Release only 00010101 possible
         nation     TYPE ad_nation,  " Version ID for International Addresses
         date_to    TYPE ad_date_to, " Valid-to date in current Release only 99991231 possible
         name1 TYPE ad_name1,        " Name 1
         name2 TYPE ad_name2,        " Name 2
         name3 TYPE ad_name3,        " Name 3
         name4 TYPE ad_name4,        " Name 4
         city1 TYPE ad_city1,        " City
         city2 TYPE ad_city2,        " District
         post_code1 TYPE ad_pstcd1,  " City postal code
         street     TYPE ad_street,  " Street
         house_num1 TYPE ad_hsnm1,   " House Number
         house_num2 TYPE ad_hsnm2,   " House number supplement
         str_suppl1 TYPE ad_strspp1, " Street 2
         str_suppl2 TYPE ad_strspp2, " Street 3
         building   TYPE ad_bldng,   " Building (Number or Code)
         floor      TYPE ad_floor,   " Floor in building
         roomnumber TYPE ad_roomnum, " Room or Appartment Number
         country TYPE land1,         " Country Key
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
         langu TYPE spras, " Language Key
* <--- End of Change D3_OTC_FDD_0073 by kmishra
         region  TYPE regio, " Region (State, Province, County)
       END OF lty_adrc,
*Types for t005U
       BEGIN OF lty_t005u,
         spras  TYPE  spras,  " Language Key
         land1  TYPE land1,   " Country Key
         bland  TYPE regio,   " Region (State, Province, County)
         bezei  TYPE bezei20, " Description
       END OF lty_t005u,
*Types for VBKD
         BEGIN OF lty_vbkd,
          vbeln TYPE vbeln, " Sales and Distribution Document Number
          bstkd TYPE bstkd, " Customer purchase order number
         END OF lty_vbkd,
*Types for VBAP
         BEGIN OF lty_vbap,
          vbeln TYPE vbeln, " Sales and Distribution Document Number
          posnr TYPE posnr, " Item number of the SD document
          matnr TYPE matnr, " Material Number
          arktx TYPE arktx, " Short text for sales order item
         END OF lty_vbap,
*Types for VBAK
         BEGIN OF lty_vbak,
          vbeln TYPE vbeln, " Sales and Distribution Document Number
          vkorg TYPE vkorg, " Sales Organization
          vsbed TYPE vsbed, " Shipping Conditions
         END OF   lty_vbak,
*Types for EKES
        BEGIN OF lty_ekes,
          ebeln TYPE ebeln,    " Purchasing Document Number
          ebelp TYPE ebelp,    " Item Number of Purchasing Document
          etens TYPE etens,    " Sequential Number of Vendor Confirmation
          ebtyp TYPE ebtyp,    " Confirmation Category
          eindt TYPE bbein,    " Delivery Date of Vendor Confirmation
          menge TYPE bbmng,    " Material Master View: Alternative Quantity of Material
          vbeln TYPE vbeln_vl, " Sales and Distribution Document Number
          vbelp TYPE posnr_vl, " Sales document item
         END OF lty_ekes,
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
        BEGIN OF lty_vgbel,
         vbeln TYPE vbeln_vl,         " Delivery
         vgbel TYPE vgbel,            " Document number of the reference document
        END OF lty_vgbel,
        BEGIN OF lty_ekkn_vbeln,
          ebeln TYPE ebeln,           " Purchasing Document Number
          vbeln TYPE vbeln_co,        " Sales and Distribution Document Number
        END OF lty_ekkn_vbeln,
        BEGIN OF lty_vbpa_adrnr,
          vbeln TYPE vbeln,           " Sales and Distribution Document Number
          parvw TYPE parvw,           " Partner Function
          adrnr TYPE adrnr,           " Address
        END OF lty_vbpa_adrnr,
        BEGIN OF lty_adrc_shipto,
          addrnumber TYPE ad_addrnum, " Address number
          country TYPE land1,         " Country Key
          langu TYPE spras,           " Language Key
        END OF lty_adrc_shipto.
* <--- End of Change D3_OTC_FDD_0073 by kmishra

*Table Types Declarations
  TYPES:  lty_t_lips TYPE STANDARD TABLE OF lty_lips,   " Table type for lips
          lty_t_ekpo TYPE STANDARD TABLE OF lty_ekpo,   " Table type for
          lty_t_vbpa TYPE STANDARD TABLE OF lty_vbpa,   " Table type for vbpa
          lty_t_adr6 TYPE STANDARD TABLE OF lty_adr6,   " Table type for adr6
          lty_t_adrc TYPE STANDARD TABLE OF lty_adrc,   " Table type for adrc
          lty_t_vbap TYPE STANDARD TABLE OF lty_vbap,   " Table type for vbap
          lty_t_vbak TYPE STANDARD TABLE OF lty_vbak,   " Table type for vbap
          lty_t_ekes TYPE STANDARD TABLE OF lty_ekes,   " Table type for ekes
          lty_t_vbkd TYPE STANDARD TABLE OF lty_vbkd,   " Table type for vbkd
          lty_t_ekkn TYPE STANDARD TABLE OF lty_ekkn,   " Table type for ekkn
          lty_t_t005u TYPE STANDARD TABLE OF lty_t005u. " Table type for t005u
*Internal Tables Declarations
  DATA :  li_lips TYPE  lty_t_lips,                 "Internal Table for Lips
          li_ekpo TYPE  lty_t_ekpo,                 "Internal Table for ekpo
          li_vbpa TYPE  lty_t_vbpa,                 "Internal Table for vbpa
          li_adr6 TYPE  lty_t_adr6,                 "Internal Table for ADR6
          li_adrc TYPE  lty_t_adrc,                 "Internal Table for adrc
          li_vbap TYPE  lty_t_vbap,                 "Internal Table for vbap
          li_vbak TYPE  lty_t_vbak,                 "Internal Table for vbak
          li_ekes TYPE  lty_t_ekes,                 "Internal Table for ekes
          li_vbkd TYPE  lty_t_vbkd,                 "Internal Table for vbkd
          li_ekes_tmp TYPE  lty_t_ekes,             "Internal Table for ekes
          li_ekkn     TYPE  lty_t_ekkn ,            "Internal Table for ekkn
          li_t005u    TYPE  lty_t_t005u ,           "Internal Table for t005u
          li_lines    TYPE STANDARD TABLE OF tline, "Internal Table for Attention To Sales text
*Work Area Declaration
          lwa_likp    TYPE lty_likp,
          lv_tdspras  TYPE spras,    " Language Key
          lv_name     TYPE tdobname, " Name
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
##needed  lv_adrnr TYPE adrnr, " Address
          lwa_vgbel TYPE lty_vgbel,
          lwa_ekkn_vbeln TYPE lty_ekkn_vbeln,
          lwa_vbpa_adrnr TYPE lty_vbpa_adrnr,
          lwa_adrc_shipto TYPE lty_adrc_shipto.
* <--- End of Change D3_OTC_FDD_0073 by kmishra

*CONSTANTS Declarations
  CONSTANTS: lc_id     TYPE tdid     VALUE '0002', " Attention to text
             lc_object TYPE tdobject VALUE 'VBBK'. " Sales Header texts
*Field symbols
  FIELD-SYMBOLS:
    <lfs_lips>     TYPE lty_lips,
    <lfs_ekkn>     TYPE lty_ekkn,
    <lfs_ekpo>     TYPE lty_ekpo,
    <lfs_vbpa>     TYPE lty_vbpa,
    <lfs_ekes>     TYPE lty_ekes,
    <lfs_ekes_tmp> TYPE lty_ekes,
    <lfs_vbkd>     TYPE lty_vbkd,
    <lfs_vbap>     TYPE lty_vbap,
    <lfs_vbak>     TYPE lty_vbak,
    <lfs_adrc>     TYPE lty_adrc,
    <lfs_adr6>     TYPE lty_adr6,
    <lfs_t005u>    TYPE lty_t005u,
    <lfs_lines>    TYPE tline. " SAPscript: Text Lines
*----------------------------------------------------------------------------*
*Fetching data from databse Tables
*Fetching data from Likp Table
  SELECT SINGLE vbeln " Delivery
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
                vkorg
* <--- End of Change D3_OTC_FDD_0073 by kmishra
                lifex " External Identification of Delivery Note
           FROM likp  " SD Document: Delivery Header Data
           INTO lwa_likp
          WHERE vbeln = fp_nast-objky.
  IF sy-subrc = 0.
*Fetching data from LIPS Table
    SELECT vbeln " Delivery
           posnr " Delivery Item
           erdat " Date on Which Record Was Created
           lfimg " Actual quantity delivered (in sales units)
           meins " Base Unit of Measure
           vgbel " Document number of the reference document
           vgpos " Item number of the reference item
         FROM lips INTO TABLE li_lips
         WHERE vbeln = lwa_likp-vbeln .
    IF sy-subrc = 0.
      SORT li_lips BY vbeln.
    ENDIF. " IF sy-subrc = 0
    IF li_lips[] IS NOT INITIAL.
*Fetching data from EKES Table
      SELECT  ebeln " Purchasing Document Number
              ebelp " Item Number of Purchasing Document
              etens " Sequential Number of Vendor Confirmation
              ebtyp " Confirmation Category
              eindt " Delivery Date of Vendor Confirmation
              menge " Quantity as Per Vendor Confirmation
              vbeln " Delivery
              vbelp " Delivery Item
        FROM ekes INTO TABLE li_ekes
        FOR ALL ENTRIES IN li_lips
        WHERE ebeln = li_lips-vgbel.
*        AND   ebelp = li_lips-vgpos.
      IF sy-subrc = 0.
        li_ekes_tmp[] = li_ekes[].
      ENDIF. " IF sy-subrc = 0

*Fetching data from EKKN Table
      SELECT ebeln " Purchasing Document Number
             ebelp " Item Number of Purchasing Document
             zekkn " Sequential Number of Account Assignment
             menge " Quantity
             vbeln " Sales and Distribution Document Number
             vbelp " Sales Document Item
        FROM ekkn INTO TABLE li_ekkn
        FOR ALL ENTRIES IN li_lips
        WHERE ebeln = li_lips-vgbel
        AND   ebelp = li_lips-vgpos.

      IF  sy-subrc = 0.
*Sort & DELETE ADJACENT DUPLICATES FROM li_ekkn COMPARING vbeln vbelp.
        SORT li_ekkn BY vbeln vbelp.
        DELETE ADJACENT DUPLICATES FROM li_ekkn COMPARING vbeln vbelp.
        IF NOT li_ekkn[] IS INITIAL.
*Fetching data from VBPA Table
          SELECT vbeln " Sales and Distribution Document Number
                 posnr " Item number of the SD document
                 parvw " Partner Function
                 kunnr " Customer Number
                 parnr " Number of contact person
                 adrnr " Address
                 adrnp " Person number
             FROM vbpa INTO TABLE li_vbpa
             FOR ALL ENTRIES IN li_ekkn
             WHERE vbeln = li_ekkn-vbeln
               AND posnr = lc_posnr
               AND parvw IN (lc_contact_ap,
                             lc_sold_to,
                             lc_ship_to ).
          IF sy-subrc = 0.
            SORT li_vbpa BY vbeln.
          ENDIF. " IF sy-subrc = 0
*Fetching data from VBAP Table
          SELECT vbeln " Sales Document
                 posnr " Sales Document Item
                 matnr " Material Number
                 arktx " Short text for sales order item
            FROM vbap INTO TABLE li_vbap
            FOR ALL ENTRIES IN li_ekkn
            WHERE vbeln = li_ekkn-vbeln
            AND   posnr = li_ekkn-vbelp.
          IF sy-subrc = 0.
            SORT li_vbap BY vbeln posnr.
          ENDIF. " IF sy-subrc = 0
*Fetching data from VBAK Table
          SELECT vbeln " Sales Document
                 vkorg " Sales Organization
                 vsbed " Shipping Conditions
        FROM vbak INTO TABLE li_vbak
        FOR ALL ENTRIES IN li_ekkn
        WHERE vbeln = li_ekkn-vbeln.

          IF sy-subrc = 0.
            SORT li_vbak BY vbeln.
          ENDIF. " IF sy-subrc = 0
*Fetching data from VBKD Table
          SELECT vbeln " Sales and Distribution Document Number
                 bstkd " Customer purchase order number
          FROM vbkd INTO TABLE li_vbkd
          FOR ALL ENTRIES IN li_ekkn
          WHERE vbeln =  li_ekkn-vbeln
            AND posnr = lc_posnr .
          IF sy-subrc = 0.
            SORT li_vbkd BY vbeln.
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF NOT li_ekkn[] IS INITIAL

*Fetching data from EKPO Table
        SELECT ebeln " Purchasing Document Number
               ebelp " Item Number of Purchasing Document
               menge " Purchase Order Quantity
          FROM ekpo INTO TABLE li_ekpo
          FOR ALL ENTRIES IN li_ekkn
          WHERE ebeln = li_ekkn-ebeln.
        IF sy-subrc = 0.
          SORT li_ekpo BY ebeln ebelp.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc = 0

      IF li_vbpa IS NOT INITIAL.
*Fetch Contact Person E-Mail Address
        SELECT addrnumber " Address number
               persnumber " Person number
               date_from  " Valid-from date - in current Release only 00010101 possible
               consnumber " Sequence Number
               smtp_addr  " E-Mail Address
        INTO TABLE li_adr6
        FROM adr6         " E-Mail Addresses (Business Address Services)
        FOR ALL ENTRIES IN li_vbpa
        WHERE addrnumber = li_vbpa-adrnr
         AND  persnumber = li_vbpa-adrnp.
        IF sy-subrc = 0.
          SORT li_adr6 BY addrnumber.
        ENDIF. " IF sy-subrc = 0
*Fetching data from ADRC Table
        SELECT addrnumber " Address number
               date_from  " Valid-from date - in current Release only 00010101 possible
               nation     " Version ID for International Addresses
               date_to    " Valid-to date in current Release only 99991231 possible
               name1      " Name 1
               name2      " Name 2
               name3      " Name 3
               name4      " Name 4
               city1      " City
               city2      " District
               post_code1 " City postal code
               street     " Street
               house_num1 " House Number
               house_num2 " House number supplement
               str_suppl1 " Street 2
               str_suppl2 " Street 3
               building   " Building (Number or Code)
               floor      " Floor in building
               roomnumber " Room or Appartment Number
               country    " Country Key
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
               langu
* <--- End of Change D3_OTC_FDD_0073 by kmishra
               region " Region (State, Province, County)
          FROM adrc INTO TABLE li_adrc
          FOR ALL ENTRIES IN li_vbpa
          WHERE addrnumber = li_vbpa-adrnr.
        IF sy-subrc = 0.
*Delete address lines where the valid date is greater then current date
          DELETE li_adrc WHERE date_from GT sy-datum.
          DELETE li_adrc WHERE date_to   LT sy-datum.
        ENDIF. " IF sy-subrc = 0
*Fetching data from t005U table
        IF li_adrc[] IS NOT INITIAL.
          SELECT spras " Language Key
                 land1 " Country Key
                 bland " Region (State, Province, County)
                 bezei " Description
            FROM t005u " Taxes: Region Key: Texts
            INTO TABLE li_t005u
            FOR ALL ENTRIES IN li_adrc
            WHERE spras = fp_nast-spras
             AND  land1 = li_adrc-country
             AND  bland = li_adrc-region.
          IF sy-subrc = 0.
            SORT li_t005u BY land1.
          ENDIF. " IF sy-subrc = 0

        ENDIF. " IF li_adrc[] IS NOT INITIAL
      ENDIF. " IF li_vbpa IS NOT INITIAL
    ENDIF. " IF li_lips[] IS NOT INITIAL
  ENDIF. " IF sy-subrc = 0

* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*** Logic to fetch ship to customer langauge***
*Fetching Delivery and document no from table LIPS
  SELECT vbeln " Delivery
         vgbel " Document number of the reference document
  FROM lips    " SD document: Delivery: Item data
  INTO lwa_vgbel
  UP TO 1 ROWS
  WHERE vbeln = fp_nast-objky.
  ENDSELECT.
  IF sy-subrc EQ 0.
*If document no. exist in LIPS table then fetching sales and Distribution Document Number from table EKKN
*on the basis of Document number of the reference document
    SELECT ebeln " Purchasing Document Number
           vbeln " Sales and Distribution Document Number
    FROM ekkn    " Account Assignment in Purchasing Document
    INTO lwa_ekkn_vbeln
    UP TO 1 ROWS
    WHERE ebeln = lwa_vgbel-vgbel.
    ENDSELECT.
*If data found in table EKKN then fetching address no from VBPA table for ship to party
    IF sy-subrc EQ 0.
      SELECT vbeln " Sales and Distribution Document Number
             parvw " Partner Function
             adrnr " Address
        FROM vbpa  " Sales Document: Partner
        INTO lwa_vbpa_adrnr
        UP TO 1 ROWS
        WHERE vbeln = lwa_ekkn_vbeln-vbeln
        AND parvw = lc_ship_to.
      ENDSELECT.
      IF sy-subrc EQ 0.
*Fetching Country and langauge from ADRC table for ship to
        SELECT   addrnumber " Address number
                 country    " Country Key
                 langu      " Language Key
          FROM adrc         " Addresses (Business Address Services)
          INTO lwa_adrc_shipto
          UP TO 1 ROWS
          WHERE addrnumber =  lwa_vbpa_adrnr-adrnr.
        ENDSELECT.
        IF sy-subrc EQ 0.
          fp_lv_shipto_lang = lwa_adrc_shipto-langu  .
          fp_lv_shipto_country  =  lwa_adrc_shipto-country.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
* <--- End of Change D3_OTC_FDD_0073 by kmishra

*Filling final line item table
*Sorting all internal tables
  SORT li_lips BY vgbel vgpos.
  SORT li_ekkn BY ebeln ebelp.
  SORT li_vbap BY vbeln posnr.
  SORT li_ekes BY vbeln vbelp.
  SORT li_vbpa BY vbeln parvw.
  SORT li_vbak BY vbeln.
  SORT li_adrc BY addrnumber.
  SORT li_t005u BY land1 bland.
  SORT li_vbkd BY vbeln.
  SORT li_adr6 BY addrnumber persnumber.
  SORT li_ekes_tmp BY ebeln ebelp.
  SORT li_ekpo BY ebeln ebelp.

*Loop process for line item table population
  LOOP AT li_ekkn  ASSIGNING <lfs_ekkn>.
*READ  Delivery item TABLE
    READ TABLE li_lips ASSIGNING <lfs_lips>
    WITH KEY  vgbel = <lfs_ekkn>-ebeln
              vgpos = <lfs_ekkn>-ebelp
                       BINARY SEARCH.
    IF sy-subrc = 0.
*Sales order & Line Item
      lwa_item-vbeln = fp_vbeln = <lfs_ekkn>-vbeln.
      lwa_item-vbelp =  <lfs_ekkn>-vbelp.
*Shipped Qty
      lwa_item-lfimg =  <lfs_lips>-lfimg.
*Sales Unit
      lwa_item-meins =  <lfs_lips>-meins.
**Shipped Date
*      lwa_item-erdat =  <lfs_lips>-erdat.
*Tracking Number
      IF lwa_likp-vbeln = <lfs_lips>-vbeln.
        lwa_item-lifex    = lwa_likp-lifex.
      ENDIF. " IF lwa_likp-vbeln = <lfs_lips>-vbeln
*READ TABLE VENDOR cONFIRMATION
      READ TABLE li_ekes ASSIGNING <lfs_ekes>
      WITH KEY vbeln = <lfs_lips>-vbeln
               vbelp = <lfs_lips>-posnr.
*                        BINARY SEARCH.
*Order Qty (EA)
      IF sy-subrc = 0.
        lwa_item-menge = <lfs_ekkn>-menge.
**Shipped Date
        lwa_item-erdat = <lfs_ekes>-eindt.

      ENDIF. " IF sy-subrc = 0

      READ TABLE li_ekes_tmp ASSIGNING <lfs_ekes_tmp>
      WITH KEY ebeln = <lfs_lips>-vgbel
                       ebelp = <lfs_lips>-vgpos
                       BINARY SEARCH.
      IF sy-subrc = 0.
*READ TABLE EKES for open Quantity
        lv_tabix1 = sy-tabix.
        LOOP AT li_ekes_tmp ASSIGNING <lfs_ekes_tmp> FROM lv_tabix1.

          IF   <lfs_ekes_tmp>-ebeln <> <lfs_lips>-vgbel
           OR  <lfs_ekes_tmp>-ebelp <> <lfs_lips>-vgpos.
            EXIT.
          ENDIF. " IF <lfs_ekes_tmp>-ebeln <> <lfs_lips>-vgbel

          IF <lfs_ekes>-ebtyp = lc_la. "ebtype (LA)
            lv_sum_menge_la = lv_sum_menge_la + <lfs_ekes_tmp>-menge.

            IF  <lfs_ekes_tmp>-vbeln EQ <lfs_lips>-vbeln
            AND <lfs_ekes_tmp>-vbelp EQ <lfs_lips>-posnr.
              EXIT.
            ENDIF. " IF <lfs_ekes_tmp>-vbeln EQ <lfs_lips>-vbeln
          ENDIF. " IF <lfs_ekes>-ebtyp = lc_la
        ENDLOOP. " LOOP AT li_ekes_tmp ASSIGNING <lfs_ekes_tmp> FROM lv_tabix1
*Calculate open Quantity = (Order qty - Ekes qty for LA type)
        lwa_item-open_qty = lwa_item-menge - lv_sum_menge_la.
        CLEAR : lv_sum_menge_la.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0

*Read VBAP table
    READ TABLE li_vbap ASSIGNING <lfs_vbap>
    WITH KEY vbeln = <lfs_ekkn>-vbeln
             posnr = <lfs_ekkn>-vbelp
                       BINARY SEARCH.
    IF sy-subrc = 0.
*Material
      lwa_item-matnr = <lfs_vbap>-matnr.
*Description
      lwa_item-arktx = <lfs_vbap>-arktx.
    ENDIF. " IF sy-subrc = 0
*Read Shipping condtion from Vbak
    READ TABLE li_vbak ASSIGNING <lfs_vbak>
      WITH KEY vbeln = <lfs_ekkn>-vbeln
                         BINARY SEARCH.
    IF sy-subrc = 0.
*Shipping Condition
      lwa_item-vsbed = <lfs_vbak>-vsbed.
      fp_vkorg     = <lfs_vbak>-vkorg.
    ENDIF. " IF sy-subrc = 0
*Material
    lwa_item-matnr = <lfs_vbap>-matnr.
*Read VBPA Partner Data for sold to party
    READ TABLE li_vbpa ASSIGNING <lfs_vbpa>
    WITH KEY vbeln = <lfs_ekkn>-vbeln
             parvw = lc_sold_to
                     BINARY SEARCH.
    IF sy-subrc = 0.
*Sold to to party
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = <lfs_vbpa>-kunnr
        IMPORTING
          output = fp_sold_no.
*Read Sold to customer Address details
      READ TABLE li_adrc ASSIGNING <lfs_adrc>
      WITH KEY addrnumber = <lfs_vbpa>-adrnr
                             BINARY SEARCH.
      IF sy-subrc = 0.
*Filling sold to party address details from adrc
        fp_sold_to_addr-adrnr       =  <lfs_adrc>-addrnumber.
        fp_sold_to_addr-date_from   =  <lfs_adrc>-date_from.
        fp_sold_to_addr-nation      =  <lfs_adrc>-nation.
        fp_sold_to_addr-date_to     =  <lfs_adrc>-date_to.
        fp_sold_to_addr-name1       =  <lfs_adrc>-name1.
        fp_sold_to_addr-name2       =  <lfs_adrc>-name2.
        fp_sold_to_addr-name3       =  <lfs_adrc>-name3.
        fp_sold_to_addr-name4       =  <lfs_adrc>-name4.
        fp_sold_to_addr-city1       =  <lfs_adrc>-city1.
        fp_sold_to_addr-city2       =  <lfs_adrc>-city2.
        fp_sold_to_addr-post_code1  =  <lfs_adrc>-post_code1.
        fp_sold_to_addr-street      =  <lfs_adrc>-street.
        fp_sold_to_addr-house_num1  =  <lfs_adrc>-house_num1.
        fp_sold_to_addr-house_num2  =  <lfs_adrc>-house_num2.
        fp_sold_to_addr-str_suppl1  =  <lfs_adrc>-str_suppl1.
        fp_sold_to_addr-str_suppl2  =  <lfs_adrc>-str_suppl2.
        fp_sold_to_addr-building    =  <lfs_adrc>-building.
        fp_sold_to_addr-floor       =  <lfs_adrc>-floor.
        fp_sold_to_addr-roomnumber  =  <lfs_adrc>-roomnumber.
        fp_sold_to_addr-country     =  <lfs_adrc>-country.
        fp_sold_to_addr-region      =  <lfs_adrc>-region.
*Read sold to Region
        READ TABLE li_t005u ASSIGNING <lfs_t005u>
        WITH KEY land1 = <lfs_adrc>-country
                 bland = <lfs_adrc>-region
                 BINARY SEARCH.
        IF sy-subrc = 0.
          fp_sold_to_addr-bezei = <lfs_t005u>-bezei .
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0
*Read VBPA Partner Data for ship to party
    READ TABLE li_vbpa ASSIGNING <lfs_vbpa>
    WITH KEY vbeln = <lfs_ekkn>-vbeln
             parvw = lc_ship_to
                     BINARY SEARCH.
    IF sy-subrc = 0.
*Ship to to party
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = <lfs_vbpa>-kunnr
        IMPORTING
          output = fp_ship_no.
**Read ship to party Address details
      READ TABLE li_adrc ASSIGNING <lfs_adrc>
      WITH KEY addrnumber = <lfs_vbpa>-adrnr
                             BINARY SEARCH.
      IF sy-subrc = 0.
*Filling ship to party address details from adrc
        fp_ship_to_addr-adrnr       =  <lfs_adrc>-addrnumber.
        fp_ship_to_addr-date_from   =  <lfs_adrc>-date_from.
        fp_ship_to_addr-nation      =  <lfs_adrc>-nation.
        fp_ship_to_addr-date_to     =  <lfs_adrc>-date_to.
        fp_ship_to_addr-name1       =  <lfs_adrc>-name1.
        fp_ship_to_addr-name2       =  <lfs_adrc>-name2.
        fp_ship_to_addr-name3       =  <lfs_adrc>-name3.
        fp_ship_to_addr-name4       =  <lfs_adrc>-name4.
        fp_ship_to_addr-city1       =  <lfs_adrc>-city1.
        fp_ship_to_addr-city2       =  <lfs_adrc>-city2.
        fp_ship_to_addr-post_code1  =  <lfs_adrc>-post_code1.
        fp_ship_to_addr-street      =  <lfs_adrc>-street.
        fp_ship_to_addr-house_num1  =  <lfs_adrc>-house_num1.
        fp_ship_to_addr-house_num2  =  <lfs_adrc>-house_num2.
        fp_ship_to_addr-str_suppl1  =  <lfs_adrc>-str_suppl1.
        fp_ship_to_addr-str_suppl2  =  <lfs_adrc>-str_suppl2.
        fp_ship_to_addr-building    =  <lfs_adrc>-building.
        fp_ship_to_addr-floor       =  <lfs_adrc>-floor.
        fp_ship_to_addr-roomnumber  =  <lfs_adrc>-roomnumber.
        fp_ship_to_addr-country     =  <lfs_adrc>-country.
        fp_ship_to_addr-region      =  <lfs_adrc>-region.
*Read ship to Region
        READ TABLE li_t005u ASSIGNING <lfs_t005u>
        WITH KEY land1 = fp_ship_to_addr-country
                 bland = fp_ship_to_addr-region
                         BINARY SEARCH.
        IF sy-subrc = 0.
          fp_ship_to_addr-bezei = <lfs_t005u>-bezei .
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0
*Read VBPA Partner Data for Contact person
    READ TABLE li_vbpa ASSIGNING <lfs_vbpa>
    WITH KEY vbeln = <lfs_ekkn>-vbeln
             parvw = lc_contact_ap
                      BINARY SEARCH.
    IF sy-subrc = 0.
*Contact Person
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = <lfs_vbpa>-parnr
        IMPORTING
          output = fp_con_person.

*Read Contact person Address details
      READ TABLE li_adrc ASSIGNING <lfs_adrc>
      WITH KEY addrnumber = <lfs_vbpa>-adrnr
                             BINARY SEARCH.
      IF sy-subrc = 0.
*Filling contactperson Name from adrc
        fp_contact_addr-name1 = <lfs_adrc>-name1.
        READ TABLE li_adr6 ASSIGNING <lfs_adr6>
        WITH KEY addrnumber = <lfs_vbpa>-adrnr
                 persnumber = <lfs_vbpa>-adrnp
                               BINARY SEARCH.
        IF sy-subrc = 0.
**Fetch Contact Person E-Mail Address
          fp_contact_addr-smtp_addr = <lfs_adr6>-smtp_addr.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0
**Read Business data
    READ TABLE li_vbkd ASSIGNING <lfs_vbkd>
    WITH KEY vbeln = <lfs_ekkn>-vbeln
                     BINARY SEARCH.
    IF sy-subrc = 0.
      fp_bstkd = <lfs_vbkd>-bstkd .
    ENDIF. " IF sy-subrc = 0
    APPEND lwa_item TO fp_i_item.
*CLEAR all work Areas
    CLEAR: lwa_item.
  ENDLOOP. " LOOP AT li_ekkn ASSIGNING <lfs_ekkn>


* ---> Begin of Change for D2_OTC_FDD_0073 Defect # 5847 by APODDAR
  SORT li_ekes BY ebeln ebelp.
* <--- End    of Change for D2_OTC_FDD_0073 Defect # 5847 by APODDAR

*Shippment Status
  LOOP AT li_ekpo ASSIGNING <lfs_ekpo>  .
    lv_tot_po_qty = lv_tot_po_qty + <lfs_ekpo>-menge.
    READ TABLE li_ekes ASSIGNING <lfs_ekes_tmp>
          WITH KEY ebeln = <lfs_ekpo>-ebeln
                           ebelp = <lfs_ekpo>-ebelp
                           BINARY SEARCH.
    IF sy-subrc = 0.
*READ TABLE EKES for shipped Quantity
      CLEAR lv_tabix1.
      lv_tabix1 = sy-tabix.
      LOOP AT li_ekes_tmp ASSIGNING <lfs_ekes_tmp> FROM lv_tabix1.

        IF   <lfs_ekes_tmp>-ebeln <> <lfs_ekpo>-ebeln
         OR  <lfs_ekes_tmp>-ebelp <> <lfs_ekpo>-ebelp.
*          CONTINUE.   " Defect 5847
          EXIT. " Defect 5847
        ENDIF. " IF <lfs_ekes_tmp>-ebeln <> <lfs_ekpo>-ebeln

* Begin of Change for Defect 5847
*        IF  <lfs_ekpo>-menge = lv_sum_menge_la.
*          EXIT.
*        ENDIF. " IF <lfs_ekpo>-menge = lv_sum_menge_la
*
*        IF  <lfs_ekes_tmp>-vbeln EQ <lfs_lips>-vbeln
*         AND <lfs_ekes_tmp>-vbelp EQ <lfs_lips>-posnr.
*          IF <lfs_ekes>-ebtyp = lc_la. "ebtype (LA)
*            lv_sum_menge_la = lv_sum_menge_la + <lfs_ekes_tmp>-menge.
*          ENDIF. " IF <lfs_ekes_tmp>-vbeln EQ <lfs_lips>-vbeln
*        ENDIF. " LOOP AT li_ekes_tmp ASSIGNING <lfs_ekes_tmp> FROM lv_tabix1
* End of Change for Defect 5847

        IF <lfs_ekes>-ebtyp = lc_la. "ebtype (LA)
          lv_tot_shp_la = lv_tot_shp_la + <lfs_ekes_tmp>-menge.
* Begin of Change for Defect 5847
*          IF  <lfs_ekes_tmp>-vbeln EQ <lfs_lips>-vbeln
*          AND <lfs_ekes_tmp>-vbelp EQ <lfs_lips>-posnr.
*            EXIT.
*          ENDIF. " IF <lfs_ekes_tmp>-vbeln EQ <lfs_lips>-vbeln
* End of Change for Defect 5847
        ENDIF. " IF <lfs_ekes>-ebtyp = lc_la
      ENDLOOP. " LOOP AT li_ekes_tmp ASSIGNING <lfs_ekes_tmp> FROM lv_tabix1
    ENDIF. " IF sy-subrc = 0
  ENDLOOP. " LOOP AT li_ekpo ASSIGNING <lfs_ekpo>

*Total Open Qty for sales order level
*Total po qty.  minus total shipped qty.
  fp_total_open_qty = lv_tot_po_qty - lv_tot_shp_la.
*Get header text(Attention to) for sales order
*  For dynamic text ( eg.Kindtext) we taken tdspras value
*  for language to read values usung 'RED_TEXT'
  CLEAR: lv_name.
  REFRESH: li_lines[].
  SELECT SINGLE tdspras FROM stxh " STXD SAPscript text file header
    INTO lv_tdspras
    WHERE tdobject = lc_object
     AND  tdname   = fp_vbeln
    AND   tdid     = lc_id.
  IF sy-subrc = 0.

  ENDIF. " IF sy-subrc = 0
  lv_name = fp_vbeln. "sales order
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id
      language                = lv_tdspras
      name                    = lv_name
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      IF sy-tabix = 1.
        MOVE <lfs_lines>-tdline TO fp_ship_to_addr-kind_text.
      ELSE. " ELSE -> IF sy-tabix = 1
        CONCATENATE fp_ship_to_addr-kind_text <lfs_lines>-tdline
        INTO fp_ship_to_addr-kind_text
        SEPARATED BY space.
      ENDIF. " IF sy-tabix = 1
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0

ENDFORM. " F_GET_DATA
*&---------------------------------------------------------------------*
*&      Form  F_GET_READ_STD_TEXT
*&---------------------------------------------------------------------*
*    Read Standard Texts for Layouy Labels
*----------------------------------------------------------------------*
*      -->FP_NAST          Output Messages
*      <--fp_std_text      Standard Text Info
*----------------------------------------------------------------------*
FORM f_get_read_std_text   USING fp_nast     TYPE nast  " Message Status
                                 lv_vkorg    TYPE vkorg " Sales. Org.
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
                                 fp_lv_shipto_lang TYPE langu  ##needed   " Language Key
                                 fp_lv_shipto_country TYPE land1 ##needed " Country Key
* ---> End of Change for D3_OTC_FDD_0073 by kmishra
                        CHANGING fp_std_text TYPE zotc_std_text_info " Stadard Text Information
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
                                 fp_lv_d3_lang_flag TYPE char1. " Lv_d3_lang_flag of type CHAR1
* ---> End of Change for D3_OTC_FDD_0073 by kmishra
*Data Declarations
  DATA:li_lines  TYPE STANDARD TABLE OF tline,               " SAPscript: Text Lines
       li_enh_status TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
       lv_spras  TYPE sylangu.                               " Language Key of Current Text Environment


*Field symbols
  FIELD-SYMBOLS: <lfs_lines> TYPE tline,                "SAPscript: Text Lines
                 <lfs_enh_status> TYPE zdev_enh_status. " Enhancement Status
*Constants for Standard Texts
  CONSTANTS :
  lc_object TYPE tdobject VALUE 'TEXT' ##needed,                           "Texts: Application Object
  lc_id     TYPE tdid     VALUE 'ST'   ##needed,                           "Text ID
  lc_biorad_ship_notif TYPE tdobname VALUE 'ZOTC_0073_BIORAD_SHIP_NOTIF',  "STD.text for Ship.Notification
  lc_contact_us TYPE thead-tdname        VALUE 'ZOTC_0073_CONTACT_US',     "STD.text for Contact Us
  lc_thanks_note TYPE thead-tdname       VALUE 'ZOTC_0073_THANKS_NOTE',    "STD.text for thanks Notes
  lc_contact_person TYPE thead-tdname    VALUE 'ZOTC_0073_CONTACT_PERSON', "STD.text for contact person
  lc_contact_email TYPE thead-tdname     VALUE  'ZOTC_0073_CONTACT_EMAIL', "STD.text for contact Email
  lc_your_po TYPE thead-tdname  VALUE 'ZOTC_0073_YOUR_PO',                 "STD.text for Your Po
  lc_order TYPE thead-tdname    VALUE 'ZOTC_0073_ORDER',                   "STD.text for Order
  lc_sold_to TYPE thead-tdname  VALUE 'ZOTC_0073_SOLD_TO',                 "STD.text for sold to
  lc_ship_to TYPE thead-tdname  VALUE 'ZOTC_0073_SHIP_TO',                 "STD.text for ship to
  lc_asn TYPE thead-tdname      VALUE 'ZOTC_0073_ASN',                     "STD.text for Mail subject
  lc_line TYPE thead-tdname     VALUE 'ZOTC_0073_LINE',                    "STD.text for line
  lc_mat TYPE thead-tdname      VALUE 'ZOTC_0073_MAT',                     "STD.text for material
  lc_des TYPE thead-tdname      VALUE 'ZOTC_0073_DES',                     "STD.text for Mat. Description
  lc_ord_qty TYPE thead-tdname  VALUE 'ZOTC_0073_ORD_QTY',                 "STD.text for Order Qty
  lc_shp_qty TYPE thead-tdname  VALUE 'ZOTC_0073_SHP_QTY',                 "STD.text for Ship Qty
  lc_shp_date TYPE thead-tdname VALUE 'ZOTC_0073_SHP_DATE',                "STD.text for Ship Date
  lc_trac TYPE thead-tdname     VALUE 'ZOTC_0073_TRACK',                   "STD.text for  tracking No
  lc_open_qty TYPE thead-tdname VALUE 'ZOTC_0073_OPEN_QTY',                "STD.text for Open Qty
  lc_shipped  TYPE thead-tdname VALUE 'ZOTC_0073_SHIPPED',                 "STD.text for  fully Shipped
  lc_kind TYPE thead-tdname     VALUE 'ZOTC_0073_KIND',                    "STD.text for  tracking No
* ---> Begin of Change for Defect #4207 by Hrudra
  lc_pshipped  TYPE thead-tdname VALUE 'ZOTC_0073_PRSL_SHIPPED', "STD.text for  partially Shipped
  lc_langu_fr    TYPE char1        VALUE 'F',                    "Language key F for French
  lc_langu_es    TYPE char1        VALUE 'S',                    "Language key F for Spanish
* <--- End of Change for Defect #4207 by Hrudra
* ---> Begin of Change for Defect #4207_2 by Hrudra
  lc_enh_no TYPE z_enhancement VALUE 'D2_OTC_FDD_0073', " Enhancement No.
  lc_vkorg TYPE z_criteria VALUE 'VKORG',               " Enh. Criteria

* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  lc_biorad_ship_notif_d3 TYPE tdobname VALUE 'ZOTC_0073_BIORAD_SHIP_NOTIF_EU', "STD.text for Ship.Notification
  lc_contact_us_d3 TYPE tdobname        VALUE 'ZOTC_0073_CONTACT_US_EU',        "STD.text for Contact Us
  lc_thanks_note_d3 TYPE tdobname       VALUE 'ZOTC_0073_THANKS_NOTE_EU',       "STD.text for thanks Notes
  lc_contact_person_d3 TYPE tdobname    VALUE 'ZOTC_0073_CONTACT_PERSON_EU',    "STD.text for contact person
  lc_contact_email_d3 TYPE tdobname     VALUE  'ZOTC_0073_CONTACT_EMAIL_EU',    "STD.text for contact Email
  lc_your_po_d3 TYPE tdobname  VALUE 'ZOTC_0073_YOUR_PO_EU',                    "STD.text for Your Po
  lc_order_d3 TYPE tdobname    VALUE 'ZOTC_0073_ORDER_EU',                      "STD.text for Order
  lc_sold_to_d3 TYPE tdobname  VALUE 'ZOTC_0073_SOLD_TO_EU',                    "STD.text for sold to
  lc_ship_to_d3 TYPE tdobname  VALUE 'ZOTC_0073_SHIP_TO_EU',                    "STD.text for ship to
  lc_line_d3 TYPE tdobname     VALUE 'ZOTC_0073_LINE_EU',                       "STD.text for line
  lc_mat_d3 TYPE tdobname      VALUE 'ZOTC_0073_MAT_EU',                        "STD.text for material
  lc_des_d3 TYPE tdobname      VALUE 'ZOTC_0073_DES_EU',                        "STD.text for Mat. Description
  lc_ord_qty_d3 TYPE tdobname  VALUE 'ZOTC_0073_ORD_QTY_EU',                    "STD.text for Order Qty
  lc_shp_qty_d3 TYPE tdobname  VALUE 'ZOTC_0073_SHP_QTY_EU',                    "STD.text for Ship Qty
  lc_shp_date_d3 TYPE tdobname VALUE 'ZOTC_0073_SHP_DATE_EU',                   "STD.text for Ship Date
  lc_trac_d3 TYPE tdobname     VALUE 'ZOTC_0073_TRACK_EU',                      "STD.text for  tracking No
  lc_open_qty_d3 TYPE tdobname VALUE 'ZOTC_0073_OPEN_QTY_EU',                   "STD.text for Open Qty
  lc_shipped_d3  TYPE tdobname VALUE 'ZOTC_0073_SHIPPED_EU',                    "STD.text for  fully Shipped
  lc_pshipped_d3  TYPE tdobname VALUE 'ZOTC_0073_PRSL_SHIPPED_EU'.              "STD.text for  partially Shipped
  DATA: lv_text_name TYPE char70. " Text_name of type CHAR70
* <--- End of Change for D3_OTC_FDD_0073 by kmishra

*Nast Language
*Language selection
*Get the reqiured details form the EMI tool
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_no
    TABLES
      tt_enh_status     = li_enh_status.
*We select only the active entries.
  DELETE li_enh_status WHERE active = space.
  IF li_enh_status IS NOT INITIAL.
    READ TABLE li_enh_status ASSIGNING <lfs_enh_status>
    WITH KEY criteria = lc_vkorg
             sel_low  = lv_vkorg .
    IF sy-subrc IS INITIAL.
*If language key is found in T002 table then passing it to fp_nast-spras
*else passing default language key'E' that is English to fp_nast-spras
      SELECT SINGLE
        spras "Language Key
        FROM t002 INTO lv_spras
        WHERE laiso = <lfs_enh_status>-sel_high.
      IF sy-subrc NE 0. " if record not found in T002 table
        lv_spras = fp_nast-spras. "assigning default language(Nast)
      ENDIF. " IF sy-subrc NE 0
    ELSE. " ELSE -> IF sy-subrc IS INITIAL
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*If EMI entries are not found then VKORG is for D3 changes (EU country) thus setting flag for D3.
      fp_lv_d3_lang_flag = abap_true.
*      lv_spras =  fp_nast-spras. "assigning default language(Nast)''' Commenting this line
* ---> End of Change for D3_OTC_FDD_0073 by kmishra
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_enh_status IS NOT INITIAL

*If D3 flag is checked then passing ship to customer language as form langauge.
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  IF fp_lv_d3_lang_flag = abap_true.
    IF fp_lv_shipto_lang IS NOT INITIAL.
      lv_spras = fp_lv_shipto_lang.
    ELSE. " ELSE -> IF fp_lv_shipto_lang IS NOT INITIAL
      lv_spras = fp_nast-spras.
    ENDIF. " IF fp_lv_shipto_lang IS NOT INITIAL
  ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* ---> End of Change for D3_OTC_FDD_0073 by kmishra

*Language is based on Sales org
  fp_std_text-nast_langu = fp_nast-spras = lv_spras.
* <--- End of Change for Defect #4207_2 by Hrudra
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  IF fp_lv_d3_lang_flag = abap_true.
    lv_text_name = lc_biorad_ship_notif_d3.
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag = abap_true
    lv_text_name = lc_biorad_ship_notif.
  ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* ---> End of Change for D3_OTC_FDD_0073 by kmishra
*Read Standard Text with 'Read_Text' FM
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id " TextId
      language                = fp_nast-spras
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*      name                    = lc_biorad_ship_notif " Name of the Text
      name                    = lv_text_name " Name of the Text
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines> .
      CONCATENATE  fp_std_text-ship_notif <lfs_lines>-tdline
      INTO fp_std_text-ship_notif.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
    IF fp_lv_d3_lang_flag NE abap_true.
* <--- End of Change D3_OTC_FDD_0073 by kmishra
* ---> Begin of Change for Defect #4207 by Hrudra
*If Nast Spras is French
      IF fp_std_text-nast_langu = lc_langu_fr. " 'F'.
        SPLIT fp_std_text-ship_notif AT '$' INTO fp_std_text-ship_notif_fr fp_std_text-ship_notif.
      ENDIF. " IF fp_std_text-nast_langu = lc_langu_fr
    ENDIF. " IF fp_lv_d3_lang_flag NE abap_true
* <--- End of Change for Defect #4207 by Hrudra
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  ENDIF. " IF sy-subrc = 0
  CLEAR: lv_text_name.
  IF fp_lv_d3_lang_flag = abap_true.
    lv_text_name = lc_contact_us_d3.
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag = abap_true
    lv_text_name = lc_contact_us.
  ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* * <--- End of Change for D3_OTC_FDD_0073 by kmishra
* Read contact us text
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id " TextId
      language                = fp_nast-spras
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*      name                    = lc_contact_us " Name of the Text
  name = lv_text_name
* <--- End of Change D3_OTC_FDD_0073 by kmishra
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      CONCATENATE  fp_std_text-contact_us <lfs_lines>-tdline
      INTO fp_std_text-contact_us.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  IF fp_lv_d3_lang_flag NE abap_true.
*     * <--- End of Change for D3_OTC_FDD_0073 by kmishra
* ---> Begin of Change for Defect #4207 by Hrudra
*If Nast Spras is French
    IF fp_std_text-nast_langu = lc_langu_fr. " 'F'.
      SPLIT fp_std_text-contact_us AT '$' INTO fp_std_text-contact_us_fr fp_std_text-contact_us.
      CONDENSE fp_std_text-contact_us_fr.
      CONDENSE fp_std_text-contact_us.
    ENDIF. " IF fp_std_text-nast_langu = lc_langu_fr
* <--- End of Change for Defect #4207 by Hrudra
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  ENDIF. " IF fp_lv_d3_lang_flag NE abap_true
  CLEAR: lv_text_name.
  IF fp_lv_d3_lang_flag = abap_true.
    lv_text_name = lc_thanks_note_d3.
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag = abap_true
    lv_text_name = lc_thanks_note.
  ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* * <--- End of Change for D3_OTC_FDD_0073 by kmishra
*  * Read Thanks notes
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id " TextId
      language                = fp_nast-spras
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*      name                    = lc_thanks_note " Name of the Text
       name = lv_text_name
* <--- End of Change D3_OTC_FDD_0073 by kmishra
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      CONCATENATE  fp_std_text-thanks_note <lfs_lines>-tdline
      INTO  fp_std_text-thanks_note
      SEPARATED BY space.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  IF fp_lv_d3_lang_flag NE abap_true.
* * <--- End of Change for D3_OTC_FDD_0073 by kmishra
* ---> Begin of Change for Defect #4207 by Hrudra
*If Nast Spras is French
    IF fp_std_text-nast_langu = lc_langu_fr. " 'F'.
      SPLIT fp_std_text-thanks_note AT '$' INTO fp_std_text-thanks_note_fr fp_std_text-thanks_note.
      CONDENSE fp_std_text-thanks_note_fr.
      CONDENSE fp_std_text-thanks_note.
    ENDIF. " IF fp_std_text-nast_langu = lc_langu_fr
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  ENDIF. " IF fp_lv_d3_lang_flag NE abap_true
  CLEAR: lv_text_name.
  IF fp_lv_d3_lang_flag = abap_true.
    lv_text_name = lc_shipped_d3.
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag = abap_true
    lv_text_name = lc_shipped.
  ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* ---> End of Change for D3_OTC_FDD_0073 by kmishra
*Shipped
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id " TextId
      language                = fp_nast-spras
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*        name                    = lc_shipped " Name of the Text
       name                    = lv_text_name
* ---> End of Change for D3_OTC_FDD_0073 by kmishra
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      CONCATENATE  fp_std_text-shipped <lfs_lines>-tdline
      INTO  fp_std_text-shipped
      SEPARATED BY space.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0
*If Nast Spras is French
* * ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  IF fp_lv_d3_lang_flag NE abap_true.
* ---> End of Change for D3_OTC_FDD_0073 by kmishra
    IF fp_std_text-nast_langu = lc_langu_fr. " 'F'.
      SPLIT fp_std_text-shipped AT '$' INTO fp_std_text-shipped_fr fp_std_text-shipped.
      CONDENSE fp_std_text-shipped_fr.
      CONDENSE fp_std_text-shipped.
    ENDIF. " IF fp_std_text-nast_langu = lc_langu_fr
* * <--- End of Change for Defect #4207 by Hrudra
** ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  ENDIF. " IF fp_lv_d3_lang_flag NE abap_true
  CLEAR: lv_text_name.
  IF fp_lv_d3_lang_flag = abap_true.
    lv_text_name = lc_pshipped_d3.
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag = abap_true
    lv_text_name = lc_pshipped.
  ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* ---> End of Change for D3_OTC_FDD_0073 by kmishra
*Partially shipped
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id " TextId
      language                = fp_nast-spras
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*        name                    = lc_pshipped " Name of the Text
       name                    = lv_text_name
* ---> End of Change for D3_OTC_FDD_0073 by kmishra
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      CONCATENATE  fp_std_text-pshipped <lfs_lines>-tdline
      INTO  fp_std_text-pshipped
      SEPARATED BY space.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0

* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  IF fp_lv_d3_lang_flag NE abap_true.
* ---> End of Change for D3_OTC_FDD_0073 by kmishra
* ---> Begin of Change for Defect #4207 by Hrudra
*If Nast Spras is French
    IF fp_std_text-nast_langu = lc_langu_fr. " 'F'.
      SPLIT fp_std_text-pshipped AT '$' INTO fp_std_text-pshipped_fr fp_std_text-pshipped.
      CONDENSE fp_std_text-pshipped_fr.
      CONDENSE fp_std_text-pshipped.
    ENDIF. " IF fp_std_text-nast_langu = lc_langu_fr
* <--- End of Change for Defect #4207 by Hrudra
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  ENDIF. " IF fp_lv_d3_lang_flag NE abap_true
  CLEAR: lv_text_name.
  IF fp_lv_d3_lang_flag = abap_true.
    lv_text_name = lc_contact_person_d3.
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag = abap_true
    lv_text_name = lc_contact_person.
  ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* * <--- End of Change for D3_OTC_FDD_0073 by kmishra

* Read contact person
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id " TextId
      language                = fp_nast-spras
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*      name                    = lc_contact_person " Name of the Text
       name                    = lv_text_name
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      CONCATENATE  fp_std_text-con_person <lfs_lines>-tdline
      INTO fp_std_text-con_person.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0
*  *  Begin of change for D3_OTC_FDD_0073 by kmishra
  CLEAR: lv_text_name.
  IF fp_lv_d3_lang_flag = abap_true.
    lv_text_name = lc_contact_email_d3.
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag = abap_true
    lv_text_name = lc_contact_email.
  ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* * <--- End of Change for D3_OTC_FDD_0073 by kmishra

** Read contact email
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id " TextId
      language                = fp_nast-spras
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*      name                    = lc_contact_email " Name of the Text
  name                    = lv_text_name
* <--- End of Change D3_OTC_FDD_0073 by kmishra
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      CONCATENATE  fp_std_text-con_email <lfs_lines>-tdline
      INTO fp_std_text-con_email.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  CLEAR: lv_text_name.
  IF fp_lv_d3_lang_flag = abap_true.
    lv_text_name = lc_your_po_d3.
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag = abap_true
    lv_text_name = lc_your_po.
  ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* * <--- End of Change for D3_OTC_FDD_0073 by kmishra

* Read your po
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id " TextId
      language                = fp_nast-spras
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*      name                    = lc_your_po " Name of the Text
  name                    = lv_text_name
* <--- End of Change D3_OTC_FDD_0073 by kmishra
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      CONCATENATE  fp_std_text-your_po <lfs_lines>-tdline
      INTO fp_std_text-your_po.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0
*  Begin of change  for D3_OTC_FDD_0073 by kmishra
  CLEAR: lv_text_name.
  IF fp_lv_d3_lang_flag = abap_true.
    lv_text_name = lc_order_d3.
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag = abap_true
    lv_text_name = lc_order.
  ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* * <--- End of Change for D3_OTC_FDD_0073 by kmishra


* Read Order
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id " TextId
      language                = fp_nast-spras
*      * ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*      name                    = lc_order " Name of the Text
  name                    = lv_text_name
* <--- End of Change D3_OTC_FDD_0073 by kmishra
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      CONCATENATE  fp_std_text-sorder  <lfs_lines>-tdline
      INTO fp_std_text-sorder.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  CLEAR: lv_text_name.
  IF fp_lv_d3_lang_flag = abap_true.
    lv_text_name = lc_sold_to_d3.
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag = abap_true
    lv_text_name = lc_sold_to.
  ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* * <--- End of Change for D3_OTC_FDD_0073 by kmishra
* Read sold to
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id " TextId
      language                = fp_nast-spras
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*      name                    = lc_sold_to " Name of the Text
  name                    = lv_text_name
* <--- End of Change D3_OTC_FDD_0073 by kmishra
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      CONCATENATE  fp_std_text-sold_to  <lfs_lines>-tdline
      INTO fp_std_text-sold_to.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0
* *  Begin of change for D3_OTC_FDD_0073 by kmishra
  CLEAR: lv_text_name.
  IF fp_lv_d3_lang_flag = abap_true.
    lv_text_name = lc_ship_to_d3.
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag = abap_true
    lv_text_name = lc_ship_to.
  ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* * <--- End of Change for D3_OTC_FDD_0073 by kmishra

**Read Shipp to
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id " TextId
      language                = fp_nast-spras
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*      name                    = lc_ship_to " Name of the Text
  name                    = lv_text_name
* <--- End of Change D3_OTC_FDD_0073 by kmishra
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      CONCATENATE  fp_std_text-ship_to  <lfs_lines>-tdline
      INTO fp_std_text-ship_to.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0
* Read Text ASN confirmation Order:
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id  " TextId
      language                = fp_nast-spras
      name                    = lc_asn " Name of the Text
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      CONCATENATE fp_std_text-mail_sub <lfs_lines>-tdline
      INTO fp_std_text-mail_sub.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0
* Begin of change for D3_OTC_FDD_0073 by kmishra
  CLEAR: lv_text_name.
  IF fp_lv_d3_lang_flag = abap_true.
    lv_text_name = lc_line_d3.
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag = abap_true
    lv_text_name = lc_line.
  ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* * <--- End of Change for D3_OTC_FDD_0073 by kmishra

* Read Text Line number:
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id " TextId
      language                = fp_nast-spras
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*      name                    = lc_line " Name of the Text
  name                    = lv_text_name
* <--- End of Change D3_OTC_FDD_0073 by kmishra
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      CONCATENATE  fp_std_text-line <lfs_lines>-tdline
      INTO fp_std_text-line.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0
* ---> Begin of Change for Defect #4207 by Hrudra
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  IF fp_lv_d3_lang_flag NE abap_true.
* ---> End of Change for D3_OTC_FDD_0073 by kmishra
*If Nast Spras is French
    IF fp_std_text-nast_langu = lc_langu_fr. " 'F'.
      SPLIT fp_std_text-line AT '$' INTO fp_std_text-line_fr fp_std_text-line.
      CONDENSE fp_std_text-line_fr.
      CONDENSE fp_std_text-line.
    ENDIF. " IF fp_std_text-nast_langu = lc_langu_fr
* <--- End of Change for Defect #4207 by Hrudra
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  ENDIF. " IF fp_lv_d3_lang_flag NE abap_true
  CLEAR: lv_text_name.
  IF fp_lv_d3_lang_flag = abap_true.
    lv_text_name = lc_mat_d3.
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag = abap_true
    lv_text_name = lc_mat.
  ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* * <--- End of Change for D3_OTC_FDD_0073 by kmishra
* Read Text Material:
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id " TextId
      language                = fp_nast-spras
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*      name                    = lc_mat " Name of the Text
       name                    = lv_text_name
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      CONCATENATE  fp_std_text-material <lfs_lines>-tdline
      INTO fp_std_text-material.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  CLEAR: lv_text_name.
  IF fp_lv_d3_lang_flag = abap_true.
    lv_text_name = lc_des_d3.
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag = abap_true
    lv_text_name = lc_des.
  ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* * <--- End of Change for D3_OTC_FDD_0073 by kmishra
* Read Text Description:
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id " TextId
      language                = fp_nast-spras
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*      name                    = lc_des " Name of the Text
  name                    = lv_text_name
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      CONCATENATE  fp_std_text-descripn <lfs_lines>-tdline
      INTO fp_std_text-descripn.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  CLEAR: lv_text_name.
  IF fp_lv_d3_lang_flag = abap_true.
    lv_text_name = lc_ord_qty_d3.
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag = abap_true
    lv_text_name = lc_ord_qty.
  ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* * <--- End of Change for D3_OTC_FDD_0073 by kmishra
* Read Text Order Qty(EA):
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id " TextId
      language                = fp_nast-spras
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*      name                    = lc_ord_qty " Name of the Text
       name                    = lv_text_name
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      CONCATENATE  fp_std_text-ord_qty  <lfs_lines>-tdline
      INTO fp_std_text-ord_qty.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  IF fp_lv_d3_lang_flag NE abap_true.
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
* ---> Begin of Change for Defect #4207 by Hrudra
*If Nast Spras is French
    IF fp_std_text-nast_langu = lc_langu_fr. " 'F'.
      SPLIT fp_std_text-ord_qty AT '$' INTO fp_std_text-ord_qty_fr fp_std_text-ord_qty.
      CONDENSE fp_std_text-ord_qty_fr.
      CONDENSE fp_std_text-ord_qty.
    ENDIF. " IF fp_std_text-nast_langu = lc_langu_fr
* <--- End of Change for Defect #4207 by Hrudra
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  ENDIF. " IF fp_lv_d3_lang_flag NE abap_true
  CLEAR: lv_text_name.
  IF fp_lv_d3_lang_flag = abap_true.
    lv_text_name = lc_shp_qty_d3.
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag = abap_true
    lv_text_name = lc_shp_qty.
  ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* * <--- End of Change for D3_OTC_FDD_0073 by kmishra
* Read Text Shipped Qty(EA):
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id " TextId
      language                = fp_nast-spras
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*      name                    = lc_shp_qty " Name of the Text
  name                    = lv_text_name
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      CONCATENATE  fp_std_text-shp_qty <lfs_lines>-tdline
      INTO fp_std_text-shp_qty.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  IF fp_lv_d3_lang_flag NE abap_true.
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
* ---> Begin of Change for Defect #4207 by Hrudra
*If Nast Spras is French
    IF fp_std_text-nast_langu = lc_langu_fr. " 'F'.
      SPLIT fp_std_text-shp_qty AT '$' INTO fp_std_text-shp_qty_fr fp_std_text-shp_qty.
      CONDENSE fp_std_text-shp_qty_fr.
*    CONDENSE fp_std_text-shp_qty.
    ENDIF. " IF fp_std_text-nast_langu = lc_langu_fr
* <--- End of Change for Defect #4207 by Hrudra
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  ENDIF. " IF fp_lv_d3_lang_flag NE abap_true
  CLEAR: lv_text_name.
  IF fp_lv_d3_lang_flag = abap_true.
    lv_text_name = lc_shp_date_d3.
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag = abap_true
    lv_text_name = lc_shp_date.
  ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* * <--- End of Change for D3_OTC_FDD_0073 by kmishra
* Read Text Shipped Date:
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id " TextId
      language                = fp_nast-spras
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*      name                    = lc_shp_date " Name of the Text
       name                    = lv_text_name
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      CONCATENATE fp_std_text-shp_date  <lfs_lines>-tdline
      INTO fp_std_text-shp_date.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0

* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  IF fp_lv_d3_lang_flag NE abap_true.
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
* ---> Begin of Change for Defect #4207 by Hrudra
*If Nast Spras is French
    IF fp_std_text-nast_langu = lc_langu_fr. " 'F'.
      SPLIT fp_std_text-shp_date AT '$' INTO fp_std_text-shp_date_fr fp_std_text-shp_date.
      CONDENSE fp_std_text-shp_date_fr.
      CONDENSE fp_std_text-shp_date.
    ENDIF. " IF fp_std_text-nast_langu = lc_langu_fr
* <--- End of Change for Defect #4207 by Hrudra
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  ENDIF. " IF fp_lv_d3_lang_flag NE abap_true
  CLEAR: lv_text_name.
  IF fp_lv_d3_lang_flag = abap_true.
    lv_text_name = lc_trac_d3.
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag = abap_true
    lv_text_name = lc_trac.
  ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* * <--- End of Change for D3_OTC_FDD_0073 by kmishra
* Read Text Tracking No:
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id " TextId
      language                = fp_nast-spras
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*      name                    = lc_trac " Name of the Text
       name                    = lv_text_name
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      CONCATENATE  fp_std_text-trackng  <lfs_lines>-tdline
      INTO fp_std_text-trackng.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  IF fp_lv_d3_lang_flag NE abap_true.
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
* ---> Begin of Change for Defect #4207 by Hrudra
*If Nast Spras is French
    IF fp_std_text-nast_langu = lc_langu_fr. " 'F'.
      SPLIT fp_std_text-trackng AT '$' INTO fp_std_text-trackng_fr fp_std_text-trackng.
      CONDENSE fp_std_text-trackng_fr.
      CONDENSE fp_std_text-trackng.
    ENDIF. " IF fp_std_text-nast_langu = lc_langu_fr
* <--- End of Change for Defect #4207 by Hrudra
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  ENDIF. " IF fp_lv_d3_lang_flag NE abap_true
  CLEAR: lv_text_name.
  IF fp_lv_d3_lang_flag = abap_true.
    lv_text_name = lc_open_qty_d3.
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag = abap_true
    lv_text_name = lc_open_qty.
  ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* * <--- End of Change for D3_OTC_FDD_0073 by kmishra
* Read Text Open Qty:
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id " TextId
      language                = fp_nast-spras
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*      name                    = lc_open_qty " Name of the Text
       name                    = lv_text_name
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      CONCATENATE  fp_std_text-open_qty <lfs_lines>-tdline
      INTO fp_std_text-open_qty.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  IF fp_lv_d3_lang_flag NE abap_true.
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
* ---> Begin of Change for Defect #4207 by Hrudra
*If Nast Spras is French
    IF fp_std_text-nast_langu = lc_langu_fr. " 'F'.
      SPLIT fp_std_text-open_qty AT '$' INTO fp_std_text-open_qty_fr fp_std_text-open_qty.
      CONDENSE fp_std_text-open_qty_fr.
      CONDENSE fp_std_text-open_qty.
    ENDIF. " IF fp_std_text-nast_langu = lc_langu_fr
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  ENDIF. " IF fp_lv_d3_lang_flag NE abap_true
* ---> End of Change for D3_OTC_FDD_0073 by kmishra

* Kind Text
  REFRESH li_lines[].
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id   " TextId
      language                = fp_nast-spras
      name                    = lc_kind " Name of the Text
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      CONCATENATE  fp_std_text-kind_txt  <lfs_lines>-tdline
      INTO fp_std_text-kind_txt.
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0

* <--- End of Change for Defect #4207 by Hrudra
ENDFORM. " F_GET_READ_STD_TEXT
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_HTML_BODY
*&---------------------------------------------------------------------*
*       Build Email Header & Body in HTML Format
*----------------------------------------------------------------------*
*      -->fp_sold_to_addr  Sold to Address Information
*      -->fp_ship_to_addr  Ship to zotc_order_address_info
*      -->fp_contact_addr  Contact zotc_order_address_info
*      -->fp_line_item     ASN Order Item data
*      -->fp_ship_no       Ship_no
*      -->fp_sold_no       Sold_no of type CHAR10
*      -->fp_vbeln         Sales Order No
*      -->fp_bstkd         Customer Po
*      -->fp_std_text      Standard Text Info
*      <--fp_li_objtxt     solisti1
*      <--fp_doc_chng      sodocchgi1.
*----------------------------------------------------------------------*
FORM f_build_html_body  USING
  value(fp_sold_to_addr) TYPE zotc_order_address_info " Order General Address Information
  value(fp_ship_to_addr) TYPE zotc_order_address_info " Order General Address Information
  value(fp_contact_addr) TYPE zotc_order_address_info " Order General Address Information
  value(fp_line_item)    TYPE zotc_t_order_asn_item   " ASN Order Item data
  value(fp_ship_no)      TYPE char10                  " Ship_no of type CHAR10
  value(fp_sold_no)      TYPE char10                  " Sold_no of type CHAR10
  value(fp_vbeln)        TYPE char10                  "Order No
  value(fp_bstkd)        TYPE char35                  " Bstkd of type CHAR35
  value(fp_total_open_qty) TYPE bbmng                 " Quantity as Per Vendor Confirmation
  value(fp_std_text)     TYPE zotc_std_text_info      " Stadard Text Information
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
        fp_lv_shipto_lang TYPE langu    " Language Key
        fp_lv_shipto_country TYPE land1 " Country Key
        fp_lv_d3_lang_flag TYPE char1   " Lv_d3_lang_flag of type CHAR1
* * <--- End of Change for D3_OTC_FDD_0073 by kmishra
                     CHANGING
        fp_li_objtxt     TYPE zotc_t_solisti1
        fp_doc_chng      TYPE sodocchgi1. " Data of an object which can be changed

*Field symbols
  FIELD-SYMBOLS: <lfs_item> TYPE zotc_order_asn_item. " ASN Order Item data

* Begin of Defect 6146
  TYPES : BEGIN OF lty_address,
             soldto   TYPE char100, " Soldto of type CHAR100
             shipto   TYPE char100, " Shiptp of type CHAR100
          END   OF lty_address.

  FIELD-SYMBOLS : <lfs_address>  TYPE lty_address.

  DATA : lwa_address  TYPE lty_address,
         lv_column1   TYPE flag, " General Flag
         lv_column2   TYPE flag, " General Flag
         li_address   TYPE STANDARD TABLE OF lty_address.
* End   of Defect 6146

*Local Declarations
  DATA :li_objtxt    TYPE TABLE OF solisti1,   "To hold data in single line format
        lwa_objtxt   TYPE solisti1,            "To hold data for API Recipient List
        lv_sold_to_building_value TYPE string, "Sold To Building/Room/Floor
        lv_biorad_ship_notif_val  TYPE string, "Bio-Rad Shipment Notification for Order
        lv_ship_to_building_value TYPE string, "Ship To Building/Room/Floor OR Street 3
        lv_ship_to_street_value   TYPE string, "Ship To Customer Street 2
        lv_sold_to_street_value   TYPE string, "Sold To Street 2
        lv_sold_to_house_value    TYPE string, "Sold To House #/Street and Supplement
        lv_ship_to_house_value    TYPE string, "Ship To House #/Street and Supplement
        lv_ship_to_city_value     TYPE string, "Ship To House #/Street and Supplement
        lv_sold_to_city_value     TYPE string, "Sold To House #/Street and Supplement
        lv_asn_value TYPE string,              "Mail Subject
        lv_length    TYPE i,                   "Length of type Integers
        lv_op_qty    TYPE char13,              "Open_qty of type CHAR13
        lv_menge     TYPE char13,              "Menge of type CHAR13
        lv_lfimg     TYPE char13,              "Lfimg of type CHAR13
* ---> Begin of change for D3_OTC_FDD_0073 by kmishra
*        lv_erdat     TYPE char10 ##needed,     "Erdat of type CHAR10
         lv_erdat     TYPE char15, " Erdat of type CHAR15
         lv_uom       TYPE char10, " Uom of type CHAR10
         lv_uom_text  TYPE char10, " Uom_text of type CHAR10
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
        lv_len2      TYPE i,     "Len2 of type Integers
        lv_len3      TYPE i,     "Len3 of type Integers
        lv_flag      TYPE char1, " Flag of type CHAR1
* ---> Begin of Change for Defect #4207_2 by Hrudra
        lv_url        TYPE string, " URL Based on Shipping Condition
* <--- End of Change for Defect #4207_2 by Hrudra
*Class for cobining HMTL & Image
    lref_mr_api      TYPE REF TO if_mr_api, "API for MIME Repository - Basic Functions
    lwa_io           TYPE skwf_io ##needed, " KW Framework: Object Key
    lv_is_folder     TYPE boole_d ##needed, " Data element for domain BOOLE: TRUE(='X')FALSE (=' ')
    lwa_current      TYPE xstring,          "xstring data for logo in MIME
    lwa_b64data      TYPE string,           "string data for logo in b64data
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
    lv_ex_erdat TYPE sy-datum. " Current Date of Application Server
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
  CONSTANTS:
    lc_url TYPE string  VALUE '/SAP/PUBLIC/BIO_RAD_LOGO.JPG', "Url for Bio-Rad Logo
    lc_255 TYPE int3    VALUE '255', "255 of type Integers
* ---> Begin of Change for Defect #4207 by Hrudra
    lc_langu_fr    TYPE char1 VALUE 'F', "Language key F for French
    lc_langu_es    TYPE char1 VALUE 'S', " Langu_es of type CHAR1
* <--- End of Change for Defect #4207 by Hrudra                                                      "Language key F for Spanish
* ---> Begin of Change for Defect #4207_2 by Hrudra
    lc_url_z1  TYPE string  VALUE
    'http://www.fedex.com/Tracking?action=track&language=english&cntry_code=us&tracknumbers=', "URL Shipping Cond. Z1 FEDEX
    lc_url_z2  TYPE string  VALUE
    'http://wwwapps.ups.com/etracking/tracking.cgi?tracknums_displayed=5&TypeOfInquiryNumber=T&HTMLVersion=4.0&InquiryNumber1=', "URL Shipping Cond. Z2 UPS
    lc_url_z3  TYPE string  VALUE
    'http://track.dhl-usa.com/TrackByNbr.asp?ShipmentNumber=' , " URL Shipping Cond. Z3 DHL
    lc_url_z4  TYPE string  VALUE 'https://tools.usps.com/go/TrackConfirmAction.action?tRef=fullpage&tLc=1&text28777=&tLabels=', " URL Shipping Cond. Z4 USPS
    lc_url_z9  TYPE string  VALUE
    'https://www.purolator.com/purolator/ship-track/tracking-details.page?pin='##no_text, " URL Shipping Cond. Z9 Purolator
    lc_url_za  TYPE string  VALUE 'https://www.quikx.com/QuikXGrpWeb/en/CGI101R_QX.PGM?LANGUAGE=E&NUMTYPE=PRO%20NUMBER&NUM=' , " URL Shipping Cond. ZA Quick X
    lc_url_zb  TYPE string  VALUE 'http://www.airtradesfreight.com/', " URL Shipping Cond. ZB Air Trades
    lc_url_zc  TYPE string  VALUE 'http://www.dicomexpress.com/', "URL Shipping Cond. ZC Dicom
*Shipping Conds
    lc_z1      TYPE vsbed   VALUE  'Z1', "Shipping Cond.Z1 FEDEX
    lc_z2      TYPE vsbed   VALUE  'Z2', "Shipping CondZ2 UPS
    lc_z3      TYPE vsbed   VALUE  'Z3', "Shipping CondZ3 DHL
    lc_z4      TYPE vsbed   VALUE  'Z4', "Shipping CondZ4 USPS
    lc_z9      TYPE vsbed   VALUE  'Z9', "Shipping CondZ9 Purolator
    lc_za      TYPE vsbed   VALUE  'ZA', "Shipping CondZA Quick X
    lc_zb      TYPE vsbed   VALUE  'ZB', "Shipping Cond. ZB Air Trades
    lc_zc      TYPE vsbed   VALUE  'ZC', "Shipping Cond. ZC Dicom
* <--- End of Change for Defect #4207_2 by Hrudra


* ---> Begin of Change for D2_OTC_FDD_0073 Defect # 4207 by APODDAR

    lc_dot     TYPE z_criteria VALUE '.', " Enh. Criteria
    lc_slash   TYPE z_criteria VALUE '/',                  " Enh. Criteria
    lc_hyphen  TYPE z_criteria VALUE '-',                  " Enh. Criteria
    lc_enh_no  TYPE z_enhancement VALUE 'D2_OTC_FDD_0073', " Enhancement No.
    lc_country TYPE z_criteria    VALUE 'COUNTRY',         " Enh. Criteria

* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
   lc_format TYPE char15 VALUE 'DD-MMM-YYYY' , " Format of type CHAR15
   lc_uom TYPE char2 VALUE 'EA'.               " Uom of type CHAR2
*   * <--- End of Change for D3_OTC_FDD_0073 by kmishra

  DATA :          li_constant    TYPE STANDARD TABLE OF zdev_enh_status. " Enhancement Status
  FIELD-SYMBOLS : <lfs_constant> TYPE zdev_enh_status. " Enhancement Status

* <--- End    of Change for D2_OTC_FDD_0073 Defect # 4207 by APODDAR


*Set the Subject line for Mail
  CONCATENATE fp_std_text-mail_sub fp_vbeln INTO lv_asn_value
  SEPARATED BY space.
  fp_doc_chng-obj_name =  lv_asn_value.
  fp_doc_chng-obj_descr = lv_asn_value.
*Set the Body background colour
  lwa_objtxt-line = '<body bgcolor="#ffffcc">'.
*Append
  APPEND lwa_objtxt TO li_objtxt.
*Get Xstring data from MIME repository for Bio-rad logo
  IF lref_mr_api IS INITIAL.
    lref_mr_api = cl_mime_repository_api=>if_mr_api~get_api( ).
  ENDIF. " IF lref_mr_api IS INITIAL
*Get Xstring for logo
  CALL METHOD lref_mr_api->get
    EXPORTING
      i_url              = lc_url "'/SAP/PUBLIC/BIO_RAD_LOGO.JPG'.
    IMPORTING
      e_is_folder        = lv_is_folder
      e_content          = lwa_current
      e_loio             = lwa_io
    EXCEPTIONS
      parameter_missing  = 1
      error_occured      = 2
      not_found          = 3
      permission_failure = 4
      OTHERS             = 5.
*Convert Xstring to string data for Bio-rad logo
* convert temporary xstring to base64 encoded string
  lwa_b64data = cl_http_utility=>encode_x_base64( lwa_current ).

  lwa_objtxt-line = '<TABLE width="100%">'.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR  lwa_objtxt.
* ---> Begin of Change for Defect #4207 by Hrudra
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  IF fp_lv_d3_lang_flag NE abap_true.
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
*Bio-Rad Laboratories Shipment Notification for Order #:
    IF fp_std_text-nast_langu EQ lc_langu_fr.
*For French Header
      CONCATENATE fp_std_text-ship_notif_fr fp_vbeln INTO lv_biorad_ship_notif_val
      SEPARATED BY space.
      CONCATENATE '<tr><td align="CENTER" ><font face="Arial" size="4" color="black">'
      lv_biorad_ship_notif_val '</font> </td>'
      INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
*For Eng Header
      CLEAR lv_biorad_ship_notif_val.
      CONCATENATE fp_std_text-ship_notif fp_vbeln INTO lv_biorad_ship_notif_val
      SEPARATED BY space.
      CONCATENATE '<tr><td align="CENTER" ><font face="Arial" size="4" color="black">'
      lv_biorad_ship_notif_val '</font> </td>'
      INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
    ELSE. " ELSE -> IF fp_std_text-nast_langu EQ lc_langu_fr
*For Eng/Spanish
      CLEAR lv_biorad_ship_notif_val.
      CONCATENATE fp_std_text-ship_notif fp_vbeln INTO lv_biorad_ship_notif_val
      SEPARATED BY space.
      CONCATENATE '<tr><td align="CENTER" ><font face="Arial" size="4" color="black">'
      lv_biorad_ship_notif_val '</font> </td>'
      INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
    ENDIF. " IF fp_std_text-nast_langu EQ lc_langu_fr
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag NE abap_true
    CLEAR lv_biorad_ship_notif_val.
    CONCATENATE fp_std_text-ship_notif fp_vbeln INTO lv_biorad_ship_notif_val
    SEPARATED BY space.
    CONCATENATE '<tr><td align="CENTER" ><font face="Arial" size="4" color="black">'
    lv_biorad_ship_notif_val '</font> </td>'
    INTO lwa_objtxt-line.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
  ENDIF. " IF fp_lv_d3_lang_flag NE abap_true
* <--- End of Change for D3_OTC_FDD_0073 by kmishra.
* <--- End of Change for Defect #4207 by Hrudra
  lwa_objtxt-line = '<td align="RIGHT"><img src= "data:image/jpeg;base64,'.
  APPEND lwa_objtxt TO li_objtxt.
*Clear
  CLEAR lwa_objtxt.
  lv_length = strlen( lwa_b64data ).
  lv_len2 = lv_length / lc_255.
  CLEAR lwa_objtxt.
  lwa_objtxt-line = lwa_b64data.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR  lwa_objtxt.

  DO lv_len2 TIMES.
    lv_len3 = lc_255 * sy-index.
    IF lv_len3 <= lv_length.
      lwa_objtxt-line = lwa_b64data+lv_len3.
      IF lwa_objtxt IS NOT INITIAL.
        APPEND lwa_objtxt TO li_objtxt.
        CLEAR  lwa_objtxt.
      ELSE. " ELSE -> IF lwa_objtxt IS NOT INITIAL
        EXIT.
      ENDIF. " IF lwa_objtxt IS NOT INITIAL
    ELSE. " ELSE -> IF lv_len3 <= lv_length
      EXIT.
    ENDIF ##bool_ok . " IF lv_len3 <= lv_length
  ENDDO.
  lwa_objtxt-line = '"</td> </tr>'.
*Append
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR lwa_objtxt.
*create space between two Rows
  CONCATENATE '<tr><tr><td >'
   '</td></tr></tr>'
  INTO lwa_objtxt-line.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR  lwa_objtxt.

*End table for Html
  lwa_objtxt-line = '</TABLE>'.
*Clear
  CLEAR lwa_objtxt.

*New table for Html
  lwa_objtxt-line = '<TABLE width="100%">'.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR  lwa_objtxt.
* ---> Begin of Change for Defect #4207 by Hrudra
*Contact us via the web at:  www.bio-rad.com/contact
*For French Translation
  IF fp_std_text-nast_langu EQ lc_langu_fr
    AND fp_lv_d3_lang_flag IS INITIAL.          "++D3_OTC_FDD_0073 DMOIRAN
    CONCATENATE '<tr><td align="left"><font face="Arial" size="2" color="black"><b>'
             fp_std_text-contact_us_fr
      '<BR>' fp_std_text-contact_us
      '</b>' ' </font> </td>'
      INTO lwa_objtxt-line.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
*For Eng or Spanish Translation
  ELSE. " ELSE -> IF fp_std_text-nast_langu EQ lc_langu_fr
    CONCATENATE '<tr><td align="left"><font face="Arial" size="2" color="black"><b>'
    fp_std_text-contact_us '</b>' ' </font> </td>'
    INTO lwa_objtxt-line.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
  ENDIF. " IF fp_std_text-nast_langu EQ lc_langu_fr

*Thanks Note
  IF NOT fp_total_open_qty IS INITIAL.
    lv_flag = abap_true.
  ENDIF. " IF NOT fp_total_open_qty IS INITIAL
  IF  lv_flag = abap_true. "if partially shipped
**For French Translation
    IF fp_std_text-nast_langu EQ lc_langu_fr
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
      AND fp_lv_d3_lang_flag NE abap_true.
* ---> End of Change for D3_OTC_FDD_0073 by kmishra
      CONCATENATE fp_std_text-thanks_note_fr fp_std_text-pshipped_fr
      INTO fp_std_text-thanks_note_fr SEPARATED BY space.

      CONCATENATE fp_std_text-thanks_note fp_std_text-pshipped
      INTO fp_std_text-thanks_note SEPARATED BY space.
    ELSE. " ELSE -> IF fp_std_text-nast_langu EQ lc_langu_fr
      CONCATENATE fp_std_text-thanks_note fp_std_text-pshipped
      INTO fp_std_text-thanks_note SEPARATED BY space.
    ENDIF. " IF fp_std_text-nast_langu EQ lc_langu_fr
  ELSE. " ELSE -> IF lv_flag = abap_true
    IF NOT fp_std_text-thanks_note_fr IS INITIAL
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
      AND fp_lv_d3_lang_flag NE abap_true.
* ---> End of Change for D3_OTC_FDD_0073 by kmishra
      CONCATENATE fp_std_text-thanks_note_fr fp_std_text-shipped_fr
      INTO fp_std_text-thanks_note_fr SEPARATED BY space.

      CONCATENATE fp_std_text-thanks_note fp_std_text-shipped
      INTO fp_std_text-thanks_note SEPARATED BY space.
    ELSE. " ELSE -> IF NOT fp_std_text-thanks_note_fr IS INITIAL
      CONCATENATE fp_std_text-thanks_note fp_std_text-shipped
    INTO fp_std_text-thanks_note SEPARATED BY space.
    ENDIF. " IF NOT fp_std_text-thanks_note_fr IS INITIAL
  ENDIF. " IF lv_flag = abap_true
  IF fp_std_text-nast_langu EQ lc_langu_fr
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  AND fp_lv_d3_lang_flag NE abap_true.
* <--- End of Change for D3_OTC_FDD_0073 by kmishra

    CONCATENATE '<td align="Justified"><font face="Arial" size="2" color="black"><b>'
    fp_std_text-thanks_note_fr
    '<BR>' fp_std_text-thanks_note
    '</b>'
    '</font></td></tr>'
    INTO lwa_objtxt-line.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.

  ELSE. " ELSE -> IF fp_std_text-nast_langu EQ lc_langu_fr
    CONCATENATE '<td align="Justified"><font face="Arial" size="2" color="black"><b>'
   fp_std_text-thanks_note '</b>' '<BR></font></td></tr>'
   INTO lwa_objtxt-line.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
  ENDIF. " IF fp_std_text-nast_langu EQ lc_langu_fr
* <--- End of Change for Defect #4207 by Hrudra
*create space between two Rows
  CONCATENATE '<tr><tr><td ><hr width=900%>'
   ' </td></tr></tr>'
  INTO lwa_objtxt-line.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR  lwa_objtxt.

*To:  Contact Person
  CONCATENATE '<tr> <td align="left"><font face="Arial" size="2"><font color="black"><b>'
  fp_std_text-con_person ' ' '</b>' fp_contact_addr-name1 '</font></td>'
  INTO lwa_objtxt-line.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR  lwa_objtxt.
*Email:  Contact Person Email address
  CONCATENATE '<td align="Justified"><font face="Arial" size="2" color="black"><b>'
  fp_std_text-con_email ' ' '</b>' fp_contact_addr-smtp_addr '<BR></font></td></tr>'
  INTO lwa_objtxt-line.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR  lwa_objtxt.

*Space between to Rows
  CONCATENATE '<tr><tr><td >'
   ' </td></tr></tr>'
  INTO lwa_objtxt-line.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR  lwa_objtxt.
*Your Po
  SHIFT fp_bstkd  RIGHT DELETING TRAILING ''.
  CONCATENATE '<tr> <td align="left"><font face="Arial" size="2"><font color="black"><b>'
  fp_std_text-your_po '</b>' fp_bstkd'</font></td>'
  INTO lwa_objtxt-line.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR  lwa_objtxt.
*Sales Order
  SHIFT fp_vbeln  RIGHT DELETING TRAILING ''.
  CONCATENATE '<td align="Justified"><font face="Arial" size="2"><font color="black">'
  '<b>' fp_std_text-sorder '</b>' fp_vbeln' </font></td></tr>'
  INTO lwa_objtxt-line.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR  lwa_objtxt.
**Space between to Rows
  CONCATENATE '<tr><tr><td ><hr width=900%>'
    '</td></tr></tr>'
   INTO lwa_objtxt-line.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR  lwa_objtxt.
*Space between Row
  CONCATENATE '<tr><tr><td >'
 ' </td></tr></tr>'
INTO lwa_objtxt-line.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR  lwa_objtxt.
*Sold To: #
  SHIFT fp_sold_no  RIGHT DELETING TRAILING ''.
  CONCATENATE '<tr> <td align="left"><font face="Arial" size="2"> <font color="black">'
  '<b>' fp_std_text-sold_to '</b>' fp_sold_no '</font></td>' INTO lwa_objtxt-line.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR  lwa_objtxt.
*Ship To: #
  SHIFT fp_ship_no  RIGHT DELETING TRAILING ''.
  CONCATENATE '<td align="Justified"><font face="Arial" size="2"><font color="black">'
  '<b>' fp_std_text-ship_to '</b>'
  fp_ship_no'</font></td></tr>' INTO lwa_objtxt-line.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR  lwa_objtxt.
*Space between to Rows
  CONCATENATE '<tr><tr><td >'
   ' </td></tr></tr>'
  INTO lwa_objtxt-line.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR  lwa_objtxt.

*Sold To Customer Name 1
  CONDENSE fp_sold_to_addr-name1 .
  IF NOT fp_sold_to_addr-name1 IS INITIAL.
    CONCATENATE '<tr> <td align="left"><font face="Arial" size="2"><font color="black">'
    fp_sold_to_addr-name1'</font></td>' INTO lwa_objtxt-line.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
  ENDIF. " IF NOT fp_sold_to_addr-name1 IS INITIAL
*Ship To Customer Name 1
  CONDENSE fp_ship_to_addr-name1.
  IF NOT fp_ship_to_addr-name1 IS INITIAL.
    CONCATENATE '<td align="Justified"><font face="Arial" size="2"><font color="black">'
    fp_ship_to_addr-name1 '</font></td></tr>'
    INTO lwa_objtxt-line.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
  ENDIF. " IF NOT fp_ship_to_addr-name1 IS INITIAL
*Sold To House #/Street and Supplement
  IF NOT fp_sold_to_addr-house_num1 IS INITIAL.
    CONCATENATE  lv_sold_to_house_value fp_sold_to_addr-house_num1
    INTO lv_sold_to_house_value  SEPARATED BY ', '.
  ENDIF. " IF NOT fp_sold_to_addr-house_num1 IS INITIAL

  IF NOT fp_sold_to_addr-street IS INITIAL.
    CONCATENATE  lv_sold_to_house_value fp_sold_to_addr-street
    INTO lv_sold_to_house_value SEPARATED BY ', '.

  ENDIF. " IF NOT fp_sold_to_addr-street IS INITIAL

  IF NOT fp_sold_to_addr-house_num2 IS INITIAL.
    CONCATENATE  lv_sold_to_house_value fp_sold_to_addr-house_num2
    INTO lv_sold_to_house_value SEPARATED BY ', '.
  ENDIF. " IF NOT fp_sold_to_addr-house_num2 IS INITIAL
*  CONCATENATE fp_sold_to_addr-house_num1   fp_sold_to_addr-street
*              fp_sold_to_addr-house_num2 INTO lv_sold_to_house_value
*              SEPARATED BY ', '.

  SHIFT lv_sold_to_house_value  LEFT DELETING LEADING   ','.
  SHIFT lv_sold_to_house_value  RIGHT DELETING TRAILING ', '.
  CONDENSE lv_sold_to_house_value.
  IF NOT lv_sold_to_house_value IS INITIAL.
    CONCATENATE '<tr> <td align="left"><font face="Arial" size="2"><font color="black">'
    lv_sold_to_house_value '</font></td>' INTO lwa_objtxt-line.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
  ENDIF. " IF NOT lv_sold_to_house_value IS INITIAL
*Ship To House #/Street and Supplement

  IF NOT fp_ship_to_addr-house_num1 IS INITIAL.
    CONCATENATE  lv_ship_to_house_value fp_ship_to_addr-house_num1
    INTO lv_ship_to_house_value  SEPARATED BY ', '.
  ENDIF. " IF NOT fp_ship_to_addr-house_num1 IS INITIAL

  IF NOT  fp_ship_to_addr-street IS INITIAL.
    CONCATENATE  lv_ship_to_house_value  fp_ship_to_addr-street
    INTO lv_ship_to_house_value  SEPARATED BY ', '.
  ENDIF. " IF NOT fp_ship_to_addr-street IS INITIAL

  IF NOT fp_ship_to_addr-house_num2 IS INITIAL.
    CONCATENATE  lv_ship_to_house_value fp_ship_to_addr-house_num2
    INTO lv_ship_to_house_value  SEPARATED BY ', '.
  ENDIF. " IF NOT fp_ship_to_addr-house_num2 IS INITIAL

*  CONCATENATE fp_ship_to_addr-house_num1  fp_ship_to_addr-street
*              fp_ship_to_addr-house_num2 INTO lv_ship_to_house_value
*              SEPARATED BY ', '.
  SHIFT lv_ship_to_house_value  RIGHT DELETING TRAILING ', '.
  SHIFT lv_ship_to_house_value  LEFT DELETING LEADING   ','.
  CONDENSE lv_ship_to_house_value .
  IF NOT lv_ship_to_house_value  IS INITIAL.
    CONCATENATE '<td align="Justified"><font face="Arial" size="2"><font color="black">'
    lv_ship_to_house_value '</font></td></tr>'
    INTO lwa_objtxt-line.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
  ENDIF. " IF NOT lv_ship_to_house_value IS INITIAL
*Sold To Street 2
* ---> Begin of Change for Defect #4207_3 by HRUDRA
*  CONCATENATE fp_sold_to_addr-street  fp_sold_to_addr-str_suppl1
*  INTO lv_sold_to_street_value SEPARATED BY ', '.
*  SHIFT lv_sold_to_street_value  RIGHT DELETING TRAILING ', '.
*  CONDENSE lv_sold_to_street_value.
*  IF NOT lv_sold_to_street_value IS INITIAL.
*    CONCATENATE '<tr> <td align="left"><font face="Arial" size="2"><font color="black">'
*    lv_sold_to_street_value '</font></td>'
*    INTO lwa_objtxt-line.
*    APPEND lwa_objtxt TO li_objtxt.
*    CLEAR  lwa_objtxt.
*  ENDIF. " IF NOT lv_sold_to_street_value IS INITIAL
* <--- End of Change for Defect #4207_3 by HRUDRA
*Ship To Customer Street 2
* ---> Begin of Change for Defect #4207_3 by HRUDRA
*  CONCATENATE fp_ship_to_addr-street   fp_ship_to_addr-str_suppl1
*  INTO lv_ship_to_street_value SEPARATED BY ', '.
*  SHIFT lv_ship_to_street_value  RIGHT DELETING TRAILING ', '.
*  CONDENSE lv_ship_to_street_value.

*  IF NOT lv_ship_to_street_value IS INITIAL.
*    CONCATENATE '<td align="Justified"><font face="Arial" size="2"><font color="black">'
*    lv_ship_to_street_value '</font></td></tr>'
*    INTO lwa_objtxt-line.
*    APPEND lwa_objtxt TO li_objtxt.
*    CLEAR  lwa_objtxt.
*  ENDIF. " IF NOT lv_ship_to_street_value IS INITIAL
* <--- End of Change for Defect #4207_3 by HRUDRA


*Sold To Building/Room/Floor
  CLEAR lv_sold_to_building_value.
  IF NOT fp_sold_to_addr-building IS INITIAL.
    CONCATENATE  lv_sold_to_building_value fp_sold_to_addr-building
    INTO lv_sold_to_building_value SEPARATED BY ', '.
  ENDIF. " IF NOT fp_sold_to_addr-building IS INITIAL
  IF NOT fp_sold_to_addr-roomnumber IS INITIAL.
    CONCATENATE  lv_sold_to_building_value fp_sold_to_addr-roomnumber
    INTO lv_sold_to_building_value SEPARATED BY ', '.
  ENDIF. " IF NOT fp_sold_to_addr-roomnumber IS INITIAL

  IF NOT fp_sold_to_addr-floor IS INITIAL.
    CONCATENATE  lv_sold_to_building_value fp_sold_to_addr-floor
    INTO lv_sold_to_building_value SEPARATED BY ', '.
  ENDIF. " IF NOT fp_sold_to_addr-floor IS INITIAL

  IF NOT fp_sold_to_addr-str_suppl2 IS INITIAL.
    CONCATENATE  lv_sold_to_building_value fp_sold_to_addr-str_suppl2
    INTO lv_sold_to_building_value SEPARATED BY ', '.
  ENDIF. " IF NOT fp_sold_to_addr-str_suppl2 IS INITIAL

*  CONCATENATE fp_sold_to_addr-building  fp_sold_to_addr-roomnumber
*  fp_sold_to_addr-floor  fp_sold_to_addr-str_suppl2
*  INTO lv_sold_to_building_value SEPARATED BY ', '.
  SHIFT lv_sold_to_building_value RIGHT DELETING TRAILING ', '.
  SHIFT lv_sold_to_building_value  LEFT DELETING LEADING space.
  SHIFT lv_sold_to_building_value  LEFT DELETING LEADING   ','.
  CONDENSE lv_sold_to_building_value.
* ****** Begin of Commenting code for Defect 6146
*  IF lv_sold_to_building_value NE space.
**   Begin of Defect 6146
**    CONCATENATE '<tr> <td align="left"><font face="Arial" size="2" color="black">'
**    lv_sold_to_building_value '</font></td>'
**    INTO lwa_objtxt-line.
*
*    lwa_objtxt-line = '<tr> <td align="left"><font face="Arial" size="2" color="black">'.
*    APPEND lwa_objtxt TO li_objtxt.
*    lwa_objtxt-line = lv_sold_to_building_value.
*    APPEND lwa_objtxt TO li_objtxt.
*    lwa_objtxt-line = '</font></td>'.
** End of Defect 6146
*
*    APPEND lwa_objtxt TO li_objtxt.
*    CLEAR  lwa_objtxt.
*  ENDIF. " IF lv_sold_to_building_value NE space

* ****** End of Commenting code for Defect 6146
*Ship To Building/Room/Floor OR Street 3
  CLEAR lv_ship_to_building_value.
  IF NOT fp_ship_to_addr-building IS INITIAL.
    CONCATENATE  lv_ship_to_building_value fp_ship_to_addr-building
    INTO lv_ship_to_building_value SEPARATED BY ', '.
  ENDIF. " IF NOT fp_ship_to_addr-building IS INITIAL

  IF NOT fp_ship_to_addr-roomnumber IS INITIAL.
    CONCATENATE  lv_ship_to_building_value fp_ship_to_addr-roomnumber
    INTO lv_ship_to_building_value SEPARATED BY ', '.
  ENDIF. " IF NOT fp_ship_to_addr-roomnumber IS INITIAL

  IF NOT fp_ship_to_addr-floor IS INITIAL.
    CONCATENATE  lv_ship_to_building_value fp_ship_to_addr-floor
    INTO lv_ship_to_building_value SEPARATED BY ', '.
  ENDIF. " IF NOT fp_ship_to_addr-floor IS INITIAL

  IF NOT fp_ship_to_addr-str_suppl2 IS INITIAL.
    CONCATENATE  lv_ship_to_building_value fp_ship_to_addr-str_suppl2
    INTO lv_ship_to_building_value SEPARATED BY ', '.
  ENDIF. " IF NOT fp_ship_to_addr-str_suppl2 IS INITIAL

*  CONCATENATE fp_ship_to_addr-building  fp_ship_to_addr-roomnumber
*  fp_ship_to_addr-floor   fp_ship_to_addr-str_suppl2
*  INTO lv_ship_to_building_value SEPARATED BY ', '.
  SHIFT lv_ship_to_building_value RIGHT DELETING TRAILING ', '.
  SHIFT lv_ship_to_building_value  LEFT DELETING LEADING space.
  SHIFT lv_ship_to_building_value  LEFT DELETING LEADING   ','.

  CONDENSE lv_ship_to_building_value.
* ****** Begin of Commenting code for Defect 6146
*  IF  lv_ship_to_building_value NE space AND
*      lv_sold_to_building_value NE space. " Defect 6146
**  Begin of Defect 6146
**    CONCATENATE '<td align="Justified"><font face="Arial" size="2" color="black">'
**    lv_ship_to_building_value
**    INTO lwa_objtxt-line.
*
*    lwa_objtxt-line = '<td align="Justified"><font face="Arial" size="2" color="black">'.
*    APPEND lwa_objtxt TO li_objtxt.
*    lwa_objtxt-line = lv_ship_to_building_value.
*    APPEND lwa_objtxt TO li_objtxt.
*
*    lwa_objtxt-line = '</font></td></tr>'.
**  End of Defect 6146
*
*    APPEND lwa_objtxt TO li_objtxt.
*    CLEAR  lwa_objtxt.
*  ENDIF. " IF lv_ship_to_building_value NE space AND
*
** Begin of Change for Defect 6146
*  IF  lv_ship_to_building_value = space AND
*     lv_sold_to_building_value NE space.
*
**Ship To City, State,postal code and country should be single line
*    CONCATENATE fp_ship_to_addr-city1    fp_ship_to_addr-bezei
*                fp_ship_to_addr-post_code1 " Postal code
*                fp_ship_to_addr-country    "Country
*    INTO lv_ship_to_city_value
*    SEPARATED BY ', '.
*    SHIFT lv_ship_to_city_value RIGHT DELETING TRAILING ', '.
*    CONDENSE lv_ship_to_city_value.
*    IF NOT lv_ship_to_city_value IS INITIAL.
*      CONCATENATE '<td align="Justified"><font face="Arial" size="2" color="black">'
*      lv_ship_to_city_value
*       '</font></td></tr>'
*      INTO lwa_objtxt-line.
*      APPEND lwa_objtxt TO li_objtxt.
*      CLEAR  lwa_objtxt.
*    ENDIF. " IF NOT lv_ship_to_city_value IS INITIAL
*
*  ENDIF. " IF lv_ship_to_building_value = space AND

* ****** End  of Commenting code for Defect 6146
* End of Chnage for Defect 6146
*Sold To City, State,postal code and country should be single line
  CONCATENATE fp_sold_to_addr-city1    fp_sold_to_addr-bezei
* ---> Begin of Change for Defect #4207_3 by HRUDRA
              fp_sold_to_addr-post_code1 " Postal code
              fp_sold_to_addr-country    "Country
* <--- End of Change for Defect #4207_2 by HRUDRA
  INTO lv_sold_to_city_value
  SEPARATED BY ', '.
  SHIFT lv_sold_to_city_value RIGHT DELETING TRAILING ', '.
  CONDENSE lv_sold_to_city_value.

* ****** Begin of Commenting code for Defect 6146
*  IF NOT lv_sold_to_city_value IS INITIAL .
*    CONCATENATE '<tr> <td align="left"><font face="Arial" size="2" color="black">'
*    lv_sold_to_city_value '</font></td>'
*    INTO lwa_objtxt-line.
*    APPEND lwa_objtxt TO li_objtxt.
*    CLEAR  lwa_objtxt.
*  ENDIF. " IF NOT lv_sold_to_city_value IS INITIAL


**  Begin of Defect 6146
*  IF lv_sold_to_building_value = space AND
*     lv_ship_to_building_value NE space.
*
*    lwa_objtxt-line = '<td align="Justified"><font face="Arial" size="2" color="black">'.
*    APPEND lwa_objtxt TO li_objtxt.
*    lwa_objtxt-line = lv_ship_to_building_value.
*    APPEND lwa_objtxt TO li_objtxt.
*
*    lwa_objtxt-line = '</font></td></tr>'.
*    APPEND lwa_objtxt TO li_objtxt.
*    CLEAR  lwa_objtxt.
*
*    CONCATENATE '<tr> <td align="left"><font face="Arial" size="2" color="black">'
*        '  ' '</font></td>'
*        INTO lwa_objtxt-line.
*    APPEND lwa_objtxt TO li_objtxt.
*
*  ENDIF. " IF lv_sold_to_building_value = space AND
*  End of Defect 6146
* ****** End  of Commenting code for Defect 6146

*Ship To City, State,postal code and country should be single line
  CONCATENATE fp_ship_to_addr-city1    fp_ship_to_addr-bezei
* ---> Begin of Change for Defect #4207_3 by HRUDRA
              fp_ship_to_addr-post_code1 " Postal code
              fp_ship_to_addr-country    "Country
* <--- End of Change for Defect #4207_2 by HRUDRA
  INTO lv_ship_to_city_value
  SEPARATED BY ', '.
  SHIFT lv_ship_to_city_value RIGHT DELETING TRAILING ', '.
  CONDENSE lv_ship_to_city_value.

* ****** Begin  of Commenting code for Defect 6146
*  IF  lv_ship_to_building_value NE space . " Defect 6146
*
*    IF NOT lv_ship_to_city_value IS INITIAL.
*      CONCATENATE '<td align="Justified"><font face="Arial" size="2" color="black">'
*      lv_ship_to_city_value
*       '</font></td></tr>'
*      INTO lwa_objtxt-line.
*      APPEND lwa_objtxt TO li_objtxt.
*      CLEAR  lwa_objtxt.
*    ENDIF. " IF NOT lv_ship_to_city_value IS INITIAL
*  ENDIF. " Defect 6146
* ****** End  of Commenting code for Defect 6146
* ---> Begin of Change for Defect #4207_3 by HRUDRA
*Sold To  Postal Code
*  CONDENSE fp_sold_to_addr-post_code1.
*  IF NOT fp_sold_to_addr-post_code1 IS INITIAL.
*    CONCATENATE '<tr> <td align="left"><font face="Arial" size="2" color="black">'
*    fp_sold_to_addr-post_code1 '</font></td>'
*    INTO lwa_objtxt-line.
*    APPEND lwa_objtxt TO li_objtxt.
*    CLEAR  lwa_objtxt.
*  ENDIF. " IF NOT fp_sold_to_addr-post_code1 IS INITIAL
**Ship To Postal Code
*  CONDENSE fp_ship_to_addr-post_code1.
*  IF NOT fp_ship_to_addr-post_code1 IS INITIAL.
*    CONCATENATE '<td align="Justified"><font face="Arial" size="2" color="black">'
*    fp_ship_to_addr-post_code1
*    '</font></td></tr>'
*    INTO lwa_objtxt-line.
*    APPEND lwa_objtxt TO li_objtxt.
*    CLEAR  lwa_objtxt.
*  ENDIF. " IF NOT fp_ship_to_addr-post_code1 IS INITIAL
**Sold To  Country
*  CONDENSE fp_sold_to_addr-country.
*  IF NOT fp_sold_to_addr-country IS INITIAL.
*    CONCATENATE '<tr> <td align="left"><font face="Arial" size="2" color="black">'
*    fp_sold_to_addr-country '</font></td>'
*    INTO lwa_objtxt-line.
*    APPEND lwa_objtxt TO li_objtxt.
*    CLEAR  lwa_objtxt.
*  ENDIF. " IF NOT fp_sold_to_addr-country IS INITIAL
**Ship To  Country
*  CONDENSE fp_ship_to_addr-kind_text.
*  IF NOT fp_ship_to_addr-country IS INITIAL.
*    CONCATENATE '<td align="Justified"><font face="Arial" size="2" color="black">'
*    fp_ship_to_addr-country
*
*    '</font></td></tr>'
*    INTO lwa_objtxt-line.
*    APPEND lwa_objtxt TO li_objtxt.
*    CLEAR  lwa_objtxt.
*  ENDIF. " IF NOT fp_ship_to_addr-country IS INITIAL
* <--- End of Change for Defect #4207_3 by HRUDRA


***********************Begin of New Logic ***********************************

* Begin of Defect 6146

  IF fp_sold_to_addr-str_suppl1 NE space.
    lwa_address-soldto = fp_sold_to_addr-str_suppl1.
    APPEND lwa_address TO li_address.
    CLEAR lwa_address.
  ENDIF. " IF fp_sold_to_addr-str_suppl1 NE space

  IF lv_sold_to_building_value NE space.
    lwa_address-soldto = lv_sold_to_building_value.
    APPEND lwa_address TO li_address.
    CLEAR lwa_address.
  ENDIF. " IF lv_sold_to_building_value NE space

  IF lv_sold_to_city_value NE space.
    lwa_address-soldto = lv_sold_to_city_value.
    APPEND lwa_address TO li_address.
    CLEAR lwa_address.
  ENDIF. " IF lv_sold_to_city_value NE space

* Now update the Ship To column
  READ TABLE li_address ASSIGNING <lfs_address> INDEX 1.
  IF sy-subrc = 0.
    <lfs_address>-shipto = fp_ship_to_addr-str_suppl1.
    IF <lfs_address>-shipto = space.
      <lfs_address>-shipto = lv_ship_to_building_value.
    ENDIF. " IF <lfs_address>-shipto = space
    IF <lfs_address>-shipto = space.
      <lfs_address>-shipto = lv_ship_to_city_value.
    ENDIF. " IF <lfs_address>-shipto = space
  ENDIF. " IF sy-subrc = 0

  READ TABLE li_address ASSIGNING <lfs_address> INDEX 2.
  IF sy-subrc = 0.
    IF fp_ship_to_addr-str_suppl1 = space.
      IF lv_ship_to_building_value NE space.
        <lfs_address>-shipto = lv_ship_to_city_value.
      ENDIF. " IF lv_ship_to_building_value NE space
    ELSE. " ELSE -> IF fp_ship_to_addr-str_suppl1 = space
      <lfs_address>-shipto = lv_ship_to_building_value.
      IF <lfs_address>-shipto = space.
        <lfs_address>-shipto = lv_ship_to_city_value.
      ENDIF. " IF <lfs_address>-shipto = space
    ENDIF. " IF fp_ship_to_addr-str_suppl1 = space

  ELSE. " ELSE -> IF sy-subrc = 0
    IF fp_ship_to_addr-str_suppl1 = space.
      IF lv_ship_to_building_value NE space.
        lwa_address-shipto = lv_ship_to_city_value .
        APPEND lwa_address TO li_address.
        CLEAR lwa_address.
      ENDIF. " IF lv_ship_to_building_value NE space
    ELSE. " ELSE -> IF fp_ship_to_addr-str_suppl1 = space
      lwa_address-shipto = lv_ship_to_building_value.
      IF lwa_address-shipto = space.
        lwa_address-shipto = lv_ship_to_city_value.
      ENDIF. " IF lwa_address-shipto = space
      APPEND lwa_address TO li_address.
      CLEAR lwa_address.
    ENDIF. " IF fp_ship_to_addr-str_suppl1 = space

  ENDIF. " IF sy-subrc = 0

  READ TABLE li_address ASSIGNING <lfs_address> INDEX 3.
  IF sy-subrc = 0.
    IF fp_ship_to_addr-str_suppl1 NE space AND
       lv_ship_to_building_value NE space.
      <lfs_address>-shipto = lv_ship_to_city_value.
    ENDIF. " IF fp_ship_to_addr-str_suppl1 NE space AND
  ELSE. " ELSE -> IF sy-subrc = 0
    IF fp_ship_to_addr-str_suppl1 NE space AND
       lv_ship_to_building_value NE space.
      lwa_address-shipto = lv_ship_to_city_value .
      APPEND lwa_address TO li_address.
      CLEAR lwa_address.
    ENDIF. " IF fp_ship_to_addr-str_suppl1 NE space AND
  ENDIF. " IF sy-subrc = 0


  DELETE li_address WHERE soldto IS INITIAL AND
                          shipto IS INITIAL.

* Now Print the addresses.
  LOOP AT li_address ASSIGNING <lfs_address>.

    IF <lfs_address>-soldto IS NOT INITIAL.
      lwa_objtxt-line = '<tr> <td align="left"><font face="Arial" size="2" color="black">'.
      APPEND lwa_objtxt TO li_objtxt.
      lwa_objtxt-line = <lfs_address>-soldto.
      APPEND lwa_objtxt TO li_objtxt.
      lwa_objtxt-line = '</font></td>'.
      APPEND lwa_objtxt TO li_objtxt.
      IF lv_column2 = abap_true.
        lwa_objtxt-line = '</tr>'.
        APPEND lwa_objtxt TO li_objtxt.
      ENDIF. " IF lv_column2 = abap_true
    ELSE. " ELSE -> IF <lfs_address>-soldto IS NOT INITIAL
      lv_column1 = abap_true.
    ENDIF. " IF <lfs_address>-soldto IS NOT INITIAL


    IF  <lfs_address>-shipto IS NOT INITIAL.
      IF lv_column1 IS INITIAL.

        lwa_objtxt-line = '<td align="Justified"><font face="Arial" size="2" color="black">'.
        APPEND lwa_objtxt TO li_objtxt.
        lwa_objtxt-line = <lfs_address>-shipto.
        APPEND lwa_objtxt TO li_objtxt.
        lwa_objtxt-line = '</font></td></tr>'.
        APPEND lwa_objtxt TO li_objtxt.

      ELSE. " ELSE -> IF lv_column1 IS INITIAL
        CONCATENATE '<tr> <td align="left"><font face="Arial" size="2" color="black">'
    ' ' '</font></td>' INTO lwa_objtxt-line.
        APPEND lwa_objtxt TO li_objtxt.

        lwa_objtxt-line = '<td align="Justified"><font face="Arial" size="2" color="black">'.
        APPEND lwa_objtxt TO li_objtxt.
        lwa_objtxt-line = <lfs_address>-shipto.
        APPEND lwa_objtxt TO li_objtxt.
        lwa_objtxt-line = '</font></td></tr>'.
        APPEND lwa_objtxt TO li_objtxt.

      ENDIF. " IF lv_column1 IS INITIAL
    ELSE. " ELSE -> IF <lfs_address>-shipto IS NOT INITIAL
      lv_column2 = abap_true.
    ENDIF. " IF <lfs_address>-shipto IS NOT INITIAL

  ENDLOOP. " LOOP AT li_address ASSIGNING <lfs_address>

* End   of Defect 6146


***********************End of New Logic ***********************************




* kind text
  CONDENSE fp_ship_to_addr-kind_text.
  IF NOT fp_ship_to_addr-kind_text IS INITIAL.
    CONCATENATE '<tr> <td align="Left" ><font face="Arial" size="2" color="black">'
      '.' '</font></td>'
    INTO lwa_objtxt-line.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.

    CONCATENATE '<td align="Justified"><font face="Arial" size="2" color="black">'
    '<b>' fp_std_text-kind_txt '</b>'
    fp_ship_to_addr-kind_text '</font></td></tr>'
    INTO lwa_objtxt-line.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
  ENDIF. " IF NOT fp_ship_to_addr-kind_text IS INITIAL
*End of HTML table
  lwa_objtxt-line = '</TABLE>'.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR lwa_objtxt.

*Draw a Horizontal line
  lwa_objtxt-line = '<hr width="100%">'.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR  lwa_objtxt.
  lwa_objtxt-line = '<TABLE  width= "100%" >'.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR  lwa_objtxt.
* ---> Begin of Change for Defect #4207 by Hrudra
*Line NO.
  IF fp_std_text-nast_langu EQ lc_langu_fr
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
    AND fp_lv_d3_lang_flag NE abap_true.
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
    CONCATENATE '<TR ><td  width= "14.285%">'
                '<FONT COLOR = "BLACK"> <font face="Arial" size="2">'
                '<b>' fp_std_text-line_fr  '</b>'
                '<br>' '.'
                 '</FONT>'
                '</td>'  INTO lwa_objtxt-line.

    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
*Spanish Translation
*  ELSEIF  fp_std_text-nast_langu EQ lc_langu_es.
*    CONCATENATE '<TR ><td  width= "10%">'
*                 '<FONT COLOR = "BLACK"> <font face="Arial" size="2">'
*                 '<b>' fp_std_text-line '</b>'
*                 '<BR>' '.'
*                 '</FONT></td>'  INTO lwa_objtxt-line.
*    APPEND lwa_objtxt TO li_objtxt.
*    CLEAR  lwa_objtxt.
*Eng Transl
  ELSE. " ELSE -> IF fp_std_text-nast_langu EQ lc_langu_fr
    CONCATENATE '<TR ><td  width= "14.285%">'
                '<FONT COLOR = "BLACK"> <font face="Arial" size="2">'
                '<b>' fp_std_text-line '</b></FONT>'
                  '</td>'  INTO lwa_objtxt-line.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
  ENDIF. " IF fp_std_text-nast_langu EQ lc_langu_fr
*Material
  IF  fp_std_text-nast_langu EQ lc_langu_fr
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
    AND fp_lv_d3_lang_flag NE abap_true.
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
    CONCATENATE '<td  width= "16%" align="LEFT" >'
                  '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
                  '<b>'  fp_std_text-material '</b>'
                  '<br>' '.'
                  '</FONT>'
                  '</td>'  INTO lwa_objtxt-line.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
  ELSE. " ELSE -> IF fp_std_text-nast_langu EQ lc_langu_fr

    CONCATENATE '<td  width= "16%" align="LEFT">'
                  '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
                  '<b>'  fp_std_text-material
                  '<br>' fp_std_text-descripn
                  '</b></FONT>'
                  '</td>'  INTO lwa_objtxt-line.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
  ENDIF. " IF fp_std_text-nast_langu EQ lc_langu_fr
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  IF fp_lv_d3_lang_flag NE abap_true.
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
    IF  fp_std_text-nast_langu EQ lc_langu_fr.

*For French Translation
*Order Qty
      CONCATENATE '<td  width= "16.29%" align="RIGHT">' "13
                    '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
                    '<b>'  fp_std_text-ord_qty_fr
                    '</b></FONT>'
                    '</td>'  INTO lwa_objtxt-line.

      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
*For  Spanish Translation
    ELSEIF fp_std_text-nast_langu EQ lc_langu_es.
*Order Qty
      CONCATENATE '<td  width= "16.29%" align="RIGHT"> '
                    '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
                    '<b>' fp_std_text-ord_qty '</b></FONT>'
                    '</td>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
    ELSE. " ELSE -> IF fp_std_text-nast_langu EQ lc_langu_fr
*For Eng  Translation
*Order Qty
      CONCATENATE '<td  width= "16.29%" align="RIGHT">'
                    '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
                    '<b>' fp_std_text-ord_qty '</b></FONT>'
                    '</td>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
    ENDIF. " IF fp_std_text-nast_langu EQ lc_langu_fr

* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*Convert UOM according toshipto language
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag NE abap_true
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input    = lc_uom
        language = fp_lv_shipto_lang
      IMPORTING
        output   = lv_uom.

    CONDENSE lv_uom .
    CONCATENATE '(' lv_uom ')' INTO lv_uom_text.
    CONDENSE: fp_std_text-ord_qty.
    CONDENSE: lv_uom_text.
    CONCATENATE '<td width= "16.29%" align="RIGHT">'
                     '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
                     '<b>' fp_std_text-ord_qty '</b>'
                     '<b>' lv_uom_text
                     '</b></FONT>'
                     '</td>'  INTO lwa_objtxt-line.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
  ENDIF. " IF fp_lv_d3_lang_flag NE abap_true
  IF fp_lv_d3_lang_flag NE abap_true.
* * <--- End of Change for D3_OTC_FDD_0073 by kmishra
*For French Translation
    IF fp_std_text-nast_langu EQ lc_langu_fr.
*Shipped Qty
      CONCATENATE '<td  width= "15.279%" align="RIGHT">' "12
                       ' <FONT COLOR = "BLACK"><font face="Arial" size="2">'
                       '<b>'  fp_std_text-shp_qty_fr
                       '</b></FONT>'
                       '</td>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
*For  Spanish Translation
*  ELSEIF fp_std_text-nast_langu EQ lc_langu_es.
*Shipped Qty
*    CONCATENATE '<td  width= "12%" align="CENTER">'
*                     ' <FONT COLOR = "BLACK"><font face="Arial" size="2">'
*                     '<b>' fp_std_text-shp_qty '</b></FONT>'
*                     '</td>'  INTO lwa_objtxt-line.
*    APPEND lwa_objtxt TO li_objtxt.
*    CLEAR  lwa_objtxt.
    ELSE. " ELSE -> IF fp_std_text-nast_langu EQ lc_langu_fr
*For Eng   Translation
*Shipped Qty
      CONCATENATE '<td  width= "15.279%" align="RIGHT">'
                       ' <FONT COLOR = "BLACK"><font face="Arial" size="2">'
                       '<b>' fp_std_text-shp_qty '</b></FONT>'
                       '</td>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
    ENDIF. " IF fp_std_text-nast_langu EQ lc_langu_fr
* * ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag NE abap_true
    CONDENSE: fp_std_text-shp_qty.
    CONCATENATE '<td width= "15.279%" align="RIGHT">'
                       '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
                       '<b>' fp_std_text-shp_qty '</b>'
                       '<b>' lv_uom_text
                       '</b></FONT>'
                       '</td>'  INTO lwa_objtxt-line.

    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
    CLEAR: lv_uom.
  ENDIF. " IF fp_lv_d3_lang_flag NE abap_true
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
*For French Translation
  IF fp_std_text-nast_langu EQ lc_langu_fr
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
    AND fp_lv_d3_lang_flag NE abap_true.
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
*Ship Date

    CONCATENATE '<td  width= "14.29%" align="CENTER">' "11
                     '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
                     '<b>' fp_std_text-shp_date_fr '</b>'
                     '<br>'  '.'
                     '</FONT>'
                     '</td>'  INTO lwa_objtxt-line.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.

*  ELSEIF fp_std_text-nast_langu EQ lc_langu_es.
*Spanish Translation
**Shipp Date
*    CONCATENATE '<td  width= "14.29%" align="CENTER" valign="TOP">'
*                     '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
*                     '<b>' fp_std_text-shp_date '</b></FONT>'
*                     '</td>'  INTO lwa_objtxt-line.
*    APPEND lwa_objtxt TO li_objtxt.
*    CLEAR  lwa_objtxt.
  ELSE. " ELSE -> IF fp_std_text-nast_langu EQ lc_langu_fr
*For Eng  Translation
*Shipp Date
    CONCATENATE '<td  width= "14.29%" align="CENTER">'
                     '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
                     '<b>' fp_std_text-shp_date '</b></FONT>'
                     '</td>'  INTO lwa_objtxt-line.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
  ENDIF. " IF fp_std_text-nast_langu EQ lc_langu_fr
*For French Translation
  IF fp_std_text-nast_langu EQ lc_langu_fr
    and fp_lv_d3_lang_flag is INITIAL.           "D3_OTC_FDD_0073 only for Canada FR.
*Tracking No.
    CONCATENATE '<td  width= "14%" >' "20
                   '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
                   '<b>'  fp_std_text-trackng_fr '</b>'
                   '<br>' '.'
                   '</FONT>'
                   '</td>'  INTO lwa_objtxt-line.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
*For Spanish Translation
*  ELSEIF fp_std_text-nast_langu EQ lc_langu_es.
*    CONCATENATE '<td  width= "25%" align="RIGHT">'
*                  '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
*                  '<b>' fp_std_text-trackng '</b>'
*                  '<BR>' '.'
*                  '</FONT></td>'  INTO lwa_objtxt-line.
*    APPEND lwa_objtxt TO li_objtxt.
*    CLEAR  lwa_objtxt.
  ELSE. " ELSE -> IF fp_std_text-nast_langu EQ lc_langu_fr
*For Eng   Translation
    CONCATENATE '<td  width= "14%" >'
                   '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
                   '<b>' fp_std_text-trackng '</b> </FONT>'
                   '</td>'  INTO lwa_objtxt-line.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
  ENDIF. " IF fp_std_text-nast_langu EQ lc_langu_fr
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  IF fp_lv_d3_lang_flag NE abap_true.
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
*For French Translation
    IF fp_std_text-nast_langu EQ lc_langu_fr.
*Open Qty
      CONCATENATE '<td  width= "10%" align="RIGHT">' "15
                     '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
                     '<b>'  fp_std_text-open_qty_fr
                     '</b></FONT>'
                     '</td></TR>'  INTO lwa_objtxt-line.

      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
**For  Spanish Translation
*  ELSEIF fp_std_text-nast_langu EQ lc_langu_es.
**Open Qty
*    CONCATENATE '<td  width= "12%" align="CENTER">'
*                   '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
*                   '<b>' fp_std_text-open_qty '</b></FONT>'
*                   '</td></TR>'  INTO lwa_objtxt-line.
*    APPEND lwa_objtxt TO li_objtxt.
*    CLEAR  lwa_objtxt.
    ELSE. " ELSE -> IF fp_std_text-nast_langu EQ lc_langu_fr
*For Eng Translation
*Open Qty
      CONCATENATE '<td  width= "10%" align="RIGHT">'
                     '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
                     '<b>' fp_std_text-open_qty '</b></FONT>'
                     '</td></TR>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
    ENDIF. " IF fp_std_text-nast_langu EQ lc_langu_fr
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  ELSE. " ELSE -> IF fp_lv_d3_lang_flag NE abap_true
    CONDENSE: fp_std_text-open_qty.
    CONCATENATE '<td width= "15.279%" align="RIGHT">'
                       '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
                       '<b>' fp_std_text-open_qty '</b>'
                       '<b>' lv_uom_text
                       '</b></FONT>'
                       '</td>'  INTO lwa_objtxt-line.

    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
    CLEAR: lv_uom.
  ENDIF. " IF fp_lv_d3_lang_flag NE abap_true
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
*End of Html Table
  lwa_objtxt-line = '</TABLE>'.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR  lwa_objtxt.
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  IF fp_lv_d3_lang_flag NE abap_true.
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
*In case of French, separate line for Eng. Header
    lwa_objtxt-line = '<TABLE  width= "100%" >'.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
*Line NO.
    IF fp_std_text-nast_langu EQ lc_langu_fr.
      CONCATENATE '<TR ><td  width= "14.285%" align="LEFT">'
                  '<FONT COLOR = "BLACK"> <font face="Arial" size="2">'
                  '<b>' fp_std_text-line '</b></FONT>'
                    '</td>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
*Material Description
      CONCATENATE '<td  width= "16%" align="LEFT">'
                    '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
                    '<b>' fp_std_text-descripn '</b></FONT>'
                    '</td>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
*Order Qty
      CONCATENATE '<td  width= "14.29%" align="RIGHT">'
                    '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
                    '<b>' fp_std_text-ord_qty '</b></FONT>'
                    '</td>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
*Shipped Qty
      CONCATENATE '<td  width= "14.279%" align="RIGHT">'
                       ' <FONT COLOR = "BLACK"><font face="Arial" size="2">'
                       '<b>' fp_std_text-shp_qty '</b></FONT>'
                       '</td>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
*Shipp Date
      CONCATENATE '<td  width= "14.29%" align="CENTER">'
                       '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
                       '<b>' fp_std_text-shp_date '</b></FONT>'
                       '</td>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
*Tracking No
      CONCATENATE '<td  width= "14%" '
                     '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
                     '<b>' fp_std_text-trackng '</b> </FONT>'
                     '</td>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
*Open Qty
      CONCATENATE '<td  width= "10%" align="RIGHT">'
                     '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
                     '<b>' fp_std_text-open_qty '</b></FONT>'
                     '</td></TR>'  INTO lwa_objtxt-line.

      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
    ENDIF. " IF fp_std_text-nast_langu EQ lc_langu_fr
* <--- End of Change for Defect #4207 by Hrudra
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
  ENDIF. " IF fp_lv_d3_lang_flag NE abap_true
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
*End of Html Table
  lwa_objtxt-line = '</TABLE>'.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR  lwa_objtxt.
*Draw a horizontal Line
  lwa_objtxt-line = '<hr width="100%">'.
  APPEND lwa_objtxt TO li_objtxt.
  CLEAR  lwa_objtxt.
*Writing line item data in HTML format
  LOOP AT fp_line_item ASSIGNING <lfs_item>.
*Converting menge ,lfimg & open Qty into UOM(EA)
    WRITE <lfs_item>-menge    TO lv_menge UNIT <lfs_item>-meins.
    CONDENSE lv_menge.
    WRITE <lfs_item>-lfimg    TO lv_lfimg UNIT <lfs_item>-meins.
    CONDENSE lv_lfimg.
    WRITE <lfs_item>-open_qty TO lv_op_qty UNIT <lfs_item>-meins.
    CONDENSE lv_op_qty.
* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
*Converting menge, lfimg and open quantity acc to ship to country
    IF fp_lv_d3_lang_flag EQ abap_true.
      CLEAR: lv_menge.
      CLEAR:lv_lfimg.
      CLEAR:lv_op_qty.
      SET COUNTRY fp_lv_shipto_country.
      WRITE <lfs_item>-menge    TO lv_menge ##uom_in_mes.
      WRITE <lfs_item>-lfimg    TO lv_lfimg ##uom_in_mes.
      WRITE <lfs_item>-open_qty TO lv_op_qty ##uom_in_mes.
    ENDIF. " IF fp_lv_d3_lang_flag EQ abap_true
* <--- End of Change for D3_OTC_FDD_0073 by kmishra
*Converting Date into client formt
* ---> Begin of Change for D2_OTC_FDD_0073 Defect # 4207 by APODDAR
*For French Translation
    IF fp_std_text-nast_langu EQ lc_langu_fr.

      CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
        EXPORTING
          iv_enhancement_no = lc_enh_no
        TABLES
          tt_enh_status     = li_constant.
      DELETE li_constant WHERE active NE abap_true.

      READ TABLE li_constant ASSIGNING <lfs_constant>
                WITH KEY criteria = lc_country.
      IF sy-subrc = 0.

 "Getting the Date Format for French Nation
        SET COUNTRY <lfs_constant>-sel_low.
      ENDIF. " IF sy-subrc = 0
      CLEAR lv_erdat.
      WRITE <lfs_item>-erdat TO lv_erdat MM/DD/YY.
      REPLACE ALL OCCURRENCES OF lc_slash IN lv_erdat WITH lc_hyphen.
    ELSE. " ELSE -> IF fp_std_text-nast_langu EQ lc_langu_fr
      CLEAR lv_erdat.
      WRITE <lfs_item>-erdat TO lv_erdat.
    ENDIF. " IF fp_std_text-nast_langu EQ lc_langu_fr

* <--- End    of Change for D2_OTC_FDD_0073 Defect # 4207 by APODDAR

* ---> Begin of Change for D3_OTC_FDD_0073 by kmishra
    IF fp_lv_d3_lang_flag = abap_true.
*Covert date according to ship to party
      CALL FUNCTION 'ZDEV_DATE_FORMAT'
        EXPORTING
          i_date       = <lfs_item>-erdat "date should always be in YYYYMMDD
          i_format     = lc_format
          i_langu      = fp_lv_shipto_lang
        IMPORTING
          e_date_final = lv_erdat.
    ENDIF. " IF fp_lv_d3_lang_flag = abap_true
* ---> End of Change for D3_OTC_FDD_0073 by kmishra

    CONDENSE : lv_lfimg,lv_lfimg,lv_op_qty.
*    IF fp_std_text-nast_langu EQ lc_langu_fr OR fp_std_text-nast_langu EQ lc_langu_es.
*New Table for Html
    lwa_objtxt-line = '<TABLE  width= "100%">'.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.

    IF fp_std_text-nast_langu EQ lc_langu_fr.
      CONCATENATE '<TR><td  width= "14.2845%" > '
     '<FONT COLOR = "BLACK"><font face="Arial" size="2">' <lfs_item>-vbelp '</FONT>'
                  '</td>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.

    ELSE. " ELSE -> IF fp_std_text-nast_langu EQ lc_langu_fr
      CONCATENATE '<TR><td  width= "14.2845%" > '
    '<FONT COLOR = "BLACK"><font face="Arial" size="2">' <lfs_item>-vbelp '</FONT>'
                 '</td>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt .
    ENDIF. " IF fp_std_text-nast_langu EQ lc_langu_fr

    IF fp_std_text-nast_langu EQ lc_langu_fr.
*Material & Description
      CONCATENATE '<td  width= "16%" align="LEFT">'
      '<FONT COLOR = "BLACK"><font face="Arial" size="2">' <lfs_item>-matnr '<BR>'
                    <lfs_item>-arktx '</FONT>'
                    '</td>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
    ELSE. " ELSE -> IF fp_std_text-nast_langu EQ lc_langu_fr
      CONCATENATE '<td  width= "16%" align="LEFT">'
     '<FONT COLOR = "BLACK"><font face="Arial" size="2">' <lfs_item>-matnr '<BR>'
                   <lfs_item>-arktx '</FONT>'
                   '</td>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
    ENDIF. " IF fp_std_text-nast_langu EQ lc_langu_fr
* ---> Begin of Change for Defect #4207 by Hrudra
    IF fp_std_text-nast_langu EQ lc_langu_fr.

*Order Qty
      CONCATENATE '<td  width= "14.2845%" align="RIGHT">' "13
      '<FONT COLOR = "BLACK"><font face="Arial" size="2">' lv_menge '</FONT>'
                    '</td>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
*    ELSEIF fp_std_text-nast_langu EQ lc_langu_es.
*Order Qty
*      CONCATENATE '<td  width= "11%" align="RIGHT">'
*      '<FONT COLOR = "BLACK"><font face="Arial" size="2">' lv_menge '</FONT>'
*                    '</td>'  INTO lwa_objtxt-line.
*      APPEND lwa_objtxt TO li_objtxt.
*      CLEAR  lwa_objtxt.
    ELSE. " ELSE -> IF fp_std_text-nast_langu EQ lc_langu_fr
*Order Qty
      CONCATENATE '<td  width= "14.2845%" align="RIGHT">'
      '<FONT COLOR = "BLACK"><font face="Arial" size="2">' lv_menge '</FONT>'
                    '</td>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
    ENDIF. " IF fp_std_text-nast_langu EQ lc_langu_fr

    IF NOT fp_std_text-shp_qty_fr IS INITIAL.
*Shipped Qty
      CONCATENATE '<td  width= "14.2845%" align="RIGHT" >'
      '<FONT COLOR = "BLACK"><font face="Arial" size="2">' lv_lfimg '</FONT>'
                   '</td>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
*    ELSEIF fp_std_text-nast_langu EQ lc_langu_es.
*      CONCATENATE '<td  width= "11.75%" align="RIGHT">'
*     '<FONT COLOR = "BLACK"><font face="Arial" size="2">' lv_lfimg '</FONT>'
*                  '</td>'  INTO lwa_objtxt-line.
*      APPEND lwa_objtxt TO li_objtxt.
*      CLEAR  lwa_objtxt.
    ELSE. " ELSE -> IF NOT fp_std_text-shp_qty_fr IS INITIAL
      CONCATENATE '<td  width= "14.2845%" align="RIGHT" >'
   '<FONT COLOR = "BLACK"><font face="Arial" size="2">' lv_lfimg '</FONT>'
                '</td>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt  TO li_objtxt.
      CLEAR  lwa_objtxt.
    ENDIF. " IF NOT fp_std_text-shp_qty_fr IS INITIAL
    IF NOT fp_std_text-shp_date_fr IS INITIAL.
*Shipped Date
      CONCATENATE '<td  width= "14.2845%" align="CENTER">' "11
      '<FONT COLOR = "BLACK"><font face="Arial" size="2">' lv_erdat '</FONT>'
                       '</td>'  INTO lwa_objtxt-line.

      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
*    ELSEIF fp_std_text-nast_langu EQ lc_langu_es.
**Shipped Date
*      CONCATENATE '<td  width= "14.2845%%" align="RIGHT">'
*      '<FONT COLOR = "BLACK"><font face="Arial" size="2">' lv_erdat '</FONT>'
*                       '</td>'  INTO lwa_objtxt-line.
*
*      APPEND lwa_objtxt TO li_objtxt.
*      CLEAR  lwa_objtxt.
    ELSE. " ELSE -> IF NOT fp_std_text-shp_date_fr IS INITIAL
*Shipped Date
      CONCATENATE '<td  width= "14.2845%" align="CENTER">'
      '<FONT COLOR = "BLACK"><font face="Arial" size="2">' lv_erdat '</FONT>'
                       '</td>'  INTO lwa_objtxt-line.

      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
    ENDIF. " IF NOT fp_std_text-shp_date_fr IS INITIAL
* ---> Begin of Change for Defect #4207_2 by Hrudra
    CLEAR  lv_url .
    CASE <lfs_item>-vsbed.
      WHEN lc_z1.
        CONCATENATE  lc_url_z1 <lfs_item>-lifex INTO lv_url.
      WHEN lc_z2.
        CONCATENATE lv_url lc_url_z3 INTO lv_url.
        CONCATENATE  lc_url_z2 <lfs_item>-lifex INTO lv_url.
      WHEN lc_z3.
        CONCATENATE  lc_url_z3 <lfs_item>-lifex INTO lv_url.
      WHEN lc_z4.
        CONCATENATE  lc_url_z4 <lfs_item>-lifex INTO lv_url.
      WHEN lc_z9.
        CONCATENATE  lc_url_z9 <lfs_item>-lifex INTO lv_url.
      WHEN lc_za.
        CONCATENATE  lc_url_za <lfs_item>-lifex INTO lv_url.
      WHEN lc_zb.
        CONCATENATE  lc_url_zb <lfs_item>-lifex INTO lv_url.
      WHEN lc_zc.
        CONCATENATE  lc_url_zc <lfs_item>-lifex INTO lv_url.
      WHEN OTHERS.
    ENDCASE.
    CONDENSE lv_url.
    IF NOT fp_std_text-trackng_fr IS INITIAL.
*Tracking No
      CONCATENATE '<td  col width= "14%" '
      '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
      '<a href = 'lv_url' target ="_top">' <lfs_item>-lifex'</a>'
      '</FONT>'
      '</td>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
*    ELSEIF fp_std_text-nast_langu EQ lc_langu_es.
*Tracking No
*      CONCATENATE '<td  width= "25%" align="LEFT">'
*      '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
*      '<a href = 'lv_url' target ="_top">' <lfs_item>-lifex'</a>'
*      '</FONT>'
*      '</td>'  INTO lwa_objtxt-line.
*      APPEND lwa_objtxt TO li_objtxt.
*      CLEAR  lwa_objtxt.
    ELSE. " ELSE -> IF NOT fp_std_text-trackng_fr IS INITIAL
*Tracking No
      CONCATENATE '<td  col width= "14%" '
      '<FONT COLOR = "BLACK"><font face="Arial" size="2">'
      '<a href = 'lv_url' target ="_top">' <lfs_item>-lifex'</a>'
      '</FONT>'
      '</td>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
    ENDIF. " IF NOT fp_std_text-trackng_fr IS INITIAL
* <--- End of Change for Defect #4207_2 by Hrudra
    IF NOT fp_std_text-open_qty_fr IS INITIAL.
*Open Qty
      CONCATENATE '<td  width= "10%" align="RIGHT">'
      '<FONT COLOR = "BLACK"><font face="Arial" size="2">' lv_op_qty '</FONT>'
                       '</td></tr>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.
*    ELSEIF fp_std_text-nast_langu EQ lc_langu_es.
**Open Qty
*      CONCATENATE '<td  width= "11%" align="RIGHT">'
*      '<FONT COLOR = "BLACK"><font face="Arial" size="2">' lv_op_qty '</FONT>'
*                       '</td></tr>'  INTO lwa_objtxt-line.
*      APPEND lwa_objtxt TO li_objtxt.
*      CLEAR  lwa_objtxt.
    ELSE. " ELSE -> IF NOT fp_std_text-open_qty_fr IS INITIAL
*Open Qty
      CONCATENATE '<td  width= "10%" align="RIGHT">'
      '<FONT COLOR = "BLACK"><font face="Arial" size="2">' lv_op_qty '</FONT>'
                       '</td></tr>'  INTO lwa_objtxt-line.
      APPEND lwa_objtxt TO li_objtxt.
      CLEAR  lwa_objtxt.

    ENDIF. " IF NOT fp_std_text-open_qty_fr IS INITIAL

*End of Html Table
    lwa_objtxt-line = '</TABLE>'.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
*Draw a horizon tal Line
    lwa_objtxt-line = '<hr width="100%">'.
    APPEND lwa_objtxt TO li_objtxt.
    CLEAR  lwa_objtxt.
*clear local variables
    CLEAR :  lwa_objtxt,lv_menge,lv_lfimg ,lv_op_qty.
  ENDLOOP. " LOOP AT fp_line_item ASSIGNING <lfs_item>
  fp_li_objtxt[] = li_objtxt[].
ENDFORM. " F_BUILD_HTML_BODY
*&---------------------------------------------------------------------*
*&      Form  F_HTML_MAIL_SENT
*&---------------------------------------------------------------------*
*       To sent embed Mail to contact Person
*----------------------------------------------------------------------*
*       -->fp_li_objtxt
*       -->fp_doc_chng      Data of an object which can be changed
*       -->fp_contact_addr  Order General Address Information
*      -->fp_msgid          Message Class
*      -->fp_msgno          Message Number
*      -->fp_error          Message Type
*----------------------------------------------------------------------*
FORM f_html_mail_sent  USING fp_li_objtxt    TYPE  zotc_t_solisti1
                       value(fp_doc_chng)    TYPE  sodocchgi1             "Data of an object which can be changed
                             fp_contact_addr TYPE zotc_order_address_info "Order General Address Information.
                             fp_msgid TYPE sy-msgid                       " Message Class
                             fp_msgno TYPE sy-msgno                       " Message Number
                             fp_error TYPE sy-msgty                       " Message Type
                    CHANGING fp_retcode    TYPE sy-subrc ##needed.        "Return Value of ABAP Statements

*Diclarations to send the email is same for this also
  DATA: lv_msg_lines TYPE sy-tabix,            "Index of Internal Tables
        lv_msg3      TYPE sy-msgv1,            "Msg string for Mail Failure
        lx_objpack   TYPE sopcklsti1,          "To hold Imported Object Components
        li_reclist   TYPE TABLE OF somlreci1,  "To hold data for API Recipient List
        lwa_reclist  TYPE somlreci1,           "To hold data for API Recipient List
        li_objhead   TYPE TABLE OF solisti1,   "To hold data in single line format
        li_objpack   TYPE TABLE OF sopcklsti1. "To hold Imported Object Components
*Field symbols
  FIELD-SYMBOLS: <lfs_objtxt>  TYPE solisti1. "SAPscript: Text Lines
*Constants Declarations
  CONSTANTS:
    lc_doc_type_htm TYPE char3 VALUE 'HTM', "Code for document class
    lc_rec_type     TYPE char1 VALUE 'U',   "Recipient type
    lc_express      TYPE char1 VALUE 'X',   " Express of type CHAR1
    lc_255          TYPE int3 VALUE '255'.  " 255 of type Integers
*Document size calculation
  DESCRIBE TABLE fp_li_objtxt LINES lv_msg_lines.
  READ TABLE fp_li_objtxt ASSIGNING <lfs_objtxt> INDEX lv_msg_lines.
  IF sy-subrc = 0.
    fp_doc_chng-doc_size = ( lv_msg_lines - 1 ) * lc_255 + strlen( <lfs_objtxt> ).
  ENDIF. " IF sy-subrc = 0
*Creation of the entry for the compressed document
  lx_objpack-transf_bin = ' '.
  lx_objpack-head_start = 1.
  lx_objpack-head_num   = 0.
  lx_objpack-body_start = 1.
  lx_objpack-body_num   = lv_msg_lines.
  lx_objpack-doc_type   = lc_doc_type_htm.
*Append
  APPEND lx_objpack TO li_objpack.
*Clear
  CLEAR lx_objpack.
*Completing the recipient list
  lwa_reclist-receiver = fp_contact_addr-smtp_addr.
  lwa_reclist-rec_type = lc_rec_type.
  lwa_reclist-express  = lc_express.
*Append
  APPEND lwa_reclist TO li_reclist.
*Clear
  CLEAR lwa_reclist.
*Sent Embeded mail Body
  CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
    EXPORTING
      document_data              = fp_doc_chng
    TABLES
      packing_list               = li_objpack
      object_header              = li_objhead
      contents_txt               = fp_li_objtxt
      receivers                  = li_reclist
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.
  IF sy-subrc <> 0.

    lv_msg3 = 'Email can not be sent to email ID.'(168)  .
    PERFORM f_protocol_update USING fp_msgid
                                    fp_msgno
                                    fp_error
                                    lv_msg3.

    fp_retcode = 1.
  ENDIF. " IF sy-subrc <> 0
ENDFORM. " F_HTML_MAIL_SENT
*&---------------------------------------------------------------------*
*&      Form  F_PROTOCOL_UPDATE
*&---------------------------------------------------------------------*
*       Nast Protocol Update
*----------------------------------------------------------------------*
*      -->fp_msgid Message Class
*      -->fp_msgno Message Number
*      -->fp_error Message Type
*      -->fp_msg   Message Text
*----------------------------------------------------------------------*
FORM f_protocol_update  USING    fp_msgid TYPE sy-msgid  " Message Class
                                 fp_msgno TYPE sy-msgno  " Message Number
                                 fp_error TYPE sy-msgty  " Message Type
                                 fp_msg   TYPE sy-msgv1. " Message Variable
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = fp_msgid
      msg_nr    = fp_msgno
      msg_ty    = fp_error
      msg_v1    = fp_msg
    EXCEPTIONS
      OTHERS    = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF. " IF sy-subrc <> 0
ENDFORM. " F_PROTOCOL_UPDATE
