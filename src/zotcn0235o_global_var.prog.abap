*&---------------------------------------------------------------------*
*&  Include           ZOTCN0235O_GLOBAL_VAR
*&---------------------------------------------------------------------*
***********************************************************************
*Program    : ZOTCN0235O_GLOBAL_VAR                                   *
*Title      : Ship Complete                                           *
*Developer  : Dhananjoy Moirangthem                                   *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_EDD_0235                                           *
*---------------------------------------------------------------------*
*Description: Global data declaration for ship complete               *
*                                                                     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*18-Feb-2015  DMOIRAN       E2DK900492       Initial declaration
*---------------------------------------------------------------------*

TYPES: BEGIN OF ty_tragr_pref,
        vkorg         TYPE vkorg,       " Sales Organization
        vtweg         TYPE vtweg,       " Distribution Channel
        zpriorcount   TYPE zpriorcount, " Priority Counter
        zztragr       TYPE z_tragr,     " Transportation Group
      END OF ty_tragr_pref,
      ty_t_tragr_pref TYPE STANDARD TABLE OF ty_tragr_pref.


DATA: i_tragr_pref TYPE ty_t_tragr_pref. " Transportation Group preference table
