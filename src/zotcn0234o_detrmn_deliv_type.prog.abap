************************************************************************
* PROGRAM    :  ZOTCN0234O_DETRMN_DELIV_TYPE                           *
* TITLE      :  D2_OTC_EDD_0234 Determine Delivery type                *
* DEVELOPER  :  Rajendra Panigrahy                                     *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  D2_OTC_EDD_0234                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:                                                         *
* Determine Delivery type                                              *
*                                                                      *
* This BAdi is implemented to Determine Delivery type for              *
* Export Delivery                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER    TRANSPORT  DESCRIPTION                          *
* ============ ======= ========== =====================================*
* 25-AUG-2014  RPANIGR E2DK904272 Initial Development                  *
* Determine Delivery type                                              *
*                                                                      *
* This BAdi is implemented to Determine Delivery type for              *
* Export Delivery                                                      *
* 12-Sep-2104 RPANIGR E2DK904272 Changes done for adding Order type    *
* Check and replace delivery type only if it was ZLF type              *
*&---------------------------------------------------------------------*
*&09-Jun-2016 RBANERJ1 E1DK918436  D3_OTC_EDD_0234 -Determine Delivery *
*                                  type                                *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           ZPTPN0234O_DETRMN_DELIV_TYPE
*&---------------------------------------------------------------------*

************************************************************************
*Begin of change for D3_OTC_EDD_0234 by RBANERJ1
*===========================Type Declaration===========================*
 TYPES:BEGIN OF lty_kna1,
        kunnr TYPE kunnr,    " Customer Number
        land1 TYPE land1_gp, " Country Key
        lzone TYPE lzone,    " Transportation zone to or from which the goods are delivered
       END OF lty_kna1.
*End of change for D3_OTC_EDD_0234 by RBANERJ1
*===========================Data Declaration===========================*
************************************************************************

* Constants declaration
 CONSTANTS: lc_enh_no     TYPE z_enhancement VALUE 'D2_OTC_EDD_0234', " Enhancement No.
            lc_lfart      TYPE z_criteria    VALUE 'LFART',           " Enh. Criteria
            lc_null       TYPE z_criteria    VALUE 'NULL',            " Enh. Criteria
            lc_trans_crt  TYPE trtyp         VALUE 'H',               " Transaction typ
            lc_msg_typ    TYPE symsgty       VALUE 'W',               " Message Type
            lc_msg_id     TYPE symsgid       VALUE 'ZOTC_MSG',        " Message Class
            lc_msg_num    TYPE symsgno       VALUE '160',             " Message Number
*---> Begin of Change for D2_OTC_EDD_0234/12-Sep-14 by RPANIGR
            lc_lfart_bef  TYPE z_criteria    VALUE 'LFART_BEF',      " Enh. Criteria
            lc_auart      TYPE z_criteria    VALUE 'AUART',          " Enh. Criteria
            lc_soitem_rec TYPE char20        VALUE '(SAPFV50K)LIPS', " FOR SO Item data read
*---< End of Change for D2_OTC_EDD_0234/12-Sep-14 by RPANIGR
*Begin of change for D3_OTC_EDD_0234 by RBANERJ1
            lc_separator        TYPE xfeld         VALUE '.'              , " Checkbox
            lc_name_appl        TYPE string        VALUE 'ZA_OTC_EDD_0234_EHQ_DET',
            lc_name_func        TYPE string        VALUE 'ZF_OTC_EDD_0234_EHQ_DET',
            lc_vstel            TYPE char10        VALUE 'VSTEL',      " Shpping Point
            lc_kunag_ctry       TYPE char10        VALUE 'KUNAG_CTRY', " Ship to country
            lc_lzone            TYPE char10        VALUE 'LZONE'.      " Transportaion Zone
*End of change for D3_OTC_EDD_0234 by RBANERJ1

* Field Symbol Declaration
 FIELD-SYMBOLS: <lfs_enh_status> TYPE zdev_enh_status, " Enhancement Status

                <lfs_soitem>     TYPE lips.            " SD document: Delivery: Item data

* Data Declaration
 DATA: li_enh_status TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Enhancement Status
       lwa_error_log TYPE shp_badi_error_log.                               " Messages from BAdI Processing Delivery

 DATA: lv_lfart        TYPE lfart,    " General Flag
       lv_export_lfart TYPE lfart,    " Delivery Type
       lv_vstel        TYPE vstel,    " Shipping Point/Receiving Point
       lv_vstel_adrnr  TYPE adrnr,    " Address
       lv_vstel_cntry  TYPE land1,    " Country Key
       lv_kunnr        TYPE kunwe,    " Ship-to party
       lv_kunnr_cntry  TYPE land1_gp, " Country Key
       lv_export_delv  TYPE flag,     " General Flag
*---> Begin of Change for D2_OTC_EDD_0234/12-Sep-14 by RPANIGR
       lv_lfart_bef    TYPE lfart, " Delivery Type
       lv_auart        TYPE auart, " Sales Document Type
       lv_auart_emi    TYPE auart, " Sales Document Type
*---< End of Change for D2_OTC_EDD_0234/12-Sep-14 by RPANIGR
*Begin of change for D3_OTC_EDD_0234 by RBANERJ1
       lv_lfart_brf    TYPE lfart,                          " Delivery Type
       lv_query_in     TYPE string,
       lv_query_out    TYPE if_fdt_types=>id,
       lwa_kna1        TYPE lty_kna1,
       lref_utility    TYPE REF TO /bofu/cl_fdt_util, " BRFplus Utilities
       lref_admin_data TYPE REF TO if_fdt_admin_data, " FDT: Administrative Data
       lref_function   TYPE REF TO if_fdt_function,   " FDT: Function
       lref_context    TYPE REF TO if_fdt_context,    " FDT: Context
       lref_result     TYPE REF TO if_fdt_result,     " FDT: Result
       lref_fdt        TYPE REF TO cx_fdt.            "#EC NEEDED   FDT: Abstract Exception Class
*End of change for D3_OTC_EDD_0234 by RBANERJ1

************************************************************************
*==========================Processing Logic============================*
************************************************************************

* Call FM to retrieve Enhancement Status
 CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
   EXPORTING
     iv_enhancement_no = lc_enh_no
   TABLES
     tt_enh_status     = li_enh_status.

* Delete the EMI records where the status is not active
 DELETE li_enh_status WHERE active = space.

* Check whether this Enhancement is Active
 IF li_enh_status IS NOT INITIAL.

   READ TABLE li_enh_status ASSIGNING <lfs_enh_status>
                         WITH KEY criteria = lc_null.
   IF sy-subrc = 0.

* If the transaction is used for delivery creation
     IF if_trtyp = lc_trans_crt.
*Begin of change for D3_OTC_EDD_0234 by RBANERJ1

* Ship to party of the delivery
         lv_kunnr = cs_likp-kunnr.

* Getting the country key for the ship to party
         IF lv_kunnr IS NOT INITIAL.
           SELECT SINGLE kunnr " Customer Number
                         land1 " Country Key
                         lzone " Transportation zone to or from which the goods are delivered
                  FROM kna1    " General Data in Customer Master
                  INTO lwa_kna1
                  WHERE kunnr = lv_kunnr.
           IF sy-subrc = 0.    "#EC NEEDED
* Do Nothing
           ENDIF. " IF sy-subrc = 0
         ENDIF. " IF lv_kunnr IS NOT INITIAL

         CLEAR: lref_utility,
                lv_query_in,
                lv_query_out.
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

*--Set the context for value comparison
             lref_context->set_value( iv_name = lc_vstel       ia_value = cs_likp-vstel ).
             lref_context->set_value( iv_name = lc_kunag_ctry  ia_value = lwa_kna1-land1 ).
             lref_context->set_value( iv_name = lc_lzone       ia_value = lwa_kna1-lzone ).
             TRY.
                 lref_function->process( EXPORTING io_context = lref_context
                                         IMPORTING eo_result  = lref_result ).

                 lref_result->get_value( IMPORTING ea_value = lv_lfart_brf ).

               CATCH cx_fdt INTO lref_fdt.
                 CLEAR lv_lfart_brf.
             ENDTRY.


           ENDIF. " IF sy-subrc IS INITIAL
         ENDIF. " IF lref_utility IS BOUND


       IF lv_lfart_brf IS INITIAL.
*End of change for D3_OTC_EDD_0234 by RBANERJ1
* Shipping point of the delivery
         lv_vstel = cs_likp-vstel.

* Getting the country key for the shipping point
         IF lv_vstel IS NOT INITIAL.
           SELECT SINGLE adrnr " Address
                  FROM tvst    " Organizational Unit: Shipping Points
                  INTO lv_vstel_adrnr
                  WHERE vstel = lv_vstel.

           IF sy-subrc = 0.
             SELECT country   " Country Key
                    FROM adrc " Addresses (Business Address Services)
                    INTO lv_vstel_cntry
                    UP TO 1 ROWS
                    WHERE addrnumber = lv_vstel_adrnr
                    AND   date_from <= sy-datum
                    AND   date_to >= sy-datum.
             ENDSELECT.
             IF sy-subrc = 0.
* Do Nothing
             ENDIF. " IF sy-subrc = 0
           ENDIF. " IF sy-subrc = 0
         ENDIF. " IF lv_vstel IS NOT INITIAL

* Ship to party of the delivery
         lv_kunnr = cs_likp-kunnr.

* Getting the country key for the ship to party
         IF lv_kunnr IS NOT INITIAL.
           SELECT SINGLE land1 " Country Key
                  FROM kna1    " General Data in Customer Master
                  INTO lv_kunnr_cntry
                  WHERE kunnr = lv_kunnr.
           IF sy-subrc = 0.
* Do Nothing
           ENDIF. " IF sy-subrc = 0
         ENDIF. " IF lv_kunnr IS NOT INITIAL

* If country of the shipping point and country of ship to party are not equal...
* ...then set a flag determining this is an export delivery
         IF lv_vstel_cntry <> lv_kunnr_cntry.
           lv_export_delv = abap_true.
         ENDIF. " IF lv_vstel_cntry <> lv_kunnr_cntry
*Begin of change for D3_OTC_EDD_0234 by RBANERJ1
       ENDIF. " IF lv_lfart_brf IS INITIAL
*End of change for D3_OTC_EDD_0234 by RBANERJ1
     ENDIF. " IF if_trtyp = lc_trans_crt
   ENDIF. " IF sy-subrc = 0
 ENDIF. " IF li_enh_status IS NOT INITIAL
*Begin of change for D3_OTC_EDD_0234 by RBANERJ1
   IF lv_lfart_brf IS NOT INITIAL.
     ASSIGN (lc_soitem_rec) TO <lfs_soitem>.
     IF <lfs_soitem> IS ASSIGNED.
       SELECT SINGLE auart " Sales Document Type
                FROM vbak  " Sales Document: Header Data
                INTO lv_auart
               WHERE vbeln = <lfs_soitem>-vgbel.
       IF sy-subrc = 0.
* Then read the order type for which delivery is created
         READ TABLE li_enh_status TRANSPORTING NO FIELDS
                                  WITH KEY criteria = lc_auart sel_low = lv_auart.
         IF sy-subrc = 0.


* Read TVLK to check, the delivery type stored in EMI tool is existing in the system
           SELECT SINGLE lfart " Delivery Type
                  FROM tvlk    " Delivery Types
                  INTO lv_lfart
                  WHERE lfart = lv_lfart_brf.

* If delivery type found in system then replace with the same...
* ...else populate the log table with the message 'Delivery type & Not found'
           IF sy-subrc = 0.
             cs_likp-lfart = lv_lfart_brf.
           ELSE. " ELSE -> IF sy-subrc = 0
             lwa_error_log-msgty = lc_msg_typ.
             lwa_error_log-msgid = lc_msg_id.
             lwa_error_log-msgno = lc_msg_num.
             lwa_error_log-msgv1 = lv_lfart_brf.
             APPEND lwa_error_log TO ct_log.
           ENDIF. " IF sy-subrc = 0

         ENDIF. " IF sy-subrc = 0
       ENDIF. " IF sy-subrc = 0
     ENDIF. " IF <lfs_soitem> IS ASSIGNED
   ENDIF. " IF lv_lfart_brf is not INITIAL

*End of change for D3_OTC_EDD_0234 by RBANERJ1
* If delivery is an export delivery
 IF lv_export_delv = abap_true.
*---> Begin of Change for D2_OTC_EDD_0234/12-Sep-14 by RPANIGR

* Then read the delivery type is ZLF only which is to be replaced with ZLE delivery type
   READ TABLE li_enh_status ASSIGNING <lfs_enh_status>
                            WITH KEY criteria = lc_lfart_bef.
   IF sy-subrc = 0.
     lv_lfart_bef = <lfs_enh_status>-sel_low+0(4).
     UNASSIGN :<lfs_enh_status>.

* If the incoming delivery type is ZLF
     IF cs_likp-lfart = lv_lfart_bef.

       ASSIGN (lc_soitem_rec) TO <lfs_soitem>.
       IF <lfs_soitem> IS ASSIGNED.
* Get the order type of the order for which the delivery is created
         SELECT SINGLE auart " Sales Document Type
                FROM vbak    " Sales Document: Header Data
                INTO lv_auart
                WHERE vbeln = <lfs_soitem>-vgbel.
         IF sy-subrc = 0.
*---< End of Change for D2_OTC_EDD_0234/12-Sep-14 by RPANIGR

* Then read the order type for which delivery is created is ZOR or ZTD only
           READ TABLE li_enh_status TRANSPORTING NO FIELDS
                                    WITH KEY criteria = lc_auart sel_low = lv_auart.
           IF sy-subrc = 0.

* Then get the delivery type from EMI tool
             READ TABLE li_enh_status ASSIGNING <lfs_enh_status>
                                      WITH KEY criteria = lc_lfart.
             IF sy-subrc = 0.
               lv_export_lfart = <lfs_enh_status>-sel_low+0(4).

* Read TVLK to check, the delivery type stored in EMI tool is existing in the system
               SELECT SINGLE lfart " Delivery Type
                      FROM tvlk    " Delivery Types
                      INTO lv_lfart
                      WHERE lfart = lv_export_lfart.

* If delivery type found in system then replace with the same...
* ...else populate the log table with the message 'Delivery type & Not found'
               IF sy-subrc = 0.
                 cs_likp-lfart = lv_export_lfart.
               ELSE. " ELSE -> IF sy-subrc = 0
                 lwa_error_log-msgty = lc_msg_typ.
                 lwa_error_log-msgid = lc_msg_id.
                 lwa_error_log-msgno = lc_msg_num.
                 lwa_error_log-msgv1 = lv_export_lfart.
                 APPEND lwa_error_log TO ct_log.
               ENDIF. " IF sy-subrc = 0
             ENDIF. " IF sy-subrc = 0
           ENDIF. " IF sy-subrc = 0
         ENDIF. " IF sy-subrc = 0
       ENDIF. " IF <lfs_soitem> IS ASSIGNED
     ENDIF. " IF cs_likp-lfart = lv_lfart_bef
   ENDIF. " IF sy-subrc = 0
 ENDIF. " IF lv_export_delv = abap_true


* Clear variables in case there is some data while running...
* ...for collective order processing
 CLEAR: lv_vstel,
        lv_vstel_adrnr,
        lv_vstel_cntry,
        lv_kunnr,
        lv_kunnr_cntry,
        lv_export_delv,
        lv_lfart,

        lv_lfart_bef,
        lv_auart,
        lv_auart_emi.
*Begin of change for D3_OTC_EDD_0234 by RBANERJ1
 CLEAR: lv_lfart_brf , " Delivery Type
        lv_query_in ,
        lwa_kna1 .
*End of change for D3_OTC_EDD_0234 by RBANERJ1
