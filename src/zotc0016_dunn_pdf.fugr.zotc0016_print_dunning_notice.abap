FUNCTION ZOTC0016_PRINT_DUNNING_NOTICE.
*"--------------------------------------------------------------------
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
*"--------------------------------------------------------------------
  DATA: langu     LIKE sy-langu,       "Language of the master record
        lang2     LIKE sy-langu,    "Language of the form (second guess)
        incl_item LIKE boole-boole,    "include item in dunning letter?
        incl_mhnk LIKE boole-boole,
        i_itcpp   LIKE itcpp,          "Sapscript return structure
        h_msgno   LIKE sy-msgno,
        h_archive_index   LIKE toa_dara,
        h_archive_params  LIKE arc_params,
        smschl_before LIKE mhnd-smschl.

  CLEAR: adrnr, uadrnr.
  gb_archive_mail = space.
  i_itcpo-tdprogram = sy-repid.
  gb_update = i_update. " save in memory of function-group, so that form
  " can access it.

* CONCATENATE i_mhnk-kunnr i_mhnk-bukrs INTO   thead-tdname. "1551010
  thead-tdname = '&1&2'.                                     "1551010
  REPLACE '&1' WITH I_MHNK-KUNNR INTO thead-tdname.          "1551010
  REPLACE '&2' WITH I_MHNK-BUKRS INTO thead-tdname.          "1551010

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
  ELSE.
    PERFORM log_msg USING h_msgno i_mhnk-koart i_mhnk-lifnr space space.
  ENDIF.

* check the mhnk and mhnd entries if item is to be dunned
  PERFORM check_dunning_data TABLES   t_mhnd
                             USING    i_mhnk
                             CHANGING incl_mhnk.
*  CHECK INCL_MHNK = 'X'.
  IF incl_mhnk EQ space.
    RAISE accnt_block.
  ENDIF.

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
  ENDIF.

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
  itcpo = i_itcpo.

* open the dunning form
  PERFORM open_dunning_form    USING    f150v t047e
                                        finaa langu
                                        h_archive_index
                                        h_archive_params
                               CHANGING i_itcpo i_itcpp lang2.

  IF langu <> lang2 AND NOT I_MHNK-BUSAB IS INITIAL.            "1342715
    CALL FUNCTION 'CORRESPONDENCE_DATA_BUSAB'                   "1342715
      EXPORTING
        I_BUKRS         = I_MHNK-BUKRS
        I_BUSAB         = I_MHNK-BUSAB
        I_LANGU         = LANG2
      IMPORTING
        E_T001S         = T001S
        E_FSABE         = FSABE
      EXCEPTIONS
        BUSAB_NOT_FOUND = 01
        OTHERS          = 02.                                   "1342715
  ENDIF.                                                        "1342715

* create remittance advice in
  PERFORM create_remadv       TABLES   t_mhnd
                              USING    i_update i_mhnk t047b t047e
                              CHANGING i_mhnk-avsid.

* init the payment form
  PERFORM init_payment_struct USING     finaa t047e
                              CHANGING  paymo paymi.

* if form language and requested language differ display message
  IF langu <> lang2.
    IF mhnk-koart = 'D'.
      IF 1 = 0. MESSAGE s209. ENDIF.
      PERFORM log_msg USING '209' t047e-fornr kna1-kunnr
                                  knb1-bukrs langu.
    ELSE.
      IF 1 = 0. MESSAGE s210. ENDIF.
      PERFORM log_msg USING '210' t047e-fornr lfa1-lifnr
                                  lfb1-bukrs langu.
    ENDIF.
  ENDIF.

* write information to the dunning print form (header)
  PERFORM write_header         USING i_mhnk i_mahnv i_update.

  DATA: l_xbegin(1) type C.
  LOOP AT t_mhnd.
*   check wether the item should be include in the dunning notice or not
    PERFORM check_item           USING    t047b i_mhnk t_mhnd
                                 CHANGING incl_item.

*   read the complete item information (bsec,bseg,bkpf)
    PERFORM read_document        changing  t_mhnd
                                           f150d *f150d mhnd
                                 bkpf bseg bsec.

*   complete mhnd with previous calculated values
    PERFORM complete_mhnd        USING    i_mhnk
                                 CHANGING mhnd.

*   read additional infomation tables (t003t,tbslt)
    PERFORM read_tables          USING    t_mhnd langu
                                 CHANGING t003t tbslt.

*   init esr procedure
    PERFORM init_esr_line        CHANGING f150d_esr.

    IF incl_item = 'X'.
      IF t_mhnd-smschl <> smschl_before AND smschl_before <> space.
        PERFORM write_end_mschl.
        clear l_xbegin.
      ENDIF.

*     determine and write the special dunning key begin
      IF t_mhnd-smschl <> smschl_before AND  t_mhnd-smschl <> space.
        PERFORM read_mschl         USING    t_mhnd langu lang2
                                   CHANGING t040a.
        PERFORM write_begin_mschl.
        l_xbegin = 'X'.
      ENDIF.

*     write the line item to the form
      PERFORM write_line.
      smschl_before = t_mhnd-smschl.
*     store the item dunning data for later update
      IF mhnd-mahns > 0 OR mhnd-mahnn > 0 OR
             NOT i_mhnk-gmvdt IS INITIAL.
        PERFORM add_updbel   TABLES updbel USING mhnd.
      ENDIF.
    ENDIF.
*     add the current values to the sumation tables
    PERFORM collect_sums TABLES saltab sumtab USING mhnd incl_item.
  ENDLOOP.

  IF NOT l_xbegin IS INITIAL.
    PERFORM write_end_mschl.
    clear l_xbegin.
  ENDIF.

* calculate and write the dunning charges if applicable
  IF i_mhnk-gmvdt IS INITIAL.
    PERFORM calc_dunning_charges   TABLES   sumtab
                                   USING    t001 t047c
                                   CHANGING f150d.

    PERFORM write_dunning_charges  USING f150d.
  ENDIF.

* get all the necessary ESR information if applicable
*  PERFORM get_esr_information      TABLES   t_mhnd
*                                   USING    i_mhnk f150d
*                                   CHANGING bnka sadr f150d_esr.

* write information to the dunning print form (Footer)
  PERFORM write_footer TABLES   saltab sumtab
                       USING    t001
                                i_mhnk-xzins
                       CHANGING f150d.

* get all the necessary ESR information if applicable
  PERFORM get_esr_information      TABLES   t_mhnd
                                   USING    i_mhnk f150d
                                   CHANGING bnka sadr f150d_esr.

* fill the structure for payment forms
  PERFORM fill_payment_struct TABLES   t_mhnd sumtab
                              USING    finaa i_f150v f150d t047e
                                       i_mhnk adrs
                              CHANGING paymi paymo.

  if not t047e-zlsch is initial.
  f150d_esr-mtein =  paymo-esrnr.  f150d_esr-mkodz =  paymo-mkodz.
  f150d_esr-mbetr =  paymo-mbetr.  f150d_esr-mrefn =  paymo-mrefn.
  endif.

* close the dunning form
  gd_lifnr_last       = t_mhnd-lifnr.                       "1042992
  gd_kunnr_last       = t_mhnd-kunnr.                       "1042992
  gd_bukrs_last       = t_mhnd-bukrs.                       "1042992
  PERFORM close_dunning_form USING  fsabe finaa i_itcpp
                                    i_itcpo langu lang2
                                    i_update paymo          "1042992
                                    h_archive_index
                                    h_archive_params.

* update dunning data in master and item recors
  PERFORM update_data TABLES updbel USING i_update i_mhnk updkto updver.

* request a commit work from caller after 10 dunning notices,
* for email direct here after each email                      "923289
  IF updcnt > 10 OR finaa-nacha ='I'.                         "923289
    updcnt   = 0.
    e_comreq = 'X'.
  ENDIF.
  updcnt = updcnt + 1.

* log the apropriate messages
  IF i_mout = 'X'.
    IF NOT sy-batch IS INITIAL.
      CALL FUNCTION 'FI_MESSAGE_PROTOCOL'
        EXCEPTIONS
          no_message = 1
          not_batch  = 2
          OTHERS     = 3.
    ELSE.
      CALL FUNCTION 'FI_MESSAGE_PRINT'
        EXPORTING
          i_xausn = 'X'
          i_comsg = 0
        EXCEPTIONS
          OTHERS  = 0.
    ENDIF.
  ENDIF.
  IF t_fimsg IS REQUESTED.
    CALL FUNCTION 'FI_MESSAGE_GET'
      TABLES
        t_fimsg    = t_fimsg
      EXCEPTIONS
        no_message = 1
        OTHERS     = 2.
  ENDIF.
ENDFUNCTION.

*&---------------------------------------------------------------------*
*&      Form  INIT_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_print USING i_mhnk  LIKE mhnk
                      i_f150v LIKE f150v.
  page   = 1.
  status = space.
  CLEAR f150d.
  CLEAR f150d_esr.
  mhnk   = i_mhnk.
  f150v  = i_f150v.
  REFRESH  sumtab.
  REFRESH  saltab.
ENDFORM.                               " INIT_PRINT


*&---------------------------------------------------------------------*
*&      Form  CALCULATE_HOLIDAYS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MHNK  text                                               *
*      -->P_T047A  text                                                *
*      <--P_F150D  text                                                *
*----------------------------------------------------------------------*
FORM calculate_holidays USING    i_mhnk  LIKE mhnk
                                 i_t047a LIKE t047a
                                 i_t047b LIKE t047b
                        CHANGING e_f150d LIKE f150d.
  DATA:
    datum LIKE f150d-zield,
    xfeit LIKE scal-indicator,
    tag   LIKE scal-indicator,         "1-5= Werktag, 6+7 Wochenende
    fattr LIKE thol OCCURS 0 WITH HEADER LINE.

  e_f150d-zield = i_mhnk-ausdt.
  e_f150d-zield = e_f150d-zield + i_t047b-zfrst.
  IF i_t047a-kalid NE space.           "Feiertagkalender-Id
    LOOP AT werktab WHERE zield = e_f150d-zield.
      EXIT.
    ENDLOOP.
    IF sy-subrc NE 0.
      xfeit = 'X'.
      werktab-zield = e_f150d-zield.
      WHILE xfeit NE space.
        CLEAR tag.
        CLEAR xfeit.
        CALL FUNCTION 'DATE_COMPUTE_DAY'
          EXPORTING
            date = e_f150d-zield
          IMPORTING
            day  = tag.
        IF tag <> '6' AND tag <> '7'.
          CALL FUNCTION 'HOLIDAY_CHECK_AND_GET_INFO'
            EXPORTING
              date                         = e_f150d-zield
              holiday_calendar_id          = i_t047a-kalid
              with_holiday_attributes      = ' '
            IMPORTING
              holiday_found                = xfeit
            TABLES
              holiday_attributes           = fattr  "Dummy
            EXCEPTIONS
              calendar_buffer_not_loadable = 01
              date_after_range             = 02
              date_before_range            = 03
              date_invalid                 = 04
              holiday_calendar_not_found   = 05.
          IF xfeit = space.            "Werktag
            EXIT.
          ENDIF.
        ELSE.                          "Samstag oder Sonntag
          xfeit = 'X'.
        ENDIF.
        e_f150d-zield = e_f150d-zield + 1.
      ENDWHILE.
      werktab-werkd = e_f150d-zield.
      APPEND werktab.
    ELSE.                              "Datum bereits geprüft
      e_f150d-zield = werktab-werkd.
    ENDIF.
  ENDIF.
ENDFORM.                               " CALCULATE_HOLIDAYS
*&---------------------------------------------------------------------*
*&      Form  COMPLETE_F150D
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MHNK  text                                               *
*      -->P_T001  text                                                 *
*      <--P_F150D  text                                                *
*----------------------------------------------------------------------*
FORM complete_f150d USING    i_mhnk  LIKE mhnk
                             i_t001  LIKE t001
                    CHANGING e_f150d LIKE f150d.

  e_f150d-mhngh = i_mhnk-mhngh.
  e_f150d-mhngf = i_mhnk-mhngf.

  e_f150d-waerh = i_t001-waers.
  e_f150d-waerf = i_mhnk-waers.
  IF i_mhnk-xzins = space.
    e_f150d-sfpzh = i_mhnk-faehw + i_mhnk-zinhw + e_f150d-mhngh.
    e_f150d-sfpzf = i_mhnk-faebt + i_mhnk-zinbt + e_f150d-mhngf.
    e_f150d-sopzf = i_mhnk-saldo + i_mhnk-zinbt + e_f150d-mhngf -
                    i_mhnk-gsfbt - i_mhnk-gsnbt.
    e_f150d-salzf = i_mhnk-saldo + i_mhnk-zinbt + e_f150d-mhngf.
  ELSE.
    e_f150d-sfpzh = i_mhnk-faehw + e_f150d-mhngh.
    e_f150d-sfpzf = i_mhnk-faebt + e_f150d-mhngf.
    e_f150d-sopzf = i_mhnk-saldo + e_f150d-mhngf -
                    i_mhnk-gsfbt - i_mhnk-gsnbt.
    e_f150d-salzf = i_mhnk-saldo + e_f150d-mhngf.
  ENDIF.
  e_f150d-salfw = i_mhnk-saldo.
ENDFORM.                               " COMPLETE_F150D

*&---------------------------------------------------------------------*
*&      Form  INIT_ACCOUNT_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_account_update TABLES   t_updbel STRUCTURE updbel
                         USING    i_mhnk   LIKE mhnk
                                  i_t047   LIKE t047
                                  i_knb1   LIKE knb1
                                  i_lfb1   LIKE lfb1
                         CHANGING e_updkto LIKE updkto
                                  e_updver LIKE updver.

  REFRESH t_updbel.
  CLEAR   e_updkto.
  CLEAR   e_updver.
  e_updkto-mandt = sy-mandt.
  e_updkto-koart = i_mhnk-koart.
  e_updkto-bukrs = i_mhnk-bukrs.
  e_updkto-madat = i_mhnk-ausdt.
  e_updkto-gmvdt = i_mhnk-gmvdt.
  IF i_mhnk-cpdky = space OR i_mhnk-mgrup <> space.
    e_updkto-mahsk = i_mhnk-mahns.
  ENDIF.
  IF i_mhnk-koart = 'D'.
    IF i_mhnk-sknrze EQ space.
      e_updkto-kunnr = i_mhnk-kunnr.
      e_updkto-filkd = space.
    ELSE.                              "Dezentrale Mahnung
      e_updkto-kunnr = i_mhnk-sknrze.
      e_updkto-filkd = i_mhnk-kunnr.
    ENDIF.
  ELSEIF i_mhnk-sknrze EQ space.
    e_updkto-lifnr = i_mhnk-lifnr.
    e_updkto-filkd = space.
  ELSE.                                "Dezentrale Mahnung
    e_updkto-lifnr = i_mhnk-sknrze.
    e_updkto-filkd = i_mhnk-lifnr.
  ENDIF.
  e_updkto-maber = i_mhnk-smaber.
*----------------------------------------------------------------------*
*       Bei Verrechnung muss auch Update auf Verrechnungskonto         *
*       durchgeführt werden                                            *
*----------------------------------------------------------------------*
  IF i_mhnk-koart = 'D'.
*   if mhnk-lifnr ne space. "Verr. Kred. bei Verarbeitung eines Deb.
*   Verr. Kred. bei Verarbeitung eines Deb.
    IF i_mhnk-lifnr NE space AND i_knb1-xverr NE space. "<<<INSERT 67909
      e_updver-mandt = sy-mandt.
      e_updver-koart = 'K'.
      e_updver-bukrs = i_mhnk-bukrs.
      e_updver-madat = i_mhnk-ausdt.
      e_updver-gmvdt = i_mhnk-gmvdt.
      IF i_mhnk-cpdky = space OR i_mhnk-mgrup <> space.
        e_updkto-mahsk = i_mhnk-mahns.
      ENDIF.
      e_updver-lifnr = i_mhnk-lifnr.
      e_updver-maber = i_mhnk-smaber.
    ENDIF.
  ELSE.
*    if mhnk-kunnr ne space. "Verr. Deb. bei Verarbeitung eines Kred.
*    Verr. Deb. bei Verarbeitung eines Kred.
    IF i_mhnk-kunnr NE space AND i_lfb1-xverr NE space."<<<INSERT 67909
      e_updver-mandt = sy-mandt.
      e_updver-koart = 'D'.
      e_updver-bukrs = i_mhnk-bukrs.
      e_updver-madat = i_mhnk-ausdt.
      e_updver-gmvdt = i_mhnk-gmvdt.
      IF i_mhnk-cpdky = space OR i_mhnk-mgrup <> space.
        e_updkto-mahsk = i_mhnk-mahns.
      ENDIF.
      e_updver-kunnr = i_mhnk-kunnr.
      e_updver-maber = i_mhnk-smaber.
    ENDIF.
  ENDIF.

ENDFORM.                               " INIT_ACCOUNT_UPDATE
*&---------------------------------------------------------------------*
*&      Form  DETERMINE_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MHNK  text                                               *
*      <--P_H_FINAA  text                                              *
*----------------------------------------------------------------------*
FORM determine_output USING    i_mhnk  LIKE mhnk
                      CHANGING e_finaa LIKE finaa.
  DATA: hprofil LIKE soprd.
  CASE e_finaa-nacha.
    WHEN '1'.                          "Drucker
    WHEN '2'.                                               "Fax

*     Old number check
*     call function 'SK_NUMBER_TO_DEST'
*          exporting
*               service                = 'TELEFAX'
*               number                 = e_finaa-tdtelenum
*               country                = e_finaa-tdteleland
*          exceptions
*               country_not_configured = 1
*               service_not_supported  = 2
*               server_not_found       = 3
*               number_emptied         = 4
*               number_empty           = 5
*               number_not_legal       = 6.

*      new number check
      CALL FUNCTION 'TELECOMMUNICATION_NUMBER_CHECK'
        EXPORTING
          country                = e_finaa-tdteleland
          number                 = e_finaa-tdtelenum
          service                = 'TELEFAX'
        EXCEPTIONS
          country_not_configured = 1
          number_emptied         = 2
          number_empty           = 3
          number_not_legal       = 4
          server_not_found       = 5
          service_not_supported  = 6
          OTHERS                 = 7.
      IF sy-subrc NE 0.
        finaa-nacha = '1'.
      ENDIF.
    WHEN 'I'.                          "Internet
      CALL FUNCTION 'SO_PROFILE_READ'
        IMPORTING
          profile               = hprofil
        EXCEPTIONS
          communication_failure = 1
          profile_not_exist     = 2
          system_failure        = 3
          OTHERS                = 4.
      IF sy-subrc NE 0 OR hprofil-smtp_exist NE 'X'.
        finaa-nacha = '1'.
      ENDIF.
    WHEN OTHERS.
      e_finaa-nacha = '1'.
  ENDCASE.
ENDFORM.                               " DETERMINE_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  OPEN_DUNNING_FORM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T047E  text                                                *
*      -->P_ITCPO  text                                                *
*      -->P_FINAA  text                                                *
*----------------------------------------------------------------------*
FORM open_dunning_form USING    i_f150v          LIKE f150v
                                i_t047e          LIKE t047e
                                i_finaa          LIKE finaa
                                i_langu          LIKE sy-langu
                                i_archive_index  LIKE toa_dara
                                i_archive_params LIKE arc_params
                       CHANGING e_itcpo          LIKE itcpo
                                e_itcpp          LIKE itcpp
                                e_langu          LIKE sy-langu.
  CASE i_finaa-nacha.
    WHEN '1'.
      PERFORM open_dunning_form_print USING    i_f150v i_t047e i_langu
                                               i_archive_index
                                               i_archive_params
                                               i_finaa
                                      CHANGING e_itcpo e_langu.
    WHEN '2'.
      PERFORM open_dunning_form_fax   USING    i_f150v i_t047e
                                               i_finaa i_langu
                                               i_archive_index
                                               i_archive_params
                                      CHANGING e_itcpo e_langu.
    WHEN 'I'.
      PERFORM open_dunning_form_net   USING    i_f150v i_t047e i_langu
                                               i_finaa
                                      CHANGING e_itcpo e_itcpp e_langu.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                               " OPEN_DUNNING_FORM

*&---------------------------------------------------------------------*
*&      Form  OPEN_DUNNING_FORM_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_T047E  text                                              *
*      -->P_I_ITCPO  text                                              *
*----------------------------------------------------------------------*
FORM open_dunning_form_print USING    i_f150v          LIKE f150v
                                      i_t047e          LIKE t047e
                                      i_langu          LIKE sy-langu
                                      i_archive_index  LIKE toa_dara
                                      i_archive_params LIKE arc_params
                                      i_finaa          like finaa
                             CHANGING e_itcpo          LIKE itcpo
                                      e_langu          LIKE sy-langu.
  DATA: i_repid LIKE sy-repid,
        i_fornr like t047e-fornr.

* check if alternate form is to be used via finaa
  if i_finaa-fornr <> space.
    i_fornr = i_finaa-fornr.
  else.
    i_fornr = i_t047e-fornr.
  endif.

  i_repid = sy-repid.
* append the current dunning notice to a previous opened print job
  READ TABLE lsttab WITH KEY i_t047e-listn.
  IF sy-subrc = 0.
    e_itcpo-tdnewid = space.
  ELSE.
    e_itcpo-tdnewid = 'X'.
    lsttab-listn = i_t047e-listn.
    APPEND lsttab.
  ENDIF.
  CONCATENATE i_f150v-laufi i_f150v-laufd+2(6) INTO e_itcpo-tdsuffix2.
  e_itcpo-tddataset = i_t047e-listn.
* Open the dunning form
  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      archive_index  = i_archive_index
      archive_params = i_archive_params
      device         = 'PRINTER'
      dialog         = space
            form           = i_fornr
      options        = e_itcpo.

  CALL FUNCTION 'START_FORM'
    EXPORTING
      archive_index = i_archive_index
            form          = i_fornr
      language      = i_langu
      startpage     = 'FIRST'
      program       = i_repid
    IMPORTING
      language      = e_langu.

ENDFORM.                               " OPEN_DUNNING_FORM_PRINT
*&---------------------------------------------------------------------*
*&      Form  OPEN_DUNNING_FORM_FAX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_T047E  text                                              *
*      -->P_I_ITCPO  text                                              *
*----------------------------------------------------------------------*
FORM open_dunning_form_fax   USING    i_f150v          LIKE f150v
                                      i_t047e          LIKE t047e
                                      i_finaa          LIKE finaa
                                      i_langu          LIKE sy-langu
                                      i_archive_index  LIKE toa_dara
                                      i_archive_params LIKE arc_params
                             CHANGING e_itcpo          LIKE itcpo
                                      e_langu          LIKE sy-langu.
  DATA: i_repid LIKE sy-repid,
        i_fornr LIKE t047e-fornr.

  i_repid = sy-repid.
* always start a new print job for fax

* check if alternate form is to be used via finaa
  IF i_finaa-fornr <> space.
    i_fornr = i_finaa-fornr.
  ELSE.
    i_fornr = i_t047e-fornr.
  ENDIF.

  e_itcpo-tdschedule = i_finaa-tdschedule.
  e_itcpo-tdteleland = i_finaa-tdteleland.
  e_itcpo-tdtelenum  = i_finaa-tdtelenum.
  e_itcpo-tdfaxuser  = i_finaa-tdfaxuser.
  e_itcpo-tddataset  = i_t047e-listn.
  e_itcpo-tdsuffix1  = 'FAX'.
  CONCATENATE i_f150v-laufi i_f150v-laufd+2(6) INTO e_itcpo-tdsuffix2.
  e_itcpo-tdnewid    = 'X'.

* Open the dunning form
  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      archive_index  = i_archive_index
      archive_params = i_archive_params
            language       = i_langu
            device         = 'TELEFAX'
      dialog         = space
      form           = i_fornr
      options        = e_itcpo.

* Start and print the receiver-cover sheet if applicable
  PERFORM print_receiver_cover_sheet USING i_archive_index
                                           i_finaa i_langu.

  CALL FUNCTION 'START_FORM'
    EXPORTING
      archive_index = i_archive_index
      form          = i_fornr
      language      = i_langu
      startpage     = 'FIRST'
      program       = i_repid
    IMPORTING
      language      = e_langu.

ENDFORM.                               " OPEN_DUNNING_FORM_FAX
*&---------------------------------------------------------------------*
*&      Form  OPEN_DUNNING_FORM_NET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_T047E  text                                              *
*      -->P_I_ITCPO  text                                              *
*----------------------------------------------------------------------*
FORM open_dunning_form_net   USING    i_f150v LIKE f150v
                                      i_t047e LIKE t047e
                                      i_langu LIKE sy-langu
                                      i_finaa like finaa
                             CHANGING e_itcpo LIKE itcpo
                                      e_itcpp LIKE itcpp
                                      e_langu LIKE sy-langu.
  DATA: i_repid LIKE sy-repid,
        i_fornr like t047e-fornr.

* check if alternate form is to be used via finaa
  if i_finaa-fornr <> space.
    i_fornr = i_finaa-fornr.
  else.
    i_fornr = i_t047e-fornr.
  endif.

  i_repid = sy-repid.
  e_itcpo-tdgetotf  = 'X'.
  if e_itcpo-tdarmod = '3'.
    gb_archive_mail = 'X'.
    e_itcpo-tdarmod = '1'.
  endif.
* Open the dunning form
  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      device  = 'PRINTER'
      dialog  = space
            form    = i_fornr
      options = e_itcpo
    IMPORTING
      RESULT  = e_itcpp
    EXCEPTIONS
      form    = 5.

  CALL FUNCTION 'START_FORM'
    EXPORTING
            form      = i_fornr
      language  = i_langu
      startpage = 'FIRST'
      program   = i_repid
    IMPORTING
      language  = e_langu.

ENDFORM.                               " OPEN_DUNNING_FORM_NET

*&---------------------------------------------------------------------*
*&      Form  CLOSE_DUNNING_FORM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM close_dunning_form USING  i_fsabe LIKE fsabe
                               i_finaa LIKE finaa
                               i_itcpp LIKE itcpp
                               i_itcpo LIKE itcpo
                               i_langu LIKE sy-langu
                               i_lang2 LIKE sy-langu
                               i_update TYPE C
                               i_paymo LIKE paymo
                               i_archive_index LIKE toa_dara
                               i_archive_params LIKE arc_params.

  CASE i_finaa-nacha.
    WHEN '1'.                          "Printer
      PERFORM close_dunning_form_print USING i_itcpo i_paymo i_lang2
                                             i_archive_index   "1377587
                                             i_archive_params. "1377587
    WHEN '2'.                                               "Fax
      PERFORM close_dunning_form_fax.
    WHEN 'I'.                          "Internet
      PERFORM close_dunning_form_net_new USING i_fsabe i_finaa i_itcpp
                                    i_itcpo i_langu i_update"1042992
                                           i_archive_index
                                           i_archive_params.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                               " CLOSE_DUNNING_FORM

*&---------------------------------------------------------------------*
*&      Form  CLOSE_DUNNING_FORM_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM close_dunning_form_print USING i_itcpo LIKE itcpo
                                    i_paymo LIKE paymo
                              i_lang2 like sy-langu
                              i_archive_index LIKE toa_dara     "1377587
                              i_archive_params LIKE arc_params. "1377587
* declaration
  DATA: h_err LIKE sy-subrc.
  DATA t_fimsg LIKE fimsg OCCURS 0 WITH HEADER LINE.
  DATA h_line LIKE sy-tabix.

* end the dunning print form
  CALL FUNCTION 'END_FORM'
    EXCEPTIONS
      unopened = 1
      OTHERS   = 2.
  h_err = sy-subrc.

* print the payment form
  CALL FUNCTION 'PAYMENT_MEDIUM_PRINT'
    EXPORTING
      i_paymo = i_paymo
      i_itcpo = i_itcpo
            I_LANGUAGE = i_lang2
      I_ARCHIVE_INDEX  = I_ARCHIVE_INDEX                        "1377587
      I_ARCHIVE_PARAMS = I_ARCHIVE_PARAMS                       "1377587
    TABLES
      t_fimsg = t_fimsg
    EXCEPTIONS
      OTHERS  = 0.
  DESCRIBE TABLE t_fimsg LINES h_line.
  IF h_line <> 0.
    LOOP AT t_fimsg.
      CALL FUNCTION 'FI_MESSAGE_COLLECT'
        EXPORTING
          i_fimsg       = t_fimsg
          i_xappn       = 'X'
        EXCEPTIONS
          msgid_missing = 1
          msgno_missing = 2
          msgty_missing = 3
          OTHERS        = 4.
    ENDLOOP.
    CLEAR t_fimsg[].
  ENDIF.


  IF h_err = 0.
    CALL FUNCTION 'CLOSE_FORM'
      EXCEPTIONS
        unopened = 1
        OTHERS   = 2.

    READ TABLE lsttab_paym WITH KEY t047e-listn.
    IF sy-subrc = 0.
      i_itcpo-tdnewid = space.
    ELSE.
      i_itcpo-tdnewid = 'X'.
      lsttab_paym-listn = t047e-listn.
      APPEND lsttab_paym.
    ENDIF.

    CALL FUNCTION 'PAYMENT_MEDIUM_PRINT'
      EXPORTING
        i_paymo = i_paymo
        i_itcpo = i_itcpo
              I_LANGUAGE = i_lang2
              i_xopen = 'X'
        I_ARCHIVE_INDEX  = I_ARCHIVE_INDEX                      "1377587
        I_ARCHIVE_PARAMS = I_ARCHIVE_PARAMS                     "1377587
      EXCEPTIONS
        OTHERS  = 0.
    DESCRIBE TABLE t_fimsg LINES h_line.
    IF h_line <> 0.
      LOOP AT t_fimsg.
        CALL FUNCTION 'FI_MESSAGE_COLLECT'
          EXPORTING
            i_fimsg       = t_fimsg
            i_xappn       = 'X'
          EXCEPTIONS
            msgid_missing = 1
            msgno_missing = 2
            msgty_missing = 3
            OTHERS        = 4.
      ENDLOOP.
      CLEAR t_fimsg[].
    ENDIF.
  ENDIF.
ENDFORM.                               " CLOSE_DUNNING_FORM_PRINT

*&---------------------------------------------------------------------*
*&      Form  WRITE_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MHNK  text                                               *
*----------------------------------------------------------------------*
FORM write_header USING i_mhnk   LIKE mhnk
                        i_mahnv  LIKE mahnv
                        i_update LIKE boole-boole.
  DATA: event(15) TYPE c.
* write the original reciever (*adrs) if applicable
  IF i_mhnk-koart = 'D' AND knb5-knrma <> space OR
     i_mhnk-koart = 'K' AND lfb5-lfrma <> space.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = '500'          "Urspr. Mahnempfaenger
        window  = 'INFO1'        "Einheitliche Formulargestaltung
      EXCEPTIONS
        OTHERS  = 01.
    IF sy-subrc = 01.                  "2. Versuch: Adresse des urspr.
      CALL FUNCTION 'WRITE_FORM'       "Mahnempfängers im Fenster
           EXPORTING                   "'MAIN' ausgeben
                element = '500'        "Urspr. Mahnempfaenger
                window  = 'MAIN'
           EXCEPTIONS
                OTHERS  = 01.
    ENDIF.
  ENDIF.
* write the 'test print' line if applicable
* if i_mahnv-xmpri = space and i_update = space and
*     i_mahnv-laufi <> space.
  IF i_mahnv-xmpri = space AND i_update = space.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = '509'
        window  = 'REPEAT'       "Einheitliche Formulargestaltung
      EXCEPTIONS
        OTHERS  = 01.
    IF sy-subrc = 01.                  "2. Versuch: Text 'Probedruck'
      CALL FUNCTION 'WRITE_FORM'       "im Fenster 'MAIN' ausgeben
           EXPORTING
                element = '509'
                window  = 'MAIN'
           EXCEPTIONS
                OTHERS  = 01.
    ENDIF.
  ENDIF.
* write the dunning Stage if applicable
  IF i_mhnk-gmvdt IS INITIAL.
    event      = '51X'.                "Mahnstufe-X
    event+2(1) = i_mhnk-mahns.
  ELSE.
    event      = '520'.
  ENDIF.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window  = 'MAIN'
      element = event
    EXCEPTIONS
      OTHERS  = 01.
* write the rowheader
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window  = 'MAIN'
      element = '530'            "Zeilenueberschrift
    EXCEPTIONS
      OTHERS  = 01.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window  = 'MAIN'
      element = '530'            "Zeilenueberschrift
      type    = 'TOP'
    EXCEPTIONS
      OTHERS  = 01.
ENDFORM.                               " WRITE_HEADER
*&---------------------------------------------------------------------*
*&      Form  READ_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHND  text                                               *
*      <--P_MHND  text                                                 *
*      <--P_BKPF  text                                                 *
*      <--P_BSEG  text                                                 *
*      <--P_BSEC  text                                                 *
*----------------------------------------------------------------------*
FORM read_document changing    i_mhnd  LIKE mhnd
                            e_f150d LIKE f150d
                            e_f150dh LIKE f150d
                            e_mhnd  LIKE mhnd
                            e_bkpf  LIKE bkpf
                            e_bseg  LIKE bseg
                            e_bsec  LIKE bsec.
  CLEAR: e_f150d-dmsol,e_f150d-wrsol,e_f150d-dmhab,e_f150d-wrhab.
  e_mhnd = i_mhnd.
  SELECT SINGLE * FROM bkpf INTO e_bkpf
    WHERE bukrs = i_mhnd-bbukrs
    AND   gjahr = i_mhnd-gjahr
    AND   belnr = i_mhnd-belnr.

  if i_mhnd-bbukrs = space.
    i_mhnd-bbukrs = i_mhnd-bukrs.
  endif.

  SELECT SINGLE * FROM bseg INTO e_bseg
    WHERE bukrs = i_mhnd-bbukrs
    AND   gjahr = i_mhnd-gjahr
    AND   belnr = i_mhnd-belnr
    AND   buzei = i_mhnd-buzei.

  IF e_bseg-xcpdd NE space.
    SELECT SINGLE * FROM bsec INTO e_bsec
      WHERE bukrs = i_mhnd-bbukrs
      AND   gjahr = i_mhnd-gjahr
      AND   belnr = i_mhnd-belnr
      AND   buzei = i_mhnd-buzei.
  ENDIF.
* update f150d with values
*  CASE E_BSEG-SHKZG.
*    WHEN 'S'.
*      E_F150D-DMSOL = E_BSEG-DMBTR.  " comp code currency
*      E_F150D-WRSOL = E_BSEG-WRBTR.  " transaction currency
*    WHEN 'H'.
*      E_F150D-DMHAB = E_BSEG-DMBTR.
*      E_F150D-WRHAB = E_BSEG-WRBTR.
*  ENDCASE.

* NNN
  CASE i_mhnd-shkzg.
    WHEN 'S'.
      e_f150d-dmsol = i_mhnd-dmshb.
      e_f150d-wrsol = i_mhnd-wrshb.
    WHEN 'H'.
      e_f150d-dmhab = i_mhnd-dmshb.
      e_f150d-wrhab = i_mhnd-wrshb.
  ENDCASE.

  e_f150dh = f150d.

  CASE e_bseg-shkzg.
    WHEN 'S'.
      e_f150dh-dmsol = e_bseg-dmbtr.
      e_f150dh-wrsol = e_bseg-wrbtr.
    WHEN 'H'.
      e_f150dh-dmhab = e_bseg-dmbtr.
      e_f150dh-wrhab = e_bseg-wrbtr.
  ENDCASE.


* ignore text if necessary
  IF e_bseg-sgtxt(1) NE '*'.
    e_bseg-sgtxt = space.
  ELSE.
    SHIFT e_bseg-sgtxt LEFT BY 1 PLACES.
  ENDIF.
ENDFORM.                               " READ_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  COMPLETE_MHND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MHNK  text                                               *
*      <--P_MHND  text                                                 *
*----------------------------------------------------------------------*
FORM complete_mhnd USING    i_mhnk LIKE mhnk
                   CHANGING e_mhnd LIKE mhnd.
  IF e_mhnd-xzins = 'X' OR i_mhnk-xzins = 'X'.
    e_mhnd-zsbtr = 0.
    e_mhnd-wzsbt = 0.
  ENDIF.
ENDFORM.                               " COMPLETE_MHND

*&---------------------------------------------------------------------*
*&      Form  CHECK_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MHNK  text                                               *
*      -->P_T_MHND  text                                               *
*      <--P_INCL_ITEM  text                                            *
*----------------------------------------------------------------------*
FORM check_item USING    i_t047b     LIKE t047b
                         i_mhnk      LIKE mhnk
                         i_mhnd      LIKE mhnd
                CHANGING e_incl_item LIKE boole-boole.
  e_incl_item = 'X'.
  IF i_mhnk-gmvdt IS INITIAL.
    IF i_mhnd-xzalb <> space OR i_mhnd-mansp <> space.
      e_incl_item = space.
    ENDIF.
    IF i_t047b-xpost NE 'X'.
      IF i_mhnd-xfael <> 'X'.          "Nur ueberfaellige
        e_incl_item = space.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                               " CHECK_ITEM
*&---------------------------------------------------------------------*
*&      Form  WRITE_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_line.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = '531'.           "Einzelzeile Mahnung
ENDFORM.                               " WRITE_LINE

*&---------------------------------------------------------------------*
*&      Form  COLLECT_SUMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SALTAB  text                                               *
*      -->P_SUMTAB  text                                               *
*      -->P_MHND  text                                                 *
*----------------------------------------------------------------------*
FORM collect_sums TABLES   t_saltab STRUCTURE saltab
                           t_sumtab STRUCTURE sumtab
                  USING    i_mhnd LIKE mhnd
                           i_incl LIKE boole-boole.

  t_saltab-waers = i_mhnd-waers.
  t_saltab-dmshb = i_mhnd-dmshb.
  t_saltab-wrshb = i_mhnd-wrshb.
  COLLECT t_saltab.

  IF i_incl = 'X'.
    CLEAR t_sumtab.
    t_sumtab-waers = i_mhnd-waers.
    t_sumtab-wrshb = i_mhnd-wrshb.
    t_sumtab-dmshb = i_mhnd-dmshb.
    t_sumtab-wzsbt = i_mhnd-wzsbt.
    t_sumtab-zsbtr = i_mhnd-zsbtr.
    IF i_mhnd-xfael = 'X'.
      t_sumtab-ffshb = i_mhnd-wrshb.
      t_sumtab-fhshb = i_mhnd-dmshb.
    ENDIF.
    COLLECT t_sumtab.
  ENDIF.
ENDFORM.                               " COLLECT_SUMS

*---------------------------------------------------------------------*
*       FORM WRITE_FOOTER                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  T_SALTAB                                                      *
*  -->  T_SUMTAB                                                      *
*  -->  I_T001                                                        *
*  -->  E_F150D                                                       *
*---------------------------------------------------------------------*
FORM write_footer TABLES   t_saltab STRUCTURE saltab
                           t_sumtab STRUCTURE sumtab
                  USING    i_t001  LIKE t001
                           i_xzins LIKE mhnk-xzins
                  CHANGING e_f150d LIKE f150d.

  CALL FUNCTION 'WRITE_FORM'        " print no more header
       EXPORTING
            window   = 'MAIN'
            element  = '530'
            type     = 'TOP'
            function = 'DELETE'.

*------- Summe der faelligen Posten ----------------------------------*
  CALL FUNCTION 'CONTROL_FORM'
    EXPORTING
      command = 'PROTECT'.

  LOOP AT t_sumtab.
    e_f150d-waerh = i_t001-waers.
    e_f150d-waerf = t_sumtab-waers.
    e_f150d-supoh = t_sumtab-dmshb.
    e_f150d-supof = t_sumtab-wrshb.
    e_f150d-sufph = t_sumtab-fhshb.
    e_f150d-sufpf = t_sumtab-ffshb.
    IF i_xzins = space.
      e_f150d-sufzh = t_sumtab-fhshb + t_sumtab-zsbtr.
      e_f150d-sufzf = t_sumtab-ffshb + t_sumtab-wzsbt.
      e_f150d-suozh = t_sumtab-dmshb + t_sumtab-zsbtr.
      e_f150d-suozf = t_sumtab-wrshb + t_sumtab-wzsbt.
      e_f150d-suzsh = t_sumtab-zsbtr.
      e_f150d-suzsf = t_sumtab-wzsbt.

    ELSE.
      e_f150d-sufzh = t_sumtab-fhshb.
      e_f150d-sufzf = t_sumtab-ffshb.
      e_f150d-suozh = t_sumtab-dmshb.
      e_f150d-suozf = t_sumtab-wrshb.
      e_f150d-suzsh = 0.
      e_f150d-suzsf = 0.
    ENDIF.

    IF sy-tabix = 1.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = '581'        "Mahnsumme Zeile 1
        EXCEPTIONS
          element = 4.
    ELSE.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = '582'        "Mahnsumme Zeile n
        EXCEPTIONS
          element = 4.
    ENDIF.
  ENDLOOP.


  LOOP AT t_saltab.
    e_f150d-waerh = i_t001-waers.
    e_f150d-waerf = t_saltab-waers.
    e_f150d-salhw = t_saltab-dmshb.
    e_f150d-salfw = t_saltab-wrshb.

    IF sy-tabix = 1.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = '591'        "Kontensaldo Zeile 1
        EXCEPTIONS
          element = 4.
    ELSE.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = '592'        "Kontensaldo Zeile n
        EXCEPTIONS
          element = 4.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'CONTROL_FORM'
    EXPORTING
      command = 'ENDPROTECT'.
ENDFORM.                               " WRITE_FOOTER

*&---------------------------------------------------------------------*
*&      Form  READ_MSCHL
*&---------------------------------------------------------------------*
*       Try to determine the dunning key
*----------------------------------------------------------------------*
FORM read_mschl USING    i_mhnd  LIKE mhnd
                         i_langu LIKE sy-langu
                         i_lang2 LIKE sy-langu
                CHANGING e_t040a LIKE t040a.

  SELECT SINGLE * FROM t040a
    WHERE spras = i_langu
    AND   mschl = i_mhnd-smschl.
  IF sy-subrc NE 0.
    IF 1 = 0. MESSAGE s221. ENDIF.
    PERFORM log_msg USING '221' i_mhnd-smschl i_langu space space.
    IF i_langu <> i_lang2.
      SELECT SINGLE * FROM t040a
        WHERE spras = i_lang2
        AND   mschl = i_mhnd-smschl.
    ENDIF.
    IF sy-subrc <> 0 OR i_langu = i_lang2.
      SELECT SINGLE * FROM t040a
        WHERE spras = sy-langu
        AND   mschl = i_mhnd-smschl.
    ENDIF.
  ENDIF.
ENDFORM.                               " READ_MSCHL
*&---------------------------------------------------------------------*
*&      Form  WRITE_BEGIN_MSCHL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_begin_mschl.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = '540'            "Leerzeile
    EXCEPTIONS
      element = 4.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = '550'            "Anf. Text sep. Ausweis
    EXCEPTIONS
      element = 4.
ENDFORM.                               " WRITE_BEGIN_MSCHL

*&---------------------------------------------------------------------*
*&      Form  WRITE_END_MSCHL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_end_mschl.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = '551'            "Ende Text sep. Ausweis
    EXCEPTIONS
      element = 4.
ENDFORM.                               " WRITE_END_MSCHL
*&---------------------------------------------------------------------*
*&      Form  COMPLETE_OUTPUT_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ADRS  text                                                 *
*      -->P_SADR  text                                                 *
*      -->P_FSABE  text                                                *
*      -->P_T047I  text                                                *
*      <--P_FINAA  text                                                *
*      <--P_I_ITCPO  text                                              *
*      <--P_ITCFX  text                                                *
*----------------------------------------------------------------------*
FORM complete_output_info USING    i_t001   LIKE t001
                                   i_adrs   LIKE adrs
                                   i_sadr   LIKE sadr
                                   i_fsabe  LIKE fsabe
                                   i_t047i  LIKE t047i
                                   i_langu  LIKE sy-langu
                          CHANGING e_finaa  LIKE finaa
                                   e_itcpo  LIKE itcpo
                                   e_itcfx  LIKE itcfx.
  CASE e_finaa-nacha.
    WHEN '1'.
    WHEN '2'.
      e_itcfx-rtitle     = i_adrs-anred.
      e_itcfx-rname1     = i_adrs-name1.
      e_itcfx-rname2     = i_adrs-name2.
      e_itcfx-rname3     = i_adrs-name3.
      e_itcfx-rname4     = i_adrs-name4.
      e_itcfx-rpocode    = i_adrs-pstlz.
      e_itcfx-rcity1     = i_adrs-ort01.
      e_itcfx-rcity2     = i_adrs-ort02.
      e_itcfx-rpocode2   = i_adrs-pstl2.
      e_itcfx-rpobox     = i_adrs-pfach.
      e_itcfx-rpoplace   = i_adrs-pfort.
      e_itcfx-rstreet    = i_adrs-stras.
      e_itcfx-rcountry   = i_adrs-land1.
      e_itcfx-rregio     = i_adrs-regio.
      e_itcfx-rlangu     = i_langu.
      e_itcfx-rhomecntry = i_adrs-inlnd.
      e_itcfx-rlines     = '9'.
      e_itcfx-rctitle    = space.
      e_itcfx-rcfname    = space.
      e_itcfx-rclname    = space.
      e_itcfx-rcname1    = e_finaa-namep.
      e_itcfx-rcname2    = space.
      e_itcfx-rcdeptm    = e_finaa-abtei.
      e_itcfx-rcfaxnr    = e_finaa-tdtelenum.
      e_itcfx-stitle     = i_sadr-anred.
      e_itcfx-sname1     = i_sadr-name1.
      e_itcfx-sname2     = i_sadr-name2.
      e_itcfx-sname3     = i_sadr-name3.
      e_itcfx-sname4     = i_sadr-name4.
      e_itcfx-spocode    = i_sadr-pstlz.
      e_itcfx-scity1     = i_sadr-ort01.
      e_itcfx-scity2     = i_sadr-ort02.
      e_itcfx-spocode2   = i_sadr-pstl2.
      e_itcfx-spobox     = i_sadr-pfach.
      e_itcfx-spoplace   = i_sadr-pfort.
      e_itcfx-sstreet    = i_sadr-stras.
      e_itcfx-scountry   = i_sadr-land1.
      e_itcfx-sregio     = i_sadr-regio.
      e_itcfx-shomecntry = i_adrs-land1.
      e_itcfx-slines     = '9'.
      e_itcfx-sctitle    = i_fsabe-salut.
      e_itcfx-scfname    = i_fsabe-fname.
      e_itcfx-sclname    = i_fsabe-lname.
      e_itcfx-scname1    = i_fsabe-namp1.
      e_itcfx-scname2    = i_fsabe-namp2.
      e_itcfx-scdeptm    = i_fsabe-abtei.
      e_itcfx-sccostc    = i_fsabe-kostl.
      e_itcfx-scroomn    = i_fsabe-roomn.
      e_itcfx-scbuild    = i_fsabe-build.
      CONCATENATE i_fsabe-telf1 '-' i_fsabe-tel_exten1
                  INTO e_itcfx-scphonenr1.
      CONCATENATE i_fsabe-telfx '-' i_fsabe-tel_exten2
                  INTO e_itcfx-scphonenr2.
      CONCATENATE i_fsabe-telfx '-' i_fsabe-fax_extens
                  INTO e_itcfx-scfaxnr.
      e_itcfx-header     = i_t047i-txtko.
      e_itcfx-footer     = i_t047i-txtfu.
      e_itcfx-signature  = i_t047i-txtun.
      e_itcfx-tdid       = i_t047i-txtid.
      e_itcfx-tdlangu    = i_t001-spras.
      e_itcfx-subject    = space.
    WHEN '3'.
  ENDCASE.
ENDFORM.                               " COMPLETE_OUTPUT_INFO
*&---------------------------------------------------------------------*
*&      Form  PRINT_RECEIVER_COVER_SHEET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_FINAA  text                                              *
*      -->P_I_LANGU  text                                              *
*----------------------------------------------------------------------*
FORM print_receiver_cover_sheet USING    i_archive_index  LIKE toa_dara
                                         i_finaa          LIKE finaa
                                         i_langu          LIKE sy-langu.
  IF NOT i_finaa-formc IS INITIAL.
    CALL FUNCTION 'START_FORM'
      EXPORTING
        archive_index = i_archive_index
        form          = i_finaa-formc
        language      = i_langu
        startpage     = 'FIRST'.

    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        window = 'RECEIVER'.

    CALL FUNCTION 'END_FORM'.
  ENDIF.
ENDFORM.                               " PRINT_RECEIVER_COVER_SHEET
*&---------------------------------------------------------------------*
*&      Form  CLOSE_DUNNING_FORM_NET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ITCPP  text                                              *
*----------------------------------------------------------------------*
FORM close_dunning_form_net USING i_fsabe LIKE fsabe
                                  i_finaa LIKE finaa
                                  i_itcpp LIKE itcpp
                                  i_itcpo LIKE itcpo
                                  i_langu LIKE sy-langu
                                  i_update TYPE C
                                  i_archive_index LIKE toa_dara
                                  i_archive_params LIKE arc_params.
  DATA:   hanswer  TYPE c,
          ld_hformat(10) TYPE c,                            "1042992
          doc_size(12) TYPE c,
          hltlines TYPE i,
          htabix LIKE sy-tabix,
          lp_fle1(2) TYPE p,                                "1042992
          lp_fle2(2) TYPE p,                                "1042992
          lp_off1 TYPE p,                                   "1042992
          hfeld(500) TYPE c,
          document_type LIKE soodk-objtp,
          linecnt TYPE p.

  DATA:   lt_hotfdata LIKE itcoo OCCURS 1 WITH HEADER LINE, "1042992
          htline LIKE tline             OCCURS 1 WITH HEADER LINE,
          x_objcont LIKE soli           OCCURS 1 WITH HEADER LINE,
          x_objhead LIKE soli           OCCURS 1 WITH HEADER LINE,
          x_object_hd_change LIKE sood1 OCCURS 1 WITH HEADER LINE,
          x_receivers LIKE soos1        OCCURS 1 WITH HEADER LINE,
          lt_solix    LIKE solix        OCCURS 0 WITH HEADER LINE.

  Data: begin of Ls_tmp,                                        "1640757
           Type    like sxaddrtype-addr_type value 'INT',       "1640757
           Address like soextreci1-Receiver,                    "1640757
        end of Ls_tmp.                                          "1640757


  DATA:   gt_text_mail LIKE soli OCCURS 3 WITH HEADER LINE, "1042992
          gd_text_existing type C,                          "1042992
          ld_packing_list LIKE soxpl OCCURS 1 WITH HEADER LINE,"1042992
          ld_address LIKE finaa-intad,                      "1042992
          ld_addr(60),                                      "1042992
          ld_originator LIKE soos1-recextnam,               "1042992
          h_fimsg LIKE fimsg.                               "1042992


  CALL FUNCTION 'CLOSE_FORM'
    IMPORTING
      RESULT   = i_itcpp
    TABLES
      otfdata  = lt_hotfdata
    EXCEPTIONS
      unopened = 3.

* check if text is in SO10 and fill it in gt_text_mail         "1042992
  perform check_mail_text                                   "1042992
          tables gt_text_mail                               "1042992
          using i_langu gd_text_existing.                   "1042992

  IF NOT i_itcpo-tdpreview IS INITIAL
     AND SY-BATCH IS INITIAL.                               "1346230
    i_itcpp-tdnoprint = 'X'.
    CALL FUNCTION 'DISPLAY_OTF'
      EXPORTING
        control = i_itcpp
      IMPORTING
        RESULT  = i_itcpp
      TABLES
        otf     = lt_hotfdata                               "1042992
      EXCEPTIONS
        OTHERS  = 1.

    CALL FUNCTION 'CORRESPONDENCE_POPUP_EMAIL'
      EXPORTING
        i_intad  = finaa-intad
      IMPORTING
        e_answer = hanswer
        e_intad  = finaa-intad
      EXCEPTIONS
        OTHERS   = 1.
  ENDIF.
* begin of change note 1042992
  IF hanswer = space OR hanswer = 'J'.
    ld_hformat = finaa-textf.
    IF ld_hformat IS INITIAL.
      ld_hformat = 'PDF'.                 "PDF als Default
    ENDIF.
    DATA ld_binfile TYPE xstring.
    CALL FUNCTION 'CONVERT_OTF'
         EXPORTING
        format                = ld_hformat
      IMPORTING
        bin_filesize          = doc_size
        bin_file              = ld_binfile               "?
      TABLES
        otf                   = lt_hotfdata
              lines                 = htline
         EXCEPTIONS
              err_max_linewidth     = 1
              err_format            = 2
              err_conv_not_possible = 3
              OTHERS                = 4.

    DATA: i TYPE i, n TYPE i.
    i = 0.
    n = xstrlen( ld_binfile ).
    WHILE i < n.
      lt_solix-line = ld_binfile+i.                         "(132).
      APPEND lt_solix.
      i = i + 255.
    ENDWHILE.


    DATA wa_soli TYPE soli.
    DATA wa_solix TYPE solix.
    FIELD-SYMBOLS: <ptr_hex> TYPE solix.

    IF ld_hformat = 'PDF'.
      LOOP AT lt_solix INTO wa_solix.
        CLEAR wa_soli.
        ASSIGN wa_soli TO <ptr_hex> CASTING.
        MOVE wa_solix TO <ptr_hex>.
        APPEND wa_soli TO x_objcont.
      ENDLOOP.
      IF 1 = 0.
*-Itab 134 Zeichen nach 255 Zeichen überführen-----
        DESCRIBE TABLE htline    LINES  hltlines.
        DESCRIBE FIELD htline    LENGTH lp_fle1 in character mode.
        DESCRIBE FIELD x_objcont LENGTH lp_fle2 in character mode.
        LOOP AT htline.
          htabix = sy-tabix.
          MOVE htline TO hfeld+lp_off1.
          IF htabix = hltlines.
            lp_fle1 = strlen( htline ).
          ENDIF.
          lp_off1 = lp_off1 + lp_fle1.
          IF lp_off1 GE lp_fle2.
            CLEAR x_objcont.  x_objcont = hfeld(lp_fle2).
            APPEND x_objcont. SHIFT hfeld BY lp_fle2 PLACES.
            lp_off1 = lp_off1 - lp_fle2.
          ENDIF.
          IF htabix = hltlines.
            IF lp_off1 GT 0.
              CLEAR x_objcont.
              x_objcont = hfeld(lp_off1).
              APPEND x_objcont.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ELSE.
      LOOP AT htline.
        x_objcont = htline. APPEND x_objcont.
      ENDLOOP.
    ENDIF.

    x_object_hd_change-objnam    = space.
    IF i_itcpo-tdtitle = space.
      x_object_hd_change-objdes    = text-031.
    ELSE.
      x_object_hd_change-objdes    = i_itcpo-tdtitle.
    ENDIF.
    x_object_hd_change-objla     = i_langu.
    x_object_hd_change-objsns    = 'O'.
    x_object_hd_change-objlen    = doc_size.

    x_object_hd_change-file_ext  = space.
    ld_packing_list-transf_bin = 'X'.
    ld_packing_list-head_start = 1.
    ld_packing_list-head_num = 0.
    ld_packing_list-body_start = 1.
    DESCRIBE TABLE x_objcont LINES    ld_packing_list-body_num.
    ld_packing_list-objtp     = 'EXT'.
    ld_packing_list-objdes    = i_itcpo-tdtitle.
    ld_packing_list-objla     = i_langu.
    ld_packing_list-objlen    = doc_size.
    IF ld_hformat = 'PDF'.
      ld_packing_list-file_ext  = 'PDF'.
    ELSE.
      ld_packing_list-file_ext  = 'TXT'.
    ENDIF.
    APPEND ld_packing_list.

* Aufbereitung Empfängerliste
    ld_address = i_finaa-intad.
    x_receivers-recesc       = 'E'.
    x_receivers-sndart       = 'INT'.
    x_receivers-not_deli     = 'X'.
    x_receivers-RCDAT        = i_itcpo-TDSENDDATE.              "1349674
    x_receivers-RCTIM        = i_itcpo-TDSENDTIME.              "1349674
    WHILE ld_address <> space.
      WHILE ld_address(1) = space.
        SHIFT ld_address BY 1 PLACES.
      ENDWHILE.
      Split Ld_address at ' ' into Ls_tmp-Address Ld_address.   "1640757
      Call function 'SX_INTERNET_ADDRESS_TO_NORMAL'             "1640757
      exporting Address_unstruct = Ls_tmp                       "1640757
      importing Address_normal   = Ls_tmp                       "1640757
      exceptions Error_address       = 2                        "1640757
                 Error_group_address = 3.                       "1640757
      Check sy-subrc = 0.                                       "1640757
                                                                "1640757
      Ld_addr = Ls_tmp-Address.                                 "1640757
      x_receivers-recextnam    = ld_addr.
      APPEND x_receivers.
    ENDWHILE.

    DESCRIBE TABLE x_objcont LINES linecnt.
    IF ld_hformat <> 'PDF'.
      x_objhead = linecnt.
      APPEND x_objhead.
    ENDIF.

   IF I_FINAA-INTUSER IS INITIAL.                              "1002463
      IF fsabe-usrnam IS INITIAL.
        ld_originator = sy-uname.
      ELSE.
        ld_originator = fsabe-usrnam.
      ENDIF.
   ELSE.                                                       "1002463
*     User out of BTE 1040_P                                   "1002463
      ld_originator = I_FINAA-INTUSER.                         "1002463
   ENDIF.                                                      "1002463

    IF ld_hformat = 'PDF'.
      CALL FUNCTION 'SO_OBJECT_SEND'
        EXPORTING
          object_hd_change           = x_object_hd_change
          object_type                = 'RAW'
          originator_type            = 'B'  "Einfügen
          originator                 = ld_originator  "Einfügen
        TABLES
          objcont                    = gt_text_mail
          receivers                  = x_receivers
          packing_list               = ld_packing_list
          att_cont                   = x_objcont
          att_head                   = x_objhead
        EXCEPTIONS
          active_user_not_exist      = 1
          communication_failure      = 2
          component_not_available    = 3
          folder_not_exist           = 4
          folder_no_authorization    = 5
          forwarder_not_exist        = 6
          note_not_exist             = 7
          object_not_exist           = 8
          object_not_sent            = 9
          object_no_authorization    = 10
          object_type_not_exist      = 11
          operation_no_authorization = 12
          owner_not_exist            = 13
          parameter_error            = 14
          substitute_not_active      = 15
          substitute_not_defined     = 16
          system_failure             = 17
          too_much_receivers         = 18
          user_not_exist             = 19
          x_error                    = 20
          OTHERS                     = 21.
      IF sy-subrc = 0.
        IF gb_archive_mail = 'X' AND i_update = 'X'.
          CALL FUNCTION 'CONVERT_OTF_AND_ARCHIVE'
            EXPORTING
              arc_p  = i_archive_params
              arc_i  = i_archive_index
            TABLES
              otf    = lt_hotfdata
            EXCEPTIONS
              OTHERS = 1.
          IF sy-subrc <> 0.
*         log the message with the message handler
            h_fimsg-msgid = 'F0'.
            h_fimsg-msgno = '751'.
            h_fimsg-msgty = 'S'.
            h_fimsg-msgv1 = sy-subrc. CONDENSE h_fimsg-msgv1.
            if gd_lifnr_last <> space.
              h_fimsg-msgv2 = gd_lifnr_last.
            else.
              h_fimsg-msgv2 = gd_kunnr_last.
            endif.
            h_fimsg-msgv3 = gd_bukrs_last.
            CALL FUNCTION 'FI_MESSAGE_COLLECT'
              EXPORTING
                i_fimsg       = h_fimsg
                i_xappn       = 'X'
              EXCEPTIONS
                msgid_missing = 1
                msgno_missing = 2
                msgty_missing = 3
                OTHERS        = 4.
          ENDIF.
        ENDIF.
      ELSE.                      "sy-subrc <> 0 for SO_OBJECT_SEND
        h_fimsg-msgid = 'F0'.
        h_fimsg-msgno = '750'.
        h_fimsg-msgty = 'S'.
        h_fimsg-msgv1 = sy-subrc. CONDENSE h_fimsg-msgv1.
        if gd_lifnr_last <> space.
          h_fimsg-msgv2 = gd_lifnr_last.
        else.
          h_fimsg-msgv2 = gd_kunnr_last.
        endif.
        h_fimsg-msgv3 = gd_bukrs_last.
        CALL FUNCTION 'FI_MESSAGE_COLLECT'
          EXPORTING
            i_fimsg       = h_fimsg
            i_xappn       = 'X'
          EXCEPTIONS
            msgid_missing = 1
            msgno_missing = 2
            msgty_missing = 3
            OTHERS        = 4.
      ENDIF.  "IF sy-subrc = 0.
    ELSE.
* No PDF, but RAW
      CALL FUNCTION 'SO_OBJECT_SEND'
        EXPORTING
          object_hd_change           = x_object_hd_change
          object_type                = 'RAW'
          originator_type            = 'B'
          originator                 = ld_originator
        TABLES
          objcont                    = gt_text_mail
          objhead                    = x_objhead
          receivers                  = x_receivers
          packing_list               = ld_packing_list
          att_cont                   = x_objcont
          att_head                   = x_objhead
         EXCEPTIONS
              active_user_not_exist      = 1
              communication_failure      = 2
              component_not_available    = 3
              folder_not_exist           = 4
              folder_no_authorization    = 5
              forwarder_not_exist        = 6
              note_not_exist             = 7
              object_not_exist           = 8
              object_not_sent            = 9
              object_no_authorization    = 10
              object_type_not_exist      = 11
              operation_no_authorization = 12
              owner_not_exist            = 13
              parameter_error            = 14
              substitute_not_active      = 15
              substitute_not_defined     = 16
              system_failure             = 17
              too_much_receivers         = 18
              user_not_exist             = 19
              x_error                    = 20
              OTHERS                     = 21.
      IF sy-subrc = 0.
        IF gb_archive_mail = 'X' AND i_update = 'X'.
      CALL FUNCTION 'CONVERT_OTF_AND_ARCHIVE'
           EXPORTING
                arc_p  = i_archive_params
                arc_i  = i_archive_index
           TABLES
            otf    = lt_hotfdata
           EXCEPTIONS
                OTHERS = 1.
      IF sy-subrc <> 0.
*       log the message with the message handler
            h_fimsg-msgid = 'F0'.
            h_fimsg-msgno = '751'.
            h_fimsg-msgty = 'S'.
            h_fimsg-msgv1 = sy-subrc. CONDENSE h_fimsg-msgv1.
            if gd_lifnr_last <> space.
              h_fimsg-msgv2 = gd_lifnr_last.
            else.
              h_fimsg-msgv2 = gd_kunnr_last.
            endif.
            h_fimsg-msgv3 = gd_bukrs_last.
        CALL FUNCTION 'FI_MESSAGE_COLLECT'
             EXPORTING
                  i_fimsg       = h_fimsg
                  i_xappn       = 'X'
             EXCEPTIONS
                  msgid_missing = 1
                  msgno_missing = 2
                  msgty_missing = 3
                  OTHERS        = 4.
      ENDIF.
    ENDIF.
      ELSE.                      "sy-subrc <> 0 for SO_OBJECT_SEND
        h_fimsg-msgid = 'F0'.
        h_fimsg-msgno = '750'.
        h_fimsg-msgty = 'S'.
        h_fimsg-msgv1 = sy-subrc. CONDENSE h_fimsg-msgv1.
        if gd_lifnr_last <> space.
          h_fimsg-msgv2 = gd_lifnr_last.
        else.
          h_fimsg-msgv2 = gd_kunnr_last.
        endif.
        h_fimsg-msgv3 = gd_bukrs_last.
        CALL FUNCTION 'FI_MESSAGE_COLLECT'
          EXPORTING
            i_fimsg       = h_fimsg
            i_xappn       = 'X'
          EXCEPTIONS
            msgid_missing = 1
            msgno_missing = 2
            msgty_missing = 3
            OTHERS        = 4.
      ENDIF.   "IF sy-subrc = 0.
    ENDIF.   "IF ld_hformat = 'PDF'.
  ENDIF.   "IF hanswer = space OR hanswer = 'J'.
* end of change note 1042992
ENDFORM.                               " CLOSE_DUNNING_FORM_NET
*&---------------------------------------------------------------------*
*&      Form  ADD_UPDBEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_UPDBEL  text                                               *
*      -->P_MHND  text                                                 *
*----------------------------------------------------------------------*
FORM add_updbel TABLES   t_updbel STRUCTURE updbel
                USING    i_mhnd LIKE mhnd.
  CLEAR t_updbel.
* bbukrs is new field in Rel. 4.5A; for old entries take bukrs:
  IF i_mhnd-bbukrs IS INITIAL.
    t_updbel-bukrs = i_mhnd-bukrs.
  ELSE.
    t_updbel-bukrs = i_mhnd-bbukrs.
  ENDIF.
  t_updbel-belnr = i_mhnd-belnr.
  t_updbel-gjahr = i_mhnd-gjahr.
  t_updbel-buzei = i_mhnd-buzei.
  t_updbel-mahnn = i_mhnd-mahnn.
  APPEND t_updbel.
ENDFORM.     " ADD_UPDBEL

*&---------------------------------------------------------------------*
*&      Form  UPDATE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_UPDBEL  text                                               *
*      -->P_UPDKTO  text                                               *
*      -->P_UPDVER  text                                               *
*----------------------------------------------------------------------*
FORM update_data TABLES   t_updbel STRUCTURE updbel
                 USING    i_update LIKE boole-boole
                          i_mhnk   LIKE mhnk
                          i_updkto LIKE updkto
                          i_updver LIKE updver.
* declaration
  DATA: t_updkto     LIKE updkto      OCCURS 1   WITH HEADER LINE,
        t_updver     LIKE updver      OCCURS 1   WITH HEADER LINE,
        t_iccdtab    LIKE ibkrtab     OCCURS 10  WITH HEADER LINE,
        h_updbel     LIKE updbel.

  IF i_update = 'X'. "<< deleted only for debugging reasons

*   sort t_updbel descending by bukrs and mahnn and determine highest
*   dunning level per cc
    SORT t_updbel BY bukrs mahnn DESCENDING.

*   create the updkto entrys for iccd dunning with the highest dunning
*   level for each cc
    LOOP AT t_updbel.
      h_updbel = t_updbel.
      AT NEW bukrs.
        t_updkto = i_updkto.
        t_updkto-mahsk = h_updbel-mahnn.
        t_updkto-bukrs = h_updbel-bukrs.
        APPEND t_updkto.
      ENDAT.
    ENDLOOP.

*   create the updver entrys for each entry of updkto if clearing for
*   the accounts is active
    IF NOT i_updver-koart IS INITIAL.
*     determine the cc in which the clr account is defined
      IF i_updver-koart = 'D'.
        SELECT bukrs FROM  knb1 INTO TABLE t_iccdtab
                     WHERE kunnr = i_updver-kunnr.
      ELSE.
        SELECT bukrs FROM  lfb1 INTO TABLE t_iccdtab
                     WHERE lifnr = i_updver-lifnr.
      ENDIF.
      LOOP AT t_updkto.
        READ TABLE t_iccdtab WITH KEY bukrs = i_updver-bukrs.
        IF sy-subrc = 0.
          t_updver       = i_updver.
          t_updver-mahsk = t_updkto-mahsk.
          t_updver-bukrs = t_updkto-bukrs.
          APPEND t_updver.
        ENDIF.
      ENDLOOP.
    ENDIF.

* only for debugging reasons
* if i_update = 'X'.

*   update all accounts in iccd dunning
    LOOP AT t_updkto.

*     check if clearing account is to be updated in current cc
      READ TABLE t_updver WITH KEY bukrs = t_updkto-bukrs.
      IF sy-subrc <> 0.
        CLEAR t_updver.
      ENDIF.

*     execute account update
      CALL FUNCTION 'CHANGE_DUNNING_DATA'
        EXPORTING
          i_account          = t_updkto
          i_clearing_account = t_updver
        TABLES
          t_docum            = t_updbel.

*     refresh updbel to avoid a double update
      REFRESH t_updbel.

    ENDLOOP.

*   set print-date stamp
    UPDATE mhnk
           SET    prndt       = sy-datum
           WHERE  laufd       = i_mhnk-laufd
           AND    laufi       = i_mhnk-laufi
           AND    koart       = i_mhnk-koart
           AND    bukrs       = i_mhnk-bukrs
           AND    kunnr       = i_mhnk-kunnr
           AND    lifnr       = i_mhnk-lifnr
           AND    cpdky       = i_mhnk-cpdky
           AND    sknrze      = i_mhnk-sknrze
           AND    smaber      = i_mhnk-smaber
           AND    smahsk      = i_mhnk-smahsk
           AND    busab       = i_mhnk-busab.
  ENDIF.
ENDFORM.                               " UPDATE_DATA
*&---------------------------------------------------------------------*
*&      Form  CALC_DUNNING_CHARGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SALTAB  text                                               *
*      -->P_SUMTAB  text                                               *
*      -->P_T001  text                                                 *
*      <--P_T047C  text                                                *
*      <--P_F150D  text                                                *
*      <--P_ENDIF  text                                                *
*----------------------------------------------------------------------*
FORM calc_dunning_charges  TABLES   t_sumtab STRUCTURE sumtab
                           USING    i_t001   LIKE t001
                                    i_t047c  LIKE t047c
                           CHANGING e_f150d  LIKE f150d.

*------- Mahngebuehr addieren  ---------------------------------------*
* e_f150d-mhngf = t047c-mahng
  CLEAR t_sumtab.
  IF e_f150d-mhngf NE 0.
    e_f150d-waerf = i_t047c-waers.
    e_f150d-waerh = i_t001-waers.

    t_sumtab-waers = e_f150d-waerf.
    t_sumtab-wrshb = e_f150d-mhngf.
    t_sumtab-ffshb = e_f150d-mhngf.
    IF e_f150d-waerf = e_f150d-waerh.
      t_sumtab-dmshb = e_f150d-mhngh.
      t_sumtab-fhshb = e_f150d-mhngf.
    ELSE.
      t_sumtab-dmshb = e_f150d-mhngh.
      t_sumtab-fhshb = e_f150d-mhngh.
    ENDIF.
    COLLECT t_sumtab.
  ENDIF.
ENDFORM.                               " CALC_DUNNING_CHARGES
*&---------------------------------------------------------------------*
*&      Form  WRITE_DUNNING_CHARGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T047C  text                                                *
*----------------------------------------------------------------------*
FORM write_dunning_charges USING i_f150d LIKE f150d.
  IF i_f150d-mhngf NE 0.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = '540'          "Leerzeile
      EXCEPTIONS
        element = 4.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = '570'          "Mahngebuehr
      EXCEPTIONS
        element = 4.
  ENDIF.
ENDFORM.                               " WRITE_DUNNING_CHARGES

*&---------------------------------------------------------------------*
*&      Form  CHECK_CURRENCY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SALTAB  text                                               *
*      -->P_SUMTAB  text                                               *
*      -->P_T001  text                                                 *
*      <--P_F150D  text                                                *
*----------------------------------------------------------------------*
FORM check_currency TABLES   t_saltab STRUCTURE saltab
                             t_sumtab STRUCTURE sumtab
                    USING    i_t001   LIKE t001
                    CHANGING e_f150d  LIKE f150d.
*------- Nur eine Waehrung vorhanden : HW-Felder loeschen ------------*
  e_f150d-waerh = i_t001-waers.
  READ TABLE t_sumtab INDEX 1.
  IF sy-tfill = 1 AND t_sumtab-waers = i_t001-waers.
    READ TABLE t_saltab INDEX 1.
    IF sy-tfill = 1 AND t_saltab-waers = i_t001-waers.
      t_sumtab-dmshb = 0.
      t_sumtab-fhshb = 0.
      t_sumtab-zsbtr = 0.
      MODIFY t_sumtab INDEX 1.
      t_saltab-dmshb = 0.
      MODIFY t_saltab INDEX 1.
      e_f150d-waerh = space.
    ENDIF.
  ENDIF.
ENDFORM.                               " CHECK_CURRENCY
*&---------------------------------------------------------------------*
*&      Form  GET_ESR_INFORMATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHND  text                                               *
*      -->P_I_MHNK  text                                               *
*      -->P_F150D  text                                                *
*      <--P_F150D_ESR  text                                            *
*----------------------------------------------------------------------*
FORM get_esr_information TABLES   t_mhnd STRUCTURE mhnd
                         USING    i_mhnk LIKE mhnk
                                  i_f150d LIKE f150d
                         CHANGING e_bnka  LIKE bnka
                                  e_sadr  LIKE sadr
                                  e_f150d_esr LIKE f150d_esr.
  CALL FUNCTION 'GET_DUNNING_DATA_ESR'
    EXPORTING
      i_f150d           = i_f150d
      i_mhnk            = i_mhnk
    IMPORTING
      e_bnka            = e_bnka
      e_sadr            = e_sadr
    TABLES
      t_mhnd            = t_mhnd
    CHANGING
      c_f150d_esr       = e_f150d_esr
    EXCEPTIONS
      no_esr_applicable = 1
      no_bukrs          = 2
      no_adrs           = 3
      no_bank           = 4
      amount_to_large   = 5
      OTHERS            = 6.
ENDFORM.                               " GET_ESR_INFORMATION
*&---------------------------------------------------------------------*
*&      Form  INIT_ESR_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_F150D_ESR  text                                            *
*----------------------------------------------------------------------*
FORM init_esr_line CHANGING e_f150d_esr LIKE f150d_esr.
  e_f150d_esr-mbetr = '*********  **'.
ENDFORM.                               " INIT_ESR_LINE

*&---------------------------------------------------------------------*
*&      Form  READ_TABLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHND  text                                               *
*      -->P_LANGU  text                                                *
*      <--P_T003T  text                                                *
*      <--P_TBSLT  text                                                *
*----------------------------------------------------------------------*
FORM read_tables USING    i_mhnd  LIKE mhnd
                          i_langu LIKE sy-langu
                 CHANGING e_t003t LIKE t003t
                          e_tbslt LIKE tbslt.

*-------- erster Durchgang -------------------------------------------*
  READ TABLE h_t003t INDEX 1.
  IF sy-subrc NE 0.
    SELECT * FROM t003t INTO TABLE h_t003t.
  ENDIF.

  CLEAR h_t003t.
  CLEAR e_t003t.
  LOOP AT h_t003t WHERE spras = i_langu
                  AND   blart = i_mhnd-blart.
    e_t003t = h_t003t.
    EXIT.
  ENDLOOP.


*-------- erster durchgang -------------------------------------------*
  READ TABLE h_tbslt INDEX 1.
  IF sy-subrc NE 0.
    SELECT * FROM tbslt INTO TABLE h_tbslt.
  ENDIF.

  CLEAR h_tbslt.
  CLEAR e_tbslt.
  LOOP AT h_tbslt WHERE spras = i_langu
                  AND   bschl = i_mhnd-bschl
                  AND   umskz = i_mhnd-umskz.
    e_tbslt = h_tbslt.
    EXIT.
  ENDLOOP.

ENDFORM.                               " READ_TABLES
*&---------------------------------------------------------------------*
*&      Form  CHECK_DUNNING_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHND  text                                               *
*      -->P_I_MHNK  text                                               *
*----------------------------------------------------------------------*
FORM check_dunning_data TABLES   t_mhnd STRUCTURE mhnd
                        USING    i_mhnk LIKE mhnk
                        CHANGING e_incl.

* assume that the mhnk entry is to be dunned
  e_incl = 'X'.

  IF ( NOT i_mhnk-gmvdt IS INITIAL ) AND i_mhnk-mansp = space.
    EXIT.
  ENDIF.

* check for account dunn block reason
  IF i_mhnk-mansp <> space OR i_mhnk-xmflg = space
     OR i_mhnk-faebt <= 0.
    e_incl = space.
  ENDIF.

* check if at least one item has no dunn block reason
  LOOP AT t_mhnd WHERE mansp = space.
    EXIT.
  ENDLOOP.
  IF sy-subrc <> 0.
    e_incl = space.
  ENDIF.

ENDFORM.                               " CHECK_DUNNING_DATA
*&---------------------------------------------------------------------*
*&      Form  OFI_DETERMINE_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_KNA1  text                                                 *
*      -->P_KNB1  text                                                 *
*      -->P_LFA1  text                                                 *
*      -->P_LFB1  text                                                 *
*      -->P_I_MHNK  text                                               *
*      -->P_T047E  text                                                *
*      <--P_FINAA  text                                                *
*----------------------------------------------------------------------*
FORM ofi_determine_output USING    i_kna1   LIKE kna1
                                   i_knb1   LIKE knb1
                                   i_lfa1   LIKE lfa1
                                   i_lfb1   LIKE lfb1
                                   i_mhnk   LIKE mhnk
                                   i_f150d2 LIKE f150d2
                                   i_t047e  LIKE t047e
                                   i_ofi    LIKE boole-boole
                                   i_update LIKE boole-boole
                          CHANGING e_finaa  LIKE finaa
                                   e_itcpo  LIKE itcpo
                                   e_archive_index   LIKE toa_dara
                                   e_archive_params  LIKE arc_params.
* declaration
  DATA: t_fimsg LIKE fimsg OCCURS 10 WITH HEADER LINE.

  CHECK i_ofi = 'X'.

  CALL FUNCTION 'OPEN_FI_PERFORM_00001040_P'
    EXPORTING
      i_kna1           = i_kna1
      i_knb1           = i_knb1
      i_lfa1           = i_lfa1
      i_lfb1           = i_lfb1
      i_mhnk           = i_mhnk
      i_f150d2         = i_f150d2
      i_t047e          = i_t047e
      i_update         = i_update
    TABLES
      t_fimsg          = t_fimsg
    CHANGING
      c_finaa          = e_finaa
      c_itcpo          = e_itcpo
      c_archive_index  = e_archive_index
      c_archive_params = e_archive_params
    EXCEPTIONS
      OTHERS           = 0.

  PERFORM log_msg_tab TABLES t_fimsg.
ENDFORM.                               " OFI_DETERMINE_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  FILL_PAYMENT_STRUCT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SALTAB  text                                               *
*      -->P_SUMTAB  text                                               *
*      -->P_FINAA  text                                                *
*      <--P_H_PAYMI  text                                              *
*      <--P_H_PAYMO  text                                              *
*----------------------------------------------------------------------*
FORM fill_payment_struct TABLES   t_mhnd   STRUCTURE mhnd
                                  t_sumtab STRUCTURE sumtab
                         USING    i_finaa LIKE finaa
                                  i_f150v LIKE f150v
                                  i_f150d LIKE f150d
                                  i_t047e LIKE t047e
                                  i_mhnk  LIKE mhnk
                                  i_adrs  LIKE adrs
                         CHANGING e_paymi LIKE paymi
                                  e_paymo LIKE paymo.
* declaration
  DATA: lin      LIKE sy-tfill,
        mhnd_lin LIKE sy-tfill.

* init the output structure
  CLEAR e_paymo.

* fill structure only when printing the dunning form
  CHECK i_finaa-nacha = '1' AND i_t047e-zlsch <> space.

* fill the structure with the default values
  e_paymi-bukrs = i_mhnk-bukrs.
  e_paymi-applk = i_mhnk-applk.
  e_paymi-zlsch = i_t047e-zlsch.
  e_paymi-nacha = i_finaa-nacha.
  e_paymi-zbukr = i_mhnk-bukrs.
  e_paymi-zadrt = '01'.
  MOVE-CORRESPONDING i_adrs TO e_paymi.
  IF mhnk-koart = 'D'.
    e_paymi-kunnr = i_mhnk-kunnr.
  ELSE.
    e_paymi-lifnr = i_mhnk-lifnr.
  ENDIF.
  e_paymi-avsid = i_mhnk-avsid.
  e_paymi-datum = i_f150v-ausdt.
  e_paymi-vorid = '0002'.

* fill payment belnr
  DESCRIBE TABLE t_mhnd LINES mhnd_lin.
  IF mhnd_lin = 1.
    READ TABLE t_mhnd INDEX 1.
    e_paymi-belnr = t_mhnd-belnr.
  ENDIF.

* fill the amount fields only if one currency is in use
  DESCRIBE TABLE t_sumtab LINES lin.
  IF lin = 1.
    e_paymi-waers = i_f150d-waerf.
    e_paymi-rbbtr = i_f150d-sufph + i_f150d-suzsh.
    e_paymi-rwbbt = i_f150d-sufpf + i_f150d-suzsf.
    IF e_paymi-rbbtr > 0.
      e_paymi-shkzg = 'S'.
    ELSE.
      e_paymi-shkzg = 'H'.
    ENDIF.

*   fill the necessary work areas
    CALL FUNCTION 'PAYMENT_MEDIUM_DATA'
      EXPORTING
        i_paymi  = e_paymi
        i_applk  = mhnk-applk                                   "1285642
      IMPORTING
        e_paymo  = e_paymo
      EXCEPTIONS
        no_print = 1
        OTHERS   = 2.
    IF sy-subrc <> 0.
      CLEAR e_paymo.
    ENDIF.
  ENDIF.

ENDFORM.                               " FILL_PAYMENT_STRUCT
*&---------------------------------------------------------------------*
*&      Form  INIT_PAYMENT_STRUCT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FINAA  text                                                *
*      -->P_T047  text                                                 *
*      <--P_H_PAYMO  text                                              *
*      <--P_H_PAYMI  text                                              *
*----------------------------------------------------------------------*
FORM init_payment_struct USING    i_finaa LIKE finaa
                                  i_t047e LIKE t047e
                         CHANGING e_paymo LIKE paymo
                                  e_paymi LIKE paymi.

* fill structure only when printing the dunning form
  CHECK i_finaa-nacha = '1' AND i_t047e-zlsch <> space.

  CLEAR e_paymi.
  CALL FUNCTION 'PAYMENT_MEDIUM_INIT'
    IMPORTING
      e_paymo = e_paymo
    EXCEPTIONS
      OTHERS  = 0.
ENDFORM.                               " INIT_PAYMENT_STRUCT

*&---------------------------------------------------------------------*
*&      Form  CLOSE_DUNNING_FORM_FAX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM close_dunning_form_fax.
* end the dunning print form
  CALL FUNCTION 'END_FORM'
    EXCEPTIONS
      unopened = 1
      OTHERS   = 2.
  IF sy-subrc = 0.
    CALL FUNCTION 'CLOSE_FORM'
      EXCEPTIONS
        unopened = 1
        OTHERS   = 2.
    COMMIT WORK.
  ENDIF.

ENDFORM.                               " CLOSE_DUNNING_FORM_FAX
*&---------------------------------------------------------------------*
*&      Form  CREATE_REMADV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHND  text                                               *
*      -->P_I_UPDATE  text                                             *
*      -->P_I_MHNK  text                                               *
*----------------------------------------------------------------------*
FORM create_remadv TABLES   t_mhnd STRUCTURE mhnd
                   USING    i_update LIKE boole-boole
                            i_mhnk  LIKE mhnk
                            i_t047b LIKE t047b
                            i_t047e LIKE t047e
                   CHANGING e_avsid LIKE mhnk-avsid.
* declaration
  DATA: t_avico     LIKE avico OCCURS 10 WITH HEADER LINE,
        h_incl_item LIKE boole-boole,
        h_konto     LIKE mhnk-kunnr.


* disable remadv functionality
  CHECK i_t047e-xavis = 'X' AND i_update = 'X'.

* create t_avico struct
  LOOP AT t_mhnd.

*   check wether the item should be include in the dunning notice or not
    PERFORM check_item           USING    i_t047b i_mhnk t_mhnd
                                 CHANGING h_incl_item.

    IF h_incl_item = 'X'.
      CLEAR t_avico.
      MOVE-CORRESPONDING t_mhnd TO t_avico.
      IF t_mhnd-sknrze <> space.
        t_avico-kunnr = t_mhnd-sknrze.
      ENDIF.
      t_avico-koart = t_mhnd-bkoart.
      APPEND t_avico.
    ENDIF.
  ENDLOOP.

* get the account nr
  IF i_mhnk-koart = 'D'.
    h_konto = i_mhnk-kunnr.
  ELSE.
    h_konto = i_mhnk-lifnr.
  ENDIF.

* create the rem adv
  CALL FUNCTION 'REMADV_CORRESPONDENCE_INSERT'
    EXPORTING
      i_vorid = '0002'
      i_bukrs = i_mhnk-bukrs
      i_koart = i_mhnk-koart
      i_konto = h_konto
    IMPORTING
      e_avsid = e_avsid
    TABLES
      t_avico = t_avico
    EXCEPTIONS
      error   = 1
      OTHERS  = 2.
* if adice could not be created
  IF sy-subrc <> 0.
*   create log with last known error and ignore further processing
    PERFORM log_symsg.
    EXIT.
  ENDIF.


* save the rem adv (no commit)
  CALL FUNCTION 'REMADV_SAVE_DB_ALL'
    EXPORTING
      i_dialog_update = 'X'
      i_commit        = ' '
    EXCEPTIONS
      OTHERS          = 0.

* update mhnk if possible.
  UPDATE mhnk
         SET    avsid       = e_avsid
         WHERE  laufd       = i_mhnk-laufd
         AND    laufi       = i_mhnk-laufi
         AND    koart       = i_mhnk-koart
         AND    bukrs       = i_mhnk-bukrs
         AND    kunnr       = i_mhnk-kunnr
         AND    lifnr       = i_mhnk-lifnr
         AND    cpdky       = i_mhnk-cpdky
         AND    sknrze      = i_mhnk-sknrze
         AND    smaber      = i_mhnk-smaber
         AND    smahsk      = i_mhnk-smahsk
         AND    busab       = i_mhnk-busab.

  mhnk-avsid = e_avsid.

  IF 1 = 0. MESSAGE s460. ENDIF.
  PERFORM log_msg USING '460' i_mhnk-koart h_konto e_avsid space.


ENDFORM.                               " CREATE_REMADV
*&---------------------------------------------------------------------*
*&      FORM check_mail_text
*&---------------------------------------------------------------------*
*       .........
*----------------------------------------------------------------------*
*   --> LD_TEXT_EXISTING                                             *
*----------------------------------------------------------------------*
* form was created with note 1042992
FORM check_mail_text TABLES gt_text_mail
USING id_langu
CHANGING cd_text_existing.
  DATA : ld_text LIKE soli OCCURS 3 WITH HEADER LINE,
        ld_packing_list LIKE soxpl OCCURS 1 WITH HEADER LINE,
        ld_header LIKE thead,                           "...Textkopf
        ld_lines  LIKE tline OCCURS 0 WITH HEADER LINE, "...Textline
        ld_name TYPE tdobname,
        ld_no_lines TYPE I,
        selections LIKE  stxh OCCURS 0 WITH HEADER LINE.

  IF finaa-namep <> space.
    ld_name = finaa-namep.
  ELSE.
    ld_name = finaa-mail_body_text.
  ENDIF.
  IF ld_name = space.
    EXIT.
  ENDIF.
  cd_text_existing = space.

* read text for mail-body out of SO10                          "1042992
* with selected language
  CALL FUNCTION 'READ_TEXT'
  EXPORTING
    object    = 'TEXT'
    ID        = 'FIKO'
    name      = ld_name
    LANGUAGE  = id_langu
  IMPORTING
    HEADER    = ld_header
  TABLES
    LINES     = ld_lines
  EXCEPTIONS
    not_found = 1
    OTHERS    = 2.
  IF sy-subrc = 0.
    cd_text_existing = 'X'.
  ELSE.
*     with logon language
    CALL FUNCTION 'READ_TEXT'
    EXPORTING
      object    = 'TEXT'
      ID        = 'FIKO'
      name      = ld_name
      LANGUAGE  = sy-langu
    IMPORTING
      HEADER    = ld_header
    TABLES
      LINES     = ld_lines
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.
    IF sy-subrc = 0.
      cd_text_existing = 'X'.
    ELSE.
      SELECT * FROM stxh INTO TABLE selections
      WHERE tdobject   = 'TEXT'
      AND tdname     = ld_name
      AND tdid       = 'FIKO'.
      DESCRIBE TABLE selections LINES ld_no_lines .
*     if unique text ld_name, then with available language
      IF ld_no_lines  = '1'.
        CALL FUNCTION 'READ_TEXT'
        EXPORTING
          object    = 'TEXT'
          ID        = 'FIKO'
          name      = ld_name
          LANGUAGE  = selections-tdspras
        IMPORTING
          HEADER    = ld_header
        TABLES
          LINES     = ld_lines
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
        IF sy-subrc = 0.
          cd_text_existing = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  gt_text_mail[] = ld_lines[].

ENDFORM.

FORM close_dunning_form_net_new USING i_fsabe LIKE fsabe
      i_finaa LIKE finaa
      i_itcpp LIKE itcpp
      i_itcpo LIKE itcpo
      i_langu LIKE sy-langu
      i_update TYPE C
      i_archive_index LIKE toa_dara
      i_archive_params LIKE arc_params.
  DATA:   hanswer  TYPE C,
        ld_hformat(10) TYPE C,
        doc_size(12) TYPE C,
        hltlines TYPE I,
        htabix LIKE sy-tabix,
        lp_fle1(2) TYPE p,
        lp_fle2(2) TYPE p,
        lp_off1 TYPE p,
        hfeld(500) TYPE C,
        document_type LIKE soodk-objtp,
        linecnt TYPE p.

  DATA:   lt_hotfdata LIKE itcoo OCCURS 1 WITH HEADER LINE,
        htline LIKE tline             OCCURS 1 WITH HEADER LINE,
        x_objcont LIKE soli           OCCURS 1 WITH HEADER LINE,
        x_objhead LIKE soli           OCCURS 1 WITH HEADER LINE,
        x_object_hd_change LIKE sood1 OCCURS 1 WITH HEADER LINE,
        x_receivers LIKE soos1        OCCURS 1 WITH HEADER LINE,
        lt_solix    LIKE solix        OCCURS 0 WITH HEADER LINE.


  DATA:   gt_text_mail LIKE soli OCCURS 3 WITH HEADER LINE,
        gd_text_existing TYPE C,
        ld_packing_list LIKE soxpl OCCURS 1 WITH HEADER LINE,
        ld_address LIKE finaa-intad,
        ld_addr(60),
        ld_originator LIKE soos1-recextnam,
        h_fimsg LIKE fimsg.


  CALL FUNCTION 'CLOSE_FORM'
  IMPORTING
    RESULT   = i_itcpp
  TABLES
    otfdata  = lt_hotfdata
  EXCEPTIONS
    unopened = 3.

* check if text is in SO10 and fill it in gt_text_mail
  PERFORM check_mail_text
  TABLES gt_text_mail
  USING i_langu gd_text_existing.

  IF NOT i_itcpo-tdpreview IS INITIAL
  AND SY-BATCH IS INITIAL.
    i_itcpp-tdnoprint = 'X'.
    CALL FUNCTION 'DISPLAY_OTF'
    EXPORTING
      CONTROL = i_itcpp
    IMPORTING
      RESULT  = i_itcpp
    TABLES
      otf     = lt_hotfdata
    EXCEPTIONS
      OTHERS  = 1.

    CALL FUNCTION 'CORRESPONDENCE_POPUP_EMAIL'
    EXPORTING
      i_intad  = i_finaa-intad
    IMPORTING
      e_answer = hanswer
      e_intad  = i_finaa-intad
    EXCEPTIONS
      OTHERS   = 1.
  ENDIF.

  IF hanswer = space OR hanswer = 'J'.
    ld_hformat = i_finaa-textf.
    IF ld_hformat IS INITIAL.
      ld_hformat = 'PDF'.                 "PDF als Default
    ENDIF.
    DATA : lt_solix_dummy TYPE solix_tab,
          ld_error.
    REFRESH lt_solix_dummy[].
    IF itcpo-tdtitle = space.                                   "1565941
       itcpo-tdtitle = text-031.                                "1565941
    ENDIF.                                                      "1565941
    PERFORM send_mail_with_attachm TABLES lt_hotfdata lt_solix_dummy
                                          gt_text_mail
                                   USING ' ' i_finaa fsabe-usrnam itcpo
                                   CHANGING ld_error.

    IF ld_error = space.
      IF gb_archive_mail = 'X' AND i_update = 'X'.
        CALL FUNCTION 'CONVERT_OTF_AND_ARCHIVE'
        EXPORTING
          arc_p  = i_archive_params
          arc_i  = i_archive_index
        TABLES
          otf    = lt_hotfdata
        EXCEPTIONS
          OTHERS = 1.
        IF sy-subrc <> 0.
*       log the message with the message handler
          h_fimsg-msgid = 'F0'.
          h_fimsg-msgno = '751'.
          h_fimsg-msgty = 'S'.
          h_fimsg-msgv1 = sy-subrc. CONDENSE h_fimsg-msgv1.
          IF gd_lifnr_last <> space.
            h_fimsg-msgv2 = gd_lifnr_last.
          ELSE.
            h_fimsg-msgv2 = gd_kunnr_last.
          ENDIF.
          h_fimsg-msgv3 = gd_bukrs_last.
          CALL FUNCTION 'FI_MESSAGE_COLLECT'
          EXPORTING
            i_fimsg       = h_fimsg
            i_xappn       = 'X'
          EXCEPTIONS
            msgid_missing = 1
            msgno_missing = 2
            msgty_missing = 3
            OTHERS        = 4.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.

FORM send_mail_with_attachm   TABLES  it_otfdata STRUCTURE itcoo
  it_advice  STRUCTURE solix
  it_lines   TYPE soli_tab
USING   id_call_from_pdf
      i_finaa LIKE finaa
      i_fsabe_usrnam LIKE fsabe-usrnam
      i_itcpo_l     LIKE itcpo
                              changing cd_error   like boole-boole.

  DATA: so10_lines TYPE I,
        lt_hotfdata LIKE itcoo OCCURS 1 WITH HEADER LINE,
        htline LIKE tline OCCURS 1 WITH HEADER LINE,
        n_objcont TYPE soli_tab,
        ld_address LIKE finaa-intad,
        ld_addr TYPE adr6-smtp_addr,
        send_request TYPE REF TO cl_bcs,
        document TYPE REF TO cl_document_bcs,
        attachment TYPE REF TO cl_document_bcs,
        sender TYPE REF TO cl_sapuser_bcs,
        internet_recipient TYPE REF TO if_recipient_bcs,
        internet_sender TYPE REF TO if_sender_bcs,
        bcs_exception TYPE REF TO cx_bcs,
        sent_to_all TYPE os_boolean,
        lt_solix    TYPE solix_tab,
        begin of Ls_tmp,                                        "1640757
           Type    like sxaddrtype-addr_type value 'INT',       "1640757
           Address like soextreci1-Receiver,                    "1640757
        end of Ls_tmp.                                          "1640757


  DESCRIBE TABLE it_lines  LINES so10_lines.
  DATA lt_text_mail       TYPE soli_tab.

  CLEAR lt_text_mail[].
  IF so10_lines > 0.
*  convert gt_lines
    PERFORM convert_itf USING it_lines[] CHANGING lt_text_mail[].
*  the result is now in lt_text_mail[]
  ENDIF.

  TRY.
    send_request = cl_bcs=>create_persistent( ).
    IF i_finaa-mail_status_attr = space.
      send_request->set_status_attributes(
      i_requested_status =  'N'
      i_status_mail      =  'N' ).
    ELSE.
      send_request->set_status_attributes(
      i_requested_status =  i_finaa-mail_status_attr
      i_status_mail      =  i_finaa-mail_status_attr ).
    ENDIF.
*     create sender
    IF i_finaa-mail_send_addr <> space.
      ld_addr = i_finaa-mail_send_addr.
      internet_sender = cl_cam_address_bcs=>create_internet_address(
      i_address_string = ld_addr  ).
      CALL METHOD send_request->set_sender
      EXPORTING
        i_sender = internet_sender.
    ELSE.
      DATA: ld_originator TYPE uname.
      IF i_finaa-intuser <> space.
        ld_originator = i_finaa-intuser.
    ELSEIF i_fsabe_usrnam IS INITIAL.
          ld_originator = sy-uname.
        else.
        ld_originator = i_fsabe_usrnam.
      ENDIF.
      sender = cl_sapuser_bcs=>create( ld_originator ).
      CALL METHOD send_request->set_sender
      EXPORTING
        i_sender = sender.
    ENDIF.
*     create recipients
    ld_address = i_finaa-intad.
    WHILE ld_address <> space.
      WHILE ld_address(1) = space.
        SHIFT ld_address BY 1 PLACES.
      ENDWHILE.
      Split Ld_address at ' ' into Ls_tmp-Address Ld_address.   "1640757
      Call function 'SX_INTERNET_ADDRESS_TO_NORMAL'             "1640757
      exporting Address_unstruct = Ls_tmp                       "1640757
      importing Address_normal   = Ls_tmp                       "1640757
      exceptions Error_address       = 2                        "1640757
                 Error_group_address = 3.                       "1640757
      Check sy-subrc = 0.                                       "1640757
                                                                "1640757
      Ld_addr = Ls_tmp-Address.                                 "1640757
      internet_recipient =
      cl_cam_address_bcs=>create_internet_address(
      i_address_string = ld_addr ).
      CALL METHOD send_request->add_recipient
      EXPORTING
        i_recipient = internet_recipient.
    ENDWHILE.

    document = cl_document_bcs=>create_document(
    i_type    = 'TXT'
    i_text    = lt_text_mail
    i_subject = i_itcpo_l-tdtitle ).

      if id_call_from_pdf is initial.
      PERFORM convert_advice TABLES it_otfdata n_objcont lt_solix USING
      i_finaa-textf.
    ELSE.
      lt_solix[] = it_advice[].
    ENDIF.

    IF i_finaa-textf = 'PDF' OR i_finaa-textf = space.
      attachment = cl_document_bcs=>create_document(
      i_type    = 'PDF'
      i_hex     = lt_solix
      i_subject = i_itcpo_l-tdtitle ).
    ELSE.
      attachment = cl_document_bcs=>create_document(
      i_type    = 'RAW'
      i_text    = n_objcont
      i_subject = i_itcpo_l-tdtitle ).
    ENDIF.

    IF i_finaa-mail_sensitivity <> space.
*      'P' is confidential, * 'F' is functional
      document->set_sensitivity( i_finaa-mail_sensitivity ).
    ENDIF.
    IF i_finaa-mail_importance <> space.
      document->set_importance( i_finaa-mail_importance ).
    ENDIF.

    CALL METHOD document->add_document_as_attachment
    EXPORTING
      im_document = attachment.
    send_request->set_document( document ).

    IF i_finaa-mail_send_prio <> space.
      send_request->set_priority( i_finaa-mail_send_prio ).
    ENDIF.

    IF i_itcpo_l-tdsenddate IS NOT INITIAL.
      DATA : l_timestamp TYPE bcs_sndat, tzone TYPE timezone.
      tzone = sy-zonlo.
      CONVERT DATE i_itcpo_l-tdsenddate TIME i_itcpo_l-tdsendtime
        INTO TIME STAMP l_timestamp TIME ZONE tzone.
      send_request->send_request->set_send_at( l_timestamp ).
    ENDIF.

    IF i_finaa-mail_outbox_link <> space.
      send_request->send_request->set_link_to_outbox(
      EXPORTING i_link_to_outbox = 'X' ).
    ENDIF.

    sent_to_all = send_request->send(
    i_with_error_screen = space ).
    IF sent_to_all = space.
      DATA h_fimsg LIKE fimsg.
      h_fimsg-msgid = 'F0'.
      h_fimsg-msgno = '750'.
      h_fimsg-msgty = 'S'.
      h_fimsg-msgv1 = sy-subrc. CONDENSE h_fimsg-msgv1.
      IF gd_lifnr_last <> space.
        h_fimsg-msgv2 = gd_lifnr_last.
      ELSE.
        h_fimsg-msgv2 = gd_kunnr_last.
      ENDIF.
      h_fimsg-msgv3 = gd_bukrs_last.
      CALL FUNCTION 'FI_MESSAGE_COLLECT'
      EXPORTING
        i_fimsg       = h_fimsg
        i_xappn       = 'X'
      EXCEPTIONS
        msgid_missing = 1
        msgno_missing = 2
        msgty_missing = 3
        OTHERS        = 4.
    ENDIF.

  CATCH cx_bcs INTO bcs_exception.
    h_fimsg-msgid = 'F0'.
    h_fimsg-msgno = '750'.
    h_fimsg-msgty = 'S'.
    h_fimsg-msgv1 = sy-subrc. CONDENSE h_fimsg-msgv1.
    IF gd_lifnr_last <> space.
      h_fimsg-msgv2 = gd_lifnr_last.
    ELSE.
      h_fimsg-msgv2 = gd_kunnr_last.
    ENDIF.
    h_fimsg-msgv3 = gd_bukrs_last.
    CALL FUNCTION 'FI_MESSAGE_COLLECT'
    EXPORTING
      i_fimsg       = h_fimsg
      i_xappn       = 'X'
    EXCEPTIONS
      msgid_missing = 1
      msgno_missing = 2
      msgty_missing = 3
      OTHERS        = 4.
    cd_error = 'X'.
  ENDTRY.

ENDFORM.                    "send_mail_with_attachm

*&---------------------------------------------------------------------*
*&      Form  convert_itf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM convert_itf USING it_lines TYPE soli_tab
CHANGING ct_text_mail TYPE soli_tab.

  DATA : x_objcont TYPE soli_tab WITH HEADER LINE,
        x_objcont_line LIKE soli,
        hltlines TYPE I, so10_lines TYPE I,
        htabix LIKE sy-tabix,
        lp_fle1(2) TYPE p, lp_fle2(2) TYPE p, lp_off1 TYPE p,
        linecnt TYPE p,
        hfeld(500) TYPE C,
        ltxt_tdtab_c256(256) OCCURS 5 WITH HEADER LINE,
        ltxt_tdtab_x256 TYPE tdtab_x256,
        ls_tdtab_x256   TYPE LINE OF tdtab_x256.
  FIELD-symbols <cptr>  TYPE C.

* convert gt_lines to destination format
  CALL FUNCTION 'CONVERT_ITF_TO_ASCII'
  EXPORTING
    tabletype         = 'BIN'
  IMPORTING
    x_datatab         = ltxt_tdtab_x256
  TABLES
    itf_lines         = it_lines
  EXCEPTIONS
    invalid_tabletype = 1
    OTHERS            = 2.
  LOOP AT ltxt_tdtab_x256 INTO ls_tdtab_x256.
    ASSIGN ls_tdtab_x256 TO <cptr> casting.
    ltxt_tdtab_c256 = <cptr>.
    APPEND ltxt_tdtab_c256.
  ENDLOOP.

  IF cl_abap_char_utilities=>charsize > 1.
    DATA tab_c256(256) OCCURS 5 WITH HEADER LINE.
    DATA : I TYPE I, ld_appended(1) TYPE C.
    LOOP AT ltxt_tdtab_c256.
      I = sy-tabix MOD 2.
      ld_appended = space.
      IF I = 1.                         " uneven
        tab_c256 = ltxt_tdtab_c256.
      ELSE.
        tab_c256+128 = ltxt_tdtab_c256.  " even
        APPEND tab_c256.
        ld_appended = 'X'.
      ENDIF.
    ENDLOOP.
    IF  ld_appended = space.
      APPEND tab_c256.                   " append last line.
    ENDIF.
    ltxt_tdtab_c256[] = tab_c256[].
  ENDIF.

* convert to 255 for call to cl_bcs
   DESCRIBE FIELD  x_objcont_line length lp_fle2 IN character MODE.
   DATA ls_string TYPE string.
   LOOP AT ltxt_tdtab_c256.
     CONCATENATE ls_string ltxt_tdtab_c256 INTO ls_string.
   ENDLOOP.

* remove hex 00, note 1503173
  REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>minchar IN
    ls_string WITH space.

   WHILE ls_string <> ''.
     x_objcont = ls_string.
     APPEND x_objcont.
     SHIFT ls_string BY lp_fle2 PLACES in character mode.
   ENDWHILE.
   ct_text_mail[] = x_objcont[].

ENDFORM.                    "convert_itf

*&---------------------------------------------------------------------*
*&      Form  convert_advice
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IT_OTFDATA text
*      -->N_OBJCONT  text
*----------------------------------------------------------------------*
FORM convert_advice TABLES  it_otfdata STRUCTURE itcoo
  n_objcont  TYPE soli_tab
  e_solix    TYPE solix_tab
USING i_format LIKE finaa-textf.


  DATA: ld_hformat(10) TYPE C, doc_size(12) TYPE C,
        hltlines TYPE I, so10_lines TYPE I,
        htabix LIKE sy-tabix,
        lp_fle1(2) TYPE p, lp_fle2(2) TYPE p, lp_off1 TYPE p,
        linecnt TYPE p,
        hfeld(500) TYPE C,
        lt_hotfdata LIKE itcoo OCCURS 1 WITH HEADER LINE,
        htline LIKE tline OCCURS 1 WITH HEADER LINE,
        x_objcont TYPE soli_tab WITH HEADER LINE,
        x_objcont_line LIKE soli,
        ld_binfile TYPE xstring,
        lt_solix   TYPE solix_tab ,
        wa_soli TYPE soli,
        wa_solix TYPE solix,
        I TYPE I, n TYPE I.

  FIELD-symbols: <ptr_hex> TYPE solix.

* convert data
  LOOP AT it_otfdata INTO lt_hotfdata.
    APPEND lt_hotfdata.
  ENDLOOP.
  ld_hformat = i_format.
  IF ld_hformat IS INITIAL OR ld_hformat = 'PDF'.
    ld_hformat = 'PDF'.               "PDF as default
  ELSE.
    ld_hformat = 'ASCII'.
  ENDIF.
  CALL FUNCTION 'CONVERT_OTF'
  EXPORTING
    FORMAT                = ld_hformat
  IMPORTING
    bin_filesize          = doc_size
    bin_file              = ld_binfile
  TABLES
    otf                   = lt_hotfdata
    LINES                 = htline
  EXCEPTIONS
    err_max_linewidth     = 1
    err_format            = 2
    err_conv_not_possible = 3
    OTHERS                = 4.

  n = XSTRLEN( ld_binfile ).
  WHILE I < n.
    wa_solix-LINE = ld_binfile+I.
    APPEND wa_solix TO lt_solix.
    I = I + 255.
  ENDWHILE.

  e_solix[] = lt_solix[].

  IF ld_hformat <> 'PDF'.
    LOOP AT htline.
      x_objcont = htline-tdline.
      APPEND x_objcont TO n_objcont.
    ENDLOOP.
  ENDIF.

ENDFORM.
