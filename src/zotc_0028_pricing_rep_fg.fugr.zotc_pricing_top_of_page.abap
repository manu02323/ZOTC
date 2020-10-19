*&---------------------------------------------------------------------*
*& Function Module  ZOTC_PRICING_TOP_OF_PAGE
*&---------------------------------------------------------------------*
************************************************************************
* FM         :  ZOTC_PRICING_TOP_OF_PAGE                               *
* FG         :  ZOTC_0028_PRICING_REP_FG                               *
* TITLE      :  Top-Of-Page for Pricing Report                         *
* DEVELOPER  :  ROHIT VERMA                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  OTC_RDD_0028_Pricing Report for Mass Price Upload      *
*----------------------------------------------------------------------*
* DESCRIPTION:  FM to get Top-Of-Page for Pricing Report               *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 22-Jul-2013 RVERMA   E1DK910844 INITIAL DEVELOPMENT - CR#410         *
*&---------------------------------------------------------------------*

FUNCTION zotc_pricing_top_of_page.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_REP_TITLE) TYPE  STRING OPTIONAL
*"     REFERENCE(IM_TOT_RECORDS) TYPE  I OPTIONAL
*"  EXPORTING
*"     REFERENCE(EX_LISTHEADER) TYPE  SLIS_T_LISTHEADER
*"----------------------------------------------------------------------

*&--Local declaration
  DATA: lv_date        TYPE char10,  "date variable
        lv_time        TYPE char10,  "time variable
        lx_address     TYPE bapiaddr3, "User Address Data
        li_listheader  TYPE slis_t_listheader,   "List header internal tab
        lwa_listheader TYPE slis_listheader,     "List header Workarea
        li_return      TYPE STANDARD TABLE OF bapiret2. "return table

  lwa_listheader-typ  = 'H'(062).
  lwa_listheader-key  = 'Report'(057).
  IF im_rep_title IS NOT INITIAL.
    lwa_listheader-info = im_rep_title.
  ELSE.
    lwa_listheader-info = 'Pricing Report for Mass Price Upload'(054).
  ENDIF.
  APPEND lwa_listheader TO li_listheader.
  CLEAR lwa_listheader.

  lwa_listheader-typ  = 'S'(061).
  lwa_listheader-key  = 'User Name'(058).

*&--Get user details
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    IMPORTING
      address  = lx_address
    TABLES
      return   = li_return.

  IF lx_address-fullname IS NOT INITIAL.
    MOVE lx_address-fullname TO lwa_listheader-info.
  ELSE.
    MOVE sy-uname TO lwa_listheader-info.
  ENDIF.

  APPEND lwa_listheader TO li_listheader.
  CLEAR lwa_listheader.

  lwa_listheader-typ = 'S'(061).
  lwa_listheader-key = 'Date and Time'(059).

  CONCATENATE sy-uzeit+0(2)
              sy-uzeit+2(2)
              sy-uzeit+4(2)
         INTO lv_time
         SEPARATED BY c_colon.

  CONCATENATE sy-datum+4(2)
              sy-datum+6(2)
              sy-datum+0(4)
         INTO lv_date
         SEPARATED BY c_dot.

  CONCATENATE lv_date
              lv_time
         INTO lwa_listheader-info
         SEPARATED BY space.
  APPEND lwa_listheader TO li_listheader.
  CLEAR lwa_listheader.

  lwa_listheader-typ  = 'S'(061).
  lwa_listheader-key  = 'Total Records'(060).
  MOVE im_tot_records TO lwa_listheader-info.
  CONDENSE lwa_listheader-info NO-GAPS.
  APPEND lwa_listheader TO li_listheader.
  CLEAR lwa_listheader.

  ex_listheader = li_listheader.

ENDFUNCTION.
