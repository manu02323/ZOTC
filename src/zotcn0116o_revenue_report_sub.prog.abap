*&---------------------------------------------------------------------*
*&  Include           ZOTCN0116O_REVENUE_REPORT_SUB
*&---------------------------------------------------------------------*
************************************************************************
* Include    :  ZOTCN0116O_REVENUE_REPORT_SUB                          *
* TITLE      :  End to End Revenue Report                              *
* DEVELOPER  :  RAGHAV SUREDDI                                         *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0116_REVENUE_REPORT                              *
*----------------------------------------------------------------------*
* DESCRIPTION: This Report can be utilized by users to track Revenue   *
*               Documents created on a specific date or within a date  *
*               range. The report will provide all key information     *
*               about the Revenue.                                     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 30-Nov-2017 U033876   E1DK934630 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 11-Apr-2018 MGARG/    E1DK934630 Defect#4360                         *
*             U024694              Fix performance Issue, Add Search   *
*                                  help and change the description of  *
*                                  column headings                     *
*&---------------------------------------------------------------------*
* 10-May-2018 U100018   E1DK934630 Defect# 6027: Fix performance issue *
*&---------------------------------------------------------------------*
* 12-Apr-2019 PDEBARU   E1DK941048 Defect# 9070 : 1. VF01 authorization*
*                                  for all users allowed               *
*                                  2. Display of Payer Block & Sold to *
*                                  party block even if customer is     *
*                                  marked for deletion                 *
*&---------------------------------------------------------------------*


*                  S T A R T - O F - S E L E C T I O N
START-OF-SELECTION.

*&-- Authorization check
  PERFORM f_authorization_check.

* Clear global variables
  PERFORM f_global_clear.

* Get the Delivery Data
  PERFORM f_get_deliv_data CHANGING i_likp
                                    i_lips
*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
                                    i_payr
                                    i_paybl
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
*--> Begin of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
                                    i_knvv.
*<-- End of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
* Get the status details
  PERFORM f_get_status_vbup USING i_lips
                           CHANGING i_vbup.

* Get Hu details
  PERFORM f_get_hu_details USING i_lips
                                 i_enh_status
                           CHANGING gv_vpobj
                                    i_vekp.


* Get the Sales order information
  PERFORM f_get_order_data USING i_lips
                          CHANGING i_vbak
                                   i_vbap.
* Get the text descriptions
  PERFORM f_get_desc USING  i_lips
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
                            i_likp
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
                            i_vbap
                     CHANGING i_tvkot
                              i_tvm1t
*                              i_tvm4t
                              i_tvrot
                              i_tvkmt.
* Get the condition details
  PERFORM f_get_from_konv  USING i_vbak
                          CHANGING i_konv.

* Ge the Customer information
  PERFORM f_get_cust_data USING
* ---> Begin of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
*                                  i_lips
* <--- End of Delete for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
                                   i_likp
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
                          CHANGING i_kna1.

* Get the Docflow
  PERFORM f_get_docflow USING i_lips
                        CHANGING i_vbfa.

* Get the Billing Info
  PERFORM f_get_bill_det USING i_vbfa
                        CHANGING i_vbrk
                                 i_vbrp.

* Get the Rev Recog details
  PERFORM f_get_rev_det USING i_lips
                        CHANGING i_vbreve.

* Get the Accounting Details
  PERFORM f_get_accnt_det USING i_vbreve
                          CHANGING i_bkpf.
* Begin of Change for SCTASK0745122 by U033876
* for IC related fields
  PERFORM f_get_intercomp USING i_likp
                                i_lips
                                i_vbrk
                                i_vbrp
                                i_vbfa
                                i_bkpf
                          CHANGING
                                i_ic_ar_bill
                                i_bkpf_ap.
* Begin of change for Sctask: SCTASK0745122 Intercompany Billing Accural fields by U033876
  IF p_inter = abap_true.
    PERFORM f_get_ic_bill_accural USING i_vbak
                                        i_likp
                                        i_lips
                                        i_vbup
                                  CHANGING i_ic_bill_acc.
  ENDIF. " IF p_inter = abap_true
* End of change for Sctask: SCTASK0745122 Intercompany Billing Accural fields by U033876

* End of Change for SCTASK0745122 by U033876



  PERFORM f_prepare_final USING i_lips
* ---> Begin of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
                                i_likp
* <--- End of Insert for D3_OTC_RDD_0116_Defect#4360 by MGARG/U024694 on 11-Apr-2018
                                i_vbup
                                i_vbap
                                gv_vpobj
                                i_vekp
                                i_vbak
                                i_konv
                                i_kna1
*--> Begin of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
                                i_knvv
*<-- End of insert for Defect# 9070 D3_OTC_RDD_0116 by PDEBARU
                                i_vbfa
                                i_vbrk
                                i_vbrp
                                i_vbreve
                                i_bkpf
                                i_tvkot
                                i_tvm1t
*                                i_tvm4t
                                i_tvrot
                                i_tvkmt
*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
                                i_payr
                                i_paybl
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
*---> Begin of Change for SCTASK0745122 by U033876
*                                i_a005_konp
                                i_ic_ar_bill
                                i_bkpf_ap
                                i_ic_bill_acc
*<---End of Change for SCTASK0745122 by U033876
                          CHANGING i_final.


END-OF-SELECTION.


  IF i_final[] IS NOT INITIAL.
*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
    IF p_mode EQ abap_true.
      PERFORM f_appl_server_upload USING i_final.
    ELSE. " ELSE -> IF p_mode EQ abap_true
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
* Generate Field catalog based on Internal table dynamically
      PERFORM f_fieldcat_fill USING i_final
                              CHANGING i_fieldcat.

      CALL SCREEN 9000.
*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
    ENDIF. " IF p_mode EQ abap_true
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
  ELSE. " ELSE -> IF i_final[] IS NOT INITIAL
 "infomation mesaage.
    MESSAGE i115.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF i_final[] IS NOT INITIAL

*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS 'STATUS'.
  SET TITLEBAR 'REVENUE_REPORT'.

ENDMODULE. " STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_ALV  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE display_alv OUTPUT.
  PERFORM f_display_alv USING i_fieldcat i_final.
ENDMODULE. " DISPLAY_ALV  OUTPUT
*&---------------------------------------------------------------------*
*&       Class (Implementation)  go_event_handler
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS go_event_handler IMPLEMENTATION. " Event_handler class
*&--Top of page handler method for common header data section
  METHOD meth_i_pub_handle_topofpage.
    PERFORM f_handle_topofpage USING e_dyndoc_id
                                     go_gui_cont_top.
  ENDMETHOD. "meth_i_pub_handle_topofpage
*&--On tool bar handler method for adding accounting button on alv
  METHOD meth_on_toolbar.
    PERFORM f_on_toolbar USING e_object.
  ENDMETHOD. "meth_on_toolbar
*&--Action to be performed when accounting button is pressed on alv
  METHOD meth_handle_user_comm.
    PERFORM f_handle_user_comm USING e_ucomm.
  ENDMETHOD. "meth_handle_user_comm
ENDCLASS. "go_event_handler

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
*&--Handle user command
  CASE sy-ucomm.
    WHEN c_back.
      PERFORM f_free_container.
      LEAVE TO SCREEN 0.
    WHEN c_exit.
      PERFORM f_free_container.
      LEAVE TO SCREEN 0.
    WHEN c_cancel.
      PERFORM f_free_container.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE. " USER_COMMAND_9000  INPUT
