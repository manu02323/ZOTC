************************************************************************
* Program          :  ZOTCR0337B_EXIT_KEII_VF44 (Report)               *
* TITLE            :  Implementing note 829292 Transfer of Quantity and*
*                     Value Fields                                     *
* DEVELOPER        :  NASRIN ALI                                       *
* OBJECT TYPE      :  ENHANCEMENT                                      *
* SAP RELEASE      :  SAP ECC 6.0                                      *
*----------------------------------------------------------------------*
*  WRICEF ID       :  D3_OTC_EDD_0337                                  *
*----------------------------------------------------------------------*
* DESCRIPTION      :  Implementing note 829292 Transfer of Quantity and*
*                     Value Fields                                     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER     TRANSPORT   DESCRIPTION                        *
* ===========  ======== ==========  ===================================*
* 01-JUN-2016  NALI     E1DK918440  INITIAL DEVELOPMENT                *
*&---------------------------------------------------------------------*
REPORT ZOTCR0337B_EXIT_KEII_VF44 NO STANDARD PAGE HEADING "  class
                                         LINE-SIZE 132
                                         MESSAGE-ID zotc_msg.

*&---------------------------------------------------------------------*
*&      Form  f_run_exit
*&---------------------------------------------------------------------*
*       <-- FP_EXIT_ACTIVE "Exit is active
*       <-- FP_BUKRS "Company Code
*       <-- FP_SUMMERIZATION_ACtIVE " Sum at Item Level
*----------------------------------------------------------------------*
FORM f_run_exit CHANGING fp_exit_active          TYPE c
                       fp_bukrs                TYPE accit-bukrs
                       fp_summerization_active TYPE c  ##CALLED.
CONSTANTS: lc_bukrs_x TYPE char04 VALUE 'XXXX'.
  fp_exit_active          = abap_true.
*  fp_bukrs                = lc_bukrs_x.
  fp_summerization_active = abap_true.                       "sum at item level

*  MESSAGE i089. "Report ZOTCR0337B_EXIT_KEII_VF44 is called.
ENDFORM.                    "run_exit
