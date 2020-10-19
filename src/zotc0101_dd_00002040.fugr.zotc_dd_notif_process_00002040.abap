***********************************************************************
*Program    : ZOTC_DD_NOTIF_PROCESS_00002040                          *
*Title      : Check Standard Communication Method                     *
*Developer  : Sayantan Mukherjee                                      *
*Object type: Function Module                                         *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_FDD_0101                                              *
*---------------------------------------------------------------------*
*Description: Direct debit notification letter                        *
*This is the standard copy of SAMPLE_PROCESS_00002040                 *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*18-NOV-2018  SMUKHER4      E1DK939327     SCTASK0754492:Initial      *
*                                                        Development  *
*---------------------------------------------------------------------*
*19-DEC-2018  SMUKHER4       E1DK940264     Defect# 8217: Don't exit   *
*                                          processing in case Email or*
*                                          otherdetails not found     *
*---------------------------------------------------------------------*
FUNCTION zotc_dd_notif_process_00002040.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_REGUH) LIKE  REGUH STRUCTURE  REGUH
*"  TABLES
*"      T_FIMSG STRUCTURE  FIMSG
*"  CHANGING
*"     VALUE(C_FINAA) LIKE  FINAA STRUCTURE  FINAA
*"----------------------------------------------------------------------

*&--Local Data Declaration
  DATA:  lv_prsnr                TYPE ad_persnum, " Person number
         lwa_comm                TYPE addr3_sel,  " Selection parameter for the address of a person in a company
         lv_char                 TYPE char100,    " Defect 8217
         lwa_fimsg               TYPE fimsg,      "Defect 8217
         lv_return               TYPE ad_retcode, " Return code: Address data check error (E,W,I, SPACE)
         lwa_value               TYPE addr3_val,  " Return structure for the address of a person in a company
         lv_adrnr                TYPE adrnr,      " Address
         lv_fax                  TYPE ad_fxnrlng, " Complete number: dialling code+number+extension
         lv_email_comm           TYPE ad_smtpadr, " E-Mail Address
         lv_remit_bukrs          TYPE vkbuk,      " Company code of the sales organization
         lv_email_sender         TYPE ad_smtpadr, " E-Mail Address
         lv_adrnr_t001           TYPE adrnr.      " Address


*&--Local Constants
  CONSTANTS: lc_int             TYPE ad_comm          VALUE 'INT',                            " Communication Method (Key) (Business Address Services)
             lc_prt             TYPE ad_comm          VALUE 'PRT',                            " Communication Method (Key) (Business Address Services)
             lc_fax             TYPE ad_comm          VALUE 'FAX',                            " Communication Method (Key) (Business Address Services)
             lc_name1           TYPE name1_gp         VALUE 'Direct Debit Notification',      " Name 1
             lc_error           TYPE ad_retcode       VALUE 'E',                              " Return code: Address data check error (E,W,I, SPACE)
             lc_i               TYPE fi_nacha         VALUE 'I',                              " Transmission Medium for Correspondence
             lc_1               TYPE fi_nacha         VALUE '1',                              " Transmission Medium for Correspondence
             lc_2               TYPE fi_nacha         VALUE '2',                              " Transmission Medium for Correspondence
             lc_mprogram        TYPE programm         VALUE 'ZOTCP0013O_MONTHLY_OPEN_AR_STM', "ABAP Program Name
             lc_param_bukrs     TYPE enhee_parameter  VALUE 'Z_REMIT_TO_ADDRESS',             " Parameter
             lc_soption         TYPE char2            VALUE 'EQ'.                             "Selection Option


*&This FM checks the standard communication method of the customer and sends the form in attached PDF format
* by mail and FAX.
*&--The below logic will only work for the customers only.
  IF i_reguh-kunnr IS NOT INITIAL AND i_reguh-lifnr IS INITIAL.

*&--Retrieve the sender email address
*&--Fetching company code 2068 from ZOTC_PRC_CONTROL table for remit to address

    SELECT mvalue2           " Select Options: Value High
      UP TO 1 ROWS
       FROM zotc_prc_control " OTC Process Team Control Table
       INTO lv_remit_bukrs
       WHERE vkorg = i_reguh-zbukr
        AND mprogram   = lc_mprogram
        AND mparameter = lc_param_bukrs
        AND mactive    = abap_true
        AND soption    = lc_soption.
    ENDSELECT.

    IF sy-subrc IS INITIAL AND lv_remit_bukrs IS NOT INITIAL.
*&--Fetch the address number
      SELECT SINGLE adrnr FROM t001 INTO lv_adrnr_t001
                    WHERE bukrs = lv_remit_bukrs.

      IF sy-subrc IS INITIAL.
*&--Fetch contact email address
        SELECT smtp_addr " E-Mail Address
           UP TO 1 ROWS
           FROM adr6     " E-Mail Addresses (Business Address Services)
           INTO lv_email_sender
       WHERE addrnumber = lv_adrnr_t001.
        ENDSELECT.

      ENDIF. " IF sy-subrc IS INITIAL

      IF sy-subrc IS INITIAL.
*&--Do nothing
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL AND lv_remit_bukrs IS NOT INITIAL
*&--The Name1 value will always be maintain as constant value in the table. It will not check the
*--language key.
*&Fetch contact person
    SELECT prsnr UP TO 1 ROWS FROM knvk INTO lv_prsnr
               WHERE kunnr = i_reguh-kunnr
               AND   name1 = lc_name1
               AND   loevm = space.
    ENDSELECT.

    IF sy-subrc IS NOT INITIAL.
      CLEAR lv_char. " Defect 8217
      lv_char = 'Contact Person is not available for '(001) .
      CLEAR lwa_fimsg.
      lwa_fimsg-msort = '1'.
      lwa_fimsg-msgid = 'ZOTC_MSG'.
      lwa_fimsg-msgty = 'I'.
      lwa_fimsg-msgno = '108'.
      lwa_fimsg-msgv1 = lv_char.
      lwa_fimsg-msgv2 = i_reguh-kunnr.
      APPEND lwa_fimsg TO t_fimsg.
*      MESSAGE lv_char TYPE 'S'. " Defect 8217
*      MESSAGE 'Contact Person is not available'(001) TYPE 'I'.
*      LEAVE LIST-PROCESSING." Defect 8217
*      RETURN. " Defect 8217
    ENDIF. " IF sy-subrc IS NOT INITIAL

*&--fetch address number
*  SELECT SINGLE adrnr FROM kna1 INTO lv_adrnr
*               WHERE kunnr = i_reguh-kunnr.
    SELECT adrnr " Customer Number
      UP TO 1 ROWS
      FROM kna1  " General Data in Customer Master
      INTO lv_adrnr
      WHERE kunnr = i_reguh-kunnr
        AND loevm EQ space.
    ENDSELECT.
    IF sy-subrc IS NOT INITIAL.
      CLEAR lv_char. " Defect 8217
      lv_char = 'Address Number is not available for '(002) .

      lwa_fimsg-msort = '1'.
      lwa_fimsg-msgid = 'ZOTC_MSG'.
      lwa_fimsg-msgty = 'I'.
      lwa_fimsg-msgno = '108'.
      lwa_fimsg-msgv1 = lv_char.
      lwa_fimsg-msgv2 = i_reguh-kunnr.
      APPEND lwa_fimsg TO t_fimsg.
*      MESSAGE lv_char TYPE 'S'. " Defect 8217
*      MESSAGE 'Address Number is not available'(002) TYPE 'I'.
*      LEAVE LIST-PROCESSING." Defect 8217
*      RETURN. " Defect 8217
    ENDIF. " IF sy-subrc IS NOT INITIAL

    IF lv_prsnr IS NOT INITIAL AND lv_adrnr IS NOT INITIAL.
      lwa_comm-persnumber = lv_prsnr.
      lwa_comm-addrnumber = lv_adrnr.
    ENDIF. " IF lv_prsnr IS NOT INITIAL AND lv_adrnr IS NOT INITIAL

    IF lwa_comm IS NOT INITIAL.

*&--Call FM to get the communication method
      CALL FUNCTION 'ADDR_PERS_COMP_GET'
        EXPORTING
          address_pers_in_comp_selection = lwa_comm
        IMPORTING
          address_pers_in_comp_value     = lwa_value
          returncode                     = lv_return.

*&--Since this FM has no exception, sy-subrc check is not required since it will always set as 0.
      IF lv_return = lc_error.
        RETURN.
      ENDIF. " IF lv_return = lc_error


*&-->Customer communication method is not relevant (in case comm. Method is not Print , email or Fax)
      IF NOT ( lwa_value-deflt_comm EQ lc_fax OR
               lwa_value-deflt_comm EQ lc_int OR
               lwa_value-deflt_comm EQ lc_prt ).

        CLEAR lv_char. " Defect 8217
        lv_char = 'Communication Method is not relevant for '(003).

        lwa_fimsg-msgid = 'ZOTC_MSG'.
        lwa_fimsg-msort = '1'.
        lwa_fimsg-msgty = 'I'.
        lwa_fimsg-msgno = '108'.
        lwa_fimsg-msgv1 = lv_char.
        lwa_fimsg-msgv2 = i_reguh-kunnr.
        APPEND lwa_fimsg TO t_fimsg.
*        MESSAGE lv_char TYPE 'I'. " Defect 8217

*        MESSAGE 'Communication Method is not relevant'(003) TYPE 'I'.
*        LEAVE LIST-PROCESSING. " Defect 8217
*        RETURN. " Defect 8217
      ENDIF. " IF NOT ( lwa_value-deflt_comm EQ lc_fax OR

*&--If communication method is FAX, populate FAX#.Form attachment will send to this Fax number
      IF lwa_value-deflt_comm = lc_fax.
*&--Populate FAX #
        SELECT faxnr_long UP TO 1 ROWS FROM adr3 " Fax Numbers (Business Address Services)
             INTO lv_fax WHERE persnumber = lv_prsnr.
        ENDSELECT.
        IF sy-subrc IS INITIAL.
          c_finaa-nacha      = lc_2.
          c_finaa-tdschedule = 'IMM'.
          c_finaa-tdteleland = i_reguh-zland.
          c_finaa-tdtelenum  = lv_fax.
          c_finaa-formc      = 'FI_FAX_COVER_A4'.
        ENDIF. " IF sy-subrc IS INITIAL
* Begin of " Defect 8217
          IF lv_fax IS INITIAL.

            CLEAR lv_char. " Defect 8217
            lv_char = 'Fax number is not maintained for '(010).

            lwa_fimsg-msgid = 'ZOTC_MSG'.
            lwa_fimsg-msort = '1'.
            lwa_fimsg-msgty = 'I'.
            lwa_fimsg-msgno = '108'.
            lwa_fimsg-msgv1 = lv_char.
            lwa_fimsg-msgv2 = i_reguh-kunnr.
            APPEND lwa_fimsg TO t_fimsg.

          ENDIF. " if lv_email_comm is initial
      ELSE. " ELSE -> IF lwa_value-deflt_comm = lc_fax
*&--If communication method is Internet mail, populate mail id.Form attachment will send to this email address
        IF lwa_value-deflt_comm = lc_int.
*&--Populate EMAIL
          SELECT smtp_addr UP TO 1 ROWS FROM adr6 " E-Mail Addresses (Business Address Services)
            INTO lv_email_comm WHERE persnumber = lv_prsnr.
          ENDSELECT.

          IF sy-subrc IS INITIAL.
            c_finaa-nacha = lc_i.
            c_finaa-intad = lv_email_comm.
            c_finaa-mail_send_addr = lv_email_sender.
          ENDIF. " IF sy-subrc IS INITIAL
* Begin of " Defect 8217
          IF lv_email_comm IS INITIAL.

            CLEAR lv_char. " Defect 8217
            lv_char = 'Email id is not maintained for'(011).

            lwa_fimsg-msgid = 'ZOTC_MSG'.
            lwa_fimsg-msort = '1'.
            lwa_fimsg-msgty = 'I'.
            lwa_fimsg-msgno = '108'.
            lwa_fimsg-msgv1 = lv_char.
            lwa_fimsg-msgv2 = i_reguh-kunnr.
            APPEND lwa_fimsg TO t_fimsg.

          ENDIF. " if lv_email_comm is initial
*           * ENDOF " Defect 8217
        ELSE. " ELSE -> IF lwa_value-deflt_comm = lc_int
*&--When communication method is printer , set the default value as 1
          IF lwa_value-deflt_comm = lc_prt.
*default: print payment advice
            c_finaa-nacha = lc_1.

          ELSE. " ELSE -> IF lwa_value-deflt_comm = lc_prt
*&--If no communication method is found, form should not be generated.
            IF lwa_value-deflt_comm IS INITIAL.
              RETURN.
            ENDIF. " IF lwa_value-deflt_comm IS INITIAL

          ENDIF. " IF lwa_value-deflt_comm = lc_prt

        ENDIF. " IF lwa_value-deflt_comm = lc_int
      ENDIF. " IF lwa_value-deflt_comm = lc_fax

    ENDIF. " IF lwa_comm IS NOT INITIAL

  ENDIF. " IF i_reguh-kunnr IS NOT INITIAL AND i_reguh-lifnr IS INITIAL

ENDFUNCTION.
