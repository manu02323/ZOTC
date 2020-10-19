FUNCTION zotc0016_dunning_notice_pdf.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MAHNV) LIKE  MAHNV STRUCTURE  MAHNV
*"     VALUE(I_F150V) LIKE  F150V STRUCTURE  F150V
*"     VALUE(I_F150D2) LIKE  F150D2 STRUCTURE  F150D2 OPTIONAL
*"     VALUE(I_MHNK) LIKE  MHNK STRUCTURE  MHNK
*"     VALUE(I_ITCPO) LIKE  ITCPO STRUCTURE  ITCPO
*"     VALUE(I_UPDATE) TYPE  C DEFAULT SPACE
*"     VALUE(I_MOUT) LIKE  BOOLE-BOOLE DEFAULT SPACE
*"     VALUE(I_OFI) LIKE  BOOLE-BOOLE DEFAULT 'X'
*"  TABLES
*"      T_MHND STRUCTURE  MHND
*"      T_FIMSG STRUCTURE  FIMSG OPTIONAL
*"  CHANGING
*"     VALUE(E_COMREQ) LIKE  BOOLE-BOOLE
*"  EXCEPTIONS
*"      PARAM_ERROR
*"      ACCNT_BLOCK
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
* PDF Form CONVERSION FOR : PRINT_DUNNING_NOTICE_PDF                   *
* Author                  : Kishore MVR (C5056320)                     *
* Date                     : 30/08/2004                                *
* Program description     : Modified Function Module for printing the  *
*                           Dunning forms                              *
* Form Name               : F150_DUNN_SF                               *
*----------------------------------------------------------------------*

************************************************************************
* Function Module : ZOTC0016_DUNNING_NOTICE_PDF                        *
* TITLE      : OTC_FDD_0016: Sending Dunning Notice                    *
* DEVELOPER  : Gautam NAG                                              *
* OBJECT TYPE: Function Module                                         *
* SAP RELEASE: SAP ECC 6.0                                             *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_FDD_0016                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: This is the the copy of the std function module         *
* PRINT_DUNNING_NOTICE_PDF. This is to incorporate the email sending   *
* functionality. All the code changes are tagged with the TR number    *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 09-MAY-2012 GNAG     E1DK901269 INITIAL DEVELOPMENT                  *
* 13-Nov-2014 JAHAN    E2DK906609 D2_OTC_FDD_0016 Changes              *
* 10-Jan-2015 VGAUR    E2DK906453 CR# D2_390                           *
* 20-Oct-2016 RBANERJ1/Arpita  E1DK922552  D3_OTC_FDD_0016             *
* 1. Set D3 flag if there is no lockbox entry for the company.
* 2. Get remit address using Sales Org address
* 3. Get the House bank detail using FM ZOTC_GET_HOUSEBANKINFO.
*&---------------------------------------------------------------------*
* 29-Dec-2016 U033867  E1DK922552    CR#301:Add company VAT No         *
*                                          into the header of the form *
*                                          Print multiple bank account *
*                                          Add page no as “Page:x / y” *
*&---------------------------------------------------------------------*
* Begin of change - GNAG E1DK901269
  CONSTANTS:
    lc_dev_msg   TYPE symsgid VALUE 'ZDEV_MSG', "Dev Message Class
    lc_error     TYPE symsgty VALUE 'E',        "Error
    lc_msgno_003 TYPE msgtyp  VALUE '003',      "Message No.
    lc_int       TYPE ad_comm VALUE 'INT'.      "Communiaction Type Mail

  DATA: lv_cust_adrnr TYPE adrnr,     "Customer Address
        lv_cust_name  TYPE name1_gp,  "Name1
        lv_kunnr      TYPE kunnr,     "Customer Number
        lv_comm_type  TYPE ad_comm,   "Default Communication Type
        li_text       TYPE bcsy_text, "Mail body
        lwa_text      TYPE soli.      "Mail body
* End of change - GNAG E1DK901269

  DATA: langu     LIKE sy-langu,           "Language of the master record
        lang2     LIKE sy-langu,           "Language of the form (second guess)
        incl_item LIKE boole-boole,        "include item in dunning letter?
        incl_mhnk LIKE boole-boole,        " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
        i_itcpp   LIKE itcpp,              "Sapscript return structure
        h_msgno   LIKE sy-msgno,           " Message Number
        h_archive_index   LIKE toa_dara,   " SAP ArchiveLink structure of a DARA line
        h_archive_params  LIKE arc_params. " ImageLink structure

  DATA: fp_docparams TYPE sfpdocparams. "1460038
*************** Start of PDF Conversion, Date:19/07/2004, I029678
* Declarations.
  DATA: lv_form_name       TYPE fpname,          " Name of Form Object
        lv_fm_name         TYPE funcname,        " Function name
        ls_fp_outputparams TYPE sfpoutputparams, " Form Processing Output Parameter
        lp_cx_root         TYPE REF TO cx_root,  " Abstract Superclass for All Global Exceptions
        lv_error_mssg      TYPE string.
  STATICS ls_fp_outputparams_last TYPE sfpoutputparams. " Form Processing Output Parameter

  DATA: lv_show_interest   TYPE tdbool,     " Checkbox (yes or no)
        lv_incl_item       TYPE boole_d,    " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
        lv_smschl_before   TYPE mschl_mhnd, " Dunning key if separate printout is active; otherwise blank
*        lth_mhnd        TYPE fin_f150_dunn_ty_mhnd_pdf WITH HEADER LINE,   "By Jahan for D2_OTC_FDD_0016
* Begin of change for D2_OTC_FDD_0016 by Jahan
        lth_mhnd           TYPE fin_f150_dunn_sf_t_mhnd_pdf WITH HEADER LINE, "By Jahan  for D2_OTC_FDD_0016
* End of change for D2_OTC_FDD_0016 by Jahan
        ls_sumtab          LIKE sumtab,                            " FI-SL summary table
        lt_sumtab          LIKE sumtab OCCURS 0,                   " FI-SL summary table
        lt_saltab          LIKE fin_f150_dunn_saltab_pdf OCCURS 0, " Dunning Notice: Structure for PDF Output
        ls_saltab          LIKE fin_f150_dunn_saltab_pdf,          " Dunning Notice: Structure for PDF Output
        lv_recnt           LIKE sy-tabix,                          " Index of Internal Tables
        lv_recs            TYPE boole_d.                           " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')

  DATA: ls_t040a TYPE t040a, " Dunning key names
        ls_bkpf  TYPE bkpf,  " Accounting Document Header
        ls_bseg  TYPE bseg,  " Accounting Document Segment
        ls_bsec  TYPE bsec.  " One-Time Account Data Document Segment
*************** End of PDF Conversion, Date:19/07/2004, I029678
  DATA: ld_answer      TYPE c,                       "1460038
        lb_send        TYPE c,                       "1460038
        lb_archive     TYPE c,                       "1554240
        ld_device      TYPE tddevice,                "1460038
        lt_mail_recip  TYPE TABLE OF somlreci1,      "1460038
        lt_fax_recip   TYPE TABLE OF somlreci1,      "1460038
        ls_dkadr       TYPE dkadr,                   "1460038
        ld_sender      TYPE so_rec_ext,              "1460038
        ld_sender_type TYPE so_adr_typ,              "1460038
        ls_message     TYPE balmt,                   "1460038
        lt_messages    TYPE STANDARD TABLE OF balmt, "1460038
        ls_formoutput  TYPE fpformoutput.            "1460038

* ---> Begin of Insert for CR# D2_390 by VGAUR
  CONSTANTS:
    lc_id             TYPE tdid          VALUE 'ST',                       " Material-sales text
    lc_object         TYPE tdobject      VALUE 'TEXT',                     " Order item text
    lc_name1          TYPE tdobname      VALUE 'ZOTC_FDD_ACCOUNT_PESOS',   " Name
    lc_name2          TYPE tdobname      VALUE 'ZOTC_FDD_ACCOUNT_DOLLARS', " Name
    lc_spanish        TYPE sylangu       VALUE 'S',                        " Spanish Language
    lc_enhancement_no TYPE z_enhancement VALUE 'D2_OTC_FDD_0016',          " Enhancement No.
    lc_bukrs          TYPE z_criteria    VALUE 'BUKRS',                    " Enh. Criteria
    lc_null           TYPE z_criteria    VALUE 'NULL',                     " Enh. Criteria
    lc_remit_field    TYPE string        VALUE 'LV_REMIT_TO_l'.            " Remit field name

  DATA:
    li_status         TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
    li_lines          TYPE STANDARD TABLE OF tline            " SAPscript: Text Lines
                           INITIAL SIZE 0,
*Begin of change for CR#301 by U033867
    li_housebank      TYPE zotc_t_housebank,
*End of change for CR#301 by U033867
    lx_org_address    TYPE zotc_company_address,              " Company Address
    lv_remit_to_l1    TYPE string,                            " For non 1103 company code
    lv_remit_to_l2    TYPE string,                            " For non 1103 company code
    lv_remit_to_l3    TYPE string,                            " For non 1103 company code
    lv_remit_to_l4    TYPE string,                            " For non 1103 company code
    lv_remit_to_l5    TYPE string,                            " For non 1103 company code
    lv_lines1         TYPE string,                            " Address Line
    lv_lines2         TYPE string,                            " Address Line
    lv_lines3         TYPE string,                            " Address Line
    lv_lines4         TYPE string,                            " Address Line
    lv_lines5         TYPE string,                            " Address Line
    lv_lines6         TYPE string,                            " Address Line
    lv_lines7         TYPE string,                            " Address Line
    lv_lines8         TYPE string,                            " Address Line
    lv_city           TYPE string,                            " City
    lv_street_hnum    TYPE string,                            " Street and house no
    lv_pobox          TYPE string,                            " PO box
    lv_field_name     TYPE string,                            " field name
    lv_comp_adrnr     TYPE adrnr,                             " Company Address
    lv_index          TYPE char_02,                           " Line couner
*---> Begin of D2 Change of object D2_OTC_FDD_0013 BY NBAIS.
       gv_langu_bi   TYPE spras. " Language Key
*<--- End of D2 change for object D2_OTC_FDD_0013 BY NBAIS.

  FIELD-SYMBOLS:
    <lfs_status>      TYPE zdev_enh_status, " Enhancement Status
    <lfs_lines>       TYPE tline,           " SAPscript: Text Lines
    <lfs_address>     TYPE string.          " Address line
* <--- End of Insert for CR# D2_390 by VGAUR
* ---> Begin of Insert for D3_OTC_FDD_0016 by RBANERJ1/Arpita
  CONSTANTS: lc_comma          TYPE char01  VALUE ','. " Comma
  DATA: lv_d3_flag TYPE char1 VALUE IS INITIAL,      " D3_flag of type CHAR1
        lv_tvko_adrnr  TYPE adrnr VALUE IS INITIAL,  "Address from Sales Organisation
        lv_tvko_country TYPE land1 VALUE IS INITIAL, " Country Key
        lv_tlfxs       TYPE tlfxs VALUE IS INITIAL,  " Accounting clerk's fax number at the customer/vendor
        lv_intad       TYPE intad VALUE IS INITIAL,  " Internet address of partner company clerk
        lv_housebank_line2  TYPE string,
        lx_housebank_info   TYPE zotc_housebank.     " Structure for House Bank Info
* <--- End of Insert for D3_OTC_FDD_0016 by RBANERJ1/Arpita
  i_itcpo-tdprogram = sy-repid.
* init the log tables
  CALL FUNCTION 'FI_MESSAGE_INIT'.

* set the enable flag for the open fi interface
  use_ofi = i_ofi.

* init the print variable Print Structure and archive defaults
  f150d2           = i_f150d2.
  h_archive_index  = space.
  h_archive_params = space.

* init ddic structures for printing and reading
  PERFORM init_print USING i_mhnk i_f150v.

* log the beginning of the dunning print
  IF i_update = 'X'. h_msgno = '458'. ELSE. h_msgno = '459'. ENDIF.
  IF 1 = 0. MESSAGE s458. ENDIF.
  IF 1 = 0. MESSAGE s459. ENDIF.
  IF i_mhnk-koart = 'D'.
    PERFORM log_msg USING h_msgno i_mhnk-koart i_mhnk-kunnr space space.
  ELSE. " ELSE -> IF i_mhnk-koart = 'D'
    PERFORM log_msg USING h_msgno i_mhnk-koart i_mhnk-lifnr space space.
  ENDIF. " IF i_mhnk-koart = 'D'

* check the mhnk and mhnd entries if item is to be dunned
  PERFORM check_dunning_data TABLES   t_mhnd
                             USING    i_mhnk
                             CHANGING incl_mhnk.
*  CHECK INCL_MHNK = 'X'.
  IF incl_mhnk EQ space.
    RAISE accnt_block.
  ENDIF. " IF incl_mhnk EQ space

* read all necessary customizing information
  CALL FUNCTION 'GET_DUNNING_CUSTOMIZING'
    EXPORTING
      i_mhnk            = i_mhnk
    IMPORTING
      e_t001            = t001
      e_t047            = t047
      e_t047a           = t047a
      e_t047b           = t047b
      e_t047c           = t047c
      e_t047d           = t047d
      e_t047e           = t047e
      e_t047i           = t047i
      e_t056z           = t056z
      e_t021m           = t021m
    CHANGING
      c_f150d           = f150d
    EXCEPTIONS
      param_error_t001  = 1
      param_error_t047  = 2
      param_error_t047a = 3
      param_error_t047b = 4
      param_error_t047d = 5
      param_error_t047e = 6
      OTHERS            = 7.
  IF sy-subrc <> 0.
    PERFORM log_symsg.
    RAISE param_error.
  ENDIF. " IF sy-subrc <> 0

* read all the necessary data for customers or vendors
  CALL FUNCTION 'GET_DUNNING_DATA_CUST_VEND'
    EXPORTING
      i_t001  = t001
      i_mhnk  = i_mhnk
    IMPORTING
      e_adrs  = adrs
      e_uadrs = *adrs
      e_sadr  = sadr
      e_t001s = t001s
      e_fsabe = fsabe
      e_langu = langu
      e_kna1  = kna1
      e_lfa1  = lfa1
      e_knb1  = knb1
      e_lfb1  = lfb1
      e_knb5  = knb5
      e_lfb5  = lfb5
    TABLES
      t_mhnd  = t_mhnd
    CHANGING
      c_f150d = f150d
    EXCEPTIONS
      OTHERS  = 0.

* sort the mhnd entries by the values in t021m.
  CALL FUNCTION 'SORT_MHND'
    EXPORTING
      i_t021m = t021m
    TABLES
      t_mhnd  = t_mhnd
    EXCEPTIONS
      OTHERS  = 0.
* calculate the due date of the dunning notice regarding holidays
  PERFORM calculate_holidays   USING    i_mhnk t047a t047b
                               CHANGING f150d.
* complete f150d with previus calculated values
  PERFORM complete_f150d       USING    i_mhnk t001
                               CHANGING f150d.
* init the update information
  PERFORM init_account_update  TABLES   updbel
                               USING    i_mhnk t047 knb1 lfb1
                               CHANGING updkto updver.
* Userexit 001 determine output method. This user exit should not be
* used anymore. Use Open FI Process 00001040 to determine output
  PERFORM exit_001_para(sapf150d) USING    kna1 knb1
                                           lfa1 lfb1 i_mhnk t047e
                                  CHANGING finaa.
* Open FI Interface determine output method and save in finaa
  PERFORM ofi_determine_output    USING    kna1 knb1 lfa1 lfb1
                                           i_mhnk i_f150d2 t047e i_ofi
                                           i_update
                                  CHANGING finaa i_itcpo
                                           h_archive_index
                                           h_archive_params.
* determine the output device and test availability
  PERFORM determine_output     USING    i_mhnk
                               CHANGING finaa.
* complete the output information depending on output message
  PERFORM complete_output_info USING    t001 adrs sadr fsabe t047i langu
                                         CHANGING finaa i_itcpo itcfx.
* fill printing/fax/mail-relevant parameters for pdf call       "1460038
  PERFORM fill_pdf_system_param TABLES lt_mail_recip             "1460038
                                       lt_fax_recip              "1460038
                                USING  f150v t047e               "1460038
                                CHANGING finaa i_itcpo ld_sender "1460038
                                         ld_sender_type.         "1460038

* create remittance advice in
  PERFORM create_remadv       TABLES   t_mhnd
                              USING    i_update i_mhnk t047b t047e
                              CHANGING i_mhnk-avsid.

* init the payment form
  PERFORM init_payment_struct USING     finaa t047e
                              CHANGING  paymo paymi.

  LOOP AT t_mhnd.
*   check wether the item should be include in the dunning notice or not
    PERFORM check_item           USING    t047b i_mhnk t_mhnd
                                 CHANGING incl_item.

*   init esr procedure
    PERFORM init_esr_line        CHANGING f150d_esr.
    IF incl_item = 'X'.
      PERFORM add_updbel   TABLES updbel USING t_mhnd.
    ENDIF. " IF incl_item = 'X'
  ENDLOOP. " LOOP AT t_mhnd

* calculate and write the dunning charges if applicable
  IF i_mhnk-gmvdt IS INITIAL.
    PERFORM calc_dunning_charges   TABLES   sumtab
                                   USING    t001 t047c
                                   CHANGING f150d.
************ Start of PDF Conversion : Insert : Date:19/07/2004, I029678
    IF NOT sumtab-waers IS INITIAL. "1296772
      COLLECT sumtab INTO lt_sumtab.
    ENDIF. " IF NOT sumtab-waers IS INITIAL
************ End   of PDF Conversion : Insert : Date:19/07/2004, I029678

  ENDIF. " IF i_mhnk-gmvdt IS INITIAL
* check the currency's and patch saltab and sumtab if applicable
  PERFORM check_currency           TABLES   saltab sumtab
                                   USING    t001
                                   CHANGING f150d.

* get name of dunning form

************ Start of PDF Conversion : Insert: Date:19/07/2004, I029678

* Move the form name to the function Module
  lv_form_name = t047e-fornr.

************ End   of PDF Conversion : Insert: Date:19/07/2004, I029678

************ Start of PDF Conversion : Insert: Date:19/07/2004, I029678
  TRY.
* The function module name is retrieved by passing the PDF Form name
      CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
        EXPORTING
          i_name     = lv_form_name
        IMPORTING
          e_funcname = lv_fm_name.
    CATCH cx_root INTO lp_cx_root.
      lv_error_mssg = lp_cx_root->get_text( ).
      MESSAGE e845 WITH lv_error_mssg.
  ENDTRY.

*  DATA sfparam LIKE sfparam.
*************** End   of PDF Conversion, Insert Date:19/07/2004, I029678

* put smartforms-interface data in global memory, the form gets it with
* function call.
  gb_sf_testprint = space.
  IF i_mahnv-xmpri = space AND i_update = space.
    gb_sf_testprint = 'X'.
  ENDIF. " IF i_mahnv-xmpri = space AND i_update = space

  gs_sf_mhnk      = i_mhnk.
  gs_sf_fsabe     = fsabe.
  gs_sf_t047      = t047.
  gs_sf_t047b     = t047b.
  gs_sf_t047c     = t047c.
  gs_sf_t047i     = t047i.
  gs_sf_t056z     = t056z.
  gs_sf_t001      = t001.
  gs_sf_adrs      = adrs.
  gs_sf_uadrs     = *adrs.
  gs_sf_adrnr     = adrnr.
  gs_sf_uadrnr    = uadrnr.
  gs_sf_knb5      = knb5.
  gs_sf_lfb5      = lfb5.
  gt_sf_mhnd[]    = t_mhnd[].
  g_sf_langu      = langu.
  g_sf_lang2      = lang2.
  gs_sf_f150d     = f150d.
  gs_sf_f150d2    = f150d2.
  gs_sf_f150d_esr = f150d_esr.
  gs_sf_paymi     = paymi.
  gs_sf_paymo     = paymo.

  PERFORM fill_outputparams TABLES   lt_mail_recip lt_fax_recip "1460038
                            USING    finaa-nacha i_itcpo        "1460038
                            CHANGING ls_fp_outputparams         "1460038
                                     ld_device lb_send          "1460038
                                     lb_archive.                "1554240
  lv_show_interest = space.
  ls_t040a-text1 = space.
  READ TABLE t_mhnd WITH KEY xzins = space.
  IF sy-subrc EQ 0.
    lv_show_interest = 'X'.
  ELSE. " ELSE -> IF sy-subrc EQ 0
    lv_show_interest = space.
  ENDIF. " IF sy-subrc EQ 0
  LOOP AT t_mhnd.

*   check wether the item should be include in the dunning notice or not
    PERFORM check_item           USING    t047b i_mhnk t_mhnd "1449122
                                 CHANGING incl_item.          "1449122

***collect data into saltab and sumtab
    ls_saltab-waers = t_mhnd-waers.
    ls_saltab-dmshb = t_mhnd-dmshb.
    ls_saltab-wrshb = t_mhnd-wrshb.
    COLLECT ls_saltab INTO lt_saltab.
    IF incl_item = 'X'.
      CLEAR sumtab.
      sumtab-waers = t_mhnd-waers.
      sumtab-wrshb = t_mhnd-wrshb.
      sumtab-dmshb = t_mhnd-dmshb.
      IF t_mhnd-xzins = 'X'. "1633098
        sumtab-wzsbt = 0.
        sumtab-zsbtr = 0.
      ELSE. " ELSE -> IF t_mhnd-xzins = 'X'
        sumtab-wzsbt = t_mhnd-wzsbt.
        sumtab-zsbtr = t_mhnd-zsbtr.
      ENDIF. " IF t_mhnd-xzins = 'X'
      IF t_mhnd-xfael = 'X'. "1296772
        sumtab-ffshb = t_mhnd-wrshb.
        sumtab-fhshb = t_mhnd-dmshb.
      ENDIF. " IF t_mhnd-xfael = 'X'
      COLLECT sumtab INTO lt_sumtab.
    ENDIF. " IF incl_item = 'X'
    IF incl_item EQ 'X'. "1449122
      SELECT SINGLE * FROM bkpf INTO ls_bkpf WHERE
        bukrs EQ t_mhnd-bukrs AND
        gjahr EQ t_mhnd-gjahr AND
        belnr EQ t_mhnd-belnr.
      SELECT SINGLE * FROM bseg INTO ls_bseg WHERE
        bukrs EQ t_mhnd-bukrs AND
        gjahr EQ t_mhnd-gjahr AND
        belnr EQ t_mhnd-belnr AND
        buzei EQ t_mhnd-buzei.
      IF ls_bseg-xcpdd NE space.
        SELECT SINGLE * FROM bsec INTO ls_bsec WHERE
          bukrs EQ t_mhnd-bukrs AND
          gjahr EQ t_mhnd-gjahr AND
          belnr EQ t_mhnd-belnr AND
          buzei EQ t_mhnd-buzei.
      ENDIF. " IF ls_bseg-xcpdd NE space
      IF ls_bseg-sgtxt(1) NE '*'.
        ls_bseg-sgtxt = space.
      ELSE. " ELSE -> IF ls_bseg-sgtxt(1) NE '*'
        SHIFT ls_bseg-sgtxt LEFT BY 1 PLACES.
      ENDIF. " IF ls_bseg-sgtxt(1) NE '*'
      lth_mhnd-sgtxt = ls_bseg-sgtxt.
      IF t_mhnd-smschl   NE lv_smschl_before AND
         lv_smschl_before NE space.
        MOVE ls_t040a-text1 TO lth_mhnd-text_e.
      ENDIF. " IF t_mhnd-smschl NE lv_smschl_before AND
      IF t_mhnd-smschl NE lv_smschl_before AND
         t_mhnd-smschl NE space.
        SELECT SINGLE * FROM t040a INTO ls_t040a
          WHERE spras EQ langu AND
                mschl EQ t_mhnd-mschl.
        IF sy-subrc NE 0.
          IF langu NE lang2.
            SELECT SINGLE * FROM t040a INTO ls_t040a
              WHERE spras EQ lang2 AND
                    mschl EQ t_mhnd-mschl.
          ENDIF. " IF langu NE lang2
          IF sy-subrc NE 0 OR langu EQ lang2.
            SELECT SINGLE * FROM t040a INTO ls_t040a
              WHERE spras EQ lang2 AND
                    mschl EQ sy-langu.
          ENDIF. " IF sy-subrc NE 0 OR langu EQ lang2
        ENDIF. " IF sy-subrc NE 0
        MOVE ls_t040a-text1 TO lth_mhnd-text_s.
      ENDIF. " IF t_mhnd-smschl NE lv_smschl_before AND
      lv_smschl_before = t_mhnd-smschl.
      MOVE-CORRESPONDING t_mhnd TO lth_mhnd.
      APPEND lth_mhnd. CLEAR lth_mhnd.
    ENDIF. " IF incl_item EQ 'X'
  ENDLOOP. " LOOP AT t_mhnd

  READ TABLE lt_sumtab INTO ls_sumtab INDEX 1.

  f150d-waerf = ls_sumtab-waers.
  f150d-supoh = ls_sumtab-dmshb.
  f150d-supof = ls_sumtab-wrshb.
  f150d-sufph = ls_sumtab-fhshb.
  f150d-sufpf = ls_sumtab-ffshb.
  f150d-sufzh = ls_sumtab-fhshb + ls_sumtab-zsbtr.
  f150d-sufzf = ls_sumtab-ffshb + ls_sumtab-wzsbt.
  f150d-suozh = ls_sumtab-dmshb + ls_sumtab-zsbtr.
  f150d-suozf = ls_sumtab-wrshb + ls_sumtab-wzsbt.
  f150d-suzsh = ls_sumtab-zsbtr.
  f150d-suzsf = ls_sumtab-wzsbt.
* CLEAR : LT_SUMTAB, LS_SUMTAB.                                 "1296772

* get all the necessary ESR information if applicable
  IF NOT t047e-zlsch IS INITIAL. "1294091
    PERFORM get_esr_information    TABLES   t_mhnd
                                   USING    i_mhnk f150d
                                   CHANGING bnka sadr f150d_esr.
  ENDIF. " IF NOT t047e-zlsch IS INITIAL
* fill the structure for payment forms
  PERFORM fill_payment_struct TABLES   t_mhnd sumtab
                              USING    finaa i_f150v f150d t047e
                                       i_mhnk adrs
                              CHANGING paymi paymo.
  f150d_esr-mtein =  paymo-esrnr.  f150d_esr-mkodz =  paymo-mkodz.
  f150d_esr-mbetr =  paymo-mbetr.  f150d_esr-mrefn =  paymo-mrefn.


  DESCRIBE TABLE lt_saltab LINES lv_recnt.
  IF lv_recnt > 1.
    lv_recs = 'X'.
  ENDIF. " IF lv_recnt > 1

  IF mhnk-saldo = 0.
    MOVE : t001-waers TO mhnk-waers,
           mhnk-salhw TO mhnk-saldo.
  ENDIF. " IF mhnk-saldo = 0


  IF ls_fp_outputparams <> ls_fp_outputparams_last OR
     gd_pdf_is_open = space.
*   save old value
    ls_fp_outputparams_last = ls_fp_outputparams.
    PERFORM pdf_close. "1460038

* Begin of change - GNAG E1DK901269
    SELECT SINGLE adrnr "Address No.
                  name1 "Name1
      INTO (lv_cust_adrnr, lv_cust_name)
      FROM kna1         " General Data in Customer Master
     WHERE kunnr = i_mhnk-kunnr.
    IF sy-subrc = 0.
*&--Fetch Default Communication Type
      SELECT deflt_comm "Default Communication Type
       UP TO 1 ROWS
        INTO lv_comm_type
        FROM adrc       " Addresses (Business Address Services)
       WHERE addrnumber = lv_cust_adrnr.
      ENDSELECT.
      IF sy-subrc = 0.
*&--If Communication Type is Mail
        IF lv_comm_type = lc_int.
          ls_fp_outputparams-getpdf = 'X'.
        ENDIF. " IF lv_comm_type = lc_int
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0
* End of change - GNAG E1DK901269

    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = ls_fp_outputparams
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE. " ELSE -> IF sy-subrc <> 0
      gd_pdf_is_open = 'X'.
    ENDIF. " IF sy-subrc <> 0

  ENDIF. " IF ls_fp_outputparams <> ls_fp_outputparams_last OR
  IF i_mhnk-koart = 'D'.
    fp_docparams-country = kna1-land1.
    MOVE-CORRESPONDING kna1 TO ls_dkadr. "1460038
    MOVE kna1-kunnr TO ls_dkadr-konto. "1460038
    MOVE-CORRESPONDING knb1 TO ls_dkadr. "1460038
  ELSE. " ELSE -> IF i_mhnk-koart = 'D'
    fp_docparams-country = lfa1-land1.
    MOVE-CORRESPONDING lfa1 TO ls_dkadr. "1460038
    MOVE lfa1-lifnr TO ls_dkadr-konto. "1460038
    MOVE-CORRESPONDING lfb1 TO ls_dkadr. "1460038
  ENDIF. " IF i_mhnk-koart = 'D'
  fp_docparams-langu = langu.
  fp_docparams-replangu1 = sy-langu.
  MOVE t001-land1 TO ls_dkadr-inlnd. "1460038

  IF gs_sf_adrnr = space.
    CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
      EXPORTING
        adrswa_in  = gs_sf_adrs
      IMPORTING
        adrswa_out = gs_sf_adrs
      EXCEPTIONS
        OTHERS     = 04.
  ENDIF. " IF gs_sf_adrnr = space

  IF i_itcpo-tdarmod <> '1'.
    REFRESH fp_docparams-daratab.
    APPEND h_archive_index TO fp_docparams-daratab.
  ENDIF. " IF i_itcpo-tdarmod <> '1'

* ---> Begin of Insert for CR# D2_390 by VGAUR

* Get constants from EMI tools
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enhancement_no "D2_FDD_IDD_0016
    TABLES
      tt_enh_status     = li_status.        "returning table

* Deleting those records from li_status where active is equla to space
  DELETE li_status WHERE active EQ space.

* Read li_status with criteria equal to Null
  READ TABLE li_status WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                                criteria = lc_null "NULL
                              sel_option = if_cwd_constants=>c_option_equals
                      TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.

    READ TABLE li_status ASSIGNING <lfs_status>
                          WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                                   criteria = lc_bukrs
                                 sel_option = if_cwd_constants=>c_option_equals.
    IF sy-subrc EQ 0.
      IF t001-bukrs NE <lfs_status>-sel_low.

*&--Fetch Organization Address
*Since this address data need not to be printed in case of spanish statement,only
*Standard text data need to be printed.we are keeping this check.
*if the logon language is other then spanish we need to print this data on form.

        SELECT adrnr "Address No.
            UP TO 1 ROWS
          INTO lv_comp_adrnr
          FROM t049l " Lockboxes at our House Banks
         WHERE bukrs = t001-bukrs.
        ENDSELECT.
        IF sy-subrc = 0.
* Add PO_BOX into address
          SELECT addrnumber " Address number
                 name1      " Name 1
                 name2      " Name 2
                 house_num1 " House Number
                 street     " Street
                 city1      " City
                 city2      " District
                 region     " Region (State, Province, County)
                 post_code1 " City postal code
                 country    " Country Key
                 tel_number " First telephone no.: dialling code+number
                 fax_number " First fax no.: dialling code+number
                 po_box     " PO Box
           UP TO 1 ROWS
            FROM adrc       " Addresses (Business Address Services)
            INTO lx_org_address
           WHERE addrnumber = lv_comp_adrnr.
          ENDSELECT.
          IF sy-subrc = 0.
            IF NOT lx_org_address-po_box IS INITIAL.
              CONCATENATE 'P.O. Box'(013)
                          lx_org_address-po_box
                          lx_org_address-name2
                     INTO lv_pobox SEPARATED BY space.
            ELSEIF  lx_org_address-name2 IS NOT INITIAL.
              lv_pobox = lx_org_address-name2.
            ENDIF. " IF NOT lx_org_address-po_box IS INITIAL

            IF lx_org_address-hnum1 IS NOT INITIAL.
              CONCATENATE lx_org_address-hnum1
                          lx_org_address-street
                     INTO lv_street_hnum
             SEPARATED BY space.
            ELSE. " ELSE -> IF lx_org_address-hnum1 IS NOT INITIAL
              lv_street_hnum = lx_org_address-street.
            ENDIF. " IF lx_org_address-hnum1 IS NOT INITIAL

            CONCATENATE lx_org_address-city1
                        lx_org_address-region
                        space
                        lx_org_address-pcode1
                   INTO lv_city
           SEPARATED BY space.

* We need to compress if data is not there, eg, if name1 is not there
* then in place of name1, po box+name2 should be printed. The java script to hide
*in adobe form is not working.
            lv_index = 1.
            CONCATENATE lc_remit_field lv_index INTO lv_field_name.
            ASSIGN (lv_field_name) TO <lfs_address>.

* Name1
            IF lx_org_address-name1 IS NOT INITIAL.
              IF <lfs_address> IS ASSIGNED.
                <lfs_address> = lx_org_address-name1.
* prepare field symbol for next address line
                lv_index = lv_index + 1.
                CONCATENATE lc_remit_field lv_index INTO lv_field_name.
                ASSIGN (lv_field_name) TO <lfs_address>.
              ENDIF. " IF <lfs_address> IS ASSIGNED

            ENDIF. " IF lx_org_address-name1 IS NOT INITIAL

* PO box + Name 2
            IF lx_org_address-po_box IS NOT INITIAL.
              IF <lfs_address> IS ASSIGNED.
                <lfs_address> = lv_pobox.
* prepare field symbol for next address line
                lv_index = lv_index + 1.
                CONCATENATE lc_remit_field lv_index INTO lv_field_name.
                ASSIGN (lv_field_name) TO <lfs_address>.

              ENDIF. " IF <lfs_address> IS ASSIGNED

            ENDIF. " IF lx_org_address-po_box IS NOT INITIAL
* Street and house number
            IF lv_street_hnum IS NOT INITIAL.
              IF <lfs_address> IS ASSIGNED.
                <lfs_address> = lv_street_hnum.
* prepare field symbol for next address line
                lv_index = lv_index + 1.
                CONCATENATE lc_remit_field lv_index INTO lv_field_name.
                ASSIGN (lv_field_name) TO <lfs_address>.
              ENDIF. " IF <lfs_address> IS ASSIGNED

            ENDIF. " IF lv_street_hnum IS NOT INITIAL

            IF   lv_city IS NOT INITIAL.
              IF <lfs_address> IS ASSIGNED.
                <lfs_address> = lv_city. "city.
* prepare field symbol for next address line
                lv_index = lv_index + 1.
                CONCATENATE lc_remit_field lv_index INTO lv_field_name.
                ASSIGN (lv_field_name) TO <lfs_address>.
              ENDIF. " IF <lfs_address> IS ASSIGNED

            ENDIF. " IF lv_city IS NOT INITIAL
          ENDIF. " IF sy-subrc = 0
* ---> Begin of Insert for D3_OTC_FDD_0016 by RBANERJ1/Arpita
        ELSE. " ELSE -> IF sy-subrc = 0
* If Lockbox entry not found then it is D3 country
          lv_d3_flag = abap_true.
* <--- End of Insert for D3_OTC_FDD_0016 by RBANERJ1/Arpita
        ENDIF. " IF sy-subrc = 0

*If the logon language is spanish then pass this data as space
* only standard text data needs to be printed.

      ELSE. " ELSE -> IF t001-bukrs NE <lfs_status>-sel_low

        lx_org_address = space.
        lv_comp_adrnr  = space.
*Need to print the standard text in case of spanish language only.
*Remit to Address
*To Read the Standard text  ZOTC_FDD_ACCOUNT_PESOS
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = lc_id     "ID
            language                = sy-langu  "Lang
            name                    = lc_name1  "Text Name
            object                  = lc_object "object id
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
        IF sy-subrc EQ 0.
*To Read the text lines
          LOOP AT li_lines ASSIGNING <lfs_lines>.
            IF sy-tabix EQ 1.
              lv_lines1 = <lfs_lines>-tdline.
            ELSEIF sy-tabix EQ 2.
              lv_lines2 = <lfs_lines>-tdline.
            ELSEIF sy-tabix EQ 3.
              lv_lines3 = <lfs_lines>-tdline.
            ELSE. " ELSE -> IF sy-tabix EQ 1
              lv_lines4 = <lfs_lines>-tdline.
            ENDIF. " IF sy-tabix EQ 1
          ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
        ENDIF. " IF sy-subrc EQ 0
        REFRESH li_lines.
*To Read Standard Text -  ZOTC_FDD_ACCOUNT_DOLLARS
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = lc_id     "Id
            language                = sy-langu  "language
            name                    = lc_name2  "Text Name
            object                  = lc_object "Object Id
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
        IF sy-subrc EQ 0.
*To Read text lines
          LOOP AT li_lines ASSIGNING <lfs_lines>.
            IF sy-tabix EQ 1.
              lv_lines5 = <lfs_lines>-tdline.
            ELSEIF sy-tabix EQ 2.
              lv_lines6 = <lfs_lines>-tdline.
            ELSEIF sy-tabix EQ 3.
              lv_lines7 = <lfs_lines>-tdline.
            ELSE. " ELSE -> IF sy-tabix EQ 1
              lv_lines8 = <lfs_lines>-tdline.
            ENDIF. " IF sy-tabix EQ 1
          ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
        ENDIF. " IF sy-subrc EQ 0
        REFRESH li_lines.
        UNASSIGN <lfs_lines>.
      ENDIF. " IF t001-bukrs NE <lfs_status>-sel_low
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
* <--- End of Insert for CR# D2_390 by VGAUR
*---> Begin of D2_change of object D2_OTC_FDD_0016 BY NBAIS
  PERFORM f_language    CHANGING fp_docparams
                                 gv_langu_bi.

*<--- End of D2_change of object D2_OTC_FDD_0016 BY NBAIS

* ---> Begin of Insert for D3_OTC_FDD_0016 by RBANERJ1/Arpita
*&--For D3 country( if there is no T049L entry (lockbox address) maintained )
*    get the address from the sales organisation of the company
  IF lv_d3_flag EQ abap_true.
    SELECT adrnr " Address
    UP TO 1 ROWS
    FROM tvko    " Organizational Unit: Sales Organizations
    INTO lv_tvko_adrnr
    WHERE bukrs = t001-bukrs.
    ENDSELECT.
    IF sy-subrc EQ 0.
**&--Get the Sener Country
      SELECT country " Country Key
        UP TO 1 ROWS
        FROM adrc    " Addresses (Business Address Services)
        INTO lv_tvko_country
        WHERE addrnumber  = lv_tvko_adrnr.
      ENDSELECT.
      IF sy-subrc EQ 0.
* DO nothing
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0

*&--Get the IBAN (Bank Account Info)
    CALL FUNCTION 'ZOTC_GET_HOUSEBANKINFO'
      EXPORTING
        im_bukrs = t001-bukrs
        im_curr  = t001-waers
*Begin of change for CR#301 by U033867
        im_mult_housebank_info = abap_true
*End of change for CR#301 by U033867
      IMPORTING
        ex_out   = lx_housebank_info
*Begin of change for CR#301 by U033867
      CHANGING
        et_housebank      = li_housebank.
*End of change for CR#301 by U033867
*&--Concatenate the House Bank Street and City in Line 2
    CONCATENATE lx_housebank_info-stras
                lx_housebank_info-ort01
                INTO lv_housebank_line2
                SEPARATED BY lc_comma.
    CLEAR lx_org_address.
  ENDIF. " IF lv_d3_flag EQ abap_true
* <--- End of Insert for D3_OTC_FDD_0016 by RBANERJ1/Arpita

  CALL FUNCTION lv_fm_name                 " '/1BCDWB/SM00000012'
    EXPORTING
      /1bcdwb/docparams        = fp_docparams
      th_mhnd                  = lth_mhnd[]
      testprint                = gb_sf_testprint
      show_interest            = lv_show_interest
      t047                     = t047      "1336134
      t047c                    = t047c     "1336134
      mhnk                     = i_mhnk
      f150d                    = f150d
      f150d2                   = f150d2
      t056z                    = t056z
      t047i                    = t047i
      adrnr                    = gs_sf_adrnr
      uadrs                    = gs_sf_uadrs
      adrs                     = gs_sf_adrs
      fsabe                    = fsabe
      uadrnr                   = gs_sf_uadrnr
      incl_item                = 'X'       "1449122
      h_f150d                  = f150d
      recs                     = lv_recs
      waers                    = t001-waers
      paymi                    = paymi
      paymo                    = paymo
      f150d_esr                = f150d_esr
      t_sumtab                 = lt_sumtab "1296772
      t_saltab                 = lt_saltab "1574710
* ---> Begin of Insert for CR# D2_390 by VGAUR
      im_pesos_1               = lv_lines1 "Text lines
      im_pesos_2               = lv_lines2 "Text lines
      im_pesos_3               = lv_lines3 "Text lines
      im_pesos_4               = lv_lines4 "Text lines
      im_dollar_1              = lv_lines5 "Text lines
      im_dollar_2              = lv_lines6 "Text lines
      im_dollar_3              = lv_lines7 "Text lines
      im_dollar_4              = lv_lines8 "Text lines
      im_remit_l1              = lv_remit_to_l1
      im_remit_l2              = lv_remit_to_l2
      im_remit_l3              = lv_remit_to_l3
      im_remit_l4              = lv_remit_to_l4
* <--- End of Insert for CR# D2_390 by VGAUR
* ---> Begin of D2 Change for D2_OTC_FDD_0016 by NBAIS.
      im_gv_langu_bi           = gv_langu_bi
*<--- End of D2 Changes for D2_OTC_FDD_0016 BY NBAIS.
* ---> Begin of Insert for D3_OTC_FDD_0016 by RBANERJ1/Arpita
      im_d3_flag              =  lv_d3_flag
      im_d3_sender_country    = lv_tvko_country
      im_d3_remit_to_address  = lv_tvko_adrnr
      im_x_housebank     = lx_housebank_info
*Begin of change for CR#301 by U033867
      im_t_housebank     = li_housebank
*End of change for CR#301 by U033867
      im_housebank_line2 = lv_housebank_line2
* <--- End of Insert for D3_OTC_FDD_0016 by RBANERJ1/Arpita
   IMPORTING                                   "1460038
      /1bcdwb/formoutput       = ls_formoutput "1460038
   EXCEPTIONS
     usage_error              = 1
     system_error             = 2
     internal_error           = 3
     OTHERS                   = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
* Begin of change - GNAG E1DK901269
* PDF email sending part added based on the customer default communication method
  ELSE. " ELSE -> IF sy-subrc <> 0
* Email body
*&--Remove leading zeros from Customer
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = i_mhnk-kunnr
      IMPORTING
        output = lv_kunnr.

    CONCATENATE text-m01
                lv_cust_name
                '/'
                text-m02
                lv_kunnr
           INTO lwa_text-line SEPARATED BY space.
    APPEND lwa_text TO li_text.
* ---> Begin of Insert for D3_OTC_FDD_0016 by RBANERJ1/Arpita
* For D3 countru overwrite the customer email address  with clerk email id and fax
    IF lv_d3_flag EQ abap_true.
*  Email
      IF knb1-intad IS NOT INITIAL.
        lv_intad = knb1-intad.
      ENDIF. " IF knb1-intad IS NOT INITIAL
*  Fax
      IF knb1-tlfxs IS NOT INITIAL.
        lv_tlfxs = knb1-tlfxs.
      ENDIF. " IF knb1-tlfxs IS NOT INITIAL
    ENDIF. " IF lv_d3_flag EQ abap_true
* <--- End of Insert for D3_OTC_FDD_0016 by RBANERJ1/Arpita
*  &--Send Mail/Fax/Print
    CALL FUNCTION 'ZOTC_STANDARD_COMMUNICATION'
      EXPORTING
        im_adrnr         = lv_cust_adrnr
        im_subject       = 'Payment Inquiry from Bio-Rad Labs'(sub)
        im_form_output   = ls_formoutput
        im_t_text        = li_text
* ---> Begin of Insert for D3_OTC_FDD_0016 by RBANERJ1/Arpita
        im_tlfxs         = lv_tlfxs
        im_intad         = lv_intad
        im_adrnr_sender  = lv_tvko_adrnr
* <--- End of Insert for D3_OTC_FDD_0016 by RBANERJ1/Arpita
      EXCEPTIONS
        no_email_address = 1
        no_fax_number    = 2
        mail_failure     = 3
        fax_failure      = 4
        OTHERS           = 5.

    IF sy-subrc = 1.
*  &--If E-mail address not maintained
      CLEAR ls_message.
      MESSAGE ID lc_dev_msg TYPE lc_error NUMBER lc_msgno_003
              WITH 'For Customer'(e01) i_mhnk-kunnr 'E-mail Address is not Maintained'(e02)
              INTO ls_message.
      MOVE-CORRESPONDING ls_message TO t_fimsg.
      APPEND t_fimsg.
    ELSEIF sy-subrc = 2.
*  &--If Fax Number not maintained
      CLEAR ls_message.
      MESSAGE ID lc_dev_msg TYPE lc_error NUMBER lc_msgno_003
              WITH 'For Customer'(e01) i_mhnk-kunnr 'Fax Number is not Maintained'(e03)
              INTO ls_message.
      MOVE-CORRESPONDING ls_message TO t_fimsg.
      APPEND t_fimsg.
    ELSEIF sy-subrc = 3.
*  &--If E-mail sending failed
      CLEAR ls_message.
      MESSAGE ID lc_dev_msg TYPE lc_error NUMBER lc_msgno_003
              WITH 'For Customer'(e01) i_mhnk-kunnr 'E-mail sending failed'(e04)
              INTO ls_message.
      MOVE-CORRESPONDING ls_message TO t_fimsg.
      APPEND t_fimsg.
    ELSEIF sy-subrc = 4.
*  &--If Fax sending failed
      CLEAR ls_message.
      MESSAGE ID lc_dev_msg TYPE lc_error NUMBER lc_msgno_003
              WITH 'For Customer'(e01) i_mhnk-kunnr 'Fax sending failed'(e05)
              INTO ls_message.
      MOVE-CORRESPONDING ls_message TO t_fimsg.
      APPEND t_fimsg.
    ELSEIF sy-subrc = 5.
*  &--If other error
      CLEAR ls_message.
      MESSAGE ID lc_dev_msg TYPE lc_error NUMBER lc_msgno_003
              WITH 'For Customer'(e01) i_mhnk-kunnr 'Document sending failed'(e06)
              INTO ls_message.
      MOVE-CORRESPONDING ls_message TO t_fimsg.
      APPEND t_fimsg.
    ENDIF. " IF sy-subrc = 1
  ENDIF. " IF sy-subrc <> 0
* End of change - GNAG E1DK901269

* begin of note 1460038                                         "1460038
  IF i_itcpo-tdpreview = 'X'.
    CASE ld_device.
      WHEN 'PRINTER'.
        PERFORM pdf_close.
      WHEN 'MAIL'
      OR   'TELEFAX'.
        PERFORM preview TABLES lt_mail_recip lt_fax_recip
                        USING finaa ls_formoutput
                        CHANGING ld_answer.
        IF ld_answer = 'J'
        OR ld_answer = space
        OR ld_answer = '1'.
          CALL FUNCTION 'FI_SEND_PDF'
            EXPORTING
              ib_send                    = lb_send
              ib_archive                 = lb_archive           "1554240
              id_device                  = ld_device
              is_pdf                     = ls_formoutput
              id_t001_adrnr              = t001-adrnr
              id_sender                  = ld_sender
              id_sender_type             = ld_sender_type
              is_fsabe                   = fsabe
              is_receiver                = ls_dkadr
              is_outputparams            = ls_fp_outputparams
              id_langu                   = fp_docparams-langu
              id_mail_text               = finaa-mail_body_text
              id_fax_cover               = finaa-formc
              is_t047i                   = t047i
            IMPORTING
              es_error                   = ls_message
            TABLES
              it_mail_receivers          = lt_mail_recip
              it_fax_receivers           = lt_fax_recip
              it_dara                    = fp_docparams-daratab "1554240
            EXCEPTIONS
              too_many_receivers         = 1
              document_not_sent          = 2
              document_type_not_exist    = 3
              operation_no_authorization = 4
              invalid_device             = 7
              archive_error              = 8.
          CASE sy-subrc.
            WHEN 1.
              MESSAGE e499(msint) INTO ls_message. " User does not have authorization for so many recipients
            WHEN 2.
              MESSAGE e023(so) INTO ls_message. " Document <&> could not be sent
            WHEN 3.
              MESSAGE e627(so) INTO ls_message. " Object type does not exist
            WHEN 4.
              MESSAGE e015(so) INTO ls_message. " You do not have the necessary authorization for this function
            WHEN 7.
              MESSAGE e288(f5) INTO ls_message. " System lock error: Inform system administrator
            WHEN 8. "1554240
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno "1554240
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4          "1554240
              INTO ls_message.                                  "1554240
          ENDCASE.
        ENDIF. " IF ld_answer = 'J'
    ENDCASE.
  ELSE. " ELSE -> IF i_itcpo-tdpreview = 'X'
    CALL FUNCTION 'FI_SEND_PDF_IN_BUNDLE'
      EXPORTING
        ib_send           = lb_send
        ib_archive        = lb_archive           "1554240
        id_device         = ld_device
        id_t001_adrnr     = t001-adrnr
        id_sender         = ld_sender
        id_sender_type    = ld_sender_type
        is_fsabe          = fsabe
        is_receiver       = ls_dkadr
        is_outputparams   = ls_fp_outputparams
        id_langu          = fp_docparams-langu
        id_mail_text      = finaa-mail_body_text
        id_fax_cover      = finaa-formc
        is_t047i          = t047i
      IMPORTING
        es_error          = ls_message
      TABLES
        it_mail_receivers = lt_mail_recip
        it_fax_receivers  = lt_fax_recip
        it_dara           = fp_docparams-daratab "1554240
        et_messages       = lt_messages.
  ENDIF. " IF i_itcpo-tdpreview = 'X'
  IF NOT ls_message IS INITIAL.
    MOVE-CORRESPONDING ls_message TO t_fimsg.
    APPEND t_fimsg.
  ENDIF. " IF NOT ls_message IS INITIAL
  LOOP AT lt_messages INTO ls_message.
    MOVE-CORRESPONDING ls_message TO t_fimsg.
    APPEND t_fimsg.
  ENDLOOP. " LOOP AT lt_messages INTO ls_message
* end of note 1460038                                           "1460038

* update dunning data in master and item recors
  PERFORM update_data TABLES updbel USING i_update i_mhnk updkto updver.

* request a commit work from caller after 10 dunning notices
  IF updcnt > 10.
    updcnt   = 0.
    e_comreq = 'X'.
  ENDIF. " IF updcnt > 10
  updcnt = updcnt + 1.

* log the apropriate messages
  IF i_mout = 'X'.
    IF NOT sy-batch IS INITIAL.
      CALL FUNCTION 'FI_MESSAGE_PROTOCOL'
        EXCEPTIONS
          no_message = 1
          not_batch  = 2
          OTHERS     = 3.
    ELSE. " ELSE -> IF NOT sy-batch IS INITIAL
      CALL FUNCTION 'FI_MESSAGE_PRINT'
        EXPORTING
          i_xausn = 'X'
          i_comsg = 0
        EXCEPTIONS
          OTHERS  = 0.
    ENDIF. " IF NOT sy-batch IS INITIAL
  ENDIF. " IF i_mout = 'X'
  IF t_fimsg IS REQUESTED.
    CALL FUNCTION 'FI_MESSAGE_GET'
      TABLES
        t_fimsg    = t_fimsg
      EXCEPTIONS
        no_message = 1
        OTHERS     = 2.
  ENDIF. " IF t_fimsg IS REQUESTED
ENDFUNCTION.

*&---------------------------------------------------------------------*
*&      Form  pdf_close
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM pdf_close.
  IF gd_pdf_is_open = 'X'.
    CALL FUNCTION 'FP_JOB_CLOSE'
      EXCEPTIONS
        usage_error    = 1
        system_error   = 2
        internal_error = 3
        OTHERS         = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF. " IF sy-subrc <> 0
    CLEAR gd_pdf_is_open.
    CALL FUNCTION 'FI_SEND_PDF_IN_BUNDLE' "1460038
    EXPORTING ib_send  = 'Y'.             "1460038
  ENDIF. " IF gd_pdf_is_open = 'X'
ENDFORM. "pdf_close
*-----------------------------------------------------------------------
FORM fill_pdf_system_param              "new by note 1460038
TABLES ct_mail_recip STRUCTURE somlreci1
       ct_fax_recip  STRUCTURE somlreci1
USING is_f150v LIKE f150v               " Work fields for SAPF150V
      is_t047e LIKE t047e               " Form selection for dunning notices
CHANGING cs_finaa       LIKE finaa      " Data for Transmission Medium for Correspondence
         cs_itcpo       LIKE itcpo      " SAPscript output interface
         cd_sender      TYPE so_rec_ext " External address (SMTP/X.400...)
         cd_sender_type TYPE so_adr_typ.

  DATA: ld_faxnr TYPE tlfxs. " Accounting clerk's fax number at the customer/vendor

  ld_faxnr = cs_finaa-tdtelenum.
  CALL FUNCTION 'FI_GET_FAX_MAIL_RECEIVERS'
    EXPORTING
      id_faxnr      = ld_faxnr
      id_land1      = cs_finaa-tdteleland
      id_mailadr    = cs_finaa-intad
    TABLES
      ct_mail_recip = ct_mail_recip
      ct_fax_recip  = ct_fax_recip
    EXCEPTIONS
      no_data       = 1.
  IF sy-subrc <> 0.
    cs_finaa-nacha = '1'.
  ENDIF. " IF sy-subrc <> 0
  CONCATENATE is_f150v-laufi is_f150v-laufd+2(6)
  INTO cs_itcpo-tdsuffix2.
  cs_itcpo-tddataset = is_t047e-listn.
  CASE cs_finaa-nacha.
    WHEN '1'. " Print
    WHEN '2'. " Fax
      cs_itcpo-tdschedule = cs_finaa-tdschedule.
      cs_itcpo-tdteleland = cs_finaa-tdteleland.
      cs_itcpo-tdtelenum  = cs_finaa-tdtelenum.
      cs_itcpo-tdfaxuser  = cs_finaa-tdfaxuser.
      cs_itcpo-tdsuffix1  = 'FAX'.
      cd_sender = finaa-tdfaxuser.
      cd_sender_type = space.
    WHEN 'I'. " Mail
      cd_sender = finaa-mail_send_addr.
      cd_sender_type = 'U'.
      IF cd_sender IS INITIAL.
        cd_sender = finaa-intuser.
        cd_sender_type = 'B'.
      ENDIF. " IF cd_sender IS INITIAL
  ENDCASE.
ENDFORM. "1460038

************ Start of PDF Conversion : Insert : Date:19/07/2004, I029678
*---------------------------------------------------------------------*
*       FORM fill_outputparams                                        *
*---------------------------------------------------------------------*
FORM fill_outputparams                        "1460038
TABLES   it_mail_recip   STRUCTURE somlreci1  "1460038
         it_fax_recip    STRUCTURE somlreci1  "1460038
USING    id_nacha        LIKE finaa-nacha     "1460038
         is_itcpo        TYPE itcpo           " SAPscript output interface
CHANGING xs_outputparams TYPE sfpoutputparams " Form Processing Output Parameter
         xd_device       TYPE tddevice        "1460038
         xb_send         TYPE c               "1460038
         xb_archive      TYPE c.              "1554240

  CONSTANTS  : lc_charx TYPE c VALUE 'X'. " Charx of type Character
  DATA       : lb_bundling.

  CASE id_nacha. "1460038
    WHEN '1'. "1460038
      xs_outputparams-device  = 'PRINTER'. "1460038
    WHEN '2'. "1460038
      xs_outputparams-device  = 'TELEFAX'. "1460038
    WHEN 'I'. "1460038
      xs_outputparams-device  = 'MAIL'. "1460038
    WHEN OTHERS. "1460038
      xs_outputparams-device  = space. "1460038
  ENDCASE. "1460038
  xs_outputparams-nodialog   = lc_charx.
  xs_outputparams-preview    = space. "1460038
  xs_outputparams-dest       = is_itcpo-tddest.
*  xs_outputparams-REQNEW     = is_itcpo-TDNEWID.
  xs_outputparams-reqimm     = is_itcpo-tdimmed.
  xs_outputparams-reqdel     = is_itcpo-tddelete.
  xs_outputparams-reqfinal   = is_itcpo-tdfinal.
  xs_outputparams-senddate   = is_itcpo-tdsenddate.
  xs_outputparams-sendtime   = is_itcpo-tdsendtime.
  xs_outputparams-schedule   = is_itcpo-tdschedule.
  xs_outputparams-copies     = is_itcpo-tdcopies.
  xs_outputparams-dataset    = is_itcpo-tddataset.
  xs_outputparams-suffix1    = is_itcpo-tdsuffix1.
  xs_outputparams-suffix2    = is_itcpo-tdsuffix2.
  xs_outputparams-covtitle   = is_itcpo-tdcovtitle.
  xs_outputparams-cover      = is_itcpo-tdcover.
  xs_outputparams-receiver   = is_itcpo-tdreceiver.
  xs_outputparams-division   = is_itcpo-tddivision.
  xs_outputparams-lifetime   = is_itcpo-tdlifetime.
  xs_outputparams-authority  = is_itcpo-tdautority.
  xs_outputparams-rqposname  = is_itcpo-rqposname.
  xs_outputparams-arcmode    = is_itcpo-tdarmod.
  xs_outputparams-noarmch    = is_itcpo-tdnoarmch.
  xs_outputparams-title      = is_itcpo-tdtitle.
  xs_outputparams-nopreview  = is_itcpo-tdnoprev.
  xs_outputparams-noprint    = is_itcpo-tdnoprint.
  IF is_itcpo-tdpreview = space. "1460038
    lb_bundling = 'X'. "1460038
  ENDIF. " IF is_itcpo-tdpreview = space
  CALL FUNCTION 'FI_CHECK_FAX_MAIL_OPTIONS' "1460038
  EXPORTING ib_bundling = lb_bundling       "1460038
  IMPORTING ed_device   = xd_device         "1460038
            eb_send     = xb_send           "1460038
            eb_archive  = xb_archive        "1554240
  TABLES it_mail_recip  = it_mail_recip     "1460038
         it_fax_recip   = it_fax_recip      "1460038
  CHANGING cs_params    = xs_outputparams.  "1460038
  IF xs_outputparams-device = 'PRINTER'. "1460038
    xs_outputparams-preview = is_itcpo-tdpreview. "1460038
  ENDIF. " IF xs_outputparams-device = 'PRINTER'

ENDFORM. "fill_outputparams
*-----------------------------------------------------------------------
FORM preview TABLES ct_mail_recip STRUCTURE somlreci1 "1460038
                    ct_fax_recip  STRUCTURE somlreci1
             USING is_finaa      TYPE finaa           " Data for Transmission Medium for Correspondence
                   is_formoutput TYPE fpformoutput    " Form Output (PDF, PDL)
             CHANGING cd_answer  TYPE c.              " Answer of type Character

  DATA: ld_pdf    TYPE fpcontent, " Form Processing: Content from XFT, XFD, PDF, and so on
        ld_intad  TYPE intad.     " Internet address of partner company clerk

  ld_pdf = is_formoutput-pdf.
  CALL FUNCTION 'EFG_DISPLAY_PDF'
    EXPORTING
      i_pdf = ld_pdf.
  CASE is_finaa-nacha.
    WHEN '2'.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
*         TITLEBAR              = ' '
          text_question         = text-326
          default_button        = '2'
          display_cancel_button = space
        IMPORTING
          answer                = cd_answer.
    WHEN 'I'.
      CALL FUNCTION 'CORRESPONDENCE_POPUP_EMAIL'
        EXPORTING
          i_intad  = is_finaa-intad
        IMPORTING
          e_answer = cd_answer
          e_intad  = ld_intad.
      IF ld_intad <> is_finaa-intad.
        REFRESH ct_mail_recip.
        CALL FUNCTION 'FI_GET_FAX_MAIL_RECEIVERS'
          EXPORTING
            id_faxnr      = space
            id_land1      = is_finaa-tdteleland
            id_mailadr    = ld_intad
          TABLES
            ct_mail_recip = ct_mail_recip
            ct_fax_recip  = ct_fax_recip
          EXCEPTIONS
            no_data       = 1.
        IF sy-subrc <> 0.
          cd_answer = 'N'.
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF ld_intad <> is_finaa-intad
  ENDCASE.
ENDFORM. "1460038
*-----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  F_LANGUAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_FP_DOCPARAMS  text
*      <--P_GV_LANGU_BI  text
*----------------------------------------------------------------------*
FORM f_language  CHANGING fp_docparams TYPE  sfpdocparams " Form Parameters for Form Processing
                          fp_gv_langu_bi TYPE  spras.     " Language Key of Current Text Environment

  DATA:   li_status TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
          lv_langu          TYPE  spras,                    " Language Key
          lv_langu_bi       TYPE  spras.                    " Language Key

  CONSTANTS:   lc_enhancement_no TYPE z_enhancement VALUE 'D2_OTC_FDD_0016', " Enhancement No.
               lc_bukrs          TYPE z_criteria    VALUE 'BUKRS',           " Enh. Criteria
               lc_null           TYPE z_criteria    VALUE 'NULL',            "Enh. Criteria
               lc_eq             TYPE bapioption    VALUE 'EQ',              "Selection operator OPTION for range tables
               lc_sign_i         TYPE bapisign      VALUE 'I'.               " Inclusion/exclusion criterion SIGN for range tables

  FIELD-SYMBOLS: <lfs_status> TYPE zdev_enh_status. " Enhancement Status

  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enhancement_no "D2_PTM_IDD_0018
    TABLES
      tt_enh_status     = li_status.        "returning table

* Deleting those records from li_status where active is equla to space
  DELETE li_status WHERE active EQ space.

*Read li_status with criteria equal to Null
  READ TABLE li_status WITH KEY criteria = lc_null "NULL
                      TRANSPORTING NO FIELDS.
  IF li_status[] IS NOT INITIAL.

    READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_bukrs
                                                         sel_low  = t001-bukrs.
    IF sy-subrc EQ 0.

      IF <lfs_status>-sel_high CS '_'.
        SPLIT <lfs_status>-sel_high AT '_' INTO lv_langu
                                                lv_langu_bi.

        fp_docparams-langu = lv_langu_bi.
        fp_gv_langu_bi     = lv_langu.
      ELSE. " ELSE -> IF <lfs_status>-sel_high CS '_'
        fp_docparams-langu = <lfs_status>-sel_high.
      ENDIF. " IF <lfs_status>-sel_high CS '_'
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_status[] IS NOT INITIAL

ENDFORM. " F_LANGUAGE
