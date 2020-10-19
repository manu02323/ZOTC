FUNCTION ZOTC0016_GENERATE_DUNNING_DATA.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_LAUFD) LIKE  F150V-LAUFD
*"     VALUE(I_LAUFI) LIKE  F150V-LAUFI
*"     VALUE(I_BUKRS) LIKE  T001-BUKRS
*"     VALUE(I_GRDAT) LIKE  F150V-GRDAT
*"     VALUE(I_AUSDT) LIKE  F150V-AUSDT
*"     VALUE(I_TRACE) LIKE  BOOLE-BOOLE
*"     VALUE(I_MOUT) LIKE  BOOLE-BOOLE
*"     VALUE(I_OFI) LIKE  BOOLE-BOOLE DEFAULT 'X'
*"     VALUE(I_CHECK_IN) LIKE  BOOLE-BOOLE DEFAULT SPACE
*"  TABLES
*"      T_MHNK STRUCTURE  MHNK
*"      T_MHND STRUCTURE  MHND
*"      T_MHNK_IN STRUCTURE  MHNK OPTIONAL
*"      T_MHND_IN STRUCTURE  MHND OPTIONAL
*"      T_FLDTAB STRUCTURE  IFLDTAB OPTIONAL
*"      T_ICCDBUKRS STRUCTURE  IBKRTAB OPTIONAL
*"      T_FIMSG STRUCTURE  FIMSG OPTIONAL
*"  CHANGING
*"     VALUE(C_KUNNR) LIKE  KNA1-KUNNR
*"     VALUE(C_LIFNR) LIKE  LFA1-LIFNR
*"  EXCEPTIONS
*"      CUSTOMER_WO_PROCEDURE
*"      CUSTOMER_NOT_FOUND
*"      CUSTOMIZING_ERROR
*"      PARAMETER_ERROR
*"--------------------------------------------------------------------
  DATA:  e_bsec      LIKE bsec,
         e_t001      LIKE t001,
         e_t047      LIKE t047,
         e_t047a     LIKE t047a,
         e_knb5      LIKE knb5,
         e_lfb5      LIKE lfb5,
         e_vfm_knxx  LIKE vfm_knxx,
         e_vfm_lfxx  LIKE vfm_lfxx,
         h_vfm_knxx  LIKE vfm_knxx,
         h_vfm_lfxx  LIKE vfm_lfxx,
         e_mahna     LIKE t047a-mahna,
         h_del_du    LIKE boole-boole, "delete item from dunning sel
         h_dunn_it   LIKE boole-boole,
         h_own_mhnk  LIKE boole-boole, "own mhnk entry in iccd
         h_legal_du  LIKE boole-boole, "account is in legal dunning p.
         h_dd_acc    LIKE boole-boole, "account has pm for dir debit
         h_db_item   LIKE boole-boole, "dunn block item
         h_mahna     LIKE vfm_knxx-mahna,"dunning procedure
         h_idx       LIKE sy-tabix,
         h_has_items LIKE boole-boole,
         h_koart     LIKE mhnk_ext-koart,
         h_checks    LIKE checks,
         h_cpdky_cpd LIKE mhnd_ext-cpdky,
         h_cpdky_grp LIKE mhnd_ext-cpdky,
         h_cpdky     LIKE mhnd_ext-cpdky,                       "1406401
         h_mhnd_rebzg LIKE mhnd_ext,                            "1406401
         h_mhnd_ext  LIKE mhnd_ext OCCURS 10 WITH HEADER LINE,  "1406401
         h_char80(80) TYPE c,
         h_iccd      LIKE boole-boole,
         h_item_koart LIKE mhnk_ext-koart,                      "1258562
         t_knb5      LIKE knb5     OCCURS 10 WITH HEADER LINE,
         t_lfb5      LIKE lfb5     OCCURS 10 WITH HEADER LINE,
         t_t047b     LIKE t047b    OCCURS 10 WITH HEADER LINE,
         t_t047c     LIKE t047c    OCCURS 10 WITH HEADER LINE,
         t_t047h     LIKE t047h    OCCURS 10 WITH HEADER LINE,
         t_t047r     LIKE t047r    OCCURS 10 WITH HEADER LINE,
         t_cpdtab    LIKE cpdtab   OCCURS 10 WITH HEADER LINE,
         t_mhnk_ext  LIKE mhnk_ext OCCURS 10 WITH HEADER LINE,
         t_mhnd_ext  LIKE mhnd_ext OCCURS 10 WITH HEADER LINE,
         t_bukrs     LIKE bukrs_sel OCCURS 10 WITH HEADER LINE.
  TABLES takof.

  IF i_bukrs <> gd_last_bukrs.
    gd_last_bukrs = i_bukrs.
    REFRESH r_hkont. CLEAR r_hkont.
    r_hkont-sign   = 'E'.
    r_hkont-option = 'EQ'.
    SELECT * FROM takof WHERE bukrs = i_bukrs
                    AND   xndunning = 'X'.
      r_hkont-low  = takof-akont.
      r_hkont-high = takof-akont.
      APPEND r_hkont.
    ENDSELECT.
  ENDIF.

* init the protocoll
  CALL FUNCTION 'FI_MESSAGE_INIT'.
  REFRESH deleted_per_branch[].
* convert the ranges table
  PERFORM convert_bukrs_ranges TABLES   t_iccdbukrs t_bukrs
                               USING    i_bukrs
                               CHANGING h_iccd.
* set the enable flag for the open fi interface
  use_ofi = i_ofi.

  delay_with_blocked_items = 0. " Maximum account delay only
  " blocked items.

* check parameters in case of dunning check
  IF i_check_in = 'X' AND c_kunnr <> space AND c_lifnr <> space.
    READ TABLE t_mhnd_in INDEX 1.
    IF sy-subrc = 0.
      IF t_mhnd_in-koart = 'D'.
        c_lifnr = space.
      ELSE.
        c_kunnr = space.
      ENDIF.
    ENDIF.
  ENDIF.

************************************************************************
* Phase 0                                                              *
* Read the custoner Masterdata and bsid/bsik entries                   *
************************************************************************

* assign the fields from the fld tab
  PERFORM assign_fields TABLES   t_fldtab
                        CHANGING h_checks.

  IF c_kunnr <> space.
* get necessary customer master data from view and dunning master data
    PERFORM get_master_data_customer TABLES   t_knb5 t_lfb5 t_fldtab
                                              t_bukrs
                                     USING    i_bukrs c_kunnr h_checks
                                     CHANGING e_vfm_knxx e_vfm_lfxx
                                              e_knb5 e_lfb5 c_lifnr
                                              h_koart h_mahna h_dunn_it.
  ELSEIF c_lifnr <> space.
* get necessary vendor master data from view and dunning master data
    PERFORM get_master_data_vendor   TABLES   t_knb5 t_lfb5 t_fldtab
                                              t_bukrs
                                     USING    i_bukrs c_lifnr h_checks
                                     CHANGING e_vfm_knxx e_vfm_lfxx
                                              e_knb5 e_lfb5 c_kunnr
                                              h_koart h_mahna h_dunn_it.
  ELSE.
    MESSAGE e844 RAISING parameter_error.
  ENDIF.

* read opens items if account is to be dunned
  IF h_dunn_it = 'X'.

*   read the default dunning customizing
    PERFORM get_dunning_customizing TABLES   t_t047b t_t047c
                                             t_t047h t_t047r
                                    USING    i_bukrs h_mahna
                                    CHANGING e_t001 e_t047 e_t047a.

*   check if account has direct debit
    PERFORM check_dd_account        USING     e_t001
                                              e_vfm_knxx e_vfm_lfxx
                                    CHANGING  h_dd_acc.

    IF convert_currency = space.
      CALL FUNCTION 'CURRENCY_CHECK_FOR_PROCESS'
        EXPORTING
          process                = 'SAPF150'
        EXCEPTIONS
          process_not_maintained = 1.
      IF sy-subrc = 0.
        convert_currency = 'T'.
      ELSE.
        convert_currency = 'F'.
      ENDIF.
    ENDIF.

* check if home currency is still valid:
    IF convert_currency = 'T'.
      DATA new_cc_currency LIKE mhnd-waers.
      CALL FUNCTION 'CURRENCY_GET_SUBSEQUENT'
        EXPORTING
          currency     = e_t001-waers
          process      = 'SAPF150'
          date         = f150v-ausdt
          bukrs        = e_t001-bukrs
        IMPORTING
          currency_new = new_cc_currency.


* expiring currencies: Check which fields have reference to MHND-WAERS
* and store in internal table gt_fieldlist:
      DATA h_line LIKE sy-tabix.
      DATA xdfies LIKE dfies OCCURS 0 WITH HEADER LINE.

      DESCRIBE TABLE gt_fieldlist LINES h_line.
      IF h_line = 0.
        CALL FUNCTION 'DDIF_FIELDINFO_GET'
          EXPORTING
            tabname        = 'MHND_EXT'
          TABLES
            dfies_tab      = xdfies
          EXCEPTIONS
            not_found      = 1
            internal_error = 2
            OTHERS         = 3.
        LOOP AT xdfies.
          IF  xdfies-datatype = 'CURR'
          AND xdfies-reftable = 'MHND_EXT'
          AND xdfies-reffield = 'WAERS'.
            gt_fieldlist-name = xdfies-fieldname.
            APPEND gt_fieldlist.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

*   get the open items for the customer and move them into t_mhnd

    IF h_koart = 'D' AND i_check_in = space.
      PERFORM get_open_items_customer TABLES   t_mhnd_ext
                                               t_fldtab t_knb5 t_lfb5
                                               t_t047r t_bukrs
                                      USING    i_grdat e_vfm_knxx
                                               h_checks
                                               e_t001
                                      CHANGING h_has_items.

    ELSEIF h_koart = 'K' AND i_check_in = space.
      PERFORM get_open_items_vendor   TABLES   t_mhnd_ext
                                               t_fldtab t_knb5 t_lfb5
                                               t_t047r t_bukrs
                                      USING    i_grdat e_vfm_lfxx
                                               h_checks
                                               e_t001
                                      CHANGING h_has_items.
    ELSEIF i_check_in = 'X'.
*     use previous determined mhnd and check consistence
      PERFORM create_mhnd_ext         TABLES   t_mhnd_in t_mhnk_in
                                               t_mhnd_ext
                                      CHANGING h_has_items.
    ENDIF.

    IF i_check_in = space.
* Collections Management
      DATA: lt_fimsg_cm LIKE fimsg OCCURS 10 WITH HEADER LINE.
      TRY.
          CALL FUNCTION 'OPEN_FI_PERFORM_00001765_E'
            TABLES
              ct_mhnd_ext = t_mhnd_ext
              ct_fimsg    = lt_fimsg_cm
            EXCEPTIONS
              OTHERS      = 4.
        CATCH cx_sy_dyn_call_illegal_func.
      ENDTRY.
      PERFORM log_msg_tab TABLES lt_fimsg_cm.
    ENDIF.

  ENDIF.

************************************************************************
* Phase I                                                              *
* Check and complete the mhnd entrys and create the mhnk entrys        *
************************************************************************
  IF h_has_items = 'X'.
    PERFORM log_msg USING '818' space space space space.
  ENDIF.

* save the original view entrys for branch dunning
  h_vfm_knxx = e_vfm_knxx.
  h_vfm_lfxx = e_vfm_lfxx.


  IF i_check_in = space AND ( e_vfm_knxx-xdezv = 'X'
                             OR e_vfm_lfxx-xdezv = 'X' ).
    SORT t_mhnd_ext BY filkd.
  ENDIF.
* check and complete the mhnd entries
  LOOP AT t_mhnd_ext.

    e_vfm_knxx  = h_vfm_knxx.
    e_vfm_lfxx  = h_vfm_lfxx.

    h_idx       = sy-tabix.
    h_del_du    = space.
    h_own_mhnk  = space.

    h_cpdky_cpd = space.
    h_cpdky_grp = space.

    IF t_mhnd_ext-KUNNR IS INITIAL AND
       NOT t_mhnd_ext-lifnr IS INITIAL.                         "1230552
           h_item_koart = 'K'.                                  "1230552
    ELSE.                                                       "1230552
           h_item_koart = 'D'.                                  "1230552
    ENDIF.                                                      "1230552

*   fill the mhnd entries with additional values
    PERFORM init_mhnd USING    i_laufd i_laufi i_bukrs
                               c_kunnr c_lifnr h_koart h_iccd
                               i_check_in
                      CHANGING t_mhnd_ext.

*   generate sknrze for branch-dunning
    IF   i_check_in = space AND ( e_vfm_knxx-xdezv = 'X'
                                 OR e_vfm_lfxx-xdezv = 'X' ).
      PERFORM create_dezv TABLES   t_knb5 t_lfb5
                          CHANGING t_mhnd_ext e_vfm_knxx e_vfm_lfxx.
    ENDIF.

*   generate group identifers
    IF   i_check_in = space AND
       ( e_vfm_knxx-mgrup <> space OR
         e_vfm_lfxx-mgrup <> space ).
      PERFORM create_mgrup USING t_mhnd_ext CHANGING h_cpdky_grp.
      IF sy-subrc <> 0.
*       overflow while building cpdky from dunning group
      ENDIF.
    ENDIF.

*   generate smaber if dunning per dunning area is active
    IF e_t047-xmabe = 'X' AND i_check_in = space.
*      generate the mhnd key field
      t_mhnd_ext-smaber = t_mhnd_ext-maber.
    ENDIF.

*   determine dunning procedure
    PERFORM determine_mahna TABLES   t_knb5 t_lfb5
                            USING    t_mhnd_ext h_mahna
                            CHANGING e_mahna e_knb5 e_lfb5.

*   reread the customizing for a new dunning procedure
    IF e_mahna <> e_t047a-mahna.
      PERFORM get_dunning_customizing TABLES   t_t047b t_t047c
                                               t_t047h t_t047r
                                      USING    i_bukrs e_mahna
                                      CHANGING e_t001 e_t047 e_t047a.
    ENDIF.

*   call open fi interface for cpdky
    IF i_check_in = space.

*     we save the old value of h_cpdky_grp:                     "1352330
      data ld_cpdky_grp like h_cpdky_grp.                       "1352330
      ld_cpdky_grp = h_cpdky_grp.                               "1352330
      PERFORM ofi_dun_det_cpdky USING t_mhnd_ext CHANGING h_cpdky_grp.

      IF ( e_vfm_knxx-xcpdk = 'X' AND h_koart = 'D' ) OR
         ( e_vfm_lfxx-xcpdk = 'X' AND h_koart = 'K' ).
** check last dunning date in item, not in account
        DATA h_date LIKE f150v-ausdt.
        h_date = t_mhnd_ext-madat + e_t047a-rhyth.
        IF i_ausdt < h_date.
          DATA h_chardate(10). WRITE t_mhnd_ext-madat TO h_chardate.
          PERFORM log_msg USING '700' t_mhnd_ext-blinf
                                 h_chardate space space.
          DELETE t_mhnd_ext INDEX h_idx.
          CONTINUE.
        ENDIF.
      ENDIF.

*     set data for cpd accounts
      IF ( e_vfm_knxx-xcpdk = 'X' AND h_koart = 'D' ) OR
         ( e_vfm_lfxx-xcpdk = 'X' AND h_koart = 'K' ).
*       read bsec entry for t_mhnd_ext
        PERFORM read_bsec           USING    t_mhnd_ext
                                    CHANGING e_bsec.
        IF sy-subrc = 0.
*         generate cpdkey from bsec
          PERFORM create_cpdky        USING    e_bsec
                                      CHANGING h_cpdky_cpd.

*         generate cpd-address from bsec
          PERFORM create_cpd_address  USING    e_bsec
                                      CHANGING t_mhnd_ext.
        ENDIF.
      ELSE.
*       create address from master data
        PERFORM create_address USING    e_vfm_knxx e_vfm_lfxx
                               CHANGING t_mhnd_ext.
      ENDIF.

*     generate unique CPDKY from temp keys. allowing to combine cpd
*     accounts and user defined mhnk groups
      if ld_cpdky_grp <> h_cpdky_grp.                           "1352330
*     h_cpdky_grp was created in the exit, so we use it         "1352330
        t_mhnd_ext-cpdky = h_cpdky_grp.                         "1352330
      else.                                                     "1352330
        IF t_mhnd_ext-rebzg IS INITIAL.                         "1406401
          PERFORM create_unique_cpdky  TABLES   t_cpdtab
                                       USING    h_cpdky_cpd
                                                h_cpdky_grp
                                       CHANGING t_mhnd_ext-cpdky.
        ELSE. "rebzg filled - take cpdky from invoice           "1406401
          READ table t_mhnd_ext into h_mhnd_rebzg
                                with key kunnr = t_mhnd_ext-kunnr
                                         lifnr = t_mhnd_ext-lifnr
                                         belnr = t_mhnd_ext-rebzg
                                         GJAHR = t_mhnd_ext-rebzj
                                         BUZEI = t_mhnd_ext-rebzz.
          IF Sy-SUBRC = 0.                                      "1406401
             IF NOT h_mhnd_rebzg-cpdky IS INITIAL.              "1406401
               t_mhnd_ext-cpdky = h_mhnd_rebzg-cpdky.           "1406401
             ELSE.                                              "1406401
               h_mhnd_ext = t_mhnd_ext.                         "1406401
               append h_mhnd_ext. "process h_mhnd_ext later in new loop
             ENDIF.                                             "1406401
          ELSE.                                                 "1406401
            PERFORM create_unique_cpdky  TABLES   t_cpdtab      "1406401
                                         USING    h_cpdky_cpd   "1406401
                                                  h_cpdky_grp   "1406401
                                         CHANGING t_mhnd_ext-cpdky.
          ENDIF.                                                "1406401
        ENDIF.                                                  "1406401
      endif.                                                    "1352330
    ENDIF.


*   special checks for icc dunning
    IF h_iccd = 'X' AND i_check_in = space.
*     check the dunning period for the item cc
      PERFORM check_dunning_iccd_mhnd TABLES   t_knb5 t_lfb5
                                      USING    e_knb5  e_lfb5
                                               i_ausdt t_mhnd_ext
                                               e_t047a
                                      CHANGING t_mhnd_ext-gmvdt
                                               t_mhnd_ext-kmansp
                                               h_del_du
                                               h_own_mhnk.
      IF h_del_du = 'X'.
*       delete all items for that cc/smaber
        DELETE t_mhnd_ext WHERE smaber = t_mhnd_ext-smaber
                          AND   bbukrs = t_mhnd_ext-bbukrs.
        CONTINUE.
      ENDIF.

*     check the legal dunning proc for the item cc if the item is in a
*     legal dunning procedure the set bukrs to bbukrs this will resut
*     in a separate mhnk entry for that group of items
      IF h_own_mhnk = 'X'.
        t_mhnd_ext-bukrs = t_mhnd_ext-bbukrs.
      ENDIF.
    ENDIF.

    IF i_check_in = space.
*   check Umskz and mark item as deleted if necessary
      PERFORM check_sgl_indicator  USING    e_t047a t_mhnd_ext
                                            h_item_koart        "1230552
                                 CHANGING h_del_du.
      IF h_del_du = 'X'.
*     delete and disregard all further processing for the item
        DELETE t_mhnd_ext INDEX h_idx.
        CONTINUE.
      ENDIF.
    ENDIF.
*   check if item is a not invoice related credit memo
    PERFORM check_credit_memo   TABLES t_mhnd_ext
                               USING    t_mhnd_ext
                               CHANGING t_mhnd_ext-cmemo.


    IF i_check_in = space.
*   generate xfael-flag from mahna and maber
      PERFORM determine_due_date USING    i_ausdt e_t047a t_mhnd_ext
                                 CHANGING t_mhnd_ext-faedt
                                          t_mhnd_ext-verzn
                                          t_mhnd_ext-xfael.

*   check direct debit for the item
      PERFORM check_dd_item      USING    e_t001 h_vfm_knxx h_vfm_lfxx
                                          t_mhnd_ext h_dd_acc
                                 CHANGING t_mhnd_ext-xzalb.

*   call open FI and allow to include/exclude the item
      PERFORM ofi_dun_check_item USING    t_mhnd_ext e_mahna
                                 CHANGING t_mhnd_ext-xfael
                                          t_mhnd_ext-xzalb
                                          t_mhnd_ext-mansp
                                          t_mhnd_ext-faedt  "N
                                          t_mhnd_ext-verzn. "N
    ENDIF.

    IF t_mhnd_ext-xzalb = 'X'.
      IF 0 = 1. MESSAGE s804. ENDIF.
      PERFORM log_msg USING '804' t_mhnd_ext-blinf space space space.
    ENDIF.


*   check dumm block reason for item
    PERFORM check_db_item      USING    t_mhnd_ext
                               CHANGING t_mhnd_ext-mansp
                                        h_db_item.

    IF i_check_in = space.
*     check, if the item has to be dunned
      PERFORM check_dunning_item USING    t_mhnd_ext
                                 CHANGING h_dunn_it.

*     item must be dunned, calculate new duning level and key
      IF h_dunn_it = 'X'.
        IF gd_exit_active = 'X'.
          CALL FUNCTION 'OPEN_FI_PERFORM_00001762_E'
            CHANGING
              cs_mhnd_ext = t_mhnd_ext
            EXCEPTIONS
              OTHERS      = 4.
          IF sy-subrc <> 0.
            PERFORM determine_du_level TABLES   t_t047b
                                       USING    t_mhnd_ext
                                       CHANGING t_mhnd_ext-mahnn.
*           log the new dunning level for the item                  "1273832
            IF 0 = 1. MESSAGE s831. ENDIF.                          "1273832
            IF t_mhnd_ext-mahnn <> '9'.                             "1273832
            PERFORM log_msg USING '831'
                    t_mhnd_ext-blinf t_mhnd_ext-mahnn space space.  "1273832
            ENDIF.                                                  "1273832
          ENDIF.
        ELSE.
*       generate dunning level (mahnn)
          PERFORM determine_du_level TABLES   t_t047b
                                     USING    t_mhnd_ext
                                     CHANGING t_mhnd_ext-mahnn.
*         log the new dunning level for the item                  "1273832
          IF 0 = 1. MESSAGE s831. ENDIF.                          "1273832
          IF t_mhnd_ext-mahnn <> '9'.                             "1273832
          PERFORM log_msg USING '831'
                  t_mhnd_ext-blinf t_mhnd_ext-mahnn space space.  "1273832
          ENDIF.                                                  "1273832
        ENDIF.
      ELSE.
*       if item is not to be dunned keep the old mahns as mahnn
        t_mhnd_ext-mahnn = t_mhnd_ext-mahns.
      ENDIF.
*     generate dunning key and reassign dunning level if necessary
      IF t_mhnd_ext-mschl <> space.
        PERFORM determine_du_key   USING    t_mhnd_ext
                                   CHANGING t_mhnd_ext-mahnn
                                            t_mhnd_ext-smschl.
      ENDIF.
    ELSE.
*     check if dunning level is correct
      IF t_mhnd_ext-shkzg = 'S'.
        PERFORM check_du_level TABLES   t_t047b t_mhnk_in
                               CHANGING t_mhnd_ext.
      ENDIF.
    ENDIF.

*   generate smask for dunning each dunning level separate
    IF e_t047-xstmv = 'X'.
      IF t_mhnd_ext-cmemo = space OR i_check_in = 'X'.
        t_mhnd_ext-smahsk = t_mhnd_ext-mahnn.
      ENDIF.
    ENDIF.

    IF i_check_in = space.
*     OFI check if the item is to be removed completely from the dunning
      PERFORM ofi_dun_delete_item  USING    t_mhnd_ext
                                 CHANGING h_del_du.
      IF h_del_du = 'X'.
        MOVE-CORRESPONDING t_mhnd_ext TO deleted_per_branch.
        IF t_mhnd_ext-mgrup <> space.
          deleted_per_branch-cpdky = space.
        ENDIF.
        COLLECT deleted_per_branch.
*     delete and disregard all further processing for the item
        DELETE t_mhnd_ext INDEX h_idx.
        CONTINUE.
      ENDIF.
    ENDIF.
*   generate new mhnk entry if mhnd is in a new group
    PERFORM create_mhnk   TABLES   t_mhnk_ext t_mhnk_in
                                   t_knb5 t_lfb5                "1498587
                          USING    e_t001 e_t047 e_t047a
                                   e_vfm_knxx e_vfm_lfxx
                                   i_ausdt i_grdat              "1498587
                                   h_cpdky_cpd h_cpdky_grp
                                   i_check_in
                          CHANGING t_mhnd_ext.

    MODIFY t_mhnd_ext INDEX h_idx.

  ENDLOOP.

* fill CPDKY for that entries with invoice reference.           "1406401
  LOOP AT h_mhnd_ext.                                           "1406401
    h_idx = sy-tabix.                                           "1406401
    READ table t_mhnd_ext with key kunnr = h_mhnd_ext-kunnr     "1406401
                                    lifnr = h_mhnd_ext-lifnr
                                    belnr = h_mhnd_ext-rebzg
                                    GJAHR = h_mhnd_ext-rebzj
                                    BUZEI = h_mhnd_ext-rebzz.
    IF Sy-SUBRC = 0.                                            "1406401
       h_cpdky = t_mhnd_ext-cpdky.                              "1406401
       READ table t_mhnd_ext with key kunnr = h_mhnd_ext-kunnr  "1406401
                                    lifnr = h_mhnd_ext-lifnr
                                    belnr = h_mhnd_ext-belnr
                                    GJAHR = h_mhnd_ext-gjahr
                                    BUZEI = h_mhnd_ext-buzei.
       IF SY-SUBRC = 0.                                         "1461472
         t_mhnd_ext-cpdky = h_cpdky.                            "1406401
         modify t_mhnd_ext index sy-tabix.                      "1406401
       ENDIF.                                                   "1461472
    ENDIF.                                                      "1406401
    sy-tabix = h_idx.                                           "1406401
  ENDLOOP.                                                      "1406401

************************************************************************
* Phase II check for legal Dunning procedure and assign credit memos   *
************************************************************************
  IF h_has_items = 'X'.
    PERFORM log_msg USING '822' space space space space.
  ENDIF.

* sort descending to assure the max dunning level at first position
  SORT t_mhnk_ext BY mahsk DESCENDING.

* second run checks for the accounts
  LOOP AT t_mhnk_ext.
    h_idx = sy-tabix.

*   check the legal dunning procedure handling
    PERFORM check_legal_dunning  USING    e_t047a t_mhnk_ext
                                 CHANGING t_mhnk_ext-dunn_it
                                          t_mhnk_ext-legal_du
                                          t_mhnk_ext-legal_msg.
    MODIFY t_mhnk_ext INDEX h_idx.
*   assign non invoice related credit memos to the max dunning level.
    PERFORM assign_credit_memos TABLES t_mhnd_ext t_mhnk_ext
                                USING  t_mhnk_ext.

  ENDLOOP.

* deletes all mhnk_entries without mhnd entries
  PERFORM clean_mhnk TABLES t_mhnk_ext t_mhnd_ext.


************************************************************************
* Phase III                                                            *
* check the minimum amounts for each dunning level and reassign levels *
* and amounts for the dunning and delete entrys if a dunning level     *
* could not be created and assign min interest rates and calc interest *
************************************************************************
  IF h_has_items = 'X'.
    IF 0 = 1. MESSAGE s817. ENDIF.
    PERFORM log_msg USING '817' space space space space.
  ENDIF.

  IF gd_exit_active = 'X'.
    DATA lt_mhnk LIKE mhnk OCCURS 0 WITH HEADER LINE.
    LOOP AT t_mhnk_ext.
      MOVE-CORRESPONDING t_mhnk_ext TO lt_mhnk.
      APPEND lt_mhnk.
    ENDLOOP.
    CALL FUNCTION 'OPEN_FI_PERFORM_00001763_E'
      TABLES
        ct_mhnk     = lt_mhnk
        ct_mhnd_ext = t_mhnd_ext
      EXCEPTIONS
        OTHERS      = 4.
    IF sy-subrc = 0.
      LOOP AT t_mhnk_ext.
        READ TABLE lt_mhnk INDEX sy-tabix.
        t_mhnk_ext-mahns = lt_mhnk-mahns.
        t_mhnk_ext-mahsk = lt_mhnk-mahsk.
        MODIFY t_mhnk_ext.
      ENDLOOP.
    ENDIF.
  ENDIF.

* check and assign min amounts
  PERFORM check_min_amounts TABLES   t_t047h t_mhnk_ext t_mhnd_ext
                            USING    i_check_in.

* check and assign min interest and calculate interest
  LOOP AT t_mhnk_ext.
    h_idx = sy-tabix.

*   reread the customizing for a new dunning procedure
    IF t_mhnk_ext-mahna <> e_t047a-mahna.
      PERFORM get_dunning_customizing TABLES   t_t047b t_t047c
                                               t_t047h t_t047r
                                      USING    i_bukrs t_mhnk_ext-mahna
                                      CHANGING e_t001 e_t047 e_t047a.
    ENDIF.

*   determine the minimum interest to be used for that dunning level
    PERFORM determine_min_interest TABLES   t_t047h
                                   USING    t_mhnk_ext-mahna
                                            t_mhnk_ext-mahsk
                                            t_mhnk_ext-hwaers
                                            t_mhnk_ext-waers
                                   CHANGING t_mhnk_ext-minzhw
                                            t_mhnk_ext-minzfw.

    IF i_ofi = 'X'.
      DATA  h_group_interest TYPE boole-boole.
      CALL FUNCTION 'OPEN_FI_PERFORM_00001068_P'         "IS-PS
        EXPORTING    i_mahna          = t_mhnk_ext-mahna
                     i_applk          = t_mhnk_ext-applk
        IMPORTING    e_group_interest = h_group_interest.
    ENDIF.
    DATA: t_hfimsg LIKE fimsg OCCURS 10 WITH HEADER LINE.
    DATA: h_mhnk   LIKE mhnk.
    IF h_group_interest = space.
      LOOP AT t_mhnd_ext WHERE laufd  = t_mhnk_ext-laufd AND
                             laufi  = t_mhnk_ext-laufi AND
                             koart  = t_mhnk_ext-koart AND
                             bukrs  = t_mhnk_ext-bukrs AND
                             kunnr  = t_mhnk_ext-kunnr AND
                             lifnr  = t_mhnk_ext-lifnr AND
                             cpdky  = t_mhnk_ext-cpdky AND
                             sknrze = t_mhnk_ext-sknrze AND
                             smaber = t_mhnk_ext-smaber AND
                             smahsk = t_mhnk_ext-smahsk.
*     calculate the interest
        PERFORM calc_interest  TABLES   t_t047b
                               USING    i_ausdt
                               CHANGING t_mhnk_ext
                                        t_mhnd_ext.
        MODIFY t_mhnd_ext.

      ENDLOOP.
*     BTE 1076 to be called only if switch FM_CI_CORE_SFWS_2 is on
      DATA l_fm_ci_core_sfws_2_active type xfeld.
      CALL METHOD cl_psm_core_switch_check=>psm_fm_ci_core_not_rev_2
        RECEIVING
          rv_active = l_fm_ci_core_sfws_2_active.
      IF l_fm_ci_core_sfws_2_active IS NOT INITIAL.
        MOVE-CORRESPONDING t_mhnk_ext to h_mhnk.
        CALL FUNCTION 'OPEN_FI_PERFORM_00001076_P'  "IS-PS
          EXPORTING
            i_applk          = t_mhnk_ext-applk
            i_ausdt          = i_ausdt
            i_trace          = i_trace
            i_mhnk           = h_mhnk
          TABLES
            t_fimsg          = t_hfimsg
            t_mhnd_ext       = t_mhnd_ext
            t_t047b          = t_t047b.
        PERFORM log_msg_tab tables t_hfimsg.
      ENDIF.
    ELSE.
      MOVE-CORRESPONDING t_mhnk_ext TO h_mhnk.
      CALL FUNCTION 'OPEN_FI_PERFORM_00001074_P'  "IS-PS
         EXPORTING  i_ausdt    = i_ausdt
                    i_trace    = i_trace
                    i_applk    = t_mhnk_ext-applk
         TABLES     t_mhnd_ext = t_mhnd_ext
                    t_t047b    = t_t047b
                    t_fimsg    = t_hfimsg
         CHANGING  cs_mhnk     = h_mhnk.
      MOVE-CORRESPONDING h_mhnk TO t_mhnk_ext.
      PERFORM log_msg_tab TABLES t_hfimsg.
    ENDIF.

    PERFORM check_acc_min_interest CHANGING t_mhnk_ext.

*   determine dunning charges
    PERFORM calc_charges  TABLES   t_t047c
                                   t_mhnd_ext
                          USING    i_ausdt
                          CHANGING t_mhnk_ext.


    MODIFY t_mhnk_ext INDEX h_idx.
  ENDLOOP.

************************************************************************
* Phase IV                                                             *
* create the dunning data (mhnk/mhnd) perform the final checks         *
************************************************************************
  IF h_has_items = 'X'.
    PERFORM log_msg USING '816' space space space space.
  ENDIF.

  LOOP AT t_mhnk_ext.

*   get the previous determined dunning status
    h_dunn_it = t_mhnk_ext-dunn_it.


*   reread the customizing for the account if necessary
    IF e_t047a-mahna <> t_mhnk_ext-mahna.
      PERFORM get_dunning_customizing TABLES   t_t047b t_t047c
                                               t_t047h t_t047r
                                      USING    i_bukrs t_mhnk_ext-mahna
                                      CHANGING e_t001 e_t047 e_t047a.
    ENDIF.

*   log the begining of the final run
    PERFORM log_msg USING '799' space space space space.
    IF e_t047-xmabe = 'X'.
      IF 0 = 1. MESSAGE s815. ENDIF.
      IF t_mhnk_ext-smaber <> space.
        PERFORM log_msg USING '815' t_mhnk_ext-konto
                                    t_mhnk_ext-smaber space space.
      ELSE.
        PERFORM log_msg USING '815' t_mhnk_ext-konto
                                    text-100 space space.
      ENDIF.
    ENDIF.
    IF e_t047-xstmv = 'X'.
      IF 0 = 1. MESSAGE s814. ENDIF.
      PERFORM log_msg USING '814' t_mhnk_ext-konto
                                  t_mhnk_ext-smahsk space space.
    ENDIF.
    IF e_t047-xstmv = space AND e_t047-xmabe = space.
      IF 0 = 1. MESSAGE s839. ENDIF.
      PERFORM log_msg USING '839' t_mhnk_ext-konto space space space.
    ENDIF.
    IF t_mhnk_ext-sknrze <> space.
      IF 0 = 1. MESSAGE s842. ENDIF.
      PERFORM log_msg USING '842' t_mhnk_ext-konto t_mhnk_ext-sknrze
                                  space space.
    ENDIF.

    IF 0 = 1. MESSAGE s840. ENDIF.
    PERFORM log_msg USING '840' t_mhnk_ext-konto t_mhnk_ext-mahna
                                space space.

    IF t_mhnk_ext-legal_du = 'X'.
*     log the status of the legal dunning procedure
      PERFORM log_msg USING t_mhnk_ext-legal_msg-msgno
                            t_mhnk_ext-legal_msg-msgv1
                            t_mhnk_ext-legal_msg-msgv2
                            t_mhnk_ext-legal_msg-msgv3
                            t_mhnk_ext-legal_msg-msgv4.
    ENDIF.
    IF t_mhnk_ext-min_it = 'X'.
*     log the status of the legal dunning procedure
      PERFORM log_msg USING t_mhnk_ext-min_msg-msgno
                            t_mhnk_ext-min_msg-msgv1
                            t_mhnk_ext-min_msg-msgv2
                            t_mhnk_ext-min_msg-msgv3
                            t_mhnk_ext-min_msg-msgv4.
    ENDIF.
    IF t_mhnk_ext-minz_it = 'X'.
*     log the status of the min interest check
      PERFORM log_msg USING t_mhnk_ext-minz_msg-msgno
                            t_mhnk_ext-minz_msg-msgv1
                            t_mhnk_ext-minz_msg-msgv2
                            t_mhnk_ext-minz_msg-msgv3
                            t_mhnk_ext-minz_msg-msgv4.
    ENDIF.
*    IF t_mhnk_ext-charge_it = 'X'.
*     log the status of the charge calculation
*      PERFORM log_msg USING t_mhnk_ext-charge_msg-msgno
*                            t_mhnk_ext-charge_msg-msgv1
*                            t_mhnk_ext-charge_msg-msgv2
*                            t_mhnk_ext-charge_msg-msgv3
*                            t_mhnk_ext-charge_msg-msgv4.

*    ENDIF.

    IF i_check_in = space.
*   complete mhnk entries via OpenFI
      PERFORM ofi_dun_complete_mhnk CHANGING t_mhnk_ext.
    ENDIF.

*   check dunn block reason for account
    PERFORM check_db_account USING    t_mhnk_ext
                             CHANGING h_dunn_it
                                      t_mhnk_ext-xmflg.

*   check dunning period if icc dunning is not in use
    IF h_iccd = space.
      IF NOT ( ( e_vfm_knxx-xcpdk = 'X' AND h_koart = 'D' ) OR
         ( e_vfm_lfxx-xcpdk = 'X' AND h_koart = 'K' ) ).
        PERFORM check_dunning_period USING    i_ausdt t_mhnk_ext
                                         CHANGING h_dunn_it.
      ENDIF.
    ENDIF.

*   only if account is not in the legal dunning procedure
    IF t_mhnk_ext-legal_du = space.

*   check the account delay
      PERFORM check_account_delay  USING e_t047a
                                 CHANGING t_mhnk_ext h_dunn_it.

*     check for a change in the dunning levels
      PERFORM check_dunning_change TABLES   t_t047b
                                            t_mhnd_ext
                                   USING    t_mhnk_ext
                                            i_check_in   "1615236
                                   CHANGING h_dunn_it
                                            t_mhnk_ext-xmflg.

      DATA ld_processed LIKE boole-boole.
      DATA lt_fimsg LIKE fimsg OCCURS 0 WITH HEADER LINE.
      DATA ls_mhnk LIKE mhnk.
      MOVE-CORRESPONDING t_mhnk_ext TO ls_mhnk.
      CALL FUNCTION 'OPEN_FI_PERFORM_00001764_E'
        EXPORTING
          i_waers      = e_t001-waers
        IMPORTING
          eb_processed = ld_processed
        TABLES
          t_mhnd_ext   = t_mhnd_ext
          t_t047b      = t_t047b
          t_fimsg      = lt_fimsg
        CHANGING
          cb_dunn_it   = h_dunn_it
          cs_mhnk      = ls_mhnk
        EXCEPTIONS
          OTHERS       = 0.

      IF ld_processed = space.
*     check dunning amounts
        PERFORM check_dunning_amount USING    e_t001 t_mhnk_ext
                                           e_t047a             "1113414
                                   CHANGING h_dunn_it
                                            t_mhnk_ext-xmflg.  "1493804
      ELSE.
        MOVE-CORRESPONDING ls_mhnk TO t_mhnk_ext.
        PERFORM log_msg_tab TABLES lt_fimsg.
      ENDIF.
    ENDIF.

    IF h_dunn_it = space.
*     skip the dunning if any check failed
      IF 0 = 1. MESSAGE s807. ENDIF.
      PERFORM log_msg USING '807' t_mhnk_ext-konto
                                  space space space.
      CONTINUE.
    ELSE.
*     dunning level for that account is 0 > no dunning will be created
*     unless the dunning has blocked items in that case create the
*     dunning data anyways.
      IF t_mhnk_ext-mahsk = 0 AND t_mhnk_ext-cblock = 0.
*       log the aprpriate message
        IF 0 = 1. MESSAGE s724. ENDIF.
        PERFORM log_msg USING '724' t_mhnk_ext-koart t_mhnk_ext-konto
                                  space space.
*     dunning level is 0 but there are blocked items in that case
*     create the dunning data anyways but delete all the item with
*     no dunn block reason and xfael = space (not due)
      ELSEIF t_mhnk_ext-mahsk = 0 AND t_mhnk_ext-cblock > 0.
        IF 0 = 1. MESSAGE s724. ENDIF.
        PERFORM log_msg USING '724' t_mhnk_ext-koart t_mhnk_ext-konto
                                    space space.
        IF 0 = 1. MESSAGE s812. ENDIF.
        PERFORM log_msg USING '812' t_mhnk_ext-konto
                                    space space space.
*     account has only blocked items or the account is blocked itself
      ELSEIF t_mhnk_ext-cblock > 0 AND
             t_mhnk_ext-cblock = t_mhnk_ext-call.
*             t_mhnk_ext-xmflg = 'X'.
*        if t_mhnk_ext-xmflg = 'X'.
        IF 0 = 1. MESSAGE s813. ENDIF.
        PERFORM log_msg USING '813' t_mhnk_ext-konto
                                    space space space.
*        endif.
        IF 0 = 1. MESSAGE s812. ENDIF.
        PERFORM log_msg USING '812' t_mhnk_ext-konto
                                    space space space.
      ELSEIF t_mhnk_ext-mahsk > 0 AND
             t_mhnk_ext-legal_du = space AND
             t_mhnk_ext-xmflg = 'X'.
*       account has not only blocked items and is not in a legal du proc
*       this is the finaly the 99% case of dunning letters
        IF 0 = 1. MESSAGE s811. ENDIF.
        PERFORM log_msg USING '811' t_mhnk_ext-konto
                                    t_mhnk_ext-mahsk space space.
      ELSEIF t_mhnk_ext-xmflg = space.
*       account will not be dunned but items will be created anyways,
*       this normaly means that the account has a dunn block reason
        IF 0 = 1. MESSAGE s835. ENDIF.
        PERFORM log_msg USING '835' t_mhnk_ext-konto
                                    space space space.

      ENDIF.
    ENDIF.

    LOOP AT t_mhnd_ext WHERE laufd  = t_mhnk_ext-laufd AND
                             laufi  = t_mhnk_ext-laufi AND
                             koart  = t_mhnk_ext-koart AND
                             bukrs  = t_mhnk_ext-bukrs AND
                             kunnr  = t_mhnk_ext-kunnr AND
                             lifnr  = t_mhnk_ext-lifnr AND
                             cpdky  = t_mhnk_ext-cpdky AND
                             sknrze = t_mhnk_ext-sknrze AND
                             smaber = t_mhnk_ext-smaber AND
                             smahsk = t_mhnk_ext-smahsk.

*     fill and show the status to be shown in the log file
      IF t_mhnd_ext-xzalb = SPACE.                              "1111000
        PERFORM fill_status    USING    t_mhnd_ext
                               CHANGING t_mhnd_ext-status.
      ENDIF.                                                    "1111000
      IF NOT t_mhnk_ext-gmvdt IS INITIAL.
*       this value is requested by the print form
        t_mhnd_ext-mahnn = t_mhnd_ext-mahns.
      ENDIF.

      CLEAR t_mhnd.
      MOVE-CORRESPONDING t_mhnd_ext TO t_mhnd.
      APPEND t_mhnd.

    ENDLOOP.
    IF sy-subrc = 0.
      CLEAR t_mhnk.
      MOVE-CORRESPONDING t_mhnk_ext TO t_mhnk.
*     this value is requested by the print form
      t_mhnk-mahns = t_mhnk-mahsk.

*     expiring currencies: is MHNK-WAERS en expiring currency ?
*     MHNK-WAERS is only an expiring currency, if the company code
*     currency is expiring too, and not yet converted.
*     If so, convert all amounts with reference to MHNK-WAERS in table
*     MHNK to the subsequent currency of MHNK-WAERS.
      IF convert_currency = 'T'.
        IF ( t_mhnk-waers = e_t001-waers ) AND
          ( new_cc_currency <> e_t001-waers ).
*-------Get all fields with reference to MHNK-WAERS:
          DATA h_xdfies LIKE dfies OCCURS 0 WITH HEADER LINE.
          DESCRIBE TABLE gt_fieldlist_dc LINES h_line.
          IF h_line = 0.
            CALL FUNCTION 'DDIF_FIELDINFO_GET'
              EXPORTING
                tabname        = 'MHNK'
              TABLES
                dfies_tab      = h_xdfies
              EXCEPTIONS
                not_found      = 1
                internal_error = 2
                OTHERS         = 3.
            LOOP AT h_xdfies.
              IF  h_xdfies-datatype = 'CURR'
                  AND h_xdfies-reftable = 'MHNK'
                  AND h_xdfies-reffield = 'WAERS'.
                gt_fieldlist_dc-name = h_xdfies-fieldname.
                APPEND gt_fieldlist_dc.
              ENDIF.
            ENDLOOP.
          ENDIF.
          CALL FUNCTION 'CURRENCY_DOCUMENT_CONVERT'
            EXPORTING
              conversion_mode     = 'O'
              from_currency       = t_mhnk-waers
              to_currency         = new_cc_currency
              date                = t_mhnk-ausdt
              local_currency      = e_t001-waers
            TABLES
              fieldlist           = gt_fieldlist_dc
            CHANGING
              line                = t_mhnk
            EXCEPTIONS
              field_unknown       = 1
              field_not_amount    = 2
              error_in_conversion = 3
              OTHERS              = 4.

          t_mhnk-waers = new_cc_currency.


          MOVE-CORRESPONDING t_mhnk TO t_mhnk_ext.
* recompute the dunning charges:
          PERFORM calc_charges  TABLES   t_t047c
                                         t_mhnd_ext
                                USING    t_mhnk-ausdt
                                CHANGING t_mhnk_ext.
          t_mhnk-mhngf = t_mhnk_ext-mhngf.
          t_mhnk-mhngh = t_mhnk_ext-mhngh.
        ENDIF.
      ENDIF.        " / if convert_currency

      IF t_mhnk_ext-charge_it = 'X'.
*     log the status of the charge calculation
        PERFORM log_msg USING t_mhnk_ext-charge_msg-msgno
                            t_mhnk_ext-charge_msg-msgv1
                            t_mhnk_ext-charge_msg-msgv2
                            t_mhnk_ext-charge_msg-msgv3
                            t_mhnk_ext-charge_msg-msgv4.

      ENDIF.


      APPEND t_mhnk.
      IF 0 = 1. MESSAGE s806. ENDIF.
      PERFORM log_msg USING '806' t_mhnk_ext-konto
                                  space space space.
    ELSE.
      IF 0 = 1. MESSAGE s807. ENDIF.
      PERFORM log_msg USING '807' t_mhnk_ext-konto
                                  space space space.
    ENDIF.

  ENDLOOP.


* generate log
  IF i_trace = 'X'.
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
  ENDIF.
ENDFUNCTION.

*&---------------------------------------------------------------------*
*&      Form  CREATE_CPDKY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHND  text                                               *
*      <--P_T_MHND-CPDKY  text                                         *
*----------------------------------------------------------------------*
FORM create_cpdky USING    i_bsec       LIKE bsec
                  CHANGING e_cpdky      LIKE mhnd-cpdky.

* declarations
  DATA: h_cpdvs LIKE cpdvs.

* check for cpdky < 3.0E and create a new key.
  IF i_bsec-empfg+5(1) = '0'.
    MOVE-CORRESPONDING i_bsec TO h_cpdvs.
    CALL FUNCTION 'FI_ONETIMEACNT_RECEIVER_DECODE'
      EXPORTING
        i_cpdvs = h_cpdvs
      IMPORTING
        e_empfg = e_cpdky.
  ELSE.
    e_cpdky = i_bsec-empfg.
  ENDIF.
ENDFORM.                               " CREATE_CPDKY
*&---------------------------------------------------------------------*
*&      Form  INIT_MHND_CUSTOMER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_LAUFD  text                                              *
*      -->P_I_LAUFI  text                                              *
*      -->P_I_BUKRS  text                                              *
*      -->P_I_KUNNR  text                                              *
*----------------------------------------------------------------------*
FORM init_mhnd            USING    i_laufd    LIKE f150v-laufd
                                   i_laufi    LIKE f150v-laufi
                                   i_bukrs    LIKE t001-bukrs
                                   i_kunnr    LIKE kna1-kunnr
                                   i_lifnr    LIKE lfa1-lifnr
                                   i_koart    LIKE mhnk_ext-koart
                                   i_iccd     LIKE boole-boole
                                   i_check_in LIKE boole-boole
                          CHANGING e_mhnd_ext LIKE mhnd_ext.

* dunning will be created from bsid
  IF i_check_in = space.
*   init key fields
    e_mhnd_ext-laufd = i_laufd.
    e_mhnd_ext-laufi = i_laufi.
    e_mhnd_ext-koart = i_koart.
    e_mhnd_ext-bukrs = i_bukrs.
    e_mhnd_ext-kunnr = i_kunnr.
    e_mhnd_ext-lifnr = i_lifnr.

*   get old dunning level from bsid/bsik
    e_mhnd_ext-mahns = e_mhnd_ext-manst.

*   assign belnr as default value to the xbelnr
    IF e_mhnd_ext-xblnr IS INITIAL.
      e_mhnd_ext-xblnr = e_mhnd_ext-belnr.
    ENDIF.

*   assign bldat as defaul value for due date
    IF e_mhnd_ext-zfbdt = '00000000'.
      e_mhnd_ext-zfbdt = e_mhnd_ext-bldat.
    ENDIF.

*   determine amount and check sign
    e_mhnd_ext-dmshb = e_mhnd_ext-dmbtr.
    e_mhnd_ext-wrshb = e_mhnd_ext-wrbtr.
    IF e_mhnd_ext-shkzg = 'H'.
      e_mhnd_ext-dmshb = - e_mhnd_ext-dmshb.
      e_mhnd_ext-wrshb = - e_mhnd_ext-wrshb.
    ENDIF.
  ENDIF.

* determine the belinfo field used in messages
  IF i_iccd = space.
    e_mhnd_ext-blinf    = e_mhnd_ext-belnr.
    e_mhnd_ext-blinf+10 = '/'.
    e_mhnd_ext-blinf+11 = e_mhnd_ext-gjahr.
    e_mhnd_ext-blinf+15 = '/'.
    e_mhnd_ext-blinf+16 = e_mhnd_ext-buzei.
  ELSE.
    e_mhnd_ext-blinf    = e_mhnd_ext-bbukrs.
    e_mhnd_ext-blinf+4  = '/'.
    e_mhnd_ext-blinf+5  = e_mhnd_ext-belnr.
    e_mhnd_ext-blinf+15 = '/'.
    e_mhnd_ext-blinf+16 = e_mhnd_ext-gjahr.
    e_mhnd_ext-blinf+20 = '/'.
    e_mhnd_ext-blinf+21 = e_mhnd_ext-buzei.
  ENDIF.

ENDFORM.                               " INIT_MHND_CUSTOMER

*&---------------------------------------------------------------------*
*&      Form  CREATE_MGRUP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHND  text                                               *
*      <--P_T_MHND-CPDKY  text                                         *
*----------------------------------------------------------------------*
FORM create_mgrup USING    i_mhnd_ext LIKE mhnd_ext
                  CHANGING e_cpdky    LIKE mhnd-cpdky.
* declaration
  DATA: h_feld(32)       TYPE c.

* build cpdkey from the group field in mhnd_ext
  h_feld     = i_mhnd_ext-group1.
  CONDENSE h_feld NO-GAPS.
  e_cpdky    = h_feld.

* issue error in case of cpdky overflow when using dunning groups
  sy-subrc = 0.
  IF h_feld+16 <> space.
    sy-subrc = 4.
  ENDIF.

ENDFORM.                               " CREATE_MGRUP
*&---------------------------------------------------------------------*
*&      Form  LOG_MSG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY-MSGNO  text                                             *
*      -->P_SY-MSGV1  text                                             *
*      -->P_SY-MSGV2  text                                             *
*      -->P_SY-MSGV3  text                                             *
*      -->P_SY-MSGV4  text                                             *
*----------------------------------------------------------------------*
FORM log_msg USING    i_msgno LIKE sy-msgno
                      i_msgv1
                      i_msgv2
                      i_msgv3
                      i_msgv4.
* declaration
  DATA: h_fimsg LIKE fimsg.

* log the message with the message handler
  h_fimsg-msgid = 'FM'.
  h_fimsg-msgty = 'S'.
  h_fimsg-msgno = i_msgno.
  h_fimsg-msgv1 = i_msgv1. CONDENSE h_fimsg-msgv1.
  h_fimsg-msgv2 = i_msgv2. CONDENSE h_fimsg-msgv2.
  h_fimsg-msgv3 = i_msgv3. CONDENSE h_fimsg-msgv3.
  h_fimsg-msgv4 = i_msgv4. CONDENSE h_fimsg-msgv4.
  CALL FUNCTION 'FI_MESSAGE_COLLECT'
    EXPORTING
      i_fimsg       = h_fimsg
      i_xappn       = 'X'
    EXCEPTIONS
      msgid_missing = 1
      msgno_missing = 2
      msgty_missing = 3
      OTHERS        = 4.
ENDFORM.                               " LOG_MSG
*&---------------------------------------------------------------------*
*&      Form  LOG_SYMSG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY-MSGNO  text                                             *
*      -->P_SY-MSGV1  text                                             *
*      -->P_SY-MSGV2  text                                             *
*      -->P_SY-MSGV3  text                                             *
*      -->P_SY-MSGV4  text                                             *
*----------------------------------------------------------------------*
FORM log_symsg.
* declaration
  DATA: h_fimsg LIKE fimsg.

* log the message with the message handler
  h_fimsg-msgid = sy-msgid.
  h_fimsg-msgty = sy-msgty.
  h_fimsg-msgno = sy-msgno.
  h_fimsg-msgv1 = sy-msgv1. CONDENSE h_fimsg-msgv1.
  h_fimsg-msgv2 = sy-msgv2. CONDENSE h_fimsg-msgv2.
  h_fimsg-msgv3 = sy-msgv3. CONDENSE h_fimsg-msgv3.
  h_fimsg-msgv4 = sy-msgv4. CONDENSE h_fimsg-msgv4.
  CALL FUNCTION 'FI_MESSAGE_COLLECT'
    EXPORTING
      i_fimsg       = h_fimsg
      i_xappn       = 'X'
    EXCEPTIONS
      msgid_missing = 1
      msgno_missing = 2
      msgty_missing = 3
      OTHERS        = 4.
ENDFORM.                               " LOG_MSG

*&---------------------------------------------------------------------*
*&      Form  CREATE_MGRUP_CUSTOMER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_T_MHND_EXT-MGRUP  text                                     *
*----------------------------------------------------------------------*
FORM create_mgrup_customer TABLES   t_t047r    STRUCTURE t047r
                           USING    i_mgrup    LIKE vfm_knxx-mgrup
                           CHANGING e_group    LIKE mhnd_ext-group1.

* declaration
  DATA: fname1-bsid(35) TYPE c,        "Feldname 1 fuer MGRUP Debit.
        fname2-bsid(35) TYPE c,        "Feldname 2 fuer MGRUP Debit.
        l_describe TYPE REF TO cl_abap_typedescr.

* get the customizing
* select single * from t047r where mgrup = i_mgrup.

  READ TABLE t_t047r WITH KEY mgrup = i_mgrup.
  t047r = t_t047r.
  IF sy-subrc NE 0.
    MESSAGE e219 WITH     i_mgrup bsid-kunnr bsid-bukrs
                 RAISING  dunning_group_not_maintained.
  ENDIF.
* fill assign fields
  IF t047r-xdebi EQ space.
    fname1-bsid = 'BSID-'.
    fname1-bsid+5 = t047r-name1.
    ASSIGN (fname1-bsid) TO <g1>.
    IF t047r-name2 <> space.
      fname2-bsid = 'BSID-'.
      fname2-bsid+5 = t047r-name2.
      ASSIGN (fname2-bsid) TO <g2>.
    ENDIF.
  ENDIF.
  l_describe = cl_abap_typedescr=>describe_by_data( <g1> ).
  IF NOT l_describe->type_kind = 'P'.
    IF t047r-leng1 EQ 0.
      IF t047r-xdebi EQ space.
        ASSIGN <g1>+t047r-offs1 TO <g1>.
      ENDIF.
    ELSE.
      IF t047r-xdebi EQ space.
        ASSIGN <g1>+t047r-offs1(t047r-leng1) TO <g1>.
      ENDIF.
    ENDIF.
  ENDIF.
  IF t047r-name2 <> space.
    l_describe = cl_abap_typedescr=>describe_by_data( <g2> ).
    IF NOT l_describe->type_kind = 'P'.
      IF t047r-leng2 EQ 0.
        IF t047r-xdebi EQ space.
          ASSIGN <g2>+t047r-offs2 TO <g2>.
        ENDIF.
      ELSE.
        IF t047r-xdebi EQ space.
          ASSIGN <g2>+t047r-offs2(t047r-leng2) TO <g2>.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
* assign the goups
  e_group    = <g1>.
  IF t047r-name2 <> space.
    e_group+16 = <g2>.
  ENDIF.
ENDFORM.                               " CREATE_MGRUP_CUSTOMER
*&---------------------------------------------------------------------*
*&      Form  CREATE_MGRUP_VENDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_T_MHND_EXT-MGRUP  text                                     *
*----------------------------------------------------------------------*
FORM create_mgrup_vendor   TABLES   t_t047r    STRUCTURE t047r
                           USING    i_mgrup    LIKE vfm_knxx-mgrup
                           CHANGING e_group    LIKE mhnd_ext-group1.
* declaration
  DATA: fname1-bsik(35) TYPE c,        "Feldname 1 fuer MGRUP Kred.
        fname2-bsik(35) TYPE c,        "Feldname 2 fuer MGRUP Kred.
        l_describe TYPE REF TO cl_abap_typedescr.

* get the customizing
*  select single * from t047r where mgrup = i_mgrup.

  READ TABLE t_t047r WITH KEY mgrup = i_mgrup.
  t047r = t_t047r.
  IF sy-subrc NE 0.
    MESSAGE e219 WITH    i_mgrup bsid-kunnr bsid-bukrs
                 RAISING dunning_group_not_maintained.
  ENDIF.
* fill assign fields
  IF t047r-xkred EQ space.
    fname1-bsik = 'BSIK-'.
    fname1-bsik+5 = t047r-name1.
    ASSIGN (fname1-bsik) TO <g3>.
    IF t047r-name2 <> space.
      fname2-bsik = 'BSIK-'.
      fname2-bsik+5 = t047r-name2.
      ASSIGN (fname2-bsik) TO <g4>.
    ENDIF.
  ENDIF.
  l_describe = cl_abap_typedescr=>describe_by_data( <g3> ).
  IF NOT l_describe->type_kind = 'P'.
    IF t047r-leng1 EQ 0.
      IF t047r-xkred EQ space.
        ASSIGN <g3>+t047r-offs1 TO <g3>.
      ENDIF.
    ELSE.
      IF t047r-xkred EQ space.
        ASSIGN <g3>+t047r-offs1(t047r-leng1) TO <g3>.
      ENDIF.
    ENDIF.
  ENDIF.
  IF t047r-name2 <> space.                                      "1163617
    l_describe = cl_abap_typedescr=>describe_by_data( <g4> ).
  IF NOT l_describe->type_kind = 'P'.
    IF t047r-leng2 EQ 0.
      IF t047r-xkred EQ space.
        ASSIGN <g4>+t047r-offs2 TO <g4>.
      ENDIF.
    ELSE.
      IF t047r-xkred EQ space.
        ASSIGN <g4>+t047r-offs2(t047r-leng2) TO <g4>.
      ENDIF.
    ENDIF.
  ENDIF.
  ENDIF.                                                        "1163617
* assign the goups
  e_group    = <g3>.
  IF t047r-name2 <> space.
    e_group+16 = <g4>.
  ENDIF.
ENDFORM.                               " CREATE_MGRUP_VENDOR
*&---------------------------------------------------------------------*
*&      Form  CREATE_DEZV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_T_MHND_EXT  text                                           *
*----------------------------------------------------------------------*
FORM create_dezv TABLES   t_knb5 STRUCTURE knb5
                          t_lfb5 STRUCTURE lfb5
                 CHANGING e_mhnd_ext LIKE mhnd_ext
                          e_vfm_knxx LIKE vfm_knxx
                          e_vfm_lfxx LIKE vfm_lfxx.
* wrap accounts if item is a branch item and reselect master data
  IF e_mhnd_ext-filkd <> space.
    IF e_mhnd_ext-koart = 'D'.
      e_mhnd_ext-sknrze = e_mhnd_ext-kunnr.
      e_mhnd_ext-kunnr  = e_mhnd_ext-filkd.
      IF e_mhnd_ext-kunnr <> e_vfm_knxx-kunnr OR
         e_mhnd_ext-bukrs  <> e_vfm_knxx-bukrs.
        SELECT SINGLE * FROM  vfm_knxx INTO e_vfm_knxx
               WHERE  kunnr       = e_mhnd_ext-kunnr
               AND    bukrs       = e_mhnd_ext-bukrs
               AND    maber       = space.
        SELECT  * FROM  knb5 APPENDING TABLE t_knb5
               WHERE  kunnr       = e_mhnd_ext-kunnr
               AND    bukrs       = e_mhnd_ext-bukrs.
      ENDIF.
    ELSE.
      e_mhnd_ext-sknrze = e_mhnd_ext-lifnr.
      e_mhnd_ext-lifnr  = e_mhnd_ext-filkd.
      IF e_mhnd_ext-lifnr <> e_vfm_lfxx-lifnr OR
         e_mhnd_ext-bukrs <> e_vfm_lfxx-bukrs.
        SELECT SINGLE * FROM  vfm_lfxx INTO e_vfm_lfxx
               WHERE  lifnr       = e_mhnd_ext-lifnr
               AND    bukrs       = e_mhnd_ext-bukrs
               AND    maber       = space.
        SELECT  * FROM  lfb5 APPENDING TABLE t_lfb5
               WHERE  lifnr       = e_mhnd_ext-lifnr
               AND    bukrs       = e_mhnd_ext-bukrs.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                               " CREATE_DEZV

*&---------------------------------------------------------------------*
*&      Form  READ_BSEC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHND_EXT  text                                           *
*      <--P_E_BSEC  text                                               *
*----------------------------------------------------------------------*
FORM read_bsec USING    i_mhnd_ext LIKE mhnd_ext
               CHANGING e_bsec LIKE bsec.
* determine item
  SELECT SINGLE * FROM  bsec INTO e_bsec
                             WHERE  bukrs = i_mhnd_ext-bbukrs
                             AND    belnr = i_mhnd_ext-belnr
                             AND    gjahr = i_mhnd_ext-gjahr
                             AND    buzei = i_mhnd_ext-buzei.

ENDFORM.                               " READ_BSEC

*&---------------------------------------------------------------------*
*&      Form  CREATE_CPD_ADDRESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_BSEC  text                                               *
*      <--P_T_MHND_EXT  text                                           *
*----------------------------------------------------------------------*
FORM create_cpd_address USING    i_bsec LIKE bsec
                        CHANGING e_mhnd_ext LIKE mhnd_ext.

* save the address of the cpd-account with the item
  e_mhnd_ext-pstlz = i_bsec-pstlz.
  e_mhnd_ext-ort01 = i_bsec-ort01.
  e_mhnd_ext-stras = i_bsec-stras.
  e_mhnd_ext-pfach = i_bsec-pfach.
  e_mhnd_ext-land1 = i_bsec-land1.
  IF i_bsec-pstl2 NE space.            "Postleitzahl des Postfachs hat
    e_mhnd_ext-pstlz = i_bsec-pstl2.   "Priorität
  ENDIF.

ENDFORM.                               " CREATE_CPD_ADDRESS

*&---------------------------------------------------------------------*
*&      Form  DETERMINE_DUE_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_T_MHND_EXT  text                                           *
*----------------------------------------------------------------------*
FORM determine_due_date USING    i_ausdt    LIKE f150v-ausdt
                                 i_t047a    LIKE t047a
                                 i_mhnd_ext LIKE mhnd_ext
                        CHANGING e_faedt    LIKE mhnd_ext-faedt
                                 e_verzn    LIKE mhnd_ext-verzn
                                 e_xfael    LIKE mhnd_ext-xfael.

* declaration
  DATA: h_faede   LIKE faede,
        h_refe(8) TYPE p.

* determine the due date
  CLEAR h_faede.
  MOVE-CORRESPONDING i_mhnd_ext TO h_faede.
  h_faede-koart = i_mhnd_ext-bkoart.
  CALL FUNCTION 'DETERMINE_DUE_DATE'
    EXPORTING
      i_faede = h_faede
    IMPORTING
      e_faede = h_faede
    EXCEPTIONS
      OTHERS  = 1.
  e_faedt = h_faede-netdt.

*------- Verzugstage / Kennzeichen Faelligkeit
*        bei nicht rechnungsbez. Gutschr. keine Kulanz
  h_refe = i_ausdt - e_faedt.
  IF h_refe < 99999.
    IF h_refe > -99999.
      e_verzn = h_refe.
    ELSE.
      e_verzn = -99999.
    ENDIF.
  ELSE.
    e_verzn = 99999.
  ENDIF.
  IF i_mhnd_ext-shkzg = 'S' OR i_mhnd_ext-rebzg NE space.
    IF e_verzn > i_t047a-kulep.
      e_xfael = 'X'.
    ELSE.
      IF e_verzn > 0.
        IF 1 = 0. MESSAGE s808. ENDIF.
        PERFORM log_msg USING '808' i_mhnd_ext-blinf
                                    e_verzn i_t047a-kulep space.
      ELSE.
        IF 1 = 0. MESSAGE s809. ENDIF.
        PERFORM log_msg USING '809' i_mhnd_ext-blinf
                                    e_verzn space space.
      ENDIF.
    ENDIF.
  ELSEIF e_verzn > 0.
    e_xfael = 'X'.
  ENDIF.
ENDFORM.                               " DETERMINE_DUE_DATE


*&---------------------------------------------------------------------*
*&      Form  DETERMINE_MAHNA
*&---------------------------------------------------------------------*
*       Determine the dunning procedure vor the dunning area in the open
*       item regarding the KOART. If no dunning procedure can be found
*       in VFM_KNXX
*----------------------------------------------------------------------*
*      -->P_T_MHND_EXT  text                                           *
*      <--P_E_MAHNA  text                                              *
*----------------------------------------------------------------------*
FORM determine_mahna TABLES   t_knb5 STRUCTURE knb5
                              t_lfb5 STRUCTURE lfb5
                     USING    i_mhnd_ext LIKE mhnd_ext
                              i_orgmahna LIKE t047a-mahna
                     CHANGING e_mahna    LIKE t047a-mahna
                              e_knb5     LIKE knb5
                              e_lfb5     LIKE lfb5.
  e_mahna = space.
  IF i_mhnd_ext-bkoart = 'D'.
*   first guess: try to find mahna for the dunning area
    READ TABLE t_knb5 WITH KEY bukrs = i_mhnd_ext-bukrs
                               kunnr = i_mhnd_ext-kunnr
                               maber = i_mhnd_ext-maber.
*   second gues reread default mahna
    IF sy-subrc <> 0.
      READ TABLE t_knb5 WITH KEY bukrs = i_mhnd_ext-bukrs
                                 kunnr = i_mhnd_ext-kunnr
                                 maber = space.
      IF i_mhnd_ext-smaber <> space.
*       dunning per dunning area is active
        CLEAR t_knb5-madat.
      ENDIF.
    ENDIF.
    e_knb5  = t_knb5.
    e_mahna = t_knb5-mahna.
  ELSE.
*   first guess: try to find mahna for the dunning area
    READ TABLE t_lfb5 WITH KEY bukrs = i_mhnd_ext-bukrs
                               lifnr = i_mhnd_ext-lifnr
                               maber = i_mhnd_ext-maber.
*   second gues reread default mahna
    IF sy-subrc <> 0.
      READ TABLE t_lfb5 WITH KEY bukrs = i_mhnd_ext-bukrs
                                 lifnr = i_mhnd_ext-lifnr
                                 maber = space.
      IF i_mhnd_ext-smaber <> space.
*       dunning per dunning area is active
        CLEAR t_lfb5-madat.
      ENDIF.
    ENDIF.
    e_lfb5  = t_lfb5.
    e_mahna = t_lfb5-mahna.
  ENDIF.

* if procedure is empty use default procedure
  IF e_mahna = space.
    e_mahna = i_orgmahna.
  ENDIF.

ENDFORM.                               " DETERMINE_MAHNA
*&---------------------------------------------------------------------*
*&      Form  DETERMINE_DU_LEVEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_T047B  text                                              *
*      -->P_E_T047A  text                                              *
*      -->P_T_MHND_EXT  text                                           *
*      <--P_T_MHND_EXT-MAHNN  text                                     *
*      <--P_IF  text                                                   *
*      <--P_E_T047-XSTMV  text                                         *
*      <--P_=  text                                                    *
*      <--P_'X'  text                                                  *
*----------------------------------------------------------------------*
FORM determine_du_level TABLES   t_t047b STRUCTURE t047b
                        USING    i_mhnd_ext LIKE mhnd_ext
                        CHANGING e_mahnn LIKE mhnd_ext-mahnn.
* declaration
  DATA : h_refe(8) TYPE p.

* if item is a normal item
  IF i_mhnd_ext-cmemo = space.
*   determine the possible dunning level
    e_mahnn = 0.
    LOOP AT t_t047b.
      IF i_mhnd_ext-verzn < t_t047b-vertg.
        EXIT.
      ENDIF.
      e_mahnn = t_t047b-mahns.
    ENDLOOP.

*   calcualte the actuak dunning level
    h_refe = i_mhnd_ext-mahns + 1.
    IF h_refe < e_mahnn.
      e_mahnn = h_refe.
    ENDIF.

*   check if the new dunning level is greter then the old one
    IF e_mahnn < i_mhnd_ext-mahns.
      e_mahnn = i_mhnd_ext-mahns.
    ENDIF.

*   log the new dunning level for the item                      "1273832
*   IF 0 = 1. MESSAGE s831. ENDIF.                              "1273832
*   PERFORM log_msg USING
*           '831' i_mhnd_ext-blinf e_mahnn space space.         "1273832
  ELSE.
*   max dunning level for non invoice related credit memos will be re-
*   assigned and logged later
    e_mahnn = 9.
  ENDIF.

ENDFORM.                               " DETERMINE_DU_LEVEL

*&---------------------------------------------------------------------*
*&      Form  GET_DUNNING_CUSTOMIZING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_T047B  text                                              *
*      -->P_I_BUKRS  text                                              *
*      -->P_E_VFM_KNXX-MAHNA  text                                     *
*      <--P_E_T047  text                                               *
*      <--P_E_T047A  text                                              *
*----------------------------------------------------------------------*
FORM get_dunning_customizing TABLES   t_t047b STRUCTURE t047b
                                      t_t047c STRUCTURE t047c
                                      t_t047h STRUCTURE t047h
                                      t_t047r STRUCTURE t047r
                             USING    i_bukrs LIKE t001-bukrs
                                      i_mahna LIKE t047a-mahna
                             CHANGING e_t001  LIKE t001
                                      e_t047  LIKE t047
                                      e_t047a LIKE t047a.
* declaration
  DATA : lin LIKE sy-tabix.


  CALL FUNCTION 'GET_DUNNING_CUSTOMIZING_SEL'
    EXPORTING
      i_bukrs           = i_bukrs
      i_mahna           = i_mahna
    IMPORTING
      e_t001            = e_t001
      e_t047            = e_t047
      e_t047a           = e_t047a
    TABLES
      t_t047b           = t_t047b
      t_t047c           = t_t047c
    EXCEPTIONS
      param_error_t001  = 1
      param_error_t047  = 2
      param_error_t047a = 3
      param_error_t047b = 4
      OTHERS            = 5.
  CASE sy-subrc.
    WHEN 1.
      MESSAGE e451 WITH i_bukrs RAISING customizing_error.
    WHEN 2.
      MESSAGE e452 WITH i_bukrs RAISING customizing_error.
    WHEN 3.
      MESSAGE e453 WITH i_mahna RAISING customizing_error.
    WHEN 4.
      MESSAGE e457 WITH i_mahna RAISING customizing_error.
  ENDCASE.

* read all the min values
  DESCRIBE TABLE t_t047h LINES lin.
  IF lin = 0.
    SELECT * FROM t047h INTO TABLE t_t047h.
  ENDIF.

* read all the min values
  DESCRIBE TABLE t_t047r LINES lin.
  IF lin = 0.
    SELECT * FROM t047r INTO TABLE t_t047r.
  ENDIF.

ENDFORM.                               " GET_DUNNING_CUSTOMIZING
*&---------------------------------------------------------------------*
*&      Form  DETERMINE_DU_KEY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHND_EXT-MSCHL  text                                     *
*      <--P_T_MHND_EXT-MAHNN  text                                     *
*      <--P_T_MHND_EXT-SMSCHL  text                                    *
*----------------------------------------------------------------------*
FORM determine_du_key USING    i_mhnd_ext  LIKE mhnd_ext
                      CHANGING e_mahnn     LIKE mhnd-mahnn
                               e_smschl    LIKE mhnd-smschl.
* determine dunning key
  SELECT SINGLE * FROM t040 WHERE mschl = i_mhnd_ext-mschl.
  IF sy-subrc NE 0.
    IF 0 = 1. MESSAGE s119. ENDIF.
    PERFORM log_msg USING '119' i_mhnd_ext-mschl i_mhnd_ext-bukrs
                                i_mhnd_ext-belnr i_mhnd_ext-gjahr.
  ELSE.
*   assign the max dunning level regarding the dunning key
    IF t040-maxst <> space AND
       t040-maxst <> '0' AND
       e_mahnn > t040-maxst.
      e_mahnn = t040-maxst.
    ENDIF.
*   assign dunning key for separate info in dunning notice
    IF t040-xsepd NE space.
      e_smschl = i_mhnd_ext-mschl.
    ENDIF.
  ENDIF.
ENDFORM.                               " DETERMINE_DU_KEY
