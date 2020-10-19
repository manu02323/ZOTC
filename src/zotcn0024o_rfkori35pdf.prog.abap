************************************************************************
* PROGRAM    :  ZOTCN0024O_RFKORI35PDF                                 *
* TITLE      :  OTC_FDD_0024: Print program for Debit/Credit form      *
* DEVELOPER  :  Gautam NAG                                             *
* OBJECT TYPE:  PRINT PROGRAM                                          *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_FDD_0024                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: This include is called form the main print program      *
*              RFKORD50_PDF and contains the data processing for email *
*              sending functionality                                   *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 24-SEP-2013 GNAG     E1DK911667 INITIAL DEVELOPMENT - CR#768         *
*&---------------------------------------------------------------------*

***INCLUDE RFKORI35 .

*-------Includes für syntax-check---------------------------------------
*NCLUDE RFKORI00.
*nCLUDE RFKORI80.
*NCLUDE RFKORI90.

*=======================================================================
*       Interne Perform-Routinen
*=======================================================================

*-----------------------------------------------------------------------
*       FORM AUSGABE_BELEGAUSZUG
*-----------------------------------------------------------------------
FORM ausgabe_belegauszug_pdf.

* Begin of change - GNAG CR#768
  CONSTANTS:
    lc_msort       TYPE msort              VALUE '    ',     "Sort field for messages
    lc_dev_msg     TYPE symsgid            VALUE 'ZDEV_MSG', "Dev Message Class
    lc_error       TYPE symsgty            VALUE 'E',        "Error
    lc_msgno_003   TYPE msgtyp             VALUE '003',      "Message No.
    lc_corrid_oil  TYPE rfkord_item_corrid VALUE 'OIL',      "Correspondence: ID
    lc_credit_memo TYPE char20             VALUE 'Credit Memo', "Text: Credit memo
    lc_debit_memo  TYPE char20             VALUE 'Debit Memo',  "Text: Debit memo
    lc_tvarvc_blart TYPE RVARI_VNAM        VALUE 'Z_OTC_FDD_0024_BLART'.  " STVARV Name

  DATA: lv_cust_adrnr TYPE adrnr,             "Customer Address
        lv_attachment_name TYPE so_obj_des,   "Attachment name
        lwa_item TYPE rfkord_s_item,          "Line item
        lx_formoutput TYPE fpformoutput,      "Form output for email/fax
        lr_blart TYPE RANGE OF blart.         " Range table for tvarvc
* End of change - GNAG CR#768

  DATA:
       ls_header   TYPE rfkord_s_header,
       ls_address  TYPE rfkord_s_address,
       ls_item     TYPE rfkord_s_item,
       ls_sum      TYPE rfkord_s_sum,
       ls_rtab     TYPE rfkord_s_rtab,
       ls_item_alw TYPE rfkord_s_item_alw,

       lt_address  TYPE rfkord_t_address,
       lt_item     TYPE rfkord_t_item,
       lt_sum      TYPE rfkord_t_sum,
       lt_rtab     TYPE rfkord_t_rtab,
       lt_paymo    TYPE rfkord_t_paymo.

  DATA:
       ls_adrs       TYPE adrs,
       ls_adrs_print TYPE adrs_print,
       fp_docparams  TYPE sfpdocparams,
       error_string  TYPE string.

  DATA:
       co_tax_item               TYPE rfkord_item_corrid VALUE 'TAX',
       co_open_item              TYPE rfkord_item_corrid VALUE 'OIL',
       co_total_clearing_item    TYPE rfkord_item_corrid VALUE 'TCL',
       co_tax_item1              TYPE rfkord_item_corrid VALUE 'TX1',
       co_rfkord_rec             TYPE rfkord_item_corrid VALUE 'REC',
       co_supplier_address       TYPE rfkord_item_corrid VALUE 'VEN',
       co_customer_branch_address  TYPE rfkord_address_corrid VALUE
                                                  'BRC',
       co_vendor_branch_address  TYPE rfkord_address_corrid VALUE 'BRV'.


  IF  xkausg IS INITIAL.
*-------Adressen einlesen-----------------------------------------------
*   PERFORM FIND_EMPFAENGER_ADRESSE.
***<<<pdf-enabling
*   SAPScript logic for language determination can't be used
    language = save_langu.
***>>>pdf-enabling


    IF NOT xadrs IS INITIAL.
      PERFORM aufbereitung_bukrsadresse.
*-------START FORMULAR--------------------------------------------------
*      PERFORM FORM_START_BA.
      IF NOT save_fm_name IS INITIAL.
        save_bukrs = hdbukrs.
        PERFORM read_t001s.
        IF  NOT save_kunnr IS INITIAL
        AND NOT save_lifnr IS INITIAL.
          PERFORM read_t001s_2.
          dkad2-sname = *t001s-sname.
        ENDIF.
        save_usnam = hdusnam.
        PERFORM pruefen_husr03_2.
        IF xvorh2 IS INITIAL.
          PERFORM read_usr03_2.
          CLEAR husr03.
          MOVE-CORRESPONDING *usr03 TO husr03.              "USR0340A
          APPEND husr03.
        ENDIF.
        LOOP AT hbkpf
          WHERE bukrs = hdbukrs.
          EXIT.
        ENDLOOP.
        MOVE-CORRESPONDING hbkpf TO bkpf.
         *bkpf = bkpf.
        alw_waers = bkpf-waers.
        PERFORM currency_get_subsequent
                    USING
                       save_repid
                       bkpf-budat
                       bkpf-bukrs
                    CHANGING
                       alw_waers.
        IF alw_waers NE bkpf-waers.
          bkpf-waers = alw_waers.
        ENDIF.
        save_blart = bkpf-blart.
        PERFORM read_t003t.
        save_usnam = bkpf-usnam.
        PERFORM pruefen_husr03.
        IF xvorh2 IS INITIAL.
          PERFORM read_usr03.
          CLEAR husr03.
          MOVE-CORRESPONDING usr03 TO husr03.               "USR0340A
          APPEND husr03.
        ENDIF.

*       perform fill_bltxt.

        countm = countm + 1.

        CLEAR rf140-spras.
        rf140-spras = language.

****<<<    commented for pdf conversion

**        CALL FUNCTION 'WRITE_FORM'
**                         EXPORTING  WINDOW    = 'ADDRESS'
**                         EXCEPTIONS WINDOW    = 1.
**                             UNOPENED  = 3
**                             UNSTARTET = 4.
**                         IF SY-SUBRC = 1.
**                           WINDOW = 'ADDRESS'.
**                           PERFORM MESSAGE_WINDOW.
**                         ENDIF.
**                        IF SY-SUBRC = 3.
**                          PERFORM MESSAGE_UNOPENED.
**                        ENDIF.
**                        IF SY-SUBRC = 4.
**                          PERFORM MESSAGE_UNSTARTED.
**                        ENDIF.
****>>>    commented for pdf conversion


***pdf enabling
*-------------------------------header,address------------------------*
        MOVE-CORRESPONDING dkadr TO ls_adrs.
        IF NOT dkadr-adrnr IS INITIAL.
          CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
            EXPORTING
              address_type      = '1'
              address_number    = dkadr-adrnr
              sender_country    = dkadr-inlnd
            IMPORTING
              address_printform = ls_adrs_print.

*         fill receiver address information into header
          MOVE-CORRESPONDING ls_adrs_print TO ls_header.
*         also provide address information in address
          MOVE-CORRESPONDING ls_adrs_print TO ls_address.
        ELSE.
          MOVE-CORRESPONDING dkadr TO ls_adrs.
          CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
            EXPORTING
              adrswa_in                    = ls_adrs
            IMPORTING
              adrswa_out                   = ls_adrs
*           NUMBER_OF_USED_LINES
            EXCEPTIONS
              OTHERS = 1.
*         fill receiver address information into header
          MOVE-CORRESPONDING ls_adrs TO ls_header.
*         also provide address information in address
          MOVE-CORRESPONDING ls_adrs TO ls_address.
        ENDIF.

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

*   enrich address-structure with masterdata
        ls_address-corrid = co_rfkord_rec.   "receiveraddress
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


*   standardtexts (HEADER; FOOTER etc.)
        MOVE t001g-txtko TO ls_header-txtko.
        MOVE t001g-txtfu TO ls_header-txtfu.
        MOVE t001g-txtun TO ls_header-txtun.
        MOVE t001g-txtab TO ls_header-txtab.

        MOVE t001g-sender TO ls_header-sender.
        MOVE t001g-footer TO ls_header-footer.
        MOVE t001g-header TO ls_header-header.
        MOVE t001g-logo   TO ls_header-logo.
        MOVE t001g-greetings TO ls_header-greetings.
        MOVE t001g-graph TO ls_header-graph.


        IF save_rxopol IS INITIAL.
*=> ID (account statement)
          ls_header-corrid = co_rfkord_ast. "account statement
        ELSE.
*=> ID (open item list)
          ls_header-corrid = co_rfkord_oil. "open item list
        ENDIF.

* language
        CLEAR ls_header-spras.
        ls_header-spras = language.

* Dates (from-, to- and key-date)
        ls_header-date_from = rf140-datu1.
        ls_header-date_to = rf140-datu2.
        ls_header-key_date = rf140-stida.
        ls_header-vstid = rf140-vstid.

* individual text
        ls_header-tdname = rf140-tdname.
        ls_header-tdspras = rf140-tdspras.

        APPEND ls_address TO lt_address.

*-------------------------------header completed-----------------------*
        CLEAR rf140-stenr.
        CLEAR t001z.
        IF save_koart = 'K'.
          rf140-stenr = lfa1-stenr.
        ELSE.
          SELECT SINGLE * FROM t001z
            WHERE party = 'SAP011'
            AND   bukrs = bkpf-bukrs.
          rf140-stenr = t001z-paval.
        ENDIF.

        IF NOT dkadr-eikto IS INITIAL
        OR NOT dkadr-zsabe IS INITIAL.
          ereignis = '505'.
        ELSE.
          ereignis = '506'.
        ENDIF.
        CLEAR rf140-element.
        rf140-element = ereignis.

****<<<    commented for pdf conversion
**        CALL FUNCTION 'WRITE_FORM'
**                         EXPORTING  WINDOW    = 'INFO'
**                                    ELEMENT   = EREIGNIS
**                                    FUNCTION  = 'APPEND'
**                         EXCEPTIONS WINDOW    = 1
**                                    ELEMENT   = 2.
**                         IF SY-SUBRC = 1.
**                           WINDOW = 'INFO'.
**                           PERFORM MESSAGE_WINDOW.
**                         ENDIF.
**                         IF SY-SUBRC = 2.
**                           WINDOW = 'INFO'.
**                           PERFORM MESSAGE_ELEMENT.
**                         ENDIF.
****>>>    commented for pdf conversion

*-------Anschreiben text------------------------------------------------
        CLEAR countz.
        IF NOT save_kunnr IS INITIAL.
          LOOP AT hextractd
            WHERE kont1 = save_kunnr.
            countz = countz + 1.
          ENDLOOP.
          DESCRIBE TABLE hextractd LINES linecnt.
        ENDIF.
        IF NOT save_lifnr IS INITIAL.
          LOOP AT hextractk
            WHERE kont1 = save_lifnr.
            countz = countz + 1.
          ENDLOOP.
          DESCRIBE TABLE hextractk LINES linecnt.
        ENDIF.
        IF countz = '1'.
          IF save_koart = 'D'.
*           IF SAVE_LIFNR IS INITIAL.
            ereignis = '510'.
*           ELSE.
**            message
*           ENDIF.
          ENDIF.
          IF save_koart = 'K'.
            ereignis = '512'.
          ENDIF.
        ELSE.
          IF save_koart = 'D'.
            IF save_lifnr IS INITIAL.
              ereignis = '511'.
            ELSE.
              ereignis = '514'.
            ENDIF.
          ENDIF.
          IF save_koart = 'K'.
            ereignis = '513'.
          ENDIF.
        ENDIF.
        CLEAR rf140-element.
        rf140-element = ereignis.

****<<<    commented for pdf conversion
**        CALL FUNCTION 'WRITE_FORM'
**                         EXPORTING  WINDOW    = 'MAIN'
**                                    ELEMENT   = EREIGNIS
**                         EXCEPTIONS WINDOW    = 1
**                                    ELEMENT   = 2.
**                         IF SY-SUBRC = 1.
**                           WINDOW = 'MAIN'.
**                           PERFORM MESSAGE_WINDOW.
**                         ENDIF.
**                         IF SY-SUBRC = 2.
**                           WINDOW = 'MAIN'.
**                           PERFORM MESSAGE_ELEMENT.
**                         ENDIF.
****>>>    commented for pdf conversion

        CLEAR rf140-element.
        rf140-element = '520'.
****<<<    commented for pdf conversion
**        CALL FUNCTION 'WRITE_FORM'
**                 EXPORTING  WINDOW    = 'MAIN'
**                            ELEMENT   = '520'
**                 EXCEPTIONS WINDOW    = 1
**                            ELEMENT   = 2.
**                 IF SY-SUBRC = 1.
**                   WINDOW = 'MAIN'.
**                   PERFORM MESSAGE_WINDOW.
**                 ENDIF.
**                 IF SY-SUBRC = 2.
**                   WINDOW = 'MAIN'.
**                   EREIGNIS = '520'.
**                   PERFORM MESSAGE_ELEMENT.
**                 ENDIF.
****>>>    commented for pdf conversion

        CLEAR tbslt.
        CLEAR rf140-gsaldf.
        CLEAR rf140-waers.
         *rf140 = rf140.
        rf140-waers  = bkpf-waers.
         *rf140-waers = *bkpf-waers.

        LOOP AT hbseg.
          MOVE-CORRESPONDING hbseg TO bseg.
          PERFORM sortierung USING 'P' '1' ' '.
          hbseg-sortp1 = sortp1.
          hbseg-sortp2 = sortp2.
          hbseg-sortp3 = sortp3.
          hbseg-sortp4 = sortp4.
          hbseg-sortp5 = sortp5.
          MODIFY hbseg.
        ENDLOOP.
        SORT hbseg BY bukrs sortp1 sortp2 sortp3 sortp4 sortp5
                      belnr gjahr buzei.
        LOOP AT hbseg.
*         WHERE BUKRS = SAVE_BUKRS.
          save_bukrs  = hbseg-bukrs.
          IF  ( hbseg-kunnr = save_kunnr
          AND   NOT save_kunnr IS INITIAL )
          OR  ( hbseg-lifnr = save_lifnr
          AND   NOT save_lifnr IS INITIAL ).
            CLEAR bseg.
            MOVE-CORRESPONDING hbseg TO bseg.
             *bseg = bseg.
            IF bkpf-waers NE *bkpf-waers.
              PERFORM curr_document_convert_bseg
                          USING
                             bkpf-budat
                             *bkpf-waers
                             *bkpf-hwaer
                             bkpf-waers
                          CHANGING
                             bseg.
              IF NOT bseg-pycur IS INITIAL.
                alw_waers = bseg-pycur.
                PERFORM currency_get_subsequent
                            USING
                               save_repid
                               bkpf-budat
                               bkpf-bukrs
                            CHANGING
                               alw_waers.
                IF alw_waers NE bseg-pycur.
                  bseg-pycur = alw_waers.
                  PERFORM convert_foreign_to_foreign_cur
                              USING
                                 bkpf-budat
                                 *bkpf-waers
                                 *bkpf-hwaer
                                 bseg-pycur
                              CHANGING
                                 bseg-pyamt.
                ENDIF.
              ENDIF.
            ENDIF.


            PERFORM fill_waehrungsfelder_bseg_2.

            IF bseg-sgtxt(1) NE '*'.
              bseg-sgtxt = space.
            ELSE.
              bseg-sgtxt = bseg-sgtxt+1.
            ENDIF.

***<<<pdf enabling
            MOVE-CORRESPONDING bkpf TO ls_item.
            MOVE-CORRESPONDING bseg TO ls_item.

*            ls_item-sgtxt = BSEG-SGTXT.
*            ls_item-belnr = BSEG-BELNR.
*            ls_item-rebzg = BSEG-REBZG.

***>>>pdf enabling

            PERFORM fill_waehrungsfelder_bseg.
***<<<pdf enabling
            ls_item-wrshb = rf140-wrshb.
            ls_item-dmshb = rf140-dmshb.
            ls_item-wsshb = rf140-wsshb.
            ls_item-skshb = rf140-skshb.
            ls_item-wsshv = rf140-wsshv.
            ls_item-skshv = rf140-skshv.

***>>>pdf enabling



            CLEAR save_bschl.
            CLEAR save_umskz.
            CLEAR tbslt.
            save_bschl = bseg-bschl.
            save_umskz = bseg-umskz.
            PERFORM read_tbslt.
            rf140-gsaldf = rf140-gsaldf + rf140-wrshb.
             *rf140-gsaldf = *rf140-gsaldf + *rf140-wrshb.

            IF  xmultk IS INITIAL
            AND xactiv IS INITIAL
            AND linecnt = '1'
            AND NOT      xumsst IS INITIAL
            AND NOT save_xumstn IS INITIAL.
              IF bkpf-bstat = 'V'.
                PERFORM read_vbset.
              ELSE.
                PERFORM read_bset.
              ENDIF.
              DESCRIBE TABLE hbset LINES linecnt.
              IF linecnt = '1'.
                LOOP AT hbset.
                  MOVE-CORRESPONDING hbset TO bset.
                   *bset = bset.
                  IF bkpf-waers NE *bkpf-waers.
                    PERFORM curr_document_convert_bset
                                USING
                                   bkpf-budat
                                   *bkpf-waers
                                   *bkpf-hwaer
                                   bkpf-waers
                                CHANGING
                                   bset.
                  ENDIF.
                  CLEAR rf140-msatz.
                  CLEAR rf140-vtext.

                  save_ktosl = bset-ktosl.
                  PERFORM read_t687t.

                  rf140-msatz = bset-kbetr / 10.
                   *rf140-msatz = rf140-msatz.
                  rf140-vtext = save_vtext.
                   *rf140-vtext = rf140-vtext.

                  IF bset-shkzg = 'H'.
                    rf140-mwshb = bset-fwste.
                     *rf140-mwshb = *bset-fwste.
                    rf140-mdshb = bset-hwste.
                     *rf140-mdshb = *bset-hwste.
                  ELSE.
                    rf140-mwshb = 0 - bset-fwste.
                     *rf140-mwshb = 0 - *bset-fwste.
                    rf140-mdshb = 0 - bset-hwste.
                     *rf140-mdshb = 0 - *bset-hwste.
                  ENDIF.
                  EXIT.
                ENDLOOP.
                rf140-wrshb = rf140-wrshb - rf140-mwshb.
                 *rf140-wrshb = *rf140-wrshb - *rf140-mwshb.
                rf140-dmshb = rf140-dmshb - rf140-mdshb.
                 *rf140-dmshb = *rf140-dmshb - *rf140-mdshb.
              ENDIF.
            ENDIF.

***<<<pdf enabling
            ls_item-waers = rf140-waers.
            ls_item-wrshb = rf140-wrshb.
            ls_item-corrid = co_rfkord_oil.
            APPEND ls_item TO lt_item.
***>>>pdf enabling

            CLEAR rf140-element.
            rf140-element = '521'.

***<<<  commented for pdf enabling
**            CALL FUNCTION 'WRITE_FORM'
**                     EXPORTING  WINDOW    = 'MAIN'
**                                ELEMENT   = '521'
**                     EXCEPTIONS WINDOW    = 1
**                                ELEMENT   = 2.
**                     IF SY-SUBRC = 1.
**                       WINDOW = 'MAIN'.
**                       PERFORM MESSAGE_WINDOW.
**                     ENDIF.
**                     IF SY-SUBRC = 2.
**                       WINDOW = 'MAIN'.
**                       EREIGNIS = '521'.
**                       PERFORM MESSAGE_ELEMENT.
**                     ENDIF.
***>>>  commented for pdf enabling

            IF save_xumstn IS INITIAL.
*-------Umsatzsteuer ---------------------------------------------------
              IF xactiv IS INITIAL.
                save_waers = rf140-waers.
                PERFORM tax_data.
                CLEAR taxlines.
                DESCRIBE TABLE atax LINES taxlines.
                IF NOT taxlines IS INITIAL.
                  LOOP AT atax.
                    CLEAR ereignis.
                    CLEAR rf140-msatz.
                    CLEAR rf140-vtext.

                    rf140-msatz = atax-msatz.
                     *rf140-msatz = atax-msatz.
                    rf140-vtext = atax-vtext.
                     *rf140-vtext = atax-vtext.

                    IF sy-tabix = '1'.
                      ereignis = '522'.
                    ELSE.
                      ereignis = '523'.
                    ENDIF.

                    CLEAR rf140-element.
                    rf140-element = ereignis.

***<<<  commented for pdf enabling
*                IF NOT EREIGNIS IS INITIAL.
*                  CALL FUNCTION 'WRITE_FORM'
*                                   EXPORTING  WINDOW    = 'MAIN'
*                                              ELEMENT   = EREIGNIS
*                                   EXCEPTIONS WINDOW    = 1
*                                              ELEMENT   = 2.
*                                   IF SY-SUBRC = 1.
*                                     WINDOW = 'MAIN'.
*                                     PERFORM MESSAGE_WINDOW.
*                                   ENDIF.
*                                   IF SY-SUBRC = 2.
*                                     WINDOW = 'MAIN'.
*                                     PERFORM MESSAGE_ELEMENT.
*                                   ENDIF.
*                ENDIF.
***>>>  commented for pdf enabling

***<<<  pdf enabling
                    CLEAR ls_item.
                    ls_item-tax_percent = rf140-msatz.
                    ls_item-vtext = rf140-vtext.
                    ls_item-corrid = co_tax_item.
                    APPEND ls_item TO lt_item.
***>>>  pdf enabling

                  ENDLOOP.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.



        IF countz GT '1'.
          CLEAR rf140-element.
          rf140-element = '530'.
***<<<  commented for pdf enabling
**          CALL FUNCTION 'WRITE_FORM'
**                   EXPORTING  WINDOW    = 'MAIN'
**                              ELEMENT   = '530'
**                   EXCEPTIONS WINDOW    = 1
**                              ELEMENT   = 2.
**                   IF SY-SUBRC = 1.
**                     WINDOW = 'MAIN'.
**                     PERFORM MESSAGE_WINDOW.
**                   ENDIF.
**                   IF SY-SUBRC = 2.
**                     WINDOW = 'MAIN'.
**                     EREIGNIS = '530'.
**                     PERFORM MESSAGE_ELEMENT.
**                   ENDIF.
***>>>  commented for pdf enabling

****<<<< pdf enabling

          CLEAR ls_sum.
          ls_sum-waers = bkpf-waers.
          ls_sum-saldow = rf140-gsaldf.
          ls_sum-sum_id = co_total_clearing_item.

          APPEND ls_sum TO lt_sum.
****>>>> pdf enabling

        ENDIF.



        IF  xmultk IS INITIAL
        AND NOT xumsst IS INITIAL
        AND     save_xumstn IS INITIAL.
          IF bkpf-bstat = 'V'.
            PERFORM read_vbset.
          ELSE.
            PERFORM read_bset.
          ENDIF.
          LOOP AT hbset.
            MOVE-CORRESPONDING hbset TO bset.
             *bset = bset.
            IF bkpf-waers NE *bkpf-waers.
              PERFORM curr_document_convert_bset
                          USING
                             bkpf-budat
                             *bkpf-waers
                             *bkpf-hwaer
                             bkpf-waers
                          CHANGING
                             bset.
            ENDIF.
            CLEAR ereignis.
            IF sy-tabix = '1'.
              ereignis = '531'.
            ELSE.
              ereignis = '532'.
            ENDIF.
            CLEAR rf140-msatz.
            CLEAR rf140-vtext.

            save_ktosl = bset-ktosl.
            PERFORM read_t687t.

            rf140-msatz = bset-kbetr / 10.
             *rf140-msatz = rf140-msatz.
            rf140-vtext = save_vtext.
             *rf140-vtext = rf140-vtext.

            IF bset-shkzg = 'H'.
              rf140-mwshb = bset-fwste.
               *rf140-mwshb = *bset-fwste.
              rf140-mdshb = bset-hwste.
               *rf140-mdshb = *bset-hwste.
            ELSE.
              rf140-mwshb = 0 - bset-fwste.
               *rf140-mwshb = 0 - *bset-fwste.
              rf140-mdshb = 0 - bset-hwste.
               *rf140-mdshb = 0 - *bset-hwste.
            ENDIF.

            CLEAR rf140-element.
            rf140-element = ereignis.

***<<<  commented for pdf enabling
**            IF NOT EREIGNIS IS INITIAL.
**              CALL FUNCTION 'WRITE_FORM'
**                               EXPORTING  WINDOW    = 'MAIN'
**                                          ELEMENT   = EREIGNIS
**                               EXCEPTIONS WINDOW    = 1
**                                          ELEMENT   = 2.
**                               IF SY-SUBRC = 1.
**                                 WINDOW = 'MAIN'.
**                                 PERFORM MESSAGE_WINDOW.
**                               ENDIF.
**                               IF SY-SUBRC = 2.
**                                 WINDOW = 'MAIN'.
**                                 PERFORM MESSAGE_ELEMENT.
**                               ENDIF.
**            ENDIF.
***>>>  commented for pdf enabling

***<<<  pdf enabling
            CLEAR ls_sum.
            ls_sum-butxt = rf140-vtext.
            ls_sum-tax_percent = rf140-msatz.
            ls_sum-waers = bkpf-waers.
            ls_sum-p_tax_amount = rf140-mwshb.
            ls_sum-txjcd = bset-txjcd.
            ls_sum-sum_id = co_tax_item1.
            APPEND ls_sum TO lt_sum.
***>>>  pdf enabling

          ENDLOOP.
        ENDIF.

*-------Kreditorn-/Debitorenverrechnung---------------------------------
        IF  NOT save_kunnr IS INITIAL
        AND NOT save_lifnr IS INITIAL
        AND NOT xadr2      IS INITIAL.
          CLEAR rf140-element.
          rf140-element = '540'.
***<<<  commented for pdf enabling

**        CALL FUNCTION 'WRITE_FORM'
**                 EXPORTING  WINDOW    = 'MAIN'
**                            ELEMENT   = '540'
**                 EXCEPTIONS WINDOW    = 1
**                            ELEMENT   = 2.
**                 IF SY-SUBRC = 1.
**                   WINDOW = 'MAIN'.
**                   PERFORM MESSAGE_WINDOW.
**                 ENDIF.
**                 IF SY-SUBRC = 2.
**                   WINDOW = 'MAIN'.
**                   EREIGNIS = '540'.
**                   PERFORM MESSAGE_ELEMENT.
**                 ENDIF.



**        CLEAR RF140-ELEMENT.
**        RF140-ELEMENT = '541'.
**        CALL FUNCTION 'WRITE_FORM'
**                 EXPORTING  WINDOW    = 'MAIN'
**                            ELEMENT   = '541'
**                 EXCEPTIONS WINDOW    = 1
**                            ELEMENT   = 2.
**                 IF SY-SUBRC = 1.
**                   WINDOW = 'MAIN'.
**                   PERFORM MESSAGE_WINDOW.
**                 ENDIF.
**                 IF SY-SUBRC = 2.
**                   WINDOW = 'MAIN'.
**                   EREIGNIS = '541'.
**                   PERFORM MESSAGE_ELEMENT.
**                 ENDIF.
***>>>  commented for pdf enabling

          CLEAR ls_address.

          MOVE-CORRESPONDING dkad2 TO ls_address.

          MOVE-CORRESPONDING dkad2 TO ls_adrs.

          IF NOT dkad2-adrnr IS INITIAL.
            CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
              EXPORTING
                address_type      = '1'
                address_number    = fiadr-adrnr
                sender_country    = fiadr-inlnd
              IMPORTING
                address_printform = ls_adrs_print.
            MOVE-CORRESPONDING ls_adrs_print TO ls_address.
          ELSE.
            CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
              EXPORTING
                adrswa_in  = ls_adrs
              IMPORTING
                adrswa_out = ls_adrs.
            MOVE-CORRESPONDING ls_adrs TO ls_address.
          ENDIF.

          ls_address-corrid = co_supplier_address.

          APPEND ls_address TO lt_address.

        ENDIF.

*-------Filialen--------------------------------------------------------
        IF NOT anzko IS INITIAL.
          CLEAR rf140-element.
          rf140-element = '550'.
**        CALL FUNCTION 'WRITE_FORM'
**                 EXPORTING  WINDOW    = 'MAIN'
**                            ELEMENT   = '550'
**                 EXCEPTIONS WINDOW    = 1
**                            ELEMENT   = 2.
**                 IF SY-SUBRC = 1.
**                   WINDOW = 'MAIN'.
**                   PERFORM MESSAGE_WINDOW.
**                 ENDIF.
**                 IF SY-SUBRC = 2.
**                   WINDOW = 'MAIN'.
**                   EREIGNIS = '550'.
**                   PERFORM MESSAGE_ELEMENT.
**                 ENDIF.

          LOOP AT azentfil.
            AT NEW koart.
              IF anzko = '2'.
                IF azentfil-koart = 'D'.
                  ereignis = '551'.
                ELSE.
                  ereignis = '552'.
                ENDIF.
                CLEAR rf140-element.
                rf140-element = ereignis.
**              CALL FUNCTION 'WRITE_FORM'
**                       EXPORTING  WINDOW    = 'MAIN'
**                                  ELEMENT   = EREIGNIS
**                       EXCEPTIONS WINDOW    = 1
**                                  ELEMENT   = 2.
**                       IF SY-SUBRC = 1.
**                         WINDOW = 'MAIN'.
**                         PERFORM MESSAGE_WINDOW.
**                       ENDIF.
**                       IF SY-SUBRC = 2.
**                         WINDOW = 'MAIN'.
**                         PERFORM MESSAGE_ELEMENT.
**                       ENDIF.
              ENDIF.
            ENDAT.
            PERFORM filiale.
            CLEAR rf140-element.
            rf140-element = '553'.
**          CALL FUNCTION 'WRITE_FORM'
**                   EXPORTING  WINDOW    = 'MAIN'
**                              ELEMENT   = '553'
**                   EXCEPTIONS WINDOW    = 1
**                              ELEMENT   = 2.
**                   IF SY-SUBRC = 1.
**                     WINDOW = 'MAIN'.
**                     PERFORM MESSAGE_WINDOW.
**                   ENDIF.
**                   IF SY-SUBRC = 2.
**                     WINDOW = 'MAIN'.
**                     EREIGNIS = '553'.
**                     PERFORM MESSAGE_ELEMENT.
**                   ENDIF.

***<<<   pdf enabling
            CLEAR ls_address.

            MOVE-CORRESPONDING fiadr TO ls_address.

            MOVE-CORRESPONDING fiadr TO ls_adrs.

            IF NOT fiadr-adrnr IS INITIAL.
              CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
                EXPORTING
                  address_type      = '1'
                  address_number    = fiadr-adrnr
                  sender_country    = fiadr-inlnd
                IMPORTING
                  address_printform = ls_adrs_print.
              MOVE-CORRESPONDING ls_adrs_print TO ls_address.
            ELSE.
              CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
                EXPORTING
                  adrswa_in  = ls_adrs
                IMPORTING
                  adrswa_out = ls_adrs.
              MOVE-CORRESPONDING ls_adrs TO ls_address.
            ENDIF.

            IF azentfil-koart = 'D'.
              ls_address-corrid = co_customer_branch_address.
            ELSE.
              ls_address-corrid = co_vendor_branch_address.
            ENDIF.

            APPEND ls_address TO lt_address.


***>>>   pdf enabling


          ENDLOOP.
        ENDIF.


*-------Gruß und Unterschrift-------------------------------------------
        CLEAR rf140-element.
        rf140-element = '560'.
**        CALL FUNCTION 'WRITE_FORM'
**                 EXPORTING  WINDOW    = 'MAIN'
**                            ELEMENT   = '560'
**                 EXCEPTIONS WINDOW    = 1
**                            ELEMENT   = 2.
**                 IF SY-SUBRC = 1.
**                   WINDOW = 'MAIN'.
**                   PERFORM MESSAGE_WINDOW.
**                 ENDIF.
**                 IF SY-SUBRC = 2.
**                   WINDOW = 'MAIN'.
**                   EREIGNIS = '560'.
**                   PERFORM MESSAGE_ELEMENT.
**                 ENDIF.

*       CLEAR RF140-ELEMENT.           "kundeneigenes Element
*       RF140-ELEMENT = '570'.
*       CALL FUNCTION 'WRITE_FORM'
*                EXPORTING  WINDOW    = 'MAIN'
*                           ELEMENT   = '570'
*                EXCEPTIONS WINDOW    = 1
*                           ELEMENT   = 2.
*                IF SY-SUBRC = 1.
**                 WINDOW = 'MAIN'.
**                 PERFORM MESSAGE_WINDOW.
*                ENDIF.
*                IF SY-SUBRC = 2.
**                 WINDOW = 'MAIN'.
**                 EREIGNIS = '570'.
**                 FTEXT = TEXT-570.
**                 PERFORM MESSAGE_ELEMENT.
*                ENDIF.

*        PERFORM FORM_END_2.
        xprint = 'X'.
*       IF SAVE_SORT = '1'.
*         ANZDR2 = ANZDR2 + 1.
*       ENDIF.
      ENDIF.                                               "xstart
    ENDIF.                                                 "Xadrs
  ENDIF.                                                   "Xkausg

*   xprint = 'X'.               "(-) GNAG  CR#768

  CHECK save_ftype = '3'.

* get docparams
  PERFORM fill_docparams_pdf USING    language
                                  dkadr-inlnd
                                  h_archive_index
                         CHANGING fp_docparams.

  IF NOT save_fm_name IS INITIAL.
* call the generated function module
    CALL FUNCTION save_fm_name
      EXPORTING
        /1bcdwb/docparams  = fp_docparams
        ls_header          = ls_header
        lt_address         = lt_address
        lt_item            = lt_item
        lt_sum             = lt_sum
        lt_rtab            = lt_rtab
        lt_paymo           = lt_paymo
      IMPORTING                                 "(+) GNAG  CR#768
        /1bcdwb/formoutput = lx_formoutput      "(+) GNAG  CR#768
      EXCEPTIONS
        usage_error        = 1
        system_error       = 2
        internal_error     = 3
        OTHERS             = 4.
    IF sy-subrc <> 0.
      PERFORM message_pdf.

*     Begin of change - GNAG CR#768
*     PDF email sending part added based on the customer default communication method
    ELSE.
*      &--Fetch Customer Address
      SELECT SINGLE adrnr   "Address No.
        INTO lv_cust_adrnr
        FROM kna1
       WHERE kunnr = ls_header-konto.

      READ TABLE lt_item INTO lwa_item WITH KEY corrid = lc_corrid_oil.
      IF sy-subrc = 0.
        IF lwa_item-wrshb GT 0.
          lv_attachment_name = lc_debit_memo.         "Debit Memo
        ELSE.
          lv_attachment_name = lc_credit_memo.        "Credit Memo
        ENDIF.
      ENDIF.

*     For document types DG and DR, dont send the mail
      SELECT sign       " Sign
             opti       " Option
             low        " Low value
             high       " High value
        FROM tvarvc
        INTO TABLE lr_blart
       WHERE name = lc_tvarvc_blart.
      IF sy-subrc IS INITIAL.
        IF save_blart IN lr_blart.
          CHECK 1 = 2.
        ENDIF.
      ENDIF.

*      &--Send Mail/Fax/Print
      CALL FUNCTION 'ZOTC_STANDARD_COMMUNICATION'
        EXPORTING
          im_adrnr           = lv_cust_adrnr
          im_subject         = 'Debit/Credit Form'(sub)
          im_form_output     = lx_formoutput
          im_attachment_name = lv_attachment_name
        EXCEPTIONS
          no_email_address   = 1
          no_fax_number      = 2
          mail_failure       = 3
          fax_failure        = 4
          OTHERS             = 5.
      CASE sy-subrc.
        WHEN 1.
*          &--If E-mail address not maintained
          CLEAR fimsg.
          fimsg-msort = lc_msort.
          fimsg-msgid = lc_dev_msg.
          fimsg-msgty = lc_error.
          fimsg-msgno = lc_msgno_003.
          fimsg-msgv1 = 'For Customer'(e01).
          fimsg-msgv2 = ls_header-konto.
          fimsg-msgv3 = 'E-mail Address is not Maintained'(e02).
          PERFORM message_append.
        WHEN 2.
*          &--If Fax Number not maintained
          CLEAR fimsg.
          fimsg-msort = lc_msort.
          fimsg-msgid = lc_dev_msg.
          fimsg-msgty = lc_error.
          fimsg-msgno = lc_msgno_003.
          fimsg-msgv1 = 'For Customer'(e01).
          fimsg-msgv2 = ls_header-konto.
          fimsg-msgv3 = 'Fax Number is not Maintained'(e03).
          PERFORM message_append.
        WHEN 3.
*          &--If E-mail sending failed
          CLEAR fimsg.
          fimsg-msort = lc_msort.
          fimsg-msgid = lc_dev_msg.
          fimsg-msgty = lc_error.
          fimsg-msgno = lc_msgno_003.
          fimsg-msgv1 = 'For Customer'(e01).
          fimsg-msgv2 = ls_header-konto.
          fimsg-msgv3 = 'E-mail sending failed'(e04).
          PERFORM message_append.
        WHEN 4.
*          &--If Fax sending failed
          CLEAR fimsg.
          fimsg-msort = lc_msort.
          fimsg-msgid = lc_dev_msg.
          fimsg-msgty = lc_error.
          fimsg-msgno = lc_msgno_003.
          fimsg-msgv1 = 'For Customer'(e01).
          fimsg-msgv2 = ls_header-konto.
          fimsg-msgv3 = 'Fax sending failed'(e05).
          PERFORM message_append.
        WHEN OTHERS.
*          &--If other error
          CLEAR fimsg.
          fimsg-msort = lc_msort.
          fimsg-msgid = lc_dev_msg.
          fimsg-msgty = lc_error.
          fimsg-msgno = lc_msgno_003.
          fimsg-msgv1 = 'For Customer'(e01).
          fimsg-msgv2 = ls_header-konto.
          fimsg-msgv3 = 'Document sending failed'(e06).
          PERFORM message_append.
      ENDCASE.
* End of change - GNAG CR#768
    ENDIF.
  ELSE.
* error
  ENDIF.

ENDFORM.                    "AUSGABE_BELEGAUSZUG_PDF
