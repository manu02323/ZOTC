FUNCTION-POOL zotc_excel_to_it. "MESSAGE-ID ..
************************************************************************
* PROGRAM    :  ZOTC_ALSM_EXCEL_TO_INT_TABLE(Function module)          *
* TITLE      :  D2_OTC_EDD_0274_Pricing upload program for pricing cond*
* DEVELOPER  :  Dhananjoy Moirangthem                                  *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_EDD_0274                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: FM to upload the data from excel file.                  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER     TRANSPORT  DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 26-Oct-2015  DMOIRAN   E2DK913959 INITIAL DEVELOPMENT                *
* Defect 1209 PGL B development. This FM is copy of SAP stadard FM     *
*ALSM_EXCEL_TO_INTERNAL_TABLE. The latter supports only VALUE of 50    *
*characters (field VALUE in INTERN) only. As for pricing upload        *
*condition text will have 72 characters, standard FM is copied and     *
*modified.                                                             *
*&---------------------------------------------------------------------*

* INCLUDE LZOTC_EXCEL_TO_ITD...              " Local class definition
TYPE-POOLS: ole2.

*      value of excel-cell
TYPES: ty_d_itabvalue             TYPE zotc_s_alsmex_tabline-value, " Comment
*      internal table containing the excel data
       ty_t_itab                  TYPE zotc_s_alsmex_tabline   OCCURS 0, " Rows for Table with Excel Data

*      line type of sender table
       BEGIN OF ty_s_senderline,
         line(4096)               TYPE c, " Line(4096) of type Character
       END OF ty_s_senderline,
*      sender table
       ty_t_sender                TYPE ty_s_senderline  OCCURS 0.

*
CONSTANTS:  gc_esc              VALUE '"'.
