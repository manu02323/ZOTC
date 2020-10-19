class ZCL_IM_BADI_BATCH_DETEREM definition
  public
  final
  create public .

public section.

  interfaces /SPE/IF_EX_BADI_BATCH_DETERM .
  interfaces IF_BADI_INTERFACE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_BADI_BATCH_DETEREM IMPLEMENTATION.


method /spe/if_ex_badi_batch_determ~get_batch_determ_criteria.
************************************************************************
* Method  : /SPE/IF_EX_BADI_BATCH_DETERM~GET_BATCH_DETERM_CRITERIA     *
* TITLE      :  Automatic Batch Determination at Sales Order in ECC    *
* DEVELOPER  :  Soumendra Behera                                       *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D3_OTC_EDD_0360                                          *
*----------------------------------------------------------------------*
* DESCRIPTION: Automatic Batch Determination at Sales Order in ECC     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT  DESCRIPTION                        *
* ===========  ========  ========== ===================================*
* 15-Sept-2016  SBEHERA  E1DK921679 Initial Development                *
* 04-Oct-2016   SBEHERA  E1DK921679 CR_D3_0072: Batch determination is *
*                                   only work for for transaction VA01 *
*                                   or VA02 or any other interface that*
*                                   creates/changes Sales Orders       *
* 30-Nov-2016   DARUMUG  E1DK921679 CR_D3_0272: Logic to take place    *
*                                   batch determination in EWM         *
* 15-Dec-2016   DARUMUG  E1DK921679 CR_D3_0299: Validate whether the   *
*                                   document is Sales or Delivery and  *
*                                   then determine the logic for Batch *
*                                   determination                      *
* 08-Feb-2017   DARUMUG  E1DK925614 Defect# 9395 - EMI table entry for *
*                                   plant and set replication value if *
*                                   Mat. Grp. 2 is in EMI table        *
*&---------------------------------------------------------------------*

  data:
    li_status          type standard table of  zdev_enh_status. "Internal table for Enhancement Status
*-Local Variable Declaration
  data: lv_lgnum     type lgnum, " Warehouse Number / Warehouse Complex
* ---> Begin of Change for D3_OTC_EDD_0360_CR_D3_0072 by SBEHERA
        lv_vbtyp     type vbtyp, " SD document category
* <--- End of Change for D3_OTC_EDD_0360_CR_D3_0072 by SBEHERA
        lv_batch_determ_ewm type /spe/batch_determ_flag. " Batch Determination in EWM via Batch Attribute Replication

*- Local Constant Declarations
  constants : lc_edd_0360 type z_enhancement value 'OTC_EDD_0360', " Local Constant for Enhancement Object Id
              lc_null     type z_criteria    value 'NULL',         " Local Constant for  Enh. Criteria
              lc_value_x  type /spe/batch_determ_flag value 'X',   " Batch Determination in EWM via Batch Attribute Replication
              lc_blank    type char1 value ' ',                    " Blank value
* ---> Begin of Change for D3_OTC_EDD_0360_CR_D3_0072 by SBEHERA
              lc_vbtyp    type char5 value 'VBTYP', " SD Document Category
* <--- End of Change for D3_OTC_EDD_0360_CR_D3_0072 by SBEHERA

* ---> Begin of Change for D3_OTC_EDD_0360_CR_D3_0272 by DARUMUG
              lc_mvgr2    type char10 value 'MVGR1_GRP2', " Material Group 2
              lc_mvgrp2   type char10 value 'MVGR2',      " Material Group 2
* <--- End of Change for D3_OTC_EDD_0360_CR_D3_0272 by DARUMUG

* ---> Begin of Change for D3_OTC_EDD_0360 Defect # 9395 by DARUMUG
              lc_werks    type char10 value 'WERKS'.      " Plant
* <--- End of Change for D3_OTC_EDD_0360 Defect # 9395 by DARUMUG

  field-symbols:
              <lfs_status> type  zdev_enh_status. "For Reading enhancement table

***//-->>Begin of Changes - D3_CR_0299
* Calling FM check if the Enhancement is active or not.
  call function 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    exporting
      iv_enhancement_no = lc_edd_0360 "Object ID number
    tables
      tt_enh_status     = li_status.  "Internal table for Enhancement Status

  if li_status is not initial.
    sort li_status  by criteria sel_low active.
*First of all criteria “NULL” in LI_STATUS is checked ,If it has Active flag as “X”.
* Non active entries are removed.
    delete li_status where active eq abap_false.
  endif. " IF li_status is NOT INITIAL

  read table li_status with key
                       criteria = lc_null transporting no fields. " NULL.
  if sy-subrc eq 0.

**//-->Begin of Changes - Defect# 9395
**----Fetch Warehouse Number / Warehouse Complex from table T320
* Not always SLOC will be populated in the incoming data due to custom
* requirement and hence lgort could not be added in where clause
*  select lgnum " Warehouse Number / Warehouse Complex
*    into lv_lgnum
*    up to 1 rows
*    from t320  " Assignment IM Storage Location to WM Warehouse Number
*   where werks = is_komph-werks.
*  endselect.
*  if sy-subrc is initial.
***---- Check Batch Determination in EWM via Batch Attribute Replication value in table T340D
*    select single
*      batch_determ_ewm " Batch Determination in EWM via Batch Attribute Replication
*      into lv_batch_determ_ewm
*      from t340d       " WM Default Values
*      where lgnum = lv_lgnum.
** In case value equals to “X” it means Batch Determination replication is activated in EWM.
*    if sy-subrc  is initial and lv_batch_determ_ewm = lc_value_x.
    "Check the EMI table for the plant
    read table li_status assigning <lfs_status>
                               with key criteria = lc_werks
                                        sel_low  = is_komph-werks
                                        active   = abap_true
                                        binary search.
    if sy-subrc eq 0.
**//-->End of Changes - Defect# 9395
      if is_komkh-auart is not initial.
        select single vbtyp " SD document category
          into lv_vbtyp
          from tvak         " Sales Document Types
         where auart = is_komkh-auart.
        if sy-subrc eq 0 ##needed.

*   Read status table for criteria VBTYP and active = X
          read table li_status assigning <lfs_status>
                                     with key criteria = lc_vbtyp
                                              active   = abap_true
                                              binary search.
* Check SD document category value to execute the logic for Batch Determination
          if sy-subrc eq 0 and lv_vbtyp eq <lfs_status>-sel_low.

*   Read status table for criteria MVGR1_GRP2 and active = X
            read table li_status assigning <lfs_status>
                                       with key criteria = lc_mvgr2
                                                sel_low  = is_komph-mvgr2
                                                active   = abap_true.
            if sy-subrc ne 0.
              cv_replic_value = lc_blank.
            else.
              "If material group 2 is maintained in EMI table then
              "set the value 'X' for Replication value
              cv_replic_value = lc_value_x.   "Defect 9395
            endif.
          endif.
        endif.
      else. "Delivery
*   Read status table for criteria MVGR1_GRP2 and active = X
        read table li_status assigning <lfs_status>
                                   with key criteria = lc_mvgrp2
                                            sel_low  = is_komph-mvgr2
                                            active   = abap_true.
        if sy-subrc eq 0.
          cv_replic_value = lc_blank.
        endif.
      endif. " IF is_komkh-auart IS NOT INITIAL
*    endif. " IF sy-subrc IS INITIAL AND lv_batch_determ_ewm = lc_value_x
    endif. " IF sy-subrc IS INITIAL
  endif.
***//-->>End of Changes - D3_CR_0299


**//-->> Based on above D3_CR_0299 the entire logic below commented and added logic from CR_D3_0072 & CR_D3_0272
** ---> Begin of Change for D3_OTC_EDD_0360_CR_D3_0072 by SBEHERA
*
*
*
*
**Binary search not done as numnber of entries are less
*  read table li_status with key criteria = lc_null transporting no fields. " NULL.
*  if sy-subrc eq 0.
*
*    if is_komkh-auart is not initial.
*      select single vbtyp " SD document category
*        into lv_vbtyp
*        from tvak         " Sales Document Types
*       where auart = is_komkh-auart.
*      if sy-subrc eq 0 ##needed.
** Do Nothing
*      endif. " IF sy-subrc EQ 0
*    endif. " IF is_komkh-auart IS NOT INITIAL
*
**   Read status table for criteria VBTYP and active = X
*    read table li_status assigning <lfs_status>
*                               with key criteria = lc_vbtyp
*                                        active   = abap_true
*                                        binary search.
** Check SD document category value to execute the logic for Batch Determination
*    if sy-subrc eq 0 and lv_vbtyp eq <lfs_status>-sel_low.
*
*
*    endif.
*  endif.
*
***//-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
**Binary search not done as numnber of entries are less
*  read table li_status with key criteria = lc_null transporting no fields. " NULL.
*  if sy-subrc eq 0.
***//-->>Begin of Changes - D3_CR_0272
*    sort li_status by criteria sel_low active.
**   Read status table for criteria MVGR1_GRP2 and active = X
*    read table li_status assigning <lfs_status>
*                               with key criteria = lc_mvgr2
*                                        sel_low  = is_komph-mvgr2
*                                        active   = abap_true
*                                        binary search.
*    if sy-subrc ne 0.
*      sort li_status by criteria active.
***//-->>End of Changes - D3_CR_0272
** Below Logic will work only for transaction VA01 and VA02 and other interfaces (Sales Order Entry)
***----Fetch SD Document Catagory from table TVAK
*      if is_komkh-auart is not initial.
*        select single vbtyp " SD document category
*          into lv_vbtyp
*          from tvak         " Sales Document Types
*         where auart = is_komkh-auart.
*        if sy-subrc eq 0 ##needed.
** Do Nothing
*        endif. " IF sy-subrc EQ 0
*      endif. " IF is_komkh-auart IS NOT INITIAL
**   Read status table for criteria VBTYP and active = X
*      read table li_status assigning <lfs_status>
*                                 with key criteria = lc_vbtyp
*                                          active   = abap_true
*                                          binary search.
** Check SD document category value to execute the logic for Batch Determination
*      if sy-subrc eq 0 and lv_vbtyp eq <lfs_status>-sel_low.
** <--- End of Change for D3_OTC_EDD_0360_CR_D3_0072 by SBEHERA
** ---> Begin of Delete for D3_OTC_EDD_0360_CR_D3_0072 by SBEHERA
*** Calling FM check if the Enhancement is active or not.
**    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
**      EXPORTING
**        iv_enhancement_no = lc_edd_0360 "Object ID number
**      TABLES
**        tt_enh_status     = li_status.  "Internal table for Enhancement Status
*** Non active entries are removed.
**    DELETE li_status WHERE active EQ abap_false.
**First of all criteria “NULL” in LI_STATUS is checked ,If it has Active flag as “X”.
**Binary search not done as numnber of entries are less
**    READ TABLE li_status WITH KEY criteria = lc_null TRANSPORTING NO FIELDS. " NULL.
**    IF sy-subrc EQ 0.
** <--- End of Delete for D3_OTC_EDD_0360_CR_D3_0072 by SBEHERA
***----Fetch Warehouse Number / Warehouse Complex from table T320
** Not always SLOC will be populated in the incoming data due to custom
** requirement and hence lgort could not be added in where clause
*        select lgnum " Warehouse Number / Warehouse Complex
*          into lv_lgnum
*          up to 1 rows
*          from t320  " Assignment IM Storage Location to WM Warehouse Number
*         where werks = is_komph-werks.
*        endselect.
*        if sy-subrc is initial.
***---- Check Batch Determination in EWM via Batch Attribute Replication value in table T340D
*          select single
*            batch_determ_ewm " Batch Determination in EWM via Batch Attribute Replication
*            into lv_batch_determ_ewm
*            from t340d       " WM Default Values
*            where lgnum = lv_lgnum.
** In case value equals to “X” it means Batch Determination replication is activated in EWM.
*          if sy-subrc  is initial and lv_batch_determ_ewm = lc_value_x.
**  Trigger Automatic Batch Determination:
*            if cv_replic_value = lc_value_x.
*              cv_replic_value = lc_blank.
*            endif. " IF cv_replic_value = lc_value_x
**              endif.
*          endif. " IF sy-subrc IS INITIAL AND lv_batch_determ_ewm = lc_value_x
*        endif. " IF sy-subrc IS INITIAL
*      else.
*        break ffoltyn.
***----Fetch Warehouse Number / Warehouse Complex from table T320
** Not always SLOC will be populated in the incoming data due to custom
** requirement and hence lgort could not be added in where clause
*        select lgnum " Warehouse Number / Warehouse Complex
*          into lv_lgnum
*          up to 1 rows
*          from t320  " Assignment IM Storage Location to WM Warehouse Number
*         where werks = is_komph-werks.
*        endselect.
*        if sy-subrc is initial.
***---- Check Batch Determination in EWM via Batch Attribute Replication value in table T340D
*          select single
*            batch_determ_ewm " Batch Determination in EWM via Batch Attribute Replication
*            into lv_batch_determ_ewm
*            from t340d       " WM Default Values
*            where lgnum = lv_lgnum.
** In case value equals to “X” it means Batch Determination replication is activated in EWM.
*          if sy-subrc  is initial and lv_batch_determ_ewm = lc_value_x.
*            if is_komkh-lgnum ne space.
**   Read status table for criteria MVGR1_GRP2 and active = X
*              read table li_status assigning <lfs_status>
*                                         with key criteria = lc_mvgrp2
*                                                  sel_low  = is_komph-mvgr2
*                                                  active   = abap_true
*                                                  binary search.
*              if sy-subrc eq 0.
**  Trigger Automatic Batch Determination:
*                if cv_replic_value = lc_value_x.
*                  cv_replic_value = lc_blank.
*                endif. " IF cv_replic_value = lc_value_x
*              endif.
*            endif. " IF sy-subrc IS INITIAL AND lv_batch_determ_ewm = lc_value_x
*          endif.
*        endif.
** ---> Begin of Delete for D3_OTC_EDD_0360_CR_D3_0072 by SBEHERA
**    ENDIF. " IF sy-subrc EQ 0
** <--- End of Delete for D3_OTC_EDD_0360_CR_D3_0072 by SBEHERA
** ---> Begin of Change for D3_OTC_EDD_0360_CR_D3_0072 by SBEHERA
*      endif. " IF sy-subrc EQ 0 AND lv_vbtyp EQ <lfs_status>-sel_low
*    endif. " IF sy-subrc EQ 0
** <--- End of Change for D3_OTC_EDD_0360_CR_D3_0072 by SBEHERA
*  endif. " Change for D3_OTC_EDD_0360_CR_D3_0272 by DARUMUG
**endif.
endmethod.
ENDCLASS.
