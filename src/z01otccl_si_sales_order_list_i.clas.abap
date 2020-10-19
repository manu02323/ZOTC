class Z01OTCCL_SI_SALES_ORDER_LIST_I definition
  public
  create public .

public section.

  interfaces Z01OTCII_SI_SALES_ORDER_LIST_I .
protected section.
private section.
ENDCLASS.



CLASS Z01OTCCL_SI_SALES_ORDER_LIST_I IMPLEMENTATION.


METHOD z01otcii_si_sales_order_list_i~si_sales_order_list_in.
************************************************************************
* PROGRAM    :  Z01OTCII_SI_SALES_ORDER_LIST_I~SI_SALES_ORDER_LIST_IN  *
* TITLE      :  Interface for retrieving the order list from           *
*               Bio Rad SAP (ECC) based on the request from EVo        *
* DEVELOPER  :  AVIK PODDAR                                            *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D2_OTC_IDD_0091                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Population of Order List and Order Status               *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT  DESCRIPTION                        *
* ===========  ========  ========== ===================================*
* 16-MAY-2014  APODDAR   E2DK900460 Initial Development                *
* 27-JUN-2014  APODDAR   E2DK900460 D2_OTC_IDD_0091_CR01               *
* 15-AUG-2014  APODDAR   E2DK900460 D2_OTC_IDD_0091 Defect # 418       *
* 13-SEP-2014  APODDAR   E2DK900460 D2_OTC_IDD_0091 Defect # 482       *
* 13-SEP-2014  APODDAR   E2DK900460 D2_OTC_IDD_0091 CR D2_117          *
*                                   Multiple Sold To / Message Changes *
* 13-SEP-2014  APODDAR   E2DK906360 D2_OTC_IDD_0091 Defect # 916       *
* 27-JAN-2015  APODDAR   E2DK900460 D2_OTC_IDD_0091 Defect # 3210      *
* 29-APR-2015  MBAGDA    E2DK900460 D2_OTC_IDD_0091 Defect # 6270      *
*                                   Fix for performance issue          *
* 08-MAY-2015  APODDAR   E2DK900460 D2_OTC_IDD_0091 Defect # 6369      *
*                                   Get order list is not returning    *
*                                   result when queried with PO        *
*&---------------------------------------------------------------------*
**--------------Declaration of Types--------------**
  TYPES:  BEGIN OF lty_vbkd,
            vbeln TYPE vbeln,       " Sales and Distribution Document Number
            posnr TYPE posnr,       " Item number of the SD document
            bstkd TYPE bstkd,       " Customer purchase order number
          END OF lty_vbkd,

          BEGIN OF lty_vbak,
            vbeln TYPE vbeln_va,    " Sales Document
            erdat TYPE erdat,       " Date on Which Record Was Created
            kunnr TYPE kunag,       " Sold-to party
            dflag TYPE flag,        " General Flag
          END OF lty_vbak,

          BEGIN OF lty_mulref,
            zzdocref TYPE z_docref, " Legacy Doc Ref
            zzdoctyp TYPE z_doctyp, " Ref Doc type
            status   TYPE string,   " Status
           END OF lty_mulref,

** --- Begin of Changes CR D2_117 by Avik Poddar on Sept 13 2014
          BEGIN OF lty_mul_soldto,
            sales_ordr TYPE vbeln_va, " Sales Document
            sold_to_id TYPE kunnr,    " Customer Number
            status     TYPE string,   " Status
          END OF lty_mul_soldto.
** --- End of Changes CR D2_117 by Avik Poddar on Sept 13 2014

**-------Declaration for Internal Tables------------------**
  DATA : li_proxy_in       TYPE z01otcdt_order_list_req_sa_tab,          "Proxy Structure (generated)
         li_vbak           TYPE TABLE OF lty_vbak,                       "Table for order List Req
         li_vbkd           TYPE TABLE OF lty_vbkd,                       "Table for PO Selection
         li_order_res      TYPE zotc_put_ordr_status_tbl,                "Table for order list Res
         li_sales_doc      TYPE zotc_sales_ordr_tbl,                     "Table for order list
         li_invoice_list   TYPE zotc_order_invc_tbl,                     "Table for Invoice
         li_log_item       TYPE sapplco_log_item_tab,                    "Table for Log
         li_inv            TYPE z01otcstring_tab,                        "Table for Invoice List Res
         li_where          TYPE STANDARD TABLE OF string INITIAL SIZE 0, "Dynamic Where
         li_mulref         TYPE STANDARD TABLE OF lty_mulref,            "Table for Multiple Web Ref
** --- Begin of Changes CR D2_117 by Avik Poddar on Sept 13 2014
         li_mulsoldto      TYPE STANDARD TABLE OF lty_mul_soldto, "Table for Multiple Sold To
** --- End of Changes CR D2_117 by Avik Poddar on Sept 13 2014

**-------Declaration of Work Area--------------------**
         lwa_proxy_out     TYPE z01otcdt_order_list_res_sales, " Proxy Structure (generated)
         lwa_standard_err  TYPE z01otcexchange_fault_data,     " Proxy Structure (generated)
         lwa_log_data      TYPE z01otcexchange_log_data,       " Proxy Structure (generated)
         lwa_log           TYPE sapplco_log,                   " Proxy Structure (Generated)
         lwa_where         TYPE string,                        " Dynamic Where
         lwa_log_item      TYPE sapplco_log_item,              " protocol message issued by an application
         lwa_sales_doc     TYPE zotc_sales_ordr,               " Sales Order Number
         lwa_vbak          TYPE lty_vbak,                      " Work Area for Sales Order
         lwa_mulref        TYPE lty_mulref,                    " Work Area for Multiple Web Ref
** --- Begin of Changes CR D2_117 by Avik Poddar on Sept 13 2014
         lwa_mulsoldto     TYPE lty_mul_soldto. " Work Area for Multiple Sold To
** --- End of Changes CR D2_117 by Avik Poddar on Sept 13 2014

*--------------------Local Data Declaration----------------------*
  DATA:  lv_msg        TYPE string,   " Error message
         lv_note       TYPE string,   " Initial Note
         lv_inc_frmt   TYPE string,   " Note for Incorrect Format
         lv_note_log   TYPE string,   " Note Sent to Log
         li_erdat_low  TYPE sy-datum, " Current Date of Application Server
         li_erdat_high TYPE sy-datum, " Current Date of Application Server
         lv_success    TYPE string,   " Success Message
         lv_tabix      TYPE sy-tabix, " Index of Internal Tables
         lv_po_number  TYPE bstkd,    " Customer purchase order number "D2_OTC_IDD_0091 Defect # 482
         lv_dbcnt      TYPE sy-dbcnt, " Processed Database Table Rows
         lv_status     TYPE string,   " Status
         lv_tfill      TYPE sy-tfill, " Row Number of Internal Tables
         lv_soldto     TYPE kunag,    " Sold-to party
         lv_ref_code   TYPE string.   " Reference Code


*--------------------local constant declaration------------------*
  CONSTANTS:
      lc_five       TYPE char2  VALUE '5',      " Five of type CHAR2
      lc_three      TYPE char2  VALUE '3',      " Three of type CHAR2
      lc_posnr      TYPE posnr  VALUE '000000'. " Item number of the SD document
*-------------------Field Symbol Declaration--------------------*
  FIELD-SYMBOLS :
                 <lfs_proxy_in>  TYPE z01otcdt_order_list_req_sales, " Proxy Structure (generated),
                 <lfs_order_res> TYPE zotc_put_status_struc,         " Structure to Return Status with Order List
                 <lfs_vbkd>      TYPE lty_vbkd,
                 <lfs_invc_list> TYPE zotc_order_invc,               " Sales Order and Invoice List
                 <lfs_vbak>      TYPE lty_vbak,                      " Sales Order Number
                 <lfs_mulref>    TYPE lty_mulref,
                 <lfs_soldto>    TYPE string,
** --- Begin of Changes CR D2_117 by Avik Poddar on Sept 13 2014
                 <lfs_mulsoldto> TYPE lty_mul_soldto. " Work Area for Multiple Sold To
** --- End of Changes CR D2_117 by Avik Poddar on Sept 13 2014


  CLEAR : output, lv_note.

 " for processing data further at subroutine level
  li_proxy_in[] = input-mt_order_list_req-sales_order[].

 " Prepare query to VBAK
 " Dynamic Where clause before hitting on VBAK
 " Validation on each field
  IF li_proxy_in IS NOT INITIAL.
    DESCRIBE TABLE li_proxy_in LINES lv_tfill.
    IF lv_tfill EQ 1.
      LOOP AT li_proxy_in ASSIGNING <lfs_proxy_in>.
* Begin of Changes APODDAR 30TH June 2014
        IF <lfs_proxy_in>-status IS NOT INITIAL.
          lv_status = <lfs_proxy_in>-status. "Status
        ENDIF. " IF <lfs_proxy_in>-status IS NOT INITIAL
* End of Changes APODDAR 30TH June 2014

** --- Begin of Changes CR D2_117 by Avik Poddar on Sept 13 2014
        LOOP AT <lfs_proxy_in>-sold_to_id ASSIGNING <lfs_soldto>.

          CONCATENATE lv_note 'Sold To Id'(006) <lfs_soldto>
              INTO lv_note SEPARATED BY space.
          CONCATENATE 'Incorrect Input Format for'(009)
          'Sold To Id'(006) <lfs_soldto>
            INTO lv_inc_frmt SEPARATED BY space.

*          FIND FIRST OCCURRENCE OF REGEX `[[:punct:]]`
*          IN <lfs_soldto>.
*          IF sy-subrc = 0.
*            lwa_log_item-severity_code = lc_five. " Error
*            lwa_log_item-note = lv_inc_frmt.
*            APPEND lwa_log_item TO li_log_item.
*            lwa_log-item[] = li_log_item[].
*
*          ELSE. " ELSE -> IF sy-subrc = 0

            CLEAR lv_soldto.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = <lfs_soldto>
              IMPORTING
                output = lv_soldto.

            lwa_mulsoldto-sales_ordr = <lfs_proxy_in>-sales_order_number.
            lwa_mulsoldto-sold_to_id = lv_soldto.
            lwa_mulsoldto-status     = lv_status.
            APPEND lwa_mulsoldto TO li_mulsoldto.


       "   ENDIF. " IF sy-subrc = 0

* <--- End    of Change for D2_OTC_IDD_0091 Defect # 6369 by APODDAR


        ENDLOOP. " LOOP AT <lfs_proxy_in>-sold_to_id ASSIGNING <lfs_soldto>
** --- End of Changes CR D2_117 by Avik Poddar on Sept 13 2014

* ---> Begin of Change for D2_OTC_IDD_0091 Defect # 6369 by APODDAR

*        IF NOT <lfs_proxy_in>-sales_order_number IS INITIAL.
*          CONCATENATE 'Sales Order Number'(002) <lfs_proxy_in>-sales_order_number
*            INTO lv_note SEPARATED BY space.
*          CONCATENATE 'Incorrect Input Format for'(009)
*          'Sales Order Number'(002) <lfs_proxy_in>-sales_order_number
*            INTO lv_inc_frmt SEPARATED BY space.


*          FIND FIRST OCCURRENCE OF REGEX `[[:punct:]]`
*          IN <lfs_proxy_in>-sales_order_number.
*          IF sy-subrc = 0.
*            lwa_log_item-severity_code = lc_five. " Error
*            lwa_log_item-note    = lv_inc_frmt.
*            APPEND lwa_log_item TO li_log_item.
*            lwa_log-item[] =  li_log_item[].
*          ENDIF. " IF sy-subrc = 0


*        ENDIF. " IF NOT <lfs_proxy_in>-sales_order_number IS INITIAL

* <--- End    of Change for D2_OTC_IDD_0091 Defect # 6369 by APODDAR

* ---> Begin of Change for D2_OTC_IDD_0091 Defect # 6369 by APODDAR

*        IF NOT <lfs_proxy_in>-reference_code IS INITIAL.
*          CONCATENATE lv_note 'Reference Code'(003) <lfs_proxy_in>-reference_code
*          INTO lv_note SEPARATED BY space.
*          CONCATENATE 'Incorrect Input Format for'(009)
*          'Reference Code'(003) <lfs_proxy_in>-reference_code
*            INTO lv_inc_frmt SEPARATED BY space.


*          FIND FIRST OCCURRENCE OF REGEX `[[:punct:]]`
*          IN <lfs_proxy_in>-reference_code.
*          IF sy-subrc = 0.
*            lwa_log_item-severity_code = lc_five. " Error
*            lwa_log_item-note = lv_inc_frmt.
*            APPEND lwa_log_item TO li_log_item.
*            lwa_log-item[] =  li_log_item[].
*          ENDIF. " IF sy-subrc = 0


*        ENDIF. " IF NOT <lfs_proxy_in>-reference_code IS INITIAL

* <--- End    of Change for D2_OTC_IDD_0091 Defect # 6369 by APODDAR

* ---> Begin of Change for D2_OTC_IDD_0091 Defect # 6369 by APODDAR

*        IF NOT <lfs_proxy_in>-reference_id IS INITIAL.
*          CONCATENATE lv_note 'Reference Id'(004) <lfs_proxy_in>-reference_id
*          INTO lv_note SEPARATED BY space.
*          CONCATENATE 'Incorrect Input Format for'(009)
*          'Reference Id'(004) <lfs_proxy_in>-reference_id
*            INTO lv_inc_frmt SEPARATED BY space.

*          FIND FIRST OCCURRENCE OF REGEX `[[:punct:]]`
*          IN <lfs_proxy_in>-reference_id.
*          IF sy-subrc = 0.
*            lwa_log_item-severity_code = lc_five. " Error
*            lwa_log_item-note = lv_inc_frmt.
*            APPEND lwa_log_item TO li_log_item.
*            lwa_log-item[] =  li_log_item[].
*          ENDIF. " IF sy-subrc = 0


*        ENDIF. " IF NOT <lfs_proxy_in>-reference_id IS INITIAL

* <--- End    of Change for D2_OTC_IDD_0091 Defect # 6369 by APODDAR

* ---> Begin of Change for D2_OTC_IDD_0091 Defect # 6369 by APODDAR


*        IF NOT <lfs_proxy_in>-po_number IS INITIAL.
*          CONCATENATE lv_note 'PO Number'(005) <lfs_proxy_in>-po_number
*          INTO lv_note SEPARATED BY space.
*          CONCATENATE 'Incorrect Input Format for'(009)
*          'PO Number'(005) <lfs_proxy_in>-po_number
*            INTO lv_inc_frmt SEPARATED BY space.

*          FIND FIRST OCCURRENCE OF REGEX `[[:punct:]]`
*          IN <lfs_proxy_in>-po_number.
*          IF sy-subrc = 0.
*            lwa_log_item-severity_code = lc_five. " Error
*            lwa_log_item-note = lv_inc_frmt.
*            APPEND lwa_log_item TO li_log_item.
*            lwa_log-item[] =  li_log_item[].
*          ELSE. " ELSE -> IF sy-subrc = 0
            lv_po_number = <lfs_proxy_in>-po_number.
*          ENDIF. " IF sy-subrc = 0


*        ENDIF. " IF NOT <lfs_proxy_in>-po_number IS INITIAL

* <--- End    of Change for D2_OTC_IDD_0091 Defect # 6369 by APODDAR


** --- Begin of Changes CR D2_117 by Avik Poddar on Sept 13 2014
*        IF NOT <lfs_proxy_in>-sold_to_id IS INITIAL.
*          CONCATENATE lv_note 'Sold To Id'(006) <lfs_proxy_in>-sold_to_id
*          INTO lv_note SEPARATED BY space.
*          CONCATENATE 'Incorrect Input Format for'(009)
*          'Sold To Id'(006) <lfs_proxy_in>-sold_to_id
*            INTO lv_inc_frmt SEPARATED BY space.
*          FIND FIRST OCCURRENCE OF REGEX `[[:punct:]]`
*          IN <lfs_proxy_in>-sold_to_id.
*          IF sy-subrc = 0.
*            lwa_log_item-severity_code = lc_five. " Error
*            lwa_log_item-note = lv_inc_frmt.
*            APPEND lwa_log_item TO li_log_item.
*            lwa_log-item[] = li_log_item[].
*          ENDIF. " IF sy-subrc = 0
*        ENDIF. " IF NOT <lfs_proxy_in>-sold_to_id IS INITIAL
** --- End of Changes CR D2_117 by Avik Poddar on Sept 13 2014

        IF <lfs_proxy_in>-created_from_date IS NOT INITIAL.
          CONCATENATE lv_note 'From Date'(007) <lfs_proxy_in>-created_from_date
          INTO lv_note SEPARATED BY space.
        ENDIF. " IF <lfs_proxy_in>-created_from_date IS NOT INITIAL

        IF <lfs_proxy_in>-created_to_date IS NOT INITIAL.
          CONCATENATE lv_note 'To Date'(008) <lfs_proxy_in>-created_to_date
          INTO lv_note SEPARATED BY space.
        ENDIF. " IF <lfs_proxy_in>-created_to_date IS NOT INITIAL

** --- Begin of Changes CR D2_117 by Avik Poddar on Sept 13 2014
*        IF NOT li_log_item IS INITIAL.
*          EXIT.
*        ENDIF. " IF NOT li_log_item IS INITIAL
** --- End of Changes CR D2_117 by Avik Poddar on Sept 13 2014

        IF NOT <lfs_proxy_in>-sales_order_number IS INITIAL.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = <lfs_proxy_in>-sales_order_number
            IMPORTING
              output = <lfs_proxy_in>-sales_order_number.
          CONCATENATE 'VBELN = ''' <lfs_proxy_in>-sales_order_number ''''
          INTO lwa_where.
          APPEND lwa_where TO li_where.
        ENDIF. " IF NOT <lfs_proxy_in>-sales_order_number IS INITIAL

** --- Begin of Changes CR D2_117 by Avik Poddar on Sept 13 2014
*        CLEAR lwa_where.
*        IF NOT li_where IS INITIAL
*          AND NOT <lfs_proxy_in>-sold_to_id IS INITIAL.
*          CLEAR lv_soldto.
*          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*            EXPORTING
*              input  = <lfs_proxy_in>-sold_to_id
*            IMPORTING
*              output = lv_soldto.
*          CONCATENATE 'AND KUNNR = ''' lv_soldto ''''
*           INTO lwa_where.
*          APPEND lwa_where TO li_where.
*        ELSEIF NOT <lfs_proxy_in>-sold_to_id IS INITIAL
*          AND <lfs_proxy_in>-sales_order_number IS INITIAL.
*          CLEAR lv_soldto.
*          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*            EXPORTING
*              input  = <lfs_proxy_in>-sold_to_id
*            IMPORTING
*              output = lv_soldto.
*          CONCATENATE 'KUNNR = ''' lv_soldto ''''
*           INTO lwa_where.
*          APPEND lwa_where TO li_where.
*        ENDIF. " IF NOT li_where IS INITIAL
** --- End of Changes CR D2_117 by Avik Poddar on Sept 13 2014
* -->Begin of Changes for Defect 3210 by Avik Poddar on Jan 27,2015
        CLEAR lwa_where.
        IF NOT li_where IS INITIAL
          AND NOT <lfs_proxy_in>-reference_id IS INITIAL.
          CONCATENATE 'AND ZZDOCREF = ''' <lfs_proxy_in>-reference_id ''''
          INTO lwa_where.
          APPEND lwa_where TO li_where.
* -->Begin of Changes for Defect 6270 by MBAGDA
*> DELETE
*        ELSEIF NOT <lfs_proxy_in>-reference_id IS INITIAL
*          AND <lfs_proxy_in>-reference_code IS INITIAL
*          AND <lfs_proxy_in>-sales_order_number IS INITIAL.
*> INSERT
        ELSEIF NOT <lfs_proxy_in>-reference_id IS INITIAL.
* <--End of Changes for Defect 6270
          CONCATENATE 'ZZDOCREF = ''' <lfs_proxy_in>-reference_id ''''
          INTO lwa_where.
          APPEND lwa_where TO li_where.
        ENDIF. " IF NOT li_where IS INITIAL
* <--End of Changes for Defect 3210 by Avik Poddar on Jan 27,2015

        CLEAR lwa_where.
        IF NOT li_where IS INITIAL
          AND NOT <lfs_proxy_in>-reference_code IS INITIAL.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = <lfs_proxy_in>-reference_code
            IMPORTING
              output = <lfs_proxy_in>-reference_code.
          CONCATENATE 'AND ZZDOCTYP = ''' <lfs_proxy_in>-reference_code ''''
          INTO lwa_where.
          APPEND lwa_where TO li_where.
* -->Begin of Changes for Defect 6270 by MBAGDA
*> DELETE
*        ELSEIF NOT <lfs_proxy_in>-reference_code IS INITIAL
*          AND <lfs_proxy_in>-sales_order_number IS INITIAL.
*> INSERT
        ELSEIF NOT <lfs_proxy_in>-reference_code IS INITIAL.
* <--End of Changes for Defect 6270
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = <lfs_proxy_in>-reference_code
            IMPORTING
              output = <lfs_proxy_in>-reference_code.
          CONCATENATE 'ZZDOCTYP = ''' <lfs_proxy_in>-reference_code ''''
          INTO lwa_where.
          APPEND lwa_where TO li_where.
        ENDIF. " IF NOT li_where IS INITIAL


* -->Begin of Changes for Defect 3210 by Avik Poddar on Jan 27,2015
*        CLEAR lwa_where.
*        IF NOT li_where IS INITIAL
*          AND NOT <lfs_proxy_in>-reference_id IS INITIAL.
*          CONCATENATE 'AND ZZDOCREF = ''' <lfs_proxy_in>-reference_id ''''
*          INTO lwa_where.
*          APPEND lwa_where TO li_where.
*        ELSEIF NOT <lfs_proxy_in>-reference_id IS INITIAL
*          AND <lfs_proxy_in>-reference_code IS INITIAL
*          AND <lfs_proxy_in>-sales_order_number IS INITIAL.
*          CONCATENATE 'ZZDOCREF = ''' <lfs_proxy_in>-reference_id ''''
*          INTO lwa_where.
*          APPEND lwa_where TO li_where.
*        ENDIF. " IF NOT li_where IS INITIAL
* <--End of Changes for Defect 3210 by Avik Poddar on Jan 27,2015


        IF NOT <lfs_proxy_in>-created_from_date IS INITIAL
          AND NOT <lfs_proxy_in>-created_to_date IS INITIAL.
          li_erdat_low = <lfs_proxy_in>-created_from_date.
          li_erdat_high = <lfs_proxy_in>-created_to_date.
        ELSE. " ELSE -> IF NOT <lfs_proxy_in>-created_from_date IS INITIAL
          IF li_where IS INITIAL.
            IF <lfs_proxy_in>-po_number IS INITIAL.
              li_erdat_low = sy-datum - 90.
              li_erdat_high = sy-datum.
              CONCATENATE lv_note 'From Date'(007) li_erdat_low
               INTO lv_note SEPARATED BY space.
              CONCATENATE lv_note 'To Date'(008) li_erdat_high
               INTO lv_note SEPARATED BY space.
            ENDIF. " IF <lfs_proxy_in>-po_number IS INITIAL
          ENDIF. " IF li_where IS INITIAL
        ENDIF. " IF NOT <lfs_proxy_in>-created_from_date IS INITIAL

        CLEAR lwa_where.
        IF li_where IS INITIAL.
          IF  li_erdat_low  IS NOT INITIAL
          AND li_erdat_high IS NOT INITIAL.
            CONCATENATE '(ERDAT GE ''' li_erdat_low ''' AND ERDAT LE ''' li_erdat_high ''')'
             INTO lwa_where.
            APPEND lwa_where TO li_where.
          ENDIF. " IF li_erdat_low IS NOT INITIAL
        ELSE. " ELSE -> IF li_erdat_low IS NOT INITIAL
          IF  li_erdat_low  IS NOT INITIAL
          AND li_erdat_high IS NOT INITIAL.
            CONCATENATE 'AND (ERDAT GE ''' li_erdat_low ''' AND ERDAT LE ''' li_erdat_high ''')'
             INTO lwa_where.
            APPEND lwa_where TO li_where.
          ENDIF. " IF li_erdat_low IS NOT INITIAL
        ENDIF. " IF li_where IS INITIAL
      ENDLOOP. " LOOP AT li_proxy_in ASSIGNING <lfs_proxy_in>
    ELSE. " ELSE -> IF li_erdat_low IS NOT INITIAL
 "Logic for multiple web reference
      UNASSIGN <lfs_proxy_in>.
      LOOP AT li_proxy_in ASSIGNING <lfs_proxy_in>.
        IF <lfs_proxy_in>-reference_id IS NOT INITIAL
         AND <lfs_proxy_in>-reference_code IS NOT INITIAL.
 "Reference Code
          CONCATENATE 'Incorrect Input Format for'(009)
          'Reference Code'(003) <lfs_proxy_in>-reference_code
          INTO lv_inc_frmt SEPARATED BY space.
* Begin of Changes Defect # 418 by Avik Poddar on Aug 15th 2014
          lv_ref_code = <lfs_proxy_in>-reference_code.
* End of Changes Defect # 418 by Avik Poddar on Aug 15th 2014
 "Reference Id
          CONCATENATE 'Incorrect Input Format for'(009)
          'Reference Id'(004) <lfs_proxy_in>-reference_id
          INTO lv_inc_frmt SEPARATED BY space.

* ---> Begin of Change for D2_OTC_IDD_0091 Defect # 6369 by APODDAR

*          FIND FIRST OCCURRENCE OF REGEX `[[:punct:]]`
*          IN <lfs_proxy_in>-reference_code.
*          IF sy-subrc = 0.
*            lwa_log_item-severity_code = lc_five. " Error
*            lwa_log_item-note = lv_inc_frmt.
*            APPEND lwa_log_item TO li_log_item.
*            lwa_log-item[] =  li_log_item[].
*          ELSE. " ELSE -> IF sy-subrc = 0
            lwa_mulref-zzdocref = <lfs_proxy_in>-reference_id.
*          ENDIF. " IF sy-subrc = 0
*          FIND FIRST OCCURRENCE OF REGEX `[[:punct:]]`
*          IN <lfs_proxy_in>-reference_id.
*          IF sy-subrc = 0.
*            lwa_log_item-severity_code = lc_five. " Error
*            lwa_log_item-note = lv_inc_frmt.
*            APPEND lwa_log_item TO li_log_item.
*            lwa_log-item[] =  li_log_item[].
*            CLEAR lwa_proxy_out.
*            lwa_proxy_out-log = lwa_log.
*            APPEND lwa_proxy_out
*            TO output-mt_order_list_res-sales_order.
*            REFRESH li_log_item.
*            CONTINUE.
*          ELSE. " ELSE -> IF sy-subrc = 0
            lwa_mulref-zzdoctyp = <lfs_proxy_in>-reference_code.
*          ENDIF. " IF sy-subrc = 0

* <--- End    of Change for D2_OTC_IDD_0091 Defect # 6369 by APODDAR

          IF <lfs_proxy_in>-status IS NOT INITIAL.
            lv_status = <lfs_proxy_in>-status.

* ---> Begin of Change for D2_OTC_IDD_0091 Defect # 6369 by APODDAR

*            FIND FIRST OCCURRENCE OF REGEX `[[:punct:]]`
*            IN <lfs_proxy_in>-status.
*            IF sy-subrc NE 0.
              lwa_mulref-status = <lfs_proxy_in>-status.
*            ENDIF. " IF sy-subrc NE 0


* <--- End    of Change for D2_OTC_IDD_0091 Defect # 6369 by APODDAR

          ENDIF. " IF <lfs_proxy_in>-status IS NOT INITIAL
          APPEND lwa_mulref TO li_mulref.
        ENDIF. " IF <lfs_proxy_in>-reference_id IS NOT INITIAL

** --- Begin of Changes CR D2_117 by Avik Poddar on Sept 13 2014
*        IF <lfs_proxy_in>-sold_to_id IS NOT INITIAL.
*
*          CLEAR lv_soldto.
*          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*            EXPORTING
*              input  = <lfs_proxy_in>-sold_to_id
*            IMPORTING
*              output = lv_soldto.
*
*          CLEAR lv_inc_frmt.
*          CONCATENATE 'Incorrect Input Format for'(009)
*          'Sold To Id'(006) <lfs_proxy_in>-sold_to_id
*            INTO lv_inc_frmt SEPARATED BY space.
*          FIND FIRST OCCURRENCE OF REGEX `[[:punct:]]`
*          IN <lfs_proxy_in>-sold_to_id.
*          IF sy-subrc = 0.
*            lwa_log_item-severity_code = lc_five. " Error
*            lwa_log_item-note = lv_inc_frmt.
*            APPEND lwa_log_item TO li_log_item.
*            lwa_log-item[] = li_log_item[].
*          ENDIF. " IF sy-subrc = 0
*
*          lwa_mulsoldto-sold_to_id = <lfs_proxy_in>-sold_to_id.
*          lwa_mulsoldto-status     = <lfs_proxy_in>-status.
*          APPEND lwa_mulsoldto TO li_mulsoldto.
*
*        ENDIF.
** --- End of Changes CR D2_117 by Avik Poddar on Sept 13 2014
      ENDLOOP. " LOOP AT li_proxy_in ASSIGNING <lfs_proxy_in>
    ENDIF. " IF lv_tfill EQ 1
  ELSE. " ELSE -> IF sy-subrc NE 0
    li_erdat_low = sy-datum - 90.
    li_erdat_high = sy-datum.
    CONCATENATE lv_note 'From Date'(007) li_erdat_low
         INTO lv_note SEPARATED BY space.
    CONCATENATE lv_note 'To Date'(008) li_erdat_high
     INTO lv_note SEPARATED BY space.
    CONCATENATE '(ERDAT GE ''' li_erdat_low ''' AND ERDAT LE ''' li_erdat_high ''')'
       INTO lwa_where.
    APPEND lwa_where TO li_where.
  ENDIF. " IF li_proxy_in IS NOT INITIAL

  IF lv_po_number IS NOT INITIAL.
* -- Begin of Changes by APODDAR for Defect # 482 on Sept 10 2014
    TRANSLATE lv_po_number TO UPPER CASE.
* -- End of Changes by APODDAR for Defect # 482 on Sept 10 2014
    SELECT vbeln " Sales and Distribution Document Number
           posnr " Item number of the SD document
           bstkd " Customer purchase order number
      FROM vbkd  " Sales Document: Business Data
      INTO TABLE li_vbkd
      WHERE bstkd_m = lv_po_number
      AND posnr = lc_posnr.
    IF sy-subrc = 0.
      SORT li_vbkd BY vbeln.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF lv_po_number IS NOT INITIAL

*--Select Orders from VBAK to be further processed--*
  IF li_where IS NOT INITIAL.
    TRY.
        SELECT vbeln " Sales Document
               erdat " Date on Which Record Was Created
               kunnr " Sold-to party
         FROM vbak   " Sales Document: Header Data
         INTO TABLE li_vbak
         WHERE (li_where).
        IF sy-subrc = 0.
*--Sort to get latest records to older records--*
          SORT li_vbak BY vbeln kunnr. "CR D2_117 Change
          lv_dbcnt = sy-dbcnt.
        ENDIF. " IF sy-subrc = 0
      CATCH cx_sy_dynamic_osql_error.
        MESSAGE s138(zotc_msg) INTO lv_msg. " No Records Found
        lwa_log_data-text = lv_msg.
        lwa_log_data-severity = 'ERROR'(001).
        APPEND lwa_log_data TO lwa_standard_err-fault_detail.
        RAISE EXCEPTION TYPE z01otccx_fmt_sales_order_list
          EXPORTING
            standard = lwa_standard_err.
    ENDTRY.
  ELSEIF li_mulref IS NOT INITIAL.
    TRY.
        SELECT vbeln                             " Sales Document
               erdat                             " Date on Which Record Was Created
               kunnr                             " Sold-to party
         FROM vbak                               " Sales Document: Header Data
         INTO TABLE li_vbak
         FOR ALL ENTRIES IN li_mulref
         WHERE    zzdocref = li_mulref-zzdocref
            AND   zzdoctyp = li_mulref-zzdoctyp. " Defect 3201
        IF sy-subrc = 0.
*--Sort to get latest records to older records--*
          SORT li_vbak BY vbeln kunnr. "CR D2_117 Change
          lv_dbcnt = sy-dbcnt.
        ENDIF. " IF sy-subrc = 0
      CATCH cx_sy_dynamic_osql_error.
        MESSAGE s138(zotc_msg) INTO lv_msg. " No Records Found
        lwa_log_data-text = lv_msg.
        lwa_log_data-severity = 'ERROR'(001).
        APPEND lwa_log_data TO lwa_standard_err-fault_detail.
        RAISE EXCEPTION TYPE z01otccx_fmt_sales_order_list
          EXPORTING
            standard = lwa_standard_err.
    ENDTRY.
** ---> Begin of Changes for Defect # 482 "PO Search by APODDAR
  ELSEIF li_vbkd IS NOT INITIAL.
    TRY.
        SELECT vbeln " Sales Document
               erdat " Date on Which Record Was Created
               kunnr " Sold-to party
         FROM vbak   " Sales Document: Header Data
         INTO TABLE li_vbak
         FOR ALL ENTRIES IN li_vbkd
         WHERE vbeln = li_vbkd-vbeln.
        IF sy-subrc = 0.
*--Sort to get latest records to older records--*
          SORT li_vbak BY vbeln kunnr. "CR D2_117 Change
          lv_dbcnt = sy-dbcnt.
        ENDIF. " IF sy-subrc = 0
      CATCH cx_sy_dynamic_osql_error.
        MESSAGE s138(zotc_msg) INTO lv_msg. " No Records Found
        lwa_log_data-text = lv_msg.
        lwa_log_data-severity = 'ERROR'(001).
        APPEND lwa_log_data TO lwa_standard_err-fault_detail.
        RAISE EXCEPTION TYPE z01otccx_fmt_sales_order_list
          EXPORTING
            standard = lwa_standard_err.
    ENDTRY.
** ---> End of Changes for Defect # 482 "PO Search by APODDAR
  ENDIF. " IF li_where IS NOT INITIAL

  IF lv_po_number IS NOT INITIAL.
    IF li_vbkd IS NOT INITIAL
      AND li_vbak IS NOT INITIAL.
      LOOP AT li_vbak ASSIGNING <lfs_vbak>.
        READ TABLE li_vbkd TRANSPORTING NO FIELDS
          WITH KEY vbeln = <lfs_vbak>-vbeln.
        IF sy-subrc NE 0.
          <lfs_vbak>-vbeln = space.
        ENDIF. " IF sy-subrc NE 0
      ENDLOOP. " LOOP AT li_vbak ASSIGNING <lfs_vbak>
      DELETE li_vbak WHERE vbeln IS INITIAL.
    ELSEIF li_vbkd IS NOT INITIAL
    AND li_where IS INITIAL.
      LOOP AT li_vbkd ASSIGNING <lfs_vbkd>.
        IF li_log_item IS INITIAL.
          lwa_vbak-vbeln = <lfs_vbkd>-vbeln.
          APPEND lwa_vbak TO li_vbak.
        ENDIF. " IF li_log_item IS INITIAL
      ENDLOOP. " LOOP AT li_vbkd ASSIGNING <lfs_vbkd>
    ELSEIF li_vbkd IS INITIAL
    AND li_vbak IS NOT INITIAL.
      CONCATENATE 'Order Details for'(012) lv_note 'Not Found'(013)
        INTO lv_note SEPARATED BY space.
      lwa_log_item-severity_code = lc_five. " Error
      lwa_log_item-note    = lv_note.
      APPEND lwa_log_item TO li_log_item.
      lwa_log-item[] =  li_log_item[].
      CLEAR lwa_proxy_out.
* Begin of Changes Defect # 418 by Avik Poddar on Aug 15th 2014
      REFRESH li_log_item.
* End of Changes Defect # 418 by Avik Poddar on Aug 15th 2014
      lwa_proxy_out-log = lwa_log.
      APPEND lwa_proxy_out
      TO output-mt_order_list_res-sales_order.
      RETURN.
    ENDIF. " IF li_vbkd IS NOT INITIAL
  ENDIF. " IF lv_po_number IS NOT INITIAL

  IF li_vbak IS INITIAL.
** --- Begin of Changes CR D2_117 by Avik Poddar on Sept 13 2014
    lv_note = 'Order Details Not Found'(017).
*    CONCATENATE 'Order Details for'(012) lv_note 'Not Found'(013)
*      INTO lv_note SEPARATED BY space.
** --- End of Changes CR D2_117 by Avik Poddar on Sept 13 2014
    lwa_log_item-severity_code = lc_five. " Error
    lwa_log_item-note    = lv_note.
    APPEND lwa_log_item TO li_log_item.
    lwa_log-item[] =  li_log_item[].
    CLEAR lwa_proxy_out.
* Begin of Changes Defect # 418 by Avik Poddar on Aug 15th 2014
    REFRESH li_log_item.
* End of Changes Defect # 418 by Avik Poddar on Aug 15th 2014
    lwa_proxy_out-log = lwa_log.
    APPEND lwa_proxy_out
    TO output-mt_order_list_res-sales_order.
    RETURN.
  ENDIF. " IF li_vbak IS INITIAL

** --- Begin of Changes CR D2_117 by Avik Poddar on Sept 13 2014
  IF li_mulsoldto IS NOT INITIAL
 AND li_vbak IS NOT INITIAL.

    LOOP AT li_mulsoldto ASSIGNING <lfs_mulsoldto>.
      IF <lfs_mulsoldto>-sold_to_id NE space
        AND <lfs_mulsoldto>-sales_ordr IS NOT INITIAL.

        READ TABLE li_vbak ASSIGNING <lfs_vbak>
        WITH KEY vbeln = <lfs_mulsoldto>-sales_ordr
                 kunnr = <lfs_mulsoldto>-sold_to_id
                 BINARY SEARCH.
        IF sy-subrc EQ 0.
          <lfs_vbak>-dflag = abap_true.
        ENDIF. " IF sy-subrc EQ 0
      ELSEIF <lfs_mulsoldto>-sold_to_id NE space
        AND <lfs_mulsoldto>-sales_ordr IS INITIAL.
        SORT li_vbak BY kunnr.
        READ TABLE li_vbak ASSIGNING <lfs_vbak>
     WITH KEY kunnr = <lfs_mulsoldto>-sold_to_id
              BINARY SEARCH.
        IF sy-subrc EQ 0.
          <lfs_vbak>-dflag = abap_true.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF <lfs_mulsoldto>-sold_to_id NE space
    ENDLOOP. " LOOP AT li_mulsoldto ASSIGNING <lfs_mulsoldto>
    DELETE li_vbak WHERE dflag IS INITIAL.
  ENDIF. " IF li_mulsoldto IS NOT INITIAL
** --- End of Changes CR D2_117 by Avik Poddar on Sept 13 2014

 "delete if more than 100 records
  IF lv_dbcnt GT 100.
    SORT   li_vbak BY erdat DESCENDING.
*>>> Change-Begin for Def# 916
*   DELETE li_vbak FROM 101. "DEL
*<<< Change-End for Def# 916
  ENDIF. " IF lv_dbcnt GT 100

  LOOP AT li_vbak ASSIGNING <lfs_vbak>.
    lwa_sales_doc-sales_order_number = <lfs_vbak>-vbeln.
    APPEND lwa_sales_doc TO li_sales_doc.
  ENDLOOP. " LOOP AT li_vbak ASSIGNING <lfs_vbak>

 "Calling Custom FM to populate resultant order list
 " with overall status in response to query from Evo
  CALL FUNCTION 'ZOTC_GET_ORDER_STATUS'
    EXPORTING
      im_order_req     = li_sales_doc
    IMPORTING
      ex_order_res     = li_order_res
      ex_order_inv     = li_invoice_list
    EXCEPTIONS
      no_order_found   = 1
      no_data_provided = 2
      OTHERS           = 3.
  IF sy-subrc <> 0
    OR li_order_res IS INITIAL.
** --- Begin of Changes CR D2_117 by Avik Poddar on Sept 13 2014
    lv_note = 'Order Details Not Found'(017).
*    CONCATENATE 'Order Details for'(012) lv_note 'Not Found'(013)
*      INTO lv_note SEPARATED BY space.
** --- End of Changes CR D2_117 by Avik Poddar on Sept 13 2014
    lwa_log_item-severity_code = lc_five. " Error
    lwa_log_item-note    = lv_note.
    APPEND lwa_log_item TO li_log_item.
    lwa_log-item[] =  li_log_item[].
    CLEAR lwa_proxy_out.
    REFRESH li_log_item.
    lwa_proxy_out-log = lwa_log.
    APPEND lwa_proxy_out
    TO output-mt_order_list_res-sales_order.
    RETURN.
  ENDIF. " IF sy-subrc <> 0

  IF lv_tfill EQ 1.
    CLEAR lwa_proxy_out.
    SORT : li_order_res BY sales_order_number,
           li_invoice_list BY sales_order_number.
**---Prepare the Final List to be sent to Proxy Structure---**
    LOOP AT li_order_res ASSIGNING <lfs_order_res>.

      lwa_proxy_out-sales_order_number = <lfs_order_res>-sales_order_number.
      lwa_proxy_out-reference_id = <lfs_order_res>-reference_id.
      lwa_proxy_out-po_number = <lfs_order_res>-po_number.
* Begin of Change for D2_OTC_IDD_0091_CR01 by APODDAR ON 27TH Jun 2014
      lwa_proxy_out-po_date = <lfs_order_res>-po_date.
* End of Change for D2_OTC_IDD_0091_CR01 by APODDAR ON 27TH Jun 2014
      lwa_proxy_out-order_value = <lfs_order_res>-order_value.
      lwa_proxy_out-order_value_currency = <lfs_order_res>-order_value_currency.
      lwa_proxy_out-status = <lfs_order_res>-status.

      READ TABLE li_invoice_list TRANSPORTING NO FIELDS
        WITH KEY sales_order_number = <lfs_order_res>-sales_order_number
        BINARY SEARCH.
      IF sy-subrc = 0.
        lv_tabix = sy-tabix.
      ENDIF. " IF sy-subrc = 0

**---Preparing the Invoice List per Order---**
      LOOP AT li_invoice_list ASSIGNING <lfs_invc_list>
        FROM lv_tabix.
        IF <lfs_order_res>-sales_order_number NE <lfs_invc_list>-sales_order_number.
          REFRESH li_inv.
          EXIT.
        ENDIF. " IF <lfs_order_res>-sales_order_number NE <lfs_invc_list>-sales_order_number
        APPEND <lfs_invc_list>-invoice_number
          TO li_inv.
        lwa_proxy_out-invoice_number[] = li_inv[].
      ENDLOOP. " LOOP AT li_invoice_list ASSIGNING <lfs_invc_list>


**----Send back the data to Proxy Structure----**
*     Begin of Changes APODDAR 30-June 2014
      IF lv_status IS NOT INITIAL.
        IF lwa_proxy_out-status = lv_status.
          APPEND lwa_proxy_out
              TO output-mt_order_list_res-sales_order.
        ELSE. " ELSE -> IF lwa_proxy_out-status = lv_status
          CLEAR lv_note.
** --- Begin of Changes CR D2_117 by Avik Poddar on Sept 13 2014
*          CONCATENATE 'Order Details for'(012) 'Sales Order Number'(002)
*          lwa_proxy_out-sales_order_number
*          'Status'(015) lv_status 'Not Found'(013)
*           INTO lv_note SEPARATED BY space.
          lv_note = 'Order Details Not Found'(017).
** --- End of Changes CR D2_117 by Avik Poddar on Sept 13 2014
          lwa_log_item-severity_code = lc_five. " Error
          lwa_log_item-note    = lv_note.
          APPEND lwa_log_item TO li_log_item.
          lwa_log-item[] =  li_log_item[].
          CLEAR lwa_proxy_out.
          lwa_proxy_out-log = lwa_log.
          REFRESH li_log_item.
          CLEAR:
          lwa_proxy_out-sales_order_number,
          lwa_proxy_out-reference_id,
          lwa_proxy_out-po_number,
          lwa_proxy_out-po_date,
          lwa_proxy_out-order_value,
          lwa_proxy_out-order_value_currency,
          lwa_proxy_out-status.
          APPEND lwa_proxy_out
              TO output-mt_order_list_res-sales_order.
        ENDIF. " IF lwa_proxy_out-status = lv_status
      ELSE. " ELSE -> IF lv_status IS NOT INITIAL
**---Preparing the Success Log---**
        CLEAR : lv_note_log, lv_success.

** --- Begin of Changes CR D2_117 by Avik Poddar on Sept 13 2014
        lv_note_log = 'Order Details Found'(016).
*        CONCATENATE 'Order Details for'(012) lv_note 'Found'(014)
*          INTO lv_note_log SEPARATED BY space.
        lwa_log_item-severity_code = lc_three. " Success
** --- End of Changes CR D2_117 by Avik Poddar on Sept 13 2014

        lwa_log_item-note    = lv_note_log.
        APPEND lwa_log_item TO li_log_item.
        lwa_log-item[] =  li_log_item[].

        lwa_proxy_out-log = lwa_log.

        APPEND lwa_proxy_out
            TO output-mt_order_list_res-sales_order.
      ENDIF. " IF lv_status IS NOT INITIAL
*     End of Changes APODDAR 30-June 2014
      CLEAR lwa_proxy_out.
      REFRESH li_log_item.
    ENDLOOP. " LOOP AT li_order_res ASSIGNING <lfs_order_res>

  ELSE. " ELSE -> IF <lfs_order_res>-sales_order_number NE <lfs_invc_list>-sales_order_number
    CLEAR lwa_proxy_out.
    SORT : li_order_res BY sales_order_number,
           li_invoice_list BY sales_order_number.
**---Prepare the Final List to be sent to Proxy Structure---**
    LOOP AT li_order_res ASSIGNING <lfs_order_res>.

      lwa_proxy_out-sales_order_number = <lfs_order_res>-sales_order_number.
      lwa_proxy_out-reference_id = <lfs_order_res>-reference_id.
      lwa_proxy_out-po_number = <lfs_order_res>-po_number.
* Begin of Change for D2_OTC_IDD_0091_CR01 by APODDAR ON 27TH Jun 2014
      lwa_proxy_out-po_date = <lfs_order_res>-po_date.
* End of Change for D2_OTC_IDD_0091_CR01 by APODDAR ON 27TH Jun 2014
      lwa_proxy_out-order_value = <lfs_order_res>-order_value.
      lwa_proxy_out-order_value_currency = <lfs_order_res>-order_value_currency.
      lwa_proxy_out-status = <lfs_order_res>-status.

      READ TABLE li_invoice_list TRANSPORTING NO FIELDS
        WITH KEY sales_order_number = <lfs_order_res>-sales_order_number
        BINARY SEARCH.
      IF sy-subrc = 0.
        lv_tabix = sy-tabix.
      ENDIF. " IF sy-subrc = 0

**---Preparing the Invoice List per Order---**
      LOOP AT li_invoice_list ASSIGNING <lfs_invc_list>
        FROM lv_tabix.
        IF <lfs_order_res>-sales_order_number NE <lfs_invc_list>-sales_order_number.
          REFRESH li_inv.
          EXIT.
        ENDIF. " IF <lfs_order_res>-sales_order_number NE <lfs_invc_list>-sales_order_number
        APPEND <lfs_invc_list>-invoice_number
          TO li_inv.
        lwa_proxy_out-invoice_number[] = li_inv[].
      ENDLOOP. " LOOP AT li_invoice_list ASSIGNING <lfs_invc_list>

**----Send back the data to Proxy Structure----**
*     Begin of Changes APODDAR 30-June 2014
      IF lv_status IS NOT INITIAL.
        IF lwa_proxy_out-status = lv_status.
* Begin of Changes Defect # 418 by Avik Poddar on Aug 15th 2014
          CONCATENATE 'Order Details for'(012)
          'Reference Code'(003) lv_ref_code
          'Reference Id'(004) lwa_proxy_out-reference_id
          'Status'(015) lv_status
          'Found'(014)
          INTO lv_note_log SEPARATED BY space.
* End of Changes Defect # 418 by Avik Poddar on Aug 15th 2014
          lwa_log_item-severity_code = lc_three. " Error

          lwa_log_item-note    = lv_note_log.
          APPEND lwa_log_item TO li_log_item.
          lwa_log-item[] =  li_log_item[].

          lwa_proxy_out-log = lwa_log.

          APPEND lwa_proxy_out
              TO output-mt_order_list_res-sales_order.

          CLEAR lwa_proxy_out.
          REFRESH li_log_item.
*        ELSE. " ELSE -> IF lwa_proxy_out-status = lv_status
**----Begin of Changes for Multiple Reference
*          CLEAR : lv_note, lv_success.
* "Reference Code
*          CONCATENATE lv_note 'Reference Code'(003) '01'
*          INTO lv_note SEPARATED BY space.
* "Reference Id
*          CONCATENATE lv_note 'Reference Id'(004) <lfs_order_res>-reference_id
*          INTO lv_note SEPARATED BY space.
*
*          CONCATENATE 'Order Details for'(012)
*                      lv_note
*                      'Status'(015)
*                      lv_status
*                      'Not Found'(013)
*            INTO lv_note_log SEPARATED BY space.
*          lwa_log_item-severity_code = lc_five. " Error
*          lwa_log_item-note    = lv_note_log.
*          APPEND lwa_log_item TO li_log_item.
*          lwa_log-item[] =  li_log_item[].
*          CLEAR lv_note_log.

*            CLEAR lv_note.
*            CONCATENATE 'Order Details for'(012) 'Sales Order Number'(002)
*            lwa_proxy_out-sales_order_number
*            'Status'(015) lv_status 'Not Found'(013)
*             INTO lv_note SEPARATED BY space.
*            lwa_log_item-severity_code = lc_five. " Error
*            lwa_log_item-note    = lv_note.
*            APPEND lwa_log_item TO li_log_item.
*            lwa_log-item[] =  li_log_item[].
*          CLEAR lwa_proxy_out.
*          lwa_proxy_out-log = lwa_log.
*          CLEAR:
*          lwa_proxy_out-sales_order_number,
*          lwa_proxy_out-reference_id,
*          lwa_proxy_out-po_number,
*          lwa_proxy_out-po_date,
*          lwa_proxy_out-order_value,
*          lwa_proxy_out-order_value_currency,
*          lwa_proxy_out-status.
*          REFRESH li_log_item.
*          APPEND lwa_proxy_out
*              TO output-mt_order_list_res-sales_order.
        ENDIF. " IF lwa_proxy_out-status = lv_status
**----End of Changes for Multiple Reference
      ELSE. " ELSE -> IF lwa_proxy_out-status = lv_status
**---Preparing the Success Log---**
        CLEAR : lv_note_log, lv_note, lv_success.
 "Reference Code
        CONCATENATE lv_note 'Reference Code'(003) '01'
        INTO lv_note SEPARATED BY space.
 "Reference Id
        CONCATENATE lv_note 'Reference Id'(004) <lfs_order_res>-reference_id
        INTO lv_note SEPARATED BY space.

        CONCATENATE 'Order Details for'(012) lv_note 'Found'(014)
          INTO lv_note_log SEPARATED BY space.
        lwa_log_item-severity_code = lc_three. " Success

        lwa_log_item-note    = lv_note_log.
        APPEND lwa_log_item TO li_log_item.
        lwa_log-item[] =  li_log_item[].

        lwa_proxy_out-log = lwa_log.

        APPEND lwa_proxy_out
              TO output-mt_order_list_res-sales_order.
        CLEAR lwa_proxy_out.
        REFRESH li_log_item.
      ENDIF. " IF lv_status IS NOT INITIAL
    ENDLOOP. " LOOP AT li_order_res ASSIGNING <lfs_order_res>

** --- Begin of Changes CR D2_117 by Avik Poddar on Sept 13 2014
 "check if web reference has been returned
    LOOP AT li_mulref ASSIGNING <lfs_mulref>.
      IF <lfs_mulref>-status IS INITIAL.
        READ TABLE li_order_res TRANSPORTING NO FIELDS
          WITH KEY reference_id = <lfs_mulref>-zzdocref.
        IF sy-subrc NE 0.
          CLEAR lv_note.
 "Reference Code
          CONCATENATE lv_note 'Reference Code'(003) <lfs_mulref>-zzdoctyp
          INTO lv_note SEPARATED BY space.
 "Reference Id
          CONCATENATE lv_note 'Reference Id'(004) <lfs_mulref>-zzdocref
          INTO lv_note SEPARATED BY space.
          CONCATENATE 'Order Details for'(012) lv_note
                      'Not Found'(013)
        INTO lv_note SEPARATED BY space.
          lwa_log_item-severity_code = lc_five. " Error
          lwa_log_item-note    = lv_note.
          APPEND lwa_log_item TO li_log_item.
          lwa_log-item[] =  li_log_item[].
          CLEAR lwa_proxy_out.
          lwa_proxy_out-log = lwa_log.
          APPEND lwa_proxy_out
          TO output-mt_order_list_res-sales_order.
          REFRESH li_log_item.
        ENDIF. " IF sy-subrc NE 0
      ELSE. " ELSE -> IF sy-subrc NE 0
        UNASSIGN <lfs_order_res>.
        READ TABLE li_order_res ASSIGNING <lfs_order_res>
         WITH KEY reference_id = <lfs_mulref>-zzdocref
                  status       = <lfs_mulref>-status.
        IF sy-subrc NE 0.
          CLEAR lv_note.
 "Reference Code
          CONCATENATE lv_note 'Reference Code'(003) <lfs_mulref>-zzdoctyp
          INTO lv_note SEPARATED BY space.
 "Reference Id
          CONCATENATE lv_note 'Reference Id'(004) <lfs_mulref>-zzdocref
          INTO lv_note SEPARATED BY space.
          CONCATENATE 'Order Details for'(012) lv_note
                      'Status'(015) <lfs_mulref>-status 'Not Found'(013)
        INTO lv_note SEPARATED BY space.
          lwa_log_item-severity_code = lc_five. " Error
          lwa_log_item-note    = lv_note.
          APPEND lwa_log_item TO li_log_item.
          lwa_log-item[] =  li_log_item[].
          CLEAR lwa_proxy_out.
          lwa_proxy_out-log = lwa_log.
          APPEND lwa_proxy_out
          TO output-mt_order_list_res-sales_order.
          REFRESH li_log_item.
        ENDIF. " IF sy-subrc NE 0
      ENDIF. " IF <lfs_mulref>-status IS INITIAL
    ENDLOOP. " LOOP AT li_mulref ASSIGNING <lfs_mulref>
** --- End of Changes CR D2_117 by Avik Poddar on Sept 13 2014

  ENDIF. " IF lv_tfill EQ 1

  CLEAR : li_proxy_in,
          li_vbak,
          li_order_res,
          li_sales_doc,
          li_invoice_list,
          li_log_item,
          li_inv,
          li_where,
          lwa_proxy_out,
          lwa_standard_err,
          lwa_log_data,
          lwa_log,
          lwa_where,
          lwa_log_item,
          lv_po_number,
          lv_status,
          lv_dbcnt.

ENDMETHOD.
ENDCLASS.
