FUNCTION zotc_get_announcement.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_CS_GRP) TYPE  CHAR10 OPTIONAL
*"  EXPORTING
*"     VALUE(EX_ANCEMENT_DATA) TYPE  STRING_VALUE
*"----------------------------------------------------------------------

***********************************************************************
*Program    : ZOTC_GET_ANNOUNCEMENT                                   *
*Title      : Get Order Details                                       *
*Developer  : ABdus Salam SK                                          *
*Object type: Funtion Module                                          *
*SAP Release: SAP ECC 8.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_MDD_0003                                           *
*---------------------------------------------------------------------*
*Description: Get CSR Announcement                                    *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*======================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ============================*
*10-Sept-2019   ASK         E2DK927306    Initial Developmentr
*----------------------------------------------------------------------*

  DATA:
    lref_utility    TYPE REF TO /bofu/cl_fdt_util, " BRFplus Utilities
    lref_admin_data TYPE REF TO if_fdt_admin_data, " FDT: Administrative Data
    lref_function   TYPE REF TO if_fdt_function,   " FDT: Function
    lref_context    TYPE REF TO if_fdt_context,    " FDT: Context
    lref_result     TYPE REF TO if_fdt_result,     " FDT: Result
    lref_fdt        TYPE REF TO cx_fdt,            " FDT: Abstract Exception Class   ##NEEDED
    lv_query_in     TYPE        string,
    lv_query_out    TYPE        if_fdt_types=>id.


  CONSTANTS:
    lc_separator TYPE xfeld     VALUE   '.'              , " Checkbox
    lc_name_appl TYPE string    VALUE   'ZOTC_MDD_0003_ORDER_DETAILS',
    lc_name_func TYPE string    VALUE   'ZOTC_F_ANNOUNCE_DATA'.


* Get BRF+ Data for Announcement

*-- Create an instance of BRFPlus Utility class
  lref_utility ?= /bofu/cl_fdt_util=>get_instance( ).

*-- Make BRF query by concatenation of BRF application name and BRF Function name
  CONCATENATE lc_name_appl lc_name_func
         INTO lv_query_in
         SEPARATED BY lc_separator.
*-- To get GUID of query string
  IF lref_utility IS BOUND.
    CALL METHOD lref_utility->convert_function_input
      EXPORTING
        iv_input  = lv_query_in
      IMPORTING
        ev_output = lv_query_out
      EXCEPTIONS
        failed    = 1
        OTHERS    = 2.
    IF sy-subrc IS INITIAL.
*-- Set the variable value(s)
      cl_fdt_factory=>get_instance_generic( EXPORTING iv_id = lv_query_out
                                            IMPORTING eo_instance = lref_admin_data ).
      lref_function ?= lref_admin_data.
      lref_context  ?= lref_function->get_process_context( ).

* Get the Announcement
      lref_context->set_value( iv_name = 'CUST_GRP'  ia_value = im_cs_grp ).
      TRY.
          lref_function->process( EXPORTING io_context = lref_context
                                  IMPORTING eo_result = lref_result ).
          lref_result->get_value( IMPORTING ea_value = ex_ancement_data ).

        CATCH cx_fdt INTO lref_fdt.                      ##no_handler
          CLEAR ex_ancement_data.
      ENDTRY.
    ENDIF.
  ENDIF.

ENDFUNCTION.
