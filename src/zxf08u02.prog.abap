*&-----------------------------------------------------------------------*
*&  Include           ZXF08U02
*MODIFICATION HISTORY:
*========================================================================*
*Date           User        Transport                     Description
*=========== ============== ============== ==============================*
*12-MAY-2016   AMOHAPA      E2DK917830     Defect#1474(Posting date for  *
*                                          ACH Idoc will be derived from *
*                                          E1EDK03(17)segment which      *
*                                          should match with EBS posting *
*                                          date                          *
*&-----------------------------------------------------------------------*
*"-----------------------------------------------------------------------*
*"*"Globale Schnittstelle:
*"       IMPORTING
*"             VALUE(IDOC_CONTROL_INDEX)
*"             VALUE(IDOC_DATA_INDEX)
*"             VALUE(AVIK_IN) LIKE  AVIK STRUCTURE  AVIK
*"             VALUE(AVIP_IN) LIKE  AVIP STRUCTURE  AVIP
*"             VALUE(AVIR_IN) LIKE  AVIR STRUCTURE  AVIR
*"       EXPORTING
*"             VALUE(I_FIMSG) LIKE  FIMSG STRUCTURE  FIMSG
*"             VALUE(AVIK_OUT) LIKE  AVIK STRUCTURE  AVIK
*"             VALUE(AVIP_OUT) LIKE  AVIP STRUCTURE  AVIP
*"             VALUE(AVIR_OUT) LIKE  AVIR STRUCTURE  AVIR
*"       TABLES
*"              IDOC_CONTROL STRUCTURE  EDIDC
*"              IDOC_DATA STRUCTURE  EDIDD
*"       EXCEPTIONS
*"              PROC_ERROR
*"----------------------------------------------------------------------
avik_out = avik_in.
avip_out = avip_in.
avir_out = avir_in.

*Begin of Change D2_OTC_IDD_0062 by AMOHAPA for Defect#1474 on 12-May-2016
INCLUDE zotcn_idd_0062_ach_payments. " Include ZOTCN_IDD_0062_ACH_PAYMENTS
*End of Change D2_OTC_IDD_0062 by AMOHAPA for Defect#1474 on 12-May-2016
