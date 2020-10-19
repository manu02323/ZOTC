*$*$----------------------------------------------------------------$*$*
*$ Correction Inst.         0120024545 0000001797                     $*
*$--------------------------------------------------------------------$*
*$ Valid for       :                                                  $*
*$ Software Component   SAP_APPL   SAP Application                    $*
*$  Release 31I          All Support Package Levels                   $*
*$  Release 40B          All Support Package Levels                   $*
*$  Release 45B          All Support Package Levels                   $*
*$  Release 46B          All Support Package Levels                   $*
*$  Release 46C          All Support Package Levels                   $*
*$  Release 470          All Support Package Levels                   $*
*$  Release 500          Fm SAPKH50001                                $*
*$  Release 600          Fm SAPKH60001                                $*
*$  Release 602          All Support Package Levels                   $*
*$  Release 603          All Support Package Levels                   $*
*$  Release 604          Fm SAPKH60401                                $*
*$  Release 605          All Support Package Levels                   $*
*$  Release 606          Fm SAPKH60601                                $*
*$  Release 616          All Support Package Levels                   $*
*$  Release 617          All Support Package Levels                   $*
*$  Release 618          All Support Package Levels                   $*
*$--------------------------------------------------------------------$*
*$ Changes/Objects Not Contained in Standard SAP System               $*
*$*$----------------------------------------------------------------$*$*
*&--------------------------------------------------------------------*
*& Object          REPS ZXV05U06
*& Object Header   PROG ZXV05U06
*&--------------------------------------------------------------------*
*& FORM ZXV05U06
*&--------------------------------------------------------------------*
...
*&---------------------------------------------------------------------*
*&  Include           ZXV05U06                                         *
*&---------------------------------------------------------------------*

************************************************************************
* PROGRAM    :  ZXV05U06 (User Exit -Enhancement)                      *
* TITLE      :  Update Billing Due Index for Intercompany Invoice      *
* DEVELOPER  :  Shushant Nigam                                         *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_EDD_0022                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: It is required to implement OSS Note 38501 to ensure    *
* that billing due index is updated for intercompany invoice creation  *
* before customer invoice creation. However, implementing this note    *
* will make this feature applied globally for all Sales organizations, *
* which is not intended before proper impact analysis. Hence, it is    *
* required to restrict this change to Italy Sales Organization only &  *
* Billing type ZF2N (to be maintained using EMI entry).                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 21-Feb-2018 U024694  E1DK934648 INITIAL DEVELOPMENT  - D3_R3         *
*&---------------------------------------------------------------------*



* Constant declaration
CONSTANTS: lc_emi_proj TYPE z_enhancement VALUE 'D2_OTC_EDD_0022', " Enhancement No.
           lc_null     TYPE z_criteria    VALUE 'NULL',            " Enh. Criteria
           lc_vkorg    TYPE z_criteria    VALUE 'VKORG_D3',        " Enh. Criteria
           lc_fkart    TYPE z_criteria    VALUE 'FKART'.           " FKIVK

* Data declaraions
DATA: li_enh_status  TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
      lwa_enh_status TYPE zdev_enh_status.                   " Enhancement Status

FIELD-SYMBOLS: <lfs_vkorg> TYPE vkorg, " Sales Organization
               <lfs_fkart> TYPE fkart. " Billing Type


* Check if the object is active from EMI.
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_emi_proj
  TABLES
    tt_enh_status     = li_enh_status.

IF li_enh_status IS NOT INITIAL.

  DELETE li_enh_status  WHERE active IS INITIAL.

  IF li_enh_status IS NOT INITIAL.

* Check  NULL activated or not
    READ TABLE li_enh_status WITH KEY criteria = lc_null TRANSPORTING NO FIELDS.

    IF sy-subrc  EQ 0.

* Get Sales Org from Stack
      ASSIGN ('(SAPLV05I)VKDFS-VKORG') TO <lfs_vkorg>.

      IF sy-subrc = 0.
        READ TABLE li_enh_status  WITH KEY criteria = lc_vkorg
                                           sel_low = <lfs_vkorg> TRANSPORTING NO FIELDS.
        IF sy-subrc  EQ 0.

* Get Billing type from Stack
          ASSIGN ('(SAPLV05I)VKDFS-FKART') TO <lfs_fkart>.
          IF sy-subrc = 0.
            READ TABLE li_enh_status WITH KEY criteria = lc_fkart
                                              sel_low =  <lfs_fkart> TRANSPORTING NO FIELDS.
            IF sy-subrc  EQ 0.

* >>>>>>  Begin of modification of note 38501  <<<<<<
              IF fvbuk-fkivk CA 'AB' AND fvbuk-wbstk CA 'C'.
                fiv_cust_index = '1'.
              ENDIF. " IF fvbuk-fkivk CA 'AB' AND fvbuk-wbstk CA 'C'
* >>>>>>  End of modification of note 38501  <<<<<<

            ENDIF. " IF sy-subrc EQ 0

          ENDIF. " IF sy-subrc = 0

        ENDIF. " IF sy-subrc EQ 0

      ENDIF. " IF sy-subrc = 0

    ENDIF. " IF sy-subrc EQ 0

  ENDIF. " IF li_enh_status IS NOT INITIAL

ENDIF. " IF li_enh_status IS NOT INITIAL



*&--------------------------------------------------------------------*
