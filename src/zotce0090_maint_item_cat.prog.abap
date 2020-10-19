***********************************************************************
***********************************************************************
***********************************************************************
*REport     : ZOTCE0090_MAINT_ITEM_CAT                                *
*Title      : Item Category maintainance program                      *
*Developer  : Manish/Jahan Mazumder                                   *
*Object type: Report                                                  *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0090 / CR D2_36                                *
*---------------------------------------------------------------------*
*Description: Item Category maintainance program using BRF+           *
*This report calls directly the BRFplus Workbench and open            *
*the Decision Table for Agent Determination                           *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:                                                *
*=====================================================================*
*Date           User        Transport       Description               *
*=========== ============== ============== ===========================*
*21-May-2014  MANISH/JAHAN  E2DK900476      INITIAL DEVELOPMENT       *
*---------------------------------------------------------------------*
REPORT zotce0090_maint_item_cat.

*BRFplus ID for Decision Table (in Customizing Application MDG_BS_ECC_SUPPLIER_WF_CUSTM)
CONSTANTS: lc_get_agent_decision_table_id TYPE if_fdt_types=>id VALUE '005056B342CF1ED48490DCC5F35E1B67'.

DATA: lo_ui_execution    TYPE REF TO if_fdt_wd_ui_execution, " FDT WD: Execution of FDT UI in a browser
      lv_unknown         TYPE abap_bool,
      ro_admin_data      TYPE REF TO  if_fdt_admin_data.     " FDT: Administrative Data


*START-OF-SELECTION.

END-OF-SELECTION.
  lo_ui_execution = cl_fdt_wd_factory=>if_fdt_wd_factory~get_instance( )->get_ui_execution( ).

  cl_fdt_factory=>get_instance_generic(
     EXPORTING iv_id         = lc_get_agent_decision_table_id
     IMPORTING eo_instance   = ro_admin_data
               ev_id_unknown = lv_unknown ).

  IF lv_unknown EQ abap_true OR ro_admin_data IS NOT BOUND.
    MESSAGE e000(mdgs_workflow) WITH lc_get_agent_decision_table_id. " Decision Table "GET_AGENT" (ID: &1) does not exist in this client
    EXIT.
  ELSE. " ELSE -> IF lv_unknown EQ abap_true OR ro_admin_data IS NOT BOUND
    lo_ui_execution->execute_workbench( iv_id = lc_get_agent_decision_table_id ).
  ENDIF. " IF lv_unknown EQ abap_true OR ro_admin_data IS NOT BOUND
