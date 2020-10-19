************************************************************************
* PROGRAM    :  ZOTCE0213O_MAINT_TAB_TERRASSN                          *
* TITLE      :  Program to maintain Territory Assignment table         *
* DEVELOPER  :  Mayukh CHatterjee                                      *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
*  WRICEF ID :  D2_OTC_EDD_0213                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Program for online maintenance of Territory Assignment *
*               table                                                  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 02-OCT-2014 MCHATTE  E2DK904939  INITIAL DEVELOPMENT                 *
* 03-MAY-2016 SBEHERA  E2DK917651  Defect#1461 : 1.Radio button Display*
*                                  Added with display functionality    *
*                                  2.Customer name column is added in  *
*                                    the report output                 *
*                                  3.Download option with download     *
*                                    functionality added in application*
*                                    toolbar in report output          *
*                                  4.Screen display of the output      *
*                                    changed to full screen            *
*                                  5.Remove error message at the time  *
*                                    of any change in the report output*
*                                  6.Duplicate entries removed in the  *
*                                    report output while opening and   *
*                                    closing configuration             *
*&---------------------------------------------------------------------*
*18-SEP-2017 amangal E1DK930689  D3R2 Changes
*                                1. Allow mass update of date fields in*
*                                   Maintenance transaction            *
*                                2. Allow Load from AL11 with effective*
*                                   dates populated and properly       *
*                                   formatted                          *
*                                3.	Control the sending of IDoc on     *
*                                   request                            *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZOTCE0213O_MAINT_TAB_TERR_SEL
*&---------------------------------------------------------------------*

PARAMETERS: rb_add RADIOBUTTON GROUP rb1 USER-COMMAND cmd DEFAULT 'X',
            rb_chg RADIOBUTTON GROUP rb1,
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
            rb_dis RADIOBUTTON GROUP rb1 .
SELECT-OPTIONS: s_vkorg1 FOR gv_vkorg    MODIF ID gr2, " Sales Organization
                s_vtweg1 FOR gv_vtweg    MODIF ID gr2, " Distribution Channel
                s_spart1 FOR gv_spart    MODIF ID gr2, " Division
                s_kunnr1 FOR gv_kunnr    MODIF ID gr2 MATCHCODE OBJECT zotc_sh_custno,
                                                       " Customer Number
                s_terrid FOR gv_terrid1  MODIF ID gr2, " Partner Territory ID
                s_partrl FOR gv_partrole MODIF ID gr2. " Partner Role
PARAMETERS : p_date TYPE zeffect_date MODIF ID gr2 DEFAULT sy-datum. " Effective From
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA

SELECT-OPTIONS: s_vkorg FOR gv_vkorg MODIF ID gr1,
                s_vtweg FOR gv_vtweg MODIF ID gr1,
                s_spart FOR gv_spart MODIF ID gr1,
                s_kunnr FOR gv_kunnr MODIF ID gr1 MATCHCODE OBJECT zotc_sh_custno.
