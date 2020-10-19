*&---------------------------------------------------------------------*
*&  Include           ZOTCN0217B_RIBA_CITI_BANK_FORM
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0217B_RIBA_CITI_BANK_FORM                          *
* TITLE      :  Interface for RIBA Payments Italy Outbound CITI Bank   *
* DEVELOPER  :  Raghav Sureddi                                         *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    R3. D3_OTC_IDD_0217_RIBA_ITALY_Outbound-CITI Bank      *
*----------------------------------------------------------------------*
* DESCRIPTION:  This Interface generate the payment medium files from  *
*               SAP system with RIBA (payment method R) Payment method *
*               based on the due date of customer open invoices        *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
*18-Apr-2018  U033876   E1DK936113   Initial Development               *
*----------------------------------------------------------------------*
*16-May-2018  U033876   E1DK936113   Defect 6115 :Fixes to file name   *
*----------------------------------------------------------------------*
*14-Aug-2018  ASK       E1DK938336   Defect 6882 :Fixes to decimal place*
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_F4_HELP_IDEN
*&---------------------------------------------------------------------*
*       F4 help on identification
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_f4_help_iden .
  DATA: lv_xf4_c1 TYPE char1,                    " Xf4_c1 of type CHAR1
        li_laufk  TYPE STANDARD TABLE OF ilaufk, " Run indicator transfer structure in payment transactions
        lwa_laufk TYPE ilaufk.                   " Run indicator transfer structure in payment transactions
  CONSTANTS: lc_i     TYPE token  VALUE 'I',           " Sign for Range Tables
             lc_laufd TYPE char12 VALUE 'F110V-LAUFD'. " Laufd of type CHAR12
  CLEAR: li_laufk[] , lwa_laufk.
  lwa_laufk-laufk = space.
  lwa_laufk-sign  = lc_i.
  APPEND lwa_laufk TO  li_laufk.
  CALL FUNCTION 'F4_ZAHLLAUF'
    EXPORTING
      f1typ            = lc_i
      f2nme            = lc_laufd
    IMPORTING
      laufd            = p_laufd
      laufi            = p_laufi
      nothing_selected = lv_xf4_c1
    TABLES
      laufk            = li_laufk.
  IF lv_xf4_c1 IS INITIAL.
    LEAVE TO SCREEN 0.
  ENDIF. " IF lv_xf4_c1 IS INITIAL
ENDFORM. " F_F4_HELP_IDEN
*&---------------------------------------------------------------------*
*&      Form  F_GET_PAYMENT_DATA
*&---------------------------------------------------------------------*
*      Get the payement details from
*----------------------------------------------------------------------*
*      -->P_P_LAUFD  text
*      -->P_P_LAUFI  text
*----------------------------------------------------------------------*
FORM f_get_payment_data  USING    fp_laufd TYPE laufd " Date on Which the Program Is to Be Run
                                  fp_laufi TYPE laufi " Additional Identification
                         CHANGING fp_i_reguh TYPE ty_t_reguh
                                  fp_i_regup TYPE ty_t_regup
                                  fp_i_kna1  TYPE ty_t_kna1
                                  fp_i_knb1  TYPE ty_t_knb1
                                  fp_i_t001  TYPE ty_t_t001
                                  fp_i_adrc  TYPE ty_t_adrc.

  DATA: li_reguh TYPE ty_t_reguh,
        li_regup TYPE ty_t_regup.

  SELECT laufd " Date on Which the Program Is to Be Run
         laufi " Additional Identification
         zbukr " Paying company code
         lifnr " Account Number of Vendor or Creditor
         kunnr " Customer Number
         vblnr " Document Number of the Payment Document
         waers " Currency Key
         name1 " Name 1
         name2 " Name 2
         pstlz " Postal Code
         ort01 " City
         stras " House number and street
         land1 " Country Key
         zaldt " Posting date of the payment document
         ubknt " Our account number at the bank
         ubnkl " Bank number of our bank
         valut " Value Date
         rwbtr " Amount Paid in the Payment Currency
     FROM reguh INTO TABLE fp_i_reguh
                                         WHERE laufd = fp_laufd
                                           AND laufi = fp_laufi
                                           AND xvorl NE abap_true.
  IF sy-subrc = 0.
    SORT fp_i_reguh BY laufd laufi .

    SELECT   laufd " Date on Which the Program Is to Be Run
             laufi " Additional Identification
             vblnr " Document Number of the Payment Document
             bukrs " Company Code
             belnr " Accounting Document Number
             rebzg " Number of the Invoice the Transaction Belongs to
      FROM regup INTO TABLE fp_i_regup
        FOR ALL ENTRIES IN fp_i_reguh
                                         WHERE laufd = fp_laufd
                                           AND laufi = fp_laufi
                                           AND vblnr = fp_i_reguh-vblnr
                                           AND xvorl NE abap_true.
    IF sy-subrc = 0.
      SORT fp_i_regup BY laufd laufi vblnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF sy-subrc = 0

  IF fp_i_reguh[] IS NOT INITIAL.
    CLEAR: li_reguh[].
    li_reguh[] = fp_i_reguh[].

    SORT li_reguh BY kunnr.
    DELETE ADJACENT DUPLICATES FROM li_reguh COMPARING kunnr.

    IF li_reguh[] IS NOT INITIAL.
      SELECT kunnr " Customer Number
             stcd1 " Tax Number 1
             FROM kna1 INTO TABLE fp_i_kna1
             FOR ALL ENTRIES IN li_reguh
             WHERE kunnr = li_reguh-kunnr.
      IF sy-subrc = 0.
        SORT fp_i_kna1 BY kunnr .
      ENDIF. " IF sy-subrc = 0
      SELECT kunnr " Customer Number
             bukrs " Company Code
             kverm " Memo
             FROM knb1 INTO TABLE fp_i_knb1
             FOR ALL ENTRIES IN li_reguh
             WHERE kunnr = li_reguh-kunnr.
      IF sy-subrc = 0.
        SORT fp_i_knb1 BY kunnr bukrs.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF li_reguh[] IS NOT INITIAL

*for BUKRS
    CLEAR: li_reguh[].
    li_reguh[] = fp_i_reguh[].

    SORT li_reguh BY zbukr.
    DELETE ADJACENT DUPLICATES FROM li_reguh COMPARING zbukr.

    IF li_reguh[] IS NOT INITIAL.
      SELECT bukrs " Company Code
             butxt " Name of Company Code or Company
             adrnr " Address
             FROM t001 INTO TABLE fp_i_t001
             FOR ALL ENTRIES IN li_reguh
             WHERE bukrs = li_reguh-zbukr.
      IF sy-subrc = 0.
        SORT fp_i_t001 BY bukrs adrnr .
        SELECT addrnumber " Address number
               name1      " Name 1
               street     " Street
               house_num1 " House Number
               post_code1 " City postal code
               city1      " City
               region     " Region (State, Province, County)
               sort2      " Search Term 2
               FROM adrc INTO TABLE fp_i_adrc
               FOR ALL ENTRIES IN fp_i_t001
               WHERE addrnumber = fp_i_t001-adrnr.
        IF sy-subrc = 0.
          SORT fp_i_adrc BY addrnumber.
        ENDIF. " IF sy-subrc = 0

      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF li_reguh[] IS NOT INITIAL

  ENDIF. " IF fp_i_reguh[] IS NOT INITIAL

ENDFORM. " F_GET_PAYMENT_DATA
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY1_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
* This perform hide/ unhide selection screen parameters based on user
* selection
*----------------------------------------------------------------------*
FORM f_modify1_screen .
  LOOP AT SCREEN .
    IF screen-group1 = c_mi4.
      screen-input = c_zero.
      MODIFY SCREEN.
    ENDIF. " IF screen-group1 = c_mi4
    IF rb_pres EQ abap_true.
      CLEAR: p_ahdr.
      IF screen-group1 = c_mi6
        OR screen-group1 = c_mi9.
        screen-active = c_zero.
        screen-input = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_mi6
    ELSEIF rb_app EQ abap_true.
      CLEAR: p_phdr.
      IF screen-group1 = c_mi3
        OR screen-group1 = c_mi9.
        screen-active = c_zero.
        screen-input = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_mi3
      p_ahdr = gv_pfile.
      IF screen-name = c_file_f.
        screen-input = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-name = c_file_f
    ELSEIF rb_pres NE abap_true
      AND rb_app NE abap_true.
      rb_pres = abap_true.
      CLEAR: p_ahdr.
    ENDIF. " IF rb_pres EQ abap_true
*
*      IF rb_pres EQ abap_true.
*        CLEAR: p_ahdr.
*        IF screen-group1 = c_mi6
*          OR screen-group1 = c_mi9.
*          screen-active = c_zero.
*          screen-input = c_zero.
*          MODIFY SCREEN.
*        ENDIF. " IF screen-group1 = c_mi6
*      ELSEIF rb_app EQ abap_true.
*        CLEAR: p_phdr.
*        IF screen-group1 = c_mi3
*          OR screen-group1 = c_mi9.
*          screen-active = c_zero.
*          screen-input = c_zero.
*          MODIFY SCREEN.
*        ENDIF. " IF screen-group1 = c_mi3
*        p_ahdr = gv_pfile.
*        IF screen-name = c_file_f.
*          screen-input = c_zero.
*          MODIFY SCREEN.
*        ENDIF. " IF screen-name = c_file_f
*      ENDIF. " IF rb_pres EQ abap_true
  ENDLOOP. " LOOP AT SCREEN
ENDFORM. " F_MODIFY1_SCREEN
*&---------------------------------------------------------------------*
*&      Form  F_FILL_REC_STRC
*&---------------------------------------------------------------------*
*       Fill the reord structures
*----------------------------------------------------------------------*
*      -->P_I_REGUH  text
*      -->P_I_REGUP  text
*      -->P_I_KNA1  text
*      -->P_I_KNB1  text
*      <--P_WA_HEADER  text
*      <--P_WA_14_DISP  text
*      <--P_WA_20_ODESC  text
*      <--P_WA_30_DB_INFO  text
*      <--P_WA_40_DB_ADD  text
*      <--P_WA_50_DB_NOTES  text
*      <--P_WA_51_PIR_INFO  text
*      <--P_WA_70_CK_DETAIL  text
*      <--P_WA_TRAILER  text
*----------------------------------------------------------------------*
FORM f_fill_rec_strc  USING    fp_i_reguh TYPE ty_t_reguh
                               fp_i_regup TYPE ty_t_regup
                               fp_i_kna1  TYPE ty_t_kna1
                               fp_i_knb1  TYPE ty_t_knb1
                               fp_i_t001  TYPE ty_t_t001
                               fp_i_adrc  TYPE ty_t_adrc
                  CHANGING       fp_wa_header      TYPE ty_header
                                 fp_wa_14_disp     TYPE ty_14_disp
                                 fp_wa_20_odesc    TYPE ty_20_odesc
                                 fp_wa_30_db_info  TYPE ty_30_db_info
                                 fp_wa_40_db_add   TYPE ty_40_db_add
                                 fp_wa_50_db_notes TYPE ty_50_db_notes
                                 fp_wa_51_pir_info TYPE ty_51_pir_info
                                 fp_wa_70_ck_detail TYPE ty_70_ck_detail
                                 fp_wa_trailer     TYPE ty_trailer
                                 fp_i_final        TYPE ty_t_final.
*Begin of change for Defect 5474 by U033876
  DATA: lv_amnt_num(13) TYPE p,    " Amnt_num(13) of type Packed Number
        lv_trans_amnt TYPE numc13, " Numerical 13-digit
        lv_char_rwbtr TYPE char18. " Char_rwbtr of type CHAR18
*End of change for Defect 5474 by U033876
  DATA: li_reguh_tmp TYPE ty_t_reguh,
        lwa_final TYPE ty_final,
        lwa_reguh TYPE ty_reguh,
        lwa_regup TYPE ty_regup,
        lwa_kna1  TYPE ty_kna1,
        lwa_knb1  TYPE ty_knb1,
        lwa_t001  TYPE ty_t001,
        lwa_adrc  TYPE ty_adrc,
        lv_tot_trans TYPE numc7,      " Tot_trans of type Integers
        lv_t_neg_rwbtr   TYPE numc15, " Amount Paid in the Payment Currency
        lv_tot_neg TYPE numc15,       " Tot_neg of type CHAR13
        lv_disp_no TYPE numc7,        " StADUEV: Seven-Digit Value
        lv_tot_no_rec TYPE numc7.     " StADUEV: Seven-Digit Value
  CONSTANTS:lc_ib       TYPE char2 VALUE 'IB',                  " Ib of type CHAR2
            lc_ef       TYPE char2 VALUE 'EF',                  " Ib of type CHAR2
            lc_14       TYPE char2 VALUE '14',                  " 14 of type CHAR2
            lc_20       TYPE char2 VALUE '20',                  " 20 of type CHAR2
            lc_30       TYPE char2 VALUE '30',                  " 30 of type CHAR2
            lc_40       TYPE char2 VALUE '40',                  " 40 of type CHAR2
            lc_50       TYPE char2 VALUE '50',                  " 50 of type CHAR2
            lc_51       TYPE char2 VALUE '51',                  " 51 of type CHAR2
            lc_70       TYPE char2 VALUE '70',                  " 70 of type CHAR2
            lc_neg      TYPE char1 VALUE '-',                   " Neg of type CHAR1
            lc_cc_code  TYPE char1 VALUE 'E',                   " Cc_code of type CHAR1
            lc_file     TYPE char4 VALUE '0217',                " File of type CHAR20
            lc_tot_pos_amt TYPE char15 VALUE '000000000000000'. " Tot_pos_amt of type CHAR15

  CLEAR: li_reguh_tmp[], lwa_final, fp_wa_header, fp_wa_14_disp, fp_wa_20_odesc,fp_wa_30_db_info,
         fp_wa_40_db_add, fp_wa_50_db_notes, fp_wa_51_pir_info, fp_wa_70_ck_detail,
         fp_wa_trailer,  fp_i_final[], lv_tot_trans,lv_t_neg_rwbtr, lv_tot_neg.

  li_reguh_tmp[] = fp_i_reguh[].
  DELETE li_reguh_tmp WHERE vblnr = space.
  fp_wa_header-filler_s         = space.
  fp_wa_header-rec_type         = lc_ib.
  fp_wa_header-sp_sia_code      = space.


  READ TABLE li_reguh_tmp INTO lwa_reguh
                       WITH KEY laufd = p_laufd
                                laufi = p_laufi  BINARY SEARCH.
  IF sy-subrc = 0.
    fp_wa_header-ob_abi_code   = lwa_reguh-ubnkl+0(5).

    CONCATENATE lwa_reguh-zaldt+6(2)
                lwa_reguh-zaldt+4(2)
                lwa_reguh-zaldt+2(2) INTO fp_wa_header-erdat.
  ENDIF. " IF sy-subrc = 0

*Begin of change for Defect 5474 by U033876
  CONCATENATE lc_file sy-datum sy-uzeit INTO fp_wa_header-file_name SEPARATED BY c_uscore.
*End of change for Defect 5474 by U033876
  fp_wa_header-filler_m  = space.
*RID Collection Type
  fp_wa_header-rid_coll_typ = space.
*  Currency Code
  fp_wa_header-curr_code = lc_cc_code.

  CONCATENATE space space  INTO fp_wa_header-filler_e RESPECTING BLANKS.
  lwa_final-str = fp_wa_header.
  APPEND lwa_final TO fp_i_final.
  CLEAR: lwa_final.

  CLEAR: lv_disp_no.
  SORT fp_i_reguh BY vblnr ASCENDING.
  LOOP AT fp_i_reguh INTO lwa_reguh WHERE vblnr NE space.
* for 14 Disposition & Ordering Customer Information
    fp_wa_14_disp-filler_s  = space.
    fp_wa_14_disp-rec_type  = lc_14.

*    fp_wa_14_disp-disp_no   = lwa_reguh-vblnr+3(7). "Move last 7 char
    lv_disp_no = lv_disp_no + 1.
    fp_wa_14_disp-disp_no   = lv_disp_no.

    fp_wa_14_disp-filler_m1 = space.
*Maturity Date
    CONCATENATE lwa_reguh-valut+6(2)
                lwa_reguh-valut+4(2)
                lwa_reguh-valut+2(2) INTO  fp_wa_14_disp-matu_date.
*Reason

    fp_wa_14_disp-reason      = '00000'.
*Begin of change for Defect 5474 by U033876
*    fp_wa_14_disp-trans_amt   = lwa_reguh-rwbtr.
    CLEAR: lv_amnt_num, lv_trans_amnt,lv_char_rwbtr.
    lv_char_rwbtr = lwa_reguh-rwbtr.
* Begin of Defect 6882
    REPLACE ALL OCCURRENCES OF ',' IN lv_char_rwbtr WITH space.
    REPLACE ALL OCCURRENCES OF '.' IN lv_char_rwbtr WITH space.
    CONDENSE lv_char_rwbtr.

    fp_wa_14_disp-trans_amt = lv_char_rwbtr.
* End of Defect 6882

* Begin of comment for Defect 6882
**    CALL FUNCTION 'MOVE_CHAR_TO_NUM'
**      EXPORTING
**        chr             = lv_char_rwbtr
**      IMPORTING
**        num             = lv_amnt_num
**      EXCEPTIONS
**        convt_no_number = 1
**        convt_overflow  = 2.
*    IF  sy-subrc = 0.
*
**      WRITE lv_amnt_num TO lv_trans_amnt.
*      lv_trans_amnt = lv_amnt_num.
*      fp_wa_14_disp-trans_amt =  lv_trans_amnt.
*
*      fp_wa_14_disp-trans_amt = lv_char_rwbtr.
*    ELSE. " ELSE -> IF sy-subrc = 0
*      CLEAR: fp_wa_14_disp-trans_amt.
*    ENDIF. " IF sy-subrc = 0
* End  of comment for Defect 6882

*End of change for Defect 5474 by U033876
    fp_wa_14_disp-sign        = lc_neg.
    fp_wa_14_disp-ob_abi_code = lwa_reguh-ubnkl+0(5).
    fp_wa_14_disp-ob_cab_code = lwa_reguh-ubnkl+5(5).
    fp_wa_14_disp-cr_accnt_no = lwa_reguh-ubknt.
    READ TABLE fp_i_knb1 INTO lwa_knb1
                              WITH KEY kunnr = lwa_reguh-kunnr
                                       bukrs = lwa_reguh-zbukr BINARY SEARCH.
    IF sy-subrc = 0.
      fp_wa_14_disp-db_abi_code = lwa_knb1-kverm+0(5).
      fp_wa_14_disp-db_cab_code = lwa_knb1-kverm+5(5).
    ENDIF. " IF sy-subrc = 0

    fp_wa_14_disp-filler_m2   = '000000000000'.
    fp_wa_14_disp-op_sia_code = space.
    fp_wa_14_disp-code_type   = '4'.
    fp_wa_14_disp-deb_id      = lwa_reguh-kunnr.
    fp_wa_14_disp-filler_e    = space.
    fp_wa_14_disp-curr_code   = lc_cc_code.

    lwa_final-str = fp_wa_14_disp.
    APPEND lwa_final TO fp_i_final.
    lv_tot_trans     = lv_tot_trans + 1.
    lv_t_neg_rwbtr   = lv_t_neg_rwbtr + fp_wa_14_disp-trans_amt.
    CLEAR: lwa_final.

*Record 20 - Orderer Description  -  will repeat for each payment document
    fp_wa_20_odesc-filler_s       = space.
    fp_wa_20_odesc-rec_type       = lc_20.
    fp_wa_20_odesc-disp_no        = fp_wa_14_disp-disp_no.

    READ TABLE fp_i_t001 INTO lwa_t001
                          WITH KEY bukrs = lwa_reguh-zbukr BINARY SEARCH.
    IF sy-subrc = 0.
      READ TABLE fp_i_adrc INTO lwa_adrc
                          WITH KEY addrnumber = lwa_t001-adrnr BINARY SEARCH.

      IF sy-subrc = 0.
        fp_wa_20_odesc-ord_cust_desc1 = lwa_adrc-name1.

        CONCATENATE lwa_adrc-street
                    lwa_adrc-house_num1 INTO
                      fp_wa_20_odesc-ord_cust_desc2 SEPARATED BY space .

        CONCATENATE lwa_adrc-post_code1
                    lwa_adrc-city1
                    lwa_adrc-region INTO
                    fp_wa_20_odesc-ord_cust_desc3 SEPARATED BY space.
        fp_wa_20_odesc-ord_cust_desc4 =  lwa_adrc-sort2.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0
    fp_wa_20_odesc-filler_e       = space.

    lwa_final-str = fp_wa_20_odesc.
    APPEND lwa_final TO fp_i_final.
    CLEAR: lwa_final.

*Record 30 - Debtor Information

    fp_wa_30_db_info-filler_s   = space.
    fp_wa_30_db_info-rec_type      = lc_30 .
    fp_wa_30_db_info-disp_no       = fp_wa_14_disp-disp_no.
    fp_wa_30_db_info-deb_name1     = lwa_reguh-name1.
    fp_wa_30_db_info-deb_name2     = lwa_reguh-name2.
    READ TABLE fp_i_kna1 INTO lwa_kna1
                         WITH KEY kunnr = lwa_reguh-kunnr BINARY SEARCH.
    IF  sy-subrc = 0.
      fp_wa_30_db_info-deb_fisc_code =  lwa_kna1-stcd1.
    ENDIF. " IF sy-subrc = 0
    fp_wa_30_db_info-filler_e      = space.

    lwa_final-str = fp_wa_30_db_info.
    APPEND lwa_final TO fp_i_final.
    CLEAR: lwa_final.

*Record 40 - Debtor Address -  will repeat for each payment document

    fp_wa_40_db_add-filler_s     = space.
    fp_wa_40_db_add-rec_type     = lc_40.
    fp_wa_40_db_add-disp_no      = fp_wa_14_disp-disp_no.
    fp_wa_40_db_add-deb_str_add  = lwa_reguh-stras.
    fp_wa_40_db_add-deb_pos_code = lwa_reguh-pstlz.
    fp_wa_40_db_add-deb_city     = lwa_reguh-ort01.
    fp_wa_40_db_add-deb_bank     = space.

    lwa_final-str = fp_wa_40_db_add.
    APPEND lwa_final TO fp_i_final.
    CLEAR: lwa_final.

*Record 50 - Notes for Debtor -  will repeat for each payment document

    fp_wa_50_db_notes-filler_s      = space.
    fp_wa_50_db_notes-rec_type      = lc_50.
    fp_wa_50_db_notes-disp_no       = fp_wa_14_disp-disp_no.
    READ TABLE fp_i_regup INTO lwa_regup
                          WITH KEY laufd =  lwa_reguh-laufd
                                   laufi =  lwa_reguh-laufi
                                   vblnr =  lwa_reguh-vblnr
                                   BINARY SEARCH.
    IF sy-subrc = 0.
      fp_wa_50_db_notes-pay_det1      =  lwa_regup-belnr.
      fp_wa_50_db_notes-pay_det2      =  lwa_regup-rebzg.
    ENDIF. " IF sy-subrc = 0


    fp_wa_50_db_notes-filler_m      = space.
    IF lwa_kna1-stcd1 IS NOT INITIAL.
      fp_wa_50_db_notes-cre_fisc_code = lwa_kna1-stcd1.
    ENDIF. " IF lwa_kna1-stcd1 IS NOT INITIAL
    fp_wa_50_db_notes-filler_e      = space.

    lwa_final-str = fp_wa_50_db_notes.
    APPEND lwa_final TO fp_i_final.
    CLEAR: lwa_final.

*Record 51 - Province Internal Revenue Office Information -  will repeat for each payment document

    fp_wa_51_pir_info-filler_s      = space.
    fp_wa_51_pir_info-rec_type      = lc_51.
    fp_wa_51_pir_info-disp_no       = fp_wa_14_disp-disp_no.
    fp_wa_51_pir_info-trans_ref_no  = lwa_reguh-vblnr.
    fp_wa_51_pir_info-ord_par_name  = lwa_t001-butxt.
    fp_wa_51_pir_info-pir_office    = space.
    fp_wa_51_pir_info-auth_no       = '0000000000'.
    fp_wa_51_pir_info-auth_date     = '000000'.
    fp_wa_51_pir_info-filler_e      = space.

    lwa_final-str = fp_wa_51_pir_info.
    APPEND lwa_final TO fp_i_final.
    CLEAR: lwa_final.

*Record 70 - Control Key Detail  -  will repeat for each payment document

    fp_wa_70_ck_detail-filler_s       = space.
    fp_wa_70_ck_detail-rec_type       = lc_70.
    fp_wa_70_ck_detail-disp_no        = fp_wa_14_disp-disp_no.
    fp_wa_70_ck_detail-res_of_cred    = space.
    fp_wa_70_ck_detail-cc_cred_bank   = space.
    fp_wa_70_ck_detail-cred_bank_name = space.
    fp_wa_70_ck_detail-cred_acc_no    = space.
    fp_wa_70_ck_detail-cred_acc_name  = space.
    fp_wa_70_ck_detail-f_riba_flag    = space.
    fp_wa_70_ck_detail-filler_m       = space.
    fp_wa_70_ck_detail-deb_docu_type  = '1'.
    fp_wa_70_ck_detail-pay_notif      = '1'.
    fp_wa_70_ck_detail-print_notif    = '4'.
    fp_wa_70_ck_detail-filler_e       = space.

    lwa_final-str = fp_wa_70_ck_detail.
    APPEND lwa_final TO fp_i_final.
    CLEAR: lwa_final.

  ENDLOOP. " LOOP AT fp_i_reguh INTO lwa_reguh WHERE vblnr NE space

  fp_wa_trailer-filler_s         = space.
  fp_wa_trailer-rec_type         = lc_ef.
  fp_wa_trailer-sp_sia_code      = space.

  READ TABLE li_reguh_tmp INTO lwa_reguh
                       WITH KEY laufd = p_laufd
                                laufi = p_laufi.
  IF sy-subrc = 0.
    fp_wa_trailer-ob_abi_code   = lwa_reguh-ubnkl+0(5).

    CONCATENATE lwa_reguh-zaldt+6(2)
                lwa_reguh-zaldt+4(2)
                lwa_reguh-zaldt+2(2) INTO fp_wa_trailer-erdat.
  ENDIF. " IF sy-subrc = 0


  CONCATENATE lc_file sy-datum sy-uzeit INTO fp_wa_trailer-file_name SEPARATED BY c_uscore.

  fp_wa_trailer-filler_m1         = space.
  fp_wa_trailer-tot_no_disp       = lv_tot_trans.
  lv_tot_neg = lv_t_neg_rwbtr.
  fp_wa_trailer-tot_neg_amts      = lv_tot_neg.
  fp_wa_trailer-tot_pos_amts      = lc_tot_pos_amt.
  DESCRIBE TABLE fp_i_final LINES lv_tot_no_rec.
  lv_tot_no_rec = lv_tot_no_rec + 1. "(include trailer record).
  fp_wa_trailer-no_of_recds       = lv_tot_no_rec.
  fp_wa_trailer-filler_m2         = space.
  fp_wa_trailer-rid_coll_typ      = space.
*  Currency Code
  fp_wa_trailer-curr_code         = lc_cc_code.
*Filler end
  fp_wa_trailer-filler_e          = space.

  lwa_final-str = fp_wa_trailer.
  APPEND lwa_final TO fp_i_final.
  CLEAR: lwa_final,lv_tot_neg, lv_t_neg_rwbtr,lv_tot_trans.
  CLEAR: fp_wa_header, fp_wa_14_disp, fp_wa_20_odesc ,
         fp_wa_30_db_info ,fp_wa_40_db_add , fp_wa_50_db_notes ,
         fp_wa_51_pir_info, fp_wa_70_ck_detail ,fp_wa_trailer   .
ENDFORM. " F_FILL_REC_STRC
*&---------------------------------------------------------------------*
*&      Form  F_WRITE_APP_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FP_GV_FILEPATH  File Path
*      -->FP_I_FINAL      Final Internal Table
*      <--FP_I_LOG        Log Table
*----------------------------------------------------------------------*
FORM f_write_app_data  USING    fp_gv_filepath TYPE localfile " Local file for upload/download
                                fp_i_final TYPE ty_t_final
                       CHANGING fp_i_log TYPE ty_t_log.

*&--Local Data Declaration
  DATA:
        lwa_log       TYPE ty_log,  " Log Data
        lv_data       TYPE string,
        lv_len        TYPE i,       " Len of type Integers
        lv_menge      TYPE char20,  " Menge of type CHAR20
        lv_string     TYPE char256, " String of type CHAR256
        lv_count      TYPE sytabix, " Records Count
        lv_path       TYPE string,  "Path
        lv_file       TYPE string,  "File name
        lv_file_path  TYPE string.  "File name with file path

  FIELD-SYMBOLS: <lfs_final>    TYPE ty_final.

*&--Build File Path
  CLEAR: lv_path.
  lv_path = fp_gv_filepath .
  WRITE:/ 'Files written to path:'(051), lv_path.

*&--Build File Name
  CONCATENATE c_filename
              sy-datum+0(4)
              sy-datum+4(2)
              sy-datum+6(2)
              c_uscore
              sy-uzeit+0(2)
              sy-uzeit+2(2)
              sy-uzeit+4(2)
    INTO lv_file.
  CONDENSE lv_file.

*&--Build File name with file path
  CONCATENATE lv_path
              lv_file
              c_fileext
    INTO lv_file_path.
  CONDENSE lv_file_path.

* && -- Open dataset to read
  OPEN DATASET lv_file_path FOR INPUT IN TEXT MODE ENCODING DEFAULT IGNORING CONVERSION ERRORS. " Set as Ready for Input
  IF sy-subrc IS INITIAL.
*&--Read application directory file
    READ DATASET lv_file_path INTO lv_string ACTUAL LENGTH lv_len.
    IF sy-subrc IS INITIAL.
      IF lv_string IS NOT INITIAL.
*&--If data already exist in the file message will be displayed
        lwa_log-msgtyp = c_msgtyp_i.
        lwa_log-msgtxt = 'Existing file has been overwritten.'(021).
        CONDENSE lwa_log-msgtxt.
        APPEND lwa_log TO fp_i_log.
        CLEAR lwa_log.
      ENDIF. " IF lv_string IS NOT INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL
*&--Close dataset
  CLOSE DATASET lv_file_path.


* && -- Open dataset to write
  OPEN DATASET lv_file_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT          " Output type
                                                      WITH WINDOWS LINEFEED . " Output type
  IF sy-subrc IS INITIAL.

    LOOP AT fp_i_final ASSIGNING <lfs_final>.
      CLEAR: lv_data.
      lv_data = <lfs_final>-str.
*&--Transfer string data to application file
      TRANSFER lv_data TO lv_file_path LENGTH 120.
    ENDLOOP. " LOOP AT fp_i_final ASSIGNING <lfs_final>

*&--Calculate the number of records written in file
    DESCRIBE TABLE fp_i_final LINES lv_count.
    WRITE lv_count TO lwa_log-msgtxt.
    CONDENSE lwa_log-msgtxt.

*&--Populate Log table for success message
    lwa_log-msgtyp = c_msgtyp_s.
    CONCATENATE lwa_log-msgtxt
                'number of records written.'(013)
                INTO lwa_log-msgtxt
                SEPARATED BY space.
    CONDENSE lwa_log-msgtxt.

    APPEND lwa_log TO fp_i_log.
    CLEAR lwa_log.

    lwa_log-msgtyp = c_msgtyp_s.
    CLEAR lv_count.
    lv_count = strlen( lv_file_path ).
    CONCATENATE 'File written at'(014)
                lv_file_path+0(lv_count)
                INTO lwa_log-msgtxt
                SEPARATED BY space.
    CONDENSE lwa_log-msgtxt.

    APPEND lwa_log TO fp_i_log.
    CLEAR lwa_log.
  ELSE. " ELSE -> IF sy-subrc IS INITIAL

*&--Populate Log table with error message
    lwa_log-msgtyp = c_msgtyp_e.
    lwa_log-msgtxt = 'Error in creating file.'(015).
    APPEND lwa_log TO fp_i_log.
    CLEAR lwa_log.
  ENDIF. " IF sy-subrc IS INITIAL

*&--Close dataset
  CLOSE DATASET lv_file_path.

ENDFORM. " F_WRITE_APP_DATA
*&---------------------------------------------------------------------*
*&      Form  F_WRITE_PRES_DATA
*&---------------------------------------------------------------------*
*       Write Data in Presentation Server
*----------------------------------------------------------------------*
*      -->FP_I_FINAL   Final Internal Table
*      <--FP_P_PHDR    File Path
*      <--FP_I_DATA    Data Table
*      <--FP_I_LOG     Log Table
*----------------------------------------------------------------------*
FORM f_write_pres_data  USING   fp_i_final TYPE ty_t_final
                        CHANGING fp_p_phdr TYPE localfile " Local file for upload/download
                                 fp_i_data TYPE ty_t_data
                                 fp_i_log  TYPE ty_t_log.
*&--Local Data Declaration
  DATA:
        lwa_log     TYPE ty_log,  " Log Data
        lwa_data    TYPE ty_data, " Pipe delimited data
        lv_filename TYPE string,  " File Name
        lv_data     TYPE char120, " Data
        lv_count    TYPE sytabix, " Index of Internal Tables
        lv_space TYPE string.
  FIELD-SYMBOLS: <lfs_final> TYPE ty_final.
  CONSTANTS: lc_120 TYPE sytabix VALUE '120'. " Index of Internal Tables
  IF fp_p_phdr IS NOT INITIAL.
*&--Populate file name
    lv_filename = fp_p_phdr.
  ENDIF. " IF fp_p_phdr IS NOT INITIAL

  CLEAR: lv_space.
  lv_space = cl_abap_conv_in_ce=>uccp( '00a0' ).
  LOOP AT fp_i_final ASSIGNING <lfs_final>.
    CLEAR: lv_data, lv_count.
    lv_data = <lfs_final>-str.

    lv_count = strlen( lv_data ).
    WHILE lv_count < lc_120. "check the length
      CONCATENATE  lv_data lv_space INTO lv_data . "add spaces at the end
      lv_count = strlen( lv_data ).
    ENDWHILE.
    lwa_data-data = lv_data.
    APPEND lwa_data TO fp_i_data.
    CLEAR: lwa_data.
  ENDLOOP. " LOOP AT fp_i_final ASSIGNING <lfs_final>

*&--Call method to download the file
  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename                = lv_filename
      filetype                = c_asc
      confirm_overwrite       = abap_true
    CHANGING
      data_tab                = fp_i_data
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.

  IF sy-subrc IS INITIAL.
    CLEAR: lv_count.
    DESCRIBE TABLE fp_i_data LINES lv_count.

    WRITE lv_count TO lwa_log-msgtxt.
    CONDENSE lwa_log-msgtxt.

*&--Populate Log table for success message
    lwa_log-msgtyp = c_msgtyp_s.
    CONCATENATE lwa_log-msgtxt
                'number of records written.'(013)
    INTO lwa_log-msgtxt
    SEPARATED BY space.
    CONDENSE lwa_log-msgtxt.

    APPEND lwa_log TO fp_i_log.
    CLEAR lwa_log.

    lwa_log-msgtyp = c_msgtyp_s.
    CLEAR lv_count.
    lv_count = strlen( fp_p_phdr ).
    CONCATENATE 'File written at'(014)
                fp_p_phdr+0(lv_count)
                INTO lwa_log-msgtxt
                SEPARATED BY space.
    CONDENSE lwa_log-msgtxt.

    APPEND lwa_log TO fp_i_log.
    CLEAR lwa_log.
  ELSE. " ELSE -> IF sy-subrc IS INITIAL

*&--Populate Log table for error message
    lwa_log-msgtyp = c_msgtyp_e.
    lwa_log-msgtxt = 'Error in creating file.'(015).
    APPEND lwa_log TO fp_i_log.
    CLEAR lwa_log.
  ENDIF. " IF sy-subrc IS INITIAL
ENDFORM. " F_WRITE_PRES_DATA
*&---------------------------------------------------------------------*
*&      Form  F_WRITE_LOG
*&---------------------------------------------------------------------*
*       Write Log Data
*----------------------------------------------------------------------*
*      -->FP_I_LOG  Log Table
*----------------------------------------------------------------------*
FORM f_write_log  USING    fp_i_log TYPE ty_t_log.

*&--Local Data Declaration
  TYPES: BEGIN OF lty_varinfo,
          flag TYPE c,          " Flag of type Character
          olength TYPE x,       " Olength of type Byte fields
          line TYPE raldb_info, "LIKE raldb-infoline, " Variant information
         END OF lty_varinfo.

  DATA: li_tables TYPE STANDARD TABLE OF trdir-name INITIAL SIZE 0, " ABAP Program Name
        li_infotab TYPE STANDARD TABLE OF lty_varinfo INITIAL SIZE 0.

  FIELD-SYMBOLS: <lfs_log>  TYPE ty_log, "Log Data
                 <lfs_infotab> TYPE lty_varinfo.

  FORMAT INTENSIFIED OFF.

  WRITE:/2(262) sy-uline.

*&--Printing Top-Of-Page Data
  WRITE:/2(50) 'Outbound Interface - RIBA Payments Citibank'(016) COLOR 1.

  WRITE:/2(262) sy-uline.

  WRITE:/2(25) 'Run by:'(018),
        27(25) sy-uname.

  WRITE:/2(262) sy-uline.


*&--Print the selection screen
  CALL FUNCTION 'PRINT_SELECTIONS'
    EXPORTING
      mode      = li_tables
      rname     = sy-repid " Program Name
      rvariante = sy-slset "li_variant_info-variant " Varient Name
    TABLES
      infotab   = li_infotab.

*&--Printing Selection Screen
  LOOP AT li_infotab ASSIGNING <lfs_infotab>.
    WRITE / <lfs_infotab>-line.
  ENDLOOP. " LOOP AT li_infotab ASSIGNING <lfs_infotab>

  WRITE:/2(262) sy-uline.

*&--Printing Table Headings
  WRITE:/2(5)   'Type'(019) COLOR 1,
  8(220) 'Message Text'(020) COLOR 1.

  WRITE:/2(262) sy-uline.

*&--Printing Log Data
  LOOP AT fp_i_log ASSIGNING <lfs_log>.
    WRITE:/2(5)   <lfs_log>-msgtyp,
           8(220) <lfs_log>-msgtxt.
  ENDLOOP. " LOOP AT fp_i_log ASSIGNING <lfs_log>

  WRITE:/2(262) sy-uline.
ENDFORM. " F_WRITE_LOG
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_DATA_EMI
*&---------------------------------------------------------------------*
*       Retrieve Data from EMI
*----------------------------------------------------------------------*
*      <--FP_GV_FILE    Filename
*      <--FP_GV_PFILE   Filepath
*----------------------------------------------------------------------*
FORM f_retrieve_data_emi  CHANGING fp_gv_file TYPE char50      " Retrieve_data_emi chang of type CHAR50
                                   fp_gv_pfile TYPE localfile. " Local file for upload/download
  DATA: li_constant TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0. " Enhancement Status
  FIELD-SYMBOLS: <lfs_constant> TYPE zdev_enh_status. " Enhancement Status


*&--Local Data Declaration
  CONSTANTS: lc_enh_name TYPE z_enhancement VALUE 'OTC_IDD_0217', " Enhancement No.
             lc_filename TYPE z_criteria VALUE 'Z_FILENAME',      " Enh. Criteria
             lc_filepath TYPE z_criteria VALUE 'Z_FILEPATH',      " Enh. Criteria
             lc_appl  TYPE char07 VALUE '/appl/'.                 " Appl of type CHAR07
*&--Function Module to retrieve data from EMI
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_name
    TABLES
      tt_enh_status     = li_constant.
*&--Delete inactive entries
  DELETE li_constant WHERE active = space.

  IF li_constant[] IS NOT INITIAL.
* Begin of change for Defect 6115 by U033876
* commented below code as its not required
**&--Read filename
*    READ TABLE li_constant ASSIGNING <lfs_constant> WITH KEY criteria = lc_filename.
*    IF sy-subrc IS INITIAL .
*      fp_gv_file = <lfs_constant>-sel_low.
*    ENDIF. " IF sy-subrc IS INITIAL
* End of Change for Defect 6115 by U033876
*&--Read filepath
    READ TABLE li_constant ASSIGNING <lfs_constant> WITH KEY criteria = lc_filepath.
    IF sy-subrc IS INITIAL .
      CONCATENATE lc_appl sy-sysid <lfs_constant>-sel_low
* Begin of change for Defect 6115 by U033876
*                                              fp_gv_file c_fileext
* End of Change for Defect 6115 by U033876
                                                INTO fp_gv_pfile.
      CONDENSE fp_gv_pfile.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_constant[] IS NOT INITIAL
ENDFORM. " F_RETRIEVE_DATA_EMI
