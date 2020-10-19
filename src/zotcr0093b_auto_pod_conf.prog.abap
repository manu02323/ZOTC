************************************************************************
* PROGRAM    :  ZOTCR0093B_AUTO_POD_CONF                               *
* TITLE      :  OTC_EDD_0093_AUTOMATE POD CONFIRMATION                 *
* DEVELOPER  :  Sneha Mukherjee                                        *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0093_AUTOMATE POD CONFIRMATION                   *
*----------------------------------------------------------------------*
* DESCRIPTION: A program which will run in the background through batch*
*              job to identify POD relevant deliveries with zero qualit*
*             -y and run VLPOD transaction for those deliveries.       *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 02-Dec-13  SMUKHER   E1DK912327  INITIAL DEVELOPMENT                 *
* 24-Feb-13  SMUKHER   E1DK912327  CR#1229: Included logic to fetch all*
*                                  Delivery documents in the report,   *
*                                  New output parameters included as   *
*                                  well and updated functionality to   *
*                                  update all deliveries as a radio    *
*                                  button                              *
* 07-Mar-14  SMUKHER  E1DK912327   HPQC Defect 1229 - addition of the  *
*                                  Shipping Point description' to      *
*                                  the output ALV report               *
*&---------------------------------------------------------------------*

REPORT  zotcr0093b_auto_pod_conf MESSAGE-ID zotc_msg
                                            LINE-COUNT 80
                                            LINE-SIZE 132
                                            NO STANDARD PAGE HEADING.

************************************************************************
*          DATA DECLARATION INCLUDE                                    *
************************************************************************
* Top Include
INCLUDE zotcn0093b_auto_pod_conf_top.

************************************************************************
*          SELECTION SCREEN DECLARATION INCLUDE                        *
************************************************************************
* Selection Screen Include
INCLUDE zotcn0093b_auto_pod_conf_sel.

************************************************************************
*          SUBROUTINE INCLUDE                                          *
************************************************************************
* Include for all subroutines
INCLUDE zotcn0093b_auto_pod_conf_f01.


************************************************************************
*---- AT-SELECTION-SCREEN VALIDATION ----------------------------------*
************************************************************************
* Validating Incoterms
AT SELECTION-SCREEN ON s_inco1.
  IF s_inco1 IS NOT INITIAL.
*     Validating the Incoterms
    PERFORM f_validate_s_inco1.
  ENDIF.

* Validating Shipping Conditions
AT SELECTION-SCREEN ON s_vsbed.
  IF s_vsbed IS NOT INITIAL.
* Validating the Shipping Conditions
    PERFORM f_validate_s_vsbed.
  ENDIF.



************************************************************************
*        S T A R T - O F - S E L E C T I O N                           *
************************************************************************
START-OF-SELECTION.

**&& -- BOC for CR#1229

*  Checking if Incoterms, Shipping Conditions and Creation Date Range
*  are not initial, if all deliveries radiobutton is selected.
  PERFORM f_check_initial.

**&& -- EOC for CR#1229

*  Retrieve data from likp
  PERFORM f_retrieve_from_likp
                      CHANGING i_likp.
*  Retrieve data from lips
  PERFORM f_retrieve_from_lips
                      USING    i_likp
                      CHANGING i_lips.
* Retrieve data from vbuk
  PERFORM f_retrieve_from_vbuk
                      USING    i_likp
                      CHANGING i_vbuk.

*  Retrieve data from vbup
  PERFORM f_retrieve_from_vbup
                      USING    i_vbuk
                      CHANGING i_vbup.
**&& -- BOC for CR#1229
  PERFORM f_retrieve_from_tinc
                      USING i_likp
                      CHANGING i_tinct.
  PERFORM f_retrieve_from_tvsb
                      USING i_likp
                      CHANGING i_tvsbt.

**&& -- EOC for CR#1229
**&& -- BOC : HPQC Defect 1229 : SMUKHER : 07-MAR-14
  PERFORM f_retrieve_from_tvstt
                       USING i_likp
                       CHANGING i_tvstt.
**&& -- EOC : HPQC Defect 1229 : SMUKHER : 07-MAR-14
*----------------------------------------------------------------------*
*        E N D - O F - S E L E C T I O N                               *
*----------------------------------------------------------------------*
END-OF-SELECTION.
*  Prepare final table.
  PERFORM f_final_table_population
                        USING i_likp
                              i_lips
                              i_vbup
                              i_tinct
                              i_tvsbt
**&& -- BOC : HPQC Defect 1229 : SMUKHER : 07-MAR-14
                              i_tvstt
**&& -- EOC : HPQC Defect 1229 : SMUKHER : 07-MAR-14
                     CHANGING i_final.
*  Report display
  IF i_final[] IS NOT INITIAL.
    SORT i_final BY vbeln.   "Delivery Number

    IF sy-batch = abap_true.
* Batch Processing
      PERFORM f_execute_background USING i_final[].

    ELSE.
* prepare fieldcatlog
      PERFORM f_prepare_fieldcat
                            CHANGING i_fieldcat[].

* display ALV report
      PERFORM f_output_display USING i_fieldcat[]
                                     i_final[].
    ENDIF.
  ELSE.
    "infomation mesaage.
    MESSAGE i115.
    LEAVE LIST-PROCESSING.
  ENDIF.
