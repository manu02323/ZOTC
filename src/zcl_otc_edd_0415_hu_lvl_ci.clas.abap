class ZCL_OTC_EDD_0415_HU_LVL_CI definition
  public
  final
  create public
  shared memory enabled .

public section.

  class-methods SET_HU_LVL_CI_DATA
    importing
      value(IM_HU_DET) type ZLEX_TT_HU_DETAILS_FROM_EWM .
  class-methods GET_HU_LVL_CI_DATA
    exporting
      value(EX_HU_DET) type ZLEX_TT_HU_DETAILS_FROM_EWM .
protected section.
private section.

  class-data ATTR_STAT_PRI_SINGLETON type ref to ZCL_OTC_EDD_0415_HU_LVL_CI .
  class-data ATTRI_HU_DET type ZLEX_TT_HU_DETAILS_FROM_EWM .
ENDCLASS.



CLASS ZCL_OTC_EDD_0415_HU_LVL_CI IMPLEMENTATION.


METHOD get_hu_lvl_ci_data.
***********************************************************************
*Program    : GET_HU_LVL_CI_DATA(Method)                              *
*Title      : move data from RFC FM to Enhancement                    *
*Developer  : Raghahv Sureddi (U033876)                               *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_EDD_0415                                              *
*---------------------------------------------------------------------*
*Description: GET_HU_LVL_CI_DATA                                      *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*======================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ============================*
*24-Aug-2018   U033876       E1DK938535      Initial Development
*---------------------------------------------------------------------*
  ex_hu_det[] = attri_hu_det[].
ENDMETHOD.


METHOD set_hu_lvl_ci_data.
***********************************************************************
*Program    : SET_HU_LVL_CI_DATA(Method)                              *
*Title      : move data from RFC FM to Enhancement                    *
*Developer  : Raghahv Sureddi (U033876)                               *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_EDD_0415                                              *
*---------------------------------------------------------------------*
*Description: SET_HU_LVL_CI_DATA                                           *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*======================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ============================*
*24-Aug-2018   U033876       E1DK938535      Initial Development
*---------------------------------------------------------------------*
  CLEAR: attri_hu_det[].

  attri_hu_det[] = im_hu_det[].
ENDMETHOD.
ENDCLASS.
