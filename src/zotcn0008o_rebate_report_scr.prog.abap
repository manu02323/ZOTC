*&---------------------------------------------------------------------*
*&  Include           ZOTCN0008O_REBATE_REPORT_SCR
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCR0008O_REBATE_REPORT_SCR                           *
* TITLE      :  REBATE REPORT (PRICING)                                *
* DEVELOPER  :  ROHIT VERMA                                            *
* OBJECT TYPE:  INCLUDE                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0008_REBATE_REPORT                               *
*----------------------------------------------------------------------*
* DESCRIPTION: This Include is for Screen declaration of Report        *
*               ZOTCR0008O_REBATE_REPORT_TOP (Rebate Report).          *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 09-MAR-2012 RVERMA   E1DK901226 INITIAL DEVELOPMENT                  *
*&---------------------CR#6--------------------------------------------*
* 17-APR-2012 RVERMA   E1DK901226 Addition of fields Payer Desc,       *
*                                 Ship-to-Party Desc, Material Desc,   *
*                                 Rebate Basis, Currency Key in ALV    *
*                                 output. Changes in the fetching      *
*                                 logic of Ship-to-Party Value         *
* 21-MAY-2012 RVERMA   E1DK901226 Fetching field for condition currency*
*                                 changed from WAERS to KWAEH          *
*&---------------------CR#34-------------------------------------------*
* 12-JUN-2012 RVERMA   E1DK901226 Adding fields KVGR1(GPO Code) & KVGR2*
*                                 (IDN Code) and their description     *
*                                 fields in the report and removing    *
*                                 leading zeroes from customer material*
*                                 field and dividing dividing          *
*                                 KONV-KBETR by 10.                    *
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*     S E L E C T I O N - S C R E E N
*----------------------------------------------------------------------*
  SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
  PARAMETERS: p_gjahr TYPE gjahr OBLIGATORY        "Fiscal Year
                                 MATCHCODE OBJECT rscalyear.

  SELECT-OPTIONS: s_bukrs FOR gv_bukrs OBLIGATORY, "Company Code
                  s_vkorg FOR gv_vkorg,"Sales Organization
                  s_fkart FOR gv_fkart       "Billing Doc Type
                          MATCHCODE OBJECT H_TVFK,
                  s_vbeln FOR gv_vbeln       "Billing Doc Number
                          MATCHCODE OBJECT F4_VBRK,
                  s_fkdat FOR gv_fkdat,      "Billing Date
                  s_kunrg FOR gv_kunrg       "Payer
                          MATCHCODE OBJECT DEBI,
                  s_kschl FOR gv_kschl OBLIGATORY "Condition Type
                          MATCHCODE OBJECT h_t685.
  SELECTION-SCREEN END OF BLOCK bl1.
