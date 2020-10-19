*&---------------------------------------------------------------------*
*&  Include           ZOTCN0093_LIST_PRICE_TOP
*&---------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*& PROGRAM   :  ZOTCO0093O_LIST_PRICE_TOP                             *
* TITLE      :  Data declaration                                      *
* DEVELOPER  :  Moushumi Bhattacharya                                 *
* OBJECT TYPE:  INTERFACE                                             *
* SAP RELEASE:  SAP ECC 6.0                                           *
*---------------------------------------------------------------------*
* WRICEF ID  :  D2_OTC_IDD_0093                                       *
*---------------------------------------------------------------------*
* DESCRIPTION:  Data declaration .                                    *
*---------------------------------------------------------------------*
* MODIFICATION HISTORY:                                               *
*=====================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                         *
* =========== ======== ===============================================*
* 21-May-2014 MBHATTA1 E2DK900420 INITIAL DEVELOPMENT                 *
* 17-11-2015  RDAS     E2DK915852 Defect#1285                         *
*Changes done to not generate Idoc with condition type not maintained
*in EMI.
* 28-Oct-2016 JAHANM  E1DK918891 Defect#5444 Performance Improvement  *
*---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*     TABLES
*----------------------------------------------------------------------*
 TABLES : mara. " General Material Data
 DATA : gv_ersda TYPE ersda, " Date  " 21-MAY-2014 by MBHATTA1
        gv_count TYPE i, " Count of type Integers
        gv_matnr TYPE matnr. " Material Number

*->> Start of Defect#5444 by Jahan.
 TYPES: BEGIN OF ty_jobs,
           jobname TYPE tbtcjob-jobname, " Background job name
           count   TYPE i,
        END OF ty_jobs,
        ty_t_jobs  TYPE STANDARD TABLE OF ty_jobs.

 DATA  : i_knumh_dyn    TYPE STANDARD TABLE OF vkkacondit, " Gen. Condition Transfer: Condition Key
         i_jobs         TYPE ty_t_jobs,
         gv_subm_count  TYPE i,                            " Subm_count of type Integers
         gv_vkorg       TYPE vkorg,                        " Sales Organization
         gv_vtweg       TYPE vtweg.                        " Distribution Channel
 " Subm_count of type Integers
*->> Start of Defect#5444 by Jahan.

* Begin of change for D2_OTC_IDD_0093 by MBHATTA1
 CONSTANTS : c_app      TYPE kappl      VALUE 'V',           " Application
             c_cond_use TYPE kvewe      VALUE 'A',           " Usage of the condition table
             c_msg_typ  TYPE edi_mestyp VALUE 'ZOTC_COND_A', " Message Type
* End of change for D2_OTC_IDD_0093 by MBHATTA1
*-->  Begin of change for D2_OTC_IDD_0093/Defect 1285 by RDAS
*&--Enhancement Name for object 'D2_OTC_IDD_0093'- Condition Type(s)
             c_enh_idd_0093      TYPE z_enhancement VALUE 'D2_OTC_IDD_0093'. " Enhancement No.
*<-- End of change for D2_OTC_IDD_0093/Defect 1285 by RDAS
