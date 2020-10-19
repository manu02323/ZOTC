*&--------------------------------------------------------------------*
*&FUNCTION POOL      :  SAPLZOTC_VKOE                                 *
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

*******************************************************************
*   System-defined Include-files.                                 *
*******************************************************************
  INCLUDE LZOTC_VKOETOP.                     " Global Data
  INCLUDE LZOTC_VKOEUXX.                     " Function Modules

*******************************************************************
*   User-defined Include-files (if necessary).                    *
*******************************************************************
* INCLUDE LZOTC_VKOEF...                     " Subroutines
* INCLUDE LZOTC_VKOEO...                     " PBO-Modules
* INCLUDE LZOTC_VKOEI...                     " PAI-Modules
* INCLUDE LZOTC_VKOEE...                     " Events
* INCLUDE LZOTC_VKOEP...                     " Local class implement.
* INCLUDE LZOTC_VKOET99.                     " ABAP Unit tests
