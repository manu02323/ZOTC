class ZCL_IM_OTC_DMEE_BADI_01 definition
  public
  final
  create public .

public section.

  interfaces IF_EX_DMEE_BADI_01 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_OTC_DMEE_BADI_01 IMPLEMENTATION.


METHOD if_ex_dmee_badi_01~modify_output_file.
************************************************************************
* PROGRAM    :  MODIFY_OUTPUT_FILE                                     *
* TITLE      :  D3_PTP_IDD_0192 Bank Payment Interface Citibank        *
* DEVELOPER  :  Yogesh P Singh                                         *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_PTP_IDD_0192                                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Bank Payment Interface Citibank                        *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 27.05.2016    YSINGH  E1DK918236   a check have been added to        *
*                                    control the activation/ deactivat-*
*                                    ion of overall code and not any   *
*                                    specific Org Level check.         *
*&---------------------------------------------------------------------*
* 06.15.2016    NGARG   E1DK918236  D3_OTC_IDD_0201: Add filter for   *
*                                    DMEE tree                         *
*&---------------------------------------------------------------------*

* The file is converted to 4110 (if codepage in OBPM3 is 4110), when
* unicode is not active. If unicode is active the file is converted
* by transfer command in write-function.

  DATA:  ls_output_tab  TYPE dmee_output_file,           " DMEE: Structure for Transferring Line Content
         conv           TYPE REF TO cl_abap_conv_x2x_ce, " Code Page and Endian Conversion Between External Formats
         in_encoding    TYPE abap_encoding,
         encoding       TYPE tcp00-cpcodepage,           " SAP Character Set ID
         cust_codepage TYPE cpcodepage,                  "codepage form customizing
         special_codep_requested TYPE boole-boole,       " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
         xstr           TYPE xstring,
         length         TYPE i,                          " Length of type Integers
         l_charset      TYPE string,
         ld_target      TYPE dfilesyst,                  " Filesystem (Temse, ...)
         ld_laufi       TYPE fpayh-laufi,                " Additional Identification
         lb_is_ficca    TYPE boole VALUE space.          " Boolean variable

  FIELD-SYMBOLS: <xptr>  TYPE x. " Field-symbols: <xptr> of type Byte fields
* Begin of change D3_PTP_IDD_0192 by YSINGH

  DATA: li_constants  TYPE STANDARD TABLE OF zdev_enh_status " Enhancement Status
                             INITIAL SIZE 0,
* Begin of Insert D3_OTC_IDD_0201 by NGARG
        li_enh_status  TYPE STANDARD TABLE OF zdev_enh_status " Enhancement Status
                             INITIAL SIZE 0.
* End of Insert D3_OTC_IDD_0201 by NGARG



  CONSTANTS : lc_enh_name       TYPE z_enhancement VALUE 'PTP_IDD_0192', " Enhancement No.
              lc_null           TYPE z_criteria    VALUE 'NULL',         " Constant table.
              lc_enh_0201       TYPE z_enhancement VALUE 'OTC_IDD_0201', " Enhancement No.
              lc_dmee_tree      TYPE z_criteria    VALUE 'DMEE_TREE'.    " Enh. Criteria

  CHECK i_tree_type EQ 'PAYM'.
*Begin of Insert D3_OTC_IDD_201 by NGARG
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_0201
    TABLES
      tt_enh_status     = li_enh_status.

  IF sy-subrc EQ 0 AND li_enh_status IS NOT INITIAL.

    DELETE li_enh_status WHERE active IS INITIAL.

    IF li_enh_status IS NOT INITIAL.

      READ TABLE  li_enh_status WITH KEY
      criteria = lc_null
      TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
        READ TABLE li_enh_status
        WITH KEY criteria = lc_dmee_tree
        sel_low = flt_val
        TRANSPORTING NO FIELDS.

        IF sy-subrc EQ 0.

* End of Insert D3_OTC_IDD_0201 by NGARG

* Check if payment run is FI or FI-CA and get
* target codepage from customizing
          CALL FUNCTION 'FI_PAYM_PARAMETERS_GET'
            IMPORTING
              e_laufi            = ld_laufi
              e_xdme_file_system = ld_target.

          IF ld_laufi IS INITIAL.
* msut be FI-CA Payment run, parameters not available
            DATA g_function TYPE rs38l_fnam. " Name of Function Module
            lb_is_ficca = 'X'.
            g_function = 'FKK_DME_FDTA_CODEPAGE_GET'.
            CALL FUNCTION 'FUNCTION_EXISTS'
              EXPORTING
                funcname           = g_function
              EXCEPTIONS
                function_not_exist = 1.
            IF sy-subrc = 0.
              CALL FUNCTION g_function
                EXPORTING
                  i_formi    = flt_val
                IMPORTING
                  e_codepage = cust_codepage
                EXCEPTIONS
                  OTHERS     = 1.
            ELSE. " ELSE -> IF sy-subrc = 0
*     FI-CA customizing for codepage starting in release 6.0
*     so we assume 4110
              cust_codepage = '4110'.
            ENDIF. " IF sy-subrc = 0
          ELSE. " ELSE -> IF ld_laufi IS INITIAL
* adjust encoding section in xml according to codepage in OBPM3
            CALL FUNCTION 'FI_PAYM_FORMAT_READ_CODEPAGE'
              EXPORTING
                i_formi    = flt_val
              IMPORTING
                e_codepage = cust_codepage
              EXCEPTIONS
                not_found  = 4.
          ENDIF. " IF ld_laufi IS INITIAL

          IF cust_codepage = '0000' AND cl_abap_char_utilities=>charsize > 1.
            cust_codepage = '4110'.
          ENDIF. " IF cust_codepage = '0000' AND cl_abap_char_utilities=>charsize > 1
          IF cust_codepage = '4120'. " pure UTF-8
            cust_codepage = '4110'.
          ENDIF. " IF cust_codepage = '4120'

          IF cust_codepage = '0000' AND cl_abap_char_utilities=>charsize = 1.
* no conversion and no replacement, customer must enter value in OBPM3
            EXIT.
          ENDIF. " IF cust_codepage = '0000' AND cl_abap_char_utilities=>charsize = 1

          IF cust_codepage = '4110'. " target codepage is UTF-8
            IF cl_abap_char_utilities=>charsize = 1. " non-Unicode system
              READ TABLE c_output_tab INTO ls_output_tab INDEX 1.
              DATA off TYPE i. DATA start_pos TYPE i.
              FIND '"iso-8859-' IN ls_output_tab-line MATCH OFFSET start_pos IGNORING CASE.
              off = start_pos + 11.
              IF ls_output_tab-line+off(1) CA '0123456789'.
                REPLACE SECTION OFFSET start_pos LENGTH 12  OF ls_output_tab-line  WITH
                          '"UTF-8' IN CHARACTER MODE.
                ls_output_tab-length = ls_output_tab-length - 6.
              ELSE. " ELSE -> IF ls_output_tab-line+off(1) CA '0123456789'
                REPLACE SECTION OFFSET start_pos LENGTH 11 OF ls_output_tab-line  WITH
                          '"UTF-8' IN CHARACTER MODE.
                ls_output_tab-length = ls_output_tab-length - 5.
              ENDIF. " IF ls_output_tab-line+off(1) CA '0123456789'
              MODIFY c_output_tab FROM ls_output_tab INDEX 1.
            ELSE. " ELSE -> IF cl_abap_char_utilities=>charsize = 1
*   unicode is active, replace utf-16 with utf-8
              READ TABLE c_output_tab INTO ls_output_tab INDEX 1.
              REPLACE '"UTF-16"' IN ls_output_tab-line WITH
                      '"UTF-8"' IGNORING CASE.
              ls_output_tab-length = ls_output_tab-length - 1.
              MODIFY c_output_tab FROM ls_output_tab INDEX 1.
            ENDIF. " IF cl_abap_char_utilities=>charsize = 1
          ENDIF. " IF cust_codepage = '4110'

          IF NOT ( cust_codepage = '4110' OR cust_codepage = '4102'
                                          OR cust_codepage = '4103' ).
            special_codep_requested = 'X'.
          ENDIF. " IF NOT ( cust_codepage = '4110' OR cust_codepage = '4102'

          IF cl_abap_char_utilities=>charsize > 1 AND special_codep_requested = 'X'.
*   unicode is active
*   converion of file is done via open statement, but we have to adjust the
*   encoding section
            CALL FUNCTION 'SCP_GET_HTTP_NAME'
              EXPORTING
                sap_codepage     = cust_codepage
              IMPORTING
                name             = l_charset
              EXCEPTIONS
                name_unknown     = 1
                invalid_codepage = 2
                OTHERS           = 3.
            IF sy-subrc = 0.
              READ TABLE c_output_tab INTO ls_output_tab INDEX 1.
              REPLACE 'UTF-16' IN ls_output_tab-line WITH
                      l_charset IGNORING CASE.
              DATA l TYPE i. " Data l of type Integers
              l = strlen( l_charset ).
              l = l - 6.
              ls_output_tab-length = ls_output_tab-length + l.
              MODIFY c_output_tab FROM ls_output_tab INDEX 1.
            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF cl_abap_char_utilities=>charsize > 1 AND special_codep_requested = 'X'

* remove byte order mark BOM
          IF cl_abap_char_utilities=>charsize > 1
            AND NOT ( cust_codepage = '4102' OR cust_codepage = '4103' ).
            READ TABLE c_output_tab INTO ls_output_tab INDEX 1.
            WHILE ls_output_tab-line(1) <> '<'.
              SHIFT ls_output_tab-line BY 1 PLACES LEFT IN CHARACTER MODE.
              ls_output_tab-length = ls_output_tab-length - 1.
            ENDWHILE.
            MODIFY c_output_tab FROM ls_output_tab INDEX 1.
          ENDIF. " IF cl_abap_char_utilities=>charsize > 1

          CHECK cl_abap_char_utilities=>charsize = 1 AND cust_codepage = '4110'.

* non Unicode System, but file has to be in Unicode, target is filesystem
          IF lb_is_ficca = 'X'.
* FI-CA payment run, we need the target (filesystem or temse)
            g_function = 'FKK_PAYM_PARAMETERS_GET'.
            CALL FUNCTION 'FUNCTION_EXISTS'
              EXPORTING
                funcname           = g_function
              EXCEPTIONS
                function_not_exist = 1.
            IF sy-subrc = 0.
              DATA lb_fica_filesystem TYPE boole VALUE space. " Boolean variable
              CALL FUNCTION g_function
                IMPORTING
                  e_xdme_file_system = lb_fica_filesystem
                EXCEPTIONS
                  OTHERS             = 1.
            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF lb_is_ficca = 'X'

          IF ld_target = '2' OR NOT lb_fica_filesystem IS INITIAL.
*   get current codepage
            CALL FUNCTION 'SCP_GET_CODEPAGE_NUMBER'
              IMPORTING
                appl_codepage = encoding.
            in_encoding = encoding.

            LOOP AT c_output_tab INTO ls_output_tab.
              length = ls_output_tab-length.
              IF length > 0.
                ASSIGN ls_output_tab-line(length) TO <xptr> CASTING.
                xstr = <xptr>.
                TRY.
                    conv = cl_abap_conv_x2x_ce=>create(
                         in_encoding  = in_encoding
                         out_encoding = '4110'
                         input = xstr ).
                  CATCH cx_sy_codepage_converter_init.
                    MESSAGE a218(fz) WITH in_encoding '4110'. " The conversion of code page & to code page & is not supported
                ENDTRY.
                TRY.
                    CALL METHOD conv->convert_c( EXPORTING n = length ).
                  CATCH cx_sy_codepage_converter_init.
                    MESSAGE a218(fz) WITH in_encoding '4110'. " The conversion of code page & to code page & is not supported
                  CATCH cx_sy_conversion_codepage.
                ENDTRY.
                xstr = conv->get_out_buffer( ).
                length = xstrlen( xstr ).
*         set new length
                ls_output_tab-length = length.
                ASSIGN ls_output_tab-line(length) TO <xptr> CASTING.
                <xptr> = xstr.
                MODIFY c_output_tab FROM ls_output_tab.
              ENDIF. " IF length > 0
            ENDLOOP. " LOOP AT c_output_tab INTO ls_output_tab
          ENDIF. " IF ld_target = '2' OR NOT lb_fica_filesystem IS INITIAL
        ENDIF. " IF sy-subrc EQ 0
*Begin of Insert D3_OTC_IDD_201 by NGARG

      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " if li_enh_status is NOT INITIAL
  ENDIF. " IF sy-subrc EQ 0 AND li_enh_status IS NOT INITIAL
*End of Insert D3_OTC_IDD_201 by NGARG

ENDMETHOD.
ENDCLASS.
