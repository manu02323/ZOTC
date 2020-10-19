*-------------------------------------------------------------------
***INCLUDE LF150F0A .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  ASSIGN_CREDIT_MEMOS
*&---------------------------------------------------------------------*
*       the dunning level in the key and the data section of each non
*       invoice related mhnd entry will set to the max dunning level of
*       the account. Therefore credit memos will reduce the amount of
*       the highest dunning level first.
*----------------------------------------------------------------------*
*      -->T_MHNK_EXT  MHNK entries                                     *
*      -->T_MHND_EXT  MHND entries                                     *
*----------------------------------------------------------------------*
FORM assign_credit_memos TABLES   t_mhnd_ext STRUCTURE mhnd_ext
                                  t_mhnk_ext STRUCTURE mhnk_ext
                         USING    i_mhnk_ext LIKE mhnk_ext.

* declaration
  DATA: h_mahsk    LIKE mhnk_ext-mahsk,
        h_mhnd_ext LIKE mhnd_ext,
        h_idx      TYPE p,  h_mhnk_ext LIKE mhnk_ext,
        h_verzn    LIKE mhnd-verzn.
  DATA  repeat_loop TYPE c.

  h_verzn = 0.
* reset the dunning level for each credit memo to the max dunning level
* of the mhnk entr
  h_mahsk = i_mhnk_ext-mahsk.
  repeat_loop = 'X'.
  data ld_repeat_count type i. ld_repeat_count = 0.
  while repeat_loop = 'X'.
    repeat_loop = space.
    data ld_loop_count type i. ld_loop_count = 0.
* read all credit memos disregard smahsk
    LOOP AT t_mhnd_ext WHERE laufd  = i_mhnk_ext-laufd AND
                             laufi  = i_mhnk_ext-laufi AND
                             koart  = i_mhnk_ext-koart AND
                             bukrs  = i_mhnk_ext-bukrs AND
                             kunnr  = i_mhnk_ext-kunnr AND
                             lifnr  = i_mhnk_ext-lifnr AND
                             cpdky  = i_mhnk_ext-cpdky AND
                             sknrze = i_mhnk_ext-sknrze AND
                             smaber = i_mhnk_ext-smaber AND
                             casgn  = space AND
                             cmemo  = 'X'.

      h_idx = sy-tabix.
      ld_loop_count = ld_loop_count + 1.
      IF T_MHND_EXT-REBZJ NE '0000'
         and not ( t_mhnd_ext-rebzg = t_mhnd_ext-belnr and
                   t_mhnd_ext-rebzz = t_mhnd_ext-buzei and
                   t_mhnd_ext-rebzj = t_mhnd_ext-gjahr ).
*     reassign the dunning levels for the credit memos w rbzg
        READ TABLE t_mhnd_ext INTO     h_mhnd_ext
                              WITH KEY belnr = t_mhnd_ext-rebzg
                                       gjahr = t_mhnd_ext-rebzj
                                       buzei = t_mhnd_ext-rebzz.
        IF sy-subrc = 0.
          IF h_mhnd_ext-cmemo ='X' AND h_mhnd_ext-casgn = space.
            repeat_loop = 'X'.
            CONTINUE.
          ENDIF.
          t_mhnd_ext-smahsk = h_mhnd_ext-smahsk.
          t_mhnd_ext-mahnn  = h_mhnd_ext-mahnn.
          t_mhnd_ext-smschl = h_mhnd_ext-smschl.
          t_mhnd_ext-xzalb  = h_mhnd_ext-xzalb.
          t_mhnd_ext-xfael  = h_mhnd_ext-xfael.
          if t_mhnd_ext-mansp <> h_mhnd_ext-mansp
              and t_mhnd_ext-mansp = space.
            IF 0 = 1. MESSAGE s730. ENDIF.
            PERFORM log_msg USING '730' t_mhnd_ext-belnr
                                        t_mhnd_ext-buzei
                                        h_mhnd_ext-mansp
                                        space.
            t_mhnd_ext-mansp  = h_mhnd_ext-mansp.
          ENDIF.
*       log the new dunning level for the credit memo w rebz
          IF 0 = 1. MESSAGE s829. ENDIF.
          PERFORM log_msg USING '829' t_mhnd_ext-blinf t_mhnd_ext-mahnn
                                      h_mhnd_ext-blinf space.
          IF t_mhnd_ext-shkzg = 'S' AND t_mhnd_ext-verzn > h_verzn.
            h_verzn = t_mhnd_ext-verzn.
          ENDIF.
        ELSE.
*       reassign the dunning levels for the credit memos w/o rbzg
*       when rbzg could not be found in t_mhnd_ext
     if t_mhnd_ext-verzn > 0.
          t_mhnd_ext-smahsk = i_mhnk_ext-smahsk.
          t_mhnd_ext-mahnn  = h_mahsk.
          t_mhnd_ext-xfael  = 'X'.
     endif.
          IF t_mhnd_ext-xzalb IS INITIAL.                       "1111000
            IF 0 = 1. MESSAGE s830. ENDIF.
          data ld_rebzg-blinf like h_mhnd_ext-blinf.
          ld_rebzg-blinf    = t_mhnd_ext-rebzg.
          ld_rebzg-blinf+10 = '/'.
          ld_rebzg-blinf+11 = t_mhnd_ext-rebzj.
          ld_rebzg-blinf+15 = '/'.
          ld_rebzg-blinf+16 = t_mhnd_ext-rebzz.
          PERFORM LOG_MSG USING '830' T_MHND_EXT-BLINF ld_rebzg-BLINF
                                      space space.

*       log the new dunning level for the credit memo w/o rebz
          IF 0 = 1. MESSAGE s828. ENDIF.
          PERFORM log_msg USING '828' t_mhnd_ext-blinf t_mhnd_ext-mahnn
                                      space space.
          ENDIF.                                                "1111000
        ENDIF.
      ELSE.
*     reassign the dunning levels for the credit memos w/o rbzg
        IF t_mhnd_ext-verzn > 0 AND t_mhnd_ext-xfael = 'X'.
          t_mhnd_ext-smahsk = i_mhnk_ext-smahsk.
          t_mhnd_ext-mahnn  = h_mahsk.
        ENDIF.
*     log the new dunning level for the credit memo w/o rebz
        IF t_mhnd_ext-xzalb IS INITIAL.                         "1111000
          IF 0 = 1. MESSAGE s828. ENDIF.
          PERFORM log_msg USING '828' t_mhnd_ext-blinf t_mhnd_ext-mahnn
                                      space space.
        ENDIF.                                                  "1111000
      ENDIF.
*   mark credit memo as assigned
      t_mhnd_ext-casgn  = 'X'.

*   update the internal table with the new values
      MODIFY t_mhnd_ext INDEX h_idx.
* In case MHNK-entry has diffrent currency, set cc-currency
      READ TABLE t_mhnk_ext INTO h_mhnk_ext WITH KEY
                                 koart  = t_mhnd_ext-koart
                                 bukrs  = t_mhnd_ext-bukrs
                                 kunnr  = t_mhnd_ext-kunnr
                                 lifnr  = t_mhnd_ext-lifnr
                                 cpdky  = t_mhnd_ext-cpdky
                                 sknrze = t_mhnd_ext-sknrze
                                 smaber = t_mhnd_ext-smaber
                                 smahsk = t_mhnd_ext-smahsk.
      IF sy-subrc = 0.
        IF h_mhnk_ext-waers <> t_mhnd_ext-waers.
          h_mhnk_ext-waers = h_mhnk_ext-hwaers.
        ENDIF.
        IF h_verzn <> 0 AND h_verzn > h_mhnk_ext-kverz.
          h_mhnk_ext-kverz = h_verzn.
        ENDIF.
        MODIFY t_mhnk_ext FROM h_mhnk_ext INDEX sy-tabix.
      ENDIF.

    ENDLOOP.
    ld_repeat_count = ld_repeat_count + 1.
    if ld_repeat_count > ld_loop_count.
      repeat_loop = space.
    endif.
  ENDWHILE.

ENDFORM.                    " ASSIGN_CREDIT_MEMOS
*&---------------------------------------------------------------------*
*&      Form  ASSIGN_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_FLDTAB  text                                             *
*      <--P_E_CHECKS  text                                             *
*----------------------------------------------------------------------*
FORM assign_fields TABLES   t_fldtab STRUCTURE fldtab
                   CHANGING e_checks LIKE checks.

  CLEAR e_checks.
  LOOP AT t_fldtab.
    CASE sy-tabix.
      WHEN '1'.
        ASSIGN (t_fldtab-fldna) TO <f1>.
      WHEN '2'.
        ASSIGN (t_fldtab-fldna) TO <f2>.
      WHEN '3'.
        ASSIGN (t_fldtab-fldna) TO <f3>.
      WHEN '4'.
        ASSIGN (t_fldtab-fldna) TO <f4>.
      WHEN '5'.
        ASSIGN (t_fldtab-fldna) TO <f5>.
      WHEN '6'.
        ASSIGN (t_fldtab-fldna) TO <f6>.
      WHEN '7'.
        ASSIGN (t_fldtab-fldna) TO <f7>.
      WHEN '8'.
        ASSIGN (t_fldtab-fldna) TO <f8>.
    ENDCASE.
    CASE t_fldtab-fldna(4).
      WHEN 'BSID'.
        e_checks-c_bsid = 'X'.                "Feldprüfung BSID
      WHEN 'BSIK'.
        e_checks-c_bsik = 'X'.                "Feldprüfung BSIK
      WHEN 'KNA1'.
        e_checks-c_kna1 = 'X'.                "Feldprüfung KNA1
      WHEN 'KNB1'.
        e_checks-c_knb1 = 'X'.                "Feldprüfung KNB1
      WHEN 'KNB5'.
        e_checks-c_knb5 = 'X'.                "Feldprüfung KNB5
      WHEN 'LFA1'.
        e_checks-c_lfa1 = 'X'.                "Feldprüfung LFA1
      WHEN 'LFB1'.
        e_checks-c_lfb1 = 'X'.                "Feldprüfung LFB1
      WHEN 'LFB5'.
        e_checks-c_lfb5 = 'X'.                "Feldprüfung LFB5
    ENDCASE.
  ENDLOOP.



ENDFORM.                    " ASSIGN_FIELDS
*&---------------------------------------------------------------------*
*&      Form  ASSIGN_SORT_FIELDS_MHND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_T021M  text                                              *
*----------------------------------------------------------------------*
FORM assign_sort_fields_mhnd USING i_t021m LIKE t021m.
* declaration
  DATA: h_char60(60) TYPE c,
        l_describe TYPE ref to cl_abap_typedescr.

* 1. MHNK Field
  IF i_t021m-tnam1 <> space AND i_t021m-feld1 <> space.
    CONCATENATE i_t021m-tnam1 i_t021m-feld1
                INTO h_char60 SEPARATED BY '-'.
    CONDENSE h_char60.
    ASSIGN (h_char60) TO <h1>.
    l_describe = cl_abap_typedescr=>describe_by_data( <H1> ).
    if l_describe->type_kind = 'P'.
      ASSIGN <H1> TO <P1>.
    else.
      ASSIGN <h1>+i_t021m-offs1(i_t021m-leng1) TO <p1>.
    endif.
  ENDIF.
* 2. MHNK Field
  IF i_t021m-tnam2 <> space AND i_t021m-feld2 <> space.
    CONCATENATE i_t021m-tnam2 i_t021m-feld2
                INTO h_char60 SEPARATED BY '-'.
    CONDENSE h_char60.
    ASSIGN (h_char60) TO <h1>.
    l_describe = cl_abap_typedescr=>describe_by_data( <H1> ).
    if l_describe->type_kind = 'P'.
      ASSIGN <H1> TO <P2>.
    else.
      ASSIGN <h1>+i_t021m-offs2(i_t021m-leng2) TO <p2>.
    endif.
  ENDIF.
* 3. MHNK Field
  IF i_t021m-tnam3 <> space AND i_t021m-feld3 <> space.
    CONCATENATE i_t021m-tnam3 i_t021m-feld3
                INTO h_char60 SEPARATED BY '-'.
    CONDENSE h_char60.
    ASSIGN (h_char60) TO <h1>.
    l_describe = cl_abap_typedescr=>describe_by_data( <H1> ).
    if l_describe->type_kind = 'P'.
      ASSIGN <H1> TO <P3>.
    else.
      ASSIGN <h1>+i_t021m-offs3(i_t021m-leng3) TO <p3>.
    endif.
  ENDIF.
* 4. MHNK Field
  IF i_t021m-tnam4 <> space AND i_t021m-feld4 <> space.
    CONCATENATE i_t021m-tnam4 i_t021m-feld4
                INTO h_char60 SEPARATED BY '-'.
    CONDENSE h_char60.
    ASSIGN (h_char60) TO <h1>.
    l_describe = cl_abap_typedescr=>describe_by_data( <H1> ).
    if l_describe->type_kind = 'P'.
      ASSIGN <H1> TO <P4>.
    else.
      ASSIGN <h1>+i_t021m-offs4(i_t021m-leng4) TO <p4>.
    endif.
  ENDIF.
* 5. MHNK Field
  IF i_t021m-tnam5 <> space AND i_t021m-feld5 <> space.
    CONCATENATE i_t021m-tnam5 i_t021m-feld5
                INTO h_char60 SEPARATED BY '-'.
    CONDENSE h_char60.
    ASSIGN (h_char60) TO <h1>.
    l_describe = cl_abap_typedescr=>describe_by_data( <H1> ).
    if l_describe->type_kind = 'P'.
      ASSIGN <H1> TO <P5>.
    else.
      ASSIGN <h1>+i_t021m-offs5(i_t021m-leng5) TO <p5>.
    endif.
  ENDIF.

ENDFORM.                    " ASSIGN_SORT_FIELDS_MHND
*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_CHECK_ACCOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_F150V  text                                                *
*      -->P_I_UPDATE  text                                             *
*----------------------------------------------------------------------*
FORM authority_check_account USING    i_f150v  LIKE f150v
                                      i_update LIKE boole-boole
                             CHANGING e_ok LIKE boole-boole.
* declaration
  DATA: actvt(2)   TYPE c,
        errtxt(25) TYPE c,
        a_err      LIKE sy-subrc VALUE 0.


  IF i_update = 'X'.
    actvt = '21'.errtxt = text-034.
  ELSE.
    actvt = '22'.errtxt = text-035.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'F_MAHN_BUK'
    ID 'FBTCH' FIELD actvt
    ID 'BUKRS' FIELD i_f150v-bukrs.
  IF sy-subrc NE 0.
    MESSAGE i216 WITH errtxt i_f150v-bukrs.
    a_err = 4.
  ENDIF.

  IF i_f150v-kunnr <> space AND a_err = 0.
    AUTHORITY-CHECK OBJECT 'F_MAHN_KOA'
      ID 'FBTCH' FIELD actvt
      ID 'KOART' FIELD 'D'.
    IF sy-subrc NE 0.
      MESSAGE i217 WITH errtxt 'D'.
      a_err = 4.
    ENDIF.
  ENDIF.

  IF i_f150v-lifnr <> space AND a_err = 0.
    AUTHORITY-CHECK OBJECT 'F_MAHN_KOA'
      ID 'FBTCH' FIELD actvt
      ID 'KOART' FIELD 'K'.
    IF sy-subrc NE 0.
      MESSAGE i217 WITH errtxt 'K'.
      a_err = 4.
    ENDIF.
  ENDIF.

  IF a_err <> 0.
    e_ok = space.
  ELSE.
    e_ok = 'X'.
  ENDIF.


ENDFORM.                    " AUTHORITY_CHECK_ACCOUNT
