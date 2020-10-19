***********************************************************************
*Program    : ZOTCN0229B_QUOTE_VALID_CPQ_TOP                          *
*Title      : Quote Validation to CPQ                                 *
*Developer  : Raghav Sureddi (u033876)                                *
*Object type: Interface                                               *
*SAP Release: SAP ECC 8.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_IDD_0229                                              *
*---------------------------------------------------------------------*
*Description: Send Order info for Quote validation  to SOA  and SOA   *
* will send it CPQ for Quote validations and response back.           *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*20-June-2019  U033876      E2DK924884     Initial Development.       *
*&---------------------------------------------------------------------*
*21-Aug-2019   U033876      E2DK924884     Defect10289 - OTC_IDD_0229  *
*                                check zzquoteref is not initial as to *
*                                remove vbak records based on vbap     *
*&---------------------------------------------------------------------*
*-- type declarations
TYPES:

  BEGIN OF ty_vbak,
    vbeln TYPE vbeln,
    erdat TYPE erdat,
    erzet TYPE erzet,
    waerk TYPE waerk,
    vkorg TYPE vkorg,
    vtweg TYPE vtweg,
    kunnr TYPE kunag,
    objnr TYPE objko,
  END   OF ty_vbak,
  BEGIN OF ty_vbap,
    vbeln      TYPE vbeln,
    posnr      TYPE posnr,
    matnr      TYPE matnr,
    uepos      TYPE uepos,
    kwmeng     TYPE kwmeng,
    zzquoteref TYPE z_quoteref,
  END   OF ty_vbap,
  BEGIN OF ty_vbpa,
    vbeln TYPE vbeln,
    posnr TYPE posnr,
    parvw TYPE parvw,
    kunnr TYPE kunnr,
  END OF  ty_vbpa,
  BEGIN OF ty_final,
    zzquoteref TYPE z_quoteref,
    vbeln      TYPE vbeln,
    erdat      TYPE erdat,
    erzet      TYPE erzet,
    waerk      TYPE waerk,
    vkorg      TYPE vkorg,
    vtweg      TYPE vtweg,
    kunag      TYPE kunag,
    kunnr      TYPE kunnr,  "ship-to
    objnr      TYPE objko,
    posnr      TYPE posnr,
    matnr      TYPE matnr,
    kwmeng     TYPE kwmeng,
  END   OF ty_final,
  BEGIN OF ty_error,
    msgtyp TYPE bapi_mtype,    "Message Type
    msgtxt TYPE bapi_msg,   "Message Text
    key    TYPE bapi_msg,
  END   OF ty_error,
*-- Table type declarations
  ty_t_vbak   TYPE STANDARD TABLE OF ty_vbak,
  ty_t_vbap   TYPE STANDARD TABLE OF ty_vbap,
  ty_t_vbpa   TYPE STANDARD TABLE OF ty_vbpa,
  ty_t_final  TYPE STANDARD TABLE OF ty_final,
  ty_t_return TYPE STANDARD TABLE OF bapiret1,
  ty_t_error  TYPE STANDARD TABLE OF ty_error,
  ty_t_status TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0.

*-- Internal table declarations
DATA: i_vbak   TYPE  ty_t_vbak   ##needed,
      i_vbap   TYPE  ty_t_vbap   ##needed,
      i_vbpa   TYPE  ty_t_vbpa   ##needed,
      i_final  TYPE  ty_t_final  ##needed,
      i_error  TYPE  ty_t_error  ##needed,
      i_status TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0 ##needed.
* Variable Declaration
DATA: gv_vbeln TYPE  vbak-vbeln, "Sales Order no
      gv_erdat TYPE  erdat,      "Date on Which Record Was Created
* Begin of change for Defect 10289
      gv_vkorg TYPE vkorg.
* End of change for Defect   10289

DATA: gv_modify  TYPE localfile, " Input Data
      gv_mode    TYPE char10,
      gv_scount  TYPE int2,      " Succes Count
      gv_ecount  TYPE int2,      " Error Count
      gv_line    TYPE int2,      "Number of lines
      gv_err_flg TYPE char1.     "Error Flag
* Begin of change for Defect 10289
TYPES: ty_t_fkk        TYPE STANDARD TABLE OF fkk_ranges.
CONSTANTS: c_sign   TYPE char1 VALUE 'I',    " Integer
           c_option TYPE char4 VALUE 'EQ'. "Equal to
* End of change for Defect   10289
***** Constant declaration
CONSTANTS:c_success TYPE char1           VALUE 'S',            "Error Indicator
          c_error   TYPE char1           VALUE 'E',            "Success Indicator
          c_info    TYPE char1           VALUE 'I'.            " Info of type CHAR1
CONSTANTS:c_posnr   TYPE posnr           VALUE '000000'.
