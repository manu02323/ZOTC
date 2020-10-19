***INCLUDE ZOTCN0013O_RFKORI16PDF.

************************************************************************
* INCLUDE    :  ZOTCN0013O_RFKORI16PDF                                 *
* TITLE      :  Copy of Standard Program RFKORI16PDF                   *
* DEVELOPER  :  Vivek Gaur                                             *
* OBJECT TYPE:  Include Progarm                                        *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   OTC_FDD_0013_Monthly Open AR Statement                  *
*----------------------------------------------------------------------*
* DESCRIPTION: This include is copied from standard include RFKORI16PDF*
*              necessary modifications are made for PDF form generation*
*              and Print or Mail/Fax to customer                       *
*              The changes in the code are tagged with the TR number   *
*              E1DK901190                                              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 15-May-2012 VGAUR    E1DK901190 Initial Development                  *
************************************************************************
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 11-Apr-2012 AMANGAL  E1DK909861 Send email only during background    *
*                                 processing. CR 357-Defect # 3453     *
*======================================================================*
*                                                                      *
* WRICEF ID:   D2_OTC_FDD_0013_Monthly Open AR Statement               *
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 19-Nov-2014 NSAXENA  E2DK906565 D2 Changes - Replacing Remit to      *
*                                 address with standard text address in*
*                                 case of spanish language.            *
* 31-Dec-2014 KBANSAL  E2DK906565 D2 Changes - French and English      *
*                                 labels need to be printed when Canada*
*                                 customers login                      *
*26-March-2015 KBANSAL E2DK906565 Defect# 4271- Maintain standard text  *
*                                 for Company Code-1020(Both English and*
*                                 French Text Displayed1103(only Spanish*
*                                 Text) displayed.                      *
*02-April-2015 NBAIS  E2DK906565 Defect# 4271(2nd change)-              *
*                                Change the Translation                 *
*                                for Canada and Mexico                  *
*                                date format for Mexico.                *
*************************************************************************
* 21-Sep-2016  NALI    E1DK921941 D3_OTC_FDD_0013 - D3 changes - Send   *
*                                 Houe Bank Info to the form output,    *
*                                 replace the remit to address with the *
*                                 organisation address for D3           *
*************************************************************************
* 03-Jan-2017  SGHOSH  E1DK921941 CR#301: Changes done in the FM call of*
*                                 ZOTC_GET_HOUSEBANKINFO to accomodate  *
*                                 multiple address records. Also the    *
*                                 table returned is passed during form  *
*                                 call.                                 *
*************************************************************************
* 20-Feb-2017  U034087 E1DK925882 CR#356 : D3_OTC_FDD_0013
*                                 Changes done in format of Bank Address
*                                 printing.
*                                 1. IBAN - Divided in 4 sets
*                                    XXXX XXXX XXXX XX
*                                 2. Print Address and City from Standard
*                                    Text if Company Code 2001,2002 and
*                                    2003.
*                                 3. Clearing Text added in the form
*************************************************************************

*-------Includes für syntax-check---------------------------------------
*NCLUDE RFKORI00.
*NCLUDE RFKORI80.
*NCLUDE RFKORI90.
*************************************************************************
* 04-Apr-2017  DMOIRAN E1DK926553 Defect#2379: Labels are not getting
*                                 displayed for D1/D2 company code.


*=======================================================================
*       Interne Perform-Routinen
*=======================================================================

*-----------------------------------------------------------------------
*       FORM AUSGABE_CUSTOMER_STAT_PDF
*-----------------------------------------------------------------------
FORM ausgabe_customer_stat_pdf.
  DATA:
       ls_header   TYPE rfkord_s_header,   " Header Structure for RFKORD* Programs
       ls_address  TYPE rfkord_s_address,  " Address Structure for RFKORD* Correspondence
       ls_item     TYPE rfkord_s_item,     " Item Structure for RFKORD* Correspondence
       ls_sum      TYPE rfkord_s_sum,      " Totals Structure (Balances) for RFKORD* Correspondence
       ls_rtab     TYPE rfkord_s_rtab,     " Structure for Sorted List Information (RFKORD* Correspond.)
       ls_item_alw TYPE rfkord_s_item_alw, " Structure for Old Amounts as Part of Currency Translation

       lt_address  TYPE rfkord_t_address,
       lt_item     TYPE rfkord_t_item,
       lt_sum      TYPE rfkord_t_sum,
       lt_rtab     TYPE rfkord_t_rtab,
       lt_paymo    TYPE rfkord_t_paymo.

  DATA:
       ls_adrs       TYPE adrs,         " Address formating function module transfer structure
       ls_adrs_print TYPE adrs_print,   " Formatted address (maximum 10 lines)
       fp_docparams  TYPE sfpdocparams, " Form Parameters for Form Processing
       error_string  TYPE string,
*---> Begin of Changes for Defect# 4271,D2_OTC_FDD_0013 BY kbansal.
       gv_langu_bi   TYPE spras. " Language Key
*<--- End of Changes for Defect# 4271,D2_OTC_FDD_0013 BY kbansal.


  IF xkausg IS INITIAL.
***<<<pdf-enabling
*    PERFORM form_start_as.
*   SAPScript logic for language determination can't be used
    language = save_langu.
***>>>pdf-enabling
    PERFORM find_sachbearbeiter.
    PERFORM read_t001s.
    save_usnam = hdusnam.
    PERFORM pruefen_husr03_2.
    IF xvorh2 IS INITIAL.
      PERFORM read_usr03_2.
      CLEAR husr03.
      MOVE-CORRESPONDING *usr03 TO husr03. "USR0340A
      APPEND husr03.
    ENDIF. " IF xvorh2 IS INITIAL
    countm = countm + 1.

    CLEAR rf140-avsid.
    IF NOT save_rxavis IS INITIAL.
      IF davsid IS INITIAL.
        IF save_koart = 'D'.
          save_konto = save_kunnr.
        ELSE. " ELSE -> IF save_koart = 'D'
          save_konto = save_lifnr.
        ENDIF. " IF save_koart = 'D'

        CLEAR   havico.
        REFRESH havico.

*         LOOP AT HBSID.
*           IF HBSID-AUGDT IS INITIAL
*           OR HBSID-AUGDT GT DATUM02.
*             MOVE-CORRESPONDING HBSID TO HAVICO.
*             HAVICO-KOART = 'D'.
*             APPEND HAVICO.
*           ENDIF.
*         ENDLOOP.
        LOOP AT dopos.
          IF dopos-augdt IS INITIAL
          OR dopos-augdt GT datum02.
            MOVE-CORRESPONDING dopos TO havico.
            havico-koart = 'D'.
            APPEND havico.
          ENDIF. " IF dopos-augdt IS INITIAL
        ENDLOOP. " LOOP AT dopos
        LOOP AT dmpos.
          IF dmpos-augdt IS INITIAL
          OR dmpos-augdt GT datum02.
            MOVE-CORRESPONDING dmpos TO havico.
            havico-koart = 'D'.
            APPEND havico.
          ENDIF. " IF dmpos-augdt IS INITIAL
        ENDLOOP. " LOOP AT dmpos

*         LOOP AT HBSIK.
*           IF HBSIK-AUGDT IS INITIAL
*           OR HBSIK-AUGDT GT DATUM02.
*             MOVE-CORRESPONDING HBSIK TO HAVICO.
*             HAVICO-KOART = 'K'.
*             APPEND HAVICO.
*           ENDIF.
*         ENDLOOP.
        LOOP AT kopos.
          IF kopos-augdt IS INITIAL
          OR kopos-augdt GT datum02.
            MOVE-CORRESPONDING kopos TO havico.
            havico-koart = 'K'.
            APPEND havico.
          ENDIF. " IF kopos-augdt IS INITIAL
        ENDLOOP. " LOOP AT kopos
        LOOP AT kmpos.
          IF kmpos-augdt IS INITIAL
          OR kmpos-augdt GT datum02.
            MOVE-CORRESPONDING kmpos TO havico.
            havico-koart = 'K'.
            APPEND havico.
          ENDIF. " IF kmpos-augdt IS INITIAL
        ENDLOOP. " LOOP AT kmpos

        LOOP AT havico.
          IF havico-bukrs NE *t001-bukrs.
            SELECT SINGLE * FROM t001 INTO *t001
              WHERE bukrs = havico-bukrs.
          ENDIF. " IF havico-bukrs NE *t001-bukrs
          alw_waers = havico-waers.
          PERFORM currency_get_subsequent
                      USING
                         save_repid_alw
                         datum02
                         havico-bukrs
                      CHANGING
                         alw_waers.
          IF alw_waers NE havico-waers.
            PERFORM convert_foreign_to_foreign_cur
                        USING
                           datum02
                           havico-waers
                           *t001-waers
                           alw_waers
                        CHANGING
                           havico-wrbtr.
            havico-waers = alw_waers.
            MODIFY havico.
          ENDIF. " IF alw_waers NE havico-waers
        ENDLOOP. " LOOP AT havico

        CALL FUNCTION 'REMADV_CORRESPONDENCE_INSERT'
          EXPORTING
            i_vorid = '0001' "Kontoauszug
            i_bukrs = save_bukrs
            i_koart = save_koart
            i_konto = save_konto
          IMPORTING
            e_avsid = rf140-avsid
          TABLES
            t_avico = havico
          EXCEPTIONS
            error   = 1
            OTHERS  = 0.

        IF sy-subrc = 0.
          CALL FUNCTION 'REMADV_SAVE_DB_ALL'
            EXPORTING
              i_dialog_update = 'X'
              i_commit        = ' '
            EXCEPTIONS
              OTHERS          = 1.
        ELSE. " ELSE -> IF sy-subrc = 0
          CLEAR fimsg.
          fimsg-msgid = 'FB'.
          fimsg-msgty = 'S'.
          fimsg-msgno = '862'.
          fimsg-msgv1 = save_bukrs.
          fimsg-msgv2 = save_koart.
          fimsg-msgv3 = save_konto.
          fimsg-msgv4 = '08'.
          PERFORM message_collect.
        ENDIF. " IF sy-subrc = 0

      ELSE. " ELSE -> IF davsid IS INITIAL
        IF save_koart = 'D'.
          save_konto = save_kunnr.
        ELSE. " ELSE -> IF save_koart = 'D'
          save_konto = save_lifnr.
        ENDIF. " IF save_koart = 'D'

        CLEAR   havico.
        REFRESH havico.

*         LOOP AT HBSID.
*           IF HBSID-AUGDT IS INITIAL
*           OR HBSID-AUGDT GT DATUM02.
*             MOVE-CORRESPONDING HBSID TO HAVICO.
*             HAVICO-KOART = 'D'.
*             APPEND HAVICO.
*           ENDIF.
*         ENDLOOP.
        LOOP AT dopos.
          IF dopos-augdt IS INITIAL
          OR dopos-augdt GT datum02.
            MOVE-CORRESPONDING dopos TO havico.
            havico-koart = 'D'.
            APPEND havico.
          ENDIF. " IF dopos-augdt IS INITIAL
        ENDLOOP. " LOOP AT dopos
        LOOP AT dmpos.
          IF dmpos-augdt IS INITIAL
          OR dmpos-augdt GT datum02.
            MOVE-CORRESPONDING dmpos TO havico.
            havico-koart = 'D'.
            APPEND havico.
          ENDIF. " IF dmpos-augdt IS INITIAL
        ENDLOOP. " LOOP AT dmpos

*         LOOP AT HBSIK.
*           IF HBSIK-AUGDT IS INITIAL
*           OR HBSIK-AUGDT GT DATUM02.
*             MOVE-CORRESPONDING HBSIK TO HAVICO.
*             HAVICO-KOART = 'K'.
*             APPEND HAVICO.
*           ENDIF.
*         ENDLOOP.
        LOOP AT kopos.
          IF kopos-augdt IS INITIAL
          OR kopos-augdt GT datum02.
            MOVE-CORRESPONDING kopos TO havico.
            havico-koart = 'K'.
            APPEND havico.
          ENDIF. " IF kopos-augdt IS INITIAL
        ENDLOOP. " LOOP AT kopos
        LOOP AT kmpos.
          IF kmpos-augdt IS INITIAL
          OR kmpos-augdt GT datum02.
            MOVE-CORRESPONDING kmpos TO havico.
            havico-koart = 'K'.
            APPEND havico.
          ENDIF. " IF kmpos-augdt IS INITIAL
        ENDLOOP. " LOOP AT kmpos

        CLEAR   avik.
        CLEAR   havip.
        REFRESH havip.

        avik-bukrs = save_bukrs.
        avik-koart = save_koart.
        avik-konto = save_konto.
        avik-avsid = davsid.

        CALL FUNCTION 'REMADV_POSITIONS_READ'
          EXPORTING
            i_avik        = avik
          TABLES
            t_avip        = havip
          EXCEPTIONS
            nothing_found = 1
            OTHERS        = 2.

        LOOP AT havico.
          LOOP AT havip
            WHERE belnr = havico-belnr
            AND   gjahr = havico-gjahr
            AND   buzei = havico-buzei.
            DELETE havip.
            EXIT.
          ENDLOOP. " LOOP AT havip
          IF sy-subrc = 0.
            DELETE havico.
          ENDIF. " IF sy-subrc = 0
        ENDLOOP. " LOOP AT havico

        DESCRIBE TABLE havico LINES av1lines.
        DESCRIBE TABLE havip  LINES av2lines.
        IF av1lines NE 0
        OR av1lines NE 0.
          CLEAR rf140-avsid.

          CLEAR hbkormkey.
          CLEAR herdata.
          hbkormkey-bukrs = hdbukrs.
          hbkormkey-koart = hdkoart.
          hbkormkey-konto = hdkonto.
          hbkormkey-belnr = dabelnr.
          hbkormkey-gjahr = dagjahr.
          CONDENSE hbkormkey.
          herdata-usnam = hdusnam.
          herdata-datum = hddatum.
          herdata-uzeit = hduzeit.
          CLEAR fimsg.
          fimsg-msort = '    '. fimsg-msgid = 'FB'. fimsg-msgty = 'S'.
          fimsg-msgno = '863'.
          fimsg-msgv1 = davsid.
          fimsg-msgv2 = bkorm-event.
          fimsg-msgv3 = hbkormkey.
          fimsg-msgv4 = herdata.
          PERFORM message_collect.

        ELSE. " ELSE -> IF av1lines NE 0
          rf140-avsid = davsid.
        ENDIF. " IF av1lines NE 0
      ENDIF. " IF davsid IS INITIAL
    ENDIF. " IF NOT save_rxavis IS INITIAL

    IF NOT save_rzlsch IS INITIAL.
      CLEAR paymi.
      CLEAR xkausgzt.
      CALL FUNCTION 'PAYMENT_MEDIUM_INIT'
        IMPORTING
          e_paymo = paymo
        EXCEPTIONS
          OTHERS  = 0.
    ENDIF. " IF NOT save_rzlsch IS INITIAL

    CLEAR ls_header.
    CLEAR ls_address.
    REFRESH lt_address[].
    CLEAR ls_item.
    REFRESH lt_item[].
    CLEAR ls_sum.
    REFRESH lt_sum[].
    CLEAR ls_rtab.
    REFRESH lt_rtab[].

*-------------------------------header,address------------------------*

    MOVE-CORRESPONDING dkadr TO ls_adrs.
    IF NOT dkadr-adrnr IS INITIAL.
      CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
        EXPORTING
          address_type         = '1'
          address_number       = dkadr-adrnr
          sender_country       = dkadr-inlnd
*         PERSON_NUMBER        = ' '
        IMPORTING
          address_printform    = ls_adrs_print
*         NUMBER_OF_USED_LINES =
        EXCEPTIONS
          OTHERS               = 1.
* fill receiver address information into header
      MOVE-CORRESPONDING ls_adrs_print TO ls_header.
* also provide address information in address
      MOVE-CORRESPONDING ls_adrs_print TO ls_address.
    ELSE. " ELSE -> IF NOT dkadr-adrnr IS INITIAL
      MOVE-CORRESPONDING dkadr TO ls_adrs.
      CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
        EXPORTING
          adrswa_in            = ls_adrs
        IMPORTING
          adrswa_out           = ls_adrs
*         NUMBER_OF_USED_LINES =
        EXCEPTIONS
          OTHERS               = 1.
* fill receiver address information into header
      MOVE-CORRESPONDING ls_adrs TO ls_header.
* also provide address information in address
      MOVE-CORRESPONDING ls_adrs TO ls_address.
    ENDIF. " IF NOT dkadr-adrnr IS INITIAL

* header
    MOVE-CORRESPONDING fsabe TO ls_header.
    MOVE-CORRESPONDING bkorm TO ls_header.
    MOVE-CORRESPONDING t001s TO ls_header.
    MOVE dkadr-adrnr TO ls_header-adrnr.
    MOVE dkadr-konto TO ls_header-konto.
    MOVE dkadr-land1 TO ls_header-land1.
    MOVE dkadr-zsabe TO ls_header-zsabe.
    MOVE dkadr-eikto TO ls_header-eikto.
    MOVE t001-adrnr TO ls_header-sadrnr.
    MOVE t001-waers TO ls_header-hwaer.
    MOVE dkadr-inlnd TO ls_header-inlnd.

* enrich address-structure with masterdata
    ls_address-corrid = co_rfkord_rec. "receiveraddress
    MOVE dkadr-adrnr TO ls_address-adrnr.
    MOVE dkadr-konto TO ls_address-konto.
    MOVE dkadr-land1 TO ls_address-land1.
    MOVE dkadr-zsabe TO ls_address-zsabe.
    MOVE dkadr-eikto TO ls_address-eikto.
    MOVE-CORRESPONDING fsabe TO ls_address.

    CASE save_koart.
      WHEN 'D'.
        MOVE-CORRESPONDING kna1 TO ls_address.
        MOVE-CORRESPONDING knb1 TO ls_address.
      WHEN 'K'.
        MOVE-CORRESPONDING lfa1 TO ls_address.
        MOVE-CORRESPONDING lfb1 TO ls_address.
    ENDCASE.


* standardtexts (HEADER; FOOTER usw.)
    MOVE t001g-txtko  TO ls_header-txtko.
    MOVE t001g-txtfu  TO ls_header-txtfu.
    MOVE t001g-txtun  TO ls_header-txtun.
    MOVE t001g-txtab  TO ls_header-txtab.
    MOVE t001g-header TO ls_header-header.
    MOVE t001g-footer TO ls_header-footer.
    MOVE t001g-sender TO ls_header-sender.
    MOVE t001g-greetings TO ls_header-greetings.
    MOVE t001g-logo   TO ls_header-logo.
    MOVE t001g-graph  TO ls_header-graph.

    IF save_rxopol IS INITIAL.
*=> ID (customer statement)
      ls_header-corrid = co_rfkord_cst. "customer statement
    ELSE. " ELSE -> IF save_rxopol IS INITIAL
*=> ID (open item list)
      ls_header-corrid = co_rfkord_oil. "open item list
    ENDIF. " IF save_rxopol IS INITIAL

* language
    CLEAR ls_header-spras.
    ls_header-spras = language.

* Dates (from-, to- and key-date)
    ls_header-date_from = rf140-datu1.
    ls_header-date_to = rf140-datu2.
    ls_header-key_date = rf140-stida.
* Added VSTID into ls_header
    ls_header-vstid = rf140-vstid.

* individual text
    ls_header-tdname = rf140-tdname.
    ls_header-tdspras = rf140-tdspras.

    APPEND ls_address TO lt_address.

*-------------------------------header completed-----------------------*

*-------------------------------senderaddress(response address)--------*
    CLEAR ls_address.
    MOVE-CORRESPONDING raadr TO ls_adrs.
    IF NOT raadr-adrnr IS INITIAL.
      CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
        EXPORTING
          address_type         = '1'
          address_number       = raadr-adrnr
          sender_country       = raadr-inlnd
*         PERSON_NUMBER        = ' '
        IMPORTING
          address_printform    = ls_adrs_print
*         NUMBER_OF_USED_LINES =
        EXCEPTIONS
          OTHERS               = 1.
      MOVE-CORRESPONDING ls_adrs_print TO ls_address.
    ELSE. " ELSE -> IF NOT raadr-adrnr IS INITIAL
      MOVE-CORRESPONDING raadr TO ls_adrs.
      CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
        EXPORTING
          adrswa_in            = ls_adrs
        IMPORTING
          adrswa_out           = ls_adrs
*         NUMBER_OF_USED_LINES =
        EXCEPTIONS
          OTHERS               = 1.
      MOVE-CORRESPONDING ls_adrs TO ls_address.
    ENDIF. " IF NOT raadr-adrnr IS INITIAL

* enrich address-structure with masterdata
    ls_address-corrid = co_rfkord_raa. "Rückantwortadresse
    MOVE raadr-adrnr TO ls_address-adrnr.
    MOVE raadr-land1 TO ls_address-land1.

    APPEND ls_address TO lt_address.
*-------------------------------senderaddress completed----------------*


    CLEAR   saldoa.
    REFRESH saldoa.
*    CLEAR   SALDOE.
*    REFRESH SALDOE.
    CLEAR   saldof.
    REFRESH saldof.
    CLEAR   saldom.
    REFRESH saldom.
    CLEAR   saldok.
    REFRESH saldok.

*------Ausgleichsvorgänge---------------------------------------------*
    IF save_koart = 'D'.
      IF NOT aidlines IS INITIAL.
        LOOP AT hbsid.
          IF hbsid-bukrs NE *t001-bukrs.
            SELECT SINGLE * FROM t001 INTO *t001
              WHERE bukrs = hbsid-bukrs.
          ENDIF. " IF hbsid-bukrs NE *t001-bukrs
          CLEAR ls_item-netdt.
          IF NOT save_rxekvb IS INITIAL.
            IF NOT xpkont IS INITIAL.
              AT NEW <konto3>.
                CLEAR   saldok.
                REFRESH saldok.
              ENDAT.
            ENDIF. " IF NOT xpkont IS INITIAL
          ENDIF. " IF NOT save_rxekvb IS INITIAL

          MOVE-CORRESPONDING hbsid TO bsid.
          MOVE-CORRESPONDING bsid TO ls_item.
          MOVE bsid-kunnr TO ls_item-konto.
          MOVE save_koart TO ls_item-koart.

          PERFORM fill_waehrungsfelder_bsidk.
          ls_item-wrshb = rf140-wrshb.
          ls_item-dmshb = rf140-dmshb.
          ls_item-wsshb = rf140-wsshb.
          ls_item-skshb = rf140-skshb.
          ls_item-wsshv = rf140-wsshv.
          ls_item-skshv = rf140-skshv.

          PERFORM fill_skonto_bsidk.
          ls_item-wskta = rf140-wskta.
          ls_item-wrshn = rf140-wrshn.

          CLEAR ls_item-waers.
          ls_item-waers = bsid-waers.

          IF bsid-shkzg = 'S'.
            ls_item-psshb = hbsid-pswbt.
            ls_item-zlshb = hbsid-nebtr.
          ELSE. " ELSE -> IF bsid-shkzg = 'S'
            ls_item-psshb = 0 - hbsid-pswbt.
            ls_item-zlshb = 0 - hbsid-nebtr.
          ENDIF. " IF bsid-shkzg = 'S'
          ls_item-zalbt = hbsid-zalbt.

*** expiring currencies: store old amounts
          ls_item_alw-waers_alw = ls_item-waers.
          ls_item_alw-pswsl_alw = ls_item-pswsl.
          ls_item_alw-wrshb_alw = ls_item-wrshb.
          ls_item_alw-dmshb_alw = ls_item-dmshb.
          ls_item_alw-wsshb_alw = ls_item-wsshb.
          ls_item_alw-skshb_alw = ls_item-skshb.
          ls_item_alw-wsshv_alw = ls_item-wsshv.
          ls_item_alw-skshv_alw = ls_item-skshv.
          ls_item_alw-wrshn_alw = ls_item-wrshn.
          ls_item_alw-wrshn_alw = ls_item-wrshn.
          ls_item_alw-zalbt_alw = ls_item-zalbt.
          MOVE *t001-waers TO ls_item_alw-hwaer_alw.

* provide old amounts in item structure (via ci-include)
          MOVE-CORRESPONDING ls_item_alw TO ls_item.

          alw_waers = bsid-waers.
          PERFORM currency_get_subsequent
                      USING
                         save_repid_alw
                         datum02
                         bsid-bukrs
                      CHANGING
                         alw_waers.
          IF alw_waers NE bsid-waers.
            bsid-waers = alw_waers.
            PERFORM curr_document_convert_bsid
                        USING
                           datum02
                           ls_item_alw-waers_alw
                           ls_item_alw-hwaer_alw
                           bsid-waers
                        CHANGING
                           bsid.

            PERFORM fill_waehrungsfelder_bsidk.
            ls_item-wrshb = rf140-wrshb.
            ls_item-dmshb = rf140-dmshb.
            ls_item-wsshb = rf140-wsshb.
            ls_item-skshb = rf140-skshb.
            ls_item-wsshv = rf140-wsshv.
            ls_item-skshv = rf140-skshv.

            PERFORM fill_skonto_bsidk.
            ls_item-wskta = rf140-wskta.
            ls_item-wrshn = rf140-wrshn.

            CLEAR ls_item-waers.
            ls_item-waers = bsid-waers.
            PERFORM convert_foreign_to_foreign_cur
                        USING
                           datum02
                           ls_item_alw-waers_alw
                           ls_item_alw-hwaer_alw
                           bsid-waers
                        CHANGING
                           hbsid-nebtr.
            IF bsid-shkzg = 'S'.
              ls_item-zlshb = hbsid-nebtr.
            ELSE. " ELSE -> IF bsid-shkzg = 'S'
              ls_item-zlshb = 0 - hbsid-nebtr.
            ENDIF. " IF bsid-shkzg = 'S'

            PERFORM convert_foreign_to_foreign_cur
                        USING
                           datum02
                           ls_item_alw-waers_alw
                           ls_item_alw-hwaer_alw
                           bsid-waers
                        CHANGING
                           hbsid-zalbt.
            ls_item-zalbt = hbsid-zalbt.
          ENDIF. " IF alw_waers NE bsid-waers
          IF  bsid-augdt IS INITIAL
          OR  bsid-augdt GT save2_datum.
            alw_waers = hbsid-pswsl.
            PERFORM currency_get_subsequent
                        USING
                           save_repid_alw
                           datum02
                           bsid-bukrs
                        CHANGING
                           alw_waers.
            IF alw_waers NE hbsid-pswsl.
              PERFORM convert_foreign_to_foreign_cur
                          USING
                             datum02
                             hbsid-pswsl
                             ls_item_alw-hwaer_alw
                             alw_waers
                          CHANGING
                             hbsid-pswbt.
              hbsid-pswsl = alw_waers.
              bsid-pswsl  = alw_waers.
              bsid-pswbt  = hbsid-pswbt.
              IF bsid-shkzg = 'S'.
                ls_item-psshb = hbsid-pswbt.
              ELSE. " ELSE -> IF bsid-shkzg = 'S'
                ls_item-psshb = 0 - hbsid-pswbt.
              ENDIF. " IF bsid-shkzg = 'S'
            ENDIF. " IF alw_waers NE hbsid-pswsl
          ENDIF. " IF bsid-augdt IS INITIAL

*            MOVE RF140-PSSHB  TO SALDOE-SALDOW.
*            IF BSID-AUGDT GT SAVE2_DATUM.
*              MOVE RF140-WSKTA  TO SALDOE-SALSK.
*              MOVE RF140-WRSHN  TO SALDOE-SALDN.
*            ENDIF.
*            COLLECT SALDOE.
          CLEAR saldok.
          MOVE hbsid-kunnr  TO saldok-konto.
          MOVE hbsid-pswsl  TO saldok-waers.
          MOVE ls_item-dmshb  TO saldok-saldoh.
          MOVE ls_item-psshb  TO saldok-saldow.
          IF hbsid-shkzg = 'S'.
            MOVE ls_item-psshb  TO saldok-saldop.
            CLEAR saldok-saldon.
          ELSE. " ELSE -> IF hbsid-shkzg = 'S'
            CLEAR saldok-saldop.
            MOVE ls_item-psshb  TO saldok-saldon.
          ENDIF. " IF hbsid-shkzg = 'S'
          MOVE ls_item-zlshb  TO saldok-nebtr.
          COLLECT saldok.
*          ENDIF.
          IF NOT rf140-vstid IS INITIAL.
            ls_item-vstid = rf140-vstid.
            IF hbsid-vztas IS INITIAL.
              CLEAR ls_item-vztas.
              ls_item-netdt = hbsid-netdt.
            ELSE. " ELSE -> IF hbsid-vztas IS INITIAL
              ls_item-vztas = hbsid-vztas.
              ls_item-netdt = hbsid-netdt.
            ENDIF. " IF hbsid-vztas IS INITIAL
            IF hbsid-augbl IS INITIAL
            OR ( hbsid-augdt GT rf140-vstid
                AND NOT rvztag IS INITIAL ).
              IF ls_item-vztas GE '0'.
                CLEAR saldof.
                MOVE hbsid-pswsl  TO saldof-waers.
                MOVE ls_item-dmshb  TO saldof-saldoh.
                MOVE ls_item-psshb  TO saldof-saldow.
                MOVE ls_item-wskta  TO saldof-salsk.
                MOVE ls_item-wrshn  TO saldof-saldn.
                COLLECT saldof.
              ENDIF. " IF ls_item-vztas GE '0'
            ENDIF. " IF hbsid-augbl IS INITIAL
          ENDIF. " IF NOT rf140-vstid IS INITIAL
          IF bsid-sgtxt(1) NE '*'.
            ls_item-sgtxt = space.
          ELSE. " ELSE -> IF bsid-sgtxt(1) NE '*'
            ls_item-sgtxt = bsid-sgtxt+1.
          ENDIF. " IF bsid-sgtxt(1) NE '*'
          IF bsid-xblnr IS INITIAL.
            MOVE bsid-belnr TO ls_item-belegnum.
          ELSE. " ELSE -> IF bsid-xblnr IS INITIAL
            MOVE bsid-xblnr TO ls_item-belegnum.
          ENDIF. " IF bsid-xblnr IS INITIAL

          CLEAR save_blart.
          save_blart = bsid-blart.
          PERFORM read_t003t.
          save_bschl = bsid-bschl.
          PERFORM read_tbslt.
*          IF NOT RXOPOS IS INITIAL.
          IF  ( save_rxekvb NE space
          AND   rxekep = '1'
          AND   bsid-kunnr NE save_kunnr )
          OR  ( save_rxekvb NE space
          AND   rxekep = '2' ).
          ELSE. " ELSE -> IF ( save_rxekvb NE space
            ls_item-corrid = co_rfkord_cst. "customer statement
            ls_item-blart_desc = t003t-ltext.
            ls_item-bschl_desc = tbslt-ltext.
            APPEND ls_item TO lt_item.
*------------------------------item completed--------------------------*
          ENDIF. " IF ( save_rxekvb NE space
*          ENDIF.
          IF NOT save_rxekvb IS INITIAL.
            IF NOT xpkont IS INITIAL.
              AT END OF <konto3>.
                IF  rxekep IS INITIAL
                AND rxeksu IS INITIAL.
                ELSE. " ELSE -> IF rxekep IS INITIAL
                  SORT saldok BY waers.
                  LOOP AT saldok.
*                IF  ( RXEKEP = '1'
*                AND SALDOK-KONTO =  SAVE_KUNNR
*                AND     RXEKSU IS INITIAL ).
*                ELSE.
                    CLEAR ls_sum.
                    ls_sum-sum_id = co_rfkord_sdka.
                    MOVE saldok-konto  TO ls_sum-konto.
                    MOVE saldok-waers  TO ls_sum-waers.
                    MOVE saldok-saldow TO ls_sum-saldow.
                    MOVE t001-waers    TO ls_sum-hwaer.
                    MOVE saldok-saldoh TO ls_sum-saldoh.
                    MOVE saldok-saldop TO ls_sum-saldop.
                    MOVE saldok-saldon TO ls_sum-saldon.
                    MOVE saldok-nebtr  TO ls_sum-nebtr.
                    APPEND ls_sum TO lt_sum.
*                ENDIF.
                  ENDLOOP. " LOOP AT saldok
                ENDIF. " IF rxekep IS INITIAL
              ENDAT.
            ENDIF. " IF NOT xpkont IS INITIAL
          ENDIF. " IF NOT save_rxekvb IS INITIAL
        ENDLOOP. " LOOP AT hbsid
      ENDIF. " IF NOT aidlines IS INITIAL
    ELSE. " ELSE -> IF save_koart = 'D'
      IF NOT aiklines IS INITIAL.
        LOOP AT hbsik.
          IF hbsik-bukrs NE *t001-bukrs.
            SELECT SINGLE * FROM t001 INTO *t001
              WHERE bukrs = hbsik-bukrs.
          ENDIF. " IF hbsik-bukrs NE *t001-bukrs
          CLEAR ls_item-netdt.

          MOVE-CORRESPONDING hbsik TO bsik.
          MOVE-CORRESPONDING bsik TO ls_item.
          MOVE bsik-lifnr TO ls_item-konto.
          MOVE save_koart TO ls_item-koart.

          PERFORM fill_waehrungsfelder_bsidk.
          ls_item-wrshb = rf140-wrshb.
          ls_item-dmshb = rf140-dmshb.
          ls_item-wsshb = rf140-wsshb.
          ls_item-skshb = rf140-skshb.
          ls_item-wsshv = rf140-wsshv.
          ls_item-skshv = rf140-skshv.

          PERFORM fill_skonto_bsidk.
          ls_item-wskta = rf140-wskta.
          ls_item-wrshn = rf140-wrshn.

          CLEAR ls_item-waers.
          ls_item-waers = bsik-waers.
*          IF BSIK-BSTAT NE 'S'.
*            MOVE HBSIK-PSWSL  TO SALDOE-WAERS.
*            MOVE RF140-DMSHB  TO SALDOE-SALDOH.
          IF bsik-shkzg = 'S'.
            ls_item-psshb = hbsik-pswbt.
            ls_item-zlshb = hbsik-nebtr.
          ELSE. " ELSE -> IF bsik-shkzg = 'S'
            ls_item-psshb = 0 - hbsik-pswbt.
            ls_item-zlshb = 0 - hbsik-nebtr.
          ENDIF. " IF bsik-shkzg = 'S'
          ls_item-zalbt = hbsik-zalbt.

*** expiring currencies: store old amounts
          ls_item_alw-waers_alw = ls_item-waers.
          ls_item_alw-pswsl_alw = ls_item-pswsl.
          ls_item_alw-wrshb_alw = ls_item-wrshb.
          ls_item_alw-dmshb_alw = ls_item-dmshb.
          ls_item_alw-wsshb_alw = ls_item-wsshb.
          ls_item_alw-skshb_alw = ls_item-skshb.
          ls_item_alw-wsshv_alw = ls_item-wsshv.
          ls_item_alw-skshv_alw = ls_item-skshv.
          ls_item_alw-wrshn_alw = ls_item-wrshn.
          ls_item_alw-wrshn_alw = ls_item-wrshn.
          ls_item_alw-zalbt_alw = ls_item-zalbt.
          MOVE *t001-waers TO ls_item_alw-hwaer_alw.

* provide old amounts in item structure (via ci-include)
          MOVE-CORRESPONDING ls_item_alw TO ls_item.

          alw_waers = bsik-waers.
          PERFORM currency_get_subsequent
                      USING
                         save_repid_alw
                         datum02
                         bsik-bukrs
                      CHANGING
                         alw_waers.
          IF alw_waers NE bsik-waers.
            bsik-waers = alw_waers.
            PERFORM curr_document_convert_bsik
                        USING
                           datum02
                           ls_item_alw-waers_alw
                           ls_item_alw-hwaer_alw
                           bsik-waers
                        CHANGING
                           bsik.

            PERFORM fill_waehrungsfelder_bsidk.
            ls_item-wrshb = rf140-wrshb.
            ls_item-dmshb = rf140-dmshb.
            ls_item-wsshb = rf140-wsshb.
            ls_item-skshb = rf140-skshb.
            ls_item-wsshv = rf140-wsshv.
            ls_item-skshv = rf140-skshv.

            PERFORM fill_skonto_bsidk.
            ls_item-wskta = rf140-wskta.
            ls_item-wrshn = rf140-wrshn.

            CLEAR ls_item-waers.
            ls_item-waers = bsik-waers.
            PERFORM convert_foreign_to_foreign_cur
                        USING
                           datum02
                           ls_item_alw-waers_alw
                           ls_item_alw-hwaer_alw
                           bsik-waers
                        CHANGING
                           hbsik-nebtr.
            IF bsik-shkzg = 'S'.
              ls_item-zlshb = hbsik-nebtr.
            ELSE. " ELSE -> IF bsik-shkzg = 'S'
              ls_item-zlshb = 0 - hbsik-nebtr.
            ENDIF. " IF bsik-shkzg = 'S'
            PERFORM convert_foreign_to_foreign_cur
                        USING
                           datum02
                           ls_item_alw-waers_alw
                           ls_item_alw-hwaer_alw
                           bsik-waers
                        CHANGING
                           hbsik-zalbt.
            ls_item-zalbt = hbsik-zalbt.
          ENDIF. " IF alw_waers NE bsik-waers
          IF  bsik-augdt IS INITIAL
          OR  bsik-augdt GT save2_datum.
            alw_waers = hbsik-pswsl.
            PERFORM currency_get_subsequent
                        USING
                           save_repid_alw
                           datum02
                           bsik-bukrs
                        CHANGING
                           alw_waers.
            IF alw_waers NE hbsik-pswsl.
              PERFORM convert_foreign_to_foreign_cur
                          USING
                             datum02
                             hbsik-pswsl
                             ls_item_alw-hwaer_alw
                             alw_waers
                          CHANGING
                             hbsik-pswbt.
              hbsik-pswsl = alw_waers.
              bsik-pswsl  = alw_waers.
              bsik-pswbt  = hbsik-pswbt.
              IF bsik-shkzg = 'S'.
                ls_item-psshb = hbsik-pswbt.
              ELSE. " ELSE -> IF bsik-shkzg = 'S'
                ls_item-psshb = 0 - hbsik-pswbt.
              ENDIF. " IF bsik-shkzg = 'S'
            ENDIF. " IF alw_waers NE hbsik-pswsl
          ENDIF. " IF bsik-augdt IS INITIAL
*         endif.
*            MOVE RF140-PSSHB  TO SALDOE-SALDOW.
*            IF BSIK-AUGDT GT SAVE2_DATUM.
*              MOVE RF140-WSKTA  TO SALDOE-SALSK.
*              MOVE RF140-WRSHN  TO SALDOE-SALDN.
*            ENDIF.
*            COLLECT SALDOE.
*          ENDIF.
          IF NOT rf140-vstid IS INITIAL.
            ls_item-vstid = rf140-vstid.
            IF hbsik-vztas IS INITIAL.
              CLEAR ls_item-vztas.
              ls_item-netdt = hbsik-netdt.
            ELSE. " ELSE -> IF hbsik-vztas IS INITIAL
              ls_item-vztas = hbsik-vztas.
              ls_item-netdt = hbsik-netdt.
            ENDIF. " IF hbsik-vztas IS INITIAL
            IF hbsik-augbl IS INITIAL
            OR ( hbsik-augdt GT rf140-vstid
                AND NOT rvztag IS INITIAL ).
              IF ls_item-vztas GE '0'.
                CLEAR saldof.
                MOVE hbsik-pswsl  TO saldof-waers.
                MOVE ls_item-dmshb  TO saldof-saldoh.
                MOVE ls_item-psshb  TO saldof-saldow.
                MOVE ls_item-wskta  TO saldof-salsk.
                MOVE ls_item-wrshn  TO saldof-saldn.
                COLLECT saldof.
              ENDIF. " IF ls_item-vztas GE '0'
            ENDIF. " IF hbsik-augbl IS INITIAL
          ENDIF. " IF NOT rf140-vstid IS INITIAL
          IF bsik-sgtxt(1) NE '*'.
            ls_item-sgtxt = space.
          ELSE. " ELSE -> IF bsik-sgtxt(1) NE '*'
            ls_item-sgtxt = bsik-sgtxt+1.
          ENDIF. " IF bsik-sgtxt(1) NE '*'
          IF bsik-xblnr IS INITIAL.
            MOVE bsik-belnr TO ls_item-belegnum.
          ELSE. " ELSE -> IF bsik-xblnr IS INITIAL
            MOVE bsik-xblnr TO ls_item-belegnum.
          ENDIF. " IF bsik-xblnr IS INITIAL

          CLEAR save_blart.
          save_blart = bsik-blart.
          PERFORM read_t003t.
          save_bschl = bsid-bschl.
          PERFORM read_tbslt.
*          IF NOT RXOPOS IS INITIAL.
          ls_item-corrid = co_rfkord_cst. "customer statement
          ls_item-blart_desc = t003t-ltext.
          ls_item-bschl_desc = tbslt-ltext.
          APPEND ls_item TO lt_item.
*------------------------------item completed--------------------------*
*          ENDIF.
        ENDLOOP. " LOOP AT hbsik
      ENDIF. " IF NOT aiklines IS INITIAL
    ENDIF. " IF save_koart = 'D'

*------Offene Posten--------------------------------------------------*

    IF save_koart = 'D'.

      LOOP AT dopos.
        IF dopos-bukrs NE *t001-bukrs.
          SELECT SINGLE * FROM t001 INTO *t001
            WHERE bukrs = dopos-bukrs.
        ENDIF. " IF dopos-bukrs NE *t001-bukrs
        CLEAR ls_item-netdt.
        IF NOT save_rxekvb IS INITIAL.
          IF NOT xpkont IS INITIAL.
            AT NEW <konto1>.
              CLEAR   saldok.
              REFRESH saldok.
            ENDAT.
          ENDIF. " IF NOT xpkont IS INITIAL
        ENDIF. " IF NOT save_rxekvb IS INITIAL
        IF NOT xumskz IS INITIAL.
          AT NEW <umskz1>.
            CLEAR ereignis.
            save_umskz = <umskz1>.
            IF NOT <umskz1>    IS INITIAL.
              PERFORM read_t074t.
            ENDIF. " IF NOT <umskz1> IS INITIAL
            CLEAR   saldoz.
            REFRESH saldoz.
          ENDAT.
        ENDIF. " IF NOT xumskz IS INITIAL
        MOVE-CORRESPONDING dopos TO bsid.
        MOVE-CORRESPONDING bsid TO ls_item.
        MOVE bsid-kunnr TO ls_item-konto.
        MOVE save_koart TO ls_item-koart.

        PERFORM fill_waehrungsfelder_bsidk.
        ls_item-wrshb = rf140-wrshb.
        ls_item-dmshb = rf140-dmshb.
        ls_item-wsshb = rf140-wsshb.
        ls_item-skshb = rf140-skshb.
        ls_item-wsshv = rf140-wsshv.
        ls_item-skshv = rf140-skshv.

        PERFORM fill_skonto_bsidk.
        ls_item-wskta = rf140-wskta.
        ls_item-wrshn = rf140-wrshn.

        CLEAR ls_item-waers.
        ls_item-waers = bsid-waers.
*        IF BSID-BSTAT NE 'S'.
        IF bsid-shkzg = 'S'.
          ls_item-psshb = dopos-pswbt.
          ls_item-zlshb = dopos-nebtr.
        ELSE. " ELSE -> IF bsid-shkzg = 'S'
          ls_item-psshb = 0 - dopos-pswbt.
          ls_item-zlshb = 0 - dopos-nebtr.
        ENDIF. " IF bsid-shkzg = 'S'
        ls_item-zalbt = dopos-zalbt.

*** expiring currencies: store old amounts
        ls_item_alw-waers_alw = ls_item-waers.
        ls_item_alw-pswsl_alw = ls_item-pswsl.
        ls_item_alw-wrshb_alw = ls_item-wrshb.
        ls_item_alw-dmshb_alw = ls_item-dmshb.
        ls_item_alw-wsshb_alw = ls_item-wsshb.
        ls_item_alw-skshb_alw = ls_item-skshb.
        ls_item_alw-wsshv_alw = ls_item-wsshv.
        ls_item_alw-skshv_alw = ls_item-skshv.
        ls_item_alw-wrshn_alw = ls_item-wrshn.
        ls_item_alw-wrshn_alw = ls_item-wrshn.
        ls_item_alw-zalbt_alw = ls_item-zalbt.
        MOVE *t001-waers TO ls_item_alw-hwaer_alw.

* provide old amounts in item structure (via ci-include)
        MOVE-CORRESPONDING ls_item_alw TO ls_item.

        alw_waers = bsid-waers.
        PERFORM currency_get_subsequent
                    USING
                       save_repid_alw
                       datum02
                       bsid-bukrs
                    CHANGING
                       alw_waers.
        IF alw_waers NE bsid-waers.
          bsid-waers = alw_waers.
          PERFORM curr_document_convert_bsid
                      USING
                         datum02
                         ls_item_alw-waers_alw
                         ls_item_alw-hwaer_alw
                         bsid-waers
                      CHANGING
                         bsid.

          PERFORM fill_waehrungsfelder_bsidk.
          ls_item-wrshb = rf140-wrshb.
          ls_item-dmshb = rf140-dmshb.
          ls_item-wsshb = rf140-wsshb.
          ls_item-skshb = rf140-skshb.
          ls_item-wsshv = rf140-wsshv.
          ls_item-skshv = rf140-skshv.

          PERFORM fill_skonto_bsidk.
          ls_item-wskta = rf140-wskta.
          ls_item-wrshn = rf140-wrshn.

          CLEAR ls_item-waers.
          ls_item-waers = bsid-waers.
          PERFORM convert_foreign_to_foreign_cur
                      USING
                         datum02
                         ls_item_alw-waers_alw
                         ls_item_alw-hwaer_alw
                         bsid-waers
                      CHANGING
                         dopos-nebtr.
          IF bsid-shkzg = 'S'.
            ls_item-zlshb = dopos-nebtr.
          ELSE. " ELSE -> IF bsid-shkzg = 'S'
            ls_item-zlshb = 0 - dopos-nebtr.
          ENDIF. " IF bsid-shkzg = 'S'
          PERFORM convert_foreign_to_foreign_cur
                      USING
                         datum02
                         ls_item_alw-waers_alw
                         ls_item_alw-hwaer_alw
                         bsid-waers
                      CHANGING
                         dopos-zalbt.
          ls_item-zalbt = dopos-zalbt.
        ENDIF. " IF alw_waers NE bsid-waers
        IF  bsid-augdt IS INITIAL
        OR  bsid-augdt GT save2_datum.
          alw_waers = dopos-pswsl.
          PERFORM currency_get_subsequent
                      USING
                         save_repid_alw
                         datum02
                         bsid-bukrs
                      CHANGING
                         alw_waers.
          IF alw_waers NE dopos-pswsl.
            PERFORM convert_foreign_to_foreign_cur
                        USING
                           datum02
                           dopos-pswsl
                           ls_item_alw-hwaer_alw
                           alw_waers
                        CHANGING
                           dopos-pswbt.
            dopos-pswsl = alw_waers.
            bsid-pswsl  = alw_waers.
            bsid-pswbt  = dopos-pswbt.
            IF bsid-shkzg = 'S'.
              ls_item-psshb = dopos-pswbt.
            ELSE. " ELSE -> IF bsid-shkzg = 'S'
              ls_item-psshb = 0 - dopos-pswbt.
            ENDIF. " IF bsid-shkzg = 'S'
          ENDIF. " IF alw_waers NE dopos-pswsl
        ENDIF. " IF bsid-augdt IS INITIAL
*         endif.

        CLEAR saldoa.
        MOVE dopos-pswsl  TO saldoa-waers.
        MOVE ls_item-dmshb  TO saldoa-saldoh.
        MOVE ls_item-psshb  TO saldoa-saldow.
        IF bsid-augdt IS INITIAL
        OR bsid-augdt GT save2_datum.
          MOVE ls_item-wskta  TO saldoa-salsk.
          MOVE ls_item-wrshn  TO saldoa-saldn.
        ENDIF. " IF bsid-augdt IS INITIAL
        COLLECT saldoa.
        CLEAR saldoz.
        MOVE dopos-pswsl  TO saldoz-waers.
        MOVE ls_item-dmshb  TO saldoz-saldoh.
        MOVE ls_item-psshb  TO saldoz-saldow.
        IF  bsid-augdt IS INITIAL
        OR  bsid-augdt GT save2_datum.
          MOVE ls_item-wskta  TO saldoz-salsk.
          MOVE ls_item-wrshn  TO saldoz-saldn.
        ENDIF. " IF bsid-augdt IS INITIAL
        COLLECT saldoz.
        CLEAR saldok.
        MOVE dopos-kunnr  TO saldok-konto.
        MOVE dopos-pswsl  TO saldok-waers.
        MOVE ls_item-dmshb  TO saldok-saldoh.
        MOVE ls_item-psshb  TO saldok-saldow.
        IF dopos-shkzg = 'S'.
          MOVE ls_item-psshb  TO saldok-saldop.
          CLEAR saldok-saldon.
        ELSE. " ELSE -> IF dopos-shkzg = 'S'
          CLEAR saldok-saldop.
          MOVE ls_item-psshb  TO saldok-saldon.
        ENDIF. " IF dopos-shkzg = 'S'
        MOVE ls_item-zlshb  TO saldok-nebtr.
        COLLECT saldok.
*        ENDIF.
        IF NOT rf140-vstid IS INITIAL.
          ls_item-vstid = rf140-vstid.
          IF dopos-vztas IS INITIAL.
            CLEAR ls_item-vztas.
            ls_item-netdt = dopos-netdt.
          ELSE. " ELSE -> IF dopos-vztas IS INITIAL
            ls_item-vztas = dopos-vztas.
            ls_item-netdt = dopos-netdt.
          ENDIF. " IF dopos-vztas IS INITIAL
          IF dopos-augbl IS INITIAL
          OR ( dopos-augdt GT rf140-vstid
              AND NOT rvztag IS INITIAL ).
            IF ls_item-vztas GE '0'.
              CLEAR saldof.
              MOVE dopos-pswsl  TO saldof-waers.
              MOVE ls_item-dmshb  TO saldof-saldoh.
              MOVE ls_item-psshb  TO saldof-saldow.
              MOVE ls_item-wskta  TO saldof-salsk.
              MOVE ls_item-wrshn  TO saldof-saldn.
              COLLECT saldof.
            ENDIF. " IF ls_item-vztas GE '0'
          ENDIF. " IF dopos-augbl IS INITIAL
        ENDIF. " IF NOT rf140-vstid IS INITIAL
        IF bsid-sgtxt(1) NE '*'.
          ls_item-sgtxt = space.
        ELSE. " ELSE -> IF bsid-sgtxt(1) NE '*'
          ls_item-sgtxt = bsid-sgtxt+1.
        ENDIF. " IF bsid-sgtxt(1) NE '*'
        IF bsid-xblnr IS INITIAL.
          MOVE bsid-belnr TO ls_item-belegnum.
        ELSE. " ELSE -> IF bsid-xblnr IS INITIAL
          MOVE bsid-xblnr TO ls_item-belegnum.
        ENDIF. " IF bsid-xblnr IS INITIAL

        CLEAR save_blart.
        save_blart = bsid-blart.
        PERFORM read_t003t.
        save_bschl = bsid-bschl.
        PERFORM read_tbslt.
*        IF NOT RXOPOS IS INITIAL
        IF     rxopol IS INITIAL
        OR NOT save_rxopol IS INITIAL.
          IF  ( save_rxekvb NE space
          AND   rxekep = '1'
          AND   bsid-kunnr NE save_kunnr )
          OR  ( save_rxekvb NE space
          AND   rxekep = '2' ).
          ELSE. " ELSE -> IF ( save_rxekvb NE space
            ls_item-corrid = co_rfkord_oil. "offene-Posten-Liste
            ls_item-blart_desc = t003t-ltext.
            ls_item-bschl_desc = tbslt-ltext.
            APPEND ls_item TO lt_item.
*------------------------------item completed--------------------------*
          ENDIF. " IF ( save_rxekvb NE space
        ENDIF. " IF rxopol IS INITIAL
        IF NOT xumskz IS INITIAL.
          AT END OF <umskz1>.
            LOOP AT saldoz.
              CLEAR ls_sum.
              ls_sum-sum_id = co_rfkord_sdzo.
              ls_sum-genid_name = 'UMSKZ'.
              ls_sum-genid_value = <umskz1>.
              ls_sum-genid_text = t074t-ltext.
              MOVE saldoz-waers  TO ls_sum-waers.
              MOVE saldoz-saldow TO ls_sum-saldow.
              MOVE t001-waers    TO ls_sum-hwaer.
              MOVE saldoz-saldoh TO ls_sum-saldoh.
              MOVE saldoz-salsk  TO ls_sum-salsk.
              MOVE saldoz-saldn  TO ls_sum-saldn.
              APPEND ls_sum TO lt_sum.
            ENDLOOP. " LOOP AT saldoz
          ENDAT.
        ENDIF. " IF NOT xumskz IS INITIAL
        IF NOT save_rxekvb IS INITIAL.
          IF NOT xpkont IS INITIAL.
            AT END OF <konto1>.
              IF  rxekep IS INITIAL
              AND rxeksu IS INITIAL.
              ELSE. " ELSE -> IF rxekep IS INITIAL
*            IF NOT RXOPOS IS INITIAL
*            IF NOT SAVE_RXOPOL IS INITIAL.
                SORT saldok BY waers.
                LOOP AT saldok.
*              IF  ( RXEKEP = '1'
*              AND SALDOK-KONTO =  SAVE_KUNNR
*              AND     RXEKSU IS INITIAL ).
*              ELSE.
                  CLEAR ls_sum.
                  ls_sum-sum_id = co_rfkord_sdko.
                  MOVE saldok-konto  TO ls_sum-konto.
                  MOVE saldok-waers  TO ls_sum-waers.
                  MOVE saldok-saldow TO ls_sum-saldow.
                  MOVE t001-waers    TO ls_sum-hwaer.
                  MOVE saldok-saldoh TO ls_sum-saldoh.
                  MOVE saldok-saldop TO ls_sum-saldop.
                  MOVE saldok-saldon TO ls_sum-saldon.
                  MOVE saldok-nebtr  TO ls_sum-nebtr.
                  APPEND ls_sum TO lt_sum.
*              ENDIF.
                ENDLOOP. " LOOP AT saldok
*            ENDIF.
              ENDIF. " IF rxekep IS INITIAL
            ENDAT.
          ENDIF. " IF NOT xpkont IS INITIAL
        ENDIF. " IF NOT save_rxekvb IS INITIAL
      ENDLOOP. " LOOP AT dopos

    ELSE. " ELSE -> IF save_koart = 'D'

      LOOP AT kopos.
        IF kopos-bukrs NE *t001-bukrs.
          SELECT SINGLE * FROM t001 INTO *t001
            WHERE bukrs = kopos-bukrs.
        ENDIF. " IF kopos-bukrs NE *t001-bukrs
        CLEAR ls_item-netdt.
        IF NOT xumskz IS INITIAL.
          AT NEW <umskz2>.
            save_umskz = <umskz2>.
            IF NOT <umskz2>    IS INITIAL.
              PERFORM read_t074t.
            ENDIF. " IF NOT <umskz2> IS INITIAL
            CLEAR   saldoz.
            REFRESH saldoz.
          ENDAT.
        ENDIF. " IF NOT xumskz IS INITIAL

        MOVE-CORRESPONDING kopos TO bsik.
        MOVE-CORRESPONDING bsik TO ls_item.
        MOVE bsik-lifnr TO ls_item-konto.
        MOVE save_koart TO ls_item-koart.

        PERFORM fill_waehrungsfelder_bsidk.
        ls_item-wrshb = rf140-wrshb.
        ls_item-dmshb = rf140-dmshb.
        ls_item-wsshb = rf140-wsshb.
        ls_item-skshb = rf140-skshb.
        ls_item-wsshv = rf140-wsshv.
        ls_item-skshv = rf140-skshv.

        PERFORM fill_skonto_bsidk.
        ls_item-wskta = rf140-wskta.
        ls_item-wrshn = rf140-wrshn.

        CLEAR ls_item-waers.
        ls_item-waers = bsik-waers.
*        IF BSIK-BSTAT NE 'S'.
        IF bsik-shkzg = 'S'.
          ls_item-psshb = kopos-pswbt.
          ls_item-zlshb = kopos-nebtr.
        ELSE. " ELSE -> IF bsik-shkzg = 'S'
          ls_item-psshb = 0 - kopos-pswbt.
          ls_item-zlshb = 0 - kopos-nebtr.
        ENDIF. " IF bsik-shkzg = 'S'
        ls_item-zalbt = kopos-zalbt.

*** expiring currencies: store old amounts
        ls_item_alw-waers_alw = ls_item-waers.
        ls_item_alw-pswsl_alw = ls_item-pswsl.
        ls_item_alw-wrshb_alw = ls_item-wrshb.
        ls_item_alw-dmshb_alw = ls_item-dmshb.
        ls_item_alw-wsshb_alw = ls_item-wsshb.
        ls_item_alw-skshb_alw = ls_item-skshb.
        ls_item_alw-wsshv_alw = ls_item-wsshv.
        ls_item_alw-skshv_alw = ls_item-skshv.
        ls_item_alw-wrshn_alw = ls_item-wrshn.
        ls_item_alw-wrshn_alw = ls_item-wrshn.
        ls_item_alw-zalbt_alw = ls_item-zalbt.
        MOVE *t001-waers TO ls_item_alw-hwaer_alw.

* provide old amounts in item structure (via ci-include)
        MOVE-CORRESPONDING ls_item_alw TO ls_item.

        alw_waers = bsik-waers.
        PERFORM currency_get_subsequent
                    USING
                       save_repid_alw
                       datum02
                       bsik-bukrs
                    CHANGING
                       alw_waers.
        IF alw_waers NE bsik-waers.
          bsik-waers = alw_waers.
          PERFORM curr_document_convert_bsik
                      USING
                         datum02
                         ls_item_alw-waers_alw
                         ls_item_alw-hwaer_alw
                         bsik-waers
                      CHANGING
                         bsik.
          PERFORM fill_waehrungsfelder_bsidk.
          ls_item-wrshb = rf140-wrshb.
          ls_item-dmshb = rf140-dmshb.
          ls_item-wsshb = rf140-wsshb.
          ls_item-skshb = rf140-skshb.
          ls_item-wsshv = rf140-wsshv.
          ls_item-skshv = rf140-skshv.

          PERFORM fill_skonto_bsidk.
          ls_item-wskta = rf140-wskta.
          ls_item-wrshn = rf140-wrshn.

          CLEAR ls_item-waers.
          ls_item-waers = bsik-waers.
          PERFORM convert_foreign_to_foreign_cur
                      USING
                         datum02
                         ls_item_alw-waers_alw
                         ls_item_alw-hwaer_alw
                         bsik-waers
                      CHANGING
                         kopos-nebtr.
          IF bsik-shkzg = 'S'.
            ls_item-zlshb = kopos-nebtr.
          ELSE. " ELSE -> IF bsik-shkzg = 'S'
            ls_item-zlshb = 0 - kopos-nebtr.
          ENDIF. " IF bsik-shkzg = 'S'
          PERFORM convert_foreign_to_foreign_cur
                      USING
                         datum02
                         ls_item_alw-waers_alw
                         ls_item_alw-hwaer_alw
                         bsik-waers
                      CHANGING
                         kopos-zalbt.
          ls_item-zalbt = kopos-zalbt.
        ENDIF. " IF alw_waers NE bsik-waers
        IF  bsik-augdt IS INITIAL
        OR  bsik-augdt GT save2_datum.
          alw_waers = bsik-pswsl.
          PERFORM currency_get_subsequent
                      USING
                         save_repid_alw
                         datum02
                         bsik-bukrs
                      CHANGING
                         alw_waers.
          IF alw_waers NE bsik-pswsl.
            PERFORM convert_foreign_to_foreign_cur
                        USING
                           datum02
                           kopos-pswsl
                           ls_item_alw-hwaer_alw
                           alw_waers
                        CHANGING
                           kopos-pswbt.
            kopos-pswsl = alw_waers.
            bsik-pswsl  = alw_waers.
            bsik-pswbt  = kopos-pswbt.
            IF bsik-shkzg = 'S'.
              ls_item-psshb = kopos-pswbt.
            ELSE. " ELSE -> IF bsik-shkzg = 'S'
              ls_item-psshb = 0 - kopos-pswbt.
            ENDIF. " IF bsik-shkzg = 'S'
          ENDIF. " IF alw_waers NE bsik-pswsl
        ENDIF. " IF bsik-augdt IS INITIAL
*         endif.

        CLEAR saldoa.
        MOVE kopos-pswsl  TO saldoa-waers.
        MOVE ls_item-dmshb  TO saldoa-saldoh.
        MOVE ls_item-psshb  TO saldoa-saldow.
        IF bsik-augdt IS INITIAL
        OR bsik-augdt GT save2_datum.
          MOVE ls_item-wskta  TO saldoa-salsk.
          MOVE ls_item-wrshn  TO saldoa-saldn.
        ENDIF. " IF bsik-augdt IS INITIAL
        COLLECT saldoa.
        CLEAR saldoz.
        MOVE kopos-pswsl  TO saldoz-waers.
        MOVE ls_item-dmshb  TO saldoz-saldoh.
        MOVE ls_item-psshb  TO saldoz-saldow.
        IF  bsik-augdt IS INITIAL
        OR  bsik-augdt GT save2_datum.
          MOVE ls_item-wskta  TO saldoz-salsk.
          MOVE ls_item-wrshn  TO saldoz-saldn.
        ENDIF. " IF bsik-augdt IS INITIAL
        COLLECT saldoz.
*          MOVE KOPOS-PSWSL  TO SALDOE-WAERS.
*          MOVE RF140-DMSHB  TO SALDOE-SALDOH.
*          MOVE RF140-PSSHB  TO SALDOE-SALDOW.
*          IF BSIK-AUGDT GT SAVE2_DATUM.
*            MOVE RF140-WSKTA  TO SALDOE-SALSK.
*            MOVE RF140-WRSHN  TO SALDOE-SALDN.
*          ENDIF.
*          COLLECT SALDOE.
*        ENDIF.
        IF NOT rf140-vstid IS INITIAL.
          ls_item-vstid = rf140-vstid.
          IF kopos-vztas IS INITIAL.
            CLEAR ls_item-vztas.
            ls_item-netdt = kopos-netdt.
          ELSE. " ELSE -> IF kopos-vztas IS INITIAL
            ls_item-vztas = kopos-vztas.
            ls_item-netdt = kopos-netdt.
          ENDIF. " IF kopos-vztas IS INITIAL
          IF kopos-augbl IS INITIAL
          OR ( kopos-augdt GT rf140-vstid
              AND NOT rvztag IS INITIAL ).
            IF ls_item-vztas GE '0'.
              CLEAR saldof.
              MOVE kopos-pswsl  TO saldof-waers.
              MOVE ls_item-dmshb  TO saldof-saldoh.
              MOVE ls_item-psshb  TO saldof-saldow.
              MOVE ls_item-wskta  TO saldof-salsk.
              MOVE ls_item-wrshn  TO saldof-saldn.
              COLLECT saldof.
            ENDIF. " IF ls_item-vztas GE '0'
          ENDIF. " IF kopos-augbl IS INITIAL
        ENDIF. " IF NOT rf140-vstid IS INITIAL
        IF bsik-sgtxt(1) NE '*'.
          ls_item-sgtxt = space.
        ELSE. " ELSE -> IF bsik-sgtxt(1) NE '*'
          ls_item-sgtxt = bsik-sgtxt+1.
        ENDIF. " IF bsik-sgtxt(1) NE '*'
        IF bsik-xblnr IS INITIAL.
          MOVE bsik-belnr TO ls_item-belegnum.
        ELSE. " ELSE -> IF bsik-xblnr IS INITIAL
          MOVE bsik-xblnr TO ls_item-belegnum.
        ENDIF. " IF bsik-xblnr IS INITIAL

        CLEAR save_blart.
        save_blart = bsik-blart.
        PERFORM read_t003t.
        save_bschl = bsid-bschl.
        PERFORM read_tbslt.
*        IF NOT RXOPOS IS INITIAL
        IF     rxopol IS INITIAL
        OR NOT save_rxopol IS INITIAL.
          ls_item-corrid = co_rfkord_oil.
          ls_item-blart_desc = t003t-ltext.
          ls_item-bschl_desc = tbslt-ltext.
          APPEND ls_item TO lt_item.
*------------------------------item completed--------------------------*
        ENDIF. " IF rxopol IS INITIAL
        IF NOT xumskz IS INITIAL.
          AT END OF <umskz2>.
            LOOP AT saldoz.
              CLEAR ls_sum.
              ls_sum-sum_id = co_rfkord_sdzo.
              ls_sum-genid_name = 'UMSKZ'.
              ls_sum-genid_value = <umskz2>.
              ls_sum-genid_text = t074t-ltext.
              MOVE saldoz-waers  TO ls_sum-waers.
              MOVE saldoz-saldow TO ls_sum-saldow.
              MOVE t001-waers    TO ls_sum-hwaer.
              MOVE saldoz-saldoh TO ls_sum-saldoh.
              MOVE saldoz-salsk  TO ls_sum-salsk.
              MOVE saldoz-saldn  TO ls_sum-saldn.
              APPEND ls_sum TO lt_sum.
            ENDLOOP. " LOOP AT saldoz
          ENDAT.
        ENDIF. " IF NOT xumskz IS INITIAL
      ENDLOOP. " LOOP AT kopos
    ENDIF. " IF save_koart = 'D'

    DESCRIBE TABLE saldoa LINES sldalines.
    IF sldalines GT 0.
      SORT saldoa BY waers.
      LOOP AT saldoa.
        CLEAR ls_sum.
        ls_sum-sum_id = co_rfkord_sda. "balance carried-forward
        MOVE saldoa-waers  TO ls_sum-waers.
        MOVE saldoa-saldow TO ls_sum-saldow.
        MOVE t001-waers    TO ls_sum-hwaer.
        MOVE saldoa-saldoh TO ls_sum-saldoh.
        MOVE saldoa-salsk  TO ls_sum-salsk.
        MOVE saldoa-saldn  TO ls_sum-saldn.
        APPEND ls_sum TO lt_sum.
      ENDLOOP. " LOOP AT saldoa
    ENDIF. " IF sldalines GT 0


*------Offene Merkposten----------------------------------------------*

    IF save_koart = 'D'.

      LOOP AT dmpos.
        IF dmpos-bukrs NE *t001-bukrs.
          SELECT SINGLE * FROM t001 INTO *t001
            WHERE bukrs = dmpos-bukrs.
        ENDIF. " IF dmpos-bukrs NE *t001-bukrs
        CLEAR ls_item-netdt.
        IF NOT save_rxekvb IS INITIAL.
          IF NOT xpkont IS INITIAL.
            AT NEW <konto5>.
              CLEAR   saldok.
              REFRESH saldok.
            ENDAT.
          ENDIF. " IF NOT xpkont IS INITIAL
        ENDIF. " IF NOT save_rxekvb IS INITIAL
        IF NOT xumskz IS INITIAL.
          AT NEW <umskz5>.
            CLEAR ereignis.
            save_umskz = <umskz5>.
            IF NOT <umskz5>    IS INITIAL.
              PERFORM read_t074t.
            ENDIF. " IF NOT <umskz5> IS INITIAL
            CLEAR   saldoz.
            REFRESH saldoz.
          ENDAT.
        ENDIF. " IF NOT xumskz IS INITIAL

        MOVE-CORRESPONDING dmpos TO bsid.
        MOVE-CORRESPONDING bsid TO ls_item.
        MOVE bsid-kunnr TO ls_item-konto.
        MOVE save_koart TO ls_item-koart.

        PERFORM fill_waehrungsfelder_bsidk.
        ls_item-wrshb = rf140-wrshb.
        ls_item-dmshb = rf140-dmshb.
        ls_item-wsshb = rf140-wsshb.
        ls_item-skshb = rf140-skshb.
        ls_item-wsshv = rf140-wsshv.
        ls_item-skshv = rf140-skshv.

        PERFORM fill_skonto_bsidk.
        ls_item-wskta = rf140-wskta.
        ls_item-wrshn = rf140-wrshn.

        CLEAR ls_item-waers.
        rf140-waers = bsid-waers.
*       Added for currency not populated in Open noted Items
        ls_item-waers = bsid-waers.
*        IF BSID-BSTAT NE 'S'.
        IF bsid-shkzg = 'S'.
          ls_item-psshb = dmpos-pswbt.
          ls_item-zlshb = dmpos-nebtr.
        ELSE. " ELSE -> IF bsid-shkzg = 'S'
          ls_item-psshb = 0 - dmpos-pswbt.
          ls_item-zlshb = 0 - dmpos-nebtr.
        ENDIF. " IF bsid-shkzg = 'S'

*** expiring currencies: store old amounts
        ls_item_alw-waers_alw = ls_item-waers.
        ls_item_alw-pswsl_alw = ls_item-pswsl.
        ls_item_alw-wrshb_alw = ls_item-wrshb.
        ls_item_alw-dmshb_alw = ls_item-dmshb.
        ls_item_alw-wsshb_alw = ls_item-wsshb.
        ls_item_alw-skshb_alw = ls_item-skshb.
        ls_item_alw-wsshv_alw = ls_item-wsshv.
        ls_item_alw-skshv_alw = ls_item-skshv.
        ls_item_alw-wrshn_alw = ls_item-wrshn.
        ls_item_alw-wrshn_alw = ls_item-wrshn.
        ls_item_alw-zalbt_alw = ls_item-zalbt.
        MOVE *t001-waers TO ls_item_alw-hwaer_alw.


* provide old amounts in item structure (via ci-include)
        MOVE-CORRESPONDING ls_item_alw TO ls_item.

        alw_waers = bsid-waers.
        PERFORM currency_get_subsequent
                    USING
                       save_repid_alw
                       datum02
                       bsid-bukrs
                    CHANGING
                       alw_waers.
        IF alw_waers NE bsid-waers.
          bsid-waers = alw_waers.
          PERFORM curr_document_convert_bsid
                      USING
                         datum02
                         ls_item_alw-waers_alw
                         ls_item_alw-hwaer_alw
                         bsid-waers
                      CHANGING
                         bsid.

          PERFORM fill_waehrungsfelder_bsidk.
          ls_item-wrshb = rf140-wrshb.
          ls_item-dmshb = rf140-dmshb.
          ls_item-wsshb = rf140-wsshb.
          ls_item-skshb = rf140-skshb.
          ls_item-wsshv = rf140-wsshv.
          ls_item-skshv = rf140-skshv.

          PERFORM fill_skonto_bsidk.
          ls_item-wskta = rf140-wskta.
          ls_item-wrshn = rf140-wrshn.

          CLEAR ls_item-waers.
          ls_item-waers = bsid-waers.
          PERFORM convert_foreign_to_foreign_cur
                      USING
                         datum02
                         ls_item_alw-waers_alw
                         ls_item_alw-hwaer_alw
                         bsid-waers
                      CHANGING
                         dmpos-nebtr.
          IF bsid-shkzg = 'S'.
            ls_item-zlshb = dmpos-nebtr.
          ELSE. " ELSE -> IF bsid-shkzg = 'S'
            ls_item-zlshb = 0 - dmpos-nebtr.
          ENDIF. " IF bsid-shkzg = 'S'
          PERFORM convert_foreign_to_foreign_cur
                      USING
                         datum02
                         ls_item_alw-waers_alw
                         ls_item_alw-hwaer_alw
                         bsid-waers
                      CHANGING
                         dmpos-zalbt.
          ls_item-zalbt = dmpos-zalbt.
        ENDIF. " IF alw_waers NE bsid-waers
        IF  bsid-augdt IS INITIAL
        OR  bsid-augdt GT save2_datum.
          alw_waers = dmpos-pswsl.
          PERFORM currency_get_subsequent
                      USING
                         save_repid_alw
                         datum02
                         bsid-bukrs
                      CHANGING
                         alw_waers.
          IF alw_waers NE dmpos-pswsl.
            PERFORM convert_foreign_to_foreign_cur
                        USING
                           datum02
                           dmpos-pswsl
                           ls_item_alw-hwaer_alw
                           alw_waers
                        CHANGING
                           dmpos-pswbt.
            dmpos-pswsl = alw_waers.
            bsid-pswsl  = alw_waers.
            bsid-pswbt  = dmpos-pswbt.
            IF bsid-shkzg = 'S'.
              ls_item-psshb = dmpos-pswbt.
            ELSE. " ELSE -> IF bsid-shkzg = 'S'
              ls_item-psshb = 0 - dmpos-pswbt.
            ENDIF. " IF bsid-shkzg = 'S'
          ENDIF. " IF alw_waers NE dmpos-pswsl
        ENDIF. " IF bsid-augdt IS INITIAL
*         endif.

        CLEAR saldom.
        MOVE dmpos-pswsl  TO saldom-waers.
        MOVE ls_item-dmshb  TO saldom-saldoh.
        MOVE ls_item-psshb  TO saldom-saldow.
        IF bsid-augdt IS INITIAL
        OR bsid-augdt GT save2_datum.
          MOVE ls_item-wskta  TO saldom-salsk.
          MOVE ls_item-wrshn  TO saldom-saldn.
        ENDIF. " IF bsid-augdt IS INITIAL
        COLLECT saldom.
        CLEAR saldoz.
        MOVE dmpos-pswsl  TO saldoz-waers.
        MOVE ls_item-dmshb  TO saldoz-saldoh.
        MOVE ls_item-psshb  TO saldoz-saldow.
        IF  bsid-augdt IS INITIAL
        OR  bsid-augdt GT save2_datum.
          MOVE ls_item-wskta  TO saldoz-salsk.
          MOVE ls_item-wrshn  TO saldoz-saldn.
        ENDIF. " IF bsid-augdt IS INITIAL
        COLLECT saldoz.
        CLEAR saldok.
        MOVE dmpos-kunnr  TO saldok-konto.
        MOVE dmpos-pswsl  TO saldok-waers.
        MOVE ls_item-dmshb  TO saldok-saldoh.
        MOVE ls_item-psshb  TO saldok-saldow.
        IF dmpos-shkzg = 'S'.
          MOVE ls_item-psshb  TO saldok-saldop.
          CLEAR saldok-saldon.
        ELSE. " ELSE -> IF dmpos-shkzg = 'S'
          CLEAR saldok-saldop.
          MOVE ls_item-psshb  TO saldok-saldon.
        ENDIF. " IF dmpos-shkzg = 'S'
        MOVE ls_item-zlshb  TO saldok-nebtr.
        COLLECT saldok.
*        ENDIF.
        IF NOT rf140-vstid IS INITIAL.
          ls_item-vstid = rf140-vstid.
          IF dmpos-vztas IS INITIAL.
            CLEAR ls_item-vztas.
            ls_item-netdt = dmpos-netdt.
          ELSE. " ELSE -> IF dmpos-vztas IS INITIAL
            ls_item-vztas = dmpos-vztas.
            ls_item-netdt = dmpos-netdt.
          ENDIF. " IF dmpos-vztas IS INITIAL
          IF dmpos-augbl IS INITIAL
          OR ( dmpos-augdt GT rf140-vstid
              AND NOT rvztag IS INITIAL ).
            IF ls_item-vztas GE '0'.
              CLEAR saldof.
              MOVE dmpos-pswsl  TO saldof-waers.
              MOVE ls_item-dmshb  TO saldof-saldoh.
              MOVE ls_item-psshb  TO saldof-saldow.
              MOVE ls_item-wskta  TO saldof-salsk.
              MOVE ls_item-wrshn  TO saldof-saldn.
              COLLECT saldof.
            ENDIF. " IF ls_item-vztas GE '0'
          ENDIF. " IF dmpos-augbl IS INITIAL
        ENDIF. " IF NOT rf140-vstid IS INITIAL
        IF bsid-sgtxt(1) NE '*'.
          ls_item-sgtxt = space.
        ELSE. " ELSE -> IF bsid-sgtxt(1) NE '*'
          ls_item-sgtxt = bsid-sgtxt+1.
        ENDIF. " IF bsid-sgtxt(1) NE '*'
        IF bsid-xblnr IS INITIAL.
          MOVE bsid-belnr TO ls_item-belegnum.
        ELSE. " ELSE -> IF bsid-xblnr IS INITIAL
          MOVE bsid-xblnr TO ls_item-belegnum.
        ENDIF. " IF bsid-xblnr IS INITIAL

        CLEAR save_blart.
        save_blart = bsid-blart.
        PERFORM read_t003t.
        save_bschl = bsid-bschl.
        PERFORM read_tbslt.
        CLEAR ereignis.
*        IF NOT RXOPOS IS INITIAL.
        IF  ( save_rxekvb NE space
        AND   rxekep = '1'
        AND   bsid-kunnr NE save_kunnr )
        OR  ( save_rxekvb NE space
        AND   rxekep = '2' ).
        ELSE. " ELSE -> IF ( save_rxekvb NE space
          ls_item-corrid = co_rfkord_mpo. "noted items
          ls_item-blart_desc = t003t-ltext.
          ls_item-bschl_desc = tbslt-ltext.
          APPEND ls_item TO lt_item.
*------------------------------item completed--------------------------*
        ENDIF. " IF ( save_rxekvb NE space
*        ENDIF.
        IF NOT xumskz IS INITIAL.
          AT END OF <umskz5>.
            LOOP AT saldoz.
              CLEAR ls_sum.
              ls_sum-sum_id = co_rfkord_sdzm.
              ls_sum-genid_name = 'UMSKZ'.
              ls_sum-genid_value = <umskz5>.
              ls_sum-genid_text = t074t-ltext.
              MOVE saldoz-waers  TO ls_sum-waers.
              MOVE saldoz-saldow TO ls_sum-saldow.
              MOVE t001-waers    TO ls_sum-hwaer.
              MOVE saldoz-saldoh TO ls_sum-saldoh.
              MOVE saldoz-salsk  TO ls_sum-salsk.
              MOVE saldoz-saldn  TO ls_sum-saldn.
              APPEND ls_sum TO lt_sum.
            ENDLOOP. " LOOP AT saldoz
          ENDAT.
        ENDIF. " IF NOT xumskz IS INITIAL
        IF NOT save_rxekvb IS INITIAL.
          IF NOT xpkont IS INITIAL.
            AT END OF <konto5>.
              IF  rxekep IS INITIAL
              AND rxeksu IS INITIAL.
              ELSE. " ELSE -> IF rxekep IS INITIAL
                SORT saldok BY waers.
                LOOP AT saldok.
*              IF  ( RXEKEP = '1'
*              AND SALDOK-KONTO =  SAVE_KUNNR
*              AND     RXEKSU IS INITIAL ).
*              ELSE.
                  CLEAR ls_sum.
                  ls_sum-sum_id = co_rfkord_sdkm.
                  MOVE saldok-konto  TO ls_sum-konto.
                  MOVE saldok-waers  TO ls_sum-waers.
                  MOVE saldok-saldow TO ls_sum-saldow.
                  MOVE t001-waers    TO ls_sum-hwaer.
                  MOVE saldok-saldoh TO ls_sum-saldoh.
                  MOVE saldok-saldop TO ls_sum-saldop.
                  MOVE saldok-saldon TO ls_sum-saldon.
                  MOVE saldok-nebtr  TO ls_sum-nebtr.
                  APPEND ls_sum TO lt_sum.
*              ENDIF.
                ENDLOOP. " LOOP AT saldok
              ENDIF. " IF rxekep IS INITIAL
            ENDAT.
          ENDIF. " IF NOT xpkont IS INITIAL
        ENDIF. " IF NOT save_rxekvb IS INITIAL
      ENDLOOP. " LOOP AT dmpos

    ELSE. " ELSE -> IF save_koart = 'D'

      LOOP AT kmpos.
        IF kmpos-bukrs NE *t001-bukrs.
          SELECT SINGLE * FROM t001 INTO *t001
            WHERE bukrs = kmpos-bukrs.
        ENDIF. " IF kmpos-bukrs NE *t001-bukrs
        CLEAR ls_item-netdt.
        IF NOT xumskz IS INITIAL.
          AT NEW <umskz6>.
            save_umskz = <umskz6>.
            IF NOT <umskz6>    IS INITIAL.
              PERFORM read_t074t.
            ENDIF. " IF NOT <umskz6> IS INITIAL
            CLEAR   saldoz.
            REFRESH saldoz.
          ENDAT.
        ENDIF. " IF NOT xumskz IS INITIAL

        MOVE-CORRESPONDING kmpos TO bsik.
        MOVE-CORRESPONDING bsik TO ls_item.
        MOVE bsik-lifnr TO ls_item-konto.
        MOVE save_koart TO ls_item-koart.

        PERFORM fill_waehrungsfelder_bsidk.
        ls_item-wrshb = rf140-wrshb.
        ls_item-dmshb = rf140-dmshb.
        ls_item-wsshb = rf140-wsshb.
        ls_item-skshb = rf140-skshb.
        ls_item-wsshv = rf140-wsshv.
        ls_item-skshv = rf140-skshv.

        PERFORM fill_skonto_bsidk.
        ls_item-wskta = rf140-wskta.
        ls_item-wrshn = rf140-wrshn.

        CLEAR ls_item-waers.
        ls_item-waers = bsik-waers.
*        IF BSIK-BSTAT NE 'S'.
        IF bsik-shkzg = 'S'.
          ls_item-psshb = kmpos-pswbt.
          ls_item-zlshb = kmpos-nebtr.
        ELSE. " ELSE -> IF bsik-shkzg = 'S'
          ls_item-psshb = 0 - kmpos-pswbt.
          ls_item-zlshb = 0 - kmpos-nebtr.
        ENDIF. " IF bsik-shkzg = 'S'

*** expiring currencies: store old amounts
        ls_item_alw-waers_alw = ls_item-waers.
        ls_item_alw-pswsl_alw = ls_item-pswsl.
        ls_item_alw-wrshb_alw = ls_item-wrshb.
        ls_item_alw-dmshb_alw = ls_item-dmshb.
        ls_item_alw-wsshb_alw = ls_item-wsshb.
        ls_item_alw-skshb_alw = ls_item-skshb.
        ls_item_alw-wsshv_alw = ls_item-wsshv.
        ls_item_alw-skshv_alw = ls_item-skshv.
        ls_item_alw-wrshn_alw = ls_item-wrshn.
        ls_item_alw-wrshn_alw = ls_item-wrshn.
        ls_item_alw-zalbt_alw = ls_item-zalbt.
        MOVE *t001-waers TO ls_item_alw-hwaer_alw.

* provide old amounts in item structure (via ci-include)
        MOVE-CORRESPONDING ls_item_alw TO ls_item.

        alw_waers = bsik-waers.
        PERFORM currency_get_subsequent
                    USING
                       save_repid_alw
                       datum02
                       bsik-bukrs
                    CHANGING
                       alw_waers.
        IF alw_waers NE bsik-waers.
          bsik-waers = alw_waers.
          PERFORM curr_document_convert_bsik
                      USING
                         datum02
                         ls_item_alw-waers_alw
                         ls_item_alw-hwaer_alw
                         bsik-waers
                      CHANGING
                         bsik.

          PERFORM fill_waehrungsfelder_bsidk.
          ls_item-wrshb = rf140-wrshb.
          ls_item-dmshb = rf140-dmshb.
          ls_item-wsshb = rf140-wsshb.
          ls_item-skshb = rf140-skshb.
          ls_item-wsshv = rf140-wsshv.
          ls_item-skshv = rf140-skshv.

          PERFORM fill_skonto_bsidk.
          ls_item-wskta = rf140-wskta.
          ls_item-wrshn = rf140-wrshn.

          CLEAR ls_item-waers.
          ls_item-waers = bsik-waers.
          PERFORM convert_foreign_to_foreign_cur
                      USING
                         datum02
                         ls_item_alw-waers_alw
                         ls_item_alw-hwaer_alw
                         bsik-waers
                      CHANGING
                         kmpos-nebtr.
          IF bsik-shkzg = 'S'.
            ls_item-zlshb = kmpos-nebtr.
          ELSE. " ELSE -> IF bsik-shkzg = 'S'
            ls_item-zlshb = 0 - kmpos-nebtr.
          ENDIF. " IF bsik-shkzg = 'S'
          PERFORM convert_foreign_to_foreign_cur
                      USING
                         datum02
                         ls_item_alw-waers_alw
                         ls_item_alw-hwaer_alw
                         bsik-waers
                      CHANGING
                         kmpos-zalbt.
          ls_item-zalbt = kmpos-zalbt.
        ENDIF. " IF alw_waers NE bsik-waers
        IF  bsik-augdt IS INITIAL
        OR  bsik-augdt GT save2_datum.
          alw_waers = kmpos-pswsl.
          PERFORM currency_get_subsequent
                      USING
                         save_repid_alw
                         datum02
                         bsik-bukrs
                      CHANGING
                         alw_waers.
          IF alw_waers NE kmpos-pswsl.
            PERFORM convert_foreign_to_foreign_cur
                        USING
                           datum02
                           kmpos-pswsl
                           ls_item_alw-hwaer_alw
                           alw_waers
                        CHANGING
                           kmpos-pswbt.
            kmpos-pswsl = alw_waers.
            bsik-pswsl  = alw_waers.
            bsik-pswbt  = hbsid-pswbt.
            IF bsik-shkzg = 'S'.
              ls_item-psshb = kmpos-pswbt.
            ELSE. " ELSE -> IF bsik-shkzg = 'S'
              ls_item-psshb = 0 - kmpos-pswbt.
            ENDIF. " IF bsik-shkzg = 'S'
          ENDIF. " IF alw_waers NE kmpos-pswsl
        ENDIF. " IF bsik-augdt IS INITIAL
*         endif.

        CLEAR saldom.
        MOVE kmpos-pswsl  TO saldom-waers.
        MOVE ls_item-dmshb  TO saldom-saldoh.
        MOVE ls_item-psshb  TO saldom-saldow.
        IF bsik-augdt IS INITIAL
        OR bsik-augdt GT save2_datum.
          MOVE ls_item-wskta  TO saldom-salsk.
          MOVE ls_item-wrshn  TO saldom-saldn.
        ENDIF. " IF bsik-augdt IS INITIAL
        COLLECT saldom.
        CLEAR saldoz.
        MOVE kmpos-pswsl  TO saldoz-waers.
        MOVE ls_item-dmshb  TO saldoz-saldoh.
        MOVE ls_item-psshb  TO saldoz-saldow.
        IF  bsik-augdt IS INITIAL
        OR  bsik-augdt GT save2_datum.
          MOVE ls_item-wskta  TO saldoz-salsk.
          MOVE ls_item-wrshn  TO saldoz-saldn.
        ENDIF. " IF bsik-augdt IS INITIAL
        COLLECT saldoz.
*        ENDIF.
        IF NOT rf140-vstid IS INITIAL.
          ls_item-vstid = rf140-vstid.
          IF kmpos-vztas IS INITIAL.
            CLEAR ls_item-vztas.
            ls_item-netdt = kmpos-netdt.
          ELSE. " ELSE -> IF kmpos-vztas IS INITIAL
            ls_item-vztas = kmpos-vztas.
            ls_item-netdt = kmpos-netdt.
          ENDIF. " IF kmpos-vztas IS INITIAL
          IF kmpos-augbl IS INITIAL
          OR ( kmpos-augdt GT rf140-vstid
              AND NOT rvztag IS INITIAL ).
            IF ls_item-vztas GE '0'.
              CLEAR saldof.
              MOVE kmpos-pswsl  TO saldof-waers.
              MOVE ls_item-dmshb  TO saldof-saldoh.
              MOVE ls_item-psshb  TO saldof-saldow.
              MOVE ls_item-wskta  TO saldof-salsk.
              MOVE ls_item-wrshn  TO saldof-saldn.
              COLLECT saldof.
            ENDIF. " IF ls_item-vztas GE '0'
          ENDIF. " IF kmpos-augbl IS INITIAL
        ENDIF. " IF NOT rf140-vstid IS INITIAL

        IF bsik-sgtxt(1) NE '*'.
          ls_item-sgtxt = space.
        ELSE. " ELSE -> IF bsik-sgtxt(1) NE '*'
          ls_item-sgtxt = bsik-sgtxt+1.
        ENDIF. " IF bsik-sgtxt(1) NE '*'
        IF bsik-xblnr IS INITIAL.
          MOVE bsik-belnr TO ls_item-belegnum.
        ELSE. " ELSE -> IF bsik-xblnr IS INITIAL
          MOVE bsik-xblnr TO ls_item-belegnum.
        ENDIF. " IF bsik-xblnr IS INITIAL

        CLEAR save_blart.
        save_blart = bsik-blart.
        PERFORM read_t003t.
        save_bschl = bsid-bschl.
        PERFORM read_tbslt.
*        IF NOT RXOPOS IS INITIAL.
        ls_item-corrid = co_rfkord_mpo. "noted items
        ls_item-blart_desc = t003t-ltext.
        ls_item-bschl_desc = tbslt-ltext.
        APPEND ls_item TO lt_item.
*------------------------------item completed--------------------------*
*        ENDIF.
        IF NOT xumskz IS INITIAL.
          AT END OF <umskz6>.
            LOOP AT saldoz.
              CLEAR ls_sum.
              ls_sum-sum_id = co_rfkord_sdzm.
              ls_sum-genid_name = 'UMSKZ'.
              ls_sum-genid_value = <umskz6>.
              ls_sum-genid_text = t074t-ltext.
              MOVE saldoz-waers  TO ls_sum-waers.
              MOVE saldoz-saldow TO ls_sum-saldow.
              MOVE t001-waers    TO ls_sum-hwaer.
              MOVE saldoz-saldoh TO ls_sum-saldoh.
              MOVE saldoz-salsk  TO ls_sum-salsk.
              MOVE saldoz-saldn  TO ls_sum-saldn.
              APPEND ls_sum TO lt_sum.
            ENDLOOP. " LOOP AT saldoz
          ENDAT.
        ENDIF. " IF NOT xumskz IS INITIAL
      ENDLOOP. " LOOP AT kmpos
    ENDIF. " IF save_koart = 'D'

    DESCRIBE TABLE saldom LINES sldmlines.
    IF sldmlines GT 0.
      SORT saldom BY waers.
      LOOP AT saldom.
        CLEAR ls_sum.
        ls_sum-sum_id = co_rfkord_sdm.
        MOVE saldom-waers  TO ls_sum-waers.
        MOVE saldom-saldow TO ls_sum-saldow.
        MOVE t001-waers    TO ls_sum-hwaer.
        MOVE saldom-saldoh TO ls_sum-saldoh.
        MOVE saldom-salsk  TO ls_sum-salsk.
        MOVE saldom-saldn  TO ls_sum-saldn.
        APPEND ls_sum TO lt_sum.
      ENDLOOP. " LOOP AT saldom
    ENDIF. " IF sldmlines GT 0

*------Summe fällige Posten und OP-Rasterung--------------------------*

    IF NOT rf140-vstid IS INITIAL.
      DESCRIBE TABLE saldof LINES sldflines.
      IF sldflines GT 0.
        SORT saldof BY waers.
        LOOP AT saldof.
          CLEAR ls_sum.
          ls_sum-sum_id = co_rfkord_sdf.
          MOVE saldof-waers  TO ls_sum-waers.
          MOVE saldof-saldow TO ls_sum-saldow.
          MOVE t001-waers    TO ls_sum-hwaer.
          MOVE saldof-saldoh TO ls_sum-saldoh.
          MOVE saldof-salsk  TO ls_sum-salsk.
          MOVE saldof-saldn  TO ls_sum-saldn.
          APPEND ls_sum TO lt_sum.
        ENDLOOP. " LOOP AT saldof
      ENDIF. " IF sldflines GT 0

      CLEAR sldflines.
      DESCRIBE TABLE rtab LINES sldflines.
      IF sldflines GT 0.

        CLEAR ls_rtab.
        REFRESH lt_rtab[].

        LOOP AT rtab.
          MOVE-CORRESPONDING rtab TO ls_rtab.
          ls_rtab-rpt01 = rf140-rpt01.
          ls_rtab-rpt02 = rf140-rpt02.
          ls_rtab-rpt03 = rf140-rpt03.
          ls_rtab-rpt04 = rf140-rpt04.
          ls_rtab-rpt05 = rf140-rpt05.
          ls_rtab-rpt06 = rf140-rpt06.
          ls_rtab-rpt07 = rf140-rpt07.
          ls_rtab-rpt08 = rf140-rpt08.
          ls_rtab-rpt09 = rf140-rpt09.
          ls_rtab-rpt10 = rf140-rpt10.
          APPEND ls_rtab TO lt_rtab.
        ENDLOOP. " LOOP AT rtab

      ENDIF. " IF sldflines GT 0
    ENDIF. " IF NOT rf140-vstid IS INITIAL

* provide subsidary information in address
    IF  NOT xzent  IS INITIAL.
*    AND     HXDEZV IS INITIAL.
      DESCRIBE TABLE filialen LINES sy-tfill.

      LOOP AT filialen.
        CLEAR fiadr.
        CLEAR ls_address.
        IF save_koart = 'D'.
          LOOP AT hkna1
            WHERE kunnr = filialen-filiale.
            MOVE-CORRESPONDING hkna1 TO fiadr.
            MOVE hkna1-kunnr         TO fiadr-konto.
            MOVE t001-land1          TO fiadr-inlnd.
          ENDLOOP. " LOOP AT hkna1
          LOOP AT hknb1
            WHERE kunnr = filialen-filiale
            AND   bukrs = save_bukrs.
            MOVE-CORRESPONDING hknb1 TO fiadr.
          ENDLOOP. " LOOP AT hknb1
        ELSE. " ELSE -> IF save_koart = 'D'
          LOOP AT hlfa1
            WHERE lifnr = filialen-filiale.
            MOVE-CORRESPONDING hlfa1 TO fiadr.
            MOVE hlfa1-lifnr         TO fiadr-konto.
            MOVE t001-land1          TO fiadr-inlnd.
          ENDLOOP. " LOOP AT hlfa1
          LOOP AT hlfb1
            WHERE lifnr = filialen-filiale
            AND   bukrs = save_bukrs.
            MOVE-CORRESPONDING hlfb1 TO fiadr.
          ENDLOOP. " LOOP AT hlfb1
        ENDIF. " IF save_koart = 'D'

        MOVE-CORRESPONDING fiadr TO ls_address.

        MOVE-CORRESPONDING fiadr TO ls_adrs.
        IF NOT dkadr-adrnr IS INITIAL.
          CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
            EXPORTING
              address_type         = '1'
              address_number       = fiadr-adrnr
              sender_country       = fiadr-inlnd
*             PERSON_NUMBER        = ' '
            IMPORTING
              address_printform    = ls_adrs_print
*             NUMBER_OF_USED_LINES =
            EXCEPTIONS
              OTHERS               = 1.
          MOVE-CORRESPONDING ls_adrs_print TO ls_address.
        ELSE. " ELSE -> IF NOT dkadr-adrnr IS INITIAL
          MOVE-CORRESPONDING fiadr TO ls_adrs.
          CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
            EXPORTING
              adrswa_in            = ls_adrs
            IMPORTING
              adrswa_out           = ls_adrs
*             NUMBER_OF_USED_LINES =
            EXCEPTIONS
              OTHERS               = 1.
          MOVE-CORRESPONDING ls_adrs TO ls_address.
        ENDIF. " IF NOT dkadr-adrnr IS INITIAL

        MOVE co_rfkord_fil TO ls_address-corrid.
        APPEND ls_address TO lt_address.

      ENDLOOP. " LOOP AT filialen
    ENDIF. " IF NOT xzent IS INITIAL

*--------------------payment medium------------------------------------*
    IF NOT save_rzlsch IS INITIAL.

      REFRESH lt_paymo[].
      CLEAR: paymi, paymo.

      paymi-bukrs = save_bukrs.
      paymi-zlsch = save_rzlsch.
      paymi-nacha = finaa-nacha.
      paymi-applk = 'FI-FI'.
      paymi-zbukr = save_bukrs.
      paymi-zadrt = '01'.
      MOVE-CORRESPONDING dkadr TO paymi.
      IF save_koart = 'D'.
        paymi-kunnr = save_kunnr.
      ELSE. " ELSE -> IF save_koart = 'D'
        paymi-lifnr = save_lifnr.
      ENDIF. " IF save_koart = 'D'
      paymi-avsid = rf140-avsid.
      paymi-datum = syst-datum.
      paymi-vorid = '0001'.

      DESCRIBE TABLE saldoe LINES sldelines.
      IF sldelines = 1.
        READ TABLE saldoe INDEX 1.
        paymi-waers = saldoe-waers.
        IF saldoe-saldow GT 0.
          paymi-shkzg = 'S'.
        ELSE. " ELSE -> IF saldoe-saldow GT 0
          paymi-shkzg = 'H'.
        ENDIF. " IF saldoe-saldow GT 0
        paymi-rbbtr = saldoe-saldoh.
        paymi-rwbbt = saldoe-saldow.
        paymi-rwskt = saldoe-salsk.
      ENDIF. " IF sldelines = 1

      REFRESH hfimsg.
      CLEAR   hfimsg.
      CALL FUNCTION 'PAYMENT_MEDIUM_DATA'
        EXPORTING
          i_paymi = paymi
        IMPORTING
          e_paymo = paymo
        TABLES
          t_fimsg = hfimsg
        EXCEPTIONS
          OTHERS  = 4.
      IF sy-subrc NE 0.
        xkausgzt = 'X'.
      ENDIF. " IF sy-subrc NE 0

* provide paymo
      APPEND paymo TO lt_paymo.

      LOOP AT hfimsg.
        CALL FUNCTION 'FI_MESSAGE_COLLECT'
          EXPORTING
            i_fimsg       = hfimsg
*           I_XAPPN       = ' '
          EXCEPTIONS
*           MSGID_MISSING = 1
*           MSGNO_MISSING = 2
*           MSGTY_MISSING = 3
            OTHERS        = 4.
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF. " IF sy-subrc <> 0
      ENDLOOP. " LOOP AT hfimsg
    ENDIF. " IF NOT save_rzlsch IS INITIAL

*    xprint = 'X'.  ">>VGAUR     E1DK901190

    CHECK save_ftype = '3'.

* get docparams
    PERFORM fill_docparams_pdf USING    language
                                    dkadr-inlnd
                                    h_archive_index
                           CHANGING fp_docparams.
************************************************************************
*  Start of changes for PDF generation
*  Copy of Standard Include RFKORI16PDF
*----------------------------------------------------------------------*
*  User      Transport
*----------------------------------------------------------------------*
*  VGAUR     E1DK901190
************************************************************************
*---> Begin of D2_change of object D2_OTC_FDD_0013 BY KBANSAL.
    PERFORM f_language    CHANGING fp_docparams
                                   gv_langu_bi.
*<--- End of D2_change of object D2_OTC_FDD_0013 BY KBANSAL.
    PERFORM f_adobe_form_processing USING fp_docparams
                                          lt_item
                                          lt_rtab
                                          gv_langu_bi.
************************************************************************
*  End of changes for PDF generation
*  Copy of Standard Include RFKORI16PDF
*----------------------------------------------------------------------*
*  User      Transport
*----------------------------------------------------------------------*
*  VGAUR     E1DK901190
************************************************************************

  ENDIF. " IF xkausg IS INITIAL
ENDFORM. "AUSGABE_CUSTOMER_STAT

*&---------------------------------------------------------------------*
*&      Form  check_output
*&---------------------------------------------------------------------*
*       created by note 854148. Statements activating indicator XKAUSG
*       are moved from FORM AUSGABE_KONTOAUSZUG in order to avoid that
*       a fax cover sheet is printed without corresponding output of
*       open item list or customer statement
*----------------------------------------------------------------------*
FORM check_output .
* CLEAR xkausg.
  CLEAR aidlines.
  CLEAR aiklines.
  CLEAR aoplines.
  CLEAR amplines.
  IF save_rxopol IS INITIAL.
    IF save_koart = 'D'.
      DESCRIBE TABLE hbsid LINES aidlines.
      DESCRIBE TABLE dopos LINES aoplines.
      DESCRIBE TABLE dmpos LINES amplines.
      IF aidlines IS INITIAL.
        IF NOT aoplines IS INITIAL
        OR NOT amplines IS INITIAL.
        ELSE. " ELSE -> IF NOT aoplines IS INITIAL
          IF rxkpos IS INITIAL.
            xkausg = 'X'.
          ENDIF. " IF rxkpos IS INITIAL
        ENDIF. " IF NOT aoplines IS INITIAL
      ENDIF. " IF aidlines IS INITIAL
    ENDIF. " IF save_koart = 'D'
    IF save_koart = 'K'.
      DESCRIBE TABLE hbsik LINES aiklines.
      DESCRIBE TABLE kopos LINES aoplines.
      DESCRIBE TABLE kmpos LINES amplines.
      IF aiklines IS INITIAL.
        IF NOT aoplines IS INITIAL
        OR NOT amplines IS INITIAL.
        ELSE. " ELSE -> IF NOT aoplines IS INITIAL
          IF rxkpos IS INITIAL.
            xkausg = 'X'.
          ENDIF. " IF rxkpos IS INITIAL
        ENDIF. " IF NOT aoplines IS INITIAL
      ENDIF. " IF aiklines IS INITIAL
    ENDIF. " IF save_koart = 'K'
  ELSE. " ELSE -> IF save_rxopol IS INITIAL
    IF save_koart = 'D'.
      DESCRIBE TABLE dopos LINES aoplines.
      DESCRIBE TABLE dmpos LINES amplines.
    ELSE. " ELSE -> IF save_koart = 'D'
      DESCRIBE TABLE kopos LINES aoplines.
      DESCRIBE TABLE kmpos LINES amplines.
    ENDIF. " IF save_koart = 'D'
    IF aoplines IS INITIAL.
      IF NOT amplines IS INITIAL.
      ELSE. " ELSE -> IF NOT amplines IS INITIAL
        IF rxkpos IS INITIAL.
          xkausg = 'X'.
        ENDIF. " IF rxkpos IS INITIAL
      ENDIF. " IF NOT amplines IS INITIAL
    ENDIF. " IF aoplines IS INITIAL
  ENDIF. " IF save_rxopol IS INITIAL

ENDFORM. " check_output

************************************************************************
*  Start of changes for PDF generation
*  Copy of Standard Include RFKORI16PDF
*----------------------------------------------------------------------*
*  User      Transport
*----------------------------------------------------------------------*
*  VGAUR     E1DK901190
************************************************************************
* 10-Apr-2013 AMANGAL  E1DK909861 CR357 Defect 3453. Send email only in*
*                       background mode. Form f_adobe_form_processing  *
************************************************************************
* WRICEF ID:   D2_OTC_FDD_0013_Monthly Open AR Statement               *
*                                                                      *
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 19-Nov-2014 NSAXENA  E2DK906565 D2 Changes - Replacing Remit to      *
*                                 address with standard text address in*
*                                 case of spanish language.            *
* 07-jan-2014 KBANSAL E2DK906565  Defect# 1997- Remit to is not        *
*                                               populating for company *
*                                               code 1103 and remove   *
*                                               periods between US and *
*                                               correct Remit to address*
*26-March-2015 KBANSAL E2DK906565 Defect# 4271- Maintain standard text  *
*                                 for Company Code-1020(Both English and*
*                                 French Text Displayed1103(only Spanish*
*                                 Text) displayed.                      *
*************************************************************************
* 21-Sep-2016  NALI    E1DK921941 D3_OTC_FDD_0013 - D3 changes - Send   *
*                                 Houe Bank Info to the form output,    *
*                                 replace the remit to address with the *
*                                 organisation address for D3           *
*************************************************************************
* 03-Jan-2017  SGHOSH  E1DK921941 CR#301: Changes done in the FM call of*
*                                 ZOTC_GET_HOUSEBANKINFO to accomodate  *
*                                 multiple address records. Also the    *
*                                 table returned is passed during form  *
*                                 call.                                 *
*************************************************************************
* 20-Feb-2017  U034087 E1DK925882 CR#356 : D3_OTC_FDD_0013
*                                 Changes done in format of Bank Address
*                                 printing.
*                                 1. IBAN - Divided in 4 sets
*                                    XXXX XXXX XXXX XX
*                                 2. Print Address and City from Standard
*                                    Text if Company Code 2001,2002 and
*                                    2003.
*                                 3. Clearing Text added in the form
*************************************************************************
* 13-Oct-2017   SGHOSH E1DK931140 D3R2 Change: 1. Added logic to support
*                                 Nordic languages.
*                                 2. Bug-fix for translation error if
*                                 KNKK select fails.
*************************************************************************
* 25-Jan-2018  SMUKHER4 E1DK931140 D3R3 Development:
*1. Remit to address should be uniform for all D3 countries i.e from 2068*
*2.Email address has been added which should check from 2068.
*3.Country name has been added for all address
*4.Only one housebank details will be required
*5.Customer's currency code check has been added from KNVV table
*************************************************************************
* 13-Mar-2018 SMUKHER4 E1DK931140 Defect# 5228: Legal entity name should*
*                                 be concatenated with Name1 & Name2    *
*                                 separated by space and condense.      *
*************************************************************************
*&---------------------------------------------------------------------*
*&      Form  F_ADOBE_FORM_PROCESSING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  FP_DOCPARAMS    Form Output Parameters
*  -->  FP_LT_ITEM      Line Item data
*  -->  FP_LT_RTAB      Day Intervals data
*----------------------------------------------------------------------*
FORM f_adobe_form_processing USING fp_docparams  TYPE sfpdocparams " Form Parameters for Form Processing
                                   fp_lt_item    TYPE rfkord_t_item
                                   fp_lt_rtab    TYPE rfkord_t_rtab
*---> Begin of Changes for Defect# 4271, D2_OTC_FDD_0013 BY KBANSAL.
                                   fp_gv_langu_bi TYPE spras. " Language Key
*<--- End of Changes for Defect# 4271, D2_OTC_FDD_0013 BY KBANSAL.
  TYPES:
*&--For Credit Contact info
   BEGIN OF lty_credit_info,
     param TYPE enhee_parameter, "Parameter
     value TYPE z_mvalue_high,   "Value
   END OF lty_credit_info,

* ---> Begin of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
   lty_t_enh_status TYPE STANDARD TABLE OF zdev_enh_status. " Enhancement Status
* <--- End of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI

*---> Begin of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
*&--Local Structure declarations
  TYPES: BEGIN OF lty_bukrs,
         bukrs TYPE vkbuk,            " Sales Organization
         END OF lty_bukrs,

         BEGIN OF lty_adrnr,
         bukrs TYPE vkbuk,            " Company code of the sales organization
         adrnr TYPE adrnr,            " Address
         END OF lty_adrnr,

         BEGIN OF lty_adrc,
         addrnumber TYPE  ad_addrnum, " Address number
         name1      TYPE   ad_name1,  " Name 1
         city1      TYPE  ad_city1,   " City
         post_code1 TYPE ad_pstcd1,   " City postal code
         street     TYPE ad_street,   " Street
         str_suppl2 TYPE ad_strspp2,  " Street 3
         country    TYPE land1,       "Country Key
         langu      TYPE spras,       "Language Key
         END OF lty_adrc.
*<--- End of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018

  FIELD-SYMBOLS:
  <lfs_credit_info> TYPE lty_credit_info, "Credit contact Info
  <lfs_lines> TYPE tline,                 " SAPscript: Text Lines
* ---> Begin of Change for D3_OTC_FDD_0013 by NALI
  <lfs_adrs_print> TYPE szadr_printform_table_line. " Structure for Standard Texts for Form OTC_FDD_0013
* <--- End of Change for D3_OTC_FDD_0013 by NALI



  DATA:
  lv_cust_adrnr    TYPE adrnr,         "Customer Address
  lv_status        TYPE string,        "Communication Status
  lv_comp_adrnr    TYPE adrnr,         "Company Address
  lv_sbgrp         TYPE sbgrp_cm,      "Credit representative group for credit management
  lv_crd_area      TYPE kkber,         "Credit Control Area
  lv_crd_grp       TYPE sbgrp_cm,      "Credit Control group
  lv_crd_rep_name  TYPE stext_cm,      "Credit Control Name
  lv_crd_rep_phone TYPE z_mvalue_high, "Credit Control Phone No.
  lx_formout       TYPE fpformoutput,  "Form Output (PDF, PDL)
* ---> Begin of Insert for Defect#1997, D2_OTC_FDD_0013 by KBANSAL.
  lx_org_address   TYPE zotc_company_address, "company Address
* <--- End   of Insert for Defect#1997, D2_OTC_FDD_0013 by KBANSAL.
*---> Begin of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
  lwa_org_address   TYPE zotc_company_address, "company Address
*<--- End of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
  lt_open_item     TYPE rfkord_t_item,                     "Open Items table
  lt_content       TYPE bcsy_text,                         "Mail Content
  lwa_content      TYPE LINE OF bcsy_text,                 "Mail Content
  lv_kunnr         TYPE kunnr,                             "Customer Number
  lv_vkorg         TYPE vkorg,                             " Sales Org " Defect 1997
  lt_credit_info   TYPE STANDARD TABLE OF lty_credit_info, "Credit contact Info
* ---> Begin of Change for D3_OTC_FDD_0013 by NALI
  lwa_standard_text TYPE zotc0013_st_list, " Structure for Standard Texts for Form OTC_FDD_0013
  lv_housebank_line2  TYPE string,
  lx_housebank_info   TYPE zotc_housebank, " Structure for House Bank Info
  lv_cust_country   TYPE land1.            " Country Key
* <--- End of Change for D3_OTC_FDD_0013 by NALI

* ---> Begin of Change for D3_OTC_FDD_0013_CR#356 by u034087

  DATA : lwa_value       TYPE rsdsselopt                    VALUE IS INITIAL, "Structure of generic SELECT-OPTION for (dynamic selections)
         li_value_bukrs  TYPE STANDARD TABLE OF rsdsselopt  INITIAL SIZE 0,   "Range Table
         li_banka_stras  TYPE STANDARD TABLE OF tline       INITIAL SIZE 0.   "SAPscript: Text Lines

  DATA : lv_len         TYPE int4   VALUE IS INITIAL,    " 2 byte integer (signed)
         lv_count       TYPE int4   VALUE IS INITIAL,    " 2 byte integer (signed)
         lv_line_banka  TYPE string VALUE IS INITIAL,    " Address
         lv_line_stras  TYPE string VALUE IS INITIAL,    " City
         lv_iban        TYPE string VALUE IS INITIAL,    " IBAN (International Bank Account Number)
         lv_iban_final  TYPE string VALUE IS INITIAL,    " IBAN (International Bank Account Number)
         lv_iban_fin_cond  TYPE string VALUE IS INITIAL, " IBAN (International Bank Account Number)
         lv_var         TYPE int4   VALUE IS INITIAL,    " 2 byte integer (signed)
         lv_off         TYPE int4   VALUE IS INITIAL.    " 2 byte integer (signed)

  CONSTANTS : lc_v    TYPE int4         VALUE '4.0', " Natural Number
              lc_i    TYPE tvarv_sign   VALUE 'I',                      " ABAP: ID: I/E (include/exclude values)
              lc_en   TYPE langu        VALUE 'E',                      " Language Key
              lc_name TYPE tdobname     VALUE 'ZOTC_BANKADDR_FIRMA_CH'. "Name

* <--- End of Change for D3_OTC_FDD_0013_CR#356 by u034087

  CONSTANTS:
  lc_vkorg       TYPE vkorg     VALUE '1000', "Sales Organization
*---> Begin of Change for D3_OTC_FDD_0013 by NALI
  lc_vtweg_90    TYPE z_criteria     VALUE 'VTWEG_INT', "Enhancement Criteria
  lc_vtweg_10    TYPE z_criteria     VALUE 'VTWEG_EXT', "Enhancement Criteria
*<--- End of Change for D3_OTC_FDD_0013 by NALI
  lc_mprogram    TYPE programm  VALUE 'ZOTCP0013O_MONTHLY_OPEN_AR_STM', "ABAP Program Name
  lc_param_name  TYPE char20    VALUE 'Z_CREDIT_REP_NAME',              "Parameter for credit contact name
  lc_param_phone TYPE char20    VALUE 'Z_CREDIT_REP_PHONE',             "Parameter for credit contact Phone
  lc_soption     TYPE char2     VALUE 'EQ',                             "Selection Option
  lc_msort       TYPE msort     VALUE '    ',                           "Sort field for messages
  lc_dev_msg     TYPE symsgid   VALUE 'ZDEV_MSG',                       "Dev Message Class
  lc_error       TYPE symsgty   VALUE 'E',                              "Error
  lc_status      TYPE symsgty   VALUE 'S',                              "Status
  lc_msgno_003   TYPE msgtyp    VALUE '003',                            "Message No.
  lc_open_ind    TYPE char3     VALUE 'OIL'.                            "Open Items Indicator

* ---> Begin of D2 Change for D2_OTC_FDD_0013 by NSAXENA.
  CONSTANTS: lc_id      TYPE tdid     VALUE 'ST',                       " Material-sales text
             lc_object  TYPE tdobject VALUE 'TEXT',                     " Order item text
             lc_name1   TYPE tdobname VALUE 'ZOTC_FDD_ACCOUNT_PESOS',   " Name
             lc_name2   TYPE tdobname VALUE 'ZOTC_FDD_ACCOUNT_DOLLARS', " Name
             lc_spanish TYPE sylangu VALUE 'S',                         "Spanish Language
* ---> Begin of Insert for Defect#1997, D2_OTC_FDD_0013 by KBANSAL.
             lc_ccode   TYPE char4   VALUE '1103',                         " Ccode of type CHAR4
             lc_enhancement_no TYPE z_enhancement VALUE 'D2_OTC_FDD_0013', " Enhancement No.
             lc_bukrs          TYPE z_criteria    VALUE 'BUKRS',           " Enh. Criteria
             lc_bukrs_ch       TYPE z_criteria    VALUE 'BUKRS_CH',        " Enh. Criteria
             lc_ktokd          TYPE z_criteria    VALUE 'KTOKD',           " Enh. Criteria
             lc_null           TYPE z_criteria    VALUE 'NULL',            "Enh. Criteria
             lc_eq             TYPE bapioption    VALUE 'EQ',              "Selection operator OPTION for range tables
             lc_remit_field    TYPE string        VALUE 'LV_REMIT_TO_L',   "Remit field name
* <--- End   of Insert for Defect#1997, D2_OTC_FDD_0013 by KBANSAL.
* ---> Begin of Change for D3_OTC_FDD_0013 by NALI
             lc_generic        TYPE char01  VALUE '*', " Generic of type CHAR01
             lc_check_ind      TYPE char01  VALUE 'X', " Check_ind of type CHAR01
             lc_comma          TYPE char01  VALUE ',', " Comma
             lc_addr_type      TYPE ad_adrtype  VALUE '1',
* <--- End of Change for D3_OTC_FDD_0013 by NALI
* ---> Begin of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
             lc_clearing       TYPE z_criteria  VALUE 'CLEARING', " Enhancement Criteria
             lc_country        TYPE z_criteria  VALUE 'COUNTRY',  " Enhancement Criteria
             lc_default        TYPE char08      VALUE 'DEFAULT',  " DEFAULT constant
* <--- End of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
*---> Begin of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
             lc_param_bukrs    TYPE enhee_parameter VALUE 'Z_REMIT_TO_ADDRESS', " Parameter
             lc_vtweg          TYPE vtweg       VALUE '10',                     " Distribution Channel
             lc_spart          TYPE spart       VALUE '00',                     " Division
             lc_english        TYPE spras       VALUE 'E'.                      " Language Key
*<--- End of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018

*Local Variables
  DATA: li_lines TYPE STANDARD TABLE OF tline INITIAL SIZE 0, " SAPscript: Text Lines
         lwa_lines1 TYPE tline,                               " SAPscript: Text Lines
         lv_lines1 TYPE string,                               "Local Variable
         lv_lines2 TYPE string,                               "Local Variable
         lv_lines3 TYPE string,                               "Local Variable
         lv_lines4 TYPE string,                               "Local Variable
         lv_lines5 TYPE string,                               "Local Variable
         lv_lines6 TYPE string,                               "Local Variable
         lv_lines7 TYPE string,                               "Local Variable
         lv_lines8 TYPE string,                               "Local Variable
* ---> Begin of Insert for Defect#1997, D2_OTC_FDD_0013 by KBANSAL.
         li_status TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
         lv_remit_to_l1 TYPE string,                       "For non 1103 company code
         lv_remit_to_l2 TYPE string,                       "For non 1103 company code
         lv_remit_to_l3 TYPE string,                       "For non 1103 company code
         lv_city        TYPE string,                       "City
         lv_street_hnum TYPE string,                       "Street and house no
         lv_pobox       TYPE string,                       "PO box
         lv_field_name  TYPE string,                       "field name
         lv_index       TYPE char_02,                      "Line coune
*---> Begin of Change for D3_OTC_FDD_0013 by NALI
         lv_check_d3    TYPE char01,  "Flag for LockBox Address
         lv_tvko_adrnr  TYPE adrnr,   "Address from Sales Organisation
         lv_tlfxs       TYPE tlfxs,   " Accounting clerk's fax number at the customer/vendor
         lv_intad       TYPE intad,   " Internet address of partner company clerk
         lv_ktokd       TYPE ktokd,   "Customer Account Group
         lv_vtweg       TYPE vtweg,   "Distribution Channel
         lv_tvko_country  TYPE land1, "Country
*<--- End of Change for D3_OTC_FDD_0013 by NALI
* ---> Begin of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
         lv_clr_txt     TYPE tdobname,                           " Standard text name for Clearing
         lv_iban1       TYPE char10,                             " Char10
         lv_iban2       TYPE char12,                             " Char12
         lv_iban3       TYPE char02,                             " Char02
         lwa_fr_bankinfo  TYPE zotc_housebank,                   " Structure for House Bank Info
         li_fr_bankinfo   TYPE STANDARD TABLE OF zotc_housebank, " Structure for House Bank Info
* <--- End of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
* ---> Begin of Insert for D3_OTC_FDD_0013_CR#301 by SGHOSH
         li_housebank   TYPE zotc_t_housebank,
* <--- End of Insert for D3_OTC_FDD_0013_CR#301 by SGHOSH

*---> Begin of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018

        li_bukrs          TYPE STANDARD TABLE OF lty_bukrs INITIAL SIZE 0,
        li_adrnr          TYPE STANDARD TABLE OF lty_adrnr INITIAL SIZE 0,
        lwa_housebank     TYPE zotc_housebank, " Structure for House Bank Info
        lwa_bukrs         TYPE lty_bukrs,      "Work Area for company code
        lwa_adrnr         TYPE lty_adrnr,      "Work area for address number
        lwa_adrc          TYPE lty_adrc,       "Work Area for ADRC table
        lv_knvv_curr      TYPE waers_v02d,     " Currency
        lv_remit_bukrs1   TYPE vkbuk,          " Sales Organization 2052
        lv_mail_bukrs2    TYPE vkbuk,          " Sales Organization 2068
        lv_email          TYPE ad_smtpadr,     " E-Mail Address
        lv_lines9         TYPE string,         "Local Variable
        lv_lines10        TYPE string,         "Local Variable
        lv_cust_langu     TYPE spras,          " Language Key
        lv_country_name   TYPE string,         "Customer Country Name
        lv_custcntry_name TYPE landx.          "Country Name

*<--- End of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018

  FIELD-SYMBOLS: <lfs_status>     TYPE zdev_enh_status, " Enhancement Status

* ---> Begin of Change for D3_OTC_FDD_0013_CR#356 by u034087
                 <lfs_housebank>  TYPE zotc_housebank, " Structure for House Bank Info
* <--- End of Change for D3_OTC_FDD_0013_CR#356 by u034087
* ---> Begin of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
                 <lfs_bank_country>      TYPE zotc_housebank,  " Structure for House Bank Info
                 <lfs_status_clr>        TYPE zdev_enh_status, " Enhancement Status
                 <lfs_status_default>    TYPE zdev_enh_status, " Enhancement Status
* <--- End of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
                 <lfs_address>    TYPE string, "address line
*---> Begin of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
                 <lfs_address1>    TYPE string, "address line
*<--- End of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
*---> Begin of Change for D3_OTC_FDD_0013 by NALI
                 <lfs_status_d3>     TYPE zdev_enh_status, " Enhancement Status
                 <lfs_status_ktokd>  TYPE zdev_enh_status. " Enhancement Status
*<--- End of Change for D3_OTC_FDD_0013 by NALI
* <--- End   of Insert for Defect#1997, D2_OTC_FDD_0013 by KBANSAL.
*&--Fetch Organization Address
*Since this address data need not to be printed in case of spanish statement,only
*Standard text data need to be printed.we are keeping this check.
*if the logon language is other then spanish we need to print this data on form.

*---> Begin of Delete for Defect# 4271(2nd change), D2_OTC_FDD_0013 BY NBAIS
*  IF sy-langu NE lc_spanish.
*<--- End of Delete for Defect# 4271(2nd change), D2_OTC_FDD_0013 BY NBAIS

* ---> Begin of Insert for Defect#1997, D2_OTC_FDD_0013 by KBANSAL.
* Get constants from EMI tools
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
  IF sy-subrc EQ 0.

*check if li_status is not initial after deleting the inactive
*entries
    IF li_status[] IS NOT INITIAL.
      READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_bukrs
                                                           sel_low  = t001-bukrs
                                                           sel_high = lc_spanish. " Nisha
      IF sy-subrc EQ 0.
*          IF <lfs_status>-sel_high = lc_spanish.
*      IF t001-bukrs IN lr_bukrs_range.
        lx_org_address = ''.
        lv_comp_adrnr = ''.
*Need to print the standard text in case of spanish language only.
*Remit to Address
*To Read the Standard text  ZOTC_FDD_ACCOUNT_PESOS
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = lc_id "ID
*---> Begin of change for Defect# 4271(2nd change), D2_OTC_FDD_0013 BY NBAIS
* As the standard text will be print as per the Country Code we will pass fp_docparams-langu instead of sy-langu.
            language                = fp_docparams-langu "sy-langu  "Lang
*<--- End of change for Defect# 4271(2nd change), D2_OTC_FDD_0013 BY NBAIS
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
            id                      = lc_id "Id

*---> Begin of change for Defect# 4271(2nd change), D2_OTC_FDD_0013 BY NBAIS
* As the standard text will be print as per the Country Code we will pass fp_docparams-langu instead of sy-langu.
            language                = fp_docparams-langu "sy-langu  "Lang
*<--- End of change for Defect# 4271(2nd change), D2_OTC_FDD_0013 BY NBAIS
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

      ELSE. " ELSE -> IF sy-subrc EQ 0
        SELECT adrnr "Address No.
            UP TO 1 ROWS
          INTO lv_comp_adrnr
          FROM t049l " Lockboxes at our House Banks
         WHERE bukrs = t001-bukrs.
        ENDSELECT.
        IF sy-subrc = 0.
*---> Begin of Delete for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
*&--This part is commented since we have to fetch Address based on the company codes.

** Add PO_BOX into address
*          SELECT  addrnumber       "Address
*                        name1      "Name 1
*                        name2      "Name 2
*                        house_num1 "House Number
*                        street     "Street
*                        city1      "City
*                        city2      "District
*                        region     "Region (State, Province, County)
*                        post_code1 "City postal code
*                        country    "Country Key
*                        tel_number "First telephone no.: dialling code+number
*                        fax_number "First fax no.: dialling code+number
*                        po_box     " PO Box
*                        UP TO 1 ROWS
*                        FROM adrc  " Addresses (Business Address Services)
*                        INTO lx_org_address
*                       WHERE addrnumber = lv_comp_adrnr.
*
*          ENDSELECT.
*          IF sy-subrc = 0.
** PO BOX + NAME2
*            IF NOT lx_org_address-po_box IS INITIAL.
*              CONCATENATE 'P.O. Box'(001) lx_org_address-po_box lx_org_address-name2
*                  INTO lv_pobox SEPARATED BY space.
*            ELSEIF  lx_org_address-name2 IS NOT INITIAL.
*              lv_pobox = lx_org_address-name2.
*            ENDIF. " IF NOT lx_org_address-po_box IS INITIAL
*
*            IF lx_org_address-hnum1 IS NOT INITIAL.
*              CONCATENATE lx_org_address-hnum1
*                          lx_org_address-street
*                     INTO lv_street_hnum
*             SEPARATED BY space.
*            ELSE. " ELSE -> IF lx_org_address-hnum1 IS NOT INITIAL
*              lv_street_hnum = lx_org_address-street.
*            ENDIF. " IF lx_org_address-hnum1 IS NOT INITIAL
*
*            CONCATENATE lx_org_address-city1
*                        lx_org_address-region
*                        space
*                        lx_org_address-pcode1
*                   INTO lv_city
*           SEPARATED BY space.
*
** We need to compress if data is not there, eg, if name1 is not there
** then in place of name1, po box+name2 should be printed. The java script to hide
**in adobe form is not working.
*            lv_index = 1.
*            CONCATENATE lc_remit_field lv_index INTO lv_field_name.
*            ASSIGN (lv_field_name) TO <lfs_address>.
*
**populating internal table for company address.
**Name1
*            IF lx_org_address-name1 IS NOT INITIAL.
*              IF <lfs_address> IS ASSIGNED.
*                <lfs_address> = lx_org_address-name1.
** prepare field symbol for next address line
*                lv_index = lv_index + 1.
*                CONCATENATE lc_remit_field lv_index INTO lv_field_name.
*                ASSIGN (lv_field_name) TO <lfs_address>.
*              ENDIF. " IF <lfs_address> IS ASSIGNED
*
*            ENDIF. " IF lx_org_address-name1 IS NOT INITIAL
*
** PO box + Name 2
*            IF lx_org_address-po_box IS NOT INITIAL.
*              IF <lfs_address> IS ASSIGNED.
*                <lfs_address> = lv_pobox.
** prepare field symbol for next address line
*                lv_index = lv_index + 1.
*                CONCATENATE lc_remit_field lv_index INTO lv_field_name.
*                ASSIGN (lv_field_name) TO <lfs_address>.
*
*              ENDIF. " IF <lfs_address> IS ASSIGNED
*
*            ENDIF. " IF lx_org_address-po_box IS NOT INITIAL
** Street and house number
*            IF lv_street_hnum IS NOT INITIAL.
*              IF <lfs_address> IS ASSIGNED.
*                <lfs_address> = lv_street_hnum.
** prepare field symbol for next address line
*                lv_index = lv_index + 1.
*                CONCATENATE lc_remit_field lv_index INTO lv_field_name.
*                ASSIGN (lv_field_name) TO <lfs_address>.
*              ENDIF. " IF <lfs_address> IS ASSIGNED
*
*            ENDIF. " IF lv_street_hnum IS NOT INITIAL
*
*            IF   lv_city IS NOT INITIAL.
*              IF <lfs_address> IS ASSIGNED.
*                <lfs_address> = lv_city. "city.
** prepare field symbol for next address line
*                lv_index = lv_index + 1.
*                CONCATENATE lc_remit_field lv_index INTO lv_field_name.
*                ASSIGN (lv_field_name) TO <lfs_address>.
*              ENDIF. " IF <lfs_address> IS ASSIGNED
*
*            ENDIF. " IF lv_city IS NOT INITIAL
*          ENDIF. " IF sy-subrc = 0
*<--- End of Delete for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018

*---> Begin of Change for D3_OTC_FDD_0013 by NALI
        ELSE. " ELSE -> IF sy-subrc = 0
*&--If no Loackbox address found from T049L, set the d3 flag
          CLEAR lv_check_d3.
          lv_check_d3 = abap_true.
*<--- End of Change for D3_OTC_FDD_0013 by NALI
        ENDIF. " IF sy-subrc = 0

*&--Fetch Company Address
*            SELECT adrnr "Address No.
*                UP TO 1 ROWS
*              INTO lv_comp_adrnr
*              FROM t049l " Lockboxes at our House Banks
*             WHERE bukrs = t001-bukrs.
*            ENDSELECT.
*If the logon language is spanish then pass this data as space
* only standard text data needs to be printed.

      ENDIF. " IF sy-subrc EQ 0
*        ENDIF. " IF sy-subrc EQ 0    "Delete NISHA
    ENDIF. " IF li_status[] IS NOT INITIAL
  ENDIF. " IF sy-subrc EQ 0
* <--- End   of Insert for Defect#1997, D2_OTC_FDD_0013 by KBANSAL.

*---> Begin of Delete for Defect# 4271 (2nd Change), D2_OTC_FDD_0013 BY NBAIS
* As the standard text is getting printed based on the company code this part is not reuired.
*  ELSE. " ELSE -> IF <lfs_address> IS ASSIGNED
*    lx_org_address = ''.
*    lv_comp_adrnr = ''.
** ---> Begin of D2 Change for D2_OTC_FDD_0013 by NSAXENA.
**Need to print the standard text in case of spanish language only.
**Remit to Address
**To Read the Standard text  ZOTC_FDD_ACCOUNT_PESOS
*    CALL FUNCTION 'READ_TEXT'
*      EXPORTING
*        id                      = lc_id     "ID
*        language                = fp_docparams-langu "sy-langu  "Lang
*        name                    = lc_name1  "Text Name
*        object                  = lc_object "object id
*      TABLES
*        lines                   = li_lines
*      EXCEPTIONS
*        id                      = 1
*        language                = 2
*        name                    = 3
*        not_found               = 4
*        object                  = 5
*        reference_check         = 6
*        wrong_access_to_archive = 7
*        OTHERS                  = 8.
*    IF sy-subrc EQ 0.
**To Read the text lines
*      LOOP AT li_lines ASSIGNING <lfs_lines>.
*        IF sy-tabix EQ 1.
*          lv_lines1 = <lfs_lines>-tdline.
*        ELSEIF sy-tabix EQ 2.
*          lv_lines2 = <lfs_lines>-tdline.
*        ELSEIF sy-tabix EQ 3.
*          lv_lines3 = <lfs_lines>-tdline.
*        ELSE. " ELSE -> IF sy-tabix EQ 1
*          lv_lines4 = <lfs_lines>-tdline.
*        ENDIF. " IF sy-tabix EQ 1
*      ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
*    ENDIF. " IF sy-subrc EQ 0
*    REFRESH li_lines.
**To Read Standard Text -  ZOTC_FDD_ACCOUNT_DOLLARS
*    CALL FUNCTION 'READ_TEXT'
*      EXPORTING
*        id                      = lc_id     "Id
**---> Begin of Insert for Defect # 4271(2nd change),  D2_OTC_FDD_0013 BY NBAIS
*        language                = fp_docparams-langu "sy-langu  "language
**<--- End of Insert for Defect # 4271(2nd change),  D2_OTC_FDD_0013 BY NBAIS
*        name                    = lc_name2  "Text Name
*        object                  = lc_object "Object Id
*      TABLES
*        lines                   = li_lines
*      EXCEPTIONS
*        id                      = 1
*        language                = 2
*        name                    = 3
*        not_found               = 4
*        object                  = 5
*        reference_check         = 6
*        wrong_access_to_archive = 7
*        OTHERS                  = 8.
*    IF sy-subrc EQ 0.
**To Read text lines
*      LOOP AT li_lines ASSIGNING <lfs_lines>.
*        IF sy-tabix EQ 1.
*          lv_lines5 = <lfs_lines>-tdline.
*        ELSEIF sy-tabix EQ 2.
*          lv_lines6 = <lfs_lines>-tdline.
*        ELSEIF sy-tabix EQ 3.
*          lv_lines7 = <lfs_lines>-tdline.
*        ELSE. " ELSE -> IF sy-tabix EQ 1
*          lv_lines8 = <lfs_lines>-tdline.
*        ENDIF. " IF sy-tabix EQ 1
*      ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
*    ENDIF. " IF sy-subrc EQ 0
*    REFRESH li_lines.
*    UNASSIGN <lfs_lines>.
**---> End of D2 Change for D2_OTC_FDD_0013 by NSAXENA.
*<--- End of delete for Defect# 4271 2nd Change, D2_OTC_FDD_0013 BY NBAIS

*---> Begin of Delete for Defect # 4271(2nd change),  D2_OTC_FDD_0013 BY NBAIS
*  ENDIF. " IF sy-langu NE lc_spanish
*<--- End of delete for Defect# 4271 (2nd Change), D2_OTC_FDD_0013 BY NBAIS

*&--Fetch Customer Address
  SELECT SINGLE adrnr "Address No.
*---> Begin of Change for D3_OTC_FDD_0013 by NALI
                ktokd
*<--- End of Change for D3_OTC_FDD_0013 by NALI
           INTO (lv_cust_adrnr,
*---> Begin of Change for D3_OTC_FDD_0013 by NALI
                lv_ktokd)
*<--- End of Change for D3_OTC_FDD_0013 by NALI
           FROM kna1 " General Data in Customer Master
          WHERE kunnr = save_kunnr.

  SELECT SINGLE kkber "Credit Control area
         sbgrp        "Credit Control group
* ---> Begin of delete for Defect# 1997, D2_OTC_FDD_0013 by KBANSAL.
*   UP TO 1 ROWS
* <--- End   of delete for Defect# 1997, D2_OTC_FDD_0013 by KBANSAL.
    INTO (lv_crd_area, lv_sbgrp)
    FROM knkk " Customer master credit management: Control area data
   WHERE kunnr = save_kunnr
     AND kkber = t001-kkber.
* ---> Begin of delete for Defect# 1997, D2_OTC_FDD_0013 by KBANSAL.
*  ENDSELECT.
* <--- End   of delete for Defect# 1997, D2_OTC_FDD_0013 by KBANSAL.
  IF sy-subrc = 0.

    SELECT SINGLE stext "Credit Rep Name
      FROM t024b        " Credit management: Credit representative groups
      INTO lv_crd_rep_name
     WHERE sbgrp = lv_sbgrp
* ---> Begin of Change for Defect# 1997, D2_OTC_FDD_0013 by KBANSAL.
*       AND kkber = lv_crd_area.       " Defect 1997
        AND kkber = t001-kkber. " Defect 1997
* <--- End   of change for Defect# 1997, D2_OTC_FDD_0013 by KBANSAL.

*---> Begin of Insert for D3R2 D3_OTC_FDD_0013 by SGHOSH
* For KNKK Select
  ENDIF. " IF sy-subrc = 0
*---> End of Insert for D3R2 D3_OTC_FDD_0013 by SGHOSH
*---> Begin of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
*&--Clearing the local variable and internal tables used.
  CLEAR: lv_remit_bukrs1.
  FREE: li_bukrs,
        li_adrnr.

*&--Fetching company code 2068 from ZOTC_PRC_CONTROL table for remit to address

  SELECT mvalue2           " Select Options: Value High
    UP TO 1 ROWS
     FROM zotc_prc_control " OTC Process Team Control Table
     INTO lv_remit_bukrs1
     WHERE vkorg = t001-bukrs
      AND mprogram   = lc_mprogram
      AND mparameter = lc_param_bukrs
      AND mactive    = abap_true
      AND soption    = lc_soption.
  ENDSELECT.

*****&-- Appending different Company Codes in an internal table for fetching Address
*    IF sy-subrc IS  INITIAL.
  IF lv_remit_bukrs1 IS NOT INITIAL.
    lwa_bukrs-bukrs = lv_remit_bukrs1.
    APPEND lwa_bukrs TO li_bukrs.
    CLEAR lwa_bukrs.
  ENDIF. " IF lv_remit_bukrs1 IS NOT INITIAL
*&-- Company Code for Email Address
  IF t001-bukrs IS NOT INITIAL.
    lwa_bukrs-bukrs = t001-bukrs.
    APPEND lwa_bukrs TO li_bukrs.
    CLEAR lwa_bukrs.
  ENDIF. " IF t001-bukrs IS NOT INITIAL

*<--- End of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018

* ---> Begin of Change for Defect# 1997, D2_OTC_FDD_0013 by KBANSAL.
*---> Begin of Change for D3_OTC_FDD_0013 by NALI
  CLEAR lv_tvko_adrnr.
*<--- End of Change for D3_OTC_FDD_0013 by NALI

*---> Begin of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018

*&--Fetching the address number from T001 table.
  IF li_bukrs IS NOT INITIAL.

    SELECT bukrs " Company code of the sales organization
           adrnr " Address
       FROM t001 " Organizational Unit: Sales Organizations
    INTO TABLE li_adrnr
    FOR ALL ENTRIES IN li_bukrs
    WHERE bukrs = li_bukrs-bukrs.

    IF sy-subrc IS INITIAL.
      SORT li_adrnr BY bukrs.

      READ TABLE li_adrnr INTO lwa_adrnr WITH KEY bukrs = t001-bukrs BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        lv_tvko_adrnr = lwa_adrnr-adrnr.
        lv_vkorg = lwa_adrnr-bukrs.

      ENDIF. " IF sy-subrc IS INITIAL

    ELSE. " ELSE -> IF sy-subrc IS INITIAL
*<--- End of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018

      SELECT vkorg     " Sales Organization
             adrnr     " Address
             UP TO 1 ROWS
             FROM tvko " Organizational Unit: Sales Organizations
             INTO (lv_vkorg, lv_tvko_adrnr)
        WHERE bukrs = t001-bukrs.
      ENDSELECT.
* <--- End   of change for Defect# 1997, D2_OTC_FDD_0013 by KBANSAL.

*---> Begin of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
    ENDIF. " IF sy-subrc IS INITIAL
*&--Reading local internal table to access the address number fetched from ADRC for different company codes
    READ TABLE li_adrnr INTO lwa_adrnr WITH KEY bukrs = lv_remit_bukrs1 BINARY SEARCH.
    IF sy-subrc IS INITIAL.

*&--Fetching data for email address for company code 2068. Since Email address will always
*be coming from 2068 company code.

      SELECT smtp_addr " E-Mail Address
             UP TO 1 ROWS
             FROM adr6 " E-Mail Addresses (Business Address Services)
             INTO lv_email
         WHERE addrnumber = lwa_adrnr-adrnr.
      ENDSELECT.
      IF sy-subrc IS INITIAL.
*  do nothing

      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_bukrs IS NOT INITIAL


*&--Fetching data for legal entity address for company code 2019
* Add PO_BOX into address
  SELECT       addrnumber  "Address
                name1      "Name 1
                name2      "Name 2
                house_num1 "House Number
                street     "Street
                city1      "City
                city2      "District
                region     "Region (State, Province, County)
                post_code1 "City postal code
                country    "Country Key
                tel_number "First telephone no.: dialling code+number
                fax_number "First fax no.: dialling code+number
                po_box     " PO Box
                langu      " Language Key
                UP TO 1 ROWS
                FROM adrc  " Addresses (Business Address Services)
                INTO lx_org_address
               WHERE addrnumber = lv_tvko_adrnr.

  ENDSELECT.
  IF sy-subrc = 0.
*first check for customer's language.
*&--Fetch country name from T005T table
    SELECT SINGLE landx                 "Country name
           FROM t005t                   "Country Names
           INTO lv_custcntry_name
       WHERE spras = fp_docparams-langu "lx_org_address-langu " As per Defcet 5228 suggested by Frank Sallai
       AND   land1 = lx_org_address-land1.
    IF sy-subrc IS NOT INITIAL.
*If not found check from company's language
*&--Fetch country name from T005T table
      SELECT SINGLE landx "Country name
             FROM t005t   "Country Names
             INTO lv_custcntry_name
         WHERE spras = t001-spras
         AND   land1 = lx_org_address-land1.
      IF sy-subrc IS NOT INITIAL.
*&--If not found , then country code name should print in English.
*&--Fetch country name from T005T table
        SELECT SINGLE landx "Country name
               FROM t005t   "Country Names
               INTO lv_custcntry_name
           WHERE spras = lc_english
           AND   land1 = lx_org_address-land1.
        IF sy-subrc IS INITIAL.
*&--do nothing.
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF sy-subrc IS NOT INITIAL
    ENDIF. " IF sy-subrc IS NOT INITIAL

* PO BOX + NAME2
    IF NOT lx_org_address-po_box IS INITIAL.
      CONCATENATE 'P.O. Box'(001) lx_org_address-po_box lx_org_address-name2
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
*&--Need to add country name for the legal entity address.
                lc_comma
                lv_custcntry_name
           INTO lv_city
   SEPARATED BY space.

* We need to compress if data is not there, eg, if name1 is not there
* then in place of name1, po box+name2 should be printed. The java script to hide
*in adobe form is not working.
    lv_index = 1.
    CONCATENATE lc_remit_field lv_index INTO lv_field_name.
    ASSIGN (lv_field_name) TO <lfs_address>.

*populating internal table for company address.
*Name1
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


*&--Logic should occur only for D3 countries.
  IF lv_check_d3 = abap_true.

*&--Fetching data for remit address for company code 2068
    IF li_bukrs IS NOT INITIAL.
      SELECT   addrnumber  "Address
                name1      "Name 1
                city1      "City
                post_code1 " City postal code
                street     "Street
                str_suppl2 " Street 3
                country    "Country key
                langu      " Language Key
                UP TO 1 ROWS
                FROM adrc  " Addresses (Business Address Services)
                INTO lwa_adrc
               WHERE addrnumber = lwa_adrnr-adrnr.

      ENDSELECT.
      IF sy-subrc = 0.

*&--Since the name1 of company code-2068 should come from current company code t001-bukrs
        IF lx_org_address-name1 IS NOT INITIAL.
          lv_lines1 = lx_org_address-name1.
        ENDIF. " IF lx_org_address-name1 IS NOT INITIAL

*---> Begin of Insert for D3_OTC_FDD_0013 Defect# 5228 by SMUKHER4 on 13-Mar-2018
*&--Legal enitity name should be concatenated with Name1 & Name2 separated by space.
        IF lx_org_address-name2 IS NOT INITIAL.
          CONCATENATE lv_lines1 lx_org_address-name2 INTO lv_lines1 SEPARATED BY space.
          CONDENSE lv_lines1.
        ENDIF. " IF lx_org_address-name2 IS NOT INITIAL
*<--- End of Insert for D3_OTC_FDD_0013 Defect# 5228 by SMUKHER4 on 13-Mar-2018

        IF lwa_adrc-str_suppl2 IS NOT INITIAL.
          lv_lines2 = lwa_adrc-str_suppl2.
        ENDIF. " IF lwa_adrc-str_suppl2 IS NOT INITIAL

        IF lwa_adrc-street IS NOT INITIAL.
          lv_lines3 = lwa_adrc-street.
        ENDIF. " IF lwa_adrc-street IS NOT INITIAL

        IF lwa_adrc-city1 IS NOT INITIAL.
          lv_lines4 = lwa_adrc-city1.
        ENDIF. " IF lwa_adrc-city1 IS NOT INITIAL

        IF lwa_adrc-post_code1 IS NOT INITIAL.
          lv_lines9 = lwa_adrc-post_code1.
        ENDIF. " IF lwa_adrc-post_code1 IS NOT INITIAL

*&--Fetching country name from T005T table for 2068 company code.
        SELECT SINGLE landx50                   " Country Name
               INTO lv_lines10
               FROM t005t                       " Country Names
*               WHERE spras = fp_docparams-langu "lwa_adrc-langu " As per Defcet 5228 suggested by Frank Sallai  " Defcet 5522
                WHERE spras = lwa_adrc-langu "Defect 5522
               AND   land1 = lwa_adrc-country.
        IF sy-subrc IS INITIAL.
*&--do nothing
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF li_bukrs IS NOT INITIAL
*&--Below part of code should work for D2 specific countries.
  ELSE. " ELSE -> IF lv_check_d3 = abap_true

    CLEAR: lv_lines1,
           lv_lines2,
           lv_lines3.

    lv_lines1 = lv_remit_to_l1.
    lv_lines2 = lv_remit_to_l2.
    lv_lines3 = lv_remit_to_l3.

  ENDIF. " IF lv_check_d3 = abap_true
*<--- End of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018

*---> Begin of Change for D3_OTC_FDD_0013 by NALI

*&--Get the Sener Country
  SELECT country " Country Key
    UP TO 1 ROWS
    FROM adrc    " Addresses (Business Address Services)
    INTO lv_tvko_country
    WHERE addrnumber  = lv_tvko_adrnr.
  ENDSELECT.

*---> Begin of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
*    ENDIF. " IF sy-subrc IS INITIAL
*&--Get the currency from customer master data table.
  CLEAR lv_knvv_curr.
  SELECT waers              " Currency
    UP TO 1 ROWS
    FROM knvv               " Customer Master Sales Data
    INTO lv_knvv_curr
    WHERE kunnr = save_kunnr
    AND   vkorg = t001-bukrs
    AND   vtweg = lc_vtweg  "'10'
    AND   spart = lc_spart. "'00'.
  ENDSELECT.
  IF sy-subrc IS INITIAL.
*&--do nothing.
  ENDIF. " IF sy-subrc IS INITIAL

*<--- End of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018

*---> Begin of Insert for D3R2 D3_OTC_FDD_0013 by SGHOSH
* For KNKK Select
*  ENDIF. " IF sy-subrc = 0
*---> End of Insert for D3R2 D3_OTC_FDD_0013 by SGHOSH

*&--If there is no T049L entry (lockbox address) maintained then
*    get the address from the sales organisation of the company
  IF lv_check_d3 = abap_true.
*&--Get the IBAN (Bank Account Info)

*---> Begin of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
*If customer currency is populated use that currency. Otherwise, fall back on the existing logic to send
*in the company code currency, T001-WAERS.

    IF lv_knvv_curr IS NOT INITIAL.

      CALL FUNCTION 'ZOTC_GET_HOUSEBANKINFO'
        EXPORTING
          im_bukrs = t001-bukrs
          im_curr  = lv_knvv_curr
        IMPORTING
          ex_out   = lwa_housebank.

    ELSE. " ELSE -> IF lv_knvv_curr IS NOT INITIAL

*<--- End of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018

      CALL FUNCTION 'ZOTC_GET_HOUSEBANKINFO'
        EXPORTING
          im_bukrs = t001-bukrs
          im_curr  = t001-waers
*---> Begin of Delete for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
*&--As per the new requirement, there will be always one bank account details , so the changing parameter has been commenetd.
* ---> Begin of Insert for D3_OTC_FDD_0013_CR#301 by SGHOSH
*            im_mult_housebank_info = abap_true
* <--- End of Insert for D3_OTC_FDD_0013_CR#301 by SGHOSH
*<--- End of Delete for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018

* ---> Begin of Delete for D3_OTC_FDD_0013_CR#301 by SGHOSH
* As per new logic multiple address need to be returned so this part has been
* commented and table is added in the changing parameter.
*        IMPORTING
*          ex_out   = lx_housebank_info.
* <--- End of Delete for D3_OTC_FDD_0013_CR#301 by SGHOSH
*---> Begin of Delete for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
* ---> Begin of Insert for D3_OTC_FDD_0013_CR#301 by SGHOSH
*           CHANGING
*             et_housebank = li_housebank.
* <--- End of Insert for D3_OTC_FDD_0013_CR#301 by SGHOSH
*<--- End of Delete for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
*---> Begin of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
*&--Since there always been one bank account, we are populating the details in the structure instead in a table
         IMPORTING
        ex_out                        = lwa_housebank.
*<--- End of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
* ---> Begin of Delete for D3_OTC_FDD_0013_CR#301 by SGHOSH
* Commented out as this logic is no more required
*&--Concatenate the House Bank Street and City in Line 2
*      CONCATENATE lx_housebank_info-stras
*                  lx_housebank_info-ort01
*                  INTO lv_housebank_line2
*                  SEPARATED BY lc_comma.
* <--- End of Delete for D3_OTC_FDD_0013_CR#301 by SGHOSH

*---> Begin of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018

    ENDIF. " IF lv_knvv_curr IS NOT INITIAL
*    ENDIF. " IF li_knvv IS NOT INITIAL
*<--- End of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018

* ---> Begin of Change for D3_OTC_FDD_0013_CR#356 by u034087

    LOOP AT li_housebank ASSIGNING <lfs_housebank>.
      CONDENSE <lfs_housebank>-iban NO-GAPS.
      lv_iban  = <lfs_housebank>-iban.
      lv_len   = strlen( lv_iban ).
      lv_count = ceil( lv_len / lc_v ).
      lv_var   = 0.
      lv_off   = 4.
      DO lv_count TIMES.
        CONCATENATE lv_iban_final
                    lv_iban+lv_var(lv_off)
                    INTO  lv_iban_final
                    SEPARATED BY space.
        lv_iban_fin_cond  = lv_iban_final.
        CONDENSE lv_iban_fin_cond NO-GAPS.
        IF strlen( lv_iban_fin_cond ) + 4 > lv_len.
          lv_off  = lv_len - strlen( lv_iban_fin_cond ).
        ELSE. " ELSE -> IF strlen( lv_iban_fin_cond ) + 4 > lv_len
          lv_off  = 4.
        ENDIF. " IF strlen( lv_iban_fin_cond ) + 4 > lv_len
        lv_var = lv_var + 4 .
      ENDDO.
* Check if there is any remaining character
      IF lv_var LT lv_len.
        CONCATENATE lv_iban_final
                    lv_iban+lv_var(lv_off)
                    INTO  lv_iban_final
                    SEPARATED BY space.
        lv_iban_fin_cond  = lv_iban_final.
        CONDENSE lv_iban_fin_cond NO-GAPS.
      ENDIF. " IF lv_var LT lv_len

      SHIFT lv_iban_final LEFT DELETING LEADING space.
      <lfs_housebank>-iban = lv_iban_final.
      CLEAR : lv_iban,
              lv_len,
              lv_count,
              lv_var,
              lv_iban_final.
* ---> Begin of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
      READ TABLE li_status  TRANSPORTING NO FIELDS  WITH KEY criteria = lc_country
                                                              sel_low = <lfs_housebank>-bank_country
                                                                   active = abap_true. " No Binary Search required as this table has few entries
      IF sy-subrc = 0.
        lv_iban = <lfs_housebank>-iban.
        CONDENSE lv_iban NO-GAPS.
        lv_iban1 = lv_iban+4(10).
        lv_iban2 = lv_iban+14(11).
        lv_iban3 = lv_iban+25(2).
        CONCATENATE lv_iban1
                    lv_iban2
                    lv_iban3
                    INTO lv_iban_final
                    SEPARATED BY space.
        lwa_fr_bankinfo-banka = lv_iban_final.
        lwa_fr_bankinfo-iban  = <lfs_housebank>-iban.
        APPEND lwa_fr_bankinfo  TO li_fr_bankinfo.
        CLEAR: lv_iban,
               lv_iban_final,
               lwa_fr_bankinfo,
               <lfs_housebank>-bankn,
               <lfs_housebank>-bank_key.
      ENDIF. " IF sy-subrc = 0
* <--- End of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI

    ENDLOOP. " LOOP AT li_housebank ASSIGNING <lfs_housebank>

* ---> Begin of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
    READ TABLE li_housebank ASSIGNING <lfs_bank_country>  INDEX 1.
    IF sy-subrc = 0.
      READ TABLE li_status  ASSIGNING <lfs_status_clr>  WITH KEY criteria = lc_clearing
                                                                 sel_low  = <lfs_bank_country>-bank_country
                                                                 active   = abap_true. " No Binary Search required as this table has few entries
      IF sy-subrc = 0.
        lv_clr_txt = <lfs_status_clr>-sel_high.
      ELSE. " ELSE -> IF sy-subrc = 0
        READ TABLE li_status ASSIGNING <lfs_status_default> WITH KEY criteria = lc_clearing
                                                                     sel_low  = lc_default
                                                                     active = abap_true. " No Binary Search required as this table has few entries
        IF sy-subrc = 0.
          lv_clr_txt  = <lfs_status_default>-sel_high.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0
* <--- End of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI

*&--Get all the standard texts which vary based on D2 or D3 sites.
    PERFORM f_get_texts USING lv_check_d3
                              fp_docparams-langu
* ---> Begin of Delete for D3_OTC_FDD_0013_CR#356_PartII by NALI
* ---> Begin of Change for D3_OTC_FDD_0013_CR#356 by NALI
*                              lv_tvko_country
* <--- End of Change for D3_OTC_FDD_0013_CR#356 by NALI
* <--- End of Delete for D3_OTC_FDD_0013_CR#356_PartII by NALI
* ---> Begin of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
                               lv_clr_txt
* <--- End of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
                        CHANGING lwa_standard_text.

**If 2001or 2002 or 2003, instead of Bank Address and City from
**bank master data (BNKA – BANKA (bank name), and - STRAS, ORT01
**(address) replaced with Standard Text - ZOTC_BANKADDR_FIRMA_CH
**in Language EN
    READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_bukrs_ch
                                                         sel_low  = t001-bukrs
                                                         sel_high = space. " No Binary Search required as this table has few entries
    IF sy-subrc = 0.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = lc_id
          language                = lc_en
          name                    = lc_name
          object                  = lc_object
        TABLES
          lines                   = li_banka_stras
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.
      IF sy-subrc = 0.
        CLEAR lv_line_banka.
        CLEAR lv_line_stras.
        LOOP AT li_banka_stras ASSIGNING <lfs_lines>.
          IF sy-tabix = 1.
            lv_line_banka = <lfs_lines>-tdline.
          ELSEIF sy-tabix = 2.
            lv_line_stras = <lfs_lines>-tdline.
          ENDIF. " IF sy-tabix = 1
        ENDLOOP. " LOOP AT li_banka_stras ASSIGNING <lfs_lines>
      ENDIF. " IF sy-subrc = 0

      LOOP AT li_housebank ASSIGNING <lfs_housebank>.
        <lfs_housebank>-banka = lv_line_banka.
        <lfs_housebank>-stras = lv_line_stras.
      ENDLOOP. " LOOP AT li_housebank ASSIGNING <lfs_housebank>

    ENDIF. " IF sy-subrc = 0


* <--- End of Change for D3_OTC_FDD_0013_CR#356 by u034087

*---> Begin of delete for D3_OTC_FDD_0013 Defect# 5228 by SMUKHER4 on 13-Mar-2018
*   CLEAR lx_org_address.
*<--- End of delete for D3_OTC_FDD_0013 Defect# 5228 by SMUKHER4 on 13-Mar-2018

    CLEAR lv_crd_rep_name. " Contact Name is not needed for D3
  ELSE. " ELSE -> IF lv_check_d3 = abap_true

* ---> Begin of Insert for D3_OTC_FDD_0013 Defect# 2379 by DMOIRAN on 04-Apr-2017
* To get labels for D1/D2 Company Code as well
    PERFORM f_get_texts USING lv_check_d3
                              fp_docparams-langu
                               lv_clr_txt
                        CHANGING lwa_standard_text.

    CLEAR lv_tvko_country.
* <--- End of Insert for D3_OTC_FDD_0013 Defect# 2379 by DMOIRAN on 04-Apr-2017

    CLEAR lv_tvko_adrnr.
  ENDIF. " IF lv_check_d3 = abap_true
*&--The Distribution Channel will be 90 for Customer Account Group ZICC, otherwise 10.
  IF li_status  IS NOT INITIAL.
    READ TABLE li_status  ASSIGNING <lfs_status_ktokd> WITH KEY criteria = lc_ktokd
                                                          active = abap_true. " No Binary Search required as this table has few entries
    IF sy-subrc = 0 AND lv_ktokd = <lfs_status_ktokd>-sel_low.
      READ TABLE li_status  ASSIGNING <lfs_status_d3>  WITH KEY criteria = lc_vtweg_90
                                                           active = abap_true. " No Binary Search required as this table has few entries
      IF sy-subrc = 0.
        lv_vtweg = <lfs_status_d3>-sel_low.
      ENDIF. " IF sy-subrc = 0
    ELSE. " ELSE -> IF sy-subrc = 0 AND lv_ktokd = <lfs_status_ktokd>-sel_low
      READ TABLE li_status  ASSIGNING <lfs_status_d3>  WITH KEY criteria = lc_vtweg_10
                                                               active = abap_true. " No Binary Search required as this table has few entries
      IF sy-subrc = 0.
        lv_vtweg = <lfs_status_d3>-sel_low.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0 AND lv_ktokd = <lfs_status_ktokd>-sel_low
  ENDIF. " IF li_status IS NOT INITIAL
  IF lv_check_d3 = abap_false.
*<--- End of Change for D3_OTC_FDD_0013 by NALI
*&--Fetch data from Process Control Table
    SELECT mvalue2          "Credit Rep Phone Number
      UP TO 1 ROWS
      FROM zotc_prc_control " OTC Process Team Control Table
      INTO lv_crd_rep_phone
*     WHERE vkorg      = lc_vkorg      " Defect 1997
     WHERE vkorg      = lv_vkorg " Defect 1997
*---> Begin of Change for D3_OTC_FDD_0013 by NALI
*       AND vtweg      = lc_vtweg
       AND vtweg      = lv_vtweg
*<--- End of Change for D3_OTC_FDD_0013 by NALI
       AND mprogram   = lc_mprogram
       AND mparameter = lc_param_phone
       AND mactive    = abap_true
       AND soption    = lc_soption
       AND mvalue1    = lv_sbgrp.
    ENDSELECT.
*---> Begin of Change for D3_OTC_FDD_0013 by NALI
  ELSE. " ELSE -> IF lv_check_d3 = abap_false
*&--Get the Payer Country Code
    IF lv_cust_adrnr IS NOT INITIAL.
      SELECT country " Country Key
*---> Begin of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
             langu " Language key
*<--- End of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
        UP TO 1 ROWS
        FROM adrc " Addresses (Business Address Services)
        INTO
*---> Begin of delete for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
*        lv_cust_country
*<--- End of delete for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
*---> Begin of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
        (lv_cust_country,lv_cust_langu)
*<--- End of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
        WHERE addrnumber = lv_cust_adrnr.
      ENDSELECT.
*---> Begin of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
*&--First check for customer's language code for getting country name
*&--Get the country name from T005T table.
      SELECT SINGLE landx " Country Name
          FROM t005t      " Country Names
        INTO lv_country_name
        WHERE spras = lv_cust_langu
        AND   land1 = lv_cust_country.
      IF sy-subrc IS NOT INITIAL.
*&--If not found check for country's language code for getting country name
*&--Get the country name from T005T table.
        SELECT SINGLE landx " Country Name
            FROM t005t      " Country Names
          INTO lv_country_name
          WHERE spras = t001-spras
          AND   land1 = lv_cust_country.
        IF sy-subrc IS NOT INITIAL.
*&--If not found country name should check for English language.
*&--Get the country name from T005T table.
          SELECT SINGLE landx " Country Name
              FROM t005t      " Country Names
            INTO lv_country_name
            WHERE spras = lc_english
            AND   land1 = lv_cust_country.
          IF sy-subrc IS INITIAL.
*&--do nothing.

          ENDIF. " IF sy-subrc IS INITIAL
        ENDIF. " IF sy-subrc IS NOT INITIAL
      ENDIF. " IF sy-subrc IS NOT INITIAL
*<--- End of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
    ENDIF. " IF lv_cust_adrnr IS NOT INITIAL
*&-- Get the Contact Phone Number
    SELECT mvalue2        "Credit Rep Phone Number
    UP TO 1 ROWS
    FROM zotc_prc_control " OTC Process Team Control Table
    INTO lv_crd_rep_phone
      WHERE vkorg      = lv_vkorg
        AND vtweg      = lv_vtweg
        AND mprogram   = lc_mprogram
        AND mparameter = lc_param_phone
        AND mactive    = abap_true
        AND soption    = lc_soption
        AND mvalue1    = lv_cust_country.
    ENDSELECT.
*&-- If no entry found then look up by generic *
    IF sy-subrc <> 0  AND lv_crd_rep_phone IS INITIAL.
      SELECT mvalue2        "Credit Rep Phone Number
      UP TO 1 ROWS
      FROM zotc_prc_control " OTC Process Team Control Table
      INTO lv_crd_rep_phone
       WHERE vkorg      = lv_vkorg
         AND vtweg      = lv_vtweg
         AND mprogram   = lc_mprogram
         AND mparameter = lc_param_phone
         AND mactive    = abap_true
         AND soption    = lc_soption
         AND mvalue1    = lc_generic.
      ENDSELECT.
    ENDIF. " IF sy-subrc <> 0 AND lv_crd_rep_phone IS INITIAL
  ENDIF. " IF lv_check_d3 = abap_false
*<--- End of Change for D3_OTC_FDD_0013 by NALI
* ---> Begin of Delete for D3R2 for D3_OTC_FDD_0013 by SGHOSH
* ENDIF for KNKK select failure is shifted above to keep housebank details population separate from it
*  ENDIF. " IF sy-subrc = 0
* ---> End of Delete for D3R2 for D3_OTC_FDD_0013 by SGHOSH
  lt_open_item[] = fp_lt_item[].
*&--Delete all cleared items from tha table
  DELETE lt_open_item WHERE corrid NE lc_open_ind.

*&--If there is no data to display then append message to log
  IF lt_open_item[] IS INITIAL.
    MESSAGE 'No data for display'(214) TYPE lc_status.
    CLEAR fimsg.
    fimsg-msort = lc_msort.
    fimsg-msgid = lc_dev_msg.
    fimsg-msgty = lc_error.
    fimsg-msgno = lc_msgno_003.
    fimsg-msgv1 = 'No data for display'(214).
    PERFORM message_append.
    EXIT.
  ENDIF. " IF lt_open_item[] IS INITIAL


  IF NOT save_fm_name IS INITIAL.
* call the generated function module

    CALL FUNCTION save_fm_name
      EXPORTING
        /1bcdwb/docparams  = fp_docparams
        im_org_address     = lx_org_address
        im_company_adrnr   = lv_comp_adrnr
        im_customer_adrnr  = lv_cust_adrnr
*---> Begin of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
        im_customer_email  = lv_email
*<--- End of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
        im_customer_no     = save_kunnr
        im_credit_contact  = lv_crd_rep_name
        im_credit_phone    = lv_crd_rep_phone
        lt_item            = lt_open_item
        lt_rtab            = fp_lt_rtab
* ---> Begin of D2 Change for D2_OTC_FDD_0013 by NSAXENA.
        im_pesos_1         = lv_lines1 "Text lines
        im_pesos_2         = lv_lines2 "Text lines
        im_pesos_3         = lv_lines3 "Text lines
        im_pesos_4         = lv_lines4 "Text lines
*---> Begin of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
        im_pesos_5         = lv_lines9       "Text lines
        im_pesos_6         = lv_lines10      "Text lines
        im_cust_country    = lv_country_name "Customer Country Name
        im_cust_langu      = lv_cust_langu   "Customer Language
        im_comp_langu      = t001-spras      "Company Code language
        im_t001_bukrs      = t001-bukrs      "COmpany code
        im_d3_flag         = lv_check_d3     "D3 Flag
*<--- End of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
        im_dollar_1        = lv_lines5 "Text lines
        im_dollar_2        = lv_lines6 "Text lines
        im_dollar_3        = lv_lines7 "Text lines
        im_dollar_4        = lv_lines8 "Text lines
* ---> Begin of delete for Defect# 1997, D2_OTC_FDD_0013 by DMOIRAN.
        im_remit_l1        = lv_remit_to_l1
        im_remit_l2        = lv_remit_to_l2
        im_remit_l3        = lv_remit_to_l3
* <--- End   of change for Defect# 1997, D2_OTC_FDD_0013 by DMOIRAN.
* ---> End of D2 Change for D2_OTC_FDD_0013 by NSAXENA.
* ---> Begin of Changes for Defect# 4271, D2_OTC_FDD_0013 by KBANSAL.
       im_gv_langu_bi       = fp_gv_langu_bi
*<--- End of Changes for Defect# 4271, D2_OTC_FDD_0013 BY KBANSAL.
* ---> Begin of Change for D3_OTC_FDD_0013 by NALI
        im_d3_sender_country    = lv_tvko_country
        im_d3_remit_to_address  = lv_tvko_adrnr
* ---> Begin of Delete for D3_OTC_FDD_0013_CR#301 by SGHOSH
* Commented out as now multiple records will be returned in table form instead of structure
*        im_x_housebank     = lx_housebank_info
*        im_housebank_line2 = lv_housebank_line2
* <--- End of Delete for D3_OTC_FDD_0013_CR#301 by SGHOSH
* ---> Begin of Insert for D3_OTC_FDD_0013_CR#301 by SGHOSH
        im_t_housebank = li_housebank
* <--- End of Insert for D3_OTC_FDD_0013_CR#301 by SGHOSH
*---> Begin of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
        im_housebank  = lwa_housebank
*<--- End of Insert for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
* ---> Begin of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
        im_t_fr_bankinfo = li_fr_bankinfo
* <--- End of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
        im_x_standard_text = lwa_standard_text
* <--- End of Change for D3_OTC_FDD_0013 by NALI
    IMPORTING
      /1bcdwb/formoutput = lx_formout
    EXCEPTIONS
      usage_error        = 1
      system_error       = 2
      internal_error     = 3
      OTHERS             = 4.
    IF sy-subrc <> 0.
      PERFORM message_pdf.
    ELSE. " ELSE -> IF sy-subrc <> 0
      IF lx_formout-pdf IS NOT INITIAL.

*&--Remove leading zeros from Customer
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = save_kunnr
          IMPORTING
            output = lv_kunnr.

*&--Mail Content
        CONCATENATE text-217 kna1-name1 text-218 lv_kunnr
               INTO lwa_content-line SEPARATED BY space.
        APPEND INITIAL LINE TO lt_content.
        APPEND lwa_content TO lt_content.
        CLEAR lwa_content.

        IF sy-batch = 'X'. "Defect # 3453, Send email only in background processing
*---> Begin of Change for D3_OTC_FDD_0013 by NALI
*&--Get the clerk's fax number and internet address
          CLEAR lv_tlfxs.
          CLEAR lv_intad.
          SELECT SINGLE tlfxs " Accounting clerk's fax number at the customer/vendor
                        intad " Internet address of partner company clerk
            FROM knb1         " Customer Master (Company Code)
            INTO (lv_tlfxs, lv_intad)
            WHERE kunnr = save_kunnr
            AND   bukrs = t001-bukrs.
*<--- End of Change for D3_OTC_FDD_0013 by NALI
*&--Send Mail/Fax/Print

          CALL FUNCTION 'ZOTC_STANDARD_COMMUNICATION'
            EXPORTING
              im_adrnr         = lv_cust_adrnr
              im_subject       = 'Statement from Bio-Rad Labs'(208)
              im_t_text        = lt_content
              im_form_output   = lx_formout
*---> Begin of Change for D3_OTC_FDD_0013 by NALI
              im_tlfxs         = lv_tlfxs
              im_intad         = lv_intad
              im_adrnr_sender  = lv_tvko_adrnr
*<--- End of Change for D3_OTC_FDD_0013 by NALI
            IMPORTING
              ex_status        = lv_status
              ex_print_doc     = xprint
            EXCEPTIONS
              no_email_address = 1
              no_fax_number    = 2
              mail_failure     = 3
              fax_failure      = 4
              OTHERS           = 5.

          IF sy-subrc = 1.
*&--If E-mail address not maintained
            CLEAR fimsg.
            fimsg-msort = lc_msort.
            fimsg-msgid = lc_dev_msg.
            fimsg-msgty = lc_error.
            fimsg-msgno = lc_msgno_003.
            fimsg-msgv1 = 'For Customer'(209).
            fimsg-msgv2 = save_kunnr.
            fimsg-msgv3 = 'E-mail Address is not Maintained'(210).
            PERFORM message_append.

          ELSEIF sy-subrc = 2.
*&--If Fax Number not maintained
            CLEAR fimsg.
            fimsg-msort = lc_msort.
            fimsg-msgid = lc_dev_msg.
            fimsg-msgty = lc_error.
            fimsg-msgno = lc_msgno_003.
            fimsg-msgv1 = 'For Customer'(209).
            fimsg-msgv2 = save_kunnr.
            fimsg-msgv3 = 'Fax Number is not Maintained'(211).
            PERFORM message_append.

          ELSEIF sy-subrc = 3.
*&--If E-mail sending failed
            CLEAR fimsg.
            fimsg-msort = lc_msort.
            fimsg-msgid = lc_dev_msg.
            fimsg-msgty = lc_error.
            fimsg-msgno = lc_msgno_003.
            fimsg-msgv1 = 'For Customer'(209).
            fimsg-msgv2 = save_kunnr.
            fimsg-msgv3 = 'E-mail sending failed'(212).
            PERFORM message_append.

          ELSEIF sy-subrc = 4.
*&--If Fax sending failed
            CLEAR fimsg.
            fimsg-msort = lc_msort.
            fimsg-msgid = lc_dev_msg.
            fimsg-msgty = lc_error.
            fimsg-msgno = lc_msgno_003.
            fimsg-msgv1 = 'For Customer'(209).
            fimsg-msgv2 = save_kunnr.
            fimsg-msgv3 = 'Fax sending failed'(213).
            PERFORM message_append.

          ELSEIF sy-subrc = 5.
*&--Other Exception
            fimsg-msort = lc_msort.
            fimsg-msgid = lc_dev_msg.
            fimsg-msgty = lc_error.
            fimsg-msgno = lc_msgno_003.
            fimsg-msgv1 = 'Exception occured while sending E-mail / Fax'(215).
            PERFORM message_append.
          ENDIF. " IF sy-subrc = 1
        ELSE. " ELSE -> IF sy-batch = 'X'
          fimsg-msort = lc_msort.
          fimsg-msgid = lc_dev_msg.
          fimsg-msgty = lc_error.
          fimsg-msgno = lc_msgno_003.
          fimsg-msgv1 = 'No data for display in PDF Output'(216). " Indicator whether Data Should be Displayed or not
          PERFORM message_append.

        ENDIF. " IF sy-batch = 'X'
      ENDIF. " IF lx_formout-pdf IS NOT INITIAL
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF NOT save_fm_name IS INITIAL

ENDFORM. " F_ADOBE_FORM_PROCESSING

************************************************************************
*  End of changes for PDF generation
*  Copy of Standard Include RFKORI16PDF
*----------------------------------------------------------------------*
*  User      Transport
*----------------------------------------------------------------------*
*  VGAUR     E1DK901190
************************************************************************
*---> Begin of Changes for Defect# 4271, D2_OTC_FDD_0013 By KBANSAL.
*&---------------------------------------------------------------------*
*&      Form  F_LANGUAGE
*&---------------------------------------------------------------------*
*      Changing value of structure FP_DOCPARAMS
*----------------------------------------------------------------------*
*       -->FP_DOCPARAMS   Form Output Parameters
*       -->GV_LANGU_BI   Language Parameter
*----------------------------------------------------------------------*


FORM f_language  CHANGING fp_docparams         TYPE  sfpdocparams " Form Parameters for Form Processing
                          fp_gv_langu_bi       TYPE  spras.       " Language Key of Current Text Environment

  DATA:   li_status TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
          lv_langu          TYPE  spras,                    " Language Key
          lv_langu_bi       TYPE  spras.                    " Language Key

  CONSTANTS:   lc_enhancement_no TYPE z_enhancement VALUE 'D2_OTC_FDD_0013', " Enhancement No.
               lc_bukrs          TYPE z_criteria    VALUE 'BUKRS',           " Enh. Criteria
               lc_null           TYPE z_criteria    VALUE 'NULL',            "Enh. Criteria
               lc_english        TYPE spras         VALUE 'E',               " Language Key
* ---> Begin of Change for D3_OTC_FDD_0013 by NALI
               lc_spanish        TYPE spras         VALUE 'S', " Language Key
               lc_french         TYPE spras         VALUE 'F', " Language Key
               lc_german         TYPE spras         VALUE 'D', " language Key
* <--- End of Change for D3_OTC_FDD_0013 by NALI
* ---> Begin of Change for D3R2 D3_OTC_FDD_0013 by SGHOSH
               lc_danish         TYPE spras         VALUE 'K', " Language Key
               lc_finnish        TYPE spras         VALUE 'U', " Language Key
               lc_norwegian      TYPE spras         VALUE 'O', " Language Key
               lc_swedish        TYPE spras         VALUE 'V', " Language Key
* ---> End of Change for D3R2 D3_OTC_FDD_0013 by SGHOSH
*---> Begin of Changes for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
               lc_italy          TYPE spras         VALUE 'I', " Language Key
               lc_portugal       TYPE spras         VALUE 'P'. " Language Key
*<--- End of Changes for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018


  FIELD-SYMBOLS: <lfs_status> TYPE zdev_enh_status. " Enhancement Status

  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enhancement_no "D2_OTC_FDD_0013
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
*Read table li_status for Company Code 1020 and 1103
    IF sy-subrc EQ 0.

      IF <lfs_status>-sel_high CS '_'.
* Check Select-high constains string '_'. if yes split the value of Select-high and pass it to
*two diffrent variables (GV_LANGU_BI, FP_DOCPARAMS-Langu) and bind the standard texts in forms with these
*varables.
        SPLIT <lfs_status>-sel_high AT '_' INTO lv_langu
                                                lv_langu_bi.

        fp_docparams-langu = lv_langu_bi.
        fp_gv_langu_bi     = lv_langu.
      ELSE. " ELSE -> IF <lfs_status>-sel_high CS '_'
        fp_docparams-langu = <lfs_status>-sel_high.
      ENDIF. " IF <lfs_status>-sel_high CS '_'
* ---> Begin of Change for D3_OTC_FDD_0013 by NALI
    ELSEIF fp_docparams-langu <> lc_german AND fp_docparams-langu <> lc_spanish AND fp_docparams-langu <> lc_french
* ---> Begin of Change for D3R2 D3_OTC_FDD_0013 by SGHOSH
           AND fp_docparams-langu <> lc_danish AND fp_docparams-langu <> lc_finnish AND fp_docparams-langu <> lc_norwegian AND fp_docparams-langu <> lc_swedish
* <--- End of Change for D3_R3 D3_OTC_FDD_0013 by SGHOSH
*---> Begin of Changes for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018
           AND fp_docparams-langu <> lc_italy AND fp_docparams-langu <> lc_portugal.
*<--- End of Changes for D3R3 D3_OTC_FDD_0013 by SMUKHER4 on 25-Jan-2018

      fp_docparams-langu  = lc_english.
* <--- End of Change for D3_OTC_FDD_0013 by NALI
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_status[] IS NOT INITIAL
ENDFORM. " F_LANGUAGE
*<--- End of Changes for Defect# 4271, D2_OTC_FDD_0013 By KBANSAL.
*---> Begin of Change for D3_OTC_FDD_0013 by NALI
*&---------------------------------------------------------------------*
*&      Form  F_GET_TEXTS
*&---------------------------------------------------------------------*
*       Get the Standrd Text names based on site (D2 or D3)
*----------------------------------------------------------------------*
*      -->FP_LV_CHECK_D3      D3 flag
*      --->FP_LANGU           Form Language
*      --->FP_CLR_TXT         Standard Text for Clearing
*      <--FP_X_STANDARD_TEXT  Standard Texts
*----------------------------------------------------------------------*
FORM f_get_texts  USING    fp_lv_check_d3 TYPE char01 " D3 Flag
                           fp_langu       TYPE spras  " Form Language
* ---> Begin of Delete for D3_OTC_FDD_0013_CR#356_PartII by NALI
* ---> Begin of Change for D3_OTC_FDD_0013_CR#356 by NALI
*                           fp_country     TYPE land1 " Country
* <--- End of Change for D3_OTC_FDD_0013_CR#356 by NALI
* <--- End of Delete for D3_OTC_FDD_0013_CR#356_PartII by NALI
* ---> Begin of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
                           fp_clr_txt     TYPE tdobname " Standard text for Clearing
* <--- End of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
                  CHANGING fp_x_standard_text TYPE zotc0013_st_list. " Structure for Standard Texts for Form OTC_FDD_0013
  CONSTANTS: lc_langu_de  TYPE langu  VALUE 'D',        "German Language
             lc_suffix_eu TYPE char10 VALUE '_0013_EU'. "Suffix for the D3 Standard Texts.
  IF fp_lv_check_d3 = abap_true.
*&--Get the SO10 text names with suffix _0013_EU for D3 specific texts
    PERFORM f_populate_text  USING lc_suffix_eu
* ---> Begin of Delete for D3_OTC_FDD_0013_CR#356_PartII by NALI
* ---> Begin of Change for D3_OTC_FDD_0013_CR#356 by NALI
*                                   fp_country
* <--- End of Change for D3_OTC_FDD_0013_CR#356 by NALI
* <--- End of Delete for D3_OTC_FDD_0013_CR#356_PartII by NALI
* ---> Begin of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
                                   fp_clr_txt
* <--- End of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
                                  CHANGING fp_x_standard_text.
  ELSEIF fp_lv_check_d3 = abap_false AND  fp_langu <> lc_langu_de.
*&--Get the D1/D2 existing SO10 text names
    PERFORM f_populate_text  USING ' '
* ---> Begin of Delete for D3_OTC_FDD_0013_CR#356_PartII by NALI
* ---> Begin of Change for D3_OTC_FDD_0013_CR#356 by NALI
*                                   fp_country
* <--- End of Change for D3_OTC_FDD_0013_CR#356 by NALI
* <--- End of Delete for D3_OTC_FDD_0013_CR#356_PartII by NALI
* ---> Begin of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
                                   fp_clr_txt
* <--- End of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
                                  CHANGING fp_x_standard_text.
  ELSEIF fp_lv_check_d3 = abap_false AND  fp_langu = lc_langu_de.
*&--Get the German Translations of all SO10 Texts independent of D1-D2 or D3 sites
    PERFORM f_populate_text  USING lc_suffix_eu
* ---> Begin of Delete for D3_OTC_FDD_0013_CR#356_PartII by NALI
* ---> Begin of Change for D3_OTC_FDD_0013_CR#356 by NALI
*                                   fp_country
* <--- End of Change for D3_OTC_FDD_0013_CR#356 by NALI
* <--- End of Delete for D3_OTC_FDD_0013_CR#356_PartII by NALI
* ---> Begin of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
                                   fp_clr_txt
* <--- End of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
                                  CHANGING fp_x_standard_text.
  ENDIF. " IF fp_lv_check_d3 = abap_true


ENDFORM. " F_GET_TEXTS
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_TEXT
*&---------------------------------------------------------------------*
*       Populate the Text Names to pass to the Form
*----------------------------------------------------------------------*
*      -->FP_SUFFIX           Suffix for D3 Standard Text Names
*      -->FP_CLR_TXT          Standard text name for Clearing
*      <--FP_X_STANDARD_TEXT  Structure for Standrd Texts
*----------------------------------------------------------------------*
FORM f_populate_text  USING    fp_suffix  TYPE char10 " Populate_text_name usin of type CHAR10
* ---> Begin of Delete for D3_OTC_FDD_0013_CR#356_PartII by NALI
* ---> Begin of Change for D3_OTC_FDD_0013_CR#356 by NALI
*                               fp_country TYPE land1 " Country
* <--- End of Change for D3_OTC_FDD_0013_CR#356 by NALI
* <--- End of Delete for D3_OTC_FDD_0013_CR#356_PartII by NALI
* ---> Begin of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
                               fp_clr_txt TYPE tdobname " Standard Text name
* <--- End of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
                           CHANGING fp_x_standard_text TYPE zotc0013_st_list. " Structure for Standard Texts for Form OTC_FDD_0013
  CONSTANTS:  lc_customer_statement TYPE  tdobname  VALUE 'ZOTC_CUSTOMER_STATEMENT', " Name
              lc_remit_to TYPE  tdobname  VALUE 'ZOTC_REMIT_TO',                     " Name
              lc_page TYPE  tdobname  VALUE 'ZOTC_PAGE',                             " Name
              lc_of TYPE  tdobname  VALUE 'ZOTC_OF',                                 " Name
              lc_customer_number  TYPE  tdobname  VALUE 'ZOTC_CUSTOMER_NUMBER',      " Name
              lc_creditpt_contact TYPE  tdobname  VALUE 'ZOTC_CREDIT_DEPT_CONTACT',  " Name
              lc_statement_date TYPE  tdobname  VALUE 'ZOTC_STATEMENT_DATE',         " Name
              lc_transaction_date TYPE  tdobname  VALUE 'ZOTC_TRANSACTION_DATE',     " Name
              lc_po_number  TYPE  tdobname  VALUE 'ZOTC_PO_NUMBER',                  " Name
              lc_charges  TYPE  tdobname  VALUE 'ZOTC_CHARGES',                      " Name
              lc_credits  TYPE  tdobname  VALUE 'ZOTC_CREDITS',                      " Name
              lc_amount_due TYPE  tdobname  VALUE 'ZOTC_AMOUNT_DUE',                 " Name
              lc_currency TYPE  tdobname  VALUE 'ZOTC_CURRENCY',                     " Name
              lc_invoice_number TYPE  tdobname  VALUE 'ZOTC_INVOICE_NUMBER',         " Name
              lc_over_90  TYPE  tdobname  VALUE 'ZOTC_OVER_90',                      " Name
* ---> Begin of Change for D3_OTC_FDD_0013_CR#356 by u034087
              lc_de       TYPE land1     VALUE 'DE',              " Country Key
              lc_at       TYPE land1     VALUE 'AT',              " Country Key
              lc_ch       TYPE land1     VALUE 'CH',              " Country Key
              lc_clearing TYPE tdobname  VALUE 'ZOTC_CLEARING',   " Name
              lc_sort_code TYPE tdobname  VALUE 'ZOTC_SORT_CODE', " Name
              lc_blz TYPE tdobname  VALUE 'ZOTC_BLZ',             " Name
* <--- End of Change for D3_OTC_FDD_0013_CR#356 by u034087
              lc_total_balance_due  TYPE  tdobname  VALUE 'ZOTC_TOTAL_BALANCE_DUE'. " Name


*&--CUSTOMER_STATEMENT
  CONCATENATE
              lc_customer_statement
              fp_suffix
              INTO fp_x_standard_text-customer_statement.
  CONDENSE fp_x_standard_text-customer_statement.

*&--REMIT_TO
  CONCATENATE
              lc_remit_to
              fp_suffix
              INTO fp_x_standard_text-remit_to.
  CONDENSE fp_x_standard_text-remit_to.


*&--PAGE
  CONCATENATE
              lc_page
              fp_suffix
              INTO fp_x_standard_text-page1.
  CONDENSE fp_x_standard_text-page1.

*&--OF
  CONCATENATE
              lc_of
              fp_suffix
              INTO fp_x_standard_text-of1.
  CONDENSE fp_x_standard_text-of1.


*&--CUSTOMER_NUMBER
  CONCATENATE
              lc_customer_number
              fp_suffix
              INTO fp_x_standard_text-customer_number.
  CONDENSE fp_x_standard_text-customer_number.


*&--CREDITPT_CONTACT
  CONCATENATE
              lc_creditpt_contact
              fp_suffix
              INTO fp_x_standard_text-credit_dept_contact.
  CONDENSE fp_x_standard_text-credit_dept_contact.

*&--STATEMENT_DATE
  CONCATENATE
              lc_statement_date
              fp_suffix
              INTO fp_x_standard_text-statement_date.
  CONDENSE fp_x_standard_text-statement_date.

*&--TRANSACTION_DATE
  CONCATENATE
              lc_transaction_date
              fp_suffix
              INTO fp_x_standard_text-transaction_date.
  CONDENSE fp_x_standard_text-transaction_date.

*&--PO_NUMBER
  CONCATENATE
              lc_po_number
              fp_suffix
              INTO fp_x_standard_text-po_number.
  CONDENSE fp_x_standard_text-po_number.

*&--CHARGES
  CONCATENATE
              lc_charges
              fp_suffix
              INTO fp_x_standard_text-charges.
  CONDENSE fp_x_standard_text-charges.

*&--CREDITS
  CONCATENATE
              lc_credits
              fp_suffix
              INTO fp_x_standard_text-credits.
  CONDENSE fp_x_standard_text-credits.

*&--AMOUNT_DUE
  CONCATENATE
              lc_amount_due
              fp_suffix
              INTO fp_x_standard_text-amount_due.
  CONDENSE fp_x_standard_text-amount_due.

*&--CURRENCY
  CONCATENATE
              lc_currency
              fp_suffix
              INTO fp_x_standard_text-currency.
  CONDENSE fp_x_standard_text-currency.

*&--INVOICE_NUMBER
  CONCATENATE
              lc_invoice_number
              fp_suffix
              INTO fp_x_standard_text-invoice_number.
  CONDENSE fp_x_standard_text-invoice_number.

*&--OVER_90
  CONCATENATE
              lc_over_90
              fp_suffix
              INTO fp_x_standard_text-over_90.
  CONDENSE fp_x_standard_text-over_90.


*&--TOTAL_BALANCE_DUE
  CONCATENATE
              lc_total_balance_due
              fp_suffix
              INTO fp_x_standard_text-total_balance_due.
  CONDENSE fp_x_standard_text-total_balance_due.
* ---> Begin of Delete for D3_OTC_FDD_0013_CR#356_PartII by NALI

*
** ---> Begin of Change for D3_OTC_FDD_0013_CR#356 by u034087
*  IF fp_country = lc_de OR fp_country = lc_at.
*    CONCATENATE
*                lc_blz
*                ' '
*                INTO fp_x_standard_text-clearing.
*    CONDENSE fp_x_standard_text-clearing.
*  ELSEIF fp_country = lc_ch.
*    CONCATENATE
*                lc_clearing
*                fp_suffix
*                INTO fp_x_standard_text-clearing.
*    CONDENSE fp_x_standard_text-clearing.
*  ELSE.
*    CONCATENATE
*                lc_sort_code
*                ' '
*                INTO fp_x_standard_text-clearing.
*    CONDENSE fp_x_standard_text-clearing.
*
*  ENDIF. " IF fp_country = lc_uk
** <--- End of Change for D3_OTC_FDD_0013_CR#356 by u034087
* <--- End of Delete for D3_OTC_FDD_0013_CR#356_PartII by NALI
* ---> Begin of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI
  CONCATENATE
              fp_clr_txt
              ' '
              INTO fp_x_standard_text-clearing.
  CONDENSE fp_x_standard_text-clearing.
* <--- End of Change for D3_OTC_FDD_0013_CR#356_PartII by NALI

ENDFORM. " F_POPULATE_TEXT
*<--- End of Change for D3_OTC_FDD_0013 by NALI
