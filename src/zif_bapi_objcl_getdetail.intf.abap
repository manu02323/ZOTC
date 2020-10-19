interface ZIF_BAPI_OBJCL_GETDETAIL
  public .


  types:
    KLASSE_D type C length 000018 .
  types:
    KLASSENART type C length 000003 .
  types:
    OBJNUM type C length 000050 .
  types:
    TABELLE type C length 000030 .
  types:
    CLSTATUS type C length 000001 .
  types:
    AENNR type C length 000012 .
  types:
    STDCLASS type C length 000001 .
  types:
    FLAG type C length 000001 .
  types:
    CUOBJ type N length 000018 .
  types:
    CUOBN90 type C length 000090 .
  types:
    begin of BAPI1003_KEY,
      CLASSNUM type KLASSE_D,
      CLASSTYPE type KLASSENART,
      OBJECT type OBJNUM,
      OBJECTTABLE type TABELLE,
      KEYDATE type DATS,
      STATUS type CLSTATUS,
      CHANGENUMBER type AENNR,
      STDCLASS type STDCLASS,
      FLAG type FLAG,
      OBJECT_GUID type CUOBJ,
      OBJECT_LONG type CUOBN90,
    end of BAPI1003_KEY .
  types:
    BAPILANGUA type C length 000001 .
  types:
    begin of BAPIFIELDSCACL,
      BAPILANGUA type BAPILANGUA,
    end of BAPIFIELDSCACL .
  types:
    ATNAM type C length 000030 .
  types:
    ATWRT type C length 000030 .
  types:
    FLINH type C length 000001 .
  types:
    ATZIS type N length 000003 .
  types:
    ATBEZ type C length 000030 .
  types:
    ATWRT70 type C length 000070 .
  types:
    begin of BAPI1003_ALLOC_VALUES_CHAR,
      CHARACT type ATNAM,
      VALUE_CHAR type ATWRT,
      INHERITED type FLINH,
      INSTANCE type ATZIS,
      VALUE_NEUTRAL type ATWRT,
      CHARACT_DESCR type ATBEZ,
      VALUE_CHAR_LONG type ATWRT70,
      VALUE_NEUTRAL_LONG type ATWRT70,
    end of BAPI1003_ALLOC_VALUES_CHAR .
  types:
    __BAPI1003_ALLOC_VALUES_CHAR   type standard table of BAPI1003_ALLOC_VALUES_CHAR     with non-unique default key .
  types ATFLV type F .
  types ATFLB type F .
  types:
    ATCOD type C length 000001 .
  types:
    WAERS type C length 000005 .
  types:
    ISOCD type C length 000003 .
  types:
    begin of BAPI1003_ALLOC_VALUES_CURR,
      CHARACT type ATNAM,
      VALUE_FROM type ATFLV,
      VALUE_TO type ATFLB,
      VALUE_RELATION type ATCOD,
      CURRENCY_FROM type WAERS,
      CURRENCY_TO type WAERS,
      CURRENCY_FROM_ISO type ISOCD,
      CURRENCY_TO_ISO type ISOCD,
      INHERITED type FLINH,
      INSTANCE type ATZIS,
      CHARACT_DESCR type ATBEZ,
    end of BAPI1003_ALLOC_VALUES_CURR .
  types:
    __BAPI1003_ALLOC_VALUES_CURR   type standard table of BAPI1003_ALLOC_VALUES_CURR     with non-unique default key .
  types:
    MEINS type C length 000003 .
  types:
    MEINS_ISO type C length 000003 .
  types:
    begin of BAPI1003_ALLOC_VALUES_NUM,
      CHARACT type ATNAM,
      VALUE_FROM type ATFLV,
      VALUE_TO type ATFLB,
      VALUE_RELATION type ATCOD,
      UNIT_FROM type MEINS,
      UNIT_TO type MEINS,
      UNIT_FROM_ISO type MEINS_ISO,
      UNIT_TO_ISO type MEINS_ISO,
      INHERITED type FLINH,
      INSTANCE type ATZIS,
      CHARACT_DESCR type ATBEZ,
    end of BAPI1003_ALLOC_VALUES_NUM .
  types:
    __BAPI1003_ALLOC_VALUES_NUM    type standard table of BAPI1003_ALLOC_VALUES_NUM      with non-unique default key .
  types:
    BAPI_MTYPE type C length 000001 .
  types:
    SYMSGID type C length 000020 .
  types:
    SYMSGNO type N length 000003 .
  types:
    BAPI_MSG type C length 000220 .
  types:
    BALOGNR type C length 000020 .
  types:
    BALMNR type N length 000006 .
  types:
    SYMSGV type C length 000050 .
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
endinterface.
