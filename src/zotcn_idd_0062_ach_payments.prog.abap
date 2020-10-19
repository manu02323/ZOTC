*&-----------------------------------------------------------------------*
*&  Include           ZOTCN_IDD_0062_ACH_PAYMENTS
***********************************************************************
*Program    : ZOTCN_IDD_0062_ACH_PAYMENTS                             *
*Title      : Include ZOTCN_IDD_0062_ACH_PAYMENTS                     *
*Developer  : Amlan J Mohapatra                                       *
*Object type: Report                                                  *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0062                                           *
*---------------------------------------------------------------------*
*Description: ACH Payments EDI 820                                    *
*                                                                     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*16-MAY-2016   AMOHAPA      E2DK917830     Defect#1474(Posting date for *
*                                          ACH Idoc will be derived from*
*                                          E1EDK03(17)segment which     *
*                                          should match with EBS posting*
*                                          date                         *
*---------------------------------------------------------------------*


** & -- Data Declaration

DATA: lwa_e1edk03    TYPE e1edk03. " IDoc: Document header date segment

** & -- Field Symbol Declaration
FIELD-SYMBOLS: <lfs_edidd> TYPE edidd. " Data record (IDoc)

** & -- Constants Declaration
CONSTANTS : lc_qualf_017   TYPE edi_qualfr VALUE '017',     " IDOC qualifier reference document
            lc_seg_e1edk03 TYPE edilsegtyp VALUE 'E1EDK03'. " Name of SAP segment

READ TABLE idoc_data ASSIGNING <lfs_edidd>
                     WITH KEY segnam   = lc_seg_e1edk03
                              sdata(3) = lc_qualf_017.
IF sy-subrc = 0.
  lwa_e1edk03    = <lfs_edidd>-sdata.
  avik_out-bvdat = lwa_e1edk03-datum.
ENDIF. " IF sy-subrc = 0
