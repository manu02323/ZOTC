*&--------------------------------------------------------------------*
*&INCLUDE            :  ZXVKOU03                                      *
* TITLE              :  Creation of IDOC for message type COND_A      *
* DEVELOPER          :  Moushumi Bhattacharya                         *
* OBJECT TYPE        :  INTERFACE                                     *
* SAP RELEASE        :  SAP ECC 6.0                                   *
*---------------------------------------------------------------------*
* WRICEF ID  :  D2_OTC_IDD_0093                                       *
*---------------------------------------------------------------------*
* DESCRIPTION: THis User Exit adds the custom segment into the Idoc   *
*---------------------------------------------------------------------*
* MODIFICATION HISTORY:                                               *
*=====================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                         *
* =========== ======== ===============================================*
* 21-MAY-2014 MBHATTA1 E2DK902074 INITIAL DEVELOPMENT                 *
*                                                                     *
* 13-Mar-2015 NSAXENA  E2DK902074 Defect #4846 - Field KUNNR is not   *
*popultng at header level,chngs insde nw incld zotcn0093b_idoc_cond_a1*
*---------------------------------------------------------------------*
* ---> Begin of Insert for D2_OTC_IDD_0093,Defect #4846 by NSAXENA

*Code in include zotcn0093b_idoc_cond_a has been copied to new
* include zotcn0093b_idoc_cond_a1 as include zotcn0093b_idoc_cond_a is
*having editor lock so cannot modify this code.Only Commenting out it.

*INCLUDE zotcn0093b_idoc_cond_a. " Include ZOTCN0093B_IDOC_COND_A

INCLUDE zotcn0093b_idoc_cond_a1. " Include ZOTCN0093B_IDOC_COND_A1
* <--- End of Insert for D2_OTC_IDD_0093,Defect #4846 by NSAXENA
