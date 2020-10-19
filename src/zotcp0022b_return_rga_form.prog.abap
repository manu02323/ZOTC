*&---------------------------------------------------------------------*
*& Report  ZOTCP0022B_RETURN_RGA_FORM
*&---------------------------------------------------------------------*
************************************************************************
* Program    : ZOTCP0022B_RETURN_RGA_FORM                              *
* Title      : Returns RGA Form                                        *
* Developer  : Rohit Verma                                             *
* Object Type: Driver Program                                          *
* SAP Release: SAP ECC 6.0                                             *
*----------------------------------------------------------------------*
* WRICEF ID  : OTC_FDD_0022_Returns RGA Form                           *
*----------------------------------------------------------------------*
* Description: Returns Goods Authorization form is sent to the customer*
*              through email, fax or print. These forms need to be     *
*              auto-generated at the time the return order is saved.   *
*----------------------------------------------------------------------*
* Modification History:                                                *
*======================================================================*
* Date        User     Transport   Description                         *
* =========== ======== =========== ====================================*
* 24-APR-2012 RVERMA   E1DK901239  Initial development                 *
* 06-JAN-2015 MGARG    E2DK906535  Defect 2545, Serial Number of item  *
*                                  should be read by using Read_Text   *
*                                  function module                     *
* 15-SEP-2016 U034334  E1DK921274  D3_OTC_FDD_0022 Print new field cust*
*                                  material no. in Item level table,if *
*                                  present in KNMT. Allow printing of  *
*                                  the PDF generated in print preview  *
* 28-OCT-2016 U034334  E1DK921274  Defect 5450, Item SNo should be read*
*                                  & displayed in sold-to-party langu  *
*&---------------------------------------------------------------------*

REPORT  zotcp0022b_return_rga_form.

*----------------------------------------------------------------------*
*       F O R M S
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  ENTRY
*&---------------------------------------------------------------------*
*       Entry Routine for Form Processing
*----------------------------------------------------------------------*
*      -->RETURN_CODE  Return Code for errors
*      -->US_SCREEN    Print Preview
*----------------------------------------------------------------------*
FORM entry USING return_code TYPE sy-subrc  ##called " Return Value of ABAP Statements
                 us_screen   TYPE c.                 " Screen of type Character

  CONSTANTS:
     lc_nast      TYPE tabname VALUE 'NAST',  "Messages
     lc_tnapr     TYPE tabname VALUE 'TNAPR'. "Processing programs for output

*&--Related with Archiving
*  CONSTANTS:
*     lc_toadara   TYPE tabname VALUE 'TOA_DARA',  "SAP ArchiveLink structure of a DARA
*     lc_arcparams TYPE tabname VALUE 'ARC_PARAMS'."ImageLink structure

  FIELD-SYMBOLS:
     <lfs_x_nast>      TYPE nast,  "NAST Structure
     <lfs_x_tnapr>     TYPE tnapr. "TNAPR Structure

*&--Related with Archiving
*  FIELD-SYMBOLS:
*     <lfs_x_toadara>   TYPE toa_dara,         "SAP ArchiveLink structure of a DARA
*     <lfs_x_arcparams> TYPE arc_params.       "ImageLink structure

  DATA:
     lv_retcode    TYPE sy-subrc. "Returncode

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
     <lfs_x_nast>      IS ASSIGNED. "AND
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
    ELSE. " ELSE -> IF lv_retcode NE 0
      return_code = 0.
    ENDIF. " IF lv_retcode NE 0
  ELSE. " ELSE -> IF <lfs_x_tnapr> IS ASSIGNED AND
    return_code = 1.
  ENDIF. " IF <lfs_x_tnapr> IS ASSIGNED AND
ENDFORM. "ENTRY

*&---------------------------------------------------------------------*
*&      Form  F_PROCESSING
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
FORM f_processing USING fp_us_screen  TYPE c     " Processing using fp_us_ of type Character
                        fp_nast       TYPE nast  " Message Status
                        fp_tnapr      TYPE tnapr " Processing programs for output
*                        fp_arc_params TYPE arc_params "Related with Archiving
               CHANGING
*                        fp_toadara    TYPE toa_dara   "Related with Archiving
                        fp_retcode    TYPE sy-subrc. " Return Value of ABAP Statements

  CONSTANTS:
    lc_mail       TYPE fpmedium   VALUE 'MAIL',     "Mail Output Device
    lc_telefax    TYPE fpmedium   VALUE 'TELEFAX',  "Fax Output Device
    lc_error      TYPE sy-msgty   VALUE 'E',        "Error
    lc_fax        TYPE ad_comm    VALUE 'FAX',      "Fax Communication
    lc_int        TYPE ad_comm    VALUE 'INT',      "Mail Communication
    lc_pdf        TYPE so_obj_tp  VALUE 'PDF',      "PDF Object Type
    lc_mail_msg   TYPE na_nacha   VALUE '5',        "Mail Message transmission
    lc_fax_msg    TYPE na_nacha   VALUE '2',        "Fax Message transmission
    lc_archive    TYPE syarmod    VALUE '2',        "Archive Only
    lc_pr_archive TYPE syarmod    VALUE '3',        "Print & Archive
    lc_msgno      TYPE sy-msgno   VALUE '000',      "Message No.
    lc_msgid      TYPE sy-msgid   VALUE 'ZOTC_MSG'. "OTC Message ID

*&--Related with Archiving
*  CONSTANTS:
*    lc_doctyp     TYPE saedoktyp  VALUE 'PDF',       "PDF
*    lc_dara       TYPE saefktname VALUE 'DARA'.      "DARA



  DATA:
*&---------V A R I A B L E S---------*
    lv_vbeln         TYPE vbeln_va,       "Document No.
    lv_formname      TYPE fpname,         "Name of Form Object
    lv_function      TYPE rs38l_fnam,     "Name of Function Module
    lv_pdf_content   TYPE solix_tab,      "SAPoffice: Binary data
    lv_emailaddr     TYPE adr6-smtp_addr, "E-Mail Address
    lv_sent_to_all   TYPE os_boolean,     "Sent to all indicator
    lv_pdf_siz       TYPE so_obj_len,     "PDF Size
*&--Related with Archiving
*    lv_size          TYPE i,                      "Archived PDF Size
    lv_subject       TYPE so_obj_des, "Mail Subject
    lv_inupd         TYPE i,          "Update task indicator
    lv_comm_type     TYPE ad_comm,    "Communication type for customer
    lv_programm      TYPE tdprogram,  "Program Name

*&--Related with Archiving
*    lv_archiveformat TYPE toadd-doc_type,         "PDF or OTF
*    lv_documentclass TYPE toadv-doc_type,         "Document Class

*&---------R E F E R E N C E   V A R I A B L E S---------*
    lv_cx_root       TYPE REF TO cx_root,          "All Global Exceptions
    lv_send_request  TYPE REF TO cl_bcs,           "Business Communication Service
    lv_document      TYPE REF TO cl_document_bcs,  "Wrapper Class for Office Documents
    lv_recipient     TYPE REF TO if_recipient_bcs, "Interface of Recipient Object in BCS

*&---------S T R U C T U R E S---------*
    lx_itcpo         TYPE itcpo,                "SAPscript output interface
    lx_cre_addr      TYPE bapiaddr3,            "Created By Address
    lx_header        TYPE zotc_return_rga_head, "Document Header data
    lx_docparams     TYPE sfpdocparams,         "Form Parameters for Form Processing
    lx_outputparams  TYPE sfpoutputparams,      "Form Processing Output Parameter
    lx_formout       TYPE fpformoutput,         "Form Output (PDF, PDL)
    lx_vbadr         TYPE vbadr,                "Address Structure
    lx_comm_values   TYPE szadr_comm_values,    "Communicaion specific values
    lx_recipient     TYPE swotobjid,            "Mail Recepeint
    lx_sender        TYPE swotobjid,            "Mail Sender
    lx_intnast       TYPE snast,                "Message output
    lx_outputparams_fax TYPE sfpoutpar,         "Form Processing Output Fax

*&---------I N T E R N A L   T A B L E S---------*
    li_item       TYPE STANDARD TABLE OF zotc_return_rga_item,    "Item Data
    li_plant_addr TYPE STANDARD TABLE OF zotc_return_rga_address. "Plant address

*&--Check if the subroutine is called in update task.
  CALL METHOD cl_system_transaction_state=>get_in_update_task
    RECEIVING
      in_update_task = lv_inupd.

*&--Fetch form data
  PERFORM f_get_data USING fp_us_screen
                           fp_nast
                  CHANGING lx_vbadr
                           li_item
                           li_plant_addr
                           lv_vbeln
                           lx_cre_addr
                           lx_header
                           fp_retcode.
  IF fp_retcode = 1.
    RETURN.
  ENDIF. " IF fp_retcode = 1

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
    ENDIF. " IF sy-subrc <> 0

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
    ENDIF. " IF sy-subrc <> 0

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
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF lx_outputparams-device = lc_mail
  ENDIF. " IF fp_nast-nacha EQ lc_mail_msg
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
  ENDIF. " IF NOT fp_tnapr-sform IS INITIAL

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
        ENDIF. " IF lx_itcpo-tdtelenum EQ space
      ENDIF. " IF ( lv_comm_type EQ lc_fax OR lv_comm_type EQ lc_int )
    ELSE. " ELSE -> IF fp_nast-nacha EQ lc_mail_msg
      lx_outputparams-getpdf = abap_true.
    ENDIF. " IF fp_nast-nacha EQ lc_mail_msg
*&--Specific setting for FAX
    IF fp_nast-nacha EQ lc_fax_msg.
*&--Setting output parameters
      lx_outputparams-device = lc_telefax.
      IF fp_nast-telfx EQ space.
        lx_outputparams-nodialog = space.
      ENDIF. " IF fp_nast-telfx EQ space
    ENDIF. " IF fp_nast-nacha EQ lc_fax_msg
  ENDIF. " IF fp_us_screen IS INITIAL

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
  ENDIF. " IF sy-subrc <> 0
* &--To handle print and archive scenario
  IF fp_nast-tdarmod EQ lc_pr_archive.
    lx_outputparams-getpdf = abap_true.
  ENDIF. " IF fp_nast-tdarmod EQ lc_pr_archive

  CLEAR: lx_docparams.
  lx_docparams-langu = fp_nast-spras.
  lx_docparams-country = fp_nast-tland.

*&--Call the generated function module
  CALL FUNCTION lv_function
    EXPORTING
      /1bcdwb/docparams  = lx_docparams
      im_vbeln           = lv_vbeln
      im_header          = lx_header
      im_item            = li_item
      im_plant_addr      = li_plant_addr
      im_cre_addr        = lx_cre_addr
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
  ENDIF. " IF sy-subrc <> 0

*&--sending Document out via mail or FAX
  IF fp_us_screen IS INITIAL "In case of preview message should be displayed only
     AND ( fp_nast-nacha EQ lc_mail_msg OR fp_nast-nacha EQ lc_fax_msg )
     AND lx_formout IS NOT INITIAL.

*&--Get Email id from address no
    lv_emailaddr = lx_header-cntct_smtp_addr.

*&--When more than one address is maintained default address should be selected.
*&--When there is only one mail id then that will have default flag set
*&--Set FAX specific setting
    IF fp_nast-nacha EQ lc_mail_msg.
      lx_outputparams_fax-telenum = lx_itcpo-tdtelenum.
      lx_outputparams_fax-teleland = lx_itcpo-tdteleland.
    ELSE. " ELSE -> IF fp_nast-nacha EQ lc_mail_msg
      IF fp_nast-telfx NE space.
        lx_outputparams_fax-telenum  = fp_nast-telfx.
        IF fp_nast-tland IS INITIAL.
          lx_outputparams_fax-teleland = lx_vbadr-land1.
        ELSE. " ELSE -> IF fp_nast-tland IS INITIAL
          lx_outputparams_fax-teleland = fp_nast-tland.
        ENDIF. " IF fp_nast-tland IS INITIAL
      ENDIF. " IF fp_nast-telfx NE space
    ENDIF. " IF fp_nast-nacha EQ lc_mail_msg

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
          CONCATENATE 'Confirmation of your RGA Order #'(001) lv_vbeln INTO lv_subject
                                        SEPARATED BY space.
          lv_document = cl_document_bcs=>create_document(
                    i_type    = lc_pdf
                    i_hex     = lv_pdf_content
                    i_length  = lv_pdf_siz
                    i_subject = lv_subject ). "#EC NOTEXT

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
                      msg_v1    = 'Customer Email address not maintained'(002)
                    EXCEPTIONS
                      OTHERS    = 1.
                  IF sy-subrc <> 0.
                    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                  ENDIF. " IF sy-subrc <> 0
                  fp_retcode = 1.
                  RETURN.
                ENDIF. " IF lv_emailaddr IS INITIAL

*&--Add recipient (e-mail address)
                lv_recipient = cl_cam_address_bcs=>create_internet_address(
                i_address_string = lv_emailaddr ).
              ELSE. " ELSE -> IF lv_comm_type EQ lc_int
                IF lx_outputparams_fax-telenum IS INITIAL OR
                   lx_outputparams_fax-teleland IS INITIAL.
                  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
                    EXPORTING
                      msg_arbgb = lc_msgid
                      msg_nr    = lc_msgno
                      msg_ty    = lc_error
                      msg_v1    = 'Customer Fax number not maintained'(003)
                    EXCEPTIONS
                      OTHERS    = 1.
                  IF sy-subrc <> 0.
                    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                  ENDIF. " IF sy-subrc <> 0
                  fp_retcode = 1.
                  RETURN.
                ENDIF. " IF lx_outputparams_fax-telenum IS INITIAL OR
*&--Add recipient (fax address)
                lv_recipient = cl_cam_address_bcs=>create_fax_address(
                                 i_country = lx_outputparams_fax-teleland
                                 i_number  = lx_outputparams_fax-telenum ).
              ENDIF. " IF lv_comm_type EQ lc_int

            WHEN lc_fax_msg.
              IF lx_outputparams_fax-telenum IS INITIAL OR
                 lx_outputparams_fax-teleland IS INITIAL.
                CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
                  EXPORTING
                    msg_arbgb = lc_msgid
                    msg_nr    = lc_msgno
                    msg_ty    = lc_error
                    msg_v1    = 'Customer Fax number not maintained'(003)
                  EXCEPTIONS
                    OTHERS    = 1.
                IF sy-subrc <> 0.
                  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                ENDIF. " IF sy-subrc <> 0

                fp_retcode = 1.
                RETURN.
              ENDIF. " IF lx_outputparams_fax-telenum IS INITIAL OR
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
              MESSAGE i022(so). " Document sent
            ENDIF. " IF lv_sent_to_all = abap_true
*&--Explicit 'commit work' is mandatory!
            COMMIT WORK.
          ENDIF. " IF lv_inupd = 0
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
                msg_v1    = 'Sending Mail/Fax Failed'(004)
              EXCEPTIONS
                OTHERS    = 1.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF. " IF sy-subrc <> 0
            fp_retcode = 1.
            RETURN.
          ELSE. " ELSE -> IF lv_comm_type EQ lc_int
            CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
              EXPORTING
                msg_arbgb = lc_msgid
                msg_nr    = lc_msgno
                msg_ty    = lc_error
                msg_v1    = 'Sending Fax Failed'(005)
              EXCEPTIONS
                OTHERS    = 1.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF. " IF sy-subrc <> 0
            fp_retcode = 1.
            RETURN.
          ENDIF. " IF lv_comm_type EQ lc_int

          fp_retcode = 1.
          RETURN.
      ENDTRY.
    ENDIF. " IF lv_comm_type EQ lc_fax OR
  ENDIF. " IF fp_us_screen IS INITIAL

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
  ENDIF. " IF sy-subrc <> 0

  FREE li_item.

ENDFORM. "F_PROCESSING


*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       General provision of data for the form
*----------------------------------------------------------------------*
*      -->FP_SCREEN               Preview on Printer or Screen
*      -->FP_NAST                 Output Messages
*      -->FP_VBADR                Address work area
*      -->FP_I_ITEM               Return RGA Item Data
*      -->FP_I_PLANT_ADDR         Plant Address Data
*      -->FP_VBELN                Sales Document No.
*      -->FP_CRE_ADDR             Created By Address
*      -->FP_HEADER               Return RGA Header Data
*      -->FP_RETCODE              Return Code
*----------------------------------------------------------------------*
FORM f_get_data USING fp_screen       TYPE c                    " Get_data using fp_screen of type Character
                      fp_nast         TYPE nast                 " Message Status
             CHANGING fp_vbadr        TYPE vbadr                " Address work area
                      fp_i_item       TYPE zotc_t_return_rga_item
                      fp_i_plant_addr TYPE zotc_t_return_rga_address
                      fp_vbeln        TYPE vbeln_va             " Sales Document
                      fp_cre_addr     TYPE bapiaddr3            " BAPI reference structure for addresses (contact person)
                      fp_header       TYPE zotc_return_rga_head " Header data for Returns RGA Form
                      fp_retcode      TYPE sy-subrc.            " Return Value of ABAP Statements

  DATA: lx_vbpa  TYPE vbpa. "Partner data

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
  ENDIF. " IF sy-subrc NE 0

*&--Fetch Sales Document Header data
  PERFORM f_get_header_data USING fp_vbeln
                         CHANGING fp_cre_addr
                                  fp_header.

*&--Fetch Sales Document Item data
  PERFORM f_get_item_data USING fp_vbeln
* ---> Begin of Insert for D3_OTC_FDD_0022 by U034334
                                fp_header
* <--- End   of Insert for D3_OTC_FDD_0022 by U034334
                       CHANGING fp_i_item
                                fp_i_plant_addr.

ENDFORM. "F_GET_DATA
**
*---------------------------------------------------------------------*
*       FORM PROTOCOL_UPDATE                                          *
*---------------------------------------------------------------------*
*       The messages are collected for the processing protocol.       *
*---------------------------------------------------------------------*
*      -->FP_SCREEN        Print Preview Indicator
*---------------------------------------------------------------------*
FORM protocol_update USING fp_screen TYPE c. " Update using fp_ of type Character

  IF fp_screen <> space.
    RETURN.
  ENDIF. " IF fp_screen <> space
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
  ENDIF. " IF sy-subrc <> 0
ENDFORM. "PROTOCOL_UPDATE

*&---------------------------------------------------------------------*
*&      Form  F_GET_ITEM_DATA
*&---------------------------------------------------------------------*
*       Fetch Sales Document Item data
*----------------------------------------------------------------------*
*      -->FP_VBELN        Sales Document Number
*      -->FP_HEADER       Sales Document Header data
*      -->FP_I_ITEM       Order Acknowledgement Item data
*      -->FP_I_PLANT_ADDR Plant Address
*----------------------------------------------------------------------*
FORM f_get_item_data USING fp_vbeln        TYPE vbeln_va " Sales Document
* ---> Begin of Insert for D3_OTC_FDD_0022 by U034334
                           fp_header       TYPE zotc_return_rga_head " Header data for Returns RGA Form
* <--- End   of Insert for D3_OTC_FDD_0022 by U034334
                  CHANGING fp_i_item       TYPE zotc_t_return_rga_item
                           fp_i_plant_addr TYPE zotc_t_return_rga_address.

  TYPES:
* ---> Begin of Delete for D2_OTC_FDD_0022 Defect 2545 by MGARG
**&--VBFA data
*  BEGIN OF lty_vbfa,
*    vbelv   TYPE vbeln_von,  "Preceding SD document
*    posnv   TYPE posnr_von,  "Preceding item of an SD document
*    vbeln   TYPE vbeln_nach, "Subsequent SD document
*    posnn   TYPE posnr_nach, "Subsequent item of an SD document
*    vbtyp_n TYPE vbtyp_n,    "Document category of subsequent document
*  END OF lty_vbfa,
* ---> End of Delete for D2_OTC_FDD_0022 Defect 2545 by MGARG

*&--Address Data
  BEGIN OF lty_adrc,
    adrnr TYPE adrnr, "Address Number
    land1 TYPE land1, "Country
  END OF lty_adrc,

* ---> Begin of Delete for D2_OTC_FDD_0022 Defect 2545 by MGARG
**&--Document Header for Serial Numbers for Delivery
*  BEGIN OF lty_ser01,
*    obknr TYPE objknr,   "Object list number
*    vbeln TYPE vbeln_vl, "Delivery
*    posnr TYPE posnr_vl, "Delivery Item
*  END OF lty_ser01,
*
**&--Serial number data
*  BEGIN OF lty_objk,
*    obknr TYPE objknr, "Object list number
*    obzae TYPE objza,  "Object list counters
*    sernr TYPE gernr,  "Serial Number
*  END OF lty_objk,
* ---> End of Delete for D2_OTC_FDD_0022 Defect 2545 by MGARG

*&--VBAP Item data
  BEGIN OF lty_vbap,
    posnr  TYPE  posnr_va,  "Item No.
    matnr	 TYPE  matnr,     "Material Number
    arktx  TYPE  arktx,     "Description
    zmeng  TYPE  kwmeng,    "Quantity
    zieme  TYPE  dzieme,    "UOM
    werks  TYPE  werks_ext, "Plant
  END OF lty_vbap,

* ---> Begin of Insert for D3_OTC_FDD_0022 by U034334
  BEGIN OF lty_knmt,
    matnr TYPE matnr,    " Material Number
    kdmat TYPE matnr_ku, " Material Number Used by Customer
  END OF lty_knmt.
* <--- End   of Insert for D3_OTC_FDD_0022 by U034334
  CONSTANTS:
    lc_doc_cat  TYPE vbtyp_n VALUE 'T'. "Doc category for Returns Delivery

  DATA:
    li_vbap       TYPE STANDARD TABLE OF lty_vbap, "Item Data
    li_vbap_tmp   TYPE STANDARD TABLE OF lty_vbap, "Item Data
* ---> Begin of Delete for D2_OTC_FDD_0022 Defect 2545 by MGARG
*    li_vbfa       TYPE STANDARD TABLE OF lty_vbfa,  "VBFA data
*    li_vbfa_tmp   TYPE STANDARD TABLE OF lty_vbfa,  "VBFA data
*    li_objk       TYPE STANDARD TABLE OF lty_objk,  "Serial Number data
*    li_ser01      TYPE STANDARD TABLE OF lty_ser01, "Header data for serial number
* ---> End of Delete for D2_OTC_FDD_0022 Defect 2545 by MGARG
    li_adrc       TYPE STANDARD TABLE OF lty_adrc, "Address data
    li_plant_addr TYPE zotc_t_return_rga_address,  "Plant address data
    lwa_item      TYPE zotc_return_rga_item,       "Work Area-Item Data
* ---> Begin of Delete for D2_OTC_FDD_0022 Defect 2545 by MGARG
*    lwa_objk      TYPE lty_objk,                    "Work Area-Serial No Data
*    lwa_vbfa      TYPE lty_vbfa,                    "Work Area-VBFA data
* ---> End of Delete for D2_OTC_FDD_0022 Defect 2545 by MGARG
    lv_count      TYPE int4,    "Count
    lv_index      TYPE sytabix, "Index
* ---> Begin of Insert for D3_OTC_FDD_0022 by U034334
    li_knmt       TYPE STANDARD TABLE OF lty_knmt, "KNMT data
    lwa_knmt      TYPE lty_knmt.                   "Work Area-KNMT data
* <--- End   of Insert for D3_OTC_FDD_0022 by U034334

  FIELD-SYMBOLS:
    <lfs_vbap>       TYPE lty_vbap, "Item Data
* ---> Begin of Delete for D2_OTC_FDD_0022 Defect 2545 by MGARG
*    <lfs_vbfa>       TYPE lty_vbfa,                "VBFA Data
*    <lfs_ser01>      TYPE lty_ser01,               "Header for Serial Number
*    <lfs_objk>       TYPE lty_objk,                "Serial Number Data
* ---> End of Delete for D2_OTC_FDD_0022 Defect 2545 by MGARG
    <lfs_adrc>       TYPE lty_adrc,                "Address Data
    <lfs_plant_addr> TYPE zotc_return_rga_address. "Plant Address Data

* ---> Begin of Delete for D3_OTC_FDD_0022 Defect 5450 by U034334
** ---> Begin of Insert for D2_OTC_FDD_0022 Defect 2545 by MGARG
*  CONSTANTS:
*   lc_text_id TYPE tdid     VALUE 'Z013', " Text ID
*   lc_object  TYPE tdobject VALUE 'VBBP'. " Texts: Application Object
*
*  DATA :
*   lv_name   TYPE tdobname,                               "Field name
*   li_sernr  TYPE STANDARD TABLE OF tline INITIAL SIZE 0. " SAPscript: Text Lines
*
*  FIELD-SYMBOLS :
*   <lfs_sernr> TYPE tline. " SAPscript: Text Lines
** ---> End of Insert for D2_OTC_FDD_0022 Defect 2545 by MGARG
* ---> End   of Delete for D3_OTC_FDD_0022 Defect 5450 by U034334

*&--Fetch Item data from VBAP
  SELECT posnr  "Item No.
         matnr  "Material Number
         arktx  "Description
         kwmeng "Quantity
         zieme  "UOM
         werks  "Plant
    FROM vbap   " Sales Document: Item Data
    INTO TABLE li_vbap
   WHERE vbeln = fp_vbeln.
  IF sy-subrc = 0.
    SORT li_vbap BY werks posnr.

    li_vbap_tmp[] = li_vbap[].
    SORT li_vbap_tmp BY werks.
    DELETE ADJACENT DUPLICATES FROM li_vbap_tmp COMPARING werks.

*&--Fetch Plant Address data from T001W
    IF li_vbap_tmp[] IS NOT INITIAL.
      SELECT werks "Plant
             adrnr "Address Number
        FROM t001w " Plants/Branches
        INTO TABLE fp_i_plant_addr
        FOR ALL ENTRIES IN li_vbap_tmp
        WHERE werks EQ li_vbap_tmp-werks.

      IF sy-subrc EQ 0.

        SORT fp_i_plant_addr BY werks adrnr.

        li_plant_addr[] = fp_i_plant_addr[].

        SORT li_plant_addr BY adrnr.
        DELETE ADJACENT DUPLICATES FROM li_plant_addr
                              COMPARING adrnr.

        IF li_plant_addr IS NOT INITIAL.
*&--Fetch Plant Address data from ADRC
          SELECT addrnumber "Address Number
                 country    "Country
            FROM adrc       " Addresses (Business Address Services)
            INTO TABLE li_adrc
            FOR ALL ENTRIES IN li_plant_addr
            WHERE addrnumber EQ li_plant_addr-adrnr.

          IF sy-subrc EQ 0.

            SORT li_adrc BY adrnr.
            DELETE ADJACENT DUPLICATES FROM li_adrc
                                  COMPARING adrnr.

*&--Populating Country field value in FP_I_PLANT_ADDR table
            LOOP AT fp_i_plant_addr ASSIGNING <lfs_plant_addr>.
              READ TABLE li_adrc ASSIGNING <lfs_adrc>
                                 WITH KEY adrnr = <lfs_plant_addr>-adrnr
                                 BINARY SEARCH.
              IF sy-subrc EQ 0.
                <lfs_plant_addr>-land1 = <lfs_adrc>-land1.
              ENDIF. " IF sy-subrc EQ 0
            ENDLOOP. " LOOP AT fp_i_plant_addr ASSIGNING <lfs_plant_addr>

          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF li_plant_addr IS NOT INITIAL
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF li_vbap_tmp[] IS NOT INITIAL

    REFRESH: li_vbap_tmp,
             li_plant_addr,
             li_adrc.

* ---> Begin of Insert for D3_OTC_FDD_0022 by U034334
    li_vbap_tmp[] = li_vbap[].
    SORT li_vbap_tmp BY matnr.
    DELETE ADJACENT DUPLICATES FROM li_vbap_tmp COMPARING matnr.
    IF li_vbap_tmp[] IS NOT INITIAL.
      SELECT matnr kdmat " Material Number Used by Customer
        FROM knmt        " Customer-Material Info Record Data Table
        INTO TABLE li_knmt
        FOR ALL ENTRIES IN li_vbap_tmp
        WHERE vkorg = fp_header-vkorg
        AND   vtweg = fp_header-vtweg
        AND   kunnr = fp_header-kunnr
        AND   matnr = li_vbap_tmp-matnr.
      IF sy-subrc = 0.
        SORT li_knmt BY matnr .
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF li_vbap_tmp[] IS NOT INITIAL
    REFRESH li_vbap_tmp.
* <--- End   of Insert for D3_OTC_FDD_0022 by U034334


* ---> Begin of Delete for D2_OTC_FDD_0022 Defect 2545 by MGARG
**&--Fetch Return Delivery data from VBFA
*    SELECT vbelv   "Preceeding Document
*           posnv   "Preceeding Item
*           vbeln   "Subsequent Document
*           posnn   "Subsequent Item
*           vbtyp_n "Subsequent Document Category
*      FROM vbfa    " Sales Document Flow
*      INTO TABLE li_vbfa
*      FOR ALL ENTRIES IN li_vbap
*      WHERE vbelv   EQ fp_vbeln
*      AND   posnv   EQ li_vbap-posnr
*      AND   vbtyp_n EQ lc_doc_cat.
*
*    IF sy-subrc EQ 0.
*      SORT li_vbfa BY vbelv posnv.

**&--Fetch Document Header for Serial No. for Delivery from SER01
*      SELECT obknr    "Object List Number
*             lief_nr  "Delivery
*             posnr    "Delivery Item
*        FROM ser01
*        INTO TABLE li_ser01
*        FOR ALL ENTRIES IN li_vbfa
*        WHERE lief_nr EQ li_vbfa-vbeln
*        AND   posnr   EQ li_vbfa-posnn.
*      IF sy-subrc EQ 0.
*        SORT li_ser01 BY vbeln posnr.
*      ENDIF.
*
**&--Filtering records for which header for serial no. is not fetched from SER01
*      LOOP AT li_vbfa ASSIGNING <lfs_vbfa>.
*        READ TABLE li_ser01 TRANSPORTING NO FIELDS
*                            WITH KEY vbeln = <lfs_vbfa>-vbeln
*                                     posnr = <lfs_vbfa>-posnn
*                            BINARY SEARCH.
*        IF sy-subrc NE 0.
*          APPEND <lfs_vbfa> TO li_vbfa_tmp.
*        ENDIF.
*      ENDLOOP.
*    ELSE.
**&--If data not found from VBFA then appending VBAP data into LI_VBFA
**&--table for fetching data of serial number, those return orders are
**&--created for BAAN
*      LOOP AT li_vbap ASSIGNING <lfs_vbap>.
*        lwa_vbfa-vbelv = fp_vbeln.
*        lwa_vbfa-posnv = <lfs_vbap>-posnr.
*
*        APPEND lwa_vbfa TO li_vbfa.
*        APPEND lwa_vbfa TO li_vbfa_tmp.
*
*        CLEAR lwa_vbfa.
*      ENDLOOP.    "LI_VBAP
*    ENDIF.

*    SORT li_vbfa_tmp BY vbelv posnv.

*    IF li_vbfa_tmp IS NOT INITIAL.
**&--Fetch Document Header for Serial No. for Document from SER02
*      SELECT obknr    "Object List Number
*             sdaufnr  "Sales Document
*             posnr    "Sales Doc Item
*        FROM ser02
*        APPENDING TABLE li_ser01
*        FOR ALL ENTRIES IN li_vbfa_tmp
*        WHERE sdaufnr EQ li_vbfa_tmp-vbelv
*        AND   posnr   EQ li_vbfa_tmp-posnv.
*
*      IF sy-subrc EQ 0.
*        SORT li_ser01 BY vbeln posnr.
*      ENDIF.
*    ENDIF.

*    REFRESH li_vbfa_tmp.

*    IF li_ser01 IS NOT INITIAL.
**&--Fetch Serial Number data from OBJK
*      SELECT obknr    "Object List No.
*             obzae    "Object list counters
*             sernr    "Serial Number
*        FROM objk
*        INTO TABLE li_objk
*        FOR ALL ENTRIES IN li_ser01
*        WHERE obknr EQ li_ser01-obknr.
*
*      IF sy-subrc EQ 0.
*        SORT li_objk BY obknr.
*      ENDIF.
*    ENDIF.
* ---> End of Delete for D2_OTC_FDD_0022 Defect 2545 by MGARG

*&--Merging Item data and Serial Number Data
    LOOP AT li_vbap ASSIGNING <lfs_vbap>.

*&--Increment Position
      lv_count = lv_count + 1.
      lwa_item-posn  = lv_count.
* ---> Begin of Insert for D3_OTC_FDD_0022 Defect_5450 by U034334
      lwa_item-posnr = <lfs_vbap>-posnr.
* ---> End   of Insert for D3_OTC_FDD_0022 Defect_5450 by U034334
      lwa_item-matnr = <lfs_vbap>-matnr.
      lwa_item-arktx = <lfs_vbap>-arktx.
      lwa_item-zmeng = <lfs_vbap>-zmeng.
      lwa_item-zieme = <lfs_vbap>-zieme.
      lwa_item-werks = <lfs_vbap>-werks.

* ---> Begin of Delete for D3_OTC_FDD_0022 Defect_5450 by U034334
* Serial Number Text needs to be read in the sold-to party language
* ---> Begin of Insert for D2_OTC_FDD_0022 Defect 2545 by MGARG
* As per new requirement, Equipment Serial no of item is fetched
* from function module "READ_TEXT"
*      CONCATENATE fp_vbeln <lfs_vbap>-posnr INTO lv_name.
** Read Serial number of material
*      CALL FUNCTION 'READ_TEXT'
*        EXPORTING
*          id                      = lc_text_id
*          language                = sy-langu
*          name                    = lv_name
*          object                  = lc_object
*        TABLES
*          lines                   = li_sernr
*        EXCEPTIONS
*          id                      = 1
*          language                = 2
*          name                    = 3
*          not_found               = 4
*          object                  = 5
*          reference_check         = 6
*          wrong_access_to_archive = 7
*          OTHERS                  = 8.
*
*      IF sy-subrc IS INITIAL.
*        LOOP AT li_sernr ASSIGNING <lfs_sernr>.
*          IF <lfs_sernr>-tdline IS NOT INITIAL.
*            CONCATENATE lwa_item-sernr <lfs_sernr>-tdline INTO lwa_item-sernr
*            SEPARATED BY space.
*          ENDIF. " IF <lfs_sernr>-tdline IS NOT INITIAL
*        ENDLOOP. " LOOP AT li_sernr ASSIGNING <lfs_sernr>
*        UNASSIGN <lfs_sernr>.
*      ENDIF. " IF sy-subrc IS INITIAL
* <--- End   of Delete for D3_OTC_FDD_0022 Defect_5450 by U034334

* ---> Begin of Insert for D3_OTC_FDD_0022 by U034334
      READ TABLE li_knmt INTO lwa_knmt
                         WITH KEY matnr = <lfs_vbap>-matnr
                         BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_item-kdmat = lwa_knmt-kdmat.
        CLEAR lwa_knmt.
      ENDIF. " IF sy-subrc = 0
* <--- End   of Insert for D3_OTC_FDD_0022 by U034334

      APPEND lwa_item TO fp_i_item.
      CLEAR: lwa_item.
* ---> End of Insert for D2_OTC_FDD_0022 Defect 2545 by MGARG

* ---> Begin of Delete for D2_OTC_FDD_0022 Defect 2545 by MGARG
**&--Read return delivery data/return orders created for BAAN
*      READ TABLE li_vbfa ASSIGNING <lfs_vbfa>
*                         WITH KEY vbelv = fp_vbeln
*                                  posnv = <lfs_vbap>-posnr
*                         BINARY SEARCH.
*      IF sy-subrc EQ 0.
**&--Read header data of serial number based on return delivery
*        READ TABLE li_ser01 ASSIGNING <lfs_ser01>
*                            WITH KEY vbeln = <lfs_vbfa>-vbeln
*                                     posnr = <lfs_vbfa>-posnn
*                            BINARY SEARCH.
*        IF sy-subrc EQ 0.
**&--Read Serial number data using parallel cursor
**&--as a material can have multiple serial number
*          READ TABLE li_objk INTO lwa_objk
*                             WITH KEY obknr = <lfs_ser01>-obknr
*                             BINARY SEARCH.
*          IF sy-subrc EQ 0.
*            lv_index = sy-tabix.
*            LOOP AT li_objk ASSIGNING <lfs_objk> FROM lv_index.
*              IF lwa_objk-obknr NE <lfs_objk>-obknr.
*                EXIT.
*              ENDIF.
*              lwa_item-sernr = <lfs_objk>-sernr.
*              APPEND lwa_item TO fp_i_item.
*            ENDLOOP.    "LI_OBJK
*          ENDIF.
*        ELSE.
**&--If header data of serial number not found based on return delivery
**&--then read header data of serial number based on return order
*          READ TABLE li_ser01 ASSIGNING <lfs_ser01>
*                              WITH KEY vbeln = <lfs_vbfa>-vbelv
*                                       posnr = <lfs_vbfa>-posnv
*                              BINARY SEARCH.
*          IF sy-subrc EQ 0.
**&--Read Serial number data using parallel cursor
**&--as a material can have multiple serial number
*            READ TABLE li_objk INTO lwa_objk
*                               WITH KEY obknr = <lfs_ser01>-obknr
*                               BINARY SEARCH.
*            IF sy-subrc EQ 0.
*              lv_index = sy-tabix.
*              LOOP AT li_objk ASSIGNING <lfs_objk> FROM lv_index.
*                IF lwa_objk-obknr NE <lfs_objk>-obknr.
*                  EXIT.
*                ENDIF.
*                lwa_item-sernr = <lfs_objk>-sernr.
*      APPEND lwa_item TO fp_i_item.
*              ENDLOOP.   "LI_OBJK
*            ENDIF.
*          ELSE.
**&--No serial data found, append item data without serial
**&--number
*            APPEND lwa_item TO fp_i_item.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*      CLEAR: lwa_item, lwa_objk, lv_index.
* ---> End of Delete for D2_OTC_FDD_0022 Defect 2545 by MGARG

    ENDLOOP. " LOOP AT li_vbap ASSIGNING <lfs_vbap>
  ENDIF. " IF sy-subrc = 0
  FREE: li_vbap, li_vbap_tmp.

ENDFORM. " F_GET_ITEM_DATA


*&---------------------------------------------------------------------*
*&      Form  F_GET_HEADER_DATA
*&---------------------------------------------------------------------*
*       Get Sales Document Header data
*----------------------------------------------------------------------*
*      -->FP_VBELN                Sales Document No.
*      -->FP_CRE_ADDR             Created By Address
*      -->FP_HEADER               Sales Document Header data
*----------------------------------------------------------------------*
FORM f_get_header_data USING fp_vbeln     TYPE vbeln_va               " Sales Document
                    CHANGING fp_cre_addr  TYPE bapiaddr3              " BAPI reference structure for addresses (contact person)
                             fp_header    TYPE zotc_return_rga_head . " Header data for Returns RGA Form

*&--Address Data
  TYPES:
         BEGIN OF lty_adrc,
           adrnr      TYPE ad_addrnum, "Address No.
           name1      TYPE ad_name1,   "Name
           city1      TYPE ad_city1,   "City
           post_code1 TYPE ad_pstcd1,  "Postal Code
           region     TYPE regio,      "Region
           tel_number TYPE ad_tlnmbr1, "Telephone No.
         END OF lty_adrc.

  CONSTANTS:
    lc_add_90       TYPE i               VALUE '90',     "Constant value to add 90 in date
    lc_contact      TYPE parvw           VALUE 'AP',     "Contact person
    lc_order        TYPE vbtyp_v         VALUE 'C',      "Order type
    lc_sch_agr      TYPE vbtyp_v         VALUE 'E',      "Scheduling Agreement type
    lc_ord_chg      TYPE vbtyp_v         VALUE 'I',      "Order W/O Charge type
    lc_posnr        TYPE posnr_va        VALUE '000000'. "Header Item count

  DATA:
    lv_comp_adr TYPE adrnr,                      "Company address number
    lv_part_adr TYPE adrnr,                      "Partner address number
    li_return   TYPE STANDARD TABLE OF bapiret2, "BAPI Return table
    li_adrc     TYPE STANDARD TABLE OF lty_adrc. "Address data table

  FIELD-SYMBOLS: <lfs_adrc> TYPE lty_adrc. "Address data field symbol

* ---> Begin of Delete for D3_OTC_FDD_0022 by U034334
**&--Fetch Sales document header data
*  SELECT SINGLE ernam    "Name of Person who Created the Object
*                bukrs_vf "Company Code
*                erdat    "Date on Which Record Was Created
*           FROM vbak     " Sales Document: Header Data
*           INTO (fp_header-ernam, fp_header-bukrs_vf, fp_header-erdat)
*          WHERE vbeln = fp_vbeln.
* <--- End   of Delete for D3_OTC_FDD_0022 by U034334

* ---> Begin of Insert for D3_OTC_FDD_0022 by U034334
*&--Fetch Sales document header data
  SELECT SINGLE erdat    "Date on Which Record Was Created
                ernam    "Name of Person who Created the Object
                vkorg    " Sales Organization
                vtweg    " Distribution Channel
                kunnr    " Sold-to party
                bukrs_vf "Company Code
           FROM vbak     " Sales Document: Header Data
           INTO (fp_header-erdat, fp_header-ernam, fp_header-vkorg, fp_header-vtweg, fp_header-kunnr, fp_header-bukrs_vf)
          WHERE vbeln = fp_vbeln.
* <--- End   of Insert for D3_OTC_FDD_0022 by U034334

  IF sy-subrc = 0.
* Return by date will be +90 days of created date
    fp_header-erdat = fp_header-erdat + lc_add_90.

*&--Fetch Address data of Person who Created Object
    CALL FUNCTION 'BAPI_USER_GET_DETAIL'
      EXPORTING
        username = fp_header-ernam
      IMPORTING
        address  = fp_cre_addr
      TABLES
        return   = li_return.

*&--Fetch Company Address Number
    SELECT SINGLE adrnr " Address
      INTO lv_comp_adr
      FROM t001         " Company Codes
      WHERE bukrs EQ fp_header-bukrs_vf.

  ENDIF. " IF sy-subrc = 0

*&--Fetch Sales Document: Partner data
  SELECT SINGLE adrnr "Address Number
    FROM vbpa         " Sales Document: Partner
    INTO lv_part_adr
   WHERE vbeln EQ fp_vbeln
     AND posnr EQ lc_posnr
     AND parvw EQ lc_contact.
  IF sy-subrc = 0.

*&--Fetch Contact Person E-Mail Address
    SELECT smtp_addr "E-Mail Address
     UP TO 1 ROWS
      FROM adr6      " E-Mail Addresses (Business Address Services)
       INTO fp_header-cntct_smtp_addr
     WHERE addrnumber EQ lv_part_adr.
    ENDSELECT.

  ENDIF. " IF sy-subrc = 0


  IF lv_comp_adr IS NOT INITIAL OR
     lv_part_adr IS NOT INITIAL.

*&--Fetch address data for Company and Contact Person
    SELECT addrnumber "Address Number
           name1      "Name
           city1      "City
           post_code1 "Postal Code
           region     "Region
           tel_number "Telephone No.
      FROM adrc       " Addresses (Business Address Services)
      INTO TABLE li_adrc
      WHERE addrnumber IN (lv_comp_adr, lv_part_adr).

    IF sy-subrc EQ 0.
      SORT li_adrc BY adrnr.

*&--Read data for Company address
      READ TABLE li_adrc ASSIGNING <lfs_adrc>
                         WITH KEY adrnr = lv_comp_adr
                         BINARY SEARCH.
      IF sy-subrc EQ 0.
        fp_header-comp_name1 = <lfs_adrc>-name1.
        fp_header-comp_city1 = <lfs_adrc>-city1.
        fp_header-comp_regio = <lfs_adrc>-region.
        fp_header-comp_pcode = <lfs_adrc>-post_code1.
      ENDIF. " IF sy-subrc EQ 0

*&--Read data for Contact Person address
      READ TABLE li_adrc ASSIGNING <lfs_adrc>
                         WITH KEY adrnr = lv_part_adr
                         BINARY SEARCH.
      IF sy-subrc EQ 0.
        fp_header-cntct_name1      = <lfs_adrc>-name1.
        fp_header-cntct_tel_number = <lfs_adrc>-tel_number.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0

  ENDIF. " IF lv_comp_adr IS NOT INITIAL OR

*&--Fetch Customer Purchase Order Number at Header level
  SELECT SINGLE bstkd "Customer purchase order number
           INTO fp_header-bstkd
           FROM vbkd  " Sales Document: Business Data
          WHERE vbeln = fp_vbeln
            AND posnr = lc_posnr.

*&--Fetch Original Order Number at Header level
  SELECT vbelv "Preceeding Document/Original Order
    UP TO 1 ROWS
    INTO fp_header-orig_order
    FROM vbfa  " Sales Document Flow
    WHERE vbeln   EQ fp_vbeln
    AND   vbtyp_v IN (lc_order, lc_sch_agr, lc_ord_chg).
  ENDSELECT.

ENDFORM. " F_GET_HEADER_DATA

*&---------------------------------------------------------------------*
*&      Form  FILL_CONTROL_STRUCTURE
*&---------------------------------------------------------------------*
*       Fill Output Parameters Control Structure
*----------------------------------------------------------------------*
*      -->P_NAST             Message Status
*      -->P_FP_US_SCREEN     Print Preview
*      <--P_LX_outputparams  Form Processing Output Parameter
*----------------------------------------------------------------------*
FORM fill_control_structure USING value(fp_nast)      TYPE nast             " Message Status
                                  value(fp_us_screen) TYPE c                " Us_screen) of type Character
                         CHANGING fp_outputparams     TYPE sfpoutputparams. " Form Processing Output Parameter
  CLEAR: fp_outputparams.
*&--Fill Output Parameters Control Structure
  IF fp_us_screen IS INITIAL.
    CLEAR: fp_outputparams-preview.
  ELSE. " ELSE -> IF fp_us_screen IS INITIAL
    fp_outputparams-preview = abap_true.
* ---> Begin of Delete for D3_OTC_FDD_0022 by U034334
*   fp_outputparams-noprint = abap_true.
* <--- End   of Delete for D3_OTC_FDD_0022 by U034334
* ---> Begin of Insert for D3_OTC_FDD_0022 by U034334
    fp_outputparams-noprint = space.
* <--- End   of Insert for D3_OTC_FDD_0022 by U034334
  ENDIF. " IF fp_us_screen IS INITIAL

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

ENDFORM. " FILL_CONTROL_STRUCTURE



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
  ENDIF. " IF lv_last_row_length > 0

ENDFORM. " F_XSTRING_TO_SOLIX
