************************************************************************
* PROGRAM    :  ZOTCN0042_PROC_BILLBACKS_SCR(Include)                  *
* TITLE      :  Process Billback data                                  *
* DEVELOPER  :  Santosh Vinapamula                                     *
* OBJECT TYPE:  Executable program                                     *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0042                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Process Billback data from EDI 867                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 15-JUN-2012  SVINAPA  E1DK901251 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* Selection parameters for Billback claims from Billback staging table

*-- Sales Document selections
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.
SELECT-OPTIONS:
  s_vkorg     FOR gv_vkorg OBLIGATORY DEFAULT c_sales_org,
  s_vtweg     FOR gv_vtweg OBLIGATORY DEFAULT c_distr_channel,
  s_vbeln     FOR gv_vbeln,
  s_posnr     FOR gv_posnr,
  s_auart     FOR gv_auart,
  s_erdat     FOR gv_erdat OBLIGATORY,     " make it mandatory??
  s_ernam     FOR gv_ernam.
SELECTION-SCREEN END OF BLOCK b1.

*-- Sold-to & Ship-to selections
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-t02.
SELECT-OPTIONS:
  s_bstkag    FOR gv_bstkd,
  s_bstdag    FOR gv_bstdk,
  s_bstkwe    FOR gv_bstkd,
  s_bstdwe    FOR gv_bstdk,
  s_kunag     FOR gv_kunnr,
  s_kunwe     FOR gv_kunnr,
  s_fkdat     FOR gv_fkdat.
SELECTION-SCREEN END OF BLOCK b2.

*-- Additional selection criteria
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-t03.
SELECT-OPTIONS:
  s_distr     FOR gv_distr,     " ?? required
  s_matnr     FOR gv_matnr,
  s_clmtch    FOR gv_clm_mtch,
  s_dupclm    FOR gv_dup_clm,
  s_flproc    FOR gv_ful_proc.
SELECTION-SCREEN END OF BLOCK b3.
