*&---------------------------------------------------------------------*
*&  Include           ZOTCN0011O_CR1475
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0011O_CR1475                                      *
* TITLE      :  Issue while creating PR from Sales Data using customize*
*               -d routine 902. OSS Note: 603547                       *
* DEVELOPER  :  Sneha Mukherjee                                        *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 7.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  CR#1475(OTC_EDD_0011)                                    *
*----------------------------------------------------------------------*
* DESCRIPTION:  Issue while creating PR from Sales Data using customize*
*               -d routine 902.                                        *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 17-OCT-2014 SMUKHER  E1DK914536 CR#1475: Issue while creating PR from*
*                                 Sales Data using customized routine  *
*                                 902.                                 *
* 12-SEP-2019 U105993  E2DK926716 INC0505510-02 Defect#10251:          *
*                                 RFC error - item does not exist      *
*&---------------------------------------------------------------------*

* Begin of changes for INC0505510-02 defect# 10251 by u105993 on 12-SEP-2019

*-----------------Local Structure Declarations-------------------------*
TYPES: BEGIN OF lty_mara,
         matnr TYPE matnr, " Material
         xchpf TYPE xchpf, " Batch management requirement indicator
       END OF lty_mara,

       BEGIN OF lty_marc,
         matnr TYPE matnr, " Material
         werks TYPE werks_d,
         xchar TYPE xchar, " Batch management indicator (internal)
       END OF lty_marc.

*-----------------Local Internal Declarations-------------------------*
DATA: li_mara   TYPE STANDARD TABLE OF lty_mara INITIAL SIZE 0, " Mara Internal table
      li_marc   TYPE STANDARD TABLE OF lty_marc INITIAL SIZE 0, " Marc Internal table

*-----------------Local Range Declaration-----------------------------*
      lr_matnr  TYPE range_t_matnr, " Local range to store Materials

*-----------------Local Work Area Declaration-------------------------*
      lwa_matnr TYPE range_s_matnr. " Work area for Materials

*-----------------Local Constant Declaration--------------------------*
CONSTANTS : lc_sign   TYPE char1 VALUE 'I', " Sign
            lc_option TYPE char2 VALUE 'EQ'. " Option

LOOP AT xvbap[] ASSIGNING FIELD-SYMBOL(<lfs_xvbap_matnr>).
*   Fill Materials into Local range
  lwa_matnr-sign   = lc_sign.  " I
  lwa_matnr-option = lc_option." EQ
  lwa_matnr-low    = <lfs_xvbap_matnr>-matnr." Material
  APPEND lwa_matnr TO lr_matnr.
  CLEAR : lwa_matnr.
ENDLOOP."LOOP AT xvbap[] ASSIGNING FIELD-SYMBOL(<lfs_xvbap_matnr>).

IF lr_matnr IS NOT INITIAL.
*   Fetch data from MARA
  SELECT matnr " Material
         xchpf " Batch management requirement indicator
         INTO TABLE li_mara
         FROM mara
         WHERE matnr IN lr_matnr
         AND xchpf = abap_true.
  IF sy-subrc IS INITIAL.
    SORT li_mara BY matnr.
  ENDIF."  IF sy-subrc is INITIAL.
ENDIF."  IF lr_matnr is not INITIAL.

IF li_mara IS NOT INITIAL.
*      Fetch data from MARC
  SELECT matnr " Material
         werks
         xchar " Batch management indicator (internal)
         INTO TABLE li_marc
         FROM marc
         FOR ALL ENTRIES IN li_mara
         WHERE matnr EQ li_mara-matnr
         AND xchar = abap_true.
  IF sy-subrc IS INITIAL.
    SORT li_marc BY matnr werks.
  ENDIF."  IF sy-subrc is INITIAL.
ENDIF."  IF li_mara is not INITIAL.

LOOP AT xvbap ASSIGNING FIELD-SYMBOL(<lfs_xvbap_matnr1>).
*    To set value of VBAP-xchpf to X if MARA-XCHPF = 'X'
  READ TABLE li_mara ASSIGNING FIELD-SYMBOL(<lfs_mara>)
                     WITH KEY matnr = <lfs_xvbap_matnr1>-matnr
                     BINARY SEARCH.
  IF sy-subrc IS INITIAL
    AND <lfs_xvbap_matnr1>-xchpf IS INITIAL.
    <lfs_xvbap_matnr1>-xchpf = abap_true."  Batch management requirement indicator
  ENDIF."  IF sy-Subrc is initial
*            AND <lfs_mara>-xchpf = abap_true
*            AND <lfs_xvbap_matnr1>-xchpf IS INITIAL.
*        To set value of VBAP-xchar to X if MARC-XCHAR = 'X'
  READ TABLE li_marc ASSIGNING FIELD-SYMBOL(<lfs_marc>)
                     WITH KEY matnr = <lfs_xvbap_matnr1>-matnr
                              werks = <lfs_xvbap_matnr1>-werks
                     BINARY SEARCH.
  IF sy-subrc IS INITIAL
    AND <lfs_xvbap_matnr1>-xchar IS INITIAL.
    <lfs_xvbap_matnr1>-xchar = abap_true."  Batch management indicator (internal)
  ENDIF." IF sy-subrc is initial
*           AND <lfs_marc>-xchar = abap_true
*           AND <lfs_xvbap_matnr1>-xchar IS INITIAL.
ENDLOOP."   LOOP AT xvbap ASSIGNING FIELD-SYMBOL(<lfs_xvbap_matnr1>).

* End of changes for INC0505510-02 defect# 10251 by u105993 on 12-SEP-2019


**&& -- Calling FM to resolve the issue.

CALL FUNCTION '/SAPSLL/CD_SD0A_R3'
  EXPORTING
    is_header             = vbak
    is_document_type      = tvak
    iv_simulation         = 'X'
    iv_deletion_indicator = yvbak_updkz
    iv_business_object    = businessobjekt
  TABLES
    it_partner_new        = xvbpa
    it_partner_old        = yvbpa
    it_item_new           = xvbap
    it_item_old           = yvbap
    it_item_status_new    = xvbup
    it_sched_line_vb      = xvbep
    it_business_data      = xvbkd
    it_partner_address    = xvbadr
  EXCEPTIONS
    OTHERS                = 1.
