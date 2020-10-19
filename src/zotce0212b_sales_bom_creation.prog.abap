************************************************************************
* PROGRAM    :  ZOTCE0212B_SALES_BOM_CREATION                          *
* TITLE      :  Auto Creation of Sales BOM                             *
* DEVELOPER  :  NEHA KUMARI                                            *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
*  WRICEF ID :  D2_OTC_EDD_0212                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Auto Creation of Material BOM and BOM Extension for    *
*               plant assignments                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 16-SEP-2014 NKUMARI  E2DK904869  INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 24-Feb-2015 NKUMARI  E2DK904869  Defect 4058: Logic is added for     *
*                                  Background Mode Execution           *
*&---------------------------------------------------------------------*
* 19-Mar-2015 NKUMARI  E2DK904869  Defect 4058_2: Generate Error for   *
*                                  blank MTNR in forground mode.       *
*&---------------------------------------------------------------------*
REPORT zotce0212b_sales_bom_creation NO STANDARD PAGE HEADING
                                     LINE-SIZE 132
                                     LINE-COUNT 70
                                     MESSAGE-ID zotc_msg.
************************************************************************
*               INCLUDE DECLARATION
************************************************************************
****----------------TOP INCLUDE-------------------*****
INCLUDE zotcn0212b_sales_bom_top. " Include ZOTCN0212B_SALES_BOM_TOP

************************************************************************
*          SELECTION SCREEN DECLARATION INCLUDE                        *
************************************************************************
INCLUDE zotcn0212b_sales_bom_sel. " Include ZOTCN0212B_SALES_BOM_SEL

************************************************************************
*          SUBROUTINE INCLUDE                                          *
************************************************************************
INCLUDE zotcn0212b_sales_bom_form. " Include ZOTCN0212B_SALES_BOM_FORM
************************************************************************

************************************************************************
*           AT-SELECTION-SCREEN OUTPUT
************************************************************************
AT SELECTION-SCREEN OUTPUT.
* Modify the screen based on User action.
  PERFORM f_modify_screen.

***********************************************************************
*         AT-SELECTION-SCREEN VALIDATION
************************************************************************
AT SELECTION-SCREEN ON s_matnr. "p_matnr.
** Validation on Material
  PERFORM f_validate_matnr  USING  s_matnr[]. "  p_matnr.

* ---> Begin of change for Defect #4058 by NKUMARI
** Date validation
AT SELECTION-SCREEN ON p_date.
  PERFORM f_validate_date CHANGING p_date.

*AT SELECTION-SCREEN ON s_werk.
AT SELECTION-SCREEN.
* <--- End of change for Defect #4058 by NKUMARI
** Validation for Plant
  IF p_extend EQ abap_true.
    PERFORM f_validate_plant  USING  s_werk[].
  ENDIF. " IF p_extend EQ abap_true

************************************************************************
*         START-OF-SELECTION
************************************************************************
START-OF-SELECTION.

* ---> Begin of change for Defect #4058_2 by NKUMARI
*** If the material is blank, generate the error message for the forground job
  IF sy-batch IS INITIAL.
    IF s_matnr IS INITIAL.
      MESSAGE i127 WITH 'Material'(003). " & is mandatory field.
      LEAVE LIST-PROCESSING.
    ENDIF. " if s_matnr is initial
  ENDIF. " if sy-batch is initial
* <--- End of change for Defect #4058_2 by NKUMARI

*** Get Characteristic information from custom table 'ZOTC_BOM_CREATE'
** And perform BOM creation and BOM extension on the data
  PERFORM f_char_info. " CHANGING i_bom_create[].

**&& Delete the header Material records with status Flag “C” with
* Date processed older than 30 days from the job execution date.
  PERFORM f_job_delete_record  CHANGING  i_bom_create[].

************************************************************************
*         END-OF-SELECTION
************************************************************************
END-OF-SELECTION.
*** Get List of e-mail address of recipnts
  PERFORM f_get_email_id CHANGING i_mail[].

*** Send Mail to all recipnts
* ---> Begin of change for Defect #4058 by NKUMARI
*          PERFORM f_send_mail  USING  i_mail[].
*                              gv_msg_create
*                              gv_msg_extend.
  PERFORM f_send_mail  USING  i_mail[].
* <--- End of change for Defect #4058 by NKUMARI
