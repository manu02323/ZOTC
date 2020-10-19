************************************************************************
* PROGRAM    :  ZOTCE0213O_MAINT_TAB_PART2EMP                          *
* TITLE      :  Program to maintain Partner to Employee table          *
* DEVELOPER  :  Mayukh CHatterjee                                      *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
*  WRICEF ID :  D2_OTC_EDD_0213                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Program for online maintenance of  Partner to Employee *
*               table                                                  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 02-OCT-2014 MCHATTE  E2DK904939  INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZOTCE0213O_MAINT_TAB_P2E_SEL
*&---------------------------------------------------------------------*

PARAMETERS: rb_add RADIOBUTTON GROUP rb1 USER-COMMAND cmd DEFAULT 'X',
            rb_chg RADIOBUTTON GROUP rb1.

SELECT-OPTIONS: s_vkorg FOR gv_vkorg MODIF ID gr1,
                s_vtweg FOR gv_vtweg MODIF ID gr1,
                s_spart FOR gv_spart MODIF ID gr1,
                s_terrid FOR gv_terrid MODIF ID gr1 MATCHCODE OBJECT zotc_sh_terrid.
