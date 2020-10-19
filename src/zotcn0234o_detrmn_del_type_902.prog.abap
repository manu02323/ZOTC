************************************************************************
* PROGRAM    :  ZOTCN0234O_DETRMN_DEL_TYPE_902                         *
* TITLE      :  D3_OTC_EDD_0234 Determine Delivery type                *
* DEVELOPER  :  Jayanta Ray                                            *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  D3_OTC_EDD_0234                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:                                                         *
* Determine Delivery type                                              *
* This include copied from include ZOTCN0234O_DETRMN_DELIV_TYPE to     *
* determine correct delivery type in VOFM routine                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER    TRANSPORT  DESCRIPTION                          *
* ============ ======= ========== =====================================*
*----------------------------------------------------------------------*
* 22-Dec-2016  U033867 E1DK918436 D3_OTC_EDD_0234-CR 306 Determine     *
*                                                        Delivery type *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           ZOTCN0234O_DETRMN_DEL_TYPE_902
*&---------------------------------------------------------------------*

*===========================Type Declaration===========================*
 TYPES:BEGIN OF lty_kna1,
        kunnr TYPE kunnr,    " Customer Number
        land1 TYPE land1_gp, " Country Key
        lzone TYPE lzone,    " Transportation zone to or from which the goods are delivered
       END OF lty_kna1.

*===========================Data Declaration===========================*

* Constants declaration
 CONSTANTS: lc_enh_no       TYPE z_enhancement VALUE 'D2_OTC_EDD_0234', " Enhancement No.
            lc_lfart        TYPE z_criteria    VALUE 'LFART',           " Enh. Criteria
            lc_null         TYPE z_criteria    VALUE 'NULL',            " Enh. Criteria
            lc_trans_crt    TYPE trtyp         VALUE 'H',               " Transaction typ
            lc_msg_typ      TYPE symsgty       VALUE 'W',               " Message Type
            lc_msg_id       TYPE symsgid       VALUE 'ZOTC_MSG',        " Message Class
            lc_msg_num      TYPE symsgno       VALUE '160',             " Message Number
            lc_lfart_bef    TYPE z_criteria    VALUE 'LFART_BEF',      " Enh. Criteria
            lc_auart        TYPE z_criteria    VALUE 'AUART',          " Enh. Criteria
            lc_soitem_rec   TYPE char20        VALUE '(SAPFV50K)LIPS', " FOR SO Item data read
            lc_separator    TYPE xfeld         VALUE '.'              , " Checkbox
            lc_name_appl    TYPE string        VALUE 'ZA_OTC_EDD_0234_EHQ_DET',
            lc_name_func    TYPE string        VALUE 'ZF_OTC_EDD_0234_EHQ_DET',
            lc_vstel        TYPE char10        VALUE 'VSTEL',      " Shpping Point
            lc_kunag_ctry   TYPE char10        VALUE 'KUNAG_CTRY', " Ship to country
            lc_lzone        TYPE char10        VALUE 'LZONE'.      " Transportaion Zone

* Field Symbol Declaration
 FIELD-SYMBOLS: <lfs_enh_status> TYPE zdev_enh_status, " Enhancement Status

                <lfs_soitem>     TYPE lips.            " SD document: Delivery: Item data

* Data Declaration
 DATA: li_enh_status TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Enhancement Status
       lwa_error_log TYPE shp_badi_error_log.                               " Messages from BAdI Processing Delivery

 DATA: lv_lfart        TYPE         lfart,             " General Flag
       lv_export_lfart TYPE         lfart,             " Delivery Type
       lv_vstel        TYPE         vstel,             " Shipping Point/Receiving Point
       lv_vstel_adrnr  TYPE         adrnr,             " Address
       lv_vstel_cntry  TYPE         land1,             " Country Key
       lv_kunnr        TYPE         kunwe,             " Ship-to party
       lv_kunnr_cntry  TYPE         land1_gp,          " Country Key
       lv_export_delv  TYPE         flag,              " General Flag
       lv_lfart_bef    TYPE         lfart,             " Delivery Type
       lv_auart        TYPE         auart,             " Sales Document Type
       lv_auart_emi    TYPE         auart,             " Sales Document Type
       lv_lfart_brf    TYPE         lfart,             " Delivery Type
       lv_query_in     TYPE         string,            " Query
       lv_query_out    TYPE         if_fdt_types=>id,  " Query
       lwa_kna1        TYPE         lty_kna1,          " Kna1
       lref_utility    TYPE REF TO  /bofu/cl_fdt_util, " BRFplus Utilities
       lref_admin_data TYPE REF TO  if_fdt_admin_data, " FDT: Administrative Data
       lref_function   TYPE REF TO  if_fdt_function,   " FDT: Function
       lref_context    TYPE REF TO  if_fdt_context,    " FDT: Context
       lref_result     TYPE REF TO  if_fdt_result,     " FDT: Result
       lref_fdt        TYPE REF TO  cx_fdt.            "#EC NEEDED   FDT: Abstract Exception Class

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
* ---> Begin of Delete for D3_OTC_EDD_0234 CR#306 by U033867
*     IF if_trtyp = lc_trans_crt.
* <--- End of Delete for D3_OTC_EDD_0234 CR#306 by U033867
* ---> Begin of Insert for D3_OTC_EDD_0234 CR#306 by U033867
     IF t180-trtyp = lc_trans_crt.
* <--- End of Insert for D3_OTC_EDD_0234 CR#306 by U033867
* Ship to party of the delivery
* ---> Begin of Delete for D3_OTC_EDD_0234 CR#306 by U033867
*       lv_kunnr = cs_likp-kunnr.
* <--- End of Delete for D3_OTC_EDD_0234 CR#306 by U033867
* ---> Begin of Insert for D3_OTC_EDD_0234 CR#306 by U033867
       lv_kunnr = likp-kunnr.
* <--- End of Insert for D3_OTC_EDD_0234 CR#306 by U033867
* Getting the country key for the ship to party
       IF lv_kunnr IS NOT INITIAL.
         SELECT SINGLE kunnr " Customer Number
                       land1 " Country Key
                       lzone " Transportation zone to or from which the goods are delivered
                FROM kna1    " General Data in Customer Master
                INTO lwa_kna1
                WHERE kunnr = lv_kunnr.
         IF sy-subrc = 0. "#EC NEEDED
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
* ---> Begin of Delete for D3_OTC_EDD_0234 CR#306 by U033867
*           lref_context->set_value( iv_name = lc_vstel       ia_value = cs_likp-vstel ).
* <--- End of Delete for D3_OTC_EDD_0234 CR#306 by U033867
* ---> Begin of Insert for D3_OTC_EDD_0234 CR#306 by U033867
           lref_context->set_value( iv_name = lc_vstel       ia_value = likp-vstel ).
* <--- End of Insert for D3_OTC_EDD_0234 CR#306 by U033867
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
* Shipping point of the delivery
* ---> Begin of Delete for D3_OTC_EDD_0234 CR#306 by U033867
*         lv_vstel = cs_likp-vstel.
* <--- End of Delete for D3_OTC_EDD_0234 CR#306 by U033867
* ---> Begin of Insert for D3_OTC_EDD_0234 CR#306 by U033867
         lv_vstel = likp-vstel.
* <--- End of Insert for D3_OTC_EDD_0234 CR#306 by U033867

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
* ---> Begin of Delete for D3_OTC_EDD_0234 CR#306 by U033867
*         lv_kunnr = cs_likp-kunnr.
* <--- End of Delete for D3_OTC_EDD_0234 CR#306 by U033867
* ---> Begin of Insert for D3_OTC_EDD_0234 CR#306 by U033867
         lv_kunnr = likp-kunnr.
* <--- End of Insert for D3_OTC_EDD_0234 CR#306 by U033867

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
       ENDIF. " IF lv_lfart_brf IS INITIAL
     ENDIF. " IF T180-TRTYP = lc_trans_crt
   ENDIF. " IF sy-subrc = 0
 ENDIF. " IF li_enh_status IS NOT INITIAL

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
           lv_lfarv = lv_lfart_brf.
         ELSE. " ELSE -> IF sy-subrc <> 0
* ---> Begin of Delete for D3_OTC_EDD_0234 CR#306 by U033867
*             lwa_error_log-msgty = lc_msg_typ.
*             lwa_error_log-msgid = lc_msg_id.
*             lwa_error_log-msgno = lc_msg_num.
*             lwa_error_log-msgv1 = lv_lfart_brf.
*             APPEND lwa_error_log TO ct_log.
* <--- End of Delete for D3_OTC_EDD_0234 CR#306 by U033867
* ---> Begin of Insert for D3_OTC_EDD_0234 CR#306 by U033867
           PERFORM message_handling IN PROGRAM (programmname)
                                              USING posnr_low
                                                    lc_msg_num
                                                    lc_msg_typ
                                                    lc_msg_id
                                                    lv_lfart_brf
                                                    space
                                                    space
                                                    space.
* <--- End of Insert for D3_OTC_EDD_0234 CR#306 by U033867
         ENDIF. " IF sy-subrc = 0

       ENDIF. " IF sy-subrc = 0
     ENDIF. " IF sy-subrc = 0
   ENDIF. " IF <lfs_soitem> IS ASSIGNED
 ENDIF. " IF lv_lfart_brf IS NOT INITIAL

* If delivery is an export delivery
 IF lv_export_delv = abap_true.
* Then read the delivery type is ZLF only which is to be replaced with ZLE delivery type
   READ TABLE li_enh_status ASSIGNING <lfs_enh_status>
                            WITH KEY criteria = lc_lfart_bef.
   IF sy-subrc = 0.
     lv_lfart_bef = <lfs_enh_status>-sel_low+0(4).
     UNASSIGN :<lfs_enh_status>.

* If the incoming delivery type is ZLF
     IF lv_lfarv = lv_lfart_bef.

       ASSIGN (lc_soitem_rec) TO <lfs_soitem>.
       IF <lfs_soitem> IS ASSIGNED.
* Get the order type of the order for which the delivery is created
         SELECT SINGLE auart " Sales Document Type
                FROM vbak    " Sales Document: Header Data
                INTO lv_auart
                WHERE vbeln = <lfs_soitem>-vgbel.
         IF sy-subrc = 0.

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
                 lv_lfarv = lv_export_lfart.
               ELSE. " ELSE -> IF sy-subrc <> 0
* ---> Begin of Delete for D3_OTC_EDD_0234 CR#306 by U033867
*                 lwa_error_log-msgty = lc_msg_typ.
*                 lwa_error_log-msgid = lc_msg_id.
*                 lwa_error_log-msgno = lc_msg_num.
*                 lwa_error_log-msgv1 = lv_export_lfart.
*                 APPEND lwa_error_log TO ct_log.
* <--- End of Delete for D3_OTC_EDD_0234 CR#306 by U033867
* ---> Begin of Insert for D3_OTC_EDD_0234 CR#306 by U033867
                 PERFORM message_handling IN PROGRAM (programmname)
                                                    USING posnr_low
                                                          lc_msg_num
                                                          lc_msg_typ
                                                          lc_msg_id
                                                          lv_export_lfart
                                                          space
                                                          space
                                                          space.
* <--- End of Insert for D3_OTC_EDD_0234 CR#306 by U033867
               ENDIF. " IF sy-subrc = 0
             ENDIF. " IF sy-subrc = 0
           ENDIF. " IF sy-subrc = 0
         ENDIF. " IF sy-subrc = 0
       ENDIF. " IF <lfs_soitem> IS ASSIGNED
     ENDIF. " IF lv_lfarv = lv_lfart_bef
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
        lv_auart_emi,
        lv_lfart_brf ,
        lv_query_in ,
        lwa_kna1 .
