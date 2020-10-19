FUNCTION ZOTC_0011_SD_GET_LIFNR .
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_BELNR) TYPE  VBELN_VF
*"  EXPORTING
*"     REFERENCE(EX_LIFNR) TYPE  LIFNR_ED1
*"--------------------------------------------------------------------
***********************************************************************
*Program    : ZOTC_0011_SD_GET_LIFNR( Function Module )               *
*Title      : Fetch Vendor number from Sales order number via IDOC    *
*Developer  : Manmeet Singh                                           *
*Object type: Function Module                                         *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0011_SAP                                           *
*---------------------------------------------------------------------*
*Description: Function Module to retrieve Vendor number on the base of*
*             sales order number                                      *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*05-Jun-2014  Msingh1       E2DK900763      FM to get vendor for sales
*                                            order
*---------------------------------------------------------------------*
*** Constant
  CONSTANTS:
         lc_obj_ty          TYPE swo_objtyp VALUE 'BUS2032', " Object Type
         lc_rel_ty          TYPE binreltyp  VALUE 'IDC1',    " Relationship type
         lc_segnam          TYPE edi_segnam VALUE 'E1EDKA1', " Name of SAP segment
         lc_parv_we         TYPE edi3035_a  VALUE 'WE'.      " Partner function (e.g. sold-to party, ship-to party, ...)

*** Variables
  DATA :
          lv_obj          TYPE borident,                     " Object Relationship Service: BOR object identifier
          li_link         TYPE STANDARD TABLE OF relgraphlk, " Object Relationship: Link of Network for Links
          li_edidd        TYPE STANDARD TABLE OF edidd,      " Data Record
          lv_docnum       TYPE edi_docnum,                   " Document Number

          lwa_link        TYPE relgraphlk,                   " Object Relationship: Link of Network for Links
          lwa_e1edka1     TYPE e1edka1,                      " IDoc: Document Header Partner Information
          lv_belnr       TYPE vbeln_vf.                      " Billing Document

*** Field Sysmbols
  FIELD-SYMBOLS:
                 <lfs_edidd> TYPE edidd. " Data Record

***
  lv_belnr = im_belnr.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT' " Conversion to internal required format
    EXPORTING
      input  = lv_belnr
    IMPORTING
      output = lv_belnr.

***
  lv_obj-objkey = lv_belnr.
  lv_obj-objtype = lc_obj_ty.

*** FM to get Idoc number from sales order
  CALL FUNCTION 'SREL_GET_NEXT_RELATIONS'
    EXPORTING
      object         = lv_obj
      relationtype   = lc_rel_ty
    TABLES
      links          = li_link
    EXCEPTIONS
      internal_error = 1
      no_logsys      = 2
      OTHERS         = 3.
  IF sy-subrc = 0.
    READ TABLE li_link INTO lwa_link INDEX 1.
    IF sy-subrc EQ 0.
      lv_docnum = lwa_link-objkey_a.


*** Logic to fetch Vendor No.
      CALL FUNCTION 'IDOC_READ_COMPLETELY'
        EXPORTING
          document_number         = lv_docnum
        TABLES
          int_edidd               = li_edidd
        EXCEPTIONS
          document_not_exist      = 1
          document_number_invalid = 2
          OTHERS                  = 3.
      IF sy-subrc = 0.

        DELETE li_edidd WHERE segnam NE lc_segnam.
        LOOP AT li_edidd ASSIGNING <lfs_edidd>.
          lwa_e1edka1 = <lfs_edidd>-sdata.
          IF lwa_e1edka1-parvw NE lc_parv_we.
            CONTINUE.
          ELSE. " ELSE -> IF lwa_e1edka1-parvw NE lc_parv_we
            ex_lifnr = lwa_e1edka1-lifnr.
            EXIT.
          ENDIF. " IF lwa_e1edka1-parvw NE lc_parv_we
        ENDLOOP. " LOOP AT li_edidd ASSIGNING <lfs_edidd>

      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc = 0

  FREE : li_link, li_edidd. " Free table

ENDFUNCTION.
