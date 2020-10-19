************************************************************************
* PROGRAM    :  ZOTCN0043O_BILLBACK_UPD (Include)                      *
* TITLE      :  Billback Enhancement for Billing User Exit             *
* DEVELOPER  :  ANANYA DAS                                             *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0043                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Update Custom table with Billing informations when
* Invoice is created and Accounting documement is genarated
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 25-APR-2012  RNATHAK  E1DK901257 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
  CONSTANTS: lc_invoice   TYPE vbtyp VALUE 'M',  " Billing Type - Inv
*            BOC ADAS1 08/07/2012
             lc_credit    TYPE vbtyp VALUE 'O',  " Credit Memo
             lc_debit     TYPE vbtyp VALUE 'P',  " Debit Memo
*            EOC ADAS1 08/07/2012
             lc_cust_grp  TYPE kdgrp VALUE 'CR'. " Cardinal Customer

* This enhancement should get triggered during Billing doc creation
* and also only for Customer Group - Cardinal Customers - CR
  IF ( vbrk-vbtyp = lc_invoice OR
*      BOC ADAS1 08/07/2012
       vbrk-vbtyp = lc_credit  OR
       vbrk-vbtyp = lc_debit ) AND
*      EOC ADAS1 08/07/2012
       vbrk-kdgrp = lc_cust_grp.

*   FM to update Billback Table
    CALL FUNCTION 'ZOTC_0043_BILLBACK_UPDATE_FM'
      EXPORTING
        im_vbrk  = vbrk
        im_cvbrp = cvbrp[]
        im_ckomv = ckomv[].

  ENDIF.  " IF vbrk-vbtyp = lc_invoice AND
          "    vbrk-kdgrp = lc_cust_grp.
