*&---------------------------------------------------------------------*
*&  Include           ZOTCN0095O_GLOBAL_VAR
*&---------------------------------------------------------------------*

***********************************************************************
*Program    : ZOTCN0095O_GLOBAL_VAR                                   *
*Title      : Item Category flip  on 100 % discount                   *
*Developer  : Harshit Badlani                                         *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0095                                           *
*---------------------------------------------------------------------*
*Description:Simulate Sales Order to retrieve ATP information, prices,*
*            taxes and handling charges for subscribing applications  *
*CR D2_37   : This CR invloves Item Category flip  whenever 100 %     *
*discount is given on a line item.                                    *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*05-Aug-2014  HBADLAN      E2DK900468      CR: D2_37
*12-Sep-2014  SMUKHER      E2DK900468      Retrofit of OTC_EDD_0221   *
*                                          (CR# 1535)                 *
*10-SEP-2015  DARUMUG      E2DK905281      D# 536, 1162 and 1019      *
*                                          Performance tuning changes *
*---------------------------------------------------------------------*
*As this is Data declaration user exit so no ABAP code can be done.
*Hence no EMI check is done.

  DATA : gv_flip_flag TYPE flag. " General Flag

**&& BOC : Retrofit of CR# 1535 : SMUKHER : 27-Jan-2014
*&&-- Declare Global range table for entries of zotc_prc_control table
  DATA: i_werks_pstyv_r TYPE RANGE OF z_mvalue_low. " Select Options: Value Low
**&& EOC : Retrofit of CR# 1535 : SMUKHER : 27-Jan-2014

**//-->> Begin of changes - D# 1019 - DARUMUG - 08/27/2015
  DATA : gv_hazd_prod TYPE flag, " General Flag
         gv_bom       TYPE flag, " General Flag
         i_enh_stat   TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0. " Internal table
**//-->> End of changes - D# 1019 - DARUMUG - 08/27/2015
