FUNCTION ZOTC_EDD_0234_CONVERSION.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_INPUT)   No type assigned to keep it same as standard
*"  EXPORTING
*"     VALUE(EX_OUTPUT)  No type assigned to keep it same as standard
*"----------------------------------------------------------------------
************************************************************************
* PROGRAM    : ZOTC_0234_COVERSION                                     *
* TITLE      : D3_OTC_EDD_0234_EHQ_Determine Delivery type             *
* DEVELOPER  : Jayanta Ray                                             *
* OBJECT TYPE: Enhancement                                             *
* SAP RELEASE: SAP ECC 6.0                                             *
*----------------------------------------------------------------------*
* WRICEF ID: D3_OTC_EDD_0234                                           *
*----------------------------------------------------------------------*
* DESCRIPTION:
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER     TRANSPORT  DESCRIPTION                         *
* ===========  ======== ========== ====================================*
* 04.25.2017   U033867  E1DK927636   Defect#2713 Coversion routine to  *
*                                    get time duration.Below logic has *
*                                    been copied from standard FM      *
*                                    CONVERSION_EXIT_TSTRG_OUTPUT      *
*&---------------------------------------------------------------------*

  TYPES:
  BEGIN OF lty_sts4_durationstruc,
    hours   TYPE numc7, " Hours(7) of type Numeric Text Fields
    minutes TYPE numc2, " Minutes(2) of type Numeric Text Fields
    seconds TYPE numc2, " Seconds(2) of type Numeric Text Fields
    sign    TYPE char1, " Sign of type Character
  END   OF lty_sts4_durationstruc.

  DATA:
    lv_input   TYPE tstrbreaks, " Time stream: Proportionate breaks in hhhhhh:mm:ss
    lv_output  TYPE char10,     " Output of type CHAR10
    lv_inputstruc         TYPE lty_sts4_durationstruc,
    lv_convstruc          type tstrconv2, " Output conversion for TSTRDURAG/TSTRDURAN Option 2
    lv_offset             type SYFDPOS,  " Found Location in Byte or Character String
    lv_days4(4)           TYPE n,         " Days4(4) of type Numeric Text Fields
    lv_timestruc          TYPE tstr_timestr,
    lv_time               TYPE t,         " Time of type
    lv_timeint            TYPE i,         " Timeint of type Integers
    lv_frac2(2)           TYPE n.         " Frac2(2) of type Numeric Text Fields

  FIELD-SYMBOLS:
    <lfs_char> TYPE c. " <char> of type Character
  CONSTANTS: lc_dot   TYPE c   VALUE '.'. " Dot of type Character

* move into correct types
  lv_input = im_input.

* convert
  lv_inputstruc         =  lv_input.
  TRANSLATE lv_inputstruc USING ' 0'.
  lv_convstruc-days4    =  lv_days4      =  lv_inputstruc-hours DIV 24.
  lv_timestruc-hour     =  lv_inputstruc-hours MOD 24.
  lv_timestruc-minute   =  lv_inputstruc-minutes.
  lv_timestruc-second   =  lv_inputstruc-seconds.
  lv_timeint            =  lv_time       =  lv_timestruc.
  lv_convstruc-frac2    =  lv_frac2      =  lv_timeint DIV 864.
* remove initial value / leading zeroes (days)
  DO 3 TIMES.
    lv_offset = sy-index - 1.
    ASSIGN lv_convstruc-days4+lv_offset(1) TO <lfs_char>.
    IF <lfs_char> CN ' 0'.
      EXIT.
    ELSE. " ELSE -> IF <char> CN ' 0'
      <lfs_char> = space.
    ENDIF. " IF <char> CN ' 0'
  ENDDO.
* remove initial values (fractions of day)
  IF lv_days4 IS INITIAL.
    IF lv_frac2 IS INITIAL.
      CLEAR: lv_convstruc-days4,
             lv_convstruc-frac2.
    ELSE. " ELSE -> IF lv_frac2 IS INITIAL
      lv_convstruc-decim = lc_dot.
    ENDIF. " IF lv_frac2 IS INITIAL
  ELSE. " ELSE -> IF lv_days4 IS INITIAL
    lv_convstruc-decim = lc_dot.
  ENDIF. " IF lv_days4 IS INITIAL

  lv_output = lv_convstruc.

  ex_output = lv_output .




ENDFUNCTION.
