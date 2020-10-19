FUNCTION ZOTC_003_DASHBOARD_DETAILS .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_CS_GRP) TYPE  CHAR10 OPTIONAL
*"  EXPORTING
*"     VALUE(EX_ORDCOUNT) TYPE  I
*"     VALUE(EX_DLYCOUNT) TYPE  I
*"     VALUE(ET_DLYVBELN) TYPE  TT_VBELN
*"     VALUE(EV_DLYDATE) TYPE  STRING
*"     VALUE(EX_CRDCOUNT) TYPE  I
*"     VALUE(ET_CRDVBELN) TYPE  TT_VBELN
*"     VALUE(ET_ADDRESS) TYPE  BAPIADDR3
*"     VALUE(ET_ORDER_COUNT) TYPE  ZOTC_OPEN_ORDERS_T
*"     VALUE(EX_ANCEMENT_DATA) TYPE  STRING_VALUE
*"     VALUE(EX_ZIUSER) TYPE  BAPIPARAM-PARVA
*"----------------------------------------------------------------------
***********************************************************************
*Program    : ZOTC_003_DASHBOARD_DETAILS                              *
*Title      : Dashboard Details                                       *
*Developer  : Manoj Thatha                                            *
*Object type: Funtion Module                                          *
*SAP Release: SAP ECC 8.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_MDD_0003                                           *
*---------------------------------------------------------------------*
*Description: Get Dashboard details                                   *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*======================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ============================*
*10-Sept-2019   mthatha     E2DK927306    Initial Development
*31-Oct-2019    mthatha     E2DK927828    D#10926 Open orders
*----------------------------------------------------------------------*
*--Begin of change by mthatha INC0524777
  CONSTANTS:C_MDD_0003 TYPE Z_ENHANCEMENT VALUE 'OTC_MDD_0003',          " Enhancement No.
            C_NULL     TYPE Z_CRITERIA    VALUE 'NULL',
            C_OTYPE    TYPE Z_CRITERIA    VALUE 'ORDTYPE'.
*--End of change by mthatha INC0524777
  TYPES:BEGIN OF TY_VBELN,
          VBELN TYPE VBELN,
        END OF TY_VBELN.
  DATA:LI_VBELN      TYPE TABLE OF TY_VBELN,
       LR_OTYPE      TYPE RANGE OF AUART,
       LI_CONSTANT   TYPE STANDARD TABLE OF ZDEV_ENH_STATUS INITIAL SIZE 0, " Enhancement Status
       lwa_otype     LIKE LINE OF lr_otype,
       LI_RETURN     TYPE TABLE OF BAPIRET2,
       LV_DATE       TYPE ERDAT,
       LT_PARAMETERS TYPE TABLE OF BAPIPARAM.
  FIELD-SYMBOLS: <FS_PARAM> TYPE BAPIPARAM.
*--Begin of change by mthatha INC0524777
* Getting all the constant values.
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      IV_ENHANCEMENT_NO = C_MDD_0003
    TABLES
      TT_ENH_STATUS     = LI_CONSTANT.
*--Get User details
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      USERNAME  = SY-UNAME
*     CACHE_RESULTS        = 'X'
    IMPORTING
      ADDRESS   = ET_ADDRESS
    TABLES
      PARAMETER = LT_PARAMETERS
      RETURN    = LI_RETURN.

  LOOP AT LT_PARAMETERS ASSIGNING <FS_PARAM> WHERE PARID = 'ZIUSER'.
    EX_ZIUSER = <FS_PARAM>-PARVA.
  ENDLOOP.
*--Begin of defect#10926 by mthatha
*--Order Count details
  LV_DATE = SY-DATUM - 60.
  LOOP AT LI_CONSTANT ASSIGNING FIELD-SYMBOL(<LFS_CONSTANT>) WHERE CRITERIA EQ C_OTYPE.
    LWA_OTYPE-LOW = <LFS_CONSTANT>-SEL_LOW.
    LWA_OTYPE-SIGN = 'I'.
    LWA_OTYPE-OPTION = 'EQ'.
    APPEND LWA_OTYPE TO LR_OTYPE.
  ENDLOOP.
*--End of defect#10926 by mthatha
  IF EX_ZIUSER <> ''.
    SELECT VBELN INTO TABLE LI_VBELN FROM VBAK
                             WHERE ERDAT GE LV_DATE AND
                                   ERNAM IN (SY-UNAME, EX_ZIUSER)
                                   AND auart IN lr_otype.
  ELSE.
    SELECT VBELN INTO TABLE LI_VBELN FROM VBAK
                             WHERE ERDAT GE LV_DATE AND
                                   ERNAM = SY-UNAME AND
                                   auart IN lr_otype.
  ENDIF.

  IF LI_VBELN[] IS NOT INITIAL.
    SELECT COUNT(*) INTO EX_ORDCOUNT FROM VBUK FOR ALL ENTRIES IN LI_VBELN
                                            WHERE VBELN  = LI_VBELN-VBELN
*--Begin of defect#10926 by mthatha
                                                  AND   GBSTK NE 'C'.
*--End of defect#10926 by mthatha
  ENDIF.

*--Delivery block count
  IF EX_ZIUSER <> ''.
    SELECT VBELN INTO TABLE ET_DLYVBELN FROM VBAK
                             WHERE ERDAT GE LV_DATE AND
                                   ERNAM IN (SY-UNAME, EX_ZIUSER) AND
                                   LIFSK <> SPACE. "Delivery Block
  ELSE.
    SELECT VBELN INTO TABLE ET_DLYVBELN FROM VBAK
                             WHERE ERDAT GE LV_DATE AND
                                   ERNAM = SY-UNAME AND
                                   LIFSK <> SPACE. "Delivery Block
  ENDIF.

  IF ET_DLYVBELN[] IS NOT INITIAL.
    "Table Count
    DESCRIBE TABLE ET_DLYVBELN LINES EX_DLYCOUNT.
  ENDIF.
*--Credit block count
  IF EX_ZIUSER <> ''.
    SELECT A~VBELN FROM VBAK AS A
        INNER JOIN VBUK AS B ON
        A~VBELN = B~VBELN AND
        A~ERDAT GE @LV_DATE AND
        A~ERNAM IN (@SY-UNAME, @EX_ZIUSER) AND
        B~CMGST IN ('B', 'C')
      INTO TABLE @ET_CRDVBELN.
  ELSE.
    SELECT A~VBELN FROM VBAK AS A
        INNER JOIN VBUK AS B ON
        A~VBELN = B~VBELN AND
        A~ERDAT GE @LV_DATE AND
        A~ERNAM = @SY-UNAME AND
        B~CMGST IN ('B', 'C')
      INTO TABLE @ET_CRDVBELN.
  ENDIF.
  IF ET_CRDVBELN[] IS NOT INITIAL.
    "Table Count
    DESCRIBE TABLE ET_CRDVBELN LINES EX_CRDCOUNT.
  ENDIF.

*--Chart table data
  TYPES:BEGIN OF TY_VBAK,
          VBELN    TYPE VBELN,
          ERDAT    TYPE ERDAT,
          YEAR(4)  TYPE C,
          MONTH(2) TYPE C,
        END OF TY_VBAK.

  DATA: LV_YEAR(4)     TYPE C,
        LS_OPEN_ORDERS TYPE ZOTC_OPEN_ORDERS_S,
        IT_VBAK        TYPE TABLE OF TY_VBAK.

  LV_DATE = SY-DATUM - 30.
  SELECT VBELN ERDAT INTO TABLE IT_VBAK FROM VBAK
                             WHERE ERDAT GE LV_DATE.

  DATA LV_MONTH(2).
  DATA: LV_COUNT_JAN  TYPE I,
        LV_COUNT_FEB  TYPE I,
        LV_COUNT_MAR  TYPE I,
        LV_COUNT_APR  TYPE I,
        LV_COUNT_MAY  TYPE I,
        LV_COUNT_JUNE TYPE I,
        LV_COUNT_JULY TYPE I,
        LV_COUNT_AUG  TYPE I,
        LV_COUNT_SEP  TYPE I,
        LV_COUNT_OCT  TYPE I,
        LV_COUNT_NOV  TYPE I,
        LV_COUNT_DEC  TYPE I.

  SORT IT_VBAK BY ERDAT.

  LOOP AT IT_VBAK ASSIGNING FIELD-SYMBOL(<FS_VBAK>).
    LV_YEAR = <FS_VBAK>-ERDAT+0(4).
    LV_MONTH = <FS_VBAK>-ERDAT+4(2).

    CASE LV_MONTH.
      WHEN '01'.
        LV_COUNT_JAN = LV_COUNT_JAN + 1.
      WHEN '02'.
        LV_COUNT_FEB = LV_COUNT_FEB + 1.
      WHEN '03'.
        LV_COUNT_MAR = LV_COUNT_MAR + 1.
      WHEN '04'.
        LV_COUNT_APR = LV_COUNT_APR + 1.
      WHEN '05'.
        LV_COUNT_MAY = LV_COUNT_MAY + 1.
      WHEN '06'.
        LV_COUNT_JUNE = LV_COUNT_JUNE + 1.
      WHEN '07'.
        LV_COUNT_JULY = LV_COUNT_JULY + 1.
      WHEN '08'.
        LV_COUNT_AUG = LV_COUNT_AUG + 1.
      WHEN '09'.
        LV_COUNT_SEP = LV_COUNT_SEP + 1.
      WHEN '10'.
        LV_COUNT_OCT = LV_COUNT_OCT + 1.
      WHEN '11'.
        LV_COUNT_NOV = LV_COUNT_NOV + 1.
      WHEN '12'.
        LV_COUNT_DEC = LV_COUNT_DEC + 1.
    ENDCASE.
  ENDLOOP.

* January Count
  IF LV_COUNT_JAN IS NOT INITIAL.
    LS_OPEN_ORDERS-YEAR = LV_YEAR.
    LS_OPEN_ORDERS-MONTH = 'Jan'.
    LS_OPEN_ORDERS-COUNT = LV_COUNT_JAN.
    APPEND LS_OPEN_ORDERS TO ET_ORDER_COUNT.
  ENDIF.

* Febuary Count
  CLEAR LS_OPEN_ORDERS.
  IF LV_COUNT_FEB IS NOT INITIAL.
    LS_OPEN_ORDERS-YEAR = LV_YEAR.
    LS_OPEN_ORDERS-MONTH = 'Feb'.
    LS_OPEN_ORDERS-COUNT = LV_COUNT_FEB.
    APPEND LS_OPEN_ORDERS TO ET_ORDER_COUNT.
  ENDIF.

* March Count
  CLEAR LS_OPEN_ORDERS.
  IF LV_COUNT_MAR IS NOT INITIAL.
    LS_OPEN_ORDERS-YEAR = LV_YEAR.
    LS_OPEN_ORDERS-MONTH = 'March'.
    LS_OPEN_ORDERS-COUNT = LV_COUNT_MAR.
    APPEND LS_OPEN_ORDERS TO ET_ORDER_COUNT.
  ENDIF.
*
* Apr Count
  CLEAR LS_OPEN_ORDERS.
  IF LV_COUNT_APR IS NOT INITIAL.
    LS_OPEN_ORDERS-YEAR = LV_YEAR.
    LS_OPEN_ORDERS-MONTH = 'April'.
    LS_OPEN_ORDERS-COUNT = LV_COUNT_APR.
    APPEND LS_OPEN_ORDERS TO ET_ORDER_COUNT.
  ENDIF.

* May Count
  CLEAR LS_OPEN_ORDERS.
  IF LV_COUNT_MAY IS NOT INITIAL.
    LS_OPEN_ORDERS-YEAR = LV_YEAR.
    LS_OPEN_ORDERS-MONTH = 'May'.
    LS_OPEN_ORDERS-COUNT = LV_COUNT_MAY.
    APPEND LS_OPEN_ORDERS TO ET_ORDER_COUNT.
  ENDIF.

* June Count
  CLEAR LS_OPEN_ORDERS.
  IF LV_COUNT_JUNE IS NOT INITIAL.
    LS_OPEN_ORDERS-YEAR = LV_YEAR.
    LS_OPEN_ORDERS-MONTH = 'June'.
    LS_OPEN_ORDERS-COUNT = LV_COUNT_JUNE.
    APPEND LS_OPEN_ORDERS TO ET_ORDER_COUNT.
  ENDIF.

* July Count
  CLEAR LS_OPEN_ORDERS.
  IF LV_COUNT_JULY IS NOT INITIAL.
    LS_OPEN_ORDERS-YEAR = LV_YEAR.
    LS_OPEN_ORDERS-MONTH = 'July'.
    LS_OPEN_ORDERS-COUNT = LV_COUNT_JULY.
    APPEND LS_OPEN_ORDERS TO ET_ORDER_COUNT.
  ENDIF.

* Aug Count
  CLEAR LS_OPEN_ORDERS.
  IF LV_COUNT_AUG IS NOT INITIAL.
    LS_OPEN_ORDERS-YEAR = LV_YEAR.
    LS_OPEN_ORDERS-MONTH = 'Aug'.
    LS_OPEN_ORDERS-COUNT = LV_COUNT_AUG.
    APPEND LS_OPEN_ORDERS TO ET_ORDER_COUNT.
  ENDIF.

* September Count
  CLEAR LS_OPEN_ORDERS.
  IF LV_COUNT_SEP IS NOT INITIAL.
    LS_OPEN_ORDERS-YEAR = LV_YEAR.
    LS_OPEN_ORDERS-MONTH = 'Sep'.
    LS_OPEN_ORDERS-COUNT = LV_COUNT_SEP.
    APPEND LS_OPEN_ORDERS TO ET_ORDER_COUNT.
  ENDIF.

* October Count
  CLEAR LS_OPEN_ORDERS.
  IF LV_COUNT_OCT IS NOT INITIAL.
    LS_OPEN_ORDERS-YEAR = LV_YEAR.
    LS_OPEN_ORDERS-MONTH = 'October'.
    LS_OPEN_ORDERS-COUNT = LV_COUNT_OCT.
    APPEND LS_OPEN_ORDERS TO ET_ORDER_COUNT.
  ENDIF.

* November Count
  CLEAR LS_OPEN_ORDERS.
  IF LV_COUNT_NOV IS NOT INITIAL.
    LS_OPEN_ORDERS-YEAR = LV_YEAR.
    LS_OPEN_ORDERS-MONTH = 'Nov'.
    LS_OPEN_ORDERS-COUNT = LV_COUNT_NOV.
    APPEND LS_OPEN_ORDERS TO ET_ORDER_COUNT.
  ENDIF.

* Dec Count
  CLEAR LS_OPEN_ORDERS.
  IF LV_COUNT_DEC IS NOT INITIAL.
    LS_OPEN_ORDERS-YEAR = LV_YEAR.
    LS_OPEN_ORDERS-MONTH = 'December'.
    LS_OPEN_ORDERS-COUNT = LV_COUNT_DEC.
    APPEND LS_OPEN_ORDERS TO ET_ORDER_COUNT.
  ENDIF.

  DATA:
    LREF_UTILITY    TYPE REF TO /BOFU/CL_FDT_UTIL, " BRFplus Utilities
    LREF_ADMIN_DATA TYPE REF TO IF_FDT_ADMIN_DATA, " FDT: Administrative Data
    LREF_FUNCTION   TYPE REF TO IF_FDT_FUNCTION,   " FDT: Function
    LREF_CONTEXT    TYPE REF TO IF_FDT_CONTEXT,    " FDT: Context
    LREF_RESULT     TYPE REF TO IF_FDT_RESULT,     " FDT: Result
    LREF_FDT        TYPE REF TO CX_FDT,            " FDT: Abstract Exception Class   ##NEEDED
    LV_QUERY_IN     TYPE        STRING,
    LV_QUERY_OUT    TYPE        IF_FDT_TYPES=>ID.


  CONSTANTS:
    LC_SEPARATOR TYPE XFELD     VALUE   '.'              , " Checkbox
    LC_NAME_APPL TYPE STRING    VALUE   'ZOTC_MDD_0003_ORDER_DETAILS',
    LC_NAME_FUNC TYPE STRING    VALUE   'ZOTC_F_ANNOUNCE_DATA'.


* Get BRF+ Data for Announcement

*-- Create an instance of BRFPlus Utility class
  LREF_UTILITY ?= /BOFU/CL_FDT_UTIL=>GET_INSTANCE( ).

*-- Make BRF query by concatenation of BRF application name and BRF Function name
  CONCATENATE LC_NAME_APPL LC_NAME_FUNC
         INTO LV_QUERY_IN
         SEPARATED BY LC_SEPARATOR.
*-- To get GUID of query string
  IF LREF_UTILITY IS BOUND.
    CALL METHOD LREF_UTILITY->CONVERT_FUNCTION_INPUT
      EXPORTING
        IV_INPUT  = LV_QUERY_IN
      IMPORTING
        EV_OUTPUT = LV_QUERY_OUT
      EXCEPTIONS
        FAILED    = 1
        OTHERS    = 2.
    IF SY-SUBRC IS INITIAL.
*-- Set the variable value(s)
      CL_FDT_FACTORY=>GET_INSTANCE_GENERIC( EXPORTING IV_ID = LV_QUERY_OUT
                                            IMPORTING EO_INSTANCE = LREF_ADMIN_DATA ).
      LREF_FUNCTION ?= LREF_ADMIN_DATA.
      LREF_CONTEXT  ?= LREF_FUNCTION->GET_PROCESS_CONTEXT( ).

* Get the Announcement
      LREF_CONTEXT->SET_VALUE( IV_NAME = 'CUST_GRP'  IA_VALUE = 'TEST' ).
      TRY.
          LREF_FUNCTION->PROCESS( EXPORTING IO_CONTEXT = LREF_CONTEXT
                                  IMPORTING EO_RESULT = LREF_RESULT ).
          LREF_RESULT->GET_VALUE( IMPORTING EA_VALUE = EX_ANCEMENT_DATA ).

        CATCH CX_FDT INTO LREF_FDT.                      ##no_handler
          CLEAR EX_ANCEMENT_DATA.
      ENDTRY.
    ENDIF.
  ENDIF.
ENDFUNCTION.
