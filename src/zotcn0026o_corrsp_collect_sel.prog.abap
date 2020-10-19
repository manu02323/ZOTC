*&---------------------------------------------------------------------*
*&  Include           ZOTCN0026O_CORRSP_COLLECT_SEL
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0026O_CORRSP_COLLECT_SEL                          *
* TITLE      :  ZOTCR0026O - Customer Master & Corresp Collect Account *
*               Report                                                 *
* DEVELOPER  :  Gautam NAG                                             *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0026                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: This report shows tte list of customer master data with
*              the collect number details. The collect numbers are
*              stored in the Sales Text and the same is read and
*              displayed against the customer master
*              This include program defines the selection screen for
*              this report
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 22-JUL-2013 GNAG     E1DK911035 INITIAL DEVELOPMENT
* 06-AUG-2013 BMAJI    E1DK911035 DEFECT#53 : Add F4 for Language &
*                                 Text Object
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK ss WITH FRAME TITLE text-ssr.

SELECT-OPTIONS: s_kunnr FOR gv_kunnr OBLIGATORY.  " Customer Number

SELECTION-SCREEN SKIP.

PARAMETERS: p_ktokd TYPE kna1-ktokd,          " Customer Account Group
            p_vkorg TYPE vkorg OBLIGATORY,    " Sales Organization
            p_vtweg TYPE vtweg OBLIGATORY,    " Distribution Channel
            p_spart TYPE spart OBLIGATORY,    " Division
            p_tdid  TYPE tdid OBLIGATORY,     " Text ID
            p_langu TYPE spras OBLIGATORY
                      MATCHCODE OBJECT h_t002," Language  "DEF#53 ++
            p_tdobj TYPE tdobject OBLIGATORY DEFAULT 'KNVV'.
" Texts: Application Object
SELECTION-SCREEN END OF BLOCK ss.
