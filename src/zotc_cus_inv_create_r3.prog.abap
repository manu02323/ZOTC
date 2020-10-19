*&---------------------------------------------------------------------*
*& Report  ZOTC_CUS_INV_CREATE_R3
*&
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTC_CUS_INV_CREATE_R3                                 *
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
*&---------------------------------------------------------------------*
REPORT  zotc_cus_inv_create_r3 MESSAGE-ID /sapsll/pluginr3.

*------ Top-Include
INCLUDE ZOTC_CUS_INV_CREATE_TOP.
*INCLUDE /sapsll/cus_inv_create_top.

*------ Selektionsbild
INCLUDE ZOTC_CUS_INV_CREATE_PAR.
*INCLUDE /sapsll/cus_inv_create_par.

*------ Routinen
INCLUDE ZOTC_CUS_INV_CREATE_FOR.
*INCLUDE /sapsll/cus_inv_create_for.

*------ Hauptprogramm
INCLUDE ZOTC_CUS_INV_CREATE_PRO.
*INCLUDE /sapsll/cus_inv_create_pro.
