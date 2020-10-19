function zotc_rv_condition_reset.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(FREE_MEMORY) TYPE  C OPTIONAL
*"----------------------------------------------------------------------
************************************************************************
* Function Module    :  ZOTC_RV_CONDITION_RESET                        *
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

  call function 'RV_CONDITION_RESET'
    exporting
      free_memory = free_memory.
  .
endfunction.
