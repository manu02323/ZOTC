FUNCTION zotc_standard_communication.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_ADRNR) TYPE  ADRNR
*"     REFERENCE(IM_SUBJECT) TYPE  SO_OBJ_DES OPTIONAL
*"     REFERENCE(IM_FORM_OUTPUT) TYPE  FPFORMOUTPUT
*"     REFERENCE(IM_T_TEXT) TYPE  BCSY_TEXT OPTIONAL
*"     REFERENCE(IM_ATTACHMENT_NAME) TYPE  SOOD-OBJDES OPTIONAL
*"     REFERENCE(IM_TLFXS) TYPE  TLFXS OPTIONAL
*"     REFERENCE(IM_INTAD) TYPE  INTAD OPTIONAL
*"     REFERENCE(IM_ADRNR_SENDER) TYPE  ADRNR OPTIONAL
*"  EXPORTING
*"     REFERENCE(EX_STATUS) TYPE  STRING
*"     REFERENCE(EX_PRINT_DOC) TYPE  BOOLEAN
*"  EXCEPTIONS
*"      NO_EMAIL_ADDRESS
*"      NO_FAX_NUMBER
*"      MAIL_FAILURE
*"      FAX_FAILURE
*"----------------------------------------------------------------------
************************************************************************
* FUNCTION MODULE: ZOTC_STANDARD_COMMUNICATION                         *
* TITLE          : External Communication for Mail/Fax/Print           *
* DEVELOPER      : Vivek Gaur                                          *
* OBJECT TYPE    : Function Module                                     *
* SAP RELEASE    : SAP ECC 6.0                                         *
*----------------------------------------------------------------------*
* WRICEF ID      : OTC_FDD_0013_Monthly Open AR Statement              *
*----------------------------------------------------------------------*
* DESCRIPTION    : This FM will be used to send E-mail/Fax/Print to the*
*                  receiver based on the default communication type of *
*                  receiver                                            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* Date         User      Transport  Description                        *
* ===========  ========  ========== ===================================*
* 14-MAY-2012  VGAUR     E1DK901190 Initial development                *
* 21-Sep-2016  NALI    E1DK921941 D3_OTC_FDD_0013 - D3 changes - Send  *
*                                 Houe Bank Info to the form output,   *
*                                 replace the remit to address with the*
*                                 organisation address for D3          *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  C O N S T A N T S
*&---------------------------------------------------------------------*
  CONSTANTS:
    lc_int             TYPE ad_comm   VALUE 'INT', "Communiaction Type Mail
    lc_fax             TYPE ad_comm   VALUE 'FAX', "Communiaction Type Fax
    lc_pdf             TYPE so_obj_tp VALUE 'PDF'. "PDF Object Type

  DATA:
*&---------------------------------------------------------------------*
*&  V A R I A B L E S
*&---------------------------------------------------------------------*
    lv_comm_type       TYPE ad_comm,     "Default Communication Type
    lv_emailaddr       TYPE ad_smtpadr,  "E-Mail Address
    lv_pdf_siz         TYPE so_obj_len,  "PDF Size
    lv_subject         TYPE so_obj_des,  "Mail Subject
    lv_fax_number      TYPE ad_fxnmbr1,  "First fax no.: dialling code+number
    lv_country         TYPE land1,       "Fax Country
    lv_attachment_name TYPE sood-objdes, "Attachment Name
*---> Begin of Change for D3_OTC_FDD_0013 by NALI
    lv_sender_email    TYPE ad_smtpadr, " E-Mail Address
*<--- End of Change for D3_OTC_FDD_0013 by NALI

*&---------------------------------------------------------------------*
*&  R E F E R E N C E   V A R I A B L E S
*&---------------------------------------------------------------------*
    lv_send_request    TYPE REF TO cl_bcs,           "Business Communication Service
    lv_document        TYPE REF TO cl_document_bcs,  "Wrapper Class for Office Documents
    lv_recipient       TYPE REF TO if_recipient_bcs, "Interface of Recipient Object in BCS
*---> Begin of Change for D3_OTC_FDD_0013 by NALI
    lo_sender TYPE REF TO if_sender_bcs VALUE IS INITIAL, " Interface of Sender Object in BCS
*<--- End of Change for D3_OTC_FDD_0013 by NALI
*&---------------------------------------------------------------------*
*&  I N T E R N A L   T A B L E S
*&---------------------------------------------------------------------*
    li_pdf_content     TYPE solix_tab. "SAPoffice: Binary data

  CLEAR: ex_status.

*&--Fetch Default Communication Type
  SELECT deflt_comm "Default Communication Type
          country   "Country Key
         fax_number "First fax no.: dialling code+number
   UP TO 1 ROWS
    INTO (lv_comm_type, lv_country, lv_fax_number)
    FROM adrc       " Addresses (Business Address Services)
   WHERE addrnumber = im_adrnr.
  ENDSELECT.
  IF sy-subrc  = 0.

*&--If Communication Type is Mail
    IF lv_comm_type = lc_int.
*&--Fetch Customer E-Mail Address
      SELECT smtp_addr "E-Mail Address
       UP TO 1 ROWS
        FROM adr6      " E-Mail Addresses (Business Address Services)
         INTO lv_emailaddr
       WHERE addrnumber = im_adrnr.
      ENDSELECT.
    ENDIF. " IF lv_comm_type = lc_int
    "for E-mail/Fax. Any exception will be handled below

*&--If Communication Type is Mail/Fax
    IF lv_comm_type = lc_int OR
       lv_comm_type = lc_fax.

* ------------ Call BCS interface ----------------------------------
      TRY.
* ------------ Create persistent send request ----------------------
          lv_send_request = cl_bcs=>create_persistent( ).

*---> Begin of Change for D3_OTC_FDD_0013 by NALI
* ------------ Sets the Sender -------------------------------------
          CLEAR lv_sender_email.
          SELECT smtp_addr "E-Mail Address
          UP TO 1 ROWS
           FROM adr6              " E-Mail Addresses (Business Address Services)
            INTO lv_sender_email
          WHERE addrnumber = im_adrnr_sender.
          ENDSELECT.
          IF lv_sender_email IS NOT INITIAL.
            lo_sender = cl_cam_address_bcs=>create_internet_address(
            i_address_string = lv_sender_email
            i_address_name   = lv_sender_email ).
* Set sender to send request
            lv_send_request->set_sender(
            EXPORTING
            i_sender = lo_sender ).
          ENDIF. " IF lv_sender_email IS NOT INITIAL
*<--- End of Change for D3_OTC_FDD_0013 by NALI

* ------------ Add document ----------------------------------------
*&--Get PDF xstring and convert it to BCS format
          lv_pdf_siz = xstrlen( im_form_output-pdf ).

          PERFORM f_xstring_to_solix USING im_form_output-pdf
                                           li_pdf_content.
          lv_subject = im_subject.

          lv_document = cl_document_bcs=>create_from_text(
                        i_text    = im_t_text
                        i_subject = lv_subject ).

          IF im_attachment_name IS NOT SUPPLIED.
            lv_attachment_name = lv_subject.
          ELSE. " ELSE -> IF im_attachment_name IS NOT SUPPLIED
            lv_attachment_name = im_attachment_name.
          ENDIF. " IF im_attachment_name IS NOT SUPPLIED

          CALL METHOD lv_document->add_attachment
            EXPORTING
              i_attachment_type    = lc_pdf
              i_attachment_subject = lv_attachment_name
              i_attachment_size    = lv_pdf_siz
              i_att_content_hex    = li_pdf_content.

*&--Add document to send request
          lv_send_request->set_document( lv_document ).

*&--Add recipient (E-mail/Fax address)
          IF lv_comm_type EQ lc_int.
*---> Begin of Change for D3_OTC_FDD_0013 by NALI
*&--If Communication type is INT (for email) and IM_INTAD is provided,
*   then use that for SMTP address of the recipient.
            IF im_intad IS NOT INITIAL.
              CLEAR lv_emailaddr.
              lv_emailaddr = im_intad.
            ENDIF. " IF im_intad IS NOT INITIAL
*<--- End of Change for D3_OTC_FDD_0013 by NALI
            IF lv_emailaddr IS INITIAL.
              RAISE no_email_address.
            ENDIF. " IF lv_emailaddr IS INITIAL

*&--Add recipient (e-mail address)
            lv_recipient = cl_cam_address_bcs=>create_internet_address(
                           i_address_string = lv_emailaddr ).

          ELSEIF lv_comm_type EQ lc_fax.
*---> Begin of Change for D3_OTC_FDD_0013 by NALI
*&--If Communication type is FAX and IM_TLFXS is provided then use that,
*   instead of looking up the customer general address.
            IF im_tlfxs IS NOT INITIAL.
              CLEAR lv_fax_number.
              lv_fax_number = im_tlfxs.
            ENDIF. " IF im_tlfxs IS NOT INITIAL
*<--- End of Change for D3_OTC_FDD_0013 by NALI
            IF lv_fax_number IS INITIAL.
              RAISE no_fax_number.
            ENDIF. " IF lv_fax_number IS INITIAL

*&--Add recipient (fax address)
            lv_recipient = cl_cam_address_bcs=>create_fax_address(
                           i_country = lv_country
                           i_number  = lv_fax_number ).
          ENDIF. " IF lv_comm_type EQ lc_int

*&--Add recipient to send request
          lv_send_request->add_recipient( i_recipient = lv_recipient ).

*&--Send document
          lv_send_request->send( i_with_error_screen = abap_true ).

*&--Explicit 'commit work' is mandatory!
          COMMIT WORK.
* ------------------------------------------------------------------
*             Exception handling
* ------------------------------------------------------------------
        CATCH cx_bcs.
          IF lv_comm_type EQ lc_int.
*&--Sending Mail failed
            RAISE mail_failure.
          ELSE. " ELSE -> IF lv_comm_type EQ lc_int
*&--Sending Fax failed
            RAISE fax_failure.
          ENDIF. " IF lv_comm_type EQ lc_int
      ENDTRY.

    ELSE. " ELSE -> IF lv_comm_type = lc_int OR
*&--Set the Print flag
      ex_print_doc = abap_true.
    ENDIF. " IF lv_comm_type = lc_int OR
  ELSE. " ELSE -> IF sy-subrc = 0
*&--Set the Print flag
    ex_print_doc = abap_true.
  ENDIF. " IF sy-subrc = 0
ENDFUNCTION.
