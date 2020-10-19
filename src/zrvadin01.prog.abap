*&---------------------------------------------------------------------*
*& Report  ZRVADIN01
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
***********************************************************************
*Program    : ZRVADIN01                                               *
*Title      : Customer Downpayment Form                               *
*Developer  : Dhananjoy Moirangthem                                   *
*Object type: Forms                                                   *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_FDD_0067                                           *
*---------------------------------------------------------------------*
*Description: Customer Downpayment Form                               *
*This report has been copied from Cressier system. No change has been *
* done. Only code has been commented out for custom table and FM which*
* is not there in D3 and not needed.                                  *
*This report calls SAP Script ZSDESRINVOI01.                          *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*13-OCT-2014  DMOIRAN       E1DK921459     Initial Development
*---------------------------------------------------------------------*

REPORT ZRVADIN01 LINE-COUNT 100 MESSAGE-ID vn .



***********************************************************************
* Definition of tables                                                *
***********************************************************************
*
* cjo Arbeitsbereiche
*
DATA   h_sernr LIKE equi-sernr.
DATA: wa_marc LIKE marc.
DATA: wa_mara LIKE mara.
DATA: wa_vbrp LIKE vbrp.
* HFR20090317: Bei Yen keine Nachkommastellen
DATA: wa_kzwi2_jpy(11) TYPE p.
DATA: wa_komvd LIKE komvd.
DATA: zmerk(1) TYPE c.
DATA: h_service(20) TYPE c.
*DATA: wa_zmhdat LIKE zmhdat.           "D3_OTC_FDD_0067 by DMOIRAN
DATA: h_mhdat(10)  TYPE c VALUE 0.                          "SAP4u OPJ
DATA: ch_charg(19) TYPE c VALUE 0,
      ch_charg_lif(19) TYPE c VALUE 0.
DATA: fl_sernr,
      ch_sernr(50).
DATA: wa_head TYPE thead.
DATA: wa_spras TYPE langu.
*INS rte0002
DATA: flg_china(1),
      ser_china(23) TYPE c.
*INS rte0002
TABLES: komk    ,
        komp    ,
        equi    ,
        viqmel  ,
        caufv   ,
        makt    ,
        eipo    ,
        vbrp    ,
        knvv    ,
        lips    ,
        komvd   ,
        mch1    ,
        afih    ,
        kna1    ,
        vbfa    ,
        vbco3   ,
        vbdkr   ,
        vbdpr   ,
        marc    ,
        vbdre   ,
        vbak    ,
        conf_out,
        sadr    ,
        tvko    ,
*        zmch    ,             "D3_OTC_FDD_0067 by DMOIRAN
        adrs    ,
        t005    ,
        t001    ,
        t001g   ,
        t052u,         "neue Zahlungskonditionen
        tvcint  ,
        konh    ,
        tlic    ,
        fpltvb  ,
*INS rte0001
*        zsd_knmt,  "D3_OTC_FDD_0067 by DMOIRAN
*INS rte0001
*INS rte0002
        stxh,
        adr2.
*INS rte0002

* HFR20090813: Chargenmenge mit ausgeben
DATA: wa_char_menge(20) TYPE c.
DATA: wa_char_menge_zw TYPE char20.

DATA: wa_char_lifnr TYPE vbeln.
DATA: wa_char_lifpo TYPE posnr.
***********************************************************************
* Additional definitions of tables for general issues                 *
***********************************************************************
***********************************************************************
* Additional definitions of tables for general issues                 *
***********************************************************************
* Data for printout Slovakia
TABLES: vbrk, bkpf, bset, teurb.

* Data for printout discount information
TABLES: vbdprl, vtopis.


INCLUDE rvadtabl.

***********************************************************************
* Definition of internal tables                                       *
***********************************************************************

DATA: BEGIN OF tvbdpr OCCURS 100.      "Internal table for items
        INCLUDE STRUCTURE vbdpr.
DATA: END OF tvbdpr.

DATA: BEGIN OF tkomv OCCURS 50.
        INCLUDE STRUCTURE komv.
DATA: END OF tkomv.

DATA: BEGIN OF tkomvd OCCURS 50.
        INCLUDE STRUCTURE komvd.
DATA: END OF tkomvd.

DATA: BEGIN OF tkomser_print OCCURS 5.
        INCLUDE STRUCTURE komser.
DATA: END   OF tkomser_print.
DATA: BEGIN OF *tkomvd OCCURS 50.
        INCLUDE STRUCTURE komvd.
DATA: END OF *tkomvd.

DATA: BEGIN OF hkomv OCCURS 50.
        INCLUDE STRUCTURE komv.
DATA: END OF hkomv.

DATA: BEGIN OF hkomvd OCCURS 50.
        INCLUDE STRUCTURE komvd.
DATA: END OF hkomvd.

DATA: BEGIN OF tkomcon OCCURS 50.
        INCLUDE STRUCTURE conf_out.
DATA: END   OF tkomcon.

DATA: h_vbeln-vauf LIKE vbdpr-vbeln_vauf.
DATA: BEGIN OF tkomser OCCURS 5.
        INCLUDE STRUCTURE riserls.
DATA: END   OF tkomser.

***********************************************************************
* Definition of internal variables                                    *
***********************************************************************

DATA: retcode   LIKE sy-subrc.         "Returncode
DATA: repeat(1) TYPE c.
DATA: xscreen(1) TYPE c.               "Output on printer or screen
DATA: xvbeln LIKE vbrk-vbeln.
DATA: xposnr LIKE vbrl-posnr.
DATA: pr_kappl(01)   TYPE c VALUE 'V'. "Application for pricing
DATA: print_mwskz.                     "Mehrwertsteuer-Kz drucken
DATA: ccname(30) TYPE c.               "Card Type

***********************************************************************
* Definition of variables for calling customer subroutines dynamically*
***********************************************************************

DATA : header_userexit       LIKE tnapr-ronam,
       item_userexit         LIKE tnapr-ronam,
       header_print_userexit LIKE tnapr-ronam,
       item_print_userexit   LIKE tnapr-ronam,
       get_data_userexit     LIKE tnapr-ronam.
* HFR20090317: New-Page bei Deutschen Faktruren und WE-Wechsel
DATA: wa_new_we(01) TYPE c.
DATA: wa_new_del(01) TYPE c.
DATA: wa_adrnr TYPE adrnr.
DATA: wa_kunwe   TYPE kunwe.
DATA: wa_kunwe_p TYPE kunwe.
DATA: wa_vbeln_vl TYPE vbeln.
DATA: wa_perfk TYPE knvv-perfk.
DATA: wa_kzwi2_tot TYPE vbrp-kzwi2.
DATA: wa_tot_we(01) TYPE c.
DATA: wa_tr(01) TYPE c.
***********************************************************************
* Specific data of ENTRY_CH
***********************************************************************

DATA print_local_curr_ch.
DATA: komvdk_ch LIKE komvd OCCURS 10 WITH HEADER LINE.
DATA: komvdp_ch LIKE komvd OCCURS 10 WITH HEADER LINE.

*   mbi0001------------------------------------------------------------
DATA : wa_adresse_sel  TYPE addr1_sel,
       wl_sadr         TYPE sadr,
       wl_likp         TYPE likp.
*   mbi0001------------------------------------------------------------
* mbi0004-------------------------------------------------------------
DATA wa_kbetr_ser TYPE kbetr.
* mbi0004-------------------------------------------------------------
* mbi0005-------------------------------------------------------------
DATA : wa_round_netwr LIKE vbap-netwr.
* mbi0005-------------------------------------------------------------
* hfr20090527: Zusatzdef. Fakturaplan
DATA: wa_auart TYPE auart.
DATA: z_von(02) TYPE p.
DATA: z_tot(02) TYPE p.
TYPES: BEGIN OF ty_fplnr,
            fplnr TYPE fplnr,
            fpltr TYPE fpltr,
            fproz TYPE fproz,
            fakwr TYPE fakwr,
            waers TYPE waers,
            fkdat TYPE fkdat,
            zterm TYPE fplt-zterm,
         END OF ty_fplnr.
DATA: it_fplnr TYPE TABLE OF ty_fplnr.
DATA: wa_fplnr TYPE ty_fplnr.
DATA: wa_fplnr_aktuel TYPE ty_fplnr.
DATA: z_fplnr(05) TYPE p.
DATA: wa_zterm_fpl(35) TYPE c.
* hfr20090527: Zusatzdef. Fakturaplan

* country specific entry routines
INCLUDE idbillprint.

* data for access to central address maintenance
INCLUDE sdzavdat.

*mbi0008---------------------------------------------------------------
DATA: w_logo(1) TYPE c VALUE ' ',
*mbi0008---------------------------------------------------------------
*mbi0011---------------------------------------------------------------
      wl_tiban      TYPE tiban,
      wa_iban_bc(5) TYPE c,
*mbi0011---------------------------------------------------------------
*mbi0013---------------------------------------------------------
      wa_mail_list TYPE so_obj_des,
      wa_name      TYPE so_adrnam,
      wa_tel_nr    LIKE adr2-tel_number.
*mbi0013---------------------------------------------------------



***********************************************************************
*                                                                     *
* Standard Routine ENTRY                                              *
*                                                                     *
***********************************************************************

FORM entry USING return_code us_screen.

  CLEAR retcode.
  xscreen = us_screen.

* mbi0008---------------------------------------------------------------
  IF nast-tdarmod = '3'.
*   Print without Logo
    w_logo = ' '.
    nast-tdarmod = '1'.
    PERFORM processing USING us_screen.

*   Archive with Logo
    w_logo = 'X'.
    nast-tdarmod = '2'.
    PERFORM processing USING us_screen.

  ELSE.
    PERFORM processing USING us_screen.
  ENDIF.
* mbi0008---------------------------------------------------------------

  CASE retcode.
    WHEN 0.
      return_code = 0.
    WHEN 3.
      return_code = 3.
    WHEN OTHERS.
      return_code = 1.
  ENDCASE.

ENDFORM.                    "ENTRY

***********************************************************************
*                                                                     *
* Standard Routine ENTRY_PROFORMA                                     *
*                                                                     *
***********************************************************************

FORM entry_proforma USING return_code us_screen.

  CLEAR return_code.

ENDFORM.                    "ENTRY_PROFORMA

***********************************************************************
*                                                                     *
* Standard Routine ENTRY_ESR                                          *
*                                                                     *
***********************************************************************

FORM entry_esr USING return_code us_screen.

  CLEAR retcode.
  xscreen = us_screen.

* mbi0008---------------------------------------------------------------
  IF nast-tdarmod = '3'.
*   Print without Logo
    w_logo = ' '.
    nast-tdarmod = '1'.
    PERFORM processing_esr USING us_screen.

*   Archive with Logo
    w_logo = 'X'.
    nast-tdarmod = '2'.
    PERFORM processing_esr USING us_screen.

  ELSE.
    PERFORM processing_esr USING us_screen.
  ENDIF.
* mbi0008---------------------------------------------------------------

  CASE retcode.
    WHEN 0.
      return_code = 0.
    WHEN 3.
      return_code = 3.
    WHEN OTHERS.
      return_code = 1.
  ENDCASE.

ENDFORM.                    "ENTRY_ESR

***********************************************************************
*                                                                     *
* Standard Routine ENTRY_ITALY                                        *
*                                                                     *
***********************************************************************

FORM entry_italy USING return_code us_screen.

  CLEAR retcode.
  xscreen = us_screen.

* mbi0008---------------------------------------------------------------
  IF nast-tdarmod = '3'.
*   Print without Logo
    w_logo = ' '.
    nast-tdarmod = '1'.
    PERFORM processing_italy USING us_screen.

*   Archive with Logo
    w_logo = 'X'.
    nast-tdarmod = '2'.
    PERFORM processing_italy USING us_screen.

  ELSE.
    PERFORM processing_italy USING us_screen.
  ENDIF.
* mbi0008---------------------------------------------------------------

  CASE retcode.
    WHEN 0.
      return_code = 0.
    WHEN 3.
      return_code = 3.
    WHEN OTHERS.
      return_code = 1.
  ENDCASE.

ENDFORM.                    "ENTRY_ITALY

***********************************************************************
*                                                                     *
* Standard Routine ENTRY_CH                                           *
*                                                                     *
***********************************************************************

FORM entry_ch USING return_code us_screen.
  CLEAR retcode.
  xscreen = us_screen.
  header_userexit = 'HEADER_CH'.
  item_userexit = 'ITEM_CH'.
  header_print_userexit = 'HEADER_PRINT_CH'.
  item_print_userexit = 'ITEM_PRINT_CH'.


* mbi0008---------------------------------------------------------------
  IF nast-tdarmod = '3'.
*   Print without Logo
    w_logo = ' '.
    nast-tdarmod = '1'.
    PERFORM processing USING us_screen.

*   Archive with Logo
    w_logo = 'X'.
    nast-tdarmod = '2'.
    PERFORM processing USING us_screen.

  ELSE.
    PERFORM processing USING us_screen.
  ENDIF.
* mbi0008---------------------------------------------------------------

  CASE retcode.
    WHEN 0.
      return_code = 0.
    WHEN 3.
      return_code = 3.
    WHEN OTHERS.
      return_code = 1.
  ENDCASE.
ENDFORM.                    "ENTRY_CH

***********************************************************************
*                                                                     *
* Customer Entry-Routines                                             *
*                                                                     *
***********************************************************************



***********************************************************************
*                                                                     *
* Standard Routine PROCESSING                                         *
*                                                                     *
***********************************************************************

FORM processing USING proc_screen.

* mbi0006--------------------------------------------------------------
  DATA : wa_command      TYPE string.
* mbi0006--------------------------------------------------------------

  PERFORM get_data.
* hfr20090527 Ermitteln ob Fakturaplan vorhanden ist oder nicht!
  PERFORM faktura_plan.

  CHECK retcode = 0.
  PERFORM form_open USING proc_screen vbdkr-land1.
  CHECK retcode = 0.

* mbi0013--------------------------------------------------------------
  CASE vbdkr-vkorg.

    WHEN '9030'.
*      CONCATENATE 'PRINT-CONTROL TRY0' '2' INTO wa_command. "rte0013 --> rte0015
      CONCATENATE 'PRINT-CONTROL TRY0' '1' INTO wa_command. "rte0015
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command   = wa_command
        EXCEPTIONS
          unopened  = 1
          unstarted = 2
          OTHERS    = 3.
* DEL rte0015
* INS rte0014
*      CLEAR wa_command.
*      CONCATENATE 'PRINT-CONTROL' 'SPMSI' INTO wa_command SEPARATED BY space.
*      CALL FUNCTION 'CONTROL_FORM'
*        EXPORTING
*          command   = wa_command
*        EXCEPTIONS
*          unopened  = 1
*          unstarted = 2
*          OTHERS    = 3.
* INS rte0014
* DEL rte0015
*   mbi0006--------------------------------------------------------------
*   IF vbdkr-vkorg EQ '9050'.
    WHEN '9050'.
*   mbi0013--------------------------------------------------------------
      CONCATENATE 'PRINT-CONTROL TRY0' '3' INTO wa_command.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command   = wa_command
        EXCEPTIONS
          unopened  = 1
          unstarted = 2
          OTHERS    = 3.
* mbi0006----------------------------------------------------------------

*   HORNM_130226------------------------------------------------------------
*   mbi0013--------------------------------------------------------------
    WHEN '3000'.
*  IF vbdkr-vkorg EQ '3000'.
*   mbi0013--------------------------------------------------------------
      CONCATENATE 'PRINT-CONTROL TRY0' '3' INTO wa_command.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command   = wa_command
        EXCEPTIONS
          unopened  = 1
          unstarted = 2
          OTHERS    = 3.
*   mbi0013---------------------------------------------------------------
*  ENDIF.
  ENDCASE.
*  HORNM_130226-----------------------------------------------------------
*  mbi0013----------------------------------------------------------------
  PERFORM form_title_print.
  CHECK retcode = 0.
  PERFORM header_consgnee.
  CHECK retcode = 0.
  PERFORM tax_text_print.
  CHECK retcode = 0.
  PERFORM header_data_print.
  CHECK retcode = 0.
  PERFORM header_text_print.
  CHECK retcode = 0.
  PERFORM item_print.
  CHECK retcode = 0.
  PERFORM end_print.
  CHECK retcode = 0.
  PERFORM form_close.
  CHECK retcode = 0.

ENDFORM.                    "PROCESSING

***********************************************************************
*                                                                     *
* Standard Routine PROCESSING_ESR                                     *
*                                                                     *
***********************************************************************

FORM processing_esr USING proc_screen.

  DATA : lt_fplt LIKE fpltvb OCCURS 1 WITH HEADER LINE.
  DATA : ld_fkwrt LIKE acccr-wrbtr.
  PERFORM get_data.
  ld_fkwrt = komk-fkwrt.
  CALL FUNCTION 'BILLING_SCHEDULE_CREATE_T052S'
    EXPORTING
      zterm                   = vbdkr-zterm
      wert                    = ld_fkwrt
      waerk                   = vbdkr-waerk
      fkdat                   = vbdkr-fkdat
      i_company_code          = vbdkr-bukrs
    TABLES
      zfplt                   = lt_fplt
    EXCEPTIONS
      no_entry_t052s          = 1
      no_zfbdt                = 2
      no_entry_t052           = 3
      no_billing_schedule     = 4
      no_entry_in_t001r_found = 5
      OTHERS                  = 6.
  IF sy-subrc EQ 4.
    PERFORM get_data_esr.
    CHECK retcode = 0.
    PERFORM form_open USING proc_screen vbdkr-land1.
    CHECK retcode = 0.
    PERFORM start_form.
    CHECK retcode = 0.
    PERFORM header_consgnee.
    CHECK retcode = 0.
    PERFORM header_text_print.
    CHECK retcode = 0.
    PERFORM item_print.
    CHECK retcode = 0.
    PERFORM end_print.
    CHECK retcode = 0.
    PERFORM form_close.
    CHECK retcode = 0.
  ELSE.
    LOOP AT lt_fplt.
      komk-fkwrt = lt_fplt-fakwr.
      PERFORM get_data_esr.
      CHECK retcode = 0.
      PERFORM form_open USING proc_screen vbdkr-land1.
      CHECK retcode = 0.
      PERFORM start_form.
      CHECK retcode = 0.
      PERFORM header_consgnee.
      CHECK retcode = 0.
      PERFORM header_text_print.
      CHECK retcode = 0.
      PERFORM item_print.
      CHECK retcode = 0.
      PERFORM end_print.
      CHECK retcode = 0.
      PERFORM form_close.
      CHECK retcode = 0.
    ENDLOOP.
  ENDIF.

ENDFORM.                    "PROCESSING_ESR

***********************************************************************
*                                                                     *
* Standard Routine PROCESSING_ITALY                                   *
*                                                                     *
***********************************************************************

FORM processing_italy USING proc_screen.

  PERFORM get_data.
  PERFORM get_data_italy USING proc_screen.
  CHECK retcode = 0.
  PERFORM form_open USING proc_screen vbdkr-land1.
  CHECK retcode = 0.
  PERFORM form_title_print.
  CHECK retcode = 0.
  PERFORM header_consgnee.
  CHECK retcode = 0.
  PERFORM tax_text_print.
  CHECK retcode = 0.
  PERFORM header_data_print.
  CHECK retcode = 0.
  PERFORM header_text_print.
  CHECK retcode = 0.
  PERFORM item_print.
  CHECK retcode = 0.
  PERFORM end_print.
  CHECK retcode = 0.
  PERFORM form_close.
  CHECK retcode = 0.

ENDFORM.                    "PROCESSING_ITALY

***********************************************************************
*       SAP STANDARD-SUBROUTINES                                      *
***********************************************************************

*---------------------------------------------------------------------*
*       FORM AMOUNT_FOR_CASH_DISCOUNT                                 *
*---------------------------------------------------------------------*
*       This routine prints the amount qualifying for cash discount.  *
*---------------------------------------------------------------------*

FORM amount_for_cash_discount.

  CHECK vbdkr-skfbk NE 0.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'AMOUNT_QUALIFYING_FOR_CASH_DISCOUNT'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "AMOUNT_FOR_CASH_DISCOUNT

*---------------------------------------------------------------------*
*       FORM PAYMENT_SPLIT                                            *
*---------------------------------------------------------------------*
*       This routine prints the payment split                         *
*---------------------------------------------------------------------*
FORM payment_split.

  DATA: h_skfbt LIKE acccr-skfbt.
  DATA: h_fkdat LIKE vbrk-fkdat.
  DATA: h_fkwrt LIKE acccr-wrbtr.
  DATA : BEGIN OF payment_split OCCURS 3.
          INCLUDE STRUCTURE vtopis.
  DATA : END OF payment_split.


  CHECK vbdkr-zterm NE space.

  h_skfbt = vbdkr-skfbk.
  h_fkwrt = komk-fkwrt.
  h_fkdat = vbdkr-fkdat.
  IF vbdkr-valdt NE 0.
    h_fkdat = vbdkr-valdt.
  ENDIF.
  IF vbdkr-valtg NE 0.
    h_fkdat = vbdkr-fkdat + vbdkr-valtg.
  ENDIF.
  CALL FUNCTION 'SD_PRINT_TERMS_OF_PAYMENT_SPLI'
    EXPORTING
      i_country                     = vbdkr-land1
      bldat                         = h_fkdat
      budat                         = h_fkdat
      cpudt                         = h_fkdat
      language                      = vbco3-spras
      terms_of_payment              = vbdkr-zterm
      wert                          = h_fkwrt  "Warenwert + Tax
      waerk                         = vbdkr-waerk
      fkdat                         = vbdkr-fkdat
      skfbt                         = h_skfbt
      i_company_code                = vbdkr-bukrs
    TABLES
      top_text_split                = payment_split
    EXCEPTIONS
      terms_of_payment_not_in_t052  = 01
      terms_of_payment_not_in_t052s = 02.

  LOOP AT payment_split.

    AT FIRST.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = 'PROTECT'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TERMS_OF_PAYMENT_SPLIT_HEADER'.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ENDAT.

    vbdkr-text = payment_split-line.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'TERMS_OF_PAYMENT_SPLIT'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.

    AT LAST.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = 'ENDPROTECT'.
    ENDAT.

  ENDLOOP.

ENDFORM.                    "PAYMENT_SPLIT

*---------------------------------------------------------------------*
*       FORM CHECK_REPEAT                                             *
*---------------------------------------------------------------------*
*       A text is printed, if it is a repeat print for the document.  *
*---------------------------------------------------------------------*

FORM check_repeat.

  CLEAR repeat.
  SELECT * INTO *nast FROM nast WHERE kappl = nast-kappl
                                AND   objky = nast-objky
                                AND   kschl = nast-kschl
                                AND   spras = nast-spras
                                AND   parnr = nast-parnr
                                AND   parvw = nast-parvw
                                AND   nacha BETWEEN '1' AND '4'.
    CHECK *nast-vstat = '1'.
    repeat = 'X'.
    EXIT.
  ENDSELECT.

ENDFORM.                    "CHECK_REPEAT

*---------------------------------------------------------------------*
*       FORM DIFFERENT_CONSIGNEE                                      *
*---------------------------------------------------------------------*
*       If the consignee in the item is different to the header con-  *
*       signee, it is printed by this routine.                        *
*---------------------------------------------------------------------*

FORM different_consignee.

  CHECK vbdkr-name1_we NE vbdpr-name1_we
    OR  vbdkr-name2_we NE vbdpr-name2_we
    OR  vbdkr-name3_we NE vbdpr-name3_we
    OR  vbdkr-name4_we NE vbdpr-name4_we.
  CHECK vbdpr-name1_we NE space
    OR  vbdpr-name2_we NE space
    OR  vbdpr-name3_we NE space
    OR  vbdpr-name4_we NE space.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_CONSIGNEE'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "DIFFERENT_CONSIGNEE

*---------------------------------------------------------------------*
*       FORM DIFFERENT_DELIVERY_NO                                    *
*---------------------------------------------------------------------*
*       If the delivery number is different to number in the header,  *
*       it is printed by this routine.                                *
*---------------------------------------------------------------------*

FORM different_delivery_no.

  CHECK vbdkr-vbtyp CA 'MUN'.
  CHECK vbdpr-vbeln_vl NE vbdpr-vbeln_vauf.
  CHECK vbdkr-vbeln_vl NE vbdpr-vbeln_vl.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_DELIVERY_NO'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "DIFFERENT_DELIVERY_NO

*---------------------------------------------------------------------*
*       FORM DIFFERENT_ORDER_NO                                       *
*---------------------------------------------------------------------*
*       If the order number is different to number in the header,     *
*       it is printed by this routine.                                *
*---------------------------------------------------------------------*

FORM different_order_no.

  CHECK vbdkr-vbtyp CA 'MUN'.
  CHECK vbdpr-vbeln_vauf NE space.
  CHECK vbdkr-vbeln_vauf NE vbdpr-vbeln_vauf.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_ORDER_NO'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "DIFFERENT_ORDER_NO

*---------------------------------------------------------------------*
*       FORM DIFFERENT_EXTERN_NO                                      *
*---------------------------------------------------------------------*
*       If the extern number is different to number in the header,    *
*       it is printed by this routine.                                *
*---------------------------------------------------------------------*

FORM different_extern_no.

  CHECK vbdkr-vbtyp CA 'MUN'.
  CHECK vbdkr-vbeln_vauf EQ space.
  CHECK vbdkr-vbeln_vl   EQ space.
  CHECK vbdpr-vbeln_vauf EQ space.
  CHECK vbdpr-vbeln_vl   EQ space.
  CHECK vbdkr-vgbel NE vbdpr-vgbel.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_EXTERN_NO'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "DIFFERENT_EXTERN_NO
*---------------------------------------------------------------------*
*       FORM DIFFERENT_PURCHASE_ORDER_NO                              *
*---------------------------------------------------------------------*
*       If the purchase order number is different to number in the    *
*       header, it is printed by this routine.                        *
*---------------------------------------------------------------------*

FORM different_purchase_order_no.

  CHECK vbdkr-vbtyp CA 'MUN'.
  CHECK vbdpr-bstnk NE space.
  CHECK vbdkr-bstnk NE vbdpr-bstnk
    OR  vbdkr-bstdk NE vbdpr-bstdk.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_PURCHASE_ORDER_NO'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "DIFFERENT_PURCHASE_ORDER_NO

*---------------------------------------------------------------------*
*       FORM END_PRINT                                                *
*---------------------------------------------------------------------*
*                                                                     *
*---------------------------------------------------------------------*

FORM end_print.

  CALL FUNCTION 'CONTROL_FORM'
    EXPORTING
      command = 'PROTECT'.
  PERFORM header_price_print.


  IF vbdkr-vkorg NE '9030'.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'END_VALUES'.
  ELSE.
    IF komk-fkwrt > komk-supos.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'END_VALUES'.
    ENDIF.
  ENDIF.




  PERFORM downpayment_value.
  PERFORM paymentcard_values.
  PERFORM amount_for_cash_discount.
  CALL FUNCTION 'CONTROL_FORM'
    EXPORTING
      command = 'ENDPROTECT'.
  PERFORM payment_split.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'SUPPLEMENT_TEXT'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.
  CONCATENATE 'ZSD_ADDITIONAL_TEXT_' vbdkr-vkorg INTO wa_head-tdname.
  CLEAR wa_head-tdspras.
  wa_head-tdobject = 'TEXT'.
  wa_head-tdid     = 'ST'.
  SELECT tdspras FROM  stxh INTO wa_head-tdspras
         WHERE  tdobject  = wa_head-tdobject
         AND    tdname    = wa_head-tdname
         AND    tdid      = wa_head-tdid.
    IF wa_head-tdspras = nast-spras.
      EXIT.
    ENDIF.
  ENDSELECT.
  IF wa_head-tdspras IS NOT INITIAL.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'SPACE_LINE'
      EXCEPTIONS
        element = 1
        window  = 2.

    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'INFORMATION_TEXT'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.

* mbi0013------------------------------------------------------------
  IF vbdkr-vkorg EQ '2000'.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'AEO_LOGO'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.
* mbi0013------------------------------------------------------------
ENDFORM.                    "END_PRINT

*---------------------------------------------------------------------*
*       FORM FORM_CLOSE                                               *
*---------------------------------------------------------------------*
*       End of printing the form                                      *
*---------------------------------------------------------------------*

FORM form_close.

  DATA: i_itcpp LIKE itcpp.

  CALL FUNCTION 'CLOSE_FORM'
    IMPORTING
      RESULT = i_itcpp
    EXCEPTIONS
      OTHERS = 1.
  IF sy-subrc NE 0.
    retcode = sy-subrc.
    PERFORM protocol_update.
  ENDIF.
  IF i_itcpp-tdspoolid NE space.
    PERFORM protocol_update_spool USING '342' i_itcpp-tdspoolid
                                              space space space.
  ENDIF.

  SET COUNTRY space.

* update number of printed pages in VBRK for Argentina
  CALL FUNCTION 'J_1A_SD_UPD_NUM_OF_PAGES'
    EXPORTING
      pages = i_itcpp-tdpages
      vbeln = vbdkr-vbeln
      bukrs = vbdkr-bukrs.


ENDFORM.                    "FORM_CLOSE

*---------------------------------------------------------------------*
*       FORM FORM_OPEN                                                *
*---------------------------------------------------------------------*
*       Start of printing the form                                    *
*---------------------------------------------------------------------*
*  -->  US_SCREEN  Output on screen                                   *
*                  ' ' = Printer                                      *
*                  'X' = Screen                                       *
*  -->  US_COUNTRY County for telecommunication and SET COUNTRY       *
*---------------------------------------------------------------------*

FORM form_open USING us_screen us_country.

  INCLUDE rvadopfo.

ENDFORM.                    "FORM_OPEN

*---------------------------------------------------------------------*
*       FORM FORM_TITLE_PRINT                                         *
*---------------------------------------------------------------------*
*       Printing of the form title depending of the field VBTYP       *
*---------------------------------------------------------------------*

FORM form_title_print.

  CASE vbdkr-vbtyp.
    WHEN 'M'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_M'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    WHEN 'N'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_N'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    WHEN 'O'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_O'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    WHEN 'P'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_P'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    WHEN 'S'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_S'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    WHEN 'U'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_U'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    WHEN OTHERS.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_M'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
  ENDCASE.
  IF repeat NE space.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'REPEAT'
        window  = 'REPEAT'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.

ENDFORM.                    "FORM_TITLE_PRINT

*---------------------------------------------------------------------*
*       FORM GET_DATA                                                 *
*---------------------------------------------------------------------*
*       General provision of data for the form                        *
*---------------------------------------------------------------------*
FORM get_data.

* Local data definition----------------------------------------
  DATA : wl_vbak TYPE vbak.


  CALL FUNCTION 'RV_PRICE_PRINT_REFRESH'
    TABLES
      tkomv = tkomv.
  CLEAR komk.
  CLEAR komp.

  IF nast-objky+10(6) NE space.
    vbco3-vbeln = nast-objky+16(10).
  ELSE.
    vbco3-vbeln = nast-objky.
  ENDIF.

  vbco3-mandt = sy-mandt.
  vbco3-spras = nast-spras.
  vbco3-kunde = nast-parnr.
  vbco3-parvw = nast-parvw.

  CALL FUNCTION 'RV_BILLING_PRINT_VIEW'
    EXPORTING
      comwa                        = vbco3
    IMPORTING
      kopf                         = vbdkr
    TABLES
      pos                          = tvbdpr
    EXCEPTIONS
      terms_of_payment_not_in_t052 = 1
      error_message                = 5
      OTHERS                       = 4.
  IF NOT sy-subrc IS INITIAL.
    IF sy-subrc = 1.
      syst-msgty = 'I'.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.


  CLEAR kna1.

  SELECT        * FROM  kna1
         WHERE  kunnr  = vbdkr-kunre.

  ENDSELECT.



*...Einfügen neue Zahlungsbedingungen mit code Z... (z.B. Z005)
*...aus Tabelle T052U                             sap4u opj 28.02.2003
  SELECT SINGLE * FROM t052u
     WHERE spras = vbdkr-spras AND
           zterm = vbdkr-zterm.
  IF sy-subrc = 0 AND
       t052u-text1 <> space.
    MOVE t052u-text1 TO vbdkr-zterm_tx1.
    MOVE space       TO vbdkr-zterm_tx2.
    MOVE space       TO vbdkr-zterm_tx3.
  ENDIF.


*   replace 'jusque' with 'jusq' into VBDKR-ZTERM_TX1.


  READ TABLE tvbdpr INDEX 1.

  SELECT        * FROM  vbak
         WHERE  vbeln  = tvbdpr-vgbel.

  ENDSELECT.

  IF vbak-aufnr EQ space.

    SELECT        * FROM  viqmel
           WHERE  qmnum  = vbak-qmnum.

    ENDSELECT.

    IF sy-subrc EQ 0.
      SELECT        * FROM  equi
             WHERE  equnr  = viqmel-equnr.

      ENDSELECT.
    ENDIF.

    h_service = vbak-vbeln.


  ELSE.
    SELECT        * FROM  afih
       WHERE  aufnr  = vbak-aufnr.

    ENDSELECT.

    SELECT        * FROM  equi
           WHERE  equnr  = afih-equnr.

    ENDSELECT.


    h_service = afih-aufnr.

  ENDIF.


  CLEAR knvv.
  SELECT        * FROM  knvv
         WHERE  kunnr  = vbdkr-kunre
         AND    vkorg  = vbdkr-vkorg.

  ENDSELECT.

  SHIFT equi-sernr LEFT DELETING LEADING '0'.
  h_sernr = equi-sernr.

  SELECT        * FROM  makt
         WHERE  matnr  = equi-matnr
         AND    spras  = nast-spras.

  ENDSELECT.


  IF vbdkr-kalsm+00(04) NE 'ZSER'.

    IF  vbdkr-fkart EQ 'ZL2'
    OR  vbdkr-fkart EQ 'ZG2'.

      CLEAR h_service.

    ENDIF.
  ENDIF.


  CLEAR knvv.

  SELECT        * FROM  knvv
         WHERE  kunnr  = vbdkr-kunre
         AND    vkorg  = vbdkr-vkorg
         AND    vtweg  = vbdkr-vtweg
         AND    spart  = vbdkr-spart.
  ENDSELECT.
*hornm20100811-Begin
*Verkaufsorganisation 2000
*Wenn kein Satz gefunden in Sparte 10 suchen.
  IF sy-subrc NE 0 AND vbdkr-vkorg EQ '2000'.
    SELECT SINGLE * FROM  knvv
           WHERE  kunnr  = vbdkr-kunre
           AND    vkorg  = vbdkr-vkorg
           AND    vtweg  = vbdkr-vtweg
           AND    spart  = '10'.
  ENDIF.
*hornm20100811--End




* fill address key --> necessary for emails
  addr_key-addrnumber = vbdkr-adrnr.
  addr_key-persnumber = vbdkr-adrnp.
  addr_key-addr_type  = vbdkr-address_type.

  PERFORM sender.
  PERFORM check_repeat.
  PERFORM get_header_prices.
* Calling customer subroutine dynamically for additional data transfer
  IF NOT get_data_userexit IS INITIAL.
    PERFORM (get_data_userexit) IN PROGRAM rvadin01 IF FOUND.
  ENDIF.

* mbi0001--------------------------------------------------------------
* Get supplementary adress data----------------------------------------

  MOVE : addr_key-addrnumber TO wa_adresse_sel-addrnumber.

  CALL FUNCTION 'ADDR_GET'
    EXPORTING
      address_selection = wa_adresse_sel
    IMPORTING
      sadr              = wl_sadr
    EXCEPTIONS
      parameter_error   = 1
      address_not_exist = 2
      version_not_exist = 3
      internal_error    = 4
      OTHERS            = 5.
  IF sy-subrc NE 0.
    CLEAR wl_sadr.
  ENDIF.

* mbi0001--------------------------------------------------------------
  SELECT SINGLE * FROM likp INTO wl_likp WHERE vbeln EQ vbdkr-vbeln_vl.
* mbi0001-------------------------------------------------------------
  break deltennor.
* rte0002
* Check ob Text ZEI / VBBK vorhanden, nur dann andrucken von "Serial-No."
  CLEAR flg_china.
  SELECT SINGLE * FROM stxh WHERE
      tdobject EQ 'VBBK' AND
      tdname   EQ vbdkr-vbeln AND
      tdid     EQ 'ZEI' AND
      tdspras  EQ nast-spras.

  IF sy-subrc EQ 0.
    SELECT SINGLE * FROM kna1 WHERE kunnr EQ vbdkr-kunag.
    IF kna1-land1 EQ 'CN' AND kna1-ort01 NP '*Hong Kong*'.
      flg_china  = 'X'.
      CONCATENATE '07710' vbdkr-fkdat+6(2) vbdkr-fkdat+4(2)
                          vbdkr-fkdat+0(4) vbdkr-vbeln
                          INTO ser_china.
    ENDIF.
  ENDIF.
* rte0002


* mbi0013------------------------------------------------------------------
  IF vbdkr-vkorg EQ '3000'.
    SELECT SINGLE * FROM vbak INTO wl_vbak WHERE vbeln EQ vbdkr-vbeln_vauf.
    PERFORM get_contact_data_3000 USING wl_vbak-ernam.
  ENDIF.
* mbi0013------------------------------------------------------------------





ENDFORM.                    "GET_DATA


*---------------------------------------------------------------------*
*       FORM GET_ITEM_CHARACTERISTICS                                 *
*---------------------------------------------------------------------*
*       In this routine the configuration data item is fetched from   *
*       the database.                                                 *
*---------------------------------------------------------------------*

FORM get_item_characteristics.

  DATA da_t_cabn LIKE cabn OCCURS 10 WITH HEADER LINE.
  DATA: BEGIN OF da_key,
          mandt LIKE cabn-mandt,
          atinn LIKE cabn-atinn,
        END   OF da_key.

  REFRESH tkomcon.
  CHECK NOT vbdpr-cuobj IS INITIAL.

  CALL FUNCTION 'VC_I_GET_CONFIGURATION'
    EXPORTING
      instance      = vbdpr-cuobj
      language      = nast-spras
      print_sales   = 'X'
    TABLES
      configuration = tkomcon
    EXCEPTIONS
      OTHERS        = 4.

  RANGES : da_in_cabn FOR da_t_cabn-atinn.
* Beschreibung der Merkmale wegen Objektmerkmalen auf sdcom-vkond holen
  CLEAR da_in_cabn. REFRESH da_in_cabn.
  LOOP AT tkomcon.
    da_in_cabn-option = 'EQ'.
    da_in_cabn-sign   = 'I'.
    da_in_cabn-low    = tkomcon-atinn.
    APPEND da_in_cabn.
  ENDLOOP.

  CLEAR da_t_cabn. REFRESH da_t_cabn.
  CALL FUNCTION 'CLSE_SELECT_CABN'
*    EXPORTING
*         KEY_DATE                     = SY-DATUM
*         BYPASSING_BUFFER             = ' '
*         WITH_PREPARED_PATTERN        = ' '
*         I_AENNR                      = ' '
*    IMPORTING
*         AMBIGUOUS_OBJ_CHARACTERISTIC =
     TABLES
          in_cabn                      = da_in_cabn
          t_cabn                       = da_t_cabn
     EXCEPTIONS
          no_entry_found               = 1
          OTHERS                       = 2.

* Preisfindungsmerkmale und Merkmale auf vcsd_update herausnehmen
  SORT da_t_cabn.
  LOOP AT tkomcon.
    da_key-mandt = sy-mandt.
    da_key-atinn = tkomcon-atinn.
    READ TABLE da_t_cabn WITH KEY da_key BINARY SEARCH.
    IF sy-subrc <> 0 OR
         ( ( da_t_cabn-attab = 'SDCOM' AND
            da_t_cabn-atfel = 'VKOND'       ) OR
          ( da_t_cabn-attab = 'VCSD_UPDATE' ) ) .
      DELETE tkomcon.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "GET_ITEM_CHARACTERISTICS

*---------------------------------------------------------------------*
*       FORM GET_ITEM_PRICES                                          *
*---------------------------------------------------------------------*
*       In this routine the price data for the item is fetched from   *
*       the database.                                                 *
*---------------------------------------------------------------------*

FORM get_item_prices.

  CLEAR: komp,
         tkomv.

  IF komk-knumv NE vbdkr-knumv.
    CLEAR komk.
    komk-mandt = sy-mandt.
    komk-kalsm = vbdkr-kalsm.
    komk-fkart = vbdkr-fkart.
    komk-kappl = pr_kappl.
    IF vbdkr-kappl NE space.
      komk-kappl = vbdkr-kappl.
    ENDIF.
    komk-waerk = vbdkr-waerk.
    komk-knumv = vbdkr-knumv.
    komk-vbtyp = vbdkr-vbtyp.
    komk-bukrs = vbdkr-bukrs.
    komk-land1 = vbdkr-lland.
  ENDIF.
  komp-kposn = vbdpr-posnr.

  CALL FUNCTION 'RV_PRICE_PRINT_ITEM'
    EXPORTING
      comm_head_i = komk
      comm_item_i = komp
      language    = nast-spras
    IMPORTING
      comm_head_e = komk
      comm_item_e = komp
    TABLES
      tkomv       = tkomv
      tkomvd      = tkomvd.
* Calling customer subroutine dynamically for handling item prices
  IF NOT item_userexit IS INITIAL.
    PERFORM (item_userexit) IN PROGRAM rvadin01 IF FOUND.
  ENDIF.

ENDFORM.                    "GET_ITEM_PRICES

*---------------------------------------------------------------------*
*       FORM GET_HEADER_PRICES                                        *
*---------------------------------------------------------------------*
*       In this routine the price data for the header is fetched from *
*       the database.                                                 *
*---------------------------------------------------------------------*

FORM get_header_prices.

  IF komk-knumv NE vbdkr-knumv.
    CLEAR komk.
    komk-mandt = sy-mandt.
    komk-kalsm = vbdkr-kalsm.
    komk-fkart = vbdkr-fkart.
    komk-kappl = pr_kappl.
    IF vbdkr-kappl NE space.
      komk-kappl = vbdkr-kappl.
    ENDIF.
    komk-waerk = vbdkr-waerk.
    komk-knumv = vbdkr-knumv.
    komk-vbtyp = vbdkr-vbtyp.
    komk-knuma = vbdkr-knuma.
    komk-bukrs = vbdkr-bukrs.
    komk-land1 = vbdkr-lland.
  ENDIF.
  CALL FUNCTION 'RV_PRICE_PRINT_HEAD'
    EXPORTING
      comm_head_i = komk
      language    = nast-spras
    IMPORTING
      comm_head_e = komk
      comm_mwskz  = print_mwskz
    TABLES
      tkomv       = tkomv
      tkomvd      = hkomvd.
* Calling customer subroutine dynamically for handling header prices
  IF NOT header_userexit IS INITIAL.
    PERFORM (header_userexit) IN PROGRAM rvadin01 IF FOUND.
  ENDIF.

ENDFORM.                    "GET_HEADER_PRICES

*---------------------------------------------------------------------*
*       FORM HEADER_PRICE_PRINT                                       *
*---------------------------------------------------------------------*
*       Printout of the header prices                                 *
*---------------------------------------------------------------------*

FORM header_price_print.

  LOOP AT hkomvd.

    AT FIRST.
*    mbi0001-----------------------------------------------------------
*      IF KOMK-SUPOS NE 0.
*    mbi0001-----------------------------------------------------------
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_SUM'.
*      ELSE.
*        CALL FUNCTION 'WRITE_FORM'
*          EXPORTING
*            ELEMENT = 'UNDER_LINE'
*          EXCEPTIONS
*            ELEMENT = 1
*            WINDOW  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
*    mbi0001-----------------------------------------------------------
*      ENDIF.
    ENDAT.

    komvd = hkomvd.
    IF print_mwskz = space.
      CLEAR komvd-mwskz.
    ENDIF.
    IF komvd-koaid = 'D'.

      IF vbdkr-vkorg = '9030' AND komvd-kschl = 'MWST' AND komvd-kbetr =
      0.
      ELSE.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'TAX_LINE'.
      ENDIF.
    ELSE.
      IF NOT komvd-kntyp EQ 'f'.


        zmerk = 'X'.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'SUM_LINE'.
      ENDIF.
    ENDIF.
  ENDLOOP.
  DESCRIBE TABLE hkomvd LINES sy-tfill.
  IF sy-tfill = 0.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'UNDER_LINE'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.
* Calling customer subroutine dynamically for handling header price
* printing
  IF NOT header_print_userexit IS INITIAL.
    PERFORM (header_print_userexit) IN PROGRAM rvadin01 IF FOUND.
  ENDIF.

ENDFORM.                    "HEADER_PRICE_PRINT

*---------------------------------------------------------------------*
*       FORM HEADER_TEXT_PRINT                                        *
*---------------------------------------------------------------------*
*       Printout of the headertexts                                   *
*---------------------------------------------------------------------*

FORM header_text_print.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'HEADER_TEXT'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "HEADER_TEXT_PRINT

*---------------------------------------------------------------------*
*       FORM ITEM_CHARACERISTICS_PRINT                                *
*---------------------------------------------------------------------*
*       Printout of the item characteristics -> configuration         *
*---------------------------------------------------------------------*

FORM item_characteristics_print.

  LOOP AT tkomcon.
    conf_out = tkomcon.
    IF sy-tabix = 1.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_CONFIGURATION_HEADER'
        EXCEPTIONS
          OTHERS  = 1.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ELSE.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_CONFIGURATION'
        EXCEPTIONS
          OTHERS  = 1.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "ITEM_CHARACTERISTICS_PRINT

*---------------------------------------------------------------------*
*       FORM ITEM_PRICE_PRINT                                         *
*---------------------------------------------------------------------*
*       Printout of the item prices                                   *
*---------------------------------------------------------------------*

FORM item_price_print.

* Local data definition-----------------------------------------------
  DATA: h_rab(1)     TYPE c,
        wa_rab_kond  TYPE c,
        wa_kzwi2     TYPE kzwi2,
        wl_tkomv_rab TYPE komv,
        fl_kbetr     LIKE wa_vbrp-kzwi1,
        wa_tabix     LIKE sy-tabix.

  CLEAR : h_rab,
          wa_rab_kond.

  break biondam.

  READ TABLE tkomvd WITH KEY kschl = 'ZRPG'.
  IF sy-subrc EQ 0.
    wa_rab_kond = 'X'.
    IF tkomvd-kbetr = '1000.00-'.
      h_rab = 'X'.
    ENDIF.
  ELSE.
    READ TABLE tkomvd WITH KEY kschl = 'ZGAE'.
    IF sy-subrc EQ 0.
      wa_rab_kond = 'X'.
      IF tkomvd-kbetr = '1000.00-'.
        h_rab = 'X'.
      ENDIF.
    ELSE.
      READ TABLE tkomvd WITH KEY kschl = 'ZMUS'.
      IF sy-subrc EQ 0.
        wa_rab_kond = 'X'.
        IF tkomvd-kbetr = '1000.00-'.
          h_rab = 'X'.
        ENDIF.

      ELSE.
        READ TABLE tkomvd WITH KEY kschl = 'ZSON'.
        IF sy-subrc EQ 0.
          wa_rab_kond = 'X'.
          IF tkomvd-kbetr = '1000.00-'.
            h_rab = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.


  LOOP AT tkomvd.
    MOVE sy-tabix TO wa_tabix.
    komvd = tkomvd.

    IF h_rab NE space AND vbdkr-bukrs EQ '3000'..
      vbdkr-bukrs = '9999'.
    ENDIF.

    CLEAR fl_kbetr.

    IF vbdkr-fkart = 'ZZZ' OR                  "Dieser Fall ist inaktiv
       vbdkr-fkart = 'ZL2' AND                 "Anpassung Roger Schneider
     ( vbdkr-bukrs NE '9010' AND
       vbdkr-bukrs NE '9020' AND
       vbdkr-bukrs NE '3000' ).

      CLEAR wa_komvd-kbetr.
      IF h_rab EQ space.
        wa_vbrp-kzwi2 = wa_vbrp-kzwi1.
      ENDIF.
    ELSE.

* HFR20100127: Anstatt KZWI1 wird CMPRE (Entwert) abgefragt
*      IF wa_vbrp-kzwi1 > 0.
      IF wa_vbrp-cmpre > 0.
*   and wa_komvd-kbetr > 0.
        fl_kbetr = wa_vbrp-kzwi1 - wa_vbrp-kzwi2.
        IF fl_kbetr NE  wa_vbrp-kzwi1.
*         mbi00009----------------------------------------------------------
          IF vbdkr-bukrs EQ '9020'.
            break biondam.
            CLEAR wl_tkomv_rab.

*           mbi0010---------------------------------------------------------
            CLEAR wa_komvd-kbetr.
*           mbi0010---------------------------------------------------------
            READ TABLE tkomv INTO wl_tkomv_rab WITH KEY kposn = tkomvd-kposn
                             kschl = 'ZRAT'.
            IF sy-subrc EQ 0 AND NOT wl_tkomv_rab-kbetr IS INITIAL.
              wa_komvd-kbetr = wl_tkomv_rab-kbetr / -10.
            ENDIF.
          ELSE.
            break biondam.
            wa_komvd-kbetr = fl_kbetr * 10000 / wa_vbrp-kzwi1.
          ENDIF.
*         mbi00009----------------------------------------------------------
        ELSE.
*           mbi0001-------------------------------------------------------------
*            IF WA_VBRP-KZWI2 EQ 0.
*              wa_komvd-kbetr = 10000.
*           mbi0001-------------------------------------------------------------
*            ELSE.
          CLEAR wa_komvd-kbetr.
          wa_vbrp-kzwi2 = wa_vbrp-kzwi1.
*           mbi0001-------------------------------------------------------------
*            endif.
*           mbi0001-------------------------------------------------------------
        ENDIF.
      ELSE.
        CLEAR wa_komvd-kbetr.
      ENDIF.
    ENDIF.

    IF vbdkr-bukrs EQ '9010' OR
       vbdkr-bukrs EQ '9020'.
      IF wa_vbrp-netwr = 0.
        wa_komvd-kbetr = 10000.
        wa_vbrp-kzwi2  = 0.
      ENDIF.
    ENDIF.

*   mbi0004---------------------------------------------------
    IF vbdkr-kalsm EQ 'ZSER02' AND
       vbdkr-fkart EQ 'ZL2'.

      IF  wa_rab_kond    EQ 'X'.
        IF wa_vbrp-kzwi1 NE 0.
*         mbi0005-------------------------------------------------
          CLEAR wa_round_netwr.
          CALL FUNCTION 'ROUND'
            EXPORTING
              decimals      = 1
              input         = wa_vbrp-netwr
              sign          = '-'
            IMPORTING
              output        = wa_round_netwr
            EXCEPTIONS
              input_invalid = 1
              overflow      = 2
              type_invalid  = 3
              OTHERS        = 4.

          fl_kbetr = wa_vbrp-kzwi1 - wa_round_netwr.
*         mbi0005-------------------------------------------------
*         mbi00009----------------------------------------------------------
          IF vbdkr-bukrs EQ '9020'.
            CLEAR wl_tkomv_rab.
*           mbi0010---------------------------------------------------------
            CLEAR wa_komvd-kbetr.
*           mbi0010---------------------------------------------------------
            READ TABLE tkomv INTO wl_tkomv_rab WITH KEY kposn = tkomvd-kposn
                             kschl = 'ZRAT'.
            IF sy-subrc EQ 0 AND NOT wl_tkomv_rab-kbetr IS INITIAL.
              wa_komvd-kbetr = wl_tkomv_rab-kbetr / -10.
            ENDIF.
          ELSE.
            wa_komvd-kbetr = fl_kbetr * 10000 / wa_vbrp-kzwi1.
          ENDIF.
*         mbi00009----------------------------------------------------------
        ELSE.
          wa_komvd-kbetr = 0.
        ENDIF.
        MOVE wa_vbrp-netwr TO wa_vbrp-kzwi2.
      ENDIF.
    ENDIF.
*   mbi0004---------------------------------------------------
    IF vbdkr-bukrs EQ '9020'.
      CALL FUNCTION 'ROUND'
        EXPORTING
          decimals      = 2
          input         = wa_komvd-kbetr
          sign          = '-'
        IMPORTING
          output        = wa_komvd-kbetr
        EXCEPTIONS
          input_invalid = 1
          overflow      = 2
          type_invalid  = 3
          OTHERS        = 4.
    ELSE.
      CALL FUNCTION 'ROUND'
        EXPORTING
          decimals      = 1
          input         = wa_komvd-kbetr
          sign          = '-'
        IMPORTING
          output        = wa_komvd-kbetr
        EXCEPTIONS
          input_invalid = 1
          overflow      = 2
          type_invalid  = 3
          OTHERS        = 4.
    ENDIF.

    DATA: h_menge TYPE i.
    CLEAR h_menge.

    h_menge = komvd-kawrt / 1000.
*   mbi0004---------------------------------------------------
    IF vbdkr-fkart NE 'ZSER'.
      IF komvd-kbetr EQ komvd-kwert AND h_menge NE 1.
        IF komvd-kpein NE 0.
          IF h_menge NE 0.
            komvd-kbetr = ( komvd-kbetr / h_menge ) / komvd-kpein.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
*   mbi0004---------------------------------------------------

    IF h_rab NE space.
      wa_komvd-kbetr = 10000.
      wa_vbrp-kzwi2  = 0.
    ENDIF.
    IF vbdpr-waerk = 'JPY'.
      wa_kzwi2_jpy = wa_vbrp-kzwi2.
    ENDIF.

*   mbi0004---------------------------------------------------
    CLEAR wa_kbetr_ser.
    IF vbdpr-matnr EQ 'SER2000' OR vbdpr-matnr EQ 'SER2001'.
      IF vbdpr-vrkme EQ 'MIN' AND komvd-kmein EQ 'H'.
        wa_kbetr_ser = komvd-kbetr / 60.
      ELSEIF vbdpr-vrkme EQ 'H' AND komvd-kmein EQ 'MIN'.
        wa_kbetr_ser = komvd-kbetr * 60.
      ENDIF.
    ENDIF.
*   mbi0004---------------------------------------------------

    IF print_mwskz EQ space.
      CLEAR komvd-mwskz.
    ENDIF.
*    mbi00009----------------------------------------------------------
*    IF sy-tabix = 1.
    IF wa_tabix = 1.
*    mbi00009----------------------------------------------------------
      IF komvd-koaid = 'B' OR komvd-kschl IS INITIAL.
        ADD wa_vbrp-kzwi2 TO wa_kzwi2_tot.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'ITEM_LINE_PRICE_QUANTITY'.
        IF vbdpr-pstyv = 'ZTAF'.
          PERFORM faktura_plan_pos .
        ENDIF.
      ELSE.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'ITEM_LINE_PRICE_TEXT'.
      ENDIF.
    ELSE.
      IF komvd-kntyp NE 'f'.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'ITEM_LINE_PRICE_TEXT'.
      ELSE.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'ITEM_LINE_REBATE_IN_KIND'.
      ENDIF.
    ENDIF.
  ENDLOOP.
* Calling customer subroutine dynamically for handling item price
* printing
  IF NOT item_print_userexit IS INITIAL.
    PERFORM (item_print_userexit) IN PROGRAM rvadin01 IF FOUND.
  ENDIF.

ENDFORM.                    "ITEM_PRICE_PRINT

*---------------------------------------------------------------------*
*       FORM ITEM_PRINT                                               *
*---------------------------------------------------------------------*
*       Printout of the items                                         *
*---------------------------------------------------------------------*

FORM item_print.

  DATA: da_ganf(1) TYPE c,      "Print flag for billing correction
        da_lanf(1) TYPE c.      "Print flag for billing correction

  CALL FUNCTION 'WRITE_FORM'           "First header
       EXPORTING  element = 'ITEM_HEADER'
       EXCEPTIONS OTHERS  = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.
  CALL FUNCTION 'WRITE_FORM'           "Activate header
       EXPORTING  element = 'ITEM_HEADER'
                  type    = 'TOP'
       EXCEPTIONS OTHERS  = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

  CLEAR: wa_perfk, wa_tot_we, wa_kzwi2_tot.
  ..
  SELECT SINGLE perfk FROM  knvv INTO wa_perfk
         WHERE  kunnr  = vbdkr-kunag
         AND    vkorg  = vbdkr-vkorg.
* HFR20090813: Gemäss Mail von Jan. Lorbert -> Wenn Fakturiert Menge = 0 --> nichts ausgeben!
  LOOP AT tvbdpr WHERE fkimg = 0.
    DELETE tvbdpr.
  ENDLOOP.


  LOOP AT tvbdpr.


*   mbi0007----------------------------------------------------------------------------------
*    IF wa_auart     EQ 'ZKL' AND
*       tvbdpr-pstyv EQ 'ZKLP'.
*      CONTINUE.
*    ENDIF.
*   mbi0007----------------------------------------------------------------------------------

    vbdpr = tvbdpr.
* HFR20090317: Pro neuem Warenenpfänger --> new Page! Aber nur bei
*              Deutschen Auftägen
    CLEAR wa_new_del.
    AT FIRST.
      wa_kunwe = vbdpr-kunwe.
    ENDAT.
    IF vbdkr-vkorg = '9010' AND wa_perfk IS NOT INITIAL.
      IF wa_kunwe NE vbdpr-kunwe.
        IF wa_kunwe IS INITIAL.
          wa_kunwe_p = vbdkr-kunwe.
        ELSE.
          wa_kunwe_p = wa_kunwe.
        ENDIF.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'ITEM_TOT_WE'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
        CLEAR  wa_kzwi2_tot.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'NEW_PAGE'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
        wa_new_we = 'J'.
        CLEAR wa_adrnr.
        SELECT SINGLE adrnr FROM  vbpa INTO wa_adrnr
               WHERE  vbeln  = vbdkr-vbeln
               AND    posnr  = vbdpr-posnr
               AND    parvw  = 'WE'.
        IF sy-subrc NE 0 OR wa_adrnr IS INITIAL.
          SELECT SINGLE adrnr FROM  kna1 INTO wa_adrnr
                 WHERE  kunnr  = vbdpr-kunwe.


        ENDIF.
        IF vbdkr-vkorg EQ'9010' AND wa_perfk IS NOT INITIAL.
          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = 'ITEM_CONSIGNEE'
              window  = 'ADDR_WE'
            EXCEPTIONS
              element = 1
              window  = 2.
          wa_tot_we = 'J'.
        ENDIF.
      ELSE.
        CLEAR: wa_new_we.
      ENDIF.
      wa_kunwe = vbdpr-kunwe.

      IF wa_vbeln_vl NE vbdpr-vbeln_vl.
        wa_new_del = 'J'.

*        CALL FUNCTION 'WRITE_FORM'
*          EXPORTING
*            ELEMENT = 'ITEM_DELIVERY_NO'
*          EXCEPTIONS
*            ELEMENT = 1
*            WINDOW  = 2.
*        IF SY-SUBRC NE 0.
*          PERFORM PROTOCOL_UPDATE.
*        ENDIF.
      ENDIF.
      wa_vbeln_vl = vbdpr-vbeln_vl.
    ELSE.
      CLEAR wa_new_we.
    ENDIF.
* HFR20090317: ENDE: Pro neuem Warenenpfänger --> new Page! Aber nur bei
*              Spanischen Auftägen

    IF vbdpr-vrkme = 'KM1'.
      vbdpr-vrkme = 'KM'.
    ENDIF.


    SELECT        * FROM  vbrp
           WHERE  vbeln  = vbdkr-vbeln
           AND    posnr  = vbdpr-posnr.

    ENDSELECT.


* Bei Fakturen, die keine Anzahlungsanforderungen darstellen, werden
* die Verrechnungspositionen nicht gedruckt
    IF ( vbdkr-fktyp EQ 'P'  )       OR
       ( vbdkr-fktyp NE 'P' AND vbdpr-fareg NA '45' ).
      PERFORM item_billing_correction_header USING da_ganf da_lanf.
      IF tvbdpr-uecha EQ vbdpr-uecha OR
         tvbdpr-uecha IS INITIAL.
        PERFORM get_item_prices.
        PERFORM get_item_characteristics.
*
* cjo Serialnummer
*
        PERFORM get_item_serials.
*
* cjo Lesen der Herkunft
* >
        CLEAR wa_marc.
        SELECT SINGLE *
          INTO  wa_marc
          FROM  marc CLIENT SPECIFIED
          WHERE mandt  = sy-mandt
          AND   matnr  = vbdpr-matnr
          AND   werks  = vbdkr-vkorg.
* <
* cjo Lesen Bruttogewicht auf Material
* >
*        CLEAR wa_mara.
*        SELECT SINGLE *
*          INTO  wa_mara
*          FROM  mara CLIENT SPECIFIED
*          WHERE mandt  = sy-mandt
*          AND   matnr  = vbdpr-matnr.
* <
* cjo Lesen Nettopreise
* >
        CLEAR wa_vbrp.
        SELECT SINGLE *
          FROM  vbrp CLIENT SPECIFIED
          INTO  wa_vbrp
          WHERE mandt  = sy-mandt
          AND   vbeln  = vbdkr-vbeln
          AND   posnr  = vbdpr-posnr.

* MILLERW001 02.02.2011 - Währungsbezugsfelder für KZWIx
        vbrk-waerk = vbdkr-waerk.

* <
* Roger Schneider / lesen des Verfalldatum
* >

* ---> Begin of Delete for D3_OTC_FDD_0067 by DMOIRAN
*


*        CLEAR zmch.
*        SELECT        * FROM  zmch
*               WHERE  matnr  = vbdpr-matnr
*               AND    charg  = vbdpr-charg.
*        ENDSELECT.
* <--- End    of Delete for D3_OTC_FDD_0067 by DMOIRAN
        CLEAR mch1.

        SELECT        * FROM  mch1
               WHERE  matnr  = vbdpr-matnr
               AND    charg  = vbdpr-charg.
        ENDSELECT.

* ---> Begin of Delete for D3_OTC_FDD_0067 by DMOIRAN
*
*        zmch-vfdat = mch1-vfdat.
*
*
**.......BEGIN - SAP4u / Olivier Petitjean 0797891851 15.12.02
*        CLEAR h_mhdat.
*        CALL FUNCTION 'Z_FORMAT_DATE'
*          EXPORTING
*            in_matnr = vbdpr-matnr
*            in_date  = zmch-vfdat
*          IMPORTING
*            out_date = h_mhdat.
**.......END - SAP4u / Olivier Petitjean 0797891851 15.12.02


*        wa_zmhdat-mhdat = zmch-vfdat.
* <--- End    of Delete for D3_OTC_FDD_0067 by DMOIRAN
** <
** cjo Lesen Verfallsdatum
** >
**       clear wa_zmhdat.
**       select single *
**         from  zmhdat client specified
**         into  wa_zmhdat
**         where mandt  = sy-mandt
**         and   charg  = vbdpr-charg.
** <
** cjo Formatieren Chargennummer
** >
* ---> Begin of Delete for D3_OTC_FDD_0067 by DMOIRAN
*        break ext_mbi.
*
**.......BEGIN - SAP4u / Olivier Petitjean 0797891851 15.12.02
*        CLEAR ch_charg.
*        CALL FUNCTION 'Z_GET_NEW_CHARGE'
*          EXPORTING
*            in_matnr       = vbdpr-matnr
*            in_chnr        = vbdpr-charg
*            in_format_mode = 'E'
*          IMPORTING
*            out_chnr       = ch_charg.

*.......END - SAP4u / Olivier Petitjean 0797891851 15.12.02

**        CALL FUNCTION 'Z_GET_FORMAT_CHARGE'              "SAP4u OPJ
**             EXPORTING                                   "SAP4u OPJ
**                  im_charg  = vbdpr-charg                "SAP4u OPJ
**             IMPORTING                                   "SAP4u OPJ
**                  ex_charg  = ch_charg                   "SAP4u OPJ
**             EXCEPTIONS                                  "SAP4u OPJ
**                  not_found = 1                          "SAP4u OPJ
**                  OTHERS    = 2.                         "SAP4u OPJ

* <--- End    of Delete for D3_OTC_FDD_0067 by DMOIRAN
        CLEAR eipo.
        SELECT        * FROM  eipo
               WHERE  exnum  = vbdkr-exnum
               AND    expos  = vbdpr-posnr.

        ENDSELECT.

        IF eipo-stawn EQ space.
          CLEAR marc.
          SELECT        * FROM  marc
                WHERE  matnr  = vbdpr-matnr
                AND    werks  = vbdpr-werks.
          ENDSELECT.
          eipo-stawn = marc-stawn.
          IF eipo-herkl EQ space.
            eipo-herkl = marc-herkl.
          ENDIF.
        ENDIF.

        IF vbdpr-matnr = 'ZZZZZZZ'.
          eipo-stawn = vbdpr-stawn.
        ENDIF.

        IF knvv-klabc NE space. CLEAR eipo-stawn. ENDIF.

        CLEAR fl_sernr.
        CLEAR ch_sernr.

        IF ch_charg EQ space.
          PERFORM get_item_serials.
          ch_sernr = ch_charg.
        ENDIF.
*
* Objektart lesen
*
        CLEAR equi.
        IF tkomser-sernr NE space.

          SELECT        * FROM  equi
                 WHERE  sernr  = tkomser-sernr.

          ENDSELECT.
        ENDIF.

        READ TABLE tkomser_print INDEX 1.

        IF vbdpr-pstyv EQ 'ZMUS'.

          SELECT        * FROM  lips
                 WHERE  vbeln  = vbdpr-vgbel
                 AND    uecha  = vbdpr-vgpos.

          ENDSELECT.

          IF sy-subrc EQ 0.

            vbdpr-fkimg = lips-lfimg.
            vbdpr-vrkme = lips-meins.

          ENDIF.

        ENDIF.
* ---> Begin of Delete for D3_OTC_FDD_0067 by DMOIRAN
*        CLEAR zmch.
*        SELECT        * FROM  zmch
*               WHERE  matnr  = vbdpr-matnr
*               AND    charg  = vbdpr-charg.
*        ENDSELECT.
*
*        CLEAR mch1.
*
*        SELECT        * FROM  mch1
*               WHERE  matnr  = vbdpr-matnr
*               AND    charg  = vbdpr-charg.
*        ENDSELECT.
*
*        zmch-vfdat = mch1-vfdat.
*
*        CLEAR h_mhdat.
*        CALL FUNCTION 'Z_FORMAT_DATE'
*          EXPORTING
*            in_matnr = vbdpr-matnr
*            in_date  = zmch-vfdat
*          IMPORTING
*            out_date = h_mhdat.
* <--- End    of Delete for D3_OTC_FDD_0067 by DMOIRAN

        IF vbdpr-fkimg = 0.

          vbdpr-fkimg = vbdpr-fklmg.

        ENDIF.

*       mbi0003-----------------------------------------------------
        CLEAR ch_charg_lif.
        SELECT        * FROM  lips
               WHERE  vbeln  = vbdpr-vgbel
               AND    uecha  = vbdpr-vgpos.


          CALL FUNCTION 'Z_GET_NEW_CHARGE'
            EXPORTING
              in_matnr       = vbdpr-matnr
              in_chnr        = lips-charg
              in_format_mode = 'E'
            IMPORTING
              out_chnr       = ch_charg_lif.
        ENDSELECT.
*       mbi0003-----------------------------------------------------


* INS rte0001
* ---> Begin of Delete for D3_OTC_FDD_0067 by DMOIRAN
*        SELECT SINGLE * FROM zsd_knmt
*          WHERE vkorg EQ vbdkr-vkorg
*          AND   vtweg EQ vbdkr-vtweg
*          AND   kunnr EQ vbdkr-kunwe.
*
*        IF sy-subrc EQ 0 AND NOT vbdpr-idnkd IS INITIAL.
*          MOVE vbdpr-idnkd TO vbdpr-matnr.
*        ENDIF.
* <--- End    of Delete for D3_OTC_FDD_0067 by DMOIRAN
* INS rte0001


        CALL FUNCTION 'CONTROL_FORM'
          EXPORTING
            command = 'PROTECT'.
* HFR20090813: Chargenmenge mit ausgeben
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'ITEM_LINE'.

        IF ch_charg EQ space.

          SELECT        * FROM  lips
                 WHERE  vbeln  = vbdpr-vgbel
                 AND    uecha  = vbdpr-vgpos.


            CALL FUNCTION 'Z_GET_NEW_CHARGE'
              EXPORTING
                in_matnr       = vbdpr-matnr
                in_chnr        = lips-charg
                in_format_mode = 'E'
              IMPORTING
                out_chnr       = ch_charg.
* ---> Begin of Delete for D3_OTC_FDD_0067 by DMOIRAN
*            CLEAR zmch.
*            SELECT        * FROM  zmch
*                   WHERE  matnr  = vbdpr-matnr
*                   AND    charg  = lips-charg.
*            ENDSELECT.
*
*            CLEAR mch1.
*
*            SELECT        * FROM  mch1
*                   WHERE  matnr  = vbdpr-matnr
*                   AND    charg  = lips-charg.
*            ENDSELECT.
*
*            zmch-vfdat = mch1-vfdat.
*
*            CLEAR h_mhdat.
*            CALL FUNCTION 'Z_FORMAT_DATE'
*              EXPORTING
*                in_matnr = vbdpr-matnr
*                in_date  = zmch-vfdat
*              IMPORTING
*                out_date = h_mhdat.
*
* <--- End    of Delete for D3_OTC_FDD_0067 by DMOIRAN
* HFR20090813: Ermitteln der Chargenmenge
            PERFORM chargenmenge_ermitteln USING vbdpr-vgbel vbdpr-vgpos mch1-charg CHANGING wa_char_menge.
* HFR20090813: Nur Charge ausgeben, wenn nicht Unterposition
* HFR20090827: Neu gilt dies nur für Proformarechnungen (Fakturaart: ZF5 / ZF6)
* ----> gemäss Tel von Marcel Bertxchy...... gleiche logik für alle
*            IF tvbdpr-uecha IS INITIAL OR ( vbdkr-fkart NE 'ZF5'  AND vbdkr-fkart NE 'ZF8' ).
* HFR20091019: Gemäss Mail von M.Bertschy --> Bei Splittpositionen keine Mengen aus geben
            wa_char_menge_zw = wa_char_menge.
            CLEAR wa_char_menge.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = 'ITEM_LINE_BATCH'
              EXCEPTIONS
                OTHERS  = 1.
            IF sy-subrc NE 0.
              PERFORM protocol_update.
            ENDIF.
            wa_char_menge = wa_char_menge_zw.
*            ENDIF.


          ENDSELECT.

        ELSE.

*       if tvbdpr-charg ne space.
*          CALL FUNCTION 'WRITE_FORM'
*            EXPORTING
*              ELEMENT = 'ITEM_LINE_BATCH'
*            EXCEPTIONS
*              OTHERS  = 1.
*          IF SY-SUBRC NE 0.
*            PERFORM PROTOCOL_UPDATE.
*          ENDIF.
        ENDIF.
*
* Serialproblematik /17.2.2004 Roger Schneider
*
        CLEAR tkomser_print-snrln.

        LOOP AT tkomser_print FROM 2.
          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = 'ITEM_SERIAL_PRINT'
            EXCEPTIONS
              element = 1
              window  = 2.
        ENDLOOP.
*        READ TABLE TKOMSER_PRINT INDEX 2.
*        IF SY-SUBRC EQ 0.
*          CALL FUNCTION 'WRITE_FORM'
*            EXPORTING
*              ELEMENT = 'ITEM_SERIAL_PRINT'
*            EXCEPTIONS
*              ELEMENT = 1
*              WINDOW  = 2.
*        ENDIF.
*        READ TABLE TKOMSER_PRINT INDEX 3.
*        IF SY-SUBRC EQ 0.
*          CALL FUNCTION 'WRITE_FORM'
*            EXPORTING
*              ELEMENT = 'ITEM_SERIAL_PRINT'
*            EXCEPTIONS
*              ELEMENT = 1
*              WINDOW  = 2.
*        ENDIF.
*        READ TABLE TKOMSER_PRINT INDEX 4.
*        IF SY-SUBRC EQ 0.
*          CALL FUNCTION 'WRITE_FORM'
*            EXPORTING
*              ELEMENT = 'ITEM_SERIAL_PRINT'
*            EXCEPTIONS
*              ELEMENT = 1
*              WINDOW  = 2.
*        ENDIF.
* End
        PERFORM item_price_print.
        PERFORM item_characteristics_print.
        PERFORM item_reference_billing.
        CALL FUNCTION 'CONTROL_FORM'
          EXPORTING
            command = 'ENDPROTECT'.
        PERFORM item_text_print.
        IF vbdkr-vkorg NE'9010' OR wa_perfk IS INITIAL.
          PERFORM different_consignee.
        ENDIF.
        PERFORM different_order_no.
        PERFORM different_delivery_no.
        PERFORM different_extern_no.
        PERFORM different_purchase_order_no.
        PERFORM different_reference_no.
      ELSE.
        IF NOT tvbdpr-fkimg IS INITIAL.
          PERFORM get_item_prices.
* HFR20090813: Chargenmenge mit ausgeben
          PERFORM chargenmenge_ermitteln USING vbdpr-vgbel vbdpr-vgpos mch1-charg CHANGING wa_char_menge.
* HFR20090813: Nur Charge ausgeben, wenn nicht Unterposition
* HFR20090827: Neu gilt dies nur für Proformarechnungen (Fakturaart: ZF5 / ZF6)
* ----> gemäss Tel von Marcel Bertxchy...... gleiche logik für alle
*          IF tvbdpr-uecha IS INITIAL OR ( vbdkr-fkart NE 'ZF5'  AND vbdkr-fkart NE 'ZF8' ).
* HFR20091019: Gemäss Mail von M.Bertschy --> Bei Splittpositionen keine Mengen aus geben
          wa_char_menge_zw = wa_char_menge.
          CLEAR wa_char_menge.
          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = 'ITEM_LINE_BATCH'
            EXCEPTIONS
              OTHERS  = 1.
          IF sy-subrc NE 0.
            PERFORM protocol_update.
          ENDIF.
*          ENDIF.
          wa_char_menge = wa_char_menge_zw.
          PERFORM item_price_print.
        ENDIF.
      ENDIF.
*   IF NOT VBDPR-PREFE IS INITIAL.
*     CALL FUNCTION 'WRITE_FORM'
*          EXPORTING
*               ELEMENT = 'PREFERENCE_TEXT'
*          EXCEPTIONS
*               OTHERS  = 1.
*     IF SY-SUBRC NE 0.
*       PERFORM PROTOCOL_UPDATE.
*     ENDIF.
*   ENDIF.
    ENDIF.
  ENDLOOP.
  IF wa_tot_we = 'J'.
    IF wa_kunwe IS INITIAL.
      wa_kunwe_p = vbdkr-kunwe.
    ELSE.
      wa_kunwe_p = wa_kunwe.
    ENDIF.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'ITEM_TOT_WE'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'WRITE_FORM'           "Deactivate Header
       EXPORTING  element  = 'ITEM_HEADER'
                  function = 'DELETE'
                  type     = 'TOP'
       EXCEPTIONS OTHERS   = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "ITEM_PRINT
*
* cjo auslesen Serialnummer
*
FORM get_item_serials.

  CLEAR ch_sernr.
* Read the Serialnumbers of a Position.
  REFRESH tkomser.

  h_vbeln-vauf = vbdkr-vbeln_vauf.

  IF vbdpr-vbeln_vl EQ space.

    vbdpr-posnr_vl = vbdpr-vgpos.
    vbdpr-vbeln_vl = vbdpr-vgbel.
  ENDIF.

  CALL FUNCTION 'SERIAL_LS_PRINT'
    EXPORTING
      posnr  = vbdpr-posnr_vl
      vbeln  = vbdpr-vbeln_vl
    TABLES
      iserls = tkomser.
*
* cjo Serialnr. Ja/Nein und abfüllen
* >
  DATA: in_sernr TYPE i.
  CLEAR fl_sernr.
  DESCRIBE TABLE tkomser LINES in_sernr.
  IF in_sernr > 0.
    fl_sernr = 'X'.
    READ TABLE tkomser INDEX 1.
    MOVE tkomser-sernr TO ch_sernr.
    SHIFT ch_sernr LEFT DELETING LEADING '0'.
  ELSE.
    IF vbdpr-vbeln_vl NE space.
      vbdpr-posnr_vauf = vbdpr-posnr_vl.
      vbdkr-vbeln_vauf = vbdpr-vbeln_vl.
    ENDIF.
    CALL FUNCTION 'SERIAL_WV_PRINT'
      EXPORTING
        posnr  = vbdpr-posnr_vauf
        vbeln  = vbdkr-vbeln_vauf
      TABLES
        isernr = tkomser.
*
* cjo Serialnr. Ja/Nein und abfüllen
* >
* data: in_sernr type i.
    CLEAR fl_sernr.
    DESCRIBE TABLE tkomser LINES in_sernr.
    IF in_sernr > 0.
      fl_sernr = 'X'.
      READ TABLE tkomser INDEX 1.
      MOVE tkomser-sernr TO ch_sernr.
      SHIFT ch_sernr LEFT DELETING LEADING '0'.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'PROCESS_SERIALS_FOR_PRINT'
    EXPORTING
      i_boundary_left             = '(_'
      i_boundary_right            = '_)'
      i_sep_char_strings          = ',_'
      i_sep_char_interval         = '_-_'
      i_use_interval              = 'X'
      i_boundary_method           = 'C'
      i_line_length               = 50
      i_no_zero                   = 'X'
      i_alphabet                  = sy-abcde
      i_digits                    = '0123456789'
      i_special_chars             = '-'
      i_with_second_digit         = ' '
    TABLES
      serials                     = tkomser
      serials_print               = tkomser_print
    EXCEPTIONS
      boundary_missing            = 01
      interval_separation_missing = 02
      length_to_small             = 03
      internal_error              = 04
      wrong_method                = 05
      wrong_serial                = 06
      two_equal_serials           = 07
      serial_with_wrong_char      = 08
      serial_separation_missing   = 09.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.
  ch_charg = ch_sernr.
  vbdkr-vbeln_vauf = h_vbeln-vauf.
* <
ENDFORM.                               " GET_ITEM_SERIALS

*---------------------------------------------------------------------*
*       FORM ITEM_TEXT_PRINT                                          *
*---------------------------------------------------------------------*
*       Printout of the item texts                                    *
*---------------------------------------------------------------------*

FORM item_text_print.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_TEXT'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                    "ITEM_TEXT_PRINT

*---------------------------------------------------------------------*
*       FORM PROTOCOL_UPDATE                                          *
*---------------------------------------------------------------------*
*       The messages are collected for the processing protocol.       *
*---------------------------------------------------------------------*

FORM protocol_update.

  CHECK xscreen = space.
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = syst-msgid
      msg_nr    = syst-msgno
      msg_ty    = syst-msgty
      msg_v1    = syst-msgv1
      msg_v2    = syst-msgv2
      msg_v3    = syst-msgv3
      msg_v4    = syst-msgv4
    EXCEPTIONS
      OTHERS    = 1.

ENDFORM.                    "PROTOCOL_UPDATE
*---------------------------------------------------------------------*
*       FORM SENDER                                                   *
*---------------------------------------------------------------------*
*       This routine determines the address of the sender (Table VKO) *
*---------------------------------------------------------------------*

FORM sender.

  SELECT SINGLE * FROM tvko  WHERE vkorg = vbdkr-vkorg.
  IF sy-subrc NE 0.
    syst-msgid = 'VN'.
    syst-msgno = '203'.
    syst-msgty = 'E'.
    syst-msgv1 = 'TVKO'.
    syst-msgv2 = syst-subrc.
    PERFORM protocol_update.
    EXIT.
  ENDIF.
  CLEAR gv_fb_addr_get_selection.
  gv_fb_addr_get_selection-addrnumber = tvko-adrnr.
  CALL FUNCTION 'ADDR_GET'
    EXPORTING
      address_selection = gv_fb_addr_get_selection
      address_group     = 'CA01'
    IMPORTING
      sadr              = sadr
    EXCEPTIONS
      OTHERS            = 01.                               "SADR40A
  IF sy-subrc NE 0.
    CLEAR sadr.
  ENDIF.

  vbdkr-sland = sadr-land1.
  IF sy-subrc NE 0.
    syst-msgid = 'VN'.
    syst-msgno = '203'.
    syst-msgty = 'E'.
    syst-msgv1 = 'SADR'.
    syst-msgv2 = syst-subrc.
    PERFORM protocol_update.
  ENDIF.

* Interne Verrechnung: Adresse des Buchungskreises lesen
  IF vbdkr-vbtyp CA '56'.
    CLEAR t001g.
    SELECT SINGLE * FROM t001g WHERE bukrs = vbdkr-bukrs
                                 AND programm EQ sy-repid
                                 AND txtid EQ 'SD'.
  ENDIF.

ENDFORM.                    "SENDER

*&---------------------------------------------------------------------*
*&      Form  HEADER_CONSGNEE
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header_consgnee.
  IF vbdkr-kunwe NE vbdkr-kunre.
    IF vbdkr-vkorg NE '9050'.


      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'HEADER_CONSGNEE'
          window  = 'CONSGNEE'
        EXCEPTIONS
          element = 1
          window  = 2.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'HEADER_CONSGNEE'
          window  = 'INFO1'
        EXCEPTIONS
          element = 1
          window  = 2.

    ELSE.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'HEADER_CONSGNEE'
          window  = 'CONSGNEE'
        EXCEPTIONS
          element = 1
          window  = 2.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'HEADER_CONSGNEE'
          window  = 'INF19050'
        EXCEPTIONS
          element = 1
          window  = 2.
    ENDIF.
  ENDIF.

ENDFORM.                               " HEADER_CONSGNEE
*&---------------------------------------------------------------------*
*&      Form  DIFFERENT_REFERENCE_NO
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM different_reference_no.

  CHECK vbdkr-vbtyp CA 'OP'.
  CHECK vbdkr-vbeln_vg2 NE vbdpr-vbeln_vg2.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_REFERENCE_NO'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                               " DIFFERENT_REFERENCE_NO
*&---------------------------------------------------------------------*
*&      Form  HEADER_DATA_PRINT
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header_data_print.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'HEADER_DATA'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                               " HEADER_DATA_PRINT
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_ESR
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_esr.

*   mbi0012---------------------------------------------------------------
  DATA :  wa_bankn TYPE tiban-bankn.
*   mbi0012---------------------------------------------------------------

  CALL FUNCTION 'SD_ESR_GET_DATA'
    EXPORTING
      vbdkr_bukrs                   = vbdkr-bukrs
      vbdkr_vkorg                   = vbdkr-vkorg
      komk_fkwrt                    = komk-fkwrt
      vbdkr_vbeln                   = vbdkr-vbeln
      vbdkr_kunrg                   = vbdkr-kunrg
      vbdkr_waerk                   = vbdkr-waerk
    CHANGING
      ivbdre                        = vbdre
    EXCEPTIONS
      t049e_no_entry                = 1
      t001_no_entry                 = 2
      bnka_no_entry                 = 3
      sadr_no_entry                 = 4
      fkwrt_not_valid               = 5
      esr_digits_to_check_not_valid = 6
      esr_check_method_not_valid    = 7
      OTHERS                        = 8.

  IF sy-subrc NE 0.
    retcode = sy-subrc.
    PERFORM protocol_update.
  ELSE.
*   mbi0011---------------------------------------------------------------
    CLEAR wl_tiban.
*   mbi0012---------------------------------------------------------------
    WRITE vbdre-kunid TO wa_bankn NO-ZERO.
    CONDENSE wa_bankn.
*   mbi0012---------------------------------------------------------------
    SELECT SINGLE * FROM tiban INTO wl_tiban
                  WHERE banks EQ vbdre-bland AND
                        bankl EQ vbdre-bankl AND
                        bankn EQ wa_bankn .
    MOVE wl_tiban-iban+4(5) TO wa_iban_bc.
*   mbi0011---------------------------------------------------------------
  ENDIF.
ENDFORM.                               " GET_DATA_ESR

*----------------------------------------------------------------------*
*       Form  GET_DATA_ITALY
*----------------------------------------------------------------------*
*                                                                      *
*----------------------------------------------------------------------*
*
*
*----------------------------------------------------------------------*
FORM get_data_italy USING proc_screen.

  CLEAR konh.
  CLEAR tlic.
  LOOP AT tkomv WHERE koaid = 'D'
                AND   kntyp ='+'.
    SELECT SINGLE * FROM konh WHERE knumh = tkomv-knumh.
    IF sy-subrc EQ 0.
      IF NOT konh-licno IS INITIAL AND NOT konh-licdt IS INITIAL.
        SELECT SINGLE * FROM tlic WHERE licno  = konh-licno
                                  AND   kunnr  = vbdkr-kunag.
        IF sy-subrc NE 0.
* Alte TLIC-Sätze haben KUNNR initial. Alter Satz vorhanden ?
          DATA: da_kunnr_initial LIKE vbdkr-kunag.
          CLEAR da_kunnr_initial.
          SELECT SINGLE * FROM tlic WHERE licno = konh-licno
                                    AND   kunnr = da_kunnr_initial.
        ENDIF.
        IF sy-subrc EQ 0.
          IF NOT tlic-prnum_nr IS INITIAL AND
             NOT tlic-prnum_dt IS INITIAL.
            MOVE:
              konh-licno TO vbdkr-licno,
              konh-licdt TO vbdkr-licdt.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    IF vbdkr-licno     IS INITIAL OR
       vbdkr-licdt     IS INITIAL OR
       tlic-prnum_nr   IS INITIAL OR
       tlic-prnum_dt   IS INITIAL.
      IF proc_screen = space.
        retcode = 3.
        syst-msgno = '205'.
        syst-msgid = 'VN'.
        syst-msgty = 'I'.
        PERFORM protocol_update.
      ELSE.
        MESSAGE i205.
      ENDIF.
    ENDIF.
    EXIT.
  ENDLOOP.



ENDFORM.                               " get_data_italy

*&---------------------------------------------------------------------*
*&      Form  START_FORM
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM start_form.

  DATA : startseite(8) VALUE 'NEXTBSR'.
  DATA : sprache LIKE sy-langu.

  IF vbdre-verfa = '04' OR vbdre-verfa = '08'.

    CALL FUNCTION 'START_FORM'
      EXPORTING
        startpage = startseite
      IMPORTING
        language  = sprache
      EXCEPTIONS
        form      = 1
        format    = 2
        unended   = 3
        unopened  = 4
        unused    = 5
        OTHERS    = 6.
    IF sy-subrc NE 0.
      retcode = sy-subrc.
      PERFORM protocol_update.
    ENDIF.

  ENDIF.

ENDFORM.                               " START_OPEN
*&---------------------------------------------------------------------*
*&      Form  TAX_TEXT_PRINT
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM tax_text_print.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'TAX_TEXT'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                               " TAX_TEXT_PRINT

***********************************************************************
*                SUBROUTINES OF ENTRY_CH                              *
***********************************************************************

FORM header_ch.
  CLEAR print_local_curr_ch.
* Hauswährung <> Belegwährung ?
  SELECT SINGLE * FROM t001 WHERE bukrs EQ vbdkr-bukrs.
  CHECK sy-subrc = 0.
  CHECK t001-waers <> vbdkr-waerk.
  MOVE 'X' TO print_local_curr_ch.
  REFRESH komvdk_ch.
  LOOP AT hkomvd WHERE koaid = 'D'.
    CLEAR komvdk_ch.
    CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
      EXPORTING
        date             = vbdkr-fkdat
        foreign_amount   = hkomvd-kwert
        foreign_currency = vbdkr-waerk
        local_currency   = t001-waers
        rate             = vbdkr-kurrf
      IMPORTING
        local_amount     = komvdk_ch-kwert
      EXCEPTIONS
        no_rate_found    = 1
        overflow         = 2
        no_factors_found = 3
        no_spread_found  = 4
        OTHERS           = 5.
    CHECK sy-subrc = 0.
    MOVE: t001-waers TO komvdk_ch-awein,
          t001-waers TO komvdk_ch-awei1,
          hkomvd-vtext TO komvdk_ch-vtext,
          vbdkr-kurrf TO hkomvd-kkurs.
    APPEND komvdk_ch.
  ENDLOOP.
ENDFORM.                    "HEADER_CH

*---------------------------------------------------------------------*
*       FORM ITEM_CH                                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM item_ch.
  CHECK print_local_curr_ch EQ 'X'.
  REFRESH komvdp_ch.
* Suche die Steuerkonditionen der Position und rechne Hauswährung aus.
  LOOP AT tkomvd WHERE koaid = 'D'.
    CLEAR komvdp_ch.
    CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
      EXPORTING
        date             = vbdkr-fkdat
        foreign_amount   = tkomvd-kwert
        foreign_currency = vbdkr-waerk
        local_currency   = t001-waers
        rate             = vbdkr-kurrf
      IMPORTING
        local_amount     = komvdp_ch-kwert
      EXCEPTIONS
        no_rate_found    = 1
        overflow         = 2
        no_factors_found = 3
        no_spread_found  = 4
        OTHERS           = 5.
    CHECK sy-subrc = 0.
    MOVE: t001-waers TO komvdp_ch-awein,
          t001-waers TO komvdp_ch-awei1,
          tkomvd-vtext TO komvdp_ch-vtext,
          vbdkr-kurrf TO komvdp_ch-kkurs.
    APPEND komvdp_ch.
  ENDLOOP.
ENDFORM.                    "ITEM_CH

*---------------------------------------------------------------------*
*       FORM ITEM_PRINT_CH                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM item_print_ch.
  DATA: save_waerk_fw LIKE komk-waerk.
  save_waerk_fw = komk-waerk.
  LOOP AT komvdp_ch.
    komvd = komvdp_ch.
    komk-waerk = komvd-awein.
    IF print_mwskz EQ space.
      CLEAR komvd-mwskz.
    ENDIF.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'ITEM_LINE_TAX_HAUSWAEHRUNG'.
  ENDLOOP.
  komk-waerk = save_waerk_fw.
ENDFORM.                    "ITEM_PRINT_CH

*---------------------------------------------------------------------*
*       FORM HEADER_PRINT_CH                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM header_print_ch.
  DATA: save_waerk_fw LIKE komk-waerk.
  save_waerk_fw = komk-waerk.
  LOOP AT komvdk_ch.
    komvd = komvdk_ch.
    komk-waerk = komvd-awein.
    IF print_mwskz = space.
      CLEAR komvd-mwskz.
    ENDIF.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'SUM_LINE_TAX_HAUSWAEHRUNG'.
  ENDLOOP.
  komk-waerk = save_waerk_fw.
ENDFORM.                    "HEADER_PRINT_CH








***********************************************************************
*       CUSTOMER SUBROUTINES                                          *
***********************************************************************
*&---------------------------------------------------------------------*
*&      Form  ITEM_BILLING_CORRECTION_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DA_GANF  text                                              *
*      -->P_DA_LANF  text                                              *
*----------------------------------------------------------------------*
FORM item_billing_correction_header USING    us_ganf
                                             us_lanf.

  CHECK : vbdkr-knuma IS INITIAL.
  IF vbdpr-autyp = 'K'.
*   Gutschriftsanforderung
    IF vbdpr-shkzg = 'X'.
      IF us_ganf IS INITIAL.
        MOVE 'X'   TO us_ganf.
        MOVE space TO us_lanf.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'CORRECTION_TEXT_K'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ENDIF.
    ELSE.
      IF us_lanf IS INITIAL.
        MOVE 'X'   TO us_lanf.
        MOVE space TO us_ganf.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'CORRECTION_TEXT_L'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF vbdpr-autyp = 'L'.
*   Lastschriftsanforderung
    IF vbdpr-shkzg = space.
      IF us_lanf IS INITIAL.
        MOVE 'X'   TO us_lanf.
        MOVE space TO us_ganf.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'CORRECTION_TEXT_L'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ENDIF.
    ELSE.
      IF us_ganf IS INITIAL.
        MOVE 'X'   TO us_ganf.
        MOVE space TO us_lanf.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'CORRECTION_TEXT_K'
          EXCEPTIONS
            element = 1
            window  = 2.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                               " ITEM_BILLING_CORRECTION_HEADER
*&---------------------------------------------------------------------*
*&      Form  ITEM_REFERENCE_BILLING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM item_reference_billing.

  CHECK vbdpr-vbklt EQ 'D'.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_REFERENCE_BILLING'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                               " ITEM_REFERENCE_BILLING
*&---------------------------------------------------------------------*
*&      Form  DOWNPAYMENT_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM downpayment_value.
* ---> Begin of Delete for D3_OTC_FDD_0067 by DMOIRAN
*

*
*  CALL FUNCTION 'WRITE_FORM'
*    EXPORTING
*      element = 'DOWNPAYMENT_VALUE'
*    EXCEPTIONS
*      element = 1
*      window  = 2.
*  IF sy-subrc NE 0.
*    PERFORM protocol_update.
*  ENDIF.
* <--- End    of Delete for D3_OTC_FDD_0067 by DMOIRAN
ENDFORM.                               " DOWNPAYMENT_INFO

*&---------------------------------------------------------------------*
*&      Form  PAYMENTCARD_VALUES
*&---------------------------------------------------------------------*
*       Print Payment Cards
*----------------------------------------------------------------------*
*  -->  VBDKR Header
*----------------------------------------------------------------------*
FORM paymentcard_values.

  DATA: da_xfplt LIKE fpltvb OCCURS 2 WITH HEADER LINE. " Cards

  IF NOT vbdkr-rplnr IS INITIAL.
* Read from the Database
    CALL FUNCTION 'BILLING_SCHEDULE_READ'
      EXPORTING
        fplnr         = vbdkr-rplnr
      TABLES
        zfplt         = da_xfplt
      EXCEPTIONS
        error_message = 0
        OTHERS        = 0.
* Loop at Cards
    LOOP AT da_xfplt.
      MOVE-CORRESPONDING da_xfplt TO fpltvb.
* Get text
      IF da_xfplt-ccins NE tvcint-ccins.
        SELECT SINGLE * FROM tvcint
               WHERE spras = vbco3-spras
               AND   ccins = da_xfplt-ccins.
        IF sy-subrc =  0.
          ccname = tvcint-vtext.
        ELSE.
          ccname = da_xfplt-ccins.
        ENDIF.
      ENDIF.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'PAYMENTCARDS'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
      ADD da_xfplt-fakwr TO vbdkr-ccval.
    ENDLOOP.
    IF da_xfplt-fakwr NE vbdkr-ccval.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'PAYMENTCARD_SUM'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                               " PAYMENTCARD_VALUES
*---------------------------------------------------------------------*
*       FORM PROTOCOL_UPDATE_SPOOL                                    *
*---------------------------------------------------------------------*
*       The messages are collected for the processing protocol.       *
*---------------------------------------------------------------------*

FORM protocol_update_spool USING syst-msgno h_i_itcpp-tdspoolid
                                 syst-msgv2 syst-msgv3 syst-msgv4.
  syst-msgid = 'VN'.
  syst-msgv1 = h_i_itcpp-tdspoolid.
  CONDENSE syst-msgv1.
  CHECK xscreen = space.
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = syst-msgid
      msg_nr    = syst-msgno
      msg_ty    = syst-msgty
      msg_v1    = syst-msgv1
      msg_v2    = syst-msgv2
      msg_v3    = syst-msgv3
      msg_v4    = syst-msgv4
    EXCEPTIONS
      OTHERS    = 1.

ENDFORM.                    "PROTOCOL_UPDATE_SPOOL
*&---------------------------------------------------------------------*
*&      Form  FAKTURA_PLAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM faktura_plan .

  READ TABLE tvbdpr.
  IF sy-subrc = 0.
    SELECT SINGLE auart FROM vbak INTO wa_auart
        WHERE vbeln = tvbdpr-vbeln_vauf.
    IF sy-subrc = 0 AND wa_auart = 'ZTAF'. " Fakturaplan?
* Aktrueller Fakturaplan lesen!
      CLEAR wa_fplnr_aktuel.
      SELECT SINGLE fplnr fpltr FROM  vbfa INTO wa_fplnr_aktuel
             WHERE  vbelv  = tvbdpr-vbeln_vauf
             AND    vbeln  = vbdkr-vbeln.
      IF sy-subrc EQ 0 AND wa_fplnr_aktuel-fplnr IS NOT INITIAL.
        REFRESH it_fplnr.
        SELECT fplnr fpltr FROM  fplt INTO TABLE it_fplnr
               WHERE  fplnr  = wa_fplnr_aktuel-fplnr.
        IF sy-subrc NE 0.
          CLEAR wa_auart.
        ELSE.
          DESCRIBE TABLE it_fplnr LINES z_fplnr.
          IF z_fplnr < 100.
            z_tot = z_fplnr.
          ELSE.
            z_tot = 99.
          ENDIF.
          z_von = 0.
          LOOP AT it_fplnr INTO wa_fplnr WHERE fpltr LE wa_fplnr_aktuel-fpltr.
            ADD 1 TO z_von.
          ENDLOOP.
          IF z_von > 0.
            vbdkr-vbtyp = '&'. " Fakruraplan für Druck
          ENDIF.
        ENDIF.
      ELSE.
        CLEAR wa_auart.
      ENDIF.



    ENDIF.

  ENDIF.
ENDFORM.                    " FAKTURA_PLA
*&---------------------------------------------------------------------*
*&      Form  FAKTURA_PLAN_POS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM faktura_plan_pos .
  DATA :   if_top_text TYPE TABLE OF vtopis.
  DATA :   wa_top_text TYPE vtopis.

* Aktrueller Fakturaplan lesen!
  CLEAR wa_fplnr_aktuel.
  SELECT SINGLE fplnr fpltr FROM  vbfa INTO wa_fplnr_aktuel
         WHERE  vbelv  = tvbdpr-vbeln_vauf
         AND    vbeln  = vbdkr-vbeln
         AND    posnn  = vbdpr-posnr.
  IF sy-subrc EQ 0 AND wa_fplnr_aktuel-fplnr IS NOT INITIAL.
    REFRESH it_fplnr.
    SELECT fplnr fpltr fproz fakwr waers fkdat FROM  fplt INTO TABLE it_fplnr
           WHERE  fplnr  = wa_fplnr_aktuel-fplnr.
    LOOP AT it_fplnr INTO wa_fplnr.
      AT FIRST.
        wa_tr = 'J'.
      ENDAT.
      DO 2 TIMES.
        CALL FUNCTION 'SD_PRINT_TERMS_OF_PAYMENT'
          EXPORTING
*         BLDAT                              = 00000000
*         BUDAT                              = 00000000
*         CPUDT                              = 00000000
            language                           = vbdkr-spras
            terms_of_payment                   = wa_fplnr-zterm
*         COUNTRY                            = ' '
*         HOLDBACK                           = ' '
*         TOP_HOLDBACK_INFO                  =
*         DOCUMENT_CURRENCY                  = ' '
*       IMPORTING
*         BASELINE_DATE                      =
*         PAYMENT_SPLIT                      =
*         ZFBDT                              =
          TABLES
            top_text                           = if_top_text
        EXCEPTIONS
           terms_of_payment_not_in_t052       = 1
           OTHERS                             = 2
                  .
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ELSE.
          READ TABLE if_top_text INTO wa_top_text INDEX 1.
          IF sy-subrc = 0.
            wa_zterm_fpl = wa_top_text-line.
          ENDIF.
        ENDIF.
        IF wa_zterm_fpl IS NOT INITIAL.
          CONDENSE wa_zterm_fpl.
          EXIT.
        ELSE.
          wa_fplnr-zterm = vbdkr-zterm.
        ENDIF.
      ENDDO.
      IF wa_fplnr-fproz > 0.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element                  = 'ITEM_LINE_FAKTURAPLAN_PROZ'
          EXCEPTIONS
            element                  = 1
            function                 = 2
            type                     = 3
            unopened                 = 4
            unstarted                = 5
            window                   = 6
            bad_pageformat_for_print = 7
            spool_error              = 8
            codepage                 = 9
            OTHERS                   = 10.
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
      ELSE.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element                  = 'ITEM_LINE_FAKTURAPLAN'
          EXCEPTIONS
            element                  = 1
            function                 = 2
            type                     = 3
            unopened                 = 4
            unstarted                = 5
            window                   = 6
            bad_pageformat_for_print = 7
            spool_error              = 8
            codepage                 = 9
            OTHERS                   = 10.
      ENDIF.

      wa_tr = 'N'.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " FAKTURA_PLAN_POS
*&---------------------------------------------------------------------*
*&      Form  CHARGENMENGE_ERMITTELN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_VBELN  text
*      -->P_VBDPR_VGBEL  text
*      -->P_VBDPR_VGPOS  text
*      -->P_MCH1_CHARG  text
*----------------------------------------------------------------------*
FORM chargenmenge_ermitteln  USING    p_lif_num
                                      p_lif_pos
                                      p_mch1_charg
                             CHANGING p_menge.
  DATA: wa_liefpos TYPE lips.

  SELECT        * FROM  lips INTO wa_liefpos
         WHERE  vbeln  = p_lif_num
         AND    uecha  = p_lif_pos.
    IF wa_liefpos-charg = p_mch1_charg.
      WRITE: wa_liefpos-lfimg TO p_menge.
      SHIFT p_menge RIGHT DELETING TRAILING space.
      DO 4 TIMES.

        IF p_menge+19(01) CN '0,.' OR p_menge NA '.,'.
          EXIT.
        ELSE.
          SHIFT p_menge RIGHT BY 1 PLACES.
        ENDIF.
      ENDDO.
      CONDENSE p_menge NO-GAPS.
      CONCATENATE p_menge wa_liefpos-vrkme INTO p_menge SEPARATED BY ' '.
      EXIT.
    ENDIF.

  ENDSELECT.


ENDFORM.                    " CHARGENMENGE_ERMITTEL


*mbi0013---------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  get_contact_data_3000
*&---------------------------------------------------------------------*
*       Get Auftragserfasser INfo
*----------------------------------------------------------------------*
*      -->WP_ERNAM : Auftragerfasser
*----------------------------------------------------------------------*
FORM get_contact_data_3000 USING wp_ernam TYPE ernam.


* Local data definition-------------------------------------------------
  DATA : wa_dlidata     TYPE sodlidati1,
         wt_entries_dli TYPE TABLE OF sodlienti1,
         wl_entries_dli TYPE sodlienti1,
         wl_usr21       TYPE usr21.


  CLEAR wl_usr21.
  SELECT SINGLE * FROM  usr21 INTO wl_usr21 WHERE bname EQ wp_ernam.
  IF sy-subrc EQ 0.
    SELECT * FROM adr2
      WHERE  persnumber  = wl_usr21-persnumber.
    ENDSELECT.
  ENDIF.
  MOVE adr2-tel_number TO wa_tel_nr.

  CALL FUNCTION 'SO_DLI_READ_API1'
    EXPORTING
      dli_name                   = '3000_CC'
      dli_id                     = '3000_CC'
      shared_dli                 = 'X'
    IMPORTING
      dli_data                   = wa_dlidata
    TABLES
      dli_entries                = wt_entries_dli[]
    EXCEPTIONS
      dli_not_exist              = 1
      operation_no_authorization = 2
      parameter_error            = 3
      x_error                    = 4
      OTHERS                     = 5.

  IF sy-subrc EQ 0.
    READ TABLE wt_entries_dli INTO wl_entries_dli WITH KEY member_nam = wp_ernam.
    IF sy-subrc EQ 0.
      MOVE : wa_dlidata-obj_descr     TO wa_mail_list,
             wl_entries_dli-full_name TO wa_name.
      EXIT.
    ENDIF.
  ENDIF.

  REFRESH wt_entries_dli[].
  CLEAR wa_dlidata.

  CALL FUNCTION 'SO_DLI_READ_API1'
    EXPORTING
      dli_name                   = '3000_CS'
      dli_id                     = '3000_CS'
      shared_dli                 = 'X'
    IMPORTING
      dli_data                   = wa_dlidata
    TABLES
      dli_entries                = wt_entries_dli[]
    EXCEPTIONS
      dli_not_exist              = 1
      operation_no_authorization = 2
      parameter_error            = 3
      x_error                    = 4
      OTHERS                     = 5.
  IF sy-subrc EQ 0.
    READ TABLE wt_entries_dli INTO wl_entries_dli WITH KEY member_nam = wp_ernam.
    IF sy-subrc EQ 0.
      MOVE : wa_dlidata-obj_descr TO wa_mail_list,
             wl_entries_dli-full_name TO wa_name.
    ENDIF.
  ENDIF.
ENDFORM.                    "get_contact_data_3000
*mbi0013---------------------------------------------------------------
