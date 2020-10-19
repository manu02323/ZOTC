class Z01OTC_CL_SI_EDPAR_IN definition
  public
  create public .

public section.

  interfaces Z01OTC_II_SI_EDPAR_IN .
protected section.
private section.
ENDCLASS.



CLASS Z01OTC_CL_SI_EDPAR_IN IMPLEMENTATION.


METHOD z01otc_ii_si_edpar_in~si_edpar_in.
*&---------------------------------------------------------------------*
*& method z01otc_ii_si_edpar_in~si_edpar_in.
*&---------------------------------------------------------------------*
***********************************************************************
*Program    : z01otc_ii_si_edpar_in~si_edpar_in(It is a proxy method) *
*Title      : Read EDI Partner from EDPAR                             *
*Developer  : Mini Duggal                                             *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0128_Read EDI Partner from EDPAR               *
*---------------------------------------------------------------------*
*Description: The following method will return the sold-to-customer,
*partner function,ext.partner no. and ship-to-customer from EDPAR table
*based on the given ext.partner no. and partner function              *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*19-May-2014    MDUGGAL           E2DK900444      INITIAL DEVELOPMENT
*---------------------------------------------------------------------*

**--------------------------------------------------------------*
*** **** INSERT IMPLEMENTATION HERE **** ***

*---------------------local types declaration-------------------*
  TYPES:
* for data fetching from EDPAR table
          BEGIN OF lty_partner,
           sold_to_customer TYPE kunnr,     " Customer Number
           partner_role     TYPE parvw,     "Partner Function
           external_partner TYPE edi_expnr, "External partner number
           ship_to_customer TYPE edi_inpnr, "Internal partner number
          END OF lty_partner,
* table type for data fetching EDPAR table
          lty_t_partner TYPE STANDARD TABLE OF lty_partner,
* for partner type format conversion
          BEGIN OF lty_ptype,
           ext_ptype TYPE parvw, "Partner Function
           int_ptype TYPE parvw, "Partner Function
          END OF lty_ptype,
* table type for partner type format conversion
          lty_t_ptype TYPE STANDARD TABLE OF lty_ptype.

*--------------------local constant declaration------------------*
  CONSTANTS:lc_severity TYPE string VALUE 'ERROR'. "constant to hold the type of message

*--------------------local data declaration----------------------*
  DATA:
        lv_msg            TYPE string, "variable to hold the error message
        lwa_details_res   TYPE z01otc_dt_edpar_res_details, "request detail work area
        lwa_mt_edpar_req  TYPE z01otc_dt_edpar_req, " request data
        lwa_mt_edpar_res  TYPE z01otc_dt_edpar_res, "response data
        lwa_partner       TYPE lty_partner,         "to store sold to cust., partner function,
*                                                               ext. partner no and ship to cust
        li_partner        TYPE lty_t_partner, "to store sold to cust., partner function,
*                                             ext. partner no and ship to cust
        li_partner_input  TYPE lty_t_partner,             "input partner
        li_ptype          TYPE SORTED TABLE OF lty_ptype  "internal table to store the partner role
                          WITH UNIQUE KEY ext_ptype,

        lv_int_ptype      TYPE parvw,                     "Partner role
        lwa_standard_err  TYPE z01otcexchange_fault_data, "error data
        lwa_log_data      TYPE z01otcexchange_log_data,   "error log data
        lv_line           TYPE REF TO data.               "class

  FIELD-SYMBOLS:
                 <lfs_details>       TYPE z01otc_dt_edpar_req_details, "proxy req detail
                 <lfs_ptype>         TYPE lty_ptype,                   "to hold ext. and int. partner type
                 <lfs_partner_input> TYPE lty_partner,                 "to hold ext. partner no. and partner function
                 <lfs_partner>       TYPE lty_partner.                 "to hold ext. partner no. and partner function
*-----------------------------------------------------------------*
*exporting parameters needs to be initialized if they are passed
*by reference
  CLEAR:output.

*assigning the values so as to get the final details i.e partner function
*and external partner number
  lwa_mt_edpar_req = input-mt_edpar_req.

  LOOP AT lwa_mt_edpar_req-details ASSIGNING <lfs_details>.
    CLEAR lv_int_ptype.
* check if partner type has already been converted
* LI_PTYPE is a sorted table type so no sort required before binary search
    READ TABLE li_ptype ASSIGNING <lfs_ptype>
                        WITH KEY ext_ptype = <lfs_details>-partner_role
                        BINARY SEARCH.

    IF sy-subrc = 0 AND <lfs_ptype> IS ASSIGNED.
      lv_int_ptype = <lfs_ptype>-int_ptype.
    ELSE. " ELSE -> IF sy-subrc = 0 AND <lfs_ptype> IS ASSIGNED

*to convert the data into SAP input format
* As fieldsymbol is to be used, assign a memory first.

      CREATE DATA lv_line LIKE LINE OF li_ptype.
      ASSIGN lv_line->* TO <lfs_ptype>.

      <lfs_ptype>-ext_ptype = <lfs_details>-partner_role.

      CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
        EXPORTING
          input  = <lfs_details>-partner_role
        IMPORTING
          output = lv_int_ptype.

      <lfs_ptype>-int_ptype = lv_int_ptype.

      INSERT <lfs_ptype> INTO TABLE li_ptype.



    ENDIF. " IF sy-subrc = 0 AND <lfs_ptype> IS ASSIGNED
* update the conversion IT
    lwa_partner-partner_role     =  lv_int_ptype.
    lwa_partner-external_partner = <lfs_details>-external_partner.
    APPEND lwa_partner TO li_partner_input.
    CLEAR lwa_partner.

  ENDLOOP. " LOOP AT lwa_mt_edpar_req-details ASSIGNING <lfs_details>

  CHECK li_partner_input IS NOT INITIAL.
*to fetch the Customer Number and Internal partner number

  SORT li_partner_input BY external_partner partner_role.
  DELETE ADJACENT DUPLICATES FROM li_partner_input COMPARING external_partner
                                                             partner_role.

  SELECT kunnr "Customer Number
         parvw "Partner Function
         expnr "External partner number
         inpnr "Internal partner number
  FROM   edpar "Convert External <  > Internal Partner Number
  INTO  TABLE li_partner
  FOR ALL ENTRIES IN li_partner_input
  WHERE parvw = li_partner_input-partner_role
  AND   expnr = li_partner_input-external_partner.


  IF sy-subrc = 0.
    SORT li_partner BY external_partner partner_role.
  ENDIF. " IF sy-subrc = 0
*if entry not found for given ext. partner no. and partner role in
*edpar table , then raise exception otherwise return the entries found
*to the calling system

  LOOP AT lwa_mt_edpar_req-details ASSIGNING <lfs_details>.
* LI_PTYPE is a sorted table type so no sort required before binary search
* convert the ext to internal format before read
    READ TABLE li_ptype ASSIGNING <lfs_ptype>
                 WITH KEY ext_ptype = <lfs_details>-partner_role
                 BINARY SEARCH.
    CHECK sy-subrc = 0 AND <lfs_ptype> IS ASSIGNED.

* Need to convert partner type based on SAP format
    READ TABLE li_partner_input ASSIGNING <lfs_partner_input> WITH KEY
                           external_partner = <lfs_details>-external_partner
                           partner_role     = <lfs_ptype>-int_ptype
                           BINARY SEARCH.
    CHECK sy-subrc = 0 AND <lfs_partner_input> IS ASSIGNED.

    READ TABLE li_partner ASSIGNING <lfs_partner> WITH KEY
                   external_partner = <lfs_partner_input>-external_partner
                   partner_role     = <lfs_partner_input>-partner_role
                   BINARY SEARCH.
    IF sy-subrc NE 0.

*No record found for external partner & partner role &
      MESSAGE s137(zotc_msg) WITH <lfs_details>-external_partner " No record found for external partner & partner role &
                                  <lfs_details>-partner_role INTO lv_msg.
      lwa_log_data-text     = lv_msg.
      lwa_log_data-severity = lc_severity.

      APPEND lwa_log_data TO lwa_standard_err-fault_detail.

      RAISE EXCEPTION TYPE z01otccx_fmt_edpar
        EXPORTING
          standard = lwa_standard_err.

****if entry exists in edpar table for given ext.partner number and
****partner role, then send the data in the export parameter
    ELSE. " ELSE -> IF sy-subrc NE 0
      lwa_details_res-sold_to_customer = <lfs_partner>-sold_to_customer. "customer no.
* return the external partner type
      lwa_details_res-partner_role     = <lfs_ptype>-ext_ptype. "partner function
      lwa_details_res-external_partner = <lfs_partner>-external_partner. "ext.partner no.
      lwa_details_res-ship_to_customer = <lfs_partner>-ship_to_customer. "ship to customer
      APPEND lwa_details_res TO lwa_mt_edpar_res-details.
      CLEAR: lwa_details_res.

    ENDIF. " IF sy-subrc NE 0

  ENDLOOP. " LOOP AT lwa_mt_edpar_req-details ASSIGNING <lfs_details>

  IF lwa_mt_edpar_res-details[] IS NOT INITIAL.
    output-mt_edpar_res = lwa_mt_edpar_res.
  ENDIF. " IF lwa_mt_edpar_res-details[] IS NOT INITIAL

ENDMETHOD.
ENDCLASS.
