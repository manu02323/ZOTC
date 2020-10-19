*&---------------------------------------------------------------------*
*&  Include           ZOTCN0068B_MODIFY_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0068B_MODIFY_TOP                                  *
* TITLE      :  OTC_CDD_0068B SALES ORDER OUTPUT                       *
* DEVELOPER  :  Pallavi Gupta                                          *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  OTC_CDD_0068_SALES ORDER OUTPUT CONVERSION             *
*----------------------------------------------------------------------*
* DESCRIPTION:  Data declaration include for uploading Conditional     *
*               Records into SAP from text file                        *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 06-JUN-2012 PGUPTA2  E1DK901630 INITIAL DEVELOPMENT                  *
* 23-JUN-2014 KNAMALA    E2DK901634 D2 Changes, Condition Type Z855    *
*                                   to Accommodate the Keycombination  *
*                                   changes                            *
* 07-MAR-2014 U104864    E2DK922518 D3 Changes in KeyCombination of    *
*                                   903(ZBA0,ZBA1),904(ZBA0,ZBA1)      *
*                                   Add KeyCombination 909(ZBA0,ZBA1)  *
*                                   SCTASK0801091                      *
*&---------------------------------------------------------------------*


TYPES: BEGIN OF ty_modify,
         keycombi   TYPE char20,      "Key combination
         kschl      TYPE na_kschl,    "Condition type
         vkorg      TYPE vkorg,       "sales organization
         vtweg      TYPE vtweg,       "Distribution Channel
         auart      TYPE auart,       "Output Type
         kunnr      TYPE kunag,       "Sold to Party
         kunwe      TYPE kunwe,       "Ship-to party
         parvw      TYPE parvw,       "partner function
         nacha      TYPE na_nacha,    "Message transmission medium
         vsztp      TYPE na_vsztp,    "dispatch time
         tcode      TYPE cstrategy,   "Communication strategy
         ldest      TYPE rspopname,   "spool : output device
         tdarmod    TYPE syarmod,     "Print: Archiving mode
         tdschedule TYPE skschedule,  "send time request
         dimme      TYPE tdimmed,     "print immediately
         zzbsark    TYPE bsark,       "Customer purchase order type
         parnr      TYPE na_parnr241, "partner number
       END OF ty_modify,

       BEGIN OF ty_modify_e,
         keycombi   TYPE char20,      "key combination
         kschl      TYPE na_kschl,    "condition type
         vkorg      TYPE vkorg,       "sales organization
         vtweg      TYPE vtweg,       "Distribution Channel
         auart      TYPE auart,       "Output Type
         kunnr      TYPE kunag,       "Sold to Party
         kunwe      TYPE kunwe,       "Ship-to party
         parvw      TYPE parvw,       "partner function
         nacha      TYPE na_nacha,    "Message transmission medium
         vsztp      TYPE na_vsztp,    "dispatch time
         tcode      TYPE cstrategy,   "Communication strategy
         ldest      TYPE rspopname,   "spool : output device
         tdarmod    TYPE syarmod,     "Print: Archiving mode
         tdschedule TYPE skschedule,  "send time request
         dimme      TYPE tdimmed,     "print immediately
         zzbsark    TYPE bsark,       "Customer purchase order type
         parnr      TYPE na_parnr241, "partner number
         errormsg   TYPE string,      "error message
       END OF ty_modify_e,


*Final Report Display Structure
       BEGIN OF ty_report,
         msgtyp TYPE char1,    "Message Type
         msgtxt TYPE string,   "Message Text
         key    TYPE string,   "Message Key
       END OF ty_report,

       BEGIN OF ty_vkorg,
         vkorg TYPE vkorg,     "sales organization from tvko table
       END OF ty_vkorg,

       BEGIN OF ty_tvtw,
         vtweg TYPE vtweg,     "sales organization from tvtw table
       END OF ty_tvtw,

       BEGIN OF ty_kunnr,
         kunnr TYPE kunnr,     "customer number from kna1 table
       END OF ty_kunnr,

       BEGIN OF ty_parvw,
         parvw TYPE parvw,     "partner function from tpar table
       END OF ty_parvw,

       BEGIN OF ty_auart,
         auart TYPE auart,     "Sales Document Type from tvak table
       END OF ty_auart ,

       BEGIN OF ty_kschl,
         kschl TYPE kschl,     "condition type
       END OF ty_kschl,

       BEGIN OF ty_b901,
         kappl TYPE kappl,     "Application
         kschl TYPE na_kschl,  "output type
         vkorg TYPE vkorg,     "sales organisation
         auart TYPE auart,     "Sales Document Type
         kunnr TYPE kunag,     "Sold-to party
         knumh TYPE nnumh,     "Number of output condition record
       END OF ty_b901,

       BEGIN OF ty_b902,
         kappl TYPE kappl,      "Application
         kschl TYPE na_kschl,   "output type
         vkorg TYPE vkorg,      "sales organisation
         auart TYPE auart,      "Sales Document Type
         kunwe TYPE kunwe,      "Ship to party
         knumh TYPE nnumh,      "Number of output condition record
       END OF ty_b902,

       BEGIN OF ty_b903,
         kappl TYPE kappl,      "Application
         kschl TYPE na_kschl,   "output type
         vkorg TYPE vkorg,      "sales organisation
         kunnr TYPE kunag,      "Sold-to party
         knumh TYPE nnumh,      "Number of output condition record
       END OF ty_b903,


       BEGIN OF ty_b904,
         kappl TYPE kappl,      "Application
         kschl TYPE na_kschl,   "output type
         vkorg TYPE vkorg,      "sales organisation
         kunwe TYPE kunwe,      "Ship to party
         knumh TYPE nnumh,      "Number of output condition record
       END OF ty_b904,


       BEGIN OF ty_b907,
         kappl TYPE kappl,      "Application
         kschl TYPE na_kschl,   "output type
         vkorg TYPE vkorg,      "sales organisation
         vtweg TYPE vtweg,      "Distribution Channel
         auart TYPE auart,      "Sales Document Type
         knumh TYPE nnumh,      "Number of output condition record
       END OF ty_b907,

       BEGIN OF ty_b908,
         kappl   TYPE kappl,    "Application
         kschl   TYPE na_kschl, "output type
         vkorg   TYPE vkorg,    "sales organisation
         auart   TYPE auart,    "Sales Document Type
         zzbsark TYPE bsark,    "Customer purchase order type
         kunnr   TYPE kunag,    "Sold-to party
         knumh   TYPE nnumh,    "Number of output condition record
       END OF ty_b908,

       BEGIN OF ty_b909,
         kappl   TYPE kappl,    "Application
         kschl   TYPE na_kschl, "output type
         vkorg   TYPE vkorg,    "sales organisation
         zzbsark TYPE bsark,    "Customer purchase order type
         kunnr   TYPE kunag,    "Sold-to party
         knumh   TYPE nnumh,    "Number of output condition record
       END OF ty_b909,

       BEGIN OF ty_dup,
         kschl   TYPE kschl,     "output type
         vkorg   TYPE vkorg,     "sales organisation
         auart   TYPE auart,     "Sales Document Type
         kunnr   TYPE kunag,     "Sold-to party
         vtweg   TYPE vtweg,     "sales organization
         zzbsark TYPE bsark,   "Customer purchase order type
       END OF ty_dup.


* Table Type Declaration
TYPES: ty_t_modify  TYPE STANDARD TABLE OF ty_modify   INITIAL SIZE 0, "For Input data
       ty_t_error   TYPE STANDARD TABLE OF ty_modify_e INITIAL SIZE 0, "For Error data
       ty_t_report  TYPE STANDARD TABLE OF ty_report   INITIAL SIZE 0, "Report
       ty_t_final   TYPE STANDARD TABLE OF ty_modify   INITIAL SIZE 0, "For Final Data
       ty_t_vkorg   TYPE STANDARD TABLE OF ty_vkorg    INITIAL SIZE 0, "sales organization
       ty_t_vtweg   TYPE STANDARD TABLE OF ty_tvtw     INITIAL SIZE 0, "Distribution Channels
       ty_t_kunnr   TYPE STANDARD TABLE OF ty_kunnr    INITIAL SIZE 0, "customer no
       ty_t_parvw   TYPE STANDARD TABLE OF ty_parvw    INITIAL SIZE 0, "partner function
       ty_t_auart   TYPE STANDARD TABLE OF ty_auart    INITIAL SIZE 0, "billing type
       ty_t_kschl   TYPE STANDARD TABLE OF ty_kschl    INITIAL SIZE 0, "condition type
       ty_t_b901    TYPE STANDARD TABLE OF ty_b901     INITIAL SIZE 0, "outtput condition record
       ty_t_b902    TYPE STANDARD TABLE OF ty_b902     INITIAL SIZE 0, "Sales org./SalesDocTy/Ship-to
       ty_t_b903    TYPE STANDARD TABLE OF ty_b903     INITIAL SIZE 0, "Sales org./Sold-to pt
       ty_t_b904    TYPE STANDARD TABLE OF ty_b904     INITIAL SIZE 0, "Sales org./Ship-to
       ty_t_b907    TYPE STANDARD TABLE OF ty_b907     INITIAL SIZE 0, "Sales org./Ship-to
       ty_t_b908    TYPE STANDARD TABLE OF ty_b908     INITIAL SIZE 0, "Sales org./Ship-to
       ty_t_b909    TYPE STANDARD TABLE OF ty_b909     INITIAL SIZE 0, "Sales org./Ship-to
       ty_t_bdcdata TYPE STANDARD TABLE OF bdcdata,                    "bdc data
       ty_t_dup     TYPE STANDARD TABLE OF ty_dup     INITIAL SIZE 0.  "duplicate records

* Constants
CONSTANTS: c_tab       TYPE char1   VALUE                           " Tab of type CHAR1
                             cl_abap_char_utilities=>horizontal_tab, "TAB value
           c_crlf      TYPE char1   VALUE                           " Crlf of type CHAR1
                             cl_abap_char_utilities=>cr_lf,          "New Line Feed
           c_ext       TYPE char3   VALUE 'CSV',                    " constant for extension
           c_comma     TYPE char1   VALUE ',',                      " constant for comma
           c_tbp_fld   TYPE char3   VALUE 'TBP',                    " constant declaration for TBP folder
           c_error_fld TYPE char5   VALUE 'ERROR',                  " ERROR folder
           c_done_fld  TYPE char4   VALUE 'DONE',                   " DONE folder
           c_v         TYPE char2   VALUE 'V1',                     " Constant for kappl = 'v1'
           c_error     TYPE char1   VALUE 'E',                      " Error Indicator
           c_success   TYPE char1   VALUE 'S',                      " Success Indicator
           c_slash     TYPE char1   VALUE '/',                      " For slash
           c_tcode     TYPE sytcode VALUE  'VV11',                  " T-code to upload
           c_seson     TYPE char10  VALUE 'OTC68_CONV',             " session name
           c_filetype  TYPE char10 VALUE 'ASC',                     " File type
           c_ba901     TYPE char10 VALUE 'ZBA0901',                 " key combination value
           c_zrga      TYPE char10 VALUE 'ZRGA901',                 " key combination value
           c_zko0      TYPE char10 VALUE 'ZKO0901',                 " key combination value
           c_zba0f     TYPE char10 VALUE 'ZBA0F901',                " key combination value
           c_zrgaf     TYPE char10 VALUE 'ZRGAF901',                " key combination value
           c_zko0f     TYPE char10 VALUE 'ZKO0F901',                " key combination value
           c_zba02     TYPE char10 VALUE 'ZBA0902',                 " key combination value
           c_zrga2     TYPE char10 VALUE 'ZRGA902',                 " key combination value
           c_zko02     TYPE char10 VALUE 'ZKO0902',                 " key combination value
           c_zba0f2    TYPE char10 VALUE 'ZBA0F902',                " key combination value
           c_zrgaf2    TYPE char10 VALUE 'ZRGAF902',                " key combination value
           c_zko0f2    TYPE char10 VALUE 'ZKO0F902',                " key combination value
           c_zbao3     TYPE char10 VALUE 'ZBA0903',                 " key combination value
           c_zrga3     TYPE char10 VALUE 'ZRGA903' ,                " key combination value
           c_zba03     TYPE char10 VALUE 'ZBA0F903',                " key combination value
           c_zko03     TYPE char10 VALUE 'ZKO0903',                 " key combination value
           c_zrgaf3    TYPE char10 VALUE 'ZRGAF903',                " key combination value
           c_zko0f3    TYPE char10 VALUE 'ZKO0F903',                " key combination value
           c_zba04     TYPE char10 VALUE 'ZBA0904',                 " key combination value
           c_zrga4     TYPE char10 VALUE 'ZRGA904',                 " key combination value
           c_zko04     TYPE char10 VALUE 'ZKO0904',                 " key combination value
           c_zba0f4    TYPE char10 VALUE 'ZBA0F904',                " key combination value
           c_zrgaf4    TYPE char10 VALUE 'ZRGAF904',                " key combination value
           c_zko0f4    TYPE char10 VALUE 'ZKO0F904',                " key combination value
           c_zba11     TYPE char10 VALUE 'ZBA1901',                 " key combination value
           c_zko11     TYPE char10 VALUE 'ZKO1901',                 " key combination value
           c_zrgb1     TYPE char10 VALUE 'ZRGB901',                 " key combination value
           c_zba13     TYPE char10 VALUE 'ZBA1903',                 " key combination value
           c_zrgb3     TYPE char10 VALUE 'ZRGB903',                 " key combination value
           c_zko13     TYPE char10 VALUE 'ZKO1903',                 " key combination value
           c_zba14     TYPE char10 VALUE 'ZBA1904',                 " key combination value
           c_zrgb4     TYPE char10 VALUE 'ZRGB904',                 " key combination value
           c_zko14     TYPE char10 VALUE 'ZKO1904',                 " key combination value
           c_zba12     TYPE char10 VALUE 'ZBA1902',                 " key combination value
           c_zrgb2     TYPE char10 VALUE 'ZRGB902',                 " key combination value
           c_zko12     TYPE char10 VALUE 'ZKO1902',                 " key combination value
           c_z855      TYPE char10 VALUE 'Z855903',                 " key combination value
           c_z8551     TYPE char10 VALUE 'Z855901',                 " key combination value
           c_z8558     TYPE char10 VALUE 'Z855908',                 " key combination value
           c_z8559     TYPE char10 VALUE 'Z855909',                 " key combination value
           c_zrcc      TYPE char10 VALUE 'ZRRC907',                 " key combination value
           c_ctype     TYPE char4  VALUE 'ZRRC'.                    "constant for ZRRC

** D2 Changes
CONSTANTS : c_z855921 TYPE char7 VALUE 'Z855921', "Key Combination
*            c_z855908 TYPE char7 VALUE 'Z855908', " Z855908 of type CHAR7
*            c_z855909 TYPE char7 VALUE 'Z855909', " Z855909 of type CHAR7
*            c_z855901 TYPE char7 VALUE 'Z855901', " Z855901 of type CHAR7
*            c_z855903 TYPE char7 VALUE 'Z855903'. " Z855903 of type CHAR7
**End of D2 Changes

*---Begin of Insert SCTASK0801091 by U104864.
            c_zba09   TYPE char10 VALUE 'ZBA0909',     " key combination value
            c_zba19   TYPE char10 VALUE 'ZBA1909'.     " key combination value
*---End of Insert SCTASK0801091 by U104864.
* Internal Table Declaration.
DATA: i_modify  TYPE ty_t_modify,  " For Input data
      i_error   TYPE ty_t_error,   " For Error data
      i_report  TYPE ty_t_report,  " Report Internal Table
      i_final   TYPE ty_t_final,   " For Final Data
      i_vkorg   TYPE ty_t_vkorg,   " sales organization
      i_vtweg   TYPE ty_t_vtweg,   " Distribution Channels
      i_kunnr   TYPE ty_t_kunnr,   " Customer number
      i_parvw   TYPE ty_t_parvw,   " Partner function
      i_auart   TYPE ty_t_auart,   " Sales Document Type
      i_kschl   TYPE ty_t_kschl,   " condition type
      i_b901    TYPE ty_t_b901,    " Sales org./SalesDocTy/Sold-to pt
      i_b902    TYPE ty_t_b902,    " condition record
      i_b903    TYPE ty_t_b903,    " condition record
      i_b904    TYPE ty_t_b904,    " condition record
      i_b907    TYPE ty_t_b907,    " Conditional Record
      i_b908    TYPE ty_t_b908,    " Conditional Record
      i_b909    TYPE ty_t_b909,    " Conditional Record
      i_bdcdata TYPE ty_t_bdcdata. " For bdc data

* Global Work area / structure declaration.
DATA:
      wa_report TYPE ty_report. " work area for report

* Variable Declaration.
DATA: gv_mode    TYPE char10,    " Mode of transaction
      gv_modify  TYPE localfile, " Input Data
      gv_scount  TYPE int2,      " Succes Count
      gv_ecount  TYPE int2,      " Error Count
      gv_line    TYPE int2,      "Number of lines
      gv_err_flg TYPE char1.     "Error Flag
