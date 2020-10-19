***********************************************************************
* Program     : LZOTC_PROFORMA_INV_FORMF01                            *
* Title       : Proforma Invoice Form                                 *
* Developer   : Avanti Sharma                                         *
* Object type : Adobe Form                                            *
* SAP Release : SAP ECC 6.0                                           *
*---------------------------------------------------------------------*
* WRICEF ID   : D3_OTC_FDD_0088                                       *
*---------------------------------------------------------------------*
* Description : Include program for subroutines                       *
*---------------------------------------------------------------------*
* MODIFICATION HISTORY:                                               *
*=====================================================================*
* Date           User        Transport       Description              *
*=========== ============== ============== ===========================*
*23-SEP-2016 ASHARMA8       E1DK921463     Initial development        *
*&--------------------------------------------------------------------*
*26-OCT-2016 ASHARMA8       E1DK921463     Defect_5595, Defect_5657,  *
*   Defect_5676, Defect_5741, Defect_5921                             *
* - Contact phone and email should be printed                         *
* - VAT% should appear in tax summary                                 *
* - Item number - remove leading zeros                                *
* - Address of Sales org should have 5 lines max                      *
* - Address of customers - bill to, sold to, ship to should have      *
*   6 lines max                                                       *
* - Freight, Handling, Insurance & Documentation charges should appear*
*   as 0 instead of blank                                             *
* - VAT Tax rate (field 107) should appear for BOM header material    *
*   and not for BOM components                                        *
* - Net amt, tax amt and total amt should be printed in decimal format*
*   of the country and should be printed as 0 instead of blank        *
*&--------------------------------------------------------------------*
*26-OCT-2016 ASHARMA8       E1DK921463     Defect_7129 (CR D3_301)    *
* - Print Handling and Document charges when it is not 0              *
* - Print Tax Legal Mention only if text exist, else no blank line    *
* - If sales org is 2001 or 2002, display bank name and address from  *
*   Standard text. Also print clearing account                        *
* - Donot print payment terms text if VBTYP = O or 6                  *
* - Update logic for payment terms text print LINE3                   *
* - Payment terms text - If installment payment print text            *
*   'Please refer to schedule of payment ' in LINE2                   *
*&--------------------------------------------------------------------*
*26-OCT-2016 ASHARMA8       E1DK921463     CR D3_301_Part2            *
* - Payment terms - print HDATUM in format DD-MMM-YYYY                *
* - Bio-rad customer service phone/email - remove additional logic for*
*   printing when sales org is 1024/2000                              *
*&--------------------------------------------------------------------*
* 20-Feb-2017 MGARG         E1DK921463    CR#356 : Layout changes for *
*                                         bank details.               *
*                                         - Change Bank address logic *
*                                         - Add spaces in IBAN value  *
*                                         - Change Translation for    *
*                                           'Clearing' Field          *
*&--------------------------------------------------------------------*
* 23-Feb-2017 MGARG         E1DK921463    CR#356 : Layout changes for *
*                                         bank details.               *
*                                         - Change Bank address logic *
*---------------------------------------------------------------------*
*20-APRIL-2017 U034087      E1DK927324  Defect 2622: The language,EN  *
*                                       ES,DE and FR are maintained in*
*                                       EMI table.If the form output  *
*                                       language( NAST-SPRAS)         *
*                                       is not maintained in EMI table*
*                                       then language is defaulted to *
*                                       English and the appearance    *
*                                       of entire form is in English  *
*
*                                       Payment Terms:Fetch from tvzbt*
*                                       Table and replace the Payment *
*                                       Term TOP text in English      *
*                                       language                      *
*                                       For Payment Term ZTERM_TXT1   *
*                                       ZTERM_TXT2 and ZTERM_TXT3 :   *
*                                       FM is used                    *
*&--------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*09-OCT-2017 SMUKHER4      E1DK931130    D3_D3_R2 as follows:    *
* 1.Insurance: Omit printing of the label & field when pricing cond.  *
* ZINS is inactive.                                                   *
* 2. Document: Add the value for cond.ZDOC to the field Handling      *
* when pricing condition is active KINAK.                             *
* 3. Adding new field GLN in the layout.                              *
* 4. SWISS VAT Label-Logic implemented in OTC_FDD_0014.We are just    *
* the standard text.                                                  *
* 5.Environment Fee-new field is added in the layout.Pricing Cond.ZINV*
*Suppressing the field and printing when value is initial.            *
*&--------------------------------------------------------------------*
* 06-Feb-2018 MGARG     E1DK931130   D3_R3 changes:                   *
*                                  -> Adding new fields and logic to  *
*                                     populate values. Contact name
*                                     CUU/AR for Italy,S/Y certifica-
*                                     tion, WEEE and 3days invoicing
*                                     text for Portugal.
*                                  -> Suppress fields when having zero*
*                                     value.
*                                  -> Item text formatting            *
*                                  -> GLN logic change for partnes    *
*                                  -> Language(P and I), CUU/AR VKORG *
*                                      are maintained in EMI.
*                                  -> Translation are maintained in PT,*
*                                     IT langauges and some changes are*
*                                     done in ES language.
*&---------------------------------------------------------------------*
*17-Aug-2018 U101734      E1DK938306 defect 6832: Concate check digit  *
*&---------------------------------------------------------------------*
*17-Aug-2018 U101734      E1DK938306 defect 6782: exclude UTXJ line    *
*                                    from Vat Summary table            *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE LZOTC_PROFORMA_INV_FORMF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_fill_control_data
*&---------------------------------------------------------------------*
*    Fill form control data in Header
*----------------------------------------------------------------------*
*      -->FP_NAST    NAST
*      -->FP_VBDKR   Document Header View for Billing
*      -->FP_ENH_STATUS Enhancement status
*      <--FP_HEADER  Proforma invoice form header structure
*----------------------------------------------------------------------*
FORM f_fill_control_data USING    fp_nast   TYPE nast                  " Message Status
                                  fp_vbdkr  TYPE vbdkr                 " Document Header View for Billing
                                  fp_enh_status TYPE zdev_tt_enh_status
                         CHANGING fp_header TYPE zotc_proforma_header. " Proforma invoice form header structure

  DATA: lv_vstat TYPE na_vstat, " Processing status of message
        lv_name  TYPE tdobname. " Name

  CONSTANTS: lc_success     TYPE na_vstat    VALUE '1',            " Processing status of message
             lc_logo_image  TYPE tdobname    VALUE 'ZBIORAD_LOGO', "Logo: Obj name
             lc_draft_image TYPE tdobname    VALUE 'ZDRAFT',       "Watermark: Obj name
             lc_system_id   TYPE z_criteria  VALUE 'SYSTEM_ID'.    " Enh. Criteria
* ---> Begin of Delete for D3_OTC_FDD_00088_CR#356 by MGARG
*             lc_logo_cs     TYPE char21      VALUE 'ZOTC_0014_D3_LOGO_CS_'. " Logo_cs of type CHAR21
* ---> End of Delete for D3_OTC_FDD_00088_CR#356 by MGARG

* Form Language

**Begin of Change by u034087 for Defect#2622 on 20-April-2017

  CONSTANTS :     lc_langu             TYPE z_criteria          VALUE 'LANGUAGE', "Criteria
                  lc_en                TYPE langu               VALUE 'E',        "Language Key
                  lc_i                 TYPE tvarv_sign          VALUE 'I',        "ABAP: ID: I/E (include/exclude values)
                  lc_eq                TYPE tvarv_opti          VALUE 'EQ'.       "ABAP: Selection option (EQ/BT/CP/...)

  FIELD-SYMBOLS : <lfs_constants>      TYPE zdev_enh_status. "Enhancement Status

  DATA : lv_langu      TYPE langu               VALUE IS INITIAL. "Language Key

  DATA : li_langu      TYPE icl_langu_range_t   VALUE IS INITIAL, "Language
         li_enh_status TYPE zdev_tt_enh_status  VALUE IS INITIAL. "Enhancement Table

  DATA : lwa_lang      TYPE icl_langu_range_s   VALUE IS INITIAL. " Range for LANGU


  IF fp_enh_status[] IS NOT INITIAL.

    li_enh_status[] = fp_enh_status[].

    DELETE  li_enh_status WHERE criteria NE lc_langu.
    DELETE  li_enh_status WHERE active   IS INITIAL.

    LOOP AT  li_enh_status ASSIGNING <lfs_constants>.
*&-->Begin of delete for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
*&--Since we have to make some translations changes, we have to change this peice of code.
*      lwa_lang-low    = <lfs_constants>-sel_high.
*&<--End of delete for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
*&-->Begin of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
      lwa_lang-low    = <lfs_constants>-sel_low.
*&<--End of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
      lwa_lang-sign   = lc_i.
      lwa_lang-option = lc_eq.
      APPEND lwa_lang TO li_langu.
      CLEAR: lwa_lang.
    ENDLOOP. " LOOP AT li_enh_status ASSIGNING <lfs_constants>

  ENDIF. " IF fp_enh_status[] IS NOT INITIAL

  FREE li_enh_status.

  IF fp_nast-spras NOT IN li_langu.

    fp_header-langu = lc_en.

  ELSE. " ELSE -> IF fp_nast-spras NOT IN li_langu

**End of Change by u034087 for Defect#2622 on 20-April-2017

    fp_header-langu = fp_nast-spras.

  ENDIF. " IF fp_nast-spras NOT IN li_langu

************************************************************************
****** Check if duplicate printing
************************************************************************
* Set the duplicate flag in case similar NAST message processed earlier
  SELECT vstat " Processing status of message
    INTO lv_vstat
    FROM nast  " Message Status
    UP TO 1 ROWS
    WHERE kappl = fp_nast-kappl
      AND objky = fp_nast-objky
      AND kschl = fp_nast-kschl
      AND spras = fp_nast-spras
      AND parnr = fp_nast-parnr
      AND parvw = fp_nast-parvw
      AND nacha = fp_nast-nacha
      AND vstat = lc_success.
  ENDSELECT.
  IF sy-subrc = 0
    AND lv_vstat IS NOT INITIAL.
    fp_header-duplicate = abap_true.
  ENDIF. " IF sy-subrc = 0

************************************************************************
******** Get images
************************************************************************
* Get Bio-Radlogo
  PERFORM f_get_form_image USING lc_logo_image
                           CHANGING fp_header-logo.

* Get image for draft
* check production system
  READ TABLE fp_enh_status   TRANSPORTING NO FIELDS
                             WITH KEY criteria = lc_system_id
                                      sel_low  = sy-sysid
                             BINARY SEARCH.
  IF sy-subrc IS NOT INITIAL.
    PERFORM f_get_form_image USING lc_draft_image
                             CHANGING fp_header-draft.
  ENDIF. " IF sy-subrc IS NOT INITIAL

* Get image for customer service phone
* form image name using sales org

* ---> Begin of Delete for D3_OTC_FDD_00088_CR#356 by MGARG
**** In form, Logo at field 72 is not needed.
*    CONCATENATE lc_logo_cs
*                fp_vbdkr-vkorg
*           INTO lv_name.
*    PERFORM f_get_form_image USING lv_name
*                             CHANGING fp_header-cs_logo.

* ---> End of Delete for D3_OTC_FDD_00088_CR#356 by MGARG

* --->Begin of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018
*** Get System certification Details
  SELECT prod_version " Signature PT: Certified Product Version
         cert_id      " Signature PT: Certification ID
    FROM sipt_cert    " Signature PT: Certification Data
    UP TO 1 ROWS
    INTO (fp_header-cversion,
          fp_header-cid)
   WHERE cert_todate >= sy-datum.
  ENDSELECT.

  IF sy-subrc IS NOT INITIAL.
    CLEAR: fp_header-cversion,
           fp_header-cid.
  ENDIF. " IF sy-subrc IS NOT INITIAL
* <---End of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018

ENDFORM. "f_fill_control_data
*&---------------------------------------------------------------------*
*&      Form  f_get_inv_header_data
*&---------------------------------------------------------------------*
*       Fill Invoice header data
*----------------------------------------------------------------------*
*      -->FP_VBDKR   Document Header View for Billing
*      -->FP_TVKO    Organizational Unit: Sales Organizations
*      -->FP_VBDPR   Document Item data for Billing
*      <--FP_HEADER  Proforma invoice form header structure
*----------------------------------------------------------------------*
FORM f_fill_form_head_data USING    fp_vbdkr  TYPE vbdkr                 " Document Header View for Billing
                                    fp_tvko   TYPE tvko                  " Organizational Unit: Sales Organizations
                                    fp_vbdpr  TYPE tbl_vbdpr
                           CHANGING fp_header TYPE zotc_proforma_header. " Proforma invoice form header structure

  DATA: lwa_vbdpr     TYPE vbdpr. " Document Item View for Billing
* Begin of Delete for Defect_5676 by ASHARMA8
*        lv_total_amt  TYPE netwr. " Net Value in Document Currency
* End of Delete for Defect_5676 by ASHARMA8

  CONSTANTS: lc_posnr TYPE posnr VALUE '000000'. " Item number of the SD document

  fp_header-vbeln         = fp_vbdkr-vbeln.
  fp_header-fkdat         = fp_vbdkr-fkdat.
  fp_header-vkorg         = fp_vbdkr-vkorg.
  fp_header-vtweg         = fp_vbdkr-vtweg.
  fp_header-stceg         = fp_vbdkr-stceg.
  fp_header-netwr         = fp_vbdkr-netwr.
  fp_header-mwsbk         = fp_vbdkr-mwsbk.
  fp_header-waerk         = fp_vbdkr-waerk.
  fp_header-inco1         = fp_vbdkr-inco1.
  fp_header-inco2         = fp_vbdkr-inco2.
  fp_header-bukrs         = fp_vbdkr-bukrs.
  fp_header-fkart         = fp_vbdkr-fkart.
  fp_header-salesorg_addr = fp_tvko-adrnr.

* Begin of Insert for Defect_7129 (CR D3_301) by ASHARMA8
  fp_header-vbtyp         = fp_vbdkr-vbtyp.
* End of Insert for Defect_7129 (CR D3_301) by ASHARMA8

* Begin of Delete for Defect_5676 by ASHARMA8
** Net amount
*  IF fp_header-netwr IS NOT INITIAL.
*    WRITE fp_header-netwr TO fp_header-netwr_char CURRENCY fp_header-waerk.
*  ENDIF. " IF fp_header-netwr IS NOT INITIAL
*
** Tax amount
*  IF fp_header-mwsbk IS NOT INITIAL.
*    WRITE fp_header-mwsbk TO fp_header-mwsbk_char CURRENCY fp_header-waerk.
*  ENDIF. " IF fp_header-mwsbk IS NOT INITIAL
*
** Total amount
*  lv_total_amt = fp_header-netwr + fp_header-mwsbk.
*  IF lv_total_amt IS NOT INITIAL.
*    WRITE lv_total_amt    TO fp_header-total_amt  CURRENCY fp_header-waerk.
*  ENDIF. " IF lv_total_amt IS NOT INITIAL
* End of Delete for Defect_5676 by ASHARMA8

* Get invoice first line item
  READ TABLE fp_vbdpr INTO lwa_vbdpr INDEX 1.
  IF sy-subrc = 0.

    fp_header-vgbel = lwa_vbdpr-vgbel.
    fp_header-vkbur = lwa_vbdpr-vkbur.

* Get customer purchase order number
    IF fp_header-vgbel IS NOT INITIAL.
      SELECT SINGLE bstkd " Customer purchase order number
        FROM vbkd         " Sales Document: Business Data
        INTO fp_header-bstkd
        WHERE vbeln = fp_header-vgbel
          AND posnr = lc_posnr.
      IF sy-subrc NE 0.
        CLEAR fp_header-bstkd.
      ENDIF. " IF sy-subrc NE 0
    ENDIF. " IF fp_header-vgbel IS NOT INITIAL

  ENDIF. " IF sy-subrc = 0

** Comvert date
  PERFORM f_convert_date_format USING    fp_header-fkdat
                                         fp_header-langu
                                CHANGING fp_header-fkdat_char.

ENDFORM. "f_get_inv_header_data
*&---------------------------------------------------------------------*
*&      Form  f_get_partner_data
*&---------------------------------------------------------------------*
*      Get partner data
*----------------------------------------------------------------------*
*      -->FP_VBELN   Billing Document
*      <--FP_HEADER  Proforma invoice form header structure
*----------------------------------------------------------------------*
FORM f_get_partner_data USING    fp_vbeln TYPE vbeln_vf                " Billing Document
                        CHANGING fp_header  TYPE zotc_proforma_header. " Proforma invoice form header structure

  DATA: li_vbpa  TYPE STANDARD TABLE OF ty_vbpa,
*&-->Begin of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
        li_vbpa_temp  TYPE STANDARD TABLE OF ty_vbpa,
        li_kna1       TYPE STANDARD TABLE OF ty_kna1, "Local Table for KNA1
        lwa_kna1      TYPE ty_kna1,                   "Local Work Area for KNA1
        lv_bbbnr      TYPE bbbnr,                     " International location number  (part 1)
        lv_bbsnr      TYPE bbsnr,                     " International location number (Part 2)
*&-->Begin of Insert for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6832
        lv_bubkz      TYPE bubkz, " Check digit for the international location number
*&-->End of Insert for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6832
*&<--End of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKH ER4 on 09-Oct-2017
* --->Begin of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018
        lv_contact_add  TYPE adrnr. " Address
* <---End of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018

  FIELD-SYMBOLS: <lfs_vbpa> TYPE ty_vbpa.


  CONSTANTS: lc_posnr   TYPE posnr VALUE '000000', " Item number of the SD document
             lc_billto  TYPE parvw VALUE 'RE',     " Partner Function
             lc_soldto  TYPE parvw VALUE 'AG',     " Partner Function
             lc_shipto  TYPE parvw VALUE 'WE',     " Partner Function
             lc_payer   TYPE parvw VALUE 'RG',     " Partner Function
* --->Begin of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018
             lc_contact1 TYPE parvw VALUE 'AP', " Partner Function
             lc_contact2 TYPE parvw VALUE 'ZA', " Partner Function
* <---End of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018
*&-->Begin of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
             lc_zero    TYPE char1 VALUE '0'. " Zero of type CHAR1
*&<--End of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017


  SELECT  vbeln " Sales and Distribution Document Number
          posnr " Item number of the SD document
          parvw " Partner Function
          kunnr " Customer Number
          adrnr " Address
          land1 " Country Key
    FROM vbpa   " Sales Document: Partner
    INTO TABLE li_vbpa
    WHERE vbeln = fp_vbeln
      AND posnr = lc_posnr
      AND parvw IN (lc_billto, lc_soldto, lc_shipto, lc_payer,
* --->Begin of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018
                  lc_contact1, lc_contact2
* <---End of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018
                    ).

  IF sy-subrc = 0.

*&-->Begin of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
*&--Fetching KNA1 to get GLN number.
    li_vbpa_temp[] = li_vbpa[].
    SORT li_vbpa_temp BY kunnr.
    DELETE ADJACENT DUPLICATES FROM  li_vbpa_temp COMPARING kunnr.
    IF li_vbpa_temp IS NOT INITIAL.

      SELECT kunnr " Customer Number
             bbbnr " International location number  (part 1)
             bbsnr " International location number (Part 2)
*&-->Begin of Insert for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6832
             bubkz
*&-->End of Insert for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6832
        FROM kna1 " General Data in Customer Master
        INTO TABLE li_kna1
        FOR ALL ENTRIES IN li_vbpa_temp
        WHERE kunnr = li_vbpa_temp-kunnr.
      IF sy-subrc IS INITIAL.
        SORT li_kna1 BY kunnr.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF li_vbpa_temp IS NOT INITIAL
*&<--End of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017

    LOOP AT li_vbpa ASSIGNING <lfs_vbpa>.
*&-->Begin of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
      CLEAR: lv_bbbnr,
             lv_bbsnr.
*&<--End of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017

      CASE <lfs_vbpa>-parvw.

        WHEN lc_billto.
          fp_header-billto      = <lfs_vbpa>-kunnr.
          fp_header-billto_addr = <lfs_vbpa>-adrnr.
          fp_header-billto_ctry = <lfs_vbpa>-land1.
*&-->Begin of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
*&--Populating GLN number for Bill-to party.
          READ TABLE li_kna1 INTO lwa_kna1 WITH KEY kunnr = <lfs_vbpa>-kunnr BINARY SEARCH.
          IF sy-subrc IS INITIAL.

            lv_bbbnr = lwa_kna1-bbbnr.
            lv_bbsnr = lwa_kna1-bbsnr.
*&-->Begin of Insert for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6832
            lv_bubkz = lwa_kna1-bubkz.
*&-->End of Insert for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6832
            IF lv_bbsnr IS NOT INITIAL.
*&--Concatenating both the fields to get the 12 digit GLN number.
              CONCATENATE lv_bbbnr
                          lv_bbsnr
*&-->Begin of Insert for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6832
                          lv_bubkz
*&-->End of Insert for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6832
               INTO fp_header-location_billto.
              SHIFT fp_header-location_billto LEFT DELETING LEADING lc_zero.
            ELSEIF lv_bbbnr IS NOT INITIAL.
              fp_header-location_billto = lv_bbbnr.
            ENDIF. " IF lv_bbsnr IS NOT INITIAL

          ENDIF. " IF sy-subrc IS INITIAL
*&<--End of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017

        WHEN lc_soldto.
          fp_header-soldto      = <lfs_vbpa>-kunnr.
          fp_header-soldto_addr = <lfs_vbpa>-adrnr.

* --->Begin of Delete for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018
** GLN no for Sold-to party is no more needed in D3_R3.So, commented below code
**&-->Begin of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
**&--Populating GLN number for Sold-to party.
*          READ TABLE li_kna1 INTO lwa_kna1 WITH KEY kunnr = <lfs_vbpa>-kunnr BINARY SEARCH.
*          IF sy-subrc IS INITIAL.
*            lv_bbbnr = lwa_kna1-bbbnr.
*            lv_bbsnr = lwa_kna1-bbsnr.
****&--Concatenating both the fields to get the 12 digit GLN number.
*            IF lv_bbsnr IS NOT INITIAL.
*
*              CONCATENATE lv_bbbnr
*                          lv_bbsnr
*               INTO fp_header-location_soldto.
*              SHIFT fp_header-location_soldto LEFT DELETING LEADING lc_zero.
*            ELSEIF lv_bbbnr IS NOT INITIAL.
*              fp_header-location_soldto = lv_bbbnr.
*            ENDIF. " IF lv_bbsnr IS NOT INITIAL
*
*          ENDIF. " IF sy-subrc IS INITIAL
**&<--End of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
* <---End of Delete for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018

        WHEN lc_shipto.
          fp_header-shipto      = <lfs_vbpa>-kunnr.
          fp_header-shipto_addr = <lfs_vbpa>-adrnr.
*&-->Begin of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
*&--Populating GLN number for Ship-to party.
          READ TABLE li_kna1 INTO lwa_kna1 WITH KEY kunnr = <lfs_vbpa>-kunnr BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            lv_bbbnr = lwa_kna1-bbbnr.
            lv_bbsnr = lwa_kna1-bbsnr.
*&-->Begin of Insert for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6832
            lv_bubkz = lwa_kna1-bubkz.
*&-->End of Insert for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6832

            IF lv_bbsnr IS NOT INITIAL.
*&--Concatenating both the fields to get the 12 digit GLN number.
              CONCATENATE lv_bbbnr
                          lv_bbsnr
*&-->Begin of Insert for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6832
                          lv_bubkz
*&-->End of Insert for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6832
               INTO fp_header-location_shipto.
              SHIFT fp_header-location_shipto LEFT DELETING LEADING lc_zero.
            ELSEIF lv_bbbnr IS NOT INITIAL.
              fp_header-location_shipto = lv_bbbnr.
            ENDIF. " IF lv_bbsnr IS NOT INITIAL

          ENDIF. " IF sy-subrc IS INITIAL
*&<--End of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017

        WHEN lc_payer.
          fp_header-payer       = <lfs_vbpa>-kunnr.

* --->Begin of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018
** Get adrnr no for AP partner
        WHEN lc_contact1.
          lv_contact_add = <lfs_vbpa>-adrnr.

        WHEN lc_contact2.
** only store adrnr no for ZA partner,when AP does not have
          IF lv_contact_add IS INITIAL.
            lv_contact_add = <lfs_vbpa>-adrnr.
          ENDIF. " IF lv_contact_add IS INITIAL
* <---End of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018
        WHEN OTHERS.

      ENDCASE.
*&-->Begin of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
*&--Clearing the Local work area
      CLEAR lwa_kna1.
*&<--End of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
    ENDLOOP. " LOOP AT li_vbpa ASSIGNING <lfs_vbpa>

* --->Begin of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018
**Ship-to GLN is printed only when different from Bill-to GLN
    IF fp_header-location_shipto = fp_header-location_billto.
      CLEAR fp_header-location_shipto.
    ENDIF. " IF fp_header-location_shipto = fp_header-location_billto
* <---End of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018

  ENDIF. " IF sy-subrc = 0

  FREE li_vbpa.
*&-->Begin of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
  FREE: li_kna1,
        li_vbpa_temp.
*&--Unassigning the field symbol used.
  IF <lfs_vbpa> IS ASSIGNED.
    UNASSIGN <lfs_vbpa>.
  ENDIF. " IF <lfs_vbpa> IS ASSIGNED
*&<--End of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017

* --->Begin of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018
** Get contact name
  IF lv_contact_add IS NOT INITIAL.
    SELECT name1 " Name 1
      FROM adrc  " Addresses (Business Address Services)
      UP TO 1 ROWS
      INTO fp_header-contact_name
      WHERE addrnumber = lv_contact_add.
    ENDSELECT.
    IF sy-subrc IS NOT INITIAL.
      CLEAR fp_header-contact_name.
    ENDIF. " IF sy-subrc IS NOT INITIAL

    CLEAR: lv_contact_add.
  ENDIF. " IF lv_contact_add IS NOT INITIAL
* <---End of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018

ENDFORM. "f_get_partner_data
*&---------------------------------------------------------------------*
*&      Form  f_get_customer_data
*&---------------------------------------------------------------------*
*       get customer data
*----------------------------------------------------------------------*
*      <--FP_HEADER  Proforma invoice form header structure
*----------------------------------------------------------------------*
FORM f_get_customer_data CHANGING fp_header TYPE zotc_proforma_header. " Proforma invoice form header structure

  DATA: lv_stcd1 TYPE stcd1, " Tax Number 1
        lv_stcd2 TYPE stcd2. " Tax Number 2


  CONSTANTS: lc_sep TYPE char1 VALUE '/'. " Sep of type CHAR1

* Get other tax numbers for sold to customer
  SELECT SINGLE
                stcd1 " Tax Number 1
                stcd2 " Tax Number 2
         FROM  kna1   " General Data in Customer Master
         INTO (lv_stcd1,
               lv_stcd2)
        WHERE kunnr = fp_header-kunag.

  IF sy-subrc = 0.

* If both tax numbers are present print them separated by '/'
* Else print the one which is present
    IF lv_stcd1 IS NOT INITIAL
      AND lv_stcd2 IS NOT INITIAL.

      CONCATENATE lv_stcd1
                  lc_sep
                  lv_stcd2
             INTO fp_header-tax_number
             SEPARATED BY space.

    ELSEIF lv_stcd1 IS NOT INITIAL.

      fp_header-tax_number = lv_stcd1.

    ELSEIF lv_stcd2 IS NOT INITIAL.

      fp_header-tax_number = lv_stcd2.

    ENDIF. " IF lv_stcd1 IS NOT INITIAL

  ENDIF. " IF sy-subrc = 0

ENDFORM. "f_get_customer_data
*&---------------------------------------------------------------------*
*&      Form  f_fill_form_item_data
*&---------------------------------------------------------------------*
*       Populate form item data
*----------------------------------------------------------------------*
*      -->FP_VBDKR   Document Header View for Billing
*      -->FP_VBDPR   Document Item data for Billing
*      -->FP_EIPO    Foreign Trade: Export/Import: Item Data
*      -->FP_SER02   Document Header for Serial Nos for Maint.Contract (SD Order)
*      -->FP_OBJK    Plant Maintenance Object List
*      -->FP_KNMT    Customer-Material Info Record Data Table
*      -->FP_VBRP    Billing item data
*      -->FP_KONV    Conditions (Transaction Data)
*      -->FP_LIPS    Delivery item data
*      <--FP_HEADER  Proforma invoice form header structure
*      <--FP_ITEM    Proforma invoice form item table
*----------------------------------------------------------------------*
FORM f_fill_form_item_data USING  fp_vbdkr  TYPE vbdkr                  " Document Header View for Billing
                                  fp_vbdpr  TYPE tbl_vbdpr
                                  fp_eipo   TYPE ty_t_eipo
                                  fp_ser02  TYPE ty_t_ser02
                                  fp_objk   TYPE ty_t_objk
                                  fp_knmt   TYPE ty_t_knmt
                                  fp_vbrp   TYPE ty_t_vbrp
                                  fp_konv   TYPE ty_t_konv
                                  fp_lips   TYPE ty_t_lips
                           CHANGING fp_header TYPE zotc_proforma_header " Proforma invoice form header structure
                                    fp_item TYPE zotc_t_proforma_item.

  DATA: li_vbdpr_hdr    TYPE tbl_vbdpr,
        li_vbdpr_bom    TYPE tbl_vbdpr,
        lwa_vbrp        TYPE ty_vbrp,
        lwa_eipo        TYPE ty_eipo,
        lwa_item        TYPE zotc_proforma_item, " Proforma invoice form item
        lwa_knmt        TYPE ty_knmt,
        lwa_konv        TYPE ty_konv,
        lwa_lips        TYPE ty_lips,
        lv_bom_flag     TYPE flag,               " General Flag
        lv_subtotal     TYPE kzwi1,              " Subtotal 1 from pricing procedure for condition
        lv_kbetr        TYPE kbetr,              " Rate (condition amount or percentage)
        lv_unit_price   TYPE kzwi1,              " Subtotal 1 from pricing procedure for condition

* Begin of Insert for Defect_5741 by ASHARMA8
        li_konv         TYPE ty_t_konv.
* End of Insert for Defect_5741 by ASHARMA8

  FIELD-SYMBOLS: <lfs_vbdpr>       TYPE vbdpr. " Document Item View for Billing

  CONSTANTS: lc_percent TYPE koein  VALUE '%', " Calculation type for condition
             lc_tax     TYPE koaid  VALUE 'D', " Condition class
*&-->Begin of Insert for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6782
             lc_cat     TYPE kntyp  VALUE '1', " Condition category (examples: tax, freight, price, cost)
*&-->End of Insert for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6782
             lc_billing_rule TYPE fareg VALUE '6'. " Rule in billing plan/invoice plan

  li_vbdpr_hdr[] = fp_vbdpr[].
  li_vbdpr_bom[] = fp_vbdpr[].
  DELETE li_vbdpr_hdr WHERE uepos IS NOT INITIAL.
  DELETE li_vbdpr_bom WHERE uepos IS INITIAL.

  LOOP AT li_vbdpr_hdr ASSIGNING <lfs_vbdpr>.

* Set the BOM flag if the header has BOM components
    CLEAR lv_bom_flag.
    READ TABLE li_vbdpr_bom TRANSPORTING NO FIELDS
                            WITH KEY uepos = <lfs_vbdpr>-posnr.
    IF sy-subrc = 0.
      lv_bom_flag = abap_true.
    ENDIF. " IF sy-subrc = 0

    lwa_item-posnr = <lfs_vbdpr>-posnr.
    lwa_item-matnr = <lfs_vbdpr>-matnr.
    lwa_item-fkimg = <lfs_vbdpr>-fkimg.
    lwa_item-arktx = <lfs_vbdpr>-arktx.
    lwa_item-kzwi1 = <lfs_vbdpr>-kzwi1.
    lwa_item-vgbel = <lfs_vbdpr>-vgbel.
    lwa_item-vgpos = <lfs_vbdpr>-vgpos.

    CONCATENATE fp_vbdkr-vbeln
                <lfs_vbdpr>-posnr
           INTO lwa_item-tdname.

* Begin of Insert for Defect_5595 by ASHARMA8
* Item number
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = lwa_item-posnr
      IMPORTING
        output = lwa_item-posnr_output.
* End of Insert for Defect_5595 by ASHARMA8

* Unit price
    IF <lfs_vbdpr>-fkimg IS NOT INITIAL.
      lv_unit_price = ( <lfs_vbdpr>-kzwi1 / <lfs_vbdpr>-fkimg ).
      WRITE: lv_unit_price    TO lwa_item-unit_price_char CURRENCY fp_vbdkr-waerk,
             <lfs_vbdpr>-fkimg  TO lwa_item-fkimg_char      UNIT     <lfs_vbdpr>-vrkme.
      CONDENSE: lwa_item-fkimg_char.
    ENDIF. " IF <lfs_vbdpr>-fkimg IS NOT INITIAL

* Quantity UoM
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input          = <lfs_vbdpr>-vrkme
        language       = fp_header-langu
      IMPORTING
        output         = lwa_item-vrkme
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      lwa_item-vrkme = <lfs_vbdpr>-vrkme.
    ENDIF. " IF sy-subrc <> 0


* Amount
    WRITE <lfs_vbdpr>-kzwi1 TO lwa_item-amt_char CURRENCY fp_vbdkr-waerk.

*&-->Begin of Delete for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6782
** Rate
*    READ TABLE fp_konv INTO lwa_konv
*                       WITH KEY kposn = <lfs_vbdpr>-posnr
** Begin of Insert for Defect_5741 by ASHARMA8
*                                kinak = abap_false
** End of Insert for Defect_5741 by ASHARMA8
*                                koaid = lc_tax.
*&-->End of Delete for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6782
*&-->Begin of Insert for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6782
* Rate
    CLEAR lv_kbetr.
    LOOP AT fp_konv INTO lwa_konv WHERE kposn = <lfs_vbdpr>-posnr AND
                                kinak = abap_false AND
                                koaid = lc_tax AND
                                kstat = abap_false AND kwert IS NOT INITIAL.
      lv_kbetr  = lv_kbetr + lwa_konv-kbetr.
    ENDLOOP. " LOOP AT fp_konv INTO lwa_konv WHERE kposn = <lfs_vbdpr>-posnr AND
    lwa_konv-kbetr = lv_kbetr.
    CLEAR lv_kbetr.
*&-->End of Insert for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6782

*&-->Begin of Delete for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6782
*    IF sy-subrc = 0.
*&-->End of Delete for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6782
    lv_kbetr = lwa_konv-kbetr / 10.
    WRITE lv_kbetr TO lwa_item-kbetr_char CURRENCY lc_percent.
    CONCATENATE lwa_item-kbetr_char
                lc_percent
           INTO lwa_item-kbetr_char.
*&-->Begin of Delete for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6782
*    ENDIF. " IF sy-subrc = 0
*&-->End of Delete for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6782

* Begin of Insert for Defect_5741 by ASHARMA8
    IF lv_bom_flag = abap_true.
      CLEAR lwa_item-kbetr_char.
      li_konv[] = fp_konv[].
      DELETE li_konv WHERE kinak = abap_false.
      READ TABLE li_konv INTO lwa_konv
                       WITH KEY kposn = <lfs_vbdpr>-posnr
                                koaid = lc_tax.
      IF sy-subrc = 0.
        lv_kbetr = lwa_konv-kbetr / 10.
        WRITE lv_kbetr TO lwa_item-kbetr_char CURRENCY lc_percent.
        CONCATENATE lwa_item-kbetr_char
                    lc_percent
               INTO lwa_item-kbetr_char.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF lv_bom_flag = abap_true
* End of Insert for Defect_5741 by ASHARMA8

* customer material number
    READ TABLE fp_knmt INTO lwa_knmt
                       WITH KEY matnr = lwa_item-matnr
                       BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_item-kdmat = lwa_knmt-kdmat.
    ENDIF. " IF sy-subrc = 0

*
    READ TABLE fp_vbrp INTO lwa_vbrp
                       WITH KEY vbeln = fp_vbdkr-vbeln
                                posnr = <lfs_vbdpr>-posnr
                       BINARY SEARCH.
    IF sy-subrc = 0
      AND <lfs_vbdpr>-fareg = lc_billing_rule.
      lwa_item-abrbg = lwa_vbrp-abrbg.
      lwa_item-fbuda = lwa_vbrp-fbuda.
      PERFORM f_convert_date_format USING    lwa_item-abrbg
                                             fp_header-langu
                                    CHANGING lwa_item-abrbg_char.

      PERFORM f_convert_date_format USING    lwa_item-fbuda
                                             fp_header-langu
                                    CHANGING lwa_item-fbuda_char.

    ENDIF. " IF sy-subrc = 0

*
    READ TABLE fp_eipo INTO lwa_eipo
                       WITH KEY exnum = fp_vbdkr-exnum
                                expos = <lfs_vbdpr>-posnr
                       BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_item-herkl = lwa_eipo-herkl.
      lwa_item-stawn = lwa_eipo-stawn.
    ENDIF. " IF sy-subrc = 0

*********************************************************************
* Populate batch and serial number only if header doesnot have components
*********************************************************************
    IF lv_bom_flag = abap_false.

* Subtotal
      lv_subtotal = lv_subtotal + <lfs_vbdpr>-kzwi1.

* Batch
      IF <lfs_vbdpr>-xchar = abap_true.
        lwa_item-charg = <lfs_vbdpr>-charg.
        READ TABLE fp_lips INTO lwa_lips
                           WITH KEY vbeln = <lfs_vbdpr>-vgbel
                                    posnr = <lfs_vbdpr>-vgpos
                           BINARY SEARCH.
        IF sy-subrc = 0
          AND lwa_lips-vfdat IS NOT INITIAL.
          PERFORM f_convert_date_format USING lwa_lips-vfdat
                                              fp_header-langu
                                        CHANGING lwa_item-vfdat_char.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF <lfs_vbdpr>-xchar = abap_true

* serial numbers
      PERFORM f_get_serial_numbers USING <lfs_vbdpr>-vgbel
                                         <lfs_vbdpr>-vgpos
                                         fp_ser02
                                         fp_objk
                                   CHANGING lwa_item-serialno.
    ENDIF. " IF lv_bom_flag = abap_false

*********************************************************************
* If BOM scenario - populate all components details in a separate table
*********************************************************************
    IF lv_bom_flag = abap_true.

* this subroutine has loop for forming BOM components,
* loop inside loop is used, so save BOM components table inside
* respective invoice item
      PERFORM f_fill_bom_components USING fp_header-langu
                                          <lfs_vbdpr>
                                          fp_vbdpr
                                          fp_ser02
                                          fp_objk
* Begin of Delete for Defect_5741 by ASHARMA8
*                                          fp_konv
* End of Delete for Defect_5741 by ASHARMA8
                                          fp_lips
                                    CHANGING lv_subtotal
                                             lwa_item-bom.

    ENDIF. " IF lv_bom_flag = abap_true


*********************************************************************
* Append
*********************************************************************
    APPEND lwa_item TO fp_item.
    CLEAR lwa_item.

  ENDLOOP. " LOOP AT li_vbdpr_hdr ASSIGNING <lfs_vbdpr>

* Subtotal amount
  IF lv_subtotal IS NOT INITIAL.
    WRITE lv_subtotal TO fp_header-subtotal CURRENCY fp_vbdkr-waerk.
  ENDIF. " IF lv_subtotal IS NOT INITIAL

ENDFORM. "f_get_item_data
*&---------------------------------------------------------------------*
*&      Form  f_fetch_inv_item_rel_data
*&---------------------------------------------------------------------*
*       Fetch invoice item related data
*----------------------------------------------------------------------*
*      -->FP_VBDKR   Document Header View for Billing
*      -->FP_VBDPR   Document Item data for Billing
*      <--FP_SER02   Document Header for Serial Nos for Maint.Contract (SD Order)
*      <--FP_OBJK    Plant Maintenance Object List
*      <--FP_KNMT    Customer-Material Info Record Data Table
*      <--FP_VBFA    Sales Document Flow
*      <--FP_LIPS    Delivery item data
*----------------------------------------------------------------------*
FORM f_fetch_inv_item_rel_data USING fp_vbdkr TYPE vbdkr " Document Header View for Billing
                                     fp_vbdpr TYPE tbl_vbdpr
                            CHANGING fp_ser02 TYPE ty_t_ser02
                                     fp_objk  TYPE ty_t_objk
                                     fp_knmt  TYPE ty_t_knmt
                                     fp_vbfa  TYPE ty_t_vbfa
                                     fp_lips  TYPE ty_t_lips.

  DATA: li_vbdpr TYPE tbl_vbdpr.

  CONSTANTS: lc_credit_memo      TYPE vbtyp_n VALUE 'O', " Document category of subsequent document
             lc_debit_memo       TYPE vbtyp_n VALUE 'P', " Document category of subsequent document
             lc_category_invoice TYPE vbtyp_n VALUE 'M'. " Document category of subsequent document

************************************************************************
******* Get item serial numbers
************************************************************************

  li_vbdpr[] = fp_vbdpr[].
  SORT li_vbdpr BY vgbel vgpos.
  DELETE ADJACENT DUPLICATES FROM li_vbdpr COMPARING vgbel vgpos.

  IF li_vbdpr[] IS NOT INITIAL.
    SELECT obknr   " Object list number
           sdaufnr " Sales Document
           posnr   " Sales Document Item
      FROM ser02   " Document Header for Serial Nos for Maint.Contract (SD Order)
      INTO TABLE fp_ser02
      FOR ALL ENTRIES IN li_vbdpr
      WHERE sdaufnr = li_vbdpr-vgbel
        AND posnr   = li_vbdpr-vgpos.
    IF sy-subrc NE 0.
      CLEAR fp_ser02.
    ENDIF. " IF sy-subrc NE 0

    IF fp_ser02[] IS NOT INITIAL.

      SORT fp_ser02 BY obknr.

      SELECT obknr " Object list number
             obzae " Object list counters
             sernr " Serial Number
        FROM objk  " Plant Maintenance Object List
        INTO TABLE fp_objk
        FOR ALL ENTRIES IN fp_ser02
        WHERE obknr = fp_ser02-obknr.
      IF sy-subrc = 0.
        SORT fp_objk BY obknr.
      ENDIF. " IF sy-subrc = 0

      SORT fp_ser02 BY sdaufnr posnr.

    ENDIF. " IF fp_ser02[] IS NOT INITIAL

    SELECT vbeln " Delivery
           posnr " Delivery Item
           vfdat " Shelf Life Expiration or Best-Before Date
      FROM lips  " SD document: Delivery: Item data
      INTO TABLE fp_lips
      FOR ALL ENTRIES IN li_vbdpr
      WHERE vbeln = li_vbdpr-vgbel
        AND posnr = li_vbdpr-vgpos.
    IF sy-subrc = 0.
      SORT fp_lips BY vbeln posnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_vbdpr[] IS NOT INITIAL

************************************************************************
***** customer material data
************************************************************************
  li_vbdpr[] = fp_vbdpr[].
  SORT li_vbdpr BY matnr.
  DELETE ADJACENT DUPLICATES FROM li_vbdpr COMPARING matnr.

  IF li_vbdpr[] IS NOT INITIAL.
    SELECT  vkorg " Sales Organization
            vtweg " Distribution Channel
            kunnr " Customer number
            matnr " Material Number
            kdmat " Material Number Used by Customer
      FROM knmt   " Customer-Material Info Record Data Table
      INTO TABLE fp_knmt
      FOR ALL ENTRIES IN li_vbdpr
      WHERE vkorg = fp_vbdkr-vkorg
        AND vtweg = fp_vbdkr-vtweg
        AND kunnr = fp_vbdkr-kunag
        AND matnr = li_vbdpr-matnr.
    IF sy-subrc = 0.
      SORT fp_knmt BY matnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_vbdpr[] IS NOT INITIAL

************************************************************************
***** Get original invoice
************************************************************************

  li_vbdpr[] = fp_vbdpr[].
  SORT li_vbdpr BY vbeln_vauf posnr_vauf.
  DELETE ADJACENT DUPLICATES FROM li_vbdpr COMPARING vbeln_vauf posnr_vauf.

  IF li_vbdpr[] IS NOT INITIAL.
    SELECT  vbelv   " Preceding sales and distribution document
            posnv   " Preceding item of an SD document
            vbeln   " Subsequent sales and distribution document
            posnn   " Subsequent item of an SD document
            vbtyp_n " Document category of subsequent document
      FROM vbfa     " Sales Document Flow
      INTO TABLE fp_vbfa
      FOR ALL ENTRIES IN li_vbdpr
      WHERE vbelv   = li_vbdpr-vbeln_vauf
        AND posnv   = li_vbdpr-posnr_vauf
        AND ( vbtyp_n = lc_credit_memo
         OR   vbtyp_n = lc_debit_memo )
        AND vbtyp_v = lc_category_invoice.
    IF sy-subrc = 0.
      SORT fp_vbfa BY vbelv posnv.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_vbdpr[] IS NOT INITIAL

ENDFORM. "f_get_unique_item_data
*&---------------------------------------------------------------------*
*&      Form  F_GET_SERIAL_NUMBERS
*&---------------------------------------------------------------------*
*       Get serial numbers
*----------------------------------------------------------------------*
*      -->FP_VGBEL   Document number of the reference document
*      -->FP_VGPOS   Item number of the reference item
*      -->FP_SER02   Document Header for Serial Nos for Maint.Contract (SD Order)
*      -->FP_OBJK    Plant Maintenance Object List
*      <--FP_SERIALNO  Serial number
*----------------------------------------------------------------------*
FORM f_get_serial_numbers  USING    fp_vgbel    TYPE vgbel " Document number of the reference document
                                    fp_vgpos    TYPE vgpos " Item number of the reference item
                                    fp_ser02    TYPE ty_t_ser02
                                    fp_objk     TYPE ty_t_objk
                           CHANGING fp_serialno TYPE zotc_t_sernr.

  DATA: lv_tabix      TYPE sytabix,      " Tabix of type Integers
        lwa_ser02     TYPE ty_ser02,
        lwa_serialno  TYPE zotc_s_sernr. " Serial numbers

  FIELD-SYMBOLS: <lfs_objk>      TYPE ty_objk.

  READ TABLE fp_ser02 INTO lwa_ser02
                      WITH KEY sdaufnr = fp_vgbel
                               posnr   = fp_vgpos
                      BINARY SEARCH.
  IF sy-subrc NE 0.
    RETURN.
  ENDIF. " IF sy-subrc NE 0

  READ TABLE fp_objk TRANSPORTING NO FIELDS
                     WITH KEY obknr = lwa_ser02-obknr
                     BINARY SEARCH.
  IF sy-subrc = 0.
    lv_tabix = sy-tabix.

    LOOP AT fp_objk ASSIGNING <lfs_objk> FROM lv_tabix.
      IF <lfs_objk>-obknr NE lwa_ser02-obknr.
        EXIT.
      ENDIF. " IF <lfs_objk>-obknr NE lwa_ser02-obknr

      lwa_serialno-sernr = <lfs_objk>-sernr.
      APPEND lwa_serialno TO fp_serialno.
      CLEAR lwa_serialno.
    ENDLOOP. " LOOP AT fp_objk ASSIGNING <lfs_objk> FROM lv_tabix

  ENDIF. " IF sy-subrc = 0


ENDFORM. " F_GET_SERIAL_NUMBERS
*&---------------------------------------------------------------------*
*&      Form  F_FETCH_INV_HEAD_REL_DATA
*&---------------------------------------------------------------------*
*       Fetch Invoice Header related data
*----------------------------------------------------------------------*
*      -->FP_VBDKR   Document Header View for Billing
*      <--FP_HEADER  Proforma invoice form header structure
*      <--FP_VBRP    Billing item data
*      <--FP_EIPO    Foreign Trade: Export/Import: Item Data
*      <--FP_KONV    Conditions (Transaction Data)
*----------------------------------------------------------------------*
FORM f_fetch_inv_head_rel_data  USING    fp_vbdkr   TYPE vbdkr                " Document Header View for Billing
                                CHANGING fp_header  TYPE zotc_proforma_header " Proforma invoice form header structure
                                         fp_vbrp    TYPE ty_t_vbrp
                                         fp_eipo    TYPE ty_t_eipo
                                         fp_konv    TYPE ty_t_konv.

****** VBRK data
  SELECT SINGLE
         zlsch " Payment Method
         kunag " Sold-to party
* Begin of Insert for Defect_7129 (CR D3_301) by ASHARMA8
         zzrland
* End of Insert for Defect_7129 (CR D3_301) by ASHARMA8
         zzvatnsf " VAT Registration Number
    FROM vbrk     " Billing Document: Header Data
    INTO (fp_header-zlsch,
          fp_header-kunag,
* Begin of Insert for Defect_7129 (CR D3_301) by ASHARMA8
          fp_header-zzrland,
* End of Insert for Defect_7129 (CR D3_301) by ASHARMA8
          fp_header-zzvatnsf)
    WHERE vbeln = fp_vbdkr-vbeln.
  IF sy-subrc NE 0.
    CLEAR: fp_header-zlsch,
        fp_header-kunag,
        fp_header-zzvatnsf.
  ENDIF. " IF sy-subrc NE 0



****** VBRP data
  SELECT vbeln " Billing Document
         posnr " Billing item
         fbuda " Date on which services rendered
         abrbg " Start of accounting settlement period
    FROM vbrp  " Billing Document: Item Data
    INTO TABLE fp_vbrp
    WHERE vbeln = fp_vbdkr-vbeln.
  IF sy-subrc = 0.
    SORT fp_vbrp BY vbeln posnr.
  ENDIF. " IF sy-subrc = 0



**** EIPO data
  IF fp_vbdkr-exnum IS NOT INITIAL.
    SELECT  exnum " Number of foreign trade data in MM and SD documents
            expos " Internal item number for foreign trade data in MM and SD
            stawn " Commodity Code/Import Code Number for Foreign Trade
            herkl " Country of origin of the material
      FROM eipo   " Foreign Trade: Export/Import: Item Data
      INTO TABLE fp_eipo
      WHERE exnum = fp_vbdkr-exnum.
    IF sy-subrc = 0.
      SORT fp_eipo BY exnum expos.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF fp_vbdkr-exnum IS NOT INITIAL


* Fetching condition data...
  SELECT knumv " Number of the document condition
         kposn " Condition item number
         kschl " Condition type
         kawrt " Condition base value
         kbetr " Rate (condition amount or percentage)
         mwsk1 " Tax on sales/purchases code
         kwert " Condition value
* Begin of Insert for Defect_5741 by ASHARMA8
         kinak
* End of Insert for Defect_5741 by ASHARMA8
         koaid " Condition class
*&-->Begin of Insert for  D3_OTC_FDD_0088 by U101734 on 14/08/2018 Defect #6782
         kntyp
         kstat
*&-->End of Insert for  D3_OTC_FDD_0088 by U101734 on 14/08/2018 Defect #6782
    FROM konv " Conditions (Transaction Data)
    INTO TABLE fp_konv
   WHERE knumv = fp_vbdkr-knumv.
* Begin of Delete for Defect_5741 by ASHARMA8
*     AND kinak = abap_false.
* End of Delete for Defect_5741 by ASHARMA8

  IF sy-subrc NE 0.
    RETURN.
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_FETCH_INV_HEAD_REL_DATA
*&---------------------------------------------------------------------*
*&      Form  F_FILL_CONDITIONS_DATA
*&---------------------------------------------------------------------*
*       Fill condition data related fields
*----------------------------------------------------------------------*
*      -->FP_DOC_CURRENCY   Document currency
*      -->FP_KONV           Conditions (Transaction Data)
*      <--FP_HEADER         Proforma invoice form header structure
*----------------------------------------------------------------------*
FORM f_fill_conditions_data  USING   fp_doc_currency TYPE waerk                 " SD Document Currency
                                     fp_konv         TYPE ty_t_konv
                            CHANGING fp_header       TYPE zotc_proforma_header. " Proforma invoice form header structure


  DATA: li_summary    TYPE STANDARD TABLE OF zotc_proforma_tax_summary, " Tax summary
        li_tax        TYPE STANDARD TABLE OF ty_tax,
        li_taxcode    TYPE STANDARD TABLE OF ty_taxcode,
        li_tax_legal  TYPE zotc_t_proforma_tax_legal,
        lwa_tax_legal TYPE zotc_proforma_tax_legal,                     " Structure for textname of Tax legal mention
        lwa_taxcode   TYPE ty_taxcode,
        lwa_tax       TYPE ty_tax,
        lwa_summary   TYPE zotc_proforma_tax_summary,                   " Tax summary
        lv_kbetr      TYPE kbetr,                                       " Rate (condition amount or percentage)
        lv_freight    TYPE kbetr,                                       " Rate (condition amount or percentage)
        lv_handling   TYPE kbetr,                                       " Rate (condition amount or percentage)
        lv_insurance  TYPE kbetr,                                       " Rate (condition amount or percentage)
        lv_document   TYPE kbetr,                                       " Rate (condition amount or percentage)
**&-->Begin of Insert for  D3_OTC_FDD_0088 by U101734 on 14/08/2018 Defect #6782
        li_tmp        TYPE TABLE OF ty_tax,                             " temprory tax table
        lv_prev_kbetr TYPE char22, " Prev_kbetr of type CHAR22          " Previous record
**&-->End of Insert for  D3_OTC_FDD_0088 by U101734 on 14/08/2018 Defect #6782
*&-->Begin of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
        lv_environment TYPE kbetr. " Rate (condition amount or percentage)
*&<--End of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017

  FIELD-SYMBOLS: <lfs_tax>      TYPE  ty_tax,
                 <lfs_konv>     TYPE  ty_konv,
**&-->Begin of Insert for  D3_OTC_FDD_0088 by U101734 on 14/08/2018 Defect #6782
                 <lfs_tmp>      TYPE  ty_tax,  " temprory work area  pointer for tax table
**&-->End of Insert for  D3_OTC_FDD_0088 by U101734 on 14/08/2018 Defect #6782
                 <lfs_taxcode>  TYPE  ty_taxcode.

  CONSTANTS: lc_ztfr    TYPE kscha  VALUE 'ZTFR', " Condition type
             lc_zhdl    TYPE kscha  VALUE 'ZHDL', " Condition type
             lc_zins    TYPE kscha  VALUE 'ZINS', " Condition type
             lc_zdoc    TYPE kscha  VALUE 'ZDOC', " Condition type
             lc_tax     TYPE koaid  VALUE 'D',    " Condition class
             lc_percent TYPE char1  VALUE '%',    " Percent of type CHAR1
             lc_sep     TYPE char1  VALUE '_',    " Sep of type CHAR1
*&-->Begin of Insert for  D3_OTC_FDD_0088 by U101734 on 14/08/2018 Defect #6782
             lc_cat     TYPE char1  VALUE '1', " Condition category
             lc_typ     TYPE char6  VALUE '123456', " Condition category
*&-->End of Insert for  D3_OTC_FDD_0088 by U101734 on 14/08/2018 Defect #6782
             lc_taxcode TYPE char25 VALUE 'ZOTC_0014_D3_TCODE', " Taxcode of type CHAR25

* Begin of Insert for Defect_7129 (CR D3_301) by ASHARMA8
             lc_text    TYPE tdobject VALUE 'TEXT', " Texts: Application Object
             lc_st      TYPE tdid     VALUE 'ST',   " Text ID
* End of Insert for Defect_7129 (CR D3_301) by ASHARMA8

*&-->Begin of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
             lc_zenv    TYPE kscha VALUE 'ZENV'. " Condition type
*&<--End of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017


*************************************************************************
**** Populate charges
*************************************************************************

  LOOP AT fp_konv ASSIGNING <lfs_konv>
* Begin of Insert for Defect_5741 by ASHARMA8
                  WHERE kinak = abap_false.
* End of Insert for Defect_5741 by ASHARMA8

    CASE <lfs_konv>-kschl.

* Freight Charge
      WHEN lc_ztfr.
        lv_freight = lv_freight + <lfs_konv>-kwert.


* Handling charges
      WHEN lc_zhdl.
        lv_handling = lv_handling  + <lfs_konv>-kwert.

* Insurance charges
      WHEN lc_zins.
        lv_insurance = lv_insurance + <lfs_konv>-kwert.

*&-->Begin of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
      WHEN lc_zenv.
        lv_environment = lv_environment + <lfs_konv>-kwert.
*&<--End of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017

* document charges
      WHEN lc_zdoc.
        lv_document = lv_document + <lfs_konv>-kwert.

      WHEN OTHERS.

    ENDCASE.

* Tax summary
    IF <lfs_konv>-koaid = lc_tax.
      lv_kbetr = <lfs_konv>-kbetr / 10.
      WRITE lv_kbetr TO lwa_tax-kbetr_char CURRENCY lc_percent.

**&-->Begin of Insert for  D3_OTC_FDD_0088 by U101734 on 14/08/2018 Defect #6782
      lwa_tax-kstat = <lfs_konv>-kstat.
      lwa_tax-kntyp = <lfs_konv>-kntyp.
**&-->End of Insert for  D3_OTC_FDD_0088 by U101734 on 14/08/2018 Defect #6782
      lwa_tax-kawrt = <lfs_konv>-kawrt.
      lwa_tax-kwert = <lfs_konv>-kwert.
      COLLECT lwa_tax INTO li_tax .

      lwa_taxcode-mwskz = <lfs_konv>-mwsk1.
      COLLECT lwa_taxcode INTO li_taxcode.
      CLEAR: lwa_tax,
             lwa_taxcode.
    ENDIF. " IF <lfs_konv>-koaid = lc_tax
  ENDLOOP. " LOOP AT fp_konv ASSIGNING <lfs_konv>

*&-->Begin of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
*  IF lv_document IS NOT INITIAL.
*    lv_handling = lv_handling + lv_document.
*  ENDIF. " IF lv_document IS NOT INITIAL
*&<--End of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017

* Begin of Delete for Defect_5676 by ASHARMA8
*  IF lv_freight IS NOT INITIAL.
*    WRITE lv_freight   TO fp_header-freight_charge    CURRENCY fp_doc_currency.
*  ENDIF. " IF lv_freight IS NOT INITIAL
*
*  IF lv_handling IS NOT INITIAL.
*    WRITE lv_handling  TO fp_header-handling_charge   CURRENCY fp_doc_currency.
*  ENDIF. " IF lv_handling IS NOT INITIAL
*
*  IF lv_insurance IS NOT INITIAL.
*    WRITE lv_insurance TO fp_header-insurance_charge  CURRENCY fp_doc_currency.
*  ENDIF. " IF lv_insurance IS NOT INITIAL
*
*  IF lv_document IS NOT INITIAL.
*    WRITE lv_document  TO fp_header-document_charge   CURRENCY fp_doc_currency.
*  ENDIF. " IF lv_document IS NOT INITIAL
* End of Delete for Defect_5676 by ASHARMA8

* Begin of Insert for Defect_5676 by ASHARMA8
* --->Begin of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 22-Feb-2018
**FUT_Issue
*Freight charges should not appear when 0
  IF lv_freight IS NOT INITIAL.
* <---End of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 22-Feb-2018
* Freight, Handling, Insurance & Documentation charges should appear as 0 not blank
    WRITE lv_freight   TO fp_header-freight_charge    CURRENCY fp_doc_currency.
* --->Begin of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 22-Feb-2018
  ELSE. " ELSE -> IF lv_freight IS NOT INITIAL
    CLEAR: fp_header-freight_charge.
  ENDIF. " IF lv_freight IS NOT INITIAL
* <---End of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 22-Feb-2018

* Begin of Delete for Defect_7129 (CR D3_301) by ASHARMA8
*  WRITE lv_handling  TO fp_header-handling_charge   CURRENCY fp_doc_currency.
* End of Delete for Defect_7129 (CR D3_301) by ASHARMA8

*&-->Begin of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
*&--Insurance charge should print as blank when value is initial.Script added in form to hide label
  IF lv_insurance IS NOT INITIAL.
*&<--End of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017

    WRITE lv_insurance TO fp_header-insurance_charge  CURRENCY fp_doc_currency.

*&-->Begin of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
  ENDIF. " IF lv_insurance IS NOT INITIAL
*&<--End of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017

* Begin of Delete for Defect_7129 (CR D3_301) by ASHARMA8
*  WRITE lv_document  TO fp_header-document_charge   CURRENCY fp_doc_currency.
* End of Delete for Defect_7129 (CR D3_301) by ASHARMA8

* End of Insert for Defect_5676 by ASHARMA8

* Begin of Insert for Defect_7129 (CR D3_301) by ASHARMA8
* If handing charges & Document charges are not 0, then only value & label
* needs to be printed. Script added in form to hide label
  IF lv_handling IS NOT INITIAL.
    WRITE lv_handling  TO fp_header-handling_charge   CURRENCY fp_doc_currency.
  ENDIF. " IF lv_handling IS NOT INITIAL

  IF lv_document IS NOT INITIAL.
    WRITE lv_document  TO fp_header-document_charge   CURRENCY fp_doc_currency.
  ENDIF. " IF lv_document IS NOT INITIAL
* End of Insert for Defect_7129 (CR D3_301) by ASHARMA8

*&-->Begin of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
*&--Environment charge should print as blank when value is initial.Script added in form to hide label
  IF lv_environment IS NOT INITIAL.
    WRITE lv_environment  TO fp_header-environment_fee   CURRENCY fp_doc_currency.
  ENDIF. " IF lv_environment IS NOT INITIAL
*&--Clearing the local variables used.
  CLEAR: lv_document,
         lv_insurance,
         lv_environment,
         lv_handling,
         lv_freight.
*&<--End of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017

*************************************************************************
**** Populate tax summary
*************************************************************************
  SORT li_tax BY kbetr_char.

**&-->Begin of Insert for  D3_OTC_FDD_0088 by U101734 on 14/08/2018 Defect #6782
*Calculate the collective percentage rate of vat adding up all vat rates of relevant category classes VAT summary table
  li_tmp = li_tax.
  CLEAR li_tax.
  DELETE li_tmp WHERE kstat EQ abap_true.
  SORT li_tmp BY kbetr_char koaid kntyp.

  LOOP AT li_tmp ASSIGNING <lfs_tax> WHERE kwert IS NOT INITIAL.
    IF lv_prev_kbetr EQ <lfs_tax>-kbetr_char.
      CLEAR <lfs_tax>-kntyp.
      COLLECT <lfs_tax> INTO li_tax.
    ELSE. " ELSE -> IF lv_prev_kbetr EQ <lfs_tax>-kbetr_char
      IF <lfs_tax>-kntyp CA lc_typ.
        READ TABLE li_tax ASSIGNING <lfs_tmp> WITH KEY kbetr_char = lv_prev_kbetr.
        IF sy-subrc EQ 0.
          <lfs_tmp>-kbetr_char = <lfs_tmp>-kbetr_char +  <lfs_tax>-kbetr_char.
          <lfs_tmp>-kwert = <lfs_tmp>-kwert +  <lfs_tax>-kwert.
        ELSE. " ELSE -> if sy-subrc eq 0
          CLEAR <lfs_tax>-kntyp.
          APPEND <lfs_tax> TO li_tax.
        ENDIF. " if sy-subrc eq 0
      ELSE. " ELSE -> if <lfs_tax>-kntyp CA lc_typ
        CLEAR <lfs_tax>-kntyp.
        APPEND <lfs_tax> TO li_tax.
      ENDIF. " if <lfs_tax>-kntyp CA lc_typ
    ENDIF. " IF lv_prev_kbetr EQ <lfs_tax>-kbetr_char
    lv_prev_kbetr = <lfs_tax>-kbetr_char.
  ENDLOOP. " LOOP AT li_tmp ASSIGNING <lfs_tax> WHERE kwert IS NOT INITIAL
**&-->End of Insert for  D3_OTC_FDD_0088 by U101734 on 14/08/2018 Defect #6782

  LOOP AT li_tax ASSIGNING <lfs_tax>.

    lwa_summary-unit       = lc_percent.

* Begin of Delete for Defect_5595 by ASHARMA8
*    lwa_summary-kbetr_char = lwa_tax-kbetr_char.
* End of Delete for Defect_5595 by ASHARMA8

* Begin of Insert for Defect_5595 by ASHARMA8
    lwa_summary-kbetr_char = <lfs_tax>-kbetr_char.
* End of Insert for Defect_5595 by ASHARMA8

* Begin of Insert for Defect_5595 by ASHARMA8
    CONDENSE lwa_summary-kbetr_char.
* End of Insert for Defect_5595 by ASHARMA8

    WRITE <lfs_tax>-kawrt TO lwa_summary-kawrt_char CURRENCY fp_header-waerk.
    WRITE <lfs_tax>-kwert TO lwa_summary-kwert_char CURRENCY fp_header-waerk.

    APPEND lwa_summary TO li_summary.
    CLEAR lwa_summary.

  ENDLOOP. " LOOP AT li_tax ASSIGNING <lfs_tax>

  fp_header-tax_summary = li_summary.

*************************************************************************
**** Populate tax legal text
*************************************************************************

* Populate standard text name based on tax code and company code country
  LOOP AT li_taxcode ASSIGNING <lfs_taxcode>.

    CONCATENATE lc_taxcode
* Begin of Delete for Defect_7129 (CR D3_301) by ASHARMA8
*                fp_header-compcode_ctry
* End of Delete for Defect_7129 (CR D3_301) by ASHARMA8
* Begin of Insert for Defect_7129 (CR D3_301) by ASHARMA8
                fp_header-zzrland
* End of Insert for Defect_7129 (CR D3_301) by ASHARMA8
                <lfs_taxcode>-mwskz
           INTO lwa_tax_legal-textname
           SEPARATED BY lc_sep.
    APPEND lwa_tax_legal TO li_tax_legal.
    CLEAR lwa_tax_legal.

  ENDLOOP. " LOOP AT li_taxcode ASSIGNING <lfs_taxcode>

* Begin of Insert for Defect_7129 (CR D3_301) by ASHARMA8
  IF li_tax_legal[] IS NOT INITIAL.
    SORT li_tax_legal BY textname.
    DELETE ADJACENT DUPLICATES FROM li_tax_legal COMPARING textname.
    SELECT tdname " Name
      FROM stxh   " STXD SAPscript text file header
      INTO TABLE fp_header-tax_legal
      FOR ALL ENTRIES IN li_tax_legal
      WHERE tdobject = lc_text
        AND tdname   = li_tax_legal-textname
        AND tdid     = lc_st
        AND tdspras  = fp_header-langu.
    ##needed IF sy-subrc EQ 0.
    ENDIF. " IF li_tax_legal[] IS NOT INITIAL
  ENDIF. " IF li_tax_legal[] IS NOT INITIAL
* End of Insert for Defect_7129 (CR D3_301) by ASHARMA8


* Begin of Delete for Defect_7129 (CR D3_301) by ASHARMA8
*  fp_header-tax_legal = li_tax_legal.
* End of Delete for Defect_7129 (CR D3_301) by ASHARMA8

  FREE: li_summary,
        li_tax,
        li_taxcode,
        li_tax_legal.

ENDFORM. " F_GET_CONDITIONS_DATA
*&---------------------------------------------------------------------*
*&      Form  F_GET_BANK_DETAILS
*&---------------------------------------------------------------------*
*       Get bank details
*----------------------------------------------------------------------*
*      -->FP_BUKRS   Company code
*      -->FP_WAERK   Currency
*      -->FP_ENH_STATUS Enhancement status
*      <--FP_HEADER  Proforma invoice form header structure
*----------------------------------------------------------------------*
FORM f_get_bank_details  USING    fp_bukrs  TYPE bukrs                 " Company Code
                                  fp_waerk  TYPE waers                 " Currency Key
                                  fp_enh_status TYPE zdev_tt_enh_status
                         CHANGING fp_header TYPE zotc_proforma_header. " Proforma invoice form header structure

  DATA: li_bank   TYPE STANDARD TABLE OF ty_bank, " House Bank Determination
        lwa_bank  TYPE ty_bank,                   " House Bank Determination
        lv_banks  TYPE banks,                     " Bank country key
        lv_bankl  TYPE bankk,                     " Bank Keys
        lv_bankn  TYPE bankn,                     " Bank account number
        lv_bkont  TYPE bkont,                     " Bank Control Key
* ---> Begin of Insert for D3_OTC_FDD_00088_CR#356 by MGARG
        li_text      TYPE STANDARD TABLE OF tline INITIAL SIZE 0, " SAPscript: Text Lines
        lv_iban      TYPE iban,                                   " IBAN (International Bank Account Number)
        lv_len_iban  TYPE int2,                                   " 2 byte integer (signed)
        lv_index     TYPE int2,                                   " 2 byte integer (signed)
        lv_char      TYPE char4,                                  " Char of type CHAR4
        lv_final_val TYPE string.

  CONSTANTS:
             lc_address         TYPE tdobname      VALUE 'ZOTC_BANKADDR_FIRMA_CH', " Name
             lc_txt_obj_st      TYPE tdobject      VALUE 'TEXT',                   "text obj for std text
             lc_txt_id_st       TYPE tdid          VALUE 'ST',                     "text id for std text
             lc_english         TYPE spras         VALUE 'E',                      " language Key
             lc_bank_name       TYPE z_criteria    VALUE 'BANK_KEY_NVALUE',        " Enh. Criteria
             lc_bank_cleacc     TYPE z_criteria    VALUE 'BANK_KEY_CLEACC',        " Enh. Criteria
* ---> Begin of Insert for D3_OTC_FDD_00088_CR#356_2nd_change by MGARG
             lc_bank_nocle      TYPE z_criteria    VALUE 'BANK_KEY_NOCLEACC', " Enh. Criteria
* ---> End of Insert for D3_OTC_FDD_00088_CR#356_2nd_change by MGARG
             lc_bank_accno      TYPE z_criteria    VALUE 'BANK_KEY_ACCNO', " Enh. Criteria

* ---> End of Insert for D3_OTC_FDD_00088_CR#356 by MGARG
  lc_sep              TYPE char1      VALUE '-',     " Sep of type CHAR1
  lc_bukrs            TYPE z_criteria VALUE 'BUKRS', " Enh. Criteria
* Begin of Insert for Defect_7129 (CR D3_301) by ASHARMA8
  lc_vkorg_ch         TYPE z_criteria VALUE 'VKORG_CH'. " Enh. Criteria
* End of Insert for Defect_7129 (CR D3_301) by ASHARMA8

* ---> Begin of Insert for D3_OTC_FDD_00088_CR#356 by MGARG
  FIELD-SYMBOLS : <lfs_text> TYPE tline. " SAPscript: Text Lines
* ---> End of Insert for D3_OTC_FDD_00088_CR#356 by MGARG

**** Get bank details based on company code and currency
  SELECT bukrs     " Company Code
         waerk     " SD Document Currency
         hbkid     " Short Key for a House Bank
         htkid     " ID for Account Details
    FROM zotc_bank " House Bank Determination
    INTO TABLE li_bank
    WHERE bukrs = fp_bukrs.
  IF sy-subrc NE 0.
    RETURN.
  ENDIF. " IF sy-subrc NE 0

  SORT li_bank BY bukrs waerk.

  READ TABLE li_bank INTO lwa_bank
                     WITH KEY bukrs = fp_bukrs
                              waerk = fp_waerk
                     BINARY SEARCH.
  IF sy-subrc NE 0.
    READ TABLE li_bank INTO lwa_bank
                  WITH KEY bukrs = fp_bukrs.
    IF sy-subrc NE 0.
      RETURN.
    ENDIF. " IF sy-subrc NE 0
  ENDIF. " IF sy-subrc NE 0


**** Get bank name, street, city and SWIFT based on T012
  SELECT SINGLE
         banks " Bank country key
         bankl " Bank Keys
    FROM t012  " House Banks
    INTO (lv_banks, lv_bankl)
    WHERE bukrs = lwa_bank-bukrs
      AND hbkid = lwa_bank-hbkid.

  IF sy-subrc = 0.
    SELECT SINGLE
           banka " Name of bank
* ---> Begin of Delete for D3_OTC_FDD_00088_CR#356 by MGARG
*           stras " House number and street
* ---> End of Delete for D3_OTC_FDD_00088_CR#356 by MGARG
           ort01 " City
           swift " SWIFT/BIC for International Payments
      FROM bnka  " Bank master record
      INTO (fp_header-banka,
* ---> Begin of Delete for D3_OTC_FDD_00088_CR#356 by MGARG
** Bank address is not required
*            fp_header-bank_stras,
* ---> End of Delete for D3_OTC_FDD_00088_CR#356 by MGARG
            fp_header-bank_ort01,
            fp_header-swift)
      WHERE banks = lv_banks
        AND bankl = lv_bankl.
    IF sy-subrc NE 0.
      CLEAR: fp_header-banka,
* ---> Begin of Delete for D3_OTC_FDD_00088_CR#356 by MGARG
*          fp_header-bank_stras,
* ---> End of Delete for D3_OTC_FDD_00088_CR#356 by MGARG
          fp_header-bank_ort01,
          fp_header-swift.
    ENDIF. " IF sy-subrc NE 0
  ENDIF. " IF sy-subrc = 0

* ---> Begin of Insert for D3_OTC_FDD_00088_CR#356 by MGARG
*Check if banks belong to 'CH', then need to pick standard text for
* Bank Name/City
  READ TABLE fp_enh_status TRANSPORTING NO FIELDS
                          WITH KEY criteria = lc_bank_name
                                   sel_low  = lv_banks
                          BINARY SEARCH.
  IF sy-subrc = 0.
    CLEAR: fp_header-banka,
           fp_header-bank_stras,
           fp_header-bank_ort01.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_txt_id_st
        language                = lc_english
        name                    = lc_address
        object                  = lc_txt_obj_st
      TABLES
        lines                   = li_text
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc = 0 .
      READ TABLE li_text ASSIGNING <lfs_text> INDEX 1.
      IF sy-subrc IS INITIAL.
        fp_header-banka = <lfs_text>-tdline.
      ENDIF. " IF sy-subrc IS INITIAL

      READ TABLE li_text ASSIGNING <lfs_text> INDEX 2.
      IF sy-subrc IS INITIAL.
        fp_header-bank_ort01 = <lfs_text>-tdline.
      ENDIF. " IF sy-subrc IS INITIAL

      READ TABLE li_text ASSIGNING <lfs_text> INDEX 3.
      IF sy-subrc IS INITIAL.
        fp_header-bank_stras = <lfs_text>-tdline.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF sy-subrc = 0

* ---> End of Insert for D3_OTC_FDD_00088_CR#356 by MGARG

*** Get IBAN number based on T012K
  SELECT SINGLE
         bankn " Bank account number
         bkont " Bank Control Key
    FROM t012k " House Bank Accounts
    INTO (lv_bankn, lv_bkont)
    WHERE bukrs = lwa_bank-bukrs
      AND hbkid = lwa_bank-hbkid
      AND hktid = lwa_bank-htkid.

  IF sy-subrc = 0.

    SELECT SINGLE
           iban  " IBAN (International Bank Account Number)
      FROM tiban " IBAN
* ---> Begin of Delete for D3_OTC_FDD_00088_CR#356 by MGARG
*      INTO fp_header-iban
* ---> End of Delete for D3_OTC_FDD_00088_CR#356 by MGARG
* ---> Begin of Insert for D3_OTC_FDD_00088_CR#356 by MGARG
       INTO lv_iban
* ---> End of Insert for D3_OTC_FDD_00088_CR#356 by MGARG
      WHERE banks = lv_banks
        AND bankl = lv_bankl
        AND bankn = lv_bankn
        AND bkont = lv_bkont.
    IF sy-subrc NE 0.
* ---> Begin of Delete for D3_OTC_FDD_00088_CR#356 by MGARG
*      CLEAR fp_header-iban.
* ---> End of Delete for D3_OTC_FDD_00088_CR#356 by MGARG
* ---> Begin of Insert for D3_OTC_FDD_00088_CR#356 by MGARG
      CLEAR lv_iban.
    ELSE. " ELSE -> IF sy-subrc NE 0
**To fullfill the requirement of inserting a space after every 4
** Character, below logic is implemented.
      CLEAR: lv_len_iban,
             lv_index,
             lv_char,
             lv_final_val.
** Get length of IBAN
      lv_len_iban = strlen( lv_iban ).

      WHILE lv_index < lv_len_iban.
        lv_char = lv_iban+lv_index(4).
        IF sy-index EQ 1.
          lv_final_val = lv_char.
        ELSE. " ELSE -> IF sy-index EQ 1
          CONCATENATE lv_final_val lv_char INTO lv_final_val
          SEPARATED BY space.
        ENDIF. " IF sy-index EQ 1
        lv_index = lv_index + 4.
      ENDWHILE.
      fp_header-iban = lv_final_val.
* ---> End of Insert for D3_OTC_FDD_00088_CR#356 by MGARG
    ENDIF. " IF sy-subrc NE 0

  ENDIF. " IF sy-subrc = 0

* ---> Begin of Delete for D3_OTC_FDD_00088_CR#356 by MGARG
*  READ TABLE fp_enh_status TRANSPORTING NO FIELDS
*                           WITH KEY criteria = lc_bukrs
*                                    sel_low  = fp_bukrs
*                           BINARY SEARCH.
*  IF sy-subrc = 0.
*    CONCATENATE lv_bankl+0(2)
*                lv_bankl+2(2)
*                lv_bankl+4(2)
*                lv_bankn
*           INTO fp_header-bank_account
*           SEPARATED BY lc_sep.
*  ELSE. " ELSE -> IF sy-subrc = 0
*    CONCATENATE lv_bankl
*                lv_bankn
*                lv_bkont
*           INTO fp_header-bank_account
*         SEPARATED BY space.
*  ENDIF. " IF sy-subrc = 0
* ---> End of Delete for D3_OTC_FDD_00088_CR#356 by MGARG
* ---> Begin of Insert for D3_OTC_FDD_00088_CR#356 by MGARG
** To get Account number based on bank country key.
** values are maintained in EMI
  READ TABLE fp_enh_status TRANSPORTING NO FIELDS
                           WITH KEY criteria = lc_bank_accno
                                    sel_low  = lv_banks
                           BINARY SEARCH.
  IF sy-subrc = 0.
* ---> Begin of Delete for D3_OTC_FDD_00088_CR#356_2nd_change by MGARG
*    CONCATENATE lv_bankn
*                lv_bkont
*          INTO fp_header-bank_account
*          SEPARATED BY space .
* ---> End of Delete for D3_OTC_FDD_00088_CR#356_2nd_change by MGARG

* ---> Begin of Insert for D3_OTC_FDD_00088_CR#356_2nd_change by MGARG
    CONCATENATE lv_iban+4(10)
                lv_iban+14(11)
                lv_iban+25(2)
           INTO fp_header-bank_account
           SEPARATED BY space.
* ---> End of Insert for D3_OTC_FDD_00088_CR#356_2nd_change by MGARG
  ELSE. " ELSE -> IF sy-subrc = 0
* ---> Begin of Delete for D3_OTC_FDD_00088_CR#356_2nd_change by MGARG
*    CONCATENATE lv_bankl
*                lv_bankn
*                lv_bkont
*           INTO fp_header-bank_account
*         SEPARATED BY space.
* ---> End of Delete for D3_OTC_FDD_00088_CR#356_2nd_change by MGARG
* ---> Begin of Insert for D3_OTC_FDD_00088_CR#356_2nd_change by MGARG
    CONCATENATE lv_bankn
                lv_bkont
           INTO fp_header-bank_account
           SEPARATED BY space.
* ---> End of Insert for D3_OTC_FDD_00088_CR#356_2nd_change by MGARG
  ENDIF. " IF sy-subrc = 0

** To get Clearing account based on bank country key.
** values are maintained in EMI

  READ TABLE fp_enh_status TRANSPORTING NO FIELDS
                           WITH KEY criteria = lc_bank_cleacc
                                    sel_low  = lv_banks
                           BINARY SEARCH.
  IF sy-subrc = 0.
* Populate clearing account
    CONCATENATE lv_bankl+0(2)
                lv_bankl+2(2)
                lv_bankl+4(2)
       INTO fp_header-bankl
       SEPARATED BY lc_sep.
* ---> Begin of Insert for D3_OTC_FDD_00088_CR#356_2nd_change by MGARG
  ELSE. " ELSE -> IF sy-subrc = 0
    READ TABLE fp_enh_status TRANSPORTING NO FIELDS
                           WITH KEY criteria = lc_bank_nocle
                                    sel_low  = lv_banks
                           BINARY SEARCH.
    IF sy-subrc IS NOT INITIAL.
      fp_header-bankl = lv_bankl.
    ENDIF. " IF sy-subrc IS NOT INITIAL
* ---> End of Insert for D3_OTC_FDD_00088_CR#356_2nd_change by MGARG
  ENDIF. " IF sy-subrc = 0

* ---> Begin of Delete for D3_OTC_FDD_00088_CR#356_2nd_change by MGARG
**** Logic to fetch clearing account get changed as per above logic
* ---> End of Insert for D3_OTC_FDD_00088_CR#356 by MGARG

** Begin of Insert for Defect_7129 (CR D3_301) by ASHARMA8
** If VKORG = 2001 or 2002, then print bank Name & address from SO10 text
** Also, print clearing account
*  READ TABLE fp_enh_status TRANSPORTING NO FIELDS
*                           WITH KEY criteria = lc_vkorg_ch
*                                    sel_low  = fp_header-vkorg
*                           BINARY SEARCH.
*  IF sy-subrc = 0.
*    CLEAR: fp_header-banka,
*           fp_header-bank_stras,
*           fp_header-bank_ort01.
*    fp_header-bank_ch_flag = abap_true.
*
** Populate clearing account
*    fp_header-bankl = lv_bankl.
*
*  ENDIF. " IF sy-subrc = 0
** End of Insert for Defect_7129 (CR D3_301) by ASHARMA8
* ---> End of Delete for D3_OTC_FDD_00088_CR#356_2nd_change by MGARG

  FREE: li_bank.

ENDFORM. " F_GET_BANK_DETAILS
*&---------------------------------------------------------------------*
*&      Form  F_GET_PAYMENT_TERMS
*&---------------------------------------------------------------------*
*       Get payment terms
*----------------------------------------------------------------------*
*      -->FP_VBDKR   Document Header View for Billing
*      <--FP_HEADER  Proforma invoice form header structure
*----------------------------------------------------------------------*
FORM f_get_payment_terms  USING    fp_vbdkr   TYPE vbdkr " Document Header View for Billing
* Begin of Insert for Defect_7129 (CR D3_301) by ASHARMA8
                                   fp_enh_status TYPE zdev_tt_enh_status
* End of Insert for Defect_7129 (CR D3_301) by ASHARMA8
                          CHANGING fp_header  TYPE zotc_proforma_header. " Proforma invoice form header structure

  DATA: lv_zterm  TYPE dzterm. " Terms of Payment Key

* Begin of Insert for Defect_7129 (CR D3_301) by ASHARMA8

  CONSTANTS: lc_vbtyp       TYPE z_criteria VALUE 'VBTYP',             " Enh. Criteria
             lc_bukrs_spain TYPE z_criteria VALUE 'BUKRS_SPAIN',       " Enh. Criteria
             lc_zterm       TYPE char20     VALUE '(SAPLV05N)ZTERM[]'. " Zterm of type CHAR20

  FIELD-SYMBOLS: <lfs_zterm> TYPE ANY TABLE. " Information Structure for Installment Payment Terms

  DATA: li_zterm TYPE STANDARD TABLE OF vtopis, " Information Structure for Installment Payment Terms
        lwa_zterm TYPE vtopis.                  " Information Structure for Installment Payment Terms

***Begin of Change by u034087 for Defect#2622 on 20 April,2017

  FIELD-SYMBOLS : <lfs_zterm1>   TYPE vtopis, "Information Structure for Installment Payment Terms
                  <lfs_top_text> TYPE vtopis. "Information Structure for Installment Payment Terms

  DATA            li_top_text TYPE STANDARD TABLE OF vtopis INITIAL SIZE 0. " Information Structure for Installment Payment Terms

***End of Change by u034087 for Defect#2622 on 20 April,2017

* End of Insert for Defect_7129 (CR D3_301) by ASHARMA8

* Begin of Insert for Defect_7129 (CR D3_301) by ASHARMA8

* If VBTYP = 'O' or '6', donot print payment terms text
  READ TABLE fp_enh_status TRANSPORTING NO FIELDS
                           WITH KEY criteria = lc_vbtyp
                                    sel_low  = fp_header-vbtyp
                           BINARY SEARCH.
  IF sy-subrc NE 0.

    ASSIGN (lc_zterm) TO <lfs_zterm>.
    IF <lfs_zterm> IS ASSIGNED.
      li_zterm = <lfs_zterm>.
      UNASSIGN <lfs_zterm>.
    ENDIF. " IF <lfs_zterm> IS ASSIGNED
* End of Insert for Defect_7129 (CR D3_301) by ASHARMA8

***Begin of Change by u034087 for Defect#2622 on 20 April,2017
    READ TABLE li_zterm ASSIGNING <lfs_zterm1> INDEX 1.
    IF sy-subrc = 0.
      SELECT SINGLE vtext " Description of terms of payment
             INTO <lfs_zterm1>-line
            FROM tvzbt    " Customers: Terms of Payment Texts
         WHERE spras = fp_header-langu
           AND zterm = fp_vbdkr-zterm.
    ENDIF. " IF sy-subrc = 0
***End of Change by u034087 for Defect#2622 on 20 April,2017

    SELECT zterm " Terms of Payment Key
      FROM t052  " Terms of Payment
      INTO lv_zterm
      UP TO 1 ROWS
      WHERE zterm = fp_vbdkr-zterm
        AND xsplt = abap_true.
    ENDSELECT.

    IF sy-subrc = 0
      AND lv_zterm IS NOT INITIAL.

* CASE1: When installment payment indicator is set,
* LINE1 - print ZTERM_BEZ in language of o/p
* LINE2 - print text "Please refer to schedule of payment"
      fp_header-zterm_bez = fp_vbdkr-zterm_bez.
* Begin of Insert for Defect_7129 (CR D3_301) by ASHARMA8
      fp_header-xsplt     = abap_true.
* End of Insert for Defect_7129 (CR D3_301) by ASHARMA8

    ELSE. " ELSE -> IF sy-subrc = 0

* Begin of Insert for Defect_7129 (CR D3_301) by ASHARMA8
      READ TABLE fp_enh_status TRANSPORTING NO FIELDS
                            WITH KEY criteria = lc_bukrs_spain
                                     sel_low  = fp_header-bukrs
                            BINARY SEARCH.
      IF sy-subrc = 0.

* CASE2: When installment payment indicator is not set & Company code is 2045
* LINE1 - print "Net due date" in language of o/p + HDATUM
        READ TABLE li_zterm INTO lwa_zterm INDEX 1.
        IF sy-subrc = 0.
* Begin of Delete for CR D3_301_Part2  by ASHARMA8
*          WRITE lwa_zterm-hdatum TO fp_header-hdatum_char.
* End of Delete for CR D3_301_Part2 by ASHARMA8

* Begin of Insert for CR D3_301_Part2 by ASHARMA8
          PERFORM f_convert_date_format USING    lwa_zterm-hdatum
                                                 fp_header-langu
                                        CHANGING fp_header-hdatum_char.
* End of Insert for CR D3_301_Part2 by ASHARMA8
        ENDIF. " IF sy-subrc = 0

      ELSE. " ELSE -> IF sy-subrc = 0
* End of Insert for Defect_7129 (CR D3_301) by ASHARMA8

* CASE2: When installment payment indicator is not set & Company code is not 2045
* LINE1 - print First line of TOP_TEXT
* LINE2 - print Second line of TOP_TEXT
* LINE3 - print Third line of TOP_TEXT
* TOP_TEXT comes from (SAPLV05N)ZTERM[]

**Begin of Delete by u034087 for Defect#2622 on 20-April-2017
*        fp_header-zterm_tx1 = fp_vbdkr-zterm_tx1.
*        fp_header-zterm_tx2 = fp_vbdkr-zterm_tx2.
**End of Delete by u034087 for Defect#2622 on 20-April-2017

* Begin of Insert for Defect_7129 (CR D3_301) by ASHARMA8

**Begin of Delete by u034087 for Defect#2622 on 20-April-2017
*        fp_header-zterm_tx3 = fp_vbdkr-zterm_tx3.
**End of Delete by u034087 for Defect#2622 on 20-April-2017

**Begin of Change by u034087 for Defect#2622 on 20-April-2017
        CALL FUNCTION 'SD_PRINT_TERMS_OF_PAYMENT'
          EXPORTING
            bldat                        = fp_header-fkdat
            language                     = fp_header-langu
            terms_of_payment             = fp_vbdkr-zterm
          TABLES
            top_text                     = li_top_text
          EXCEPTIONS
            terms_of_payment_not_in_t052 = 1
            OTHERS                       = 2.

        IF sy-subrc = 0.
          READ TABLE li_top_text  ASSIGNING <lfs_top_text> INDEX 1.
          IF sy-subrc = 0.
            fp_header-zterm_tx1  = <lfs_top_text>-line.
          ENDIF. " IF sy-subrc = 0

          READ TABLE li_top_text  ASSIGNING <lfs_top_text> INDEX 2.
          IF sy-subrc = 0.
            fp_header-zterm_tx2  = <lfs_top_text>-line.
          ENDIF. " IF sy-subrc = 0


          READ TABLE li_top_text  ASSIGNING <lfs_top_text> INDEX 3.
          IF sy-subrc = 0.
            fp_header-zterm_tx3  = <lfs_top_text>-line.
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF sy-subrc = 0
**End of Change by u034087 for Defect#2622 on 20-April-2017

      ENDIF. " IF sy-subrc = 0
* End of Insert for Defect_7129 (CR D3_301) by ASHARMA8

    ENDIF. " IF sy-subrc = 0

* Begin of Insert for Defect_7129 (CR D3_301) by ASHARMA8
  ENDIF. " IF sy-subrc NE 0
* End of Insert for Defect_7129 (CR D3_301) by ASHARMA8

ENDFORM. " F_GET_PAYMENT_TERMS
*&---------------------------------------------------------------------*
*&      Form  F_GET_PAYMENT_METHOD
*&---------------------------------------------------------------------*
*       Get payment method
*----------------------------------------------------------------------*
*      -->FP_ENH_STATUS Enhancement status
*      <--FP_HEADER     Proforma invoice form header structure
*----------------------------------------------------------------------*
FORM f_get_payment_method  USING    fp_enh_status TYPE zdev_tt_enh_status
                           CHANGING fp_header     TYPE zotc_proforma_header. " Proforma invoice form header structure

  DATA: lwa_enh_status TYPE zdev_enh_status, " Enhancement Status
        lv_zlsch       TYPE dzlsch,          " Payment Method
        lv_zwels       TYPE dzwels.          " List of the Payment Methods to be Considered

  CONSTANTS: lc_ddebit TYPE z_criteria VALUE 'DDEBIT'. " Enh. Criteria

  IF fp_header-zlsch IS NOT INITIAL.
    lv_zlsch = fp_header-zlsch.

  ELSE. " ELSE -> IF fp_header-zlsch IS NOT INITIAL

    SELECT SINGLE zwels " List of the Payment Methods to be Considered
      FROM knb1         " Customer Master (Company Code)
      INTO lv_zwels
      WHERE kunnr = fp_header-payer
        AND bukrs = fp_header-bukrs.

    IF sy-subrc = 0.

      READ TABLE fp_enh_status INTO lwa_enh_status
                               WITH KEY criteria = lc_ddebit
                               BINARY SEARCH.
      IF sy-subrc = 0.

        lv_zlsch = lwa_enh_status-sel_low.

        IF  lv_zlsch CA lv_zwels
          AND lv_zlsch IS NOT INITIAL.
        ELSE. " ELSE -> IF lv_zlsch CA lv_zwels
          CLEAR lv_zlsch.
        ENDIF. " IF lv_zlsch CA lv_zwels

      ENDIF. " IF sy-subrc = 0

    ENDIF. " IF sy-subrc = 0

  ENDIF. " IF fp_header-zlsch IS NOT INITIAL

  IF lv_zlsch IS NOT INITIAL.
    SELECT SINGLE text2 " Description of Payment Method in Logon Language
     FROM t042zt        " Texts of Payment Methods for Automatic Payment
     INTO fp_header-pay_meth_txt
     WHERE spras = fp_header-langu
       AND land1 = fp_header-compcode_ctry
       AND zlsch = lv_zlsch.
    IF sy-subrc NE 0.
      CLEAR fp_header-pay_meth_txt.
    ENDIF. " IF sy-subrc NE 0
  ENDIF. " IF lv_zlsch IS NOT INITIAL

ENDFORM. " F_GET_PAYMENT_METHOD
*&---------------------------------------------------------------------*
*&      Form  F_GET_ENH_STATUS_DATA
*&---------------------------------------------------------------------*
*       Fetch enhancement status data
*----------------------------------------------------------------------*
*      -->FP_ENH_STATUS Enhancement status
*----------------------------------------------------------------------*
FORM f_get_enh_status_data  CHANGING fp_enh_status TYPE zdev_tt_enh_status.

  CONSTANTS: lc_enhancement TYPE z_enhancement VALUE 'OTC_FDD_0088'. " Enhancement No.

* get EMI constants of the enhancement and store in class attributes
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enhancement
    TABLES
      tt_enh_status     = fp_enh_status.

  DELETE fp_enh_status WHERE active = abap_false.
  SORT   fp_enh_status BY    criteria
                             sel_low.

ENDFORM. " F_GET_ENH_STATUS_DATA
*&---------------------------------------------------------------------*
*&      Form  F_GET_FORM_IMAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FP_NAME  text
*      <--P_FP_HEADER_LOGO  text
*----------------------------------------------------------------------*
FORM f_get_form_image  USING    fp_name  TYPE tdobname " Name
                       CHANGING fp_image TYPE xstring.

  CONSTANTS:   lc_graphics     TYPE tdobjectgr     VALUE 'GRAPHICS', "Watermark
               lc_image_id     TYPE tdidgr         VALUE 'BMAP',     "Watermark: Obj id
               lc_image_type   TYPE tdbtype        VALUE 'BCOL'.     "Watermark: Obj type

  CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp
    EXPORTING
      p_object       = lc_graphics   "value: GRAPHICS
      p_name         = fp_name
      p_id           = lc_image_id   "value:BMAP
      p_btype        = lc_image_type "value:BCOL
    RECEIVING
      p_bmp          = fp_image
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc NE 0.
    CLEAR fp_image.
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_GET_FORM_IMAGE
*&---------------------------------------------------------------------*
*&      Form  F_GET_SALES_ORG_DATA
*&---------------------------------------------------------------------*
*       Get sales org data
*----------------------------------------------------------------------*
*      <--FP_HEADER  Proforma invoice form header structure
*----------------------------------------------------------------------*
FORM f_get_sales_org_data  CHANGING fp_header TYPE zotc_proforma_header. " Proforma invoice form header structure

* from sales org address number, get the sales org phone number

  SELECT tel_number " Telephone no.: dialling code+number
    FROM adr2       " Telephone Numbers (Business Address Services)
    INTO fp_header-salesorg_tel
    UP TO 1 ROWS
    WHERE addrnumber = fp_header-salesorg_addr.
  ENDSELECT.
  IF sy-subrc NE 0.
    CLEAR fp_header-salesorg_tel.
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_GET_SALES_ORG_DATA
*&---------------------------------------------------------------------*
*&      Form  F_GET_BILL_DOC_TYPE_DESC
*&---------------------------------------------------------------------*
*       Get billing document type description
*----------------------------------------------------------------------*
*      <--FP_HEADER  Proforma invoice form header structure
*----------------------------------------------------------------------*
FORM f_get_bill_doc_type_desc CHANGING fp_header     TYPE zotc_proforma_header. "Proforma invoice form header structure
* Get the billing document type description from custom table

  SELECT SINGLE bill_desc " 30 Characters
    FROM zotc_billname    " Billing type description for printing purpose
    INTO fp_header-bill_desc
    WHERE spras = fp_header-langu
      AND fkart = fp_header-fkart.
  IF sy-subrc NE 0.
    CLEAR fp_header-bill_desc.
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_GET_BILL_DOC_TYPE_DESC
*&---------------------------------------------------------------------*
*&      Form  F_FILL_HEAD_ADDRESS
*&---------------------------------------------------------------------*
*       Fill address details in form header
*----------------------------------------------------------------------*
*      <--FP_HEADER  Proforma invoice form header structure
*----------------------------------------------------------------------*
FORM f_fill_head_address CHANGING fp_header     TYPE zotc_proforma_header. " Proforma invoice form header structure

* Begin of Insert for Defect_5595 by ASHARMA8
  CONSTANTS: lc_lines_5 TYPE anzei VALUE '5', " Number of lines in address
             lc_lines_6 TYPE anzei VALUE '6'. " Number of lines in address
* End of Insert for Defect_5595 by ASHARMA8

* Begin of Insert for Defect_5921 by ASHARMA8
  FIELD-SYMBOLS: <lfs_add> TYPE fsbp_address_printf_line. " Print Form Row
* End of Insert for Defect_5921 by ASHARMA8

* Fill Bill to address table
  PERFORM f_get_address USING fp_header-billto_addr
                              fp_header-langu
* Begin of Insert for Defect_5595 by ASHARMA8
* Address of customers - bill to should have 6 lines max
                              lc_lines_6
* End of Insert for Defect_5595 by ASHARMA8
                              abap_true
                              abap_true
                        CHANGING fp_header-billto_address.

* Fill Sold to address table
  PERFORM f_get_address USING fp_header-soldto_addr
                              fp_header-langu
* Begin of Insert for Defect_5595 by ASHARMA8
* Address of customers - sold to should have 6 lines max
                              lc_lines_6
* End of Insert for Defect_5595 by ASHARMA8
                              abap_true
                              abap_true
                        CHANGING fp_header-soldto_address.

* Fill Ship to address table
  PERFORM f_get_address USING fp_header-shipto_addr
                              fp_header-langu
* Begin of Insert for Defect_5595 by ASHARMA8
* Address of customers - ship to should have 6 lines max
                              lc_lines_6
* End of Insert for Defect_5595 by ASHARMA8
                              abap_true
                              abap_true
                        CHANGING fp_header-shipto_address.

* Fill Sales org address table
  PERFORM f_get_address USING fp_header-salesorg_addr
                              fp_header-langu
* Begin of Insert for Defect_5595 by ASHARMA8
* Address For sales org should have 5 lines max
                              lc_lines_5
* End of Insert for Defect_5595 by ASHARMA8
                              abap_true
                              abap_true
                        CHANGING fp_header-salesorg_address.

* Begin of Insert for Defect_5921 by ASHARMA8
  LOOP AT fp_header-salesorg_address ASSIGNING <lfs_add>.

    CASE sy-tabix.

      WHEN 1.
        fp_header-sorg_addline1 = <lfs_add>-address_line.
      WHEN 2.
        fp_header-sorg_addline2 = <lfs_add>-address_line.
      WHEN 3.
        fp_header-sorg_addline3 = <lfs_add>-address_line.
      WHEN 4.
        fp_header-sorg_addline4 = <lfs_add>-address_line.
      WHEN 5.
        fp_header-sorg_addline5 = <lfs_add>-address_line.

    ENDCASE.

  ENDLOOP. " LOOP AT fp_header-salesorg_address ASSIGNING <lfs_add>
* End of Insert for Defect_5921 by ASHARMA8
ENDFORM. " F_FILL_HEAD_ADDRESS
*&---------------------------------------------------------------------*
*&      Form  F_GET_ADDRESS
*&---------------------------------------------------------------------*
*       Get address
*----------------------------------------------------------------------*
*      -->FP_ADRNR  Address number
*      -->FP_LANGU  Language
*      -->FP_NO_UPPER_CASE  Flag for no upper case
*      -->FP_COUNTRY_NAME_SEPARATE_LINE Flag for Country name in sep line
*      <--FP_ADDRESS  Table for address details
*----------------------------------------------------------------------*
FORM f_get_address  USING    fp_adrnr                      TYPE adrnr " Address
                             fp_langu                      TYPE langu " Language Key
* Begin of Insert for Defect_5595 by ASHARMA8
                             fp_no_of_lines                TYPE anzei " Number of lines in address
* End of Insert for Defect_5595 by ASHARMA8
                             fp_no_upper_case              TYPE xfeld " Checkbox
                             fp_country_name_separate_line TYPE xfeld " Checkbox
                    CHANGING fp_address TYPE fsbp_address_printf_line_tty.

  CONSTANTS: lc_add_typ_org  TYPE ad_adrtype VALUE '1'. " Address type (1=Organization, 2=Person, 3=Contact person)

  IF fp_adrnr IS NOT INITIAL.

    CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
      EXPORTING
        address_type                  = lc_add_typ_org
        address_number                = fp_adrnr
* Begin of Insert for CR D3_301_Part2 by ASHARMA8
        receiver_language             = fp_langu
* End of Insert for CR D3_301_Part2 by ASHARMA8
* Begin of Insert for Defect_5595 by ASHARMA8
        number_of_lines               = fp_no_of_lines
* End of Insert for Defect_5595 by ASHARMA8
* Begin of Insert for CR D3_301_Part2 by ASHARMA8
        country_name_in_receiver_langu = abap_true
* End of Insert for CR D3_301_Part2 by ASHARMA8
* Begin of Delete for CR D3_301_Part2 by ASHARMA8
*        language_for_country_name     = fp_langu
* End of Delete for CR D3_301_Part2 by ASHARMA8
        no_upper_case_for_city        = fp_no_upper_case
        iv_country_name_separate_line = fp_country_name_separate_line
      IMPORTING
        address_printform_table       = fp_address.

  ENDIF. " IF fp_adrnr IS NOT INITIAL

ENDFORM. " F_GET_ADDRESS
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_HEADER
*&---------------------------------------------------------------------*
*       Populate header
*----------------------------------------------------------------------*
*      -->FP_NAST    message status
*      -->FP_VBDKR   Document Header View for Billing
*      -->FP_TVKO    Organizational Unit: Sales Organizations
*      -->FP_VBDPR   Document Item data for Billing
*      -->FP_VBFA    Sales Document Flow
*      -->FP_ENH_STATUS Enhancement status
*      <--FP_HEADER  Proforma invoice form header structure
*----------------------------------------------------------------------*
FORM f_populate_header  USING     fp_nast   TYPE nast                  " Message Status
                                  fp_vbdkr  TYPE vbdkr                 " Document Header View for Billing
                                  fp_tvko   TYPE tvko                  " Organizational Unit: Sales Organizations
                                  fp_vbdpr  TYPE tbl_vbdpr
                                  fp_vbfa   TYPE ty_t_vbfa
                                  fp_enh_status TYPE zdev_tt_enh_status
                        CHANGING  fp_header TYPE zotc_proforma_header. " Proforma invoice form header structure

* Populate form control data
  PERFORM f_fill_control_data       USING     fp_nast
                                              fp_vbdkr
                                              fp_enh_status
                                    CHANGING  fp_header.

* Populate form fields from invoice header
  PERFORM f_fill_form_head_data     USING    fp_vbdkr
                                             fp_tvko
                                             fp_vbdpr
                                    CHANGING fp_header.

* Populate standard text
  PERFORM f_fill_standard_text      USING    fp_enh_status
                                    CHANGING fp_header.


* Fetch invoice partner data & populate form header
  PERFORM f_get_partner_data        USING    fp_vbdkr-vbeln
                                    CHANGING fp_header.

* Fetch company code data
  PERFORM f_get_compcode_data       USING    fp_vbdkr-bukrs
                                    CHANGING fp_header.

* Fetch customer data & populate form header
  PERFORM f_get_customer_data       CHANGING fp_header.


* Fetch sales org data & populate form header
  PERFORM f_get_sales_org_data      CHANGING fp_header.


* Fetch billing type description in form language & populate form header
  PERFORM f_get_bill_doc_type_desc CHANGING fp_header.

* Populate address tables in form header

  PERFORM f_fill_head_address CHANGING fp_header.

* Populate original invoice
  PERFORM f_get_original_invoice    USING    fp_vbdpr
                                             fp_vbfa
                                    CHANGING fp_header.

* Fetch bank details & populate header
  PERFORM f_get_bank_details        USING    fp_vbdkr-bukrs
                                             fp_vbdkr-waerk
                                             fp_enh_status
                                    CHANGING fp_header.

* Fetch payment terms text & populate header
  PERFORM f_get_payment_terms       USING    fp_vbdkr
* Begin of Insert for Defect_7129 (CR D3_301) by ASHARMA8
                                             fp_enh_status
* End of Insert for Defect_7129 (CR D3_301) by ASHARMA8
                                    CHANGING fp_header.

* Fetch payment method text $ populate form header
  PERFORM f_get_payment_method      USING    fp_enh_status
                                    CHANGING fp_header.
ENDFORM. " F_POPULATE_HEADER
*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_DATE_FORMAT
*&---------------------------------------------------------------------*
*       Convert date format
*----------------------------------------------------------------------*
*      -->FP_DATE   Input date format
*      -->FP_LANGU  Language
*      <--FP_DATE_CHAR  Output date format
*----------------------------------------------------------------------*
FORM f_convert_date_format  USING    fp_date   TYPE dats       " Field of type DATS
                                     fp_langu TYPE langu       " Language Key
                            CHANGING fp_date_char TYPE char15. " Date_char of type CHAR15

  CONSTANTS: lc_format TYPE char15 VALUE 'DD-MMM-YYYY'. " Format of type CHAR15

  IF fp_date IS NOT INITIAL.
    CALL FUNCTION 'ZDEV_DATE_FORMAT'
      EXPORTING
        i_date       = fp_date
        i_format     = lc_format
        i_langu      = fp_langu
      IMPORTING
        e_date_final = fp_date_char.
  ENDIF. " IF fp_date IS NOT INITIAL


ENDFORM. " F_CONVERT_DATE_FORMAT
*&---------------------------------------------------------------------*
*&      Form  F_GET_INV_DETAIL
*&---------------------------------------------------------------------*
*       get invoice details
*----------------------------------------------------------------------*
*      -->FP_BIL_PRT_COM  Billing Document: Interface Structure for Adobe Print
*      <--FP_CURRENCY     Document currency
*      <--FP_VBDKR        Document Header View for Billing
*      <--FP_TVKO         Organizational Unit: Sales Organizations
*      <--FP_VBDPR   Document Item data for Billing
*----------------------------------------------------------------------*
FORM f_get_inv_detail USING    fp_bil_prt_com TYPE invoice_s_prt_interface " Billing Document: Interface Structure for Adobe Print
                      CHANGING fp_currency    TYPE waerk                   " SD Document Currency
                               fp_vbdkr       TYPE vbdkr                   " Document Header View for Billing
                               fp_tvko        TYPE tvko                    " Organizational Unit: Sales Organizations
                               fp_vbdpr       TYPE tbl_vbdpr.

  DATA: lwa_vbdpr TYPE vbdpr. " Document Item View for Billing

  FIELD-SYMBOLS: <lfs_item_detail> TYPE invoice_s_prt_item_detail. " Items Detail for PDF Print

  fp_currency = fp_bil_prt_com-head_detail-doc_currency.
  fp_vbdkr    = fp_bil_prt_com-head_detail-vbdkr.
  fp_tvko     = fp_bil_prt_com-head_detail-tvko.

  LOOP AT fp_bil_prt_com-item_detail ASSIGNING <lfs_item_detail>.

    lwa_vbdpr = <lfs_item_detail>-vbdpr.
    APPEND lwa_vbdpr TO fp_vbdpr.

  ENDLOOP. " LOOP AT fp_bil_prt_com-item_detail ASSIGNING <lfs_item_detail>

ENDFORM. " F_GET_IN_ITEM
*&---------------------------------------------------------------------*
*&      Form  F_GET_ORIGINAL_INVOICE
*&---------------------------------------------------------------------*
*       Original Invoice
*----------------------------------------------------------------------*
*      -->FP_VBDPR   Document Item data for Billing
*      -->FP_VBFA    Sales Document Flow
*      <--FP_HEADER  Proforma invoice form header structure
*----------------------------------------------------------------------*
FORM f_get_original_invoice  USING    fp_vbdpr  TYPE tbl_vbdpr
                                      fp_vbfa   TYPE ty_t_vbfa
                             CHANGING fp_header TYPE zotc_proforma_header. " Proforma invoice form header structure

  DATA: lwa_vbfa  TYPE ty_vbfa.

  FIELD-SYMBOLS: <lfs_vbdpr> TYPE vbdpr. " Document Item View for Billing

  LOOP AT fp_vbdpr ASSIGNING <lfs_vbdpr>.

    READ TABLE fp_vbfa INTO lwa_vbfa
                       WITH KEY vbelv = <lfs_vbdpr>-vbeln_vauf
                                posnv = <lfs_vbdpr>-posnr_vauf
                       BINARY SEARCH.
    IF sy-subrc = 0.
      fp_header-org_invoice = lwa_vbfa-vbeln.
      EXIT.
    ENDIF. " IF sy-subrc = 0

  ENDLOOP. " LOOP AT fp_vbdpr ASSIGNING <lfs_vbdpr>

ENDFORM. " F_GET_ORIGINAL_INVOICE
*&---------------------------------------------------------------------*
*&      Form  F_FILL_STANDARD_TEXT
*&---------------------------------------------------------------------*
*       Fill standard textnames in header structure
*----------------------------------------------------------------------*
*      -->FP_ENH_STATUS Enhancement status
*      <--FP_HEADER  Proforma invoice form header structure
*----------------------------------------------------------------------*
FORM f_fill_standard_text  USING    fp_enh_status TYPE zdev_tt_enh_status
                           CHANGING fp_header TYPE zotc_proforma_header. " Proforma invoice form header structure

  DATA: li_stxh         TYPE STANDARD TABLE OF ty_stxh,
        lwa_enh_status  TYPE zdev_enh_status. " Enhancement Status

  FIELD-SYMBOLS: <lfs_stxh> TYPE ty_stxh.

  CONSTANTS: lc_phone_cs    TYPE char25 VALUE 'ZOTC_0014_D3_PHONE_CS_',    " Phone_cs of type CHAR25
             lc_email_cs    TYPE char25 VALUE 'ZOTC_0014_D3_EMAIL_CS_',    " Email_cs of type CHAR25
             lc_tcsales     TYPE char25 VALUE 'ZOTC_0014_D3_TCSALES_',     " Tcsales of type CHAR25
             lc_ltext_sales TYPE char25 VALUE 'ZOTC_0014_D3_LTEXT_SALES_', " Ltext_sales of type CHAR25
             lc_payment     TYPE char25 VALUE 'ZOTC_0014_D3_PAYMENT_',     " Payment of type CHAR25
             lc_tdobj_text  TYPE tdobject   VALUE 'TEXT',                  " Texts: Application Object
             lc_tdid_st     TYPE tdid       VALUE 'ST',                    " Text ID
             lc_vkorg       TYPE z_criteria VALUE 'VKORG',                 " Enh. Criteria
             lc_pf_dp       TYPE char10     VALUE '_PF_DP',                " Pf_dp of type CHAR10
* Begin of Insert for Defect_5657 by ASHARMA8
             lc_tdobj_vbbk  TYPE tdobject   VALUE 'VBBK', " Texts: Application Object
             lc_tdid_z006   TYPE tdid       VALUE 'Z006', " Text ID
             lc_tdid_z009   TYPE tdid       VALUE 'Z009', " Text ID
* End of Insert for Defect_5657 by ASHARMA8
* --->Begin of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018
             lc_weee       TYPE char25      VALUE 'ZOTC_0014_D3_WEEE_', " Ltext_sales of type CHAR25
             lc_i          TYPE tvarv_sign  VALUE 'I',                  "ABAP: ID: I/E (include/exclude values)
             lc_eq         TYPE tvarv_opti  VALUE 'EQ',                 " ABAP: Selection option (EQ/BT/CP/...)
             lc_vkorg_cuu  TYPE z_criteria  VALUE 'VKORG_CUU_AR',       " Enh. Criteria
             lc_tdid_z010  TYPE tdid        VALUE 'Z010',               " Text ID
             lc_tdid_z011  TYPE tdid        VALUE 'Z011'.               " Text ID

  DATA: li_enh_status TYPE zdev_tt_enh_status,
        li_cuu        TYPE RANGE OF vkorg, " Sales Organization
        lwa_cuu       LIKE LINE OF li_cuu.

*** Internal table
  li_enh_status[] = fp_enh_status[].
  DELETE li_enh_status WHERE criteria NE lc_vkorg_cuu.
  DELETE li_enh_status WHERE active IS INITIAL.

  IF li_enh_status IS NOT INITIAL.
** Store sales org for which CUU/AR no needs to print
    LOOP AT  li_enh_status INTO lwa_enh_status.
      lwa_cuu-low    = lwa_enh_status-sel_low.
      lwa_cuu-sign   = lc_i.
      lwa_cuu-option = lc_eq.
      APPEND lwa_cuu TO li_cuu.
      CLEAR: lwa_cuu.
    ENDLOOP. " LOOP AT li_enh_status INTO lwa_enh_status
  ENDIF. " IF li_enh_status IS NOT INITIAL

* Standard text for WEEE
  CONCATENATE lc_weee
              fp_header-vkorg
         INTO fp_header-weee.
* <---End of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018

* Begin of Delete for CR D3_301_Part2 by ASHARMA8
* Condition for sales org 1024/2000 is removed
*  READ TABLE fp_enh_status INTO lwa_enh_status
*                           WITH KEY criteria = lc_vkorg
*                                    sel_low  = fp_header-vkorg
*                           BINARY SEARCH.
*  IF sy-subrc = 0.
** In case sales org is 1024/2000, then use sales office
** Standard text for customer service phone
*    IF fp_header-cs_logo IS INITIAL.
*      CONCATENATE lc_phone_cs
*                  fp_header-vkbur
*             INTO fp_header-cust_service_tel.
*    ENDIF. " IF fp_header-cs_logo IS INITIAL
*
** Standard text for customer service email
*    CONCATENATE lc_email_cs
*                fp_header-vkbur
*           INTO fp_header-cust_service_email.
*
** Begin of Insert for Defect_5595 by ASHARMA8
** In case sales org is not 1024/2000, then use sales org instead of sales office
*
*  ELSE. " ELSE -> IF sy-subrc = 0
*
* End of Delete for CR D3_301_Part2 by ASHARMA8

* Standard text for customer service phone with sales org
  IF fp_header-cs_logo IS INITIAL.
    CONCATENATE lc_phone_cs
                fp_header-vkorg
           INTO fp_header-cust_service_tel.
  ENDIF. " IF fp_header-cs_logo IS INITIAL

* Standard text for customer service email with sales org
  CONCATENATE lc_email_cs
              fp_header-vkorg
         INTO fp_header-cust_service_email.
* End of Insert for Defect_5595 by ASHARMA8

* Begin of Delete for CR D3_301_Part2 by ASHARMA8
*  ENDIF. " IF sy-subrc = 0
* End of Delete for CR D3_301_Part2 by ASHARMA8

  CONCATENATE lc_tcsales
              fp_header-bukrs
         INTO fp_header-terms_n_condition.

  CONCATENATE lc_ltext_sales
              fp_header-bukrs
         INTO fp_header-sales_org_info.

  CONCATENATE lc_payment
              fp_header-bukrs
              lc_pf_dp
         INTO fp_header-payment_text1.

  CONCATENATE lc_payment
              fp_header-bukrs
         INTO fp_header-payment_text2.

* Begin of delete for Defect_5657 by ASHARMA8
*  SELECT tdname  " Name
*         tdspras " Language Key
*    FROM stxh    " STXD SAPscript text file header
*    INTO TABLE li_stxh
*    WHERE tdobject = lc_tdobj_text
*      AND tdname   IN (fp_header-terms_n_condition,
*                       fp_header-sales_org_info,
*                       fp_header-payment_text1,
*                       fp_header-payment_text2)
*      AND tdid      = lc_tdid_st.
*  IF sy-subrc NE 0.
*    CLEAR li_stxh.
*  ENDIF. " IF sy-subrc NE 0
* End of Delete for Defect_5657 by ASHARMA8

* Begin of Insert for Defect_5657 by ASHARMA8
  SELECT tdobject " Texts: Application Object
         tdname   " Name
         tdid     " Text ID
         tdspras  " Language Key
    FROM stxh     " STXD SAPscript text file header
    INTO TABLE li_stxh
    WHERE tdobject IN (lc_tdobj_text,
                       lc_tdobj_vbbk)
      AND tdname   IN (fp_header-terms_n_condition,
                       fp_header-sales_org_info,
                       fp_header-payment_text1,
                       fp_header-payment_text2,
* --->Begin of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018
                       fp_header-weee,
* <---End of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018
                       fp_header-vbeln)
      AND tdid     IN (lc_tdid_st,
                       lc_tdid_z006,
                       lc_tdid_z009,
* --->Begin of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018
                       lc_tdid_z010,
                       lc_tdid_z011
* <---End of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018
    ).
  IF sy-subrc NE 0.
    CLEAR li_stxh.
  ENDIF. " IF sy-subrc NE 0

* End of Insert for Defect_5657 by ASHARMA8
  LOOP AT li_stxh ASSIGNING <lfs_stxh>.

    CASE <lfs_stxh>-tdname.

      WHEN fp_header-terms_n_condition.
        fp_header-terms_langu = <lfs_stxh>-tdspras.

      WHEN fp_header-sales_org_info.
        fp_header-salesinfo_langu = <lfs_stxh>-tdspras.

      WHEN fp_header-payment_text1.
        fp_header-paytext1_langu = <lfs_stxh>-tdspras.

      WHEN fp_header-payment_text2.
        fp_header-paytext2_langu = <lfs_stxh>-tdspras.

* Begin of Insert for Defect_5657 by ASHARMA8
      WHEN fp_header-vbeln.
        IF <lfs_stxh>-tdid = lc_tdid_z006
          AND  <lfs_stxh>-tdspras = fp_header-langu.
          fp_header-disp_z006_flag = abap_true.

        ENDIF. " IF <lfs_stxh>-tdid = lc_tdid_z006
        IF <lfs_stxh>-tdid = lc_tdid_z009
           AND  <lfs_stxh>-tdspras = fp_header-langu.
          fp_header-disp_z009_flag = abap_true.

        ENDIF. " IF <lfs_stxh>-tdid = lc_tdid_z009
* End of Insert for Defect_5657 by ASHARMA8

* --->Begin of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018
        IF <lfs_stxh>-tdid = lc_tdid_z010.
          IF fp_header-vkorg IN li_cuu[].
            fp_header-disp_z010_flag = abap_true.
          ENDIF. " IF fp_header-vkorg IN li_cuu[]
        ENDIF. " IF <lfs_stxh>-tdid = lc_tdid_z010

        IF <lfs_stxh>-tdid = lc_tdid_z011.
          IF fp_header-vkorg IN li_cuu[].
            fp_header-disp_z011_flag = abap_true.
          ENDIF. " IF fp_header-vkorg IN li_cuu[]
        ENDIF. " IF <lfs_stxh>-tdid = lc_tdid_z011

      WHEN fp_header-weee.
        fp_header-weee_langu = <lfs_stxh>-tdspras.
* <---End of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018

      WHEN OTHERS.

    ENDCASE.

  ENDLOOP. " LOOP AT li_stxh ASSIGNING <lfs_stxh>
  FREE: li_stxh.

* --->Begin of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018
  FREE: li_cuu[],
        li_enh_status[].
* <---End of Insert for D3_R3 for D3_OTC_FDD_0088 by MGARG on 06-Feb-2018

ENDFORM. " F_FILL_STANDARD_TEXT
*&---------------------------------------------------------------------*
*&      Form  F_GET_COMPCODE_DATA
*&---------------------------------------------------------------------*
*       Get company code data
*----------------------------------------------------------------------*
*      -->FP_BUKRS   Company code
*      <--FP_HEADER  Proforma invoice form header structure
*----------------------------------------------------------------------*
FORM f_get_compcode_data  USING    fp_bukrs   TYPE bukrs                 " Company Code
                          CHANGING fp_header  TYPE zotc_proforma_header. " Proforma invoice form header structure

  SELECT SINGLE land1 " Country Key
    FROM t001         " Company Codes
    INTO fp_header-compcode_ctry
    WHERE bukrs = fp_bukrs.
  IF sy-subrc NE 0.
    CLEAR fp_header-compcode_ctry.
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_GET_COMPCODE_DATA
*&---------------------------------------------------------------------*
*&      Form  F_FILL_BOM_COMPONENTS
*&---------------------------------------------------------------------*
*       Fill BOM components
*----------------------------------------------------------------------*
*      -->FP_LANGU    Language key
*      -->FP_VBDPR    Document Item data for Billing
*      -->FP_ITEMS    Invoice item details
*      -->FP_SER02    Document Header for Serial Nos for Maint.Contract (SD Order)
*      -->FP_OBJK     Plant Maintenance Object List
*      -->FP_KONV     Conditions (Transaction Data)
*      -->FP_LIPS     Delivery item data
*      <--FP_SUBTOTAL Subtotal amount
*      <--FP_BOM_COMPONENTS BOM components
*----------------------------------------------------------------------*
FORM f_fill_bom_components  USING    fp_langu TYPE langu " Language Key
                                     fp_vbdpr TYPE vbdpr " Document Item View for Billing
                                     fp_items TYPE tbl_vbdpr
                                     fp_ser02 TYPE ty_t_ser02
                                     fp_objk  TYPE ty_t_objk
* Begin of Delete for Defect_5741 by ASHARMA8
*                                     fp_konv  TYPE ty_t_konv
* End of Delete for Defect_5741 by ASHARMA8
                                     fp_lips  TYPE ty_t_lips
                            CHANGING fp_subtotal       TYPE kzwi1 " Subtotal 1 from pricing procedure for condition
                                     fp_bom_components TYPE zotc_t_proforma_bom.

  DATA: li_vbdpr_bom  TYPE tbl_vbdpr,
        lwa_lips      TYPE ty_lips,
* Begin of Delete for Defect_5741 by ASHARMA8
*        lwa_konv      TYPE ty_konv,
*        lv_kbetr      TYPE kbetr.             " Rate (condition amount or percentage)
* End of Delete for Defect_5741 by ASHARMA8
        lwa_bom       TYPE zotc_proforma_bom. " Proforma invoice - bom components of item

  FIELD-SYMBOLS: <lfs_vbdpr> TYPE vbdpr. " Document Item View for Billing

* Begin of Delete for Defect_5741 by ASHARMA8
*  CONSTANTS: lc_tax     TYPE koaid VALUE 'D', " Condition class
*             lc_percent TYPE char1 VALUE '%'. " Percent of type CHAR1
* End of Delete for Defect_5741 by ASHARMA8

  li_vbdpr_bom[] = fp_items[].
  DELETE li_vbdpr_bom WHERE uepos NE fp_vbdpr-posnr.

  LOOP AT li_vbdpr_bom ASSIGNING <lfs_vbdpr>.

    lwa_bom-matnr = <lfs_vbdpr>-matnr.
    lwa_bom-arktx = <lfs_vbdpr>-arktx.

* Begin of Delete for Defect_5741 by ASHARMA8
** Rate
*    READ TABLE fp_konv INTO lwa_konv
*                       WITH KEY kposn = <lfs_vbdpr>-posnr
*                                koaid = lc_tax.
*    IF sy-subrc = 0.
*      lv_kbetr = lwa_konv-kbetr / 10.
*      WRITE lv_kbetr TO lwa_bom-kbetr_char CURRENCY lc_percent.
*      CONCATENATE lwa_bom-kbetr_char
*                  lc_percent
*             INTO lwa_bom-kbetr_char.
*    ENDIF. " IF sy-subrc = 0
* End of Delete for Defect_5741 by ASHARMA8

* Unit price
    IF <lfs_vbdpr>-fkimg IS NOT INITIAL.
      WRITE: <lfs_vbdpr>-fkimg  TO lwa_bom-fkimg_char      UNIT     <lfs_vbdpr>-vrkme.
      CONDENSE lwa_bom-fkimg_char.
    ENDIF. " IF <lfs_vbdpr>-fkimg IS NOT INITIAL

* Quantity UoM
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input          = <lfs_vbdpr>-vrkme
        language       = fp_langu
      IMPORTING
        output         = lwa_bom-vrkme
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      lwa_bom-vrkme = <lfs_vbdpr>-vrkme.
    ENDIF. " IF sy-subrc <> 0

* Subtotal
    fp_subtotal = fp_subtotal + <lfs_vbdpr>-kzwi1.

* Batch
    IF <lfs_vbdpr>-xchar = abap_true.
      lwa_bom-charg = <lfs_vbdpr>-charg.
      READ TABLE fp_lips INTO lwa_lips
                           WITH KEY vbeln = <lfs_vbdpr>-vgbel
                                    posnr = <lfs_vbdpr>-vgpos
                           BINARY SEARCH.
      IF sy-subrc = 0
        AND lwa_lips-vfdat IS NOT INITIAL.
        PERFORM f_convert_date_format USING lwa_lips-vfdat
                                            fp_langu
                                      CHANGING lwa_bom-vfdat_char.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF <lfs_vbdpr>-xchar = abap_true

* serial numbers
    PERFORM f_get_serial_numbers USING <lfs_vbdpr>-vgbel
                                       <lfs_vbdpr>-vgpos
                                       fp_ser02
                                       fp_objk
                                 CHANGING lwa_bom-serialno.

    APPEND lwa_bom TO fp_bom_components.
    CLEAR lwa_bom.

  ENDLOOP. " LOOP AT li_vbdpr_bom ASSIGNING <lfs_vbdpr>

ENDFORM. " F_FILL_BOM_COMPONENTS
* Begin of Insert for Defect_5676 by ASHARMA8
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_HEADER
*&---------------------------------------------------------------------*
*       Update header structure
*----------------------------------------------------------------------*
*      <--FP_HEADER  Proforma invoice form header structure
*----------------------------------------------------------------------*
FORM f_update_header  CHANGING fp_header  TYPE zotc_proforma_header. " Proforma invoice form header structure

  DATA: lv_total_amt  TYPE netwr. " Net Value in Document Currency

* Net amount
  WRITE fp_header-netwr TO fp_header-netwr_char CURRENCY fp_header-waerk.

* Tax amount
  WRITE fp_header-mwsbk TO fp_header-mwsbk_char CURRENCY fp_header-waerk.

* Total amount
  lv_total_amt = fp_header-netwr + fp_header-mwsbk.

  WRITE lv_total_amt    TO fp_header-total_amt  CURRENCY fp_header-waerk.


ENDFORM. " F_UPDATE_HEADER
* End of Insert for Defect_5676 by ASHARMA8
