***********************************************************************
* Function Module : ZOTC_CHECK_COMPLETION                             *
* TITLE           : D3_OTC_WDD_0024_Workflow for Returns              *
* DEVELOPER       : Jaswinder                                         *
* OBJECT TYPE     : Function Module                                   *
* SAP RELEASE     : SAP ECC 6.0                                       *
*---------------------------------------------------------------------*
* WRICEF ID       : D3_OTC_WDD_0024                                   *
*---------------------------------------------------------------------*
* DESCRIPTION     : Returns and No Charge                             *
*---------------------------------------------------------------------*
* MODIFICATION HISTORY:                                               *
*=====================================================================*
* DATE        USER     TRANSPORT       DESCRIPTION                    *
* =========== ======== ========== ====================================*
* 18-July-2018 U101779  E1DK937450  INITIAL DEVELOPMENT               *
* 15.01.2019   U101779  E1DK937450  Defect #8160: Changes for deleting*
*                                   existing workflow and starting the*
*                                   workflow for any changes in order *
* 08.02.2019 U101779   E1DK940472   Defect 8327 Upate logic for order *
* 21.02.2019 U101779   E1DK940472   Defect 8327 issue in triggering of*
*                                  return order changeINC0466244-02   *
* 02.04.2019 U101779   E2DK922261  Defect 8966 VBAK memory read issue *
*&--------------------------------------------------------------------*

FUNCTION zotc_check_completion.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(OBJTYPE) TYPE  SWETYPECOU-OBJTYPE OPTIONAL
*"     VALUE(OBJKEY) TYPE  SWEINSTCOU-OBJKEY OPTIONAL
*"     VALUE(EVENT) TYPE  SWEINSTCOU-EVENT OPTIONAL
*"     REFERENCE(RECTYPE) TYPE  SWETYPECOU-RECTYPE OPTIONAL
*"  TABLES
*"      EVENT_CONTAINER STRUCTURE  SWCONT
*"  EXCEPTIONS
*"      INCOMPLETION
*"      INVALID_ORDER_TYPE
*"      NO_WF_TRIGGER
*"----------------------------------------------------------------------

  CONSTANTS:
    lc_auart    TYPE z_criteria    VALUE 'AUART',        " Sales Document Type
    lc_null     TYPE char4         VALUE 'NULL',         " Null Criteria
    lc_wdd_0024 TYPE z_enhancement VALUE 'OTC_WDD_0024'. " Enhancement No.

  DATA:
    li_status TYPE TABLE OF zdev_enh_status, " Enhancement Status
    lv_auart  TYPE auart,                    " Sales Document Type
*---> Begin of Delete for Defect #8327 on 08.02.2019 by U101779
*        lv_netwr   TYPE netwr_ak,                         " Net Value of the Sales Order in Document Currency
*        li_orders  TYPE STANDARD TABLE OF zotc_order_val, " Net Value history of the Sales Order
*        lwa_orders TYPE zotc_order_val,                   " Net Value history of the Sales Orde
*<--- End of Delete for Defect #8327 on 08.02.2019 by U101779
    lv_key    TYPE vbeln, " Sales and Distribution Document Number
    lv_vbeln  TYPE vbeln. " Sales and Distribution Document Number

*---- Clear data
  CLEAR:
        lv_key,
        lv_vbeln,
        lv_auart,
        li_status[].

*---> Begin of Insert for Defect #8327 on 08.02.2019 by U101779
  DATA:
    lx_vbuk          TYPE vbuk,                      " Sales Document: Header Status and Administrative Data
    lx_vbak          TYPE vbak ,                     " Sales Document: Header Data
    li_vbfa          TYPE STANDARD TABLE OF vbfavb,  " Reference Structure for XVBFA/YVBFA
    li_vbap          TYPE STANDARD TABLE OF  vbapvb, " Document Structure for XVBAP/YVBAP
    lv_ret_ord_flag  TYPE flag,                      " General Flag
    lv_no_trigger_wf TYPE flag.                      " General Flag

  FIELD-SYMBOLS:
    <fs_vbap> TYPE ANY TABLE,
    <fs_vbfa> TYPE ANY TABLE,
    <fs_vbak> TYPE any,
    <fs_vbuk> TYPE any.

  CONSTANTS:
  lc_no_charg TYPE z_criteria    VALUE 'NCAUART'. " Enh. Criteria

  UNASSIGN:
   <fs_vbap>,
   <fs_vbfa>,
   <fs_vbak>,
   <fs_vbuk>.

  CLEAR:
      lv_ret_ord_flag,
      lv_no_trigger_wf.

*<--- End of Insert for Defect #8327 on 08.02.2019 by U101779

**---- wait is needed so that the data gets updated in the table
  WAIT UP TO 5 SECONDS.
  IF objkey IS NOT INITIAL.

    lv_key    =  objkey.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_key
      IMPORTING
        output = lv_key.

*---- Select order type from VBAK
    SELECT SINGLE auart " Sales Document Type
*---> Begin of Delete for Defect #8327 on 08.02.2019 by U101779
*                netwr " Net Value of the Sales Order in Document Currency
*<--- End of Delete for Defect #8327 on 08.02.2019 by U101779
      FROM vbak " Sales Document: Header Data
*---> Begin of Delete Defect #8327 on 08.02.2019 by U101779
*      INTO (lv_auart,lv_netwr)
*<--- End of Delete for Defect #8327 on 08.02.2019 by U101779
         INTO lv_auart
      WHERE vbeln = lv_key.

    IF sy-subrc IS INITIAL.

* Get constants from EMI tools
      CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
        EXPORTING
          iv_enhancement_no = lc_wdd_0024
        TABLES
          tt_enh_status     = li_status.

      DELETE li_status WHERE active IS INITIAL.

      READ TABLE li_status WITH KEY criteria = lc_null
                                    active   = abap_true
                                           TRANSPORTING NO FIELDS.

      IF sy-subrc IS INITIAL.

        SORT li_status BY criteria sel_low active .

        READ TABLE li_status WITH KEY criteria = lc_auart
                                      sel_low  = lv_auart
                                      active   = abap_true
                                      BINARY SEARCH  TRANSPORTING NO FIELDS.

        IF sy-subrc IS NOT INITIAL.
          RAISE invalid_order_type.
        ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL

*---- check the incompletion log
          SELECT vbeln " Sales and Distribution Document Number
            FROM vbuv  " Sales Document: Incompletion Log
            UP TO 1 ROWS
            INTO lv_vbeln
            WHERE vbeln = lv_key.
          ENDSELECT.

*---- Entry exists in case of incompletion log, ignore to start the workflow
          IF sy-subrc IS INITIAL AND lv_vbeln IS NOT INITIAL.
            RAISE incompletion.

*<--- Begin of Delete for Defect #8327 on 08.02.2019 by U101779
*          ELSE. " ELSE -> IF sy-subrc IS INITIAL AND lv_vbeln IS NOT INITIAL
*---- Check if it's a change in order and there's no change in value, then raise the exception
*---- Get the latest order change value
*            SELECT *
*              FROM zotc_order_val " Net Value history of the Sales Order
*              INTO TABLE li_orders
*              WHERE vbeln = lv_key.
*
*            IF sy-subrc IS INITIAL.
*              SORT li_orders BY counter DESCENDING.
*              READ TABLE li_orders INTO lwa_orders INDEX 1.
*
*              IF lwa_orders-netwr EQ lv_netwr.
** ---> Begin of Insert for D3_OTC_WDD_0024  Defect # 8160  by U101779
**                RAISE net_value_not_changed.
** <--- End   of Insert for D3_OTC_WDD_0024  Defect # 8160 by U101779
*
*              ENDIF. " IF lwa_orders-netwr EQ lv_netwr
*
*            ENDIF. " IF sy-subrc IS INITIAL
*<--- End   of Delete for Defect #8327 on 08.02.2019 by U101779

          ENDIF. " IF sy-subrc IS INITIAL AND lv_vbeln IS NOT INITIAL

        ENDIF. " IF sy-subrc IS NOT INITIAL

*---> begin of insert for defect #8327 on 08.02.2019 by u101779
*-- Assign the stack data to field symbols
        ASSIGN ('(SAPMV45A)XVBAK')   TO <fs_vbak>.
        ASSIGN ('(SAPMV45A)XVBUK')   TO <fs_vbuk>.
        ASSIGN ('(SAPMV45A)XVBAP[]') TO <fs_vbap>.
        ASSIGN ('(SAPMV45A)XVBFA[]') TO <fs_vbfa>.

        IF <fs_vbak> IS ASSIGNED.
          lx_vbak = <fs_vbak>.
*<--- End  of insert for defect #8327 on 08.02.2019 by u101779

*--> begin of insert for defect #8966  on  02.04.2019 by u101779
          IF lx_vbak-vbeln IS INITIAL.
            IF lv_key IS NOT INITIAL.
              SELECT SINGLE *
                FROM vbak
                INTO lx_vbak
                WHERE vbeln = lv_key.
            ENDIF.
          ENDIF.
*<-- End of insert for defect #8966  on  02.04.2019 by u101779

          IF <fs_vbap> IS ASSIGNED.
            li_vbap = <fs_vbap>.
          ENDIF. " IF <fs_vbap> IS ASSIGNED

          IF <fs_vbfa> IS ASSIGNED.
            li_vbfa = <fs_vbfa>.
          ENDIF. " IF <fs_vbfa> IS ASSIGNED

          IF <fs_vbuk> IS ASSIGNED.
            lx_vbuk =  <fs_vbuk>.
          ENDIF. " IF <fs_vbuk> IS ASSIGNED

          CALL FUNCTION 'ZOTC_ORDER_WF'
            EXPORTING
              i_vbeln         = lx_vbak-vbeln
              i_xvbak         = lx_vbak
              i_vbuk          = lx_vbuk
            IMPORTING
*<--- begin of insert for defect #8327 on 21.02.2019 by u101779
              e_ret_ord_flag  = lv_ret_ord_flag
*---> end of insert for defect #8327 on 21.02.2019 by u101779
              e_no_trigger_wf = lv_no_trigger_wf
            TABLES
              t_xvbap         = li_vbap
              t_xvbfa         = li_vbfa.

          IF lv_no_trigger_wf IS NOT INITIAL.
            RAISE no_wf_trigger.
          ENDIF. " IF lv_no_trigger_wf IS NOT INITIAL

*Raise exception for return order change
          READ TABLE li_status  WITH KEY criteria = lc_no_charg
                                        sel_low  = lx_vbak-auart
                                        BINARY SEARCH  TRANSPORTING NO FIELDS.

* if it's a return order and the flag is not populated
          IF ( sy-subrc IS NOT INITIAL ) AND ( lv_ret_ord_flag IS INITIAL ).
            RAISE no_wf_trigger.
          ENDIF. " IF ( sy-subrc IS NOT INITIAL ) AND ( lv_ret_ord_flag IS INITIAL )

        ENDIF. " IF <fs_vbak> IS ASSIGNED
*---> End of Insert for Defect #8327 on 08.02.2019 by U101779

      ENDIF. " IF sy-subrc IS INITIAL

    ENDIF. " IF sy-subrc IS INITIAL

  ENDIF. " IF objkey IS NOT INITIAL

ENDFUNCTION.
