***********************************************************************
*Program    : ZOTC_DD_EMAIL_SUB_00002050                              *
*Title      : Change the Email Subject line                           *
*Developer  : Sayantan Mukherjee                                      *
*Object type: Function Module                                         *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_FDD_0101                                              *
*---------------------------------------------------------------------*
*Description: Direct debit notification letter                        *
*This is the standard copy of SAMPLE_PROCESS_00002050                 *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*18-NOV-2018  SMUKHER4      E1DK939327     SCTASK0754492:Initial      *
*                                                        Development  *
*19-DEC-2018  SMUKHER4      E1DK939327     Defect# 8019: Split spool  *
*                                          for the customer have same *
*                                          communication method.      *
*---------------------------------------------------------------------*
*19-DEC-2018  SMUKHER4       E1DK940264    Defect# 8217: Don't exit   *
*                                          processing in case Email or*
*                                          otherdetails not found     *
*---------------------------------------------------------------------*
FUNCTION zotc_dd_email_sub_00002050.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_REGUH) LIKE  REGUH STRUCTURE  REGUH
*"     VALUE(I_GJAHR) LIKE  REGUD-GJAHR
*"     VALUE(I_NACHA) LIKE  FINAA-NACHA
*"     VALUE(I_AFORN) LIKE  T042B-AFORN
*"  CHANGING
*"     VALUE(C_ITCPO) LIKE  ITCPO STRUCTURE  ITCPO
*"     VALUE(C_ARCHIVE_INDEX) LIKE  TOA_DARA STRUCTURE  TOA_DARA
*"       DEFAULT SPACE
*"     VALUE(C_ARCHIVE_PARAMS) LIKE  ARC_PARAMS STRUCTURE  ARC_PARAMS
*"       DEFAULT SPACE
*"----------------------------------------------------------------------

  DATA: lv_category     TYPE cccategory,                             " Client control: Role of client (production, test,...)
        lv_subject      TYPE tdtitle,                                " Title in dialog box
        lv_char         TYPE char100,                                " Defect 8217
        lv_prsnr        TYPE ad_persnum,                             " Person number
        lv_adrnr        TYPE adrnr,                                  " Address
        lwa_comm        TYPE addr3_sel,                              " Selection parameter for the address of a person in a company
        lv_return       TYPE ad_retcode,                             " Return code: Address data check error (E,W,I, SPACE)
        lwa_value       TYPE addr3_val,                              " Return structure for the address of a person in a company
        li_lines        TYPE STANDARD TABLE OF tline INITIAL SIZE 0, "SAPscript: Text Lines
        lwa_lines       TYPE tline,                                  " SAPscript: Text Lines
        lv_form_name    TYPE tdobname,                               " Name
        lv_spras        TYPE spras.                                  " Language Key


  CONSTANTS: lc_category  TYPE cccategory VALUE 'P',                         " Client control: Role of client (production, test,...)
             lc_error     TYPE ad_retcode VALUE 'E',                         " Return code: Address data check error (E,W,I, SPACE)
             lc_hiphen    TYPE char1      VALUE '-',                         " Hiphen of type CHAR1
             lc_int       TYPE ad_comm    VALUE 'INT',                       " Communication Method (Key) (Business Address Services)
             lc_name1     TYPE name1_gp   VALUE 'Direct Debit Notification', " Name 1
             lc_form_name TYPE tdobname   VALUE 'ZOTC0101_FORM_NAME',        " Name
             lc_id        TYPE tdid       VALUE 'ST',                        " Material-sales text
             lc_object    TYPE tdobject   VALUE 'TEXT',                      " Order item text
             lc_english   TYPE spras      VALUE 'E'.                         " Language Key


*&--The below logic will only work for the customers.
  IF i_reguh-kunnr IS NOT INITIAL AND i_reguh-lifnr IS INITIAL.

   c_itcpo-TDCOVTITLE+31(10) =  i_reguh-kunnr."Defect 8217

*&-->Begin of changes for D3_OTC_FDD_0101 Defect# 8019 by SMUKHER4 on 19-DEC-2018
*&--Spool has to be splitted based on each customer. Each Customer should have separate spool request.
    CLEAR c_itcpo-tdsuffix2.
    c_itcpo-tdsuffix2 = i_reguh-kunnr.
*&<--End of changes for D3_OTC_FDD_0101 Defect# 8019 by SMUKHER4 on 19-DEC-2018


*&--This FM modifies the subject line of the email.
*&--Fetch the customer maintained language
    SELECT SINGLE spras FROM kna1 INTO lv_spras WHERE kunnr = i_reguh-kunnr.
    IF sy-subrc IS INITIAL.
*&--do nothing
    ENDIF. " IF sy-subrc IS INITIAL
*&--Preparing the email subject line
*&--First Check the Customer maintained language,if not fall back would be on English
*&--Call Function module to fetch the label form name.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_spras
        name                    = lc_form_name
        object                  = lc_object
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

    IF sy-subrc IS INITIAL.

      READ TABLE li_lines INTO lwa_lines INDEX 1.
      IF sy-subrc IS INITIAL.
        lv_form_name = lwa_lines-tdline.
      ENDIF. " IF sy-subrc IS INITIAL

      CLEAR lwa_lines.

    ELSE. " ELSE -> IF sy-subrc IS INITIAL

      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = lc_id
          language                = lc_english
          name                    = lc_form_name
          object                  = lc_object
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

      IF sy-subrc IS INITIAL.

        READ TABLE li_lines INTO lwa_lines INDEX 1.
        IF sy-subrc IS INITIAL.
          lv_form_name = lwa_lines-tdline.
        ENDIF. " IF sy-subrc IS INITIAL

        CLEAR lwa_lines.
      ENDIF. " IF sy-subrc IS INITIAL

    ENDIF. " IF sy-subrc IS INITIAL

*&--The Name1 value will always be maintain as constant value in the table. It will not check the
*--language key.

*&Fetch contact person
    SELECT prsnr UP TO 1 ROWS FROM knvk INTO lv_prsnr
               WHERE kunnr = i_reguh-kunnr
               AND   name1 = lc_name1
               AND   loevm = space.
    ENDSELECT.

    IF sy-subrc IS NOT INITIAL.
      CLEAR lv_char.
      CONCATENATE 'Contact Person is not available for '(001) i_reguh-kunnr
       INTO lv_char SEPARATED BY space. " Defect 8217
      MESSAGE lv_char TYPE 'S'. " Defect 8217
*      MESSAGE 'Contact Person is not available'(001)TYPE 'I'.
*      LEAVE LIST-PROCESSING.  " Defect 8217
*      RETURN. " Defect 8217
    ENDIF. " IF sy-subrc IS NOT INITIAL

*&--fetch address number
*  SELECT SINGLE adrnr FROM kna1 INTO lv_adrnr
*               WHERE kunnr = i_reguh-kunnr.
    SELECT adrnr " Customer Number
    UP TO 1 ROWS
   FROM kna1     " General Data in Customer Master
   INTO lv_adrnr
   WHERE kunnr = i_reguh-kunnr
    AND loevm EQ space.
    ENDSELECT.
    IF sy-subrc IS NOT INITIAL.
*      CLEAR lv_char. " Defect 8217
*      CONCATENATE 'Address Number is not available for '(002) i_reguh-kunnr
*       INTO lv_char SEPARATED BY space. " Defect 8217
*      MESSAGE lv_char TYPE 'S'. " Defect 8217
*      MESSAGE 'Address Number is not available'(002) TYPE 'I'.
*      LEAVE LIST-PROCESSING.  " Defect 8217
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
*&--The logic holds good only when the communication method is maintained as Internet mail.
      IF lwa_value-deflt_comm = lc_int.

        SELECT SINGLE cccategory INTO lv_category FROM t000 " Company Codes
               WHERE mandt = sy-mandt.
* Check if Production Client is not
        IF lv_category NE lc_category.
*&--* For non-prod systems,Populate the subject line with system id and company code
*          CONCATENATE 'Direct debit notification'(004) sy-sysid lc_hiphen i_reguh-zbukr INTO lv_subject SEPARATED BY space.
          CONCATENATE lv_form_name sy-sysid lc_hiphen i_reguh-zbukr i_reguh-kunnr INTO lv_subject SEPARATED BY space.
          CLEAR: c_itcpo-tdtitle.

          c_itcpo-tdtitle = lv_subject.

        ELSE. " ELSE -> IF lv_category NE lc_category
          CLEAR: c_itcpo-tdtitle.
          c_itcpo-tdtitle = lv_form_name.
        ENDIF. " IF lv_category NE lc_category
      ENDIF. " IF lwa_value-deflt_comm = lc_int

    ENDIF. " IF lwa_comm IS NOT INITIAL
  ENDIF. " IF i_reguh-kunnr IS NOT INITIAL AND i_reguh-lifnr IS INITIAL



ENDFUNCTION.
