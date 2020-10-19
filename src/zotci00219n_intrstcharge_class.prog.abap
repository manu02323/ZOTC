*&---------------------------------------------------------------------*
*&  Include           ZOTCI00219N_INTRSTCHARGE_CLASS
*&---------------------------------------------------------------------*
************************************************************************
* INCLUDE    : ZOTCI00219N_INTRSTCHARGE_CLASS                          *
* TITLE      : Send Intrest Charges to fabn                            *
* DEVELOPER  : Manoj Thatha                                            *
* OBJECT TYPE: Interface                                               *
* SAP RELEASE: SAP ECC 6.0                                             *
*----------------------------------------------------------------------*
* WRICEF ID  : D3_OTC_IDD_0219                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: Include for Local Class Definition & Implementation     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT   DESCRIPTION                       *
* ===========  ========  ==========  ==================================*
* 20-FEB-2018  MTHATHA   E1DK934654  Initial Development               *
* 20-Mar-2018  MTHATHA   E1DK934654  D#5532 Dump issue                 *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS LCL_SEL_SCREEN DEFINITION
*----------------------------------------------------------------------*
*       Local Class for Selection Screen
*----------------------------------------------------------------------*
CLASS lcl_sel_screen DEFINITION FINAL. " Selection Screen Class.
**********************************************************
  PUBLIC SECTION.
**********************************************************
*--------------------------------------------------------*
*                S T A T I C   D A T A                   *
*--------------------------------------------------------*
*    CLASS-DATA:
*    attr_stat_pub_belnr TYPE bseg-belnr. " Document Number,
*--------------------------------------------------------*
*                     M E T H O D S                      *
*--------------------------------------------------------*
    METHODS:
    meth_inst_pub_valid_bukrs       " Validate Company Code
      IMPORTING im_bukrs TYPE bukrs " Company Code
        RAISING cx_crm_genil_general_error,
    meth_inst_pub_valid_fs_year     " Validate Document Number
      IMPORTING im_gjahr TYPE gjahr " Fiscal Year
        RAISING cx_crm_genil_general_error,
    meth_inst_pub_valid_doc
      IMPORTING im_belnr TYPE bkk_r_belnr
                im_regn  TYPE c     " Regn of type Character
        RAISING cx_crm_genil_general_error.
ENDCLASS. "lcl_sel_screen DEFINITION
*----------------------------------------------------------------------*
*       CLASS LCL_PROCESS DEFINITION
*----------------------------------------------------------------------*
*       Local Class for Processing
*----------------------------------------------------------------------*
CLASS lcl_process DEFINITION FINAL. " Processing Class
**********************************************************
  PUBLIC SECTION.
**********************************************************
*--------------------------------------------------------*
*            T Y P E    D E C L A R A T I O N            *
*--------------------------------------------------------*
    TYPES:
    BEGIN OF ty_bkpf_data,        " Accounting Document Header
      bukrs         TYPE bukrs,   " Company Code
      belnr         TYPE belnr_d, " Accounting Document Number
      gjahr         TYPE gjahr,   " Fiscal Year
      budat         TYPE budat,   " Posting Date in the Document
      cpudt         TYPE cpudt,   " Date of Entry
      waers         TYPE waers,   " Currency Key
    END OF ty_bkpf_data,
    BEGIN OF ty_bseg_data,        " Accounting Document Segment
      bukrs         TYPE bukrs,   " Company Code
      belnr         TYPE belnr_d, " Accounting Document Number
      gjahr         TYPE gjahr,   " Fiscal Year
      buzei         TYPE buzei,   " Number of Line Item
      buzid         TYPE buzid,   " Identification of the Line Item
      koart         TYPE koart,   " Account Type
      shkzg         TYPE shkzg,   " Debit/Credit Indicator
      wrbtr         TYPE wrbtr,   " Amount in Document Currency
      kunnr         TYPE kunnr,   " Customer Number
      rebzg         TYPE rebzg,   " Number of the Invoice the Transaction Belongs to
    END OF ty_bseg_data,
    BEGIN OF ty_intitit_data,     " Accounting Document Segment
      belnr_to      TYPE belnr_d, " Accounting Document Number
      bukrs         TYPE bukrs,   " Company Code
      belnr         TYPE belnr_d, " Accounting Document Number
      gjahr         TYPE gjahr,   " Fiscal Year
      buzei         TYPE buzei,   " Number of Line Item
*--Begin of changes for D#5532 BY mthatha
      int_end       TYPE int_end, " FI Item Interest Calc.: End of Int. Calc. for Item/Int. Rate
*--End of changes for D#5532 BY mthatha
      int_curr      TYPE waers,      " Currency Key
      int_amount    TYPE wrshb_x8,   " Amount in Document Currency (Foreign Currency)
      int_shkzg     TYPE shkzg,      " Debit/Credit Indicato
      int_cpudt     TYPE cpudt,      " Day On Which Accounting Document Was Entered
      account       TYPE ktonr,      " SD business partner identifier (number or code)
      koart         TYPE koart,      " Account Type
      buzei_to      TYPE buzei,      " Number of Line Item Within Accounting Document
      form_to       TYPE int_form,   " Form Number for New Item Interest Calculation
    END OF ty_intitit_data,
    BEGIN OF ty_kna1_data,           " Customer Data
      kunnr         TYPE kunnr,      " Customer Number
      land1         TYPE land1_gp,   " Country Key
      adrnr         TYPE adrnr,      " Address
      stceg         TYPE stceg,      " Tax Number 1
    END OF ty_kna1_data,
    BEGIN OF ty_address,             " Addresses
      adrnr         TYPE adrnr,      " Address
      date_from     TYPE ad_date_fr, " Date From
      date_to       TYPE ad_date_to, " Date To
      name1         TYPE ad_name1,   " Name 1
      city2         TYPE ad_city2,   " District
      post_code1    TYPE ad_pstcd1,  " City postal code
      street        TYPE ad_street,  " Street
      house_num1    TYPE ad_hsnm1,   " House Number
      house_num2    TYPE ad_hsnm2,   " House number supplement
      str_suppl1    TYPE ad_strspp1, " Street 2
      country       TYPE land1,      " Country Key
      region        TYPE regio,      " Region (State, Province, County)
      tel_number    TYPE ad_tlnmbr1, " Telephone Number
      mc_city1      TYPE ad_mc_city, " City name in upper case
    END OF ty_address.
*--------------------------------------------------------*
*    T A B L E     T Y P E     D E C L A R A T I O N     *
*--------------------------------------------------------*
    TYPES:
*&--Documents for Mexico E-Invoice Interface
     ty_t_icharges  TYPE HASHED TABLE OF zotc_int_charg                 "
                     WITH UNIQUE KEY bukrs
                                     gjahr
                                     belnr,
*&--Accounting Document Header
     ty_t_bkpf      TYPE HASHED TABLE OF ty_bkpf_data                "
                     WITH UNIQUE KEY bukrs
                                     belnr
                                     gjahr,
*&--Accounting Document Segment
     ty_t_bseg      TYPE SORTED TABLE OF ty_bseg_data                "
                     WITH UNIQUE KEY belnr
                                     gjahr
                                     buzei,
*&--Accounting Document Segment
     ty_t_intitit   TYPE SORTED TABLE OF ty_intitit_data                "
                             WITH NON-UNIQUE KEY belnr_to
                                     bukrs
                                     gjahr
                                     buzei_to
*--Begin of changes for d#5532 by mthatha
                                     int_end,
*--End of changes for d#5532 by mthatha
*&--Customer Data
     ty_t_kna1      TYPE HASHED TABLE OF ty_kna1_data                "
                     WITH UNIQUE KEY kunnr,
*&--Addresses
     ty_t_adrc      TYPE HASHED TABLE OF ty_address                  "
                     WITH UNIQUE KEY adrnr,
*&--Documents for Mexico E-Invoice Interface
     ty_t_update    TYPE STANDARD TABLE OF zotc_int_charg.          "
*--------------------------------------------------------*
*                  C O N S T A N T S                     *
*--------------------------------------------------------*
    CONSTANTS:
*&--Enhancement No.
    c_idd_0219      TYPE z_enhancement VALUE 'D3_OTC_IDD_0219'.   "
    "
*--------------------------------------------------------*
*                S T A T I C   D A T A                   *
*--------------------------------------------------------*
    CLASS-DATA:
*&--Enhancement Status
    attr_stat_pub_status TYPE zdev_tt_enh_status,                      "
*&--Accounting Document Header
    attr_stat_pub_bkpf   TYPE ty_t_bkpf,                              "
*&--Accounting Document Segment
    attr_stat_pub_bseg   TYPE ty_t_bseg,                              "
*&--Interest Calculation Details per Item
    attr_stat_pub_intitit TYPE ty_t_intitit,
*&--Customer Data
    attr_stat_pub_kna1   TYPE ty_t_kna1,                              "
*--Company code address number
    attr_stat_pub_adrnr  TYPE adrnr, " Address
*--Company Vat
    attr_stat_pub_stceg  TYPE stceg, " VAT Registration Number
*&--Addresses
    attr_stat_pub_adrc      TYPE ty_t_adrc,                              "
    attr_idpaese            TYPE zdev_criteria,    " Enhancement Criteria Definition
    attr_idpaese_represent  TYPE zdev_criteria,    " Enhancement Criteria Definition
    attr_idpaese_prestatore TYPE zdev_criteria,    " Enhancement Criteria Definition
    attr_idpaese_terzo      TYPE zdev_criteria,    " Enhancement Criteria Definition
    attr_denominazione      TYPE zdev_criteria,    " Enhancement Criteria Definition
    attr_idcodice           TYPE z_criteria,       " Enh. Criteria
    attr_idcodice_represent TYPE z_criteria,       " Enh. Criteria
    attr_idcodice_prestatore TYPE zdev_criteria,   " Enhancement Criteria Definition
    attr_soggettoemittente  TYPE z_criteria,       " Enh. Criteria
    attr_tipodocumento      TYPE z_criteria,       " Enh. Criteria
    attr_idcodice_terzo     TYPE z_criteria,       " Enh. Criteria
    attr_formatotrasmissione TYPE z_criteria,      " Enh. Criteria
    attr_regimefiscale       TYPE z_criteria,      " Enh. Criteria
    attr_numerorea           TYPE z_criteria,      " Enh. Criteria
    attr_capitalesociale          TYPE z_criteria, " Enh. Criteria
    attr_sociounico              TYPE z_criteria,  " Enh. Criteria
    attr_statoliquidazione       TYPE z_criteria,  " Enh. Criteria
    attr_bollovirtuale           TYPE z_criteria,  " Enh. Criteria
    attr_importobollo            TYPE z_criteria,  " Enh. Criteria
    attr_natura                  TYPE z_criteria,  " Enh. Criteria
    attr_prezzounitario          TYPE z_criteria,  " Enh. Criteria
    attr_unitamisura             TYPE z_criteria,  " Enh. Criteria
    attr_esigibilitaiva          TYPE z_criteria,  " Enh. Criteria
    attr_riferimentonormativo    TYPE z_criteria,  " Enh. Criteria
    attr_bic                     TYPE z_criteria,  " Enh. Criteria
    attr_condizionipagamento     TYPE z_criteria,  " Enh. Criteria
    attr_giorniterminipagamento  TYPE z_criteria,  " Enh. Criteria
    attr_iban                    TYPE z_criteria,  " Enh. Criteria
    attr_iddocumento             TYPE z_criteria,  " Enh. Criteria
    attr_modalitapagamento       TYPE z_criteria,  " Enh. Criteria
*&--Documents already Sent to Faben
    attr_stat_pub_update TYPE ty_t_update.                            "
*--------------------------------------------------------*
*                     M E T H O D S                      *
*--------------------------------------------------------*
    METHODS:
    constructor                           " Constructor
        RAISING cx_crm_genil_general_error,
    meth_inst_pub_get_inv_data            " Get Invoice data
      IMPORTING im_belnr TYPE bkk_r_belnr " Document Number
                im_cpudt TYPE bkk_r_budat " Day On Which Accounting Document Was Entered
                im_bukrs TYPE bukrs       " Company Code
                im_gjahr TYPE gjahr       " Fiscal Year
        RAISING cx_crm_genil_general_error,
    meth_inst_pub_send_charges
        IMPORTING im_regn TYPE c OPTIONAL " Document Number       " Send Charges
        RAISING cx_crm_genil_general_error,
    meth_inst_pub_free.                   " Free Class Attributes
ENDCLASS. "lcl_process DEFINITION
*----------------------------------------------------------------------*
*       CLASS LCL_SEL_SCREEN IMPLEMENTATION
*----------------------------------------------------------------------*
*       Local Class for Selection Screen
*----------------------------------------------------------------------*
CLASS lcl_sel_screen IMPLEMENTATION. " Selection Screen Class
*------------------------------------------------------------------*
* METHOD: METH_INST_PUB_VALID_BUKRS
*------------------------------------------------------------------*
* Validate Company Code
*------------------------------------------------------------------*
* ---> IM_BUKRS     Company Code
*------------------------------------------------------------------*
  METHOD meth_inst_pub_valid_bukrs.
*--------------------------Local Variables-------------------------*
    DATA: lv_bukrs  TYPE satr_de_hierfldk. " Company Code
*------------------------------Logic-------------------------------*
*&--Check Company Code
    SELECT SINGLE bukrs " Company Code
             FROM t001  " Company Codes
             INTO lv_bukrs
            WHERE bukrs EQ im_bukrs.
    IF sy-subrc NE 0.
*&--Raise Exception
      RAISE EXCEPTION TYPE cx_crm_genil_general_error
        EXPORTING
          text = 'Invalid Company Code'(003).
    ELSE. " ELSE -> IF sy-subrc NE 0
      CLEAR: lv_bukrs.
    ENDIF. " IF sy-subrc NE 0
  ENDMETHOD. "METH_INST_PUB_VALID_BUKRS
*------------------------------------------------------------------*
* METHOD: METH_INST_PUB_VALID_FS_YEAR
*------------------------------------------------------------------*
* Validate Fiscal Year
*------------------------------------------------------------------*
* ---> IM_GJAHR     Fiscal Year
*------------------------------------------------------------------*
  METHOD meth_inst_pub_valid_fs_year.
*------------------------------Logic-------------------------------*
*&--Check if Fiscal Year is numeric only
    IF im_gjahr CN cl_fdt_unit_test_wf_helper=>mc_instid.
*&--Raise Exception
      RAISE EXCEPTION TYPE cx_crm_genil_general_error
        EXPORTING
          text = 'Enter a numeric value'(005).
    ENDIF. " IF im_gjahr CN cl_fdt_unit_test_wf_helper=>mc_instid
  ENDMETHOD. "METH_INST_PUB_VALID_FS_YEAR
*------------------------------------------------------------------*
* METHOD: METH_INST_PUB_VALID_DOC
*------------------------------------------------------------------*
* Validate Document is entered for regenartion check box
*------------------------------------------------------------------*
* ---> IM_BELNR     Document Number
*------------------------------------------------------------------*
  METHOD meth_inst_pub_valid_doc.
*&--Check if Fiscal Year is numeric only
    IF im_belnr[] IS NOT INITIAL.
      IF im_regn IS INITIAL.
*&--Raise Exception
        RAISE EXCEPTION TYPE cx_crm_genil_general_error
          EXPORTING
            text = 'Please Enter Document Number for Re-genaration'(002).
      ENDIF. " IF im_regn IS INITIAL
    ENDIF. " IF im_belnr[] IS NOT INITIAL
  ENDMETHOD. "meth_inst_pub_valid_doc
ENDCLASS. "LCL_SEL_SCREEN IMPLEMENTATION
*----------------------------------------------------------------------*
*       CLASS LCL_PROCESS IMPLEMENTATION
*----------------------------------------------------------------------*
*       Local Class for Processing
*----------------------------------------------------------------------*
CLASS lcl_process IMPLEMENTATION. " Processing Class
*------------------------------------------------------------------*
* METHOD: CONSTRUCTOR
*------------------------------------------------------------------*
* Constructor
*------------------------------------------------------------------*
  METHOD constructor.
    CONSTANTS:lc_idpaese                 TYPE z_criteria VALUE 'IDPAESE',                " Enh. Criteria
              lc_idpaese_represent       TYPE z_criteria VALUE 'IDPAESE_REPRESENT',      " Enh. Criteria
              lc_idpaese_prestatore      TYPE z_criteria VALUE 'IDPAESE_PRESTATORE',     " Enh. Criteria
              lc_idcodice                TYPE z_criteria VALUE 'IDCODICE',               " Enh. Criteria
              lc_idcodice_represent      TYPE z_criteria VALUE 'IDCODICE_REPRESENT',     " Enh. Criteria
              lc_idcodice_prestatore     TYPE z_criteria VALUE 'IDCODICE_PRESTATORE',    " Enh. Criteria
              lc_iddocumento             TYPE z_criteria VALUE 'IDDOCUMENTO',            " Enh. Criteria
              lc_soggettoemittente       TYPE z_criteria VALUE 'SOGGETTOEMITTENTE',      " Enh. Criteria
              lc_tipodocumento           TYPE z_criteria VALUE 'TIPODOCUMENTO',          " Enh. Criteria
              lc_idcodice_terzo          TYPE z_criteria VALUE 'IDCODICE_TERZO',         " Enh. Criteria
              lc_denominazione           TYPE z_criteria VALUE 'DENOMINAZIONE',          " Enh. Criteria
              lc_formatotrasmissione     TYPE z_criteria VALUE 'FORMATOTRASMISSIONE',    " Enh. Criteria
              lc_regimefiscale           TYPE z_criteria VALUE 'REGIMEFISCALE',          " Enh. Criteria
              lc_numerorea               TYPE z_criteria VALUE 'NUMEROREA',              " Enh. Criteria
              lc_capitalesociale         TYPE z_criteria VALUE 'CAPITALESOCIALE',        " Enh. Criteria
              lc_sociounico              TYPE z_criteria VALUE 'SOCIOUNICO',             " Enh. Criteria
              lc_statoliquidazione       TYPE z_criteria VALUE 'STATOLIQUIDAZIONE',      " Enh. Criteria
              lc_bollovirtuale           TYPE z_criteria VALUE 'BOLLOVIRTUALE',          " Enh. Criteria
              lc_importobollo            TYPE z_criteria VALUE 'IMPORTOBOLLO',           " Enh. Criteria
              lc_natura                  TYPE z_criteria VALUE 'NATURA',                 " Enh. Criteria
              lc_prezzounitario          TYPE z_criteria VALUE 'PREZZOUNITARIO',         " Enh. Criteria
              lc_unitamisura             TYPE z_criteria VALUE 'UNITAMISURA',            " Enh. Criteria
              lc_esigibilitaiva          TYPE z_criteria VALUE 'ESIGIBILITAIVA',         " Enh. Criteria
              lc_riferimentonormativo    TYPE z_criteria VALUE 'RIFERIMENTONORMATIVO',   " Enh. Criteria
              lc_bic                     TYPE z_criteria VALUE 'BIC',                    " Enh. Criteria
              lc_condizionipagamento     TYPE z_criteria VALUE 'CONDIZIONIPAGAMENTO',    " Enh. Criteria
              lc_giorniterminipagamento  TYPE z_criteria VALUE 'GIORNITERMINIPAGAMENTO', " Enh. Criteria
              lc_iban                    TYPE z_criteria VALUE 'IBAN',                   " Enh. Criteria
              lc_modalitapagamento       TYPE z_criteria VALUE 'MODALITAPAGAMENTO',      " Enh. Criteria
              lc_idpaese_terzo           TYPE z_criteria VALUE 'IDPAESE_TERZO'.          " Enh. Criteria
    FIELD-SYMBOLS:
    <lfs_status>   TYPE zdev_enh_status. " Enhancement Status
*------------------------------Logic-------------------------------*
*&--Check Enhancement Status
    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
      EXPORTING
        iv_enhancement_no = c_idd_0219
      TABLES
        tt_enh_status     = attr_stat_pub_status.
*&--First thing is to check for field criterion,for value “NULL” and
*&--field Active value:
*&  1. If the value is: “X”, the overall Enhancement is active and can
*&      proceed further for checks
*&  2. If the value is space, then do not proceed further for this
*&     enhancement
    DELETE attr_stat_pub_status WHERE active = abap_false.
    READ TABLE attr_stat_pub_status
      WITH KEY criteria = zif_plm_constants=>c_plm_null
  TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
*&--Raise Exception
      RAISE EXCEPTION TYPE cx_crm_genil_general_error
        EXPORTING
          text = 'Configuration not maintained in EMI tool'(004).
    ELSE. " ELSE -> IF sy-subrc NE 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                      WITH KEY criteria = lc_idpaese.
      IF sy-subrc EQ 0.
        attr_idpaese = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                      WITH KEY criteria = lc_idpaese_represent.
      IF sy-subrc EQ 0.
        attr_idpaese_represent = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                      WITH KEY criteria = lc_idpaese_prestatore.
      IF sy-subrc EQ 0.
        attr_idpaese_prestatore = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                      WITH KEY criteria = lc_idpaese_terzo.
      IF sy-subrc EQ 0.
        attr_idpaese_terzo = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                       WITH KEY criteria = lc_denominazione.
      IF sy-subrc EQ 0.
        attr_denominazione = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                WITH KEY criteria = lc_idcodice.
      IF sy-subrc EQ 0.
        attr_idcodice = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                      WITH KEY criteria = lc_idcodice_represent.
      IF sy-subrc EQ 0.
        attr_idcodice_represent = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                      WITH KEY criteria = lc_idcodice_prestatore.
      IF sy-subrc EQ 0.
        attr_idcodice_prestatore = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                      WITH KEY criteria = lc_idcodice_terzo.
      IF sy-subrc EQ 0.
        attr_idcodice_terzo = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                       WITH KEY criteria = lc_soggettoemittente.
      IF sy-subrc EQ 0.
        attr_soggettoemittente = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                       WITH KEY criteria = lc_tipodocumento.
      IF sy-subrc EQ 0.
        attr_tipodocumento = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                       WITH KEY criteria = lc_formatotrasmissione.
      IF sy-subrc EQ 0.
        attr_formatotrasmissione = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                       WITH KEY criteria = lc_regimefiscale.
      IF sy-subrc EQ 0.
        attr_regimefiscale = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                      WITH KEY criteria = lc_numerorea.
      IF sy-subrc EQ 0.
        attr_numerorea = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                      WITH KEY criteria = lc_capitalesociale.
      IF sy-subrc EQ 0.
        attr_capitalesociale = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                      WITH KEY criteria = lc_sociounico.
      IF sy-subrc EQ 0.
        attr_sociounico = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                       WITH KEY criteria = lc_statoliquidazione.
      IF sy-subrc EQ 0.
        attr_statoliquidazione = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                WITH KEY criteria = lc_bollovirtuale.
      IF sy-subrc EQ 0.
        attr_bollovirtuale = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                      WITH KEY criteria = lc_importobollo.
      IF sy-subrc EQ 0.
        attr_importobollo = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                      WITH KEY criteria = lc_natura.
      IF sy-subrc EQ 0.
        attr_natura = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                       WITH KEY criteria = lc_prezzounitario.
      IF sy-subrc EQ 0.
        attr_prezzounitario = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                       WITH KEY criteria = lc_unitamisura.
      IF sy-subrc EQ 0.
        attr_unitamisura = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                       WITH KEY criteria = lc_esigibilitaiva.
      IF sy-subrc EQ 0.
        attr_esigibilitaiva = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                       WITH KEY criteria = lc_riferimentonormativo.
      IF sy-subrc EQ 0.
        attr_riferimentonormativo = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                      WITH KEY criteria = lc_bic.
      IF sy-subrc EQ 0.
        attr_bic = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                       WITH KEY criteria = lc_condizionipagamento.
      IF sy-subrc EQ 0.
        attr_condizionipagamento = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                       WITH KEY criteria = lc_giorniterminipagamento.
      IF sy-subrc EQ 0.
        attr_giorniterminipagamento = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                       WITH KEY criteria = lc_iban.
      IF sy-subrc EQ 0.
        attr_iban = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                       WITH KEY criteria = lc_modalitapagamento.
      IF sy-subrc EQ 0.
        attr_modalitapagamento = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
      READ TABLE attr_stat_pub_status ASSIGNING <lfs_status>
                                       WITH KEY criteria = lc_iddocumento.
      IF sy-subrc EQ 0.
        attr_iddocumento = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc NE 0
  ENDMETHOD. "CONSTRUCTOR
*------------------------------------------------------------------*
* METHOD: METH_INST_PUB_GET_INV_DATA
*------------------------------------------------------------------*
* Validate Company Code
*------------------------------------------------------------------*
* ---> IM_REGN      Scheduled Batch Job (Radio Button)
* ---> IM_BELNR     Document Number
* ---> IM_BUKRS     Company Code
* ---> IM_GJAHR     Fiscal Year
*------------------------------------------------------------------*
  METHOD meth_inst_pub_get_inv_data.
*-----------------------Local Internal Tables----------------------*
    DATA:
    li_adrc_uniq    TYPE STANDARD TABLE OF ty_kna1_data, " Addresses
    li_charges_cust TYPE STANDARD TABLE OF ty_intitit_data,
    li_bseg_d_cust  TYPE STANDARD TABLE OF ty_bseg_data. " Customer
*------------------------Local Field Symbols-----------------------*
*--Get the company stceg
    SELECT SINGLE stceg INTO attr_stat_pub_stceg FROM t001 " Company Codes
                                                 WHERE bukrs = im_bukrs.
    IF sy-subrc EQ 0.
    ENDIF. " IF sy-subrc EQ 0
*------------------------------Logic-------------------------------*
    IF im_belnr[] IS NOT INITIAL.
*&--Fetch Accounting Document Header Data
      SELECT bukrs " Company Code
             belnr " Accounting Document Number
             gjahr " Fiscal Year
             budat " Posting Date in the Document
             cpudt " Date of Entry
             waers " Currency Key
        FROM bkpf  " Accounting Document Header
        INTO TABLE attr_stat_pub_bkpf
       WHERE bukrs EQ im_bukrs
         AND belnr IN im_belnr
         AND gjahr EQ im_gjahr
         AND cpudt IN im_cpudt.
      IF sy-subrc NE 0.
*&--Raise Exception
        RAISE EXCEPTION TYPE cx_crm_genil_general_error
          EXPORTING
            text = 'No data found'(007).
      ENDIF. " IF sy-subrc NE 0
    ELSE. " ELSE -> IF im_belnr[] IS NOT INITIAL
*&--Fetch Accounting Document Header Data
      SELECT belnr_to   " Form Number for New Item Interest Calculation
             bukrs      " Company Code
             belnr      " Accounting Document Number
             gjahr      " Fiscal Year
             buzei      " Number of Line Item Within Accounting Document
             int_end    " FI Item Interest Calc.: End of Int. Calc. for Item/Int. Rate
             int_curr   " Currency Key
             int_amount " Amount in Document Currency (Foreign Currency)
             int_shkzg  " Debit/Credit Indicator
             int_cpudt  " Date of Entry
             account    " SD business partner identifier (number or code)
             koart      " Account Type
             buzei_to   " Number of Line Item Within Accounting Document
             form_to    " Form Number for New Item Interest Calculation
        FROM intitit    " Accounting Document Header
        INTO TABLE attr_stat_pub_intitit
       WHERE bukrs EQ im_bukrs
         AND gjahr EQ im_gjahr
         AND int_cpudt IN im_cpudt.
      IF sy-subrc NE 0.
*&--Raise Exception
        RAISE EXCEPTION TYPE cx_crm_genil_general_error
          EXPORTING
            text = 'No data found'(007).
      ELSE. " ELSE -> IF sy-subrc NE 0
        IF attr_stat_pub_intitit[] IS NOT INITIAL.
          SELECT * FROM zotc_int_charg " Interest charges
           APPENDING TABLE attr_stat_pub_update
           FOR ALL ENTRIES IN attr_stat_pub_intitit
           WHERE belnr = attr_stat_pub_intitit-belnr_to AND
                 bukrs = attr_stat_pub_intitit-bukrs.
          IF sy-subrc EQ 0.
          ENDIF. " IF sy-subrc EQ 0
*&--fetch accounting document header data
          SELECT bukrs " Company Code
                 belnr " Accounting Document Number
                 gjahr " Fiscal Year
                 budat " Posting Date in the Document
                 cpudt " Date of Entry
                 waers " Currency Key
            FROM bkpf  " Accounting Document Header
            INTO TABLE attr_stat_pub_bkpf
            FOR ALL ENTRIES IN attr_stat_pub_intitit
           WHERE bukrs EQ attr_stat_pub_intitit-bukrs
             AND belnr EQ attr_stat_pub_intitit-belnr_to
             AND gjahr EQ attr_stat_pub_intitit-gjahr.
          IF sy-subrc NE 0.
*&--Raise Exception
            RAISE EXCEPTION TYPE cx_crm_genil_general_error
              EXPORTING
                text = 'No data found'(007).
          ENDIF. " IF sy-subrc NE 0
        ENDIF. " IF attr_stat_pub_intitit[] IS NOT INITIAL
      ENDIF. " IF sy-subrc NE 0
    ENDIF. " IF im_belnr[] IS NOT INITIAL
    IF attr_stat_pub_bkpf[] IS NOT INITIAL.
*&--Fetch Accounting Document Segment Data
      SELECT bukrs " Company Code
             belnr " Accounting Document Number
             gjahr " Fiscal Year
             buzei " Number of Line Item
             buzid " Identification of the Line Item
             koart " Account Type
             shkzg " Debit/Credit Indicator
             wrbtr " Amount in Document Currency
             kunnr " Customer Number
             rebzg " Number of the Invoice the Transaction Belongs to
        FROM bseg  " Accounting Document Segment
        INTO TABLE attr_stat_pub_bseg
         FOR ALL ENTRIES IN attr_stat_pub_bkpf
       WHERE bukrs EQ attr_stat_pub_bkpf-bukrs
         AND belnr EQ attr_stat_pub_bkpf-belnr
         AND gjahr EQ attr_stat_pub_bkpf-gjahr.
      IF sy-subrc NE 0.
*&--Raise Exception
        RAISE EXCEPTION TYPE cx_crm_genil_general_error
          EXPORTING
            text = 'No data found'(007).
      ELSE. " ELSE -> IF sy-subrc NE 0
*&--Get Unique Customer Records
        li_bseg_d_cust[] = attr_stat_pub_bseg[].
        SORT li_bseg_d_cust BY kunnr.
        DELETE ADJACENT DUPLICATES FROM li_bseg_d_cust
                              COMPARING kunnr.
      ENDIF. " IF sy-subrc NE 0
      SELECT * FROM zotc_int_charg " Interest charges
               INTO TABLE attr_stat_pub_update
               FOR ALL ENTRIES IN attr_stat_pub_bkpf
               WHERE belnr = attr_stat_pub_bkpf-belnr AND
                     bukrs = attr_stat_pub_bkpf-bukrs.
      IF sy-subrc EQ 0.
      ENDIF. " IF sy-subrc EQ 0
    ELSE. " ELSE -> IF attr_stat_pub_bkpf[] IS NOT INITIAL
    ENDIF. " IF attr_stat_pub_bkpf[] IS NOT INITIAL
    IF li_bseg_d_cust[] IS NOT INITIAL.
*&--Fetch Customer Data
      SELECT kunnr " Customer Number
             land1 " Country Key
             adrnr " Address Number
             stceg " Tax Number 1
        FROM kna1  " General Data in Customer Master
        INTO TABLE attr_stat_pub_kna1
         FOR ALL ENTRIES IN li_bseg_d_cust
       WHERE kunnr EQ li_bseg_d_cust-kunnr.
      IF sy-subrc NE 0.
        FREE: li_bseg_d_cust.
      ENDIF. " IF sy-subrc NE 0
    ELSE. " ELSE -> IF li_bseg_d_cust[] IS NOT INITIAL
*&--Get Unique Customer Records
      li_charges_cust[] = attr_stat_pub_intitit[].
      SORT li_charges_cust BY account.
      DELETE ADJACENT DUPLICATES FROM li_charges_cust
                            COMPARING account.
      IF li_charges_cust[] IS NOT INITIAL.
*&--Fetch Customer Data
        SELECT kunnr " Customer Number
               land1 " Country Key
               adrnr " Address Number
               stceg " Tax Number 1
          FROM kna1  " General Data in Customer Master
          INTO TABLE attr_stat_pub_kna1
           FOR ALL ENTRIES IN li_charges_cust
         WHERE kunnr EQ li_charges_cust-account.
        IF sy-subrc NE 0.
          FREE: li_bseg_d_cust.
        ENDIF. " IF sy-subrc NE 0
      ENDIF. " IF li_charges_cust[] IS NOT INITIAL
    ENDIF. " IF li_bseg_d_cust[] IS NOT INITIAL
    li_adrc_uniq[] = attr_stat_pub_kna1[].
    SORT li_adrc_uniq BY adrnr.
    DELETE ADJACENT DUPLICATES FROM li_adrc_uniq COMPARING adrnr.
*&--Fetch Customer Address Data
    IF li_adrc_uniq[] IS NOT INITIAL.
      SELECT addrnumber " Address
             date_from  " Date From
             date_to    " Date To
             name1      " Name 1
             city2      " District
             post_code1 " City postal code
             street     " Street
             house_num1 " House Number
             house_num2 " House number supplement
             str_suppl1 " Street 2
             country    " Country Key
             region     " Region (State, Province, County)
             tel_number " Telephone Number
             mc_city1   " City name in upper case
        FROM adrc       " Addresses (Business Address Services)
        INTO TABLE attr_stat_pub_adrc
         FOR ALL ENTRIES IN li_adrc_uniq
       WHERE addrnumber = li_adrc_uniq-adrnr.
      IF sy-subrc EQ 0.
        DELETE attr_stat_pub_adrc WHERE date_from GE sy-datum.
        DELETE attr_stat_pub_adrc WHERE date_to   LE sy-datum.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF li_adrc_uniq[] IS NOT INITIAL
    SELECT SINGLE adrnr INTO attr_stat_pub_adrnr
                        FROM  t001 " Company Codes
                        WHERE bukrs = im_bukrs.
    IF sy-subrc EQ 0.
      SELECT addrnumber " Address
             date_from  " Date From
             date_to    " Date To
             name1      " Name 1
             city2      " District
             post_code1 " City postal code
             street     " Street
             house_num1 " House Number
             house_num2 " House number supplement
             str_suppl1 " Street 2
             country    " Country Key
             region     " Region (State, Province, County)
             tel_number " Telephone Number
             mc_city1   " City name in upper case
        FROM adrc       " Addresses (Business Address Services)
        APPENDING TABLE attr_stat_pub_adrc
       WHERE addrnumber = attr_stat_pub_adrnr.
      IF sy-subrc EQ 0.
        DELETE attr_stat_pub_adrc WHERE date_from GE sy-datum.
        DELETE attr_stat_pub_adrc WHERE date_to   LE sy-datum.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
    FREE: li_adrc_uniq,
          li_bseg_d_cust.
  ENDMETHOD. "METH_INST_PUB_GET_INV_DATA
*------------------------------------------------------------------*
* METHOD: METH_INST_PUB_SEND_IDOC
*------------------------------------------------------------------*
* Send Invoice Idoc
*------------------------------------------------------------------*
  METHOD meth_inst_pub_send_charges.
*--------------------------Local Variables-------------------------*
************************************************************************
*                          CLASS DECLARATIONS                          *
************************************************************************
    CONSTANTS:lc_e TYPE char1 VALUE 'E',                      " E of type CHAR1
              lc_tabname TYPE tabname VALUE 'ZOTC_INT_CHARG'. " Table Name
    DATA: lref_charges     TYPE REF TO z01otc_co_si_interest_charges,  " OTC_IDD_0219_InterestCharges
         lv_tabix          TYPE sy-tabix,                              " Index of Internal Tables
         lv_update         TYPE c,                                     " Update of type Character
          lv_name          TYPE tdobname,                              " Name
          wa_update        TYPE zotc_int_charg,                        " Interest charges
          wa_header        TYPE z01otc_fattura_elettronica_hea,        " Proxy Structure (generated)
          wa_body          TYPE z01otc_fattura_elettronica_bod,        " Proxy Structure (generated)
          wa_datidat       TYPE z01otc_dati_ddttype,                   " Proxy Structure (generated)
          wa_datirepligon  TYPE z01otc_dati_riepilogo_type,            " Proxy Structure (generated
          wa_line          TYPE z01otc_dettaglio_linee_type,           " Proxy Structure (generated)
          wa_pagemento     TYPE z01otc_dati_pagamento_type,            " Blocco relativo ai dati di Pagamento della Fattura  Elettroni
          wa_det_pagemento TYPE z01otc_dettaglio_pagamento_typ,        " Proxy Structure (generated)
          wa_dati_ordine_acquisto TYPE z01otc_dati_documenti_correlat, " Proxy Structure (generated)
          li_dati_ordine_acquisto TYPE z01otc_dati_documenti_corr_tab,
          li_datirepligo   TYPE z01otc_dati_riepilogo_type_tab,        " Proxy Structure (generated)
          li_body          TYPE z01otc_fattura_elettronica_tab,
          li_line          TYPE z01otc_dettaglio_linee_typ_tab,
          li_pagemento     TYPE z01otc_dati_pagamento_type_tab,
          li_datidat       TYPE z01otc_dati_ddttype_tab,
          lv_string        TYPE string,
          li_sub_txt       TYPE STANDARD TABLE OF tline,               " SAPscript: Text Lines
          li_update        TYPE TABLE OF zotc_int_charg,               " Interest charges
          li_charges       TYPE z01otc_fattura_elettronica,            " Class type ref to the proxy class
          li_det_pagemento TYPE z01otc_dettaglio_pagamento_tab,
          lr_sys_exc        TYPE REF TO cx_ai_system_fault,            " Application Integration: Technical Error
          l_exception_msg  TYPE string,
          lv_lang          TYPE thead-tdspras,                         " Language Key
          lv_amount        TYPE wrshb_x8.                              " Amount in Document Currency (Foreign Currency)
*------------------------Local Field Symbols-----------------------*
    FIELD-SYMBOLS:<lfs_intitit>   TYPE ty_intitit_data, " Enhancement Status
                  <lfs_sub_txt>   TYPE tline,           " SAPscript: Text Lines
                  <lfs_adrc>      TYPE ty_address,
                  <lfs_kna1>      TYPE ty_kna1_data,
                  <lfs_bkpf>      TYPE ty_bkpf_data,
                  <lfs_bseg>      TYPE ty_bseg_data,
                  <lfs_update>    TYPE zotc_int_charg.  " Interest charges
    REFRESH:li_update.
*--Loop At interest charges
    LOOP AT attr_stat_pub_intitit ASSIGNING <lfs_intitit>.
      AT NEW belnr_to.
        READ TABLE attr_stat_pub_update ASSIGNING  <lfs_update> WITH  KEY belnr = <lfs_intitit>-belnr_to
                                                                          data  = 'X'.
        IF sy-subrc EQ 0.
          WRITE:/ <lfs_intitit>-belnr_to,'Document was already sent, for re-send please check the re-generation check box'(006).
          CONTINUE.
        ENDIF. " IF sy-subrc EQ 0
        wa_header-dati_trasmissione-id_trasmittente-id_paese                  = attr_idpaese .
        wa_header-dati_trasmissione-id_trasmittente-id_codice                 = attr_idcodice.
        wa_header-dati_trasmissione-progressivo_invio                         = <lfs_intitit>-belnr_to.
        wa_header-dati_trasmissione-formato_trasmissione                      = attr_formatotrasmissione.
        CONCATENATE <lfs_intitit>-account <lfs_intitit>-bukrs '10' '00' INTO lv_name.
        lv_lang = 'S'.
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            client                  = sy-mandt
            id                      = 'Z010'
            language                = lv_lang
            name                    = lv_name
            object                  = 'KNVV'
          TABLES
            lines                   = li_sub_txt
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ELSE. " ELSE -> IF sy-subrc <> 0
          READ TABLE li_sub_txt ASSIGNING <lfs_sub_txt> INDEX 1.
          IF sy-subrc EQ 0.
            wa_header-dati_trasmissione-codice_destinatario = <lfs_sub_txt>-tdline.
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF sy-subrc <> 0
        wa_header-cedente_prestatore-dati_anagrafici-id_fiscale_iva-id_codice =  attr_stat_pub_stceg+2(18).
        wa_header-cedente_prestatore-dati_anagrafici-id_fiscale_iva-id_paese  =  attr_stat_pub_stceg+0(2).
        wa_header-cedente_prestatore-dati_anagrafici-codice_fiscale           = attr_stat_pub_stceg+2(18).
        wa_header-cedente_prestatore-dati_anagrafici-regime_fiscale           = attr_regimefiscale.
        READ TABLE attr_stat_pub_adrc ASSIGNING <lfs_adrc> WITH KEY adrnr = attr_stat_pub_adrnr.
        IF sy-subrc EQ 0.
          wa_header-cedente_prestatore-dati_anagrafici-anagrafica-denominazione = <lfs_adrc>-name1.
          CONCATENATE <lfs_adrc>-street <lfs_adrc>-house_num1 INTO wa_header-cedente_prestatore-sede-indirizzo SEPARATED BY ','.
          wa_header-cedente_prestatore-sede-cap                               =  <lfs_adrc>-post_code1.
          wa_header-cedente_prestatore-sede-comune                            = <lfs_adrc>-mc_city1.
          wa_header-cedente_prestatore-sede-provincia                         = <lfs_adrc>-region.
          wa_header-cedente_prestatore-sede-nazione                           = <lfs_adrc>-country.
          wa_header-cedente_prestatore-iscrizione_rea-ufficio                 = <lfs_adrc>-region.
          wa_header-cedente_prestatore-iscrizione_rea-numero_rea              = attr_numerorea.
          wa_header-cedente_prestatore-iscrizione_rea-capitale_sociale        = attr_capitalesociale.
          wa_header-cedente_prestatore-iscrizione_rea-socio_unico             = attr_sociounico.
          wa_header-cedente_prestatore-iscrizione_rea-stato_liquidazione      = attr_statoliquidazione.
        ENDIF. " IF sy-subrc EQ 0
        READ TABLE attr_stat_pub_kna1 ASSIGNING <lfs_kna1> WITH KEY kunnr = <lfs_intitit>-account.
        IF sy-subrc EQ 0.
          wa_header-cessionario_committente-dati_anagrafici-id_fiscale_iva-id_paese  = <lfs_kna1>-stceg+0(2).
          wa_header-cessionario_committente-dati_anagrafici-id_fiscale_iva-id_codice = <lfs_kna1>-stceg+2(18).
          wa_header-cessionario_committente-dati_anagrafici-codice_fiscale           = <lfs_kna1>-stceg+2(18).
          READ TABLE attr_stat_pub_adrc ASSIGNING <lfs_adrc> WITH KEY adrnr = <lfs_kna1>-adrnr.
          IF sy-subrc EQ 0.
            CONCATENATE <lfs_adrc>-street <lfs_adrc>-house_num1 INTO  wa_header-cessionario_committente-sede-indirizzo SEPARATED BY ', '.
            wa_header-cessionario_committente-dati_anagrafici-anagrafica-denominazione = <lfs_adrc>-name1.
            wa_header-cessionario_committente-sede-cap =  <lfs_adrc>-post_code1.
            wa_header-cessionario_committente-sede-comune = <lfs_adrc>-mc_city1.
            wa_header-cessionario_committente-sede-provincia = <lfs_adrc>-region.
            wa_header-cessionario_committente-sede-nazione = <lfs_adrc>-country.
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF sy-subrc EQ 0
        wa_header-terzo_intermediario_osoggetto-dati_anagrafici-id_fiscale_iva-id_paese  = attr_idpaese_terzo.
        wa_header-terzo_intermediario_osoggetto-dati_anagrafici-id_fiscale_iva-id_codice = attr_idcodice_terzo.
        wa_header-terzo_intermediario_osoggetto-dati_anagrafici-anagrafica-denominazione = attr_denominazione.
        CONCATENATE attr_idpaese_terzo attr_idcodice_terzo INTO  wa_header-terzo_intermediario_osoggetto-dati_anagrafici-anagrafica-cod_eori.
        wa_header-soggetto_emittente                                                     = attr_soggettoemittente.
        li_charges-fattura_elettronica-fattura_elettronica_header = wa_header.
      ENDAT.
      READ TABLE attr_stat_pub_update ASSIGNING  <lfs_update> WITH  KEY belnr = <lfs_intitit>-belnr_to
                                                                  data  = 'X'.
      IF sy-subrc EQ 0.
        WRITE:/ <lfs_intitit>-belnr_to,'Document was already sent, for re-send please check the re-generation check box'(006).
        CONTINUE.
      ENDIF. " IF sy-subrc EQ 0
      wa_line-numero_linea = <lfs_intitit>-buzei_to.
      CONCATENATE 'FATTURA' <lfs_intitit>-belnr 'GG' INTO wa_line-descrizione SEPARATED BY space.
      wa_line-quantita     = '1'.
      wa_line-unita_misura = attr_unitamisura.
      wa_line-prezzo_unitario = <lfs_intitit>-int_amount.
      wa_line-prezzo_totale   = <lfs_intitit>-int_amount.
      wa_line-aliquota_iva    = '0.00'.
      wa_line-natura          = attr_natura.
      APPEND wa_line TO li_line.
      lv_amount = lv_amount + <lfs_intitit>-int_amount.
      wa_body-dati_generali-dati_generali_documento-importo_totale_documento = lv_amount.
      wa_body-dati_beni_servizi-dettaglio_linee = li_line.
      AT END OF belnr_to. " Form Number for New Item Interest Calculation.
        wa_body-dati_generali-dati_generali_documento-tipo_documento            = attr_tipodocumento.
        wa_body-dati_generali-dati_generali_documento-divisa                    = <lfs_intitit>-int_curr.
        wa_body-dati_generali-dati_generali_documento-numero                    = <lfs_intitit>-belnr.
        READ TABLE attr_stat_pub_bkpf ASSIGNING <lfs_bkpf> WITH KEY belnr = <lfs_intitit>-belnr_to
                                                                    bukrs = <lfs_intitit>-bukrs
                                                                    gjahr = <lfs_intitit>-gjahr.
        IF sy-subrc EQ 0 AND <lfs_bkpf> IS ASSIGNED.
          wa_body-dati_generali-dati_generali_documento-data                      = <lfs_bkpf>-budat.
        ENDIF. " IF sy-subrc EQ 0 AND <lfs_bkpf> IS ASSIGNED
        wa_body-dati_generali-dati_generali_documento-dati_bollo-bollo_virtuale = attr_bollovirtuale.
        wa_body-dati_generali-dati_generali_documento-dati_bollo-importo_bollo  = attr_importobollo.
        wa_dati_ordine_acquisto-id_documento = attr_iddocumento.
        APPEND wa_dati_ordine_acquisto TO li_dati_ordine_acquisto.
        wa_body-dati_generali-dati_ordine_acquisto = li_dati_ordine_acquisto.
        wa_datirepligon-aliquota_iva = '0.00'.
        wa_datirepligon-natura       = attr_natura.
        wa_datirepligon-imponibile_importo = wa_body-dati_generali-dati_generali_documento-importo_totale_documento..
        wa_datirepligon-imposta            = '0.00'.
        wa_datirepligon-esigibilita_iva    = attr_esigibilitaiva.
        wa_datirepligon-riferimento_normativo = attr_riferimentonormativo.
        APPEND wa_datirepligon TO li_datirepligo.
        wa_body-dati_beni_servizi-dati_riepilogo = li_datirepligo.
        wa_pagemento-condizioni_pagamento = attr_condizionipagamento.
        wa_det_pagemento-modalita_pagamento = attr_modalitapagamento.
        wa_det_pagemento-data_riferimento_termini_pagam = <lfs_intitit>-int_cpudt.
        wa_det_pagemento-giorni_termini_pagamento       = attr_giorniterminipagamento.
        wa_det_pagemento-data_scadenza_pagamento        = <lfs_intitit>-int_cpudt + attr_giorniterminipagamento.
        wa_det_pagemento-importo_pagamento              = wa_body-dati_generali-dati_generali_documento-importo_totale_documento..
        wa_det_pagemento-iban                           = attr_iban.
        wa_det_pagemento-bic                            = attr_bic.
        APPEND wa_det_pagemento TO li_det_pagemento.
        wa_pagemento-dettaglio_pagamento = li_det_pagemento.
        APPEND wa_pagemento TO li_pagemento.
        wa_body-dati_pagamento = li_pagemento.
        APPEND wa_body TO li_body.
        li_charges-fattura_elettronica-fattura_elettronica_body = li_body.
        li_charges-fattura_elettronica-versione  = 'FPA12'.
        CREATE OBJECT lref_charges.
        TRY.
            CALL METHOD lref_charges->si_interest_charges_out
              EXPORTING
                output = li_charges.
          CATCH cx_ai_system_fault INTO lr_sys_exc .
            IF lr_sys_exc IS NOT INITIAL.
              lv_string = lr_sys_exc->get_text( ).
              WRITE: lv_string.
            ENDIF. " IF lr_sys_exc IS NOT INITIAL
        ENDTRY.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
        IF sy-subrc EQ 0.
          wa_update-belnr          = <lfs_intitit>-belnr_to.
          wa_update-bukrs          = <lfs_intitit>-bukrs.
          wa_update-gjahr          = <lfs_intitit>-gjahr.
          wa_update-intform        = <lfs_intitit>-form_to.
          wa_update-zz_lastchanged = sy-uname.
          wa_update-zz_change_date = sy-datum.
          wa_update-zz_change_time = sy-uzeit.
          wa_update-data          = 'X'.
          APPEND wa_update TO li_update.
        ENDIF. " IF sy-subrc EQ 0
        WRITE:/ <lfs_intitit>-belnr_to,'Document sent Sucessfully'(009).
        CLEAR:wa_header,wa_body,wa_pagemento,wa_det_pagemento,wa_body-dati_generali-dati_generali_documento-importo_totale_documento,lv_amount,lv_string.
        REFRESH:li_body,li_det_pagemento,li_pagemento,li_line,li_dati_ordine_acquisto,
                li_datirepligo,li_datidat,li_sub_txt.
        FREE:li_charges.
      ENDAT.
    ENDLOOP. " LOOP AT attr_stat_pub_intitit ASSIGNING <lfs_intitit>
*--Bkpf
    LOOP AT attr_stat_pub_bkpf ASSIGNING <lfs_bkpf>.
      AT NEW belnr.
        READ TABLE attr_stat_pub_update ASSIGNING  <lfs_update> WITH  KEY belnr = <lfs_bkpf>-belnr
                                                                          data  = 'X'.
        IF sy-subrc NE 0.
*-- Begin of changes for d#5532 by mthatha
          IF im_regn IS NOT INITIAL.
            WRITE:/ <lfs_bkpf>-belnr,'Document does not exist in data base'(008).
            CONTINUE.
          ENDIF. " IF im_regn IS NOT INITIAL
        ELSE. " ELSE -> IF sy-subrc NE 0
          IF im_regn IS INITIAL.
            WRITE:/ <lfs_bkpf>-belnr,'Document was already sent, for re-send please check the re-generation check '(006).
            CONTINUE.
          ENDIF. " IF im_regn IS INITIAL
*--End of changes for d#5532 by mthatha
        ENDIF. " IF sy-subrc NE 0
        IF <lfs_update> IS NOT ASSIGNED AND im_regn IS INITIAL.
          lv_update = 'X'.
        ENDIF. " IF <lfs_update> IS NOT ASSIGNED AND im_regn IS INITIAL
        wa_header-dati_trasmissione-id_trasmittente-id_paese                            = attr_idpaese.
        wa_header-dati_trasmissione-id_trasmittente-id_codice                           = attr_idcodice.
        wa_header-dati_trasmissione-progressivo_invio                                   = <lfs_bkpf>-belnr.
        wa_header-dati_trasmissione-formato_trasmissione                                = attr_formatotrasmissione.
        wa_header-cedente_prestatore-dati_anagrafici-id_fiscale_iva-id_codice           = attr_stat_pub_stceg+2(18).
        wa_header-cedente_prestatore-dati_anagrafici-id_fiscale_iva-id_paese            = attr_stat_pub_stceg+0(2).
        wa_header-cedente_prestatore-dati_anagrafici-codice_fiscale                     = attr_stat_pub_stceg+2(18).
        wa_header-cedente_prestatore-dati_anagrafici-regime_fiscale                     = attr_regimefiscale.
        READ TABLE attr_stat_pub_bseg ASSIGNING <lfs_bseg> WITH KEY belnr = <lfs_bkpf>-belnr
                                                                    koart = 'D'.
        IF sy-subrc EQ 0.
          CONCATENATE <lfs_bseg>-kunnr <lfs_bseg>-bukrs '10' '00' INTO lv_name.
          lv_lang = 'I'.
          CALL FUNCTION 'READ_TEXT'
            EXPORTING
              client                  = sy-mandt
              id                      = 'Z010'
              language                = lv_lang
              name                    = lv_name
              object                  = 'KNVV'
            TABLES
              lines                   = li_sub_txt
            EXCEPTIONS
              id                      = 1
              language                = 2
              name                    = 3
              not_found               = 4
              object                  = 5
              reference_check         = 6
              wrong_access_to_archive = 7
              OTHERS                  = 8.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ELSE. " ELSE -> IF sy-subrc <> 0
            READ TABLE li_sub_txt ASSIGNING <lfs_sub_txt> INDEX 1.
            IF sy-subrc EQ 0.
              wa_header-dati_trasmissione-codice_destinatario = <lfs_sub_txt>-tdline.
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF sy-subrc <> 0
        ENDIF. " IF sy-subrc EQ 0
        READ TABLE attr_stat_pub_adrc ASSIGNING <lfs_adrc> WITH KEY adrnr = attr_stat_pub_adrnr.
        IF sy-subrc EQ 0.
          wa_header-cedente_prestatore-dati_anagrafici-anagrafica-denominazione         = <lfs_adrc>-name1.
          CONCATENATE <lfs_adrc>-street <lfs_adrc>-house_num1 INTO wa_header-cedente_prestatore-sede-indirizzo SEPARATED BY ','.
          wa_header-cedente_prestatore-sede-cap                                         =  <lfs_adrc>-post_code1.
          wa_header-cedente_prestatore-sede-comune                                      = <lfs_adrc>-mc_city1.
          wa_header-cedente_prestatore-sede-provincia                                   = <lfs_adrc>-region.
          wa_header-cedente_prestatore-sede-nazione                                     = <lfs_adrc>-country.
          wa_header-cedente_prestatore-iscrizione_rea-ufficio                           = <lfs_adrc>-region.
          wa_header-cedente_prestatore-iscrizione_rea-numero_rea                        = attr_numerorea.
          wa_header-cedente_prestatore-iscrizione_rea-capitale_sociale                  = attr_capitalesociale.
          wa_header-cedente_prestatore-iscrizione_rea-socio_unico                       = attr_sociounico.
          wa_header-cedente_prestatore-iscrizione_rea-stato_liquidazione                = attr_statoliquidazione.
        ENDIF. " IF sy-subrc EQ 0
        READ TABLE attr_stat_pub_kna1 ASSIGNING <lfs_kna1> WITH KEY kunnr = <lfs_bseg>-kunnr.
        IF sy-subrc EQ 0.
          wa_header-cessionario_committente-dati_anagrafici-id_fiscale_iva-id_paese  = <lfs_kna1>-stceg+0(2).
          wa_header-cessionario_committente-dati_anagrafici-id_fiscale_iva-id_codice = <lfs_kna1>-stceg+2(18).
          wa_header-cessionario_committente-dati_anagrafici-codice_fiscale           = <lfs_kna1>-stceg+2(18).
          READ TABLE attr_stat_pub_adrc ASSIGNING <lfs_adrc> WITH KEY adrnr = <lfs_kna1>-adrnr.
          IF sy-subrc EQ 0.
            wa_header-cessionario_committente-dati_anagrafici-anagrafica-denominazione   = <lfs_adrc>-name1.
            CONCATENATE <lfs_adrc>-street <lfs_adrc>-house_num1 INTO  wa_header-cessionario_committente-sede-indirizzo SEPARATED BY ', '.
            wa_header-cessionario_committente-sede-cap                                  =  <lfs_adrc>-post_code1.
            wa_header-cessionario_committente-sede-comune                               = <lfs_adrc>-mc_city1.
            wa_header-cessionario_committente-sede-provincia                            = <lfs_adrc>-region.
            wa_header-cessionario_committente-sede-nazione                              = <lfs_adrc>-country.
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF sy-subrc EQ 0
        wa_header-terzo_intermediario_osoggetto-dati_anagrafici-id_fiscale_iva-id_paese  = attr_idpaese_terzo.
        wa_header-terzo_intermediario_osoggetto-dati_anagrafici-id_fiscale_iva-id_codice = attr_idcodice_terzo.
        wa_header-terzo_intermediario_osoggetto-dati_anagrafici-anagrafica-denominazione = attr_denominazione.
        CONCATENATE attr_idpaese_terzo attr_idcodice_terzo INTO wa_header-terzo_intermediario_osoggetto-dati_anagrafici-anagrafica-cod_eori.
        wa_header-soggetto_emittente                                                     = attr_soggettoemittente.
        li_charges-fattura_elettronica-fattura_elettronica_header = wa_header.
      ENDAT.
      AT END OF belnr.
        wa_body-dati_generali-dati_generali_documento-tipo_documento            = attr_tipodocumento.
        wa_body-dati_generali-dati_generali_documento-divisa                    = <lfs_bkpf>-waers.
        wa_body-dati_generali-dati_generali_documento-numero                    = <lfs_bkpf>-belnr.
        wa_body-dati_generali-dati_generali_documento-data                      = <lfs_bkpf>-cpudt.
        wa_body-dati_generali-dati_generali_documento-dati_bollo-bollo_virtuale = attr_bollovirtuale.
        wa_body-dati_generali-dati_generali_documento-dati_bollo-importo_bollo  = attr_importobollo.
        READ TABLE attr_stat_pub_bseg ASSIGNING <lfs_bseg>
                                     WITH KEY belnr = <lfs_bkpf>-belnr
                                              bukrs = <lfs_bkpf>-bukrs
                                              gjahr = <lfs_bkpf>-gjahr.
        IF sy-subrc = 0. "Does not enter the inner loop
          lv_tabix = sy-tabix.
          LOOP AT attr_stat_pub_bseg ASSIGNING <lfs_bseg> FROM lv_tabix.
            IF <lfs_bseg>-belnr <> <lfs_bkpf>-belnr . "This checks whether to exit out of loop
              EXIT.
            ENDIF. " IF <lfs_bseg>-belnr <> <lfs_bkpf>-belnr
            IF <lfs_bseg>-koart = 'S'.
              CONTINUE.
            ENDIF. " IF <lfs_bseg>-koart = 'S'
            lv_amount = lv_amount + <lfs_bseg>-wrbtr.
            wa_body-dati_generali-dati_generali_documento-importo_totale_documento = lv_amount.
            wa_line-numero_linea = <lfs_bseg>-buzei.
            CONCATENATE 'FATTURA' <lfs_bseg>-rebzg 'GG' INTO wa_line-descrizione SEPARATED BY space.
            wa_line-quantita                              = '1'.
            wa_line-unita_misura                          = attr_unitamisura.
            wa_line-prezzo_unitario                       = <lfs_bseg>-wrbtr.
            wa_line-prezzo_totale                         = <lfs_bseg>-wrbtr.
            wa_line-aliquota_iva                          = '0.00'.
            wa_line-natura                                = attr_natura.
            APPEND wa_line TO li_line.
            wa_body-dati_beni_servizi-dettaglio_linee     = li_line.
          ENDLOOP. " LOOP AT attr_stat_pub_bseg ASSIGNING <lfs_bseg> FROM lv_tabix
        ENDIF. " IF sy-subrc = 0
        wa_dati_ordine_acquisto-id_documento            = attr_iddocumento.
        APPEND wa_dati_ordine_acquisto TO li_dati_ordine_acquisto.
        wa_body-dati_generali-dati_ordine_acquisto      = li_dati_ordine_acquisto.
        wa_datirepligon-aliquota_iva                    = '0.00'.
        wa_datirepligon-natura                          = attr_natura.
        wa_datirepligon-imponibile_importo              = wa_body-dati_generali-dati_generali_documento-importo_totale_documento.
        wa_datirepligon-imposta                         = '0.00'.
        wa_datirepligon-esigibilita_iva                 = attr_esigibilitaiva.
        wa_datirepligon-riferimento_normativo           = attr_riferimentonormativo.
        APPEND wa_datirepligon TO li_datirepligo.
        CLEAR wa_datirepligon.
        wa_body-dati_beni_servizi-dati_riepilogo        = li_datirepligo.
        wa_pagemento-condizioni_pagamento               = attr_condizionipagamento.
        wa_det_pagemento-modalita_pagamento             = attr_modalitapagamento.
        wa_det_pagemento-data_riferimento_termini_pagam = <lfs_bkpf>-cpudt.
        wa_det_pagemento-giorni_termini_pagamento       = attr_giorniterminipagamento.
        wa_det_pagemento-data_scadenza_pagamento        = <lfs_bkpf>-cpudt + attr_giorniterminipagamento.
        wa_det_pagemento-importo_pagamento              = wa_body-dati_generali-dati_generali_documento-importo_totale_documento.
        wa_det_pagemento-iban                           = attr_iban.
        wa_det_pagemento-bic                            = attr_bic.
        APPEND wa_det_pagemento TO li_det_pagemento.
        wa_pagemento-dettaglio_pagamento = li_det_pagemento.
        APPEND wa_pagemento TO li_pagemento.
        wa_body-dati_pagamento = li_pagemento.
        APPEND wa_body TO li_body.
        li_charges-fattura_elettronica-fattura_elettronica_body = li_body.
        li_charges-fattura_elettronica-versione                 = 'FPA12'.
        CREATE OBJECT lref_charges.
        TRY.
            CALL METHOD lref_charges->si_interest_charges_out
              EXPORTING
                output = li_charges.
          CATCH cx_ai_system_fault INTO lr_sys_exc.
            IF lr_sys_exc IS NOT INITIAL.
              lv_string = lr_sys_exc->get_text( ).
            ENDIF. " IF lr_sys_exc IS NOT INITIAL
        ENDTRY.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
        IF sy-subrc EQ 0 AND lv_update IS NOT INITIAL.
          WRITE:/ <lfs_bkpf>-belnr,'Document sent Sucessfully'(009).
          wa_update-belnr          =  <lfs_bkpf>-belnr.
          wa_update-bukrs          =  <lfs_bkpf>-bukrs.
          wa_update-gjahr          =  <lfs_bkpf>-gjahr.
          wa_update-zz_lastchanged = sy-uname.
          wa_update-zz_change_date = sy-datum.
          wa_update-zz_change_time = sy-uzeit.
          wa_update-data          = 'X'.
          APPEND wa_update TO li_update.
          CLEAR wa_update.
        ELSE. " ELSE -> IF sy-subrc EQ 0 AND lv_update IS NOT INITIAL
          WRITE:/ <lfs_bkpf>-belnr,'Document sent Sucessfully'(009).
        ENDIF. " IF sy-subrc EQ 0 AND lv_update IS NOT INITIAL
        CLEAR:wa_header,wa_body,wa_pagemento,wa_det_pagemento,wa_body-dati_generali-dati_generali_documento-importo_totale_documento,lv_amount,lv_string,lv_update.
        REFRESH:li_body,li_det_pagemento,li_pagemento,li_line,li_dati_ordine_acquisto,
                li_datirepligo,li_datidat,li_sub_txt.
        FREE:li_charges,lref_charges.
      ENDAT.
    ENDLOOP. " LOOP AT attr_stat_pub_bkpf ASSIGNING <lfs_bkpf>
*--When the records sent sucessfully
    IF li_update[] IS NOT INITIAL.
*  Lock table
      CALL FUNCTION 'ENQUEUE_E_TABLEE'
        EXPORTING
          mode_rstable   = lc_e
          tabname        = lc_tabname
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.
      IF sy-subrc EQ 0.
        INSERT zotc_int_charg FROM TABLE li_update.
*      Fill return table with success message if deleted successfully
        IF sy-subrc EQ 0.
*--Begin of changes for d#5532 by mthatha
          REFRESH:li_update.
*--End of changes for d#5532 by mthatha
*      Fill return table with success message if deletion fails
        ELSE. " ELSE -> IF sy-subrc EQ 0
        ENDIF. " IF sy-subrc EQ 0
*     Unlock table
        CALL FUNCTION 'DEQUEUE_E_TABLEE'
          EXPORTING
            mode_rstable = lc_e
            tabname      = lc_tabname.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF li_update[] IS NOT INITIAL
  ENDMETHOD. "METH_INST_PUB_SEND_IDOC
*------------------------------------------------------------------*
* METHOD: METH_INST_PUB_FREE
*------------------------------------------------------------------*
* Free Class Attributes
*------------------------------------------------------------------*
  METHOD meth_inst_pub_free.
    REFRESH:attr_stat_pub_status,attr_stat_pub_bkpf.
  ENDMETHOD. "METH_INST_PUB_FREE
ENDCLASS. "LCL_PRO  CESS IMPLEMENTATION
