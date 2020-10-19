interface ZIF_BAPI_SALESORDER_SIMULATE
  public .


  types:
    KUNRG type C length 000010 .
  types:
    NAME1_GP type C length 000035 .
  types:
    STRAS type C length 000030 .
  types:
    PFACH type C length 000010 .
  types:
    PSTLZ type C length 000010 .
  types:
    PSTL2 type C length 000010 .
  types:
    ORT01 type C length 000025 .
  types:
    SPRAS type C length 000001 .
  types:
    LAND1 type C length 000003 .
  types:
    TELF1 type C length 000016 .
  types:
    KKBER type C length 000004 .
  types:
    KNKLI type C length 000010 .
  types:
    KLIMK type P length 8  decimals 000002 .
  types:
    SAUFT type P length 8  decimals 000002 .
  types:
    SKFOR type P length 8  decimals 000002 .
  types:
    SSOBL type P length 8  decimals 000002 .
  types:
    WAERS_KNKK type C length 000005 .
  types:
    MRNKZ type C length 000001 .
  types:
    PERFK type C length 000002 .
  types:
    PERRL type C length 000002 .
  types:
    KVAWT type P length 7  decimals 000002 .
  types:
    KTGRD type C length 000002 .
  types:
    DZTERM type C length 000004 .
  types:
    VALTG type N length 000002 .
  types:
    VSORT type C length 000010 .
  types:
    FAKSD_V type C length 000002 .
  types:
    AUFSD type C length 000002 .
  types:
    STCEG type C length 000020 .
  types:
    STCEG_L type C length 000003 .
  types:
    TAXK1 type C length 000001 .
  types:
    TAXK2 type C length 000001 .
  types:
    TAXK3 type C length 000001 .
  types:
    TAXK4 type C length 000001 .
  types:
    TAXK5 type C length 000001 .
  types:
    TAXK6 type C length 000001 .
  types:
    TAXK7 type C length 000001 .
  types:
    TAXK8 type C length 000001 .
  types:
    TAXK9 type C length 000001 .
  types:
    BOKRE type C length 000001 .
  types:
    GRUPP_CM type C length 000004 .
  types:
    SBGRP_CM type C length 000003 .
  types:
    CTLPC_CM type C length 000003 .
  types:
    RASSC type C length 000006 .
  types:
    begin of BAPIPAYER,
      PAYER type KUNRG,
      NAME type NAME1_GP,
      STREET type STRAS,
      PO_BOX type PFACH,
      POSTL_CODE type PSTLZ,
      POBX_PCD type PSTL2,
      CITY type ORT01,
      LANGU type SPRAS,
      COUNTRY type LAND1,
      TELEPHONE type TELF1,
      C_CTR_AREA type KKBER,
      CRED_ACCNT type KNKLI,
      CRED_LIMIT type KLIMK,
      ORDER_VALS type SAUFT,
      RCVBL_VALS type SKFOR,
      CRED_LIAB type SSOBL,
      CURRENCY type WAERS_KNKK,
      MN_INVOICE type MRNKZ,
      BILL_SCHED type PERFK,
      LIST_SCHED type PERRL,
      VAL_LIMIT type KVAWT,
      ACCNT_ASGN type KTGRD,
      PMNTTRMS type DZTERM,
      ADD_VAL_DY type VALTG,
      FIX_VAL_DY type DATS,
      PROD_PROP type VSORT,
      BILL_BLOCK type FAKSD_V,
      ORDER_BLCK type AUFSD,
      VAT_REG_NO type STCEG,
      VAT_CNTRY type STCEG_L,
      TAX_CLASS1 type TAXK1,
      TAX_CLASS2 type TAXK2,
      TAX_CLASS3 type TAXK3,
      TAX_CLASS4 type TAXK4,
      TAX_CLASS5 type TAXK5,
      TAX_CLASS6 type TAXK6,
      TAX_CLASS7 type TAXK7,
      TAX_CLASS8 type TAXK8,
      TAX_CLASS9 type TAXK9,
      REBATE_REL type BOKRE,
      REBATE_FRM type DATS,
      CRED_GROUP type GRUPP_CM,
      REPR_GROUP type SBGRP_CM,
      RISK_CATEG type CTLPC_CM,
      TRADE_ID type RASSC,
    end of BAPIPAYER .
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
    VBELN_VA type C length 000010 .
  types:
    begin of BAPIVBELN,
      VBELN type VBELN_VA,
    end of BAPIVBELN .
  types:
    KUNWE type C length 000010 .
  types:
    LLAND type C length 000003 .
  types:
    LZONE type C length 000010 .
  types:
    BAHNS type C length 000025 .
  types:
    BAHNE type C length 000025 .
  types:
    ABLAD type C length 000025 .
  types:
    KNFAK type C length 000002 .
  types:
    WANID type C length 000003 .
  types WAMOAB1 type T .
  types WAMOBI1 type T .
  types WAMOAB2 type T .
  types WAMOBI2 type T .
  types WADIAB1 type T .
  types WADIBI1 type T .
  types WADIAB2 type T .
  types WADIBI2 type T .
  types WAMIAB1 type T .
  types WAMIBI1 type T .
  types WAMIAB2 type T .
  types WAMIBI2 type T .
  types WADOAB1 type T .
  types WADOBI1 type T .
  types WADOAB2 type T .
  types WADOBI2 type T .
  types WAFRAB1 type T .
  types WAFRBI1 type T .
  types WAFRAB2 type T .
  types WAFRBI2 type T .
  types WASAAB1 type T .
  types WASABI1 type T .
  types WASAAB2 type T .
  types WASABI2 type T .
  types WASOAB1 type T .
  types WASOBI1 type T .
  types WASOAB2 type T .
  types WASOBI2 type T .
  types:
    REGIO type C length 000003 .
  types:
    COUNC type C length 000003 .
  types:
    CITYC type C length 000004 .
  types:
    TXJCD type C length 000015 .
  types:
    STDOK type C length 000001 .
  types:
    DWERK type C length 000004 .
  types:
    LIFSD_V type C length 000002 .
  types:
    VSBED type C length 000002 .
  types:
    XCPDK type C length 000001 .
  types:
    KTOKD type C length 000004 .
  types:
    KNREF type C length 000030 .
  types:
    PERIV type C length 000002 .
  types:
    KUAT1 type C length 000001 .
  types:
    KUAT2 type C length 000001 .
  types:
    KUAT3 type C length 000001 .
  types:
    KUAT4 type C length 000001 .
  types:
    KUAT5 type C length 000001 .
  types:
    KUAT6 type C length 000001 .
  types:
    KUAT7 type C length 000001 .
  types:
    KUAT8 type C length 000001 .
  types:
    KUAT9 type C length 000001 .
  types:
    KUATA type C length 000001 .
  types:
    begin of BAPISHIPTO,
      SHIP_TO type KUNWE,
      NAME type NAME1_GP,
      STREET type STRAS,
      PO_BOX type PFACH,
      POSTL_CODE type PSTLZ,
      POBX_PCD type PSTL2,
      CITY type ORT01,
      LANGU type SPRAS,
      DEST_CNTRY type LLAND,
      TRNSP_ZONE type LZONE,
      TRAIN_STAT type BAHNS,
      EXPR_STAT type BAHNE,
      TELEPHONE type TELF1,
      UNLOAD_PT type ABLAD,
      FAC_CALEND type KNFAK,
      RECV_HOURS type WANID,
      MO_AM_FROM type WAMOAB1,
      MO_AM_UNTL type WAMOBI1,
      MO_PM_FROM type WAMOAB2,
      MO_PM_UNTL type WAMOBI2,
      TU_AM_FROM type WADIAB1,
      TU_AM_UNTL type WADIBI1,
      TU_PM_FROM type WADIAB2,
      TU_PM_UNTL type WADIBI2,
      WE_AM_FROM type WAMIAB1,
      WR_AM_UNTL type WAMIBI1,
      WE_PM_FROM type WAMIAB2,
      WE_PM_UNTL type WAMIBI2,
      TH_AM_FROM type WADOAB1,
      TH_AM_UNTL type WADOBI1,
      TH_PM_FROM type WADOAB2,
      TH_PM_UNTL type WADOBI2,
      FR_AM_FROM type WAFRAB1,
      FR_AM_UNTL type WAFRBI1,
      FR_PM_FROM type WAFRAB2,
      FR_PM_UNTL type WAFRBI2,
      SA_AM_FROM type WASAAB1,
      SA_AM_UNTL type WASABI1,
      SA_PM_FROM type WASAAB2,
      SA_PM_UNTL type WASABI2,
      SU_AM_FROM type WASOAB1,
      SU_AM_UNTL type WASOBI1,
      SU_PM_FROM type WASOAB2,
      SU_PM_UNTL type WASOBI2,
      VAT_REG_NO type STCEG,
      TAX_CLASS1 type TAXK1,
      TAX_CLASS2 type TAXK2,
      TAX_CLASS3 type TAXK3,
      TAX_CLASS4 type TAXK4,
      TAX_CLASS5 type TAXK5,
      TAX_CLASS6 type TAXK6,
      TAX_CLASS7 type TAXK7,
      TAX_CLASS8 type TAXK8,
      TAX_CLASS9 type TAXK9,
      REGION type REGIO,
      COUNTY_CDE type COUNC,
      CITY_CODE type CITYC,
      TAXJURCODE type TXJCD,
      CTRDATA_OK type STDOK,
      DLV_PLANT type DWERK,
      DLV_BLOCK type LIFSD_V,
      ORDER_BLCK type AUFSD,
      PROD_PROP type VSORT,
      SHIP_COND type VSBED,
      ACC_1_TIME type XCPDK,
      ACCNT_GRP type KTOKD,
      DESC_PARTN type KNREF,
      FY_VARIANT type PERIV,
      PROD_ATTR1 type KUAT1,
      PROD_ATTR2 type KUAT2,
      PROD_ATTR3 type KUAT3,
      PROD_ATTR4 type KUAT4,
      PROD_ATTR5 type KUAT5,
      PROD_ATTR6 type KUAT6,
      PROD_ATTR7 type KUAT7,
      PROD_ATTR8 type KUAT8,
      PROD_ATTR9 type KUAT9,
      PROD_ATTRA type KUATA,
    end of BAPISHIPTO .
  types:
    KUNAG type C length 000010 .
  types:
    VERSG type C length 000001 .
  types:
    KALKS type C length 000001 .
  types:
    KDGRP type C length 000002 .
  types:
    BZIRK type C length 000006 .
  types:
    KONDA type C length 000002 .
  types:
    PLTYP type C length 000002 .
  types:
    INCO1 type C length 000003 .
  types:
    INCO2 type C length 000028 .
  types:
    AUTLF type C length 000001 .
  types:
    ANTLF type P length 1  decimals 000000 .
  types:
    KZAZU_D type C length 000001 .
  types:
    CHSPL type C length 000001 .
  types:
    LPRIO type N length 000002 .
  types:
    WAERK type C length 000005 .
  types:
    KURST type C length 000004 .
  types:
    KZTLF type C length 000001 .
  types:
    AWAHR type N length 000003 .
  types:
    VKBUR type C length 000004 .
  types:
    VKGRP type C length 000003 .
  types:
    VBUND type C length 000006 .
  types:
    INCOV type C length 000004 .
  types:
    INCO2_L type C length 000070 .
  types:
    INCO3_L type C length 000070 .
  types:
    begin of BAPISOLDTO,
      SOLD_TO type KUNAG,
      NAME type NAME1_GP,
      STREET type STRAS,
      PO_BOX type PFACH,
      POSTL_CODE type PSTLZ,
      POBX_PCD type PSTL2,
      CITY type ORT01,
      LANGU type SPRAS,
      COUNTRY type LAND1,
      TELEPHONE type TELF1,
      STAT_GROUP type VERSG,
      ORDER_BLCK type AUFSD,
      PRC_PROCED type KALKS,
      CUST_GROUP type KDGRP,
      SALES_DIST type BZIRK,
      PRICE_GRP type KONDA,
      PRICE_LIST type PLTYP,
      INCOTERMS1 type INCO1,
      INCOTERMS2 type INCO2,
      COMPL_DLV type AUTLF,
      MAX_PL_DLV type ANTLF,
      ORDER_COMB type KZAZU_D,
      BTCH_SPLIT type CHSPL,
      DLV_PRIO type LPRIO,
      CURRENCY type WAERK,
      EXCHG_RATE type KURST,
      SHIP_COND type VSBED,
      PART_DLV type KZTLF,
      ORDER_PROB type AWAHR,
      DLV_BLOCK type LIFSD_V,
      PROD_PROP type VSORT,
      ACC_1_TIME type XCPDK,
      SALES_OFF type VKBUR,
      SALES_GRP type VKGRP,
      VAT_REG_NO type STCEG,
      TAX_CLASS1 type TAXK1,
      TAX_CLASS2 type TAXK2,
      TAX_CLASS3 type TAXK3,
      TAX_CLASS4 type TAXK4,
      TAX_CLASS5 type TAXK5,
      TAX_CLASS6 type TAXK6,
      TAX_CLASS7 type TAXK7,
      TAX_CLASS8 type TAXK8,
      TAX_CLASS9 type TAXK9,
      COMPANY_ID type VBUND,
      INCOTERMSV type INCOV,
      INCOTERMS2L type INCO2_L,
      INCOTERMS3L type INCO3_L,
    end of BAPISOLDTO .
  types:
    CHAR1 type C length 000001 .
  types:
    begin of BAPIFLAG,
      BAPIFLAG type CHAR1,
    end of BAPIFLAG .
  types:
    AUART type C length 000004 .
  types:
    SUBMI type C length 000010 .
  types:
    VKORG type C length 000004 .
  types:
    VTWEG type C length 000002 .
  types:
    SPART type C length 000002 .
  types:
    PRGRS_VBAK type C length 000001 .
  types:
    BSTNK type C length 000020 .
  types:
    BSARK type C length 000004 .
  types:
    BSTZD type C length 000004 .
  types:
    IHREZ type C length 000012 .
  types:
    BNAME type C length 000030 .
  types:
    TELF1_VP type C length 000016 .
  types:
    LIFSK type C length 000002 .
  types:
    FAKSK type C length 000002 .
  types:
    AUGRU type C length 000003 .
  types:
    KVGR1 type C length 000003 .
  types:
    KVGR2 type C length 000003 .
  types:
    KVGR3 type C length 000003 .
  types:
    KVGR4 type C length 000003 .
  types:
    KVGR5 type C length 000003 .
  types:
    BSTKD type C length 000035 .
  types:
    BSTKD_E type C length 000035 .
  types:
    BSARK_E type C length 000004 .
  types:
    IHREZ_E type C length 000012 .
  types:
    VBTYP type C length 000001 .
  types:
    WAERS_ISO type C length 000003 .
  types:
    DELCO type C length 000003 .
  types:
    KSCHA type C length 000004 .
  types:
    BAPIKBETR type P length 12  decimals 000004 .
  types:
    KPEINC type N length 000005 .
  types:
    KVMEI type C length 000003 .
  types:
    KVMEI_ISO type C length 000003 .
  types:
    WAERS type C length 000005 .
  types:
    CHAR12 type C length 000012 .
  types:
    VGBEL type C length 000010 .
  types:
    VBTYP_V type C length 000001 .
  types:
    SEPA_MNDID type C length 000035 .
  types:
    VBTYPL_S4 type C length 000004 .
  types:
    begin of BAPISDHEAD,
      DOC_NUMBER type VBELN_VA,
      DOC_TYPE type AUART,
      COLLECT_NO type SUBMI,
      SALES_ORG type VKORG,
      DISTR_CHAN type VTWEG,
      DIVISION type SPART,
      SALES_GRP type VKGRP,
      SALES_OFF type VKBUR,
      REQ_DATE_H type DATS,
      DATE_TYPE type PRGRS_VBAK,
      PURCH_NO type BSTNK,
      PURCH_DATE type DATS,
      PO_METHOD type BSARK,
      PO_SUPPLEM type BSTZD,
      REF_1 type IHREZ,
      NAME type BNAME,
      TELEPHONE type TELF1_VP,
      PRICE_GRP type KONDA,
      CUST_GROUP type KDGRP,
      SALES_DIST type BZIRK,
      PRICE_LIST type PLTYP,
      INCOTERMS1 type INCO1,
      INCOTERMS2 type INCO2,
      PMNTTRMS type DZTERM,
      DLV_BLOCK type LIFSK,
      BILL_BLOCK type FAKSK,
      ORD_REASON type AUGRU,
      COMPL_DLV type AUTLF,
      PRICE_DATE type DATS,
      QT_VALID_F type DATS,
      QT_VALID_T type DATS,
      CT_VALID_F type DATS,
      CT_VALID_T type DATS,
      CUST_GRP1 type KVGR1,
      CUST_GRP2 type KVGR2,
      CUST_GRP3 type KVGR3,
      CUST_GRP4 type KVGR4,
      CUST_GRP5 type KVGR5,
      PURCH_NO_C type BSTKD,
      PURCH_NO_S type BSTKD_E,
      PO_DAT_S type DATS,
      PO_METH_S type BSARK_E,
      REF_1_S type IHREZ_E,
      SD_DOC_CAT type VBTYP,
      SHIP_COND type VSBED,
      CURRENCY type WAERK,
      CURRENCY_ISO type WAERS_ISO,
      DLV_TIME type DELCO,
      CD_TYPE1 type KSCHA,
      CD_VALUE1 type BAPIKBETR,
      CD_P_UNT1 type KPEINC,
      CD_D_UNT1 type KVMEI,
      CD_D_UISO1 type KVMEI_ISO,
      CD_CURR1 type WAERS,
      CD_CU_ISO1 type WAERS_ISO,
      CD_TYPE2 type KSCHA,
      CD_VALUE2 type BAPIKBETR,
      CD_P_UNT2 type KPEINC,
      CD_D_UNT2 type KVMEI,
      CD_D_UISO2 type KVMEI_ISO,
      CD_CURR2 type WAERS,
      CD_CU_ISO2 type WAERS_ISO,
      CD_TYPE3 type KSCHA,
      CD_VALUE3 type BAPIKBETR,
      CD_P_UNT3 type KPEINC,
      CD_D_UNT3 type KVMEI,
      CD_D_UISO3 type KVMEI_ISO,
      CD_CURR3 type WAERS,
      CD_CU_ISO3 type WAERS_ISO,
      CD_TYPE4 type KSCHA,
      CD_VALUE4 type BAPIKBETR,
      CD_P_UNT4 type KPEINC,
      CD_D_UNT4 type KVMEI,
      CD_D_UISO4 type KVMEI_ISO,
      CD_CURR4 type WAERS,
      CD_CU_ISO4 type WAERS_ISO,
      FKK_CONACCT type CHAR12,
      REF_DOC type VGBEL,
      REF_DOC_CA type VBTYP_V,
      SEPA_MANDATE_ID type SEPA_MNDID,
      SD_DOC_CAT_LONG type VBTYPL_S4,
      REF_DOC_CA_LONG type VBTYPL_S4,
      INCOTERMSV type INCOV,
      INCOTERMS2L type INCO2_L,
      INCOTERMS3L type INCO3_L,
    end of BAPISDHEAD .
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
    SYMSGID type C length 000020 .
  types:
    SYMSGNO type N length 000003 .
  types:
    BAPI_PARAM type C length 000032 .
  types:
    BAPI_FLD type C length 000030 .
  types:
    BAPILOGSYS type C length 000010 .
  types:
    begin of BAPIRET2,
      TYPE type BAPI_MTYPE,
      ID type SYMSGID,
      NUMBER type SYMSGNO,
      MESSAGE type BAPI_MSG,
      LOG_NO type BALOGNR,
      LOG_MSG_NO type BALMNR,
      MESSAGE_V1 type SYMSGV,
      MESSAGE_V2 type SYMSGV,
      MESSAGE_V3 type SYMSGV,
      MESSAGE_V4 type SYMSGV,
      PARAMETER type BAPI_PARAM,
      ROW type INT4,
      FIELD type BAPI_FLD,
      SYSTEM type BAPILOGSYS,
    end of BAPIRET2 .
  types:
    __BAPIRET2                     type standard table of BAPIRET2                       with non-unique default key .
  types:
    CCPRE type C length 000001 .
  types:
    CCFOL type C length 000010 .
  types:
    CCVAL type C length 000001 .
  types:
    CCAUA type C length 000001 .
  types:
    CSOUR type C length 000001 .
  types:
    RCAVR_CC type C length 000004 .
  types:
    RCAVA_CC type C length 000004 .
  types:
    RCAVZ_CC type C length 000004 .
  types:
    RCRSP_CC type C length 000004 .
  types:
    CCBEG type C length 000001 .
  types:
    begin of APPEND_BAPICCARD_1,
      PRE_AUTH type CCPRE,
      CC_SEQ_NO type CCFOL,
      AMOUNTCHAN type CCVAL,
      AUTHORTYPE type CCAUA,
      DATAORIGIN type CSOUR,
      RADRCHECK1 type RCAVR_CC,
      RADRCHECK2 type RCAVA_CC,
      RADRCHECK3 type RCAVZ_CC,
      RCARDCHECK type RCRSP_CC,
      CC_LIMITED type CCBEG,
    end of APPEND_BAPICCARD_1 .
  types:
    CVVAL type C length 000006 .
  types:
    CVVCT type C length 000001 .
  types:
    CVVST type C length 000001 .
  types:
    begin of APPEND_BAPICCARD_4,
      CC_VERIF_VALUE type CVVAL,
      CC_CTRL_FIELD type CVVCT,
      CC_IN_USE_ST type CVVST,
    end of APPEND_BAPICCARD_4 .
  types:
    CCINS type C length 000004 .
  types:
    CCNUM type C length 000025 .
  types:
    CCNAME type C length 000040 .
  types:
    CC_BILL_VA type P length 12  decimals 000004 .
  types:
    FLGAU type C length 000001 .
  types:
    CC_AUTH_VA type P length 12  decimals 000004 .
  types AUTIM type T .
  types:
    AUNUM type C length 000010 .
  types:
    AUTRA type C length 000015 .
  types:
    REACT_SD type C length 000001 .
  types:
    BAPICURR_D type P length 12  decimals 000004 .
  types:
    SAKNR type C length 000010 .
  types:
    CCALL type C length 000001 .
  types:
    RTEXT_CC type C length 000040 .
  types:
    XFELD type C length 000001 .
  types:
    MERCH type C length 000015 .
  types:
    begin of BAPICCARD,
      CC_TYPE type CCINS,
      CC_NUMBER type CCNUM,
      CC_VALID_T type DATS,
      CC_NAME type CCNAME,
      BILLAMOUNT type CC_BILL_VA,
      AUTH_FLAG type FLGAU,
      AUTHAMOUNT type CC_AUTH_VA,
      CURRENCY type WAERS,
      CURR_ISO type WAERS_ISO,
      AUTH_DATE type DATS,
      AUTH_TIME type AUTIM,
      AUTH_CC_NO type AUNUM,
      AUTH_REFNO type AUTRA,
      CC_REACT type REACT_SD,
      CC_RE_AMOUNT type BAPICURR_D,
      GL_ACCOUNT type SAKNR,
      CC_STAT_EX type CCALL,
      CC_REACT_T type RTEXT_CC,
      VIRT_CARD type XFELD,
      MERCHIDCL type MERCH.
    include type APPEND_BAPICCARD_1.
    include type APPEND_BAPICCARD_4.
    types:
    end of BAPICCARD .
  types:
    __BAPICCARD                    type standard table of BAPICCARD                      with non-unique default key .
  types:
    TYPZM type C length 000001 .
  types:
    TRMID type C length 000010 .
  types:
    FKSAF type C length 000001 .
  types:
    SETTL type C length 000001 .
  types:
    LOCID_CC type C length 000010 .
  types:
    FPLNR type C length 000010 .
  types:
    FPLTR type N length 000006 .
  types:
    RFCDEST type C length 000032 .
  types:
    FNAUT_SETINIT type C length 000030 .
  types:
    FNAUT_SETINFO type C length 000030 .
  types:
    begin of BAPICCARD_EX,
      PAY_TYPE type TYPZM,
      CC_TYPE type CCINS,
      CC_NUMBER type CCNUM,
      CC_SEQ_NO type CCFOL,
      CC_VALID_F type DATS,
      CC_VALID_T type DATS,
      CC_NAME type CCNAME,
      AUTHAMOUNT type CC_AUTH_VA,
      CURRENCY type WAERS,
      CURR_ISO type WAERS_ISO,
      AUTH_DATE type DATS,
      AUTH_TIME type AUTIM,
      MERCHIDCL type MERCH,
      TERMINAL type TRMID,
      BILLAMOUNT type CC_BILL_VA,
      CC_LI_AMOUNT type CCBEG,
      CC_AUTTH_NO type AUNUM,
      BILLSTATUS type FKSAF,
      DATAORIGIN type CSOUR,
      CC_SETTLED type SETTL,
      AUTH_REFNO type AUTRA,
      PTOFRCPT type LOCID_CC,
      CC_REACT type REACT_SD,
      AUTH_FLAG type FLGAU,
      BILL_PLAN type FPLNR,
      BILL_PLANI type FPLTR,
      CC_RE_AMOUNT type BAPICURR_D,
      GL_ACCOUNT type SAKNR,
      CC_STAT_EX type CCALL,
      CC_REACT_T type RTEXT_CC,
      RFCAUT type RFCDEST,
      AUT_SETINIT type FNAUT_SETINIT,
      AUT_SETINFO type FNAUT_SETINFO,
      PRE_AUTH type CCPRE,
    end of BAPICCARD_EX .
  types:
    __BAPICCARD_EX                 type standard table of BAPICCARD_EX                   with non-unique default key .
  types:
    CUX_CFG_ID type C length 000006 .
  types:
    CUBLOB type C length 000250 .
  types:
    begin of BAPICUBLB,
      CONFIG_ID type CUX_CFG_ID,
      CONTEXT type CUBLOB,
    end of BAPICUBLB .
  types:
    __BAPICUBLB                    type standard table of BAPICUBLB                      with non-unique default key .
  types:
    CU_INST_ID type C length 000008 .
  types:
    CUIB_OBJTYP type C length 000010 .
  types:
    KLASSENART type C length 000003 .
  types:
    CUIB_OBJKEY type C length 000050 .
  types:
    CU_OBJ_TXT type C length 000070 .
  types:
    CU_QUAN type C length 000015 .
  types:
    CU_INF type C length 000001 .
  types:
    CUX_QUAN_UNIT type C length 000003 .
  types:
    CU_CHECKED type C length 000001 .
  types:
    CUX_UUID_TYPE type C length 000032 .
  types:
    CUX_PERSIST_ID type C length 000032 .
  types:
    CUX_PERSIST_ID_TYPE type C length 000001 .
  types:
    begin of BAPICUINS,
      CONFIG_ID type CUX_CFG_ID,
      INST_ID type CU_INST_ID,
      OBJ_TYPE type CUIB_OBJTYP,
      CLASS_TYPE type KLASSENART,
      OBJ_KEY type CUIB_OBJKEY,
      OBJ_TXT type CU_OBJ_TXT,
      QUANTITY type CU_QUAN,
      AUTHOR type CU_INF,
      QUANTITY_UNIT type CUX_QUAN_UNIT,
      COMPLETE type CU_CHECKED,
      CONSISTENT type CU_CHECKED,
      OBJECT_GUID type CUX_UUID_TYPE,
      PERSIST_ID type CUX_PERSIST_ID,
      PERSIST_ID_TYPE type CUX_PERSIST_ID_TYPE,
    end of BAPICUINS .
  types:
    __BAPICUINS                    type standard table of BAPICUINS                      with non-unique default key .
  types:
    CUX_PART_POS_NO type C length 000004 .
  types:
    CUX_SALES_RELEVANT type C length 000001 .
  types:
    CUX_GUID_PRT type C length 000032 .
  types:
    begin of BAPICUPRT,
      CONFIG_ID type CUX_CFG_ID,
      PARENT_ID type CU_INST_ID,
      INST_ID type CU_INST_ID,
      PART_OF_NO type CUX_PART_POS_NO,
      OBJ_TYPE type CUIB_OBJTYP,
      CLASS_TYPE type KLASSENART,
      OBJ_KEY type CUIB_OBJKEY,
      AUTHOR type CU_INF,
      SALES_RELEVANT type CUX_SALES_RELEVANT,
      PART_OF_GUID type CUX_GUID_PRT,
    end of BAPICUPRT .
  types:
    __BAPICUPRT                    type standard table of BAPICUPRT                      with non-unique default key .
  types:
    CU_POSEX type C length 000006 .
  types:
    CUX_CONFIGURATION_TYPE type C length 000001 .
  types:
    CUX_KBNAME type C length 000030 .
  types:
    CUX_RT_VERSION type C length 000030 .
  types:
    CUX_KB_PROFILE type C length 000030 .
  types:
    CUX_KBLANGUAGE type C length 000001 .
  types:
    begin of BAPICUCFG,
      POSEX type CU_POSEX,
      CONFIG_ID type CUX_CFG_ID,
      ROOT_ID type CU_INST_ID,
      SCE type CUX_CONFIGURATION_TYPE,
      KBNAME type CUX_KBNAME,
      KBVERSION type CUX_RT_VERSION,
      COMPLETE type CU_CHECKED,
      CONSISTENT type CU_CHECKED,
      CFGINFO type CUBLOB,
      KBPROFILE type CUX_KB_PROFILE,
      KBLANGUAGE type CUX_KBLANGUAGE,
      CBASE_ID type CUX_PERSIST_ID,
      CBASE_ID_TYPE type CUX_PERSIST_ID_TYPE,
    end of BAPICUCFG .
  types:
    __BAPICUCFG                    type standard table of BAPICUCFG                      with non-unique default key .
  types:
    CU_CHARC type C length 000040 .
  types:
    CU_CHARCT type C length 000070 .
  types:
    CUX_VALUE type C length 000040 .
  types:
    CU_VALUET type C length 000070 .
  types:
    CUX_VALCOD type C length 000001 .
  types:
    begin of BAPICUVAL,
      CONFIG_ID type CUX_CFG_ID,
      INST_ID type CU_INST_ID,
      CHARC type CU_CHARC,
      CHARC_TXT type CU_CHARCT,
      VALUE type CUX_VALUE,
      VALUE_TXT type CU_VALUET,
      AUTHOR type CU_INF,
      VALUE_TO type CUX_VALUE,
      VALCODE type CUX_VALCOD,
    end of BAPICUVAL .
  types:
    __BAPICUVAL                    type standard table of BAPICUVAL                      with non-unique default key .
  types:
    KPOSN type N length 000006 .
  types:
    STUNR type N length 000003 .
  types:
    DZAEHK type N length 000002 .
  types:
    BAPIKBETR1 type P length 15  decimals 000009 .
  types:
    KMEIN type C length 000003 .
  types:
    KPEIN type P length 3  decimals 000000 .
  types:
    SWO_OBJTYP type C length 000010 .
  types:
    SWO_TYPEID type C length 000070 .
  types:
    LOGSYS type C length 000010 .
  types:
    KAPPL type C length 000002 .
  types:
    KRECH type C length 000001 .
  types:
    BAPIKAWRT1 type P length 15  decimals 000009 .
  types:
    KKURS type P length 5  decimals 000005 .
  types:
    KUMZA type P length 3  decimals 000000 .
  types:
    KUMNE type P length 3  decimals 000000 .
  types:
    KNTYP type C length 000001 .
  types:
    KSTAT type C length 000001 .
  types:
    STFKZ type C length 000001 .
  types:
    KRUEK type C length 000001 .
  types:
    KRELI type C length 000001 .
  types:
    KHERK type C length 000001 .
  types:
    KGRPE type C length 000001 .
  types:
    KOUPD type C length 000001 .
  types:
    KOLNR type N length 000002 .
  types:
    KOPOS type N length 000002 .
  types:
    BAPICUREXT type P length 15  decimals 000009 .
  types:
    BAPIKWERT1 type P length 15  decimals 000009 .
  types:
    KSTEU type C length 000001 .
  types:
    KINAK type C length 000001 .
  types:
    KOAID type C length 000001 .
  types KFAKTOR type F .
  types:
    KZBZG type C length 000001 .
  types:
    BAPIKSTBS1 type P length 15  decimals 000009 .
  types:
    KONMS type C length 000003 .
  types:
    ISOCD_UNIT type C length 000003 .
  types:
    KONWS type C length 000005 .
  types:
    KFKIV type C length 000001 .
  types:
    KVARC type C length 000001 .
  types:
    KMPRS type C length 000001 .
  types:
    KNUMH type C length 000010 .
  types:
    MWSKZ type C length 000002 .
  types:
    VARCOND type C length 000026 .
  types:
    KVSL1 type C length 000003 .
  types:
    KVSL2 type C length 000003 .
  types:
    WT_WITHCD type C length 000002 .
  types:
    KDUPL type C length 000001 .
  types KFAKTOR1 type F .
  types:
    DZAEKO type N length 000002 .
  types:
    begin of BAPICOND,
      ITM_NUMBER type KPOSN,
      COND_ST_NO type STUNR,
      COND_COUNT type DZAEHK,
      COND_TYPE type KSCHA,
      COND_VALUE type BAPIKBETR1,
      CURRENCY type WAERS,
      COND_UNIT type KMEIN,
      COND_P_UNT type KPEIN,
      CURR_ISO type WAERS_ISO,
      CD_UNT_ISO type KVMEI_ISO,
      REFOBJTYPE type SWO_OBJTYP,
      REFOBJKEY type SWO_TYPEID,
      REFLOGSYS type LOGSYS,
      APPLICATIO type KAPPL,
      CONPRICDAT type DATS,
      CALCTYPCON type KRECH,
      CONBASEVAL type BAPIKAWRT1,
      CONEXCHRAT type KKURS,
      NUMCONVERT type KUMZA,
      DENOMINATO type KUMNE,
      CONDTYPE type KNTYP,
      STAT_CON type KSTAT,
      SCALETYPE type STFKZ,
      ACCRUALS type KRUEK,
      CONINVOLST type KRELI,
      CONDORIGIN type KHERK,
      GROUPCOND type KGRPE,
      COND_UPDAT type KOUPD,
      ACCESS_SEQ type KOLNR,
      CONDCOUNT type KOPOS,
      ROUNDOFFDI type BAPICUREXT,
      CONDVALUE type BAPIKWERT1,
      CURRENCY_2 type WAERK,
      CURR_ISO_2 type WAERS_ISO,
      CONDCNTRL type KSTEU,
      CONDISACTI type KINAK,
      CONDCLASS type KOAID,
      FACTBASVAL type KFAKTOR,
      SCALEBASIN type KZBZG,
      SCALBASVAL type BAPIKSTBS1,
      UNITMEASUR type KONMS,
      ISO_UNIT type ISOCD_UNIT,
      CURRENCKEY type KONWS,
      CURRENISO type WAERS_ISO,
      CONDINCOMP type KFKIV,
      CONDCONFIG type KVARC,
      CONDCHAMAN type KMPRS,
      COND_NO type KNUMH,
      TAX_CODE type MWSKZ,
      VARCOND type VARCOND,
      ACCOUNTKEY type KVSL1,
      ACCOUNT_KE type KVSL2,
      WT_WITHCD type WT_WITHCD,
      STRUCTCOND type KDUPL,
      FACTCONBAS type KFAKTOR1,
      CONDCOINHD type DZAEKO,
    end of BAPICOND .
  types:
    __BAPICOND                     type standard table of BAPICOND                       with non-unique default key .
  types:
    VBELN type C length 000010 .
  types:
    POSNR type N length 000006 .
  types:
    ETENR type N length 000004 .
  types:
    PARVW type C length 000002 .
  types:
    TBNAM_VB type C length 000030 .
  types:
    FDNAM_VB type C length 000030 .
  types:
    SCRTEXT_L type C length 000040 .
  types:
    begin of BAPIINCOMP,
      DOC_NUMBER type VBELN,
      ITM_NUMBER type POSNR,
      SCHED_LINE type ETENR,
      PARTN_ROLE type PARVW,
      TABLE_NAME type TBNAM_VB,
      FIELD_NAME type FDNAM_VB,
      FIELD_TEXT type SCRTEXT_L,
    end of BAPIINCOMP .
  types:
    __BAPIINCOMP                   type standard table of BAPIINCOMP                     with non-unique default key .
  types:
    POSNR_VA type N length 000006 .
  types:
    UEPOS type N length 000006 .
  types:
    POSEX type C length 000006 .
  types:
    MATNR type C length 000018 .
  types:
    KDMAT22 type C length 000022 .
  types:
    CHARG_D type C length 000010 .
  types:
    GRKOR type N length 000003 .
  types:
    ABGRU_VA type C length 000002 .
  types:
    FAKSP type C length 000002 .
  types:
    WERKS_D type C length 000004 .
  types:
    LGORT_D type C length 000004 .
  types:
    DZMENGC type N length 000013 .
  types:
    DZIEME type C length 000003 .
  types:
    WMENGC type N length 000013 .
  types:
    VRKME type C length 000003 .
  types:
    PSTYV type C length 000004 .
  types:
    ARKTX type C length 000040 .
  types:
    PRGRS type C length 000001 .
  types EZEIT_VBEP type T .
  types:
    KBETR type P length 6  decimals 000002 .
  types:
    MVGR1 type C length 000003 .
  types:
    MVGR2 type C length 000003 .
  types:
    MVGR3 type C length 000003 .
  types:
    MVGR4 type C length 000003 .
  types:
    MVGR5 type C length 000003 .
  types:
    BAPI_PRODH type C length 000018 .
  types:
    MATKL type C length 000009 .
  types:
    POSEX_E type C length 000006 .
  types:
    ISO_ZIEME type C length 000003 .
  types:
    VRKME_ISO type C length 000003 .
  types:
    KDMAT type C length 000035 .
  types:
    W_SORTK type C length 000018 .
  types:
    WKTNR type C length 000010 .
  types:
    WKTPS type N length 000006 .
  types:
    VGPOS type N length 000006 .
  types:
    MGV_MATERIAL_EXTERNAL type C length 000040 .
  types:
    MGV_MATERIAL_GUID type C length 000032 .
  types:
    MGV_MATERIAL_VERSION type C length 000010 .
  types:
    STLAL type C length 000002 .
  types:
    EAN11 type C length 000018 .
  types:
    VSTEL type C length 000004 .
  types:
    WMINR type C length 000010 .
  types:
    SGT_RCAT type C length 000016 .
  types:
    MATNR40 type C length 000040 .
  types:
    SGT_RCAT40 type C length 000040 .
  types:
    begin of BAPIITEMIN,
      ITM_NUMBER type POSNR_VA,
      HG_LV_ITEM type UEPOS,
      PO_ITM_NO type POSEX,
      MATERIAL type MATNR,
      CUST_MAT type KDMAT22,
      BATCH type CHARG_D,
      DLV_GROUP type GRKOR,
      PART_DLV type KZTLF,
      REASON_REJ type ABGRU_VA,
      BILL_BLOCK type FAKSP,
      BILL_DATE type DATS,
      PLANT type WERKS_D,
      STORE_LOC type LGORT_D,
      TARGET_QTY type DZMENGC,
      TARGET_QU type DZIEME,
      REQ_QTY type WMENGC,
      SALES_UNIT type VRKME,
      ITEM_CATEG type PSTYV,
      SHORT_TEXT type ARKTX,
      REQ_DATE type DATS,
      DATE_TYPE type PRGRS,
      REQ_TIME type EZEIT_VBEP,
      COND_TYPE type KSCHA,
      COND_VALUE type KBETR,
      COND_P_UNT type KPEINC,
      COND_D_UNT type KVMEI,
      PRC_GROUP1 type MVGR1,
      PRC_GROUP2 type MVGR2,
      PRC_GROUP3 type MVGR3,
      PRC_GROUP4 type MVGR4,
      PRC_GROUP5 type MVGR5,
      PROD_HIERA type BAPI_PRODH,
      MATL_GROUP type MATKL,
      PURCH_NO_C type BSTKD,
      PURCH_DATE type DATS,
      PO_METHOD type BSARK,
      REF_1 type IHREZ,
      PURCH_NO_S type BSTKD_E,
      PO_DAT_S type DATS,
      PO_METH_S type BSARK_E,
      REF_1_S type IHREZ_E,
      PO_ITM_NO_S type POSEX_E,
      COND_VAL1 type BAPIKBETR,
      CURRENCY type WAERS,
      CURR_ISO type WAERS_ISO,
      T_UNIT_ISO type ISO_ZIEME,
      S_UNIT_ISO type VRKME_ISO,
      CD_UNT_ISO type KVMEI_ISO,
      CUST_MAT35 type KDMAT,
      INCOTERMS1 type INCO1,
      INCOTERMS2 type INCO2,
      DLV_TIME type DELCO,
      ASSORT_MOD type W_SORTK,
      VAL_CONTR type WKTNR,
      VAL_CON_I type WKTPS,
      REF_DOC type VGBEL,
      REF_DOC_IT type VGPOS,
      REF_DOC_CA type VBTYP_V,
      CD_TYPE2 type KSCHA,
      CD_VALUE2 type BAPIKBETR,
      CD_P_UNT2 type KPEINC,
      CD_D_UNT2 type KVMEI,
      CD_D_UISO2 type KVMEI_ISO,
      CD_CURR2 type WAERS,
      CD_CU_ISO2 type WAERS_ISO,
      CD_TYPE3 type KSCHA,
      CD_VALUE3 type BAPIKBETR,
      CD_P_UNT3 type KPEINC,
      CD_D_UNT3 type KVMEI,
      CD_D_UISO3 type KVMEI_ISO,
      CD_CURR3 type WAERS,
      CD_CU_ISO3 type WAERS_ISO,
      CD_TYPE4 type KSCHA,
      CD_VALUE4 type BAPIKBETR,
      CD_P_UNT4 type KPEINC,
      CD_D_UNT4 type KVMEI,
      CD_D_UISO4 type KVMEI_ISO,
      CD_CURR4 type WAERS,
      CD_CU_ISO4 type WAERS_ISO,
      MAT_EXT type MGV_MATERIAL_EXTERNAL,
      MAT_GUID type MGV_MATERIAL_GUID,
      MAT_VERS type MGV_MATERIAL_VERSION,
      ALTERN_BOM type STLAL,
      FKK_CONACCT type CHAR12,
      EAN_UPC type EAN11,
      SHIP_POINT type VSTEL,
      PRODCAT type WMINR,
      SGT_RCAT type SGT_RCAT,
      INCOTERMSV type INCOV,
      INCOTERMS2L type INCO2_L,
      INCOTERMS3L type INCO3_L,
      REF_DOC_CA_LONG type VBTYPL_S4,
      MATERIAL_LONG type MATNR40,
      REQ_SEG_LONG type SGT_RCAT40,
    end of BAPIITEMIN .
  types:
    __BAPIITEMIN                   type standard table of BAPIITEMIN                     with non-unique default key .
  types:
    MATWA type C length 000018 .
  types:
    NETWRC type N length 000015 .
  types:
    KZWI1C type N length 000015 .
  types:
    KZWI2C type N length 000015 .
  types:
    KZWI3C type N length 000015 .
  types:
    KZWI4C type N length 000015 .
  types:
    KZWI5C type N length 000015 .
  types:
    KZWI6C type N length 000015 .
  types:
    MNGWT type N length 000013 .
  types:
    WZEITC type N length 000003 .
  types:
    KZKFG type C length 000001 .
  types:
    BAPINETWR type P length 12  decimals 000004 .
  types:
    KWMENG type P length 8  decimals 000003 .
  types:
    BAPIWMWST type P length 12  decimals 000004 .
  types:
    MGV_MAT_ENTRD_EXTERNAL type C length 000040 .
  types:
    MGV_MAT_ENTRD_GUID type C length 000032 .
  types:
    MGV_MAT_ENTRD_VERSION type C length 000010 .
  types:
    DZMENG type P length 7  decimals 000003 .
  types:
    ABGRU type C length 000002 .
  types:
    PRODH_D type C length 000018 .
  types:
    KZWI1BAPI type P length 12  decimals 000004 .
  types:
    KZWI2BAPI type P length 12  decimals 000004 .
  types:
    KZWI3BAPI type P length 12  decimals 000004 .
  types:
    KZWI4BAPI type P length 12  decimals 000004 .
  types:
    KZWI5BAPI type P length 12  decimals 000004 .
  types:
    KZWI6BAPI type P length 12  decimals 000004 .
  types:
    MATWA40 type C length 000040 .
  types:
    begin of BAPIITEMEX,
      ITM_NUMBER type POSNR_VA,
      PO_ITM_NO type POSEX,
      MATERIAL type MATNR,
      MAT_ENTRD type MATWA,
      SHORT_TEXT type ARKTX,
      NET_VALUE type NETWRC,
      CURRENCY type WAERK,
      SUBTOTAL_1 type KZWI1C,
      SUBTOTAL_2 type KZWI2C,
      SUBTOTAL_3 type KZWI3C,
      SUBTOTAL_4 type KZWI4C,
      SUBTOTAL_5 type KZWI5C,
      SUBTOTAL_6 type KZWI6C,
      SALES_UNIT type VRKME,
      QTY_REQ_DT type MNGWT,
      DLV_DATE type DATS,
      REPL_TIME type WZEITC,
      CONFIGURED type KZKFG,
      PURCH_NO_C type BSTKD,
      PURCH_DATE type DATS,
      PO_METHOD type BSARK,
      REF_1 type IHREZ,
      PURCH_NO_S type BSTKD_E,
      PO_DAT_S type DATS,
      PO_METH_S type BSARK_E,
      REF_1_S type IHREZ_E,
      PO_ITM_NO_S type POSEX_E,
      NET_VALUE1 type BAPINETWR,
      CURR_ISO type WAERS_ISO,
      S_UNIT_ISO type VRKME_ISO,
      REQ_QTY type KWMENG,
      PLANT type WERKS_D,
      TX_DOC_CUR type BAPIWMWST,
      MAT_EXT type MGV_MATERIAL_EXTERNAL,
      MAT_GUID type MGV_MATERIAL_GUID,
      MAT_VERS type MGV_MATERIAL_VERSION,
      MAT_E_EXT type MGV_MAT_ENTRD_EXTERNAL,
      MAT_E_GUID type MGV_MAT_ENTRD_GUID,
      MAT_E_VERS type MGV_MAT_ENTRD_VERSION,
      TARGET_QTY type DZMENG,
      TARGET_QU type DZIEME,
      T_UNIT_ISO type ISO_ZIEME,
      ITEM_CATEG type PSTYV,
      SHIP_POINT type VSTEL,
      HG_LV_ITEM type UEPOS,
      CUST_MAT type KDMAT,
      PART_DLV type KZTLF,
      REASON_REJ type ABGRU,
      BILL_BLOCK type FAKSP,
      STGE_LOC type LGORT_D,
      PROD_HIER type PRODH_D,
      MATL_GROUP type MATKL,
      SUBTOTAL1 type KZWI1BAPI,
      SUBTOTAL2 type KZWI2BAPI,
      SUBTOTAL3 type KZWI3BAPI,
      SUBTOTAL4 type KZWI4BAPI,
      SUBTOTAL5 type KZWI5BAPI,
      SUBTOTAL6 type KZWI6BAPI,
      MATERIAL_LONG type MATNR40,
      MAT_ENTRD_LONG type MATWA40,
      REQ_SEGMENT type SGT_RCAT,
      REQ_SEG_LONG type SGT_RCAT40,
    end of BAPIITEMEX .
  types:
    __BAPIITEMEX                   type standard table of BAPIITEMEX                     with non-unique default key .
  types:
    KUNNR type C length 000010 .
  types:
    ANRED_VP type C length 000015 .
  types:
    NAME2_GP type C length 000035 .
  types:
    NAME3_GP type C length 000035 .
  types:
    NAME4_GP type C length 000035 .
  types:
    STRAS_GP type C length 000035 .
  types:
    LAND1_ISO type C length 000002 .
  types:
    PFORT_GP type C length 000035 .
  types:
    ORT01_GP type C length 000035 .
  types:
    ORT02_GP type C length 000035 .
  types:
    TELF2 type C length 000016 .
  types:
    TELBX type C length 000015 .
  types:
    TELFX type C length 000031 .
  types:
    TELTX type C length 000030 .
  types:
    TELX1 type C length 000030 .
  types:
    LAISO type C length 000002 .
  types:
    ADRNR type C length 000010 .
  types:
    ADRNP type C length 000010 .
  types:
    AD_ADRTYPE type C length 000001 .
  types:
    ADDR_ORIGIN type C length 000001 .
  types:
    ADDR_LINK type C length 000010 .
  types:
    begin of BAPIPARTNR,
      PARTN_ROLE type PARVW,
      PARTN_NUMB type KUNNR,
      ITM_NUMBER type POSNR,
      TITLE type ANRED_VP,
      NAME type NAME1_GP,
      NAME_2 type NAME2_GP,
      NAME_3 type NAME3_GP,
      NAME_4 type NAME4_GP,
      STREET type STRAS_GP,
      COUNTRY type LAND1,
      COUNTRY_ISO type LAND1_ISO,
      POSTL_CODE type PSTLZ,
      POBX_PCD type PSTL2,
      POBX_CTY type PFORT_GP,
      CITY type ORT01_GP,
      DISTRICT type ORT02_GP,
      REGION type REGIO,
      PO_BOX type PFACH,
      TELEPHONE type TELF1,
      TELEPHONE2 type TELF2,
      TELEBOX type TELBX,
      FAX_NUMBER type TELFX,
      TELETEX_NO type TELTX,
      TELEX_NO type TELX1,
      LANGU type SPRAS,
      LANGU_ISO type LAISO,
      UNLOAD_PT type ABLAD,
      TRANSPZONE type LZONE,
      TAXJURCODE type TXJCD,
      ADDRESS type ADRNR,
      PRIV_ADDR type ADRNP,
      ADDR_TYPE type AD_ADRTYPE,
      ADDR_ORIG type ADDR_ORIGIN,
      ADDR_LINK type ADDR_LINK,
      VAT_REG_NO type STCEG,
    end of BAPIPARTNR .
  types:
    __BAPIPARTNR                   type standard table of BAPIPARTNR                     with non-unique default key .
  types:
    MSGFN type C length 000003 .
  types:
    ETTYP type C length 000002 .
  types:
    LFREL type C length 000001 .
  types:
    WMENG type P length 7  decimals 000003 .
  types:
    BMENG type P length 7  decimals 000003 .
  types:
    LMENG type P length 7  decimals 000003 .
  types:
    MEINS type C length 000003 .
  types:
    BDART type C length 000002 .
  types:
    PLART type C length 000001 .
  types:
    VBELE type C length 000010 .
  types:
    POSNE type N length 000006 .
  types:
    ETENE type N length 000004 .
  types:
    IDNNR type N length 000010 .
  types:
    BANFN type C length 000010 .
  types:
    BSART type C length 000004 .
  types:
    BSTYP type C length 000001 .
  types:
    WEPOS_A type C length 000001 .
  types:
    REPOS type C length 000001 .
  types:
    CMENG type P length 7  decimals 000003 .
  types:
    LIFSP_EP type C length 000002 .
  types:
    GRSTR type N length 000003 .
  types:
    ABART type C length 000001 .
  types:
    ABRUF type N length 000010 .
  types:
    DCQNT type P length 7  decimals 000003 .
  types:
    ROMS2 type P length 7  decimals 000003 .
  types:
    ROMS3 type P length 7  decimals 000003 .
  types:
    ROMEI type C length 000003 .
  types:
    RFORM type C length 000002 .
  types:
    UMVKZ type P length 3  decimals 000000 .
  types:
    UMVKN type P length 3  decimals 000000 .
  types:
    VERFP_MAS type C length 000001 .
  types:
    BWART type C length 000003 .
  types:
    BNFPO type N length 000005 .
  types:
    EDI_ETTYP type C length 000001 .
  types:
    AUFNR type C length 000012 .
  types:
    PLNUM type C length 000010 .
  types:
    SERNR type C length 000008 .
  types:
    AESKD type C length 000017 .
  types ABGES_CM type F .
  types MBUHR type T .
  types TDUHR type T .
  types LDUHR type T .
  types WAUHR type T .
  types:
    AULWE type C length 000010 .
  types:
    begin of BAPISDHEDU,
      OPERATION type MSGFN,
      DOC_NUMBER type VBELN_VA,
      ITM_NUMBER type POSNR_VA,
      SCHED_LINE type ETENR,
      SCHED_TYPE type ETTYP,
      RELFORDEL type LFREL,
      REQ_DATE type DATS,
      REQ_TIME type EZEIT_VBEP,
      REQ_QTY type WMENG,
      CONFIR_QTY type BMENG,
      SALES_UNIT type VRKME,
      ISOCODUNIT type ISOCD_UNIT,
      REQ_QTY1 type LMENG,
      BASE_UOM type MEINS,
      ISOBASUNIT type ISO_ZIEME,
      REQ_DATE1 type DATS,
      REQ_TYPE type BDART,
      PLTYPE type PLART,
      BUSIDOCNR type VBELE,
      BUSIITNR type POSNE,
      SCHED_LIN1 type ETENE,
      EARL_DATE type DATS,
      MAINT_REQ type IDNNR,
      PREQ_NO type BANFN,
      PO_TYPE type BSART,
      DOC_CAT type BSTYP,
      CONF_STAT type WEPOS_A,
      IR_IND type REPOS,
      RETURNDATE type DATS,
      DATE_TYPE type PRGRS,
      TP_DATE type DATS,
      MS_DATE type DATS,
      LOAD_DATE type DATS,
      GI_DATE type DATS,
      CORR_QTY type CMENG,
      REQ_DLV_BL type LIFSP_EP,
      GRP_DEFIN type GRSTR,
      RELEASTYP type ABART,
      FORCAST_NR type ABRUF,
      COMMIT_QTY type DCQNT,
      SIZE2 type ROMS2,
      SIZE3 type ROMS3,
      UNIT_MEAS type ROMEI,
      ISO_ROMEI type ISO_ZIEME,
      FORMULAKEY type RFORM,
      SALESQTYNR type UMVKZ,
      SALESQTYDE type UMVKN,
      AVAIL_CON type VERFP_MAS,
      MOVE_TYPE type BWART,
      PREQ_ITEM type BNFPO,
      LINTYP_EDI type EDI_ETTYP,
      ORDERID type AUFNR,
      PLANORDNR type PLNUM,
      BOMEXPL_NO type SERNR,
      CUSTCHSTAT type AESKD,
      GURANTEED type ABGES_CM,
      MS_TIME type MBUHR,
      TP_TIME type TDUHR,
      LOAD_TIME type LDUHR,
      GI_TIME type WAUHR,
      ROUTESCHED type AULWE,
    end of BAPISDHEDU .
  types:
    __BAPISDHEDU                   type standard table of BAPISDHEDU                     with non-unique default key .
  types:
    begin of BAPISCHDL,
      ITM_NUMBER type POSNR_VA,
      SCHED_LINE type ETENR,
      REQ_DATE type DATS,
      DATE_TYPE type PRGRS,
      REQ_TIME type EZEIT_VBEP,
      REQ_QTY type WMENG,
      REQ_DLV_BL type LIFSP_EP,
      SCHED_TYPE type ETTYP,
      TP_DATE type DATS,
      MS_DATE type DATS,
      LOAD_DATE type DATS,
      GI_DATE type DATS,
      TP_TIME type TDUHR,
      MS_TIME type MBUHR,
      LOAD_TIME type LDUHR,
      GI_TIME type WAUHR,
      REFOBJTYPE type SWO_OBJTYP,
      REFOBJKEY type SWO_TYPEID,
      REFLOGSYS type LOGSYS,
      DLV_DATE type DATS,
      DLV_TIME type EZEIT_VBEP,
      REL_TYPE type ABART,
      PLAN_SCHED_TYPE type EDI_ETTYP,
    end of BAPISCHDL .
  types:
    __BAPISCHDL                    type standard table of BAPISCHDL                      with non-unique default key .
  types:
    AD_ADDRNUM type C length 000010 .
  types:
    AD_TITLE_T type C length 000020 .
  types:
    AD_NAME1 type C length 000040 .
  types:
    AD_NAME2 type C length 000040 .
  types:
    AD_NAME3 type C length 000040 .
  types:
    AD_NAME4 type C length 000040 .
  types:
    AD_NAME_CO type C length 000040 .
  types:
    AD_CITY1 type C length 000040 .
  types:
    AD_CITY2 type C length 000040 .
  types:
    AD_CITYNUM type C length 000012 .
  types:
    AD_PSTCD1 type C length 000010 .
  types:
    AD_PSTCD2 type C length 000010 .
  types:
    AD_PSTCD3 type C length 000010 .
  types:
    AD_POBX type C length 000010 .
  types:
    AD_POBXLOC type C length 000040 .
  types:
    AD_PSTLAR type C length 000015 .
  types:
    AD_STR_OLD type C length 000040 .
  types:
    AD_STRNUM type C length 000012 .
  types:
    AD_STRABBR type C length 000002 .
  types:
    AD_HSNM1 type C length 000010 .
  types:
    AD_STRSPP1 type C length 000040 .
  types:
    AD_STRSPP2 type C length 000040 .
  types:
    AD_LCTN type C length 000040 .
  types:
    AD_BLD_OLD type C length 000010 .
  types:
    AD_FLOOR type C length 000010 .
  types:
    AD_ROOMNUM type C length 000010 .
  types:
    AD_SORT1 type C length 000020 .
  types:
    AD_SORT2 type C length 000020 .
  types:
    AD_TZONE type C length 000006 .
  types:
    AD_TXJCD type C length 000015 .
  types:
    AD_REMARK1 type C length 000050 .
  types:
    AD_COMM type C length 000003 .
  types:
    AD_TLNMBR1 type C length 000030 .
  types:
    AD_TLXTNS1 type C length 000010 .
  types:
    AD_FXNMBR1 type C length 000030 .
  types:
    AD_FXXTNS1 type C length 000010 .
  types:
    AD_STREET type C length 000060 .
  types:
    AD_CITYPNM type C length 000008 .
  types:
    AD_CHECKST type C length 000001 .
  types:
    AD_CIT2NUM type C length 000012 .
  types:
    AD_HSNM2 type C length 000010 .
  types:
    AD_SMTPADR type C length 000241 .
  types:
    AD_STRSPP3 type C length 000040 .
  types:
    AD_TITLETX type C length 000030 .
  types:
    INTCA type C length 000002 .
  types:
    AD_BLDNG type C length 000020 .
  types:
    REGIOGROUP type C length 000008 .
  types:
    AD_CITY3 type C length 000040 .
  types:
    AD_CITYHNM type C length 000012 .
  types:
    AD_PST1XT type C length 000010 .
  types:
    AD_PST2XT type C length 000010 .
  types:
    AD_PST3XT type C length 000010 .
  types:
    AD_POBXNUM type C length 000001 .
  types:
    AD_POBXREG type C length 000003 .
  types:
    AD_POBXCTY type C length 000003 .
  types:
    AD_URISCR type C length 000132 .
  types:
    AD_NO_USES type C length 000004 .
  types:
    AD_NO_USEP type C length 000004 .
  types:
    AD_HSNM3 type C length 000010 .
  types:
    AD_LANGUCR type C length 000001 .
  types:
    AD_PO_BOX_LBY type C length 000040 .
  types:
    AD_DELIVERY_SERVICE_TYPE type C length 000004 .
  types:
    AD_DELIVERY_SERVICE_NUMBER type C length 000010 .
  types:
    AD_URITYPE type C length 000003 .
  types:
    AD_CNTYNUM type C length 000008 .
  types:
    AD_COUNTY type C length 000040 .
  types:
    AD_TWSHPNUM type C length 000008 .
  types:
    AD_TOWNSHIP type C length 000040 .
  types:
    AD_XPCPT type C length 000001 .
  types:
    begin of BAPIADDR1,
      ADDR_NO type AD_ADDRNUM,
      FORMOFADDR type AD_TITLE_T,
      NAME type AD_NAME1,
      NAME_2 type AD_NAME2,
      NAME_3 type AD_NAME3,
      NAME_4 type AD_NAME4,
      C_O_NAME type AD_NAME_CO,
      CITY type AD_CITY1,
      DISTRICT type AD_CITY2,
      CITY_NO type AD_CITYNUM,
      POSTL_COD1 type AD_PSTCD1,
      POSTL_COD2 type AD_PSTCD2,
      POSTL_COD3 type AD_PSTCD3,
      PO_BOX type AD_POBX,
      PO_BOX_CIT type AD_POBXLOC,
      DELIV_DIS type AD_PSTLAR,
      STREET type AD_STR_OLD,
      STREET_NO type AD_STRNUM,
      STR_ABBR type AD_STRABBR,
      HOUSE_NO type AD_HSNM1,
      STR_SUPPL1 type AD_STRSPP1,
      STR_SUPPL2 type AD_STRSPP2,
      LOCATION type AD_LCTN,
      BUILDING type AD_BLD_OLD,
      FLOOR type AD_FLOOR,
      ROOM_NO type AD_ROOMNUM,
      COUNTRY type LAND1,
      LANGU type SPRAS,
      REGION type REGIO,
      SORT1 type AD_SORT1,
      SORT2 type AD_SORT2,
      TIME_ZONE type AD_TZONE,
      TAXJURCODE type AD_TXJCD,
      ADR_NOTES type AD_REMARK1,
      COMM_TYPE type AD_COMM,
      TEL1_NUMBR type AD_TLNMBR1,
      TEL1_EXT type AD_TLXTNS1,
      FAX_NUMBER type AD_FXNMBR1,
      FAX_EXTENS type AD_FXXTNS1,
      STREET_LNG type AD_STREET,
      DISTRCT_NO type AD_CITYPNM,
      CHCKSTATUS type AD_CHECKST,
      PBOXCIT_NO type AD_CIT2NUM,
      TRANSPZONE type LZONE,
      HOUSE_NO2 type AD_HSNM2,
      E_MAIL type AD_SMTPADR,
      STR_SUPPL3 type AD_STRSPP3,
      TITLE type AD_TITLETX,
      COUNTRYISO type INTCA,
      LANGU_ISO type LAISO,
      BUILD_LONG type AD_BLDNG,
      REGIOGROUP type REGIOGROUP,
      HOME_CITY type AD_CITY3,
      HOMECITYNO type AD_CITYHNM,
      PCODE1_EXT type AD_PST1XT,
      PCODE2_EXT type AD_PST2XT,
      PCODE3_EXT type AD_PST3XT,
      PO_W_O_NO type AD_POBXNUM,
      PO_BOX_REG type AD_POBXREG,
      POBOX_CTRY type AD_POBXCTY,
      PO_CTRYISO type INTCA,
      HOMEPAGE type AD_URISCR,
      DONT_USE_S type AD_NO_USES,
      DONT_USE_P type AD_NO_USEP,
      HOUSE_NO3 type AD_HSNM3,
      LANGU_CR type AD_LANGUCR,
      LANGUCRISO type LAISO,
      PO_BOX_LOBBY type AD_PO_BOX_LBY,
      DELI_SERV_TYPE type AD_DELIVERY_SERVICE_TYPE,
      DELI_SERV_NUMBER type AD_DELIVERY_SERVICE_NUMBER,
      URI_TYPE type AD_URITYPE,
      COUNTY_CODE type AD_CNTYNUM,
      COUNTY type AD_COUNTY,
      TOWNSHIP_CODE type AD_TWSHPNUM,
      TOWNSHIP type AD_TOWNSHIP,
      XPCPT type AD_XPCPT,
    end of BAPIADDR1 .
  types:
    __BAPIADDR1                    type standard table of BAPIADDR1                      with non-unique default key .
endinterface.
