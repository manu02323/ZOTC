FUNCTION zotc_get_housebankinfo.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_BUKRS) TYPE  BUKRS
*"     VALUE(IM_CURR) TYPE  WAERS
*"     VALUE(IM_MULT_HOUSEBANK_INFO) TYPE  FLAG OPTIONAL
*"  EXPORTING
*"     VALUE(EX_OUT) TYPE  ZOTC_HOUSEBANK
*"  CHANGING
*"     VALUE(ET_HOUSEBANK) TYPE  ZOTC_T_HOUSEBANK OPTIONAL
*"----------------------------------------------------------------------
************************************************************************
* PROGRAM    :  ZOTC_GET_HOUSEBANKINFO                                 *
* TITLE      :  FM to get the house bank info                          *
* DEVELOPER  :  Pallavi Gupta                                          *
* OBJECT TYPE:  Form                                                   *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_FDD_0015                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: Customer Dispute form have some changes under the WRICEF*
*              D3_OTC_FDD_0015.This FM is created for getting the house*
*              bank information using the company code.                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER        TRANSPORT     DESCRIPTION                   *
* 21-SEP-2016  U024571     E1DK921945    Initial Development           *
*----------------------------------------------------------------------*
* 03-Jan-2017  SGHOSH      E1DK921945    CR#301: New logic implemented *
*                                        to display multiple Housebank *
*                                        addresses based. The new logic*
*                                        will be triggered when flag   *
*                                        IM_MULT_HOUSEBANK_INFO is set *
************************************************************************
*20-Feb-2017   NGARG      E1DK921945    D3_OTC_FDD_0016_CR#356 : Add   *
*                                       bank key( T012-BANKL) to output*
*                                        structure/table               *
************************************************************************
* 24-Feb-2017 NGARG      E1DK921945   Defect#9637 :Add BANKS field to  *
*                                     output structure and pass it's   *
*                                     value from T012 table            *
************************************************************************
* 27-Feb-2017 U033867    E1DK921945   CR356 Defect#9636 :Logic to get  *
*                                     the bank name and address for    *
*                                     swiss company codes .Add currency*
*                                     with bank account                *
************************************************************************
* 25-Jan-2018 PDEBARU    E1DK931113   D3R3 changes : The FM will fetch *
*                                     data even if IBAN value is blank *
************************************************************************
* 05-Sep-2018 U103061    E1DK938648   Defect# 6368: Bank GIRO # needs  *
*                                     to be printed on customer statement*
*                                     - Sweden only                    *
************************************************************************
*Local Data declaration

*Types Declaration
  TYPES : BEGIN OF lty_t012k,
            bukrs TYPE bukrs, " Company Code
            hbkid TYPE hbkid, " Short Key for a House Bank
            hktid TYPE hktid, " ID for Account Details
            bankn TYPE bankn, " Bank account number
            bkont TYPE bkont, " Bank Control Key
*-->Begin of change for CR356 defect#9636 by U033867
            waers TYPE waers, " Currency Key
*<--End of change for CR356 defect#9636 by U033867
         END OF lty_t012k,

         BEGIN OF lty_t012,
           bukrs TYPE bukrs,    " Company Code
           hbkid TYPE hbkid,    " Short Key for a House Bank
           banks TYPE banks,    " Bank country key
           bankl TYPE bankk,    " Bank Keys
         END OF lty_t012,

         BEGIN OF lty_bnka,
           banks TYPE banks,    " Bank country key
           bankl TYPE bankk,    " Bank Keys
           banka TYPE banka,    " Name of bank
           stras TYPE stras_gp, " House number and street
           ort01 TYPE ort01_gp, " City
           swift TYPE swift,    " SWIFT/BIC for International Payments
         END OF lty_bnka,

         BEGIN OF lty_tiban,
           banks TYPE banks,    " Bank country key
           bankl TYPE bankk,    " Bank Keys
           bankn TYPE bankn,    " Bank account number
           bkont TYPE bkont,    " Bank Control Key
           iban  TYPE iban,     " IBAN (International Bank Account Number)
         END OF lty_tiban,

         BEGIN OF lty_bank,
           bukrs TYPE	bukrs,
           waerk  TYPE waerk,   " SD Document Currency
           hbkid  TYPE hbkid,   " Short Key for a House Bank
           htkid  TYPE hktid,   " ID for Account Details
*&--Begin of Change for Defect# 6368 by U103061 on 05-09-18
           zz_addbankinf1 TYPE text20, "Additional Bank Information 1
           zz_addbankinf2 TYPE text20, "Additional Bank Information 2
*&--End of Change for Defect# 6368 by U103061 on 05-09-18
         END OF lty_bank,

*---> Begin of Insert for D3_OTC_FDD_0013_CR#301 by SGHOSH
         BEGIN OF lty_tiban1,
           banks TYPE banks,   " Bank country key
           bankl TYPE bankk,   " Bank Keys
           bankn TYPE bankn35, " Bank account number
           bkont TYPE bkont,   " Bank Control Key
           iban  TYPE iban,    " IBAN (International Bank Account Number)
         END OF lty_tiban1,

         BEGIN OF lty_t012k1,
            bukrs TYPE bukrs,  " Company Code
            hbkid TYPE hbkid,  " Short Key for a House Bank
            hktid TYPE hktid,  " ID for Account Details
            bankn TYPE bankn,  " Bank account number
            bkont TYPE bkont,  " Bank Control Key
            waers TYPE waers,  " Currency Key
         END OF lty_t012k1,

         BEGIN OF lty_bnka_t012k,
           banks TYPE banks,   " Bank country key
           bankl TYPE bankk,   " Bank Keys
           bankn TYPE bankn35, " Bank account number
           bkont TYPE bkont,   " Bank Control Key
           waerk TYPE waerk,   " SD Document Currency
         END OF lty_bnka_t012k.
*<--- End of Insert for D3_OTC_FDD_0013_CR#301 by SGHOSH

*Internal table and work area declaration
  DATA : lwa_t012k     TYPE lty_t012k,
         lwa_t012      TYPE lty_t012,
         lwa_tiban     TYPE lty_tiban,
         lwa_bnka      TYPE lty_bnka,
         lwa_out       TYPE zotc_housebank, " Structure for House Bank Info
         lwa_zotc_bank TYPE lty_bank,
*---> Begin of Insert for D3_OTC_FDD_0013_CR#301 by SGHOSH
         lv_index      TYPE sytabix,                          " Index of Internal Tables
         li_t012k      TYPE STANDARD TABLE OF lty_t012k1,
         li_t012       TYPE STANDARD TABLE OF lty_t012,
         li_t012k_tmp  TYPE STANDARD TABLE OF lty_t012k1,
         li_t012_tmp   TYPE STANDARD TABLE OF lty_t012,
         li_tiban      TYPE STANDARD TABLE OF lty_tiban1,
         li_bnka       TYPE STANDARD TABLE OF lty_bnka,
         li_zotc_bank  TYPE STANDARD TABLE OF lty_bank,
         li_housebank  TYPE STANDARD TABLE OF zotc_housebank, " Structure for House Bank Info
         lwa_bnka_t012k TYPE lty_bnka_t012k,
         li_bnka_t012k TYPE STANDARD TABLE OF lty_bnka_t012k,
*-->Begin of change for CR356 defect#9636 by U033867
         li_enh_status TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
*<--End of change for CR356 defect#9636 by U033867
* ---> Begin of Insert for CR356 defect#9636 by DMOIRAN
        li_lines       TYPE text_lines,
        lv_ch_address  TYPE flag. " General Flag

* <--- End    of Insert for CR356 defect#9636 by DMOIRAN

  CONSTANTS: lc_usd TYPE waers VALUE 'USD', " Currency Key
             lc_eur TYPE waers VALUE 'EUR', " Currency Key
*---> Begin of Insert for D3_OTC_FDD_0013_CR#301_Part_II by SGHOSH
             lc_slash TYPE char1 VALUE '/', " Slash of type CHAR1
*<--- End of Insert for D3_OTC_FDD_0013_CR#301_Part_II by SGHOSH
*-->Begin of change for CR356 defect#9636 by U033867
             lc_id       TYPE tdid     VALUE 'ST',                       " Text ID
             lc_lang     TYPE spras    VALUE 'E',                        " Language Key
             lc_name     TYPE tdobname   VALUE 'ZOTC_BANKADDR_FIRMA_CH', " Name
             lc_obj      TYPE tdobject VALUE 'TEXT',                     " Texts: Application Object
             lc_enh_no   TYPE z_enhancement VALUE 'D2_OTC_FDD_0015',     "Enhancement No.
             lc_bukrs_ch TYPE z_criteria    VALUE 'BUKRS_CH'.            " Enh. Criteria
*<--End of change for CR356 defect#9636 by U033867
  FIELD-SYMBOLS: <lfs_bnka>       TYPE lty_bnka,
                 <lfs_t012>       TYPE lty_t012,
                 <lfs_t012k>      TYPE lty_t012k1,
                 <lfs_tiban>      TYPE lty_tiban1,
*---> Begin of Insert for D3_OTC_FDD_0013_CR#301_Part_II by SGHOSH
                 <lfs_zotc_bank>  TYPE lty_bank,
*<--- End of Insert for D3_OTC_FDD_0013_CR#301_Part_II by SGHOSH
                 <lfs_bnka_t012k> TYPE lty_bnka_t012k,
*<--- End of Insert for D3_OTC_FDD_0013_CR#301 by SGHOSH
                 <lfs_line>       TYPE tline,          " SAPscript: Text Lines +CR356 defect#9636 by DMOIRAN
                 <lfs_bank>       TYPE zotc_housebank. " Structure for House Bank Info
* ---> Begin of Insert for CR356 defect#9636 by DMOIRAN
* In case of company code 2001, 2002, 2003 pick up Name and city from
*-->Begin of change for CR356 defect#9636 by U033867
*&-- Get the reqiured details form the EMI tool
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_no
    TABLES
      tt_enh_status     = li_enh_status.
  DELETE li_enh_status WHERE active = space.
*  Binary search not used as table has few entries
  READ TABLE li_enh_status WITH KEY criteria = lc_bukrs_ch
                                    sel_low  = im_bukrs
                                    TRANSPORTING NO FIELDS.
*<--End of change for CR356 defect#9636 by U033867
* standard text
  IF sy-subrc = 0.
    lv_ch_address = abap_true.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lc_lang
        name                    = lc_name
        object                  = lc_obj
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
    IF sy-subrc <> 0.
      CLEAR: li_lines[],
            lv_ch_address.

    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF sy-subrc = 0

* <--- End of Insert for CR356 defect#9636 by DMOIRAN


*---> Begin of Insert for D3_OTC_FDD_0013_CR#301 by SGHOSH
  IF  im_mult_housebank_info IS INITIAL.
*<--- End of Insert for D3_OTC_FDD_0013_CR#301 by SGHOSH

*Select data from ZOTC_BANK based on bukrs and waers
    SELECT SINGLE bukrs " Company Code
                  waerk " SD Document Currency
                  hbkid " Short Key for a House Bank
                  htkid " ID for Account Details
*&--Begin of Change for Defect# 6368 by U103061 on 05-09-18
                  zz_addbankinf1 "Additional Bank Information 1
                  zz_addbankinf2 "Additional Bank Information 2
*&--End of Change for Defect# 6368 by U103061 on 05-09-18
           FROM zotc_bank " House Bank Determination
           INTO lwa_zotc_bank
           WHERE bukrs = im_bukrs
             AND waerk = im_curr.

    IF sy-subrc NE 0.
*If no data found based on company and currency
*then fetch data based on just company
      SELECT   bukrs " Company Code
               waerk " SD Document Currency
               hbkid " Short Key for a House Bank
               htkid " ID for Account Details
*&--Begin of Change for Defect# 6368 by U103061 on 05-09-18
               zz_addbankinf1 "Additional Bank Information 1
               zz_addbankinf2 "Additional Bank Information 2
*&--End of Change for Defect# 6368 by U103061 on 05-09-18
        FROM zotc_bank " House Bank Determination
        UP TO 1 ROWS
        INTO lwa_zotc_bank
        WHERE bukrs = im_bukrs.
      ENDSELECT.
      IF sy-subrc NE 0.
        CLEAR lwa_zotc_bank.
      ENDIF. " IF sy-subrc NE 0
    ENDIF. " IF sy-subrc NE 0

    IF lwa_zotc_bank IS NOT INITIAL.
*Select data from T012K table
      SELECT SINGLE bukrs " Company Code
                    hbkid " Short Key for a House Bank
                    hktid " ID for Account Details
                    bankn " Bank account number
                    bkont " Bank Control Key
*-->Begin of change for CR356 defect#9636 by U033867
                    waers
*<--End of change for CR356 defect#9636 by U033867
        FROM t012k " House Bank Accounts
        INTO lwa_t012k
        WHERE bukrs = lwa_zotc_bank-bukrs
          AND hbkid = lwa_zotc_bank-hbkid
          AND hktid = lwa_zotc_bank-htkid.

      IF sy-subrc EQ 0.


*Fetch data from T012 table based on T012K data fetched above
        SELECT SINGLE bukrs " Company Code
                      hbkid " Short Key for a House Bank
                      banks " Bank country key
                      bankl " Bank Keys
          FROM t012         " House Banks
          INTO lwa_t012
          WHERE bukrs = lwa_t012k-bukrs
            AND hbkid = lwa_t012k-hbkid.
        IF sy-subrc = 0.

*Begin of insert for D3_OTC_FDD_0016_CR#356 by NGARG
          lwa_out-bank_key = lwa_t012-bankl.
*End of insert for D3_OTC_FDD_0016_CR#356 by NGARG

*Begin of insert for Defect#9637 by NGARG
          lwa_out-bank_country  = lwa_t012-banks.
*End of insert for Defect#9637 by NGARG

*---> Begin of Insert for D3_OTC_FDD_0016_D3R3 by PDEBARU on 25-Jan-2018
          lwa_out-bankn = lwa_t012k-bankn. " Bank account number
          lwa_out-waers = lwa_t012k-waers. " Currency Key
*<--- End of Insert for D3_OTC_FDD_0016_D3R3 by PDEBARU on 25-Jan-2018

*Fetch data from BNKA table based on T012 data above
          SELECT SINGLE banks " Bank country key
                        bankl " Bank Keys
                        banka " Name of bank
                        stras " House number and street
                        ort01 " City
                        swift " SWIFT/BIC for International Payments
            FROM bnka         " Bank master record
            INTO lwa_bnka
            WHERE banks = lwa_t012-banks
              AND bankl = lwa_t012-bankl.
          IF sy-subrc = 0.
*Populate exporting paramter
            lwa_out-banka = lwa_bnka-banka.
            lwa_out-stras = lwa_bnka-stras.
            lwa_out-ort01 = lwa_bnka-ort01.
            lwa_out-swift = lwa_bnka-swift.

*Fetch data from TIBAN table
            SELECT SINGLE banks " Bank country key
                          bankl " Bank Keys
                          bankn " Bank account number
                          bkont " Bank Control Key
                          iban  " IBAN (International Bank Account Number)
              FROM tiban        " IBAN
              INTO lwa_tiban
              WHERE banks = lwa_bnka-banks
                AND bankl = lwa_bnka-bankl
                AND bankn = lwa_t012k-bankn
                AND bkont = lwa_t012k-bkont.
            IF sy-subrc = 0.

*---> Begin of Delete for D3_OTC_FDD_0016_D3R3 by PDEBARU on 25-Jan-2018
*Populate exporting paramter
*              lwa_out-bankn = lwa_tiban-bankn.
*<--- End of Delete for D3_OTC_FDD_0016_D3R3 by PDEBARU on 25-Jan-2018
              lwa_out-iban = lwa_tiban-iban.
*---> Begin of Delete for D3_OTC_FDD_0016_D3R3 by PDEBARU on 25-Jan-2018
*-->Begin of change for CR356 defect#9636 by U033867
*              lwa_out-waers = lwa_t012k-waers. " Currency Key
*<--End of change for CR356 defect#9636 by U033867
*<--- End of Delete for D3_OTC_FDD_0016_D3R3 by PDEBARU on 25-Jan-2018
            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc EQ 0
*&--Begin of Change for D3_OTC_FDD_0013 Defect# 6368 by U103061 on 05-Sep-18
*&--Populating the additional housebank address in the final structure.
      lwa_out-zz_addbankinf1 = lwa_zotc_bank-zz_addbankinf1.
      lwa_out-zz_addbankinf2 = lwa_zotc_bank-zz_addbankinf2.
*&--End of Change for D3_OTC_FDD_0013 Defect# 6368 by U103061 on 05-Sep-18
    ENDIF. " IF lwa_zotc_bank IS NOT INITIAL

* ---> Begin of Insert for CR356 defect#9636 DMOIRAN
    IF lv_ch_address = abap_true.
      READ TABLE li_lines ASSIGNING <lfs_line> INDEX 1.
      IF sy-subrc = 0 AND
        <lfs_line> IS ASSIGNED.
        lwa_out-banka = <lfs_line>-tdline.
      ENDIF. " IF sy-subrc = 0 AND

      READ TABLE li_lines ASSIGNING <lfs_line> INDEX 2.
      IF sy-subrc = 0 AND
        <lfs_line> IS ASSIGNED.
        lwa_out-ort01 = <lfs_line>-tdline.
      ENDIF. " IF sy-subrc = 0 AND
    ENDIF. " IF lv_ch_address = abap_true

* <--- End    of Insert for CR356 defect#9636 by DMOIRAN

    ex_out = lwa_out.

*---> Begin of Insert for D3_OTC_FDD_0013_CR#301 by SGHOSH
  ELSE. " ELSE -> IF im_mult_housebank_info IS INITIAL

***Select data from ZOTC_BANK based on bukrs and waers
    SELECT bukrs     " Company Code
           waerk     " SD Document Currency
           hbkid     " Short Key for a House Bank
           htkid     " ID for Account Details
      FROM zotc_bank " House Bank Determination
      INTO TABLE li_zotc_bank
      WHERE bukrs = im_bukrs
*---> Begin of Delete for D3_OTC_FDD_0013_CR#301 Part II by SGHOSH
*      AND waerk IN (im_curr, lc_eur, lc_usd).
*<--- End of Delete for D3_OTC_FDD_0013_CR#301 Part II by SGHOSH
*---> Begin of Insert for D3_OTC_FDD_0013_CR#301 Part II by SGHOSH
      AND waerk IN (im_curr, lc_eur, lc_usd, space).
*<--- End of Insert for D3_OTC_FDD_0013_CR#301 Part II by SGHOSH

*---> Begin of Delete for D3_OTC_FDD_0013_CR#301 Part II by SGHOSH
*    IF sy-subrc NE 0.
***If no data found based on company and currency
***then fetch data based on just company
*      SELECT   bukrs   " Company Code
*               waerk   " SD Document Currency
*               hbkid   " Short Key for a House Bank
*               htkid   " ID for Account Details
*        FROM zotc_bank " House Bank Determination
*        INTO TABLE li_zotc_bank
*        WHERE bukrs = im_bukrs.
*      IF sy-subrc NE 0.
*        CLEAR li_zotc_bank.
*      ENDIF. " IF sy-subrc NE 0
*    ENDIF. " IF sy-subrc NE 0
*<--- End of Delete for D3_OTC_FDD_0013_CR#301 Part II by SGHOSH
    IF sy-subrc IS INITIAL.
* check if entry is found for importing currency. If so, then remove
* default entry (entry with blank currency).
*---> Begin of Insert for D3_OTC_FDD_0013_CR#301 Part II by SGHOSH
      READ TABLE li_zotc_bank WITH KEY waerk = im_curr
                    TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        DELETE li_zotc_bank WHERE waerk = space.
      ENDIF. " IF sy-subrc = 0
*<--- End of Insert for D3_OTC_FDD_0013_CR#301 Part II by SGHOSH

      SORT li_zotc_bank BY bukrs hbkid htkid.
      DELETE ADJACENT DUPLICATES FROM li_zotc_bank COMPARING bukrs hbkid htkid.
    ENDIF. " IF sy-subrc IS INITIAL

    IF li_zotc_bank[] IS NOT INITIAL.
*Select data from T012K table
      SELECT bukrs " Company Code
             hbkid " Short Key for a House Bank
             hktid " ID for Account Details
             bankn " Bank account number
             bkont " Bank Control Key
*<--- Begin of Insert for D3_OTC_FDD_0013_CR#301 Part II by SGHOSH
             waers
*<--- End of Insert for D3_OTC_FDD_0013_CR#301 Part II by SGHOSH
        FROM t012k " House Bank Accounts
        INTO TABLE li_t012k
        FOR ALL ENTRIES IN li_zotc_bank
        WHERE bukrs = li_zotc_bank-bukrs
          AND hbkid = li_zotc_bank-hbkid
          AND hktid = li_zotc_bank-htkid.

      IF sy-subrc EQ 0.

        SORT li_t012k BY bukrs hbkid.
        li_t012k_tmp[] = li_t012k[].
        DELETE ADJACENT DUPLICATES FROM li_t012k_tmp COMPARING bukrs hbkid.

        IF li_t012k_tmp[] IS NOT INITIAL.
*Fetch data from T012 table based on T012K data fetched above
          SELECT bukrs " Company Code
                 hbkid " Short Key for a House Bank
                 banks " Bank country key
                 bankl " Bank Keys
            FROM t012  " House Banks
            INTO TABLE li_t012
            FOR ALL ENTRIES IN li_t012k_tmp
            WHERE bukrs = li_t012k_tmp-bukrs
            AND hbkid = li_t012k_tmp-hbkid.
          IF sy-subrc = 0.

            li_t012_tmp[] = li_t012[].
            SORT li_t012_tmp BY banks bankl.
            SORT li_t012 BY bukrs hbkid.
            DELETE ADJACENT DUPLICATES FROM li_t012_tmp COMPARING banks bankl.

            IF li_t012_tmp[] IS NOT INITIAL.
*Fetch data from BNKA table based on T012 data above
              SELECT banks " Bank country key
                     bankl " Bank Keys
                     banka " Name of bank
                     stras " House number and street
                     ort01 " City
                     swift " SWIFT/BIC for International Payments
                FROM bnka  " Bank master record
                INTO TABLE li_bnka
                FOR ALL ENTRIES IN li_t012_tmp
                WHERE banks = li_t012_tmp-banks
                AND bankl = li_t012_tmp-bankl.
              IF sy-subrc = 0.

                LOOP AT li_t012k ASSIGNING <lfs_t012k>.

                  READ TABLE li_t012 ASSIGNING <lfs_t012> WITH KEY bukrs = <lfs_t012k>-bukrs
                                                                   hbkid = <lfs_t012k>-hbkid
                                                          BINARY SEARCH.
                  IF sy-subrc IS INITIAL.

                    LOOP AT li_bnka ASSIGNING <lfs_bnka>.

                      IF <lfs_bnka>-banks = <lfs_t012>-banks AND
                         <lfs_bnka>-bankl = <lfs_t012>-bankl.

                        lwa_bnka_t012k-banks = <lfs_bnka>-banks.
                        lwa_bnka_t012k-bankl = <lfs_bnka>-bankl.
                        lwa_bnka_t012k-bankn = <lfs_t012k>-bankn.
                        lwa_bnka_t012k-bkont = <lfs_t012k>-bkont.
*---> Begin of Insert for D3_OTC_FDD_0013_CR#301_Part_II by SGHOSH
                        lwa_bnka_t012k-waerk = <lfs_t012k>-waers.
*<--- End of Insert for D3_OTC_FDD_0013_CR#301_Part_II by SGHOSH
                        APPEND lwa_bnka_t012k TO li_bnka_t012k.
                        CLEAR lwa_bnka_t012k.

                      ENDIF. " IF <lfs_bnka>-banks = <lfs_t012>-banks AND

                    ENDLOOP. " LOOP AT li_bnka ASSIGNING <lfs_bnka>
                  ENDIF. " IF sy-subrc IS INITIAL
                ENDLOOP. " LOOP AT li_t012k ASSIGNING <lfs_t012k>

                SORT li_bnka_t012k BY banks bankl bankn bkont.
                DELETE ADJACENT DUPLICATES FROM li_bnka_t012k COMPARING banks bankl bankn bkont.

                IF li_bnka_t012k[] IS NOT INITIAL.
*Fetch data from TIBAN table
                  SELECT banks " Bank country key
                         bankl " Bank Keys
                         bankn " Bank account number
                         bkont " Bank Control Key
                         iban  " IBAN (International Bank Account Number)
                    FROM tiban " IBAN
                    INTO TABLE li_tiban
                    FOR ALL ENTRIES IN li_bnka_t012k
                    WHERE banks = li_bnka_t012k-banks
                    AND bankl = li_bnka_t012k-bankl
                    AND bankn = li_bnka_t012k-bankn
                    AND bkont = li_bnka_t012k-bkont.

                  IF sy-subrc IS INITIAL.

                    SORT li_tiban BY banks bankl bankn bkont iban.
                    DELETE ADJACENT DUPLICATES FROM li_tiban COMPARING banks bankl bankn bkont iban.

*Populate result in exporting table
                    LOOP AT li_bnka ASSIGNING <lfs_bnka>.
* Binary Search cannot be used as keys used for the read is not unique as this table contains
* 2 different tables data
                      READ TABLE li_bnka_t012k TRANSPORTING NO FIELDS WITH KEY banks = <lfs_bnka>-banks
                                                                               bankl = <lfs_bnka>-bankl.
                      IF sy-subrc IS INITIAL.
                        lv_index = sy-tabix.
                        LOOP AT li_bnka_t012k ASSIGNING <lfs_bnka_t012k> FROM lv_index.

                          IF NOT ( <lfs_bnka_t012k>-banks = <lfs_bnka>-banks AND
                                   <lfs_bnka_t012k>-bankl = <lfs_bnka>-bankl ).
                            EXIT.
                          ENDIF. " IF NOT ( <lfs_bnka_t012k>-banks = <lfs_bnka>-banks AND


                          READ TABLE li_tiban ASSIGNING <lfs_tiban> WITH KEY banks = <lfs_bnka_t012k>-banks
                                                                             bankl = <lfs_bnka_t012k>-bankl
                                                                             bankn = <lfs_bnka_t012k>-bankn
                                                                             bkont = <lfs_bnka_t012k>-bkont
                                                                    BINARY SEARCH.
                          IF sy-subrc IS INITIAL.

*                 Begin of insert for D3_OTC_FDD_0016_CR#356 by NGARG
                            lwa_out-bank_key = <lfs_bnka>-bankl.
*                 End of insert for D3_OTC_FDD_0016_CR#356 by NGARG

*Begin of insert for Defect#9637 by NGARG
                            lwa_out-bank_country  = <lfs_tiban>-banks.


*End of insert for Defect#9637 by NGARG

                            lwa_out-banka = <lfs_bnka>-banka.
                            lwa_out-stras = <lfs_bnka>-stras.
                            lwa_out-ort01 = <lfs_bnka>-ort01.
                            lwa_out-swift = <lfs_bnka>-swift.
*-->Begin of change for CR356 defect#9636 by U033867
                            lwa_out-waers = <lfs_bnka_t012k>-waerk. " Currency Key
*<--End of change for CR356 defect#9636 by U033867
*---> Begin of Insert for D3_OTC_FDD_0013_CR#301_Part_II by SGHOSH

                            CONCATENATE <lfs_bnka_t012k>-waerk lc_slash <lfs_tiban>-bankn INTO lwa_out-bankn.
                            SHIFT lwa_out-bankn LEFT DELETING LEADING lc_slash.
*<--- End of Insert for D3_OTC_FDD_0013_CR#301_Part_II by SGHOSH
                            lwa_out-iban  = <lfs_tiban>-iban.
                            APPEND lwa_out TO li_housebank.
                            CLEAR lwa_out.
*---> Begin of Insert for D3_OTC_FDD_0016_D3R3 by PDEBARU on 25-Jan-2018
                          ELSE. " ELSE -> IF sy-subrc IS INITIAL

                            lwa_out-bank_key = <lfs_bnka>-bankl.
                            lwa_out-bank_country  = <lfs_bnka_t012k>-banks.
                            lwa_out-banka = <lfs_bnka>-banka.
                            lwa_out-stras = <lfs_bnka>-stras.
                            lwa_out-ort01 = <lfs_bnka>-ort01.
                            lwa_out-swift = <lfs_bnka>-swift.
                            lwa_out-waers = <lfs_bnka_t012k>-waerk. " Currency Key

                            CONCATENATE <lfs_bnka_t012k>-waerk lc_slash <lfs_bnka_t012k>-bankn INTO lwa_out-bankn.
                            SHIFT lwa_out-bankn LEFT DELETING LEADING lc_slash.

                            APPEND lwa_out TO li_housebank.
                            CLEAR lwa_out.
*<--- End of Insert for D3_OTC_FDD_0016_D3R3 by PDEBARU on 25-Jan-2018

                          ENDIF. " IF sy-subrc IS INITIAL

                        ENDLOOP. " LOOP AT li_bnka_t012k ASSIGNING <lfs_bnka_t012k> FROM lv_index
                      ENDIF. " IF sy-subrc IS INITIAL
                    ENDLOOP. " LOOP AT li_bnka ASSIGNING <lfs_bnka>
                  ENDIF. " IF sy-subrc IS INITIAL
                ENDIF. " IF li_bnka_t012k[] IS NOT INITIAL
              ENDIF. " IF sy-subrc = 0
            ENDIF. " IF li_t012_tmp[] IS NOT INITIAL
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF li_t012k_tmp[] IS NOT INITIAL
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF li_zotc_bank[] IS NOT INITIAL
*---> Begin of Insert for D3_OTC_FDD_0013_CR#301_Part_II by SGHOSH
    SORT li_housebank BY bankn iban.
    DELETE ADJACENT DUPLICATES FROM li_housebank COMPARING bankn iban.
*<--- End of Insert for D3_OTC_FDD_0013_CR#301_Part_II by SGHOSH

* ---> Begin of Insert for CR356 defect#9636 by DMOIRAN

    IF lv_ch_address = abap_true.
      LOOP AT li_housebank ASSIGNING <lfs_bank>.
        READ TABLE li_lines ASSIGNING <lfs_line> INDEX 1.
        IF sy-subrc = 0 AND
          <lfs_line> IS ASSIGNED.
          <lfs_bank>-banka = <lfs_line>-tdline.
        ENDIF. " IF sy-subrc = 0 AND

        READ TABLE li_lines ASSIGNING <lfs_line> INDEX 2.
        IF sy-subrc = 0 AND
          <lfs_line> IS ASSIGNED.
          <lfs_bank>-ort01 = <lfs_line>-tdline.
        ENDIF. " IF sy-subrc = 0 AND
      ENDLOOP. " LOOP AT li_housebank ASSIGNING <lfs_bank>
    ENDIF. " IF lv_ch_address = abap_true
* <--- End    of Insert for CR356 defect#9636 by DMOIRAN
    et_housebank[] = li_housebank[].
  ENDIF. " IF im_mult_housebank_info IS INITIAL
*<--- End of Insert for D3_OTC_FDD_0013_CR#301 by SGHOSH
ENDFUNCTION.
