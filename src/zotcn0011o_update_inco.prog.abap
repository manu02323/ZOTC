*&---------------------------------------------------------------------*
*&  Include           ZOTCN0011O_UPDATE_INCO
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0011O_UPDATE_INCO(Include)                        *
* TITLE      :  Update Incoterms for ZIT1                              *
* DEVELOPER  :  Gautam Nag                                             *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   CR#785(OTC_EDD_0011)                                    *
*----------------------------------------------------------------------*
* DESCRIPTION: If the business data header has INCO1 = FCA, then check *
*              condition ZIT1 in each line items. If the value KWERT >0*
*              then change the value of INCO1 of that item to DAP      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 17-OCT-2013 GNAG     E1DK911983 Initial dev - CR#785: Update Incoterms*
*&---------------------------------------------------------------------*
* 07-Apr-2014 RVERMA   E1DK913055 Def#1317 - Bug fix for updating VBKD *
*                                 table in sales order create and      *
*                                 change mode.                         *
*&---------------------------------------------------------------------*

* Local constants
CONSTANTS:
  lc_posnr_h       TYPE posnr   VALUE '000000',  " Header line for SD
  lc_program_inco  TYPE char50  VALUE 'ZOTCN0011O_UPDATE_INCO', " Program Name
  lc_fld_inco_s    TYPE char50  VALUE 'VBKD-INCO1', " Field Name for Inco1
  lc_fld_inco_t    TYPE char50  VALUE 'VBKD-INCO1_TARGET', " Target Inco1
  lc_fld_kschl     TYPE char50  VALUE 'KONV-KSCHL', " Field Name for KSCHL
  lc_opt_eq        TYPE char2   VALUE 'EQ',     " Option EQ
  lc_trtyp_cre     TYPE trtyp   VALUE 'H',       " Creation mode
  lc_trtyp_chg     TYPE trtyp   VALUE 'V',       " Change mode
  lc_updkz_chg     TYPE updkz_d VALUE 'U',       " Update mode
  lc_updkz_cre     TYPE updkz_d VALUE 'I'.       " Insert mode

TYPES:
  BEGIN OF lty_prc_control,
    mparameter TYPE ENHEE_PARAMETER,    " Parameter field name
    mvalue1    TYPE Z_MVALUE_LOW,       " Field value
  END OF lty_prc_control,
  lty_t_prc_control TYPE STANDARD TABLE OF lty_prc_control. " Tab type for prc_control

* Local work area
DATA:
  lwa_vbkd   TYPE vbkdvb,    " Reference structure for XVBKD/YVBKD
  lv_inco_t  TYPE inco1,     " Target Inco1 value
  lv_kschl   TYPE kscha,     " Condition type (ZIT1)
  li_otc_prc_control TYPE lty_t_prc_control.   " Int Table for prc_control

* Local field sumbols
FIELD-SYMBOLS:
  <lfs_vbkd>        TYPE vbkdvb,  " SD str business data
  <lfs_vbkd_h>      TYPE vbkdvb,  " SD str business data
  <lfs_komv_zit1>   TYPE komv,    " Conditions (Transaction Data)
  <lfs_otc_prc_control> TYPE lty_prc_control.    " Conditions (Transaction Data)

* This is needed for creation and change mode
IF t180-trtyp = lc_trtyp_cre OR
   t180-trtyp = lc_trtyp_chg.

* Check if the header business data has the incoterm FCA
* (No Binary search needed as there would be only few lines and also
* XVBKD is std)
  READ TABLE xvbkd ASSIGNING <lfs_vbkd_h> WITH KEY vbeln = vbak-vbeln
                                                   posnr = lc_posnr_h.
  IF sy-subrc IS INITIAL.

*   Fetch all the hardcode replacements from the control table, e.g.
*   FCA, DAP, ZIT1 etc.
    SELECT mparameter     " Parameter field name
           mvalue1        " Field value
      FROM zotc_prc_control
      INTO TABLE li_otc_prc_control
      WHERE vkorg      = vbak-vkorg
        AND vtweg      = vbak-vtweg
        AND mprogram   = lc_program_inco
        AND mactive    = abap_true
        AND soption    = lc_opt_eq.
    IF sy-subrc IS INITIAL.

*     Check if the INCO1 maintained in OTC Control table. If the INCO1
*     matched, only then this rule should be applied.
      READ TABLE li_otc_prc_control TRANSPORTING NO FIELDS
                                    WITH KEY mparameter = lc_fld_inco_s
                                             mvalue1    = <lfs_vbkd_h>-inco1.
      IF sy-subrc IS INITIAL.       " INCO1 = FCA etc.

*       Get the target INCO1 value (DAP)
        READ TABLE li_otc_prc_control ASSIGNING <lfs_otc_prc_control>
                                      WITH KEY mparameter = lc_fld_inco_t.
        IF sy-subrc IS INITIAL.
          lv_inco_t = <lfs_otc_prc_control>-mvalue1.
        ENDIF.

*       Get the condition type for value check (ZIT1)
        READ TABLE li_otc_prc_control ASSIGNING <lfs_otc_prc_control>
                                      WITH KEY mparameter = lc_fld_kschl.
        IF sy-subrc IS INITIAL.
          lv_kschl = <lfs_otc_prc_control>-mvalue1.
        ENDIF.

*       If the target INCO1 value and condition type are not maintained
*       in the control table, then skip
        IF lv_inco_t IS NOT INITIAL AND
           lv_kschl IS NOT INITIAL.

*         Check all the condition records ZIT1 and for each line, check if
*         business data table has that item already added or not. If yes,
*         then modify the INCO1 of that line to DAP; if not, then add that
*         line item in VBKD and update the INCO1 to DAP
          LOOP AT xkomv ASSIGNING <lfs_komv_zit1> WHERE kschl = lv_kschl.

*           The updation of the INCO1 is done only if the ZIT1 value is +ve
            IF <lfs_komv_zit1>-kwert GT 0.
*             Check if the business data table already has this line item
*             updated in it. If yes, modify the INCO1 value to DAP, else
*             add that line item in VBKD with INCO1 = DAP
*             No Binary search needed as only few lines and also XVBKD is std
              READ TABLE xvbkd ASSIGNING <lfs_vbkd>
                               WITH KEY vbeln = vbak-vbeln
                                        posnr = <lfs_komv_zit1>-kposn.
              IF sy-subrc IS INITIAL.
                <lfs_vbkd>-inco1 = lv_inco_t.

*&--BOC : HPQC Defect # 1317 : User ID - RVERMA : Date - 07-Apr-2014
*                <lfs_vbkd>-updkz = lc_updkz_chg.      " update flag

                IF <lfs_vbkd>-updkz IS INITIAL.
                  <lfs_vbkd>-updkz = lc_updkz_chg.
                ENDIF.
*&--EOC : HPQC Defect # 1317 : User ID - RVERMA : Date - 07-Apr-2014
              ELSE.
                lwa_vbkd = <lfs_vbkd_h>.
                lwa_vbkd-posnr = <lfs_komv_zit1>-kposn.
                lwa_vbkd-inco1 = lv_inco_t.
                lwa_vbkd-updkz = lc_updkz_cre.      " insert flag
                APPEND lwa_vbkd TO xvbkd.
                CLEAR lwa_vbkd.
              ENDIF.
            ENDIF.        " zit1-kwert GT 0.
          ENDLOOP.

        ENDIF.      " INCO1 target and KSCHL are maintained
      ENDIF.      " inco1 = FCA
    ENDIF.      " SELECT from control table
  ENDIF.      " INCO1 maintained in VBKD header
ENDIF.      " trtyp = H or V
