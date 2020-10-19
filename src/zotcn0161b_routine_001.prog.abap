************************************************************************
* PROGRAM    :  ZOTCN0161B_ROUTINE_001                                 *
* TITLE      :  Copy Control routines sales order to billing           *
* DEVELOPER  :  Sankritya Saurav                                       *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D2_OTC_EDD_0161                                          *
*----------------------------------------------------------------------*
* DESCRIPTION:                                                         *
* Custom fields have been identified in the sales document header and  *
* line item and these are required to be copied over to the billing    *
* document that is created for the sales order. These custom fields    *
* have been defined under D2_OTC_EDD_0136_Custom fields in sales       *
* document header and line.                                            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 16-JUN-2014 PMISHRA  E2DK900949 Initial Version                      *
* 15-Mar-2016 PDEBARU  E2DK917220 Defect # 1582 : Creation of new field*
*                                 in VBAP & VBRP table                 *
*&---------------------------------------------------------------------*

* Update Header Custom Fields
IF vbak-zzdocref IS NOT INITIAL.
  vbrk-zzdocref = vbak-zzdocref.
ENDIF. " IF vbak-zzdocref IS NOT INITIAL

IF vbak-zzdoctyp IS NOT INITIAL.
  vbrk-zzdoctyp = vbak-zzdoctyp.
ENDIF. " IF vbak-zzdoctyp IS NOT INITIAL

IF vbak-zzcaseref IS NOT INITIAL.
  vbrk-zzcaseref = vbak-zzcaseref.
ENDIF. " IF vbak-zzcaseref IS NOT INITIAL

* Update Item Custom Fields
IF vbap-zzagmnt IS NOT INITIAL.
  vbrp-zzagmnt = vbap-zzagmnt.
ENDIF. " IF vbap-zzagmnt IS NOT INITIAL

IF  vbap-zzagmnt_typ IS NOT INITIAL.
  vbrp-zzagmnt_typ = vbap-zzagmnt_typ.
ENDIF. " IF vbap-zzagmnt_typ IS NOT INITIAL

IF vbap-zzitemref IS NOT INITIAL.
  vbrp-zzitemref = vbap-zzitemref.
ENDIF. " IF vbap-zzitemref IS NOT INITIAL

IF vbap-zzquoteref IS NOT INITIAL.
  vbrp-zzquoteref = vbap-zzquoteref.
ENDIF. " IF vbap-zzquoteref IS NOT INITIAL

* ---> Begin of Insert for D2_OTC_EDD_0136 Defect# 1582 by PDEBARU
IF vbap-zzmat IS NOT INITIAL.
  vbrp-zzmat = vbap-zzmat.
ENDIF. " IF vbap-zzmat IS NOT INITIAL

* <--- End of Insert for D2_OTC_EDD_0136 Defect# 1582 by PDEBARU
