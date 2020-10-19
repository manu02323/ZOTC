*&---------------------------------------------------------------------*
*&  Include           ZOTCN0110B_CON_LIST_EXCLU_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0110B_CON_LIST_EXCLU_TOP                          *
* TITLE      :  Order to Cash D2_OTC_CDD_0110_Convert Listing          *
*               exclusion records                                      *
* DEVELOPER  :  Abhishek Gupta                                         *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_CDD_0110                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Convert Listing exclusion records                      *
*                                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 12-Sep-2014 AGUPTA3  E2DK904581 INITIAL DEVELOPMENT                  *
* =========== ======== ========== =====================================*
* 12-May-2016 U033808  E1DK917461 D3: Add tables 915 and 922. File deli*
*                                 miter changed to pipe. Add codepage  *
*----------------------------------------------------------------------*
* 19-Jul-2016 U033808  E1DK917461 D3 Defect #2570: Short dump for field*
*                                 g_scount                             *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*                                      ITC1 Defect Issue fixed         *
* 30-AUG-2016 U033870  E1DK917461      Defect#3488: Picking file       *
*                                      from application server require *
*                                             S_DATASET authorization  *
*----------------------------------------------------------------------*
* 28-SEP-2016 MGARG   E1DK917461  D3_CR_0062:Added logic for call trans*
*                                 action based on EMI Value. Added more*
*                                 access sequences on selection Screen *
*                                 Added option for downloading error   *
*                                 file to presentation server          *
*&---------------------------------------------------------------------*
* 19-OCT-2016 U029639 E1DK917461  D3_CR_0062_2nd_Change:Make changes in*
*                                 logic to address issues mentioned in *
*                                 defect#3121.                         *
*&---------------------------------------------------------------------*

* Final Report Display Structure
TYPES :
      BEGIN OF ty_report,
       msgtyp TYPE char1,  "Message Type E / S
       msgtxt TYPE string, "Message Text
       key    TYPE string, "Key of message
      END OF ty_report,

** Structure for KOTG896
      BEGIN OF ty_key1,
        kschl  TYPE kschg, "Material listing/exclusion type
        vkorg  TYPE vkorg, "Sales Organization
        matnr  TYPE matnr, "Material Number
        kunag  TYPE kunag, "Sold-to party
        datbi TYPE char10, "Validity end date of the condition record
        datab TYPE char10, "Validity start date of the condition record
      END OF ty_key1,

** Structure for KOTG898
      BEGIN OF ty_key2,
        kschl TYPE kschg,  "Material listing/exclusion type
        vkorg  TYPE vkorg, "Sales Organization
        matnr  TYPE matnr, "Material Number
        kunwe  TYPE kunwe, "Ship-to party
        datbi TYPE char10, "Validity end date of the condition record
        datab TYPE char10, "Validity start date of the condition record
     END OF ty_key2,

** Structure for KOTG911
      BEGIN OF ty_key3,
        kschl  TYPE kschg,   "Material listing/exclusion type
        vkorg  TYPE vkorg,   "Sales Organization
        werks  TYPE werks_d, "Plant
        kunag  TYPE kunag,   "Sold-to party
        datbi TYPE char10,   "Validity end date of the condition record
        datab TYPE char10,   "Validity start date of the condition record
      END OF ty_key3,

** Structure for KOTG912
      BEGIN OF ty_key4,
        kschl  TYPE kschg, "Material listing/exclusion type
        vkorg  TYPE vkorg, "Sales Organization
        vtweg  TYPE vtweg, "Distribution Channel
        aland  TYPE aland, "Departure country
        matnr  TYPE matnr, "Material Number
        land1  TYPE lland, "Country of Destination
        datbi TYPE char10, "Validity end date of the condition record
        datab TYPE char10, "Validity start date of the condition record
     END OF ty_key4,

**Structure for KOTG903
      BEGIN OF ty_key5,
        kschl  TYPE kschg,   "Material listing/exclusion type
        vkorg  TYPE vkorg,   "Sales Organization
        aland  TYPE aland,   "Departure country (country from which the goods are sent)
        matnr  TYPE matnr,   "Material Number
        charg  TYPE charg_d, "Batch Number
        kunwe  TYPE kunwe,   "Ship-to party
        datbi TYPE char10,   "Validity end date of the condition record
        datab TYPE char10,   "start date of the condition record
      END OF ty_key5,

**Structure for KOTG904
      BEGIN OF ty_key6,
        kschl  TYPE kschg,   "Material listing/exclusion type
        vkorg  TYPE vkorg,   "Sales Organization
        aland  TYPE aland,   "Departure country (country from which the goods are sent)
        matnr  TYPE matnr,   "Material Number
        charg  TYPE charg_d, "Batch Number
        land1  TYPE lland,   "Country of Destination
        datbi TYPE char10,   "Validity end date of the condition record
        datab TYPE char10,   "Validity start date of the condition record
      END OF ty_key6,

** Structure for KOTG907
      BEGIN OF ty_key7,
        kschl  TYPE kschg, "Material listing/exclusion type
        vkorg  TYPE vkorg, "Sales Organization
        aland  TYPE aland, "Departure country (country from which the goods are sent)
        matnr  TYPE matnr, "Material Number
        land1  TYPE lland, "Country of Destination
        datbi TYPE char10, "Validity end date of the condition record
        datab TYPE char10, "Validity start date of the condition record
      END OF ty_key7,

**Structure for KOTG918
      BEGIN OF ty_key8,
        kschl  TYPE kschg,    "Material listing/exclusion type
        vkorg  TYPE vkorg,    "Sales Organization
        vtweg  TYPE vtweg,    "Distribution Channel
        zzpotype  TYPE bsark, "Customer purchase order type
        kunag  TYPE kunag,    "Sold-to party
        matnr  TYPE matnr,    "Material Number
        datbi TYPE char10,    "Validity end date of the condition record
        datab TYPE char10,    "Validity start date of the condition record
      END OF ty_key8,

**Structure for KOTG919
      BEGIN OF ty_key9,
        kschl  TYPE kschg,    "Material listing/exclusion type
        vkorg  TYPE vkorg,    "Sales Organization
        vtweg  TYPE vtweg,    "Distribution Channel
        zzpotype  TYPE bsark, "Customer purchase order type
        matnr  TYPE matnr,    "Material Number
        datbi TYPE char10,    "Validity end date of the condition record
        datab TYPE char10,    "Validity start date of the condition record
      END OF ty_key9,

* Start changes U033808
**Structure for KOTG915
      BEGIN OF ty_key10,
        kschl  TYPE kschg, "Material listing/exclusion type
        land1  TYPE lland, "Country of Destination
        matnr  TYPE matnr, "Material Number
        datbi TYPE char10, "Validity end date of the condition record
        datab TYPE char10, "Validity start date of the condition record
      END OF ty_key10,

**Structure for KOTG922
      BEGIN OF ty_key11,
        kschl  TYPE kschg,  "Material listing/exclusion type
        vkorg  TYPE vkorg,  "Sales Organization
        kunag  TYPE kunag,  "Sold-to party
        zzprctr TYPE prctr, "Profit Center               Added for E1DK917461 D3 U033808
        datbi TYPE char10,  "Validity end date of the condition record
        datab TYPE char10,  "Validity start date of the condition record
      END OF ty_key11,

      BEGIN OF ty_tab,
        input_line TYPE string,
      END OF ty_tab,
* End Changes U033808

*---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
     BEGIN OF ty_key12,
       kschl TYPE kschg,    " Material listing/exclusion type
       land1 TYPE lland,   "Country of Destination
       matnr TYPE matnr,   "Material Number
       charg TYPE charg_d, "Batch Number
       datbi TYPE char10,   "Validity end date of the condition record
       datab TYPE char10,   "Validity start date of the condition record
     END OF ty_key12,
*---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG

      BEGIN OF ty_final,
        kschl  TYPE kschg,   "Material listing/exclusion type
        vkorg  TYPE vkorg,   "Sales Organization
        werks TYPE werks_d,  "Plant
        matnr  TYPE matnr,   "Material Number
        kunwe TYPE kunwe,    "Ship-to party
        kunag  TYPE kunag,   "Sold-to party
        vtweg TYPE vtweg,    "Distribution Channel
        aland TYPE aland,    " Departure country (country from which the goods are sent)
        land1 TYPE lland,    " Country of Destination
        charg TYPE charg_d,  "Batch Number
        zzpotype TYPE bsark, "Customer purchase order type
        zzprctr TYPE prctr,  "Profit Center                     Added for E1DK917461 D3 U033808
        datbi TYPE char10,   "Validity end date of the condition record
        datab TYPE char10,   "Validity start date of the condition record
     END OF ty_final,

***Structure for error file
     BEGIN OF ty_error,
        kschl  TYPE kschg,   "Material listing/exclusion type
        vkorg  TYPE vkorg,   "Sales Organization
        werks TYPE werks_d,  "Plant
        matnr  TYPE matnr,   "Material Number
        kunwe TYPE kunwe,    "Ship-to party
        kunag  TYPE kunag,   "Sold-to party
        vtweg TYPE vtweg,    "Distribution Channel
        aland TYPE aland,    " Departure country (country from which the goods are sent)
        land1 TYPE lland,    " Country of Destination
        charg TYPE charg_d,  "Batch Number
        zzpotype TYPE bsark, "Customer purchase order type
        zzprctr TYPE prctr,  "Profit Center                   Added for E1DK917461 D3 U033808
        datbi TYPE char10,   "Validity end date of the condition record
        datab TYPE char10,   "Validity start date of the condition record
        errmsg TYPE string,
     END OF ty_error.

**Table Type declaration
TYPES: ty_t_report    TYPE STANDARD TABLE OF ty_report INITIAL SIZE 0, " Report
       ty_t_final TYPE STANDARD TABLE OF ty_final INITIAL SIZE 0,
       ty_t_error TYPE STANDARD TABLE OF ty_error INITIAL SIZE 0,
       ty_t_bdcdata   TYPE STANDARD TABLE OF bdcdata   INITIAL SIZE 0. " For bdc data

* Constants
CONSTANTS:
    c_text      TYPE char3    VALUE 'TXT',                     "Extension .TXT
    c_file_type TYPE char10   VALUE 'ASC',                     "ASC
    c_sep       TYPE char01   VALUE 'X',                       "Seprator
    c_lp_ind    TYPE char1    VALUE 'X',                       "X = Logical File Path
    c_tab       TYPE char1    VALUE                            " Tab of type CHAR1
                       cl_abap_char_utilities=>horizontal_tab, " Tab
    c_pipe      TYPE char1    VALUE '|',                       " Pipe delimieter U033808
    c_group     TYPE apqi-groupid VALUE 'OTC_0110',            " Session Name
    c_emsg      TYPE char1    VALUE 'E',                       " constant declaration for 'E' error message type
    c_imsg      TYPE char1    VALUE 'I',                       " constant declaration for 'I' Information message type "Added by JAHANM
    c_fslash    TYPE char1    VALUE '/',                       " Forward slash
    c_error     TYPE char1    VALUE 'E',                       "Success Indicator
    c_tcode     TYPE tstc-tcode   VALUE 'VB01',                " Tcode name
    c_tbp_fld   TYPE char5    VALUE 'TBP',                     " constant declaration for TBP folder
    c_done_fld  TYPE char5    VALUE 'DONE',                    " constant declaration for DONE folder.
    c_error_fld TYPE char5    VALUE 'ERROR',                   " constant declaration ERROR folder
* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062_2nd_Change by u029639
    c_error_file TYPE char6   VALUE 'Error_',
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062_2nd_Change by u029639
    c_smsg      TYPE char1    VALUE 'S',                       " constant declaration for 'S' success message type
    c_rbselected TYPE char1   VALUE 'X',                       " constant declaration for radio button selected
*---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
   c_abort      TYPE char1    VALUE 'A',    " Abort of type CHAR1
   c_scr_n12    TYPE bdc_dynr VALUE '1923', " BDC Screen number
*---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
   c_scr_n1     TYPE bdc_dynr VALUE '1896', " BDC Screen number
   c_scr_n2     TYPE bdc_dynr VALUE '1898', " BDC Screen number
   c_scr_n3     TYPE bdc_dynr VALUE '1911', " BDC Screen number
   c_scr_n4     TYPE bdc_dynr VALUE '1912', " BDC Screen number
   c_scr_n5     TYPE bdc_dynr VALUE '1903', " BDC Screen number
   c_scr_n6     TYPE bdc_dynr VALUE '1904', " BDC Screen number
   c_scr_n7     TYPE bdc_dynr VALUE '1907', " BDC Screen number
   c_scr_n8     TYPE bdc_dynr VALUE '1918', " BDC Screen number
   c_scr_n9     TYPE bdc_dynr VALUE '1919', " BDC Screen number
   c_scr_n10    TYPE bdc_dynr VALUE '1915', " BDC Screen number   "Added for E1DK917461 D3 U033808
   c_scr_n11    TYPE bdc_dynr VALUE '1922'. " BDC Screen number   "Added for E1DK917461 D3 U033808

* Variable Declaration.
DATA: gv_save     TYPE char1,     "= X for Post; = Space for Verify Only
      gv_file     TYPE localfile, "File name
      gv_mode     TYPE char10,    "Mode of transaction
*----> Start changes Defect 2570 D3 E1DK917461 by U033808
*      gv_scount   TYPE int2,      " Succes Count
*      gv_ecount   TYPE int2,      " Error Count
       gv_scount   TYPE int4, " Succes Count
       gv_ecount   TYPE int4, " Error Count
*----> End changes Defect 2570 D3 E1DK917461 by U033808
      gv_codepage TYPE cpcodepage, " SAP Character Set ID   "Added for E1DK917461 D3 U033808
*---> Begin of change for Defect#3488 by U033870 on 08/30/2016
      gv_file_flag TYPE flag, " General Flag
*<--- End of change for Defect#3488 by U033870 on 08/30/2016
      gv_flg1 TYPE char1, " Flg1 of type CHAR1
      gv_flg2 TYPE char1, " Flg2 of type CHAR1
      gv_flg3 TYPE char1, " Flg3 of type CHAR1
      gv_flg4 TYPE char1, " Flg4 of type CHAR1
*     gv_flg5 TYPE char1,         " Flg5 of type CHAR1   "Commented for E1DK917461 D3 U033808
*     gv_flg6 TYPE char1,         " Flg6 of type CHAR1   "Commented for E1DK917461 D3 U033808
      gv_flg7 TYPE char1,  " Flg7 of type CHAR1
      gv_flg8 TYPE char1,  " Flg8 of type CHAR1
      gv_flg9 TYPE char1,  " Flg9 of type CHAR1
      gv_flg10 TYPE char1, " Flg9 of type CHAR1   "Added for E1DK917461 D3 U033808
      gv_flg11 TYPE char1, " Flg9 of type CHAR1   "Added for E1DK917461 D3 U033808
* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
      gv_flg5 TYPE char1,           " Flg5 of type CHAR1
      gv_flg6 TYPE char1,           " Flg6 of type CHAR1
      gv_flg12 TYPE char1,          " Flg12 of type CHAR1
      gv_flag_calltrans TYPE char1, " Flag_calltrans of type CHAR1
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
      gv_scr_num TYPE bdc_dynr. " BDC Screen number

*WorkArea
DATA: wa_report TYPE ty_report, " Report
      wa_final  TYPE ty_final.

**Internal Tables
DATA: i_z001_1 TYPE STANDARD TABLE OF ty_key1,
      i_z001_2 TYPE STANDARD TABLE OF ty_key2,
      i_z001_3 TYPE STANDARD TABLE OF ty_key3,
      i_z001_4 TYPE STANDARD TABLE OF ty_key4,
      i_z001_5 TYPE STANDARD TABLE OF ty_key5,
      i_z001_6 TYPE STANDARD TABLE OF ty_key6,
      i_z001_7 TYPE STANDARD TABLE OF ty_key7,
      i_z001_8 TYPE STANDARD TABLE OF ty_key10, "Added for E1DK917461 D3 U033808
      i_z001_9 TYPE STANDARD TABLE OF ty_key11, "Added for E1DK917461 D3 U033808
      i_z002_1 TYPE STANDARD TABLE OF ty_key8,
      i_z002_2 TYPE STANDARD TABLE OF ty_key9,
* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
      i_z002_3 TYPE STANDARD TABLE OF ty_key12,
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
      i_report TYPE ty_t_report,              "Report table
      i_final TYPE STANDARD TABLE OF ty_final,
      i_error TYPE STANDARD TABLE OF ty_error,
      i_valid TYPE STANDARD TABLE OF ty_final,
      i_bdcdata TYPE ty_t_bdcdata,
      i_fs_tab TYPE STANDARD TABLE OF ty_tab, "Added for E1DK917461 D3 U033808
      wa_error TYPE ty_error.

FIELD-SYMBOLS:   <fs_tab> TYPE ANY TABLE.
