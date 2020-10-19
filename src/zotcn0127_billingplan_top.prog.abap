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
*&--------------------------------------------------------------------------------*
*
DATA: gv_fpart      TYPE fpart,                                                     "Global variable for Billing/Invoicing Plan Type
      gv_fplnr      TYPE fplnr,                                                     "Globalvariable for Billing Plan Number / Invoicing Plan Number
      gv_vbeln      TYPE vbak-vbeln,                                                "Global variable for Sales and Distribution Document Number
      i_fieldcat    TYPE lvc_t_fcat,
* ---> Begin of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
*      wa_tvrg     TYPE tvrg,                                                     " Rule table for indirect date determination for contracts
* ---> End of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
      go_container  TYPE REF TO cl_gui_custom_container,                        " Container for Custom Controls in the Screen Area
      go_grid       TYPE REF TO cl_gui_alv_grid,                                " ALV List Viewer
      gv_error      TYPE sy-subrc,                                               " Return Value of ABAP Statements
      gv_reciever   TYPE sy-subrc,                                               " Return Value of ABAP Statements
* ---> Begin of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
*      gv_tvrg_nicht_runden TYPE char1,                                         " Tvrg_nicht_runden of type CHAR1
* ---> End of Delete for OTC_RDD_0127 for version 1.7 changes by U101734 on 6-Dec-2018 SCTASK0754502
      i_tab         TYPE STANDARD TABLE OF zotc_s_bill_plan_out INITIAL SIZE 0, " Result
      i_t_message   TYPE STANDARD TABLE OF solisti1 INITIAL SIZE 0,              " SAPoffice: Single List with Column Length 255
      i_t_attach    TYPE STANDARD TABLE OF solisti1 INITIAL SIZE 0.               " SAPoffice: Single List with Column Length 255

CONSTANTS:
      c_tx       TYPE char13 VALUE 'ZOTC_BILLPLAN', " Tx of type CHAR13
      c_fpart    TYPE fieldname VALUE 'FPART',   " Field Name
      c_dynfield TYPE dynfnam   VALUE 'S_FPART', " Field name
      c_pvalkey  TYPE ddshpvkey VALUE ' ',       " Key for personal help
      c_org      TYPE ddbool_d  VALUE 'S',       " DD: truth value
      c_coma     TYPE char1 VALUE ',',      " Sign of type CHAR1
      c_delete   TYPE char6 VALUE 'DELETE', " Delete of type CHAR6
* ---> Begin of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 5-Dec-2018 SCTASK0754502
      c_x        TYPE char1 VALUE 'X', " X of type CHAR1
* ---> End of Insert for OTC_RDD_0127 for version 1.7 changes by U101734 on 5-Dec-2018 SCTASK0754502
      c_c        TYPE char1 VALUE 'C', " C of type CHAR1
      c_f        TYPE char1 VALUE 'F',            " F of type CHAR1
      c_saprpt   TYPE char6  VALUE 'SAPRPT', " Saprpt of type CHAR6
      c_raw      TYPE char3 VALUE 'RAW',        " Raw of type CHAR3
      c_int      TYPE char3 VALUE 'INT',        " Int of type CHAR3
      c_u        TYPE char1 VALUE 'U',            " U of type CHAR1
      c_suffix   TYPE char12 VALUE '@BIO-RAD.COM', " Suffix of type CHAR12
      c_struct_nam TYPE tabname VALUE 'ZOTC_S_BILL_PLAN_OUT', " Table Name
      c_icon1    TYPE iconname VALUE 'ICON_OKAY',   " Name of an Icon
      c_but_2    TYPE char1    VALUE '2',           " Cursor pos
      c_ans_1    TYPE char1    VALUE '1',           " Return value
      c_icon2    TYPE iconname VALUE 'ICON_CANCEL', " Name of an Icon
      c_back     TYPE char4 VALUE 'BACK', "back
      c_cancel   TYPE char4 VALUE 'CANC'. "save
