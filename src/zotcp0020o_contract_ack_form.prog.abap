*&---------------------------------------------------------------------*
*& Report  ZOTCP0020O_CONTRACT_ACK_FORM
*&---------------------------------------------------------------------*
************************************************************************
* Program    :  ZOTCP0020O_CONTRACT_ACK_FORM                           *
* Title      :  Driver Program for Contract Acknowledgement Form       *
* Developer  :  Vivek Gaur                                             *
* Object Type:  Report (Driver Program)                                *
* SAP Release:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_FDD_0020_Contract acknowledgement form               *
*----------------------------------------------------------------------*
* Description: Contract Acknowledgement is sent to the customer through*
*              email, fax or print. These forms will need to be auto-  *
*              generated at the time the contract is saved.            *
*----------------------------------------------------------------------*
* Modification History:                                                *
*======================================================================*
* Date        User      Transport  Description                         *
* =========== ========  ========== ====================================*
* 23-FEB-2012 VGAUR     E1DK900428 Initial development                 *
*&---------------------------------------------------------------------*

REPORT  zotcp0020o_contract_ack_form.

*----------------------------------------------------------------------*
*       F O R M S
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  Processing
*&---------------------------------------------------------------------*
*       Entry Routine for Form Processing
*----------------------------------------------------------------------*
*      -->RETURN_CODE  Return Code for errors
*      -->US_SCREEN    Print Preview
*----------------------------------------------------------------------*
FORM entry USING return_code TYPE sy-subrc  ##called
                 us_screen   TYPE c.

  CONSTANTS:
     lc_nast      TYPE tabname VALUE 'NAST',      "Messages
     lc_tnapr     TYPE tabname VALUE 'TNAPR'.     "Processing programs for output

*&--Related with Archiving
*  CONSTANTS:
*     lc_toadara   TYPE tabname VALUE 'TOA_DARA',  "SAP ArchiveLink structure of a DARA
*     lc_arcparams TYPE tabname VALUE 'ARC_PARAMS'."ImageLink structure

  FIELD-SYMBOLS:
     <lfs_x_nast>      TYPE nast,             "NAST Structure
     <lfs_x_tnapr>     TYPE tnapr.            "TNAPR Structure

*&--Related with Archiving
*  FIELD-SYMBOLS:
*     <lfs_x_toadara>   TYPE toa_dara,         "SAP ArchiveLink structure of a DARA
*     <lfs_x_arcparams> TYPE arc_params.       "ImageLink structure

  DATA:
     lv_retcode    TYPE sy-subrc.             "Returncode

*&--Assign NAST Structure
  ASSIGN (lc_tnapr)     TO <lfs_x_tnapr>.
*&--Assign TNAPR Structure
  ASSIGN (lc_nast)      TO <lfs_x_nast>.

*&--Related with Archiving
**&--Assign TOA_DARA Structure
*  ASSIGN (lc_toadara)   TO <lfs_x_toadara>.
**&--Assign ARC_PARAMS Structure
*  ASSIGN (lc_arcparams) TO <lfs_x_arcparams>.

  IF <lfs_x_tnapr>     IS ASSIGNED AND
     <lfs_x_nast>      IS ASSIGNED.   "AND
*&--Related with Archiving
*     <lfs_x_toadara>   IS ASSIGNED AND
*     <lfs_x_arcparams> IS ASSIGNED.
*&--Form Print/Fax/Mail Processing
    PERFORM f_processing USING us_screen
                               <lfs_x_nast>
                               <lfs_x_tnapr>
*                               <lfs_x_arcparams> "Related with Archiving
                      CHANGING
*                               <lfs_x_toadara>   "Related with Archiving
                               lv_retcode.
    IF lv_retcode NE 0.
      return_code = 1.
    ELSE.
      return_code = 0.
    ENDIF.
  ELSE.
    return_code = 1.
  ENDIF.
ENDFORM.                    "entry

*&---------------------------------------------------------------------*
*&      Form  f_processing
*&---------------------------------------------------------------------*
*       Processing Forms for output Print/Fax/Mail
*----------------------------------------------------------------------*
*      -->FP_US_SCREEN  Print Preview
*      -->FP_NAST       Messages
*      -->FP_TNAPR      Processing programs for output
*      -->FP_ARC_PARAMS ImageLink structure
*      -->FP_TOADARA    SAP ArchiveLink structure of a DARA line
*      -->FP_RETCODE    Return Code for errors
*----------------------------------------------------------------------*
FORM f_processing USING fp_us_screen  TYPE c
                        fp_nast       TYPE nast
                        fp_tnapr      TYPE tnapr
*                        fp_arc_params TYPE arc_params "Related with Archiving
               CHANGING
*                        fp_toadara    TYPE toa_dara   "Related with Archiving
                        fp_retcode    TYPE sy-subrc.

  CONSTANTS:
    lc_mail       TYPE fpmedium   VALUE 'MAIL',      "Mail Output Device
    lc_telefax    TYPE fpmedium   VALUE 'TELEFAX',   "Fax Output Device
    lc_error      TYPE sy-msgty   VALUE 'E',         "Error
    lc_fax        TYPE ad_comm    VALUE 'FAX',       "Fax Communication
    lc_int        TYPE ad_comm    VALUE 'INT',       "Mail Communication
    lc_pdf        TYPE so_obj_tp  VALUE 'PDF',       "PDF Object Type
    lc_mail_msg   TYPE na_nacha   VALUE '5',         "Mail Message transmission
    lc_fax_msg    TYPE na_nacha   VALUE '2',         "Fax Message transmission
    lc_archive    TYPE syarmod    VALUE '2',         "Archive Only
    lc_pr_archive TYPE syarmod    VALUE '3',         "Print & Archive
    lc_msgno      TYPE sy-msgno   VALUE '000',       "Message No.
    lc_msgid      TYPE sy-msgid   VALUE 'ZOTC_MSG'.  "OTC Message ID

*&--Related with Archiving
*  CONSTANTS:
*    lc_doctyp     TYPE saedoktyp  VALUE 'PDF',       "PDF
*    lc_dara       TYPE saefktname VALUE 'DARA'.      "DARA



  DATA:
*&---------V A R I A B L E S---------*
    lv_vbeln         TYPE vbeln_va,               "Document No.
    lv_auart         TYPE auart,                  "Sales Document Type
    lv_payment_term  TYPE dzterm_bez,             "Payment Terms Text
    lv_item          TYPE boolean,                "Quantity Contract
    lv_total         TYPE boolean,                "Value Contract
    lv_total_price   TYPE netwr_ak,               "Total Price
    lv_formname      TYPE fpname,                 "Name of Form Object
    lv_function      TYPE rs38l_fnam,             "Name of Function Module
    lv_pdf_content   TYPE solix_tab,              "SAPoffice: Binary data
    lv_emailaddr     TYPE adr6-smtp_addr,         "E-Mail Address
    lv_sent_to_all   TYPE os_boolean,             "Sent to all indicator
    lv_pdf_siz       TYPE so_obj_len,             "PDF Size
*&--Related with Archiving
*    lv_size          TYPE i,                      "Archived PDF Size
    lv_subject       TYPE so_obj_des,             "Mail Subject
    lv_inupd         TYPE i,                      "Update task indicator
    lv_comm_type     TYPE ad_comm,                "Communication type for customer
    lv_programm      TYPE tdprogram,              "Program Name

*&--Related with Archiving
*    lv_archiveformat TYPE toadd-doc_type,         "PDF or OTF
*    lv_documentclass TYPE toadv-doc_type,         "Document Class

*&---------R E F E R E N C E   V A R I A B L E S---------*
    lv_cx_root       TYPE REF TO cx_root,         "All Global Exceptions
    lv_send_request  TYPE REF TO cl_bcs,          "Business Communication Service
    lv_document      TYPE REF TO cl_document_bcs, "Wrapper Class for Office Documents
    lv_recipient     TYPE REF TO if_recipient_bcs,"Interface of Recipient Object in BCS

*&---------S T R U C T U R E S---------*
    lx_itcpo         TYPE itcpo,                  "SAPscript output interface
    lx_cre_addr      TYPE bapiaddr3,              "Created By Address
    lx_bill_to_addr  TYPE zotc_address_info,      "Bill To Address
    lx_ship_to_addr  TYPE zotc_address_info,      "Ship-To Address
    lx_contact_addr  TYPE zotc_address_info,      "Contact Person Address
    lx_vbak          TYPE zotc_contract_ack_vbak, "Document Header data
    lx_sadr          TYPE sadr,                   "Address Management: Company Data
    lx_docparams     TYPE sfpdocparams,           "Form Parameters for Form Processing
    lx_outputparams  TYPE sfpoutputparams,        "Form Processing Output Parameter
    lx_formout       TYPE fpformoutput,           "Form Output (PDF, PDL)
    lx_vbadr         TYPE vbadr,                  "Address Structure
    lx_comm_values   TYPE szadr_comm_values,      "Communicaion specific values
    lx_recipient     TYPE swotobjid,              "Mail Recepeint
    lx_sender        TYPE swotobjid,              "Mail Sender
    lx_intnast       TYPE snast,                  "Message output
    lx_outputparams_fax TYPE sfpoutpar,           "Form Processing Output Fax

*&---------I N T E R N A L   T A B L E S---------*
    li_item_data     TYPE STANDARD TABLE OF zotc_contract_ack_item.  "Item Data

*&--Check if the subroutine is called in update task.
  CALL METHOD cl_system_transaction_state=>get_in_update_task
    RECEIVING
      in_update_task = lv_inupd.

*&--Fetch form data
  PERFORM f_get_data USING fp_us_screen
                           fp_nast
                  CHANGING lx_vbadr
                           li_item_data
                           lv_vbeln
                           lv_auart
                           lv_payment_term
                           lv_item
                           lv_total
                           lv_total_price
                           lx_cre_addr
                           lx_bill_to_addr
                           lx_ship_to_addr
                           lx_contact_addr
                           lx_vbak
                           lx_sadr
                           fp_retcode.
  IF fp_retcode = 1.
    RETURN.
  ENDIF.

*&--Check for external send
  IF fp_nast-nacha EQ lc_mail_msg.
*&--Strategy to get communication type
    CALL FUNCTION 'ADDR_GET_NEXT_COMM_TYPE'
      EXPORTING
        strategy           = fp_nast-tcode
        address_number     = lx_vbadr-adrnr
      IMPORTING
        comm_type          = lv_comm_type
        comm_values        = lx_comm_values
      EXCEPTIONS
        address_not_exist  = 1
        person_not_exist   = 2
        no_comm_type_found = 3
        internal_error     = 4
        parameter_error    = 5
        OTHERS             = 6.
    IF sy-subrc <> 0.
      PERFORM protocol_update USING fp_us_screen.
      fp_retcode = 1.
      RETURN.
    ENDIF.

*&--Convert communication data
    MOVE fp_nast-mandt      TO lx_intnast-mandt.
    MOVE fp_nast-kschl      TO lx_intnast-kschl.
    MOVE fp_nast-spras      TO lx_intnast-spras.
    MOVE fp_nast-adrnr      TO lx_intnast-adrnr.
    MOVE fp_nast-nacha      TO lx_intnast-nacha.
    MOVE fp_nast-anzal      TO lx_intnast-anzal.
    MOVE fp_nast-vsdat      TO lx_intnast-vsdat.
    MOVE fp_nast-vsura      TO lx_intnast-vsura.
    MOVE fp_nast-tcode      TO lx_intnast-tcode.
    MOVE fp_nast-usnam      TO lx_intnast-usnam.
    MOVE fp_nast-ldest      TO lx_intnast-ldest.
    MOVE fp_nast-dsnam      TO lx_intnast-dsnam.
    MOVE fp_nast-dsuf1      TO lx_intnast-dsuf1.
    MOVE fp_nast-dsuf2      TO lx_intnast-dsuf2.
    MOVE fp_nast-dimme      TO lx_intnast-dimme.
    MOVE fp_nast-delet      TO lx_intnast-delet.
    MOVE fp_nast-telfx      TO lx_intnast-telfx.
    MOVE fp_nast-telx1      TO lx_intnast-telx1.
    MOVE fp_nast-pfld4      TO lx_intnast-pfld4.
    MOVE fp_nast-pfld5      TO lx_intnast-pfld5.
    MOVE fp_nast-tdname     TO lx_intnast-tdname.
    MOVE fp_nast-snddr      TO lx_intnast-snddr.
    MOVE fp_nast-sndbc      TO lx_intnast-sndbc.
    MOVE fp_nast-forfb      TO lx_intnast-forfb.
    MOVE fp_nast-prifb      TO lx_intnast-prifb.
    MOVE fp_nast-tdreceiver TO lx_intnast-tdreceiver.
    MOVE fp_nast-tddivision TO lx_intnast-tddivision.
    MOVE fp_nast-tdocover   TO lx_intnast-tdocover.
    MOVE fp_nast-tdcovtitle TO lx_intnast-tdcovtitle.
    MOVE fp_nast-tdautority TO lx_intnast-tdautority.
    MOVE fp_nast-tdarmod    TO lx_intnast-tdarmod.
    MOVE fp_nast-usrnam     TO lx_intnast-usrnam.
    MOVE fp_nast-event      TO lx_intnast-event.
    MOVE fp_nast-sort1      TO lx_intnast-sort1.
    MOVE fp_nast-sort2      TO lx_intnast-sort2.
    MOVE fp_nast-sort3      TO lx_intnast-sort3.
    MOVE fp_nast-objtype    TO lx_intnast-objtype.
    MOVE fp_nast-tdschedule TO lx_intnast-tdschedule.
    MOVE fp_nast-tland      TO lx_intnast-tland.

    MOVE sy-repid           TO lv_programm.

    CALL FUNCTION 'CONVERT_COMM_TYPE_DATA'
      EXPORTING
        pi_comm_type              = lv_comm_type
        pi_comm_values            = lx_comm_values
        pi_country                = lx_vbadr-land1
        pi_repid                  = lv_programm
        pi_snast                  = lx_intnast
      IMPORTING
        pe_itcpo                  = lx_itcpo
        pe_device                 = lx_outputparams-device
        pe_mail_recipient         = lx_recipient
        pe_mail_sender            = lx_sender
      EXCEPTIONS
        comm_type_not_supported   = 1
        recipient_creation_failed = 2
        sender_creation_failed    = 3
        OTHERS                    = 4.
    IF sy-subrc <> 0.
      PERFORM protocol_update USING fp_us_screen.
      fp_retcode = 1.
      RETURN.
    ENDIF.

*&--Determine device type for formatting a document with DEVICE=MAIL
    IF lx_outputparams-device = lc_mail.
      CALL FUNCTION 'SX_ADDRESS_TO_DEVTYPE'
        EXPORTING
          recipient_id      = lx_recipient
          sender_id         = lx_sender
        EXCEPTIONS
          err_invalid_route = 1
          err_system        = 2
          OTHERS            = 3.
      IF sy-subrc <> 0.
        PERFORM protocol_update USING fp_us_screen.
        fp_retcode = 1.
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.
*&--Get Function Module name for Form Processing
  lv_function = fp_tnapr-funcname.
  IF NOT fp_tnapr-sform IS INITIAL.
    lv_formname = fp_tnapr-sform.
    TRY.
        CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
          EXPORTING
            i_name     = lv_formname
          IMPORTING
            e_funcname = lv_function.
      CATCH cx_fp_api_repository INTO lv_cx_root.
        MESSAGE lv_cx_root TYPE lc_error.
      CATCH cx_fp_api_usage INTO lv_cx_root.
        MESSAGE lv_cx_root TYPE lc_error.
      CATCH cx_fp_api_internal INTO lv_cx_root.
        MESSAGE lv_cx_root TYPE lc_error.
    ENDTRY.
  ENDIF.

*&--Fill Output Parameters Control Structure
  PERFORM fill_control_structure USING fp_nast
                                       fp_us_screen
                              CHANGING lx_outputparams.

*&--Sending via Mail or archiving the PDF output
  IF fp_us_screen IS INITIAL "In case of preview message should be displayed only
    AND ( fp_nast-nacha EQ lc_mail_msg OR fp_nast-tdarmod = lc_archive OR fp_nast-nacha EQ lc_fax_msg ).
*&--Setting output parameters only if communication type is fax or email.
    IF fp_nast-nacha EQ lc_mail_msg.
      IF ( lv_comm_type EQ lc_fax OR lv_comm_type EQ lc_int ).
        lx_outputparams-getpdf = abap_true.
        IF lx_itcpo-tdtelenum EQ space.
          lx_outputparams-nodialog = space.
        ENDIF.
      ENDIF.
    ELSE.
      lx_outputparams-getpdf = abap_true.
    ENDIF.
*&--Specific setting for FAX
    IF fp_nast-nacha EQ lc_fax_msg.
*&--Setting output parameters
      lx_outputparams-device = lc_telefax.
      IF fp_nast-telfx EQ space.
        lx_outputparams-nodialog = space.
      ENDIF.
    ENDIF.
  ENDIF.

*&--Open Spool Job
  CALL FUNCTION 'FP_JOB_OPEN'
    CHANGING
      ie_outputparams = lx_outputparams
    EXCEPTIONS
      cancel          = 1
      usage_error     = 2
      system_error    = 3
      internal_error  = 4
      OTHERS          = 5.
  IF sy-subrc <> 0.
    PERFORM protocol_update USING fp_us_screen.
    fp_retcode = 1.
    RETURN.
  ENDIF.
* &--To handle print and archive scenario
  IF fp_nast-tdarmod EQ lc_pr_archive.
    lx_outputparams-getpdf = abap_true.
  ENDIF.

  CLEAR: lx_docparams.
  lx_docparams-langu = fp_nast-spras.
  lx_docparams-country = fp_nast-tland.

*&--Call the generated function module
  CALL FUNCTION lv_function
    EXPORTING
      /1bcdwb/docparams  = lx_docparams
      im_vbeln           = lv_vbeln
      im_payment_terms   = lv_payment_term
      im_sadr            = lx_sadr
      im_vbak            = lx_vbak
      im_contact_addr    = lx_contact_addr
      im_ship_to_addr    = lx_ship_to_addr
      im_bill_to_addr    = lx_bill_to_addr
      im_cre_addr        = lx_cre_addr
      im_item_data       = li_item_data
      im_item            = lv_item
      im_total           = lv_total
      im_total_price     = lv_total_price
    IMPORTING
      /1bcdwb/formoutput = lx_formout
    EXCEPTIONS
      usage_error        = 1
      system_error       = 2
      ternal_error       = 3
      OTHERS             = 4.
  IF sy-subrc <> 0.
    PERFORM protocol_update USING fp_us_screen.
    fp_retcode = 1.
    RETURN.
  ENDIF.

*&--sending Document out via mail or FAX
  IF fp_us_screen IS INITIAL   "In case of preview message should be displayed only
     AND ( fp_nast-nacha EQ lc_mail_msg OR fp_nast-nacha EQ lc_fax_msg )
     AND lx_formout IS NOT INITIAL.

*&--Get Email id from address no
    lv_emailaddr = lx_contact_addr-smtp_addr.

*&--When more than one address is maintained default address should be selected.
*&--When there is only one mail id then that will have default flag set
*&--Set FAX specific setting
    IF fp_nast-nacha EQ lc_mail_msg.
      lx_outputparams_fax-telenum = lx_itcpo-tdtelenum.
      lx_outputparams_fax-teleland = lx_itcpo-tdteleland.
    ELSE.
      IF fp_nast-telfx NE space.
        lx_outputparams_fax-telenum  = fp_nast-telfx.
        IF fp_nast-tland IS INITIAL.
          lx_outputparams_fax-teleland = lx_vbadr-land1.
        ELSE.
          lx_outputparams_fax-teleland = fp_nast-tland.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lv_comm_type EQ lc_fax OR
       lv_comm_type EQ lc_int OR
       fp_nast-nacha EQ lc_fax_msg.
* ------------ Call BCS interface ----------------------------------
      TRY.
*   ---------- create persistent send request ----------------------
          lv_send_request = cl_bcs=>create_persistent( ).

*   ---------- add document ----------------------------------------
*&--Get PDF xstring and convert it to BCS format
          lv_pdf_siz = xstrlen( lx_formout-pdf ).

          PERFORM f_xstring_to_solix USING lx_formout-pdf
                                           lv_pdf_content.
          CONCATENATE text-001 lx_vbak-bstkd INTO lv_subject
                                     SEPARATED BY space.
          lv_document = cl_document_bcs=>create_document(
                    i_type    = lc_pdf
                    i_hex     = lv_pdf_content
                    i_length  = lv_pdf_siz
                    i_subject = lv_subject ).               "#EC NOTEXT

*&--Add document to send request
          lv_send_request->set_document( lv_document ).

*&--Add recipient (E-mail/Fax address)

          CASE fp_nast-nacha.
            WHEN lc_mail_msg.
              IF lv_comm_type EQ lc_int.
                IF lv_emailaddr IS INITIAL.
                  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
                    EXPORTING
                      msg_arbgb = lc_msgid
                      msg_nr    = lc_msgno
                      msg_ty    = lc_error
                      msg_v1    = text-002
                    EXCEPTIONS
                      OTHERS    = 1.
                  IF sy-subrc <> 0.
                    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                  ENDIF.
                  fp_retcode = 1.
                  RETURN.
                ENDIF.

*&--Add recipient (e-mail address)
                lv_recipient = cl_cam_address_bcs=>create_internet_address(
                i_address_string = lv_emailaddr ).
              ELSE.
                IF lx_outputparams_fax-telenum IS INITIAL OR
                   lx_outputparams_fax-teleland IS INITIAL.
                  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
                    EXPORTING
                      msg_arbgb = lc_msgid
                      msg_nr    = lc_msgno
                      msg_ty    = lc_error
                      msg_v1    = text-003
                    EXCEPTIONS
                      OTHERS    = 1.
                  IF sy-subrc <> 0.
                    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                  ENDIF.
                  fp_retcode = 1.
                  RETURN.
                ENDIF.
*&--Add recipient (fax address)
                lv_recipient = cl_cam_address_bcs=>create_fax_address(
                                 i_country = lx_outputparams_fax-teleland
                                 i_number  = lx_outputparams_fax-telenum ).
              ENDIF.

            WHEN lc_fax_msg.
              IF lx_outputparams_fax-telenum IS INITIAL OR
                 lx_outputparams_fax-teleland IS INITIAL.
                CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
                  EXPORTING
                    msg_arbgb = lc_msgid
                    msg_nr    = lc_msgno
                    msg_ty    = lc_error
                    msg_v1    = text-003
                  EXCEPTIONS
                    OTHERS    = 1.
                IF sy-subrc <> 0.
                  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                ENDIF.
                fp_retcode = 1.
                RETURN.
              ENDIF.
*&--Add recipient (fax address)
              lv_recipient = cl_cam_address_bcs=>create_fax_address(
                               i_country = lx_outputparams_fax-teleland
                               i_number  = lx_outputparams_fax-telenum ).
          ENDCASE.

*&--Add recipient to send request
          lv_send_request->add_recipient( i_recipient = lv_recipient ).

*&--Send document

          lv_sent_to_all = lv_send_request->send(
              i_with_error_screen = abap_true ).
*&--Issue message and COMMIT only if the subroutine is not called in update task
          IF lv_inupd = 0.
            IF lv_sent_to_all = abap_true.
              MESSAGE i022(so).
            ENDIF.
*&--Explicit 'commit work' is mandatory!
            COMMIT WORK.
          ENDIF.
* ------------------------------------------------------------------
* *            Exception handling
* ------------------------------------------------------------------
        CATCH cx_bcs.
          IF lv_comm_type EQ lc_int.
*&--Sending fax/mail failed
            CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
              EXPORTING
                msg_arbgb = lc_msgid
                msg_nr    = lc_msgno
                msg_ty    = lc_error
                msg_v1    = text-004
              EXCEPTIONS
                OTHERS    = 1.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
            fp_retcode = 1.
            RETURN.
          ELSE.
            CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
              EXPORTING
                msg_arbgb = lc_msgid
                msg_nr    = lc_msgno
                msg_ty    = lc_error
                msg_v1    = text-005
              EXCEPTIONS
                OTHERS    = 1.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
            fp_retcode = 1.
            RETURN.
          ENDIF.

          fp_retcode = 1.
          RETURN.
      ENDTRY.
    ENDIF.
  ENDIF.

******************************************************************************
*&--Commented as Testing is not possible
*   It might need to be changed if it someone is trying to do archiving and
*   finds that it doesn't work.
******************************************************************************

**&--Archiving for adobe forms
*  IF fp_nast-tdarmod = lc_archive OR fp_nast-tdarmod = lc_pr_archive.
*
**&--Get the PDF length
*    lv_pdf_siz = xstrlen( lx_formout-pdf ).
*
**&--defaults for archive
*    IF fp_toadara-function = space.
*      fp_toadara-function = lc_dara.
*    ENDIF.
**&--which format to be used for archiving: OTF or PDF?
*    CALL FUNCTION 'ARCHIV_GET_PRINTFORMAT'
*      EXPORTING
*        application = lc_doctyp
*      IMPORTING
*        printformat = lv_archiveformat.
*
*    IF lv_archiveformat EQ lc_doctyp.
*      lv_documentclass = lc_doctyp.
*      lv_size = lv_pdf_siz.
*      CALL FUNCTION 'ARCHIV_CREATE_OUTGOINGDOCUMENT'
*        EXPORTING
*          arc_p                    = fp_arc_params
*          arc_i                    = fp_toadara
*          pdflen                   = lv_size
*          documentclass            = lv_documentclass   "Since the output is in PDF document class is also PDF
*          document                 = lx_formout-pdf
*        EXCEPTIONS
*          error_archiv             = 1
*          error_communicationtable = 2
*          error_connectiontable    = 3
*          error_kernel             = 4
*          error_parameter          = 5
*          OTHERS                   = 6.
*      IF sy-subrc <> 0.
*        PERFORM protocol_update USING fp_us_screen.
*        fp_retcode = 1.
*        RETURN.
*      ENDIF.
*    ENDIF.
*  ENDIF.
******************************************************************************


*&--Close Job
  CALL FUNCTION 'FP_JOB_CLOSE'
    EXCEPTIONS
      usage_error    = 1
      system_error   = 2
      internal_error = 3
      OTHERS         = 4.
  IF sy-subrc <> 0.
    PERFORM protocol_update USING fp_us_screen.
    fp_retcode = 1.
    RETURN.
  ENDIF.

  FREE li_item_data.

ENDFORM.                    "f_processing


*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       General provision of data for the form
*----------------------------------------------------------------------*
*      -->FP_SCREEN               Preview on Printer or Screen
*      -->FP_NAST                 Output Messages
*      -->FP_VBADR                Address work area
*      -->fp_i_item_data          Contract Acknowledgement data
*      -->FP_VBELN                Sales Document No.
*      -->FP_AUART                Sales Document Type.
*      -->FP_PAYMENT_TERM         Payment Terms text
*      -->FP_F7                   Quantity Form Indicator
*      -->FP_F8                   Total Committed Value Form Indicator
*      -->FP_TOTAL_PRICE          Total Price
*      -->FP_CRE_ADDR             Created By Address
*      -->FP_BILL_TO_ADDR         Bill To Address
*      -->FP_SHIP_TO_ADDR         Ship To Address
*      -->FP_CONTACT_ADDR         Contact Person Address
*      -->FP_VBAK                 Sales Document Header data
*      -->FP_RETCODE              Return Code
*----------------------------------------------------------------------*
FORM f_get_data USING fp_screen       TYPE c
                      fp_nast         TYPE nast
             CHANGING fp_vbadr        TYPE vbadr
                      fp_i_item_data  TYPE zotc_t_contract_ack_item
                      fp_vbeln        TYPE vbeln_va
                      fp_auart        TYPE auart
                      fp_payment_term TYPE dzterm_bez
                      fp_f7           TYPE boolean
                      fp_f8           TYPE boolean
                      fp_total_price  TYPE netwr_ak
                      fp_cre_addr     TYPE bapiaddr3
                      fp_bill_to_addr TYPE zotc_address_info
                      fp_ship_to_addr TYPE zotc_address_info
                      fp_contact_addr TYPE zotc_address_info
                      fp_vbak         TYPE zotc_contract_ack_vbak
                      fp_sadr         TYPE sadr
                      fp_retcode      TYPE sy-subrc.

  DATA: lx_vbpa  TYPE vbpa,     "Partner data
        lv_vkorg TYPE vkorg,    "Sales org.
        lv_vtweg TYPE vtweg.    "Distribution Channel

*&--Sales Document No. from NAST Object key
  fp_vbeln = fp_nast-objky.

  lx_vbpa-mandt = sy-mandt.
  lx_vbpa-vbeln = fp_nast-objky.
  lx_vbpa-kunnr = fp_nast-parnr.
  lx_vbpa-parvw = fp_nast-parvw.

*&--Identify addresses for customers
  CALL FUNCTION 'VIEW_VBADR'
    EXPORTING
      input      = lx_vbpa
      langu_prop = fp_nast-spras
    IMPORTING
      adresse    = fp_vbadr
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update USING fp_screen.
    fp_retcode = 1.
    RETURN.
  ENDIF.

*&--Fetch Sales Document Header data
  PERFORM f_get_header_data USING fp_vbeln
                                  fp_nast
                         CHANGING lv_vkorg
                                  lv_vtweg
                                  fp_auart
                                  fp_payment_term
                                  fp_cre_addr
                                  fp_bill_to_addr
                                  fp_ship_to_addr
                                  fp_contact_addr
                                  fp_vbak.

*&--Check entries for Document Type in Process Team Control Table
  PERFORM f_check_process_table USING lv_vkorg
                                      lv_vtweg
                                      fp_auart
                             CHANGING fp_f7
                                      fp_f8.

*&--If Sales Document Type is Quantity Contract fetch Item data
  IF fp_f7 IS NOT INITIAL.
    PERFORM f_get_item_data USING fp_vbeln
                         CHANGING fp_i_item_data
                                  fp_total_price.
  ENDIF.

*&--Determines the address of the sender (Table TVKO)
  PERFORM f_sender USING lv_vkorg
                       fp_screen
              CHANGING fp_sadr
                       fp_retcode.

ENDFORM.                    "f_get_data
**
*---------------------------------------------------------------------*
*       FORM PROTOCOL_UPDATE                                          *
*---------------------------------------------------------------------*
*       The messages are collected for the processing protocol.       *
*---------------------------------------------------------------------*
*      -->FP_SCREEN        Print Preview Indicator
*---------------------------------------------------------------------*
FORM protocol_update USING fp_screen TYPE c.

  IF fp_screen <> space.
    RETURN.
  ENDIF.
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
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    "protocol_update



*&---------------------------------------------------------------------*
*&     Form  f_sender
*&---------------------------------------------------------------------*
*      This routine determines the address of the sender (Table TVKO)  *
*----------------------------------------------------------------------*
*      -->FP_VKORG    Sales Organization
*      -->FP_SCREEN   Output Preview or Print
*      -->FP_SADR     Address
*      -->FP_RETCODE  Return Code
*----------------------------------------------------------------------*
FORM f_sender USING fp_vkorg   TYPE vkorg
                    fp_screen  TYPE c
           CHANGING fp_sadr    TYPE sadr
                    fp_retcode TYPE sy-subrc.

  CONSTANTS:
    lc_vn        TYPE sy-msgid VALUE 'VN',   "Message ID
    lc_error     TYPE sy-msgty VALUE 'E',    "Error Message
    lc_203       TYPE sy-msgno VALUE '203',  "Message No.
    lc_tvko      TYPE sy-msgv1 VALUE 'TVKO', "TVKO Table name
    lc_ca01      TYPE ad_group VALUE 'CA01'. "Customizing addresses Group

  DATA:
    lv_adrnr    TYPE adrnr,                 "Address Key
    lx_fb_addr  TYPE addr1_sel.             "Address selection parameter

*&--Fetch Sales Organizations Address
  SELECT SINGLE adrnr   "Address
           FROM tvko
           INTO lv_adrnr
    WHERE vkorg = fp_vkorg.
  IF sy-subrc NE 0.
    syst-msgid = lc_vn.
    syst-msgno = lc_203.
    syst-msgty = lc_error.
    syst-msgv1 = lc_tvko.
    syst-msgv2 = syst-subrc.
    PERFORM protocol_update USING fp_screen.
    fp_retcode = 1.
    RETURN.
  ENDIF.

  lx_fb_addr-addrnumber = lv_adrnr.
*&--Read an address
  CALL FUNCTION 'ADDR_GET'
    EXPORTING
      address_selection = lx_fb_addr
      address_group     = lc_ca01
    IMPORTING
      sadr              = fp_sadr
    EXCEPTIONS
      OTHERS            = 01.
  IF sy-subrc NE 0.
    CLEAR fp_sadr.
  ENDIF.

ENDFORM.                    "f_sender


*&---------------------------------------------------------------------*
*&      Form  f_get_item_data
*&---------------------------------------------------------------------*
*       Fetch Sales Document Item data
*----------------------------------------------------------------------*
*      -->FP_VBELN        Sales Document Number
*      -->fp_i_item_data    Sales Item data
*      -->FP_TOTAL_PRICE  Total Item Price
*----------------------------------------------------------------------*
FORM f_get_item_data USING fp_vbeln        TYPE vbeln_va
                  CHANGING fp_i_item_data  TYPE zotc_t_contract_ack_item
                           fp_total_price  TYPE netwr_ak.

  TYPES:
*&--Batches data for Items
  BEGIN OF lty_mchi,
    matnr	 TYPE  matnr,       "Material Number
    charg	 TYPE  charg_d,     "Batch Number
    vfdat  TYPE  vfdat,       "Expiration Date
  END OF lty_mchi,

*&--VBAP Item data
  BEGIN OF lty_vbap,
    posnr  TYPE  posnr_va,    "Item No.
    matnr	 TYPE  matnr,       "Material Number
    arktx  TYPE  arktx,       "Description
    charg	 TYPE  charg_d,     "Batch Number
    zmeng  TYPE  dzmeng,      "Quantity
    zieme  TYPE  dzieme,      "UOM
    netwr  TYPE  netwr_ap,    "Net Price
    waerk  TYPE  waerk,       "Currency
  END OF lty_vbap.

  DATA:
    li_mch1       TYPE STANDARD TABLE OF lty_mchi, "Batches data
    li_vbap       TYPE STANDARD TABLE OF lty_vbap, "Item Data
    li_vbap_tmp   TYPE STANDARD TABLE OF lty_vbap, "Item Data
    lwa_item_data TYPE zotc_contract_ack_item,     "Work Area-Item Data
    lv_count      TYPE int4.                       "Count

  FIELD-SYMBOLS:
    <lfs_vbap>    TYPE lty_vbap,                   "Item Data
    <lfs_mchi>    TYPE lty_mchi.                   "Batches data


*&--Fetch Item data from VBAP
  SELECT posnr    "Item No.
         matnr    "Material Number
         arktx    "Description
         charg    "Batch
         zmeng    "Quantity
         zieme    "UOM
         netwr    "Net Price
         waerk    "Document Currency
    FROM vbap
    INTO TABLE li_vbap
   WHERE vbeln = fp_vbeln.
  IF sy-subrc = 0.
    li_vbap_tmp[] = li_vbap[].
    SORT li_vbap BY posnr.
    SORT li_vbap_tmp BY matnr charg.
    DELETE ADJACENT DUPLICATES FROM li_vbap_tmp COMPARING matnr charg.
*&--Fetch Batches data from mchi
    SELECT matnr    "Material Number
           charg    "Batch
           vfdat    "Expiration date
      FROM mch1
      INTO TABLE li_mch1
       FOR ALL ENTRIES IN li_vbap_tmp
     WHERE matnr = li_vbap_tmp-matnr
       AND charg = li_vbap_tmp-charg.
    IF sy-subrc = 0.
      SORT li_mch1 BY matnr charg.
    ENDIF.

*&--Merging Item data and Batches data
    LOOP AT li_vbap ASSIGNING <lfs_vbap>.

      lwa_item_data-matnr = <lfs_vbap>-matnr.
      lwa_item_data-arktx = <lfs_vbap>-arktx.
      lwa_item_data-charg = <lfs_vbap>-charg.
      lwa_item_data-zieme = <lfs_vbap>-zieme.
      WRITE <lfs_vbap>-zmeng TO lwa_item_data-zmeng UNIT <lfs_vbap>-zieme.
      lwa_item_data-netwr = <lfs_vbap>-netwr.
      lwa_item_data-waerk = <lfs_vbap>-waerk.

*&--Increment Position
      lv_count = lv_count + 1.
      lwa_item_data-posn  = lv_count.
*&--Calculate Total Price
      fp_total_price      = lwa_item_data-netwr + fp_total_price.
*&--Read Expiration date for Batches
      READ TABLE li_mch1 ASSIGNING <lfs_mchi> WITH KEY matnr = <lfs_vbap>-matnr
                                                       charg = <lfs_vbap>-charg
                                              BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_item_data-vfdat = <lfs_mchi>-vfdat.
      ENDIF.
      APPEND lwa_item_data TO fp_i_item_data.
      CLEAR: lwa_item_data.
    ENDLOOP.
  ENDIF.

  FREE: li_mch1, li_vbap, li_vbap_tmp.

ENDFORM.                    " F_GET_ITEM_DATA


*&---------------------------------------------------------------------*
*&      Form  f_get_header_data
*&---------------------------------------------------------------------*
*       Get Sales Document Header data
*----------------------------------------------------------------------*
*      -->FP_VBELN                Sales Document No.
*      -->FP_NAST                 NAST
*      -->FP_VKORG                Sales Org.
*      -->FP_VTWEG                Distribution Channel
*      -->FP_AUART                Sales Document Type.
*      -->FP_PAYMENT_TERM         Payment Terms text
*      -->FP_CRE_ADDR             Created By Address
*      -->FP_BILL_TO_ADDR         Bill To Address
*      -->FP_SHIP_TO_ADDR         Ship To Address
*      -->FP_CONTACT_ADDR         Contact Person Address
*      -->FP_VBAK                 Sales Document Header data
*----------------------------------------------------------------------*
FORM f_get_header_data USING fp_vbeln        TYPE vbeln_va
                             fp_nast         TYPE nast
                    CHANGING fp_vkorg        TYPE vkorg
                             fp_vtweg        TYPE vtweg
                             fp_auart        TYPE auart
                             fp_payment_term TYPE dzterm_bez
                             fp_cre_addr     TYPE bapiaddr3
                             fp_bill_to_addr TYPE zotc_address_info
                             fp_ship_to_addr TYPE zotc_address_info
                             fp_contact_addr TYPE zotc_address_info
                             fp_vbak         TYPE zotc_contract_ack_vbak.

  TYPES:
*&--For VBPA data
    BEGIN OF lty_vbpa,
      parvw    TYPE parvw,                     "Partner Function
      adrnr    TYPE adrnr,                     "Address
    END OF lty_vbpa.

  CONSTANTS:
    lc_contact TYPE parvw    VALUE 'AP',      "Contact person
    lc_bill_to TYPE parvw    VALUE 'WE',      "Bill-to party
    lc_ship_to TYPE parvw    VALUE 'RE',      "Ship-to party
    lc_posnr   TYPE posnr_va VALUE '000000'.  "Header Item count

  DATA:
    lv_ernam   TYPE ernam,                     "Person who Created Object
    li_vbpa    TYPE STANDARD TABLE OF lty_vbpa, "Table for Partner data
    li_return  TYPE STANDARD TABLE OF bapiret2."BAPI Return table

  FIELD-SYMBOLS:
    <lfs_vbpa> TYPE lty_vbpa.                   "Partner data

*&--Fetch Sales document header data
  SELECT SINGLE ernam   "Name of Person who Created the Object
                auart   "Sales Document Type
                vkorg   "Sales Organization
                vtweg   "Distribution Channel
                guebg   "Valid-from date
                gueen   "Valid-to date
                netwr   "Net Value of the Sales Order
                waerk   "Document Currency
           FROM vbak
           INTO (lv_ernam, fp_auart, fp_vkorg, fp_vtweg,
                 fp_vbak-guebg, fp_vbak-gueen, fp_vbak-netwr, fp_vbak-waerk)
          WHERE vbeln = fp_vbeln.

  IF sy-subrc = 0.
*&--Fetch Address data of Person who Created Object
    CALL FUNCTION 'BAPI_USER_GET_DETAIL'
      EXPORTING
        username = lv_ernam
      IMPORTING
        address  = fp_cre_addr
      TABLES
        return   = li_return.
  ENDIF.

*&--Fetch Sales Document: Partner data
  SELECT parvw    "Partner Function
         adrnr    "Address Number
    FROM vbpa
    INTO TABLE li_vbpa
   WHERE vbeln = fp_vbeln
     AND posnr = lc_posnr
     AND parvw IN (lc_contact, lc_bill_to, lc_ship_to ).
  IF sy-subrc = 0.
*&--Read Contact Person Address no.
    READ TABLE li_vbpa ASSIGNING <lfs_vbpa> WITH KEY parvw = lc_contact.
    IF sy-subrc = 0.
*&--Fetch Contact Person Address details
      SELECT name1        "Name
             tel_number   "Telephone No.
       UP TO 1 ROWS
        FROM adrc
        INTO (fp_contact_addr-name1,
              fp_contact_addr-tel_number)
       WHERE addrnumber = <lfs_vbpa>-adrnr.
      ENDSELECT.

*&--Fetch Contact Person E-Mail Address
      SELECT smtp_addr    "E-Mail Address
       UP TO 1 ROWS
        FROM adr6
         INTO fp_contact_addr-smtp_addr
       WHERE addrnumber = <lfs_vbpa>-adrnr.
      ENDSELECT.
    ENDIF.

*&--Read Bill to customer Address no.
    READ TABLE li_vbpa ASSIGNING <lfs_vbpa> WITH KEY parvw = lc_ship_to.
    IF sy-subrc = 0.
*&--Fetch Bill to customer Address details
      SELECT addrnumber   "Address No.
             country      "Country
       UP TO 1 ROWS
       FROM adrc
       INTO (fp_bill_to_addr-adrnr, fp_bill_to_addr-land1)
      WHERE addrnumber = <lfs_vbpa>-adrnr.
      ENDSELECT.
    ENDIF.

*&--Read Ship to customer Address no.
    READ TABLE li_vbpa ASSIGNING <lfs_vbpa> WITH KEY parvw = lc_bill_to.
    IF sy-subrc = 0.
*&--Fetch Ship to customer Address details
      SELECT addrnumber   "Address No.
             name1        "Name 1
             name2        "Name 2
             name3        "Name 3
             name4        "Name 4
             house_num1   "House No.
             street       "Street
             city1        "City
             city2        "District
             region       "Region
             post_code1   "Postal Code
             country      "Country
       UP TO 1 ROWS
       FROM adrc
       INTO fp_ship_to_addr
      WHERE addrnumber = <lfs_vbpa>-adrnr.
      ENDSELECT.
    ENDIF.
  ENDIF.

*&--Fetch Payment Terms Text
  PERFORM f_get_payment_terms USING fp_vbeln
                                    fp_nast
                           CHANGING fp_payment_term
                                    fp_vbak-bstkd.

ENDFORM.                    " F_GET_HEADER_DATA


*&---------------------------------------------------------------------*
*&      Form  f_get_payment_terms
*&---------------------------------------------------------------------*
*       Get Description of terms of payment
*----------------------------------------------------------------------*
*      -->FP_VBELN         Sales Document Number
*      -->FP_NAST          Message Status
*      -->FP_PAYMENT_TERM  Payment Terms Text
*      -->FP_BSTKD         Customer purchase order number
*----------------------------------------------------------------------*
FORM f_get_payment_terms USING fp_vbeln        TYPE vbeln_va
                               fp_nast         TYPE nast
                      CHANGING fp_payment_term TYPE dzterm_bez
                               fp_bstkd        TYPE bstkd.

  CONSTANTS:
    lc_posnr TYPE posnr_va VALUE '000000'.  "Header Item count

  DATA:
    lv_zterm TYPE dzterm.                   "Terms of Payment



*&--Fetch Terms of Payment Key at Header level
  SELECT SINGLE zterm    "Terms of Payment
                bstkd    "Customer purchase order number
           INTO (lv_zterm , fp_bstkd)
           FROM vbkd
          WHERE vbeln = fp_vbeln
            AND posnr = lc_posnr.
  IF sy-subrc = 0.
*&--Fetch Description of terms of payment
    SELECT SINGLE vtext   "Description of terms of payment
             FROM tvzbt
             INTO fp_payment_term
            WHERE spras = fp_nast-spras
              AND zterm = lv_zterm.
  ENDIF.

ENDFORM.                    "f_get_payment_terms

*&---------------------------------------------------------------------*
*&      Form  f_check_process_table
*&---------------------------------------------------------------------*
*       Check entries for Document Type in Process Team Control Table
*----------------------------------------------------------------------*
*  -->  FP_VKORG       Sales Organization
*  -->  FP_VTWEG       Distribution Channel
*  -->  FP_AUART       Sales Document Type
*  -->  FP_F7          Quantity Form Indicator
*  -->  FP_F8          Total Committed Value Form Indicator
*----------------------------------------------------------------------*
FORM f_check_process_table USING fp_vkorg TYPE vkorg
                                 fp_vtweg TYPE vtweg
                                 fp_auart TYPE auart
                        CHANGING fp_f7    TYPE boolean
                                 fp_f8    TYPE boolean.
  DATA:
      lv_form    TYPE z_comments.     "Form to be printed

  CONSTANTS:
*&--ABAP Program Name
      lc_program TYPE programm      VALUE 'ZOTCP0020O_CONTRACT_ACK_FORM',
*&--SD Document Type
      lc_auart   TYPE axt_parameter VALUE 'VBAK-AUART',
*&--Select Option:Option-Equal
      lc_eq      TYPE rmsae_option  VALUE 'EQ',
*&--F7 Form to be printed
      lc_f7      TYPE char20        VALUE 'F7',
*&--F8 Form to be printed
      lc_f8      TYPE char20        VALUE 'F8'.

*&--Check Document Type Active
  SELECT zz_comments   "Active/Inactive Indicaor
   UP TO 1 ROWS
    FROM zotc_prc_control
    INTO lv_form
   WHERE vkorg      = fp_vkorg
     AND vtweg      = fp_vtweg
     AND mprogram   = lc_program
     AND mparameter = lc_auart
     AND mactive    = abap_true
     AND soption    = lc_eq
     AND mvalue1    = fp_auart.
*&--If F7 form(Quantity data) to be printed
    IF lv_form = lc_f7.
      fp_f7 = abap_true.
*&--If F8 form(Total Commited Value) to be printed
    ELSEIF lv_form = lc_f8.
      fp_f8 = abap_true.
    ENDIF.
  ENDSELECT.

ENDFORM.                    " F_CHECK_PROCESS_TABLE

*&---------------------------------------------------------------------*
*&      Form  FILL_CONTROL_STRUCTURE
*&---------------------------------------------------------------------*
*       Fill Output Parameters Control Structure
*----------------------------------------------------------------------*
*      -->P_NAST             Message Status
*      -->P_FP_US_SCREEN     Print Preview
*      <--P_LX_outputparams  Form Processing Output Parameter
*----------------------------------------------------------------------*
FORM fill_control_structure USING value(fp_nast)      TYPE nast
                                  value(fp_us_screen) TYPE c
                         CHANGING fp_outputparams     TYPE sfpoutputparams.
  CLEAR: fp_outputparams.
*&--Fill Output Parameters Control Structure
  IF fp_us_screen IS INITIAL.
    CLEAR: fp_outputparams-preview.
  ELSE.
    fp_outputparams-preview = abap_true.
    fp_outputparams-noprint = abap_true.
  ENDIF.
  fp_outputparams-nodialog = abap_true.
  fp_outputparams-dest     = fp_nast-ldest.
  fp_outputparams-reqimm   = fp_nast-dimme.
  fp_outputparams-reqdel   = fp_nast-delet.
  fp_outputparams-copies   = fp_nast-anzal.
  fp_outputparams-dataset  = fp_nast-dsnam.
  fp_outputparams-suffix1  = fp_nast-dsuf1.
  fp_outputparams-suffix2  = fp_nast-dsuf2.
  fp_outputparams-covtitle = fp_nast-tdcovtitle.
  fp_outputparams-cover    = fp_nast-tdocover.
  fp_outputparams-receiver = fp_nast-tdreceiver.
  fp_outputparams-division = fp_nast-tddivision.
  fp_outputparams-reqfinal = abap_true.
  fp_outputparams-arcmode  = fp_nast-tdarmod.
  fp_outputparams-schedule = fp_nast-tdschedule.
  fp_outputparams-senddate = fp_nast-vsdat.
  fp_outputparams-sendtime = fp_nast-vsura.

ENDFORM.                    " FILL_CONTROL_STRUCTURE



*&---------------------------------------------------------------------*
*&      Form  F_XSTRING_TO_SOLIX
*&---------------------------------------------------------------------*
*       Convert String to Hexadecimal
*----------------------------------------------------------------------*
*      -->FP_LX_FORMOUT_PDF  Form String
*      -->FP_PDF_CONTENT     SAPoffice: Binary data
*----------------------------------------------------------------------*
FORM f_xstring_to_solix USING fp_lx_formout_pdf TYPE xstring
                              fp_pdf_content    TYPE solix_tab.

  DATA:
    lv_offset          TYPE i,         "Offset
    lt_solix           TYPE solix_tab, "SAPoffice: Binary data
    lx_solix_line      TYPE solix,     "SAPoffice: Binary data
    lv_pdf_string_len  TYPE i,         "PDF String Length
    lv_solix_rows      TYPE i,         "Binary data rows
    lv_last_row_length TYPE i,         "Binary data last row length
    lv_row_length      TYPE i.         "Binary data row length

  CLEAR fp_pdf_content.

*&--Transform xstring to SOLIX
  DESCRIBE TABLE lt_solix.
  lv_row_length = sy-tleng.
  lv_offset = 0.

*&--Get PDF form string length
  lv_pdf_string_len = xstrlen( fp_lx_formout_pdf ).

  lv_solix_rows = lv_pdf_string_len DIV lv_row_length.
  lv_last_row_length = lv_pdf_string_len MOD lv_row_length.
  DO lv_solix_rows TIMES.
    lx_solix_line-line =
           fp_lx_formout_pdf+lv_offset(lv_row_length).
    APPEND lx_solix_line TO fp_pdf_content.
    ADD lv_row_length TO lv_offset.
  ENDDO.
  IF lv_last_row_length > 0.
    CLEAR lx_solix_line-line.
    lx_solix_line-line = fp_lx_formout_pdf+lv_offset(lv_last_row_length).
    APPEND lx_solix_line TO fp_pdf_content.
  ENDIF.

ENDFORM.                    " F_XSTRING_TO_SOLIX
