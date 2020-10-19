*************************************************************************
** PROGRAM    :  ZXEDFU02                                               *
** TITLE      :  D3_OTC_IDD_0011                                        *
** DEVELOPER  :  Abdulla Mangalore                                      *
** OBJECT TYPE:  Interface                                              *
** SAP RELEASE:  SAP ECC 6.0                                            *
**----------------------------------------------------------------------*
** WRICEF ID  :  D3_OTC_IDD_0011                                        *
**----------------------------------------------------------------------*
** DESCRIPTION: Outbound Customer Invoices EDI 810                      *
**----------------------------------------------------------------------*
** MODIFICATION HISTORY:                                                *
**======================================================================*
** DATE         USER      TRANSPORT   DESCRIPTION                       *
** ===========  ========  ==========  ==================================*
** 24-Aug-207  amangal  E1DK930202 French E-Invoicing change:           *
**                                 Effective 1st January 2018, all      *
**                                 invoices for French Public institute *
**                                 should be sent by e-invoice.         *
**                                 Legal requirement for French Public  *
**                                 Customers                            *
*                                 SCTASK0555123                         *
*************************************************************************
** 09-Mar-2018 SMUKHER4 E1DK935113 Defect# 5150:Bank details are updated*
**                                 inconsistently for multiple invoices *
**                                 for segment E1EDK28.
*************************************************************************
** 10-Sep-2019 U030946 E2DK926642 Def#10388/INC0505671-02:Check current *
*                                 segment check(E1EDKA1) has been added *
*************************************************************************
*&---------------------------------------------------------------------*
*&  Include           ZOTCN0111B_FRENCH_E_INVOICING
*&---------------------------------------------------------------------*

  DATA: lv_stcd2               TYPE stcd2,                             " Tax Number 2
        wa_e1edka1             TYPE e1edka1,                         " IDoc: Document Header Partner Information
        lv_flag                TYPE flag,                               " General Flag
        lv_french_e_inv_flg    TYPE flag,                   " General Flag
        fp_i_status            TYPE TABLE OF zdev_enh_status,       " Enhancement Status
        lv_iban                TYPE iban,                               " IBAN (International Bank Account Number)
        wa_z1otc_e1edk28_zeinv TYPE z1otc_e1edk28_zeinv, " French E-Invoicing change: SCTASK0555123
        wa_e1edk28             TYPE e1edk28,                         " IDoc: Document Header Bank Data
        lv_vfdat               TYPE vfdat,                             " Shelf Life Expiration or Best-Before Date
        wa_e1edp03             TYPE e1edp03,                         " IDoc: Document Item Date Segment
        wa_z1otc_e1edka1_einv  TYPE z1otc_e1edka1_einv,   " French E-Invoicing change: SCTASK0555123
        wa_edidd               TYPE edidd,                             " Data record (IDoc)
        lv_waerk               TYPE waerk,                             " SD Document Currency
        ls_housebank           TYPE zotc_housebank,                " Structure for House Bank Info
        lv_index2              TYPE sy-index,                         " Loop Index
        ls_edidd               TYPE edidd,                             " Data record (IDoc)
        ls_sdata               TYPE edidd-sdata.                       " Application data


  FIELD-SYMBOLS: <fs_e1edk28> TYPE e1edk28,        " IDoc: Document Header Bank Data
                 <fs_xtvbdpr> TYPE vbdpr,          " Document Item View for Billing
                 <fs_status>  TYPE zdev_enh_status. " Enhancement Status


*
**------------------------Local Constants -----------------------*
  CONSTANTS :

*&--EMI Table Entries:
    lc_enh_0011  TYPE z_enhancement VALUE 'OTC_IDD_0011',       " Enhancement No.
    lc_frinv     TYPE z_criteria    VALUE 'FRENCH_E_INVOICING', " Enh. Criteria
* ---> Begin of Insert for D3_OTC_IDD_0011_Defect#10388_INC0505671_02 by U030946 on 10-SEP-2019
    lc_s_e1edka1 TYPE char7         VALUE 'E1EDKA1'.            "Segment name
* <--- End of Insert for D3_OTC_IDD_0011_Defect#10388_INC0505671_02 by U030946 on 10-SEP-2019


* FM fetches EMI Entries
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_0011
    TABLES
      tt_enh_status     = fp_i_status.

*&-- Delete Inactive Records
  DELETE fp_i_status WHERE active IS INITIAL.

  READ TABLE fp_i_status WITH KEY criteria = 'NULL'
                                   TRANSPORTING NO FIELDS.

  IF sy-subrc EQ 0.
    LOOP AT fp_i_status ASSIGNING <fs_status>.

      IF <fs_status>-criteria EQ lc_frinv
         AND <fs_status>-active EQ abap_true.
        lv_french_e_inv_flg = <fs_status>-sel_low.
      ENDIF. " IF <fs_status>-criteria EQ lc_frinv

    ENDLOOP. " LOOP AT fp_i_status ASSIGNING <fs_status>
  ENDIF. " IF sy-subrc EQ 0

  IF lv_french_e_inv_flg = 'X'. "EMI check
    lv_flag = 'N'.

    IF int_edidd-sdata+0(3) = lc_parvw_ag.
      READ TABLE int_edidd ASSIGNING <lfs_edidd> WITH KEY segnam = 'E1EDKA1' sdata+0(3) = lc_parvw_ag.
* ---> Begin of Insert for D3_OTC_IDD_0011_Defect#10388_INC0505671_02 by U030946 on 10-SEP-2019
* Set the flag for current segment E1EDKA1 only, so that Z1OTC_E1EDKA1_EINV segment should
*populate only for E1EDKA1.
      IF int_edidd-segnam = lc_s_e1edka1.    "E1EDKA1 segment check
* <--- End of Insert for D3_OTC_IDD_0011_Defect#10388_INC0505671_02 by U030946 on 10-SEP-2019
        lv_flag = 'Y'.
* ---> Begin of Insert for D3_OTC_IDD_0011_Defect#10388_INC0505671_02 by U030946 on 10-SEP-2019
      ENDIF.
* <--- End of Insert for D3_OTC_IDD_0011_Defect#10388_INC0505671_02 by U030946 on 10-SEP-2019
    ELSEIF int_edidd-sdata+0(3) = lc_parvw_we.
      READ TABLE int_edidd ASSIGNING <lfs_edidd> WITH KEY segnam = 'E1EDKA1' sdata+0(3) = lc_parvw_we.
* ---> Begin of Insert for D3_OTC_IDD_0011_Defect#10388_INC0505671_02 by U030946 on 10-SEP-2019
* Set the flag for current segment E1EDKA1 only, so that Z1OTC_E1EDKA1_EINV segment should
*populate only for E1EDKA1.
      IF int_edidd-segnam = lc_s_e1edka1.    "E1EDKA1 segment check
* <--- End of Insert for D3_OTC_IDD_0011_Defect#10388_INC0505671_02 by U030946 on 10-SEP-2019
        lv_flag = 'Y'.
* ---> Begin of Insert for D3_OTC_IDD_0011_Defect#10388_INC0505671_02 by U030946 on 10-SEP-2019
      ENDIF.
* <--- End of Insert for D3_OTC_IDD_0011_Defect#10388_INC0505671_02 by U030946 on 10-SEP-2019
    ELSEIF int_edidd-sdata+0(3) = lc_parvw_re.
      READ TABLE int_edidd ASSIGNING <lfs_edidd> WITH KEY segnam = 'E1EDKA1' sdata+0(3) = lc_parvw_re.
* ---> Begin of Insert for D3_OTC_IDD_0011_Defect#10388_INC0505671_02 by U030946 on 10-SEP-2019
* Set the flag for current segment E1EDKA1 only, so that Z1OTC_E1EDKA1_EINV segment should
*populate only for E1EDKA1.
      IF int_edidd-segnam = lc_s_e1edka1.    "E1EDKA1 segment check
* <--- End of Insert for D3_OTC_IDD_0011_Defect#10388_INC0505671_02 by U030946 on 10-SEP-2019
        lv_flag = 'Y'.
* ---> Begin of Insert for D3_OTC_IDD_0011_Defect#10388_INC0505671_02 by U030946 on 10-SEP-2019
      ENDIF.
* <--- End of Insert for D3_OTC_IDD_0011_Defect#10388_INC0505671_02 by U030946 on 10-SEP-2019
    ENDIF. " IF int_edidd-sdata+0(3) = lc_parvw_ag

    IF lv_flag = 'Y'.
      lv_kunnr = <lfs_edidd>-sdata+3(10).

      IF lv_kunnr NE space.

        SELECT SINGLE stcd1 stcd2
          INTO (lv_stcd1, lv_stcd2)
          FROM kna1 " General Data in Customer Master
          WHERE kunnr = lv_kunnr.

        IF sy-subrc EQ 0.

          wa_z1otc_e1edka1_einv-stcd1 = lv_stcd1.
          wa_z1otc_e1edka1_einv-stcd2 = lv_stcd2.

          wa_edidd = int_edidd.

          wa_edidd-segnam = 'Z1OTC_E1EDKA1_EINV'.

          CLEAR wa_edidd-sdata.

          MOVE wa_z1otc_e1edka1_einv TO wa_edidd-sdata.

          APPEND  wa_edidd TO int_edidd.

        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF lv_kunnr NE space
    ENDIF. " IF lv_flag = 'Y'



    IF int_edidd-segnam = 'E1EDK28'.

*&-->Begin of delete for Defect# 5150 D3_OTC_IDD_0011 by SMUKHER4 on 09-Mar-2018
*&--Commented since this flag is not getting updated for multiple invoices.
*      IMPORT lv_flag FROM MEMORY ID 'ZOTC_EDD_0011_FLAG'.
*&<--End of delete for Defect# 5150 D3_OTC_IDD_0011 by SMUKHER4 on 09-Mar-2018

*&-->Begin of insert for Defect# 5150 D3_OTC_IDD_0011 by SMUKHER4 on 09-Mar-2018
*&--We are using document number for IMPORT EXPOERT since it will change for each invoice.
      IMPORT lv_belnr FROM MEMORY ID 'ZOTC_EDD_0011_FLAG'.


*      IF lv_flag EQ space.
*&<--End of insert for Defect# 5150 D3_OTC_IDD_0011 by SMUKHER4 on 09-Mar-2018
      READ TABLE int_edidd INTO lwa_edidd WITH KEY segnam = 'E1EDKA1' sdata+0(3) = 'BK'.
      IF sy-subrc = 0.
*Get billing document number
        CLEAR : lwa_edidd ,
                lv_belnr,
                lv_bukrs,
                lv_adrnr,
                lwa_add.

        READ TABLE int_edidd INTO lwa_edidd WITH KEY segnam = 'E1EDK01'.
        IF sy-subrc = 0.
*&-->Begin of insert for Defect# 5150 D3_OTC_IDD_0011 by SMUKHER4 on 09-Mar-2018
*&--Checking with the current document number. If matches then exit else fall back with the existing logic.
          IF lv_belnr = lwa_edidd-sdata+83(35).
            EXIT.
          ENDIF. " IF lv_belnr = lwa_edidd-sdata+83(35)
*&<--End of insert for Defect# 5150 D3_OTC_IDD_0011 by SMUKHER4 on 09-Mar-2018
          lv_belnr = lwa_edidd-sdata+83(35).
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lv_belnr
            IMPORTING
              output = lv_belnr.
        ENDIF. " IF sy-subrc = 0

      ENDIF. " IF sy-subrc = 0

      LOOP AT int_edidd ASSIGNING <lfs_edidd>
        WHERE segnam = 'Z1OTC_E1EDK28_ZEINV'.
        lv_flag = 'X'.
        EXIT.
      ENDLOOP. " LOOP AT int_edidd ASSIGNING <lfs_edidd>

      IF lv_flag NE 'X'.

        READ TABLE int_edidd ASSIGNING <lfs_edidd>.

        IF <lfs_edidd> IS ASSIGNED AND lv_belnr NE space.

          wa_e1edk28 = <lfs_edidd>-sdata.

*Get company code, currency from VBRK
          SELECT SINGLE bukrs waerk " Company Code
                 FROM   vbrk        " Billing Document: Header Data
                 INTO   (lv_bukrs, lv_waerk)
                 WHERE  vbeln = lv_belnr.

          IF sy-subrc EQ 0.

            CALL FUNCTION 'ZOTC_GET_HOUSEBANKINFO'
              EXPORTING
                im_bukrs = lv_bukrs
                im_curr  = lv_waerk
              IMPORTING
                ex_out   = ls_housebank.

            IF ls_housebank-iban IS NOT INITIAL.

              MOVE ls_housebank-bank_country  TO wa_e1edk28-bcoun.
              MOVE ls_housebank-bank_key TO wa_e1edk28-brnum.
              MOVE ls_housebank-banka TO wa_e1edk28-bname.
              MOVE ls_housebank-ort01 TO wa_e1edk28-baloc.
              MOVE ls_housebank-bankn TO wa_e1edk28-acnum.

              <lfs_edidd>-sdata = wa_e1edk28.

              wa_z1otc_e1edk28_zeinv-iban = ls_housebank-iban.

              wa_edidd = int_edidd.

              wa_edidd-segnam = 'Z1OTC_E1EDK28_ZEINV'.

              CLEAR wa_edidd-sdata.

              MOVE wa_z1otc_e1edk28_zeinv TO wa_edidd-sdata.

              APPEND  wa_edidd TO int_edidd.
*&-->Begin of delete for Defect# 5150 D3_OTC_IDD_0011 by SMUKHER4 on 09-Mar-2018
*                lv_flag = 'X'.

*                EXPORT lv_flag TO MEMORY ID 'ZOTC_EDD_0011_FLAG'.  "D3
*&<--End of delete for Defect# 5150 D3_OTC_IDD_0011 by SMUKHER4 on 09-Mar-2018

*&-->Begin of insert for Defect# 5150 D3_OTC_IDD_0011 by SMUKHER4 on 09-Mar-2018
              EXPORT lv_belnr TO MEMORY ID 'ZOTC_EDD_0011_FLAG'.
*&<--End of insert for Defect# 5150 D3_OTC_IDD_0011 by SMUKHER4 on 09-Mar-2018

            ENDIF. " IF ls_housebank-iban IS NOT INITIAL

          ENDIF. " IF sy-subrc EQ 0

        ENDIF. " IF <lfs_edidd> IS ASSIGNED AND lv_belnr NE space

*        ENDIF. " IF lv_flag NE 'X'  " Defect 5150

      ELSE. " ELSE -> IF lv_flag EQ space

*        READ TABLE int_edidd ASSIGNING <lfs_edidd>.

        lv_flag = space.

        DESCRIBE TABLE int_edidd LINES lv_index2.

        IF lv_index2 IS NOT INITIAL.
          DELETE int_edidd INDEX lv_index2.
        ENDIF. " IF lv_index2 IS NOT INITIAL

      ENDIF. " IF lv_flag EQ space

    ENDIF. " IF int_edidd-segnam = 'E1EDK28'

    IF int_edidd-segnam = 'E1EDP03'.

      READ TABLE int_edidd ASSIGNING <lfs_edidd> WITH KEY segnam = 'E1EDP03'
                sdata+0(3) = '045'.

      IF sy-subrc NE 0.

        READ TABLE int_edidd ASSIGNING <lfs_edidd> WITH KEY segnam = 'E1EDP03'.

        IF <lfs_edidd> IS ASSIGNED.

          READ TABLE xtvbdpr ASSIGNING <fs_xtvbdpr> INDEX 1.

          IF <fs_xtvbdpr> IS ASSIGNED.

            SELECT SINGLE vfdat " Shelf Life Expiration or Best-Before Date
             INTO lv_vfdat
             FROM mch1          " Batches (if Batch Management Cross-Plant)
             WHERE matnr EQ <fs_xtvbdpr>-matnr
             AND charg EQ <fs_xtvbdpr>-charg.

            IF sy-subrc EQ 0.

              wa_edidd-segnam = 'E1EDP03'.
              wa_e1edp03-datum = lv_vfdat.
              wa_e1edp03-iddat = '045'.
              wa_e1edp03-uzeit = space.
              wa_edidd-sdata = wa_e1edp03.

              APPEND  wa_edidd TO int_edidd.

            ENDIF. " IF sy-subrc EQ 0

          ENDIF. " IF <fs_xtvbdpr> IS ASSIGNED

        ENDIF. " IF <lfs_edidd> IS ASSIGNED

      ENDIF. " IF sy-subrc NE 0

    ENDIF. " IF int_edidd-segnam = 'E1EDP03'

  ENDIF. " IF lv_french_e_inv_flg = 'X'
