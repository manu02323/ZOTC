*&---------------------------------------------------------------------*
*&  Include           ZOTCN0011O_CHK_LISTPRICE_BLOCK
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* INCLUDE    :  ZOTCN0011O_CHK_LISTPRICE_BLOCK                                              *
* TITLE      :  D3_OTC_EDD_0011_EHQ_Pricing routine enhancement        *
* DEVELOPER  :  Srinivasa G                                            *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0011                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  If there is any Item level Billing Blocks for List Price
*               then populate the header level Billing Block for List Pr
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT   DESCRIPTION                        *
* =========== ========  ==========  ===================================*
* 05-DEC-2018 U033814  E1DK939703  Initial Defect# 7800(Old Defect# 3406)*
*                                  INC0409200-02: The billing block as *
*                                  per Defect#3406 should be applied   *
*                                  only if the ZLMX and ZLMZ condition *
*                                  type is active.                     *
*----------------------------------------------------------------------*


CONSTANTS : lc_faksp TYPE faksp VALUE 'LP'. " Block

FIELD-SYMBOLS : <lfs_xvabp> TYPE vbapvb. " Document Structure for XVBAP/YVBAP
*BREAK U033814.
LOOP AT xvbap ASSIGNING <lfs_vbap>.
  IF <lfs_vbap>-uepos IS NOT INITIAL AND <lfs_vbap>-faksp EQ lc_faksp.
    <lfs_vbap>-faksp = space.
  ENDIF. " IF <lfs_vbap>-uepos IS NOT INITIAL AND <lfs_vbap>-faksp EQ lc_faksp

  IF <lfs_vbap>-abgru IS NOT INITIAL AND <lfs_vbap>-faksp EQ lc_faksp.
    <lfs_vbap>-faksp = space.
  ENDIF. " IF <lfs_vbap>-abgru IS NOT INITIAL AND <lfs_vbap>-faksp EQ lc_faksp


  IF <lfs_vbap>-faksp EQ lc_faksp AND vbak-faksk IS INITIAL.
    vbak-faksk = lc_faksp.
  ENDIF. " IF <lfs_vbap>-faksp EQ lc_faksp AND vbak-faksk IS INITIAL
ENDLOOP. " LOOP AT xvbap ASSIGNING <lfs_vbap>
