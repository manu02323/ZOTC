function zotc_rv_condition_save.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_KNUMH) TYPE  KNUMH OPTIONAL
*"     REFERENCE(I_NO_POSTING) TYPE  XFELD OPTIONAL
*"  TABLES
*"      KNUMH_MAP STRUCTURE  KNUMH_COMP OPTIONAL
*"----------------------------------------------------------------------
************************************************************************
* Function Module    :  ZOTC_RV_CONDITION_SAVE                         *
* TITLE      :  OTC_IDD_42_Price Load                                  *
* DEVELOPER  :  Shammi Puri                                            *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_42_Price Load
*----------------------------------------------------------------------*
* DESCRIPTION: Wrapper Function Module to Create Condition type. Since
* standard function modules are not released , these are copied into
* custom Function modules and called Wrapper FM.
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 05-June-2012 SPURI  E1DK901668 INITIAL DEVELOPMENT                   *
*&---------------------------------------------------------------------*
  call function 'RV_CONDITION_SAVE'
    exporting
      i_knumh      = i_knumh
      i_no_posting = i_no_posting
    tables
      knumh_map    = knumh_map.
endfunction.
