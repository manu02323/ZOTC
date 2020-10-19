interface ZIF_BAPI_SALESORDER_GETLIST
  public .


  types:
    BAPI_MTYPE type C length 000001 .
  types:
    BAPI_RCODE type C length 000005 .
  types:
    BAPI_MSG type C length 000220 .
  types:
    BALOGNR type C length 000020 .
  types:
    BALMNR type N length 000006 .
  types:
    SYMSGV type C length 000050 .
  types:
    begin of BAPIRETURN,
      TYPE type BAPI_MTYPE,
      CODE type BAPI_RCODE,
      MESSAGE type BAPI_MSG,
      LOG_NO type BALOGNR,
      LOG_MSG_NO type BALMNR,
      MESSAGE_V1 type SYMSGV,
      MESSAGE_V2 type SYMSGV,
      MESSAGE_V3 type SYMSGV,
      MESSAGE_V4 type SYMSGV,
    end of BAPIRETURN .
  types:
    KUNNR type C length 000010 .
  types:
    BUKRS type C length 000004 .
  types:
    begin of BAPI1007,
      CUSTOMER type KUNNR,
      COMP_CODE type BUKRS,
    end of BAPI1007 .
  types:
    VBELN type C length 000010 .
  types:
    POSNR type N length 000006 .
  types:
    MATNR type C length 000018 .
  types:
    ARKTX type C length 000040 .
  types:
    AUART type C length 000004 .
  types:
    KWMENG type P length 8  decimals 000003 .
  types:
    BSTNK type C length 000020 .
  types:
    CHARG_D type C length 000010 .
  types:
    FAKSK type C length 000002 .
  types:
    LIFSK type C length 000002 .
  types:
    KUNAG type C length 000010 .
  types:
    NAME1_GP type C length 000035 .
  types:
    KURSK_P type P length 5  decimals 000005 .
  types:
    LFIMG type P length 7  decimals 000003 .
  types:
    MEINS type C length 000003 .
  types:
    NETPR type P length 6  decimals 000002 .
  types:
    KPEIN type P length 3  decimals 000000 .
  types:
    KMEIN type C length 000003 .
  types:
    NETWR_AK type P length 8  decimals 000002 .
  types:
    NETWR type P length 8  decimals 000002 .
  types:
    SPART type C length 000002 .
  types:
    STATS type C length 000020 .
  types:
    VKGRP type C length 000003 .
  types:
    VKBUR type C length 000004 .
  types:
    VKORG type C length 000004 .
  types:
    VRKME type C length 000003 .
  types:
    VSTEL type C length 000004 .
  types:
    VTWEG type C length 000002 .
  types:
    WAERK type C length 000005 .
  types:
    WERKS_D type C length 000004 .
  types:
    LGORT_D type C length 000004 .
  types:
    AUGRU type C length 000003 .
  types:
    ABGRU type C length 000002 .
  types:
    MEINS_ISO type C length 000003 .
  types:
    KVMEI_ISO type C length 000003 .
  types:
    VRKME_ISO type C length 000003 .
  types:
    WAERS_ISO type C length 000003 .
  types:
    BSTKD type C length 000035 .
  types:
    KURSK_V type P length 5  decimals 000005 .
  types:
    MGV_MATERIAL_EXTERNAL type C length 000040 .
  types:
    MGV_MATERIAL_GUID type C length 000032 .
  types:
    MGV_MATERIAL_VERSION type C length 000010 .
  types ERZET type T .
  types:
    STATUS_VB type C length 000001 .
  types:
    SGT_RCAT type C length 000016 .
  types:
    MATNR40 type C length 000040 .
  types:
    begin of BAPIORDERS,
      SD_DOC type VBELN,
      ITM_NUMBER type POSNR,
      MATERIAL type MATNR,
      SHORT_TEXT type ARKTX,
      DOC_TYPE type AUART,
      DOC_DATE type DATS,
      REQ_QTY type KWMENG,
      REQ_DATE type DATS,
      PURCH_NO type BSTNK,
      BATCH type CHARG_D,
      VALID_FROM type DATS,
      VALID_TO type DATS,
      BILL_BLOCK type FAKSK,
      DLV_BLOCK type LIFSK,
      SOLD_TO type KUNAG,
      NAME type NAME1_GP,
      EXCHG_RATE type KURSK_P,
      DLV_QTY type LFIMG,
      BASE_UOM type MEINS,
      NET_PRICE type NETPR,
      COND_P_UNT type KPEIN,
      COND_UNIT type KMEIN,
      NET_VAL_HD type NETWR_AK,
      NET_VALUE type NETWR,
      DIVISION type SPART,
      DOC_STATUS type STATS,
      SALES_GRP type VKGRP,
      SALES_OFF type VKBUR,
      SALES_ORG type VKORG,
      SALES_UNIT type VRKME,
      SHIP_POINT type VSTEL,
      DISTR_CHAN type VTWEG,
      GI_DATE type DATS,
      CURRENCY type WAERK,
      PLANT type WERKS_D,
      STORE_LOC type LGORT_D,
      ORD_REASON type AUGRU,
      REASON_REJ type ABGRU,
      B_UOM_ISO type MEINS_ISO,
      CD_UNT_ISO type KVMEI_ISO,
      S_UNIT_ISO type VRKME_ISO,
      CURR_ISO type WAERS_ISO,
      PURCH_NO_C type BSTKD,
      EXCHG_RATE_V type KURSK_V,
      MAT_EXT type MGV_MATERIAL_EXTERNAL,
      MAT_GUID type MGV_MATERIAL_GUID,
      MAT_VERS type MGV_MATERIAL_VERSION,
      CREATION_DATE type DATS,
      CREATION_TIME type ERZET,
      STATUS_DOC type STATUS_VB,
      REQ_SEGMENT type SGT_RCAT,
      MATERIAL_LONG type MATNR40,
    end of BAPIORDERS .
  types:
    MATNR_EXT type C length 000040 .
  types:
    MATNR_VERS type C length 000010 .
  types:
    MATNR_EGUID type C length 000032 .
  types:
    begin of BAPIMGVMATNR,
      MATERIAL_EXT type MATNR_EXT,
      MATERIAL_VERS type MATNR_VERS,
      MATERIAL_GUID type MATNR_EGUID,
    end of BAPIMGVMATNR .
  types:
    CHAR1 type C length 000001 .
  types:
    begin of BAPIFLAG,
      BAPIFLAG type CHAR1,
    end of BAPIFLAG .
  types:
    TE_STRUC type C length 000030 .
  types:
    VALUEPART type C length 000240 .
  types:
    begin of BAPIPAREX,
      STRUCTURE type TE_STRUC,
      VALUEPART1 type VALUEPART,
      VALUEPART2 type VALUEPART,
      VALUEPART3 type VALUEPART,
      VALUEPART4 type VALUEPART,
    end of BAPIPAREX .
  types:
    __BAPIPAREX                    type standard table of BAPIPAREX                      with non-unique default key .
  types:
    __BAPIORDERS                   type standard table of BAPIORDERS                     with non-unique default key .
endinterface.
