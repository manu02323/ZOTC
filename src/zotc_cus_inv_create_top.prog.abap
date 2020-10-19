*&---------------------------------------------------------------------*
*&  Include           /SAPSLL/CUS_INV_CREATE_TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include  ZOTC_CUS_INV_CREATE_TOP
*&
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTC_CUS_INV_CREATE_TOP                                *
* TITLE      :  OTC_EDD_0414_Proforma Shipment                         *
* DEVELOPER  :  Manoj thatha                                           *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_EDD_0414                                           *
*----------------------------------------------------------------------*
* DESCRIPTION: Proforma Shipment                                       *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER     TRANSPORT  DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 16-Aug-2018  MTHATHA  E1DK937760 INITIAL DEVELOPMENT                 *
* 19-Nov-2018  U033632  E1DK939349 SCTASK0753994:1.Code added to create*
*                                  proforma invoice for ZDF8 billing   *
*                                  type                                *
*                                  2. Added Creation date and Proforma *
*                                  CI for Sales BOM on selection screen*
*&---------------------------------------------------------------------*

TABLES: likp, lips, vttk, eikp, eipo, vbpa.

INCLUDE /sapsll/pi_constants_r3.

TYPE-POOLS: vrm,
            sllr3.

CONSTANTS: BEGIN OF gc_variant_handle,
              h01  TYPE slis_handl VALUE '01',
           END OF gc_variant_handle.

DATA: gt_values       TYPE vrm_values.
DATA: gs_values       TYPE vrm_value.
DATA: gv_lines        TYPE i.
DATA: gv_rcode        TYPE sy-subrc.
DATA: gt_cus_inv      TYPE /sapsll/cus_inv_r3_t.
DATA: gt_cus_inv_disp TYPE /sapsll/cus_inv_disp_r3_t.
DATA: gt_cus_inv_all  TYPE /sapsll/cus_inv_disp_r3_t.
DATA: gt_cus_inv_del  TYPE /sapsll/cus_inv_r3_t.
DATA: gs_variant      TYPE disvariant.
DATA: gs_cus_inv      TYPE /sapsll/cus_inv_r3_s.
DATA: gv_repid        TYPE sy-repid.
DATA: gt_selection_table TYPE rsparams_tt.

*Begin of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
Types: ty_t_emi TYPE STANDARD TABLE OF zdev_enh_status. " Table Type for Enhancement Status
DATA: i_enh_status  TYPE ty_t_emi.            " Enhancement Status
*End of insert for D3_OTC_EDD_0414 SCTASK0753994 by U033632
