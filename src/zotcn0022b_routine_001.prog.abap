************************************************************************
* PROGRAM    :  ZOTCN0022B_ROUTINE_001                                 *
* TITLE      :  Delivery Doc to Billing Doc Copy Control Routines      *
* DEVELOPER  :  Shushant Nigam                                         *
* OBJECT TYPE:  Include Program                                        *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0022                                             *
*----------------------------------------------------------------------*
* DESCRIPTION:                                                         *
* (i)The requirement is to ensure invoice split should not happen      *
* because of the billing date. As the system time is set to UTC, the   *
* enhancement should set the billing date based on the timezone of the *
* plant it’s being shipped from.                                       *
*(ii)Since GTS is used to execute foreign trade related processes, the *
* foreign trade data determined in ECC causes unwanted splits as it is *
* always different.Hence clear the foreign trade data for Pro-Forma    *
* Invoices                                                             *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 16-APR-2013 SNIGAM   E1DK909939 Implicit Enhancement in Routine-001
* 14-DEC-2017 U034229  E1DK933165 Defect# 3776: invoice number(VBRK-VBELN)
*                                 is getting copied in PO#(VBKD-BSTKD) for
*                                 order related billing
*&---------------------------------------------------------------------*
* 19-JUN-2018 ASK  E1DK933165 Defect# 6520: As per defect 6520 we will *
*                             be commenting PO reference changes of    *
*                             the defect # 3776 and only keep the      *
*                             Foreign trade number (LIKP-EXNUM) clearing*
*                             bug fix code                             *
*&---------------------------------------------------------------------*
* 23-SEP-2019 U101779  E2DK926922 Defect# 10514- INC0511867-02 : BILLING  *
*                                 ISSUE - control the clearing of XBLNR*
*                                 based on the SO value                *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           ZOTCE0022N_ROUTINE_001
*&---------------------------------------------------------------------*
* Local Data Decleration
 DATA: lv_tzone          TYPE tznzone,       "Timezone of Plant
       lv_local_date     TYPE sy-datum,      "Local Date
       lv_timestamp      TYPE tzntstmps,     "Local Timestamp
       lv_tznzone_global TYPE tznzone.   "Global Timestamp



*--> Begin of Insert for Defect# 10514:INC0511867-02 OTC_EDD_0022 by U101779 Dated 23-SEP-2019
 DATA:
   li_stat         TYPE TABLE OF zdev_enh_status. " Enhancement Status

 CONSTANTS :
   lc_otc_edd_0022 TYPE z_enhancement VALUE 'D2_OTC_EDD_0022',   " Enhancement No.
   lc_sorg         TYPE char5         VALUE 'VKORG',             " Sales Organization
   lc_nul          TYPE char4         VALUE 'NULL'.              " Null Criteria

 CLEAR: li_stat[].

*<-- End of Insert for Defect# 10514:INC0511867-02 OTC_EDD_0022 by U101779 Dated 23-SEP-2019

*Get timezone of plant
 CALL FUNCTION 'SD_TZONE_PLANT'
   EXPORTING
     plant              = vbrp-werks   "Plant
   IMPORTING
     timezone           = lv_tzone     "timezone
   EXCEPTIONS
     missing_plant      = 1
     non_existent_plant = 2
     OTHERS             = 3.

* If no error found
 IF sy-subrc EQ 0.

*  Convert local date and time to corresponding timezone of plant.
   SELECT SINGLE tzonesys
     FROM ttzcu
     INTO lv_tznzone_global
     WHERE flagactive = abap_true.

   IF sy-subrc = 0.

     CONVERT DATE sy-datum
             TIME sy-uzeit
             INTO TIME STAMP lv_timestamp
             TIME ZONE lv_tznzone_global .

     CONVERT TIME STAMP lv_timestamp
             TIME ZONE lv_tzone
             INTO DATE lv_local_date .

*  If no error found
     IF NOT lv_local_date IS INITIAL.

*    Re-set Billing date (for billing index and printout)
       vbrk-fkdat = lv_local_date.

*--> Begin of Delete for D3_OTC_EDD_0022_Defect# 3776/6520 by U034229 on 14-Dec-2017
**    Clear foreign trade data
*       CLEAR vbrk-exnum.

* Begin of Defect 6520
* Revert back the changes of Defect 3776 as per Defect 6520
** Commented the code to avoid invoice#  getting copied in the billing document instead of PO# of sales order.

*--> Begin of Insert for Defect# 10514:INC0511867-02 OTC_EDD_0022 by U101779 Dated 23-SEP-2019
* Get SO value from EMI table
       CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
         EXPORTING
           iv_enhancement_no = lc_otc_edd_0022
         TABLES
           tt_enh_status     = li_stat.

*--- Binary Search is not needed in the li_stat as there are only few entries
* and we need to read below twice with different fields which needs sorting to be done twice.

* - Check the null criteria
       READ TABLE li_stat WITH KEY   criteria = lc_nul    "NULL
                                     active   = abap_true "X"
                                     TRANSPORTING NO FIELDS.

       IF sy-subrc IS INITIAL.

*   Use the existing criteria vkorg from EMI
         READ TABLE li_stat WITH KEY  criteria = lc_sorg
                                      sel_low = likp-vkorg
                                      active = abap_true
                                   TRANSPORTING NO FIELDS.

* Clear only if the Sorg is not maintained in the EMI table
         IF sy-subrc IS NOT INITIAL.
           CLEAR vbrk-xblnr.
         ENDIF.

       ENDIF.

       CLEAR: li_stat[].

*<-- End of Insert for Defect# 10514:INC0511867-02 OTC_EDD_0022 by U101779 Dated 23-SEP-2019

*--> Begin of Delete for Defect# 10514:INC0511867-02 OTC_EDD_0022 by U101779 Dated 23-SEP-2019
*    Clear Refernce Number
*       CLEAR vbrk-xblnr.
*<-- End of Delete for Defect# 10514:INC0511867-02 OTC_EDD_0022 by U101779 Dated 23-SEP-2019

*End of Defect 6520
*<-- End of Delete for D3_OTC_EDD_0022_Defect# 3776/6520 by U034229 on 14-Dec-2017

     ENDIF.

   ENDIF.

* Clear Local variables
   CLEAR: lv_tzone,
          lv_local_date.

 ENDIF.

* *--> Begin of Delete for D3_OTC_EDD_0022_Defect# 3776/6520 by U034229 on 14-Dec-2017
* This logic is independent of Requrement 1, so taking out of there
*    Clear foreign trade data

 CLEAR vbrk-exnum.

*<-- End of Delete for D3_OTC_EDD_0022_Defect# 3776/6520 by U034229 on 14-Dec-2017
