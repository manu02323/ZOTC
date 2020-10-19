*&---------------------------------------------------------------------*
*&  Include           ZOTCN0101B_PRICE_DATE_UPD_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0101B_PRICE_DATE_UPD_TOP                          *
* TITLE      :  Pricing Date Update Report                             *
* DEVELOPER  :  ROHIT VERMA                                            *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_EDD_0101_Pricing Date Update                       *
*----------------------------------------------------------------------*
* DESCRIPTION: This is a top include program of Report                 *
*              ZOTCR0101B_PRICE_DATE_UPD. All global declaration of    *
*              this report are declared in this include program        *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 03-Oct-2013 RVERMA   E1DK913507 INITIAL DEVELOPMENT - CR#649         *
*08-Aug-2018  AMOHAPA E1DK930340  Defect#3400(Part 2): 1)Program to be *
*                                 made to process D3 sales organization*
*                                 records with different logic from    *
*                                 existing program                     *
*                                 2) Output of Batchjob to be import   *
*                                    in an excel sheet                 *
*&---------------------------------------------------------------------*

***************************TYPES DECLARATION****************************
TYPES:
  BEGIN OF ty_vbkd,   "Sales Document: Business Data
    vbeln TYPE vbeln, "Sales Document Number
    posnr TYPE posnr, "Sales Document Item Number
    prsdt TYPE prsdt, "Pricing Date
    edatu TYPE edatu, "First Date
  END OF ty_vbkd,
*&--Table type for Business data
  ty_t_vbkd TYPE STANDARD TABLE OF ty_vbkd,

  BEGIN OF ty_log,         "Log data
    type  TYPE bapi_mtype, "Message Type
    icon  TYPE char4,      "Icon
    vbeln TYPE char10,     "Sales Document Number
    posnr TYPE char6,      "Sales Document Item Number
    msg   TYPE bapi_msg,   "Message Text
  END OF ty_log,
*&--Table type for Log data
  ty_t_log TYPE STANDARD TABLE OF ty_log,

*--> Begin of insert D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
"Declaring the Log Table structure
  BEGIN OF ty_log_d3,
   vbeln    TYPE vbeln_va, "Sales Doc Number
   posnr    TYPE posnr_va, "Sales Doc Item Number
   msg      TYPE bapi_msg, "First Date/Delivery Date
  END OF ty_log_d3,

  ty_t_logd3 TYPE STANDARD TABLE OF ty_log_d3.
*<-- End of insert D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018


***************************CONSTANT DECLARATION*************************
CONSTANTS:
  c_hash  TYPE char1   VALUE '#', "Hash
  c_msg_e TYPE char1   VALUE 'E', "Error Message Type
  c_msg_s TYPE char1   VALUE 'S', "Success Message Type
  c_updt  TYPE updkz_d VALUE 'U'. "Update indicator

***************************INTERNAL TABLE DECLARATION*******************
DATA:
  i_vbkd    TYPE ty_t_vbkd, "SO Business Data
  i_log     TYPE ty_t_log,  "Log data
*--> Begin of insert D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
  i_log_d3   TYPE ty_t_logd3,          "Internal table for D3 specific log
  gv_flag    TYPE flag,                "Flag to distinguish between D2 and D3 radio button from calling program
  i_fieldcat TYPE slis_t_fieldcat_alv, " Fieldcatalog Internal tab
*<-- End of insert D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
***************************VARIABLE DECLARATION*************************
  gv_data    TYPE char35, "Data String Variable
  gv_count_e TYPE int4,   "Error Record Count
  gv_count_s TYPE int4.   "Success Record Count
