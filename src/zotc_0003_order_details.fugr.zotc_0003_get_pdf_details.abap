FUNCTION ZOTC_0003_GET_PDF_DETAILS.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_VBELN) TYPE  VBELN
*"  EXPORTING
*"     VALUE(E_MESSAGE) TYPE  STRING
*"----------------------------------------------------------------------
***********************************************************************
*Program    : ZOTC_0003_GET_ORDER_pdf                                 *
*Title      : Get PDF from sales order                                *
*Developer  : Manoj Thatha                                            *
*Object type: Funtion Module                                          *
*SAP Release: SAP ECC 8.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_MDD_0003                                           *
*---------------------------------------------------------------------*
*Description: Get PDF from sales order                                *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*10-Sept-2019   MTHATHA      E2DK927306    Initial Development        *
*---------------------------------------------------------------------*
*--Data Declarations
data: go_myobject type ref to cl_gos_manager.
data: ls_object   type borident.

ls_object-OBJKEY = i_vbeln.
ls_object-OBJTYPE = 'BUS2032'.

create object go_myobject.

CALL METHOD GO_MYOBJECT->START_SERVICE_DIRECT
  EXPORTING
    IP_SERVICE         = 'VIEW_ATTA'
    IS_OBJECT          = ls_object
  EXCEPTIONS
    NO_OBJECT          = 1
    OBJECT_INVALID     = 2
    EXECUTION_FAILED   = 3
    others             = 4.
IF SY-SUBRC <> 0.
E_MESSAGE = 'Attachment is not Available'.
ENDIF.



ENDFUNCTION.
