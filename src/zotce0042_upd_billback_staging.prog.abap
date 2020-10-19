************************************************************************
* PROGRAM    :  ZIM_UPDATE_BILLBACK_STAGING (Enhancement)              *
* TITLE      :  Populate Billback staging table with Sales data        *
* DEVELOPER  :  Santosh Vinapamula                                     *
* OBJECT TYPE:  INCLUDE                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0042                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Populate Billback staging table with EDI 867 data       *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 15-JUN-2012  SVINAPA  E1DK901251 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*

* Populate Billback staging table from EDI867 data
CONSTANTS: lc_credit TYPE auart VALUE 'ZBBC', " Sales Document Type
           lc_debit  TYPE auart VALUE 'ZDBC', " Sales Document Type
           lc_delete TYPE updkz_d VALUE 'D'.  " Update indicator

IF vbak-auart = lc_credit OR
   vbak-auart = lc_debit.

  IF xvbak_updkz <> lc_delete.

* Call function in update task
    CALL FUNCTION 'ZOTC_UPDATE_BILLBACK_STAGING'
      IN UPDATE TASK
      EXPORTING
        im_vbak = vbak
        im_vbap = xvbap[]
        im_vbpa = xvbpa[]
        im_vbkd = xvbkd[]
        im_komv = xkomv[].

  ENDIF. " IF xvbak_updkz <> lc_delete

ENDIF. " IF vbak-auart = lc_credit OR

***********************************************************************
***********************************************************************
***********************************************************************
*PROGRAM    : ZIM_UPDATE_BILLBACK_STAGING (Enhancement)              *
*Title      : ES Sales Order Creation                                 *
*Developer  : Jahan Mazumder                                          *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0090 / CR - D2_9, 20, 127, 137, 159            *
*---------------------------------------------------------------------*
*Description: Assign serial number to each materiaql for each line    *
*             during SO creation from SVCMX and Evo Sales Order       *
*             submit interface                                        *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:                                                *
*=====================================================================*
*Date           User        Transport       Description               *
*=========== ============== ============== ===========================*
*30-July-2014  JAHAN/MANISH E2DK904466      INITIAL DEVELOPMENT       *
*---------------------------------------------------------------------*

CONSTANTS: lc_ord_typ   TYPE vbtyp  VALUE 'C',         " SD document category
           lc_operation TYPE beleg  VALUE 'SDAU',      " Serialization Procedure for Serial Number Management
           lc_objkopf   TYPE taser  VALUE 'SER02',     " Table for Serial Numbers
           lc_vorgang   TYPE char4  VALUE 'PMS2',      " Indicator controls: X = activity " " = element
           lc_memory_id TYPE char15 VALUE 'SERIAL_NO'. " Memory ID for each item

TYPES: BEGIN OF lty_sernr,
         sernr TYPE gernr, "Serial No
       END OF lty_sernr.

DATA:  lv_memory_id          TYPE char15,     " Memory ID for each item
       lv_anzsn              TYPE lips-anzsn, " Number of serial numbers
       lv_new_obknr          TYPE objknr,     " Object list number
       lv_zeile              TYPE msgzeile,   " Line number
       lv_anzser             TYPE anzser,     " Quantity
       lv_kwmeng             TYPE n,          " Kwmeng of type Numeric Text Fields
       lv_serial_commit      TYPE c,          " Serial_commit of type Character
       lv_status_not_allowed TYPE c,          " Status_not_allowed of type Character
       wa_serxx              TYPE rserxx,     " I/O Table for Serial Number Headers SERXX
       wa_sernr              TYPE e1rmsno,    " Repetitive Manufacturing Serial Number
       li_sern               TYPE sernr_t,
       li_sern_msg           TYPE mmpur_serno_mess,
       li_serial_no          TYPE STANDARD TABLE OF lty_sernr.

FIELD-SYMBOLS:
  <lfs_vbak>          TYPE vbak,   " Sales doc item data
  <lfs_vbap>          TYPE vbapvb, " Sales doc item data
  <lfs_vbpa>          TYPE vbpavb, " Sales doc partner data
  <lfs_sernr>         TYPE lty_sernr.


LOOP AT xvbap ASSIGNING <lfs_vbap>.

  wa_serxx-sdaufnr   = vbak-vbeln.
  wa_serxx-posnr     = <lfs_vbap>-posnr.
  wa_serxx-vbtyp     = lc_ord_typ. "'C'. "Constant Order = C
  wa_serxx-sd_auart  = vbak-auart.
  wa_serxx-sd_postyp = <lfs_vbap>-pstyv.
  lv_kwmeng = <lfs_vbap>-kwmeng.
  lv_anzser = lv_kwmeng.

  READ TABLE xvbpa ASSIGNING <lfs_vbpa> WITH KEY parvw = 'AG'.
  IF sy-subrc EQ 0.
    wa_serxx-kunde     = <lfs_vbpa>-kunnr. "for XVBPA[1]-PARVW = 'AG'
  ENDIF. " IF sy-subrc EQ 0

  REFRESH li_serial_no.
  CONCATENATE lc_memory_id <lfs_vbap>-posex INTO lv_memory_id SEPARATED BY '_'.
  IMPORT li_serial_no_t TO li_serial_no FROM MEMORY ID lv_memory_id.

  LOOP AT li_serial_no ASSIGNING <lfs_sernr>.
    wa_sernr-sernr = <lfs_sernr>-sernr.
    APPEND wa_sernr TO li_sern.
    CLEAR wa_sernr.
  ENDLOOP. " LOOP AT li_serial_no ASSIGNING <lfs_sernr>

  CALL FUNCTION 'SERNR_ADD_TO_DOCUMENT'
    EXPORTING
      operation                 = lc_operation "'SDAU'
      objkopf                   = lc_objkopf   "'SER02'
      serxx                     = wa_serxx
      material                  = <lfs_vbap>-matnr
      profile                   = <lfs_vbap>-serail
      quantity                  = lv_anzser
      j_vorgang                 = lc_vorgang   "'PMS2'
    IMPORTING
      anzsn                     = lv_anzsn
      new_obknr                 = lv_new_obknr
      serial_commit             = lv_serial_commit
      status_not_allowed        = lv_status_not_allowed
    TABLES
      sernr                     = li_sern
      r_sernr                   = li_sern_msg
    EXCEPTIONS
      konfigurations_error      = 1
      general_serial_error      = 2
      no_profile_operation      = 3
      difference_in_header_data = 4
      OTHERS                    = 5.

  IF sy-subrc EQ 0.
    CALL FUNCTION 'SERIAL_LISTE_POST_AU'.
  ENDIF. " IF sy-subrc EQ 0

ENDLOOP. " LOOP AT xvbap ASSIGNING <lfs_vbap>
