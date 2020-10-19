FUNCTION zotc_0210_prod_list_exclusion.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_APPLICATION) LIKE  T683-KAPPL
*"     VALUE(IM_DATE) LIKE  SY-DATUM
*"     VALUE(IM_HEADER_COMMUNICATION) LIKE  KOMKG STRUCTURE  KOMKG
*"     VALUE(IM_ITEM_COMMUNICATION) LIKE  KOMPG STRUCTURE  KOMPG
*"     VALUE(IM_LIST) TYPE  FLAG
*"     VALUE(IM_VERLI) LIKE  TVAK-VERLI OPTIONAL
*"     VALUE(IM_SCHEME) LIKE  T683-KALSM
*"     VALUE(IM_PROTOKOLL) TYPE  FLAG OPTIONAL
*"  EXPORTING
*"     VALUE(EX_ENTRY_FOUND) TYPE  CHAR1
*"----------------------------------------------------------------------
*"----------------------------------------------------------------------
************************************************************************
* FUNCTION MODULE  :  ZOTC_0210_PROD_LIST_EXCLUSIONZ                   *
* TITLE            :  Requirement routine for Listings Exclusions      *
* DEVELOPER        :  NEHA KUMARI                                      *
* OBJECT TYPE      :  ENHANCEMENT                                      *
* SAP RELEASE      :  SAP ECC 6.0                                      *
*----------------------------------------------------------------------*
*  WRICEF ID :  D2_OTC_EDD_0210                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: Requirement routine for Listings Exclusions             *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER     TRANSPORT   DESCRIPTION                        *
* ===========  ======== ==========  ===================================*
* 09-SEP-2014  NKUMARI  E2DK904374  INITIAL DEVELOPMENT                *
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(APPLICATION) LIKE  T683-KAPPL
*"     VALUE(DATE) LIKE  SY-DATUM
*"     VALUE(HEADER_COMMUNICATION) LIKE  KOMKG STRUCTURE  KOMKG
*"     VALUE(ITEM_COMMUNICATION) LIKE  KOMPG STRUCTURE  KOMPG
*"     VALUE(LIST) TYPE  FLAG
*"     VALUE(VERLI) LIKE  TVAK-VERLI OPTIONAL
*"     VALUE(SCHEME) LIKE  T683-KALSM
*"     VALUE(PROTOKOLL) TYPE  FLAG OPTIONAL
*"  EXPORTING
*"     VALUE(ENTRY_FOUND) TYPE  CHAR1

* Call the standard FM to check customer entry is existing
* in standard table
  CALL FUNCTION 'PRODUCT_LIST_EXCLUSION'
    EXPORTING
      application          = im_application
      date                 = im_date
      header_communication = im_header_communication
      item_communication   = im_item_communication
      list                 = im_list
      verli                = im_verli
      scheme               = im_scheme
      protokoll            = im_protokoll
    IMPORTING
      entry_found          = ex_entry_found.


ENDFUNCTION.
