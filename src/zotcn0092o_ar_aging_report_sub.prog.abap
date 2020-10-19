*&---------------------------------------------------------------------*
*&  Include           ZOTCN0092O_AR_AGING_REPORT_SUB
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZOTCR0092O_AR_AGING_REPORT
************************************************************************
* PROGRAM    :  ZOTCN0092O_AR_AGING_REPORT_SUB                         *
* TITLE      :  AR Aging Report                                        *
* DEVELOPER  :  Sneha/Moushumi/Sayantan/Lekhashri                      *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID: D2_OTC_RDD_0092
*----------------------------------------------------------------------*
* DESCRIPTION: AR Aging Report
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER      TRANSPORT      DESCRIPTION                   *
* ===========  ========   =========  ==================================*
* 18-Mar-2016  SMUKHER    E2DK917181  AR Aging Report                  *
* 22-Jun-2016  SMUKHER   E2DK918149  Defect# 1829 : Following changes  *
*                                    were done:-                       *
*                                    1.Key Date on selection screen was*
*                                   getting overwritten to current date*
*                                    while saving variant.             *
*                                    2.Clearing Documents not showing  *
*                                    correctly at past Key Date        *
*                                    3.Column Heading 'Profile Center' *
*                                     to be changed to 'Profit Center'.*
*                                    4.ALV File name in Application    *
*                                    Server should now be appended with*
*                                    User Name.                        *
*                                    5.Leading 0's to be removed from  *
*                                      Customer Number.                *
* 18-Jul-2016  U034192   E2DK918411  Defect #1804(SCTASK0357514).      *
*                                   1.Add Customer Group( KNKK- KDGRP)&*
*                                    Assignment(BSAD-ZUONR/BSID -ZUONR)*
*                                    Fields to ALV output              *
*                                   2.Copy authorization Object from   *
*                                     F_KNA1_BUK to ZOTC_AGING         *
* 18-Jul-2016 SMUKHER    E2DK918411 Defect# 1804 1.Amount in Doc curre *
*                                    -ncy should also consider (-) valu*
*                                    -es.                              *
*                                     2.Also, there might be cases where
*                                     the same document is available in*
*                                     both BSAD and BSID table.This nee*
*                                     -ds to be taken care of.         *
*                                     3.Also Credit Rep Group is not   *
*                                     mandatory.                       *
* 08-Sep-2016 SMUKHER   E2DK918919   Defect# 2008: For all date purpose*
*                                    calculation,Document Date needs to*
*                                    considered, and not Posting Date. *
*                                    Also, for the cases where the     *
*                                    Document Date is later than the   *
*                                    Key date, then the amount should  *
*                                    fall in 0-30 Aging bucket.        *
* 13-Oct-2016 LMAHEND  E2DK919334    Defect# 2091:Delimiter is changed *
*                                    from Comma to tab to download     *
*                                    the data into excel sheet         *
*                                    Also output length specified in   *
*                                    fieldcatalog because large numbers*
*                                    were getting truncated when report*
*                                    ran in background.                *
* 13-Oct-2017 MGARG/   E1DK931620    Defect#2646:                      *
*             SGHOSH                 1.Execute AR Report for mutiple   *
*                                    company codes.                    *
*                                    2. FSCM Disptue Case ID field to  *
*                                    be added.                         *
*&---------------------------------------------------------------------*
* 19-Jan-2018 ASK   E1DK933936    Defect#2646:                         *
*                                    1.SORTINH KNKK by KUNNR           *
*                                    2. Removing Binary Search from    *
*                                       Final table                    *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INITIALIZATION
*&---------------------------------------------------------------------*
*       Create default path
*----------------------------------------------------------------------*
FORM f_initialization .
*&-- Create default path
  CONSTANTS: lc_appl TYPE string VALUE '/appl/',
             lc_rep  TYPE string VALUE '/REP/OTC/OTC_RDD_0092/'.

  CONCATENATE lc_appl sy-sysid lc_rep INTO p_path.
ENDFORM. " F_INITIALIZATION
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       Modify selection screen
*----------------------------------------------------------------------*
FORM f_modify_screen USING fp_gv_ucomm TYPE syucomm. " Function code that PAI triggered

  CONSTANTS: lc_sel   TYPE syucomm VALUE 'SEL',   " Function code that PAI triggered
             lc_ucomm TYPE syucomm VALUE 'UCOMM', " Function code that PAI triggered
*-->Begin of delete for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
*             lc_name  TYPE name    VALUE 'P_DATUM', " Employee's last name
*<-- End of delete for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
             lc_name  TYPE group1    VALUE 'DAT', " Employee's last name
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
             lc_name1 TYPE group1  VALUE 'P'. " Employee's last name

  IF fp_gv_ucomm = lc_sel.
    LOOP AT SCREEN.
*-->Begin of delete for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
*      IF screen-name = lc_name.
*<-- End of delete for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
      IF screen-group1 = lc_name.
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
        IF NOT rb_creif IS INITIAL.
          p_datum = sy-datum.
          screen-input = 0.
          MODIFY SCREEN.
        ELSE. " ELSE -> IF NOT rb_creif IS INITIAL
*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
*&-- Only if the Key Date on the selection screen is blank, then current
*    date should be populated in same.
          IF p_datum IS INITIAL.
            p_datum = sy-datum.
          ENDIF. " IF p_datum IS INITIAL
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
          screen-input = 1.
          MODIFY SCREEN.
        ENDIF. " IF NOT rb_creif IS INITIAL

      ELSEIF screen-group1 = lc_name1.
        IF rb_afile = abap_true
          AND rb_alv <> abap_true.
          screen-invisible = 0.
          screen-input     = 1.
          MODIFY SCREEN.
        ELSEIF rb_afile <> abap_true
          AND rb_alv = abap_true.
          screen-invisible = 1.
          screen-input     = 0.
          MODIFY SCREEN.
        ENDIF. " IF rb_afile = abap_true
      ENDIF. " IF screen-group1 = lc_name
    ENDLOOP. " LOOP AT SCREEN
  ENDIF. " IF fp_gv_ucomm = lc_sel

  IF fp_gv_ucomm = lc_ucomm.
    LOOP AT SCREEN.
      IF screen-group1 = lc_name1.
        IF rb_afile = abap_true
          AND rb_alv <> abap_true.
          screen-invisible = 0.
          screen-input     = 1.
          MODIFY SCREEN.
        ELSEIF rb_afile <> abap_true
          AND rb_alv = abap_true..
          screen-invisible = 1.
          screen-input     = 0.
          MODIFY SCREEN.
        ENDIF. " IF rb_afile = abap_true
      ENDIF. " IF screen-group1 = lc_name1
    ENDLOOP. " LOOP AT SCREEN
  ENDIF. " IF fp_gv_ucomm = lc_ucomm

*&-- Initializing selection screen not based on user command
  LOOP AT SCREEN.
    IF screen-name = lc_name.
      IF NOT rb_creif IS INITIAL.
        p_datum = sy-datum.
        screen-input = 0.
        MODIFY SCREEN.
      ELSE. " ELSE -> IF NOT rb_creif IS INITIAL
*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
*&-- Only if the Key Date on the selection screen is blank, then current
*    date should be populated in same.
        IF p_datum IS INITIAL.
          p_datum = sy-datum.
        ENDIF. " IF p_datum IS INITIAL
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF. " IF NOT rb_creif IS INITIAL
    ELSEIF screen-group1 = lc_name1.
      IF rb_afile = abap_true
        AND rb_alv <> abap_true.
        screen-invisible = 0.
        screen-input     = 1.
        MODIFY SCREEN.
      ELSEIF rb_afile <> abap_true
        AND rb_alv = abap_true.
        screen-invisible = 1.
        screen-input     = 0.
        MODIFY SCREEN.
      ENDIF. " IF rb_afile = abap_true
    ENDIF. " IF screen-name = lc_name
  ENDLOOP. " LOOP AT SCREEN

ENDFORM. " F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_S_KUNNR
*&---------------------------------------------------------------------*
*       Validate Customer
*----------------------------------------------------------------------*
*      -->FP_S_KUNNR[]  Customer Number
*----------------------------------------------------------------------*
FORM f_validate_s_kunnr  USING    fp_s_kunnr TYPE ty_t_kunnr.
  DATA: lv_kunnr TYPE kunnr. " Customer Number

  SELECT kunnr     " Customer Number
         INTO lv_kunnr  ##needed
         FROM kna1 " General Data in Customer Master
         UP TO 1 ROWS
         WHERE kunnr IN fp_s_kunnr
         AND loevm <> abap_true.
  ENDSELECT.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE e945. "Invalid Customer Number
  ENDIF. " IF sy-subrc IS NOT INITIAL
ENDFORM. " F_VALIDATE_S_KUNNR
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_S_COMP
*&---------------------------------------------------------------------*
*       Validate Company Code
*----------------------------------------------------------------------*
*      -->FP_S_COMP[]  Company Code
*----------------------------------------------------------------------*
FORM f_validate_s_comp  USING    fp_s_comp TYPE ty_t_bukrs.

  SELECT bukrs " Company Code
    INTO TABLE i_comp
    FROM t001  " Customer Master (Company Code)
   WHERE bukrs IN fp_s_comp.

  IF  sy-subrc IS NOT INITIAL.
    MESSAGE e944. " Invalid Company Code
  ENDIF. " IF sy-subrc IS NOT INITIAL

ENDFORM. " F_VALIDATE_S_COMP
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_S_RECCON
*&---------------------------------------------------------------------*
*       Validate Reconciliation Account in General Ledger
*----------------------------------------------------------------------*
*      -->FP_S_RECCON[]  Reconciliation Account in General Ledger
*----------------------------------------------------------------------*
FORM f_validate_s_reccon  USING    fp_s_reccon TYPE ty_t_reccon.
  DATA: lv_reccon TYPE akont. " Reconciliation Account in General Ledger

  SELECT saknr                       " Reconciliation Account in General Ledger
         UP TO 1 ROWS
         INTO lv_reccon ##needed
         FROM ska1                   " G/L Account Master (Chart of Accounts)
         WHERE saknr IN fp_s_reccon. "#EC CI_GENBUFF
  ENDSELECT.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE e943. " Invalid Reconciliation Account in General Ledger
  ENDIF. " IF sy-subrc IS NOT INITIAL
ENDFORM. " F_VALIDATE_S_RECCON
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_S_SBGRP
*&---------------------------------------------------------------------*
*       Validate Credit representative group
*----------------------------------------------------------------------*
*      -->FP_S_SBGRP[]  Credit representative group for credit management
*----------------------------------------------------------------------*
FORM f_validate_s_sbgrp USING    fp_s_sbgrp TYPE ty_t_sbgrp.
  DATA: lv_sbgrp TYPE sbgrp_cm. " Credit representative group for credit management

  SELECT sbgrp      " Credit representative group for credit management
         UP TO 1 ROWS
         INTO lv_sbgrp
         FROM t024b " Credit management: Credit representative groups
         WHERE sbgrp IN fp_s_sbgrp.
  ENDSELECT.
  IF  sy-subrc IS NOT INITIAL.
    MESSAGE e915.
  ENDIF. " IF sy-subrc IS NOT INITIAL
ENDFORM. " F_VALIDATE_S_SBGRP
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_S_SBGRP
*&---------------------------------------------------------------------*
*       Validate Credit representative group for credit management
*----------------------------------------------------------------------*
*      -->FP_S_SBGRP[]  Credit representative group for credit management
*----------------------------------------------------------------------*
FORM f_validate_s_sbgrp_kkber  USING    fp_s_sbgrp TYPE ty_t_sbgrp.
  DATA: lv_sbgrp TYPE sbgrp_cm, " Credit representative group for credit management
        lv_kkber TYPE kkber.    " Credit Control Area

  SELECT sbgrp                  " Credit representative group for credit management
         kkber                  " Credit Control Area
         UP TO 1 ROWS
         INTO (lv_sbgrp, lv_kkber) ##needed
         FROM t024b             " Credit management: Credit representative groups
         WHERE sbgrp IN fp_s_sbgrp
         AND   kkber = p_kkber. "#EC CI_GENBUFF
  ENDSELECT.
  IF  sy-subrc IS NOT INITIAL.
    MESSAGE e909. " Credit Control Area not valid in the Credit Rep Group
  ENDIF. " IF sy-subrc IS NOT INITIAL
ENDFORM. " F_VALIDATE_S_SBGRP
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_S_KNKLI
*&---------------------------------------------------------------------*
*       Validate Customer's account number
*----------------------------------------------------------------------*
*      -->FP_S_KNKLI[]  Customer's account number
*----------------------------------------------------------------------*
FORM f_validate_s_knkli  USING    fp_s_knkli TYPE ty_t_knkli.
  DATA: lv_kunnr TYPE kunnr. " Customer's account number with credit limit reference

  SELECT kunnr     " Customer's account number with credit limit reference
         INTO lv_kunnr ##needed
         FROM kna1 " Customer master credit management: Control area data
         UP TO 1 ROWS
         WHERE kunnr IN fp_s_knkli
         AND loevm <> abap_true.
  ENDSELECT.

  IF  sy-subrc IS NOT INITIAL.
    MESSAGE e942. " Invalid Customer's Account Number With Credit Limit Reference
  ENDIF. " IF sy-subrc IS NOT INITIAL

ENDFORM. " F_VALIDATE_S_KNKLI
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_P_KKBER
*&---------------------------------------------------------------------*
*       Validate Credit Control Area
*----------------------------------------------------------------------*
FORM f_validate_p_kkber .
  DATA: lv_kkber TYPE kkber. " Credit Control Area
  SELECT SINGLE kkber " Credit Control Area
         FROM t014    " Credit control areas
         INTO lv_kkber ##needed
         WHERE kkber = p_kkber.
  IF  sy-subrc IS NOT INITIAL.
    MESSAGE e941. " Invalid Credit Control Area
  ENDIF. " IF sy-subrc IS NOT INITIAL
ENDFORM. " F_VALIDATE_P_KKBER
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_KUNNR_COMP
*&---------------------------------------------------------------------*
*       Validate KUNNR with BUKRS
*----------------------------------------------------------------------*
*      -->FP_S_KUNNR[]  Customer Number
*      -->FP_S_COMP[]   Company code
*----------------------------------------------------------------------*
FORM f_validate_kunnr_comp  USING    fp_s_kunnr TYPE ty_t_kunnr
                                     fp_s_comp  TYPE ty_t_bukrs.
  DATA: lv_kunnr TYPE kunnr. " Customer Number
  SELECT SINGLE kunnr " Customer Number
         FROM knb1    " Customer Master (Company Code)
         INTO lv_kunnr ##needed
         WHERE kunnr IN fp_s_kunnr
         AND   bukrs IN fp_s_comp.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE e940. "Invalid customer number and company code combination
  ENDIF. " IF sy-subrc IS NOT INITIAL

ENDFORM. " F_VALIDATE_KUNNR_COMP
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_KUNNR_KKBER
*&---------------------------------------------------------------------*
*       Validate kunnr with kkber
*----------------------------------------------------------------------*
*      -->FP_S_KUNNR[]  Customer Number
*      -->FP_P_KKBER    Credit Control Area
*----------------------------------------------------------------------*
FORM f_validate_kunnr_kkber  USING    fp_s_kunnr TYPE ty_t_kunnr
                                      fp_p_kkber .
  DATA: lv_kunnr TYPE kunnr. " Customer Number

  SELECT kunnr     " Customer Number
         FROM knkk " Customer master credit management: Control area data
         UP TO 1 ROWS
         INTO lv_kunnr ##needed
         WHERE kunnr IN fp_s_kunnr
         AND   kkber = fp_p_kkber.
  ENDSELECT.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE e939. " Invalid Customer Number and Credit Control Area Combination
  ENDIF. " IF sy-subrc IS NOT INITIAL

ENDFORM. " F_VALIDATE_KUNNR_KKBER
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_COMP_KKBER
*&---------------------------------------------------------------------*
*       Validate BUKRS with KKBER
*----------------------------------------------------------------------*
*      -->FP_S_COMP[]  Company code
*      -->FP_P_KKBER   Credit Control
*----------------------------------------------------------------------*
FORM f_validate_comp_kkber  USING    fp_s_comp TYPE ty_t_bukrs
                                     fp_p_kkber.
  DATA: lv_bukrs TYPE bukrs. " Company Code
  SELECT SINGLE bukrs " Company Code
         FROM t001    " Company Codes
         INTO lv_bukrs ##needed
         WHERE bukrs IN fp_s_comp
         AND   kkber = fp_p_kkber.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE e938. "Invalid Company Code And Credit Control Area Combination
  ENDIF. " IF sy-subrc IS NOT INITIAL

ENDFORM. " F_VALIDATE_COMP_KKBER
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_T001
*&---------------------------------------------------------------------*
*       Fetch data from T001
*----------------------------------------------------------------------*
FORM f_get_data_t001  CHANGING fp_i_t001 TYPE ty_t_t001.

  IF NOT i_comp IS INITIAL.
    SELECT bukrs " Company Code
           waers " Currency Key
           kkber " Credit Control Area
      FROM t001  " Company Codes
      INTO TABLE fp_i_t001
      FOR ALL ENTRIES IN i_comp
      WHERE bukrs = i_comp-bukrs.

    IF sy-subrc IS INITIAL.

      IF p_kkber IS NOT INITIAL.
        DELETE fp_i_t001 WHERE kkber NE p_kkber.
      ENDIF. " IF p_kkber IS NOT INITIAL

      SORT fp_i_t001 BY bukrs.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF NOT i_comp IS INITIAL
ENDFORM. " F_GET_DATA_T001
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_KNB1
*&---------------------------------------------------------------------*
*       Fetch data for KNB1
*----------------------------------------------------------------------*
*      -->FP_S_KUNNR[]  Customer Number
*      -->FP_S_RECCON[] Reconciliation Account in General Ledger
*----------------------------------------------------------------------*
FORM f_get_data_knb1  USING    fp_s_kunnr TYPE ty_t_kunnr
                               fp_s_reccon TYPE ty_t_reccon
                      CHANGING fp_i_knb1 TYPE ty_t_knb1
                               fp_i_t001 TYPE ty_t_t001.

  SORT fp_i_t001 BY bukrs.
  DELETE ADJACENT DUPLICATES FROM fp_i_t001 COMPARING bukrs.

  IF fp_i_t001 IS NOT INITIAL.

    SELECT  kunnr     " Customer Number
            bukrs     " Company Code
            akont     " Reconciliation Account in General Ledger
            FROM knb1 " Customer Master (Company Code)
            INTO TABLE fp_i_knb1
            FOR ALL ENTRIES IN fp_i_t001
            WHERE kunnr IN fp_s_kunnr[]
            AND   bukrs = fp_i_t001-bukrs
            AND   akont IN fp_s_reccon[].

    IF sy-subrc IS INITIAL.
      SORT fp_i_knb1 BY kunnr bukrs.
    ENDIF. " IF sy-subrc IS INITIAL
* <--- Begin of Insert for D3_OTC_RDD_0092 Defect#2646 by MGARG
    SORT fp_i_t001 BY kkber.
* <--- End of Insert for D3_OTC_RDD_0092 Defect#2646 by MGARG
  ENDIF. " IF fp_i_t001 IS NOT INITIAL

ENDFORM. " F_GET_DATA_KNB1
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_KNKK
*&---------------------------------------------------------------------*
*       Fetch Data from KNKK
*----------------------------------------------------------------------*
*      -->FP_I_T001[]   T001 data
*      -->FP_s_knkli[]  KNKLI
*      -->FP_S_SBGRP[]  SBGRP
*----------------------------------------------------------------------*
FORM f_get_data_knkk  USING    fp_i_knb1 TYPE ty_t_knb1
                               fp_i_t001 TYPE ty_t_t001
                      CHANGING fp_i_knkk TYPE ty_t_knkk.

  DATA: li_knb1 TYPE STANDARD TABLE OF ty_knb1,
* <--- Begin of Insert for D3_OTC_RDD_0092 Defect#2646 by MGARG
        lv_index TYPE sytabix,   " Index of Internal Tables
        li_knkk  TYPE ty_t_knkk, " Internal table for KNKK
        lwa_knkk TYPE ty_knkk.   " Work Area for KNKK
* <--- End of Insert for D3_OTC_RDD_0092 Defect#2646 by MGARG

  FIELD-SYMBOLS: <lfs_knkk> TYPE ty_knkk,
                 <lfs_t001> TYPE ty_t001,
                 <lfs_knb1> TYPE ty_knb1.

  li_knb1[] = fp_i_knb1[].
  SORT li_knb1 BY kunnr.
  DELETE ADJACENT DUPLICATES FROM li_knb1 COMPARING kunnr.


  IF li_knb1 IS NOT INITIAL.
*&-- Fetch data from KNKK
    SELECT kunnr " Customer Number
           kkber " Credit Control Area
           klimk " Customer's credit limit
           knkli " Customer's account number with credit limit reference
           skfor " Total receivables (for credit limit check)
           ctlpc " Credit management: Risk category
           dtrev " Last internal review
           sbgrp " Credit representative group for credit management
           nxtrv " Next internal review
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
           kdgrp " Customer Group
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
           FROM knkk " Customer master credit management: Control area data
           INTO TABLE fp_i_knkk
           FOR ALL ENTRIES IN li_knb1
           WHERE kunnr = li_knb1-kunnr
           AND   kkber = p_kkber.

    IF sy-subrc IS INITIAL.
      IF s_knkli IS NOT INITIAL.
        DELETE fp_i_knkk WHERE knkli NOT IN s_knkli.
      ENDIF. " IF s_knkli IS NOT INITIAL
      IF s_sbgrp IS NOT INITIAL.
        DELETE fp_i_knkk WHERE sbgrp NOT IN s_sbgrp.
      ENDIF. " IF s_sbgrp IS NOT INITIAL

* <--- Begin of Delete for D3_OTC_RDD_0092 Defect#2646 by MGARG
**We need to consider all the comp code rather than one comp code
**from table fp_i_t001. So, removing Read from this table and applying
** loop on table fp_i_t001

** Populate the Company Code in I_KNKK as well.
*      LOOP AT fp_i_knkk ASSIGNING <lfs_knkk>.
*        READ TABLE fp_i_t001 ASSIGNING <lfs_t001>
*                          WITH KEY kkber = <lfs_knkk>-kkber
*                          BINARY SEARCH.
*        IF sy-subrc IS INITIAL.
*          READ TABLE fp_i_knb1 ASSIGNING <lfs_knb1>
*                               WITH KEY kunnr = <lfs_knkk>-kunnr
*                                        bukrs = <lfs_t001>-bukrs
*                                        BINARY SEARCH.
*          IF sy-subrc IS INITIAL.
*            <lfs_knkk>-bukrs = <lfs_knb1>-bukrs.
*            <lfs_knkk>-waers = <lfs_t001>-waers.
*          ENDIF. " IF sy-subrc IS INITIAL
*        ENDIF. " IF sy-subrc IS INITIAL
*      ENDLOOP. " LOOP AT fp_i_knkk ASSIGNING <lfs_knkk>
* <--- End of Delete for D3_OTC_RDD_0092 Defect#2646 by MGARG

* <--- Begin of Insert for D3_OTC_RDD_0092 Defect#2646 by MGARG
** Populate all comp code in I_KNKK
      li_knkk[] = fp_i_knkk[].
      SORT li_knkk BY kkber.
      FREE: fp_i_knkk[].

*** Apply  parallel cursor to populate all comp code.
      LOOP AT li_knkk ASSIGNING <lfs_knkk>.
        CLEAR lv_index.
        READ TABLE fp_i_t001 TRANSPORTING NO FIELDS
                             WITH KEY kkber = <lfs_knkk>-kkber.
        IF sy-subrc = 0.
          lv_index = sy-tabix.
          LOOP AT fp_i_t001 ASSIGNING <lfs_t001> FROM lv_index.
            IF <lfs_t001>-kkber <> <lfs_knkk>-kkber.
              EXIT.
            ELSE. " ELSE -> IF <lfs_t001>-kkber <> <lfs_knkk>-kkber

              READ TABLE fp_i_knb1 ASSIGNING <lfs_knb1>
                                  WITH KEY kunnr = <lfs_knkk>-kunnr
                                           bukrs = <lfs_t001>-bukrs
                                           BINARY SEARCH.
              IF sy-subrc IS INITIAL.
                MOVE <lfs_knkk> TO lwa_knkk.
                lwa_knkk-bukrs = <lfs_knb1>-bukrs.
                lwa_knkk-waers = <lfs_t001>-waers.
                APPEND lwa_knkk TO fp_i_knkk.
                CLEAR lwa_knkk.
              ENDIF. " IF sy-subrc IS INITIAL
            ENDIF. " IF <lfs_t001>-kkber <> <lfs_knkk>-kkber
          ENDLOOP. " LOOP AT fp_i_t001 ASSIGNING <lfs_t001> FROM lv_index
        ENDIF. " IF sy-subrc = 0
      ENDLOOP. " LOOP AT li_knkk ASSIGNING <lfs_knkk>

      SORT fp_i_knkk BY kunnr kkber.
* <--- End of Insert for D3_OTC_RDD_0092 Defect#2646 by MGARG
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_knb1 IS NOT INITIAL

ENDFORM. " F_GET_DATA_KNKK
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_KNA1
*&---------------------------------------------------------------------*
*       Fetch data from KNA1
*----------------------------------------------------------------------*
*      -->FP_I_KNKK[]  KNKK Data
*----------------------------------------------------------------------*
FORM f_get_data_kna1  USING    fp_i_knkk TYPE ty_t_knkk
                      CHANGING fp_i_kna1 TYPE ty_t_kna1.

  DATA: li_knkk TYPE STANDARD TABLE OF ty_knkk INITIAL SIZE 0. " Local table

  li_knkk[] = fp_i_knkk[].
  SORT li_knkk BY kunnr.
  DELETE ADJACENT DUPLICATES FROM li_knkk COMPARING kunnr.

  IF li_knkk IS NOT INITIAL.

    SELECT kunnr     " Customer Number
           land1     " Country Key
           name1     " Name 1
           FROM kna1 " General Data in Customer Master
           INTO TABLE fp_i_kna1
           FOR ALL ENTRIES IN li_knkk
           WHERE kunnr = li_knkk-kunnr
           AND loevm <> abap_true.
    IF sy-subrc IS INITIAL.
      SORT fp_i_kna1 BY kunnr.
    ENDIF. " IF sy-subrc IS INITIAL

  ENDIF. " IF li_knkk IS NOT INITIAL

ENDFORM. " F_GET_DATA_KNA1
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_BSID
*&---------------------------------------------------------------------*
*       Fetch data from KNB1
*----------------------------------------------------------------------*
*      -->FP_I_KNB1[]  KNB1 data
*----------------------------------------------------------------------*
FORM f_get_data_bsid  USING    fp_i_knb1 TYPE ty_t_knb1
                      CHANGING fp_i_bsid TYPE ty_t_bsid.

  DATA: li_knb1 TYPE STANDARD TABLE OF ty_knb1.

  li_knb1[] = fp_i_knb1[].
  SORT li_knb1 BY kunnr bukrs.
  DELETE ADJACENT DUPLICATES FROM li_knb1 COMPARING kunnr bukrs.

  IF  li_knb1 IS NOT INITIAL.
*&-- Fetch data from BSID
    SELECT bukrs     "Company Code
           kunnr     "Customer Number
           umsks     " Transaction Type
           umskz     "Special G/L Indicator
           augdt     "  Clearing Date
           augbl     "  Document Number of the Clearing Document
           zuonr     "  Assignment Number
           gjahr     "  Fiscal Year
           belnr     "  Accounting Document Number
           buzei     "  Number of Line Item Within Accounting Document
           budat     "  Posting Date in the Document
           bldat     "  Document Date in Document
           cpudt     "  Day On Which Accounting Document Was Entered
           blart     "  Document Type
           waers     "  Currency Key
           xblnr     "  Reference Document Number
           monat     "  Fiscal Period
           bschl     "  Posting Key
           shkzg     "  Debit/Credit Indicator
           mwskz     "  Tax on sales/purchases code
           dmbtr     "  Amount in Local Currency
           wrbtr     "  Amount in Document Currency
           sgtxt     "  Item Text
           hkont     "  General Ledger Account
           zfbdt     "  Baseline Date for Due Date Calculation
           zterm     "  Terms of Payment Key
           zbd1t     "  Cash Discount Days 1
           zbd2t     "  Cash Discount Days 2
           rebzg     "  Number of the Invoice the Transaction Belongs to
           vbeln     "  Billing Document
           xref1     "  Business Partner Reference Key
           xref2     "  Business Partner Reference Key
           prctr     "  Profit Center
           FROM bsid " Accounting: Secondary Index for Customers
           INTO TABLE fp_i_bsid
           FOR ALL ENTRIES IN li_knb1
           WHERE bukrs = li_knb1-bukrs
           AND  kunnr = li_knb1-kunnr.

    IF sy-subrc IS INITIAL.
      SORT fp_i_bsid BY bukrs kunnr.

      IF s_reccon IS NOT INITIAL.
        DELETE fp_i_bsid WHERE hkont NOT IN s_reccon[].
      ENDIF. " IF s_reccon IS NOT INITIAL
*& Keeping only those entries in BSID where Posting Date < Key date.
      IF rb_creif IS INITIAL.
        DELETE fp_i_bsid WHERE budat GT p_datum.
      ENDIF. " IF rb_creif IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL

  ENDIF. " IF li_knb1 IS NOT INITIAL
ENDFORM. " F_GET_DATA_BSID
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_BSAD
*&---------------------------------------------------------------------*
*       Fetch data from BSAD
*----------------------------------------------------------------------*
*      -->FP_I_KNB1[]  KNB1 data
*----------------------------------------------------------------------*
FORM f_get_data_bsad  USING    fp_i_knb1 TYPE ty_t_knb1
                      CHANGING fp_i_bsad TYPE ty_t_bsad.

  DATA: li_knb1 TYPE STANDARD TABLE OF ty_knb1. " local internal table

  FIELD-SYMBOLS: <lfs_bsad> TYPE ty_bsad . " Field symbol for TY_BSAD

  li_knb1[] = fp_i_knb1[].
  SORT li_knb1 BY kunnr bukrs.
  DELETE ADJACENT DUPLICATES FROM li_knb1 COMPARING kunnr bukrs.

  IF li_knb1 IS NOT INITIAL.
*&-- Fetch data from BSAD
    SELECT bukrs     " Company Code
           kunnr     " Customer Number
           umsks     " Transaction Type
           umskz     " Special G/L Indicator
           augdt     "  Clearing Date
           augbl     "  Document Number of the Clearing Document
           zuonr     "  Assignment Number
           gjahr     "  Fiscal Year
           belnr     "  Accounting Document Number
           buzei     "  Number of Line Item Within Accounting Document
           budat     "  Posting Date in the Document
           bldat     "  Document Date in Document
           cpudt     "  Day On Which Accounting Document Was Entered
           blart     "  Document Type
           waers     " Currency Key
           xblnr     " Reference Document Number
           monat     "  Fiscal Period
           bschl     "  Posting Key
           shkzg     " Debit/Credit Indicator
           mwskz     "  Tax on sales/purchases code
           dmbtr     "  Amount in Local Currency
           wrbtr     "  Amount in Document Currency
           sgtxt     " Item Text
           hkont     "  General Ledger Account
           zfbdt     "Baseline Date for Due Date Calculation
           zterm     "Terms of Payment Key
           zbd1t     "Cash Discount Days 1
           zbd2t     "Cash Discount Days 2
           rebzg     " Number of the Invoice the Transaction Belongs to
           vbeln     "  Billing Document
           xref1     "Business Partner Reference Key
           xref2     "Business Partner Reference Key
           prctr     " Profit Center
           FROM bsad " Accounting: Secondary Index for Customers (Cleared Items)
           INTO TABLE fp_i_bsad
           FOR ALL ENTRIES IN li_knb1
           WHERE bukrs = li_knb1-bukrs
           AND   kunnr = li_knb1-kunnr.

    IF sy-subrc IS INITIAL.
*&-- Sort
      SORT fp_i_bsad BY bukrs kunnr belnr.

      IF s_reccon IS NOT INITIAL.
        DELETE fp_i_bsad WHERE hkont NOT IN s_reccon[].
      ENDIF. " IF s_reccon IS NOT INITIAL

      IF rb_creif IS INITIAL.

        DELETE fp_i_bsad WHERE budat GT p_datum.
        DELETE fp_i_bsad WHERE augdt LE p_datum.

*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
*&-- We will filter out those entries from BSAD where AUGBL = BELNR.
*    This happens whenever any Invoice is cleared out, then an additional
*    entry gets created in BSAD where the same Clearing Doc gets populated at
*    both AUGBL and BELNR.
        LOOP AT fp_i_bsad ASSIGNING <lfs_bsad>.
          IF <lfs_bsad>-augdt LT p_datum.
            IF <lfs_bsad>-augbl = <lfs_bsad>-belnr.
              <lfs_bsad>-kunnr = space.
            ENDIF. " IF <lfs_bsad>-augbl = <lfs_bsad>-belnr
          ENDIF. " IF <lfs_bsad>-augdt LT p_datum
        ENDLOOP. " LOOP AT fp_i_bsad ASSIGNING <lfs_bsad>
        UNASSIGN <lfs_bsad>.
        DELETE fp_i_bsad WHERE kunnr IS INITIAL.
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016

      ENDIF. " IF rb_creif IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL

  ENDIF. " IF li_knb1 IS NOT INITIAL

ENDFORM. " F_GET_DATA_BSAD
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_VBRP
*&---------------------------------------------------------------------*
*       Fetch data from VBRP
*----------------------------------------------------------------------*
*      -->FP_I_BSID[]  BSID data
*----------------------------------------------------------------------*
FORM f_get_data_vbrp  USING    fp_i_bsid TYPE ty_t_bsid
                      CHANGING fp_i_vbrp TYPE ty_t_vbrp.

  DATA: li_bsid TYPE STANDARD TABLE OF ty_bsid INITIAL SIZE 0, " Local table
        lwa_bsid TYPE ty_bsid,                                 " local work area
        li_bsad TYPE STANDARD TABLE OF ty_bsad INITIAL SIZE 0. " local internal table

  FIELD-SYMBOLS: <lfs_bsad> TYPE ty_bsad. " field symbols

  li_bsid[] = fp_i_bsid[].
  SORT li_bsid BY vbeln.
  DELETE ADJACENT DUPLICATES FROM li_bsid COMPARING vbeln.

  li_bsad[] = i_bsad[].
  SORT li_bsad BY vbeln.
  DELETE ADJACENT DUPLICATES FROM li_bsad COMPARING vbeln.

  LOOP AT li_bsad ASSIGNING <lfs_bsad>.
    lwa_bsid = <lfs_bsad>.
    APPEND lwa_bsid TO li_bsid.
    CLEAR lwa_bsid.
  ENDLOOP. " LOOP AT li_bsad ASSIGNING <lfs_bsad>
  UNASSIGN <lfs_bsad>.

  IF li_bsid IS NOT INITIAL.
*&-- Fetch data from VBRP
    SELECT vbeln     " Billing Document
           posnr     " Billing item
           aubel     " Sales Document
           FROM vbrp " Billing Document: Item Data
           INTO TABLE fp_i_vbrp
           FOR ALL ENTRIES IN li_bsid
           WHERE vbeln = li_bsid-vbeln.
    IF sy-subrc IS INITIAL.
*     Do Nothing
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_bsid IS NOT INITIAL
ENDFORM. " F_GET_DATA_VBRP
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_VBAK
*&---------------------------------------------------------------------*
*       Fetch data from VBAK
*----------------------------------------------------------------------*
*      -->FP_I_VBRP[]  VBRP Data
*----------------------------------------------------------------------*
FORM f_get_data_vbak     CHANGING fp_i_vbak TYPE ty_t_vbak
                                  fp_i_vbrp TYPE ty_t_vbrp.

  DATA: li_vbrp TYPE STANDARD TABLE OF ty_vbrp.

  li_vbrp[] = fp_i_vbrp[].
  SORT li_vbrp BY aubel.
  DELETE ADJACENT DUPLICATES FROM li_vbrp COMPARING aubel.

  IF li_vbrp IS NOT INITIAL.
*&-- Fetch data from VBAK
    SELECT vbeln     " Sales Document
           bstnk     " Customer purchase order number
           bsark     " Customer purchase order type
           FROM vbak " Sales Document: Header Data
           INTO TABLE fp_i_vbak
           FOR ALL ENTRIES IN li_vbrp
           WHERE vbeln = li_vbrp-aubel.

    IF sy-subrc IS INITIAL.
      SORT fp_i_vbak BY vbeln.
    ENDIF. " IF sy-subrc IS INITIAL

  ENDIF. " IF li_vbrp IS NOT INITIAL

  SORT fp_i_vbrp BY vbeln. " This is added to avoid a Binary search fail later

ENDFORM. " F_GET_DATA_VBAK
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_T024B
*&---------------------------------------------------------------------*
*       Fetch data from  T024B
*----------------------------------------------------------------------*
*      -->FP_I_KNKK[]  KNKK data
*----------------------------------------------------------------------*
FORM f_get_data_t024b  USING    fp_i_knkk TYPE ty_t_knkk
                       CHANGING fp_i_t024b TYPE ty_t_024b.

  DATA: li_knkk TYPE STANDARD TABLE OF ty_knkk.

  li_knkk[] = fp_i_knkk[].
  SORT li_knkk BY kkber sbgrp.

  DELETE ADJACENT DUPLICATES FROM li_knkk COMPARING kkber sbgrp.

  IF li_knkk IS NOT INITIAL.
*&-- Fetch data from T024B
    SELECT sbgrp                        " Credit representative group for credit management
           kkber                        " Credit Control Area
           stext                        " Name of the credit representative group
           FROM t024b                   " Credit management: Credit representative groups
           INTO TABLE fp_i_t024b
           FOR ALL ENTRIES IN li_knkk
           WHERE sbgrp = li_knkk-sbgrp
           AND   kkber = li_knkk-kkber. "#EC CI_GENBUFF
    IF sy-subrc IS INITIAL.
      SORT fp_i_t024b BY sbgrp kkber.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_knkk IS NOT INITIAL

ENDFORM. " F_GET_DATA_T024B
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_FIELDCAT
*&---------------------------------------------------------------------*
*       Design the field catalog
*----------------------------------------------------------------------*
*      <--P_I_FIELDCAT[]    field catalog
*----------------------------------------------------------------------*
FORM f_prepare_fieldcat  CHANGING fp_i_fieldcat TYPE slis_t_fieldcat_alv.

  PERFORM f_populate_fieldcat USING:
        'BUKRS'     'I_FINAL_DET'               'Co Code'(001) space space     CHANGING fp_i_fieldcat,
        'KUNNR'     'I_FINAL_DET'       'Customer Number'(002) space space     CHANGING fp_i_fieldcat,
        'NAME1'     'I_FINAL_DET'         'Customer Name'(003) space space     CHANGING fp_i_fieldcat,
        'LAND1'     'I_FINAL_DET'               'Country'(050) space space     CHANGING fp_i_fieldcat,
        'HKONT'     'I_FINAL_DET'            'Reccon Acc'(004) space space     CHANGING fp_i_fieldcat,
        'BSCHL'     'I_FINAL_DET'           'Posting Key'(005) space space     CHANGING fp_i_fieldcat,
        'BLART'     'I_FINAL_DET'         'Document Type'(006) space space     CHANGING fp_i_fieldcat,
        'BELNR'     'I_FINAL_DET'       'Document Number'(007) space space     CHANGING fp_i_fieldcat,
        'XBLNR'     'I_FINAL_DET'             'Reference'(008) space  space    CHANGING fp_i_fieldcat,
        'DMBTR'     'I_FINAL_DET'    'Amt Local Currency'(009) 'WAERS' 'T001'  CHANGING fp_i_fieldcat,
        'BALANCE'   'I_FINAL_DET'               'Balance'(049) 'WAERS' 'T001'  CHANGING fp_i_fieldcat,
        'WAERS'     'I_FINAL_DET'        'Local Currency'(010) space  space    CHANGING fp_i_fieldcat,
        'NOT_DUE'   'I_FINAL_DET'               'Not Due'(011) 'WAERS' 'T001'  CHANGING fp_i_fieldcat.

  IF NOT rb_detdc IS INITIAL
    OR NOT rb_sumdc IS INITIAL.
    PERFORM f_populate_fieldcat USING:
         'CALC1'     'I_FINAL_DET'             '0-30Days'(012) 'WAERS' 'T001'  CHANGING fp_i_fieldcat.
  ELSEIF NOT rb_detnt IS INITIAL
    OR NOT rb_sumnt IS INITIAL.
    PERFORM f_populate_fieldcat USING:
         'CALC1'     'I_FINAL_DET'             '1-30Days'(013) 'WAERS' 'T001'  CHANGING fp_i_fieldcat.
  ENDIF. " IF NOT rb_detdc IS INITIAL

  PERFORM f_populate_fieldcat USING:
          'CALC2'     'I_FINAL_DET'            '31-60Days'(014)  'WAERS' 'T001' CHANGING fp_i_fieldcat,
          'CALC3'     'I_FINAL_DET'            '61-90Days'(015)  'WAERS' 'T001' CHANGING fp_i_fieldcat,
          'CALC4'     'I_FINAL_DET'           '91-120Days'(016)  'WAERS' 'T001' CHANGING fp_i_fieldcat,
          'CALC5'     'I_FINAL_DET'          '121-150Days'(017)  'WAERS' 'T001' CHANGING fp_i_fieldcat,
          'CALC6'     'I_FINAL_DET'             '>150Days'(018)  'WAERS' 'T001' CHANGING fp_i_fieldcat,
          'WRBTR'     'I_FINAL_DET'     'Amt Doc Currency'(019)  'WAERS' 'BSID' CHANGING fp_i_fieldcat,
          'WAERS1'    'I_FINAL_DET'         'Doc Currency'(063)  space space    CHANGING fp_i_fieldcat,
          'BLDAT'     'I_FINAL_DET'        'Document Date'(020)  space space    CHANGING fp_i_fieldcat,
          'BUDAT'     'I_FINAL_DET'         'Posting Date'(021)  space space    CHANGING fp_i_fieldcat,
          'CPUDT'     'I_FINAL_DET'           'Entry Date'(022)  space space    CHANGING fp_i_fieldcat,
          'AUGDT'     'I_FINAL_DET'        'Clearing Date'(023)  space space    CHANGING fp_i_fieldcat,
          'AUGBL'     'I_FINAL_DET'         'Clearing Doc'(024)  space space    CHANGING fp_i_fieldcat,
          'ZFBDT'     'I_FINAL_DET'       'Base Line Date'(025)  space space    CHANGING fp_i_fieldcat,
          'ZTERM'     'I_FINAL_DET'        'Payment Terms'(026)  space space    CHANGING fp_i_fieldcat,
          'MWSKZ'     'I_FINAL_DET'             'Tax Code'(027)  space space    CHANGING fp_i_fieldcat,
*-->Begin of delete for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
*          'PRCTR'     'I_FINAL_DET'       'Profile Center'(028)  space space    CHANGING fp_i_fieldcat,
*<-- End of delete for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
          'PRCTR'     'I_FINAL_DET'       'Profit Center'(028)  space space    CHANGING fp_i_fieldcat,
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
          'REBZG'     'I_FINAL_DET'    'Invoice Reference'(029)  space space    CHANGING fp_i_fieldcat,
          'VBELN'     'I_FINAL_DET'          'Billing Doc'(030)  space space    CHANGING fp_i_fieldcat,
          'AUBEL'     'I_FINAL_DET'           'Sale Order'(031)  space space    CHANGING fp_i_fieldcat,
          'BSTNK'     'I_FINAL_DET'            'PO Number'(032)  space space    CHANGING fp_i_fieldcat,
          'BSARK'     'I_FINAL_DET'              'PO Type'(033)  space space    CHANGING fp_i_fieldcat,
          'UMSKZ'     'I_FINAL_DET'     'Spl GL Indicator'(034)  space space    CHANGING fp_i_fieldcat,
          'XREF1'     'I_FINAL_DET'      'Reference Key 1'(035)  space space    CHANGING fp_i_fieldcat,
          'XREF2'     'I_FINAL_DET'      'Reference Key 2'(036)  space space    CHANGING fp_i_fieldcat,
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
          'ZUONR'     'I_FINAL_DET'    'Assignment Number'(070)  space space    CHANGING fp_i_fieldcat,
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
          'SGTXT'     'I_FINAL_DET'           'Header TXT'(037)  space space    CHANGING fp_i_fieldcat,
          'KKBER'     'I_FINAL_DET'  'Credit Control Area'(038)  space space    CHANGING fp_i_fieldcat,
          'KNKLI'     'I_FINAL_DET'       'Credit Account'(039)  space space    CHANGING fp_i_fieldcat,
          'KLIMK'     'I_FINAL_DET'         'Credit Limit'(040)  space space    CHANGING fp_i_fieldcat,
          'OBLIG'     'I_FINAL_DET'      'Credit Exposure'(064)  space space    CHANGING fp_i_fieldcat,
          'KLPRZ'     'I_FINAL_DET'  'Credit Limit Used %'(068)  space space    CHANGING fp_i_fieldcat,
          'CTLPC'     'I_FINAL_DET'        'Risk Catagory'(041)  space space    CHANGING fp_i_fieldcat,
          'HORDA'     'I_FINAL_DET'  'Credit Horizon Date'(065)  space space    CHANGING fp_i_fieldcat,
          'SKFOR'     'I_FINAL_DET'    'Total Receivables'(059)  space space    CHANGING fp_i_fieldcat,
          'OEIKW'     'I_FINAL_DET'           'Open Sales'(060)  space space    CHANGING fp_i_fieldcat,
          'OLIKW'     'I_FINAL_DET'        'Open Delivery'(061)  space space    CHANGING fp_i_fieldcat,
          'OFAKW'     'I_FINAL_DET'            'Open VFX3'(062)  space space    CHANGING fp_i_fieldcat,
          'DTREV'     'I_FINAL_DET'      'Last Int Review'(057)  space space    CHANGING fp_i_fieldcat,
          'NXTRV'     'I_FINAL_DET'      'Next Int Review'(058)  space space    CHANGING fp_i_fieldcat,
          'SBGRP'     'I_FINAL_DET'       'Credit Rep Grp'(042)  space space    CHANGING fp_i_fieldcat,
          'STEXT'     'I_FINAL_DET'  'Credit Rep Grp Name'(043)  space space    CHANGING fp_i_fieldcat,
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
          'KDGRP'     'I_FINAL_DET'    'Customer Group'(069)  space space    CHANGING fp_i_fieldcat,
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
**-->Begin of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
          'CASE_ID'    'I_FINAL_DET'   'Case ID'              space space CHANGING fp_i_fieldcat.
**<--End of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.

ENDFORM. " F_PREPARE_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_FIELDCAT
*&---------------------------------------------------------------------*
*       Populate the field catalog for ALV display
*----------------------------------------------------------------------*
FORM f_populate_fieldcat  USING   fp_fnam           TYPE slis_fieldname       "fieldname
                                  fp_itab           TYPE slis_tabname         "table name
                                  fp_descr          TYPE scrtext_l            "field description
                                  fp_cfieldname     TYPE slis_fieldname       " field with currency unit
                                  fp_ctabname       TYPE slis_tabname         " and table
                         CHANGING fp_i_fieldcat     TYPE slis_t_fieldcat_alv. "Internal Table for Field Catalog

  DATA  lwa_fcat TYPE slis_fieldcat_alv. "work area for fieldcatalog

  STATICS lv_fpos TYPE sycucol. " Horizontal Cursor Position at PAI

  CLEAR lwa_fcat.
  lv_fpos = lv_fpos + 1.

  lwa_fcat-col_pos       = lv_fpos.
  lwa_fcat-fieldname     = fp_fnam.
  lwa_fcat-tabname       = fp_itab.
  lwa_fcat-seltext_l     = fp_descr.
  lwa_fcat-cfieldname    = fp_cfieldname.
  lwa_fcat-ctabname      = fp_ctabname.
* ---> Begin of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* The values of Amount field is maximum 15 including decimal, but we have kept
* 20 as maximum length.
  lwa_fcat-outputlen     = 20.
* <--- End of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016

*&-- Hiding different columns based on radiobuttons
  IF fp_fnam = 'NOT_DUE'
  AND ( rb_detdc = abap_true OR rb_sumdc = abap_true ).
    lwa_fcat-no_out = abap_true.
  ENDIF. " IF fp_fnam = 'NOT_DUE'

  IF rb_detdc = abap_true OR rb_detnt = abap_true.
    IF fp_fnam = 'BALANCE'
    OR fp_fnam = 'LAND1'
    OR fp_fnam = 'OBLIG'
    OR fp_fnam = 'KLPRZ'
    OR fp_fnam = 'HORDA'
    OR fp_fnam = 'SKFOR'
    OR fp_fnam = 'OEIKW'
    OR fp_fnam = 'OLIKW'
    OR fp_fnam = 'OFAKW'.
      lwa_fcat-no_out = abap_true.
    ENDIF. " IF fp_fnam = 'BALANCE'
  ENDIF. " IF rb_detdc = abap_true OR rb_detnt = abap_true

  IF rb_sumdc = abap_true OR rb_sumnt = abap_true .
    IF fp_fnam = 'HKONT'
    OR fp_fnam = 'BSCHL'
    OR fp_fnam = 'BLART'
    OR fp_fnam = 'BELNR'
    OR fp_fnam = 'XBLNR'
    OR fp_fnam = 'DMBTR'
    OR fp_fnam = 'WRBTR'
    OR fp_fnam = 'WAERS1'
    OR fp_fnam = 'BLDAT'
    OR fp_fnam = 'BUDAT'
    OR fp_fnam = 'AUGDT'
    OR fp_fnam = 'CPUDT'
    OR fp_fnam = 'AUGBL'
    OR fp_fnam = 'ZFBDT'
    OR fp_fnam = 'ZTERM'
    OR fp_fnam = 'MWSKZ'
    OR fp_fnam = 'PRCTR'
    OR fp_fnam = 'REBZG'
    OR fp_fnam = 'VBELN'
    OR fp_fnam = 'AUBEL'
    OR fp_fnam = 'BSTNK'
    OR fp_fnam = 'BSARK'
    OR fp_fnam = 'UMSKZ'
    OR fp_fnam = 'XREF1'
    OR fp_fnam = 'XREF2'
    OR fp_fnam = 'SGTXT'
    OR fp_fnam = 'OBLIG'
    OR fp_fnam = 'KLPRZ'
    OR fp_fnam = 'HORDA'
    OR fp_fnam = 'SKFOR'
    OR fp_fnam = 'OEIKW'
    OR fp_fnam = 'OLIKW'
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
    OR fp_fnam = 'ZUONR'
*<--End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
    OR fp_fnam = 'OFAKW'.
      lwa_fcat-no_out = abap_true.
    ENDIF. " IF fp_fnam = 'HKONT'
  ENDIF. " IF rb_sumdc = abap_true OR rb_sumnt = abap_true

  IF NOT rb_creif IS INITIAL.
    IF fp_fnam = 'BUKRS'
    OR fp_fnam = 'LAND1'
    OR fp_fnam = 'NAME1'
    OR fp_fnam = 'HKONT'
    OR fp_fnam = 'BSCHL'
    OR fp_fnam = 'BLART'
    OR fp_fnam = 'BELNR'
    OR fp_fnam = 'XBLNR'
    OR fp_fnam = 'DMBTR'
    OR fp_fnam = 'WAERS'
    OR fp_fnam = 'BALANCE'
    OR fp_fnam = 'NOT_DUE'
    OR fp_fnam = 'CALC2'
    OR fp_fnam = 'CALC3'
    OR fp_fnam = 'CALC4'
    OR fp_fnam = 'CALC5'
    OR fp_fnam = 'CALC6'
    OR fp_fnam = 'WRBTR'
    OR fp_fnam = 'WAERS1'
    OR fp_fnam = 'BLDAT'
    OR fp_fnam = 'BUDAT'
    OR fp_fnam = 'CPUDT'
    OR fp_fnam = 'AUGDT'
    OR fp_fnam = 'AUGBL'
    OR fp_fnam = 'ZFBDT'
    OR fp_fnam = 'ZTERM'
    OR fp_fnam = 'MWSKZ'
    OR fp_fnam = 'PRCTR'
    OR fp_fnam = 'REBZG'
    OR fp_fnam = 'VBELN'
    OR fp_fnam = 'AUBEL'
    OR fp_fnam = 'BSTNK'
    OR fp_fnam = 'BSARK'
    OR fp_fnam = 'UMSKZ'
    OR fp_fnam = 'XREF1'
    OR fp_fnam = 'XREF2'
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
    OR fp_fnam = 'ZUONR'
*<--End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
    OR fp_fnam = 'SGTXT'.
      lwa_fcat-no_out = abap_true.
    ENDIF. " IF fp_fnam = 'BUKRS'
  ENDIF. " IF NOT rb_creif IS INITIAL
  APPEND lwa_fcat TO fp_i_fieldcat. "fp_i_fieldcat.
  CLEAR lwa_fcat.

ENDFORM. " F_POPULATE_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_FINAL_TABLE
*&---------------------------------------------------------------------*
*       Populate the final table for ALV display
*----------------------------------------------------------------------*
FORM f_populate_final_table_dd  USING fp_i_kna1  TYPE ty_t_kna1
                                      fp_i_knkk  TYPE ty_t_knkk
                                      fp_i_bsid  TYPE ty_t_bsid
                                      fp_i_bsad  TYPE ty_t_bsad
                                      fp_i_vbrp  TYPE ty_t_vbrp
                                      fp_i_vbak  TYPE ty_t_vbak
                                      fp_i_t024b TYPE ty_t_024b
                         CHANGING fp_i_final_det TYPE ty_t_final_det.

*-->Begin of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH
  TYPES: BEGIN OF ty_udmcaseattr00,
            case_guid TYPE sysuuid_c,      " UUID in character form
            fin_kunnr TYPE udm_kunnr,      " Key of Customer in Accounts Receivable Accounting
            fin_bukrs TYPE bukrs,          " Company Code
          END OF ty_udmcaseattr00,

          BEGIN OF ty_scmg_t_case_attr,
            case_guid TYPE scmg_case_guid, " Technical Case Key (Case GUID)
            ext_key   TYPE scmg_ext_key,   " Case ID
            ext_ref   TYPE scmg_ext_ref,   " External reference
          END OF ty_scmg_t_case_attr.

  DATA: li_udmcaseattr00    TYPE STANDARD TABLE OF ty_udmcaseattr00,    " Internal table
        li_scmg_t_case_attr TYPE STANDARD TABLE OF ty_scmg_t_case_attr, " Internal table
        li_bsid             TYPE STANDARD TABLE OF ty_bsid,             " Internal table
        lv_indx             TYPE syindex.                               " Loop Index
*<--End of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.

  DATA: lwa_final_det   TYPE ty_final_det,
        lv_total_dmbtr  TYPE dmbtr,    " Balance
        lv_total_cal30  TYPE dmbtr,    " Total 30 Days Balance
        lv_total_cal60  TYPE dmbtr,    " Total 60 Days Balance
        lv_total_cal90  TYPE dmbtr,    " Total 90 Days Balance
        lv_total_cal120 TYPE dmbtr,    " Total 120 Days Balance
        lv_total_cal150 TYPE dmbtr,    " Total 150 Days Balance
        lv_total_cal151 TYPE dmbtr,    " Total 151 Days Balance
        lv_dmbtr  TYPE dmbtr,          " Balance
        lv_cal30  TYPE dmbtr,          " Total 30 Days Balance
        lv_cal60  TYPE dmbtr,          " Total 60 Days Balance
        lv_cal90  TYPE dmbtr,          " Total 90 Days Balance
        lv_cal120 TYPE dmbtr,          " Total 120 Days Balance
        lv_cal150 TYPE dmbtr,          " Total 150 Days Balance
        lv_cal151 TYPE dmbtr,          " Total 151 Days Balance
        lv_index1       TYPE sy-index, " Loop Index
        lv_index        TYPE sy-index, " Loop Index
        lv_name         TYPE name1.    " Name

  FIELD-SYMBOLS: <lfs_knkk>  TYPE ty_knkk,
                 <lfs_bsid>  TYPE ty_bsid,
                 <lfs_bsad>  TYPE ty_bsad,
                 <lfs_t024b> TYPE ty_t024b,
                 <lfs_kna1>  TYPE ty_kna1,
                 <lfs_vbrp>  TYPE ty_vbrp,
                 <lfs_vbak>  TYPE ty_vbak,
*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
                 <lfs_final> TYPE ty_final_det, " Field symbol
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016

*-->Begin of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                 <lfs_scmg_t_case_attr> TYPE ty_scmg_t_case_attr, " Field symbol
                 <lfs_udmcaseattr00>    TYPE ty_udmcaseattr00.    " Field symbol
**Fetching FSCM Disptue Case ID field
  li_bsid[] = fp_i_bsid[].
  SORT li_bsid BY kunnr bukrs.
  DELETE ADJACENT DUPLICATES FROM li_bsid COMPARING kunnr bukrs.
  IF li_bsid IS NOT INITIAL.
    SELECT case_guid     " UUID in character form
           fin_kunnr     " Key of Customer in Accounts Receivable Accounting
           fin_bukrs     " Company Code
      INTO TABLE li_udmcaseattr00
      FROM udmcaseattr00 " Dispute Case Attributes
      FOR ALL ENTRIES IN li_bsid
      WHERE fin_kunnr = li_bsid-kunnr
      AND fin_bukrs = li_bsid-bukrs.
    IF sy-subrc IS INITIAL.
      SORT li_udmcaseattr00 BY case_guid.

      SELECT case_guid        " Technical Case Key (Case GUID)
             ext_key          " Case ID
             ext_ref          " External reference
        INTO TABLE li_scmg_t_case_attr
        FROM scmg_t_case_attr " Case Attributes
        FOR ALL ENTRIES IN li_udmcaseattr00
        WHERE case_guid = li_udmcaseattr00-case_guid.
      IF sy-subrc IS INITIAL.
        SORT li_scmg_t_case_attr BY case_guid ext_ref.
        SORT li_udmcaseattr00 BY fin_kunnr fin_bukrs.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_bsid IS NOT INITIAL
*<--End of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.

*&---------------Populating Final Internal Table----------------------
  LOOP AT fp_i_knkk ASSIGNING <lfs_knkk>.

    CLEAR: lv_total_dmbtr,
             lv_total_cal30,
             lv_total_cal60,
             lv_total_cal90,
             lv_total_cal120,
             lv_total_cal150,
             lv_total_cal151,
             lv_name.

*&-- Populating all values from KNKK table
    lwa_final_det-bukrs = <lfs_knkk>-bukrs. " Company Code
    lwa_final_det-kunnr = <lfs_knkk>-kunnr. " Customer Number
    SHIFT lwa_final_det-kunnr LEFT DELETING LEADING '0'.
    lwa_final_det-kkber = <lfs_knkk>-kkber. " Credit Control
    lwa_final_det-knkli = <lfs_knkk>-knkli. " Credit Account
    SHIFT lwa_final_det-knkli LEFT DELETING LEADING '0'.
    lwa_final_det-klimk = <lfs_knkk>-klimk. " Credit Limit
    lwa_final_det-ctlpc = <lfs_knkk>-ctlpc. " Risk Category
    lwa_final_det-sbgrp = <lfs_knkk>-sbgrp. " Credit Rep Grp
    lwa_final_det-dtrev = <lfs_knkk>-dtrev.
    lwa_final_det-nxtrv = <lfs_knkk>-nxtrv.
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
    lwa_final_det-kdgrp = <lfs_knkk>-kdgrp. " Customer Group Name
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
    READ TABLE fp_i_kna1 ASSIGNING <lfs_kna1>
                         WITH KEY kunnr = <lfs_knkk>-kunnr
                         BINARY SEARCH.
    IF sy-subrc IS INITIAL.
*&-- Populating land and customer name
      lwa_final_det-land1 = <lfs_kna1>-land1. " Country
      lwa_final_det-name1 = <lfs_kna1>-name1. " Name1
      lv_name             = <lfs_kna1>-name1. " Name1
    ENDIF. " IF sy-subrc IS INITIAL

    READ TABLE fp_i_t024b ASSIGNING <lfs_t024b>
                         WITH KEY sbgrp = <lfs_knkk>-sbgrp
                                  kkber = <lfs_knkk>-kkber
                                  BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lwa_final_det-stext = <lfs_t024b>-stext. " Credit Rep grp Name
    ENDIF. " IF sy-subrc IS INITIAL

*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
*&-- It might happen that there are no Open Items for a Customer.
    IF fp_i_bsid IS NOT INITIAL.
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016

* NOt using Bainary search as the entries with this key are not unique, we need the first entry.
      READ TABLE fp_i_bsid TRANSPORTING NO FIELDS
                           WITH KEY bukrs = <lfs_knkk>-bukrs
                                    kunnr = <lfs_knkk>-kunnr.
*-----------------------------------------------------------------
*& -- This below code will execute when only I_BSID[] has entries.
*-----------------------------------------------------------------
      IF sy-subrc IS INITIAL.
        CLEAR: lv_index,
               lv_total_dmbtr,
               lv_total_cal30,
               lv_total_cal60,
               lv_total_cal90,
               lv_total_cal120,
               lv_total_cal150,
               lv_total_cal151.

        lv_index = sy-tabix.

        LOOP AT fp_i_bsid ASSIGNING <lfs_bsid> FROM lv_index.

          IF <lfs_bsid>-bukrs NE <lfs_knkk>-bukrs
          OR <lfs_bsid>-kunnr NE <lfs_knkk>-kunnr.
            EXIT.
          ELSE. " ELSE -> IF <lfs_bsid>-bukrs NE <lfs_knkk>-bukrs
            IF <lfs_bsid>-shkzg = c_shkzg.
              <lfs_bsid>-dmbtr = <lfs_bsid>-dmbtr * -1.
            ENDIF. " IF <lfs_bsid>-shkzg = c_shkzg
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by SMUKHER on 18-July-2016
* For Doc currency also , the Debit / Credit indicator should be considered.
            IF <lfs_bsid>-shkzg = c_shkzg.
              <lfs_bsid>-wrbtr = <lfs_bsid>-wrbtr * -1.
            ENDIF. " IF <lfs_bsid>-shkzg = c_shkzg
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by SMUKHER on 18-July-2016

            lv_total_dmbtr = lv_total_dmbtr + <lfs_bsid>-dmbtr. " Sum Total Balance
*&-- To appear on every line
            lwa_final_det-bukrs = <lfs_knkk>-bukrs. " Company Code
            lwa_final_det-kunnr = <lfs_knkk>-kunnr. " Customer Number
            SHIFT lwa_final_det-kunnr LEFT DELETING LEADING '0'.
            lwa_final_det-name1 = lv_name.
            lwa_final_det-land1 = <lfs_kna1>-land1. " Country

*&-- Populating all the BSID entries
            lwa_final_det-hkont = <lfs_bsid>-hkont. " Recon Acc
            SHIFT lwa_final_det-hkont LEFT DELETING LEADING '0'.
            lwa_final_det-bschl = <lfs_bsid>-bschl. " Posting Key
            lwa_final_det-blart = <lfs_bsid>-blart. " Document Type
            lwa_final_det-belnr = <lfs_bsid>-belnr. " Document Number
            SHIFT lwa_final_det-belnr LEFT DELETING LEADING '0'.
            lwa_final_det-xblnr = <lfs_bsid>-xblnr. " Reference Document
            SHIFT lwa_final_det-xblnr LEFT DELETING LEADING '0'.
            lwa_final_det-dmbtr = <lfs_bsid>-dmbtr. " Amount in Local Currency
            lwa_final_det-waers = <lfs_knkk>-waers. " Local Currency Key
            lwa_final_det-wrbtr  = <lfs_bsid>-wrbtr. " Amt in Doc Currency
            lwa_final_det-waers1 = <lfs_bsid>-waers. " Document Currency
            lwa_final_det-bldat = <lfs_bsid>-bldat. " Document date in document
            lwa_final_det-budat = <lfs_bsid>-budat. " Posting date in the document
            lwa_final_det-cpudt = <lfs_bsid>-cpudt. " Day on which accounting document was entered
            lwa_final_det-augdt = <lfs_bsid>-augdt. " Clearing Date
            lwa_final_det-augbl = <lfs_bsid>-augbl. " Document number of the clearing document
            SHIFT lwa_final_det-augbl LEFT DELETING LEADING '0'.
            lwa_final_det-zfbdt = <lfs_bsid>-zfbdt. " Baseline Date for Due Date Calculation
            lwa_final_det-zterm = <lfs_bsid>-zterm. " Terms of Payment Key
            lwa_final_det-mwskz = <lfs_bsid>-mwskz. " Tax on sales/purchases code
            lwa_final_det-prctr = <lfs_bsid>-prctr. " Profit Center
            SHIFT lwa_final_det-prctr LEFT DELETING LEADING '0'.
            lwa_final_det-rebzg = <lfs_bsid>-rebzg. "Number of the Invoice the Transaction Belongs to
            lwa_final_det-vbeln = <lfs_bsid>-vbeln. "Billing Document
            SHIFT lwa_final_det-vbeln LEFT DELETING LEADING '0'.
            lwa_final_det-umskz = <lfs_bsid>-umskz. "Special G/L Indicator
            lwa_final_det-xref1 = <lfs_bsid>-xref1. "Business Partner Reference Key
            lwa_final_det-xref2 = <lfs_bsid>-xref2. "Business Partner Reference Key
            lwa_final_det-sgtxt = <lfs_bsid>-sgtxt. "Item Text
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
            lwa_final_det-zuonr = <lfs_bsid>-zuonr. " Assignment number.
            lwa_final_det-kdgrp = <lfs_knkk>-kdgrp. " Customer Group Name
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016

*&-- Populating sales doc, PO order num and PO type
            READ TABLE fp_i_vbrp ASSIGNING <lfs_vbrp>
                                 WITH KEY vbeln = <lfs_bsid>-vbeln
                                 BINARY SEARCH.
            IF sy-subrc IS INITIAL.
              lwa_final_det-aubel = <lfs_vbrp>-aubel. "Sales Document

              READ TABLE fp_i_vbak ASSIGNING <lfs_vbak>
                                   WITH KEY vbeln = <lfs_vbrp>-aubel
                                   BINARY SEARCH.
              IF sy-subrc IS INITIAL.
                lwa_final_det-bstnk = <lfs_vbak>-bstnk. "Customer purchase order number
                SHIFT lwa_final_det-bstnk LEFT DELETING LEADING '0'.
                lwa_final_det-bsark = <lfs_vbak>-bsark. "	Customer purchase order type
              ENDIF. " IF sy-subrc IS INITIAL

            ENDIF. " IF sy-subrc IS INITIAL

*& -----------------Populating the logic for Calcution fields-----------------------
*-----------------------------------------------------------------------------------
*                  For Document Date Reports ( both summary and detailed )
*-----------------------------------------------------------------------------------
*&-- Begin of delete for D2_OTC_RDD_0092 Defect#2008 by SMUKHER on 08-Sep-2016
*&------------------------------Commented out---------------------------------------
*            IF <lfs_bsid>-budat LE p_datum AND <lfs_bsid>-budat GE gv_date30.
*              lwa_final_det-calc1 = <lfs_bsid>-dmbtr. " 0-30 Days
*            ELSEIF <lfs_bsid>-budat LE gv_date31 AND <lfs_bsid>-budat GE gv_date60.
*              lwa_final_det-calc2 = <lfs_bsid>-dmbtr. " 31-60 Days
*            ELSEIF <lfs_bsid>-budat LE gv_date61 AND <lfs_bsid>-budat GE gv_date90.
*              lwa_final_det-calc3 = <lfs_bsid>-dmbtr. " 61-90 Days
*            ELSEIF <lfs_bsid>-budat LE gv_date91 AND <lfs_bsid>-budat GE gv_date120.
*              lwa_final_det-calc4 = <lfs_bsid>-dmbtr. " 91-120 Days
*            ELSEIF <lfs_bsid>-budat LE gv_date121 AND <lfs_bsid>-budat GE gv_date150.
*              lwa_final_det-calc5 = <lfs_bsid>-dmbtr. " 121- 150 Days
*            ELSEIF <lfs_bsid>-budat LE gv_date151.
*              lwa_final_det-calc6 = <lfs_bsid>-dmbtr. " > 151 Days
*            ENDIF. " IF <lfs_bsid>-budat LE p_datum AND <lfs_bsid>-budat GE gv_date30
*&-- End of delete for D2_OTC_RDD_0092 Defect#2008 by SMUKHER on 08-Sep-2016

*&-- Begin of change for D2_OTC_RDD_0092 Defect#2008 by SMUKHER on 08-Sep-2016
* We will use BSID-BLDAT and not BSID-BUDAT for all Aging bucket calculation logic.
            IF <lfs_bsid>-bldat LE p_datum AND <lfs_bsid>-bldat GE gv_date30.
              lwa_final_det-calc1 = <lfs_bsid>-dmbtr. " 0-30 Days
            ELSEIF <lfs_bsid>-bldat LE gv_date31 AND <lfs_bsid>-bldat GE gv_date60.
              lwa_final_det-calc2 = <lfs_bsid>-dmbtr. " 31-60 Days
            ELSEIF <lfs_bsid>-bldat LE gv_date61 AND <lfs_bsid>-bldat GE gv_date90.
              lwa_final_det-calc3 = <lfs_bsid>-dmbtr. " 61-90 Days
            ELSEIF <lfs_bsid>-bldat LE gv_date91 AND <lfs_bsid>-bldat GE gv_date120.
              lwa_final_det-calc4 = <lfs_bsid>-dmbtr. " 91-120 Days
            ELSEIF <lfs_bsid>-bldat LE gv_date121 AND <lfs_bsid>-bldat GE gv_date150.
              lwa_final_det-calc5 = <lfs_bsid>-dmbtr. " 121- 150 Days
            ELSEIF <lfs_bsid>-bldat LE gv_date151.
              lwa_final_det-calc6 = <lfs_bsid>-dmbtr. " > 151 Days
            ENDIF. " IF <lfs_bsid>-bldat LE p_datum AND <lfs_bsid>-bldat GE gv_date30

*-->Begin of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
**Populating FSCM Disptue Case ID field in final table
            READ TABLE li_udmcaseattr00 TRANSPORTING NO FIELDS WITH KEY fin_kunnr = <lfs_bsid>-kunnr
                                                                        fin_bukrs = <lfs_bsid>-bukrs.

            IF sy-subrc IS INITIAL.
              lv_indx = sy-tabix.
              LOOP AT li_udmcaseattr00 ASSIGNING <lfs_udmcaseattr00> FROM lv_indx.

                IF <lfs_udmcaseattr00>-fin_kunnr NE <lfs_bsid>-kunnr OR
                   <lfs_udmcaseattr00>-fin_bukrs NE <lfs_bsid>-bukrs.
                  EXIT.
                ENDIF. " IF <lfs_udmcaseattr00>-fin_kunnr NE <lfs_bsid>-kunnr OR

                READ TABLE li_scmg_t_case_attr ASSIGNING <lfs_scmg_t_case_attr> WITH KEY case_guid = <lfs_udmcaseattr00>-case_guid
                                                                                         ext_ref = <lfs_bsid>-zuonr
                                                                                BINARY SEARCH.
                IF sy-subrc IS INITIAL.
                  lwa_final_det-case_id = <lfs_scmg_t_case_attr>-ext_key.
                ENDIF. " IF sy-subrc IS INITIAL

              ENDLOOP. " LOOP AT li_udmcaseattr00 ASSIGNING <lfs_udmcaseattr00> FROM lv_indx
            ENDIF. " IF sy-subrc IS INITIAL
*<--End of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.

*&-- There might be documents where the Document Date is greater than the Posting Date.
* In such cases, the Amount will not be mapped to any of the Aging Buckets , since the Doc
* date of the Document is in future to the Key Date.
* In such cases, the amount of the Document should go to 0-30 Days bucket.
            IF lwa_final_det-calc1 IS INITIAL
            AND lwa_final_det-calc2 IS INITIAL
            AND lwa_final_det-calc3 IS INITIAL
            AND lwa_final_det-calc4 IS INITIAL
            AND lwa_final_det-calc5 IS INITIAL
            AND lwa_final_det-calc6 IS INITIAL
            AND p_datum LT <lfs_bsid>-bldat
            .
              lwa_final_det-calc1 = <lfs_bsid>-dmbtr. " 0-30 Days
            ENDIF. " IF lwa_final_det-calc1 IS INITIAL
*&-- End of change for D2_OTC_RDD_0092 Defect#2008 by SMUKHER on 08-Sep-2016
*------------------------------------------------------------------------------
*& -- This below code will be executed if both I_BSAD + I_BSID has entries.
*------------------------------------------------------------------------------

*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by SMUKHER on 18-July-2016
            lv_total_cal30  = lv_total_cal30  + lwa_final_det-calc1.
            lv_total_cal60  = lv_total_cal60  + lwa_final_det-calc2.
            lv_total_cal90  = lv_total_cal90  + lwa_final_det-calc3.
            lv_total_cal120 = lv_total_cal120 + lwa_final_det-calc4.
            lv_total_cal150 = lv_total_cal150 + lwa_final_det-calc5.
            lv_total_cal151 = lv_total_cal151 + lwa_final_det-calc6.

            IF rb_sumdc IS NOT INITIAL
            OR rb_sumnt IS NOT INITIAL.
              CLEAR: lwa_final_det-not_due,
                     lwa_final_det-calc1,
                     lwa_final_det-calc2,
                     lwa_final_det-calc3,
                     lwa_final_det-calc4,
                     lwa_final_det-calc5,
                     lwa_final_det-calc6.
            ENDIF. " IF rb_sumdc IS NOT INITIAL
*& -----------------------Sum Total Fields----------------------------------
            IF rb_detdc IS NOT INITIAL
            OR rb_detnt IS NOT INITIAL.
              APPEND lwa_final_det TO fp_i_final_det.
*&-- these fields need to be cleared for next line updation
              CLEAR:lwa_final_det-hkont,
                    lwa_final_det-bschl,
                    lwa_final_det-blart,
                    lwa_final_det-belnr,
                    lwa_final_det-xblnr,
                    lwa_final_det-dmbtr,
                    lwa_final_det-waers,
                    lwa_final_det-wrbtr,
                    lwa_final_det-bldat,
                    lwa_final_det-budat,
                    lwa_final_det-cpudt,
                    lwa_final_det-augdt,
                    lwa_final_det-augbl,
                    lwa_final_det-zfbdt,
                    lwa_final_det-zterm,
                    lwa_final_det-mwskz,
                    lwa_final_det-prctr,
                    lwa_final_det-rebzg,
                    lwa_final_det-vbeln,
                    lwa_final_det-umskz,
                    lwa_final_det-xref1,
                    lwa_final_det-xref2,
                    lwa_final_det-sgtxt,
                    lwa_final_det-aubel,
                    lwa_final_det-bstnk,
                    lwa_final_det-bsark,
                    lwa_final_det-bukrs,
                    lwa_final_det-name1,
                    lwa_final_det-land1,
                    lwa_final_det-kunnr,
                    lwa_final_det-calc1,
                    lwa_final_det-calc2,
                    lwa_final_det-calc3,
                    lwa_final_det-calc4,
                    lwa_final_det-calc5,
                    lwa_final_det-calc6,
                    lwa_final_det-not_due,
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                    lwa_final_det-kdgrp, "Customer Grp
                    lwa_final_det-zuonr, "Assignment number
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
*<--Begin of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                    lwa_final_det-case_id.
*<--End of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
            ENDIF. " IF rb_detdc IS NOT INITIAL
*<--- End of change for D2_OTC_RDD_0092 Def#1804 by SMUKHER on 18-July-2016
          ENDIF. " IF <lfs_bsid>-bukrs NE <lfs_knkk>-bukrs
        ENDLOOP. " LOOP AT fp_i_bsid ASSIGNING <lfs_bsid> FROM lv_index


        IF rb_sumdc IS NOT INITIAL
        OR rb_sumnt IS NOT INITIAL.
          lwa_final_det-balance = lv_total_dmbtr.
          lwa_final_det-calc1   = lv_total_cal30.
          lwa_final_det-calc2   = lv_total_cal60.
          lwa_final_det-calc3   = lv_total_cal90.
          lwa_final_det-calc4   = lv_total_cal120.
          lwa_final_det-calc5   = lv_total_cal150.
          lwa_final_det-calc6   = lv_total_cal151.
          APPEND lwa_final_det TO fp_i_final_det.
          CLEAR lwa_final_det.

*& -- The below code block will add a single line of summed up
*     values for each Company Code - Customer combination.
          lv_dmbtr = lv_dmbtr + lv_total_dmbtr.
          lv_cal30 = lv_cal30 + lv_total_cal30.
          lv_cal60 = lv_cal60 + lv_total_cal60.
          lv_cal90 = lv_cal90 + lv_total_cal90.
          lv_cal120 = lv_cal120 + lv_total_cal120.
          lv_cal150 = lv_cal150 + lv_total_cal150.
          lv_cal151 = lv_cal151 + lv_total_cal151.
        ENDIF. " IF rb_sumdc IS NOT INITIAL
*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF fp_i_bsid IS NOT INITIAL
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016

*-----------------------------------------------------------------
*& -- This below code will execute when only I_BSAD[] has entries.
*-----------------------------------------------------------------
*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
*&-- It might happen there are no Clearing Docs for the current Customer
    IF fp_i_bsad IS NOT INITIAL.
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
* NOt using Bainary search as the entries with this key are not unique, we need the first entry.
      READ TABLE fp_i_bsad TRANSPORTING NO FIELDS
                           WITH KEY bukrs = <lfs_knkk>-bukrs
                                    kunnr = <lfs_knkk>-kunnr.
      IF sy-subrc IS INITIAL.
        CLEAR: lv_index1,
               lv_total_dmbtr,
               lv_total_cal30,
               lv_total_cal60,
               lv_total_cal90,
               lv_total_cal120,
               lv_total_cal150,
               lv_total_cal151.
        lv_index1 = sy-tabix.

*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
*        SORT fp_i_final_det BY bukrs
*                               kunnr.
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016

        LOOP AT fp_i_bsad ASSIGNING <lfs_bsad> FROM lv_index1.
          IF <lfs_bsad>-bukrs NE <lfs_knkk>-bukrs
          OR <lfs_bsad>-kunnr NE <lfs_knkk>-kunnr.
            EXIT.
          ELSE. " ELSE -> IF <lfs_bsad>-bukrs NE <lfs_knkk>-bukrs
            IF <lfs_bsad>-shkzg = c_shkzg.
              <lfs_bsad>-dmbtr = <lfs_bsad>-dmbtr * -1.
            ENDIF. " IF <lfs_bsad>-shkzg = c_shkzg
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by SMUKHER on 18-July-2016
* For Doc currency also , the Debit / Credit indicator should be considered.
            IF <lfs_bsad>-shkzg = c_shkzg.
              <lfs_bsad>-wrbtr = <lfs_bsad>-wrbtr * -1.
            ENDIF. " IF <lfs_bsad>-shkzg = c_shkzg
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by SMUKHER on 18-July-2016

            lv_total_dmbtr = lv_total_dmbtr + <lfs_bsad>-dmbtr. " Sum Total Balance

            lwa_final_det-bukrs = <lfs_knkk>-bukrs. " Company Code
            lwa_final_det-kunnr = <lfs_knkk>-kunnr. " Customer Number
            SHIFT lwa_final_det-kunnr LEFT DELETING LEADING '0'.
            lwa_final_det-name1 = lv_name.

*&-- Populating all the BSAD entries
            lwa_final_det-hkont = <lfs_bsad>-hkont. " Recon Acc
            SHIFT lwa_final_det-hkont LEFT DELETING LEADING '0'.
            lwa_final_det-bschl = <lfs_bsad>-bschl. " Posting Key
            lwa_final_det-blart = <lfs_bsad>-blart. " Document Type
            lwa_final_det-belnr = <lfs_bsad>-belnr. " Document Number
            SHIFT lwa_final_det-belnr LEFT DELETING LEADING '0'.
            lwa_final_det-xblnr = <lfs_bsad>-xblnr. " Reference Document
            SHIFT lwa_final_det-xblnr LEFT DELETING LEADING '0'.
            lwa_final_det-dmbtr = <lfs_bsad>-dmbtr. " Amount in Local Currency
            lwa_final_det-waers = <lfs_knkk>-waers. " Local Currency Key
            lwa_final_det-wrbtr = <lfs_bsad>-wrbtr. " Amount in Doc Currency
            lwa_final_det-waers1 = <lfs_bsad>-waers. " Document Currency
            lwa_final_det-bldat = <lfs_bsad>-bldat. " Document date in document
            lwa_final_det-budat = <lfs_bsad>-budat. " Posting date in the document
            lwa_final_det-cpudt = <lfs_bsad>-cpudt. " Day on which accounting document was entered

            lwa_final_det-augdt = <lfs_bsad>-augdt. " Clearing Date
            lwa_final_det-augbl = <lfs_bsad>-augbl. " Document number of the clearing document

            SHIFT lwa_final_det-augbl LEFT DELETING LEADING '0'.
            lwa_final_det-zfbdt = <lfs_bsad>-zfbdt. " Baseline Date for Due Date Calculation
            lwa_final_det-zterm = <lfs_bsad>-zterm. "Terms of Payment Key
            lwa_final_det-mwskz = <lfs_bsad>-mwskz. "  Tax on sales/purchases code
            lwa_final_det-prctr = <lfs_bsad>-prctr. "  Profit Center
            SHIFT lwa_final_det-prctr LEFT DELETING LEADING '0'.
            lwa_final_det-rebzg = <lfs_bsad>-rebzg. "Number of the Invoice the Transaction Belongs to
            lwa_final_det-vbeln = <lfs_bsad>-vbeln. "Billing Document
            SHIFT lwa_final_det-vbeln LEFT DELETING LEADING '0'.
            lwa_final_det-umskz = <lfs_bsad>-umskz. "Special G/L Indicator
            lwa_final_det-xref1 = <lfs_bsad>-xref1. "Business Partner Reference Key
            lwa_final_det-xref2 = <lfs_bsad>-xref2. "Business Partner Reference Key
            lwa_final_det-sgtxt = <lfs_bsad>-sgtxt. "Item Text
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
            lwa_final_det-zuonr = <lfs_bsad>-zuonr. "Assignment number
            lwa_final_det-kdgrp = <lfs_knkk>-kdgrp. " Customer Group Name
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016


*&-- Populating Sales doc, PO num and PO type
            READ TABLE fp_i_vbrp ASSIGNING <lfs_vbrp>
                                 WITH KEY vbeln = <lfs_bsad>-vbeln
                                 BINARY SEARCH.
            IF sy-subrc IS INITIAL.
              lwa_final_det-aubel = <lfs_vbrp>-aubel. "Sales Document

              READ TABLE fp_i_vbak ASSIGNING <lfs_vbak>
                                   WITH KEY vbeln = <lfs_vbrp>-aubel
                                   BINARY SEARCH.
              IF sy-subrc IS INITIAL.
                lwa_final_det-bstnk = <lfs_vbak>-bstnk. "Customer purchase order number
                SHIFT lwa_final_det-bstnk LEFT DELETING LEADING '0'.
                lwa_final_det-bsark = <lfs_vbak>-bsark. "	Customer purchase order type
              ENDIF. " IF sy-subrc IS INITIAL

            ENDIF. " IF sy-subrc IS INITIAL

*&-- Begin of delete for D2_OTC_RDD_0092 Defect#2008 by SMUKHER on 08-Sep-2016
*&------------------------------Commented out---------------------------------------
*            IF  <lfs_bsad>-budat LE p_datum AND <lfs_bsad>-budat GE gv_date30.
*              lwa_final_det-calc1 =  <lfs_bsad>-dmbtr.
*            ELSEIF <lfs_bsad>-budat LE gv_date31 AND <lfs_bsad>-budat GE gv_date60.
*              lwa_final_det-calc2 =  <lfs_bsad>-dmbtr.
*            ELSEIF <lfs_bsad>-budat LE gv_date61 AND <lfs_bsad>-budat GE gv_date90.
*              lwa_final_det-calc3 =  <lfs_bsad>-dmbtr.
*            ELSEIF <lfs_bsad>-budat LE gv_date91 AND <lfs_bsad>-budat GE gv_date120.
*              lwa_final_det-calc4 =  <lfs_bsad>-dmbtr.
*            ELSEIF <lfs_bsad>-budat LE gv_date121 AND <lfs_bsad>-budat GE gv_date150.
*              lwa_final_det-calc5 =  <lfs_bsad>-dmbtr.
*            ELSEIF <lfs_bsad>-budat LE gv_date151.
*              lwa_final_det-calc6 =  <lfs_bsad>-dmbtr.
*            ENDIF. " IF <lfs_bsad>-budat LE p_datum AND <lfs_bsad>-budat GE gv_date30
*&-- End of delete for D2_OTC_RDD_0092 Defect#2008 by SMUKHER on 08-Sep-2016

*&-- Begin of change for D2_OTC_RDD_0092 Defect#2008 by SMUKHER on 08-Sep-2016
            IF  <lfs_bsad>-bldat LE p_datum AND <lfs_bsad>-bldat GE gv_date30.
              lwa_final_det-calc1 =  <lfs_bsad>-dmbtr.
            ELSEIF <lfs_bsad>-bldat LE gv_date31 AND <lfs_bsad>-bldat GE gv_date60.
              lwa_final_det-calc2 =  <lfs_bsad>-dmbtr.
            ELSEIF <lfs_bsad>-bldat LE gv_date61 AND <lfs_bsad>-bldat GE gv_date90.
              lwa_final_det-calc3 =  <lfs_bsad>-dmbtr.
            ELSEIF <lfs_bsad>-bldat LE gv_date91 AND <lfs_bsad>-bldat GE gv_date120.
              lwa_final_det-calc4 =  <lfs_bsad>-dmbtr.
            ELSEIF <lfs_bsad>-bldat LE gv_date121 AND <lfs_bsad>-bldat GE gv_date150.
              lwa_final_det-calc5 =  <lfs_bsad>-dmbtr.
            ELSEIF <lfs_bsad>-bldat LE gv_date151.
              lwa_final_det-calc6 =  <lfs_bsad>-dmbtr.
            ENDIF. " IF <lfs_bsad>-bldat LE p_datum AND <lfs_bsad>-bldat GE gv_date30

*&-- There might be documents where the Document Date is greater than the Posting Date.
* In such cases, the Amount will not be mapped to any of the Aging Buckets , since the Doc
* date of the Document is in future to the Key Date.
* In such cases, the amount of the Document should go to 0-30 Days bucket.
            IF lwa_final_det-calc1 IS INITIAL
            AND lwa_final_det-calc2 IS INITIAL
            AND lwa_final_det-calc3 IS INITIAL
            AND lwa_final_det-calc4 IS INITIAL
            AND lwa_final_det-calc5 IS INITIAL
            AND lwa_final_det-calc6 IS INITIAL
            AND p_datum LT <lfs_bsad>-bldat
            .
              lwa_final_det-calc1 = <lfs_bsad>-dmbtr. " 0-30 Days
            ENDIF. " IF lwa_final_det-calc1 IS INITIAL
          ENDIF. " IF <lfs_bsad>-bukrs NE <lfs_knkk>-bukrs
*&-- End of change for D2_OTC_RDD_0092 Defect#2008 by SMUKHER on 08-Sep-2016
          IF rb_sumdc IS NOT INITIAL.
*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
*&-- Even in case of Clearing Docs, the summation of amount should happen
*    for each Customer.

            SHIFT <lfs_bsad>-kunnr LEFT DELETING LEADING '0'.
            READ TABLE fp_i_final_det ASSIGNING <lfs_final>
                                      WITH KEY bukrs = <lfs_bsad>-bukrs
                                               kunnr = <lfs_bsad>-kunnr.
*                                               BINARY SEARCH.  " Defect 2646 Removing
*            binary serach as the same table is getting appended so, sort won't happen
            IF sy-subrc IS INITIAL.
              <lfs_final>-balance = <lfs_final>-balance + <lfs_bsad>-dmbtr.
              <lfs_final>-calc1 = <lfs_final>-calc1 + lwa_final_det-calc1.
              <lfs_final>-calc2 = <lfs_final>-calc2 + lwa_final_det-calc2.
              <lfs_final>-calc3 = <lfs_final>-calc3 + lwa_final_det-calc3.
              <lfs_final>-calc4 = <lfs_final>-calc4 + lwa_final_det-calc4.
              <lfs_final>-calc5 = <lfs_final>-calc5 + lwa_final_det-calc5.
              <lfs_final>-calc6 = <lfs_final>-calc6 + lwa_final_det-calc6.
            ELSE. " ELSE -> IF sy-subrc IS INITIAL
              lwa_final_det-balance = lwa_final_det-dmbtr.
              APPEND lwa_final_det TO fp_i_final_det.
              CLEAR lwa_final_det.
            ENDIF. " IF sy-subrc IS INITIAL
            UNASSIGN <lfs_final>.

            CLEAR: lwa_final_det-dmbtr,
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016

                   lwa_final_det-calc1,
                   lwa_final_det-calc2,
                   lwa_final_det-calc3,
                   lwa_final_det-calc4,
                   lwa_final_det-calc5,
                   lwa_final_det-calc6.
          ENDIF. " IF rb_sumdc IS NOT INITIAL
*& -----------------------Sunm Total Fields----------------------------------
          IF rb_detdc IS NOT INITIAL
          OR rb_detnt IS NOT INITIAL.
            APPEND lwa_final_det TO fp_i_final_det.
*&-- these fields need to be cleared for next line updation
            CLEAR:lwa_final_det-hkont,
                  lwa_final_det-bschl,
                  lwa_final_det-blart,
                  lwa_final_det-belnr,
                  lwa_final_det-xblnr,
                  lwa_final_det-dmbtr,
                  lwa_final_det-waers,
                  lwa_final_det-wrbtr,
                  lwa_final_det-bldat,
                  lwa_final_det-budat,
                  lwa_final_det-cpudt,
                  lwa_final_det-augdt,
                  lwa_final_det-augbl,
                  lwa_final_det-zfbdt,
                  lwa_final_det-zterm,
                  lwa_final_det-mwskz,
                  lwa_final_det-prctr,
                  lwa_final_det-rebzg,
                  lwa_final_det-vbeln,
                  lwa_final_det-umskz,
                  lwa_final_det-xref1,
                  lwa_final_det-xref2,
                  lwa_final_det-sgtxt,
                  lwa_final_det-aubel,
                  lwa_final_det-bstnk,
                  lwa_final_det-bsark,
                  lwa_final_det-bukrs,
                  lwa_final_det-name1,
                  lwa_final_det-land1,
                  lwa_final_det-kunnr,
                  lwa_final_det-calc1,
                  lwa_final_det-calc2,
                  lwa_final_det-calc3,
                  lwa_final_det-calc4,
                  lwa_final_det-calc5,
                  lwa_final_det-calc6,
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                  lwa_final_det-kdgrp, "Customer Grp
                  lwa_final_det-zuonr, "Assignment number
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
*<--Begin of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                  lwa_final_det-case_id.
*<--End of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
          ENDIF. " IF rb_detdc IS NOT INITIAL
        ENDLOOP. " LOOP AT fp_i_bsad ASSIGNING <lfs_bsad> FROM lv_index1

*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
      ELSE. " ELSE -> IF sy-subrc IS INITIAL
        CLEAR: lwa_final_det.
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
      ENDIF. " IF sy-subrc IS INITIAL

*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
      CLEAR lwa_final_det.
    ENDIF. " IF fp_i_bsad IS NOT INITIAL
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
  ENDLOOP. " LOOP AT fp_i_knkk ASSIGNING <lfs_knkk>

ENDFORM. " F_POPULATE_FINAL_TABLE
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_DATE
*&---------------------------------------------------------------------*
*       Add days to dates
*----------------------------------------------------------------------*
FORM f_populate_date  USING    fp_p_datum TYPE datum      " Start Date
                               fp_adsub   TYPE adsub      " Processing indicator
                               fp_days    TYPE psen_durdd " Days
                      CHANGING fp_lv_date TYPE datum.     " Start Date

  DATA: lwa_days TYPE psen_duration. " Duration in Years, Months, and Days

  CLEAR lwa_days.
  lwa_days-duryy = 0.
  lwa_days-durmm = 0.
  lwa_days-durdd = fp_days.
*&-- ADD/SUB days from date
  CALL FUNCTION 'HR_99S_DATE_ADD_SUB_DURATION' ##fm_subrc_ok
    EXPORTING
      im_date     = fp_p_datum
      im_operator = fp_adsub
      im_duration = lwa_days
    IMPORTING
      ex_date     = fp_lv_date.

  IF fp_lv_date IS INITIAL.
    CLEAR fp_lv_date.
  ENDIF. " IF fp_lv_date IS INITIAL

ENDFORM. " F_POPULATE_DATE
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*       ALV List or Grid Display
*----------------------------------------------------------------------*
FORM f_display_alv  USING    fp_i_fieldcat  TYPE slis_t_fieldcat_alv
                             fp_i_final_det TYPE ty_t_final_det.

  DATA: lwa_layo   TYPE slis_layout_alv. "work area

  CONSTANTS:  lc_a         TYPE char1         VALUE 'A',             " A
              lc_top_page  TYPE slis_formname VALUE 'F_TOP_OF_PAGE'. "top of page

*&-- Update header
  PERFORM f_top_header.
* ---> Begin of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* The below layout changes are cosmetic changes done.
  lwa_layo-colwidth_optimize = abap_true.
  lwa_layo-zebra = abap_true.
* <--- End of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016

*&-- Generating ALV for foreground and background
  IF sy-batch = abap_false.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program     = sy-repid
        i_callback_top_of_page = lc_top_page " TOP-OF-PAGE
        is_layout              = lwa_layo
        it_fieldcat            = fp_i_fieldcat
        i_save                 = lc_a
      TABLES
        t_outtab               = fp_i_final_det
      EXCEPTIONS
        program_error          = 1
        OTHERS                 = 2.
    IF sy-subrc <> 0.
      MESSAGE i000 WITH 'Report Display Failed'(067).
      LEAVE LIST-PROCESSING.
    ENDIF. " IF sy-subrc <> 0

  ELSE. " ELSE -> IF sy-batch = abap_false

    CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
      EXPORTING
        i_callback_program = sy-repid
        is_layout          = lwa_layo
        it_fieldcat        = fp_i_fieldcat
        i_save             = lc_a
      TABLES
        t_outtab           = fp_i_final_det
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
      MESSAGE i000 WITH 'Report Display Failed'(067).
      LEAVE LIST-PROCESSING.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF sy-batch = abap_false

ENDFORM. " F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*&      Form  F_TOP_HEADER
*&---------------------------------------------------------------------*
*       Design Header
*----------------------------------------------------------------------*
FORM f_top_header .

  CONSTANTS: lc_typ_h       TYPE char1 VALUE 'H', "H
             lc_typ_s       TYPE char1 VALUE 'S'. "S

  TYPES: ty_t_bapiret TYPE STANDARD TABLE OF bapiret2. "Bapi Returb Tab Type

* Local data declaration
  DATA: lv_date    TYPE char10,              "date variable
        lv_time    TYPE char10,              "time variable
        lv_lines   TYPE int4,                "records count of final table
        lx_address TYPE bapiaddr3,           "User Address Data
        lwa_listheader TYPE slis_listheader, "list header
        li_return  TYPE ty_t_bapiret.        "return table

  CONSTANTS: lc_colon TYPE char1 VALUE ':', "Colon
             lc_slash TYPE char1 VALUE '/'. "Slash

  lwa_listheader-typ  = lc_typ_h.
  lwa_listheader-key  = 'Report'(044).
  lwa_listheader-info = 'AR Aging Report'(045).
  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.

  lwa_listheader-typ  = lc_typ_s.
  lwa_listheader-key  = 'User Name'(046).

* Get user details
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    IMPORTING
      address  = lx_address
    TABLES
      return   = li_return.


*&-- Username
  IF lx_address-fullname IS NOT INITIAL.
    MOVE lx_address-fullname TO lwa_listheader-info.
  ELSE. " ELSE -> IF lx_address-fullname IS NOT INITIAL
    MOVE sy-uname TO lwa_listheader-info.
  ENDIF. " IF lx_address-fullname IS NOT INITIAL

  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.


*&-- Date and time
  lwa_listheader-typ = lc_typ_s.
  lwa_listheader-key = 'Date and Time'(047).

  CONCATENATE sy-uzeit+0(2)
              sy-uzeit+2(2)
              sy-uzeit+4(2)
         INTO lv_time
         SEPARATED BY lc_colon.

  CONCATENATE sy-datum+4(2)
              sy-datum+6(2)
              sy-datum+0(4)
         INTO lv_date
         SEPARATED BY lc_slash.
  CONCATENATE lv_date
              lv_time
         INTO lwa_listheader-info
         SEPARATED BY space.
  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.

*&-- Report type
  lwa_listheader-typ = lc_typ_s.
  lwa_listheader-key = 'Report Type'(051).
  IF NOT rb_detdc IS INITIAL.
    lwa_listheader-info = 'AR Detail Report by Doc Date'(052).
  ELSEIF NOT rb_detnt IS INITIAL.
    lwa_listheader-info = 'AR Detail Report by Net Due Dt'(053).
  ELSEIF NOT rb_sumdc IS INITIAL.
    lwa_listheader-info = 'AR Summary Report by Doc Date'(054).
  ELSEIF NOT rb_sumnt IS INITIAL.
    lwa_listheader-info = 'AR Summary Rep by Net Due Date'(055).
  ELSE. " ELSE -> IF NOT rb_detdc IS INITIAL
    lwa_listheader-info = 'Customer Credit Information'(056).
  ENDIF. " IF NOT rb_detdc IS INITIAL
  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.

*&-- No of records
  DESCRIBE TABLE i_final_det[] LINES lv_lines.
  lwa_listheader-typ  = lc_typ_s.
  lwa_listheader-key  = 'Total Records'(048).
  MOVE lv_lines TO lwa_listheader-info.
  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.

ENDFORM. " F_TOP_HEADER
*&---------------------------------------------------------------------*
*&      Form  sub_top_of_page
*&---------------------------------------------------------------------*
*      Subroutine is used to call TOP OF PAGE event dynamically
*----------------------------------------------------------------------*
*      <-- i_top using internal table for the TOP_OF_PAGE
*----------------------------------------------------------------------*
FORM f_top_of_page. "#EC CALLED
* Subroutine for top of page
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = i_listheader.


ENDFORM. "f_top_of_page
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_DATES
*&---------------------------------------------------------------------*
*       Populate the global dates for calculation
*----------------------------------------------------------------------*
FORM f_populate_dates .
  CONSTANTS: lc_sign TYPE ddsign VALUE '-'. " Type of SIGN component in row type of a Ranges type
* Populate the 30, 60, 90, 120, 150 day(s) date.
*&-- 30 Days Date
  PERFORM f_populate_date USING p_datum
                                lc_sign
                                30
                       CHANGING gv_date30.
*&-- 31 Days Date
  PERFORM f_populate_date USING p_datum
                                lc_sign
                                31
                       CHANGING gv_date31.
*&-- 60 Days Date
  PERFORM f_populate_date USING p_datum
                                lc_sign
                                60
                       CHANGING gv_date60.
*&-- 61 Days Date
  PERFORM f_populate_date USING p_datum
                                lc_sign
                                61
                       CHANGING gv_date61.
*&-- 90 Days Date
  PERFORM f_populate_date USING p_datum
                                lc_sign
                                90
                       CHANGING gv_date90.
*&-- 91 Days Date
  PERFORM f_populate_date USING p_datum
                                lc_sign
                                91
                       CHANGING gv_date91.
*&-- 120 Days Date
  PERFORM f_populate_date USING p_datum
                                lc_sign
                                120
                       CHANGING gv_date120.
*&-- 121 Days Date
  PERFORM f_populate_date USING p_datum
                                lc_sign
                                121
                       CHANGING gv_date121.
*&-- 150 Days Date
  PERFORM f_populate_date USING p_datum
                                lc_sign
                                150
                       CHANGING gv_date150.
*&-- 151 Days Date
  PERFORM f_populate_date USING p_datum
                                lc_sign
                                151
                       CHANGING gv_date151.
ENDFORM. " F_POPULATE_DATES
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_FINAL_TABLE_ND
*&---------------------------------------------------------------------*
*       Populate final table for ALV display
*----------------------------------------------------------------------*
FORM f_populate_final_table_nd  USING fp_i_kna1  TYPE ty_t_kna1
                                      fp_i_knkk  TYPE ty_t_knkk
                                      fp_i_bsid  TYPE ty_t_bsid
                                      fp_i_bsad  TYPE ty_t_bsad
                                      fp_i_vbrp  TYPE ty_t_vbrp
                                      fp_i_vbak  TYPE ty_t_vbak
                                      fp_i_t024b TYPE ty_t_024b
                         CHANGING fp_i_final_det TYPE ty_t_final_det.

*-->Begin of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH
  TYPES: BEGIN OF ty_udmcaseattr00,
            case_guid TYPE sysuuid_c,      " UUID in character form
            fin_kunnr TYPE udm_kunnr,      " Key of Customer in Accounts Receivable Accounting
            fin_bukrs TYPE bukrs,          " Company Code
          END OF ty_udmcaseattr00,

          BEGIN OF ty_scmg_t_case_attr,
            case_guid TYPE scmg_case_guid, " Technical Case Key (Case GUID)
            ext_key   TYPE scmg_ext_key,   " Case ID
            ext_ref   TYPE scmg_ext_ref,   " External reference
          END OF ty_scmg_t_case_attr.

  DATA: li_udmcaseattr00    TYPE STANDARD TABLE OF ty_udmcaseattr00,    " Internal table
        li_scmg_t_case_attr TYPE STANDARD TABLE OF ty_scmg_t_case_attr, " Internal table
        li_bsid             TYPE STANDARD TABLE OF ty_bsid,             " Internal table
        lv_indx             TYPE syindex.                               " Loop Index
*<--End of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.

  CONSTANTS: lc_sign TYPE ddsign VALUE '+'. " Type of SIGN component in row type of a Ranges type

  DATA: lwa_final_det   TYPE ty_final_det,
        lv_total_bal    TYPE dmbtr,      " Balance
        lv_total_ntdue  TYPE dmbtr,      " Not due
        lv_days         TYPE psen_durdd, " Duration of imputation in days
        lv_net_due      TYPE dzfbdt,     " Baseline Date for Due Date Calculation
        lv_total_cal30  TYPE dmbtr,      " Total 30 Days Balance
        lv_total_cal60  TYPE dmbtr,      " Total 60 Days Balance
        lv_total_cal90  TYPE dmbtr,      " Total 90 Days Balance
        lv_total_cal120 TYPE dmbtr,      " Total 120 Days Balance
        lv_total_cal150 TYPE dmbtr,      " Total 150 Days Balance
        lv_total_cal151 TYPE dmbtr,      " Total 151 Days Balance
        lv_bal    TYPE dmbtr,            " Balance
        lv_ntdue  TYPE dmbtr,            " Amount in Local Currency
        lv_cal30  TYPE dmbtr,            " Total 30 Days Balance
        lv_cal60  TYPE dmbtr,            " Total 60 Days Balance
        lv_cal90  TYPE dmbtr,            " Total 90 Days Balance
        lv_cal120 TYPE dmbtr,            " Total 120 Days Balance
        lv_cal150 TYPE dmbtr,            " Total 150 Days Balance
        lv_cal151 TYPE dmbtr,            " Total 151 Days Balance
        lv_index1       TYPE sy-index,   " Loop Index
        lv_index        TYPE sy-index,   " Loop Index
        lv_name         TYPE name1.      " Name

  FIELD-SYMBOLS: <lfs_knkk>   TYPE ty_knkk,
                 <lfs_bsid>   TYPE ty_bsid,
                 <lfs_bsad>   TYPE ty_bsad,
                 <lfs_t024b>  TYPE ty_t024b,
                 <lfs_kna1>   TYPE ty_kna1,
                 <lfs_vbrp>   TYPE ty_vbrp,
                 <lfs_vbak>   TYPE ty_vbak,
*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
                 <lfs_final>  TYPE ty_final_det, " Field symbol
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
*-->Begin of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                 <lfs_scmg_t_case_attr> TYPE ty_scmg_t_case_attr, " Field symbol
                 <lfs_udmcaseattr00>    TYPE ty_udmcaseattr00.    " Field symbol
**Fetching FSCM Disptue Case ID field
  li_bsid[] = fp_i_bsid[].
  SORT li_bsid BY kunnr bukrs.
  DELETE ADJACENT DUPLICATES FROM li_bsid COMPARING kunnr bukrs.
  IF li_bsid IS NOT INITIAL.
    SELECT case_guid     " UUID in character form
           fin_kunnr     " Key of Customer in Accounts Receivable Accounting
           fin_bukrs     " Company Code
      INTO TABLE li_udmcaseattr00
      FROM udmcaseattr00 " Dispute Case Attributes
      FOR ALL ENTRIES IN li_bsid
      WHERE fin_kunnr = li_bsid-kunnr
      AND fin_bukrs = li_bsid-bukrs.
    IF sy-subrc IS INITIAL.
      SORT li_udmcaseattr00 BY case_guid.

      SELECT case_guid        " Technical Case Key (Case GUID)
             ext_key          " Case ID
             ext_ref          " External reference
        INTO TABLE li_scmg_t_case_attr
        FROM scmg_t_case_attr " Case Attributes
        FOR ALL ENTRIES IN li_udmcaseattr00
        WHERE case_guid = li_udmcaseattr00-case_guid.
      IF sy-subrc IS INITIAL.
        SORT li_scmg_t_case_attr BY case_guid ext_ref.
        SORT li_udmcaseattr00 BY fin_kunnr fin_bukrs.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_bsid IS NOT INITIAL
*<--End of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.

*&---------------Populating Final Internal Table----------------------
  LOOP AT fp_i_knkk ASSIGNING <lfs_knkk>.

    CLEAR:   lv_total_bal,
             lv_total_ntdue,
             lv_total_cal30,
             lv_total_cal60,
             lv_total_cal90,
             lv_total_cal120,
             lv_total_cal150,
             lv_total_cal151,
             lv_name.

*&-- Details of Summary report
    lwa_final_det-bukrs = <lfs_knkk>-bukrs. " Company Code
    lwa_final_det-kunnr = <lfs_knkk>-kunnr. " Customer Number
    SHIFT lwa_final_det-kunnr LEFT DELETING LEADING '0'.
    lwa_final_det-kkber = <lfs_knkk>-kkber. " Credit Control
    lwa_final_det-knkli = <lfs_knkk>-knkli. " Credit Account
    SHIFT lwa_final_det-knkli LEFT DELETING LEADING '0'.
    lwa_final_det-klimk = <lfs_knkk>-klimk. " Credit Limit
    lwa_final_det-ctlpc = <lfs_knkk>-ctlpc. " Risk Category
    lwa_final_det-sbgrp = <lfs_knkk>-sbgrp. " Credit Rep Grp
    lwa_final_det-dtrev = <lfs_knkk>-dtrev.
    lwa_final_det-nxtrv = <lfs_knkk>-nxtrv.
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
    lwa_final_det-kdgrp = <lfs_knkk>-kdgrp. "Customer Grp
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016

*&-- Populating Land and Customer Name
    READ TABLE fp_i_kna1 ASSIGNING <lfs_kna1>
                         WITH KEY kunnr = <lfs_knkk>-kunnr
                         BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lwa_final_det-land1 = <lfs_kna1>-land1. " Country
      lwa_final_det-name1 = <lfs_kna1>-name1. " Name1
      lv_name             = <lfs_kna1>-name1. " Name1
    ENDIF. " IF sy-subrc IS INITIAL

*&-- Populating Credit Rep Grp Name
    READ TABLE fp_i_t024b ASSIGNING <lfs_t024b>
                         WITH KEY sbgrp = <lfs_knkk>-sbgrp
                                  kkber = <lfs_knkk>-kkber
                                  BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lwa_final_det-stext = <lfs_t024b>-stext. " Credit Rep grp Name
    ENDIF. " IF sy-subrc IS INITIAL

*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
    IF fp_i_bsid IS NOT INITIAL.
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016

* NOt using Bainary search as the entries with this key are not unique, we need the first entry.
*&-- Populating data from BSID table
      READ TABLE fp_i_bsid TRANSPORTING NO FIELDS
                           WITH KEY bukrs = <lfs_knkk>-bukrs
                                    kunnr = <lfs_knkk>-kunnr.
*-----------------------------------------------------------------
*& -- This below code will execute when only I_BSID[] has entries.
*-----------------------------------------------------------------
      IF   sy-subrc IS INITIAL.
        CLEAR: lv_index,
               lv_total_bal,
               lv_total_ntdue,
               lv_total_cal30,
               lv_total_cal60,
               lv_total_cal90,
               lv_total_cal120,
               lv_total_cal150,
               lv_total_cal151.

        lv_index = sy-tabix.

        LOOP AT fp_i_bsid ASSIGNING <lfs_bsid> FROM lv_index.

          IF <lfs_bsid>-bukrs NE <lfs_knkk>-bukrs
          OR <lfs_bsid>-kunnr NE <lfs_knkk>-kunnr.
            EXIT.
          ELSE. " ELSE -> IF <lfs_bsid>-bukrs NE <lfs_knkk>-bukrs
            IF <lfs_bsid>-shkzg = c_shkzg.
              <lfs_bsid>-dmbtr = <lfs_bsid>-dmbtr * -1.
            ENDIF. " IF <lfs_bsid>-shkzg = c_shkzg
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by SMUKHER on 18-July-2016
* For Doc currency also , the Debit / Credit indicator should be considered.
            IF <lfs_bsid>-shkzg = c_shkzg.
              <lfs_bsid>-wrbtr = <lfs_bsid>-wrbtr * -1.
            ENDIF. " IF <lfs_bsid>-shkzg = c_shkzg
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by SMUKHER on 18-July-2016
*&-- Calculate Net due date
*********************************************************
            lv_days = <lfs_bsid>-zbd1t + <lfs_bsid>-zbd2t.
            PERFORM f_populate_date USING <lfs_bsid>-zfbdt
                                          lc_sign
                                          lv_days
                                 CHANGING lv_net_due.
*********************************************************

*&-- Initialising variables for balance
*&--  and not due amounts for summary table
*&-- Begin of delete for D2_OTC_RDD_0092 Defect#2008 by SMUKHER on 08-Sep-2016
*            IF <lfs_bsid>-budat LE p_datum.
*&-- End of delete for D2_OTC_RDD_0092 Defect#2008 by SMUKHER on 08-Sep-2016
*&-- Begin of change for D2_OTC_RDD_0092 Defect#2008 by SMUKHER on 08-Sep-2016
            IF <lfs_bsid>-bldat LE p_datum.
*&-- End of change for D2_OTC_RDD_0092 Defect#2008 by SMUKHER on 08-Sep-2016
              lv_total_bal = lv_total_bal + <lfs_bsid>-dmbtr. " Sum Total Balance
            ENDIF. " IF <lfs_bsid>-bldat LE p_datum

            IF lv_net_due GE p_datum.
              lv_total_ntdue = lv_total_ntdue + <lfs_bsid>-dmbtr. " Sum Total Not due
            ENDIF. " IF lv_net_due GE p_datum

            lwa_final_det-bukrs = <lfs_knkk>-bukrs. " Company Code
            lwa_final_det-kunnr = <lfs_knkk>-kunnr. " Customer Number
            SHIFT lwa_final_det-kunnr LEFT DELETING LEADING '0'.
            lwa_final_det-name1 = lv_name.
            lwa_final_det-land1 = <lfs_kna1>-land1. " Country

            lwa_final_det-hkont = <lfs_bsid>-hkont. " Recon Acc
            SHIFT lwa_final_det-hkont LEFT DELETING LEADING '0'.
            lwa_final_det-bschl = <lfs_bsid>-bschl. " Posting Key
            lwa_final_det-blart = <lfs_bsid>-blart. " Document Type
            lwa_final_det-belnr = <lfs_bsid>-belnr. " Document Number
            SHIFT lwa_final_det-belnr LEFT DELETING LEADING '0'.
            lwa_final_det-xblnr = <lfs_bsid>-xblnr. " Reference Document
            SHIFT lwa_final_det-xblnr LEFT DELETING LEADING '0'.
            lwa_final_det-dmbtr = <lfs_bsid>-dmbtr. " Amount in Local Currency
            lwa_final_det-waers = <lfs_knkk>-waers. " Local Currency Key
            lwa_final_det-wrbtr = <lfs_bsid>-wrbtr. " Amount in Doc Currency
            lwa_final_det-waers1 = <lfs_bsid>-waers. " Document Currency
            lwa_final_det-bldat = <lfs_bsid>-bldat. " Document date in document
            lwa_final_det-budat = <lfs_bsid>-budat. " Posting date in the document
            lwa_final_det-cpudt = <lfs_bsid>-cpudt. " Day on which accounting document was entered
            lwa_final_det-augdt = <lfs_bsid>-augdt. " Clearing Date
            lwa_final_det-augbl = <lfs_bsid>-augbl. " Document number of the clearing document
            lwa_final_det-zfbdt = <lfs_bsid>-zfbdt. " Baseline Date for Due Date Calculation
            lwa_final_det-zterm = <lfs_bsid>-zterm. " Terms of Payment Key
            lwa_final_det-mwskz = <lfs_bsid>-mwskz. "  Tax on sales/purchases code
            lwa_final_det-prctr = <lfs_bsid>-prctr. "  Profit Center
            SHIFT lwa_final_det-prctr LEFT DELETING LEADING '0'.
            lwa_final_det-rebzg = <lfs_bsid>-rebzg. "Number of the Invoice the Transaction Belongs to
            lwa_final_det-vbeln = <lfs_bsid>-vbeln. "Billing Document
            SHIFT lwa_final_det-vbeln LEFT DELETING LEADING '0'.
            lwa_final_det-umskz = <lfs_bsid>-umskz. "Special G/L Indicator
            lwa_final_det-xref1 = <lfs_bsid>-xref1. "Business Partner Reference Key
            lwa_final_det-xref2 = <lfs_bsid>-xref2. "Business Partner Reference Key
            lwa_final_det-sgtxt = <lfs_bsid>-sgtxt. "Item Text
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
            lwa_final_det-zuonr = <lfs_bsid>-zuonr. "Assignment number
            lwa_final_det-kdgrp = <lfs_knkk>-kdgrp. " Customer Group Name
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016


*&-- Populating Sales doc, PO Num, PO Type
            READ TABLE fp_i_vbrp ASSIGNING <lfs_vbrp>
                                 WITH KEY vbeln = <lfs_bsid>-vbeln
                                 BINARY SEARCH.
            IF sy-subrc IS INITIAL.
              lwa_final_det-aubel = <lfs_vbrp>-aubel. "Sales Document

              READ TABLE fp_i_vbak ASSIGNING <lfs_vbak>
                                   WITH KEY vbeln = <lfs_vbrp>-aubel
                                   BINARY SEARCH.
              IF sy-subrc IS INITIAL.
                lwa_final_det-bstnk = <lfs_vbak>-bstnk. "Customer purchase order number
                SHIFT lwa_final_det-bstnk LEFT DELETING LEADING '0'.
                lwa_final_det-bsark = <lfs_vbak>-bsark. "	Customer purchase order type
              ENDIF. " IF sy-subrc IS INITIAL

            ENDIF. " IF sy-subrc IS INITIAL

*& -----------------Populating the logic for Calcution fields-----------------------
*-----------------------------------------------------------------------------------
*                  For Net Date Reports ( both summary and detailed )
*-----------------------------------------------------------------------------------
            IF lv_net_due LE p_datum AND lv_net_due GE gv_date30.
              lwa_final_det-calc1 = <lfs_bsid>-dmbtr. " 0-30 Days
            ELSEIF lv_net_due LE gv_date31 AND lv_net_due GE gv_date60.
              lwa_final_det-calc2 = <lfs_bsid>-dmbtr. " 31-60 Days
            ELSEIF lv_net_due LE gv_date61 AND lv_net_due GE gv_date90.
              lwa_final_det-calc3 = <lfs_bsid>-dmbtr. " 61-90 Days
            ELSEIF lv_net_due LE gv_date91 AND lv_net_due GE gv_date120.
              lwa_final_det-calc4 = <lfs_bsid>-dmbtr. " 91-120 Days
            ELSEIF lv_net_due LE gv_date121 AND lv_net_due GE gv_date150.
              lwa_final_det-calc5 = <lfs_bsid>-dmbtr. " 121- 150 Days
            ELSEIF lv_net_due LE gv_date151.
              lwa_final_det-calc6 = <lfs_bsid>-dmbtr. " > 151 Days
            ELSE. " ELSE -> IF lv_net_due LE p_datum AND lv_net_due GE gv_date30
              lwa_final_det-not_due = <lfs_bsid>-dmbtr.
            ENDIF. " IF lv_net_due LE p_datum AND lv_net_due GE gv_date30

*-->Begin of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
**Populating FSCM Disptue Case ID field in final table
            READ TABLE li_udmcaseattr00 TRANSPORTING NO FIELDS WITH KEY fin_kunnr = <lfs_bsid>-kunnr
                                                                        fin_bukrs = <lfs_bsid>-bukrs.
            IF sy-subrc IS INITIAL.
              lv_indx = sy-tabix.
              LOOP AT li_udmcaseattr00 ASSIGNING <lfs_udmcaseattr00> FROM lv_indx.

                IF <lfs_udmcaseattr00>-fin_kunnr NE <lfs_bsid>-kunnr OR
                   <lfs_udmcaseattr00>-fin_bukrs NE <lfs_bsid>-bukrs.
                  EXIT.
                ENDIF. " IF <lfs_udmcaseattr00>-fin_kunnr NE <lfs_bsid>-kunnr OR

                READ TABLE li_scmg_t_case_attr ASSIGNING <lfs_scmg_t_case_attr> WITH KEY case_guid = <lfs_udmcaseattr00>-case_guid
                                                                                         ext_ref = <lfs_bsid>-zuonr
                                                                                BINARY SEARCH.
                IF sy-subrc IS INITIAL.
                  lwa_final_det-case_id = <lfs_scmg_t_case_attr>-ext_key.
                ENDIF. " IF sy-subrc IS INITIAL

              ENDLOOP. " LOOP AT li_udmcaseattr00 ASSIGNING <lfs_udmcaseattr00> FROM lv_indx
            ENDIF. " IF sy-subrc IS INITIAL
*<--End of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.

*------------------------------------------------------------------------------
*& -- This below code will be executed if both I_BSAD + I_BSID has entries.
*------------------------------------------------------------------------------

*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by SMUKHER on 18-July-2016
            lv_total_cal30  = lv_total_cal30  + lwa_final_det-calc1.
            lv_total_cal60  = lv_total_cal60  + lwa_final_det-calc2.
            lv_total_cal90  = lv_total_cal90  + lwa_final_det-calc3.
            lv_total_cal120 = lv_total_cal120 + lwa_final_det-calc4.
            lv_total_cal150 = lv_total_cal150 + lwa_final_det-calc5.
            lv_total_cal151 = lv_total_cal151 + lwa_final_det-calc6.

            IF rb_sumdc IS NOT INITIAL
            OR rb_sumnt IS NOT INITIAL.
              CLEAR: lwa_final_det-not_due,
                     lwa_final_det-calc1,
                     lwa_final_det-calc2,
                     lwa_final_det-calc3,
                     lwa_final_det-calc4,
                     lwa_final_det-calc5,
                     lwa_final_det-calc6.
            ENDIF. " IF rb_sumdc IS NOT INITIAL
*& -----------------------Sum Total Fields----------------------------------
            IF rb_detdc IS NOT INITIAL
            OR rb_detnt IS NOT INITIAL.
              APPEND lwa_final_det TO fp_i_final_det.
*&-- these fields need to be cleared for next line updation
              CLEAR:lwa_final_det-hkont,
                    lwa_final_det-bschl,
                    lwa_final_det-blart,
                    lwa_final_det-belnr,
                    lwa_final_det-xblnr,
                    lwa_final_det-dmbtr,
                    lwa_final_det-waers,
                    lwa_final_det-wrbtr,
                    lwa_final_det-bldat,
                    lwa_final_det-budat,
                    lwa_final_det-cpudt,
                    lwa_final_det-augdt,
                    lwa_final_det-augbl,
                    lwa_final_det-zfbdt,
                    lwa_final_det-zterm,
                    lwa_final_det-mwskz,
                    lwa_final_det-prctr,
                    lwa_final_det-rebzg,
                    lwa_final_det-vbeln,
                    lwa_final_det-umskz,
                    lwa_final_det-xref1,
                    lwa_final_det-xref2,
                    lwa_final_det-sgtxt,
                    lwa_final_det-aubel,
                    lwa_final_det-bstnk,
                    lwa_final_det-bsark,
                    lwa_final_det-bukrs,
                    lwa_final_det-name1,
                    lwa_final_det-land1,
                    lwa_final_det-kunnr,
                    lwa_final_det-calc1,
                    lwa_final_det-calc2,
                    lwa_final_det-calc3,
                    lwa_final_det-calc4,
                    lwa_final_det-calc5,
                    lwa_final_det-calc6,
                    lwa_final_det-not_due,
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                    lwa_final_det-kdgrp, "Customer Grp
                    lwa_final_det-zuonr, "Assignment number
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
*<--Begin of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                    lwa_final_det-case_id.
*<--End of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
            ENDIF. " IF rb_detdc IS NOT INITIAL
*<--- End of change for D2_OTC_RDD_0092 Def#1804 by SMUKHER on 18-July-2016
          ENDIF. " IF <lfs_bsid>-bukrs NE <lfs_knkk>-bukrs
        ENDLOOP. " LOOP AT fp_i_bsid ASSIGNING <lfs_bsid> FROM lv_index


        IF rb_sumdc IS NOT INITIAL
        OR rb_sumnt IS NOT INITIAL.
          lwa_final_det-balance = lv_total_bal.
          lwa_final_det-not_due = lv_total_ntdue.
          lwa_final_det-calc1 = lv_total_cal30.
          lwa_final_det-calc2 = lv_total_cal60.
          lwa_final_det-calc3 = lv_total_cal90.
          lwa_final_det-calc4 = lv_total_cal120.
          lwa_final_det-calc5 = lv_total_cal150.
          lwa_final_det-calc6 = lv_total_cal151.
          APPEND lwa_final_det TO fp_i_final_det.
          CLEAR lwa_final_det.

*& -- The below code block will add a single line of summed up
*     values for each Company Code - Customer combination.
          lv_bal   = lv_bal   + lv_total_bal.
          lv_ntdue = lv_ntdue + lv_total_ntdue.
          lv_cal30 = lv_cal30 + lv_total_cal30.
          lv_cal60 = lv_cal60 + lv_total_cal60.
          lv_cal90 = lv_cal90 + lv_total_cal90.
          lv_cal120 = lv_cal120 + lv_total_cal120.
          lv_cal150 = lv_cal150 + lv_total_cal150.
          lv_cal151 = lv_cal151 + lv_total_cal151.
        ENDIF. " IF rb_sumdc IS NOT INITIAL

*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF fp_i_bsid IS NOT INITIAL
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016

*-----------------------------------------------------------------
*& -- This below code will execute when only I_BSAD[] has entries.
*-----------------------------------------------------------------
*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
    IF fp_i_bsad IS NOT INITIAL.
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016

* NOt using Bainary search as the entries with this key are not unique, we need the first entry.
      READ TABLE fp_i_bsad TRANSPORTING NO FIELDS
                           WITH KEY bukrs = <lfs_knkk>-bukrs
                                    kunnr = <lfs_knkk>-kunnr.

      IF sy-subrc IS INITIAL.
        CLEAR: lv_index1,
               lv_total_bal,
               lv_total_ntdue,
               lv_total_cal30,
               lv_total_cal60,
               lv_total_cal90,
               lv_total_cal120,
               lv_total_cal150,
               lv_total_cal151.
        lv_index1 = sy-tabix.

*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
*        SORT fp_i_final_det BY bukrs
*                               kunnr.
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016

        LOOP AT fp_i_bsad ASSIGNING <lfs_bsad> FROM lv_index1.
          IF <lfs_bsad>-bukrs NE <lfs_knkk>-bukrs
          OR <lfs_bsad>-kunnr NE <lfs_knkk>-kunnr.
            EXIT.
          ELSE. " ELSE -> IF <lfs_bsad>-bukrs NE <lfs_knkk>-bukrs
            IF <lfs_bsad>-shkzg = c_shkzg.
              <lfs_bsad>-dmbtr = <lfs_bsad>-dmbtr * -1.
            ENDIF. " IF <lfs_bsad>-shkzg = c_shkzg
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by SMUKHER on 18-July-2016
* For Doc currency also , the Debit / Credit indicator should be considered.
            IF <lfs_bsad>-shkzg = c_shkzg.
              <lfs_bsad>-wrbtr = <lfs_bsad>-wrbtr * -1.
            ENDIF. " IF <lfs_bsad>-shkzg = c_shkzg
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by SMUKHER on 18-July-2016
*&-- Calculate Net due date
*********************************************************
            CLEAR: lv_days,
                   lv_net_due.
            lv_days = <lfs_bsad>-zbd1t + <lfs_bsad>-zbd2t.
            PERFORM f_populate_date USING <lfs_bsad>-zfbdt
                                          lc_sign
                                          lv_days
                                 CHANGING lv_net_due.
*********************************************************
*&-- Initialising variables for balance
*&-- & net due for summary table
*&-- Begin of delete for D2_OTC_RDD_0092 Defect#2008 by SMUKHER on 08-Sep-2016
*            IF <lfs_bsad>-budat LE p_datum AND <lfs_bsad>-augdt GT p_datum.
*&-- End of delete for D2_OTC_RDD_0092 Defect#2008 by SMUKHER on 08-Sep-2016
*&-- Begin of change for D2_OTC_RDD_0092 Defect#2008 by SMUKHER on 08-Sep-2016
            IF <lfs_bsad>-bldat LE p_datum AND <lfs_bsad>-augdt GT p_datum.
*&-- End of change for D2_OTC_RDD_0092 Defect#2008 by SMUKHER on 08-Sep-2016
              lv_total_bal = lv_total_bal + <lfs_bsad>-dmbtr. " Sum Total Balance
            ENDIF. " IF <lfs_bsad>-bldat LE p_datum AND <lfs_bsad>-augdt GT p_datum

            IF lv_net_due GE p_datum.
              lv_total_ntdue = lv_total_ntdue + <lfs_bsad>-dmbtr. " Sum Total Not due
            ENDIF. " IF lv_net_due GE p_datum

            lwa_final_det-bukrs = <lfs_knkk>-bukrs. " Company Code
            lwa_final_det-kunnr = <lfs_knkk>-kunnr. " Customer Number
            SHIFT lwa_final_det-kunnr LEFT DELETING LEADING '0'.
            lwa_final_det-name1 = lv_name.
            lwa_final_det-hkont = <lfs_bsad>-hkont. " Recon Acc
            SHIFT lwa_final_det-hkont LEFT DELETING LEADING '0'.
            lwa_final_det-bschl = <lfs_bsad>-bschl. " Posting Key
            lwa_final_det-blart = <lfs_bsad>-blart. " Document Type
            lwa_final_det-belnr = <lfs_bsad>-belnr. " Document Number
            SHIFT lwa_final_det-belnr LEFT DELETING LEADING '0'.
            lwa_final_det-xblnr = <lfs_bsad>-xblnr. " Reference Document
            SHIFT lwa_final_det-xblnr LEFT DELETING LEADING '0'.
            lwa_final_det-dmbtr = <lfs_bsad>-dmbtr. " Amount in Local Currency
            lwa_final_det-waers = <lfs_knkk>-waers. " Local Currency Key
            lwa_final_det-wrbtr = <lfs_bsad>-wrbtr. " Amount in Doc Currency
            lwa_final_det-waers1 = <lfs_bsad>-waers. " Currency Key
            lwa_final_det-bldat = <lfs_bsad>-bldat. " Document date in document
            lwa_final_det-budat = <lfs_bsad>-budat. " Posting date in the document
            lwa_final_det-cpudt = <lfs_bsad>-cpudt. " Day on which accounting document was entered
            lwa_final_det-augdt = <lfs_bsad>-augdt. " Clearing Date
            lwa_final_det-augbl = <lfs_bsad>-augbl. " Document number of the clearing document
            lwa_final_det-zfbdt = <lfs_bsad>-zfbdt. " Baseline Date for Due Date Calculation
            lwa_final_det-zterm = <lfs_bsad>-zterm. " Terms of Payment Key
            lwa_final_det-mwskz = <lfs_bsad>-mwskz. " Tax on sales/purchases code
            lwa_final_det-prctr = <lfs_bsad>-prctr. " Profit Center
            SHIFT lwa_final_det-prctr LEFT DELETING LEADING '0'.
            lwa_final_det-rebzg = <lfs_bsad>-rebzg. " Number of the Invoice the Transaction Belongs to
            lwa_final_det-vbeln = <lfs_bsad>-vbeln. " Billing Document
            SHIFT lwa_final_det-vbeln LEFT DELETING LEADING '0'.
            lwa_final_det-umskz = <lfs_bsad>-umskz. " Special G/L Indicator
            lwa_final_det-xref1 = <lfs_bsad>-xref1. " Business Partner Reference Key
            lwa_final_det-xref2 = <lfs_bsad>-xref2. " Business Partner Reference Key
            lwa_final_det-sgtxt = <lfs_bsad>-sgtxt. " Item Text
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
            lwa_final_det-zuonr = <lfs_bsad>-zuonr. "Assignment number
            lwa_final_det-kdgrp = <lfs_knkk>-kdgrp. " Customer Group Name
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016

            READ TABLE fp_i_vbrp ASSIGNING <lfs_vbrp>
                                 WITH KEY vbeln = <lfs_bsad>-vbeln
                                 BINARY SEARCH.
            IF sy-subrc IS INITIAL.
              lwa_final_det-aubel = <lfs_vbrp>-aubel. "Sales Document

              READ TABLE fp_i_vbak ASSIGNING <lfs_vbak>
                                   WITH KEY vbeln = <lfs_vbrp>-aubel
                                   BINARY SEARCH.
              IF sy-subrc IS INITIAL.
                lwa_final_det-bstnk = <lfs_vbak>-bstnk. "Customer purchase order number
                SHIFT lwa_final_det-bstnk LEFT DELETING LEADING '0'.
                lwa_final_det-bsark = <lfs_vbak>-bsark. "	Customer purchase order type
              ENDIF. " IF sy-subrc IS INITIAL

            ENDIF. " IF sy-subrc IS INITIAL

            lwa_final_det-augdt = <lfs_bsad>-augdt. " Clearing Date
            lwa_final_det-augbl = <lfs_bsad>-augbl. " Document Number of the Clearing Document

            IF  lv_net_due LE p_datum AND lv_net_due GE gv_date30.
              lwa_final_det-calc1 =  <lfs_bsad>-dmbtr.
            ELSEIF lv_net_due LE gv_date31 AND lv_net_due GE gv_date60.
              lwa_final_det-calc2 =  <lfs_bsad>-dmbtr.
            ELSEIF lv_net_due LE gv_date61 AND lv_net_due GE gv_date90.
              lwa_final_det-calc3 =  <lfs_bsad>-dmbtr.
            ELSEIF lv_net_due LE gv_date91 AND lv_net_due GE gv_date120.
              lwa_final_det-calc4 =  <lfs_bsad>-dmbtr.
            ELSEIF lv_net_due LE gv_date121 AND lv_net_due GE gv_date150.
              lwa_final_det-calc5 =  <lfs_bsad>-dmbtr.
            ELSEIF lv_net_due LE gv_date151.
              lwa_final_det-calc6 =  <lfs_bsad>-dmbtr.
            ELSE. " ELSE -> IF lv_net_due LE p_datum AND lv_net_due GE gv_date30
              lwa_final_det-not_due = <lfs_bsad>-dmbtr.
            ENDIF. " IF lv_net_due LE p_datum AND lv_net_due GE gv_date30
          ENDIF. " IF <lfs_bsad>-bukrs NE <lfs_knkk>-bukrs

          IF rb_sumnt IS NOT INITIAL.
*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
*&-- Even in case of Clearing Docs, the summation of amount should happen
*    for each Customer.

            SHIFT <lfs_bsad>-kunnr LEFT DELETING LEADING '0'.
            READ TABLE fp_i_final_det ASSIGNING <lfs_final>
                                      WITH KEY bukrs = <lfs_bsad>-bukrs
                                               kunnr = <lfs_bsad>-kunnr.
*                                               BINARY SEARCH.  " Defect 2646 Removing
*            binary serach as the same table is getting appended so, sort won't happen
            IF sy-subrc IS INITIAL.
              <lfs_final>-balance = <lfs_final>-balance + <lfs_bsad>-dmbtr.
              <lfs_final>-calc1 = <lfs_final>-calc1 + lwa_final_det-calc1.
              <lfs_final>-calc2 = <lfs_final>-calc2 + lwa_final_det-calc2.
              <lfs_final>-calc3 = <lfs_final>-calc3 + lwa_final_det-calc3.
              <lfs_final>-calc4 = <lfs_final>-calc4 + lwa_final_det-calc4.
              <lfs_final>-calc5 = <lfs_final>-calc5 + lwa_final_det-calc5.
              <lfs_final>-calc6 = <lfs_final>-calc6 + lwa_final_det-calc6.
              <lfs_final>-not_due = <lfs_final>-not_due + lwa_final_det-not_due.
            ELSE. " ELSE -> IF sy-subrc IS INITIAL
              lwa_final_det-balance = lwa_final_det-dmbtr.
              APPEND lwa_final_det TO fp_i_final_det.
              CLEAR lwa_final_det.
            ENDIF. " IF sy-subrc IS INITIAL
            UNASSIGN <lfs_final>.

            CLEAR: lwa_final_det-dmbtr,
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
                   lwa_final_det-not_due,
                   lwa_final_det-calc1,
                   lwa_final_det-calc2,
                   lwa_final_det-calc3,
                   lwa_final_det-calc4,
                   lwa_final_det-calc5,
                   lwa_final_det-calc6.

          ENDIF. " IF rb_sumnt IS NOT INITIAL
*& -----------------------Sum Total Fields----------------------------------
          IF rb_detdc IS NOT INITIAL
          OR rb_detnt IS NOT INITIAL.
            APPEND lwa_final_det TO fp_i_final_det.
*&-- these fields need to be cleared for next line updation
            CLEAR:lwa_final_det-hkont,
                  lwa_final_det-bschl,
                  lwa_final_det-blart,
                  lwa_final_det-belnr,
                  lwa_final_det-xblnr,
                  lwa_final_det-dmbtr,
                  lwa_final_det-waers,
                  lwa_final_det-wrbtr,
                  lwa_final_det-bldat,
                  lwa_final_det-budat,
                  lwa_final_det-cpudt,
                  lwa_final_det-augdt,
                  lwa_final_det-augbl,
                  lwa_final_det-zfbdt,
                  lwa_final_det-zterm,
                  lwa_final_det-mwskz,
                  lwa_final_det-prctr,
                  lwa_final_det-rebzg,
                  lwa_final_det-vbeln,
                  lwa_final_det-umskz,
                  lwa_final_det-xref1,
                  lwa_final_det-xref2,
                  lwa_final_det-sgtxt,
                  lwa_final_det-aubel,
                  lwa_final_det-bstnk,
                  lwa_final_det-bsark,
                  lwa_final_det-bukrs,
                  lwa_final_det-name1,
                  lwa_final_det-land1,
                  lwa_final_det-kunnr,
                  lwa_final_det-calc1,
                  lwa_final_det-calc2,
                  lwa_final_det-calc3,
                  lwa_final_det-calc4,
                  lwa_final_det-calc5,
                  lwa_final_det-calc6,
                  lwa_final_det-not_due,
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                  lwa_final_det-kdgrp, "Customer Grp
                  lwa_final_det-zuonr, "Assignment number
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
*<--Begin of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                  lwa_final_det-case_id.
*<--End of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
          ENDIF. " IF rb_detdc IS NOT INITIAL

        ENDLOOP. " LOOP AT fp_i_bsad ASSIGNING <lfs_bsad> FROM lv_index1

*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
      ELSE. " ELSE -> IF sy-subrc IS INITIAL
        CLEAR: lwa_final_det.
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF fp_i_bsad IS NOT INITIAL

  ENDLOOP. " LOOP AT fp_i_knkk ASSIGNING <lfs_knkk>

ENDFORM. " F_POPULATE_FINAL_TABLE_ND
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_FINAL_TABLE_CR
*&---------------------------------------------------------------------*
*       Populate final credit report table
*----------------------------------------------------------------------*
FORM f_populate_final_table_cr  USING fp_i_knkk      TYPE ty_t_knkk
                             CHANGING fp_i_final_det TYPE ty_t_final_det.

  DATA: lwa_final    TYPE ty_final_det,
        lv_sptag     TYPE sptag, " Period to analyze - current date
        lv_refe1(16) TYPE p.     " Refe1(16) of type Packed Number

  FIELD-SYMBOLS: <lfs_knkk>  TYPE ty_knkk,
                 <lfs_t024b> TYPE ty_t024b.

*&-- Fill all data from KNKK table
  LOOP AT fp_i_knkk ASSIGNING <lfs_knkk>.
    lwa_final-kunnr = <lfs_knkk>-kunnr.
    SHIFT lwa_final-kunnr LEFT DELETING LEADING '0'.
    lwa_final-kkber = <lfs_knkk>-kkber.
    lwa_final-klimk = <lfs_knkk>-klimk.
    lwa_final-knkli = <lfs_knkk>-knkli.
    SHIFT lwa_final-knkli LEFT DELETING LEADING '0'.
    lwa_final-skfor = <lfs_knkk>-skfor.
    lwa_final-ctlpc = <lfs_knkk>-ctlpc.
    lwa_final-dtrev = <lfs_knkk>-dtrev.
    lwa_final-sbgrp = <lfs_knkk>-sbgrp.
    lwa_final-nxtrv = <lfs_knkk>-nxtrv.
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
    lwa_final-kdgrp = <lfs_knkk>-kdgrp. "Customer Grp
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016

    READ TABLE i_t024b ASSIGNING <lfs_t024b>
                             WITH KEY sbgrp = <lfs_knkk>-sbgrp
                                      kkber = <lfs_knkk>-kkber
                                      BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lwa_final-stext = <lfs_t024b>-stext. " Credit Rep grp Name
    ENDIF. " IF sy-subrc IS INITIAL
*&-- Set the horizon date
    CALL FUNCTION 'SD_CREDIT_HORIZON_DATE'
      EXPORTING
        i_kkber         = <lfs_knkk>-kkber
        i_ctlpc         = <lfs_knkk>-ctlpc
        i_horizon_exist = abap_true
      IMPORTING
        e_horizon_date  = lv_sptag.

    IF lv_sptag IS NOT INITIAL.
      lwa_final-horda = lv_sptag.
*&-- Get the components of sales values
      CALL FUNCTION 'SD_CREDIT_EXPOSURE'
        EXPORTING
          flag_open_delivery = abap_true
          flag_open_invoice  = abap_true
          flag_open_order    = abap_true
          horizon_date       = lv_sptag
          kkber              = <lfs_knkk>-kkber
          knkli              = <lfs_knkk>-knkli
        IMPORTING
          open_delivery      = lwa_final-olikw
          open_invoice       = lwa_final-ofakw
          open_order         = lwa_final-oeikw.

*&-- Calculating Credit Exposure & Credit limit used
*&--This code has been kept as in FD32
      TRY.
          lwa_final-oblig = lwa_final-skfor + lwa_final-olikw + lwa_final-ofakw + lwa_final-oeikw.
        CATCH cx_sy_arithmetic_overflow. ##no_handler
      ENDTRY.
      CLEAR lv_refe1.
      IF lwa_final-klimk  = 0
       OR lwa_final-oblig < 0.
        CLEAR lwa_final-klprz.
      ELSE. " ELSE -> IF lwa_final-klimk = 0

        TRY.
            lv_refe1 = ( lwa_final-oblig * 10000 ) / lwa_final-klimk.
          CATCH cx_sy_arithmetic_overflow. ##no_handler
        ENDTRY.
      ENDIF. " IF lwa_final-klimk = 0
      IF  lwa_final-klimk = 0
      AND lwa_final-oblig > 0.
*&-- To restrict the conversion to 3dig ans 2dec places
*&-- after division by 100
        lv_refe1 = 99999.
      ENDIF. " IF lwa_final-klimk = 0

*&-- Pass the value to work area
      IF lv_refe1 > 99999.
        lwa_final-klprz = 99999 / 100.
      ELSE. " ELSE -> IF lv_refe1 > 99999
        lwa_final-klprz = lv_refe1 / 100.
      ENDIF. " IF lv_refe1 > 99999
    ENDIF. " IF lv_sptag IS NOT INITIAL

    APPEND lwa_final TO fp_i_final_det.

    CLEAR: lwa_final.
  ENDLOOP. " LOOP AT fp_i_knkk ASSIGNING <lfs_knkk>

ENDFORM. " F_POPULATE_FINAL_TABLE_CR
*&---------------------------------------------------------------------*
*&      Form  F_APPL_SERVER_UPLOAD
*&---------------------------------------------------------------------*
*       Transporting file to AL11
*----------------------------------------------------------------------*
*      -->P_I_FINAL_DET  text
*----------------------------------------------------------------------*
FORM f_appl_server_upload  USING fp_i_final_det TYPE ty_t_final_det.

**//Local Data Declaration
  DATA:lv_filename  TYPE localfile, " Local file for upload/download
       lv_flag      TYPE flag,      " General Flag
       lwa_final    TYPE ty_final_det,
       lv_string    TYPE char1792,  " String of type CHAR1792
       lv_dmbtr     TYPE char16,    " Dmbtr of type CHAR16
       lv_balance   TYPE char16,    " Balance of type CHAR16
       lv_not_due   TYPE char16,    " Not_due of type CHAR16
       lv_calc1     TYPE char16,    " Calc1 of type CHAR16
       lv_calc2     TYPE char16,    " Calc2 of type CHAR16
       lv_calc3     TYPE char16,    " Calc3 of type CHAR16
       lv_calc4     TYPE char16,    " Calc4 of type CHAR16
       lv_calc5     TYPE char16,    " Calc5 of type CHAR16
       lv_calc6     TYPE char16,    " Calc6 of type CHAR16
       lv_wrbtr     TYPE char16,    " Wrbtr of type CHAR16
       lv_klimk     TYPE char20,    " Klimk of type CHAR20
       lv_oblig     TYPE char20,    " Oblig of type CHAR20
       lv_klprz     TYPE char5,     " Klprz of type CHAR20
       lv_skfor     TYPE char20,    " Skfor of type CHAR20
       lv_oeikw     TYPE char26,    " Oeikw of type CHAR26
       lv_olikw     TYPE char26,    " Olikw of type CHAR26
       lv_budat     TYPE char10,    " Date of Char10
       lv_bldat     TYPE char10,    " Date of Char10
       lv_cpudt     TYPE char10,    " Date of Char10
       lv_augdt     TYPE char10,    " Date of Char10
       lv_zfbdt     TYPE char10,    " Date of Char10
       lv_ofakw     TYPE char26.    " Ofakw of type CHAR26

  CONSTANTS:
* ---> Begin of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
*             lc_comma  TYPE c      VALUE ',', " Comma of type Character
* <--- End of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* ---> Begin of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
             lc_tab   TYPE char1  VALUE cl_abap_char_utilities=>horizontal_tab, " Tab
             lc_negative TYPE char1 VALUE '-',                                  " Negative sign
* <--- End of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
             lc_format TYPE string VALUE '.csv',
             lc_name   TYPE string VALUE 'AR_AGING_REPORT_'.

*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
  CONSTANTS lc_score TYPE c      VALUE '_'. " Score of type Character

* The User Name will be concatenated along with the File Name.
*  CONCATENATE p_path lc_name sy-datum sy-uzeit lc_format INTO lv_filename.
  CONCATENATE p_path lc_name sy-datum sy-uzeit lc_score sy-uname lc_format INTO lv_filename.
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016


  IF NOT lv_filename IS INITIAL.
**//Check file for authorization
    PERFORM f_check_file USING lv_filename
                      CHANGING lv_flag.
    IF lv_flag IS INITIAL.
**//Transferring the Final table to Application Server.
      OPEN DATASET lv_filename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " Output type
      IF sy-subrc = 0.

**//Concatenating For Header in Application Server
*&-- Populating header based on Radio-buttons
        IF NOT rb_detdc IS INITIAL.
          CONCATENATE 'Co Code'(001) 'Customer Number'(002) 'Customer Name'(003) 'Reccon Acc'(004) 'Posting Key'(005)
                      'Document Type'(006) 'Document Number'(007) 'Reference'(008) 'Amt Local Currency'(009) 'Local Currency'(010)
                      '0-30Days'(012) '31-60Days'(014) '61-90Days'(015) '91-120Days'(016) '121-150Days'(017) '>150Days'(018)
                      'Amt Doc Currency'(019) 'Doc Currency'(063) 'Document Date'(020) 'Posting Date'(021) 'Entry Date'(022)
                      'Clearing Date'(023) 'Clearing Doc'(024) 'Base Line Date'(025) 'Payment Terms'(026) 'Tax Code'(027)
*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
                      'Profit Center'(028)
 "'Profile Center'(028)
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016

                      'Invoice Reference'(029) 'Billing Doc'(030) 'Sale Order'(031) 'PO Number'(032) 'PO Type'(033)
                      'Spl GL Indicator'(034) 'Reference Key 1'(035) 'Reference Key 2'(036)
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                       'Assignment Number'(070)
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                      'Header TXT'(037)
                      'Credit Control Area'(038) 'Credit Account'(039) 'Credit Limit'(040) 'Risk Catagory'(041)
                      'Last Int Review'(057) 'Next Int Review'(058) 'Credit Rep Grp'(042) 'Credit Rep Grp Name'(043)
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                      'Customer Grp Name'(069)
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
**-->Begin of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                      'Case ID'(071)
**-->End of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                      INTO lv_string SEPARATED BY
* ---> Begin of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* We will now use tab as separator since a few Customer Names have comma in them and this
* was leading to a wrong output when the background report was downloaded to an excel .
                      lc_tab.
* <--- End of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* ---> Begin of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
*                      lc_comma.
* <--- End of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016

        ELSEIF NOT rb_detnt IS INITIAL.
          CONCATENATE 'Co Code'(001) 'Customer Number'(002) 'Customer Name'(003) 'Reccon Acc'(004) 'Posting Key'(005)
                    'Document Type'(006) 'Document Number'(007) 'Reference'(008) 'Amt Local Currency'(009) 'Local Currency'(010)
                    'Not Due'(011) '1-30Days'(013) '31-60Days'(014) '61-90Days'(015) '91-120Days'(016) '121-150Days'(017)
                    '>150Days'(018) 'Amt Doc Currency'(019) 'Doc Currency'(063) 'Document Date'(020) 'Posting Date'(021)
                    'Entry Date'(022) 'Clearing Date'(023) 'Clearing Doc'(024) 'Base Line Date'(025) 'Payment Terms'(026) 'Tax Code'(027)
*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
*                     'Profile Center'(028)
                      'Profit Center'(028)
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
                     'Invoice Reference'(029) 'Billing Doc'(030) 'Sale Order'(031)


                    'PO Number'(032) 'PO Type'(033) 'Spl GL Indicator'(034) 'Reference Key 1'(035) 'Reference Key 2'(036)
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                    'Assignment Number'(070)
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                    'Header TXT'(037) 'Credit Control Area'(038) 'Credit Account'(039) 'Credit Limit'(040) 'Risk Catagory'(041)
                    'Last Int Review'(057) 'Next Int Review'(058) 'Credit Rep Grp'(042) 'Credit Rep Grp Name'(043)
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                      'Customer Grp Name'(069)
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
**-->Begin of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                      'Case ID'(071)
**-->End of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                    INTO lv_string SEPARATED BY
* ---> Begin of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* We will now use tab as separator since a few Customer Names have comma in them and this
* was leading to a wrong output when the background report was downloaded to an excel .
                      lc_tab.
* <--- End of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* ---> Begin of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
*                      lc_comma.
* <--- End of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016

        ELSEIF NOT rb_sumdc IS INITIAL.
          CONCATENATE 'Co Code'(001) 'Customer Number'(002) 'Country'(050) 'Customer Name'(003) 'Balance'(049)
                    'Local Currency'(010) '0-30Days'(012) '31-60Days'(014) '61-90Days'(015) '91-120Days'(016)
                    '121-150Days'(017) '>150Days'(018) 'Credit Control Area'(038) 'Credit Account'(039) 'Credit Limit'(040)
                    'Risk Catagory'(041) 'Last Int Review'(057) 'Next Int Review'(058) 'Credit Rep Grp'(042) 'Credit Rep Grp Name'(043)
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                      'Customer Grp Name'(069)
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
**-->Begin of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                      'Case ID'(071)
**-->End of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                    INTO lv_string SEPARATED BY
* ---> Begin of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* We will now use tab as separator since a few Customer Names have comma in them and this
* was leading to a wrong output when the background report was downloaded to an excel .
                      lc_tab.
* <--- End of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* ---> Begin of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
*                      lc_comma.
* <--- End of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016

        ELSEIF NOT rb_sumnt IS INITIAL.
          CONCATENATE 'Co Code'(001) 'Customer Number'(002) 'Country'(050) 'Customer Name'(003) 'Balance'(049)
                    'Local Currency'(010) 'Not Due'(011) '1-30Days'(013) '31-60Days'(014) '61-90Days'(015)
                    '91-120Days'(016) '121-150Days'(017) '>150Days'(018) 'Credit Control Area'(038) 'Credit Account'(039)
                    'Credit Limit'(040) 'Risk Catagory'(041) 'Last Int Review'(057)
                    'Next Int Review'(058) 'Credit Rep Grp'(042) 'Credit Rep Grp Name'(043)
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                      'Customer Grp Name'(069)
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
**-->Begin of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                      'Case ID'(071)
**-->End of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                    INTO lv_string SEPARATED BY
* ---> Begin of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* We will now use tab as separator since a few Customer Names have comma in them and this
* was leading to a wrong output when the background report was downloaded to an excel .
                      lc_tab.
* <--- End of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* ---> Begin of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
*                      lc_comma.
* <--- End of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
        ELSE. " ELSE -> IF NOT rb_detdc IS INITIAL
          CONCATENATE 'Customer Number'(002) 'Credit Control Area'(038) 'Credit Account'(039) 'Credit Limit'(040)
                    'Credit Exposure'(064) 'Credit limit Used %'(068) 'Risk Catagory'(041) 'Credit Horizon Date'(065)
                    'Total Receivables'(059) 'Open Sales'(060) 'Open Delivery'(061) 'Open VFX3'(062) 'Last Int Review'(057)
                    'Next Int Review'(058) 'Credit Rep Grp'(042) 'Credit Rep Grp Name'(043)
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                      'Customer Grp Name'(069)
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                    INTO lv_string SEPARATED BY
* ---> Begin of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* We will now use tab as separator since a few Customer Names have comma in them and this
* was leading to a wrong output when the background report was downloaded to an excel .
                      lc_tab.
* <--- End of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* ---> Begin of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
*                      lc_comma.
* <--- End of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016

        ENDIF. " IF NOT rb_detdc IS INITIAL
        TRANSFER lv_string TO lv_filename.
        CLEAR lv_string.

        LOOP AT fp_i_final_det INTO lwa_final.

          lv_dmbtr   = lwa_final-dmbtr.
          lv_balance = lwa_final-balance.
          lv_not_due = lwa_final-not_due.
          lv_calc1   = lwa_final-calc1.
          lv_calc2   = lwa_final-calc2.
          lv_calc3   = lwa_final-calc3.
          lv_calc4   = lwa_final-calc4.
          lv_calc5   = lwa_final-calc5.
          lv_calc6   = lwa_final-calc6.
          lv_wrbtr   = lwa_final-wrbtr.
          lv_klimk   = lwa_final-klimk.
          lv_oblig   = lwa_final-oblig.
          lv_klprz   = lwa_final-klprz.
          lv_skfor   = lwa_final-skfor.
          lv_oeikw   = lwa_final-oeikw.
          lv_olikw   = lwa_final-olikw.
          lv_ofakw   = lwa_final-ofakw.

          lv_bldat = lwa_final-bldat.
          lv_budat = lwa_final-budat.
          lv_cpudt = lwa_final-cpudt.
          lv_augdt = lwa_final-augdt.
          lv_zfbdt = lwa_final-zfbdt.

          PERFORM f_convert_date CHANGING lv_bldat.
          PERFORM f_convert_date CHANGING lv_budat.
          PERFORM f_convert_date CHANGING lv_cpudt.
          PERFORM f_convert_date CHANGING lv_augdt.
          PERFORM f_convert_date CHANGING lv_zfbdt.

          IF lv_dmbtr CA lc_negative.
            PERFORM f_convert_amount CHANGING lv_dmbtr.
          ENDIF. " IF lv_dmbtr CA lc_negative
          IF lv_balance CA lc_negative.
            PERFORM f_convert_amount CHANGING lv_balance.
          ENDIF. " IF lv_balance CA lc_negative
          IF lv_not_due CA lc_negative.
            PERFORM f_convert_amount CHANGING lv_not_due.
          ENDIF. " IF lv_not_due CA lc_negative
          IF lv_calc1 CA lc_negative.
            PERFORM f_convert_amount CHANGING lv_calc1.
          ENDIF. " IF lv_calc1 CA lc_negative
          IF lv_calc2 CA lc_negative.
            PERFORM f_convert_amount CHANGING lv_calc2.
          ENDIF. " IF lv_calc2 CA lc_negative
          IF lv_calc3 CA lc_negative.
            PERFORM f_convert_amount CHANGING lv_calc3.
          ENDIF. " IF lv_calc3 CA lc_negative
          IF lv_calc4 CA lc_negative.
            PERFORM f_convert_amount CHANGING lv_calc4.
          ENDIF. " IF lv_calc4 CA lc_negative
          IF lv_calc5 CA lc_negative.
            PERFORM f_convert_amount CHANGING lv_calc5.
          ENDIF. " IF lv_calc5 CA lc_negative
          IF lv_calc6 CA lc_negative.
            PERFORM f_convert_amount CHANGING lv_calc6.
          ENDIF. " IF lv_calc6 CA lc_negative
          IF lv_wrbtr CA lc_negative.
            PERFORM f_convert_amount CHANGING lv_wrbtr.
          ENDIF. " IF lv_wrbtr CA lc_negative

*-->Begin of change for D2_OTC_RDD_0092 Def#2901 by ASK
          REPLACE ALL OCCURRENCES OF lc_tab IN lwa_final-xblnr WITH ' '.
          REPLACE ALL OCCURRENCES OF lc_tab IN lwa_final-bstnk WITH ' '.
          REPLACE ALL OCCURRENCES OF lc_tab IN lwa_final-sgtxt WITH ' '.
*<-- End of change for D2_OTC_RDD_0092 Def#2901 by ASK

          IF NOT rb_detdc IS INITIAL.
            CONCATENATE lwa_final-bukrs lwa_final-kunnr lwa_final-name1  lwa_final-hkont lwa_final-bschl
                        lwa_final-blart lwa_final-belnr lwa_final-xblnr  lv_dmbtr        lwa_final-waers
                        lv_calc1        lv_calc2        lv_calc3         lv_calc4        lv_calc5
                        lv_calc6        lv_wrbtr        lwa_final-waers1 lv_bldat
                        lv_budat lv_cpudt lv_augdt  lwa_final-augbl lv_zfbdt
                        lwa_final-zterm lwa_final-mwskz lwa_final-prctr  lwa_final-rebzg lwa_final-vbeln
                        lwa_final-aubel lwa_final-bstnk lwa_final-bsark  lwa_final-umskz lwa_final-xref1
                        lwa_final-xref2
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                        lwa_final-zuonr
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                        lwa_final-sgtxt lwa_final-kkber  lwa_final-knkli lv_klimk
                        lwa_final-ctlpc lwa_final-dtrev lwa_final-nxtrv  lwa_final-sbgrp lwa_final-stext
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                        lwa_final-kdgrp
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
**-->Begin of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                        lwa_final-case_id
**-->End of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                        INTO lv_string
                        SEPARATED BY
* ---> Begin of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* We will now use tab as separator since a few Customer Names have comma in them and this
* was leading to a wrong output when the background report was downloaded to an excel .
                      lc_tab.
* <--- End of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* ---> Begin of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
*                      lc_comma.
* <--- End of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016

          ELSEIF NOT rb_detnt IS INITIAL.
            CONCATENATE lwa_final-bukrs lwa_final-kunnr lwa_final-name1  lwa_final-hkont lwa_final-bschl
                        lwa_final-blart lwa_final-belnr lwa_final-xblnr  lv_dmbtr        lwa_final-waers
                        lv_not_due      lv_calc1        lv_calc2         lv_calc3        lv_calc4 lv_calc5
                        lv_calc6        lv_wrbtr        lwa_final-waers1 lv_bldat
                        lv_budat lv_cpudt lv_augdt  lwa_final-augbl lv_zfbdt
                        lwa_final-zterm lwa_final-mwskz lwa_final-prctr  lwa_final-rebzg lwa_final-vbeln
                        lwa_final-aubel lwa_final-bstnk lwa_final-bsark  lwa_final-umskz lwa_final-xref1
                        lwa_final-xref2
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                        lwa_final-zuonr " Cusotmer Grp , Assignment number
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                        lwa_final-sgtxt lwa_final-kkber  lwa_final-knkli lv_klimk
                        lwa_final-ctlpc lwa_final-dtrev lwa_final-nxtrv  lwa_final-sbgrp lwa_final-stext
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                        lwa_final-kdgrp " Cusotmer Grp , Assignment number
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
**-->Begin of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                        lwa_final-case_id
**-->End of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                        INTO lv_string
                        SEPARATED BY
* ---> Begin of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* We will now use tab as separator since a few Customer Names have comma in them and this
* was leading to a wrong output when the background report was downloaded to an excel .
                      lc_tab.
* <--- End of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* ---> Begin of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
*                      lc_comma.
* <--- End of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016

          ELSEIF NOT rb_sumdc IS INITIAL.
            CONCATENATE lwa_final-bukrs lwa_final-kunnr lwa_final-land1 lwa_final-name1 lv_balance
                        lwa_final-waers lv_calc1        lv_calc2        lv_calc3        lv_calc4
                        lv_calc5        lv_calc6        lwa_final-kkber lwa_final-knkli lv_klimk
                        lwa_final-ctlpc lwa_final-dtrev lwa_final-nxtrv lwa_final-sbgrp lwa_final-stext
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                        lwa_final-kdgrp " Cusotmer Grp
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
**-->Begin of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                        lwa_final-case_id
**-->End of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                        INTO lv_string
                        SEPARATED BY
* ---> Begin of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* We will now use tab as separator since a few Customer Names have comma in them and this
* was leading to a wrong output when the background report was downloaded to an excel .
                      lc_tab.
* <--- End of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* ---> Begin of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
*                      lc_comma.
* <--- End of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016

          ELSEIF NOT rb_sumnt IS INITIAL.
            CONCATENATE lwa_final-bukrs lwa_final-kunnr lwa_final-land1 lwa_final-name1 lv_balance
                        lwa_final-waers lv_not_due      lv_calc1        lv_calc2        lv_calc3  lv_calc4
                        lv_calc5        lv_calc6        lwa_final-kkber lwa_final-knkli lv_klimk
                        lwa_final-ctlpc lwa_final-dtrev lwa_final-nxtrv lwa_final-sbgrp lwa_final-stext
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                        lwa_final-kdgrp " Cusotmer Grp
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
**-->Begin of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                        lwa_final-case_id
**-->End of Change for Defect#2646:D3_OTC_RDD_0092 by SGHOSH.
                        INTO lv_string
                        SEPARATED BY
* ---> Begin of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* We will now use tab as separator since a few Customer Names have comma in them and this
* was leading to a wrong output when the background report was downloaded to an excel .
                      lc_tab.
* <--- End of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* ---> Begin of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
*                      lc_comma.
* <--- End of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016

          ELSE. " ELSE -> IF NOT rb_detdc IS INITIAL
            CONCATENATE lwa_final-kunnr  lwa_final-kkber lwa_final-knkli lv_klimk lv_oblig lv_klprz
                        lwa_final-ctlpc  lwa_final-horda lv_skfor        lv_oeikw lv_olikw lv_ofakw
                        lwa_final-dtrev  lwa_final-nxtrv lwa_final-sbgrp lwa_final-stext
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                        lwa_final-kdgrp " Cusotmer Grp
*<-- End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
                        INTO lv_string
                        SEPARATED BY
* ---> Begin of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* We will now use tab as separator since a few Customer Names have comma in them and this
* was leading to a wrong output when the background report was downloaded to an excel .
                      lc_tab.
* <--- End of Insert for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
* ---> Begin of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016
*                      lc_comma.
* <--- End of Delete for D2_OTC_RDD_0092_Defect# 2091 by LMAHEND on 13-Oct-2016

          ENDIF. " IF NOT rb_detdc IS INITIAL
          TRANSFER lv_string TO lv_filename.
          CLEAR:lv_string,
                lv_dmbtr,
                lv_balance,
                lv_not_due,
                lv_calc1,
                lv_calc2,
                lv_calc3,
                lv_calc4,
                lv_calc5,
                lv_calc6,
                lv_wrbtr,
                lv_klimk,
                lv_oblig,
                lv_klprz,
                lv_skfor,
                lv_oeikw,
                lv_olikw,
                lv_ofakw.
        ENDLOOP. " LOOP AT fp_i_final_det INTO lwa_final
      ENDIF. " IF sy-subrc = 0

      CLOSE DATASET lv_filename.
*&-- File uploaded
      IF sy-subrc = 0.
        MESSAGE s910 WITH p_path. " File uploaded to &
      ENDIF. " IF sy-subrc = 0
    ELSE. " ELSE -> IF lv_flag IS INITIAL
*&-- File not uploaded
      MESSAGE e918 WITH p_path. " No authorization to write file &
    ENDIF. " IF lv_flag IS INITIAL
  ENDIF. " IF NOT lv_filename IS INITIAL

ENDFORM. " F_APPL_SERVER_UPLOAD
*&---------------------------------------------------------------------*
*&      Form  F_AUTHORIZATION_CHECK
*&---------------------------------------------------------------------*
*       Authorization check for company codes
*----------------------------------------------------------------------*
FORM f_authorization_check .
  DATA: lv_lines     TYPE i, " Lines of type Integers
        lv_lines_new TYPE i. " Lines_new of type Integers

  FIELD-SYMBOLS :  <lfs_comp>  TYPE ty_comp.
  DESCRIBE TABLE i_comp LINES lv_lines.

  LOOP AT i_comp ASSIGNING <lfs_comp>.
*-->Begin of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
*    AUTHORITY-CHECK OBJECT 'F_KNA1_BUK'
    AUTHORITY-CHECK OBJECT 'ZOTC_AGING'
*-->End of change for D2_OTC_RDD_0092 Def#1804 by u034192 on 18-Jul-2016
     ID 'BUKRS' FIELD <lfs_comp>-bukrs " Company Code
     ID 'ACTVT' FIELD '03'.            " Activity- Display
    IF sy-subrc <> 0.
      CLEAR <lfs_comp>-bukrs.
    ENDIF. " IF sy-subrc <> 0
  ENDLOOP. " LOOP AT i_comp ASSIGNING <lfs_comp>

  DELETE i_comp WHERE bukrs IS INITIAL.
  DESCRIBE TABLE i_comp LINES lv_lines_new.

  IF i_comp IS INITIAL.
    MESSAGE e916(zotc_msg). " User is not authorized for the given company code(s)
  ELSE. " ELSE -> IF i_comp IS INITIAL
    IF lv_lines_new LT lv_lines.
      MESSAGE i917(zotc_msg). " User is not authorized for some company code(s)
    ENDIF. " IF lv_lines_new LT lv_lines
  ENDIF. " IF i_comp IS INITIAL

ENDFORM. " F_AUTHORIZATION_CHECK
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_FILE
*&---------------------------------------------------------------------*
*       Authorization check based on filename for AL11 action
*----------------------------------------------------------------------*
FORM f_check_file  USING    fp_filename TYPE localfile " Local file for upload/download
                CHANGING    fp_flag     TYPE flag.     " General Flag

  CONSTANTS: lc_act  TYPE char5 VALUE 'WRITE'. " Act of type Character
  DATA:      lv_file TYPE fileextern. " Physical file name

  lv_file = fp_filename.
*  Authorization for writing to dataset
  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
    EXPORTING
      activity         = lc_act
      filename         = lv_file
    EXCEPTIONS
      no_authority     = 1
      activity_unknown = 2
      OTHERS           = 3.

  IF sy-subrc <> 0.
    fp_flag = abap_true.
  ELSE. " ELSE -> IF sy-subrc <> 0
    fp_flag = abap_false.
  ENDIF. " IF sy-subrc <> 0
ENDFORM. " F_CHECK_FILE
*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_DATE
*&---------------------------------------------------------------------*
*       Convert Date
*----------------------------------------------------------------------*
*      <--P_LWA_FINAL_BLDAT  text
*      <--P_LWA_FINAL_BUDAT  text
*      <--P_LWA_FINAL_CPUDT  text
*      <--P_LWA_FINAL_AUGDT  text
*      <--P_LWA_FINAL_ZFBDT  text
*----------------------------------------------------------------------*
FORM f_convert_date  CHANGING fp_date TYPE char10. " Date

  CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
    EXPORTING
      input  = fp_date
    IMPORTING
      output = fp_date.


ENDFORM. " F_CONVERT_DATE
*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_AMOUNT
*&---------------------------------------------------------------------*
*      Convert amount field
*----------------------------------------------------------------------*
*      <--FP_LV_DMBTR  text
*----------------------------------------------------------------------*
FORM f_convert_amount  CHANGING lv_amount TYPE char16. " Convert_amount changing of type CHAR16

  CONSTANTS: lc_negative TYPE char1 VALUE '-'. " Negative

  lv_amount = lv_amount * -1.
  CONDENSE lv_amount.
  CONCATENATE lc_negative lv_amount INTO lv_amount.


ENDFORM. " F_CONVERT_AMOUNT
