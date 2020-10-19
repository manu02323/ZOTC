REPORT  zotcr0026o_corrsp_collect_rpt MESSAGE-ID zotc_msg
                                      NO STANDARD PAGE HEADING.
************************************************************************
* PROGRAM    :  ZOTCR0026O_CORRSP_COLLECT_RPT                          *
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
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 22-JUL-2013 GNAG     E1DK911035 INITIAL DEVELOPMENT                  *
* 06-AUG-2013 BMAJI    E1DK911035 DEFECT#53 : Add F4 for Language &
*                                 Text Object
*&---------------------------------------------------------------------*

INCLUDE zotcn0026o_corrsp_collect_top.

INCLUDE zotcn0026o_corrsp_collect_sel.

INCLUDE zotcn0026o_corrsp_collect_f01.

*&&-- BOC of DEF#53
************************************************************************
*   AT-SELECTION-SCREEN VALUE REQUEST
************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_tdid.
  PERFORM f_get_f4_textid CHANGING i_textid.
  PERFORM f_help_textid USING i_textid[]
                       CHANGING p_tdid.
*&&-- EOC of DEF#53

************************************************************************
*        At selection-screen Event
************************************************************************
* Validation of Customer Number
AT SELECTION-SCREEN ON s_kunnr.
  PERFORM f_validate_customer.

* Validation of Customer Account Group
AT SELECTION-SCREEN ON p_ktokd.
  IF NOT p_ktokd IS INITIAL.
    PERFORM f_validate_ktokd.
  ENDIF.

* Validation of Sales Org
AT SELECTION-SCREEN ON p_vkorg.
  PERFORM f_validate_vkorg.

* Validation of Distribution Channel
AT SELECTION-SCREEN ON p_vtweg.
  PERFORM f_validate_vtweg.

* Validation of Division
AT SELECTION-SCREEN ON p_spart.
  PERFORM f_validate_spart.

* Validation of Text ID
AT SELECTION-SCREEN ON p_tdid.
  PERFORM f_validate_tdid.

* Validation of Text Object
AT SELECTION-SCREEN ON p_tdobj.
  PERFORM f_validate_tdobj.


************************************************************************
*        Start-of-selection Event
************************************************************************
START-OF-SELECTION.

* Get the customer master after applying the filters
  PERFORM f_get_data_cust CHANGING i_cust_name.

* Get the customer texts
  PERFORM f_get_cust_text USING i_cust_name
                          CHANGING i_cust_text
                                   i_final.

************************************************************************
*        End-of-selection Event
************************************************************************
END-OF-SELECTION.

* Prepare the ALV parameters
  PERFORM f_prepare_alv_param CHANGING i_fieldcat
                                       x_layout.

* Display the final output
  PERFORM f_output_display USING i_final
                                 x_layout
                                 i_fieldcat.
