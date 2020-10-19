FUNCTION zotc_rv_inv_create.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(DELIVERY_DATE) TYPE  FBUDA DEFAULT 0
*"     VALUE(INVOICE_DATE) TYPE  FKDAT DEFAULT 0
*"     VALUE(INVOICE_TYPE) TYPE  FKART DEFAULT '    '
*"     VALUE(PRICING_DATE) TYPE  PRSDT DEFAULT 0
*"     VALUE(VBSK_I) LIKE  VBSK STRUCTURE  VBSK
*"     VALUE(WITH_POSTING) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(SELECT_DATE) TYPE  FKDAT DEFAULT 0
*"     VALUE(I_NO_VBLOG) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(I_ANALYZE_MODE) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(ID_UTASY) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(ID_UTSWL) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(ID_UTSNL) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(ID_NO_ENQUEUE) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(ID_NEW_CANCELLATION) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_BLART) TYPE  BLART DEFAULT SPACE
*"     VALUE(ID_EXT_CANCELLATION) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_STGRD) TYPE  STGRD OPTIONAL
*"     VALUE(PRICING_TIME) TYPE  VORGABEENZ OPTIONAL
*"     VALUE(OIR_INVINFO) LIKE  OIRI_INVINFO STRUCTURE  OIRI_INVINFO
*"       OPTIONAL
*"  EXPORTING
*"     VALUE(VBSK_E) LIKE  VBSK STRUCTURE  VBSK
*"     VALUE(OD_BAD_DATA) LIKE  RVSEL-XFELD
*"     VALUE(DET_REBATE) TYPE  CHAR1
*"  TABLES
*"      XKOMFK STRUCTURE  KOMFK OPTIONAL
*"      XKOMV STRUCTURE  KOMV OPTIONAL
*"      XTHEAD STRUCTURE  THEADVB OPTIONAL
*"      XVBFS STRUCTURE  VBFS OPTIONAL
*"      XVBPA STRUCTURE  VBPAVB OPTIONAL
*"      XVBRK STRUCTURE  VBRKVB OPTIONAL
*"      XVBRP STRUCTURE  VBRPVB OPTIONAL
*"      XVBSS STRUCTURE  VBSS OPTIONAL
*"      XKOMFKGN STRUCTURE  KOMFKGN OPTIONAL
*"      XKOMFKKO STRUCTURE  KOMV OPTIONAL
*"      XOIA_KOMF STRUCTURE  OIAKOMF OPTIONAL
*"      XOIA_OICQ7 STRUCTURE  OIAF7 OPTIONAL
*"      XOIA_OICQ8 STRUCTURE  OIAF8 OPTIONAL
*"      XOIA_OICQ9 STRUCTURE  OIAF9 OPTIONAL
*"      XOICQ7 STRUCTURE  OICQ7 OPTIONAL
*"      XOICQ8 STRUCTURE  OICQ8 OPTIONAL
*"      XOICQ9 STRUCTURE  OICQ9 OPTIONAL
*"      XOIC_KOMV1 STRUCTURE  KOMV OPTIONAL
*"      XOICINT_CAL STRUCTURE  OICINT_CALCULATION OPTIONAL
*"      XOIUQ9 STRUCTURE  OIUQ9 OPTIONAL
*"----------------------------------------------------------------------
*Program    : ZOTC_RV_INV_CREATE                                      *
*Title      : End to End Revenue Report                               *
*Developer  : Debarun Paul                                            *
*Object type: Function Module                                         *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_RDD_0116                                              *
*---------------------------------------------------------------------*
*Description: End to End Revenue Report                               *
* This FM was developed from onsite by Raghav Sureddi. Pdebaru        *
* (Debarun Paul ) has made docuemntation for this                     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
* 12-Apr-2019 PDEBARU   E1DK941048 Defect# 9070 : 1. VF01 authorization*
*                                  for all users allowed               *
*                                  2. Display of Payer Block & Sold to *
*                                  party block even if customer is     *
*                                  marked for deletion                 *
*&---------------------------------------------------------------------*
  TRY.

      CALL FUNCTION 'RV_INVOICE_CREATE'
        EXPORTING
          delivery_date       = delivery_date
          invoice_date        = invoice_date
          invoice_type        = invoice_type
          pricing_date        = pricing_date
          vbsk_i              = vbsk_i
          with_posting        = with_posting
          select_date         = select_date
          i_no_vblog          = i_no_vblog
          i_analyze_mode      = i_analyze_mode
          id_utasy            = id_utasy
          id_utswl            = id_utswl
          id_utsnl            = id_utsnl
          id_no_enqueue       = id_no_enqueue
          id_new_cancellation = id_new_cancellation
          i_blart             = i_blart
          id_ext_cancellation = id_ext_cancellation
          i_stgrd             = i_stgrd
        IMPORTING
          vbsk_e              = vbsk_e
          od_bad_data         = od_bad_data
          det_rebate          = det_rebate
        TABLES
          xkomfk              = xkomfk
          xkomv               = xkomv
          xthead              = xthead
          xvbfs               = xvbfs
          xvbpa               = xvbpa
          xvbrk               = xvbrk
          xvbrp               = xvbrp
          xvbss               = xvbss
          xkomfkgn            = xkomfkgn
          xkomfkko            = xkomfkko.


*      DATA: lf_kvorg TYPE kvorg. " Event in condition processing
*
*      CALL FUNCTION 'GN_INVOICE_CREATE'
*        EXPORTING
*          vbsk_i       = vbsk_i
*          id_kvorg     = lf_kvorg
*          id_no_dialog = 'X'
*          invoice_date = sy-datum
*          pricing_date = sy-datum
*        IMPORTING
*          vbsk_e       = vbsk_e
*        TABLES
*          xkomfk       = xkomfk
*          xkomfkgn     = xkomfkgn
*          xkomfkko     = xkomfkko
*          xkomv        = xkomv
*          xthead       = xthead
*          xvbfs        = xvbfs
*          xvbpa        = xvbpa
*          xvbrk        = xvbrk
*          xvbrp        = xvbrp
*          xvbss        = xvbss
*        EXCEPTIONS
*          OTHERS       = 1.

    CATCH cx_root.
  ENDTRY.


ENDFUNCTION.
