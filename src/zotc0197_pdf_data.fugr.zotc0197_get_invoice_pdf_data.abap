FUNCTION zotc0197_get_invoice_pdf_data.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_DOC_NUMBER) TYPE  STRING
*"  EXPORTING
*"     REFERENCE(EX_OUTPUT) TYPE  Z01CA_MT_DOCUMENT_RES
*"  EXCEPTIONS
*"      WRONG_DOC_NUMBER
*"----------------------------------------------------------------------
***********************************************************************
*Program    : ZOTC0197_GET_INVOICE_PDF_DATA                           *
*Title      : Certificate of Origin                                   *
*Developer  : Neha Garg (NGARG)                                       *
*Object type: Funtion Module                                          *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: ZOTC0197_GET_INVOICE_PDF_DATA                             *
*---------------------------------------------------------------------*
*Description: Download Billing Invoice attachment in PDF format to    *
*             send to certify website                                 *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*======================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ============================*
*20-Aug-2016   NGARG        E1DK919089     Download Billing Invoice
*                                          Attachment in PDf format
*----------------------------------------------------------------------*
  DATA:
        lwa_documents TYPE z01ca_dt_documentdetails_req,       " I0138
        lwa_dockey    TYPE z01ca_dt_documentkey_req,           " I0138
        lref_opentext TYPE REF TO z01ca_cl_si_document_req_in, " Generated test implementation
        lwa_input      TYPE z01ca_mt_document_req,             " I0138 Interface
        lv_vbeln       TYPE vbeln_vf,                          " Billing Document
        lv_vbeln2       TYPE vbeln_vf.                         " Billing Document

  CONSTANTS: lc_vbeln TYPE string VALUE 'VBELN',
             lc_evo TYPE string VALUE 'EVO',
             lc_vbrk TYPE string VALUE 'VBRK',
             lc_pdf TYPE string VALUE 'PDF'.



  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = im_doc_number
    IMPORTING
      output = lv_vbeln.

  SELECT SINGLE vbeln INTO lv_vbeln2 FROM vbrk WHERE vbeln EQ lv_vbeln.
  IF sy-subrc EQ 0.
    IF lref_opentext IS NOT BOUND.
      CREATE OBJECT lref_opentext TYPE z01ca_cl_si_document_req_in.
    ENDIF. " IF lref_opentext IS NOT BOUND

    lwa_dockey-field_name = lc_vbeln.
    lwa_dockey-fieldvalue = im_doc_number.
    APPEND lwa_dockey TO lwa_documents-documentkey.
    CLEAR lwa_dockey.

    lwa_documents-source_system = lc_evo.
    lwa_documents-object_type   = lc_vbrk.
    lwa_documents-document_type = lc_pdf.
    APPEND lwa_documents TO lwa_input-mt_document_req-documents.
    CLEAR lwa_documents.

    TRY .

      CALL METHOD lref_opentext->z01ca_ii_si_document_req_in~si_document_req_in
        EXPORTING
          input  = lwa_input
        IMPORTING
          output = ex_output.

    ENDTRY.

  ELSE. " ELSE -> IF sy-subrc EQ 0
    RAISE wrong_doc_number.
  ENDIF. " IF sy-subrc EQ 0


ENDFUNCTION.
