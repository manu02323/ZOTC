*&---------------------------------------------------------------------*
*&  Include           ZOTCN0028O_PRICING_REPORT_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0028O_PRICING_REPORT_TOP                          *
* TITLE      :  Pricing Report for Mass Price Upload                   *
* DEVELOPER  :  ROHIT VERMA                                            *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_RDD_0028_Pricing Report for Mass Price Upload      *
*----------------------------------------------------------------------*
* DESCRIPTION: This is a top include program of Report                 *
*              ZOTCN0028O_PRICING_REPORT. All global declaration of    *
*              this report are declared in this include program        *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 22-Jul-2013 RVERMA   E1DK910844 INITIAL DEVELOPMENT - CR#410         *
*&---------------------------------------------------------------------*

***************************TYPES DECLARATION*************************
TYPES:
*&--Structure for TVARVC table
  BEGIN OF ty_tvarvc,
    name TYPE rvari_vnam,	"Name of Variant Variable
    type TYPE rsscr_kind,	"Type of selection
    numb TYPE tvarv_numb,	"Current selection number
    sign TYPE tvarv_sign,	"ID: I/E (include/exclude values)
    opti TYPE tvarv_opti,	"Selection option (EQ/BT/CP/...)
    low  TYPE tvarv_val,  "Selection value Low
  END OF ty_tvarvc,

*&--Table Type for TVARVC table
  ty_t_tvarvc TYPE STANDARD TABLE OF ty_tvarvc.

***************************CONSTANT DECLARATION*************************
CONSTANTS:
  c_name_usg     TYPE rvari_vnam VALUE 'ZOTC_0028_USG',"Variant Name
  c_name_apl     TYPE rvari_vnam VALUE 'ZOTC_0028_APL',"Variant Name
  c_type_p       TYPE rsscr_kind VALUE 'P',"Variant Type
  c_numb_00      TYPE tvarv_numb VALUE '0000',"Variant Selction Number
  c_yes          TYPE char01     VALUE 'X',   "Check
  c_cond_class   TYPE char01     VALUE 'C'.   "Condition Class

***************************STRUCTURE DECLARATION************************
DATA:
  x_t681         TYPE t681,"Conditions: Structure
  x_tmc1t        TYPE tmc1t,"Short Texts on Conditions

***************************VARIABLE DECLARATION*************************

  gv_usage       TYPE kvewe,"Usage Variable
  gv_appl        TYPE kappl,"Application Variable
  gv_program     TYPE syrepid."Program Name Variable
