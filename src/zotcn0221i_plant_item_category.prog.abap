*&---------------------------------------------------------------------*
*&  Include           ZOTCN0221I_PLANT_ITEM_CATEGORY
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZOTCN0221I_PLANT_ITEM_CATEGORY
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0221I_PLANT_ITEM_CATEGORY(Include)                *
* TITLE      :  Sales Order Enhancement                                *
* DEVELOPER  :  Babli Samanta                                          *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0221                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Check Item Category per Plant: If sales orders are not
*created using correct item category then the order gets stuck in the
*eWM queue. As a permanent fix business requirement is that the system
*should be able to check that right item category is specified for the
*line item in the sales order.
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 12-SEP-2014 BMAJI    E1DK915056  CR#1593: INITIAL DEVELOPMENT        *
*&---------------------------------------------------------------------*

types:
    begin of lty_control,
      mvalue1 type z_mvalue_low, "Select Options: Value Low
    end of lty_control,
    lty_control_t type standard table of lty_control."Table type

constants :
lc_prog_name  type char50
              value 'ZOTCN0221I_PLANT_ITEM_CATEGORY',"Program Name
lc_fld_name   type char50 value 'VBAP_WERKS-VBAP_PSTY',  "Field Name
lc_rsign_i    type char1  value 'I',     "Sign:Include
lc_roptn_eq   type char2  value 'EQ',    "Option:Equal
lc_hyphen     type char1  value '-',     "Hyphen
lc_create     type trtyp  value 'H',     "Add
lc_change     type trtyp  value 'V'.     "Change

data:
      lv_fcode               type syucomm,      "SY-UCOMM value
      lv_werks_pstyv         type z_mvalue_low, "Value from Z-table
      li_mvalue1_werks_pstyv type lty_control_t,"Int table for Z-table
      lwa_werks_pstyv_r like line of i_werks_pstyv_r."Workarea for range

field-symbols:
      <lfs_control> type lty_control.    "Control Data

*&&-- This check is triggered for Sales Order Create & Change
if t180-trtyp = lc_create or t180-trtyp = lc_change.
  if i_werks_pstyv_r[] is initial.
*&&-- Get type from custom table for Plants
    select mvalue1
    from  zotc_prc_control
    into  table li_mvalue1_werks_pstyv
    where vkorg      = vbak-vkorg   and
          vtweg      = vbak-vtweg   and
          mprogram   = lc_prog_name and
          mparameter = lc_fld_name  and
          mactive    = abap_true    and
          soption    = lc_roptn_eq.
    if sy-subrc is initial.

      loop at li_mvalue1_werks_pstyv assigning <lfs_control>.
*&&-- Get sales order item category & plant combination
*      from zotc_prc_control table into a Range table
        lwa_werks_pstyv_r-sign = lc_rsign_i.
        lwa_werks_pstyv_r-option = lc_roptn_eq.
        condense <lfs_control>-mvalue1.
        move <lfs_control>-mvalue1 to lwa_werks_pstyv_r-low.
        append lwa_werks_pstyv_r to i_werks_pstyv_r.
        clear lwa_werks_pstyv_r.
      endloop.
    endif.
  endif.

*&&-- Check if sales order item category & plant combination is valid
*    based on the zotc_prc_control table records
  if i_werks_pstyv_r[] is not initial.
    concatenate vbap-werks lc_hyphen vbap-pstyv
    into lv_werks_pstyv.
    if lv_werks_pstyv in i_werks_pstyv_r.
      message e999(zotc_msg).
    endif.
    clear lv_werks_pstyv.
  endif.
endif.
