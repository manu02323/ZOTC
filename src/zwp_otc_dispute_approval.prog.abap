*****           Implementation of object type ZWOOTC0013           *****
INCLUDE <object>. " INCLUDE for Object Type Definition
BEGIN_DATA OBJECT. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
" begin of private,
"   to declare private attributes remove comments and
"   insert private attributes here ...
" end of private,
  BEGIN OF KEY,
      SALESDOCUMENT LIKE VBAK-VBELN,
  END OF KEY,
      _VBAK LIKE VBAK.
END_DATA OBJECT. " Do not change.. DATA is generated

TABLES vbak. " Sales Document: Header Data
*
get_table_property vbak.
DATA subrc LIKE sy-subrc. " Return Value of ABAP Statements
* Fill TABLES VBAK to enable Object Manager Access to Table Properties
PERFORM select_table_vbak USING subrc.
IF subrc NE 0.
  exit_object_not_found.
ENDIF. " IF subrc NE 0
end_property.
*
* Use Form also for other(virtual) Properties to fill TABLES VBAK
FORM select_table_vbak USING subrc LIKE sy-subrc. " Return Value of ABAP Statements
* Select single * from VBAK, if OBJECT-_VBAK is initial
  IF object-_vbak-mandt IS INITIAL
  AND object-_vbak-vbeln IS INITIAL.
    SELECT SINGLE * FROM vbak CLIENT SPECIFIED
        WHERE mandt = sy-mandt
        AND vbeln = object-key-salesdocument.
    subrc = sy-subrc.
    IF subrc NE 0. EXIT. ENDIF.
    object-_vbak = vbak.
  ELSE. " ELSE -> IF subrc NE 0 EXIT ENDIF
    subrc = 0.
    vbak = object-_vbak.
  ENDIF. " IF subrc NE 0 EXIT ENDIF
ENDFORM. "SELECT_TABLE_VBAK



************************************************************************
* PROGRAM    :ZWP_OTC_DISPUTE_APPROVAL                                 *
* TITLE      :D2_OTC_WDD_0013                                          *
* DEVELOPER  :  Vinita Choudhary                                       *
* OBJECT TYPE: Business object                                         *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID: D2_OTC_WDD_0013                                           *
*----------------------------------------------------------------------*
* DESCRIPTION:
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER     TRANSPORT  DESCRIPTION                         *
* ===========  ======== ========== ====================================*
* 01.12.2014   VCHOUDH   E2DK907287  Business object
* 20.01.2015   PMISHRA   E2DK907287  Defect 3080
* 18.02.2015   PMISHRA   E2DK907287  Defect 3739
* 15.07.2015   DDWIVED   E2DK913984  Defect 8668
*&---------------------------------------------------------------------*



*-------------------------------------------------*
*  Get the list of valid approvers .
*  This method helps to fetch the valid approvers for the memo.
*-------------------------------------------------*
begin_method wmbo_get_approvers changing container.


TYPES : BEGIN OF lty_vbap,
           vbeln    TYPE   vbeln_va, " Sales Document
           posnr    TYPE   posnr_va, " Sales Document Item
           abgru    TYPE   abgru_va, " Reason for rejection of quotations and sales orders
           netwr    TYPE   netwr_ap, " Net value of the order item in document currency
           kowrr    TYPE   kowrr,    " Statistical values
           mwsbp    TYPE   mwsbp,    " Tax amount in document currency
        END OF lty_vbap.

TYPES : BEGIN OF ty_vbak,
             vbeln     TYPE vbeln_va, " Sales Document
             auart     TYPE auart,    " Sales Document Type
             augru     TYPE augru,    " Order reason (reason for the business transaction)
*--> Begin of change for defect 4711.
             waerk     TYPE waerk, " SD Document Currency
*<-- End of change for defect 4711.
             vkorg     TYPE vkorg, " Sales Organization
             vtweg     TYPE vtweg, " Distribution Channel
             vkbur     TYPE vkbur, " Sales Office
             kunnr     TYPE kunag, " Sold-to party
*--> Begin of change for defect 4711.
             bukrs_vf  TYPE bukrs_vf, " Company code to be billed
*<-- End of change for defect 4711.
        END OF ty_vbak.
*--> Begin of change for defect 4711.
TYPES : BEGIN OF lty_t001 ,
            bukrs   TYPE  bukrs, " Company Code
            waers   TYPE  waers, " Currency Key
        END OF lty_t001.
*<-- End of change for defect 4711.
TYPES : BEGIN OF lty_dispute_app,
             vkorg     TYPE     vkorg,          " Sales Organization
             vtweg     TYPE     vtweg,          " Distribution Channel
             vkbur     TYPE     vkbur,          " Sales Office
             applevel  TYPE     z_applevel,     " Approver level
             agr_name  TYPE     agr_name  ,     " Role Name
             netwr         TYPE  netwr_ak,      " Net Value of the Sales Order in Document Currency
             value_compare  TYPE z_val_compare, " Net value comparison operator
        END OF lty_dispute_app.

TYPES : BEGIN OF lty_agr_users,
             agr_name  TYPE agr_name,  " Role Name
             uname     TYPE xubname,   " User Name in User Master Record
             from_dat  TYPE agr_fdate, " Date of validity
             to_dat    TYPE agr_tdate, " Date of validity
        END OF lty_agr_users.

TYPES : BEGIN OF lty_kna1 ,
             kunnr    TYPE   kunnr,    " Customer Number
             name1    TYPE   name1_gp, " Name 1
             name2    TYPE   name2_gp, " Name 2
        END OF lty_kna1.

TYPES : BEGIN OF lty_tvaut,
           spras   TYPE  spras,   " Language Key
           augru   TYPE  augru,   " Order reason (reason for the business transaction)
           bezei   TYPE  bezei40, " Description
       END OF lty_tvaut.

DATA : lwa_kna1  TYPE  lty_kna1.
DATA : lwa_tvaut TYPE lty_tvaut.
DATA : li_vbap TYPE TABLE OF lty_vbap ,
       lwa_vbap TYPE lty_vbap.

DATA : li_agr_user1 TYPE TABLE OF lty_agr_users.

DATA : lwa_vbak  TYPE ty_vbak.
DATA : li_agr_users TYPE TABLE OF agr_users, " Assignment of roles to users
      li_agr_users1 TYPE TABLE OF lty_agr_users,
       lwa_agr_users TYPE agr_users.         " Assignment of roles to users

DATA : lwa_address TYPE bapiaddr3. " BAPI reference structure for addresses (contact person)

DATA : lv_initiator TYPE swp_initia,      " Initiator of workflow instance
       lv_initiator_mail TYPE ad_smtpadr. " E-Mail Address

*--> Begin of change for defect 4711.
DATA : lwa_t001 TYPE lty_t001.
*<-- End of change for defect 4711.
DATA : li_dispute_app TYPE TABLE OF lty_dispute_app, " Credit/Debit Memo Workflow Approvers
       lwa_dispute_app TYPE lty_dispute_app.         " Credit/Debit Memo Workflow Approvers

DATA: lv_level TYPE z_applevel, " Approver level
      lv_cost  TYPE netwr_ak,   " Net Value of the Sales Order in Document Currency
      lv_camt TYPE netwr_ak,    " Net Value of the Sales Order in Document Currency
      lv_cost1 TYPE char20 .    " Cost1 of type CHAR20

DATA : lv_user TYPE xubname. " User Name in User Master Record
DATA : li_return TYPE TABLE OF bapiret2 ,   " Return Parameter
       li_addsmtp TYPE TABLE OF bapiadsmtp. " BAPI Structure for E-Mail Addresses (Bus. Address Services)
FIELD-SYMBOLS : <lfs_addsmtp> TYPE bapiadsmtp. " BAPI Structure for E-Mail Addresses (Bus. Address Services)

DATA : lv_cust_name TYPE char70. " Cust_name of type CHAR70
*--> Begin of Addition for defect 3739.
CONSTANTS : lc_cmr TYPE auart VALUE 'ZCMR',        " Sales Document Type
            lc_cmr_txt TYPE char10 VALUE 'Credit', " Cmr_txt of type CHAR10
            lc_dmr_txt TYPE char10 VALUE 'Debit'.  " Dmr_txt of type CHAR10

DATA : lv_memo_type TYPE rplnr.
*<-- End of Addition for defect 3739.
FIELD-SYMBOLS : <lfs_vbap>  TYPE lty_vbap,
                <lfs_dispute_app> TYPE lty_dispute_app. " Credit/Debit Memo Workflow Approvers

FIELD-SYMBOLS : <lfs_agr_users1> TYPE lty_agr_users.

CONSTANTS : lc_cost TYPE netwr_ak VALUE '0.00', " Net Value of the Sales Order in Document Currency
            lc_uid            TYPE char6         VALUE 'USERID',          " Null Criteria
           lc_wdd_0013        TYPE z_enhancement VALUE 'D2_OTC_WDD_0013'. " Enhancement No.
DATA :     li_status  TYPE TABLE OF zdev_enh_status. " Enhancement Status
DATA : lv_level1 TYPE char4. " Level1 of type CHAR4
FIELD-SYMBOLS : <lfs_status>  TYPE zdev_enh_status. " Enhancement Status

*--> Begin of change for defect 4711.
DATA : lv_famt TYPE bapicurr-bapicurr, " Currency amount in BAPI interfaces
       lv_fcurr TYPE bwaer_curv ,      " Reference currency for currency translation
       lv_lcurr TYPE bwaer_curv,       " Reference currency for currency translation
       lv_lamt TYPE bapicurr-bapicurr. " Currency amount in BAPI interfaces
*<-- End of change for defect 4711.



swc_get_element container 'WC_LEVEL' lv_level.
swc_get_element container 'WC_COST' lv_cost.
swc_get_element container 'WC_INITIATOR' lv_initiator .
lv_level1 = lv_level.

**************
*  Fetch the net price of the memo .
**************
IF lv_cost = lc_cost.
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
      WHERE vbeln = object-key-salesdocument
      AND   abgru = space
      AND   kowrr = space.
    IF sy-subrc IS INITIAL.
      CLEAR lv_level.
      EXIT.
    ELSE. " ELSE -> IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ENDDO.


  LOOP AT li_vbap ASSIGNING <lfs_vbap>.
    lv_cost = lv_cost + <lfs_vbap>-netwr + <lfs_vbap>-mwsbp.
  ENDLOOP. " LOOP AT li_vbap ASSIGNING <lfs_vbap>

ELSE. " ELSE -> IF lv_cost = lc_cost
***  lv_level1 = lv_level1 + 1.
ENDIF. " IF lv_cost = lc_cost

lv_level1 = lv_level1 + 1.
lv_level = lv_level1.

****   Get the header information for the memo .
SELECT SINGLE
          vbeln " Sales Document
          auart " Sales Document Type
          augru " Order reason (reason for the business transaction)
*--> Begin of change for defect 4711.
          waerk
*<-- End of change for defect 4711.
          vkorg " Sales Organization
          vtweg " Distribution Channel
          vkbur " Sales Office
          kunnr " Sales Office
*--> Begin of change for defect 4711.
          bukrs_vf " Company code to be billed
*<-- End of change for defect 4711.
 FROM vbak " Sales Document: Header Data
 INTO lwa_vbak
 WHERE vbeln = object-key-salesdocument.

*--> Begin of changes for defect 4711.

SELECT SINGLE
         bukrs " Company Code
         waers " Currency Key
  FROM t001    " Company Codes
  INTO lwa_t001
  WHERE bukrs = lwa_vbak-bukrs_vf.

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
*     RATE             = 0
*     TYPE_OF_RATE     = 'M'
*     READ_TCURR       = 'X'
    IMPORTING
      local_amount     = lv_lamt
    EXCEPTIONS
      no_rate_found    = 1
      overflow         = 2
      no_factors_found = 3
      no_spread_found  = 4
      derived_2_times  = 5
      OTHERS           = 6.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF. " IF sy-subrc <> 0

  lv_camt = lv_lamt .
ELSE. " ELSE -> IF sy-subrc <> 0
  lv_camt = lv_cost.
ENDIF. " IF lwa_vbak-waerk <> lwa_t001-waers
*<-- End of changes for Defect 4711.

******** get the customer name .
SELECT SINGLE
     kunnr " Customer Number
     name1 " Name 1
     name2 " Name 2
FROM kna1  " General Data in Customer Master
INTO lwa_kna1
WHERE kunnr = lwa_vbak-kunnr.

CONCATENATE lwa_kna1-name1 lwa_kna1-name2 INTO lv_cust_name SEPARATED BY space.

**** get the order reason.
SELECT SINGLE
       spras " Language Key
       augru " Order reason (reason for the business transaction)
       bezei " Description
FROM tvaut   " Sales Documents: Order Reasons: Texts
  INTO lwa_tvaut
WHERE spras = 'EN'
AND   augru = lwa_vbak-augru.
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

*  DELETE li_dispute_app WHERE applevel LE lv_level.
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
ELSE. " ELSE -> IF li_dispute_app IS NOT INITIAL
  lv_level = '9999'.
***   if no users maintained then mail should be sent to the admin.
ENDIF. " IF sy-subrc IS INITIAL

IF li_dispute_app[] IS INITIAL OR li_agr_users1[] IS INITIAL .

  lv_level = '9999'.

  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_wdd_0013
    TABLES
      tt_enh_status     = li_status.

  READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_uid     "NULL
                                                       active   = abap_true. "X"
  IF sy-subrc IS INITIAL.
    REFRESH li_addsmtp.
    lv_user = <lfs_status>-sel_low.

    CALL FUNCTION 'BAPI_USER_GET_DETAIL'
      EXPORTING
        username = lv_user
      TABLES
        return   = li_return
        addsmtp  = li_addsmtp.

    READ TABLE li_addsmtp ASSIGNING <lfs_addsmtp> INDEX 1.
    IF sy-subrc IS INITIAL.

      swc_set_element container 'WC_ADMIN' <lfs_addsmtp>-e_mail.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL
ENDIF. " IF li_dispute_app[] IS INITIAL OR li_agr_users1[] IS INITIAL
" IF sy-subrc IS INITIAL


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
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = lv_user
    IMPORTING
      address  = lwa_address
    TABLES
      return   = li_return
      addsmtp  = li_addsmtp.

  READ TABLE li_addsmtp ASSIGNING <lfs_addsmtp> INDEX 1.
  swc_set_element container 'WC_IMAIL' <lfs_addsmtp>-e_mail.
ENDIF. " IF lv_user IS NOT INITIAL

*--> Begin of Addition for Defect 3739.
* if the transaction type is ZCMR then the memo type is Credit.
* if the transaction type is ZDMR then the memo type is Debit.
IF lwa_vbak-auart = lc_cmr.
  lv_memo_type = lc_cmr_txt.
ELSE. " ELSE -> IF lwa_vbak-auart = lc_cmr
  lv_memo_type = lc_dmr_txt.
ENDIF. " IF lwa_vbak-auart = lc_cmr
swc_set_element container 'WC_MTYPE' lv_memo_type.
*<-- End of Addition for Defect 3739.

swc_set_element container 'WC_CREATOR' lwa_address-fullname.
swc_set_element container 'WC_OREASON' lwa_tvaut-bezei.
swc_set_element container 'WC_LEVEL' lv_level  .
swc_set_table container 'WC_APPROVERS' li_agr_users.
swc_set_element container 'WC_MEMO_COST' lv_cost.
swc_set_element container 'WC_CUST_NAME' lv_cust_name.
swc_set_element container 'WC_TTYPE' lwa_vbak-auart.

end_method.

*-------------------------------------------------*
*     Update the comments in header text.
*-------------------------------------------------*
begin_method wmbo_update_comments changing container.

DATA : li_subcontainer TYPE TABLE OF swr_cont. " Container (name-value pairs)
DATA : li_simple_container  TYPE TABLE OF swr_cont,        " Container (name-value pairs)
       li_message_lines TYPE TABLE OF swr_messag,          " Workflow Interfaces: Messages
       li_message_struct TYPE TABLE OF swr_mstruc,         " Workflow interfaces: Message structure
       li_subcontainer_bor_objects TYPE TABLE OF swr_cont. " Container (name-value pairs)


DATA : lv_document_id TYPE so_entryid. " Folder Entry ID (Obj+Fol+Forwarder Name)
DATA : li_object_content TYPE TABLE OF solisti1. " SAPoffice: Single List with Column Length 255
FIELD-SYMBOLS : <lfs_subcontainer> TYPE swr_cont,   " Container (name-value pairs)\
                <lfs_object_content> TYPE solisti1. " SAPoffice: Single List with Column Length 255
DATA: lv_workid TYPE sww_wiid. " Work item ID
CONSTANTS : lc_id  TYPE tdid VALUE 'Z015',         " Change for defect 3080.
            lc_object  TYPE tdobject VALUE 'VBBK'. " Texts: Application Object

DATA : lv_lang TYPE spras,    " Language Key
       lv_name TYPE tdobname. " Name
DATA : li_lines TYPE TABLE OF tline,       " SAPscript: Text Lines
       li_lines_save TYPE TABLE OF tline . " SAPscript: Text Lines
DATA : lv_date TYPE char10. " Field of type DATS
DATA : lwa_lines TYPE tline . " SAPscript: Text Lines
DATA : lv_return_code TYPE sy-subrc. " Return Value of ABAP Statements
DATA : lv_app_userid TYPE xubname. " User Name in User Master Record
DATA : lv_result  TYPE  swd_retur_, " Workflow Definition: Container Expression for Step Result
       lv_action TYPE char10,       " Action of type CHAR10
       lv_agent TYPE swp_agent.     " Agent
****  Save text.
DATA : lwa_header TYPE thead,  " SAPscript: Text Header
       lv_function TYPE char1. " Function of type CHAR1
DATA : lv_time TYPE char8. "   defect 3739.
DATA : lv_string TYPE string .
*--> Begin of addition for Defect 8668 .
data : lv_user type XUBNAME,
       li_return  type table of BAPIRET2,
       lwa_address type BAPIADDR3.
*<-- End of addition for Defect 8668 .

swc_get_element container 'WC_WORKITEM_ID' lv_workid.
*--> begin of change for defect 3080.
swc_get_element container 'WC_APP_USERID' lv_app_userid.
swc_get_element container 'WC_RESULT' lv_result.
swc_get_element container 'WC_ACTUAL_AGENT' lv_agent .
*<-- end of change for defect 3080.

lv_app_userid = lv_agent+2(12).

*--> Begin of addition for Defect 8668 .
* Get the user name of the agent and display it in the comments.

lv_user = lv_app_userid .

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = lv_user
    IMPORTING
       ADDRESS = lwa_ADDRESS
    TABLES
      return   = li_return.

*-- End of addition for Defect 8668.

IF lv_result = '0001'.
  lv_action = 'Approve'.
ELSEIF lv_result = '0002'.
  lv_action = 'Reject'.
ELSEIF lv_result = '0003'.
  lv_action = 'Return'.
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

  IF sy-subrc IS INITIAL.

    LOOP AT li_subcontainer ASSIGNING <lfs_subcontainer>
                                   WHERE element = '_ATTACH_OBJECTS'.
      lv_document_id = <lfs_subcontainer>-value.
    ENDLOOP. " LOOP AT li_subcontainer ASSIGNING <lfs_subcontainer>

    IF lv_document_id IS NOT INITIAL.
*   Read the SOFM Document
*  Get the contents of the attachment.
      CALL FUNCTION 'SO_DOCUMENT_READ_API1'
        EXPORTING
          document_id    = lv_document_id
        TABLES
          object_content = li_object_content. "   text in the workitem .
    ENDIF. " IF lv_document_id IS NOT INITIAL
  ENDIF. " IF sy-subrc IS INITIAL


*** Read the text saved .
** Reading the previously saved text.
  lv_name = object-key-salesdocument.
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
  IF sy-subrc IS INITIAL.
* Implement suitable error handling here
************    li_lines_save[] = li_lines[].
  ENDIF. " IF sy-subrc IS INITIAL

*--> begin of change for defect 3080.
  WRITE sy-datum TO lv_date.
*--> Begin of Addition for defect 3739.
* Set the system date to lv_time.
  WRITE sy-uzeit TO lv_time.
*<-- End of addition for defect 3739.

*--> Begin of addition for Defect 8668.
  CONCATENATE lv_agent+2(12) lwa_address-FULLNAME lv_date lv_time  lv_action ':' INTO lv_string SEPARATED BY space.
*<-- End of addition for Defect 8668.


  lwa_lines-tdline = lv_string.
  APPEND lwa_lines TO li_lines_save.
  CLEAR lwa_lines.
***************  New comment .

  LOOP AT  li_object_content ASSIGNING <lfs_object_content>.
*    lwa_lines-tdline = <lfs_object_content>-line+5(250).  " Defect 8913
    lwa_lines-tdline = <lfs_object_content>-line+0(250).  " Defect 8913
    APPEND lwa_lines TO li_lines_save.
    CLEAR lwa_lines.
  ENDLOOP. " LOOP AT li_object_content ASSIGNING <lfs_object_content>
*--> Begin of Addition for defect 3739.
*  Appending a blank line in the text internal table.
  CLEAR lwa_lines.
  lwa_lines = cl_abap_char_utilities=>newline.
  APPEND lwa_lines TO li_lines_save.
*<-- End of Additon for defect 3739.
**** Appending old comments.
  LOOP AT li_lines INTO lwa_lines .
    APPEND lwa_lines TO li_lines_save.
  ENDLOOP. " LOOP AT li_lines INTO lwa_lines

*<-- end of change for defect 3080 .


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
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF li_lines_save IS NOT INITIAL
ENDIF. " IF lv_workid IS NOT INITIAL

swc_set_element container 'WC_APP_USERID' lv_app_userid.
end_method.

*-----------------------------------------------*
*  Update the status .
*-----------------------------------------------*
begin_method wmbo_update_status changing container.
TYPES : BEGIN OF lty_vbak ,
          vbeln    TYPE vbeln_va, " Sales Document
          objnr    TYPE objko,    " Object number at header level
        END OF lty_vbak .
DATA : lwa_vbak TYPE lty_vbak.
DATA : lv_status_indicator TYPE vbtyp_v. " Document category of preceding SD document

DATA : lv_user_status TYPE j_status. " Object status
DATA : lv_user_status1 TYPE j_status. " Object status
DATA : lv_objnr TYPE j_objnr. " Object number
DATA : lv_stonr TYPE j_stonr. " Status Order Number
DATA : lv_level TYPE z_applevel. " Approver level
DATA : li_vbap TYPE TABLE OF vbap, " Sales Document: Item Data
       lwa_vbap TYPE vbap.         " Sales Document: Item Data

DATA : lwa_order_header_in  TYPE bapisdh1,    " Communication Fields: SD Order Header
         lwa_order_header_inx TYPE bapisdh1x. " Checkbox List: SD Order Header

DATA : lit_return_head TYPE TABLE OF bapiret2 . " Return Parameter
FIELD-SYMBOLS :  <lfs_return_head> TYPE bapiret2. " Return Parameter

TYPES : BEGIN OF ty_vbap,
           vbeln   TYPE vbeln_va, " Sales Document
           posnr   TYPE posnr_va, " Sales Document Item
        END OF ty_vbap.

DATA : lit_vbap TYPE TABLE OF ty_vbap.
FIELD-SYMBOLS : <lfs_vbap> TYPE ty_vbap.

DATA : lit_order_item_in TYPE TABLE OF bapisditm,   " Communication Fields: Sales and Distribution Document Item
       lwa_order_item_in TYPE bapisditm,            " Communication Fields: Sales and Distribution Document Item
       lit_order_item_inx TYPE TABLE OF bapisditmx, " Communication Fields: Sales and Distribution Document Item
       lwa_order_item_inx TYPE bapisditmx.          " Communication Fields: Sales and Distribution Document Item


CONSTANTS: lc_rej_reason TYPE char2 VALUE 'R6', " Rej_reason of type CHAR2
           lc_updateflag TYPE char1 VALUE 'U',  " Updateflag of type CHAR1
           lc_rej TYPE char1 VALUE 'X'.         " Rej of type CHAR1
CONSTANTS : lc_etype TYPE char1 VALUE 'E'.
swc_get_element container 'WC_INDICATOR' lv_status_indicator.


IF lv_status_indicator EQ 'A'.
*  Approve
  lv_user_status = 'E0003'.
ELSEIF lv_status_indicator EQ 'R'.
*    Reject
  lv_user_status = 'E0004'.
ELSEIF lv_status_indicator EQ 'C'. " Set the status approval in process.
*    Return
  lv_user_status = 'E0002'.
ELSEIF lv_status_indicator EQ 'B'.
  lv_user_status = 'E0001'.
ENDIF. " IF lv_status_indicator EQ 'A'

*--> Begin of change for defect 3080.

*IF lv_status_indicator EQ 'A'. "  update the bilng block .
*
*  lwa_order_header_inx-updateflag = 'U'.
*  lwa_order_header_inx-bill_block = 'X'.
*
*  CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
*    EXPORTING
*      salesdocument         = object-key-salesdocument
*      order_header_in       = lwa_order_header_in
*      order_header_inx      = lwa_order_header_inx
**     SIMULATION            =
**     BEHAVE_WHEN_ERROR     = ' '
**     INT_NUMBER_ASSIGNMENT = ' '
**     LOGIC_SWITCH          =
**     NO_STATUS_BUF_INIT    = ' '
*    TABLES
*      return                = lit_return_head.
*
*  READ TABLE lit_return_head ASSIGNING <lfs_return_head> WITH KEY type = 'E'. " Return_head int of type
*  IF sy-subrc IS NOT INITIAL.
*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
*  ENDIF. " IF sy-subrc IS NOT INITIAL
*ENDIF. " IF object-_vbak-mandt IS INITIAL



*--> begin of change for defect 3080.
*** update the rejection status in the line item .
IF lv_status_indicator EQ 'R'. " update the reason of rejection for all the items .



*  Fetch all the line item
  SELECT vbeln           " Sales Document
         posnr FROM vbap " Sales Document: Item Data
    INTO TABLE lit_vbap
    WHERE vbeln = object-key-salesdocument .


  LOOP AT lit_vbap ASSIGNING <lfs_vbap> .
    lwa_order_item_in-itm_number = <lfs_vbap>-posnr.
    lwa_order_item_in-reason_rej = lc_rej_reason.
    APPEND lwa_order_item_in TO lit_order_item_in.
    CLEAR lwa_order_item_in .

    lwa_order_item_inx-itm_number = <lfs_vbap>-posnr.
    lwa_order_item_inx-updateflag = lc_updateflag.
    lwa_order_item_inx-reason_rej = lc_rej.
    APPEND lwa_order_item_inx TO lit_order_item_inx.
    CLEAR lwa_order_item_inx.
  ENDLOOP. " LOOP AT lit_vbap ASSIGNING <lfs_vbap>

  lwa_order_header_inx-updateflag = lc_updateflag.

  CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
    EXPORTING
      salesdocument    = object-key-salesdocument
*     ORDER_HEADER_IN  =
      order_header_inx = lwa_order_header_inx
    TABLES
      return           = lit_return_head
      order_item_in    = lit_order_item_in
      order_item_inx   = lit_order_item_inx.

  READ TABLE lit_return_head ASSIGNING <lfs_return_head> WITH KEY type = lc_etype. " Return_head ass of type
  IF sy-subrc IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
  ENDIF. " IF sy-subrc IS NOT INITIAL
ENDIF. " IF object-_vbak-mandt IS INITIAL
*<-- end of change for defect 3080.

*Get the object number for the memo for which the status is to be updated.

SELECT SINGLE
       vbeln " Sales Document
       objnr " Object number at header level
  FROM vbak  " Sales Document: Header Data
  INTO lwa_vbak
  WHERE vbeln = object-key-salesdocument.

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
  ENDIF. " IF lv_stonr IS NOT INITIAL

ENDIF. " IF sy-subrc IS INITIAL


end_method.

*----------------------------------------------------*
*    Send Notification to approvers.
*----------------------------------------------------*

begin_method wmbo_send_notification changing container.

DATA : li_approvers TYPE TABLE OF agr_users, " Assignment of roles to users
       lwa_approvers TYPE agr_users.         " Assignment of roles to users
DATA :   li_addsmtp  TYPE STANDARD TABLE OF bapiadsmtp,              " BAPI Structure for E-Mail Addresses (Bus. Address Services)
         lwa_addsmtp TYPE bapiadsmtp,                                " BAPI Structure for E-Mail Addresses (Bus. Address Services)
         lv_subject  TYPE so_obj_des,                                " Short description of contents
         li_return   TYPE STANDARD TABLE OF bapiret2,                " Return Parameter
         lwa_body    TYPE soli,                                      " SAPoffice: line, length 255
         li_body     TYPE bcsy_text ,
         li_recipients_temp TYPE STANDARD TABLE OF zdev_receipients, " InfoUser (SEM-BIC)
         li_recipient TYPE TABLE OF zdev_receipients ,               " InfoUser (SEM-BIC)
         lwa_recipient TYPE zdev_receipients,                        " InfoUser (SEM-BIC)
         lv_result  TYPE boolean.                                    " Boolean Variable (X=True, -=False, Space=Unknown)

DATA : lv_username TYPE  bapibname-bapibname. " User Name in User Master Record
FIELD-SYMBOLS : <lfs_approvers> TYPE agr_users. " Assignment of roles to users

CONSTANTS: lc_object TYPE tdobject VALUE 'TEXT',    " Texts: Application Object
           lc_id     TYPE tdid     VALUE 'ST',      " Text ID
           lc_lang   TYPE thead-tdspras VALUE 'EN'. " Language Key
*--> Begin of Addition for Defect 3739.
CONSTANTS : lc_cmr TYPE char4 VALUE 'ZCMR',        " Cmr of type CHAR4
            lc_cmr_txt TYPE char10 VALUE 'Credit', " Cmr_txt of type CHAR10
            lc_dmr_txt TYPE char10 VALUE 'Debit'.  " Dmr_txt of type CHAR10
*<-- End of Addition for Defect 3739.
DATA : lv_curr TYPE char5. " Curr of type CHAR5
CONSTANTS : lc_app_sub TYPE tdobname VALUE 'ZOTC_WDD_0013_NOTIF_SUB',   " Name
            lc_app_txt TYPE   tdobname VALUE 'ZOTC_WDD_0013_NOTIF_TXT'. " Name
DATA :
       li_sub_txt           TYPE STANDARD TABLE OF tline, " SAPscript: Text Lines
       lwa_sub_txt           TYPE tline,                  " SAPscript: Text Lines
       li_body_txt          TYPE STANDARD TABLE OF tline. " SAPscript: Text Lines

DATA : lv_creator    TYPE   ad_namtext, " Full Name of Person
       lv_oreason    TYPE   bezei40,    " Description
       lv_memo_cost  TYPE   netwr_ak,   " Net Value of the Sales Order in Document Currency
       lv_cost_char  TYPE   char20,     " Cost_char of type CHAR20
       lv_cust_name  TYPE   ad_namtext, " Full Name of Person
       lv_ttype      TYPE   auart.


TYPES : BEGIN OF lty_vbap,
           vbeln    TYPE   vbeln_va, " Sales Document
           posnr    TYPE   posnr_va, " Sales Document Item
           abgru    TYPE   abgru_va, " Reason for rejection of quotations and sales orders
           netwr    TYPE   netwr_ap, " Net value of the order item in document currency
           waerk    TYPE   waerk,    " SD Document Currency
           kowrr    TYPE   kowrr,    " Statistical values
           mwsbp    TYPE   mwsbp,    " Tax amount in document currency
        END OF lty_vbap.
*--> Begin of Addition for Defect 3739.
TYPES : BEGIN OF lty_vbak,
            vbeln  TYPE vbeln_va, " Sales Document
            kunnr  TYPE kunag,    " Sold-to party
        END OF lty_vbak.
DATA : lwa_vbak TYPE lty_vbak.

TYPES : BEGIN OF lty_kna1,
          kunnr    TYPE kunnr,    " Customer Number
          ort01    TYPE ort01_gp, " City
          pstlz    TYPE pstlz,    " Postal Code
        END OF lty_kna1.

DATA : lwa_kna1 TYPE lty_kna1.
DATA : lv_mtype TYPE char10.
*<-- End of addition for defect 3739.
DATA : li_vbap TYPE TABLE OF lty_vbap.
FIELD-SYMBOLS : <lfs_vbap> TYPE lty_vbap.


swc_get_element container 'WC_APPROVERS' li_approvers.
swc_get_element container 'WC_CREATOR' lv_creator.
swc_get_element container 'WC_OREASON' lv_oreason.
swc_get_element container 'WC_MEMO_COST' lv_memo_cost.
swc_get_element container 'WC_CUST_NAME' lv_cust_name.
swc_get_element container 'WC_TTYPE' lv_ttype.


*-->Begin of Addition for defect 3739.
* fetch the sold to party from VBAK ,
* fetch the customer details from table kna1.

SELECT SINGLE  vbeln " Sales Document
               kunnr " Sold-to party
  FROM vbak          " Sales Document: Header Data
  INTO lwa_vbak
  WHERE vbeln = object-key-salesdocument.
IF sy-subrc IS INITIAL.
  SELECT SINGLE kunnr " Customer Number
          ort01       " City
          pstlz       " Postal Code
    FROM kna1         " General Data in Customer Master
    INTO lwa_kna1
    WHERE kunnr = lwa_vbak-kunnr.
  IF sy-subrc IS INITIAL.
  ENDIF. " IF sy-subrc IS INITIAL
ENDIF . " IF sy-subrc IS INITIAL


IF lv_ttype = lc_cmr.
  lv_mtype = lc_cmr_txt.
ELSE. " ELSE -> IF lv_ttype = lc_cmr
  lv_mtype = lc_dmr_txt.
ENDIF. " IF lv_ttype = lc_cmr

*<-- End of Addition for defect 3739.

SELECT vbeln " Sales Document
       posnr " Sales Document Item
       abgru " Reason for rejection of quotations and sales orders
       netwr " Net value of the order item in document currency
       waerk " SD Document Currency
       kowrr " Statistical values
       mwsbp " Tax amount in document currency
  FROM vbap  " Sales Document: Item Data
  INTO TABLE li_vbap
  WHERE vbeln = object-key-salesdocument
  AND   abgru = space
  AND   kowrr = space.



LOOP AT li_vbap ASSIGNING <lfs_vbap>.
  lv_memo_cost = lv_memo_cost + <lfs_vbap>-netwr + <lfs_vbap>-mwsbp.
  lv_curr = <lfs_vbap>-waerk.
ENDLOOP. " LOOP AT li_vbap ASSIGNING <lfs_vbap>

lv_cost_char = lv_memo_cost.
if <lfs_vbap> is ASSIGNED . "(+) Defect 8668 by ddwivedi ob 14-july-2015
lv_curr = <lfs_vbap>-waerk.
ENDIF. "(+) Defect 8668 by ddwivedi ob 14-july-2015
****   Fetch the subject
*Text is maintained in EN language only .
CALL FUNCTION 'READ_TEXT'
  EXPORTING
    id                      = lc_id
    language                = lc_lang
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
    language                = lc_lang
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
  REPLACE 'xDOC_NOx' IN lwa_sub_txt-tdline WITH object-key-salesdocument.
  lv_subject = lwa_sub_txt-tdline .
  EXIT.
ENDLOOP. " LOOP AT li_sub_txt INTO lwa_sub_txt


CLEAR : li_body[].
LOOP AT li_body_txt INTO lwa_sub_txt.

  REPLACE 'xDOC_NOx'    IN lwa_sub_txt-tdline WITH object-key-salesdocument .
  REPLACE 'xCUST_NAMEx' IN lwa_sub_txt-tdline WITH  lv_cust_name.
  REPLACE 'xNET_AMTx'   IN lwa_sub_txt-tdline WITH  lv_cost_char.
  REPLACE 'xCURx' IN lwa_sub_txt-tdline WITH lv_curr.
  REPLACE 'xOREASONx'   IN lwa_sub_txt-tdline WITH  lv_oreason.
  REPLACE 'xTTYPEx'     IN lwa_sub_txt-tdline WITH lv_ttype.
  REPLACE 'xCREATORx'   IN lwa_sub_txt-tdline WITH lv_creator.
*--> Begin of Addition for defect 3739.
*  Update the customer details in the mail text.
  REPLACE 'xKUNNRx' IN lwa_sub_txt-tdline WITH lwa_vbak-kunnr.
  REPLACE 'xMTYPEx' IN lwa_sub_txt-tdline WITH lv_mtype.
  REPLACE 'xCITYx'  IN lwa_sub_txt-tdline WITH lwa_kna1-ort01.
  REPLACE 'xPOSTx' IN lwa_sub_txt-tdline WITH lwa_kna1-pstlz.

*<-- End of Addition for defect 3739.
  replace '<(>' in lwa_sub_txt-tdline with space.
  replace '<)>' in lwa_sub_txt-tdline with space.
  lwa_body-line = lwa_sub_txt-tdline.
  APPEND lwa_body TO li_body.
  CLEAR lwa_body.
ENDLOOP. " LOOP AT li_body_txt INTO lwa_sub_txt


LOOP AT li_approvers ASSIGNING <lfs_approvers>.

  lv_username = <lfs_approvers>-uname.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = lv_username
    TABLES
      return   = li_return
      addsmtp  = li_addsmtp.

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
ENDLOOP. " LOOP AT li_approvers ASSIGNING <lfs_approvers>

end_method.
