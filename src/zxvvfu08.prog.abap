*&---------------------------------------------------------------------*
*&  Include           ZXVVFU08
*&---------------------------------------------------------------------*

*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(CVBRK) LIKE  VBRK STRUCTURE  VBRK
*"     REFERENCE(DOC_NUMBER) LIKE  VBRK-VBELN OPTIONAL
*"  TABLES
*"      XACCIT STRUCTURE  ACCIT
*"      XACCCR STRUCTURE  ACCCR
*"      CVBRP STRUCTURE  VBRPVB OPTIONAL
*"      CKOMV STRUCTURE  KOMV
*"      CACCDPC STRUCTURE  ACCDPC OPTIONAL
*"      XACCFI STRUCTURE  ACCFI OPTIONAL
*"----------------------------------------------------------------------
************************************************************************
* Program          :  ZXVVFU08 (Include)                               *
* TITLE            :  User-exit to initialize the delivery qauntities  *
* DEVELOPER        :  NASRIN ALI                                       *
* OBJECT TYPE      :  ENHANCEMENT                                      *
* SAP RELEASE      :  SAP ECC 6.0                                      *
*----------------------------------------------------------------------*
*  WRICEF ID       :  D3_OTC_EDD_0337                                  *
*----------------------------------------------------------------------*
* DESCRIPTION      :  The delivery quantities are initialized when the *
*                     billing document is transfered                   *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER     TRANSPORT   DESCRIPTION                        *
* ===========  ======== ==========  ===================================*
* 01-JUN-2016  NALI     E1DK918440  INITIAL DEVELOPMENT                *
*&---------------------------------------------------------------------*
INCLUDE zotcn0337o_init_delivery_quant. " Include ZOTCN0337O_INIT_DELIVERY_QUANT
