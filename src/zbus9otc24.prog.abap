************************************************************************
* Program    : ZBUS9OTC24                                              *
* Title      : Returns and  No Charge                                  *
* Developer  : Jaswinder                                               *
* Object Type: Business Object                                         *
* SAP Release: SAP ECC 6.0                                             *
*----------------------------------------------------------------------*
* WRICEF ID  : D3_OTC_WDD_0024_Workflow  for Returns                   *
*----------------------------------------------------------------------*
* DESCRIPTION: Generated Program of ZBUS9OTC24 copied from BO BUS2102  *
*----------------------------------------------------------------------*
* Modification History:                                                *
*======================================================================*
* Date        User      Transport  Description                         *
* =========== ========  ========== ====================================*
* 02-Aug-2018 U101779   E1DK937450 Initial development                 *
* 15.01.2019  U101779   E1DK937450 Defect #8160: Changes for deleting  *
*                                   existing workflow and starting the *
*                                   workflow for any changes in order  *
* 08.02.2019 U101779   E1DK940392   Defect 8327 Upate logic for order  *
*&---------------------------------------------------------------------*
* 03/27/2019 ASK    E2DK922261   Defect 8863 APproval text truncate issue *
*&---------------------------------------------------------------------*

*****           Implementation of object type ZBUS9OTC24           *****
INCLUDE <object>. " INCLUDE for Object Type Definition
begin_data object. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
" begin of private,
"   to declare private attributes remove comments and
"   insert private attributes here ...
" end of private,
  BEGIN OF key,
      salesdocument LIKE vbak-vbeln, " Sales Document
  END OF key.
end_data object. " Do not change.. DATA is generated

begin_method wmbo_get_approvers changing container.

TYPES : BEGIN OF lty_vbap,
           vbeln    TYPE   vbeln_va,            " Sales Document
           posnr    TYPE   posnr_va,            " Sales Document Item
           abgru    TYPE   abgru_va,            " Reason for rejection of quotations and sales orders
           netwr    TYPE   netwr_ap,            " Net value of the order item in document currency
           kowrr    TYPE   kowrr,               " Statistical values
           mwsbp    TYPE   mwsbp,               " Tax amount in document currency
        END OF lty_vbap,

          BEGIN OF ty_vbak,
             vbeln     TYPE vbeln_va,           " Sales Document
             auart     TYPE auart,              " Sales Document Type
             augru     TYPE augru,              " Order reason (reason for the business transaction)
             waerk     TYPE waerk,              " SD Document Currency
             vkorg     TYPE vkorg,              " Sales Organization
             vtweg     TYPE vtweg,              " Distribution Channel
             vkbur     TYPE vkbur,              " Sales Office
             kunnr     TYPE kunag,              " Sold-to party
             bukrs_vf  TYPE bukrs_vf,           " Company code to be billed
        END OF ty_vbak,

        BEGIN OF lty_t001 ,
            bukrs   TYPE  bukrs,                " Company Code
            waers   TYPE  waers,                " Currency Key
        END OF lty_t001,

      BEGIN OF lty_dispute_app,
             vkorg     TYPE     vkorg,          " Sales Organization
             vtweg     TYPE     vtweg,          " Distribution Channel
             vkbur     TYPE     vkbur,          " Sales Office
             applevel  TYPE     z_applevel,     " Approver level
             agr_name  TYPE     agr_name  ,     " Role Name
             netwr         TYPE  netwr_ak,      " Net Value of the Sales Order in Document Currency
             value_compare  TYPE z_val_compare, " Net value comparison operator
        END OF lty_dispute_app,

        BEGIN OF lty_agr_users,
             agr_name  TYPE agr_name,           " Role Name
             uname     TYPE xubname,            " User Name in User Master Record
             from_dat  TYPE agr_fdate,          " Date of validity
             to_dat    TYPE agr_tdate,          " Date of validity
        END OF lty_agr_users,

        BEGIN OF lty_kna1 ,
             kunnr    TYPE   kunnr,             " Customer Number
             name1    TYPE   name1_gp,          " Name 1
             name2    TYPE   name2_gp,          " Name 2
        END OF lty_kna1.

DATA :
    li_agr_users      TYPE STANDARD TABLE OF agr_users,       " Assignment of roles to users
    li_agr_users1     TYPE STANDARD  TABLE OF lty_agr_users,  "IT for user
    lwa_agr_users     TYPE agr_users,                         " Assignment of roles to users
    lwa_address       TYPE bapiaddr3,                         " BAPI reference structure for addresses (contact person)
    lv_bezei          TYPE bezei40,                           " Description
    lv_initiator      TYPE swp_initia,                        " Initiator of workflow instance
    lv_initiator_mail TYPE ad_smtpadr,                        " E-Mail  Address
    lwa_t001          TYPE lty_t001,                          "IT for T001
    li_dispute_app    TYPE STANDARD TABLE OF lty_dispute_app, " Credit/Debit Memo Workflow Approvers
    lwa_dispute_app   TYPE lty_dispute_app,                   " Credit/Debit Memo Workflow Approvers
    lv_level          TYPE z_applevel,                        " Approver level
    lv_cost           TYPE netwr_ak,                          " Net Value of the Sales Order in Document Currency
    lv_camt           TYPE netwr_ak,                          " Net Value of the Sales Order in Document Currency
    lv_user           TYPE xubname,                           " User Name in User Master Record
    lwa_kna1          TYPE lty_kna1,                          " IT for KNA1
    li_vbap           TYPE STANDARD TABLE OF lty_vbap ,       " IT for vbap
    lwa_vbap          TYPE lty_vbap,                          "WA for vbap
    li_agr_user1      TYPE STANDARD TABLE OF lty_agr_users,   " IT for Users
    lwa_vbak          TYPE ty_vbak,                           " IT for vbak
    li_status         TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
    lv_cust_name      TYPE char70,                            " Cust_name of type CHAR70
    lv_level1         TYPE char4,                             " Level1 of type CHAR4
    lv_famt           TYPE bapicurr_d,                        " Currency amount in BAPI interfaces
    lv_fcurr          TYPE bwaer_curv ,                       " Reference currency for currency translation
    lv_lcurr          TYPE bwaer_curv,                        " Reference currency for currency translation
    lv_lamt           TYPE bapicurr_d,                        " Currency amount in BAPI interfaces
    lx_logon          TYPE bapilogond,                        " Defect 8282
    li_return         TYPE STANDARD TABLE OF bapiret2 ,       " Return Parameter
    li_addsmtp        TYPE STANDARD TABLE OF bapiadsmtp.      " BAPI Structure for E-Mail Addresses (Bus. Address Services)

FIELD-SYMBOLS :
   <lfs_addsmtp>      TYPE bapiadsmtp,      " BAPI Structure for E-Mail Addresses (Bus. Address Services)
   <lfs_vbap>         TYPE lty_vbap,        "" IT for vbak
   <lfs_status>       TYPE zdev_enh_status, " Enhancement Status
   <lfs_dispute_app>  TYPE lty_dispute_app, " Credit/Debit Memo Workflow Approvers
   <lfs_agr_users1>   TYPE lty_agr_users.

CONSTANTS :
            lc_uid       TYPE char6         VALUE 'USERID',       " Null Criteria
            lc_null      TYPE char4         VALUE 'NULL',         " Null Criteria
            lc_wdd_0024  TYPE z_enhancement VALUE 'OTC_WDD_0024'. " Enhancement No.

swc_get_element container 'WC_LEVEL' lv_level.
swc_get_element container 'WC_COST' lv_cost.
swc_get_element container 'WC_INITIATOR' lv_initiator .

lv_level1 = lv_level.

IF lv_cost IS INITIAL.
  DO 5 TIMES.
    WAIT UP TO 1 SECONDS. "   the standard table need to be updated. Hence a wait statement .
    SELECT vbeln " Sales Document
           posnr " Sales Document Item
           abgru " Reason for rejection of quotations and sales orders
           netwr " Net value of the order item in document currency
           kowrr " Statistical values
           mwsbp " Tax amount in document currency
      FROM vbap  " Sales Document: Item Data
      INTO TABLE li_vbap
      WHERE vbeln = object-key
      AND   abgru = space
      AND   kowrr = space.

    IF sy-subrc IS INITIAL.
      CLEAR lv_level.
      EXIT.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDDO.

  LOOP AT li_vbap ASSIGNING <lfs_vbap>.
    lv_cost = lv_cost + <lfs_vbap>-netwr + <lfs_vbap>-mwsbp.
  ENDLOOP. " LOOP AT li_vbap ASSIGNING <lfs_vbap>

ENDIF. " IF lv_cost IS INITIAL

lv_level1 = lv_level1 + 1.
lv_level = lv_level1.

****   Get the header information for the memo .
SELECT SINGLE
          vbeln    " Sales Document
          auart    " Sales Document Type
          augru    " Order reason (reason for the business transaction)
          waerk    " SD Document Currency
          vkorg    " Sales Organization
          vtweg    " Distribution Channel
          vkbur    " Sales Office
          kunnr    " Sales Office
          bukrs_vf " Company code to be billed
 FROM vbak         " Sales Document: Header Data
 INTO lwa_vbak
 WHERE vbeln = object-key.

*--- sy-subrc check not needed as VBAK will always have the value

SELECT SINGLE
         bukrs " Company Code
         waers " Currency Key
  FROM t001    " Company Codes
  INTO lwa_t001
  WHERE bukrs = lwa_vbak-bukrs_vf.

* ---- Sy-subrc check is not needed as the else condition will follow if the select fails

** The currency for the company code is different.
** We need to convert amount into company code currency.
IF lwa_vbak-waerk <> lwa_t001-waers.

  lv_famt = lv_cost.
  lv_fcurr = lwa_vbak-waerk.
  lv_lcurr = lwa_t001-waers.

  CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
    EXPORTING
      client           = sy-mandt
      date             = sy-datum
      foreign_amount   = lv_famt
      foreign_currency = lv_fcurr
      local_currency   = lv_lcurr
    IMPORTING
      local_amount     = lv_lamt
    EXCEPTIONS
      no_rate_found    = 1
      overflow         = 2
      no_factors_found = 3
      no_spread_found  = 4
      derived_2_times  = 5
      OTHERS           = 6.

  IF sy-subrc IS INITIAL.
    lv_camt = lv_lamt .
  ENDIF. " IF sy-subrc IS INITIAL

ELSE. " ELSE -> IF lwa_vbak-waerk <> lwa_t001-waers
  lv_camt = lv_cost.
ENDIF. " IF lwa_vbak-waerk <> lwa_t001-waers

******** get the customer name .
SELECT SINGLE
     kunnr " Customer Number
     name1 " Name 1
     name2 " Name 2
FROM kna1  " General Data in Customer Master
INTO lwa_kna1
WHERE kunnr = lwa_vbak-kunnr
  AND loevm = space.

IF sy-subrc IS INITIAL.
  CONCATENATE lwa_kna1-name1 lwa_kna1-name2 INTO lv_cust_name SEPARATED BY space.
ENDIF. " IF sy-subrc IS INITIAL

**** get the order reason.
SELECT SINGLE bezei " Description
FROM tvaut          " Sales Documents: Order Reasons: Texts
  INTO lv_bezei
WHERE spras = sy-langu
AND   augru = lwa_vbak-augru.
*---- it's a independenet select for order reason which is not mandator, so the sy-subrc check is not needed

****  Fetch the role information from the table
SELECT vkorg            " Sales Organization
       vtweg            " Distribution Channel
       vkbur            " Sales Office
       applevel         " Approver level
       agr_name         " Role Name
       netwr            " Net Value of the Sales Order in Document Currency
       value_compare    " Net value comparison operator
  FROM zotc_dispute_app " Credit/Debit Memo Workflow Approvers
  INTO  TABLE li_dispute_app
  WHERE vkorg = lwa_vbak-vkorg
  AND   vtweg = lwa_vbak-vtweg
  AND   vkbur = lwa_vbak-vkbur
  AND   applevel = lv_level.
IF sy-subrc IS INITIAL.
  SORT li_dispute_app BY applevel.

  DELETE li_dispute_app WHERE netwr GT  lv_camt . "lv_cost.
  SORT li_dispute_app BY applevel.
  READ TABLE li_dispute_app ASSIGNING <lfs_dispute_app> INDEX 1.
  IF sy-subrc IS INITIAL.
    DELETE li_dispute_app WHERE applevel <> <lfs_dispute_app>-applevel.
  ENDIF. " IF sy-subrc IS INITIAL

  IF li_dispute_app IS NOT INITIAL.
*  Fetch the appropriate users for the role.
    SELECT agr_name " Role Name
           uname    " User Name in User Master Record
           from_dat " Date of validity
           to_dat   " Date of validity
  FROM agr_users    " Assignment of roles to users
  INTO TABLE li_agr_users1
  WHERE agr_name =  <lfs_dispute_app>-agr_name.
*  No roles are maintained for the level.
    IF sy-subrc IS INITIAL.

      SORT li_agr_users1 BY agr_name uname from_dat to_dat.
      DELETE li_agr_users1 WHERE from_dat > sy-datum.
      DELETE li_agr_users1 WHERE to_dat < sy-datum.

    ELSE. " ELSE -> IF sy-subrc IS INITIAL
      lv_level = '9999'.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_dispute_app IS NOT INITIAL
ELSE. " ELSE -> IF sy-subrc IS INITIAL
  lv_level = '9999'.
***   if no users maintained then mail should be sent to the admin.
ENDIF. " IF sy-subrc IS INITIAL

IF li_dispute_app[] IS INITIAL OR li_agr_users1[] IS INITIAL .

  lv_level = '9999'.

  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_wdd_0024
    TABLES
      tt_enh_status     = li_status.

  DELETE li_status WHERE active = space.

  READ TABLE li_status WITH KEY criteria = lc_null
                                active   = abap_true
                                TRANSPORTING NO FIELDS.

  IF sy-subrc IS INITIAL.

    READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_uid
                                                         active   = abap_true.

    IF sy-subrc IS INITIAL.
      REFRESH li_addsmtp.
      lv_user = <lfs_status>-sel_low.

      CALL FUNCTION 'BAPI_USER_GET_DETAIL'
        EXPORTING
          username  = lv_user
        IMPORTING
          logondata = lx_logon " Defect 8282
        TABLES
          return    = li_return
          addsmtp   = li_addsmtp.
      IF lx_logon-ustyp NE 'B'. " Defect 8282 IF not System User
        READ TABLE li_addsmtp ASSIGNING <lfs_addsmtp> INDEX 1.
        IF sy-subrc IS INITIAL.
          IF <lfs_addsmtp>-e_mail IS NOT INITIAL. " Defect 8282
            swc_set_element container 'WC_ADMIN' <lfs_addsmtp>-e_mail.
          ENDIF. " IF <lfs_addsmtp>-e_mail IS NOT INITIAL
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF lx_logon-ustyp NE 'B'
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL
ENDIF. " IF li_dispute_app[] IS INITIAL OR li_agr_users1[] IS INITIAL

LOOP AT li_agr_users1 ASSIGNING <lfs_agr_users1>.
  lwa_agr_users-agr_name =   <lfs_agr_users1>-agr_name.
  lwa_agr_users-uname  =  <lfs_agr_users1>-uname.
  lwa_agr_users-from_dat = <lfs_agr_users1>-from_dat.
  lwa_agr_users-to_dat =  <lfs_agr_users1>-to_dat.
  APPEND lwa_agr_users TO li_agr_users.
  CLEAR lwa_agr_users.
ENDLOOP. " LOOP AT li_agr_users1 ASSIGNING <lfs_agr_users1>
* Get the mail id of the initiator .
CLEAR lv_user.
lv_user = lv_initiator+2(12).

IF lv_user IS NOT INITIAL.
  CLEAR lx_logon. " Defect 8282
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username  = lv_user
    IMPORTING
      logondata = lx_logon " Defect 8282
      address   = lwa_address
    TABLES
      return    = li_return
      addsmtp   = li_addsmtp.
  IF lx_logon-ustyp NE 'B'. " Defect 8282 IF not System User
    READ TABLE li_addsmtp ASSIGNING <lfs_addsmtp> INDEX 1.
    IF sy-subrc = 0. " Defect 8282
      IF <lfs_addsmtp>-e_mail IS NOT INITIAL. " Defect 8282
        swc_set_element container 'WC_IMAIL' <lfs_addsmtp>-e_mail.
      ENDIF. " IF <lfs_addsmtp>-e_mail IS NOT INITIAL
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF lx_logon-ustyp NE 'B'
ENDIF. " IF lv_user IS NOT INITIAL

swc_set_element container 'WC_CREATOR' lwa_address-fullname.
swc_set_element container 'WC_OREASON' lv_bezei.
swc_set_element container 'WC_LEVEL' lv_level  .
swc_set_table container   'WC_APPROVERS' li_agr_users.
swc_set_element container 'WC_MEMO_COST' lv_cost.
swc_set_element container 'WC_CUST_NAME' lv_cust_name.
swc_set_element container 'WC_TTYPE' lwa_vbak-auart.

end_method.

begin_method wmbo_update_status changing container.

TYPES : BEGIN OF lty_vbak ,
          vbeln    TYPE vbeln_va, " Sales Document
          objnr    TYPE objko,    " Object number at header level
        END OF lty_vbak ,

       BEGIN OF ty_vbap,
           vbeln   TYPE vbeln_va, " Sales Document
           posnr   TYPE posnr_va, " Sales Document Item
        END OF ty_vbap.

DATA:
   lv_status_indicator TYPE vbtyp_v,                      " Document category of preceding SD document
   lwa_vbak            TYPE lty_vbak,                     "" IT for VBAK
   lit_order_item_in   TYPE STANDARD TABLE OF bapisditm,  " Communication Fields: Sales and Distribution Document Item
   lwa_order_item_in   TYPE bapisditm,                    " Communication Fields: Sales and Distribution Document Item
   lit_order_item_inx  TYPE STANDARD TABLE OF bapisditmx, " Communication Fields: Sales and Distribution Document Item
   lwa_order_item_inx  TYPE bapisditmx,                   " Communication Fields: Sales and Distribution Document Item
   lv_user_status      TYPE j_status,                     " Object status
   lv_user_status1     TYPE j_status,                     " Object status
   lv_objnr            TYPE j_objnr,                      " Object number
  lwa_order_header_inx TYPE bapisdh1x,                    " Checkbox List: SD Order Header
   lv_stonr            TYPE j_stonr,                      " Status Order Number
   lv_level            TYPE z_applevel,                   " Approver level
   li_vbap             TYPE STANDARD TABLE OF vbap,       " Sales Document: Item Data
   lwa_vbap            TYPE vbap,                         " Sales Document: Item Data
   wa_order_header_in  TYPE bapisdh1,                     " Communication Fields: SD Order Header
   lit_return_head     TYPE STANDARD TABLE OF bapiret2 .  " Return Parameter

FIELD-SYMBOLS :
       <lfs_return_head> TYPE bapiret2, " Return Parameter
       <lfs_vbap>        TYPE ty_vbap.  " FS for VBAP

CONSTANTS:
        lc_updateflag TYPE char1 VALUE 'U'. " Update flag of type CHAR1


swc_get_element container 'WC_INDICATOR' lv_status_indicator.

IF lv_status_indicator EQ 'A'.
  lv_user_status = 'E0003'.
ELSEIF lv_status_indicator EQ 'C'. " Set the status approval in process.
  lv_user_status = 'E0002'.
ELSEIF lv_status_indicator EQ 'B'.
  lv_user_status = 'E0001'.
ENDIF. " IF lv_status_indicator EQ 'A'
*Get the object number for the memo for which the status is to be updated.

SELECT SINGLE
       vbeln " Sales Document
       objnr " Object number at header level
  FROM vbak  " Sales Document: Header Data
  INTO lwa_vbak
  WHERE vbeln = object-key.

*--- sy-subrc check not needed as VBAK will always have the value
lv_objnr = lwa_vbak-objnr .

**** Updating the required status .
CALL FUNCTION 'STATUS_CHANGE_EXTERN'
  EXPORTING
    objnr               = lv_objnr
    user_status         = lv_user_status
  IMPORTING
    stonr               = lv_stonr
  EXCEPTIONS
    object_not_found    = 1
    status_inconsistent = 2
    status_not_allowed  = 3
    OTHERS              = 4.

IF sy-subrc IS INITIAL.

  IF lv_stonr IS NOT INITIAL.
***    running the FM for commiting the status change.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' .
    IF  lv_status_indicator <> 'C'.
      lv_level = '9999'.
      swc_set_element container 'WC_LEVEL' lv_level.
    ENDIF. " IF lv_status_indicator <> 'C'
  ELSE. " ELSE -> IF lv_stonr IS NOT INITIAL
    ROLLBACK WORK.
  ENDIF. " IF lv_stonr IS NOT INITIAL
ENDIF. " IF sy-subrc IS INITIAL

end_method.

begin_method wmbo_send_notification changing container.

TYPES : BEGIN OF lty_vbap,
           vbeln    TYPE   vbeln_va, " Sales Document
           posnr    TYPE   posnr_va, " Sales Document Item
           abgru    TYPE   abgru_va, " Reason for rejection of quotations and sales orders
           netwr    TYPE   netwr_ap, " Net value of the order item in document currency
           waerk    TYPE   waerk,    " SD Document Currency
           kowrr    TYPE   kowrr,    " Statistical values
           mwsbp    TYPE   mwsbp,    " Tax amount in document currency
        END OF lty_vbap,

        BEGIN OF lty_vbak,
            vbeln  TYPE vbeln_va,    " Sales Document
            kunnr  TYPE kunag,       " Sold-to party
        END OF lty_vbak,

       BEGIN OF lty_kna1,
          kunnr    TYPE kunnr,       " Customer Number
          ort01    TYPE ort01_gp,    " City
          pstlz    TYPE pstlz,       " Postal Code
        END OF lty_kna1.

DATA :
    li_approvers       TYPE STANDARD TABLE OF agr_users,        " Assignment of roles to users
    lwa_approvers      TYPE agr_users,                          " Assignment of roles to users
    li_addsmtp         TYPE STANDARD TABLE OF bapiadsmtp,       " BAPI Structure for E-Mail Addresses (Bus. Address Services)
    lwa_addsmtp        TYPE bapiadsmtp,                         " BAPI Structure for E-Mail Addresses (Bus. Address Services)
    lv_subject         TYPE so_obj_des,                         " Short description of contents
    li_return          TYPE STANDARD TABLE OF bapiret2,         " Return Parameter
    lwa_body           TYPE soli,                               " SAPoffice: line, length 255
    li_body            TYPE bcsy_text ,                         " IT for  bcsy_text
    li_recipients_temp TYPE STANDARD TABLE OF zdev_receipients, " InfoUser (SEM-BIC)
    lv_curr            TYPE char5,                              " Curr of type CHAR5
    li_recipient       TYPE TABLE OF zdev_receipients ,         " InfoUser (SEM-BIC)
    lwa_recipient      TYPE zdev_receipients,                   " InfoUser (SEM-BIC)
    lv_result          TYPE boolean,                            " Boolean Variable (X=True, -=False, Space=Unknown)
    lv_username        TYPE bapibname-bapibname,                " User Name in User Master Record
    li_sub_txt         TYPE STANDARD TABLE OF tline,            " SAPscript: Text Lines
    lwa_sub_txt        TYPE tline,                              " SAPscript: Text Lines
    li_body_txt        TYPE STANDARD TABLE OF tline,            " SAPscript: Text Lines
    lv_creator         TYPE ad_namtext,                         " Full Name of Person
    lv_oreason         TYPE bezei40,                            " Description
    lv_memo_cost       TYPE netwr_ak,                           " Net Value of the Sales Order in Document Currency
    lv_cost_char       TYPE char20,                             " Cost_char of type CHAR20
    lv_cust_name       TYPE ad_namtext,                         " Full Name of Person
    lwa_kna1           TYPE lty_kna1,                           " WA for KNA1
    lv_mtype           TYPE char10,                             " Type declaration
    li_vbap            TYPE STANDARD TABLE OF lty_vbap,         " VPAP type IT
    lv_ttype           TYPE auart,                              " Order type
    lx_logon          TYPE bapilogond,                          " Defect 8282
    lwa_vbak           TYPE lty_vbak.                           " WA for VBAK

FIELD-SYMBOLS : <lfs_vbap>     TYPE lty_vbap,  " FS for VBAP
               <lfs_approvers> TYPE agr_users. " Assignment of roles to users

CONSTANTS:
   lc_object  TYPE   tdobject VALUE 'TEXT',                    " Texts: Application Object
   lc_id      TYPE   tdid     VALUE 'ST',                      " Text ID
   lc_app_sub TYPE   tdobname VALUE 'ZOTC_WDD_0024_NOTIF_SUB', " Name
   lc_app_txt TYPE   tdobname VALUE 'ZOTC_WDD_0024_NOTIF_TXT'. " Name

swc_get_element container 'WC_APPROVERS' li_approvers.
swc_get_element container 'WC_CREATOR'   lv_creator.
swc_get_element container 'WC_OREASON'   lv_oreason.
swc_get_element container 'WC_MEMO_COST' lv_memo_cost.
swc_get_element container 'WC_CUST_NAME' lv_cust_name.
swc_get_element container 'WC_TTYPE'     lv_ttype.

* fetch the sold to party from VBAK ,
* fetch the customer details from table kna1.

SELECT SINGLE  vbeln " Sales Document
               kunnr " Sold-to party
  FROM vbak          " Sales Document: Header Data
  INTO lwa_vbak
  WHERE vbeln = object-key.

IF sy-subrc IS INITIAL.
  SELECT SINGLE kunnr " Customer Number
          ort01       " City
          pstlz       " Postal Code
    FROM kna1         " General Data in Customer Master
    INTO lwa_kna1
    WHERE kunnr = lwa_vbak-kunnr
          AND loevm EQ space.
ENDIF . " IF sy-subrc IS INITIAL

*--- sy-subrc check not needed, it's an independent select and the fetched fields are not mandatory

SELECT vbeln " Sales Document
       posnr " Sales Document Item
       abgru " Reason for rejection of quotations and sales orders
       netwr " Net value of the order item in document currency
       waerk " SD Document Currency
       kowrr " Statistical values
       mwsbp " Tax amount in document currency
  FROM vbap  " Sales Document: Item Data
  INTO TABLE li_vbap
  WHERE vbeln = object-key
  AND   abgru = space
  AND   kowrr = space.

IF sy-subrc IS INITIAL.

  LOOP AT li_vbap ASSIGNING <lfs_vbap>.
    lv_memo_cost = lv_memo_cost + <lfs_vbap>-netwr + <lfs_vbap>-mwsbp.
    lv_curr = <lfs_vbap>-waerk.
  ENDLOOP. " LOOP AT li_vbap ASSIGNING <lfs_vbap>

ENDIF. " IF sy-subrc IS INITIAL

lv_cost_char = lv_memo_cost.
IF <lfs_vbap> IS ASSIGNED .
  lv_curr = <lfs_vbap>-waerk.
ENDIF. " IF <lfs_vbap> IS ASSIGNED
****   Fetch the subject
*Text is maintained in EN language only .
CALL FUNCTION 'READ_TEXT'
  EXPORTING
    id                      = lc_id
    language                = sy-langu
    name                    = lc_app_sub
    object                  = lc_object
  TABLES
    lines                   = li_sub_txt
  EXCEPTIONS
    id                      = 1
    language                = 2
    name                    = 3
    not_found               = 4
    object                  = 5
    reference_check         = 6
    wrong_access_to_archive = 7
    OTHERS                  = 8.

*****   Fetch the mail text.
*Text is maintained in EN language only .
CALL FUNCTION 'READ_TEXT'
  EXPORTING
    id                      = lc_id
    language                = sy-langu
    name                    = lc_app_txt
    object                  = lc_object
  TABLES
    lines                   = li_body_txt
  EXCEPTIONS
    id                      = 1
    language                = 2
    name                    = 3
    not_found               = 4
    object                  = 5
    reference_check         = 6
    wrong_access_to_archive = 7
    OTHERS                  = 8.

CLEAR : lv_subject.

LOOP AT li_sub_txt INTO lwa_sub_txt.
  REPLACE 'xDOC_NOx' IN lwa_sub_txt-tdline WITH object-key.
  lv_subject = lwa_sub_txt-tdline .
  EXIT.
ENDLOOP. " LOOP AT li_sub_txt INTO lwa_sub_txt

CLEAR : li_body[].
LOOP AT li_body_txt INTO lwa_sub_txt.

  REPLACE 'xDOC_NOx'    IN lwa_sub_txt-tdline WITH object-key.
  REPLACE 'xCUST_NAMEx' IN lwa_sub_txt-tdline WITH  lv_cust_name.
  REPLACE 'xNET_AMTx'   IN lwa_sub_txt-tdline WITH  lv_cost_char.
  REPLACE 'xCURx' IN lwa_sub_txt-tdline WITH lv_curr.
  REPLACE 'xOREASONx'   IN lwa_sub_txt-tdline WITH  lv_oreason.
  REPLACE 'xTTYPEx'     IN lwa_sub_txt-tdline WITH lv_ttype.
  REPLACE 'xCREATORx'   IN lwa_sub_txt-tdline WITH lv_creator.
*  Update the customer details in the mail text.
  REPLACE 'xKUNNRx' IN lwa_sub_txt-tdline WITH lwa_vbak-kunnr.
  REPLACE 'xMTYPEx' IN lwa_sub_txt-tdline WITH lv_mtype.
  REPLACE 'xCITYx'  IN lwa_sub_txt-tdline WITH lwa_kna1-ort01.
  REPLACE 'xPOSTx' IN lwa_sub_txt-tdline WITH lwa_kna1-pstlz.
  REPLACE '<(>' IN lwa_sub_txt-tdline WITH space.
  REPLACE '<)>' IN lwa_sub_txt-tdline WITH space.
  lwa_body-line = lwa_sub_txt-tdline.
  APPEND lwa_body TO li_body.
  CLEAR lwa_body.
ENDLOOP. " LOOP AT li_body_txt INTO lwa_sub_txt

LOOP AT li_approvers ASSIGNING <lfs_approvers>.

  lv_username = <lfs_approvers>-uname.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username  = lv_username
    IMPORTING
      logondata = lx_logon " Defect 8282
    TABLES
      return    = li_return
      addsmtp   = li_addsmtp.
  IF lx_logon-ustyp NE 'B'. " Defect 8282 IF not System User
    READ TABLE li_addsmtp INTO lwa_addsmtp INDEX 1 .
    IF sy-subrc IS INITIAL.
      CLEAR lwa_recipient .
      lwa_recipient-iusrid = lv_username .
      lwa_recipient-email = lwa_addsmtp-e_mail .

*  sending mail to the required approvers .
      CALL FUNCTION 'ZDEV_SEND_EMAIL'
        EXPORTING
          subject        = lv_subject
          message_body   = li_body
          sender_uid     = sy-uname
          recipient_mail = lwa_recipient-email
        IMPORTING
          result         = lv_result
        TABLES
          recipients     = li_recipients_temp.

    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF lx_logon-ustyp NE 'B'
ENDLOOP. " LOOP AT li_approvers ASSIGNING <lfs_approvers>

end_method.

begin_method wmbo_update_comments changing container.

DATA :
    li_subcontainer             TYPE STANDARD TABLE OF swr_cont,   " Container (name-value pairs)
    li_simple_container         TYPE STANDARD TABLE OF swr_cont,   " Container (name-value pairs)
    li_message_lines            TYPE STANDARD TABLE OF swr_messag, " Workflow Interfaces: Messages
    li_message_struct           TYPE STANDARD TABLE OF swr_mstruc, " Workflow interfaces: Message structure
    li_subcontainer_bor_objects TYPE STANDARD TABLE OF swr_cont,   " Container (name-value pairs)
    lv_workid                   TYPE sww_wiid,                     " Work item ID
    lv_document_id              TYPE so_entryid,                   " Folder Entry ID (Obj+Fol+Forwarder Name)
    li_object_content           TYPE STANDARD TABLE OF solisti1,   " SAPoffice: Single List with Column Length 255
    lv_lang                     TYPE spras,                        " Language Key
    lv_name                     TYPE tdobname,                     " Name
    li_lines                    TYPE STANDARD TABLE OF tline,      " SAPscript: Text Lines
    li_lines_save               TYPE STANDARD TABLE OF tline,      " SAPscript: Text Lines
    lv_date                     TYPE char10,                       " Field of type DATS
    lwa_lines                   TYPE tline,                        " SAPscript: Text Lines
    lv_return_code              TYPE sy-subrc,                     " Return Value of ABAP Statements
    lv_app_userid               TYPE xubname,                      " User Name in User Master Record
    lv_result                   TYPE swd_retur_,                   " Workflow Definition: Container Expression for Step Result
    lv_action                   TYPE char10,                       " Action of type CHAR10
    lv_agent                    TYPE swp_agent,                    " Agent
    lwa_header                  TYPE thead,                        " SAPscript: Text Header
    lv_function                 TYPE char1,                        " Function of type CHAR1
    lv_time                     TYPE char8,                        " Time of type CHAR8
    lv_string                   TYPE string ,                      " String variable
    lv_user                     TYPE xubname,                      " User Name in User Master Record
    li_return                   TYPE STANDARD TABLE OF bapiret2,   " Return Parameter
    lwa_address                 TYPE bapiaddr3.                    " BAPI reference structure for addresses (contact person)

FIELD-SYMBOLS :
    <lfs_subcontainer>   TYPE swr_cont, " Container (name-value pairs)
    <lfs_object_content> TYPE solisti1. " SAPoffice: Single List with Column Length 255

CONSTANTS :
   lc_id      TYPE tdid     VALUE 'Z015', " Text ID
   lc_colon   TYPE char1    VALUE ':' ,   " Colon of type CHAR1
   lc_object  TYPE tdobject VALUE 'VBBK'. " Texts: Application Object

swc_get_element container 'WC_WORKITEM_ID' lv_workid.
swc_get_element container 'WC_APP_USERID' lv_app_userid.
swc_get_element container 'WC_RESULT' lv_result.
swc_get_element container 'WC_ACTUAL_AGENT' lv_agent .

lv_app_userid = lv_agent+2(12).

* Get the user name of the agent and display it in the comments.
lv_user = lv_app_userid .

DATA LV_flag type flag.


CALL FUNCTION 'BAPI_USER_GET_DETAIL'
  EXPORTING
    username = lv_user
  IMPORTING
    address  = lwa_address
  TABLES
    return   = li_return.

IF lv_result = '0001'.
  lv_action = text-003.
ELSEIF lv_result = '0002'.
*  lv_action = text-004.
  lv_action = text-005.
*ELSEIF lv_result = '0003'.
*  lv_action = text-005.
ENDIF. " IF lv_result = '0001'

IF lv_workid IS NOT INITIAL.
*** This FM returns the Workitem attachment details.
  CALL FUNCTION 'SAP_WAPI_READ_CONTAINER'
    EXPORTING
      workitem_id              = lv_workid
    IMPORTING
      return_code              = lv_return_code
    TABLES
      simple_container         = li_simple_container
      message_lines            = li_message_lines
      message_struct           = li_message_struct
      subcontainer_bor_objects = li_subcontainer_bor_objects
      subcontainer_all_objects = li_subcontainer.

  LOOP AT li_subcontainer ASSIGNING <lfs_subcontainer>
                                 WHERE element = '_ATTACH_OBJECTS'.
    lv_document_id = <lfs_subcontainer>-value.
  ENDLOOP. " LOOP AT li_subcontainer ASSIGNING <lfs_subcontainer>

  IF lv_document_id IS NOT INITIAL.

*  Get the contents of the attachment.
    CALL FUNCTION 'SO_DOCUMENT_READ_API1'
      EXPORTING
        document_id    = lv_document_id
      TABLES
        object_content = li_object_content. "   text in the workitem .
  ENDIF. " IF lv_document_id IS NOT INITIAL

*** Read the text saved .
** Reading the previously saved text.
  lv_name = object-key.
  lv_lang = sy-langu.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id
      language                = lv_lang
      name                    = lv_name
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  WRITE sy-datum TO lv_date.
* Set the system date to lv_time.
  WRITE sy-uzeit TO lv_time.

  CONCATENATE lv_agent+2(12) lwa_address-fullname lv_date lv_time  lv_action lc_colon INTO lv_string SEPARATED BY space.

  lwa_lines-tdline = lv_string.
  APPEND lwa_lines TO li_lines_save.
  CLEAR lwa_lines.
***************  New comment .

  LOOP AT  li_object_content ASSIGNING <lfs_object_content>.
*    lwa_lines-tdline = <lfs_object_content>-line+5(250).  " Defcet 8863
    lwa_lines-tdline = <lfs_object_content>-line+0(250).  " Defcet 8863
    APPEND lwa_lines TO li_lines_save.
    CLEAR lwa_lines.
  ENDLOOP. " LOOP AT li_object_content ASSIGNING <lfs_object_content>

*  Appending a blank line in the text internal table.
  CLEAR lwa_lines.
  lwa_lines = cl_abap_char_utilities=>newline.
  APPEND lwa_lines TO li_lines_save.

**** Appending old comments.
  LOOP AT li_lines INTO lwa_lines .
    APPEND lwa_lines TO li_lines_save.
  ENDLOOP. " LOOP AT li_lines INTO lwa_lines

  lwa_header-tdobject  = lc_object.
  lwa_header-tdname    = lv_name .
  lwa_header-tdid      = lc_id.
  lwa_header-tdspras   = sy-langu.

***  Saving the text.
  IF li_lines_save IS NOT INITIAL.
    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        header          = lwa_header
        savemode_direct = abap_true
      IMPORTING
        function        = lv_function
      TABLES
        lines           = li_lines_save
      EXCEPTIONS
        id              = 1
        language        = 2
        name            = 3
        object          = 4
        OTHERS          = 5.
  ENDIF. " IF li_lines_save IS NOT INITIAL
ENDIF. " IF lv_workid IS NOT INITIAL

swc_set_element container 'WC_APP_USERID' lv_app_userid.

end_method.

begin_method wmbo_save_ord_val changing container.

*<--- Begin of Delete for Defect #8327 on 08.02.2019 by U101779

*CONSTANTS:
*  lc_write TYPE enqmode VALUE 'E',              " Lock mode
*  lc_tab   TYPE tabname VALUE 'ZOTC_ORDER_VAL'. " Table Name
*
*DATA:
*      lv_netwr     TYPE netwr_ak,                         " Net Value of the Sales Order in Document Currency
*      lv_lines     TYPE i,                                " Lines of type Integers
*      lv_lock      TYPE flag,                             " General Flag
*      lv_ctr       TYPE z_ctr,                            " Counter for the Sales order order
*      lv_prev      TYPE sydatum,                          " Current Date of Application Server
*      li_cur_order TYPE STANDARD TABLE OF zotc_order_val, " Net Value history of the Sales Order
*      lwa_cur_ord  TYPE zotc_order_val,                   " Net Value history of the Sales Order
*      lwa_temp     TYPE zotc_order_val,                   " Net Value history of the Sales Order
*      li_order_val TYPE STANDARD TABLE OF zotc_order_val. " Net Value history of the Sales Order
*
*CLEAR:
*      lv_netwr,
*      lv_ctr,
*      lwa_temp,
*      lv_lines,
*      lv_lock,
*      lv_prev,
*      lwa_cur_ord.
*
**---- Get the VBAK data
*
*SELECT SINGLE netwr " Net Value of the Sales Order in Document Currency
*  FROM vbak         " Sales Document: Header Data
*  INTO lv_netwr
*  WHERE vbeln = object-key.
*
*IF sy-subrc IS INITIAL.
*
**----Fetch all records from table ZOTC_ORDER_VAL
*  SELECT * FROM
*    zotc_order_val
*    INTO TABLE li_order_val.
*
*  IF sy-subrc IS INITIAL.
*
*    li_cur_order = li_order_val.
*    DESCRIBE TABLE li_order_val LINES lv_lines.
*
**----delete enties when it exceeds 5000 i.e clear the history
*    IF lv_lines > 5000.
**---- delete the orders created 10 days prior to current date
*      lv_prev = sy-datum - 10.
*
*      DO 5 TIMES.
*
*        WAIT UP TO 1 SECONDS.
*        CALL FUNCTION 'ENQUEUE_E_TABLE'
*          EXPORTING
*            mode_rstable   = lc_write
*            tabname        = lc_tab
*          EXCEPTIONS
*            foreign_lock   = 1
*            system_failure = 2
*            OTHERS         = 3.
*
*        IF sy-subrc IS INITIAL.
**--- exit the loop if the lock is succesful
*          lv_lock = abap_true.
*          EXIT.
*        ENDIF. " IF sy-subrc IS INITIAL
*
*      ENDDO.
*
*      IF lv_lock = abap_true.
*
*        DELETE li_order_val WHERE erdat GT lv_prev.
*        DELETE zotc_order_val FROM TABLE li_order_val.
*
*        CALL FUNCTION 'DEQUEUE_E_TABLE'
*          EXPORTING
*            mode_rstable = lc_write
*            tabname      = lc_tab.
*
*      ENDIF. " IF lv_lock = abap_true
*
*    ENDIF. " IF lv_lines > 5000
*
*    SORT li_cur_order BY vbeln.
*    DELETE  li_cur_order WHERE vbeln NE object-key.
*
*    IF li_cur_order IS NOT INITIAL.
*
*      SORT li_cur_order BY counter DESCENDING.
*      READ TABLE li_cur_order INTO lwa_temp INDEX 1.
*
*      lwa_cur_ord-vbeln       = object-key.
*      lwa_cur_ord-counter     = lwa_temp-counter + 1.
*      lwa_cur_ord-erdat       = sy-datum.
*      lwa_cur_ord-netwr       = lv_netwr.
*
*    ELSE. " ELSE -> IF li_cur_order IS NOT INITIAL
*
*      lwa_cur_ord-vbeln       = object-key.
*      lwa_cur_ord-counter     = 1.
*      lwa_cur_ord-erdat       = sy-datum.
*      lwa_cur_ord-netwr       = lv_netwr.
*
*    ENDIF. " IF li_cur_order IS NOT INITIAL
*
*  ELSE. " ELSE -> IF sy-subrc IS INITIAL
*
*    lwa_cur_ord-vbeln       = object-key.
*    lwa_cur_ord-counter     = 1.
*    lwa_cur_ord-erdat       = sy-datum.
*    lwa_cur_ord-netwr       = lv_netwr.
*
*  ENDIF. " IF sy-subrc IS INITIAL
*
**---- Lock is not required as it's an insertion of 1 new record.
*  INSERT zotc_order_val FROM lwa_cur_ord.
*
*ENDIF. " IF sy-subrc IS INITIAL

*<--- End   of Delete for Defect #8327 on 08.02.2019 by U101779

end_method.

begin_method wmbo_check_flag changing container.

* ---> Begin of Insert for D3_OTC_WDD_0024  Defect # 8160  by U101779

*CONSTANTS:
*      lc_objtype         TYPE swo_objtyp VALUE 'ZBUS9OTC24', " Object type
*      lc_terminate_event TYPE swo_event VALUE 'TERMINATE'.   " Event
*
*DATA:
*      lv_key     TYPE vbeln,                            " Sales and Distribution Document Number
*      li_orders  TYPE STANDARD TABLE OF zotc_order_val, " Net Value history of the Sales Order
*      lwa_orders TYPE zotc_order_val,                   " Net Value history of the Sales Order
*      lv_auart   TYPE auart,                            " Sales Document Type
*      lv_netwr   TYPE netwr_ak,                         " Net Value of the Sales Order in Document Currency
*      lv_flag    TYPE flag,                             " General Flag
*      lv_objkey  TYPE swo_typeid.                       " Object key
*
*CLEAR:
*      lv_flag,
*      lv_auart,
*      lv_netwr,
*      lv_key,
*      lv_objkey,
*      lwa_orders,
*      li_orders[].
*
*lv_key = object-key.
*
*CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*  EXPORTING
*    input  = lv_key
*  IMPORTING
*    output = lv_key.
*
**---- Select order type from VBAK
*SELECT SINGLE auart " Sales Document Type
*              netwr " Net Value of the Sales Order in Document Currency
*  FROM vbak         " Sales Document: Header Data
*  INTO (lv_auart,lv_netwr)
*  WHERE vbeln = lv_key.
*
*IF sy-subrc IS INITIAL.
*
**---- Get the latest order change value
*  SELECT *
*    FROM zotc_order_val " Net Value history of the Sales Order
*    INTO TABLE li_orders
*    WHERE vbeln = lv_key.
*
*  IF sy-subrc IS INITIAL.
*
*    SORT li_orders BY counter DESCENDING.
*    READ TABLE li_orders INTO lwa_orders INDEX 1.
*
*    IF lwa_orders-netwr NE lv_netwr.
*
*      lv_flag = abap_true.
*      lv_objkey  = object-key.
*      CALL FUNCTION 'SAP_WAPI_CREATE_EVENT'
*        EXPORTING
*          object_type = lc_objtype
*          object_key  = lv_objkey
*          event       = lc_terminate_event.
*
*    ENDIF. " IF lwa_orders-netwr NE lv_netwr
*
*  ENDIF. " IF sy-subrc IS INITIAL
*
*ENDIF. " IF sy-subrc IS INITIAL

* <--- End   of Insert for D3_OTC_WDD_0024  Defect # 8160 by U101779

end_method.
