FUNCTION zotc_0043_billback_update_fm.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_VBRK) TYPE  VBRK
*"     REFERENCE(IM_CVBRP) TYPE  VBRPVB_T
*"     REFERENCE(IM_CKOMV) TYPE  KOMV_TAB
*"----------------------------------------------------------------------
************************************************************************
* PROGRAM    :  ZOTC_0043_BILLBACK_UPDATE_FM (FM)                      *
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
* 19-APR-2013  ADAS1    E1DK910010 D#3611: Refresh Global table & create
*                                  logic for mass upload               *
*&---------------------------------------------------------------------*
* 07-DEC-2013  SBASU    E1DK912403 D#1069: Delete  li_cvbrp should     *
*                                   happen only in create mode         *
*&---------------------------------------------------------------------*
* Delete Item tables based on index mainly required for mass update
* BOC ADD ADAS1 D#3611
  DATA: lv_index TYPE char10,
        li_cvbrp TYPE vbrpvb_t,
        li_ckomv TYPE komv_tab.
  FIELD-SYMBOLS : <lfs_t180> TYPE t180.
* Create Indexing
  gv_index = gv_index + 1.

* Refresh & Populate Item tables with all items
  REFRESH: li_cvbrp[].
  CLEAR  : lv_index.
  li_cvbrp[] = im_cvbrp[].
  li_ckomv[] = im_ckomv[].
  ASSIGN ('(SAPLV60A)T180')    TO <lfs_t180>.
* Create Variable of Indexing type
  MOVE gv_index TO lv_index.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = lv_index
    IMPORTING
      output = lv_index.
  REPLACE FIRST OCCURRENCE OF '0' IN lv_index WITH '$'.

  IF <lfs_t180> IS ASSIGNED AND <lfs_t180>-trtyp EQ 'H'. "Added by SBASU D#1069
* Deleting temporary item tables based on Index
    DELETE li_cvbrp WHERE vbeln NE lv_index.
    DELETE li_ckomv WHERE knumv NE lv_index.
* EOC ADD ADAS1 D#3611
  ENDIF. "Added by SBASU D#1069

* Get Values from Stack
  PERFORM f_get_stack_val USING    im_vbrk   " ADD ADAS1 D#3611
                                   lv_index  " ADD ADAS1 D#3611
                                   li_cvbrp  " ADD ADAS1 D#3611
                          CHANGING x_kuagv
                                   x_kuwev
                                   x_vbkd
                                   i_vbpa.

* Get Original Inv, settle & balance qty
* BOC ADAS1 08/07/2012
  IF ( im_vbrk-vbtyp = c_credit  OR
       im_vbrk-vbtyp = c_debit ).
    PERFORM f_get_original_doc  USING im_vbrk
                                      li_cvbrp "im_cvbrp " ADAS1 Change D#3611
                                CHANGING i_vbrk_vbrp_so
                                         i_vbrk_vbrp_bill.
  ENDIF.
* EOC ADAS1 08/07/2012

* Get Customer specific data
  PERFORM f_get_customer   CHANGING i_vbpa
                                    i_edpar
                                    i_kna1.

*  Get materials based on Product Family
  PERFORM f_get_mat_prodfamily USING    im_vbrk
                                        li_cvbrp "im_cvbrp " ADAS1 Change D#3611
                               CHANGING i_mvke[].

* Get Billback table for all the materials
  PERFORM f_get_billback USING li_cvbrp "im_cvbrp " ADAS1 Change D#3611
                               i_mvke
                         CHANGING i_billback.

* BOC ADAS1 08/07/2012
* Get Original Invoice no
  IF ( im_vbrk-vbtyp = c_credit  OR
       im_vbrk-vbtyp = c_debit ).
    PERFORM f_get_billback_crdr USING i_vbrk_vbrp_so
                                      i_vbrk_vbrp_bill
                                CHANGING i_billback_org.
  ENDIF. " IF ( im_vbrk-vbtyp = c_credit  OR
  "      im_vbrk-vbtyp = c_debit ).
* EOC ADAS1 08/07/2012

* Prepare Billback table with new entries for Invoice
  PERFORM f_populate_final USING im_vbrk
                                 li_cvbrp "im_cvbrp " ADAS1 Change D#3611
                                 li_ckomv "im_ckomv " ADAS1 Change D#3611
                                 i_vbpa
                                 i_edpar
                                 i_kna1
                                 i_billback
                                 i_vbrk_vbrp_so
                                 i_vbrk_vbrp_bill
                                 i_billback_org
                                 x_kuwev
                                 x_vbkd
                        CHANGING i_zotc_billback.

* Update Billback table
  PERFORM f_update_db USING i_zotc_billback.

* BOC ADD ADAS1 D#3611
* Refresh all global tables
  REFRESH: i_zotc_billback[],
           i_billback[],
           i_vbpa[],
           i_edpar[],
           i_kna1[],
           i_mvke[],
           i_vbrk_vbrp_bill[],
           i_vbrk_vbrp_so[],
           i_billback_org[].
* BOC ADD ADAS1 D#3611

ENDFUNCTION.
