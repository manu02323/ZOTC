*&---------------------------------------------------------------------*
*&  Include           ZXVVAU05
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :ZXVVAU05                                                 *
* TITLE      :D2_OTC_WDD_0013                                          *
* DEVELOPER  :  Vinita Choudhary                                       *
* OBJECT TYPE:  User exit                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID: D2_OTC_WDD_0013                                           *
*            D3_OTC_WDD_0024                                           *
*----------------------------------------------------------------------*
* DESCRIPTION:
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER     TRANSPORT  DESCRIPTION                         *
* ===========  ======== ========== ====================================*
* 12.12.2014   VCHOUDH   E2DK907287 Initial Development                *
* 20.01.2015   PMISHRA   E2DK907287 Defect 3080                        *
* 08.02.2016   SGHOSH    E2DK916930 Defect#1475:Db/Cr Memo workflows   *
*                                   status is getting reset even after *
*                                   being approved and billed          *
*16.08.2018    U101779  E1DK937450  Trigger event for No Charge order  *
*                                   for R4 object OTC_WDD_0024         *
*15.01.2019   U101779   E1DK937450 Defect #8160: Changes for deleting  *
*                                   existing workflow and starting the *
*                                   workflow for any changes in order  *
*25.01.2019   ASK      E1DK940271  Defect #8220: Commit work should not*
*                                  be done and the code should not     *
*                                  trigger for non retrun orders       *
*08.02.2019   U101779  E1DK940472  Defect #8327: Restrict WF start     *
*                                  during order change - Net Value,    *
*                                  Quantity, Creation new line, Removal*
*                                  of Rejection of Line Item - for the *
*                                  WRICEF ID D3_OTC_WDD_0024           *
*&---------------------------------------------------------------------*

DATA : lv_objkey  TYPE          swo_typeid. " Object key
DATA : li_dtls    TYPE TABLE OF swr_cont,        " Container (name-value pairs)
       lwa_dtls   TYPE          swr_cont      ,  " Container (name-value pairs)
       li_status  TYPE TABLE OF zdev_enh_status, " Enhancement Status
       li_worklist    TYPE TABLE OF swr_wihdr.   " Work Item Structure
DATA : lv_flag TYPE char1 . " Flag of type CHAR1
DATA : lv_objnr TYPE j_objnr , " Object number
       lv_stonr TYPE j_stonr,  " Status Order Number
* ---> Begin of Insert for Defect#1475(INC0255616): D2_OTC_WDD_0013 by SGHOSH
       lv_appr           TYPE flag,    " General Flag
       lv_billing_status TYPE fkstk,   " Billing status
       lv_status_num     TYPE j_stonr. " Status Order Number

FIELD-SYMBOLS: <lfs_status> TYPE zdev_enh_status. " Enhancement Status
* <--- End of Insert for Defect#1475(INC0255616): D2_OTC_WDD_0013 by SGHOSH

CONSTANTS : lc_objtype         TYPE swo_objtyp    VALUE 'ZWOOTC0013',
            lc_null            TYPE char4         VALUE 'NULL',              " Null Criteria
            lc_create_event    TYPE swo_event     VALUE 'WE_CREATE_MEMO',    " Event
            lc_terminate_event TYPE swo_event     VALUE 'WE_TERMINATE_MEMO', " Event
            lc_wdd_0013        TYPE z_enhancement VALUE 'D2_OTC_WDD_0013',   " Enhancement No.
            lc_cmr            TYPE auart         VALUE 'CMR',                " Sales Document Type
            lc_c              TYPE uvall_uk      VALUE 'C',                  " General incompletion status of the header
***--> Begin of addition of changes for defect 3080 .
            lc_zcmr           TYPE char4         VALUE 'ZCMR', " Zcmr of type CHAR4
            lc_zdmr           TYPE char4         VALUE 'ZDMR', " Zdmr of type CHAR4
            lc_etype          TYPE char1         VALUE 'E',
* ---> Begin of Insert for Defect#1475(INC0255616): D2_OTC_WDD_0013 by SGHOSH
            lc_billing_status TYPE char20       VALUE 'Z_BILLING_STATUS', " Billing status
            lc_status_num     TYPE char20       VALUE 'Z_STATUS_NUMBER'.  " Status Order Number
* <--- End of Insert for Defect#1475(INC0255616): D2_OTC_WDD_0013 by SGHOSH
***<-- End of changes for defect 3080.

**--> Begin of Insert for WDD0024 on 16.08.2018 by U101779
CONSTANTS:
*---> Begin of Delete for Defect #8327 on 08.02.2019 by U101779
** ---> Begin of Insert for D3_OTC_WDD_0024  Defect # 8160  by U101779
*      lc_no_charge_ord TYPE z_criteria    VALUE 'NCAUART',      " Enh. Criteria
*      lc_wdd_0024      TYPE z_enhancement VALUE 'OTC_WDD_0024'. " Enhancement No.
** <--- End   of Insert for D3_OTC_WDD_0024  Defect # 8160 by U101779
*<--- End of Delete for Defect #8327 on 08.02.2019 by U101779
      lc_term_event    TYPE swo_event     VALUE 'TERMINATE',  " Event
      lc_objtp         TYPE swo_objtyp    VALUE 'ZBUS9OTC24', " Object Type
      lc_event         TYPE swo_event     VALUE 'NOCHARGE'.   " Event
*---> Begin of Delete for Defect #8327 on 08.02.2019 by U101779
*DATA:
*      li_stat         TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
**--> End of Insert for WDD0024 on 16.08.2018 by U101779
*<--- End of Delete for Defect #8327 on 08.02.2019 by U101779

*<--- Begin of Insert for Defect #8327 on 08.02.2019 by U101779
DATA:
lv_ret_ord_flag       TYPE flag, " General Flag
lv_nocharge_flag      TYPE flag, " General Flag
lv_nocharge_create_fl TYPE flag, " General Flag
lv_no_trigger_wf      TYPE flag. " General Flag

CLEAR:
    lv_ret_ord_flag,
    lv_nocharge_flag,
    lv_no_trigger_wf,
    lv_nocharge_create_fl.
*<--- End   of Insert for Defect #8327 on 08.02.2019 by U101779

IF xvbak-vkbur IS NOT INITIAL AND xvbuk-uvall EQ lc_c. "   Check on sales office and the completness of the document, the workflow shouid be triggered on if sales office exists.

  CLEAR lv_flag.

* Get constants from EMI tools
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_wdd_0013
    TABLES
      tt_enh_status     = li_status.



  READ TABLE li_status WITH KEY criteria = lc_null   "NULL
                                active   = abap_true "X"
                                TRANSPORTING NO FIELDS.
  IF sy-subrc IS INITIAL.

    READ TABLE li_status WITH KEY criteria = lc_cmr
                                  sel_low = xvbak-auart
                                  active = abap_true
                                  TRANSPORTING NO FIELDS.
    IF sy-subrc IS NOT INITIAL .
      lv_flag = 'X'.
    ENDIF. " IF sy-subrc IS NOT INITIAL
    IF lv_flag IS INITIAL.

* ---> Begin of Insert for Defect#1475(INC0255616): D2_OTC_WDD_0013 by SGHOSH
*&&--Fetch Billing Status
      READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_billing_status
                                                           active = abap_true.
      IF sy-subrc IS INITIAL.
        lv_billing_status = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc IS INITIAL
*&&--Fetch Status Number
      READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_status_num
                                                           active = abap_true.
      IF sy-subrc IS INITIAL.
        lv_status_num = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc IS INITIAL
* <--- End of Insert for Defect#1475(INC0255616): D2_OTC_WDD_0013 by SGHOSH


*--->  begin of change for defect 3080
***  document should not be allowed to save if the status is status profile is Reject .
      lv_objnr = xvbak-objnr .
      CALL FUNCTION 'STATUS_READ'
        EXPORTING
          objnr                  =  lv_objnr
         only_active            = abap_true
       IMPORTING
*   OBTYP                  =
*   STSMA                  =
         stonr                  = lv_stonr
* TABLES
*   STATUS                 =
       EXCEPTIONS
         object_not_found       = 1
         OTHERS                 = 2 .
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF. " IF sy-subrc <> 0
      IF lv_stonr = '40' . "  rejected .
        MESSAGE 'No changes can be made. Status profile set to Reject' TYPE lc_etype.
      ENDIF. " IF lv_stonr = '40'
*<--- End of change for defect 3080.

* ---> Begin of Insert for Defect#1475(INC0255616): D2_OTC_WDD_0013 by SGHOSH
*&&-- If DR/CR Workflow is already approved , it should not trigger a new WF event again.
      CLEAR lv_appr.
      IF xvbuk-fkstk IS INITIAL OR
         xvbuk-fkstk = lv_billing_status. " Billing Status = C

        IF lv_stonr = lv_status_num. "Status Number: Approved (30).
*&&-- Set Approved Flag
          lv_appr = abap_true.
        ENDIF. " IF lv_stonr = lv_status_num
      ENDIF. " IF xvbuk-fkstk IS INITIAL OR

*&&--If Status is Approve then do not trigger any new workflow for that document
      IF lv_appr IS INITIAL.
* <--- End of Insert for Defect#1475(INC0255616): D2_OTC_WDD_0013 by SGHOSH

****
        lv_objkey = xvbak-vbeln.

*** check if there is existing workflow.
        CALL FUNCTION 'SAP_WAPI_WORKITEMS_TO_OBJECT'
          EXPORTING
*           OBJECT_POR      =
            objtype         = lc_objtype
            objkey          = lv_objkey
            top_level_items = abap_true
          TABLES
            worklist        = li_worklist.

        IF li_worklist[] IS  NOT INITIAL.
****  trigger termination event for the current in process workflow.
          CALL FUNCTION 'SAP_WAPI_CREATE_EVENT'
            EXPORTING
              object_type = lc_objtype
              object_key  = lv_objkey
              event       = lc_terminate_event.
        ENDIF. " IF li_worklist[] IS NOT INITIAL
****  trigger workflow for dispute.
        CALL FUNCTION 'SAP_WAPI_CREATE_EVENT'
          EXPORTING
            object_type = lc_objtype
            object_key  = lv_objkey
            event       = lc_create_event.

* ---> Begin of Insert for Defect#1475(INC0255616): D2_OTC_WDD_0013 by SGHOSH
      ENDIF. " IF lv_appr IS INITIAL
* <--- End of Insert for Defect#1475(INC0255616): D2_OTC_WDD_0013 by SGHOSH
    ENDIF. " IF lv_flag IS INITIAL

  ENDIF. " IF sy-subrc IS INITIAL
ENDIF. " IF xvbak-vkbur IS NOT INITIAL AND xvbuk-uvall EQ lc_c

*---> Begin of Delete for Defect #8327 on 08.02.2019 by U101779
*--> Begin of Insert for WDD0024 on 16.08.2018 by U101779

*CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
*  EXPORTING
*    iv_enhancement_no = lc_wdd_0024
*  TABLES
*    tt_enh_status     = li_stat.
*
*DELETE li_stat WHERE active = space.
*
*READ TABLE li_stat WITH KEY criteria = lc_null
*                              TRANSPORTING NO FIELDS.
*
*IF sy-subrc IS INITIAL.
** ---> Begin of Insert for D3_OTC_WDD_0024  Defect # 8220
*** ---> Begin of Insert for D3_OTC_WDD_0024  Defect # 8160  by U101779
*
*  READ TABLE li_stat WITH KEY criteria = 'AUART'
*                              sel_low  = xvbak-auart
*                              active   = abap_true
*                              BINARY SEARCH  TRANSPORTING NO FIELDS.
*
*  IF sy-subrc IS INITIAL.
*    lv_objkey = xvbak-vbeln.
*    CONDENSE lv_objkey.
*
*****  trigger termination event no charge and return order workflows for the current key
*    CALL FUNCTION 'SAP_WAPI_CREATE_EVENT'
*      EXPORTING
*        object_type = lc_objtp
*        object_key  = lv_objkey
*        event       = lc_term_event
*        commit_work = abap_false.
*  ENDIF. " IF sy-subrc IS INITIAL
*** <--- End   of Insert for D3_OTC_WDD_0024  Defect # 8160 by U101779
*
*  READ TABLE li_stat WITH KEY   criteria = lc_no_charge_ord
*                                sel_low  = xvbak-auart
*                                active   = abap_true
*                                BINARY SEARCH  TRANSPORTING NO FIELDS.
*
*  IF sy-subrc IS INITIAL.
*
** ---> Begin of Insert for D3_OTC_WDD_0024  Defect # 8160  by U101779
*    lv_objkey = xvbak-vbeln.
*    CONDENSE lv_objkey.
*
*****  trigger termination event no charge and return order workflows for the current key
*    CALL FUNCTION 'SAP_WAPI_CREATE_EVENT'
*      EXPORTING
*        object_type = lc_objtp
*        object_key  = lv_objkey
*        event       = lc_term_event
**       commit_work = abap_true.  " Defect 8220
*        commit_work = abap_false. " Defect 8220
** <--- End   of Insert for D3_OTC_WDD_0024  Defect # 8160 by U101779
** <--- End   of Insert for D3_OTC_WDD_0024  Defect # 8220
** Trigger the new workflow
*    CALL FUNCTION 'SAP_WAPI_CREATE_EVENT'
*      EXPORTING
*        object_type    = lc_objtp
*        object_key     = lv_objkey
*        event          = lc_event
*        commit_work    = space
*        event_language = sy-langu
*        language       = sy-langu
*        user           = sy-uname.
*
*  ENDIF. " IF sy-subrc IS INITIAL
*
*ENDIF. " IF sy-subrc IS INITIAL
*
**<--- End of Insert for WDD0024 on 16.08.2018 by U101779
*<--- End of Delete for Defect #8327 on 08.02.2019 by U101779

*---> Begin  of Insert for Defect #8327 on 08.02.2019 by U101779
CALL FUNCTION 'ZOTC_ORDER_WF'
  EXPORTING
    i_vbeln           = xvbak-vbeln
    i_xvbak           = xvbak
    i_vbuk            = xvbuk
  IMPORTING
    e_ret_ord_flag    = lv_ret_ord_flag
    e_nocharge_flag   = lv_nocharge_flag
    e_nocharge_create = lv_nocharge_create_fl
    e_no_trigger_wf   = lv_no_trigger_wf
  TABLES
    t_xvbap           = xvbap[]
    t_xvbfa           = xvbfa[].

IF lv_no_trigger_wf IS INITIAL.

  lv_objkey = xvbak-vbeln.
  CONDENSE lv_objkey.

  IF ( lv_ret_ord_flag IS NOT INITIAL ) OR ( lv_nocharge_flag IS NOT INITIAL ).
****  trigger termination event no charge and return order workflows for the current key
    CALL FUNCTION 'SAP_WAPI_CREATE_EVENT'
      EXPORTING
        object_type = lc_objtp
        object_key  = lv_objkey
        event       = lc_term_event
        commit_work = abap_false.

  ENDIF. " IF ( lv_ret_ord_flag IS NOT INITIAL ) OR ( lv_nocharge_flag IS NOT INITIAL )

  IF ( lv_nocharge_create_fl IS NOT INITIAL ) OR ( lv_nocharge_flag IS NOT INITIAL ) OR ( lv_ret_ord_flag IS NOT INITIAL ).
* Trigger the new workflow for no charge
    CALL FUNCTION 'SAP_WAPI_CREATE_EVENT'
      EXPORTING
        object_type    = lc_objtp
        object_key     = lv_objkey
        event          = lc_event
        commit_work    = space
        event_language = sy-langu
        language       = sy-langu
        user           = sy-uname.

  ENDIF. " IF ( lv_nocharge_create_fl IS NOT INITIAL ) OR ( lv_nocharge_flag IS NOT INITIAL ) OR ( lv_ret_ord_flag IS NOT INITIAL )

ENDIF. " IF lv_no_trigger_wf IS INITIAL

*<--- End   of Insert for Defect #8327 on 08.02.2019 by U101779
