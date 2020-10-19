************************************************************************
* Program    : ZOTCI00219N_INTEREST_CHARGES                            *
* Title      : Interest Charges to Faber                               *
* Developer  : Manoj Thatha                                            *
* Object type: Interface                                               *
* SAP Release: SAP ECC 6.0                                             *
*----------------------------------------------------------------------*
* WRICEF ID  : D3_OTC_IDD_0219                                         *
*----------------------------------------------------------------------*
* Description: This interface send intrest charges to Faber system     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* Date           User        Transport       Description               *
*=========== ============== ============== ============================*
* 20-FEB-2018    mthatha     E2DK907549     Initial Development        *
*&---------------------------------------------------------------------*
*& Report  ZOTCI00219N_INTEREST_CHARGES
*&
*&---------------------------------------------------------------------*
REPORT zotci00219o_interest_charges.
*&--Include for Global Data Declarations
INCLUDE zotci00219n_intrstcharge_top. " " Top Inlcude for interet charges
*&--Include for Local Class Definition and Implementation
INCLUDE zotci00219n_intrstcharge_class. " Class Include
*&--Include for Selection Screen
INCLUDE zotci00219n_intrstcharge_sel. " Selection screen for intrest charges
*----------------------------------------------------------------------*
*                    I N I T I A L I Z A T I O N                       *
*----------------------------------------------------------------------*
INITIALIZATION.
*&--Create Object for Selection Screen Class
  CREATE OBJECT gref_selscr.
*&--Create Object for Processing
  CREATE OBJECT gref_process.
*----------------------------------------------------------------------*
*               A T   S E L E C T I O N    S C R E E N                 *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_bukrs.
*&--Validate Company Code
  TRY.
      CALL METHOD gref_selscr->meth_inst_pub_valid_bukrs
        EXPORTING
          im_bukrs = p_bukrs.
    CATCH cx_crm_genil_general_error INTO gref_exce.
      MESSAGE gref_exce TYPE cl_axt_constants=>gc_msgty_error.
  ENDTRY.
AT SELECTION-SCREEN ON p_gjahr.
*&--Validate Fiscal Year
  TRY.
      CALL METHOD gref_selscr->meth_inst_pub_valid_fs_year
        EXPORTING
          im_gjahr = p_gjahr.
    CATCH cx_crm_genil_general_error INTO gref_exce.
      MESSAGE gref_exce TYPE cl_axt_constants=>gc_msgty_error.
  ENDTRY.
*----------------------------------------------------------------------*
*                 S T A R T   O F   S E L E C T I O N                  *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  TRY.
*&--Fetch Invoice Data
      CALL METHOD gref_process->meth_inst_pub_get_inv_data
        EXPORTING
          im_belnr = s_docno[]
          im_bukrs = p_bukrs
          im_cpudt = s_cdat[]
          im_gjahr = p_gjahr.
    CATCH cx_crm_genil_general_error INTO gref_exce.
      MESSAGE gref_exce TYPE cl_axt_constants=>gc_msgty_success
                DISPLAY LIKE cl_axt_constants=>gc_msgty_error.
      LEAVE LIST-PROCESSING.
  ENDTRY.
*----------------------------------------------------------------------*
*                   E N D   O F   S E L E C T I O N                    *
*----------------------------------------------------------------------*
END-OF-SELECTION.
  TRY.
*&--Transfer Interest charges
      CALL METHOD gref_process->meth_inst_pub_send_charges
      exporting
        im_regn = p_regn.
    CATCH cx_crm_genil_general_error INTO gref_exce.
      MESSAGE gref_exce TYPE cl_axt_constants=>gc_msgty_success
                DISPLAY LIKE cl_axt_constants=>gc_msgty_error.
      LEAVE LIST-PROCESSING.
  ENDTRY.
*&--Free Class Attributes
  CALL METHOD gref_process->meth_inst_pub_free.
