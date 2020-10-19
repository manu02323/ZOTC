*&--------------------------------------------------------------------------------*
*& Report zotcn0127_billingplan_exreport
*&--------------------------------------------------------------------------------*
***********************************************************************************
* PROGRAM    :  zotcr0127_billingplan_exreport                                    *
* TITLE      :  Billing plan exception report                                     *
* DEVELOPER  :  Trupti Raikar                                                     *
* OBJECT TYPE:  REPORT                                                            *
* SAP RELEASE:  SAP ECC 6.0                                                       *
*---------------------------------------------------------------------------------*
* WRICEF ID:    OTC_RDD_0127_BILLING_PLAN_EXCEPTION_REPORT                        *
*---------------------------------------------------------------------------------*
* DESCRIPTION: Billing plan exception report                                      *
*---------------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                           *
*=================================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                                     *
* =========== =======  ========== ================================================*
* 20-Nov-2018 U101734  E1DK939517 SCTASK0754502:INITIAL DEVELOPMENT FOR R5 RELEASE*
* 03-Dec-2018 U101734  E1DK939517 SCTASK0754502:Version 1.5  changes              *
* 05-Dec-2018 U101734  E1DK939517 SCTASK0754502:Version 1.7  changes              *
* 06-Dec-2018 U101734  E1DK939517 SCTASK0754502:Modified Version 1.7  changes     *
* 12-Dec-2018 U103062  E1DK939517 SCTASK0754502 - Defect# 7854: Addition of new   *
*                                 fields MATNR, KUNNR, WERKS, PRCTR, PSTYV, NAME1 *
*                                 in ALV Display                                  *
* 17-Dec-2018 U101734  E1DK939517 SCTASK0754502 - Defect# 7854: Addition of new   *
*                                 fields MATNR, KUNNR, WERKS, PRCTR, PSTYV, NAME1 *
*                                 in ALV Display                                  *
* 20-Dec-2018 U101734  E1DK939517 SCTASK0754502 - Version 2.1 changes             *
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_BILLING_PLAN_TYPE
*&---------------------------------------------------------------------*
*       Validating Billig Plan Type
*----------------------------------------------------------------------*
FORM f_validate_billing_plan_type .

  DATA: lv_fpart TYPE fpart. " Billing/Invoicing Plan Type

  SELECT fpart      " Billing/Invoicing Plan Type
         FROM tfpla " Billing Plan Type
         INTO lv_fpart
         UP TO 1 ROWS
         WHERE fpart IN s_fpart.
  ENDSELECT.
  IF sy-subrc EQ 0 AND lv_fpart IS INITIAL.
    MESSAGE e000 WITH 'Incorrect Billing Plan Type'(002).
  ENDIF. " IF sy-subrc EQ 0 AND lv_fpart IS INITIAL

  CLEAR lv_fpart.

ENDFORM. "f_validate_billing_plan_type
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_BILLING_PLAN_NUMBER
*&---------------------------------------------------------------------*
*       Validating Billig Plan number
*----------------------------------------------------------------------*
FORM f_validate_billing_plan_number .
  DATA: lv_fplnr TYPE fplnr. " Billing/Invoicing Plan number

  SELECT fplnr     " Billing/Invoicing Plan number
         FROM fpla " Billing Plan
         INTO lv_fplnr
         UP TO 1 ROWS
         WHERE fplnr IN s_fplnr.
  ENDSELECT.
  IF sy-subrc EQ 0 AND lv_fplnr IS INITIAL.
    MESSAGE e000 WITH 'Incorrect Billing Plan number'(047).
  ENDIF. " IF sy-subrc EQ 0 AND lv_fplnr IS INITIAL

  CLEAR lv_fplnr.
ENDFORM. " F_VALIDATE_BILLING_PLAN_NUMBER
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SALES_DOC
*&---------------------------------------------------------------------*
*       Validating sales document
*----------------------------------------------------------------------*
FORM f_validate_sales_doc .

  DATA: lv_vbeln TYPE vbeln. " Sales and Distribution Document Number

  SELECT vbeln     " Sales and Distribution Document Number
         FROM vbak " Sales Document: Header Status and Administrative Data
         INTO lv_vbeln
         UP TO 1 ROWS
         WHERE vbeln IN s_vbeln.
  ENDSELECT.

  IF sy-subrc EQ 0 AND lv_vbeln IS INITIAL.
    MESSAGE e000 WITH 'Incorrect Sales Document Number'(028).
  ENDIF. " IF sy-subrc EQ 0 AND lv_vbeln IS INITIAL
  CLEAR lv_vbeln.
ENDFORM. "f_validate_sales_doc
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_EMAIL
*&---------------------------------------------------------------------*
*       Validating EMAIL id
*----------------------------------------------------------------------*
FORM f_validate_email.

  TRANSLATE p_email TO UPPER CASE.

  IF NOT p_email CS  c_suffix.
    MESSAGE 'Please enter the valid emailid'(011) TYPE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF NOT p_email CS c_suffix


ENDFORM. "f_validate_email
*&---------------------------------------------------------------------*
*&      Form  F_F4_FPART
*&---------------------------------------------------------------------*
*       F4 help for billing type
*----------------------------------------------------------------------*

FORM f_f4_fpart.
                           "local structure for Billing Type
  TYPES: BEGIN OF lty_fpart,
         fpart TYPE fpart, " Billing/Invoicing Plan Type
         END OF lty_fpart.

  DATA: li_fpart TYPE STANDARD TABLE OF lty_fpart INITIAL SIZE 0. "Local internal table

  SELECT fpart " Billing/Invoicing Plan Type
         INTO TABLE li_fpart
         FROM tfpla.
  IF sy-subrc IS INITIAL.
 "Sort the internal table before displaying
    SORT li_fpart BY fpart.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield    = c_fpart
        pvalkey     = c_pvalkey
        dynpprog    = sy-repid
        dynpnr      = sy-dynnr
        dynprofield = c_dynfield
        value_org   = c_org
      TABLES
        value_tab   = li_fpart.
  ENDIF. " IF sy-subrc IS INITIAL

  FREE: li_fpart.
ENDFORM. " F_F4_FPART
* ---> Begin of Delete for OTC_RDD_0127 for version 2.1 changes by U101734 on 20-Dec-2018 SCTASK0754502
*&---------------------------------------------------------------------*
*&      Form  F_RETRIVE
*&---------------------------------------------------------------------*
*       Fetch resultset
*----------------------------------------------------------------------*
*FORM f_retrive_results .
*  TYPES: BEGIN OF lty_vbap,
*            vbeln TYPE vbeln_va,  " Customer number
*            posnr TYPE posnr_va,  " Customer number
*            matnr TYPE matnr,     " Material Number
*            pstyv TYPE pstyv,     " Sales document item category
*            werks TYPE werks_ext, " Plant (Own or External)
*            prctr TYPE prctr,     " Profit Center
*         END OF lty_vbap,
*
*         BEGIN OF lty_kna1,
*            kunnr TYPE kunnr,     " Customer Number
*            name1 TYPE name1_gp,  " Name 1
*         END OF lty_kna1.
*
*  DATA: lv_datum     TYPE  sy-datum, " Current Date of Application Server
** ---> Begin of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
*        lv_next_b    TYPE  sy-datum,   " Current Date of Application Server
*        lv_start     TYPE sy-datum,    " Current Date of Application Server
*        lv_stlmnt_date  TYPE sy-datum, " Current Date of Application Server
*        lx_veda      TYPE veda,        " Contract Data
** ---> End of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
*        lv_horiz     TYPE tvrg-regel, " Rule for indirect date determination
** ---> Begin of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
**        lv_dat_high  TYPE sy-datum,             " Current Date of Application Server
** ---> End of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
** ---> Begin of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 for Defect 7854 on 17-Dec-2018 SCTASK0754502
*        li_vbap     TYPE TABLE OF lty_vbap,
*        li_kna1     TYPE TABLE OF lty_kna1,
*        lwa_vbap    TYPE lty_vbap,
*        lwa_kna1    TYPE lty_kna1,
** ---> End of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 for Defect 7854 on 17-Dec-2018 SCTASK0754502
*        lwa_prev_rec TYPE zotc_s_bill_plan_out. " Bill plan exception report alv output
*
*  FIELD-SYMBOLS :
*           <lfs_wa_tmp> TYPE zotc_s_bill_plan_out. " Bill plan exception report alv output
*
*
*  IF s_fpart[] IS NOT INITIAL.
*
*    SELECT  f~vbeln " Sales and Distribution Document Number
*            f~fplnr " Billing plan number / invoicing plan number
*            f~fpart " Billing/Invoicing Plan Type
*            f~bedat " Start date for billing plan/invoice plan
*            f~endat " End date billing plan/invoice plan
*            f~horiz " Rule for Determining Horizon in Billing/Invoicing Plan
** ---> Begin of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
*            f~perio " Billing/Invoice Creation in Advance
** ---> End of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
** ---> Begin of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 5-Dec-2018 SCTASK0754502
*            f~autte " Billing/Invoice Creation in Advance
** ---> End of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 5-Dec-2018 SCTASK0754502
*            t~fpltr " Item for billing plan/invoice plan/payment cards
*            t~fkdat " Billing date for billing index and printout
*            t~fksaf " Billing status for the billing plan/invoice plan date
*            t~nfdat " Settlement date for deadline
*            t~waers " Currency Key of Credit Control Area
*            t~afdat " Billing date for billing index and printout
*            t~netwr " Net Value of the Sales Order in Document Currency
*            d~posnr " Item number of the SD document
*            b~vkorg " Sales Organization
*            b~auart " Sales Document Type
** ---> Begin of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 for Defect 7854 on 17-Dec-2018 SCTASK0754502
*            b~kunnr " Customer number
** ---> End of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 for Defect 7854 on 17-Dec-2018 SCTASK0754502
** ---> Begin of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 for Defect 7854 on 17-Dec-2018 SCTASK0754502
*** ---> Begin of Insert for OTC_RDD_0127 Defect# 7854 by U103062 on 12-Dec-2018
**            b~kunnr " Customer number
**            c~matnr " Material Number
**            c~pstyv " Sales document item category
**            c~werks " Plant (Own or External)
**            c~prctr " Profit Center
**            k~name1 " Name1
*** <--- End of Insert for OTC_RDD_0127  Defect# 7854 by U103062 on 12-Dec-2018
** ---> End of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 for Defect 7854 on 17-Dec-2018 SCTASK0754502
*            FROM fpla AS f
*            LEFT OUTER JOIN fplt AS t ON f~fplnr = t~fplnr
*            LEFT OUTER JOIN vbkd AS d ON f~vbeln = d~vbeln AND f~fplnr = d~fplnr
*            LEFT OUTER JOIN vbak AS b ON f~vbeln = b~vbeln
** ---> Begin of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 for Defect 7854 on 17-Dec-2018 SCTASK0754502
*** ---> Begin of Insert for OTC_RDD_0127 Defect# 7854 by U103062 on 12-Dec-2018
**            LEFT OUTER JOIN vbap AS c ON f~vbeln = c~vbeln
**            INNER JOIN kna1 AS k ON b~kunnr = k~kunnr AND k~loevm = space
*** <--- End of Insert for OTC_RDD_0127  Defect# 7854 by U103062 on 12-Dec-2018
** ---> End of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 for Defect 7854 on 17-Dec-2018 SCTASK0754502
*      INTO TABLE i_tab
*      WHERE f~fpart IN s_fpart
*            AND f~horiz NE space.
*
*    IF sy-subrc EQ 0.
*
*      DELETE i_tab WHERE vbeln NOT IN s_vbeln.
*
*      DELETE i_tab WHERE fplnr NOT IN s_fplnr.
*
*      IF p_endat IS NOT INITIAL.
*        DELETE i_tab WHERE endat < p_endat.
*      ENDIF. " if p_endat IS NOT INITIAL
*
*      SORT i_tab BY fpart fplnr vbeln fpltr bedat endat.
*
*      DELETE ADJACENT DUPLICATES FROM i_tab COMPARING  fpart fplnr vbeln fpltr bedat endat.
*
*      SORT i_tab BY fplnr fpltr DESCENDING.
*
*      LOOP AT i_tab ASSIGNING <lfs_wa_tmp>.
*        CLEAR : <lfs_wa_tmp>-comments.
*        IF lwa_prev_rec-fplnr IS INITIAL OR lwa_prev_rec-fplnr NE <lfs_wa_tmp>-fplnr .
** ---> Begin of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
*          lv_horiz = <lfs_wa_tmp>-horiz.
*          CALL FUNCTION 'SD_VEDA_GET_DATE'
*            EXPORTING
*              i_regel                    = lv_horiz
*              i_veda_kopf                = lx_veda
*              i_veda_pos                 = lx_veda
*              i_fkdat                    = sy-datum
*            IMPORTING
*              e_datum                    = lv_datum
*            EXCEPTIONS
*              basedate_and_cal_not_found = 1
*              basedate_is_initial        = 2
*              basedate_not_found         = 3
*              cal_error                  = 4
*              rule_not_found             = 5
*              timeframe_not_found        = 6
*              wrong_month_rule           = 7
*              OTHERS                     = 8.
*          IF sy-subrc <> 0.
** Implement suitable error handling here
*            <lfs_wa_tmp>-comments = 'Error while fetching HORIZ Date'(029).
*            CONTINUE.
*          ENDIF. " IF sy-subrc <> 0
** ---> End of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
** ---> Begin of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
**          PERFORM f_get_horizon_date USING lv_horiz
**                                           sy-datum
**                                     CHANGING lv_datum
**                                              sy-subrc.
** ---> End of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
** ---> Begin of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 5-Dec-2018 SCTASK0754502
** ---> Begin of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
**          IF <lfs_wa_tmp>-autte EQ c_x.
**            lv_datum = <lfs_wa_tmp>-nfdat + 1.
** ---> End of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
** ---> Begin of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
**Take the greater Settlement Date
*          CLEAR lv_stlmnt_date .
*          IF <lfs_wa_tmp>-nfdat > <lfs_wa_tmp>-fkdat.
*            lv_stlmnt_date = <lfs_wa_tmp>-nfdat.
*          ELSE. " ELSE -> IF <lfs_wa_tmp>-nfdat > <lfs_wa_tmp>-fkdat
*            lv_stlmnt_date = <lfs_wa_tmp>-fkdat.
*          ENDIF. " IF <lfs_wa_tmp>-nfdat > <lfs_wa_tmp>-fkdat
*
*
*          IF <lfs_wa_tmp>-autte = c_x.
*            lv_next_b = lv_stlmnt_date + 1.
** ---> End of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
*          ELSE. " ELSE -> IF <lfs_wa_tmp>-autte = c_x
** ---> End of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 5-Dec-2018 SCTASK0754502
** ---> Begin of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
**            lv_horiz = <lfs_wa_tmp>-horiz.
** ---> End of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
** ---> Begin of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
*            lv_horiz =  <lfs_wa_tmp>-perio.
*            lv_start =  lv_stlmnt_date + 1.
*            CALL FUNCTION 'SD_VEDA_GET_DATE'
*              EXPORTING
*                i_regel                    = lv_horiz
*                i_veda_kopf                = lx_veda
*                i_veda_pos                 = lx_veda
*                i_fkdat                    = lv_start
*              IMPORTING
*                e_datum                    = lv_next_b
*              EXCEPTIONS
*                basedate_and_cal_not_found = 1
*                basedate_is_initial        = 2
*                basedate_not_found         = 3
*                cal_error                  = 4
*                rule_not_found             = 5
*                timeframe_not_found        = 6
*                wrong_month_rule           = 7
*                OTHERS                     = 8.
**          IF sy-subrc <> 0.
*** Implement suitable error handling here
**          ENDIF. " IF sy-subrc <> 0
** ---> End of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
** ---> Begin of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
***       This perform logic is copied from FM SD_VEDA_GET_DATE as the FM  was unreleased.
**            PERFORM f_get_horizon_date USING lv_horiz
**                                             lv_start
**                                       CHANGING lv_next_b
**                                                sy-subrc.
** ---> End of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
*            IF sy-subrc <> 0.
*              <lfs_wa_tmp>-comments = 'Error while fetching next billing date'(049).
*              CONTINUE.
*            ENDIF. " IF sy-subrc <> 0
** ---> Begin of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 5-Dec-2018 SCTASK0754502
*          ENDIF. " IF <lfs_wa_tmp>-autte = c_x
** ---> End of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 5-Dec-2018 SCTASK0754502
*          MOVE <lfs_wa_tmp> TO lwa_prev_rec.
** ---> Begin of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 on 5-Dec-2018 SCTASK0754502
**          IF <lfs_wa_tmp>-fkdat < <lfs_wa_tmp>-nfdat.
**            lv_dat_high = <lfs_wa_tmp>-nfdat.
**          ELSE. " ELSE -> IF <lfs_wa_tmp>-fkdat < <lfs_wa_tmp>-nfdat
**            lv_dat_high =  <lfs_wa_tmp>-fkdat.
**          ENDIF. " IF <lfs_wa_tmp>-fkdat < <lfs_wa_tmp>-nfdat
**          IF lv_datum <=  lv_dat_high.
** ---> End of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 on 5-Dec-2018 SCTASK0754502
** ---> Begin of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
*** ---> Begin of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 5-Dec-2018 SCTASK0754502
**          IF lv_datum >  <lfs_wa_tmp>-endat.
*** ---> End of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 5-Dec-2018 SCTASK0754502
**            <lfs_wa_tmp>-comments = c_delete.
**          ELSE. " ELSE -> IF lv_datum <= lv_dat_high
**            <lfs_wa_tmp>-comments = 'Error, Billing plan line item needs to be added'(025).
**          ENDIF. " IF lv_datum <= lv_dat_high
** ---> End of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
** ---> Begin of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
*          IF lv_next_b <=  <lfs_wa_tmp>-endat AND lv_next_b <= lv_datum.
*            <lfs_wa_tmp>-comments = 'Error, Billing plan line item needs to be added'(025).
*          ELSE. " ELSE -> IF lv_next_b <= <lfs_wa_tmp>-endat AND lv_next_b <= lv_datum
*            <lfs_wa_tmp>-comments = c_delete.
*          ENDIF. " IF lv_next_b <= <lfs_wa_tmp>-endat AND lv_next_b <= lv_datum
** ---> End of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
*          IF <lfs_wa_tmp>-fksaf NE c_c AND <lfs_wa_tmp>-fksaf NE space.
*            IF <lfs_wa_tmp>-afdat < sy-datum.
*              IF <lfs_wa_tmp>-comments IS NOT INITIAL.
**Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
*** ---> Begin of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 for Defect 7854 on 17-Dec-2018 SCTASK0754502
*                IF <lfs_wa_tmp>-comments EQ c_delete.
*                  CLEAR <lfs_wa_tmp>-comments.
*                  <lfs_wa_tmp>-comments = 'Error, Billing plan lines are not invoiced yet'(026).
*                ELSE. " ELSE -> IF <lfs_wa_tmp>-comments EQ c_delete
*** ---> Begin of End for OTC_RDD_0127 for version 1.7 changes by U101734 for Defect 7854 on 17-Dec-2018 SCTASK0754502
*                  CONCATENATE <lfs_wa_tmp>-comments 'Error, Billing plan lines are not invoiced yet'(026) INTO <lfs_wa_tmp>-comments SEPARATED BY c_coma.
**End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
*** ---> Begin of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 for Defect 7854 on 17-Dec-2018 SCTASK0754502
*                ENDIF. " IF <lfs_wa_tmp>-comments EQ c_delete
*** ---> End of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 for Defect 7854 on 17-Dec-2018 SCTASK0754502
*              ELSE. " ELSE -> IF <lfs_wa_tmp>-comments IS NOT INITIAL
**Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
*                <lfs_wa_tmp>-comments = 'Error, Billing plan lines are not invoiced yet'(026).
**End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
*              ENDIF. " IF <lfs_wa_tmp>-comments IS NOT INITIAL
*            ENDIF. " IF <lfs_wa_tmp>-afdat < sy-datum
*          ENDIF. " IF <lfs_wa_tmp>-fksaf NE c_c AND <lfs_wa_tmp>-fksaf NE space
*        ELSE. " ELSE -> IF lwa_prev_rec-fplnr IS INITIAL OR lwa_prev_rec-fplnr NE <lfs_wa_tmp>-fplnr
*          IF <lfs_wa_tmp>-fksaf NE c_c AND <lfs_wa_tmp>-fksaf NE space.
*            IF <lfs_wa_tmp>-afdat < sy-datum.
**Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
*              <lfs_wa_tmp>-comments = 'Error, Billing plan lines are not invoiced yet'(026).
**End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
*            ELSE. " ELSE -> IF <lfs_wa_tmp>-afdat < sy-datum
*              <lfs_wa_tmp>-comments = c_delete.
*            ENDIF. " IF <lfs_wa_tmp>-afdat < sy-datum
*          ELSE. " ELSE -> IF <lfs_wa_tmp>-fksaf NE c_c AND <lfs_wa_tmp>-fksaf NE space
*            <lfs_wa_tmp>-comments = c_delete.
*          ENDIF. " IF <lfs_wa_tmp>-fksaf NE c_c AND <lfs_wa_tmp>-fksaf NE space
*          CLEAR lv_horiz.
*        ENDIF. " IF lwa_prev_rec-fplnr IS INITIAL OR lwa_prev_rec-fplnr NE <lfs_wa_tmp>-fplnr
*
*      ENDLOOP. " LOOP AT i_tab ASSIGNING <lfs_wa_tmp>
*
*      DELETE i_tab[] WHERE comments = c_delete.
*
*** ---> Begin of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 for Defect 7854 on 17-Dec-2018 SCTASK0754502
*      IF i_tab[] IS NOT INITIAL.
*        SELECT b~vbeln " Customer number
*              c~posnr  " Sales Document Item
*              c~matnr  " Material Number
*              c~pstyv  " Sales document item category
*              c~werks  " Plant (Own or External)
*              c~prctr  " Profit Center
*              FROM vbak AS b
*              LEFT OUTER JOIN vbap AS c ON b~vbeln = c~vbeln
*              INTO TABLE li_vbap
*              FOR ALL ENTRIES IN i_tab
*              WHERE b~vbeln = i_tab-vbeln.
*
*        SELECT kunnr     " Customer Number
*               name1     " Name 1
*               FROM kna1 " General Data in Customer Master
*               INTO TABLE li_kna1
*               FOR ALL ENTRIES IN i_tab
*               WHERE kunnr = i_tab-kunnr
*                     AND loevm = space.
*      ENDIF. " IF i_tab[] IS NOT INITIAL
*
*      UNASSIGN <lfs_wa_tmp>.
*      LOOP AT i_tab ASSIGNING <lfs_wa_tmp>.
*        READ TABLE li_vbap INTO lwa_vbap WITH KEY vbeln = <lfs_wa_tmp>-vbeln posnr = <lfs_wa_tmp>-posnr.
*        IF sy-subrc EQ 0.
*          <lfs_wa_tmp>-matnr = lwa_vbap-matnr.
*          <lfs_wa_tmp>-pstyv = lwa_vbap-pstyv.
*          <lfs_wa_tmp>-werks = lwa_vbap-werks.
*          <lfs_wa_tmp>-prctr = lwa_vbap-prctr.
*        ENDIF. " IF sy-subrc EQ 0
*
*        READ TABLE li_kna1 INTO lwa_kna1 WITH KEY kunnr = <lfs_wa_tmp>-kunnr.
*        IF sy-subrc EQ 0.
*          <lfs_wa_tmp>-name1 = lwa_kna1-name1.
*        ELSE. " ELSE -> IF sy-subrc EQ 0
*          CLEAR <lfs_wa_tmp>-kunnr.
*        ENDIF. " IF sy-subrc EQ 0
*        CLEAR: lwa_vbap , lwa_kna1.
*      ENDLOOP. " LOOP AT i_tab ASSIGNING <lfs_wa_tmp>
*
*** ---> End of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 for Defect 7854 on 17-Dec-2018 SCTASK0754502
*
*    ENDIF. " IF sy-subrc EQ 0
*  ENDIF. " IF s_fpart[] IS NOT INITIAL
**Begin of Insert for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
*  SORT i_tab[] BY vkorg vbeln posnr.
**End of Insert for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
*ENDFORM. " F_RETRIVE
* ---> End of Delete for OTC_RDD_0127 for version 2.1 changes by U101734 on 20-Dec-2018 SCTASK0754502
*&---------------------------------------------------------------------*
*&      Module  SHOW_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       Display ALV
*----------------------------------------------------------------------*
MODULE show_data OUTPUT.

  DATA:
      wa_layout    TYPE lvc_s_layo. " ALV control: Layout structure

  SET PF-STATUS 'STATUS_9002'.
  SET TITLEBAR 'TITLE'.

  IF go_container IS NOT INITIAL.
    CALL METHOD go_container->free.
  ENDIF. " IF go_container IS NOT INITIAL

  IF go_grid IS NOT INITIAL.
    FREE go_grid.
    FREE wa_layout.
    FREE i_fieldcat.
  ENDIF. " IF go_grid IS NOT INITIAL

  CREATE OBJECT go_container
    EXPORTING
      container_name              = 'CONTAINER'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

  CREATE OBJECT go_grid
    EXPORTING
      i_shellstyle      = 0
      i_parent          = go_container
      i_appl_events     = space
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.

  PERFORM f_alv_builv_fieldcatalog.

  wa_layout-cwidth_opt = abap_true.

  IF i_tab[] IS NOT INITIAL.

    CALL METHOD go_grid->set_table_for_first_display
      EXPORTING
        i_structure_name              = c_struct_nam
        i_default                     = abap_true
        is_layout                     = wa_layout
      CHANGING
        it_outtab                     = i_tab[]
        it_fieldcatalog               = i_fieldcat
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.

  ELSE. " ELSE -> IF i_tab[] IS NOT INITIAL
    LEAVE TO SCREEN 9000.
  ENDIF. " IF i_tab[] IS NOT INITIAL

ENDMODULE. " SHOW_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_FROM_APf9002  INPUT
*&---------------------------------------------------------------------*
*       On Exit command handler
*----------------------------------------------------------------------*
MODULE exit_from_app_9002 INPUT.
  DATA: gv_answer TYPE char1. " Answer of type CHAR1

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Exit from application'(003)           "Exit from application
      text_question         = 'Exit from application?'(004)          "Exit from application?
      text_button_1         = 'Yes'(005)                             "Yes
      icon_button_1         = c_icon1
      text_button_2         = 'No'(006)                              "No
      icon_button_2         = c_icon2
      default_button        = c_but_2
      display_cancel_button = space
      iv_quickinfo_button_1 = 'Terminate current work and quit'(007) "Terminate current work and quit
      iv_quickinfo_button_2 = 'Continue current work'(008)           "Continue current work'
    IMPORTING
      answer                = gv_answer
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

  IF sy-subrc IS INITIAL.
    IF gv_answer = c_ans_1.
      LEAVE PROGRAM.
    ENDIF. " IF gv_answer = c_ans_1
  ENDIF. " IF sy-subrc IS INITIAL

ENDMODULE. " EXIT_FROM_APf9002  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_BUIlv_FIELDCATALOG
*&---------------------------------------------------------------------*
*       Prepare ALV field catalog
*----------------------------------------------------------------------*
FORM f_alv_builv_fieldcatalog .
  DATA: lwa_fieldcat TYPE lvc_s_fcat. " ALV control: Field catalog
* ---> Begin of Insert for OTC_RDD_0127 Defect# 7854 by U103062 on 12-Dec-2018
  CONSTANTS: lc_table TYPE lvc_tname VALUE 'ZOTC_S_BILL_PLAN_OUT', " LVC tab name
             lc_kunnr TYPE lvc_fname VALUE 'KUNNR',                " ALV control: Field name of internal table field
             lc_name1 TYPE lvc_fname VALUE 'NAME1',                " ALV control: Field name of internal table field
             lc_matnr TYPE lvc_fname VALUE 'MATNR',                " ALV control: Field name of internal table field
             lc_pstyv TYPE lvc_fname VALUE 'PSTYV',                " ALV control: Field name of internal table field
             lc_werks TYPE lvc_fname VALUE 'WERKS',                " ALV control: Field name of internal table field
             lc_prctr TYPE lvc_fname VALUE 'PRCTR',                " ALV control: Field name of internal table field
             lc_nfdat TYPE lvc_fname VALUE 'NFDAT'.                " ALV control: Field name of internal table field
* <--- End of Insert for OTC_RDD_0127 Defect# 7854 by U103062 on 12-Dec-2018
  CLEAR lwa_fieldcat.
  lwa_fieldcat-fieldname = 'VKORG'.
  lwa_fieldcat-tabname = 'ZOTC_S_BILL_PLAN_OUT'.
*Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-coltext = 'Sales org'(030).
  lwa_fieldcat-col_pos = 1.
*End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-outputlen = 4.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.
  lwa_fieldcat-fieldname = 'VBELN'.
  lwa_fieldcat-tabname = 'ZOTC_S_BILL_PLAN_OUT'.
*Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-coltext = 'Sales doc no.'(031).
  lwa_fieldcat-col_pos = 2.
*End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-outputlen = 10.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.
  lwa_fieldcat-fieldname = 'POSNR'.
  lwa_fieldcat-tabname = 'ZOTC_S_BILL_PLAN_OUT'.
*Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-coltext = 'Sales order item no.'(032).
  lwa_fieldcat-col_pos = 3.
*End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-outputlen = 14.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.
* ---> Begin of Insert for OTC_RDD_0127 Defect# 7854 by U103062 on 12-Dec-2018
  CLEAR lwa_fieldcat.
  lwa_fieldcat-fieldname = lc_kunnr.
  lwa_fieldcat-tabname = lc_table.
  lwa_fieldcat-coltext = 'Sold-to party'(050).
  lwa_fieldcat-col_pos = 4.
  lwa_fieldcat-outputlen = 10.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.

  lwa_fieldcat-fieldname = lc_name1.
  lwa_fieldcat-tabname = lc_table.
  lwa_fieldcat-coltext = 'Customer Name'(055).
  lwa_fieldcat-col_pos = 5.
  lwa_fieldcat-outputlen = 10.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.

  lwa_fieldcat-fieldname = lc_matnr.
  lwa_fieldcat-tabname = lc_table.
  lwa_fieldcat-coltext = 'Material Number'(051).
  lwa_fieldcat-col_pos = 6.
  lwa_fieldcat-outputlen = 18.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.

  lwa_fieldcat-fieldname = lc_pstyv.
  lwa_fieldcat-tabname = lc_table.
  lwa_fieldcat-coltext = 'Item category'(052).
  lwa_fieldcat-col_pos = 7.
  lwa_fieldcat-outputlen = 4.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.

  lwa_fieldcat-fieldname = lc_werks.
  lwa_fieldcat-tabname = lc_table.
  lwa_fieldcat-coltext = 'Plant'(053).
  lwa_fieldcat-col_pos = 8.
  lwa_fieldcat-outputlen = 4.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.

  lwa_fieldcat-fieldname = lc_prctr.
  lwa_fieldcat-tabname = lc_table.
  lwa_fieldcat-coltext = 'Profit Center'(054).
  lwa_fieldcat-col_pos = 9.
  lwa_fieldcat-outputlen = 10.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.
* <--- End of Insert for OTC_RDD_0127 Defect# 7854 by U103062 on 12-Dec-2018

  lwa_fieldcat-fieldname = 'FPLNR'.
  lwa_fieldcat-tabname = 'ZOTC_S_BILL_PLAN_OUT'.
*Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-coltext = 'Billing plan no.'(033).
  lwa_fieldcat-col_pos = 10.
*End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-outputlen = 10.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.
  lwa_fieldcat-fieldname = 'FPART'.
  lwa_fieldcat-tabname = 'ZOTC_S_BILL_PLAN_OUT'.
*Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-coltext = 'Billing plan type'(034).
  lwa_fieldcat-col_pos = 11.
*End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-outputlen = 2.
  APPEND lwa_fieldcat TO i_fieldcat.
*Begin of insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 06-Dec-2018 SCTASK0754502
  CLEAR lwa_fieldcat.
  lwa_fieldcat-fieldname = 'PERIO'.
  lwa_fieldcat-tabname = 'ZOTC_S_BILL_PLAN_OUT'.
  lwa_fieldcat-coltext = 'Billing frequency'(048).
  lwa_fieldcat-col_pos = 12.
  lwa_fieldcat-outputlen = 2.
  APPEND lwa_fieldcat TO i_fieldcat.
*End of insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 06-Dec-2018 SCTASK0754502
  CLEAR lwa_fieldcat.
  lwa_fieldcat-fieldname = 'BEDAT'.
  lwa_fieldcat-tabname = 'ZOTC_S_BILL_PLAN_OUT'.
*Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-coltext = 'Billing plan start date'(035).
  lwa_fieldcat-col_pos = 13.
*End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-outputlen = 8.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.
  lwa_fieldcat-fieldname = 'ENDAT'.
  lwa_fieldcat-tabname = 'ZOTC_S_BILL_PLAN_OUT'.
*Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-coltext = 'Billing plan end date'(036).
  lwa_fieldcat-col_pos = 14.
*End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-outputlen = 8.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.
  lwa_fieldcat-fieldname = 'FPLTR'.
  lwa_fieldcat-tabname = 'ZOTC_S_BILL_PLAN_OUT'.
*Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-coltext = 'Billing plan Item no.'(037).
  lwa_fieldcat-col_pos = 15.
*End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-outputlen = 6.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.
  lwa_fieldcat-fieldname = 'HORIZ'.
  lwa_fieldcat-tabname = 'ZOTC_S_BILL_PLAN_OUT'.
*Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-coltext = 'Horizon'(038).
  lwa_fieldcat-col_pos = 16.
*End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-outputlen = 8.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.
* ---> Begin of Delete for OTC_RDD_0127 Defect# 7854 by U103062 on 12-Dec-2018
*  lwa_fieldcat-fieldname = 'NFDAT'.
*  lwa_fieldcat-tabname = 'ZOTC_S_BILL_PLAN_OUT'.
**Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
*  lwa_fieldcat-coltext = 'Billing plan item Date to'(040).
*  lwa_fieldcat-col_pos = 10.
**End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
*  lwa_fieldcat-outputlen = 8.
*  APPEND lwa_fieldcat TO i_fieldcat.
*  CLEAR lwa_fieldcat.
* <--- End of Delete for OTC_RDD_0127 Defect# 7854 by U103062 on 12-Dec-2018
  lwa_fieldcat-fieldname = 'FKDAT'.
  lwa_fieldcat-tabname = 'ZOTC_S_BILL_PLAN_OUT'.
*Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-coltext = 'Billing plan item Date from'(039).
  lwa_fieldcat-col_pos = 17.
*End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-outputlen = 8.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.
* ---> Begin of Insert for OTC_RDD_0127 Defect# 7854 by U103062 on 12-Dec-2018
  lwa_fieldcat-fieldname = lc_nfdat.
  lwa_fieldcat-tabname = lc_table.
  lwa_fieldcat-coltext = 'Billing plan item Date to'(040).
  lwa_fieldcat-col_pos = 18.
  lwa_fieldcat-outputlen = 8.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.
* <--- End of Insert for OTC_RDD_0127 Defect# 7854 by U103062 on 12-Dec-2018
  lwa_fieldcat-fieldname = 'AFDAT'.
  lwa_fieldcat-tabname = 'ZOTC_S_BILL_PLAN_OUT'.
*Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-coltext = 'Billing date'(041).
  lwa_fieldcat-col_pos = 19.
*End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-outputlen = 7.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.
  lwa_fieldcat-fieldname = 'FKSAF'.
  lwa_fieldcat-tabname = 'ZOTC_S_BILL_PLAN_OUT'.
*Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-coltext = 'Billing status'(042).
  lwa_fieldcat-col_pos = 20.
*End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-outputlen = 1.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.
  lwa_fieldcat-fieldname = 'WAERS'.
  lwa_fieldcat-tabname = 'ZOTC_S_BILL_PLAN_OUT'.
*Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-coltext = 'Currency'(043).
  lwa_fieldcat-col_pos = 21.
*End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-outputlen = 5.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.
  lwa_fieldcat-fieldname = 'NETWR'.
  lwa_fieldcat-tabname = 'ZOTC_S_BILL_PLAN_OUT'.
*Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-coltext = 'Net value'(044).
  lwa_fieldcat-col_pos = 22.
*End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-outputlen = 15.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.
  lwa_fieldcat-fieldname = 'AUART'.
  lwa_fieldcat-tabname = 'ZOTC_S_BILL_PLAN_OUT'.
*Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-coltext = 'Sales doc type'(046).
  lwa_fieldcat-col_pos = 23.
  lwa_fieldcat-tech = 'X'.
*End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-outputlen = 4.
  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.
  lwa_fieldcat-fieldname = 'COMMENTS'.
  lwa_fieldcat-tabname = 'ZOTC_S_BILL_PLAN_OUT'.
*Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  lwa_fieldcat-coltext = 'error msg'(045).
  lwa_fieldcat-col_pos = 24.
*End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  APPEND lwa_fieldcat TO i_fieldcat.
* ---> Begin of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 5-Dec-2018 SCTASK0754502
  CLEAR lwa_fieldcat.
  lwa_fieldcat-fieldname = 'AUTTE'.
  lwa_fieldcat-tabname = 'ZOTC_S_BILL_PLAN_OUT'.
  lwa_fieldcat-col_pos = 25.
  lwa_fieldcat-tech = 'X'.
  lwa_fieldcat-outputlen = 1.
  APPEND lwa_fieldcat TO i_fieldcat.
* <--- End    of Insert for OTC_RDD_0127 for version 1.7 changes  by U101734 on 5-Dec-2018 SCTASK0754502
ENDFORM. " F_ALV_BUIlv_FIELDCATALOG


**&---------------------------------------------------------------------*
**&      Form  BUIlv_XLS_DATA_TABLE
**&---------------------------------------------------------------------*
**       Convert result set into excel format
**----------------------------------------------------------------------*
FORM f_build_xls_data_table .

  DATA: lv_len TYPE i,        " Data:lv_len of type Integers
        lv_ini TYPE i,        " Init of type Integers
        lv_next TYPE i,       " Next of type Integers
        lv_netwr TYPE char10, " Netwr of type CHAR10
        lv_attach_str TYPE string,
        lv_attach_end TYPE string.

  FIELD-SYMBOLS :
           <lfs_wa_tmp> TYPE zotc_s_bill_plan_out. " Bill plan exception report alv output

*Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
  CONCATENATE
      'Sales org'(030)
      'Sales doc no.'(031)
      'Sales order item no.'(032)
* ---> Begin of Insert for OTC_RDD_0127 Defect# 7854 by U103062 on 12-Dec-2018
      'Sold-to party'(050)
      'Customer Name'(055)
      'Material Number'(051)
      'Item category'(052)
      'Plant'(053)
      'Profit Center'(054)
* <--- End of Insert for OTC_RDD_0127 Defect# 7854 by U103062 on 12-Dec-2018
      'Billing plan no.'(033)
      'Billing plan type'(034)
*Begin of insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 06-Dec-2018 SCTASK0754502
      'Billing frequency'(048)
*End of insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 06-Dec-2018 SCTASK0754502
      'Billing plan start date'(035)
      'Billing plan end date'(036)
      'Billing plan Item no.'(037)
      'Horizon'(038)
      'Billing plan item Date from'(039)
      'Billing plan item Date to'(040)
      'Billing date'(041)
      'Billing status'(042)
      'Currency'(043)
      'Net value'(044)
      'error msg'(045)
         INTO lv_attach_str SEPARATED BY cl_abap_char_utilities=>horizontal_tab.
*End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502

  lv_len = strlen( lv_attach_str ).
  lv_ini = 0.
* ---> Begin of Delete for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
*  lv_next = 252.
* ---> End of Delete for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
* ---> Begin of Insert for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
  lv_next = 255.
* ---> End of Insert for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
  WHILE ( lv_next < lv_len ).
    APPEND lv_attach_str+lv_ini(lv_next) TO i_t_attach.
* ---> Begin of Delete for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
*    lv_ini = lv_next + 1.
* ---> End of Delete for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
* ---> Begin of Insert for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
    lv_ini = lv_next.
* ---> End of Insert for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
* ---> Begin of Delete for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
*    lv_next = lv_next + 252.
* ---> End of Delete for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
* ---> Begin of Insert for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
    lv_next = lv_next + 255.
* ---> End of Insert for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
  ENDWHILE.

  lv_next = lv_len - lv_ini.
  CONCATENATE  lv_attach_str+lv_ini(lv_next) cl_abap_char_utilities=>cr_lf INTO lv_attach_end.
  APPEND lv_attach_end TO i_t_attach.

  CLEAR: lv_len,
  lv_ini,
  lv_next,
  lv_attach_end,
  lv_attach_str.

  LOOP AT i_tab ASSIGNING <lfs_wa_tmp>.
    lv_netwr = <lfs_wa_tmp>-netwr.

*Begin of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502
    CONCATENATE
        <lfs_wa_tmp>-vkorg
        <lfs_wa_tmp>-vbeln
        <lfs_wa_tmp>-posnr
* ---> Begin of Insert for OTC_RDD_0127 Defect# 7854 by U103062 on 12-Dec-2018
        <lfs_wa_tmp>-kunnr
        <lfs_wa_tmp>-name1
        <lfs_wa_tmp>-matnr
        <lfs_wa_tmp>-pstyv
        <lfs_wa_tmp>-werks
        <lfs_wa_tmp>-prctr
* <--- End of Insert for OTC_RDD_0127 Defect# 7854 by U103062 on 12-Dec-2018
        <lfs_wa_tmp>-fplnr
        <lfs_wa_tmp>-fpart
*Begin of insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 06-Dec-2018 SCTASK0754502
        <lfs_wa_tmp>-perio
*End of insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 06-Dec-2018 SCTASK0754502
        <lfs_wa_tmp>-bedat
        <lfs_wa_tmp>-endat
        <lfs_wa_tmp>-fpltr
        <lfs_wa_tmp>-horiz
* ---> Begin of Delete for OTC_RDD_0127 Defect# 7854 by U103062 on 12-Dec-2018
*        <lfs_wa_tmp>-nfdat
* <--- End of Delete for OTC_RDD_0127 Defect# 7854 by U103062 on 12-Dec-2018
        <lfs_wa_tmp>-fkdat
* ---> Begin of Insert for OTC_RDD_0127 Defect# 7854 by U103062 on 12-Dec-2018
        <lfs_wa_tmp>-nfdat
* <--- End of Insert for OTC_RDD_0127 Defect# 7854 by U103062 on 12-Dec-2018
        <lfs_wa_tmp>-afdat
        <lfs_wa_tmp>-fksaf
        <lfs_wa_tmp>-waers
        lv_netwr
        <lfs_wa_tmp>-comments
           INTO lv_attach_str SEPARATED BY cl_abap_char_utilities=>horizontal_tab.
*End of change for OTC_RDD_0127 for version 1.5 changes by U101734 on 03-Dec-2018 SCTASK0754502

    lv_len = strlen( lv_attach_str ).
    lv_ini = 0.
* ---> Begin of Delete for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
*  lv_next = 252.
* ---> End of Delete for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
* ---> Begin of Insert for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
  lv_next = 255.
* ---> End of Insert for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
    WHILE ( lv_next < lv_len ).
      APPEND lv_attach_str+lv_ini(lv_next) TO i_t_attach.
* ---> Begin of Delete for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
*    lv_ini = lv_next + 1.
* ---> End of Delete for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
* ---> Begin of Insert for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
    lv_ini = lv_next.
* ---> End of Insert for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
* ---> Begin of Delete for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
*    lv_next = lv_next + 252.
* ---> End of Delete for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
* ---> Begin of Insert for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
    lv_next = lv_next + 255.
* ---> End of Insert for OTC_RDD_0127 by U101734 on version 2.1 changes on 20-Dec-2018 SCTASK0754502
    ENDWHILE.

    lv_next = lv_len - lv_ini.
    CONCATENATE  lv_attach_str+lv_ini(lv_next) cl_abap_char_utilities=>cr_lf INTO lv_attach_end.
    APPEND lv_attach_end TO i_t_attach.

    CLEAR: lv_len,
    lv_ini,
    lv_next,
    lv_attach_end,
    lv_attach_str.
  ENDLOOP. " LOOP AT i_tab ASSIGNING <lfs_wa_tmp>

ENDFORM. " BUIlv_XLS_DATA_TABLE
*&---------------------------------------------------------------------*
*&      Form  SEND_FILE_AS_EMAIL_ATTACHMENT
*&---------------------------------------------------------------------*
*       Prepare email with attachment
*----------------------------------------------------------------------*
*          ->fp_email
*          ->fp_mtitle
*          ->fp_format
*          ->fp_filename
*          ->fp_attdescription
*          ->fp_sender_address
*          ->fp_sender_addres_type
*          <->fp_ch_error
*          <->fp_ch_reciever.
*----------------------------------------------------------------------*
FORM f_send_file_as_email_attachmt USING  fp_email TYPE ad_smtpadr      " E-Mail Address
                                          fp_mtitle TYPE string
                                          fp_format TYPE string
                                          fp_filename TYPE string
                                          fp_attdescription TYPE string
                                          fp_sender_address TYPE string
                                          fp_sender_addres_type TYPE string
                                 CHANGING fp_ch_error TYPE sy-subrc     " Return Value of ABAP Statements
                                          fp_ch_reciever TYPE sy-subrc. " Return Value of ABAP Statements

  DATA:
        lv_len      TYPE i,                              "lv_len of type Integers
        lv_mtitle TYPE sodocchgi1-obj_descr,             " Short description of contents
        lv_email TYPE  so_recname,                       " SAPoffice: Name of the recipient of a document (also ext.)
        lv_format TYPE  so_obj_tp ,                      " Code for document class
        lv_attdescription TYPE  so_obj_nam ,             " Name of document, folder or distribution list
        lv_attfilename TYPE  so_obj_des ,                " Short description of contents
        lv_sender_address TYPE  soextreci1-receiver,     " External address (SMTP/X.400...)
        lv_sender_address_type TYPE  soextreci1-adr_typ, " SAPoffice: type of address
        li_t_packing_list TYPE TABLE OF sopcklsti1,      " SAPoffice: Description of Imported Object Components
        li_t_receivers TYPE TABLE OF somlreci1,          " SAPoffice: Structure of the API Recipient List
        li_t_attachment TYPE TABLE OF solisti1,          " SAPoffice: Single List with Column Length 255
        lwa_receivers TYPE  somlreci1,                   " SAPoffice: Structure of the API Recipient List
        lwa_packing_list TYPE sopcklsti1,                " SAPoffice: Description of Imported Object Components
        lv_cnt TYPE i,                                   " Cnt of type Integers
        lwa_attach TYPE solisti1,                        " SAPoffice: Single List with Column Length 255
        lwa_doc_data TYPE sodocchgi1.                    " Data of an object which can be changed


  lv_email   = fp_email.
  lv_mtitle = fp_mtitle.
  lv_format              = fp_format.
  lv_attdescription      = fp_attdescription.
  lv_attfilename         = fp_filename.
  lv_sender_address      = fp_sender_address.
  lv_sender_address_type = fp_sender_addres_type.

* Fill the document data.
  lwa_doc_data-doc_size = 1.

* Populate the subject/generic message attributes
  lwa_doc_data-obj_langu = sy-langu.
  lwa_doc_data-obj_name  = c_saprpt.
  lwa_doc_data-obj_descr = lv_mtitle .
  lwa_doc_data-sensitivty = c_f.

* Fill the document data and get size of attachment
  CLEAR lwa_doc_data.
  READ TABLE i_t_attach INTO lwa_attach INDEX lv_cnt.
  IF sy-subrc EQ 0.
    lv_len = strlen( lwa_attach ).
    lwa_doc_data-doc_size =
       ( lv_cnt - 1 ) * 255 + lv_len.
  ENDIF. " IF sy-subrc EQ 0
  lwa_doc_data-obj_langu  = sy-langu.
  lwa_doc_data-obj_name   = c_saprpt.
  lwa_doc_data-obj_descr  = lv_mtitle.
  lwa_doc_data-sensitivty = c_f.
  CLEAR li_t_attachment.
  REFRESH li_t_attachment.
  li_t_attachment[] = i_t_attach[].

* Describe the body of the message
  CLEAR lwa_packing_list.
  lwa_packing_list-transf_bin = space.
  lwa_packing_list-head_start = 1.
  lwa_packing_list-head_num = 0.
  lwa_packing_list-body_start = 1.
  DESCRIBE TABLE i_t_message LINES lwa_packing_list-body_num.
  lwa_packing_list-doc_type = c_raw.
  APPEND lwa_packing_list TO li_t_packing_list.

* Create attachment notification
  lwa_packing_list-transf_bin = c_x.
  lwa_packing_list-head_start = 1.
  lwa_packing_list-head_num   = 1.
  lwa_packing_list-body_start = 1.

  DESCRIBE TABLE li_t_attachment LINES lwa_packing_list-body_num.
  lwa_packing_list-doc_type   =  lv_format.
  lwa_packing_list-obj_descr  =  lv_attdescription.
  lwa_packing_list-obj_name   =  lv_attfilename.
  lwa_packing_list-doc_size   =  lwa_packing_list-body_num * 255.
  APPEND lwa_packing_list TO li_t_packing_list.

* Add the recipients email address
  CLEAR lwa_receivers.
  lwa_receivers-receiver = lv_email.
  lwa_receivers-rec_type = c_u.
  lwa_receivers-com_type = c_int.
  lwa_receivers-notif_del = c_x.
  lwa_receivers-notif_ndel = c_x.
  APPEND lwa_receivers TO li_t_receivers.

  CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
    EXPORTING
      document_data              = lwa_doc_data
      put_in_outbox              = c_x
      sender_address             = lv_sender_address
      sender_address_type        = lv_sender_address_type
      commit_work                = c_x
    TABLES
      packing_list               = li_t_packing_list
      contents_bin               = li_t_attachment
      contents_txt               = i_t_message
      receivers                  = li_t_receivers
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.

* Populate zerror return code
  fp_ch_error = sy-subrc.

* Populate zreceiver return code
  LOOP AT li_t_receivers INTO lwa_receivers.
    fp_ch_reciever = lwa_receivers-retrn_code.
  ENDLOOP. " LOOP AT li_t_receivers INTO lwa_receivers
ENDFORM. "SEND_FILE_AS_EMAIL_ATTACHMENT

*&---------------------------------------------------------------------*
*&      Form  INITIATE_MAIL_EXECUTE_PROGRAM
*&---------------------------------------------------------------------*
*       Instructs mail send program for SAPCONNECT to send email.
*----------------------------------------------------------------------*
FORM f_initiate_mail_execute_prog.
  CONSTANTS:
       c_int TYPE char3 VALUE 'INT'. " Int of type CHAR3

  WAIT UP TO 2 SECONDS.
  SUBMIT rsconn01 WITH mode = c_int
                AND RETURN.
ENDFORM. " INITIATE_MAIL_EXECUTE_PROGRAM

*&---------------------------------------------------------------------*
*&      Form  POPULATE_EMAIL_MESSAGE_BODY
*&---------------------------------------------------------------------*
*       Prepare email body
*----------------------------------------------------------------------*
FORM f_populate_email_msg_body .
  DATA:  lwa_message TYPE solisti1. " SAPoffice: Single List with Column Length 255

  lwa_message-line = 'Please find attached a list records'(024).
  APPEND lwa_message TO i_t_message.
ENDFORM. " POPULATE_EMAIL_MESSAGE_BODY
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
*       User command handler
*----------------------------------------------------------------------*
MODULE user_command_9002 INPUT.
* To go back to previous screen
  CASE sy-ucomm.
    WHEN c_back.
*      LEAVE TO TRANSACTION c_tx.  " Defect 8147
       LEAVE to screen 0.  " Defect 8147
* to cancel the present process
    WHEN c_cancel.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE. " USER_COMMAND_9002  INPUT
* ---> Begin of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
**&---------------------------------------------------------------------*
**&      Form  F_GET_HORIZON_DATE
**&---------------------------------------------------------------------*
**       This perform logic is copied from FM SD_VEDA_GET_DATE as the FM
**       was unreleased.
**----------------------------------------------------------------------*
**  -->  fp_regel
**  <--  fp_ch_datum
**  <--  fp_sy_subrc
**----------------------------------------------------------------------*
*FORM f_get_horizon_date USING fp_regel TYPE tvrg-regel       " Rule for indirect date determination
*                              fp_datum TYPE sy-datum         " Current Date of Application Server
*                        CHANGING fp_ch_datum TYPE sy-datum   " Current Date of Application Server
*                                 fp_sy_subrc TYPE sy-subrc . " Current Date of Application Server
*
*  DATA:
*        lwa_veda_pos TYPE  veda. " Contract Data
*
** Lesen der Regeldaten.
*  PERFORM f_tvrg_select USING    fp_regel
*                               space
*                      CHANGING sy-subrc.
*  IF sy-subrc EQ 0.
**   Ermittlung des Datums zur Regel.
*    IF wa_tvrg-vkopo = space.
*
*      PERFORM f_datum_ermitteln USING    lwa_veda_pos-vinsdat
*                                       lwa_veda_pos-vabndat
*                                       lwa_veda_pos-vuntdat
*                                       lwa_veda_pos-vbegdat
*                                       lwa_veda_pos-venddat
*                                       lwa_veda_pos-vlaufz
*                                       lwa_veda_pos-vlauez
*                                       fp_datum
**                                       fp_regel
*                                       space
*                                       space
**                                       lwa_isu_f_datum_ermitteln "IS2ERP
*                              CHANGING sy-subrc
*                                       fp_ch_datum.
*
*    ENDIF. " IF wa_tvrg-vkopo = space
*  ELSE. " ELSE -> IF sy-subrc EQ 0
*    MOVE 1 TO sy-subrc.
*  ENDIF. " IF sy-subrc EQ 0
*
*  CASE sy-subrc.
*    WHEN 0.
*    WHEN 1.
*      fp_sy_subrc = 1.
*    WHEN 2.
*      fp_sy_subrc = 1.
*    WHEN 3.
*      fp_sy_subrc = 1.
*    WHEN 4.
*      fp_sy_subrc = 1.
*    WHEN 5.
*      fp_sy_subrc = 1.
*    WHEN 6.
*      fp_sy_subrc = 1.
*    WHEN 7.
*      fp_sy_subrc = 1.
*    WHEN OTHERS.
*  ENDCASE.
*
*ENDFORM. " F_GET_HORIZON_DATE
**&---------------------------------------------------------------------*
**&      Form  f_datum_ermitteln
**&---------------------------------------------------------------------*
**       This perform logic is copied from FM SD_VEDA_GET_DATE as the FM
**       was unreleased.
**----------------------------------------------------------------------*
**        ->fp_vinsdat
**        ->fp_vabndat
**        ->fp_vuntdat
**        ->fp_vbegdat
**        ->fp_venddat
**        ->fp_vlaufz
**        ->fp_vlauez
**        ->fp_fkdat
**        ->fp_regel
**        ->fp_inexc
**        ->fp_noadd_cal
**        ->fp_enhancement TYPE isu_datum_ermitteln " IS Erweiterungsstruktur - Form Using Parameter
**        <->fp_ch_subrc
**        <->fp_ch_datum.
**----------------------------------------------------------------------*
*FORM f_datum_ermitteln USING  fp_vinsdat TYPE  veda-vinsdat " Installation date
*                              fp_vabndat TYPE  veda-vabndat " Agreement acceptance date
*                              fp_vuntdat TYPE  veda-vuntdat " Date on which contract is signed
*                              fp_vbegdat TYPE  veda-vbegdat " Contract start date
*                              fp_venddat TYPE  veda-venddat " Contract end date
*                              fp_vlaufz  TYPE  veda-vlaufz  " Validity period of contract
*                              fp_vlauez  TYPE  veda-vlauez  " Unit of validity period of contract
*                              fp_fkdat   TYPE fpdat         " Date of issue for personal ID
*                              fp_inexc TYPE char1           " Inexc of type CHAR1
*                              fp_noadd_cal TYPE char1       " Noadd_cal of type CHAR1
*                     CHANGING fp_ch_subrc TYPE sy-subrc     " Return Value of ABAP Statements
*                              fp_ch_datum TYPE sy-datum.    " Current Date of Application Server
*
*
*  DATA: lv_datum         TYPE sy-datum. " Current Date of Application Server
*  DATA: lv_basisdatum    TYPE sy-datum. " Current Date of Application Server
*  DATA: lv_factorydate   TYPE scal-facdate. " Factory calendar: Factory date
*  DATA: lv_mtend TYPE tvrg-mtend. " Last of the month switch for date determination
**
*  fp_ch_subrc = 0.
*
** Weder Basisdatum noch Kalenderid vorhanden?
*  IF wa_tvrg-basdat IS INITIAL AND
*     wa_tvrg-perca  IS INITIAL.
*    fp_ch_subrc = 4.
*  ENDIF. " IF wa_tvrg-basdat IS INITIAL AND
*
** Basisdatum für Einstieg in Kalenderid vorhanden?
*  IF     wa_tvrg-basdat IS INITIAL.
*    fp_ch_subrc = 3.
*  ENDIF. " IF wa_tvrg-basdat IS INITIAL
*
** Berechnung des Basisdatums.
*  CASE wa_tvrg-basdat.
*    WHEN '01'. "Tagesdatum
*      lv_basisdatum = sy-datlo.
*    WHEN '02'. "Vertragsbeginn
*      IF fp_vbegdat IS INITIAL.
*        fp_ch_subrc = 2.
*        EXIT.
*      ELSE. " ELSE -> IF fp_vbegdat IS INITIAL
*        lv_basisdatum = fp_vbegdat.
*      ENDIF. " IF fp_vbegdat IS INITIAL
*    WHEN '04'. "Abnahmedatum
*      IF fp_vabndat IS INITIAL.
*        fp_ch_subrc = 2.
*        EXIT.
*      ELSE. " ELSE -> IF fp_vabndat IS INITIAL
*        lv_basisdatum = fp_vabndat.
*      ENDIF. " IF fp_vabndat IS INITIAL
*    WHEN '05'. "Installationsdatum
*      IF fp_vinsdat IS INITIAL.
*        fp_ch_subrc = 2.
*        EXIT.
*      ELSE. " ELSE -> IF fp_vinsdat IS INITIAL
*        lv_basisdatum = fp_vinsdat.
*      ENDIF. " IF fp_vinsdat IS INITIAL
*    WHEN '06'. "Vertragsunterzeichnungsdatum
*      IF fp_vuntdat IS INITIAL.
*        fp_ch_subrc = 2.
*        EXIT.
*      ELSE. " ELSE -> IF fp_vuntdat IS INITIAL
*        lv_basisdatum = fp_vuntdat.
*      ENDIF. " IF fp_vuntdat IS INITIAL
*    WHEN '07'. "Fakturadatum
*      IF fp_fkdat IS INITIAL.
*        fp_ch_subrc = 2.
*        EXIT.
*      ELSE. " ELSE -> IF fp_fkdat IS INITIAL
*        lv_basisdatum = fp_fkdat.
*      ENDIF. " IF fp_fkdat IS INITIAL
*    WHEN '08'. "VertrBeginn + VertrLaufzeit
*      IF fp_vbegdat IS INITIAL OR
*         fp_vlaufz IS INITIAL  OR
*         fp_vlauez IS INITIAL.
*        IF fp_vbegdat IS INITIAL.
**         Basisdatum nicht vorhanden
*          fp_ch_subrc = 2.
*          EXIT.
*        ELSE. " ELSE -> IF fp_vbegdat IS INITIAL
*          lv_basisdatum = fp_vbegdat. "P30K033834
*        ENDIF. " IF fp_vbegdat IS INITIAL
*      ELSE. " ELSE -> IF fp_vbegdat IS INITIAL OR
**       Nicht runden wenn Vertragsbeginn 1. ist,
**       da sonst der letzte des Folgemonats ermittelt wird
*        DATA: lv_da_date TYPE veda-vbegdat. " Contract start date
*        lv_da_date = fp_vbegdat.
*        IF lv_da_date+6(2) EQ '01'.
*          gv_tvrg_nicht_runden = 'X'.
*        ENDIF. " IF lv_da_date+6(2) EQ '01'
*
**       Ermittlung des Datums aus Basisdatum plus Zeitraum.
*        PERFORM f_zeitraum_addieren USING fp_vbegdat
*                                        fp_vlaufz
*                                        fp_vlauez
*                                        wa_tvrg-mtend
*                               CHANGING lv_basisdatum.
*
*        CLEAR gv_tvrg_nicht_runden.
*
**       1 Tag abziehen, um Vertragsende richtig darzustellen
*        lv_basisdatum = lv_basisdatum - 1.
*      ENDIF. " IF fp_vbegdat IS INITIAL OR
*
*    WHEN '09'. "Vertragsende
*      IF fp_venddat IS INITIAL.
*        fp_ch_subrc = 2.
*        EXIT.
*      ELSE. " ELSE -> IF fp_venddat IS INITIAL
*        lv_basisdatum = fp_venddat.
*      ENDIF. " IF fp_venddat IS INITIAL
*    WHEN OTHERS.
*      fp_ch_subrc = 3.
*      EXIT.
*  ENDCASE.
*
** Ermittlung des Datums aus Basisdatum plus Zeitraum.
*  MOVE wa_tvrg-mtend TO lv_mtend.
*  IF NOT wa_tvrg-perca   IS INITIAL       AND
*         wa_tvrg-basdat  EQ '07'          AND
*         fp_noadd_cal IS INITIAL.
*    CLEAR lv_mtend.
*  ENDIF. " IF NOT wa_tvrg-perca IS INITIAL AND
*  PERFORM f_zeitraum_addieren USING    lv_basisdatum
*                                     wa_tvrg-zeitr
*                                     wa_tvrg-zeite
*                                     lv_mtend
*                            CHANGING lv_datum.
*
** Ermittlung des Kalenderdatums aus dem Basisdatum, falls erwünscht.
*  IF NOT wa_tvrg-perca IS INITIAL.
*    IF wa_tvrg-basdat EQ '07' AND
*       lv_datum    EQ lv_basisdatum AND
*         fp_noadd_cal IS INITIAL.
**     Falls Basisdatum Faktura (nächstes Fakturierungsdatum im FPlan)
**     muß sich das Ergebnis ändern
*      lv_datum = lv_datum + 1.
*    ENDIF. " IF wa_tvrg-basdat EQ '07' AND
*    CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
*      EXPORTING
*        correct_option               = '+'
*        date                         = lv_datum
*        factory_calendar_id          = wa_tvrg-perca
*      IMPORTING
*        factorydate                  = lv_factorydate
*      EXCEPTIONS
*        calendar_buffer_not_loadable = 10
*        correct_option_invalid       = 11
*        date_after_range             = 12
*        date_before_range            = 13
*        date_invalid                 = 14
*        factory_calendar_not_found   = 15.
*    CASE sy-subrc.
*      WHEN 10.
*      WHEN 11.
*      WHEN 12.
*      WHEN 13.
*      WHEN 14.
*      WHEN 15.
*      WHEN OTHERS.
*    ENDCASE.
*    IF sy-subrc NE 0.
*      fp_ch_subrc = 6.
*      EXIT.
*    ENDIF. " IF sy-subrc NE 0
**   Umrechnung Nr. des Arbeitstages in Datum.
*    CALL FUNCTION 'FACTORYDATE_CONVERT_TO_DATE'
*      EXPORTING
*        factorydate                  = lv_factorydate
*        factory_calendar_id          = wa_tvrg-perca
*      IMPORTING
*        date                         = lv_datum
*      EXCEPTIONS
*        calendar_buffer_not_loadable = 16
*        factorydate_after_range      = 17
*        factorydate_before_range     = 18
*        factorydate_invalid          = 19
*        factory_calendar_id_missing  = 20
*        factory_calendar_not_found   = 21.
*    CASE sy-subrc.
*      WHEN 16.
*      WHEN 17.
*      WHEN 18.
*      WHEN 19.
*      WHEN 20.
*      WHEN 21.
*      WHEN OTHERS.
*    ENDCASE.
*    IF sy-subrc NE 0.
*      fp_ch_subrc = 6.
*      EXIT.
*    ENDIF. " IF sy-subrc NE 0
*    IF fp_noadd_cal IS INITIAL.
*      PERFORM f_tvrg_mtend_ermitteln USING lv_datum lv_datum wa_tvrg-mtend
*                                         fp_ch_subrc.
*    ENDIF. " IF fp_noadd_cal IS INITIAL
*  ELSE. " ELSE -> IF NOT wa_tvrg-perca IS INITIAL
*    IF wa_tvrg-mtend NE space.
*      PERFORM f_tvrg_mtend_ermitteln USING lv_datum fp_ch_datum wa_tvrg-mtend
*                                         fp_ch_subrc.
*      EXIT.
*    ENDIF. " IF wa_tvrg-mtend NE space
*
*    IF fp_inexc EQ space.
**     1-Tag abziehen, falls ein Zeitraum addiert wurde.
*      IF wa_tvrg-zeitr > 0.
**       nur bei positivem Zeitraum subtrahieren
*        lv_datum = lv_datum - 1.
*      ENDIF. " IF wa_tvrg-zeitr > 0
*    ENDIF. " IF fp_inexc EQ space
*  ENDIF. " IF NOT wa_tvrg-perca IS INITIAL
*
*  MOVE lv_datum TO fp_ch_datum.
*
*ENDFORM. " f_datum_ermitteln
**&---------------------------------------------------------------------*
**&      Form  f_zeitraum_addieren
**&---------------------------------------------------------------------*
**       This perform logic is copied from FM SD_VEDA_GET_DATE as the FM
**       was unreleased.
**----------------------------------------------------------------------*
**        ->fp_datum_alt
**        ->fp_laenge
**        ->fp_einheit
**        ->fp_mtend
**        <->fp_datum_neu.
**----------------------------------------------------------------------*
*FORM f_zeitraum_addieren USING  fp_datum_alt TYPE veda-vbegdat   " Contract start date
*                                fp_laenge TYPE any
*                                fp_einheit TYPE char1            " Einheit of type CHAR1
*                                fp_mtend TYPE tvrg-mtend         " Last of the month switch for date determination
*                       CHANGING fp_datum_neu TYPE veda-vbegdat . " Contract start date
*
*  CONSTANTS:
*       c_tage  TYPE tvkr-zeitraume VALUE '1',  " Time unit for period of notice
*       c_wochen TYPE tvkr-zeitraume VALUE '2', " Time unit for period of notice
*       c_monate TYPE tvkr-zeitraume VALUE '3', " Time unit for period of notice
*       c_jahre  TYPE tvkr-zeitraume VALUE '4'. " Time unit for period of notice
*
*  DATA: lv_datum TYPE sy-datum. " Current Date of Application Server
*  DATA: lv_jahre      TYPE i. " Jahre of type Integers
*  DATA: lv_monate     TYPE i. " Monate of type Integers
*  DATA: lv_monate_sum TYPE i. " Monate_sum of type Integers
*  DATA: lv_jahre_sum  TYPE i. " Jahre_sum of type Integers
*
*  lv_datum      = fp_datum_alt.
*  lv_jahre      = lv_datum(4).
*  lv_monate     = lv_datum+4(2).
*
*  CASE fp_einheit.
*    WHEN c_tage.
*      lv_datum = lv_datum + fp_laenge.
*    WHEN c_wochen.
*      lv_datum = lv_datum + fp_laenge * 7.
*    WHEN c_monate.
*      lv_monate_sum = lv_monate + fp_laenge.
*      lv_jahre_sum  = lv_monate_sum DIV 12.
*      lv_monate = lv_monate_sum MOD 12.
*      IF lv_monate = 0.
*        lv_jahre_sum = lv_jahre_sum - 1.
*        lv_monate = lv_monate + 12.
*      ENDIF. " IF lv_monate = 0
*      lv_jahre  = lv_jahre_sum + lv_jahre.
*      MOVE lv_jahre  TO lv_datum(4).
*      MOVE lv_monate TO lv_datum+4(2).
**     Korrigiert das Datum, falls der Tag größer ist wie der letzte
**     des entsprechenden Monats 31.04.1994 -> 30.04.1994
*      PERFORM f_datum_monat_pruefen USING    lv_datum
*                                  CHANGING lv_datum.
*    WHEN c_jahre.
*      lv_jahre = lv_jahre + fp_laenge.
*      MOVE lv_jahre TO lv_datum(4).
**     Korrigiert das Datum, falls der Tag größer ist wie der letzte
**     des entsprechenden Monats 31.04.1994 -> 30.04.1994
*      PERFORM f_datum_monat_pruefen USING    lv_datum
*                                  CHANGING lv_datum.
*    WHEN OTHERS.
*  ENDCASE.
*  fp_datum_neu = lv_datum.
*
*  PERFORM f_tvrg_mtend_ermitteln USING lv_datum fp_datum_neu fp_mtend
*                                     sy-subrc.
*
*
*ENDFORM. " f_zeitraum_addieren
**&---------------------------------------------------------------------*
**&      Form  f_tvrg_mtend_ermitteln
**&---------------------------------------------------------------------*
**       This perform logic is copied from FM SD_VEDA_GET_DATE as the FM
**       was unreleased.
**----------------------------------------------------------------------*
**     ->fp_datum
**     ->fp_ch_datum
**     ->fp_mtend
**     ->fp_ch_subrc.
**----------------------------------------------------------------------*
*FORM f_tvrg_mtend_ermitteln USING fp_datum TYPE sy-datum     " Current Date of Application Server
*                                  fp_ch_datum TYPE sy-datum  " Current Date of Application Server
*                                  fp_mtend TYPE tvrg-mtend   " Last of the month switch for date determination
*                                  fp_ch_subrc TYPE sy-subrc. " Return Value of ABAP Statements
*
*  DATA: lv_monat(2)      TYPE n. " Monat(2) of type Numeric Text Fields
*  DATA: lv_jahr(4)       TYPE n. " Jahr(4) of type Numeric Text Fields
*
*  CASE fp_mtend.
*    WHEN space.
*    WHEN 'A'.
**     Monatsersten ermitteln
*      fp_datum+6(2) = '01'.
*      MOVE fp_datum TO fp_ch_datum.
*    WHEN 'B'.
**     Nicht runden wenn Vertragsbeginn 1. ist,
**     da sonst der letzte des Folgemonats ermittelt wird
*      IF NOT gv_tvrg_nicht_runden IS INITIAL.
*        RETURN.
*      ENDIF. " IF NOT gv_tvrg_nicht_runden IS INITIAL
*
**     Monatsletzten ermitteln
*      lv_monat = fp_datum+4(2).
*      lv_jahr  = fp_datum(4).
*      lv_jahr  = lv_jahr + ( ( lv_monat + 1 ) DIV 13 ).
*      lv_monat = ( lv_monat + 1 ) MOD 12.
*      IF lv_monat EQ 0.
*        lv_monat = 12.
*      ENDIF. " IF lv_monat EQ 0
*      fp_datum(4)   = lv_jahr.
*      fp_datum+4(2) = lv_monat.
*      fp_datum+6(2) = '01'.
*      fp_datum = fp_datum - 1.
*      MOVE fp_datum TO fp_ch_datum.
*    WHEN OTHERS.
*      fp_ch_subrc = 7.
*  ENDCASE.
*
*
*ENDFORM. " f_tvrg_mtend_ermitteln
**&      Form  f_datum_monat_pruefen
**&---------------------------------------------------------------------*
**       This perform logic is copied from FM SD_VEDA_GET_DATE as the FM
**       was unreleased.
**----------------------------------------------------------------------*
**      -->fp_datum_alt
**      <--fp_datum_neu
**----------------------------------------------------------------------*
*FORM f_datum_monat_pruefen USING fp_datum_alt TYPE sy-datum " Current Date of Application Server
*                      CHANGING fp_datum_neu TYPE sy-datum.  " Current Date of Application Server
*
*  DATA: lv_datum     TYPE sy-datum. " Current Date of Application Server
*  DATA: lv_jahr      TYPE i. " Jahr of type Integers
*  DATA: lv_jahr_neu  TYPE i. " Jahr_neu of type Integers
*  DATA: lv_monat     TYPE i. " Monat of type Integers
*  DATA: lv_monat_neu TYPE i. " Monat_neu of type Integers
*  DATA: lv_tag       TYPE i. " Tag of type Integers
*  DATA: lv_erster    TYPE i VALUE 1. " Erster of type Integers
*  DATA: lv_letzter   TYPE i. " Letzter of type Integers
*
** Monat und Tag des zu prüfenden Datums separieren.
*  lv_datum = fp_datum_alt.
*  lv_jahr  = lv_datum(4).
*  lv_monat = lv_datum+4(2).
*  lv_tag   = lv_datum+6(2).
** Ermittlung des Monatsletzten.
*  lv_jahr_neu  = lv_jahr.
*  lv_monat_neu = lv_monat + 1.
*  IF lv_monat_neu EQ 13.
*    lv_monat_neu = 1.
*    lv_jahr_neu  = lv_jahr_neu + 1.
*  ENDIF. " IF lv_monat_neu EQ 13
*  MOVE lv_jahr_neu  TO lv_datum(4).
*  MOVE lv_monat_neu TO lv_datum+4(2).
*  MOVE lv_erster    TO lv_datum+6(2).
*  lv_datum = lv_datum - 1.
*  MOVE lv_datum+6(2) TO lv_letzter.
*
** Falls Tag des zu prüfenden Datums kleiner gleich dem Monatsletzter
** ist, wird dieser Tag gesetzt, sonst der Monatsletzte.
*  IF lv_tag LE lv_letzter.
*    lv_datum+6(2) = lv_tag.
*  ELSE. " ELSE -> IF lv_tag LE lv_letzter
*    lv_datum+6(2) = lv_letzter.
*  ENDIF. " IF lv_tag LE lv_letzter
*  fp_datum_neu = lv_datum.
*
*ENDFORM. " f_datum_monat_pruefen
**&---------------------------------------------------------------------*
**&      Form  f_tvrg_select
**&---------------------------------------------------------------------*
**       This perform logic is copied from FM SD_VEDA_GET_DATE as the FM
**       was unreleased.
**----------------------------------------------------------------------*
**      -->fp_regel
**      -->fp_error
**      <--fp_subrc
**----------------------------------------------------------------------*
*FORM f_tvrg_select USING  fp_regel TYPE tvrg-regel " Rule for indirect date determination
*                          fp_error TYPE char1      " Error of type CHAR1
*                 CHANGING fp_subrc TYPE sy-subrc.  " Return Value of ABAP Statements
*  SELECT SINGLE * FROM tvrg  INTO wa_tvrg WHERE regel = fp_regel.
*  IF sy-subrc NE 0.
*    CLEAR: wa_tvrg.
*    IF fp_error EQ 'X'.
*      MESSAGE e000 WITH 'Error while fetching HORIZ Date'(029) fp_regel.
*    ELSE. " ELSE -> IF fp_error EQ 'X'
*      fp_subrc = 4.
*    ENDIF. " IF fp_error EQ 'X'
*  ENDIF. " IF sy-subrc NE 0
*
*ENDFORM. "f_tvrg_select
* ---> End of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
* ---> Begin of Insert for OTC_RDD_0127 for version 2.1 changes by U101734 on 20-Dec-2018 SCTASK0754502
*&---------------------------------------------------------------------*
*&      Form  F_RETRIVE_RECORDS
*&---------------------------------------------------------------------*
FORM f_retrive_records .
  TYPES: BEGIN OF lty_vbap,
            vbeln TYPE vbeln_va,      " Customer number
            posnr TYPE posnr_va,      " Customer number
            matnr TYPE matnr,         " Material Number
            pstyv TYPE pstyv,         " Sales document item category
            werks TYPE werks_ext,     " Plant (Own or External)
            prctr TYPE prctr,         " Profit Center
         END OF lty_vbap,

         BEGIN OF lty_kna1,
            kunnr TYPE kunnr,         " Customer Number
            name1 TYPE name1_gp,      " Name 1
         END OF lty_kna1,

          BEGIN OF lty_fpla,
               vbeln  TYPE  vbeln,    " Sales and Distribution Document Number
               fplnr  TYPE  fplnr,    " Billing plan number / invoicing plan number
               fpart  TYPE  fpart,    " Billing/Invoicing Plan Type
               bedat  TYPE  bedat_fp, " Start date for billing plan/invoice plan
               endat  TYPE  endat_fp, " End date billing plan/invoice plan
               horiz  TYPE  horiz_fp, " Rule for Determining Horizon in Billing/Invoicing Plan
               perio  TYPE  perio_fp, " Rule for Origin of Next Billing/Invoice Date
               autte  TYPE  autte,    " Billing/Invoice Creation in Advance
           END OF lty_fpla,

           BEGIN OF lty_fplt,
              fplnr  TYPE  fplnr,     " Billing plan number / invoicing plan number
              fpltr TYPE  fpltr,      " Item for billing plan/invoice plan/payment cards
              fkdat TYPE  fkdat,      " Billing date for billing index and printout
              fksaf TYPE  fksaf,      " Billing status for the billing plan/invoice plan date
              nfdat TYPE  nfdat,      " Settlement date for deadline
              waers TYPE  waers,      " Currency Key
              afdat TYPE  fkdat,      " Billing date for billing index and printout
              netwr TYPE  netwr_ap,   " Net value of the order item in document currency
           END OF lty_fplt,

           BEGIN OF lty_vbkd,
             vbeln TYPE vbeln,        " Sales and Distribution Document Number
             fplnr TYPE fplnr,        " Billing plan number / invoicing plan number
             posnr TYPE posnr,        " Item number of the SD document
           END OF lty_vbkd,

           BEGIN OF lty_vbak,
             vbeln TYPE vbeln,        " Sales and Distribution Document Number
             vkorg TYPE vkorg,        " Sales Organization
             auart TYPE auart,        " Sales Document Type
             kunnr TYPE kunnr,        " Customer Number
           END OF lty_vbak.

  DATA: li_fpla TYPE STANDARD TABLE OF lty_fpla,
        lwa_fpla TYPE lty_fpla,
        li_fplt TYPE STANDARD TABLE OF  lty_fplt,
        lwa_fplt TYPE lty_fplt,
        li_vbkd TYPE STANDARD TABLE OF  lty_vbkd,
        lwa_vbkd TYPE lty_vbkd,
        li_vbak TYPE STANDARD TABLE OF  lty_vbak,
        lwa_vbak TYPE lty_vbak,
        lwa_itab TYPE zotc_s_bill_plan_out,     " Bill plan exception report alv output
        lv_datum     TYPE  sy-datum,            " Current Date of Application Server
        lv_next_b    TYPE  sy-datum,            " Current Date of Application Server
        lv_start     TYPE sy-datum,             " Current Date of Application Server
        lv_stlmnt_date  TYPE sy-datum,          " Current Date of Application Server
        lx_veda      TYPE veda,                 " Contract Data
        lv_horiz     TYPE tvrg-regel,           " Rule for indirect date determination
        li_vbap     TYPE STANDARD TABLE OF lty_vbap,
        li_kna1     TYPE STANDARD TABLE OF  lty_kna1,
        lwa_vbap    TYPE lty_vbap,
        lwa_kna1    TYPE lty_kna1,
        lv_tmp_date type sy-datum,
        lwa_prev_rec TYPE zotc_s_bill_plan_out. " Bill plan exception report alv output

  FIELD-SYMBOLS :
           <lfs_wa_tmp> TYPE zotc_s_bill_plan_out. " Bill plan exception report alv output

  SELECT
          vbeln     " Sales and Distribution Document Number
          fplnr     " Billing plan number / invoicing plan number
          fpart     " Billing/Invoicing Plan Type
          bedat     " Start date for billing plan/invoice plan
          endat     " End date billing plan/invoice plan
          horiz     " Rule for Determining Horizon in Billing/Invoicing Plan
          perio     " Billing/Invoice Creation in Advance
          autte     " Billing/Invoice Creation in Advance
          FROM fpla " Billing Plan
      INTO TABLE li_fpla
      WHERE     fplnr IN s_fplnr
            AND fpart IN s_fpart
            AND horiz NE space
            AND vbeln IN s_vbeln.


  IF p_endat IS NOT INITIAL.
    DELETE li_fpla WHERE endat < p_endat.
    SORT li_fpla BY fplnr.
  ENDIF. " IF p_endat IS NOT INITIAL

  IF li_fpla[] IS NOT INITIAL.
    SELECT  fplnr     " Billing plan number / invoicing plan number
            fpltr     " Item for billing plan/invoice plan/payment cards
            fkdat     " Billing date for billing index and printout
            fksaf     " Billing status for the billing plan/invoice plan date
            nfdat     " Settlement date for deadline
            waers     " Currency Key of Credit Control Area
            afdat     " Billing date for billing index and printout
            netwr     " Net Value of the Sales Order in Document Currency
            FROM fplt " Billing Plan: Dates
            INTO TABLE li_fplt
            FOR ALL ENTRIES IN li_fpla
            WHERE fplnr = li_fpla-fplnr.
  ENDIF. " IF li_fpla[] IS NOT INITIAL

  LOOP AT li_fplt INTO lwa_fplt.
    READ TABLE li_fpla INTO lwa_fpla WITH  KEY fplnr = lwa_fplt-fplnr
                                               BINARY SEARCH.
    IF sy-subrc EQ 0.
      lwa_itab-vbeln = lwa_fpla-vbeln.
      lwa_itab-fplnr = lwa_fpla-fplnr.
      lwa_itab-fpart = lwa_fpla-fpart.
      lwa_itab-bedat = lwa_fpla-bedat.
      lwa_itab-endat = lwa_fpla-endat.
      lwa_itab-horiz = lwa_fpla-horiz.
      lwa_itab-perio = lwa_fpla-perio.
      lwa_itab-autte = lwa_fpla-autte.
    ENDIF. " IF sy-subrc EQ 0
    lwa_itab-fpltr = lwa_fplt-fpltr.
    lwa_itab-fkdat = lwa_fplt-fkdat.
    lwa_itab-fksaf = lwa_fplt-fksaf.
    lwa_itab-nfdat = lwa_fplt-nfdat.
    lwa_itab-waers = lwa_fplt-waers.
    lwa_itab-afdat = lwa_fplt-afdat.
    lwa_itab-netwr = lwa_fplt-netwr.
    APPEND lwa_itab TO i_tab.
  ENDLOOP. " LOOP AT li_fplt INTO lwa_fplt

*  SORT i_tab BY fpart fplnr vbeln fpltr bedat endat.
  SORT i_tab BY fplnr fpltr DESCENDING.

  LOOP AT i_tab ASSIGNING <lfs_wa_tmp>.
    CLEAR : <lfs_wa_tmp>-comments.
    IF lwa_prev_rec-fplnr IS INITIAL OR lwa_prev_rec-fplnr NE <lfs_wa_tmp>-fplnr .
      lv_horiz = <lfs_wa_tmp>-horiz.
      CALL FUNCTION 'SD_VEDA_GET_DATE'
        EXPORTING
          i_regel                    = lv_horiz
          i_veda_kopf                = lx_veda
          i_veda_pos                 = lx_veda
          i_fkdat                    = sy-datum
        IMPORTING
          e_datum                    = lv_datum
        EXCEPTIONS
          basedate_and_cal_not_found = 1
          basedate_is_initial        = 2
          basedate_not_found         = 3
          cal_error                  = 4
          rule_not_found             = 5
          timeframe_not_found        = 6
          wrong_month_rule           = 7
          OTHERS                     = 8.
      IF sy-subrc <> 0.
* Implement suitable error handling here
        <lfs_wa_tmp>-comments = 'Error while fetching HORIZ Date'(029).
        CONTINUE.
      ENDIF. " IF sy-subrc <> 0
*Take the greater Settlement Date
      CLEAR lv_stlmnt_date .
      IF <lfs_wa_tmp>-nfdat > <lfs_wa_tmp>-fkdat.
        lv_stlmnt_date = <lfs_wa_tmp>-nfdat.
      ELSE. " ELSE -> IF <lfs_wa_tmp>-nfdat > <lfs_wa_tmp>-fkdat
        lv_stlmnt_date = <lfs_wa_tmp>-fkdat.
      ENDIF. " IF <lfs_wa_tmp>-nfdat > <lfs_wa_tmp>-fkdat


      IF <lfs_wa_tmp>-autte = c_x.
        lv_next_b = lv_stlmnt_date + 1.
      ELSE. " ELSE -> IF <lfs_wa_tmp>-autte = c_x
        lv_horiz =  <lfs_wa_tmp>-perio.
        lv_start =  lv_stlmnt_date + 1.
        CALL FUNCTION 'SD_VEDA_GET_DATE'
          EXPORTING
            i_regel                    = lv_horiz
            i_veda_kopf                = lx_veda
            i_veda_pos                 = lx_veda
            i_fkdat                    = lv_start
          IMPORTING
            e_datum                    = lv_next_b
          EXCEPTIONS
            basedate_and_cal_not_found = 1
            basedate_is_initial        = 2
            basedate_not_found         = 3
            cal_error                  = 4
            rule_not_found             = 5
            timeframe_not_found        = 6
            wrong_month_rule           = 7
            OTHERS                     = 8.
        IF sy-subrc <> 0.
          <lfs_wa_tmp>-comments = 'Error while fetching next billing date'(049).
          CONTINUE.
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF <lfs_wa_tmp>-autte = c_x
      MOVE <lfs_wa_tmp> TO lwa_prev_rec.
      IF lv_next_b <=  <lfs_wa_tmp>-endat AND lv_next_b <= lv_datum.
        <lfs_wa_tmp>-comments = 'Error, Billing plan line item needs to be added'(025).
      ELSE. " ELSE -> IF lv_next_b <= <lfs_wa_tmp>-endat AND lv_next_b <= lv_datum
        <lfs_wa_tmp>-comments = c_delete.
      ENDIF. " IF lv_next_b <= <lfs_wa_tmp>-endat AND lv_next_b <= lv_datum
      IF <lfs_wa_tmp>-fksaf NE c_c AND <lfs_wa_tmp>-fksaf NE space.
        IF <lfs_wa_tmp>-afdat < sy-datum.
          IF <lfs_wa_tmp>-comments IS NOT INITIAL.
            IF <lfs_wa_tmp>-comments EQ c_delete.
              CLEAR <lfs_wa_tmp>-comments.
              <lfs_wa_tmp>-comments = 'Error, Billing plan lines are not invoiced yet'(026).
            ELSE. " ELSE -> IF <lfs_wa_tmp>-comments EQ c_delete
              CONCATENATE <lfs_wa_tmp>-comments 'Error, Billing plan lines are not invoiced yet'(026) INTO <lfs_wa_tmp>-comments SEPARATED BY c_coma.
            ENDIF. " IF <lfs_wa_tmp>-comments EQ c_delete
          ELSE. " ELSE -> IF <lfs_wa_tmp>-comments IS NOT INITIAL
            <lfs_wa_tmp>-comments = 'Error, Billing plan lines are not invoiced yet'(026).
          ENDIF. " IF <lfs_wa_tmp>-comments IS NOT INITIAL
        ENDIF. " IF <lfs_wa_tmp>-afdat < sy-datum
      ENDIF. " IF <lfs_wa_tmp>-fksaf NE c_c AND <lfs_wa_tmp>-fksaf NE space
    ELSE. " ELSE -> IF lwa_prev_rec-fplnr IS INITIAL OR lwa_prev_rec-fplnr NE <lfs_wa_tmp>-fplnr
      IF <lfs_wa_tmp>-fksaf NE c_c AND <lfs_wa_tmp>-fksaf NE space.
        IF <lfs_wa_tmp>-afdat < sy-datum.
          <lfs_wa_tmp>-comments = 'Error, Billing plan lines are not invoiced yet'(026).
        ELSE. " ELSE -> IF <lfs_wa_tmp>-afdat < sy-datum
          <lfs_wa_tmp>-comments = c_delete.
        ENDIF. " IF <lfs_wa_tmp>-afdat < sy-datum
      ELSE. " ELSE -> IF <lfs_wa_tmp>-fksaf NE c_c AND <lfs_wa_tmp>-fksaf NE space
        <lfs_wa_tmp>-comments = c_delete.
      ENDIF. " IF <lfs_wa_tmp>-fksaf NE c_c AND <lfs_wa_tmp>-fksaf NE space
      CLEAR lv_horiz.
    ENDIF. " IF lwa_prev_rec-fplnr IS INITIAL OR lwa_prev_rec-fplnr NE <lfs_wa_tmp>-fplnr

  ENDLOOP. " LOOP AT i_tab ASSIGNING <lfs_wa_tmp>

  DELETE i_tab[] WHERE comments = c_delete.

  IF i_tab[] IS NOT INITIAL.
    SELECT  vbeln     " Sales and Distribution Document Number
            fplnr     " Billing plan number / invoicing plan number
            posnr     " Item number of the SD document
            FROM vbkd " Sales Document: Business Data
            INTO TABLE li_vbkd
            FOR ALL ENTRIES IN i_tab
            WHERE vbeln = i_tab-vbeln
            AND fplnr = i_tab-fplnr.

    SELECT vbeln     " Sales Document
           vkorg     " Sales Organization
           auart     " Sales Document Type
           kunnr     " Sold-to party
           FROM vbak " Sales Document: Header Data
           INTO TABLE li_vbak
           FOR ALL ENTRIES IN i_tab
           WHERE vbeln = i_tab-vbeln.

    SELECT vbeln    " Customer number
          posnr     " Sales Document Item
          matnr     " Material Number
          pstyv     " Sales document item category
          werks     " Plant (Own or External)
          prctr     " Profit Center
          FROM vbap " Sales Document: Item Data
          INTO TABLE li_vbap
          FOR ALL ENTRIES IN i_tab
          WHERE vbeln = i_tab-vbeln.

  ENDIF. " IF i_tab[] IS NOT INITIAL

  IF li_vbak IS NOT INITIAL.
    SELECT kunnr     " Customer Number
           name1     " Name 1
           FROM kna1 " General Data in Customer Master
           INTO TABLE li_kna1
           FOR ALL ENTRIES IN li_vbak
           WHERE kunnr = li_vbak-kunnr
                 AND loevm = space.
  ENDIF. " IF li_vbak IS NOT INITIAL

  SORT li_vbkd BY vbeln fplnr.
  SORT li_vbak BY vbeln.
  SORT li_vbap BY vbeln posnr.
  SORT li_kna1 BY kunnr.

  UNASSIGN <lfs_wa_tmp>.

  LOOP AT i_tab ASSIGNING <lfs_wa_tmp>.
   lv_tmp_date = <lfs_wa_tmp>-fkdat.
   if <lfs_wa_tmp>-fkdat > <lfs_wa_tmp>-nfdat.
     <lfs_wa_tmp>-fkdat = <lfs_wa_tmp>-nfdat.
     <lfs_wa_tmp>-nfdat = lv_tmp_date.
   endif.

    READ TABLE li_vbkd INTO lwa_vbkd WITH KEY  vbeln = <lfs_wa_tmp>-vbeln   fplnr = <lfs_wa_tmp>-fplnr
                                     BINARY SEARCH.
    IF sy-subrc EQ 0.
      <lfs_wa_tmp>-posnr = lwa_vbkd-posnr.
    ENDIF. " IF sy-subrc EQ 0

    READ TABLE li_vbak INTO lwa_vbak WITH KEY  vbeln = <lfs_wa_tmp>-vbeln
                                     BINARY SEARCH.
    IF sy-subrc EQ 0.
      <lfs_wa_tmp>-vkorg = lwa_vbak-vkorg.
      <lfs_wa_tmp>-auart = lwa_vbak-auart.
      <lfs_wa_tmp>-kunnr = lwa_vbak-kunnr.
    ENDIF. " IF sy-subrc EQ 0

    READ TABLE li_vbap INTO lwa_vbap WITH KEY vbeln = <lfs_wa_tmp>-vbeln posnr = <lfs_wa_tmp>-posnr
                                     BINARY SEARCH.
    IF sy-subrc EQ 0.
      <lfs_wa_tmp>-matnr = lwa_vbap-matnr.
      <lfs_wa_tmp>-pstyv = lwa_vbap-pstyv.
      <lfs_wa_tmp>-werks = lwa_vbap-werks.
      <lfs_wa_tmp>-prctr = lwa_vbap-prctr.
    ENDIF. " IF sy-subrc EQ 0

    READ TABLE li_kna1 INTO lwa_kna1 WITH KEY kunnr = <lfs_wa_tmp>-kunnr
                                     BINARY SEARCH.
    IF sy-subrc EQ 0.
      <lfs_wa_tmp>-name1 = lwa_kna1-name1.
    ELSE. " ELSE -> IF sy-subrc EQ 0
      CLEAR <lfs_wa_tmp>-kunnr.
    ENDIF. " IF sy-subrc EQ 0
    CLEAR: lwa_vbap , lwa_kna1.
  ENDLOOP. " LOOP AT i_tab ASSIGNING <lfs_wa_tmp>



  SORT i_tab[] BY vkorg vbeln posnr.
ENDFORM. " F_RETRIVE_RECORDS
* ---> End of Insert for OTC_RDD_0127 for version 2.1 changes by U101734 on 20-Dec-2018 SCTASK0754502
