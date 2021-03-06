*&--------------------------------------------------------------------*
*&FUNCTION MODULE    :  ZOTC_SET_VALUE                                *
* TITLE              :  Creation of IDOC for message type COND_A      *
* DEVELOPER          :  Moushumi Bhattacharya                         *
* OBJECT TYPE        :  INTERFACE                                     *
* SAP RELEASE        :  SAP ECC 6.0                                   *
*---------------------------------------------------------------------*
* WRICEF ID  :  D2_OTC_IDD_0093                                       *
*---------------------------------------------------------------------*
* DESCRIPTION:  This has been copied from MASTERIDOC_CREATE_SMD_COND_A*
*               Some changes have been made in the function           *
*               MASTER_CREATE_COND_A inside the perform EDIDD_FILL_AND*
*              SEND where irrelevant records are getting deleted based*
*               on sy-datum. Just after the function call irrelevant  *
*               change pointers are getting deleted based on sy-datum *
*---------------------------------------------------------------------*
* MODIFICATION HISTORY:                                               *
*=====================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                         *
* =========== ======== ===============================================*
* 21-MAY-2014 MBHATTA1 E2DK902074 INITIAL DEVELOPMENT                 *
*---------------------------------------------------------------------*

FUNCTION zotc_set_value.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_FLAG) TYPE  FLAG OPTIONAL
*"     REFERENCE(IM_FLAG2) TYPE  FLAG OPTIONAL
*"----------------------------------------------------------------------

* Setting the values into the Global Variable
  gv_flag  = im_flag.
  gv_flag2 = im_flag2.

ENDFUNCTION.
