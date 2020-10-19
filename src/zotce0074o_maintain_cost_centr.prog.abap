************************************************************************
* PROGRAM    :  ZOTCE0074O_MAINTAIN_COST_CENTR                         *
* TITLE      :  OTC_EDD_0074_Sales Rep Cost Center Assignment          *
* DEVELOPER  :  Debraj Haldar                                          *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0074                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: This program will be used to maintain the table         *
*              ZOTC_COSTCENTER                                         *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
*  30-JUN-2012 DHALDAR  E1DK903043 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*

REPORT  zotce0074o_maintain_cost_centr NO STANDARD PAGE HEADING
MESSAGE-ID zotc_msg LINe-SIZE 132.

*Top Include
INCLUDE zotcn0074o_mntn_cost_cntr_top.

*Selection Screen Include
INCLUDE zotcn0074o_mntn_cost_cntr_sel.

*Include for all subroutines
INCLUDE zotcn0074o_mntn_cost_cntr_frm.

************************************************************************
* AT SELECTION-SCREEN VALIDATION
************************************************************************
AT SELECTION-SCREEN ON s_auart.
* Validating doc type
  PERFORM f_validate_doc_typ.

AT SELECTION-SCREEN ON s_vkorg.
* Validating sales org
  PERFORM f_validate_sales_org.

AT SELECTION-SCREEN ON s_kunnr.
* Validating customer
  PERFORM f_validate_cust.
************************************************************************
* Start of Selection
************************************************************************

START-OF-SELECTION.

* Subroutine to get DDIC Information
  PERFORM f_get_ddic CHANGING i_header[]
                              i_namtab[]
                              i_rangetab[].

*Subroutine to populate the i_rangetab[]
  PERFORM f_populate_rangetab USING     i_namtab[]
                              CHANGING  i_rangetab[].

*Check which radio button is selected
  IF rb_edt IS INITIAL.

* Display selected
    gv_action = c_action_s.

  ELSE.

*Create change selected
    gv_action = c_action_u.

  ENDIF.

* Call VIEW_MAINTENANCE_CALL to update ZOTC_COSTCENTER
  PERFORM f_view_maintenance USING gv_action.
