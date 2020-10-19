*&---------------------------------------------------------------------*
*&  Include           ZOTCN0094O_DBKMVF02
*&---------------------------------------------------------------------*
* PROGRAM    :  ZOTCN0094O_DBKMVF02                                    *
* TITLE      :  New Columns in VKM1 Report                             *
* DEVELOPER  :  Babli Samanta                                          *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0094                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: The required functionality is to populate two more
*              columns, Sales Document Type (AUART) and Header
*              Delivery Block (LIFSK) in the VKM1 Report.
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 09-AUG-2013 BMAJI    E1DK911307 CR#577: INITIAL DEVELOPMENT: As per
*                                 OSS note 779389: Populate 2 new
*                                 fields-ZZAUART, ZZLIFSK
*&---------------------------------------------------------------------*
* 16-NOV-2013 GNAG     E1DK912192 CR#499: Add the Cust group in the
*                                 output display
*&---------------------------------------------------------------------*

* BoC CR#499
TYPES:
  BEGIN OF lty_knkk,
    kkber TYPE KKBER,     " Credit Control Area
    knkli TYPE KNKLI,     " Customer's account number with credit limit reference
    kdgrp TYPE KDGRP_CM,  " Customer Group
  END OF lty_knkk,
  lty_t_knkk TYPE TABLE OF lty_knkk.    " Int table type for Cust group
* EoC CR#499

*&&-- Local Data Declaration
FIELD-SYMBOLS:
  <lfs_vbkred> TYPE vbkred, "Field sym for Rele of CR Limit
  <lfs_knkk>   TYPE lty_knkk. " Cust Credit mgmt : CR#499

DATA: lwa_xvbak TYPE vbak,               "Workarea for Sales Order Header
      li_vbak TYPE STANDARD TABLE OF vbak,"Int Tab for Sales Order Header
      li_xknkk TYPE lty_t_knkk,           " Cust Credit mgmt : CR#499
      li_xvbkred_tmp TYPE STANDARD TABLE OF vbkred. " Credit limit : CR#499

*&&-- In order to sort the internal VBAK data
li_vbak[] = xvbak[].
SORT li_vbak BY vbeln.

* BoC CR#499
* Get the Cust group for all the cust from KNKK table. This is needed as the
* available int table XKNKK does not contain the value of Cust group (KDGRP)
* in XKNKK-KDGRP
li_xvbkred_tmp = xvbkred[].
SORT li_xvbkred_tmp BY kkber knkli.
DELETE ADJACENT DUPLICATES FROM li_xvbkred_tmp COMPARING kkber knkli.

SELECT kkber    " Credit Control Area
       knkli    " Customer's account number with credit limit reference
       kdgrp    " Customer Group
  FROM knkk     " Customer master credit management: Control area data
  INTO TABLE li_xknkk
   FOR ALL ENTRIES IN li_xvbkred_tmp
 WHERE kkber = li_xvbkred_tmp-kkber
   AND knkli = li_xvbkred_tmp-knkli.
IF sy-subrc IS INITIAL.
  SORT li_xknkk BY kkber knkli.   " For binary search
ENDIF.
* EoC CR#499

*&&-- Populate the fields in XVBKRED
LOOP AT xvbkred ASSIGNING <lfs_vbkred>.
  READ TABLE li_vbak INTO lwa_xvbak
                   WITH KEY vbeln = <lfs_vbkred>-vbeln
                   BINARY SEARCH.
  IF sy-subrc IS INITIAL.
*&&-- Sales Document Type
    <lfs_vbkred>-zzauart = lwa_xvbak-auart.
*&&-- Header Delivery Block
    <lfs_vbkred>-zzlifsk = lwa_xvbak-lifsk.
    CLEAR lwa_xvbak.
  ENDIF.

* BoC CR#499
* Read the value of the Cust group and update in the VBKRED table
  READ TABLE li_xknkk ASSIGNING <lfs_knkk> WITH KEY kkber = <lfs_vbkred>-kkber
                                                    knkli = <lfs_vbkred>-knkli
                                           BINARY SEARCH.
  IF sy-subrc IS INITIAL.
    <lfs_vbkred>-zzkdgrp = <lfs_knkk>-kdgrp.
  ENDIF.
* EoC CR#499

ENDLOOP.
