*-------------------------------------------------------------------
***INCLUDE LF150F0C .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  CHECK_DUNNING_CHANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_T047B  text                                              *
*      -->P_T_MHNK_EXT  text                                           *
*      <--P_H_DUNN_IT  text                                            *
*----------------------------------------------------------------------*
FORM check_dunning_change TABLES   t_t047b    STRUCTURE t047b
                                   t_mhnd_ext STRUCTURE mhnd_ext
                          USING    i_mhnk_ext LIKE mhnk_ext
                                   i_check_in LIKE boole-boole "1615236
                          CHANGING e_dunn_it
                                   e_mhnk_xmflg.
  CHECK e_dunn_it = 'X'.

* read the customizing
  READ TABLE t_t047b WITH KEY mahna = i_mhnk_ext-mahna
                              mahns = i_mhnk_ext-mahsk.
  IF sy-subrc = 0.
*   do not print dunning when no changes are to be printed and account
*   has not only blocked items
    IF t_t047b-xaend = space AND i_mhnk_ext-cblock < i_mhnk_ext-call.
      e_dunn_it = space.
      LOOP AT t_mhnd_ext WHERE laufd  = i_mhnk_ext-laufd AND
                         laufi  = i_mhnk_ext-laufi AND
                         koart  = i_mhnk_ext-koart AND
                         bukrs  = i_mhnk_ext-bukrs AND
                         kunnr  = i_mhnk_ext-kunnr AND
                         lifnr  = i_mhnk_ext-lifnr AND
                         cpdky  = i_mhnk_ext-cpdky AND
                         sknrze = i_mhnk_ext-sknrze AND
                         smaber = i_mhnk_ext-smaber AND
                         smahsk = i_mhnk_ext-smahsk.
        IF ( t_mhnd_ext-mahnn > t_mhnd_ext-mahns OR             "1615236
             t_mhnd_ext-mahnn < t_mhnd_ext-mahns ) AND          "1615236
            t_mhnd_ext-mansp = space AND t_mhnd_ext-xzalb = space.
          e_dunn_it = 'X'.  EXIT.
        ENDIF.
      ENDLOOP.
      IF e_dunn_it = space.
* check for blocked items
        LOOP AT t_mhnd_ext WHERE laufd  = i_mhnk_ext-laufd AND
                           laufi  = i_mhnk_ext-laufi AND
                           koart  = i_mhnk_ext-koart AND
                           bukrs  = i_mhnk_ext-bukrs AND
                           kunnr  = i_mhnk_ext-kunnr AND
                           lifnr  = i_mhnk_ext-lifnr AND
                           cpdky  = i_mhnk_ext-cpdky AND
                           sknrze = i_mhnk_ext-sknrze AND
                           smaber = i_mhnk_ext-smaber AND
                           smahsk = i_mhnk_ext-smahsk.
          IF t_mhnd_ext-mansp <> space.
            DATA new_level LIKE mhnd-mahnn.
* simulate new dunning-level
            PERFORM determine_du_level TABLES    t_t047b
                                        USING    t_mhnd_ext
                                        CHANGING new_level.
            IF new_level > t_mhnd_ext-mahns.
              e_dunn_it = 'X'.
* do not print the letter, block has to be removed manually first
              e_mhnk_xmflg = space.
              EXIT.
            ENDIF.
          ENDIF.
          IF i_check_in = 'X' and t_t047b-xaend = space.        "1615236
            clear e_mhnk_xmflg.                                 "1615236
            e_dunn_it = 'X'.                                    "1615236
          ENDIF.                                                "1615236
        ENDLOOP.
      ENDIF.
      IF e_dunn_it = space.
        IF i_mhnk_ext-smaber = space AND i_mhnk_ext-smahsk = space.
          IF 0 = 1. MESSAGE s711. ENDIF.
          PERFORM log_msg USING '711' i_mhnk_ext-koart i_mhnk_ext-konto
                                      space space.
        ELSE.
          IF 0 = 1. MESSAGE s712. ENDIF.
         PERFORM log_msg USING '712' i_mhnk_ext-konto i_mhnk_ext-smaber
                                      i_mhnk_ext-mahsk space.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                               " CHECK_DUNNING_CHANGE
*&---------------------------------------------------------------------*
*&      Form  CHECK_DUNNING_PERIOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_AUSDT  text                                              *
*      -->P_T_MHNK-MAHNA  text                                         *
*      <--P_H_DUNN_IT  text
**----------------------------------------------------------------------
*
FORM check_dunning_period USING    i_ausdt    LIKE f150v-ausdt
                                   i_mhnk_ext LIKE mhnk_ext
                          CHANGING e_dunn_it  LIKE boole-boole.
* declaration
  DATA: h_date LIKE f150v-ausdt,
        h_kto  LIKE mhnk_ext-kunnr,
        h_char(15) TYPE c.

* test previous checks
  CHECK e_dunn_it = 'X'.

* check the dunning period
  e_dunn_it = 'X'.
  h_date = i_mhnk_ext-madat + i_mhnk_ext-rhyth.
  IF i_ausdt < h_date.
    e_dunn_it = space.
*   log the apropriate messages
    WRITE i_mhnk_ext-madat TO h_char.
    IF i_mhnk_ext-smaber <> space.
      IF 0 = 1. MESSAGE s722. ENDIF.
      PERFORM log_msg USING '722' i_mhnk_ext-konto i_mhnk_ext-bukrs
                                  i_mhnk_ext-smaber h_char.
    ELSE.
      IF 0 = 1. MESSAGE s701. ENDIF.
      PERFORM log_msg USING '701' i_mhnk_ext-konto i_mhnk_ext-bukrs
                                  h_char space.
    ENDIF.
  ENDIF.
ENDFORM.                               " CHECK_DUNNING_PERIOD
*&---------------------------------------------------------------------*
*&      Form  CHECK_DUNNING_AMOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHNK_EXT  text                                           *
*      <--P_H_DUNN_IT  text                                            *
*----------------------------------------------------------------------*
FORM check_dunning_amount USING    i_t001     LIKE t001
                                   i_mhnk_ext LIKE mhnk_ext
                                   i_t047a    LIKE T047A       "1113414
                          CHANGING e_dunn_it  LIKE boole-boole
                                   e_mhnk_xmflg.               "1493804

* declaration
  DATA: h_char15(15) TYPE c.
  DATA: h_amount LIKE i_mhnk_ext-faebt.
* test previous checks
  CHECK e_dunn_it = 'X'.

* ommit check if account has only blocked items
  CHECK i_mhnk_ext-cblock < i_mhnk_ext-call.
  h_amount = i_mhnk_ext-faebt + i_mhnk_ext-gsfbt.
* check the dunning amounts
  e_dunn_it = 'X'.
  IF i_mhnk_ext-salhw <= 0 AND i_mhnk_ext-saldo <= 0
     AND i_t047a-xsalsh = ' '.                                 "1113414
    e_dunn_it = ' '.
*   log the apropriate messages
    WRITE i_mhnk_ext-salhw TO h_char15 CURRENCY t001-waers.
    IF 0 = 1. MESSAGE s702. ENDIF.
    PERFORM log_msg USING '702' i_mhnk_ext-konto i_mhnk_ext-konto
                                i_mhnk_ext-ukto  h_char15.

  ELSEIF i_mhnk_ext-faebt <= 0 AND h_amount <= 0.
    e_dunn_it = ' '.
*   log the apropriate messages
    WRITE h_amount TO h_char15 CURRENCY i_mhnk_ext-waers.
    IF 0 = 1. MESSAGE s703. ENDIF.
    PERFORM log_msg USING '703' i_mhnk_ext-konto i_mhnk_ext-konto
                                i_mhnk_ext-ukto  h_char15.
  ELSEIF i_mhnk_ext-faebt <= 0 AND h_amount > 0.               "1493804
    e_mhnk_xmflg = ' '.                                        "1493804
*   log the apropriate messages                                "1493804
    IF 0 = 1. MESSAGE s737. ENDIF.                             "1493804
    PERFORM log_msg USING '737' i_mhnk_ext-konto
                                i_mhnk_ext-faebt
                                i_mhnk_ext-gsfbt space.        "1493804
  ENDIF.
ENDFORM.                               " CHECK_DUNNING_AMOUNT
*&---------------------------------------------------------------------*
*&      Form  CHECK_MIN_AMOUNTS
*&---------------------------------------------------------------------*
*       Summarize the amounts for each dunning level and check the
*       field minbt in T047H. If the minbt is not reached, reduce the
*       dunning level by 1 and recheck. If the field SMAHSK is initial
*       simply reduce the dunning level of the items by 1. If the field
*       SMAHSK is NOT initial reduce the dunning level of the items and
*       SMAHSK by 1 and also check the MHNK entry and delete double
*       MHNK entries
*----------------------------------------------------------------------*
*      -->P_T_MHNK_EXT  text                                           *
*      -->P_T_MHND_EXT  text                                           *
*----------------------------------------------------------------------*
FORM check_min_amounts TABLES   t_t047h    STRUCTURE t047h
                                t_mhnk_ext STRUCTURE mhnk_ext
                                t_mhnd_ext structure mhnd_ext
                        using   i_check_in   like boole-boole.

  DATA:
   h_idx        LIKE sy-tabix,         h_mahsk      LIKE mhnk_ext-mahsk,
   h_minhw      LIKE lsumtab-faehw,    h_minfw      LIKE lsumtab-faefw,
   h_minhwp     LIKE lsumtab-faehw,    h_minfwp     LIKE lsumtab-faefw,
   h_mhnk_ext   LIKE mhnk_ext,         h_reduce_it  LIKE boole-boole,
   h_char15(15) TYPE c,
   t_sumtab     LIKE lsumtab OCCURS 10 WITH HEADER LINE,
* Table sums_per_branch is used to perform summation (collect statement)
* on table t_sumtab: Some values in mhnk_ext are needed per dunning
* branch, not per dunning level.

   sums_per_branch TYPE t_sums_per_branch OCCURS 5 WITH HEADER LINE,
   h_cpdky LIKE mhnk-cpdky, h_mgrup LIKE mhnk-mgrup.
  DATA: BEGIN OF LACCSUMTAB,                                    "984845
           KOART     LIKE MHND-KOART,                           "1276748
           BUKRS     LIKE MHND-BUKRS,
           KUNNR     LIKE MHND-KUNNR,                           "1276748
           LIFNR     LIKE MHND-LIFNR,
           CPDKY     LIKE MHND-CPDKY,
           SKNRZE    LIKE MHND-SKNRZE,
           SMABER    LIKE MHND-SMABER,                          "984845
           WAERS     LIKE MHND-WAERS,  "Waehrung                "984845
           SMAHSK    like mhnk_ext-smahsk, "Mahnstufe           "984845
           salhw     LIKE mhnk_ext-salhw, "Betrag in HW         "984845
           saldo     LIKE mhnk_ext-saldo, "Betrag in FW         "984845
        END OF LACCSUMTAB.                                      "984845
  Data: t_accsumtab1 like laccsumtab occurs 0 with header line, "984845
        t_accsumtab2 like laccsumtab occurs 0 with header line, "984845
        l_counter type I.                                       "984845

* Build summation table for all dunning levels
  PERFORM build_sum_table TABLES t_mhnk_ext t_mhnd_ext t_sumtab
                          USING  'MAHNS'.

* build sum of all open items                                   "984845
  IF i_check_in EQ space.                                       "984845
*   by collection of t_sumtab                                   "984845
    loop at t_sumtab.                                           "984845
      move-corresponding t_sumtab to t_accsumtab1.
      t_accsumtab1-smaber = t_sumtab-smaber.                    "984845
      t_accsumtab1-waers = t_sumtab-waers.                      "984845
      t_accsumtab1-salhw = t_sumtab-DMSHB.                      "984845
      t_accsumtab1-saldo = t_sumtab-WRSHB.                      "984845
      collect t_accsumtab1.                                     "984845
    endloop.                                                    "984845
  ELSE.            "i_check_in = 'X'.                           "984845
*   by collection of t_mhnk_ext                                 "984845
    loop at t_mhnk_ext.                                         "984845
      move-corresponding t_mhnk_ext to t_accsumtab1.            "984845
      append t_accsumtab1.                                      "984845
    endloop.                                                    "984845
  ENDIF.                                                        "984845

* Sort all the accounts decending by mahsk to assure proper handling
* in case of dunning per dunning level.
  SORT t_mhnk_ext BY smahsk DESCENDING.
* For filling the field mhnk-saldo we have to know, whether cpdkey
* is filled because it is a cpd-account or because of dunning groups.
*  It is dunning group if mgrup is filled .
  READ TABLE t_mhnk_ext INDEX 1 TRANSPORTING mgrup.
  h_mgrup = t_mhnk_ext-mgrup.

* Check all the accounts that are not in the legal dunning proc
  LOOP AT t_mhnk_ext WHERE legal_du = space.
    clear t_accsumtab2.                                         "984845
    refresh t_accsumtab2.                                       "984845
    h_idx       = sy-tabix.
    h_mahsk     = t_mhnk_ext-mahsk.
    h_reduce_it = 'X'.
    WHILE h_mahsk > 0 AND
          h_reduce_it = 'X' AND
          t_mhnk_ext-dunn_it = 'X'.
*     Get the amount for that dunning level from the sumtab
      CLEAR t_sumtab.
      READ TABLE t_sumtab WITH KEY laufd  = t_mhnk_ext-laufd
                                   laufi  = t_mhnk_ext-laufi
                                   koart  = t_mhnk_ext-koart
                                   bukrs  = t_mhnk_ext-bukrs
                                   kunnr  = t_mhnk_ext-kunnr
                                   lifnr  = t_mhnk_ext-lifnr
                                   cpdky  = t_mhnk_ext-cpdky
                                   sknrze = t_mhnk_ext-sknrze
                                   smaber = t_mhnk_ext-smaber
                                   smahsk = t_mhnk_ext-smahsk
                                   mahnn  = h_mahsk.
      IF sy-subrc <> 0.                                         "1517266
         move-corresponding t_mhnk_ext to t_sumtab.             "1517266
      ENDIF.                                                    "1517266
*     amount was found in sumtab
*     IF sy-subrc = 0.                                          "1517266
*       read balance of account per dunning area                "984845
        IF i_check_in EQ space.                                 "984845
          clear: l_counter.                                     "984845
          loop at t_accsumtab1 where smaber = t_mhnk_ext-smaber.
               l_counter = l_counter + 1.                       "984845
          endloop.                                              "984845
          IF l_counter > 1.        "entries with different curr."984845
            loop at t_accsumtab1 where smaber = t_mhnk_ext-smaber
                                   and koart  = t_mhnk_ext-koart
                                   and bukrs  = t_mhnk_ext-bukrs
                                   and kunnr  = t_mhnk_ext-kunnr
                                   and lifnr  = t_mhnk_ext-lifnr
                                   and cpdky  = t_mhnk_ext-cpdky
                                   and sknrze = t_mhnk_ext-sknrze.
              move-corresponding t_accsumtab1 to t_accsumtab2.  "1276748
              t_accsumtab2-smaber = t_accsumtab1-smaber.        "984845
              t_accsumtab2-waers  = t_mhnk_ext-hwaers.          "984845
              t_accsumtab2-salhw  = t_accsumtab1-salhw.         "984845
              t_accsumtab2-saldo  = t_accsumtab1-salhw.         "984845
              COLLECT t_accsumtab2.                             "984845
            endloop.                                            "984845
            read table t_accsumtab2 index 1.                    "984845
          ELSE.                                                 "984845
            t_accsumtab2 = t_accsumtab1.                        "984845
          ENDIF.                                                "984845
        ELSE.                                                   "984845
          loop at t_accsumtab1 where smaber = t_mhnk_ext-smaber
                                 and smahsk = t_mhnk_ext-smahsk "984845
                                 and koart  = t_mhnk_ext-koart
                                 and bukrs  = t_mhnk_ext-bukrs
                                 and kunnr  = t_mhnk_ext-kunnr
                                 and lifnr  = t_mhnk_ext-lifnr
                                 and cpdky  = t_mhnk_ext-cpdky
                                 and sknrze = t_mhnk_ext-sknrze.
          endloop.                                              "984845
          t_accsumtab2 = t_accsumtab1.                          "984845
          IF t_accsumtab2-saldo = 0.                            "984845
             t_accsumtab2-waers = t_mhnk_ext-hwaers.            "984845
             t_accsumtab2-saldo = t_accsumtab2-salhw.           "984845
          ENDIF.                                                "984845
        ENDIF.                                                  "984845

*       new variable for call to determine_min_amounts         "1133338
        data ld_min_check_waers like mhnk-waers.               "1133338
        if t_accsumtab2-waers = t_mhnk_ext-waers.              "1133338
          ld_min_check_waers = t_mhnk_ext-waers.               "1133338
        else.                                                  "1133338
*         we set it to space, so that cc-currency is used      "1133338
          ld_min_check_waers = space.                          "1133338
        endif.                                                 "1133338

*       determine the minimum amounts for that dunning level
        perform determine_min_amounts tables  t_t047h
*                                     using   t_mhnk_ext-salhw   "984845
*                                             t_mhnk_ext-saldo   "984845
                                      using   t_accsumtab2-salhw "984845
                                              t_accsumtab2-saldo "984845
                                              t_mhnk_ext-mahna h_mahsk
                                              t_mhnk_ext-hwaers
*                                             t_mhnk_ext-waers   "984845
*                                             t_accsumtab2-waers "1133338
                                              ld_min_check_waers "1133338
                                      CHANGING h_minhw h_minfw
                                               h_minhwp h_minfwp.

*       check if amount is less than min amount the reduce levels
        PERFORM check_du_level_amount USING    t_mhnk_ext t_sumtab
                                               h_minhw h_minfw
                                               h_minhwp h_minfwp
                                      CHANGING h_reduce_it.

*       if account dunnnig level cannot be reduced any further
        IF h_reduce_it = 'X' AND t_mhnk_ext-mahsk <= 1.
          IF t_mhnk_ext-cblock = 0.
            t_mhnk_ext-dunn_it = space.
          ENDIF.
          t_mhnk_ext-xmflg = space.
          t_mhnk_ext-min_it = 'X'.
          CLEAR t_mhnk_ext-min_msg.
          IF 0 = 1. MESSAGE s826. ENDIF.
          t_mhnk_ext-min_msg-msgno = '826'.
          t_mhnk_ext-min_msg-msgv1 = t_mhnk_ext-konto.
          MODIFY t_mhnk_ext INDEX h_idx.
          h_mahsk = 0.
        ENDIF.

*       reduce dunning level mahnn by 1 and smahsk
        IF h_reduce_it = 'X' AND t_mhnk_ext-mahsk > 1.
          LOOP AT t_mhnd_ext WHERE laufd  = t_mhnk_ext-laufd AND
                                   laufi  = t_mhnk_ext-laufi AND
                                   koart  = t_mhnk_ext-koart AND
                                   bukrs  = t_mhnk_ext-bukrs AND
                                   kunnr  = t_mhnk_ext-kunnr AND
                                   lifnr  = t_mhnk_ext-lifnr AND
                                   cpdky  = t_mhnk_ext-cpdky AND
                                   sknrze = t_mhnk_ext-sknrze AND
                                   smaber = t_mhnk_ext-smaber AND
                                   smahsk = t_mhnk_ext-smahsk AND
                                   mahnn  = h_mahsk.
*           in case due date has been changed to the future, item not
*           due and item has already been dunned:
            IF t_mhnd_ext-mahnn = t_mhnd_ext-mahns AND
                 t_mhnd_ext-xfael = space.
              CONTINUE.
            ENDIF.
*           in case dunning block was inserted, item not to be dunned:
*            if t_mhnd_ext-mansp NE space.                 "1005739 1092805
*             continue.                                    "1005739 1092805
*           endif.                                         "1005739 1092805

            t_mhnd_ext-mahnn = t_mhnd_ext-mahnn - 1.
*           dunning per dunning level reduce key in MHND
            IF t_mhnd_ext-smahsk <> space.
              t_mhnd_ext-smahsk = t_mhnd_ext-smahsk - 1.
            ENDIF.
            MODIFY t_mhnd_ext INDEX sy-tabix.
*           log the new dunning level
            IF 0 = 1. MESSAGE s832. ENDIF.
            PERFORM log_msg USING '832' t_mhnd_ext-blinf
                                        t_mhnd_ext-mahnn space space.
          ENDLOOP.
*         dunning per dunning level reduce key in mhnk and add saldo
          IF t_mhnk_ext-smahsk <> space.
            t_mhnk_ext-smahsk = t_mhnk_ext-smahsk - 1.
            t_mhnk_ext-mahsk  = t_mhnk_ext-mahsk  - 1.

*           log the new dunning for dunning/dunning level.
            IF 0 = 1. MESSAGE s827. ENDIF.
            PERFORM log_msg USING '827' t_mhnk_ext-konto
                                        t_mhnk_ext-smahsk
                                        space space.

*           test if mhnk entry is there otherwise create
            READ TABLE t_mhnk_ext INTO h_mhnk_ext
                                  WITH KEY  laufd  = t_mhnk_ext-laufd
                                            laufi  = t_mhnk_ext-laufi
                                            koart  = t_mhnk_ext-koart
                                            bukrs  = t_mhnk_ext-bukrs
                                            kunnr  = t_mhnk_ext-kunnr
                                            lifnr  = t_mhnk_ext-lifnr
                                            cpdky  = t_mhnk_ext-cpdky
                                            sknrze = t_mhnk_ext-sknrze
                                            smaber = t_mhnk_ext-smaber
                                            smahsk = t_mhnk_ext-smahsk.
            IF sy-subrc <> 0.
*             append actual mhnk entry
              MODIFY t_mhnk_ext INDEX h_idx.
            ELSE.
*             modify sy-tabix entry determined by read and delete
*             previous found entry because it is not longer used
*             due to the fact that the min amount is not sufficient
              if i_check_in = space.
                t_mhnk_ext-saldo  = t_mhnk_ext-saldo + t_sumtab-wrshb.
                t_mhnk_ext-salhw  = t_mhnk_ext-salhw + t_sumtab-dmshb.
              endif.
              t_mhnk_ext-caend  = t_mhnk_ext-caend + h_mhnk_ext-caend.
              t_mhnk_ext-cblock = t_mhnk_ext-cblock + h_mhnk_ext-cblock.
              t_mhnk_ext-call   = t_mhnk_ext-call + h_mhnk_ext-call.
*             save biggest account delay:
              if h_mhnk_ext-kverz > t_mhnk_ext-kverz.
                t_mhnk_ext-kverz = h_mhnk_ext-kverz.
              endif.
              MODIFY t_mhnk_ext INDEX sy-tabix.
              DELETE t_mhnk_ext INDEX h_idx.
              h_idx = sy-tabix - 1.    "<-- HW 129874
            ENDIF.
          ELSE.
            t_mhnk_ext-mahsk  = t_mhnk_ext-mahsk  - 1.
            MODIFY t_mhnk_ext.
          ENDIF.

*         add the amount in that dunning level to the previous one
          t_sumtab-mahnn = t_sumtab-mahnn - 1.
*         dunning per dunning level
          IF t_mhnk_ext-smahsk <> space.
            t_sumtab-smahsk = t_sumtab-smahsk - 1.
          ENDIF.
          COLLECT t_sumtab.
          h_mahsk = h_mahsk - 1.
        ENDIF.
*     ENDIF.                                                    "1517266
    ENDWHILE.
*   dunning level for that account is 0 > no dunning will be created
*   unless the dunning has blocked items in that case create the
*   dunning data anyways.
    IF i_check_in = space.   "do not call for edited dunning    "1583259
    IF h_mahsk = 0 AND t_mhnk_ext-cblock = 0.
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
        MOVE-CORRESPONDING t_mhnd_ext TO deleted_per_branch.
        IF h_mgrup <> space.
          deleted_per_branch-cpdky = space.
        ENDIF.
        COLLECT deleted_per_branch.
      ENDLOOP.
*     delete the account and all its items from mhnk and mhnd
      DELETE t_mhnd_ext WHERE laufd  = t_mhnk_ext-laufd AND
                              laufi  = t_mhnk_ext-laufi AND
                              koart  = t_mhnk_ext-koart AND
                              bukrs  = t_mhnk_ext-bukrs AND
                              kunnr  = t_mhnk_ext-kunnr AND
                              lifnr  = t_mhnk_ext-lifnr AND
                              cpdky  = t_mhnk_ext-cpdky AND
                              sknrze = t_mhnk_ext-sknrze AND
                              smaber = t_mhnk_ext-smaber AND
                              smahsk = t_mhnk_ext-smahsk.
      DELETE t_mhnk_ext INDEX h_idx.

*   dunning level is 0 but there are blocked items in that case
*   create the dunning data anyways but delete all the item with
*   no dunn block reason and xfael = space (not due)
    ELSEIF h_mahsk = 0 AND t_mhnk_ext-cblock > 0.
      clear t_mhnk_ext-xmflg.                                   "1104224
      MODIFY t_mhnk_ext INDEX h_idx.
      LOOP AT t_mhnd_ext WHERE laufd  = t_mhnk_ext-laufd AND
                            laufi  = t_mhnk_ext-laufi AND
                            koart  = t_mhnk_ext-koart AND
                            bukrs  = t_mhnk_ext-bukrs AND
                            kunnr  = t_mhnk_ext-kunnr AND
                            lifnr  = t_mhnk_ext-lifnr AND
                            cpdky  = t_mhnk_ext-cpdky AND
                            sknrze = t_mhnk_ext-sknrze AND
                            smaber = t_mhnk_ext-smaber AND
                            smahsk = t_mhnk_ext-smahsk AND
                            mansp  = space AND
                            xfael  = space.
        MOVE-CORRESPONDING t_mhnd_ext TO deleted_per_branch.
        IF h_mgrup <> space.
          deleted_per_branch-cpdky = space.
        ENDIF.
        COLLECT deleted_per_branch.
      ENDLOOP.
      DELETE t_mhnd_ext WHERE laufd  = t_mhnk_ext-laufd AND
                              laufi  = t_mhnk_ext-laufi AND
                              koart  = t_mhnk_ext-koart AND
                              bukrs  = t_mhnk_ext-bukrs AND
                              kunnr  = t_mhnk_ext-kunnr AND
                              lifnr  = t_mhnk_ext-lifnr AND
                              cpdky  = t_mhnk_ext-cpdky AND
                              sknrze = t_mhnk_ext-sknrze AND
                              smaber = t_mhnk_ext-smaber AND
                              smahsk = t_mhnk_ext-smahsk AND
                              mansp  = space AND
                              xfael  = space.
*   a dunning could be created but all dunning items are blocked
    ELSEIF h_mahsk > 0 AND t_mhnk_ext-cblock = t_mhnk_ext-call.
*   a dunning could be created
    ELSEIF h_mahsk > 0 AND h_reduce_it = space.
    ENDIF.
    ELSE.                                                       "1583259
      IF h_mahsk = 0.                                           "1583259
        clear t_mhnk_ext-xmflg.                                 "1583259
        MODIFY t_mhnk_ext INDEX h_idx.                          "1583259
      ENDIF.                                                    "1583259
    ENDIF.                      "FI i_check_in = space.         "1583259
  ENDLOOP.

  LOOP AT t_mhnk_ext.
    IF t_mhnk_ext-waers <> t_mhnk_ext-hwaers.
      DATA mhnk_index LIKE sy-tabix.
      mhnk_index = sy-tabix.
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
        IF t_mhnd_ext-waers <> t_mhnk_ext-waers.
          t_mhnk_ext-waers = t_mhnk_ext-hwaers.
          MODIFY t_mhnk_ext INDEX mhnk_index.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

* build summation table for account
  PERFORM build_sum_table TABLES t_mhnk_ext t_mhnd_ext t_sumtab
                          USING  'ACCOUNT'.

  REFRESH sums_per_branch[].
  LOOP AT t_sumtab.
    MOVE-CORRESPONDING t_sumtab TO sums_per_branch.
    IF h_mgrup <> space.
      sums_per_branch-cpdky = space.
    ENDIF.

    COLLECT sums_per_branch.
  ENDLOOP.
* assign the amounts to the account header
  LOOP AT t_mhnk_ext .
    h_idx = sy-tabix.
    READ TABLE t_sumtab WITH KEY laufd  = t_mhnk_ext-laufd
                                 laufi  = t_mhnk_ext-laufi
                                 koart  = t_mhnk_ext-koart
                                 bukrs  = t_mhnk_ext-bukrs
                                 kunnr  = t_mhnk_ext-kunnr
                                 lifnr  = t_mhnk_ext-lifnr
                                 cpdky  = t_mhnk_ext-cpdky
                                 sknrze = t_mhnk_ext-sknrze
                                 smaber = t_mhnk_ext-smaber
                                 smahsk = t_mhnk_ext-smahsk.
    IF sy-subrc = 0.
      t_mhnk_ext-gsfbt  = t_sumtab-gsffw.
      t_mhnk_ext-gsnbt  = t_sumtab-gsnfw.
      t_mhnk_ext-faebt  = t_sumtab-faefw.
      t_mhnk_ext-faehw  = t_sumtab-faehw.
* either read with cpdky or without, depending on dunning group:
* If field mgrup is filled, there are different mhnk records because of
* dunning groups. In this case the contents of cpdky is due to the
* dunning group, it is not a cpd-account.
      IF h_mgrup <> space.
        h_cpdky = space.
      ELSE.
        h_cpdky = t_mhnk_ext-cpdky.
      ENDIF.

*      READ TABLE sums_per_branch WITH KEY koart  = t_mhnk_ext-koart
*                              bukrs  = t_mhnk_ext-bukrs
*                              kunnr  = t_mhnk_ext-kunnr
*                              lifnr  = t_mhnk_ext-lifnr
*                              cpdky  = h_cpdky
*                              smaber = t_mhnk_ext-smaber.
      DATA sumhw(8) TYPE p.
      DATA famsh(8) TYPE p.
      DATA sum_del_hw(8) TYPE p.
      DATA multiple_entries(1).
      DATA multiple_entries_del(1).
      sumhw = 0. multiple_entries = space.
      sum_del_hw = 0. multiple_entries_del = space.
      LOOP AT sums_per_branch WHERE koart  = t_mhnk_ext-koart     AND
                                        bukrs  = t_mhnk_ext-bukrs AND
                                        kunnr  = t_mhnk_ext-kunnr AND
                                        lifnr  = t_mhnk_ext-lifnr AND
                                        cpdky  = h_cpdky          AND
                                        smaber = t_mhnk_ext-smaber.

        IF sumhw <> 0.
          multiple_entries = 'X'.
        ENDIF.
        sumhw = sumhw + sums_per_branch-dmshb.
        famsh = famsh + sums_per_branch-famsh.
      ENDLOOP.

      CLEAR deleted_per_branch.
     LOOP AT deleted_per_branch WHERE koart  = t_mhnk_ext-koart     AND
                                        bukrs  = t_mhnk_ext-bukrs AND
                                        kunnr  = t_mhnk_ext-kunnr AND
                                        lifnr  = t_mhnk_ext-lifnr AND
                                        cpdky  = h_cpdky          AND
                                        smaber = t_mhnk_ext-smaber.
        IF sum_del_hw <> 0.
          multiple_entries_del = 'X'.
        ENDIF.
        sum_del_hw = sum_del_hw + deleted_per_branch-dmshb.
      ENDLOOP.
      IF multiple_entries = 'X'.
        if i_check_in = space.
          t_mhnk_ext-saldo  = 0.
          t_mhnk_ext-salhw  = sumhw + sum_del_hw.
        endif.
        t_mhnk_ext-famsh  = famsh.
        t_mhnk_ext-famsm  = 0.
      else.
        if i_check_in = space.
          t_mhnk_ext-salhw  = sums_per_branch-dmshb + sum_del_hw.
        endif.
        t_mhnk_ext-famsh  = sums_per_branch-famsh.
        t_mhnk_ext-famsm  = sums_per_branch-famsm.
        IF multiple_entries_del = 'X' OR
             ( sums_per_branch-waers <> deleted_per_branch-waers AND
                 deleted_per_branch-waers <> space ).
          if i_check_in = space.
            t_mhnk_ext-saldo  = 0.
          endif.
          t_mhnk_ext-famsm  = 0.
        else.
          if i_check_in = space.
            t_mhnk_ext-saldo = sums_per_branch-wrshb +
                  deleted_per_branch-wrshb.
          endif.
        ENDIF.
      ENDIF.
      MODIFY t_mhnk_ext INDEX h_idx.
    ENDIF.
  ENDLOOP.

ENDFORM.                               " CHECK_MIN_AMOUNTS
*&---------------------------------------------------------------------*
*&      Form  CHECK_ACCOUNT_DELAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_T047A  text                                              *
*      -->P_T_MHNK_EXT-KVERZ  text                                     *
*      <--P_H_DUNN_IT  text                                            *
*----------------------------------------------------------------------*
FORM check_account_delay USING    i_t047a    LIKE t047a
                         CHANGING     i_mhnk_ext LIKE mhnk_ext
                                     e_dunn_it  LIKE boole-boole.
* declaration
  DATA: h_char(4) TYPE c.

* test previous checks
  CHECK e_dunn_it = 'X'.

* check the account delay
  e_dunn_it = 'X'.
  IF i_mhnk_ext-kverz < i_t047a-mivrz
  OR i_mhnk_ext-kverz = 0.
    IF ( delay_with_blocked_items < i_t047a-mivrz
    OR delay_with_blocked_items = 0 ) and i_mhnk_ext-cpdky = space.
      WRITE i_mhnk_ext-kverz TO h_char.
      IF 0 = 1. MESSAGE s718. ENDIF.
      PERFORM log_msg USING '718' i_mhnk_ext-konto i_mhnk_ext-smaber
                                h_char i_t047a-mivrz.
      e_dunn_it = space.
    ELSE.
      i_mhnk_ext-xmflg = space.
    ENDIF.

  ENDIF.

ENDFORM.                               " CHECK_ACCOUNT_DELAY
*&---------------------------------------------------------------------*
*&      Form  CHECK_CREDIT_MEMO
*&---------------------------------------------------------------------*
*       check if the actual item is a non invoice related credit memo
*----------------------------------------------------------------------*
*      -->I_MHND_EXT    actual mhnd entry                              *
*      <--E_CMEMO       flag  'X' = non invoice related credit memo    *
*                             ' ' = all other items                    *
*----------------------------------------------------------------------*
FORM check_credit_memo TABLES t_mhnd_ext STRUCTURE mhnd_ext
                       USING    i_mhnd_ext LIKE mhnd_ext
                       CHANGING e_cmemo    LIKE mhnd_ext-cmemo.

  DATA h_mhnd_ext LIKE mhnd_ext.

  IF ( i_mhnd_ext-bkoart = 'D' AND i_mhnd_ext-shkzg = 'S' ) OR
     ( i_mhnd_ext-bkoart = 'D' AND i_mhnd_ext-shkzg = 'H' and
       i_mhnd_ext-rebzg = 'V' ) or
* kreditorische valutierte Gutschrift
     ( i_mhnd_ext-bkoart = 'K' AND i_mhnd_ext-shkzg = 'S'
        and i_mhnd_ext-rebzg = 'V' ) or
* kreditorische Rechnung
     ( i_mhnd_ext-bkoart = 'K' AND i_mhnd_ext-shkzg = 'H' ).
    e_cmemo = space.
  ELSE.
    e_cmemo = 'X'.
  ENDIF.
ENDFORM.                               " CHECK_CREDIT_MEMO
*&---------------------------------------------------------------------*
*&      Form  CREATE_ADDRESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_VFM_KNXX  text                                             *
*      -->P_VFM_LFXX  text                                             *
*      <--P_T_MHND_EXT  text                                           *
*----------------------------------------------------------------------*
FORM create_address USING    i_vfm_knxx LIKE vfm_knxx
                             i_vfm_lfxx LIKE vfm_lfxx
                    CHANGING e_mhnd_ext LIKE mhnd_ext.
  IF e_mhnd_ext-koart = 'D'.
    e_mhnd_ext-pstlz = i_vfm_knxx-pstlz.
    e_mhnd_ext-ort01 = i_vfm_knxx-ort01.
    e_mhnd_ext-stras = i_vfm_knxx-stras.
    e_mhnd_ext-pfach = i_vfm_knxx-pfach.
    e_mhnd_ext-land1 = i_vfm_knxx-land1.
    IF i_vfm_knxx-pstl2 NE space.
      e_mhnd_ext-pstlz = i_vfm_knxx-pstl2. "Priorität
    ENDIF.
  ELSE.
    e_mhnd_ext-pstlz = i_vfm_lfxx-pstlz.
    e_mhnd_ext-ort01 = i_vfm_lfxx-ort01.
    e_mhnd_ext-stras = i_vfm_lfxx-stras.
    e_mhnd_ext-pfach = i_vfm_lfxx-pfach.
    e_mhnd_ext-land1 = i_vfm_lfxx-land1.
    IF i_vfm_lfxx-pstl2 NE space.
      e_mhnd_ext-pstlz = i_vfm_lfxx-pstl2. "Priorität
    ENDIF.
  ENDIF.
ENDFORM.                               " CREATE_ADDRESS


*---------------------------------------------------------------------*
*       FORM create_mhnk                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  T_MHNK_EXT                                                    *
*  -->  T_MHNK_IN                                                     *
*  -->  I_T001                                                        *
*  -->  I_T047                                                        *
*  -->  I_T047A                                                       *
*  -->  I_VFM_KNXX                                                    *
*  -->  I_VFM_LFXX                                                    *
*  -->  I_KNB5                                                        *
*  -->  I_LFB5                                                        *
*  -->  I_AUSDT                                                       *
*  -->  I_GRDAT                                                       *
*  -->  I_CPDKY_CPD                                                   *
*  -->  I_CPDKY_GRP                                                   *
*  -->  I_CHECK_IN                                                    *
*  -->  E_MHND_EXT                                                    *
*---------------------------------------------------------------------*
FORM create_mhnk TABLES   t_mhnk_ext  STRUCTURE mhnk_ext
                          t_mhnk_in   STRUCTURE mhnk
                          t_knb5      STRUCTURE knb5           "1498587
                          t_lfb5      STRUCTURE lfb5           "1498587
                 USING    i_t001      LIKE t001
                          i_t047      LIKE t047
                          i_t047a     LIKE t047a
                          i_vfm_knxx  LIKE vfm_knxx
                          i_vfm_lfxx  LIKE vfm_lfxx
*                         i_knb5      LIKE knb5                "1498587
*                         i_lfb5      LIKE lfb5                "1498587
                          i_ausdt     LIKE f150v-ausdt
                          i_grdat     LIKE f150v-grdat
                          i_cpdky_cpd LIKE mhnk-cpdky
                          i_cpdky_grp LIKE mhnk-cpdky
                          i_check_in LIKE boole-boole
                 CHANGING e_mhnd_ext LIKE mhnd_ext.
  DATA: h_idx  LIKE sy-tabix.

* try to locate entry
  READ TABLE t_mhnk_ext WITH KEY laufd  = e_mhnd_ext-laufd
                                 laufi  = e_mhnd_ext-laufi
                                 koart  = e_mhnd_ext-koart
                                 bukrs  = e_mhnd_ext-bukrs
                                 kunnr  = e_mhnd_ext-kunnr
                                 lifnr  = e_mhnd_ext-lifnr
                                 cpdky  = e_mhnd_ext-cpdky
                                 sknrze = e_mhnd_ext-sknrze
                                 smaber = e_mhnd_ext-smaber
                                 smahsk = e_mhnd_ext-smahsk.
  IF sy-subrc <> 0.
*   no entry found assign, the fields
    CLEAR t_mhnk_ext.
*   assign key fields
    t_mhnk_ext-laufd  = e_mhnd_ext-laufd.
    t_mhnk_ext-laufi  = e_mhnd_ext-laufi.
    t_mhnk_ext-koart  = e_mhnd_ext-koart.
    t_mhnk_ext-bukrs  = e_mhnd_ext-bukrs.
    t_mhnk_ext-kunnr  = e_mhnd_ext-kunnr.
    t_mhnk_ext-lifnr  = e_mhnd_ext-lifnr.
    t_mhnk_ext-cpdky  = e_mhnd_ext-cpdky.
    t_mhnk_ext-sknrze = e_mhnd_ext-sknrze.
    t_mhnk_ext-smaber = e_mhnd_ext-smaber.
    t_mhnk_ext-smahsk = e_mhnd_ext-smahsk.
*   restore information from previous determined mhnk items
    IF i_check_in = 'X'.
      PERFORM restore_mhnk_ext TABLES t_mhnk_in CHANGING t_mhnk_ext.
    ENDIF.

*   assign the mgrup-id
    t_mhnk_ext-mgrup  = e_mhnd_ext-mgrup.
    IF i_check_in = space.
*   assign cpdky
      t_mhnk_ext-cpdky_cpd = i_cpdky_cpd.
      t_mhnk_ext-cpdky_grp = i_cpdky_grp.
    ENDIF.
*   assign the account specifier
    IF i_t047-xmabe = 'X'.
      IF t_mhnk_ext-smaber = space.
        t_mhnk_ext-ukto = text-100.
      ELSE.
        t_mhnk_ext-ukto = t_mhnk_ext-smaber.
      ENDIF.
    ENDIF.
*   get knb5/lfb5 data
    IF t_mhnk_ext-koart = 'D'.
      t_mhnk_ext-konto  = 'D'.
      t_mhnk_ext-konto+2  = t_mhnk_ext-kunnr.

*     first guess: try to find mahna for the dunning area      "1498587
      READ TABLE t_knb5 WITH KEY bukrs = t_mhnk_ext-bukrs      "1498587
                                 kunnr = t_mhnk_ext-kunnr      "1498587
                                 maber = e_mhnd_ext-maber.     "1498587
*     second gues reread default mahna                         "1498587
      IF sy-subrc <> 0.                                        "1498587
        READ TABLE t_knb5 WITH KEY bukrs = t_mhnk_ext-bukrs    "1498587
                                   kunnr = t_mhnk_ext-kunnr    "1498587
                                   maber = space.              "1498587
        CLEAR t_knb5-madat.                                    "1593824
        CLEAR t_knb5-mahns.                                    "1593824
      ENDIF.                                                   "1498587

      IF i_check_in = space.
        t_mhnk_ext-knrma  = t_knb5-knrma.                      "1498587
        t_mhnk_ext-gmvdt  = t_knb5-gmvdt.                      "1498587
        t_mhnk_ext-mansp  = t_knb5-mansp.                      "1498587
        t_mhnk_ext-madat  = t_knb5-madat.                      "1498587
        t_mhnk_ext-prndt_before = t_knb5-madat.                "1498587
        t_mhnk_ext-busab  = t_knb5-busab.                      "1498587
        IF t_mhnk_ext-busab = space.
          IF i_vfm_knxx-busab NE space.
            t_mhnk_ext-busab = i_vfm_knxx-busab.
          ELSE.
            t_mhnk_ext-busab = i_vfm_knxx-busab_knb1.
          ENDIF.
        ENDIF.
*     determine interest id
        IF i_vfm_knxx-vzskz NE space.
          t_mhnk_ext-vzskz = i_vfm_knxx-vzskz.
        ELSE.
          t_mhnk_ext-vzskz = i_t047a-vzskz.
        ENDIF.
      ENDIF.
    ELSE.
      t_mhnk_ext-konto  = 'K'.
      t_mhnk_ext-konto+2 = t_mhnk_ext-lifnr.

*     first guess: try to find mahna for the dunning area      "1498587
      READ TABLE t_lfb5 WITH KEY bukrs = t_mhnk_ext-bukrs      "1498587
                                 lifnr = t_mhnk_ext-lifnr      "1498587
                                 maber = e_mhnd_ext-maber.     "1498587
*     second gues reread default mahna                         "1498587
      IF sy-subrc <> 0.                                        "1498587
        READ TABLE t_lfb5 WITH KEY bukrs = t_mhnk_ext-bukrs    "1498587
                                   lifnr = t_mhnk_ext-lifnr    "1498587
                                   maber = space.              "1498587
        CLEAR t_lfb5-madat.                                    "1593824
        CLEAR t_lfb5-mahns.                                    "1593824
      ENDIF.                                                   "1498587

      IF i_check_in = space.
        t_mhnk_ext-knrma  = t_lfb5-lfrma.                      "1498587
        t_mhnk_ext-gmvdt  = t_lfb5-gmvdt.                      "1498587
        t_mhnk_ext-mansp  = t_lfb5-mansp.                      "1498587
        t_mhnk_ext-madat  = t_lfb5-madat.                      "1498587
        t_mhnk_ext-prndt_before = t_lfb5-madat.                "1498587
        t_mhnk_ext-busab  = t_lfb5-busab.                      "1498587
        IF t_mhnk_ext-busab = space.
          IF i_vfm_lfxx-busab NE space.
            t_mhnk_ext-busab = i_vfm_lfxx-busab.
          ELSE.
            t_mhnk_ext-busab = i_vfm_lfxx-busab_lfb1.
          ENDIF.
        ENDIF.
*     determine interest id
        IF i_vfm_lfxx-vzskz NE space.
          t_mhnk_ext-vzskz = i_vfm_lfxx-vzskz.
        ELSE.
          t_mhnk_ext-vzskz = i_t047a-vzskz.
        ENDIF.
      ENDIF.
    ENDIF.
*   set gmvdt obtained from t_mhnd_ext in iccd for cc
    IF NOT e_mhnd_ext-gmvdt IS INITIAL.
      t_mhnk_ext-gmvdt = e_mhnd_ext-gmvdt.
    ENDIF.
    t_mhnk_ext-mahna = i_t047a-mahna.
*   asign data fields
    t_mhnk_ext-ausdt  = i_ausdt.   t_mhnk_ext-grdat  = i_grdat.
    t_mhnk_ext-rhyth  = i_t047a-rhyth.
*    e_mhnd_ext-rhyth  = i_t047a-rhyth.
    e_mhnd_ext-konto  = t_mhnk_ext-konto.
*   assign dunning level and account delay for normal items
    IF e_mhnd_ext-cmemo = space.
      IF t_mhnk_ext-gmvdt IS INITIAL.
        t_mhnk_ext-mahsk  = e_mhnd_ext-mahnn.
      ELSE.
        t_mhnk_ext-mahsk  = e_mhnd_ext-mahns.
      ENDIF.
*     IF e_mhnd_ext-shkzg  = 'S'.                               "954873
*     IF ( e_mhnd_ext-shkzg  = 'S' AND e_mhnd_ext-koart = 'D' ) "959237
*     OR ( e_mhnd_ext-shkzg  = 'H' AND e_mhnd_ext-koart = 'K' )."959237
        IF e_mhnd_ext-mansp = space.
          t_mhnk_ext-kverz  = e_mhnd_ext-verzn.
        ELSE.
          delay_with_blocked_items = e_mhnd_ext-verzn.
        ENDIF.
*     ENDIF.                                                    "959237
    ELSE.
      t_mhnk_ext-mahsk  = 0.
    ENDIF.
*   determine address
    t_mhnk_ext-pstlz = e_mhnd_ext-pstlz.
    t_mhnk_ext-ort01 = e_mhnd_ext-ort01.
    t_mhnk_ext-stras = e_mhnd_ext-stras.
    t_mhnk_ext-pfach = e_mhnd_ext-pfach.
    t_mhnk_ext-land1 = e_mhnd_ext-land1.
*   determine account sum for later checking
    if i_check_in = space.
      t_mhnk_ext-saldo  = e_mhnd_ext-wrshb.
      t_mhnk_ext-salhw  = e_mhnd_ext-dmshb.
*    assign the currency key
      t_mhnk_ext-waers  = e_mhnd_ext-waers.
    endif.
*   assign the date of the last account change
    t_mhnk_ext-dtlbw  = e_mhnd_ext-budat.
    IF t_mhnk_ext-dtlbw < e_mhnd_ext-cpudt.
      t_mhnk_ext-dtlbw  = e_mhnd_ext-cpudt.
    ENDIF.
*   assign the company currency
    t_mhnk_ext-hwaers = i_t001-waers.
*   assume that account must be dunned
    t_mhnk_ext-dunn_it = 'X'.
    t_mhnk_ext-xmflg   = 'X'.

*   determine the dunning level for the summation status
    t_mhnk_ext-sum_lev = i_t047a-mahns.
*   set counter for changed items
    IF e_mhnd_ext-mahnn <> e_mhnd_ext-mahns.
      t_mhnk_ext-caend = 1.
    ENDIF.
*   check for blocked items and add counter
    IF e_mhnd_ext-mansp <> space.
      t_mhnk_ext-cblock = 1.
    ENDIF.
    t_mhnk_ext-call = 1.
*   assign vertt from MHND assuming that all MHND entrys have the same
*   type in vertt.
    t_mhnk_ext-vertt = e_mhnd_ext-vertt.
*   assign vertn from MHND assuning that all MHND entrys have the same
*   number in vertn. Vertn remains empty until further notice. Appli-
*   cations are responsibel for information stred in that field
*   t_mhnk_ext-vertn = e_mhnd_ext-vertn.
    IF i_check_in = space.
*   assign standard applk for all FI entrys
      t_mhnk_ext-applk = c_applk.
*   determine applk for mhnk entry
      PERFORM ofi_dun_mhnk_applk USING t_mhnk_ext
                                 CHANGING t_mhnk_ext-applk.
      IF t_mhnk_ext-applk = space.
        t_mhnk_ext-applk = c_applk.
      ENDIF.
    ENDIF.
*   append the new mhnk entry
    APPEND t_mhnk_ext.
  ELSE.
*   entry found collect the sums
    h_idx = sy-tabix.

*   assign mgrup if not already used
    IF t_mhnk_ext-mgrup = space.
      t_mhnk_ext-mgrup  = e_mhnd_ext-mgrup.
    ENDIF.

*   set counter for changed items
    IF e_mhnd_ext-mahnn <> e_mhnd_ext-mahns.
      t_mhnk_ext-caend = t_mhnk_ext-caend + 1.
    ENDIF.

*   determine the max dunning level for normal items
    IF t_mhnk_ext-gmvdt IS INITIAL.
      IF e_mhnd_ext-mahnn > t_mhnk_ext-mahsk
        AND e_mhnd_ext-cmemo = space
           AND e_mhnd_ext-xfael = 'X'.
        t_mhnk_ext-mahsk = e_mhnd_ext-mahnn.
      ENDIF.
    ELSE.
      IF e_mhnd_ext-mahns > t_mhnk_ext-mahsk
        AND e_mhnd_ext-cmemo = space
          AND e_mhnd_ext-xfael = 'X'.
        t_mhnk_ext-mahsk = e_mhnd_ext-mahns.
      ENDIF.
    ENDIF.

*   determine the max account delay for normal items
    IF e_mhnd_ext-mansp = space.
      IF e_mhnd_ext-verzn > t_mhnk_ext-kverz AND
         e_mhnd_ext-cmemo = space.   "AND e_mhnd_ext-shkzg = 'S'. 959237
        t_mhnk_ext-kverz = e_mhnd_ext-verzn.
      ENDIF.
    ELSE.
      IF e_mhnd_ext-verzn > delay_with_blocked_items AND
        e_mhnd_ext-cmemo = space.    "AND e_mhnd_ext-shkzg = 'S'. 959237
        delay_with_blocked_items = e_mhnd_ext-verzn.
      ENDIF.
    ENDIF.

*   determine account sum for later checking
    if i_check_in = space.
      t_mhnk_ext-saldo  = t_mhnk_ext-saldo + e_mhnd_ext-wrshb.
    t_mhnk_ext-salhw  = t_mhnk_ext-salhw + e_mhnd_ext-dmshb.

*   check and reassign the currency key if accout has multiple currencys
    IF t_mhnk_ext-waers <> e_mhnd_ext-waers.
      t_mhnk_ext-waers  = i_t001-waers.
      t_mhnk_ext-saldo  = t_mhnk_ext-salhw.
      endif.
    endif.

*   assign the date of the last account change
    IF t_mhnk_ext-dtlbw < e_mhnd_ext-budat.
      t_mhnk_ext-dtlbw  = e_mhnd_ext-budat.
    ENDIF.
    IF t_mhnk_ext-dtlbw < e_mhnd_ext-cpudt.
      t_mhnk_ext-dtlbw  = e_mhnd_ext-cpudt.
    ENDIF.
*   check for blocked items and add counter
    IF e_mhnd_ext-mansp <> space.
      t_mhnk_ext-cblock = t_mhnk_ext-cblock + 1.
    ENDIF.
*   set dunning period in item (performance
*    e_mhnd_ext-rhyth  = i_t047a-rhyth.
    e_mhnd_ext-konto  = t_mhnk_ext-konto.

    t_mhnk_ext-call = t_mhnk_ext-call + 1.
*   modify the internal table
    MODIFY t_mhnk_ext INDEX h_idx.
  ENDIF.
ENDFORM.                               " CREATE_MHNK
*&---------------------------------------------------------------------*
*&      Form  CHECK_DUNNING_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MHNK_EXT  text                                           *
*      <--P_H_DUNN_IT  text                                            *
*----------------------------------------------------------------------*
FORM check_dunning_item USING    i_mhnd_ext LIKE mhnd_ext
                        CHANGING e_dunn_it  LIKE boole-boole.
  e_dunn_it = 'X'.
  IF i_mhnd_ext-xzalb =  'X' OR
     i_mhnd_ext-xfael <> 'X' OR
     i_mhnd_ext-mansp <> space.
    e_dunn_it = space.
  ENDIF.
ENDFORM.                               " CHECK_DUNNING_ITEM
*&---------------------------------------------------------------------*
*&      Form  CHECK_DU_LEVEL_AMOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_H_MAHSK  text                                              *
*      -->P_T_SUMTAB  text                                             *
*      -->P_H_MINHW  text                                              *
*      -->P_H_MINFW  text                                              *
*      -->P_H_MINHWP  text                                             *
*      -->P_H_MINFWP  text                                             *
*      <--P_H_REDUCE_IT  text                                          *
*----------------------------------------------------------------------*
FORM check_du_level_amount USING    i_mhnk_ext  LIKE mhnk_ext
                                    i_sumtab    LIKE lsumtab
                                    i_minhw     LIKE lsumtab-dmshb
                                    i_minfw     LIKE lsumtab-wrshb
                                    i_minhwp    LIKE lsumtab-dmshb
                                    i_minfwp    LIKE lsumtab-wrshb
                           CHANGING e_reduce_it LIKE boole-boole.
* declaration
  DATA: h_achar30(30) TYPE c,
        h_achar15(15) TYPE c,
        h_pchar30(30) TYPE c,
        h_pchar15(15) TYPE c,
        h_amount LIKE boole-boole,
        h_proz LIKE boole-boole.

  DATA ld_check_in_fw.

  ld_check_in_fw = 'X'.
* always check in foreign currency, except when no min amounts in
* foreign currency were found, that means :
  IF i_minhw <> 0 OR i_minhwp <> 0.
    ld_check_in_fw = space.  " check in company currency
  ENDIF.

  e_reduce_it = space.

* check the min amount for dunning currency
  IF ld_check_in_fw = 'X'.
    IF ( i_sumtab-faefw < i_minfw  OR i_sumtab-faefw = 0 )
       AND not i_mhnk_ext-cblock = i_mhnk_ext-call.           "1273832
      e_reduce_it = 'X'.
      h_amount = 'X'.
      WRITE i_sumtab-faefw TO h_achar30 CURRENCY i_mhnk_ext-waers
            LEFT-JUSTIFIED.
      WRITE i_minfw TO h_achar15 CURRENCY i_mhnk_ext-waers
            LEFT-JUSTIFIED.
    ENDIF.
* check the minproz amount for dunning currency
    IF i_sumtab-faefw < i_minfwp.
      e_reduce_it = 'X'.
      h_proz = 'X'.
      WRITE i_sumtab-faefw TO h_pchar30 CURRENCY i_mhnk_ext-waers
            LEFT-JUSTIFIED.
      WRITE i_minfwp TO h_pchar15 CURRENCY i_mhnk_ext-waers
            LEFT-JUSTIFIED.
    ENDIF.
  ELSE.
* check the min amount for company currency
    if ( i_sumtab-faehw < i_minhw or i_sumtab-faehw = 0 )
         AND not i_mhnk_ext-cblock = i_mhnk_ext-call.           "1273832
      e_reduce_it = 'X'.
      h_amount = 'X'.
      WRITE i_sumtab-faehw TO h_achar30 CURRENCY i_mhnk_ext-hwaers
            LEFT-JUSTIFIED.
      WRITE i_minhw TO h_achar15 CURRENCY i_mhnk_ext-hwaers
            LEFT-JUSTIFIED.
    ENDIF.
* check the minproz amount for company currency
    IF i_sumtab-faehw < i_minhwp.
      e_reduce_it = 'X'.
      h_proz = 'X'.
      WRITE i_sumtab-faehw TO h_pchar30 CURRENCY i_mhnk_ext-hwaers
            LEFT-JUSTIFIED.
      WRITE i_minhwp TO h_pchar15 CURRENCY i_mhnk_ext-hwaers
            LEFT-JUSTIFIED.
    ENDIF.
  ENDIF.
* log the amounts if necessary
  IF e_reduce_it = 'X'.
    IF h_amount = 'X'.
      IF 0 = 1. MESSAGE s708. ENDIF.
      PERFORM log_msg USING '708' h_achar30 i_mhnk_ext-mahsk
                                  space space.
      IF h_achar30 < h_achar15.                                "1273832
      if i_mhnk_ext-smahsk <> space or i_mhnk_ext-smaber = space.
        IF 0 = 1. MESSAGE s715. ENDIF.
        PERFORM log_msg USING '715' i_mhnk_ext-konto i_mhnk_ext-mahsk
                                    h_achar30 h_achar15.
      ELSE.
        IF 0 = 1. MESSAGE s713. ENDIF.
        PERFORM log_msg USING '713' i_mhnk_ext-konto i_mhnk_ext-smaber
                                    h_pchar30 h_pchar15.
      ENDIF.
      ENDIF.                                                    "1273832
    endif.
    IF h_proz = 'X'.
      IF 0 = 1. MESSAGE s708. ENDIF.
      PERFORM log_msg USING '708' h_pchar30 i_mhnk_ext-mahsk
                                  space space.
      IF h_achar30 < h_achar15.                                "1273832
      IF i_mhnk_ext-smahsk <> space OR i_mhnk_ext-smaber = space.
        IF 0 = 1. MESSAGE s716. ENDIF.
        PERFORM log_msg USING '716' i_mhnk_ext-konto i_mhnk_ext-mahsk
                                    h_pchar30 h_pchar15.
      ELSE.
        IF 0 = 1. MESSAGE s714. ENDIF.
        PERFORM log_msg USING '714' i_mhnk_ext-konto i_mhnk_ext-smaber
                                    h_pchar30 h_pchar15.
      ENDIF.
      ENDIF.                                                    "1273832
    endif.
  ENDIF.

ENDFORM.                               " CHECK_DU_LEVEL_AMOUNT
*&---------------------------------------------------------------------*
*&      Form  CHECK_DD_ITEM
*&---------------------------------------------------------------------*
*       check if the item has a payment method for diredt debit or
*       if the item is a branch item which has direct debit in knb1
*----------------------------------------------------------------------*
*      -->P_T_MHND_EXT  text                                           *
*      <--P_T_MHND_EXT-XZALB  text                                     *
*----------------------------------------------------------------------*
FORM check_dd_item USING    i_t001     LIKE t001
                            i_vfm_knxx LIKE vfm_knxx
                            i_vfm_lfxx LIKE vfm_lfxx
                            i_mhnd_ext LIKE mhnd_ext
                            i_dd_acc   LIKE boole-boole
                   CHANGING e_xzalb.
* declaration
  DATA: acc_zwels    LIKE vfm_knxx-zwels,
        acc_zahls    LIKE knb1-zahls.

  e_xzalb = space.

* check the payment method for the item
  IF i_mhnd_ext-zlspr = space.
    acc_zwels = i_mhnd_ext-zlsch.
    PERFORM check_direct_debit USING    i_t001 acc_zwels
                               CHANGING e_xzalb.
  ELSE.
    EXIT.
  ENDIF.

* get the payment methods from the branch
  IF i_mhnd_ext-koart = 'D'.
*   if branch dunning is active
    IF i_vfm_knxx-xdezv = 'X' AND i_mhnd_ext-filkd <> space.
*     determine payment method for the brach account
      SELECT SINGLE zwels zahls FROM knb1 INTO (acc_zwels, acc_zahls)
                          WHERE  kunnr = i_mhnd_ext-filkd
                          AND    bukrs = i_mhnd_ext-bukrs.
      IF acc_zwels <> space AND acc_zahls = space AND
         i_mhnd_ext-zlsch = space.
        PERFORM check_direct_debit USING    i_t001 acc_zwels
                                   CHANGING e_xzalb.
      ENDIF.
      IF acc_zahls <> space. e_xzalb = space. ENDIF.
    ELSE.
*     check if account has payment lock
      IF i_vfm_knxx-zahls = space.
*       check if item is payable
        IF i_mhnd_ext-zlsch = space.
          e_xzalb = i_dd_acc.
        ENDIF.
      ELSE.
*       set account status
        e_xzalb = space.
      ENDIF.
    ENDIF.
  ELSE.
*     if branch dunning is active
    IF i_vfm_lfxx-xdezv = 'X' AND i_mhnd_ext-filkd <> space.
*       determine payment method for the brach account
      SELECT SINGLE zwels zahls FROM lfb1 INTO (acc_zwels, acc_zahls)
                          WHERE  lifnr = i_mhnd_ext-filkd
                          AND    bukrs = i_mhnd_ext-bukrs.
      IF acc_zwels <> space AND acc_zahls = space AND
         i_mhnd_ext-zlsch = space.
        PERFORM check_direct_debit USING    i_t001 acc_zwels
                                   CHANGING e_xzalb.
      ENDIF.
      IF acc_zahls <> space. e_xzalb = space. ENDIF.
    ELSE.
*       check if account has payment lock
      IF i_vfm_lfxx-zahls = space.
*         check if item is payable
        IF i_mhnd_ext-zlsch = space.
          e_xzalb = i_dd_acc.
        ENDIF.
      ELSE.
*         set account status
        e_xzalb = space.
      ENDIF.
    ENDIF.
  ENDIF.


ENDFORM.                               " CHECK_DD_ITEM

*&---------------------------------------------------------------------*
*&      Form  CHECK_DIRECT_DEBIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ACC_ZWELS  text                                            *
*      <--P_E_XZALB  text                                              *
*----------------------------------------------------------------------*
FORM check_direct_debit USING    i_t001  LIKE t001
                                 i_zwels LIKE knb1-zwels
                        CHANGING e_xzalb LIKE boole-boole.
  DATA: string LIKE knb1-zwels.
  e_xzalb = space.
  string = i_zwels.
  WHILE string NE space.
    t042z-land1 = i_t001-land1.
    t042z-zlsch = string(1).
    READ TABLE t042z.
    IF sy-subrc = 0.
      IF t042z-xeinz = 'X'
      AND t042z-xwanf = space          "Wechselanforderung
      AND t042z-xzanf = space.         "Zahlungsanforderung
        e_xzalb = 'X'.
        EXIT.
      ENDIF.
    ENDIF.
    SHIFT string.
  ENDWHILE.

ENDFORM.                               " CHECK_DIRECT_DEBIT
*&---------------------------------------------------------------------*
*&      Form  CHECK_DD_ACCOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_T001  text                                               *
*      -->P_E_VFM_KNXX  text                                           *
*      -->P_E_VFM_LFXX  text                                           *
*      <--P_H_DD_ACC  text                                             *
*----------------------------------------------------------------------*
FORM check_dd_account USING    i_t001     LIKE t001
                               i_vfm_knxx LIKE vfm_knxx
                               i_vfm_lfxx LIKE vfm_lfxx
                      CHANGING e_dd_acc.
* declaration
  DATA: acc_zwels LIKE knb1-zwels,
        konto(15) TYPE c.

  e_dd_acc = space.
  IF i_vfm_knxx-zwels <> space.
    acc_zwels = i_vfm_knxx-zwels.
    konto   = 'D'.
    konto+2 = i_vfm_knxx-kunnr.
  ELSEIF i_vfm_lfxx-zwels <> space.
    acc_zwels = i_vfm_lfxx-zwels.
    konto = 'K'.
    konto+2 = i_vfm_lfxx-lifnr.
  ENDIF.
  IF acc_zwels <> space.
    PERFORM check_direct_debit USING    i_t001 acc_zwels
                               CHANGING e_dd_acc.
  ENDIF.
  IF e_dd_acc = 'X'.
    IF 0 = 1. MESSAGE s805. ENDIF.
    PERFORM log_msg USING '805' konto space space space.
  ENDIF.

ENDFORM.                               " CHECK_DD_ACCOUNT
*&---------------------------------------------------------------------*
*&      Form  CHECK_SGL_INDICATOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_T047A  text                                              *
*      -->P_T_MHND_EXT  text                                           *
*      <--P_H_DEL_DU  text                                             *
*----------------------------------------------------------------------*
FORM check_sgl_indicator USING    i_t047a    LIKE t047a
                                  i_mhnd_ext LIKE mhnd_ext
                                  i_item_koart LIKE mhnk_ext-koart "1258562
                         CHANGING e_del_du   LIKE boole-boole.
* declaration
  DATA: h_char1(1) TYPE c,
        h_umskd LIKE t047a-umskd.

* test previous checks
  CHECK e_del_du = space.

  IF i_item_koart = 'K'.                               "1258562
    h_umskd = i_t047a-umskk.                           "1258562
  ELSE.
    h_umskd = i_t047a-umskd.                           "1258562
  ENDIF.


* determine sgl indicator and check if mhnd is to be included
  e_del_du = 'X'.

  IF i_mhnd_ext-umskz = space.
    IF i_t047a-xnums = 'X'.
      e_del_du = space.
    ENDIF.
  ELSE.
*    Coding before Unicode:
*    DO 20 TIMES VARYING h_char1 FROM h_umskd NEXT h_umskd+1.
*      IF h_char1 = i_mhnd_ext-umskz.
*        e_del_du = space.
*        EXIT.
*      ENDIF.
*    ENDDO.
*  With Unicode:
    FIND i_mhnd_ext-umskz IN h_umskd.
    IF sy-subrc = 0.
      e_del_du = space.
    ENDIF.
  ENDIF.
  IF e_del_du = 'X'.
*   do not include ite in dunning
    IF 0 = 1. MESSAGE s820. ENDIF.
    PERFORM log_msg USING '820' i_mhnd_ext-blinf i_mhnd_ext-umskz
                                space space.
  ENDIF.



ENDFORM.                               " CHECK_SGL_INDICATOR
*&---------------------------------------------------------------------*
*&      Form  CHECK_LEGAL_DUNNING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_T047A  text                                              *
*      -->P_T_MHNK_EXT  text                                           *
*      <--P_H_DUNN_IT  text                                            *
*      <--P_H_LEGAL_DU  text                                           *
*----------------------------------------------------------------------*
FORM check_legal_dunning USING    i_t047a    LIKE t047a
                                  i_mhnk_ext LIKE mhnk_ext
                         CHANGING e_dunn_it  LIKE boole-boole
                                  e_legal_du LIKE boole-boole
                                  e_fimsg    LIKE fimsg.

* declaration
  DATA: h_char15(15) TYPE c.

* test previous checks
  CHECK e_dunn_it = 'X'.

* preset variables
  e_dunn_it  = 'X'.
  e_legal_du = space.
  h_char15   = i_mhnk_ext-madat.
  CLEAR e_fimsg.

* account is in the legal dunning
  IF NOT i_mhnk_ext-gmvdt IS INITIAL.
    e_legal_du = 'X'.
*   account has no transactions after the last dunning date
    IF i_mhnk_ext-dtlbw < i_mhnk_ext-madat AND
       NOT i_mhnk_ext-madat IS INITIAL.
      IF i_t047a-xmger = 'X'.
*       always print a dunning in the legal dunning proc.
        IF 0 = 1. MESSAGE s825. ENDIF.
        e_fimsg-msgno = '825'.
        e_fimsg-msgv1 = i_mhnk_ext-konto.
        e_fimsg-msgv2 = i_mhnk_ext-madat.
      ELSE.
*       account has no transactions after the legal dunning data
        IF 0 = 1. MESSAGE s824. ENDIF.
        e_fimsg-msgno = '824'.
        e_fimsg-msgv1 = i_mhnk_ext-konto.
        e_fimsg-msgv2 = i_mhnk_ext-madat.
        e_dunn_it = space.
      ENDIF.
    ELSE.
*     account has transactions after the legal dunning data > save msg
      IF 0 = 1. MESSAGE s823. ENDIF.
      e_fimsg-msgno = '823'.
      e_fimsg-msgv1 = i_mhnk_ext-konto.
      e_fimsg-msgv2 = i_mhnk_ext-madat.
    ENDIF.
  ENDIF.

ENDFORM.                               " CHECK_LEGAL_DUNNING
*&---------------------------------------------------------------------*
*&      Form  CALC_INTEREST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_T047B  text                                              *
*      <--P_T_MHNK_EXT  text                                           *
*      <--P_T_MHND_EXT  text                                           *
*----------------------------------------------------------------------*
FORM calc_interest TABLES   t_t047b STRUCTURE t047b
                   USING    i_ausdt    LIKE f150v-ausdt
                   CHANGING e_mhnk_ext LIKE mhnk_ext
                            e_mhnd_ext LIKE mhnd_ext.

* check if account has a vzskz if not do not print any interest
  IF e_mhnk_ext-vzskz = space OR e_mhnd_ext-mahnn = 0 OR
            e_mhnd_ext-xzalb <> space
            OR ( e_mhnd_ext-shkzg = 'S' AND e_mhnd_ext-verzn < 0 ).
    e_mhnd_ext-xzins = 'X'.
    EXIT.
  ENDIF.

* determine the customizing for the mhnd entry
  READ TABLE t_t047b WITH KEY mahna = e_mhnk_ext-mahna
                              mahns = e_mhnd_ext-mahnn.

* if customizing could be found (this is reasonable sure)
  IF sy-subrc = 0.
*   calcuate the interest if
    PERFORM determine_interest USING    i_ausdt e_mhnk_ext e_mhnd_ext
                               CHANGING e_mhnd_ext-zinss
                                        e_mhnd_ext-zinst
                                        e_mhnd_ext-wzsbt
                                        e_mhnd_ext-zsbtr.
    IF t_t047b-xzins = 'X' AND e_mhnd_ext-mansp = space.
*     print interest in the dunning notice
      e_mhnd_ext-xzins = space.
    ELSE.
*     do not print interest in the dunning notice
      e_mhnd_ext-xzins = 'X'.
    ENDIF.

*   redetermine the interest in the ofi interface
    PERFORM ofi_dun_determine_interest USING    i_ausdt e_mhnk_ext
                                                e_mhnd_ext
                                       CHANGING e_mhnd_ext-zinss
                                                e_mhnd_ext-zinst
                                                e_mhnd_ext-wzsbt
                                                e_mhnd_ext-zsbtr
                                                e_mhnd_ext-xzins.

    IF e_mhnd_ext-xzins = space AND e_mhnd_ext-mansp = space.
      IF e_mhnd_ext-waers = e_mhnk_ext-waers.
*  item is in dunning currency
        e_mhnk_ext-zinbt = e_mhnk_ext-zinbt + e_mhnd_ext-wzsbt.
      ELSE.
*  item is not in dunning currency, dunning currency must be
*  company code currency
        e_mhnk_ext-zinbt = e_mhnk_ext-zinbt + e_mhnd_ext-zsbtr.
      ENDIF.
      e_mhnk_ext-zinhw = e_mhnk_ext-zinhw + e_mhnd_ext-zsbtr.
    ENDIF.
  ENDIF.
ENDFORM.                               " CALC_INTEREST
*&---------------------------------------------------------------------*
*&      Form  CHECK_DB_ACCOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHNK_EXT  text                                           *
*      <--P_T_MHNK_EXT-XMFLG  text                                     *
*----------------------------------------------------------------------*
FORM check_db_account USING    i_mhnk_ext LIKE mhnk_ext
                      CHANGING e_dunn_it  LIKE boole-boole
                               e_xmflg LIKE mhnk_ext-xmflg.
*  e_xmflg = 'X'.
  IF i_mhnk_ext-mansp <> space.
    e_xmflg = space.
    IF 0 = 1. MESSAGE s810. ENDIF.
    PERFORM log_msg USING '810' i_mhnk_ext-konto
                                space space space.
  ENDIF.

* additional check if only blocked items
  IF i_mhnk_ext-cblock = i_mhnk_ext-call AND
                    i_mhnk_ext-gmvdt IS INITIAL.
    e_xmflg = space.
    e_dunn_it = 'X'.
  ENDIF.


ENDFORM.                               " CHECK_DB_ACCOUNT
*&---------------------------------------------------------------------*
*&      Form  CHECK_DB_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHND_EXT  text                                           *
*      <--P_H_DB_ITEM  text                                            *
*----------------------------------------------------------------------*
FORM check_db_item USING    i_mhnd_ext LIKE mhnd_ext
                   CHANGING e_mansp    LIKE mhnd_ext-mansp
                            e_db_item  LIKE boole-boole.
  e_db_item = space.

* check if account has db reason in icc dunning
  IF i_mhnd_ext-mansp = space AND i_mhnd_ext-kmansp <> space.
    e_db_item = 'X'.
    e_mansp = i_mhnd_ext-kmansp.
    IF 0 = 1. MESSAGE s849. ENDIF.
    PERFORM log_msg USING '849' i_mhnd_ext-blinf i_mhnd_ext-kmansp
                                space space.
    EXIT.
  ENDIF.

* check if item has db reason
  IF i_mhnd_ext-mansp <> space.
    e_db_item = 'X'.
    IF 0 = 1. MESSAGE s821. ENDIF.
    PERFORM log_msg USING '821' i_mhnd_ext-blinf i_mhnd_ext-mansp
                                space space.
  ENDIF.
ENDFORM.                               " CHECK_DB_ITEM
*&---------------------------------------------------------------------*
*&      Form  CLEAN_MHNK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHNK_EXT  text                                           *
*----------------------------------------------------------------------*
FORM clean_mhnk TABLES   t_mhnk_ext STRUCTURE mhnk_ext
                         t_mhnd_ext STRUCTURE mhnd_ext.

  LOOP AT t_mhnk_ext.
    READ TABLE t_mhnd_ext WITH KEY laufd  = t_mhnk_ext-laufd
                                   laufi  = t_mhnk_ext-laufi
                                   koart  = t_mhnk_ext-koart
                                   bukrs  = t_mhnk_ext-bukrs
                                   kunnr  = t_mhnk_ext-kunnr
                                   lifnr  = t_mhnk_ext-lifnr
                                   cpdky  = t_mhnk_ext-cpdky
                                   sknrze = t_mhnk_ext-sknrze
                                   smaber = t_mhnk_ext-smaber
                                   smahsk = t_mhnk_ext-smahsk.
    IF sy-subrc <> 0.
      DELETE t_mhnk_ext.
    ENDIF.
  ENDLOOP.


ENDFORM.                               " CLEAN_MHNK
*&---------------------------------------------------------------------*
*&      Form  CHECK_ACC_MIN_INTEREST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_T_MHNK_EXT  text                                           *
*----------------------------------------------------------------------*
FORM check_acc_min_interest CHANGING e_mhnk_ext LIKE mhnk_ext.
* declaration
  DATA: h_achar30(30) TYPE c,
        h_achar15(15) TYPE c,
        h_waers LIKE t001-waers.

* check previous settings for mhnk-xzins
  CHECK e_mhnk_ext-xzins = space.
  e_mhnk_ext-minz_it = space.

* check if account has a interest indicator
  IF e_mhnk_ext-vzskz = space.
    e_mhnk_ext-minz_it = 'X'.
    IF 0 = 1. MESSAGE s841. ENDIF.
    e_mhnk_ext-minz_msg-msgno = '841'.
    e_mhnk_ext-minz_msg-msgv1 = e_mhnk_ext-konto.
    e_mhnk_ext-minz_msg-msgv2 = e_mhnk_ext-mahna.
    EXIT.
  ENDIF.

* check the min amount for dunning currency
  IF e_mhnk_ext-minzfw > e_mhnk_ext-zinbt.
    WRITE e_mhnk_ext-zinbt TO h_achar30 CURRENCY e_mhnk_ext-waers
          LEFT-JUSTIFIED.
    WRITE e_mhnk_ext-minzfw TO h_achar15 CURRENCY e_mhnk_ext-waers
          LEFT-JUSTIFIED.
    e_mhnk_ext-xzins = 'X'.
    h_waers = e_mhnk_ext-waers.
  ELSEIF e_mhnk_ext-minzhw > e_mhnk_ext-zinhw.
    WRITE e_mhnk_ext-zinhw TO h_achar30 CURRENCY e_mhnk_ext-hwaers
          LEFT-JUSTIFIED.
    WRITE e_mhnk_ext-minzhw TO h_achar15 CURRENCY e_mhnk_ext-hwaers
          LEFT-JUSTIFIED.
    e_mhnk_ext-xzins = 'X'.
    h_waers = e_mhnk_ext-hwaers.
  ENDIF.
  IF e_mhnk_ext-xzins = 'X'.
    e_mhnk_ext-minz_it = 'X'.
    IF 0 = 1. MESSAGE s719. ENDIF.
    e_mhnk_ext-minz_msg-msgno = '719'.
    e_mhnk_ext-minz_msg-msgv1 = e_mhnk_ext-konto.
    e_mhnk_ext-minz_msg-msgv2 = h_achar30.
    e_mhnk_ext-minz_msg-msgv3 = h_achar15.
    e_mhnk_ext-minz_msg-msgv4 = h_waers.
  ENDIF.

ENDFORM.                               " CHECK_ACC_MIN_INTEREST
*&---------------------------------------------------------------------*
*&      Form  CHECK_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_FLDTAB  text                                             *
*      -->P_0285   text                                                *
*      <--P_E_DUNN_IT  text                                            *
*----------------------------------------------------------------------*
FORM check_field TABLES   t_fldtab  STRUCTURE ifldtab
                 USING    i_tabname LIKE f150v-fldna
                 CHANGING e_dunn_it LIKE boole-boole.
* declaration
  DATA: h_idx LIKE sy-tabix,
        h_ret LIKE sy-subrc.

* determine if field is to be included
  e_dunn_it = 'X'.
  LOOP AT t_fldtab.
    h_idx = sy-tabix.
    CHECK t_fldtab-fldna(4) = i_tabname.
    PERFORM check_string USING t_fldtab t_fldtab-fldl1
                               h_idx e_dunn_it.
    IF e_dunn_it = space.
      PERFORM check_string USING t_fldtab t_fldtab-fldl2
                                 h_idx e_dunn_it.
    ENDIF.
    IF t_fldtab-ignor = 'X'.
      IF e_dunn_it = 'X'.
        e_dunn_it = space.
      ELSE.
        e_dunn_it = 'X'.
      ENDIF.
    ENDIF.
    IF e_dunn_it = space.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " CHECK_FIELD
*&---------------------------------------------------------------------*
*&      Form  CHECK_STRING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_FLDTAB-FLDL1  text                                       *
*      -->P_H_IDX  text                                                *
*      -->P_E_DUNN_IT  text                                            *
*----------------------------------------------------------------------*
FORM check_string USING    i_fldtab  LIKE ifldtab
                           i_string  LIKE ifldtab-fldl1
                           i_idx     LIKE sy-tabix
                  CHANGING e_dunn_it LIKE boole-boole.
* declaration
  DATA:  h_string    LIKE ifldtab-fldl1,
         h_von(50)   TYPE c,
         h_bis(50)   TYPE c,
         h_blank(50) TYPE c VALUE ' ',
         h_value(50) TYPE c,
         h_ref1(16)  TYPE p,
         h_ref2(16)  TYPE p,
         h_ref3(16)  TYPE p.

* initialization
  h_string  = i_string.
  e_dunn_it = space.

  WHILE h_string <> space AND e_dunn_it = space.
    IF h_string(1) NE '('.
      h_von = h_string.
      REPLACE ',' WITH h_blank INTO h_von.
      h_bis = h_von.
    ELSE.
      h_von = h_string+1.
      REPLACE ',' WITH h_blank INTO h_von.
      SHIFT h_string UP TO ','.
      SHIFT h_string.
      h_bis = h_string.
      REPLACE ')' WITH h_blank INTO h_bis.
    ENDIF.
    CASE i_idx.
      WHEN 1. h_value = <f1>.
      WHEN 2. h_value = <f2>.
      WHEN 3. h_value = <f3>.
      WHEN 4. h_value = <f4>.
      WHEN 5. h_value = <f5>.
      WHEN 6. h_value = <f6>.
      WHEN 7. h_value = <f7>.
      WHEN 8. h_value = <f8>.
    ENDCASE.
    IF i_fldtab-uppct = 'X'.
      IF sy-langu <> 'E'.
        SET LOCALE LANGUAGE 'E'.
        TRANSLATE h_value TO UPPER CASE.
        SET LOCALE LANGUAGE space.
      ELSE.
        TRANSLATE h_value TO UPPER CASE.
      ENDIF.
    ENDIF.
    IF i_fldtab-uppct NE 'P'.
      IF h_value GE h_von AND h_value LE h_bis.
        e_dunn_it = 'X'.
      ENDIF.
    ELSE.
      h_ref1 = h_von.
      h_ref2 = h_bis.
      h_ref3 = h_value.
      IF  h_ref3 GE h_ref1
      AND h_ref3 LE h_ref2.
        e_dunn_it = 'X'.
      ENDIF.
    ENDIF.
    IF e_dunn_it = 'X'. EXIT. ENDIF.
    SHIFT h_string UP TO ','.
    IF sy-subrc = 0.
      SHIFT h_string.
    ELSE.
      EXIT.
    ENDIF.
  ENDWHILE.

ENDFORM.                               " CHECK_STRING
*&---------------------------------------------------------------------*
*&      Form  CHECK_CLEARING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_KNB5  text                                               *
*      -->P_T_LFB5  text                                               *
*      <--P_E_VFM_KNXX  text                                           *
*      <--P_E_VFM_LFXX  text                                           *
*----------------------------------------------------------------------*
FORM check_clearing TABLES   i_knb5 STRUCTURE knb5
                             i_lfb5 STRUCTURE lfb5
                    USING    koart LIKE mhnk_ext-koart
                    CHANGING e_vfm_knxx LIKE vfm_knxx
                             e_vfm_lfxx LIKE vfm_lfxx.
  IF e_vfm_knxx-xdezv = 'X' OR e_vfm_lfxx-xdezv = 'X'.
*   clearing is not allowed with branch dunning
    e_vfm_knxx-xverr = space.
    e_vfm_lfxx-xverr = space.
    IF koart = 'D'.
      IF 0 = 1. MESSAGE s112. ENDIF.
      PERFORM log_msg USING '112' e_vfm_knxx-kunnr e_vfm_knxx-bukrs
                                  space space.
    ELSE.
      IF 0 = 1. MESSAGE s113. ENDIF.
      PERFORM log_msg USING '113' e_vfm_lfxx-kunnr e_vfm_lfxx-bukrs
                                  space space.
    ENDIF.
  ENDIF.
*** XO
*  LOOP AT i_knb5.
*    READ TABLE i_lfb5 WITH KEY maber = i_knb5-maber.
*    IF sy-subrc = 0.
*    IF ( i_lfb5-mahna <> i_knb5-mahna )  AND ( i_lfb5-mahna <> space ).
**     Ausgabe der Fehlermeldung
*        PERFORM log_msg USING '114' e_vfm_knxx-kunnr e_vfm_knxx-lifnr
*                                e_vfm_knxx-bukrs  i_knb5-maber.
*        e_vfm_knxx-xverr = space.
*        e_vfm_lfxx-xverr = space.
*      ENDIF.
*    ELSEIF sy-subrc = 4.
**  Satz in lfb5 schreiben.
*      i_knb5-mansp = space. i_knb5-mahns = 0. i_knb5-knrma = space.
*      INSERT INTO lfb5 VALUES i_knb5.
*    ENDIF.
*  ENDLOOP.
*** XO ENDE
  IF e_vfm_knxx-mahna <> e_vfm_lfxx-mahna.
*   clearing is not allowed with different dunning procedures
    e_vfm_knxx-xverr = space.
    e_vfm_lfxx-xverr = space.
    IF 0 = 1. MESSAGE s111. ENDIF.
    PERFORM log_msg USING '111' e_vfm_knxx-lifnr e_vfm_knxx-kunnr "982935
                                e_vfm_knxx-bukrs space.
  ENDIF.
ENDFORM.                               " CHECK_CLEARING
*&---------------------------------------------------------------------*
*&      Form  CREATE_UNIQUE_CPDKY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_H_CPDKY_CPD  text                                          *
*      -->P_H_CPDKY_GRP  text                                          *
*      <--P_T_MHND_EXT_CPDKY  text                                     *
*----------------------------------------------------------------------*
FORM create_unique_cpdky TABLES   t_cpdtab    STRUCTURE cpdtab
                         USING    i_cpdky_cpd LIKE mhnd_ext-cpdky
                                  i_cpdky_grp LIKE mhnd_ext-cpdky
                         CHANGING e_cpdky     LIKE mhnd_ext-cpdky.
* declaration
  DATA: h_tabix      LIKE sy-tabix,
        h_char10(10) TYPE c.

  e_cpdky = space.
  IF i_cpdky_cpd <> space AND i_cpdky_grp = space.
*   cpd account without groups
    e_cpdky = i_cpdky_cpd.
  ELSEIF i_cpdky_cpd = space AND i_cpdky_grp <> space.
*   groups at non cpd accounts
    e_cpdky = i_cpdky_grp.
  ELSEIF i_cpdky_cpd <> space AND i_cpdky_grp <> space.
*   cpdaccount and groups determine unique cpdky
    READ TABLE t_cpdtab WITH KEY cpdky_cpd = i_cpdky_cpd
                                 cpdky_grp = i_cpdky_grp.
*   entry not found create new unique cpdky and save in t_cpdky
    IF sy-subrc <> 0.
      DESCRIBE TABLE t_cpdtab LINES h_tabix.
      h_tabix  = h_tabix + 1.
      h_char10 = h_tabix.
      CONCATENATE c_cpdprefix h_char10 INTO e_cpdky.
      t_cpdtab-cpdky     = e_cpdky.
      t_cpdtab-cpdky_cpd = i_cpdky_cpd.
      t_cpdtab-cpdky_grp = i_cpdky_grp.
      APPEND t_cpdtab.
    ENDIF.
    e_cpdky = t_cpdtab-cpdky.
  ENDIF.

ENDFORM.                               " CREATE_UNIQUE_CPDKY
*&---------------------------------------------------------------------*
*&      Form  CONVERT_BUKRS_RANGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BUKRS  text                                              *
*      -->P_TR_BUKRS  text                                             *
*----------------------------------------------------------------------*
FORM convert_bukrs_ranges TABLES   t_iccdbukrs  STRUCTURE ibkrtab
                                   t_bukrs      STRUCTURE bukrs_sel
                          USING    i_bukrs      LIKE mhnd-bukrs
                          CHANGING e_iccd       LIKE boole-boole.

* declaration
  DATA: h_lines LIKE sy-tfill.

* check if inter company code dunning is in progress
  DESCRIBE TABLE t_iccdbukrs LINES h_lines.
  IF h_lines > 0.
    e_iccd = 'X'.
  ELSE.
    e_iccd = space.
    t_iccdbukrs-bukrs = i_bukrs.
    APPEND t_iccdbukrs.
  ENDIF.

* init the ranges
  REFRESH t_bukrs.
  CLEAR t_bukrs.
  t_bukrs-sign   = 'I'.
  t_bukrs-option = 'EQ'.

* convert bukrs table into ranges structure
  LOOP AT t_iccdbukrs.
    t_bukrs-low = t_iccdbukrs-bukrs.
    COLLECT t_bukrs.
  ENDLOOP.

ENDFORM.                               " CONVERT_BUKRS_RANGES
*&---------------------------------------------------------------------*
*&      Form  CHECK_DUNNING_PERIOD_MHND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_KNB5  text                                               *
*      -->P_T_LFB5  text                                               *
*      -->P_I_AUSDT  text                                              *
*      <--P_H_DEL_DU  text                                             *
*----------------------------------------------------------------------*
FORM check_dunning_iccd_mhnd TABLES   t_knb5     STRUCTURE knb5
                                      t_lfb5     STRUCTURE lfb5
                             USING    i_knb5     STRUCTURE knb5
                                      i_lfb5     STRUCTURE lfb5
                                      i_ausdt    LIKE f150v-ausdt
                                      i_mhnd_ext LIKE mhnd_ext
                                      i_t047a    LIKE t047a
                             CHANGING e_gmvdt    LIKE mhnk-gmvdt
                                      e_mansp    LIKE mhnk-mansp
                                      e_del_du   LIKE boole-boole
                                      e_own_mhnk LIKE boole-boole.
* declaration
  DATA: h_date    LIKE f150v-ausdt,
        h_gmvdt_l LIKE mhnk-gmvdt,
        h_madat   LIKE f150v-ausdt,
        h_char(15) TYPE c.

  e_del_du = space.

  IF i_mhnd_ext-bkoart = 'D'.
*   determine actual knb5 entry
    CLEAR t_knb5.
    READ TABLE t_knb5 WITH KEY kunnr = i_mhnd_ext-kunnr
                               bukrs = i_mhnd_ext-bbukrs
                               maber = i_mhnd_ext-smaber.
    h_madat   = t_knb5-madat.
    e_gmvdt   = t_knb5-gmvdt.
    e_mansp   = t_knb5-mansp.
    h_gmvdt_l = i_knb5-gmvdt.
  ELSE.
*   determine the actual knb5 entry
    CLEAR t_lfb5.
    READ TABLE t_lfb5 WITH KEY lifnr = i_mhnd_ext-lifnr
                               bukrs = i_mhnd_ext-bbukrs
                               maber = i_mhnd_ext-smaber.
    h_madat   = t_lfb5-madat.
    e_gmvdt   = t_lfb5-gmvdt.
    e_mansp   = t_lfb5-mansp.
    h_gmvdt_l = i_lfb5-gmvdt.
  ENDIF.

* set flag if cc is in legal dunning
  IF NOT e_gmvdt IS INITIAL AND h_gmvdt_l IS INITIAL.
    e_own_mhnk = 'X'.
  ENDIF.

* check the dunning period for this cc
  IF sy-subrc = 0.
    h_date = h_madat + i_t047a-rhyth.
    IF i_ausdt < h_date.
      e_del_du = 'X'.

*     log the apropriate messages
      h_char = h_madat.
      IF i_mhnd_ext-smaber <> space.
        IF 0 = 1. MESSAGE s847. ENDIF.
        PERFORM log_msg USING '847' i_mhnd_ext-bbukrs
                                    i_mhnd_ext-smaber h_char space.
      ELSE.
        IF 0 = 1. MESSAGE s848. ENDIF.
        PERFORM log_msg USING '848' i_mhnd_ext-bbukrs
                                    h_char space space.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                               " CHECK_DUNNING_PERIOD_MHND
*&---------------------------------------------------------------------*
*&      Form  CREATE_MHND_EXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHND  text                                               *
*      <--P_H_HAS_ITEMS  text                                          *
*----------------------------------------------------------------------*
FORM create_mhnd_ext TABLES   t_mhnd_in   STRUCTURE mhnd
                              t_mhnk_in   STRUCTURE mhnk
                              t_mhnd_ext  STRUCTURE mhnd_ext
                     CHANGING e_has_items LIKE boole-boole.

* init
  e_has_items = 'X'.

* transform mhnd
  LOOP AT t_mhnd_in.
    MOVE-CORRESPONDING t_mhnd_in TO t_mhnd_ext.
    t_mhnd_ext-smahsk = space.
    READ TABLE t_mhnk_in WITH KEY laufd  = t_mhnd_in-laufd
                                   laufi  = t_mhnd_in-laufi
                                   koart  = t_mhnd_in-koart
                                   bukrs  = t_mhnd_in-bukrs
                                   kunnr  = t_mhnd_in-kunnr
                                   lifnr  = t_mhnd_in-lifnr
                                   cpdky  = t_mhnd_in-cpdky
                                   sknrze = t_mhnd_in-sknrze
                                   smaber = t_mhnd_in-smaber.
    IF sy-subrc = 0.
      t_mhnd_ext-applk = t_mhnk_in-applk.
      t_mhnd_ext-mgrup = t_mhnk_in-mgrup.
      t_mhnd_ext-pstlz = t_mhnk_in-pstlz.
      t_mhnd_ext-ort01 = t_mhnk_in-ort01.
      t_mhnd_ext-stras = t_mhnk_in-stras.
      t_mhnd_ext-pfach = t_mhnk_in-pfach.
      t_mhnd_ext-land1 = t_mhnk_in-land1.
    ENDIF.

    APPEND t_mhnd_ext.
  ENDLOOP.
  IF sy-subrc <> 0.
    e_has_items = space.
  ENDIF.

ENDFORM.                               " CREATE_MHND_EXT
*&---------------------------------------------------------------------*
*&      Form  COMMAND_CHCK_1003
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM command_chck_1003 USING i_display_log LIKE boole-boole.

* declaration
  DATA: h_lmhnk LIKE sy-tabix,
        h_lmhnd LIKE sy-tabix,
        t_mhnd  LIKE mhnd OCCURS 1 WITH HEADER LINE,
        t_mhnk  LIKE mhnk OCCURS 1 WITH HEADER LINE.

* check if check has to be made
  CHECK edd_disp = space.

* check if check has already been made
  IF edd_mhnk[] = chk_mhnk[] AND
     edd_mhnd[] = chk_mhnd[] AND
     i_display_log = space.
*    no changes has been made
    EXIT.
  ENDIF.

* init the log table
  REFRESH ti_fimsg.

* check the dunning data in the t_mhnd/k_in tables and build new groups
  CALL FUNCTION 'GENERATE_DUNNING_DATA'
       EXPORTING
            i_laufd               = edi_mhnk-laufd
            i_laufi               = edi_mhnk-laufi
            i_bukrs               = edi_mhnk-bukrs
            i_grdat               = edi_mhnk-grdat
            i_ausdt               = edi_mhnk-ausdt
            i_trace               = 'X'
            i_mout                = space
            i_ofi                 = 'X'
            i_check_in            = 'X'
       TABLES
            t_mhnk                = t_mhnk
            t_mhnd                = t_mhnd
            t_mhnk_in             = edd_mhnk
            t_mhnd_in             = edd_mhnd
*           T_FLDTAB              =
*           T_ICCDBUKRS           =
            t_fimsg               = ti_fimsg
       CHANGING
            c_kunnr               = edi_mhnk-kunnr
            c_lifnr               = edi_mhnk-lifnr
       EXCEPTIONS
            customer_wo_procedure = 1
            customer_not_found    = 2
            customizing_error     = 3
            parameter_error       = 4
            OTHERS                = 5.

  IF i_display_log = 'X'.
*   display the log
    CALL SCREEN 2001 STARTING AT  5 13
                         ENDING   AT 95 30.
  ENDIF.

* reset the changed dunning data
  DESCRIBE TABLE t_mhnk LINES h_lmhnk.
  DESCRIBE TABLE t_mhnd LINES h_lmhnd.

  IF h_lmhnk > 0 AND h_lmhnd > 0.
    edd_mhnk[] = t_mhnk[].
    edd_mhnd[] = t_mhnd[].
  ELSE.
*   restore old values
    edd_mhnk[] = chk_mhnk[].
    edd_mhnd[] = chk_mhnd[].

*   clear ok code
    CLEAR ok-code-1003.

*   issue error message
    MESSAGE e488.

*    loop at edd_mhnk.
*      edd_mhnk-xmflg = space.
*      modify edd_mhnk.
*    endloop.
  ENDIF.

* save for checking
  chk_mhnk[] = edd_mhnk[].
  chk_mhnd[] = edd_mhnd[].

ENDFORM.                               " COMMAND_CHCK_1003
*&---------------------------------------------------------------------*
*&      Form  CHECK_DU_LEVEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MHNK_IN  text                                            *
*      <--P_T_MHND_EXT  text                                           *
*----------------------------------------------------------------------*
FORM check_du_level TABLES   t_t047b    STRUCTURE t047b
                             t_mhnk_in  STRUCTURE mhnk
                             CHANGING e_mhnd_ext LIKE mhnd_ext.
* declaration
  DATA: h_maxst LIKE t047b-mahns.

* check if level manually raised by one and procedure allow that level
  h_maxst = e_mhnd_ext-mahns + 1.
  READ TABLE t_t047b WITH KEY mahns = h_maxst.
  IF sy-subrc <> 0.
    h_maxst = e_mhnd_ext-mahns.
  ENDIF.

* assign max level
  IF e_mhnd_ext-mahnn > h_maxst.
    MESSAGE s855 WITH e_mhnd_ext-blinf h_maxst space space.
    PERFORM log_msg USING '855' e_mhnd_ext-blinf h_maxst space space.
    e_mhnd_ext-mahnn = h_maxst.
    EXIT.
  ELSE.
*   log the new dunning level for the item
    IF 0 = 1. MESSAGE s831. ENDIF.
    PERFORM log_msg USING '831' e_mhnd_ext-blinf e_mhnd_ext-mahnn
                                space space.
  ENDIF.

*   IF e_mhnd_ext-mahnn = 0.
*    e_mhnd_ext-xfael = space.
*  ENDIF.
ENDFORM.                               " CHECK_DU_LEVEL
*&---------------------------------------------------------------------*
*&      Form  CHECK_EDIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_C_MHNK  text                                               *
*----------------------------------------------------------------------*
FORM check_edit USING i_mhnk LIKE mhnk.
  IF NOT i_mhnk-gmvdt IS INITIAL.
    MESSAGE e485.
  ENDIF.
ENDFORM.                               " CHECK_EDIT
*&---------------------------------------------------------------------*
*&      Form  COMMAND_PRIN_1003
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM command_prin_1003.

* declaration
  DATA: h_usr01 LIKE usr01,
        h_itcpo LIKE itcpo,
        t_fimsg LIKE fimsg OCCURS 10 WITH HEADER LINE.

* determine printer parameter
  CALL FUNCTION 'GET_PRINT_PARAM'
    EXPORTING
      i_bname = sy-uname
    IMPORTING
      e_usr01 = h_usr01.

* set printer parameters
  h_itcpo-tddest     = h_usr01-spld.
  h_itcpo-tdimmed    = 'X'.
  h_itcpo-tdpreview  = 'X'.

* reprint the dunning
  CALL FUNCTION 'REPRINT_DUNNING_DATA_ACCOUNT'
    EXPORTING
      i_mhnk        = edi_mhnk
      i_itcpo       = h_itcpo
    TABLES
      t_fimsg       = t_fimsg
    EXCEPTIONS
      no_data_found = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.
    IF edi_mhnk-koart = 'D'.
      MESSAGE e471 WITH edi_mhnk-laufd edi_mhnk-bukrs edi_mhnk-kunnr.
    ELSE.
      MESSAGE e471 WITH edi_mhnk-laufd edi_mhnk-bukrs edi_mhnk-lifnr.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DISPLAY_DUNNING_LOG'
      TABLES
        t_fimsg = t_fimsg.
  ENDIF.


ENDFORM.                               " COMMAND_PRIN_1003
*&---------------------------------------------------------------------*
*&      Form  CALC_CHARGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_T047C  text
*      -->P_E_T001  text
*      <--P_T_MHNK_EXT  text
*----------------------------------------------------------------------*
FORM calc_charges TABLES   t_t047c STRUCTURE t047c
                           t_mhnd_ext
                  USING    i_ausdt    LIKE f150v-ausdt
                  CHANGING e_mhnk_ext LIKE mhnk_ext.
* declaration
  DATA:                                "refe(8)       type p,
        h_achar30(30) TYPE c,
        h_charge      LIKE t047c-mahng,
        h_charge_curr LIKE t047c-waers,
        dunn_currency  TYPE c. " charges found in dunning currency

* init the dunning charges
  CLEAR e_mhnk_ext-charge_msg.
  e_mhnk_ext-charge_it = space.
  e_mhnk_ext-mhngh     = 0.
  e_mhnk_ext-mhngf     = 0.

* determine dunning charges from customizing (1. try dunning currency)
  LOOP AT t_t047c WHERE mahna =  e_mhnk_ext-mahna AND
                        mahns =  e_mhnk_ext-mahsk AND
                        waers =  e_mhnk_ext-waers AND
                        mahnb <= e_mhnk_ext-faebt.
*   check if charges are percent value
    IF t_t047c-mahnp <> 0.
      h_charge = e_mhnk_ext-faebt * t_t047c-mahnp / 10000.
    ELSE.
      h_charge = t_t047c-mahng.
    ENDIF.

*   save the charge currency
    h_charge_curr        = e_mhnk_ext-waers.
    dunn_currency = 'X'.
    e_mhnk_ext-charge_it = 'X'.

*   exit after the first match
    EXIT.
  ENDLOOP.

* if read was not successful (2. try company currence)
  IF sy-subrc <> 0.
    LOOP AT t_t047c WHERE mahna =  e_mhnk_ext-mahna AND
                          mahns =  e_mhnk_ext-mahsk AND
                          waers =  e_mhnk_ext-hwaers AND
                          mahnb <= e_mhnk_ext-faehw.
*     check if charges are percent value
      IF t_t047c-mahnp <> 0.
        h_charge = e_mhnk_ext-faehw * t_t047c-mahnp / 10000.
      ELSE.
        h_charge = t_t047c-mahng.
      ENDIF.

*     save the charge currency
      h_charge_curr        = e_mhnk_ext-hwaers.
      e_mhnk_ext-charge_it = 'X'.

*     exit after the first match
      EXIT.
    ENDLOOP.
  ENDIF.

* determine if charges where calculated
  IF e_mhnk_ext-charge_it = 'X'.
    IF dunn_currency = 'X'.
* calculate amount in company-currency
      IF h_charge_curr <> e_mhnk_ext-hwaers.
        e_mhnk_ext-mhngf = h_charge.
        CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
          EXPORTING
            local_currency   = e_mhnk_ext-hwaers
            foreign_currency = e_mhnk_ext-waers
            foreign_amount   = e_mhnk_ext-mhngf
            date             = e_mhnk_ext-ausdt
          IMPORTING
            local_amount     = e_mhnk_ext-mhngh.
      ELSE.
        e_mhnk_ext-mhngh = h_charge.
        e_mhnk_ext-mhngf = h_charge.
      ENDIF.

    ELSE.
* calculate amount in dunn-currency
      IF h_charge_curr <> e_mhnk_ext-waers.
        e_mhnk_ext-mhngh = h_charge.
        CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
          EXPORTING
            local_currency   = e_mhnk_ext-hwaers
            foreign_currency = e_mhnk_ext-waers
            local_amount     = e_mhnk_ext-mhngh
            date             = e_mhnk_ext-ausdt
          IMPORTING
            foreign_amount   = e_mhnk_ext-mhngf.
      ELSE.
        e_mhnk_ext-mhngh = h_charge.
        e_mhnk_ext-mhngf = h_charge.
      ENDIF.
    ENDIF.
  ENDIF.

* redetermine Charges via open FI
  PERFORM ofi_dun_determine_charges TABLES   t_mhnd_ext
                                    USING    i_ausdt
                                             e_mhnk_ext
                                    CHANGING e_mhnk_ext-mhngh
                                             e_mhnk_ext-mhngf.

  IF e_mhnk_ext-mhngf <> 0.

*   set status
    e_mhnk_ext-charge_it = 'X'.

*   create the aproprite message
    WRITE e_mhnk_ext-mhngf TO h_achar30 CURRENCY e_mhnk_ext-waers
           LEFT-JUSTIFIED.

    IF 0 = 1. MESSAGE s856. ENDIF.
    e_mhnk_ext-charge_msg-msgno = '856'.
    e_mhnk_ext-charge_msg-msgv1 = e_mhnk_ext-konto.
    e_mhnk_ext-charge_msg-msgv2 = h_achar30.
    e_mhnk_ext-charge_msg-msgv3 = e_mhnk_ext-waers.
    e_mhnk_ext-charge_msg-msgv4 = space.

  ELSE.
    e_mhnk_ext-charge_it = space.
  ENDIF.


ENDFORM.                               " CALC_CHARGES
