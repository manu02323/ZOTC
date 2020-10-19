*&---------------------------------------------------------------------*
*&  Include           ZOTCN0019O_ORDER_OUTPUT
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZOTCN0019O_ORDER_OUTPUT
*&---------------------------------------------------------------------*
************************************************************************
* INCLUDE    :  ZOTCN0019O_ORDER_OUTPUT                                *
* TITLE      :  Output Control Routines                                *
* DEVELOPER  :  Rohan Rana                                             *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   CR691(OTC_EDD_0091)                                     *
*----------------------------------------------------------------------*
* DESCRIPTION: control the triggering of output through assigning      *
*              a Delivery Block to the sales order header              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER     TRANSPORT  DESCRIPTION                         *
* ============ ======== ========== ====================================*
* 27-Dec-2013  RRANA    E1DK913465  INITIAL DEVELOPMENT   CR# 691      *
*&---------------------------------------------------------------------*
* 28-Aug-2019  U033814  E2DK926282  SCTASK0865054 if the status is     *
*                                   ZCP1 then fail the output.         *
*&---------------------------------------------------------------------*
* 15-Nov-2019 RNATHAK   E2DK928215  Defect 10901 - OTC_EDD_0019        *
*                                   changing from CA (Contains Any) to *
*                                   CS (Contains string)               *
*----------------------------------------------------------------------*

* Local Constant Declaration
  CONSTANTS :
* Transaction is 'Create' ( 'H' )
    lc_so_create TYPE trtyp VALUE 'H',
* Transaction is 'Change' ( 'V' )
    lc_so_change TYPE trtyp VALUE 'V',
* Constant for stack
    lc_prog_stk  TYPE char20 VALUE '(SAPMV45A)T180-TRTYP',
* Begin of SCTASK0862055
    lc_en        TYPE spras  VALUE  'E',
    lc_prog_stk1 TYPE char20 VALUE '(SAPMV45A)VBAK-OBJNR',
    lc_prog_stk2 TYPE char30 VALUE  '(SAPMV45A)XVBAP-ZZQUOTEREF',
* End of SCTASK0862055
*  Begin of change for INC0525294 OTC_EDD_0019_Defect# 10901 by RNATHAK dated 15/11/2019
    lc_cpq       TYPE char20 VALUE 'CPQ'.
*  End of change for INC0525294 OTC_EDD_0019_Defect# 10901 by RNATHAK dated 15/11/2019


* Field Symbol Declaration
  FIELD-SYMBOLS: <lfs_trtyp> TYPE trtyp,
* Begin of SCTASK0862055
                 <lfs_objnr> TYPE objko,
                 <lfs_quote> TYPE z_quoteref.
* End of SCTASK0862055

* Local variable Declaration
  DATA : lv_lifsp TYPE lifsp,  "Default delivery block
         lv_spedr TYPE spedr,  "Printing block
         lv_trtyp TYPE trtyp,  "transaction type
* Begin of SCTASK0862055
         lv_objnr TYPE objko,
         lv_quote TYPE z_quoteref,
         lv_stat  TYPE j_stext.
* End of SCTASK0862055
*Assign stack values to the field symbol
  ASSIGN (lc_prog_stk) TO <lfs_trtyp>.
  IF sy-subrc = 0.
* Store the value of transaction code in local variable
    lv_trtyp =  <lfs_trtyp>.
  ENDIF.

* Begin of SCTASK0862055
  IF lv_trtyp EQ lc_so_create.
*Assign stack values to the field symbol
    ASSIGN (lc_prog_stk2) TO <lfs_quote>.
    IF sy-subrc = 0.
* Store the value of transaction code in local variable
      lv_quote =  <lfs_quote>.
*  Begin of change for INC0525294 OTC_EDD_0019_Defect# 10901 by RNATHAK dated 15/11/2019
*      IF lv_quote CA 'CPQ' AND lv_quote IS NOT INITIAL.
      IF lv_quote CS lc_cpq AND lv_quote IS NOT INITIAL.
*  End of change for INC0525294 OTC_EDD_0019_Defect# 10901 by RNATHAK dated 15/11/2019
        sy-subrc = 4.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.
  IF lv_trtyp EQ lc_so_change.
    ASSIGN (lc_prog_stk2) TO <lfs_quote>.
    IF sy-subrc = 0.
* Store the value of transaction code in local variable
      lv_quote =  <lfs_quote>.
*  Begin of change for INC0525294 OTC_EDD_0019_Defect# 10901 by RNATHAK dated 15/11/2019
*      IF lv_quote CA 'CPQ' AND lv_quote IS NOT INITIAL.
       IF lv_quote CS lc_cpq AND lv_quote IS NOT INITIAL.
*  End of change for INC0525294 OTC_EDD_0019_Defect# 10901 by RNATHAK dated 15/11/2019
*Assign stack values to the field symbol
        ASSIGN (lc_prog_stk1) TO <lfs_objnr>.
        IF sy-subrc = 0.
* Store the value of transaction code in local variable
          lv_objnr =  <lfs_objnr>.
        ENDIF.
        CALL FUNCTION 'STATUS_TEXT_EDIT'
          EXPORTING
            client           = sy-mandt
            flg_user_stat    = abap_true
            objnr            = lv_objnr
            only_active      = abap_true
            spras            = lc_en
            bypass_buffer    = ' '
          IMPORTING
            user_line        = lv_stat
          EXCEPTIONS
            object_not_found = 1
            OTHERS           = 2.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
        IF lv_stat EQ 'ZCP1' And sy-cprog NE 'ZOTCO0229B_QUOTE_VALID_CPQ' or lv_stat EQ 'INIT'.
          sy-subrc = 4.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
* End of SCTASK0862055
* If Tcode is VA01 or VA02
  IF ( lv_trtyp EQ lc_so_create ) OR ( lv_trtyp EQ lc_so_change ).

* If Delivery block is initial then output type will be triggered
    IF komkbv1-lifsk IS INITIAL.
      sy-subrc = 0.
    ENDIF.
* If Delivery block is not initial we will check for Printing block
* where VBAK – LIFSK = TVLS- LIFSP
    IF komkbv1-lifsk IS NOT INITIAL.
* Fetch the values from Table TVLS for printing block
      SELECT SINGLE
             lifsp   "Default delivery block
             spedr   "Printing block
             INTO (lv_lifsp, lv_spedr)
             FROM  tvls
             WHERE lifsp = komkbv1-lifsk.
      IF sy-subrc = 0.
* Check if print block = 'X' then do not trigger the output
        IF lv_spedr IS NOT INITIAL.
          sy-subrc = 4.   "by passing 4, the output type will
          EXIT.           "Not trigger
        ENDIF.
* Check if print block is initial then output is triggered
        IF lv_spedr IS INITIAL.
          sy-subrc = 0.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
