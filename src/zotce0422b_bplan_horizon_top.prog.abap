*&---------------------------------------------------------------------*
*&  Include           ZOTCE0422B_BPLAN_HORIZON_TOP
*&---------------------------------------------------------------------*
***********************************************************************************
* PROGRAM    :  ZOTCE0422B_BILLINGPLAN_HORIZON                                    *
* TITLE      :  Wrapper to feed sales orders/billing plans to standard SAP program*
* DEVELOPER  :  Amlan J Mohapatra                                                 *
* OBJECT TYPE:  REPORT                                                            *
* SAP RELEASE:  SAP ECC 6.0                                                       *
*---------------------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0422_BILLING_PLAN_HORIZON_WRAPPER_for_V.07             *
*---------------------------------------------------------------------------------*
* DESCRIPTION: This report is a wrapper program for Transaction V.07 for reducing *
*              the credit exposure up to the next 'billing due date'              *
*---------------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                           *
*=================================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                                     *
* =========== =======  ========== ================================================*
* 22-Oct-2018 AMOHAPA  E1DK939308 SCTASK0750474:INITIAL DEVELOPMENT FOR R5 RELEASE*
*&--------------------------------------------------------------------------------*

TYPE-POOLS: slis.

DATA: gv_fpart TYPE fpart,      "Global variable for Billing/Invoicing Plan Type
      gv_fplnr TYPE fplnr,      "Globalvariable for Billing Plan Number / Invoicing Plan Number
      gv_vbeln TYPE vbak-vbeln, "Global variable for Sales and Distribution Document Number
      gv_endat TYPE endat_fp,   "Global variable for End date billing plan/invoice plan
      gv_email TYPE ad_smtpadr. "Global variable for Mail id

TYPES: BEGIN OF ty_fpla,
         fplnr  TYPE fplnr,                                         " Billing plan number / invoicing plan number
         fpart  TYPE fpart,                                         " Billing/Invoicing Plan Type
         endat  TYPE endat_fp,                                      " End date billing plan/invoice plan
         vbeln  TYPE vbeln,                                         " Sales and Distribution Document Number
       END OF ty_fpla,

       BEGIN OF ty_log,
         vbeln    TYPE vbeln,                                       " Sales and Distribution Document Number
         text     TYPE natxt,                                       " Message Text
         vkorg    TYPE vkorg,                                       " Sales Organization
         auart    TYPE auart,                                       " Sales Document Type
       END OF ty_log,

       BEGIN OF ty_fplt,
       fplnr  TYPE fplnr,                                           " Billing plan number / invoicing plan number
       fpltr  TYPE fpltr,                                           " Item for billing plan/invoice plan/payment cards
       count  TYPE i,                                               " 2 byte integer (signed)
       update TYPE flag,                                            " Flag
       END OF ty_fplt,

       ty_t_fpla   TYPE STANDARD TABLE OF ty_fpla   INITIAL SIZE 0, "Table type for FPLA
       ty_t_log    TYPE STANDARD TABLE OF ty_log    INITIAL SIZE 0, "Table type for final
       ty_t_fplt   TYPE STANDARD TABLE OF ty_fplt   INITIAL SIZE 0, "Table type for FPLT
       ty_t_submit TYPE STANDARD TABLE OF rsparams  INITIAL SIZE 0. " ABAP: General Structure for PARAMETERS and SELECT-OPTIONS

DATA: i_fpla        TYPE STANDARD TABLE OF ty_fpla  INITIAL SIZE 0, "Global table for FPLA
      i_fplt_before TYPE STANDARD TABLE OF ty_fplt INITIAL SIZE 0,  "Gloabl table for FPLT
      i_fplt_after  TYPE STANDARD TABLE OF ty_fplt INITIAL SIZE 0,  "Global table for FPLT
      i_log         TYPE STANDARD TABLE OF ty_log   INITIAL SIZE 0, "Gloabl table for final
      i_fieldcat    TYPE slis_t_fieldcat_alv,                       " Fieldcatalog Internal tab
      i_listheader  TYPE slis_t_listheader.                         " List header internal tab
