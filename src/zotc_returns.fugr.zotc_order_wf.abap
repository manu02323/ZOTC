***********************************************************************
* Function Module : ZOTC_ORDER_WF                                     *
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
* 10-Feb-2019 U101779  E1DK940472  Defect 8327 Upate logic for order  *
*&--------------------------------------------------------------------*

FUNCTION zotc_order_wf.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_VBELN) TYPE  VBELN_VA
*"     REFERENCE(I_XVBAK) TYPE  VBAK
*"     REFERENCE(I_VBUK) TYPE  VBUK
*"  EXPORTING
*"     REFERENCE(E_RET_ORD_FLAG) TYPE  FLAG
*"     REFERENCE(E_NOCHARGE_FLAG) TYPE  FLAG
*"     REFERENCE(E_NOCHARGE_CREATE) TYPE  FLAG
*"     REFERENCE(E_NO_TRIGGER_WF) TYPE  FLAG
*"  TABLES
*"      T_XVBAP STRUCTURE  VBAPVB OPTIONAL
*"      T_XVBFA STRUCTURE  VBFAVB OPTIONAL
*"----------------------------------------------------------------------

*-- Data declaration
  CONSTANTS:
    lc_null     TYPE char4         VALUE 'NULL',         " Null Criteria
    lc_h        TYPE trtyp         VALUE 'H',            " Transaction type H
    lc_v        TYPE trtyp         VALUE 'V',            " Transaction type V
    lc_i        TYPE updkz_d       VALUE 'I',            " Update indicator
    lc_u        TYPE updkz_d       VALUE 'U',            " Update indicator
    lc_auart    TYPE z_criteria    VALUE 'AUART',        " Enh. Criteria
    lc_no_charg TYPE z_criteria    VALUE 'NCAUART',      " Enh. Criteria

    lc_wdd_0024 TYPE z_enhancement VALUE 'OTC_WDD_0024'. " Enhancement No.

  FIELD-SYMBOLS:
        <fs_vbap> TYPE ANY TABLE, " table vbapvb
        <fs_t180> TYPE any.       " Structure for t180

  DATA:
        ls_t180    TYPE t180,                              " Screen Sequence Control: Transaction Default Values
        lwa_xvbap  TYPE vbapvb,                            " Document Structure for XVBAP/YVBAP
        lwa_vbap   TYPE vbapvb,                            " Document Structure for XVBAP/YVBAP
        li_vbap    TYPE STANDARD TABLE OF vbapvb,          " Document Structure for XVBAP/YVBAP
        li_stat    TYPE STANDARD TABLE OF zdev_enh_status. " Enhancement Status

*-- clear the data
  CLEAR:
      ls_t180,
      lwa_xvbap,
      lwa_vbap,
      li_stat[],
      li_vbap[],
      e_no_trigger_wf,
      e_nocharge_create,
      e_ret_ord_flag,
      e_nocharge_flag.

  UNASSIGN:
        <fs_vbap>,
        <fs_t180>.

*-- Get constants from EMI tools for the Order types
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_wdd_0024
    TABLES
      tt_enh_status     = li_stat.

  DELETE li_stat WHERE active = space.

  READ TABLE li_stat WITH KEY criteria = lc_null
                                TRANSPORTING NO FIELDS.

  IF sy-subrc IS INITIAL.

*-- sort the table
    SORT li_stat BY criteria sel_low.

*-- Proceed only for the maintained order types of return and no charge order
    READ TABLE li_stat WITH KEY criteria = lc_auart
                                sel_low  = i_xvbak-auart
                                BINARY SEARCH  TRANSPORTING NO FIELDS.

    IF sy-subrc IS INITIAL.

*-- Assign the stack data to field symbols
      ASSIGN ('(SAPMV45A)YVBAP[]') TO <fs_vbap>.
      ASSIGN ('(SAPMV45A)T180')    TO <fs_t180>.

*-- check if field symbols are assigned
      IF <fs_t180> IS ASSIGNED.

*-- Assign the data to structure
        ls_t180 = <fs_t180>.

*-- The FM should work only during Order Changes
        IF ls_t180-trtyp = lc_v.

*---- Logic for WF trigger at change mode
          IF <fs_vbap> IS ASSIGNED.

*-- Pass the values to local internal table
            li_vbap[] = <fs_vbap>.

            SORT li_vbap BY vbeln posnr.

*-- loop at the changed records and compare the values from yvbap
            LOOP AT t_xvbap INTO lwa_xvbap WHERE updkz IS NOT INITIAL.

*-- Check for the update
              IF lwa_xvbap-updkz = lc_u.

*Read changes in line item
                READ TABLE li_vbap INTO lwa_vbap
                                        WITH KEY vbeln = lwa_xvbap-vbeln
                                                 posnr = lwa_xvbap-posnr
                                                 BINARY SEARCH.

                IF   sy-subrc IS INITIAL.

*-- check the QTY change
                  IF lwa_xvbap-kwmeng NE lwa_vbap-kwmeng .
                    e_ret_ord_flag  = abap_true.
                    e_nocharge_flag = abap_true.
*-- Exit the loop once the flags are populated
                    EXIT.
                  ENDIF. " IF lwa_xvbap-kwmeng NE lwa_vbap-kwmeng

*-- check the Line item reason as blank
                  IF  lwa_xvbap-abgru NE lwa_vbap-abgru .
                    IF lwa_xvbap-abgru EQ space.
                      e_ret_ord_flag  = abap_true.
                      e_nocharge_flag = abap_true.
*-- Exit the loop once the flags are populated
                      EXIT.
                    ENDIF. " IF lwa_xvbap-abgru EQ space
                  ENDIF. " IF lwa_xvbap-abgru NE lwa_vbap-abgru

*-- check the net value
                  IF lwa_xvbap-netwr NE lwa_vbap-netwr.
                    e_ret_ord_flag  = abap_true.
                    e_nocharge_flag = abap_true.
*-- Exit the loop once the flags are populated
                    EXIT.
                  ENDIF. " IF lwa_xvbap-netwr NE lwa_vbap-netwr

                ENDIF. " IF sy-subrc IS INITIAL

*-- Check for the insert
              ELSEIF lwa_xvbap-updkz = lc_i.
*-- check the new Line item
                READ TABLE li_vbap INTO lwa_vbap
                                        WITH KEY vbeln = lwa_xvbap-vbeln
                                                 posnr = lwa_xvbap-posnr
                                                 BINARY SEARCH.

                IF sy-subrc IS NOT INITIAL.
                  e_ret_ord_flag  = abap_true.
                  e_nocharge_flag = abap_true.
*-- Exit the loop once the flags are populated
                  EXIT.
                ENDIF. " IF sy-subrc IS NOT INITIAL

              ENDIF. " IF lwa_xvbap-updkz = lc_u

            ENDLOOP. " LOOP AT t_xvbap INTO lwa_xvbap WHERE updkz IS NOT INITIAL
*-- if it's no charge WF, clear the return flag and vice versa

            READ TABLE li_stat WITH KEY   criteria = lc_no_charg
                                          sel_low  = i_xvbak-auart
                                          BINARY SEARCH  TRANSPORTING NO FIELDS.

            IF sy-subrc IS INITIAL.
              CLEAR e_ret_ord_flag.
            ENDIF. " IF sy-subrc IS INITIAL

          ENDIF. " IF <fs_vbap> IS ASSIGNED

        ELSEIF ls_t180-trtyp = lc_h. " ELSE -> IF ls_t180-trtyp = lc_h
*-- populate E_NOCHARGE_CREATE if it's create and for No order

          READ TABLE li_stat WITH KEY   criteria = lc_no_charg
                                        sel_low  = i_xvbak-auart
                                        BINARY SEARCH  TRANSPORTING NO FIELDS.

          IF sy-subrc IS INITIAL.
            e_nocharge_create = abap_true.
          ENDIF. " IF sy-subrc IS INITIAL

        ENDIF. " IF ls_t180-trtyp = lc_v

      ENDIF. " IF <fs_t180> IS ASSIGNED

    ELSE. " ELSE -> IF sy-subrc IS INITIAL

*---- do not trigger the WF for other order types
      e_no_trigger_wf = abap_true.

    ENDIF. " IF sy-subrc IS INITIAL

  ENDIF. " IF sy-subrc IS INITIAL

ENDFUNCTION.
