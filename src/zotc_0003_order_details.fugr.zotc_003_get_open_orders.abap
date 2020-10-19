FUNCTION ZOTC_003_GET_OPEN_ORDERS.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(ET_ORDER_COUNT) TYPE  ZOTC_OPEN_ORDERS_T
*"----------------------------------------------------------------------

***********************************************************************
*Program    : ZOTC_0003_GET_ORDER_DETAILS                             *
*Title      : Get Order Details                                       *
*Developer  : ABdus Salam SK                                          *
*Object type: Funtion Module                                          *
*SAP Release: SAP ECC 8.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_MDD_0003                                           *
*---------------------------------------------------------------------*
*Description: Get Order related data foe SAP CSR overview screen      *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*======================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ============================*
*10-Sept-2019   ASK         E2DK927306    Initial Developmentr
*27-Oct-2019    MTHATHA     E2DK927735    INC0524777 Personas issue
*----------------------------------------------------------------------*
*--Begin of change by mthatha INC0524777
  CONSTANTS:C_MDD_0003 TYPE Z_ENHANCEMENT VALUE 'OTC_MDD_0003',          " Enhancement No.
            C_NULL     TYPE Z_CRITERIA    VALUE 'NULL',
            C_OTYPE    TYPE Z_CRITERIA    VALUE 'ORDTYPE'.
*--End of change by mthatha INC0524777
  TYPES:BEGIN OF TY_VBAK,
          VBELN    TYPE VBELN,
          ERDAT    TYPE ERDAT,
          VDATU    TYPE EDATU_VBAK,
          YEAR(4)  TYPE C,
          MONTH(2) TYPE C,
        END OF TY_VBAK.

  DATA: LR_DATE        TYPE RANGE OF ERDAT,
        LWA_DATE       LIKE LINE OF LR_DATE,
        LR_OTYPE       TYPE RANGE OF AUART,
        LWA_OTYPE      LIKE LINE OF LR_OTYPE,
        LV_DATE        TYPE ERDAT,
        LV_DATE1       TYPE ERDAT,
        LV_YEAR(4)     TYPE C,
        LV_YEAR1(4)    TYPE C,
        LS_OPEN_ORDERS TYPE ZOTC_OPEN_ORDERS_S,
        IT_VBAK        TYPE TABLE OF TY_VBAK.


  DATA LV_MONTH(2).
  DATA: I_CONSTANT    TYPE STANDARD TABLE OF ZDEV_ENH_STATUS INITIAL SIZE 0, " Enhancement Status
        LV_COUNT_JAN  TYPE I,
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
*--Begin of change by mthatha INC0524777
* Getting all the constant values.
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      IV_ENHANCEMENT_NO = C_MDD_0003
    TABLES
      TT_ENH_STATUS     = I_CONSTANT.
*--End of change by mthatha INC0524777
* Deleting those records from li_status where active is equla to space
  DELETE I_CONSTANT WHERE ACTIVE EQ SPACE.
  READ TABLE I_CONSTANT WITH KEY CRITERIA = C_NULL "NULL
                        TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ  0.
*--Get order details last month
    LV_DATE  = SY-DATUM - 30.
    LV_DATE1 = SY-DATUM.

*--Begin of change by mthatha INC0524777
    LWA_DATE-LOW = LV_DATE.
    LWA_DATE-HIGH = LV_DATE1.
    LWA_DATE-SIGN = 'I'.
    LWA_DATE-OPTION = 'BT'.
    APPEND LWA_DATE TO LR_DATE.
    LOOP AT I_CONSTANT ASSIGNING FIELD-SYMBOL(<LFS_CONSTANT>) WHERE CRITERIA EQ C_OTYPE.
      LWA_OTYPE-LOW = <LFS_CONSTANT>-SEL_LOW.
      LWA_OTYPE-SIGN = 'I'.
      LWA_OTYPE-OPTION = 'EQ'.
      APPEND LWA_OTYPE TO LR_OTYPE.
    ENDLOOP.

    SELECT VBELN ERDAT VDATU INTO TABLE IT_VBAK FROM VBAKUK
                             WHERE AUART IN LR_OTYPE
                             AND   ERDAT IN LR_DATE
                             AND   VDATU LE LV_DATE1
                             AND   GBSTK NE 'C'.
    IF SY-SUBRC EQ 0.
      SORT IT_VBAK BY ERDAT.
    ENDIF.
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
      IF LV_COUNT_JAN IS NOT INITIAL.
        LS_OPEN_ORDERS-YEAR = LV_YEAR - 1.
      ELSE.
        LS_OPEN_ORDERS-YEAR = LV_YEAR.
      ENDIF.
      LS_OPEN_ORDERS-MONTH = 'December'.
      LS_OPEN_ORDERS-COUNT = LV_COUNT_DEC.
      APPEND LS_OPEN_ORDERS TO ET_ORDER_COUNT.
    ENDIF.
*--Begin of change by mthatha INC0524777
  ENDIF.
*--End of change by mthatha INC0524777

ENDFUNCTION.
