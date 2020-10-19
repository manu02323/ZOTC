FUNCTION zwf_otc_dispute_agent.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      ACTOR_TAB STRUCTURE  SWHACTOR
*"      AC_CONTAINER STRUCTURE  SWCONT
*"----------------------------------------------------------------------


************************************************************************
* PROGRAM    :ZWF_OTC_DISPUTE_AGENT                                    *
* TITLE      :D2_OTC_WDD_0013                                          *
* DEVELOPER  :  Vinita Choudhary                                       *
* OBJECT TYPE: Business object                                         *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID: D2_OTC_WDD_0013                                           *
*----------------------------------------------------------------------*
* DESCRIPTION:
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER     TRANSPORT  DESCRIPTION                         *
* ===========  ======== ========== ====================================*
* 01.12.2014   VCHOUDH   E2DK907287  Workflow for credit & Debit memo.
*&---------------------------------------------------------------------*



  INCLUDE <cntn01>. " Include for Container Macros

  DATA : lit_approvers TYPE TABLE OF agr_users. " Assignment of roles to users
  FIELD-SYMBOLS : <lfs_approvers> TYPE agr_users. " Assignment of roles to users

  swc_get_table ac_container 'WC_APPROVERS' lit_approvers.

  REFRESH actor_tab.
  CLEAR actor_tab.

  LOOP AT lit_approvers ASSIGNING <lfs_approvers>.
    actor_tab-otype = 'US'.
    actor_tab-objid = <lfs_approvers>-uname.
    APPEND actor_tab.

  ENDLOOP. " loop at lit_approvers ASSIGNING <lfs_approvers>


ENDFUNCTION.
